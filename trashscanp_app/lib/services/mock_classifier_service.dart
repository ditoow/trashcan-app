import 'dart:math';
import 'dart:ui';
import '../domain/models/waste_category.dart';
import '../domain/models/scan_result.dart';

class MockClassifierService {
  final _random = Random();

  final List<Map<String, dynamic>> _mockData = [
    {'label': 'Botol Plastik', 'category': WasteCategory.plastic},
    {'label': 'Daun Kering', 'category': WasteCategory.organic},
    {'label': 'Sisa Makanan', 'category': WasteCategory.organic},
    {'label': 'Kaleng Minuman', 'category': WasteCategory.metal},
    {'label': 'Kertas Koran', 'category': WasteCategory.paper},
    {'label': 'Kardus', 'category': WasteCategory.paper},
    {'label': 'Sendok Plastik', 'category': WasteCategory.plastic},
  ];

  Future<ScanResult> classify() async {
    // Simulasi delay proses
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(1000)));

    final data = _mockData[_random.nextInt(_mockData.length)];
    
    // Generate koordinat acak (normalisasi 0.0 - 1.0)
    // Kita buat di area tengah layar agar tidak terlalu ke pinggir
    final double width = 0.4 + (_random.nextDouble() * 0.3); // 40% - 70%
    final double height = 0.2 + (_random.nextDouble() * 0.2); // 20% - 40%
    final double left = 0.1 + (_random.nextDouble() * (1.0 - width - 0.2));
    final double top = 0.2 + (_random.nextDouble() * 0.3);

    return ScanResult(
      label: data['label'],
      confidence: 0.7 + (_random.nextDouble() * 0.28),
      category: data['category'],
      timestamp: DateTime.now(),
      rect: Rect.fromLTWH(left, top, width, height),
    );
  }
}
