# 🚶 Walkthrough TrashScan MVP (Mock Version)

Aplikasi ini didesain untuk dijalankan langsung tanpa setup API key pada tahap awal.

## 1. Startup & Permission
- Saat pertama kali dijalankan, aplikasi akan mengecek izin kamera.
- Jika izin belum diberikan, Anda akan melihat layar permintaan izin.
- Klik "Beri Izin" untuk melanjutkan ke layar kamera.

## 2. Realtime Detection
- Setelah masuk ke layar utama, kamera akan aktif secara otomatis.
- Di pojok kiri atas, Anda akan melihat status "Scanning..." dengan animasi pulse.
- Setiap 2 detik, aplikasi akan melakukan simulasi deteksi otomatis.
- Panel di bagian bawah akan terupdate dengan:
  - **Nama Sampah:** (Contoh: Botol Plastik)
  - **Kategori:** (Organic/Inorganic/B3 dengan warna yang sesuai)
  - **Confidence:** Bar animasi yang menunjukkan tingkat keyakinan simulasi.

## 3. Interaction
- **Pause/Resume:** Ketuk tombol di pojok kanan atas untuk menghentikan deteksi sementara jika Anda ingin mengunci satu hasil scan.
- **Visual Feedback:** Perhatikan efek glassmorphism pada panel bawah dan glow ungu di sekitar teks label utama.

## 4. Background Management
- Jika Anda keluar dari aplikasi atau memindahkan aplikasi ke background, deteksi akan otomatis berhenti untuk menghemat baterai.
- Saat kembali ke aplikasi, deteksi akan dilanjutkan kembali secara otomatis (kecuali jika sebelumnya di-pause manual).
