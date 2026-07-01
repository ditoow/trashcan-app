# Tech Stack

| Layer | Technology | Version | Why |
|---|---|---|---|
| Language | Dart | ^3.11.4 | Flutter requirement |
| Framework | Flutter | stable (db50e20) | Cross-platform mobile |
| UI Kit | Cupertino | — | iOS-native look & feel |
| State Management | Riverpod | ^3.3.1 | Lightweight, testable, no BuildContext needed |
| Camera | `camera` | ^0.12.0+1 | Live preview + frame access |
| Permissions | `permission_handler` | ^12.0.3 | Runtime camera permission |
| Image Compression | `flutter_image_compress` | ^2.4.0 | (future use for captured frames) |
| Fonts | `google_fonts` | ^8.1.0 | Plus Jakarta Sans throughout |
| Linting | `flutter_lints` | ^6.0.0 | Via `analysis_options.yaml` |

## Architecture style

Layered monolith within a single Flutter app:
- **Domain layer** — pure Dart models (no Flutter dependency except `Cupertino` for Color/Rect)
- **Services layer** — stateless services (mock classifier, interface-ready for real ML)
- **Feature layer** — screens + Riverpod providers + widgets per feature
- **Shared layer** — theme constants + reusable widgets

## Changelog

- 2026-06-18: Initial analysis
