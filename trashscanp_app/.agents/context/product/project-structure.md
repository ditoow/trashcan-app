# 📁 Project Structure
## TrashScan — Flutter App (Realtime Camera)
**v1.1.0** — Revisi: Upload → Realtime Camera

```
trash_scan/
├── 00-overview/
│   ├── PRD_TrashScan_App.md              # Product Requirements Document
│   ├── app-design.md                     # Design system & UI spec
│   └── flow.html                         # App flow & component list visual
│
├── 01-architecture/
│   ├── architecture.md                   # Provider + Service layer + Camera lifecycle
│   ├── capture_loop_flow.md              # Diagram throttle logic Timer.periodic
│   └── decision_log.md                   # Catatan keputusan teknis
│
├── 02-domain/
│   ├── models/
│   │   ├── scan_result.dart              # Model hasil klasifikasi per frame
│   │   ├── hf_prediction.dart            # Model response HuggingFace
│   │   ├── waste_category.dart           # Enum: organic/inorganic/b3/unknown
│   │   └── scan_status.dart             # Enum: scanning/loading/paused/error/coldStart
│   └── utils/
│       └── waste_category_mapper.dart    # Mapping label API → kategori + nama Indonesia
│
├── 03-infrastructure/
│   ├── services/
│   │   └── huggingface_service.dart      # HTTP POST frame bytes ke HF Inference API
│   └── config/
│       └── app_config.dart               # Env loader: token, model name, interval
│
├── 04-delivery/
│   ├── features/
│   │   ├── splash/
│   │   │   └── splash_screen.dart        # Logo + auto-redirect
│   │   │
│   │   ├── onboarding/
│   │   │   ├── onboarding_screen.dart    # PageView 2 slide
│   │   │   └── widgets/
│   │   │       └── onboarding_page.dart  # Widget per slide
│   │   │
│   │   ├── permission/
│   │   │   ├── permission_screen.dart    # Request kamera + handle denied
│   │   │   └── widgets/
│   │   │       └── permission_denied_view.dart  # UI jika izin ditolak
│   │   │
│   │   ├── camera/                       # ← Screen utama
│   │   │   ├── camera_screen.dart        # CameraController + Timer.periodic loop
│   │   │   ├── providers/
│   │   │   │   └── scan_provider.dart    # State: result, status, error
│   │   │   └── widgets/
│   │   │       ├── result_overlay.dart   # Overlay transparan di atas preview
│   │   │       ├── confidence_bar.dart   # Animated progress bar
│   │   │       ├── pause_resume_button.dart  # FAB toggle pause/play
│   │   │       ├── status_indicator.dart # Dot animasi scanning/loading/error
│   │   │       └── education_bottom_sheet.dart  # Modal edukasi + pause loop
│   │   │
│   │   └── about/
│   │       └── about_screen.dart         # Info app, disclaimer, kredit model
│   │
│   └── shared/
│       └── widgets/
│           └── error_snackbar.dart       # Snackbar error standar
│
├── 05-shared/
│   └── theme/
│       ├── app_colors.dart               # Semua konstanta warna + overlay colors
│       ├── app_text_styles.dart          # Text styles + overlay-specific styles
│       ├── app_spacing.dart              # Spacing & border radius
│       └── app_theme.dart               # ThemeData utama
│
├── 06-api/
│   ├── api_contract.md                   # Dokumentasi endpoint, body, response
│   ├── sample_response.json              # Contoh response sukses + 503
│   └── error_handling.md                 # Mapping error: timeout, 503, no-internet
│
├── 07-assets/
│   ├── images/
│   │   ├── logo.png
│   │   └── onboarding/
│   │       ├── slide_1.png               # Ilustrasi "arahkan kamera"
│   │       └── slide_2.png               # Ilustrasi "lihat hasilnya"
│   └── icons/
│       └── app_icon.png
│
├── 08-testing/
│   ├── unit/
│   │   ├── waste_category_mapper_test.dart
│   │   ├── huggingface_service_test.dart
│   │   └── scan_provider_test.dart
│   └── widget/
│       ├── camera_screen_test.dart
│       └── result_overlay_test.dart
│
├── 09-devops/
│   ├── .env.example                      # Template env tanpa token asli
│   ├── .gitignore                        # Pastikan .env masuk sini
│   ├── build_android.sh                  # Script build release APK
│   └── README.md                         # Setup & run instructions
│
└── 10-gaps-and-recommendations/
    ├── known_issues.md                   # Bug & limitasi yang diketahui
    ├── future_features.md                # Fitur v2: riwayat, GPS, offline model
    └── model_integration_notes.md        # Catatan untuk rekan model HF
```

---

## Catatan Folder

| Folder | Isi | Perubahan dari v1.0 |
|--------|-----|---------------------|
| `00-overview` | Dokumen perencanaan & desain | — |
| `01-architecture` | Arsitektur + capture loop diagram | + capture_loop_flow.md |
| `02-domain` | Model & business logic murni | + scan_status.dart |
| `03-infrastructure` | API & env config | Interval config ditambah |
| `04-delivery` | UI layer — screens, widgets, providers | **Besar berubah:** `scan/` → `camera/`, hapus image_preview & galeri, tambah permission screen |
| `05-shared` | Design system | + overlay colors |
| `06-api` | Dokumentasi kontrak API | + error_handling.md |
| `07-assets` | Aset statis | Ilustrasi onboarding disesuaikan |
| `08-testing` | Unit & widget test | — |
| `09-devops` | Build & env | — |
| `10-gaps-and-recommendations` | Living doc | — |

---

## File Kritis

```
.env                          → ⚠️ JANGAN commit (ada di .gitignore)
waste_category_mapper.dart    → Update mapping tiap label model berubah
app_config.dart               → Satu-satunya tempat baca env vars
camera_screen.dart            → Core: lifecycle kamera + timer loop
```

---

## Perubahan Besar v1.0 → v1.1

| Aspek | v1.0 (Upload) | v1.1 (Realtime Camera) |
|-------|--------------|----------------------|
| Package kamera | `image_picker` | `camera` |
| Permission | Otomatis oleh image_picker | Manual via `permission_handler` |
| Screen utama | HomeScreen (pilih gambar) | CameraScreen (live preview) |
| Trigger analisis | Tap tombol "Analisis" | Timer.periodic otomatis |
| State flow | Linear: pilih → analisis → result screen | Loop: capture → analisis → update overlay |
| Error handling | Dialog full-screen | Snackbar + overlay update |
| Galeri | Ada | Dihapus |
| Model baru | ScanResult | + ScanStatus enum |

---

## Konvensi Penamaan

| Tipe | Format | Contoh |
|------|--------|--------|
| File Dart | snake_case | `camera_screen.dart` |
| Class | PascalCase | `CameraScreen` |
| Variable | camelCase | `_isRequesting` |
| Private field | _camelCase | `_captureTimer` |
| Asset | snake_case | `slide_1.png` |
| Test file | `*_test.dart` | `camera_screen_test.dart` |
