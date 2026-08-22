# scenario/ — Dokumen Skenario per Modul

Satu subfolder per modul, berisi dokumen hasil generate:

```
scenario/<nama-modul>/
├── <modul>_analysis.md       daftar REQ / VAL / AC
├── <modul>_ui-inventory.md   peta layar (SCR-xx), elemen, selector usulan, pesan (M-xx), temuan (FND-xx)
├── <modul>.feature           skenario Gherkin lengkap
├── <modul>_scenarios.json    skenario terstruktur → SUMBER UTAMA EKSEKUSI
└── <modul>_coverage.md       hasil review coverage
```

Contoh nama modul: `oms012-order-ftl-auto-stuffing`.

## Skema wajib `*_scenarios.json`

```json
{
  "scenarios": [
    {
      "id": "SCN-0001",
      "title": "Judul skenario",
      "category": "positive",
      "priority": "high",
      "screen": "SCR-01",
      "requirements": ["REQ-001"],
      "steps": ["..."],
      "expected": ["..."]
    }
  ]
}
```

Aturan field:

| Field | Format | Keterangan |
|---|---|---|
| `id` | `SCN-xxxx` | WAJIB format ini — dipakai untuk traceability judul test Playwright (`SCN-xxxx: <judul>`) |
| `requirements` | array, mis. `["REQ-001"]` | WAJIB array (bukan string tunggal) |
| `category` | `positive` \| `negative` \| `edge` \| `stress` | |
| `priority` | `high` \| `medium` \| `low` | |
| `screen` | `SCR-xx` | layar utama skenario |
| `steps` | array string | langkah eksekusi |
| `expected` | array string | hasil yang diharapkan |

**Penting**: `scripts/playwright_to_results.py` mengandalkan format `id` `SCN-xxxx` dan field `requirements` (array) untuk menyalin metadata apa adanya ke `results/`. Modul dengan skema lain (mis. id `OMS013-POS-001` atau field `requirement` tunggal) **harus dinormalisasi dulu** ke skema di atas sebelum bisa dieksekusi lewat pipeline.
