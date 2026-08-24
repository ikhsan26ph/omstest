# Analysis — oms014-order-ftl-fcl-normal

> **Tahap pipeline:** 1/4 — spec-analyzer
> **Sumber spesifikasi:** `inputs/oms014-order-ftl-fcl-normal/spec.txt` (19 baris)
> **Aset desain:** `inputs/oms014-order-ftl-fcl-normal/designs/*.png` (85 file) — dipakai hanya sebagai *grounding* nama field/label; inventarisasi penuh menjadi tugas design-analyzer.

## Ringkasan Modul

Modul **OMS-014** mencakup proses **pengisian data order** pada **Jenis Order FTL (Full Truck Load)** dan **FCL (Full Container Load)** untuk seluruh **tipe pengiriman: Normal, Multipickup, Multidrop, dan Multipoint**, dalam kondisi **add-on Auto Stuffing DINONAKTIFKAN (toggle OFF)**.

Sistem dibangun dengan Auto Stuffing aktif sebagai perilaku default. Sebuah **toggle** disediakan agar *flow* order normal (tanpa Auto Stuffing) tetap dapat diuji/dijalankan. Ketika toggle dimatikan:

- **Step 2 (Data Barang)** menyembunyikan/bypass floating button `Hitung Ulang Armada/Kontainer`, floating button `Visualisasi Terbaru`, panel hitung ulang, dan seluruh logic penempatan/distribusi barang otomatis.
- **Pengisian barang menjadi 100% manual**: user mengisi kuantitas barang per armada/kontainer, dan pada tipe Multipickup/Multidrop/Multipoint juga per **kombinasi alamat** (Pick Up / Drop Off / Pick Up × Drop Off).
- **Step 4 (Review)** dan **Detail Order** tidak menampilkan elemen turunan Auto Stuffing (visualisasi muatan 3D, indikator keterisian/persentase Berat & Ruang Terpakai).
- **Seluruh rule Order FTL & FCL OMS standar tetap berlaku** (wizard 4 step, Master Barang di Step 2, checkbox Tambahkan Asuransi & Nilai Barang, Nomor DO, alert kapasitas informatif, validasi field wajib, No. Perjalanan, Status Order, Hak Edit, Pembatalan, Aksi Daftar Order).
- **Basis komponen tetap sama** antara mode aktif dan nonaktif — perbedaan hanya pada visibilitas elemen dan eksekusi logic.

**Karakter utama modul ini untuk pengujian:** mayoritas requirement bersifat **negatif-visibilitas** (elemen X *tidak boleh* tampil) dan **regresi** (rule standar *tetap* berjalan). Test suite harus menyeimbangkan verifikasi ketiadaan elemen Auto Stuffing dengan verifikasi utuhnya alur order standar.

---

## Requirements

### Legenda

| Kolom | Keterangan |
|---|---|
| **ID** | Identifier requirement, dipakai sebagai tag `@REQ-xxx` di tahap scenario-generator |
| **Sumber** | Baris pada `spec.txt` yang menjadi dasar. `INF` = inferensi (lihat Assumptions Log) |
| **Prioritas** | `high` = inti pembeda modul / blocking; `medium` = rule standar yang harus regresi; `low` = pelengkap |

### R1. Cakupan & Konfigurasi Mode

| ID | Requirement | Sumber | Prioritas |
|---|---|---|---|
| **REQ-001** | Sistem mendukung pengisian data order untuk **Jenis Order FTL dan FCL** pada **empat tipe pengiriman**: Normal, Multipickup, Multidrop, Multipoint — dalam kondisi tanpa Auto Stuffing. | L1 | high |
| **REQ-002** | Sistem dibangun dengan **add-on Auto Stuffing aktif sebagai perilaku default**. | L17 | medium |
| **REQ-003** | Tersedia **toggle Auto Stuffing** yang dapat dimatikan, agar flow order normal (tanpa Auto Stuffing) tetap dapat diuji/dijalankan. | L18 | high |
| **REQ-004** | Saat toggle Auto Stuffing dimatikan, **Step 2 menyembunyikan/bypass** floating button, panel hitung ulang, dan logic penempatan otomatis; **Review & Detail Order** mengikuti kondisi tanpa elemen Auto Stuffing. | L19 | high |
| **REQ-005** | **Basis komponen tetap sama** antara mode Auto Stuffing aktif dan nonaktif — tidak ada perbedaan struktur halaman/komponen selain visibilitas elemen dan eksekusi logic. | L19 | medium |

**Acceptance Criteria**

- **REQ-001**
  - AC-001.1: Pada Step 1, kartu jenis order `FTL` dan `FCL` dapat dipilih dan mengarah ke form Step 1 yang sesuai (FTL → Jenis/Jumlah Armada; FCL → Pelabuhan Asal/Tujuan, Jenis/Jumlah Kontainer, Metode Pengiriman).
  - AC-001.2: Dropdown `Tipe Pengiriman` memuat tepat empat opsi: `Normal`, `Multipickup`, `Multidrop`, `Multipoint`.
  - AC-001.3: Setiap kombinasi (2 jenis order × 4 tipe pengiriman = 8 kombinasi) dapat diselesaikan sampai Step 4 dan disimpan tanpa keterlibatan Auto Stuffing.
- **REQ-002**
  - AC-002.1: Pada instalasi baru tanpa perubahan konfigurasi, nilai toggle Auto Stuffing = `aktif/ON`.
  - AC-002.2: Dengan toggle ON, floating button `Hitung Ulang Armada/Kontainer` dan `Visualisasi Terbaru` tampil di Step 2 (kondisi kontrol/pembanding).
- **REQ-003**
  - AC-003.1: Toggle Auto Stuffing dapat diubah ke `OFF` dan perubahan tersimpan (persist setelah reload halaman).
  - AC-003.2: Setelah toggle OFF, order baru yang dibuat mengikuti seluruh rule modul ini.
  - AC-003.3: Mengubah toggle tidak menyebabkan error/500 dan tidak menghapus data order yang sudah ada.
- **REQ-004**
  - AC-004.1: Dengan toggle OFF, Step 2 tidak merender floating button maupun panel/drawer `Hitung Ulang Armada` / `Hitung Ulang Kontainer`.
  - AC-004.2: Dengan toggle OFF, Step 4 dan Detail Order tidak merender elemen visualisasi/keterisian.
  - AC-004.3: Bypass bersifat menyeluruh — tidak ada jalur alternatif (deep link URL, shortcut keyboard, pemanggilan API dari UI) yang memunculkan panel hitung ulang.
- **REQ-005**
  - AC-005.1: Nama section, urutan section, label field, dan struktur tabel Step 1–Step 4 identik antara mode ON dan OFF.
  - AC-005.2: Perbedaan yang boleh muncul hanya: ketiadaan floating button, ketiadaan panel hitung ulang, ketiadaan visualisasi/indikator keterisian, dan ketiadaan pre-fill hasil distribusi otomatis.

---

### R2. Elemen & Logic yang Dinonaktifkan (Auto Stuffing OFF)

| ID | Requirement | Sumber | Prioritas |
|---|---|---|---|
| **REQ-006** | Floating button **"Hitung Ulang Armada/Kontainer"** pada Step 2 **tidak ditampilkan**. | L4 | high |
| **REQ-007** | Floating button **"Visualisasi Terbaru"** pada Step 2 **tidak ditampilkan**. | L4 | high |
| **REQ-008** | **Logic distribusi/penempatan barang otomatis (Auto Stuffing) antar armada/kontainer tidak berjalan** — sistem tidak memindahkan, membagi, atau mengisi ulang kuantitas barang antar unit. | L5 | high |
| **REQ-009** | **Pembagian barang otomatis antar alamat** pada tipe Multipickup/Multidrop/Multipoint **tidak berjalan**. | L6 | high |
| **REQ-010** | **Pengisian barang per armada/kontainer dilakukan manual oleh user** (pilih barang + isi Jumlah per unit). | L6 | high |
| **REQ-011** | **Pengisian barang per kombinasi alamat dilakukan manual oleh user** (per Pick Up, per Drop Off, atau per pasangan Pick Up × Drop Off sesuai tipe pengiriman). | L6 | high |

**Acceptance Criteria**

- **REQ-006**
  - AC-006.1: Pada Step 2 (semua kombinasi FTL/FCL × 4 tipe pengiriman), tidak terdapat elemen dengan label/aria-label `Hitung Ulang Armada` maupun `Hitung Ulang Kontainer`.
  - AC-006.2: Ikon floating berbentuk *refresh/recalculate* di area kanan-atas Step 2 tidak dirender (baik state collapsed berupa ikon maupun state expanded berlabel).
  - AC-006.3: Modal/drawer `Hitung Ulang Armada` beserta isinya (kartu rekomendasi armada `Paling Efisien`, field `Jenis Armada`/`Jumlah Armada` dengan stepper `−`/`+`, tombol `Terapkan ke Order`) tidak dapat dibuka dari Step 2.
  - AC-006.4: Tidak ada perubahan otomatis pada `Jenis Armada`/`Jumlah Armada` (atau `Jenis Kontainer`/`Jumlah Kontainer`) hasil rekomendasi sistem.
- **REQ-007**
  - AC-007.1: Pada Step 2, tidak terdapat elemen dengan label/aria-label `Visualisasi Terbaru`.
  - AC-007.2: Ikon floating berbentuk *mata (eye)* di area kanan-atas Step 2 tidak dirender.
  - AC-007.3: Panel `Visualisasi Muatan` (tab per Armada/Kontainer, progress `Berat Terpakai` / `Ruang Terpakai`, kanvas 3D, legenda warna barang, badge `n koli melebihi kapasitas (outline merah)`) tidak dapat diakses dari Step 2.
- **REQ-008**
  - AC-008.1: Menambah barang pada Armada/Kontainer 1 tidak mengubah isi tabel barang Armada/Kontainer 2..N.
  - AC-008.2: Mengubah nilai `Jumlah` pada satu baris barang tidak memicu redistribusi ke unit lain; hanya total `Total Kubikasi` / `Total Berat` unit terkait yang ter-update.
  - AC-008.3: Menambah/mengurangi `Jumlah Armada`/`Jumlah Kontainer` di Step 1 lalu kembali ke Step 2 tidak memicu penempatan otomatis; unit baru muncul dalam kondisi **kosong** dengan empty state `Belum ada barang. Klik "Pilih Barang"`.
  - AC-008.4: Tidak ada request/proses kalkulasi penempatan (stuffing) yang dieksekusi saat Step 2 dimuat atau saat data barang berubah.
- **REQ-009**
  - AC-009.1: Pada Multipickup, barang yang diisi di `Pick Up 1` tidak otomatis tersalin/terbagi ke `Pick Up 2..N`.
  - AC-009.2: Pada Multidrop, barang yang diisi di `Drop Off 1` tidak otomatis tersalin/terbagi ke `Drop Off 2..N`.
  - AC-009.3: Pada Multipoint, barang yang diisi di kombinasi `Pick Up 1 – Drop Off 1` tidak otomatis tersalin/terbagi ke kombinasi lain.
  - AC-009.4: Menambah alamat baru (`Tambah Baris Input`) di Step 1 menghasilkan section alamat baru di Step 2 dalam kondisi kosong.
- **REQ-010**
  - AC-010.1: Setiap Armada/Kontainer memiliki tombol `Pilih Barang` sendiri yang membuka modal Master Barang.
  - AC-010.2: Field `Jumlah` per baris barang dapat diisi manual oleh user dan nilainya tersimpan persis seperti yang diinput.
  - AC-010.3: Baris barang dapat dihapus per unit melalui ikon hapus (trash) tanpa mempengaruhi unit lain.
  - AC-010.4: Unit yang dibiarkan kosong tetap dapat direview (alert kapasitas informatif menampilkan `0 / <kapasitas>`), sesuai REQ-016.
- **REQ-011**
  - AC-011.1: **Normal** — Step 2 menampilkan **satu** blok barang per Armada/Kontainer (tanpa sub-section alamat).
  - AC-011.2: **Multipickup** — Step 2 menampilkan sub-section `Pick Up 1..N` **di dalam setiap** Armada/Kontainer, masing-masing dengan `Nomor DO` dan tabel barang sendiri.
  - AC-011.3: **Multidrop** — Step 2 menampilkan sub-section `Drop Off 1..N` **di dalam setiap** Armada/Kontainer, masing-masing dengan `Nomor DO` dan tabel barang sendiri.
  - AC-011.4: **Multipoint** — Step 2 menampilkan sub-section **kombinasi** `Pick Up i – Drop Off j` untuk setiap pasangan alamat di dalam setiap Armada/Kontainer (jumlah sub-section = `jumlah pickup × jumlah dropoff`), masing-masing dengan `Nomor DO` dan tabel barang sendiri.
  - AC-011.5: Judul sub-section menampilkan alamat lengkap alamat terkait (contoh: `Pick Up 1 - Jl. Jambi No.35, Darmo, Wonokromo, Kota Surabaya, Jawa Timur 60241`).

---

### R3. Rule Standar Order FTL & FCL yang Tetap Berlaku

| ID | Requirement | Sumber | Prioritas |
|---|---|---|---|
| **REQ-012** | **Wizard 4 step** tetap berlaku: `01 Data Pengiriman` → `02 Data Barang` → `03 Vendor dan Harga` → `04 Review`. | L9 | high |
| **REQ-013** | **Master Barang di Step 2** tetap berlaku — modal `Pilih Barang` dengan pencarian kode/nama barang dan pemilihan multi-SKU. | L9 | high |
| **REQ-014** | **Checkbox "Tambahkan Asuransi"** (per armada/kontainer) tetap berlaku, dan mengaktifkannya memunculkan kolom **`Nilai Barang`** yang wajib diisi. | L9 | high |
| **REQ-015** | **Nomor DO** tetap berlaku — dapat diisi per armada/kontainer (dan per kombinasi alamat), mendukung beberapa nomor yang dipisahkan koma. | L9 | medium |
| **REQ-016** | **Alert kapasitas bersifat informatif** — melebihi kubikasi/berat kapasitas armada menampilkan peringatan namun **tidak memblokir** user melanjutkan ke step berikutnya. | L9 | high |
| **REQ-017** | **Validasi field wajib** tetap berlaku pada seluruh step; step tidak dapat dilanjutkan bila masih ada field wajib kosong/invalid. | L9 | high |
| **REQ-018** | **No. Perjalanan** tetap berlaku — nomor perjalanan order dapat dilihat (mis. via `Data No. Perjalanan`) beserta identitas unit/kontainer terkait. | L9 | medium |
| **REQ-019** | **Status Order** tetap berlaku — order melalui rangkaian status standar dan status ditampilkan pada Daftar Order & Detail Order. | L9 | medium |
| **REQ-020** | **Hak Edit** tetap berlaku — order hanya dapat diedit pada status yang diizinkan; aksi `Edit`/`Edit Order` tidak tersedia di luar status tersebut. | L9 | high |
| **REQ-021** | **Pembatalan** order tetap berlaku — `Batalkan Order` tersedia pada status yang diizinkan dan mengubah status menjadi `Dibatalkan`. | L9 | medium |
| **REQ-022** | **Aksi Daftar Order** tetap berlaku — `Buat Order`, `Batch Order`, `Riwayat Pembatalan`, `Filter`, serta aksi baris `Detail`, `Lanjutkan Pengisian`, `Edit`, `Batalkan Order`, `Riwayat Perubahan`. | L9 | medium |
| **REQ-023** | Informasi **"Data Unit"** (Jenis & Jumlah Armada/Kontainer) pada Step 2 **tetap tampil bersifat informatif** hasil turunan Step 1, **tanpa mekanisme hitung ulang**. | L10 | high |
| **REQ-024** | **Simpan ke Draf** tetap berlaku pada Step 1–3; order tersimpan sebagai draft dengan status pengisian dan dapat dilanjutkan via aksi `Lanjutkan Pengisian`. | INF | medium |

**Acceptance Criteria**

- **REQ-012**
  - AC-012.1: Stepper menampilkan 4 langkah bernomor `01`–`04` dengan label `Data Pengiriman`, `Data Barang`, `Vendor dan Harga`, `Review`.
  - AC-012.2: Step yang telah diselesaikan berubah menjadi indikator *checked*; step aktif ter-highlight; step belum tersentuh berwarna netral.
  - AC-012.3: Navigasi `Selanjutnya` / `Sebelumnya` berfungsi dan data setiap step dipertahankan saat berpindah bolak-balik.
  - AC-012.4: Tombol `Selanjutnya` pada Step 1 dalam keadaan disabled sampai seluruh field wajib Step 1 terisi.
  - AC-012.5: Pada Step 4 tombol aksi utama adalah `Simpan` (bukan `Selanjutnya`).
- **REQ-013**
  - AC-013.1: Tombol `Pilih Barang` membuka modal berjudul `Pilih Barang` dengan subjudul `Pilih barang yang ingin ditambahkan ke order`.
  - AC-013.2: Modal menyediakan search `Cari kode/nama barang` yang memfilter daftar berdasarkan kode SKU maupun nama barang.
  - AC-013.3: Setiap item menampilkan `Kode SKU - Nama Barang`, `Kemasan`, kubikasi (m³), dan berat (kg).
  - AC-013.4: Barang yang sudah ada di unit tersebut ditandai `Sudah Ditambahkan` dan checkbox-nya dalam keadaan tercentang.
  - AC-013.5: Footer modal menampilkan counter `<n> barang terpilih`; `Simpan` menambahkan barang ke tabel unit terkait; `Batal` menutup modal tanpa perubahan.
  - AC-013.6: Barang yang ditambahkan muncul di tabel dengan kolom `Kode SKU/Nama Barang`, `Kemasan`, `Kubikasi/Dimensi`, `Berat`, `Jumlah` (input), dan aksi hapus.
- **REQ-014**
  - AC-014.1: Checkbox `Tambahkan Asuransi` tersedia di header setiap Armada/Kontainer dengan helper text `Berlaku untuk seluruh barang pada armada ini`.
  - AC-014.2: Saat dicentang, tabel barang unit tersebut menampilkan kolom tambahan `Nilai Barang` (input mata uang `Rp`).
  - AC-014.3: Saat tidak dicentang, kolom `Nilai Barang` tidak ditampilkan pada unit tersebut.
  - AC-014.4: `Nilai Barang` wajib diisi untuk setiap baris barang pada unit yang diasuransikan; kosong memunculkan pesan `Nilai Barang harus diisi`.
  - AC-014.5: Status asuransi ter-carry ke Step 3 (`Total Nilai Barang` = nominal untuk unit diasuransikan, `Tanpa Asuransi` untuk unit tidak diasuransikan), ke Step 4, dan ke Detail Order (badge `Diasuransikan` pada unit terkait).
  - AC-014.6: Komponen biaya `Asuransi (n%)` muncul pada ringkasan harga hanya jika terdapat minimal satu unit diasuransikan.
- **REQ-015**
  - AC-015.1: Field `Nomor DO` tersedia di setiap Armada/Kontainer (Normal) dan di setiap sub-section alamat (Multipickup/Multidrop/Multipoint).
  - AC-015.2: Helper text `Pisahkan dengan koma untuk menambahkan beberapa nomor` ditampilkan.
  - AC-015.3: Input yang dipisahkan koma dirender menjadi beberapa chip/tag terpisah, masing-masing dapat dihapus individual.
  - AC-015.4: `Nomor DO` bersifat opsional — unit tanpa Nomor DO tetap dapat lanjut ke step berikutnya dan ditampilkan sebagai `-` di Detail Order.
  - AC-015.5: Nomor DO tampil apa adanya (dipisah koma) pada Step 4 Review dan Detail Order.
- **REQ-016**
  - AC-016.1: Bila total kubikasi unit melebihi kapasitas, muncul badge peringatan `Kubikasi melebihi kapasitas armada`.
  - AC-016.2: Bila total berat unit melebihi kapasitas, muncul badge peringatan `Berat melebihi kapasitas armada`.
  - AC-016.3: Ringkasan kapasitas ditampilkan sebagai `Total Kubikasi: <terpakai> / <kapasitas> m³` dan `Total Berat: <terpakai> / <kapasitas> kg`.
  - AC-016.4: Meskipun peringatan muncul, tombol `Selanjutnya` **tetap aktif** dan user dapat lanjut ke Step 3 lalu menyimpan order.
  - AC-016.5: Peringatan hilang secara otomatis saat `Jumlah` diturunkan hingga kembali di bawah kapasitas.
- **REQ-017**
  - AC-017.1: Field wajib ditandai asterisk merah (`*`) pada label.
  - AC-017.2: Submit/lanjut dengan field wajib kosong menampilkan pesan validasi inline pada field terkait dan menahan navigasi step.
  - AC-017.3: Pesan validasi Step 2 minimal mencakup `Jumlah harus diisi` dan `Nilai Barang harus diisi`.
  - AC-017.4: Setelah field diperbaiki, pesan validasi hilang dan navigasi step kembali diizinkan.
- **REQ-018**
  - AC-018.1: Modal `Data No. Perjalanan` dapat dibuka dan menampilkan `ID Order` beserta badge jenis order (FTL/FCL).
  - AC-018.2: Setiap baris menampilkan nomor perjalanan (mis. `TRC79289802`) dan identitas unit/kontainer terkait (mis. `TVW67892231 • 40 DRY`).
  - AC-018.3: Nomor perjalanan dapat disalin melalui ikon copy.
  - AC-018.4: Jumlah baris nomor perjalanan konsisten dengan jumlah armada/kontainer pada order.
- **REQ-019**
  - AC-019.1: Kolom `Status` pada Daftar Order menampilkan status order dengan badge berwarna.
  - AC-019.2: Status pengisian bertahap mengikuti step yang sudah/belum diselesaikan (`Isi Data Dasar` → `Isi Data Muatan` → `Isi Data Vendor` → `Review Order`).
  - AC-019.3: Setelah order disimpan lengkap, status berlanjut ke `Menunggu Penugasan` dan selanjutnya `Ditugaskan` → `Proses Pengiriman` → `Terkirim`; pembatalan menghasilkan `Dibatalkan`.
  - AC-019.4: Status yang sama ditampilkan konsisten pada Detail Order.
- **REQ-020**
  - AC-020.1: Aksi `Edit` tersedia pada baris order berstatus `Menunggu Penugasan`.
  - AC-020.2: Aksi `Edit` **tidak** tersedia pada order berstatus `Ditugaskan`, `Proses Pengiriman`, `Terkirim`, dan `Dibatalkan`.
  - AC-020.3: Pada order yang belum lengkap pengisiannya, aksi yang muncul adalah `Lanjutkan Pengisian` (bukan `Edit`).
  - AC-020.4: Halaman `Edit Order` menampilkan seluruh section dalam satu halaman (Jenis Pengiriman dan Rute, Data Pengirim, Data Penerima, Data Barang per unit, Vendor dan Harga) dengan tombol `Batal` dan `Simpan`.
  - AC-020.5: Field identitas order (`ID Order`, `Tanggal Dibuat`, `Jenis Pengiriman`, `Tipe Pengiriman`) bersifat read-only pada Edit Order.
  - AC-020.6: Mengakses URL edit secara langsung untuk order berstatus tidak diizinkan harus ditolak (redirect/pesan error), bukan hanya disembunyikan di UI.
- **REQ-021**
  - AC-021.1: Aksi `Batalkan Order` tersedia pada baris Daftar Order dan sebagai tombol pada Detail Order untuk status yang diizinkan.
  - AC-021.2: Aksi memunculkan konfirmasi sebelum pembatalan dieksekusi.
  - AC-021.3: Setelah dikonfirmasi, status order berubah menjadi `Dibatalkan` dan order tidak lagi dapat di-edit.
  - AC-021.4: Order yang dibatalkan tercatat pada `Riwayat Pembatalan`.
- **REQ-022**
  - AC-022.1: Halaman `Daftar Order` menyediakan tombol `Buat Order`, `Batch Order`, `Riwayat Pembatalan`, dan `Filter`.
  - AC-022.2: Panel `Filter` menyediakan minimal: `ID Order`, `Jenis Order`, `Vendor`, `Kota Asal`, `Kota Tujuan`, `Total Harga`, `Tipe Pengiriman`, `Metode Pengiriman`, `Drop Point Asal`, `Drop Point Tujuan`, `Status`, dengan tombol `Reset` dan `Terapkan`.
  - AC-022.3: Tabel menampilkan kolom `ID Order` (+badge jenis order), `Vendor`, `Kota Asal`/`Warehouse Asal`, `Kota Tujuan`/`Warehouse Tujuan`, `Total Harga`, `Status`.
  - AC-022.4: Kontrol `Tampilkan <n> data`, informasi `Menampilkan x - y data dari z data`, sorting `Total Harga`, dan paginasi berfungsi.
  - AC-022.5: Menu aksi baris (`...`) menampilkan opsi sesuai status: `Detail`, `Lanjutkan Pengisian`/`Edit`, `Batalkan Order`, `Riwayat Perubahan`.
- **REQ-023**
  - AC-023.1: Step 2 menampilkan card `Data Unit` berisi `Jenis Armada` + `Jumlah Armada` (FTL) atau `Jenis Kontainer` + `Jumlah Kontainer` (FCL).
  - AC-023.2: Nilai pada `Data Unit` sama persis dengan yang diinput di Step 1.
  - AC-023.3: `Data Unit` bersifat **read-only** — tidak ada input, dropdown, stepper, maupun tombol aksi di dalamnya.
  - AC-023.4: Tidak ada tombol/link `Hitung Ulang` di dalam maupun di sekitar card `Data Unit`.
  - AC-023.5: Mengubah `Jumlah Armada`/`Jumlah Kontainer` di Step 1 memperbarui `Data Unit` dan jumlah blok unit di Step 2 secara sinkron.
- **REQ-024**
  - AC-024.1: Tombol `Simpan ke Draf` tersedia pada Step 1, Step 2, dan Step 3.
  - AC-024.2: Order draft muncul di Daftar Order dengan status pengisian sesuai step terakhir yang diselesaikan.
  - AC-024.3: Aksi `Lanjutkan Pengisian` membuka wizard pada step yang sesuai dengan seluruh data sebelumnya ter-restore.
  - AC-024.4: Data barang manual per unit/per kombinasi alamat ter-restore persis (tidak ada redistribusi otomatis saat restore).

---

### R4. Efek pada Step 4 (Review) dan Detail Order

| ID | Requirement | Sumber | Prioritas |
|---|---|---|---|
| **REQ-025** | **Step 4 (Review) tidak menampilkan elemen turunan Auto Stuffing** — tidak ada visualisasi muatan maupun indikator keterisian. | L13 | high |
| **REQ-026** | **Step 4 (Review) menampilkan Data Barang apa adanya** sesuai hasil input manual per armada/kontainer (dan per kombinasi alamat). | L13 | high |
| **REQ-027** | **Detail Order mengikuti kondisi yang sama** — tidak menampilkan elemen visualisasi/keterisian hasil Auto Stuffing. | L14 | high |
| **REQ-028** | **Step 3 (Vendor dan Harga)** merekap `Total Berat`, `Total Kubikasi`, dan `Total Nilai Barang` per unit **dari hasil input manual Step 2**, tanpa kalkulasi ulang penempatan. | INF | medium |

**Acceptance Criteria**

- **REQ-025**
  - AC-025.1: Section `Data Barang` pada Step 4 **tidak** memuat tombol `Visualisasi Muatan`.
  - AC-025.2: Step 4 tidak memuat progress bar/persentase `Berat Terpakai` maupun `Ruang Terpakai`.
  - AC-025.3: Step 4 tidak memuat kanvas 3D muatan, legenda warna barang, maupun badge `n koli melebihi kapasitas`.
  - AC-025.4: Section lain pada Step 4 tetap lengkap: `Jenis Pengiriman dan Rute`, `Data Pengirim`, `Data Penerima`, `Data Barang`, `Vendor dan Harga` (termasuk rincian `Harga DPP`, `PPN`, `PPh`, `Asuransi`, `Total Harga`).
- **REQ-026**
  - AC-026.1: Untuk setiap Armada/Kontainer, Step 4 menampilkan `Nomor DO` dan tabel barang berisi persis SKU + `Jumlah` yang diinput user di Step 2.
  - AC-026.2: Tidak ada baris barang tambahan, penggabungan baris, maupun perubahan `Jumlah` dibanding input Step 2.
  - AC-026.3: Unit yang diasuransikan menampilkan badge `Diasuransikan` dan kolom `Nilai Barang`; unit tanpa asuransi tidak menampilkan kolom tersebut.
  - AC-026.4: Untuk Multipickup/Multidrop/Multipoint, Step 4 menampilkan pengelompokan per alamat/kombinasi alamat sesuai struktur input Step 2 (mis. `Kontainer 1` → `Drop Off 1`, `Drop Off 2`).
  - AC-026.5: Unit yang dibiarkan kosong ditampilkan apa adanya sebagai unit tanpa barang (tidak diisi otomatis).
- **REQ-027**
  - AC-027.1: Header Detail Order **tidak** memuat tombol `Visualisasi Muatan`; tombol yang tersisa adalah `Batalkan Order` dan `Edit Order` (sesuai hak status).
  - AC-027.2: Section `Data Barang` pada Detail Order tidak memuat progress bar/persentase keterisian, kanvas 3D, maupun legenda.
  - AC-027.3: Detail Order tetap menampilkan `Jenis Pengiriman dan Rute`, `Data Pengirim`, `Data Penerima`, `Data Barang` per unit, dan `Vendor dan Harga` secara lengkap.
  - AC-027.4: Isi `Data Barang` pada Detail Order identik dengan Step 4 Review pada saat order disimpan.
- **REQ-028**
  - AC-028.1: Tabel rekap Step 3 menampilkan baris per `Armada n` / `Kontainer n` dengan `Total Berat`, `Total Kubikasi`, `Total Nilai Barang`.
  - AC-028.2: `Total Berat` unit = Σ(berat satuan × Jumlah) seluruh baris barang pada unit tersebut (termasuk seluruh sub-section alamat bila multi-alamat).
  - AC-028.3: `Total Kubikasi` unit = Σ(kubikasi satuan × Jumlah) seluruh baris barang pada unit tersebut.
  - AC-028.4: `Total Nilai Barang` menampilkan nominal untuk unit diasuransikan dan `Tanpa Asuransi` untuk unit lainnya.
  - AC-028.5: Nilai rekap ikut berubah bila user kembali ke Step 2 dan mengubah `Jumlah`.

---

### R5. Requirement per Tipe Pengiriman

| ID | Requirement | Sumber | Prioritas |
|---|---|---|---|
| **REQ-029** | **Tipe Normal** — satu alamat asal dan satu alamat tujuan; Step 2 menampilkan satu blok barang per armada/kontainer. | L1, L6 | high |
| **REQ-030** | **Tipe Multipickup** — beberapa alamat asal (Pick Up 1..N) dan satu alamat tujuan; Step 2 menampilkan sub-section per Pick Up di dalam setiap armada/kontainer. | L1, L6 | high |
| **REQ-031** | **Tipe Multidrop** — satu alamat asal dan beberapa alamat tujuan (Drop Off 1..N); Step 2 menampilkan sub-section per Drop Off di dalam setiap armada/kontainer. | L1, L6 | high |
| **REQ-032** | **Tipe Multipoint** — beberapa alamat asal dan beberapa alamat tujuan; Step 2 menampilkan sub-section per **kombinasi** Pick Up × Drop Off di dalam setiap armada/kontainer. | L1, L6 | high |

**Acceptance Criteria**

- **REQ-029**
  - AC-029.1: Step 1 menampilkan tepat satu blok `Data Pengirim` dan satu blok `Data Penerima` (tanpa tombol `Tambah Baris Input`).
  - AC-029.2: Step 2 menampilkan `Armada n` / `Kontainer n` dengan langsung satu `Nomor DO` + satu tabel barang.
  - AC-029.3: Detail Order menampilkan `Tipe Pengiriman : Normal`.
- **REQ-030**
  - AC-030.1: Step 1 menampilkan blok `Data Pengirim` berulang (`Pick Up 1`, `Pick Up 2`, …) dengan tombol `Tambah Baris Input`, dan satu blok `Data Penerima`.
  - AC-030.2: Setiap alamat pickup dapat dihapus kecuali menyisakan minimal 2 alamat pickup.
  - AC-030.3: Step 2 menampilkan sub-section `Pick Up 1..N` di dalam **setiap** armada/kontainer, masing-masing dengan `Nomor DO` + tabel barang terpisah.
  - AC-030.4: Barang antar Pick Up tidak saling terisi otomatis (lihat REQ-009).
  - AC-030.5: Step 3 menyediakan link/aksi untuk melihat rincian alamat multipickup (mis. `Lihat Detail` → modal `Detail Multipickup`).
- **REQ-031**
  - AC-031.1: Step 1 menampilkan satu blok `Data Pengirim` dan blok `Data Penerima` berulang (`Drop Off 1`, `Drop Off 2`, …) dengan tombol `Tambah Baris Input`.
  - AC-031.2: Info alert `Pastikan urutan pengiriman sudah sesuai saat membuat shipment` ditampilkan pada section Data Penerima.
  - AC-031.3: Step 2 menampilkan sub-section `Drop Off 1..N` di dalam **setiap** armada/kontainer, masing-masing dengan `Nomor DO` + tabel barang terpisah.
  - AC-031.4: Step 3 menyediakan modal `Detail Multidrop` yang menampilkan setiap Drop Off beserta nama drop point dan alamat lengkapnya.
  - AC-031.5: Daftar Order menampilkan kota tujuan/warehouse tujuan sesuai konvensi multidrop (tidak error/blank).
- **REQ-032**
  - AC-032.1: Step 1 menampilkan blok `Data Pengirim` berulang **dan** blok `Data Penerima` berulang, keduanya dengan `Tambah Baris Input`.
  - AC-032.2: Step 2 menampilkan sub-section berjudul kombinasi `Pick Up i - <alamat>` + `Drop Off j - <alamat>` untuk setiap pasangan, di dalam setiap armada/kontainer.
  - AC-032.3: Jumlah sub-section per unit = `jumlah Pick Up × jumlah Drop Off`.
  - AC-032.4: Menambah satu alamat baru di Step 1 menambah sub-section kombinasi baru di Step 2 dalam kondisi kosong.
  - AC-032.5: Setiap kombinasi memiliki `Nomor DO` dan tabel barang independen; tidak ada penyalinan otomatis antar kombinasi.

---

### Ringkasan Traceability

| Baris spec | REQ terkait |
|---|---|
| L1 (cakupan) | REQ-001, REQ-029, REQ-030, REQ-031, REQ-032 |
| L4 (floating button) | REQ-006, REQ-007 |
| L5 (distribusi otomatis) | REQ-008 |
| L6 (pembagian antar alamat & pengisian manual) | REQ-009, REQ-010, REQ-011, REQ-029–REQ-032 |
| L9 (rule standar) | REQ-012 s.d. REQ-022 |
| L10 (Data Unit) | REQ-023 |
| L13 (Step 4 Review) | REQ-025, REQ-026 |
| L14 (Detail Order) | REQ-027 |
| L17 (default aktif) | REQ-002 |
| L18 (toggle) | REQ-003 |
| L19 (perilaku toggle off + basis komponen) | REQ-004, REQ-005 |
| Inferensi | REQ-024, REQ-028 |

---

## Validation Rules

### V1. Step 1 — Data Pengiriman (Jenis Pengiriman dan Rute)

| Field | Wajib | Tipe/Format | Aturan | Berlaku pada |
|---|---|---|---|---|
| Jenis Order (FTL / FCL / LTL / LCL) | Ya | Radio card | Tepat satu terpilih. Modul ini mencakup FTL & FCL. | Semua |
| `Jenis Armada` | Ya (*) | Dropdown (master armada) | Harus dipilih dari master; menentukan kapasitas berat & kubikasi per unit. | FTL |
| `Jumlah Armada` | Ya (*) | Integer | Minimal `1`; hanya angka bulat positif; menentukan jumlah blok unit di Step 2. | FTL |
| `Pelabuhan Asal` | Ya (*) | Dropdown | Harus dipilih dari master pelabuhan. | FCL |
| `Pelabuhan Tujuan` | Ya (*) | Dropdown | Harus dipilih dari master pelabuhan; sebaiknya ≠ Pelabuhan Asal. | FCL |
| `Jenis Kontainer` | Ya (*) | Dropdown (mis. `20 DRY`, `40 DRY`) | Harus dipilih dari master; menentukan kapasitas per kontainer. | FCL |
| `Jumlah Kontainer` | Ya (*) | Integer | Minimal `1`; hanya angka bulat positif. | FCL |
| `Tipe Pengiriman` | Ya (*) | Dropdown | Nilai valid: `Normal`, `Multipickup`, `Multidrop`, `Multipoint`. Menentukan struktur alamat & struktur Step 2. | Semua |
| `Metode Pengiriman` | Ya (*) | Radio card | Nilai valid: `Door to Door`, `Door to CY`, `CY to CY`, `CY to Door`. | FCL |

### V2. Step 1 — Data Pengirim / Data Penerima

| Field | Wajib | Tipe/Format | Aturan |
|---|---|---|---|
| `Drop Point Asal` | Ya (*) | Dropdown | Dari master drop point; memicu auto-fill Provinsi/Kota/Kecamatan/Desa/Kode Pos/Alamat Asal. |
| `Pengirim` | Ya (*) | Dropdown | Dari master partner/perusahaan. |
| `PIC Pengirim` | Ya (*) | Text | Nama PIC; helper `Nama PIC Pengirim`. |
| `No. WhatsApp PIC` (pengirim) | Ya (*) | Numerik | Format contoh `081234567898`. Hanya digit; diawali `0`. Panjang wajar 10–15 digit. |
| `Provinsi Asal`, `Kota/Kab. Asal`, `Kecamatan Asal`, `Desa/Kelurahan Asal`, `Kode Pos`, `Alamat Asal` | — | Read-only (auto-fill) | Terisi otomatis dari Drop Point Asal; tidak dapat diedit manual. Kode Pos 5 digit. |
| `Catatan` (pengirim) | Tidak | Textarea | Opsional; ditampilkan `-` bila kosong. |
| `Drop Point Tujuan` | Ya (*) | Dropdown | Dari master drop point; memicu auto-fill data wilayah tujuan. |
| `Penerima` | Ya (*) | Dropdown | Dari master partner/perusahaan. |
| `PIC Penerima` | Ya (*) | Text | Nama PIC penerima. |
| `No. WhatsApp PIC` (penerima) | Ya (*) | Numerik | Format contoh `081234567898`. |
| `Provinsi Tujuan`, `Kota/Kab. Tujuan`, `Kecamatan Tujuan`, `Desa/Kelurahan Tujuan`, `Kode Pos`, `Alamat Tujuan` | — | Read-only (auto-fill) | Terisi otomatis dari Drop Point Tujuan. |
| `Catatan` (penerima) | Tidak | Textarea | Opsional. |
| `Tambah Baris Input` | — | Aksi | Muncul pada sisi pengirim (Multipickup/Multipoint) dan/atau sisi penerima (Multidrop/Multipoint). Minimal 2 alamat pada sisi yang di-multi-kan. |

### V3. Step 2 — Data Barang

| Field / Elemen | Wajib | Tipe/Format | Aturan |
|---|---|---|---|
| `Data Unit` (Jenis & Jumlah Armada/Kontainer) | — | Read-only | Informatif dari Step 1. Tanpa mekanisme hitung ulang (REQ-023). |
| `Tambahkan Asuransi` | Tidak | Checkbox per unit | Default tidak tercentang. Bila dicentang → kolom `Nilai Barang` muncul dan menjadi wajib. |
| `Nomor DO` | Tidak | Text/tag input | Multi-nilai dipisahkan koma → dirender sebagai chip. Opsional; kosong ditampilkan `-`. |
| Baris barang (via `Pilih Barang`) | Ya (minimal 1 per order) | Modal Master Barang | Barang dipilih dari master; tidak bisa input SKU bebas. Duplikat SKU dalam satu unit dicegah (ditandai `Sudah Ditambahkan`). |
| `Jumlah` (per baris barang) | Ya | Integer > 0 | Kosong/`0` → pesan `Jumlah harus diisi`. Hanya angka bulat positif. |
| `Nilai Barang` (per baris barang) | Ya bila unit diasuransikan | Currency (Rp) | Kosong/`0` saat asuransi aktif → pesan `Nilai Barang harus diisi`. Tidak boleh negatif. |
| `Total Kubikasi` | — | Kalkulasi | `Σ(kubikasi satuan × Jumlah)` per unit, ditampilkan `<terpakai> / <kapasitas> m³`. |
| `Total Berat` | — | Kalkulasi | `Σ(berat satuan × Jumlah)` per unit, ditampilkan `<terpakai> / <kapasitas> kg`. |
| Alert kapasitas | — | Badge informatif | `Kubikasi melebihi kapasitas armada` bila kubikasi > kapasitas; `Berat melebihi kapasitas armada` bila berat > kapasitas. **Tidak memblokir** (REQ-016). |
| Empty state unit | — | Teks | `Belum ada barang. Klik "Pilih Barang"`. |

### V4. Step 3 — Vendor dan Harga

| Field | Wajib | Tipe/Format | Aturan |
|---|---|---|---|
| `Vendor` | Ya (*) | Dropdown | Dari master vendor. |
| `Tanggal Permintaan Muat` | Ya (*) | Datetime `DD/MM/YYYY hh:mm` | Format wajib sesuai mask. Tanggal tidak boleh di masa lalu (asumsi). |
| `Waktu Perjalanan` | Ya (*) | Integer, satuan `Jam` | Minimal `1` jam. Bila rute belum ada di master, muncul info: `Rute belum ada di Master Waktu Perjalanan. Isi waktu perjalanan, nilainya akan otomatis tersimpan sebagai data master baru.` |
| `Harga` | Ya (*) | Currency (Rp) | Nilai > 0. Helper `Mencakup seluruh biaya armada pada order ini`. |
| `Gunakan komponen harga` | Tidak | Checkbox | Bila dicentang → menampilkan input `PPN (%)`, `PPh (%)`, dan `Asuransi (%)` bila ada unit diasuransikan. |
| `PPN` | Ya bila komponen harga aktif | Persen (desimal) | Range wajar `0`–`100`. Contoh nilai `1,1`. |
| `PPh` | Ya bila komponen harga aktif | Persen (desimal) | Range wajar `0`–`100`. Contoh nilai `2`. Bersifat pengurang (`- Rp`). |
| `Asuransi` | Kondisional | Persen (desimal) | Contoh `0,2`. Dasar perhitungan = `Total Nilai Barang`. |
| `Simpan data ke master harga` | Tidak | Checkbox | Opsional. |
| `Total Harga` | — | Kalkulasi | `Harga DPP + PPN − PPh + Asuransi`. |

### V5. Aturan Lintas-Step

| Aturan | Detail |
|---|---|
| Navigasi step | `Selanjutnya` disabled/menahan navigasi selama masih ada field wajib kosong pada step aktif (REQ-017). |
| Alert kapasitas non-blocking | Pelanggaran kapasitas **tidak** menghalangi `Selanjutnya`/`Simpan` (REQ-016). |
| Sinkronisasi unit | Perubahan `Jumlah Armada`/`Jumlah Kontainer` di Step 1 menyesuaikan jumlah blok unit di Step 2; unit baru dalam kondisi kosong (REQ-008). |
| Sinkronisasi alamat | Perubahan jumlah alamat di Step 1 menyesuaikan jumlah sub-section alamat/kombinasi di Step 2; sub-section baru dalam kondisi kosong (REQ-009). |
| Konsistensi data | Data pada Step 4 Review dan Detail Order harus identik dengan input Step 2 — tanpa transformasi (REQ-026, REQ-027). |
| Kuota order | Sidebar menampilkan `Kuota Order` (mis. `120/300`, `40%`). Pembuatan order diperkirakan ditolak bila kuota habis (asumsi). |

### V6. Katalog Pesan Validasi & Notifikasi (yang teridentifikasi)

| Pesan | Jenis | Lokasi |
|---|---|---|
| `Jumlah harus diisi` | Error inline | Step 2 — kolom `Jumlah` |
| `Nilai Barang harus diisi` | Error inline | Step 2 — kolom `Nilai Barang` (saat asuransi aktif) |
| `Kubikasi melebihi kapasitas armada` | Warning informatif | Step 2 — footer unit |
| `Berat melebihi kapasitas armada` | Warning informatif | Step 2 — footer unit |
| `Belum ada barang. Klik "Pilih Barang"` | Empty state | Step 2 — tabel barang unit kosong |
| `Rute belum ada di Master Waktu Perjalanan. Isi waktu perjalanan, nilainya akan otomatis tersimpan sebagai data master baru.` | Info | Step 3 |
| `Pastikan urutan pengiriman sudah sesuai saat membuat shipment` | Info | Step 1 — Data Penerima (Multidrop/Multipoint) |
| `Sudah Ditambahkan` | Badge state | Modal `Pilih Barang` |
| `<n> barang terpilih` | Counter | Modal `Pilih Barang` |
| `Menampilkan x - y data dari z data` | Info paginasi | Daftar Order |

---

## Roles & Permissions

> Spesifikasi **tidak** menyebutkan role secara eksplisit. Role di bawah diinferensikan dari konteks aplikasi (header menampilkan konteks `Shipper` dengan badge peran `Staff Operasional`) dan dari kebutuhan operasional modul. Lihat ASM-005 dan ASM-006.

| Role | Konteks | Hak Akses pada Modul OMS-014 |
|---|---|---|
| **Staff Operasional (Shipper)** | Pengguna utama modul | Akses `Daftar Order`; `Buat Order` (wizard 4 step FTL/FCL, semua tipe pengiriman); `Simpan ke Draf`; `Lanjutkan Pengisian`; `Edit Order` (sesuai Hak Edit / status yang diizinkan); `Batalkan Order`; lihat `Detail Order`, `Riwayat Perubahan`, `Riwayat Pembatalan`, `Data No. Perjalanan`; gunakan `Filter`. **Tidak** memiliki akses mengubah toggle Auto Stuffing. |
| **Admin Shipper / Supervisor** | Atasan operasional | Seluruh hak Staff Operasional + persetujuan/override pembatalan dan pengelolaan master (Master Barang, Master Wilayah, Master Operasional, Manajemen Vendor). |
| **System Admin / Super Admin** | Pengelola konfigurasi | Akses menu `Pengaturan Sistem` untuk **mengaktifkan/menonaktifkan toggle add-on Auto Stuffing** (REQ-003). Perubahan toggle berlaku global terhadap Step 2, Step 4, dan Detail Order. |
| **Vendor / Transporter** | Pihak eksternal | *Di luar cakupan modul ini.* Tidak memiliki akses ke wizard pembuatan order OMS. |
| **Guest / Unauthenticated** | — | Tidak memiliki akses; seluruh URL modul harus menolak akses (redirect ke halaman login). |

### Matriks Hak Akses Ringkas

| Aksi | Staff Operasional | Admin Shipper | System Admin | Guest |
|---|:--:|:--:|:--:|:--:|
| Lihat Daftar Order | ✔ | ✔ | ✔ | ✘ |
| Buat Order (wizard 4 step) | ✔ | ✔ | ✔ | ✘ |
| Simpan ke Draf / Lanjutkan Pengisian | ✔ | ✔ | ✔ | ✘ |
| Edit Order (status diizinkan) | ✔ | ✔ | ✔ | ✘ |
| Edit Order (status tidak diizinkan) | ✘ | ✘ | ✘ | ✘ |
| Batalkan Order | ✔ | ✔ | ✔ | ✘ |
| Lihat Detail Order & No. Perjalanan | ✔ | ✔ | ✔ | ✘ |
| Kelola Master (Barang/Wilayah/Vendor) | ✘ | ✔ | ✔ | ✘ |
| Ubah toggle Auto Stuffing | ✘ | ✘ | ✔ | ✘ |

---

## User Flows

### Prasyarat Global (berlaku untuk semua flow)

1. User terautentikasi dengan role yang berwenang (lihat Roles & Permissions).
2. **Toggle add-on Auto Stuffing berada dalam kondisi OFF** (REQ-003) — ini adalah prasyarat pembeda modul OMS-014.
3. Master data tersedia: Drop Point, Partner (Pengirim/Penerima), Armada/Kontainer, Barang (SKU), Vendor, Pelabuhan (untuk FCL).
4. Kuota order masih tersedia.

---

### F1. Flow Utama — Tipe Pengiriman **Normal** (FTL & FCL)

**Step 1 — Data Pengiriman**
1. User membuka `Beranda` → `Daftar Order` → klik `Buat Order`.
2. Sistem menampilkan wizard dengan stepper `01 Data Pengiriman` aktif.
3. User memilih jenis order: `FTL` (atau `FCL`).
4. **FTL:** isi `Jenis Armada`, `Jumlah Armada`.
   **FCL:** isi `Pelabuhan Asal`, `Pelabuhan Tujuan`, `Jenis Kontainer`, `Jumlah Kontainer`, `Metode Pengiriman`.
5. User memilih `Tipe Pengiriman` = **`Normal`**.
6. Sistem menampilkan section `Data Pengirim` (tunggal) dan `Data Penerima` (tunggal).
7. User memilih `Drop Point Asal` → sistem auto-fill Provinsi/Kota/Kecamatan/Desa/Kode Pos/Alamat Asal (read-only).
8. User mengisi `Pengirim`, `PIC Pengirim`, `No. WhatsApp PIC`, dan `Catatan` (opsional).
9. User memilih `Drop Point Tujuan` → sistem auto-fill data wilayah tujuan; user mengisi `Penerima`, `PIC Penerima`, `No. WhatsApp PIC`, `Catatan` (opsional).
10. User klik `Selanjutnya`.

**Step 2 — Data Barang** *(Auto Stuffing OFF)*
11. Sistem menampilkan card **`Data Unit`** read-only berisi `Jenis Armada` + `Jumlah Armada` (atau kontainer) — **tanpa** tombol hitung ulang (REQ-023).
12. **Sistem TIDAK menampilkan** floating button `Hitung Ulang Armada/Kontainer` maupun `Visualisasi Terbaru` (REQ-006, REQ-007).
13. Sistem merender blok `Armada 1..N` (atau `Kontainer 1..N`), **semuanya kosong** — tidak ada pre-fill hasil distribusi otomatis (REQ-008).
14. Untuk **setiap** unit, user:
    a. (Opsional) centang `Tambahkan Asuransi` → kolom `Nilai Barang` muncul.
    b. (Opsional) isi `Nomor DO` (beberapa nomor dipisah koma → menjadi chip).
    c. Klik `Pilih Barang` → modal Master Barang terbuka.
    d. Cari via `Cari kode/nama barang`, centang SKU yang diinginkan, klik `Simpan`.
    e. Isi `Jumlah` **manual** per baris barang (REQ-010).
    f. Isi `Nilai Barang` per baris bila asuransi aktif.
15. Sistem menghitung `Total Kubikasi` dan `Total Berat` per unit dan menampilkan alert kapasitas bila terlampaui — **informatif, tidak memblokir** (REQ-016).
16. User klik `Selanjutnya`.

**Step 3 — Vendor dan Harga**
17. Sistem menampilkan ringkasan rute (`Drop Point Asal`, `Drop Point Tujuan`, `Jenis Armada`) dan tabel rekap per unit (`Total Berat`, `Total Kubikasi`, `Total Nilai Barang`) hasil input manual Step 2 (REQ-028).
18. User memilih `Vendor`, mengisi `Tanggal Permintaan Muat`, `Waktu Perjalanan`, dan `Harga`.
19. (Opsional) User centang `Gunakan komponen harga` → isi `PPN`, `PPh` (+ `Asuransi` bila relevan); sistem menghitung `Total Harga`.
20. User klik `Selanjutnya`.

**Step 4 — Review**
21. Sistem menampilkan seluruh section: `Jenis Pengiriman dan Rute`, `Data Pengirim`, `Data Penerima`, `Data Barang`, `Vendor dan Harga`.
22. **Section `Data Barang` TIDAK menampilkan** tombol `Visualisasi Muatan`, progress `Berat/Ruang Terpakai`, maupun kanvas 3D (REQ-025).
23. Data barang ditampilkan **apa adanya** per armada/kontainer sesuai input manual (REQ-026).
24. User klik `Simpan` → order tersimpan, sistem mengarahkan ke `Daftar Order` dan order muncul dengan status awal.

**Pasca-simpan**
25. User membuka `Detail Order` → seluruh data tampil lengkap **tanpa** tombol/elemen `Visualisasi Muatan` dan indikator keterisian (REQ-027).
26. `No. Perjalanan` dapat dilihat melalui modal `Data No. Perjalanan` (REQ-018).

---

### F2. Flow — Tipe Pengiriman **Multipickup**

Perbedaan terhadap F1:

- **Step 1 (langkah 5–9):** setelah memilih `Tipe Pengiriman` = `Multipickup`, section `Data Pengirim` menjadi **berulang** (`Pick Up 1`, `Pick Up 2`, …) dengan tombol `Tambah Baris Input`. Section `Data Penerima` tetap tunggal. User mengisi seluruh field wajib untuk **setiap** Pick Up.
- **Step 2 (langkah 13–14):** di dalam **setiap** `Armada n` / `Kontainer n`, sistem merender sub-section `Pick Up 1..N` — masing-masing dengan judul beralamat lengkap, `Nomor DO` sendiri, dan tabel barang sendiri.
  Checkbox `Tambahkan Asuransi` tetap berada di **level unit** (berlaku untuk seluruh barang pada unit tersebut).
  User mengisi barang **manual per kombinasi (unit × Pick Up)** — **tidak ada** pembagian otomatis antar alamat (REQ-009, REQ-011).
  Jumlah sub-section per unit = `jumlah Pick Up`.
- **Step 3:** ringkasan rute menampilkan multipickup dengan link `Lihat Detail` → modal `Detail Multipickup` berisi daftar alamat pickup.
- **Step 4 & Detail Order:** `Data Barang` dikelompokkan `Unit` → `Pick Up`, ditampilkan apa adanya, tanpa elemen Auto Stuffing.

---

### F3. Flow — Tipe Pengiriman **Multidrop**

Perbedaan terhadap F1:

- **Step 1:** setelah memilih `Tipe Pengiriman` = `Multidrop`, section `Data Pengirim` tetap tunggal; section `Data Penerima` menjadi **berulang** (`Drop Off 1`, `Drop Off 2`, …) dengan tombol `Tambah Baris Input` dan info alert `Pastikan urutan pengiriman sudah sesuai saat membuat shipment`. User mengisi field wajib untuk **setiap** Drop Off.
- **Step 2:** di dalam **setiap** unit, sistem merender sub-section `Drop Off 1..N` — masing-masing dengan judul beralamat lengkap, `Nomor DO` sendiri, dan tabel barang sendiri. User mengisi barang **manual per kombinasi (unit × Drop Off)**.
  Jumlah sub-section per unit = `jumlah Drop Off`.
- **Step 3:** ringkasan rute menampilkan `Drop Point Tujuan : Multidrop` dengan link `Lihat Detail` → modal `Detail Multidrop` (menampilkan `Drop Off n - <Kota>`, nama drop point, dan alamat lengkap).
- **Step 4 & Detail Order:** `Data Penerima` menampilkan blok `Drop Off 1..N`; `Data Barang` dikelompokkan `Unit` → `Drop Off`, tanpa elemen Auto Stuffing.

---

### F4. Flow — Tipe Pengiriman **Multipoint**

Perbedaan terhadap F1:

- **Step 1:** setelah memilih `Tipe Pengiriman` = `Multipoint`, **kedua** section (`Data Pengirim` dan `Data Penerima`) menjadi berulang, masing-masing dengan `Tambah Baris Input`. User mengisi field wajib untuk setiap Pick Up dan setiap Drop Off.
- **Step 2:** di dalam **setiap** unit, sistem merender sub-section untuk **setiap kombinasi** `Pick Up i – Drop Off j`, dengan header dua kolom (kiri: alamat Pick Up, kanan: alamat Drop Off). Setiap kombinasi memiliki `Nomor DO` dan tabel barang independen.
  Jumlah sub-section per unit = `jumlah Pick Up × jumlah Drop Off` (mis. 2 pickup × 2 dropoff = 4 sub-section per unit).
  User mengisi barang **manual per kombinasi (unit × Pick Up × Drop Off)** — inti dari REQ-011.
- **Step 3:** ringkasan rute menampilkan multipoint dengan link `Lihat Detail`.
- **Step 4 & Detail Order:** `Data Barang` dikelompokkan `Unit` → `Kombinasi Alamat`, tanpa elemen Auto Stuffing.

---

### Flow Alternatif & Percabangan

| Kode | Nama | Langkah |
|---|---|---|
| **ALT-01** | Simpan ke Draf | Pada Step 1/2/3 user klik `Simpan ke Draf` → order tersimpan dengan status pengisian (`Isi Data Dasar` / `Isi Data Muatan` / `Isi Data Vendor`) → muncul di Daftar Order. |
| **ALT-02** | Lanjutkan Pengisian | Dari Daftar Order, menu `...` → `Lanjutkan Pengisian` → wizard terbuka pada step terakhir yang belum selesai dengan seluruh data (termasuk barang manual per unit/alamat) ter-restore utuh. |
| **ALT-03** | Navigasi mundur | User klik `Sebelumnya` dari Step 2/3/4 → kembali ke step sebelumnya dengan data terisi; perubahan `Jumlah Armada` di Step 1 menyesuaikan blok unit di Step 2 (unit baru **kosong**, tidak terisi otomatis). |
| **ALT-04** | Batal buat order | User klik `Batal` di step manapun → konfirmasi → wizard ditutup dan kembali ke `Daftar Order` tanpa menyimpan. |
| **ALT-05** | Edit Order | Dari Daftar Order/Detail Order, aksi `Edit`/`Edit Order` (hanya pada status yang diizinkan) → halaman `Edit Order` satu-halaman berisi seluruh section → ubah data → `Simpan`. |
| **ALT-06** | Batalkan Order | Aksi `Batalkan Order` → dialog konfirmasi → status menjadi `Dibatalkan`, order tercatat di `Riwayat Pembatalan`, aksi Edit tidak lagi tersedia. |
| **ALT-07** | Lihat No. Perjalanan | Dari Daftar Order/Detail Order → modal `Data No. Perjalanan` → daftar nomor perjalanan + identitas unit/kontainer, dengan aksi copy. |
| **ALT-08** | Riwayat Perubahan | Menu `...` → `Riwayat Perubahan` → menampilkan log perubahan order. |
| **ALT-09** | Filter Daftar Order | Klik `Filter` → isi kriteria → `Terapkan` (tabel terfilter) / `Reset` (kriteria dikosongkan). |

### Skenario Percabangan Negatif / Edge (turunan requirement)

| Kode | Kondisi | Ekspektasi |
|---|---|---|
| **EX-01** | Field wajib Step 1 kosong lalu klik `Selanjutnya` | Navigasi ditahan; pesan validasi inline muncul (REQ-017). |
| **EX-02** | `Tambahkan Asuransi` dicentang tetapi `Nilai Barang` kosong | Pesan `Nilai Barang harus diisi`; navigasi ditahan (REQ-014, REQ-017). |
| **EX-03** | Baris barang ada tetapi `Jumlah` kosong | Pesan `Jumlah harus diisi`; navigasi ditahan (REQ-017). |
| **EX-04** | Total kubikasi/berat melebihi kapasitas unit | Badge peringatan muncul namun `Selanjutnya` tetap aktif dan order dapat disimpan (REQ-016). |
| **EX-05** | User menambah barang di Armada 1 | Armada 2..N tetap tidak berubah (REQ-008). |
| **EX-06** | User menaikkan `Jumlah Armada` di Step 1 lalu kembali ke Step 2 | Unit baru muncul **kosong** dengan empty state; tidak ada penempatan otomatis (REQ-008). |
| **EX-07** | User mengisi barang di `Pick Up 1` (Multipickup) | `Pick Up 2..N` tetap kosong (REQ-009). |
| **EX-08** | User membuka Step 2 pada mode Auto Stuffing OFF | Tidak ada floating button dan panel hitung ulang tidak dapat dibuka melalui jalur apa pun (REQ-006, REQ-007, AC-004.3). |
| **EX-09** | User membuka Step 4 / Detail Order pada mode OFF | Tidak ada tombol `Visualisasi Muatan`, progress keterisian, maupun kanvas 3D (REQ-025, REQ-027). |
| **EX-10** | Unit dibiarkan kosong lalu order disimpan | Unit ditampilkan apa adanya tanpa barang di Step 4 & Detail Order; tidak diisi otomatis (REQ-026). |
| **EX-11** | Akses Edit Order pada status tidak diizinkan (langsung via URL) | Ditolak (redirect/pesan error), bukan hanya disembunyikan di UI (REQ-020, AC-020.6). |
| **EX-12** | Toggle Auto Stuffing diubah ke ON saat ada order draft mode OFF | Data barang manual tidak boleh hilang/terdistribusi ulang secara diam-diam (lihat ASM-010). |

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

## Assumptions Log

| ID | Area | Ambiguitas pada Spec | Keputusan yang Diambil | Dampak / Risiko |
|---|---|---|---|---|
| **ASM-001** | Cakupan | Spec baris 1 menulis "Mulripickup" dan "Multipoin" (typo). | Dibaca sebagai **`Multipickup`** dan **`Multipoint`** — konsisten dengan label pada UI dan dengan penyebutan di baris 6 ("Multipickup/Multidrop/Multipoint"). | Rendah. |
| **ASM-002** | Struktur wizard | Spec hanya menyebut "4 step" tanpa merinci nama step. | Nama step ditetapkan: `01 Data Pengiriman`, `02 Data Barang`, `03 Vendor dan Harga`, `04 Review` — di-*ground* dari stepper pada aset desain. | Rendah. Nama step dipakai sebagai `@screen-*` di tahap scenario-generator. |
| **ASM-003** | Nama field & label | Spec tidak mencantumkan satu pun nama field, format, atau panjang min/maks. | Seluruh isi bagian **Validation Rules** diturunkan dari aset desain `inputs/oms014-order-ftl-fcl-normal/designs/*.png` (sampling terarah pada Step 1–4, modal, Detail Order, Edit Order). | **Sedang.** Label harus divalidasi ulang oleh design-analyzer; ketidaksesuaian label akan mempengaruhi selector Playwright. |
| **ASM-004** | Batas panjang/range | Spec sama sekali tidak menyebut panjang min/maks maupun range nilai. | Ditetapkan aturan wajar: `Jumlah Armada`/`Jumlah Kontainer` ≥ 1 (integer); `Jumlah` barang > 0 (integer); `Nilai Barang` dan `Harga` ≥ 0 (currency); `PPN`/`PPh`/`Asuransi` dalam range 0–100%; `No. WhatsApp PIC` 10–15 digit numerik diawali `0`; `Kode Pos` 5 digit. | **Sedang.** Nilai boundary untuk kategori test `edge` bersandar pada asumsi ini. |
| **ASM-005** | Role | Spec tidak menyebut role/aktor sama sekali. | Diinferensikan 3 role internal: **Staff Operasional (Shipper)** sebagai aktor utama (di-*ground* dari badge peran pada header aplikasi), **Admin Shipper/Supervisor**, dan **System Admin**. | **Sedang.** Skenario autorisasi negatif bersandar pada asumsi ini. |
| **ASM-006** | Kepemilikan toggle | Spec menyebut "disediakan toggle" tanpa menyebut siapa yang berhak mengubahnya atau di mana lokasinya. | Toggle ditetapkan sebagai **konfigurasi add-on tingkat sistem** yang hanya dapat diubah oleh **System Admin** melalui menu `Pengaturan Sistem`, dan berlaku **global** (bukan per-order/per-user). | **Sedang.** Bila implementasinya per-order, skenario prasyarat perlu direvisi. |
| **ASM-007** | Level checkbox Asuransi | Spec hanya menyebut "checkbox Tambahkan Asuransi & Nilai Barang" tanpa menyebut cakupannya pada tipe multi-alamat. | Checkbox `Tambahkan Asuransi` berada di **level Armada/Kontainer** (bukan per sub-section alamat) dan berlaku untuk seluruh barang pada unit tersebut — sesuai helper text `Berlaku untuk seluruh barang pada armada ini`. `Nomor DO`, sebaliknya, berada di **level sub-section alamat**. | **Sedang.** Menentukan struktur skenario Multipickup/Multidrop/Multipoint. |
| **ASM-008** | Cakupan alert kapasitas | Spec menyebut "alert kapasitas informatif" tanpa menjelaskan basis agregasinya pada tipe multi-alamat. | Alert dan angka `Total Kubikasi` / `Total Berat` dihitung **agregat per Armada/Kontainer** (bukan per sub-section alamat), meskipun ditampilkan berulang di footer setiap sub-section. | **Sedang.** Bila ternyata per-alamat, ekspektasi angka pada skenario perlu disesuaikan. |
| **ASM-009** | Status Order & Hak Edit | Spec hanya menyebut "Status Order" dan "Hak Edit" tanpa merinci daftar status maupun matriks status→aksi. | Daftar status diturunkan dari desain: `Isi Data Dasar`, `Isi Data Muatan`, `Isi Data Vendor`, `Review Order`, `Menunggu Penugasan`, `Ditugaskan`, `Proses Pengiriman`, `Terkirim`, `Dibatalkan`. Hak Edit diasumsikan aktif pada `Menunggu Penugasan`; status pengisian menggunakan aksi `Lanjutkan Pengisian`; status `Ditugaskan` ke atas tidak dapat diedit. | **Tinggi.** Matriks status→aksi adalah sumber skenario negatif/autorisasi yang banyak; wajib dikonfirmasi ke spec induk Order FTL & FCL OMS standar. |
| **ASM-010** | Peralihan mode toggle | Spec tidak menjelaskan perilaku order yang sudah dibuat ketika toggle diubah. | Diasumsikan perubahan toggle **tidak** mengubah data order yang sudah tersimpan; hanya mempengaruhi rendering/logic pada order yang sedang atau akan dibuat. Skenario EX-12 disiapkan untuk memverifikasi tidak ada kehilangan/redistribusi data. | **Sedang.** Perilaku ini berpotensi menjadi celah data-loss bila implementasi berbeda. |
| **ASM-011** | Draft | Spec tidak menyebut fitur draft, namun "Aksi Daftar Order" mencakup `Lanjutkan Pengisian` pada desain. | Ditambahkan **REQ-024** (Simpan ke Draf / Lanjutkan Pengisian) sebagai bagian dari rule standar yang tetap berlaku, ditandai sumber `INF`. | Rendah–Sedang. Bila di luar cakupan modul, REQ-024 dapat di-*deprioritize*. |
| **ASM-012** | Rekap Step 3 | Spec tidak menyebut Step 3 sama sekali (hanya Step 2 dan Step 4). | Ditambahkan **REQ-028** yang menegaskan rekap Step 3 murni berasal dari input manual Step 2 tanpa kalkulasi penempatan — konsekuensi logis dari REQ-008. | Rendah. |
| **ASM-013** | "Elemen turunan Auto Stuffing" | Spec menyebut "visualisasi muatan/indikator keterisian" secara umum. | Diperinci menjadi daftar elemen konkret yang harus absen: tombol/floating button `Visualisasi Muatan`/`Visualisasi Terbaru`, tombol `Hitung Ulang Armada/Kontainer`, panel `Hitung Ulang`, kartu rekomendasi armada (`Paling Efisien`), progress bar `Berat Terpakai`/`Ruang Terpakai`, kanvas 3D + legenda warna, badge `n koli melebihi kapasitas`. | **Sedang.** Daftar ini menjadi checklist assertion negatif; design-analyzer diharapkan mengonfirmasi/melengkapi. |
| **ASM-014** | Multipoint — struktur Step 2 | Spec hanya menyebut "per kombinasi alamat" tanpa merinci kardinalitas. | Ditetapkan jumlah sub-section per unit = `jumlah Pick Up × jumlah Drop Off` (produk kartesian penuh), di-*ground* dari desain Step 2 multipoint yang menampilkan 4 kombinasi untuk 2 pickup × 2 dropoff. | **Sedang.** Menjadi dasar skenario `stress` (banyak alamat × banyak unit). |
| **ASM-015** | Minimum alamat multi | Spec tidak menyebut batas minimum/maksimum jumlah alamat. | Diasumsikan **minimal 2** alamat pada sisi yang di-multi-kan (pickup untuk Multipickup, dropoff untuk Multidrop, keduanya untuk Multipoint); tidak ada batas maksimum eksplisit. | Rendah–Sedang. Batas atas menjadi area uji `stress`/`edge`. |
| **ASM-016** | Kuota Order | Sidebar desain menampilkan `Kuota Order 120/300`, namun spec tidak menyebutkannya. | Diasumsikan pembuatan order ditolak bila kuota habis; dicatat sebagai aturan lintas-step (V5) namun **tidak** dijadikan REQ tersendiri karena di luar cakupan spec modul ini. | Rendah. |
| **ASM-017** | `Tanggal Permintaan Muat` | Spec tidak menyebut aturan tanggal. | Diasumsikan tidak boleh di masa lalu (relatif terhadap waktu pembuatan order). | Rendah–Sedang. Menjadi dasar skenario `negative`/`edge`. |
| **ASM-018** | Aset desain vs mode OFF | Sebagian besar PNG pada folder `designs/` menampilkan mode Auto Stuffing **aktif** (floating button, panel hitung ulang, `Visualisasi Muatan` tampil). File bersufiks `a` (mis. `031a`, `043a`, `047a`, `057a`) diduga varian. | Aset desain diperlakukan sebagai referensi **struktur dan label** (yang menurut L19 identik antar mode), **bukan** sebagai referensi visibilitas elemen. Visibilitas mengikuti rule spec (REQ-006, REQ-007, REQ-025, REQ-027). | **Tinggi.** Bila design-analyzer menginventarisasi tombol `Hitung Ulang`/`Visualisasi Muatan` sebagai elemen yang harus ada, akan bertentangan dengan requirement modul ini. Requirement (dokumen ini) yang menjadi acuan. |
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
