# Business Rules - Fitur Forum Komunitas RT/RW Digital

## 1. Postingan (Posts)

### 1.1. Pembuatan Postingan
1.1.1. Setiap warga yang sudah login dapat membuat postingan.
1.1.2. Postingan wajib memiliki kategori yang valid.
1.1.3. Postingan minimal memiliki judul atau konten teks (salah satu wajib diisi).
1.1.4. Postingan dapat memiliki attachment berupa foto (maksimal 5 foto per postingan).
1.1.5. Postingan dengan kategori "Keluhan" otomatis mendapatkan status "Menunggu Tindakan" saat dipublikasikan.

### 1.2. Kategori Postingan
1.2.1. Kategori bersifat statis dan dikelola melalui master data oleh Super Admin.
1.2.2. Kategori yang tersedia: Keluhan, Aspirasi, Informasi, Kegiatan, Keamanan, Lingkungan, Diskusi Umum.
1.2.3. Setiap postingan hanya boleh memiliki satu kategori.
1.2.4. Pengurus RT/RW dapat menambahkan label tambahan ke postingan (multi-label opsional).

### 1.3. Visibilitas & Status Postingan
1.3.1. Status postingan: Aktif, Dalam Review, Ditutup, Diselesaikan, Dihapus.
1.3.2. Postingan baru dari warga langsung berstatus "Aktif" (tanpa pre-approval). Jika forum diset ke mode review, berstatus "Dalam Review".
1.3.3. Postingan dari Pengurus RT/RW langsung "Aktif" tanpa review.
1.3.4. Hanya Pengurus RT/RW, Super Admin, atau penulis postingan yang dapat mengubah status postingan.
1.3.5. Postingan dengan status "Dihapus" hanya terlihat oleh penulis dan moderator.

### 1.4. Postingan Pin (Pinned Post)
1.4.1. Hanya Pengurus RT/RW dan Super Admin yang dapat me-pin postingan.
1.4.2. Maksimal 3 postingan pin dalam satu waktu per RT/RW.
1.4.3. Postingan pin muncul di bagian atas feed secara permanen sampai di-unpin.

## 2. Komentar & Balasan (Comments & Replies)

2.1. Setiap warga yang sudah login dapat memberikan komentar pada postingan.
2.2. Komentar dapat memiliki balasan (reply), maksimal kedalaman 2 level (postingan > komentar > balasan).
2.3. Penulis postingan dan moderator dapat menghapus komentar atau balasan dari user lain.
2.4. User dapat menghapus komentar atau balasannya sendiri.
2.5. Tidak ada batasan jumlah komentar per postingan.
2.6. Komentar baru muncul di urutan paling bawah (kronologis).

## 3. Reaksi (Reactions)

3.1. Setiap user dapat memberikan satu reaksi pada postingan atau komentar.
3.2. User dapat mengubah reaksi (mengganti Like dengan Love, dll).
3.3. User dapat membatalkan reaksi (un-react).
3.4. Tipe reaksi: Like, Love, Support, Sad, Angry (dapat ditambah di masa depan).
3.5. Jumlah reaksi per tipe ditampilkan secara publik.

## 4. Pelaporan Konten (Content Reporting)

4.1. Setiap warga dapat melaporkan postingan atau komentar yang melanggar aturan.
4.2. Alasan pelaporan: Spam, Hate Speech, Konten Tidak Pantas, Informasi Palsu, Kategori Salah, Lainnya.
4.3. Satu user hanya dapat melaporkan konten yang sama satu kali.
4.4. Laporan bersifat anonim (pelapor tidak diketahui oleh penulis konten).
4.5. Moderator mendapat notifikasi saat konten mendapat 3+ laporan berbeda dari user yang berbeda.

## 5. Moderasi Konten (Content Moderation)

### 5.1. Hak Moderasi
5.1.1. Pengurus RT: Moderasi konten di wilayah RT-nya sendiri.
5.1.2. Pengurus RW: Moderasi konten di seluruh RT dalam RW-nya.
5.1.3. Super Admin: Moderasi seluruh konten di aplikasi.

### 5.2. Tindakan Moderasi
5.2.1. Moderator dapat menyembunyikan postingan/komentar (hidden) - konten tidak tampil di publik namun tidak dihapus permanen.
5.2.2. Moderator dapat menghapus postingan/komentar (soft delete) - konten dihapus dari feed, penulis mendapat notifikasi.
5.2.3. Moderator dapat mengubah kategori atau status postingan.
5.2.4. Moderator dapat memindahkan postingan ke forum RT lain (jika salah RT).

### 5.3. Sanksi User
5.3.1. Moderator dapat memberikan peringatan (warning) ke user.
5.3.2. Setelah 3 pelanggaran, user dapat dibatasi (restricted) selama 7 hari: tidak bisa membuat postingan baru.
5.3.3. Super Admin dapat mem-banned user secara permanen.
5.3.4. Riwayat pelanggaran user dicatat untuk referensi.

## 6. Hak Akses & Kepemilikan Data

6.1. Data postingan dan komentar adalah milik penulisnya.
6.2. Moderator dan Super Admin memiliki hak untuk mengelola konten namun tidak memiliki hak kepemilikan.
6.3. Warga hanya bisa melihat konten di RT/RW tempat tinggalnya (default).
6.4. Warga dapat melihat konten forum RT lain jika postingan tersebut di-set "Publik Lintas RT".
6.5. Data user yang dihapus: postingan tetap ada namun nama penulis menjadi "[Warga Dihapus]".

## 7. Notifikasi

### 7.1. Event Notifikasi
7.1.1. Postingan baru dari Pengurus RT/RW ke seluruh warga di RT/RW tersebut.
7.1.2. Komentar baru ke penulis postingan.
7.1.3. Balasan baru ke penulis komentar.
7.1.4. Mention (@username) ke user yang disebut.
7.1.5. Perubahan status keluhan ke penulis postingan.
7.1.6. Postingan disetujui/ditolak ke penulis (jika mode review aktif).
7.1.7. Konten dihapus oleh moderator ke penulis.

### 7.2. Setting Notifikasi
7.2.1. User dapat mengatur preferensi notifikasi (on/off per jenis notifikasi).
7.2.2. User dapat mem-follow postingan tertentu untuk mendapat notifikasi komentar baru.

## 8. Share & Integrasi

8.1. Setiap postingan dapat dibagikan (share) ke aplikasi eksternal melalui mekanisme share platform (WhatsApp, Telegram, Facebook, Twitter, Copy Link).
8.2. Link yang dibagikan mengarah ke postingan di aplikasi mobile (deep link).
8.3. User yang belum login saat membuka link akan diarahkan ke halaman login, lalu ke postingan.

## 9. Privasi & Keamanan

9.1. Hanya user yang sudah login yang dapat melihat feed forum.
9.2. Postingan publik tidak boleh mengandung data pribadi (nomor HP, alamat lengkap, NIK). Moderator dapat menghapus konten yang mengandung data pribadi.
9.3. Pelaporan bersifat anonim demi keamanan pelapor.
9.4. Fitur "Posting Anonim" (future): khusus untuk kategori Keluhan, identitas penulis hanya diketahui moderator.

## 10. Data Retention & Pembersihan

10.1. Postingan aktif disimpan tanpa batas waktu (tidak ada auto-delete).
10.2. Postingan dengan status "Dihapus": soft delete, data masih tersimpan 90 hari sebelum permanent purge oleh Super Admin.
10.3. Riwayat pelanggaran user disimpan 1 tahun.

## 11. Moderasi Otomatis (Future)

11.1. Sistem dapat menandai konten yang mengandung kata-kata terlarang (daftar kata dilarang dikelola Super Admin).
11.2. Konten yang ditandai otomatis masuk ke antrian review moderator.
11.3. User yang sering menggunakan kata terlarang mendapat batasan otomatis.

## 12. Analitik & Reporting (Future)

12.1. Postingan dan komentar digunakan untuk analitik engagement warga dan tidak dijual ke pihak ketiga.
12.2. Data agregat (jumlah postingan per kategori, engagement rate, top contributor) dapat digunakan oleh pengurus untuk laporan.

## 13. Aturan Tambahan

13.1. Satu user tidak boleh membuat postingan yang sama persis (duplikat konten). Moderator akan menghapus duplikat.
13.2. Promosi komersial (jual-beli) dilarang kecuali ada kategori khusus yang disediakan.
13.3. Pengurus dapat menutup thread diskusi (disable komentar) untuk postingan tertentu yang dianggap sudah selesai.
