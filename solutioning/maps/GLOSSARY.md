# Glossary - Fitur Maps RT/RW Digital

## Domain Entities

### Hunian
Tempat tinggal/bangunan yang didiami warga. Merupakan unit dasar kepemilikan koordinat geografis. Setiap hunian memiliki ID unik dan dapat memiliki satu koordinat lokasi.

### Koordinat Lokasi
Posisi geografis dalam format latitude dan longitude (sistem WGS84). Koordinat dimiliki oleh Hunian atau Fasilitas Lingkungan, bukan oleh warga secara langsung.

### Fasilitas Lingkungan
Infrastruktur atau area publik di lingkungan RT/RW seperti masjid, balai warga, pos keamanan, CCTV, taman, tempat sampah, dll. Setiap fasilitas memiliki koordinat dan metadata.

### Kepala Keluarga
Warga yang terdaftar sebagai akun utama dan bertanggung jawab atas data hunian. 1 akun = 1 kepala keluarga = 1 hunian.

### Anggota Keluarga
Warga yang tinggal di hunian yang sama dengan kepala keluarga. Tidak memiliki akun login sendiri, terdaftar dalam data hunian.

### Relasi Hunian-Warga
Hubungan antara warga (kepala keluarga + anggota keluarga) dengan hunian. Relasi ini yang menunjukkan warga tinggal di hunian mana, bukan koordinat warga itu sendiri.

### RT (Rukun Tetangga)
Unit wilayah administrasi terkecil di Indonesia, biasanya terdiri dari 20-50 hunian.

### RW (Rukun Warga)
Unit wilayah administrasi yang membawahi beberapa RT, biasanya 5-10 RT.

### Wilayah RT/RW
Batas geografis (polygon) yang mendefinisikan area cakupan RT atau RW. Bersifat opsional dalam fase POC.

## Map-Specific Terms

### OpenStreetMap (OSM)
Platform peta open-source yang digunakan sebagai sumber tile map. Gratis dan dapat digunakan tanpa biaya lisensi.

### flutter_map
Library Flutter untuk menampilkan peta interaktif dengan tile dari OSM atau sumber lain.

### Tile Layer
Layer dasar peta yang menampilkan jalan, bangunan, dan fitur geografis dari OSM.

### Marker
Penanda visual di peta yang menunjukkan lokasi hunian atau fasilitas. Dapat di-klik untuk menampilkan detail.

### Polygon
Bentuk geometris tertutup yang digunakan untuk menggambarkan batas wilayah RT/RW (di luar scope POC).

### Geocoding
Proses mengubah alamat teks menjadi koordinat lat/lng. Tidak termasuk dalam POC (entry manual).

### Reverse Geocoding
Proses mengubah koordinat lat/lng menjadi alamat teks. Tidak termasuk dalam POC.

### Zoom Level
Tingkat pembesaran peta. Level 15-18 cocok untuk lingkungan RT/RW.

### Center Coordinate
Koordinat tengah (centroid) yang digunakan sebagai pusat tampilan peta saat pertama kali dibuka.

## Feature-Specific Terms

### Pendataan Lokasi
Proses pengumpulan dan validasi koordinat hunian atau fasilitas oleh pengurus RT/RW. Dapat dilakukan manual (input lat/lng) atau menggunakan fitur current location device.

### Validasi Lokasi
Proses verifikasi bahwa koordinat yang diinput sudah benar dan sesuai dengan lokasi fisik hunian/fasilitas.

### Cluster Marker
Pengelompokan beberapa marker yang berdekatan menjadi satu marker dengan angka jumlah (tidak wajib di POC).

### Peta Warga
Tampilan peta yang menampilkan sebaran hunian warga dalam satu RT/RW beserta fasilitas lingkungan.

### Mode View (Warga)
Mode tampilan read-only untuk warga. Hanya bisa melihat peta, tidak bisa menambah/edit data.

### Mode Edit (Pengurus)
Mode tampilan untuk pengurus RT/RW yang memungkinkan penambahan, perubahan, dan penghapusan marker.

## Data Privacy Terms

### Kepemilikan Data Lokasi
Koordinat lokasi adalah milik hunian/fasilitas, bukan warga. Warga tidak memiliki koordinat pribadi, hanya terhubung ke hunian.

### Privasi Lokasi Warga
Koordinat hunian hanya dapat dilihat oleh:
- Kepala keluarga hunian tersebut
- Pengurus RT/RW setempat
- Admin sistem

Warga lain tidak dapat melihat detail hunian milik orang lain (hanya marker tanpa detail).

### Data Agregat
Data yang sudah diagregasi seperti jumlah hunian per RT atau per fasilitas. Tidak menampilkan data individu.

## Access Control Terms

### Role: Warga
Akun kepala keluarga yang dapat melihat peta (read-only) dan melihat detail huniannya sendiri.

### Role: Pengurus RT
Akun pengurus yang dapat mengelola data hunian dan fasilitas dalam RT-nya saja.

### Role: Pengurus RW
Akun pengurus yang dapat mengelola data hunian dan fasilitas dalam seluruh RT di RW-nya.

### Role: Admin
Akun sistem yang memiliki akses penuh ke seluruh data.

## POC Scope Terms

### Fase POC (Proof of Concept)
Tahap awal pengembangan fitur Maps dengan scope terbatas: hanya pendataan koordinat hunian dan fasilitas dasar, tanpa fitur geocoding otomatis atau batas wilayah polygon.

### Future Enhancement
Fitur yang direncanakan untuk fase pengembangan berikutnya di luar POC, seperti:
- Batas wilayah RT/RW (polygon)
- Heatmap kependudukan
- Tracking survey lapangan
- Geocoding otomatis
- Kondisi darurat/panic button
- Laporan berbasis GIS

## Technical Terms (Non-Implementation)

### GeoJSON
Format data JSON untuk menyimpan struktur geometris seperti point, polygon, dll. Akan digunakan untuk menyimpan koordinat dan batas wilayah.

### WGS84
Sistem koordinat geografis standar yang digunakan GPS. Format: latitude (lintang) dan longitude (bujur).

### Latitude (Lintang)
Koordinat utara-selatan, nilai -90 hingga 90. Positif = utara, negatif = selatan.

### Longitude (Bujur)
Koordinat timur-barat, nilai -180 hingga 180. Positif = timur, negatif = barat.

### Tile Server
Server yang menyediakan gambar tile peta. Untuk POC menggunakan OpenStreetMap tile server gratis.

## Integration Terms

### Modul Data Warga
Modul existing yang menyimpan data warga dan kepala keluarga. Fitur Maps terintegrasi dengan modul ini untuk mendapatkan data hunian.

### Modul Hunian
Modul existing yang menyimpan data hunian/tempat tinggal. Fitur Maps menambahkan field koordinat ke entity hunian existing.

### No Duplication Principle
Prinsip bahwa fitur Maps tidak membuat tabel/entity baru untuk data warga atau hunian. Semua data referensi menggunakan entity existing, hanya menambahkan koordinat dan fasilitas.
