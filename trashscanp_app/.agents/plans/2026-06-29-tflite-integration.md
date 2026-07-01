# TFLite YOLOv8 On-Device Integration

- **Spec:** `.agents/specs/2026-06-29-tflite-integration-design.md`
- **Dibuat:** 2026-06-29
- **Status:** Done

## Tasks

- [x] A1: Model Conversion — convert .pt → ONNX via Ultralytics (TFLite blocked by macOS Python 3.14)
- [x] B1: Pubspec + Assets — add flutter_onnxruntime, register assets, labels.txt
- [x] B2: OnnxClassifierService — core service: preprocess, ONNX inference, postprocess
- [x] B3: Provider update — scan_provider ganti HF → OnnxClassifierService + fallback
- [x] C1: Error check — flutter analyze: 0 issues ✅

## Walkthrough

### Apa yang dibangun

Integrasi YOLOv8 ONNX on-device ke TrashScan dengan fallback ke HF Inference API.

### Arsitektur

```
Camera frame (startImageStream)
  └─ ScanProvider (Riverpod Notifier)
       └─ OnnxClassifierService (on-device ONNX Runtime)
            ├─ init: OrtSession dari assets/models/best.onnx
            ├─ detect(): preprocess (resize 640, normalize) → session.run → postprocess (argmax, NMS)
            └─ return ScanResult (label, confidence, category, rect)
       └─ Fallback: HfInferenceService (kalo ONNX gagal init)
```

### File utama

| File | Peran |
|---|---|
| `assets/models/best.onnx` | YOLOv8s 4-class ONNX model (43 MB) |
| `assets/models/labels.txt` | 4 label: plastik, kertas, logam, lainnya |
| `lib/services/onnx_classifier_service.dart` | ONNX Runtime service: init, preprocess, inference, postprocess |
| `lib/features/camera/providers/scan_provider.dart` | Provider + fallback logic |
| `android/app/build.gradle.kts` | minSdk=26, aaptOptions noCompress tflite |
| `android/app/proguard-rules.pro` | Keep rule untuk onnxruntime |
| `ios/Podfile` | platform 16.0, static linkage |
| `ios/Flutter/Release.xcconfig` | STRIP_STYLE = non-global |

### Flow

1. App start → ScanProvider.build() → _initService()
2. Coba init OnnxClassifierService → kalo berhasil, pake on-device
3. Kalo gagal → fallback ke HfInferenceService (remote)
4. Timer tiap 2 detik → capture frame → detect() → update state
5. Model 4-class: plastik (0), kertas (1), logam (2), lainnya (3)
6. Mapping ke WasteCategory: plastic, paper, metal, other

### Mapping kelas

| Model | WasteCategory | Label |
|---|---|---|
| 0 plastik | plastic | Plastik |
| 1 kertas | paper | Kertas |
| 2 logam | metal | Logam |
| 3 lainnya | other | Lainnya |

### Catatan

- TFLite gagal konversi karena macOS Python 3.14 gak support TensorFlow export
- Pivot ke ONNX Runtime — model ONNX udah ready
- Kalo mau TFLite di masa depan, convert di Linux/Colab, copy .tflite ke assets/models/, dan service tinggal ganti backend

## Changelog

- 2026-06-29: Initial plan
- 2026-06-29: Updated — pivot ONNX Runtime (TFLite blocked), 0 analyze issues ✅
