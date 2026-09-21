# Selector Map — Modul Entitlement Produk (`/setting/sistem` + sidebar Shipper)

- **Tanggal harvest**: 2026-09-20 (harvest pertama untuk file ini — sebelumnya belum ada `shared/selector-map-setting.md`).
- **Modul pemicu**: `oms000-jenis-produk` — **MODUL TERAKHIR** dari 8 modul harvest (order group, oms017, oms022, oms2324 sudah selesai lebih dulu).
- **Kenapa nama file `-setting` dan bukan `-jenis-produk`**: modul ini **tidak punya layar transaksional sendiri** — ia adalah pengaturan entitlement (`products[]`/`addOns[]`) tingkat client, diubah HANYA lewat API `PATCH /api/v1/service/registry/clients/{clientId}/entitlement` dengan header `X-Admin-Key` oleh **Admin platform** (bukan user OMS biasa). Tidak ada route/menu "Jenis Produk" atau "Entitlement" di UI Shipper/Admin OMS manapun (dikonfirmasi via sidebar lengkap di bawah — 0 match). Satu-satunya layar UI **berdedikasi** yang isinya benar-benar dikontrol entitlement adalah **`/setting/sistem`** (Pengaturan Sistem, R5/REQ-058…068); efek entitlement LAINNYA (R3/R6) murni berupa **tampil/hilangnya item sidebar** — bukan layar baru. Karena itu file ini diberi nama sesuai route dedicated (`/setting/*`), bukan nama modul.
- **Sumber acuan sebelum harvest**: `scenario/oms000-jenis-produk/oms000-jenis-produk.analysis.md` (tidak ada `ui-inventory.md` terpisah — UI Inventory ada di dalam `analysis.md`, section `UI-T00`…`UI-T11`, **seluruhnya usulan tanpa aset desain**, ASM-01); `explore/oms000-jenis-produk.md` (eksplorasi live 2026-09-07, entitlement tenant = `products:[OMS]` saja + 6 add-on, Pengaturan Sistem 2 item, sidebar Admin 25 route); `explore/module-map.md` baris #3/#24 (catatan historis 26 route & 8 accordion — **sudah usang**, lihat Temuan #1).
- **Base URL**: `https://oms-staging.prahu-hub.com`.
- **Akun**: Admin Utama (`finance.roro1@gmail.com`, akun #1 `config/env.md`), sesuai instruksi task (login akun #1 saja) — sesi browser sudah login dari sesi sebelumnya (tidak login ulang). **Vendor (akun #2) TIDAK dicek ulang live sesi ini** — instruksi task membatasi login ke akun #1; UI-T07 (Sidebar Vendor) mengandalkan dokumentasi lama (`explore/oms000-jenis-produk.md`, live 2026-09-07: 6 item — Order, Penugasan Tracking, Master Armada, Master Sopir, Akun Saya, Pusat Notifikasi, semua berprefix `/vendor-portal/*` kecuali Penugasan Tracking), **belum diverifikasi ulang 2026-09-20**.
- **Entitlement live dikonfirmasi ulang (indirect, dari efek UI, TANPA memanggil API entitlement)**: `products: [OMS]` saja (TMS tidak aktif), moda laut aktif (Master Pelabuhan/Pelayaran tampil), `AUTO_STUFFING` aktif (Simulasi Muatan tampil) — identik dengan temuan 2026-09-07. **Tidak ada PATCH entitlement dilakukan sesi ini** (murni observasi read-only via navigasi + `browser_evaluate`/snapshot).
- **Cakupan live 2026-09-20**: Sidebar lengkap Admin/Shipper (semua group + link, dengan `href` asli — bukan cuma nama), halaman **Pengaturan Sistem** (`/setting/sistem`) lengkap dengan isi ke-2 accordion (field-level, tanpa disimpan).
- **Skipped**:
  - **UI-T00 (API entitlement)** — tidak dipanggil sama sekali (bukan GET status, bukan PATCH) untuk menghindari risiko apa pun terhadap tenant testing; state entitlement disimpulkan murni dari efek UI (indirect), konsisten aturan read-only.
  - **UI-T01 (Login)** — sesi sudah login dari sebelumnya, tidak re-login (menghindari boros kuota "gagal 2x → stop" & tidak perlu, form login generik sudah terdokumentasi di modul lain).
  - **UI-T05 (Aplikasi mobile Sopir)** — aplikasi eksternal (native apps), tidak dapat diakses via Playwright browser MCP.
  - **UI-T07 (Sidebar Vendor)** — SKIPPED live, lihat catatan akun di atas (task membatasi ke akun #1 Admin Utama).
  - **UI-T09 (Navigasi TMS LKL Darat/Laut/Udara)** — SKIPPED, tidak reachable: entitlement live tenant testing = **OMS-only** (TMS tidak aktif), sehingga seluruh sidebar varian LKL (TMS) tidak eksis sama sekali untuk tenant ini tanpa PATCH entitlement (dilarang task ini).
  - **UI-T11 (Halaman error/guard deep-link)** — SKIPPED, sengaja TIDAK memaksa buka route yang hilang dari sidebar (mis. `/tracking-location`) via direct URL, sesuai instruksi eksplisit task ("JANGAN paksa buka route yang memang hilang dari sidebar via direct URL kecuali itu memang bagian eksplisit dari skenario resminya") dan konsisten dengan keputusan yang sama di `shared/selector-map-dashboard.md` Temuan #6.
  - **Master Pelabuhan/Pelayaran/Barang (isi halaman, bukan cuma nav-item)** — TIDAK dibuka detail; nama modul lain (oms015/master data) yang berwenang atas isi form-nya. Harvest ini hanya memverifikasi **kemunculan nav-item** sebagai bukti entitlement (cukup untuk REQ-039/041/042/070/071), bukan isi CRUD-nya.
  - **Kartu "Jenis Pengiriman" Step 1 Buat Order (UI-T10)** — TIDAK diulang; sudah live-verified baru-baru ini di `shared/selector-map-order.md` (S-03, harvest 2026-09-14/20): tetap 4 kartu FTL/FCL/LTL/LCL, **tidak ada kartu ke-5 "Air Freight"** meski `SERVICE_AIR_FREIGHT` aktif di entitlement (relevan REQ-077, tetap NEED-RECHECK apakah Air Freight order-type memang direncanakan untuk kanal OMS — bukan temuan baru sesi ini).

## Temuan Struktural Penting (perbedaan vs dokumen lama — DILAPORKAN APA ADANYA)

1. **Pengaturan Sistem tetap TEPAT 2 item (REQ-068), REPRODUCE ulang untuk ketiga kalinya** (2026-09-05 lama mencatat 8 item, 2026-09-07 & sekarang 2026-09-20 sama-sama 2 item) — `Durasi Kedaluwarsa Undangan Vendor` dan `Nomor WhatsApp CS`. Ini menguatkan kesimpulan `explore/oms000-jenis-produk.md`: **catatan 8-item di `explore/module-map.md` baris #24 sudah usang/basi**, bukan representasi entitlement tenant testing saat ini. **Rekomendasi tetap sama**: sebelum eksekusi skenario R5 (REQ-058…068), pastikan tim mengerti baseline live = 2 item (OMS-only), bukan 8 item (yang hanya berlaku bila TMS aktif/gabungan, REQ-067).
2. **Sidebar Admin tetap 25 route** (bukan 26 baseline sangat lama), dikonfirmasi ulang dengan `href` asli lengkap kali ini (sebelumnya cuma nama menu tanpa URL). **`Dashboard ▸ Tracking & Location` dan `Dashboard ▸ Progress Pengiriman` KEDUANYA absen** dari grup Dashboard (hanya 3 sub-item: Monitoring, Operasional, Distribusi & Muatan) — sesuai REQ-031 & REQ-032 (keduanya butuh TMS aktif, tenant ini OMS-only). Ini detail baru dibanding catatan lama yang hanya menyebut Tracking & Location saja; Progress Pengiriman ternyata JUGA tidak pernah tercatat eksplisit sebagai sub-item Dashboard di eksplorasi manapun sebelumnya (baik saat ada maupun tidak ada) — sekarang terkonfirmasi absen, konsisten spec.
3. **DUA menu ditemukan di sidebar live yang TIDAK ADA di matriks entitlement R3 (`analysis.md` sheet `SH`, 20 baris resmi)**: **`Master Waktu Perjalanan`** (`/master/waktu-perjalanan`) dan **`Master CS`** (`/master/cs`). Kedua menu ini tampil untuk state OMS-only tenant ini, tapi tidak punya baris REQ terkait sama sekali di dokumen sumber (xlsx sheet `SH` A3-E27 hanya 20 baris, tidak menyebut keduanya). Kemungkinan besar ini menu yang ditambahkan setelah matriks xlsx sumber dibuat, atau menu yang selalu tampil terlepas dari entitlement (di luar cakupan modul ini) — **bukan bug**, tapi **gap dokumentasi requirement** yang layak dicatat untuk update `analysis.md` R3 bila modul ini di-maintain lagi.
4. **`Master Drop Point` route asli = `/master/customer`** (BUKAN `/master/drop-point` seperti yang diusulkan `nav-item-master-drop-point` testid di `analysis.md` UI-T02) — konsisten dengan label lengkap "Master Drop Point (Include Customer)" di REQ-040 (menu ini memang menggabungkan data Customer). Selector role-based (`getByRole('link', {name:'Master Drop Point'})`) tetap valid dan tidak terpengaruh oleh detail route ini, tapi developer/executor yang mengandalkan `page.goto('/master/drop-point')` langsung akan salah.
5. **Struktur accordion Pengaturan Sistem: KEDUANYA default expanded** (bukan collapsed menunggu klik) — `browser_snapshot` menunjukkan atribut `[expanded]` pada accordion pertama, dan isi accordion kedua juga langsung terlihat di DOM tanpa interaksi. Field di dalamnya (spinbutton Durasi, combobox Satuan, textbox Nomor WhatsApp CS) sudah terisi nilai live: Durasi **2 Jam**, Nomor WhatsApp CS **kosong** (placeholder `08xxxxxxxxxx`, tidak ada value tersimpan).
6. **TIDAK ADA `id`, `data-testid`, `aria-label`, maupun `<label for>` pada ketiga field form Pengaturan Sistem** (dikonfirmasi lewat `browser_evaluate` khusus field — lihat metodologi di bawah) — `getByLabel(...)` **TIDAK akan berfungsi** meski secara visual field punya teks label ("Durasi \*", "Satuan \*", "Nomor WhatsApp CS"). Wajib pakai `getByRole('spinbutton'/'combobox'/'textbox')` di-scope ke container accordion masing-masing (tidak unik lintas halaman kalau tidak di-scope, karena role generik). Pola sama dengan temuan "aplikasi tidak punya `data-testid`" di modul Dashboard & Penugasan Tracking — konsisten lintas seluruh aplikasi.
7. **Tidak ditemukan toggle/opsi "Auto Stuffing" di halaman ini maupun di sidebar** — konsisten dengan Temuan #18 `explore/module-map.md` (2026-09-05: "Toggle add-on Auto Stuffing tidak ada" di UI maupun API `setting/system`). Add-on `AUTO_STUFFING` tetap murni dikontrol lewat entitlement API (R1), efeknya HANYA terlihat di sidebar (`Simulasi Muatan` tampil/hilang), bukan lewat toggle di halaman ini.
8. **Tidak ada request API dipanggil sesi ini untuk memverifikasi entitlement** (beda dari `explore/oms000-jenis-produk.md` 2026-09-07 yang membaca `GET /api/system/status` dari network listener) — kesimpulan "OMS-only, moda laut+darat+udara add-on aktif" pada harvest ini murni inferensi dari sidebar (indirect), bukan bukti langsung API. Cukup untuk tujuan harvest selector, tapi **jangan dipakai sebagai bukti entitlement definitif** tanpa silang-cek `explore/oms000-jenis-produk.md` atau re-run GET status.

## Metodologi Verifikasi Field (khusus Pengaturan Sistem)

Selain script `browser_evaluate` standar (button/a/input/select/textarea/role), dijalankan satu query tambahan khusus 3 field form untuk memastikan tidak ada `id`/`aria-label`/`<label for>` yang terlewat oleh query umum:

```js
[...document.querySelectorAll('input, select, textarea')].map(el => ({
  tag: el.tagName, type: el.type, id: el.id || null,
  ariaLabel: el.getAttribute('aria-label'), ariaLabelledby: el.getAttribute('aria-labelledby'),
  labelViaFor: el.id ? document.querySelector(`label[for="${el.id}"]`)?.innerText : null,
  closestLabel: el.closest('label')?.innerText, value: el.value
}))
```
Hasil: 3/3 field — semua `id`, `ariaLabel`, `ariaLabelledby`, `labelViaFor`, `closestLabel` = `null`. Hanya `value` yang terisi (`"2"`, `"JAM"`, `""`).

## Tabel Selector

| SCR | Elemen | Selector terbaik | Sumber | Catatan |
|---|---|---|---|---|
| SCR-00 | Sidebar — group toggle Dashboard | `getByRole('button', { name: 'Dashboard' })` | role+name | Collapsible group (bukan link), sama seperti `selector-map-dashboard.md` SCR-00. |
| SCR-00 | Sidebar — Monitoring | `getByRole('link', { name: 'Monitoring' })` | role+name | href `/monitoring`. |
| SCR-00 | Sidebar — Operasional | `getByRole('link', { name: 'Operasional' })` | role+name | href `/dashboard-operasional`. |
| SCR-00 | Sidebar — Distribusi & Muatan | `getByRole('link', { name: 'Distribusi & Muatan' })` | role+name | href `/dashboard-distribusi`. |
| SCR-00 | Sidebar — Tracking & Location / Progress Pengiriman | — | **TIDAK ADA** | Absen dari grup Dashboard (Temuan #2) — entitlement-gated TMS (REQ-031/032), tenant ini OMS-only. |
| SCR-00 | Sidebar — Order | `getByRole('link', { name: 'Order' })` | role+name | href `/order`. |
| SCR-00 | Sidebar — Penugasan Tracking | `getByRole('link', { name: 'Penugasan Tracking' })` | role+name | href `/penugasan-tracking`. |
| SCR-00 | Sidebar — Simulasi Muatan | `getByRole('link', { name: 'Simulasi Muatan' })` | role+name | href `/simulasi-muatan`. Entitlement-gated OMS + `AUTO_STUFFING` (REQ-036/076) — tampil karena keduanya aktif live. |
| SCR-00 | Sidebar — group toggle Master Wilayah | `getByRole('button', { name: 'Master Wilayah' })` | role+name | Bukan link tersendiri; berisi 4 sub-link. |
| SCR-00 | Sidebar — Master Provinsi | `getByRole('link', { name: 'Master Provinsi' })` | role+name | href `/master/provinsi`. |
| SCR-00 | Sidebar — Master Kota | `getByRole('link', { name: 'Master Kota' })` | role+name | href `/master/kota`. |
| SCR-00 | Sidebar — Master Kecamatan | `getByRole('link', { name: 'Master Kecamatan' })` | role+name | href `/master/kecamatan`. |
| SCR-00 | Sidebar — Master Kelurahan | `getByRole('link', { name: 'Master Kelurahan' })` | role+name | href `/master/kelurahan`. |
| SCR-00 | Sidebar — group toggle Master Operasional | `getByRole('button', { name: 'Master Operasional' })` | role+name | Berisi 9 sub-link (lihat baris berikut). |
| SCR-00 | Sidebar — Master Drop Point | `getByRole('link', { name: 'Master Drop Point' })` | role+name | href **`/master/customer`** (bukan `/master/drop-point`, Temuan #4). REQ-040, Setara. |
| SCR-00 | Sidebar — Master Waktu Perjalanan | `getByRole('link', { name: 'Master Waktu Perjalanan' })` | role+name | href `/master/waktu-perjalanan`. **Tidak ada REQ terkait di analysis.md** (Temuan #3) — selalu tampil, di luar matriks R3. |
| SCR-00 | Sidebar — Master Pelabuhan | `getByRole('link', { name: 'Master Pelabuhan' })` | role+name | href `/master/pelabuhan`. Entitlement-gated moda laut (REQ-041/070/074) — tampil krn `SERVICE_FCL`/`SERVICE_LCL` aktif live. |
| SCR-00 | Sidebar — Master Pelayaran | `getByRole('link', { name: 'Master Pelayaran' })` | role+name | href `/master/pelayaran`. Entitlement-gated moda laut (REQ-042/071/075) — sama seperti Pelabuhan. |
| SCR-00 | Sidebar — Master Barang | `getByRole('link', { name: 'Master Barang' })` | role+name | href `/master/barang`. Entitlement-gated OMS-only (REQ-039) — tampil krn produk OMS aktif. |
| SCR-00 | Sidebar — Master Kemasan | `getByRole('link', { name: 'Master Kemasan' })` | role+name | href `/master/kemasan`. |
| SCR-00 | Sidebar — Master Unit | `getByRole('link', { name: 'Master Unit' })` | role+name | href `/master/unit`. REQ-043 (Setara/varian TMS saat gabungan). |
| SCR-00 | Sidebar — Master Sopir | `getByRole('link', { name: 'Master Sopir' })` | role+name | href `/master/sopir`. REQ-044. |
| SCR-00 | Sidebar — Master CS | `getByRole('link', { name: 'Master CS' })` | role+name | href `/master/cs`. **Tidak ada REQ terkait di analysis.md** (Temuan #3) — selalu tampil, di luar matriks R3. |
| SCR-00 | Sidebar — Master Bandara / Master Maskapai | — | **TIDAK ADA** | Absen dari sidebar Shipper (eksklusif TMS LKL, R7/ASM-17 — bukan bagian matriks R3 Shipper sama sekali, konsisten). |
| SCR-00 | Sidebar — Manajemen Vendor | `getByRole('link', { name: 'Manajemen Vendor' })` | role+name | href `/manajemen-vendor`. REQ-045 (Setara). |
| SCR-00 | Sidebar — Pengaturan Akun | `getByRole('link', { name: 'Pengaturan Akun' })` | role+name | href `/pengaturan-akun`. REQ-046. |
| SCR-00 | Sidebar — Akun Saya | `getByRole('link', { name: 'Akun Saya' })` | role+name | href `/akun-saya`. REQ-047. |
| SCR-00 | Sidebar — Pengaturan Sistem | `getByRole('link', { name: 'Pengaturan Sistem' })` | role+name | href `/setting/sistem`. REQ-048/058 — isi halamannya lihat SCR-01. |
| SCR-00 | Sidebar — group toggle Pusat Notifikasi | `getByRole('button', { name: 'Pusat Notifikasi' })` | role+name | Berisi 2 sub-link. |
| SCR-00 | Sidebar — Pengaturan Notifikasi | `getByRole('link', { name: 'Pengaturan Notifikasi' })` | role+name | href `/setting/general`. |
| SCR-00 | Sidebar — Preferensi Notifikasi | `getByRole('link', { name: 'Preferensi Notifikasi' })` | role+name | href `/setting/preferensi-notifikasi`. |
| SCR-00 | Header — Toggle Sidebar | `getByRole('button', { name: 'Toggle Sidebar' })` | role+name | Tidak diklik saat harvest. |
| SCR-00 | Header — Mode gelap | `getByRole('button', { name: 'Aktifkan mode gelap' })` | role+name | Tidak diklik. |
| SCR-00 | Header — Notifikasi bell | `header.getByRole('button').filter({hasText: /^\d+$/})` | TIDAK STABIL | Accessible name = badge count (live `"63"`), sama temuan `selector-map-dashboard.md`. |
| SCR-00 | Header — Logout | `getByRole('button', { name: 'Logout' })` | role+name | Tidak diklik. |
| SCR-00 | Header — Konteks role | `getByText('Admin').first()`, `getByText('Administrator')` | text | Menampilkan role user login (bukan tenant Shipper/Vendor — beda pola dgn `selector-map-order.md` `header-tenant-context`, perlu cek ulang bila dipakai lintas modul). |
| SCR-00 | Widget Kuota Order | `getByRole('heading', { name: 'Kuota Order' })` | role+name | Live: 33/200 (16,5%) — identik dgn `selector-map-dashboard.md` (persisten semua halaman). |
| SCR-01 | Breadcrumb Beranda | `getByRole('link', { name: 'Beranda' })` | role+name | href `/`. |
| SCR-01 | Judul halaman | `getByRole('heading', { name: 'Pengaturan Sistem', level: 2 })` | role+name | — |
| SCR-01 | Accordion 1 — trigger | `getByRole('button', { name: /^Durasi Kedaluwarsa Undangan Vendor/ })` | role+name (regex, accessible name gabung judul+deskripsi) | Default **expanded** (Temuan #5). Deskripsi lengkap: "Batas waktu tautan undangan registrasi vendor berlaku sebelum kedaluwarsa". |
| SCR-01 | Accordion 1 — field Durasi | `getByRole('spinbutton')` di-scope container accordion 1 (mis. `.filter({has: page.getByText('Durasi *')})` atau urutan DOM pertama) | role (tidak ada label asosiasi — Temuan #6) | Live value: `2`. Wajib scope manual, `getByLabel('Durasi')` **TIDAK berfungsi**. |
| SCR-01 | Accordion 1 — field Satuan | `getByRole('combobox')` di-scope container accordion 1 | role (tidak ada label asosiasi) | Native `<select>`, opsi: `Select an option` (disabled), `Menit`, `Jam` (live selected). |
| SCR-01 | Accordion 2 — trigger | `getByRole('button', { name: /^Nomor WhatsApp CS/ })` | role+name (regex) | Default **expanded**. Deskripsi: `Nomor tujuan tombol "Hubungi Kami" di halaman publik: Lacak Pengiriman, Registrasi Vendor, dan Atur Kata Sandi Vendor`. |
| SCR-01 | Accordion 2 — field Nomor WhatsApp CS | `getByPlaceholder('08xxxxxxxxxx')` | placeholder | Live value kosong (`""`) — tanpa nomor tersimpan. Field ini juga TIDAK ada label asosiasi, tapi placeholder unik di seluruh halaman jadi aman dipakai. |
| SCR-01 | Item Pengaturan Sistem lain (Notifikasi Lokasi, Deteksi Tidak Update, Deteksi Keluar Jalur, Koridor Historis, Notifikasi Dini Berisiko Terlambat, Pembatasan Kelayakan Armada) | — | **TIDAK ADA** | 6 item khusus TMS (REQ-060…066) absen — sesuai REQ-068 (OMS-only = tepat 2 item), reproduce 3× (2026-09-07, 2026-09-20). |
| SCR-01 | Footer — Batal | `getByRole('button', { name: 'Batal' })` scoped footer | role+name | **TIDAK diklik** (harvest read-only). |
| SCR-01 | Footer — Simpan | `getByRole('button', { name: 'Simpan' })` scoped footer | role+name | Aksi tulis — **JANGAN diklik** saat harvest/verifikasi non-destruktif. |

## Rekomendasi data-testid untuk developer

- `nav-item-<slug>` pada seluruh 25 item sidebar (konsisten usulan `analysis.md` UI-T02/ASM-22/ASM-23) — saat ini 0 elemen sidebar punya `data-testid`, semuanya hanya bisa di-assert via `getByRole('link'/'button', {name})`, cukup stabil untuk saat ini tapi rawan kalau ada 2 label identik di masa depan (mis. "Master Pelabuhan" hanya muncul 1x sekarang, tapi kalau nanti ada varian Vendor dgn nama sama perlu scoping).
- `nav-item-master-waktu-perjalanan` dan `nav-item-master-cs` — dua menu yang ditemukan live tapi TIDAK ada di matriks requirement R3 (Temuan #3); selain kebutuhan testid, ini juga perlu diteruskan ke tim analisis untuk update `oms000-jenis-produk.analysis.md` sheet `SH` (source-of-truth xlsx kemungkinan sudah tidak lengkap).
- `setting-item-<slug>` pada tiap accordion Pengaturan Sistem (usulan `analysis.md` sudah ada) — saat ini accordion trigger hanya bisa di-assert via `getByRole('button', {name: /regex judul/})` karena accessible name menggabung judul+deskripsi tanpa pemisah jelas untuk automation.
- `setting-durasi-input` / `setting-durasi-satuan` / `setting-whatsapp-cs-input` — ketiga field form Pengaturan Sistem sama sekali tidak punya `id`/`aria-label`/`<label for>` (Temuan #6); `getByLabel()` tidak berfungsi meski field punya teks label visual "Durasi \*"/"Satuan \*". Prioritas **tinggi** karena field durasi & satuan tidak unik (perlu scoping manual DOM-order-dependent, rapuh terhadap perubahan layout).
- `system-settings-list` (root container 2 accordion) — usulan `analysis.md` UI-T06, untuk `toHaveCount(2)` assertion langsung tanpa perlu menghitung manual jumlah button trigger di halaman.
- `header-user-role-context` — badge "Admin"/"Administrator" di header tidak punya testid/aria-label sama sekali (SCR-00), berguna untuk skenario yang perlu memverifikasi role aktif tanpa bergantung teks lokal.

## Ringkasan Harvest — Modul `oms000-jenis-produk` (2026-09-20)

- **Layar/permukaan dipetakan live**: 2 — Sidebar lengkap Admin (SCR-00, 25 nav-item + header) dan halaman Pengaturan Sistem (SCR-01, 2 accordion + 3 field + footer).
- **Layar di-SKIP**: 6 — UI-T00 (API, dihindari demi read-only), UI-T01 (Login, sesi sudah aktif), UI-T05 (app mobile, di luar jangkauan Playwright web), UI-T07 (Sidebar Vendor, dibatasi akun #1 oleh task), UI-T09 (Navigasi TMS LKL, entitlement live tidak TMS), UI-T11 (halaman error/guard, sengaja tidak dipaksa via direct URL). Semua alasan skip dijelaskan di bagian "Skipped" atas.
- **Jumlah baris Tabel Selector**: 39 baris (33 sidebar/header + 6 Pengaturan Sistem, termasuk 3 baris "TIDAK ADA" sebagai bukti negatif entitlement).
- **Selector stabil** (role+name via label/href yang jelas): **~34 dari 39**.
- **Selector TIDAK STABIL / perlu scoping manual**: **~5** — notifikasi bell (badge count dinamis), field Durasi (spinbutton tanpa label), field Satuan (combobox tanpa label), (keduanya perlu scoping DOM-order dalam accordion 1).
- **8 Temuan struktural** dicatat, termasuk 1 reproduce ulang REQ-068 (Pengaturan Sistem tepat 2 item, kali ketiga dikonfirmasi) dan 2 gap dokumentasi requirement baru (Master Waktu Perjalanan & Master CS tidak ada di matriks R3 sumber).
- **Tidak ada perubahan data/setting** dilakukan sesi ini — accordion dibuka (memang sudah default-expanded, tidak perlu diklik), tombol Simpan/Batal tidak disentuh, tidak ada PATCH entitlement API.

---

## Rekap Akhir — Seluruh `shared/selector-map-*.md` (modul TERAKHIR dari 8, per 2026-09-20)

Hasil `ls shared/` setelah harvest modul ini:

| File | Modul pemicu | Cakupan route |
|---|---|---|
| `selector-map-dashboard.md` | `oms2324-dashboard` | `/monitoring`, `/dashboard-operasional`, `/dashboard-distribusi`, `/monitoring/riwayat` |
| `selector-map-order.md` | `oms012`/`oms014`/`oms015` (order group) | `/order`, `/order/buat`, wizard Step 1-4, Detail/Edit Order |
| `selector-map-penugasan.md` | `oms017-penugasan-tracking` | `/penugasan-tracking` + sub-halaman (Tambah, Detail, Edit, Riwayat, Isi Data Tracking, Penugasan Sopir Bongkar) |
| `selector-map-setting.md` | `oms000-jenis-produk` (**file ini, BARU**) | `/setting/sistem` + sidebar Shipper lengkap (25 nav-item) |
| `selector-map-tracking.md` | `oms022-public-tracking-improve` | `/tracking` (Lacak Pengiriman publik) + terkait penugasan |

**5 file selector-map** kini tersedia di `shared/`, mencakup seluruh 8 modul yang sudah di-harvest (order group = 3 modul berbagi `selector-map-order.md`). Modul `oms000-jenis-produk` adalah modul TERAKHIR — seluruh rangkaian harvest selector 8 modul **SELESAI** per tanggal ini.
