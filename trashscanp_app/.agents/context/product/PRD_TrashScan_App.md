# 📄 Product Requirements Document (PRD)
## TrashScan — Aplikasi Klasifikasi Sampah Realtime
**Version:** 1.1.0 (Revisi: Upload → Realtime Camera)
**Platform:** Flutter (Android & iOS)
**Status:** Draft
**Last Updated:** Juni 2026

---

## 1. Overview

### 1.1 Latar Belakang
Masyarakat umum sering tidak tahu cara memilah sampah. TrashScan menggunakan kamera realtime untuk mengklasifikasikan sampah secara otomatis — cukup arahkan kamera ke sampah, dan hasil klasifikasi muncul langsung di layar tanpa perlu foto manual.

### 1.2 Tujuan Produk
- Klasifikasi sampah secara realtime via live camera feed
- Hasil muncul otomatis setiap X detik tanpa interaksi user
- Ringan, cepat, dan bisa dipakai semua kalangan

### 1.3 Target Pengguna
**Primer:** Masyarakat umum semua usia
**Sekunder:** Komunitas peduli lingkungan, relawan bank sampah

---

## 2. Scope

### ✅ In Scope (MVP)
- Live camera feed menggunakan `camera` package Flutter
- Frame capture otomatis setiap interval (default: 2 detik)
- Kirim frame ke Hugging Face Inference API untuk klasifikasi
- Overlay hasil klasifikasi langsung di atas live camera (label + kategori + confidence)
- Tombol pause/resume scanning
- UI ramah semua usia

### ❌ Out of Scope (v1.0)
- Upload dari galeri
- Login / akun pengguna
- Riwayat scan
- Lokasi tempat buang sampah (GPS)
- Mode offline / on-device inference
- Adjustable interval oleh user (hardcoded di v1)

---

## 3. User Stories

| ID | Sebagai... | Saya ingin... | Supaya... |
|----|-----------|----------------|-----------|
| US-01 | Pengguna | Buka app dan langsung lihat kamera aktif | Tidak perlu tombol apapun untuk mulai |
| US-02 | Pengguna | Arahkan kamera ke sampah dan hasil muncul otomatis | Tidak perlu tap "scan" berulang |
| US-03 | Pengguna | Melihat label & kategori langsung di overlay kamera | Tahu jenis sampah saat kamera masih aktif |
| US-04 | Pengguna | Pause scanning saat mau baca info lebih lanjut | Overlay tidak berganti-ganti saat baca |
| US-05 | Pengguna | Tap hasil untuk buka detail edukasi | Tahu cara buang/daur ulang yang benar |
| US-06 | Pengguna | App tidak panas atau boros baterai berlebihan | Tetap nyaman dipakai lama |

---

## 4. Functional Requirements

### 4.1 Camera Screen (Screen Utama)
- Kamera aktif otomatis saat screen dibuka (izin diminta di awal)
- Live preview fullscreen atau 16:9
- **Frame capture loop:** setiap 2 detik, ambil frame → compress → kirim ke API
- Jika API masih dalam proses (request sebelumnya belum selesai), skip frame — tidak queue
- Tombol **Pause / Resume** untuk hentikan loop sementara
- UI reaktif terhadap perubahan state scan

### 4.2 Result Overlay (di atas live camera)
- **Label utama** hasil klasifikasi (contoh: "Botol Plastik")
- **Kategori chip** (Organik / Anorganik / B3) dengan warna berbeda
- **Confidence bar** horizontal di bawah label
- Overlay tetap tampil selama kamera aktif; update setiap kali response baru tiba
- Saat loading (menunggu response): tampilkan indikator kecil (spinner atau pulse), hasil lama tetap tampil
- Saat belum ada hasil sama sekali: tampilkan "Arahkan kamera ke sampah..."

### 4.3 (Hapus - Fitur Edukasi Dihilangkan)
- Fokus pada klasifikasi cepat dan realtime.

### 4.4 Permission Handling
- Minta izin kamera saat pertama buka
- Jika ditolak: tampilkan screen khusus dengan tombol "Buka Pengaturan"
- Tidak ada fallback galeri

### 4.5 Integrasi Hugging Face API
- Endpoint: `POST https://api-inference.huggingface.co/models/{MODEL_NAME}`
- Body: raw bytes hasil capture frame (compressed < 300KB)
- Response: array label + score → ambil score tertinggi
- Timeout per request: 5 detik
- Jika timeout/error: skip, tunggu interval berikutnya (tidak retry langsung)
- Jika 503 (model cold start): hentikan loop sementara, tampilkan "Model sedang dimuat...", retry setelah estimated_time

---

## 5. Non-Functional Requirements

| Aspek | Target |
|-------|--------|
| **Ukuran App** | < 30 MB (release APK) |
| **Interval Scan** | Default 2 detik (bisa diubah di config) |
| **Compress Target** | < 300KB per frame sebelum upload |
| **API Response** | Target < 3 detik (jaringan 4G normal) |
| **Minimum OS** | Android 6.0 (API 23) / iOS 13 |
| **RAM Usage** | < 200 MB saat kamera aktif |
| **Baterai** | Loop pause otomatis saat app di background |
| **Aksesibilitas** | Font min 14sp, kontras tinggi, tombol min 48dp |

---

## 6. Tech Stack

| Layer | Teknologi |
|-------|-----------|
| **Framework** | Flutter (Dart) |
| **State Management** | Provider atau Riverpod |
| **Camera** | `camera` package (bukan image_picker) |
| **HTTP Client** | `http` atau `dio` |
| **Image Compress** | `flutter_image_compress` |
| **Env Config** | `flutter_dotenv` |
| **Permissions** | `permission_handler` |
| **AI Backend** | Hugging Face Inference API (model TBD) |

---

## 7. Interval & Throttling Logic

```
Loop aktif → ambil frame → sedang request? → YA: skip frame ini
                                            → TIDAK: compress → POST → update overlay
         ↑___________________________________|
                    tunggu 2 detik
```

- Loop berjalan di `Timer.periodic(Duration(seconds: 2), ...)`
- Flag `_isRequesting` bool mencegah request tumpang tindih
- Saat app di background: `WidgetsBindingObserver` pause loop otomatis
- Saat kembali foreground: resume loop

---

## 8. Risiko & Mitigasi

| Risiko | Mitigasi |
|--------|---------|
| HF API lambat (> 2 detik) | Skip request jika masih pending, hasil lama tetap tampil |
| Model cold start (503) | Pause loop, tampilkan pesan, retry setelah estimated_time |
| Kamera panas / boros baterai | Compress agresif, pause di background, interval tidak terlalu cepat |
| Rate limit HF free tier | Interval 2 detik sudah cukup moderat; pertimbangkan paid tier jika demo intensif |
| Izin kamera ditolak | Dedicated permission screen dengan penjelasan ramah |

---

## 9. Milestone & Timeline (Estimasi)

| Sprint | Deliverable |
|--------|-------------|
| Sprint 1 | Setup project, camera package, permission handling, live preview fullscreen |
| Sprint 2 | Frame capture loop, compress, integrasi HF API, parsing response |
| Sprint 3 | Result overlay UI, confidence bar animasi, pause/resume |
| Sprint 4 | Education bottom sheet, error states, polish UI, test device |

---

## 10. Open Questions

- [ ] Model HuggingFace mana? (ditentukan rekan)
- [ ] Label set dari model → untuk mapping kategori
- [ ] Interval 2 detik cukup atau perlu dikurangi/ditambah?
- [ ] Perlu backend proxy untuk sembunyikan API key di production?
- [ ] HF free tier cukup untuk demo intensif?
