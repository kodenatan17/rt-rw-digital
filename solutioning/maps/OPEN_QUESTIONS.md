# Open Questions - Fitur Maps RT/RW Digital

Dokumen ini mencatat pertanyaan, keputusan yang belum diambil, potensi konflik, dan rekomendasi untuk fitur Maps POC.

---

## 1. Keputusan yang Masih Perlu Diambil

### Q1.1: Format ID Hunian
**Pertanyaan:** Apakah format ID Hunian sudah ditentukan? (Contoh: `H001`, `RT01-001`, UUID, dll)
**Impact:** Mempengaruhi struktur tabel fasilitas dan API response.
**Rekomendasi:** Gunakan format yang sudah ada di modul Profil & Hunian. Jika belum ada, usulkan format: `H{nomor_urut}` atau `{kode_rt}-{nomor_urut}`.
**Status:** Perlu konfirmasi dengan tim existing.

### Q1.2: Pusat Peta Default (Center Coordinate)
**Pertanyaan:** Jika belum ada hunian yang memiliki koordinat, apa koordinat pusat peta yang ditampilkan?
**Opsi:**
  - A: Menggunakan koordinat default (misal: pusat Indonesia atau pusat kota/kabupaten).
  - B: Menampilkan pesan error "Belum ada data koordinat".
  - C: Menggunakan koordinat balai RW (jika sudah ada fasilitas balai warga).
**Rekomendasi:** Opsi C (jika balai RW ada) atau Opsi A dengan koordinat default provinsi/kabupaten.
**Status:** Perlu keputusan bisnis.

### Q1.3: Akses Warga Lain Melihat Detail Hunian
**Pertanyaan:** Apakah warga boleh melihat detail hunian tetangga (tanpa nama/identitas lengkap) seperti: tipe hunian, jumlah penghuni?
**Opsi:**
  - A: Hanya tampilkan marker tanpa info apapun.
  - B: Tampilkan info dasar: tipe hunian (rumah/kontrakan/kos).
  - C: Tampilkan juga jumlah penghuni (agregat).
**Rekomendasi:** Opsi B (tipe hunian saja) untuk menjaga privasi namun tetap informatif.
**Status:** Perlu keputusan kebijakan privasi.

### Q1.4: Batas Jumlah Fasilitas per Kategori
**Pertanyaan:** Apakah ada batasan jumlah fasilitas yang bisa ditambahkan per kategori? (Misal: maksimal 1 masjid per RT)
**Rekomendasi:** Tidak ada batasan hard limit di POC. Pengurus dapat menambahkan sesuai kebutuhan.
**Status:** Opsional, bisa ditambahkan jika ada kebutuhan bisnis.

### Q1.5: Periode Validitas Koordinat
**Pertanyaan:** Apakah koordinat memiliki masa berlaku? Jika sudah lebih dari X tahun, status menjadi `outdated`?
**Rekomendasi:** Di POC, tidak perlu ada validitas waktu. Koordinat tetap valid hingga ada perubahan manual.
**Status:** Future enhancement.

---

## 2. Potensi Konflik dengan Modul Existing

### C2.1: Sinkronisasi Data Hunian
**Potensi Konflik:** Jika modul Profil & Hunian mengubah atau menghapus hunian, apakah koordinat di modul Maps ikut terpengaruh?
**Rekomendasi:**
- Jika hunian dihapus, koordinat juga dihapus (atau diarsipkan).
- Jika hunian dipindah RT/RW, koordinat tetap ada namun perlu divalidasi ulang oleh pengurus RT/RW yang baru.
**Action Required:** Perlu diskusi alur cascading delete/update dengan modul Profil.

### C2.2: Role & Permission Pengurus RT/RW
**Potensi Konflik:** Apakah role "Pengurus RT" dan "Pengurus RW" sudah didefinisikan di sistem autentikasi?
**Rekomendasi:** Jika belum, tambahkan role baru: `pengurus_rt` dan `pengurus_rw` dengan scope wilayah (RT/RW mana yang boleh dikelola).
**Action Required:** Integrasi dengan modul Autentikasi & Autorisasi.

### C2.3: Notifikasi ke Warga
**Potensi Konflik:** Fitur Maps membutuhkan notifikasi (misal: usulan lokasi ditolak). Apakah modul Notifikasi sudah mendukung tipe notifikasi ini?
**Rekomendasi:** Tambahkan tipe notifikasi baru: `maps_usulan_ditolak`, `maps_usulan_disetujui`.
**Action Required:** Koordinasi dengan modul Notifikasi.

### C2.4: Upload Foto Fasilitas
**Potensi Konflik:** Apakah sudah ada sistem upload gambar/foto di aplikasi?
**Rekomendasi:** Gunakan endpoint upload existing (jika ada). Jika belum ada, tambahkan endpoint: `POST /upload/foto` yang mengembalikan URL file.
**Action Required:** Cek modul file storage existing.

---

## 3. Kebutuhan yang Belum Terdefinisi

### N3.1: Aturan Perpindahan Warga Antar RT/RW
**Pertanyaan:** Jika warga pindah dari RT A ke RT B (masih dalam RW yang sama), apakah:
  - Koordinat hunian lama tetap ada?
  - Koordinat hunian baru perlu input ulang?
  - Siapa yang bertanggung jawab validasi?
**Rekomendasi:** Koordinat hunian lama tetap ada (sebagai arsip). Hunian baru perlu input ulang oleh pengurus RT B.
**Status:** Perlu konfirmasi alur bisnis.

### N3.2: Hak Akses Lintas RT/RW
**Pertanyaan:** Apakah Pengurus RW dapat mengelola data hunian di seluruh RT, atau hanya di RT-nya sendiri?
**Rekomendasi:** Pengurus RW dapat mengelola seluruh RT di dalam RW-nya. Pengurus RT hanya dapat mengelola RT-nya sendiri.
**Status:** Perlu konfirmasi kebijakan organisasi.

### N3.3: Arsip Data Fasilitas yang Dihapus
**Pertanyaan:** Fasilitas yang dihapus (soft delete) apakah dapat diaktifkan kembali (restore)?
**Rekomendasi:** Ya, pengurus dapat melihat arsip fasilitas nonaktif dan mengaktifkan kembali jika diperlukan.
**Action Required:** Tambahkan endpoint `POST /maps/fasilitas/{id}/restore`.

### N3.4: Validasi Jarak Minimum Antar Marker
**Pertanyaan:** Apakah sistem perlu memvalidasi jarak minimum antar hunian atau antar fasilitas? (Misal: 2 hunian tidak boleh kurang dari 5 meter)
**Rekomendasi:** Tidak perlu di POC. Koordinat dipercayakan kepada pengurus RT/RW.
**Status:** Future enhancement (jika ada masalah duplikasi marker).

---

## 4. Pertanyaan Teknis (Untuk Developer)

### T4.1: Penyimpanan Koordinat
**Pertanyaan:** Apakah database mendukung tipe data POINT (PostGIS) atau menggunakan 2 kolom terpisah (latitude, longitude)?
**Rekomendasi:** Gunakan 2 kolom terpisah (`latitude: double`, `longitude: double`) untuk kemudahan di POC. Migrasi ke PostGIS di masa depan jika diperlukan analitik GIS.

### T4.2: Tile Server Rate Limit
**Pertanyaan:** Apakah OpenStreetMap tile server gratis memiliki rate limit atau batasan penggunaan?
**Jawaban:** Ya, OSM tile server gratis memiliki [usage policy](https://operations.osmfoundation.org/policies/tiles/) yang membatasi penggunaan komersial berat. Untuk POC dengan skala kecil (1 RT/RW, puluhan user), masih aman.
**Action Required:** Jika aplikasi berkembang, pertimbangkan self-hosting tile server atau migrasi ke Mapbox free tier.

### T4.3: Caching Peta di Client
**Pertanyaan:** Apakah tile peta di-cache di client untuk mengurangi bandwidth?
**Rekomendasi:** Ya, `flutter_map` mendukung caching tile. Implementasikan di client-side untuk performa lebih baik.

### T4.4: Penyimpanan Riwayat Perubahan Koordinat
**Pertanyaan:** Apakah riwayat perubahan koordinat wajib disimpan, atau opsional?
**Rekomendasi:** Wajib, untuk keperluan audit dan penyelesaian sengketa. Tabel `RIWAYAT_KOORDINAT` wajib diimplementasikan.

---

## 5. Risiko & Mitigasi

### R5.1: Risiko: Koordinat Salah Input
**Deskripsi:** Pengurus atau warga salah input koordinat, marker muncul di lokasi yang tidak sesuai.
**Mitigasi:**
- Wajib validasi oleh pengurus sebelum koordinat warga aktif.
- Tampilkan preview marker di peta sebelum simpan (konfirmasi visual).
- Catat riwayat perubahan untuk rollback jika diperlukan.

### R5.2: Risiko: Privasi Data Warga
**Deskripsi:** Koordinat hunian dapat membocorkan informasi sensitif (lokasi rumah warga).
**Mitigasi:**
- Koordinat hanya dapat diakses user yang login.
- Marker warga lain tidak menampilkan identitas lengkap.
- API memerlukan autentikasi & autorisasi ketat.

### R5.3: Risiko: Ketergantungan pada OSM Tile Server
**Deskripsi:** Jika OSM tile server down atau slow, peta tidak bisa ditampilkan.
**Mitigasi:**
- Implementasikan fallback ke tile server alternatif (misal: CartoDB, Stamen).
- Pertimbangkan self-hosting tile server di masa depan.

### R5.4: Risiko: Koordinat Tidak Akurat (GPS Error)
**Deskripsi:** GPS device tidak akurat, koordinat melenceng 5-10 meter.
**Mitigasi:**
- Pengurus wajib validasi koordinat secara manual (lihat peta).
- Gunakan metode map picker sebagai alternatif GPS.

---

## 6. Rekomendasi Scope POC

### Ruang Lingkup Minimal (Must-Have POC)
- [x] Tampilan peta dasar dengan tile OSM
- [x] Marker hunian & fasilitas
- [x] Input koordinat oleh pengurus (manual, map picker, GPS)
- [x] Detail marker (info singkat)
- [x] CRUD fasilitas lingkungan
- [x] Hak akses berbasis role

### Ruang Lingkup Opsional (Nice-to-Have POC)
- [x] Validasi usulan lokasi warga
- [x] Riwayat perubahan koordinat
- [ ] Filter marker berdasarkan kategori
- [ ] Search fasilitas berdasarkan nama
- [ ] Upload foto fasilitas

### Di Luar Scope POC (Future Phase)
- [ ] Polygon batas wilayah RT/RW
- [ ] Heatmap kependudukan
- [ ] Geocoding otomatis
- [ ] Cluster marker
- [ ] Laporan berbasis GIS
- [ ] Tracking survey lapangan
- [ ] Panic button / emergency mapping

---

## 7. Action Items & Keputusan yang Dibutuhkan

| # | Item | Stakeholder | Deadline | Status |
|---|------|-------------|----------|--------|
| 1 | Konfirmasi format ID Hunian | Tim Existing | - | Pending |
| 2 | Tentukan koordinat pusat default | Product Owner | - | Pending |
| 3 | Tentukan kebijakan privasi detail hunian | Product Owner | - | Pending |
| 4 | Cek role Pengurus RT/RW di sistem autentikasi | Tim Backend | - | Pending |
| 5 | Cek modul notifikasi untuk tipe baru | Tim Backend | - | Pending |
| 6 | Cek sistem upload foto existing | Tim Backend | - | Pending |
| 7 | Tentukan alur perpindahan warga | Product Owner | - | Pending |
| 8 | Tentukan hak akses Pengurus RW | Product Owner | - | Pending |

---

## 8. Asumsi yang Diambil (Untuk POC)

1. **Asumsi Data Existing**: Data hunian dan warga sudah lengkap di modul Profil & Hunian. Tidak ada duplikasi atau inkonsistensi.
2. **Asumsi Role**: Role `pengurus_rt` dan `pengurus_rw` sudah didefinisikan dengan scope wilayah yang jelas.
3. **Asumsi Notifikasi**: Modul notifikasi dapat diperluas untuk mendukung notifikasi Maps.
4. **Asumsi Upload**: Sistem upload foto sudah ada atau akan dibuat terpisah (bukan bagian fitur Maps).
5. **Asumsi GPS Accuracy**: GPS device warga memiliki akurasi minimal 10 meter (standar smartphone).
6. **Asumsi Network**: User memiliki koneksi internet untuk mengakses tile peta (tidak ada offline mode di POC).

---

## 9. Pertanyaan untuk Product Owner / Stakeholder

1. **Kebijakan Privasi**: Apakah warga lain boleh melihat tipe hunian tetangga (tanpa identitas nama)?
2. **Prioritas Fitur**: Mana yang lebih prioritas: validasi usulan warga atau CRUD fasilitas?
3. **Budget & Timeline**: Apakah POC harus selesai dalam 1 sprint (2 minggu) atau bisa lebih lama?
4. **User Adoption**: Apakah ada rencana sosialisasi/pelatihan untuk pengurus RT/RW dalam menggunakan fitur Maps?
5. **Data Migration**: Apakah ada data koordinat existing (dari Excel/Google Maps) yang perlu di-import?

---

**Status Dokumen:** Draft  
**Terakhir Diperbarui:** 18 Juni 2026  
**Next Review:** Setelah keputusan stakeholder diterima
