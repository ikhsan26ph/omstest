# OMS Automation Testing Machine

Project ini adalah mesin automation testing untuk produk **OMS (Order Management System)**,
dijalankan lewat Claude Code + browser agent (Playwright MCP).

## Alur Kerja Utama

1. `/explore` — eksplorasi general aplikasi: login, petakan SEMUA modul/menu, simpan hasil ke `knowledge/module-map.md`. Ini WAJIB dijalankan pertama kali (atau saat aplikasi berubah besar).
2. User memerintah modul mana yang mau dites: `/test-module <nama-modul>`.
3. Hasil eksekusi disimpan sebagai JSON di `results/`, lalu `/report` mengubahnya menjadi file Excel di `reports/`.

Catatan: `/harvest-selectors <modul>` disarankan dijalankan sekali sebelum test modul pertama kali, dan diulang bila UI aplikasi berubah — hasilnya (`selector-map.md`) menjadi sumber selector utama executor.

## Aturan Wajib

- **Jangan pernah menebak URL atau kredensial.** Semua ada di `config/env.md`. Jika file itu belum diisi, berhenti dan minta user mengisinya.
- **Environment testing bisa berisi data nyata.** Dilarang keras: menghapus data yang tidak dibuat oleh test run ini, mengubah setting tenant, atau melakukan aksi destruktif (hapus order, batalkan order milik orang lain) kecuali skenario secara eksplisit memerintahkannya pada data yang dibuat sendiri oleh run ini.
- **Data test diberi prefix** `AUTOTEST-<tanggal>-` pada field bebas teks (mis. nama order/catatan) supaya mudah diidentifikasi dan dibersihkan.
- **Selector priority**: `getByRole(name)` → `getByLabel` → `getByText` → `getByTestId`. `data-testid` di dokumen knowledge hanyalah usulan, belum tentu ada di implementasi.
- **Satu skenario = satu verdict**: `passed` / `failed` / `blocked` / `skipped`. Failed harus menyertakan pesan error + screenshot di `artifacts/screenshots/`.
- **Bedakan BUG vs GAP DESAIN.** Dokumen knowledge menandai kandidat bug (FND-xx). Jika perilaku aplikasi cocok desain tapi bertentangan REQ, catat sebagai `bug-candidate`, jangan langsung failed tanpa keterangan.
- Bahasa laporan dan komunikasi: **Indonesia**.

## Knowledge Base (`knowledge/`)

Folder `knowledge/<modul>/` berisi dokumen hasil generate per modul:
- `*_analysis.md` — daftar REQ / VAL / AC
- `*_ui-inventory.md` — peta layar (SCR-xx), elemen, selector, pesan (M-xx), temuan (FND-xx)
- `*.feature` — skenario Gherkin lengkap
- `*_scenarios.json` — skenario terstruktur (id, category, priority, steps, expected) → **ini sumber utama eksekusi**
- `*_coverage.md` — hasil review coverage
- `selector-map.md` — hasil `/harvest-selectors`: selector asli per layar (SCR-xx) hasil harvesting dari aplikasi live → **sumber selector utama executor** (bila ada)

Saat mengeksekusi modul, SELALU baca `scenarios.json` modul tersebut sebagai daftar skenario, dan `ui-inventory.md` sebagai peta selector. Bila `selector-map.md` tersedia, selector dari sana diprioritaskan di atas usulan ui-inventory.

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
   Butuh Node 22 (`~/.nvm/versions/node/v22.19.0`); runner sudah mengatur PATH sendiri.
2. **Playwright MCP tanpa snapshot** — untuk modul tanpa spec / eksplorasi: gunakan `browser_run_code_unsafe`
   (satu call = seluruh langkah + assertion satu skenario, selector dari `selector-map.md`).
   `browser_snapshot` HANYA untuk explore/harvest/diagnosis kegagalan — dilarang di jalur eksekusi normal (lambat & boros context).

Catatan sesi (verifikasi 2026-08-22): backend OMS **menolak sesi yang dipindah antar browser-context** —
`storageState` Playwright tidak berfungsi. Login dilakukan sekali per worker pada context yang terus hidup
(`tests/helpers/fixtures.js`), dengan guard "login gagal 2x → berhenti". Jangan kembali ke pola storageState.
Selector login: `getByPlaceholder('Masukkan Email')`, `getByPlaceholder('Masukkan Password')`, tombol `Login`; sukses → redirect `/monitoring`.

## Batasan Eksekusi Browser

- Selalu tunggu network idle / elemen terlihat sebelum assert; UI OMS memakai drawer/modal yang render async.
- Skenario `@stress` dan yang berpotensi membuat data masif hanya dijalankan jika user secara eksplisit memintanya.
- Jika login gagal 2x berturut-turut, BERHENTI (jangan sampai akun terkunci) dan lapor ke user.
