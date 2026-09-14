# Selector Map — Modul Order (`/order`)

- **Tanggal harvest terbaru**: 2026-09-14
- **Modul pemicu**: `oms012-order-ftl-auto-stuffing`
- **Base URL**: `https://oms-staging.prahu-hub.com`
- **Output mentah**: `artifacts/explore-scripts/harvest-selectors-oms012-order-ftl-auto-stuffing.json`
- **Cakupan live 2026-09-14**: Daftar Order + Panel Filter, Detail Order, Popup Visualisasi Muatan Detail.
- **Skipped live 2026-09-14**: Edit Order, Modal Batalkan Order, Popup Data No. Perjalanan, Buat Order Step 1, Batch Order, Riwayat Pembatalan. Route tersebut redirect ke `/login?next=...` setelah navigasi detail pada run ini; selector historis yang masih relevan tetap dicatat dengan sumber `historis`.

## Temuan Struktural

- Tidak ditemukan `data-testid` pada elemen yang di-harvest live.
- Popup/modal Order belum punya root `role="dialog"` stabil; pakai heading/tombol di dalam popup atau minta developer menambah `role="dialog"` + `data-testid`.
- Panel Filter Daftar Order tampil langsung di `/order`; tombol `Filter` hanya aman dipakai sebagai kontrol visual, bukan precondition pembuka panel.
- Tombol notifikasi header kanan tidak punya nama aksesibel.

## Tabel Selector

| SCR | Elemen (nama sesuai ui-inventory) | Selector terbaik | Sumber | Catatan |
|---|---|---|---|---|
| SCR-00 | Logo/Home | `getByRole('link', { name: 'PT. OMESH' })` | role+name | Link sidebar. |
| SCR-00 | Menu Dashboard | `getByRole('button', { name: 'Dashboard' })` | role+name | Collapsible. |
| SCR-00 | Menu Order | `getByRole('link', { name: 'Order' })` | role+name | Route `/order`. |
| SCR-00 | Menu Penugasan Tracking | `getByRole('link', { name: 'Penugasan Tracking' })` | role+name | Sidebar. |
| SCR-00 | Menu Simulasi Muatan | `getByRole('link', { name: 'Simulasi Muatan' })` | role+name | Sidebar. |
| SCR-00 | Menu Master Wilayah | `getByRole('button', { name: 'Master Wilayah' })` | role+name | Collapsible. |
| SCR-00 | Menu Master Operasional | `getByRole('button', { name: 'Master Operasional' })` | role+name | Collapsible. |
| SCR-00 | Menu Pusat Notifikasi | `getByRole('button', { name: 'Pusat Notifikasi' })` | role+name | Collapsible. |
| SCR-00 | Toggle mode gelap | `getByRole('button', { name: 'Aktifkan mode gelap' })` | role+name | Jangan diklik saat harvest read-only. |
| SCR-00 | Toggle Sidebar | `getByRole('button', { name: 'Toggle Sidebar' })` | role+name | Header. |
| SCR-00 | Notifikasi header | tombol tanpa nama dekat profil | TIDAK STABIL | Perlu `aria-label`/`data-testid`. |
| SCR-00 | Breadcrumb Beranda | `getByRole('link', { name: 'Beranda' })` | role+name | Tampil di layar Order. |
| SCR-01 | Buat Order | `getByRole('button', { name: 'Buat Order' })` | role+name | Navigasi ke `/order/buat`. |
| SCR-01 | Batch Order | `getByRole('button', { name: 'Batch Order' })` | role+name | Navigasi ke `/order/batch`. |
| SCR-01 | Riwayat Pembatalan | `getByRole('button', { name: 'Riwayat Pembatalan' })` | role+name | Navigasi ke `/order/riwayat-pembatalan`. |
| SCR-01 | Filter | `getByRole('button', { name: 'Filter' })` | role+name | Panel sudah terlihat. |
| SCR-01 | Dropdown jumlah data | `locator('select').first()` scoped di header tabel | TIDAK STABIL | Native select tanpa label; opsi `10/20/50/100`. |
| SCR-01 | Tabel order | `getByRole('table')` | role | Gunakan row-scope. |
| SCR-01 | Salin ID Order | `getByRole('button', { name: /^Salin ORD/ })` | role+name | Dinamis mengikuti kode order. |
| SCR-01 | Badge tipe Multipickup | `getByRole('button', { name: 'Multipickup' })` scoped ke row | role+name | Terlihat di list live. |
| SCR-01 | Badge tipe Multidrop | `getByRole('button', { name: 'Multidrop' })` scoped ke row | role+name | Terlihat di list live. |
| SCR-01 | Aksi baris | `getByRole('button', { name: 'Aksi' }).nth(i)` scoped ke row | role+name (tidak unik) | Perlu row atau index. |
| SCR-02 | ID Order filter | `getByPlaceholder('Masukkan ID Order')` | placeholder | Stabil. |
| SCR-02 | Jenis Order filter | `getByRole('button', { name: 'Semua Jenis' })` | role+name | Dropdown custom. |
| SCR-02 | Vendor filter | `getByPlaceholder('Masukkan Vendor')` | placeholder | Stabil. |
| SCR-02 | Kota Asal filter | scoped label `Kota Asal` lalu tombol `Semua Kota` pertama | TIDAK STABIL | Ada dua tombol `Semua Kota`. |
| SCR-02 | Kota Tujuan filter | scoped label `Kota Tujuan` lalu tombol `Semua Kota` kedua | TIDAK STABIL | Ada dua tombol `Semua Kota`. |
| SCR-02 | Tanggal Buat filter | `getByRole('button', { name: 'Pilih Tanggal' })` | role+name | Datepicker. |
| SCR-02 | Tipe Pengiriman filter | `getByRole('button', { name: 'Semua Tipe' })` | role+name | Dropdown custom. |
| SCR-02 | Drop Point Asal filter | scoped label `Drop Point Asal` lalu tombol `Semua Drop Point` pertama | TIDAK STABIL | Ada dua tombol `Semua Drop Point`. |
| SCR-02 | Drop Point Tujuan filter | scoped label `Drop Point Tujuan` lalu tombol `Semua Drop Point` kedua | TIDAK STABIL | Ada dua tombol `Semua Drop Point`. |
| SCR-02 | Pengirim filter | `getByPlaceholder('Masukkan Nama Pengirim')` | placeholder | Stabil. |
| SCR-02 | Penerima filter | `getByPlaceholder('Masukkan Nama Penerima')` | placeholder | Stabil. |
| SCR-02 | Status filter | `getByRole('button', { name: 'Semua Status' })` | role+name | Dropdown custom. |
| SCR-02 | Reset filter | `getByRole('button', { name: 'Reset' })` | role+name | Aman untuk reset filter. |
| SCR-02 | Terapkan filter | `getByRole('button', { name: 'Terapkan' })` | role+name | Submit filter list. |
| SCR-03 | Menu item Detail | `getByRole('button', { name: 'Detail', exact: true })` scoped ke menu aksi | role+name | Menu tanpa root stabil. |
| SCR-03 | Menu item Edit | `getByRole('button', { name: 'Edit', exact: true })` scoped ke menu aksi | role+name | Tergantung status order. |
| SCR-03 | Menu item Batalkan Order | `getByRole('button', { name: 'Batalkan Order' })` scoped ke menu aksi | role+name | Jangan klik submit pembatalan. |
| SCR-03 | Menu item Lihat No. Perjalanan | `getByRole('button', { name: 'Lihat No. Perjalanan' })` scoped ke menu aksi | role+name | Tergantung status order. |
| SCR-03 | Menu item Lanjutkan Pengisian | `getByRole('button', { name: 'Lanjutkan Pengisian' })` scoped ke menu aksi | role+name | Untuk draft-like order. |
| SCR-03 | Menu item Order Kembali | `getByRole('button', { name: 'Order Kembali' })` scoped ke menu aksi | role+name | Historis: muncul di Menunggu Penugasan dan Ditugaskan. |
| SCR-03 | Menu item Riwayat Perubahan | `getByRole('button', { name: 'Riwayat Perubahan' })` scoped ke menu aksi | role+name | Navigasi ke `/order/{uuid}/riwayat`. |
| SCR-04/05 | Kartu FTL | `getByRole('button', { name: /FTL/ })` | historis role+name | Button biasa, bukan radio. |
| SCR-04/05 | Kartu FCL | `getByRole('button', { name: /FCL/ })` | historis role+name | Button biasa, bukan radio. |
| SCR-04/05 | Kartu LTL | `getByRole('button', { name: /LTL/ })` | historis role+name | Button biasa, bukan radio. |
| SCR-04/05 | Kartu LCL | `getByRole('button', { name: /LCL/ })` | historis role+name | Button biasa, bukan radio. |
| SCR-04/05 | Jenis Armada | `getByRole('button', { name: 'Pilih Jenis Armada' })` | historis role+name | Step 1 FTL. |
| SCR-04/05 | Jumlah Armada | `getByPlaceholder('Masukkan Jumlah Armada')` | historis placeholder | Step 1 FTL. |
| SCR-04/05 | Tipe Pengiriman | `getByRole('button', { name: 'Pilih Tipe Pengiriman' })` | historis role+name | Step 1 FTL. |
| SCR-04/05 | Selanjutnya | `getByRole('button', { name: 'Selanjutnya' })` scoped ke wizard footer | historis role+name | Ada juga di modal/paginasi. |
| SCR-04/05 | Simpan ke Draf | `getByRole('button', { name: 'Simpan ke Draf' })` | historis role+name | Aksi tulis; jangan diklik saat harvest. |
| SCR-04/05 | Batal wizard | `getByRole('button', { name: 'Batal' })` | historis role+name | Memicu dialog konfirmasi. |
| SCR-09/10 | Pilih Barang Step 2 | `getByRole('button', { name: 'Pilih Barang' })` scoped ke unit/sub-section | historis role+name | Muncul setelah Step 1 valid. |
| SCR-09/10 | Hitung Ulang Armada | `getByRole('button', { name: 'Hitung Ulang Armada' })` | historis role+name | Jangan klik `Terapkan ke Order`. |
| SCR-09/10 | Visualisasi Terbaru | `getByRole('button', { name: 'Visualisasi Terbaru' })` | historis role+name | Drawer read-only. |
| SCR-11 | Modal Pilih Barang - judul | `getByRole('heading', { name: 'Pilih Barang' })` | historis role+name | Modal tanpa root dialog. |
| SCR-11 | Modal Pilih Barang - cari | `getByPlaceholder('Cari Kode SKU atau Nama Barang')` | historis placeholder | Stabil. |
| SCR-11 | Modal Pilih Barang - Tutup | `getByRole('button', { name: 'Tutup' }).first()` scoped ke modal | historis role+name | Tombol close. |
| SCR-11 | Modal Pilih Barang - Tambahkan | `getByRole('button', { name: 'Tambahkan' })` | historis role+name | Aksi pilih barang. |
| SCR-12/13 | Drawer Hitung Ulang Armada - Terapkan ke Order | `getByRole('button', { name: 'Terapkan ke Order' })` | historis role+name | Aksi tulis; jangan diklik saat harvest. |
| SCR-12/13 | Drawer Hitung Ulang Armada - Batal | `getByRole('button', { name: 'Batal' })` scoped ke drawer | historis role+name | Tutup drawer. |
| SCR-14/21 | Popup Visualisasi - Tutup header | `getByRole('button', { name: 'Tutup' }).first()` scoped ke popup | role+name | Live 2026-09-14. |
| SCR-14/21 | Popup Visualisasi - Tutup footer | `getByRole('button', { name: 'Tutup' }).last()` scoped ke popup | role+name | Live 2026-09-14. |
| SCR-14/21 | Popup Visualisasi - Ganti warna unit | `getByRole('button', { name: 'Ganti warna unit' })` | role+name | Live 2026-09-14. |
| SCR-14/21 | Popup Visualisasi - layar penuh | `getByRole('button', { name: 'Tampilkan layar penuh' })` | role+name | Live 2026-09-14. |
| SCR-14/21 | Popup Visualisasi - geser atas | `getByRole('button', { name: 'Geser ke atas' })` | role+name | Live 2026-09-14. |
| SCR-14/21 | Popup Visualisasi - geser kiri | `getByRole('button', { name: 'Geser ke kiri' })` | role+name | Live 2026-09-14. |
| SCR-14/21 | Popup Visualisasi - geser kanan | `getByRole('button', { name: 'Geser ke kanan' })` | role+name | Live 2026-09-14. |
| SCR-14/21 | Popup Visualisasi - geser bawah | `getByRole('button', { name: 'Geser ke bawah' })` | role+name | Live 2026-09-14. |
| SCR-14/21 | Popup Visualisasi - item barang | `getByRole('button', { name: '<nama barang>' })` scoped ke popup | TIDAK STABIL | Contoh live: `Sepatu Running Pria`; data dinamis. |
| SCR-20 | Breadcrumb Daftar Order | `getByRole('link', { name: 'Daftar Order' })` | role+name | Detail Order. |
| SCR-20 | Judul/accordion Detail Order | `getByRole('button', { name: 'Detail Order' })` | role+name | Live berupa button/collapsible. |
| SCR-20 | Visualisasi Muatan | `getByRole('button', { name: 'Visualisasi Muatan' })` | role+name | Membuka popup visualisasi. |
| SCR-20 | Batalkan Order | `getByRole('button', { name: 'Batalkan Order' })` | role+name | Membuka modal pembatalan; jangan submit. |
| SCR-20 | Edit Order | `getByRole('button', { name: 'Edit Order' })` | role+name | Tampil pada order yang bisa diedit. |
| SCR-20 | Salin ID Order detail | `getByRole('button', { name: /^Salin ORD/ })` | role+name | Dinamis mengikuti order. |
| SCR-20 | Accordion Data Pengirim | `getByRole('button', { name: 'Data Pengirim' })` | role+name | Detail Order. |
| SCR-20 | Accordion Data Penerima | `getByRole('button', { name: 'Data Penerima' })` | role+name | Detail Order. |
| SCR-20 | Accordion Data Barang | `getByRole('button', { name: 'Data Barang' })` | role+name | Detail Order. |
| SCR-20 | Accordion Vendor dan Harga | `getByRole('button', { name: 'Vendor dan Harga' })` | role+name | Detail Order. |
| SCR-20 | Accordion No. Perjalanan | `getByRole('button', { name: 'No. Perjalanan' })` | role+name | Detail Order. |
| SCR-22 | Modal Batalkan Order - judul | `getByRole('heading', { name: 'Batalkan Order' })` | historis role+name | Modal skipped live 2026-09-14. |
| SCR-22 | Modal Batalkan Order - Alasan | `locator('#cancelReason')` | id stabil | Satu-satunya id stabil historis. |
| SCR-22 | Modal Batalkan Order - submit | `getByRole('button', { name: 'Batalkan Order' })` scoped ke modal | historis role+name | Aksi destruktif; jangan diklik tanpa skenario eksplisit pada data sendiri. |
| SCR-23 | Edit Order - Hitung Ulang Armada | `getByRole('button', { name: 'Hitung Ulang Armada' })` | historis role+name | Route skipped live 2026-09-14. |
| SCR-23 | Edit Order - Visualisasi Terbaru | `getByRole('button', { name: 'Visualisasi Terbaru' })` | historis role+name | Route skipped live 2026-09-14. |
| SCR-23 | Edit Order - PIC Pengirim | `getByPlaceholder('Masukkan PIC Pengirim')` | historis placeholder | Stabil. |
| SCR-23 | Edit Order - PIC Penerima | `getByPlaceholder('Masukkan PIC Penerima')` | historis placeholder | Stabil. |
| SCR-23 | Edit Order - No. WhatsApp PIC | `getByPlaceholder('Masukkan No. WhatsApp PIC')` | historis placeholder (tidak unik) | Scope ke Data Pengirim/Penerima. |
| SCR-23 | Edit Order - Catatan | `getByPlaceholder('Masukkan Catatan')` | historis placeholder (tidak unik) | Scope ke section. |
| SCR-23 | Edit Order - Tambahkan Asuransi | `getByRole('checkbox', { name: 'Tambahkan Asuransi' })` | historis role+name | Per unit/armada. |
| SCR-23 | Edit Order - Gunakan komponen harga | `getByRole('checkbox', { name: 'Gunakan komponen harga' })` | historis role+name | Step harga/edit. |
| SCR-23 | Edit Order - Batal | `getByRole('button', { name: 'Batal' })` scoped ke footer | historis role+name | Memicu dialog batal. |
| SCR-23 | Edit Order - Simpan | `getByRole('button', { name: 'Simpan', exact: true })` scoped ke footer | historis role+name | Aksi tulis; jangan diklik saat harvest. |
| SCR-24 | Popup Data No. Perjalanan - judul | `getByRole('heading', { name: 'Data No. Perjalanan' })` | historis role+name | Action skipped live 2026-09-14. |
| SCR-24 | Popup Data No. Perjalanan - Salin | `getByRole('button', { name: /Salin/ })` scoped ke popup | historis role+name | Nomor dinamis. |
| SCR-24 | Popup Data No. Perjalanan - Tutup | `getByRole('button', { name: 'Tutup' })` scoped ke popup | historis role+name | Sebagian varian memakai ikon close. |
| SCR-25 | Riwayat Pembatalan - Kembali | `getByRole('button', { name: /Kembali/ })` | historis role+name | Route skipped live 2026-09-14. |
| SCR-25 | Riwayat Pembatalan - jumlah data | `locator('select').first()` scoped ke halaman riwayat | historis TIDAK STABIL | Native select tanpa label. |
| SCR-BATCH | Batch Order - kartu FTL/FCL/LTL/LCL | `getByRole('button', { name: /FTL|FCL|LTL|LCL/ })` scoped ke halaman batch | historis role+name | Route skipped live 2026-09-14. |
| SCR-BATCH | Batch Order - Download Template Excel | `getByRole('button', { name: 'Download Template Excel' })` | historis role+name | Aksi unduh. |
| SCR-BATCH | Batch Order - Import Batch Order | `getByRole('button', { name: 'Import Batch Order' })` | historis role+name | Aksi tulis/import; jangan diklik saat harvest. |

## Tambahan FCL — Harvest `oms013-order-fcl-auto-stuffing` 2026-09-14

- **Output mentah**: `artifacts/explore-scripts/harvest-selectors-oms013-order-fcl-auto-stuffing.json`
- **Cakupan live**: Daftar Order filter FCL, Daftar Order filter FCL Ditugaskan, Popup Data No. Perjalanan FCL, Detail FCL Ditugaskan, Detail FCL Menunggu Penugasan, Edit FCL Menunggu Penugasan, Buat Order FCL Step 1, Batch Order FCL.
- **Skipped live**: tidak ada.

| SCR | Elemen (nama sesuai ui-inventory) | Selector terbaik | Sumber | Catatan |
|---|---|---|---|---|
| SCR-069 | Filter Jenis Order = FCL | `getByRole('button', { name: 'FCL - Full Container Load' })` | role+name | Setelah opsi dipilih di dropdown `Jenis Order`. |
| SCR-069 | Row FCL by ID Order | `getByRole('button', { name: /^Salin ORD/ })` scoped ke row | role+name | Contoh live FCL: `ORD8338620381`, `ORD8338534214`, `ORD8338374164`, `ORD7556205186`. |
| SCR-069 | Status Ditugaskan filter | `getByRole('button', { name: 'Ditugaskan' })` scoped ke listbox Status | role+name | Untuk membuka list FCL Ditugaskan. |
| SCR-069 | Status Menunggu Penugasan filter | `getByRole('button', { name: 'Menunggu Penugasan' })` scoped ke listbox Status | role+name | Untuk membuka list FCL editable. |
| SCR-070 | Popup Data No. Perjalanan FCL - heading | `getByRole('heading', { name: 'Data No. Perjalanan' })` | role+name | Popup tidak punya root `role="dialog"`. |
| SCR-070 | Popup Data No. Perjalanan FCL - Tutup | `getByRole('button', { name: 'Tutup' })` scoped ke popup | role+name | Live 2026-09-14. |
| SCR-070 | Popup Data No. Perjalanan FCL - Salin nomor | `getByRole('button', { name: 'Salin nomor' })` scoped ke popup | role+name | Bisa lebih dari 1 untuk multi-kontainer. |
| SCR-067 | Detail FCL Ditugaskan - Visualisasi Muatan | `getByRole('button', { name: 'Visualisasi Muatan' })` | role+name | Tampil di Detail Ditugaskan. |
| SCR-067 | Detail FCL Ditugaskan - Batalkan Order | `getByRole('button', { name: 'Batalkan Order' })` | role+name | Membuka modal; jangan submit. |
| SCR-067 | Detail FCL Ditugaskan - No. Perjalanan accordion | `getByRole('button', { name: 'No. Perjalanan' })` | role+name | Section detail; live juga punya tombol `Salin nomor`. |
| SCR-067 | Detail FCL Ditugaskan - Salin nomor perjalanan | `getByRole('button', { name: 'Salin nomor' })` scoped ke accordion No. Perjalanan | role+name | Live 2026-09-14. |
| SCR-066 | Detail FCL Menunggu - Edit Order | `getByRole('button', { name: 'Edit Order' })` | role+name | Tampil pada FCL Menunggu Penugasan; membuka `/order/{uuid}/edit`. |
| SCR-066 | Detail FCL Menunggu - No. Perjalanan empty accordion | `getByRole('button', { name: 'No. Perjalanan' })` | role+name | Section ada walau belum ada nomor perjalanan. |
| SCR-068 | Edit FCL - Hitung Ulang Kontainer | `getByRole('button', { name: 'Hitung Ulang Kontainer' })` | role+name | Pengganti FTL `Hitung Ulang Armada`; jangan klik `Terapkan ke Order`. |
| SCR-068 | Edit FCL - Visualisasi Muatan Saat Ini | `getByRole('button', { name: 'Visualisasi Muatan Saat Ini' })` | role+name | Drawer visualisasi read-only. |
| SCR-068 | Edit FCL - accordion Jenis Pengiriman dan Rute | `getByRole('button', { name: 'Jenis Pengiriman dan Rute' })` | role+name | Live berupa accordion button. |
| SCR-068 | Edit FCL - Jumlah Kontainer | `getByPlaceholder('Masukkan Jumlah Kontainer')` | placeholder | Stabil. |
| SCR-068 | Edit FCL - PIC Pengirim | `getByPlaceholder('Masukkan PIC Pengirim')` | placeholder | Stabil. |
| SCR-068 | Edit FCL - PIC Penerima | `getByPlaceholder('Masukkan PIC Penerima')` | placeholder | Stabil. |
| SCR-068 | Edit FCL - Data Barang Kontainer | `getByRole('button', { name: /^Data Barang - Kontainer/ })` | role+name | Contoh live: `Data Barang - Kontainer 1`. |
| SCR-068 | Edit FCL - Jumlah SKU | `getByRole('textbox', { name: /^Jumlah / })` | role+name | Aria-label dinamis, contoh `Jumlah IK-APT-001`. |
| SCR-068 | Edit FCL - Pilih Barang | `getByRole('button', { name: 'Pilih Barang' })` scoped ke kontainer | role+name | Membuka modal Pilih Barang. |
| SCR-068 | Edit FCL - Vendor dan Harga accordion | `getByRole('button', { name: 'Vendor dan Harga' })` | role+name | Accordion. |
| SCR-068 | Edit FCL - Lihat Detail alamat multi | `getByRole('button', { name: 'Lihat Detail' })` scoped ke ringkasan alamat | role+name | Buka modal detail pengirim/penerima multi; tutup kembali saat harvest. |
| SCR-068 | Edit FCL - Batal | `getByRole('button', { name: 'Batal' })` scoped ke footer | role+name | Memicu dialog batal. |
| SCR-068 | Edit FCL - Simpan | `getByRole('button', { name: 'Simpan', exact: true })` scoped ke footer | role+name | Aksi tulis; jangan diklik saat harvest. |
| SCR-060 | Kartu FCL Step 1 | `getByRole('button', { name: /FCL Full Container Load/ })` | role+name | Live text gabungan tanpa dash. |
| SCR-060 | Pelabuhan Asal | `getByRole('button', { name: 'Pilih Pelabuhan Asal' })` | role+name | Dropdown custom. |
| SCR-060 | Pelabuhan Tujuan | `getByRole('button', { name: 'Pilih Pelabuhan Tujuan' })` | role+name | Dropdown custom. |
| SCR-060 | Jenis Kontainer | `getByRole('button', { name: 'Pilih Jenis Kontainer' })` | role+name | Dropdown custom. |
| SCR-060 | Jumlah Kontainer | `getByPlaceholder('Masukkan Jumlah Kontainer')` | placeholder | Stabil. |
| SCR-060 | Metode Door to Door | `getByRole('button', { name: /Door to Door/ })` | role+name | Card button, bukan radio. |
| SCR-060 | Metode Door to CY | `getByRole('button', { name: /Door to CY/ })` | role+name | Card button, bukan radio. |
| SCR-060 | Metode CY to CY | `getByRole('button', { name: /CY to CY/ })` | role+name | Card button, bukan radio. |
| SCR-060 | Metode CY to Door | `getByRole('button', { name: /CY to Door/ })` | role+name | Card button, bukan radio. |
| SCR-060 | Drop Point Asal | `getByRole('button', { name: 'Pilih Drop Point Asal' })` | role+name | Dropdown custom. |
| SCR-060 | Pengirim | `getByRole('button', { name: 'Semua Pengirim' })` | role+name | Company pengirim. |
| SCR-060 | Drop Point Tujuan | `getByRole('button', { name: 'Pilih Drop Point Tujuan' })` | role+name | Dropdown custom. |
| SCR-060 | Penerima | `getByRole('button', { name: 'Semua Penerima' })` | role+name | Company penerima. |
| SCR-BATCH-FCL | Batch Order - kartu FCL | `getByRole('button', { name: /FCL Full Container Load/ })` | role+name | Live 2026-09-14. |

## Tambahan FTL/FCL Normal — Harvest `oms014-order-ftl-fcl-normal` 2026-09-14

- **Output mentah**: `artifacts/explore-scripts/harvest-selectors-oms014-order-ftl-fcl-normal.json`
- **Cakupan live**: Daftar Order filter FTL, Daftar Order filter FTL Ditugaskan, Popup Data No. Perjalanan FTL, Detail FTL Ditugaskan, Detail FTL Menunggu Penugasan, Edit FTL Menunggu Penugasan, Buat Order FTL Step 1, Batch Order FTL/FCL, Pengaturan Sistem untuk cek toggle Auto Stuffing.
- **Skipped live**: tidak ada.
- **Catatan Auto Stuffing**: `getByRole('switch', { name: 'Auto Stuffing' })` tidak tersedia pada `/setting/sistem` live 2026-09-14. Halaman hanya menampilkan accordion `Durasi Kedaluwarsa Undangan Vendor...`, serta tombol `Batal` dan `Simpan` untuk setting umum. Selector toggle di skenario oms014 harus diperlakukan sebagai blocked/gap environment bila belum ada build yang menyediakan toggle.

| SCR | Elemen (nama sesuai ui-inventory) | Selector terbaik | Sumber | Catatan |
|---|---|---|---|---|
| S-01 | Filter Jenis Order = FTL | `getByRole('button', { name: 'FTL - Full Truck Load' })` | role+name | Setelah opsi dipilih di dropdown `Jenis Order`. |
| S-01 | Row FTL by ID Order | `getByRole('button', { name: /^Salin ORD/ })` scoped ke row | role+name | Contoh live: `ORD8500349516`, `ORD8337312450`, dst. |
| S-01 | Chip Multipickup | `getByRole('button', { name: 'Multipickup' })` scoped ke row | role+name | Muncul pada row FTL multi. |
| S-01 | Chip Multidrop | `getByRole('button', { name: 'Multidrop' })` scoped ke row | role+name | Muncul pada row FTL multi. |
| S-01 | Status Ditugaskan filter | `getByRole('button', { name: 'Ditugaskan' })` scoped ke listbox Status | role+name | Untuk list FTL Ditugaskan. |
| S-01 | Status Menunggu Penugasan filter | `getByRole('button', { name: 'Menunggu Penugasan' })` scoped ke listbox Status | role+name | Untuk list FTL editable. |
| S-10 | Popup Data No. Perjalanan FTL - heading | `getByRole('heading', { name: 'Data No. Perjalanan' })` | role+name | Popup tidak punya root `role="dialog"`. |
| S-10 | Popup Data No. Perjalanan FTL - Tutup | `getByRole('button', { name: 'Tutup' })` scoped ke popup | role+name | Live 2026-09-14. |
| S-10 | Popup Data No. Perjalanan FTL - Salin nomor | `getByRole('button', { name: 'Salin nomor' })` scoped ke popup | role+name | Live 2026-09-14. |
| S-11 | Detail FTL Ditugaskan - Visualisasi Muatan | `getByRole('button', { name: 'Visualisasi Muatan' })` | role+name | Detail tetap punya visualisasi generik. |
| S-11 | Detail FTL Ditugaskan - Batalkan Order | `getByRole('button', { name: 'Batalkan Order' })` | role+name | Membuka modal; jangan submit. |
| S-11 | Detail FTL Ditugaskan - No. Perjalanan accordion | `getByRole('button', { name: 'No. Perjalanan' })` | role+name | Live juga punya tombol `Salin nomor`. |
| S-11 | Detail FTL Ditugaskan - Salin nomor perjalanan | `getByRole('button', { name: 'Salin nomor' })` scoped ke accordion No. Perjalanan | role+name | Live 2026-09-14. |
| S-12 | Detail FTL Menunggu - Edit Order | `getByRole('button', { name: 'Edit Order' })` | role+name | Tampil pada FTL Menunggu Penugasan. |
| S-12 | Detail FTL Menunggu - No. Perjalanan accordion | `getByRole('button', { name: 'No. Perjalanan' })` | role+name | Section ada walau belum ada nomor perjalanan. |
| S-13 | Edit FTL - Hitung Ulang Armada | `getByRole('button', { name: 'Hitung Ulang Armada' })` | role+name | Auto Stuffing live aktif; bertentangan dengan premis AS-OFF oms014. |
| S-13 | Edit FTL - Visualisasi Terbaru | `getByRole('button', { name: 'Visualisasi Terbaru' })` | role+name | Auto Stuffing live aktif. |
| S-13 | Edit FTL - accordion Jenis Pengiriman dan Rute | `getByRole('button', { name: 'Jenis Pengiriman dan Rute' })` | role+name | Edit Order. |
| S-13 | Edit FTL - Jumlah Armada | `getByPlaceholder('Masukkan Jumlah Armada')` | placeholder | Stabil. |
| S-13 | Edit FTL - PIC Pengirim | `getByPlaceholder('Masukkan PIC Pengirim')` | placeholder | Stabil. |
| S-13 | Edit FTL - PIC Penerima | `getByPlaceholder('Masukkan PIC Penerima')` | placeholder | Stabil. |
| S-13 | Edit FTL - Data Barang Armada | `getByRole('button', { name: /^Data Barang - Armada/ })` | role+name | Contoh live: `Data Barang - Armada 1`. |
| S-13 | Edit FTL - Jumlah SKU | `getByRole('textbox', { name: /^Jumlah / })` | role+name | Aria-label dinamis, contoh `Jumlah IK-APT-001`. |
| S-13 | Edit FTL - Pilih Barang | `getByRole('button', { name: 'Pilih Barang' })` scoped ke armada | role+name | Membuka modal Pilih Barang. |
| S-13 | Edit FTL - Vendor dan Harga accordion | `getByRole('button', { name: 'Vendor dan Harga' })` | role+name | Accordion. |
| S-13 | Edit FTL - Batal | `getByRole('button', { name: 'Batal' })` scoped ke footer | role+name | Memicu dialog batal. |
| S-13 | Edit FTL - Simpan | `getByRole('button', { name: 'Simpan', exact: true })` scoped ke footer | role+name | Aksi tulis; jangan diklik saat harvest. |
| S-03 | Kartu FTL Step 1 | `getByRole('button', { name: /FTL Full Truck Load/ })` | role+name | Live text gabungan tanpa dash. |
| S-03 | Kartu FCL Step 1 | `getByRole('button', { name: /FCL Full Container Load/ })` | role+name | Ada di wizard yang sama. |
| S-03 | Jenis Armada | `getByRole('button', { name: 'Pilih Jenis Armada' })` | role+name | Step 1 FTL. |
| S-03 | Jumlah Armada | `getByPlaceholder('Masukkan Jumlah Armada')` | placeholder | Stabil. |
| S-03 | Drop Point Asal | `getByRole('button', { name: 'Pilih Drop Point Asal' })` | role+name | Dropdown custom. |
| S-03 | Pengirim | `getByRole('button', { name: 'Semua Pengirim' })` | role+name | Company pengirim. |
| S-03 | Drop Point Tujuan | `getByRole('button', { name: 'Pilih Drop Point Tujuan' })` | role+name | Dropdown custom. |
| S-03 | Penerima | `getByRole('button', { name: 'Semua Penerima' })` | role+name | Company penerima. |
| S-BATCH | Batch Order - kartu FTL | `getByRole('button', { name: /FTL Full Truck Load/ })` | role+name | Live 2026-09-14. |
| S-BATCH | Batch Order - kartu FCL | `getByRole('button', { name: /FCL Full Container Load/ })` | role+name | Live 2026-09-14. |
| S-AS-OFF | Toggle Auto Stuffing | `getByRole('switch', { name: 'Auto Stuffing' })` | SKIPPED | Tidak ada di `/setting/sistem` live 2026-09-14; skenario toggle perlu environment/build yang sesuai. |
| S-AS-OFF | Pengaturan Sistem - accordion Durasi Kedaluwarsa Undangan Vendor | `getByRole('button', { name: /Durasi Kedaluwarsa Undangan Vendor/ })` | role+name | Accordion setting yang terlihat saat cek toggle. |
| S-AS-OFF | Pengaturan Sistem - Batal | `getByRole('button', { name: 'Batal' })` | role+name | Jangan dipakai untuk mengubah setting. |
| S-AS-OFF | Pengaturan Sistem - Simpan | `getByRole('button', { name: 'Simpan' })` | role+name | Aksi tulis; jangan diklik saat harvest. |

## Tambahan LTL/LCL — Harvest `oms015-order-ltl-lcl-universal` 2026-09-14

- **Output mentah**: `artifacts/explore-scripts/harvest-selectors-oms015-order-ltl-lcl-universal.json`
- **Cakupan live**: Daftar Order filter LTL/LCL, Daftar Order filter LTL/LCL Ditugaskan, Popup Data No. Resi LTL/LCL, Detail LTL/LCL Ditugaskan, Detail LTL/LCL Menunggu Penugasan, Buat Order Step 1 LTL/LCL, Batch Order LTL/LCL, Riwayat Pembatalan.
- **Skipped live**: tidak ada.
- **Catatan No. Resi**: LTL/LCL memakai action `Lihat No. Resi`, bukan `Lihat No. Perjalanan`. Popup dan Detail punya tombol `Salin nomor`; tabel resi punya tombol sort `Urutkan berdasarkan Nama Barang`.

| SCR | Elemen (nama sesuai ui-inventory) | Selector terbaik | Sumber | Catatan |
|---|---|---|---|---|
| LTL-LIST | Filter Jenis Order = LTL | `getByRole('button', { name: 'LTL - Less Than Truck Load' })` | role+name | Setelah opsi dipilih di dropdown `Jenis Order`. |
| LTL-LIST | Row LTL by ID Order | `getByRole('button', { name: /^Salin ORD/ })` scoped ke row | role+name | Contoh live: `ORD8337730685`, `ORD7886177064`. |
| LTL-LIST | Status Ditugaskan filter | `getByRole('button', { name: 'Ditugaskan' })` scoped ke listbox Status | role+name | Untuk list LTL Ditugaskan. |
| LTL-LIST | Status Menunggu Penugasan filter | `getByRole('button', { name: 'Menunggu Penugasan' })` scoped ke listbox Status | role+name | Untuk list LTL editable. |
| LTL-RESI | Menu item Lihat No. Resi | `getByRole('button', { name: 'Lihat No. Resi' })` scoped ke menu aksi | role+name | Muncul pada LTL/LCL, bukan FTL/FCL. |
| LTL-RESI | Popup Data No. Resi LTL - heading | `getByRole('heading', { name: 'Data No. Resi' })` | role+name | Popup tanpa root `role="dialog"`. |
| LTL-RESI | Popup Data No. Resi LTL - Tutup | `getByRole('button', { name: 'Tutup' })` scoped ke popup | role+name | Live 2026-09-14. |
| LTL-RESI | Popup Data No. Resi LTL - sort Nama Barang | `getByRole('button', { name: 'Urutkan berdasarkan Nama Barang' })` | role+name | Aria-label live; text tombol `Nama Barang`. |
| LTL-RESI | Popup Data No. Resi LTL - Salin nomor | `getByRole('button', { name: 'Salin nomor' })` scoped ke popup | role+name | Bisa lebih dari 1 jika banyak SKU. |
| LTL-DETAIL-DITUGASKAN | Detail LTL Ditugaskan - Batalkan Order | `getByRole('button', { name: 'Batalkan Order' })` | role+name | Membuka modal; jangan submit. |
| LTL-DETAIL-DITUGASKAN | Detail LTL Ditugaskan - No. Resi accordion | `getByRole('button', { name: 'No. Resi' })` | role+name | Section detail. |
| LTL-DETAIL-DITUGASKAN | Detail LTL Ditugaskan - sort Nama Barang | `getByRole('button', { name: 'Urutkan berdasarkan Nama Barang' })` scoped ke accordion No. Resi | role+name | Live 2026-09-14. |
| LTL-DETAIL-DITUGASKAN | Detail LTL Ditugaskan - Salin nomor resi | `getByRole('button', { name: 'Salin nomor' })` scoped ke accordion No. Resi | role+name | Live 2026-09-14. |
| LTL-DETAIL-MENUNGGU | Detail LTL Menunggu - No. Resi accordion | `getByRole('button', { name: 'No. Resi' })` | role+name | Section ada pada status Menunggu Penugasan. |
| LCL-LIST | Filter Jenis Order = LCL | `getByRole('button', { name: 'LCL - Less Than Container Load' })` | role+name | Setelah opsi dipilih di dropdown `Jenis Order`. |
| LCL-LIST | Row LCL by ID Order | `getByRole('button', { name: /^Salin ORD/ })` scoped ke row | role+name | Contoh live: `ORD8416187200`, `ORD8338814778`. |
| LCL-LIST | Status Ditugaskan filter | `getByRole('button', { name: 'Ditugaskan' })` scoped ke listbox Status | role+name | Untuk list LCL Ditugaskan. |
| LCL-LIST | Status Menunggu Penugasan filter | `getByRole('button', { name: 'Menunggu Penugasan' })` scoped ke listbox Status | role+name | Untuk list LCL editable. |
| LCL-RESI | Popup Data No. Resi LCL - heading | `getByRole('heading', { name: 'Data No. Resi' })` | role+name | Popup tanpa root `role="dialog"`. |
| LCL-RESI | Popup Data No. Resi LCL - Tutup | `getByRole('button', { name: 'Tutup' })` scoped ke popup | role+name | Live 2026-09-14. |
| LCL-RESI | Popup Data No. Resi LCL - sort Nama Barang | `getByRole('button', { name: 'Urutkan berdasarkan Nama Barang' })` | role+name | Sama dengan LTL. |
| LCL-RESI | Popup Data No. Resi LCL - Salin nomor | `getByRole('button', { name: 'Salin nomor' })` scoped ke popup | role+name | Live 2026-09-14. |
| LCL-DETAIL-DITUGASKAN | Detail LCL Ditugaskan - Batalkan Order | `getByRole('button', { name: 'Batalkan Order' })` | role+name | Membuka modal; jangan submit. |
| LCL-DETAIL-DITUGASKAN | Detail LCL Ditugaskan - No. Resi accordion | `getByRole('button', { name: 'No. Resi' })` | role+name | Section detail. |
| LCL-DETAIL-DITUGASKAN | Detail LCL Ditugaskan - sort Nama Barang | `getByRole('button', { name: 'Urutkan berdasarkan Nama Barang' })` scoped ke accordion No. Resi | role+name | Live 2026-09-14. |
| LCL-DETAIL-DITUGASKAN | Detail LCL Ditugaskan - Salin nomor resi | `getByRole('button', { name: 'Salin nomor' })` scoped ke accordion No. Resi | role+name | Live 2026-09-14. |
| LCL-DETAIL-MENUNGGU | Detail LCL Menunggu - No. Resi accordion | `getByRole('button', { name: 'No. Resi' })` | role+name | Section ada pada status Menunggu Penugasan. |
| LTL-STEP1 | Kartu LTL Step 1 | `getByRole('button', { name: /LTL Less Than Truck Load/ })` | role+name | Live text gabungan tanpa dash. |
| LTL-STEP1 | Kota Asal | `getByRole('button', { name: 'Pilih Kota Asal' })` | role+name | Dropdown custom khusus LTL. |
| LTL-STEP1 | Kota Tujuan | `getByRole('button', { name: 'Pilih Kota Tujuan' })` | role+name | Dropdown custom khusus LTL. |
| LTL-STEP1 | Drop Point Asal | `getByRole('button', { name: 'Pilih Drop Point Asal' })` | role+name | Dropdown custom. |
| LTL-STEP1 | Pengirim | `getByRole('button', { name: 'Semua Pengirim' })` | role+name | Company auto/selected. |
| LTL-STEP1 | PIC Pengirim | `getByPlaceholder('Masukkan PIC Pengirim')` | placeholder | Stabil. |
| LTL-STEP1 | No. WhatsApp PIC | `getByPlaceholder('Masukkan No. WhatsApp PIC')` scoped ke Data Pengirim/Penerima | placeholder (tidak unik) | Ada pada pengirim dan penerima. |
| LTL-STEP1 | Kota/Kab. Asal readonly | `getByPlaceholder('Kota/Kab. Asal')` | placeholder | Disabled live. |
| LTL-STEP1 | Drop Point Tujuan | `getByRole('button', { name: 'Pilih Drop Point Tujuan' })` | role+name | Dropdown custom. |
| LTL-STEP1 | Penerima | `getByRole('button', { name: 'Semua Penerima' })` | role+name | Company auto/selected. |
| LTL-STEP1 | PIC Penerima | `getByPlaceholder('Masukkan PIC Penerima')` | placeholder | Stabil. |
| LTL-STEP1 | Kota/Kab. Tujuan readonly | `getByPlaceholder('Kota/Kab. Tujuan')` | placeholder | Disabled live. |
| LCL-STEP1 | Kartu LCL Step 1 | `getByRole('button', { name: /LCL Less Than Container Load/ })` | role+name | Live text gabungan tanpa dash. |
| LCL-STEP1 | Pelabuhan Asal | `getByRole('button', { name: 'Pilih Pelabuhan Asal' })` | role+name | Dropdown custom khusus LCL. |
| LCL-STEP1 | Pelabuhan Tujuan | `getByRole('button', { name: 'Pilih Pelabuhan Tujuan' })` | role+name | Dropdown custom khusus LCL. |
| LCL-STEP1 | Metode Door to Door | `getByRole('button', { name: /Door to Door/ })` | role+name | Card button, bukan radio. |
| LCL-STEP1 | Metode Door to CY | `getByRole('button', { name: /Door to CY/ })` | role+name | Card button, bukan radio. |
| LCL-STEP1 | Metode CY to CY | `getByRole('button', { name: /CY to CY/ })` | role+name | Card button, bukan radio. |
| LCL-STEP1 | Metode CY to Door | `getByRole('button', { name: /CY to Door/ })` | role+name | Card button, bukan radio. |
| LCL-STEP1 | Drop Point Asal | `getByRole('button', { name: 'Pilih Drop Point Asal' })` | role+name | Dropdown custom. |
| LCL-STEP1 | Pengirim | `getByRole('button', { name: 'Semua Pengirim' })` | role+name | Company auto/selected. |
| LCL-STEP1 | Drop Point Tujuan | `getByRole('button', { name: 'Pilih Drop Point Tujuan' })` | role+name | Dropdown custom. |
| LCL-STEP1 | Penerima | `getByRole('button', { name: 'Semua Penerima' })` | role+name | Company auto/selected. |
| LTL-LCL-BATCH | Batch Order - kartu LTL | `getByRole('button', { name: /LTL Less Than Truckload/ })` | role+name | Live batch memakai `Truckload` satu kata. |
| LTL-LCL-BATCH | Batch Order - kartu LCL | `getByRole('button', { name: /LCL Less Than Container Load/ })` | role+name | Live 2026-09-14. |
| LTL-LCL-CANCEL-HISTORY | Riwayat Pembatalan - row by ID Order | `getByRole('button', { name: /^Salin ORD/ })` scoped ke row | role+name | Contoh live LTL/LCL dibatalkan: `ORD8331533103`, `ORD8331456722`. |
| LTL-LCL-CANCEL-HISTORY | Riwayat Pembatalan - chip Multipickup | `getByRole('button', { name: 'Multipickup' })` scoped ke row | role+name | Jika row multi muncul. |

## Layar Skipped pada Harvest Live 2026-09-14

| SCR | Layar | Alasan |
|---|---|---|
| SCR-23 | Edit Order | Tidak ada menu `Edit` yang berhasil dibuka dari halaman pertama pada run live. |
| SCR-22 | Modal Batalkan Order | Tidak ada menu `Batalkan Order` yang berhasil dibuka dari halaman pertama pada run live. |
| SCR-24 | Popup Data No. Perjalanan | Tidak ada menu `Lihat No. Perjalanan` yang berhasil dibuka dari halaman pertama pada run live. |
| SCR-04/05/06/07/08 | Buat Order Step 1 | Route `/order/buat` redirect ke `/login?next=%2Forder%2Fbuat` setelah navigasi detail. |
| SCR-BATCH | Batch Order | Route `/order/batch` redirect ke `/login?next=%2Forder%2Fbatch` setelah navigasi detail. |
| SCR-25 | Riwayat Pembatalan | Route `/order/riwayat-pembatalan` redirect ke `/login?next=%2Forder%2Friwayat-pembatalan` setelah navigasi detail. |

## Rekomendasi data-testid untuk developer

- `header-notification` — tombol bell notifikasi saat ini tanpa nama aksesibel.
- `order-action-menu` — tombol/menu aksi baris agar item bisa di-scope ke row tanpa index rapuh.
- `order-filter-page-size` — native select jumlah data tanpa label.
- `order-filter-kota-asal` / `order-filter-kota-tujuan` — dua dropdown sama-sama bernama `Semua Kota`.
- `order-filter-drop-point-asal` / `order-filter-drop-point-tujuan` — dua dropdown sama-sama bernama `Semua Drop Point`.
- `order-modal-visualisasi-muatan` — root popup visualisasi; tambahkan juga `role="dialog"` dan label aksesibel.
- `order-modal-batalkan-order` — root modal pembatalan; `#cancelReason` sudah stabil tetapi root modal belum.
- `order-modal-pilih-barang` — root modal pilih barang; tambahkan `role="dialog"` dan label aksesibel.
- `order-wizard-next` / `order-wizard-save-draft` / `order-wizard-cancel` — tombol footer wizard yang namanya bentrok dengan tombol lain di modal/drawer.
- `order-edit-save` / `order-edit-cancel` — tombol footer edit order.
- `order-batch-import` / `order-batch-download-template` — aksi batch order.

## Ringkasan Harvest 2026-09-14

- Harvest `oms012-order-ftl-auto-stuffing`: **3** layar berhasil, **6** skipped, **182** elemen mentah.
- Harvest `oms013-order-fcl-auto-stuffing`: **8** layar berhasil, **0** skipped, **485** elemen mentah.
- Harvest `oms014-order-ftl-fcl-normal`: **9** layar berhasil, **0** skipped, **557** elemen mentah.
- Harvest `oms015-order-ltl-lcl-universal`: **14** layar berhasil, **0** skipped, **794** elemen mentah.
- Total layar berhasil dipetakan live hari ini: **34**.
- Total layar skipped live hari ini: **6**.
- Total elemen mentah dari query workflow hari ini: **2018**.
- Selector di tabel final: **249**.
- Selector stabil (`data-testid`, id stabil, role/name, placeholder, atau historis role/name/placeholder): **240**.
- Selector tidak stabil/perlu scoping khusus / skipped selector: **9**.
