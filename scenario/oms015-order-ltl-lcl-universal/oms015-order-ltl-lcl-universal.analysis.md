# Analysis — oms015-order-ltl-lcl-universal

> **Tahap pipeline:** 1/4 — spec-analyzer
> **Sumber spesifikasi:** `inputs/oms015-order-ltl-lcl-universal/spec.txt` (89 baris, 8 blok rule)
> **Aset desain:** `inputs/oms015-order-ltl-lcl-universal/designs/*.png` (10 file) — dipakai hanya sebagai *grounding* nama field/label/pesan; inventarisasi penuh menjadi tugas design-analyzer.
> **Aplikasi:** tenant `Mentari Sumber Kertas` — `Order Management System Versi 1.0.0`; konteks `Shipper`, badge peran `Staff Operasional`.

## Ringkasan Modul

Modul **OMS-015** mencakup proses **pembuatan, pengeditan, dan pembatalan order** untuk **Jenis Order LTL (Less Than Truck Load)** dan **LCL (Less Than Container Load)** pada Order Management System (OMS).

Modul ini bersifat **turunan** dari spesifikasi Order LTL & LCL di TMS. Seluruh rule TMS berlaku identik, **kecuali satu pembeda inti**:

- **Step 2 (Data Barang)** — barang **tidak diinput manual sebagai deskripsi bebas**, melainkan **dipilih dari Master Barang** melalui modal `Pilih Barang`. Field identitas barang (Kode SKU, Nama Barang, Kemasan, Kubikasi, Dimensi, Berat) ter-*draft* otomatis dan **read-only**; user hanya mengisi `Jumlah` dan (kondisional) `Nilai Barang`.
- **Step 4 (Review)** — penyesuaian *turunan*: struktur tampilan Data Barang mengikuti Step 2 versi OMS.

**Karakter pembeda LTL/LCL terhadap FTL/FCL** (menentukan bentuk test suite):

| Aspek | FTL / FCL | **LTL / LCL (modul ini)** |
|---|---|---|
| Unit muatan | N armada / N kontainer, barang dikelompokkan per unit | **Selalu 1 unit** — seluruh barang dalam **satu grup**, tanpa pengelompokan |
| Tipe Pengiriman | Normal / Multipickup / Multidrop / Multipoint | **Selalu `Normal`** — Data Pengirim & Data Penerima masing-masing 1 baris, tidak dapat ditambah |
| Alert kapasitas Step 2 | Ada (informatif) | **Tidak ada** pengecekan/alert berat maupun kubikasi |
| Nomor DO | Per unit (dan per kombinasi alamat) | **Satu field** untuk keseluruhan order |
| Asuransi | Level unit (per armada/kontainer) | **Level barang** — per baris SKU, dengan opsi `Asuransikan Semua` |
| Identitas perjalanan | `No. Perjalanan`, tampil saat `Ditugaskan` | **`No. Resi`**, melekat **pada barang**, tampil sejak `Menunggu Penugasan` |
| Rute Step 1 | FTL: Jenis+Jumlah Armada; FCL: Pelabuhan + Jenis/Jumlah Kontainer + Metode Pengiriman | LTL: **Kota Asal/Tujuan**; LCL: **Pelabuhan Asal/Tujuan**; jumlah unit **terkunci = 1** |
| Waktu Perjalanan Step 3 | Input wajib | LTL: textfield/text-only tergantung Master; **LCL: tidak ada input** (ETA − ETD + 4 hari) |

**Prioritas pengujian:** (1) integritas Step 2 berbasis Master Barang + asuransi per-barang, (2) ketiadaan elemen multi-unit/multi-alamat/alert kapasitas (*assertion negatif*), (3) siklus status 9-tahap beserta matriks hak Edit/Batal/Aksi, (4) fitur `No. Resi` yang eksklusif LTL/LCL.

---

## Requirements

### Legenda

| Kolom | Keterangan |
|---|---|
| **ID** | Identifier requirement, dipakai sebagai tag `@REQ-xxx` di tahap scenario-generator |
| **Sumber** | Baris pada `spec.txt` yang menjadi dasar. `INF` = inferensi (lihat Assumptions Log) |
| **Prioritas** | `high` = inti pembeda modul / blocking; `medium` = rule turunan TMS yang harus regresi; `low` = pelengkap |

---

### R1. Ketentuan Umum & Cakupan

| ID | Requirement | Sumber | Prioritas |
|---|---|---|---|
| **REQ-001** | Sistem mendukung pembuatan order untuk **Jenis Order LTL (Less Than Truck Load)** dan **LCL (Less Than Container Load)** pada OMS, mengacu penuh pada spesifikasi Order LTL & LCL di TMS. | L3 | high |
| **REQ-002** | Pengisian order menggunakan **wizard 4 step**: `01 Data Pengiriman` → `02 Data Barang` → `03 Vendor dan Harga` → `04 Review`. | L3 | high |
| **REQ-003** | Order dapat dibuat melalui **input manual** (`Buat Order`) maupun **batch order** (`Batch Order`). | L3 | medium |
| **REQ-004** | **Perbedaan utama terhadap TMS hanya pada Step 2** — data barang diambil dari **Master Barang**, bukan input deskripsi manual. Seluruh step lain identik dengan TMS. | L4 | high |
| **REQ-005** | **Penyesuaian turunan pada Step 4 (Review)** — informasi Data Barang yang ditampilkan mengikuti struktur Step 2 versi OMS. | L5 | high |

**Acceptance Criteria**

- **REQ-001**
  - AC-001.1: Pada Step 1, kartu jenis order `LTL Less Than Truck Load` dan `LCL Less Than Container Load` tersedia dan dapat dipilih.
  - AC-001.2: Memilih `LTL` menampilkan form rute versi LTL; memilih `LCL` menampilkan form rute versi LCL (REQ-007, REQ-008).
  - AC-001.3: Order LTL dan LCL dapat diselesaikan sampai Step 4 dan disimpan.
  - AC-001.4: Badge jenis order `LTL` / `LCL` tampil pada baris `Daftar Order`, `Detail Order`, dan pop up `Data No. Resi`.
- **REQ-002**
  - AC-002.1: Stepper menampilkan 4 langkah bernomor `01`–`04` dengan label `Data Pengiriman`, `Data Barang`, `Vendor dan Harga`, `Review`.
  - AC-002.2: Step selesai berubah menjadi indikator *checked*; step aktif ter-highlight; step belum tersentuh berwarna netral.
  - AC-002.3: Navigasi `Selanjutnya` / `Sebelumnya` berfungsi dan data setiap step dipertahankan saat berpindah bolak-balik.
  - AC-002.4: Aksi utama pada Step 4 adalah `Simpan` (bukan `Selanjutnya`).
- **REQ-003**
  - AC-003.1: Halaman `Daftar Order` menyediakan tombol `Buat Order` dan `Batch Order`.
  - AC-003.2: Order LTL/LCL hasil batch tampil pada `Daftar Order` dengan badge jenis order yang benar.
  - AC-003.3: Order hasil batch mengikuti seluruh rule modul ini (1 unit muatan, tipe Normal, No. Resi).
- **REQ-004**
  - AC-004.1: Step 2 **tidak** menyediakan field input teks bebas untuk nama/deskripsi/dimensi/berat barang.
  - AC-004.2: Satu-satunya jalur penambahan barang adalah tombol `Pilih Barang` → modal Master Barang (REQ-013).
  - AC-004.3: Struktur, label, dan urutan section pada Step 1, Step 3, dan Step 4 identik dengan versi TMS.
- **REQ-005**
  - AC-005.1: Section `Data Barang` pada Step 4 menampilkan kolom sesuai Step 2 OMS: `Kode SKU`/`Nama Barang`, `Kemasan`, `Kubikasi`/`Dimensi`, `Berat`, `Jumlah`, `Nilai Barang`.
  - AC-005.2: Tidak ada kolom deskripsi barang bebas pada Step 4.

---

### R2. Step 1 — Data Pengiriman

| ID | Requirement | Sumber | Prioritas |
|---|---|---|---|
| **REQ-006** | Step 1 **identik dengan Step 1 Order LTL & LCL di TMS** (struktur section `Jenis Pengiriman dan Rute`, `Data Pengirim`, `Data Penerima`). | L8 | high |
| **REQ-007** | **LCL** — menampilkan field `Pelabuhan Asal` dan `Pelabuhan Tujuan` yang bersumber dari **Master Pelabuhan**; field **`Jumlah Kontainer` dihilangkan** sebagai input user (tidak dapat diisi/diubah). | L9 | high |
| **REQ-008** | **LTL** — menampilkan field `Kota Asal` dan `Kota Tujuan` yang bersumber dari **Master Kota**. | L10 | high |
| **REQ-009** | **Kota dilepas** — pilihan Kota Asal/Kota Tujuan **tidak mengikat/memfilter** pilihan `Drop Point` maupun `Pelabuhan Asal & Tujuan`. | L10 | high |
| **REQ-010** | **Tipe pengiriman selalu `Normal`** — `Data Pengirim` dan `Data Penerima` masing-masing **tepat 1 baris** dan **tidak dapat ditambah** (tidak ada `Tambah Baris Input`). | L11 | high |
| **REQ-011** | **Auto-draft dari Master Droppoint** — memilih `Drop Point Asal`/`Drop Point Tujuan` mengisi otomatis field wilayah & alamat terkait secara read-only. | L11 | high |
| **REQ-012** | **Validasi field wajib Step 1** berlaku, dan tersedia fungsi button `Batal` / `Simpan ke Draf` / `Selanjutnya`. | L11 | high |

**Acceptance Criteria**

- **REQ-006**
  - AC-006.1: Step 1 menampilkan tiga section berurutan: `Jenis Pengiriman dan Rute`, `Data Pengirim`, `Data Penerima`.
  - AC-006.2: Label dan urutan field pada `Data Pengirim`/`Data Penerima` sama dengan versi TMS/FTL-FCL.
- **REQ-007**
  - AC-007.1: Dengan `LCL` terpilih, field `Pelabuhan Asal`\* dan `Pelabuhan Tujuan`\* tampil sebagai dropdown.
  - AC-007.2: Opsi kedua dropdown hanya berasal dari Master Pelabuhan (contoh `Tanjung Perak (SUB)`, `Panjang (PNJ)`).
  - AC-007.3: `Jumlah Kontainer` **tidak dapat diinput user** — tidak dirender sebagai input aktif, atau dirender read-only bernilai `1` (lihat ASM-004).
  - AC-007.4: Dengan `LCL` terpilih, field `Kota Asal`/`Kota Tujuan` **tidak** dirender.
  - AC-007.5: Order LCL dapat disimpan tanpa user pernah menyentuh field jumlah kontainer.
- **REQ-008**
  - AC-008.1: Dengan `LTL` terpilih, field `Kota Asal`\* dan `Kota Tujuan`\* tampil sebagai dropdown dengan placeholder `Pilih Kota Asal` / `Pilih Kota Tujuan`.
  - AC-008.2: Opsi kedua dropdown hanya berasal dari Master Kota.
  - AC-008.3: Dengan `LTL` terpilih, field `Pelabuhan Asal`/`Pelabuhan Tujuan` **tidak** dirender.
  - AC-008.4: `Jumlah Armada` tidak dapat diinput user (read-only bernilai `1`) — lihat ASM-004.
- **REQ-009**
  - AC-009.1: Mengubah `Kota Asal` **tidak** mengosongkan/mem-filter isi dropdown `Drop Point Asal`; seluruh drop point tetap dapat dipilih.
  - AC-009.2: Mengubah `Kota Tujuan` **tidak** mengosongkan/mem-filter isi dropdown `Drop Point Tujuan`.
  - AC-009.3: Kombinasi `Kota Asal` dan `Drop Point Asal` yang berbeda kota **tetap dapat disimpan** tanpa pesan error.
  - AC-009.4: Pada LCL, pilihan `Pelabuhan Asal`/`Pelabuhan Tujuan` tidak dibatasi oleh kota drop point manapun.
- **REQ-010**
  - AC-010.1: Section `Data Pengirim` menampilkan tepat satu blok alamat; section `Data Penerima` menampilkan tepat satu blok alamat.
  - AC-010.2: Tombol `Tambah Baris Input` **tidak** dirender pada kedua section.
  - AC-010.3: Ikon hapus alamat **tidak** dirender (tidak ada alamat yang dapat dihapus).
  - AC-010.4: Dropdown `Tipe Pengiriman` tidak dapat diubah dari `Normal` (tidak dirender, atau dirender terkunci) — lihat ASM-005.
  - AC-010.5: `Detail Order` / Step 4 menampilkan `Tipe Pengiriman : Normal`.
- **REQ-011**
  - AC-011.1: Memilih `Drop Point Asal` mengisi otomatis `Provinsi Asal`, `Kota/Kab. Asal`, `Kecamatan Asal`, `Desa/Kelurahan Asal`, `Kode Pos`, `Alamat Asal`.
  - AC-011.2: Memilih `Drop Point Tujuan` mengisi otomatis field wilayah & `Alamat Tujuan` yang setara.
  - AC-011.3: Seluruh field hasil auto-draft bersifat **read-only** dan tidak dapat diedit manual.
  - AC-011.4: Mengganti drop point memperbarui seluruh field turunannya.
- **REQ-012**
  - AC-012.1: Field wajib ditandai asterisk merah (`*`): `Kota Asal`/`Pelabuhan Asal`, `Kota Tujuan`/`Pelabuhan Tujuan`, `Drop Point Asal`, `Pengirim`, `PIC Pengirim`, `No. WhatsApp PIC`, `Drop Point Tujuan`, `Penerima`, `PIC Penerima`, `No. WhatsApp PIC`.
  - AC-012.2: Klik `Selanjutnya` dengan field wajib kosong **menahan navigasi** dan menampilkan pesan validasi inline pada field terkait.
  - AC-012.3: `Batal` menampilkan konfirmasi lalu keluar dari wizard tanpa menyimpan.
  - AC-012.4: `Simpan ke Draf` menyimpan order sebagai draft berstatus `Isi Data Pengiriman` (lihat REQ-039, ASM-013).
  - AC-012.5: `Selanjutnya` membawa user ke Step 2 setelah seluruh field wajib valid.

---

### R3. Step 2 — Data Barang *(pembeda inti modul)*

| ID | Requirement | Sumber | Prioritas |
|---|---|---|---|
| **REQ-013** | **Barang tidak diinput manual** — barang **dipilih dari Master Barang** melalui modal **`Pilih Barang`**. | L14 | high |
| **REQ-014** | Modal `Pilih Barang` menyediakan **pencarian berdasarkan kode barang maupun nama barang**. | L16 | high |
| **REQ-015** | Modal `Pilih Barang` mendukung **pemilihan multi-select** melalui checkbox. | L17 | high |
| **REQ-016** | Modal `Pilih Barang` menampilkan label **`Sudah Ditambahkan`** pada barang yang sudah masuk ke order/kontainer terkait. | L18 | high |
| **REQ-017** | Modal `Pilih Barang` menampilkan **counter jumlah barang terpilih**. | L19 | medium |
| **REQ-018** | Modal `Pilih Barang` menyediakan button **`Batal`** dan **`Simpan`**. | L20 | high |
| **REQ-019** | Field berikut **ter-draft otomatis dari Master Barang dan bersifat read-only**: `Kode SKU`, `Nama Barang`, `Kemasan`, `Kubikasi`, `Dimensi`, `Berat`. | L21 | high |
| **REQ-020** | Field **`Jumlah`** diinput user per baris barang dan **wajib diisi**. | L23 | high |
| **REQ-021** | Field **`Nilai Barang`** **hanya muncul** dan **menjadi wajib** saat asuransi diaktifkan untuk barang tersebut. | L24 | high |
| **REQ-022** | Checkbox asuransi tersedia pada **level barang** (per baris SKU) dan disertai kontrol **`Asuransikan Semua`** yang berlaku untuk seluruh barang pada order tersebut. | L25, L33 | high |
| **REQ-023** | **`Nomor DO`** — **hanya satu field** untuk keseluruhan order, **tidak wajib**, dapat diisi lebih dari satu nomor **dipisahkan koma**, dan **tampil sebagai chip**. | L26, L33 | high |
| **REQ-024** | **LTL & LCL hanya memiliki 1 unit muatan** — tidak ada pengelompokan per armada/kontainer, `Jumlah Kontainer` LCL selalu `1`, dan **seluruh barang berada pada satu grup**. | L27 | high |
| **REQ-025** | **Tidak ada pengecekan maupun alert kelebihan berat/kubikasi** pada Step 2. | L28 | high |
| **REQ-026** | Setiap baris barang dapat **dihapus** melalui **icon hapus** pada baris tersebut. | L29 | high |
| **REQ-027** | Field wajib yang kosong (`Jumlah`, atau `Nilai Barang` saat asuransi aktif) menampilkan **helper error** dan **border field berubah warna error**. | L30 | high |
| **REQ-028** | Fungsi button Step 2 (`Batal` / `Simpan ke Draf` / `Sebelumnya` / `Selanjutnya`) berlaku **identik dengan Step 2 TMS**. | L31 | medium |

**Acceptance Criteria**

- **REQ-013**
  - AC-013.1: Section `Data Barang` menyediakan tombol `Pilih Barang` yang membuka modal berjudul `Pilih Barang`.
  - AC-013.2: Tidak terdapat tombol/aksi lain untuk menambah barang (tidak ada `Tambah Baris`, tidak ada input SKU bebas).
  - AC-013.3: Hanya SKU yang terdaftar pada Master Barang yang dapat masuk ke tabel barang.
  - AC-013.4: Barang yang dipilih muncul di tabel dengan seluruh atribut master ter-draft (REQ-019).
- **REQ-014**
  - AC-014.1: Modal menyediakan satu input pencarian yang menerima **kode barang** maupun **nama barang**.
  - AC-014.2: Mengetik `SKU-PPR` memfilter daftar ke SKU yang kodenya cocok.
  - AC-014.3: Mengetik `Kertas` memfilter daftar ke barang yang namanya cocok.
  - AC-014.4: Pencarian tanpa hasil menampilkan empty state, bukan error.
  - AC-014.5: Mengosongkan pencarian mengembalikan daftar penuh.
- **REQ-015**
  - AC-015.1: Setiap baris barang pada modal memiliki checkbox.
  - AC-015.2: Lebih dari satu barang dapat tercentang bersamaan dalam satu sesi modal.
  - AC-015.3: Klik `Simpan` menambahkan **seluruh** barang tercentang sekaligus ke tabel Step 2.
  - AC-015.4: Mencentang lalu membatalkan centang mengembalikan barang ke kondisi tidak terpilih.
- **REQ-016**
  - AC-016.1: Barang yang sudah ada di tabel Step 2 ditampilkan dengan label `Sudah Ditambahkan` saat modal dibuka kembali.
  - AC-016.2: Barang berlabel `Sudah Ditambahkan` tidak menghasilkan baris duplikat bila `Simpan` ditekan.
  - AC-016.3: Menghapus barang dari tabel Step 2 menghilangkan label `Sudah Ditambahkan` pada modal.
- **REQ-017**
  - AC-017.1: Counter menampilkan jumlah barang terpilih saat ini (contoh `3 barang terpilih`).
  - AC-017.2: Counter bertambah/berkurang secara langsung saat checkbox diubah.
  - AC-017.3: Tanpa pilihan, counter menampilkan `0` (atau tidak dirender) — lihat ASM-010.
- **REQ-018**
  - AC-018.1: `Batal` menutup modal **tanpa** menambahkan barang apa pun ke tabel.
  - AC-018.2: `Simpan` menutup modal dan menambahkan seluruh barang terpilih ke tabel.
  - AC-018.3: Menutup modal via ikon `X` berperilaku sama dengan `Batal`.
- **REQ-019**
  - AC-019.1: Tabel barang menampilkan `Kode SKU`, `Nama Barang`, `Kemasan`, `Kubikasi`, `Dimensi`, `Berat` sesuai data Master Barang.
  - AC-019.2: Keenam field tersebut **tidak dapat diedit** (bukan input, tidak fokusabel).
  - AC-019.3: Nilai yang tampil identik dengan data master (contoh `SKU-PPR-001` / `Kertas HVS A4 80 gsm` / `Dus` / `0,018 m³` / `31 × 22 × 26,4 cm` / `12,5 kg`).
  - AC-019.4: Perubahan data pada Master Barang tidak boleh mengubah baris order yang sudah tersimpan (lihat ASM-011).
- **REQ-020**
  - AC-020.1: Kolom `Jumlah` merupakan input angka yang dapat diisi user pada setiap baris barang.
  - AC-020.2: `Jumlah` kosong/`0` saat `Selanjutnya` ditekan → navigasi ditahan dan pesan error muncul pada baris terkait.
  - AC-020.3: `Jumlah` bersifat wajib untuk **setiap** baris barang, termasuk baris yang tidak diasuransikan.
  - AC-020.4: Nilai `Jumlah` tersimpan persis seperti diinput dan ter-carry ke Step 3, Step 4, dan Detail Order.
- **REQ-021**
  - AC-021.1: Saat asuransi baris **tidak** aktif, sel `Nilai Barang` **tidak menampilkan input** (menampilkan teks `Tanpa Asuransi`).
  - AC-021.2: Saat asuransi baris diaktifkan, input `Nilai Barang` (prefix `Rp`) muncul pada baris tersebut.
  - AC-021.3: `Nilai Barang` kosong/`0` saat asuransi aktif → pesan `Nilai Barang harus diisi` dan navigasi ditahan.
  - AC-021.4: Menonaktifkan kembali asuransi menghilangkan kewajiban `Nilai Barang` dan navigasi kembali diizinkan.
- **REQ-022**
  - AC-022.1: Kolom `Asuransi` berisi checkbox pada setiap baris barang.
  - AC-022.2: Kontrol `Asuransikan Semua` mencentang seluruh baris barang sekaligus.
  - AC-022.3: Membatalkan `Asuransikan Semua` melepas centang seluruh baris.
  - AC-022.4: Mencentang sebagian baris saja diperbolehkan — baris tercentang menampilkan input `Nilai Barang`, baris lain menampilkan `Tanpa Asuransi`.
  - AC-022.5: Status asuransi per barang ter-carry ke Step 3 (komponen `Asuransi`), Step 4, dan Detail Order.
  - AC-022.6: Bila seluruh baris dicentang manual satu per satu, kontrol `Asuransikan Semua` ikut berubah menjadi tercentang (lihat ASM-002).
- **REQ-023**
  - AC-023.1: Section `Data Barang` menampilkan **tepat satu** field `Nomor DO` untuk keseluruhan order.
  - AC-023.2: Helper text `Pisahkan dengan koma untuk menambahkan beberapa nomor` ditampilkan.
  - AC-023.3: Input yang dipisahkan koma dirender menjadi beberapa chip terpisah, masing-masing dapat dihapus individual.
  - AC-023.4: `Nomor DO` bersifat **opsional** — order tanpa Nomor DO tetap dapat lanjut ke Step 3 dan disimpan.
  - AC-023.5: Order tanpa Nomor DO ditampilkan sebagai `-` pada Step 4 dan Detail Order.
- **REQ-024**
  - AC-024.1: Step 2 **tidak** menampilkan card/blok berulang `Armada n` maupun `Kontainer n`.
  - AC-024.2: Seluruh barang berada dalam **satu tabel tunggal**.
  - AC-024.3: Step 2 **tidak** menampilkan sub-section alamat (`Pick Up n` / `Drop Off n`).
  - AC-024.4: Rekap Step 3 menampilkan **tepat satu baris unit** (lihat ASM-008).
  - AC-024.5: Untuk LCL, jumlah kontainer yang tercatat pada order selalu `1`.
- **REQ-025**
  - AC-025.1: Step 2 **tidak** menampilkan badge/peringatan `Kubikasi melebihi kapasitas armada`.
  - AC-025.2: Step 2 **tidak** menampilkan badge/peringatan `Berat melebihi kapasitas armada`.
  - AC-025.3: Step 2 **tidak** menampilkan ringkasan kapasitas berformat `<terpakai> / <kapasitas>` (m³ maupun kg).
  - AC-025.4: Mengisi `Jumlah` dengan nilai sangat besar tidak memunculkan peringatan apa pun dan tidak menahan `Selanjutnya`.
  - AC-025.5: Tidak ada elemen hitung-ulang/visualisasi muatan pada Step 2 (lihat ASM-007).
- **REQ-026**
  - AC-026.1: Setiap baris barang memiliki ikon hapus (trash).
  - AC-026.2: Klik ikon hapus menghilangkan baris tersebut dari tabel tanpa mempengaruhi baris lain.
  - AC-026.3: Barang yang dihapus kehilangan label `Sudah Ditambahkan` pada modal `Pilih Barang`.
  - AC-026.4: Menghapus seluruh barang mengembalikan tabel ke empty state dan `Selanjutnya` ditahan (lihat ASM-009).
- **REQ-027**
  - AC-027.1: Field wajib kosong menampilkan **helper error** di bawah field (contoh `Nilai Barang harus diisi`).
  - AC-027.2: **Border field** berubah menjadi warna error (merah) pada field yang bermasalah.
  - AC-027.3: Error muncul pada field yang tepat — hanya baris/kolom yang kosong, bukan seluruh tabel.
  - AC-027.4: Setelah field diperbaiki, helper error hilang dan border kembali normal.
- **REQ-028**
  - AC-028.1: Step 2 menampilkan tombol `Batal`, `Sebelumnya`, `Simpan ke Draf`, dan `Selanjutnya`.
  - AC-028.2: `Sebelumnya` kembali ke Step 1 dengan seluruh data Step 1 utuh.
  - AC-028.3: `Simpan ke Draf` menyimpan order berstatus `Isi Data Muatan`.
  - AC-028.4: `Batal` menampilkan konfirmasi dan keluar tanpa menyimpan.
  - AC-028.5: `Selanjutnya` ditahan selama masih ada field wajib Step 2 yang kosong.

---

### R4. Step 3 — Vendor & Harga

| ID | Requirement | Sumber | Prioritas |
|---|---|---|---|
| **REQ-029** | Step 3 **sama dengan Step 3 Order LTL & LCL di TMS** — field `Vendor`, `Tanggal Permintaan Muat`, `Harga`, serta komponen harga opsional via checkbox **`Gunakan komponen harga`**. | L36 | high |
| **REQ-030** | **LTL** — `Waktu Perjalanan` berupa **textfield** (bila rute belum ada di Master Waktu Perjalanan, disertai info bahwa nilainya akan tersimpan sebagai data master baru) atau **text-only** (bila rute sudah ada di master). | L37 | high |
| **REQ-031** | **LCL** — **tidak memiliki input `Waktu Perjalanan`**; nilainya dihitung sistem sebagai **ETA − ETD + 4 hari** dan **baru tampil pada Detail Order saat status `Ditugaskan`**. | L37 | high |
| **REQ-032** | Komponen **`Asuransi`** mengikuti data Step 2 — saat ada barang diasuransikan, nilai Asuransi (**persentase × Total Nilai Barang**) turut dihitung ke **`Total Harga`**, di samping `PPN` dan `PPh`. | L38 | high |
| **REQ-033** | **Validasi field wajib** dan **fungsi button** Step 3 (`Batal` / `Simpan ke Draf` / `Sebelumnya` / `Selanjutnya`) **identik dengan TMS**. | L39 | medium |

**Acceptance Criteria**

- **REQ-029**
  - AC-029.1: Section `Vendor dan Harga` menampilkan `Vendor`\* (dropdown), `Tanggal Permintaan Muat`\* (datetime), dan `Harga`\* (currency `Rp`).
  - AC-029.2: Step 3 menampilkan ringkasan read-only rute (`Drop Point Asal`, `Drop Point Tujuan`) hasil Step 1.
  - AC-029.3: Checkbox `Gunakan komponen harga` **tidak dicentang secara default**; komponen `PPN`/`PPh` tersembunyi.
  - AC-029.4: Mencentang `Gunakan komponen harga` menampilkan input `PPN (%)` dan `PPh (%)` beserta rincian `Harga DPP`, `PPN (n%)`, `PPh (n%)`, `Total Harga`.
  - AC-029.5: `Total Harga` = `Harga DPP + PPN − PPh (+ Asuransi bila ada)`; `PPh` bersifat pengurang dan ditampilkan dengan tanda `-`.
  - AC-029.6: Tanpa `Gunakan komponen harga`, `Total Harga` sama dengan `Harga`.
- **REQ-030**
  - AC-030.1: Pada order **LTL**, field `Waktu Perjalanan`\* tampil dengan satuan `Jam`.
  - AC-030.2: Bila rute **belum ada** di Master Waktu Perjalanan, field dapat diedit dan muncul info `Rute belum ada di Master Waktu Perjalanan. Isi waktu perjalanan, nilainya akan otomatis tersimpan sebagai data master baru.`
  - AC-030.3: Bila rute **sudah ada** di Master Waktu Perjalanan, nilai tampil sebagai **text-only** (tidak dapat diedit) dan info tersebut tidak muncul.
  - AC-030.4: Nilai `Waktu Perjalanan` ter-carry ke Step 4 dan Detail Order (contoh `8 Jam`).
- **REQ-031**
  - AC-031.1: Pada order **LCL**, Step 3 **tidak** merender field/input `Waktu Perjalanan` dalam bentuk apa pun.
  - AC-031.2: Info `Rute belum ada di Master Waktu Perjalanan…` **tidak** muncul pada Step 3 LCL.
  - AC-031.3: Order LCL dapat lanjut ke Step 4 dan disimpan tanpa mengisi waktu perjalanan.
  - AC-031.4: `Waktu Perjalanan` **tidak tampil** pada Detail Order LCL saat status `Menunggu Penugasan`.
  - AC-031.5: Setelah status berubah menjadi `Ditugaskan`, `Waktu Perjalanan` tampil pada Detail Order LCL dengan nilai `ETA − ETD + 4 hari`.
- **REQ-032**
  - AC-032.1: Bila **tidak ada** barang diasuransikan, baris komponen `Asuransi` **tidak** muncul pada ringkasan harga, dan rekap `Total Nilai Barang` menampilkan `Tanpa Asuransi`.
  - AC-032.2: Bila **ada** barang diasuransikan, baris `Asuransi (n%)` muncul pada ringkasan harga.
  - AC-032.3: Nilai Asuransi = `persentase × Total Nilai Barang`, dengan `Total Nilai Barang` = Σ `Nilai Barang` seluruh barang yang diasuransikan pada Step 2.
  - AC-032.4: Dasar perhitungan ditampilkan sebagai catatan `(Total Nilai Barang = Rp<nominal>)`.
  - AC-032.5: `Total Harga` = `Harga DPP + PPN − PPh + Asuransi`.
  - AC-032.6: Mengubah `Nilai Barang` di Step 2 lalu kembali ke Step 3 memperbarui nilai Asuransi dan `Total Harga`.
- **REQ-033**
  - AC-033.1: Klik `Selanjutnya` dengan `Vendor` / `Tanggal Permintaan Muat` / `Harga` kosong menahan navigasi dan menampilkan validasi inline.
  - AC-033.2: Pada LTL, `Waktu Perjalanan` kosong (saat berupa textfield) juga menahan navigasi.
  - AC-033.3: `Simpan ke Draf` menyimpan order berstatus `Isi Data Vendor`.
  - AC-033.4: `Sebelumnya` kembali ke Step 2 dengan seluruh data barang utuh.
  - AC-033.5: `Batal` menampilkan konfirmasi dan keluar tanpa menyimpan.

---

### R5. Step 4 — Review

| ID | Requirement | Sumber | Prioritas |
|---|---|---|---|
| **REQ-034** | Step 4 menampilkan **ringkasan seluruh data Step 1–3 secara read-only**, sama dengan TMS. | L42 | high |
| **REQ-035** | Section **Data Barang pada Review mengikuti struktur Step 2 OMS** — menampilkan `Kode SKU`, `Nama Barang`, `Kemasan`, `Kubikasi`/`Dimensi`, `Berat`, `Jumlah`, dan `Nilai Barang`. | L43 | high |
| **REQ-036** | Review menampilkan **penanda status asuransi** untuk barang yang diasuransikan. | L43 | medium |
| **REQ-037** | Fungsi button Step 4 (`Batal` / `Simpan ke Draf` / `Sebelumnya` / `Simpan`) identik dengan TMS; **`Simpan` mengubah status order menjadi `Menunggu Penugasan`**. | L44 | high |

**Acceptance Criteria**

- **REQ-034**
  - AC-034.1: Step 4 menampilkan section `Jenis Pengiriman dan Rute`, `Data Pengirim`, `Data Penerima`, `Data Barang`, `Vendor dan Harga`.
  - AC-034.2: Seluruh nilai bersifat **read-only** — tidak ada input, dropdown, atau checkbox aktif.
  - AC-034.3: Nilai yang ditampilkan identik dengan input Step 1–3 (tanpa transformasi).
  - AC-034.4: Setiap section dapat di-*collapse*/*expand* melalui ikon chevron.
  - AC-034.5: Field kosong opsional ditampilkan sebagai `-` (mis. `Catatan`, `Nomor DO`).
- **REQ-035**
  - AC-035.1: Tabel `Data Barang` menampilkan header `Kode SKU`/`Nama Barang`, `Kemasan`, `Kubikasi`/`Dimensi`, `Berat`, `Jumlah`, `Nilai Barang`.
  - AC-035.2: Jumlah baris barang identik dengan Step 2; tidak ada baris tambahan maupun penggabungan.
  - AC-035.3: `Nomor DO` ditampilkan di atas tabel (chip, atau `-` bila kosong).
  - AC-035.4: Seluruh barang tampil dalam **satu grup tunggal**, tanpa pengelompokan per armada/kontainer/alamat (konsisten REQ-024).
- **REQ-036**
  - AC-036.1: Barang yang diasuransikan menampilkan nominal `Nilai Barang` pada kolom terkait.
  - AC-036.2: Barang yang tidak diasuransikan menampilkan `Tanpa Asuransi` pada kolom `Nilai Barang`.
  - AC-036.3: Ringkasan harga menampilkan baris `Asuransi (n%)` beserta catatan `(Total Nilai Barang = Rp<nominal>)` bila ada barang diasuransikan.
  - AC-036.4: Penanda asuransi konsisten antara Step 4 dan Detail Order.
- **REQ-037**
  - AC-037.1: Step 4 menampilkan tombol `Batal`, `Sebelumnya`, `Simpan ke Draf`, dan `Simpan`.
  - AC-037.2: `Simpan ke Draf` pada Step 4 menyimpan order berstatus `Review Order`.
  - AC-037.3: `Simpan` menyimpan order dan mengubah status menjadi **`Menunggu Penugasan`**.
  - AC-037.4: Setelah `Simpan`, user diarahkan ke `Daftar Order` dan order tampil dengan status `Menunggu Penugasan`.
  - AC-037.5: Setelah `Simpan`, aksi `Lihat No. Resi` menjadi tersedia untuk order tersebut (REQ-055).
  - AC-037.6: `Sebelumnya` kembali ke Step 3 dengan data utuh; `Batal` menampilkan konfirmasi dan keluar tanpa menyimpan.

---

### R6. Status Order

| ID | Requirement | Sumber | Prioritas |
|---|---|---|---|
| **REQ-038** | Order LTL & LCL memiliki **tepat 9 status** dengan definisi sebagaimana tabel Status di bawah. | L47–L56 | high |
| **REQ-039** | Status 1–4 (`Isi Data Pengiriman` s.d. `Review Order`) merupakan **kondisi draft**, tersimpan otomatis melalui aksi **`Simpan ke Draf` pada step manapun**. | L57 | high |

**Definisi 9 Status**

| # | Status | Definisi | Kelompok |
|---|---|---|---|
| 1 | `Isi Data Pengiriman` | Pengisian order belum selesai di step `Data Pengiriman`. | Draft |
| 2 | `Isi Data Muatan` | Pengisian order belum selesai di step `Data Barang`. | Draft |
| 3 | `Isi Data Vendor` | Pengisian order belum selesai di step `Vendor & Harga`. | Draft |
| 4 | `Review Order` | Seluruh step sudah terisi namun order belum di-submit (masih di step Review). | Draft |
| 5 | `Menunggu Penugasan` | Seluruh data order lengkap & disubmit, menunggu proses penugasan vendor. | Aktif |
| 6 | `Ditugaskan` | Vendor sudah melakukan penugasan. | Aktif |
| 7 | `Proses Pengiriman` | Status penugasan armada `Dalam Perjalanan`. | Aktif |
| 8 | `Selesai` | Seluruh armada sudah selesai bongkar (status penugasan `Selesai`). | Final |
| 9 | `Dibatalkan` | Order dibatalkan oleh admin shipper. | Final |

**Acceptance Criteria**

- **REQ-038**
  - AC-038.1: Kolom `Status` pada `Daftar Order` menampilkan status order sebagai badge berwarna.
  - AC-038.2: Filter `Status` pada `Daftar Order` memuat kesembilan status di atas.
  - AC-038.3: Status yang sama ditampilkan konsisten pada `Daftar Order` dan `Detail Order`.
  - AC-038.4: Status berubah sesuai pemicunya: submit Step 4 → `Menunggu Penugasan`; vendor menugaskan → `Ditugaskan`; armada `Dalam Perjalanan` → `Proses Pengiriman`; armada selesai bongkar → `Selesai`; pembatalan → `Dibatalkan`.
  - AC-038.5: Tidak ada status di luar kesembilan status tersebut untuk order LTL/LCL.
- **REQ-039**
  - AC-039.1: `Simpan ke Draf` tersedia pada Step 1, 2, 3, dan 4.
  - AC-039.2: `Simpan ke Draf` dari Step 1 → status `Isi Data Pengiriman`; Step 2 → `Isi Data Muatan`; Step 3 → `Isi Data Vendor`; Step 4 → `Review Order`.
  - AC-039.3: Order draft muncul pada `Daftar Order` dengan badge status yang sesuai.
  - AC-039.4: Aksi `Lanjutkan Pengisian` membuka wizard pada step yang sesuai dengan seluruh data sebelumnya ter-restore (termasuk barang, chip Nomor DO, dan status asuransi per barang).
  - AC-039.5: Aksi `Simpan ke Draf` menampilkan pop up konfirmasi sebelum menyimpan (lihat ASM-014).

---

### R7. Hak Edit Order

| ID | Requirement | Sumber | Prioritas |
|---|---|---|---|
| **REQ-040** | **Shipper dapat mengubah data order** selama status berada dalam rentang **draft (`Isi Data Pengiriman` s.d. `Review Order`) hingga `Menunggu Penugasan`**. | L60 | high |
| **REQ-041** | **Shipper tidak dapat lagi mengubah data order** setelah status berubah menjadi **`Ditugaskan`** (dan seterusnya). | L61 | high |
| **REQ-042** | Pada halaman `Edit Order`, field **`Jenis Pengiriman`** dan **`Tipe Pengiriman`** bersifat **locked/read-only** dan tidak dapat diubah. | L62 | high |
| **REQ-043** | Field `Jenis Armada`, `Jumlah Armada`, `Data Pengirim`, `Data Penerima`, `Data Barang`, dan `Vendor & Harga` **tetap dapat diubah** selama order berstatus dapat diedit. | L63 | high |
| **REQ-044** | Fungsi button pada `Edit Order`: **`Batal`** (membatalkan pengisian data → **pop up konfirmasi**) dan **`Simpan`** (menyelesaikan pengeditan → **pop up konfirmasi**). | L64–L66 | high |

**Acceptance Criteria**

- **REQ-040**
  - AC-040.1: Order berstatus `Menunggu Penugasan` menampilkan aksi `Edit` pada menu baris `Daftar Order` dan tombol `Edit Order` pada `Detail Order`.
  - AC-040.2: Order berstatus draft menampilkan aksi `Lanjutkan Pengisian` (bukan `Edit`) — lihat REQ-048.
  - AC-040.3: Perubahan yang disimpan pada `Edit Order` tercermin pada `Detail Order` dan `Daftar Order`.
  - AC-040.4: Perubahan tercatat pada `Riwayat Perubahan` order tersebut.
- **REQ-041**
  - AC-041.1: Aksi `Edit` / tombol `Edit Order` **tidak** tersedia pada status `Ditugaskan`, `Proses Pengiriman`, `Selesai`, dan `Dibatalkan`.
  - AC-041.2: Mengakses URL `Edit Order` secara langsung untuk order berstatus tersebut **ditolak** (redirect atau pesan error), bukan hanya disembunyikan di UI.
  - AC-041.3: Percobaan submit perubahan via API untuk order `Ditugaskan` ditolak sistem.
- **REQ-042**
  - AC-042.1: Pada `Edit Order`, `Jenis Pengiriman` (LTL/LCL) ditampilkan read-only dan tidak dapat diubah ke jenis lain.
  - AC-042.2: Pada `Edit Order`, `Tipe Pengiriman` ditampilkan read-only bernilai `Normal`.
  - AC-042.3: Kartu pilihan jenis order (`FTL`/`FCL`/`LTL`/`LCL`) tidak dapat diklik/diubah pada mode edit.
  - AC-042.4: Field identitas order (`ID Order`, `Tanggal Dibuat`) juga read-only.
- **REQ-043**
  - AC-043.1: Section `Data Pengirim` dan `Data Penerima` dapat diubah (drop point, PIC, No. WhatsApp, catatan).
  - AC-043.2: Section `Data Barang` dapat diubah — menambah barang via `Pilih Barang`, mengubah `Jumlah`, mengubah status asuransi & `Nilai Barang`, menghapus baris, mengubah `Nomor DO`.
  - AC-043.3: Section `Vendor dan Harga` dapat diubah (`Vendor`, `Tanggal Permintaan Muat`, `Harga`, komponen harga).
  - AC-043.4: Perubahan `Nilai Barang`/asuransi memperbarui perhitungan `Asuransi` dan `Total Harga` (REQ-032).
  - AC-043.5: Validasi field wajib tetap berlaku pada `Edit Order` — `Simpan` ditahan bila ada field wajib kosong.
  - AC-043.6: Untuk LTL/LCL, `Jenis Armada`/`Jumlah Armada` mengikuti batasan 1 unit (lihat ASM-015).
- **REQ-044**
  - AC-044.1: `Edit Order` menampilkan tombol `Batal` dan `Simpan`.
  - AC-044.2: Klik `Batal` menampilkan pop up konfirmasi sebelum keluar.
  - AC-044.3: Konfirmasi `Batal` → perubahan **tidak** tersimpan dan user kembali ke halaman sebelumnya.
  - AC-044.4: Membatalkan pop up konfirmasi → user tetap di halaman `Edit Order` dengan perubahan utuh.
  - AC-044.5: Klik `Simpan` menampilkan pop up konfirmasi sebelum menyimpan.
  - AC-044.6: Konfirmasi `Simpan` → perubahan tersimpan dan muncul notifikasi sukses.

---

### R8. Pembatalan Order

| ID | Requirement | Sumber | Prioritas |
|---|---|---|---|
| **REQ-045** | Order dapat **dibatalkan selama status berada dalam rentang draft hingga `Ditugaskan`**; **tidak dapat dibatalkan setelah status `Proses Pengiriman`**. | L70 | high |
| **REQ-046** | Pembatalan order dilakukan oleh **admin shipper**, **bukan oleh vendor**. | L71 | high |
| **REQ-047** | Field **`Alasan Pembatalan` wajib diisi** saat melakukan pembatalan. | L72 | high |

**Acceptance Criteria**

- **REQ-045**
  - AC-045.1: Aksi `Batalkan Order` tersedia pada status `Isi Data Pengiriman`, `Isi Data Muatan`, `Isi Data Vendor`, `Review Order`, `Menunggu Penugasan`, dan `Ditugaskan`.
  - AC-045.2: Aksi `Batalkan Order` **tidak** tersedia pada status `Proses Pengiriman`, `Selesai`, dan `Dibatalkan`.
  - AC-045.3: Setelah pembatalan dikonfirmasi, status order berubah menjadi `Dibatalkan`.
  - AC-045.4: Order berstatus `Dibatalkan` tidak lagi dapat diedit maupun dibatalkan ulang.
  - AC-045.5: Order yang dibatalkan tercatat pada `Riwayat Pembatalan` (REQ-050).
  - AC-045.6: Percobaan pembatalan via akses langsung pada order `Proses Pengiriman` ditolak sistem.
- **REQ-046**
  - AC-046.1: Aksi `Batalkan Order` tersedia bagi akun shipper (admin shipper / staff operasional shipper).
  - AC-046.2: Akun vendor **tidak** memiliki aksi `Batalkan Order` pada order LTL/LCL.
  - AC-046.3: Riwayat pembatalan mencatat pembatalan sebagai tindakan pihak shipper.
- **REQ-047**
  - AC-047.1: Pop up pembatalan menampilkan field `Alasan Pembatalan` bertanda wajib.
  - AC-047.2: Menekan tombol konfirmasi dengan `Alasan Pembatalan` kosong menampilkan pesan validasi dan **tidak** membatalkan order.
  - AC-047.3: Input hanya berisi spasi diperlakukan sebagai kosong (lihat ASM-016).
  - AC-047.4: Setelah diisi dan dikonfirmasi, alasan tersimpan dan dapat dilihat pada `Riwayat Pembatalan`.

---

### R9. Aksi pada Daftar Order

| ID | Requirement | Sumber | Prioritas |
|---|---|---|---|
| **REQ-048** | **Aksi per baris menyesuaikan status order** sesuai matriks di bawah. | L76–L78 | high |
| **REQ-049** | Aksi **`Edit` tidak tersedia** pada order berstatus **`Ditugaskan`**. | L78 | high |
| **REQ-050** | Tombol **`Riwayat Pembatalan`** pada toolbar `Daftar Order` menampilkan **daftar seluruh order yang pernah dibatalkan**. | L79 | medium |
| **REQ-051** | Aksi per-baris **`Riwayat Perubahan`** menampilkan **histori perubahan order tertentu** — terpisah dan berbeda dari `Riwayat Pembatalan`. | L79 | medium |

**Matriks Status → Aksi Baris**

| Status | Aksi tersedia | Sumber |
|---|---|---|
| `Isi Data Pengiriman` / `Isi Data Muatan` / `Isi Data Vendor` / `Review Order` | `Detail`, `Lanjutkan Pengisian`, `Batalkan Order`, `Riwayat Perubahan` | L76 |
| `Menunggu Penugasan` | `Detail`, `Edit`, `Batalkan Order`, `Riwayat Perubahan`, **`Lihat No. Resi`** | L77 + L85 (ASM-018) |
| `Ditugaskan` | `Detail`, `Batalkan Order`, `Riwayat Perubahan`, **`Lihat No. Resi`** — **tanpa `Edit`** | L78 + L84–85 (ASM-017) |
| `Proses Pengiriman` / `Selesai` | `Detail`, `Riwayat Perubahan`, `Lihat No. Resi` — tanpa `Edit`, tanpa `Batalkan Order` | INF (ASM-019) |
| `Dibatalkan` | `Detail`, `Riwayat Perubahan` | INF (ASM-019) |

**Acceptance Criteria**

- **REQ-048**
  - AC-048.1: Menu aksi baris dibuka melalui tombol `...` pada kolom paling kanan.
  - AC-048.2: Isi menu untuk setiap status sesuai matriks di atas — tidak lebih dan tidak kurang.
  - AC-048.3: `Detail` tersedia pada **seluruh** status.
  - AC-048.4: `Lanjutkan Pengisian` hanya tersedia pada empat status draft.
  - AC-048.5: `Lanjutkan Pengisian` membuka wizard pada step yang sesuai dengan status draft-nya.
- **REQ-049**
  - AC-049.1: Menu aksi pada baris berstatus `Ditugaskan` **tidak** memuat item `Edit`.
  - AC-049.2: `Detail Order` untuk order `Ditugaskan` **tidak** menampilkan tombol `Edit Order`.
  - AC-049.3: Baris `Ditugaskan` tetap memuat `Detail`, `Batalkan Order`, dan `Riwayat Perubahan`.
- **REQ-050**
  - AC-050.1: Toolbar `Daftar Order` menampilkan tombol `Riwayat Pembatalan` di samping `Buat Order`, `Batch Order`, dan `Filter`.
  - AC-050.2: Klik `Riwayat Pembatalan` menampilkan daftar **seluruh** order yang pernah dibatalkan (lintas order, bukan per baris).
  - AC-050.3: Order yang baru saja dibatalkan muncul pada daftar tersebut beserta alasan pembatalannya.
  - AC-050.4: Tombol `Riwayat Pembatalan` tetap dapat diakses meskipun tidak ada order yang dibatalkan (menampilkan empty state).
- **REQ-051**
  - AC-051.1: Aksi `Riwayat Perubahan` hanya tersedia pada menu aksi **per baris**, bukan pada toolbar.
  - AC-051.2: `Riwayat Perubahan` menampilkan histori perubahan **order yang dipilih saja**.
  - AC-051.3: Isi `Riwayat Perubahan` berbeda dari isi `Riwayat Pembatalan` (histori perubahan vs daftar order dibatalkan).
  - AC-051.4: Perubahan hasil `Edit Order` muncul sebagai entri baru pada `Riwayat Perubahan`.

---

### R10. No. Resi

| ID | Requirement | Sumber | Prioritas |
|---|---|---|---|
| **REQ-052** | **No. Resi digunakan untuk pengecekan pada public tracking** sehingga pengirim/penerima dapat mengetahui progress pengiriman barang. | L82 | high |
| **REQ-053** | **No. Resi di-generate otomatis oleh sistem** dan **melekat pada barang** (bukan pada order/unit). | L83 | high |
| **REQ-054** | No. Resi **hanya tampil untuk jenis pengiriman LTL & LCL**. | L84 | high |
| **REQ-055** | Aksi **`Lihat No. Resi`** pada action menu order **langsung tampil setelah seluruh step order terisi & disimpan**, atau saat status order **`Menunggu Penugasan`** — berbeda dengan `No. Perjalanan` FTL/FCL yang baru tampil saat `Ditugaskan`. | L85 | high |
| **REQ-056** | Klik aksi tersebut menampilkan pop up **`Data No. Resi`** berisi **No. Resi hasil generate sistem** serta **daftar barang berupa `Kode SKU` dan `Nama Barang`**. | L86 | high |
| **REQ-057** | Pada pop up, No. Resi dilengkapi **icon copy** untuk menyalin nomor resi. | L87 | medium |
| **REQ-058** | Selain melalui action menu, **No. Resi juga dapat dilihat pada halaman `Detail Order`**. | L88 | medium |

**Acceptance Criteria**

- **REQ-052**
  - AC-052.1: No. Resi yang di-generate dapat digunakan untuk penelusuran pada halaman public tracking.
  - AC-052.2: Public tracking menampilkan progress pengiriman untuk resi yang valid.
  - AC-052.3: Resi yang tidak dikenal menampilkan pesan tidak ditemukan, bukan error sistem.
- **REQ-053**
  - AC-053.1: User **tidak** dapat mengisi/mengedit No. Resi di step manapun (tidak ada field input No. Resi).
  - AC-053.2: No. Resi ter-generate otomatis tanpa aksi tambahan setelah order disimpan.
  - AC-053.3: Setiap baris pada pop up `Data No. Resi` memasangkan satu No. Resi dengan satu barang (`Kode SKU` + `Nama Barang`).
  - AC-053.4: Jumlah baris pada pop up konsisten dengan jumlah barang pada order.
  - AC-053.5: Menambah/menghapus barang melalui `Edit Order` memperbarui daftar No. Resi (lihat ASM-021).
- **REQ-054**
  - AC-054.1: Aksi `Lihat No. Resi` tersedia pada order berjenis `LTL` dan `LCL`.
  - AC-054.2: Aksi `Lihat No. Resi` **tidak** tersedia pada order berjenis `FTL` dan `FCL`.
  - AC-054.3: Section/field No. Resi pada `Detail Order` hanya dirender untuk order LTL/LCL.
  - AC-054.4: Badge jenis order pada pop up menampilkan `LTL` atau `LCL` sesuai order.
- **REQ-055**
  - AC-055.1: Setelah Step 4 disimpan (status `Menunggu Penugasan`), aksi `Lihat No. Resi` **langsung** muncul pada menu aksi baris.
  - AC-055.2: Aksi `Lihat No. Resi` **tidak** tersedia pada order yang masih berstatus draft (`Isi Data Pengiriman` s.d. `Review Order`).
  - AC-055.3: Aksi `Lihat No. Resi` tetap tersedia pada status `Ditugaskan` dan sesudahnya.
  - AC-055.4: Perilaku ini berbeda dari FTL/FCL — verifikasi kontrol: order FTL/FCL berstatus `Menunggu Penugasan` belum menampilkan `Lihat No. Perjalanan`.
- **REQ-056**
  - AC-056.1: Klik `Lihat No. Resi` membuka dialog berjudul `Data No. Resi`.
  - AC-056.2: Dialog menampilkan chip `ID Order: <id>` dan badge jenis order (`LTL`/`LCL`).
  - AC-056.3: Tabel dialog menampilkan kolom `No`, `No. Resi`, `Kode SKU`, `Nama Barang`.
  - AC-056.4: Nilai `Kode SKU` dan `Nama Barang` identik dengan data barang pada order.
  - AC-056.5: Dialog dapat ditutup melalui ikon `X` dan tidak mengubah data order.
- **REQ-057**
  - AC-057.1: Setiap baris No. Resi menampilkan ikon copy.
  - AC-057.2: Klik ikon copy menyalin nomor resi baris tersebut ke clipboard secara persis.
  - AC-057.3: Tersedia umpan balik visual setelah penyalinan berhasil (lihat ASM-022).
  - AC-057.4: Menyalin satu baris tidak mempengaruhi baris lain.
- **REQ-058**
  - AC-058.1: `Detail Order` untuk order LTL/LCL menampilkan informasi No. Resi.
  - AC-058.2: Nilai No. Resi pada `Detail Order` identik dengan yang ditampilkan pada pop up `Data No. Resi`.
  - AC-058.3: No. Resi pada `Detail Order` tersedia sejak status `Menunggu Penugasan` (konsisten REQ-055).

---

### Ringkasan Traceability

| Baris spec | REQ terkait |
|---|---|
| L3 (ketentuan umum 1) | REQ-001, REQ-002, REQ-003 |
| L4 (perbedaan Step 2) | REQ-004 |
| L5 (penyesuaian Step 4) | REQ-005 |
| L8 (Step 1 = TMS) | REQ-006 |
| L9 (LCL: pelabuhan, jumlah kontainer) | REQ-007 |
| L10 (LTL: kota, kota dilepas) | REQ-008, REQ-009 |
| L11 (tipe Normal, auto-draft, validasi, button) | REQ-010, REQ-011, REQ-012 |
| L14 (Master Barang) | REQ-013 |
| L16–L20 (modal Pilih Barang) | REQ-014, REQ-015, REQ-016, REQ-017, REQ-018 |
| L21 (field read-only) | REQ-019 |
| L23–L24 (Jumlah, Nilai Barang) | REQ-020, REQ-021 |
| L25 + L33 (asuransi) | REQ-022 |
| L26 + L33 (Nomor DO) | REQ-023 |
| L27 (1 unit muatan) | REQ-024 |
| L28 (tanpa alert kapasitas) | REQ-025 |
| L29 (hapus baris) | REQ-026 |
| L30 (helper error + border) | REQ-027 |
| L31 (button Step 2) | REQ-028 |
| L36 (Step 3 = TMS) | REQ-029 |
| L37 (waktu perjalanan) | REQ-030, REQ-031 |
| L38 (komponen asuransi) | REQ-032 |
| L39 (validasi & button Step 3) | REQ-033 |
| L42 (review read-only) | REQ-034 |
| L43 (struktur data barang review) | REQ-035, REQ-036 |
| L44 (button Step 4 + status) | REQ-037 |
| L47–L56 (9 status) | REQ-038 |
| L57 (draft) | REQ-039 |
| L60–L61 (hak edit) | REQ-040, REQ-041 |
| L62 (field locked) | REQ-042 |
| L63 (field editable) | REQ-043 |
| L64–L66 (button edit) | REQ-044 |
| L70–L72 (pembatalan) | REQ-045, REQ-046, REQ-047 |
| L76–L78 (aksi per status) | REQ-048, REQ-049 |
| L79 (riwayat) | REQ-050, REQ-051 |
| L82–L88 (No. Resi) | REQ-052 s.d. REQ-058 |

---

## Validation Rules

### V1. Step 1 — Jenis Pengiriman dan Rute

| Field | Wajib | Tipe/Format | Aturan | Berlaku pada |
|---|---|---|---|---|
| Jenis Order | Ya | Radio card | Tepat satu terpilih dari `FTL` / `FCL` / `LTL` / `LCL`. Modul ini mencakup **LTL & LCL**. | Semua |
| `Kota Asal` | Ya (\*) | Dropdown (Master Kota) | Harus dipilih dari Master Kota. **Tidak** memfilter `Drop Point Asal` (REQ-009). | LTL |
| `Kota Tujuan` | Ya (\*) | Dropdown (Master Kota) | Harus dipilih dari Master Kota. **Tidak** memfilter `Drop Point Tujuan`. Boleh sama dengan Kota Asal (ASM-006). | LTL |
| `Jumlah Armada` | — | Read-only | Terkunci bernilai `1` — tidak dapat diinput user (ASM-004). | LTL |
| `Pelabuhan Asal` | Ya (\*) | Dropdown (Master Pelabuhan) | Harus dipilih dari Master Pelabuhan (mis. `Tanjung Perak (SUB)`). | LCL |
| `Pelabuhan Tujuan` | Ya (\*) | Dropdown (Master Pelabuhan) | Harus dipilih dari Master Pelabuhan (mis. `Panjang (PNJ)`). Sebaiknya ≠ Pelabuhan Asal (ASM-006). | LCL |
| `Jumlah Kontainer` | — | Dihilangkan / read-only | Tidak diinput user; nilai order selalu `1` (REQ-007, REQ-024). | LCL |
| `Tipe Pengiriman` | — | Terkunci | Selalu `Normal`; tidak dapat diubah (REQ-010, ASM-005). | Semua |
| `Metode Pengiriman` | — | Tidak dirender | Tidak ada pada LTL/LCL (ASM-003). | LCL |

### V2. Step 1 — Data Pengirim / Data Penerima *(masing-masing tepat 1 baris)*

| Field | Wajib | Tipe/Format | Aturan |
|---|---|---|---|
| `Drop Point Asal` | Ya (\*) | Dropdown | Dari Master Droppoint; memicu auto-draft field wilayah & alamat asal. Tidak difilter oleh `Kota Asal`. |
| `Pengirim` | Ya (\*) | Dropdown | Dari master partner/perusahaan. |
| `PIC Pengirim` | Ya (\*) | Text | Helper `Nama PIC Pengirim`; placeholder `Masukkan PIC Pengirim`. |
| `No. WhatsApp PIC` (pengirim) | Ya (\*) | Numerik | Helper `Contoh: 081234567898`. Hanya digit, diawali `0`, panjang wajar 10–15 digit (ASM-023). |
| `Provinsi Asal`, `Kota/Kab. Asal`, `Kecamatan Asal`, `Desa/Kelurahan Asal`, `Kode Pos`, `Alamat Asal` | — | Read-only (auto-draft) | Terisi otomatis dari `Drop Point Asal`; tidak dapat diedit manual. `Kode Pos` 5 digit. |
| `Catatan` (pengirim) | Tidak | Textarea | Opsional; ditampilkan `-` bila kosong. |
| `Drop Point Tujuan` | Ya (\*) | Dropdown | Dari Master Droppoint; memicu auto-draft data wilayah tujuan. |
| `Penerima` | Ya (\*) | Dropdown | Dari master partner/perusahaan. |
| `PIC Penerima` | Ya (\*) | Text | Helper `Nama PIC Penerima`. |
| `No. WhatsApp PIC` (penerima) | Ya (\*) | Numerik | Sama dengan aturan sisi pengirim. |
| `Provinsi Tujuan`, `Kota/Kab. Tujuan`, `Kecamatan Tujuan`, `Desa/Kelurahan Tujuan`, `Kode Pos`, `Alamat Tujuan` | — | Read-only (auto-draft) | Terisi otomatis dari `Drop Point Tujuan`. |
| `Catatan` (penerima) | Tidak | Textarea | Opsional. |
| `Tambah Baris Input` | — | **Tidak dirender** | Tipe pengiriman selalu Normal → alamat tidak dapat ditambah (REQ-010). |

### V3. Step 2 — Data Barang

| Field / Elemen | Wajib | Tipe/Format | Aturan |
|---|---|---|---|
| `Asuransikan Semua` | Tidak | Checkbox (level order) | Default tidak tercentang. Mencentang → seluruh baris barang menjadi diasuransikan (REQ-022). |
| `Asuransi` (per baris) | Tidak | Checkbox (level barang) | Dapat dicentang sebagian. Mencentang → kolom `Nilai Barang` baris tersebut menjadi input wajib. |
| `Nomor DO` | Tidak | Tag/chip input (**satu field per order**) | Multi-nilai dipisahkan koma → dirender sebagai chip yang dapat dihapus individual. Kosong ditampilkan `-`. |
| Baris barang (via `Pilih Barang`) | Ya (minimal 1 per order) | Modal Master Barang | Barang hanya dari master; tidak ada input SKU bebas. Duplikat SKU dicegah (`Sudah Ditambahkan`). |
| `Kode SKU`, `Nama Barang`, `Kemasan`, `Kubikasi`, `Dimensi`, `Berat` | — | Read-only (auto-draft) | Dari Master Barang; tidak dapat diedit (REQ-019). |
| `Jumlah` (per baris) | **Ya** | Integer > 0 | Kosong/`0` → helper error + border error. Hanya angka bulat positif (ASM-023). |
| `Nilai Barang` (per baris) | **Ya bila baris diasuransikan** | Currency (`Rp`) | Kosong/`0` saat asuransi aktif → `Nilai Barang harus diisi`. Tidak boleh negatif. Baris tanpa asuransi menampilkan teks `Tanpa Asuransi`. |
| Hapus baris | — | Ikon trash | Menghapus satu baris barang tanpa mempengaruhi baris lain (REQ-026). |
| Alert kapasitas | — | **Tidak ada** | Tidak ada pengecekan/alert berat maupun kubikasi (REQ-025). |
| Ringkasan `Total Kubikasi` / `Total Berat` per unit | — | **Tidak ada** | Konsekuensi REQ-025 (ASM-007). |

### V4. Step 2 — Modal `Pilih Barang`

| Elemen | Aturan |
|---|---|
| Pencarian | Menerima **kode barang** maupun **nama barang**; memfilter daftar secara langsung. |
| Checkbox item | Multi-select; beberapa barang dapat dipilih dalam satu sesi. |
| Label `Sudah Ditambahkan` | Muncul pada barang yang sudah ada di tabel Step 2; mencegah duplikasi. |
| Counter | Menampilkan jumlah barang terpilih saat ini. |
| `Batal` | Menutup modal tanpa perubahan. |
| `Simpan` | Menambahkan seluruh barang terpilih ke tabel Step 2 sekaligus. |

### V5. Step 3 — Vendor dan Harga

| Field | Wajib | Tipe/Format | Aturan |
|---|---|---|---|
| `Vendor` | Ya (\*) | Dropdown | Dari master vendor. |
| `Tanggal Permintaan Muat` | Ya (\*) | Datetime `DD/MM/YYYY hh:mm` | Format wajib sesuai mask. Tidak boleh di masa lalu (ASM-024). |
| `Waktu Perjalanan` | Ya (\*) — **LTL saja** | Integer, satuan `Jam` | **LTL:** textfield bila rute belum ada di Master Waktu Perjalanan (disertai info master baru); text-only bila rute sudah ada. **LCL: field tidak dirender** (REQ-031). Minimal `1` jam (ASM-023). |
| `Harga` | Ya (\*) | Currency (`Rp`) | Nilai > 0. |
| `Gunakan komponen harga` | Tidak | Checkbox | Default tidak tercentang. Bila dicentang → menampilkan input `PPN (%)` dan `PPh (%)`. |
| `PPN` | Ya bila komponen harga aktif | Persen (desimal) | Range wajar `0`–`100`. Contoh `1,1`. |
| `PPh` | Ya bila komponen harga aktif | Persen (desimal) | Range wajar `0`–`100`. Contoh `2`. Bersifat pengurang (`- Rp`). |
| `Asuransi` | Kondisional (otomatis) | Persen (desimal) | Muncul hanya bila ada barang diasuransikan. Nilai = `persentase × Total Nilai Barang`. Contoh `0,2%`. |
| `Total Harga` | — | Kalkulasi | `Harga DPP + PPN − PPh + Asuransi`. |
| Rekap muatan | — | Read-only | Menampilkan `Total Berat`, `Total Kubikasi`, `Total Nilai Barang`; `Tanpa Asuransi` bila tidak ada barang diasuransikan. Satu baris unit (ASM-008). |

### V6. Pembatalan Order

| Field | Wajib | Tipe/Format | Aturan |
|---|---|---|---|
| `Alasan Pembatalan` | **Ya** | Textarea | Kosong → validasi gagal, order tidak dibatalkan. Input hanya spasi diperlakukan kosong (ASM-016). |
| Konfirmasi pembatalan | — | Pop up | Wajib dikonfirmasi sebelum status berubah menjadi `Dibatalkan`. |

### V7. Aturan Lintas-Step

| Aturan | Detail |
|---|---|
| Navigasi step | `Selanjutnya` menahan navigasi selama masih ada field wajib kosong pada step aktif (REQ-012, REQ-027, REQ-033). |
| Kardinalitas unit | Selalu **1 unit muatan**; tidak ada blok berulang armada/kontainer di step manapun (REQ-024). |
| Kardinalitas alamat | Selalu **1 pengirim & 1 penerima**; tidak ada `Tambah Baris Input` (REQ-010). |
| Propagasi asuransi | Status asuransi per barang (Step 2) → komponen `Asuransi` (Step 3) → penanda & nominal (Step 4, Detail Order) (REQ-022, REQ-032, REQ-036). |
| Konsistensi data | Data pada Step 4 dan Detail Order harus identik dengan input Step 1–3 tanpa transformasi (REQ-034, REQ-035). |
| Draft otomatis | `Simpan ke Draf` tersedia di seluruh step dan menetapkan status draft sesuai step (REQ-039). |
| Ketersediaan No. Resi | Tersedia sejak status `Menunggu Penugasan`, eksklusif LTL/LCL (REQ-054, REQ-055). |
| Kuota order | Sidebar menampilkan `Kuota Order` (mis. `120/300`, `40%`). Pembuatan order diperkirakan ditolak bila kuota habis (ASM-025). |

### V8. Katalog Pesan & Teks yang Teridentifikasi

| Teks | Jenis | Lokasi |
|---|---|---|
| `Nilai Barang harus diisi` | Error inline | Step 2 — kolom `Nilai Barang` saat asuransi aktif |
| `Jumlah harus diisi` | Error inline (pola) | Step 2 — kolom `Jumlah` (ASM-026) |
| `Berlaku untuk seluruh barang pada armada ini` | Helper | Step 2 — di bawah `Asuransikan Semua` (ASM-027) |
| `Pisahkan dengan koma untuk menambahkan beberapa nomor` | Helper | Step 2 — `Nomor DO` |
| `Tanpa Asuransi` | Teks nilai | Step 2/3/4 & Detail Order — kolom `Nilai Barang` / `Total Nilai Barang` |
| `Sudah Ditambahkan` | Badge state | Modal `Pilih Barang` |
| `<n> barang terpilih` | Counter | Modal `Pilih Barang` |
| `Rute belum ada di Master Waktu Perjalanan. Isi waktu perjalanan, nilainya akan otomatis tersimpan sebagai data master baru.` | Info | Step 3 (LTL) |
| `(Total Nilai Barang = Rp<nominal>)` | Catatan kalkulasi | Step 3 / Step 4 — baris `Asuransi` |
| `Data No. Resi` | Judul dialog | Pop up No. Resi |
| `ID Order: <id>` | Chip | Pop up `Data No. Resi` |
| `Nama PIC Pengirim` / `Nama PIC Penerima` | Helper | Step 1 |
| `Contoh: 081234567898` | Helper | Step 1 — `No. WhatsApp PIC` |
| `Menampilkan x - y data dari z data` | Info paginasi | Daftar Order |

---

## Roles & Permissions

> Spec menyebut aktor secara eksplisit hanya pada tiga titik: **Shipper** (hak edit, L60–L61), **admin shipper** (pembatalan, L71 — dan L56 sebagai pihak yang membatalkan), serta **vendor** (melakukan penugasan, L53; dan **bukan** pihak yang membatalkan, L71). Role lain diinferensikan — lihat ASM-028.

| Role | Konteks | Hak Akses pada Modul OMS-015 |
|---|---|---|
| **Staff Operasional (Shipper)** | Pengguna utama modul; badge peran pada header aplikasi | Akses `Daftar Order`; `Buat Order` (wizard 4 step LTL/LCL) & `Batch Order`; `Simpan ke Draf`; `Lanjutkan Pengisian`; `Edit Order` (draft s.d. `Menunggu Penugasan`); `Batalkan Order` (draft s.d. `Ditugaskan`); `Detail Order`; `Lihat No. Resi`; `Riwayat Perubahan`; `Riwayat Pembatalan`; `Filter`. |
| **Admin Shipper** | Aktor pembatalan yang disebut eksplisit pada spec (L56, L71) | Seluruh hak Staff Operasional + **kewenangan membatalkan order** (`Batalkan Order` + mengisi `Alasan Pembatalan`). |
| **Vendor / Transporter** | Pihak eksternal | **Melakukan penugasan** (memicu status `Ditugaskan`) dan memperbarui status penugasan armada (`Dalam Perjalanan` → `Proses Pengiriman`; `Selesai` → `Selesai`). **Tidak** memiliki hak membatalkan order (L71) dan **tidak** memiliki akses ke wizard pembuatan/pengeditan order OMS. |
| **Pengirim / Penerima (public)** | Pihak yang melacak kiriman | Hanya akses **public tracking** menggunakan `No. Resi` untuk melihat progress pengiriman (L82). Tidak memiliki akses ke OMS. |
| **Guest / Unauthenticated** | — | Tidak memiliki akses ke seluruh URL modul; harus di-redirect ke halaman login. Public tracking merupakan kanal terpisah. |

### Matriks Hak Akses Ringkas

| Aksi | Staff Operasional | Admin Shipper | Vendor | Publik (pengirim/penerima) | Guest |
|---|:--:|:--:|:--:|:--:|:--:|
| Lihat `Daftar Order` | ✔ | ✔ | ✘ | ✘ | ✘ |
| `Buat Order` / `Batch Order` LTL–LCL | ✔ | ✔ | ✘ | ✘ | ✘ |
| `Simpan ke Draf` / `Lanjutkan Pengisian` | ✔ | ✔ | ✘ | ✘ | ✘ |
| `Edit Order` (draft s.d. `Menunggu Penugasan`) | ✔ | ✔ | ✘ | ✘ | ✘ |
| `Edit Order` (status `Ditugaskan` ke atas) | ✘ | ✘ | ✘ | ✘ | ✘ |
| `Batalkan Order` (draft s.d. `Ditugaskan`) | ✔ | ✔ | **✘** | ✘ | ✘ |
| `Batalkan Order` (`Proses Pengiriman` ke atas) | ✘ | ✘ | ✘ | ✘ | ✘ |
| Melakukan penugasan vendor | ✘ | ✘ | ✔ | ✘ | ✘ |
| Lihat `Detail Order` & `Lihat No. Resi` | ✔ | ✔ | ✘ | ✘ | ✘ |
| `Riwayat Perubahan` / `Riwayat Pembatalan` | ✔ | ✔ | ✘ | ✘ | ✘ |
| Public tracking via `No. Resi` | ✔ | ✔ | — | ✔ | ✔ |

---

## User Flows

### Prasyarat Global

1. User terautentikasi sebagai shipper dengan role yang berwenang (lihat Roles & Permissions).
2. Master data tersedia: **Master Kota** (LTL), **Master Pelabuhan** (LCL), **Master Droppoint**, **Master Barang**, master partner (Pengirim/Penerima), master vendor, **Master Waktu Perjalanan** (LTL).
3. Kuota order masih tersedia.

---

### F1. Flow Utama — Buat Order **LTL**

**Step 1 — Data Pengiriman**
1. User membuka `Beranda` → `Daftar Order` → klik `Buat Order`.
2. Sistem menampilkan wizard dengan stepper `01 Data Pengiriman` aktif.
3. User memilih kartu jenis order **`LTL Less Than Truck Load`**.
4. Sistem menampilkan field rute LTL: `Kota Asal`\*, `Kota Tujuan`\*, dan `Jumlah Armada` (read-only `1`).
5. User memilih `Kota Asal` dan `Kota Tujuan` dari Master Kota. **Pilihan kota tidak memfilter drop point** (REQ-009).
6. Section `Data Pengirim` dan `Data Penerima` tampil masing-masing **satu blok**, tanpa `Tambah Baris Input` (REQ-010).
7. User memilih `Drop Point Asal` → sistem auto-draft `Provinsi Asal`, `Kota/Kab. Asal`, `Kecamatan Asal`, `Desa/Kelurahan Asal`, `Kode Pos`, `Alamat Asal` (read-only).
8. User mengisi `Pengirim`, `PIC Pengirim`, `No. WhatsApp PIC`, dan `Catatan` (opsional).
9. User memilih `Drop Point Tujuan` → auto-draft data wilayah tujuan; user mengisi `Penerima`, `PIC Penerima`, `No. WhatsApp PIC`, `Catatan` (opsional).
10. User klik `Selanjutnya`.

**Step 2 — Data Barang** *(pembeda inti)*
11. Sistem menampilkan section `Data Barang` tunggal — **tanpa** blok `Armada n`/`Kontainer n` dan **tanpa** sub-section alamat (REQ-024).
12. (Opsional) User mengisi `Nomor DO` — beberapa nomor dipisah koma → menjadi chip (REQ-023).
13. User klik **`Pilih Barang`** → modal Master Barang terbuka.
14. User mencari barang via kode/nama, mencentang beberapa SKU (multi-select), memperhatikan counter terpilih, lalu klik `Simpan`.
15. Barang masuk ke tabel dengan `Kode SKU`, `Nama Barang`, `Kemasan`, `Kubikasi`, `Dimensi`, `Berat` **read-only** hasil draft master (REQ-019).
16. User mengisi **`Jumlah`** pada setiap baris barang (wajib).
17. (Opsional) User mencentang `Asuransi` pada baris tertentu, atau `Asuransikan Semua` untuk seluruh barang → kolom `Nilai Barang` muncul dan wajib diisi pada baris terkait (REQ-021, REQ-022).
18. Sistem **tidak** menampilkan alert/ringkasan kapasitas berat maupun kubikasi (REQ-025).
19. (Opsional) User menghapus baris barang melalui ikon hapus.
20. User klik `Selanjutnya`.

**Step 3 — Vendor dan Harga**
21. Sistem menampilkan ringkasan rute (`Drop Point Asal`, `Drop Point Tujuan`) dan rekap muatan (`Total Berat`, `Total Kubikasi`, `Total Nilai Barang`).
22. User memilih `Vendor` dan mengisi `Tanggal Permintaan Muat`.
23. User mengisi **`Waktu Perjalanan`** — editable bila rute belum ada di Master Waktu Perjalanan (muncul info nilai akan tersimpan sebagai master baru); text-only bila rute sudah ada (REQ-030).
24. User mengisi `Harga`.
25. (Opsional) User centang `Gunakan komponen harga` → isi `PPN` dan `PPh`. Bila ada barang diasuransikan, komponen `Asuransi (n%)` otomatis ikut dihitung ke `Total Harga` (REQ-032).
26. User klik `Selanjutnya`.

**Step 4 — Review**
27. Sistem menampilkan seluruh section read-only: `Jenis Pengiriman dan Rute`, `Data Pengirim`, `Data Penerima`, `Data Barang`, `Vendor dan Harga`.
28. Section `Data Barang` mengikuti struktur Step 2 OMS: `Kode SKU`/`Nama Barang`, `Kemasan`, `Kubikasi`/`Dimensi`, `Berat`, `Jumlah`, `Nilai Barang` (`Tanpa Asuransi` untuk baris tanpa asuransi) (REQ-035, REQ-036).
29. User klik **`Simpan`** → status order menjadi **`Menunggu Penugasan`**; sistem mengarahkan ke `Daftar Order`.

**Pasca-simpan**
30. Aksi **`Lihat No. Resi`** langsung tersedia pada menu aksi baris (REQ-055).
31. User klik `Lihat No. Resi` → pop up `Data No. Resi` menampilkan `ID Order`, badge `LTL`, dan tabel `No` / `No. Resi` / `Kode SKU` / `Nama Barang`, dengan ikon copy per baris (REQ-056, REQ-057).
32. `No. Resi` juga dapat dilihat pada halaman `Detail Order` (REQ-058).

---

### F2. Flow — Buat Order **LCL**

Perbedaan terhadap F1:

- **Step 1 (langkah 3–5):** user memilih kartu **`LCL Less Than Container Load`**. Sistem menampilkan `Pelabuhan Asal`\* dan `Pelabuhan Tujuan`\* dari **Master Pelabuhan**, serta `Jumlah Kontainer` yang **dihilangkan sebagai input** (terkunci `1`). Field `Kota Asal`/`Kota Tujuan` **tidak** dirender (REQ-007). Pemilihan pelabuhan **tidak terikat** kota manapun (REQ-009).
- **Step 2:** identik dengan F1 — satu grup barang, `Jumlah Kontainer` order selalu `1` (REQ-024).
- **Step 3 (langkah 23):** field **`Waktu Perjalanan` tidak dirender sama sekali**. Nilainya dihitung sistem sebagai **ETA − ETD + 4 hari** dan **baru tampil pada `Detail Order` saat status `Ditugaskan`** (REQ-031).
- **Step 4 & pasca-simpan:** identik dengan F1; badge pada pop up `Data No. Resi` menampilkan **`LCL`**.

---

### Flow Alternatif & Percabangan

| Kode | Nama | Langkah |
|---|---|---|
| **ALT-01** | Simpan ke Draf | Pada Step 1/2/3/4 user klik `Simpan ke Draf` → (pop up konfirmasi) → order tersimpan dengan status `Isi Data Pengiriman` / `Isi Data Muatan` / `Isi Data Vendor` / `Review Order` → muncul di `Daftar Order` (REQ-039). |
| **ALT-02** | Lanjutkan Pengisian | Dari `Daftar Order`, menu `...` → `Lanjutkan Pengisian` → wizard terbuka pada step yang sesuai dengan seluruh data ter-restore (barang, chip Nomor DO, status asuransi per barang). |
| **ALT-03** | Navigasi mundur | User klik `Sebelumnya` dari Step 2/3/4 → kembali ke step sebelumnya dengan data terisi utuh. |
| **ALT-04** | Batal buat order | User klik `Batal` di step manapun → pop up konfirmasi → wizard ditutup, kembali ke `Daftar Order` tanpa menyimpan. |
| **ALT-05** | Batal pilih barang | Pada modal `Pilih Barang`, user klik `Batal` / ikon `X` → modal tertutup tanpa menambahkan barang (REQ-018). |
| **ALT-06** | Tambah barang berulang | User membuka `Pilih Barang` kembali → barang yang sudah ada berlabel `Sudah Ditambahkan` dan tidak terduplikasi (REQ-016). |
| **ALT-07** | Hapus barang | User klik ikon hapus pada baris barang → baris hilang; label `Sudah Ditambahkan` pada modal ikut hilang (REQ-026). |
| **ALT-08** | Edit Order | Dari `Daftar Order`/`Detail Order` (status draft s.d. `Menunggu Penugasan`), aksi `Edit`/`Edit Order` → ubah data (kecuali `Jenis Pengiriman` & `Tipe Pengiriman` yang terkunci) → `Simpan` → pop up konfirmasi → tersimpan (REQ-040, REQ-042, REQ-044). |
| **ALT-09** | Batal Edit Order | Pada `Edit Order`, user klik `Batal` → pop up konfirmasi → perubahan dibuang, kembali ke halaman sebelumnya. |
| **ALT-10** | Batalkan Order | Aksi `Batalkan Order` (status draft s.d. `Ditugaskan`) → pop up berisi `Alasan Pembatalan` (wajib) → konfirmasi → status menjadi `Dibatalkan` dan tercatat pada `Riwayat Pembatalan` (REQ-045, REQ-047). |
| **ALT-11** | Riwayat Pembatalan | Toolbar `Daftar Order` → `Riwayat Pembatalan` → daftar seluruh order yang pernah dibatalkan (REQ-050). |
| **ALT-12** | Riwayat Perubahan | Menu `...` per baris → `Riwayat Perubahan` → histori perubahan order tersebut saja (REQ-051). |
| **ALT-13** | Lihat No. Resi | Menu `...` → `Lihat No. Resi` (sejak `Menunggu Penugasan`) → pop up `Data No. Resi` → salin resi via ikon copy (REQ-055 s.d. REQ-057). |
| **ALT-14** | Public tracking | Pengirim/penerima memasukkan `No. Resi` pada halaman public tracking → progress pengiriman barang ditampilkan (REQ-052). |
| **ALT-15** | Batch Order | Toolbar `Daftar Order` → `Batch Order` → unggah/isi batch → order LTL/LCL terbentuk mengikuti seluruh rule modul (REQ-003). |
| **ALT-16** | Filter Daftar Order | Klik `Filter` → isi kriteria (mis. `Jenis Order` = `LTL`/`LCL`, `Status`) → `Terapkan` / `Reset`. |

### Skenario Percabangan Negatif / Edge

| Kode | Kondisi | Ekspektasi |
|---|---|---|
| **EX-01** | Field wajib Step 1 kosong lalu klik `Selanjutnya` | Navigasi ditahan; validasi inline muncul (REQ-012). |
| **EX-02** | Baris barang ada tetapi `Jumlah` kosong | Helper error + border error pada field `Jumlah`; navigasi ditahan (REQ-020, REQ-027). |
| **EX-03** | Asuransi baris dicentang tetapi `Nilai Barang` kosong | Pesan `Nilai Barang harus diisi` + border error; navigasi ditahan (REQ-021, REQ-027). |
| **EX-04** | User mengisi `Jumlah` sangat besar (melebihi kapasitas armada/kontainer) | **Tidak ada** alert kubikasi/berat; `Selanjutnya` tetap aktif dan order dapat disimpan (REQ-025). |
| **EX-05** | User mencari kode/nama barang yang tidak ada di master | Modal menampilkan empty state, bukan error. |
| **EX-06** | User memilih barang yang sudah ada lalu `Simpan` | Tidak ada baris duplikat; barang tetap satu baris (REQ-016). |
| **EX-07** | User memilih `Kota Asal` berbeda dari kota `Drop Point Asal` | Order tetap valid dan dapat disimpan — kota tidak mengikat drop point (REQ-009). |
| **EX-08** | User mencoba menambah alamat pengirim/penerima | Tidak ada kontrol `Tambah Baris Input` yang tersedia (REQ-010). |
| **EX-09** | User membuka Step 3 pada order **LCL** | Field `Waktu Perjalanan` tidak dirender; order tetap dapat lanjut (REQ-031). |
| **EX-10** | User melihat `Detail Order` LCL berstatus `Menunggu Penugasan` | `Waktu Perjalanan` **belum** tampil; baru tampil saat status `Ditugaskan` (REQ-031). |
| **EX-11** | Seluruh barang dihapus lalu klik `Selanjutnya` | Navigasi ditahan (minimal 1 barang) — ASM-009. |
| **EX-12** | Akses `Edit Order` pada order berstatus `Ditugaskan` (termasuk via URL langsung) | Ditolak — redirect/pesan error, bukan hanya disembunyikan di UI (REQ-041). |
| **EX-13** | Akses `Batalkan Order` pada order berstatus `Proses Pengiriman` | Aksi tidak tersedia; percobaan langsung ditolak (REQ-045). |
| **EX-14** | Konfirmasi pembatalan dengan `Alasan Pembatalan` kosong | Validasi gagal; order **tidak** berubah status (REQ-047). |
| **EX-15** | Order masih berstatus draft lalu user mencari aksi `Lihat No. Resi` | Aksi tidak tersedia (REQ-055). |
| **EX-16** | Order **FTL/FCL** dibuka menu aksinya | `Lihat No. Resi` tidak tersedia — eksklusif LTL/LCL (REQ-054). |
| **EX-17** | User mencoba mengubah `Jenis Pengiriman`/`Tipe Pengiriman` pada `Edit Order` | Field terkunci/read-only, tidak dapat diubah (REQ-042). |
| **EX-18** | User menutup pop up konfirmasi `Simpan` pada `Edit Order` | Tetap di halaman `Edit Order` dengan perubahan utuh; data belum tersimpan (REQ-044). |
| **EX-19** | User mengisi `Nomor DO` dengan koma berlebih / spasi | Chip terbentuk rapi tanpa chip kosong (ASM-020). |
| **EX-20** | User mencentang `Asuransikan Semua` lalu melepas centang satu baris | Baris tersebut kembali menampilkan `Tanpa Asuransi`; `Asuransikan Semua` tidak lagi tercentang penuh (REQ-022, ASM-002). |

---

## UI Inventory

> **Tahap pipeline:** 2/4 — design-analyzer — *selesai.*
> **Sumber:** 10 aset PNG pada `inputs/oms015-order-ltl-lcl-universal/designs/`. Setiap layar diberi ID `UI-0xx` mengikuti nomor file agar dapat dirujuk langsung oleh scenario-generator (mis. `@UI-098`).
> **Konvensi selector:** prioritas **1)** `getByRole()` + accessible name, **2)** `getByLabel()`, **3)** `getByText()` / `getByPlaceholder()`, **4)** `getByTestId()`. Seluruh nilai `data-testid` pada dokumen ini adalah **hipotesis** (aset berupa PNG statis, tidak ada informasi DOM) — lihat **ASM-031**.
> **Konvensi carry-over:** elemen bertanda **🚫 FTL-ONLY** hanya muncul karena aset merupakan *carry-over* layar FTL. Elemen tersebut **DILARANG** dijadikan ekspektasi positif pada skenario LTL/LCL; sebagian justru menjadi **assertion negatif** (REQ-024, REQ-025). Lihat ASM-001, ASM-007, ASM-008, ASM-033.
> **Konvensi label wajib:** label field wajib dirender sebagai `<Label> *` (asterisk merah terpisah). Gunakan regex anchor `getByLabel(/^Kota Asal/)` agar tidak rapuh terhadap asterisk/spasi.

### Ringkasan Layar

| ID | File | Nama layar | Jenis | Status verifikasi carry-over |
|---|---|---|---|---|
| **UI-096** | `096.png` | `Daftar Order` — list default | Halaman | Bersih untuk struktur; **tidak memuat baris LTL/LCL** (hanya badge `FTL`/`FCL`) |
| **UI-097** | `097-admin-buat-order-ltl.png` | `Buat Order` — Step 1 `Data Pengiriman` (**LTL**) | Wizard | **Bersih** — sesuai spec LTL |
| **UI-098** | `098.png` | `Buat Order` — Step 2 `Data Barang` | Wizard | **Campuran** — struktur tabel barang OMS benar, tetapi memuat 4 elemen FTL-only |
| **UI-099** | `099.png` | `Buat Order` — Step 3 `Vendor dan Harga` | Wizard | **CARRY-OVER FTL TERKONFIRMASI** — rekap `Armada 1`/`Armada 2`, `Jenis Armada` |
| **UI-100** | `100.png` | `Buat Order` — Step 4 `Review` | Wizard | **CARRY-OVER FTL TERKONFIRMASI** — `Jenis Pengiriman : FTL (Full Truck Load)`, `Jumlah Armada : 2` |
| **UI-101** | `101.png` | `Detail Order` (status `Menunggu Penugasan`) | Halaman | **CARRY-OVER FTL TERKONFIRMASI** — idem UI-100 + **tanpa section No. Resi** |
| **UI-102** | `102-admin-buat-order-lcl.png` | `Buat Order` — Step 1 `Data Pengiriman` (**LCL**) | Wizard | **Bersih** — sesuai spec LCL |
| **UI-103** | `103.png` | `Daftar Order` — panel `Filter` terbuka + *action menu* baris | Halaman + menu | **Campuran** — baris LTL/LCL sudah ada; menu ter-*anchor* pada baris FTL (ASM-034) |
| **UI-104** | `104.png` | Pop up `Data No. Resi` — badge **LTL** | Dialog | **Bersih** |
| **UI-105** | `105.png` | Pop up `Data No. Resi` — badge **LCL** | Dialog | **Bersih** (data dummy identik dengan UI-104 — ASM-030) |

**Tidak ada aset desain** untuk: modal `Pilih Barang`, pop up konfirmasi (`Batal`/`Simpan ke Draf`/`Simpan`), pop up `Batalkan Order`, `Riwayat Pembatalan`, `Riwayat Perubahan`, `Edit Order`, `Batch Order`, dan public tracking → diturunkan pada bagian **Layar Turunan (UI-D01…UI-D08)**, ditandai **ASM-032**.

---

### UI-COMMON — Kerangka aplikasi (muncul di seluruh layar)

| Elemen | Teks terlihat | Tipe / State | Selector rekomendasi | `data-testid` (hipotesis) |
|---|---|---|---|---|
| Logo tenant | `Mentari Sumber Kertas` | Teks/link | `getByRole('link', { name: 'Mentari Sumber Kertas' })` | `app-logo` |
| Toggle sidebar | ikon hamburger | Button (ikon, tanpa teks) | `getByRole('button', { name: /menu|sidebar/i })` | `sidebar-toggle` |
| Konteks tenant | `Shipper` | Teks | `getByText('Shipper', { exact: true })` | `header-tenant-context` |
| Badge peran | `Staff Operasional` | Badge | `getByText('Staff Operasional')` | `header-role-badge` |
| Notifikasi | ikon bel + *dot* merah (unread) | Button + indikator | `getByRole('button', { name: /notifikasi/i })` | `header-notification` |
| Profil user | `Andika` / `andikamsk@gmail.com` | Teks/menu | `getByText('andikamsk@gmail.com')` | `header-user` |
| Logout | ikon keluar (merah) | Button ikon | `getByRole('button', { name: /keluar|logout/i })` | `header-logout` |
| Nav sidebar | `Dashboard`, `Order`, `Penugasan Tracking`, `Master Wilayah`, `Master Operasional`, `Manajemen Vendor`, `Pengaturan Akun`, `Akun Saya`, `Pengaturan Sistem`, `Pusat Notifikasi` | Link (`Order` = **active/highlighted**) | `getByRole('navigation').getByRole('link', { name: 'Order' })` | `nav-order` |
| Nav `Simulasi Muatan` 🚫 **FTL-ONLY** | `Simulasi Muatan` | Link — **hanya pada UI-098/099/100/101** | `getByRole('link', { name: 'Simulasi Muatan' })` | `nav-simulasi-muatan` |
| Kartu kuota | `Kuota Order`, `120/300`, `40%` + progress bar | Widget read-only | `getByText('Kuota Order')` → `locator('..')` | `sidebar-order-quota` |
| Versi aplikasi | `Order Management System` / `Versi 1.0.0` | Teks | `getByText('Versi 1.0.0')` | `sidebar-app-version` |
| Breadcrumb | `Beranda` › `Daftar Order` › `Buat Order` \| `Detail Order` | Nav + link | `getByRole('navigation').getByRole('link', { name: 'Daftar Order' })` | `breadcrumb` |

> **Catatan:** `Simulasi Muatan` **tidak** muncul pada UI-096/097/102/103 → indikator kuat bahwa layar yang memuatnya adalah build FTL (ASM-033). Jangan jadikan assertion pada skenario LTL/LCL.

---

### UI-096 — `Daftar Order` (list default)

**Konteks:** halaman utama modul; state = data terisi (9 baris terlihat), belum ada filter aktif, tidak ada action menu terbuka.

| Elemen | Teks terlihat | Tipe / State | Selector rekomendasi | `data-testid` (hipotesis) |
|---|---|---|---|---|
| Judul halaman | `Daftar Order` | Heading (h1) | `getByRole('heading', { name: 'Daftar Order', level: 1 })` | `order-list-title` |
| Tombol buat order | `+ Buat Order` | Button primer (biru solid) | `getByRole('button', { name: 'Buat Order' })` | `order-list-create` |
| Tombol batch | `Batch Order` (ikon unduh) | Button sekunder (outline) | `getByRole('button', { name: 'Batch Order' })` | `order-list-batch` |
| Tombol riwayat batal | `Riwayat Pembatalan` (ikon jam-mundur) | Button sekunder | `getByRole('button', { name: 'Riwayat Pembatalan' })` | `order-list-cancel-history` |
| Tombol filter | `Filter` (ikon slider) | Button *toggle* — **collapsed** | `getByRole('button', { name: 'Filter' })` | `order-list-filter-toggle` |
| Ukuran halaman | `Tampilkan` `20` `data` | Dropdown | `getByLabel(/Tampilkan/)` **atau** `getByRole('combobox').first()` | `order-list-page-size` |
| Header kolom 1 | `ID Order` / sub `Vendor` | Column header | `getByRole('columnheader', { name: /ID Order/ })` | `col-id-order` |
| Header kolom 2 | `Kota Asal` / sub `Warehouse Asal` | Column header | `getByRole('columnheader', { name: /Kota Asal/ })` | `col-kota-asal` |
| Header kolom 3 | `Kota Tujuan` / sub `Warehouse Tujuan` | Column header | `getByRole('columnheader', { name: /Kota Tujuan/ })` | `col-kota-tujuan` |
| Header kolom 4 | `Total Harga` (ikon sort ⇅) / sub `Status` | Column header **sortable** | `getByRole('columnheader', { name: /Total Harga/ })` | `col-total-harga` |
| Baris order | mis. `ORD769797FSH` + vendor | Row | `getByRole('row', { name: /ORD769797FSH/ })` | `order-row-<idOrder>` |
| Badge jenis order | `FCL`, `FTL` *(pada UI-103 juga `LTL`, `LCL`)* | Badge berwarna | `row.getByText('LTL', { exact: true })` | `order-row-type-badge` |
| Nominal harga | `Rp. 22.000.000` | Teks | `row.getByText(/^Rp\./)` | `order-row-total-harga` |
| Badge status | `Isi Data Dasar`, `Isi Data Muatan`, `Isi Data Vendor`, `Review Order`, `Menunggu Penugasan`, `Ditugaskan`, `Proses Pengiriman`, `Terkirim`, `Dibatalkan` | Badge berwarna | `row.getByTestId('order-row-status')` / `row.getByText(/Menunggu Penugasan/)` | `order-row-status` |
| Tombol aksi baris | `...` (elipsis) | Button ikon → membuka menu | `row.getByRole('button', { name: /aksi|opsi|more/i })` | `order-row-actions` |
| Info paginasi | `Menampilkan 1 - 20 data dari 30 data` | Teks | `getByText(/Menampilkan \d+ - \d+ data dari \d+ data/)` | `order-list-pagination-info` |
| Paginasi | `«` `‹` `1` `2` `3` `…` `12` `›` `»` | Navigasi | `getByRole('button', { name: '2' })` | `order-list-pagination` |

**State terlihat**

| State | Bukti pada desain |
|---|---|
| Daftar terisi (9 baris) | ada |
| Badge status — 9 varian | **seluruh 9 status tergambar** (grey untuk 4 draft, biru `Menunggu Penugasan`, ungu `Ditugaskan`, oranye `Proses Pengiriman`, hijau `Terkirim`, merah `Dibatalkan`) |
| Empty state daftar | **tidak tergambar** (asumsi ASM-032) |
| Loading/skeleton | **tidak tergambar** |

**Temuan penting**

1. **Penamaan status** — badge memakai `Isi Data Dasar` (spec: `Isi Data Pengiriman`) dan `Terkirim` (spec: `Selesai`) → konfirmasi **ASM-013**. Gunakan matcher toleran `/(Isi Data Pengiriman|Isi Data Dasar)/` dan `/(Selesai|Terkirim)/`.
2. **UI-096 tidak memuat satu pun baris `LTL`/`LCL`** — hanya `FTL`/`FCL`. Baris LTL/LCL baru muncul pada UI-103. Untuk AC-001.4 (badge jenis order pada Daftar Order) gunakan UI-103 sebagai referensi.
3. Sub-label kolom memakai istilah **`Warehouse Asal/Tujuan`**, sedangkan wizard & Detail Order memakai **`Drop Point Asal/Tujuan`** → inkonsistensi terminologi (ASM-037).
4. Info paginasi `dari 30 data` tidak konsisten dengan 12 halaman pada kontrol paginasi → data dummy (ASM-040).

---

### UI-097 — `Buat Order` Step 1 `Data Pengiriman` (**LTL**)

**Konteks:** wizard baru, stepper `01` aktif, seluruh field masih kosong (**empty state**), jenis order **LTL terpilih**.

**Stepper**

| Elemen | Teks | State | Selector rekomendasi |
|---|---|---|---|
| Step 1 | `01` `Data Pengiriman` | **active** (bulat biru solid, label tebal) | `getByRole('listitem').filter({ hasText: 'Data Pengiriman' })` / `getByText('Data Pengiriman')` |
| Step 2 | `02` `Data Barang` | *untouched* (abu) | `getByText('Data Barang')` |
| Step 3 | `03` `Vendor dan Harga` | *untouched* | `getByText('Vendor dan Harga')` |
| Step 4 | `04` `Review` | *untouched* | `getByText('Review')` |

**Section `Jenis Pengiriman dan Rute`**

| Elemen | Teks / Placeholder | Tipe / State | Selector rekomendasi | `data-testid` (hipotesis) |
|---|---|---|---|---|
| Judul section | `Jenis Pengiriman dan Rute` | Heading section | `getByRole('heading', { name: 'Jenis Pengiriman dan Rute' })` | `section-jenis-rute` |
| Kartu FTL | `FTL` / `Full Truck Load` | Radio card — **unselected** | `getByRole('radio', { name: /FTL/ })` | `order-type-ftl` |
| Kartu FCL | `FCL` / `Full Container Load` | Radio card — unselected | `getByRole('radio', { name: /FCL/ })` | `order-type-fcl` |
| **Kartu LTL** | `LTL` / `Less Than Truck Load` | Radio card — **SELECTED** (border oranye, radio terisi) | `getByRole('radio', { name: /LTL/ })` → `toBeChecked()` | `order-type-ltl` |
| Kartu LCL | `LCL` / `Less Than Container Load` | Radio card — unselected | `getByRole('radio', { name: /LCL/ })` | `order-type-lcl` |
| `Kota Asal` \* | placeholder `Pilih Kota Asal` | Dropdown wajib — **empty** | `getByLabel(/^Kota Asal/)` \| fallback `getByText('Pilih Kota Asal')` | `field-kota-asal` |
| `Kota Tujuan` \* | placeholder `Pilih Kota Tujuan` | Dropdown wajib — empty | `getByLabel(/^Kota Tujuan/)` | `field-kota-tujuan` |
| `Jumlah Armada` | nilai `1` | Textbox — **disabled/read-only** (abu), **tanpa asterisk** | `getByLabel('Jumlah Armada')` → `toBeDisabled()` / `toHaveValue('1')` | `field-jumlah-armada` |

**Section `Data Pengirim`** (tepat 1 blok)

| Elemen | Teks / Placeholder / Helper | Tipe / State | Selector rekomendasi | `data-testid` (hipotesis) |
|---|---|---|---|---|
| Judul section | `Data Pengirim` | Heading | `getByRole('heading', { name: 'Data Pengirim' })` | `section-data-pengirim` |
| `Drop Point Asal` \* | `Pilih  Drop Point Asal` *(spasi ganda pada desain)* | Dropdown wajib — empty | `getByLabel(/^Drop Point Asal/)` | `field-drop-point-asal` |
| `Pengirim` \* | `Pilih Pengirim` | Dropdown wajib — empty | `getByLabel(/^Pengirim/)` | `field-pengirim` |
| `PIC Pengirim` \* | `Masukkan PIC Pengirim` • helper `Nama PIC Pengirim` | Textbox wajib — empty | `getByLabel(/^PIC Pengirim/)` | `field-pic-pengirim` |
| `No. WhatsApp PIC` \* | `Masukkan No. WhatsApp PIC` • helper `Contoh: 081234567898` | Textbox wajib (numerik) — empty | `getByLabel(/^No\. WhatsApp PIC/).first()` **(ada 2 di halaman — scope ke section!)** | `field-wa-pengirim` |
| `Provinsi Asal` | `Provinsi Asal` | Textbox **disabled** (auto-draft) | `getByLabel('Provinsi Asal')` → `toBeDisabled()` | `field-provinsi-asal` |
| `Kota/Kab. Asal` | `Kota/Kab. Asal` | Textbox disabled | `getByLabel('Kota/Kab. Asal')` | `field-kota-kab-asal` |
| `Kecamatan Asal` | `Kecamatan Asal` | Textbox disabled | `getByLabel('Kecamatan Asal')` | `field-kecamatan-asal` |
| `Desa/Kelurahan Asal` | `Desa/Kelurahan Asal` | Textbox disabled | `getByLabel('Desa/Kelurahan Asal')` | `field-desa-asal` |
| `Kode Pos` | `Kode Pos` | Textbox disabled | `section.getByLabel('Kode Pos')` **(ada 2 — scope!)** | `field-kode-pos-asal` |
| `Alamat Asal` | `Alamat Asal` | Textarea disabled | `getByLabel('Alamat Asal')` | `field-alamat-asal` |
| `Catatan` | `Masukkan Catatan` | Textarea opsional — enabled | `section.getByLabel('Catatan')` **(ada 2 — scope!)** | `field-catatan-pengirim` |

**Section `Data Penerima`** — struktur **cermin** dari `Data Pengirim`:
`Drop Point Tujuan`\* (`Pilih Drop Point Tujuan`), `Penerima`\* (`Pilih Penerima`), `PIC Penerima`\* (`Masukkan PIC Penerima`, helper `Nama PIC Penerima`), `No. WhatsApp PIC`\*, `Provinsi Tujuan`, `Kota/Kab. Tujuan`, `Kecamatan Tujuan`, `Desa/Kelurahan Tujuan`, `Kode Pos`, `Alamat Tujuan` (semua disabled/auto-draft), `Catatan`.
Testid hipotesis: `field-drop-point-tujuan`, `field-penerima`, `field-pic-penerima`, `field-wa-penerima`, `field-provinsi-tujuan`, `field-kota-kab-tujuan`, `field-kecamatan-tujuan`, `field-desa-tujuan`, `field-kode-pos-tujuan`, `field-alamat-tujuan`, `field-catatan-penerima`.

**Action bar**

| Elemen | Teks | Tipe / State | Selector rekomendasi | `data-testid` |
|---|---|---|---|---|
| Batal | `Batal` | Button outline **merah** (kiri) | `getByRole('button', { name: 'Batal' })` | `wizard-cancel` |
| Simpan draf | `Simpan ke Draf` | Button outline biru | `getByRole('button', { name: 'Simpan ke Draf' })` | `wizard-save-draft` |
| Selanjutnya | `Selanjutnya →` | Button primer | `getByRole('button', { name: 'Selanjutnya' })` | `wizard-next` |

**Elemen yang HARUS ABSEN (assertion negatif)**

| Elemen | REQ | Assertion |
|---|---|---|
| `Tambah Baris Input` | REQ-010 / AC-010.2 | `getByRole('button', { name: /Tambah Baris/i })` → `toHaveCount(0)` |
| Ikon hapus alamat | AC-010.3 | tidak ada tombol hapus di section pengirim/penerima |
| Dropdown `Tipe Pengiriman` | REQ-010 / ASM-005 | `getByLabel(/Tipe Pengiriman/)` → `toHaveCount(0)` |
| `Metode Pengiriman` | ASM-003 | `toHaveCount(0)` |
| `Pelabuhan Asal` / `Pelabuhan Tujuan` | AC-008.3 | `toHaveCount(0)` saat LTL terpilih |
| Tombol `Sebelumnya` | ASM-039 (baru) | tidak dirender pada Step 1 |

**State & validasi:** seluruh field wajib **kosong** (empty state); **tidak ada** pesan validasi yang tergambar pada aset ini → pola pesan mengikuti ASM-026 (`<Nama Field> harus diisi`) dan validasi diasumsikan muncul **setelah** `Selanjutnya` ditekan (ASM-038).

---

### UI-098 — `Buat Order` Step 2 `Data Barang` *(pembeda inti modul)*

**Konteks:** stepper — step 1 **checked (✓ biru)**, step 2 **active**, step 3–4 *untouched*. Tabel barang terisi 3 baris dengan **campuran state valid & error**.

**Kontrol level order**

| Elemen | Teks / Placeholder | Tipe / State | Selector rekomendasi | `data-testid` (hipotesis) |
|---|---|---|---|---|
| Judul section | `Data Barang` | Heading | `getByRole('heading', { name: 'Data Barang' })` | `section-data-barang` |
| Checkbox asuransi massal | `Asuransikan Semua` | Checkbox — **unchecked** | `getByRole('checkbox', { name: /Asuransikan Semua/ })` | `insure-all` |
| Helper asuransi | `Berlaku untuk seluruh barang pada armada ini` | Helper text *(kata "armada" = carry-over, ASM-027)* | `getByText(/Berlaku untuk seluruh barang/)` | `insure-all-helper` |
| `Nomor DO` | label `Nomor DO` | Tag/chip input — **terisi 2 chip** | `getByLabel('Nomor DO')` | `field-nomor-do` |
| Chip DO #1 | `TGK783898202U` + ikon `×` | Chip removable | `getByText('TGK783898202U')` / tombol hapus: `getByRole('button', { name: /TGK783898202U/ })` | `do-chip-TGK783898202U` |
| Chip DO #2 | `TBL28371302` + ikon `×` | Chip removable | idem | `do-chip-TBL28371302` |
| Helper DO | `Pisahkan dengan koma untuk menambahkan beberapa nomor` | Helper text | `getByText('Pisahkan dengan koma untuk menambahkan beberapa nomor')` | `nomor-do-helper` |
| Tombol pilih barang | `+ Pilih Barang` | Button outline biru → membuka modal | `getByRole('button', { name: 'Pilih Barang' })` | `open-pilih-barang` |

**Tabel barang — header**

`Asuransi` \| `Kode SKU` (sub `Nama Barang`) \| `Kemasan` \| `Kubikasi` (sub `Dimensi`) \| `Berat` \| `Jumlah` \| `Nilai Barang` \| *(kolom aksi tanpa header)*

Selector header: `getByRole('columnheader', { name: /Kode SKU/ })`, dst.

**Tabel barang — baris & state**

| # | Kode SKU / Nama | Kemasan | Kubikasi / Dimensi | Berat | `Asuransi` | `Jumlah` | `Nilai Barang` | State |
|---|---|---|---|---|---|---|---|---|
| 1 | `SKU-PPR-001` / `Kertas HVS A4 80 gsm` | `Dus` | `0,018 m³` / `31 × 22 × 26,4 cm` | `12,5 kg` | ✔ **checked** | `200` (valid) | input `Rp` `0` | **ERROR** — border merah + helper `Nilai Barang harus diisi` |
| 2 | `SKU-PPR-002` / `Kertas HVS F4 70 gsm` | `Karton` | `0,022 m³` / `34 × 22 × 29,4 cm` | `14,8 kg` | ☐ unchecked | `200` (valid) | teks `Tanpa Asuransi` (**bukan input**) | Normal |
| 3 | `SKU-BKU-001` / `Buku Tulis 38 Lembar` | `Dus` | `0,060 m³` / `60 × 40 × 25 cm` | `18 kg` | ✔ checked | **kosong** (placeholder `0`) | `Rp` `1.320.000` | Kosong **tanpa** helper error (→ ASM-038) |

| Elemen per baris | Tipe / State | Selector rekomendasi | `data-testid` (hipotesis) |
|---|---|---|---|
| Checkbox asuransi baris | Checkbox | `getByRole('row', { name: /SKU-PPR-001/ }).getByRole('checkbox')` | `row-insurance-SKU-PPR-001` |
| `Kode SKU` / `Nama Barang` | **Teks read-only** (bukan input) | `getByRole('cell', { name: 'SKU-PPR-001' })` | `row-sku-<sku>` |
| `Kemasan` / `Kubikasi` / `Dimensi` / `Berat` | Teks read-only | `row.getByText('12,5 kg')` | `row-berat-<sku>` |
| Input `Jumlah` | Textbox numerik, wajib | `row.getByRole('spinbutton')` \| `row.getByLabel(/Jumlah/)` | `row-jumlah-<sku>` |
| Input `Nilai Barang` | Textbox currency, prefix `Rp` — **muncul hanya bila asuransi baris aktif** | `row.getByRole('textbox', { name: /Nilai Barang/ })` | `row-nilai-barang-<sku>` |
| Teks `Tanpa Asuransi` | Teks pengganti input | `row.getByText('Tanpa Asuransi')` | `row-no-insurance-<sku>` |
| Ikon hapus baris | Button ikon trash **merah** | `row.getByRole('button', { name: /hapus|delete/i })` | `row-delete-<sku>` |

**Pesan validasi yang tampak**

| Teks persis | Lokasi | Kondisi pemicu | Selector |
|---|---|---|---|
| `Nilai Barang harus diisi` | Di bawah input `Nilai Barang` baris 1 | Asuransi baris aktif + `Nilai Barang` kosong/`0` | `row.getByText('Nilai Barang harus diisi')` |
| *(border merah)* | Input `Nilai Barang` baris 1 | idem | assertion visual/`aria-invalid="true"` |

**🚫 Elemen FTL-ONLY pada layar ini (WAJIB jadi assertion negatif untuk LTL/LCL — REQ-025)**

| Elemen | Teks persis | Assertion negatif |
|---|---|---|
| Badge alert kapasitas | `Kubikasi melebihi kapasitas armada` | `getByText(/melebihi kapasitas/)` → `toHaveCount(0)` (AC-025.1/025.2) |
| Ringkasan kubikasi | `Total Kubikasi: 19,2 / 17,86 m³` | `getByText(/Total Kubikasi:.*\/.*m³/)` → `toHaveCount(0)` (AC-025.3) |
| Ringkasan berat | `Total Berat: 19.200 / 24.800 kg` | `getByText(/Total Berat:.*\/.*kg/)` → `toHaveCount(0)` (AC-025.3) |
| Floating button *hitung ulang* | ikon *refresh* lingkaran (kanan atas) | `toHaveCount(0)` (AC-025.5) |
| Floating button *visualisasi muatan* | ikon *mata* (biru solid, kanan atas) | `toHaveCount(0)` (AC-025.5) |
| Nav `Simulasi Muatan` | sidebar | tidak di-assert (ASM-033) |

**Elemen yang HARUS ABSEN (REQ-024)**

- Card/blok berulang `Armada n` / `Kontainer n` → `getByText(/^Armada \d/)` `toHaveCount(0)`
- Sub-section `Pick Up n` / `Drop Off n` → `toHaveCount(0)`
- Input teks bebas nama/deskripsi/dimensi/berat barang (AC-004.1) → tidak ada `textbox` pada kolom identitas barang
- Tombol tambah barang selain `Pilih Barang` (AC-013.2)

**Action bar:** `Batal` (outline merah) • `← Sebelumnya` (outline) • `Simpan ke Draf` (outline) • `Selanjutnya →` (primer).
Selector: `getByRole('button', { name: 'Sebelumnya' })` → `wizard-prev`.

**Temuan penting**

1. **Struktur tabel barang sudah versi OMS** (Kode SKU dari master, read-only) — mendukung REQ-019 & REQ-013.
2. Seluruh barang berada dalam **satu tabel tunggal tanpa pengelompokan** → mendukung REQ-024 (AC-024.1/024.2) meskipun sisa layar carry-over.
3. Kolom `Asuransi` berisi **checkbox per baris** + `Asuransikan Semua` di header → bukti kuat untuk **ASM-002** (asuransi level barang).
4. Baris 3 memperlihatkan `Jumlah` kosong **tanpa** error, sedangkan baris 1 menampilkan error `Nilai Barang` → validasi diasumsikan *on-submit/on-blur* (**ASM-038**), bukan *on-render*.

---

### UI-099 — `Buat Order` Step 3 `Vendor dan Harga`

**Konteks:** stepper — step 1 & 2 **checked**, step 3 **active**. Form terisi penuh, komponen harga **aktif**. **Aset carry-over FTL terkonfirmasi.**

| Elemen | Teks / Nilai terlihat | Tipe / State | Selector rekomendasi | `data-testid` (hipotesis) |
|---|---|---|---|---|
| Judul section | `Vendor dan Harga` | Heading | `getByRole('heading', { name: 'Vendor dan Harga' })` | `section-vendor-harga` |
| `Vendor` \* | `PT Logistik Transportasi Nusantara` | Dropdown wajib — **filled** | `getByLabel(/^Vendor/)` | `field-vendor` |
| `Tanggal Permintaan Muat` \* | `24/07/2026 14:30` | Datetime wajib — filled | `getByLabel(/^Tanggal Permintaan Muat/)` | `field-tanggal-muat` |
| `Drop Point Asal` | `: Gudang MSK Region 2` • `Kota Surabaya` | **Teks read-only** | `getByText('Gudang MSK Region 2')` | `ro-drop-point-asal` |
| `Drop Point Tujuan` | `: Gudang Jaya Retail Malang` • `Kota Malang` | Teks read-only | `getByText('Gudang Jaya Retail Malang')` | `ro-drop-point-tujuan` |
| `Jenis Armada` 🚫 **FTL-ONLY** | `: Tronton Wing Box` | Teks read-only | — *(jangan di-assert untuk LTL/LCL)* | `ro-jenis-armada` |
| `Waktu Perjalanan` \* | input `8` + satuan `Jam` | Textbox wajib — **LTL saja**, editable | `getByLabel(/^Waktu Perjalanan/)` | `field-waktu-perjalanan` |
| Info master rute | `Rute belum ada di Master Waktu Perjalanan. Isi waktu perjalanan, nilainya akan otomatis tersimpan sebagai data master baru.` | **Alert info** (oranye, ikon ⓘ) | `getByRole('alert')` \| `getByText(/Rute belum ada di Master Waktu Perjalanan/)` | `alert-master-waktu-perjalanan` |
| Rekap muatan — header | `No` \| `Nama Item` \| `Total Berat` \| `Total Kubikasi` \| `Total Nilai Barang` | Table header | `getByRole('columnheader', { name: 'Total Nilai Barang' })` | `table-rekap-muatan` |
| Rekap baris 1 🚫 **FTL-ONLY** | `1.` `Armada 1` `25.570 kg` `56,10 m³` `Tanpa Asuransi` | Row | — | — |
| Rekap baris 2 🚫 **FTL-ONLY** | `2.` `Armada 2` `22.950 kg` `53,90 m³` `Tanpa Asuransi` | Row | **assertion LTL/LCL: rekap tepat 1 baris** (AC-024.4, ASM-008) | — |
| `Harga` \* | `Rp` `12.000.000` | Textbox currency wajib | `getByLabel(/^Harga/)` | `field-harga` |
| Komponen harga | `Gunakan komponen harga` | Checkbox — **CHECKED** | `getByRole('checkbox', { name: 'Gunakan komponen harga' })` | `use-price-components` |
| `PPN` | `1,1` `%` | Textbox persen (muncul saat checkbox aktif) | `getByLabel('PPN')` | `field-ppn` |
| `PPh` | `2` `%` | Textbox persen | `getByLabel('PPh')` | `field-pph` |
| Rincian `Harga DPP` | `Rp. 12.000.000` | Teks kalkulasi | `getByText('Harga DPP').locator('..')` | `sum-harga-dpp` |
| Rincian `PPN (1,1%)` | `Rp. 132.000` | Teks kalkulasi | `getByText(/^PPN \(/)` | `sum-ppn` |
| Rincian `PPh (2%)` | `- Rp. 240.000` (**pengurang**) | Teks kalkulasi | `getByText(/^PPh \(/)` | `sum-pph` |
| `Total Harga` | `Rp. 11.892.000` | Teks kalkulasi (bold) | `getByText('Total Harga').locator('..')` | `sum-total-harga` |
| Action bar | `Batal` • `← Sebelumnya` • `Simpan ke Draf` • `Selanjutnya →` | Buttons | idem UI-098 | — |

**Temuan penting**

1. **Carry-over FTL TERKONFIRMASI:** rekap muatan berisi **2 baris** (`Armada 1`, `Armada 2`) dan terdapat baris read-only `Jenis Armada : Tronton Wing Box`. Untuk LTL/LCL, rekap harus **1 baris** (ASM-008) dan `Jenis Armada` tidak relevan.
2. Baris komponen **`Asuransi` tidak muncul** pada ringkasan harga di layar ini karena rekap menunjukkan `Tanpa Asuransi` → konsisten dengan **AC-032.1**.
3. Field `Waktu Perjalanan` + alert master rute tergambar untuk kasus **LTL rute baru** (AC-030.2). Varian *text-only* (rute sudah ada di master, AC-030.3) **tidak tergambar** → asumsi.
4. Untuk **LCL** (REQ-031) tidak ada aset Step 3 → assertion `getByLabel(/Waktu Perjalanan/)` `toHaveCount(0)` dan `getByText(/Rute belum ada di Master Waktu Perjalanan/)` `toHaveCount(0)`.

---

### UI-100 — `Buat Order` Step 4 `Review`

**Konteks:** stepper — step 1–3 **checked**, step 4 **active**. Seluruh konten **read-only**. **Aset carry-over FTL terkonfirmasi.**

| Section (collapsible, chevron `^`) | Isi terlihat | Catatan |
|---|---|---|
| `Jenis Pengiriman dan Rute` | `Jenis Pengiriman : FTL (Full Truck Load)` 🚫 • `Jenis Armada : Tronton Wing Box` 🚫 • `Jumlah Armada : 2` 🚫 • **`Tipe Pengiriman : Normal`** ✔ • `Waktu Perjalanan : 8 Jam` | Untuk LTL/LCL: `Jenis Pengiriman` = `LTL (Less Than Truck Load)`/`LCL (Less Than Container Load)`, `Jumlah Armada`/`Jumlah Kontainer` = `1` (AC-024.5) |
| `Data Pengirim` | `Drop Point Asal : Gudang MSK Region 2` • `Pengirim : PT Mentari Sumber Kertas` • `PIC Pengirim : Budianto Suwarno` • `No. WhatsApp PIC : 081245676897892` • `Provinsi Asal : Jawa Timur` • `Kota/Kab. Asal : Kota Surabaya` • `Kecamatan Asal : Wonokromo` • `Desa/Kelurahan Asal : Darmo` • `Kode Pos : 60241` • `Alamat Asal : Jl. Jambi No.35` • `Catatan : Total barang 2.500 karton` | Urutan field identik Step 1 |
| `Data Penerima` | `Drop Point Tujuan : Gudang Jaya Retail Malang` • `Penerima : PT Retail Jaya Abadi` • `PIC Penerima : Basori` • `No. WhatsApp PIC : 08967278928989` • `Provinsi Tujuan : Jawa Timur` • `Kota/Kab. Tujuan : Kota Malang` • `Kecamatan Tujuan : Kedungkandang` • `Desa/Kelurahan Tujuan : Buring` • `Kode Pos : 65135` • `Alamat Tujuan : Jl. Kalianyar Buring No.9` • **`Catatan : -`** | Contoh **empty state opsional = `-`** (AC-034.5) |
| `Data Barang` | Box `Nomor DO` bernilai **`-`** + tabel barang (lihat bawah) | **Satu grup tunggal** ✔ (AC-035.4) |
| `Vendor dan Harga` | Rekap `Armada 1`/`Armada 2` 🚫 • `Vendor : PT Logistik Transportasi Nusantara` • `Tanggal Permintaan Muat : 24/07/2026 14:30` • ringkasan harga | Rekap harus 1 baris untuk LTL/LCL |

**Tabel `Data Barang` (Review)** — header: `Kode SKU` (sub `Nama Barang`) \| `Kemasan` \| `Kubikasi` (sub `Dimensi`) \| `Berat` \| `Jumlah` \| `Nilai Barang`
→ **tidak ada** kolom `Asuransi` (checkbox) dan **tidak ada** kolom aksi/hapus; penanda asuransi diwakili nilai kolom `Nilai Barang`.

| # | Kode SKU / Nama | Kemasan | Kubikasi / Dimensi | Berat | Jumlah | Nilai Barang |
|---|---|---|---|---|---|---|
| 1 | `SKU-PPR-001` / `Kertas HVS A4 80 gsm` | `Dus` | `0,018 m³` / `31 × 22 × 26,4 cm` | `12,5 kg` | `500` | `Rp. 365.000` (**diasuransikan**) |
| 2 | `SKU-PPR-002` / `Kertas HVS F4 70 gsm` | `Dus` | `0,022 m³` / `34 × 22 × 29,4 cm` | `14,8 kg` | `600` | `Tanpa Asuransi` |
| 3 | `SKU-BKU-003` / `Buku Tulis 38 Lembar` | `Dus` | `0,060 m³` / `60 × 40 × 25 cm` | `18 kg` | `250` | `Tanpa Asuransi` |
| 4 | `SKU-BKU-004` / `Buku Tulis Hard Cover A5` | `Dus` | `0,042 m³` / `40 × 35 × 30 cm` | `13,2 kg` | `450` | `Rp. 1.080.000` (**diasuransikan**) |

**Ringkasan harga (Review)**

| Baris | Nilai | Selector |
|---|---|---|
| `Harga DPP` | `Rp. 12.000.000` | `getByText('Harga DPP')` |
| `PPN (1,1%)` | `Rp. 132.000` | `getByText(/^PPN \(/)` |
| `PPh (2%)` | `- Rp. 240.000` | `getByText(/^PPh \(/)` |
| **`Asuransi (0,2%)`** | `Rp2.013.500` — **tanpa input persen** (mendukung ASM-012) | `getByText(/^Asuransi \(/)` |
| Catatan kalkulasi | `(Total Nilai Barang = Rp1.006.750.000)` | `getByText(/\(Total Nilai Barang = Rp/)` |
| `Total Harga` | `Rp13.905.500` | `getByText('Total Harga')` |

**Action bar:** `Batal` • `← Sebelumnya` • `Simpan ke Draf` • **`Simpan`** (primer — **bukan** `Selanjutnya`, AC-002.4/AC-037.1). Selector: `getByRole('button', { name: 'Simpan', exact: true })` → `wizard-submit`.

**Temuan penting**

1. **Carry-over FTL TERKONFIRMASI** — `Jenis Pengiriman : FTL (Full Truck Load)`, `Jumlah Armada : 2`, rekap 2 baris `Armada`.
2. `Tipe Pengiriman : Normal` **tergambar** → mendukung AC-010.5.
3. Format nominal **tidak konsisten**: `Rp. 12.000.000` (dengan titik setelah `Rp`) vs `Rp2.013.500` / `Rp13.905.500` (tanpa spasi & titik) → gunakan matcher toleran `/Rp\.?\s?13\.905\.500/`.
4. Σ `Nilai Barang` per baris (Rp1.445.000) **tidak sama** dengan `(Total Nilai Barang = Rp1.006.750.000)` → data dummy tidak konsisten (**ASM-040**); jangan salin angka desain sebagai ekspektasi.

---

### UI-101 — `Detail Order` (status `Menunggu Penugasan`)

**Konteks:** halaman detail read-only, order berstatus `Menunggu Penugasan` sehingga **`Edit Order` dan `Batalkan Order` keduanya tersedia**. **Aset carry-over FTL terkonfirmasi.**

| Elemen | Teks / Nilai | Tipe / State | Selector rekomendasi | `data-testid` (hipotesis) |
|---|---|---|---|---|
| Tombol kembali | ikon `‹` | Button ikon | `getByRole('button', { name: /kembali|back/i })` | `detail-back` |
| Judul | `Detail Order` | Heading | `getByRole('heading', { name: 'Detail Order' })` | `detail-title` |
| Tombol batal order | `Batalkan Order` | Button outline **merah** — **enabled** | `getByRole('button', { name: 'Batalkan Order' })` | `detail-cancel-order` |
| Tombol edit | `Edit Order` | Button outline biru — **enabled** | `getByRole('button', { name: 'Edit Order' })` | `detail-edit-order` |
| Badge status | `Menunggu Penugasan` | Badge biru, di **header section pertama** | `getByText('Menunggu Penugasan')` | `detail-status-badge` |
| `ID Order` | `: ORD67890792` | Teks read-only | `getByText('ORD67890792')` | `detail-id-order` |
| `Jenis Pengiriman` 🚫 | `: FTL (Full Truck Load)` | Teks read-only | untuk LTL/LCL → `/LTL \(Less Than Truck Load\)|LCL \(Less Than Container Load\)/` | `detail-jenis-pengiriman` |
| `Tanggal Dibuat` | `: 26/06/2026 08:17` | Teks read-only | `getByText(/\d{2}\/\d{2}\/\d{4} \d{2}:\d{2}/)` | `detail-tanggal-dibuat` |
| `Jenis Armada` 🚫 | `: Tronton Wing Box` | Teks read-only | — | — |
| `Jumlah Armada` 🚫 | `: 2` | Teks read-only | LTL/LCL harus `1` (AC-024.5) | `detail-jumlah-unit` |
| `Tipe Pengiriman` | `: Normal` | Teks read-only ✔ | `getByText('Normal')` | `detail-tipe-pengiriman` |
| `Waktu Perjalanan` | `: 8 Jam` | Teks read-only | `getByText('8 Jam')` | `detail-waktu-perjalanan` |
| Section `Data Pengirim` / `Data Penerima` / `Data Barang` / `Vendor dan Harga` | idem UI-100 (nilai sama) | Collapsible (chevron `^`) | `getByRole('heading', { name: 'Data Barang' })` | `detail-section-*` |
| Rekap muatan 🚫 | `Armada 1` `25.570 kg` `58,5 m³` `Rp512.500.000` • `Armada 2` `23.069 kg` `58,5 m³` `Rp494.250.000` | Table 2 baris | LTL/LCL → 1 baris | — |

**Temuan penting (KRITIS)**

1. **Section/field `No. Resi` TIDAK ADA pada Detail Order ini**, padahal REQ-058/AC-058.1 mensyaratkan No. Resi tampil pada Detail Order LTL/LCL sejak status `Menunggu Penugasan` → **gap desain**, dicatat sebagai **ASM-035**. Skenario REQ-058 tetap dibuat berbasis spec, dengan selector generik `getByText(/No\. Resi/)` dan tag risiko.
2. Untuk **LCL** (REQ-031/AC-031.4), `Waktu Perjalanan` **tidak boleh tampil** saat `Menunggu Penugasan`, dan baru muncul saat `Ditugaskan` → aset ini (FTL, `Menunggu Penugasan`, `Waktu Perjalanan` tampil) **tidak dapat dijadikan acuan** untuk LCL.
3. `Total Kubikasi` pada rekap berbeda dengan UI-100 (`58,5 m³` vs `56,10`/`51,74 m³`) untuk order yang sama → data dummy (**ASM-040**).

---

### UI-102 — `Buat Order` Step 1 `Data Pengiriman` (**LCL**)

**Konteks:** identik struktur dengan UI-097, kecuali blok rute. Kartu **LCL terpilih** (border biru, radio terisi); field rute **sudah terisi**.

| Elemen | Teks / Nilai | Tipe / State | Selector rekomendasi | `data-testid` (hipotesis) |
|---|---|---|---|---|
| Kartu LCL | `LCL` / `Less Than Container Load` | Radio card — **SELECTED** | `getByRole('radio', { name: /LCL/ })` → `toBeChecked()` | `order-type-lcl` |
| `Pelabuhan Asal` \* | `Tanjung Perak (SUB)` | Dropdown wajib — **filled** | `getByLabel(/^Pelabuhan Asal/)` | `field-pelabuhan-asal` |
| `Pelabuhan Tujuan` \* | `Panjang (PNJ)` | Dropdown wajib — filled | `getByLabel(/^Pelabuhan Tujuan/)` | `field-pelabuhan-tujuan` |
| `Jumlah Kontainer` | `1` | Textbox **disabled/read-only** (abu), **tanpa asterisk** | `getByLabel('Jumlah Kontainer')` → `toBeDisabled()` + `toHaveValue('1')` | `field-jumlah-kontainer` |
| `Data Pengirim` / `Data Penerima` | idem UI-097 (seluruh field kosong) | Empty state | idem UI-097 | idem |
| Action bar | `Batal` • `Simpan ke Draf` • `Selanjutnya →` | Buttons — **tanpa `Sebelumnya`** | idem UI-097 | idem |

**Elemen yang HARUS ABSEN (assertion negatif)**

| Elemen | REQ | Assertion |
|---|---|---|
| `Kota Asal` / `Kota Tujuan` | AC-007.4 | `getByLabel(/^Kota Asal/)` → `toHaveCount(0)` |
| `Jenis Kontainer` | REQ-007 (FCL-only) | `toHaveCount(0)` |
| `Metode Pengiriman` | ASM-003 | `toHaveCount(0)` |
| `Tipe Pengiriman` | ASM-005 | `toHaveCount(0)` |
| `Tambah Baris Input` | AC-010.2 | `toHaveCount(0)` |

**Temuan penting:** `Jumlah Kontainer` **tetap dirender** (read-only `1`), bukan dihilangkan dari DOM → konfirmasi **ASM-004**; assertion harus berbentuk "tidak dapat diubah", bukan "tidak ada".

---

### UI-103 — `Daftar Order` + panel `Filter` + *action menu* baris

**Konteks:** dua state sekaligus — panel Filter **expanded** (seluruh field kosong) dan action menu baris **terbuka**.

**Panel `Filter`** (muncul setelah tombol `Filter` diklik)

| # | Field | Placeholder | Tipe / State | Selector rekomendasi | `data-testid` (hipotesis) |
|---|---|---|---|---|---|
| 1 | `ID Order` | `Masukkan ID Order` | Textbox — enabled | `getByLabel('ID Order')` | `filter-id-order` |
| 2 | `Jenis Order` | `Pilih Jenis Order` | Dropdown — enabled (opsi diasumsikan `FTL`/`FCL`/`LTL`/`LCL`) | `getByLabel('Jenis Order')` | `filter-jenis-order` |
| 3 | `Vendor` | `Masukkan Vendor` | Textbox — enabled | `getByLabel('Vendor')` | `filter-vendor` |
| 4 | `Kota Asal` | `Pilih Kota Asal` | Dropdown — enabled | `getByLabel('Kota Asal')` | `filter-kota-asal` |
| 5 | `Kota Tujuan` | `Pilih Kota Tujuan` | Dropdown — enabled | `getByLabel('Kota Tujuan')` | `filter-kota-tujuan` |
| 6 | `Total Harga` | `Masukkan Total Harga` | Textbox — enabled | `getByLabel('Total Harga')` | `filter-total-harga` |
| 7 | `Tipe Pengiriman` | `Pilih Tipe Pengiriman` | Dropdown — **tampak disabled/greyed** (ASM-036) | `getByLabel('Tipe Pengiriman')` → `toBeDisabled()` | `filter-tipe-pengiriman` |
| 8 | `Metode Pengiriman` | `Pilih Metode Pengiriman` | Dropdown — **tampak disabled/greyed** (ASM-036) | `getByLabel('Metode Pengiriman')` | `filter-metode-pengiriman` |
| 9 | `Drop Point Asal` | `Pilih Drop Point Asal` | Dropdown — enabled | `getByLabel('Drop Point Asal')` | `filter-drop-point-asal` |
| 10 | `Drop Point Tujuan` | `Pilih Drop Point Tujuan` | Dropdown — enabled | `getByLabel('Drop Point Tujuan')` | `filter-drop-point-tujuan` |
| 11 | `Status` | `Pilih Status` | Dropdown — enabled (harus memuat 9 status, AC-038.2) | `getByLabel('Status')` | `filter-status` |
| — | `Reset` | — | Button outline **merah** | `getByRole('button', { name: 'Reset' })` | `filter-reset` |
| — | `Terapkan` | — | Button primer | `getByRole('button', { name: 'Terapkan' })` | `filter-apply` |

**Tabel order (dengan baris LTL & LCL)**

| Baris | ID Order | Badge | Rute | Status |
|---|---|---|---|---|
| 1 | `ORD769797FSH` | `FCL` | Kota Surabaya → Kab. Pasuruan | `Isi Data Dasar` |
| 2 | `ORD789871FSF7` | `FCL` | Kota Surabaya → Kota Denpasar | `Isi Data Muatan` |
| 3 | `ORD769797FSH` | `FTL` | Kota Banyuwangi → Kab. Kendal | `Isi Data Vendor` |
| 4 | `ORD789871FSF7` | **`LCL`** | Kota Jakarta Selatan → Kota Singkawang | `Review Order` |
| 5 | `ORD769797FSH` | **`LTL`** | Kota Jakarta Selatan → Kota Padangsidempuan | `Menunggu Penugasan` |
| 6 | `ORD789871FSF7` | `FTL` | Kota Batam → Kab. Tanah Laut | `Ditugaskan` ← *action menu ter-anchor di sini* |
| 7 | `ORD769797FSH` | **`LTL`** | Kota Banyuwangi → Kab. Kendal | `Proses Pengiriman` (tertutup menu) |
| 8 | `ORD789871FSF7` | `FTL` | Kota Banyuwangi → Kab. Kendal | *(tertutup menu)* |
| 9 | `ORD769797FSH` | **`LTL`** | Kota Banyuwangi → Kab. Kendal | *(tertutup menu)* |

**Action menu baris (dropdown)**

| Item | Teks persis | Selector rekomendasi | `data-testid` (hipotesis) |
|---|---|---|---|
| 1 | `Detail` | `getByRole('menuitem', { name: 'Detail' })` | `row-action-detail` |
| 2 | **`Lihat No. Resi`** | `getByRole('menuitem', { name: 'Lihat No. Resi' })` | `row-action-lihat-no-resi` |
| 3 | `Order Kembali` *(tidak ada di spec — ASM-029)* | `getByRole('menuitem', { name: 'Order Kembali' })` | `row-action-order-kembali` |
| 4 | `Batalkan Order` | `getByRole('menuitem', { name: 'Batalkan Order' })` | `row-action-batalkan` |
| 5 | `Riwayat Perubahan` | `getByRole('menuitem', { name: 'Riwayat Perubahan' })` | `row-action-riwayat-perubahan` |

Kontainer menu: `getByRole('menu')` → `row-actions-menu`.

**Temuan penting**

1. **`Lihat No. Resi` terkonfirmasi sebagai label kanonik** (bukan `Lihat No. Perjalanan`) → menguatkan **ASM-017**.
2. Menu **tidak memuat `Edit`** pada baris `Ditugaskan` → mendukung **AC-049.1**; juga tidak memuat `Lanjutkan Pengisian` (khusus draft).
3. Menu ter-*anchor* pada baris **FTL** namun memuat `Lihat No. Resi` → bertentangan dengan REQ-054 (eksklusif LTL/LCL). Diperlakukan sebagai ketidaktepatan mock (**ASM-034**); matriks aksi tetap mengikuti REQ-048/REQ-054.
4. Filter **tidak memiliki** field `Jenis Armada`/`Jumlah Armada`/`Tanggal` — cakupan filter terbatas pada 11 field di atas.

---

### UI-104 — Pop up `Data No. Resi` (**LTL**) & UI-105 — Pop up `Data No. Resi` (**LCL**)

**Konteks:** dialog modal di atas `Daftar Order` (background ter-*dim*, panel Filter terlihat terbuka di belakang). UI-104 dan UI-105 **identik** kecuali badge jenis order.

| Elemen | Teks / Nilai | Tipe / State | Selector rekomendasi | `data-testid` (hipotesis) |
|---|---|---|---|---|
| Dialog | — | `role=dialog`, modal | `getByRole('dialog')` | `dialog-data-no-resi` |
| Judul | `Data No. Resi` | Heading dialog | `getByRole('dialog').getByRole('heading', { name: 'Data No. Resi' })` | `dialog-title` |
| Tutup | ikon `X` | Button ikon (kanan atas) | `getByRole('button', { name: /close|tutup/i })` | `dialog-close` |
| Chip ID Order | `ID Order: ORD-20260607009` | Chip abu read-only | `getByText(/^ID Order: /)` | `resi-id-order` |
| Badge jenis order | **`LTL`** (UI-104, oranye) / **`LCL`** (UI-105, biru) | Badge | `dialog.getByText('LTL', { exact: true })` | `resi-order-type-badge` |
| Header kolom | `No` \| `No. Resi` \| `Kode SKU` ⇅ \| `Nama Barang` ⇅ | Table header (2 kolom **sortable**) | `getByRole('columnheader', { name: /Kode SKU/ })` | `resi-table` |
| Ikon copy | ikon salin (biru) di kiri tiap `No. Resi` | Button ikon per baris | `row.getByRole('button', { name: /salin|copy/i })` | `resi-copy-<no>` |
| Baris data | 7 baris (lihat bawah) | Row | `getByRole('row', { name: /SKU-PPR-001/ })` | `resi-row-<sku>` |

**Isi tabel (identik pada UI-104 & UI-105)**

| No | No. Resi | Kode SKU | Nama Barang |
|---|---|---|---|
| 1 | `LKL7920830903` | `SKU-PPR-001` | `Kertas HVS A4 80 gsm` |
| 2 | `LKL2567828992` | `SKU-PPR-002` | `Kertas HVS F4 70 gsm` |
| 3 | `LKL8900765636` | `SKU-BKU-001` | `Buku Tulis 38 Lembar` |
| 4 | `LKL2567828992` | `SKU-BKU-002` | `Buku Tulis Hard Cover A5` |
| 5 | `LKL8900765636` | `SKU-ATK-001` | `Pulpen Gel Hitam 0.5 mm` |
| 6 | `LKL2567828992` | `SKU-ATK-002` | `Pensil HB` |
| 7 | `LKL8900765636` | `SKU-FIL-001` | `Map Folder Plastik A4` |

**State & catatan**

- Dialog **tanpa footer button** (tanpa `Batal`/`Tutup` berbentuk button) — penutupan hanya via ikon `X` (AC-056.5).
- **Tidak ada paginasi** pada tabel resi.
- Tidak ada state *loading*, *empty*, maupun *toast* "Tersalin" yang tergambar → umpan balik copy tetap asumsi (**ASM-022**).
- No. Resi **berulang** antar baris (`LKL2567828992` di baris 2/4/6; `LKL8900765636` di baris 3/5/7) dan **data LTL = data LCL** dengan `ID Order` yang sama → data dummy (**ASM-030**); jangan meng-assert keunikan resi maupun nilai konkret.
- Prefix resi `LKL…` tergambar untuk **kedua** jenis order → jangan meng-assert prefix berbeda antara LTL dan LCL.

---

### Layar Turunan Tanpa Aset Desain (UI-D01 … UI-D08) — **hipotesis, lihat ASM-032**

> Seluruh elemen berikut **tidak tergambar** pada 10 PNG. Inventaris diturunkan dari `Requirements` + `Validation Rules`. Selector primer memakai `role` + accessible name dari teks yang disebut spec; **semua** `data-testid` bersifat hipotesis dan label wajib diverifikasi ke implementasi.

| ID | Layar/komponen | Elemen kunci (hipotesis) | Selector awal | REQ terkait |
|---|---|---|---|---|
| **UI-D01** | **Modal `Pilih Barang`** *(pembeda inti — aset TIDAK ADA)* | Judul `Pilih Barang`; input pencarian (kode **atau** nama barang); checkbox per baris; badge `Sudah Ditambahkan`; counter `<n> barang terpilih`; button `Batal` & `Simpan`; ikon `X`; empty state hasil pencarian | `getByRole('dialog', { name: 'Pilih Barang' })`; `dialog.getByRole('searchbox')` \| `getByPlaceholder(/Cari/)`; `dialog.getByRole('checkbox')`; `dialog.getByText('Sudah Ditambahkan')`; `dialog.getByText(/barang terpilih/)`; `dialog.getByRole('button', { name: 'Simpan' })` | REQ-013…REQ-018 |
| **UI-D02** | Pop up konfirmasi `Batal` (wizard/Edit) | Dialog konfirmasi + aksi ya/tidak | `getByRole('dialog')` → `getByRole('button', { name: /Ya|Batalkan|Keluar/i })` | AC-012.3, REQ-044 |
| **UI-D03** | Pop up konfirmasi `Simpan ke Draf` / `Simpan` | Dialog konfirmasi + notifikasi sukses (toast) | `getByRole('dialog')`; `getByRole('status')` | ASM-014, AC-044.5/044.6 |
| **UI-D04** | Pop up `Batalkan Order` | Field **`Alasan Pembatalan`** (wajib, textarea) + button konfirmasi + pesan validasi | `getByRole('dialog')`; `getByLabel(/Alasan Pembatalan/)`; `getByText(/harus diisi/)` | REQ-047, V6 |
| **UI-D05** | `Riwayat Pembatalan` (toolbar) | Daftar seluruh order dibatalkan + alasan + empty state | `getByRole('dialog') \| getByRole('heading', { name: 'Riwayat Pembatalan' })` | REQ-050 |
| **UI-D06** | `Riwayat Perubahan` (per baris) | Histori perubahan order terpilih | `getByRole('heading', { name: 'Riwayat Perubahan' })` | REQ-051 |
| **UI-D07** | `Edit Order` | Struktur = wizard, dengan `Jenis Pengiriman` & `Tipe Pengiriman` **locked**; button `Batal` & `Simpan` | `getByRole('heading', { name: /Edit Order/ })`; assertion `toBeDisabled()` pada kartu jenis order | REQ-042, REQ-044 |
| **UI-D08** | `Batch Order` & public tracking | Unggah batch; input `No. Resi` pada halaman tracking publik | `getByRole('button', { name: 'Batch Order' })` | REQ-003, REQ-052 |

---

### Katalog Teks Persis — **tambahan dari desain** (melengkapi V8)

| Teks persis | Jenis | Layar |
|---|---|---|
| `Buat Order` / `Batch Order` / `Riwayat Pembatalan` / `Filter` | Label button toolbar | UI-096, UI-103 |
| `Tampilkan` … `data` | Label kontrol page size | UI-096, UI-103 |
| `Warehouse Asal` / `Warehouse Tujuan` | Sub-label kolom tabel | UI-096, UI-103 |
| `Isi Data Dasar` / `Terkirim` | Badge status *(vs spec `Isi Data Pengiriman` / `Selesai`)* | UI-096, UI-103 |
| `Reset` / `Terapkan` | Button panel filter | UI-103 |
| `Detail` / `Lihat No. Resi` / `Order Kembali` / `Batalkan Order` / `Riwayat Perubahan` | Item action menu | UI-103 |
| `FTL` `Full Truck Load` / `FCL` `Full Container Load` / `LTL` `Less Than Truck Load` / `LCL` `Less Than Container Load` | Label kartu jenis order | UI-097, UI-102 |
| `Pilih Kota Asal` / `Pilih Kota Tujuan` / `Pilih  Drop Point Asal` / `Pilih Drop Point Tujuan` / `Pilih Pengirim` / `Pilih Penerima` | Placeholder dropdown | UI-097, UI-102 |
| `Masukkan PIC Pengirim` / `Masukkan PIC Penerima` / `Masukkan No. WhatsApp PIC` / `Masukkan Catatan` | Placeholder input | UI-097, UI-102 |
| `Jumlah Armada` / `Jumlah Kontainer` (nilai `1`, disabled) | Label field terkunci | UI-097 / UI-102 |
| `Asuransikan Semua` + `Berlaku untuk seluruh barang pada armada ini` | Checkbox + helper | UI-098 |
| `Pisahkan dengan koma untuk menambahkan beberapa nomor` | Helper `Nomor DO` | UI-098 |
| `Nilai Barang harus diisi` | Error inline | UI-098 |
| `Tanpa Asuransi` | Teks nilai | UI-098, UI-099, UI-100, UI-101 |
| `Kubikasi melebihi kapasitas armada` 🚫 | Badge alert (FTL-only) | UI-098 |
| `Total Kubikasi: 19,2 / 17,86 m³` • `Total Berat: 19.200 / 24.800 kg` 🚫 | Ringkasan kapasitas (FTL-only) | UI-098 |
| `Pilih Barang` | Button pembuka modal | UI-098 |
| `Rute belum ada di Master Waktu Perjalanan. Isi waktu perjalanan, nilainya akan otomatis tersimpan sebagai data master baru.` | Alert info | UI-099 |
| `Gunakan komponen harga` | Checkbox | UI-099 |
| `Harga DPP` / `PPN (1,1%)` / `PPh (2%)` / `Asuransi (0,2%)` / `Total Harga` | Baris ringkasan harga | UI-099, UI-100, UI-101 |
| `(Total Nilai Barang = Rp1.006.750.000)` | Catatan kalkulasi asuransi | UI-100, UI-101 |
| `Jam` | Satuan `Waktu Perjalanan` | UI-099 |
| `Batal` / `Sebelumnya` / `Simpan ke Draf` / `Selanjutnya` / `Simpan` | Button wizard | UI-097–UI-100, UI-102 |
| `Edit Order` / `Batalkan Order` | Button header Detail Order | UI-101 |
| `Data No. Resi` / `ID Order: ORD-20260607009` / `No. Resi` | Dialog resi | UI-104, UI-105 |
| `Simulasi Muatan` 🚫 | Item sidebar (FTL-only) | UI-098–UI-101 |

---

### Matriks Cakupan Desain vs Requirement

| REQ | Tergambar? | Aset | Catatan untuk scenario-generator |
|---|---|---|---|
| REQ-001 (LTL & LCL) | ✔ | UI-097, UI-102, UI-103, UI-104, UI-105 | Kartu jenis order + badge daftar + badge dialog resi |
| REQ-002 (stepper 4 step) | ✔ | UI-097…UI-100 | State *active/checked/untouched* terlihat |
| REQ-003 (Batch Order) | ◐ | UI-096, UI-103 | Hanya tombol; layar batch tidak ada |
| REQ-004/013 (Master Barang) | ◐ | UI-098 | Tabel hasil terlihat; **modal `Pilih Barang` TIDAK ADA** |
| REQ-014…018 (modal) | ✘ | — | Seluruhnya hipotesis (UI-D01, ASM-032) |
| REQ-007 (LCL pelabuhan) | ✔ | UI-102 | `Jumlah Kontainer` disabled `1` |
| REQ-008 (LTL kota) | ✔ | UI-097 | `Jumlah Armada` disabled `1` |
| REQ-009 (kota dilepas) | ✘ | — | Perilaku, tidak dapat dibaca dari PNG |
| REQ-010 (tipe Normal, 1 baris) | ✔ | UI-097, UI-102, UI-100 | 1 blok pengirim/penerima; `Tipe Pengiriman : Normal` di review |
| REQ-011 (auto-draft) | ◐ | UI-097, UI-102 | Field wilayah tampil **disabled**; efek pemilihan drop point tidak tergambar |
| REQ-019…023 (tabel barang, DO) | ✔ | UI-098 | Lengkap termasuk chip DO & helper |
| REQ-024 (1 unit) | ◐ | UI-098 ✔ / UI-099, UI-100, UI-101 ✘ | Step 2 sudah 1 grup; Step 3/4/Detail masih 2 armada (carry-over) |
| REQ-025 (tanpa alert kapasitas) | ✘ (kontradiktif) | UI-098 | Desain justru **menampilkan** alert → assertion negatif (ASM-007) |
| REQ-026/027 (hapus & error) | ✔ | UI-098 | Ikon trash + `Nilai Barang harus diisi` |
| REQ-029/030/032 (Step 3) | ✔ | UI-099, UI-100 | Alert master rute + `Asuransi (0,2%)` |
| REQ-031 (LCL tanpa waktu perjalanan) | ✘ | — | Tidak ada aset Step 3 LCL → assertion negatif berbasis spec |
| REQ-034…037 (Review) | ✔ | UI-100 | Termasuk `Simpan` sebagai aksi utama |
| REQ-038 (9 status) | ✔ | UI-096 | Seluruh 9 badge tergambar (2 label berbeda dari spec — ASM-013) |
| REQ-040…044 (Edit) | ◐ | UI-101 | Hanya tombol `Edit Order`; halaman edit tidak ada |
| REQ-045…047 (pembatalan) | ◐ | UI-101, UI-103 | Hanya entry point; pop up `Alasan Pembatalan` tidak ada |
| REQ-048/049 (matriks aksi) | ◐ | UI-103 | Satu varian menu saja (status `Ditugaskan`) |
| REQ-050/051 (riwayat) | ◐ | UI-096, UI-103 | Hanya tombol/menu item |
| REQ-052…057 (No. Resi) | ✔ | UI-103, UI-104, UI-105 | Aksi + dialog + ikon copy |
| REQ-058 (No. Resi di Detail Order) | ✘ | UI-101 | **Tidak tergambar** → ASM-035 |

---

### Konvensi `data-testid` (usulan, hipotesis — ASM-031)

```
<konteks>-<elemen>[-<varian|identitas>]
```

| Konteks | Prefiks | Contoh |
|---|---|---|
| Daftar Order | `order-list-` | `order-list-create`, `order-list-filter-toggle` |
| Baris tabel order | `order-row-` | `order-row-ORD769797FSH`, `order-row-status` |
| Filter | `filter-` | `filter-jenis-order`, `filter-apply` |
| Wizard (global) | `wizard-` | `wizard-next`, `wizard-prev`, `wizard-save-draft`, `wizard-submit` |
| Field form | `field-` | `field-kota-asal`, `field-pelabuhan-tujuan`, `field-nomor-do` |
| Baris barang Step 2 | `row-` + `<sku>` | `row-jumlah-SKU-PPR-001`, `row-delete-SKU-BKU-001` |
| Dialog | `dialog-` | `dialog-data-no-resi`, `dialog-pilih-barang` |
| Detail Order | `detail-` | `detail-edit-order`, `detail-cancel-order` |

> **Aturan pakai:** skenario Playwright **wajib** memakai selector ARIA/label sebagai selector utama; `getByTestId()` hanya sebagai *fallback* opsional agar test tetap lulus bila implementasi belum menambahkan testid.

---

## Assumptions Log

| ID | Area | Ambiguitas / Konflik pada Spec | Keputusan yang Diambil | Dampak / Risiko |
|---|---|---|---|---|
| **ASM-001** | Aset desain vs spec | Sebagian aset desain modul ini jelas merupakan *carry-over* layar FTL/FCL: `099.png`/`100.png`/`101.png` menampilkan `Jenis Pengiriman : FTL (Full Truck Load)`, `Jumlah Armada : 2`, dan rekap dua baris `Armada 1`/`Armada 2` — padahal LTL/LCL hanya memiliki **1 unit muatan**. | Aset desain diperlakukan sebagai referensi **struktur, label, dan teks**, **bukan** referensi kardinalitas/visibilitas. Kardinalitas dan visibilitas mengikuti rule spec (REQ-024). | **Tinggi.** Bila test suite mengambil ekspektasi dari desain, akan menghasilkan skenario multi-armada yang salah untuk LTL/LCL. |
| **ASM-002** | Level asuransi | Konflik internal spec: L25 menyatakan checkbox `Tambahkan Asuransi` **"berlaku untuk seluruh barang pada order tersebut"**, sedangkan *Take Note* pada L33 menyatakan **"asuransi mengikuti tiap jenis barang yang dimasukkan"**. | *Take Note* diperlakukan sebagai **klarifikasi/koreksi terakhir** dan dikuatkan oleh desain `098.png` yang menampilkan **kolom `Asuransi` berisi checkbox per baris barang** + kontrol master **`Asuransikan Semua`** di header. Keputusan: **asuransi bersifat per-barang**, dengan `Asuransikan Semua` sebagai *select-all* (REQ-022). | **Tinggi.** Menentukan struktur seluruh skenario Step 2, Step 3 (komponen Asuransi), dan Step 4. Bila implementasi ternyata all-or-nothing per order, AC-022.4 dan EX-20 perlu direvisi. |
| **ASM-003** | Label checkbox asuransi | Spec menyebut label `"Tambahkan Asuransi"`; desain `098.png` menampilkan **`Asuransikan Semua`**. | Label kanonik ditetapkan **`Asuransikan Semua`** (mengikuti desain, yang lebih spesifik untuk LTL/LCL). Selector memakai matcher toleran: `/(Tambahkan Asuransi\|Asuransikan Semua)/`. | **Sedang.** Berpotensi false-negative bila implementasi memakai label spec. |
| **ASM-004** | Jumlah unit pada Step 1 | Spec L9 menyatakan `Jumlah Kontainer` **"dihilangkan"** untuk LCL, namun desain `102.png` tetap menampilkan field `Jumlah Kontainer` bernilai `1` dalam kondisi *greyed/disabled*. Untuk LTL, spec tidak menyebut `Jumlah Armada` sama sekali, tetapi desain `097.png` menampilkannya bernilai `1` *greyed*. | "Dihilangkan" ditafsirkan sebagai **dihilangkan sebagai input user** — field boleh tetap dirender dalam kondisi **read-only bernilai `1`**. AC ditulis agar lolos untuk kedua implementasi (tidak dirender **atau** read-only `1`), yang diuji adalah **ketidakmampuan user mengubahnya**. | **Sedang.** Assertion berbasis "field tidak ada" akan rapuh; gunakan assertion "tidak dapat diubah". |
| **ASM-005** | Field `Tipe Pengiriman` | Spec L11 menyatakan tipe pengiriman **selalu Normal**, tetapi tidak menyebut apakah dropdown `Tipe Pengiriman` tetap dirender. Desain `097.png` dan `102.png` **tidak** menampilkan dropdown tersebut untuk LTL/LCL. | Diasumsikan dropdown `Tipe Pengiriman` **tidak dirender** pada Step 1 LTL/LCL; nilai `Normal` diset sistem dan tampil sebagai teks read-only pada Step 4/Detail Order. | **Sedang.** Bila dropdown ternyata dirender terkunci, AC-010.4 perlu penyesuaian. |
| **ASM-006** | Validasi asal = tujuan | Spec tidak menyebut apakah `Kota Asal` boleh sama dengan `Kota Tujuan`, atau `Pelabuhan Asal` sama dengan `Pelabuhan Tujuan`. | Diasumsikan **tidak ada blocking validation**; kombinasi identik tetap dapat disimpan. Skenario `edge` disiapkan untuk memverifikasi ada/tidaknya validasi. | Rendah–Sedang. |
| **ASM-007** | Elemen Auto Stuffing pada Step 2 | Desain `098.png` menampilkan **floating button** (ikon *refresh* dan ikon *mata*), **badge `Kubikasi melebihi kapasitas armada`**, dan **ringkasan `Total Kubikasi: 19,2 / 17,86 m³` • `Total Berat: 19.200 / 24.800 kg`** — seluruhnya bertentangan dengan spec L28 yang menyatakan **tidak ada pengecekan/alert kelebihan berat maupun kubikasi**. | **Spec menang.** Elemen alert kapasitas, ringkasan kapasitas berformat `terpakai/kapasitas`, dan floating button hitung-ulang/visualisasi **diperlakukan sebagai elemen yang harus ABSEN** pada Step 2 LTL/LCL (REQ-025). Desain `098.png` dinilai sebagai *carry-over* layar FTL. | **Tinggi.** Ini adalah salah satu assertion negatif utama modul. Bila ternyata elemen tersebut memang ada di implementasi LTL/LCL, REQ-025 dan AC-025.1–025.5 harus dicabut. Wajib dikonfirmasi ke PO. |
| **ASM-008** | Rekap Step 3 | Desain `099.png` menampilkan rekap **dua baris** (`Armada 1`, `Armada 2`), bertentangan dengan rule 1-unit LTL/LCL. | Rekap Step 3 untuk LTL/LCL diasumsikan menampilkan **tepat satu baris unit** (agregat seluruh barang order): `Total Berat`, `Total Kubikasi`, `Total Nilai Barang`. Nilai dihitung dari input Step 2. | **Sedang.** Menjadi dasar AC-024.4. |
| **ASM-009** | Minimum jumlah barang | Spec tidak menyebut apakah order boleh disimpan tanpa satu pun barang. | Diasumsikan **minimal 1 barang** wajib ada pada order sebelum dapat lanjut dari Step 2 (konsekuensi logis dari `Jumlah` yang wajib dan dari fungsi order). | **Sedang.** Menjadi dasar AC-026.4 dan EX-11; wajib dikonfirmasi. |
| **ASM-010** | Counter modal | Spec hanya menyebut "counter jumlah barang terpilih" tanpa format teks maupun perilaku saat nol. | Format teks mengikuti pola pada modul sejenis: `<n> barang terpilih`. Saat nol, counter menampilkan `0 barang terpilih` **atau** tidak dirender — assertion memakai matcher toleran. | Rendah. |
| **ASM-011** | Snapshot data master | Spec tidak menjelaskan apakah data barang pada order merupakan *snapshot* atau *live reference* ke Master Barang. | Diasumsikan **snapshot pada saat barang ditambahkan** — perubahan Master Barang tidak mengubah order yang sudah tersimpan. | **Sedang.** Bila implementasinya live reference, AC-019.4 gagal dan berpotensi mengubah `Total Berat`/`Kubikasi` order historis. |
| **ASM-012** | Persentase asuransi | Spec L38 menyebut "persentase × Total Nilai Barang" tanpa menjelaskan sumber persentase (input user, master vendor, atau konfigurasi sistem). | Diasumsikan persentase berasal dari **konfigurasi/master** (bukan input bebas user pada Step 3), ditampilkan sebagai label `Asuransi (n%)` — konsisten dengan desain `100.png`/`101.png` yang menampilkan `Asuransi (0,2%)` **tanpa** input persen di sampingnya (berbeda dari `PPN`/`PPh` yang punya input). | **Sedang.** Bila persentase ternyata dapat diinput, V5 dan AC-032 perlu tambahan field. |
| **ASM-013** | Penamaan status | Konflik penamaan: spec L48 menulis **`Isi Data Pengiriman`** sedangkan badge desain (`096.png`, `103.png`) menulis **`Isi Data Dasar`**; spec L55 menulis **`Selesai`** sedangkan badge desain menulis **`Terkirim`**. | **Nama pada spec dijadikan kanonik** (`Isi Data Pengiriman`, `Selesai`) karena spec adalah sumber requirement. Untuk assertion UI, digunakan matcher toleran: `/(Isi Data Pengiriman\|Isi Data Dasar)/` dan `/(Selesai\|Terkirim)/`. | **Tinggi.** Penamaan status dipakai lintas skenario (filter, badge, matriks aksi). Wajib dikonfirmasi ke PO agar satu penamaan dipakai konsisten. |
| **ASM-014** | Konfirmasi `Simpan ke Draf` | Spec tidak menyebut adanya pop up konfirmasi untuk `Simpan ke Draf` (hanya untuk `Batal`/`Simpan` pada Edit Order, L65–L66). | Diasumsikan `Simpan ke Draf` **menampilkan pop up konfirmasi**, mengikuti pola modul order sejenis. AC-039.5 ditulis sebagai verifikasi opsional bertoleransi. | Rendah–Sedang. |
| **ASM-015** | Hak edit `Jenis/Jumlah Armada` | Spec L63 menyatakan `Jenis Armada` dan `Jumlah Armada` **tetap dapat diubah** pada Edit Order, namun untuk LTL/LCL kedua field tersebut terkunci/`1` sejak Step 1 (ASM-004). | Rule L63 diperlakukan sebagai **carry-over dari spec FTL/FCL**. Untuk LTL/LCL, field yang benar-benar dapat diubah adalah `Data Pengirim`, `Data Penerima`, `Data Barang`, dan `Vendor & Harga`; `Jenis/Jumlah Armada` tetap mengikuti batasan 1 unit. | **Sedang.** Menghindari skenario edit multi-armada yang tidak relevan. |
| **ASM-016** | Validasi `Alasan Pembatalan` | Spec hanya menyebut "wajib diisi" tanpa panjang minimum/maksimum atau perlakuan whitespace. | Diasumsikan: input hanya spasi diperlakukan sebagai kosong; tidak ada batas panjang eksplisit (batas wajar textarea). | Rendah–Sedang. Menjadi dasar skenario `edge`. |
| **ASM-017** | `Lihat No. Perjalanan` vs `Lihat No. Resi` | Konflik: blok "Aksi pada Daftar Order" L78 menyebut aksi **`Lihat No. Perjalanan`** untuk status `Ditugaskan`, padahal blok "No. Resi" L84 menyatakan No. Resi **hanya untuk LTL & LCL** dan L85 membedakannya dari No. Perjalanan FTL/FCL. Desain `103.png` menampilkan menu aksi berisi **`Lihat No. Resi`**. | L78 diperlakukan sebagai **carry-over dari spec FTL/FCL**. Untuk LTL/LCL, aksi yang benar adalah **`Lihat No. Resi`** (dikuatkan desain `103.png`). Aksi `Lihat No. Perjalanan` **tidak** diharapkan muncul pada order LTL/LCL. | **Tinggi.** Salah pilih label akan menggagalkan seluruh skenario R10. |
| **ASM-018** | Ketersediaan `Lihat No. Resi` pada `Menunggu Penugasan` | Konflik: matriks aksi L77 untuk status `Menunggu Penugasan` **tidak** mencantumkan `Lihat No. Resi`, padahal L85 menyatakan aksi tersebut tampil **"saat status order `Menunggu Penugasan`"**. | Rule L85 (blok khusus No. Resi, lebih spesifik) **diprioritaskan**: `Lihat No. Resi` **ditambahkan** ke matriks aksi untuk status `Menunggu Penugasan` dan seterusnya. | **Sedang–Tinggi.** Menjadi dasar AC-055.1 dan EX-15. |
| **ASM-019** | Aksi pada status `Proses Pengiriman` / `Selesai` / `Dibatalkan` | Spec L76–L78 hanya merinci aksi untuk tiga kelompok status (draft, `Menunggu Penugasan`, `Ditugaskan`). Tiga status sisanya tidak dirinci. | Diasumsikan: `Proses Pengiriman` & `Selesai` → `Detail`, `Riwayat Perubahan`, `Lihat No. Resi` (tanpa `Edit`, tanpa `Batalkan Order` sesuai REQ-041 & REQ-045). `Dibatalkan` → `Detail`, `Riwayat Perubahan`. | **Sedang.** Menjadi dasar skenario negatif REQ-048/REQ-049; wajib dikonfirmasi. |
| **ASM-020** | Parsing `Nomor DO` | Spec menyebut pemisahan dengan koma dan tampilan chip, tanpa aturan trimming/duplikasi/nilai kosong. | Diasumsikan: spasi di sekitar nomor di-*trim*, koma berurutan/berlebih tidak menghasilkan chip kosong, dan nomor duplikat tidak digandakan. | Rendah–Sedang. Menjadi dasar EX-19. |
| **ASM-021** | Regenerasi No. Resi saat Edit | Spec tidak menjelaskan perilaku No. Resi ketika barang ditambah/dihapus melalui `Edit Order` pada status `Menunggu Penugasan`. | Diasumsikan: barang baru **mendapat No. Resi baru**, barang yang dihapus kehilangan entrinya, dan No. Resi barang yang tetap ada **tidak berubah** (stabil). | **Sedang.** Perilaku ini berdampak pada public tracking bila resi berubah diam-diam. |
| **ASM-022** | Umpan balik ikon copy | Spec hanya menyebut "icon copy => dapat menyalin nomor resi", tanpa menyebut notifikasi keberhasilan. | Diasumsikan ada umpan balik visual (toast/tooltip `Tersalin`). AC-057.3 ditulis toleran; verifikasi utama adalah **isi clipboard**. | Rendah. |
| **ASM-023** | Batas panjang & range nilai | Spec **tidak menyebut satu pun** panjang min/maks maupun range nilai. | Ditetapkan aturan wajar: `Jumlah` barang integer > 0; `Nilai Barang` & `Harga` ≥ 0 (currency); `PPN`/`PPh`/`Asuransi` range 0–100%; `No. WhatsApp PIC` 10–15 digit numerik diawali `0`; `Kode Pos` 5 digit; `Waktu Perjalanan` (LTL) minimal 1 jam. | **Sedang.** Seluruh nilai boundary untuk kategori test `edge` bersandar pada asumsi ini. |
| **ASM-024** | `Tanggal Permintaan Muat` | Spec tidak menyebut aturan tanggal. | Diasumsikan tidak boleh di masa lalu relatif terhadap waktu pembuatan order. | Rendah–Sedang. |
| **ASM-025** | Kuota Order | Sidebar desain menampilkan `Kuota Order 120/300`, namun spec tidak menyebutkannya. | Diasumsikan pembuatan order ditolak bila kuota habis; dicatat pada V7 namun **tidak** dijadikan REQ tersendiri karena di luar cakupan spec modul ini. | Rendah. |
| **ASM-026** | Pola pesan validasi | Desain hanya memperlihatkan satu pesan validasi konkret: `Nilai Barang harus diisi` (`098.png`). Pesan untuk `Jumlah` dan untuk Step 1/Step 3 tidak tergambar. | Diasumsikan pola pesan seragam: `<Nama Field> harus diisi` (mis. `Jumlah harus diisi`, `Vendor harus diisi`). Assertion memakai matcher longgar `/harus diisi/` atau memverifikasi **navigasi tertahan** alih-alih teks persis. | **Sedang.** Bila pola berbeda, skenario negatif Step 1/Step 3 perlu penyesuaian teks. |
| **ASM-027** | Helper text asuransi | Helper pada desain `098.png` berbunyi `Berlaku untuk seluruh barang pada armada ini` — menyebut "armada", padahal LTL/LCL tidak mengenal pengelompokan armada. | Diperlakukan sebagai **teks carry-over dari FTL**. Assertion memakai partial match `/Berlaku untuk seluruh barang/` agar tidak rapuh bila teks diperbaiki menjadi "…pada order ini". | Rendah–Sedang. |
| **ASM-028** | Role / aktor | Spec menyebut aktor hanya pada tiga titik (`Shipper`, `admin shipper`, `vendor`) tanpa matriks hak akses. Desain menampilkan badge peran `Staff Operasional` di bawah konteks `Shipper`. | Ditetapkan 5 aktor: **Staff Operasional (Shipper)** sebagai aktor utama, **Admin Shipper** (pemegang hak pembatalan), **Vendor** (penugasan, tanpa hak batal/edit), **Pengirim/Penerima publik** (public tracking saja), dan **Guest** (tanpa akses). | **Sedang.** Skenario autorisasi negatif bersandar pada asumsi ini. |
| **ASM-029** | Aksi `Order Kembali` | Desain `103.png` menampilkan item menu **`Order Kembali`** pada status `Ditugaskan`, yang **sama sekali tidak disebut** pada spec. | **Tidak dijadikan requirement** karena di luar cakupan spec modul ini. Dicatat sebagai temuan agar design-analyzer tidak menjadikannya assertion wajib, dan agar tidak dianggap sebagai *bug* saat elemen tersebut muncul. | Rendah–Sedang. |
| **ASM-030** | Nilai `No. Resi` berulang pada desain | Pada `104.png`/`105.png`, beberapa barang berbeda berbagi No. Resi yang sama (mis. `LKL2567828992` pada baris 2, 4, dan 6). Spec L83 menyatakan resi **melekat pada barang**. | Diperlakukan sebagai **data dummy desain**, bukan rule. Diasumsikan **satu No. Resi per barang** (unik per baris). Assertion tidak menguji keunikan secara ketat sampai dikonfirmasi. | **Sedang.** Bila resi memang dapat dibagi antar barang, AC-053.3 perlu direvisi. |
| **ASM-031** | Selector `data-testid` | Aset desain berupa PNG statis — tidak ada informasi DOM, atribut, maupun accessible name yang sesungguhnya. | Seluruh nilai `data-testid` pada UI Inventory adalah **usulan hipotesis** dengan konvensi `<konteks>-<elemen>[-<varian>]` (kebab-case). Selector primer skenario tetap `getByRole`/`getByLabel`/`getByText`; `data-testid` hanya *fallback* opsional. | **Sedang.** Bila FE memakai konvensi berbeda, seluruh fallback tidak resolve — skenario harus tetap lulus lewat selector ARIA. |
| **ASM-032** | Layar tanpa aset desain | Delapan layar/komponen yang disyaratkan spec **tidak memiliki PNG**: modal `Pilih Barang` (REQ-013…018), pop up konfirmasi `Batal`/`Simpan ke Draf`/`Simpan`, pop up `Batalkan Order` + `Alasan Pembatalan`, `Riwayat Pembatalan`, `Riwayat Perubahan`, `Edit Order`, `Batch Order`, dan public tracking. | Inventaris diturunkan dari spec pada bagian **UI-D01…UI-D08** dengan selector berbasis `role=dialog` + accessible name dari teks spec; seluruhnya ditandai hipotesis. | **Tinggi** khusus modal `Pilih Barang` — pembeda inti modul (REQ-004) justru tidak tergambar. Wajib meminta aset/klarifikasi ke desainer sebelum skenario R3 difinalkan. |
| **ASM-033** | Menu sidebar `Simulasi Muatan` | Item sidebar `Simulasi Muatan` hanya muncul pada `098.png`, `099.png`, `100.png`, `101.png` (aset carry-over FTL) dan **tidak** muncul pada `096.png`, `097.png`, `102.png`, `103.png`. | Diperlakukan sebagai **fitur FTL-only**; tidak dijadikan assertion (positif maupun negatif) pada skenario LTL/LCL. Menguatkan ASM-007 bahwa 098–101 adalah build FTL. | Rendah–Sedang. |
| **ASM-034** | Action menu pada `103.png` | Menu aksi ter-*anchor* pada baris **FTL berstatus `Ditugaskan`**, namun memuat item `Lihat No. Resi` — bertentangan dengan REQ-054 (No. Resi eksklusif LTL/LCL). Menu juga memuat `Order Kembali` (ASM-029). | Diperlakukan sebagai **ketidaktepatan mock** (menu digambar generik). Isi menu dipakai sebagai referensi **label**, bukan referensi **matriks per jenis order**; matriks tetap mengikuti REQ-048/REQ-049/REQ-054. | **Sedang–Tinggi.** Bila diambil mentah, skenario akan salah mengharapkan `Lihat No. Resi` pada order FTL. |
| **ASM-035** | No. Resi pada `Detail Order` | `101.png` (Detail Order, status `Menunggu Penugasan`) **tidak menampilkan** section/field No. Resi, padahal REQ-058/AC-058.1 mensyaratkannya untuk LTL/LCL sejak status tersebut. | Dianggap **gap desain** (aset carry-over FTL yang memang tidak punya No. Resi). Requirement tetap berlaku; skenario REQ-058 ditulis berbasis spec dengan selector generik `getByText(/No\. Resi/)` pada scope halaman dan diberi tag risiko. | **Sedang–Tinggi.** Lokasi/label elemen belum diketahui → skenario berpotensi rapuh sampai desain/implementasi dikonfirmasi. |
| **ASM-036** | Filter `Tipe Pengiriman` & `Metode Pengiriman` | Pada panel Filter (`103.png`), dropdown `Tipe Pengiriman` dan `Metode Pengiriman` dirender **greyed** (placeholder lebih pudar) berbeda dari sembilan filter lainnya. | Diasumsikan keduanya berstatus **disabled / not-applicable** pada konteks OMS LTL–LCL (tipe selalu `Normal`, tanpa metode pengiriman — ASM-003, ASM-005). Assertion memakai `toBeDisabled()` bertoleransi. | Rendah–Sedang. |
| **ASM-037** | Terminologi kolom `Daftar Order` | Tabel daftar memakai header `Kota Asal`/`Kota Tujuan` dengan sub-label `Warehouse Asal`/`Warehouse Tujuan` — termasuk pada baris **LCL** (yang di Step 1 memakai `Pelabuhan Asal/Tujuan`), dan memakai istilah `Warehouse` padahal wizard/Detail Order memakai `Drop Point`. | Diasumsikan header tabel **statis untuk semua jenis order**; nilai kolom untuk LCL diisi kota/drop point, bukan pelabuhan. Assertion memakai header persis `Kota Asal`/`Kota Tujuan`. | **Sedang.** Bila header ternyata dinamis per jenis order, assertion daftar perlu penyesuaian. |
| **ASM-038** | Waktu munculnya error inline | Pada `098.png`, baris 3 memiliki `Jumlah` **kosong tanpa** helper error, sedangkan baris 1 dengan `Nilai Barang` kosong **menampilkan** error `Nilai Barang harus diisi`. | Diasumsikan validasi bersifat **on-submit / on-blur per field**, bukan on-render. Skenario negatif wajib menekan `Selanjutnya` (atau blur field) terlebih dahulu sebelum meng-assert helper error/border error. | **Sedang.** Salah urutan langkah akan membuat skenario EX-02/EX-03 gagal palsu. |
| **ASM-039** | Tombol pada Step 1 | `097.png` dan `102.png` hanya menampilkan `Batal`, `Simpan ke Draf`, dan `Selanjutnya` — **tanpa** `Sebelumnya`. | Ditetapkan: `Sebelumnya` **tidak dirender** pada Step 1; kehadiran `Sebelumnya` hanya diuji pada Step 2–4 (AC-028.1, AC-033.4, AC-037.1). | Rendah. |
| **ASM-040** | Konsistensi angka data dummy | Nominal antar-aset tidak konsisten: (a) `100.png` — Σ `Nilai Barang` per baris = Rp1.445.000 vs catatan `(Total Nilai Barang = Rp1.006.750.000)`; (b) `Total Kubikasi` rekap berbeda antar aset untuk order yang sama (`56,10`/`53,90` di 099, `56,10`/`51,74` di 100, `58,5`/`58,5` di 101); (c) `096.png`/`103.png` — `Menampilkan 1 - 20 data dari 30 data` tetapi paginasi menampilkan 12 halaman; (d) format currency campur (`Rp. 12.000.000` vs `Rp2.013.500`). | Seluruh **nominal pada desain diperlakukan sebagai data dummy**. Skenario menghitung ekspektasi dari input test-nya sendiri (mis. `Total = Σ input`) dan memakai matcher currency toleran `/Rp\.?\s?/`, bukan menyalin angka desain. | **Sedang.** Mencegah kegagalan palsu akibat angka mock. |
