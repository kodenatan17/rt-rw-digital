# Fitur Iuran Warga

## Deskripsi
Fitur untuk manajemen tagihan iuran warga RT/RW seperti iuran sampah, keamanan, kebersihan. Warga bisa lihat tagihan aktif, riwayat pembayaran, dan konfirmasi pembayaran.

---

## User Flow

### Warga (User)
1. Buka menu **Iuran**
2. Lihat daftar tagihan:
   - **Belum Bayar**: Tagihan aktif yang perlu dibayar
   - **Sudah Bayar**: Riwayat pembayaran
3. Klik tagihan untuk lihat detail
4. Klik tombol **Bayar** → Upload bukti transfer atau konfirmasi pembayaran tunai
5. Admin validasi pembayaran → Status berubah jadi **Lunas**

### Admin
1. Buat tagihan iuran baru (bulk untuk seluruh warga atau per hunian)
2. Validasi pembayaran dari warga
3. Export laporan iuran (CSV/PDF)

---

## API Endpoints

### Warga
| Endpoint | Method | Keterangan |
|----------|--------|------------|
| `/iuran` | GET | Daftar tagihan & riwayat. Filter: `status`, `bulan`, `tahun` |
| `/iuran/{id}` | GET | Detail tagihan (jenis, nominal, periode, status, tanggal bayar) |
| `/iuran/{id}/bayar` | POST | Konfirmasi pembayaran (upload bukti, metode bayar) |

### Admin
| Endpoint | Method | Keterangan |
|----------|--------|------------|
| `/iuran/history` | GET | Riwayat pembayaran seluruh warga. Filter: `id_hunian`, `rt`, `rw` |
| `/iuran/export` | GET | Export data iuran ke CSV/PDF |
| `/iuran` | POST | Buat tagihan baru (batch/manual) |
| `/iuran/{id}/validate` | POST | Validasi pembayaran dari warga |

---

## Data Model

### Tagihan (Iuran)
```json
{
  "id": 101,
  "id_hunian": "H001",
  "nama_warga": "Budi Santoso",
  "jenis": "Sampah",
  "periode": "2026-06",
  "nominal": 50000,
  "status": "belum_bayar",
  "tanggal_jatuh_tempo": "2026-06-10",
  "tanggal_bayar": null,
  "metode_bayar": null,
  "bukti_bayar": null
}
```

### Status Iuran
- `belum_bayar`: Tagihan aktif, belum dibayar
- `lunas`: Sudah dibayar & divalidasi admin
- `pending`: Menunggu validasi admin
- `expired`: Lewat jatuh tempo

### Jenis Iuran
- `sampah`: Iuran sampah bulanan
- `keamanan`: Iuran keamanan (satpam, CCTV)
- `kebersihan`: Iuran kebersihan lingkungan
- `sosial`: Iuran sosial/kas RT
- `lainnya`: Iuran lainnya (bisa custom)

---

## Business Rules

1. **Tagihan Otomatis**: Admin bisa set auto-generate tagihan setiap bulan
2. **Notifikasi**: Warga dapat notifikasi push 3 hari sebelum jatuh tempo
3. **Denda**: Opsional, admin bisa set denda keterlambatan (mis: 5% per bulan)
4. **Metode Bayar**: 
   - Tunai ke admin
   - Transfer bank
   - E-wallet (opsional, jika integrasi payment gateway)
5. **Validasi Admin**: Setiap pembayaran perlu validasi admin sebelum status jadi `lunas`

---

## UI/UX Notes

### List Tagihan (Warga)
- Tab: **Belum Bayar** | **Sudah Bayar**
- Card per tagihan:
  - Badge status (merah: belum bayar, hijau: lunas)
  - Jenis iuran
  - Nominal
  - Periode
  - Jatuh tempo (jika belum bayar)

### Detail Tagihan
- Info lengkap: jenis, nominal, periode, status, jatuh tempo
- Jika belum bayar: Button **Bayar Sekarang**
- Jika lunas: Tampilkan tanggal bayar & metode pembayaran

### Form Pembayaran
- Upload bukti transfer (gambar)
- Pilih metode bayar: Tunai / Transfer
- Keterangan (opsional)

---

## Tech Stack Suggestion
- **State Management**: Riverpod / Bloc
- **API Client**: Dio + Retrofit
- **Image Upload**: `image_picker` + `http_multipart_request`
- **Filter/Sort**: Local filtering via state management

---

## Testing Checklist
- [ ] Warga bisa lihat daftar tagihan
- [ ] Filter status (belum bayar / lunas) bekerja
- [ ] Detail tagihan tampil lengkap
- [ ] Upload bukti bayar berhasil
- [ ] Notifikasi pembayaran muncul setelah konfirmasi
- [ ] Admin bisa validasi pembayaran
- [ ] Export data iuran (CSV/PDF) berfungsi
