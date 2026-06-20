# Workflow - Fitur Maps RT/RW Digital

Dokumen ini mendefinisikan alur kerja (workflow) dari sisi pengguna untuk fitur Maps.

---

## 1. Workflow Pendataan Lokasi Hunian oleh Pengurus RT

### Tujuan
Pengurus RT menambahkan atau memperbarui koordinat lokasi hunian warga di wilayah RT-nya.

### Alur

```
START
  |
  v
Pengurus login -> Menu Maps -> Mode Edit (otomatis untuk role pengurus)
  |
  v
Pilih Hunian (dari list / klik pada peta)
  |
  +---> [Jika belum punya koordinat]
  |       |
  |       v
  |     Tentukan lokasi:
  |         - Opsi A: Klik di peta (map picker)
  |         - Opsi B: Gunakan lokasi device saat ini (GPS)
  |         - Opsi C: Input manual lat/lng
  |       |
  |       v
  |     Simpan koordinat
  |       |
  |       v
  |     Status: "validated" (karena input oleh pengurus)
  |
  +---> [Jika sudah punya koordinat - perbarui]
          |
          v
        Geser marker di peta ke posisi baru
          |
          v
        Catat alasan perubahan (opsional)
          |
          v
        Simpan perubahan
          |
          v
        Riwayat perubahan tercatat
  |
  v
Marker tampil di peta warga
  |
  v
END
```

### Actor
Pengurus RT / Pengurus RW / Admin

### Pre-condition
- Hunian sudah terdaftar di sistem (modul Profil & Hunian)
- User memiliki role Pengurus (RT/RW/Admin)

### Post-condition
- Koordinat hunian tersimpan
- Marker hunian muncul di peta
- Warga dapat melihat marker huniannya sendiri

---

## 2. Workflow Validasi Koordinat oleh Pengurus (Input Warga)

### Tujuan
Warga mengusulkan koordinat huniannya, lalu pengurus memvalidasi.

### Alur

```
START
  |
  v
Warga login -> Menu Profil & Hunian -> Edit Lokasi
  |
  v
Tentukan lokasi (map picker / GPS / manual)
  |
  v
Simpan -> Status: "pending"
  |
  v
Notifikasi dikirim ke Pengurus RT:
  "Ada usulan lokasi baru dari [Nama Warga]"
  |
  v
Pengurus buka menu Maps -> Tab "Validasi" -> Lihat usulan
  |
  v
Cek lokasi usulan:
  |
  +---> [Setuju] -> Setujui -> Status -> "validated"
  |                  |
  |                  v
  |                Marker tampil permanen
  |
  +---> [Tolak] -> Tolak + beri alasan
  |                 |
  |                 v
  |               Status -> "pending" (dicatat ditolak)
  |               Notifikasi ke warga: "Lokasi ditolak, alasan: ..."
  |
  +---> [Revisi] -> Geser marker ke lokasi benar
                    |
                    v
                  Status -> "validated" (koordinat hasil revisi pengurus)
  |
  v
END
```

### Actor
Warga (input usulan), Pengurus RT (validasi)

### Pre-condition
- Warga sudah login dan memiliki hunian terdaftar
- Warga mengakses fitus edit lokasi dari modul Profil

---

## 3. Workflow Pendataan Fasilitas Lingkungan

### Tujuan
Pengurus RT/RW menambahkan fasilitas lingkungan ke peta.

### Alur

```
START
  |
  v
Pengurus login -> Menu Maps -> Mode Edit
  |
  v
Klik tombol "Tambah Fasilitas"
  |
  v
Pilih kategori fasilitas (dropdown):
  - Masjid, Pos Keamanan, CCTV, Taman, dll
  |
  v
Input data fasilitas:
  - Nama (wajib)
  - Deskripsi (opsional)
  - Tentukan lokasi (klik peta / GPS / manual)
  - Penanggung Jawab (opsional)
  - Kontak (opsional)
  - Jam operasional (opsional)
  - Upload foto (opsional)
  |
  v
Simpan
  |
  v
Status: langsung "aktif" (karena input oleh pengurus)
  |
  v
Marker fasilitas muncul di peta
  |
  v
END
```

### Actor
Pengurus RT / Pengurus RW / Admin

### Pre-condition
- Fasilitas belum terdaftar di sistem

### Post-condition
- Fasilitas tersimpan di tabel FASILITAS_LINGKUNGAN
- Marker fasilitas muncul di peta
- Warga dapat melihat detail fasilitas

---

## 4. Workflow Peta Warga (View Only)

### Tujuan
Warga melihat peta lingkungan RT/RW.

### Alur

```
START
  |
  v
Warga login -> Menu "Peta RT"
  |
  v
Peta terbuka dengan:
  - Pusat peta: koordinat RT/RW warga
  - Zoom level: 15 (cakupan lingkungan)
  |
  v
Tampilkan marker:
  - Marker hunian (icon rumah) - semua hunian di RT
  - Marker fasilitas (icon sesuai kategori)
  |
  v
[Interaksi]:
  - Tap marker hunian -> Lihat info singkat (tipe hunian, inisial KK)
  - Tap marker sendiri -> Lihat info detail (alamat, nama KK)
  - Tap marker fasilitas -> Lihat detail (nama, kategori, penanggung jawab)
  - Tap info fasilitas -> Dapat menelepon/menulis WA kontak (jika ada)
  |
  v
END
```

### Keterangan Privasi
- Marker tetangga: tidak menampilkan nama lengkap, hanya "Rumah"
- Marker sendiri: menampilkan "Rumah Saya" + detail
- Marker fasilitas: menampilkan informasi publik lengkap

---

## 5. Workflow Perubahan Data Fasilitas

### Tujuan
Pengurus mengubah data atau lokasi fasilitas lingkungan.

### Alur

```
START
  |
  v
Pengurus login -> Menu Maps -> Mode Edit
  |
  v
Tap marker fasilitas -> Detail -> Tombol "Edit"
  |
  v
Ubah data yang diperlukan:
  - Nama, kategori, deskripsi, lokasi, penanggung jawab, dll
  |
  v
Simpan perubahan
  |
  v
Riwayat perubahan tercatat (siapa, kapan, apa yang diubah)
  |
  v
Marker fasilitas diperbarui di peta
  |
  v
END
```

---

## 6. Workflow Penghapusan Koordinat Fasilitas

### Tujuan
Pengurus menghapus fasilitas (misal pos kamling sudah tidak aktif).

### Alur

```
START
  |
  v
Pengurus login -> Menu Maps -> Mode Edit
  |
  v
Tap marker fasilitas -> Detail -> Tombol "Hapus"
  |
  v
Konfirmasi: "Hapus [nama fasilitas]?"
  |
  +---> [Ya] -> Fasilitas dihapus (soft delete: status_aktif = false)
  |               Marker tidak muncul lagi di peta warga
  |               Pengurus masih bisa melihat di "Arsip Fasilitas"
  |
  +---> [Tidak] -> Kembali
  |
  v
END
```

---

## 7. Workflow Penghapusan Koordinat Hunian

Hunian tidak bisa dihapus di modul Maps. Koordinat hanya dinonaktifkan (dikosongkan) jika:

1. Hunian dihapus dari Modul Profil & Hunian (data warga pindah/dihapus)
2. Koordinat dianggap salah dan perlu diinput ulang

Jika koordinat dikosongkan, marker hunian tidak tampil sampai ada koordinat baru yang divalidasi.

---

## 8. Rangkuman Alur Workflow

| Workflow | Actor | Aksi | Status Awal | Status Akhir |
|----------|-------|------|-------------|--------------|
| 1. Pendataan lokasi hunian | Pengurus | Input koordinat | Belum ada | validated |
| 2. Validasi usulan warga | Warga -> Pengurus | Input -> Validasi | pending -> validated/ditolak | validated/ditolak |
| 3. Tambah fasilitas | Pengurus | Input lengkap | Belum ada | aktif |
| 4. Peta warga | Warga | View only | - | - |
| 5. Edit fasilitas | Pengurus | Update data | Aktif | Aktif (diperbarui) |
| 6. Hapus fasilitas | Pengurus | Soft delete | Aktif | Nonaktif |
