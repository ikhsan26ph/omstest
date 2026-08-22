# Analysis — oms014-order-ftl-fcl-normal

> Sumber spesifikasi: `inputs/oms014-order-ftl-fcl-normal/spec.txt`
> Spesifikasi baseline (rujukan turunan): `inputs/oms012-order-ftl-auto-stuffing/spec.txt`, `inputs/oms013-order-fcl-auto-stuffing/spec.txt`
> Tahap: 1 — Requirements Extraction
> Tanggal analisis: **2026-08-19**
> Mode: AUTO (keputusan ambigu diambil sendiri dan dicatat di **Assumptions Log**)

---

## Ringkasan Modul

Modul ini menjelaskan **proses pengisian data order pada jenis order FTL & FCL TANPA Auto Stuffing** ("order normal"), untuk seluruh tipe pengiriman: **Normal, Multipickup, Multidrop, dan Multipoint**.

Spesifikasi oms014 bersifat **delta-spec (spesifikasi selisih)**: isinya hanya menyatakan **apa yang dimatikan**, **apa yang tetap berlaku**, dan **efeknya pada Review & Detail Order**. Seluruh perilaku dasar diwarisi dari rule Order FTL & FCL OMS standar (oms012 / oms013) — lihat **ASM-001**.

| Aspek | Perilaku pada oms014 (Auto Stuffing OFF) |
|---|---|
| Jenis order | **FTL** (satuan **Armada**) dan **FCL** (satuan **Kontainer**) — ASM-002 |
| Tipe pengiriman | Normal, Multipickup, Multidrop, Multipoint (keempatnya tercakup) — ASM-003 |
| Wizard | Tetap **4 step**: Data Pengiriman → Data Barang → Vendor & Harga → Review |
| Step 2 — floating button | **Tidak ditampilkan** ("Hitung Ulang Armada/Kontainer" & "Visualisasi Terbaru") |
| Step 2 — distribusi barang | **Manual penuh oleh user** per armada/kontainer & per kombinasi alamat |
| Step 2 — Data Unit | **Tetap tampil** (informatif dari Step 1), **tanpa** mekanisme hitung ulang |
| Step 4 — Review | **Tanpa** visualisasi muatan & indikator keterisian; Data Barang apa adanya |
| Detail Order | **Tanpa** elemen visualisasi/keterisian hasil Auto Stuffing |
| Basis build | Sistem dibangun dengan add-on Auto Stuffing **aktif sebagai default**, disediakan **toggle** untuk mematikannya |
| Basis komponen | **Sama** antara mode aktif & nonaktif (hanya conditional rendering) |

---

## Requirements

Prioritas: **Must** = wajib untuk rilis / blocking; **Should** = penting namun tidak memblokir; **Could** = nice-to-have.

### A. Ruang Lingkup Modul

| ID | Deskripsi | Sumber (baris/section) | Prioritas |
|---|---|---|---|
| REQ-001 | Modul mencakup **proses pengisian data order** untuk tipe pengiriman **Normal, Multipickup, Multidrop, dan Multipoint** pada jenis order **FTL & FCL**, **tanpa Auto Stuffing** di dalamnya. | Baris 1 — Intro | Must |
| REQ-002 | Rule berlaku **untuk kedua jenis order**: **FTL** (satuan **Armada**) dan **FCL** (satuan **Kontainer**); seluruh penyebutan "Armada/Kontainer" dibaca sesuai jenis order yang sedang dibuat. | Baris 1, 4–6 — Intro & Rule Dinonaktifkan | Must |

### B. Elemen yang DINONAKTIFKAN saat Auto Stuffing Mati

| ID | Deskripsi | Sumber (baris/section) | Prioritas |
|---|---|---|---|
| REQ-003 | Floating button **"Hitung Ulang Armada/Kontainer"** pada **Step 2** → **tidak ditampilkan**. | Baris 4 — Dinonaktifkan #1 | Must |
| REQ-004 | Floating button **"Visualisasi Terbaru"** pada **Step 2** → **tidak ditampilkan**. | Baris 4 — Dinonaktifkan #1 | Must |
| REQ-005 | Sebagai turunan REQ-003 & REQ-004: **drawer/panel "Hitung Ulang Armada/Kontainer"** dan **panel "Visualisasi Terbaru"** (beserta isinya: rekomendasi armada, indikator Berat/Ruang Terpakai, label "Paling Efisien", visualisasi 3D, button "Terapkan ke Order") **tidak dapat diakses** dengan cara apa pun. | Baris 4, 19 — Dinonaktifkan #1 & Catatan Build #3 (ASM-006) | Must |
| REQ-006 | **Logic distribusi/penempatan barang otomatis (Auto Stuffing)** antar armada/kontainer → **tidak berjalan**. | Baris 5 — Dinonaktifkan #2 | Must |
| REQ-007 | **Pembagian barang otomatis antar alamat** pada kondisi **Multipickup / Multidrop / Multipoint** → **tidak berjalan** (tidak ada pembagian rata otomatis maupun penempatan sisa ke alamat pertama). | Baris 6 — Dinonaktifkan #3 | Must |
| REQ-008 | **Pengisian barang per armada/kontainer dan per kombinasi alamat dilakukan MANUAL oleh user** — sistem tidak menempatkan/memindahkan barang secara otomatis. | Baris 6 — Dinonaktifkan #3 | Must |

### C. Rule Standar yang TETAP BERLAKU (diwarisi dari Order FTL & FCL OMS)

> Spesifikasi menyatakan: *"Seluruh rule Order FTL & FCL OMS standar tetap dipakai (4 step, Master Barang di Step 2, checkbox Tambahkan Asuransi & Nilai Barang, Nomor DO, alert kapasitas informatif, validasi field wajib, No. Perjalanan, Status Order, Hak Edit, Pembatalan, Aksi Daftar Order)."* — Baris 9. REQ-009 s.d. REQ-028 merupakan **penjabaran eksplisit** rule warisan tersebut (lihat **ASM-001**).

| ID | Deskripsi | Sumber (baris/section) | Prioritas |
|---|---|---|---|
| REQ-009 | Wizard order tetap terdiri dari **4 step**: **Data Pengiriman → Data Barang → Vendor & Harga → Review**. Input **manual maupun batch order** tetap didukung (ASM-024). | Baris 9 — Tetap Berlaku #1 | Must |
| REQ-010 | **Step 1 — Data Pengiriman** identik dengan standar: field **Jenis Armada/Kontainer**, **Jumlah Armada/Kontainer**, **Tipe Pengiriman** (Normal/Multipickup/Multidrop/Multipoint), **Data Pengirim** & **Data Penerima** (auto-draft dari **Master Droppoint**), **rule cascading** & **minimal baris per tipe pengiriman**. Khusus **FCL** tersedia **Pelabuhan Asal** & **Pelabuhan Tujuan**, dan **Metode Pengiriman tidak ditampilkan** (ASM-018). | Baris 9 — Tetap Berlaku #1 | Must |
| REQ-011 | **Step 2 — Data Barang** tetap mengambil barang dari **Master Barang** melalui modal **"Pilih Barang"** (bukan input deskripsi manual), dengan: **pencarian by kode/nama barang**, **multi-select checkbox**, label **"Sudah Ditambahkan"** pada barang yang sudah masuk unit terkait, **counter jumlah barang terpilih**, serta button **Batal** & **Simpan**. | Baris 9 — Tetap Berlaku #1 | Must |
| REQ-012 | Field berikut **auto ter-draft dari Master Barang** dan bersifat **read-only**: **Kode SKU, Nama Barang, Kemasan, Kubikasi, Dimensi, Berat**. | Baris 9 — Tetap Berlaku #1 | Must |
| REQ-013 | Field **Jumlah** diinput user per baris barang dan bersifat **wajib diisi**. | Baris 9 — Tetap Berlaku #1 | Must |
| REQ-014 | Checkbox **"Tambahkan Asuransi"** bersifat **per armada/kontainer** dan berlaku untuk **seluruh barang** pada unit tersebut; saat dicentang kolom **Nilai Barang tampil dan menjadi wajib diisi**. | Baris 9 — Tetap Berlaku #1 | Must |
| REQ-015 | **Nomor DO per armada/kontainer**: **tidak wajib**, dapat diisi **lebih dari satu**, **dipisahkan koma**, dan ditampilkan sebagai **chip**. | Baris 9 — Tetap Berlaku #1 | Must |
| REQ-016 | Setiap baris barang dapat **dihapus** melalui **icon hapus**. | Baris 9 — Tetap Berlaku #1 (turunan Step 2 standar) | Must |
| REQ-017 | **Alert kapasitas armada/kontainer** (Berat dan/atau Kubikasi melebihi kapasitas maksimal) bersifat **informatif** dan **tidak memblokir** proses — user **tetap dapat lanjut** ke step berikutnya. Varian pesan: (a) **"Kubikasi melebihi kapasitas armada/kontainer"**; (b) **"Berat melebihi kapasitas armada/kontainer"**; (c) **"Kubikasi dan Berat melebihi kapasitas armada/kontainer"** (ASM-015). | Baris 9 — Tetap Berlaku #1 | Must |
| REQ-018 | Jika field wajib (**Jumlah**, atau **Nilai Barang** saat asuransi aktif) tidak diisi → tampilkan **helper error** dan **border field berubah warna error**. | Baris 9 — Tetap Berlaku #1 | Must |
| REQ-019 | Informasi **"Data Unit"** (berisi **Jenis Armada/Kontainer** & **Jumlah Armada/Kontainer**) pada **Step 2** **tetap ditampilkan**, bersifat **informatif** dan dibawa dari **Step 1**, **namun tanpa mekanisme hitung ulang**. | Baris 10 — Tetap Berlaku #2 | Must |
| REQ-020 | **Step 3 — Vendor & Harga** tetap standar: **Pilihan Vendor**, **Tanggal Permintaan Muat**, **Harga**, **ringkasan alamat** (label + text link untuk tipe multi), **komponen harga opsional** via checkbox **"Gunakan Komponen Harga"**, serta **Waktu Perjalanan** sesuai jenis order (FTL: textfield bila rute belum ada di master / text-only bila sudah ada; FCL: tanpa input, dihitung `ETA − ETD + 4 hari` dan tampil saat status "Ditugaskan") — ASM-019. | Baris 9 — Tetap Berlaku #1 | Must |
| REQ-021 | Komponen **Asuransi** pada Step 3 mengikuti data Step 2: bila terdapat armada/kontainer yang diasuransikan, nilai **Asuransi = persentase × Total Nilai Barang** dan **turut dihitung ke Total Harga**, di samping **PPN & PPh**. | Baris 9 — Tetap Berlaku #1 | Must |
| REQ-022 | **Validasi field wajib** tetap berlaku pada seluruh step, dan **fungsi button** (**Batal / Simpan ke Draf / Sebelumnya / Selanjutnya / Simpan**) berperilaku identik dengan standar. Aksi **Simpan** pada Step 4 mengubah status menjadi **"Menunggu Penugasan"**. | Baris 9 — Tetap Berlaku #1 | Must |
| REQ-023 | **Status Order** tetap **9 status**: Isi Data Pengiriman, Isi Data Muatan, Isi Data Vendor, Review Order, Menunggu Penugasan, Ditugaskan, Proses Pengiriman, Selesai, Dibatalkan. | Baris 9 — Tetap Berlaku #1 | Must |
| REQ-024 | Status **1–4 (Isi Data Pengiriman s.d. Review Order)** merupakan **kondisi draft**, tersimpan melalui aksi **"Simpan ke Draf"** pada **step manapun**. | Baris 9 — Tetap Berlaku #1 | Must |
| REQ-025 | **Hak Edit**: shipper dapat mengubah data order selama status berada pada rentang **draft s.d. "Menunggu Penugasan"**, dan **tidak dapat lagi** mengubah setelah status **"Ditugaskan"**. | Baris 9 — Tetap Berlaku #1 | Must |
| REQ-026 | Pada halaman **Edit Order**, field **Jenis Pengiriman** & **Tipe Pengiriman** bersifat **locked/read-only**; field **Jenis & Jumlah Armada/Kontainer, Data Pengirim, Data Penerima, Data Barang, Vendor & Harga** tetap dapat diubah. Button **Batal** dan **Simpan** masing-masing menampilkan **pop up konfirmasi**. | Baris 9 — Tetap Berlaku #1 | Must |
| REQ-027 | **Pembatalan Order** tetap berlaku: dapat dibatalkan pada rentang **draft s.d. "Ditugaskan"** (tidak setelah "Proses Pengiriman"), **hanya oleh admin shipper** (bukan vendor), dan field **"Alasan Pembatalan" wajib diisi**. | Baris 9 — Tetap Berlaku #1 | Must |
| REQ-028 | **Aksi pada Daftar Order** menyesuaikan status: draft/Review Order → *Detail, Lanjutkan Pengisian, Batalkan Order, Riwayat Perubahan*; Menunggu Penugasan → *Detail, Edit, Batalkan Order, Riwayat Perubahan*; Ditugaskan → *Detail, Batalkan Order, Riwayat Perubahan, Lihat No. Perjalanan* (**Edit tidak tersedia**). Toolbar menyediakan **"Riwayat Pembatalan"**. **No. Perjalanan** tetap di-generate otomatis per armada/kontainer, hanya untuk **FTL & FCL**, tampil setelah status **"Ditugaskan"** melalui pop up **"Data No. Perjalanan"** (dengan **icon copy**) dan pada **Detail Order**. | Baris 9 — Tetap Berlaku #1 | Must |

### D. Efek pada Step 4 (Review) & Detail Order

| ID | Deskripsi | Sumber (baris/section) | Prioritas |
|---|---|---|---|
| REQ-029 | **Step 4 (Review)** **tidak menampilkan elemen turunan Auto Stuffing**, yaitu **visualisasi muatan** dan **indikator keterisian** (termasuk button pemicu pop up visualisasi pada card Data Barang) — ASM-021. | Baris 13 — Efek Review & Detail #1 | Must |
| REQ-030 | Pada Step 4, **Data Barang ditampilkan apa adanya** sesuai **hasil input manual per armada/kontainer** — tanpa reorganisasi/penempatan ulang oleh sistem. | Baris 13 — Efek Review & Detail #1 | Must |
| REQ-031 | **Detail Order** mengikuti kondisi yang sama: **tidak menampilkan elemen visualisasi/keterisian** hasil Auto Stuffing. | Baris 14 — Efek Review & Detail #2 | Must |
| REQ-032 | Selain penghilangan elemen Auto Stuffing, **struktur Data Barang pada Review tetap mengikuti Step 2** (Kode SKU, Nama Barang, Kemasan, Kubikasi/Dimensi, Berat, Jumlah, Nilai Barang untuk unit yang diasuransikan, serta label **"Diasuransikan"** per unit), dan seluruh data Step 1–3 tetap tampil **read-only**. | Baris 9, 13 — Tetap Berlaku #1 + Efek Review #1 (ASM-022) | Must |

### E. Catatan Build & Toggle Auto Stuffing

| ID | Deskripsi | Sumber (baris/section) | Prioritas |
|---|---|---|---|
| REQ-033 | Sistem **dibangun dalam kondisi add-on Auto Stuffing sudah aktif** sebagai **perilaku default**. | Baris 17 — Catatan Build #1 | Must |
| REQ-034 | Disediakan **toggle untuk mematikan Auto Stuffing**, dengan tujuan agar **flow normal order (tanpa Auto Stuffing) tetap dapat diuji/dijalankan**. | Baris 18 — Catatan Build #2 | Must |
| REQ-035 | Saat **toggle dimatikan**, **Step 2** **menyembunyikan/bypass**: **floating button**, **panel hitung ulang**, dan **logic penempatan otomatis**. | Baris 19 — Catatan Build #3 | Must |
| REQ-036 | Saat **toggle dimatikan**, **Review** dan **Detail Order** mengikuti kondisi **tanpa elemen Auto Stuffing** (sesuai REQ-029 s.d. REQ-031). | Baris 19 — Catatan Build #3 | Must |
| REQ-037 | **Basis komponen tetap sama** antara mode Auto Stuffing **aktif** dan **nonaktif** (perbedaan hanya pada conditional rendering, bukan komponen/halaman terpisah) — tidak boleh menimbulkan pergeseran layout/ruang kosong (ASM-023). | Baris 19 — Catatan Build #3 | Should |

**Total: 37 requirement.**

---

## Validation Rules

### 1. Field-level — Step 1 (Data Pengiriman)

| Field | Tipe Input | Wajib | Format / Aturan | Range / Batasan | Pesan Error / Catatan |
|---|---|---|---|---|---|
| Jenis Pengiriman | Dropdown / preset | Ya | Nilai relevan modul: **FTL** atau **FCL** | 2 opsi relevan | Locked saat Edit Order (REQ-026) |
| Tipe Pengiriman | Radio / Dropdown | Ya | `Normal` \| `Multipickup` \| `Multidrop` \| `Multipoint` | 4 opsi | Locked saat Edit Order (REQ-026) |
| Jenis Armada (FTL) | Read-only field + modal "Pilih Jenis Armada" | Ya | Dipilih dari master Armada | — | Menentukan kapasitas berat & kubikasi pembanding alert (REQ-017) |
| Jenis Kontainer (FCL) | Read-only field + modal "Pilih Jenis Kontainer" | Ya | Dipilih dari master Kontainer | — | Menentukan kapasitas pembanding alert (REQ-017) |
| Jumlah Armada/Kontainer | Number / stepper | Ya | Bilangan bulat positif | **≥ 1** (ASM-010) | Menentukan jumlah card Data Barang Step 2 & jumlah No. Perjalanan (REQ-028) |
| Pelabuhan Asal (FCL) | Dropdown / autocomplete | Ya | Dari master Pelabuhan | Harus ≠ Pelabuhan Tujuan (ASM-018) | Hanya untuk FCL |
| Pelabuhan Tujuan (FCL) | Dropdown / autocomplete | Ya | Dari master Pelabuhan | — | Hanya untuk FCL |
| Data Pengirim (alamat) | Baris alamat dari Master Droppoint | Ya | Auto-draft dari **Master Droppoint** | Normal: 1; **Multipickup/Multipoint: ≥ 2** (ASM-007) | Cascading wilayah (REQ-010) |
| Data Penerima (alamat) | Baris alamat dari Master Droppoint | Ya | Auto-draft dari **Master Droppoint** | Normal: 1; **Multidrop/Multipoint: ≥ 2** (ASM-007) | Cascading wilayah (REQ-010) |
| ~~Metode Pengiriman~~ (FCL) | — | — | **Tidak ditampilkan pada OMS** | — | Kehadiran field pada FCL = cacat (ASM-018) |

### 2. Field-level — Step 2 (Data Barang)

| Field | Tipe Input | Wajib | Format / Aturan | Range / Batasan | Pesan Error / Catatan |
|---|---|---|---|---|---|
| Kode SKU | Text (read-only) | — | Dari Master Barang | — | Tidak dapat diedit (REQ-012) |
| Nama Barang | Text (read-only) | — | Dari Master Barang | — | Tidak dapat diedit |
| Kemasan | Text (read-only) | — | Dari Master Barang | — | Tidak dapat diedit |
| Kubikasi | Number (read-only) | — | Satuan **m³** | — | Dari Master Barang |
| Dimensi | Text (read-only) | — | `P × L × T` satuan **cm** | — | Dari Master Barang |
| Berat | Number (read-only) | — | Satuan **kg** | — | Dari Master Barang |
| **Jumlah** | Number / stepper | **Ya** | Bilangan **bulat positif** | **≥ 1** (ASM-008) | Helper error + border error bila kosong (REQ-013, REQ-018); teks generik "Wajib diisi" (ASM-029) |
| **Nilai Barang** | Number (currency) | **Ya — kondisional** | Muncul & wajib **hanya** saat "Tambahkan Asuransi" pada unit dicentang | **> 0** (ASM-009) | Tersembunyi & tidak divalidasi saat asuransi non-aktif (REQ-014) |
| Tambahkan Asuransi | Checkbox (per armada/kontainer) | Tidak | Boolean, berlaku untuk seluruh barang pada unit | — | Default **tidak tercentang** (ASM-012) |
| Nomor DO | Text (multi-value, chip) | **Tidak** | Multi-nilai **dipisahkan koma**, dirender sebagai **chip** | — | Per armada/kontainer (REQ-015, ASM-028) |
| Data Unit (Jenis & Jumlah Armada/Kontainer) | **Display / read-only** | — | Nilai dibawa dari Step 1 | — | **Informatif saja**, tidak dapat diubah dari Step 2 (REQ-019, ASM-016) |

### 3. Field-level — Step 3 (Vendor & Harga)

| Field | Tipe Input | Wajib | Format / Aturan | Catatan |
|---|---|---|---|---|
| Pilihan Vendor | Dropdown / modal | Ya | Dari master Vendor | REQ-020 |
| Tanggal Permintaan Muat | Date picker | Ya | Format tanggal id-ID; **≥ hari ini** (ASM-011) | REQ-020 |
| Harga | Number (currency) | Ya | ≥ 0 | REQ-020 |
| Waktu Perjalanan (FTL) | Textfield **atau** text-only | Ya (bila textfield) | Textfield bila rute **belum ada** di master; text-only bila **sudah ada** | REQ-020, ASM-019 |
| Waktu Perjalanan (FCL) | **Tidak ada input** | — | Kalkulasi sistem `ETA − ETD + 4 hari` | Tampil pada informasi detail saat status "Ditugaskan" (ASM-019) |
| Ringkasan alamat | Label + text link (tipe multi) | — (read-only) | Text link membuka detail alamat | REQ-020 |
| Gunakan Komponen Harga | Checkbox | Tidak | Boolean | Membuka input komponen harga (REQ-020) |
| Komponen Asuransi | Kalkulasi sistem (read-only) | — | **persentase × Total Nilai Barang** | Hanya bila ada unit diasuransikan (REQ-021) |
| PPN / PPh | Kalkulasi sistem (read-only) | — | Ditambahkan ke Total Harga | REQ-021 |

### 4. Field-level — Pembatalan Order

| Field | Tipe Input | Wajib | Format / Aturan | Catatan |
|---|---|---|---|---|
| Alasan Pembatalan | Textarea / Text | **Ya** | Bebas teks; tidak boleh kosong/whitespace saja (ASM-029) | Submit ditolak bila kosong (REQ-027) |

### 5. Rule-level — Negatif / Absence (spesifik oms014)

> Kelompok ini adalah **inti pengujian modul oms014**: memastikan elemen Auto Stuffing benar-benar **tidak ada**.

| Kode | Aturan | Perilaku bila dilanggar / kondisi |
|---|---|---|
| VAL-01 | Floating button **"Hitung Ulang Armada/Kontainer"** **tidak boleh tampil** pada Step 2 — dalam kondisi apa pun (scroll, hover, jumlah unit berapa pun, ada/tidak ada data barang) | Button tampil (termasuk state disabled) → **cacat** (REQ-003) |
| VAL-02 | Floating button **"Visualisasi Terbaru"** **tidak boleh tampil** pada Step 2 | Button tampil → **cacat** (REQ-004) |
| VAL-03 | **Drawer/panel Hitung Ulang** & **panel Visualisasi Terbaru** tidak dapat dibuka melalui jalur manapun (klik, shortcut, deep-link/URL langsung) | Panel terbuka → **cacat** (REQ-005, ASM-006) |
| VAL-04 | **Logic Auto Stuffing tidak boleh berjalan**: barang yang diinput user pada card unit tertentu **tetap berada** pada unit tersebut | Barang berpindah/terdistribusi otomatis antar unit → **cacat** (REQ-006) |
| VAL-05 | Pada Multipickup/Multidrop/Multipoint, **tidak boleh ada pembagian rata otomatis** antar alamat maupun penempatan sisa ke alamat pertama | Sistem membagi barang otomatis antar alamat → **cacat** (REQ-007) |
| VAL-06 | Pengisian barang per unit & per kombinasi alamat **sepenuhnya manual**; setiap kombinasi harus dapat diisi user secara independen | Kombinasi alamat tidak dapat diisi manual / terkunci → **cacat** (REQ-008) |
| VAL-07 | **Step 4 (Review)** tidak boleh memuat **button visualisasi muatan**, **pop up visualisasi**, maupun **indikator keterisian** | Elemen tampil → **cacat** (REQ-029, ASM-021) |
| VAL-08 | **Detail Order** tidak boleh memuat elemen visualisasi/keterisian Auto Stuffing | Elemen tampil → **cacat** (REQ-031) |
| VAL-09 | Data Barang pada Step 4 & Detail Order harus **identik** dengan hasil input manual Step 2 (unit, alamat, barang, jumlah) | Data berbeda/tereorganisasi → **cacat** (REQ-030) |
| VAL-10 | Penghilangan elemen Auto Stuffing **tidak boleh** menyisakan ruang kosong, layout pecah, atau error console | Layout rusak → **cacat** (REQ-037, ASM-023) |

### 6. Rule-level — Perilaku Standar yang Harus Tetap Ada

| Kode | Aturan | Perilaku bila dilanggar / kondisi |
|---|---|---|
| VAL-11 | Wizard tetap **4 step** dengan urutan Data Pengiriman → Data Barang → Vendor & Harga → Review | Step hilang/berubah urutan → cacat (REQ-009) |
| VAL-12 | Step 2 **tidak menyediakan** input deskripsi barang manual; penambahan **hanya** via modal "Pilih Barang" | Field deskripsi manual muncul → cacat (REQ-011) |
| VAL-13 | Field read-only Step 2 (Kode SKU, Nama Barang, Kemasan, Kubikasi, Dimensi, Berat) tidak boleh editable | Field editable → cacat (REQ-012) |
| VAL-14 | Field **Jumlah** wajib pada setiap baris barang | Helper error + border error; navigasi ke step berikutnya **diblokir** (REQ-013, REQ-018) |
| VAL-15 | Field **Nilai Barang** wajib **hanya** saat "Tambahkan Asuransi" pada unit tercentang | Helper error + border error; saat asuransi non-aktif kolom **tidak tampil** & tidak divalidasi (REQ-014, REQ-018) |
| VAL-16 | Checkbox "Tambahkan Asuransi" berlaku **per armada/kontainer** untuk **seluruh barang** pada unit tersebut | Asuransi diterapkan sebagian barang → cacat (REQ-014) |
| VAL-17 | **Nomor DO tidak wajib**; bila diisi lebih dari satu wajib dipisahkan **koma** dan dirender sebagai **chip** | Nomor DO kosong memblokir Selanjutnya → cacat (REQ-015) |
| VAL-18 | Setiap baris barang dapat dihapus via **icon hapus** dan total kubikasi/berat unit ter-update | Baris tidak terhapus / total tidak update → cacat (REQ-016) |
| VAL-19 | Alert kapasitas bersifat **informatif** — **tidak boleh memblokir** navigasi ke step berikutnya | Tombol Selanjutnya terblokir → cacat (REQ-017) |
| VAL-20 | Pesan alert sesuai kondisi: kubikasi saja / berat saja / keduanya; kata unit menyesuaikan jenis order (**armada** untuk FTL, **kontainer** untuk FCL) | Teks tidak sesuai kondisi/jenis order → cacat (REQ-017, ASM-015) |
| VAL-21 | Kapasitas pembanding alert diambil dari **Jenis Armada/Kontainer** yang dipilih di Step 1 | Memakai kapasitas jenis lain → cacat (REQ-010, REQ-017) |
| VAL-22 | Informasi **"Data Unit"** pada Step 2 **wajib tampil**, konsisten dengan Step 1, dan **read-only** (tanpa mekanisme hitung ulang) | Data Unit hilang / dapat diubah / tidak sinkron dengan Step 1 → cacat (REQ-019) |
| VAL-23 | Nilai **Asuransi** Step 3 = **persentase × Total Nilai Barang**, hanya dihitung bila ada unit diasuransikan; ikut ke Total Harga bersama PPN & PPh | Perhitungan Total Harga salah → cacat (REQ-021) |
| VAL-24 | Waktu Perjalanan mengikuti jenis order (FTL: input/text-only; FCL: tanpa input, `ETA − ETD + 4 hari`) | Perilaku tertukar antar jenis order → cacat (REQ-020, ASM-019) |
| VAL-25 | Step 4 menampilkan seluruh data Step 1–3 secara **read-only**, dengan label **"Diasuransikan"** hanya pada unit yang diasuransikan | Field editable / label salah tempat → cacat (REQ-032) |
| VAL-26 | Aksi **Simpan** pada Step 4 mengubah status menjadi **"Menunggu Penugasan"** | Status tidak berubah → cacat (REQ-022) |
| VAL-27 | Status 1–4 tersimpan sebagai **draft** via "Simpan ke Draf" dari **step manapun** | Draf gagal tersimpan di salah satu step → cacat (REQ-024) |
| VAL-28 | Edit order **diblokir** setelah status "Ditugaskan"; field **Jenis Pengiriman** & **Tipe Pengiriman** locked pada Edit Order | Aksi Edit tersedia/berhasil; field editable → cacat (REQ-025, REQ-026) |
| VAL-29 | Button **Batal** & **Simpan** pada Edit Order wajib memunculkan **pop up konfirmasi** | Aksi langsung dieksekusi → cacat (REQ-026) |
| VAL-30 | Pembatalan diblokir sejak status "Proses Pengiriman"; hanya **admin shipper**; **Alasan Pembatalan wajib** | Aksi tersedia terlambat / vendor dapat membatalkan / submit kosong diterima → cacat (REQ-027) |
| VAL-31 | Daftar aksi per baris harus **persis** sesuai status order | Aksi tambahan/hilang → cacat (REQ-028) |
| VAL-32 | Jumlah **No. Perjalanan** = jumlah armada/kontainer yang dipesan, tiap nomor **unik**, hanya untuk FTL & FCL, dan aksi "Lihat No. Perjalanan" baru tampil pada status **"Ditugaskan"** | Jumlah/keunikan/timing salah → cacat (REQ-028) |

### 7. Rule-level — Toggle Auto Stuffing

| Kode | Aturan | Perilaku bila dilanggar / kondisi |
|---|---|---|
| VAL-33 | Kondisi **default build** = Auto Stuffing **aktif**; mode oms014 tercapai **hanya** setelah toggle dimatikan | Default sudah OFF tanpa toggle → menyimpang dari REQ-033 |
| VAL-34 | Toggle **OFF** → Step 2 menyembunyikan/bypass floating button, panel hitung ulang, dan logic penempatan otomatis **secara serentak** (tidak parsial) | Sebagian elemen masih aktif → cacat (REQ-035) |
| VAL-35 | Toggle **OFF** → Review & Detail Order otomatis mengikuti kondisi tanpa elemen Auto Stuffing | Review/Detail masih menampilkan visualisasi → cacat (REQ-036) |
| VAL-36 | Toggle **ON kembali** → seluruh perilaku Auto Stuffing (oms012/oms013) pulih tanpa perlu deploy ulang | Perilaku tidak pulih → cacat (REQ-034, ASM-005) |
| VAL-37 | **Basis komponen sama** antara mode ON & OFF (tidak ada halaman/route duplikat) | Terdapat halaman terpisah → menyimpang dari REQ-037 |

### 8. Modal "Pilih Barang"

| Kode | Aturan |
|---|---|
| VAL-M1 | Sumber data = **Master Barang** milik shipper/tenant terkait; hanya barang berstatus **Aktif** yang tampil (ASM-014) |
| VAL-M2 | Pencarian berfungsi **by kode barang** dan **by nama barang** (REQ-011) |
| VAL-M3 | Mendukung **multi-select** via checkbox dalam satu kali buka modal (REQ-011) |
| VAL-M4 | Barang yang sudah masuk ke **unit terkait** menampilkan label **"Sudah Ditambahkan"**; label bersifat **informatif** (ASM-013) |
| VAL-M5 | **Counter jumlah barang terpilih** ter-update real-time (REQ-011) |
| VAL-M6 | Button **Batal** menutup modal **tanpa** menambahkan barang; **Simpan** menambahkan seluruh barang terpilih ke unit terkait (REQ-011) |
| VAL-M7 | Modal dibuka **per card armada/kontainer** (dan per kombinasi alamat pada tipe multi) → barang masuk **hanya** ke unit/kombinasi tempat modal dibuka (REQ-008) |

---

## Roles & Actors

> Spesifikasi oms014 **tidak menyebut aktor secara eksplisit**. Aktor berikut diturunkan dari rule warisan (oms012/oms013) yang menyebut **Shipper / Admin Shipper** dan **Vendor**, ditambah aktor pengelola toggle (**ASM-004**).

| Role / Aktor | Buat Order (Step 1–4) | Simpan ke Draf | Edit Order | Batalkan Order | Lihat No. Perjalanan | Penugasan Unit | Kelola Toggle Auto Stuffing |
|---|---|---|---|---|---|---|---|
| **Admin Shipper** (aktor utama) | Ya | Ya | Ya — draft s.d. **Menunggu Penugasan** (REQ-025) | **Ya** — draft s.d. **Ditugaskan** (REQ-027) | Ya (status Ditugaskan) | Tidak | **Tidak** (ASM-004) |
| **Staff Operasional Shipper** | Ya | Ya | Ya (mengikuti REQ-025) | Mengikuti kebijakan tenant (ASM-025) | Ya | Tidak | Tidak |
| **Vendor** | Tidak | Tidak | Tidak | **Tidak** (eksplisit dilarang, REQ-027) | Ya (konteks penugasan) | **Ya** — memicu status "Ditugaskan" (REQ-023) | Tidak |
| **Pengirim / Penerima (publik)** | Tidak | Tidak | Tidak | Tidak | Ya — via **public tracking** dengan No. Perjalanan (REQ-028) | Tidak | Tidak |
| **Admin Sistem / Super Admin (pengelola add-on)** | Tidak | Tidak | Tidak | Tidak | Tidak | Tidak | **Ya** — menyalakan/mematikan add-on Auto Stuffing (REQ-034, ASM-004) |
| **QA / Tester** | Ya (akun uji) | Ya | Ya | Ya | Ya | — | Ya (lingkungan uji) — tujuan eksplisit toggle (REQ-034) |
| **Sistem — Engine Auto Stuffing** | **NONAKTIF pada modul ini** (REQ-006) | — | — | — | — | — | — |
| **Sistem — Generator No. Perjalanan** | — | — | — | — | Meng-generate No. Perjalanan per unit (REQ-028) | — | — |
| **Master Barang** (sumber data) | Menyediakan Kode SKU, Nama Barang, Kemasan, Kubikasi, Dimensi, Berat (REQ-012) | — | — | — | — | — | — |
| **Master Droppoint** (sumber data) | Auto-draft Data Pengirim & Data Penerima (REQ-010) | — | — | — | — | — | — |
| **Master Armada / Master Kontainer** (sumber data) | Menyediakan jenis & kapasitas unit (REQ-010, REQ-017) | — | — | — | — | — | — |
| **Master Pelabuhan** (sumber data, FCL) | Menyediakan opsi Pelabuhan Asal & Tujuan (REQ-010) | — | — | — | — | — | — |

### Matriks Aksi vs Status Order

| Status | Detail | Lanjutkan Pengisian | Edit | Batalkan Order | Riwayat Perubahan | Lihat No. Perjalanan |
|---|---|---|---|---|---|---|
| Isi Data Pengiriman | Ya | Ya | Tidak | Ya | Ya | Tidak |
| Isi Data Muatan | Ya | Ya | Tidak | Ya | Ya | Tidak |
| Isi Data Vendor | Ya | Ya | Tidak | Ya | Ya | Tidak |
| Review Order | Ya | Ya | Tidak | Ya | Ya | Tidak |
| Menunggu Penugasan | Ya | Tidak | **Ya** | Ya | Ya | Tidak |
| Ditugaskan | Ya | Tidak | **Tidak** | Ya | Ya | **Ya** |
| Proses Pengiriman | Ya | Tidak | Tidak | **Tidak** | Ya | Ya |
| Selesai | Ya | Tidak | Tidak | Tidak | Ya | Ya |
| Dibatalkan | Ya | Tidak | Tidak | Tidak | Ya | Tidak |

---

## User Flows

### UF-00 — Prakondisi: Mematikan Add-on Auto Stuffing (Setup Flow)

1. **Admin Sistem / QA** membuka konfigurasi add-on pada tenant/lingkungan uji.
2. Mematikan **toggle Auto Stuffing** (kondisi default sistem adalah **aktif** — REQ-033).
3. Sistem menerapkan mode **order normal**: Step 2 menyembunyikan floating button, panel hitung ulang, dan logic penempatan otomatis; Review & Detail mengikuti kondisi tanpa elemen Auto Stuffing (REQ-035, REQ-036).
4. Admin/Staff Shipper membuka menu **Order** → **Buat Order**.

**Alternatif / Percabangan:**

- **UF-00.A1 — Toggle tetap ON:** seluruh perilaku Auto Stuffing (oms012/oms013) berlaku — di luar cakupan oms014 (REQ-033).
- **UF-00.A2 — Toggle dinyalakan kembali:** perilaku Auto Stuffing pulih sepenuhnya tanpa deploy ulang (VAL-36, ASM-005).
- **UF-00.A3 — Order draft dibuat saat toggle ON lalu dibuka saat toggle OFF:** order mengikuti kondisi toggle **saat dibuka**; penempatan barang hasil Auto Stuffing sebelumnya **tidak dihapus**, namun tidak dapat dihitung ulang (ASM-030).

### UF-01 — Buat Order FTL Tanpa Auto Stuffing, Tipe Normal (Main Flow)

1. Admin/Staff Shipper memilih **Buat Order** → jenis **FTL**.
2. **Step 1 — Data Pengiriman**: memilih **Jenis Armada**, mengisi **Jumlah Armada**, memilih **Tipe Pengiriman = Normal**.
3. Mengisi **Data Pengirim** & **Data Penerima** (auto-draft dari **Master Droppoint**, cascading wilayah).
4. Klik **Selanjutnya** → sistem memvalidasi field wajib → lanjut ke Step 2.
5. **Step 2 — Data Barang**: sistem menampilkan **card per armada** sesuai Jumlah Armada, dan menampilkan informasi **"Data Unit"** (Jenis & Jumlah Armada) bersifat **informatif** (REQ-019).
6. **Verifikasi negatif:** **tidak ada** floating button "Hitung Ulang Armada" maupun "Visualisasi Terbaru" pada halaman, termasuk saat di-scroll (REQ-003, REQ-004).
7. Pada card armada ke-1, klik **"Pilih Barang"** → modal **Pilih Barang** terbuka (pencarian by kode/nama, multi-select checkbox, counter terpilih, label "Sudah Ditambahkan").
8. Pilih barang → klik **Simpan** → baris barang tampil dengan Kode SKU, Nama Barang, Kemasan, Kubikasi, Dimensi, Berat (read-only).
9. Isi **Jumlah** pada setiap baris barang. (Opsional) isi **Nomor DO** dan centang **Tambahkan Asuransi** → isi **Nilai Barang**.
10. **Ulangi langkah 7–9 secara MANUAL untuk setiap armada berikutnya** — sistem **tidak** mendistribusikan barang otomatis (REQ-006, REQ-008).
11. Klik **Selanjutnya** → **Step 3 — Vendor & Harga**: pilih Vendor, isi Tanggal Permintaan Muat dan Harga, isi/lihat Waktu Perjalanan; (opsional) centang **Gunakan Komponen Harga**. Nilai **Asuransi** dihitung bila ada armada diasuransikan.
12. Klik **Selanjutnya** → **Step 4 — Review**: seluruh data Step 1–3 tampil read-only; Data Barang mengikuti struktur Step 2 **apa adanya** sesuai input manual, dengan label **"Diasuransikan"** per armada yang relevan.
13. **Verifikasi negatif:** pada card Data Barang Step 4 **tidak ada** button/pop up **visualisasi muatan** maupun **indikator keterisian** (REQ-029).
14. Klik **Simpan** → status order menjadi **"Menunggu Penugasan"** (REQ-022).

**Alternatif / Percabangan:**

- **UF-01.A1 — Field wajib kosong (Step 1):** klik Selanjutnya dengan Jenis/Jumlah Armada atau alamat kosong → navigasi diblokir + pesan validasi (REQ-022).
- **UF-01.A2 — Field wajib kosong (Step 2):** klik Selanjutnya tanpa mengisi **Jumlah** (atau **Nilai Barang** saat asuransi aktif) → **helper error** + **border error**; navigasi diblokir (REQ-018).
- **UF-01.A3 — Alert kapasitas armada:** total kubikasi dan/atau berat melebihi kapasitas → alert informatif tampil (3 varian pesan); **user tetap dapat lanjut** (REQ-017).
- **UF-01.A4 — Hapus barang:** klik icon hapus pada baris → barang terhapus dari armada tersebut saja; barang pada armada lain **tidak berubah** (REQ-016, REQ-006).
- **UF-01.A5 — Nomor DO multi-nilai:** input beberapa nomor dipisahkan koma → tiap nomor tampil sebagai chip (REQ-015).
- **UF-01.A6 — Barang sudah ditambahkan:** pada modal Pilih Barang untuk armada terkait, barang yang sudah masuk menampilkan label **"Sudah Ditambahkan"** (REQ-011).
- **UF-01.A7 — Batal pada modal Pilih Barang:** klik **Batal** → modal tertutup tanpa menambahkan barang (REQ-011).
- **UF-01.A8 — Simpan ke Draf:** klik **Simpan ke Draf** pada step manapun → order tersimpan dengan status draft sesuai step terakhir (REQ-024).
- **UF-01.A9 — Batal:** klik **Batal** → pop up konfirmasi → pengisian dibatalkan (REQ-022).
- **UF-01.A10 — Sebelumnya:** klik **Sebelumnya** pada Step 2/3/4 → kembali ke step sebelumnya dengan data tetap tersimpan, **tanpa** rekomputasi penempatan barang (REQ-006, REQ-022).
- **UF-01.A11 — Tanpa asuransi:** checkbox tidak dicentang → kolom Nilai Barang tidak tampil, komponen Asuransi tidak dihitung, label "Diasuransikan" tidak tampil (REQ-014, REQ-021, REQ-032).
- **UF-01.A12 — Armada tanpa barang:** salah satu card armada dibiarkan kosong → sistem menolak lanjut ke Step 3 karena minimal 1 barang per unit (**ASM-017**).
- **UF-01.A13 — Batch order:** order dibuat melalui **input batch** alih-alih manual (REQ-009, ASM-024).
- **UF-01.A14 — Ubah Jumlah Armada di Step 1 setelah Step 2 terisi:** kembali ke Step 1 dan mengubah Jumlah Armada → jumlah card Step 2 menyesuaikan; barang pada card yang hilang perlu diisi ulang manual (**ASM-016**).

### UF-02 — Buat Order FCL Tanpa Auto Stuffing, Tipe Normal

1. Ulangi UF-01 langkah 1, dengan jenis order **FCL**.
2. **Step 1**: isi **Pelabuhan Asal**, **Pelabuhan Tujuan**, pilih **Jenis Kontainer**, isi **Jumlah Kontainer**, pilih **Tipe Pengiriman = Normal**; field **Metode Pengiriman tidak tampil** (ASM-018).
3. Lanjutkan sama seperti UF-01 langkah 3–14, dengan satuan **Kontainer** dan pesan alert kapasitas memakai kata **"kontainer"** (REQ-017, ASM-015).
4. Step 3: **tidak ada input Waktu Perjalanan**; nilainya dihitung `ETA − ETD + 4 hari` dan tampil pada informasi detail saat status **"Ditugaskan"** (REQ-020, ASM-019).

**Alternatif / Percabangan:**

- **UF-02.A1 — Pelabuhan Asal = Pelabuhan Tujuan:** validasi menolak (ASM-018).
- **UF-02.A2 — Verifikasi negatif Step 2 FCL:** floating button "Hitung Ulang Kontainer" & "Visualisasi Terbaru" **tidak tampil** (REQ-003, REQ-004).
- **UF-02.A3 — Waktu Perjalanan sebelum status Ditugaskan:** informasi belum ditampilkan (REQ-020).

### UF-03 — Buat Order Tipe Multipickup / Multidrop / Multipoint (Pengisian Manual per Kombinasi Alamat)

1. Ulangi UF-01 langkah 1–2, dengan **Tipe Pengiriman = Multipickup / Multidrop / Multipoint**.
2. Sistem menerapkan **rule cascading & minimal baris** sesuai tipe (≥ 2 baris pada sisi yang relevan — ASM-007).
3. Isi seluruh alamat pengirim/penerima sesuai tipe → klik **Selanjutnya**.
4. **Step 2**: sistem menampilkan card per armada/kontainer beserta **kombinasi alamat** sesuai tipe pengiriman.
5. **User mengisi barang secara MANUAL untuk setiap kombinasi alamat pada setiap unit** — sistem **tidak** membagi barang rata antar alamat dan **tidak** menempatkan sisa ke alamat pertama (REQ-007, REQ-008).
6. Isi **Jumlah** (dan Nilai Barang bila asuransi aktif) per baris; opsional isi **Nomor DO** per unit.
7. Klik **Selanjutnya** → **Step 3**: ringkasan alamat tampil sebagai **label + text link**; klik link → detail alamat tampil.
8. Klik **Selanjutnya** → **Step 4 — Review**: seluruh kombinasi alamat & barang tampil **apa adanya** sesuai input manual, tanpa elemen visualisasi (REQ-029, REQ-030).
9. Klik **Simpan** → status **"Menunggu Penugasan"**.

**Alternatif / Percabangan:**

- **UF-03.A1 — Jumlah baris alamat kurang dari minimal:** klik Selanjutnya → validasi menolak (REQ-010, ASM-007).
- **UF-03.A2 — Distribusi tidak merata:** user sengaja mengisi jumlah berbeda antar alamat → **diterima apa adanya**, sistem tidak menyeimbangkan (REQ-007).
- **UF-03.A3 — Kombinasi alamat kosong:** salah satu kombinasi dibiarkan tanpa barang → mengikuti aturan minimal 1 barang per unit (ASM-017).
- **UF-03.A4 — Verifikasi negatif:** tidak ada floating button, panel hitung ulang, maupun indikator keterisian pada seluruh tipe multi (REQ-003 s.d. REQ-005).

### UF-04 — Edit Order

1. Pada Daftar Order, order berstatus **Menunggu Penugasan** → klik aksi **Edit**.
2. Halaman Edit Order terbuka; field **Jenis Pengiriman** & **Tipe Pengiriman** **locked/read-only** (REQ-026).
3. User mengubah **Jenis/Jumlah Armada-Kontainer, Data Pengirim, Data Penerima, Data Barang, dan/atau Vendor & Harga** — seluruh perubahan Data Barang dilakukan **manual** (REQ-008).
4. **Verifikasi negatif:** halaman edit Step 2 **tidak menampilkan** floating button/panel hitung ulang (REQ-003 s.d. REQ-005).
5. Klik **Simpan** → **pop up konfirmasi** → konfirmasi → perubahan tersimpan.

**Alternatif / Percabangan:**

- **UF-04.A1 — Batal edit:** klik **Batal** → **pop up konfirmasi** → pengeditan dibatalkan (REQ-026).
- **UF-04.A2 — Order berstatus draft:** aksi yang tersedia adalah **"Lanjutkan Pengisian"** (bukan Edit) (REQ-028).
- **UF-04.A3 — Order berstatus Ditugaskan:** aksi **Edit tidak tersedia** (REQ-025, REQ-028).
- **UF-04.A4 — Ubah Jumlah Armada/Kontainer saat edit:** jumlah card Data Barang menyesuaikan; barang pada unit yang dihapus **tidak dipindahkan otomatis** ke unit lain — user harus mengisi ulang manual (REQ-006, ASM-016).

### UF-05 — Pembatalan Order

1. Admin Shipper membuka Daftar Order dan memilih order berstatus **draft s.d. Ditugaskan**.
2. Klik aksi **Batalkan Order** → pop up pembatalan tampil.
3. Isi field **"Alasan Pembatalan"** (**wajib**).
4. Konfirmasi → status order berubah menjadi **"Dibatalkan"** (REQ-027).

**Alternatif / Percabangan:**

- **UF-05.A1 — Alasan Pembatalan kosong:** submit ditolak + pesan validasi (REQ-027).
- **UF-05.A2 — Status ≥ Proses Pengiriman:** aksi **Batalkan Order tidak tersedia** (REQ-027).
- **UF-05.A3 — Aktor vendor:** vendor tidak memiliki akses pembatalan (REQ-027).
- **UF-05.A4 — Riwayat Pembatalan:** klik tombol **"Riwayat Pembatalan"** pada toolbar → daftar order yang pernah dibatalkan tampil (REQ-028).

### UF-06 — Detail Order (Tanpa Elemen Auto Stuffing)

1. Pada Daftar Order, klik aksi **Detail** pada order yang dibuat tanpa Auto Stuffing.
2. Halaman **Detail Order** menampilkan data pengiriman, data barang per armada/kontainer (sesuai input manual), vendor & harga, serta status order.
3. **Verifikasi negatif:** **tidak ada** visualisasi muatan, pop up visualisasi, maupun **indikator keterisian** pada Detail Order (REQ-031).
4. Bila status **"Ditugaskan"** → **No. Perjalanan** tampil pada Detail Order (REQ-028).

**Alternatif / Percabangan:**

- **UF-06.A1 — Order dengan asuransi:** label **"Diasuransikan"** & Nilai Barang tampil untuk unit terkait (REQ-032).
- **UF-06.A2 — Order tipe multi:** seluruh kombinasi alamat tampil sesuai input manual (REQ-030).
- **UF-06.A3 — Perbandingan dengan mode Auto Stuffing ON:** order yang dibuat saat toggle ON tetap menampilkan elemen visualisasi — pembeda utama antar mode (REQ-036, ASM-030).

### UF-07 — Lihat No. Perjalanan

1. Vendor melakukan penugasan → status order menjadi **"Ditugaskan"**.
2. Sistem **meng-generate No. Perjalanan otomatis** sebanyak jumlah armada/kontainer yang dipesan.
3. Pada Daftar Order, aksi **"Lihat No. Perjalanan"** tampil → klik → pop up **"Data No. Perjalanan"** berisi per unit: **No. Perjalanan**, **Nopol/No. Kontainer**, **Jenis Armada/Kontainer**.
4. Klik **icon copy** → nomor tersalin ke clipboard.

**Alternatif / Percabangan:**

- **UF-07.A1 — Status belum Ditugaskan:** aksi tidak tampil (REQ-028).
- **UF-07.A2 — Public tracking:** pengirim/penerima menggunakan No. Perjalanan untuk mengecek progress perjalanan (REQ-028).

### UF-08 — Transisi Status Order (System Flow)

`Isi Data Pengiriman → Isi Data Muatan → Isi Data Vendor → Review Order → Menunggu Penugasan → Ditugaskan → Proses Pengiriman → Selesai`

Cabang: **Dibatalkan** dapat terjadi dari status draft s.d. **Ditugaskan** (REQ-023, REQ-027).

---

## Acceptance Criteria

> Spesifikasi **tidak mencantumkan acceptance criteria eksplisit**. AC berikut diturunkan langsung dari requirement (**ASM-020**) dengan traceability ke ID REQ/VAL.

| ID | Acceptance Criteria (Given / When / Then) | Traceability |
|---|---|---|
| AC-001 | Given add-on Auto Stuffing **dimatikan**, When user membuat order **FTL** atau **FCL** dengan tipe pengiriman Normal/Multipickup/Multidrop/Multipoint, Then seluruh flow order dapat diselesaikan tanpa Auto Stuffing. | REQ-001, REQ-002, REQ-034 |
| AC-002 | Given order FTL, When satuan unit diperiksa, Then satuan yang digunakan adalah **Armada**; Given order FCL, Then satuan yang digunakan adalah **Kontainer**. | REQ-002 |
| AC-003 | Given Auto Stuffing OFF, When user berada di **Step 2**, Then floating button **"Hitung Ulang Armada/Kontainer" tidak ditampilkan** — termasuk setelah halaman di-scroll dan saat hover. | REQ-003, VAL-01 |
| AC-004 | Given Auto Stuffing OFF, When user berada di **Step 2**, Then floating button **"Visualisasi Terbaru" tidak ditampilkan**. | REQ-004, VAL-02 |
| AC-005 | Given Auto Stuffing OFF, When user mencoba membuka **drawer Hitung Ulang** atau **panel Visualisasi Terbaru** melalui jalur manapun (termasuk URL langsung), Then panel **tidak dapat diakses**. | REQ-005, VAL-03 |
| AC-006 | Given Auto Stuffing OFF dan barang telah diinput pada armada/kontainer tertentu, When Step 2 di-refresh atau user berpindah step lalu kembali, Then barang **tetap berada pada unit yang sama** tanpa distribusi otomatis. | REQ-006, VAL-04 |
| AC-007 | Given Auto Stuffing OFF dan tipe pengiriman **Multipickup/Multidrop/Multipoint**, When barang diinput, Then sistem **tidak** membagi barang rata antar alamat dan **tidak** menempatkan sisa ke alamat pertama. | REQ-007, VAL-05 |
| AC-008 | Given Auto Stuffing OFF, When user mengisi Step 2, Then user dapat mengisi barang **secara manual dan independen** untuk **setiap armada/kontainer** dan **setiap kombinasi alamat**. | REQ-008, VAL-06, VAL-M7 |
| AC-009 | Given Auto Stuffing OFF, When wizard order dibuka, Then tetap tersedia **4 step**: Data Pengiriman, Data Barang, Vendor & Harga, Review. | REQ-009, VAL-11 |
| AC-010 | Given user berada di Step 1, When halaman dimuat, Then field **Jenis & Jumlah Armada/Kontainer, Tipe Pengiriman (4 opsi), Data Pengirim, Data Penerima** tampil; pada FCL juga **Pelabuhan Asal & Tujuan** dan **tanpa Metode Pengiriman**. | REQ-010, ASM-018 |
| AC-011 | Given user memilih droppoint, When Data Pengirim/Penerima diisi, Then data **ter-auto-draft dari Master Droppoint** dengan cascading wilayah. | REQ-010 |
| AC-012 | Given tipe pengiriman multi, When user mencoba lanjut dengan baris alamat kurang dari minimal, Then sistem **menolak** dan menampilkan validasi. | REQ-010, ASM-007 |
| AC-013 | Given user berada di Step 2, When area data barang diperiksa, Then **tidak ada** input deskripsi barang manual; penambahan **hanya** via modal **"Pilih Barang"**. | REQ-011, VAL-12 |
| AC-014 | Given modal "Pilih Barang" terbuka, When user mengetik kode atau nama barang, Then daftar tersaring sesuai kata kunci. | REQ-011, VAL-M2 |
| AC-015 | Given modal "Pilih Barang" terbuka, When user mencentang beberapa barang, Then multi-select berhasil dan **counter jumlah barang terpilih** ter-update. | REQ-011, VAL-M3, VAL-M5 |
| AC-016 | Given suatu barang sudah ditambahkan ke unit terkait, When modal dibuka untuk unit tersebut, Then barang menampilkan label **"Sudah Ditambahkan"**. | REQ-011, VAL-M4 |
| AC-017 | Given barang terpilih pada modal, When user klik **Simpan**, Then barang masuk ke card unit **tempat modal dibuka**; When klik **Batal**, Then tidak ada barang ditambahkan. | REQ-011, VAL-M6, VAL-M7 |
| AC-018 | Given baris barang tampil, When user mencoba mengubah Kode SKU/Nama Barang/Kemasan/Kubikasi/Dimensi/Berat, Then field bersifat **read-only**. | REQ-012, VAL-13 |
| AC-019 | Given baris barang tampil, When field **Jumlah** dikosongkan lalu klik Selanjutnya, Then **helper error** tampil, **border field berwarna error**, dan navigasi **diblokir**. | REQ-013, REQ-018, VAL-14 |
| AC-020 | Given checkbox "Tambahkan Asuransi" **tidak** tercentang, When card unit diperiksa, Then kolom **Nilai Barang tidak tampil** dan tidak divalidasi. | REQ-014, VAL-15 |
| AC-021 | Given checkbox "Tambahkan Asuransi" **dicentang**, When card unit diperiksa, Then kolom **Nilai Barang tampil untuk seluruh barang** pada unit tersebut dan bersifat **wajib**. | REQ-014, VAL-16 |
| AC-022 | Given field **Nomor DO** kosong, When klik Selanjutnya, Then navigasi **tetap berhasil**; Given beberapa nomor dipisahkan **koma**, Then setiap nomor tampil sebagai **chip** terpisah. | REQ-015, VAL-17 |
| AC-023 | Given baris barang tampil, When user klik **icon hapus**, Then baris terhapus dari unit tersebut saja dan total kubikasi/berat unit ter-update. | REQ-016, VAL-18 |
| AC-024 | Given total **kubikasi** melebihi kapasitas unit, When Step 2 dirender, Then alert **"Kubikasi melebihi kapasitas armada/kontainer"** tampil sesuai jenis order. | REQ-017, VAL-20 |
| AC-025 | Given total **berat** melebihi kapasitas unit, When Step 2 dirender, Then alert **"Berat melebihi kapasitas armada/kontainer"** tampil. | REQ-017, VAL-20 |
| AC-026 | Given **kubikasi dan berat** melebihi kapasitas unit, When Step 2 dirender, Then alert **"Kubikasi dan Berat melebihi kapasitas armada/kontainer"** tampil. | REQ-017, VAL-20 |
| AC-027 | Given alert kapasitas tampil, When user klik **Selanjutnya**, Then sistem **tetap mengizinkan** lanjut ke step berikutnya (alert informatif). | REQ-017, VAL-19 |
| AC-028 | Given Jenis Armada/Kontainer tertentu dipilih pada Step 1, When alert kapasitas dievaluasi, Then pembanding kapasitas mengikuti **jenis unit tersebut**. | REQ-017, VAL-21 |
| AC-029 | Given user berada di Step 2 dengan Auto Stuffing OFF, When halaman dimuat, Then informasi **"Data Unit"** (Jenis & Jumlah Armada/Kontainer) **tetap tampil** dan **konsisten dengan Step 1**. | REQ-019, VAL-22 |
| AC-030 | Given informasi "Data Unit" tampil, When user mencoba berinteraksi dengannya, Then bersifat **read-only/informatif** dan **tidak menyediakan mekanisme hitung ulang**. | REQ-019, VAL-22 |
| AC-031 | Given user berada di Step 3, When halaman dimuat, Then field **Pilihan Vendor, Tanggal Permintaan Muat, Harga**, ringkasan alamat, dan checkbox **"Gunakan Komponen Harga"** tampil. | REQ-020 |
| AC-032 | Given order **FTL**, When Step 3 dirender, Then **Waktu Perjalanan** tampil sebagai textfield (rute belum ada di master) atau text-only (rute sudah ada). | REQ-020, VAL-24 |
| AC-033 | Given order **FCL**, When Step 3 dirender, Then **tidak ada input Waktu Perjalanan**; nilainya tampil pada informasi detail saat status **"Ditugaskan"** dengan perhitungan `ETA − ETD + 4 hari`. | REQ-020, VAL-24 |
| AC-034 | Given terdapat unit yang diasuransikan pada Step 2, When Step 3 dirender, Then komponen **Asuransi = persentase × Total Nilai Barang** tampil dan **turut dihitung ke Total Harga** bersama **PPN & PPh**. | REQ-021, VAL-23 |
| AC-035 | Given **tidak ada** unit yang diasuransikan, When Step 3 dirender, Then komponen Asuransi **tidak** dihitung ke Total Harga. | REQ-021, VAL-23 |
| AC-036 | Given field wajib pada suatu step kosong, When klik Selanjutnya, Then navigasi **diblokir** dengan pesan validasi. | REQ-022 |
| AC-037 | Given user berada di step manapun, When menekan **Batal / Simpan ke Draf / Sebelumnya / Selanjutnya**, Then perilaku identik dengan rule standar OMS. | REQ-022 |
| AC-038 | Given seluruh data lengkap, When user klik **Simpan** pada Step 4, Then order tersimpan dan status berubah menjadi **"Menunggu Penugasan"**. | REQ-022, VAL-26 |
| AC-039 | Given daftar order, When kolom status diperiksa, Then hanya **9 status valid** yang dapat muncul. | REQ-023 |
| AC-040 | Given user berhenti pada suatu step, When klik **"Simpan ke Draf"**, Then order tersimpan dengan status draft sesuai step terakhir (Isi Data Pengiriman / Isi Data Muatan / Isi Data Vendor / Review Order). | REQ-024, VAL-27 |
| AC-041 | Given order berstatus **Menunggu Penugasan**, When shipper membuka Edit Order, Then perubahan data diizinkan dan tersimpan; Given status **Ditugaskan**, Then aksi Edit **tidak tersedia**. | REQ-025, VAL-28 |
| AC-042 | Given halaman Edit Order terbuka, When field **Jenis Pengiriman** & **Tipe Pengiriman** diperiksa, Then keduanya **locked/read-only**, sedangkan Jenis/Jumlah unit, Data Pengirim/Penerima, Data Barang, dan Vendor & Harga **dapat diubah**. | REQ-026, VAL-28 |
| AC-043 | Given halaman Edit Order, When user klik **Batal** atau **Simpan**, Then **pop up konfirmasi tampil** sebelum aksi dieksekusi. | REQ-026, VAL-29 |
| AC-044 | Given halaman **Edit Order** pada mode Auto Stuffing OFF, When Step 2 diperiksa, Then floating button & panel hitung ulang **tidak tampil**. | REQ-003, REQ-005, REQ-035 |
| AC-045 | Given order berstatus draft s.d. **Ditugaskan**, When action menu diperiksa, Then aksi **Batalkan Order tersedia**; Given status **Proses Pengiriman** atau setelahnya, Then aksi **tidak tersedia**. | REQ-027, VAL-30 |
| AC-046 | Given form pembatalan terbuka, When **Alasan Pembatalan** kosong lalu disubmit, Then submit **ditolak** dan pesan validasi tampil; When diisi lalu disubmit, Then status berubah menjadi **"Dibatalkan"**. | REQ-027, VAL-30 |
| AC-047 | Given aktor **vendor**, When mencoba membatalkan order, Then aksi **tidak tersedia/ditolak**. | REQ-027, VAL-30 |
| AC-048 | Given daftar order, When action menu dibuka, Then daftar aksi **persis** sesuai status: draft/Review → Detail, Lanjutkan Pengisian, Batalkan Order, Riwayat Perubahan; Menunggu Penugasan → Detail, Edit, Batalkan Order, Riwayat Perubahan; Ditugaskan → Detail, Batalkan Order, Riwayat Perubahan, Lihat No. Perjalanan. | REQ-028, VAL-31 |
| AC-049 | Given order dengan **N armada/kontainer** berstatus Ditugaskan, When No. Perjalanan diperiksa, Then sistem meng-generate **tepat N** nomor **unik**; aksi **"Lihat No. Perjalanan"** hanya tampil pada status **Ditugaskan** dan hanya untuk **FTL & FCL**. | REQ-028, VAL-32 |
| AC-050 | Given pop up **"Data No. Perjalanan"** terbuka, When diperiksa, Then menampilkan **No. Perjalanan, Nopol/No. Kontainer, Jenis Armada/Kontainer** per unit, dengan **icon copy** yang berfungsi. | REQ-028 |
| AC-051 | Given Auto Stuffing OFF, When user berada di **Step 4 (Review)**, Then **tidak terdapat** button visualisasi muatan, pop up visualisasi, maupun **indikator keterisian**. | REQ-029, VAL-07 |
| AC-052 | Given data barang diinput manual pada Step 2, When Step 4 dirender, Then Data Barang ditampilkan **apa adanya** per armada/kontainer sesuai input manual (unit, alamat, barang, jumlah **identik**). | REQ-030, VAL-09 |
| AC-053 | Given order dibuat tanpa Auto Stuffing, When halaman **Detail Order** dibuka, Then **tidak terdapat** elemen visualisasi/keterisian hasil Auto Stuffing. | REQ-031, VAL-08 |
| AC-054 | Given Step 4 dirender, When bagian Data Barang diperiksa, Then menampilkan **Kode SKU, Nama Barang, Kemasan, Kubikasi/Dimensi, Berat, Jumlah**, **Nilai Barang** hanya untuk unit yang diasuransikan, label **"Diasuransikan"** pada unit tersebut, dan seluruh data Step 1–3 **read-only**. | REQ-032, VAL-25 |
| AC-055 | Given build sistem, When add-on tidak dikonfigurasi apa pun, Then perilaku **default** adalah Auto Stuffing **aktif**. | REQ-033, VAL-33 |
| AC-056 | Given tersedia **toggle Auto Stuffing**, When toggle dimatikan, Then flow order normal (tanpa Auto Stuffing) **dapat dijalankan & diuji** end-to-end. | REQ-034 |
| AC-057 | Given toggle dimatikan, When Step 2 dirender, Then **floating button, panel hitung ulang, dan logic penempatan otomatis** disembunyikan/di-bypass **secara serentak**. | REQ-035, VAL-34 |
| AC-058 | Given toggle dimatikan, When Review dan Detail Order dibuka, Then keduanya mengikuti kondisi **tanpa elemen Auto Stuffing**. | REQ-036, VAL-35 |
| AC-059 | Given toggle dinyalakan kembali, When order baru dibuat, Then seluruh perilaku Auto Stuffing (oms012/oms013) **pulih** tanpa deploy ulang. | REQ-034, VAL-36 |
| AC-060 | Given mode Auto Stuffing ON dan OFF, When halaman Step 2/Review/Detail dibandingkan, Then **basis komponen sama** (tanpa halaman/route duplikat) dan penghilangan elemen **tidak** menimbulkan layout pecah/ruang kosong/error. | REQ-037, VAL-10, VAL-37 |

---

## UI Inventory

> Sumber: **60 file PNG** pada `inputs/oms014-order-ftl-fcl-normal/designs/`. Nama file **tidak konsisten** dengan isi layar (mis. `003-admin-daftar-order-multidrop.png` justru berisi Step 1 Buat Order) — penamaan layar di bawah mengikuti **konten visual**, bukan nama file (**ASM-031**).
> Produk: **Order Management System Versi 1.0.0**, tenant **"Mentari Sumber Kertas"**, aktor login **Shipper — badge "Staff Operasional"** (Andika, andikamsk@gmail.com).
> **Konfirmasi utama oms014:** pada **seluruh 60 desain**, elemen turunan Auto Stuffing **ABSEN** — tidak ditemukan floating button *"Hitung Ulang Armada/Kontainer"*, floating button *"Visualisasi Terbaru"*, drawer/panel hitung ulang, visualisasi muatan 3D, indikator/progress bar keterisian, label *"Paling Efisien"*, badge stuffing, maupun button *"Terapkan ke Order"* (**ASM-032**). Ini mengkonfirmasi REQ-003, REQ-004, REQ-005, REQ-029, REQ-031 dan VAL-01, VAL-02, VAL-07, VAL-08.

### Kerangka Global (App Shell) — tampil di semua layar
(sumber: seluruh PNG)

| Elemen | Tipe | State terlihat | Label/teks persis | selectorHint (prioritas) |
|---|---|---|---|---|
| Logo tenant | image/text | default | `Mentari Sumber Kertas` | `getByRole('link',{name:'Mentari Sumber Kertas'})` → tid `app-logo` |
| Toggle sidebar | button (ikon hamburger) | default | — | `getByRole('button',{name:/menu|sidebar/i})` → tid `btn-toggle-sidebar` |
| Nav Dashboard | link + chevron (expandable) | default | `Dashboard` | `getByRole('link',{name:'Dashboard'})` → tid `nav-dashboard` |
| Nav Order | link | **active** pada layar Daftar/Buat Order | `Order` | `getByRole('link',{name:'Order',exact:true})` → tid `nav-order` |
| Nav Penugasan Tracking | link | active pada sebagian desain (artefak desain, ASM-033) | `Penugasan Tracking` | `getByRole('link',{name:'Penugasan Tracking'})` → tid `nav-penugasan-tracking` |
| Nav Master Wilayah / Master Operasional / Pusat Notifikasi | link + chevron | collapsed | `Master Wilayah`, `Master Operasional`, `Pusat Notifikasi` | `getByRole('link',{name:'<label>'})` |
| Nav Manajemen Vendor / Pengaturan Akun / Akun Saya / Pengaturan Sistem | link | default | idem | `getByRole('link',{name:'<label>'})` |
| Kartu Kuota Order | card + progress bar | filled 40% | `Kuota Order`, `120/300`, `40%` | `getByTestId('card-kuota-order')`; nilai: `getByText('120/300')` |
| Versi aplikasi | text | default | `Order Management System` / `Versi 1.0.0` | `getByText('Versi 1.0.0')` → tid `app-version` |
| Role badge | badge | default | `Shipper` + `Staff Operasional` | `getByText('Staff Operasional')` → tid `badge-role` |
| Notifikasi | button (bell + dot merah) | **unread (dot)** | — | `getByRole('button',{name:/notifikasi/i})` → tid `btn-notifikasi` |
| Profil user | avatar + text | default | `Andika`, `andikamsk@gmail.com` | `getByTestId('user-profile')`; `getByText('andikamsk@gmail.com')` |
| Logout | button (ikon keluar) | default | — | `getByRole('button',{name:/keluar|logout/i})` → tid `btn-logout` |
| Breadcrumb | nav | default | `Beranda` › `Daftar Order` › `Buat Order` \| `Detail Order` \| `Edit Order` | `getByRole('navigation',{name:'breadcrumb'})`; item: `getByRole('link',{name:'Daftar Order'})` |

### 1. Daftar Order (sumber: `004-admin-daftar-order.png`, `001-admin-daftar-order-multipoint.png`, `014.png`, `023.png`, `031.png`, `039.png`, `83.png`)

Halaman entry-point modul. Menampilkan seluruh order lintas jenis (FTL/FCL/LTL/LCL) dan lintas status. Varian Normal vs Multi dibedakan pada kolom Kota Asal/Kota Tujuan: tipe multi menampilkan **text link** `Multipickup` / `Multidrop` menggantikan nama kota.

| Elemen | Tipe | State | Label/teks persis | selectorHint |
|---|---|---|---|---|
| Judul halaman | heading h1 | default | `Daftar Order` | `getByRole('heading',{name:'Daftar Order'})` |
| Buat Order | button primary + ikon `+` | default | `Buat Order` | `getByRole('button',{name:'Buat Order'})` → tid `btn-buat-order` |
| Batch Order | button outline + ikon unduh | default | `Batch Order` | `getByRole('button',{name:'Batch Order'})` → tid `btn-batch-order` |
| Riwayat Pembatalan | button outline + ikon jam | default | `Riwayat Pembatalan` | `getByRole('button',{name:'Riwayat Pembatalan'})` → tid `btn-riwayat-pembatalan` |
| Filter | button outline + ikon filter | default / **active (panel terbuka)** | `Filter` | `getByRole('button',{name:'Filter'})` → tid `btn-filter` |
| Jumlah data per halaman | select | filled `20` | `Tampilkan` … `data` | `getByLabel('Tampilkan')` → tid `select-page-size` |
| Header tabel (2 baris) | table columnheader | sortable pada Total Harga (ikon ⇅) | `ID Order`/`Vendor`, `Kota Asal`/`Warehouse Asal`, `Kota Tujuan`/`Warehouse Tujuan`, `Total Harga`/`Status` | `getByRole('columnheader',{name:'ID Order'})`; sort: `getByRole('button',{name:'Total Harga'})` |
| Baris order | table row | default | `ORD769797FSH`, `ORD789871FSF7` | `getByRole('row',{name:/ORD769797FSH/})` → tid `row-order-<id>` |
| Badge jenis order | badge | default | `FTL`, `FCL`, `LTL`, `LCL` | `getByTestId('row-order-<id>').getByText('FCL')` → tid `badge-jenis-order` |
| Link tipe multi | link | default | `Multipickup`, `Multidrop` | `getByRole('link',{name:'Multipickup'})` → tid `link-tipe-pengiriman` |
| Badge status | badge (warna per status) | 9 varian | `Isi Data Dasar`, `Isi Data Muatan`, `Isi Data Vendor`, `Review Order`, `Menunggu Penugasan`, `Ditugaskan`, `Proses Pengiriman`, `Terkirim`, `Dibatalkan` | `getByTestId('row-order-<id>').getByTestId('badge-status')`; teks: `getByText('Menunggu Penugasan')` |
| Aksi baris | button kebab `...` | default | — | `getByRole('row',...).getByRole('button',{name:/aksi|more/i})` → tid `btn-aksi-order` |
| Info paginasi | text | default | `Menampilkan 1 - 20 data dari 30 data` | `getByText(/Menampilkan \d+ - \d+ data dari \d+ data/)` |
| Paginasi | navigation | halaman 1 aktif | `1` `2` `3` `…` `12` + « ‹ › » | `getByRole('button',{name:'2'})` → tid `pagination` |

**Catatan penyimpangan vs spec:** label status pada desain **berbeda** dari REQ-023 — desain memakai **`Isi Data Dasar`** (spec: "Isi Data Pengiriman") dan **`Terkirim`** (spec: "Selesai") → **ASM-034**.
**Catatan oms014:** tidak ada kolom/badge stuffing maupun indikator keterisian pada tabel — **ABSEN sesuai harapan**.

### 2. Daftar Order — Menu Aksi Baris (sumber: `83.png`)

Menu dropdown pada baris berstatus **Ditugaskan**.

| Elemen | Tipe | State | Label persis | selectorHint |
|---|---|---|---|---|
| Detail | menuitem | default | `Detail` | `getByRole('menuitem',{name:'Detail'})` → tid `action-detail` |
| Lihat No. Perjalanan | menuitem | tampil hanya saat status Ditugaskan | `Lihat No. Perjalanan` | `getByRole('menuitem',{name:'Lihat No. Perjalanan'})` → tid `action-lihat-no-perjalanan` |
| Order Kembali | menuitem | default | `Order Kembali` | `getByRole('menuitem',{name:'Order Kembali'})` → tid `action-order-kembali` |
| Batalkan Order | menuitem | default | `Batalkan Order` | `getByRole('menuitem',{name:'Batalkan Order'})` → tid `action-batalkan-order` |
| Riwayat Perubahan | menuitem | default | `Riwayat Perubahan` | `getByRole('menuitem',{name:'Riwayat Perubahan'})` → tid `action-riwayat-perubahan` |

**Catatan:** aksi **`Order Kembali`** tidak disebut pada REQ-028 → **ASM-035**. Aksi `Edit`/`Lanjutkan Pengisian` tidak tertangkap pada desain (menu hanya di-capture untuk status Ditugaskan).

### 3. Daftar Order — Panel Filter (sumber: `005-admin-daftar-order-filter.png`, `83.png`)

Panel filter inline yang terbuka di bawah toolbar; seluruh field dalam kondisi **empty**.

| Elemen | Tipe | State | Label / placeholder persis | selectorHint |
|---|---|---|---|---|
| ID Order | input text | empty | label `ID Order`, ph `Masukkan ID Order` | `getByLabel('ID Order')` / `getByPlaceholder('Masukkan ID Order')` → tid `filter-id-order` |
| Jenis Order | select | empty | `Jenis Order`, ph `Pilih Jenis Order` | `getByLabel('Jenis Order')` → tid `filter-jenis-order` |
| Vendor | input text | empty | `Vendor`, ph `Masukkan Vendor` | `getByPlaceholder('Masukkan Vendor')` → tid `filter-vendor` |
| Kota Asal | select | empty | `Kota Asal`, ph `Pilih Kota Asal` | `getByLabel('Kota Asal')` → tid `filter-kota-asal` |
| Kota Tujuan | select | empty | `Kota Tujuan`, ph `Pilih Kota Tujuan` | `getByLabel('Kota Tujuan')` → tid `filter-kota-tujuan` |
| Total Harga | input | empty | `Total Harga`, ph `Masukkan Total Harga` | `getByPlaceholder('Masukkan Total Harga')` → tid `filter-total-harga` |
| Tipe Pengiriman | select | **disabled/empty** (teks abu) | `Tipe Pengiriman`, ph `Pilih Tipe Pengiriman` | `getByLabel('Tipe Pengiriman')` → tid `filter-tipe-pengiriman` |
| Skema Pengiriman | select | **disabled/empty** | `Skema Pengiriman`, ph `Pilih Skema Pengiriman` | `getByLabel('Skema Pengiriman')` → tid `filter-skema-pengiriman` |
| Drop Point Asal | select | empty | `Drop Point Asal`, ph `Pilih Drop Point Asal` | `getByLabel('Drop Point Asal')` → tid `filter-drop-point-asal` |
| Drop Point Tujuan | select | empty | `Drop Point Tujuan`, ph `Pilih Drop Point Tujuan` | `getByLabel('Drop Point Tujuan')` → tid `filter-drop-point-tujuan` |
| Status | select | empty | `Status`, ph `Pilih Status` | `getByLabel('Status')` → tid `filter-status` |
| Reset | button outline-danger | default | `Reset` | `getByRole('button',{name:'Reset'})` → tid `btn-filter-reset` |
| Terapkan | button primary | default | `Terapkan` | `getByRole('button',{name:'Terapkan'})` → tid `btn-filter-terapkan` |

### 4. Pop Up "Data No. Perjalanan" (sumber: `84.png`)

Dibuka dari aksi *Lihat No. Perjalanan*; menampilkan 1 baris per kontainer/armada (order 2 kontainer → 2 baris) → mendukung VAL-32.

| Elemen | Tipe | State | Teks persis | selectorHint |
|---|---|---|---|---|
| Judul modal | dialog heading | open | `Data No. Perjalanan` | `getByRole('dialog',{name:'Data No. Perjalanan'})` |
| Tutup | button ikon `X` | default | — | `getByRole('button',{name:/tutup|close/i})` → tid `btn-close-modal` |
| Chip ID Order | chip/badge | default | `ID Order: ORD-20260607009` | `getByText(/^ID Order: /)` → tid `chip-id-order` |
| Badge jenis order | badge | default | `FCL` | `getByTestId('modal-no-perjalanan').getByText('FCL')` |
| Baris No. Perjalanan | list item + ikon copy | default | `TRC79289802` — `TVW67892231 • 40 DRY` / `CTN68901072 • 40 DRY` | `getByTestId('row-no-perjalanan').nth(0)`; copy: `getByRole('button',{name:/salin|copy/i})` → tid `btn-copy-no-perjalanan` |

### 5. Buat Order — Step 1 Data Pengiriman, state default/kosong (sumber: `006-admin-buat-order-default.png`, `015.png`)

Kondisi awal wizard: **Tipe Pengiriman belum dipilih**, sehingga kartu **Data Pengirim/Data Penerima belum dirender** dan tombol **`Selanjutnya` dalam state DISABLED**.

| Elemen | Tipe | State | Label/teks persis | selectorHint |
|---|---|---|---|---|
| Judul | heading h1 | default | `Buat Order` | `getByRole('heading',{name:'Buat Order'})` |
| Stepper | stepper 4 langkah | step 01 aktif; 02–04 inactive | `01 Data Pengiriman`, `02 Data Barang`, `03 Vendor dan Harga`, `04 Review` | `getByTestId('wizard-stepper')`; langkah: `getByTestId('step-1-data-pengiriman')` |
| Kartu jenis pengiriman | card group | — | `Jenis Pengiriman dan Rute` | `getByRole('heading',{name:'Jenis Pengiriman dan Rute'})` |
| Pilihan FTL | radio card | unselected | `FTL` / `Full Truck Load` | `getByRole('radio',{name:/FTL/})` → tid `radio-jenis-ftl` |
| Pilihan FCL | radio card | **selected** (varian FCL) | `FCL` / `Full Container Load` | `getByRole('radio',{name:/FCL/})` → tid `radio-jenis-fcl` |
| Pilihan LTL | radio card | unselected | `LTL` / `Less Than Truck Load` | `getByRole('radio',{name:/LTL/})` → tid `radio-jenis-ltl` |
| Pilihan LCL | radio card | unselected | `LCL` / `Less Than Container Load` | `getByRole('radio',{name:/LCL/})` → tid `radio-jenis-lcl` |
| Tipe Pengiriman | select (wajib `*`) | **empty** | `Tipe Pengiriman *`, ph `Pilih Tipe Pengiriman` | `getByLabel('Tipe Pengiriman')` → tid `select-tipe-pengiriman` |
| Batal | button outline-danger | default | `Batal` | `getByRole('button',{name:'Batal'})` → tid `btn-batal` |
| Selanjutnya | button primary + panah | **disabled** | `Selanjutnya` | `getByRole('button',{name:'Selanjutnya'})` → tid `btn-selanjutnya` |

**Catatan oms014:** tidak ada toggle/switch Auto Stuffing pada UI shipper — konsisten dengan ASM-004.

### 6. Buat Order — Step 1, FTL Tipe Normal (sumber: `007-admin-buat-order-step-1-normal.png`)

| Elemen | Tipe | State | Label/teks persis | selectorHint |
|---|---|---|---|---|
| Jenis Armada | select (wajib) | filled | `Jenis Armada *` | `getByLabel('Jenis Armada')` → tid `select-jenis-armada` |
| Jumlah Armada | input number (wajib) | filled `2` | `Jumlah Armada *` | `getByLabel('Jumlah Armada')` → tid `input-jumlah-armada` |
| Tipe Pengiriman | select (wajib) | filled `Normal` | `Tipe Pengiriman *` | `getByLabel('Tipe Pengiriman')` |
| Kartu Data Pengirim | card | — | `Data Pengirim` | `getByRole('heading',{name:'Data Pengirim'})` → tid `card-data-pengirim` |
| Drop Point Asal | select (wajib) | empty/filled | `Drop Point Asal *`, ph `Pilih  Drop Point Asal` | `getByLabel('Drop Point Asal')` → tid `select-drop-point-asal` |
| Pengirim | select (wajib) | empty | `Pengirim *`, ph `Pilih Pengirim` | `getByLabel('Pengirim')` → tid `select-pengirim` |
| PIC Pengirim | input (wajib) | empty | `PIC Pengirim *`, ph `Masukkan PIC Pengirim`, helper `Nama PIC Pengirim` | `getByLabel('PIC Pengirim')` → tid `input-pic-pengirim` |
| No. WhatsApp PIC (pengirim) | input (wajib) | empty | `No. WhatsApp PIC *`, ph `Masukkan No. WhatsApp PIC`, helper `Contoh: 081234567898` | `getByTestId('card-data-pengirim').getByLabel('No. WhatsApp PIC')` → tid `input-wa-pengirim` |
| Provinsi Asal / Kota-Kab. Asal / Kecamatan Asal / Desa-Kelurahan Asal / Kode Pos | input **read-only** (auto-draft cascading) | disabled look (abu) | `Provinsi Asal`, `Kota/Kab. Asal`, `Kecamatan Asal`, `Desa/Kelurahan Asal`, `Kode Pos` | `getByLabel('Provinsi Asal')` → tid `input-provinsi-asal` dst. |
| Alamat Asal | textarea read-only | disabled look | `Alamat Asal` | `getByLabel('Alamat Asal')` → tid `textarea-alamat-asal` |
| Catatan (pengirim) | textarea | empty | `Catatan`, ph `Masukkan Catatan` | `getByTestId('card-data-pengirim').getByLabel('Catatan')` → tid `textarea-catatan-pengirim` |
| Kartu Data Penerima | card | — | `Data Penerima` | `getByRole('heading',{name:'Data Penerima'})` → tid `card-data-penerima` |
| Drop Point Tujuan / Penerima / PIC Penerima / No. WhatsApp PIC / Provinsi Tujuan / Kota/Kab. Tujuan / Kecamatan Tujuan / Desa/Kelurahan Tujuan / Kode Pos / Alamat Tujuan / Catatan | idem sisi penerima | empty | `Drop Point Tujuan *`, `Penerima *`, `PIC Penerima *`, `No. WhatsApp PIC *`, … , `Alamat Tujuan` | `getByTestId('card-data-penerima').getByLabel('<label>')` |
| Simpan ke Draf | button outline | default | `Simpan ke Draf` | `getByRole('button',{name:'Simpan ke Draf'})` → tid `btn-simpan-draf` |
| Selanjutnya | button primary | enabled | `Selanjutnya` | `getByRole('button',{name:'Selanjutnya'})` |

### 7. Buat Order — Step 1, FCL Tipe Normal (sumber: `016.png`)

Sama dengan §6 namun unit = **Kontainer** dan terdapat field pelabuhan.

| Elemen | Tipe | State | Label persis | selectorHint |
|---|---|---|---|---|
| Pelabuhan Asal | select (wajib) | filled `Tanjung Perak (SUB)` | `Pelabuhan Asal *` | `getByLabel('Pelabuhan Asal')` → tid `select-pelabuhan-asal` |
| Pelabuhan Tujuan | select (wajib) | filled `Panjang (PNJ)` | `Pelabuhan Tujuan *` | `getByLabel('Pelabuhan Tujuan')` → tid `select-pelabuhan-tujuan` |
| Jenis Kontainer | select (wajib) | filled `20 DRY` | `Jenis Kontainer *` | `getByLabel('Jenis Kontainer')` → tid `select-jenis-kontainer` |
| Jumlah Kontainer | input number (wajib) | filled `2` | `Jumlah Kontainer *` | `getByLabel('Jumlah Kontainer')` → tid `input-jumlah-kontainer` |
| Tipe Pengiriman | select (wajib) | filled `Normal` | `Tipe Pengiriman *` | `getByLabel('Tipe Pengiriman')` |
| Metode Pengiriman | — | **TIDAK TAMPIL** pada varian Normal | — | assert `getByText('Metode Pengiriman')` **hidden** |

### 8. Buat Order — Step 1, Tipe Multipickup / Multidrop / Multipoint (sumber: `003-admin-daftar-order-multidrop.png`, `003-admin-daftar-order-multipoint.png`, `024.png`, `032.png`, `040.png`)

Perbedaan vs Normal: baris alamat jamak + info alert + (pada FCL multi) blok **Metode Pengiriman**.

| Elemen | Tipe | State | Label/teks persis | selectorHint |
|---|---|---|---|---|
| Metode Pengiriman (FCL multi) | radio card group (wajib) | `Door to Door` selected | `Metode Pengiriman *`; opsi `Door to Door` (*Kontainer diambil dari lokasi pengirim dan diantar hingga penerima.*), `Door to CY` (*…dikirim hingga Container Yard (CY).*), `CY to CY` (*Kontainer diambil dari Container Yard (CY) asal dan dikirim ke Container Yard (CY) tujuan.*), `CY to Door` (*…dan diantar hingga lokasi penerima.*) | `getByRole('radio',{name:'Door to Door'})` → tid `radio-metode-door-to-door`, `-door-to-cy`, `-cy-to-cy`, `-cy-to-door` |
| Info alert urutan | alert info (biru, ikon i) | visible | `Pastikan urutan pengiriman sudah sesuai saat membuat shipment` | `getByRole('alert').filter({hasText:'Pastikan urutan pengiriman'})` → tid `alert-urutan-pengiriman` |
| Label baris pengirim | section label | default | `Pick Up 1`, `Pick Up 2` | `getByText('Pick Up 2',{exact:true})` → tid `section-pickup-2` |
| Label baris penerima | section label | default | `Drop Off 1`, `Drop Off 2` | `getByText('Drop Off 2',{exact:true})` → tid `section-dropoff-2` |
| Hapus baris alamat | button ikon tong sampah (merah) | tampil pada baris ≥ 2 | — | `getByTestId('section-pickup-2').getByRole('button',{name:/hapus/i})` → tid `btn-hapus-baris-alamat` |
| Tambah Baris Input | link-button + ikon `+` | default | `Tambah Baris Input` | `getByRole('button',{name:'Tambah Baris Input'})` → tid `btn-tambah-baris-input` |

**Catatan penyimpangan vs ASM-018:** FCL varian **Normal** (`015/016.png`) **tidak** menampilkan Metode Pengiriman, sedangkan FCL varian **multi** (`024/031/040.png`) **menampilkan** Metode Pengiriman; pada **Edit Order** field yang sama dinamai **`Skema Pengiriman`** → **ASM-036**.

### 9. Buat Order — Step 2 Data Barang, Tipe Normal (sumber: `008-admin-buat-order-step-2-normal.png`, `017.png`)

Satu **card per unit** (`Armada 1..N` / `Kontainer 1..N`) sesuai Jumlah Armada/Kontainer Step 1. **Tidak ada card "Data Unit" eksplisit** (ASM-033).

| Elemen | Tipe | State | Label/teks persis | selectorHint |
|---|---|---|---|---|
| Judul card unit | heading | default | `Armada 1` / `Kontainer 1` / `Kontainer 2` / `Kontainer 3` | `getByRole('heading',{name:'Kontainer 1'})` → tid `card-unit-1` |
| Tambahkan Asuransi | checkbox | **checked** (unit 1) / **unchecked** (unit 2,3) | `Tambahkan Asuransi`, helper `Berlaku untuk seluruh barang pada armada ini` | `getByTestId('card-unit-1').getByRole('checkbox',{name:'Tambahkan Asuransi'})` → tid `checkbox-asuransi-unit-1` |
| Nomor DO | input chip multi-value | filled (2 chip) / empty | `Nomor DO`, ph `Masukkan Nomor DO`, helper `Pisahkan dengan koma untuk menambahkan beberapa nomor` | `getByTestId('card-unit-1').getByLabel('Nomor DO')` → tid `input-nomor-do-unit-1` |
| Chip Nomor DO | chip + ikon `×` | filled | `TGK783898202U`, `TBL28371302` | `getByTestId('input-nomor-do-unit-1').getByText('TBL28371302')`; hapus: `getByRole('button',{name:/hapus TBL28371302/i})` |
| Header tabel barang | columnheader (2 baris) | — | `Kode SKU`/`Nama Barang`, `Kemasan`, `Kubikasi`/`Dimensi`, `Berat`, `Jumlah`, `Nilai Barang` | `getByRole('columnheader',{name:'Kode SKU'})` |
| Kolom Nilai Barang | column | **tampil hanya bila asuransi checked** | `Nilai Barang` | assert visible/hidden: `getByTestId('card-unit-2').getByText('Nilai Barang')` |
| Sel read-only barang | text | read-only | `SKU-PPR-001` / `Kertas HVS A4 80 gsm`, `Dus`, `0,018 m³` / `31 × 22 × 26,4 cm`, `12,5 kg` | `getByRole('row',{name:/SKU-PPR-001/})` → tid `row-barang-SKU-PPR-001` |
| Jumlah | input number (wajib) | filled `200` / **error `0`** | `Jumlah` | `getByTestId('row-barang-SKU-PPR-001').getByLabel('Jumlah')` → tid `input-jumlah-<sku>` |
| Nilai Barang | input currency (wajib bila asuransi) | filled `Rp 365.000` / ph `Rp 0` / **error** | `Nilai Barang` | `getByTestId('row-barang-<sku>').getByLabel('Nilai Barang')` → tid `input-nilai-barang-<sku>` |
| Hapus baris barang | button ikon tong sampah (merah) | default | — | `getByTestId('row-barang-<sku>').getByRole('button',{name:/hapus/i})` → tid `btn-hapus-barang-<sku>` |
| Pilih Barang | button outline + ikon `+` | default | `Pilih Barang` | `getByTestId('card-unit-1').getByRole('button',{name:'Pilih Barang'})` → tid `btn-pilih-barang-unit-1` |
| Alert kapasitas | pill/alert merah muda | conditional | `Kubikasi melebihi kapasitas armada` \| `Berat melebihi kapasitas armada` | `getByText('Kubikasi melebihi kapasitas armada')` → tid `alert-kapasitas-unit-1` |
| Ringkasan total unit | text | default | `Total Kubikasi: 19,2 / 17,86 m³` • `Total Berat: 19.200 / 24.800 kg` | `getByTestId('card-unit-1').getByText(/^Total Kubikasi:/)` → tid `total-kubikasi-unit-1` / `total-berat-unit-1` |
| Empty state barang | text | **empty** (unit tanpa barang) | `Belum ada barang. Klik "Pilih Barang "` | `getByText(/Belum ada barang\. Klik/)` → tid `empty-state-barang-unit-3` |
| Batal / Sebelumnya / Simpan ke Draf / Selanjutnya | button | default | `Batal`, `Sebelumnya`, `Simpan ke Draf`, `Selanjutnya` | `getByRole('button',{name:'Sebelumnya'})` → tid `btn-sebelumnya` |

**Pesan validasi Step 2 (kutipan persis dari `017.png`):**
- `Nilai Barang harus diisi` (helper error merah di bawah field, border field merah)
- `Jumlah harus diisi` (helper error merah, border field merah)
- Alert kapasitas informatif: `Kubikasi melebihi kapasitas armada`, `Berat melebihi kapasitas armada` — tombol **Selanjutnya tetap aktif** (mendukung VAL-19).

**Catatan penyimpangan:** teks alert memakai kata **"armada"** meskipun pada order **FCL/Kontainer**; demikian pula helper checkbox asuransi (`…pada armada ini`) → **ASM-037**. Varian pesan gabungan ("Kubikasi dan Berat melebihi…") **tidak ditemukan** pada desain.
**Catatan oms014:** **TIDAK ADA** floating button "Hitung Ulang Armada/Kontainer" maupun "Visualisasi Terbaru" pada seluruh capture Step 2 (termasuk capture full-page setinggi 10.008 px pada `004-admin-buat-order-step-2-multipoint.png`) — **ABSEN sesuai harapan**.

### 10. Buat Order — Step 2 Data Barang, Tipe Multi (sumber: `004-admin-buat-order-step-2-multidrop.png`, `004-admin-buat-order-step-2-multipoint.png`, `025.png`, `033.png`, `041.png`)

Struktur sama dengan §9, ditambah **sub-blok per kombinasi alamat** di dalam setiap card unit. Setiap kombinasi punya **Nomor DO, tabel barang, tombol Pilih Barang, alert kapasitas, dan total sendiri** → membuktikan pengisian **manual & independen per kombinasi** (REQ-008, VAL-06, VAL-M7).

| Elemen | Tipe | State | Label/teks persis (contoh) | selectorHint |
|---|---|---|---|---|
| Band kombinasi Multipickup | section header (biru muda) | default | `Pick Up 1 - Jl. Jambi No.35, Darmo, Wonokromo, Kota Surabaya, Jawa Timur 60241` | `getByTestId('card-unit-1').getByRole('region',{name:/^Pick Up 1/})` → tid `combo-unit-1-pickup-1` |
| Band kombinasi Multidrop | section header | default | `Drop Off 2 - Jl. Kalianyar Buring No.9, Buring, Kec. Kedungkandang, Kota Malang, Jawa Timur 65135` | tid `combo-unit-1-dropoff-2` |
| Band kombinasi Multipoint | section header ganda (kiri Pick Up, kanan Drop Off) | default | `Pick Up 2 - …` + `Drop Off 1 - …` | tid `combo-unit-1-pickup-2-dropoff-1` |
| Nomor DO per kombinasi | input chip | filled/empty | `Nomor DO` | `getByTestId('combo-unit-1-pickup-1').getByLabel('Nomor DO')` |
| Pilih Barang per kombinasi | button | default | `Pilih Barang` | `getByTestId('combo-unit-1-pickup-1').getByRole('button',{name:'Pilih Barang'})` |

Jumlah kombinasi terlihat: Multipickup/Multidrop = 2 kombinasi per unit; **Multipoint (2 pick up × 2 drop off) = 4 kombinasi per unit**.
**Catatan oms014:** barang antar kombinasi diisi **manual**; tidak ada indikasi pembagian rata otomatis maupun penempatan sisa ke alamat pertama (REQ-007, VAL-05).

### 11. Modal "Pilih Barang" (sumber: `009.png`)

| Elemen | Tipe | State | Teks persis | selectorHint |
|---|---|---|---|---|
| Dialog | modal | open | judul `Pilih Barang`, subjudul `Pilih barang yang ingin ditambahkan ke order` | `getByRole('dialog',{name:'Pilih Barang'})` → tid `modal-pilih-barang` |
| Pencarian | input search + ikon | empty | ph `Cari kode/nama barang` | `getByPlaceholder('Cari kode/nama barang')` → tid `input-cari-barang` |
| Item barang | checkbox + 2 baris teks | 2 checked, 3 unchecked | `SKU-PPR-001 - Kertas HVS A4 80 gsm` / `Dus • 0,018 m³ • 12,5 kg`; `SKU-PPR-002 - Kertas HVS F4 70 gsm`; `SKU-BKU-001 - Buku Tulis 38 Lembar`; `SKU-BKU-002 - Buku Tulis Hard Cover A5`; `SKU-ATK-001 - Pulpen Gel Hitam 0.5 mm` | `getByRole('checkbox',{name:/SKU-PPR-002/})` → tid `checkbox-barang-SKU-PPR-002` |
| Label sudah ditambahkan | badge | tampil pada barang yang sudah masuk unit | `Sudah Ditambahkan` | `getByRole('listitem').filter({hasText:'SKU-PPR-002'}).getByText('Sudah Ditambahkan')` → tid `badge-sudah-ditambahkan` |
| Counter terpilih | text | `3` | `3 barang terpilih` | `getByText(/\d+ barang terpilih/)` → tid `counter-barang-terpilih` |
| Batal | button outline-danger | default | `Batal` | `getByTestId('modal-pilih-barang').getByRole('button',{name:'Batal'})` → tid `btn-batal-pilih-barang` |
| Simpan | button primary | default | `Simpan` | `getByTestId('modal-pilih-barang').getByRole('button',{name:'Simpan'})` → tid `btn-simpan-pilih-barang` |

### 12. Buat Order — Step 3 Vendor dan Harga, FTL (sumber: `010.png`, `011.png`, `012.png`, `042.png`)

Tiga state terlihat: (a) **empty** (Vendor & Tanggal kosong, Waktu Perjalanan `0`, Total Harga `Rp. 0`), (b) **rute belum ada di master** (input Waktu Perjalanan + alert), (c) **rute sudah ada** (Waktu Perjalanan text-only `8 Jam`).

| Elemen | Tipe | State | Label/teks persis | selectorHint |
|---|---|---|---|---|
| Kartu | card heading | — | `Vendor dan Harga` | `getByRole('heading',{name:'Vendor dan Harga'})` → tid `card-vendor-harga` |
| Vendor | select (wajib) | empty ph `Pilih Vendor` / filled `PT Logistik Transportasi Nusantara` | `Vendor *` | `getByLabel('Vendor')` → tid `select-vendor` |
| Tanggal Permintaan Muat | datetime input (wajib) | empty ph `DD/MM/YYYY hh:mm` / filled `24/07/2026 14:30` | `Tanggal Permintaan Muat *` | `getByLabel('Tanggal Permintaan Muat')` → tid `input-tanggal-permintaan-muat` |
| Ringkasan Drop Point Asal | text read-only / link | default | `Drop Point Asal : Gudang MSK Region 2 • Kota Surabaya` \| `Multipickup` + link `Lihat Detail` | `getByTestId('summary-drop-point-asal')`; link: `getByRole('button',{name:'Lihat Detail'}).first()` → tid `link-lihat-detail-asal` |
| Ringkasan Drop Point Tujuan | text read-only / link | default | `Drop Point Tujuan : Gudang Jaya Retail Malang • Kota Malang` \| `Multidrop` + `Lihat Detail` | tid `link-lihat-detail-tujuan` |
| Jenis Armada | text read-only | default | `Jenis Armada : Tronton Wing Box` | `getByTestId('summary-jenis-armada')` |
| Waktu Perjalanan (rute belum ada) | input number + suffix `Jam` (wajib) | empty `0` / filled `8` | `Waktu Perjalanan *` | `getByLabel('Waktu Perjalanan')` → tid `input-waktu-perjalanan` |
| Alert rute baru | alert warning (oranye) | visible | `Rute belum ada di Master Waktu Perjalanan. Isi waktu perjalanan, nilainya akan otomatis tersimpan sebagai data master baru.` | `getByRole('alert').filter({hasText:'Master Waktu Perjalanan'})` → tid `alert-rute-belum-ada` |
| Waktu Perjalanan (rute sudah ada) | text-only | read-only | `Waktu Perjalanan : 8 Jam` | `getByTestId('text-waktu-perjalanan')` |
| Tabel ringkasan unit | table | default | header `No`, `Nama Item`, `Total Berat`, `Total Kubikasi`, `Total Nilai Barang`; baris `Armada 1` / `Armada 2`; nilai `Tanpa Asuransi` atau `Rp1.150.350.000` | `getByRole('row',{name:/Armada 1/})` → tid `row-ringkasan-unit-1` |
| Harga | input currency (wajib) | ph `Rp 0` / filled `Rp 12.000.000` | `Harga *`, helper `Mencakup seluruh biaya armada pada order ini` | `getByLabel('Harga')` → tid `input-harga` |
| Gunakan komponen harga | checkbox | unchecked / **checked** | `Gunakan komponen harga` | `getByRole('checkbox',{name:'Gunakan komponen harga'})` → tid `checkbox-komponen-harga` |
| PPN / PPh / Asuransi (%) | input number + suffix `%` | filled `1,1` / `2` / `0,2` | `PPN`, `PPh`, `Asuransi` | `getByLabel('PPN')` → tid `input-ppn`, `input-pph`, `input-asuransi` |
| Ringkasan harga | text read-only | default | `Harga DPP`, `PPN (1,1%)`, `PPh (2%)`, `Asuransi (0,2%)`, `(Total Nilai Barang = Rp. 63.620.000)`, `Total Harga` `Rp14.192.700` / `Rp. 0` | `getByTestId('summary-total-harga')`; `getByText('Total Harga')` |
| Aksi | button | default | `Batal`, `Sebelumnya`, `Simpan ke Draf`, `Selanjutnya` | idem §9 |

**Catatan:** baris **`Asuransi (0,2%)`** hanya muncul bila ada unit diasuransikan (`011.png`); bila seluruh unit `Tanpa Asuransi` baris tersebut absen (`012.png`) — mendukung AC-034/AC-035.

### 13. Buat Order — Step 3 Vendor dan Harga, FCL (sumber: `018.png`, `026.png`, `034.png`)

Identik dengan §12 **kecuali**: ringkasan menampilkan `Jenis Kontainer : 20 DRY`, baris tabel `Kontainer 1`/`Kontainer 2`, dan **TIDAK ADA field/teks "Waktu Perjalanan"** sama sekali.

| Elemen | Tipe | State | Teks persis | selectorHint |
|---|---|---|---|---|
| Jenis Kontainer (ringkasan) | text read-only | default | `Jenis Kontainer : 20 DRY` | `getByTestId('summary-jenis-kontainer')` |
| Waktu Perjalanan | — | **ABSEN** | — | assert `getByText('Waktu Perjalanan')` **hidden** (mendukung AC-033) |

### 14. Step 3 — Pop Up "Detail Multipickup" / "Detail Multidrop" (sumber: `027.png`, `035.png`, `043.png`, `044.png`, `008-admin-buat-order-step-3-multidrop-default-data-sudah-ada.png`, `008-admin-buat-order-step-3-multipoint-default-data-sudah-ada.png`)

| Elemen | Tipe | State | Teks persis | selectorHint |
|---|---|---|---|---|
| Dialog | modal | open | `Detail Multipickup` / `Detail Multidrop` | `getByRole('dialog',{name:'Detail Multipickup'})` → tid `modal-detail-multipickup` |
| Tutup | button ikon `X` | default | — | `getByTestId('modal-detail-multipickup').getByRole('button',{name:/tutup|close/i})` |
| Item titik | link + text | default | `Pick Up 1 - Kota Surabaya` / `Gudang MSK Region 2:` / `Jl. Jambi No.35, Darmo, Wonokromo, Kota Surabaya, Jawa Timur 60241`; `Drop Off 2 - Kab. Lampung Tengah` | `getByText('Pick Up 2 - Kota Malang')` → tid `detail-point-2` |

**Varian desain alternatif:** pada `027/035/043/044.png` latar Step 3 memperlihatkan checkbox **`Simpan data ke master harga`** dan section **`Kalkulasi Harga`** (menggantikan `Gunakan komponen harga`) → **ASM-038**.

### 15. Buat Order — Step 4 Review (sumber: `013.png`, `019.png`, `028.png`, `036.png`, `045.png`, `009-admin-buat-order-step-4-multipoint.png`)

Seluruh data Step 1–3 tampil **read-only** dalam kartu collapsible.

| Elemen | Tipe | State | Label/teks persis | selectorHint |
|---|---|---|---|---|
| Stepper | stepper | step 01–03 **checked (✓)**, 04 aktif | `04 Review` | `getByTestId('step-4-review')` |
| Kartu collapsible | card + chevron | expanded | `Jenis Pengiriman dan Rute`, `Data Pengirim`, `Data Penerima`, `Data Barang`, `Vendor dan Harga` | `getByRole('button',{name:'Data Barang'})` → tid `card-review-data-barang` |
| Ringkasan rute | definition list read-only | default | `Jenis Pengiriman : FTL (Full Truck Load)` \| `FCL (Full Container Load)`, `Jenis Armada : Tronton Wing Box` \| `Jenis Kontainer : 20ft Dry Box`/`20 DRY`, `Jumlah Armada : 2`, `Pelabuhan Asal : Tanjung Perak (SUB)`, `Pelabuhan Tujuan : Panjang (PNJ)`, `Tipe Pengiriman : Normal`/`Multipickup`/`Multidrop`/`Multipoint`, `Waktu Perjalanan : 8 Jam` (FTL) | `getByTestId('review-jenis-pengiriman')` |
| Blok unit | section | default | `Armada 1`, `Armada 2`, `Kontainer 1`, `Kontainer 2` | `getByTestId('review-unit-2')` |
| Badge diasuransikan | badge | tampil hanya pada unit berasuransi | `Diasuransikan` | `getByTestId('review-unit-2').getByText('Diasuransikan')` → tid `badge-diasuransikan` |
| Nomor DO (review) | text read-only | filled / kosong | `TBL67827879232, TBL726378927398` atau `-` | `getByTestId('review-unit-1').getByText(/TBL/)` |
| Tabel barang (review) | table read-only | default | `Kode SKU`/`Nama Barang`, `Kemasan`, `Kubikasi`/`Dimensi`, `Berat`, `Jumlah`, `Nilai Barang` | `getByTestId('review-unit-2').getByRole('row',{name:/SKU-BKU-003/})` |
| Ringkasan vendor & harga | table + text | default | `No`, `Nama Item`, `Total Berat`, `Total Kubikasi`, `Total Nilai Barang`; `Vendor : PT Logistik Transportasi Nusantara`; `Tanggal Permintaan Muat : 24/07/2026 14:30`; `Harga DPP`, `PPN (1,1%)`, `PPh (2%)`, `Asuransi (0,2%)`, `(Total Nilai Barang = Rp1.006.750.000)`, `Total Harga Rp13.905.500` | `getByTestId('review-total-harga')` |
| Aksi | button | default | `Batal`, `Sebelumnya`, `Simpan ke Draf`, **`Simpan`** | `getByRole('button',{name:'Simpan',exact:true})` → tid `btn-simpan-order` |

**Catatan oms014:** pada card **Data Barang** Step 4 **tidak ada** button pemicu pop up visualisasi muatan maupun indikator/bar keterisian — **ABSEN sesuai REQ-029 / VAL-07 / AC-051**.

### 16. Detail Order (sumber: `020.png`, `021.png`, `029.png`, `037.png`, `046.png`, `009-admin-detail-order-multidrop.png`)

| Elemen | Tipe | State | Label/teks persis | selectorHint |
|---|---|---|---|---|
| Tombol kembali | button ikon `‹` | default | — | `getByRole('button',{name:/kembali|back/i})` → tid `btn-kembali` |
| Judul | heading h1 | default | `Detail Order` | `getByRole('heading',{name:'Detail Order'})` |
| Batalkan Order | button outline-danger | tampil pada status Menunggu Penugasan & Ditugaskan | `Batalkan Order` | `getByRole('button',{name:'Batalkan Order'})` → tid `btn-batalkan-order` |
| Edit Order | button outline-primary | tampil (status Menunggu Penugasan) | `Edit Order` | `getByRole('button',{name:'Edit Order'})` → tid `btn-edit-order` |
| Status order | badge/link kanan-atas kartu pertama | `Menunggu Penugasan` (`020`), `Ditugaskan` (`021`, `037`, `046`) | idem | `getByTestId('badge-status-detail')` |
| Identitas order | definition list read-only | default | `ID Order : ORD67890792`, `Tanggal Dibuat : 26/06/2026 08:17` | `getByTestId('detail-id-order')` |
| Kartu isi | card collapsible | expanded | `Jenis Pengiriman dan Rute`, `Data Pengirim`, `Data Penerima`, `Data Barang`, `Vendor dan Harga` | idem §15 |
| Waktu Perjalanan (FCL, status Ditugaskan) | text read-only | tampil hanya pada `021.png` (Ditugaskan) | `Waktu Perjalanan : 8 Jam` | `getByTestId('detail-waktu-perjalanan')` (mendukung AC-033) |

**Catatan oms014:** Detail Order **tidak memuat** elemen visualisasi/keterisian Auto Stuffing — **ABSEN sesuai REQ-031 / VAL-08 / AC-053**.

### 17. Edit Order (sumber: `022.png`, `030.png`, `038.png`, `047.png`, `013-admin-edit-order-multidrop.png`, `013-admin-edit-order-multipoint.png`)

Form satu halaman (bukan wizard) berisi seluruh kartu Step 1–3.

| Elemen | Tipe | State | Label/teks persis | selectorHint |
|---|---|---|---|---|
| Judul | heading h1 | default | `Edit Order` | `getByRole('heading',{name:'Edit Order'})` |
| Field terkunci | text read-only (tanpa input) | **locked** | `ID Order`, `Tanggal Dibuat`, `Jenis Pengiriman : FCL (Full Container Load)`, `Tipe Pengiriman : Normal`/`Multipickup`/`Multidrop`/`Multipoint`, `Skema Pengiriman : Door to Door`, `Waktu Perjalanan : 8 Jam` | assert **bukan** editable: `expect(getByTestId('edit-tipe-pengiriman')).not.toBeEditable()` |
| Field editable rute | select/input | filled | `Pelabuhan Asal *`, `Pelabuhan Tujuan *`, `Jenis Kontainer *` (`20ft  Dry Box`), `Jumlah Kontainer *` | `getByLabel('Jumlah Kontainer')` |
| Data Pengirim / Penerima | input editable | filled | idem §6 | idem |
| Tambah Baris Input | button | default (tipe multi) | `Tambah Baris Input` | tid `btn-tambah-baris-input` |
| Kartu barang per unit | card collapsible | expanded | `Data Barang - Kontainer 1`, `Data Barang - Kontainer 2` | `getByRole('button',{name:'Data Barang - Kontainer 2'})` → tid `card-edit-unit-2` |
| Elemen Step 2 di dalamnya | checkbox/chip/tabel/tombol/alert | idem §9–§10 | `Tambahkan Asuransi`, `Nomor DO`, `Pilih Barang`, `Kubikasi melebihi kapasitas armada`, `Total Kubikasi: … • Total Berat: …` | idem §9 |
| Vendor dan Harga | card | filled | idem §12 | idem |
| Batal | button outline-danger | default | `Batal` | `getByRole('button',{name:'Batal'})` → tid `btn-batal-edit` |
| Simpan | button primary | default | `Simpan` | `getByRole('button',{name:'Simpan'})` → tid `btn-simpan-edit` |

**Catatan oms014:** halaman Edit Order **tidak menampilkan** floating button/panel hitung ulang — **ABSEN sesuai AC-044**.

### 18. Layar/komponen yang TIDAK tersedia PNG-nya (asumsi selector)

Tidak ada desain untuk: pop up konfirmasi **Batal**/**Simpan** (REQ-026/VAL-29), pop up **Pembatalan Order** + field `Alasan Pembatalan` (REQ-027), halaman **Riwayat Pembatalan**, **Riwayat Perubahan**, **Batch Order**, dan konfigurasi **toggle Auto Stuffing** (REQ-034). Selector berikut bersifat **asumsi** (**ASM-039**):

| Elemen | selectorHint (asumsi) |
|---|---|
| Dialog konfirmasi | `getByRole('dialog')` → tid `modal-konfirmasi`; aksi `getByRole('button',{name:/ya|konfirmasi|simpan/i})` / `{name:/tidak|batal/i}` |
| Alasan Pembatalan | `getByLabel('Alasan Pembatalan')` → tid `textarea-alasan-pembatalan` |
| Submit pembatalan | `getByRole('button',{name:/batalkan order|konfirmasi/i})` → tid `btn-submit-pembatalan` |
| Toggle Auto Stuffing (admin sistem) | `getByRole('switch',{name:/auto stuffing/i})` → tid `toggle-auto-stuffing` |

### Ringkasan Selector Global

Pola yang **konsisten di seluruh layar** — jadikan basis Page Object:

| Pola | Selector rekomendasi | Berlaku pada |
|---|---|---|
| Navigasi sidebar | `getByRole('link',{name:'<Label>'})` | semua layar |
| Judul halaman | `getByRole('heading',{level:1,name:'<Judul>'})` — `Daftar Order`, `Buat Order`, `Detail Order`, `Edit Order` | semua layar |
| Breadcrumb | `getByRole('link',{name:'Daftar Order'})` untuk kembali ke list | Buat/Detail/Edit |
| Stepper wizard | `getByTestId('step-<n>-<slug>')`; step selesai ditandai ikon ✓, step aktif ditandai nomor pada lingkaran biru | Step 1–4 |
| Tombol navigasi wizard (footer, urutan tetap kiri→kanan) | kiri: `getByRole('button',{name:'Batal'})`; kanan: `Sebelumnya` → `Simpan ke Draf` → `Selanjutnya`/`Simpan` | Step 1–4 |
| Tombol simpan akhir | Step 4 memakai `Simpan` (bukan `Selanjutnya`); Edit Order memakai `Simpan` | Step 4, Edit |
| Kartu section | `getByRole('heading',{name:'<Nama Kartu>'})` lalu naik ke container, atau tid `card-<slug>` | Step 1–4, Detail, Edit |
| Field wajib | label diakhiri tanda `*` merah → `getByLabel(/^<Label>/)` | semua form |
| Field read-only auto-draft | latar abu + teks abu (Provinsi/Kota/Kecamatan/Desa/Kode Pos/Alamat) | Step 1, Edit |
| Helper text | teks abu kecil di bawah field (`Nama PIC Pengirim`, `Contoh: 081234567898`, `Pisahkan dengan koma untuk menambahkan beberapa nomor`, `Mencakup seluruh biaya armada pada order ini`) | Step 1–3 |
| Helper error | teks **merah** di bawah field + border merah (`Jumlah harus diisi`, `Nilai Barang harus diisi`) | Step 2 |
| Alert | `getByRole('alert')` — biru info (`Pastikan urutan pengiriman sudah sesuai saat membuat shipment`), oranye warning (`Rute belum ada di Master Waktu Perjalanan…`), pill merah (`… melebihi kapasitas armada`) | Step 1–3 |
| Unit card | tid `card-unit-<n>`, judul `Armada <n>` / `Kontainer <n>` | Step 2, Review, Detail, Edit |
| Kombinasi alamat (tipe multi) | band `Pick Up <n> - <alamat>` / `Drop Off <n> - <alamat>` → tid `combo-unit-<n>-<slug>` | Step 2 multi |
| Modal | `getByRole('dialog',{name:'<Judul Modal>'})`; tombol tutup ikon `X`; footer `Batal` + `Simpan` | Pilih Barang, Detail Multipickup/Multidrop, Data No. Perjalanan |
| Tabel data | `getByRole('table')` + `getByRole('row',{name:/<kunci>/})`; header 2 baris (`Kode SKU`/`Nama Barang`) | Daftar Order, Step 2/3/4, Detail, Edit |
| Ikon aksi baris | tong sampah merah = hapus → `getByRole('button',{name:/hapus/i})`; kebab `...` = menu aksi | Step 1/2, Daftar Order |
| Badge status | `getByTestId('badge-status')`; nilai lihat §1 | Daftar Order, Detail |
| **Negative assertion oms014** | `await expect(page.getByRole('button',{name:/Hitung Ulang (Armada\|Kontainer)/i})).toHaveCount(0)`; `…{name:/Visualisasi Terbaru/i}…toHaveCount(0)`; `page.getByTestId(/visualisasi\|keterisian\|stuffing/)` → `toHaveCount(0)` | Step 2, Step 4, Detail, Edit |

---

## Assumptions Log

| ID | Konteks / Ambiguitas | Keputusan yang Diambil | Dampak bila Salah |
|---|---|---|---|
| ASM-001 | Spec oms014 hanya berisi rule **selisih** dan merujuk "Seluruh rule Order FTL & FCL OMS standar" tanpa merincinya (Baris 9). | Rule standar diwarisi dan dijabarkan dari **oms012 (FTL)** dan **oms013 (FCL)** sebagai baseline resmi (REQ-009 s.d. REQ-028). | Bila baseline sebenarnya berbeda, REQ-009 s.d. REQ-028 perlu disesuaikan; REQ-001 s.d. REQ-008 & REQ-029 s.d. REQ-037 tetap valid. |
| ASM-002 | Spec menulis "Armada/Kontainer" secara gabungan. | Dipetakan: **FTL → Armada**, **FCL → Kontainer**. Seluruh label, pesan alert, dan istilah UI mengikuti jenis order aktif. | Label/pesan uji bisa salah kata bila sistem memakai istilah generik. |
| ASM-003 | Judul modul "normal" ambigu — bisa berarti tipe pengiriman **Normal** saja atau **order normal (tanpa Auto Stuffing)**. | Diartikan sebagai **order normal = tanpa Auto Stuffing**, mencakup **keempat** tipe pengiriman (Normal, Multipickup, Multidrop, Multipoint) sesuai Baris 1. | Bila hanya tipe Normal, UF-03 dan AC-007 menjadi out-of-scope. |
| ASM-004 | Spec tidak menyebut **siapa** yang mengelola toggle Auto Stuffing (Baris 18). | Toggle dikelola **Admin Sistem/Super Admin** pada level konfigurasi add-on/tenant, **tidak** tampil bagi Admin Shipper; QA memiliki akses pada lingkungan uji. | Bila toggle ada di UI shipper, perlu tambahan REQ & AC untuk kontrol dan hak aksesnya. |
| ASM-005 | Spec tidak menyebut cakupan & sifat toggle (per tenant/global, runtime/deploy). | Toggle bersifat **runtime, level tenant/lingkungan**, dapat dinyalakan-matikan tanpa deploy ulang. | Bila butuh deploy ulang, VAL-36 & AC-059 tidak dapat diuji sebagaimana ditulis. |
| ASM-006 | Spec hanya menyebut floating button "tidak ditampilkan", tidak menyebut drawer/panelnya. | Drawer "Hitung Ulang" & panel "Visualisasi Terbaru" **juga tidak dapat diakses** (termasuk via deep-link), karena merupakan turunan langsung. | Bila panel masih dapat diakses melalui jalur lain, VAL-03 & AC-005 gugur. |
| ASM-007 | Spec tidak merinci "minimal baris per tipe pengiriman". | Multipickup: **≥ 2 pengirim**; Multidrop: **≥ 2 penerima**; Multipoint: **≥ 2 pengirim & ≥ 2 penerima**; Normal: 1 & 1. | Angka minimal berbeda → AC-012 perlu penyesuaian. |
| ASM-008 | Batas nilai field **Jumlah** tidak disebut. | **Bilangan bulat positif ≥ 1**; nilai 0/negatif/desimal ditolak. | Bila desimal diizinkan, aturan validasi perlu revisi. |
| ASM-009 | Batas nilai **Nilai Barang** tidak disebut. | Harus **> 0** saat asuransi aktif; format mata uang id-ID. | Bila 0 diizinkan, VAL-15 perlu revisi. |
| ASM-010 | Batas **Jumlah Armada/Kontainer** tidak disebut. | Bilangan bulat **≥ 1**. Batas atas mengikuti kebijakan sistem (tidak diuji sebagai blocker). | Bila ada batas maksimum, perlu AC tambahan. |
| ASM-011 | Aturan **Tanggal Permintaan Muat** tidak dirinci. | Tanggal **≥ hari ini** (tidak boleh masa lalu). | Bila backdate diizinkan, aturan Step 3 perlu revisi. |
| ASM-012 | Default state checkbox "Tambahkan Asuransi" tidak disebut. | Default **tidak tercentang**. | Bila default tercentang, AC-020 gugur. |
| ASM-013 | Perilaku label "Sudah Ditambahkan" tidak dirinci (apakah memblokir pemilihan ulang). | Label bersifat **informatif**; barang tetap dapat dipilih/dilepas. | Bila memblokir, VAL-M4 & AC-016 perlu revisi. |
| ASM-014 | Filter data pada modal "Pilih Barang" tidak disebut. | Hanya barang berstatus **Aktif** milik tenant terkait yang tampil. | Bila barang nonaktif ikut tampil, VAL-M1 gugur. |
| ASM-015 | Teks pesan alert kapasitas pada oms014 tidak dikutip ulang. | Mengikuti baseline: kata unit menyesuaikan jenis order — **"armada"** untuk FTL, **"kontainer"** untuk FCL, dengan 3 varian kondisi. | Bila sistem memakai satu kata generik, VAL-20 & AC-024/025/026 perlu penyesuaian teks. |
| ASM-016 | Spec menyebut "Data Unit" informatif tanpa hitung ulang, namun tidak menjelaskan cara mengubah jumlah unit. | Perubahan Jenis/Jumlah unit **hanya** dapat dilakukan di **Step 1**; Data Unit di Step 2 sepenuhnya read-only. Perubahan jumlah unit menambah/mengurangi card, dan barang pada card yang hilang **tidak dipindahkan otomatis**. | Bila Step 2 menyediakan edit inline, VAL-22 & AC-030 perlu revisi. |
| ASM-017 | Spec tidak menyebut apakah setiap armada/kontainer wajib memiliki minimal 1 barang saat Auto Stuffing mati. | Diasumsikan **wajib minimal 1 barang per armada/kontainer** (mengikuti rule Step 2 standar; alert "min 1 barang" ada pada baseline oms011) sebelum dapat lanjut ke Step 3. | Bila unit boleh kosong, UF-01.A12, UF-03.A3, dan skenario terkait menjadi positif (bukan penolakan). |
| ASM-018 | Perbedaan Step 1 FTL vs FCL tidak diulang pada spec oms014. | Mengikuti baseline oms013: FCL memiliki **Pelabuhan Asal & Tujuan**, **tanpa Metode Pengiriman**, dan Pelabuhan Asal ≠ Tujuan. | Bila FCL tetap memuat Metode Pengiriman, AC-010 perlu penyesuaian. |
| ASM-019 | Perbedaan Waktu Perjalanan FTL vs FCL tidak diulang pada spec oms014. | FTL: textfield bila rute belum ada di master / text-only bila sudah ada. FCL: tanpa input, `ETA − ETD + 4 hari`, tampil saat status "Ditugaskan". | Perilaku tertukar → VAL-24, AC-032, AC-033 perlu revisi. |
| ASM-020 | Spec **tidak** memuat acceptance criteria eksplisit. | Seluruh AC-001 s.d. AC-060 diturunkan dari requirement dengan format Given/When/Then. | AC perlu direview stakeholder sebelum dipakai sebagai basis sign-off. |
| ASM-021 | Spec menyebut Step 4 "tidak menampilkan elemen turunan Auto Stuffing". | Diartikan **button pemicu visualisasi pun tidak ada** (bukan sekadar disabled/pop up kosong), termasuk indikator keterisian. | Bila button tetap ada dalam kondisi disabled, VAL-07 & AC-051 perlu direlaksasi. |
| ASM-022 | Spec tidak menyatakan apakah struktur Data Barang di Review tetap sama dengan baseline. | Struktur Data Barang **tetap mengikuti Step 2** (kolom lengkap + label "Diasuransikan"); yang hilang **hanya** elemen Auto Stuffing. | Bila struktur Review berbeda, REQ-032 & AC-054 perlu revisi. |
| ASM-023 | "Basis komponen tetap sama" (Baris 19) tidak dijelaskan implikasinya pada QA. | Diuji sebagai: tidak ada halaman/route duplikat, dan penghilangan elemen tidak menimbulkan ruang kosong, layout pecah, atau error console. | Bila hanya pernyataan arsitektural internal, AC-060 bersifat informatif saja. |
| ASM-024 | Spec oms014 tidak menyebut dukungan **batch order**. | Dukungan batch order **tetap berlaku** karena termasuk rule standar (Baris 9). | Bila batch tidak didukung tanpa Auto Stuffing, UF-01.A13 out-of-scope. |
| ASM-025 | Hak akses **Staff Operasional Shipper** tidak disebut spec. | Diasumsikan memiliki hak setara Admin Shipper untuk pembuatan/pengisian order; hak pembatalan mengikuti kebijakan tenant. | Bila role ini tidak ada, baris terkait pada matriks role dihapus. |
| ASM-026 | Modul memiliki folder `designs/` berisi ±60 file, namun bagian **UI Inventory** dikecualikan dari tugas tahap ini. | Bagian **## UI Inventory** dibiarkan **kosong** sebagai placeholder untuk agent berikutnya. | Tidak ada; by design. |
| ASM-027 | Spec tidak mencantumkan prioritas requirement. | Prioritas ditetapkan analis: seluruh rule fungsional & negatif = **Must**; REQ-037 (basis komponen/no-regression layout) = **Should**. | Prioritas perlu konfirmasi PO sebelum perencanaan rilis. |
| ASM-028 | Format & panjang **Nomor DO** tidak dirinci. | Teks bebas, multi-nilai dipisahkan **koma**, dirender sebagai chip; tanpa batas panjang eksplisit dan tanpa validasi format. | Bila ada pola/panjang maksimum, aturan Step 2 perlu ditambah. |
| ASM-029 | Teks pesan error untuk field wajib tidak dikutip pada spec. | Diuji secara **generik**: helper error tampil + border berubah warna error (teks tidak di-assert secara literal, kecuali pesan alert kapasitas yang sudah eksplisit di baseline). | Bila teks spesifik disyaratkan, AC-019 perlu penambahan assertion teks. |
| ASM-030 | Spec tidak menjelaskan nasib order yang **sudah** dibuat dengan Auto Stuffing ketika toggle kemudian dimatikan. | Data penempatan hasil Auto Stuffing **tidak dihapus**; tampilan mengikuti kondisi toggle **saat halaman dibuka** (elemen visualisasi disembunyikan), dan tidak dapat dihitung ulang. | Bila sistem melakukan migrasi/normalisasi data, UF-00.A3 & UF-06.A3 perlu revisi. |
| ASM-031 | Nama file PNG tidak konsisten dengan isi layar (mis. `003-admin-daftar-order-multidrop.png` berisi Step 1 Buat Order; `008-admin-buat-order-step-3-*-sudah-ada.png` berisi modal Detail Multipickup/Multidrop). | Penamaan layar pada UI Inventory mengikuti **konten visual**, bukan nama file; nama file tetap dicantumkan sebagai referensi sumber. | Bila penamaan file dianggap otoritatif, pemetaan layar ↔ file perlu direvisi. |
| ASM-032 | Perlu bukti visual bahwa elemen Auto Stuffing benar-benar tidak ada. | Setelah menelaah **60/60 PNG** (termasuk capture full-page Step 2 setinggi 10.008 px), **tidak ditemukan** floating button "Hitung Ulang Armada/Kontainer", "Visualisasi Terbaru", drawer/panel hitung ulang, visualisasi muatan, indikator keterisian, label "Paling Efisien", maupun button "Terapkan ke Order". Absennya elemen dijadikan **baseline visual** untuk VAL-01, VAL-02, VAL-03, VAL-07, VAL-08. | Bila build ternyata menampilkan elemen tersebut, itu **cacat**, bukan kekurangan desain. |
| ASM-033 | REQ-019 mensyaratkan informasi **"Data Unit"** tampil pada Step 2, namun **tidak ada card/section bernama "Data Unit"** pada desain Step 2 manapun. Beberapa desain juga menandai nav aktif `Penugasan Tracking` alih-alih `Order`. | Informasi unit dianggap terwakili oleh **judul card unit** (`Armada 1..N` / `Kontainer 1..N`) yang jumlahnya = Jumlah Armada/Kontainer Step 1; VAL-22/AC-029 diuji lewat **jumlah & jenis card unit**, bukan komponen bernama "Data Unit". Nav aktif yang salah diperlakukan sebagai **artefak desain**, bukan requirement. | Bila implementasi menambahkan card "Data Unit" eksplisit, selector `card-data-unit` perlu ditambahkan; bila nav aktif memang `Penugasan Tracking`, assertion navigasi perlu disesuaikan. |
| ASM-034 | Label status pada desain berbeda dari REQ-023: desain memakai **`Isi Data Dasar`** (spec: "Isi Data Pengiriman") dan **`Terkirim`** (spec: "Selesai"). | Assertion UI memakai **teks desain** (`Isi Data Dasar`, `Terkirim`); teks spec diperlakukan sebagai nama status logis. | Bila implementasi memakai teks spec, assertion status pada Daftar Order & Detail Order gagal dan perlu disesuaikan. |
| ASM-035 | Menu aksi baris pada `83.png` memuat aksi **`Order Kembali`** yang tidak disebut REQ-028. | `Order Kembali` dicatat sebagai aksi tambahan yang **boleh ada**; VAL-31 diuji sebagai "aksi wajib harus ada", bukan "tidak boleh ada aksi lain". | Bila daftar aksi harus eksak, VAL-31/AC-048 perlu menambahkan `Order Kembali`. |
| ASM-036 | FCL tipe **Normal** (`015/016.png`) **tidak** menampilkan Metode Pengiriman, sedangkan FCL tipe **multi** (`024/031/040.png`) menampilkan **`Metode Pengiriman *`** (Door to Door / Door to CY / CY to CY / CY to Door); pada Edit Order field yang sama dinamai **`Skema Pengiriman`**. | **ASM-018 direvisi**: field metode/skema pengiriman **ADA** pada OMS untuk FCL (minimal pada tipe multi) dan bersifat **locked saat Edit Order**. Ketersediaan field diuji **per tipe pengiriman**, tidak diasumsikan absen. | Bila field seharusnya selalu absen (atau selalu ada), REQ-010, ASM-018, dan AC-010 perlu direvisi ulang. |
| ASM-037 | Teks alert kapasitas dan helper checkbox asuransi memakai kata **"armada"** meskipun pada order **FCL** (card `Kontainer N`): `Kubikasi melebihi kapasitas armada`, `Berlaku untuk seluruh barang pada armada ini`. Varian pesan gabungan ("Kubikasi dan Berat melebihi…") tidak ditemukan pada desain. | Assertion memakai **teks literal desain** (kata "armada" untuk kedua jenis order); ASM-015 direlaksasi — perbedaan kata unit **tidak** dijadikan kriteria gagal, namun dicatat sebagai **temuan copywriting**. | Bila copy diperbaiki menjadi "kontainer" untuk FCL, assertion teks perlu diparametrikkan per jenis order. |
| ASM-038 | Terdapat **dua varian desain Step 3**: (a) checkbox `Gunakan komponen harga` + input PPN/PPh/Asuransi (`010–012`, `026`, `042`), dan (b) checkbox `Simpan data ke master harga` + section `Kalkulasi Harga` (`027`, `035`, `043`, `044`). | Varian **(a)** dipakai sebagai **baseline** karena muncul pada mayoritas capture dan sesuai REQ-020/REQ-021; varian (b) dicatat sebagai desain alternatif/iterasi lain. | Bila varian (b) yang diimplementasikan, REQ-020, AC-031, dan selector Step 3 perlu direvisi. |
| ASM-039 | Tidak tersedia PNG untuk pop up konfirmasi Batal/Simpan, pop up Pembatalan Order (`Alasan Pembatalan`), Riwayat Pembatalan, Riwayat Perubahan, Batch Order, dan konfigurasi toggle Auto Stuffing. | Selector untuk elemen tersebut **diturunkan sebagai asumsi** (lihat UI Inventory §18) dan ditandai untuk diverifikasi ulang saat build tersedia. | Selector asumsi berpotensi tidak cocok → test terkait REQ-026, REQ-027, REQ-034 perlu penyesuaian selector. |
| ASM-040 | Desain **tidak memuat** atribut `data-testid`. | Seluruh nilai `tid` pada UI Inventory adalah **usulan kebab-case** yang harus ditambahkan tim FE; prioritas selector tetap `getByRole` → `getByLabel` → `getByPlaceholder` → `getByTestId` → `getByText`. | Bila FE memakai konvensi testid berbeda, seluruh fallback `getByTestId` perlu dipetakan ulang. |

