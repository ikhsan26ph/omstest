# Module Map — OMS (PT. OMESH)

Hasil eksplorasi `/explore` pada 2026-08-22 (run ketiga; run pertama 2026-08-21). Tidak ada perubahan struktural vs run kedua — set 26 route persis sama.

## Info Login & Environment

- **Base URL**: https://oms-staging.prahu-hub.com
- **Login**: Sukses percobaan pertama, redirect otomatis ke `/monitoring` (akses root `/` juga redirect ke sana).
- **Selector login terbukti**: `getByRole('textbox', {name:'Masukkan Email'})`, `getByRole('textbox', {name:'Masukkan Password'})`, `getByRole('button', {name:'Login'})`. Link "Lupa Password?" → `/lupa-password`.
- **Tenant/Perusahaan**: PT. OMESH — **tidak ada dialog pemilihan tenant** (single-tenant).
- **Role terdeteksi**: Administrator (akun `finance.roro1@gmail.com`). Seluruh 26 menu dapat diakses, tidak ada indikasi pembatasan role. Perbandingan lintas-role belum bisa dilakukan (akun #3 di `config/env.md` belum diisi).
- **Struktur sidebar**: 4 grup collapsible — **Dashboard** (Monitoring, Progres Pengiriman, Tracking & Location, Operasional), **Master Wilayah** (Provinsi/Kota/Kecamatan/Kelurahan), **Master Operasional** (Drop Point/Waktu Perjalanan/Pelabuhan/Pelayaran/Barang/Kemasan/Unit/Sopir/CS), **Pusat Notifikasi** (Pengaturan Notifikasi, Preferensi Notifikasi); sisanya item level-1.
- **Widget "Kuota Order"** persisten di sidebar bawah: 1/200 (0,5%).

## Tabel Modul

| # | Modul | Route | Jenis Halaman | Aksi Utama | Ada Dokumen Skenario? | Catatan |
|---|---|---|---|---|---|---|
| 1 | Dashboard ▸ Monitoring | /monitoring | Dashboard (peta + statistik) | Perbesar/Perkecil, Layar Penuh, filter "Semua Customer"/"Semua Kasus", link Riwayat → /monitoring/riwayat, link Lacak → /tracking-location?orderCode=... | Tidak | Halaman default setelah login |
| 2 | Dashboard ▸ Progres Pengiriman | /progres-pengiriman | List dengan filter wajib | Filter (Nopol/Nama Sopir/ID Order), Reset, Terapkan | Tidak | Tabel kosong sampai filter diisi & Terapkan — by design (pesan eksplisit di UI) |
| 3 | Dashboard ▸ Tracking & Location | /tracking-location | Form pencarian + tab | Cari (disabled sampai ID Order & Nopol dipilih) | Tidak | Tab: Tracking Terkini (default), Riwayat Tracking |
| 4 | Dashboard ▸ Operasional | /dashboard-operasional | Dashboard analitik (chart) | Filter periode (Harian/Mingguan/Bulanan/Tahunan/Pilih Tanggal), dropdown Tipe Order, Export | Tidak | Breadcrumb "Dashboard", bukan "Beranda" seperti halaman lain (inkonsistensi kecil) |
| 5 | Order | /order | List/tabel (Daftar Order) | "Buat Order" ⚠️, "Batch Order", "Riwayat Pembatalan", Filter, kolom Aksi per baris | Tidak | 14 data. Tombol "Buat Order" TIDAK berfungsi run ini — lihat Temuan Janggal #1 |
| 6 | Penugasan Tracking | /penugasan-tracking | List/tabel | "Tambah Penugasan", Filter | Tidak | 1 data |
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

## Ringkasan Kesiapan Test

**Dokumen skenario**: folder `scenario/` saat ini hanya berisi README — **belum ada dokumen skenario untuk modul mana pun** (kolom "Ada Dokumen Skenario?" = Tidak untuk seluruh 26 modul). Sebelumnya modul Order pernah punya dokumen `oms012`/`oms013`/`oms014` yang akan diisi ulang oleh user.

`shared/selector-map-order.md` (harvest 2026-08-22) tersedia untuk seluruh modul order — sumber selector utama executor route `/order`. Temuan kunci harvest: aplikasi **tidak punya data-testid sama sekali**, modal tidak memakai `role="dialog"`, panel filter selalu tampil (tombol Filter hanya toggle visual).

**Semua 26 modul saat ini baru bisa smoke test** (`/smoke`) sampai dokumen skenario diisi.

## Temuan Janggal

1. **[BUG-CANDIDATE PRIORITAS TINGGI — kini reproducible]** Tombol **"Buat Order"** di `/order` **tidak bereaksi sama sekali**: diklik 2x pada run ini — tidak ada navigasi ke `/order/buat`, tidak ada modal, tidak ada console error. Run sebelumnya intermiten (kadang berfungsi); run ini gagal konsisten. **Workaround resmi (keputusan user 2026-08-22, lihat `shared/decisions.md`)**: skenario yang butuh form buat order masuk via navigasi langsung `https://oms-staging.prahu-hub.com/order/buat` — jangan bergantung klik tombol. Skenario yang menguji tombolnya sendiri tetap klik & catat bug-candidate.
2. **[INTERMITEN]** Tab **"Hak Akses"** di `/pengaturan-akun`: explore pagi 2026-08-22 terkonfirmasi 2x tidak mengganti konten (bukti: `artifacts/screenshots/explore/pengaturan-akun-hakakses.png`), tapi smoke run malam (`smoke__20260822-225445`) tab **berfungsi** (URL berubah `?tab=hak-akses`, konten berganti). Kandidat bug intermiten state switching — pantau di run berikutnya.
3. Console error **401** pada `https://apioms-staging.prahu-hub.com/api/auth/refresh` — **tidak muncul pada run ini** (0 error console sepanjang sesi). Kemungkinan intermiten atau sudah diperbaiki; pantau di run berikutnya.
4. **[BARU]** Tombol **lonceng notifikasi** (badge "5") di header tidak membuka panel/dropdown apa pun saat diklik — severity rendah. Bukti: `artifacts/screenshots/explore/notifikasi-bell.png`.
5. **Master Sopir** tidak memiliki tombol "Riwayat" seperti master data lain — kandidat inkonsistensi UI kecil.
6. Label `/master/customer` tidak konsisten: menu "Master Drop Point", tombol "Tambah Perusahaan" — kandidat inkonsistensi copywriting.

## Screenshot

28 file di `artifacts/screenshots/explore/` (1 per modul, nama = slug route, mis. `order.png`, `master-kota.png`), plus 2 bukti temuan: `pengaturan-akun-hakakses.png`, `notifikasi-bell.png`.
