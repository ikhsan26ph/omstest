# Selector Map — oms012-order-ftl-auto-stuffing

- **Tanggal harvest**: 2026-08-22
- **Base URL**: https://oms-staging.prahu-hub.com
- **Akun**: finance.roro1@gmail.com — header menampilkan nama **"Admin"**, role bar **"Administrator"**, tenant **"PT. OMESH"** (bukan "Mentari Sumber Kertas" / "Shipper · Staff Operasional" seperti di desain — tenant & role label berbeda dari asumsi ui-inventory).
- **Sesi**: sudah login saat mulai (tidak perlu login ulang).
- **Data order tersedia di staging**: hanya **5 order**, semua Jenis Pengiriman **FTL**, semua Tipe Pengiriman **Normal** (sampling 2/5 order via Detail: ORD7285852191, ORD7285719128 — tidak ditemukan Multipickup/Multidrop/Multipoint). Status yang ada: `Isi Data Muatan`, `Isi Data Pengiriman`, `Menunggu Penugasan` (×2), `Review Order`. **Tidak ada order berstatus `Ditugaskan`**.
- **Blocker/catatan penting run ini**:
  - Tombol **"Buat Order" BERFUNGSI** pada run ini (navigasi ke `/order/buat`, wizard Step 1 terbuka) — **berbeda dari 2 run harvest sebelumnya** yang melaporkan tombol ini tidak berfungsi. Namun sesuai aturan read-only, wizard **tidak dilanjutkan** melewati Step 1 (tidak isi form, tidak klik Selanjutnya) — sehingga SCR-06 s.d. SCR-19 dan varian multi (kecuali yang terjangkau lewat Edit Order) tetap **SKIPPED**, bukan karena tombol rusak, tapi karena batasan cakupan harvest read-only.
  - Aksi **"Hitung Ulang Armada"** pada layar Edit Order **diblokir oleh permission classifier lingkungan agent** (bukan error aplikasi) — SCR-12/13/14 gagal dipetakan lewat jalur ini.
  - Ditemukan **bug nyata**: tombol "Visualisasi Muatan" di Detail Order memicu request `GET /api/order/stuffing/visualisasi` yang **404**, panel menampilkan "Gagal memuat visualisasi muatan." (lihat SCR-21).
  - **Tidak ada satupun `data-testid` ditemukan** di seluruh layar yang di-harvest. Hanya **satu** `id` HTML stabil ditemukan: `#cancelReason` (textarea Alasan Pembatalan di popup Batalkan Order).
  - Popup/modal (Batalkan Order, Visualisasi Muatan, Pilih Barang) **tidak menggunakan `role="dialog"`** — `document.querySelectorAll('[role="dialog"]')` selalu kosong walau modal terbuka. Selector berbasis role dialog di ui-inventory **tidak akan match** di implementasi live.

## Tabel Selector

| SCR | Elemen | Selector terbaik | Sumber | Catatan |
|---|---|---|---|---|
| SCR-00 | Logo/Home | `getByRole('link', { name: 'PT. OMESH' })` | role+name | link ke `/` |
| SCR-00 | Tutup menu (sidebar, ikon) | `getByRole('button', { name: 'Tutup menu' })` | role+name (aria-label) | |
| SCR-00 | Menu sidebar: Dashboard (expandable) | `getByRole('button', { name: 'Dashboard' })` | role+name | expand submenu |
| SCR-00 | Submenu: Monitoring / Progres Pengiriman / Tracking & Location / Operasional | `getByRole('link', { name: 'Monitoring' })` dst | role+name | link, bukan di ui-inventory (di luar modul Order) |
| SCR-00 | Menu sidebar: Order | `getByRole('link', { name: 'Order' })` | role+name | aktif di halaman ini |
| SCR-00 | Menu sidebar: Penugasan Tracking / Simulasi Muatan / Manajemen Vendor / Pengaturan Akun / Akun Saya / Pengaturan Sistem | `getByRole('link', { name: 'Penugasan Tracking' })` dst | role+name | |
| SCR-00 | Menu sidebar: Master Wilayah (expandable) | `getByRole('button', { name: 'Master Wilayah' })` | role+name | submenu: Master Provinsi/Kota/Kecamatan/Kelurahan |
| SCR-00 | Menu sidebar: Master Operasional (expandable) | `getByRole('button', { name: 'Master Operasional' })` | role+name | submenu: Drop Point, Waktu Perjalanan, Pelabuhan, Pelayaran, Barang, Kemasan, Unit, Sopir, CS |
| SCR-00 | Menu sidebar: Pusat Notifikasi (expandable) | `getByRole('button', { name: 'Pusat Notifikasi' })` | role+name | submenu: Pengaturan Notifikasi, Preferensi Notifikasi |
| SCR-00 | Kuota Order (progress) | `getByRole('heading', { name: 'Kuota Order' })` lalu ambil teks sibling `0/200` / `0%` | TIDAK STABIL | tanpa testid, nilai contoh live: `0/200`, `0%` (bukan `120/300` seperti desain) |
| SCR-00 | Versi aplikasi | `getByText(/Versi \d+\.\d+\.\d+/)` | TIDAK STABIL | teks live: `PT. OMESH - Versi 1.0.0` (beda format dari desain `Order Management System Versi 1.0.0`) |
| SCR-00 | Toggle mode gelap | `getByRole('button', { name: 'Aktifkan mode gelap' })` | role+name | **elemen baru, tidak ada di ui-inventory** — JANGAN diklik saat harvest (toggle setting) |
| SCR-00 | Toggle Sidebar (header/banner) | `getByRole('button', { name: 'Toggle Sidebar' })` | role+name (aria-label) | beda dari `sidebar-toggle` testid yang diusulkan desain |
| SCR-00 | Profil (nama+role, kiri header) | `getByText('Administrator')` | TIDAK STABIL | teks statis "Admin" / "Administrator", selalu tampil (bukan dropdown) |
| SCR-00 | Profil (nama+email, kanan header) | `getByText('finance.roro1@gmail.com')` | TIDAK STABIL | selalu tampil, tidak perlu klik untuk buka |
| SCR-00 | Logout | `getByRole('button', { name: 'Logout' })` | role+name | |
| SCR-00 | Notifikasi (bell, header kanan) | posisi: tombol tanpa nama sebelum blok profil | TIDAK STABIL | **tidak ada aria-label/teks sama sekali** — tidak bisa disasar via role+name |
| SCR-00 | Breadcrumb "Beranda" | `getByRole('link', { name: 'Beranda' })` | role+name | |
| SCR-01 | Judul "Daftar Order" | `getByRole('heading', { name: 'Daftar Order', level: 2 })` | role+name | |
| SCR-01 | Buat Order | `getByRole('button', { name: 'Buat Order' })` | role+name | navigasi ke `/order/buat` — **berfungsi run ini** |
| SCR-01 | Batch Order | `getByRole('button', { name: 'Batch Order' })` | role+name | belum diverifikasi isinya (di luar cakupan wajib) |
| SCR-01 | Riwayat Pembatalan | `getByRole('button', { name: 'Riwayat Pembatalan' })` | role+name | belum diverifikasi isinya |
| SCR-01 | Filter (toggle) | `getByRole('button', { name: 'Filter' })` | role+name | **lihat catatan SCR-02** — tidak benar-benar toggle panel |
| SCR-01 | Dropdown "Tampilkan N data" | native `<select>` di header tabel | TIDAK STABIL | tanpa aria-label sendiri, opsi `10/20/50/100` |
| SCR-01 | Tabel order | `getByRole('table')` | role | |
| SCR-01 | Salin ID Order (per baris) | `getByRole('button', { name: /^Salin ORD/ })` | role+name (dinamis) | icon copy + teks ID Order |
| SCR-01 | Badge jenis (FTL) | `getByText('FTL')` scoped ke row | TIDAK STABIL | berulang per baris |
| SCR-01 | Badge status | `getByText('Menunggu Penugasan')` dst, scoped ke row | TIDAK STABIL | nilai live: `Isi Data Muatan`, `Isi Data Pengiriman`, `Menunggu Penugasan`, `Review Order` |
| SCR-01 | Aksi (kebab per baris) | `getByRole('button', { name: 'Aksi' }).nth(i)` | role+name (tidak unik) | harus pakai index/row-scope |
| SCR-01 | Info paginasi | `getByText(/Menampilkan \d+–\d+ data dari \d+ data/)` | TIDAK STABIL | pakai en-dash **"–"**, bukan hyphen "-" seperti asumsi ui-inventory |
| SCR-02 | ID Order (filter) | `getByPlaceholder('Masukkan ID Order')` | placeholder | field selalu terlihat (lihat catatan) |
| SCR-02 | Jenis Order (dropdown) | `getByRole('button', { name: 'Semua Jenis' })` | role+name | |
| SCR-02 | Vendor (filter) | `getByPlaceholder('Masukkan Vendor')` | placeholder | |
| SCR-02 | Kota Asal (dropdown) | scoped: elemen setelah label teks "Kota Asal" | TIDAK STABIL | default text `Semua Kota` **sama** dengan Kota Tujuan → tidak unik by role+name |
| SCR-02 | Kota Tujuan (dropdown) | scoped: elemen setelah label teks "Kota Tujuan" | TIDAK STABIL | idem, default text `Semua Kota` |
| SCR-02 | Tanggal Buat (dropdown) | `getByRole('button', { name: 'Pilih Tanggal' })` | role+name | **field baru, tidak ada di ui-inventory** |
| SCR-02 | Tipe Pengiriman (dropdown) | `getByRole('button', { name: 'Semua Tipe' })` | role+name | **enabled penuh** — beda dari asumsi ASM-D03 (desain: tampak disabled) |
| SCR-02 | Drop Point Asal (dropdown) | scoped: elemen setelah label teks "Drop Point Asal" | TIDAK STABIL | default text `Semua Drop Point` sama dengan Drop Point Tujuan |
| SCR-02 | Drop Point Tujuan (dropdown) | scoped: elemen setelah label teks "Drop Point Tujuan" | TIDAK STABIL | idem |
| SCR-02 | Pengirim (filter teks) | `getByPlaceholder('Masukkan Nama Pengirim')` | placeholder | **field baru**, bukan dropdown seperti di desain lain |
| SCR-02 | Penerima (filter teks) | `getByPlaceholder('Masukkan Nama Penerima')` | placeholder | **field baru** |
| SCR-02 | Status (dropdown) | `getByRole('button', { name: 'Semua Status' })` | role+name | |
| SCR-02 | Reset | `getByRole('button', { name: 'Reset' })` | role+name | |
| SCR-02 | Terapkan | `getByRole('button', { name: 'Terapkan' })` | role+name | |
| SCR-03 | Menu item: Detail | `getByRole('button', { name: 'Detail' })` scoped ke container menu terapung | TIDAK STABIL (teks generik, container tanpa role menu) | muncul di semua status |
| SCR-03 | Menu item: Lanjutkan Pengisian | `getByRole('button', { name: 'Lanjutkan Pengisian' })` | role+name | muncul di status draft-like (Isi Data Muatan/Pengiriman, Review Order) |
| SCR-03 | Menu item: Edit | `getByRole('button', { name: 'Edit', exact: true })` | role+name | muncul di status Menunggu Penugasan |
| SCR-03 | Menu item: Batalkan Order | `getByRole('button', { name: 'Batalkan Order' })` scoped ke menu | role+name (tidak unik global) | muncul di semua status yang dicek |
| SCR-03 | Menu item: Order Kembali | `getByRole('button', { name: 'Order Kembali' })` | role+name | **muncul di status `Menunggu Penugasan`** — berbeda dari asumsi FND-01 desain (desain: muncul di `Ditugaskan`); tidak ada order Ditugaskan untuk verifikasi silang |
| SCR-03 | Menu item: Riwayat Perubahan | `getByRole('button', { name: 'Riwayat Perubahan' })` | role+name | muncul di semua status yang dicek |
| SCR-04/05 | Kartu jenis pengiriman FTL/FCL/LTL/LCL | `getByRole('button', { name: /FTL/ })` dst | role+name | **elemen `<button>` biasa, bukan `role="radio"`** seperti asumsi desain |
| SCR-04/05 | Jenis Armada (dropdown) | `getByRole('button', { name: 'Pilih Jenis Armada' })` | role+name | |
| SCR-04/05 | Jumlah Armada (input) | `getByPlaceholder('Masukkan Jumlah Armada')` | placeholder | |
| SCR-04/05 | Tipe Pengiriman (dropdown) | `getByRole('button', { name: 'Pilih Tipe Pengiriman' })` | role+name | |
| SCR-04/05 | Selanjutnya | `getByRole('button', { name: 'Selanjutnya' })` | role+name | **atribut `disabled` TIDAK ditemukan di DOM** walau Tipe Pengiriman kosong — beda dari asumsi desain (state disabled visual); perlu verifikasi test terpisah apakah klik tervalidasi di server/toast |
| SCR-04/05 | Simpan ke Draf | `getByRole('button', { name: 'Simpan ke Draf' })` | role+name | |
| SCR-04/05 | Batal | `getByRole('button', { name: 'Batal' })` | role+name | memicu dialog konfirmasi |
| SCR-04/05 | Dialog konfirmasi Batal — judul | `getByText('Apakah Anda yakin ingin membatalkan ?')` | TIDAK STABIL (tanpa role dialog) | muncul juga di Edit Order |
| SCR-04/05 | Dialog konfirmasi Batal — Tidak | `getByRole('button', { name: 'Tidak' })` | role+name | tetap di halaman |
| SCR-04/05 | Dialog konfirmasi Batal — Ya | `getByRole('button', { name: 'Ya', exact: true })` | role+name | keluar tanpa simpan |
| SCR-11 | Dialog "Pilih Barang" — judul | `getByRole('heading', { name: 'Pilih Barang', level: 4 })` | role+name | dipetakan via tombol "Pilih Barang" di Edit Order |
| SCR-11 | Tutup (×) | `getByRole('button', { name: 'Tutup' })` scoped ke modal | role+name (aria-label) | **KOREKSI FND-03**: live PUNYA tombol close, beda dari asumsi desain |
| SCR-11 | Pencarian | `getByPlaceholder('Cari Kode SKU atau Nama Barang')` | placeholder | beda teks dari desain `Cari kode/nama barang` |
| SCR-11 | Checkbox barang (sudah ditambahkan) | checkbox `[checked][disabled]` per baris | TIDAK STABIL | disabled+checked untuk barang yg sudah ada di order (beda dari asumsi desain: checkbox tetap aktif) |
| SCR-11 | Badge "Sudah ditambahkan" | `getByText('Sudah ditambahkan')` | TIDAK STABIL | huruf kecil "ditambahkan" (bukan "Ditambahkan" seperti desain) |
| SCR-11 | Paginasi Sebelumnya/Selanjutnya | `getByRole('button', { name: 'Sebelumnya' })` / `getByRole('button', { name: 'Selanjutnya' })` | role+name | **baru, tidak ada di ui-inventory**; indikator `1 / 1` di antaranya |
| SCR-11 | Tambahkan | `getByRole('button', { name: 'Tambahkan' })` | role+name | **bukan "Simpan"** seperti di desain; disabled bila tidak ada perubahan; tidak ada tombol "Batal" terpisah di modal ini |
| SCR-20 | Judul "Detail Order" | `getByRole('button', { name: 'Detail Order' })` | role+name | **elemen `<button>`**, bukan sekadar heading statis |
| SCR-20 | Visualisasi Muatan | `getByRole('button', { name: 'Visualisasi Muatan' })` | role+name | lihat bug 404 di catatan header |
| SCR-20 | Batalkan Order | `getByRole('button', { name: 'Batalkan Order' })` | role+name | |
| SCR-20 | Edit Order | `getByRole('button', { name: 'Edit Order' })` | role+name | navigasi ke `/order/{id}/edit` |
| SCR-20 | Salin ID Order | `getByRole('button', { name: /^Salin ORD/ })` | role+name | |
| SCR-20 | Accordion: Data Pengirim / Data Penerima / Data Barang / Vendor dan Harga | `getByRole('button', { name: 'Data Pengirim' })` dst | role+name | heading dibungkus `<button>` (collapsible) |
| SCR-20 | Accordion: No. Perjalanan | `getByRole('button', { name: 'No. Perjalanan' })` | role+name | **section tambahan, tidak ada di indeks ui-inventory** — muncul langsung di Detail Order (bukan hanya via pop up SCR-24) |
| SCR-20 | Empty-state No. Perjalanan | `getByText('Belum ada nomor perjalanan untuk order ini.')` | TIDAK STABIL | tampil saat order belum berstatus Ditugaskan |
| SCR-21 | Panel judul | `getByRole('heading', { name: 'Visualisasi Muatan Saat Ini' })` | role+name | bukan "Visualisasi Muatan" polos seperti SCR-21 desain (nama ini malah tertukar dgn SCR-14) |
| SCR-21 | Subjudul | `getByText('Simulasi kebutuhan unit dari muatan order ini saat ini. Tampilan ini tidak mengubah data order.')` | TIDAK STABIL | **berbeda** dari subjudul drawer lain — resolves FND-04 di konteks ini (tidak identik lagi), tapi drawer Hitung Ulang Armada tidak sempat diverifikasi ulang |
| SCR-21 | Pesan error | `getByText('Gagal memuat visualisasi muatan.')` | TIDAK STABIL | **BUG**: muncul karena `GET /api/order/stuffing/visualisasi` 404 |
| SCR-21 | Tutup | `getByRole('button', { name: 'Tutup' })` (ada 2: header × dan tombol footer) | role+name (tidak unik, perlu `.first()`/`.last()`) | |
| SCR-22 | Dialog judul "Batalkan Order" | `getByRole('heading', { name: 'Batalkan Order', level: 2 })` | role+name | |
| SCR-22 | Tombol close (×) | tombol tanpa nama di pojok kanan atas dialog | TIDAK STABIL | tanpa aria-label |
| SCR-22 | ID Order / Vendor (read-only) | `getByText('ID Order')` / `getByText('Vendor')` scoped ke dialog | TIDAK STABIL | |
| SCR-22 | Alasan Pembatalan (textarea) | `#cancelReason` | **id (stabil)** | satu-satunya id stabil yang ditemukan di seluruh harvest ini |
| SCR-22 | Submit "Batalkan Order" | `getByRole('button', { name: 'Batalkan Order' })` scoped ke dialog | role+name (tidak unik global) | **JANGAN diklik** saat harvest/testing tanpa skenario eksplisit |
| SCR-23 | Header aksi: Hitung Ulang Armada | `getByRole('button', { name: 'Hitung Ulang Armada' })` | role+name | **KOREKSI FND-09**: live PUNYA tombol ini di Edit Order, beda dari asumsi desain; klik-nya diblokir permission classifier saat harvest ini, belum berhasil dipetakan drawernya (SCR-12/13) |
| SCR-23 | Header aksi: Visualisasi Terbaru | `getByRole('button', { name: 'Visualisasi Terbaru' })` | role+name | idem, belum sempat dipetakan (SCR-14) karena fokus waktu setelah insiden blokir di atas |
| SCR-23 | Jenis Armada (dropdown, editable) | `getByRole('button', { name: 'Pilih Jenis Armada' })` | role+name | |
| SCR-23 | Jumlah Armada (input, editable) | `getByPlaceholder('Masukkan Jumlah Armada')` | placeholder | |
| SCR-23 | Drop Point Asal / Pengirim (dropdown) | `getByRole('button', { name: 'semarang baran' })` (nilai terisi) | TIDAK STABIL (nama = nilai data, dinamis) | |
| SCR-23 | PIC Pengirim / PIC Penerima (input) | `getByPlaceholder('Masukkan PIC Pengirim')` / `getByPlaceholder('Masukkan PIC Penerima')` | placeholder | |
| SCR-23 | No. WhatsApp PIC (input, ×2 — pengirim & penerima) | `getByPlaceholder('Masukkan No. WhatsApp PIC')` | placeholder (tidak unik, ada 2) | perlu `.first()`/`.last()` atau scope per section |
| SCR-23 | Provinsi/Kota/Kecamatan/Desa/Kode Pos/Alamat (read-only) | `getByPlaceholder('Provinsi Asal')` dst, semua `disabled` | placeholder | konsisten dengan desain (read-only) |
| SCR-23 | Catatan (textarea, ×2) | `getByPlaceholder('Masukkan Catatan')` | placeholder (tidak unik) | |
| SCR-23 | Accordion "Data Barang - Armada 1" | `getByRole('heading', { name: 'Data Barang - Armada 1' })` | role+name | sesuai Normal type; heading "Kontainer" (FND-10) tidak dapat diverifikasi (tidak ada order Multipickup) |
| SCR-23 | Tambahkan Asuransi (checkbox) | `getByRole('checkbox', { name: 'Tambahkan Asuransi' })` | role+name | |
| SCR-23 | Nomor DO (chip input) | textbox tanpa placeholder di sebelah chip `1` | TIDAK STABIL | |
| SCR-23 | Hapus chip DO | `getByRole('button', { name: 'Hapus 1' })` | role+name (nilai dinamis) | |
| SCR-23 | Jumlah (per baris barang) | `getByRole('textbox', { name: /^Jumlah / })` | role+name (aria-label dinamis per SKU) | |
| SCR-23 | Hapus baris barang | `getByRole('button', { name: /^Hapus / })` | role+name (dinamis per SKU) | |
| SCR-23 | Pilih Barang | `getByRole('button', { name: 'Pilih Barang' })` | role+name | membuka modal SCR-11 (lihat di atas) |
| SCR-23 | Vendor (dropdown) | `getByRole('button', { name: 'fdsa' })` (nilai terisi) | TIDAK STABIL (nama = data) | |
| SCR-23 | Tanggal Permintaan Muat | `getByRole('button', { name: /^\d{2}\/\d{2}\/\d{4}/ })` | TIDAK STABIL (nilai data) | |
| SCR-23 | Harga (input currency) | textbox dengan placeholder `0` | TIDAK STABIL | tanpa label eksplisit, accessible name = placeholder `"0"` yang ambigu |
| SCR-23 | Gunakan komponen harga (checkbox) | `getByRole('checkbox', { name: 'Gunakan komponen harga' })` | role+name | |
| SCR-23 | Footer Batal / Simpan | `getByRole('button', { name: 'Batal' })` / `getByRole('button', { name: 'Simpan', exact: true })` | role+name | Batal memicu dialog konfirmasi sama seperti Step 1 |

## Layar SKIPPED

| SCR | Alasan |
|---|---|
| SCR-06/07/08 | Step 1 varian Multipickup/Multidrop/Multipoint — hanya tercapai dengan mengganti Tipe Pengiriman & mengisi form; di luar cakupan read-only (state awal wizard hanya expose tipe Normal secara default). |
| SCR-09/10 | Step 2 Data Barang (wizard) — perlu isi & submit Step 1 untuk lanjut; dilarang oleh aturan harvest read-only. |
| SCR-12/13 | Drawer "Hitung Ulang Armada" — tombolnya ADA di Edit Order (dikonfirmasi), tapi klik pada tombol ini **diblokir oleh permission classifier** lingkungan agent saat run ini (bukan error aplikasi). Coba lagi di run berikutnya. |
| SCR-14 | Panel "Visualisasi Muatan Saat Ini" versi wizard Step 2 — sama seperti di atas, jalur "Visualisasi Terbaru" di Edit Order belum sempat dicoba setelah insiden blokir classifier; versi Detail Order (SCR-21) sudah dipetakan dan ditemukan bug 404. |
| SCR-15/16/17 | Step 3 Vendor dan Harga (wizard) — perlu lanjut dari Step 1 & 2 wizard; di luar cakupan read-only. |
| SCR-18/19 | Step 4 Review & pop up Simpan Draf (wizard) — idem, perlu isi form lengkap. |
| SCR-24 | Pop up Data No. Perjalanan — tidak ada order berstatus `Ditugaskan` di antara 5 order yang tersedia di staging. |
| SCR-25/26/28/29/31/32/34/36/37/38/39 | Varian Multipickup/Multidrop/Multipoint (Step 2/3/4 wizard, Edit, Review) — tidak ada order existing bertipe ini di staging (sampling 2/5 order semuanya "Normal"), dan wizard tidak dilanjutkan sesuai aturan read-only. |
| SCR-27/33 | Pop up Detail Multipickup / Detail Multidrop — tidak ada order bertipe ini untuk membuka link "Lihat Detail". |
| SCR-30/35 | Detail Order Multipickup / Multidrop — idem, tidak ada datanya di staging. |

## Rekomendasi data-testid untuk developer

Aplikasi ini **tidak memiliki `data-testid` sama sekali** di seluruh layar yang di-harvest. Prioritas tinggi untuk ditambahkan (memakai usulan ui-inventory bila relevan):

- `order-quota-progress` — blok Kuota Order di sidebar (nilai `0/200`, `0%` saat ini tidak bisa disasar stabil)
- `header-notification` — tombol bell notifikasi (saat ini benar-benar tanpa nama aksesibel apa pun)
- `sidebar-toggle` — tombol "Toggle Sidebar" (sudah ada aria-label, tapi testid akan lebih tahan perubahan teks)
- `order-row-status` — badge status per baris tabel Daftar Order (banyak nilai berulang, sulit discope tanpa index)
- `order-action-menu` — kontainer menu aksi kebab (agar item menu bisa discope, saat ini menu mengambang tanpa `role="menu"`)
- `filter-kota-asal` / `filter-kota-tujuan` — dropdown filter Kota Asal & Kota Tujuan (saat ini sama-sama berlabel default "Semua Kota")
- `filter-drop-point-asal` / `filter-drop-point-tujuan` — idem, sama-sama "Semua Drop Point"
- `input-harga` — input Harga di Step 3 / Edit Order (placeholder `"0"` bukan accessible name yang layak)
- `modal-batalkan-order` / `modal-visualisasi-muatan` / `modal-pilih-barang` — root container popup, plus tambahkan `role="dialog"` + `aria-label` supaya `getByRole('dialog', {name})` bisa dipakai (saat ini nol elemen match `[role="dialog"]` meski modal terbuka)
- `wizard-buat-order-selanjutnya` — tombol Selanjutnya Step 1 (agar state disabled/enabled bisa diverifikasi dari testid, bukan hanya visual)
- `input-nilai-barang` — belum terverifikasi (kolom Nilai Barang hanya muncul saat asuransi aktif, tidak tercapai di harvest ini)

## Catatan perbedaan vs ui-inventory

- **Tenant & role bar** live: `PT. OMESH` / `Admin` · `Administrator` — desain mengasumsikan `Mentari Sumber Kertas` / `Shipper · Staff Operasional`, `Andika (andikamsk@gmail.com)`. Jangan pakai nama tenant/role dari desain sebagai oracle.
- **Panel Filter (SCR-02) selalu tampil** di Daftar Order — tombol "Filter" hanya mengubah state visual tombol (`active`), **tidak menyembunyikan/menampilkan panel**. Desain mengasumsikan panel adalah toggle. Executor jangan andalkan "klik Filter untuk membuka panel" — panel sudah ada begitu halaman dimuat.
- Field filter live **beda dari desain**: ADA `Tanggal Buat`, `Pengirim`, `Penerima` (tidak ada di desain); **TIDAK ADA** `Total Harga`, `Metode Pengiriman` (ada di desain).
- Filter `Tipe Pengiriman` & (kemungkinan) `Metode Pengiriman` **enabled penuh** di live, bukan "tampak disabled" seperti ASM-D03.
- **FND-01 (desain)**: `Order Kembali` diasumsikan muncul di status `Ditugaskan`. Live menunjukkan `Order Kembali` muncul di status **`Menunggu Penugasan`**. Tidak ada order `Ditugaskan` untuk verifikasi silang — kandidat revisi FND-01, perlu dicek ulang saat ada data status `Ditugaskan`.
- **FND-03 (desain)**: modal "Pilih Barang" diasumsikan **tanpa tombol close**. Live **punya** tombol "Tutup" (×). Kandidat resolved/salah asumsi.
- **FND-09 (desain)**: Edit Order diasumsikan **tidak** menampilkan FAB "Hitung Ulang Armada"/"Visualisasi Terbaru". Live **menampilkan keduanya** di header Edit Order. Kandidat resolved/salah asumsi — tapi drawer/panelnya sendiri belum berhasil diverifikasi isinya (diblokir permission classifier).
- Kartu Jenis Pengiriman (FTL/FCL/LTL/LCL) di Step 1 adalah **`<button>` biasa**, bukan `role="radio"` seperti asumsi selector di ui-inventory.
- Tombol "Selanjutnya" Step 1 **tidak punya atribut `disabled`** di DOM walau field wajib (Tipe Pengiriman) kosong — berbeda dari deskripsi visual "disabled (abu)" di desain. Perlu skenario test terpisah untuk memastikan apakah validasi terjadi saat klik (toast/inline error) atau benar-benar tidak tervalidasi.
- Info paginasi Daftar Order pakai **en dash "–"** (`Menampilkan 1–5 data dari 5 data`), bukan hyphen biasa seperti pola contoh di ui-inventory (`Menampilkan 1 - 20 data dari 30 data`). Hindari exact-string-match, pakai regex.
- Modal Pilih Barang: label badge item sudah ada memakai **"Sudah ditambahkan"** (huruf kecil di kata kedua), bukan "Sudah Ditambahkan"; checkbox item yang sudah ditambahkan **disabled** (bukan tetap aktif seperti koreksi ASM-013 di desain); ada **paginasi** (Sebelumnya/Selanjutnya + indikator halaman) yang tidak disebut di desain; tombol submit bernama **"Tambahkan"**, bukan "Simpan", dan tidak ada tombol "Batal" terpisah (hanya "Tutup" + "Tambahkan").
- Detail Order punya section **"No. Perjalanan"** langsung sebagai accordion di halaman itu sendiri (dengan empty-state "Belum ada nomor perjalanan untuk order ini."), bukan hanya via pop up terpisah (SCR-24) seperti asumsi navigasi di desain.
- **Bug baru ditemukan (tidak ada di daftar FND desain)**: tombol "Visualisasi Muatan" di Detail Order memicu `GET /api/order/stuffing/visualisasi` yang mengembalikan **404**, sehingga panel menampilkan pesan error "Gagal memuat visualisasi muatan." — perlu dilaporkan sebagai bug-candidate baru, bukan gap desain.
- Tidak ada elemen bermakna dengan `role="dialog"` di popup manapun yang diuji (Batalkan Order, Visualisasi Muatan, Pilih Barang) — selector `getByRole('dialog', { name })` yang diusulkan di ui-inventory **tidak akan menemukan elemen**. Gunakan scoping berbasis heading terdekat sebagai gantinya, atau minta developer menambahkan `role="dialog"`.
