# Environment OMS

Salin file ini menjadi `config/env.md` lalu isi nilai `ISI_DISINI`.
`config/env.md` masuk `.gitignore` — **jangan pernah di-commit**.

Format tabel di bawah di-parse oleh `tests/helpers/env.js` dan `scripts/playwright_to_results.py` — jangan mengubah struktur kolomnya.

## Aplikasi

| Key | Nilai | Keterangan |
|---|---|---|
| baseUrl | ISI_DISINI | contoh: https://oms-staging.example.com |

## Akun

| No | Email | Password | Role | Keterangan |
|---|---|---|---|---|
| 1 | ISI_DISINI | ISI_DISINI | ISI_DISINI | akun utama (dipakai login test) |
| 2 | ISI_DISINI | ISI_DISINI | ISI_DISINI | opsional — role lain untuk perbandingan akses |
| 3 | ISI_DISINI | ISI_DISINI | ISI_DISINI | opsional |
