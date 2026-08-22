# OMS Automation Testing Machine (Claude Code)

Mesin automation testing OMS berbasis **VS Code + Claude Code + Playwright MCP (browser agent)**.

## Setup (sekali saja)

1. Buka folder ini di VS Code, pastikan extension/CLI Claude Code terpasang (butuh Node.js untuk `npx`).
2. Isi `config/env.md` dengan link aplikasi + akun.
3. Taruh dokumen skenario per modul ke `knowledge/<nama-modul>/` (analysis, ui-inventory, .feature, scenarios.json, coverage). Contoh: `knowledge/oms012-order-ftl-auto-stuffing/`.
4. Jalankan `claude` di folder ini. Saat pertama kali, setujui MCP server `playwright` (didefinisikan di `.mcp.json`).
5. Install dependency script report: `pip install openpyxl` (biasanya sudah ada).

## Cara Pakai

| Perintah | Fungsi |
|---|---|
| `/explore` | Login + petakan semua modul secara general → `knowledge/module-map.md` |
| `/smoke` | Cek cepat semua modul (halaman terbuka & render, read-only) |
| `/test-module <modul> [filter]` | Eksekusi skenario satu modul dari scenarios.json |
| `/report [modul\|all]` | Generate ulang Excel dari hasil run |

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
.claude/commands/          slash command: explore, smoke, test-module, report
.claude/agents/            subagent: oms-explorer, test-planner, test-executor, bug-triager
.mcp.json                  browser agent (Playwright MCP)
config/env.md              link + akun (jangan di-commit)
knowledge/<modul>/         dokumen skenario per modul
results/                   hasil run (JSON) + execution plan
reports/                   report Excel
artifacts/screenshots/     bukti screenshot
scripts/generate_report.py JSON hasil → Excel (Summary, Detail, Failed_BugCandidates)
```

## Alur Kerja Agent

```
User ── /explore ──────────▶ oms-explorer ──▶ knowledge/module-map.md
User ── /test-module X ────▶ test-planner ──▶ execution plan (batch)
                             test-executor ─▶ results/X__runId.json + screenshot
                             bug-triager ───▶ klasifikasi failed (BUG / GAP / TEST ISSUE)
                             generate_report.py ─▶ reports/X__runId.xlsx
```
