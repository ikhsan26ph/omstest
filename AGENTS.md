# OMS — Codex

Sebelum mengerjakan proyek, baca dan ikuti `docs/agent-guide.md`.
Semua path di panduan relatif terhadap root repository.

## Pemetaan permintaan

| Permintaan pengguna | Prosedur yang wajib dibaca |
|---|---|
| explore / eksplorasi aplikasi | `docs/workflows/explore.md` |
| smoke / cek cepat modul | `docs/workflows/smoke.md` |
| harvest-selectors <modul> / petakan selector | `docs/workflows/harvest-selectors.md` |
| test-module <modul> [filter] / uji modul | `docs/workflows/test-module.md` |
| report [modul atau file atau all] / buat laporan | `docs/workflows/report.md` |

Ambil `$1` dan `$ARGUMENTS` pada prosedur dari permintaan pengguna; jangan
menjalankannya sebagai variabel shell. Jika nama modul ambigu, minta klarifikasi.
Slash command Claude tidak didaftarkan sebagai slash command Codex oleh file ini.
Gunakan instruksi biasa atau permintaan untuk membaca file prosedur.
`task` belum diimplementasikan; jangan mengklaim tersedia.

Jalankan peran di `docs/roles/` secara berurutan dalam agent utama. Tidak perlu
memuat konfigurasi model/tool Claude atau membuat subagent untuk menjalankannya.
Browser memakai `.codex/config.toml`; periksa kemampuan MCP sesuai panduan bersama.
Perbarui aturan/workflow bersama di `docs/` agar Claude dan Codex tetap konsisten.
