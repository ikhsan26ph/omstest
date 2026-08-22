# Module Map — OMS (PT. OMESH)

Hasil eksplorasi `/explore` pada 2026-08-22 (run kedua; run pertama 2026-08-21 — tidak ada perubahan struktural).

## Info Login & Environment

- **Base URL**: https://oms-staging.prahu-hub.com
- **Login**: Sukses percobaan pertama, redirect otomatis ke `/monitoring`.
- **Tenant/Perusahaan**: PT. OMESH
- **Role terdeteksi**: Admin / Administrator (akun `finance.roro1@gmail.com`)
- **Tidak ada dialog pemilihan tenant** — akun ini hanya terhubung ke satu tenant.
- Tidak ada indikasi pembatasan role untuk akun Admin — seluruh 26 menu dapat diakses (perbandingan lintas-role belum bisa dilakukan; akun #2/#3 di `config/env.md` belum diisi).

## Tabel Modul

| # | Modul | Route | Jenis Halaman | Aksi Utama | Ada Knowledge Doc? | Catatan |
|---|---|---|---|---|---|---|
| 1 | Monitoring | /monitoring | Dashboard (peta + kartu statistik) | Tab "Data Kasus"/"Armada Terdekat", filter "Semua Customer", Refresh, link "Riwayat" (/monitoring/riwayat) | Tidak | Data staging kosong — "Tidak ada kasus saat ini" (bukan bug) |
| 2 | Progres Pengiriman | /progres-pengiriman | List dengan filter wajib | Filter (Nopol/Nama Sopir/ID Order), Reset, Terapkan | Tidak | Data dimuat hanya setelah filter diisi & "Terapkan" — by design |
| 3 | Tracking & Location | /tracking-location | Dashboard/detail dengan tab | Tab "Tracking Terkini"/"Riwayat Tracking", pilih ID Order, Cari | Tidak | Field "Nopol/No. Kontainer" disabled sampai ID Order dipilih |
| 4 | Operasional (Dashboard Analitik) | /dashboard-operasional | Dashboard analitik (chart) | Filter periode (Harian/Mingguan/Bulanan/Tahunan/Pilih Tanggal), Export | Tidak | 3 section: Volume & Aktivitas, Produktivitas Vendor, Performa Pengiriman |
| 5 | Order | /order | List/tabel (Daftar Order) | "Buat Order", "Batch Order", "Riwayat Pembatalan", Filter | **Ya** — `oms012-order-ftl-auto-stuffing`, `oms013-order-fcl-auto-stuffing`, `oms014-order-ftl-fcl-normal` | 5 data order tampil. **Tombol "Buat Order" INTERMITEN** — gagal di 2 run explore, tapi berfungsi di run harvest 2026-08-22 (lihat Temuan Janggal #1) |
| 6 | Penugasan Tracking | /penugasan-tracking | List/tabel | "Tambah Penugasan", Filter | Tidak | Data kosong ("Tidak ada data") |
| 7 | Simulasi Muatan | /simulasi-muatan | Wizard/tool kalkulasi | Pilih unit (Armada/Kontainer), "Pilih Barang", "Cek Visualisasi", "Lanjutkan Order" (disabled) | Tidak | Tool kalkulasi muatan, bukan CRUD biasa |
| 8 | Master Provinsi | /master/provinsi | List/tabel CRUD | "Tambah Provinsi", Filter, Riwayat | Tidak | Sub-menu Master Wilayah. 38 data, 2 halaman paginasi |
| 9 | Master Kota | /master/kota | List/tabel CRUD | "Tambah Kota" (link ke /master/kota/tambah), Filter, Riwayat | Tidak | Sub-menu Master Wilayah |
| 10 | Master Kecamatan | /master/kecamatan | List/tabel CRUD | "Tambah Kecamatan" (link), Filter, Riwayat | Tidak | Sub-menu Master Wilayah |
| 11 | Master Kelurahan | /master/kelurahan | List/tabel CRUD | "Tambah Kelurahan" (link), Filter, Riwayat | Tidak | Sub-menu Master Wilayah |
| 12 | Master Drop Point (Perusahaan) | /master/customer | List/tabel CRUD | "Tambah Perusahaan" (link ke /master/customer/tambah), Filter, Riwayat | Tidak | Sub-menu Master Operasional. Drop point dikelola via detail perusahaan. 10 data |
| 13 | Master Waktu Perjalanan | /master/waktu-perjalanan | List/tabel CRUD | "Tambah Waktu Perjalanan" (link), "Perbarui Waktu Perjalanan", Riwayat, Filter | Tidak | Sub-menu Master Operasional |
| 14 | Master Pelabuhan | /master/pelabuhan | List/tabel CRUD | "Tambah Pelabuhan" (link), Filter, Riwayat | Tidak | Sub-menu Master Operasional |
| 15 | Master Pelayaran | /master/pelayaran | List/tabel CRUD | "Tambah Pelayaran" (link), Filter, Riwayat | Tidak | Sub-menu Master Operasional |
| 16 | Master Barang | /master/barang | List/tabel CRUD | "Tambah Barang" (link), Filter, Riwayat | Tidak | Sub-menu Master Operasional |
| 17 | Master Kemasan | /master/kemasan | List/tabel CRUD | "Tambah Kemasan" (link), Filter, Riwayat | Tidak | Sub-menu Master Operasional |
| 18 | Master Unit | /master/unit | List/tabel, 3 tab | Tab "Armada"/"Jenis Armada"/"Jenis Kontainer", "Tambah Armada", Filter | Tidak | Sub-menu Master Operasional. Armada dikelola per-vendor ("Kelola Armada") |
| 19 | Master Sopir | /master/sopir | List/tabel CRUD | "Tambah Sopir" (tombol, kemungkinan modal), Filter | Tidak | Sub-menu Master Operasional. Tidak punya tombol "Riwayat" (inkonsisten dgn master lain) |
| 20 | Master CS | /master/cs | List/tabel CRUD | "Tambah Customer Service" (link ke /master/cs/tambah), Filter, Riwayat | Tidak | Sub-menu Master Operasional. Title tab browser: "Master Customer Service" |
| 21 | Manajemen Vendor | /manajemen-vendor | List/tabel CRUD | "Tambah Vendor" (link ke /manajemen-vendor/tambah), Filter | Tidak | 10 vendor, status "Menunggu"/"Aktif"/"Tidak Aktif" |
| 22 | Pengaturan Akun | /pengaturan-akun | List/tabel, 2 tab | Tab "Sub User"/"Hak Akses", "Tambah Sub User", Riwayat, Filter | Tidak | **Tab "Hak Akses" tidak mengganti konten saat diklik** — temuan baru (lihat Temuan Janggal #2) |
| 23 | Akun Saya | /akun-saya | Detail/profile | "Edit Informasi", "Ubah Password", Riwayat | Tidak | Menampilkan Nama, Email, No WA, Bagian Staff |
| 24 | Pengaturan Sistem | /setting/sistem | Form setting (8 accordion) | Batal, Simpan | Tidak | SLA, radius notifikasi, deteksi keluar jalur, kelayakan armada, dll |
| 25 | Pengaturan Notifikasi | /setting/general | Form setting (list toggle) | Switch global, Batal, Simpan | Tidak | Sub-menu Pusat Notifikasi. 10/10 notifikasi aktif global |
| 26 | Preferensi Notifikasi | /setting/preferensi-notifikasi | Form setting per kategori | Toggle per kategori (Order 3/3, Tracking 7/7, Monitoring & Tracking 5/5, KIR Armada 2/2) | Tidak | Sub-menu Pusat Notifikasi, preferensi personal |

## Ringkasan Kesiapan Test

**Siap dites detail (punya scenarios.json)** — semuanya modul Order (`/order`):
- `oms012-order-ftl-auto-stuffing` — lengkap (analysis, ui-inventory, feature, scenarios.json, coverage)
- `oms013-order-fcl-auto-stuffing` — ada scenarios.json, **belum ada ui-inventory.md**
- `oms014-order-ftl-fcl-normal` — ada scenarios.json, **belum ada ui-inventory.md**

`selector-map.md` untuk `oms012-order-ftl-auto-stuffing` sudah tersedia (harvest 2026-08-22) — jadi sumber selector utama executor. Temuan kunci harvest: aplikasi **tidak punya data-testid sama sekali**, modal tidak memakai `role="dialog"`, panel filter selalu tampil (tombol Filter hanya toggle visual). Modul oms013/oms014 belum di-harvest.

**Baru bisa smoke test (belum ada dokumen skenario)**: 25 modul lainnya — Monitoring, Progres Pengiriman, Tracking & Location, Operasional, Penugasan Tracking, Simulasi Muatan, Master Wilayah (Provinsi/Kota/Kecamatan/Kelurahan), Master Operasional (Drop Point, Waktu Perjalanan, Pelabuhan, Pelayaran, Barang, Kemasan, Unit, Sopir, CS), Manajemen Vendor, Pengaturan Akun, Akun Saya, Pengaturan Sistem, Pengaturan Notifikasi, Preferensi Notifikasi.

## Temuan Janggal

1. **[INTERMITEN — kandidat bug prioritas tinggi]** Tombol **"Buat Order"** di `/order`: pada 2 run explore (2026-08-21 & pagi 2026-08-22) tidak memicu efek apa pun (URL tetap, snapshot identik, tanpa console error). Namun pada run harvest-selectors 2026-08-22 tombol **berfungsi normal** (navigasi ke `/order/buat`, wizard Step 1 terbuka). Kesimpulan: bug intermiten/flaky, bukan rusak permanen — saat `/test-module`, jika klik pertama gagal coba reload halaman + retry 1x, dan catat kegagalannya sebagai bug-candidate.
2. **[BARU 2026-08-22]** Tab **"Hak Akses"** di `/pengaturan-akun` tidak mengganti konten saat diklik — konten tetap tabel Sub User. Kemungkinan belum diimplementasi atau bug state switching.
3. Console error **401** pada `https://apioms-staging.prahu-hub.com/api/auth/refresh` di awal sesi — konsisten di 2 run, severity rendah, tidak mengganggu fungsi.
4. **Master Sopir** tidak memiliki tombol "Riwayat" seperti master data lain — kandidat inkonsistensi UI kecil.
5. Modul dashboard (Monitoring, Penugasan Tracking) menampilkan data kosong/nol — wajar untuk staging, bukan bug.

## Screenshot

Tersimpan di `artifacts/screenshots/explore/` (diperbarui 2026-08-22):
dashboard-monitoring.png, dashboard-operasional.png, order.png, penugasan-tracking.png, simulasi-muatan.png, master-wilayah.png, master-operasional.png, manajemen-vendor.png, pengaturan-akun.png, akun-saya.png, pengaturan-sistem.png, pusat-notifikasi.png
