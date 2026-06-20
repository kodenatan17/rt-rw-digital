# Workflow - Fitur Forum Komunitas RT/RW Digital

Dokumen ini mendefinisikan alur kerja (workflow) utama dalam fitur Forum.

---

## 1. Workflow Pembuatan Postingan (User Flow)

### Tujuan
Warga atau pengurus membuat postingan baru di feed forum.

### Alur

```
START
  |
  v
User buka menu Forum -> Tab "Feed"
  |
  v
Klik tombol "Buat Postingan"
  |
  v
Pilih Kategori (Keluhan, Aspirasi, Diskusi, dll)
  |
  v
Tulis Konten:
  - Input Judul (opsional)
  - Input Konten teks (wajib)
  - Tambah Foto (opsional, maks 5)
  |
  v
Klik "Publikasikan"
  |
  v
Sistem cek "Mode Moderasi":
  |
  +---> [Mode Review Mati]
  |       |
  |       v
  |     Status: "aktif"
  |     Tampil di Feed publik
  |     Notifikasi ke pengurus (jika kategori Keluhan)
  |
  +---> [Mode Review Nyala]
          |
          v
        Status: "review"
        Hanya tampil di "Postingan Saya"
        Masuk antrian moderasi pengurus
  |
  v
END
```

---

## 2. Workflow Interaksi (Komentar & Reaksi)

### Tujuan
Warga berinteraksi dengan postingan yang sudah ada.

### Alur

```
START
  |
  v
User melihat postingan di Feed
  |
  +---> [Berikan Reaksi]
  |       |
  |       v
  |     Tap icon Reaksi -> Pilih tipe (Like, Love, dll)
  |     Sistem simpan/update reaksi
  |     Update jumlah reaksi di UI
  |
  +---> [Berikan Komentar]
  |       |
  |       v
  |     Klik "Komentar" -> Tulis teks -> Kirim
  |     Sistem simpan komentar
  |     Notifikasi ke penulis postingan
  |
  +---> [Balas Komentar / Thread]
          |
          v
        Klik "Balas" pada komentar orang lain
        Tulis balasan -> Kirim
        Sistem simpan komentar (parent_id terisi)
        Notifikasi ke penulis komentar asli
  |
  v
END
```

---

## 3. Workflow Penanganan Keluhan (Moderator Flow)

### Tujuan
Pengurus RT/RW merespons dan menyelesaikan keluhan warga.

### Alur

```
START
  |
  v
Warga posting Keluhan (status: Menunggu Tindakan)
  |
  v
Pengurus RT terima notifikasi "Keluhan Baru"
  |
  v
Pengurus buka postingan -> Klik "Proses"
  |
  v
Status postingan berubah -> "Dalam Proses"
Notifikasi ke Warga: "Keluhan Anda sedang diproses oleh Pengurus RT"
  |
  v
Pengurus melakukan tindakan di lapangan
  |
  v
Setelah selesai -> Pengurus posting Komentar (bukti penyelesaian)
  |
  v
Pengurus ubah status postingan -> "Selesai"
Notifikasi ke Warga: "Keluhan Anda telah diselesaikan"
  |
  v
Thread ditutup (opsional: stop komentar baru)
  |
  v
END
```

---

## 4. Workflow Pelaporan Konten & Moderasi

### Tujuan
Warga melaporkan konten negatif dan moderator mengambil tindakan.

### Alur

```
START
  |
  v
Warga melihat postingan/komentar negatif
  |
  v
Klik menu (...) -> "Laporkan Konten"
  |
  v
Pilih Alasan (Spam, Hate Speech, dll) -> Kirim
  |
  v
Laporan masuk ke "Daftar Laporan" Pengurus
  |
  v
[Sistem]: Jika laporan > 3 dari user berbeda -> Tandai konten "Under Review"
  |
  v
Pengurus buka Daftar Laporan -> Review konten asli
  |
  v
Pengurus ambil keputusan:
  |
  +---> [Abaikan] -> Laporan di-dismiss, konten tetap ada
  |
  +---> [Peringatan] -> Kirim notifikasi peringatan ke penulis
  |
  +---> [Hapus/Hidden] -> Konten di-hidden/dihapus
  |                       Notifikasi ke penulis: "Konten dihapus karena [alasan]"
  |                       Catat pelanggaran di profil user
  |
  v
END
```

---

## 5. Workflow Bagikan Konten (Share)

### Tujuan
Mempromosikan interaksi forum ke luar aplikasi.

### Alur

```
START
  |
  v
User buka detail postingan
  |
  v
Klik icon "Share"
  |
  v
Sistem generate Share Link (Deep Link)
Pilih Platform (WhatsApp, Copy Link, dll)
  |
  v
Link terkirim ke platform eksternal
  |
  v
Orang lain klik link:
  |
  +---> [Aplikasi terinstall] -> Buka Aplikasi -> Direct ke Postingan
  |
  +---> [Aplikasi tidak ada] -> Buka Web/Store -> Prompt Install
  |
  v
END
```

---

## 6. Workflow Pinned Post (Pengumuman Penting)

### Tujuan
Memastikan informasi penting tidak tenggelam di feed.

### Alur

```
START
  |
  v
Pengurus membuat postingan Informasi atau Kegiatan
  |
  v
Klik menu (...) -> "Pin Postingan"
  |
  v
Sistem cek jumlah Pinned Post (Maks 3):
  |
  +---> [Slot ada] -> Postingan dipindah ke baris teratas feed
  |
  +---> [Slot penuh] -> Prompt: "Slot Pin Penuh. Pilih postingan untuk di-unpin"
  |
  v
Postingan tetap di atas sampai Pengurus klik "Unpin"
  |
  v
END
```
