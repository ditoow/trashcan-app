# TFLite YOLOv8 On-Device Integration

- **Status:** Approved
- **Dibuat:** 2026-06-29
- **Plan terkait:** `.agents/plans/2026-06-29-tflite-integration.md`

## Problem

TrashScan masih pake `HfInferenceService` (remote API ke HF Space). Butuh koneksi internet, latency tinggi (1-5s), ga bisa offline. Padahal udah ada model YOLOv8 4-class lokal (`best_deteksi_sampah_4kelas.pt`).

## Goals

1. Convert model .pt → TFLite (FP16/INT8) via Ultralytics
2. Ganti `HfInferenceService` → `TfliteClassifierService` on-device
3. Camera frame → TFLite inference → bounding box + label
4. Fallback — kalo TFLite gagal, pake HfInferenceService (remote)
5. Latency target: <200ms per inference di HP mid-range

## Non-goals

- Ga training ulang model
- Ga upload ke HF Hub (model lokal aja)
- Ga ganti UI layer (screen, widgets tetap)
- Ga support multi-variant (cukup 1 model)

## Design

### Layer flow

```
Camera Screen (startImageStream)
  └─ ScanProvider (Riverpod) — frame tiap ~2 detik
       └─ TfliteClassifierService
            ├─ Interpreter.load(model.tflite) — sekali di init
            ├─ preprocess: resize 640×640 → normalize → buffer
            ├─ run inference
            └─ postprocess: decode output → NMS → label + rect
```

### Mapping kelas

| Model idx | Model label | WasteCategory |
|---|---|---|
| 0 | plastik | plastic |
| 1 | kertas | paper |
| 2 | logam | metal |
| 3 | lainnya | other |

Organic (tidak ada di model 4-class) → masuk "lainnya" = other.

### Detail per layer

#### 1. Model conversion (Python)
- File: `scripts/convert_to_tflite.py`
- Load `.pt` → export TFLite FP16 via `model.export(format='tflite', half=True)`
- Simpan ke `assets/models/best.tflite`
- Juga export label map `labels.txt`

#### 2. Services — `lib/services/`
- **`tflite_classifier_service.dart`** — extends/extract dari existing service pattern
  - `init()`: load interpreter, allocate tensors
  - `classifyRaw(Uint8List) → ScanResult`: preprocess → inference → postprocess
  - Preprocess: decode JPEG → resize 640×640 → normalize [0,1] → [1,3,640,640]
  - Postprocess: parse [1,6,8400] output → sigmoid confidence → NMS → highest box
  - Uses `image` package utk resize + `tflite_flutter` utk inference

#### 3. Model asset
- `assets/models/best.tflite` — model TFLite
- `assets/models/labels.txt` — 4 baris label

#### 4. Provider — `lib/features/camera/providers/`
- Update `scan_provider.dart`: ganti `HfInferenceService` → `TfliteClassifierService`
- Init classifier di provider `build()`
- Frame camera stream → kirim ke classifier tiap ~2 detik

### New dependencies
- `tflite_flutter: ^0.10.0` — TFLite inference engine di Flutter
- `tflite_flutter_helper` — (opsional) preprocessing helper
- `image: ^4.5.3` — udah ada di pubspec

## Notes after implementation

- **TFLite → ONNX Runtime pivot.** macOS Python 3.14 tidak support TensorFlow/TFLite export. Pivot ke ONNX Runtime via `flutter_onnxruntime`.
- **Model:** YOLOv8s 4-class ONNX (43 MB). 5-class ONNX tersedia di HF Hub (`ditoow/trashscan8n`) untuk upgrade nanti.
- **Fallback:** TFLite → HF Inference Service. On-device ONNX gagal → remote API.
- `tflite_flutter` dependency dihapus, `flutter_onnxruntime` sebagai gantinya.
- `tflite_classifier_service.dart` dihapus (sudah diganti `onnx_classifier_service.dart`).

## Open questions

1. `tflite_flutter` — perlu compile native lib sendiri atau pake prebuilt?
2. YOLOv8 TFLite output format — perlu dicek shape actual setelah export (biasanya [1,6,8400] atau [1,84,8400])
3. Frame format — YUV420 dari camera perlu dikonversi ke RGB sebelum di-resize
4. Model size — FP16 ~11MB, acceptable buat asset bundle?
5. Fallback mechanism — kalo TFLite gagal init, fallback ke HfInferenceService?

## Changelog

- 2026-06-29: Initial draft — TFLite on-device integration
