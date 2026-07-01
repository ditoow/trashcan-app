# Project Summary: TrashScan

**TrashScan** adalah aplikasi Flutter mobile untuk klasifikasi sampah otomatis via kamera real-time. Saat ini dalam tahap MVP dengan mock classifier (belum integrasi ML sungguhan).

## What it does

- Menampilkan preview kamera real-time
- Mensimulasikan deteksi sampah setiap 2 detik via `MockClassifierService`
- Mengkategorikan sampah: Organic, Inorganic, B3 (hazardous), Unknown
- Menampilkan bounding box, confidence bar, dan status pill
- Mendukung pause/resume scan
- UI gelap dengan tema purple glassmorphism (Cupertino-style)

## Entry point

`lib/main.dart:9` — `ProviderScope` wraps `TrashScanApp`, root navigation berdasarkan status permission kamera.

## Key files

| File | Role |
|---|---|
| `lib/main.dart` | Entry point, CupertinoApp, routing permission → camera |
| `lib/domain/models/` | ScanResult, WasteCategory, ScanStatus |
| `lib/services/mock_classifier_service.dart` | Mock ML classifier (random label setiap 0.5-1.5s) |
| `lib/features/camera/` | Camera screen, providers, widgets overlay |
| `lib/features/permission/` | Permission request screen + provider |
| `lib/shared/theme/` | AppColors + AppTextStyles (Plus Jakarta Sans) |
| `lib/shared/widgets/glass_card.dart` | Reusable glassmorphism container |

## Changelog

- 2026-06-18: Initial analysis — greenfield Flutter app, 16 Dart files, mock classifier active
