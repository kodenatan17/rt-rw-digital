# API Contract - Fitur Maps RT/RW Digital

Dokumen ini mendefinisikan seluruh API endpoint yang diperlukan untuk fitur Maps.

---

## 1. Endpoint Maps - Peta RT/RW

### `GET /maps/peta`
**Deskripsi:** Mengambil data peta lengkap (marker hunian + fasilitas) untuk RT/RW pengguna.
**Role:** Warga, Pengurus RT/RW, Admin
**Auth:** Required (Bearer Token)

**Query Parameters:**
| Parameter | Type | Required | Default | Deskripsi |
|-----------|------|----------|---------|-----------|
| `rt` | String | No | RT user | Filter berdasarkan RT tertentu |
| `rw` | String | No | RW user | Filter berdasarkan RW tertentu |
| `include_pending` | Boolean | No | false | Tampilkan hunian dengan status pending (hanya pengurus) |

**Response Success (200):**
```json
{
  "success": true,
  "data": {
    "pusat_peta": {
      "latitude": -6.9175,
      "longitude": 107.619
    },
    "hunian": [
      {
        "id_hunian": "H001",
        "latitude": -6.917463,
        "longitude": 107.619122,
        "tipe_hunian": "rumah",
        "status_koord": "validated",
        "inisial_kk": "BS",
        "is_mine": true
      }
    ],
    "fasilitas": [
      {
        "id_fasilitas": "F001",
        "nama": "Masjid Al-Falah",
        "kategori": "masjid",
        "latitude": -6.9175,
        "longitude": 107.619
      }
    ]
  }
}
```

**Response Error (403):**
```json
{
  "success": false,
  "message": "Akses ditolak"
}
```

---

### `GET /maps/hunian/{id_hunian}`
**Deskripsi:** Mengambil detail koordinat hunian tertentu.
**Role:** Pemilik hunian, Pengurus RT/RW (sesuai wilayah), Admin
**Auth:** Required

**Path Parameters:**
| Parameter | Type | Required | Deskripsi |
|-----------|------|----------|-----------|
| `id_hunian` | String | Yes | ID hunian |

**Response Success (200):**
```json
{
  "success": true,
  "data": {
    "id_hunian": "H001",
    "alamat": "Jl. Merdeka No. 10",
    "rt": "001",
    "rw": "002",
    "tipe_hunian": "rumah",
    "latitude": -6.917463,
    "longitude": 107.619122,
    "koord_status": "validated",
    "koord_source": "gps",
    "koord_updated_at": "2026-06-15T10:30:00Z",
    "kepala_keluarga": {
      "id": 1,
      "nama": "Budi Santoso",
      "phone": "08123456789"
    }
  }
}
```

**Response Error (403):**
```json
{
  "success": false,
  "message": "Anda tidak memiliki akses ke data hunian ini"
}
```

---

## 2. Endpoint Pendataan Koordinat (Pengurus)

### `POST /maps/hunian/{id_hunian}/koordinat`
**Deskripsi:** Menambahkan atau memperbarui koordinat hunian (oleh pengurus).
**Role:** Pengurus RT/RW (sesuai wilayah), Admin
**Auth:** Required

**Request Body:**
```json
{
  "latitude": -6.917463,
  "longitude": 107.619122,
  "sumber": "map_picker",
  "alasan_perubahan": "Koordinat salah lokasi, diperbarui sesuai alamat fisik"
}
```

**Field:**
| Field | Type | Required | Enum/Validasi | Deskripsi |
|-------|------|----------|---------------|-----------|
| `latitude` | double | Yes | -90 s.d. 90 | Latitude |
| `longitude` | double | Yes | -180 s.d. 180 | Longitude |
| `sumber` | String | No | manual, gps, map_picker | Metode input (default: map_picker) |
| `alasan_perubahan` | String | No | Max 255 karakter | Jika update koordinat lama |

**Response Success (200):**
```json
{
  "success": true,
  "message": "Koordinat hunian berhasil diperbarui",
  "data": {
    "id_hunian": "H001",
    "latitude": -6.917463,
    "longitude": 107.619122,
    "koord_status": "validated"
  }
}
```

**Response Error (403):**
```json
{
  "success": false,
  "message": "Anda tidak memiliki akses untuk mengelola hunian di RT/RW ini"
}
```

---

### `DELETE /maps/hunian/{id_hunian}/koordinat`
**Deskripsi:** Menghapus koordinat hunian (koordinat dikosongkan).
**Role:** Pengurus RT/RW, Admin
**Auth:** Required

**Response Success (200):**
```json
{
  "success": true,
  "message": "Koordinat hunian berhasil dihapus"
}
```

---

## 3. Endpoint Usulan Lokasi (Warga)

### `POST /maps/hunian/usulan`
**Deskripsi:** Warga mengusulkan koordinat huniannya sendiri (status: pending).
**Role:** Warga (Kepala Keluarga)
**Auth:** Required

**Request Body:**
```json
{
  "id_hunian": "H001",
  "latitude": -6.917463,
  "longitude": 107.619122,
  "sumber": "gps"
}
```

**Response Success (200):**
```json
{
  "success": true,
  "message": "Usulan koordinat berhasil dikirim. Menunggu validasi pengurus RT.",
  "data": {
    "id_hunian": "H001",
    "koord_status": "pending"
  }
}
```

**Business Rule:**
- Warga hanya bisa mengusulkan koordinat huniannya sendiri
- Status otomatis `pending`

---

### `GET /maps/usulan`
**Deskripsi:** Mengambil daftar usulan koordinat yang perlu divalidasi.
**Role:** Pengurus RT/RW, Admin
**Auth:** Required

**Query Parameters:**
| Parameter | Type | Required | Deskripsi |
|-----------|------|----------|-----------|
| `status` | String | No | Filter: `pending`, `rejected`, `all` (default: pending) |
| `rt` | String | No | Filter berdasarkan RT |

**Response Success (200):**
```json
{
  "success": true,
  "data": [
    {
      "id_hunian": "H002",
      "alamat": "Jl. Merdeka No. 11",
      "kepala_keluarga": "Andi Wijaya",
      "latitude": -6.917500,
      "longitude": 107.619100,
      "koord_status": "pending",
      "diusulkan_pada": "2026-06-15T08:00:00Z"
    }
  ]
}
```

---

### `POST /maps/usulan/{id_hunian}/validasi`
**Deskripsi:** Pengurus memvalidasi usulan koordinat warga.
**Role:** Pengurus RT/RW, Admin
**Auth:** Required

**Request Body:**
```json
{
  "aksi": "setuju",
  "latitude": -6.917500,
  "longitude": 107.619100,
  "catatan": "Lokasi sudah sesuai dengan alamat fisik"
}
```

**Field:**
| Field | Type | Required | Enum/Validasi | Deskripsi |
|-------|------|----------|---------------|-----------|
| `aksi` | String | Yes | `setuju`, `tolak`, `revisi` | Aksi validasi |
| `latitude` | double | Conditional | - | Wajib jika aksi = `revisi` |
| `longitude` | double | Conditional | - | Wajib jika aksi = `revisi` |
| `catatan` | String | No | Max 500 karakter | Alasan/catatan |

**Response Success (200):**
```json
{
  "success": true,
  "message": "Usulan koordinat berhasil disetujui"
}
```

**Business Logic:**
- `setuju`: Usulan disetujui, status = `validated`, koordinat sesuai usulan warga.
- `tolak`: Usulan ditolak, status = `rejected`, kirim notifikasi + catatan ke warga.
- `revisi`: Pengurus mengubah koordinat sesuai lokasi benar, status = `validated`.

---

## 4. Endpoint Fasilitas Lingkungan

### `GET /maps/fasilitas`
**Deskripsi:** Mengambil daftar fasilitas lingkungan.
**Role:** Semua user (Warga, Pengurus, Admin)
**Auth:** Required

**Query Parameters:**
| Parameter | Type | Required | Deskripsi |
|-----------|------|----------|-----------|
| `kategori` | String | No | Filter kategori (masjid, pos_keamanan, dll) |
| `rt` | String | No | Filter RT |
| `rw` | String | No | Filter RW |
| `status_aktif` | Boolean | No | Default: true (hanya pengurus bisa lihat yang nonaktif) |

**Response Success (200):**
```json
{
  "success": true,
  "data": [
    {
      "id_fasilitas": "F001",
      "nama": "Masjid Al-Falah",
      "kategori": "masjid",
      "latitude": -6.9175,
      "longitude": 107.619,
      "penanggung_jawab": "Pak Haji Ahmad",
      "kontak": "08123456789",
      "status_aktif": true
    }
  ]
}
```

---

### `GET /maps/fasilitas/{id_fasilitas}`
**Deskripsi:** Mengambil detail fasilitas lingkungan.
**Role:** Semua user
**Auth:** Required

**Response Success (200):**
```json
{
  "success": true,
  "data": {
    "id_fasilitas": "F001",
    "nama": "Masjid Al-Falah",
    "kategori": "masjid",
    "deskripsi": "Masjid lingkungan RT 01 RW 02",
    "latitude": -6.9175,
    "longitude": 107.619,
    "alamat": "Jl. Merdeka No. 1",
    "rt": "001",
    "rw": "002",
    "foto": "https://storage.example.com/fasilitas/f001.jpg",
    "penanggung_jawab": "Pak Haji Ahmad",
    "kontak": "08123456789",
    "jam_operasional": "05:00 - 21:00",
    "status_aktif": true,
    "created_at": "2026-01-10T12:00:00Z"
  }
}
```

---

### `POST /maps/fasilitas`
**Deskripsi:** Menambahkan fasilitas lingkungan baru.
**Role:** Pengurus RT/RW, Admin
**Auth:** Required

**Request Body:**
```json
{
  "nama": "Pos Keamanan RT 01",
  "kategori": "pos_keamanan",
  "deskripsi": "Pos keamanan lingkungan",
  "latitude": -6.9176,
  "longitude": 107.6191,
  "alamat": "Depan gang utama",
  "rt": "001",
  "rw": "002",
  "penanggung_jawab": "Pak Joko",
  "kontak": "08123456788",
  "jam_operasional": "18:00 - 06:00",
  "foto": "https://storage.example.com/fasilitas/pos.jpg"
}
```

**Field:**
| Field | Type | Required | Deskripsi |
|-------|------|----------|-----------|
| `nama` | String | Yes | Nama fasilitas |
| `kategori` | String (Enum) | Yes | Kategori dari master data |
| `latitude` | double | Yes | Koordinat latitude |
| `longitude` | double | Yes | Koordinat longitude |
| `deskripsi` | String | No | Deskripsi lengkap |
| `alamat` | String | No | Alamat teks |
| `rt` | String | Yes | RT lokasi fasilitas |
| `rw` | String | Yes | RW lokasi fasilitas |
| `penanggung_jawab` | String | No | Nama penanggung jawab |
| `kontak` | String | No | Nomor HP/WA |
| `jam_operasional` | String | No | Jam buka |
| `foto` | String (URL) | No | URL foto fasilitas |

**Response Success (201):**
```json
{
  "success": true,
  "message": "Fasilitas berhasil ditambahkan",
  "data": {
    "id_fasilitas": "F002",
    "nama": "Pos Keamanan RT 01"
  }
}
```

---

### `PUT /maps/fasilitas/{id_fasilitas}`
**Deskripsi:** Memperbarui data fasilitas.
**Role:** Pengurus RT/RW, Admin
**Auth:** Required

**Request Body:** (Sama seperti POST, semua field opsional untuk update)

**Response Success (200):**
```json
{
  "success": true,
  "message": "Fasilitas berhasil diperbarui"
}
```

---

### `DELETE /maps/fasilitas/{id_fasilitas}`
**Deskripsi:** Menonaktifkan fasilitas (soft delete: `status_aktif = false`).
**Role:** Pengurus RT/RW, Admin
**Auth:** Required

**Response Success (200):**
```json
{
  "success": true,
  "message": "Fasilitas berhasil dinonaktifkan"
}
```

---

## 5. Endpoint Master Data

### `GET /maps/kategori-fasilitas`
**Deskripsi:** Mengambil daftar kategori fasilitas.
**Role:** Semua user
**Auth:** Required

**Response Success (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "masjid",
      "nama": "Masjid / Mushola",
      "icon": "mosque"
    },
    {
      "id": "pos_keamanan",
      "nama": "Pos Keamanan",
      "icon": "shield"
    }
  ]
}
```

---

## 6. Integrasi dengan API Existing

### Modifikasi: `GET /profil/me`
**Perubahan:** Menambahkan field koordinat di response `hunian`.

**Response Baru (200):**
```json
{
  "success": true,
  "data": {
    "kepala_keluarga": { ... },
    "hunian": {
      "id_hunian": "H001",
      "alamat": "Jl. Merdeka No. 10",
      "rt": "001",
      "rw": "002",
      "latitude": -6.917463,
      "longitude": 107.619122,
      "koord_status": "validated"
    },
    "anggota_keluarga": [ ... ]
  }
}
```

---

## 7. Rangkuman Endpoint

| Endpoint | Method | Role | Deskripsi |
|----------|--------|------|-----------|
| `/maps/peta` | GET | Semua | Ambil data peta (marker hunian + fasilitas) |
| `/maps/hunian/{id}` | GET | Pemilik/Pengurus | Detail koordinat hunian |
| `/maps/hunian/{id}/koordinat` | POST | Pengurus | Input/update koordinat hunian |
| `/maps/hunian/{id}/koordinat` | DELETE | Pengurus | Hapus koordinat hunian |
| `/maps/hunian/usulan` | POST | Warga | Usulkan koordinat hunian |
| `/maps/usulan` | GET | Pengurus | Daftar usulan pending |
| `/maps/usulan/{id}/validasi` | POST | Pengurus | Validasi usulan |
| `/maps/fasilitas` | GET | Semua | Daftar fasilitas |
| `/maps/fasilitas/{id}` | GET | Semua | Detail fasilitas |
| `/maps/fasilitas` | POST | Pengurus | Tambah fasilitas |
| `/maps/fasilitas/{id}` | PUT | Pengurus | Update fasilitas |
| `/maps/fasilitas/{id}` | DELETE | Pengurus | Hapus fasilitas |
| `/maps/kategori-fasilitas` | GET | Semua | Master kategori |
