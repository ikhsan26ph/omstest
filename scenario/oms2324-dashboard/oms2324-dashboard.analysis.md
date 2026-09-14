# Analysis - oms2324-dashboard

## Requirements

| REQ | Area | Deskripsi | Acceptance Criteria |
|---|---|---|---|
| REQ-001 | Monitoring | Sistem menampilkan 2 score card Monitoring: Total Armada dan Melewati SLA. | Total Armada menghitung armada dalam proses pengiriman yang sudah ditugaskan dan sudah mencapai status aktif; Melewati SLA menghitung armada yang selisih selesai muat pertama sampai selesai bongkar terakhir melebihi master waktu perjalanan. |
| REQ-002 | Monitoring | Sistem menampilkan Daftar Armada Berjalan dalam bentuk card per nopol. | Hanya order yang sudah ditugaskan yang tampil; setiap card menampilkan nopol, ID Order, rute, vendor, status, informasi SLA bila ada, dan aksi Detail. |
| REQ-003 | Monitoring | Daftar Armada Berjalan dapat difilter berdasarkan status. | Filter tersedia untuk Semua Tahapan, Selesai Muat, Selesai Bongkar, Melewati SLA, dan Belum Ada Pencatatan; Belum Ada Pencatatan hanya menampilkan order yang sudah ditugaskan dan belum Selesai Muat pada H-1 tanggal pemuatan. |
| REQ-004 | Monitoring | Daftar Armada Berjalan dapat dicari dan dimuat ulang. | Search dapat mencari berdasarkan nopol, sopir, ID order, vendor, dan kota; tombol muat ulang memperbarui daftar dan informasi pembaruan terakhir. |
| REQ-005 | Monitoring | Aksi Detail pada card membuka detail penugasan untuk ID order dan nopol terkait. | Klik Detail pada card membawa user ke halaman detail penugasan dengan konteks ID order dan nopol yang sama. |
| REQ-006 | Distribusi & Muatan | Sistem menampilkan Dashboard Distribusi & Muatan dengan filter periode dan export PDF. | Dashboard memiliki filter Harian, Mingguan, Bulanan, Tahunan, Pilih Tanggal; default periode adalah Bulanan; data berdasarkan Tanggal Permintaan Muat; order batal tidak dihitung; Export menghasilkan PDF dashboard. |
| REQ-007 | Jangkauan Distribusi | Sistem menampilkan Jangkauan Distribusi dengan 3 score card dan peta choropleth. | Score card menghitung Kota Terjangkau, Jumlah Pengirim Aktif, dan Jumlah Penerima Aktif; peta menampilkan gradasi provinsi/kota, label jumlah pengiriman, zoom detail kota, dan filter Kota Asal/Kota Tujuan dengan default Kota Tujuan. |
| REQ-008 | Utilitas Armada | Sistem menampilkan Utilitas Armada. | Score card menghitung rata-rata barang per pengiriman, pengiriman < 50% kapasitas, dan kelebihan muatan; Profil Barang Terkirim menampilkan 3-10 bar sampai 80% volume dan sisanya Lainnya; Tingkat Keterisian Armada menghitung ruang dan berat, menentukan bar pembatas, warna, keterangan, dan total armada/kontainer. |

### Aturan Validasi & Perhitungan

| Topik | Aturan |
|---|---|
| Order valid | Semua perhitungan Dashboard Distribusi & Muatan hanya memakai order selain yang dibatalkan. |
| Periode default | Dashboard Distribusi & Muatan default terfilter Bulanan, dari tanggal 1 bulan berjalan sampai tanggal berjalan. |
| Harian | Menggunakan tanggal berjalan berdasarkan Tanggal Permintaan Muat. |
| Mingguan | Menggunakan ISO week berjalan, Senin sampai Minggu. |
| Tahunan | Menggunakan tahun berjalan. |
| Custom tanggal | Range tanggal bebas melalui calendar; tanggal akhir tidak boleh sebelum tanggal awal. |
| Melewati SLA | Selesai bongkar terakhir - selesai muat pertama > target master waktu perjalanan. Format kelebihan waktu memakai h, j, m. |
| Belum Ada Pencatatan | Order sudah ditugaskan, belum berubah ke Selesai Muat, dan H-1 dari tanggal pemuatan. |
| Keterisian ruang | SUM(volume_muatan_m3) / SUM(kapasitas_volume_m3) x 100. |
| Keterisian berat | SUM(berat_muatan_kg) / SUM(kapasitas_berat_kg) x 100. |
| Bar pembatas | Nilai lebih besar menjadi pembatas, kecuali selisih ruang dan berat < 5 poin maka keduanya non-pembatas. |
| Warna bar pembatas | <80% abu-abu; 80-100% hijau; >100% merah. |
| Warna bar non-pembatas | Selalu biru netral. |

### Role/Aktor

| Aktor | Hak Akses |
|---|---|
| Admin / Staff Operasional | Mengakses Dashboard Monitoring, melihat score card dan daftar armada berjalan, filter, search, refresh, dan membuka Detail penugasan. |
| Shipper / Staff Operasional | Mengakses Dashboard Distribusi & Muatan, mengubah periode, memilih Kota Asal/Kota Tujuan, zoom peta, melihat grafik, dan export PDF. |
| User tanpa akses dashboard | Tidak dapat melihat halaman dashboard terkait dan diarahkan/ditolak oleh sistem. |

### User Flow

1. User membuka menu Dashboard > Monitoring.
2. Sistem menampilkan score card Total Armada dan Melewati SLA serta Daftar Armada Berjalan.
3. User memfilter status, mencari data, memuat ulang daftar, atau membuka Detail card.
4. User membuka Dashboard > Distribusi & Muatan.
5. Sistem menampilkan filter periode, Jangkauan Distribusi, peta choropleth, Utilitas Armada, Profil Barang Terkirim, dan Tingkat Keterisian Armada.
6. User memilih periode, memilih range custom, mengganti filter peta Kota Asal/Kota Tujuan, zoom peta sampai detail kota, melihat tooltip chart, atau export PDF.

## UI Inventory

### Layar Monitoring

Sumber desain: `inputs/oms2324-dashboard/designs/128-admin-monitoring-tracking-data-kasus.png`

| Elemen | Jenis/State | Selector Playwright Disarankan | Data Test ID |
|---|---|---|---|
| Menu Dashboard | navigation link, expanded | `getByRole('link', { name: 'Dashboard' })` | `nav-dashboard` |
| Submenu Monitoring | navigation link, active | `getByRole('link', { name: 'Monitoring' })` | `nav-dashboard-monitoring` |
| Breadcrumb Dashboard > Monitoring | text/navigation | `getByText('Dashboard')`, `getByText('Monitoring')` | `breadcrumb-monitoring` |
| Judul Monitoring | heading | `getByRole('heading', { name: 'Monitoring' })` | `page-title-monitoring` |
| Score card Total Armada | metric card | `getByText('Total Armada')` | `score-total-armada` |
| Score card Melewati SLA | metric card | `getByText('Melewati SLA')` | `score-melewati-sla` |
| Filter Semua Tahapan | button/chip active | `getByRole('button', { name: /Semua Tahapan/ })` | `filter-semua-tahapan` |
| Filter Selesai Muat | button/chip | `getByRole('button', { name: /Selesai Muat/ })` | `filter-selesai-muat` |
| Filter Selesai Bongkar | button/chip | `getByRole('button', { name: /Selesai Bongkar/ })` | `filter-selesai-bongkar` |
| Filter Melewati SLA | button/chip | `getByRole('button', { name: /Melewati SLA/ })` | `filter-melewati-sla` |
| Filter Belum Ada Pencatatan | button/chip | `getByRole('button', { name: /Belum Ada Pencatatan/ })` | `filter-belum-ada-pencatatan` |
| Pencarian daftar armada | textbox placeholder `Cari nopol, sopir, atau ID order` | `getByRole('textbox', { name: /Cari nopol/ })` | `search-armada-berjalan` |
| Tombol cari | icon button | `getByRole('button', { name: 'Cari' })` | `button-search-armada` |
| Tombol muat ulang | icon button | `getByRole('button', { name: /Muat ulang/ })` | `button-refresh-armada` |
| Pembaruan terakhir | text state | `getByText(/Pembaruan terakhir:/)` | `last-updated-monitoring` |
| Card armada berjalan | repeated card | `getByText('ID Order: TRC46135584')` | `card-armada-TRC46135584` |
| Status card | status badge | `getByText('Selesai bongkar')` | `badge-status-selesai-bongkar` |
| Badge SLA | status badge error | `getByText(/Melewati SLA/)` | `badge-sla-overdue` |
| Link Detail | link/button per card | `getByRole('link', { name: 'Detail' })` | `link-detail-armada` |
| Pagination Sebelumnya/Berikutnya | button disabled/enabled | `getByRole('button', { name: 'Sebelumnya' })`, `getByRole('button', { name: 'Berikutnya' })` | `pagination-monitoring` |

### Layar Distribusi & Muatan - Peta Provinsi

Sumber desain: `inputs/oms2324-dashboard/designs/129-admin-dahsboard-distribusi.png`

| Elemen | Jenis/State | Selector Playwright Disarankan | Data Test ID |
|---|---|---|---|
| Submenu Distribusi & Muatan | navigation link active | `getByRole('link', { name: 'Distribusi & Muatan' })` | `nav-dashboard-distribusi-muatan` |
| Judul Distribusi & Muatan | heading | `getByRole('heading', { name: 'Distribusi & Muatan' })` | `page-title-distribusi-muatan` |
| Chip Harian | button/chip active pada desain | `getByRole('button', { name: 'Harian' })` | `period-harian` |
| Chip Mingguan | button/chip | `getByRole('button', { name: 'Mingguan' })` | `period-mingguan` |
| Chip Bulanan | button/chip default menurut spec | `getByRole('button', { name: 'Bulanan' })` | `period-bulanan` |
| Chip Tahunan | button/chip | `getByRole('button', { name: 'Tahunan' })` | `period-tahunan` |
| Pilih Tanggal | date range picker button | `getByRole('button', { name: /Pilih Tanggal/ })` | `period-custom-date` |
| Export | button | `getByRole('button', { name: 'Export' })` | `button-export-dashboard` |
| Score Kota Terjangkau | metric card | `getByText('Kota Terjangkau')` | `score-kota-terjangkau` |
| Score Jumlah Pengirim Aktif | metric card | `getByText('Jumlah Pengirim Aktif')` | `score-pengirim-aktif` |
| Score Jumlah Penerima Aktif | metric card | `getByText('Jumlah Penerima Aktif')` | `score-penerima-aktif` |
| Peta choropleth Indonesia | map region | `getByTestId('map-jangkauan-distribusi')` | `map-jangkauan-distribusi` |
| Tombol perbesar peta | icon button | `getByRole('button', { name: 'Perbesar' })` | `map-zoom-in` |
| Tombol perkecil peta | icon button | `getByRole('button', { name: 'Perkecil' })` | `map-zoom-out` |
| Tombol reset/fit peta | icon button | `getByRole('button', { name: /Reset|Fit/ })` | `map-reset` |
| Dropdown Kota Asal/Kota Tujuan | combobox | `getByRole('combobox', { name: /Kota/ })` | `map-location-type` |
| Legend jumlah order | legend | `getByText('Jumlah Order')` | `map-legend-jumlah-order` |
| Label provinsi dan jumlah | map labels | `getByText('DKI Jakarta')`, `getByText('Jawa Barat')` | `map-label-provinsi` |
| Profil Barang Terkirim | chart | `getByText('Profil Barang Terkirim')` | `chart-profil-barang` |
| Bar Cat Tembok/Keramik/Semen/Pipa PVC/Cat Kayu/Lainnya | bar chart item | `getByText('Cat Tembok')` | `bar-profil-barang` |
| Tingkat Keterisian Armada | progress/bar chart | `getByText('Tingkat Keterisian Armada')` | `panel-keterisian-armada` |
| Keterisian Ruang | progress bar | `getByText('Keterisian Ruang')` | `bar-keterisian-ruang` |
| Keterisian Barang | progress bar | `getByText(/Keterisian Barang/)` | `bar-keterisian-berat` |

### Layar Distribusi & Muatan - Peta Kota

Sumber desain: `inputs/oms2324-dashboard/designs/130-admin-dahsboard-distribusi.png`

| Elemen | Jenis/State | Selector Playwright Disarankan | Data Test ID |
|---|---|---|---|
| Peta kota/kabupaten Jawa Timur | map zoomed state | `getByTestId('map-jangkauan-distribusi')` | `map-city-detail` |
| Dropdown lokasi terbuka | expanded combobox/listbox | `getByRole('listbox')` | `map-location-listbox` |
| Opsi Kota Asal (Pengirim) | option | `getByRole('option', { name: 'Kota Asal (Pengirim)' })` | `option-kota-asal` |
| Opsi Kota Tujuan (Penerima) | option | `getByRole('option', { name: 'Kota Tujuan (Penerima)' })` | `option-kota-tujuan` |
| Tooltip/label kota | map label | `getByText('Kota Surabaya')` | `map-label-kota` |
| Tooltip chart Profil Barang | tooltip visible | `getByText('731')` | `tooltip-profil-barang` |

### State & Pesan yang Perlu Diuji

| State | Ekspektasi |
|---|---|
| Empty Monitoring | Menampilkan pesan daftar kosong ketika tidak ada order berjalan untuk filter/search. |
| Loading refresh | Tombol refresh menampilkan state loading dan tidak menduplikasi card. |
| Error export | Menampilkan pesan gagal export bila PDF gagal dibuat. |
| Custom date invalid | Menampilkan validasi ketika tanggal akhir sebelum tanggal awal. |
| Unauthorized | User tanpa akses dashboard tidak melihat data dashboard dan diarahkan/ditolak. |

## Assumptions Log

- Desain `129-admin-dahsboard-distribusi.png` memperlihatkan chip Harian aktif, tetapi spec menyatakan default filter adalah Bulanan. Scenario mengikuti spec sebagai sumber kebenaran dan menambahkan validasi default Bulanan.
- Ekstra `peta-sebaran-order-indonesia.html` dibaca sebagai konteks peta: terdapat tombol Perbesar, Perkecil, Reset, Unduh PNG, peta provinsi/kota, label jumlah order, gradasi warna, dan legend. Karena dashboard spec meminta export PDF, scenario memakai tombol Export dashboard, sementara tombol unduh PNG diperlakukan sebagai kemampuan peta pendukung.
- Nama aktor di desain memperlihatkan Admin dan Shipper dengan label Staff Operasional; hak akses diasumsikan mengikuti submenu yang tampil pada masing-masing desain.
- Tidak ada spesifikasi API, route URL, atau pesan error final; scenario memakai ekspektasi UI berbasis teks yang umum dan selector hint sebagai usulan.
