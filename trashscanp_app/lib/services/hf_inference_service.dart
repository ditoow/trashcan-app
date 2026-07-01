import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../domain/models/scan_result.dart';
import '../domain/models/waste_category.dart';

class HfInferenceService {
  final String apiUrl;
  final String apiToken;
  bool _initialized = false;

  HfInferenceService({
    this.apiUrl = 'https://pgxh-yolov26-ml.hf.space/detect',
    this.apiToken = '',
  });

  Future<void> initialize() async {
    _initialized = true;
  }

  void dispose() {
    // No resources to dispose for HTTP client service
  }

  Future<ScanResult> detect(Uint8List jpegBytes) async {
    if (!_initialized) await initialize();

    debugPrint('HF API: sending ${jpegBytes.length} bytes to $apiUrl');

    final headers = <String, String>{
      'Content-Type': 'application/octet-stream',
    };
    if (apiToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $apiToken';
    }

    final client = http.Client();
    final start = DateTime.now();
    late http.Response response;
    try {
      response = await client
          .post(Uri.parse(apiUrl), headers: headers, body: jpegBytes)
          .timeout(const Duration(seconds: 30));
    } finally {
      client.close();
    }
    final ms = DateTime.now().difference(start).inMilliseconds;
    debugPrint(
      'HF API: ${response.statusCode} in ${ms}ms, ${response.body.length} chars',
    );

    if (response.statusCode != 200) {
      throw Exception('API error: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    debugPrint('HF API: ${data.length} detections');

    if (data.isEmpty) {
      return ScanResult(
        label: 'Tidak terdeteksi',
        confidence: 0.0,
        category: WasteCategory.other,
        timestamp: DateTime.now(),
      );
    }

    final best = data
        .map(
          (d) => _Detection(
            label: d['label'] as String,
            confidence: (d['score'] as num).toDouble(),
            xMin: (d['xmin'] as num).toDouble(),
            yMin: (d['ymin'] as num).toDouble(),
            xMax: (d['xmax'] as num).toDouble(),
            yMax: (d['ymax'] as num).toDouble(),
          ),
        )
        .reduce((a, b) => a.confidence > b.confidence ? a : b);

    final category = _labelToCategory[best.label] ?? WasteCategory.other;
    final label = _labelMap[best.label] ?? best.label;

    return ScanResult(
      label: label,
      confidence: best.confidence,
      category: category,
      timestamp: DateTime.now(),
      rect: Rect.fromLTRB(best.xMin, best.yMin, best.xMax, best.yMax),
    );
  }

  static const Map<String, WasteCategory> _labelToCategory = {
    'paper': WasteCategory.paper,
    'plastic': WasteCategory.plastic,
    'metal': WasteCategory.metal,
    'organic': WasteCategory.organic,
    'other': WasteCategory.other,
  };

  static const Map<String, String> _labelMap = {
    'paper': 'Kertas',
    'plastic': 'Plastik',
    'metal': 'Logam',
    'organic': 'Organik',
    'other': 'Lainnya',
  };
}

class _Detection {
  final String label;
  final double confidence;
  final double xMin, yMin, xMax, yMax;

  _Detection({
    required this.label,
    required this.confidence,
    required this.xMin,
    required this.yMin,
    required this.xMax,
    required this.yMax,
  });
}
