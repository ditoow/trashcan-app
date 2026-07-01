# ONNX Runtime YOLOv8 Integration + Hugging Face Hub

- **Status:** Approved
- **Dibuat:** 2026-06-18
- **Plan terkait:** `.agents/plans/2026-06-18-onnx-integration.md` _(diisi setelah approved)_

## Problem

TrashScan masih pakai `MockClassifierService` yang hanya generate random label. Padahal sudah ada model YOLOv8 ONNX (n/s/m) dengan 5 kelas: `paper, plastic, metal, organic, other`. Model perlu diintegrasikan ke Flutter via ONNX Runtime on-device, dengan download dari Hugging Face Hub.

## Goals

1. Upload 3 varian model YOLOv8 (n/s/m) ke Hugging Face Hub
2. Flutter bisa download model ONNX dari Hugging Face Hub
3. Inferensi ONNX Runtime di device (iOS/Android) — real detection
4. Update WasteCategory & ScanResult dari 4 kelas lama → 5 kelas baru
5. Ganti MockClassifierService → OnnxClassifierService
6. Bounding box dari real detection, bukan random
7. Keep UI layer tetap sama (screens & widgets tidak perlu diubah)

## Non-goals

- Tidak deploy backend/server — semua on-device
- Tidak training ulang model
- Tidak handle PyTorch (.pt) — hanya ONNX
- Tidak perlu streaming camera frame real-time (cukup capture frame tiap 2 detik, sama seperti sekarang)

## Design

### Layer flow

```
Camera Screen
  └─ ScanProvider (Riverpod Notifier) — update state dengan real result
       └─ OnnxClassifierService
            ├─ ModelDownloader — download ONNX dari Hugging Face Hub (sekali, cached)
            ├─ OnnxRuntime — load & run inference
            └─ YoloPostProcessor — decode output → bounding box + class
```

### Detail per layer

#### 1. Hugging Face Upload (Python script)
- Script Python: `scripts/upload_to_hf.py`
- Upload `best.onnx` + `deployment_info.json` dari setiap varian ke Hugging Face Hub
- Repo di HF: `{username}/trashscan-yolov8-{variant}`
- Sertakan README.md, label map

#### 2. Services Layer — `lib/services/`
- **`onnx_classifier_service.dart`** — implements `ClassifierService` interface
  - accepts `Uint8List` image bytes
  - runs preprocess (resize 640×640, normalize)
  - runs ONNX inference
  - runs postprocess (NMS, decode boxes)
  - returns `ScanResult`
- **`model_downloader_service.dart`** — download ONNX from Hugging Face Hub
  - download ke `path_provider` app directory
  - cache check (skip if already downloaded)
  - progress callback
- **`yolo_post_processor.dart`** — YOLOv8 output parsing
  - decode raw tensor → bounding boxes
  - Non-Maximum Suppression (NMS)
  - map class indices → label strings

#### 3. Domain Layer — `lib/domain/models/`
- **`waste_category.dart`** — tambah `paper`, `plastic`, `metal`, `other`
  - hapus `inorganic`, `b3`, `unknown`
  - update `.label` dan `.color` untuk kelas baru
- **`scan_result.dart`** — tambah field `imageBytes` (optional, untuk display)

#### 4. Provider Layer — `lib/features/camera/providers/`
- **`scan_provider.dart`** — ganti `MockClassifierService` → `OnnxClassifierService`
  - inject `modelDownloaderService` untuk download model saat build()
  - sama seperti sebelumnya: timer tiap 2 detik

#### 5. New Dependencies (perlu approve)
- `onnxruntime` — ONNX inference engine
- `huggingface_hub` (Dart) — atau HTTP biasa untuk download
- `image` — untuk preprocessing gambar (resize, normalize)
- `path_provider` — sudah ada

### Mapping Kelas

| Model Output (0-4) | Label Baru | Warna |
|---|---|---|
| 0 | paper | #FFD60A (kuning) |
| 1 | plastic | #0A84FF (biru) |
| 2 | metal | #FF9F0A (oranye) |
| 3 | organic | #34D058 (hijau) |
| 4 | other | #98989D (abu) |

### Model Variants

| Varian | Ukuran | Akurasi | Use case |
|---|---|---|---|
| n (nano) | ~6 MB | Terendah | Default, cepat |
| s (small) | ~20 MB | Medium | Opsional |
| m (medium) | ~50 MB | Tertinggi | Butuh performa |

User bisa pilih varian di settings (future), default nano.

## Open questions

1. Package `onnxruntime` di Flutter — apakah stable di iOS & Android? Perlu riset.
2. Download progress feedback — perlu indikator ke user?
3. Frame capture — bagaimana capture frame dari camera preview utk dikirim ke ONNX?
   — pakai `CameraController.takePicture()` atau `startImageStream()`?
4. Fallback jika model belum terdownload — pakai mock sementara?

## Changelog

- 2026-06-18: Initial draft setelah diskusi dengan user — ONNX Runtime + HF Hub + 5 kelas baru
