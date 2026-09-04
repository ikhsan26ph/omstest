# Module Map — OMS (PT. OMESH)

Hasil eksplorasi `/explore` pada 2026-08-22 (run ketiga; run pertama 2026-08-21). Update 2026-09-04 (pagi): re-explore fokus modul **Order** (`oms012-order-ftl-auto-stuffing`) — verifikasi cepat sidebar top-level + pemetaan detail 15 layar Order (lihat section "Detail Layar Modul Order"). **1 perubahan struktural** ditemukan pada grup Dashboard (lihat catatan di bawah tabel). Update 2026-09-04 (lanjutan): re-explore fokus varian **FCL** (`oms013-order-fcl-auto-stuffing`) — lihat section "Detail Layar Modul Order — Varian FCL".

## Info Login & Environment

- **Base URL**: https://oms-staging.prahu-hub.com
- **Login**: Sukses percobaan pertama, redirect otomatis ke `/monitoring` (akses root `/` juga redirect ke sana).
- **Selector login terbukti**: `getByRole('textbox', {name:'Masukkan Email'})`, `getByRole('textbox', {name:'Masukkan Password'})`, `getByRole('button', {name:'Login'})`. Link "Lupa Password?" → `/lupa-password`.
- **Tenant/Perusahaan**: PT. OMESH — **tidak ada dialog pemilihan tenant** (single-tenant).
- **Role terdeteksi**: Administrator (akun `finance.roro1@gmail.com`). Seluruh 26 menu dapat diakses, tidak ada indikasi pembatasan role. Perbandingan lintas-role belum bisa dilakukan (akun #3 di `config/env.md` belum diisi).
- **Struktur sidebar (update 2026-09-04)**: 4 grup collapsible — **Dashboard** (Monitoring, Tracking & Location, Operasional, **Distribusi & Muatan** — route baru `/dashboard-distribusi`, menggantikan "Progres Pengiriman"), **Master Wilayah** (Provinsi/Kota/Kecamatan/Kelurahan), **Master Operasional** (Drop Point/Waktu Perjalanan/Pelabuhan/Pelayaran/Barang/Kemasan/Unit/Sopir/CS), **Pusat Notifikasi** (Pengaturan Notifikasi, Preferensi Notifikasi); sisanya item level-1. Total tetap 26 route.
- **Widget "Kuota Order"** persisten di sidebar bawah: 1/200 (0,5%) pada run 2026-08-22 — belum di-recheck pada run 2026-09-04 (fokus ke Order, bukan widget global).

## Tabel Modul

| # | Modul | Route | Jenis Halaman | Aksi Utama | Ada Dokumen Skenario? | Catatan |
|---|---|---|---|---|---|---|
| 1 | Dashboard ▸ Monitoring | /monitoring | Dashboard (peta + statistik) | Perbesar/Perkecil, Layar Penuh, filter "Semua Customer"/"Semua Kasus", link Riwayat → /monitoring/riwayat, link Lacak → /tracking-location?orderCode=... | Tidak | Halaman default setelah login |
| 2 | Dashboard ▸ Distribusi & Muatan | /dashboard-distribusi | (belum dieksplorasi detail — hanya terkonfirmasi ada di sidebar 2026-09-04) | — | Tidak | **BARU 2026-09-04**, menggantikan posisi "Progres Pengiriman" (`/progres-pengiriman`, route lama sudah hilang dari sidebar). Isi halaman belum dipetakan, perlu explore/smoke lanjutan |
| 3 | Dashboard ▸ Tracking & Location | /tracking-location | Form pencarian + tab | Cari (disabled sampai ID Order & Nopol dipilih) | Tidak | Tab: Tracking Terkini (default), Riwayat Tracking |
| 4 | Dashboard ▸ Operasional | /dashboard-operasional | Dashboard analitik (chart) | Filter periode (Harian/Mingguan/Bulanan/Tahunan/Pilih Tanggal), dropdown Tipe Order, Export | Tidak | Breadcrumb "Dashboard", bukan "Beranda" seperti halaman lain (inkonsistensi kecil) |
| 5 | Order | /order | List/tabel (Daftar Order) | "Buat Order" (✅ berfungsi normal per 2026-09-04), "Batch Order", "Riwayat Pembatalan", Filter, kolom Aksi per baris | **Ya** — `oms012-order-ftl-auto-stuffing`, `oms013-order-fcl-auto-stuffing`, `oms014-order-ftl-fcl-normal`, `oms015-order-ltl-lcl-universal` | 166 data per 2026-09-04 (naik dari 14). Detail 15 layar: lihat section "Detail Layar Modul Order" di bawah |
| 6 | Penugasan Tracking | /penugasan-tracking | List/tabel | "Tambah Penugasan", Filter | **Ya** — `oms017-penugasan-tracking` | 1 data (per 2026-08-22, belum di-recheck 2026-09-04) |
| 7 | Simulasi Muatan | /simulasi-muatan | Wizard/tool kalkulasi | Radio unit (Armada/Kontainer), "Pilih Barang", "Cek Visualisasi", "Lanjutkan Order" (disabled) | Tidak | Tool kalkulasi muatan, bukan CRUD biasa |
| 8 | Master Wilayah ▸ Master Provinsi | /master/provinsi | List/tabel CRUD | "Tambah Provinsi" (button, bukan link), Filter, Riwayat; per baris Edit/Hapus Data | Tidak | 38 data, 2 halaman |
| 9 | Master Wilayah ▸ Master Kota | /master/kota | List/tabel CRUD | "Tambah Kota" (link → /master/kota/tambah), Filter, Riwayat | Tidak | 514 data, 26 halaman |
| 10 | Master Wilayah ▸ Master Kecamatan | /master/kecamatan | List/tabel CRUD | "Tambah Kecamatan" (link → tambah), Filter, Riwayat | Tidak | 7.286 data |
| 11 | Master Wilayah ▸ Master Kelurahan | /master/kelurahan | List/tabel CRUD | "Tambah Kelurahan" (link → tambah), Filter, Riwayat | Tidak | 83.762 data |
| 12 | Master Operasional ▸ Master Drop Point | /master/customer | List/tabel CRUD | "Tambah Perusahaan" (link → /master/customer/tambah), Filter, Riwayat | Tidak | Heading "Master Drop Point", tombol tambah "Tambah Perusahaan" — label tidak konsisten. 12 data |
| 13 | Master Operasional ▸ Master Waktu Perjalanan | /master/waktu-perjalanan | List/tabel CRUD | "Tambah Waktu Perjalanan" (link), "Perbarui Waktu Perjalanan", Riwayat, Filter | Tidak | 10 data |
| 14 | Master Operasional ▸ Master Pelabuhan | /master/pelabuhan | List/tabel CRUD | "Tambah Pelabuhan" (link), Filter, Riwayat | Tidak | 11 data |
| 15 | Master Operasional ▸ Master Pelayaran | /master/pelayaran | List/tabel CRUD | "Tambah Pelayaran" (link), Filter, Riwayat | Tidak | 9 data |
| 16 | Master Operasional ▸ Master Barang | /master/barang | List/tabel CRUD | "Tambah Barang" (link), Filter, Riwayat | Tidak | 23 data |
| 17 | Master Operasional ▸ Master Kemasan | /master/kemasan | List/tabel CRUD | "Tambah Kemasan" (link), Filter, Riwayat | Tidak | 10 data |
| 18 | Master Operasional ▸ Master Unit | /master/unit | List/tabel, 3 tab | Tab "Armada"/"Jenis Armada"/"Jenis Kontainer", "Tambah Armada", Filter | Tidak | List dikelompokkan per vendor |
| 19 | Master Operasional ▸ Master Sopir | /master/sopir | List/tabel CRUD | "Tambah Sopir", Filter | Tidak | Dikelompokkan per vendor (2 vendor). Tidak punya tombol "Riwayat" (inkonsisten dgn master lain) |
| 20 | Master Operasional ▸ Master CS | /master/cs | List/tabel CRUD | "Tambah Customer Service" (link → /master/cs/tambah), Filter, Riwayat | Tidak | 1 data, expandable "2 Vendor". Title tab browser: "Master Customer Service" |
| 21 | Manajemen Vendor | /manajemen-vendor | List/tabel CRUD | "Tambah Vendor" (link → /manajemen-vendor/tambah), Filter | Tidak | 13 data, status "Menunggu"/"Aktif"/"Tidak Aktif" |
| 22 | Pengaturan Akun | /pengaturan-akun | List/tabel, 2 tab | Tab "Sub User"/"Hak Akses" ⚠️, "Tambah Sub User", Riwayat, Filter | Tidak | Tab "Hak Akses" tidak berfungsi — lihat Temuan Janggal #2 |
| 23 | Akun Saya | /akun-saya | Detail/profile | "Edit Informasi", "Ubah Password", Riwayat | Tidak | Menampilkan Nama, Email, No WA, Bagian Staff |
| 24 | Pengaturan Sistem | /setting/sistem | Form setting (accordion) | Batal, Simpan | Tidak | SLA, radius notifikasi, deteksi keluar jalur, kelayakan armada, dll |
| 25 | Pusat Notifikasi ▸ Pengaturan Notifikasi | /setting/general | Form setting (list toggle) | Switch global, Batal, Simpan | Tidak | — |
| 26 | Pusat Notifikasi ▸ Preferensi Notifikasi | /setting/preferensi-notifikasi | Form setting per kategori | Toggle per kategori, Batal, Simpan | Tidak | Preferensi personal |

## Detail Layar Modul Order (fokus `oms012-order-ftl-auto-stuffing`, eksplorasi 2026-09-04)

Re-explore read-only (tanpa submit final apa pun) atas seluruh sub-layar Order yang dicakup dokumen skenario oms012. Dipetakan setelah 287 skenario oms012 sudah dieksekusi & ditriase (lihat `results/_triage__oms012-order-ftl-auto-stuffing__20260904-130000.md`) — tabel ini melengkapi info navigasi/struktur, bukan mengulang hasil testing.

| Layar | Route/URL | Jenis | Aksi Utama | Catatan |
|---|---|---|---|---|
| Daftar Order | `/order` | List/tabel | "Buat Order", "Batch Order", "Riwayat Pembatalan", Filter, Aksi per baris | Panel filter selalu tampil (bukan toggle) |
| Buat Order — Step 1 Data Pengiriman | `/order/buat` | Wizard step 1 | Pilih FTL/FCL/LTL/LCL, Jenis & Jumlah Armada, Tipe Pengiriman, Data Pengirim/Penerima, Selanjutnya/Simpan ke Draf/Batal | Pilih Drop Point Tujuan auto-fill PIC Penerima & No. WA dari master data |
| Buat Order — Step 2 Data Barang | `/order/buat` (in-place) | Wizard step 2 | "Pilih Barang", "Hitung Ulang Armada", "Visualisasi Terbaru", input Jumlah per SKU | Validasi inline "Minimal 1 baris barang" berfungsi baik |
| ↳ Modal "Pilih Barang" | dalam Step 2 | Modal | Cari SKU, checkbox pilih, paginasi, Tambahkan/Tutup | — |
| ↳ Drawer "Hitung Ulang Armada" (Auto Stuffing) | dalam Step 2 | Drawer rekomendasi | 3 kartu rekomendasi armada, visualisasi 3D interaktif, "Terapkan ke Order"/"Batal" | Muncul untuk FTL sesuai ekspektasi |
| Buat Order — Step 3 Vendor dan Harga | `/order/buat` (in-place) | Wizard step 3 | Pilih Vendor, Tanggal Permintaan Muat, Waktu Perjalanan, Harga, checkbox komponen harga | Semua field wajib berfungsi normal |
| Buat Order — Step 4 Review | `/order/buat` (in-place) | Wizard step 4 | "Visualisasi Muatan", Sebelumnya, Simpan ke Draf, Simpan | Data Step 1-3 tampil ringkas dengan benar |
| ↳ Popup "Visualisasi Muatan" (versi wizard) | dalam Step 4 | Popup 3D | Model 3D interaktif, Tutup | Berfungsi normal — beda dari versi Detail Order (lihat Temuan #10) |
| Batch Order | `/order/batch` | Form upload | Pilih kartu tipe pengiriman (FTL/FCL/LTL/LCL), "Download Template Excel", drag&drop, "Import Batch Order" | Struktur beda dari asumsi lama — lihat Temuan #8 |
| Detail Order | `/order/{id}` | Detail (accordion) | "Visualisasi Muatan", "Batalkan Order", "Edit Order", accordion per section termasuk "No. Perjalanan" | — |
| Edit Order | `/order/{id}/edit` | Form edit | "Hitung Ulang Armada", "Visualisasi Terbaru", field lengkap, Batal/Simpan | Tab judul browser generik "PT. OMESH" — lihat Temuan #11 |
| Modal "Batalkan Order" | dari Aksi row `/order` | Modal | ID Order, Vendor (read-only), textarea Alasan, "Batalkan Order" | — |
| Riwayat Pembatalan | `/order/riwayat-pembatalan` | List/tabel terpisah | Filter jumlah data, "← Kembali" | 18 data, semua status Dibatalkan |
| Riwayat Perubahan | `/order/{id}/riwayat` | **Halaman terpisah** | Filter Tanggal Perubahan & Diubah Oleh | Bukan tab dalam Detail Order — lihat Temuan #9 |
| Panel Filter Daftar Order | dalam `/order` | Panel filter (selalu tampil) | ID Order, Jenis Order, Vendor, Kota Asal/Tujuan, Tanggal, Tipe Pengiriman, Drop Point, Pengirim, Penerima, Status | Dropdown "Status" bermasalah — lihat Temuan #7 |
| Popup "Data No. Perjalanan" | Aksi "Lihat No. Perjalanan" (status Ditugaskan) | Popup | Nomor perjalanan + Salin, info kontainer | Tidak ada link Public Tracking langsung dari sini/Detail Order (fitur ada tapi via URL publik terpisah `/tracking`, lihat `shared/selector-map-tracking.md`) |

Screenshot: 20 file baru di `artifacts/screenshots/explore/` (prefix `order-*`, mis. `order-buat-step1.png`, `order-buat-step2-modal-pilih-barang.png`, `order-modal-batalkan.png`).

## Detail Layar Modul Order — Varian FCL (fokus `oms013-order-fcl-auto-stuffing`, eksplorasi 2026-09-04)

Skeleton wizard/Daftar Order/modal/riwayat identik dengan section di atas (route sama, `/order`). Bagian ini hanya mencatat elemen yang **berbeda** untuk order tipe FCL (satuan Kontainer, bukan Armada).

- **Kartu "FCL" di Step 1 sekarang normal** — bug regresi 2026-09-02 (kartu FCL/LCL hilang dari DOM) **tidak reproduce 2 hari berturut-turut** (2026-09-02 sesi retry, 2026-09-04). `document.querySelectorAll` mengonfirmasi 4 kartu (FTL/FCL/LTL/LCL) lengkap. Lihat `shared/decisions.md`.
- **Step 1 field FCL-spesifik**: Pelabuhan Asal*, Pelabuhan Tujuan* (dropdown searchable, data Master Pelabuhan), Jenis Kontainer* (dropdown: 20ft/40ft/40ft HC/45ft HC/Reefer/Open Top/Flat Rack, dst.), Jumlah Kontainer* (textbox numerik) — menggantikan Jenis/Jumlah Armada di FTL.
- **Field baru yang tidak dibrief sebelumnya**: **Metode Pengiriman*** — 4 kartu (Door to Door, Door to CY, CY to CY, CY to Door), field unik container-shipping, tidak ada di FTL.
- **Tipe Pengiriman = Multipoint**: menambah section "Data Pengirim"/"Data Penerima" dengan multi-baris (tombol "Tambah Baris Input"). Saat Multipoint dipilih, opsi Metode Pengiriman selain "Door to Door" otomatis **disabled** (Multipoint memaksa Door to Door) — constraint valid, kandidat REQ yang belum eksplisit di dokumen analysis.
- **Step 2**: tombol "Hitung Ulang Kontainer" (versi FCL dari "Hitung Ulang Armada") — disabled sampai ada barang+jumlah terisi. Panel yang terbuka: Total Kubikasi/Berat, kapasitas maksimal per jenis kontainer (mis. 28.130 kg / 33,14 m³ untuk 20ft), visualisasi 3D interaktif, "Terapkan ke Order"/"Batal". Tombol terpisah "Visualisasi Muatan Saat Ini" (read-only) tampilkan pesan kosong bila belum ada barang.
- **Step 4 Review**: popup "Visualisasi Muatan" strukturnya **identik** dengan versi Step 2 read-only (komponen sama persis) — tidak ada behavior berbeda yang perlu dites terpisah dari versi FTL selain istilah "Kontainer"/satuan.
- **No. Perjalanan multi-kontainer**: order FCL yang dicek (`ORD8338721286`, 1 kontainer) hanya punya 1 No. Perjalanan (prefix `CNT...`, format mengindikasikan sistem siap multi-kontainer) — **belum terverifikasi dengan order Jumlah Kontainer >1**; ada 34 order FCL di data staging, cek lagi saat eksekusi skenario terkait No. Perjalanan ganda.

Screenshot: 11 file baru prefix `order-fcl-*` di `artifacts/screenshots/explore/` (mis. `order-fcl-step1-cards.png`, `order-fcl-step1-fields.png`, `order-fcl-tipe-pengiriman-multipoint.png`, `order-fcl-hitung-ulang-kontainer-panel.png`, `order-fcl-step4-visualisasi.png`, `order-fcl-detail-no-perjalanan.png`).

## Ringkasan Kesiapan Test

**Dokumen skenario**: 6 modul di `scenario/` sudah punya dokumen lengkap — `oms012-order-ftl-auto-stuffing`, `oms013-order-fcl-auto-stuffing`, `oms014-order-ftl-fcl-normal`, `oms015-order-ltl-lcl-universal` (semua ⊂ modul **Order**, baris #5), `oms017-penugasan-tracking` (baris #6), dan `oms022-public-tracking-improve` (halaman publik `/tracking`, di luar sidebar admin — tidak punya baris tersendiri di tabel modul). oms012 sudah dieksekusi penuh (287 skenario, terakhir run `20260904-130000`, lihat `results/`).

`shared/selector-map-order.md` (harvest 2026-08-22) tersedia untuk seluruh modul order — sumber selector utama executor route `/order`. Temuan kunci harvest: aplikasi **tidak punya data-testid sama sekali**, modal tidak memakai `role="dialog"`, panel filter selalu tampil (tombol Filter hanya toggle visual).

**20 modul lain** (di luar Order, Penugasan Tracking, Public Tracking) baru bisa smoke test (`/smoke`) sampai dokumen skenario diisi — termasuk modul baru **Distribusi & Muatan** (`/dashboard-distribusi`) yang belum pernah dieksplorasi isinya.

## Temuan Janggal

1. **[RESOLVED per 2026-09-04]** ~~Tombol "Buat Order" di `/order` tidak bereaksi~~ — **sekarang berfungsi normal**: diklik 1x dari `/order` langsung navigasi ke `/order/buat` dengan wizard Step 1 terbuka, tanpa workaround. Workaround navigasi langsung (`shared/decisions.md` entri 2026-08-22, dipakai di `tests/oms012-order-ftl-auto-stuffing.spec.js`) **tidak lagi diperlukan** tapi tetap harmless bila dipertahankan di spec — pertimbangkan update dokumentasi/komentar terkait.
2. **[INTERMITEN]** Tab **"Hak Akses"** di `/pengaturan-akun`: explore pagi 2026-08-22 terkonfirmasi 2x tidak mengganti konten (bukti: `artifacts/screenshots/explore/pengaturan-akun-hakakses.png`), tapi smoke run malam (`smoke__20260822-225445`) tab **berfungsi** (URL berubah `?tab=hak-akses`, konten berganti). Kandidat bug intermiten state switching — pantau di run berikutnya.
3. Console error **401** pada `https://apioms-staging.prahu-hub.com/api/auth/refresh` — **tidak muncul pada run ini** (0 error console sepanjang sesi). Kemungkinan intermiten atau sudah diperbaiki; pantau di run berikutnya.
4. **[BARU]** Tombol **lonceng notifikasi** (badge "5") di header tidak membuka panel/dropdown apa pun saat diklik — severity rendah. Bukti: `artifacts/screenshots/explore/notifikasi-bell.png`.
5. **Master Sopir** tidak memiliki tombol "Riwayat" seperti master data lain — kandidat inkonsistensi UI kecil.
6. Label `/master/customer` tidak konsisten: menu "Master Drop Point", tombol "Tambah Perusahaan" — kandidat inkonsistensi copywriting.
7. **[BUG-CANDIDATE — BARU 2026-09-04]** Dropdown filter **"Status"** (`Semua Status`) di `/order` tidak bisa diklik via mouse normal — Playwright click gagal timeout berulang (30+ detik) karena elemen lain (header sticky `z-99999`, `<th>` tabel) mencegat pointer event di posisi tombol, bahkan setelah reload fresh. Hanya berhasil via `dispatchEvent` JS langsung. Berpotensi masalah nyata bagi user mouse asli — perlu verifikasi ulang di sesi lain untuk memastikan bukan artefak sesi otomasi ini.
8. **[BARU 2026-09-04]** Batch Order (`/order/batch`) **tidak punya submenu tipe order** (Normal/Multipickup/Multidrop/Multipoint) seperti diasumsikan beberapa dokumen skenario — struktur aktual: pilih 1 dari 4 kartu Jenis Pengiriman (FTL/FCL/LTL/LCL) → langsung muncul area Download Template Excel + upload, tanpa breakdown tipe order lebih lanjut.
9. **[BARU 2026-09-04]** "Riwayat Perubahan" adalah **halaman terpisah** (`/order/{id}/riwayat`, diakses dari menu Aksi row Daftar Order) — bukan tab/section di dalam Detail Order seperti disebut di beberapa dokumen lama.
10. **[BARU 2026-09-04]** Popup "Visualisasi Muatan" versi **wizard Step 4** berfungsi normal (render 3D tanpa error) — mengonfirmasi bug 404 yang tercatat sebelumnya di modul oms012 spesifik pada versi **Detail Order**, bukan bug universal fitur ini.
11. Tab judul browser **Edit Order** generik "PT. OMESH" (bukan pola "Edit Order | PT. OMESH" seperti Detail Order) — inkonsistensi kecil.

## Screenshot

28 file (run 2026-08-22) + 20 file (run 2026-09-04 pagi, prefix `order-*`) + 11 file (run 2026-09-04 lanjutan, prefix `order-fcl-*`) di `artifacts/screenshots/explore/`, plus 2 bukti temuan: `pengaturan-akun-hakakses.png`, `notifikasi-bell.png`.
