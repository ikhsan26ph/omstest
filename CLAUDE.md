# OMS Automation Testing Machine

Project ini adalah mesin automation testing untuk produk **OMS (Order Management System)**,
dijalankan lewat Claude Code + browser agent (Playwright MCP).

## Alur Kerja Utama

1. `/explore` — eksplorasi general aplikasi: login, petakan SEMUA modul/menu, simpan hasil ke `explore/module-map.md`. Ini WAJIB dijalankan pertama kali (atau saat aplikasi berubah besar).
2. User memerintah modul mana yang mau dites: `/test-module <nama-modul>`.
3. `/task` — perintah bebas (mis. "buatkan order ..."), berbasis folder `task/`. **Status: belum diimplementasikan.**

Hasil eksekusi disimpan sebagai JSON di `results/`, lalu `/report` mengubahnya menjadi file Excel di `reports/`.

Catatan: `/harvest-selectors <modul>` disarankan dijalankan sekali sebelum test modul pertama kali, dan diulang bila UI aplikasi berubah — hasilnya (`shared/selector-map-*.md`) menjadi sumber selector utama executor.

## Aturan Wajib

- **Jangan pernah menebak URL atau kredensial.** Semua ada di `config/env.md`. Jika file itu belum diisi, berhenti dan minta user mengisinya (contoh format: `config/env.example.md`).
- **Environment testing bisa berisi data nyata.** Dilarang keras: menghapus data yang tidak dibuat oleh test run ini, mengubah setting tenant, atau melakukan aksi destruktif (hapus order, batalkan order milik orang lain) kecuali skenario secara eksplisit memerintahkannya pada data yang dibuat sendiri oleh run ini.
- **Data test diberi prefix** `AUTOTEST-<tanggal>-` pada field bebas teks (mis. nama order/catatan) supaya mudah diidentifikasi dan dibersihkan.
- **Selector priority**: `getByRole(name)` → `getByLabel` → `getByText` → `getByTestId`. `data-testid` di dokumen skenario hanyalah usulan, belum tentu ada di implementasi.
- **Satu skenario = satu verdict**: `passed` / `failed` / `blocked` / `skipped`. Failed harus menyertakan pesan error + screenshot di `artifacts/screenshots/`.
- **Bedakan BUG vs GAP DESAIN.** Dokumen skenario menandai kandidat bug (FND-xx). Jika perilaku aplikasi cocok desain tapi bertentangan REQ, catat sebagai `bug-candidate`, jangan langsung failed tanpa keterangan.
- Bahasa laporan dan komunikasi: **Indonesia**.

## Struktur Project

- `explore/` — output `/explore` (`module-map.md`): peta seluruh modul/route + info login & environment.
- `scenario/<modul>/` — dokumen skenario per modul: `*_analysis.md`, `*_ui-inventory.md`, `*.feature`, `*_scenarios.json` (**sumber utama eksekusi**), `*_coverage.md`. Skema wajib: lihat `scenario/README.md`.
- `task/` — fitur perintah bebas `/task` (defaults, intent schema). Belum diimplementasikan.
- `shared/` — hal lintas fitur: `selector-map-order.md` (hasil `/harvest-selectors`, **sumber selector utama executor** untuk route `/order`), `decisions.md` (keputusan triage bertanggal).
- `config/` — `env.md` (link + kredensial, gitignore) dan `env.example.md` (contoh format).
- `results/`, `reports/`, `artifacts/` — output run (JSON, Excel, screenshot); gitignore, tidak di-commit.

Saat mengeksekusi modul, SELALU baca `scenario/<modul>/*_scenarios.json` sebagai daftar skenario, dan `*_ui-inventory.md` sebagai peta selector. Bila selector-map di `shared/` tersedia, selector dari sana diprioritaskan di atas usulan ui-inventory.

## Skema Hasil Eksekusi (`results/`)

Satu run = satu file `results/<modul>__<YYYYMMDD-HHmmss>.json`:

```json
{
  "module": "oms012-order-ftl-auto-stuffing",
  "runId": "20260821-140501",
  "startedAt": "...", "finishedAt": "...",
  "environment": {"baseUrl": "...", "user": "...", "role": "..."},
  "scenarios": [
    {
      "id": "SCN-0001",
      "title": "...",
      "category": "positive|negative|edge|stress",
      "priority": "high|medium|low",
      "screen": "...",
      "requirements": ["REQ-001"],
      "status": "passed|failed|blocked|skipped",
      "durationSec": 12.3,
      "error": null,
      "screenshot": null,
      "bugCandidate": null,
      "notes": ""
    }
  ]
}
```

Field `id`, `title`, `category`, `priority`, `requirements` HARUS disalin apa adanya dari `scenarios.json` agar traceability terjaga.

## Report Excel

`python scripts/generate_report.py results/<file>.json` → menghasilkan `reports/<modul>__<runId>.xlsx`
berisi sheet: **Summary**, **Detail**, **Failed & Bug Candidates**. Jangan menulis Excel manual — selalu lewat script ini.

## Mode Eksekusi (urutan prioritas)

1. **Playwright script** — bila `tests/<modul>.spec.js` ada, eksekusi modul WAJIB lewat
   `bash scripts/run-playwright.sh <modul>` (opsi filter: argumen playwright, mis. `--grep SCN-0004`).
   Script otomatis: jalankan test → konversi ke skema `results/` (`scripts/playwright_to_results.py`) → generate Excel.
   Judul test berformat `SCN-xxxx: <judul asli scenarios.json>` — jangan diubah, dipakai untuk traceability.
   Butuh Node ≥ 22, lihat `.nvmrc`; runner mengatur PATH sendiri (via nvm bila tersedia).
2. **Playwright MCP tanpa snapshot** — untuk modul tanpa spec / eksplorasi: gunakan `browser_run_code_unsafe`
   (satu call = seluruh langkah + assertion satu skenario, selector dari `shared/selector-map-*.md`).
   `browser_snapshot` HANYA untuk explore/harvest/diagnosis kegagalan — dilarang di jalur eksekusi normal (lambat & boros context).

Catatan sesi: backend OMS **menolak sesi yang dipindah antar browser-context** — `storageState` Playwright
tidak berfungsi. Login dilakukan sekali per worker pada context yang terus hidup (`tests/helpers/fixtures.js`),
dengan guard "login gagal 2x → berhenti". Jangan kembali ke pola storageState.
Detail selector login & redirect: lihat `explore/module-map.md` section "Info Login & Environment".

## Batasan Eksekusi Browser

- Selalu tunggu network idle / elemen terlihat sebelum assert; UI OMS memakai drawer/modal yang render async.
- Skenario `@stress` dan yang berpotensi membuat data masif hanya dijalankan jika user secara eksplisit memintanya.
- Jika login gagal 2x berturut-turut, BERHENTI (jangan sampai akun terkunci) dan lapor ke user.
