# Feature Spec - Fitur Forum Komunitas RT/RW Digital

## Informasi Dokumen
| Item | Nilai |
|------|-------|
| **Nama Fitur** | Forum Komunitas (Warga Feed) |
| **Fase** | MVP (Minimum Viable Product) |
| **Modul Terkait** | Profil Warga, Notifikasi, Maps |
| **Aktor Utama** | Warga, Pengurus RT, Pengurus RW, Admin |

---

## 1. Ringkasan Fitur

Forum Komunitas adalah pusat interaksi digital bagi warga RT/RW. Fitur ini berbentuk feed sosial (seperti Facebook/X) yang dikhususkan untuk lingkungan perumahan. Warga dapat menyampaikan keluhan, aspirasi, berbagi informasi, dan berdiskusi secara transparan. Pengurus dapat menggunakan forum ini untuk pengumuman resmi dan merespons masukan warga secara real-time.

### Tujuan Bisnis
- Meningkatkan keterlibatan (engagement) warga dalam kegiatan lingkungan.
- Menyediakan wadah resmi untuk keluhan dan aspirasi warga.
- Mempercepat diseminasi informasi dari pengurus ke warga.
- Membangun transparansi penanganan masalah di lingkungan RT/RW.

---

## 2. Lingkupan MVP (In Scope)

### 2.1. Feed & Postingan
- [x] Feed utama (list postingan terbaru) dengan infinite scroll.
- [x] Buat postingan teks (maks 5000 karakter).
- [x] Lampirkan foto (maks 5 file).
- [x] Pilih kategori (Keluhan, Aspirasi, Info, dll).
- [x] Hapus/Edit postingan sendiri.
- [x] Filter feed berdasarkan kategori.

### 2.2. Interaksi Warga
- [x] Komentar pada postingan.
- [x] Balas komentar (Thread/Reply) kedalaman 1 level.
- [x] Reaksi (Like, Love, Support, Sad, Angry) pada postingan dan komentar.
- [x] Share postingan via System Share (WA, Link, dll).

### 2.3. Manajemen Keluhan (Complaint)
- [x] Status khusus untuk kategori Keluhan (Menunggu, Proses, Selesai).
- [x] Pengurus dapat mengubah status keluhan.
- [x] Notifikasi perubahan status ke warga.

### 2.4. Moderasi Dasar
- [x] Laporkan konten (Post/Komentar) melanggar aturan.
- [x] Moderator (Pengurus) dapat menghapus konten negatif.
- [x] Pinned Post (maks 3) oleh pengurus.

---

## 3. Di Luar Lingkupan MVP (Out of Scope / Future Enhancement)

- [ ] Polling/Voting warga.
- [ ] Lampiran Video & Dokumen (hanya foto di MVP).
- [ ] Hashtag (#) dan Mention (@).
- [ ] Forum khusus per RT (MVP: satu forum gabungan RW).
- [ ] Postingan Anonim.
- [ ] Analytics engagement mendalam.
- [ ] Trending discussion.
- [ ] Integrasi Iklan/Marketplace warga.

---

## 4. Spesifikasi Fungsional Detail

### 4.1. Modul: Feed Utama
**F-FRM-001: Tampilan Feed**
- Menampilkan postingan secara kronologis terbalik (terbaru di atas).
- Pinned post selalu di posisi paling atas.
- Setiap card postingan menampilkan: Foto profil, Nama, Waktu, Kategori, Judul (jika ada), Konten (truncate jika panjang), Foto (grid view), Jumlah Reaksi, Jumlah Komentar.

### 4.2. Modul: Postingan
**F-FRM-010: Form Buat Postingan**
- Input kategori (dropdown).
- Input teks konten (wajib).
- Input foto (multiple picker).
- Preview foto sebelum posting.

**F-FRM-011: Manajemen Status Keluhan**
- Jika kategori = Keluhan, tampilkan badge status di card.
- Hanya pengurus yang melihat tombol "Ubah Status" (Menunggu -> Proses -> Selesai).

### 4.3. Modul: Komentar & Thread
**F-FRM-020: Thread Diskusi**
- Halaman detail postingan menampilkan seluruh komentar.
- Mendukung "Balas" pada komentar orang lain (nested view).
- Real-time update (opsional) atau pull-to-refresh untuk komentar baru.

### 4.4. Modul: Moderasi
**F-FRM-030: Reporting System**
- Tombol "Laporkan" pada setiap konten.
- Pilihan alasan: SARA, Pornografi, Spam, Hoax, dll.
- Konten yang dilaporkan tetap tampil sampai moderator mengambil tindakan (kecuali auto-hide jika laporan > 10).

---

## 5. Matriks Hak Akses

| Fitur | Warga | Pengurus RT | Pengurus RW | Super Admin |
|-------|-------|-------------|-------------|-------|
| Baca Feed | YA | YA | YA | YA |
| Buat Postingan | YA | YA | YA | YA |
| Komentar/Reaksi | YA | YA | YA | YA |
| Edit/Hapus Postingan Sendiri | YA | YA | YA | YA |
| Pin Postingan | TIDAK | YA | YA | YA |
| Hapus Postingan Orang Lain | TIDAK | YA (RT) | YA (RW) | YA |
| Ubah Status Keluhan | TIDAK | YA (RT) | YA (RW) | YA |
| Banned User | TIDAK | TIDAK | YA | YA |

---

## 6. Kategori Postingan (MVP)

1. **Keluhan**: Masalah lingkungan (jalan, sampah, lampu, air).
2. **Aspirasi**: Saran/usul perbaikan lingkungan.
3. **Informasi**: Pengumuman dari warga atau pengurus.
4. **Kegiatan**: Info acara (kerja bakti, arisan, lomba).
5. **Keamanan**: Laporan isu keamanan/kamtibmas.
6. **Lingkungan**: Isu kebersihan & penghijauan.
7. **Diskusi Umum**: Topik bebas lainnya.

---

## 7. Integrasi Notifikasi

| Pemicu | Penerima | Isi Pesan |
|--------|----------|-----------|
| Komentar Baru | Penulis Post | "[Nama] berkomentar pada postingan Anda." |
| Balasan Komentar | Penulis Komentar | "[Nama] membalas komentar Anda." |
| Keluhan Diproses | Penulis Keluhan | "Keluhan Anda sedang ditangani oleh Pengurus RT." |
| Keluhan Selesai | Penulis Keluhan | "Keluhan Anda telah dinyatakan Selesai. Terima kasih." |
| Postingan di-Pin | Seluruh Warga | "Pengumuman Penting: [Judul Postingan]" |
| Konten Dihapus | Penulis Konten | "Konten Anda dihapus karena melanggar aturan komunitas." |
