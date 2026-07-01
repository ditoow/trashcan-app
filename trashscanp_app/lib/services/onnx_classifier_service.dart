import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../domain/models/scan_result.dart';
import '../domain/models/waste_category.dart';

class OnnxClassifierService {
  OrtSession? _session;
  bool _initialized = false;

  static const int _inputSize = 640;
  static const int _numClasses = 4;
  static const int _numDetections = 8400;

  // Per-class confidence thresholds matching Python webcam_detection.py
  static const List<double> _classConfThresholds = [
    0.10, // plastik  — banyak variasi bentuk, threshold rendah
    0.25, // kertas
    0.25, // logam
    0.35, // lainnya  — sering false positive, threshold tinggi
  ];

  // Box area filters (ratio of box area to frame area)
  static const double _maxAreaRatio = 0.45; // box too big → probably background
  static const double _minAreaRatio = 0.0005; // box too small → noise

  static const List<WasteCategory> _categoryMap = [
    WasteCategory.plastic,
    WasteCategory.paper,
    WasteCategory.metal,
    WasteCategory.other,
  ];

  static const List<String> _labelMap = [
    'Plastik',
    'Kertas',
    'Logam',
    'Lainnya',
  ];

  final OnnxRuntime _ort = OnnxRuntime();

  // Letterbox info for coordinate mapping
  double _scale = 1.0;
  int _padX = 0;
  int _padY = 0;
  int _origW = _inputSize;
  int _origH = _inputSize;

  // FPS tracking
  final Stopwatch _inferenceWatch = Stopwatch();
  double lastInferenceMs = 0;

  Future<void> initialize() async {
    if (_initialized) return;

    _session = await _ort.createSessionFromAsset('assets/models/best.onnx');
    _initialized = true;
    dev.log('ONNX Runtime initialized', name: 'OnnxClassifierService');
  }

  bool get isInitialized => _initialized;

  void dispose() {
    _session?.close();
    _session = null;
    _initialized = false;
  }

  Future<ScanResult> detect(Uint8List jpegBytes) async {
    if (!_initialized) await initialize();

    final image = img.decodeImage(jpegBytes);
    if (image == null) throw Exception('Failed to decode image');
    final inputData = _letterbox(image);
    final input = await OrtValue.fromList(inputData, [1, 3, _inputSize, _inputSize]);
    return _runInference(input);
  }

  bool _savedDebugImage = false;

  Future<ScanResult> detectRgb(Uint8List rgb, int w, int h) async {
    if (!_initialized) await initialize();

    final image = img.Image.fromBytes(
      width: w,
      height: h,
      bytes: rgb.buffer,
      numChannels: 3,
      order: img.ChannelOrder.rgb,
    );

    // Save one debug frame to see orientation & colors
    if (!_savedDebugImage) {
      _savedDebugImage = true;
      Future.microtask(() async {
        try {
          final tempDir = await getTemporaryDirectory();
          final debugFile = File('${tempDir.path}/debug_frame.jpg');
          // Write the original camera image to check rotation
          final jpegBytes = img.encodeJpg(image);
          await debugFile.writeAsBytes(jpegBytes);
          debugPrint('DEBUG IMAGE SAVED TO: ${debugFile.path} (Resolution: ${w}x${h})');
        } catch (e) {
          debugPrint('Failed to save debug image: $e');
        }
      });
    }

    final inputData = _letterbox(image);
    final input = await OrtValue.fromList(inputData, [1, 3, _inputSize, _inputSize]);
    return _runInference(input);
  }

  Future<ScanResult> _runInference(OrtValue input) async {
    _inferenceWatch.reset();
    _inferenceWatch.start();

    final outputs = await _session!.run({'images': input});
    final outputTensor = outputs.values.first;
    final outputList = await outputTensor.asFlattenedList();

    _inferenceWatch.stop();
    lastInferenceMs = _inferenceWatch.elapsedMilliseconds.toDouble();

    debugPrint('ONNX output shape: ${outputTensor.shape} (length: ${outputList.length})');

    return _postprocess(outputList);
  }

  int _lastLbW = 0;
  int _lastLbH = 0;

  /// Letterbox resize: scale image to fit _inputSize while preserving aspect ratio,
  /// then pad with gray (114) to fill the square.
  Float32List _letterbox(img.Image image) {
    _origW = image.width;
    _origH = image.height;
    _scale = math.min(_inputSize / _origW, _inputSize / _origH);

    final newW = (_origW * _scale).round();
    final newH = (_origH * _scale).round();
    _padX = (_inputSize - newW) ~/ 2;
    _padY = (_inputSize - newH) ~/ 2;

    if (_lastLbW != _origW || _lastLbH != _origH) {
      _lastLbW = _origW;
      _lastLbH = _origH;
      debugPrint('Letterbox: ${_origW}x$_origH → ${newW}x$newH pad=($_padX,$_padY)');
    }

    final resized = img.copyResize(image, width: newW, height: newH, interpolation: img.Interpolation.nearest);

    final input = Float32List(3 * _inputSize * _inputSize);

    // Fill entire tensor with gray (114/255)
    const grayVal = 114.0 / 255.0;
    for (int i = 0; i < input.length; i++) {
      input[i] = grayVal;
    }

    // Copy resized image pixels into padded position
    double sumR = 0, sumG = 0, sumB = 0;
    double maxVal = -1, minVal = 999;
    for (int y = 0; y < newH; y++) {
      for (int x = 0; x < newW; x++) {
        final pixel = resized.getPixel(x, y);
        final py = y + _padY;
        final px = x + _padX;
        
        final r = pixel.r / 255.0;
        final g = pixel.g / 255.0;
        final b = pixel.b / 255.0;
        
        sumR += r;
        sumG += g;
        sumB += b;
        
        if (r > maxVal) maxVal = r;
        if (r < minVal) minVal = r;

        input[0 * _inputSize * _inputSize + py * _inputSize + px] = r;
        input[1 * _inputSize * _inputSize + py * _inputSize + px] = g;
        input[2 * _inputSize * _inputSize + py * _inputSize + px] = b;
      }
    }

    final totalPixels = newW * newH;
    debugPrint('Tensor stats: min=${minVal.toStringAsFixed(3)} max=${maxVal.toStringAsFixed(3)} '
        'meanR=${(sumR / totalPixels).toStringAsFixed(3)} '
        'meanG=${(sumG / totalPixels).toStringAsFixed(3)} '
        'meanB=${(sumB / totalPixels).toStringAsFixed(3)}');

    return input;
  }

  ScanResult _postprocess(List<dynamic> flatOutput) {
    // Validate output length
    final expected = (4 + _numClasses) * _numDetections;
    if (flatOutput.length != expected) {
      debugPrint('ONNX output size mismatch: got ${flatOutput.length}, expected $expected');
      return _noDetection();
    }

    double bestConf = 0;
    double bestCx = 0, bestCy = 0, bestW = 0, bestH = 0;
    int bestClassIdx = 0;

    for (int i = 0; i < _numDetections; i++) {
      double maxClassProb = 0;
      int maxClassIdx = 0;

      for (int c = 0; c < _numClasses; c++) {
        final prob = (flatOutput[(4 + c) * _numDetections + i] as num).toDouble();
        if (prob > maxClassProb) {
          maxClassProb = prob;
          maxClassIdx = c;
        }
      }

      // Per-class confidence threshold (matching Python CLASS_CONF)
      final classThreshold = _classConfThresholds[maxClassIdx];
      if (maxClassProb < classThreshold) continue;

      // Get box coords to check area ratio
      final cx = (flatOutput[0 * _numDetections + i] as num).toDouble();
      final cy = (flatOutput[1 * _numDetections + i] as num).toDouble();
      final bw = (flatOutput[2 * _numDetections + i] as num).toDouble();
      final bh = (flatOutput[3 * _numDetections + i] as num).toDouble();

      // Area filter: skip boxes that are too big or too small
      final boxArea = bw * bh;
      final frameArea = _inputSize * _inputSize;
      final areaRatio = boxArea / frameArea;

      if (areaRatio > _maxAreaRatio || areaRatio < _minAreaRatio) continue;

      // Skip if box dimensions are invalid
      if (bw <= 0 || bh <= 0) continue;

      if (maxClassProb > bestConf) {
        bestConf = maxClassProb;
        bestCx = cx;
        bestCy = cy;
        bestW = bw;
        bestH = bh;
        bestClassIdx = maxClassIdx;
      }
    }

    if (bestConf == 0) {
      return _noDetection();
    }

    debugPrint('ONNX: ${_labelMap[bestClassIdx]} ${(bestConf * 100).toStringAsFixed(1)}% '
        'raw(cx=${bestCx.toStringAsFixed(1)}, cy=${bestCy.toStringAsFixed(1)}, '
        'w=${bestW.toStringAsFixed(1)}, h=${bestH.toStringAsFixed(1)}) '
        '${lastInferenceMs.toStringAsFixed(0)}ms');

    // Convert from letterbox pixel coords to normalized original image coords
    // 1. Remove letterbox padding
    final unpadCx = bestCx - _padX;
    final unpadCy = bestCy - _padY;
    // 2. Scale back to original image size and normalize to 0–1
    final scaledW = _origW * _scale;
    final scaledH = _origH * _scale;
    final normCx = unpadCx / scaledW;
    final normCy = unpadCy / scaledH;
    final normW = bestW / scaledW;
    final normH = bestH / scaledH;

    final xMin = (normCx - normW / 2).clamp(0.0, 1.0);
    final yMin = (normCy - normH / 2).clamp(0.0, 1.0);
    final xMax = (normCx + normW / 2).clamp(0.0, 1.0);
    final yMax = (normCy + normH / 2).clamp(0.0, 1.0);

    return ScanResult(
      label: _labelMap[bestClassIdx],
      confidence: bestConf,
      category: _categoryMap[bestClassIdx],
      timestamp: DateTime.now(),
      rect: Rect.fromLTRB(xMin, yMin, xMax, yMax),
    );
  }

  ScanResult _noDetection() {
    return ScanResult(
      label: 'Tidak terdeteksi',
      confidence: 0.0,
      category: WasteCategory.other,
      timestamp: DateTime.now(),
    );
  }
}
