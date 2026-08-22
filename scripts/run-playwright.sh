#!/usr/bin/env bash
# Jalankan test Playwright satu modul, konversi ke skema results/, generate report Excel.
# Usage: scripts/run-playwright.sh <modul> [argumen playwright tambahan, mis. --grep SCN-0004]
set -uo pipefail

MODULE="${1:?Usage: run-playwright.sh <modul> [playwright args...]}"
shift || true
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# Playwright butuh Node 22 (node sistem masih 18).
NVM_NODE="$HOME/.nvm/versions/node/v22.19.0/bin"
[ -d "$NVM_NODE" ] && export PATH="$NVM_NODE:$PATH"

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
