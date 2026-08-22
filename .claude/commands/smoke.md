---
description: Smoke test cepat seluruh modul dari module-map (read-only, tanpa dokumen skenario)
---

Jalankan smoke test cepat ke seluruh modul yang tercatat di `explore/module-map.md` (jalankan `/explore` dulu jika belum ada).

Untuk tiap modul, subagent **test-executor** cukup memverifikasi:
1. Halaman terbuka tanpa error (tidak blank, tidak 4xx/5xx, tidak error boundary).
2. Komponen utama render (tabel/list/form sesuai jenis halaman di module-map).
3. Satu interaksi read-only ringan (buka filter, buka detail baris pertama, tutup lagi).

Tanpa aksi tulis sama sekali. Hasil disimpan ke `results/smoke__<runId>.json` dengan `id` = `SMOKE-<modul>`, lalu generate Excel via `scripts/generate_report.py`.
