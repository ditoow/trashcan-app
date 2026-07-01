# 🛠️ Design Spec: TrashScan Lightweight MVP
**Date:** 2026-06-08
**Topic:** Realtime Camera MVP without API Integration
**Status:** Validated & Approved

---

## 1. Overview
TrashScan adalah aplikasi klasifikasi sampah otomatis. Spec ini mencakup pengembangan MVP (Minimum Viable Product) yang berfokus pada pengalaman kamera realtime, UI yang ringan, dan performa tinggi tanpa integrasi API eksternal pada tahap awal.

### 1.1 Goal
- Mengubah template counter Flutter menjadi aplikasi TrashScan yang fungsional secara lokal.
- Memberikan pengalaman deteksi otomatis (realtime) yang disimulasikan melalui mock classifier.
- Memastikan aplikasi ringan, cepat dibuka, dan hemat resource (baterai/RAM).

---

## 2. Architecture & Tech Stack

### 2.1 Core Components
- **Framework:** Flutter (Dart)
- **State Management:** Provider/Riverpod (akan diputuskan saat planning, fokus ke reactivity ringan).
- **Camera:** `camera` package untuk live preview dan frame source.
- **Permissions:** `permission_handler`.
- **Theme:** Custom theme berbasis purple/glassmorphism (optimized).

### 2.2 Project Structure
```
lib/
├── domain/models/       # Model: ScanResult, WasteCategory, ScanStatus
├── services/            # Service: MockClassifierService (Interface-ready)
├── features/
│   ├── camera/          # Screen utama, overlay, scan loop
│   └── permission/      # Handling jika kamera ditolak
└── shared/
    ├── theme/           # Warna & typography (AppColors, AppTextStyles)
    └── widgets/         # GlassCard ringan, StatusPill, buttons
```

---

## 3. Realtime Detection Flow (Simulation)

App berjalan secara otomatis (realtime camera) tanpa tombol scan manual.

### 3.1 Detection Loop
1. **Camera Ready:** Loop dimulai otomatis setelah inisialisasi kamera selesai.
2. **Periodic Tick:** Setiap 2 detik, sistem memicu "analisis".
3. **Throttling:** Jika analisis sebelumnya belum selesai, tick baru dilewati (skip).
4. **Mock Analysis:** Memanggil `MockClassifierService` yang mensimulasikan delay ringan (500ms - 1s) dan mengembalikan label acak (Botol Plastik, Daun, Masker Bekas, dll).
5. **UI Update:** Overlay diperbarui dengan hasil terbaru secara reaktif.
6. **Background Policy:** Loop berhenti saat app di background dan lanjut saat foreground.

---

## 4. UI Design Strategy (Lightweight)

Mengikuti `.agents/artifact/app-design.md` dengan optimasi performa:
- **Glassmorphism:** Digunakan hanya pada panel hasil (bottom) dan pill status (top).
- **Blur Efficiency:** Sigma blur dibatasi (max 10-15) untuk menjaga frame rate kamera tetap stabil di device menengah.
- **Assets:** Tidak ada aset gambar besar; ikon menggunakan material icons atau SVG ringan.
- **Zero-Block Preview:** Pemrosesan (mock) dilakukan di isolate/background task (jika berat) agar preview kamera tetap lancar.

---

## 5. Backlog (Implementation Plan)

### M0: Project Foundation
- Setup folder structure & dependencies.
- Implementasi `AppColors` & `AppTextStyles` (Purple theme).
- Setup models: `WasteCategory` (Enum), `ScanResult`, `ScanStatus`.

### M1: Camera & Permission
- Implementasi `PermissionScreen` & logic cek izin.
- Implementasi `CameraScreen` dengan live preview fullscreen.
- Lifecycle management (init/dispose controller).

### M2: Scan Loop & Mock Logic
- Implementasi `MockClassifierService`.
- Implementasi `Timer.periodic` loop di dalam `CameraScreen`.
- Logic pause/resume dan throttling.

### M3: Result Overlay & Interaction
- Build `ResultOverlay` (Glass panel di bawah).
- Build `StatusPill` (Indikator scanning/paused).
- Build `ConfidenceBar` (Animasi progress sederhana).
- Implementasi tombol pause/resume manual.

### M4: Performance & Walkthrough
- Optimasi rebuild (RepaintBoundary).
- Verifikasi startup time.
- Pembuatan Walkthrough Guide.

---

## 6. Walkthrough (How to Demo)

1. **Start:** Buka aplikasi, setujui izin kamera.
2. **Observe:** Lihat preview kamera aktif. Perhatikan pill status di pojok kiri bertuliskan "Scanning...".
3. **Scan:** Arahkan kamera. Lihat overlay di bawah akan update otomatis setiap beberapa detik dengan hasil deteksi simulasi.
4. **Interact:** Tap tombol Pause untuk mengunci hasil. Tap Resume untuk lanjut deteksi.
5. **Lifecycle:** Coba pindah app ke background dan kembali; pastikan loop dan kamera tetap stabil.

---

## 7. Self-Review & Hard-Gate
- **API Integration:** Dikeluarkan dari spec ini.
- **Code Generation:** Dilarang dilakukan sebelum konfirmasi eksplisit dari user per-fitur.
- **Complexity:** Spec ini dirancang untuk diimplementasikan dalam 1-2 sesi kerja intensif.

---
**Approved by User:** [Pending Review]
