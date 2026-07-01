# 10-gaps-and-recommendations

> **Status: populated** — initial analysis 2026-06-18.

## Gaps

### 1. Widget test masih template counter [FIXED]
- **File:** `test/widget_test.dart`
- **Apa:** Test sekarang verifikasi `CameraScreen` / `PermissionScreen` dengan teks 'Izin Kamera Diperlukan' — sesuai TrashScanApp

### 2. Belum ada unit test untuk provider
- **Area:** `lib/features/camera/providers/scan_provider.dart`, `lib/features/permission/permission_provider.dart`
- **Apa:** Tidak ada test untuk state transition (scanning → loading → scanning, pause/resume, error handling)
- **Kenapa penting:** Provider adalah core logic — tanpa test, refactor rentan regression

### 3. `flutter_image_compress` dan `path_provider` tidak terpakai
- **File:** `pubspec.yaml:40-41`
- **Apa:** Dua dependency di-install tapi zero usage di kode
- **Kenapa penting:** Bloat — tambah ukuran bundle + attack surface, hapus jika tidak segera dipakai

### 4. Belum ada error state UI untuk camera init failure
- **File:** `lib/features/camera/camera_screen.dart:47-49`
- **Apa:** Saat kamera gagal init, hanya `debugPrint` — user lihat loading spinner terus
- **Kenapa penting:** Poor UX — user tidak tahu kenapa kamera tidak muncul

### 5. Education feature directory kosong
- **File:** `lib/features/education/`
- **Apa:** Direktori ada tapi tidak ada file satupun
- **Kenapa penting:** Tidak masalah sekarang, tapi kalau tidak akan dipakai segera, hapus atau tambah README

### 6. Belum ada error boundary untuk Riverpod
- **Area:** Seluruh app
- **Apa:** Tidak ada global error handler untuk provider crashes
- **Kenapa penting:** Provider crash bisa mengakibatkan blank screen tanpa feedback

## Recommendations

1. Fix widget test sesegera mungkin (prioritas rendah tapi cepat)
2. Tambah unit test untuk `ScanNotifier` — test state machine transitions
3. Hapus `flutter_image_compress` dan `path_provider` dari pubspec jika tidak dipakai dalam 2 sprint
4. Tambah UI error state untuk kamera — `CameraScreen` harus kasih tahu user kalau init gagal
5. Pertimbangkan `ProviderScope.overrides` untuk inject mock service di test

## Changelog

- 2026-06-18: Initial analysis — 6 gaps identified
- 2026-06-18: Gap #1 (widget test) fixed; gap #7 (camera preview aspek rasio) added + resolved di decisions.md
