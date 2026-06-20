# Domain Model - Fitur Forum Komunitas RT/RW Digital

Dokumen ini mendefinisikan entitas, atribut, relasi, dan struktur data untuk fitur Forum Komunitas.

## Prinsip Desain

1. **Integrated User**: Menggunakan entitas User dari Modul Profil/Auth.
2. **Relational Hierarchy**: Postingan sebagai akar, Komentar dan Balasan sebagai percabangan.
3. **Flexible Categories**: Kategori dikelola sebagai entitas terpisah.
4. **Action Logging**: Setiap tindakan moderator dan laporan warga dicatat dalam entitas terpisah untuk audit.

---

## 1. Entity Model

### 1.1. Entity: Post (Postingan)
Pusat dari seluruh data forum.

| Attribute | Type | Mandatory | Description |
|-----------|------|-----------|-------------|
| `id` | UUID | Yes | Primary Key |
| `author_id` | UUID | Yes | Foreign Key -> User.id |
| `category_id` | UUID | Yes | Foreign Key -> ForumCategory.id |
| `rt_id` | String | Yes | Foreign Key -> RT.id (Wilayah asal postingan) |
| `rw_id` | String | Yes | Foreign Key -> RW.id |
| `title` | String | No | Judul postingan (opsional) |
| `content` | Text | Yes | Konten teks utama |
| `status` | Enum | Yes | aktif, review, ditutup, selesai, dihapus |
| `is_pinned` | Boolean | Yes | Default: false |
| `is_private` | Boolean | Yes | Default: false (Hanya RT sendiri) |
| `view_count` | int | Yes | Default: 0 |
| `created_at` | DateTime | Yes | |
| `updated_at` | DateTime | Yes | |
| `deleted_at` | DateTime | No | Untuk soft delete |

### 1.2. Entity: ForumCategory (Kategori Postingan)
Tabel master untuk mengelola kategori.

| Attribute | Type | Mandatory | Description |
|-----------|------|-----------|-------------|
| `id` | UUID | Yes | Primary Key |
| `name` | String | Yes | Nama kategori (Keluhan, Aspirasi, dll) |
| `icon_url` | String | No | URL icon kategori |
| `color_code` | String | No | Kode warna untuk tag UI (HEX) |
| `description`| String | No | Penjelasan kategori |
| `is_active` | Boolean | Yes | Default: true |

### 1.3. Entity: Comment (Komentar)
Mendukung reply berjenjang (nested).

| Attribute | Type | Mandatory | Description |
|-----------|------|-----------|-------------|
| `id` | UUID | Yes | Primary Key |
| `post_id` | UUID | Yes | Foreign Key -> Post.id |
| `author_id` | UUID | Yes | Foreign Key -> User.id |
| `parent_id` | UUID | No | Foreign Key -> Comment.id (Untuk reply) |
| `content` | Text | Yes | Konten komentar |
| `is_deleted` | Boolean | Yes | Default: false |
| `created_at` | DateTime | Yes | |
| `updated_at` | DateTime | Yes | |

### 1.4. Entity: Reaction (Reaksi)
Mendukung reaksi pada post dan komentar.

| Attribute | Type | Mandatory | Description |
|-----------|------|-----------|-------------|
| `id` | UUID | Yes | Primary Key |
| `author_id` | UUID | Yes | Foreign Key -> User.id |
| `target_id` | UUID | Yes | Foreign Key -> Post.id atau Comment.id |
| `target_type`| Enum | Yes | post, comment |
| `type` | Enum | Yes | like, love, support, sad, angry |
| `created_at` | DateTime | Yes | |

### 1.5. Entity: PostAttachment (Lampiran Postingan)

| Attribute | Type | Mandatory | Description |
|-----------|------|-----------|-------------|
| `id` | UUID | Yes | Primary Key |
| `post_id` | UUID | Yes | Foreign Key -> Post.id |
| `file_url` | String | Yes | URL file storage |
| `file_type` | Enum | Yes | image, video, document |
| `file_size` | int | Yes | Ukuran dalam bytes |
| `created_at` | DateTime | Yes | |

### 1.6. Entity: ContentReport (Laporan Konten)

| Attribute | Type | Mandatory | Description |
|-----------|------|-----------|-------------|
| `id` | UUID | Yes | Primary Key |
| `reporter_id`| UUID | Yes | Foreign Key -> User.id |
| `target_id` | UUID | Yes | Foreign Key -> Post.id atau Comment.id |
| `target_type`| Enum | Yes | post, comment |
| `reason` | Enum | Yes | spam, hate_speech, inappropriate, dll |
| `description`| String | No | Keterangan tambahan |
| `status` | Enum | Yes | pending, reviewed, dismissed, acted |
| `moderator_id`| UUID | No | Moderator yang memproses |
| `created_at` | DateTime | Yes | |

---

## 2. Enums & Status

### 2.1. Enum: PostStatus
- `aktif`: Tampil di feed.
- `review`: Menunggu persetujuan moderator (jika mode review aktif).
- `ditutup`: Diskusi selesai, tidak bisa dikomentari lagi.
- `selesai`: Khusus Keluhan, masalah sudah ditangani.
- `dihapus`: Tidak tampil di feed (soft delete).

### 2.2. Enum: ReportReason
- `spam`: Konten tidak relevan/promosi.
- `hate_speech`: Ujaran kebencian/SARA.
- `inappropriate`: Konten tidak pantas/pornografi/kekerasan.
- `fake_info`: Berita bohong/hoax.
- `misclassified`: Salah kategori.
- `harassment`: Pelecehan/gangguan.
- `other`: Alasan lainnya.

### 2.3. Enum: ReactionType
- `like` (👍)
- `love` (❤️)
- `support` (👏)
- `sad` (😢)
- `angry` (😡)

---

## 3. Relationships Model

```
+------------+        1:N        +-------------+
|    USER    | <---------------- |    POST     |
| (Existing) |                   |             |
+------------+                   +-------------+
      |                                 | 1:N
      |                                 v
      | 1:N                      +-------------+
      +------------------------> |   COMMENT   |
      |                          | (parent_id) |
      |                          +-------------+
      |                                 |
      | 1:N                             | 1:N (Recursive)
      +---------------------------------+
      |
      | 1:N                      +-------------+
      +------------------------> |  REACTION   |
      |                          | (target_id) |
      |                          +-------------+
      |
      | 1:N                      +-------------+
      +------------------------> |   REPORT    |
                                 | (target_id) |
                                 +-------------+

POST --- 1:N --- ATTACHMENT
POST --- N:1 --- FORUM_CATEGORY
```

---

## 4. Derived Data (Data Turunan)

Untuk performa, beberapa data disimpan secara agregat (atau di-hitung secara real-time dengan caching):

1. **ReactionCount**: Jumlah total reaksi per tipe untuk setiap post/comment.
2. **CommentCount**: Jumlah total komentar pada sebuah post.
3. **ReportCount**: Jumlah total laporan pada sebuah post/comment.
4. **IsFollowed**: Status apakah user tertentu mem-follow post tersebut.
5. **MyReaction**: Tipe reaksi yang diberikan user aktif pada item tertentu.

---

## 5. Domain Rules (Constraint)

1. **Constraint Postingan**: Judul maksimal 100 karakter, Konten maksimal 5000 karakter.
2. **Constraint Lampiran**: Maksimal 5 foto per post, ukuran per file maksimal 5MB.
3. **Constraint Komentar**: Maksimal 2000 karakter, tidak boleh kosong.
4. **Constraint Reaksi**: User hanya boleh memiliki 1 record di tabel Reaction untuk pasangan (user_id, target_id).
5. **Constraint Laporan**: User hanya boleh melapor 1 kali per target_id.
6. **Constraint Moderasi**: Pengurus RT hanya boleh mengupdate status Post yang rt_id nya sama dengan rt_id milik user pengurus tersebut.
