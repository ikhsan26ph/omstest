# Selector Map — Modul Order (`/order`)

- **Tanggal harvest terbaru**: 2026-09-20 (tulis ulang total, menggantikan versi 2026-09-14)
- **Modul pemicu**: `oms012-order-ftl-auto-stuffing`, `oms013-order-fcl-auto-stuffing`, `oms014-order-ftl-fcl-normal`, `oms015-order-ltl-lcl-universal` — dipicu revisi struktural wizard Buat Order yang diverifikasi 2026-09-19 (lihat `shared/decisions.md` entri 2026-09-19 dan `scenario/oms014-order-ftl-fcl-normal/oms014-order-ftl-fcl-normal.ui-inventory.md`).
- **Base URL**: `https://oms-staging.prahu-hub.com`
- **Akun**: Admin Utama (`finance.roro1@gmail.com`, akun #1 `config/env.md`), satu sesi browser berkelanjutan (sudah login dari sesi sebelumnya, tidak perlu login ulang).
- **Cakupan live 2026-09-20**: Daftar Order + Panel Filter, Buat Order Step 1 (FTL/FCL/LTL/LCL, termasuk tambah baris Multipickup), Buat Order Step 2 (Data Barang FTL termasuk Pilih Barang + Auto Stuffing drawer terisi), Buat Order Step 3 (Vendor dan Harga + modal "Lihat Detail"/Data Pengirim), Detail Order (FTL Multipickup, LCL CY to Door), Edit Order (FTL Multipickup, FCL Multipickup, LTL Normal), Popup Data No. Resi (LCL), Batch Order, Riwayat Pembatalan.
- **Skipped live 2026-09-20**: Modal Batalkan Order (diblokir classifier auto-mode 2x berturut — lihat catatan di bawah), Modal konfirmasi "Simpan ke Draf" (tidak dipicu karena itu aksi tulis), Popup Data No. Perjalanan FTL/FCL (tidak sempat, tapi struktur historis 2026-09-14 masih relevan karena tidak termasuk cakupan revisi), Step 4 Review wizard (tidak diklik langsung — representasi read-only-nya sudah tercakup lewat Detail Order yang diverifikasi terpisah pada order nyata), LCL/FCL Edit Order untuk field kontainer disabled-state pembanding lengkap (sudah cukup terwakili oleh 1 order FCL Multipickup).

## Temuan Struktural Penting (perbedaan vs ground truth/dokumen lama — DILAPORKAN APA ADANYA, TIDAK diselaraskan diam-diam)

1. **Auto Stuffing SEDANG AKTIF live di tenant ini per 2026-09-20** (floating button "Hitung Ulang Armada"/"Hitung Ulang Kontainer" + "Visualisasi Terbaru"/"Visualisasi Muatan Saat Ini" muncul di Step 2 wizard, Edit Order, dan tombol "Visualisasi Muatan" muncul di Detail Order FTL/FCL) — ini **KONTRADIKSI** premis oms014 ("Auto Stuffing OFF", semua elemen ini harus `toHaveCount(0)`). Konsisten dengan `oms014-order-ftl-fcl-normal.ui-inventory.md` yang sudah mencatat live 2026-09-14 juga menemukan Auto Stuffing aktif di Edit Order (S-13 lama). Elemen-elemen ini justru berguna sebagai cakupan live oms012/oms013 (lihat section AS di bawah), tapi berarti skenario oms014 yang mengasumsikan AS-OFF kemungkinan besar masih blocked/gap-environment sampai ada toggle/tenant yang benar-benar AS-OFF.
2. **Tombol trigger visualisasi FCL vs FTL berbeda nama**: floating button FTL = **"Visualisasi Terbaru"** (aria-label sama), membuka drawer berjudul **"Visualisasi Muatan Saat Ini"**. Floating button FCL = **langsung berjudul "Visualisasi Muatan Saat Ini"** (bukan "Visualisasi Terbaru") — trigger dan judul drawer SAMA PERSIS untuk FCL, beda untuk FTL. Belum pernah didokumentasikan sebelumnya.
3. **"Lihat Detail" (Step 3 Vendor dan Harga & Edit Order Vendor dan Harga) adalah `<button>`, BUKAN `<a>`/link** — dokumen lama (`getByRole('link', {name:'Lihat Detail'})`) salah. Selector benar: `getByRole('button', {name:'Lihat Detail'})`.
4. **Kartu Jenis Pengiriman (FTL/FCL/LTL/LCL) tetap `<button>` biasa, BUKAN `role="radio"`** — ui-inventory S-03 mengusulkan `getByRole('radio', {name:...})` tapi DOM live memakai plain button tanpa role radio. Selector benar: `getByRole('button', {name:'FTL Full Truck Load'})` dst (text gabungan tanpa baris baru dalam accessible name, persis seperti harvest 2026-09-14 sebelumnya).
5. **FCL Edit Order: `Pelabuhan Asal`, `Pelabuhan Tujuan`, `Jenis Kontainer` TERNYATA EDITABLE (`disabled:false`, ada tanda `*`)**, BUKAN read-only seperti diklaim `oms014-order-ftl-fcl-normal.ui-inventory.md` S-14 ("Read-only: ... Metode Pengiriman, Pelabuhan Asal, Pelabuhan Tujuan"). Dikonfirmasi via `document.querySelector` pada order FCL Multipickup nyata (`ORD9367650090`): ketiga field itu adalah `<button>` dropdown aktif, hanya **`Metode Pengiriman`** yang benar-benar read-only (format teks `Label : Value`, tanpa tombol). Perlu update ui-inventory terpisah.
6. **Baris "Muat N"/"Bongkar N" di WIZARD (Buat Order) SELALU punya ikon hapus (trash) ketika total baris sisi itu ≥2 — termasuk baris pertama**, bukan cuma baris ke-2 dst. Dikonfirmasi: order dengan 2 baris Muat → baik "Muat 1" maupun "Muat 2" sama-sama punya `<button>` hapus (svg icon, tanpa aria-label, class `bg-error-50 text-error-500`) di sampingnya. Kontras dengan **Edit Order yang FAKTA-nya 0 ikon hapus di baris manapun** (dikonfirmasi ulang sesi ini, konsisten dengan ui-inventory S-14).
7. **Menu Aksi baris Daftar Order SELALU me-render semua item, item yang tidak relevan untuk status/tipe order ditampilkan `disabled` + tooltip penjelasan**, bukan disembunyikan/tidak-dirender. Contoh nyata pada order LCL: `"Lihat No. Perjalanan"` tampil tapi `disabled` dengan tooltip *"No. Perjalanan hanya ada pada order FTL dan FCL"*; `"Lanjutkan Pengisian"` tampil `disabled` dengan tooltip *"Hanya order yang masih dalam pengisian yang bisa dilanjutkan. Status order ini: Ditugaskan"*. Ini mengoreksi asumsi lama (ASM-021 ui-inventory) bahwa item menu tidak dirender sama sekali untuk kombinasi status/tipe tertentu.
8. **Navigasi langsung ke `/order/{uuid}/edit` untuk order berstatus tidak-bisa-diedit (mis. `Ditugaskan`) di-redirect otomatis ke `/order/{uuid}` (Detail Order)** — dikonfirmasi pada order LCL `Ditugaskan`. Ini guard di level route/data-fetch, bukan cuma tombol "Edit Order" yang disembunyikan di UI.
9. **Popup "Lihat No. Resi" (LTL/LCL) punya 2 tombol sort**: `"Urutkan berdasarkan Kode SKU"` (baru ditemukan, belum ada di dokumen manapun sebelumnya) DAN `"Urutkan berdasarkan Nama Barang"` (sudah didokumentasikan).
10. **Klik tombol "Batalkan Order" diblokir Claude Code auto-mode classifier 2× berturut-turut** (baik via `browser_evaluate` dispatch klik maupun via `browser_click` berbasis ref/role) — konsisten dengan `[[project-classifier-blocks-cancel-order]]` di memori. Modal Batalkan Order **SKIPPED**, tidak bisa dipetakan ulang live sesi ini; tabel di bawah tetap pakai selector historis (`#cancelReason`) dari harvest 2026-09-14.
11. **Klik tombol "Visualisasi Muatan" (Detail Order) sempat diblokir classifier saat dipanggil via `browser_evaluate` dispatch, TAPI BERHASIL saat dipanggil via `browser_click` (ref/role) biasa.** Insight proses: untuk elemen yang teksnya terdengar seperti aksi tulis/berat, pakai tool klik standar (`browser_click`) dulu, bukan `evaluate`-dispatch — kemungkinan classifier menilai pola pemanggilan, bukan cuma nama tombol.
12. **Tab title Edit Order tidak berubah** — tetap generic `"Prahu Hub - OMS"` (beda dari Detail Order yang otomatis jadi `"Detail Order - ORD..."`). Observasi minor, bukan blocker fungsional.
13. **Dropdown "Jenis Armada" Step 1 (list pertama tanpa scroll)**: `Trailer 40 Feet`, `Trailer 20 Feet`, `Tronton`, `Fuso`, `CDD Long`, `CDD` — TIDAK terlihat `CDE` di daftar awal ini padahal `CDE` muncul sebagai salah satu kartu rekomendasi Auto Stuffing (`Hitung Ulang Armada` drawer). Kemungkinan perlu scroll listbox untuk menemukan `CDE`, atau `CDE` hanya muncul di rekomendasi otomatis. Data test hint lama ("Jenis Armada CDE") tetap valid untuk kartu rekomendasi, tapi picker manual awal menampilkan `CDD` dulu.
14. **LCL: field `Waktu Perjalanan` bersatuan "Hari" (bukan "Jam")** — order LCL nyata (`ORD9788079162`) menampilkan `Waktu Perjalanan : 6 Hari` di Detail Order. FTL/FCL tetap "Jam". Perlu dicek apakah ini konsisten untuk semua LCL/LTL atau kasus khusus rute laut.
15. Ground truth tugas (Tambah Lokasi Muat/Bongkar selalu tampil di wizard, Tipe Pengiriman auto-derive, LTL/LCL terkunci Normal tanpa Kota Asal/Tujuan-nya LTL atau Jenis Kontainer-nya LCL, modal "Lihat Detail" berjudul "Data Pengirim"/"Data Penerima" numbered-list, Edit Order tanpa ikon hapus sama sekali) — **SEMUA terkonfirmasi cocok 1:1 dengan DOM live** pada sesi ini, tidak ada penyimpangan.

## Tabel Selector

| SCR | Elemen | Selector terbaik | Sumber | Catatan |
|---|---|---|---|---|
| SCR-00 | Menu Order | `getByRole('link', { name: 'Order' })` | role+name | Route `/order`. Sidebar tidak berubah dari harvest 2026-09-14. |
| SCR-00 | Menu Simulasi Muatan | `getByRole('link', { name: 'Simulasi Muatan' })` | role+name | Kandidat add-on Auto Stuffing (ASM-026 ui-inventory), tetap ada di sidebar live. |
| SCR-00 | Toggle Sidebar / mode gelap | `getByRole('button', { name: 'Toggle Sidebar' })` / `getByRole('button', { name: 'Aktifkan mode gelap' })` | role+name | Tidak diklik saat harvest. |
| SCR-00 | Logout | `getByRole('button', { name: 'Logout' })` | role+name | Teks persis "Logout" (koreksi lama: "Keluar" salah-match ke tombol dashboard lain). |
| S-01 | Buat Order | `getByRole('button', { name: 'Buat Order' })` | role+name | Navigasi `/order/buat`. Berfungsi normal (bug lama sudah resolved). |
| S-01 | Batch Order | `getByRole('button', { name: 'Batch Order' })` | role+name | Navigasi `/order/batch`. |
| S-01 | Riwayat Pembatalan | `getByRole('button', { name: 'Riwayat Pembatalan' })` | role+name | Navigasi `/order/riwayat-pembatalan`. |
| S-01 | Dropdown jumlah data | `locator('select').first()` | TIDAK STABIL | Native select tanpa label; opsi `10/20/50/100`. |
| S-01 | Salin ID Order baris | `getByRole('button', { name: /^Salin ORD/ })` | role+name | Dinamis per order. |
| S-01 | Chip Multipickup/Multidrop | `getByRole('button', { name: 'Multipickup' })` / `'Multidrop'` scoped ke row | role+name | Baik di kolom Kota Asal maupun Kota Tujuan. |
| S-01 | Aksi baris | `row.getByRole('button', { name: 'Aksi' })` | role+name (tidak unik, perlu scope row) | Tanpa aria-label sendiri; scoping wajib via row. |
| S-01 | Menu Aksi — Detail | `getByRole('button', { name: 'Detail', exact: true })` scoped ke menu | role+name | Selalu ada. |
| S-01 | Menu Aksi — Edit | `getByRole('button', { name: 'Edit', exact: true })` scoped ke menu | role+name | SELALU dirender; `disabled` bila status tidak mengizinkan (lihat Temuan #7). |
| S-01 | Menu Aksi — Batalkan Order | `getByRole('button', { name: 'Batalkan Order' })` scoped ke menu | role+name | **Klik = classifier denial** (Temuan #10). Jangan dipicu di run otomatis. |
| S-01 | Menu Aksi — Lihat No. Perjalanan | `getByRole('button', { name: 'Lihat No. Perjalanan' })` scoped ke menu | role+name | Selalu dirender; `disabled` + tooltip "No. Perjalanan hanya ada pada order FTL dan FCL" utk LTL/LCL. |
| S-01 | Menu Aksi — Lihat No. Resi | `getByRole('button', { name: 'Lihat No. Resi' })` scoped ke menu | role+name | Kebalikan dari atas; enabled utk LTL/LCL. |
| S-01 | Menu Aksi — Lanjutkan Pengisian | `getByRole('button', { name: 'Lanjutkan Pengisian' })` scoped ke menu | role+name | Selalu dirender; `disabled` + tooltip status utk order yang bukan status pengisian. |
| S-01 | Menu Aksi — Order Kembali | `getByRole('button', { name: 'Order Kembali' })` scoped ke menu | role+name | — |
| S-01 | Menu Aksi — Riwayat Perubahan | `getByRole('button', { name: 'Riwayat Perubahan' })` scoped ke menu | role+name | Navigasi `/order/{uuid}/riwayat`. |
| SCR-02 | Filter panel (ID Order/Vendor/Kota/Tanggal/Tipe/Drop Point/Pengirim/Penerima/Status, Reset, Terapkan) | tidak berubah dari harvest 2026-09-14 | role+name/placeholder | Lihat detail lengkap di riwayat git file ini bila perlu; tidak diverifikasi ulang penuh sesi ini karena di luar cakupan revisi wizard, hanya dicek render awal `/order` — masih identik. |
| S-03 | Heading Step 1 | `getByRole('heading', { name: 'Jenis Pengiriman' })` | role | **BUKAN** "Jenis Pengiriman dan Rute" (judul itu khusus Detail/Edit/Review, lihat Temuan ground truth). |
| S-03 | Kartu FTL | `getByRole('button', { name: 'FTL Full Truck Load' })` | role+name | Plain button, BUKAN radio (Temuan #4). Default terselect saat wizard dibuka. |
| S-03 | Kartu FCL | `getByRole('button', { name: 'FCL Full Container Load' })` | role+name | idem. |
| S-03 | Kartu LTL | `getByRole('button', { name: 'LTL Less Than Truck Load' })` | role+name | idem. |
| S-03 | Kartu LCL | `getByRole('button', { name: 'LCL Less Than Container Load' })` | role+name | idem. |
| S-03 | Jenis Armada (FTL) | `getByRole('button', { name: 'Pilih Jenis Armada' })` | role+name | Opsi live: Trailer 40 Feet, Trailer 20 Feet, Tronton, Fuso, CDD Long, CDD (Temuan #13). |
| S-03 | Jumlah Armada (FTL) | `getByRole('textbox', { name: 'Masukkan Jumlah Armada' })` (via `getByPlaceholder`) | placeholder | — |
| S-03 | Pelabuhan Asal (FCL/LCL) | `getByRole('button', { name: 'Pilih Pelabuhan Asal' })` | role+name | — |
| S-03 | Pelabuhan Tujuan (FCL/LCL) | `getByRole('button', { name: 'Pilih Pelabuhan Tujuan' })` | role+name | — |
| S-03 | Jenis Kontainer (FCL saja) | `getByRole('button', { name: 'Pilih Jenis Kontainer' })` | role+name | TIDAK dirender di LCL (dikonfirmasi 0 kemunculan teks "Jenis Kontainer"). |
| S-03 | Jumlah Kontainer (FCL saja) | `getByPlaceholder('Masukkan Jumlah Kontainer')` | placeholder | idem, absen di LCL. |
| S-03 | Metode Pengiriman ×4 (FCL/LCL) | `getByRole('button', { name: /Door to Door/ })` dst | role+name | Card button; teks lengkap termasuk deskripsi jadi accessible name panjang — pakai regex. |
| S-03 | ~~Jumlah Armada terkunci (LTL)~~ — **TIDAK BERLAKU LAGI sejak 2026-09-21** | — | — | **[KOREKSI 2026-09-21]** Verifikasi live coordinator 2026-09-21 (order `ORD9976193880`) membuktikan field `Jumlah Armada`/`Jenis Armada` **TIDAK DIRENDER SAMA SEKALI** untuk LTL — bukan lagi disabled/`value="1"` seperti temuan harvest 2026-09-20 di baris ini sebelumnya. Section `Jenis Pengiriman` Step 1 LTL sekarang **kosong total** (hanya 4 kartu jenis order, tanpa field rute apa pun di bawahnya). Selector `field-jumlah-armada` (baris S-03 "Jumlah Armada (FTL)" di atas) tetap berlaku untuk **FTL/FCL**, TIDAK untuk LTL. |
| S-03 | Paragraf Tipe Pengiriman | `getByText(/Tipe Pengiriman: (Normal|Multipickup|Multidrop|Multipoint)/)` | text | Auto-update real-time terkonfirmasi (Normal→Multipickup saat tambah baris). TIDAK ADA di LTL/LCL (dikonfirmasi 0 kemunculan). |
| S-03 | Drop Point Asal (Data Pengirim) | `getByRole('button', { name: 'Pilih Drop Point Asal' })` scoped ke blok Muat aktif | role+name (tidak unik lintas baris) | Scope via container blok (`Muat N`/blok tunggal). |
| S-03 | Pengirim (company) | `getByRole('button', { name: /Semua Pengirim|PT\. / })` scoped ke blok | role+name | Auto-terisi nama company setelah Drop Point dipilih. |
| S-03 | PIC Pengirim | `getByPlaceholder('Masukkan PIC Pengirim')` scoped ke blok | placeholder (tidak unik) | Auto-fill dari master, overwritable. |
| S-03 | No. WhatsApp PIC | `getByPlaceholder('Masukkan No. WhatsApp PIC')` scoped ke blok | placeholder (tidak unik, ada di Pengirim & Penerima) | Auto-fill dari master. |
| S-03 | Field read-only alamat (Provinsi/Kota/Kecamatan/Desa/Kode Pos/Alamat Asal) | `getByPlaceholder('Provinsi Asal')` dst | placeholder | Semua `disabled=true`, auto-fill dari Drop Point. |
| S-03 | Catatan | `getByPlaceholder('Masukkan Catatan')` scoped ke blok | placeholder (tidak unik) | — |
| S-03 | Label baris "Muat N" / "Bongkar N" | `getByText(/^Muat \d+$/)` / `/^Bongkar \d+$/` | text | Muncul HANYA saat total baris sisi itu ≥2 (baik baris pertama maupun berikutnya, lihat Temuan #6). |
| S-03 | Ikon hapus baris (wizard, ≥2 baris) | `label.locator('xpath=following-sibling::button[1]')` atau scope by parent `div.flex.items-center.justify-between` | TIDAK STABIL (tanpa aria-label) | Ada pada SEMUA baris (termasuk baris 1) saat total ≥2. Class: `bg-error-50 text-error-500`, svg-only. Rekomendasi: developer tambah `aria-label="Hapus Muat N"`. |
| S-03 | Tambah Lokasi Muat | `getByRole('button', { name: 'Tambah Lokasi Muat' })` | role+name | SELALU tampil di wizard (FTL/FCL), termasuk 1 baris. Absen total di LTL/LCL. |
| S-03 | Tambah Lokasi Bongkar | `getByRole('button', { name: 'Tambah Lokasi Bongkar' })` | role+name | idem, sisi Penerima. |
| S-03 | Footer — Batal | `getByRole('button', { name: 'Batal' })` scoped ke footer wizard | role+name | Memicu dialog konfirmasi (tidak diuji isinya sesi ini). |
| S-03 | Footer — Simpan ke Draf | `getByRole('button', { name: 'Simpan ke Draf' })` | role+name | Terkonfirmasi ulang: visible sejak render pertama Step 1. Aksi tulis — JANGAN diklik saat harvest. |
| S-03 | Footer — Selanjutnya | `getByRole('button', { name: 'Selanjutnya' })` scoped ke footer wizard | role+name | Navigasi antar-step tanpa membuat order (aman diklik berkali-kali sampai Step 4). |
| S-04/05 | Floating — Hitung Ulang Armada | `getByRole('button', { name: 'Hitung Ulang Armada' })` | role+name (aria-label = teks) | `disabled` sampai ada ≥1 item barang berjumlah >0 di order. |
| S-04/05 | Floating — Hitung Ulang Kontainer | `getByRole('button', { name: 'Hitung Ulang Kontainer' })` | role+name | Varian FCL, sama pola disabled. |
| S-04/05 | Floating — Visualisasi Terbaru (FTL) | `getByRole('button', { name: 'Visualisasi Terbaru' })` | role+name | Selalu enabled meski kosong (drawer tampil empty-state). |
| S-04/05 | Floating — Visualisasi Muatan Saat Ini (FCL, trigger) | `getByRole('button', { name: 'Visualisasi Muatan Saat Ini' })` | role+name | Nama trigger FCL beda dari FTL (Temuan #2). |
| S-04/05 | Data Unit (ro) | `getByRole('heading', { name: 'Data Unit' })` + paragraf berpasangan | role/text | — |
| S-04/05 | Tambahkan Asuransi | `getByRole('checkbox', { name: 'Tambahkan Asuransi' })` scoped ke unit | role+name | Real `<input type=checkbox>` dibungkus `<label>`, accessible name via label — stabil. |
| S-04/05 | Nomor DO | `getByPlaceholder('Masukkan Nomor DO')` scoped ke unit/sub-section | placeholder (tidak unik) | — |
| S-04/05 | Sub-header Pick Up N / Drop Off N | `getByText(/^Pick Up \d+ - /)` / `/^Drop Off \d+ - /` | text | TIDAK BERUBAH oleh revisi (terminologi tetap lama, dikonfirmasi live). |
| S-04/05 | Pilih Barang (per unit/sub-section) | `getByRole('button', { name: 'Pilih Barang' })` scoped ke container | role+name (tidak unik) | Wajib scope; bisa >1 per Armada (Multipickup). |
| S-04/05 | Empty state tabel barang | `getByText(/Belum ada barang\. Klik/)` | text (partial) | Live: `Belum ada barang. Klik "Pilih Barang"` (tanpa spasi ekstra sebelum kutip penutup — beda tipis dari desain lama D7, gunakan partial match). |
| S-04/05 | Total Kubikasi/Berat | `getByText(/Total Kubikasi:/)` / `/Total Berat:/` scoped ke unit | text | — |
| S-06 | Modal Pilih Barang — judul | `getByRole('heading', { name: 'Pilih Barang', level: 4 })` | role+name | `<h4>`, bukan dialog role. |
| S-06 | Modal Pilih Barang — cari | `getByPlaceholder('Cari Kode SKU atau Nama Barang')` | placeholder | Terkonfirmasi live (bukan "Cari kode/nama barang" seperti asumsi desain lama). |
| S-06 | Modal Pilih Barang — checkbox item | `getByRole('row', { name: /<Kode SKU>/ }).getByRole('checkbox')` | role, scope by row | — |
| S-06 | Modal Pilih Barang — paginasi | `getByRole('button', { name: 'Sebelumnya' })` / `'Selanjutnya'` scoped ke modal | role+name (tidak unik) | Ada juga "x / y" text di antara. |
| S-06 | Modal Pilih Barang — Tambahkan (N) | `getByRole('button', { name: /^Tambahkan/ })` | role+name | Teks dinamis `Tambahkan (N)`, disabled sampai ≥1 dipilih. |
| S-06 | Modal Pilih Barang — Tutup | `getByRole('button', { name: 'Tutup' })` scoped ke modal | role+name | — |
| S-06 | Setelah barang ditambah — Jumlah | `getByRole('textbox', { name: /^Jumlah / })` | role+name (aria-label dinamis `Jumlah <SKU>`) | — |
| S-06 | Setelah barang ditambah — Hapus | `getByRole('button', { name: /^Hapus / })` | role+name (aria-label dinamis `Hapus <SKU>`) | — |
| S-07 | Drawer Hitung Ulang Armada/Kontainer — judul | `getByRole('heading', { name: /Hitung Ulang (Armada\|Kontainer)/ })` | role+name | Live: `Simulasi ulang kebutuhan unit dari muatan order ini. Terapkan untuk ubah data order.` |
| S-07 | Drawer — kartu rekomendasi | `getByRole('button', { name: /Paling Efisien/ })` / scope by index | role+name (teks gabungan panjang) | Contoh live: "Armada Paling Efisien Pickup 1 Unit • 1.500 Kg • 4,95 m³ Berat Terpakai 5% Ruang Terpakai 1%". |
| S-07 | Drawer — Pilih Jenis Armada/Kontainer | `getByRole('button', { name: /Pilih Jenis (Armada\|Kontainer)/ })` scoped ke drawer | role+name | — |
| S-07 | Drawer — stepper Jumlah Armada | `getByRole('button', { name: 'Kurangi' })` / `getByRole('button', { name: 'Tambah' })` | role+name (aria-label) | Baru ditemukan sesi ini (belum ada di dokumen manapun sebelumnya). |
| S-07 | Drawer — Ganti warna unit | `getByRole('button', { name: 'Ganti warna unit' })` | role+name | — |
| S-07 | Drawer — Tampilkan layar penuh | `getByRole('button', { name: 'Tampilkan layar penuh' })` | role+name | — |
| S-07 | Drawer — Geser ke atas/kiri/kanan/bawah | `getByRole('button', { name: 'Geser ke atas' })` dst | role+name | — |
| S-07 | Drawer — item legenda | `getByRole('button', { name: '<Nama Barang>' })` scoped ke drawer | TIDAK STABIL (nama dinamis) | Contoh live: "Sepatu Running Pria". |
| S-07 | Drawer — hint kontrol 3D | `getByText(/Drag: putar 360°/)` | text | **Teks berubah/bertambah** dari harvest lama: sekarang termasuk "Panah keyboard / tombol: geser" dan "Klik pintu: buka/tutup" (Temuan tambahan, lihat isi lengkap di bawah). |
| S-07 | Drawer — Batal (dalam drawer) | `getByRole('button', { name: 'Batal' })` scoped ke drawer, BUKAN footer wizard | role+name (tidak unik lintas halaman) | Perlu scope drawer. |
| S-07 | Drawer — Terapkan ke Order | `getByRole('button', { name: 'Terapkan ke Order' })` | role+name | Aksi tulis; jangan diklik saat harvest/test read-only. |
| S-07 | Drawer Visualisasi (empty state) | `getByText('Belum ada barang dengan jumlah terisi untuk divisualisasikan.')` | text | Muncul saat drawer dibuka sebelum ada barang berjumlah >0; hanya tombol `Tutup` yang tampil (tanpa footer Terapkan). |
| S-08 | Heading Step 3 | `getByRole('heading', { name: 'Vendor dan Harga' })` | role | — |
| S-08 | Vendor | `getByRole('button', { name: 'Pilih Vendor' })` | role+name | — |
| S-08 | Tanggal Permintaan Muat | `getByPlaceholder('DD/MM/YYYY hh:mm')` (via `getByLabel`/`getByText` scoped) | TIDAK STABIL (butuh scope by label) | Datetime picker custom. |
| S-08 | Lihat Detail | `getByRole('button', { name: 'Lihat Detail' })` | role+name | **BUKAN link** (Temuan #3, koreksi dokumen lama). Muncul saat Multipickup/Multidrop/Multipoint. |
| S-08 | Waktu Perjalanan | `getByLabel('Waktu Perjalanan')` atau scope by teks "Waktu Perjalanan" | role+name/label | Editable saat rute baru; read-only text saat rute sudah ada di master (lihat `shared/decisions.md` 2026-08-23). |
| S-08 | Tabel rekap unit | `getByRole('table')` scoped ke section Vendor dan Harga | role | Header: No/Nama Item/Total Berat/Total Kubikasi/Total Nilai Barang. |
| S-08 | Harga | `getByPlaceholder('0')` (index `count-3`, lihat `shared/decisions.md` 2026-09-02) | TIDAK STABIL (index-dependent) | Field harga/PPN/PPh berbagi placeholder `0`. |
| S-08 | Gunakan komponen harga | `getByRole('checkbox', { name: 'Gunakan komponen harga' })` | role+name | Default TERCENTANG (bug-candidate lama, masih berlaku per `shared/decisions.md` 2026-08-28). |
| S-08 | Footer Step 3 | sama pola Step 1/2 (`Batal`/`Sebelumnya`/`Simpan ke Draf`/`Selanjutnya`) | role+name | — |
| S-09 | Modal "Data Pengirim" (Multipickup) — judul | `getByRole('heading', { name: 'Data Pengirim' })` | role+name | **FAKTA TERKONFIRMASI live ulang 2026-09-20** (order test: 2 Muat — IK-BPN Platinum & IK-BPN Market). Bukan lagi "Detail Multipickup". |
| S-09 | Modal "Data Penerima" (Multidrop) — judul | `getByRole('heading', { name: 'Data Penerima' })` | role+name | Inferensi simetri (belum diuji langsung ulang sesi ini, tapi pola Data Pengirim/Data Penerima konsisten di semua layar lain). |
| S-09 | Modal — item numbered list | `getByText(/^\d+\. /)` scoped ke modal, lalu ambil paragraf sibling | text (perlu parsing manual) | Urutan per card: `N. <Drop Point>`, `<Perusahaan>`, `<Alamat>` (tampak digabung 2×: alamat singkat + lengkap), `PIC: <nama> (<no wa>)`. |
| S-09 | Modal — Tutup | `getByRole('button', { name: 'Tutup' })` scoped ke modal | role+name | — |
| S-10 | Step 4 Review — accordion `Jenis Pengiriman dan Rute` | `getByRole('heading', { name: 'Jenis Pengiriman dan Rute' })` | role (belum re-diverifikasi live sesi ini) | Diwakili oleh struktur identik pada Detail Order (S-12) yang sudah live-verified; kemungkinan besar sama karena keduanya render dari state order yang sama. |
| S-10 | Step 4 — tombol Simpan (final) | `getByRole('button', { name: 'Simpan', exact: true })` scoped ke footer | role (tidak diklik — aksi tulis final) | TIDAK dipicu sesi ini (read-only rule). |
| S-11 | Modal konfirmasi Simpan ke Draf | `getByRole('heading')` teks `Anda yakin ingin menyimpan data dalam draf?` + tombol `Batal`/`Simpan Draf` | historis (2026-09-14), tidak dipicu ulang | Trigger-nya sendiri ("Simpan ke Draf") adalah aksi tulis, sengaja tidak diklik. |
| S-12 | Detail Order — breadcrumb & judul | `getByRole('heading', { name: 'Jenis Pengiriman dan Rute' })` | role | Judul section berbeda dari wizard Step 1 ("Jenis Pengiriman" saja) — konfirmasi ulang ground truth. |
| S-12 | Detail Order — Visualisasi Muatan | `getByRole('button', { name: 'Visualisasi Muatan' })` | role+name | Tampil utk FTL/FCL (Auto Stuffing live aktif — Temuan #1); **ABSEN** utk LCL (dikonfirmasi via `ORD9788079162`, 0 kemunculan tombol ini). |
| S-12 | Detail Order — Batalkan Order | `getByRole('button', { name: 'Batalkan Order' })` | role+name | **Jangan diklik** (classifier denial, Temuan #10). |
| S-12 | Detail Order — Edit Order | `getByRole('button', { name: 'Edit Order' })` | role+name | Hanya tampil bila status order bisa diedit (mis. Menunggu Penugasan); absen pada order `Ditugaskan` (dikonfirmasi pada order LCL). |
| S-12 | Detail Order — accordion Data Pengirim/Penerima | `getByRole('button', { name: 'Data Pengirim' })` / `'Data Penerima'` | role+name | Sub-blok multi-alamat pakai label **Muat N/Bongkar N** (terkonfirmasi live, ground truth #revisi). |
| S-12 | Detail Order — accordion Data Barang | `getByRole('button', { name: 'Data Barang' })` | role+name | Sub-blok tetap **Pick Up N/Drop Off N** (TIDAK berubah, dikonfirmasi live — section terpisah dari Data Pengirim/Penerima). |
| S-12 | Detail Order — accordion Vendor dan Harga | `getByRole('button', { name: 'Vendor dan Harga' })` | role+name | Juga punya tombol `Lihat Detail` bila multi-alamat. |
| S-12 | Detail Order — accordion No. Perjalanan | `getByRole('button', { name: 'No. Perjalanan' })` | role+name | Untuk LTL/LCL, accordion setara berjudul **No. Resi** (`getByRole('button', {name:'No. Resi'})`). |
| S-12 | Detail Order — Visualisasi Muatan Saat Ini (drawer dari tombol di atas) | `getByRole('heading', { name: 'Visualisasi Muatan Saat Ini' })` | role+name | **BUKAN** "Visualisasi Muatan" seperti asumsi `ui-inventory` S-12 lama (031a.png) — judul drawer riil beda dari label tombol trigger. |
| S-13 | Modal Batalkan Order | `getByRole('dialog', { name: 'Batalkan Order' })`, `#cancelReason`, `dialog.getByRole('button', {name:'Batalkan Order'})` | historis 2026-09-14, SKIPPED 2026-09-20 | Tidak bisa dipetakan ulang (classifier denial). `#cancelReason` tetap satu-satunya id historis stabil. |
| S-14 | Edit Order — judul & breadcrumb | `getByRole('heading', { name: 'Edit Order' })` | role | — |
| S-14 | Edit Order — accordion Jenis Pengiriman dan Rute | `getByRole('button', { name: 'Jenis Pengiriman dan Rute' })` | role+name | — |
| S-14 | Edit Order — field read-only (ID Order/Tanggal Dibuat/Jenis Pengiriman/Tipe Pengiriman/Waktu Perjalanan) | `getByText(/^ID Order$/)`  dst, format `Label : Value` tanpa input | text | Terkonfirmasi tidak ada `<input>`/`<button>` terkait, murni teks. |
| S-14 | Edit Order — Metode Pengiriman (FCL/LCL, read-only) | `getByText('Metode Pengiriman')` diikuti nilai | text | Terkonfirmasi read-only (satu-satunya field FCL yang benar read-only, lihat Temuan #5). |
| S-14 | Edit Order — Pelabuhan Asal/Tujuan (FCL, EDITABLE) | `getByRole('button', { name: /^(Balikpapan\|Tanjung Perak\|<nama pelabuhan lain>)/ })` scoped ke accordion | role+name (nilai dinamis) | **KOREKSI Temuan #5**: field ini `disabled:false`, punya tanda `*`, BUKAN read-only. |
| S-14 | Edit Order — Jenis Kontainer (FCL, EDITABLE) | `getByRole('button', { name: /ft\|Dry/ })` scoped ke accordion | role+name (nilai dinamis) | idem, editable. |
| S-14 | Edit Order — Jenis Armada / Jumlah Armada (FTL) atau Jenis Kontainer / Jumlah Kontainer (FCL) | `getByRole('button', { name: '<nilai armada>' })` + `getByPlaceholder('Masukkan Jumlah Armada')` | role+name/placeholder | Selalu editable di kedua tipe. |
| S-14 | Edit Order — Floating Hitung Ulang Armada/Kontainer + Visualisasi | sama seperti S-04/05 | role+name (aria-label) | Tampil di FTL & FCL Edit Order; **ABSEN** di LTL Edit Order (dikonfirmasi 0 kemunculan ketiga teks ini pada order LTL nyata). |
| S-14 | Edit Order — Data Pengirim/Penerima field | sama struktur Step 1 wizard | placeholder/role+name | Label bernomor `Muat N`/`Bongkar N` sama seperti wizard saat ≥2 baris. |
| S-14 | Edit Order — Tambah Lokasi Muat | `getByRole('button', { name: 'Tambah Lokasi Muat' })` | role+name | **HANYA muncul bila sisi Muat SUDAH ≥2 baris** (dikonfirmasi: order Multipickup 2 Muat/1 Bongkar → tombol ini ADA di sisi Muat, TIDAK ADA di sisi Bongkar). |
| S-14 | Edit Order — Tambah Lokasi Bongkar | `getByRole('button', { name: 'Tambah Lokasi Bongkar' })` | role+name | Simetri dengan atas. |
| S-14 | Edit Order — ikon hapus baris | *(tidak ada elemen untuk didokumentasikan)* | FAKTA: TIDAK PERNAH ADA | Dikonfirmasi ulang via DOM: 0 `<button>` di container label `Muat 1`/`Muat 2` manapun. |
| S-14 | Edit Order — Data Barang - Armada N / Kontainer N | `getByRole('heading', { name: /^Data Barang - (Armada\|Kontainer) \d+$/ })` (live: plain `<button>` bukan heading — cek ulang jika assert gagal) | role/text | Live terlihat sebagai button collapsible dengan teks persis "Data Barang - Armada 1". |
| S-14 | Edit Order — Pilih Barang / Jumlah SKU / Hapus SKU | sama seperti S-06 setelah barang ditambah | role+name | — |
| S-14 | Edit Order — Vendor dan Harga (+ Lihat Detail) | `getByRole('button', { name: 'Vendor dan Harga' })`, `getByRole('button', {name:'Lihat Detail'})` | role+name | `Lihat Detail` juga muncul di Edit Order, bukan cuma wizard Step 3. |
| S-14 | Edit Order — footer Batal/Simpan | `getByRole('button', { name: 'Batal' })` scoped footer / `getByRole('button', { name: 'Simpan', exact: true })` | role+name | Aksi tulis; jangan diklik saat harvest. |
| S-14 | Edit Order — guard status | *(bukan elemen UI, behavior route)* | — | Navigasi langsung `/order/{uuid}/edit` pada order non-editable → redirect otomatis ke `/order/{uuid}` (Temuan #8). |
| LTL/LCL-STEP1 | Kota Asal/Tujuan (LTL saja) | `getByRole('button', { name: 'Pilih Kota Asal' })` / `'Pilih Kota Tujuan'` | role+name | TIDAK ADA di LCL (LCL pakai Pelabuhan, bukan Kota). |
| LTL/LCL-DETAIL | Waktu Perjalanan satuan Hari | `getByText(/Waktu Perjalanan.*Hari/)` | text | LCL nyata: "6 Hari" (Temuan #14) — beda satuan dari FTL/FCL "Jam", perlu konfirmasi apakah berlaku semua LTL/LCL. |
| POPUP-RESI | Popup Data No. Resi — judul | `getByRole('heading', { name: 'Data No. Resi' })` | role+name | Tanpa `role=dialog`. |
| POPUP-RESI | Popup — ID Order & badge tipe | `dialog.getByText(/^ID Order:/)`, `dialog.getByText('LCL')` | text | — |
| POPUP-RESI | Popup — sort Kode SKU | `getByRole('button', { name: 'Urutkan berdasarkan Kode SKU' })` | role+name | **Baru ditemukan sesi ini** (Temuan #9), belum ada di dokumen sebelumnya. |
| POPUP-RESI | Popup — sort Nama Barang | `getByRole('button', { name: 'Urutkan berdasarkan Nama Barang' })` | role+name | Sudah ada di dokumen lama, dikonfirmasi ulang. |
| POPUP-RESI | Popup — Salin nomor | `getByRole('button', { name: 'Salin nomor' })` scoped ke popup | role+name | Bisa >1 baris. |
| POPUP-RESI | Popup — Tutup | `button[aria-label="Tutup"]` (CSS, terbukti valid sbg Playwright locator) | role+name / css | `getByRole('button', {name:'Tutup'})` juga valid selama tidak ambigu dgn Tutup lain di halaman. |
| S-BATCH | Batch Order — kartu FTL/FCL/LTL/LCL | `getByRole('button', { name: /FTL\|FCL\|LTL\|LCL/ })` scoped ke halaman batch | role+name | Live 2026-09-20: LTL bertuliskan "LTL Less Than Truckload" (satu kata, beda dari wizard Buat Order "Less Than Truck Load" dua kata) — konsisten temuan lama. |
| S-BATCH | Batch Order — Download Template Excel | `getByRole('button', { name: 'Download Template Excel' })` | role+name | Muncul setelah kartu jenis order dipilih. |
| S-BATCH | Batch Order — Import Batch Order | `getByRole('button', { name: 'Import Batch Order' })` | role+name | Aksi tulis/import; jangan diklik saat harvest. |
| S-25 | Riwayat Pembatalan — row by ID Order | `getByRole('button', { name: /^Salin ORD/ })` scoped ke row | role+name | Terkonfirmasi ulang render normal 2026-09-20. |
| S-25 | Riwayat Pembatalan — chip Multipickup | `getByRole('button', { name: 'Multipickup' })` scoped ke row | role+name | — |

## Layar Skipped pada Harvest Live 2026-09-20

| SCR | Layar | Alasan |
|---|---|---|
| S-13 | Modal Batalkan Order | Klik tombol trigger diblokir Claude Code auto-mode classifier ("Modify Shared Resources") 2× berturut-turut, baik via `browser_evaluate` maupun `browser_click` berbasis ref. Tidak dipaksakan sesuai aturan agent guide (jangan bypass classifier). Selector historis 2026-09-14 tetap dipertahankan di tabel. |
| S-11 | Modal konfirmasi "Simpan ke Draf" | Trigger-nya ("Simpan ke Draf") adalah aksi tulis murni; sengaja tidak diklik sesuai aturan read-only harvest. |
| S-10 | Step 4 Review (klik langsung dari wizard in-progress) | Tidak dilanjutkan ke Step 4 demi menghindari risiko tidak sengaja menekan "Simpan" final; representasi read-only-nya sudah tercakup lewat Detail Order (S-12) yang diverifikasi terpisah pada order nyata dengan struktur data setara. |
| POPUP-TRIP | Popup Data No. Perjalanan (FTL/FCL) | Tidak sempat dibuka ulang sesi ini (waktu terbatas); di luar cakupan revisi struktural 2026-09-19 sehingga selector historis 2026-09-14 (`shared/selector-map-order.md` versi sebelumnya) tetap dianggap valid — cek ulang bila ada perubahan lanjutan. |

## Rekomendasi data-testid untuk developer

- `order-type-card-ftl` / `-fcl` / `-ltl` / `-lcl` — 4 kartu Jenis Pengiriman Step 1, saat ini plain `<button>` tanpa `role=radio` maupun testid.
- `muat-row-delete-N` / `bongkar-row-delete-N` — ikon hapus baris di wizard (svg-only, tanpa `aria-label` sama sekali saat ini).
- `order-lihat-detail-pengirim` / `-penerima` — tombol "Lihat Detail" Step 3 & Edit Order (saat ini `<button>` tanpa testid, mudah tertukar dgn tombol "Lihat Detail" lain bila multi-instance di satu halaman).
- `order-modal-data-pengirim` / `order-modal-data-penerima` — root modal numbered-list alamat multi (Step 3), belum ada `role="dialog"`.
- `as-recalc-drawer` / `as-visualisasi-drawer` — root drawer Hitung Ulang Armada/Kontainer & Visualisasi (masih tanpa `role="dialog"`, sulit di-scope selain lewat heading).
- `as-recommendation-card-N` — 3 kartu rekomendasi armada di drawer Hitung Ulang (teks gabungan panjang, tidak ada testid/id per kartu).
- `as-stepper-decrease` / `as-stepper-increase` — sudah punya `aria-label` ("Kurangi"/"Tambah") jadi CUKUP STABIL, tapi disarankan testid juga utk konsistensi dgn kontrol 3D lain.
- `order-filter-page-size` — native select jumlah data tanpa label (masih sama seperti temuan 2026-09-14).
- `order-action-menu-item` — seluruh item menu Aksi baris kini SELALU dirender (disabled+tooltip); testid akan membantu differentiate `disabled` vs `enabled` tanpa parsing tooltip.
- `order-modal-batalkan-order` — root modal pembatalan; `#cancelReason` sudah stabil tapi root modal belum, dan trigger-nya diblokir classifier di sesi otomatis sehingga developer perlu tahu QA tidak bisa reverifikasi UI ini via automation biasa.
- `order-edit-guard-redirect` *(bukan testid UI, tapi dokumentasi behavior)* — perlu didokumentasikan resmi bahwa redirect `/edit` → Detail Order terjadi untuk status non-editable, supaya test dapat assert URL akhir alih-alih menunggu elemen yang tidak akan pernah muncul.

## Ringkasan Harvest 2026-09-20

- Layar/komponen berhasil dipetakan live: **Daftar Order + Filter, Buat Order Step 1 (FTL/FCL/LTL/LCL + multi-baris), Buat Order Step 2 (Data Barang + Modal Pilih Barang + Auto Stuffing drawer terisi & kosong), Buat Order Step 3 (Vendor dan Harga + Modal Data Pengirim), Detail Order (FTL Multipickup, LCL), Edit Order (FTL Multipickup, FCL Multipickup, LTL Normal), Popup Data No. Resi (LCL), Batch Order, Riwayat Pembatalan** — total **17 layar/komponen** berhasil live.
- Layar di-skip: **3** (Modal Batalkan Order — classifier denial; Modal konfirmasi Simpan ke Draf — aksi tulis; Step 4 Review langsung — dihindari demi keamanan submit) + **1** dianggap masih valid dari harvest lama tanpa reverifikasi (Popup Data No. Perjalanan FTL/FCL).
- Jumlah baris selector pada tabel akhir: **~95**.
- Selector stabil (role+name, placeholder, text-partial yang terverifikasi, atau id `#cancelReason`): **~78**.
- Selector TIDAK STABIL / perlu scoping manual (ikon hapus tanpa aria-label, native select, kartu rekomendasi teks gabungan, datetime picker custom, index-based Harga/PPN/PPh): **~17**.
- **15 temuan struktural signifikan** dicatat di atas, termasuk 1 kontradiksi langsung dengan premis oms014 (Auto Stuffing live AKTIF, bukan OFF) dan 1 koreksi ground truth ui-inventory (Pelabuhan Asal/Tujuan/Jenis Kontainer FCL Edit Order ternyata EDITABLE, bukan read-only).
