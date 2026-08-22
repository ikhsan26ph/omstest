#!/usr/bin/env bash
# Jalankan test Playwright satu modul, konversi ke skema results/, generate report Excel.
# Usage: scripts/run-playwright.sh <modul> [argumen playwright tambahan, mis. --grep SCN-0004]
set -uo pipefail

MODULE="${1:?Usage: run-playwright.sh <modul> [playwright args...]}"
shift || true
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# Playwright butuh Node >= 22 (lihat .nvmrc). Pakai nvm bila tersedia, kalau tidak
# validasi versi node di PATH.
if [ -s "$HOME/.nvm/nvm.sh" ] && [ -f "$ROOT/.nvmrc" ]; then
  # shellcheck disable=SC1091
  . "$HOME/.nvm/nvm.sh"
  nvm use >/dev/null || { echo "nvm use gagal — jalankan 'nvm install' sesuai .nvmrc" >&2; exit 1; }
fi
NODE_MAJOR="$(node -e 'console.log(process.versions.node.split(".")[0])' 2>/dev/null || echo 0)"
if [ "$NODE_MAJOR" -lt 22 ]; then
  echo "Butuh Node >= 22 (terdeteksi: $(node -v 2>/dev/null || echo 'tidak ada node')). Install Node 22 atau pakai nvm dengan .nvmrc." >&2
  exit 1
fi

SPEC="tests/${MODULE}.spec.js"
if [ ! -f "$SPEC" ]; then
  echo "Spec $SPEC tidak ditemukan. Modul yang tersedia:" >&2
  ls tests/*.spec.js 2>/dev/null | sed 's|tests/||; s|\.spec\.js||' >&2
  exit 1
fi

npx playwright test "$SPEC" "$@"
PW_EXIT=$?   # exit != 0 saat ada test failed — hasil tetap dikonversi

RESULT_FILE="$(python3 scripts/playwright_to_results.py results/_playwright/last-run.json "$MODULE")" || exit 1
echo "Hasil run : $RESULT_FILE"
python3 scripts/generate_report.py "$RESULT_FILE"
exit "$PW_EXIT"
