# UI Inventory — oms014-order-ftl-fcl-normal (design-analyzer)

> **CATATAN MERGE:** Isi berkas ini adalah pengganti persis untuk placeholder `*(diisi oleh design-analyzer)*` pada bagian **`## UI Inventory`** di
> `output/oms014-order-ftl-fcl-normal/oms014-order-ftl-fcl-normal.analysis.md` (baris 552–554).
> Bagian **`### Tambahan Assumptions Log`** di bagian akhir berkas ini adalah baris tabel baru yang harus di-*append* ke tabel **`## Assumptions Log`** (setelah `ASM-018`).
> Design-analyzer tidak memiliki tool `Edit`, sehingga penyisipan dilakukan pada tahap berikutnya.

---

## UI Inventory

> **Tahap pipeline:** 2/4 — design-analyzer
> **Aset terbaca:** **84 dari 84** PNG pada `inputs/oms014-order-ftl-fcl-normal/designs/` — `016.png`–`095.png` (80 file, tanpa gap) + 4 varian bersufiks `a` (`031a`, `043a`, `047a`, `057a`). *Header dokumen ini menyebut 85 file; jumlah aktual hasil glob adalah **84** (lihat ASM-019).*
> **Aplikasi:** tenant `Mentari Sumber Kertas` — `Order Management System Versi 1.0.0`; konteks `Shipper`, badge peran `Staff Operasional`, user `Andika / andikamsk@gmail.com`.

### Legenda Penanda

| Penanda | Arti |
|---|---|
| **🔴 AS-OFF** | **Elemen Auto Stuffing** — tampil pada desain (mode ON) tetapi **WAJIB ABSEN** pada OMS-014 (toggle OFF). Assertion: `await expect(locator).toHaveCount(0)` |
| **✅** | Elemen inti yang **tetap wajib ada** pada mode OFF |
| **(ro)** | Read-only / auto-fill dari master |
| **\*** | Field wajib — asterisk merah pada label |

### Konvensi Selector

1. Prioritas: `getByRole(role, { name })` → `getByLabel(...)` → `getByTestId(...)`.
2. Tidak ada satu pun `data-testid` yang terlihat pada desain — seluruh testid di bawah adalah **usulan** ber-format **kebab-case** (ASM-020).
3. Elemen berulang (`Armada n` / `Kontainer n`, `Pick Up n`, `Drop Off n`) **wajib di-scope** ke container-nya:
   `page.getByTestId('unit-card-1').getByRole('button', { name: 'Pilih Barang' })`.
4. Teks label/pesan dikutip **persis** seperti pada desain (termasuk anomali spasi/tanda baca).

---

### S-00. Kerangka Aplikasi (muncul di seluruh layar)

**Sumber:** semua file.

| Elemen | Tipe | Teks / Label | Saran Selector |
|---|---|---|---|
| Logo tenant | Text | `Mentari Sumber Kertas` | `getByText('Mentari Sumber Kertas')` |
| Toggle sidebar | Button (hamburger) | — | `getByTestId('sidebar-toggle')` |
| Konteks peran | Text + Badge | `Shipper` / `Staff Operasional` | `getByText('Staff Operasional')` |
| Notifikasi | Button (bell + dot merah) | — | `getByTestId('notification-bell')` |
| Profil user | Text | `Andika`, `andikamsk@gmail.com` | `getByTestId('user-profile')` |
| Logout | Button (icon) | — | `getByTestId('logout-button')` |
| Menu sidebar | Link | `Dashboard`, `Order`, `Penugasan Tracking`, `Simulasi Muatan` 🔴 AS-OFF, `Master Wilayah`, `Master Operasional`, `Manajemen Vendor`, `Pengaturan Akun`, `Akun Saya`, `Pengaturan Sistem`, `Pusat Notifikasi` | `getByRole('link', { name: 'Order' })` |
| Kuota Order | Progress + text | `Kuota Order`, `120/300`, `40%` | `getByTestId('kuota-order')` |
| Versi | Text | `Order Management System` / `Versi 1.0.0` | `getByTestId('app-version')` |
| Breadcrumb | Nav | `Beranda` › `Daftar Order` › `Buat Order` / `Detail Order` / `Edit Order` | `getByRole('navigation', { name: 'Breadcrumb' })` |
| Stepper wizard ✅ | Progress steps | `01 Data Pengiriman`, `02 Data Barang`, `03 Vendor dan Harga`, `04 Review` | `getByTestId('order-wizard-stepper')`, step: `getByTestId('step-2')` |

**State stepper:** step selesai = lingkaran biru + ikon centang; step aktif = lingkaran biru muda + nomor + label tebal; step belum tersentuh = abu-abu.

---

### S-01. Daftar Order
**Sumber:** `016.png`, `017.png`, `034.png`, `036.png`, `050.png`, `058.png`, `069.png`, `071.png`, `079.png`, `087.png`

| Elemen | Tipe | Teks / Placeholder | Saran Selector |
|---|---|---|---|
| Judul halaman | Heading | `Daftar Order` | `getByRole('heading', { name: 'Daftar Order' })` |
| Buat Order ✅ | Button (primary, + icon) | `Buat Order` | `getByRole('button', { name: 'Buat Order' })` |
| Batch Order ✅ | Button (outline) | `Batch Order` | `getByRole('button', { name: 'Batch Order' })` |
| Riwayat Pembatalan ✅ | Button (outline) | `Riwayat Pembatalan` | `getByRole('button', { name: 'Riwayat Pembatalan' })` |
| Filter ✅ | Button (outline, toggle panel) | `Filter` | `getByRole('button', { name: 'Filter' })` |
| Tampilkan n data | Select | `Tampilkan` `20` `data` | `getByTestId('page-size-select')` |
| Filter: ID Order | Text input | ph `Masukkan ID Order` | `getByLabel('ID Order')` |
| Filter: Jenis Order | Dropdown | ph `Pilih Jenis Order` | `getByLabel('Jenis Order')` |
| Filter: Vendor | Text input | ph `Masukkan Vendor` | `getByLabel('Vendor')` |
| Filter: Kota Asal | Dropdown | ph `Pilih Kota Asal` | `getByLabel('Kota Asal')` |
| Filter: Kota Tujuan | Dropdown | ph `Pilih Kota Tujuan` | `getByLabel('Kota Tujuan')` |
| Filter: Total Harga | Text input | ph `Masukkan Total Harga` | `getByLabel('Total Harga')` |
| Filter: Tipe Pengiriman | Dropdown (disabled-look) | ph `Pilih Tipe Pengiriman` | `getByLabel('Tipe Pengiriman')` |
| Filter: Metode Pengiriman | Dropdown (disabled-look) | ph `Pilih Metode Pengiriman` | `getByLabel('Metode Pengiriman')` |
| Filter: Drop Point Asal | Dropdown | ph `Pilih Drop Point Asal` | `getByLabel('Drop Point Asal')` |
| Filter: Drop Point Tujuan | Dropdown | ph `Pilih Drop Point Tujuan` | `getByLabel('Drop Point Tujuan')` |
| Filter: Status | Dropdown | ph `Pilih Status` | `getByLabel('Status')` |
| Reset | Button (outline merah) | `Reset` | `getByRole('button', { name: 'Reset' })` |
| Terapkan | Button (primary) | `Terapkan` | `getByRole('button', { name: 'Terapkan' })` |
| Tabel order ✅ | Table | Header 2 baris: `ID Order`/`Vendor`, `Kota Asal`/`Warehouse Asal`, `Kota Tujuan`/`Warehouse Tujuan`, `Total Harga ⇅`/`Status` | `getByRole('table')` / `getByTestId('order-table')` |
| Badge jenis order | Badge | `FTL`, `FCL`, `LTL`, `LCL` | `row.getByTestId('order-type-badge')` |
| Sel multi-alamat | Link | `Multipickup` (kolom Kota Asal), `Multidrop` (kolom Kota Tujuan) | `row.getByRole('link', { name: 'Multipickup' })` |
| Sorting Total Harga | Button (icon ⇅) | `Total Harga` | `getByRole('columnheader', { name: /Total Harga/ }).getByRole('button')` |
| Badge status ✅ | Badge | `Isi Data Dasar`, `Isi Data Muatan`, `Isi Data Vendor`, `Review Order`, `Menunggu Penugasan`, `Ditugaskan`, `Proses Pengiriman`, `Terkirim`, `Dibatalkan` | `row.getByTestId('order-status-badge')` |
| Menu aksi baris ✅ | Button (`...`) → menu | lihat matriks di bawah | `row.getByRole('button', { name: 'Aksi' })` / `getByTestId('row-action-menu')` |
| Info paginasi | Text | `Menampilkan 1 - 20 data dari 30 data` | `getByText(/Menampilkan .* data dari .* data/)` |
| Paginasi | Nav | `«`, `‹`, `1`, `2`, `3`, `…`, `12`, `›`, `»` | `getByRole('navigation', { name: 'Pagination' })` |

**Matriks isi menu aksi baris (terlihat pada desain):**

| Status baris | Item menu (urut) | Sumber |
|---|---|---|
| Status pengisian (`Isi Data Dasar`/`Isi Data Muatan`/`Isi Data Vendor`/`Review Order`) | `Detail`, `Lanjutkan Pengisian`, `Batalkan Order`, `Riwayat Perubahan` | `017.png` |
| `Menunggu Penugasan` | `Detail`, `Edit`, `Batalkan Order`, `Riwayat Perubahan` | `017.png` |
| `Ditugaskan` | `Detail`, `Lihat No. Perjalanan`, `Order Kembali`, `Batalkan Order`, `Riwayat Perubahan` | `034.png`, `069.png` |

Selector item: `getByRole('menuitem', { name: 'Lanjutkan Pengisian' })`.

> **Catatan regresi (REQ-020/REQ-022):** desain **tidak** menampilkan menu untuk status `Proses Pengiriman`, `Terkirim`, `Dibatalkan` → lihat ASM-021.

---

### S-02. Modal `Data No. Perjalanan`
**Sumber:** `035.png` (FTL, dari Daftar Order), `070.png` (FCL)

| Elemen | Tipe | Teks | Selector |
|---|---|---|---|
| Judul modal ✅ | Dialog heading | `Data No. Perjalanan` | `getByRole('dialog', { name: 'Data No. Perjalanan' })` |
| Tutup | Button (X) | — | `dialog.getByRole('button', { name: 'Tutup' })` |
| Chip ID Order | Badge | `ID Order: ORD-20260607009` | `dialog.getByText(/^ID Order:/)` |
| Badge jenis | Badge | `FTL` / `FCL` | `dialog.getByTestId('order-type-badge')` |
| Baris perjalanan | List item + copy icon | FTL: `TRC79289802` — `L 1892 PGS • Fuso Box`, `TRC79289802` — `L 6718 TH • Fuso Box`<br>FCL: `TRC79289802` — `TVW67892231 • 40 DRY`, `TRC79289802` — `CTN68901072 • 40 DRY` | `dialog.getByTestId('trip-row').nth(0)` |
| Salin nomor | Button (copy icon) | — | `dialog.getByTestId('trip-row').nth(0).getByRole('button', { name: 'Salin' })` |

---

### S-03. Buat Order — Step 1 `Data Pengiriman`
**Sumber FTL:** `018.png` (jenis order dipilih, `Tipe Pengiriman` kosong), `019.png` (Normal, empty), `037.png` (Multipickup), `044.png` (Multidrop), `051.png` (Multipoint)
**Sumber FCL:** `059.png` (`Tipe Pengiriman` kosong), `060.png` (Normal), `072.png` (Multipickup), `080.png` (Multidrop), `088.png` (Multipoint)

#### Section `Jenis Pengiriman dan Rute`

| Elemen | Tipe | Label / Nilai | Wajib | Selector |
|---|---|---|---|---|
| Kartu jenis order ✅ | Radio card ×4 | `FTL` `Full Truck Load`, `FCL` `Full Container Load`, `LTL` `Less Than Truck Load`, `LCL` `Less Than Container Load` | ya | `getByRole('radio', { name: 'FTL Full Truck Load' })` / `getByTestId('order-type-ftl')` |
| `Jenis Armada` (FTL) | Dropdown | contoh `Tronton Box`, `Tronton Wing Box`, `Fuso Box` | \* | `getByLabel('Jenis Armada')` |
| `Jumlah Armada` (FTL) | Number input | contoh `2`, `3` | \* | `getByLabel('Jumlah Armada')` |
| `Pelabuhan Asal` (FCL) | Dropdown | contoh `Tanjung Perak (SUB)` | \* | `getByLabel('Pelabuhan Asal')` |
| `Pelabuhan Tujuan` (FCL) | Dropdown | contoh `Panjang (PNJ)` | \* | `getByLabel('Pelabuhan Tujuan')` |
| `Jenis Kontainer` (FCL) | Dropdown | contoh `20 DRY`, `20 Feet Dry`, `20ft Dry Box` | \* | `getByLabel('Jenis Kontainer')` |
| `Jumlah Kontainer` (FCL) | Number input | contoh `1`, `2` | \* | `getByLabel('Jumlah Kontainer')` |
| `Tipe Pengiriman` ✅ | Dropdown | ph `Pilih Tipe Pengiriman`; opsi `Normal`, `Multipickup`, `Multidrop`, `Multipoint` | \* | `getByLabel('Tipe Pengiriman')` |
| `Metode Pengiriman` (FCL) | Radio card ×4 | `Door to Door` — *Kontainer diambil dari lokasi pengirim dan diantar hingga lokasi penerima.*<br>`Door to CY` — *Kontainer diambil dari lokasi pengirim dan dikirim hingga Container Yard (CY).*<br>`CY to CY` — *Kontainer diambil dari Container Yard (CY) asal dan dikirim ke Container Yard (CY) tujuan.*<br>`CY to Door` — *Kontainer diambil dari Container Yard (CY) dan diantar hingga lokasi penerima.* | \* | `getByRole('radio', { name: 'Door to Door' })` |

#### Section `Data Pengirim` (dan blok berulang `Pick Up n`)

| Elemen | Tipe | Label | Wajib | Placeholder / Helper | Selector |
|---|---|---|---|---|---|
| Judul blok | Heading | `Data Pengirim`; sub-blok `Pick Up 1`, `Pick Up 2`, `Pick Up 3` | — | — | `getByRole('heading', { name: 'Data Pengirim' })`; `getByTestId('pickup-block-1')` |
| Info alert | Alert (biru, ikon i) | `Pastikan urutan pengiriman sudah sesuai saat membuat shipment` | — | — | `getByRole('status').filter({ hasText: 'Pastikan urutan pengiriman' })` |
| `Drop Point Asal` | Dropdown | `Drop Point Asal` | \* | ph `Pilih  Drop Point Asal` | `getByLabel('Drop Point Asal')` |
| `Pengirim` | Dropdown | `Pengirim` | \* | ph `Pilih Pengirim` | `getByLabel('Pengirim')` |
| `PIC Pengirim` | Text | `PIC Pengirim` | \* | ph `Masukkan PIC Pengirim`; helper `Nama PIC Pengirim` | `getByLabel('PIC Pengirim')` |
| `No. WhatsApp PIC` | Text (numerik) | `No. WhatsApp PIC` | \* | ph `Masukkan No. WhatsApp PIC`; helper `Contoh: 081234567898` | `getByTestId('pickup-block-1').getByLabel('No. WhatsApp PIC')` |
| `Provinsi Asal` (ro) | Text | `Provinsi Asal` | — | ph `Provinsi Asal` | `getByLabel('Provinsi Asal')` |
| `Kota/Kab. Asal` (ro) | Text | `Kota/Kab. Asal` | — | ph `Kota/Kab. Asal` | `getByLabel('Kota/Kab. Asal')` |
| `Kecamatan Asal` (ro) | Text | `Kecamatan Asal` | — | ph `Kecamatan Asal` | `getByLabel('Kecamatan Asal')` |
| `Desa/Kelurahan Asal` (ro) | Text | `Desa/Kelurahan Asal` | — | ph `Desa/Kelurahan Asal` | `getByLabel('Desa/Kelurahan Asal')` |
| `Kode Pos` (ro) | Text | `Kode Pos` | — | ph `Kode Pos` | `getByTestId('pickup-block-1').getByLabel('Kode Pos')` |
| `Alamat Asal` (ro) | Textarea | `Alamat Asal` | — | ph `Alamat Asal` | `getByLabel('Alamat Asal')` |
| `Catatan` | Textarea | `Catatan` | tidak | ph `Masukkan Catatan` | `getByTestId('pickup-block-1').getByLabel('Catatan')` |
| Hapus alamat | Button (trash merah) | — | — | hanya pada `Pick Up 2..N` | `getByTestId('pickup-block-2').getByRole('button', { name: 'Hapus' })` |
| Tambah alamat | Button (link + icon) | `Tambah Baris Input` | — | Multipickup/Multipoint | `getByTestId('data-pengirim').getByRole('button', { name: 'Tambah Baris Input' })` |

#### Section `Data Penerima` (dan blok berulang `Drop Off n`)

Struktur identik dengan Data Pengirim, dengan label: `Drop Point Tujuan`\*, `Penerima`\*, `PIC Penerima`\* (helper `Nama PIC Penerima`), `No. WhatsApp PIC`\*, `Provinsi Tujuan` (ro), `Kota/Kab. Tujuan` (ro), `Kecamatan Tujuan` (ro), `Desa/Kelurahan Tujuan` (ro), `Kode Pos` (ro), `Alamat Tujuan` (ro), `Catatan`. Info alert `Pastikan urutan pengiriman sudah sesuai saat membuat shipment` muncul pada Multidrop/Multipoint. Tombol `Tambah Baris Input` pada Multidrop/Multipoint.

#### Footer aksi Step 1

| Tombol | State | Selector |
|---|---|---|
| `Batal` | selalu aktif (outline merah) | `getByRole('button', { name: 'Batal' })` |
| `Simpan ke Draf` | muncul setelah form dasar terisi (`019`); **tidak terlihat** pada `018`/`059`/`088` | `getByRole('button', { name: 'Simpan ke Draf' })` |
| `Selanjutnya` | **disabled** pada `018.png`/`059.png` (abu-abu, `Tipe Pengiriman` masih kosong); enabled pada `019.png` | `getByRole('button', { name: 'Selanjutnya' })` → `toBeDisabled()` |

**State terlihat:** empty (`018`, `019`, `059`, `060`, `072`, `080`, `088`), filled (`033`, `043`, `049`, `057`, `068`, `078`, `086`, `095` pada Edit Order). **Tidak ada** pesan validasi inline Step 1 yang tergambar di desain (lihat ASM-022).

---

### S-04. Buat Order — Step 2 `Data Barang` (tipe **Normal**)
**Sumber FTL:** `020.png` (floating button state *collapsed*, validasi tampil), `021.png` (floating button state *expanded*)
**Sumber FCL:** `061.png`

| Elemen | Tipe | Teks / Label | Selector |
|---|---|---|---|
| Card `Data Unit` ✅ (ro) | Card | FTL: `Jenis Armada` = `Tronton Box`, `Jumlah Armada` = `2`<br>FCL: `Jenis Kontainer` = `20 Feet Dry`, `Jumlah Kontainer` = `2` | `getByTestId('data-unit-card')` |
| Blok unit ✅ | Card berulang | `Armada 1`, `Armada 2`, `Armada 3` / `Kontainer 1..N` | `getByTestId('unit-card-1')` atau `getByRole('region', { name: 'Armada 1' })` |
| `Tambahkan Asuransi` ✅ | Checkbox (level unit) | helper `Berlaku untuk seluruh barang pada armada ini` | `getByTestId('unit-card-1').getByRole('checkbox', { name: 'Tambahkan Asuransi' })` |
| `Nomor DO` ✅ | Tag/chip input | ph `Masukkan Nomor DO`; helper `Pisahkan dengan koma untuk menambahkan beberapa nomor`; chip contoh `TGK783898202U ×`, `TBL28371302 ×` | `getByTestId('unit-card-1').getByLabel('Nomor DO')` |
| Hapus chip DO | Button (× pada chip) | — | `getByTestId('unit-card-1').getByRole('button', { name: 'Hapus TGK783898202U' })` |
| Tabel barang ✅ | Table | Header: `Kode SKU` / `Nama Barang`, `Kemasan`, `Kubikasi` / `Dimensi`, `Berat`, `Jumlah`, `Nilai Barang` *(hanya bila asuransi aktif)* | `getByTestId('unit-card-1').getByRole('table')` |
| Sel SKU | Text | `SKU-PPR-001` / `Kertas HVS A4 80 gsm`; `SKU-PPR-002` / `Kertas HVS F4 70 gsm`; `SKU-BKU-001` / `Buku Tulis 38 Lembar` | `row.getByText('SKU-PPR-001')` |
| Sel Kubikasi/Dimensi | Text | `0,018 m³` / `31 × 22 × 26,4 cm` | — |
| Sel Berat | Text | `12,5 kg` | — |
| `Jumlah` ✅ | Number input per baris | contoh `200`; kosong ditampilkan `0` | `row.getByRole('spinbutton', { name: 'Jumlah' })` / `getByTestId('qty-input-sku-ppr-001')` |
| `Nilai Barang` ✅ | Currency input per baris | prefix `Rp`, contoh `1.320.000`; kosong `Rp 0` | `row.getByTestId('nilai-barang-input')` |
| Hapus baris ✅ | Button (trash merah) | — | `row.getByRole('button', { name: 'Hapus' })` |
| `Pilih Barang` ✅ | Button (outline + icon) | `Pilih Barang` | `getByTestId('unit-card-1').getByRole('button', { name: 'Pilih Barang' })` |
| Ringkasan kapasitas ✅ | Text | `Total Kubikasi: 19,2 / 17,86 m³` • `Total Berat: 19.200 / 24.800 kg`; unit kosong `Total Kubikasi: 0 / 17,86 m³` • `Total Berat: 0 / 24.800 kg` | `getByTestId('unit-card-1').getByText(/Total Kubikasi:/)` |
| Badge kapasitas ✅ | Badge merah (informatif) | `Kubikasi melebihi kapasitas armada` / `Berat melebihi kapasitas armada` | `getByTestId('unit-card-1').getByText('Kubikasi melebihi kapasitas armada')` |
| Empty state ✅ | Text dalam tabel | `Belum ada barang. Klik "Pilih Barang "` *(ada spasi sebelum kutip penutup — lihat ASM-024)* | `getByTestId('unit-card-3').getByText(/Belum ada barang\. Klik/)` |
| **Floating `Hitung Ulang Armada` / `Hitung Ulang Kontainer`** | 🔴 **AS-OFF** | ikon *refresh* bulat (collapsed, `020`) → berlabel saat hover/expanded (`021`) | `expect(page.getByRole('button', { name: /Hitung Ulang (Armada|Kontainer)/ })).toHaveCount(0)` |
| **Floating `Visualisasi Terbaru`** | 🔴 **AS-OFF** | ikon *mata* bulat biru (collapsed) → berlabel `Visualisasi Terbaru` (expanded) | `expect(page.getByRole('button', { name: 'Visualisasi Terbaru' })).toHaveCount(0)` |
| Footer aksi ✅ | Buttons | `Batal`, `Sebelumnya`, `Simpan ke Draf`, `Selanjutnya` | `getByRole('button', { name: 'Sebelumnya' })` |

**State terlihat pada `020.png` / `061.png`:**
- **Filled + error:** `Armada 1` baris `SKU-PPR-001` → input `Nilai Barang` berbingkai merah + pesan **`Nilai Barang harus diisi`**.
- **Filled + error:** `Armada 2` baris `SKU-BKU-001` → input `Jumlah` berbingkai merah + pesan **`Jumlah harus diisi`**.
- **Warning informatif:** `Armada 1` → `Kubikasi melebihi kapasitas armada` (19,2 > 17,86 m³); `Armada 2` → `Berat melebihi kapasitas armada` (25.400 > 24.800 kg). Tombol `Selanjutnya` **tetap enabled** (REQ-016).
- **Empty:** `Armada 3` → tabel kosong + empty state + `Nomor DO` kosong (`Masukkan Nomor DO`).
- **Checkbox:** `Armada 1` tercentang (kolom `Nilai Barang` muncul); `Armada 2`/`Armada 3` tidak tercentang (kolom `Nilai Barang` **tidak** dirender).

---

### S-05. Step 2 `Data Barang` — tipe **Multipickup / Multidrop / Multipoint**
**Sumber FTL:** `038.png` (Multipickup), `045.png` (Multidrop), `052.png` (Multipoint)
**Sumber FCL:** `073.png` (Multipickup), `081.png` (Multidrop), `089.png` (Multipoint)

Struktur = S-04, ditambah **sub-section alamat di dalam setiap unit**:

| Tipe | Judul sub-section (persis) | Jumlah sub-section / unit | Selector |
|---|---|---|---|
| Multipickup | `Pick Up 1 - Jl. Jambi No.35, Darmo, Wonokromo, Kota Surabaya, Jawa Timur 60241` | = jumlah Pick Up | `getByTestId('unit-card-1').getByTestId('addr-section-pickup-1')` |
| Multidrop | `Drop Off 1 - Jl. Yos Sudarso No.80, Bumi Waras, Kec. Bumi Waras, Kota Bandar Lampung, Lampung 35225` | = jumlah Drop Off | `getByTestId('unit-card-1').getByTestId('addr-section-dropoff-1')` |
| Multipoint | Header 2 kolom: kiri `Pick Up 1 - <alamat>`, kanan `Drop Off 1 - <alamat>` | = Pick Up × Drop Off (desain: 2×2 = 4) | `getByTestId('unit-card-1').getByTestId('addr-section-p1-d1')` |

- `Nomor DO` + tabel barang + `Pilih Barang` + ringkasan kapasitas berada **di dalam setiap sub-section**.
- `Tambahkan Asuransi` tetap di **level unit** (di atas seluruh sub-section) — konsisten dengan ASM-007.
- Floating `Hitung Ulang …` + `Visualisasi Terbaru` tetap tampak pada semua desain ini → 🔴 **AS-OFF**.

---

### S-06. Modal `Pilih Barang` (Master Barang)
**Sumber:** `022.png`

| Elemen | Tipe | Teks | Selector |
|---|---|---|---|
| Judul ✅ | Dialog heading | `Pilih Barang` | `getByRole('dialog', { name: 'Pilih Barang' })` |
| Subjudul ✅ | Text | `Pilih barang yang ingin ditambahkan ke order` | `dialog.getByText('Pilih barang yang ingin ditambahkan ke order')` |
| Pencarian ✅ | Search input + icon | ph `Cari kode/nama barang` | `dialog.getByPlaceholder('Cari kode/nama barang')` |
| Item list ✅ | Checkbox + 2 baris teks | `SKU-PPR-001 - Kertas HVS A4 80 gsm` / `Dus • 0,018 m³ • 12,5 kg`<br>`SKU-PPR-002 - Kertas HVS F4 70 gsm` / `Dus • 0,022 m³ • 14,8 kg`<br>`SKU-BKU-001 - Buku Tulis 38 Lembar` / `Dus • 0,06 m³ • 18 kg`<br>`SKU-BKU-002 - Buku Tulis Hard Cover A5` / `Dus • 0,042 m³ • 13,2 kg`<br>`SKU-ATK-001 - Pulpen Gel Hitam 0.5 mm` / `Dus • 0,035 m³ • 9,5 kg` | `dialog.getByRole('checkbox', { name: /SKU-PPR-001/ })` |
| Badge sudah dipakai ✅ | Badge | `Sudah Ditambahkan` (checkbox tercentang, baris ter-highlight) | `dialog.getByRole('listitem').filter({ hasText: 'SKU-PPR-002' }).getByText('Sudah Ditambahkan')` |
| Counter ✅ | Text | `3 barang terpilih` | `dialog.getByText(/\d+ barang terpilih/)` |
| `Batal` ✅ | Button (outline merah) | `Batal` | `dialog.getByRole('button', { name: 'Batal' })` |
| `Simpan` ✅ | Button (primary) | `Simpan` | `dialog.getByRole('button', { name: 'Simpan' })` |

**State:** scroll list (scrollbar terlihat), item tercentang vs tidak, badge `Sudah Ditambahkan`.

---

### S-07. 🔴 Panel Auto Stuffing — **HARUS ABSEN pada OMS-014**
**Sumber:** `023.png`, `024.png`, `025.png` (FTL) • `062.png`, `063.png` (FCL) • `031a.png` (modal dari Detail Order)

| Layar | Judul persis | Isi kunci | Assertion negatif |
|---|---|---|---|
| Drawer hitung ulang (`023`, `024`) | `Hitung Ulang Armada` | Subjudul `Simulasi ulang kebutuhan unit dari muatan order ini. Terapkan untuk ubah data order.`; ringkasan `Total Kubikasi 22,8 m³`, `Total Berat 12.140 kg`, `Jenis Pengiriman FTL`; 3 kartu rekomendasi (`Tronton Wing Box` + badge `Paling Efisien`, `Tronton Box`, `Fuso Box`) berisi `2 Unit • 15.000 Kg • 51,36 m³`, progress `Berat Terpakai 78%`, `Ruang Terpakai 82%`; field `Jenis Armada`\* (ro) + tombol `Pilih Jenis Armada`; `Jumlah Armada`\* + stepper `−`/`+`; `Berat Maksimal 1 Armada: 15.000 kg • Kubikasi Maksimal 1 Armada: 51,36 m³`; section `Visualisasi Muatan` (tab `Armada 1`/`Armada 2`, kanvas 3D `1306 koli • 19.995 kg dialokasikan ke unit ini`, hint `Drag: putar 360° • Scroll: zoom • Klik 2×: reset`, legenda warna 3 SKU); footer `Batal` / `Terapkan ke Order`. `024` = identik `023` **plus** badge merah `110 koli melebihi kapasitas (outline merah)` | `expect(page.getByRole('dialog', { name: 'Hitung Ulang Armada' })).toHaveCount(0)` |
| Drawer hitung ulang FCL (`062`) | `Hitung Ulang Kontainer` | Sama, dengan `Jenis Kontainer` (ro `20 Feet Dry`) + `Pilih Jenis Kontainer`, `Jumlah Kontainer` + stepper, `Berat Maksimal 1 Kontainer: 28.280 kg • Kubikasi Maksimal 1 Kontainer: 38,27 m³`, tab `Kontainer 1`/`Kontainer 2` | `expect(page.getByRole('dialog', { name: 'Hitung Ulang Kontainer' })).toHaveCount(0)` |
| Drawer visualisasi (`025`, `063`) | `Visualisasi Muatan Saat Ini` | Ringkasan unit read-only (`Jenis Armada`, `Jumlah Armada`, `Berat Maksimal 20.000 kg`, `Kubikasi Maksimal 60 m³`) + section `Visualisasi Muatan` + badge `110 koli melebihi kapasitas (outline merah)`; footer `Batal` / `Terapkan ke Order` | `expect(page.getByRole('dialog', { name: 'Visualisasi Muatan Saat Ini' })).toHaveCount(0)` |
| Modal dari Detail Order (`031a`) | `Visualisasi Muatan` | Tab `Armada 1`/`Armada 2`, `Berat Terpakai 78%`, `Ruang Terpakai 82%`, kanvas 3D, legenda, badge `110 koli melebihi kapasitas (outline merah)` | `expect(page.getByRole('dialog', { name: 'Visualisasi Muatan' })).toHaveCount(0)` |

**Checklist assertion negatif (gabungan) untuk Step 2 / Step 4 / Detail Order:**

```
'Hitung Ulang Armada', 'Hitung Ulang Kontainer', 'Visualisasi Terbaru',
'Visualisasi Muatan', 'Visualisasi Muatan Saat Ini', 'Terapkan ke Order',
'Paling Efisien', 'Berat Terpakai', 'Ruang Terpakai',
'Pilih Jenis Armada', 'Pilih Jenis Kontainer',
/Berat Maksimal 1 (Armada|Kontainer)/, /Kubikasi Maksimal 1 (Armada|Kontainer)/,
/\d+ koli melebihi kapasitas/, /dialokasikan ke unit ini/,
'Drag: putar 360° • Scroll: zoom • Klik 2×: reset'
```
Plus testid: `recalc-fab`, `visualisasi-fab`, `load-visualization-canvas`, `capacity-progress`.

---

### S-08. Buat Order — Step 3 `Vendor dan Harga`
**Sumber FTL:** `026.png` (empty), `027.png` (filled + komponen harga & asuransi), `028.png` (filled, tanpa asuransi), `039.png` (Multipickup), `046.png` (Multidrop), `053.png` (Multipoint)
**Sumber FCL:** `064.png` (Normal), `074.png` (Multipickup), `082.png` (Multidrop), `090.png` (Multipoint)

| Elemen | Tipe | Label / Teks | Wajib | Selector |
|---|---|---|---|---|
| Judul section ✅ | Heading | `Vendor dan Harga` (varian multi-alamat FTL memecah menjadi `Vendor` + `Harga Pengiriman` + `Kalkulasi Harga`) | — | `getByRole('heading', { name: 'Vendor dan Harga' })` |
| `Vendor` ✅ | Dropdown | ph `Pilih Vendor`; contoh `PT Logistik Transportasi Nusantara` | \* | `getByLabel('Vendor')` |
| `Tanggal Permintaan Muat` ✅ | Datetime input | ph `DD/MM/YYYY hh:mm`; contoh `24/07/2026 14:30` | \* | `getByLabel('Tanggal Permintaan Muat')` |
| `Drop Point Asal` (ro) | Text baris | `: Gudang MSK Region 2 • Kota Surabaya` atau `: Multipickup • Lihat Detail` | — | `getByTestId('summary-drop-point-asal')` |
| `Drop Point Tujuan` (ro) | Text baris | `: Gudang Jaya Retail Malang • Kota Malang` atau `: Multidrop • Lihat Detail` | — | `getByTestId('summary-drop-point-tujuan')` |
| `Lihat Detail` | Link | `Lihat Detail` | — | `getByRole('link', { name: 'Lihat Detail' })` |
| `Jenis Armada` / `Jenis Kontainer` (ro) | Text baris | `: Tronton Wing Box` | — | `getByTestId('summary-jenis-unit')` |
| `Waktu Perjalanan` ✅ | Number input + suffix `Jam` | default `0` | \* | `getByLabel('Waktu Perjalanan')` |
| Info rute baru | Alert (kuning, ikon i) | `Rute belum ada di Master Waktu Perjalanan. Isi waktu perjalanan, nilainya akan otomatis tersimpan sebagai data master baru.` | — | `getByText(/Rute belum ada di Master Waktu Perjalanan/)` |
| Tabel rekap ✅ | Table | Header `No`, `Nama Item`, `Total Berat`, `Total Kubikasi`, `Total Nilai Barang`; baris `Armada 1` / `Kontainer 1` … | — | `getByTestId('unit-recap-table')` |
| Nilai `Total Nilai Barang` | Text | contoh `Rp1.150.350.000` atau `Tanpa Asuransi` | — | `row.getByText('Tanpa Asuransi')` |
| `Harga` ✅ | Currency input | prefix `Rp`, ph `0`; helper `Mencakup seluruh biaya armada pada order ini` | \* | `getByLabel('Harga')` |
| `Gunakan komponen harga` ✅ | Checkbox | — | tidak | `getByRole('checkbox', { name: 'Gunakan komponen harga' })` |
| `PPN` | Number input + `%` | contoh `1,1` | kondisional | `getByLabel('PPN')` |
| `PPh` | Number input + `%` | contoh `2` | kondisional | `getByLabel('PPh')` |
| `Asuransi` | Number input + `%` | contoh `0,2` (muncul bila ada unit diasuransikan) | kondisional | `getByLabel('Asuransi')` |
| `Simpan data ke master harga` | Checkbox | — | tidak | `getByRole('checkbox', { name: 'Simpan data ke master harga' })` |
| Ringkasan harga ✅ | Definition list | `Harga DPP` `Rp. 30.000.000`; `PPN (1,1%)` `Rp. 330.000`; `PPh (2%)` `- Rp. 600.000`; `Asuransi (0,2%)` `Rp2.013.500` + catatan `(Total Nilai Barang = Rp1.006.750.000)`; `Total Harga` `Rp. 29.730.000` | — | `getByTestId('price-summary')` |
| Footer ✅ | Buttons | `Batal`, `Sebelumnya`, `Simpan ke Draf`, `Selanjutnya` | — | — |

**State:** empty (`026` — `Pilih Vendor`, `0 Jam`, `Rp 0`, `Total Harga Rp. 0`, checkbox off) • filled tanpa komponen harga • filled + komponen harga (`027`, `028`, `074`).

---

### S-09. Modal `Detail Multipickup` / `Detail Multidrop`
**Sumber:** `040.png`, `054.png`, `075.png`, `091.png` (Multipickup) • `047.png`, `055.png`, `083.png`, `092.png` (Multidrop)

| Elemen | Tipe | Teks | Selector |
|---|---|---|---|
| Judul ✅ | Dialog heading | `Detail Multipickup` / `Detail Multidrop` | `getByRole('dialog', { name: 'Detail Multipickup' })` |
| Tutup | Button (X) | — | `dialog.getByRole('button', { name: 'Tutup' })` |
| Item alamat ✅ | Heading link + nama + alamat | `Pick Up 1 - Kota Surabaya` / `Gudang MSK Region 2:` / `Jl. Jambi No.35, Darmo, Wonokromo, Kota Surabaya, Jawa Timur 60241`<br>`Drop Off 2 - Kab. Lampung Tengah` / `Gudang Jaya Retail Lampung Tengah` / `Jl. Proklamator Raya, Seputih Jaya, Kec. Gn. Sugih, Kabupaten Lampung Tengah, Lampung 34161` | `dialog.getByTestId('address-item').nth(0)` |

---

### S-10. Buat Order — Step 4 `Review`
**Sumber FTL:** `029.png` (Normal), `041.png` + `042.png` (Multipickup — identik), `047a.png` (Multidrop), `056.png` (Multipoint)
**Sumber FCL:** `065.png` (Normal), `076.png` (Multipickup), `084.png` (Multidrop), `093.png` (Multipoint)

| Section (accordion, semua expanded) | Isi | Selector |
|---|---|---|
| `Jenis Pengiriman dan Rute` ✅ | FTL: `Jenis Pengiriman : FTL (Full Truck Load)`, `Jenis Armada : Tronton Wing Box`, `Jumlah Armada : 2`, `Tipe Pengiriman : Normal`, `Waktu Perjalanan : 8 Jam`<br>FCL: + `Pelabuhan Asal`, `Pelabuhan Tujuan`, `Jenis Kontainer : 20ft Dry Box`, `Jumlah Kontainer`, `Metode Pengiriman : Door to Door` | `getByRole('region', { name: 'Jenis Pengiriman dan Rute' })` |
| `Data Pengirim` ✅ | Baris ro: `Drop Point Asal`, `Pengirim`, `PIC Pengirim`, `No. WhatsApp PIC` *(pada `041` tertulis `Nomor WhatsApp PIC` — ASM-023)*, `Provinsi Asal`, `Kota/Kab. Asal`, `Kecamatan Asal`, `Desa/Kelurahan Asal`, `Kode Pos`, `Alamat Asal`, `Catatan`. Multi-alamat → sub-blok `Pick Up 1..N` | `getByTestId('review-data-pengirim')` |
| `Data Penerima` ✅ | Analog, sub-blok `Drop Off 1..N` | `getByTestId('review-data-penerima')` |
| `Data Barang` ✅ | Tombol **`Visualisasi Muatan`** 🔴 **AS-OFF** (outline, ikon mata) di kiri-atas section; lalu `Armada 1` / `Kontainer 1` (+ badge `Diasuransikan` bila relevan) → `Nomor DO` (`TBL67827879232, TBL726378927398` atau `-`) → tabel `Kode SKU`/`Nama Barang`, `Kemasan`, `Kubikasi`/`Dimensi`, `Berat`, `Jumlah`, `Nilai Barang` *(hanya unit diasuransikan)*. Multi-alamat → sub-header alamat per kombinasi | `getByTestId('review-data-barang')` |
| `Vendor dan Harga` ✅ | Tabel rekap `No`, `Nama Item`, `Total Berat`, `Total Kubikasi`, `Total Nilai Barang`; `Vendor : PT Logistik Transportasi Nusantara`; `Tanggal Permintaan Muat : 24/07/2026 14:30`; ringkasan `Harga DPP` / `PPN (1,1%)` / `PPh (2%)` / `Asuransi (0,2%)` + `(Total Nilai Barang = Rp1.006.750.000)` / `Total Harga Rp13.905.500` | `getByTestId('review-vendor-harga')` |
| Footer ✅ | `Batal`, `Sebelumnya`, `Simpan ke Draf`, **`Simpan`** (bukan `Selanjutnya`) | `getByRole('button', { name: 'Simpan', exact: true })` |

**Assertion AS-OFF utama Step 4:** `expect(page.getByRole('button', { name: 'Visualisasi Muatan' })).toHaveCount(0)`.

---

### S-11. Modal konfirmasi `Simpan ke Draf`
**Sumber:** `030.png`

| Elemen | Tipe | Teks persis | Selector |
|---|---|---|---|
| Judul ✅ | Dialog heading | `Anda yakin ingin menyimpan data dalam draf?` | `getByRole('dialog').getByText('Anda yakin ingin menyimpan data dalam draf?')` |
| Deskripsi ✅ | Text | `Data yang telah diisi akan disimpan sebagai draf` | `dialog.getByText('Data yang telah diisi akan disimpan sebagai draf')` |
| `Batal` ✅ | Button (outline) | `Batal` | `dialog.getByRole('button', { name: 'Batal' })` |
| `Simpan Draf` ✅ | Button (primary) | `Simpan Draf` | `dialog.getByRole('button', { name: 'Simpan Draf' })` |

---

### S-12. Detail Order
**Sumber FTL:** `031.png` (Normal), `043a.png` (Multipickup), `048.png` (Multidrop), `057a.png` (Multipoint)
**Sumber FCL:** `066.png` (Normal — **tanpa** tombol Visualisasi Muatan), `067.png` (Normal, status `Ditugaskan`), `077.png` (Multipickup), `085.png` (Multidrop), `094.png` (Multipoint)

| Elemen | Tipe | Teks | Selector |
|---|---|---|---|
| Tombol kembali ✅ | Button (chevron kiri) | — | `getByRole('button', { name: 'Kembali' })` |
| Judul ✅ | Heading | `Detail Order` | `getByRole('heading', { name: 'Detail Order' })` |
| **`Visualisasi Muatan`** | 🔴 **AS-OFF** | Button outline biru + ikon mata | `expect(page.getByRole('button', { name: 'Visualisasi Muatan' })).toHaveCount(0)` |
| `Batalkan Order` ✅ | Button (outline merah) | `Batalkan Order` | `getByRole('button', { name: 'Batalkan Order' })` |
| `Edit Order` ✅ | Button (outline biru) | `Edit Order` | `getByRole('button', { name: 'Edit Order' })` |
| Badge status ✅ | Badge | `Menunggu Penugasan` / `Ditugaskan` | `getByTestId('order-status-badge')` |
| `Jenis Pengiriman dan Rute` ✅ | Section (collapsible) | `ID Order : ORD67890792`, `Jenis Pengiriman : FCL (Full Container Load)`, `Tanggal Dibuat : 26/06/2026 08:17`, `Jenis Kontainer : 20ft Dry Box`, `Jumlah Kontainer : 2`, `Pelabuhan Asal`, `Pelabuhan Tujuan`, `Tipe Pengiriman : Normal`, `Metode Pengiriman : Door to Door`, `Waktu Perjalanan : 8 Jam` | `getByRole('region', { name: 'Jenis Pengiriman dan Rute' })` |
| `Data Pengirim` / `Data Penerima` ✅ | Section | sama seperti Step 4; multi-alamat → `Pick Up n` / `Drop Off n` | `getByTestId('detail-data-pengirim')` |
| `Data Barang` ✅ | Section | `Kontainer 1` / `Armada 1` (+ badge `Diasuransikan`), `Nomor DO`, tabel barang; multi-alamat → sub-header kombinasi alamat | `getByTestId('detail-data-barang')` |
| `Vendor dan Harga` ✅ | Section | tabel rekap + ringkasan harga (identik Step 4) | `getByTestId('detail-vendor-harga')` |
| Toggle accordion | Button (chevron) | — | `region.getByRole('button', { name: /Sembunyikan|Tampilkan/ })` |

> **Referensi visual mode OFF:** `066.png` adalah **satu-satunya** layar Detail Order pada set desain yang header-nya hanya berisi `Batalkan Order` + `Edit Order` **tanpa** `Visualisasi Muatan` — persis kondisi yang diharapkan REQ-027/AC-027.1. Layar ini dijadikan *golden reference* mode OFF (ASM-025).

---

### S-13. Modal `Batalkan Order`
**Sumber:** `032.png`

| Elemen | Tipe | Teks | Wajib | Selector |
|---|---|---|---|---|
| Judul ✅ | Dialog heading | `Batalkan Order` | — | `getByRole('dialog', { name: 'Batalkan Order' })` |
| Tutup | Button (X) | — | — | `dialog.getByRole('button', { name: 'Tutup' })` |
| `ID Order` (ro) | Text baris | `: ORD-20260607009` | — | `dialog.getByText('ORD-20260607009')` |
| `Vendor` (ro) | Text baris | `: PT Logistik Transportasi Nusantara` | — | — |
| `Alasan Pembatalan` ✅ | Textarea | ph `Tuliskan alasan pembatalan order` | \* | `dialog.getByLabel('Alasan Pembatalan')` |
| Konfirmasi ✅ | Button (merah solid) | `Batalkan Order` | — | `dialog.getByRole('button', { name: 'Batalkan Order' })` |

---

### S-14. Edit Order (satu halaman)
**Sumber FTL:** `033.png` (Normal), `043.png` (Multipickup), `049.png` (Multidrop), `057.png` (Multipoint)
**Sumber FCL:** `068.png` (Normal), `078.png` (Multipickup), `086.png` (Multidrop), `095.png` (Multipoint)

| Section | Isi | Catatan |
|---|---|---|
| Judul ✅ | Heading `Edit Order`; breadcrumb `Beranda › Daftar Order › Edit Order` | `getByRole('heading', { name: 'Edit Order' })` |
| `Jenis Pengiriman dan Rute` ✅ | **Read-only:** `ID Order`, `Tanggal Dibuat`, `Jenis Pengiriman`, `Tipe Pengiriman`, `Waktu Perjalanan`, (FCL) `Metode Pengiriman`, `Pelabuhan Asal`, `Pelabuhan Tujuan`.<br>**Editable:** `Jenis Armada`\* / `Jenis Kontainer`\*, `Jumlah Armada`\* / `Jumlah Kontainer`\* | `getByLabel('Jenis Armada')` tetap enabled; `getByTestId('field-id-order')` `toBeDisabled()` |
| `Data Pengirim` ✅ | Form penuh identik Step 1 (+ `Tambah Baris Input`, info alert pada multi) | — |
| `Data Penerima` ✅ | Form penuh identik Step 1 | — |
| `Data Barang - Armada n` / `Data Barang - Kontainer n` ✅ | Judul section per unit; `Tambahkan Asuransi`, `Nomor DO` (chip), tabel barang editable, `Pilih Barang`, ringkasan kapasitas + badge peringatan | `getByRole('heading', { name: 'Data Barang - Kontainer 1' })` |
| `Vendor dan Harga` ✅ | `Vendor`\*, `Tanggal Permintaan Muat`\*, tabel rekap, `Harga`\*, `Gunakan komponen harga` (+ `PPN`/`PPh`/`Asuransi`), ringkasan `Total Harga` | — |
| Footer ✅ | `Batal` (outline merah), `Simpan` (primary) | `getByRole('button', { name: 'Simpan' })` |
| AS-OFF | 🔴 Tidak boleh ada floating `Hitung Ulang …` / `Visualisasi Terbaru` / tombol `Visualisasi Muatan` pada halaman Edit Order | — |

---

### Katalog Teks Persis dari Desain

**Pesan validasi error (inline, blocking):**

| # | Pesan persis | Lokasi | Sumber |
|---|---|---|---|
| 1 | `Nilai Barang harus diisi` | Step 2 — input `Nilai Barang` (unit diasuransikan) | `020`, `021`, `061` |
| 2 | `Jumlah harus diisi` | Step 2 — input `Jumlah` | `020`, `021`, `061` |

**Peringatan informatif (non-blocking):**

| # | Pesan persis | Lokasi | Sumber |
|---|---|---|---|
| 3 | `Kubikasi melebihi kapasitas armada` | Footer unit Step 2 / Edit Order | `020`, `021`, `038`, `043`, `045`, `052`, `061`, `073`, `081`, `089`, `095` |
| 4 | `Berat melebihi kapasitas armada` | Footer unit Step 2 / Edit Order | idem |

**Empty state / helper / info:**

| # | Teks persis | Jenis | Sumber |
|---|---|---|---|
| 5 | `Belum ada barang. Klik "Pilih Barang "` | Empty state tabel barang | `020`, `021`, `061` |
| 6 | `Rute belum ada di Master Waktu Perjalanan. Isi waktu perjalanan, nilainya akan otomatis tersimpan sebagai data master baru.` | Info alert Step 3 | `026` |
| 7 | `Pastikan urutan pengiriman sudah sesuai saat membuat shipment` | Info alert Step 1 (Data Pengirim pada Multipickup/Multipoint; Data Penerima pada Multidrop/Multipoint) | `072`, `078`, `080`, `088` |
| 8 | `Berlaku untuk seluruh barang pada armada ini` | Helper checkbox asuransi | `020`, `021` |
| 9 | `Pisahkan dengan koma untuk menambahkan beberapa nomor` | Helper `Nomor DO` | `020`, `021` |
| 10 | `Nama PIC Pengirim` / `Nama PIC Penerima` | Helper field PIC | `019` |
| 11 | `Contoh: 081234567898` | Helper `No. WhatsApp PIC` | `019` |
| 12 | `Mencakup seluruh biaya armada pada order ini` | Helper `Harga` | `026` |
| 13 | `Sudah Ditambahkan` | Badge modal Pilih Barang | `022` |
| 14 | `3 barang terpilih` | Counter modal Pilih Barang | `022` |
| 15 | `Menampilkan 1 - 20 data dari 30 data` | Info paginasi Daftar Order | `017`, `034` |
| 16 | `Tanpa Asuransi` | Nilai kolom `Total Nilai Barang` | `026`, `066` |
| 17 | `Diasuransikan` | Badge unit pada Step 4 / Detail Order | `029`, `065`, `066` |
| 18 | `Anda yakin ingin menyimpan data dalam draf?` / `Data yang telah diisi akan disimpan sebagai draf` | Modal konfirmasi draf | `030` |
| 19 | `Tuliskan alasan pembatalan order` | Placeholder `Alasan Pembatalan` | `032` |
| 20 | `Pilih barang yang ingin ditambahkan ke order` | Subjudul modal Pilih Barang | `022` |
| 21 | `(Total Nilai Barang = Rp1.006.750.000)` | Catatan baris `Asuransi` pada ringkasan harga | `029`, `065` |

**🔴 Teks Auto Stuffing (WAJIB ABSEN pada mode OFF):**

| # | Teks persis | Sumber |
|---|---|---|
| A1 | `Hitung Ulang Armada` | `021`, `023`, `024` |
| A2 | `Hitung Ulang Kontainer` | `062` |
| A3 | `Visualisasi Terbaru` | `021` |
| A4 | `Visualisasi Muatan` (tombol/section) | `029`, `031`, `031a`, `041`, `047a`, `056`, `065`, `076`, `077`, `084`, `085`, `093`, `094` |
| A5 | `Visualisasi Muatan Saat Ini` | `025`, `063` |
| A6 | `Simulasi ulang kebutuhan unit dari muatan order ini. Terapkan untuk ubah data order.` | `023`, `024`, `025`, `062`, `063` |
| A7 | `Paling Efisien` | `023`, `024`, `062` |
| A8 | `Berat Terpakai` / `Ruang Terpakai` (+ persentase) | `023`–`025`, `031a`, `062`, `063` |
| A9 | `110 koli melebihi kapasitas (outline merah)` | `024`, `025`, `031a`, `063` |
| A10 | `1306 koli • 19.995 kg dialokasikan ke unit ini` | `023`–`025`, `031a`, `062`, `063` |
| A11 | `Drag: putar 360° • Scroll: zoom • Klik 2×: reset` | idem |
| A12 | `Terapkan ke Order` | idem |
| A13 | `Pilih Jenis Armada` / `Pilih Jenis Kontainer` | `023`, `024`, `062` |
| A14 | `Berat Maksimal 1 Armada: 15.000 kg` • `Kubikasi Maksimal 1 Armada: 51,36 m³` • `Berat Maksimal 1 Kontainer: 28.280 kg` • `Kubikasi Maksimal 1 Kontainer: 38,27 m³` | `023`, `024`, `062` |
| A15 | Menu sidebar `Simulasi Muatan` | seluruh layar (kandidat, lihat ASM-026) |

---

### Analisis Varian File Bersufiks `a`

**Kesimpulan: varian `a` BUKAN varian mode Auto Stuffing OFF.** Keempatnya adalah layar *tambahan yang disisipkan* dalam urutan penomoran, dan **semuanya tetap menampilkan elemen Auto Stuffing**. Hipotesis pada ASM-018 karena itu dikoreksi oleh ASM-019.

| File | Isi sebenarnya | Pasangan non-`a` | Perbedaan |
|---|---|---|---|
| `031.png` | Detail Order FTL Normal — header `Visualisasi Muatan` + `Batalkan Order` + `Edit Order` | — | — |
| `031a.png` | **Modal `Visualisasi Muatan`** yang terbuka **di atas** `031` (tab `Armada 1`/`Armada 2`, `Berat Terpakai 78%`, `Ruang Terpakai 82%`, kanvas 3D, badge `110 koli melebihi kapasitas (outline merah)`) | `031` | `031a` = state *modal terbuka* dari `031`. **Auto Stuffing tetap AKTIF.** |
| `043.png` | **Edit Order** FTL Multipickup (section `Data Barang - Kontainer 1/2`, footer `Batal`/`Simpan`) | — | — |
| `043a.png` | **Detail Order** FTL Multipickup — header `Visualisasi Muatan` + `Batalkan Order` + `Edit Order`, status `Menunggu Penugasan` | `043` | Layar berbeda (Detail vs Edit), **bukan** varian mode. **Auto Stuffing tetap AKTIF.** |
| `047.png` | **Modal `Detail Multidrop`** (Step 3 FTL Multidrop) | — | — |
| `047a.png` | **Step 4 Review** FTL Multidrop — section `Data Barang` memuat tombol `Visualisasi Muatan` | `047` | Layar berbeda (Review vs modal alamat). **Auto Stuffing tetap AKTIF.** |
| `057.png` | **Edit Order** FTL Multipoint | — | — |
| `057a.png` | **Detail Order** FTL Multipoint — header `Visualisasi Muatan` + `Batalkan Order` + `Edit Order` | `057` | Layar berbeda (Detail vs Edit). **Auto Stuffing tetap AKTIF.** |

**Satu-satunya referensi visual mode OFF pada set desain:** `066.png` (Detail Order FCL Normal) — header hanya `Batalkan Order` + `Edit Order`, `Data Barang` tanpa progress/kanvas/legenda. Bandingkan dengan `067.png` (Detail Order FCL Normal, status `Ditugaskan`) yang **memiliki** `Visualisasi Muatan`.

---

### Inkonsistensi Desain yang Ditemukan (bukan requirement)

| # | Temuan | File | Dampak pada test |
|---|---|---|---|
| D1 | Label `Nomor WhatsApp PIC` (Data Pengirim) vs `No. WhatsApp PIC` (Data Penerima & layar lain) | `037`, `041` | Selector `getByLabel` harus toleran → gunakan regex `/No(mor)?\. ?WhatsApp PIC/` (ASM-023) |
| D2 | Header Step 4/Detail/Edit Order menampilkan `Tipe Pengiriman : Normal` padahal layarnya Multipickup/Multidrop | `041`, `043`, `048`, `084` | Data dummy; jangan dijadikan expected value |
| D3 | Order FTL namun section Step 2/Edit bernama `Data Barang - Kontainer 1` | `043` | Judul section harus mengikuti jenis order (`Armada` untuk FTL) |
| D4 | Step 3 FCL menampilkan `Jenis Kontainer : Tronton Wing Box` (nama armada) | `074`, `090` | Data dummy |
| D5 | Step 3 FCL Normal (`064`) **tidak** menampilkan `Waktu Perjalanan`, padahal Detail/Edit FCL menampilkannya | `064` vs `067`, `068` | Uji keberadaan field secara kondisional (ASM-027) |
| D6 | `Data Unit` menyebut `Jumlah Armada 2` / `Jumlah Kontainer 2` tetapi dirender 3 blok unit | `020`, `021`, `061` | Data dummy; kardinalitas unit diuji dari input Step 1 |
| D7 | Empty state ditulis `Belum ada barang. Klik "Pilih Barang "` (spasi sebelum kutip penutup) | `020`, `061` | Gunakan `getByText(/Belum ada barang\. Klik/)` (ASM-024) |
| D8 | Sidebar aktif berpindah antara `Order`, `Penugasan Tracking`, dan `Simulasi Muatan` pada layar yang sama | `036`, `047a`, `088` | Jangan assert highlight sidebar |
| D9 | Step 3 varian multi-alamat FTL memecah card menjadi `Vendor` + `Harga Pengiriman` + `Kalkulasi Harga`, sedangkan varian lain memakai satu card `Vendor dan Harga` | `039`, `046`, `053`, `075` | Assert per-field, bukan per-judul-card |

---

### Tambahan Assumptions Log

> Tambahkan baris berikut ke tabel `## Assumptions Log` pada `oms014-order-ftl-fcl-normal.analysis.md`, setelah `ASM-018`.

| ID | Area | Ambiguitas pada Spec | Keputusan yang Diambil | Dampak / Risiko |
|---|---|---|---|---|
| **ASM-019** | Aset desain — varian `a` | ASM-018 menduga file bersufiks `a` (`031a`, `043a`, `047a`, `057a`) adalah varian mode Auto Stuffing **OFF**. | **Dugaan tersebut dikoreksi.** Verifikasi vision atas keempat file menunjukkan semuanya adalah **layar tambahan yang disisipkan** (modal `Visualisasi Muatan`, Detail Order Multipickup, Step 4 Review Multidrop, Detail Order Multipoint) dan **semuanya masih menampilkan elemen Auto Stuffing**. Tidak ada satu pun pasangan desain ON/OFF di folder `designs/`. | **Tinggi.** Test suite tidak boleh memakai varian `a` sebagai baseline mode OFF; seluruh assertion negatif harus diturunkan dari requirement (REQ-006/007/025/027), bukan dari desain. |
| **ASM-020** | Selector | Tidak ada `data-testid`, `aria-label`, atau atribut otomasi yang terlihat pada aset desain. | Seluruh `data-testid` pada UI Inventory adalah **usulan** (format kebab-case) dan harus dikonfirmasi/ditanam oleh tim FE. Prioritas eksekusi test: `getByRole` → `getByLabel` → `getByTestId`. | **Sedang.** Bila testid tidak ditanam, test elemen berulang (unit/alamat) harus bersandar pada `getByRole('region', …)` + `filter({ hasText })`. |
| **ASM-021** | Aksi Daftar Order per status | Desain hanya menampilkan menu aksi untuk 3 kelompok status (pengisian, `Menunggu Penugasan`, `Ditugaskan`). Menu untuk `Proses Pengiriman`, `Terkirim`, `Dibatalkan` tidak tergambar. | Diasumsikan pada status tersebut menu hanya berisi `Detail`, `Lihat No. Perjalanan` (bila sudah ditugaskan), dan `Riwayat Perubahan` — **tanpa** `Edit` dan **tanpa** `Batalkan Order`. | **Sedang.** Menjadi dasar skenario negatif REQ-020/REQ-021; wajib dikonfirmasi ke spec induk. |
| **ASM-022** | Validasi Step 1 & Step 3 | Desain **tidak** memuat satu pun contoh pesan validasi inline untuk Step 1 maupun Step 3; hanya Step 2 yang memperlihatkan pesan error. | Diasumsikan pola pesan mengikuti Step 2, yaitu `<Nama Field> harus diisi` (mis. `Jenis Armada harus diisi`, `Vendor harus diisi`). Assertion Step 1/Step 3 pada tahap awal memakai matcher longgar (`/harus diisi/`) atau memverifikasi *navigasi tertahan* alih-alih teks persis. | **Sedang–Tinggi.** Bila pola pesan berbeda, skenario negatif Step 1/Step 3 perlu penyesuaian teks. |
| **ASM-023** | Inkonsistensi label PIC | Label field nomor telepon ditulis `No. WhatsApp PIC` di sebagian besar layar, namun `Nomor WhatsApp PIC` pada blok `Pick Up` (`037`, `041`). | Label kanonik ditetapkan **`No. WhatsApp PIC`**; selector memakai regex toleran `/No(mor)?\.? ?WhatsApp PIC/`. | Rendah–Sedang. |
| **ASM-024** | Empty state Step 2 | Teks empty state pada desain terbaca `Belum ada barang. Klik "Pilih Barang "` — terdapat spasi sebelum tanda kutip penutup. | Assertion memakai **partial match** `/Belum ada barang\. Klik/` agar tidak rapuh terhadap perbaikan spasi/typo di implementasi. | Rendah. |
| **ASM-025** | Golden reference mode OFF | Tidak ada layar Step 2 mode OFF pada set desain; hanya `066.png` (Detail Order FCL Normal) yang tampil **tanpa** tombol `Visualisasi Muatan`. | `066.png` dijadikan **golden reference visual** untuk Detail Order mode OFF (REQ-027). Untuk Step 2/Step 4 mode OFF, ekspektasi visual diturunkan dari desain mode ON **dikurangi** daftar elemen Auto Stuffing (tabel A1–A15 pada UI Inventory). | **Sedang.** Bila mode OFF juga mengubah layout (mis. header section bergeser), ekspektasi perlu direvisi setelah build tersedia. |
| **ASM-026** | Menu `Simulasi Muatan` | Sidebar memuat menu `Simulasi Muatan` pada seluruh layar; spec tidak menyebut apakah menu ini bagian dari add-on Auto Stuffing. | Diasumsikan **bagian dari add-on Auto Stuffing**, namun **tidak dijadikan assertion wajib** (tidak disebut pada spec L4/L5/L13/L14). Dicatat sebagai kandidat A15 pada checklist AS-OFF untuk verifikasi manual. | Rendah–Sedang. |
| **ASM-027** | `Waktu Perjalanan` pada FCL | Step 3 FCL Normal (`064.png`) tidak menampilkan field `Waktu Perjalanan`, sementara Detail Order (`067.png`) dan Edit Order (`068.png`) FCL menampilkan `Waktu Perjalanan : 8 Jam`. | Diasumsikan `Waktu Perjalanan` **tetap wajib untuk FTL maupun FCL** dan ketiadaannya pada `064.png` adalah kelalaian desain. Skenario FCL tetap mengisi field ini, dengan fallback *conditional* bila field tidak dirender. | **Sedang.** Berpotensi menimbulkan false-negative pada skenario Step 3 FCL. |
| **ASM-028** | `Simpan ke Draf` di Step 1 | Tombol `Simpan ke Draf` tidak terlihat pada `018.png`, `059.png`, dan `088.png`, tetapi terlihat pada `019.png` (Step 1 terisi) serta seluruh Step 2/Step 3. | Diasumsikan `Simpan ke Draf` baru dirender/aktif setelah `Tipe Pengiriman` dipilih (form Step 1 lengkap strukturnya), bukan sejak awal. AC-024.1 diuji dengan prasyarat form Step 1 sudah menampilkan `Data Pengirim`/`Data Penerima`. | Rendah–Sedang. |
