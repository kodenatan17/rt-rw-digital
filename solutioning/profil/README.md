# Fitur Profil & Hunian

## Deskripsi
Fitur untuk manajemen data profil warga sebagai kepala keluarga, data hunian/tempat tinggal, dan data anggota keluarga. **Tidak menggunakan NIK/KTP**, fokus pada data hunian.

---

## User Flow

### Warga
1. Buka menu **Profil**
2. Lihat data:
   - **Profil Kepala Keluarga**: Nama, nomor HP, email, foto profil
   - **Data Hunian**: ID Hunian, alamat lengkap, RT/RW, tipe hunian, status kepemilikan
   - **Anggota Keluarga**: List anggota (nama, relasi, tanggal lahir)
3. Edit profil pribadi (nama, email, foto)
4. Edit data hunian (alamat, tipe, status kepemilikan)
5. Tambah/Edit/Hapus anggota keluarga

---

## API Endpoints

### Profil & Hunian
| Endpoint | Method | Keterangan |
|----------|--------|------------|
| `/profil/me` | GET | Data lengkap: kepala keluarga + hunian + anggota keluarga |
| `/profil/me` | PUT | Update profil pribadi (nama, email, avatar, nomor HP) |
| `/profil/me/hunian` | PUT | Update data hunian (alamat, tipe, status kepemilikan) |

### Anggota Keluarga
| Endpoint | Method | Keterangan |
|----------|--------|------------|
| `/profil/me/anggota` | GET | List anggota keluarga |
| `/profil/me/anggota` | POST | Tambah anggota baru |
| `/profil/me/anggota/{id}` | GET | Detail anggota |
| `/profil/me/anggota/{id}` | PUT | Edit data anggota |
| `/profil/me/anggota/{id}` | DELETE | Hapus anggota |

---

## Data Model

### Profil Lengkap
```json
{
  "kepala_keluarga": {
    "id": 1,
    "nama": "Budi Santoso",
    "phone": "08123456789",
    "email": "budi@example.com",
    "avatar": "https://storage.example.com/avatars/budi.jpg",
    "tanggal_lahir": "1985-05-15"
  },
  "hunian": {
    "id_hunian": "H001",
    "alamat": "Jl. Merdeka No. 10",
    "rt": "001",
    "rw": "002",
    "dusun": "Krajan",
    "tipe_hunian": "rumah",
    "status_kepemilikan": "milik_sendiri",
    "luas_tanah": 150,
    "luas_bangunan": 100
  },
  "anggota_keluarga": [
    {
      "id": 101,
      "nama": "Siti Rahayu",
      "relasi": "istri",
      "tanggal_lahir": "1988-08-20"
    },
    {
      "id": 102,
      "nama": "Andi Santoso",
      "relasi": "anak",
      "tanggal_lahir": "2010-03-12"
    }
  ]
}
```

### Tipe Hunian
- `rumah`: Rumah pribadi
- `kontrakan`: Rumah kontrakan
- `kos`: Kos-kosan
- `apartemen`: Apartemen/flat
- `lainnya`: Tipe lainnya

### Status Kepemilikan
- `milik_sendiri`: Milik sendiri (pemilik)
- `kontrak`: Kontrak/sewa tahunan
- `sewa`: Sewa bulanan
- `menumpang`: Menumpang (keluarga/teman)
- `lainnya`: Status lainnya

### Relasi Anggota Keluarga
- `istri`: Istri
- `suami`: Suami
- `anak`: Anak
- `orangtua`: Orang tua
- `saudara`: Saudara kandung
- `mertua`: Mertua
- `keponakan`: Keponakan
- `lainnya`: Relasi lainnya

---

## Business Rules

1. **ID Hunian**: Setiap hunian punya ID unik (auto-generate atau manual oleh admin)
2. **Kepala Keluarga**: 1 akun = 1 kepala keluarga = 1 hunian
3. **Anggota Keluarga**: Unlimited, tapi wajib isi nama & relasi (tanggal lahir opsional)
4. **Validasi Data**: Alamat & RT/RW wajib diisi
5. **Foto Profil**: Opsional, max 2MB, format JPG/PNG
6. **Privasi**: Data profil hanya bisa dilihat oleh diri sendiri & admin

---

## UI/UX Notes

### Halaman Profil (Main)
- Header: Foto profil + Nama kepala keluarga
- Section 1: **Data Pribadi**
  - Nama
  - Nomor HP
  - Email
  - Tanggal lahir
  - Button: **Edit Profil**
- Section 2: **Data Hunian**
  - ID Hunian (read-only, badge)
  - Alamat lengkap
  - RT / RW
  - Tipe hunian
  - Status kepemilikan
  - Button: **Edit Hunian**
- Section 3: **Anggota Keluarga**
  - List card anggota:
    - Nama
    - Relasi
    - Umur (dihitung dari tanggal lahir)
  - Button floating: **+ Tambah Anggota**

### Form Edit Profil
- Upload foto (dengan crop & compress)
- Input:
  - Nama
  - Email
  - Nomor HP (read-only, tidak bisa diubah - atau dengan OTP jika mau diubah)
  - Tanggal lahir (date picker)
- Button: **Simpan**

### Form Edit Hunian
- Input:
  - Alamat lengkap (textarea)
  - RT (number)
  - RW (number)
  - Dusun (optional)
  - Tipe hunian (dropdown)
  - Status kepemilikan (dropdown)
  - Luas tanah (number, optional)
  - Luas bangunan (number, optional)
- Button: **Simpan**

### Form Tambah/Edit Anggota Keluarga
- Input:
  - Nama
  - Relasi (dropdown)
  - Tanggal lahir (date picker, optional)
- Button: **Simpan** / **Hapus** (jika edit)

---

## Tech Stack Suggestion
- **Image**: 
  - `image_picker` untuk ambil gambar
  - `image_cropper` untuk crop
  - `flutter_image_compress` untuk compress
- **Form**: 
  - `flutter_form_builder` untuk form management
  - `flutter_datetime_picker` untuk date picker
- **Validation**: Form validation dengan `validators`

---

## Testing Checklist
- [ ] Halaman profil tampil data lengkap (kepala keluarga + hunian + anggota)
- [ ] Edit profil pribadi berhasil
- [ ] Upload & update foto profil berhasil
- [ ] Edit data hunian berhasil
- [ ] Tambah anggota keluarga berhasil
- [ ] Edit anggota keluarga berhasil
- [ ] Hapus anggota keluarga berhasil (dengan konfirmasi)
- [ ] Validasi form bekerja (wajib isi nama, alamat, RT/RW)
- [ ] Data tersimpan & tampil kembali setelah logout-login
