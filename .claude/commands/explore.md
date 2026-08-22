---
description: Eksplorasi general aplikasi OMS — login lalu petakan semua modul/menu
---

Lakukan eksplorasi general aplikasi OMS. Delegasikan pekerjaan browser ke subagent **oms-explorer**.

Langkah:
1. Baca `config/env.md`. Jika `baseUrl` / kredensial kosong → berhenti, minta user mengisi.
2. Jalankan subagent `oms-explorer` dengan instruksi:
   - Login ke aplikasi memakai kredensial di `config/env.md`.
   - Petakan SELURUH struktur navigasi: sidebar, menu, submenu, tab, sampai 2 level dalam.
   - Untuk setiap modul catat: nama menu, URL/route, deskripsi singkat isi halaman (list? form? dashboard?), tombol aksi utama, dan apakah aksesnya dibatasi role.
   - JANGAN melakukan aksi tulis apa pun (tidak submit form, tidak klik hapus). Read-only.
   - Ambil screenshot 1x per modul utama ke `artifacts/screenshots/explore/`.
3. Simpan hasil ke `explore/module-map.md` dalam bentuk tabel:
   `| # | Modul | Route | Jenis Halaman | Aksi Utama | Ada Dokumen Skenario? | Catatan |`
   — kolom "Ada Dokumen Skenario?" diisi dengan mencocokkan nama modul ke folder yang ada di `scenario/`.
4. Tampilkan ringkasan ke user: daftar modul yang ditemukan, mana yang sudah punya dokumen skenario (siap dites detail), mana yang belum (baru bisa smoke test).

Argumen opsional: $ARGUMENTS (jika user menyebut area tertentu, fokuskan eksplorasi ke sana).
