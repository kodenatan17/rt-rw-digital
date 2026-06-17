# Fitur Kas RT/RW

## Deskripsi
Fitur untuk manajemen keuangan kas RT/RW. Mencatat pemasukan, pengeluaran, dan menampilkan saldo kas secara real-time. Fitur ini khusus untuk **Admin/Pengurus RT/RW**.

---

## User Flow

### Admin/Pengurus
1. Buka menu **Kas RT/RW**
2. Lihat dashboard:
   - **Saldo Total**
   - **Pemasukan Bulan Ini**
   - **Pengeluaran Bulan Ini**
   - **Grafik Arus Kas** (opsional)
3. Lihat riwayat mutasi (pemasukan & pengeluaran)
4. Tambah mutasi manual (catat pemasukan/pengeluaran)
5. Filter mutasi berdasarkan:
   - Tipe: Masuk / Keluar
   - Kategori
   - Tanggal / Periode
6. Export laporan kas (PDF/Excel)

---

## API Endpoints

| Endpoint | Method | Keterangan |
|----------|--------|------------|
| `/kas` | GET | Ringkasan saldo & cashflow bulan berjalan |
| `/kas/history` | GET | Riwayat mutasi kas. Filter: `tipe`, `kategori`, `tanggal_dari`, `tanggal_sampai` |
| `/kas/summary` | GET | Rekapitulasi bulanan/tahunan (total masuk, keluar, saldo) |
| `/kas/mutasi` | POST | Catat mutasi kas manual (Admin) |
| `/kas/mutasi/{id}` | GET | Detail mutasi kas |
| `/kas/mutasi/{id}` | PUT | Edit mutasi (Admin) |
| `/kas/mutasi/{id}` | DELETE | Hapus mutasi (Admin) |
| `/kas/export` | GET | Export laporan kas (PDF/Excel) |

---

## Data Model

### Ringkasan Kas (KasSummary)
```json
{
  "saldo_total": 15000000,
  "total_masuk_bulan_ini": 5000000,
  "total_keluar_bulan_ini": 2000000,
  "bulan": "2026-06"
}
```

### Mutasi Kas (KasMutasi)
```json
{
  "id": 501,
  "tanggal": "2026-06-15",
  "tipe": "masuk",
  "kategori": "iuran",
  "nominal": 500000,
  "keterangan": "Iuran warga periode Juni 2026",
  "penanggung_jawab": "Admin RT",
  "created_at": "2026-06-15T10:30:00Z"
}
```

### Tipe Mutasi
- `masuk`: Pemasukan (iuran, donasi, dll)
- `keluar`: Pengeluaran (operasional, pembelian, dll)

### Kategori Mutasi

**Pemasukan:**
- `iuran`: Dari iuran warga
- `donasi`: Donasi dari warga/pihak luar
- `usaha`: Hasil usaha RT (mis: sewa tempat)
- `lainnya`: Pemasukan lainnya

**Pengeluaran:**
- `operasional`: Biaya operasional RT (listrik, air, dll)
- `gaji`: Gaji petugas (satpam, cleaning service)
- `pembelian`: Pembelian barang/peralatan
- `acara`: Biaya acara warga
- `donasi_keluar`: Donasi ke pihak luar
- `lainnya`: Pengeluaran lainnya

---

## Business Rules

1. **Role Access**: Hanya Admin/Pengurus yang bisa akses fitur kas
2. **Auto-Record**: Pembayaran iuran otomatis tercatat sebagai pemasukan
3. **Approval**: Mutasi pengeluaran > Rp 1.000.000 perlu approval 2 admin (opsional)
4. **Audit Trail**: Setiap mutasi tercatat siapa yang input & kapan
5. **Saldo Real-time**: Saldo dihitung otomatis dari seluruh mutasi
6. **Laporan Berkala**: Export laporan otomatis setiap akhir bulan

---

## UI/UX Notes

### Dashboard Kas
- Card summary:
  - Saldo Total (font besar, hijau)
  - Pemasukan Bulan Ini (hijau)
  - Pengeluaran Bulan Ini (merah)
- Grafik line chart (opsional): Tren kas 6 bulan terakhir
- Quick action button: **+ Tambah Mutasi**

### Riwayat Mutasi
- List mutasi:
  - Icon/badge: Masuk (hijau ↑) / Keluar (merah ↓)
  - Tanggal
  - Kategori
  - Nominal (+ untuk masuk, - untuk keluar)
  - Keterangan singkat
- Filter floating button: Tipe, Kategori, Periode

### Form Mutasi Baru
- Pilih tipe: Masuk / Keluar
- Pilih kategori (dropdown)
- Input nominal
- Input keterangan
- Pilih tanggal (default: hari ini)
- Button: **Simpan**

### Laporan Kas
- Filter periode: Bulan/Tahun
- Tampilkan:
  - Total pemasukan (per kategori)
  - Total pengeluaran (per kategori)
  - Saldo awal & saldo akhir
- Button: **Export PDF** / **Export Excel**

---

## Tech Stack Suggestion
- **Chart**: `fl_chart` untuk grafik arus kas
- **Date Picker**: `flutter_datetime_picker`
- **Export**: `pdf` package untuk generate PDF, `excel` package untuk Excel
- **Number Format**: `intl` untuk format rupiah

---

## Testing Checklist
- [ ] Dashboard kas tampil data real-time
- [ ] Tambah mutasi masuk berhasil
- [ ] Tambah mutasi keluar berhasil
- [ ] Filter mutasi (tipe, kategori, tanggal) bekerja
- [ ] Saldo update otomatis setelah input mutasi
- [ ] Detail mutasi tampil lengkap
- [ ] Edit & hapus mutasi berfungsi (dengan konfirmasi)
- [ ] Export laporan PDF/Excel berhasil
- [ ] Pembayaran iuran otomatis tercatat sebagai pemasukan
