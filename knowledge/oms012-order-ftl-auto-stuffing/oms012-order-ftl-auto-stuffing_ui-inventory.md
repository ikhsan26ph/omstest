# UI Inventory (draft terpisah) — oms012-order-ftl-auto-stuffing

> File ini adalah salinan kerja section **## UI Inventory** untuk disisipkan ke
> `output/oms012-order-ftl-auto-stuffing/oms012-order-ftl-auto-stuffing.analysis.md`.
> Sumber: 46 PNG di `inputs/oms012-order-ftl-auto-stuffing/designs/` (016.png – 057a.png), dibaca via vision 2026-08-18.

## UI Inventory

> **Konvensi selector**: prioritas `getByRole(role, { name })` → `getByLabel` → `getByText` → `getByTestId`.
> Nilai `data-testid` bersifat **usulan** (belum tentu ada di implementasi) — lihat **ASM-D01**.
> Aplikasi: OMS tenant "Mentari Sumber Kertas", role bar `Shipper / Staff Operasional`, user `Andika (andikamsk@gmail.com)`.
> Total: **39 layar/state logis**, **±250 elemen**, dari **46 file desain**.

### Indeks Layar → File Desain

| # | Layar / State | File PNG | REQ terkait |
|---|---|---|---|
| SCR-00 | Shell global (sidebar, header, breadcrumb, kuota) | semua | — |
| SCR-01 | Daftar Order (list default) | 016, 036, 050 | REQ-054, REQ-066–069 |
| SCR-02 | Daftar Order — panel Filter terbuka | 017, 034 | REQ-069 |
| SCR-03 | Action menu per baris (3 varian status) | 017, 034 | REQ-066–068, REQ-073 |
| SCR-04 | Buat Order Step 1 — pilih Jenis Pengiriman (state awal, Selanjutnya disabled) | 018 | REQ-002, REQ-007 |
| SCR-05 | Step 1 — Tipe Pengiriman **Normal** (form penuh) | 019 | REQ-007–010 |
| SCR-06 | Step 1 — **Multipickup** (Pick Up 1–3) | 037 | REQ-009 |
| SCR-07 | Step 1 — **Multidrop** (Drop Off 1–2) | 044 | REQ-009 |
| SCR-08 | Step 1 — **Multipoint** (Pick Up 1–3 + Drop Off 1–2) | 051 | REQ-009 |
| SCR-09 | Step 2 Data Barang — Normal, FAB ikon saja | 020 | REQ-011–028 |
| SCR-10 | Step 2 — FAB hover (label tampil) | 021 | REQ-027, REQ-028 |
| SCR-11 | Modal **Pilih Barang** | 022 | REQ-011–016 |
| SCR-12 | Drawer **Hitung Ulang Armada** (normal) | 023 | REQ-033–041 |
| SCR-13 | Drawer Hitung Ulang Armada — badge over-kapasitas | 024 | REQ-038 |
| SCR-14 | Panel **Visualisasi Muatan Saat Ini** (Visualisasi Terbaru) | 025 | REQ-042 |
| SCR-15 | Step 3 Vendor dan Harga — kosong, rute belum ada | 026 | REQ-043, REQ-044, REQ-046 |
| SCR-16 | Step 3 — terisi + komponen harga + Asuransi | 027 | REQ-046, REQ-047 |
| SCR-17 | Step 3 — terisi tanpa asuransi | 028 | REQ-047 |
| SCR-18 | Step 4 Review — Normal | 029 | REQ-049–053 |
| SCR-19 | Pop up konfirmasi **Simpan Draf** | 030 | REQ-057 |
| SCR-20 | Detail Order — Normal | 031 | REQ-076 |
| SCR-21 | Pop up **Visualisasi Muatan** (dari Review/Detail) | 031a | REQ-006, REQ-052 |
| SCR-22 | Pop up **Batalkan Order** | 032 | REQ-063–065 |
| SCR-23 | Edit Order — Normal | 033 | REQ-058–062 |
| SCR-24 | Pop up **Data No. Perjalanan** | 035 | REQ-074, REQ-075 |
| SCR-25 | Step 2 — Multipickup (grup Pick Up per armada) | 038 | REQ-031 |
| SCR-26 | Step 3 — Multipickup (`Lihat Detail`) | 039 | REQ-045 |
| SCR-27 | Pop up **Detail Multipickup** | 040, 054 | REQ-045 |
| SCR-28 | Step 4 Review — Multipickup | 041, 042 | REQ-050, REQ-051 |
| SCR-29 | Edit Order — Multipickup | 043 | REQ-061 |
| SCR-30 | Detail Order — Multipickup | 043a | REQ-076 |
| SCR-31 | Step 2 — Multidrop (grup Drop Off per armada) | 045 | REQ-031 |
| SCR-32 | Step 3 — Multidrop | 046 | REQ-045 |
| SCR-33 | Pop up **Detail Multidrop** | 047, 055 | REQ-045 |
| SCR-34 | Step 4 Review — Multidrop | 047a | REQ-050 |
| SCR-35 | Detail Order — Multidrop | 048 | REQ-076 |
| SCR-36 | Edit Order — Multidrop | 049 | REQ-061 |
| SCR-37 | Step 2 — Multipoint (pasangan Pick Up × Drop Off) | 052 | REQ-031 |
| SCR-38 | Step 3 — Multipoint (2 × `Lihat Detail`) | 053 | REQ-045 |
| SCR-39 | Step 4 Review (056) & Edit (057) & Detail (057a) — Multipoint | 056, 057, 057a | REQ-050, REQ-061 |

### SCR-00 — Shell Global

| Elemen | Tipe | Label / Teks | State | Selector Playwright |
|---|---|---|---|---|
| Toggle sidebar | icon button | (hamburger) | enabled | `getByTestId('sidebar-toggle')` |
| Menu sidebar | link list | Dashboard ⌄, Order, Penugasan Tracking, Simulasi Muatan, Master Wilayah ⌄, Master Operasional ⌄, Manajemen Vendor, Pengaturan Akun, Akun Saya, Pengaturan Sistem, Pusat Notifikasi ⌄ | `Order` active pada 016–035 | `getByRole('link', { name: 'Order' })` |
| Notifikasi | icon button + dot | (bell, badge merah) | ada notifikasi baru | `getByTestId('header-notification')` |
| Profil user | text block | `Andika` / `andikamsk@gmail.com` | read-only | `getByText('andikamsk@gmail.com')` |
| Logout | icon button | (logout) | enabled | `getByTestId('header-logout')` |
| Kuota Order | progress + text | `Kuota Order`, `120/300`, `40%` | read-only | `getByTestId('order-quota-progress')` |
| Versi aplikasi | text | `Order Management System Versi 1.0.0` | read-only | `getByText('Versi 1.0.0')` |
| Breadcrumb | nav links | `Beranda > Daftar Order > Buat Order` | link aktif = terakhir non-link | `getByRole('link', { name: 'Daftar Order' })` |

### SCR-01 — Daftar Order (016, 036, 050)

| Elemen | Tipe | Label / Teks | State | Selector Playwright |
|---|---|---|---|---|
| Judul | heading | `Daftar Order` | — | `getByRole('heading', { name: 'Daftar Order' })` |
| Buat Order | button (primary, + icon) | `Buat Order` | enabled | `getByRole('button', { name: 'Buat Order' })` |
| Batch Order | button (outline) | `Batch Order` | enabled | `getByRole('button', { name: 'Batch Order' })` |
| Riwayat Pembatalan | button (outline) | `Riwayat Pembatalan` | enabled | `getByRole('button', { name: 'Riwayat Pembatalan' })` |
| Filter | button (outline) | `Filter` | toggle panel | `getByRole('button', { name: 'Filter' })` |
| Jumlah data | dropdown | `Tampilkan [20] data` | default 20 | `getByRole('combobox', { name: /Tampilkan/ })` |
| Tabel order | table | header: `ID Order`/`Vendor`, `Kota Asal`/`Warehouse Asal`, `Kota Tujuan`/`Warehouse Tujuan`, `Total Harga ⇅`/`Status` | `Total Harga` sortable | `getByRole('table')` |
| Chip jenis order | badge | `FCL`, `FTL`, `LTL`, `LCL` | read-only | `getByRole('row', { name: /ORD789871FSF7/ }).getByText('FTL')` |
| Badge status | badge | `Isi Data Dasar`, `Isi Data Muatan`, `Isi Data Vendor`, `Review Order`, `Menunggu Penugasan`, `Ditugaskan`, `Proses Pengiriman`, `Terkirim`, `Dibatalkan` | read-only | `getByTestId('order-row-status')` |
| Aksi baris | icon button `...` | (kebab) | enabled | `getByRole('row', { name: /ORD.../ }).getByRole('button', { name: 'Aksi' })` |
| Info paginasi | text | `Menampilkan 1 - 20 data dari 30 data` | read-only | `getByText(/Menampilkan \d+ - \d+ data dari/)` |
| Paginasi | nav buttons | `«`, `‹`, `1 2 3 … 12`, `›`, `»` | halaman 1 aktif | `getByRole('button', { name: '2' })` |

### SCR-02 — Panel Filter Daftar Order (017, 034)

| Elemen | Tipe | Label | Placeholder | State | Selector |
|---|---|---|---|---|---|
| ID Order | text | `ID Order` | `Masukkan ID Order` | enabled | `getByLabel('ID Order')` |
| Jenis Order | dropdown | `Jenis Order` | `Pilih Jenis Order` | enabled | `getByLabel('Jenis Order')` |
| Vendor | text | `Vendor` | `Masukkan Vendor` | enabled | `getByLabel('Vendor')` |
| Kota Asal | dropdown | `Kota Asal` | `Pilih Kota Asal` | enabled | `getByLabel('Kota Asal')` |
| Kota Tujuan | dropdown | `Kota Tujuan` | `Pilih Kota Tujuan` | enabled | `getByLabel('Kota Tujuan')` |
| Total Harga | text | `Total Harga` | `Masukkan Total Harga` | enabled | `getByLabel('Total Harga')` |
| Tipe Pengiriman | dropdown | `Tipe Pengiriman` | `Pilih Tipe Pengiriman` | **tampak disabled** (teks abu muda) — ASM-D03. **RESOLVED 2026-08-22** (harvest + run SCN-0133): live **enabled penuh**, dikonfirmasi 2x independen. Tidak ada REQ yang mewajibkan disabled — styling-only, bukan bug. | `getByLabel('Tipe Pengiriman')` |
| Metode Pengiriman | dropdown | `Metode Pengiriman` | `Pilih Metode Pengiriman` | **tampak disabled** — ASM-D03. Field ini **tidak ada di live** sama sekali (lihat selector-map.md) — belum terverifikasi ulang. | `getByLabel('Metode Pengiriman')` |
| Drop Point Asal | dropdown | `Drop Point Asal` | `Pilih Drop Point Asal` | enabled | `getByLabel('Drop Point Asal')` |
| Drop Point Tujuan | dropdown | `Drop Point Tujuan` | `Pilih Drop Point Tujuan` | enabled | `getByLabel('Drop Point Tujuan')` |
| Status | dropdown | `Status` | `Pilih Status` | enabled | `getByLabel('Status')` |
| Reset | button (danger outline) | `Reset` | — | enabled | `getByRole('button', { name: 'Reset' })` |
| Terapkan | button (primary) | `Terapkan` | — | enabled | `getByRole('button', { name: 'Terapkan' })` |

### SCR-03 — Action Menu per Status

| Konteks status | Item menu terlihat | File | Catatan vs REQ |
|---|---|---|---|
| Draft (Isi Data Dasar/Muatan/Vendor, Review Order) | `Detail`, `Lanjutkan Pengisian`, `Batalkan Order`, `Riwayat Perubahan` | 017 | sesuai REQ-066 |
| `Menunggu Penugasan` | `Detail`, `Edit`, `Batalkan Order`, `Riwayat Perubahan` | 017 | sesuai REQ-067 |
| `Ditugaskan` | `Detail`, `Lihat No. Perjalanan`, **`Order Kembali`**, `Batalkan Order`, `Riwayat Perubahan` | 034 | **`Order Kembali` tidak ada di REQ-068** → FND-01 |

Selector item: `getByRole('menuitem', { name: 'Lihat No. Perjalanan' })` atau `getByTestId('order-action-lihat-no-perjalanan')`.

### SCR-04 / SCR-05 — Buat Order Step 1 (018, 019)

| Elemen | Tipe | Label / Teks | State | Selector |
|---|---|---|---|---|
| Stepper | progress steps | `01 Data Pengiriman`, `02 Data Barang`, `03 Vendor dan Harga`, `04 Review` | step aktif = 01 | `getByTestId('order-wizard-step-1')` |
| Kartu jenis pengiriman | radio card ×4 | `FTL Full Truck Load`, `FCL Full Container Load`, `LTL Less Than Truck Load`, `LCL Less Than Container Load` | FTL checked | `getByRole('radio', { name: /FTL/ })` |
| Jenis Armada | dropdown, wajib | `Jenis Armada *` (nilai `Tronton Box`) | enabled | `getByLabel('Jenis Armada')` |
| Jumlah Armada | number input, wajib | `Jumlah Armada *` (nilai `2`) | enabled, **bukan stepper** | `getByLabel('Jumlah Armada')` |
| Tipe Pengiriman | dropdown, wajib | `Tipe Pengiriman *` / `Pilih Tipe Pengiriman` | enabled | `getByLabel('Tipe Pengiriman')` |
| Selanjutnya (018) | button | `Selanjutnya →` | **disabled** (abu) saat Tipe Pengiriman kosong | `getByRole('button', { name: 'Selanjutnya' })` |
| Drop Point Asal / Tujuan | dropdown, wajib | `Drop Point Asal *` / `Drop Point Tujuan *` | enabled | `getByLabel('Drop Point Asal')` |
| Pengirim / Penerima | dropdown, wajib | `Pengirim *` / `Penerima *` | enabled | `getByLabel('Pengirim')` |
| PIC Pengirim / Penerima | text, wajib | `PIC Pengirim *`, helper `Nama PIC Pengirim` | enabled | `getByLabel('PIC Pengirim')` |
| No. WhatsApp PIC | text, wajib | `No. WhatsApp PIC *`, helper `Contoh: 081234567898` | enabled | `getByLabel('No. WhatsApp PIC').first()` |
| Provinsi / Kota-Kab / Kecamatan / Desa-Kelurahan / Kode Pos | text | `Provinsi Asal`, `Kota/Kab. Asal`, `Kecamatan Asal`, `Desa/Kelurahan Asal`, `Kode Pos` | **read-only** (auto-draft Master Droppoint) | `getByLabel('Provinsi Asal')` |
| Alamat Asal / Tujuan | textarea | `Alamat Asal` | **read-only** | `getByLabel('Alamat Asal')` |
| Catatan | textarea | `Catatan` / `Masukkan Catatan` | enabled, opsional | `getByLabel('Catatan').first()` |
| Footer | buttons | `Batal`, `Simpan ke Draf`, `Selanjutnya →` | enabled (019) | `getByRole('button', { name: 'Simpan ke Draf' })` |

### SCR-06 / SCR-07 / SCR-08 — Step 1 varian multi (037, 044, 051)

| Elemen | Tipe | Label | State | Selector |
|---|---|---|---|---|
| Grup pengirim | card berulang | `Pick Up 1`, `Pick Up 2`, `Pick Up 3` | Multipickup & Multipoint | `getByRole('region', { name: 'Pick Up 2' })` |
| Grup penerima | card berulang | `Drop Off 1`, `Drop Off 2` | Multidrop & Multipoint | `getByRole('region', { name: 'Drop Off 2' })` |
| Hapus baris | icon button (trash merah) | — | **tidak ada pada baris ke-1**, ada pada baris ≥2 | `getByRole('region', { name: 'Pick Up 2' }).getByRole('button', { name: 'Hapus' })` |
| Tambah baris | text button | `+ Tambah Baris Input` | enabled; 1× pada Multipickup/Multidrop, 2× pada Multipoint | `getByRole('button', { name: 'Tambah Baris Input' })` |
| Nomor WhatsApp PIC (varian multi) | text | `Nomor WhatsApp PIC *` | label berbeda dari Normal (`No. WhatsApp PIC`) → FND-06 | `getByLabel('Nomor WhatsApp PIC').first()` |
| Kota/Kab. Pengirim Asal | text | `Kota/Kab. Pengirim Asal` | read-only (khusus Multipickup) | `getByLabel('Kota/Kab. Pengirim Asal').first()` |

### SCR-09 / SCR-10 — Step 2 Data Barang, tipe Normal (020, 021)

| Elemen | Tipe | Label / Teks | State | Selector |
|---|---|---|---|---|
| Data Unit | info card | `Data Unit` → `Jenis Armada: Tronton Box`, `Jumlah Armada: 2` | read-only | `getByTestId('step2-data-unit')` |
| Card armada | section berulang | `Armada 1`, `Armada 2`, `Armada 3` | **3 card padahal Jumlah Armada = 2** → FND-02 | `getByRole('region', { name: 'Armada 1' })` |
| Tambahkan Asuransi | checkbox | `Tambahkan Asuransi` + helper `Berlaku untuk seluruh barang pada armada ini` | Armada 1 checked; Armada 2 & 3 unchecked | `getByRole('region', { name: 'Armada 1' }).getByRole('checkbox', { name: 'Tambahkan Asuransi' })` |
| Nomor DO | chips input | `Nomor DO`, chip `TGK783898202U ×`, `TBL28371302 ×`, placeholder `Masukkan Nomor DO`, helper `Pisahkan dengan koma untuk menambahkan beberapa nomor` | opsional | `getByLabel('Nomor DO').first()` |
| Hapus chip DO | icon `×` di chip | — | enabled | `getByRole('button', { name: 'Hapus TGK783898202U' })` |
| Tabel barang | table | kolom: `Kode SKU`/`Nama Barang`, `Kemasan`, `Kubikasi`/`Dimensi`, `Berat`, `Jumlah`, `Nilai Barang` | kolom `Nilai Barang` **hanya** saat asuransi aktif | `getByRole('region', { name: 'Armada 1' }).getByRole('table')` |
| Kode SKU / Nama / Kemasan / Kubikasi / Dimensi / Berat | text sel | `SKU-PPR-001` / `Kertas HVS A4 80 gsm` / `Dus` / `0,018 m³` / `31 × 22 × 26,4 cm` / `12,5 kg` | **read-only** | `getByRole('cell', { name: 'SKU-PPR-001' })` |
| Jumlah | number input | (tanpa label visual, header kolom `Jumlah`) nilai `200` / `0` | wajib; **error state** bila `0`/kosong | `getByRole('row', { name: /SKU-PPR-001/ }).getByRole('spinbutton')` |
| Nilai Barang | currency input | prefix `Rp`, nilai `0` / `1.320.000` | wajib bila asuransi aktif; **error state** | `getByRole('row', { name: /SKU-PPR-001/ }).getByTestId('input-nilai-barang')` |
| Hapus baris barang | icon button (trash merah) | — | enabled | `getByRole('row', { name: /SKU-BKU-001/ }).getByRole('button', { name: 'Hapus' })` |
| Pilih Barang | button (outline, + icon) | `Pilih Barang` | enabled (juga pada armada kosong) | `getByRole('region', { name: 'Armada 3' }).getByRole('button', { name: 'Pilih Barang' })` |
| Alert kapasitas | inline badge merah | `Kubikasi melebihi kapasitas armada` (Armada 1) / `Berat melebihi kapasitas armada` (Armada 2) | informatif, tidak memblokir | `getByText('Kubikasi melebihi kapasitas armada')` |
| Total kubikasi/berat | text | `Total Kubikasi: 19,2 / 17,86 m³` • `Total Berat: 19.200 / 24.800 kg` | read-only | `getByText(/Total Kubikasi:/).first()` |
| Empty state barang | text | `Belum ada barang. Klik "Pilih Barang "` | Armada 3 | `getByText(/Belum ada barang/)` |
| FAB Hitung Ulang Armada | floating button | 020: ikon refresh saja; 021: `Hitung Ulang Armada` | enabled (ada ≥1 barang) | `getByRole('button', { name: 'Hitung Ulang Armada' })` |
| FAB Visualisasi Terbaru | floating button | 020: ikon mata saja; 021: `Visualisasi Terbaru` | enabled | `getByRole('button', { name: 'Visualisasi Terbaru' })` |
| Footer | buttons | `Batal`, `← Sebelumnya`, `Simpan ke Draf`, `Selanjutnya →` | enabled | `getByRole('button', { name: 'Sebelumnya' })` |

**Pesan validasi terlihat (Step 2):** `Nilai Barang harus diisi` (helper merah di bawah field + border merah), `Jumlah harus diisi` (idem).

### SCR-11 — Modal "Pilih Barang" (022)

| Elemen | Tipe | Label / Teks | State | Selector |
|---|---|---|---|---|
| Dialog | modal | judul `Pilih Barang`, subjudul `Pilih barang yang ingin ditambahkan ke order` | terbuka; **tidak ada tombol close (×)** → FND-03 | `getByRole('dialog', { name: 'Pilih Barang' })` |
| Pencarian | search input + icon | placeholder `Cari kode/nama barang` | enabled | `getByPlaceholder('Cari kode/nama barang')` |
| Baris barang | list item | `SKU-PPR-001 - Kertas HVS A4 80 gsm` + meta `Dus • 0,018 m³ • 12,5 kg` | scrollable | `getByRole('listitem').filter({ hasText: 'SKU-PPR-001' })` |
| Checkbox barang | checkbox | (per baris) | multi-select; SKU-PPR-002 & SKU-BKU-001 **checked** | `getByRole('checkbox', { name: /SKU-PPR-002/ })` |
| Label sudah ditambahkan | badge | `Sudah Ditambahkan` | pada SKU-PPR-002 & SKU-BKU-001; checkbox **tetap aktif** (tidak disabled) → koreksi ASM-013 | `getByRole('listitem').filter({ hasText: 'SKU-PPR-002' }).getByText('Sudah Ditambahkan')` |
| Counter terpilih | text | `3 barang terpilih` | live | `getByText(/\d+ barang terpilih/)` |
| Batal | button (danger outline) | `Batal` | enabled | `getByRole('dialog').getByRole('button', { name: 'Batal' })` |
| Simpan | button (primary) | `Simpan` | enabled | `getByRole('dialog').getByRole('button', { name: 'Simpan' })` |

### SCR-12 / SCR-13 — Drawer "Hitung Ulang Armada" (023, 024)

| Elemen | Tipe | Label / Teks | State | Selector |
|---|---|---|---|---|
| Drawer | panel kanan | judul `Hitung Ulang Armada`, subjudul `Simulasi ulang kebutuhan unit dari muatan order ini. Terapkan untuk ubah data order.` | terbuka | `getByRole('dialog', { name: 'Hitung Ulang Armada' })` |
| Ringkasan | text | `Total Kubikasi 22,8 m³`, `Total Berat 12.140 kg`, `Jenis Pengiriman FTL` | read-only | `getByTestId('recalc-total-kubikasi')` |
| Kartu rekomendasi ×3 | selectable card | `Tronton Wing Box` (2 Unit • 15.000 Kg • 51,36 m³), `Tronton Box`, `Fuso Box` (3 Unit • 8.000 kg • 31,74 m³) | kartu ke-1 selected | `getByRole('radio', { name: /Tronton Wing Box/ })` |
| Label efisien | badge hijau | `Paling Efisien` | hanya pada kartu ke-1 | `getByText('Paling Efisien')` |
| Berat Terpakai | progress + % | `Berat Terpakai 78% / 78% / 47%` | read-only | `getByTestId('recalc-card-1-berat-terpakai')` |
| Ruang Terpakai | progress + % | `Ruang Terpakai 82% / 82% / 71%` | read-only | `getByTestId('recalc-card-1-ruang-terpakai')` |
| Jenis Armada | text field | `Jenis Armada *` nilai `Tronton Wing Box` | **read-only**, diubah via modal | `getByLabel('Jenis Armada')` |
| Pilih Jenis Armada | button (outline) | `Pilih Jenis Armada` | enabled | `getByRole('button', { name: 'Pilih Jenis Armada' })` |
| Jumlah Armada | number + stepper | `Jumlah Armada *` nilai `2`, tombol `−` / `+` | enabled | `getByLabel('Jumlah Armada')`, `getByRole('button', { name: 'Tambah jumlah armada' })` |
| Info kapasitas | text | `Berat Maksimal 1 Armada: 15.000 kg • Kubikasi Maksimal 1 Armada: 51,36 m³` | read-only | `getByText(/Berat Maksimal 1 Armada/)` |
| Tab visualisasi | tablist | `Armada 1`, `Armada 2` | `Armada 1` selected | `getByRole('tab', { name: 'Armada 2' })` |
| Kanvas 3D | canvas | overlay `1306 koli • 19.995 kg dialokasikan ke unit ini`, hint `Drag: putar 360° • Scroll: zoom • Klik 2×: reset` | interaktif | `getByTestId('load-visualization-canvas')` |
| Badge over-kapasitas | badge merah | `110 koli melebihi kapasitas (outline merah)` | **hanya 024** | `getByText(/koli melebihi kapasitas/)` |
| Legenda | legend chips | `Kertas HVS A4 80 gsm` (oranye), `Kertas HVS F4 70 gsm` (biru), `Buku Tulis 38 Lembar` (hijau) | read-only | `getByTestId('visualization-legend')` |
| Batal | button (danger outline) | `Batal` | enabled | `getByRole('dialog').getByRole('button', { name: 'Batal' })` |
| Terapkan ke Order | button (primary) | `Terapkan ke Order` | enabled | `getByRole('button', { name: 'Terapkan ke Order' })` |

### SCR-14 — Panel "Visualisasi Muatan Saat Ini" (025)

| Elemen | Tipe | Label / Teks | State | Selector |
|---|---|---|---|---|
| Panel | drawer kanan | judul `Visualisasi Muatan Saat Ini`, subjudul **sama persis** dengan drawer Hitung Ulang (`Simulasi ulang kebutuhan unit…`) → FND-04 | terbuka | `getByRole('dialog', { name: 'Visualisasi Muatan Saat Ini' })` |
| Ringkasan | text | `Total Kubikasi 22,8 m³`, `Total Berat 12.140 kg`, `Jenis Pengiriman FTL` | read-only | `getByTestId('current-viz-summary')` |
| Blok Armada | info read-only | `Jenis Armada: Tronton Box`, `Jumlah Armada: 2`, `Berat Maksimal: 20.000 kg`, `Kubikasi Maksimal: 60 m³` | **tanpa kontrol ubah** (sesuai REQ-042) | `getByTestId('current-viz-armada-info')` |
| Tab + kanvas + legenda | idem SCR-12 | — | `Armada 1` aktif; badge `110 koli melebihi kapasitas (outline merah)` | idem |
| Footer | buttons | `Batal`, **`Terapkan ke Order`** | **melanggar REQ-042** (seharusnya tidak mengubah pilihan armada) → FND-05 | `getByRole('button', { name: 'Terapkan ke Order' })` |

### SCR-15 / SCR-16 / SCR-17 — Step 3 Vendor dan Harga (026, 027, 028)

| Elemen | Tipe | Label / Teks | State | Selector |
|---|---|---|---|---|
| Card | section | `Vendor dan Harga` (Normal) / `Vendor` + `Harga Pengiriman` (varian multi) | — | `getByRole('region', { name: 'Vendor dan Harga' })` |
| Vendor | dropdown, wajib | `Vendor *` / `Pilih Vendor` / terisi `PT Logistik Transportasi Nusantara` | enabled | `getByLabel('Vendor')` |
| Tanggal Permintaan Muat | datetime, wajib | `Tanggal Permintaan Muat *`, placeholder `DD/MM/YYYY hh:mm`, terisi `24/07/2026 14:30` | enabled | `getByLabel('Tanggal Permintaan Muat')` |
| Ringkasan rute | text rows | `Drop Point Asal : Gudang MSK Region 2 • Kota Surabaya`, `Drop Point Tujuan : …`, `Jenis Armada : Tronton Wing Box` | read-only | `getByText('Drop Point Asal')` |
| Waktu Perjalanan (rute belum ada) | number + suffix `Jam`, wajib | `Waktu Perjalanan *` nilai `0`/`8` | **textfield** (026, 028) | `getByLabel('Waktu Perjalanan')` |
| Waktu Perjalanan (rute sudah ada) | text-only | `Waktu Perjalanan : 8 Jam` | **read-only** (027) | `getByText('Waktu Perjalanan').locator('..')` |
| Alert rute | info alert (oranye) | `Rute belum ada di Master Waktu Perjalanan. Isi waktu perjalanan, nilainya akan otomatis tersimpan sebagai data master baru.` | tampil hanya saat rute belum ada | `getByText(/Rute belum ada di Master Waktu Perjalanan/)` |
| Tabel ringkasan armada | table | `No`, `Nama Item`, `Total Berat`, `Total Kubikasi`, `Total Nilai Barang` | nilai `Tanpa Asuransi` atau `Rp1.150.350.000` | `getByRole('table')` |
| Harga | currency, wajib | `Harga *`, prefix `Rp`, helper `Mencakup seluruh biaya armada pada order ini` | enabled | `getByLabel('Harga')` |
| Gunakan komponen harga | checkbox | `Gunakan komponen harga` | unchecked (026) / checked (027, 028) | `getByRole('checkbox', { name: 'Gunakan komponen harga' })` |
| PPN / PPh / Asuransi | number + suffix `%` | `PPN` `1,1`, `PPh` `2`, `Asuransi` `0,2` | Asuransi **hanya** saat ada armada diasuransikan (027) | `getByLabel('PPN')` |
| Rincian harga | text rows | `Harga DPP Rp. 12.000.000`, `PPN (1,1%) Rp. 132.000`, `PPh (2%) - Rp. 240.000`, `Asuransi (0,2%) Rp2.300.700`, `(Total Nilai Barang = Rp. 63.620.000` | read-only; **kurung tutup hilang** → FND-07 | `getByText(/Total Nilai Barang =/)` |
| Total Harga | text bold | `Total Harga Rp14.192.700` (027) / `Rp. 11.892.000` (028) / `Rp. 0` (026) | read-only | `getByTestId('step3-total-harga')` |
| Footer | buttons | `Batal`, `← Sebelumnya`, `Simpan ke Draf`, `Selanjutnya →` | enabled | `getByRole('button', { name: 'Selanjutnya' })` |

### SCR-18 — Step 4 Review (029)

| Elemen | Tipe | Label / Teks | State | Selector |
|---|---|---|---|---|
| Accordion section | collapsible card ×5 | `Jenis Pengiriman dan Rute`, `Data Pengirim`, `Data Penerima`, `Data Barang`, `Vendor dan Harga` | semua expanded, semua **read-only** | `getByRole('button', { name: 'Data Barang' })` |
| Ringkasan Step 1 | text rows | `Jenis Pengiriman : FTL (Full Truck Load)`, `Jenis Armada : Tronton Wing Box`, `Jumlah Armada : 2`, `Tipe Pengiriman : Normal`, `Waktu Perjalanan : 8 Jam` | read-only | `getByText('FTL (Full Truck Load)')` |
| Visualisasi Muatan | button (outline, eye icon) | `Visualisasi Muatan` | enabled — konfirmasi label ASM-020 | `getByRole('button', { name: 'Visualisasi Muatan' })` |
| Grup armada | sub-heading | `Armada 1`, `Armada 2` | — | `getByText('Armada 2')` |
| Label diasuransikan | badge | `Diasuransikan` | hanya Armada 2 | `getByText('Diasuransikan')` |
| Nomor DO (review) | text | `TBL67827879232, TBL726378927398` atau `-` | read-only, bukan chip | `getByTestId('review-nomor-do-1')` |
| Tabel barang | table | `Kode SKU`/`Nama Barang`, `Kemasan`, `Kubikasi`/`Dimensi`, `Berat`, `Jumlah` (+ `Nilai Barang` hanya armada diasuransikan) | read-only | `getByRole('table').nth(0)` |
| Footer | buttons | `Batal`, `← Sebelumnya`, `Simpan ke Draf`, `Simpan` | enabled | `getByRole('button', { name: 'Simpan', exact: true })` |

### SCR-19 / SCR-21 / SCR-22 / SCR-24 — Pop up

| Layar | Elemen | Teks | Selector |
|---|---|---|---|
| SCR-19 Simpan Draf (030) | dialog | judul `Anda yakin ingin menyimpan data dalam draf?`, body `Data yang telah diisi akan disimpan sebagai draf` | `getByRole('dialog').filter({ hasText: 'menyimpan data dalam draf' })` |
| | tombol | `Batal` (outline), `Simpan Draf` (primary) | `getByRole('button', { name: 'Simpan Draf' })` |
| SCR-21 Visualisasi Muatan (031a) | dialog | judul `Visualisasi Muatan` + ikon close `×` | `getByRole('dialog', { name: 'Visualisasi Muatan' })` |
| | tab | `Armada 1`, `Armada 2` | `getByRole('tab', { name: 'Armada 2' })` |
| | metrik | `Berat Terpakai 78%`, `Ruang Terpakai 82%` | `getByTestId('viz-berat-terpakai')` |
| | kanvas + badge | `1306 koli • 19.995 kg dialokasikan ke unit ini`, `110 koli melebihi kapasitas (outline merah)`, hint drag/scroll | `getByTestId('load-visualization-canvas')` |
| | footer | **tidak ada** tombol aksi (hanya close) | `getByRole('button', { name: 'Tutup' })` |
| SCR-22 Batalkan Order (032) | dialog | judul `Batalkan Order` + `×`; `ID Order : ORD-20260607009`; `Vendor : PT Logistik Transportasi Nusantara` | `getByRole('dialog', { name: 'Batalkan Order' })` |
| | Alasan Pembatalan | textarea wajib, label `Alasan Pembatalan *`, placeholder `Tuliskan alasan pembatalan order` | `getByLabel('Alasan Pembatalan')` |
| | submit | `Batalkan Order` (danger, enabled) | `getByRole('dialog').getByRole('button', { name: 'Batalkan Order' })` |
| SCR-24 Data No. Perjalanan (035) | dialog | judul `Data No. Perjalanan` + `×`; chip `ID Order: ORD-20260607009`; chip `FTL` | `getByRole('dialog', { name: 'Data No. Perjalanan' })` |
| | baris unit ×2 | ikon copy + `TRC79289802` + `L 1892 PGS • Fuso Box` / `TRC79289802` + `L 6718 TH • Fuso Box` | `getByRole('listitem').nth(0)` |
| | ikon copy | icon button per baris | `getByRole('button', { name: 'Salin nomor perjalanan' }).first()` |

> **FND-08:** kedua baris No. Perjalanan menampilkan nomor **identik** (`TRC79289802`) — melanggar keunikan pada AC-073.

### SCR-20 — Detail Order (031) & SCR-23 — Edit Order (033)

| Elemen | Layar | Tipe | Label / Teks | State | Selector |
|---|---|---|---|---|---|
| Tombol kembali | Detail | icon button `‹` + heading `Detail Order` | — | enabled | `getByRole('button', { name: 'Kembali' })` |
| Aksi header | Detail | buttons | `Visualisasi Muatan`, `Batalkan Order`, `Edit Order` | enabled | `getByRole('button', { name: 'Edit Order' })` |
| Badge status | Detail | badge | `Menunggu Penugasan` | read-only | `getByText('Menunggu Penugasan')` |
| Field identitas | Detail | text rows | `ID Order : ORD67890792`, `Tanggal Dibuat : 26/06/2026 08:17` | read-only | `getByText('ORD67890792')` |
| Jenis/Tipe Pengiriman | Edit | text (locked) | `Jenis Pengiriman : FTL (Full Truck Load)`, `Tipe Pengiriman : Normal` | **read-only / locked** (sesuai REQ-060) | `getByText('Tipe Pengiriman').locator('..')` |
| Jenis Armada | Edit | dropdown | `Jenis Armada *` (`Tronton Box`) | **editable** | `getByLabel('Jenis Armada')` |
| Jumlah Armada | Edit | number | `Jumlah Armada *` (`1`) | **editable** | `getByLabel('Jumlah Armada')` |
| Data Pengirim/Penerima | Edit | form | seluruh field Step 1 | editable | — |
| Data Barang | Edit | accordion | `Data Barang - Armada 1`, `Data Barang - Armada 2` (Normal) | editable (checkbox asuransi, Nomor DO, Jumlah, Nilai Barang, Pilih Barang, hapus) | `getByRole('region', { name: 'Data Barang - Armada 1' })` |
| Vendor dan Harga | Edit | form | Vendor, Tanggal, tabel, Harga, komponen harga | editable | — |
| Footer | Edit | buttons | `Batal` (outline danger), `Simpan` (primary) | enabled; pop up konfirmasi per REQ-062 (tidak digambarkan) | `getByRole('button', { name: 'Simpan' })` |
| FAB auto stuffing | Edit | — | **tidak ada** `Hitung Ulang Armada` / `Visualisasi Terbaru` | — | — (koreksi ASM-017 → FND-09) |

### SCR-25 … SCR-39 — Varian Multipickup / Multidrop / Multipoint

| Aspek | Multipickup (038, 039, 040, 041/042, 043, 043a) | Multidrop (045, 046, 047, 047a, 048, 049) | Multipoint (052, 053, 054/055, 056, 057, 057a) |
|---|---|---|---|
| Step 2 — header sub-grup per armada | `Pick Up 1 - Jl. Jambi No.35, Darmo, Wonokromo, Kota Surabaya, Jawa Timur 60241` | `Drop Off 1 - Jl. Jambi No.35, …` | pasangan 2 kolom: `Pick Up 1 - …` \| `Drop Off 1 - …` (4 kombinasi per armada) |
| Struktur per sub-grup | `Nomor DO` (chips) + tabel barang + `Pilih Barang` + alert kapasitas + total | idem | idem |
| Selector sub-grup | `getByRole('region', { name: /Pick Up 1 - Jl\. Jambi/ })` | `getByRole('region', { name: /Drop Off 2 - Jl\. Kalianyar/ })` | `getByTestId('armada-1-pickup-1-dropoff-2')` |
| Step 3 — ringkasan alamat | `Drop Point Asal : Multipickup • ` **link** `Lihat Detail` | `Drop Point Tujuan : Multidrop • Lihat Detail` | **dua** link `Lihat Detail` (asal & tujuan) |
| Selector link | `getByRole('link', { name: 'Lihat Detail' }).first()` | idem `.last()` | `getByRole('row', { name: /Drop Point Asal/ }).getByRole('link', { name: 'Lihat Detail' })` |
| Pop up detail alamat | dialog `Detail Multipickup`: `Pick Up 1 - Kota Surabaya` → `Gudang MSK Region 2:` → alamat; Pick Up 2 & 3 | dialog `Detail Multidrop`: `Drop Off 1 - Kota Surabaya` … | kedua dialog di atas (054 & 055) |
| Selector dialog | `getByRole('dialog', { name: 'Detail Multipickup' })` | `getByRole('dialog', { name: 'Detail Multidrop' })` | keduanya |
| Step 3 — card layout | dipecah `Vendor` + `Harga Pengiriman` | idem | idem |
| Step 4 Review — Data Pengirim | 3 sub-card `Pick Up 1..3` | 1 card | 3 sub-card `Pick Up 1..3` |
| Step 4 Review — Data Penerima | 1 card | 2 sub-card `Drop Off 1..2` | 2 sub-card `Drop Off 1..2` |
| Step 4 Review — Data Barang | per `Armada N` → per `Pick Up N` | per `Armada N` → per `Drop Off N` | per `Armada N` → per pasangan `Pick Up × Drop Off` |
| Edit Order — heading card barang | **`Data Barang - Kontainer 1` / `Kontainer 2`** (043) → FND-10 | `Data Barang - Armada 1/2` (049) | `Data Barang - Armada 1/2` (057) |
| Detail Order — Tipe Pengiriman | `Multipickup` (043a) | **`Normal`** padahal ada Drop Off 1 & 2 (048) → FND-11 | `Multipoint` (057a) |

### Pesan Validasi, Alert, Empty State & Teks Sistem (unik)

| # | Teks | Jenis | Lokasi (file) | REQ |
|---|---|---|---|---|
| M-01 | `Nilai Barang harus diisi` | helper error inline + border merah | Step 2 (020, 021) | REQ-019, REQ-025 |
| M-02 | `Jumlah harus diisi` | helper error inline + border merah | Step 2 (020, 021) | REQ-018, REQ-025 |
| M-03 | `Kubikasi melebihi kapasitas armada` | alert informatif (badge merah) | Step 2 (020, 021, 038, 043, 045, 049, 052, 057) | REQ-024a |
| M-04 | `Berat melebihi kapasitas armada` | alert informatif | Step 2 (020, 021, 038, 045, 052) | REQ-024b |
| M-05 | `Kubikasi dan Berat melebihi kapasitas armada` | alert informatif | **TIDAK ADA di desain** | REQ-024c → FND-12 |
| M-06 | `Belum ada barang. Klik "Pilih Barang "` | empty state tabel | Step 2 Armada 3 (020, 021) | REQ-011 |
| M-07 | `Rute belum ada di Master Waktu Perjalanan. Isi waktu perjalanan, nilainya akan otomatis tersimpan sebagai data master baru.` | info alert (oranye) | Step 3 (026, 028, 039, 046, 053) | REQ-044 |
| M-08 | `110 koli melebihi kapasitas (outline merah)` | badge merah pada kanvas 3D | 024, 025, 031a | REQ-038 |
| M-09 | `Anda yakin ingin menyimpan data dalam draf?` / `Data yang telah diisi akan disimpan sebagai draf` | dialog konfirmasi | 030 | REQ-057 |
| M-10 | `Pisahkan dengan koma untuk menambahkan beberapa nomor` | helper text | Step 2 & Edit (semua) | REQ-021 |
| M-11 | `Berlaku untuk seluruh barang pada armada ini` | helper checkbox asuransi | Step 2 & Edit | REQ-020 |
| M-12 | `Mencakup seluruh biaya armada pada order ini` | helper field Harga | Step 3 | REQ-043 |
| M-13 | `Nama PIC Pengirim` / `Nama PIC Penerima` | helper text | Step 1 & Edit | REQ-007. **RESOLVED 2026-08-22** (SCN-0007, keputusan user): live tidak menampilkan teks helper ini — hanya label field "PIC Pengirim *"/"PIC Penerima *". Ditetapkan bukan bug, variasi copy diterima; AC-004 hanya mensyaratkan field tampil. |
| M-14 | `Contoh: 081234567898` | helper format WhatsApp | Step 1 & Edit | REQ-007. **RESOLVED 2026-08-22** (SCN-0007, keputusan user): teks contoh ini tidak ditemukan di live sama sekali. Ditetapkan bukan bug — lihat catatan M-13. |
| M-15 | `N barang terpilih` (contoh `3 barang terpilih`) | counter | Modal Pilih Barang (022) | REQ-015 |
| M-16 | `Sudah Ditambahkan` | badge | Modal Pilih Barang (022) | REQ-014 |
| M-17 | `Paling Efisien` | badge rekomendasi | Drawer (023, 024) | REQ-036 |
| M-18 | `Diasuransikan` | badge armada | Review & Detail (029, 031, 041, 047a, 048, 056, 057a) | REQ-051 |
| M-19 | `Tanpa Asuransi` | nilai sel tabel | Step 3 & Review | REQ-047 |
| M-20 | `1306 koli • 19.995 kg dialokasikan ke unit ini` | overlay kanvas | 023–025, 031a | REQ-038 |
| M-21 | `Drag: putar 360° • Scroll: zoom • Klik 2×: reset` | hint interaksi kanvas | 023–025, 031a | REQ-038 |
| M-22 | `Tuliskan alasan pembatalan order` | placeholder wajib | 032 | REQ-065 |
| M-23 | `Menampilkan 1 - 20 data dari 30 data` | info paginasi | 016, 017, 034, 036, 050 | — |
| M-24 | `Simulasi ulang kebutuhan unit dari muatan order ini. Terapkan untuk ubah data order.` | subjudul drawer | 023, 024, **dan 025** | REQ-033, REQ-042 |
| M-25 | Badge status: `Isi Data Dasar`, `Isi Data Muatan`, `Isi Data Vendor`, `Review Order`, `Menunggu Penugasan`, `Ditugaskan`, `Proses Pengiriman`, `Terkirim`, `Dibatalkan` | status chip | Daftar Order | REQ-054 → FND-13 |

### Peta Navigasi / Transisi Antar Layar

```
Daftar Order (SCR-01)
 ├─ [Filter] ──────────────► panel filter (SCR-02) ─ [Terapkan]/[Reset]
 ├─ [Buat Order] ──────────► Step 1 (SCR-04 → SCR-05/06/07/08)
 │      [Selanjutnya] ────► Step 2 (SCR-09/25/31/37)
 │            ├─ [Pilih Barang] ──► Modal Pilih Barang (SCR-11) ─ [Simpan]/[Batal] ─► Step 2
 │            ├─ [Hitung Ulang Armada] ► Drawer (SCR-12/13) ─ [Terapkan ke Order] ► sinkron Step 1 & 2
 │            │                                              └ [Batal] ► Step 2 tanpa perubahan
 │            ├─ [Visualisasi Terbaru] ► Panel (SCR-14)
 │            └─ [Selanjutnya] ► Step 3 (SCR-15/16/17/26/32/38)
 │                    ├─ [Lihat Detail] ► Pop up Detail Multipickup/Multidrop (SCR-27/33)
 │                    └─ [Selanjutnya] ► Step 4 Review (SCR-18/28/34/39)
 │                            ├─ [Visualisasi Muatan] ► Pop up (SCR-21)
 │                            └─ [Simpan] ► status "Menunggu Penugasan" ► Daftar Order
 │      [Simpan ke Draf] (step manapun) ► Pop up konfirmasi (SCR-19) ► [Simpan Draf] ► Daftar Order
 │      [Batal] ► (pop up konfirmasi, tidak digambarkan) ► Daftar Order
 ├─ aksi [Detail] ─────────► Detail Order (SCR-20/30/35/39)
 │            ├─ [Visualisasi Muatan] ► Pop up (SCR-21)
 │            ├─ [Batalkan Order] ► Pop up Batalkan Order (SCR-22) ► status "Dibatalkan"
 │            └─ [Edit Order] ► Edit Order (SCR-23/29/36/39) ─ [Simpan]/[Batal]
 ├─ aksi [Lanjutkan Pengisian] ► wizard pada step terakhir
 ├─ aksi [Edit] ────────────► Edit Order (SCR-23)
 ├─ aksi [Lihat No. Perjalanan] ► Pop up Data No. Perjalanan (SCR-24)
 └─ [Riwayat Pembatalan] / aksi [Riwayat Perubahan] ► layar terpisah (tidak ada desain)
```

### Temuan Desain (diskrepansi terhadap Requirements)

| ID | Temuan | File | Dampak pada test |
|---|---|---|---|
| FND-01 | Action menu status `Ditugaskan` memuat item **`Order Kembali`** yang tidak disebut REQ-068 | 034 | AC-070 perlu diperluas atau item dianggap out-of-scope |
| FND-02 | Step 2 menampilkan **3 card Armada** padahal `Data Unit → Jumlah Armada = 2` | 020, 021 | jangan jadikan jumlah card sebagai oracle; uji sinkronisasi REQ-026 |
| FND-03 | Modal `Pilih Barang` **tanpa tombol close (×)**; hanya `Batal`/`Simpan` | 022 | test close harus pakai `Batal`, bukan `×`/Esc |
| FND-04 | Subjudul panel `Visualisasi Muatan Saat Ini` identik dengan drawer Hitung Ulang | 025 | jangan pakai subjudul sebagai pembeda layar; pakai judul |
| FND-05 | Panel `Visualisasi Terbaru` memiliki tombol **`Terapkan ke Order`** → berpotensi mengubah pilihan armada, melanggar REQ-042 / VAL-16 | 025 | skenario negatif AC-038 |
| FND-06 | Label WhatsApp tidak konsisten: `No. WhatsApp PIC` (Normal) vs `Nomor WhatsApp PIC` (varian multi) | 019 vs 037/044/051 | selector `getByLabel` harus per-varian |
| FND-07 | Rincian asuransi `(Total Nilai Barang = Rp. 63.620.000` — kurung tutup hilang | 027, 029, 031 | hindari exact-match string |
| FND-08 | Dua No. Perjalanan bernilai identik `TRC79289802` | 035 | skenario negatif keunikan (AC-073) |
| FND-09 | Halaman Edit Order **tidak** menampilkan FAB `Hitung Ulang Armada`/`Visualisasi Terbaru` | 033, 043, 049, 057 | **mengoreksi ASM-017**; UF-03.A4 perlu ditinjau |
| FND-10 | Edit Order Multipickup memakai heading `Data Barang - Kontainer 1/2` padahal jenis FTL | 043 | selector heading harus toleran / dilaporkan sebagai bug |
| FND-11 | Detail Order Multidrop menampilkan `Tipe Pengiriman : Normal` walau ada `Drop Off 1` & `Drop Off 2` | 048 | data dummy salah; jangan dijadikan oracle |
| FND-12 | Kondisi alert gabungan `Kubikasi dan Berat melebihi kapasitas armada` **tidak ada** di desain manapun | — | AC-023 diuji tanpa referensi visual |
| FND-13 | Nama status desain ≠ spec: `Isi Data Dasar` (spec: *Isi Data Pengiriman*) dan `Terkirim` (spec: *Selesai*) | 016, 034, 036, 050 | **koreksi REQ-054** saat menulis assertion status |
| FND-14 | Step 3 & Review varian multi menampilkan baris `Armada 1, Armada 2, Armada 2` (penomoran duplikat, 3 baris untuk 2–3 armada) | 039, 041/042, 043a, 047a, 048, 056 | jangan assert penomoran; assert jumlah baris = jumlah armada |
| FND-15 | Sidebar aktif pada 036/050 adalah `Simulasi Muatan` walau konten `Daftar Order` | 036, 050 | abaikan state sidebar sebagai oracle navigasi |
