# Analysis — oms012-order-ftl-auto-stuffing

> **Tahap pipeline:** 1/4 — spec-analyzer
> **Sumber spesifikasi:** `inputs/oms012-order-ftl-auto-stuffing/spec.txt` (113 baris, 10 blok rule)
> **Aset desain:** `inputs/oms012-order-ftl-auto-stuffing/designs/*.png` (47 file: `016`–`057` + varian `031a`, `043a`, `047a`, `057a`) — pada tahap ini dipakai **hanya** sebagai *grounding* nama field/label; inventarisasi penuh menjadi tugas design-analyzer.
> **Modul terkait:** `oms014-order-ftl-fcl-normal` adalah **kebalikan** modul ini (Auto Stuffing OFF). Requirement di sini menggambarkan perilaku **Auto Stuffing AKTIF**.

---

## Ringkasan Modul

Modul **OMS-012** mencakup proses **pembuatan & pengelolaan Order FTL (Full Truck Load)** pada **Order Management System (OMS)** dengan **add-on Auto Stuffing AKTIF**.

Karakteristik inti:

1. **Basis = Order FTL TMS.** Definisi FTL, satuan **Armada**, wizard **4 step** (`Data Pengiriman` → `Data Barang` → `Vendor & Harga` → `Review`), serta input **manual maupun batch order** mengikuti spesifikasi Order FTL di TMS.
2. **Pembeda utama = Step 2 (Data Barang).** Barang **tidak diinput manual**, melainkan **dipilih dari Master Barang** melalui modal `Pilih Barang`. Atribut barang (Kode SKU, Nama Barang, Kemasan, Kubikasi, Dimensi, Berat) bersifat **read-only** hasil draft dari master; user hanya mengisi `Jumlah` dan (kondisional) `Nilai Barang`.
3. **Add-on Auto Stuffing** hanya aktif bila modul OMS **dibeli beserta add-on** tersebut, dan hanya berlaku untuk jenis pengiriman **FTL & FCL**. OMS **tidak** memiliki engine stuffing sendiri — logic memakai tools yang sudah ada; peran OMS hanya **mengatur penempatan barang ke dalam order**.
4. **Turunan Auto Stuffing pada Step 2:** dua **floating button** (`Hitung Ulang Armada`, `Visualisasi Terbaru`) + **drawer/panel rekomendasi armada** berisi rekomendasi 3 teratas, indikator `Berat Terpakai`/`Ruang Terpakai`, label `Paling Efisien`, **visualisasi muatan 3D**, dan aksi `Terapkan ke Order` yang **menulis balik** ke Step 1 dan Step 2.
5. **Turunan Auto Stuffing pada Step 4 (Review):** struktur Data Barang mengikuti Step 2 + tombol **`Visualisasi Muatan`** pada card Data Barang yang membuka **pop up visualisasi**.
6. **Rule non-wizard** yang juga tercakup: 9 **Status Order**, **Hak Edit**, **Pembatalan Order**, **Aksi pada Daftar Order** per status, dan **No. Perjalanan** (generate otomatis, public tracking, pop up + copy).

**Karakter utama modul ini untuk pengujian:**
- Banyak requirement bersifat **algoritmik** (distribusi Auto Stuffing, pembagian rata antar alamat, sisa ke alamat pertama) → butuh skenario dengan **data terkontrol & ekspektasi numerik**.
- Banyak requirement bersifat **kondisional/state-driven** (Nilai Barang muncul saat asuransi aktif, tombol Hitung Ulang aktif saat ada ≥1 barang, aksi Daftar Order per status, No. Perjalanan setelah Ditugaskan) → butuh **matriks state × ekspektasi**.
- Terdapat requirement **non-blocking yang eksplisit** (alert kapasitas) → penting sebagai skenario **negatif-palsu** (sistem TIDAK boleh memblokir).

---

## Requirements

### Legenda

| Kolom | Keterangan |
|---|---|
| **ID** | Identifier requirement, dipakai sebagai tag `@REQ-xxx` pada tahap scenario-generator |
| **Sumber** | Baris pada `spec.txt` yang menjadi dasar. `INF` = inferensi (lihat Assumptions Log) |
| **Prioritas** | `high` = inti pembeda modul / blocking alur utama; `medium` = rule pendukung yang wajib regresi; `low` = pelengkap/kosmetik |

---

### R1. Ketentuan Umum & Cakupan Add-on

| ID | Requirement | Sumber | Prioritas |
|---|---|---|---|
| **REQ-001** | Order FTL pada OMS **mengacu pada spesifikasi Order FTL di TMS**: definisi FTL, **satuan Armada**, dan seluruh rule dasar yang tidak dinyatakan berbeda pada spec ini. | L3 | high |
| **REQ-002** | Pembuatan order menggunakan **wizard 4 step**: `Data Pengiriman` → `Data Barang` → `Vendor & Harga` → `Review`. | L3 | high |
| **REQ-003** | Order dapat dibuat melalui **input manual (wizard)** maupun **batch order**. | L3 | medium |
| **REQ-004** | **Pembeda tunggal terhadap TMS adalah Step 2 (Data Barang)**: data barang **diambil dari Master Barang**, bukan input deskripsi manual. Step 1 dan Step 3 identik dengan TMS. | L4, L10, L54 | high |
| **REQ-005** | **Add-on Auto Stuffing hanya aktif** jika modul OMS **dibeli beserta add-on** tersebut. Tanpa entitlement add-on, seluruh elemen & logic Auto Stuffing tidak tersedia. | L5 | high |
| **REQ-006** | Penerapan Auto Stuffing **hanya untuk jenis pengiriman FTL & FCL** — jenis lain (mis. LTL/LCL) tidak mendapatkan elemen/logic Auto Stuffing. | L5 | high |
| **REQ-007** | **Logic Auto Stuffing menggunakan tools yang sudah ada**; OMS **hanya mengatur penempatan barang ke dalam order** (tidak menghitung ulang algoritma stuffing secara mandiri). | L6 | medium |
| **REQ-008** | **Penyesuaian turunan pada Step 4 (Review)**: struktur informasi Data Barang mengikuti Step 2, dan tersedia informasi **visualisasi muatan** berupa **pop up** yang tampil saat klik button `Visualisasi Muatan`. | L7, L67 | high |

**Acceptance Criteria**

- **REQ-001**
  - AC-001.1: Satuan unit pada seluruh layar order FTL adalah **`Armada`** (bukan `Kontainer`/`Koli` sebagai unit order).
  - AC-001.2: Rule yang tidak dinyatakan berbeda pada spec OMS berperilaku sama dengan Order FTL TMS (regresi).
- **REQ-002**
  - AC-002.1: Stepper menampilkan **4 langkah** berlabel `Data Pengiriman`, `Data Barang`, `Vendor & Harga`, `Review` (penomoran `01`–`04`).
  - AC-002.2: Step aktif ter-highlight; step yang sudah selesai bertanda *checked*; step yang belum tersentuh berwarna netral.
  - AC-002.3: Navigasi maju (`Selanjutnya`) dan mundur (`Sebelumnya`) mempertahankan data setiap step.
  - AC-002.4: Aksi utama pada Step 4 adalah `Simpan` (bukan `Selanjutnya`).
- **REQ-003**
  - AC-003.1: Halaman Daftar Order menyediakan entry point `Buat Order` (manual) dan `Batch Order`.
  - AC-003.2: Order hasil batch muncul di Daftar Order dengan status yang sesuai dan dapat dibuka via `Detail`.
- **REQ-004**
  - AC-004.1: Pada Step 2, **tidak tersedia** field bebas untuk mengetik deskripsi/nama barang; satu-satunya jalur penambahan barang adalah tombol `Pilih Barang`.
  - AC-004.2: Struktur & field Step 1 dan Step 3 identik dengan Order FTL TMS.
- **REQ-005**
  - AC-005.1: Pada tenant **dengan** add-on: floating button `Hitung Ulang Armada` & `Visualisasi Terbaru` tampil di Step 2, dan tombol `Visualisasi Muatan` tampil di Step 4.
  - AC-005.2: Pada tenant **tanpa** add-on: seluruh elemen di AC-005.1 tidak dirender dan tidak dapat diakses melalui jalur alternatif (deep link/URL/API dari UI).
  - AC-005.3: Menonaktifkan add-on tidak merusak alur pembuatan order standar (order tetap dapat dibuat sampai Step 4 & disimpan).
- **REQ-006**
  - AC-006.1: Order jenis `FTL` menampilkan elemen Auto Stuffing (dengan istilah `Armada`).
  - AC-006.2: Order jenis `FCL` menampilkan elemen Auto Stuffing (dengan istilah `Kontainer`).
  - AC-006.3: Order jenis selain FTL/FCL **tidak** menampilkan elemen Auto Stuffing.
- **REQ-007**
  - AC-007.1: Hasil rekomendasi & penempatan yang ditampilkan OMS konsisten dengan output tools Auto Stuffing untuk input yang sama (deterministik untuk data identik).
  - AC-007.2: Menjalankan `Hitung Ulang Armada` dua kali berturut-turut tanpa mengubah data menghasilkan rekomendasi & penempatan yang sama.
- **REQ-008**
  - AC-008.1: Card `Data Barang` pada Step 4 memuat tombol `Visualisasi Muatan`.
  - AC-008.2: Klik tombol tersebut membuka **pop up** visualisasi muatan; pop up dapat ditutup dan mengembalikan user ke Step 4 tanpa mengubah data.
  - AC-008.3: Kolom yang ditampilkan pada Data Barang Step 4 sama dengan struktur Step 2 (lihat REQ-047).

---

### R2. Step 1 — Data Pengiriman

| ID | Requirement | Sumber | Prioritas |
|---|---|---|---|
| **REQ-009** | Step 1 **identik dengan Step 1 Order FTL di TMS**, memuat field `Jenis Armada`, `Jumlah Armada`, `Tipe Pengiriman`, section `Data Pengirim`, dan section `Data Penerima`. | L10 | high |
| **REQ-010** | `Tipe Pengiriman` memiliki **4 opsi**: `Normal`, `Multipickup`, `Multidrop`, `Multipoint`. | L10 | high |
| **REQ-011** | `Data Pengirim` & `Data Penerima` **auto-draft dari Master Droppoint** (memilih drop point mengisi otomatis data wilayah/alamat terkait). | L10 | high |
| **REQ-012** | Berlaku **rule cascading** (dropdown wilayah bertingkat / ketergantungan antar field) sesuai TMS. | L10 | medium |
| **REQ-013** | Berlaku **minimal baris alamat per tipe pengiriman**: `Normal` = 1 pengirim & 1 penerima; `Multipickup` = ≥2 pengirim; `Multidrop` = ≥2 penerima; `Multipoint` = ≥2 pengirim **dan** ≥2 penerima. | L10, INF | high |
| **REQ-014** | **Validasi field wajib Step 1** berlaku identik dengan TMS — navigasi ke Step 2 ditahan bila masih ada field wajib kosong/invalid. | L10 | high |
| **REQ-015** | **Fungsi button Step 1** (`Batal` / `Simpan ke Draf` / `Selanjutnya`) berlaku identik dengan TMS. | L10 | high |

**Acceptance Criteria**

- **REQ-009**
  - AC-009.1: Field `Jenis Armada` merupakan pilihan dari master armada dan menentukan **kapasitas Berat & Kubikasi maksimal** per armada.
  - AC-009.2: Field `Jumlah Armada` menerima bilangan bulat ≥ 1 dan menentukan jumlah blok `Armada n` yang dirender di Step 2.
  - AC-009.3: Struktur, urutan, dan label section Step 1 sama dengan Order FTL TMS.
- **REQ-010**
  - AC-010.1: Dropdown `Tipe Pengiriman` memuat **tepat empat** opsi tersebut.
  - AC-010.2: Memilih tipe pengiriman langsung mengubah struktur section `Data Pengirim`/`Data Penerima` (tunggal vs berulang) tanpa reload halaman.
- **REQ-011**
  - AC-011.1: Memilih `Drop Point Asal` mengisi otomatis Provinsi/Kota/Kecamatan/Desa/Kode Pos/Alamat Asal.
  - AC-011.2: Memilih `Drop Point Tujuan` mengisi otomatis data wilayah tujuan.
  - AC-011.3: Field hasil auto-draft bersifat **read-only** dan tidak dapat diedit manual.
  - AC-011.4: Mengganti drop point memperbarui seluruh field turunannya (tidak menyisakan nilai lama).
- **REQ-012**
  - AC-012.1: Field turunan tidak dapat diisi sebelum field induknya terisi (state disabled/kosong).
  - AC-012.2: Mengubah field induk mereset field turunan yang tidak lagi valid.
- **REQ-013**
  - AC-013.1: `Normal` — section pengirim & penerima masing-masing satu blok, tanpa tombol tambah baris.
  - AC-013.2: `Multipickup` — section pengirim berulang (`Pick Up 1..N`) dengan tombol tambah baris; sisa penerima tunggal; baris tidak dapat dihapus hingga tersisa < 2.
  - AC-013.3: `Multidrop` — section penerima berulang (`Drop Off 1..N`); pengirim tunggal.
  - AC-013.4: `Multipoint` — kedua section berulang.
- **REQ-014**
  - AC-014.1: Klik `Selanjutnya` dengan field wajib kosong menahan navigasi dan menampilkan pesan validasi inline pada field terkait.
  - AC-014.2: Field wajib ditandai asterisk (`*`) pada label.
  - AC-014.3: Setelah field diperbaiki, pesan validasi hilang dan navigasi diizinkan.
- **REQ-015**
  - AC-015.1: `Batal` menampilkan konfirmasi lalu keluar dari wizard tanpa menyimpan.
  - AC-015.2: `Simpan ke Draf` menyimpan order dengan status `Isi Data Pengiriman` (lihat REQ-051).
  - AC-015.3: `Selanjutnya` memvalidasi Step 1 lalu berpindah ke Step 2.

---

### R3. Step 2 — Data Barang (Modal Pilih Barang & Field Barang)

| ID | Requirement | Sumber | Prioritas |
|---|---|---|---|
| **REQ-016** | Barang **tidak diinput manual**; barang dipilih dari **Master Barang** melalui modal **`Pilih Barang`**. | L13 | high |
| **REQ-017** | Modal `Pilih Barang` menyediakan **pencarian by kode barang / nama barang**. | L15 | high |
| **REQ-018** | Modal `Pilih Barang` mendukung **multi-select** melalui **checkbox**. | L16 | high |
| **REQ-019** | Modal `Pilih Barang` menampilkan label **`Sudah Ditambahkan`** pada barang yang **sudah masuk ke armada terkait**. | L17 | high |
| **REQ-020** | Modal `Pilih Barang` menampilkan **counter jumlah barang terpilih**. | L18 | medium |
| **REQ-021** | Modal `Pilih Barang` memiliki button **`Batal`** (tutup tanpa perubahan) dan **`Simpan`** (tambahkan barang terpilih ke armada terkait). | L19 | high |
| **REQ-022** | Field yang **otomatis ter-draft dari Master Barang dan bersifat read-only**: `Kode SKU`, `Nama Barang`, `Kemasan`, `Kubikasi`, `Dimensi`, `Berat`. | L20 | high |
| **REQ-023** | Field **`Jumlah`** diinput user **per baris barang** dan bersifat **wajib**. | L21–L22 | high |
| **REQ-024** | Field **`Nilai Barang`** diinput user per baris barang; **hanya muncul dan wajib diisi** saat `Tambahkan Asuransi` pada **armada tersebut** dicentang. | L23 | high |
| **REQ-025** | Checkbox **`Tambahkan Asuransi`** bersifat **per armada** dan berlaku untuk **seluruh barang pada armada tersebut**; mencentangnya memunculkan kolom `Nilai Barang` dan menjadikannya wajib. | L24 | high |
| **REQ-026** | **`Nomor DO` per armada** bersifat **tidak wajib**, dapat diisi **lebih dari satu** dengan **pemisah koma**, dan **tampil sebagai chip**. | L25 | medium |
| **REQ-027** | Setiap baris barang dapat **dihapus** melalui **icon hapus** per baris. | L26 | medium |
| **REQ-028** | **Alert kapasitas armada** (Berat dan/atau Kubikasi melebihi kapasitas maksimal) bersifat **informasi saja dan TIDAK memblokir** — user tetap dapat lanjut ke step berikutnya. | L27 | high |
| **REQ-029** | Pesan alert kapasitas mengikuti kondisi: kubikasi saja → `Kubikasi melebihi kapasitas armada`; berat saja → `Berat melebihi kapasitas armada`; keduanya → `Kubikasi dan Berat melebihi kapasitas armada`. | L28–L30 | high |
| **REQ-030** | Bila field wajib (`Jumlah`, atau `Nilai Barang` saat asuransi aktif) tidak diisi → tampil **helper error** dan **border field berubah warna error**. | L31 | high |
| **REQ-031** | Step 2 menampilkan informasi **`Data Unit`** berisi `Jenis Armada` & `Jumlah Armada` yang **dibawa dari Step 1**. | L32 | medium |
| **REQ-032** | **Fungsi button Step 2** (`Batal` / `Simpan ke Draf` / `Sebelumnya` / `Selanjutnya`) berlaku identik dengan Step 2 TMS. | L39 | high |

**Acceptance Criteria**

- **REQ-016**
  - AC-016.1: Setiap blok `Armada n` memiliki tombol `Pilih Barang` yang membuka modal Master Barang.
  - AC-016.2: Tidak ada input teks bebas untuk nama/deskripsi barang di Step 2.
  - AC-016.3: Barang yang muncul di modal hanya berasal dari Master Barang aktif.
- **REQ-017**
  - AC-017.1: Mengetik **kode barang** memfilter daftar sesuai kode.
  - AC-017.2: Mengetik **nama barang** memfilter daftar sesuai nama.
  - AC-017.3: Pencarian bersifat *partial match* dan case-insensitive.
  - AC-017.4: Kata kunci tanpa hasil menampilkan empty state pencarian (bukan error).
- **REQ-018**
  - AC-018.1: Beberapa barang dapat dicentang sekaligus dalam satu sesi modal.
  - AC-018.2: Mencentang/melepas checkbox memperbarui counter secara real-time.
  - AC-018.3: Klik `Simpan` menambahkan **seluruh** barang terpilih ke tabel armada terkait dalam satu aksi.
- **REQ-019**
  - AC-019.1: Barang yang sudah ada pada armada terkait menampilkan label `Sudah Ditambahkan`.
  - AC-019.2: Label bersifat **kontekstual per armada** — barang yang sudah ada di Armada 1 **tidak** berlabel `Sudah Ditambahkan` saat modal dibuka dari Armada 2.
  - AC-019.3: Barang berlabel `Sudah Ditambahkan` tidak menghasilkan baris duplikat pada armada tersebut.
- **REQ-020**
  - AC-020.1: Counter menampilkan jumlah barang terpilih saat ini.
  - AC-020.2: Counter bernilai `0` (atau tidak menampilkan angka) saat belum ada barang dipilih.
  - AC-020.3: Counter ter-reset saat modal ditutup via `Batal` dan dibuka kembali.
- **REQ-021**
  - AC-021.1: `Batal` menutup modal **tanpa** menambahkan barang apa pun.
  - AC-021.2: `Simpan` menutup modal dan menambahkan barang terpilih ke tabel armada.
  - AC-021.3: `Simpan` tanpa barang terpilih tidak menambahkan baris apa pun (atau tombol dalam keadaan disabled).
- **REQ-022**
  - AC-022.1: Enam field tersebut terisi otomatis sesuai data Master Barang.
  - AC-022.2: Keenamnya **tidak dapat diedit** dari Step 2 (tidak ada input aktif).
  - AC-022.3: Perubahan data di Master Barang tidak mengubah order yang sudah disimpan (snapshot saat penambahan).
- **REQ-023**
  - AC-023.1: `Jumlah` dapat diinput manual per baris barang.
  - AC-023.2: `Jumlah` kosong menahan navigasi `Selanjutnya` dan memunculkan helper error (REQ-030).
  - AC-023.3: Mengubah `Jumlah` memperbarui `Total Kubikasi` & `Total Berat` armada terkait secara real-time.
- **REQ-024**
  - AC-024.1: Kolom `Nilai Barang` **tidak ditampilkan** saat `Tambahkan Asuransi` armada tersebut tidak dicentang.
  - AC-024.2: Kolom `Nilai Barang` **ditampilkan dan wajib** saat `Tambahkan Asuransi` dicentang.
  - AC-024.3: Melepas centang asuransi menyembunyikan kembali kolom `Nilai Barang` dan menghilangkan validasi wajibnya.
  - AC-024.4: Visibilitas kolom bersifat **per armada** — mencentang asuransi di Armada 1 tidak memunculkan kolom di Armada 2.
- **REQ-025**
  - AC-025.1: Checkbox `Tambahkan Asuransi` berada di level armada (header/blok armada), bukan per baris barang.
  - AC-025.2: Mencentangnya memberlakukan asuransi untuk **seluruh** baris barang pada armada tersebut.
  - AC-025.3: Status asuransi per armada terbawa ke Step 3 (komponen Asuransi) dan Step 4 (label `Diasuransikan`).
- **REQ-026**
  - AC-026.1: `Nomor DO` dapat dikosongkan dan user tetap dapat lanjut ke step berikutnya.
  - AC-026.2: Input `A, B, C` menghasilkan **tiga chip** terpisah.
  - AC-026.3: Setiap chip dapat dihapus secara individual.
  - AC-026.4: Nilai `Nomor DO` terbawa ke Step 4 Review dan Detail Order.
- **REQ-027**
  - AC-027.1: Setiap baris barang memiliki icon hapus.
  - AC-027.2: Menghapus satu baris tidak mempengaruhi baris lain maupun armada lain.
  - AC-027.3: Setelah baris dihapus, `Total Kubikasi` & `Total Berat` armada terkait ter-update.
  - AC-027.4: Menghapus seluruh baris mengembalikan armada ke kondisi kosong (empty state).
- **REQ-028**
  - AC-028.1: Saat kapasitas terlampaui, alert muncul namun tombol `Selanjutnya` **tetap aktif**.
  - AC-028.2: Order dengan kondisi kapasitas terlampaui **tetap dapat disimpan** sampai Step 4.
  - AC-028.3: Alert hilang otomatis saat `Jumlah` diturunkan hingga kembali di bawah kapasitas.
  - AC-028.4: Alert bergaya **informatif/peringatan**, bukan error yang memblokir.
- **REQ-029**
  - AC-029.1: Kubikasi > kapasitas & berat ≤ kapasitas → teks persis `Kubikasi melebihi kapasitas armada`.
  - AC-029.2: Berat > kapasitas & kubikasi ≤ kapasitas → teks persis `Berat melebihi kapasitas armada`.
  - AC-029.3: Keduanya melebihi → teks persis `Kubikasi dan Berat melebihi kapasitas armada` (satu pesan gabungan, bukan dua pesan terpisah).
  - AC-029.4: Tidak ada pelanggaran → tidak ada alert kapasitas yang dirender.
- **REQ-030**
  - AC-030.1: `Jumlah` kosong → helper error muncul di bawah field dan border field berubah warna error.
  - AC-030.2: `Nilai Barang` kosong saat asuransi aktif → helper error + border error.
  - AC-030.3: Setelah field diisi valid, helper error hilang dan border kembali normal.
  - AC-030.4: Validasi terpicu saat mencoba lanjut ke step berikutnya (dan/atau saat blur field).
- **REQ-031**
  - AC-031.1: Card/section `Data Unit` menampilkan `Jenis Armada` dan `Jumlah Armada`.
  - AC-031.2: Nilainya sama persis dengan input Step 1.
  - AC-031.3: Nilai ter-update bila Step 1 diubah, atau bila `Terapkan ke Order` dijalankan dari drawer (REQ-039).
- **REQ-032**
  - AC-032.1: `Sebelumnya` kembali ke Step 1 dengan data Step 1 tetap utuh.
  - AC-032.2: `Simpan ke Draf` menyimpan order dengan status `Isi Data Muatan`.
  - AC-032.3: `Batal` menampilkan konfirmasi lalu keluar tanpa menyimpan.
  - AC-032.4: `Selanjutnya` memvalidasi Step 2 lalu berpindah ke Step 3.

---

### R4. Step 2 — Floating Button & Logic Auto Stuffing

| ID | Requirement | Sumber | Prioritas |
|---|---|---|---|
| **REQ-033** | Step 2 menyediakan **floating button `Hitung Ulang Armada`** dan **`Visualisasi Terbaru`**. | L33 | high |
| **REQ-034** | Kedua button bersifat **floating** — posisinya **tetap mengikuti** saat halaman di-scroll. | L34 | medium |
| **REQ-035** | Kedua button **default menampilkan hanya ikon**, dan **menampilkan teks/label saat di-hover**. | L35 | medium |
| **REQ-036** | Button **`Hitung Ulang Armada` hanya dapat dijalankan** saat **minimal terdapat 1 data barang yang sudah diisi**. | L36 | high |
| **REQ-037** | **Distribusi barang antar armada mengikuti Logic Auto Stuffing**: kubikasi & berat **dioptimalkan mengisi 1 armada hingga maksimal**, baru berpindah ke armada berikutnya, berulang sampai muatan habis. | L37 | high |
| **REQ-038** | Pada tipe **Multipickup/Multidrop/Multipoint**, barang **dibagi rata antar alamat dalam 1 armada yang sama**; jika tidak dapat dibagi rata, **sisa yang lebih besar ditempatkan pada alamat pertama**. | L38 | high |

**Acceptance Criteria**

- **REQ-033**
  - AC-033.1: Kedua floating button tampil pada Step 2 saat add-on Auto Stuffing aktif.
  - AC-033.2: Klik `Hitung Ulang Armada` membuka drawer/panel rekomendasi (R5).
  - AC-033.3: Klik `Visualisasi Terbaru` membuka panel visualisasi muatan (REQ-046).
- **REQ-034**
  - AC-034.1: Setelah halaman di-scroll ke bawah, kedua button tetap terlihat pada posisi floating yang sama relatif terhadap viewport.
  - AC-034.2: Button tidak menutupi elemen aksi utama (`Selanjutnya`/`Sebelumnya`) sehingga keduanya tetap dapat diklik.
- **REQ-035**
  - AC-035.1: Dalam keadaan default (tanpa hover), button hanya menampilkan **ikon** tanpa teks.
  - AC-035.2: Saat di-hover, button menampilkan teks/label `Hitung Ulang Armada` / `Visualisasi Terbaru`.
  - AC-035.3: Label kembali tersembunyi saat pointer meninggalkan button.
  - AC-035.4: Label tetap dapat diakses oleh assistive technology (mis. `aria-label`) meskipun tersembunyi secara visual.
- **REQ-036**
  - AC-036.1: Saat **belum ada** data barang terisi, `Hitung Ulang Armada` dalam keadaan **disabled/tidak dapat dijalankan**.
  - AC-036.2: Setelah **minimal 1** baris barang terisi (SKU + `Jumlah`), button menjadi aktif.
  - AC-036.3: Menghapus seluruh barang mengembalikan button ke keadaan tidak dapat dijalankan.
  - AC-036.4: Bila button diklik dalam keadaan tidak memenuhi syarat, drawer **tidak** terbuka dan tidak ada proses kalkulasi yang berjalan.
- **REQ-037**
  - AC-037.1: Untuk muatan yang muat pada 1 armada, seluruh barang ditempatkan pada `Armada 1` dan armada berikutnya kosong.
  - AC-037.2: Untuk muatan melebihi 1 armada, `Armada 1` terisi hingga batas kapasitas (berat **atau** kubikasi, mana yang tercapai lebih dulu) sebelum `Armada 2` mulai terisi.
  - AC-037.3: Pola berlanjut ke `Armada 3..N` sampai seluruh muatan tertempatkan.
  - AC-037.4: Tidak ada armada berikutnya yang terisi selama armada sebelumnya belum mencapai batas optimalnya.
  - AC-037.5: Total `Jumlah` seluruh armada sesudah distribusi **sama** dengan total `Jumlah` yang diinput user (tidak ada barang hilang/tergandakan).
- **REQ-038**
  - AC-038.1: Barang yang habis dibagi (mis. 10 koli untuk 2 alamat) menghasilkan pembagian sama rata (5 dan 5).
  - AC-038.2: Barang yang tidak habis dibagi (mis. 7 koli untuk 2 alamat) menempatkan **sisa yang lebih besar pada alamat pertama** (4 dan 3).
  - AC-038.3: Untuk 3 alamat dengan 10 koli → alamat pertama menerima porsi terbesar (mis. 4, 3, 3).
  - AC-038.4: Pembagian dilakukan **dalam 1 armada yang sama** (tidak melintasi armada).
  - AC-038.5: Pada tipe `Normal`, aturan pembagian antar alamat tidak berlaku (hanya satu pasang alamat).

---

### R5. Drawer `Hitung Ulang Armada` & Panel `Visualisasi Terbaru`

| ID | Requirement | Sumber | Prioritas |
|---|---|---|---|
| **REQ-039** | Drawer `Hitung Ulang Armada` menampilkan **`Total Kubikasi`** & **`Total Berat`** yang dihitung dari data barang yang diinput. | L43 | high |
| **REQ-040** | Drawer menampilkan **`Jenis Pengiriman`** yang dibawa dari Step 1. | L44 | medium |
| **REQ-041** | Drawer menampilkan **rekomendasi 3 teratas armada** (dari Logic Auto Stuffing) sesuai barang yang diinput, masing-masing dengan indikator **`Berat Terpakai`** & **`Ruang Terpakai`**, serta label **`Paling Efisien`** pada rekomendasi terbaik. | L45 | high |
| **REQ-042** | Pada drawer, field **`Jenis Armada`** (via modal `Pilih Jenis Armada`) dan **`Jumlah Armada`** (via input/stepper) **dapat diubah**. | L46 | high |
| **REQ-043** | Drawer menampilkan **Visualisasi Muatan (3D) per armada**, yang **memperbarui** saat `Jenis Armada` / `Jumlah Armada` diubah. | L47 | high |
| **REQ-044** | Button **`Terapkan ke Order`** pada card menerapkan **`Jenis Armada`**, **`Jumlah Armada`**, dan **penempatan barang** ke order. | L48 | high |
| **REQ-045** | Saat `Jenis`/`Jumlah Armada` diubah lalu diterapkan → **data pada Step 1** dan **informasi yang dibawa ke Step 2** turut berubah. | L49 | high |
| **REQ-046** | Button **`Batal`** pada drawer **menutup panel tanpa menerapkan perubahan** apa pun. | L50 | high |
| **REQ-047** | Floating button **`Visualisasi Terbaru`** menampilkan panel visualisasi muatan sesuai **`Jenis` & `Jumlah Armada` terkini**, **tanpa mengubah** pilihan armada. | L51 | high |

**Acceptance Criteria**

- **REQ-039**
  - AC-039.1: `Total Kubikasi` = Σ(kubikasi satuan × `Jumlah`) seluruh barang yang diinput.
  - AC-039.2: `Total Berat` = Σ(berat satuan × `Jumlah`) seluruh barang yang diinput.
  - AC-039.3: Nilai keduanya ter-update bila drawer ditutup, data barang diubah, lalu drawer dibuka kembali.
- **REQ-040**
  - AC-040.1: `Jenis Pengiriman` yang ditampilkan sama dengan nilai pada Step 1.
  - AC-040.2: Field bersifat informatif/read-only pada drawer.
- **REQ-041**
  - AC-041.1: Drawer menampilkan **maksimal 3** kartu rekomendasi armada.
  - AC-041.2: Setiap kartu menampilkan indikator `Berat Terpakai` dan `Ruang Terpakai`.
  - AC-041.3: **Tepat satu** kartu memiliki label `Paling Efisien`, yaitu rekomendasi terbaik (urutan pertama).
  - AC-041.4: Rekomendasi berubah bila data barang berubah secara signifikan.
  - AC-041.5: Kartu rekomendasi dapat dipilih dan mengisi `Jenis Armada` & `Jumlah Armada` pada drawer.
- **REQ-042**
  - AC-042.1: Klik field `Jenis Armada` membuka modal `Pilih Jenis Armada`.
  - AC-042.2: Memilih jenis armada dari modal memperbarui field `Jenis Armada` pada drawer.
  - AC-042.3: `Jumlah Armada` dapat diubah via input angka dan/atau stepper `−`/`+`.
  - AC-042.4: `Jumlah Armada` tidak dapat diturunkan di bawah `1`.
- **REQ-043**
  - AC-043.1: Panel visualisasi menampilkan muatan **per armada** (tab/selector armada bila > 1 armada).
  - AC-043.2: Mengubah `Jenis Armada` memperbarui dimensi/kapasitas pada visualisasi.
  - AC-043.3: Mengubah `Jumlah Armada` memperbarui jumlah armada yang divisualisasikan.
  - AC-043.4: Pembaruan terjadi tanpa perlu menutup & membuka ulang drawer.
- **REQ-044**
  - AC-044.1: `Terapkan ke Order` menulis `Jenis Armada` dan `Jumlah Armada` hasil drawer ke order.
  - AC-044.2: `Terapkan ke Order` juga menerapkan **penempatan barang** hasil Auto Stuffing ke masing-masing armada.
  - AC-044.3: Setelah diterapkan, drawer tertutup dan Step 2 menampilkan hasil penempatan terbaru.
  - AC-044.4: Total `Jumlah` barang sesudah penerapan sama dengan sebelum penerapan.
- **REQ-045**
  - AC-045.1: Kembali ke Step 1 menunjukkan `Jenis Armada` & `Jumlah Armada` hasil penerapan (bukan nilai lama).
  - AC-045.2: Card `Data Unit` pada Step 2 (REQ-031) menampilkan nilai yang sama dengan hasil penerapan.
  - AC-045.3: Jumlah blok `Armada n` yang dirender di Step 2 sesuai `Jumlah Armada` baru.
  - AC-045.4: Kapasitas maksimal yang dipakai alert kapasitas (REQ-028/029) mengikuti `Jenis Armada` baru.
- **REQ-046**
  - AC-046.1: `Batal` menutup drawer.
  - AC-046.2: Perubahan `Jenis Armada`/`Jumlah Armada` yang dilakukan di drawer **tidak** tersimpan ke order.
  - AC-046.3: Penempatan barang pada Step 2 tetap sama seperti sebelum drawer dibuka.
  - AC-046.4: Membuka kembali drawer menampilkan nilai sesuai kondisi order terkini (bukan nilai yang dibatalkan).
- **REQ-047**
  - AC-047.1: Panel `Visualisasi Terbaru` menampilkan muatan sesuai `Jenis` & `Jumlah Armada` yang **sedang berlaku** pada order.
  - AC-047.2: Panel **tidak** menyediakan field pengubah `Jenis Armada`/`Jumlah Armada`, kartu rekomendasi, maupun `Terapkan ke Order`.
  - AC-047.3: Menutup panel tidak mengubah data order apa pun.

---

### R6. Step 3 — Vendor & Harga

| ID | Requirement | Sumber | Prioritas |
|---|---|---|---|
| **REQ-048** | Step 3 **sama dengan Step 3 Order FTL di TMS**, memuat: field `Pilihan Vendor`, inputan `Tanggal Permintaan Muat`, inputan `Harga`, `Waktu Perjalanan`, ringkasan alamat, dan komponen harga opsional. | L54–L60 | high |
| **REQ-049** | **`Waktu Perjalanan` memiliki 2 kondisi**: **textfield** bila rute **belum ada** di master, dan **text-only** (read-only) bila rute **sudah ada** di master. | L58 | high |
| **REQ-050** | **Ringkasan alamat** ditampilkan sebagai **label + text link** untuk tipe pengiriman multi (Multipickup/Multidrop/Multipoint). | L59 | medium |
| **REQ-051** | **Komponen harga bersifat opsional** melalui checkbox **`Gunakan Komponen Harga`**. | L60 | medium |
| **REQ-052** | **Komponen Asuransi** mengikuti data Step 2: saat terdapat armada yang diasuransikan, nilai **Asuransi = persentase × Total Nilai Barang** turut dihitung ke **Total Harga**, di samping **PPN** & **PPh**. | L61 | high |
| **REQ-053** | **Validasi field wajib** dan **fungsi button** (`Batal`/`Simpan ke Draf`/`Sebelumnya`/`Selanjutnya`) pada Step 3 **identik dengan TMS**. | L62 | high |

**Acceptance Criteria**

- **REQ-048**
  - AC-048.1: Field `Pilihan Vendor` dapat dipilih dari master vendor.
  - AC-048.2: `Tanggal Permintaan Muat` dapat diinput sesuai format tanggal/waktu yang ditentukan.
  - AC-048.3: `Harga` dapat diinput sebagai nilai mata uang.
  - AC-048.4: Struktur & label Step 3 sama dengan Order FTL TMS.
- **REQ-049**
  - AC-049.1: Rute (asal–tujuan) **belum** ada di master → `Waktu Perjalanan` dirender sebagai **textfield yang dapat diisi**.
  - AC-049.2: Rute **sudah** ada di master → `Waktu Perjalanan` dirender sebagai **teks read-only** dengan nilai dari master.
  - AC-049.3: Mengubah drop point asal/tujuan di Step 1 dapat mengubah kondisi ini saat kembali ke Step 3.
- **REQ-050**
  - AC-050.1: Tipe `Normal` → ringkasan alamat ditampilkan langsung tanpa text link.
  - AC-050.2: Tipe multi → ditampilkan **label + text link** yang membuka rincian daftar alamat.
  - AC-050.3: Rincian yang ditampilkan konsisten dengan alamat yang diinput di Step 1.
- **REQ-051**
  - AC-051.1: Checkbox `Gunakan Komponen Harga` dalam keadaan **tidak tercentang** secara default.
  - AC-051.2: Mencentangnya memunculkan input komponen harga (mis. `PPN`, `PPh`, dan `Asuransi` bila relevan).
  - AC-051.3: Tanpa mencentangnya, `Total Harga` = `Harga` yang diinput.
- **REQ-052**
  - AC-052.1: Komponen `Asuransi` **muncul** hanya bila terdapat **minimal satu** armada dengan `Tambahkan Asuransi` tercentang di Step 2.
  - AC-052.2: Nilai Asuransi = `persentase × Total Nilai Barang`.
  - AC-052.3: `Total Harga` memperhitungkan `Asuransi` bersama `PPN` (penambah) dan `PPh` (pengurang).
  - AC-052.4: Tanpa armada yang diasuransikan, komponen `Asuransi` **tidak** dirender dan tidak mempengaruhi `Total Harga`.
  - AC-052.5: Mengubah `Nilai Barang` di Step 2 lalu kembali ke Step 3 memperbarui nilai Asuransi & `Total Harga`.
- **REQ-053**
  - AC-053.1: Klik `Selanjutnya` dengan field wajib Step 3 kosong menahan navigasi dan menampilkan pesan validasi.
  - AC-053.2: `Sebelumnya` kembali ke Step 2 dengan data barang tetap utuh.
  - AC-053.3: `Simpan ke Draf` menyimpan order dengan status `Isi Data Vendor`.
  - AC-053.4: `Batal` menampilkan konfirmasi lalu keluar tanpa menyimpan.

---

### R7. Step 4 — Review

| ID | Requirement | Sumber | Prioritas |
|---|---|---|---|
| **REQ-054** | Step 4 menampilkan **ringkasan seluruh data Step 1–3 secara read-only**, sama dengan TMS. | L65 | high |
| **REQ-055** | Bagian **Data Barang mengikuti struktur Step 2 OMS**, menampilkan: `Kode SKU`, `Nama Barang`, `Kemasan`, `Kubikasi`/`Dimensi`, `Berat`, `Jumlah`, dan `Nilai Barang` (untuk armada yang diasuransikan). | L66 | high |
| **REQ-056** | Terdapat label **`Diasuransikan` per armada** pada armada yang diasuransikan. | L66 | medium |
| **REQ-057** | Terdapat **button pada card Data Barang** yang saat diklik menampilkan **pop up visualisasi muatan** (turunan add-on Auto Stuffing). | L67 | high |
| **REQ-058** | **Fungsi button Step 4** (`Batal`/`Simpan ke Draf`/`Sebelumnya`/`Simpan`) identik dengan TMS; **`Simpan` mengubah status order menjadi `Menunggu Penugasan`**. | L68 | high |

**Acceptance Criteria**

- **REQ-054**
  - AC-054.1: Seluruh section Step 1–3 tampil pada Step 4 (data pengiriman, pengirim, penerima, data barang, vendor & harga).
  - AC-054.2: Seluruh field pada Step 4 bersifat **read-only** (tidak ada input aktif).
  - AC-054.3: Nilai yang ditampilkan identik dengan input pada step asalnya.
- **REQ-055**
  - AC-055.1: Tabel Data Barang memuat kolom `Kode SKU`, `Nama Barang`, `Kemasan`, `Kubikasi`/`Dimensi`, `Berat`, `Jumlah`.
  - AC-055.2: Kolom `Nilai Barang` **hanya** tampil pada armada yang diasuransikan.
  - AC-055.3: Data dikelompokkan per `Armada n`, dan (pada tipe multi) per alamat/kombinasi alamat sesuai struktur Step 2.
  - AC-055.4: Isi tabel identik dengan hasil penempatan pada Step 2 (tidak ada penggabungan/perubahan baris).
- **REQ-056**
  - AC-056.1: Armada dengan `Tambahkan Asuransi` tercentang menampilkan label `Diasuransikan`.
  - AC-056.2: Armada tanpa asuransi **tidak** menampilkan label tersebut.
- **REQ-057**
  - AC-057.1: Card `Data Barang` memuat button visualisasi muatan.
  - AC-057.2: Klik button membuka **pop up** visualisasi muatan (bukan navigasi ke halaman lain).
  - AC-057.3: Pop up menampilkan visualisasi sesuai `Jenis`/`Jumlah Armada` dan penempatan barang order tersebut.
  - AC-057.4: Menutup pop up mengembalikan user ke Step 4 tanpa perubahan data.
  - AC-057.5: Button tidak dirender bila add-on Auto Stuffing tidak aktif (REQ-005).
- **REQ-058**
  - AC-058.1: `Sebelumnya` kembali ke Step 3 dengan data tetap utuh.
  - AC-058.2: `Simpan ke Draf` menyimpan order dengan status `Review Order`.
  - AC-058.3: `Batal` menampilkan konfirmasi lalu keluar tanpa menyimpan.
  - AC-058.4: `Simpan` menyimpan order dan mengubah status menjadi **`Menunggu Penugasan`**.
  - AC-058.5: Setelah `Simpan`, order muncul di Daftar Order dengan status `Menunggu Penugasan`.

---

### R8. Status Order

| ID | Requirement | Sumber | Prioritas |
|---|---|---|---|
| **REQ-059** | Terdapat **9 status** pada Order FTL: `Isi Data Pengiriman`, `Isi Data Muatan`, `Isi Data Vendor`, `Review Order`, `Menunggu Penugasan`, `Ditugaskan`, `Proses Pengiriman`, `Selesai`, `Dibatalkan`. | L71–L80 | high |
| **REQ-060** | **Status 1–4** (`Isi Data Pengiriman` s.d. `Review Order`) merupakan **kondisi draft**, tersimpan otomatis melalui aksi **`Simpan ke Draf`** pada **step manapun**. | L81 | high |

**Definisi Status**

| # | Status | Definisi (sesuai spec) |
|---|---|---|
| 1 | `Isi Data Pengiriman` | Pengisian data order belum selesai di step `Data Pengiriman`. |
| 2 | `Isi Data Muatan` | Pengisian data order belum selesai di step `Data Barang`. |
| 3 | `Isi Data Vendor` | Pengisian data order belum selesai di step `Vendor & Harga`. |
| 4 | `Review Order` | Seluruh step sudah terisi namun order belum di-submit (masih di step Review). |
| 5 | `Menunggu Penugasan` | Seluruh data order sudah lengkap & disubmit, menunggu proses penugasan vendor. |
| 6 | `Ditugaskan` | Vendor sudah melakukan penugasan. |
| 7 | `Proses Pengiriman` | Status penugasan armada = `Dalam Perjalanan`. |
| 8 | `Selesai` | Seluruh armada sudah selesai bongkar (status penugasan `Selesai`). |
| 9 | `Dibatalkan` | Order dibatalkan oleh admin shipper. |

**Acceptance Criteria**

- **REQ-059**
  - AC-059.1: Kolom `Status` pada Daftar Order menampilkan salah satu dari 9 status tersebut.
  - AC-059.2: Status yang sama ditampilkan konsisten pada Detail Order.
  - AC-059.3: Order yang keluar dari wizard di Step 1 tanpa menyelesaikannya berstatus `Isi Data Pengiriman`; di Step 2 → `Isi Data Muatan`; di Step 3 → `Isi Data Vendor`; di Step 4 → `Review Order`.
  - AC-059.4: `Simpan` pada Step 4 → `Menunggu Penugasan`; setelah vendor menugaskan → `Ditugaskan`; armada dalam perjalanan → `Proses Pengiriman`; seluruh armada selesai bongkar → `Selesai`.
  - AC-059.5: Pembatalan order menghasilkan status `Dibatalkan`.
- **REQ-060**
  - AC-060.1: Tombol `Simpan ke Draf` tersedia pada **setiap** step wizard (Step 1–4).
  - AC-060.2: Order draft muncul di Daftar Order dengan status sesuai step terakhir yang belum selesai.
  - AC-060.3: Aksi `Lanjutkan Pengisian` membuka wizard pada step yang sesuai dengan seluruh data ter-restore (termasuk hasil penempatan Auto Stuffing).
  - AC-060.4: Draft yang di-restore **tidak** dihitung ulang otomatis oleh Auto Stuffing (penempatan tersimpan apa adanya).

---

### R9. Hak Edit Order FTL

| ID | Requirement | Sumber | Prioritas |
|---|---|---|---|
| **REQ-061** | **Shipper dapat mengubah data order** selama status masih dalam **rentang draft** (`Isi Data Pengiriman` s.d. `Review Order`) **hingga `Menunggu Penugasan`**. | L84 | high |
| **REQ-062** | **Shipper tidak dapat lagi mengubah data order** setelah status berubah menjadi **`Ditugaskan`** (dan status setelahnya). | L85 | high |
| **REQ-063** | Pada halaman Edit Order, field **`Jenis Pengiriman`** dan **`Tipe Pengiriman`** bersifat **locked/read-only** dan tidak dapat diubah. | L86 | high |
| **REQ-064** | Field **`Jenis Armada`, `Jumlah Armada`, `Data Pengirim`, `Data Penerima`, `Data Barang`, `Vendor & Harga`** tetap dapat diubah selama order berstatus dapat diedit. | L87 | high |
| **REQ-065** | Fungsi button pada Edit Order: **`Batal`** (membatalkan pengisian data → **pop up konfirmasi**) dan **`Simpan`** (menyelesaikan proses pengeditan → **pop up konfirmasi**). | L88–L90 | high |

**Acceptance Criteria**

- **REQ-061**
  - AC-061.1: Order berstatus `Menunggu Penugasan` menampilkan aksi `Edit` pada Daftar Order dan/atau tombol `Edit Order` pada Detail Order.
  - AC-061.2: Order berstatus draft dapat dilanjutkan pengisiannya via `Lanjutkan Pengisian`.
  - AC-061.3: Perubahan yang disimpan tercermin pada Detail Order.
- **REQ-062**
  - AC-062.1: Order berstatus `Ditugaskan` **tidak** menampilkan aksi `Edit`.
  - AC-062.2: Order berstatus `Proses Pengiriman`, `Selesai`, dan `Dibatalkan` juga tidak dapat diedit.
  - AC-062.3: Mengakses URL halaman Edit secara langsung untuk order yang tidak boleh diedit **ditolak** (redirect/pesan error), bukan sekadar disembunyikan di UI.
- **REQ-063**
  - AC-063.1: `Jenis Pengiriman` pada Edit Order ditampilkan sebagai teks read-only/disabled.
  - AC-063.2: `Tipe Pengiriman` pada Edit Order ditampilkan sebagai teks read-only/disabled.
  - AC-063.3: Tidak ada jalur UI untuk mengubah kedua field tersebut dari halaman Edit.
- **REQ-064**
  - AC-064.1: `Jenis Armada` & `Jumlah Armada` dapat diubah dan tersimpan.
  - AC-064.2: `Data Pengirim` & `Data Penerima` dapat diubah dan tersimpan.
  - AC-064.3: `Data Barang` dapat diubah (tambah/hapus barang, ubah `Jumlah`/`Nilai Barang`) dan tersimpan.
  - AC-064.4: `Vendor & Harga` dapat diubah dan `Total Harga` terhitung ulang.
  - AC-064.5: Mengubah `Jumlah Armada` di Edit Order menyesuaikan jumlah blok armada pada section Data Barang.
- **REQ-065**
  - AC-065.1: Klik `Batal` menampilkan **pop up konfirmasi** sebelum meninggalkan halaman.
  - AC-065.2: Konfirmasi `Batal` membuang perubahan; membatalkan konfirmasi mengembalikan user ke form dengan perubahan tetap ada.
  - AC-065.3: Klik `Simpan` menampilkan **pop up konfirmasi** sebelum menyimpan.
  - AC-065.4: Konfirmasi `Simpan` menyimpan perubahan dan mengarahkan user kembali (Detail/Daftar Order) dengan data terbaru.

---

### R10. Pembatalan Order

| ID | Requirement | Sumber | Prioritas |
|---|---|---|---|
| **REQ-066** | Order dapat dibatalkan selama status berada dalam **rentang draft hingga `Ditugaskan`**; **tidak dapat dibatalkan** setelah status `Proses Pengiriman`. | L94 | high |
| **REQ-067** | Pembatalan order dilakukan oleh **admin shipper**, **bukan** oleh vendor. | L95 | high |
| **REQ-068** | Field **`Alasan Pembatalan` wajib diisi** saat melakukan pembatalan. | L96 | high |

**Acceptance Criteria**

- **REQ-066**
  - AC-066.1: Aksi `Batalkan Order` tersedia pada status `Isi Data Pengiriman`, `Isi Data Muatan`, `Isi Data Vendor`, `Review Order`, `Menunggu Penugasan`, dan `Ditugaskan`.
  - AC-066.2: Aksi `Batalkan Order` **tidak** tersedia pada status `Proses Pengiriman`, `Selesai`, dan `Dibatalkan`.
  - AC-066.3: Pembatalan yang berhasil mengubah status menjadi `Dibatalkan`.
  - AC-066.4: Order berstatus `Dibatalkan` tidak lagi dapat diedit maupun dibatalkan ulang.
- **REQ-067**
  - AC-067.1: Akun dengan peran admin shipper dapat mengakses & mengeksekusi `Batalkan Order`.
  - AC-067.2: Akun vendor **tidak** memiliki aksi `Batalkan Order` pada order tersebut.
  - AC-067.3: Upaya pembatalan dari akun vendor (mis. melalui pemanggilan langsung) ditolak.
- **REQ-068**
  - AC-068.1: Form/pop up pembatalan memuat field `Alasan Pembatalan` bertanda wajib.
  - AC-068.2: Submit dengan `Alasan Pembatalan` kosong ditolak dan menampilkan pesan validasi.
  - AC-068.3: Setelah alasan diisi, pembatalan dapat diproses.
  - AC-068.4: Alasan pembatalan tersimpan dan dapat dilihat pada `Riwayat Pembatalan`/Detail Order.

---

### R11. Aksi pada Daftar Order FTL

| ID | Requirement | Sumber | Prioritas |
|---|---|---|---|
| **REQ-069** | **Aksi per baris menyesuaikan status order** sesuai matriks di bawah. | L99–L102 | high |
| **REQ-070** | Pada status `Ditugaskan`, aksi **`Edit` TIDAK tersedia**, namun tersedia aksi **`Lihat No. Perjalanan`**. | L102 | high |
| **REQ-071** | Tombol **`Riwayat Pembatalan`** pada **toolbar** halaman Daftar Order menampilkan **daftar seluruh order yang pernah dibatalkan** — **terpisah** dari aksi per-baris **`Riwayat Perubahan`** yang menampilkan histori perubahan order tertentu. | L103 | medium |

**Matriks Status → Aksi**

| Status | Detail | Lanjutkan Pengisian | Edit | Batalkan Order | Riwayat Perubahan | Lihat No. Perjalanan |
|---|:--:|:--:|:--:|:--:|:--:|:--:|
| `Isi Data Pengiriman` | ✔ | ✔ | ✘ | ✔ | ✔ | ✘ |
| `Isi Data Muatan` | ✔ | ✔ | ✘ | ✔ | ✔ | ✘ |
| `Isi Data Vendor` | ✔ | ✔ | ✘ | ✔ | ✔ | ✘ |
| `Review Order` | ✔ | ✔ | ✘ | ✔ | ✔ | ✘ |
| `Menunggu Penugasan` | ✔ | ✘ | ✔ | ✔ | ✔ | ✘ |
| `Ditugaskan` | ✔ | ✘ | ✘ | ✔ | ✔ | ✔ |
| `Proses Pengiriman` (INF) | ✔ | ✘ | ✘ | ✘ | ✔ | ✔ |
| `Selesai` (INF) | ✔ | ✘ | ✘ | ✘ | ✔ | ✔ |
| `Dibatalkan` (INF) | ✔ | ✘ | ✘ | ✘ | ✔ | ✘ |

> Baris bertanda **(INF)** adalah inferensi — spec hanya merinci 3 kelompok status pertama. Lihat **ASM-016**.

**Acceptance Criteria**

- **REQ-069**
  - AC-069.1: Menu aksi (`...`) pada baris order menampilkan opsi persis sesuai matriks di atas untuk masing-masing status.
  - AC-069.2: Opsi yang tidak berlaku **tidak dirender** (bukan sekadar disabled), atau minimal tidak dapat dieksekusi.
  - AC-069.3: Setiap aksi mengarahkan ke halaman/modal yang benar.
- **REQ-070**
  - AC-070.1: Order berstatus `Ditugaskan` — menu aksi tidak memuat `Edit`.
  - AC-070.2: Order berstatus `Ditugaskan` — menu aksi memuat `Lihat No. Perjalanan`.
  - AC-070.3: Order berstatus `Menunggu Penugasan` — menu aksi memuat `Edit` namun **tidak** memuat `Lihat No. Perjalanan`.
- **REQ-071**
  - AC-071.1: Tombol `Riwayat Pembatalan` berada pada **toolbar** halaman Daftar Order (bukan di menu aksi baris).
  - AC-071.2: Klik `Riwayat Pembatalan` menampilkan daftar **seluruh** order yang pernah dibatalkan.
  - AC-071.3: Aksi `Riwayat Perubahan` pada baris menampilkan histori perubahan **order tersebut saja**.
  - AC-071.4: Order yang baru dibatalkan langsung muncul pada `Riwayat Pembatalan`.

---

### R12. No. Perjalanan

| ID | Requirement | Sumber | Prioritas |
|---|---|---|---|
| **REQ-072** | **Nomor Perjalanan digunakan untuk pengecekan pada public tracking** — pengirim/penerima dapat mengetahui progress perjalanan armada/kontainer yang dipesan. | L106 | medium |
| **REQ-073** | Nomor Perjalanan **di-generate otomatis oleh sistem** dan **melekat pada armada/kontainer**; **jumlahnya menyesuaikan jumlah armada/kontainer** yang dipesan. | L107 | high |
| **REQ-074** | No. Perjalanan **hanya tampil untuk jenis pengiriman FTL & FCL**. | L108 | high |
| **REQ-075** | Aksi **`Lihat No. Perjalanan`** pada action menu order **baru tampil setelah proses penugasan dilakukan** (status `Ditugaskan`). | L109 | high |
| **REQ-076** | Klik aksi tersebut menampilkan **pop up `Data No. Perjalanan`** yang menampilkan **per armada/kontainer**: `No. Perjalanan` (hasil generate sistem), `Nopol`/`No. Kontainer`, dan `Jenis Armada`/`Jenis Kontainer`. | L110 | high |
| **REQ-077** | Pada pop up, `No. Perjalanan` dilengkapi **icon copy** untuk menyalin nomor perjalanan. | L111 | medium |
| **REQ-078** | Selain melalui action menu, **No. Perjalanan juga dapat dilihat pada halaman Detail Order**. | L112 | medium |

**Acceptance Criteria**

- **REQ-072**
  - AC-072.1: Nomor perjalanan yang di-generate dapat digunakan sebagai kunci pencarian pada public tracking.
  - AC-072.2: Hasil tracking menampilkan progress perjalanan armada/kontainer terkait.
- **REQ-073**
  - AC-073.1: User **tidak** dapat menginput/mengedit nomor perjalanan secara manual.
  - AC-073.2: Order dengan `Jumlah Armada` = N menghasilkan **N** nomor perjalanan.
  - AC-073.3: Setiap nomor perjalanan **unik** dan terikat pada satu armada/kontainer.
  - AC-073.4: Mengubah `Jumlah Armada` sebelum penugasan menyesuaikan jumlah nomor perjalanan yang dihasilkan.
- **REQ-074**
  - AC-074.1: Order `FTL` menampilkan No. Perjalanan.
  - AC-074.2: Order `FCL` menampilkan No. Perjalanan.
  - AC-074.3: Order jenis lain **tidak** menampilkan aksi maupun informasi No. Perjalanan.
- **REQ-075**
  - AC-075.1: Sebelum penugasan (status ≤ `Menunggu Penugasan`), aksi `Lihat No. Perjalanan` **tidak** tersedia.
  - AC-075.2: Setelah status menjadi `Ditugaskan`, aksi `Lihat No. Perjalanan` muncul pada action menu.
- **REQ-076**
  - AC-076.1: Pop up berjudul `Data No. Perjalanan`.
  - AC-076.2: Terdapat satu baris per armada/kontainer.
  - AC-076.3: Setiap baris menampilkan `No. Perjalanan`, `Nopol`/`No. Kontainer`, dan `Jenis Armada`/`Jenis Kontainer`.
  - AC-076.4: Jumlah baris sama dengan jumlah armada/kontainer pada order (REQ-073).
- **REQ-077**
  - AC-077.1: Setiap `No. Perjalanan` disertai icon copy.
  - AC-077.2: Klik icon copy menyalin nomor perjalanan ke clipboard.
  - AC-077.3: Terdapat umpan balik visual setelah penyalinan (mis. toast/tooltip `Tersalin`).
- **REQ-078**
  - AC-078.1: Halaman Detail Order menampilkan informasi No. Perjalanan untuk order yang sudah ditugaskan.
  - AC-078.2: Nilai yang ditampilkan identik dengan isi pop up `Data No. Perjalanan`.

---

### Ringkasan Traceability

| Baris spec | REQ terkait |
|---|---|
| L3 (acuan TMS, 4 step, manual/batch) | REQ-001, REQ-002, REQ-003 |
| L4 (pembeda Step 2) | REQ-004 |
| L5 (entitlement add-on, FTL & FCL) | REQ-005, REQ-006 |
| L6 (logic pakai tools existing) | REQ-007 |
| L7 (penyesuaian Step 4 + pop up visualisasi) | REQ-008 |
| L10 (Step 1 identik TMS) | REQ-009 s.d. REQ-015 |
| L13 (Master Barang via modal) | REQ-016 |
| L15–L19 (isi modal Pilih Barang) | REQ-017, REQ-018, REQ-019, REQ-020, REQ-021 |
| L20 (field read-only master) | REQ-022 |
| L21–L23 (Jumlah, Nilai Barang) | REQ-023, REQ-024 |
| L24 (checkbox asuransi per armada) | REQ-025 |
| L25 (Nomor DO) | REQ-026 |
| L26 (hapus baris) | REQ-027 |
| L27–L30 (alert kapasitas) | REQ-028, REQ-029 |
| L31 (helper error & border error) | REQ-030 |
| L32 (Data Unit) | REQ-031 |
| L33–L35 (floating button) | REQ-033, REQ-034, REQ-035 |
| L36 (syarat Hitung Ulang) | REQ-036 |
| L37 (logic distribusi antar armada) | REQ-037 |
| L38 (pembagian antar alamat) | REQ-038 |
| L39 (button Step 2) | REQ-032 |
| L43–L47 (isi drawer) | REQ-039 s.d. REQ-043 |
| L48–L49 (Terapkan ke Order) | REQ-044, REQ-045 |
| L50 (Batal drawer) | REQ-046 |
| L51 (Visualisasi Terbaru) | REQ-047 |
| L54–L60 (Step 3 identik TMS) | REQ-048, REQ-049, REQ-050, REQ-051 |
| L61 (komponen Asuransi) | REQ-052 |
| L62 (validasi & button Step 3) | REQ-053 |
| L65 (review read-only) | REQ-054 |
| L66 (struktur Data Barang + label) | REQ-055, REQ-056 |
| L67 (button visualisasi Step 4) | REQ-008, REQ-057 |
| L68 (button Step 4 & status Simpan) | REQ-058 |
| L71–L80 (9 status) | REQ-059 |
| L81 (draft & Simpan ke Draf) | REQ-060 |
| L84–L87 (hak edit) | REQ-061 s.d. REQ-064 |
| L88–L90 (button Edit Order) | REQ-065 |
| L94–L96 (pembatalan) | REQ-066, REQ-067, REQ-068 |
| L99–L102 (aksi per status) | REQ-069, REQ-070 |
| L103 (Riwayat Pembatalan vs Perubahan) | REQ-071 |
| L106–L112 (No. Perjalanan) | REQ-072 s.d. REQ-078 |
| Inferensi | REQ-013 (minimal baris), matriks status→aksi baris INF |

---

## Validation Rules

> **Catatan:** spec **tidak** mencantumkan panjang min/maks maupun range nilai untuk field mana pun. Nilai batas di bawah adalah **aturan wajar hasil inferensi** — lihat **ASM-005**.

### V1. Step 1 — Data Pengiriman

| Field | Wajib | Tipe/Format | Aturan |
|---|:--:|---|---|
| `Jenis Armada` | Ya | Dropdown (Master Armada) | Harus dipilih dari master. Menentukan **kapasitas Berat & Kubikasi maksimal** per armada (dasar alert REQ-028/029). |
| `Jumlah Armada` | Ya | Integer | Minimal `1`; hanya bilangan bulat positif. Menentukan jumlah blok `Armada n` di Step 2. Dapat berubah akibat `Terapkan ke Order` (REQ-045). |
| `Tipe Pengiriman` | Ya | Dropdown | Nilai valid **tepat 4**: `Normal`, `Multipickup`, `Multidrop`, `Multipoint`. Menentukan struktur alamat & struktur Step 2. |
| `Drop Point Asal` | Ya | Dropdown (Master Droppoint) | Memicu auto-draft data wilayah/alamat asal (REQ-011). |
| `Drop Point Tujuan` | Ya | Dropdown (Master Droppoint) | Memicu auto-draft data wilayah/alamat tujuan. |
| Data wilayah asal/tujuan (Provinsi, Kota/Kab., Kecamatan, Desa/Kelurahan, Kode Pos, Alamat) | — | **Read-only** (auto-draft) | Tidak dapat diedit manual. Kode Pos 5 digit. |
| `Pengirim` / `Penerima` | Ya | Dropdown | Dari master partner/perusahaan. |
| `PIC Pengirim` / `PIC Penerima` | Ya | Text | Nama PIC. Panjang wajar 1–100 karakter (INF). |
| `No. WhatsApp PIC` | Ya | Numerik | Hanya digit, diawali `0`. Panjang wajar **10–15 digit** (INF). |
| `Catatan` | Tidak | Textarea | Opsional; ditampilkan `-` bila kosong. |
| Jumlah baris alamat | — | Aturan struktur | `Normal` = 1 pengirim + 1 penerima. `Multipickup` ≥ 2 pengirim. `Multidrop` ≥ 2 penerima. `Multipoint` ≥ 2 pengirim **dan** ≥ 2 penerima (REQ-013, INF). |

### V2. Step 2 — Data Barang

| Field / Elemen | Wajib | Tipe/Format | Aturan |
|---|:--:|---|---|
| `Data Unit` (`Jenis Armada` + `Jumlah Armada`) | — | Read-only | Informatif, dibawa dari Step 1 (REQ-031). |
| Baris barang | Ya (min. 1 per order) | Dari Master Barang via modal | Tidak ada input SKU/deskripsi bebas. Duplikat SKU per armada dicegah (label `Sudah Ditambahkan`, REQ-019). |
| `Kode SKU`, `Nama Barang`, `Kemasan`, `Kubikasi`, `Dimensi`, `Berat` | — | **Read-only** (auto-draft Master Barang) | Tidak dapat diedit dari Step 2 (REQ-022). |
| `Jumlah` | **Ya** | Integer > 0 | Kosong → helper error + border error (REQ-030). Hanya bilangan bulat positif (INF). |
| `Nilai Barang` | **Kondisional** — wajib bila `Tambahkan Asuransi` armada tercentang | Currency (Rp) ≥ 0 | Tidak dirender bila asuransi tidak aktif. Kosong saat asuransi aktif → helper error + border error (REQ-024, REQ-030). |
| `Tambahkan Asuransi` | Tidak | Checkbox **per armada** | Default tidak tercentang. Berlaku untuk seluruh barang pada armada tersebut (REQ-025). |
| `Nomor DO` | **Tidak** | Text multi-nilai (chip) | Pemisah **koma**; setiap nilai dirender sebagai chip terpisah & dapat dihapus individual (REQ-026). |
| Icon hapus baris | — | Aksi | Menghapus satu baris barang tanpa mempengaruhi baris/armada lain (REQ-027). |
| `Total Kubikasi` (per armada) | — | Kalkulasi | `Σ(kubikasi satuan × Jumlah)` pada armada tersebut. |
| `Total Berat` (per armada) | — | Kalkulasi | `Σ(berat satuan × Jumlah)` pada armada tersebut. |
| Alert kapasitas | — | **Warning informatif (non-blocking)** | Lihat matriks V2a. **Tidak** memblokir `Selanjutnya` (REQ-028). |
| Floating `Hitung Ulang Armada` | — | Button (kondisional) | Aktif hanya bila **≥ 1** data barang sudah diisi (REQ-036). |
| Floating `Visualisasi Terbaru` | — | Button | Menampilkan panel visualisasi tanpa mengubah pilihan armada (REQ-047). |

**V2a. Matriks Pesan Alert Kapasitas (REQ-029)**

| Kubikasi > kapasitas | Berat > kapasitas | Pesan (teks persis) |
|:--:|:--:|---|
| ✘ | ✘ | *(tidak ada alert)* |
| ✔ | ✘ | `Kubikasi melebihi kapasitas armada` |
| ✘ | ✔ | `Berat melebihi kapasitas armada` |
| ✔ | ✔ | `Kubikasi dan Berat melebihi kapasitas armada` |

### V3. Drawer `Hitung Ulang Armada`

| Field / Elemen | Wajib | Tipe/Format | Aturan |
|---|:--:|---|---|
| `Total Kubikasi` / `Total Berat` | — | Kalkulasi read-only | Dari data barang yang diinput (REQ-039). |
| `Jenis Pengiriman` | — | Read-only | Dibawa dari Step 1 (REQ-040). |
| Kartu rekomendasi armada | — | List, **maksimal 3** | Masing-masing dengan `Berat Terpakai` & `Ruang Terpakai`; **tepat satu** berlabel `Paling Efisien` (REQ-041). |
| `Jenis Armada` (drawer) | Ya | Modal `Pilih Jenis Armada` | Harus dipilih dari master (REQ-042). |
| `Jumlah Armada` (drawer) | Ya | Integer via input/stepper | Minimal `1` (REQ-042). |
| Visualisasi Muatan 3D | — | Kanvas per armada | Memperbarui saat `Jenis`/`Jumlah Armada` berubah (REQ-043). |
| `Terapkan ke Order` | — | Button | Menulis `Jenis Armada`, `Jumlah Armada`, dan penempatan barang ke order + Step 1 (REQ-044, REQ-045). |
| `Batal` | — | Button | Menutup panel **tanpa** menerapkan perubahan (REQ-046). |

### V4. Step 3 — Vendor & Harga

| Field | Wajib | Tipe/Format | Aturan |
|---|:--:|---|---|
| `Pilihan Vendor` | Ya | Dropdown (Master Vendor) | Harus dipilih dari master. |
| `Tanggal Permintaan Muat` | Ya | Date/Datetime | Tidak boleh di masa lalu (INF, ASM-018). |
| `Waktu Perjalanan` | **Kondisional** | **Textfield** bila rute belum ada di master; **text-only** bila sudah ada | Bila textfield: wajib, numerik ≥ 1 (satuan jam, INF). Bila text-only: read-only dari master (REQ-049). |
| `Harga` | Ya | Currency (Rp) | Nilai > 0 (INF). |
| Ringkasan alamat | — | Label (+ text link untuk tipe multi) | Text link membuka rincian daftar alamat (REQ-050). |
| `Gunakan Komponen Harga` | Tidak | Checkbox | Default tidak tercentang; mencentangnya memunculkan input komponen harga (REQ-051). |
| `PPN` | Kondisional (bila komponen harga aktif) | Persen desimal | Range wajar `0`–`100` (INF). Bersifat penambah. |
| `PPh` | Kondisional (bila komponen harga aktif) | Persen desimal | Range wajar `0`–`100` (INF). Bersifat pengurang. |
| `Asuransi` | **Kondisional** — hanya bila ada armada diasuransikan | Persen desimal | Nilai Asuransi = `persentase × Total Nilai Barang` (REQ-052). |
| `Total Harga` | — | Kalkulasi | `Harga` + `PPN` − `PPh` + `Asuransi` (bila berlaku). |

### V5. Pembatalan & Edit Order

| Field / Aturan | Wajib | Tipe/Format | Aturan |
|---|:--:|---|---|
| `Alasan Pembatalan` | **Ya** | Textarea | Wajib diisi saat pembatalan; kosong → submit ditolak (REQ-068). |
| `Jenis Pengiriman` (Edit Order) | — | **Locked/read-only** | Tidak dapat diubah (REQ-063). |
| `Tipe Pengiriman` (Edit Order) | — | **Locked/read-only** | Tidak dapat diubah (REQ-063). |
| Rentang status dapat **edit** | — | Aturan status | Draft (`Isi Data Pengiriman` s.d. `Review Order`) **hingga** `Menunggu Penugasan` (REQ-061, REQ-062). |
| Rentang status dapat **batal** | — | Aturan status | Draft **hingga** `Ditugaskan`; tidak setelah `Proses Pengiriman` (REQ-066). |
| Button `Batal` / `Simpan` (Edit Order) | — | Aksi + konfirmasi | Keduanya menampilkan **pop up konfirmasi** (REQ-065). |

### V6. Aturan Lintas-Step

| Aturan | Detail |
|---|---|
| Navigasi step | `Selanjutnya` menahan navigasi selama masih ada field wajib kosong/invalid pada step aktif (REQ-014, REQ-030, REQ-053). |
| Alert kapasitas non-blocking | Pelanggaran kapasitas **TIDAK** menghalangi `Selanjutnya`/`Simpan` (REQ-028) — ini pembeda penting dari validasi wajib. |
| Sinkronisasi armada | Perubahan `Jumlah Armada` (Step 1 **atau** hasil `Terapkan ke Order`) menyesuaikan jumlah blok armada & `Data Unit` di Step 2 (REQ-031, REQ-045). |
| Sinkronisasi kapasitas | Perubahan `Jenis Armada` mengubah kapasitas maksimal yang dipakai alert kapasitas (REQ-045). |
| Carry-over asuransi | `Tambahkan Asuransi` (Step 2) → komponen `Asuransi` (Step 3) → label `Diasuransikan` (Step 4) (REQ-025, REQ-052, REQ-056). |
| Konsistensi Review | Data Barang Step 4 harus identik dengan hasil penempatan Step 2 — tanpa transformasi (REQ-055). |
| Konservasi kuantitas | Total `Jumlah` barang **sebelum** dan **sesudah** Auto Stuffing / `Terapkan ke Order` harus sama (REQ-037, REQ-044). |
| Draft di semua step | `Simpan ke Draf` tersedia di setiap step dan memetakan status sesuai step (REQ-060). |

### V7. Katalog Pesan & Label yang Disebut Eksplisit di Spec

| Teks | Jenis | Lokasi | Sumber |
|---|---|---|---|
| `Kubikasi melebihi kapasitas armada` | Warning informatif | Step 2 — per armada | L28 |
| `Berat melebihi kapasitas armada` | Warning informatif | Step 2 — per armada | L29 |
| `Kubikasi dan Berat melebihi kapasitas armada` | Warning informatif | Step 2 — per armada | L30 |
| `Sudah Ditambahkan` | Label/badge | Modal `Pilih Barang` | L17 |
| `Pilih Barang` | Judul modal / button | Step 2 | L13, L14 |
| `Hitung Ulang Armada` | Floating button / judul drawer | Step 2 | L33, L42 |
| `Visualisasi Terbaru` | Floating button | Step 2 | L33, L51 |
| `Paling Efisien` | Label rekomendasi | Drawer | L45 |
| `Berat Terpakai` / `Ruang Terpakai` | Indikator | Drawer | L45 |
| `Pilih Jenis Armada` | Judul modal | Drawer | L46 |
| `Terapkan ke Order` | Button | Drawer | L48 |
| `Visualisasi Muatan` | Button + pop up | Step 4 / Drawer | L7, L47, L67 |
| `Gunakan Komponen Harga` | Checkbox | Step 3 | L60 |
| `Tambahkan Asuransi` | Checkbox | Step 2 | L23, L24 |
| `Diasuransikan` | Label per armada | Step 4 | L66 |
| `Data No. Perjalanan` | Judul pop up | Daftar/Detail Order | L110 |
| `Lihat No. Perjalanan` | Aksi menu | Daftar Order | L102, L109 |
| `Riwayat Pembatalan` | Button toolbar | Daftar Order | L103 |
| `Riwayat Perubahan` | Aksi per baris | Daftar Order | L100–L103 |
| `Lanjutkan Pengisian` | Aksi per baris | Daftar Order | L100 |
| `Batalkan Order` | Aksi per baris | Daftar Order | L100–L102 |
| `Alasan Pembatalan` | Field wajib | Pop up pembatalan | L96 |
| `Simpan ke Draf` | Button | Semua step | L81 |

---

## Roles & Permissions

> Spec menyebut aktor secara terbatas: **"Shipper"** (L84–L85), **"admin shipper"** (L80, L95), **"vendor"** (L77, L95), dan **"pengirim/penerima"** sebagai konsumen public tracking (L106). Rincian hak akses di bawah sebagian merupakan inferensi — lihat **ASM-013**.

| Role | Konteks | Hak Akses pada Modul OMS-012 |
|---|---|---|
| **Shipper — Staff Operasional** | Pengguna utama modul (pembuat order) | Akses `Daftar Order`; `Buat Order` (wizard 4 step FTL, semua tipe pengiriman) & `Batch Order`; gunakan modal `Pilih Barang`; jalankan `Hitung Ulang Armada` & `Visualisasi Terbaru`; `Terapkan ke Order`; `Simpan ke Draf` & `Lanjutkan Pengisian`; `Edit` order (status yang diizinkan); lihat `Detail Order`, `Riwayat Perubahan`, `Riwayat Pembatalan`, `Data No. Perjalanan`. |
| **Admin Shipper** | Pengelola order di sisi shipper | Seluruh hak Staff Operasional **+ `Batalkan Order`** (satu-satunya pihak yang berwenang membatalkan, REQ-067) dan pengelolaan master (Master Barang, Master Droppoint, Master Armada, Master Vendor). |
| **System Admin / Super Admin** | Pengelola konfigurasi & entitlement | Mengaktifkan/menonaktifkan **entitlement add-on Auto Stuffing** pada tenant (REQ-005). Perubahan ini berlaku global terhadap Step 2, drawer, dan Step 4. |
| **Vendor / Transporter** | Pihak eksternal penerima penugasan | Melakukan **penugasan armada** (memicu status `Ditugaskan`) dan memperbarui status perjalanan (`Dalam Perjalanan` → `Selesai`). **TIDAK** dapat membatalkan order (REQ-067) dan **tidak** memiliki akses ke wizard pembuatan order OMS. |
| **Pengirim / Penerima (publik)** | Konsumen tracking | Hanya dapat mengakses **public tracking** menggunakan `No. Perjalanan` untuk melihat progress perjalanan (REQ-072). Tidak memiliki akses ke OMS. |
| **Guest / Unauthenticated** | — | Tidak memiliki akses ke seluruh URL modul; seluruh akses harus ditolak/redirect ke login. Pengecualian: halaman public tracking. |

### Matriks Hak Akses Ringkas

| Aksi | Staff Operasional | Admin Shipper | System Admin | Vendor | Publik/Guest |
|---|:--:|:--:|:--:|:--:|:--:|
| Lihat Daftar Order | ✔ | ✔ | ✔ | ✘ | ✘ |
| Buat Order (wizard 4 step) | ✔ | ✔ | ✔ | ✘ | ✘ |
| Batch Order | ✔ | ✔ | ✔ | ✘ | ✘ |
| Jalankan `Hitung Ulang Armada` / `Terapkan ke Order` | ✔ | ✔ | ✔ | ✘ | ✘ |
| Lihat `Visualisasi Muatan` | ✔ | ✔ | ✔ | ✘ | ✘ |
| `Simpan ke Draf` / `Lanjutkan Pengisian` | ✔ | ✔ | ✔ | ✘ | ✘ |
| `Edit` Order (status diizinkan) | ✔ | ✔ | ✔ | ✘ | ✘ |
| `Edit` Order (status `Ditugaskan`+) | ✘ | ✘ | ✘ | ✘ | ✘ |
| **`Batalkan Order`** | ✘ (INF) | **✔** | ✔ | **✘** | ✘ |
| Lihat `Detail Order` & `No. Perjalanan` | ✔ | ✔ | ✔ | ✘ | ✘ |
| Penugasan armada (memicu `Ditugaskan`) | ✘ | ✘ | ✘ | ✔ | ✘ |
| Kelola Master (Barang/Droppoint/Armada/Vendor) | ✘ | ✔ | ✔ | ✘ | ✘ |
| Ubah entitlement add-on Auto Stuffing | ✘ | ✘ | ✔ | ✘ | ✘ |
| Public tracking via `No. Perjalanan` | ✔ | ✔ | ✔ | ✔ | ✔ |

---

## User Flows

### Prasyarat Global

1. User terautentikasi dengan role yang berwenang (lihat Roles & Permissions).
2. **Modul OMS dibeli beserta add-on Auto Stuffing** (REQ-005) — prasyarat pembeda modul OMS-012.
3. Jenis order = **FTL** (add-on hanya berlaku FTL & FCL, REQ-006).
4. Master data tersedia: **Master Droppoint**, **Master Barang**, **Master Armada** (dengan kapasitas berat & kubikasi), **Master Vendor**, dan (opsional) **Master Waktu Perjalanan**.

---

### F1. Flow Utama — Buat Order FTL, Tipe `Normal`, dengan Auto Stuffing

**Step 1 — Data Pengiriman**
1. User membuka `Daftar Order` → klik `Buat Order`.
2. Sistem menampilkan wizard dengan step `Data Pengiriman` aktif.
3. User memilih `Jenis Armada` dan mengisi `Jumlah Armada`.
4. User memilih `Tipe Pengiriman` = `Normal` → sistem menampilkan satu blok `Data Pengirim` & satu blok `Data Penerima`.
5. User memilih `Drop Point Asal` → sistem **auto-draft** Provinsi/Kota/Kecamatan/Desa/Kode Pos/Alamat asal (read-only).
6. User mengisi `Pengirim`, `PIC Pengirim`, `No. WhatsApp PIC`, `Catatan` (opsional).
7. User memilih `Drop Point Tujuan` → auto-draft data tujuan; user mengisi `Penerima`, `PIC Penerima`, `No. WhatsApp PIC`, `Catatan`.
8. User klik `Selanjutnya` → sistem memvalidasi field wajib (REQ-014).

**Step 2 — Data Barang**
9. Sistem menampilkan `Data Unit` (`Jenis Armada` + `Jumlah Armada` dari Step 1) dan blok `Armada 1..N`.
10. Sistem menampilkan **floating button** `Hitung Ulang Armada` (state **tidak aktif** karena belum ada barang) dan `Visualisasi Terbaru`.
11. Pada `Armada 1`, user klik **`Pilih Barang`** → modal terbuka.
12. User mencari barang **by kode/nama**, mencentang beberapa barang (**multi-select**); counter jumlah barang terpilih bertambah; barang yang sudah ada di armada tersebut berlabel `Sudah Ditambahkan`.
13. User klik `Simpan` pada modal → barang masuk ke tabel `Armada 1` dengan `Kode SKU`, `Nama Barang`, `Kemasan`, `Kubikasi`, `Dimensi`, `Berat` **read-only**.
14. User mengisi **`Jumlah`** per baris barang (wajib).
15. (Opsional) User mencentang **`Tambahkan Asuransi`** pada armada → kolom **`Nilai Barang`** muncul & menjadi wajib; user mengisinya per baris.
16. (Opsional) User mengisi **`Nomor DO`** (beberapa nomor dipisah koma → tampil sebagai chip).
17. Sistem menghitung `Total Kubikasi` & `Total Berat` per armada; bila melebihi kapasitas, muncul **alert informatif** sesuai kondisi (REQ-029) — **tidak memblokir**.
18. Floating button `Hitung Ulang Armada` kini **aktif** (≥ 1 data barang terisi, REQ-036).
19. User klik `Selanjutnya`.

**Step 3 — Vendor & Harga**
20. User memilih `Vendor`, mengisi `Tanggal Permintaan Muat` dan `Harga`.
21. `Waktu Perjalanan` tampil sebagai **textfield** (rute belum ada di master) atau **text-only** (rute sudah ada) — REQ-049.
22. (Opsional) User mencentang `Gunakan Komponen Harga` → mengisi `PPN`, `PPh`; bila ada armada diasuransikan, komponen **`Asuransi`** turut muncul dan dihitung ke `Total Harga` (REQ-052).
23. User klik `Selanjutnya`.

**Step 4 — Review**
24. Sistem menampilkan ringkasan Step 1–3 **read-only**.
25. Section `Data Barang` mengikuti struktur Step 2 (`Kode SKU`, `Nama Barang`, `Kemasan`, `Kubikasi`/`Dimensi`, `Berat`, `Jumlah`, `Nilai Barang` bila diasuransikan) + label `Diasuransikan` per armada.
26. User klik button **`Visualisasi Muatan`** pada card Data Barang → **pop up** visualisasi tampil; user menutup pop up.
27. User klik **`Simpan`** → order tersimpan dengan status **`Menunggu Penugasan`** dan muncul di `Daftar Order`.

---

### F2. Flow Auto Stuffing — `Hitung Ulang Armada` → `Terapkan ke Order`

*(Percabangan dari F1 langkah 18; ini adalah alur inti add-on.)*

1. Setelah minimal 1 data barang terisi, user klik floating button **`Hitung Ulang Armada`** (hover menampilkan label; default hanya ikon).
2. Sistem membuka **drawer** berisi:
   - `Total Kubikasi` & `Total Berat` dari data barang yang diinput;
   - `Jenis Pengiriman` dari Step 1;
   - **Rekomendasi 3 teratas armada** dengan indikator `Berat Terpakai` & `Ruang Terpakai`; rekomendasi terbaik berlabel **`Paling Efisien`**;
   - Field `Jenis Armada` (dapat diubah via modal `Pilih Jenis Armada`) dan `Jumlah Armada` (input/stepper);
   - **Visualisasi Muatan 3D** per armada.
3. User memilih salah satu rekomendasi (atau mengubah `Jenis Armada`/`Jumlah Armada` secara manual) → **visualisasi 3D memperbarui** secara langsung.
4. **Jalur A — Terapkan:** user klik **`Terapkan ke Order`** →
   a. `Jenis Armada` & `Jumlah Armada` order diperbarui;
   b. **Penempatan barang** hasil Auto Stuffing diterapkan ke masing-masing armada (kubikasi & berat mengisi 1 armada hingga maksimal sebelum berpindah, REQ-037);
   c. **Data Step 1 turut berubah**, demikian pula informasi `Data Unit` & jumlah blok armada di Step 2 (REQ-045);
   d. Drawer tertutup; user melihat hasil penempatan terbaru di Step 2.
5. **Jalur B — Batal:** user klik **`Batal`** → drawer tertutup; **tidak ada** perubahan yang diterapkan; Step 1 & Step 2 tetap seperti semula (REQ-046).

---

### F3. Flow — `Visualisasi Terbaru` (read-only)

1. Pada Step 2, user klik floating button **`Visualisasi Terbaru`**.
2. Sistem menampilkan panel visualisasi muatan sesuai **`Jenis` & `Jumlah Armada` terkini** pada order.
3. Panel **tidak** menyediakan kartu rekomendasi, field pengubah armada, maupun `Terapkan ke Order`.
4. User menutup panel → **tidak ada** perubahan pada pilihan armada maupun penempatan barang (REQ-047).

---

### F4. Flow — Tipe `Multipickup` / `Multidrop` / `Multipoint`

Perbedaan terhadap F1:

- **Step 1:** setelah memilih tipe pengiriman multi, section `Data Pengirim` dan/atau `Data Penerima` menjadi **berulang** dengan tombol tambah baris; berlaku **minimal baris per tipe** (REQ-013). User mengisi seluruh field wajib untuk setiap alamat.
- **Step 2:** struktur Data Barang mengikuti alamat (per `Pick Up`, per `Drop Off`, atau per **kombinasi** `Pick Up × Drop Off`) di dalam setiap armada.
- **Auto Stuffing:** setelah distribusi antar armada (REQ-037), barang **dibagi rata antar alamat dalam 1 armada yang sama**. Bila tidak dapat dibagi rata, **sisa yang lebih besar ditempatkan pada alamat pertama** (REQ-038).
  Contoh: 7 koli SKU-A pada Armada 1 dengan 2 alamat → `Alamat 1` = 4, `Alamat 2` = 3.
- **Step 3:** ringkasan alamat ditampilkan sebagai **label + text link**; klik link membuka rincian daftar alamat (REQ-050).
- **Step 4:** Data Barang dikelompokkan `Armada` → `Alamat`/`Kombinasi Alamat`, mengikuti struktur Step 2.

---

### Flow Alternatif & Percabangan

| Kode | Nama | Langkah |
|---|---|---|
| **ALT-01** | Simpan ke Draf | Pada step manapun user klik `Simpan ke Draf` → order tersimpan dengan status draft sesuai step (`Isi Data Pengiriman` / `Isi Data Muatan` / `Isi Data Vendor` / `Review Order`) dan muncul di Daftar Order (REQ-060). |
| **ALT-02** | Lanjutkan Pengisian | Daftar Order → menu `...` → `Lanjutkan Pengisian` → wizard terbuka pada step yang sesuai; seluruh data (termasuk hasil penempatan Auto Stuffing) ter-restore utuh. |
| **ALT-03** | Navigasi mundur | `Sebelumnya` dari Step 2/3/4 → kembali dengan data utuh. Mengubah `Jumlah Armada` di Step 1 menyesuaikan blok armada di Step 2. |
| **ALT-04** | Batal buat order | `Batal` di step manapun → konfirmasi → keluar wizard tanpa menyimpan. |
| **ALT-05** | Batal pada modal `Pilih Barang` | `Batal` → modal tertutup, **tidak ada** barang yang ditambahkan, counter ter-reset (REQ-021). |
| **ALT-06** | Hapus baris barang | Klik icon hapus pada baris → baris terhapus; `Total Kubikasi`/`Total Berat` armada ter-update (REQ-027). |
| **ALT-07** | Lepas centang asuransi | Melepas `Tambahkan Asuransi` → kolom `Nilai Barang` hilang beserta validasi wajibnya; komponen `Asuransi` di Step 3 tidak lagi dihitung (REQ-024, REQ-052). |
| **ALT-08** | Edit Order | Daftar/Detail Order → `Edit` (hanya status draft s.d. `Menunggu Penugasan`) → ubah `Jenis/Jumlah Armada`, `Data Pengirim/Penerima`, `Data Barang`, `Vendor & Harga` (`Jenis Pengiriman` & `Tipe Pengiriman` **locked**) → `Simpan` → **pop up konfirmasi** (REQ-061 s.d. REQ-065). |
| **ALT-09** | Batalkan Order | Aksi `Batalkan Order` (status draft s.d. `Ditugaskan`, oleh **admin shipper**) → isi **`Alasan Pembatalan` (wajib)** → konfirmasi → status `Dibatalkan`; order tercatat di `Riwayat Pembatalan` (REQ-066 s.d. REQ-068). |
| **ALT-10** | Lihat No. Perjalanan | Setelah status `Ditugaskan` → menu `...` → `Lihat No. Perjalanan` → pop up `Data No. Perjalanan` (No. Perjalanan + `Nopol`/`No. Kontainer` + `Jenis Armada`) → **icon copy** untuk menyalin (REQ-075 s.d. REQ-077). |
| **ALT-11** | Riwayat Pembatalan (toolbar) | Daftar Order → `Riwayat Pembatalan` → daftar **seluruh** order yang pernah dibatalkan (REQ-071). |
| **ALT-12** | Riwayat Perubahan (baris) | Menu `...` → `Riwayat Perubahan` → histori perubahan **order tersebut saja** (REQ-071). |
| **ALT-13** | Public tracking | Pengirim/penerima memasukkan `No. Perjalanan` pada halaman public tracking → melihat progress perjalanan armada (REQ-072). |
| **ALT-14** | Batch Order | Daftar Order → `Batch Order` → unggah/isi data batch → order terbentuk dan muncul di Daftar Order (REQ-003). |

### Skenario Percabangan Negatif / Edge

| Kode | Kondisi | Ekspektasi |
|---|---|---|
| **EX-01** | Field wajib Step 1 kosong lalu klik `Selanjutnya` | Navigasi ditahan; pesan validasi inline muncul (REQ-014). |
| **EX-02** | Baris barang ada tetapi `Jumlah` kosong | **Helper error** + **border field error**; navigasi ditahan (REQ-023, REQ-030). |
| **EX-03** | `Tambahkan Asuransi` dicentang tetapi `Nilai Barang` kosong | Helper error + border error; navigasi ditahan (REQ-024, REQ-030). |
| **EX-04** | `Nilai Barang` diisi lalu asuransi dilepas, lalu dicentang lagi | Kolom kembali muncul; perilaku validasi konsisten; tidak error (REQ-024). |
| **EX-05** | Total kubikasi dan/atau berat melebihi kapasitas armada | Alert **informatif** sesuai matriks V2a muncul, **namun `Selanjutnya` tetap aktif** dan order **tetap dapat disimpan** (REQ-028, REQ-029). |
| **EX-06** | Klik `Hitung Ulang Armada` saat **belum ada** data barang | Button tidak dapat dijalankan; drawer **tidak** terbuka; tidak ada kalkulasi (REQ-036). |
| **EX-07** | Membuka modal `Pilih Barang` dari Armada 2 untuk SKU yang sudah ada di Armada 1 | SKU **tidak** berlabel `Sudah Ditambahkan` (label bersifat per armada) dan dapat ditambahkan ke Armada 2 (REQ-019). |
| **EX-08** | Menambahkan ulang SKU yang sudah ada pada armada yang sama | Tidak menghasilkan baris duplikat (REQ-019). |
| **EX-09** | Pencarian barang tanpa hasil | Empty state pencarian, bukan error (REQ-017). |
| **EX-10** | Ubah `Jenis`/`Jumlah Armada` di drawer lalu klik `Batal` | Step 1 & Step 2 **tidak berubah**; penempatan barang tetap seperti semula (REQ-046). |
| **EX-11** | Muatan tidak muat pada 1 armada | `Armada 1` terisi hingga batas kapasitas sebelum `Armada 2` mulai terisi; total `Jumlah` konservatif (REQ-037). |
| **EX-12** | Muatan tidak habis dibagi antar alamat (mis. 7 koli / 2 alamat) | `Alamat 1` = 4, `Alamat 2` = 3 — sisa lebih besar ke **alamat pertama** (REQ-038). |
| **EX-13** | Jumlah armada yang ditetapkan lebih banyak dari kebutuhan muatan | Armada berlebih tetap dirender dalam kondisi kosong; tidak ada error (REQ-037). |
| **EX-14** | Master armada memiliki < 3 jenis armada yang relevan | Drawer menampilkan rekomendasi sebanyak yang tersedia (≤ 3), tetap dengan **tepat satu** `Paling Efisien` (REQ-041, ASM-011). |
| **EX-15** | `Nomor DO` dikosongkan | User tetap dapat lanjut ke step berikutnya (REQ-026). |
| **EX-16** | Akses `Edit Order` pada status `Ditugaskan` (langsung via URL) | Ditolak (redirect/pesan error), bukan sekadar disembunyikan di UI (REQ-062). |
| **EX-17** | Upaya mengubah `Jenis Pengiriman`/`Tipe Pengiriman` di halaman Edit | Field locked; tidak ada jalur UI untuk mengubahnya (REQ-063). |
| **EX-18** | Upaya `Batalkan Order` pada status `Proses Pengiriman`/`Selesai` | Aksi tidak tersedia dan ditolak bila dipaksakan (REQ-066). |
| **EX-19** | Submit pembatalan dengan `Alasan Pembatalan` kosong | Ditolak dengan pesan validasi (REQ-068). |
| **EX-20** | Upaya pembatalan oleh akun **vendor** | Ditolak — hanya admin shipper yang berwenang (REQ-067). |
| **EX-21** | Membuka menu aksi pada status `Menunggu Penugasan` | Terdapat `Edit`, **tidak** terdapat `Lihat No. Perjalanan` (REQ-070, REQ-075). |
| **EX-22** | Tenant **tanpa** add-on Auto Stuffing | Floating button, drawer, dan button `Visualisasi Muatan` **tidak** dirender; alur order standar tetap berjalan (REQ-005). |
| **EX-23** | Scroll panjang pada Step 2 dengan banyak armada | Floating button tetap terlihat & dapat diklik pada posisi floating (REQ-034). |
| **EX-24** | Hover/unhover floating button | Label muncul saat hover dan tersembunyi kembali saat unhover; ikon selalu tampil (REQ-035). |
| **EX-25** | Order draft di-restore via `Lanjutkan Pengisian` | Penempatan barang hasil Auto Stuffing ter-restore apa adanya, **tidak** dihitung ulang otomatis (REQ-060, ASM-010). |

---

## UI Inventory

> **Sumber:** 46 file PNG di `inputs/oms012-order-ftl-auto-stuffing/designs/` (`016`–`057` + varian `031a`, `043a`, `047a`, `057a`). Brief menyebut 47 file — selisih dicatat pada **ASM-026**.
> **Bahasa UI:** Indonesia. **Mata uang:** `Rp`. **Satuan:** `m³`, `kg`, `Jam`, `koli`.
> **Konvensi selector:** `role` = `getByRole()` Playwright; `testid` = usulan atribut `data-testid` (kebab-case, **belum ada di produk** — usulan design-analyzer); `label` = teks label yang dipakai `getByLabel()`.
> Field bertanda `*` pada desain = wajib. Field ber-background abu = **read-only/auto-draft**.

---

### UI-00. Shell Global (muncul di seluruh layar terautentikasi)

| Elemen | Tipe | Teks / Placeholder | State terlihat | Selector Playwright |
|---|---|---|---|---|
| Brand | Text/logo | `Mentari Sumber Kertas` | — | `role=link|banner name="Mentari Sumber Kertas"` · `testid=app-brand` |
| Toggle sidebar | Icon button | (hamburger) | — | `role=button name=/menu|sidebar/i` · `testid=sidebar-toggle` |
| Menu utama | Nav links | `Dashboard`, `Order`, `Penugasan Tracking`, `Simulasi Muatan`, `Master Wilayah`, `Master Operasional`, `Manajemen Vendor`, `Pengaturan Akun`, `Akun Saya`, `Pengaturan Sistem`, `Pusat Notifikasi` | `Order` aktif (016–035); `Simulasi Muatan` aktif (036–057a → ASM-042) | `role=link name="Order"` · `testid=nav-order` |
| Widget kuota | Card + progress | `Kuota Order`, `120/300`, `40%`, `Order Management System Versi 1.0.0` | — | `testid=kuota-order-widget` |
| Konteks user | Text + badge | `Shipper` + badge `Staff Operasional` | — | `testid=user-role-badge` |
| Notifikasi | Icon button + dot | (bell, dot merah = unread) | unread | `role=button name=/notifikasi/i` · `testid=btn-notifikasi` |
| Profil | Avatar + text | `Andika`, `andikamsk@gmail.com` | — | `testid=user-menu` |
| Logout | Icon button | (logout) | — | `role=button name=/keluar|logout/i` · `testid=btn-logout` |
| Breadcrumb | Nav | `Beranda > Daftar Order > (Buat Order / Edit Order / Detail Order)` | — | `role=navigation name=/breadcrumb/i` · `testid=breadcrumb` |

---

### UI-01. Daftar Order — daftar utama
**File:** `016.png`, `036.png`, `050.png` (identik; 036/050 hanya beda menu sidebar aktif)

| Elemen | Tipe | Teks / Placeholder | State terlihat | Selector Playwright |
|---|---|---|---|---|
| Judul halaman | Heading | `Daftar Order` | — | `role=heading name="Daftar Order"` · `testid=page-title` |
| Buat Order | Button (primary, ikon +) | `Buat Order` | enabled | `role=button name="Buat Order"` · `testid=btn-buat-order` |
| Batch Order | Button (outline, ikon unduh) | `Batch Order` | enabled | `role=button name="Batch Order"` · `testid=btn-batch-order` |
| Riwayat Pembatalan | Button (outline, ikon jam) | `Riwayat Pembatalan` | enabled | `role=button name="Riwayat Pembatalan"` · `testid=btn-riwayat-pembatalan` |
| Filter | Button (outline) | `Filter` | enabled (toggle panel UI-02) | `role=button name="Filter"` · `testid=btn-filter` |
| Jumlah data | Select | `Tampilkan [20] data` | value `20` | `role=combobox name=/tampilkan/i` · `testid=select-page-size` · label `Tampilkan` |
| Tabel order | Table (header 2 baris) | Kol: `ID Order`/`Vendor`, `Kota Asal`/`Warehouse Asal`, `Kota Tujuan`/`Warehouse Tujuan`, `Total Harga`⇅/`Status` | populated (9 baris) | `role=table` · `testid=table-daftar-order` |
| Sort Total Harga | Button ikon ⇅ | `Total Harga` | sortable | `role=button name=/Total Harga/`· `testid=sort-total-harga` |
| Badge jenis order | Badge | `FTL`, `FCL`, `LTL`, `LCL` | — | `testid=badge-jenis-order` |
| Chip status | Badge | `Isi Data Dasar`, `Isi Data Muatan`, `Isi Data Vendor`, `Review Order`, `Menunggu Penugasan`, `Ditugaskan`, `Proses Pengiriman`, `Terkirim`, `Dibatalkan` | 9 status tampil (label beda dari spec → **ASM-027**) | `testid=chip-status-order` |
| Aksi baris | Icon button `…` | — | membuka menu UI-03 | `role=button name=/aksi|more/i` · `testid=btn-row-action` |
| Info paginasi | Text | `Menampilkan 1 - 20 data dari 30 data` | — | `testid=pagination-info` |
| Paginasi | Nav | `«`, `‹`, `1`,`2`,`3`,`…`,`12`, `›`, `»` | halaman `1` aktif | `role=navigation name=/pagination/i` · `testid=pagination` |

**State layar:** hanya **populated**. Tidak ada desain empty/loading/error untuk daftar order (**ASM-043**).

---

### UI-02. Daftar Order — Panel Filter
**File:** `017.png`, `034.png`, `050.png`(tanpa panel)

| Field | Tipe | Label / Placeholder | State | Selector Playwright |
|---|---|---|---|---|
| ID Order | Text input | `ID Order` / `Masukkan ID Order` | empty | `role=textbox name="ID Order"` · `testid=filter-id-order` |
| Jenis Order | Dropdown | `Jenis Order` / `Pilih Jenis Order` | empty | `role=combobox name="Jenis Order"` · `testid=filter-jenis-order` |
| Vendor | Text input | `Vendor` / `Masukkan Vendor` | empty | `role=textbox name="Vendor"` · `testid=filter-vendor` |
| Kota Asal | Dropdown | `Kota Asal` / `Pilih Kota Asal` | empty | `testid=filter-kota-asal` |
| Kota Tujuan | Dropdown | `Kota Tujuan` / `Pilih Kota Tujuan` | empty | `testid=filter-kota-tujuan` |
| Total Harga | Text input | `Total Harga` / `Masukkan Total Harga` | empty | `testid=filter-total-harga` |
| Tipe Pengiriman | Dropdown | `Tipe Pengiriman` / `Pilih Tipe Pengiriman` | **placeholder abu — indikasi disabled** (ASM-045) | `testid=filter-tipe-pengiriman` |
| Metode Pengiriman | Dropdown | `Metode Pengiriman` / `Pilih Metode Pengiriman` | **placeholder abu — indikasi disabled** | `testid=filter-metode-pengiriman` |
| Drop Point Asal | Dropdown | `Drop Point Asal` / `Pilih Drop Point Asal` | empty | `testid=filter-drop-point-asal` |
| Drop Point Tujuan | Dropdown | `Drop Point Tujuan` / `Pilih Drop Point Tujuan` | empty | `testid=filter-drop-point-tujuan` |
| Status | Dropdown | `Status` / `Pilih Status` | empty | `testid=filter-status` |
| Reset | Button (danger outline) | `Reset` | enabled | `role=button name="Reset"` · `testid=btn-filter-reset` |
| Terapkan | Button (primary) | `Terapkan` | enabled | `role=button name="Terapkan"` · `testid=btn-filter-terapkan` |

---

### UI-03. Daftar Order — Menu Aksi per Status
**File:** `017.png` (2 menu), `034.png` (1 menu)

| Konteks status | Item menu (urutan desain) | Selector |
|---|---|---|
| `Isi Data Dasar` / draft (017) | `Detail`, `Lanjutkan Pengisian`, `Batalkan Order`, `Riwayat Perubahan` | `role=menuitem name="Lanjutkan Pengisian"` · `testid=action-lanjutkan-pengisian` |
| `Menunggu Penugasan` (017) | `Detail`, `Edit`, `Batalkan Order`, `Riwayat Perubahan` | `role=menuitem name="Edit"` · `testid=action-edit` |
| `Ditugaskan` (034) | `Detail`, `Lihat No. Perjalanan`, **`Order Kembali`**, `Batalkan Order`, `Riwayat Perubahan` | `role=menuitem name="Lihat No. Perjalanan"` · `testid=action-lihat-no-perjalanan`; `testid=action-order-kembali` |

> `Order Kembali` **tidak ada di spec** → **ASM-029**. Menu untuk `Proses Pengiriman`, `Terkirim`, `Dibatalkan` **tidak ada desainnya** (tetap inferensi ASM-016).

---

### UI-04. Pop up `Data No. Perjalanan`
**File:** `035.png`

| Elemen | Tipe | Teks | State | Selector |
|---|---|---|---|---|
| Judul | Heading dialog | `Data No. Perjalanan` | open | `role=dialog name="Data No. Perjalanan"` · `testid=modal-no-perjalanan` |
| Tutup | Icon button `✕` | — | — | `role=button name=/tutup|close/i` · `testid=btn-close-modal` |
| Chip ID order | Badge | `ID Order: ORD-20260607009` | — | `testid=chip-id-order` |
| Badge jenis | Badge | `FTL` | — | `testid=badge-jenis-order` |
| Baris perjalanan (2×) | List item | `TRC79289802` · `L 1892 PGS • Fuso Box` / `L 6718 TH • Fuso Box` | 2 baris = 2 armada | `testid=row-no-perjalanan` |
| Salin | Icon button (copy) per baris | — | — | `role=button name=/salin|copy/i` · `testid=btn-copy-no-perjalanan` |

**Catatan:** tidak ada tombol footer; tidak ada state toast `Tersalin` di desain (**ASM-043**).

---

### UI-05. Buat Order — Step 1 `Data Pengiriman` (tipe `Normal`)
**File:** `018.png` (state awal, Tipe Pengiriman kosong), `019.png` (form lengkap)

| Elemen | Tipe | Label / Placeholder | State terlihat | Selector Playwright |
|---|---|---|---|---|
| Judul | Heading | `Buat Order` | — | `role=heading name="Buat Order"` · `testid=page-title` |
| Stepper | Nav 4 langkah | `01 Data Pengiriman`, `02 Data Barang`, `03 Vendor dan Harga`, `04 Review` | step 1 aktif, 2–4 netral | `testid=wizard-stepper` · `testid=step-1..4` |
| Card | Section | `Jenis Pengiriman dan Rute` | — | `testid=card-jenis-pengiriman` |
| Jenis pengiriman | Radio card ×4 | `FTL` `Full Truck Load` / `FCL` `Full Container Load` / `LTL` `Less Than Truck Load` / `LCL` `Less Than Container Load` | `FTL` **checked** | `role=radio name="FTL"` · `testid=radio-jenis-ftl` |
| Jenis Armada | Dropdown (wajib) | `Jenis Armada *` / value `Tronton Box` | filled | `role=combobox name="Jenis Armada"` · `testid=select-jenis-armada` · label `Jenis Armada` |
| Jumlah Armada | Number input (wajib) | `Jumlah Armada *` / value `2` | filled | `role=spinbutton name="Jumlah Armada"` · `testid=input-jumlah-armada` |
| Tipe Pengiriman | Dropdown (wajib) | `Tipe Pengiriman *` / `Pilih Tipe Pengiriman` (018) — `Normal` (019) | empty → filled | `role=combobox name="Tipe Pengiriman"` · `testid=select-tipe-pengiriman` |
| Card | Section | `Data Pengirim` | — | `testid=card-data-pengirim` |
| Drop Point Asal | Dropdown (wajib) | `Drop Point Asal *` / `Pilih  Drop Point Asal` | empty | `testid=select-drop-point-asal` |
| Pengirim | Dropdown (wajib) | `Pengirim *` / `Pilih Pengirim` | empty | `testid=select-pengirim` |
| PIC Pengirim | Text (wajib) | `PIC Pengirim *` / `Masukkan PIC Pengirim`, helper `Nama PIC Pengirim` | empty | `testid=input-pic-pengirim` |
| No. WhatsApp PIC | Text (wajib) | `No. WhatsApp PIC *` / `Masukkan No. WhatsApp PIC`, helper `Contoh: 081234567898` | empty | `testid=input-wa-pengirim` |
| Provinsi Asal | Text **read-only** | `Provinsi Asal` / `Provinsi Asal` | disabled/abu | `testid=input-provinsi-asal` |
| Kota/Kab. Asal | Text **read-only** | `Kota/Kab. Asal` | disabled/abu | `testid=input-kota-asal` |
| Kecamatan Asal | Text **read-only** | `Kecamatan Asal` | disabled/abu | `testid=input-kecamatan-asal` |
| Desa/Kelurahan Asal | Text **read-only** | `Desa/Kelurahan Asal` | disabled/abu | `testid=input-desa-asal` |
| Kode Pos | Text **read-only** | `Kode Pos` | disabled/abu | `testid=input-kode-pos-asal` |
| Alamat Asal | Textarea **read-only** | `Alamat Asal` | disabled/abu | `testid=textarea-alamat-asal` |
| Catatan | Textarea (opsional) | `Catatan` / `Masukkan Catatan` | empty | `testid=textarea-catatan-pengirim` |
| Card | Section | `Data Penerima` | — | `testid=card-data-penerima` |
| — | (cermin Data Pengirim) | `Drop Point Tujuan *`, `Penerima *`, `PIC Penerima *`, `No. WhatsApp PIC *`, `Provinsi Tujuan`, `Kota/Kab. Tujuan`, `Kecamatan Tujuan`, `Desa/Kelurahan Tujuan`, `Kode Pos`, `Alamat Tujuan`, `Catatan` | idem | `testid=select-drop-point-tujuan`, `testid=input-pic-penerima`, … |
| Batal | Button (danger outline) | `Batal` | enabled | `role=button name="Batal"` · `testid=btn-batal` |
| Simpan ke Draf | Button (outline) | `Simpan ke Draf` | enabled (019); **tidak dirender di 018** | `role=button name="Simpan ke Draf"` · `testid=btn-simpan-draf` |
| Selanjutnya | Button (primary, ikon →) | `Selanjutnya` | **disabled (018)** → enabled (019) | `role=button name="Selanjutnya"` · `testid=btn-selanjutnya` |

**State terlihat:** `empty` (018/019), `disabled` (tombol `Selanjutnya` 018), `read-only` (field wilayah). **Tidak ada** state error inline Step 1 di desain (**ASM-043**).

---

### UI-06. Step 1 — varian tipe pengiriman multi
**File:** `037.png` (Multipickup), `044.png` (Multidrop), `051.png` (Multipoint)

| Elemen | Tipe | Teks | State | Selector |
|---|---|---|---|---|
| Tipe Pengiriman | Dropdown | `Multipickup` / `Multidrop` / `Multipoint` | filled | `testid=select-tipe-pengiriman` |
| Jumlah Armada | Number | `3` (037) / `2` (044,051) | filled | `testid=input-jumlah-armada` |
| Sub-card pengirim | Section berulang | `Pick Up 1`, `Pick Up 2`, `Pick Up 3` (037,051) | 3 blok | `testid=block-pickup-{n}` |
| Sub-card penerima | Section berulang | `Drop Off 1`, `Drop Off 2` (044,051) | 2 blok | `testid=block-dropoff-{n}` |
| Hapus baris | Icon button (trash, merah) | — | tampil pada blok ke-2 dst; **tidak** pada blok ke-1 | `role=button name=/hapus/i` · `testid=btn-hapus-pickup-{n}` |
| Tambah baris | Link button (+) | `Tambah Baris Input` | enabled | `role=button name="Tambah Baris Input"` · `testid=btn-tambah-baris` |
| Label WA varian | Text (wajib) | `Nomor WhatsApp PIC *` (blok multi) vs `No. WhatsApp PIC *` (blok tunggal) | inkonsistensi label | matcher toleran `/No(mor)? WhatsApp PIC/` |
| Label kota varian | Text read-only | `Kota/Kab. Pengirim Asal` (037/051) vs `Kota/Kab. Asal` (019) | inkonsistensi label | matcher toleran `/Kota\/Kab\./` |

---

### UI-07. Buat Order — Step 2 `Data Barang` (tipe `Normal`)
**File:** `020.png` (floating button **kolaps/ikon saja**), `021.png` (floating button **hover → berlabel**)

| Elemen | Tipe | Label / Placeholder | State terlihat | Selector Playwright |
|---|---|---|---|---|
| Stepper | Nav | step 1 **checked**, step `02 Data Barang` aktif | — | `testid=step-2` |
| Floating `Hitung Ulang Armada` | FAB (ikon refresh) | ikon saja (020) → `Hitung Ulang Armada` saat hover (021) | enabled (ada barang) | `role=button name="Hitung Ulang Armada"` (via `aria-label`) · `testid=fab-hitung-ulang-armada` |
| Floating `Visualisasi Terbaru` | FAB (ikon mata, primary) | ikon saja (020) → `Visualisasi Terbaru` saat hover (021) | enabled | `role=button name="Visualisasi Terbaru"` · `testid=fab-visualisasi-terbaru` |
| Card `Data Unit` | Section read-only | `Jenis Armada` = `Tronton Box`; `Jumlah Armada` = `2` | read-only | `testid=card-data-unit` · `testid=text-data-unit-jenis-armada` |
| Card armada | Section berulang | `Armada 1`, `Armada 2`, `Armada 3` | 3 blok meski Jumlah Armada = 2 → **ASM-041** | `testid=card-armada-{n}` |
| Tambahkan Asuransi | Checkbox (per armada) | `Tambahkan Asuransi`, helper `Berlaku untuk seluruh barang pada armada ini` | **checked** (Armada 1), unchecked (Armada 2/3) | `role=checkbox name="Tambahkan Asuransi"` · `testid=checkbox-asuransi-armada-{n}` |
| Nomor DO | Chips input (opsional) | `Nomor DO` / `Masukkan Nomor DO`, helper `Pisahkan dengan koma untuk menambahkan beberapa nomor` | filled: chip `TGK783898202U ✕`, `TBL28371302 ✕` (Armada 1/2); empty (Armada 3) | `testid=input-nomor-do-armada-{n}` · chip `testid=chip-nomor-do` · hapus chip `role=button name=/hapus/i` |
| Tabel barang | Table | Kol: `Kode SKU`/`Nama Barang`, `Kemasan`, `Kubikasi`/`Dimensi`, `Berat`, `Jumlah`, `Nilai Barang`*, (aksi) | `Nilai Barang` **hanya** pada armada berasuransi | `testid=table-barang-armada-{n}` |
| Sel read-only | Text | `SKU-PPR-001` / `Kertas HVS A4 80 gsm`, `Dus`, `0,018 m³` / `31 × 22 × 26,4 cm`, `12,5 kg` | read-only | `testid=cell-kode-sku` … |
| Jumlah | Number input (wajib) | placeholder `0`, value `200` | filled / **error** (border merah + `0`) | `testid=input-jumlah-{sku}` · `role=spinbutton` |
| Nilai Barang | Currency input (kondisional wajib) | prefix `Rp`, placeholder `0`, value `1.320.000` | filled / **error** | `testid=input-nilai-barang-{sku}` |
| Helper error | Text error | `Nilai Barang harus diisi` · `Jumlah harus diisi` | **error** | `testid=error-nilai-barang-{sku}` / `testid=error-jumlah-{sku}` |
| Hapus baris | Icon button (trash merah) | — | enabled per baris | `role=button name=/hapus/i` · `testid=btn-hapus-barang-{sku}` |
| Pilih Barang | Button (outline, +) | `Pilih Barang` | enabled | `role=button name="Pilih Barang"` · `testid=btn-pilih-barang-armada-{n}` |
| Alert kapasitas | Chip warning merah | `Kubikasi melebihi kapasitas armada` (Armada 1) · `Berat melebihi kapasitas armada` (Armada 2) | **warning non-blocking** (`Selanjutnya` tetap aktif) | `testid=alert-kapasitas-armada-{n}` |
| Total per armada | Text | `Total Kubikasi: 19,2 / 17,86 m³` · `Total Berat: 19.200 / 24.800 kg` | terlampaui / normal (`0 / 17,86 m³`) | `testid=total-kubikasi-armada-{n}` / `testid=total-berat-armada-{n}` |
| Empty state | Row placeholder | `Belum ada barang. Klik "Pilih Barang "` | **empty** (Armada 3) | `testid=empty-state-barang-armada-{n}` |
| Footer | Buttons | `Batal`, `Sebelumnya`, `Simpan ke Draf`, `Selanjutnya` | semua enabled | `testid=btn-batal` / `btn-sebelumnya` / `btn-simpan-draf` / `btn-selanjutnya` |

**Pesan validasi yang tampak:** `Jumlah harus diisi`, `Nilai Barang harus diisi`.
**Alert kapasitas gabungan** (`Kubikasi dan Berat melebihi kapasitas armada`) **tidak ada** di desain → **ASM-031**.

---

### UI-08. Modal `Pilih Barang`
**File:** `022.png`

| Elemen | Tipe | Teks / Placeholder | State terlihat | Selector |
|---|---|---|---|---|
| Dialog | Modal | judul `Pilih Barang`, subjudul `Pilih barang yang ingin ditambahkan ke order` | open | `role=dialog name="Pilih Barang"` · `testid=modal-pilih-barang` |
| Pencarian | Search input + ikon | `Cari kode/nama barang` | empty | `role=searchbox name=/cari/i` · `testid=input-cari-barang` |
| Item barang | Checkbox + label + meta | `SKU-PPR-001 - Kertas HVS A4 80 gsm` / meta `Dus • 0,018 m³ • 12,5 kg` | unchecked | `role=checkbox name=/SKU-PPR-001/` · `testid=checkbox-barang-{sku}` |
| Item terpilih | Checkbox checked | `SKU-PPR-002 …`, `SKU-BKU-001 …` | **checked** | idem |
| Badge | Label | `Sudah Ditambahkan` | tampil pada SKU-PPR-002 & SKU-BKU-001 (keduanya checked & tetap aktif → **ASM-034**) | `testid=badge-sudah-ditambahkan` |
| Daftar item lain | — | `SKU-BKU-002 - Buku Tulis Hard Cover A5` (`Dus • 0,042 m³ • 13,2 kg`), `SKU-ATK-001 - Pulpen Gel Hitam 0.5 mm` (`Dus • 0,035 m³ • 9,5 kg`) | scrollable list | `testid=list-master-barang` |
| Counter | Text | `3 barang terpilih` | 3 terpilih | `testid=counter-barang-terpilih` |
| Batal | Button (danger outline) | `Batal` | enabled | `role=button name="Batal"` · `testid=btn-modal-batal` |
| Simpan | Button (primary) | `Simpan` | enabled | `role=button name="Simpan"` · `testid=btn-modal-simpan` |

**Tidak ada** desain untuk hasil pencarian kosong / loading (**ASM-043**).

---

### UI-09. Drawer `Hitung Ulang Armada`
**File:** `023.png` (muat), `024.png` (ada overflow muatan)

| Elemen | Tipe | Teks | State | Selector |
|---|---|---|---|---|
| Drawer | Panel kanan (overlay) | judul `Hitung Ulang Armada`, subjudul `Simulasi ulang kebutuhan unit dari muatan order ini. Terapkan untuk ubah data order.` | open | `role=dialog name="Hitung Ulang Armada"` · `testid=drawer-hitung-ulang-armada` |
| Total Kubikasi | Text read-only | `Total Kubikasi` = `22,8 m³` | — | `testid=text-total-kubikasi` |
| Total Berat | Text read-only | `Total Berat` = `12.140 kg` | — | `testid=text-total-berat` |
| Jenis Pengiriman | Text read-only | `Jenis Pengiriman` = `FTL` | — | `testid=text-jenis-pengiriman` |
| Section rekomendasi | Heading | `Armada` | — | `testid=section-rekomendasi-armada` |
| Kartu rekomendasi 1 | Card selectable | `Armada` · `Tronton Wing Box` · `2 Unit • 15.000 Kg • 51,36 m³` · badge `Paling Efisien` · `Berat Terpakai 78%` · `Ruang Terpakai 82%` | **selected** (border biru) | `testid=card-rekomendasi-1` · badge `testid=badge-paling-efisien` |
| Kartu rekomendasi 2 | Card | `Tronton Box` · `2 Unit • 15.000 Kg • 51,36 m³` · `78%` / `82%` | unselected | `testid=card-rekomendasi-2` |
| Kartu rekomendasi 3 | Card | `Fuso Box` · `3 Unit • 8.000 kg • 31,74 m³` · `47%` / `71%` | unselected | `testid=card-rekomendasi-3` |
| Jenis Armada | Text read-only (wajib) | `Jenis Armada *` = `Tronton Wing Box` | read-only | `testid=field-drawer-jenis-armada` |
| Pilih Jenis Armada | Button (outline) | `Pilih Jenis Armada` | enabled → buka modal (tidak ada desainnya) | `role=button name="Pilih Jenis Armada"` · `testid=btn-pilih-jenis-armada` |
| Jumlah Armada | Number + stepper | `Jumlah Armada *` = `2`, tombol `−` / `+` | enabled | `testid=input-drawer-jumlah-armada` · `testid=btn-jumlah-minus` / `btn-jumlah-plus` |
| Info kapasitas | Text | `Berat Maksimal 1 Armada: 15.000 kg • Kubikasi Maksimal 1 Armada: 51,36 m³` | — | `testid=text-kapasitas-armada` |
| Section visualisasi | Heading | `Visualisasi Muatan` | — | `testid=section-visualisasi-muatan` |
| Tab armada | Tablist | `Armada 1` (aktif), `Armada 2` | 2 tab = jumlah armada | `role=tab name="Armada 1"` · `testid=tab-visualisasi-armada-{n}` |
| Progress | Bar + % | `Berat Terpakai 78%`, `Ruang Terpakai 82%` | — | `testid=progress-berat-terpakai` / `progress-ruang-terpakai` |
| Kanvas 3D | Canvas | overlay `1306 koli • 19.995 kg dialokasikan ke unit ini`; hint `Drag: putar 360° • Scroll: zoom • Klik 2×: reset` | rendered | `testid=canvas-visualisasi-3d` (assert via teks pendamping → **ASM-044**) |
| Badge overflow | Chip merah | `110 koli melebihi kapasitas (outline merah)` | **hanya di 024** | `testid=badge-overflow-kapasitas` |
| Legenda | Chips warna | `Kertas HVS A4 80 gsm`, `Kertas HVS F4 70 gsm`, `Buku Tulis 38 Lembar` | — | `testid=legend-visualisasi` |
| Batal | Button (danger outline) | `Batal` | enabled | `role=button name="Batal"` · `testid=btn-drawer-batal` |
| Terapkan ke Order | Button (primary) | `Terapkan ke Order` | enabled | `role=button name="Terapkan ke Order"` · `testid=btn-terapkan-ke-order` |

---

### UI-10. Panel `Visualisasi Muatan Saat Ini` (dari floating `Visualisasi Terbaru`)
**File:** `025.png`

| Elemen | Tipe | Teks | State | Selector |
|---|---|---|---|---|
| Drawer | Panel kanan | judul `Visualisasi Muatan Saat Ini`; subjudul **sama persis** dengan drawer Hitung Ulang (`Simulasi ulang kebutuhan unit dari muatan order ini. Terapkan untuk ubah data order.`) | open | `role=dialog name="Visualisasi Muatan Saat Ini"` · `testid=drawer-visualisasi-terbaru` |
| Ringkasan | Text read-only | `Total Kubikasi 22,8 m³`, `Total Berat 12.140 kg`, `Jenis Pengiriman FTL` | read-only | `testid=text-total-kubikasi` … |
| Card `Armada` | Read-only grid | `Jenis Armada` `Tronton Box` · `Jumlah Armada` `2` · `Berat Maksimal` `20.000 kg` · `Kubikasi Maksimal` `60 m³` | **read-only — tidak ada kartu rekomendasi & tidak ada input** | `testid=card-armada-readonly` |
| Visualisasi | Tabs + kanvas + legenda + badge overflow | idem UI-09 | — | `testid=section-visualisasi-muatan` |
| Footer | Buttons | `Batal`, **`Terapkan ke Order`** | **anomali:** tombol terap masih ada padahal panel read-only → **ASM-030** | `testid=btn-drawer-batal` / `btn-terapkan-ke-order` |

---

### UI-11. Step 2 — varian tipe pengiriman multi
**File:** `038.png` (Multipickup), `045.png` (Multidrop), `052.png` (Multipoint)

| Elemen | Tipe | Teks | State | Selector |
|---|---|---|---|---|
| Card armada | Section | `Armada 1`, `Armada 2` | 2 blok | `testid=card-armada-{n}` |
| Checkbox asuransi | Checkbox | `Tambahkan Asuransi` — tetap di **level armada** | checked (Armada 1) | `testid=checkbox-asuransi-armada-{n}` |
| Sub-section alamat (Multipickup) | Header baris | `Pick Up 1 - Jl. Jambi No.35, Darmo, Wonokromo, Kota Surabaya, Jawa Timur 60241`; `Pick Up 2 - Jl. Kalianyar Buring No.9, …` | 2 sub-section per armada | `testid=subsection-pickup-{m}-armada-{n}` |
| Sub-section alamat (Multidrop) | Header baris | `Drop Off 1 - …`, `Drop Off 2 - …` | 2 sub-section per armada | `testid=subsection-dropoff-{m}-armada-{n}` |
| Sub-section (Multipoint) | Header 2 kolom | kiri `Pick Up n - <alamat>` \| kanan `Drop Off m - <alamat>` | **4 sub-section per armada** (2×2 = kartesian) | `testid=subsection-pickup-{m}-dropoff-{k}-armada-{n}` |
| Nomor DO | Chips input | **per sub-section alamat** (bukan per armada) | filled/empty | `testid=input-nomor-do-{subsection}` → **ASM-036** |
| Tabel barang | Table | idem UI-07, `Nilai Barang` hanya bila armada berasuransi | populated | `testid=table-barang-{subsection}` |
| Alert & total | Chip + text | `Kubikasi melebihi kapasitas armada` / `Berat melebihi kapasitas armada`, `Total Kubikasi: 19,2 / 17,86 m³`, `Total Berat: 25.400 / 24.800 kg` | warning | `testid=alert-kapasitas-{subsection}` |
| Pilih Barang | Button | `Pilih Barang` | per sub-section | `testid=btn-pilih-barang-{subsection}` |

---

### UI-12. Buat Order — Step 3 `Vendor dan Harga` (tipe `Normal`)
**File:** `026.png` (kosong, rute belum ada di master), `027.png` (terisi + asuransi), `028.png` (terisi tanpa asuransi)

| Elemen | Tipe | Label / Placeholder | State terlihat | Selector |
|---|---|---|---|---|
| Card | Section | `Vendor dan Harga` | — | `testid=card-vendor-harga` |
| Vendor | Dropdown (wajib) | `Vendor *` / `Pilih Vendor` → `PT Logistik Transportasi Nusantara` | empty → filled | `role=combobox name="Vendor"` · `testid=select-vendor` |
| Tanggal Permintaan Muat | Datetime input (wajib) | `Tanggal Permintaan Muat *` / `DD/MM/YYYY hh:mm` → `24/07/2026 14:30` | empty → filled | `testid=input-tanggal-permintaan-muat` |
| Ringkasan rute | Text read-only | `Drop Point Asal : Gudang MSK Region 2 • Kota Surabaya`; `Drop Point Tujuan : Gudang Jaya Retail Malang • Kota Malang`; `Jenis Armada : Tronton Wing Box` | read-only | `testid=summary-drop-point-asal` … |
| Waktu Perjalanan (kondisi A) | Number + suffix `Jam` (wajib) | `Waktu Perjalanan *` / `0` → `8` | **textfield** (026/028) — rute belum ada di master | `testid=input-waktu-perjalanan` |
| Alert rute | Alert info (kuning) | `Rute belum ada di Master Waktu Perjalanan. Isi waktu perjalanan, nilainya akan otomatis tersimpan sebagai data master baru.` | tampil bersama kondisi A | `role=status` · `testid=alert-rute-belum-ada` |
| Waktu Perjalanan (kondisi B) | Text-only | `Waktu Perjalanan : 8 Jam` | **read-only** (027) — rute sudah ada di master | `testid=text-waktu-perjalanan` |
| Tabel armada | Table | `No`, `Nama Item`, `Total Berat`, `Total Kubikasi`, `Total Nilai Barang` | 2 baris: `Armada 1` `25.570 kg` `56,10 m³` `Tanpa Asuransi`; `Armada 2` `22.950 kg` `53,90 m³` `Rp1.150.350.000` | `testid=table-ringkasan-armada` |
| Harga | Currency input (wajib) | `Harga *` / `Rp 0` → `Rp 12.000.000`, helper `Mencakup seluruh biaya armada pada order ini` | empty → filled | `testid=input-harga` |
| Gunakan komponen harga | Checkbox | `Gunakan komponen harga` | unchecked (026) → **checked** (027/028) | `role=checkbox name="Gunakan komponen harga"` · `testid=checkbox-komponen-harga` |
| PPN | Percent input | `PPN` `1,1` `%` | tampil saat checkbox aktif | `testid=input-ppn` |
| PPh | Percent input | `PPh` `2` `%` | tampil saat checkbox aktif | `testid=input-pph` |
| Asuransi | Percent input | `Asuransi` `0,2` `%` | **hanya 027** (ada armada berasuransi); **tidak dirender di 028** | `testid=input-asuransi` |
| Ringkasan harga | Text | `Harga DPP Rp. 12.000.000`; `PPN (1,1%) Rp. 132.000`; `PPh (2%) - Rp. 240.000`; `Asuransi (0,2%) Rp2.300.700` + `(Total Nilai Barang = Rp. 63.620.000`; `Total Harga Rp14.192.700` (027) / `Rp. 11.892.000` (028) / `Rp. 0` (026) | computed | `testid=summary-harga-dpp` … `testid=summary-total-harga` |
| Footer | Buttons | `Batal`, `Sebelumnya`, `Simpan ke Draf`, `Selanjutnya` | enabled | `testid=btn-batal` / `btn-sebelumnya` / `btn-simpan-draf` / `btn-selanjutnya` |

> Teks `(Total Nilai Barang = Rp. 63.620.000` tampil **tanpa kurung tutup** pada desain → gunakan matcher substring.

---

### UI-13. Step 3 — varian tipe multi + pop up rincian alamat
**File:** `039.png` (Multipickup), `046.png` (Multidrop), `053.png` (Multipoint) · pop up: `040.png`, `054.png` (Multipickup), `047.png`, `055.png` (Multidrop)

| Elemen | Tipe | Teks | State | Selector |
|---|---|---|---|---|
| Card 1 | Section | `Vendor` (bukan `Vendor dan Harga`) | — | `testid=card-vendor` |
| Card 2 | Section | `Harga Pengiriman` | — | `testid=card-harga-pengiriman` |
| Ringkasan asal | Label + text link | `Drop Point Asal : Multipickup • Lihat Detail` (039/053) | link aktif | `role=link name="Lihat Detail"` · `testid=link-detail-multipickup` |
| Ringkasan tujuan | Label + text link | `Drop Point Tujuan : Multidrop • Lihat Detail` (046/053) | link aktif | `testid=link-detail-multidrop` |
| Pop up rincian | Dialog | `Detail Multipickup` / `Detail Multidrop` + tombol `✕` | open | `role=dialog name="Detail Multipickup"` · `testid=modal-detail-alamat` |
| Isi pop up | List | `Pick Up 1 - Kota Surabaya` → `Gudang MSK Region 2:` → `Jl. Jambi No.35, Darmo, Wonokromo, Kota Surabaya, Jawa Timur 60241` (3 entri untuk Multipickup, 2 entri untuk Multidrop) | — | `testid=detail-alamat-item-{n}` |
| Tabel armada | Table | 039/046/053 menampilkan **3 baris** dengan label `Armada 1`, `Armada 2`, `Armada 2` walau `Jumlah Armada = 2` | data mock inkonsisten → **ASM-041** | `testid=table-ringkasan-armada` |

---

### UI-14. Buat Order — Step 4 `Review`
**File:** `029.png` (Normal), `041.png`+`042.png` (Multipickup, identik), `047a.png` (Multidrop), `056.png` (Multipoint)

| Elemen | Tipe | Teks | State | Selector |
|---|---|---|---|---|
| Stepper | Nav | step 1–3 **checked**, `04 Review` aktif | — | `testid=step-4` |
| Card 1 (collapsible) | Section + chevron | `Jenis Pengiriman dan Rute`: `Jenis Pengiriman : FTL (Full Truck Load)`, `Jenis Armada : Tronton Wing Box`, `Jumlah Armada : 2`, `Tipe Pengiriman : Normal`, `Waktu Perjalanan : 8 Jam` | **read-only**, expanded | `testid=card-review-rute` · toggle `testid=toggle-card-rute` |
| Card 2 | Section | `Data Pengirim` (Drop Point Asal, Pengirim, PIC Pengirim, No. WhatsApp PIC, Provinsi/Kota/Kecamatan/Desa/Kode Pos/Alamat Asal, Catatan) | read-only | `testid=card-review-pengirim` |
| Card 3 | Section | `Data Penerima` (idem tujuan; `Catatan : -` bila kosong) | read-only | `testid=card-review-penerima` |
| Card 4 | Section | `Data Barang` | read-only | `testid=card-review-barang` |
| Visualisasi Muatan | Button (outline, ikon mata) | `Visualisasi Muatan` | enabled → pop up UI-17 | `role=button name="Visualisasi Muatan"` · `testid=btn-visualisasi-muatan` |
| Grup armada | Heading | `Armada 1`; `Armada 2` + badge `Diasuransikan` | badge hanya pada armada berasuransi | `testid=group-armada-{n}` · `testid=badge-diasuransikan` |
| Nomor DO | Text read-only | `TBL67827879232, TBL726378927398` / `-` | read-only | `testid=text-nomor-do-armada-{n}` |
| Tabel barang | Table | `Kode SKU`/`Nama Barang`, `Kemasan`, `Kubikasi`/`Dimensi`, `Berat`, `Jumlah`, (`Nilai Barang` hanya armada berasuransi) | read-only | `testid=table-review-barang-armada-{n}` |
| Sub-section alamat | Header baris | (varian multi) `Pick Up 1 - …` / `Drop Off 1 - …` / kombinasi `Pick Up n` \| `Drop Off m` | read-only | `testid=subsection-review-{...}` |
| Card 5 | Section | `Vendor dan Harga` + tabel `No`/`Nama Item`/`Total Berat`/`Total Kubikasi`/`Total Nilai Barang`, `Vendor :`, `Tanggal Permintaan Muat :`, ringkasan `Harga DPP` / `PPN (1,1%)` / `PPh (2%)` / `Asuransi (0,2%)` + `(Total Nilai Barang = Rp1.006.750.000` / `Total Harga Rp13.905.500` | read-only | `testid=card-review-vendor-harga` |
| Footer | Buttons | `Batal`, `Sebelumnya`, `Simpan ke Draf`, **`Simpan`** | enabled | `role=button name="Simpan"` · `testid=btn-simpan` |

---

### UI-15. Pop up konfirmasi `Simpan ke Draf`
**File:** `030.png`

| Elemen | Tipe | Teks | State | Selector |
|---|---|---|---|---|
| Dialog | Modal konfirmasi | judul `Anda yakin ingin menyimpan data dalam draf?`; body `Data yang telah diisi akan disimpan sebagai draf` | open (di atas Step 4) | `role=dialog` · `testid=modal-konfirmasi-draf` |
| Batal | Button (outline) | `Batal` | enabled | `role=button name="Batal"` · `testid=btn-konfirmasi-batal` |
| Simpan Draf | Button (primary) | `Simpan Draf` | enabled | `role=button name="Simpan Draf"` · `testid=btn-konfirmasi-simpan-draf` |

> Label tombol konfirmasi = `Simpan Draf` (bukan `Simpan ke Draf`) → matcher toleran `/Simpan\s*(ke\s*)?Draf/`.

---

### UI-16. Detail Order
**File:** `031.png` (Normal), `043a.png` (Multipickup), `048.png` (Multidrop), `057a.png` (Multipoint)

| Elemen | Tipe | Teks | State | Selector |
|---|---|---|---|---|
| Judul + back | Heading + icon button `‹` | `Detail Order` | — | `role=heading name="Detail Order"` · `testid=btn-back` |
| Visualisasi Muatan | Button (outline, ikon mata) | `Visualisasi Muatan` | enabled | `role=button name="Visualisasi Muatan"` · `testid=btn-visualisasi-muatan` |
| Batalkan Order | Button (danger outline) | `Batalkan Order` | enabled (status `Menunggu Penugasan`) | `role=button name="Batalkan Order"` · `testid=btn-batalkan-order` |
| Edit Order | Button (outline) | `Edit Order` | enabled (status `Menunggu Penugasan`) | `role=button name="Edit Order"` · `testid=btn-edit-order` |
| Chip status | Badge | `Menunggu Penugasan` | — | `testid=chip-status-order` |
| Card rute | Section | `Jenis Pengiriman dan Rute`: `ID Order : ORD67890792`, `Jenis Pengiriman : FTL (Full Truck Load)`, `Tanggal Dibuat : 26/06/2026 08:17`, `Jenis Armada`, `Jumlah Armada`, `Tipe Pengiriman`, `Waktu Perjalanan : 8 Jam` | read-only | `testid=card-detail-rute` |
| Card pengirim/penerima/barang/vendor | Sections | identik Step 4 (termasuk badge `Diasuransikan`, sub-section alamat pada tipe multi) | read-only | `testid=card-detail-*` |

> **Tidak ada** blok `No. Perjalanan` pada desain Detail Order (status contoh masih `Menunggu Penugasan`) → REQ-078 belum ter-cover desain (**ASM-043**).

---

### UI-17. Pop up `Visualisasi Muatan` (dari Review / Detail Order)
**File:** `031a.png`

| Elemen | Tipe | Teks | State | Selector |
|---|---|---|---|---|
| Dialog | Modal tengah | judul `Visualisasi Muatan` + tombol `✕` | open | `role=dialog name="Visualisasi Muatan"` · `testid=modal-visualisasi-muatan` |
| Tab armada | Tablist | `Armada 1` (aktif), `Armada 2` | 2 tab | `role=tab name="Armada 1"` · `testid=tab-visualisasi-armada-{n}` |
| Progress | Bar | `Berat Terpakai 78%`, `Ruang Terpakai 82%` | — | `testid=progress-berat-terpakai` / `progress-ruang-terpakai` |
| Kanvas 3D | Canvas | `1306 koli • 19.995 kg dialokasikan ke unit ini`; hint `Drag: putar 360° • Scroll: zoom • Klik 2×: reset`; badge `110 koli melebihi kapasitas (outline merah)` | rendered + overflow | `testid=canvas-visualisasi-3d` |
| Legenda | Chips | `Kertas HVS A4 80 gsm`, `Kertas HVS F4 70 gsm`, `Buku Tulis 38 Lembar` | — | `testid=legend-visualisasi` |

> **Tidak ada** tombol footer — hanya `✕` (berbeda dari drawer UI-09/UI-10).

---

### UI-18. Modal `Batalkan Order`
**File:** `032.png`

| Elemen | Tipe | Teks / Placeholder | State | Selector |
|---|---|---|---|---|
| Dialog | Modal | judul `Batalkan Order` + `✕` | open (di atas Detail Order) | `role=dialog name="Batalkan Order"` · `testid=modal-batalkan-order` |
| ID Order | Text read-only | `ID Order : ORD-20260607009` | read-only | `testid=text-id-order` |
| Vendor | Text read-only | `Vendor : PT Logistik Transportasi Nusantara` | read-only | `testid=text-vendor` |
| Alasan Pembatalan | Textarea (wajib) | `Alasan Pembatalan *` / `Tuliskan alasan pembatalan order` | **empty** | `role=textbox name="Alasan Pembatalan"` · `testid=textarea-alasan-pembatalan` · label `Alasan Pembatalan` |
| Batalkan Order | Button (danger, primary) | `Batalkan Order` | enabled | `role=button name="Batalkan Order"` · `testid=btn-submit-batalkan-order` |

> **Tidak ada** tombol sekunder `Batal` (hanya `✕`), dan **tidak ada** state error validasi di desain → **ASM-040**.

---

### UI-19. Edit Order
**File:** `033.png` (Normal), `043.png` (Multipickup), `049.png` (Multidrop), `057.png` (Multipoint)

| Elemen | Tipe | Teks / Placeholder | State | Selector |
|---|---|---|---|---|
| Judul | Heading | `Edit Order` | — | `role=heading name="Edit Order"` · `testid=page-title` |
| Card rute | Section (collapsible) | `Jenis Pengiriman dan Rute` | — | `testid=card-edit-rute` |
| ID Order / Tanggal Dibuat / Jenis Pengiriman / Tipe Pengiriman / Waktu Perjalanan | Text **read-only** | `ORD67890792`, `26/06/2026 08:17`, `FTL (Full Truck Load)`, `Normal`\|`Multipickup`\|`Multidrop`\|`Multipoint`, `8 Jam` | **locked** (sesuai REQ-063) | `testid=text-tipe-pengiriman` (assert bukan `combobox`) |
| Jenis Armada | Dropdown (wajib) | `Jenis Armada *` = `Tronton Box` | **editable** | `role=combobox name="Jenis Armada"` · `testid=select-jenis-armada` |
| Jumlah Armada | Number (wajib) | `Jumlah Armada *` = `1` | **editable** (nilai `1` tapi 2 blok armada dirender → **ASM-041**) | `testid=input-jumlah-armada` |
| Data Pengirim / Data Penerima | Sections editable | idem Step 1 (termasuk `Pick Up n` / `Drop Off n` + `Tambah Baris Input` pada tipe multi) | editable | `testid=card-data-pengirim` / `card-data-penerima` |
| Card barang | Section berulang | `Data Barang - Armada 1`, `Data Barang - Armada 2` — **kecuali `043.png` yang memakai `Data Barang - Kontainer 1/2`** | editable | `testid=card-edit-barang-armada-{n}` (matcher toleran `/Data Barang - (Armada|Kontainer) \d/`) |
| Elemen dalam card barang | idem UI-07/UI-11 | `Tambahkan Asuransi`, `Nomor DO` (chips), tabel + `Jumlah`/`Nilai Barang`, ikon hapus, `Pilih Barang`, alert kapasitas, total | editable + warning | idem UI-07 |
| Card vendor | Section | `Vendor dan Harga` (`Vendor *`, `Tanggal Permintaan Muat *`, tabel ringkasan, `Harga *`, `Gunakan komponen harga`, `PPN`/`PPh`/`Asuransi`, ringkasan `Total Harga`) | editable | `testid=card-vendor-harga` |
| Batal | Button (danger outline) | `Batal` | enabled | `role=button name="Batal"` · `testid=btn-batal` |
| Simpan | Button (primary) | `Simpan` | enabled | `role=button name="Simpan"` · `testid=btn-simpan` |

> Pop up konfirmasi untuk `Batal`/`Simpan` (REQ-065) **tidak ada** di desain → **ASM-039**.

---

### Katalog Teks Persis dari Desain (untuk assertion)

| Teks persis | Jenis | Lokasi | File |
|---|---|---|---|
| `Kubikasi melebihi kapasitas armada` | Warning chip | Step 2 / Edit Order, per armada/sub-section | 020, 021, 033, 038, 043, 045, 049, 052, 057 |
| `Berat melebihi kapasitas armada` | Warning chip | idem | 020, 021, 038, 045, 049, 052 |
| `Jumlah harus diisi` | Helper error | Step 2, di bawah input `Jumlah` | 020, 021 |
| `Nilai Barang harus diisi` | Helper error | Step 2, di bawah input `Nilai Barang` | 020, 021 |
| `Belum ada barang. Klik "Pilih Barang "` | Empty state | Tabel barang armada kosong | 020, 021 |
| `Berlaku untuk seluruh barang pada armada ini` | Helper checkbox | Step 2 / Edit Order | 020, 038, 045, 052 |
| `Pisahkan dengan koma untuk menambahkan beberapa nomor` | Helper input | Field `Nomor DO` | 020, 038, 045, 052 |
| `Sudah Ditambahkan` | Badge | Modal Pilih Barang | 022 |
| `3 barang terpilih` | Counter | Modal Pilih Barang | 022 |
| `Pilih barang yang ingin ditambahkan ke order` | Subjudul modal | Modal Pilih Barang | 022 |
| `Cari kode/nama barang` | Placeholder | Modal Pilih Barang | 022 |
| `Simulasi ulang kebutuhan unit dari muatan order ini. Terapkan untuk ubah data order.` | Subjudul drawer | Drawer Hitung Ulang **dan** panel Visualisasi Terbaru | 023, 024, 025 |
| `Paling Efisien` | Badge rekomendasi | Drawer, kartu ke-1 | 023, 024 |
| `Berat Terpakai` / `Ruang Terpakai` | Indikator | Drawer, panel, pop up | 023–025, 031a |
| `Berat Maksimal 1 Armada: 15.000 kg` · `Kubikasi Maksimal 1 Armada: 51,36 m³` | Info kapasitas | Drawer | 023, 024 |
| `1306 koli • 19.995 kg dialokasikan ke unit ini` | Overlay kanvas | Visualisasi 3D | 023–025, 031a |
| `Drag: putar 360° • Scroll: zoom • Klik 2×: reset` | Hint kanvas | Visualisasi 3D | 023–025, 031a |
| `110 koli melebihi kapasitas (outline merah)` | Badge overflow | Visualisasi 3D | 024, 025, 031a |
| `Rute belum ada di Master Waktu Perjalanan. Isi waktu perjalanan, nilainya akan otomatis tersimpan sebagai data master baru.` | Alert info | Step 3 (kondisi rute belum ada) | 026, 028, 039, 040, 046, 047, 053, 054, 055 |
| `Mencakup seluruh biaya armada pada order ini` | Helper input `Harga` | Step 3 | 026, 039, 046, 053 |
| `Gunakan komponen harga` | Checkbox | Step 3 / Edit Order | 026–028, 033, 039, 043, 046, 049, 053, 057 |
| `Tanpa Asuransi` | Nilai sel | Kolom `Total Nilai Barang` | 026–028, 039, 046, 053 |
| `Diasuransikan` | Badge armada | Step 4 / Detail Order | 029, 041, 042, 043a, 047a, 048, 056, 057a |
| `Anda yakin ingin menyimpan data dalam draf?` | Judul konfirmasi | Pop up Simpan Draf | 030 |
| `Data yang telah diisi akan disimpan sebagai draf` | Body konfirmasi | Pop up Simpan Draf | 030 |
| `Tuliskan alasan pembatalan order` | Placeholder | Modal Batalkan Order | 032 |
| `Contoh: 081234567898` | Helper input WA | Step 1 / Edit Order | 019, 037, 044, 051, 033 |
| `Nama PIC Pengirim` / `Nama PIC Penerima` | Helper input PIC | Step 1 / Edit Order | 019, 037, 044, 051 |
| `Menampilkan 1 - 20 data dari 30 data` | Info paginasi | Daftar Order | 016, 017, 034, 036, 050 |

---

### Peta File → Layar

| File | Layar | Varian / State |
|---|---|---|
| `016`, `036`, `050` | UI-01 Daftar Order | populated, tanpa panel filter |
| `017` | UI-01 + UI-02 + UI-03 | filter terbuka + menu aksi (draft & `Menunggu Penugasan`) |
| `034` | UI-01 + UI-02 + UI-03 | menu aksi status `Ditugaskan` (+ `Order Kembali`) |
| `035` | UI-04 | pop up `Data No. Perjalanan` (2 armada) |
| `018` | UI-05 | Step 1 awal — `Tipe Pengiriman` kosong, `Selanjutnya` **disabled**, tanpa `Simpan ke Draf` |
| `019` | UI-05 | Step 1 `Normal` — form lengkap, field wilayah read-only |
| `037` | UI-06 | Step 1 `Multipickup` (Pick Up 1–3) |
| `044` | UI-06 | Step 1 `Multidrop` (Drop Off 1–2) |
| `051` | UI-06 | Step 1 `Multipoint` (Pick Up 1–3 × Drop Off 1–2) |
| `020` | UI-07 | Step 2 `Normal` — FAB **kolaps (ikon saja)**, error `Jumlah`/`Nilai Barang`, alert kapasitas, empty state Armada 3 |
| `021` | UI-07 | idem 020 dengan FAB **hover/berlabel** |
| `022` | UI-08 | modal `Pilih Barang` — 3 terpilih, 2 badge `Sudah Ditambahkan` |
| `023` | UI-09 | drawer `Hitung Ulang Armada` — muatan muat |
| `024` | UI-09 | drawer — **overflow** `110 koli melebihi kapasitas` |
| `025` | UI-10 | panel `Visualisasi Muatan Saat Ini` (read-only + anomali footer) |
| `038` | UI-11 | Step 2 `Multipickup` (2 sub-section/armada) |
| `045` | UI-11 | Step 2 `Multidrop` (2 sub-section/armada) |
| `052` | UI-11 | Step 2 `Multipoint` (**4 sub-section/armada** = kartesian) |
| `026` | UI-12 | Step 3 kosong — `Waktu Perjalanan` **textfield** + alert master rute |
| `027` | UI-12 | Step 3 terisi — `Waktu Perjalanan` **text-only**, komponen harga + `Asuransi` |
| `028` | UI-12 | Step 3 terisi — tanpa armada berasuransi (**tanpa** komponen `Asuransi`) |
| `039` | UI-13 | Step 3 `Multipickup` — 2 card, link `Lihat Detail` |
| `046` | UI-13 | Step 3 `Multidrop` |
| `053` | UI-13 | Step 3 `Multipoint` — 2 link `Lihat Detail` |
| `040`, `054` | UI-13 | pop up `Detail Multipickup` (3 alamat) |
| `047`, `055` | UI-13 | pop up `Detail Multidrop` (2 alamat) |
| `029` | UI-14 | Step 4 Review `Normal` (+ badge `Diasuransikan` Armada 2) |
| `041`, `042` | UI-14 | Step 4 Review `Multipickup` (dua file identik) |
| `047a` | UI-14 | Step 4 Review `Multidrop` |
| `056` | UI-14 | Step 4 Review `Multipoint` |
| `030` | UI-15 | pop up konfirmasi `Simpan Draf` |
| `031` | UI-16 | Detail Order `Normal`, status `Menunggu Penugasan` |
| `043a` | UI-16 | Detail Order `Multipickup` |
| `048` | UI-16 | Detail Order `Multidrop` |
| `057a` | UI-16 | Detail Order `Multipoint` |
| `031a` | UI-17 | pop up `Visualisasi Muatan` dari Detail Order |
| `032` | UI-18 | modal `Batalkan Order` |
| `033` | UI-19 | Edit Order `Normal` |
| `043` | UI-19 | Edit Order `Multipickup` (judul card `Kontainer n`) |
| `049` | UI-19 | Edit Order `Multidrop` |
| `057` | UI-19 | Edit Order `Multipoint` |

---

### Inkonsistensi Desain ↔ Spec (ringkas)

| # | Temuan desain | Spec/REQ terkait | Rekomendasi uji |
|---|---|---|---|
| 1 | Status `Isi Data Dasar` & `Terkirim` | REQ-059 (`Isi Data Pengiriman`, `Selesai`) | matcher toleran `/Isi Data (Dasar|Pengiriman)/`, `/Terkirim|Selesai/` |
| 2 | Step 3 berjudul `Vendor dan Harga` | REQ-002 (`Vendor & Harga`) | matcher `/Vendor (dan|&) Harga/` |
| 3 | Aksi `Order Kembali` (status `Ditugaskan`) | REQ-069/070 | catat sebagai aksi tak terspesifikasi; jangan diasumsikan hilang |
| 4 | Panel `Visualisasi Terbaru` masih punya `Terapkan ke Order` | AC-047.2 (harus **tanpa** terap) | tulis skenario negatif; kandidat defect |
| 5 | `Nomor DO` per **sub-section alamat** pada tipe multi | REQ-026 (“per armada”) | ekspektasi mengikuti desain untuk tipe multi |
| 6 | Pesan alert gabungan tidak ada di desain | AC-029.3 | tetap diuji dari spec, tandai risiko |
| 7 | Edit Order Multipickup memakai `Kontainer n` | REQ-001 (satuan `Armada` untuk FTL) | kandidat defect; matcher toleran |
| 8 | Sidebar aktif `Simulasi Muatan` pada layar Order | — | abaikan sebagai galat mockup |
| 9 | `Armada 3` dirender saat `Jumlah Armada = 2`; Edit Order `Jumlah Armada = 1` dengan 2 blok; Step 3 multi 3 baris dengan 2× `Armada 2` | AC-045.3 | jangan dijadikan ekspektasi; gunakan data uji terkontrol |
| 10 | Modal `Batalkan Order` tanpa tombol sekunder & tanpa state error | AC-068.2 | uji submit kosong dari spec |

---

## Assumptions Log

| ID | Area | Ambiguitas pada Spec | Keputusan yang Diambil | Dampak / Risiko |
|---|---|---|---|---|
| **ASM-001** | Integritas spec | **Penomoran butir melompat.** Blok "Step 2" berjalan `1, 2, 4, 5, …` (tidak ada butir **3**); blok "Drawer" berjalan `1, 3, 4, …` (tidak ada butir **2**). | Diasumsikan **kesalahan penomoran**, bukan rule yang hilang — seluruh isi teks yang ada telah diekstrak. **Tidak ada** REQ yang dibuat untuk butir yang hilang. | **Tinggi.** Bila ternyata ada rule yang terpotong saat penyalinan spec, akan ada gap requirement (khususnya di Step 2 dan drawer). Wajib dikonfirmasi ke sumber spec asli. |
| **ASM-002** | Cakupan modul | Nama modul = `order-ftl-auto-stuffing` (FTL), namun spec L5 menyatakan add-on berlaku untuk **FTL & FCL**, dan L107/L110 menyebut "armada/kontainer". | Cakupan **utama pengujian = FTL** (satuan `Armada`). FCL disebut sebagai cakupan add-on (REQ-006, REQ-074) namun **tidak** dijadikan fokus skenario modul ini — pengujian FCL berada di modul terpisah. | **Sedang.** Bila FCL diharapkan tercakup, jumlah kombinasi skenario bertambah signifikan. |
| **ASM-003** | Referensi TMS | Spec berulang kali menyatakan "sama dengan / identik dengan TMS" (L10, L39, L54, L62, L65, L68) **tanpa merinci** field, format, atau pesan. Dokumen spec TMS tidak tersedia sebagai input. | Detail Step 1 & Step 3 diturunkan dari **teks spec yang ada** + konvensi Order FTL/FCL yang sudah terdokumentasi pada modul kerabat `oms014-order-ftl-fcl-normal` + *grounding* aset desain. REQ untuk bagian "identik TMS" ditulis pada **level rule** (bukan level field detail). | **Tinggi.** Merupakan sumber gap terbesar. Skenario Step 1/Step 3 sebaiknya memakai assertion pada level perilaku (navigasi tertahan, data ter-carry) sebelum dikunci ke teks pesan spesifik. |
| **ASM-004** | Nama step | Spec menyebut "4 step pengisian (Data Pengiriman, Data Barang, Vendor & Harga, Review)" tanpa penomoran/format label pasti. | Nama step ditetapkan persis: `Data Pengiriman`, `Data Barang`, `Vendor & Harga`, `Review` (penomoran `01`–`04` mengikuti pola desain). | Rendah. Dipakai sebagai `@screen-*` di tahap scenario-generator. |
| **ASM-005** | Batas panjang & range | Spec **tidak menyebut satu pun** panjang min/maks maupun range nilai. | Ditetapkan aturan wajar: `Jumlah Armada` ≥ 1 (integer); `Jumlah` barang > 0 (integer); `Nilai Barang` & `Harga` ≥ 0 (currency); `PPN`/`PPh`/`Asuransi` 0–100%; `No. WhatsApp PIC` 10–15 digit numerik diawali `0`; `Kode Pos` 5 digit; `Waktu Perjalanan` ≥ 1 jam. | **Sedang.** Seluruh nilai boundary pada kategori test `edge` bersandar pada asumsi ini. |
| **ASM-006** | Minimal baris alamat | Spec L10 hanya menyebut "rule cascading & **minimal baris per tipe pengiriman**" tanpa menyebut angkanya. | Ditetapkan: `Normal` = 1+1; `Multipickup` ≥ 2 pengirim; `Multidrop` ≥ 2 penerima; `Multipoint` ≥ 2 pengirim **dan** ≥ 2 penerima. Baris tidak dapat dihapus bila akan menyisakan < minimum. | **Sedang.** Menjadi dasar skenario negatif REQ-013. |
| **ASM-007** | Struktur Step 2 pada tipe multi | Spec L25 menyebut `Nomor DO` **"per armada"**, sedangkan L38 menyebut pembagian barang **antar alamat dalam 1 armada** — implikasinya Step 2 memiliki sub-struktur alamat di dalam armada. | Ditetapkan struktur: `Armada n` → sub-section per **alamat** (`Pick Up`/`Drop Off`) atau per **kombinasi** `Pick Up × Drop Off` (Multipoint), masing-masing memiliki `Nomor DO` & tabel barang sendiri. Checkbox `Tambahkan Asuransi` tetap di **level armada** (eksplisit pada L24). | **Sedang–Tinggi.** Menentukan struktur seluruh skenario tipe multi; wajib dikonfirmasi design-analyzer. |
| **ASM-008** | Kardinalitas Multipoint | Spec tidak merinci jumlah sub-section untuk Multipoint. | Ditetapkan **produk kartesian**: jumlah sub-section per armada = `jumlah Pick Up × jumlah Drop Off` (konsisten dengan modul kerabat OMS-014). | **Sedang.** Menjadi dasar skenario `stress`. |
| **ASM-009** | Basis agregasi alert kapasitas | Spec tidak menjelaskan apakah `Total Kubikasi`/`Total Berat` dan alert dihitung per armada atau per alamat. | Ditetapkan **agregat per Armada** (spec L27 menyebut "kapasitas armada"), meskipun tampilannya bisa berulang di setiap sub-section alamat. | **Sedang.** Bila ternyata per alamat, seluruh ekspektasi numerik alert perlu direvisi. |
| **ASM-010** | Waktu eksekusi Auto Stuffing | Spec L37 menyatakan "distribusi barang antar armada **mengikuti** Logic Auto Stuffing", sementara L48 menyatakan `Terapkan ke Order` "menerapkan … **penempatan barang** ke order". Tidak jelas apakah distribusi berjalan otomatis saat input, atau hanya setelah aksi eksplisit. | Ditetapkan **eksplisit-triggered**: distribusi diterapkan ke order hanya melalui alur `Hitung Ulang Armada` → `Terapkan ke Order`. Input barang biasa **tidak** memicu redistribusi otomatis, dan restore draft tidak menghitung ulang. | **Tinggi.** Ini adalah asumsi paling berdampak pada desain skenario Auto Stuffing (EX-11, EX-12, EX-25). Wajib dikonfirmasi. |
| **ASM-011** | Rekomendasi < 3 | Spec L45 menyebut "rekomendasi **3 teratas**" tanpa menjelaskan kondisi bila master armada yang relevan < 3. | Ditetapkan: drawer menampilkan sebanyak yang tersedia (≤ 3), dan **tetap** menandai satu kartu sebagai `Paling Efisien`. | Rendah–Sedang. Menjadi skenario `edge` (EX-14). |
| **ASM-012** | Basis nilai Asuransi | Spec L61 menyebut `Asuransi = persentase × Total Nilai Barang`, namun tidak menjelaskan apakah `Nilai Barang` per baris adalah **nilai satuan** atau **nilai total baris**, dan apakah sumber persentase adalah master atau input user. | Ditetapkan: `Nilai Barang` = **nilai total untuk baris tersebut**; `Total Nilai Barang` = Σ `Nilai Barang` seluruh baris pada armada yang **diasuransikan** saja. Persentase asuransi diinput/ditampilkan di Step 3 sebagai bagian komponen harga. | **Tinggi.** Salah tafsir menghasilkan ekspektasi `Total Harga` yang keliru pada seluruh skenario asuransi. |
| **ASM-013** | Role & hak akses | Spec hanya menyebut "Shipper" (L84–85), "admin shipper" (L80, L95), dan "vendor" (L77, L95) secara sepintas; tidak ada matriks hak akses. | Diinferensikan 5 aktor: **Staff Operasional (Shipper)**, **Admin Shipper**, **System Admin**, **Vendor**, **Pengirim/Penerima (publik)**. Aturan yang **eksplisit di spec** hanya: pembatalan = admin shipper & bukan vendor (REQ-067); edit = shipper dalam rentang status tertentu (REQ-061/062). Sisanya inferensi. | **Sedang–Tinggi.** Skenario autorisasi negatif bersandar pada asumsi ini. Pemisahan Staff Operasional vs Admin Shipper untuk hak `Batalkan Order` khususnya perlu konfirmasi. |
| **ASM-014** | Entitlement add-on | Spec L5 menyebut add-on "hanya aktif jika modul OMS dibeli beserta add-on" tanpa menjelaskan mekanisme/lokasi konfigurasi. | Ditetapkan sebagai **flag entitlement tingkat tenant** yang dikelola **System Admin**, berlaku **global** (bukan per-order/per-user). Untuk pengujian, kondisi "add-on aktif" adalah prasyarat lingkungan. | **Sedang.** Bila mekanismenya berupa toggle per-order, skenario prasyarat perlu direvisi. |
| **ASM-015** | Label button `Draf` | Spec menulis fungsi button sebagai `Draf` (L10, L39) dan aksi sebagai `Simpan ke Draf` (L81). | Label kanonik ditetapkan **`Simpan ke Draf`**; selector sebaiknya memakai matcher toleran (`/Draf/`). | Rendah. |
| **ASM-016** | Aksi untuk status lanjut | Spec L99–L102 hanya merinci aksi untuk 3 kelompok status (draft, `Menunggu Penugasan`, `Ditugaskan`). Aksi untuk `Proses Pengiriman`, `Selesai`, dan `Dibatalkan` tidak disebut. | Diinferensikan (ditandai **INF** pada matriks REQ-069): `Proses Pengiriman` & `Selesai` → `Detail`, `Riwayat Perubahan`, `Lihat No. Perjalanan` (tanpa `Edit` & tanpa `Batalkan Order`); `Dibatalkan` → `Detail`, `Riwayat Perubahan`. | **Sedang.** Menjadi dasar skenario negatif REQ-069/070; wajib dikonfirmasi. |
| **ASM-017** | Status `Selesai` vs `Terkirim` | Spec L79 memakai istilah **`Selesai`**. Modul kerabat OMS-014 mencatat istilah `Terkirim` dari aset desain. | Istilah **spec diprioritaskan**: `Selesai`. Perbedaan dicatat agar scenario-generator memakai matcher toleran bila UI menampilkan `Terkirim`. | **Sedang.** Berpotensi false-negative pada assertion teks status. |
| **ASM-018** | `Tanggal Permintaan Muat` | Spec tidak menyebut aturan tanggal. | Diasumsikan **tidak boleh di masa lalu** relatif terhadap waktu pembuatan order. | Rendah–Sedang. Dasar skenario `negative`/`edge`. |
| **ASM-019** | Satuan `Waktu Perjalanan` | Spec menyebut "Waktu Perjalanan (2 kondisi)" tanpa satuan maupun batas. | Diasumsikan satuan **jam**, numerik ≥ 1, dan nilai yang diinput pada kondisi "rute belum ada di master" akan tersimpan sebagai data master baru (konsisten dengan modul kerabat). | Rendah–Sedang. |
| **ASM-020** | Interaksi visualisasi 3D | Spec hanya menyebut "Visualisasi Muatan (3D)" tanpa merinci interaksi (rotate/zoom/reset) maupun konten legenda. | Interaksi 3D **tidak** dijadikan requirement/AC wajib pada tahap ini; hanya keberadaan panel/pop up dan **pembaruannya** saat `Jenis`/`Jumlah Armada` diubah yang diuji (REQ-043, REQ-057). | **Sedang.** Verifikasi kanvas 3D sulit diotomasi; skenario sebaiknya fokus pada container/pop up, bukan isi kanvas. |
| **ASM-021** | Definisi "1 data barang yang sudah diisi" | Spec L36 menyebut syarat "minimal terdapat 1 data barang yang sudah diisi" tanpa mendefinisikan "diisi". | Ditetapkan: terdapat **minimal satu baris barang dengan `Jumlah` terisi > 0**. Baris yang dipilih dari master namun `Jumlah`-nya masih kosong **tidak** memenuhi syarat. | **Sedang.** Menentukan boundary skenario EX-06. |
| **ASM-022** | Kapasitas maksimal armada | Spec menyebut "kapasitas maksimal" tanpa menjelaskan sumbernya. | Ditetapkan berasal dari **Master Armada** (per `Jenis Armada`), mencakup kapasitas **Berat** dan **Kubikasi**. Mengubah `Jenis Armada` mengubah basis alert kapasitas. | Rendah–Sedang. |
| **ASM-023** | Batch Order | Spec L3 menyebut "input manual maupun batch order" tanpa merinci mekanisme, format file, atau validasinya. | REQ-003 ditulis pada level keberadaan kapabilitas saja; detail batch order dianggap **di luar cakupan detail** modul ini dan mengikuti spec TMS. | **Sedang.** Bila batch order termasuk cakupan uji, dibutuhkan spec tambahan (format template, aturan validasi baris, penanganan error parsial). |
| **ASM-024** | Aset desain | Tersedia 47 PNG (`016`–`057` + varian `a`), namun spec tidak merujuk satu pun file desain. | Aset desain diperlakukan sebagai **grounding label & struktur** untuk tahap ini; **inventarisasi penuh (elemen, selector, teks persis) menjadi tugas design-analyzer**. Requirement (dokumen ini) tetap menjadi acuan bila terjadi konflik dengan desain. | **Sedang.** Bila desain menampilkan label berbeda dari spec, requirement yang menang; selisih dicatat design-analyzer sebagai inkonsistensi. |
| **ASM-025** | Hak edit vs aksi Daftar Order | Spec L84 menyebut shipper dapat **mengubah data** sejak status draft, namun L100 menyebut aksi pada status draft adalah **`Lanjutkan Pengisian`** (bukan `Edit`). | Direkonsiliasi: pada status **draft** perubahan dilakukan melalui **`Lanjutkan Pengisian`** (wizard); aksi **`Edit`** (halaman Edit Order satu-halaman) hanya muncul pada status **`Menunggu Penugasan`**. Keduanya sama-sama merupakan "hak mengubah data". | **Sedang.** Menentukan entry point skenario ALT-08 vs ALT-02. |
| **ASM-026** | Aset desain | Brief menyebut **47** PNG; direktori berisi **46** file (`016`–`057` + `031a`, `043a`, `047a`, `057a`; tidak ada `057b` atau nomor lain). | Inventarisasi dilakukan atas **46 file yang benar-benar ada**; tidak ada layar yang di-skip. Selisih dianggap salah hitung pada brief. | Rendah. Bila ada 1 file yang belum ter-commit, layar terkaitnya belum terinventarisasi. |
| **ASM-027** | Label status | Desain memakai **`Isi Data Dasar`** (bukan `Isi Data Pengiriman`) dan **`Terkirim`** (bukan `Selesai`); 7 status lain sama persis. | Spec tetap sumber kebenaran (REQ-059), namun **selector/assertion status wajib memakai matcher toleran** `/Isi Data (Dasar|Pengiriman)/` dan `/Terkirim|Selesai/`. | **Sedang.** Assertion teks status berpotensi false-negative (memperkuat ASM-017). |
| **ASM-028** | Label step & komponen | Desain: step 3 = `Vendor dan Harga`; checkbox = `Gunakan komponen harga` (huruf kecil); tombol konfirmasi draf = `Simpan Draf`. | Dipakai **teks desain** sebagai nilai selector utama, dengan matcher toleran terhadap varian spec (`Vendor & Harga`, `Gunakan Komponen Harga`, `Simpan ke Draf`). | Rendah. |
| **ASM-029** | Aksi Daftar Order | Desain `034` menampilkan aksi **`Order Kembali`** pada status `Ditugaskan` — tidak disebut spec sama sekali. | Dicatat sebagai aksi **tak terspesifikasi**; **tidak** dijadikan REQ, tetapi matriks aksi REQ-069 **tidak boleh** memakai assertion "menu berisi tepat N item". | **Sedang.** Assertion eksak jumlah item menu akan gagal. |
| **ASM-030** | Panel `Visualisasi Terbaru` | Spec (REQ-047/AC-047.2) menyatakan panel ini **tanpa** pengubah armada & **tanpa** `Terapkan ke Order`. Desain `025` berjudul **`Visualisasi Muatan Saat Ini`**, memang read-only pada bagian armada, **tetapi footer-nya masih memuat `Batal` + `Terapkan ke Order`** dan subjudulnya identik dengan drawer Hitung Ulang. | Spec dimenangkan: skenario tetap memverifikasi **tidak ada kartu rekomendasi & tidak ada field pengubah**. Keberadaan `Terapkan ke Order` ditandai sebagai **kandidat defect desain**, diuji sebagai skenario `negative` terpisah. | **Tinggi.** Titik konflik paling tajam antara desain & spec pada modul ini. |
| **ASM-031** | Alert kapasitas | Desain hanya menampilkan 2 varian pesan (`Kubikasi melebihi…`, `Berat melebihi…`). Varian gabungan `Kubikasi dan Berat melebihi kapasitas armada` **tidak pernah muncul** di 46 PNG. | Varian gabungan tetap diuji berdasarkan spec (AC-029.3) dan ditandai **belum terverifikasi desain**. | **Sedang.** Bila implementasi merender dua chip terpisah, AC-029.3 gagal. |
| **ASM-032** | Teks helper error | Spec hanya menyebut “helper error + border warna error” tanpa teks. | Teks persis diambil dari desain: **`Jumlah harus diisi`** dan **`Nilai Barang harus diisi`**; assertion border error memakai atribut/`class` (bukan warna piksel). | Rendah–Sedang. |
| **ASM-033** | Empty state barang | Spec tidak menyebut empty state Step 2. | Ditetapkan dari desain: `Belum ada barang. Klik "Pilih Barang "` (perhatikan **spasi ganjil** sebelum tanda kutip penutup) → assertion memakai **substring** `Belum ada barang`. | Rendah. |
| **ASM-034** | Perilaku `Sudah Ditambahkan` | Spec (AC-019.3) mengimplikasikan barang yang sudah ada tidak menghasilkan duplikat. Desain `022` menampilkan item berlabel `Sudah Ditambahkan` dalam keadaan **checkbox tercentang dan tetap dapat diinteraksi**, serta **ikut dihitung** counter (`3 barang terpilih` = 1 baru + 2 sudah ditambahkan). | Ditetapkan: label bersifat **informatif**, checkbox merefleksikan barang yang sudah masuk armada; melepas centang = **menghapus** barang dari armada. Duplikasi tetap dicegah. | **Sedang–Tinggi.** Menentukan ekspektasi counter & hasil `Simpan` pada skenario REQ-018/019/020. |
| **ASM-035** | Struktur Step 2 tipe multi | ASM-007/ASM-008 sebelumnya berupa inferensi. | **Terkonfirmasi desain**: `Armada n` → sub-section per alamat; `Multipickup`=`Pick Up m`, `Multidrop`=`Drop Off m`, `Multipoint`= header dua kolom `Pick Up m` \| `Drop Off k` sebanyak **kartesian** (2×2 = 4 sub-section/armada pada `052`). | Rendah (menurunkan risiko ASM-007/008 dari Sedang–Tinggi → Rendah). |
| **ASM-036** | Lokasi `Nomor DO` | Spec L25 menyatakan `Nomor DO` **per armada**. Desain tipe multi (`038`, `045`, `052`) menempatkan `Nomor DO` **pada setiap sub-section alamat**. | Ditetapkan: `Normal` = 1 `Nomor DO` per armada; tipe multi = 1 `Nomor DO` **per sub-section alamat**. Selector di-scope ke sub-section. | **Sedang.** Assertion "satu Nomor DO per armada" akan gagal pada tipe multi. |
| **ASM-037** | Level checkbox asuransi | — | **Terkonfirmasi desain**: `Tambahkan Asuransi` selalu di **header armada**, di atas seluruh sub-section alamat (`038`, `045`, `052`, `033`, `043`, `049`, `057`). | Rendah (mengonfirmasi AC-025.1). |
| **ASM-038** | Struktur Step 3 | Spec menyebut Step 3 sebagai satu kesatuan. | Desain membedakan: tipe `Normal` = **satu card** `Vendor dan Harga` (`026`–`028`); tipe multi = **dua card** `Vendor` + `Harga Pengiriman` (`039`, `046`, `053`). Ringkasan alamat multi = teks tipe + link `Lihat Detail` → pop up `Detail Multipickup`/`Detail Multidrop`. | Rendah–Sedang. Mempengaruhi scoping selector Step 3. |
| **ASM-039** | Konfirmasi Edit Order | REQ-065 mensyaratkan **pop up konfirmasi** untuk `Batal` dan `Simpan` pada Edit Order. Desain `033`/`043`/`049`/`057` hanya menampilkan tombol, tanpa pop up; satu-satunya pop up konfirmasi yang ada adalah `Simpan Draf` (`030`). | REQ-065 tetap diuji dari spec; teks pop up-nya **belum diketahui** → assertion memakai `role=dialog` + tombol, bukan teks persis. | **Sedang.** Risiko selector rapuh pada skenario ALT-08. |
| **ASM-040** | Modal `Batalkan Order` | Spec tidak merinci struktur modal. | Ditetapkan dari desain `032`: memuat `ID Order`, `Vendor`, textarea `Alasan Pembatalan *` (placeholder `Tuliskan alasan pembatalan order`), satu tombol `Batalkan Order`, **tanpa** tombol sekunder `Batal` (penutupan via `✕`). State error validasi **tidak ada** di desain. | **Sedang.** Skenario EX-19 harus mengasumsikan pesan error yang belum diketahui teksnya. |
| **ASM-041** | Konsistensi data mock | Beberapa desain tidak konsisten secara aritmetika: `020`/`021` menampilkan **Armada 3** padahal `Data Unit → Jumlah Armada = 2`; `033` menampilkan `Jumlah Armada = 1` dengan **2** blok Data Barang; `039`/`046`/`053` menampilkan **3 baris** ringkasan dengan label `Armada 1`, `Armada 2`, `Armada 2`; `043` memakai judul `Data Barang - Kontainer 1/2` pada order FTL. | Seluruh anomali diperlakukan sebagai **cacat data mock**, **bukan** perilaku sistem. Ekspektasi jumlah blok armada tetap mengikuti AC-045.3 (`= Jumlah Armada`) dan istilah tetap `Armada` untuk FTL. | **Sedang.** Bila skenario menyalin angka dari mockup, ekspektasi akan salah. |
| **ASM-042** | Menu aktif sidebar | Pada `036`–`057a`, item sidebar yang ter-highlight adalah **`Simulasi Muatan`** meski breadcrumb & konten adalah `Daftar Order`/`Buat Order`/`Edit Order`/`Detail Order`. | Diasumsikan **galat mockup**; menu aktif yang benar untuk seluruh layar modul ini adalah **`Order`**. Assertion menu aktif **tidak** dijadikan kriteria. | Rendah. |
| **ASM-043** | Layar tanpa desain | Tidak ada PNG untuk: `Riwayat Pembatalan`, `Riwayat Perubahan`, `Batch Order`, modal `Pilih Jenis Armada`, hasil pencarian kosong pada modal `Pilih Barang`, seluruh **loading state**, seluruh **toast/notifikasi sukses** (termasuk `Tersalin` setelah copy No. Perjalanan), blok **No. Perjalanan pada Detail Order**, serta state error inline Step 1 & Step 3. | Elemen-elemen tersebut diinventarisasi **hanya dari spec**; selector-nya ditandai **tentatif** dan wajib memakai `role`/`testid` generik, bukan teks persis. | **Sedang–Tinggi.** Sumber utama selector rapuh pada tahap test-generator. |
| **ASM-044** | Verifikasi kanvas 3D | Visualisasi muatan dirender sebagai kanvas gelap (tidak dapat di-query DOM secara bermakna). | Assertion diarahkan ke **container + teks pendamping**: `1306 koli • … dialokasikan ke unit ini`, `Berat Terpakai`/`Ruang Terpakai` beserta persentase, tab `Armada n`, legenda SKU, dan badge `… koli melebihi kapasitas (outline merah)`. Interaksi drag/zoom/reset **tidak** diotomasi (memperkuat ASM-020). | **Sedang.** |
| **ASM-045** | State disabled | Satu-satunya state **disabled** yang terlihat di desain adalah tombol `Selanjutnya` pada Step 1 sebelum form lengkap (`018`). Desain **tidak** menampilkan `Hitung Ulang Armada` dalam keadaan disabled (REQ-036/AC-036.1), dan filter `Tipe Pengiriman`/`Metode Pengiriman` tampil ber-placeholder abu (indikasi disabled, tidak pasti). | REQ-036 tetap diuji dari spec dengan assertion `toBeDisabled()`/`not.toBeVisible()` yang toleran; status disabled filter dicatat sebagai **belum terkonfirmasi**. | **Sedang.** EX-06 bersandar pada perilaku yang belum tervisualisasi. |
