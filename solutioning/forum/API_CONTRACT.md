# API Contract - Fitur Forum Komunitas RT/RW Digital

Dokumen ini mendefinisikan API endpoint yang diperlukan untuk fitur Forum.

---

## 1. Feed & Posts

### `GET /forum/posts`
**Deskripsi:** Mengambil daftar postingan (feed).
**Role:** Semua user terautentikasi.

**Query Parameters:**
- `category_id` (String): Filter berdasarkan kategori.
- `rt_id` (String): Filter berdasarkan RT tertentu.
- `is_pinned` (Boolean): Ambil hanya postingan pin.
- `page` (Int), `limit` (Int): Pagination.

**Response Success (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "author": {
        "id": "uuid",
        "name": "Budi Santoso",
        "avatar": "url",
        "rt": "01",
        "role": "warga"
      },
      "category": { "id": "uuid", "name": "Keluhan", "color": "#FF0000" },
      "title": "Jalan Berlubang",
      "content": "Jalan di depan blok A1 berlubang, tolong ditindaklanjuti.",
      "attachments": ["url1", "url2"],
      "status": "proses",
      "is_pinned": false,
      "reactions_count": 15,
      "comments_count": 5,
      "my_reaction": "like",
      "created_at": "2026-06-18T10:00:00Z"
    }
  ]
}
```

---

### `POST /forum/posts`
**Deskripsi:** Membuat postingan baru.
**Request Body:**
```json
{
  "category_id": "uuid",
  "title": "Opsional",
  "content": "Konten teks wajib",
  "attachment_urls": ["url1", "url2"],
  "is_private": false
}
```

---

### `PATCH /forum/posts/{id}/status`
**Deskripsi:** Mengubah status postingan (Khusus Pengurus).
**Request Body:**
```json
{
  "status": "selesai",
  "moderator_note": "Sudah diperbaiki pada 18 Juni."
}
```

---

## 2. Comments & Reactions

### `GET /forum/posts/{id}/comments`
**Deskripsi:** Mengambil komentar pada postingan tertentu.
**Response:** Mendukung nested structure atau flat list dengan `parent_id`.

### `POST /forum/posts/{id}/comments`
**Deskripsi:** Menambahkan komentar atau balasan.
**Request Body:**
```json
{
  "content": "Komentar saya",
  "parent_id": "uuid_komentar_jika_balas" 
}
```

### `POST /forum/items/{id}/react`
**Deskripsi:** Memberikan reaksi pada post atau komentar.
**Request Body:**
```json
{
  "type": "love",
  "target_type": "post" // post atau comment
}
```

---

## 3. Moderation & Reporting

### `POST /forum/items/{id}/report`
**Deskripsi:** Melaporkan konten.
**Request Body:**
```json
{
  "reason": "spam",
  "description": "Iklan judi online",
  "target_type": "post"
}
```

### `GET /forum/moderation/reports`
**Deskripsi:** List konten yang dilaporkan (Khusus Pengurus/Admin).

---

## 4. Master Data

### `GET /forum/categories`
**Deskripsi:** Mengambil daftar kategori forum aktif.
