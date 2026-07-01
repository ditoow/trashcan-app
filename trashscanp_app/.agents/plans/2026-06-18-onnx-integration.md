# ONNX Runtime YOLOv8 Integration

- **Spec:** `.agents/specs/2026-06-18-onnx-integration-design.md`
- **Dibuat:** 2026-06-18
- **Status:** Done

## Tasks

### Stage A: Upload Model ke Hugging Face

- [x] A1: Buat Python script upload model ke Hugging Face Hub
      — file: `scripts/upload_to_hf.py` — selesai kalau: model n/s/m terupload ke HF Hub dengan label map & README
- [x] A2: Jalankan script & verifikasi model ada di HF Hub
      — selesai kalau: model terverifikasi di huggingface.co/ditoow/trashscan8n

### Stage B: Persiapan Flutter

- [x] B1: Tambah dependency ke pubspec.yaml (onnxruntime, image, http)
      — file: `pubspec.yaml` — selesai kalau: `flutter pub get` sukses
- [x] B2: Update WasteCategory enum → 5 kelas (paper, plastic, metal, organic, other)
      — file: `lib/domain/models/waste_category.dart` — selesai kalau: enum punya 5 nilai + label + color
- [x] B3: Update ScanResult — tambah field imageBytes (opsional)
      — file: `lib/domain/models/scan_result.dart` — selesai kalau: model tetap kompatibel dengan existing code

### Stage C: Services Layer

- [x] C1: Buat ModelDownloaderService — download ONNX dari HF Hub, cache lokal
      — file: `lib/services/model_downloader_service.dart` — selesai kalau: download file .onnx ke path_provider & skip jika sudah ada
- [x] C2: Buat YoloPreProcessor — konversi image (Uint8List) → tensor float [1,3,640,640]
      — file: `lib/services/yolo_preprocessor.dart` — selesai kalau: output tensor shape & values sesuai YOLO input spec
- [x] C3: Buat YoloPostProcessor — decode output tensor → bounding boxes + NMS
      — file: `lib/services/yolo_post_processor.dart` — selesai kalau: output List dengan label, confidence, rect
- [x] C4: Buat OnnxClassifierService — gabung preprocessing → inference → postprocessing
      — file: `lib/services/onnx_classifier_service.dart` — selesai kalau: method classifyRaw → Future<ScanResult>

### Stage D: Provider Layer

- [x] D1: Update ScanProvider — ganti MockClassifierService → OnnxClassifierService
      — file: `lib/features/camera/providers/scan_provider.dart` — selesai kalau: provider pakai real model & download otomatis saat build
- [x] D2: Integrasi camera frame capture (startImageStream) → kirim ke classifier
      — file: `lib/features/camera/providers/scan_provider.dart` — selesai kalau: frame dari camera dikirim ke onnx setiap 2 detik

### Stage E: Verify

- [x] E1: Run `flutter analyze` — no new errors
- [x] E2: Run `flutter test` — existing tests pass
- [x] E3: Error-check skill — jalankan `.agents/skills/error-check/SKILL.md`

## Walkthrough

### Apa yang dibangun

Integrasi YOLOv8 ONNX ke TrashScan dengan pipeline lengkap:

1. **Upload model** — Python script upload 3 varian (n/s/m) ke Hugging Face Hub
2. **Model downloader** — download ONNX dari HF Hub, cache lokal di `path_provider`
3. **YOLO preprocessing** — konversi camera frame → tensor float [1,3,640,640]
4. **ONNX Runtime** — inferensi via `onnxruntime` Flutter package
5. **YOLO postprocessing** — decode output, NMS, bounding box
6. **Camera stream** — `startImageStream()` feed frame ke provider tiap 2 detik
7. **5 waste classes** — paper, plastic, metal, organic, other

### File utama

| File | Peran |
|---|---|
| `scripts/upload_to_hf.py` | Upload model ONNX ke HF Hub |
| `lib/services/onnx_classifier_service.dart` | Main classifier: download → infer → postprocess |
| `lib/services/model_downloader_service.dart` | Download & cache ONNX model |
| `lib/services/yolo_preprocessor.dart` | Camera frame → tensor |
| `lib/services/yolo_post_processor.dart` | Tensor → bounding boxes + NMS |
| `lib/domain/models/waste_category.dart` | 5 waste classes + warna |
| `lib/features/camera/providers/scan_provider.dart` | Riverpod state + camera frame integration |
| `lib/features/camera/camera_screen.dart` | Start/stop image stream |

### Cara test

1. Install di device: `flutter run`
2. App akan otomatis download model `trashscan8n` dari HF Hub (sekali di awal)
3. Arahkan kamera ke sampah — bounding box + label akan muncul
4. Ganti varian model: ubah base URL di `OnnxClassifierService` atau `ModelDownloaderService`

### Model di HF Hub

- `ditoow/trashscan8n` (nano, ~12MB) — default
- `ditoow/trashscan8s` (small, ~45MB)
- `ditoow/trashscan8m` (medium, ~104MB)

### Catatan

- Model di-download sekali & di-cache di `path_provider`
- Frame di-capture via `startImageStream`, di-throttle 2 detik
- YUV420 (Android) & BGRA8888 (iOS) handling untuk format camera frame

## Changelog

- 2026-06-18: Initial plan — all tasks completed
