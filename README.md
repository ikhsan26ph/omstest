# OMS Automation Testing Machine (Claude Code)

Mesin automation testing OMS berbasis **VS Code + Claude Code + Playwright MCP (browser agent)**.

## Setup (sekali saja)

1. Buka folder ini di VS Code, pastikan extension/CLI Claude Code terpasang (butuh Node.js ≥ 22, lihat `.nvmrc`).
2. Salin `config/env.example.md` menjadi `config/env.md`, isi link aplikasi + akun (jangan di-commit).
3. Taruh dokumen skenario per modul ke `scenario/<nama-modul>/` (analysis, ui-inventory, .feature, scenarios.json, coverage — skema: `scenario/README.md`). Contoh: `scenario/oms012-order-ftl-auto-stuffing/`.
4. Jalankan `claude` di folder ini. Saat pertama kali, setujui MCP server `playwright` (didefinisikan di `.mcp.json`).
5. Install dependency script report: `pip install openpyxl` (biasanya sudah ada).

## Cara Pakai

| Perintah | Fungsi |
|---|---|
| `/explore` | Login + petakan semua modul secara general → `explore/module-map.md` |
| `/smoke` | Cek cepat semua modul (halaman terbuka & render, read-only) |
| `/harvest-selectors <modul>` | Ekstrak selector asli aplikasi live → `shared/selector-map-*.md` |
| `/test-module <modul> [filter]` | Eksekusi skenario satu modul dari scenarios.json |
| `/report [modul\|all]` | Generate ulang Excel dari hasil run |
| `/task` | Perintah bebas, mis. "buatkan order ..." (**belum tersedia**) |

Contoh:

```
/explore
/test-module oms012 smoke
/test-module ftl-auto-stuffing priority:high
/test-module oms013 category:negative max:20
/report all
```

## Struktur

```
CLAUDE.md                  aturan & konvensi (dibaca otomatis Claude Code)
.claude/commands/          slash command: explore, smoke, harvest-selectors, test-module, report
.claude/agents/            subagent: oms-explorer, test-planner, test-executor, bug-triager
.mcp.json                  browser agent (Playwright MCP)
config/env.md              link + akun (gitignore, jangan di-commit)
config/env.example.md      contoh format env.md
explore/                   output /explore (module-map.md)
scenario/<modul>/          dokumen skenario per modul (skema: scenario/README.md)
task/                      fitur perintah bebas /task (belum diimplementasikan)
shared/                    lintas fitur: selector-map-order.md, decisions.md
scripts/                   run-playwright.sh, playwright_to_results.py, generate_report.py
tests/                     spec Playwright + helpers (fixtures login, parser env)
results/                   hasil run (JSON) + execution plan — gitignore
reports/                   report Excel — gitignore
artifacts/screenshots/     bukti screenshot — gitignore
```

## Alur Kerja Agent

```
User ── /explore ──────────▶ oms-explorer ──▶ explore/module-map.md
User ── /harvest-selectors ▶ (browser) ─────▶ shared/selector-map-*.md
User ── /test-module X ────▶ test-planner ──▶ execution plan (batch)
                             test-executor ─▶ results/X__runId.json + screenshot
                             bug-triager ───▶ klasifikasi failed (BUG / GAP / TEST ISSUE)
                             generate_report.py ─▶ reports/X__runId.xlsx
```
