# Fitur Acara Warga

## Deskripsi
Fitur untuk manajemen acara/kegiatan warga RT/RW. Warga bisa lihat kalender acara bulanan, detail acara, dan konfirmasi kehadiran (RSVP).

---

## User Flow

### Warga
1. Buka menu **Acara** atau lihat di dashboard (upcoming events)
2. Lihat kalender acara bulan ini
3. Klik acara untuk lihat detail:
   - Nama acara
   - Deskripsi
   - Tanggal & waktu
   - Lokasi
   - Jumlah peserta (RSVP)
4. Klik tombol RSVP: **Hadir** / **Tidak Hadir** / **Mungkin**
5. Notifikasi pengingat 1 hari sebelum acara (jika RSVP: Hadir)

### Admin
1. Buat acara baru
2. Edit/Hapus acara
3. Lihat daftar peserta (yang RSVP)
4. Export daftar kehadiran

---

## API Endpoints

### Warga
| Endpoint | Method | Keterangan |
|----------|--------|------------|
| `/acara` | GET | Kalender acara. Filter: `bulan`, `tahun` |
| `/acara/{id}` | GET | Detail acara (nama, deskripsi, tanggal, lokasi, total peserta) |
| `/acara/{id}/rsvp` | POST | Konfirmasi kehadiran. Body: `status` (hadir/tidak/mungkin) |
| `/acara/{id}/rsvp` | GET | Status RSVP saya |

### Admin
| Endpoint | Method | Keterangan |
|----------|--------|------------|
| `/acara` | POST | Buat acara baru |
| `/acara/{id}` | PUT | Edit acara |
| `/acara/{id}` | DELETE | Hapus acara |
| `/acara/{id}/peserta` | GET | Daftar peserta (yang RSVP) |
| `/acara/{id}/export` | GET | Export daftar kehadiran (PDF/Excel) |

---

## Data Model

### Acara (Summary)
```json
{
  "id": 301,
  "nama": "Kerja Bakti RT 01",
  "tanggal": "2026-06-20",
  "waktu_mulai": "08:00",
  "waktu_selesai": "12:00",
  "lokasi": "Balai RT 01",
  "banner": "https://storage.example.com/acara/kerja-bakti.jpg",
  "total_peserta": 45
}
```

### Acara (Detail)
```json
{
  "id": 301,
  "nama": "Kerja Bakti RT 01",
  "deskripsi": "Gotong royong membersihkan lingkungan RT 01. Diharapkan seluruh warga dapat hadir.",
  "tanggal": "2026-06-20",
  "waktu_mulai": "08:00",
  "waktu_selesai": "12:00",
  "lokasi": "Balai RT 01",
  "banner": "https://storage.example.com/acara/kerja-bakti.jpg",
  "status_rsvp_saya": "hadir",
  "total_peserta": 45,
  "peserta_hadir": 40,
  "peserta_tidak": 3,
  "peserta_mungkin": 2,
  "created_by": "Admin RT",
  "created_at": "2026-06-01T10:00:00Z"
}
```

### RSVP Status
- `hadir`: Akan hadir
- `tidak`: Tidak bisa hadir
- `mungkin`: Belum pasti
- `null`: Belum RSVP

---

## Business Rules

1. **Visibilitas**: Semua warga bisa lihat kalender & detail acara
2. **RSVP**: Warga bisa ubah status RSVP sampai 1 hari sebelum acara
3. **Notifikasi**:
   - Notifikasi push saat ada acara baru
   - Reminder 1 hari sebelum acara (untuk yang RSVP: Hadir)
4. **Banner**: Admin bisa upload banner acara (opsional)
5. **Recurring Event**: Admin bisa set acara berulang (mis: arisan bulanan) - opsional

---

## UI/UX Notes

### Kalender Acara
- View: List atau Calendar view (tab toggle)
- List view:
  - Card per acara:
    - Banner/icon
    - Nama acara
    - Tanggal & waktu
    - Badge RSVP status saya
- Calendar view:
  - Kalender bulanan
  - Titik/badge di tanggal yang ada acara
  - Klik tanggal → List acara di tanggal tersebut

### Detail Acara
- Header: Banner acara (jika ada)
- Info acara:
  - Nama
  - Deskripsi lengkap
  - Tanggal & waktu
  - Lokasi (dengan link Google Maps - opsional)
- Statistik peserta:
  - Total RSVP
  - Breakdown: Hadir (hijau), Tidak (merah), Mungkin (kuning)
- Tombol RSVP:
  - 3 button: **Hadir** / **Tidak** / **Mungkin**
  - Button aktif sesuai status RSVP saya
  - Bisa ubah status (klik button lain)

### Form Buat Acara (Admin)
- Input:
  - Nama acara
  - Deskripsi
  - Tanggal & waktu (mulai - selesai)
  - Lokasi
  - Upload banner (opsional)
- Button: **Buat Acara**

---

## Tech Stack Suggestion
- **Calendar**: `table_calendar` untuk calendar view
- **Image**: `cached_network_image` untuk banner
- **Date/Time Picker**: `flutter_datetime_picker`
- **Maps**: `url_launcher` untuk buka Google Maps (link lokasi)

---

## Testing Checklist
- [ ] Kalender acara tampil (list & calendar view)
- [ ] Filter bulan/tahun bekerja
- [ ] Detail acara tampil lengkap
- [ ] RSVP berhasil (hadir/tidak/mungkin)
- [ ] Ubah status RSVP berhasil
- [ ] Statistik peserta update real-time
- [ ] Admin bisa buat acara baru
- [ ] Admin bisa edit & hapus acara
- [ ] Upload banner acara berhasil
- [ ] Notifikasi acara baru muncul
- [ ] Reminder 1 hari sebelum acara muncul
- [ ] Export daftar kehadiran (Admin) berfungsi
