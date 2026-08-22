# Analysis — oms012-order-ftl-auto-stuffing

> Sumber spesifikasi: `inputs/oms012-order-ftl-auto-stuffing/spec.txt`
> Tahap: 1 — Requirements Extraction
> Tanggal analisis: **2026-08-18**
> Mode: AUTO (keputusan ambigu diambil sendiri dan dicatat di **Assumptions Log**)

---

## Ringkasan Modul

Modul ini menjelaskan **proses pengisian data order jenis FTL pada OMS yang memiliki add-on Auto Stuffing**, untuk seluruh tipe pengiriman: **Normal, Multipickup, Multidrop, dan Multipoint**.

Karakteristik utama:

| Aspek | Perilaku |
|---|---|
| Basis rule | Mengacu penuh pada spesifikasi **Order FTL di TMS** (4 step wizard) |
| Perbedaan inti | **Step 2 — Data Barang** diambil dari **Master Barang**, bukan input deskripsi manual |
| Add-on | **Auto Stuffing** hanya aktif bila modul OMS dibeli beserta add-on; berlaku untuk **FTL & FCL** saja |
| Penambahan UI | Floating button **"Hitung Ulang Armada"** & **"Visualisasi Terbaru"** (Step 2), pop up **Visualisasi Muatan** (Step 4) |
| Cakupan logic | Logic auto stuffing **memakai tools eksisting**; OMS hanya mengatur **penempatan barang ke dalam order** |

Alur wizard: **Step 1 Data Pengiriman → Step 2 Data Barang → Step 3 Vendor & Harga → Step 4 Review**.

---

## Requirements

### A. Ketentuan Umum Order FTL (OMS)

| ID | Deskripsi | Sumber (baris/section) | Prioritas |
|---|---|---|---|
| REQ-001 | Modul mencakup proses pengisian data order untuk tipe pengiriman **Normal, Multipickup, Multidrop, dan Multipoint** pada jenis order **FTL** yang di dalamnya terdapat **Auto Stuffing**. | Baris 1 — Intro | Must |
| REQ-002 | Secara keseluruhan sistem mengacu pada spesifikasi **Order FTL di TMS**: definisi FTL, **satuan Armada**, **4 step pengisian** (Data Pengiriman, Data Barang, Vendor & Harga, Review), serta dukungan **input manual maupun batch order**. | Baris 4 — Ketentuan Umum #1 | Must |
| REQ-003 | Perbedaan utama terhadap TMS **hanya pada Step 2 (Data Barang)**: data barang diambil dari **Master Barang**, bukan input deskripsi manual. | Baris 5 — Ketentuan Umum #2 | Must |
| REQ-004 | Add-on **Auto Stuffing hanya aktif** jika modul **OMS dibeli beserta add-on tersebut**. Penerapan **hanya untuk jenis pengiriman FTL & FCL**. | Baris 6 — Ketentuan Umum #3 | Must |
| REQ-005 | **Logic Auto Stuffing menggunakan tools yang sudah ada**; pada OMS sistem hanya mengatur **penempatan barang ke dalam order** (bukan mengulang algoritma packing). | Baris 7 — Ketentuan Umum #4 | Must |
| REQ-006 | Penyesuaian turunan pada **Step 4 (Review)**: informasi Data Barang mengikuti struktur Step 2, dan tersedia informasi **visualisasi muatan berupa pop up** yang tampil saat klik button "Visualisasi Muatan". | Baris 8 — Ketentuan Umum #5 | Must |

### B. Step 1 — Data Pengiriman

| ID | Deskripsi | Sumber (baris/section) | Prioritas |
|---|---|---|---|
| REQ-007 | Step 1 **identik dengan Step 1 Order FTL di TMS**, memuat field: **Jenis Armada**, **Jumlah Armada**, **Tipe Pengiriman** (Normal / Multipickup / Multidrop / Multipoint), **Data Pengirim** & **Data Penerima**. | Baris 11 — Step 1 #1 | Must |
| REQ-008 | **Data Pengirim & Data Penerima auto-draft dari Master Droppoint**. | Baris 11 — Step 1 #1 | Must |
| REQ-009 | Berlaku **rule cascading** dan **minimal baris per tipe pengiriman** sesuai TMS (mis. Multipickup ≥ 2 pengirim, Multidrop ≥ 2 penerima, Multipoint ≥ 2 pengirim & ≥ 2 penerima — lihat ASM-004). | Baris 11 — Step 1 #1 | Must |
| REQ-010 | **Validasi field wajib** dan **fungsi button (Batal / Draf / Selanjutnya)** pada Step 1 berlaku identik dengan TMS. | Baris 11 — Step 1 #1 | Must |

### C. Step 2 — Data Barang (Modal "Pilih Barang")

| ID | Deskripsi | Sumber (baris/section) | Prioritas |
|---|---|---|---|
| REQ-011 | Barang **tidak diinput manual**, melainkan **dipilih dari Master Barang** melalui modal **"Pilih Barang"**. | Baris 14 — Step 2 #1 | Must |
| REQ-012 | Modal "Pilih Barang" menyediakan **pencarian by kode barang / nama barang**. | Baris 16 — Step 2 #2 | Must |
| REQ-013 | Pemilihan barang dapat **multi-select** menggunakan **checkbox**. | Baris 17 — Step 2 #2 | Must |
| REQ-014 | Terdapat label **"Sudah Ditambahkan"** pada barang yang sudah masuk ke **armada terkait** (kontekstual per armada). | Baris 18 — Step 2 #2 | Must |
| REQ-015 | Terdapat **counter jumlah barang terpilih** pada modal. | Baris 19 — Step 2 #2 | Must |
| REQ-016 | Modal menyediakan button **Batal** & **Simpan**. | Baris 20 — Step 2 #2 | Must |
| REQ-017 | Field berikut **auto ter-draft dari Master Barang** dan bersifat **read-only**: **Kode SKU, Nama Barang, Kemasan, Kubikasi, Dimensi, Berat**. | Baris 21 — Step 2 #4 | Must |
| REQ-018 | Field **Jumlah** diinput user per baris barang dan bersifat **wajib diisi**. | Baris 23 — Step 2 #5 | Must |
| REQ-019 | Field **Nilai Barang** **hanya muncul** dan **wajib diisi** saat checkbox **"Tambahkan Asuransi"** pada armada tersebut dicentang. | Baris 24 — Step 2 #5 | Must |
| REQ-020 | Checkbox **"Tambahkan Asuransi"** bersifat **per armada** dan berlaku untuk **seluruh barang pada armada tersebut**; saat dicentang kolom Nilai Barang tampil dan menjadi wajib. | Baris 25 — Step 2 #6 | Must |
| REQ-021 | **Nomor DO per armada**: **tidak wajib**, dapat diisi **lebih dari satu**, **dipisahkan dengan koma**, dan **ditampilkan sebagai chip**. | Baris 26 — Step 2 #7 | Must |
| REQ-022 | Setiap baris barang dapat **dihapus** melalui **icon hapus**. | Baris 27 — Step 2 #8 | Must |
| REQ-023 | **Alert kapasitas armada** (Berat dan/atau Kubikasi melebihi kapasitas maksimal) bersifat **informasi saja** dan **tidak memblokir** proses — user tetap dapat lanjut ke step berikutnya. | Baris 28 — Step 2 #9 | Must |
| REQ-024 | Pesan alert kapasitas mengikuti 3 kondisi: (a) kubikasi berlebih → **"Kubikasi melebihi kapasitas armada"**; (b) berat berlebih → **"Berat melebihi kapasitas armada"**; (c) keduanya → **"Kubikasi dan Berat melebihi kapasitas armada"**. | Baris 29–31 — Step 2 #9 | Must |
| REQ-025 | Jika field wajib (**Jumlah**, atau **Nilai Barang** saat asuransi aktif) tidak diisi → tampilkan **helper error** dan **border field berubah warna error**. | Baris 32 — Step 2 #10 | Must |
| REQ-026 | Tampil informasi **"Data Unit"** berisi **Jenis Armada** & **Jumlah Armada** yang dibawa dari Step 1. | Baris 33 — Step 2 #11 | Must |
| REQ-027 | Terdapat **floating button "Hitung Ulang Armada"** dan **"Visualisasi Terbaru"** yang **tetap mengikuti posisi saat halaman di-scroll**. | Baris 34–35 — Step 2 #12 | Must |
| REQ-028 | Floating button **default menampilkan ikon saja**, dan **menampilkan teks/label saat di-hover**. | Baris 36 — Step 2 #12 | Should |
| REQ-029 | Button **"Hitung Ulang Armada"** **hanya dapat dijalankan** saat **minimal terdapat 1 data barang yang sudah diisi**. | Baris 37 — Step 2 #13 | Must |
| REQ-030 | **Distribusi barang antar armada** mengikuti Logic Auto Stuffing: kubikasi & berat **dioptimalkan mengisi 1 armada hingga maksimal**, baru berpindah ke armada berikutnya, **berulang sampai muatan habis**. | Baris 38 — Step 2 #14 | Must |
| REQ-031 | Pada tipe **Multipickup / Multidrop / Multipoint**, barang **dibagi rata antar alamat dalam 1 armada yang sama**; bila **tidak dapat dibagi rata**, **sisa yang lebih besar ditempatkan pada alamat pertama**. | Baris 39 — Step 2 #15 | Must |
| REQ-032 | Fungsi button **Batal / Draf / Sebelumnya / Selanjutnya** pada Step 2 berlaku **identik dengan Step 2 TMS**. | Baris 40 — Step 2 #16 | Must |

### D. Drawer "Hitung Ulang Armada" & "Visualisasi Terbaru"

| ID | Deskripsi | Sumber (baris/section) | Prioritas |
|---|---|---|---|
| REQ-033 | Drawer **"Hitung Ulang Armada"** menampilkan **Total Kubikasi** & **Total Berat** yang dihitung dari data barang yang diinput. | Baris 44 — Drawer #1 | Must |
| REQ-034 | Drawer menampilkan **Jenis Pengiriman** yang dibawa dari **Step 1**. | Baris 45 — Drawer #1 | Must |
| REQ-035 | Drawer menampilkan **rekomendasi 3 teratas armada** (dari Logic Auto Stuffing) sesuai barang yang diinput, masing-masing dengan indikator **Berat Terpakai** & **Ruang Terpakai**. | Baris 46 — Drawer #1 | Must |
| REQ-036 | Rekomendasi terbaik ditandai label **"Paling Efisien"**. | Baris 46 — Drawer #1 | Must |
| REQ-037 | Field **Jenis Armada** (via modal **"Pilih Jenis Armada"**) dan **Jumlah Armada** (via **input/stepper**) pada drawer **dapat diubah** user. | Baris 47 — Drawer #1 | Must |
| REQ-038 | Drawer menampilkan **Visualisasi Muatan (3D) per armada** yang **memperbarui otomatis** saat Jenis/Jumlah Armada diubah. | Baris 48 — Drawer #1 | Must |
| REQ-039 | Button **"Terapkan ke Order"** pada card menerapkan **Jenis Armada, Jumlah Armada, dan penempatan barang** ke order. | Baris 49 — Drawer #3 | Must |
| REQ-040 | Saat Jenis/Jumlah Armada diubah lalu diterapkan → **data pada Step 1 dan informasi yang dibawa ke Step 2 turut berubah** (sinkronisasi dua arah). | Baris 50 — Drawer #4 | Must |
| REQ-041 | Button **"Batal"** pada drawer **menutup panel tanpa menerapkan perubahan**. | Baris 51 — Drawer #5 | Must |
| REQ-042 | Floating button **"Visualisasi Terbaru"** menampilkan **panel visualisasi muatan** sesuai **Jenis & Jumlah Armada terkini**, **tanpa mengubah pilihan armada**. | Baris 52 — Drawer #6 | Must |

### E. Step 3 — Vendor & Harga

| ID | Deskripsi | Sumber (baris/section) | Prioritas |
|---|---|---|---|
| REQ-043 | Step 3 **sama dengan Step 3 Order FTL di TMS**, memuat: field **Pilihan Vendor**, inputan **Tanggal Permintaan Muat**, inputan **Harga**, **Waktu Perjalanan**, **ringkasan alamat**, dan komponen harga opsional. | Baris 55–61 — Step 3 #1 | Must |
| REQ-044 | **Waktu Perjalanan** memiliki **2 kondisi**: tampil sebagai **textfield** jika rute **belum ada** di master, dan **text-only (read-only)** jika rute **sudah ada** di master. | Baris 59 — Step 3 #1 | Must |
| REQ-045 | **Ringkasan alamat** tampil sebagai **label + text link** untuk tipe pengiriman **multi** (Multipickup/Multidrop/Multipoint). | Baris 60 — Step 3 #1 | Should |
| REQ-046 | **Komponen harga bersifat opsional**, diaktifkan via checkbox **"Gunakan Komponen Harga"**. | Baris 61 — Step 3 #1 | Must |
| REQ-047 | Komponen **Asuransi** mengikuti data Step 2: saat terdapat **armada yang diasuransikan**, nilai Asuransi = **persentase × Total Nilai Barang**, dan turut dihitung ke **Total Harga** di samping **PPN & PPh**. | Baris 62 — Step 3 #2 | Must |
| REQ-048 | **Validasi field wajib** dan **fungsi button (Batal / Draf / Sebelumnya / Selanjutnya)** pada Step 3 **identik dengan TMS**. | Baris 63 — Step 3 #3 | Must |

### F. Step 4 — Review

| ID | Deskripsi | Sumber (baris/section) | Prioritas |
|---|---|---|---|
| REQ-049 | Step 4 menampilkan **ringkasan seluruh data Step 1–3 secara read-only**, sama dengan TMS. | Baris 66 — Step 4 #1 | Must |
| REQ-050 | Bagian **Data Barang** pada Review mengikuti **struktur Step 2 OMS**: menampilkan **Kode SKU, Nama Barang, Kemasan, Kubikasi/Dimensi, Berat, Jumlah**, dan **Nilai Barang** (khusus armada yang diasuransikan). | Baris 67 — Step 4 #2 | Must |
| REQ-051 | Terdapat label **"Diasuransikan"** per armada yang diasuransikan. | Baris 67 — Step 4 #2 | Must |
| REQ-052 | Terdapat **button visualisasi pada card Data Barang** (tambahan dari add-on Auto Stuffing); saat diklik menampilkan **pop up visualisasi muatan**. | Baris 68 — Step 4 #3 | Must |
| REQ-053 | Fungsi button **Batal / Draf / Sebelumnya / Simpan** identik dengan TMS. Aksi **Simpan** mengubah status order menjadi **"Menunggu Penugasan"**. | Baris 69 — Step 4 #4 | Must |

### G. Status Order

| ID | Deskripsi | Sumber (baris/section) | Prioritas |
|---|---|---|---|
| REQ-054 | Order FTL memiliki **9 status**: Isi Data Pengiriman, Isi Data Muatan, Isi Data Vendor, Review Order, Menunggu Penugasan, Ditugaskan, Proses Pengiriman, Selesai, Dibatalkan. | Baris 72–81 — Status #1 | Must |
| REQ-055 | Definisi status: **Isi Data Pengiriman** = belum selesai di step Data Pengiriman; **Isi Data Muatan** = belum selesai di step Data Barang; **Isi Data Vendor** = belum selesai di step Vendor & Harga; **Review Order** = seluruh step terisi namun belum disubmit. | Baris 73–76 — Status #1 | Must |
| REQ-056 | Definisi status lanjutan: **Menunggu Penugasan** = data lengkap & disubmit, menunggu penugasan vendor; **Ditugaskan** = vendor sudah melakukan penugasan; **Proses Pengiriman** = status penugasan armada "Dalam Perjalanan"; **Selesai** = seluruh armada selesai bongkar; **Dibatalkan** = order dibatalkan oleh admin shipper. | Baris 77–81 — Status #1 | Must |
| REQ-057 | Status **1–4 (Isi Data Pengiriman s.d. Review Order)** merupakan **kondisi draft**, tersimpan otomatis melalui aksi **"Simpan ke Draf"** pada **step manapun**. | Baris 82 — Status #2 | Must |

### H. Hak Edit Order FTL

| ID | Deskripsi | Sumber (baris/section) | Prioritas |
|---|---|---|---|
| REQ-058 | **Shipper dapat mengubah data order** selama status berada dalam rentang **draft (Isi Data Pengiriman s.d. Review Order) hingga "Menunggu Penugasan"**. | Baris 85 — Hak Edit #1 | Must |
| REQ-059 | Shipper **tidak dapat lagi mengubah** data order setelah status berubah menjadi **"Ditugaskan"**. | Baris 86 — Hak Edit #2 | Must |
| REQ-060 | Pada halaman **Edit Order**, field **Jenis Pengiriman** dan **Tipe Pengiriman** bersifat **locked/read-only** dan tidak dapat diubah. | Baris 87 — Hak Edit #3 | Must |
| REQ-061 | Field **Jenis Armada, Jumlah Armada, Data Pengirim, Data Penerima, Data Barang, dan Vendor & Harga** **tetap dapat diubah** selama order berstatus dapat diedit (REQ-058). | Baris 88 — Hak Edit #4 | Must |
| REQ-062 | Pada Edit Order, button **Batal** (membatalkan pengisian data) dan **Simpan** (menyelesaikan pengeditan) **masing-masing menampilkan pop up konfirmasi**. | Baris 90–91 — Hak Edit #5 | Must |

### I. Pembatalan Order

| ID | Deskripsi | Sumber (baris/section) | Prioritas |
|---|---|---|---|
| REQ-063 | Order dapat **dibatalkan** selama status berada dalam rentang **draft hingga "Ditugaskan"**; **tidak dapat dibatalkan** setelah status **"Proses Pengiriman"**. | Baris 95 — Pembatalan #1 | Must |
| REQ-064 | Pembatalan order **dilakukan oleh admin shipper**, **bukan oleh vendor**. | Baris 96 — Pembatalan #2 | Must |
| REQ-065 | Field **"Alasan Pembatalan"** **wajib diisi** saat melakukan pembatalan. | Baris 97 — Pembatalan #3 | Must |

### J. Aksi pada Daftar Order FTL

| ID | Deskripsi | Sumber (baris/section) | Prioritas |
|---|---|---|---|
| REQ-066 | Pada status **Isi Data Pengiriman / Isi Data Muatan / Isi Data Vendor / Review Order**, aksi tersedia: **Detail, Lanjutkan Pengisian, Batalkan Order, Riwayat Perubahan**. | Baris 101 — Aksi #1 | Must |
| REQ-067 | Pada status **Menunggu Penugasan**, aksi tersedia: **Detail, Edit, Batalkan Order, Riwayat Perubahan**. | Baris 102 — Aksi #1 | Must |
| REQ-068 | Pada status **Ditugaskan**, aksi tersedia: **Detail, Batalkan Order, Riwayat Perubahan, Lihat No. Perjalanan** — aksi **Edit tidak tersedia**. | Baris 103 — Aksi #1 | Must |
| REQ-069 | Tombol **"Riwayat Pembatalan"** pada **toolbar** halaman Daftar Order menampilkan **daftar seluruh order yang pernah dibatalkan**, **terpisah** dari aksi per-baris **"Riwayat Perubahan"** yang menampilkan histori perubahan order tertentu. | Baris 104 — Aksi #2 | Must |

### K. No. Perjalanan

| ID | Deskripsi | Sumber (baris/section) | Prioritas |
|---|---|---|---|
| REQ-070 | **Nomor Perjalanan** digunakan untuk pengecekan pada **public tracking** sehingga pengirim/penerima dapat mengetahui progress perjalanan armada/kontainer yang dipesan. | Baris 107 — No. Perjalanan #1 | Must |
| REQ-071 | Nomor Perjalanan **di-generate otomatis oleh sistem** dan **melekat pada armada/kontainer**; **jumlahnya menyesuaikan jumlah armada/kontainer** yang dipesan. | Baris 108 — No. Perjalanan #2 | Must |
| REQ-072 | Nomor Perjalanan **hanya tampil untuk jenis pengiriman FTL & FCL**. | Baris 109 — No. Perjalanan #3 | Must |
| REQ-073 | Aksi **"Lihat No. Perjalanan"** pada action menu order **baru tampil setelah proses penugasan dilakukan** (status **"Ditugaskan"**). | Baris 110 — No. Perjalanan #4 | Must |
| REQ-074 | Klik aksi tersebut menampilkan **pop up "Data No. Perjalanan"** berisi, per armada/kontainer: **No. Perjalanan** (hasil generate sistem), **Nopol/No. Kontainer**, dan **Jenis Armada/Kontainer**. | Baris 111 — No. Perjalanan #5 | Must |
| REQ-075 | Pada pop up, **No. Perjalanan dilengkapi icon copy** untuk menyalin nomor perjalanan. | Baris 112 — No. Perjalanan #6 | Should |
| REQ-076 | Selain melalui action menu, **No. Perjalanan juga dapat dilihat pada halaman Detail Order**. | Baris 113 — No. Perjalanan #7 | Must |

**Total: 76 requirement.**

---

## Validation Rules

### 1. Field-level — Step 1 (Data Pengiriman)

| Field | Tipe Input | Wajib | Format / Aturan | Range / Batasan | Catatan |
|---|---|---|---|---|---|
| Jenis Pengiriman | Dropdown / preset | Ya | Nilai relevan modul: **FTL** | — | Locked saat Edit Order (REQ-060) |
| Tipe Pengiriman | Radio / Dropdown | Ya | `Normal` \| `Multipickup` \| `Multidrop` \| `Multipoint` | 4 opsi | Locked saat Edit Order (REQ-060) |
| Jenis Armada | Read-only field + modal "Pilih Jenis Armada" | Ya | Dipilih dari master Armada | — | Dapat di-override via drawer Hitung Ulang Armada (REQ-037) |
| Jumlah Armada | Number / stepper | Ya | Bilangan bulat positif | **≥ 1** (ASM-005) | Dapat di-override via drawer (REQ-037) |
| Data Pengirim (alamat) | Baris alamat dari Master Droppoint | Ya | Auto-draft dari Master Droppoint | Normal: 1; Multipickup/Multipoint: **≥ 2** (ASM-004) | Cascading (REQ-009) |
| Data Penerima (alamat) | Baris alamat dari Master Droppoint | Ya | Auto-draft dari Master Droppoint | Normal: 1; Multidrop/Multipoint: **≥ 2** (ASM-004) | Cascading (REQ-009) |

### 2. Field-level — Step 2 (Data Barang)

| Field | Tipe Input | Wajib | Format / Aturan | Range / Batasan | Catatan |
|---|---|---|---|---|---|
| Kode SKU | Text (read-only) | — | Dari Master Barang | — | Tidak dapat diedit (REQ-017) |
| Nama Barang | Text (read-only) | — | Dari Master Barang | — | Tidak dapat diedit |
| Kemasan | Text (read-only) | — | Dari Master Barang | — | Tidak dapat diedit |
| Kubikasi | Number (read-only) | — | Satuan **m³** | — | Dari Master Barang; format id-ID (ASM-011) |
| Dimensi | Text (read-only) | — | `P × L × T` satuan **cm** | — | Dari Master Barang |
| Berat | Number (read-only) | — | Satuan **kg** | — | Dari Master Barang |
| **Jumlah** | Number / stepper | **Ya** | Bilangan **bulat positif** | **≥ 1** (ASM-006) | Helper error + border error bila kosong (REQ-018, REQ-025) |
| **Nilai Barang** | Number (currency) | **Ya — kondisional** | Muncul & wajib **hanya** saat "Tambahkan Asuransi" armada dicentang | **> 0** (ASM-007) | Tersembunyi saat asuransi non-aktif (REQ-019) |
| Tambahkan Asuransi | Checkbox (per armada) | Tidak | Boolean | — | Default **tidak tercentang** (ASM-008); memicu munculnya Nilai Barang |
| Nomor DO | Text (multi-value, chip) | **Tidak** | Multi-nilai **dipisahkan koma**, ditampilkan sebagai **chip** | — | Per armada (REQ-021) |

### 3. Field-level — Step 3 (Vendor & Harga)

| Field | Tipe Input | Wajib | Format / Aturan | Catatan |
|---|---|---|---|---|
| Pilihan Vendor | Dropdown / modal | Ya | Dari master Vendor | Identik TMS (REQ-043) |
| Tanggal Permintaan Muat | Date picker | Ya | Format tanggal id-ID; **≥ hari ini** (ASM-009) | Identik TMS |
| Harga | Number (currency) | Ya | ≥ 0 | Identik TMS |
| Waktu Perjalanan | Textfield **atau** text-only | Ya (saat textfield) | **Textfield** bila rute belum ada di master; **text-only** bila rute sudah ada | REQ-044 |
| Gunakan Komponen Harga | Checkbox | Tidak | Boolean | Membuka input komponen harga (REQ-046) |
| Komponen Asuransi | Kalkulasi sistem (read-only) | — | **persentase × Total Nilai Barang** | Hanya muncul bila ada armada diasuransikan (REQ-047) |
| PPN / PPh | Kalkulasi sistem | — | Ditambahkan ke Total Harga | REQ-047 |

### 4. Form-level / Rule-level

| Kode | Aturan | Perilaku bila dilanggar / kondisi |
|---|---|---|
| VAL-01 | Add-on Auto Stuffing hanya aktif bila modul OMS + add-on dibeli, dan hanya untuk **FTL & FCL** | Elemen auto stuffing (floating button, drawer, pop up visualisasi) **tidak tampil** (REQ-004) |
| VAL-02 | Step 2 **tidak menyediakan** input deskripsi barang manual | Adanya field deskripsi manual → cacat (REQ-003, REQ-011) |
| VAL-03 | Field read-only Step 2 (Kode SKU, Nama Barang, Kemasan, Kubikasi, Dimensi, Berat) tidak boleh editable | Field editable → cacat (REQ-017) |
| VAL-04 | Field **Jumlah** wajib pada setiap baris barang | **Helper error** tampil + **border field berubah warna error**; lanjut ke step berikutnya diblokir (REQ-018, REQ-025) |
| VAL-05 | Field **Nilai Barang** wajib **hanya** saat "Tambahkan Asuransi" armada tercentang | Helper error + border error; saat asuransi non-aktif kolom **tidak tampil** dan **tidak divalidasi** (REQ-019, REQ-025) |
| VAL-06 | Checkbox "Tambahkan Asuransi" berlaku **per armada** untuk **seluruh barang** pada armada tersebut | Asuransi diterapkan sebagian barang → cacat (REQ-020) |
| VAL-07 | **Nomor DO tidak wajib**; bila diisi lebih dari satu wajib dipisahkan **koma** dan dirender sebagai **chip** | Nomor DO memblokir Selanjutnya → cacat (REQ-021) |
| VAL-08 | Alert kapasitas armada bersifat **informatif** — **tidak boleh memblokir** navigasi ke step berikutnya | Sistem memblokir tombol Selanjutnya → cacat (REQ-023) |
| VAL-09 | Pesan alert harus sesuai kondisi: kubikasi saja / berat saja / keduanya (teks persis sesuai REQ-024) | Teks tidak sesuai kondisi → cacat |
| VAL-10 | Button **"Hitung Ulang Armada"** hanya dapat dijalankan bila **minimal 1 data barang sudah diisi** | Button disabled / menampilkan informasi penolakan bila belum ada barang (REQ-029, ASM-010) |
| VAL-11 | Alokasi auto stuffing harus **mengisi 1 armada hingga maksimal** sebelum berpindah, dan **menghabiskan seluruh muatan** | Sisa muatan tidak teralokasi atau armada terisi paralel → cacat (REQ-030) |
| VAL-12 | Pada tipe multi, barang **dibagi rata antar alamat** dalam 1 armada; sisa pembagian **ditempatkan pada alamat pertama** | Sisa jatuh ke alamat lain → cacat (REQ-031) |
| VAL-13 | Perubahan Jenis/Jumlah Armada pada drawer harus **memperbarui visualisasi 3D** | Visualisasi statis → cacat (REQ-038) |
| VAL-14 | **"Terapkan ke Order"** harus menyinkronkan Jenis Armada, Jumlah Armada, dan penempatan barang ke **Step 1 dan Step 2** | Data tidak sinkron → cacat (REQ-039, REQ-040) |
| VAL-15 | Button **"Batal"** pada drawer **tidak boleh** mengubah data order | Perubahan tetap tersimpan → cacat (REQ-041) |
| VAL-16 | **"Visualisasi Terbaru"** menampilkan visualisasi berdasarkan armada terkini **tanpa** mengubah pilihan armada | Pilihan armada berubah → cacat (REQ-042) |
| VAL-17 | Nilai Asuransi pada Step 3 = **persentase × Total Nilai Barang**, dan **hanya** dihitung bila terdapat armada diasuransikan | Perhitungan Total Harga salah → cacat (REQ-047) |
| VAL-18 | Step 4 menampilkan seluruh data Step 1–3 **read-only** | Field editable di Review → cacat (REQ-049) |
| VAL-19 | Label **"Diasuransikan"** hanya tampil pada armada yang diasuransikan, dan kolom Nilai Barang hanya tampil untuk armada tersebut | Label/kolom salah tempat → cacat (REQ-050, REQ-051) |
| VAL-20 | Aksi **Simpan** pada Step 4 mengubah status menjadi **"Menunggu Penugasan"** | Status tidak berubah → cacat (REQ-053) |
| VAL-21 | Status 1–4 tersimpan sebagai **draft** via "Simpan ke Draf" dari **step manapun** | Draf gagal tersimpan di salah satu step → cacat (REQ-057) |
| VAL-22 | Edit order **diblokir** setelah status "Ditugaskan" | Aksi Edit muncul/berhasil di status Ditugaskan → cacat (REQ-059, REQ-068) |
| VAL-23 | Field **Jenis Pengiriman** & **Tipe Pengiriman** locked pada Edit Order | Field editable → cacat (REQ-060) |
| VAL-24 | Button Batal & Simpan pada Edit Order **wajib** memunculkan pop up konfirmasi | Aksi langsung dieksekusi tanpa konfirmasi → cacat (REQ-062) |
| VAL-25 | Pembatalan order **diblokir** sejak status "Proses Pengiriman" dan seterusnya | Aksi Batalkan Order tersedia → cacat (REQ-063) |
| VAL-26 | Field **"Alasan Pembatalan" wajib diisi** | Submit pembatalan ditolak + pesan validasi (REQ-065) |
| VAL-27 | Pembatalan hanya dapat dilakukan **admin shipper**, tidak oleh vendor | Vendor dapat membatalkan → cacat (REQ-064) |
| VAL-28 | Daftar aksi per baris harus **persis** sesuai status (REQ-066 s.d. REQ-068) | Aksi tambahan/hilang → cacat |
| VAL-29 | Jumlah **No. Perjalanan** yang di-generate = **jumlah armada/kontainer** yang dipesan | Jumlah tidak sesuai → cacat (REQ-071) |
| VAL-30 | Aksi **"Lihat No. Perjalanan"** tidak boleh tampil sebelum status "Ditugaskan", dan hanya untuk **FTL & FCL** | Aksi muncul prematur atau pada jenis lain → cacat (REQ-072, REQ-073) |

### 5. Modal "Pilih Barang"

| Kode | Aturan |
|---|---|
| VAL-M1 | Sumber data = **Master Barang** milik shipper terkait; hanya barang berstatus **Aktif** yang tampil (ASM-012) |
| VAL-M2 | Pencarian berfungsi **by kode barang** dan **by nama barang** (REQ-012) |
| VAL-M3 | Mendukung **multi-select** via checkbox dalam satu kali buka modal (REQ-013) |
| VAL-M4 | Barang yang sudah masuk ke armada terkait menampilkan label **"Sudah Ditambahkan"**; diasumsikan tidak dapat dipilih ulang untuk armada yang sama (ASM-013) |
| VAL-M5 | **Counter jumlah barang terpilih** ter-update real-time saat checkbox dicentang/dilepas (REQ-015) |
| VAL-M6 | Button **Batal** menutup modal **tanpa** menambahkan barang; button **Simpan** menambahkan seluruh barang terpilih ke armada terkait (REQ-016) |

---

## Roles & Permissions

> Spesifikasi menyebut secara eksplisit hanya **Shipper** / **Admin Shipper** dan **Vendor**. Matriks berikut melengkapi dengan aktor sistem serta interpretasi hak akses (lihat ASM-001, ASM-002).

| Role / Aktor | Buat Order (Step 1–4) | Simpan ke Draf | Edit Order | Batalkan Order | Lihat No. Perjalanan | Penugasan Armada | Riwayat Perubahan / Pembatalan |
|---|---|---|---|---|---|---|---|
| **Admin Shipper** (aktor utama) | Ya | Ya | Ya — status draft s.d. **Menunggu Penugasan** (REQ-058) | **Ya** — draft s.d. **Ditugaskan** (REQ-063, REQ-064) | Ya (status Ditugaskan) | Tidak | Ya |
| **Staff Operasional Shipper** | Ya | Ya | Ya (mengikuti REQ-058) | Mengikuti kebijakan admin (ASM-002) | Ya | Tidak | Ya (baca) |
| **Vendor** | Tidak | Tidak | Tidak | **Tidak** (eksplisit dilarang, REQ-064) | Ya (konteks penugasan, ASM-003) | **Ya** — memicu status "Ditugaskan" (REQ-056) | Tidak |
| **Pengirim / Penerima (publik)** | Tidak | Tidak | Tidak | Tidak | Ya — via **public tracking** menggunakan No. Perjalanan (REQ-070) | Tidak | Tidak |
| **Sistem — Engine Auto Stuffing** | — | — | — | — | — | — | Menghitung distribusi barang, rekomendasi 3 armada teratas, indikator Berat/Ruang Terpakai, visualisasi 3D (REQ-005, REQ-030, REQ-035) |
| **Sistem — Generator No. Perjalanan** | — | — | — | — | Meng-generate No. Perjalanan per armada/kontainer (REQ-071) | — | — |
| **Master Barang** (sumber data) | Menyediakan Kode SKU, Nama Barang, Kemasan, Kubikasi, Dimensi, Berat (REQ-017) | — | — | — | — | — | — |
| **Master Droppoint** (sumber data) | Auto-draft Data Pengirim & Data Penerima (REQ-008) | — | — | — | — | — | — |
| **Master Armada / Kontainer** (sumber data) | Menyediakan daftar & kapasitas jenis armada (REQ-037) | — | — | — | — | — | — |
| **Master Rute** (sumber data) | Menentukan mode field Waktu Perjalanan (REQ-044) | — | — | — | — | — | — |

### Matriks Aksi vs Status Order

| Status | Detail | Lanjutkan Pengisian | Edit | Batalkan Order | Riwayat Perubahan | Lihat No. Perjalanan |
|---|---|---|---|---|---|---|
| Isi Data Pengiriman | Ya | Ya | Tidak | Ya | Ya | Tidak |
| Isi Data Muatan | Ya | Ya | Tidak | Ya | Ya | Tidak |
| Isi Data Vendor | Ya | Ya | Tidak | Ya | Ya | Tidak |
| Review Order | Ya | Ya | Tidak | Ya | Ya | Tidak |
| Menunggu Penugasan | Ya | Tidak | **Ya** | Ya | Ya | Tidak |
| Ditugaskan | Ya | Tidak | **Tidak** | Ya | Ya | **Ya** |
| Proses Pengiriman | Ya (ASM-014) | Tidak | Tidak | **Tidak** | Ya | Ya (ASM-014) |
| Selesai | Ya (ASM-014) | Tidak | Tidak | Tidak | Ya | Ya (ASM-014) |
| Dibatalkan | Ya (ASM-014) | Tidak | Tidak | Tidak | Ya | Tidak |

---

## User Flows

### UF-01 — Buat Order FTL Auto Stuffing, Tipe Normal (Main Flow)

1. Admin/Staff Shipper membuka menu **Order** → **Buat Order** → jenis **FTL**.
2. **Step 1 — Data Pengiriman**: memilih **Jenis Armada**, mengisi **Jumlah Armada**, memilih **Tipe Pengiriman = Normal**.
3. Mengisi **Data Pengirim** & **Data Penerima** (auto-draft dari **Master Droppoint**).
4. Klik **Selanjutnya** → sistem memvalidasi field wajib → lanjut ke Step 2.
5. **Step 2 — Data Barang**: sistem menampilkan informasi **"Data Unit"** (Jenis & Jumlah Armada dari Step 1) dan card per armada.
6. Klik **"Pilih Barang"** → modal **Pilih Barang** terbuka (pencarian by kode/nama, multi-select checkbox, counter terpilih, label "Sudah Ditambahkan").
7. Pilih barang → klik **Simpan** → baris barang tampil dengan Kode SKU, Nama Barang, Kemasan, Kubikasi, Dimensi, Berat (read-only).
8. Isi **Jumlah** pada setiap baris barang. (Opsional) isi **Nomor DO** dan centang **Tambahkan Asuransi** → isi **Nilai Barang**.
9. Klik floating button **"Hitung Ulang Armada"** → drawer terbuka menampilkan Total Kubikasi, Total Berat, Jenis Pengiriman, rekomendasi **3 armada teratas** (indikator Berat/Ruang Terpakai, label **"Paling Efisien"**), dan **visualisasi 3D**.
10. Klik **"Terapkan ke Order"** → Jenis Armada, Jumlah Armada, dan penempatan barang diterapkan; Step 1 & Step 2 tersinkron.
11. Klik **Selanjutnya** → **Step 3 — Vendor & Harga**: pilih Vendor, isi Tanggal Permintaan Muat, Harga, Waktu Perjalanan; (opsional) centang **Gunakan Komponen Harga**. Nilai **Asuransi** otomatis dihitung bila ada armada diasuransikan.
12. Klik **Selanjutnya** → **Step 4 — Review**: seluruh data Step 1–3 tampil read-only; Data Barang mengikuti struktur Step 2 (+ label **"Diasuransikan"**).
13. (Opsional) Klik button visualisasi pada card Data Barang → **pop up visualisasi muatan** tampil.
14. Klik **Simpan** → status order menjadi **"Menunggu Penugasan"**.

**Alternatif / Percabangan:**

- **UF-01.A1 — Field wajib kosong (Step 2):** klik Selanjutnya tanpa mengisi **Jumlah** (atau **Nilai Barang** saat asuransi aktif) → **helper error** tampil dan **border field berwarna error**; navigasi diblokir (REQ-025).
- **UF-01.A2 — Alert kapasitas armada:** total kubikasi dan/atau berat melebihi kapasitas → alert informasi tampil ("Kubikasi..." / "Berat..." / "Kubikasi dan Berat melebihi kapasitas armada"); **user tetap dapat lanjut** (REQ-023, REQ-024).
- **UF-01.A3 — Hitung Ulang tanpa data barang:** klik "Hitung Ulang Armada" saat belum ada barang terisi → aksi **tidak dapat dijalankan** (REQ-029).
- **UF-01.A4 — Batal pada drawer:** klik **Batal** → panel tertutup, **tanpa** perubahan pada order (REQ-041).
- **UF-01.A5 — Ubah Jenis/Jumlah Armada di drawer:** pilih jenis lain via modal "Pilih Jenis Armada" atau ubah jumlah via stepper → **visualisasi 3D diperbarui**; setelah "Terapkan ke Order", **Step 1 & Step 2 turut berubah** (REQ-037, REQ-038, REQ-040).
- **UF-01.A6 — Visualisasi Terbaru:** klik floating button "Visualisasi Terbaru" → panel visualisasi tampil sesuai armada terkini **tanpa** mengubah pilihan armada (REQ-042).
- **UF-01.A7 — Hapus barang:** klik icon hapus pada baris → barang terhapus dari armada (REQ-022).
- **UF-01.A8 — Simpan ke Draf:** klik **Draf** pada step manapun → order tersimpan dengan status draft sesuai step terakhir (Isi Data Pengiriman / Isi Data Muatan / Isi Data Vendor / Review Order) (REQ-057).
- **UF-01.A9 — Batal:** klik **Batal** → pop up konfirmasi → pengisian dibatalkan (REQ-032, ASM-015).
- **UF-01.A10 — Sebelumnya:** klik **Sebelumnya** pada Step 2/3/4 → kembali ke step sebelumnya dengan data tetap tersimpan (REQ-032, REQ-048, REQ-053).
- **UF-01.A11 — Add-on tidak dibeli:** floating button, drawer, dan pop up visualisasi **tidak tampil**; order FTL berjalan seperti alur TMS standar (REQ-004).
- **UF-01.A12 — Barang sudah ditambahkan:** pada modal Pilih Barang, barang yang sudah masuk armada terkait menampilkan label **"Sudah Ditambahkan"** (REQ-014).
- **UF-01.A13 — Waktu Perjalanan (rute sudah ada):** field tampil sebagai **text-only** dan tidak dapat diisi (REQ-044).
- **UF-01.A14 — Batch order:** order dibuat melalui **input batch** alih-alih manual (REQ-002, ASM-016).

### UF-02 — Buat Order Tipe Multipickup / Multidrop / Multipoint

1. Ulangi UF-01 langkah 1–2, dengan **Tipe Pengiriman = Multipickup / Multidrop / Multipoint**.
2. Sistem menerapkan **rule cascading & minimal baris** sesuai tipe (≥ 2 baris pada sisi yang relevan).
3. Isi seluruh alamat pengirim/penerima sesuai tipe.
4. Lanjut ke Step 2 dan isi data barang (sama seperti UF-01 langkah 5–8).
5. Jalankan **Hitung Ulang Armada** → sistem mendistribusikan barang: **dibagi rata antar alamat dalam 1 armada yang sama**.
6. Lanjut Step 3 & Step 4 seperti UF-01.

**Alternatif / Percabangan:**

- **UF-02.A1 — Pembagian tidak rata:** bila jumlah barang tidak habis dibagi jumlah alamat, **sisa yang lebih besar ditempatkan pada alamat pertama** (REQ-031).
- **UF-02.A2 — Muatan melebihi 1 armada:** armada pertama diisi hingga maksimal, sisanya pindah ke armada berikutnya secara berulang sampai habis (REQ-030).
- **UF-02.A3 — Ringkasan alamat Step 3:** untuk tipe multi, ringkasan alamat tampil sebagai **label + text link** (REQ-045).

### UF-03 — Edit Order

1. Pada Daftar Order, order berstatus **Menunggu Penugasan** → klik aksi **Edit**.
2. Halaman Edit Order terbuka; field **Jenis Pengiriman** & **Tipe Pengiriman** tampil **locked/read-only**.
3. User mengubah **Jenis Armada, Jumlah Armada, Data Pengirim, Data Penerima, Data Barang, dan/atau Vendor & Harga**.
4. Klik **Simpan** → **pop up konfirmasi** tampil → konfirmasi → perubahan tersimpan.

**Alternatif / Percabangan:**

- **UF-03.A1 — Batal edit:** klik **Batal** → **pop up konfirmasi** → pengeditan dibatalkan (REQ-062).
- **UF-03.A2 — Order berstatus draft:** aksi yang tersedia adalah **"Lanjutkan Pengisian"** (bukan Edit), membuka wizard pada step terakhir (REQ-066).
- **UF-03.A3 — Order berstatus Ditugaskan:** aksi **Edit tidak tersedia** pada action menu (REQ-059, REQ-068).
- **UF-03.A4 — Ubah armada saat edit:** perubahan Jenis/Jumlah Armada dapat memicu penempatan ulang barang via **Hitung Ulang Armada** pada Step 2 (REQ-061, ASM-017).

### UF-04 — Pembatalan Order

1. Admin Shipper membuka Daftar Order dan memilih order berstatus **draft s.d. Ditugaskan**.
2. Klik aksi **Batalkan Order** → form/pop up pembatalan tampil.
3. Isi field **"Alasan Pembatalan"** (**wajib**).
4. Konfirmasi → status order berubah menjadi **"Dibatalkan"**.

**Alternatif / Percabangan:**

- **UF-04.A1 — Alasan Pembatalan kosong:** submit ditolak dan pesan validasi tampil (REQ-065).
- **UF-04.A2 — Status ≥ Proses Pengiriman:** aksi **Batalkan Order tidak tersedia** (REQ-063).
- **UF-04.A3 — Aktor vendor:** vendor **tidak** memiliki akses pembatalan (REQ-064).
- **UF-04.A4 — Riwayat Pembatalan:** klik tombol **"Riwayat Pembatalan"** pada toolbar Daftar Order → daftar seluruh order yang pernah dibatalkan tampil (REQ-069).

### UF-05 — Lihat No. Perjalanan

1. Vendor melakukan penugasan → status order menjadi **"Ditugaskan"**.
2. Sistem **meng-generate No. Perjalanan otomatis** sebanyak jumlah armada/kontainer yang dipesan.
3. Pada Daftar Order, aksi **"Lihat No. Perjalanan"** kini tampil pada action menu order tersebut.
4. Klik aksi → pop up **"Data No. Perjalanan"** tampil, berisi per armada/kontainer: **No. Perjalanan**, **Nopol/No. Kontainer**, **Jenis Armada/Kontainer**.
5. Klik **icon copy** pada No. Perjalanan → nomor tersalin ke clipboard.

**Alternatif / Percabangan:**

- **UF-05.A1 — Status belum Ditugaskan:** aksi "Lihat No. Perjalanan" **tidak tampil** (REQ-073).
- **UF-05.A2 — Jenis pengiriman selain FTL/FCL:** No. Perjalanan **tidak tersedia** (REQ-072).
- **UF-05.A3 — Melalui Detail Order:** No. Perjalanan juga dapat dilihat pada halaman **Detail Order** (REQ-076).
- **UF-05.A4 — Public tracking:** pengirim/penerima menggunakan No. Perjalanan untuk mengecek progress perjalanan pada public tracking (REQ-070).

### UF-06 — Transisi Status Order (System Flow)

`Isi Data Pengiriman → Isi Data Muatan → Isi Data Vendor → Review Order → Menunggu Penugasan → Ditugaskan → Proses Pengiriman → Selesai`

Cabang: **Dibatalkan** dapat terjadi dari status draft s.d. **Ditugaskan** (REQ-054, REQ-063).

---

## Acceptance Criteria

> Spesifikasi **tidak mencantumkan acceptance criteria eksplisit**. AC berikut diturunkan langsung dari requirement (ASM-018) dengan traceability ke ID REQ.

| ID | Acceptance Criteria (Given / When / Then) | Traceability |
|---|---|---|
| AC-001 | Given modul OMS dibeli **beserta** add-on Auto Stuffing, When order FTL dibuat, Then floating button "Hitung Ulang Armada" & "Visualisasi Terbaru" serta pop up visualisasi tersedia. | REQ-004 |
| AC-002 | Given add-on Auto Stuffing **tidak** dibeli, When order FTL dibuat, Then seluruh elemen auto stuffing tidak tampil dan alur mengikuti Order FTL TMS standar. | REQ-004, VAL-01 |
| AC-003 | Given jenis pengiriman selain FTL/FCL, When order dibuat, Then fitur auto stuffing tidak diterapkan. | REQ-004 |
| AC-004 | Given user berada di Step 1, When halaman dimuat, Then field Jenis Armada, Jumlah Armada, Tipe Pengiriman (4 opsi), Data Pengirim, dan Data Penerima tampil. | REQ-007 |
| AC-005 | Given user memilih droppoint, When Data Pengirim/Penerima diisi, Then data ter-auto-draft dari **Master Droppoint**. | REQ-008 |
| AC-006 | Given Tipe Pengiriman = Multipickup/Multidrop/Multipoint, When user mencoba lanjut dengan baris alamat kurang dari minimal, Then sistem menolak dan menampilkan validasi. | REQ-009, ASM-004 |
| AC-007 | Given field wajib Step 1 kosong, When klik Selanjutnya, Then navigasi diblokir dan pesan validasi tampil. | REQ-010 |
| AC-008 | Given user berada di Step 2, When area data barang diperiksa, Then **tidak ada** field input deskripsi barang manual; penambahan hanya via modal "Pilih Barang". | REQ-003, REQ-011, VAL-02 |
| AC-009 | Given modal "Pilih Barang" terbuka, When user mengetik kode atau nama barang, Then daftar barang tersaring sesuai kata kunci. | REQ-012 |
| AC-010 | Given modal "Pilih Barang" terbuka, When user mencentang beberapa barang, Then seluruh barang terpilih dan **counter jumlah barang terpilih** ter-update. | REQ-013, REQ-015 |
| AC-011 | Given suatu barang sudah ditambahkan ke armada terkait, When modal "Pilih Barang" dibuka untuk armada tersebut, Then barang menampilkan label **"Sudah Ditambahkan"**. | REQ-014, VAL-M4 |
| AC-012 | Given barang terpilih pada modal, When user klik **Simpan**, Then barang masuk ke card armada; When user klik **Batal**, Then tidak ada barang ditambahkan. | REQ-016, VAL-M6 |
| AC-013 | Given baris barang tampil, When user mencoba mengubah Kode SKU/Nama Barang/Kemasan/Kubikasi/Dimensi/Berat, Then field bersifat **read-only**. | REQ-017, VAL-03 |
| AC-014 | Given baris barang tampil, When field **Jumlah** dikosongkan lalu klik Selanjutnya, Then **helper error** tampil, **border field berwarna error**, dan navigasi diblokir. | REQ-018, REQ-025, VAL-04 |
| AC-015 | Given checkbox "Tambahkan Asuransi" **tidak** tercentang, When card armada diperiksa, Then kolom **Nilai Barang tidak tampil** dan tidak divalidasi. | REQ-019, VAL-05 |
| AC-016 | Given checkbox "Tambahkan Asuransi" **dicentang**, When card armada diperiksa, Then kolom **Nilai Barang tampil untuk seluruh barang pada armada tersebut** dan bersifat **wajib**. | REQ-019, REQ-020, VAL-06 |
| AC-017 | Given asuransi aktif dan Nilai Barang kosong, When klik Selanjutnya, Then helper error tampil dan navigasi diblokir. | REQ-019, REQ-025 |
| AC-018 | Given field **Nomor DO** kosong, When klik Selanjutnya, Then navigasi **tetap berhasil** (tidak wajib). | REQ-021, VAL-07 |
| AC-019 | Given user mengisi beberapa Nomor DO dipisahkan **koma**, When input di-commit, Then setiap nomor tampil sebagai **chip** terpisah. | REQ-021 |
| AC-020 | Given baris barang tampil, When user klik **icon hapus**, Then baris barang terhapus dari armada. | REQ-022 |
| AC-021 | Given total **kubikasi** melebihi kapasitas armada, When Step 2 dirender, Then alert **"Kubikasi melebihi kapasitas armada"** tampil. | REQ-024 |
| AC-022 | Given total **berat** melebihi kapasitas armada, When Step 2 dirender, Then alert **"Berat melebihi kapasitas armada"** tampil. | REQ-024 |
| AC-023 | Given **kubikasi dan berat** melebihi kapasitas armada, When Step 2 dirender, Then alert **"Kubikasi dan Berat melebihi kapasitas armada"** tampil. | REQ-024 |
| AC-024 | Given alert kapasitas armada tampil, When user klik **Selanjutnya**, Then sistem **tetap mengizinkan** lanjut ke step berikutnya. | REQ-023, VAL-08 |
| AC-025 | Given user berada di Step 2, When informasi **"Data Unit"** diperiksa, Then Jenis Armada & Jumlah Armada dari Step 1 ditampilkan. | REQ-026 |
| AC-026 | Given halaman Step 2 di-scroll, When posisi floating button diperiksa, Then button "Hitung Ulang Armada" & "Visualisasi Terbaru" **tetap mengikuti posisi** (floating). | REQ-027 |
| AC-027 | Given floating button dalam kondisi default, When belum di-hover, Then hanya **ikon** yang tampil; When di-hover, Then **teks/label** tampil. | REQ-028 |
| AC-028 | Given **belum ada** data barang yang diisi, When user klik **"Hitung Ulang Armada"**, Then aksi **tidak dijalankan**. | REQ-029, VAL-10 |
| AC-029 | Given minimal 1 data barang sudah diisi, When user klik **"Hitung Ulang Armada"**, Then drawer terbuka menampilkan **Total Kubikasi** & **Total Berat** sesuai data barang. | REQ-029, REQ-033 |
| AC-030 | Given drawer Hitung Ulang Armada terbuka, When konten diperiksa, Then **Jenis Pengiriman** dari Step 1 ditampilkan. | REQ-034 |
| AC-031 | Given drawer terbuka, When blok rekomendasi diperiksa, Then tampil **3 rekomendasi armada teratas**, masing-masing dengan indikator **Berat Terpakai** & **Ruang Terpakai**. | REQ-035 |
| AC-032 | Given 3 rekomendasi tampil, When rekomendasi terbaik diperiksa, Then **tepat satu** menampilkan label **"Paling Efisien"**. | REQ-036 |
| AC-033 | Given drawer terbuka, When user membuka modal **"Pilih Jenis Armada"** dan memilih jenis lain, Then field Jenis Armada ter-update dan **visualisasi 3D diperbarui**. | REQ-037, REQ-038, VAL-13 |
| AC-034 | Given drawer terbuka, When user mengubah **Jumlah Armada** via input/stepper, Then **visualisasi 3D diperbarui** sesuai jumlah baru. | REQ-037, REQ-038 |
| AC-035 | Given Jenis/Jumlah Armada diubah pada drawer, When user klik **"Terapkan ke Order"**, Then Jenis Armada, Jumlah Armada, dan penempatan barang diterapkan ke order. | REQ-039 |
| AC-036 | Given perubahan telah diterapkan, When Step 1 dan informasi Data Unit Step 2 diperiksa, Then keduanya **menampilkan nilai terbaru**. | REQ-040, VAL-14 |
| AC-037 | Given user mengubah nilai pada drawer, When user klik **"Batal"**, Then panel tertutup dan data order **tidak berubah**. | REQ-041, VAL-15 |
| AC-038 | Given user klik floating button **"Visualisasi Terbaru"**, When panel tampil, Then visualisasi mengikuti **Jenis & Jumlah Armada terkini** dan pilihan armada **tidak berubah**. | REQ-042, VAL-16 |
| AC-039 | Given data barang melebihi kapasitas 1 armada, When auto stuffing dijalankan, Then armada pertama terisi **hingga maksimal** lebih dulu sebelum armada berikutnya dipakai, dan **seluruh muatan teralokasi**. | REQ-030, VAL-11 |
| AC-040 | Given Tipe Pengiriman multi dan jumlah barang **habis dibagi** jumlah alamat, When auto stuffing dijalankan, Then barang **dibagi rata** antar alamat dalam armada yang sama. | REQ-031, VAL-12 |
| AC-041 | Given Tipe Pengiriman multi dan jumlah barang **tidak habis dibagi**, When auto stuffing dijalankan, Then **sisa yang lebih besar ditempatkan pada alamat pertama**. | REQ-031, VAL-12 |
| AC-042 | Given user berada di Step 2, When menekan Batal/Draf/Sebelumnya/Selanjutnya, Then perilaku identik dengan Step 2 TMS. | REQ-032 |
| AC-043 | Given user berada di Step 3, When halaman dimuat, Then field Pilihan Vendor, Tanggal Permintaan Muat, Harga, Waktu Perjalanan, ringkasan alamat, dan checkbox "Gunakan Komponen Harga" tampil. | REQ-043, REQ-046 |
| AC-044 | Given rute **belum ada** di master, When Step 3 dirender, Then **Waktu Perjalanan tampil sebagai textfield** yang dapat diisi. | REQ-044 |
| AC-045 | Given rute **sudah ada** di master, When Step 3 dirender, Then **Waktu Perjalanan tampil sebagai text-only** (tidak dapat diisi). | REQ-044 |
| AC-046 | Given Tipe Pengiriman multi, When ringkasan alamat pada Step 3 diperiksa, Then tampil sebagai **label + text link**. | REQ-045 |
| AC-047 | Given terdapat armada yang diasuransikan pada Step 2, When Step 3 dirender, Then komponen **Asuransi = persentase × Total Nilai Barang** tampil dan **turut dihitung ke Total Harga** bersama PPN & PPh. | REQ-047, VAL-17 |
| AC-048 | Given **tidak ada** armada yang diasuransikan, When Step 3 dirender, Then komponen Asuransi **tidak** dihitung ke Total Harga. | REQ-047 |
| AC-049 | Given field wajib Step 3 kosong, When klik Selanjutnya, Then navigasi diblokir dengan pesan validasi identik TMS. | REQ-048 |
| AC-050 | Given user berada di Step 4, When halaman dimuat, Then seluruh data Step 1–3 tampil **read-only**. | REQ-049, VAL-18 |
| AC-051 | Given Step 4 dirender, When bagian Data Barang diperiksa, Then menampilkan Kode SKU, Nama Barang, Kemasan, Kubikasi/Dimensi, Berat, Jumlah — dan **Nilai Barang hanya untuk armada yang diasuransikan**. | REQ-050 |
| AC-052 | Given terdapat armada yang diasuransikan, When Step 4 dirender, Then label **"Diasuransikan"** tampil pada armada tersebut saja. | REQ-051, VAL-19 |
| AC-053 | Given Step 4 dirender dengan add-on aktif, When user klik button visualisasi pada card Data Barang, Then **pop up visualisasi muatan** tampil. | REQ-006, REQ-052 |
| AC-054 | Given seluruh data lengkap, When user klik **Simpan** pada Step 4, Then order tersimpan dan status berubah menjadi **"Menunggu Penugasan"**. | REQ-053, VAL-20 |
| AC-055 | Given daftar order, When kolom status diperiksa, Then hanya 9 status valid yang dapat muncul sesuai REQ-054. | REQ-054 |
| AC-056 | Given user berhenti pada suatu step, When klik **"Simpan ke Draf"**, Then order tersimpan dengan status draft sesuai step terakhir (Isi Data Pengiriman / Isi Data Muatan / Isi Data Vendor / Review Order). | REQ-055, REQ-057, VAL-21 |
| AC-057 | Given vendor telah melakukan penugasan, When status order diperiksa, Then status = **"Ditugaskan"**; When armada berstatus "Dalam Perjalanan", Then status order = **"Proses Pengiriman"**; When seluruh armada selesai bongkar, Then status = **"Selesai"**. | REQ-056 |
| AC-058 | Given order berstatus **Menunggu Penugasan**, When shipper membuka Edit Order, Then perubahan data diizinkan dan tersimpan. | REQ-058 |
| AC-059 | Given order berstatus **Ditugaskan**, When action menu diperiksa, Then aksi **Edit tidak tersedia**. | REQ-059, REQ-068, VAL-22 |
| AC-060 | Given halaman Edit Order terbuka, When field Jenis Pengiriman & Tipe Pengiriman diperiksa, Then keduanya **locked/read-only**. | REQ-060, VAL-23 |
| AC-061 | Given halaman Edit Order terbuka, When user mengubah Jenis Armada / Jumlah Armada / Data Pengirim / Data Penerima / Data Barang / Vendor & Harga, Then perubahan diizinkan. | REQ-061 |
| AC-062 | Given halaman Edit Order, When user klik **Batal** atau **Simpan**, Then **pop up konfirmasi tampil** sebelum aksi dieksekusi. | REQ-062, VAL-24 |
| AC-063 | Given order berstatus draft s.d. **Ditugaskan**, When action menu diperiksa, Then aksi **Batalkan Order tersedia**. | REQ-063 |
| AC-064 | Given order berstatus **Proses Pengiriman** atau setelahnya, When action menu diperiksa, Then aksi **Batalkan Order tidak tersedia**. | REQ-063, VAL-25 |
| AC-065 | Given aktor **vendor**, When mencoba membatalkan order, Then aksi **tidak tersedia/ditolak**. | REQ-064, VAL-27 |
| AC-066 | Given form pembatalan terbuka, When **Alasan Pembatalan** kosong lalu disubmit, Then submit **ditolak** dan pesan validasi tampil. | REQ-065, VAL-26 |
| AC-067 | Given form pembatalan diisi lengkap, When disubmit, Then status order berubah menjadi **"Dibatalkan"**. | REQ-056, REQ-065 |
| AC-068 | Given order berstatus **Isi Data Pengiriman/Muatan/Vendor atau Review Order**, When action menu dibuka, Then tersedia **Detail, Lanjutkan Pengisian, Batalkan Order, Riwayat Perubahan**. | REQ-066, VAL-28 |
| AC-069 | Given order berstatus **Menunggu Penugasan**, When action menu dibuka, Then tersedia **Detail, Edit, Batalkan Order, Riwayat Perubahan**. | REQ-067, VAL-28 |
| AC-070 | Given order berstatus **Ditugaskan**, When action menu dibuka, Then tersedia **Detail, Batalkan Order, Riwayat Perubahan, Lihat No. Perjalanan**. | REQ-068, VAL-28 |
| AC-071 | Given halaman Daftar Order, When user klik **"Riwayat Pembatalan"** pada toolbar, Then daftar seluruh order yang pernah dibatalkan ditampilkan. | REQ-069 |
| AC-072 | Given order tertentu, When user klik aksi **"Riwayat Perubahan"**, Then histori perubahan **order tersebut saja** ditampilkan (bukan daftar pembatalan global). | REQ-069 |
| AC-073 | Given order FTL dengan **N armada** berstatus Ditugaskan, When No. Perjalanan diperiksa, Then sistem meng-generate **tepat N** No. Perjalanan yang melekat pada masing-masing armada. | REQ-071, VAL-29 |
| AC-074 | Given jenis pengiriman **selain FTL & FCL**, When order diperiksa, Then No. Perjalanan **tidak tersedia**. | REQ-072, VAL-30 |
| AC-075 | Given order **belum** berstatus Ditugaskan, When action menu dibuka, Then aksi **"Lihat No. Perjalanan" tidak tampil**. | REQ-073, VAL-30 |
| AC-076 | Given order berstatus Ditugaskan, When user klik **"Lihat No. Perjalanan"**, Then pop up **"Data No. Perjalanan"** tampil berisi **No. Perjalanan, Nopol/No. Kontainer, dan Jenis Armada/Kontainer** per unit. | REQ-074 |
| AC-077 | Given pop up "Data No. Perjalanan" terbuka, When user klik **icon copy**, Then nomor perjalanan tersalin ke clipboard. | REQ-075 |
| AC-078 | Given order berstatus Ditugaskan, When user membuka **Detail Order**, Then No. Perjalanan ditampilkan pada halaman tersebut. | REQ-076 |
| AC-079 | Given No. Perjalanan valid, When pengirim/penerima memasukkannya pada **public tracking**, Then progress perjalanan armada/kontainer dapat dilihat. | REQ-070 |
| AC-080 | Given data barang & armada yang sama, When auto stuffing dijalankan di OMS, Then hasil alokasi **konsisten dengan output tools auto stuffing eksisting**. | REQ-005 |

---

## Traceability Matrix (Ringkas)

| Kategori | Range REQ | Jumlah |
|---|---|---|
| A. Ketentuan Umum Order FTL (OMS) | REQ-001 – REQ-006 | 6 |
| B. Step 1 — Data Pengiriman | REQ-007 – REQ-010 | 4 |
| C. Step 2 — Data Barang | REQ-011 – REQ-032 | 22 |
| D. Drawer Hitung Ulang Armada & Visualisasi Terbaru | REQ-033 – REQ-042 | 10 |
| E. Step 3 — Vendor & Harga | REQ-043 – REQ-048 | 6 |
| F. Step 4 — Review | REQ-049 – REQ-053 | 5 |
| G. Status Order | REQ-054 – REQ-057 | 4 |
| H. Hak Edit Order FTL | REQ-058 – REQ-062 | 5 |
| I. Pembatalan Order | REQ-063 – REQ-065 | 3 |
| J. Aksi pada Daftar Order FTL | REQ-066 – REQ-069 | 4 |
| K. No. Perjalanan | REQ-070 – REQ-076 | 7 |
| **Total** | | **76** |

| Artefak | Jumlah |
|---|---|
| Requirements (REQ) | 76 |
| Aturan validasi field-level | 23 field (Step 1: 6, Step 2: 10, Step 3: 7) |
| Aturan validasi form/rule-level (VAL) | 30 |
| Aturan validasi modal "Pilih Barang" (VAL-M) | 6 |
| **Total aturan validasi** | **59** (23 field + 30 rule + 6 modal) |
| Acceptance Criteria (AC) | 80 |
| User Flow utama | 6 (UF-01 … UF-06) |
| Alur alternatif / percabangan | 25 |
| Role / aktor | 10 (4 manusia/eksternal + 6 sistem/sumber data) |

---

## UI Inventory

> **Sumber:** 46 file desain PNG di `inputs/oms012-order-ftl-auto-stuffing/designs/` (`016.png` – `057a.png`), seluruhnya dibaca via vision pada 2026-08-18. Folder desain **tersedia** — tidak ada layar yang diturunkan dari asumsi semata.
> **Cakupan:** 39 layar/state logis, ±250 elemen, 25 pesan/teks sistem unik, 15 temuan diskrepansi.
> **Konvensi selector:** prioritas `getByRole(role, { name })` → `getByLabel` → `getByText` → `getByTestId`. Nilai `data-testid` bersifat **usulan** (lihat **ASM-D01**).
> **Detail per-elemen lengkap** (tabel granular tiap layar) tersedia di file pendamping: `output/oms012-order-ftl-auto-stuffing/oms012-order-ftl-auto-stuffing.ui-inventory.md`.
> Konteks aplikasi: OMS tenant "Mentari Sumber Kertas", role bar `Shipper / Staff Operasional`, user `Andika (andikamsk@gmail.com)`.

### 1. Indeks Layar → File Desain

| # | Layar / State | File PNG | REQ terkait |
|---|---|---|---|
| SCR-00 | Shell global (sidebar, header, breadcrumb, Kuota Order) | semua | — |
| SCR-01 | Daftar Order (list default) | 016, 036, 050 | REQ-054, REQ-066–069 |
| SCR-02 | Daftar Order — panel Filter terbuka | 017, 034 | REQ-069 |
| SCR-03 | Action menu per baris (3 varian status) | 017, 034 | REQ-066–068, REQ-073 |
| SCR-04 | Step 1 — pilih Jenis Pengiriman (state awal, `Selanjutnya` disabled) | 018 | REQ-002, REQ-007 |
| SCR-05 | Step 1 — Tipe **Normal** (form penuh) | 019 | REQ-007–010 |
| SCR-06 | Step 1 — **Multipickup** (Pick Up 1–3) | 037 | REQ-009 |
| SCR-07 | Step 1 — **Multidrop** (Drop Off 1–2) | 044 | REQ-009 |
| SCR-08 | Step 1 — **Multipoint** (Pick Up 1–3 + Drop Off 1–2) | 051 | REQ-009 |
| SCR-09 | Step 2 Data Barang — Normal, FAB ikon saja | 020 | REQ-011–027 |
| SCR-10 | Step 2 — FAB hover (label tampil) | 021 | REQ-027, REQ-028 |
| SCR-11 | Modal **Pilih Barang** | 022 | REQ-011–016 |
| SCR-12 | Drawer **Hitung Ulang Armada** | 023 | REQ-033–041 |
| SCR-13 | Drawer Hitung Ulang Armada — badge over-kapasitas | 024 | REQ-038 |
| SCR-14 | Panel **Visualisasi Muatan Saat Ini** (Visualisasi Terbaru) | 025 | REQ-042 |
| SCR-15 | Step 3 — kosong, rute belum ada di master | 026 | REQ-043, REQ-044, REQ-046 |
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
| SCR-39 | Review (056) / Edit (057) / Detail (057a) — Multipoint | 056, 057, 057a | REQ-050, REQ-061 |

### 2. SCR-00 — Shell Global

| Elemen | Tipe | Label / Teks | State | Selector Playwright |
|---|---|---|---|---|
| Toggle sidebar | icon button | (hamburger) | enabled | `getByTestId('sidebar-toggle')` |
| Menu sidebar | link list | `Dashboard ⌄`, `Order`, `Penugasan Tracking`, `Simulasi Muatan`, `Master Wilayah ⌄`, `Master Operasional ⌄`, `Manajemen Vendor`, `Pengaturan Akun`, `Akun Saya`, `Pengaturan Sistem`, `Pusat Notifikasi ⌄` | `Order` aktif pada 016–035 | `getByRole('link', { name: 'Order' })` |
| Notifikasi | icon button + dot | (bell + badge merah) | ada notifikasi baru | `getByTestId('header-notification')` |
| Profil user | text block | `Andika` / `andikamsk@gmail.com`; chip `Shipper` / `Staff Operasional` | read-only | `getByText('andikamsk@gmail.com')` |
| Logout | icon button | (logout) | enabled | `getByTestId('header-logout')` |
| Kuota Order | progress + text | `Kuota Order`, `120/300`, `40%` | read-only | `getByTestId('order-quota-progress')` |
| Versi | text | `Order Management System Versi 1.0.0` | read-only | `getByText('Versi 1.0.0')` |
| Breadcrumb | nav links | `Beranda > Daftar Order > Buat Order` | item terakhir non-link | `getByRole('link', { name: 'Daftar Order' })` |

### 3. SCR-01 / SCR-02 / SCR-03 — Daftar Order, Filter & Action Menu

| Elemen | Tipe | Label / Placeholder | State | Selector |
|---|---|---|---|---|
| Judul | heading | `Daftar Order` | — | `getByRole('heading', { name: 'Daftar Order' })` |
| Buat Order | button primary (+) | `Buat Order` | enabled | `getByRole('button', { name: 'Buat Order' })` |
| Batch Order | button outline | `Batch Order` | enabled | `getByRole('button', { name: 'Batch Order' })` |
| Riwayat Pembatalan | button outline | `Riwayat Pembatalan` | enabled (REQ-069) | `getByRole('button', { name: 'Riwayat Pembatalan' })` |
| Filter | button outline (toggle) | `Filter` | enabled | `getByRole('button', { name: 'Filter' })` |
| Jumlah data | dropdown | `Tampilkan [20] data` | default `20` | `getByRole('combobox', { name: /Tampilkan/ })` |
| Tabel order | table | header `ID Order`/`Vendor`, `Kota Asal`/`Warehouse Asal`, `Kota Tujuan`/`Warehouse Tujuan`, `Total Harga ⇅`/`Status` | `Total Harga` sortable | `getByRole('table')` |
| Chip jenis order | badge | `FTL`, `FCL`, `LTL`, `LCL` | read-only | `getByRole('row', { name: /ORD789871FSF7/ }).getByText('FTL')` |
| Badge status | badge | `Isi Data Dasar`, `Isi Data Muatan`, `Isi Data Vendor`, `Review Order`, `Menunggu Penugasan`, `Ditugaskan`, `Proses Pengiriman`, `Terkirim`, `Dibatalkan` | read-only | `getByTestId('order-row-status')` |
| Aksi baris | icon button `...` | (kebab) | enabled | `getByRole('row', { name: /ORD/ }).getByRole('button', { name: 'Aksi' })` |
| Info paginasi | text | `Menampilkan 1 - 20 data dari 30 data` | read-only | `getByText(/Menampilkan \d+ - \d+ data dari/)` |
| Paginasi | buttons | `«` `‹` `1 2 3 … 12` `›` `»` | halaman 1 aktif | `getByRole('button', { name: '2' })` |
| Filter — ID Order | text | `ID Order` / `Masukkan ID Order` | enabled | `getByLabel('ID Order')` |
| Filter — Jenis Order | dropdown | `Jenis Order` / `Pilih Jenis Order` | enabled | `getByLabel('Jenis Order')` |
| Filter — Vendor | text | `Vendor` / `Masukkan Vendor` | enabled | `getByLabel('Vendor')` |
| Filter — Kota Asal / Kota Tujuan | dropdown | `Pilih Kota Asal` / `Pilih Kota Tujuan` | enabled | `getByLabel('Kota Asal')` |
| Filter — Total Harga | text | `Masukkan Total Harga` | enabled | `getByLabel('Total Harga')` |
| Filter — Tipe Pengiriman | dropdown | `Pilih Tipe Pengiriman` | **tampak disabled** (ASM-D03) | `getByLabel('Tipe Pengiriman')` |
| Filter — Metode Pengiriman | dropdown | `Pilih Metode Pengiriman` | **tampak disabled** (ASM-D03) | `getByLabel('Metode Pengiriman')` |
| Filter — Drop Point Asal / Tujuan | dropdown | `Pilih Drop Point Asal` / `Pilih Drop Point Tujuan` | enabled | `getByLabel('Drop Point Asal')` |
| Filter — Status | dropdown | `Pilih Status` | enabled | `getByLabel('Status')` |
| Filter — Reset / Terapkan | button | `Reset` (danger outline), `Terapkan` (primary) | enabled | `getByRole('button', { name: 'Terapkan' })` |

**Action menu per status (SCR-03):**

| Status baris | Item menu terlihat | File | Catatan |
|---|---|---|---|
| Draft (Isi Data Dasar/Muatan/Vendor, Review Order) | `Detail`, `Lanjutkan Pengisian`, `Batalkan Order`, `Riwayat Perubahan` | 017 | sesuai REQ-066 |
| `Menunggu Penugasan` | `Detail`, `Edit`, `Batalkan Order`, `Riwayat Perubahan` | 017 | sesuai REQ-067 |
| `Ditugaskan` | `Detail`, `Lihat No. Perjalanan`, **`Order Kembali`**, `Batalkan Order`, `Riwayat Perubahan` | 034 | `Order Kembali` **tidak ada di REQ-068** → FND-01 |

Selector item: `getByRole('menuitem', { name: 'Lihat No. Perjalanan' })` / fallback `getByTestId('order-action-lihat-no-perjalanan')`.

### 4. SCR-04 – SCR-08 — Buat Order Step 1 (Data Pengiriman)

| Elemen | Tipe | Label / Teks | State | Selector |
|---|---|---|---|---|
| Stepper wizard | steps | `01 Data Pengiriman`, `02 Data Barang`, `03 Vendor dan Harga`, `04 Review` | step selesai bercentang | `getByTestId('order-wizard-step-2')` |
| Kartu jenis pengiriman | radio card ×4 | `FTL Full Truck Load`, `FCL Full Container Load`, `LTL Less Than Truck Load`, `LCL Less Than Container Load` | `FTL` checked | `getByRole('radio', { name: /FTL/ })` |
| Jenis Armada | dropdown, wajib | `Jenis Armada *` (`Tronton Box`) | enabled | `getByLabel('Jenis Armada')` |
| Jumlah Armada | number, wajib | `Jumlah Armada *` (`2`/`3`) | enabled; **bukan stepper** di Step 1 | `getByLabel('Jumlah Armada')` |
| Tipe Pengiriman | dropdown, wajib | `Tipe Pengiriman *` / `Pilih Tipe Pengiriman` → `Normal`/`Multipickup`/`Multidrop`/`Multipoint` | enabled | `getByLabel('Tipe Pengiriman')` |
| Selanjutnya (018) | button | `Selanjutnya →` | **disabled** saat Tipe Pengiriman kosong | `getByRole('button', { name: 'Selanjutnya' })` |
| Drop Point Asal / Tujuan | dropdown, wajib | `Drop Point Asal *`, `Drop Point Tujuan *` | enabled | `getByLabel('Drop Point Asal')` |
| Pengirim / Penerima | dropdown, wajib | `Pengirim *`, `Penerima *` | enabled | `getByLabel('Pengirim')` |
| PIC Pengirim / Penerima | text, wajib | `PIC Pengirim *` + helper `Nama PIC Pengirim` | enabled | `getByLabel('PIC Pengirim')` |
| No./Nomor WhatsApp PIC | text, wajib | `No. WhatsApp PIC *` (Normal) / `Nomor WhatsApp PIC *` (varian multi) + helper `Contoh: 081234567898` | enabled — label tidak konsisten (FND-06) | `getByLabel('No. WhatsApp PIC').first()` |
| Provinsi / Kota-Kab / Kecamatan / Desa-Kelurahan / Kode Pos | text | `Provinsi Asal`, `Kota/Kab. Asal`, `Kecamatan Asal`, `Desa/Kelurahan Asal`, `Kode Pos` | **read-only** (auto-draft Master Droppoint, REQ-008) | `getByLabel('Provinsi Asal')` |
| Alamat Asal / Tujuan | textarea | `Alamat Asal`, `Alamat Tujuan` | **read-only** | `getByLabel('Alamat Asal')` |
| Catatan | textarea | `Catatan` / `Masukkan Catatan` | opsional, enabled | `getByLabel('Catatan').first()` |
| Grup pengirim (multi) | card berulang | `Pick Up 1`, `Pick Up 2`, `Pick Up 3` | Multipickup (037) & Multipoint (051) | `getByRole('region', { name: 'Pick Up 2' })` |
| Grup penerima (multi) | card berulang | `Drop Off 1`, `Drop Off 2` | Multidrop (044) & Multipoint (051) | `getByRole('region', { name: 'Drop Off 2' })` |
| Hapus baris alamat | icon button (trash merah) | — | **absen pada baris ke-1**, ada pada baris ≥ 2 | `getByRole('region', { name: 'Pick Up 2' }).getByRole('button', { name: 'Hapus' })` |
| Tambah baris | text button | `+ Tambah Baris Input` | 1× (Multipickup/Multidrop), 2× (Multipoint) | `getByRole('button', { name: 'Tambah Baris Input' })` |
| Footer | buttons | `Batal`, `Simpan ke Draf`, `Selanjutnya →` | enabled (019, 037, 044, 051) | `getByRole('button', { name: 'Simpan ke Draf' })` |

### 5. SCR-09 / SCR-10 — Step 2 Data Barang (tipe Normal)

| Elemen | Tipe | Label / Teks | State | Selector |
|---|---|---|---|---|
| Data Unit | info card | `Data Unit` → `Jenis Armada: Tronton Box`, `Jumlah Armada: 2` | read-only (REQ-026) | `getByTestId('step2-data-unit')` |
| Card armada | section berulang | `Armada 1`, `Armada 2`, `Armada 3` | **3 card padahal Jumlah Armada = 2** → FND-02 | `getByRole('region', { name: 'Armada 1' })` |
| Tambahkan Asuransi | checkbox | `Tambahkan Asuransi` + helper `Berlaku untuk seluruh barang pada armada ini` | Armada 1 **checked**; Armada 2 & 3 unchecked | `getByRole('region', { name: 'Armada 1' }).getByRole('checkbox', { name: 'Tambahkan Asuransi' })` |
| Nomor DO | chips input | `Nomor DO`, chip `TGK783898202U ×`, `TBL28371302 ×`, placeholder `Masukkan Nomor DO`, helper `Pisahkan dengan koma untuk menambahkan beberapa nomor` | opsional (REQ-021) | `getByLabel('Nomor DO').first()` |
| Hapus chip DO | `×` pada chip | — | enabled | `getByRole('button', { name: 'Hapus TGK783898202U' })` |
| Tabel barang | table | `Kode SKU`/`Nama Barang`, `Kemasan`, `Kubikasi`/`Dimensi`, `Berat`, `Jumlah`, `Nilai Barang` | kolom `Nilai Barang` **hanya** saat asuransi aktif (REQ-019) | `getByRole('region', { name: 'Armada 1' }).getByRole('table')` |
| Kode SKU / Nama / Kemasan / Kubikasi / Dimensi / Berat | text sel | `SKU-PPR-001` / `Kertas HVS A4 80 gsm` / `Dus` / `0,018 m³` / `31 × 22 × 26,4 cm` / `12,5 kg` | **read-only** (REQ-017) | `getByRole('cell', { name: 'SKU-PPR-001' })` |
| Jumlah | number input | header kolom `Jumlah`; nilai `200` / `0` | wajib; **error state** bila kosong/0 | `getByRole('row', { name: /SKU-PPR-001/ }).getByRole('spinbutton')` |
| Nilai Barang | currency input | prefix `Rp`; nilai `0` / `1.320.000` / `365.000` | wajib bila asuransi aktif; **error state** | `getByRole('row', { name: /SKU-PPR-001/ }).getByTestId('input-nilai-barang')` |
| Hapus baris barang | icon button (trash merah) | — | enabled (REQ-022) | `getByRole('row', { name: /SKU-BKU-001/ }).getByRole('button', { name: 'Hapus' })` |
| Pilih Barang | button outline (+) | `Pilih Barang` | enabled (termasuk pada armada kosong) | `getByRole('region', { name: 'Armada 3' }).getByRole('button', { name: 'Pilih Barang' })` |
| Alert kapasitas | badge merah inline | `Kubikasi melebihi kapasitas armada` (Armada 1) / `Berat melebihi kapasitas armada` (Armada 2) | **informatif, tidak memblokir** (REQ-023) | `getByText('Kubikasi melebihi kapasitas armada')` |
| Total kubikasi / berat | text | `Total Kubikasi: 19,2 / 17,86 m³` • `Total Berat: 19.200 / 24.800 kg` | read-only | `getByText(/Total Kubikasi:/).first()` |
| Empty state barang | text | `Belum ada barang. Klik "Pilih Barang "` | Armada 3 | `getByText(/Belum ada barang/)` |
| FAB Hitung Ulang Armada | floating button | 020: **ikon refresh saja**; 021: label `Hitung Ulang Armada` | enabled (ada ≥ 1 barang) — REQ-027, REQ-028 | `getByRole('button', { name: 'Hitung Ulang Armada' })` |
| FAB Visualisasi Terbaru | floating button | 020: **ikon mata saja**; 021: label `Visualisasi Terbaru` | enabled | `getByRole('button', { name: 'Visualisasi Terbaru' })` |
| Footer | buttons | `Batal`, `← Sebelumnya`, `Simpan ke Draf`, `Selanjutnya →` | enabled (REQ-032) | `getByRole('button', { name: 'Sebelumnya' })` |

### 6. SCR-11 — Modal "Pilih Barang" (022)

| Elemen | Tipe | Label / Teks | State | Selector |
|---|---|---|---|---|
| Dialog | modal | `Pilih Barang` + subjudul `Pilih barang yang ingin ditambahkan ke order` | terbuka; **tanpa tombol close `×`** → FND-03 | `getByRole('dialog', { name: 'Pilih Barang' })` |
| Pencarian | search input + icon | placeholder `Cari kode/nama barang` | enabled (REQ-012) | `getByPlaceholder('Cari kode/nama barang')` |
| Baris barang | list item | `SKU-PPR-001 - Kertas HVS A4 80 gsm` + meta `Dus • 0,018 m³ • 12,5 kg` | list scrollable | `getByRole('listitem').filter({ hasText: 'SKU-PPR-001' })` |
| Checkbox barang | checkbox | per baris | multi-select; `SKU-PPR-002` & `SKU-BKU-001` checked | `getByRole('checkbox', { name: /SKU-PPR-002/ })` |
| Label sudah ditambahkan | badge | `Sudah Ditambahkan` | checkbox **tetap aktif** (tidak disabled) → mengoreksi ASM-013 | `getByRole('listitem').filter({ hasText: 'SKU-PPR-002' }).getByText('Sudah Ditambahkan')` |
| Counter terpilih | text | `3 barang terpilih` | live (REQ-015) | `getByText(/\d+ barang terpilih/)` |
| Batal / Simpan | buttons | `Batal` (danger outline), `Simpan` (primary) | enabled (REQ-016) | `getByRole('dialog').getByRole('button', { name: 'Simpan' })` |

### 7. SCR-12 / SCR-13 / SCR-14 — Drawer Auto Stuffing

| Elemen | Tipe | Label / Teks | State | Selector |
|---|---|---|---|---|
| Drawer Hitung Ulang | panel kanan | `Hitung Ulang Armada` + subjudul `Simulasi ulang kebutuhan unit dari muatan order ini. Terapkan untuk ubah data order.` | terbuka | `getByRole('dialog', { name: 'Hitung Ulang Armada' })` |
| Ringkasan | text | `Total Kubikasi 22,8 m³`, `Total Berat 12.140 kg`, `Jenis Pengiriman FTL` | read-only (REQ-033, REQ-034) | `getByTestId('recalc-total-kubikasi')` |
| Kartu rekomendasi ×3 | selectable card | `Tronton Wing Box` (2 Unit • 15.000 Kg • 51,36 m³), `Tronton Box` (2 Unit), `Fuso Box` (3 Unit • 8.000 kg • 31,74 m³) | kartu ke-1 selected (REQ-035) | `getByRole('radio', { name: /Tronton Wing Box/ })` |
| Label efisien | badge hijau | `Paling Efisien` | **hanya 1 kartu** (REQ-036) | `getByText('Paling Efisien')` |
| Berat / Ruang Terpakai | progress + % | `Berat Terpakai 78% / 78% / 47%`, `Ruang Terpakai 82% / 82% / 71%` | read-only | `getByTestId('recalc-card-1-berat-terpakai')` |
| Jenis Armada | text field | `Jenis Armada *` = `Tronton Wing Box` | **read-only**, diubah via modal | `getByLabel('Jenis Armada')` |
| Pilih Jenis Armada | button outline | `Pilih Jenis Armada` | enabled (REQ-037) | `getByRole('button', { name: 'Pilih Jenis Armada' })` |
| Jumlah Armada | number + stepper `−` `+` | `Jumlah Armada *` = `2` | enabled (REQ-037) | `getByLabel('Jumlah Armada')` |
| Info kapasitas | text | `Berat Maksimal 1 Armada: 15.000 kg • Kubikasi Maksimal 1 Armada: 51,36 m³` | read-only | `getByText(/Berat Maksimal 1 Armada/)` |
| Tab armada | tablist | `Armada 1`, `Armada 2` | `Armada 1` selected | `getByRole('tab', { name: 'Armada 2' })` |
| Kanvas 3D | canvas | overlay `1306 koli • 19.995 kg dialokasikan ke unit ini`; hint `Drag: putar 360° • Scroll: zoom • Klik 2×: reset` | interaktif (REQ-038) | `getByTestId('load-visualization-canvas')` |
| Badge over-kapasitas | badge merah | `110 koli melebihi kapasitas (outline merah)` | **hanya 024, 025, 031a** | `getByText(/koli melebihi kapasitas/)` |
| Legenda | chips warna | `Kertas HVS A4 80 gsm`, `Kertas HVS F4 70 gsm`, `Buku Tulis 38 Lembar` | read-only | `getByTestId('visualization-legend')` |
| Footer drawer | buttons | `Batal` (REQ-041), `Terapkan ke Order` (REQ-039) | enabled | `getByRole('button', { name: 'Terapkan ke Order' })` |
| Panel Visualisasi Terbaru | drawer kanan | judul `Visualisasi Muatan Saat Ini`; **subjudul identik** dengan drawer Hitung Ulang → FND-04 | terbuka | `getByRole('dialog', { name: 'Visualisasi Muatan Saat Ini' })` |
| — blok Armada (read-only) | info | `Jenis Armada: Tronton Box`, `Jumlah Armada: 2`, `Berat Maksimal: 20.000 kg`, `Kubikasi Maksimal: 60 m³` | tanpa kontrol ubah (sesuai REQ-042) | `getByTestId('current-viz-armada-info')` |
| — footer | buttons | `Batal`, **`Terapkan ke Order`** | **melanggar REQ-042 / VAL-16** → FND-05 | `getByRole('button', { name: 'Terapkan ke Order' })` |

### 8. SCR-15 – SCR-17 — Step 3 Vendor dan Harga

| Elemen | Tipe | Label / Teks | State | Selector |
|---|---|---|---|---|
| Card | section | `Vendor dan Harga` (Normal) / `Vendor` + `Harga Pengiriman` (varian multi) | — | `getByRole('region', { name: 'Vendor dan Harga' })` |
| Vendor | dropdown, wajib | `Vendor *` / `Pilih Vendor` / `PT Logistik Transportasi Nusantara` | enabled | `getByLabel('Vendor')` |
| Tanggal Permintaan Muat | datetime, wajib | `Tanggal Permintaan Muat *`, placeholder `DD/MM/YYYY hh:mm`, terisi `24/07/2026 14:30` | enabled | `getByLabel('Tanggal Permintaan Muat')` |
| Ringkasan rute | text rows | `Drop Point Asal : Gudang MSK Region 2 • Kota Surabaya`, `Drop Point Tujuan : …`, `Jenis Armada : Tronton Wing Box` | read-only | `getByText('Drop Point Asal')` |
| Ringkasan alamat (multi) | label + **text link** | `Drop Point Asal : Multipickup • Lihat Detail` / `Drop Point Tujuan : Multidrop • Lihat Detail` | link (REQ-045); Multipoint punya **2 link** | `getByRole('link', { name: 'Lihat Detail' }).first()` |
| Waktu Perjalanan (rute belum ada) | number + suffix `Jam`, wajib | `Waktu Perjalanan *` = `0` / `8` | **textfield** (026, 028, 039, 046, 053) — REQ-044 | `getByLabel('Waktu Perjalanan')` |
| Waktu Perjalanan (rute sudah ada) | text-only | `Waktu Perjalanan : 8 Jam` | **read-only** (027) — REQ-044 | `getByText('Waktu Perjalanan').locator('..')` |
| Alert rute | info alert oranye | `Rute belum ada di Master Waktu Perjalanan. Isi waktu perjalanan, nilainya akan otomatis tersimpan sebagai data master baru.` | tampil hanya bila rute belum ada | `getByText(/Rute belum ada di Master Waktu Perjalanan/)` |
| Tabel ringkasan armada | table | `No`, `Nama Item`, `Total Berat`, `Total Kubikasi`, `Total Nilai Barang` | nilai `Tanpa Asuransi` atau `Rp1.150.350.000` | `getByRole('table')` |
| Harga | currency, wajib | `Harga *` prefix `Rp` + helper `Mencakup seluruh biaya armada pada order ini` | enabled | `getByLabel('Harga')` |
| Gunakan komponen harga | checkbox | `Gunakan komponen harga` | unchecked (026) / checked (027, 028) — REQ-046 | `getByRole('checkbox', { name: 'Gunakan komponen harga' })` |
| PPN / PPh / Asuransi | number + suffix `%` | `PPN` `1,1`, `PPh` `2`, `Asuransi` `0,2` | **Asuransi hanya** bila ada armada diasuransikan (REQ-047) | `getByLabel('PPN')` |
| Rincian harga | text rows | `Harga DPP Rp. 12.000.000`, `PPN (1,1%) Rp. 132.000`, `PPh (2%) - Rp. 240.000`, `Asuransi (0,2%) Rp2.300.700`, `(Total Nilai Barang = Rp. 63.620.000` | read-only; kurung tutup hilang → FND-07 | `getByText(/Total Nilai Barang =/)` |
| Total Harga | text bold | `Rp. 0` (026) / `Rp14.192.700` (027) / `Rp. 11.892.000` (028) | read-only | `getByTestId('step3-total-harga')` |
| Footer | buttons | `Batal`, `← Sebelumnya`, `Simpan ke Draf`, `Selanjutnya →` | enabled (REQ-048) | `getByRole('button', { name: 'Selanjutnya' })` |

### 9. SCR-18 — Step 4 Review (029) + varian multi

| Elemen | Tipe | Label / Teks | State | Selector |
|---|---|---|---|---|
| Accordion ×5 | collapsible card | `Jenis Pengiriman dan Rute`, `Data Pengirim`, `Data Penerima`, `Data Barang`, `Vendor dan Harga` | expanded, **read-only** (REQ-049) | `getByRole('button', { name: 'Data Barang' })` |
| Ringkasan Step 1 | text rows | `Jenis Pengiriman : FTL (Full Truck Load)`, `Jenis Armada : Tronton Wing Box`, `Jumlah Armada : 2`, `Tipe Pengiriman : Normal`, `Waktu Perjalanan : 8 Jam` | read-only | `getByText('FTL (Full Truck Load)')` |
| Visualisasi Muatan | button outline (eye) | `Visualisasi Muatan` | enabled (REQ-052; mengonfirmasi label ASM-020) | `getByRole('button', { name: 'Visualisasi Muatan' })` |
| Grup armada | sub-heading | `Armada 1`, `Armada 2` | — | `getByText('Armada 2')` |
| Label diasuransikan | badge | `Diasuransikan` | hanya armada berasuransi (REQ-051) | `getByText('Diasuransikan')` |
| Sub-grup alamat (multi) | header baris | Multipickup: `Pick Up N - <alamat>`; Multidrop: `Drop Off N - <alamat>`; Multipoint: pasangan `Pick Up i` \| `Drop Off j` | read-only (REQ-031) | `getByRole('region', { name: /Pick Up 1 - Jl\. Jambi/ })` |
| Nomor DO (review) | text | `TBL67827879232, TBL726378927398` atau `-` | read-only, bukan chip | `getByTestId('review-nomor-do-1')` |
| Tabel barang | table | `Kode SKU`/`Nama Barang`, `Kemasan`, `Kubikasi`/`Dimensi`, `Berat`, `Jumlah` (+ `Nilai Barang` khusus armada berasuransi) | read-only (REQ-050) | `getByRole('table').nth(0)` |
| Footer | buttons | `Batal`, `← Sebelumnya`, `Simpan ke Draf`, `Simpan` | enabled (REQ-053) | `getByRole('button', { name: 'Simpan', exact: true })` |

### 10. SCR-19 / SCR-21 / SCR-22 / SCR-24 — Pop up

| Layar (file) | Elemen | Label / Teks | Selector |
|---|---|---|---|
| Simpan Draf (030) | dialog + 2 button | `Anda yakin ingin menyimpan data dalam draf?` / `Data yang telah diisi akan disimpan sebagai draf`; `Batal`, `Simpan Draf` | `getByRole('button', { name: 'Simpan Draf' })` |
| Visualisasi Muatan (031a) | dialog + close `×` | judul `Visualisasi Muatan`; tab `Armada 1`/`Armada 2`; `Berat Terpakai 78%`, `Ruang Terpakai 82%`; kanvas + badge over-kapasitas + legenda; **tanpa tombol aksi footer** | `getByRole('dialog', { name: 'Visualisasi Muatan' })` |
| Batalkan Order (032) | dialog + close `×` | `ID Order : ORD-20260607009`; `Vendor : PT Logistik Transportasi Nusantara`; textarea wajib `Alasan Pembatalan *` placeholder `Tuliskan alasan pembatalan order`; button danger `Batalkan Order` | `getByLabel('Alasan Pembatalan')` |
| Data No. Perjalanan (035) | dialog + close `×` | chip `ID Order: ORD-20260607009` + chip `FTL`; baris: icon copy + `TRC79289802` + `L 1892 PGS • Fuso Box`; baris 2: `TRC79289802` + `L 6718 TH • Fuso Box` | `getByRole('dialog', { name: 'Data No. Perjalanan' })`, `getByRole('button', { name: 'Salin nomor perjalanan' }).first()` |
| Detail Multipickup (040, 054) | dialog + close `×` | `Pick Up 1 - Kota Surabaya` → `Gudang MSK Region 2:` → alamat lengkap; Pick Up 2 & 3 | `getByRole('dialog', { name: 'Detail Multipickup' })` |
| Detail Multidrop (047, 055) | dialog + close `×` | `Drop Off 1 - Kota Surabaya` → `Gudang Jaya Retail Malang:` → alamat; Drop Off 2 | `getByRole('dialog', { name: 'Detail Multidrop' })` |

### 11. SCR-20 / SCR-23 — Detail Order & Edit Order

| Elemen | Layar | Tipe | Label / Teks | State | Selector |
|---|---|---|---|---|---|
| Kembali | Detail | icon button + heading | `‹ Detail Order` | enabled | `getByRole('button', { name: 'Kembali' })` |
| Aksi header | Detail | buttons | `Visualisasi Muatan`, `Batalkan Order`, `Edit Order` | enabled saat `Menunggu Penugasan` | `getByRole('button', { name: 'Edit Order' })` |
| Badge status | Detail | badge | `Menunggu Penugasan` | read-only | `getByText('Menunggu Penugasan')` |
| Identitas order | Detail | text rows | `ID Order : ORD67890792`, `Tanggal Dibuat : 26/06/2026 08:17` | read-only (REQ-076) | `getByText('ORD67890792')` |
| Jenis & Tipe Pengiriman | Edit | text terkunci | `Jenis Pengiriman : FTL (Full Truck Load)`, `Tipe Pengiriman : Normal` | **locked/read-only** (REQ-060) ✔ | `getByText('Tipe Pengiriman').locator('..')` |
| Jenis Armada / Jumlah Armada | Edit | dropdown / number | `Jenis Armada *`, `Jumlah Armada *` | **editable** (REQ-061) ✔ | `getByLabel('Jenis Armada')` |
| Data Pengirim / Penerima | Edit | form | seluruh field Step 1 | editable | `getByLabel('PIC Pengirim')` |
| Data Barang | Edit | accordion | `Data Barang - Armada 1` / `Armada 2` (Normal, Multidrop, Multipoint) — **`Data Barang - Kontainer 1/2` pada Multipickup (043)** → FND-10 | editable penuh (asuransi, Nomor DO, Jumlah, Nilai Barang, Pilih Barang, hapus) | `getByRole('region', { name: 'Data Barang - Armada 1' })` |
| Vendor dan Harga | Edit | form | Vendor, Tanggal, tabel, Harga, komponen harga | editable | `getByLabel('Harga')` |
| Footer | Edit | buttons | `Batal` (danger outline), `Simpan` (primary) | enabled; pop up konfirmasi REQ-062 **tidak digambarkan** | `getByRole('button', { name: 'Simpan' })` |
| FAB auto stuffing | Edit | — | **tidak ada** `Hitung Ulang Armada` / `Visualisasi Terbaru` | — | mengoreksi ASM-017 → FND-09 |

### 12. Varian Multipickup / Multidrop / Multipoint (SCR-25 – SCR-39)

| Aspek | Multipickup (038, 039, 040, 041/042, 043, 043a) | Multidrop (045, 046, 047, 047a, 048, 049) | Multipoint (052, 053, 054/055, 056, 057, 057a) |
|---|---|---|---|
| Step 2 — header sub-grup | `Pick Up 1 - Jl. Jambi No.35, Darmo, Wonokromo, Kota Surabaya, Jawa Timur 60241` | `Drop Off 1 - Jl. Jambi No.35, …` | 2 kolom: `Pick Up i - …` \| `Drop Off j - …` (4 kombinasi/armada) |
| Isi tiap sub-grup | `Nomor DO` chips + tabel barang + `Pilih Barang` + alert kapasitas + total kubikasi/berat | idem | idem |
| Selector sub-grup | `getByRole('region', { name: /Pick Up 1 - Jl\. Jambi/ })` | `getByRole('region', { name: /Drop Off 2 - Jl\. Kalianyar/ })` | `getByTestId('armada-1-pickup-1-dropoff-2')` |
| Step 3 — ringkasan alamat | `Drop Point Asal : Multipickup • Lihat Detail` | `Drop Point Tujuan : Multidrop • Lihat Detail` | **dua** link `Lihat Detail` (asal & tujuan) |
| Step 3 — layout card | dipecah `Vendor` + `Harga Pengiriman` | idem | idem |
| Step 4 — Data Pengirim | 3 sub-card `Pick Up 1..3` | 1 card | 3 sub-card `Pick Up 1..3` |
| Step 4 — Data Penerima | 1 card | 2 sub-card `Drop Off 1..2` | 2 sub-card `Drop Off 1..2` |
| Step 4 — Data Barang | `Armada N` → per `Pick Up N` | `Armada N` → per `Drop Off N` | `Armada N` → per pasangan `Pick Up × Drop Off` |
| Edit Order — heading barang | **`Data Barang - Kontainer 1/2`** (FND-10) | `Data Barang - Armada 1/2` | `Data Barang - Armada 1/2` |
| Detail Order — Tipe Pengiriman | `Multipickup` (043a) ✔ | **`Normal`** walau ada Drop Off 1 & 2 (048) → FND-11 | `Multipoint` (057a) ✔ |

### 13. Pesan Validasi, Alert, Empty State & Teks Sistem (unik)

| # | Teks persis | Jenis | Lokasi (file) | REQ / AC |
|---|---|---|---|---|
| M-01 | `Nilai Barang harus diisi` | helper error inline + border merah | Step 2 (020, 021) | REQ-019, REQ-025, AC-017 |
| M-02 | `Jumlah harus diisi` | helper error inline + border merah | Step 2 (020, 021) | REQ-018, REQ-025, AC-014 |
| M-03 | `Kubikasi melebihi kapasitas armada` | alert informatif (badge merah) | 020, 021, 038, 043, 045, 049, 052, 057 | REQ-024a, AC-021 |
| M-04 | `Berat melebihi kapasitas armada` | alert informatif | 020, 021, 038, 045, 052 | REQ-024b, AC-022 |
| M-05 | `Kubikasi dan Berat melebihi kapasitas armada` | alert informatif | **tidak ada di desain manapun** | REQ-024c, AC-023 → FND-12 |
| M-06 | `Belum ada barang. Klik "Pilih Barang "` | empty state tabel | Step 2 Armada 3 (020, 021) | REQ-011 |
| M-07 | `Rute belum ada di Master Waktu Perjalanan. Isi waktu perjalanan, nilainya akan otomatis tersimpan sebagai data master baru.` | info alert oranye | 026, 028, 039, 046, 053 | REQ-044, AC-044 |
| M-08 | `110 koli melebihi kapasitas (outline merah)` | badge merah pada kanvas 3D | 024, 025, 031a | REQ-038 |
| M-09 | `Anda yakin ingin menyimpan data dalam draf?` / `Data yang telah diisi akan disimpan sebagai draf` | dialog konfirmasi | 030 | REQ-057, AC-056 |
| M-10 | `Pisahkan dengan koma untuk menambahkan beberapa nomor` | helper text | Step 2 & Edit (semua) | REQ-021, AC-019 |
| M-11 | `Berlaku untuk seluruh barang pada armada ini` | helper checkbox asuransi | Step 2 & Edit | REQ-020, AC-016 |
| M-12 | `Mencakup seluruh biaya armada pada order ini` | helper field Harga | Step 3 | REQ-043 |
| M-13 | `Nama PIC Pengirim` / `Nama PIC Penerima` | helper text | Step 1 & Edit | REQ-007 |
| M-14 | `Contoh: 081234567898` | helper format WhatsApp | Step 1 & Edit | REQ-007 |
| M-15 | `3 barang terpilih` (pola `N barang terpilih`) | counter | Modal Pilih Barang (022) | REQ-015, AC-010 |
| M-16 | `Sudah Ditambahkan` | badge | Modal Pilih Barang (022) | REQ-014, AC-011 |
| M-17 | `Paling Efisien` | badge rekomendasi | Drawer (023, 024) | REQ-036, AC-032 |
| M-18 | `Diasuransikan` | badge armada | 029, 031, 041/042, 043a, 047a, 048, 056, 057a | REQ-051, AC-052 |
| M-19 | `Tanpa Asuransi` | nilai sel tabel | Step 3 & Review | REQ-047, AC-048 |
| M-20 | `1306 koli • 19.995 kg dialokasikan ke unit ini` | overlay kanvas | 023–025, 031a | REQ-038 |
| M-21 | `Drag: putar 360° • Scroll: zoom • Klik 2×: reset` | hint interaksi kanvas | 023–025, 031a | REQ-038 |
| M-22 | `Tuliskan alasan pembatalan order` | placeholder field wajib | 032 | REQ-065, AC-066 |
| M-23 | `Menampilkan 1 - 20 data dari 30 data` | info paginasi | 016, 017, 034, 036, 050 | — |
| M-24 | `Simulasi ulang kebutuhan unit dari muatan order ini. Terapkan untuk ubah data order.` | subjudul drawer | 023, 024, **dan 025** | REQ-033, REQ-042 → FND-04 |
| M-25 | Badge status: `Isi Data Dasar`, `Isi Data Muatan`, `Isi Data Vendor`, `Review Order`, `Menunggu Penugasan`, `Ditugaskan`, `Proses Pengiriman`, `Terkirim`, `Dibatalkan` | status chip | Daftar Order | REQ-054, AC-055 → FND-13 |

### 14. Peta Navigasi / Transisi Antar Layar

```
Daftar Order (SCR-01)
 ├─ [Filter] ─────────────────► panel filter (SCR-02) ─ [Terapkan] / [Reset]
 ├─ [Buat Order] ─────────────► Step 1 (SCR-04 → SCR-05/06/07/08)
 │      [Selanjutnya] ───────► Step 2 (SCR-09/25/31/37)
 │            ├─ [Pilih Barang] ──────► Modal Pilih Barang (SCR-11) ─ [Simpan]/[Batal] ─► Step 2
 │            ├─ [Hitung Ulang Armada] ► Drawer (SCR-12/13)
 │            │        ├─ [Pilih Jenis Armada] ► modal pilih armada (tidak ada desain)
 │            │        ├─ [Terapkan ke Order] ─► sinkron Step 1 & Step 2 (REQ-040)
 │            │        └─ [Batal] ─────────────► Step 2 tanpa perubahan (REQ-041)
 │            ├─ [Visualisasi Terbaru] ► Panel Visualisasi Muatan Saat Ini (SCR-14)
 │            └─ [Selanjutnya] ────────► Step 3 (SCR-15/16/17/26/32/38)
 │                    ├─ [Lihat Detail] ► Pop up Detail Multipickup / Multidrop (SCR-27/33)
 │                    └─ [Selanjutnya] ─► Step 4 Review (SCR-18/28/34/39)
 │                            ├─ [Visualisasi Muatan] ► Pop up (SCR-21)
 │                            └─ [Simpan] ► status "Menunggu Penugasan" ► Daftar Order
 │      [Simpan ke Draf] (step manapun) ► Pop up konfirmasi (SCR-19) ► [Simpan Draf] ► Daftar Order
 │      [Batal] ► pop up konfirmasi (tidak digambarkan, ASM-015) ► Daftar Order
 ├─ aksi [Detail] ────────────► Detail Order (SCR-20/30/35/39)
 │            ├─ [Visualisasi Muatan] ► Pop up (SCR-21)
 │            ├─ [Batalkan Order] ────► Pop up Batalkan Order (SCR-22) ► status "Dibatalkan"
 │            └─ [Edit Order] ────────► Edit Order (SCR-23/29/36/39) ─ [Simpan] / [Batal]
 ├─ aksi [Lanjutkan Pengisian] ► wizard pada step terakhir (status draft)
 ├─ aksi [Edit] ──────────────► Edit Order (SCR-23)
 ├─ aksi [Lihat No. Perjalanan] ► Pop up Data No. Perjalanan (SCR-24)
 └─ [Riwayat Pembatalan] / aksi [Riwayat Perubahan] ► layar terpisah (TIDAK ADA desain — ASM-D04)
```

### 15. Temuan Desain (diskrepansi terhadap Requirements)

| ID | Temuan | File | Dampak pada penulisan test |
|---|---|---|---|
| FND-01 | Action menu status `Ditugaskan` memuat item **`Order Kembali`** yang tidak disebut REQ-068 | 034 | AC-070 perlu diperluas atau item ditandai out-of-scope |
| FND-02 | Step 2 menampilkan **3 card Armada** padahal `Data Unit → Jumlah Armada = 2` | 020, 021 | jangan jadikan jumlah card sebagai oracle; uji sinkronisasi REQ-026 secara eksplisit |
| FND-03 | Modal `Pilih Barang` **tanpa tombol close `×`**; hanya `Batal`/`Simpan` | 022 | penutupan modal harus via `Batal`, bukan `×`/Escape |
| FND-04 | Subjudul panel `Visualisasi Muatan Saat Ini` **identik** dengan drawer `Hitung Ulang Armada` | 025 | bedakan layar via judul (`getByRole('dialog', { name })`), bukan subjudul |
| FND-05 | Panel `Visualisasi Terbaru` memiliki tombol **`Terapkan ke Order`** → berpotensi mengubah pilihan armada | 025 | skenario negatif AC-038 / VAL-16 |
| FND-06 | Label WhatsApp tidak konsisten: `No. WhatsApp PIC` (Normal) vs `Nomor WhatsApp PIC` (varian multi) | 019 vs 037/044/051 | `getByLabel` harus dibedakan per varian tipe pengiriman |
| FND-07 | Rincian asuransi `(Total Nilai Barang = Rp. 63.620.000` — kurung tutup hilang | 027, 029, 031, 041 | hindari exact string match; gunakan regex |
| FND-08 | Dua baris No. Perjalanan bernilai **identik** `TRC79289802` | 035 | skenario negatif keunikan (AC-073) |
| FND-09 | Halaman Edit Order **tidak** menampilkan FAB `Hitung Ulang Armada` / `Visualisasi Terbaru` | 033, 043, 049, 057 | **mengoreksi ASM-017**; UF-03.A4 perlu ditinjau ulang |
| FND-10 | Edit Order Multipickup memakai heading `Data Barang - Kontainer 1/2` padahal jenis FTL | 043 | selector heading harus toleran; laporkan sebagai bug |
| FND-11 | Detail Order Multidrop menampilkan `Tipe Pengiriman : Normal` walau ada `Drop Off 1` & `Drop Off 2` | 048 | data dummy salah; jangan dijadikan oracle |
| FND-12 | Kondisi alert gabungan `Kubikasi dan Berat melebihi kapasitas armada` **tidak ada** di desain | — | AC-023 diuji tanpa referensi visual |
| FND-13 | Nama status desain ≠ spec: `Isi Data Dasar` (spec: *Isi Data Pengiriman*) dan `Terkirim` (spec: *Selesai*) | 016, 034, 036, 050 | **koreksi REQ-054** saat menulis assertion status |
| FND-14 | Step 3 & Review varian multi menampilkan `Armada 1, Armada 2, Armada 2` (penomoran duplikat; 3 baris untuk 2–3 armada) | 039, 041/042, 043a, 047a, 048, 056 | assert jumlah baris = jumlah armada, jangan assert penomoran |
| FND-15 | Sidebar aktif pada 036/050 adalah `Simulasi Muatan` walau konten `Daftar Order` | 036, 050 | abaikan state sidebar sebagai oracle navigasi |

---

## Assumptions Log

| ID | Ambiguitas pada Spec | Asumsi yang Diambil | Dampak / Risiko |
|---|---|---|---|
| ASM-001 | Spec menyebut "Shipper" dan "admin shipper" tanpa mendefinisikan hierarki role. | Diasumsikan terdapat minimal 2 role shipper: **Admin Shipper** (memiliki hak pembatalan) dan **Staff Operasional Shipper** (membuat/mengedit order). Aksi pembatalan eksplisit milik **admin shipper** (REQ-064). | Sedang — matriks role perlu dikonfirmasi ke PO sebelum test role-based access. |
| ASM-002 | Tidak dijelaskan apakah Staff Operasional dapat membatalkan order. | Diasumsikan hak pembatalan mengikuti kebijakan tenant; untuk pengujian, **hanya Admin Shipper** yang dijamin memiliki aksi Batalkan Order. | Sedang. |
| ASM-003 | Tidak dijelaskan apakah vendor dapat melihat No. Perjalanan. | Diasumsikan vendor dapat melihat No. Perjalanan pada konteks penugasannya (nomor melekat pada armada yang ditugaskan). | Rendah. |
| ASM-004 | "Rule cascading & minimal baris per tipe pengiriman" tidak dirinci (mengacu TMS). | Diasumsikan minimal baris: **Normal** = 1 pengirim + 1 penerima; **Multipickup** ≥ 2 pengirim; **Multidrop** ≥ 2 penerima; **Multipoint** ≥ 2 pengirim & ≥ 2 penerima. Cascading = pemilihan Provinsi → Kota → Kecamatan → Droppoint. | **Tinggi** — angka minimal wajib dikonfirmasi ke spesifikasi TMS sebelum menulis skenario negatif. |
| ASM-005 | Batas bawah/atas **Jumlah Armada** tidak disebut. | Diasumsikan bilangan bulat **≥ 1**, tanpa batas atas eksplisit (dibatasi kewajaran/kapasitas sistem). | Rendah. |
| ASM-006 | Batas nilai field **Jumlah** barang tidak disebut. | Diasumsikan bilangan bulat **≥ 1** (nilai 0 dan negatif ditolak). | Sedang. |
| ASM-007 | Batas nilai **Nilai Barang** tidak disebut. | Diasumsikan angka **> 0** dalam format mata uang IDR. | Sedang. |
| ASM-008 | Kondisi default checkbox "Tambahkan Asuransi" tidak disebut. | Diasumsikan **default tidak tercentang** (asuransi bersifat opt-in), sehingga kolom Nilai Barang tersembunyi saat pertama kali Step 2 dibuka. | Sedang — mempengaruhi AC-015. |
| ASM-009 | Batas **Tanggal Permintaan Muat** tidak disebut (mengacu TMS). | Diasumsikan tanggal **tidak boleh di masa lalu** (≥ hari ini). | Sedang. |
| ASM-010 | Spec menyatakan "Hitung Ulang Armada hanya dapat dijalankan saat minimal 1 data barang diisi" tanpa menjelaskan bentuk penolakannya. | Diasumsikan button dalam kondisi **disabled** saat belum ada data barang; bila implementasi memakai pop up informasi (seperti modul oms011), keduanya diterima sebagai pemenuhan REQ-029. | Sedang — desain tidak menampilkan state kosong (lihat ASM-D06). |
| ASM-011 | Satuan & format angka Kubikasi/Berat/Dimensi tidak disebut. | Diasumsikan **Kubikasi = m³**, **Berat = kg**, **Dimensi = P × L × T dalam cm**, format angka locale **id-ID** — konsisten dengan modul oms002-master-barang & oms011-simulasi-muatan. | Rendah — **terkonfirmasi oleh desain** (020, 022, 023). |
| ASM-012 | Tidak dijelaskan filter data pada modal "Pilih Barang". | Diasumsikan hanya barang **milik shipper/tenant yang sedang login** dan berstatus **Aktif** yang tampil. | Sedang. |
| ASM-013 | Perilaku barang berlabel "Sudah Ditambahkan" tidak dijelaskan (masih dapat dipilih atau tidak). | Diasumsikan barang tersebut **tidak dapat dipilih ulang** untuk armada yang sama (checkbox disabled), namun **tetap dapat dipilih** untuk armada lain karena label bersifat per armada. | **Tinggi** — **dikoreksi oleh desain 022**: checkbox tetap aktif & tercentang (lihat ASM-D07). |
| ASM-014 | Aksi yang tersedia untuk status **Proses Pengiriman, Selesai, dan Dibatalkan** tidak dirinci pada spec. | Diasumsikan hanya aksi **Detail** dan **Riwayat Perubahan** (plus **Lihat No. Perjalanan** untuk Proses Pengiriman & Selesai) yang tersedia; aksi Edit, Lanjutkan Pengisian, dan Batalkan Order tidak tersedia. | Sedang — matriks aksi untuk 3 status ini bersifat inferensi; desain tidak menampilkan menunya. |
| ASM-015 | Perilaku button **Batal** pada wizard Step 1–4 tidak dirinci (hanya "identik TMS"). | Diasumsikan menampilkan **pop up konfirmasi** sebelum meninggalkan pengisian, konsisten dengan perilaku Batal pada Edit Order (REQ-062). | Rendah — pop up Batal tidak digambarkan (hanya pop up Simpan Draf, 030). |
| ASM-016 | "Input manual maupun batch order" disebut tanpa detail mekanisme batch. | Diasumsikan mekanisme batch **identik dengan TMS** (upload template) dan **berada di luar cakupan detail modul ini**; hanya dicatat sebagai alur alternatif UF-01.A14. | Sedang — tombol `Batch Order` terlihat pada toolbar Daftar Order namun layarnya tidak didesain. |
| ASM-017 | Tidak dijelaskan apakah drawer Hitung Ulang Armada tersedia pada mode **Edit Order**. | Semula diasumsikan **tersedia**. **Dikoreksi oleh desain**: halaman Edit Order (033, 043, 049, 057) **tidak** memuat floating button auto stuffing (lihat ASM-D08 / FND-09). | Sedang — UF-03.A4 perlu direvisi. |
| ASM-018 | Spec **tidak** mencantumkan acceptance criteria eksplisit. | Seluruh AC-001 s.d. AC-080 diturunkan langsung dari requirement dengan format Given/When/Then dan traceability ke REQ. | Rendah. |
| ASM-019 | Besaran **persentase asuransi** tidak disebut pada spec. | Diasumsikan persentase diambil dari **konfigurasi master/komponen harga** (bukan hardcode); pengujian memverifikasi formula `Asuransi = persentase × Total Nilai Barang`, bukan nilai persentasenya. | Sedang — desain memakai contoh `0,2 %` yang **dapat diedit user** pada Step 3 (027). |
| ASM-020 | Spec baris 8 menyebut button "visualisasi muatan" pada Step 4 tanpa label persis. | Diasumsikan label button **"Visualisasi Muatan"** pada card Data Barang di Step 4. | Rendah — **terkonfirmasi oleh desain 029 & 031**. |
| ASM-021 | Penomoran pada section Step 2 spec melompat (poin 2 → 4) dan section Drawer (poin 1 → 3). | Diasumsikan **tidak ada requirement yang hilang** — penomoran adalah typo pada dokumen sumber. | **Tinggi** — sebaiknya dikonfirmasi ke BA/PO bahwa tidak ada poin 3 yang terpotong pada kedua section tersebut. |
| ASM-022 | Tidak dijelaskan apakah penempatan barang hasil "Terapkan ke Order" dapat diubah manual oleh user setelahnya. | Diasumsikan user **tetap dapat** menambah/menghapus barang per armada setelah penerapan (REQ-022 tidak dibatasi), dan dapat menjalankan Hitung Ulang Armada kembali. | Sedang. |
| ASM-023 | Format **No. Perjalanan** tidak disebut. | Diasumsikan string **unik hasil generate sistem**; pengujian memverifikasi keunikan, keterikatan pada armada, dan jumlah — bukan pola formatnya. | Rendah — desain 035 memakai pola `TRC########` namun **duplikat** (FND-08). |
| **ASM-D01** | Desain tidak mencantumkan atribut teknis (`id`, `name`, `data-testid`) pada elemen manapun. | Seluruh nilai `data-testid` pada UI Inventory adalah **usulan penamaan** (kebab-case, prefiks konteks layar). Strategi selector utama tetap `getByRole` + accessible name yang **terlihat di desain**; `testid` hanya fallback untuk elemen ikon-saja (FAB, kebab menu, copy, hapus, kanvas 3D). | **Tinggi** — bila FE tidak menambahkan `data-testid`, elemen ikon-saja harus di-target via `aria-label`; perlu disepakati dengan tim FE sebelum implementasi test. |
| **ASM-D02** | Layar Daftar Order pada 036 & 050 identik dengan 016 tetapi item sidebar yang aktif adalah `Simulasi Muatan`, bukan `Order`. | Diasumsikan **inkonsistensi desain (copy-paste)**, bukan requirement. Layar diperlakukan sebagai satu layar logis (SCR-01); state sidebar **tidak** dijadikan assertion. | Rendah (FND-15). |
| **ASM-D03** | Pada panel Filter (017, 034), placeholder `Pilih Tipe Pengiriman` & `Pilih Metode Pengiriman` dirender lebih pudar dibanding dropdown lain. | Diasumsikan kedua field **disabled** hingga `Jenis Order` dipilih (dependent filter). Bila ternyata enabled, hanya perbedaan styling. | Sedang — mempengaruhi skenario filter bertingkat. |
| **ASM-D04** | Tidak ada desain untuk layar `Riwayat Pembatalan` (toolbar) dan `Riwayat Perubahan` (aksi per baris). | Diasumsikan keduanya membuka **halaman/modal terpisah** yang berada di luar cakupan desain modul ini; pengujian dibatasi pada **keberadaan & keterklikan** tombol/aksi (REQ-069). | Sedang — AC-071 & AC-072 tidak dapat diverifikasi secara visual. |
| **ASM-D05** | Modal **"Pilih Jenis Armada"** (dipicu dari drawer Hitung Ulang Armada, REQ-037) tidak memiliki file desain. | Diasumsikan berupa modal daftar jenis armada dengan pencarian & pemilihan tunggal, mirip modal `Pilih Barang`. Assertion dibatasi pada perubahan nilai field `Jenis Armada` setelah modal ditutup. | Sedang — AC-033 sebagian bersifat inferensi. |
| **ASM-D06** | Desain tidak menampilkan state Step 2 **tanpa data barang sama sekali** pada seluruh armada, sehingga kondisi disabled/penolakan `Hitung Ulang Armada` (REQ-029) tidak terlihat. | Diasumsikan tetap sesuai **ASM-010** (button disabled **atau** pop up informasi). Test AC-028 menerima kedua bentuk penolakan. | Sedang. |
| **ASM-D07** | Pada modal `Pilih Barang` (022), item berlabel `Sudah Ditambahkan` justru **tercentang dan tetap aktif** (tidak disabled). | Diasumsikan label bersifat **informatif saja** dan barang **tetap dapat dipilih/dilepas** untuk armada yang sama. Ini **mengoreksi ASM-013 & VAL-M4**. | **Tinggi** — skenario duplikasi barang harus ditulis ulang mengikuti perilaku desain, bukan asumsi awal. |
| **ASM-D08** | Halaman Edit Order (033, 043, 049, 057) tidak memuat floating button `Hitung Ulang Armada` / `Visualisasi Terbaru`, dan tidak memuat pop up konfirmasi untuk `Batal`/`Simpan` (REQ-062). | Diasumsikan fitur auto stuffing **tidak tersedia pada mode Edit** (mengoreksi ASM-017), sedangkan pop up konfirmasi REQ-062 **tetap ada** namun tidak digambarkan. | Sedang–Tinggi — UF-03.A4 & AC-062 perlu konfirmasi PO. |
| **ASM-D09** | Nama status pada desain berbeda dari spec: `Isi Data Dasar` vs *Isi Data Pengiriman*, dan `Terkirim` vs *Selesai*. | Diasumsikan **desain adalah sumber kebenaran untuk teks UI**, sementara spec adalah sumber kebenaran untuk makna status. Assertion status memakai teks desain, dengan pemetaan didokumentasikan. | **Tinggi** — mempengaruhi AC-055, AC-057 dan seluruh assertion badge status (FND-13). |
| **ASM-D10** | Beberapa nilai dummy pada desain saling bertentangan (Jumlah Armada 2 tetapi 3 card armada / 3 baris tabel harga; dua No. Perjalanan identik; Detail Multidrop bertipe `Normal`; total kubikasi Review ≠ Detail). | Diasumsikan **kesalahan data contoh**, bukan requirement. Test **tidak** memakai angka-angka tersebut sebagai oracle; assertion diarahkan pada relasi (jumlah baris = jumlah armada, keunikan nomor, konsistensi tipe pengiriman). | **Tinggi** — bila diperlakukan sebagai expected value, test akan mengunci bug (FND-02, FND-08, FND-11, FND-14). |
| **ASM-D11** | Pada Step 1, `Jumlah Armada` adalah input angka biasa, sedangkan stepper `−`/`+` hanya ada pada drawer Hitung Ulang Armada. | Diasumsikan **dua kontrol berbeda** untuk field yang sama; test Step 1 memakai `fill()`, test drawer memakai klik stepper **dan** `fill()`. | Rendah — memperjelas Validation Rules Step 1 (baris "Jumlah Armada — Number / stepper"). |
| **ASM-D12** | Kondisi alert gabungan `Kubikasi dan Berat melebihi kapasitas armada` (REQ-024c) tidak pernah muncul di 46 desain. | Diasumsikan **tetap merupakan requirement valid** yang belum digambarkan; test AC-023 ditulis dari spec dengan catatan "tanpa referensi visual". | Sedang (FND-12). |
