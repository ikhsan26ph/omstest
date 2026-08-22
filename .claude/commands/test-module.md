---
description: Jalankan automation test untuk satu modul OMS. Usage — /test-module <modul> [filter]
---

Jalankan pengujian untuk modul: **$1**
Filter opsional (sisa argumen): $ARGUMENTS
Contoh filter: `priority:high`, `category:positive`, `scn:SCN-0001..SCN-0020`, `smoke` (subset 10-15 skenario high-priority positive), `max:30`.

Langkah:
1. Verifikasi `config/env.md` terisi dan `knowledge/module-map.md` ada (jika belum, sarankan `/explore` dulu).
2. Cari folder knowledge yang cocok dengan "$1" di `knowledge/` (boleh fuzzy match, mis. "ftl auto stuffing" → `oms012-order-ftl-auto-stuffing`). Jika tidak ada dokumen skenario → tawarkan smoke test eksploratif saja dan minta konfirmasi.
3. Jalankan subagent **test-planner**: baca `scenarios.json` modul, terapkan filter, dan susun *execution plan* — urutan skenario yang efisien (kelompokkan per screen/precondition, positive dulu baru negative, skenario yang saling bergantung berurutan). Skenario `@stress` di-skip kecuali filter memintanya. Simpan plan ke `results/_plan__<modul>__<runId>.md`.
4. Tampilkan plan singkat ke user (jumlah skenario, estimasi, apa yang di-skip) — lanjut eksekusi tanpa menunggu jika jumlah ≤ 30, minta konfirmasi jika lebih.
5. **Jalur cepat (prioritas):** jika `tests/<modul>.spec.js` ada, jalankan `bash scripts/run-playwright.sh <modul>` (hasil + report otomatis; filter via `--grep`). Skenario dari plan yang belum tercakup spec dieksekusi subagent **test-executor** (mode `browser_run_code_unsafe`, lihat CLAUDE.md "Mode Eksekusi") per batch 10-15 skenario, lalu hasilnya digabung ke file results yang sama. Jika spec belum ada sama sekali, seluruh plan dieksekusi test-executor. Jika sesi browser mati di tengah, login ulang dan lanjut dari skenario berikutnya (yang gagal ditandai `blocked`).
6. Setelah selesai, jalankan subagent **bug-triager** pada hasil failed/bug-candidate untuk memisahkan: bug aplikasi vs selector/timing issue vs gap desain (rujuk FND-xx di ui-inventory).
7. Generate report: `python scripts/generate_report.py results/<modul>__<runId>.json`
8. Ringkas ke user: total pass/fail/blocked/skip, daftar failed teratas + dugaan penyebab dari triager, path file Excel.
