---
description: Generate ulang report Excel dari hasil run. Usage — /report [modul|file-json] 
---

Generate report Excel dari file hasil di `results/`.

- Jika $ARGUMENTS kosong → pakai file hasil PALING BARU di `results/` (abaikan file `_plan__*`).
- Jika $ARGUMENTS berisi nama modul → pakai run terbaru modul tersebut.
- Jika $ARGUMENTS berisi path file JSON → pakai file itu.
- Jika $ARGUMENTS = `all` → gabungkan seluruh run terbaru per modul menjadi satu workbook rekap lintas modul (`python scripts/generate_report.py --all`).

Jalankan `python scripts/generate_report.py <file...>`, lalu beri tahu user lokasi file Excel di `reports/` beserta ringkasan angka Summary-nya.
