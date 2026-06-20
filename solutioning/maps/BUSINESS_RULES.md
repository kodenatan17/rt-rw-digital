# Business Rules - Fitur Maps RT/RW Digital

## 1. Kepemilikan Koordinat (Ownership)

1.1. Koordinat lokasi dimiliki oleh **Hunian** (Rumah/Bangunan), bukan oleh warga secara langsung.
1.2. Warga (Kepala Keluarga & Anggota Keluarga) terhubung ke lokasi melalui relasi dengan Hunian.
1.3. Fasilitas lingkungan (Masjid, Pos Keamanan, dll) memiliki koordinat lokasinya sendiri yang terpisah dari hunian.
1.4. Setiap hunian atau fasilitas hanya boleh memiliki maksimal satu koordinat lokasi aktif.

## 2. Hak Akses & Privasi (Access Control & Privacy)

2.1. **Warga (Kepala Keluarga):**
- Dapat melihat peta seluruh RT/RW tempat tinggalnya (Marker hunian lain & fasilitas).
- Hanya dapat melihat detail lengkap (alamat, foto, pemilik) untuk huniannya sendiri.
- Hanya dapat melihat marker hunian lain tanpa informasi detail identitas penghuni (demi privasi).
- Dapat melihat detail lengkap fasilitas lingkungan (nama, pengelola, jam operasional).
- Dapat memperbarui koordinat lokasinya sendiri (jika pengurus belum menentukan) namun memerlukan validasi pengurus.

2.2. **Pengurus RT:**
- Dapat melihat detail seluruh hunian dan warga di dalam wilayah RT-nya.
- Dapat menambah, mengubah, dan menghapus koordinat hunian dan fasilitas di dalam wilayah RT-nya.
- Wajib melakukan validasi terhadap input koordinat yang dilakukan oleh warga.

2.3. **Pengurus RW:**
- Memiliki akses yang sama dengan Pengurus RT, namun berlaku untuk seluruh RT di dalam wilayah RW-nya.
- Dapat memindahkan hunian/fasilitas antar RT jika terjadi kesalahan input.

2.4. **Keamanan Data:**
- Koordinat lokasi tidak boleh dibagikan ke pihak ketiga atau ditampilkan secara publik tanpa otentikasi.
- API untuk mengambil data lokasi harus menyertakan token otentikasi yang valid.

## 3. Pengelolaan Fasilitas Lingkungan

3.1. Fasilitas lingkungan mencakup: masjid, pos keamanan, balai warga, CCTV, taman bermain, area parkir, tempat pembuangan sampah, dll.
3.2. Penambahan fasilitas baru hanya dapat dilakukan oleh Pengurus RT/RW atau Admin.
3.3. Metadata fasilitas minimal mencakup: Nama, Kategori, Koordinat, Penanggung Jawab, dan Status Aktif.
3.4. Fasilitas CCTV dapat ditandai lokasinya di peta, namun akses streaming (jika ada) diatur oleh kebijakan hak akses yang berbeda.

## 4. Pendataan & Validasi Lokasi (Data Management)

4.1. **Metode Pendataan:**
- Manual input: User menginput nilai latitude dan longitude secara manual.
- Map picker: User memilih lokasi langsung di peta.
- Current location: User mengambil koordinat berdasarkan posisi GPS device saat ini (direkomendasikan saat berada di lokasi).

4.2. **Alur Validasi:**
- Koordinat yang diinput oleh warga berstatus "Pending Validation".
- Pengurus RT/RW harus memverifikasi lokasi tersebut (lewat kunjungan atau konfirmasi alamat).
- Setelah validasi, status menjadi "Validated" dan marker akan muncul secara permanen di peta warga.
- Koordinat yang diinput langsung oleh pengurus berstatus "Validated" secara otomatis.

4.3. **Perubahan Lokasi:**
- Perubahan lokasi hunian yang sudah berstatus "Validated" hanya dapat dilakukan oleh Pengurus RT/RW.
- Riwayat perubahan koordinat (lat/lng, timestamp, user) harus dicatat untuk keperluan audit.

## 5. Integrasi Data (Zero Duplication)

5.1. Fitur Maps tidak diperbolehkan membuat duplikasi data warga atau data hunian.
5.2. Fitur Maps harus mengambil referensi dari Modul Data Warga dan Modul Hunian existing.
5.3. Entitas baru hanya diperbolehkan untuk data fasilitas lingkungan dan metadata tambahan yang tidak ada di modul lain.

## 6. Ruang Lingkup POC (Minimal Cost Strategy)

6.1. Menggunakan OpenStreetMap (OSM) tile server yang gratis sebagai base map.
6.2. Menggunakan library flutter_map yang open-source dan tidak berbayar.
6.3. Tidak menggunakan layanan berbayar (seperti Google Maps API atau Mapbox API) untuk fase POC.
6.4. Geocoding otomatis (pencarian alamat ke koordinat) tidak masuk dalam scope POC untuk menghindari biaya API pihak ketiga. User mencari lokasi secara manual di peta.

## 7. Skalabilitas & Pengembangan Jangka Panjang

7.1. Struktur data koordinat harus mendukung pengembangan ke arah polygon (batas wilayah) di masa depan.
7.2. Pendataan aset lingkungan (lampu jalan, hydrant, dll) harus dapat ditambahkan sebagai kategori baru di fasilitas lingkungan.
7.3. Sistem harus siap untuk fitur emergency/laporan warga berbasis koordinat (lokasi kejadian otomatis terdeteksi).

## 8. Glossarium & Standar Data

8.1. Koordinat harus disimpan dalam format latitude dan longitude (WGS84).
8.2. ID Hunian menggunakan format standar aplikasi yang sudah ada.
8.3. Penamaan kategori fasilitas lingkungan harus seragam dan dikelola melalui master data sistem.
