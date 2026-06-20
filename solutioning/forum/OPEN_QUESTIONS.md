# Open Questions - Fitur Forum Komunitas RT/RW Digital

Dokumen ini mencatat tantangan, potensi konflik, dan keputusan yang belum final.

---

## 1. Potensi Konflik dengan Modul Existing

### Q1.1: Overlap Fitur "Keluhan"
**Pertanyaan:** Platform saat ini sudah memiliki modul "Administrasi" dan mungkin fitur keluhan manual. Bagaimana forum kategori "Keluhan" berinteraksi dengan modul administrasi tersebut?
**Rekomendasi:** Keluhan di Forum bersifat publik untuk membangun transparansi. Jika keluhan bersifat rahasia/pribadi, warga harus diarahkan ke fitur "Pengajuan/Laporan Privat" (jika ada). Kategori Keluhan di Forum harus memiliki alur sinkronisasi ke sistem ticketing internal pengurus.

### Q1.2: Duplikasi Notifikasi
**Pertanyaan:** Jika warga mem-follow postingan yang sangat ramai, mereka akan menerima sangat banyak notifikasi. Apakah sistem perlu limitasi atau aggregation (misal: "X orang berkomentar di postingan Anda")?
**Rekomendasi:** Gunakan notifikasi agregat untuk reaksi (Like), namun tetap kirim notifikasi individual untuk komentar/balasan di fase MVP.

---

## 2. Kebijakan Privasi & Moderasi

### Q2.1: Postingan Lintas RT/RW
**Pertanyaan:** Apakah warga RT 01 boleh melihat dan berkomentar di postingan yang dibuat warga RT 02 (masih dalam RW yang sama)?
**Rekomendasi:** Ya, di level RW forum bersifat terbuka (default). Namun, sediakan opsi `is_private` atau `is_rt_only` untuk postingan yang hanya relevan bagi tetangga terdekat.

### Q2.2: Identitas Penulis
**Pertanyaan:** Apakah warga boleh menggunakan nama alias (pseudonym) atau harus nama asli sesuai profil?
**Rekomendasi:** Gunakan nama asli sesuai profil untuk menjaga akuntabilitas dan mencegah cyberbullying di lingkungan warga.

---

## 3. Tantangan Teknis

### Q3.1: Media Storage
**Pertanyaan:** Foto postingan akan memakan banyak storage server. Apakah ada limitasi resolusi atau auto-purge untuk foto lama?
**Rekomendasi:** Terapkan kompresi gambar di sisi aplikasi sebelum upload. Limitasi maksimal 5 foto per post.

### Q3.2: Real-time Interaction
**Pertanyaan:** Apakah user mengharapkan komentar muncul secara real-time (WebSocket) atau cukup dengan refresh manual?
**Rekomendasi:** Fase MVP cukup dengan pull-to-refresh untuk menghemat resource server. WebSocket bisa dipertimbangkan untuk fitur Chat/DM di masa depan.

---

## 4. Rencana Tahap Lanjutan (Post-MVP)

1. **Polling Warga:** Fitur untuk pengambilan suara digital terkait keputusan lingkungan (misal: pemilihan vendor sampah).
2. **Postingan Anonim:** Khusus untuk keluhan sensitif (keamanan/pungli).
3. **Analitik Sentiment:** Dashboard untuk pengurus melihat tingkat kepuasan warga berdasarkan komentar di forum.
4. **Marketplace Warga:** Kategori khusus jual-beli antar tetangga.
