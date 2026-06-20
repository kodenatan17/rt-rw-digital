# Feature Spec - Fitur Maps RT/RW Digital

## Informasi Dokumen
| Item | Nilai |
|------|-------|
| **Nama Fitur** | Peta Lingkungan RT/RW |
| **Fase** | POC (Proof of Concept) |
| **Modul Terkait** | Profil & Hunian, Data Warga |
| **Pendekatan Teknis** | OpenStreetMap + flutter_map (Free Tier) |

---

## 1. Ringkasan Fitur

Fitur Peta Lingkungan memungkinkan warga dan pengurus RT/RW melihat sebaran hunian dan fasilitas lingkungan dalam bentuk peta interaktif. Pengurus RT/RW dapat melakukan pendataan koordinat hunian dan fasilitas. **Fitur ini tidak menggantikan modul data warga atau modul hunian**, melainkan menambahkan dimensi geografis ke data yang sudah ada.

### Tujuan Bisnis
- Memudahkan visualisasi sebaran warga di lingkungan RT/RW
- Membantu pengurus dalam pendataan aset dan fasilitas lingkungan
- Menyediakan informasi geografis untuk perencanaan dan pelaporan
- Meningkatkan transparansi dan akses informasi warga

---

## 2. Lingkupan POC (In Scope)

### 2.1. Peta Dasar (Base Map)
- [x] Menampilkan tile peta dari OpenStreetMap (gratis)
- [x] Zoom in/out (level 10 - 20)
- [x] Drag untuk navigasi peta
- [x] Center peta otomatis ke koordinat RT/RW pengguna

### 2.2. Marker Hunian
- [x] Menampilkan marker untuk setiap hunian yang memiliki koordinat
- [x] Dua tipe marker: "Rumah Saya" (milik sendiri) dan "Rumah" (warga lain)
- [x] Tap marker menampilkan info singkat
- [x] Perbedaan tampilan visual antara hunian validated vs pending

### 2.3. Marker Fasilitas Lingkungan
- [x] Menampilkan marker untuk setiap fasilitas yang terdaftar
- [x] Icon marker berbeda per kategori (masjid, pos, dll)
- [x] Tap marker menampilkan info detail + kontak

### 2.4. Pendataan Koordinat Hunian (Pengurus)
- [x] Input koordinat hunian via klik peta (map picker)
- [x] Input koordinat hunian via current location (GPS)
- [x] Input koordinat hunian via manual lat/lng
- [x] Edit / geser marker hunian yang sudah ada
- [x] Status validasi: validated (input langsung pengurus)

### 2.5. Validasi Usulan Koordinat (Pengurus)
- [x] List usulan koordinat dari warga (status pending)
- [x] Setujui, tolak, atau revisi usulan
- [x] Kirim notifikasi ke warga jika ditolak

### 2.6. Pendataan Fasilitas (Pengurus)
- [x] Tambah fasilitas baru (nama, kategori, lokasi, kontak, foto)
- [x] Pilih kategori dari master data yang sudah ditentukan
- [x] Edit dan hapus fasilitas (soft delete)
- [x] Tidak perlu validasi (langsung aktif)

### 2.7. Privasi & Keamanan
- [x] Marker warga lain tidak menampilkan data identitas lengkap
- [x] Map hanya bisa diakses user yang login
- [x] Edit/input terbatas pada role pengurus

---

## 3. Di Luar Lingkupan POC (Out of Scope)

Fitur berikut tidak termasuk dalam POC dan akan dipertimbangkan untuk fase selanjutnya:

### 3.1. Geocoding Otomatis
- [ ] Pencarian alamat ke koordinat (butuh API berbayar Google/Maps)
- [ ] Reverse geocoding (koordinat ke alamat)
- [ ] Suggest/autocomplete alamat

### 3.2. Polygon Wilayah
- [ ] Batas wilayah RT dalam bentuk polygon
- [ ] Batas wilayah RW dalam bentuk polygon
- [ ] Warna/shading per wilayah RT

### 3.3. Analitik Lanjutan
- [ ] Heatmap kepadatan hunian
- [ ] Cluster marker (pengelompokan marker)
- [ ] Diagram dan chart overlay peta

### 3.4. Fitur Darurat
- [ ] Lokasi kejadian
- [ ] Tracking petugas
- [ ] Status kondisi darurat di peta

### 3.5. Survey & Pendataan Lapangan
- [ ] Tracking lokasi survey
- [ ] Input data survey dengan titik koordinat
- [ ] Photo geo-tagging

### 3.6. Import / Export Data
- [ ] Batch import koordinat dari file (CSV/Excel)
- [ ] Export data koordinat ke file
- [ ] Sinkronasi data perangkat lapangan

### 3.7. Integrasi Pihak Ketiga
- [ ] Tile server berbayar (Mapbox, Google Maps)
- [ ] Layer tambahan (cuaca, lalu lintas)
- [ ] Street view

---

## 4. Spesifikasi Fungsional Detail

### 4.1. Modul: Peta RT

#### F-MAP-001: Tampilan Peta
**Deskripsi:** Halaman peta utama yang menampilkan tile OSM, marker hunian, dan marker fasilitas.
**Trigger:** User membuka menu "Peta RT" dari navigasi aplikasi.
**Aktor:** Warga, Pengurus RT/RW, Admin
**Syarat:** User sudah login, memiliki RT/RW yang terdaftar.

Alur:
1. Sistem membaca data profil user untuk mendapatkan ID RT/RW
2. Sistem menghitung koordinat pusat RT/RW (dari rata-rata koordinat hunian yang ada, atau koordinat default)
3. Peta di-render dengan tile OSM dan center di koordinat tersebut
4. Sistem mengambil data hunian dengan koordinat di RT/RW yang sama
5. Sistem mengambil data fasilitas dengan koordinat di RT/RW yang sama
6. Peta menampilkan marker untuk setiap data yang didapat

**Response:**
- Daftar marker hunian (id_hunian, lat, lng, tipe_hunian, inisial KK, status)
- Daftar marker fasilitas (id_fasilitas, nama, kategori, lat, lng)
- Pusat peta (lat, lng)

#### F-MAP-002: Detail Marker Hunian
**Deskripsi:** Informasi detail saat marker hunian di-tap.
**Aktor:** Semua role
**Aturan Akses:**
- Jika marker milik sendiri: tampilkan nama KK, alamat, tipe hunian, status validasi
- Jika marker milik orang lain: hanya tampilkan "Rumah" + tipe hunian (tanpa identitas)

#### F-MAP-003: Detail Marker Fasilitas
**Deskripsi:** Informasi detail saat marker fasilitas di-tap.
**Aktor:** Semua role
**Informasi:** Nama, kategori, deskripsi, penanggung jawab, kontak, jam operasional

### 4.2. Modul: Pendataan Lokasi

#### F-MAP-010: Input Koordinat Hunian (Pengurus)
**Deskripsi:** Pengurus menambahkan koordinat ke hunian yang belum memiliki lokasi.
**Trigger:** Pengurus memilih hunian dari daftar dan memilih "Tandai Lokasi".
**Aktor:** Pengurus RT/RW, Admin

Input:
- Latitude (double, -90 s.d. 90, wajib)
- Longitude (double, -180 s.d. 180, wajib)
- Sumber: manual / gps / map_picker (enum, default: map_picker)

Output: Koordinat tersimpan, marker langsung tampil (status: validated)

#### F-MAP-011: Validasi Usulan Lokasi Warga (Pengurus)
**Deskripsi:** Pengurus memvalidasi usulan lokasi yang diinput warga.
**Trigger:** Ada notifikasi usulan baru dari warga.
**Aktor:** Pengurus RT/RW

Alur:
1. Pengurus membuka tab "Validasi" di halaman Maps
2. Sistem menampilkan daftar usulan pending (nama warga, hunian, koordinat usulan)
3. Pengurus memilih salah satu usulan
4. Peta menampilkan posisi usulan
5. Pengurus memilih aksi:
   - Setujui: status jadi validated
   - Tolak: input alasan, status tetap pending (dicatat sebagai rejected)
   - Revisi: geser marker ke posisi benar, lalu setujui

#### F-MAP-012: Usulan Lokasi oleh Warga
**Deskripsi:** Warga mengusulkan koordinat huniannya.
**Trigger:** Warga membuka "Atur Lokasi Rumah" dari profil hunian.
**Aktor:** Warga (Kepala Keluarga)

Alur:
1. Warga memilih lokasi di peta
2. Sistem menyimpan koordinat dengan status "pending"
3. Notifikasi dikirim ke pengurus RT untuk validasi

### 4.3. Modul: Fasilitas Lingkungan

#### F-MAP-020: Daftar Fasilitas
**Deskripsi:** Menampilkan daftar fasilitas lingkungan di RT/RW.
**Trigger:** Pengurus membuka menu "Fasilitas".
**Aktor:** Semua role (view), Pengurus (manage)
**Tampilan:** List dengan filter kategori dan status

#### F-MAP-021: Tambah Fasilitas
**Deskripsi:** Pengurus menambahkan fasilitas lingkungan baru.
**Aktor:** Pengurus RT/RW, Admin

Input:
- Nama (String, wajib)
- Kategori (Enum, wajib, dari master data)
- Deskripsi (String?, opsional)
- Koordinat (lat/lng, wajib)
- Alamat (String?, opsional)
- Penanggung Jawab (String?, opsional)
- Kontak (String?, opsional)
- Jam Operasional (String?, opsional)
- Foto (String/URL?, opsional)

#### F-MAP-022: Edit Fasilitas
**Deskripsi:** Mengubah data fasilitas yang sudah ada.
**Aktor:** Pengurus RT/RW, Admin

#### F-MAP-023: Hapus Fasilitas
**Deskripsi:** Menonaktifkan fasilitas (soft delete).
**Aktor:** Pengurus RT/RW, Admin
**Alur:** Konfirmasi -> status_aktif = false

---

## 5. Matriks Hak Akses

| Fitur | Warga | Pengurus RT | Pengurus RW | Admin |
|-------|-------|-------------|-------------|-------|
| Lihat peta | YA | YA | YA | YA |
| Detail hunian sendiri | YA | YA | YA | YA |
| Detail hunian warga lain | TIDAK | YA | YA | YA |
| Usulkan koordinat sendiri | YA | - | - | - |
| Input/edit koordinat (langsung) | TIDAK | YA (RT sendiri) | YA (RW) | YA |
| Validasi usulan warga | TIDAK | YA (RT sendiri) | YA | YA |
| Tambah fasilitas | TIDAK | YA (RT sendiri) | YA | YA |
| Edit fasilitas | TIDAK | YA (RT sendiri) | YA | YA |
| Hapus fasilitas | TIDAK | YA (RT sendiri) | YA | YA |
| Lihat arsip nonaktif | TIDAK | YA | YA | YA |

---

## 6. Daftar Kategori Fasilitas (Master Data)

| ID | Kategori | Icon | Default RT/RW |
|----|----------|------|---------------|
| `masjid` | Masjid / Mushola | Mosque | RT |
| `pos_keamanan` | Pos Keamanan | Shield | RT |
| `balai_warga` | Balai Warga | Building | RW |
| `cctv` | Titik CCTV | Camera | RT |
| `taman` | Taman Bermain | Tree | RT |
| `parkir` | Area Parkir | Car | RT |
| `sampah` | Tempat Sampah | Trash | RT |
| `lapangan` | Lapangan | Sport | RW |
| `sekolah` | Sekolah/TPQ | School | RW |
| `klinik` | Klinik/Posyandu | Medical | RW |
| `air_bersih` | Sumber Air | Water | RT |
| `penerangan` | Lampu Jalan | Light | RT |
| `lainnya` | Lainnya | Pin | RT |

---

## 7. Aturan Transisi Status Koordinat Hunian

```
                   +---> [validated] <---+
                   |                     |
       Input oleh  |  Input oleh warga   |  Validasi disetujui
       pengurus    |                     |  atau direvisi
                   |                     |
                 [baru] ------------> [pending]
                   ^                       |
                   |                       | Ditolak
                   |                       v
                   +-------------------- [ditolak]
                                            |
                                            | Warga menginput ulang
                                            v
                                         [pending] (ulang)
```

### Keterangan Status
| Status | Arti |
|--------|------|
| `null` | Belum ada koordinat |
| `pending` | Koordinat diinput warga, menunggu validasi |
| `validated` | Koordinat sudah diverifikasi pengurus |
| `outdated` | Koordinat perlu diperbarui |
| `rejected` | Usulan koordinat ditolak (dicatat dengan alasan) |
