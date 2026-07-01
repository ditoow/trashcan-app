import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/scan_result.dart';
import '../../../domain/models/scan_status.dart';
import '../../../services/hf_inference_service.dart';
import 'package:image/image.dart' as img;

class ScanState {
  final ScanResult result;
  final ScanStatus status;
  final double inferenceMs;

  const ScanState({
    required this.result,
    required this.status,
    this.inferenceMs = 0,
  });

  ScanState copyWith({
    ScanResult? result,
    ScanStatus? status,
    double? inferenceMs,
  }) {
    return ScanState(
      result: result ?? this.result,
      status: status ?? this.status,
      inferenceMs: inferenceMs ?? this.inferenceMs,
    );
  }
}

final scanProvider = NotifierProvider<ScanNotifier, ScanState>(
  ScanNotifier.new,
);

class ScanNotifier extends Notifier<ScanState> {
  HfInferenceService? _service;
  Timer? _timer;
  bool _isProcessing = false;
  CameraImage? _latestFrame;
  int _missCount = 0; // consecutive frames without detection
  static const _missThreshold = 3; // clear result after this many misses

  @override
  ScanState build() {
    Future.microtask(() => _initService());
    ref.onDispose(() {
      _timer?.cancel();
      _service?.dispose();
    });
    return ScanState(
      result: ScanResult.empty(),
      status: ScanStatus.scanning,
    );
  }

  void setLatestFrame(CameraImage image) {
    _latestFrame = image;
  }

  Future<void> _initService() async {
    try {
      final hf = HfInferenceService();
      await hf.initialize();
      _service = hf;
      debugPrint('Classifier: using HF API');
      startScanning();
    } catch (e) {
      debugPrint('Classifier: HF init failed: $e');
      state = state.copyWith(status: ScanStatus.error);
    }
  }

  void startScanning() {
    _timer?.cancel();
    state = state.copyWith(status: ScanStatus.scanning);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _performScan();
    });
  }

  void stopScanning() {
    _timer?.cancel();
    state = state.copyWith(status: ScanStatus.paused);
  }

  Future<void> _performScan() async {
    if (_isProcessing || state.status == ScanStatus.paused) return;

    final frame = _latestFrame;
    if (frame == null) return;

    final service = _service;
    if (service == null) return;

    _isProcessing = true;
    state = state.copyWith(status: ScanStatus.loading);

    try {
      final scanWatch = Stopwatch()..start();
      final (rgbBytes, w, h) = _frameToRgb(frame);
      final imgObj = img.Image.fromBytes(
        width: w,
        height: h,
        bytes: rgbBytes.buffer,
        order: img.ChannelOrder.rgb,
      );
      final jpegBytes = img.encodeJpg(imgObj, quality: 70);
      final newResult = await service.detect(jpegBytes);
      scanWatch.stop();

      if (state.status == ScanStatus.paused) return;

      final totalMs = scanWatch.elapsedMilliseconds.toDouble();

      if (newResult.confidence > 0) {
        // Got a detection — show it and reset miss counter
        _missCount = 0;
        state = state.copyWith(
          result: newResult,
          status: ScanStatus.scanning,
          inferenceMs: totalMs,
        );
      } else {
        // No detection — keep previous result for a few frames
        _missCount++;
        if (_missCount >= _missThreshold) {
          state = state.copyWith(
            result: newResult, // "Tidak terdeteksi"
            status: ScanStatus.scanning,
            inferenceMs: totalMs,
          );
        } else {
          // Keep previous detection visible, just update timing
          state = state.copyWith(
            status: ScanStatus.scanning,
            inferenceMs: totalMs,
          );
        }
      }
    } catch (e, stack) {
      debugPrint('Scan error: $e');
      debugPrint('Stack: $stack');
      state = state.copyWith(status: ScanStatus.scanning);
    } finally {
      _isProcessing = false;
    }
  }

  ImageFormatGroup? _lastLoggedFormat;

  (Uint8List, int, int) _frameToRgb(CameraImage image) {
    // Only log format once to reduce spam
    if (_lastLoggedFormat != image.format.group) {
      _lastLoggedFormat = image.format.group;
      debugPrint('CAM format: ${image.format.group} planes: ${image.planes.length} (${image.width}x${image.height})');
    }
    if (image.format.group == ImageFormatGroup.yuv420) {
      return (_yuv420ToRgb(image), image.width, image.height);
    } else if (image.format.group == ImageFormatGroup.bgra8888) {
      return (_bgraToRgb(image), image.width, image.height);
    } else {
      return (_rawToRgb(image), image.width, image.height);
    }
  }

  Uint8List _rawToRgb(CameraImage image) {
    final plane = image.planes.first;
    final bytes = plane.bytes;
    final width = image.width;
    final height = image.height;
    final stride = plane.bytesPerRow;
    final rgb = Uint8List(width * height * 3);
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final s = y * stride + x;
        final d = (y * width + x) * 3;
        rgb[d] = bytes[s];
        rgb[d + 1] = bytes[s];
        rgb[d + 2] = bytes[s];
      }
    }
    return rgb;
  }

  Uint8List _bgraToRgb(CameraImage image) {
    final plane = image.planes[0];
    final bytes = plane.bytes;
    final width = image.width;
    final height = image.height;
    final stride = plane.bytesPerRow;
    final rgb = Uint8List(width * height * 3);
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final s = y * stride + x * 4;
        final d = (y * width + x) * 3;
        rgb[d] = bytes[s + 2];
        rgb[d + 1] = bytes[s + 1];
        rgb[d + 2] = bytes[s];
      }
    }
    return rgb;
  }

  Uint8List _yuv420ToRgb(CameraImage image) {
    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final yBytes = yPlane.bytes;
    final uBytes = uPlane.bytes;
    final vBytes = vPlane.bytes;

    final yRowStride = yPlane.bytesPerRow;
    final uRowStride = uPlane.bytesPerRow;

    final width = image.width;
    final height = image.height;

    final rgb = Uint8List(width * height * 3);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final yIndex = y * yRowStride + x;
        final uvX = x >> 1;
        final uvY = y >> 1;
        final uvIndex = uvY * uRowStride + uvX;

        final yy = yBytes[yIndex];
        final u = uBytes[uvIndex] - 128;
        final v = vBytes[uvIndex] - 128;

        int r = (yy + 1.402 * v + 0.5).toInt();
        int g = (yy - 0.344 * u - 0.714 * v + 0.5).toInt();
        int b = (yy + 1.772 * u + 0.5).toInt();

        final pixelIndex = (y * width + x) * 3;
        rgb[pixelIndex] = r.clamp(0, 255);
        rgb[pixelIndex + 1] = g.clamp(0, 255);
        rgb[pixelIndex + 2] = b.clamp(0, 255);
      }
    }

    return rgb;
  }
}
