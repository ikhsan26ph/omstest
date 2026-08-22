# Analysis — oms013-order-fcl-auto-stuffing

> Sumber spesifikasi: `inputs/oms013-order-fcl-auto-stuffing/spec.txt`
> Tahap: 1 — Requirements Extraction
> Tanggal analisis: **2026-08-19**
> Mode: AUTO (keputusan ambigu diambil sendiri dan dicatat di **Assumptions Log**)

---

## Ringkasan Modul

Modul ini menjelaskan **proses pengisian data order jenis FCL pada OMS yang memiliki add-on Auto Stuffing**, untuk seluruh tipe pengiriman: **Normal, Multipickup, Multidrop, dan Multipoint**.

Karakteristik utama:

| Aspek | Perilaku |
|---|---|
| Basis rule | Mengacu penuh pada spesifikasi **Order FCL di TMS** (4 step wizard) |
| Satuan unit | **Kontainer** (bukan Armada seperti pada FTL/oms012) |
| Perbedaan inti | **Step 2 — Data Barang** diambil dari **Master Barang**, bukan input deskripsi manual |
| Penyesuaian OMS | **Metode Pengiriman tidak diperlukan** pada Step 1 |
| Waktu Perjalanan | FCL **tidak memiliki input** waktu perjalanan → dihitung `ETA − ETD + 4 hari`, tampil saat status **Ditugaskan** |
| Add-on Auto Stuffing | Penambahan **button visualisasi muatan** pada card Data Barang di Step 4 → membuka **pop up visualisasi** |

Alur wizard: **Step 1 Data Pengiriman → Step 2 Data Barang → Step 3 Vendor & Harga → Step 4 Review**.

---

## Requirements

### A. Ketentuan Umum Order FCL (OMS)

| ID | Deskripsi | Sumber (baris/section) | Prioritas |
|---|---|---|---|
| REQ-001 | Modul mencakup proses pengisian data order untuk tipe pengiriman **Normal, Multipickup, Multidrop, dan Multipoint** pada jenis order **FCL** yang di dalamnya terdapat **Auto Stuffing**. | Baris 1 — Intro | Must |
| REQ-002 | Sistem secara keseluruhan mengacu pada spesifikasi **Order FCL di TMS**: definisi FCL, **satuan Kontainer**, **4 step pengisian** (Data Pengiriman, Data Barang, Vendor & Harga, Review), serta dukungan **input manual maupun batch order**. | Baris 4 — Ketentuan Umum #1 | Must |
| REQ-003 | Perbedaan utama terhadap TMS **hanya pada Step 2 (Data Barang)**: data barang diambil dari **Master Barang**, bukan input deskripsi manual. | Baris 5 — Ketentuan Umum #2 | Must |
| REQ-004 | Penyesuaian turunan pada **Step 4 (Review)**: informasi Data Barang mengikuti **struktur Step 2**, dan terdapat informasi **visualisasi muatan berupa pop up** yang tampil saat klik button **"Visualisasi Muatan"**. | Baris 6 — Ketentuan Umum #3 | Must |

### B. Step 1 — Data Pengiriman

| ID | Deskripsi | Sumber (baris/section) | Prioritas |
|---|---|---|---|
| REQ-005 | Step 1 **identik dengan Step 1 Order FCL di TMS**, memuat field: **Pelabuhan Asal**, **Pelabuhan Tujuan**, **Jenis Kontainer**, **Jumlah Kontainer**, **Tipe Pengiriman** (Normal / Multipickup / Multidrop / Multipoint), **Data Pengirim** & **Data Penerima**. | Baris 9 — Step 1 #1 | Must |
| REQ-006 | **Data Pengirim & Data Penerima auto-draft dari Master Droppoint**. | Baris 9 — Step 1 #1 | Must |
| REQ-007 | Berlaku **rule cascading** dan **minimal baris per tipe pengiriman** sesuai TMS (mis. Multipickup ≥ 2 pengirim, Multidrop ≥ 2 penerima, Multipoint ≥ 2 pengirim & ≥ 2 penerima — lihat ASM-004). | Baris 9 — Step 1 #1 | Must |
| REQ-008 | **Validasi field wajib** dan **fungsi button (Batal / Draf / Selanjutnya)** pada Step 1 berlaku **identik dengan TMS**. | Baris 9 — Step 1 #1 | Must |
| REQ-009 | Field **Metode Pengiriman tidak diperlukan pada OMS** (tidak ditampilkan), karena pada penugasan tracking hanya dibutuhkan step **"Selesai Muat"** dan **"Selesai Bongkar"**. | Baris 10 — Step 1 #2 | Must |

### C. Step 2 — Data Barang (Modal "Pilih Barang")

| ID | Deskripsi | Sumber (baris/section) | Prioritas |
|---|---|---|---|
| REQ-010 | Berbeda dengan TMS: barang **tidak diinput manual**, melainkan **dipilih dari Master Barang** melalui modal **"Pilih Barang"**. | Baris 13 — Step 2 #1 | Must |
| REQ-011 | Modal "Pilih Barang" menyediakan **pencarian by kode barang / nama barang**. | Baris 15 — Step 2 #2 | Must |
| REQ-012 | Pemilihan barang dapat **multi-select** menggunakan **checkbox**. | Baris 16 — Step 2 #2 | Must |
| REQ-013 | Terdapat label **"Sudah Ditambahkan"** pada barang yang sudah masuk ke **kontainer terkait** (kontekstual per kontainer). | Baris 17 — Step 2 #2 | Must |
| REQ-014 | Terdapat **counter jumlah barang terpilih** pada modal. | Baris 18 — Step 2 #2 | Must |
| REQ-015 | Modal menyediakan button **Batal** & **Simpan**. | Baris 19 — Step 2 #2 | Must |
| REQ-016 | Field berikut **auto ter-draft dari Master Barang** dan bersifat **read-only**: **Kode SKU, Nama Barang, Kemasan, Kubikasi, Dimensi, Berat**. | Baris 20 — Step 2 #4 | Must |
| REQ-017 | Field **Jumlah** diinput user per baris barang dan bersifat **wajib diisi**. | Baris 22 — Step 2 #5 | Must |
| REQ-018 | Field **Nilai Barang** **hanya muncul** dan **wajib diisi** saat checkbox **"Tambahkan Asuransi"** pada armada/kontainer tersebut dicentang. | Baris 23 — Step 2 #5 | Must |
| REQ-019 | Checkbox **"Tambahkan Asuransi"** bersifat **per armada/kontainer** dan berlaku untuk **seluruh barang** pada unit tersebut; saat dicentang kolom **Nilai Barang tampil dan menjadi wajib**. | Baris 24 — Step 2 #6 | Must |
| REQ-020 | **Nomor DO per armada/kontainer**: **tidak wajib**, dapat diisi **lebih dari satu**, **dipisahkan dengan koma**, dan **ditampilkan sebagai chip**. | Baris 25 — Step 2 #7 | Must |
| REQ-021 | Setiap baris barang dapat **dihapus** melalui **icon hapus**. | Baris 26 — Step 2 #8 | Must |
| REQ-022 | **Alert kapasitas kontainer** (Berat dan/atau Kubikasi melebihi kapasitas maksimal) bersifat **informasi saja** dan **tidak memblokir** proses — user **tetap dapat lanjut** ke step berikutnya. | Baris 27 — Step 2 #9 | Must |
| REQ-023 | Pesan alert kapasitas mengikuti 3 kondisi: (a) kubikasi berlebih → **"Kubikasi melebihi kapasitas kontainer"**; (b) berat berlebih → **"Berat melebihi kapasitas kontainer"**; (c) keduanya → **"Kubikasi dan Berat melebihi kapasitas kontainer"**. | Baris 28–30 — Step 2 #9 | Must |
| REQ-024 | Jika field wajib (**Jumlah**, atau **Nilai Barang** saat asuransi aktif) tidak diisi → tampilkan **helper error** dan **border field berubah warna error**. | Baris 31 — Step 2 #10 | Must |
| REQ-025 | Fungsi button **Batal / Draf / Sebelumnya / Selanjutnya** pada Step 2 berlaku **identik dengan Step 2 TMS**. | Baris 32 — Step 2 #11 | Must |

### D. Step 3 — Vendor & Harga

| ID | Deskripsi | Sumber (baris/section) | Prioritas |
|---|---|---|---|
| REQ-026 | Step 3 **sama dengan Step 3 Order FCL di TMS**, memuat: field **Pilihan Vendor**, inputan **Tanggal Permintaan Muat**, inputan **Harga**, dan **ringkasan alamat**. | Baris 35–39 — Step 3 #1 | Must |
| REQ-027 | **Ringkasan alamat** tampil sebagai **label + text link** untuk tipe pengiriman **multi** (Multipickup / Multidrop / Multipoint). | Baris 39 — Step 3 #1 | Should |
| REQ-028 | **Komponen harga bersifat opsional**, diaktifkan via checkbox **"Gunakan Komponen Harga"**. | Baris 40 — Step 3 #1 | Must |
| REQ-029 | **Waktu Perjalanan mengikuti TMS**: FCL **tidak memiliki input** waktu perjalanan; nilainya merupakan **perhitungan `ETA − ETD + 4 hari`**. | Baris 41 — Step 3 #2 | Must |
| REQ-030 | Waktu Perjalanan **baru tampil pada informasi detail** saat order berstatus **"Ditugaskan"**. | Baris 41 — Step 3 #2 | Must |
| REQ-031 | Komponen **Asuransi** mengikuti data Step 2: saat terdapat **kontainer yang diasuransikan**, nilai Asuransi = **persentase × Total Nilai Barang** dan **turut dihitung ke Total Harga**, di samping **PPN & PPh**. | Baris 42 — Step 3 #3 | Must |
| REQ-032 | **Validasi field wajib** dan **fungsi button (Batal / Draf / Sebelumnya / Selanjutnya)** pada Step 3 **identik dengan TMS**. | Baris 43 — Step 3 #4 | Must |

### E. Step 4 — Review

| ID | Deskripsi | Sumber (baris/section) | Prioritas |
|---|---|---|---|
| REQ-033 | Step 4 menampilkan **ringkasan seluruh data Step 1–3 secara read-only**, sama dengan TMS. | Baris 46 — Step 4 #1 | Must |
| REQ-034 | Bagian **Data Barang** pada Review mengikuti **struktur Step 2 OMS**: menampilkan **Kode SKU, Nama Barang, Kemasan, Kubikasi/Dimensi, Berat, Jumlah**, dan **Nilai Barang** (khusus armada/kontainer yang diasuransikan). | Baris 47 — Step 4 #2 | Must |
| REQ-035 | Terdapat label **"Diasuransikan"** **per kontainer** yang diasuransikan. | Baris 47 — Step 4 #2 | Must |
| REQ-036 | Terdapat **button visualisasi pada card Data Barang** (tambahan dari add-on Auto Stuffing); saat diklik menampilkan **pop up visualisasi muatan**. | Baris 48 — Step 4 #3 | Must |
| REQ-037 | Fungsi button **Batal / Draf / Sebelumnya / Simpan** identik dengan TMS. Aksi **Simpan** mengubah status order menjadi **"Menunggu Penugasan"**. | Baris 49 — Step 4 #4 | Must |

### F. Status Order

| ID | Deskripsi | Sumber (baris/section) | Prioritas |
|---|---|---|---|
| REQ-038 | Order FCL memiliki **9 status**: Isi Data Pengiriman, Isi Data Muatan, Isi Data Vendor, Review Order, Menunggu Penugasan, Ditugaskan, Proses Pengiriman, Selesai, Dibatalkan. | Baris 52–61 — Status #1 | Must |
| REQ-039 | Definisi status draft: **Isi Data Pengiriman** = belum selesai di step Data Pengiriman; **Isi Data Muatan** = belum selesai di step Data Barang; **Isi Data Vendor** = belum selesai di step Vendor & Harga; **Review Order** = seluruh step terisi namun belum di-submit. | Baris 53–56 — Status #1 | Must |
| REQ-040 | Definisi status lanjutan: **Menunggu Penugasan** = data lengkap & disubmit, menunggu penugasan vendor; **Ditugaskan** = vendor sudah melakukan penugasan; **Proses Pengiriman** = status penugasan armada "Dalam Perjalanan"; **Selesai** = seluruh armada selesai bongkar (status penugasan "Selesai"); **Dibatalkan** = order dibatalkan oleh admin shipper. | Baris 57–61 — Status #1 | Must |
| REQ-041 | Status **1–4 (Isi Data Pengiriman s.d. Review Order)** merupakan **kondisi draft**, tersimpan otomatis melalui aksi **"Simpan ke Draf"** pada **step manapun**. | Baris 62 — Status #2 | Must |

### G. Hak Edit Order FCL

| ID | Deskripsi | Sumber (baris/section) | Prioritas |
|---|---|---|---|
| REQ-042 | **Shipper dapat mengubah data order** selama status berada dalam rentang **draft (Isi Data Pengiriman s.d. Review Order) hingga "Menunggu Penugasan"**. | Baris 65 — Hak Edit #1 | Must |
| REQ-043 | Shipper **tidak dapat lagi mengubah** data order setelah status berubah menjadi **"Ditugaskan"**. | Baris 66 — Hak Edit #2 | Must |
| REQ-044 | Pada halaman **Edit Order**, field **Jenis Pengiriman** dan **Tipe Pengiriman** bersifat **locked/read-only** dan tidak dapat diubah. | Baris 67 — Hak Edit #3 | Must |
| REQ-045 | Field **Jenis Armada/Kontainer, Jumlah Armada/Kontainer, Data Pengirim, Data Penerima, Data Barang, dan Vendor & Harga** **tetap dapat diubah** selama order berstatus dapat diedit (REQ-042). Lihat **ASM-014** untuk pemetaan istilah pada FCL. | Baris 68 — Hak Edit #4 | Must |
| REQ-046 | Pada Edit Order, button **Batal** (membatalkan pengisian data) dan **Simpan** (menyelesaikan pengeditan) **masing-masing menampilkan pop up konfirmasi**. | Baris 70–71 — Hak Edit #5 | Must |

### H. Pembatalan Order

| ID | Deskripsi | Sumber (baris/section) | Prioritas |
|---|---|---|---|
| REQ-047 | Order dapat **dibatalkan** selama status berada dalam rentang **draft hingga "Ditugaskan"**; **tidak dapat dibatalkan** setelah status **"Proses Pengiriman"**. | Baris 75 — Pembatalan #1 | Must |
| REQ-048 | Pembatalan order **dilakukan oleh admin shipper**, **bukan oleh vendor**. | Baris 76 — Pembatalan #2 | Must |
| REQ-049 | Field **"Alasan Pembatalan"** **wajib diisi** saat melakukan pembatalan. | Baris 77 — Pembatalan #3 | Must |

### I. Aksi pada Daftar Order FCL

| ID | Deskripsi | Sumber (baris/section) | Prioritas |
|---|---|---|---|
| REQ-050 | Pada status **Isi Data Pengiriman / Isi Data Muatan / Isi Data Vendor / Review Order**, aksi tersedia: **Detail, Lanjutkan Pengisian, Batalkan Order, Riwayat Perubahan**. | Baris 81 — Aksi #1 | Must |
| REQ-051 | Pada status **Menunggu Penugasan**, aksi tersedia: **Detail, Edit, Batalkan Order, Riwayat Perubahan**. | Baris 82 — Aksi #1 | Must |
| REQ-052 | Pada status **Ditugaskan**, aksi tersedia: **Detail, Batalkan Order, Riwayat Perubahan, Lihat No. Perjalanan** — aksi **Edit tidak tersedia**. | Baris 83 — Aksi #1 | Must |
| REQ-053 | Tombol **"Riwayat Pembatalan"** pada **toolbar** halaman Daftar Order menampilkan **daftar seluruh order yang pernah dibatalkan**, **terpisah** dari aksi per-baris **"Riwayat Perubahan"** yang menampilkan histori perubahan order tertentu. | Baris 84 — Aksi #2 | Must |

### J. No. Perjalanan

| ID | Deskripsi | Sumber (baris/section) | Prioritas |
|---|---|---|---|
| REQ-054 | **Nomor Perjalanan** digunakan untuk pengecekan pada **public tracking** sehingga pengirim/penerima dapat mengetahui progress perjalanan armada/kontainer yang dipesan. | Baris 87 — No. Perjalanan #1 | Must |
| REQ-055 | Nomor Perjalanan **di-generate otomatis oleh sistem** dan **melekat pada armada/kontainer**; **jumlahnya menyesuaikan jumlah armada/kontainer** yang dipesan. | Baris 88 — No. Perjalanan #2 | Must |
| REQ-056 | Nomor Perjalanan **hanya tampil untuk jenis pengiriman FTL & FCL**. | Baris 89 — No. Perjalanan #3 | Must |
| REQ-057 | Aksi **"Lihat No. Perjalanan"** pada action menu order **baru tampil setelah proses penugasan dilakukan** (status **"Ditugaskan"**). | Baris 90 — No. Perjalanan #4 | Must |
| REQ-058 | Klik aksi tersebut menampilkan **pop up "Data No. Perjalanan"** berisi, per armada/kontainer: **No. Perjalanan** (hasil generate sistem), **Nopol/No. Kontainer**, dan **Jenis Armada/Kontainer**. | Baris 91 — No. Perjalanan #5 | Must |
| REQ-059 | Pada pop up, **No. Perjalanan dilengkapi icon copy** untuk menyalin nomor perjalanan. | Baris 92 — No. Perjalanan #6 | Should |
| REQ-060 | Selain melalui action menu, **No. Perjalanan juga dapat dilihat pada halaman Detail Order**. | Baris 93 — No. Perjalanan #7 | Must |

**Total: 60 requirement.**

---

## Validation Rules

### 1. Field-level — Step 1 (Data Pengiriman)

| Field | Tipe Input | Wajib | Format / Aturan | Range / Batasan | Catatan |
|---|---|---|---|---|---|
| Jenis Pengiriman | Dropdown / preset | Ya | Nilai relevan modul: **FCL** | — | Locked saat Edit Order (REQ-044) |
| Tipe Pengiriman | Radio / Dropdown | Ya | `Normal` \| `Multipickup` \| `Multidrop` \| `Multipoint` | 4 opsi | Locked saat Edit Order (REQ-044) |
| Pelabuhan Asal | Dropdown / autocomplete | Ya | Dipilih dari master Pelabuhan | — | Wajib (ASM-024); harus ≠ Pelabuhan Tujuan (ASM-024) |
| Pelabuhan Tujuan | Dropdown / autocomplete | Ya | Dipilih dari master Pelabuhan | — | Wajib (ASM-024) |
| Jenis Kontainer | Read-only field + modal / dropdown | Ya | Dipilih dari master Kontainer | — | Menentukan kapasitas berat & kubikasi (REQ-022) |
| Jumlah Kontainer | Number / stepper | Ya | Bilangan bulat positif | **≥ 1** (ASM-005) | Menentukan jumlah card Data Barang & jumlah No. Perjalanan (REQ-055) |
| Data Pengirim (alamat) | Baris alamat dari Master Droppoint | Ya | Auto-draft dari Master Droppoint | Normal: 1; Multipickup/Multipoint: **≥ 2** (ASM-004) | Cascading (REQ-007) |
| Data Penerima (alamat) | Baris alamat dari Master Droppoint | Ya | Auto-draft dari Master Droppoint | Normal: 1; Multidrop/Multipoint: **≥ 2** (ASM-004) | Cascading (REQ-007) |
| ~~Metode Pengiriman~~ | — | — | **Tidak ditampilkan pada OMS** | — | REQ-009 — kehadiran field = cacat. **Catatan: desain justru menampilkannya — lihat ASM-028** |

### 2. Field-level — Step 2 (Data Barang)

| Field | Tipe Input | Wajib | Format / Aturan | Range / Batasan | Catatan |
|---|---|---|---|---|---|
| Kode SKU | Text (read-only) | — | Dari Master Barang | — | Tidak dapat diedit (REQ-016) |
| Nama Barang | Text (read-only) | — | Dari Master Barang | — | Tidak dapat diedit |
| Kemasan | Text (read-only) | — | Dari Master Barang | — | Tidak dapat diedit |
| Kubikasi | Number (read-only) | — | Satuan **m³** | — | Dari Master Barang; format id-ID (ASM-010) |
| Dimensi | Text (read-only) | — | `P × L × T` satuan **cm** | — | Dari Master Barang |
| Berat | Number (read-only) | — | Satuan **kg** | — | Dari Master Barang |
| **Jumlah** | Number / stepper | **Ya** | Bilangan **bulat positif** | **≥ 1** (ASM-006) | Helper error + border error bila kosong (REQ-017, REQ-024) |
| **Nilai Barang** | Number (currency) | **Ya — kondisional** | Muncul & wajib **hanya** saat "Tambahkan Asuransi" pada unit dicentang | **> 0** (ASM-007) | Tersembunyi saat asuransi non-aktif (REQ-018) |
| Tambahkan Asuransi | Checkbox (per armada/kontainer) | Tidak | Boolean | — | Default **tidak tercentang** (ASM-008) |
| Nomor DO | Text (multi-value, chip) | **Tidak** | Multi-nilai **dipisahkan koma**, dirender sebagai **chip** | — | Per armada/kontainer (REQ-020) |

### 3. Field-level — Step 3 (Vendor & Harga)

| Field | Tipe Input | Wajib | Format / Aturan | Catatan |
|---|---|---|---|---|
| Pilihan Vendor | Dropdown / modal | Ya | Dari master Vendor | Identik TMS (REQ-026) |
| Tanggal Permintaan Muat | Date picker | Ya | Format tanggal id-ID; **≥ hari ini** (ASM-009) | Identik TMS |
| Harga | Number (currency) | Ya | ≥ 0 | Identik TMS |
| Ringkasan alamat | Label + text link (tipe multi) | — (read-only) | Text link membuka pop up detail alamat | REQ-027 |
| Gunakan Komponen Harga | Checkbox | Tidak | Boolean | Membuka input komponen harga (REQ-028) |
| Waktu Perjalanan | **Tidak ada input** | — | Kalkulasi sistem `ETA − ETD + 4 hari` | Hanya tampil di informasi detail saat status "Ditugaskan" (REQ-029, REQ-030) |
| Komponen Asuransi | Kalkulasi sistem (read-only) | — | **persentase × Total Nilai Barang** | Hanya muncul bila ada kontainer diasuransikan (REQ-031) |
| PPN / PPh | Kalkulasi sistem | — | Ditambahkan ke Total Harga | REQ-031 |

### 4. Form-level / Rule-level

| Kode | Aturan | Perilaku bila dilanggar / kondisi |
|---|---|---|
| VAL-01 | Step 2 **tidak menyediakan** input deskripsi barang manual | Adanya field deskripsi manual → cacat (REQ-003, REQ-010) |
| VAL-02 | Field **Metode Pengiriman** tidak boleh ada pada Step 1 OMS | Field muncul → cacat (REQ-009) |
| VAL-03 | Field read-only Step 2 (Kode SKU, Nama Barang, Kemasan, Kubikasi, Dimensi, Berat) tidak boleh editable | Field editable → cacat (REQ-016) |
| VAL-04 | Field **Jumlah** wajib pada setiap baris barang | **Helper error** tampil + **border field berubah warna error**; navigasi ke step berikutnya diblokir (REQ-017, REQ-024) |
| VAL-05 | Field **Nilai Barang** wajib **hanya** saat "Tambahkan Asuransi" pada unit tercentang | Helper error + border error; saat asuransi non-aktif kolom **tidak tampil** dan **tidak divalidasi** (REQ-018, REQ-024) |
| VAL-06 | Checkbox "Tambahkan Asuransi" berlaku **per armada/kontainer** untuk **seluruh barang** pada unit tersebut | Asuransi diterapkan sebagian barang → cacat (REQ-019) |
| VAL-07 | **Nomor DO tidak wajib**; bila diisi lebih dari satu wajib dipisahkan **koma** dan dirender sebagai **chip** | Nomor DO memblokir Selanjutnya → cacat (REQ-020) |
| VAL-08 | Alert kapasitas kontainer bersifat **informatif** — **tidak boleh memblokir** navigasi ke step berikutnya | Sistem memblokir tombol Selanjutnya → cacat (REQ-022) |
| VAL-09 | Pesan alert harus sesuai kondisi: kubikasi saja / berat saja / keduanya, dengan teks persis memakai kata **"kontainer"** (REQ-023) | Teks tidak sesuai kondisi atau memakai kata "armada" → cacat. **Catatan: desain memakai kata "armada" — lihat ASM-029** |
| VAL-10 | Kapasitas maksimal pembanding alert diambil dari **Jenis Kontainer** yang dipilih pada Step 1 | Alert memakai kapasitas jenis kontainer lain → cacat (REQ-005, REQ-022) |
| VAL-11 | **Waktu Perjalanan tidak boleh** tampil sebagai input pada Step 3 FCL | Textfield waktu perjalanan muncul → cacat (REQ-029) |
| VAL-12 | Waktu Perjalanan hanya tampil pada informasi detail **saat status "Ditugaskan"** dan dihitung `ETA − ETD + 4 hari` | Tampil lebih awal / hasil hitung salah → cacat (REQ-029, REQ-030) |
| VAL-13 | Nilai Asuransi pada Step 3 = **persentase × Total Nilai Barang**, **hanya** dihitung bila terdapat kontainer diasuransikan | Perhitungan Total Harga salah → cacat (REQ-031) |
| VAL-14 | Step 4 menampilkan seluruh data Step 1–3 **read-only** | Field editable di Review → cacat (REQ-033) |
| VAL-15 | Label **"Diasuransikan"** hanya tampil pada kontainer yang diasuransikan, dan kolom Nilai Barang hanya tampil untuk kontainer tersebut | Label/kolom salah tempat → cacat (REQ-034, REQ-035) |
| VAL-16 | Button visualisasi pada card Data Barang Step 4 membuka **pop up visualisasi muatan** | Button tidak ada / pop up tidak tampil → cacat (REQ-004, REQ-036) |
| VAL-17 | Aksi **Simpan** pada Step 4 mengubah status menjadi **"Menunggu Penugasan"** | Status tidak berubah → cacat (REQ-037) |
| VAL-18 | Status 1–4 tersimpan sebagai **draft** via "Simpan ke Draf" dari **step manapun** | Draf gagal tersimpan di salah satu step → cacat (REQ-041) |
| VAL-19 | Edit order **diblokir** setelah status "Ditugaskan" | Aksi Edit muncul/berhasil di status Ditugaskan → cacat (REQ-043, REQ-052). **Catatan: desain 067 masih menampilkan button Edit Order — lihat ASM-033** |
| VAL-20 | Field **Jenis Pengiriman** & **Tipe Pengiriman** locked pada Edit Order | Field editable → cacat (REQ-044) |
| VAL-21 | Button Batal & Simpan pada Edit Order **wajib** memunculkan pop up konfirmasi | Aksi langsung dieksekusi tanpa konfirmasi → cacat (REQ-046) |
| VAL-22 | Pembatalan order **diblokir** sejak status "Proses Pengiriman" dan seterusnya | Aksi Batalkan Order tersedia → cacat (REQ-047) |
| VAL-23 | Field **"Alasan Pembatalan" wajib diisi** | Submit pembatalan ditolak + pesan validasi (REQ-049) |
| VAL-24 | Pembatalan hanya dapat dilakukan **admin shipper**, tidak oleh vendor | Vendor dapat membatalkan → cacat (REQ-048) |
| VAL-25 | Daftar aksi per baris harus **persis** sesuai status (REQ-050 s.d. REQ-052) | Aksi tambahan/hilang → cacat. **Catatan: desain 069 memuat aksi tambahan "Order Kembali" — lihat ASM-032** |
| VAL-26 | Jumlah **No. Perjalanan** yang di-generate = **jumlah kontainer** yang dipesan, dan tiap nomor **unik** | Jumlah/keunikan tidak sesuai → cacat (REQ-055) |
| VAL-27 | Aksi **"Lihat No. Perjalanan"** tidak boleh tampil sebelum status "Ditugaskan", dan hanya untuk **FTL & FCL** | Aksi muncul prematur atau pada jenis lain → cacat (REQ-056, REQ-057) |

### 5. Modal "Pilih Barang"

| Kode | Aturan |
|---|---|
| VAL-M1 | Sumber data = **Master Barang** milik shipper/tenant terkait; hanya barang berstatus **Aktif** yang tampil (ASM-011) |
| VAL-M2 | Pencarian berfungsi **by kode barang** dan **by nama barang** (REQ-011) |
| VAL-M3 | Mendukung **multi-select** via checkbox dalam satu kali buka modal (REQ-012) |
| VAL-M4 | Barang yang sudah masuk ke **kontainer terkait** menampilkan label **"Sudah Ditambahkan"**; label bersifat **informatif** dan barang tetap dapat dipilih/dilepas (ASM-012) |
| VAL-M5 | **Counter jumlah barang terpilih** ter-update real-time saat checkbox dicentang/dilepas (REQ-014) |
| VAL-M6 | Button **Batal** menutup modal **tanpa** menambahkan barang; button **Simpan** menambahkan seluruh barang terpilih ke kontainer terkait (REQ-015) |

---

## Roles & Permissions

> Spesifikasi menyebut secara eksplisit hanya **Shipper** / **Admin Shipper** dan **Vendor**. Matriks berikut melengkapi dengan aktor sistem serta interpretasi hak akses (lihat ASM-001, ASM-002, ASM-003).

| Role / Aktor | Buat Order (Step 1–4) | Simpan ke Draf | Edit Order | Batalkan Order | Lihat No. Perjalanan | Penugasan Kontainer | Riwayat Perubahan / Pembatalan |
|---|---|---|---|---|---|---|---|
| **Admin Shipper** (aktor utama) | Ya | Ya | Ya — status draft s.d. **Menunggu Penugasan** (REQ-042) | **Ya** — draft s.d. **Ditugaskan** (REQ-047, REQ-048) | Ya (status Ditugaskan) | Tidak | Ya |
| **Staff Operasional Shipper** | Ya | Ya | Ya (mengikuti REQ-042) | Mengikuti kebijakan tenant (ASM-002) | Ya | Tidak | Ya (baca) |
| **Vendor** | Tidak | Tidak | Tidak | **Tidak** (eksplisit dilarang, REQ-048) | Ya (konteks penugasan, ASM-003) | **Ya** — memicu status "Ditugaskan" (REQ-040) | Tidak |
| **Pengirim / Penerima (publik)** | Tidak | Tidak | Tidak | Tidak | Ya — via **public tracking** menggunakan No. Perjalanan (REQ-054) | Tidak | Tidak |
| **Sistem — Engine Auto Stuffing** | — | — | — | — | — | — | Menyusun penempatan barang dalam kontainer & merender **visualisasi muatan** (REQ-004, REQ-036) |
| **Sistem — Generator No. Perjalanan** | — | — | — | — | Meng-generate No. Perjalanan per kontainer (REQ-055) | — | — |
| **Sistem — Kalkulator Waktu Perjalanan** | — | — | — | — | — | Menghitung `ETA − ETD + 4 hari` saat status Ditugaskan (REQ-029, REQ-030) | — |
| **Master Barang** (sumber data) | Menyediakan Kode SKU, Nama Barang, Kemasan, Kubikasi, Dimensi, Berat (REQ-016) | — | — | — | — | — | — |
| **Master Droppoint** (sumber data) | Auto-draft Data Pengirim & Data Penerima (REQ-006) | — | — | — | — | — | — |
| **Master Kontainer** (sumber data) | Menyediakan daftar & kapasitas jenis kontainer (REQ-005, REQ-022) | — | — | — | — | — | — |
| **Master Pelabuhan** (sumber data) | Menyediakan opsi Pelabuhan Asal & Tujuan (REQ-005) | — | — | — | — | — | — |

### Matriks Aksi vs Status Order

| Status | Detail | Lanjutkan Pengisian | Edit | Batalkan Order | Riwayat Perubahan | Lihat No. Perjalanan |
|---|---|---|---|---|---|---|
| Isi Data Pengiriman | Ya | Ya | Tidak | Ya | Ya | Tidak |
| Isi Data Muatan | Ya | Ya | Tidak | Ya | Ya | Tidak |
| Isi Data Vendor | Ya | Ya | Tidak | Ya | Ya | Tidak |
| Review Order | Ya | Ya | Tidak | Ya | Ya | Tidak |
| Menunggu Penugasan | Ya | Tidak | **Ya** | Ya | Ya | Tidak |
| Ditugaskan | Ya | Tidak | **Tidak** | Ya | Ya | **Ya** |
| Proses Pengiriman | Ya (ASM-015) | Tidak | Tidak | **Tidak** | Ya | Ya (ASM-015) |
| Selesai | Ya (ASM-015) | Tidak | Tidak | Tidak | Ya | Ya (ASM-015) |
| Dibatalkan | Ya (ASM-015) | Tidak | Tidak | Tidak | Ya | Tidak |

---

## User Flows

### UF-01 — Buat Order FCL Auto Stuffing, Tipe Normal (Main Flow)

1. Admin/Staff Shipper membuka menu **Order** → **Buat Order** → jenis **FCL**.
2. **Step 1 — Data Pengiriman**: mengisi **Pelabuhan Asal**, **Pelabuhan Tujuan**, memilih **Jenis Kontainer**, mengisi **Jumlah Kontainer**, memilih **Tipe Pengiriman = Normal**.
3. Mengisi **Data Pengirim** & **Data Penerima** (auto-draft dari **Master Droppoint**, cascading wilayah).
4. Klik **Selanjutnya** → sistem memvalidasi field wajib → lanjut ke Step 2.
5. **Step 2 — Data Barang**: sistem menampilkan card per **kontainer** sesuai Jumlah Kontainer dari Step 1.
6. Klik **"Pilih Barang"** → modal **Pilih Barang** terbuka (pencarian by kode/nama, multi-select checkbox, counter terpilih, label "Sudah Ditambahkan").
7. Pilih barang → klik **Simpan** → baris barang tampil dengan Kode SKU, Nama Barang, Kemasan, Kubikasi, Dimensi, Berat (read-only).
8. Isi **Jumlah** pada setiap baris barang. (Opsional) isi **Nomor DO** dan centang **Tambahkan Asuransi** → isi **Nilai Barang**.
9. Klik **Selanjutnya** → **Step 3 — Vendor & Harga**: pilih Vendor, isi Tanggal Permintaan Muat dan Harga; (opsional) centang **Gunakan Komponen Harga**. Nilai **Asuransi** otomatis dihitung bila ada kontainer diasuransikan. **Tidak ada input Waktu Perjalanan**.
10. Klik **Selanjutnya** → **Step 4 — Review**: seluruh data Step 1–3 tampil read-only; Data Barang mengikuti struktur Step 2 (+ label **"Diasuransikan"** per kontainer).
11. (Opsional) Klik button **Visualisasi Muatan** pada card Data Barang → **pop up visualisasi muatan** tampil.
12. Klik **Simpan** → status order menjadi **"Menunggu Penugasan"**.

**Alternatif / Percabangan:**

- **UF-01.A1 — Field wajib kosong (Step 1):** klik Selanjutnya dengan Pelabuhan/Jenis Kontainer/Jumlah Kontainer/alamat kosong → navigasi diblokir + pesan validasi (REQ-008).
- **UF-01.A2 — Field wajib kosong (Step 2):** klik Selanjutnya tanpa mengisi **Jumlah** (atau **Nilai Barang** saat asuransi aktif) → **helper error** tampil dan **border field berwarna error**; navigasi diblokir (REQ-024).
- **UF-01.A3 — Alert kapasitas kontainer:** total kubikasi dan/atau berat melebihi kapasitas → alert informasi tampil ("Kubikasi melebihi kapasitas kontainer" / "Berat melebihi kapasitas kontainer" / "Kubikasi dan Berat melebihi kapasitas kontainer"); **user tetap dapat lanjut** (REQ-022, REQ-023).
- **UF-01.A4 — Hapus barang:** klik icon hapus pada baris → barang terhapus dari kontainer (REQ-021).
- **UF-01.A5 — Nomor DO multi-nilai:** input beberapa nomor dipisahkan koma → tiap nomor tampil sebagai chip (REQ-020).
- **UF-01.A6 — Barang sudah ditambahkan:** pada modal Pilih Barang, barang yang sudah masuk kontainer terkait menampilkan label **"Sudah Ditambahkan"** (REQ-013).
- **UF-01.A7 — Batal pada modal Pilih Barang:** klik **Batal** → modal tertutup tanpa menambahkan barang (REQ-015).
- **UF-01.A8 — Simpan ke Draf:** klik **Draf** pada step manapun → order tersimpan dengan status draft sesuai step terakhir (Isi Data Pengiriman / Isi Data Muatan / Isi Data Vendor / Review Order) (REQ-041).
- **UF-01.A9 — Batal:** klik **Batal** → pop up konfirmasi → pengisian dibatalkan (REQ-025, ASM-016).
- **UF-01.A10 — Sebelumnya:** klik **Sebelumnya** pada Step 2/3/4 → kembali ke step sebelumnya dengan data tetap tersimpan (REQ-025, REQ-032, REQ-037).
- **UF-01.A11 — Tanpa asuransi:** checkbox "Tambahkan Asuransi" tidak dicentang → kolom Nilai Barang tidak tampil, komponen Asuransi tidak dihitung pada Step 3, label "Diasuransikan" tidak tampil pada Step 4 (REQ-018, REQ-031, REQ-035).
- **UF-01.A12 — Batch order:** order dibuat melalui **input batch** alih-alih manual (REQ-002, ASM-017).

### UF-02 — Buat Order Tipe Multipickup / Multidrop / Multipoint

1. Ulangi UF-01 langkah 1–2, dengan **Tipe Pengiriman = Multipickup / Multidrop / Multipoint**.
2. Sistem menerapkan **rule cascading & minimal baris** sesuai tipe (≥ 2 baris pada sisi yang relevan).
3. Isi seluruh alamat pengirim/penerima sesuai tipe.
4. Lanjut ke Step 2 dan isi data barang per kontainer (sama seperti UF-01 langkah 5–8).
5. Lanjut Step 3: ringkasan alamat tampil sebagai **label + text link**; klik link → pop up detail alamat.
6. Lanjut Step 4 dan Simpan seperti UF-01.

**Alternatif / Percabangan:**

- **UF-02.A1 — Jumlah baris alamat kurang dari minimal:** klik Selanjutnya → validasi menolak (REQ-007, ASM-004).
- **UF-02.A2 — Text link ringkasan alamat:** klik text link pada Step 3 → pop up detail alamat multi tampil (REQ-027).
- **UF-02.A3 — Review multi:** Step 4 menampilkan seluruh pasangan alamat sesuai tipe pengiriman (REQ-033).

### UF-03 — Edit Order

1. Pada Daftar Order, order berstatus **Menunggu Penugasan** → klik aksi **Edit**.
2. Halaman Edit Order terbuka; field **Jenis Pengiriman** & **Tipe Pengiriman** tampil **locked/read-only**.
3. User mengubah **Jenis Kontainer, Jumlah Kontainer, Data Pengirim, Data Penerima, Data Barang, dan/atau Vendor & Harga**.
4. Klik **Simpan** → **pop up konfirmasi** tampil → konfirmasi → perubahan tersimpan.

**Alternatif / Percabangan:**

- **UF-03.A1 — Batal edit:** klik **Batal** → **pop up konfirmasi** → pengeditan dibatalkan (REQ-046).
- **UF-03.A2 — Order berstatus draft:** aksi yang tersedia adalah **"Lanjutkan Pengisian"** (bukan Edit), membuka wizard pada step terakhir (REQ-050).
- **UF-03.A3 — Order berstatus Ditugaskan:** aksi **Edit tidak tersedia** pada action menu (REQ-043, REQ-052).
- **UF-03.A4 — Ubah Jumlah Kontainer saat edit:** jumlah card Data Barang menyesuaikan; data barang pada kontainer yang dihapus perlu ditinjau ulang (REQ-045, ASM-018).

### UF-04 — Pembatalan Order

1. Admin Shipper membuka Daftar Order dan memilih order berstatus **draft s.d. Ditugaskan**.
2. Klik aksi **Batalkan Order** → pop up pembatalan tampil.
3. Isi field **"Alasan Pembatalan"** (**wajib**).
4. Konfirmasi → status order berubah menjadi **"Dibatalkan"**.

**Alternatif / Percabangan:**

- **UF-04.A1 — Alasan Pembatalan kosong:** submit ditolak dan pesan validasi tampil (REQ-049).
- **UF-04.A2 — Status ≥ Proses Pengiriman:** aksi **Batalkan Order tidak tersedia** (REQ-047).
- **UF-04.A3 — Aktor vendor:** vendor **tidak** memiliki akses pembatalan (REQ-048).
- **UF-04.A4 — Riwayat Pembatalan:** klik tombol **"Riwayat Pembatalan"** pada toolbar Daftar Order → daftar seluruh order yang pernah dibatalkan tampil (REQ-053).

### UF-05 — Lihat No. Perjalanan

1. Vendor melakukan penugasan → status order menjadi **"Ditugaskan"**.
2. Sistem **meng-generate No. Perjalanan otomatis** sebanyak jumlah kontainer yang dipesan.
3. Pada Daftar Order, aksi **"Lihat No. Perjalanan"** kini tampil pada action menu order tersebut.
4. Klik aksi → pop up **"Data No. Perjalanan"** tampil, berisi per kontainer: **No. Perjalanan**, **Nopol/No. Kontainer**, **Jenis Armada/Kontainer**.
5. Klik **icon copy** pada No. Perjalanan → nomor tersalin ke clipboard.

**Alternatif / Percabangan:**

- **UF-05.A1 — Status belum Ditugaskan:** aksi "Lihat No. Perjalanan" **tidak tampil** (REQ-057).
- **UF-05.A2 — Jenis pengiriman selain FTL/FCL:** No. Perjalanan **tidak tersedia** (REQ-056).
- **UF-05.A3 — Melalui Detail Order:** No. Perjalanan juga dapat dilihat pada halaman **Detail Order** (REQ-060).
- **UF-05.A4 — Public tracking:** pengirim/penerima menggunakan No. Perjalanan untuk mengecek progress perjalanan pada public tracking (REQ-054).
- **UF-05.A5 — Waktu Perjalanan:** pada status Ditugaskan, informasi detail order menampilkan Waktu Perjalanan hasil `ETA − ETD + 4 hari` (REQ-029, REQ-030).

### UF-06 — Transisi Status Order (System Flow)

`Isi Data Pengiriman → Isi Data Muatan → Isi Data Vendor → Review Order → Menunggu Penugasan → Ditugaskan → Proses Pengiriman → Selesai`

Cabang: **Dibatalkan** dapat terjadi dari status draft s.d. **Ditugaskan** (REQ-038, REQ-047).

---

## Acceptance Criteria

> Spesifikasi **tidak mencantumkan acceptance criteria eksplisit**. AC berikut diturunkan langsung dari requirement (ASM-019) dengan traceability ke ID REQ.

| ID | Acceptance Criteria (Given / When / Then) | Traceability |
|---|---|---|
| AC-001 | Given user membuat order jenis **FCL**, When wizard dibuka, Then tersedia **4 step**: Data Pengiriman, Data Barang, Vendor & Harga, Review. | REQ-002 |
| AC-002 | Given order FCL, When satuan unit diperiksa, Then satuan yang digunakan adalah **Kontainer**. | REQ-002 |
| AC-003 | Given user berada di Step 1, When halaman dimuat, Then field **Pelabuhan Asal, Pelabuhan Tujuan, Jenis Kontainer, Jumlah Kontainer, Tipe Pengiriman (4 opsi), Data Pengirim, Data Penerima** tampil. | REQ-005 |
| AC-004 | Given user berada di Step 1 pada OMS, When form diperiksa, Then field **Metode Pengiriman tidak tersedia**. | REQ-009, VAL-02 |
| AC-005 | Given user memilih droppoint, When Data Pengirim/Penerima diisi, Then data **ter-auto-draft dari Master Droppoint**. | REQ-006 |
| AC-006 | Given Tipe Pengiriman = Multipickup/Multidrop/Multipoint, When user mencoba lanjut dengan baris alamat kurang dari minimal, Then sistem menolak dan menampilkan validasi. | REQ-007, ASM-004 |
| AC-007 | Given field wajib Step 1 kosong, When klik **Selanjutnya**, Then navigasi diblokir dan pesan validasi tampil. | REQ-008 |
| AC-008 | Given user berada di Step 2, When area data barang diperiksa, Then **tidak ada** field input deskripsi barang manual; penambahan hanya via modal **"Pilih Barang"**. | REQ-003, REQ-010, VAL-01 |
| AC-009 | Given modal "Pilih Barang" terbuka, When user mengetik kode atau nama barang, Then daftar barang tersaring sesuai kata kunci. | REQ-011 |
| AC-010 | Given modal "Pilih Barang" terbuka, When user mencentang beberapa barang, Then seluruh barang terpilih dan **counter jumlah barang terpilih** ter-update. | REQ-012, REQ-014 |
| AC-011 | Given suatu barang sudah ditambahkan ke kontainer terkait, When modal "Pilih Barang" dibuka untuk kontainer tersebut, Then barang menampilkan label **"Sudah Ditambahkan"**. | REQ-013, VAL-M4 |
| AC-012 | Given barang terpilih pada modal, When user klik **Simpan**, Then barang masuk ke card kontainer; When user klik **Batal**, Then tidak ada barang ditambahkan. | REQ-015, VAL-M6 |
| AC-013 | Given baris barang tampil, When user mencoba mengubah Kode SKU/Nama Barang/Kemasan/Kubikasi/Dimensi/Berat, Then field bersifat **read-only**. | REQ-016, VAL-03 |
| AC-014 | Given baris barang tampil, When field **Jumlah** dikosongkan lalu klik Selanjutnya, Then **helper error** tampil, **border field berwarna error**, dan navigasi diblokir. | REQ-017, REQ-024, VAL-04 |
| AC-015 | Given checkbox "Tambahkan Asuransi" **tidak** tercentang, When card kontainer diperiksa, Then kolom **Nilai Barang tidak tampil** dan tidak divalidasi. | REQ-018, VAL-05 |
| AC-016 | Given checkbox "Tambahkan Asuransi" **dicentang**, When card kontainer diperiksa, Then kolom **Nilai Barang tampil untuk seluruh barang** pada kontainer tersebut dan bersifat **wajib**. | REQ-018, REQ-019, VAL-06 |
| AC-017 | Given asuransi aktif dan Nilai Barang kosong, When klik Selanjutnya, Then helper error tampil dan navigasi diblokir. | REQ-018, REQ-024 |
| AC-018 | Given field **Nomor DO** kosong, When klik Selanjutnya, Then navigasi **tetap berhasil** (tidak wajib). | REQ-020, VAL-07 |
| AC-019 | Given user mengisi beberapa Nomor DO dipisahkan **koma**, When input di-commit, Then setiap nomor tampil sebagai **chip** terpisah. | REQ-020 |
| AC-020 | Given baris barang tampil, When user klik **icon hapus**, Then baris barang terhapus dari kontainer. | REQ-021 |
| AC-021 | Given total **kubikasi** melebihi kapasitas kontainer, When Step 2 dirender, Then alert **"Kubikasi melebihi kapasitas kontainer"** tampil. | REQ-023 |
| AC-022 | Given total **berat** melebihi kapasitas kontainer, When Step 2 dirender, Then alert **"Berat melebihi kapasitas kontainer"** tampil. | REQ-023 |
| AC-023 | Given **kubikasi dan berat** melebihi kapasitas kontainer, When Step 2 dirender, Then alert **"Kubikasi dan Berat melebihi kapasitas kontainer"** tampil. | REQ-023 |
| AC-024 | Given alert kapasitas kontainer tampil, When user klik **Selanjutnya**, Then sistem **tetap mengizinkan** lanjut ke step berikutnya. | REQ-022, VAL-08 |
| AC-025 | Given Jenis Kontainer tertentu dipilih pada Step 1, When alert kapasitas dievaluasi, Then pembanding kapasitas mengikuti **jenis kontainer tersebut**. | REQ-005, REQ-022, VAL-10 |
| AC-026 | Given user berada di Step 2, When menekan Batal/Draf/Sebelumnya/Selanjutnya, Then perilaku identik dengan Step 2 TMS. | REQ-025 |
| AC-027 | Given user berada di Step 3, When halaman dimuat, Then field **Pilihan Vendor, Tanggal Permintaan Muat, Harga**, ringkasan alamat, dan checkbox **"Gunakan Komponen Harga"** tampil. | REQ-026, REQ-028 |
| AC-028 | Given Tipe Pengiriman multi, When ringkasan alamat pada Step 3 diperiksa, Then tampil sebagai **label + text link**. | REQ-027 |
| AC-029 | Given order jenis FCL, When Step 3 dirender, Then **tidak terdapat input Waktu Perjalanan**. | REQ-029, VAL-11 |
| AC-030 | Given order berstatus **"Ditugaskan"**, When informasi detail dibuka, Then **Waktu Perjalanan** tampil dengan nilai hasil perhitungan **`ETA − ETD + 4 hari`**. | REQ-029, REQ-030, VAL-12 |
| AC-031 | Given order **belum** berstatus Ditugaskan, When informasi detail dibuka, Then Waktu Perjalanan **belum ditampilkan**. | REQ-030 |
| AC-032 | Given terdapat kontainer yang diasuransikan pada Step 2, When Step 3 dirender, Then komponen **Asuransi = persentase × Total Nilai Barang** tampil dan **turut dihitung ke Total Harga** bersama **PPN & PPh**. | REQ-031, VAL-13 |
| AC-033 | Given **tidak ada** kontainer yang diasuransikan, When Step 3 dirender, Then komponen Asuransi **tidak** dihitung ke Total Harga. | REQ-031 |
| AC-034 | Given checkbox "Gunakan Komponen Harga" tidak dicentang, When Step 3 dirender, Then input komponen harga **tidak tampil** dan Step 3 tetap dapat dilanjutkan. | REQ-028 |
| AC-035 | Given field wajib Step 3 kosong, When klik Selanjutnya, Then navigasi diblokir dengan pesan validasi identik TMS. | REQ-032 |
| AC-036 | Given user berada di Step 4, When halaman dimuat, Then seluruh data Step 1–3 tampil **read-only**. | REQ-033, VAL-14 |
| AC-037 | Given Step 4 dirender, When bagian Data Barang diperiksa, Then menampilkan **Kode SKU, Nama Barang, Kemasan, Kubikasi/Dimensi, Berat, Jumlah** — dan **Nilai Barang hanya untuk kontainer yang diasuransikan**. | REQ-034 |
| AC-038 | Given terdapat kontainer yang diasuransikan, When Step 4 dirender, Then label **"Diasuransikan"** tampil pada kontainer tersebut saja. | REQ-035, VAL-15 |
| AC-039 | Given Step 4 dirender, When user klik button **Visualisasi Muatan** pada card Data Barang, Then **pop up visualisasi muatan** tampil. | REQ-004, REQ-036, VAL-16 |
| AC-040 | Given seluruh data lengkap, When user klik **Simpan** pada Step 4, Then order tersimpan dan status berubah menjadi **"Menunggu Penugasan"**. | REQ-037, VAL-17 |
| AC-041 | Given daftar order, When kolom status diperiksa, Then hanya **9 status valid** yang dapat muncul sesuai REQ-038. | REQ-038 |
| AC-042 | Given user berhenti pada suatu step, When klik **"Simpan ke Draf"**, Then order tersimpan dengan status draft sesuai step terakhir (Isi Data Pengiriman / Isi Data Muatan / Isi Data Vendor / Review Order). | REQ-039, REQ-041, VAL-18 |
| AC-043 | Given vendor telah melakukan penugasan, When status order diperiksa, Then status = **"Ditugaskan"**; When armada berstatus "Dalam Perjalanan", Then status = **"Proses Pengiriman"**; When seluruh armada selesai bongkar, Then status = **"Selesai"**. | REQ-040 |
| AC-044 | Given order berstatus **Menunggu Penugasan**, When shipper membuka Edit Order, Then perubahan data diizinkan dan tersimpan. | REQ-042 |
| AC-045 | Given order berstatus **Ditugaskan**, When action menu diperiksa, Then aksi **Edit tidak tersedia**. | REQ-043, REQ-052, VAL-19 |
| AC-046 | Given halaman Edit Order terbuka, When field **Jenis Pengiriman** & **Tipe Pengiriman** diperiksa, Then keduanya **locked/read-only**. | REQ-044, VAL-20 |
| AC-047 | Given halaman Edit Order terbuka, When user mengubah Jenis Kontainer / Jumlah Kontainer / Data Pengirim / Data Penerima / Data Barang / Vendor & Harga, Then perubahan diizinkan. | REQ-045 |
| AC-048 | Given halaman Edit Order, When user klik **Batal** atau **Simpan**, Then **pop up konfirmasi tampil** sebelum aksi dieksekusi. | REQ-046, VAL-21 |
| AC-049 | Given order berstatus draft s.d. **Ditugaskan**, When action menu diperiksa, Then aksi **Batalkan Order tersedia**. | REQ-047 |
| AC-050 | Given order berstatus **Proses Pengiriman** atau setelahnya, When action menu diperiksa, Then aksi **Batalkan Order tidak tersedia**. | REQ-047, VAL-22 |
| AC-051 | Given aktor **vendor**, When mencoba membatalkan order, Then aksi **tidak tersedia/ditolak**. | REQ-048, VAL-24 |
| AC-052 | Given form pembatalan terbuka, When **Alasan Pembatalan** kosong lalu disubmit, Then submit **ditolak** dan pesan validasi tampil. | REQ-049, VAL-23 |
| AC-053 | Given form pembatalan diisi lengkap, When disubmit, Then status order berubah menjadi **"Dibatalkan"**. | REQ-040, REQ-049 |
| AC-054 | Given order berstatus **Isi Data Pengiriman/Muatan/Vendor atau Review Order**, When action menu dibuka, Then tersedia **Detail, Lanjutkan Pengisian, Batalkan Order, Riwayat Perubahan**. | REQ-050, VAL-25 |
| AC-055 | Given order berstatus **Menunggu Penugasan**, When action menu dibuka, Then tersedia **Detail, Edit, Batalkan Order, Riwayat Perubahan**. | REQ-051, VAL-25 |
| AC-056 | Given order berstatus **Ditugaskan**, When action menu dibuka, Then tersedia **Detail, Batalkan Order, Riwayat Perubahan, Lihat No. Perjalanan**. | REQ-052, VAL-25 |
| AC-057 | Given halaman Daftar Order, When user klik **"Riwayat Pembatalan"** pada toolbar, Then daftar seluruh order yang pernah dibatalkan ditampilkan. | REQ-053 |
| AC-058 | Given order tertentu, When user klik aksi **"Riwayat Perubahan"**, Then histori perubahan **order tersebut saja** ditampilkan (bukan daftar pembatalan global). | REQ-053 |
| AC-059 | Given order FCL dengan **N kontainer** berstatus Ditugaskan, When No. Perjalanan diperiksa, Then sistem meng-generate **tepat N** No. Perjalanan **unik** yang melekat pada masing-masing kontainer. | REQ-055, VAL-26 |
| AC-060 | Given jenis pengiriman **selain FTL & FCL**, When order diperiksa, Then No. Perjalanan **tidak tersedia**. | REQ-056, VAL-27 |
| AC-061 | Given order **belum** berstatus Ditugaskan, When action menu dibuka, Then aksi **"Lihat No. Perjalanan" tidak tampil**. | REQ-057, VAL-27 |
| AC-062 | Given order berstatus Ditugaskan, When user klik **"Lihat No. Perjalanan"**, Then pop up **"Data No. Perjalanan"** tampil berisi **No. Perjalanan, Nopol/No. Kontainer, dan Jenis Armada/Kontainer** per unit. | REQ-058 |
| AC-063 | Given pop up "Data No. Perjalanan" terbuka, When user klik **icon copy**, Then nomor perjalanan tersalin ke clipboard. | REQ-059 |
| AC-064 | Given order berstatus Ditugaskan, When user membuka **Detail Order**, Then No. Perjalanan ditampilkan pada halaman tersebut. | REQ-060 |
| AC-065 | Given No. Perjalanan valid, When pengirim/penerima memasukkannya pada **public tracking**, Then progress perjalanan kontainer dapat dilihat. | REQ-054 |
| AC-066 | Given tipe pengiriman Multipickup/Multidrop/Multipoint, When order FCL diselesaikan hingga Simpan, Then seluruh alur berjalan sama dengan tipe Normal kecuali jumlah baris alamat & ringkasan alamat. | REQ-001, REQ-007, REQ-027 |

---

## Traceability Matrix (Ringkas)

| Kategori | Range REQ | Jumlah |
|---|---|---|
| A. Ketentuan Umum Order FCL (OMS) | REQ-001 – REQ-004 | 4 |
| B. Step 1 — Data Pengiriman | REQ-005 – REQ-009 | 5 |
| C. Step 2 — Data Barang | REQ-010 – REQ-025 | 16 |
| D. Step 3 — Vendor & Harga | REQ-026 – REQ-032 | 7 |
| E. Step 4 — Review | REQ-033 – REQ-037 | 5 |
| F. Status Order | REQ-038 – REQ-041 | 4 |
| G. Hak Edit Order FCL | REQ-042 – REQ-046 | 5 |
| H. Pembatalan Order | REQ-047 – REQ-049 | 3 |
| I. Aksi pada Daftar Order FCL | REQ-050 – REQ-053 | 4 |
| J. No. Perjalanan | REQ-054 – REQ-060 | 7 |
| **Total** | | **60** |

| Artefak | Jumlah |
|---|---|
| Requirements (REQ) | 60 |
| Aturan validasi field-level | 26 field (Step 1: 9, Step 2: 10, Step 3: 8 — 1 baris "field terlarang") |
| Aturan validasi form/rule-level (VAL) | 27 |
| Aturan validasi modal "Pilih Barang" (VAL-M) | 6 |
| **Total aturan validasi** | **59** (26 field + 27 rule + 6 modal) |
| Acceptance Criteria (AC) | 66 |
| User Flow utama | 6 (UF-01 … UF-06) |
| Alur alternatif / percabangan | 27 |
| Role / aktor | 11 (4 manusia/eksternal + 7 sistem/sumber data) |

---

## UI Inventory

> Sumber: **38 file PNG** pada `inputs/oms013-order-fcl-auto-stuffing/designs/` (**058.png – 095.png**), dibaca melalui vision.
> Aplikasi: **OMS "Mentari Sumber Kertas"**, role header **Shipper / Staff Operasional**, user **Andika (andikamsk@gmail.com)**.
> Konvensi selector: `role+name` sebagai **primary** (paling stabil untuk teks Indonesia yang sudah pasti), `data-testid` sebagai **saran ke dev** (belum tentu ada di build — lihat ASM-041), `label text` untuk field form.
> Seluruh nilai `data-testid` di bawah adalah **usulan** (kebab-case, prefix per layar), bukan hasil observasi DOM.

### Peta Layar ↔ File PNG

| ID Layar | Nama Layar / State | File PNG | Tipe Pengiriman |
|---|---|---|---|
| S-01 | Daftar Order — list default | 058, 071, 079, 087 | Normal / Multipickup / Multidrop / Multipoint |
| S-02 | Daftar Order — panel Filter terbuka + action menu (status Ditugaskan) | 069 | — |
| S-03 | Modal **Data No. Perjalanan** | 070 | — |
| S-04 | Step 1 — Data Pengiriman (**empty / awal**, Selanjutnya disabled) | 059 | — |
| S-05 | Step 1 — Data Pengiriman **Normal** (terisi) | 060 | Normal |
| S-06 | Step 1 — **Multipickup** (Pick Up 1..n) | 072 | Multipickup |
| S-07 | Step 1 — **Multidrop** (Drop Off 1..n) | 080 | Multidrop |
| S-08 | Step 1 — **Multipoint** (Pick Up + Drop Off, ada icon hapus baris) | 088 | Multipoint |
| S-09 | Step 2 — Data Barang **Normal** (error + alert + empty state) | 061 | Normal |
| S-10 | Step 2 — Data Barang **multi** (sub-card per titik) | 073 (Multipickup), 081 (Multidrop), 089 (Multipoint) | Multi |
| S-11 | Modal **Hitung Ulang Kontainer** (floating button ⟳) | 062 | — |
| S-12 | Modal **Visualisasi Muatan Saat Ini** (floating button 👁) | 063 | — |
| S-13 | Step 3 — Vendor dan Harga | 064 (Normal, kosong), 074 (Multipickup), 082 (Multidrop), 090 (Multipoint) | Semua |
| S-14 | Modal **Detail Multipickup / Detail Multidrop** | 075, 083, 091, 092 | Multi |
| S-15 | Step 4 — Review | 065 (Normal), 076 (Multipickup), 084 (Multidrop), 093 (Multipoint) | Semua |
| S-16 | Detail Order — status **Menunggu Penugasan** | 066, 077, 085, 094 | Semua |
| S-17 | Detail Order — status **Ditugaskan** (ada Waktu Perjalanan + button Visualisasi Muatan) | 067 | Normal |
| S-18 | Edit Order | 068 (Normal), 078 (Multipickup), 086 (Multidrop), 095 (Multipoint) | Semua |
| S-19 | Modal **Pilih Barang** | **Tidak ada PNG** — diturunkan dari spec (ASM-040) | — |

### Elemen Global (muncul di seluruh layar)

| Elemen | Tipe | State terlihat | Saran Selector (Playwright) | Saran `data-testid` |
|---|---|---|---|---|
| Sidebar — brand "Mentari Sumber Kertas" | Text/logo | default | `getByText('Mentari Sumber Kertas')` | `app-brand` |
| Menu **Order** | Nav link | active (058) / inactive (071+) | `getByRole('link', { name: 'Order' })` | `nav-order` |
| Menu **Penugasan Tracking** | Nav link | active pada 071–095 | `getByRole('link', { name: 'Penugasan Tracking' })` | `nav-penugasan-tracking` |
| Menu **Simulasi Muatan** | Nav link | **hanya muncul pada 062 & 063** (ASM-037) | `getByRole('link', { name: 'Simulasi Muatan' })` | `nav-simulasi-muatan` |
| Menu Master Wilayah / Master Operasional / Pusat Notifikasi | Nav group (collapsible) | collapsed | `getByRole('button', { name: 'Master Wilayah' })` | `nav-master-wilayah` |
| Toggle sidebar (hamburger) | Icon button | default | `getByRole('button', { name: /menu|toggle sidebar/i })` | `btn-toggle-sidebar` |
| Notifikasi (bell + badge merah) | Icon button | ada unread (dot merah) | `getByRole('button', { name: /notifikasi/i })` | `btn-notifikasi` |
| Profil user "Andika" | Text/avatar | default | `getByText('andikamsk@gmail.com')` | `user-profile` |
| Logout | Icon button | default | `getByRole('button', { name: /keluar|logout/i })` | `btn-logout` |
| Widget **Kuota Order** (`120/300`, `40%`, progress bar) | Info card | terisi 40% | `getByTestId('widget-kuota-order')` / `getByText('120/300')` | `widget-kuota-order` |
| Footer versi "Order Management System Versi 1.0.0" | Text | default | `getByText(/Versi 1\.0\.0/)` | `app-version` |
| Breadcrumb `Beranda > Daftar Order > ...` | Navigation | default | `getByRole('navigation', { name: /breadcrumb/i })` | `breadcrumb` |

---

### S-01 — Daftar Order (058, 071, 079, 087)

**Judul halaman:** `Daftar Order`

| Elemen | Tipe | Constraint / Isi terlihat | State | Saran Selector | `data-testid` |
|---|---|---|---|---|---|
| Buat Order | Button (primary, + icon) | — | enabled | `getByRole('button', { name: 'Buat Order' })` | `btn-buat-order` |
| Batch Order | Button (outline, download icon) | — | enabled | `getByRole('button', { name: 'Batch Order' })` | `btn-batch-order` |
| Riwayat Pembatalan | Button (outline, history icon) | REQ-053 | enabled | `getByRole('button', { name: 'Riwayat Pembatalan' })` | `btn-riwayat-pembatalan` |
| Filter | Button (outline, sliders icon) | toggle panel filter | enabled | `getByRole('button', { name: 'Filter' })` | `btn-filter` |
| Tampilkan `20` data | Dropdown | opsi jumlah baris/halaman | default `20` | `getByRole('combobox', { name: /tampilkan/i })` | `select-page-size` |
| Tabel Daftar Order | Table | header 2 baris: `ID Order/Vendor`, `Kota Asal/Warehouse Asal`, `Kota Tujuan/Warehouse Tujuan`, `Total Harga/Status` | terisi | `getByRole('table')` | `table-daftar-order` |
| Sort **Total Harga** | Sortable header (icon ⇅) | asc/desc | default | `getByRole('columnheader', { name: /Total Harga/ })` | `th-total-harga` |
| Badge jenis order | Chip | `FCL`, `FTL`, `LTL`, `LCL` | — | `row.getByText('FCL', { exact: true })` | `chip-jenis-order` |
| Badge status | Chip | **Isi Data Dasar**, **Isi Data Muatan**, **Isi Data Vendor**, **Review Order**, **Menunggu Penugasan**, **Ditugaskan**, **Proses Pengiriman**, **Terkirim**, **Dibatalkan** (ASM-031) | 9 varian warna | `row.getByTestId('chip-status')` | `chip-status` |
| Link tipe multi pada kolom kota | Text link | `Multipickup` (071/087), `Multidrop` (079/087) — menggantikan nama kota/warehouse | link | `getByRole('link', { name: 'Multipickup' })` | `link-tipe-multi` |
| Kebab menu per baris | Icon button (`...`) | membuka action menu | enabled | `row.getByRole('button', { name: /aksi|more/i })` | `btn-row-action` |
| Info paginasi | Text | `Menampilkan 1 - 20 data dari 30 data` | — | `getByText(/Menampilkan .* data dari .* data/)` | `text-pagination-info` |
| Paginasi | Nav (`«`, `‹`, 1,2,3,…,12, `›`, `»`) | halaman aktif `1` | page 1 active | `getByRole('button', { name: '2' })` | `pagination` |

**State terlihat:** list terisi (tidak ada empty state list pada PNG manapun — ASM-039).

---

### S-02 — Daftar Order + Panel Filter & Action Menu (069)

**Panel Filter** (muncul setelah klik `Filter`):

| Field | Tipe | Placeholder | State | Saran Selector | `data-testid` |
|---|---|---|---|---|---|
| ID Order | Text input | `Masukkan ID Order` | empty | `getByLabel('ID Order')` | `filter-id-order` |
| Jenis Order | Dropdown | `Pilih Jenis Order` | empty | `getByLabel('Jenis Order')` | `filter-jenis-order` |
| Vendor | Text input / autocomplete | `Masukkan Vendor` | empty | `getByLabel('Vendor')` | `filter-vendor` |
| Kota Asal | Dropdown | `Pilih Kota Asal` | empty | `getByLabel('Kota Asal')` | `filter-kota-asal` |
| Kota Tujuan | Dropdown | `Pilih Kota Tujuan` | empty | `getByLabel('Kota Tujuan')` | `filter-kota-tujuan` |
| Total Harga | Text/number input | `Masukkan Total Harga` | empty | `getByLabel('Total Harga')` | `filter-total-harga` |
| Tipe Pengiriman | Dropdown | `Pilih Tipe Pengiriman` | **disabled** (teks & border pudar) | `getByLabel('Tipe Pengiriman')` | `filter-tipe-pengiriman` |
| Metode Pengiriman | Dropdown | `Pilih Metode Pengiriman` | **disabled** (teks & border pudar) | `getByLabel('Metode Pengiriman')` | `filter-metode-pengiriman` |
| Drop Point Asal | Dropdown | `Pilih Drop Point Asal` | empty | `getByLabel('Drop Point Asal')` | `filter-droppoint-asal` |
| Drop Point Tujuan | Dropdown | `Pilih Drop Point Tujuan` | empty | `getByLabel('Drop Point Tujuan')` | `filter-droppoint-tujuan` |
| Status | Dropdown | `Pilih Status` | empty | `getByLabel('Status')` | `filter-status` |
| Reset | Button (outline merah) | — | enabled | `getByRole('button', { name: 'Reset' })` | `btn-filter-reset` |
| Terapkan | Button (primary) | — | enabled | `getByRole('button', { name: 'Terapkan' })` | `btn-filter-terapkan` |

**Action Menu per baris** (contoh pada order berstatus **Ditugaskan**) — item terlihat:

| Item | Saran Selector | `data-testid` | Catatan |
|---|---|---|---|
| Detail | `getByRole('menuitem', { name: 'Detail' })` | `menu-detail` | REQ-050..052 |
| Lihat No. Perjalanan | `getByRole('menuitem', { name: 'Lihat No. Perjalanan' })` | `menu-lihat-no-perjalanan` | REQ-057 |
| **Order Kembali** | `getByRole('menuitem', { name: 'Order Kembali' })` | `menu-order-kembali` | **Tidak ada di spec** — ASM-032 |
| Batalkan Order | `getByRole('menuitem', { name: 'Batalkan Order' })` | `menu-batalkan-order` | REQ-047 |
| Riwayat Perubahan | `getByRole('menuitem', { name: 'Riwayat Perubahan' })` | `menu-riwayat-perubahan` | REQ-053 |

> Item **Edit** dan **Lanjutkan Pengisian** tidak terlihat pada PNG manapun (status Ditugaskan) — konsisten dengan REQ-052. Selector yang disarankan: `getByRole('menuitem', { name: 'Edit' })` / `getByRole('menuitem', { name: 'Lanjutkan Pengisian' })` (ASM-038).

---

### S-03 — Modal "Data No. Perjalanan" (070)

| Elemen | Tipe | Isi terlihat | Saran Selector | `data-testid` |
|---|---|---|---|---|
| Modal container | Dialog | judul `Data No. Perjalanan` | `getByRole('dialog', { name: 'Data No. Perjalanan' })` | `modal-no-perjalanan` |
| Tutup | Icon button (×) | — | `dialog.getByRole('button', { name: /tutup|close/i })` | `btn-close-modal` |
| Chip ID Order | Chip | `ID Order: ORD-20260607009` | `getByText(/ID Order: ORD-/)` | `chip-id-order` |
| Chip jenis | Chip | `FCL` | `dialog.getByText('FCL')` | `chip-jenis-order` |
| Baris unit (2 baris = 2 kontainer) | List item | `TRC79289802` + `TVW67892231 • 40 DRY`, `TRC79289802` + `CTN68901072 • 40 DRY` | `dialog.getByTestId('row-no-perjalanan').nth(0)` | `row-no-perjalanan` |
| Icon copy per baris | Icon button | menyalin No. Perjalanan (REQ-059) | `row.getByRole('button', { name: /salin|copy/i })` | `btn-copy-no-perjalanan` |

**Catatan uji:** pada desain kedua baris menampilkan **No. Perjalanan yang sama** (`TRC79289802`) padahal REQ-055/VAL-26 mensyaratkan **unik** → jadikan skenario negatif (ASM-035).

---

### S-04 — Step 1 Data Pengiriman, state awal / empty (059)

**Stepper:** `01 Data Pengiriman` (aktif) → `02 Data Barang` → `03 Vendor dan Harga` → `04 Review`.

| Elemen | Tipe | Label / Placeholder | State | Saran Selector | `data-testid` |
|---|---|---|---|---|---|
| Stepper item | Nav/step indicator | `01 Data Pengiriman` … `04 Review` | 01 active, 02–04 inactive | `getByTestId('stepper').getByText('Data Barang')` | `stepper` / `step-1..4` |
| Card jenis pengiriman | Radio card ×4 | `FTL / Full Truck Load`, `FCL / Full Container Load`, `LTL / Less Than Truck Load`, `LCL / Less Than Container Load` | **FCL selected** | `getByRole('radio', { name: /FCL/ })` | `radio-jenis-fcl` |
| Pelabuhan Asal * | Dropdown | value `Tanjung Perak (SUB)` | filled | `getByLabel('Pelabuhan Asal')` | `select-pelabuhan-asal` |
| Pelabuhan Tujuan * | Dropdown | value `Panjang (PNJ)` | filled | `getByLabel('Pelabuhan Tujuan')` | `select-pelabuhan-tujuan` |
| Jenis Kontainer * | Dropdown | value `20 DRY` | filled | `getByLabel('Jenis Kontainer')` | `select-jenis-kontainer` |
| Jumlah Kontainer * | Number input | value `2` | filled | `getByLabel('Jumlah Kontainer')` | `input-jumlah-kontainer` |
| Tipe Pengiriman * | Dropdown | placeholder `Pilih Tipe Pengiriman` | **empty** | `getByLabel('Tipe Pengiriman')` | `select-tipe-pengiriman` |
| Batal | Button (outline merah) | — | enabled | `getByRole('button', { name: 'Batal' })` | `btn-batal` |
| Selanjutnya | Button (primary + arrow) | — | **disabled** (abu-abu) | `getByRole('button', { name: 'Selanjutnya' })` | `btn-selanjutnya` |

**State terlihat:** *empty/awal* — section **Data Pengirim**, **Data Penerima**, dan **Metode Pengiriman belum dirender** sebelum Tipe Pengiriman dipilih; button **Simpan ke Draf belum muncul** (ASM-036).

---

### S-05 — Step 1 Data Pengiriman, tipe **Normal** (060)

**Section `Jenis Pengiriman dan Rute`** — sama seperti S-04, `Tipe Pengiriman = Normal`, ditambah:

| Elemen | Tipe | Isi terlihat | State | Saran Selector | `data-testid` |
|---|---|---|---|---|---|
| **Metode Pengiriman \*** | Radio card ×4 | `Door to Door` (Kontainer diambil dari lokasi pengirim dan diantar hingga lokasi penerima.), `Door to CY`, `CY to CY`, `CY to Door` | **Door to Door selected** | `getByRole('radio', { name: /Door to Door/ })` | `radio-metode-door-to-door` |

> **Konflik spec:** REQ-009/VAL-02 menyatakan Metode Pengiriman **tidak boleh ada** di OMS, tetapi desain 060/072/080/088 **menampilkannya sebagai field wajib** → **ASM-028**.

**Section `Data Pengirim`:**

| Field | Tipe | Label / Placeholder | Wajib | State | Saran Selector | `data-testid` |
|---|---|---|---|---|---|---|
| Drop Point Asal | Dropdown | `Pilih  Drop Point Asal` | * | empty | `getByLabel('Drop Point Asal')` | `select-droppoint-asal` |
| Pengirim | Dropdown | `Pilih Pengirim` | * | empty | `getByLabel('Pengirim')` | `select-pengirim` |
| PIC Pengirim | Text | `Masukkan PIC Pengirim`, helper `Nama PIC Pengirim` | * | empty | `getByLabel('PIC Pengirim')` | `input-pic-pengirim` |
| No. WhatsApp PIC | Text (tel) | `Masukkan No. WhatsApp PIC`, helper `Contoh: 081234567898` | * | empty | `getByLabel('No. WhatsApp PIC').first()` | `input-wa-pengirim` |
| Provinsi Asal | Text | `Provinsi Asal` | — | **disabled/read-only** (auto-fill) | `getByLabel('Provinsi Asal')` | `input-provinsi-asal` |
| Kota/Kab. Asal | Text | `Kota/Kab. Asal` | — | disabled/read-only | `getByLabel('Kota/Kab. Asal')` | `input-kota-asal` |
| Kecamatan Asal | Text | `Kecamatan Asal` | — | disabled/read-only | `getByLabel('Kecamatan Asal')` | `input-kecamatan-asal` |
| Desa/Kelurahan Asal | Text | `Desa/Kelurahan Asal` | — | disabled/read-only | `getByLabel('Desa/Kelurahan Asal')` | `input-kelurahan-asal` |
| Kode Pos | Text | `Kode Pos` | — | disabled/read-only | `getByLabel('Kode Pos').first()` | `input-kodepos-asal` |
| Alamat Asal | Textarea | `Alamat Asal` | — | disabled/read-only | `getByLabel('Alamat Asal')` | `textarea-alamat-asal` |
| Catatan | Textarea | `Masukkan Catatan` | Tidak | empty (editable) | `getByLabel('Catatan').first()` | `textarea-catatan-asal` |

**Section `Data Penerima`:** struktur cermin dari Data Pengirim dengan label `Drop Point Tujuan`, `Penerima`, `PIC Penerima` (helper `Nama PIC Penerima`), `No. WhatsApp PIC`, `Provinsi Tujuan`, `Kota/Kab. Tujuan`, `Kecamatan Tujuan`, `Desa/Kelurahan Tujuan`, `Kode Pos`, `Alamat Tujuan`, `Catatan`. Saran testid: `select-droppoint-tujuan`, `select-penerima`, `input-pic-penerima`, `input-wa-penerima`, `input-provinsi-tujuan`, …, `textarea-catatan-tujuan`.

**Footer aksi:** `Batal` (outline merah, kiri) · `Simpan ke Draf` (outline, kanan) · `Selanjutnya` (primary, kanan).
Selector: `getByRole('button', { name: 'Simpan ke Draf' })` → `btn-simpan-draf`.

---

### S-06 / S-07 / S-08 — Step 1 tipe Multi (072 Multipickup, 080 Multidrop, 088 Multipoint)

| Elemen | Tipe | Isi / Perilaku | State | Saran Selector | `data-testid` |
|---|---|---|---|---|---|
| Info banner | Alert info (ikon i, biru) | `Pastikan urutan pengiriman sudah sesuai saat membuat shipment` | tampil pada section yang bersifat multi | `getByText('Pastikan urutan pengiriman sudah sesuai saat membuat shipment')` | `alert-urutan-pengiriman` |
| Sub-section pengirim | Group heading | `Pick Up 1`, `Pick Up 2`, … | Multipickup & Multipoint | `getByRole('heading', { name: 'Pick Up 2' })` | `group-pickup-2` |
| Sub-section penerima | Group heading | `Drop Off 1`, `Drop Off 2`, … | Multidrop & Multipoint | `getByRole('heading', { name: 'Drop Off 2' })` | `group-dropoff-2` |
| Tambah Baris Input | Text button (+) | menambah baris Pick Up / Drop Off | enabled | `getByRole('button', { name: 'Tambah Baris Input' })` | `btn-tambah-baris-pickup` / `btn-tambah-baris-dropoff` |
| Hapus baris | Icon button (trash merah) | **hanya terlihat pada 088 (Multipoint)** di header `Pick Up 2` & `Drop Off 2` | enabled | `getByTestId('group-pickup-2').getByRole('button', { name: /hapus/i })` | `btn-hapus-baris-pickup-2` |
| Kota/Kab. Pengirim Asal | Text (read-only) | label berbeda dari tipe Normal (`Kota/Kab. Asal`) | disabled | `getByLabel('Kota/Kab. Pengirim Asal')` | `input-kota-pengirim-asal` |
| Tipe Pengiriman | Dropdown | `Multipickup` (072) / `Multidrop` (080) / `Multipoint` (088) | filled | `getByLabel('Tipe Pengiriman')` | `select-tipe-pengiriman` |
| Jumlah Kontainer | Number input | `2` (072) / `1` (080, 088) | filled | `getByLabel('Jumlah Kontainer')` | `input-jumlah-kontainer` |

**Catatan struktur:** pada Multipickup (072) sisi penerima tetap **tunggal** (tanpa heading Drop Off); pada Multidrop (080) sisi pengirim tetap tunggal; pada Multipoint (088) **kedua sisi** ber-heading dan masing-masing punya `Tambah Baris Input` — konsisten ASM-004.

---

### S-09 — Step 2 Data Barang, tipe **Normal** (061)

**Header:** breadcrumb `Buat Order`, stepper `02 Data Barang` aktif (step 01 bercentang).

**Floating action buttons (kanan atas, di luar card):**

| Elemen | Tipe | Fungsi | Saran Selector | `data-testid` |
|---|---|---|---|---|
| Icon ⟳ (refresh, outline biru) | Floating icon button | membuka modal **Hitung Ulang Kontainer** (062) | `getByRole('button', { name: /hitung ulang/i })` | `btn-hitung-ulang-kontainer` |
| Icon 👁 (eye, solid biru) | Floating icon button | membuka modal **Visualisasi Muatan Saat Ini** (063) | `getByRole('button', { name: /visualisasi/i })` | `btn-visualisasi-muatan-saat-ini` |

> Kedua button ini **tidak disebut** dalam spec FCL → **ASM-030** (menganulir sebagian ASM-022).

**Card `Data Unit` (read-only):** `Jenis Kontainer: 20 Feet Dry`, `Jumlah Kontainer: 2`.
Selector: `getByTestId('card-data-unit')`, `getByText('20 Feet Dry')`.

**Card per kontainer — `Kontainer 1`, `Kontainer 2`, `Kontainer 3`:**

| Elemen | Tipe | Isi / Constraint | State pada PNG | Saran Selector | `data-testid` |
|---|---|---|---|---|---|
| Heading card | Heading | `Kontainer 1` / `Kontainer 2` / `Kontainer 3` | — | `getByRole('heading', { name: 'Kontainer 1' })` | `card-kontainer-1` |
| Tambahkan Asuransi | Checkbox + helper | helper `Berlaku untuk seluruh barang pada armada ini` (kata **armada**, ASM-029) | **checked** (Kontainer 1), unchecked (2 & 3) | `card.getByRole('checkbox', { name: 'Tambahkan Asuransi' })` | `checkbox-asuransi-kontainer-1` |
| Nomor DO | Chips input | chip `TGK783898202U ×`, `TBL28371302 ×`; helper `Pisahkan dengan koma untuk menambahkan beberapa nomor`; placeholder kosong `Masukkan Nomor DO` (Kontainer 3) | filled (K1,K2) / empty (K3) | `card.getByLabel('Nomor DO')` | `input-nomor-do-kontainer-1` |
| Chip Nomor DO — hapus | Icon button (×) di chip | — | enabled | `card.getByTestId('chip-do-TGK783898202U').getByRole('button')` | `chip-do-<nomor>` |
| Tabel barang | Table | header: `Kode SKU / Nama Barang`, `Kemasan`, `Kubikasi / Dimensi`, `Berat`, `Jumlah`, `Nilai Barang` (**hanya bila asuransi aktif**) | — | `card.getByRole('table')` | `table-barang-kontainer-1` |
| Kolom read-only | Cell | `SKU-PPR-001` / `Kertas HVS A4 80 gsm`, `Dus`, `0,018 m³` / `31 × 22 × 26,4 cm`, `12,5 kg` | read-only | `row.getByText('SKU-PPR-001')` | `cell-kode-sku` |
| **Jumlah** | Number input per baris | value `200`, `200`, `0` | K1: filled; **K2 baris 3: error** | `row.getByLabel('Jumlah')` atau `row.getByTestId('input-jumlah')` | `input-jumlah-<sku>` |
| **Nilai Barang** | Currency input per baris (prefix `Rp`) | `0`, `0`, `1.320.000` | **K1 baris 1: error**; kolom **tidak ada** di K2/K3 (asuransi off) | `row.getByTestId('input-nilai-barang')` | `input-nilai-barang-<sku>` |
| Icon hapus baris | Icon button (trash merah) | REQ-021 | enabled | `row.getByRole('button', { name: /hapus/i })` | `btn-hapus-barang-<sku>` |
| Pilih Barang | Button (outline biru, + icon) | membuka modal Pilih Barang | enabled | `card.getByRole('button', { name: 'Pilih Barang' })` | `btn-pilih-barang-kontainer-1` |
| Alert kapasitas | Inline alert (badge merah) | `Kubikasi melebihi kapasitas armada` (K1), `Berat melebihi kapasitas armada` (K2) | tampil | `card.getByText('Kubikasi melebihi kapasitas armada')` | `alert-kapasitas-kontainer-1` |
| Ringkasan kapasitas | Text | `Total Kubikasi: 19,2 / 17,86 m³ • Total Berat: 19.200 / 24.800 kg` | — | `card.getByText(/Total Kubikasi:/)` | `text-total-kubikasi-kontainer-1` |
| Empty state tabel | Text row | `Belum ada barang. Klik "Pilih Barang "` (Kontainer 3) | **empty** | `card.getByText(/Belum ada barang/)` | `empty-state-barang-kontainer-3` |

**Pesan validasi yang terlihat (verbatim):**

| Pesan | Lokasi | Trigger | Selector assert |
|---|---|---|---|
| `Nilai Barang harus diisi` | helper error di bawah input Nilai Barang, border merah | asuransi aktif + Nilai Barang kosong/0 | `getByText('Nilai Barang harus diisi')` |
| `Jumlah harus diisi` | helper error di bawah input Jumlah, border merah | Jumlah kosong/0 | `getByText('Jumlah harus diisi')` |
| `Kubikasi melebihi kapasitas armada` | badge merah di footer card | total kubikasi > kapasitas | `getByText('Kubikasi melebihi kapasitas armada')` |
| `Berat melebihi kapasitas armada` | badge merah di footer card | total berat > kapasitas | `getByText('Berat melebihi kapasitas armada')` |

> Spec (REQ-023) menuliskan **"kapasitas kontainer"**, desain menuliskan **"kapasitas armada"**, dan varian gabungan **"Kubikasi dan Berat melebihi…"** tidak terlihat pada PNG manapun → **ASM-029**.

**Footer aksi Step 2:** `Batal` · `Sebelumnya` (outline + arrow kiri) · `Simpan ke Draf` · `Selanjutnya` (primary).
Selector: `getByRole('button', { name: 'Sebelumnya' })` → `btn-sebelumnya`.

---

### S-10 — Step 2 Data Barang, tipe Multi (073 Multipickup, 081 Multidrop, 089 Multipoint)

Struktur sama dengan S-09, dengan **sub-card per titik** di dalam tiap card kontainer:

| Elemen | Tipe | Isi terlihat | Saran Selector | `data-testid` |
|---|---|---|---|---|
| Header sub-card (Multipickup) | Banner biru muda | `Pick Up 1  -  Jl. Jambi No.35, Darmo, Wonokromo, Kota Surabaya, Jawa Timur 60241` | `card.getByText(/^Pick Up 1/)` | `subcard-pickup-1-kontainer-1` |
| Header sub-card (Multidrop) | Banner biru muda | `Drop Off 1  -  Jl. Jambi No.35, …` | `card.getByText(/^Drop Off 1/)` | `subcard-dropoff-1-kontainer-1` |
| Header sub-card (Multipoint) | Banner biru muda **2 kolom** | kiri `Pick Up 1 - …`, kanan `Drop Off 1 - …` (kombinasi kartesian: PU1×DO1, PU1×DO2, PU2×DO1, PU2×DO2) | `card.getByTestId('subcard-pu1-do2')` | `subcard-pu<i>-do<j>-kontainer-<n>` |
| Nomor DO, tabel barang, Pilih Barang, alert kapasitas | idem S-09 | tiap sub-card punya set sendiri | scoping via sub-card locator | `…-pu<i>-do<j>` |

**Catatan Playwright:** karena label field (`Nomor DO`, `Jumlah`, `Nilai Barang`) **berulang puluhan kali** pada satu halaman (089 Multipoint memiliki 8 sub-card), **wajib** melakukan scoping berlapis: `page.getByTestId('card-kontainer-2').getByTestId('subcard-pu2-do1').getByTestId('input-jumlah-SKU-PPR-001')`. Ini alasan utama `data-testid` per-sub-card diusulkan (ASM-041).

---

### S-11 — Modal "Hitung Ulang Kontainer" (062)

| Elemen | Tipe | Isi terlihat | State | Saran Selector | `data-testid` |
|---|---|---|---|---|---|
| Dialog | Drawer/Modal (slide kanan) | judul `Hitung Ulang Kontainer`, subjudul `Simulasi ulang kebutuhan unit dari muatan order ini. Terapkan untuk ubah data order.` | open | `getByRole('dialog', { name: 'Hitung Ulang Kontainer' })` | `modal-hitung-ulang-kontainer` |
| Ringkasan | Read-only trio | `Total Kubikasi 22,8 m³`, `Total Berat 12.140 kg`, `Jenis Pengiriman FCL` | — | `dialog.getByText('22,8 m³')` | `summary-total-kubikasi` |
| Jenis Kontainer * | Text (read-only) + button | value `20 Feet Dry` | read-only | `dialog.getByLabel('Jenis Kontainer')` | `input-jenis-kontainer` |
| Pilih Jenis Kontainer | Button (outline) | membuka picker jenis kontainer | enabled | `dialog.getByRole('button', { name: 'Pilih Jenis Kontainer' })` | `btn-pilih-jenis-kontainer` |
| Jumlah Kontainer * | Number input + stepper `−` / `+` | value `2` | enabled | `dialog.getByLabel('Jumlah Kontainer')` | `input-jumlah-kontainer` |
| Stepper − / + | Icon buttons | — | enabled | `dialog.getByRole('button', { name: '+' })` | `btn-jumlah-plus` / `btn-jumlah-minus` |
| Info kapasitas | Text | `Berat Maksimal 1 Kontainer: 28.280 kg • Kubikasi Maksimal 1 Kontainer: 38,27 m³` | — | `dialog.getByText(/Berat Maksimal 1 Kontainer/)` | `text-kapasitas-maks` |
| Tab unit visualisasi | Tabs | `Kontainer 1` (aktif), `Kontainer 2` | tab 1 active | `dialog.getByRole('tab', { name: 'Kontainer 2' })` | `tab-visualisasi-kontainer-2` |
| Progress `Berat Terpakai` | Progress bar + `78%` | hijau | — | `dialog.getByTestId('progress-berat')` | `progress-berat-terpakai` |
| Progress `Ruang Terpakai` | Progress bar + `82%` | biru | — | `dialog.getByTestId('progress-ruang')` | `progress-ruang-terpakai` |
| Canvas 3D | Canvas/WebGL | overlay kiri `1306 koli • 19.995 kg dialokasikan ke unit ini`; overlay kanan `Drag: putar 360° • Scroll: zoom • Klik 2×: reset` | rendered | `dialog.getByTestId('canvas-visualisasi')` | `canvas-visualisasi` |
| Legend | Color legend | `Kertas HVS A4 80 gsm` (oranye), `Kertas HVS F4 70 gsm` (biru), `Buku Tulis 38 Lembar` (hijau) | — | `dialog.getByTestId('legend-visualisasi')` | `legend-visualisasi` |
| Batal | Button (outline merah) | — | enabled | `dialog.getByRole('button', { name: 'Batal' })` | `btn-batal-hitung-ulang` |
| Terapkan ke Order | Button (primary) | mengubah data order | enabled | `dialog.getByRole('button', { name: 'Terapkan ke Order' })` | `btn-terapkan-ke-order` |

---

### S-12 — Modal "Visualisasi Muatan Saat Ini" (063)

Identik struktur dengan S-11, dengan perbedaan:

| Elemen | Perbedaan vs S-11 | Saran Selector | `data-testid` |
|---|---|---|---|
| Judul dialog | `Visualisasi Muatan Saat Ini` | `getByRole('dialog', { name: 'Visualisasi Muatan Saat Ini' })` | `modal-visualisasi-muatan` |
| Blok Kontainer | **Read-only 4 kolom**: `Jenis Kontainer 20 Feet Dry`, `Jumlah Kontainer 2`, `Berat Maksimal 28.280 kg`, `Kubikasi Maksimal 38,27 m³` (tanpa input/stepper) | `dialog.getByText('28.280 kg')` | `summary-kontainer` |
| Badge peringatan pada canvas | `110 koli melebihi kapasitas (outline merah)` — koli berlebih dirender outline merah | `dialog.getByText(/koli melebihi kapasitas/)` | `badge-koli-melebihi-kapasitas` |
| Footer | `Batal` + `Terapkan ke Order` (sama) | — | — |

**Pesan/indikator terlihat:** `110 koli melebihi kapasitas (outline merah)` — status **overflow/warning**.

---

### S-13 — Step 3 Vendor dan Harga (064 Normal-kosong, 074 / 082 / 090 terisi)

| Elemen | Tipe | Label / Isi | State | Saran Selector | `data-testid` |
|---|---|---|---|---|---|
| Card | Section | `Vendor dan Harga` | — | `getByRole('heading', { name: 'Vendor dan Harga' })` | `card-vendor-harga` |
| Vendor * | Dropdown | `Pilih Vendor` (064) / `PT Logistik Transportasi Nusantara` (074/082/090) | empty → filled | `getByLabel('Vendor')` | `select-vendor` |
| Tanggal Permintaan Muat * | Datetime input | placeholder `DD/MM/YYYY hh:mm` (064) / `24/07/2026 14:30` | empty → filled | `getByLabel('Tanggal Permintaan Muat')` | `input-tanggal-permintaan-muat` |
| Ringkasan `Drop Point Asal` | Label + value | `Gudang MSK Region 2 • Kota Surabaya` (064) / `Multipickup` + link `Lihat Detail` (074, 090) | read-only | `getByText('Drop Point Asal')` | `text-droppoint-asal` |
| Ringkasan `Drop Point Tujuan` | Label + value | `Gudang Jaya Retail Lampung • Kota Bandar Lampung` / `Multidrop` + link `Lihat Detail` (082, 090) | read-only | `getByText('Drop Point Tujuan')` | `text-droppoint-tujuan` |
| **Lihat Detail** | Text link | membuka modal Detail Multipickup/Multidrop (REQ-027) | link | `getByRole('link', { name: 'Lihat Detail' }).first()` | `link-lihat-detail-asal` / `link-lihat-detail-tujuan` |
| Ringkasan jenis unit | Label + value | `Jenis Kontainer : 20 DRY` (064) **vs** `Jenis Armada : Tronton Wing Box` (074/082/090) | read-only | `getByText(/Jenis (Kontainer\|Armada)/)` | `text-jenis-unit` |
| Tabel ringkasan unit | Table | kolom `No`, `Nama Item`, `Total Berat`, `Total Kubikasi`, `Total Nilai Barang`; baris `Kontainer 1` / `Kontainer 2`; nilai `Tanpa Asuransi` atau `Rp1.150.350.000` | — | `getByRole('table')` | `table-ringkasan-unit` |
| Harga * | Currency input (prefix `Rp`) | `0` (064, helper `Mencakup seluruh biaya armada pada order ini`) / `30.000.000` | empty → filled | `getByLabel('Harga')` | `input-harga` |
| Gunakan komponen harga | Checkbox | label persis **`Gunakan komponen harga`** (huruf kecil, beda dari spec "Gunakan Komponen Harga") | unchecked (064) / **checked** (074/082/090) | `getByRole('checkbox', { name: 'Gunakan komponen harga' })` | `checkbox-komponen-harga` |
| PPN | Number input + suffix `%` | `1,1` | muncul saat checkbox aktif | `getByLabel('PPN')` | `input-ppn` |
| PPh | Number input + suffix `%` | `2` | muncul saat checkbox aktif | `getByLabel('PPh')` | `input-pph` |
| Asuransi (Edit Order) | Number input + suffix `%` | `0,2` — terlihat pada 068/078/086/095 | muncul bila ada kontainer diasuransikan | `getByLabel('Asuransi')` | `input-asuransi-persen` |
| Panel kalkulasi | Read-only list | `Harga DPP Rp. 30.000.000`, `PPN (1,1%) Rp. 330.000`, `PPh (2%) - Rp. 600.000`, `Total Harga Rp. 29.730.000` | — | `getByText('Total Harga')` | `panel-kalkulasi-harga` |
| **Simpan data ke master harga** | Checkbox | terlihat di **background modal** 075/083/091/092 | unchecked | `getByRole('checkbox', { name: 'Simpan data ke master harga' })` | `checkbox-simpan-master-harga` |
| Section **Kalkulasi Harga** | Section heading | terlihat di background modal 075/083/091/092 | — | `getByRole('heading', { name: 'Kalkulasi Harga' })` | `section-kalkulasi-harga` |
| Footer aksi | Buttons | `Batal` · `Sebelumnya` · `Simpan ke Draf` · `Selanjutnya` | Selanjutnya enabled | `getByRole('button', { name: 'Selanjutnya' })` | `btn-selanjutnya` |

**State terlihat:** *empty* (064: Vendor & Tanggal kosong, Harga `Rp 0`, `Total Harga Rp. 0`) dan *filled* (074/082/090).
**Tidak terlihat:** input **Waktu Perjalanan** pada Step 3 → konsisten REQ-029/VAL-11 (assert `getByLabel('Waktu Perjalanan')` **not visible**).

---

### S-14 — Modal "Detail Multipickup" / "Detail Multidrop" (075, 083, 091, 092)

| Elemen | Tipe | Isi terlihat | Saran Selector | `data-testid` |
|---|---|---|---|---|
| Dialog | Modal | judul `Detail Multipickup` (075, 091) / `Detail Multidrop` (083, 092) | `getByRole('dialog', { name: 'Detail Multipickup' })` | `modal-detail-multipickup` |
| Tutup | Icon button (×) | — | `dialog.getByRole('button', { name: /tutup|close/i })` | `btn-close-modal` |
| Item titik | Heading link + alamat | `Pick Up 1 - Kota Surabaya` → `Gudang MSK Region 2:` → `Jl. Jambi No.35, Darmo, Wonokromo, Kota Surabaya, Jawa Timur 60241` | `dialog.getByText('Pick Up 1 - Kota Surabaya')` | `item-titik-1` |
| Item titik (multidrop) | Heading link + alamat | `Drop Off 1 - Kota Bandar Lampung` / `Drop Off 2 - Kab. Lampung Tengah` (092) | `dialog.getByText(/^Drop Off 2/)` | `item-titik-2` |

**State:** read-only, tanpa button aksi (hanya close).

---

### S-15 — Step 4 Review (065 Normal, 076 Multipickup, 084 Multidrop, 093 Multipoint)

Seluruh section **collapsible** (chevron `^` di kanan heading) dan **read-only**.

| Section | Elemen / Field terlihat | Saran Selector | `data-testid` |
|---|---|---|---|
| `Jenis Pengiriman dan Rute` | `Jenis Pengiriman : FCL (Full Container Load)`, `Jenis Kontainer : 20ft Dry Box`, `Jumlah Kontainer : 2`, `Pelabuhan Asal : Tanjung Perak (SUB)`, `Pelabuhan Tujuan : Panjang (PNJ)`, `Tipe Pengiriman : Normal/Multipickup/…`, `Metode Pengiriman : Door to Door` | `getByRole('heading', { name: 'Jenis Pengiriman dan Rute' })` | `section-rute` |
| `Data Pengirim` | `Drop Point Asal`, `Pengirim`, `PIC Pengirim`, `No. WhatsApp PIC`, `Provinsi Asal`, `Kota/Kab. Asal`, `Kecamatan Asal`, `Desa/Kelurahan Asal`, `Kode Pos`, `Alamat Asal`, `Catatan` — pada tipe multi dikelompokkan `Pick Up 1` / `Pick Up 2` | `getByRole('heading', { name: 'Data Pengirim' })` | `section-data-pengirim` |
| `Data Penerima` | cermin Data Pengirim; multi → `Drop Off 1` / `Drop Off 2` | `getByRole('heading', { name: 'Data Penerima' })` | `section-data-penerima` |
| `Data Barang` | button **`Visualisasi Muatan`** (outline biru + icon mata) di dalam card; heading `Kontainer 1`, `Kontainer 2` + badge **`Diasuransikan`**; `Nomor DO` (`TBL67827879232, TBL726378927398` atau `-`); tabel `Kode SKU/Nama Barang`, `Kemasan`, `Kubikasi/Dimensi`, `Berat`, `Jumlah`, `Nilai Barang` (hanya kontainer berasuransi) | `getByRole('button', { name: 'Visualisasi Muatan' })` | `btn-visualisasi-muatan` |
| `Vendor dan Harga` | tabel ringkasan unit (`No`, `Nama Item`, `Total Berat`, `Total Kubikasi`, `Total Nilai Barang` — nilai `Tanpa Asuransi` / `Rp494.250.000`); `Vendor : PT Logistik Transportasi Nusantara`; `Tanggal Permintaan Muat : 24/07/2026 14:30`; panel `Harga DPP Rp. 12.000.000`, `PPN (1,1%) Rp. 132.000`, `PPh (2%) - Rp. 240.000`, `Asuransi (0,2%) Rp2.013.500` + sub-teks `(Total Nilai Barang = Rp1.006.750.000)`, `Total Harga Rp13.905.500` | `getByText('Total Harga')` | `section-vendor-harga` |
| Badge `Diasuransikan` | Chip biru di samping `Kontainer 2` | `getByText('Diasuransikan')` | `badge-diasuransikan-kontainer-2` |
| Footer aksi | `Batal` · `Sebelumnya` · `Simpan ke Draf` · **`Simpan`** (primary) | `getByRole('button', { name: 'Simpan', exact: true })` | `btn-simpan` |

**Struktur Data Barang pada tipe multi (076/084/093):** setiap kontainer berisi sub-blok per titik (`Pick Up 1 - <alamat>`, `Drop Off 2 - <alamat>`, atau kombinasi keduanya pada Multipoint), masing-masing dengan `Nomor DO` + tabel barang tersendiri — struktur cermin S-10.

---

### S-16 / S-17 — Detail Order (066, 077, 085, 094 = Menunggu Penugasan; 067 = Ditugaskan)

| Elemen | Tipe | Isi terlihat | State | Saran Selector | `data-testid` |
|---|---|---|---|---|---|
| Judul + back | Heading + icon `‹` | `‹ Detail Order` | — | `getByRole('heading', { name: 'Detail Order' })` | `page-detail-order` |
| Badge status | Chip (kanan atas card rute) | `Menunggu Penugasan` (biru) / `Ditugaskan` (ungu) | — | `getByTestId('chip-status-order')` | `chip-status-order` |
| **Visualisasi Muatan** | Button (outline biru + icon mata) | **hanya pada 067 (Ditugaskan) dan 077/085/094** | enabled | `getByRole('button', { name: 'Visualisasi Muatan' })` | `btn-visualisasi-muatan` |
| Batalkan Order | Button (outline merah) | REQ-047 | enabled | `getByRole('button', { name: 'Batalkan Order' })` | `btn-batalkan-order` |
| **Edit Order** | Button (outline biru) | **tampil juga saat status Ditugaskan (067)** — konflik REQ-043 (ASM-033) | enabled | `getByRole('button', { name: 'Edit Order' })` | `btn-edit-order` |
| `ID Order` | Read-only | `ORD67890792` | — | `getByText('ORD67890792')` | `text-id-order` |
| `Tanggal Dibuat` | Read-only | `26/06/2026 08:17` (muncul pada 077/085/094, tidak pada 066/067) | — | `getByText('Tanggal Dibuat')` | `text-tanggal-dibuat` |
| **`Waktu Perjalanan`** | Read-only | **`8 Jam`** — **hanya pada 067 (status Ditugaskan)** | conditional | `getByText('Waktu Perjalanan')` | `text-waktu-perjalanan` |
| Section `Data Pengirim` / `Data Penerima` / `Data Barang` / `Vendor dan Harga` | Collapsible read-only | struktur identik Step 4 (S-15) | — | idem S-15 | idem S-15 |
| Badge `Diasuransikan` | Chip | di samping `Kontainer 2` | — | `getByText('Diasuransikan')` | `badge-diasuransikan` |

**Catatan:** `Waktu Perjalanan = 8 Jam` (satuan **jam**) bertentangan dengan formula `ETA − ETD + 4 hari` (REQ-029) → **ASM-034**. **No. Perjalanan tidak terlihat** pada halaman Detail Order manapun meski REQ-060 mensyaratkannya → **ASM-035**.

---

### S-18 — Edit Order (068 Normal, 078 Multipickup, 086 Multidrop, 095 Multipoint)

| Elemen | Tipe | Isi / Constraint | State | Saran Selector | `data-testid` |
|---|---|---|---|---|---|
| Judul halaman | Heading | `Edit Order` (breadcrumb `Beranda > Daftar Order > Edit Order`) | — | `getByRole('heading', { name: 'Edit Order' })` | `page-edit-order` |
| `ID Order`, `Tanggal Dibuat`, `Jenis Pengiriman`, `Tipe Pengiriman`, `Metode Pengiriman`, `Waktu Perjalanan` | Read-only text (bukan input) | `ORD67890792`, `26/06/2026 08:17`, `FCL (Full Container Load)`, `Normal/Multipickup/…`, `Door to Door`, `8 Jam` | **locked** (REQ-044) | `getByText('Jenis Pengiriman')` | `text-jenis-pengiriman-locked` |
| Pelabuhan Asal * / Pelabuhan Tujuan * | Dropdown | `Tanjung Perak (SUB)` / `Panjang (PNJ)` — **editable pada 078/086/095**, **tidak dirender pada 068** | enabled (multi) | `getByLabel('Pelabuhan Asal')` | `select-pelabuhan-asal` |
| Jenis Kontainer * | Dropdown | `20ft Dry Box` / `20 DRY` | **editable** | `getByLabel('Jenis Kontainer')` | `select-jenis-kontainer` |
| Jumlah Kontainer * | Number input | `1` (068) / `2` (078/086/095) | **editable** | `getByLabel('Jumlah Kontainer')` | `input-jumlah-kontainer` |
| Section `Data Pengirim` / `Data Penerima` | Form (collapsible) | seluruh field terisi & **editable**; field wilayah tetap disabled (auto-fill); ada `Tambah Baris Input` pada tipe multi | editable | idem S-05/S-06 | idem |
| Section `Data Barang - Kontainer 1` / `- Kontainer 2` | Collapsible card | judul **`Data Barang - Kontainer <n>`** (beda dari Step 2 yang hanya `Kontainer <n>`) | editable | `getByRole('heading', { name: 'Data Barang - Kontainer 1' })` | `card-data-barang-kontainer-1` |
| Tambahkan Asuransi | Checkbox | K1 unchecked / K2 checked (068); K1 checked / K2 unchecked (078) | toggle | `card.getByRole('checkbox', { name: 'Tambahkan Asuransi' })` | `checkbox-asuransi-kontainer-<n>` |
| Nomor DO (chips) | Chips input | `TGK783898202U ×`, `TBL28371302 ×` | editable | `card.getByLabel('Nomor DO')` | `input-nomor-do-kontainer-<n>` |
| Tabel barang + `Jumlah` / `Nilai Barang` / icon hapus / `Pilih Barang` | idem S-09 | `200`, `Rp 365.000`, `Rp 405.000`, `Rp 0` | editable | idem S-09 | idem S-09 |
| Alert kapasitas | Inline badge merah | `Kubikasi melebihi kapasitas armada` / `Berat melebihi kapasitas armada` | tampil | `card.getByText(/melebihi kapasitas armada/)` | `alert-kapasitas-kontainer-<n>` |
| Section `Vendor dan Harga` | Form | `Vendor` = `PT Logistik Transportasi Nusantara`, `Tanggal Permintaan Muat` = `24/07/2026 14:30`, tabel ringkasan unit, `Harga` = `Rp 12.000.000` | editable | idem S-13 | idem S-13 |
| Gunakan komponen harga | Checkbox (checked) | menampilkan `PPN 1,1 %`, `PPh 2 %`, **`Asuransi 0,2 %`** | checked | `getByRole('checkbox', { name: 'Gunakan komponen harga' })` | `checkbox-komponen-harga` |
| Panel kalkulasi | Read-only | `Harga DPP Rp. 12.000.000`, `PPN (1,1%) Rp. 132.000`, `PPh (2%) - Rp. 240.000`, `Asuransi (0,2%) Rp2.300.700` + `(Total Nilai Barang = Rp1.150.350.000)`, `Total Harga Rp14.192.700` | — | `getByText(/Total Harga/)` | `panel-kalkulasi-harga` |
| Footer aksi | Buttons | **`Batal`** (outline merah) · **`Simpan`** (primary) — hanya 2 button, tanpa Simpan ke Draf | enabled | `getByRole('button', { name: 'Simpan', exact: true })` | `btn-simpan-edit` |

**Pop up konfirmasi Batal/Simpan (REQ-046) tidak ada PNG** → **ASM-042**.

---

### S-19 — Modal "Pilih Barang" (tidak ada PNG — inventaris turunan spec)

> **Tidak ditemukan satu pun PNG** yang menampilkan modal ini pada 058–095. Inventaris berikut **100% asumsi** dari REQ-010..REQ-015 & VAL-M1..M6 (**ASM-040**) dan **wajib diverifikasi** sebelum test di-generate.

| Elemen | Tipe | Sumber requirement | Saran Selector (asumsi) | `data-testid` (asumsi) |
|---|---|---|---|---|
| Dialog | Modal | REQ-010 | `getByRole('dialog', { name: 'Pilih Barang' })` | `modal-pilih-barang` |
| Pencarian kode/nama barang | Search input | REQ-011 | `dialog.getByPlaceholder(/cari|kode|nama barang/i)` | `input-cari-barang` |
| Checkbox per baris barang | Checkbox | REQ-012 | `dialog.getByRole('row', { name: /SKU-PPR-001/ }).getByRole('checkbox')` | `checkbox-barang-<sku>` |
| Label "Sudah Ditambahkan" | Badge | REQ-013 | `dialog.getByText('Sudah Ditambahkan')` | `badge-sudah-ditambahkan-<sku>` |
| Counter barang terpilih | Text | REQ-014 | `dialog.getByText(/\d+ barang dipilih/i)` | `text-counter-terpilih` |
| Batal | Button | REQ-015 | `dialog.getByRole('button', { name: 'Batal' })` | `btn-batal-pilih-barang` |
| Simpan | Button | REQ-015 | `dialog.getByRole('button', { name: 'Simpan' })` | `btn-simpan-pilih-barang` |
| Empty state hasil pencarian | Text | ASM-040 | `dialog.getByText(/tidak ada|belum ada/i)` | `empty-state-pilih-barang` |

---

### Ringkasan State per Layar

| Layar | default | filled | error/validasi | disabled | empty | loading | success |
|---|---|---|---|---|---|---|---|
| S-01 Daftar Order | ✔ (058) | ✔ | — | — | — (ASM-039) | — | — |
| S-02 Filter | ✔ (069) | — | — | ✔ (Tipe & Metode Pengiriman) | ✔ (semua field kosong) | — | — |
| S-04 Step 1 awal | ✔ (059) | — | — | ✔ (`Selanjutnya`) | ✔ (Tipe Pengiriman) | — | — |
| S-05..S-08 Step 1 | — | ✔ | — (tidak ada PNG error Step 1 — ASM-039) | ✔ (field wilayah auto-fill) | ✔ (droppoint belum dipilih) | — | — |
| S-09 Step 2 | — | ✔ | ✔ (`Jumlah harus diisi`, `Nilai Barang harus diisi`, 2 alert kapasitas) | — | ✔ (`Belum ada barang…`) | — | — |
| S-10 Step 2 multi | — | ✔ | ✔ (alert kapasitas) | — | ✔ (Nomor DO kosong) | — | — |
| S-11/S-12 Modal 3D | ✔ | ✔ | ✔ (`110 koli melebihi kapasitas`) | — | — | — (ASM-039) | — |
| S-13 Step 3 | ✔ (064 kosong) | ✔ (074/082/090) | — | — | ✔ | — | — |
| S-15 Step 4 | ✔ | ✔ | — (read-only) | ✔ (semua read-only) | ✔ (`Nomor DO -`) | — | — |
| S-16/S-17 Detail | ✔ | ✔ | — | ✔ | — | — | — |
| S-18 Edit Order | ✔ | ✔ | ✔ (alert kapasitas) | ✔ (Jenis/Tipe/Metode Pengiriman locked) | — | — | — |

> **Tidak ada PNG** untuk: loading/skeleton, toast sukses, pop up konfirmasi (Batal/Simpan), pop up **Batalkan Order** + field `Alasan Pembatalan`, halaman **Riwayat Pembatalan**, **Riwayat Perubahan**, dan **Batch Order** → ASM-039, ASM-042.

### Temuan Ketidaksesuaian Desain vs Spec (input untuk skenario negatif)

| # | Temuan | PNG | REQ/VAL terdampak | ASM |
|---|---|---|---|---|
| 1 | Field **Metode Pengiriman** ADA di Step 1 OMS (4 radio card, wajib) | 060, 072, 080, 088 + Review/Detail/Edit | REQ-009, VAL-02, AC-004 | ASM-028 |
| 2 | Alert kapasitas memakai kata **"armada"**, bukan "kontainer"; varian gabungan tidak ada | 061, 073, 081, 089, 068, 078, 086, 095 | REQ-023, VAL-09, AC-021..023 | ASM-029 |
| 3 | Floating button **Hitung Ulang Kontainer** & **Visualisasi Muatan Saat Ini** ADA di Step 2 | 061, 073, 081, 089 → modal 062, 063 | ASM-022 (dianulir), REQ-004 | ASM-030 |
| 4 | Status chip memakai **"Isi Data Dasar"** (bukan "Isi Data Pengiriman") dan **"Terkirim"** (bukan "Selesai") | 058, 069, 071, 079, 087 | REQ-038, AC-041 | ASM-031 |
| 5 | Action menu memuat item **"Order Kembali"** yang tidak ada di spec | 069 | REQ-050..052, VAL-25 | ASM-032 |
| 6 | Detail Order status **Ditugaskan** masih menampilkan button **Edit Order** | 067 | REQ-043, VAL-19, AC-045 | ASM-033 |
| 7 | `Waktu Perjalanan` bernilai **"8 Jam"** (satuan jam), bukan hasil `ETA − ETD + 4 hari` | 067, 068, 078, 086, 095 | REQ-029, VAL-12, AC-030 | ASM-034 |
| 8 | Modal Data No. Perjalanan menampilkan **No. Perjalanan identik** untuk 2 kontainer; No. Perjalanan **tidak muncul** di Detail Order | 070; 066/067/077/085/094 | REQ-055, REQ-060, VAL-26 | ASM-035 |
| 9 | Step 3 memakai label **"Jenis Armada : Tronton Wing Box"** pada order FCL | 074, 082, 090 | REQ-002 (satuan Kontainer), ASM-013 | ASM-037 |
| 10 | Step 2 Normal menampilkan **3 card kontainer** padahal `Jumlah Kontainer = 2` | 061 | REQ-005, REQ-055 | ASM-036 |
| 11 | Checkbox **"Simpan data ke master harga"** & section **"Kalkulasi Harga"** tidak disebut spec | 075, 083, 091, 092 (background) | REQ-026, REQ-028 | ASM-043 |

---

## Assumptions Log

| ID | Ambiguitas pada Spec | Asumsi yang Diambil | Dampak / Risiko |
|---|---|---|---|
| ASM-001 | Spec menyebut "Shipper" dan "admin shipper" tanpa mendefinisikan hierarki role. | Diasumsikan terdapat minimal 2 role shipper: **Admin Shipper** (memiliki hak pembatalan) dan **Staff Operasional Shipper** (membuat/mengedit order). Aksi pembatalan eksplisit milik **admin shipper** (REQ-048). | Sedang — matriks role perlu dikonfirmasi ke PO sebelum test role-based access. |
| ASM-002 | Tidak dijelaskan apakah Staff Operasional dapat membatalkan order. | Diasumsikan hak pembatalan mengikuti kebijakan tenant; untuk pengujian, **hanya Admin Shipper** yang dijamin memiliki aksi Batalkan Order. | Sedang. |
| ASM-003 | Tidak dijelaskan apakah vendor dapat melihat No. Perjalanan. | Diasumsikan vendor dapat melihat No. Perjalanan pada konteks penugasannya (nomor melekat pada kontainer yang ditugaskan). | Rendah. |
| ASM-004 | "Rule cascading & minimal baris per tipe pengiriman" tidak dirinci (mengacu TMS). | Diasumsikan minimal baris: **Normal** = 1 pengirim + 1 penerima; **Multipickup** ≥ 2 pengirim; **Multidrop** ≥ 2 penerima; **Multipoint** ≥ 2 pengirim & ≥ 2 penerima. Cascading = Provinsi → Kota → Kecamatan → Droppoint. | **Tinggi** — angka minimal wajib dikonfirmasi ke spesifikasi TMS sebelum menulis skenario negatif. **Terkonfirmasi desain** (072/080/088). |
| ASM-005 | Batas bawah/atas **Jumlah Kontainer** tidak disebut. | Diasumsikan bilangan bulat **≥ 1**, tanpa batas atas eksplisit (dibatasi kewajaran/kuota order tenant). | Rendah. |
| ASM-006 | Batas nilai field **Jumlah** barang tidak disebut. | Diasumsikan bilangan bulat **≥ 1** (nilai 0 dan negatif ditolak). | Sedang. **Terkonfirmasi desain**: nilai `0` memicu `Jumlah harus diisi` (061). |
| ASM-007 | Batas nilai **Nilai Barang** tidak disebut. | Diasumsikan angka **> 0** dalam format mata uang IDR. | Sedang. **Terkonfirmasi desain**: `Rp 0` memicu `Nilai Barang harus diisi` (061). |
| ASM-008 | Kondisi default checkbox "Tambahkan Asuransi" tidak disebut. | Diasumsikan **default tidak tercentang** (opt-in), sehingga kolom Nilai Barang tersembunyi saat Step 2 pertama kali dibuka. | Sedang — mempengaruhi AC-015. |
| ASM-009 | Batas **Tanggal Permintaan Muat** tidak disebut (mengacu TMS). | Diasumsikan tanggal **tidak boleh di masa lalu** (≥ hari ini). | Sedang. |
| ASM-010 | Satuan & format angka Kubikasi/Berat/Dimensi tidak disebut. | Diasumsikan **Kubikasi = m³**, **Berat = kg**, **Dimensi = P × L × T dalam cm**, format angka locale **id-ID** — konsisten dengan modul oms002-master-barang, oms011-simulasi-muatan, dan oms012. | Rendah. **Terkonfirmasi desain** (`0,018 m³`, `31 × 22 × 26,4 cm`, `12,5 kg`). |
| ASM-011 | Tidak dijelaskan filter data pada modal "Pilih Barang". | Diasumsikan hanya barang **milik shipper/tenant yang sedang login** dan berstatus **Aktif** yang tampil. | Sedang. |
| ASM-012 | Perilaku barang berlabel "Sudah Ditambahkan" tidak dijelaskan (masih dapat dipilih atau tidak). | Diasumsikan label bersifat **informatif** dan barang **tetap dapat dipilih/dilepas** untuk kontainer yang sama — mengikuti perilaku yang terverifikasi pada modul kembar **oms012** (ASM-D07 di sana). Label bersifat **per kontainer**. | **Tinggi** — perlu konfirmasi desain FCL; skenario duplikasi barang bergantung pada asumsi ini. |
| ASM-013 | Spec Step 2 menggunakan istilah **"armada"** (checkbox asuransi per armada, Nomor DO per armada) padahal jenis order FCL bersatuan **Kontainer**. | Diasumsikan **"armada" = "kontainer"** pada konteks FCL (teks tersalin dari spec FTL). Seluruh rule per-armada diterapkan **per kontainer**. | **Tinggi** — **desain mengonfirmasi** UI memang memakai kata "armada" pada helper checkbox & alert kapasitas (lihat ASM-029); assertion label harus disesuaikan. |
| ASM-014 | Section "Hak Edit" menyebut field **Jenis Armada & Jumlah Armada** yang dapat diubah, bukan Jenis/Jumlah Kontainer, dan **tidak menyebut Pelabuhan Asal/Tujuan**. | Diasumsikan yang dimaksud adalah **Jenis Kontainer & Jumlah Kontainer**, dan **Pelabuhan Asal/Tujuan juga dapat diubah** selama order masih dapat diedit (tidak termasuk field yang di-lock pada REQ-044). | **Tinggi** — **desain 078/086/095 mengonfirmasi** Pelabuhan Asal/Tujuan editable, namun 068 tidak merendernya (ASM-044). |
| ASM-015 | Aksi yang tersedia untuk status **Proses Pengiriman, Selesai, dan Dibatalkan** tidak dirinci pada spec. | Diasumsikan hanya aksi **Detail** dan **Riwayat Perubahan** (plus **Lihat No. Perjalanan** untuk Proses Pengiriman & Selesai) yang tersedia; Edit, Lanjutkan Pengisian, dan Batalkan Order tidak tersedia. | Sedang — matriks aksi 3 status ini bersifat inferensi. |
| ASM-016 | Perilaku button **Batal** pada wizard Step 1–4 tidak dirinci (hanya "identik TMS"). | Diasumsikan menampilkan **pop up konfirmasi** sebelum meninggalkan pengisian, konsisten dengan perilaku Batal pada Edit Order (REQ-046). | Rendah. |
| ASM-017 | "Input manual maupun batch order" disebut tanpa detail mekanisme batch. | Diasumsikan mekanisme batch **identik dengan TMS** (upload template) dan **di luar cakupan detail modul ini**; hanya dicatat sebagai alur alternatif UF-01.A12. | Sedang. |
| ASM-018 | Tidak dijelaskan dampak perubahan **Jumlah Kontainer** saat Edit Order terhadap data barang yang sudah terisi. | Diasumsikan pengurangan jumlah kontainer **menghapus card kontainer terakhir beserta barangnya** (dengan konfirmasi), penambahan menghasilkan **card kosong** yang perlu diisi. | **Tinggi** — perilaku destruktif; wajib dikonfirmasi ke PO. |
| ASM-019 | Spec **tidak** mencantumkan acceptance criteria eksplisit. | Seluruh AC-001 s.d. AC-066 diturunkan langsung dari requirement dengan format Given/When/Then dan traceability ke REQ. | Rendah. |
| ASM-020 | Besaran **persentase asuransi** tidak disebut pada spec. | Diasumsikan persentase diambil dari **konfigurasi master/komponen harga** (bukan hardcode); pengujian memverifikasi formula `Asuransi = persentase × Total Nilai Barang`, bukan nilai persentasenya. | Sedang. **Desain menunjukkan** input `Asuransi 0,2 %` pada komponen harga Edit Order (068/078/086/095). |
| ASM-021 | Spec baris 6 menyebut button "visualisasi muatan" tanpa label persis dan tanpa merinci isi pop up. | Diasumsikan label button **"Visualisasi Muatan"** pada card Data Barang di Step 4, dan pop up menampilkan **visualisasi penempatan barang per kontainer**. | Sedang. **Terkonfirmasi desain**: label persis `Visualisasi Muatan` (065/076/084/093) dan isi pop up = modal 3D (063). |
| ASM-022 | Berbeda dengan modul FTL (oms012), spec FCL **tidak menyebut** floating button "Hitung Ulang Armada"/"Visualisasi Terbaru" maupun drawer rekomendasi pada Step 2. | Diasumsikan pada FCL tidak ada fitur hitung ulang/rekomendasi unit. | **DIANULIR oleh desain** — lihat **ASM-030**. Requirement tambahan wajib ditambahkan sebelum generate skenario. |
| ASM-023 | Sumber nilai **ETA** dan **ETD** untuk perhitungan `ETA − ETD + 4 hari` tidak dijelaskan. | Diasumsikan ETD/ETA berasal dari **jadwal pelayaran vendor** yang terisi saat proses penugasan; pengujian memverifikasi **formula & waktu kemunculan**, bukan sumber datanya. | Sedang. |
| ASM-024 | Aturan **Pelabuhan Asal & Pelabuhan Tujuan** (wajib/format/relasi) tidak dirinci. | Diasumsikan keduanya **wajib diisi**, dipilih dari master Pelabuhan, dan **Pelabuhan Asal ≠ Pelabuhan Tujuan**. | Sedang — aturan "tidak boleh sama" bersifat inferensi. **Desain mengonfirmasi** keduanya bertanda `*` (059/060). |
| ASM-025 | Format **No. Perjalanan** tidak disebut. | Diasumsikan string **unik hasil generate sistem**; pengujian memverifikasi keunikan, keterikatan pada kontainer, dan jumlah — bukan pola formatnya. Desain menunjukkan pola `TRC########`. | Rendah. |
| ASM-026 | Penomoran pada section Step 2 spec melompat (poin 1, 2, lalu **4**, 5, …) — tidak ada poin 3. | Diasumsikan **tidak ada requirement yang hilang**; penomoran adalah typo pada dokumen sumber. | **Tinggi** — sebaiknya dikonfirmasi ke BA/PO bahwa tidak ada poin 3 yang terpotong. |
| ASM-027 | Spec Step 3 menyebut "ringkasan alamat (label + text link untuk tipe multi)" tanpa menjelaskan isi pop up/halaman tujuan link. | Diasumsikan text link membuka **pop up detail alamat** berisi seluruh titik pickup/drop sesuai tipe pengiriman. | Rendah. **Terkonfirmasi desain**: link berlabel `Lihat Detail` → modal `Detail Multipickup` / `Detail Multidrop` (075/083/091/092). |
| ASM-028 | **Konflik desain vs spec:** REQ-009 menyatakan **Metode Pengiriman tidak ditampilkan pada OMS**, tetapi desain Step 1 (060, 072, 080, 088) menampilkannya sebagai **radio card wajib (4 opsi: Door to Door, Door to CY, CY to CY, CY to Door)** dan nilainya juga tampil di Review (065), Detail Order (066/067), serta Edit Order (068). | Untuk penulisan skenario, **desain dianggap sebagai kebenaran UI** (field **ADA**), sementara REQ-009/VAL-02/AC-004 ditandai sebagai **konflik terbuka** yang harus dikonfirmasi ke BA/PO. Skenario disiapkan dua arah: (a) happy path memilih `Door to Door`; (b) skenario verifikasi kehadiran field sebagai **potential defect**. | **Kritis** — AC-004 tidak dapat dieksekusi apa adanya. Wajib klarifikasi sebelum test dijalankan. |
| ASM-029 | **Konflik teks:** REQ-023 menetapkan alert `"… melebihi kapasitas kontainer"`, tetapi desain menuliskan `"Kubikasi melebihi kapasitas armada"` dan `"Berat melebihi kapasitas armada"`; helper checkbox juga berbunyi `"Berlaku untuk seluruh barang pada armada ini"`. Varian gabungan (`Kubikasi dan Berat melebihi…`) **tidak ditemukan** pada PNG manapun. | Assertion Playwright memakai teks **persis dari desain** (`melebihi kapasitas armada`) dengan catatan defect terhadap REQ-023; varian gabungan tetap diuji berdasarkan spec dan ditandai *unverified by design*. | **Tinggi** — assertion teks akan gagal bila dev mengikuti spec; perlu keputusan final wording. |
| ASM-030 | **Fitur tak terdokumentasi:** Step 2 memiliki **2 floating button** (icon ⟳ dan 👁) yang membuka modal **"Hitung Ulang Kontainer"** (062) dan **"Visualisasi Muatan Saat Ini"** (063), lengkap dengan canvas 3D interaktif, tab per kontainer, progress `Berat Terpakai`/`Ruang Terpakai`, legend warna per SKU, badge `110 koli melebihi kapasitas (outline merah)`, serta button `Batal` / `Terapkan ke Order`. | Diasumsikan ini adalah bagian **add-on Auto Stuffing** yang tidak tertulis di spec (menganulir ASM-022). Requirement tambahan diperlakukan sebagai **REQ turunan desain** dan skenario dibuat berdasarkan elemen yang terlihat. Interaksi canvas 3D (drag/scroll/double-click) **tidak diotomasi** — hanya keberadaan canvas & overlay yang di-assert. | **Tinggi** — cakupan modul bertambah signifikan; perlu konfirmasi scope ke PO. |
| ASM-031 | **Konflik label status:** REQ-038 menyebut status `Isi Data Pengiriman` dan `Selesai`, namun chip pada Daftar Order (058/069/071/079/087) berbunyi **`Isi Data Dasar`** dan **`Terkirim`**. | Diasumsikan `Isi Data Dasar` ≡ `Isi Data Pengiriman` dan `Terkirim` ≡ `Selesai`. Assertion memakai teks desain; mapping dicatat agar AC-041 tetap dapat ditelusuri. | **Tinggi** — assertion status akan gagal bila memakai teks spec. |
| ASM-032 | Action menu pada 069 memuat item **`Order Kembali`** yang tidak disebut sama sekali pada spec (REQ-050..053). | Diasumsikan `Order Kembali` = aksi duplikasi/re-order, **di luar scope modul ini**; keberadaannya dicatat agar assertion "daftar aksi persis" (VAL-25) tidak dianggap gagal. | Sedang — VAL-25 perlu direvisi menjadi "mengandung" alih-alih "persis". |
| ASM-033 | Detail Order berstatus **`Ditugaskan`** (067) masih menampilkan button **`Edit Order`** di header, bertentangan dengan REQ-043/VAL-19/AC-045. | Diasumsikan ini **defect desain**; skenario negatif dibuat untuk memverifikasi bahwa Edit **harus** tidak tersedia pada status Ditugaskan. | **Tinggi** — kandidat bug report. |
| ASM-034 | Detail Order (067) dan Edit Order (068/078/086/095) menampilkan `Waktu Perjalanan : 8 Jam` (satuan **jam**), sedangkan REQ-029 menetapkan `ETA − ETD + 4 hari`. | Diasumsikan nilai `8 Jam` adalah **dummy data desain** yang diwarisi dari template FTL; pengujian hanya memverifikasi **kemunculan field pada status Ditugaskan**, bukan nilainya, sampai formula dikonfirmasi. | **Tinggi** — AC-030 tidak dapat diverifikasi nilainya. |
| ASM-035 | Modal `Data No. Perjalanan` (070) menampilkan **nomor identik** (`TRC79289802`) untuk 2 kontainer berbeda, dan **No. Perjalanan tidak muncul** pada halaman Detail Order manapun meski REQ-060 mensyaratkannya. | Diasumsikan nomor identik = **dummy data desain**; keunikan tetap diuji sesuai VAL-26. Ketiadaan No. Perjalanan di Detail Order dicatat sebagai **gap desain** terhadap REQ-060/AC-064. | **Tinggi** — AC-064 belum memiliki referensi UI. |
| ASM-036 | Step 2 Normal (061) menampilkan **3 card kontainer** (`Kontainer 1..3`) padahal card `Data Unit` menyatakan `Jumlah Kontainer: 2`. Step 1 empty (059) juga belum menampilkan button `Simpan ke Draf`. | Diasumsikan 3 card = **ilustrasi state desain** (filled / error / empty), bukan aturan bisnis; jumlah card sesungguhnya = `Jumlah Kontainer`. Button `Simpan ke Draf` diasumsikan baru muncul setelah Step 1 memiliki data minimal. | Sedang — jumlah card harus diverifikasi lewat data, bukan meniru PNG. |
| ASM-037 | Step 3 pada tipe multi (074/082/090) memakai label **`Jenis Armada : Tronton Wing Box`** pada order FCL; modal 062/063 juga menampilkan latar `Jenis Armada / Tronton Box / Armada 1`. Menu sidebar **`Simulasi Muatan`** hanya muncul pada 062/063. | Diasumsikan sisa template FTL pada mock; untuk FCL label yang benar adalah **`Jenis Kontainer`** dengan nilai jenis kontainer (mis. `20 DRY`), seperti pada 064. Kemunculan menu `Simulasi Muatan` diasumsikan bergantung add-on tenant. | **Tinggi** — assertion label Step 3 berbeda antar PNG; wajib dikonfirmasi. |
| ASM-038 | Tidak ada PNG yang menampilkan action menu untuk status **draft** (`Lanjutkan Pengisian`) maupun **Menunggu Penugasan** (`Edit`). | Nama item menu diasumsikan **persis seperti spec**: `Lanjutkan Pengisian`, `Edit`, `Detail`, `Batalkan Order`, `Riwayat Perubahan`. | Sedang — selector `getByRole('menuitem', …)` belum terverifikasi. |
| ASM-039 | Tidak ada PNG untuk: **empty state daftar order**, **loading/skeleton**, **toast sukses**, dan **error validasi Step 1 & Step 3**. | Diasumsikan pola komponen standar aplikasi: helper error merah di bawah field + border merah (mengikuti pola Step 2 yang terlihat), toast sukses di kanan atas, skeleton row pada tabel. Selector generik disarankan: `getByRole('alert')`, `getByTestId('toast-success')`, `getByTestId('empty-state')`. | Sedang — assertion state ini bersifat inferensi. |
| ASM-040 | **Tidak ada PNG modal "Pilih Barang"** (REQ-010..015) di antara 38 file desain, padahal modal ini adalah **perbedaan inti** OMS vs TMS. | Seluruh inventaris S-19 diturunkan dari spec. Selector, penamaan button, dan format counter (`"N barang dipilih"`) adalah **usulan** dan **wajib** diverifikasi sebelum test di-generate. | **Kritis** — 6 AC (AC-009..AC-012) bergantung pada layar tanpa referensi desain. |
| ASM-041 | Desain tidak menunjukkan atribut DOM apa pun (`id`, `name`, `data-testid`). | Seluruh nilai `data-testid` pada UI Inventory adalah **usulan konvensi** (kebab-case, prefix per layar, suffix indeks kontainer/sub-card/SKU). Strategi utama tetap `getByRole`/`getByLabel` dengan **scoping berlapis** karena label form berulang puluhan kali pada satu halaman (khususnya S-10 Multipoint dengan 8 sub-card). | **Tinggi** — tanpa `data-testid`, selector strict-mode Playwright rawan `strict mode violation`. Perlu koordinasi dengan FE. |
| ASM-042 | Tidak ada PNG untuk **pop up konfirmasi Batal/Simpan** pada Edit Order (REQ-046), **pop up Batalkan Order** + field `Alasan Pembatalan` (REQ-049), halaman **Riwayat Pembatalan** (REQ-053), **Riwayat Perubahan**, dan **Batch Order**. | Diasumsikan dialog konfirmasi standar (`getByRole('dialog')` dengan button `Ya, Simpan` / `Batal`) dan form pembatalan berisi textarea wajib berlabel `Alasan Pembatalan`. Nama button konfirmasi **belum terverifikasi**. | **Tinggi** — AC-048, AC-052, AC-057, AC-058 tanpa referensi desain. |
| ASM-043 | Terlihat di latar modal 075/083/091/092: checkbox **`Simpan data ke master harga`** dan section **`Kalkulasi Harga`** pada Step 3 — keduanya tidak disebut spec, dan tidak terlihat pada PNG Step 3 utama (064/074/082/090). | Diasumsikan elemen ini muncul pada **varian/scroll state Step 3** yang tidak ter-capture penuh; dicatat sebagai elemen tambahan yang perlu diverifikasi, tidak dijadikan AC baru. | Sedang. |
| ASM-044 | Pada Edit Order tipe **Normal** (068), field `Pelabuhan Asal`/`Pelabuhan Tujuan` **tidak dirender** (hanya tampil sebagai read-only text), sedangkan pada tipe multi (078/086/095) keduanya tampil sebagai **dropdown editable**. | Diasumsikan **inkonsistensi mock**; mengikuti ASM-014, Pelabuhan diperlakukan **editable** pada seluruh tipe selama order dapat diedit. | Sedang — mempengaruhi AC-047. |
| ASM-045 | Struktur Step 2 pada tipe **Multipoint** (089) menampilkan sub-card sebagai **kombinasi kartesian** Pick Up × Drop Off (PU1×DO1, PU1×DO2, PU2×DO1, PU2×DO2) di dalam **setiap** kontainer. | Diasumsikan ini adalah aturan resmi: jumlah sub-card per kontainer = `jumlah Pick Up × jumlah Drop Off`. Skenario menghitung sub-card berdasarkan formula tersebut. | **Tinggi** — jumlah elemen yang harus diisi tumbuh cepat; berdampak pada durasi & desain test data. |
