# Domain Model - Fitur Maps RT/RW Digital

Dokumen ini mendefinisikan entitas, atribut, relasi, dan struktur data untuk fitur Maps.

## Prinsip Desain

1. **Zero Data Duplication**: Tidak ada tabel baru untuk data warga atau data hunian yang sudah ada.
2. **Koordinat = Attibut Hunian/Fasilitas**: Koordinat adalah properti dari Hunian atau Fasilitas Lingkungan.
3. **Marker = Turunan Data**: Marker di peta adalah hasil render dari data hunian dan fasilitas yang memiliki koordinat.

---

## 1. Entity: Hunian (Existing - Dimodifikasi)

### Sumber: Modul Profil & Hunian (existing)
### Perubahan: Menambah field koordinat

```
+-------------------------------+
|           HUNIAN              |
+-------------------------------+
| id_hunian       (PK, String)  |
| alamat          (String)      |
| rt              (String)      |
| rw              (String)      |
| dusun           (String?)     |
| tipe_hunian     (Enum)        |
| status_milik    (Enum)        |
| luas_tanah      (int?)        |
| luas_bangunan   (int?)        |
| foto_depan      (String?)     |
|+-----------------------------+|
|| Field BARU untuk Maps:      ||
|| latitude        (double?)   ||
|| longitude       (double?)   ||
|| koord_status    (Enum?)     |  --> pending / validated / outdated
|| koord_source    (Enum?)     |  --> manual / gps / map_picker
|| koord_updated_at (DateTime?)|
|| koord_validated_by (String?)|  --> ID user pengurus
|+-----------------------------+|
| created_at      (DateTime)    |
| updated_at      (DateTime)    |
+-------------------------------+
         |
         | 1
         |
         | N
+-------------------------------+
|      ANGGOTA_KELUARGA         |
+-------------------------------+
| id             (PK, int)      |
| id_hunian      (FK -> Hunian) |
| nama           (String)       |
| relasi         (Enum)         |
| tanggal_lahir  (Date?)        |
| created_at     (DateTime)     |
+-------------------------------+
```

---

## 2. Entity: Fasilitas Lingkungan (Baru)

```
+-------------------------------+
|    FASILITAS_LINGKUNGAN       |
+-------------------------------+
| id_fasilitas   (PK, String)   |
| nama           (String)       |
| kategori       (Enum)         |
| deskripsi      (String?)      |
| latitude       (double?)      |
| longitude      (double?)      |
| alamat         (String?)      |
| rt             (String)       |
| rw             (String)       |
| dusun          (String?)      |
| foto           (String?)      |
| penanggung_jawab (String?)    |
| kontak         (String?)      |  --> No telepon / WA
| jam_operasional (String?)     |
| status_aktif   (Boolean)      |
| created_by     (String)       |  --> ID user pengurus
| updated_by     (String?)      |
| created_at     (DateTime)     |
| updated_at     (DateTime)     |
+-------------------------------+
```

### Enum: Kategori Fasilitas

| Kategori | Deskripsi |
|----------|-----------|
| `masjid` | Masjid / Mushola |
| `pos_keamanan` | Pos satpam / poskamling |
| `balai_warga` | Balai RT / RW / aula |
| `cctv` | Titik CCTV lingkungan |
| `taman` | Taman bermain / RTH |
| `parkir` | Area parkir umum |
| `sampah` | TPS / Tempat pembuangan sampah |
| `lapangan` | Lapangan olahraga |
| `sekolah` | Sekolah / TPQ |
| `klinik` | Klinik / Posyandu |
| `air_bersih` | Sumur / Pompa / PAM umum |
| `penerangan` | Lampu jalan / PJU |
| `lainnya` | Fasilitas lainnya |

---

## 3. Entity: Riwayat Perubahan Koordinat (Baru - Untuk Audit)

```
+-------------------------------+
|  RIWAYAT_KOORDINAT            |
+-------------------------------+
| id               (PK, int)    |
| id_ref           (String)     |  --> ID Hunian atau ID Fasilitas
| tipe_ref         (Enum)       |  --> 'hunian' / 'fasilitas'
| latitude_lama    (double?)    |
| longitude_lama   (double?)    |
| latitude_baru    (double?)    |
| longitude_baru   (double?)    |
| diubah_oleh      (String)     |  --> ID user
| alasan_perubahan (String?)    |
| status_sebelum   (String?)    |
| status_sesudah   (String?)    |
| created_at       (DateTime)   |
+-------------------------------+
```

---

## 4. Entity: Wilayah RT/RW (Future Enhancement - Untuk Polygon)

```
+-------------------------------+
|       WILAYAH                 |
+-------------------------------+
| id_wilayah   (PK, String)     |
| nama         (String)         |
| tipe         (Enum)           |  --> 'RT' / 'RW'
| rt           (String?)        |  --> null jika tipe=RW
| rw           (String)         |
| polygon      (Polygon?)       |  --> Data polygon (GeoJSON)
| created_at   (DateTime)       |
+-------------------------------+
```

---

## 5. Relasi Antar Entity

```
+------------+    1:N    +-------------+
|   WARGA    |---------->|   HUNIAN    |
| (KK/Warga) |           | (Attribut   |
|            |           |  koordinat) |
+------------+           +------+------+
                                |
                                | (menampilkan marker)
                                v
                          +-----+------+
                          |   PETA     |
                          | (View)     |
                          +-----+------+
                                |
                    +-----------+-----------+
                    |                       |
            +-------+------+       +-------+------+
            |   HUNIAN     |       |  FASILITAS   |
            |   MARKER     |       |  MARKER      |
            +--------------+       +--------------+

WILAYAH (future) --> polygon untuk batas RT/RW
```

---

## 6. Struktur Data JSON (API Response Examples)

### Hunian dengan Koordinat
```json
{
  "id_hunian": "H001",
  "alamat": "Jl. Merdeka No. 10",
  "rt": "001",
  "rw": "002",
  "dusun": "Krajan",
  "tipe_hunian": "rumah",
  "status_kepemilikan": "milik_sendiri",
  "latitude": -6.917463,
  "longitude": 107.619122,
  "koord_status": "validated",
  "koord_source": "gps",
  "kepala_keluarga": {
    "id": 1,
    "nama": "Budi Santoso",
    "phone": "08123456789"
  }
}
```

### Fasilitas Lingkungan
```json
{
  "id_fasilitas": "F001",
  "nama": "Masjid Al-Falah",
  "kategori": "masjid",
  "deskripsi": "Masjid lingkungan RT 01",
  "latitude": -6.917500,
  "longitude": 107.619000,
  "alamat": "Jl. Merdeka No. 1",
  "rt": "001",
  "rw": "002",
  "penanggung_jawab": "Pak Haji Ahmad",
  "kontak": "08123456789",
  "jam_operasional": "05:00 - 21:00",
  "status_aktif": true
}
```

### Response Peta (List Marker)
```json
{
  "success": true,
  "data": {
    "hunian": [
      {
        "id_hunian": "H001",
        "latitude": -6.917463,
        "longitude": 107.619122,
        "tipe": "rumah",
        "kepala_keluarga": "Budi Santoso"
      }
    ],
    "fasilitas": [
      {
        "id_fasilitas": "F001",
        "nama": "Masjid Al-Falah",
        "kategori": "masjid",
        "latitude": -6.917500,
        "longitude": 107.619000
      }
    ],
    "pusat_peta": {
      "latitude": -6.9175,
      "longitude": 107.619
    }
  }
}
```

---

## 7. Aturan Domain (Domain Rules)

### Aturan 1: Koordinat Hunian
- Setiap hunian yang sudah didata koordinatnya dapat ditampilkan sebagai marker di peta.
- Hunian tanpa koordinat tidak muncul di peta.
- 1 hunian = maksimal 1 koordinat aktif.

### Aturan 2: Sumber Data
- Data warga dan hunian bersumber dari Modul Profil & Hunian saja.
- Data fasilitas bersumber dari tabel `fasilitas_lingkungan` (baru).
- Tidak ada sinkronisasi manual; semua data real-time dari database.

### Aturan 3: Status Validasi
- `pending`: Baru diinput, belum dicek pengurus.
- `validated`: Sudah dicek dan disetujui pengurus.
- `outdated`: Dianggap tidak akurat lagi, perlu pembaruan.

### Aturan 4: Privasi Marker
- Marker hunian di peta hanya menampilkan: ID hunian (terenkripsi/alias), tipe hunian, dan inisial kepala keluarga.
- Informasi detail (nama lengkap, nomor HP, alamat lengkap) hanya tersedia untuk marker milik sendiri atau untuk pengurus.

### Aturan 5: Batas POC
- Tidak ada polygon batas wilayah di POC.
- Tidak ada heatmap atau clustering di POC.
- Tidak ada geocoding otomatis di POC.
- Tidak ada batch import koordinat di POC.
