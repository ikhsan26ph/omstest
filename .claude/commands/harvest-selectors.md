---
description: Ekstrak selector asli (id/data-testid/aria) tiap layar sebuah modul. Usage — /harvest-selectors <modul>
---

Untuk modul $1: cari folder yang cocok di `knowledge/` (boleh fuzzy match).
Baca indeks layar (SCR-xx) dari `*_ui-inventory.md` modul tersebut, lalu buka
setiap layar itu memakai browser (login pakai `config/env.md`).

Di tiap layar jalankan `browser_evaluate` dengan script:

```js
[...document.querySelectorAll('button, a, input, select, textarea, [role="button"], [role="tab"], [role="menuitem"]')].map(el => ({
  tag: el.tagName,
  id: el.id || null,
  testid: el.getAttribute('data-testid') || null,
  name: el.getAttribute('name') || null,
  aria: el.getAttribute('aria-label') || null,
  placeholder: el.getAttribute('placeholder') || null,
  text: el.innerText?.trim().slice(0, 40) || null,
  disabled: el.disabled || el.getAttribute('aria-disabled') === 'true' || null
}))
```

Aturan:
- Read-only: boleh membuka modal/drawer/tab untuk memetakan isinya, lalu tutup
  lagi. DILARANG submit, simpan, atau mengubah data apa pun.
- Untuk layar yang butuh precondition data (mis. halaman Edit Order), pakai data
  yang sudah ada dengan hanya MEMBUKA halamannya, jangan menyimpan perubahan.
- Layar yang tidak bisa dicapai tanpa aksi tulis → tandai "SKIPPED" + alasannya.

Simpan hasil ke `knowledge/<modul>/selector-map.md` dengan format tabel:

| SCR | Elemen (nama sesuai ui-inventory) | Selector terbaik | Sumber | Catatan |

Pemilihan "Selector terbaik", urutan prioritas:
1. data-testid (jika ada)
2. id yang stabil — BUKAN auto-generated (tolak pola `:r12:`, id berisi angka
   acak/hash, class css-xxxxx)
3. getByRole(role, { name })
4. getByLabel / placeholder

Elemen tanpa selector stabil sama sekali → tetap masukkan ke tabel dengan
Sumber = "TIDAK STABIL", kumpulkan juga di section akhir file berjudul
"## Rekomendasi data-testid untuk developer" berisi usulan nilai data-testid
(pakai usulan yang sudah ada di ui-inventory bila tersedia).

Di akhir, laporkan ringkasan: jumlah layar dipetakan/di-skip, jumlah elemen,
berapa yang stabil vs tidak stabil.
