# Analysis — oms013-order-fcl-auto-stuffing

> Sumber: `inputs/oms013-order-fcl-auto-stuffing/spec.txt` (dianalisis 2026-08-24).
> Modul: Order FCL dengan Auto Stuffing pada OMS (Order Management System), turunan dari Order FCL di TMS.

## Requirements

### Ringkasan Modul

Order FCL (Full Container Load) pada OMS mengikuti spesifikasi Order FCL di TMS: definisi FCL, satuan Kontainer, alur 4 step pengisian (Data Pengiriman → Data Barang → Vendor & Harga → Review), serta mendukung input manual maupun batch order. Perbedaan utama dengan TMS:

1. **Step 2 (Data Barang)** — barang tidak diinput manual, melainkan dipilih dari **Master Barang** melalui modal "Pilih Barang".
2. **Step 4 (Review)** — tampilan Data Barang mengikuti struktur Step 2 OMS, dan terdapat **visualisasi muatan (auto stuffing)** berupa pop up yang tampil saat klik button "Visualisasi Muatan".
3. **Step 1** — field Metode Pengiriman tidak diperlukan pada OMS.

Modul juga mencakup: siklus 9 status order, hak edit order, pembatalan order, aksi kontekstual pada Daftar Order, dan No. Perjalanan untuk public tracking.

### Aktor & Role

| Aktor | Peran |
|---|---|
| **Shipper (Admin Shipper)** | Membuat order (manual/batch), mengisi 4 step, menyimpan draf, submit order, mengedit order (selama status memungkinkan), membatalkan order (wajib isi Alasan Pembatalan). |
| **Vendor** | Melakukan penugasan armada (status order → "Ditugaskan"). Tidak dapat membatalkan order. |
| **Pengirim / Penerima** | Menggunakan No. Perjalanan untuk memantau progres armada/kontainer melalui public tracking. |
| **Sistem** | Auto-draft data (Master Droppoint, Master Barang), generate No. Perjalanan otomatis per armada/kontainer, hitung harga (PPN, PPh, Asuransi), transisi status. |

### Daftar Requirement

#### Ketentuan Umum
- **REQ-001** — Order FCL OMS mengacu pada spesifikasi Order FCL TMS: definisi FCL, satuan Kontainer, 4 step pengisian (Data Pengiriman, Data Barang, Vendor & Harga, Review), serta mendukung input manual maupun batch order.
- **REQ-002** — Perbedaan utama dengan TMS pada Step 2 (Data Barang): data barang diambil dari Master Barang, bukan input deskripsi manual.
- **REQ-003** — Penyesuaian turunan pada Step 4 (Review): informasi Data Barang mengikuti struktur Step 2 OMS, dan terdapat pop up visualisasi muatan yang tampil saat klik button "Visualisasi Muatan".

#### Step 1 — Data Pengiriman
- **REQ-004** — Step 1 identik dengan Step 1 Order FCL TMS: field Pelabuhan Asal, Pelabuhan Tujuan, Jenis Kontainer, Jumlah Kontainer, Tipe Pengiriman (Normal/Multipickup/Multidrop/Multipoint), Data Pengirim & Data Penerima (auto-draft dari Master Droppoint).
- **REQ-005** — Rule cascading antar-field dan minimal jumlah baris (pengirim/penerima) per Tipe Pengiriman berlaku identik dengan TMS.
- **REQ-006** — Validasi field wajib pada Step 1 berlaku identik dengan TMS.
- **REQ-007** — Fungsi button Step 1 (Batal / Draf / Selanjutnya) berlaku identik dengan TMS.
- **REQ-008** — Field Metode Pengiriman TIDAK ada pada OMS (di TMS hanya dibutuhkan untuk penugasan tracking step "Selesai Muat" dan "Selesai Bongkar").

#### Step 2 — Data Barang
- **REQ-009** — Barang dipilih dari Master Barang melalui modal "Pilih Barang" (bukan input manual).
- **REQ-010** — Modal "Pilih Barang" memiliki pencarian by kode/nama barang.
- **REQ-011** — Modal "Pilih Barang" mendukung multi-select via checkbox.
- **REQ-012** — Barang yang sudah masuk ke kontainer terkait diberi label "Sudah Ditambahkan" di modal.
- **REQ-013** — Modal menampilkan counter jumlah barang terpilih.
- **REQ-014** — Modal memiliki button Batal dan Simpan.
- **REQ-015** — Field yang otomatis ter-draft dari Master Barang dan bersifat read-only: Kode SKU, Nama Barang, Kemasan, Kubikasi, Dimensi, Berat.
- **REQ-016** — Field Jumlah diinput user per baris barang dan wajib diisi.
- **REQ-017** — Field Nilai Barang hanya muncul & wajib diisi saat checkbox "Tambahkan Asuransi" pada armada tersebut dicentang.
- **REQ-018** — Checkbox "Tambahkan Asuransi" bersifat per armada: berlaku untuk seluruh barang pada armada tersebut; saat dicentang, kolom Nilai Barang tampil dan menjadi wajib.
- **REQ-019** — Nomor DO per armada: tidak wajib, dapat diisi lebih dari satu, dipisahkan koma, tampil sebagai chip.
- **REQ-020** — Setiap baris barang dapat dihapus (icon hapus).
- **REQ-021** — Alert kapasitas kontainer bersifat informasi saja (non-blocking); user tetap dapat lanjut ke step berikutnya. Pesan sesuai kondisi: (a) kubikasi lebih → "Kubikasi melebihi kapasitas kontainer"; (b) berat lebih → "Berat melebihi kapasitas kontainer"; (c) keduanya → "Kubikasi dan Berat melebihi kapasitas kontainer".
- **REQ-022** — Jika field wajib (Jumlah / Nilai Barang saat asuransi aktif) kosong: tampil helper error dan border field berubah warna error.
- **REQ-023** — Fungsi button Step 2 (Batal / Draf / Sebelumnya / Selanjutnya) identik dengan Step 2 TMS.

#### Step 3 — Vendor & Harga
- **REQ-024** — Step 3 identik dengan TMS: field Pilihan Vendor, input Tanggal Permintaan Muat, input Harga, ringkasan alamat (label + text link untuk tipe multi), komponen harga opsional via checkbox "Gunakan Komponen Harga".
- **REQ-025** — FCL tidak memiliki input Waktu Perjalanan; perhitungan mengikuti TMS (ETA − ETD + 4 hari) dan baru tampil pada informasi detail saat status "Ditugaskan".
- **REQ-026** — Komponen Asuransi mengikuti data Step 2: saat ada kontainer diasuransikan, nilai Asuransi (persentase × Total Nilai Barang) turut dihitung ke Total Harga, di samping PPN & PPh.
- **REQ-027** — Validasi field wajib & fungsi button Step 3 (Batal / Draf / Sebelumnya / Selanjutnya) identik dengan TMS.

#### Step 4 — Review
- **REQ-028** — Step 4 menampilkan ringkasan seluruh data Step 1–3 secara read-only, sama dengan TMS.
- **REQ-029** — Bagian Data Barang mengikuti struktur Step 2 OMS: menampilkan Kode SKU, Nama Barang, Kemasan, Kubikasi/Dimensi, Berat, Jumlah, dan Nilai Barang (untuk armada yang diasuransikan), termasuk label "Diasuransikan" per kontainer.
- **REQ-030** — Terdapat button visualisasi auto stuffing pada card Data Barang; saat diklik menampilkan pop up visualisasi muatan.
- **REQ-031** — Fungsi button Step 4 (Batal / Draf / Sebelumnya / Simpan) identik dengan TMS; Simpan mengubah status order menjadi "Menunggu Penugasan".

#### Status Order
- **REQ-032** — Terdapat 9 status order FCL: (1) Isi Data Pengiriman — belum selesai di step Data Pengiriman; (2) Isi Data Muatan — belum selesai di step Data Barang; (3) Isi Data Vendor — belum selesai di step Vendor & Harga; (4) Review Order — semua step terisi namun belum submit; (5) Menunggu Penugasan — data lengkap & disubmit, menunggu penugasan vendor; (6) Ditugaskan — vendor sudah melakukan penugasan; (7) Proses Pengiriman — status penugasan armada "Dalam Perjalanan"; (8) Selesai — seluruh armada selesai bongkar (status penugasan "Selesai"); (9) Dibatalkan — order dibatalkan oleh admin shipper.
- **REQ-033** — Status 1–4 (Isi Data Pengiriman s.d. Review Order) merupakan kondisi draft, tersimpan otomatis melalui aksi "Simpan ke Draf" pada step manapun.

#### Hak Edit Order
- **REQ-034** — Shipper dapat mengubah data order selama status dalam rentang draft (Isi Data Pengiriman s.d. Review Order) hingga "Menunggu Penugasan".
- **REQ-035** — Shipper tidak dapat mengubah data order setelah status "Ditugaskan".
- **REQ-036** — Pada halaman Edit Order: field Jenis Pengiriman dan Tipe Pengiriman locked/read-only.
- **REQ-037** — Field Jenis Armada, Jumlah Armada, Data Pengirim, Data Penerima, Data Barang, dan Vendor & Harga tetap dapat diubah selama order berstatus dapat diedit (mengacu REQ-034).
- **REQ-038** — Button Edit Order: Batal (membatalkan pengisian, tampil pop up konfirmasi) dan Simpan (menyelesaikan pengeditan, tampil pop up konfirmasi).

#### Pembatalan Order
- **REQ-039** — Order dapat dibatalkan selama status dalam rentang draft hingga "Ditugaskan"; tidak dapat dibatalkan setelah status "Proses Pengiriman".
- **REQ-040** — Pembatalan dilakukan oleh admin shipper (bukan vendor).
- **REQ-041** — Field "Alasan Pembatalan" wajib diisi saat melakukan pembatalan.

#### Aksi pada Daftar Order FCL
- **REQ-042** — Aksi per-baris menyesuaikan status order: (a) Isi Data Pengiriman/Muatan/Vendor & Review Order → Detail, Lanjutkan Pengisian, Batalkan Order, Riwayat Perubahan; (b) Menunggu Penugasan → Detail, Edit, Batalkan Order, Riwayat Perubahan; (c) Ditugaskan → Detail, Batalkan Order, Riwayat Perubahan, Lihat No. Perjalanan (Edit tidak tersedia).
- **REQ-043** — Tombol "Riwayat Pembatalan" pada toolbar Daftar Order menampilkan daftar seluruh order yang pernah dibatalkan (terpisah dari aksi per-baris "Riwayat Perubahan" yang menampilkan histori perubahan order tertentu).

#### No. Perjalanan
- **REQ-044** — No. Perjalanan digunakan untuk pengecekan pada public tracking oleh pengirim/penerima.
- **REQ-045** — No. Perjalanan di-generate otomatis oleh sistem, melekat pada armada/kontainer; jumlahnya menyesuaikan jumlah armada/kontainer yang dipesan.
- **REQ-046** — No. Perjalanan hanya tampil untuk jenis pengiriman FTL & FCL.
- **REQ-047** — Aksi "Lihat No. Perjalanan" pada action menu baru tampil setelah penugasan dilakukan (status "Ditugaskan").
- **REQ-048** — Klik "Lihat No. Perjalanan" menampilkan pop up "Data No. Perjalanan" berisi per armada/kontainer: No. Perjalanan (hasil generate sistem), Nopol/No. Kontainer, dan Jenis Armada/Kontainer.
- **REQ-049** — Pada pop up, No. Perjalanan dilengkapi icon copy untuk menyalin nomor perjalanan.
- **REQ-050** — No. Perjalanan juga dapat dilihat pada halaman Detail Order (selain via action menu).

### Aturan Validasi

| # | Lokasi | Aturan | Perilaku saat gagal |
|---|---|---|---|
| VAL-01 | Step 1 | Field wajib Step 1 (Pelabuhan Asal, Pelabuhan Tujuan, Jenis Kontainer, Jumlah Kontainer, Tipe Pengiriman, Data Pengirim, Data Penerima) harus terisi sebelum "Selanjutnya" | Identik TMS: blokir lanjut, tampil indikasi error |
| VAL-02 | Step 1 | Minimal baris pengirim/penerima sesuai Tipe Pengiriman (Normal/Multipickup/Multidrop/Multipoint) + rule cascading | Identik TMS |
| VAL-03 | Step 2 | Jumlah per baris barang wajib diisi | Helper error + border field berwarna error |
| VAL-04 | Step 2 | Nilai Barang wajib diisi bila "Tambahkan Asuransi" armada dicentang | Helper error + border field berwarna error |
| VAL-05 | Step 2 | Alert kapasitas (Kubikasi/Berat/keduanya melebihi kapasitas kontainer) | Informasi saja — TIDAK memblokir lanjut ke step berikutnya |
| VAL-06 | Step 2 | Nomor DO opsional; multi-nilai dipisah koma → dirender sebagai chip | Tidak ada error (opsional) |
| VAL-07 | Step 3 | Field wajib Step 3 (Pilihan Vendor, Tanggal Permintaan Muat, Harga) | Identik TMS: blokir lanjut, tampil indikasi error |
| VAL-08 | Step 3 | Bila ada kontainer diasuransikan → Asuransi = persentase × Total Nilai Barang ikut dihitung ke Total Harga bersama PPN & PPh | Perhitungan otomatis |
| VAL-09 | Pembatalan | "Alasan Pembatalan" wajib diisi | Pembatalan tidak dapat diproses |
| VAL-10 | Edit Order | Jenis Pengiriman & Tipe Pengiriman read-only/locked | Tidak dapat diubah |
| VAL-11 | Transisi status | Edit hanya s.d. "Menunggu Penugasan"; batalkan hanya s.d. "Ditugaskan" | Aksi tidak tersedia pada status di luar rentang |
| VAL-12 | Modal Pilih Barang | Barang yang sudah ditambahkan ke kontainer terkait diberi label "Sudah Ditambahkan" | Mencegah kebingungan duplikasi pemilihan |

### User Flow

**Flow A — Buat Order FCL (happy path):**
1. Shipper membuka form Order FCL → Step 1: isi Pelabuhan Asal/Tujuan, Jenis & Jumlah Kontainer, Tipe Pengiriman, Data Pengirim & Penerima (auto-draft Master Droppoint) → Selanjutnya.
2. Step 2: klik "Pilih Barang" → modal: cari by kode/nama, multi-select checkbox, lihat counter → Simpan. Field SKU/Nama/Kemasan/Kubikasi/Dimensi/Berat ter-draft read-only → isi Jumlah per baris → (opsional) centang "Tambahkan Asuransi" per armada → isi Nilai Barang → (opsional) isi Nomor DO (koma → chip) → Selanjutnya (alert kapasitas bila ada, tidak memblokir).
3. Step 3: pilih Vendor, isi Tanggal Permintaan Muat & Harga → (opsional) "Gunakan Komponen Harga" → Total Harga terhitung (PPN, PPh, + Asuransi bila ada) → Selanjutnya.
4. Step 4: review read-only seluruh data → klik "Visualisasi Muatan" → pop up visualisasi auto stuffing → Simpan → status "Menunggu Penugasan".

**Flow B — Simpan ke Draf:** Pada step manapun, klik Draf → order tersimpan dengan status sesuai step terakhir yang belum selesai (Isi Data Pengiriman / Isi Data Muatan / Isi Data Vendor / Review Order) → dapat dilanjutkan via aksi "Lanjutkan Pengisian" di Daftar Order.

**Flow C — Edit Order:** Daftar Order → order berstatus draft–Menunggu Penugasan → aksi Edit → Jenis & Tipe Pengiriman locked; field lain dapat diubah → Simpan (pop up konfirmasi) / Batal (pop up konfirmasi).

**Flow D — Pembatalan Order:** Daftar Order → order berstatus draft–Ditugaskan → aksi Batalkan Order → isi "Alasan Pembatalan" (wajib) → konfirmasi → status "Dibatalkan" → order muncul di "Riwayat Pembatalan".

**Flow E — Lihat No. Perjalanan:** Order berstatus "Ditugaskan" → aksi "Lihat No. Perjalanan" → pop up "Data No. Perjalanan" (per armada/kontainer: No. Perjalanan, Nopol/No. Kontainer, Jenis Armada/Kontainer) → klik icon copy untuk menyalin → nomor dipakai pengirim/penerima pada public tracking. Alternatif: lihat di halaman Detail Order.

**Flow F — Siklus status penuh:** Isi Data Pengiriman → Isi Data Muatan → Isi Data Vendor → Review Order → (Simpan) Menunggu Penugasan → (penugasan vendor) Ditugaskan → (armada dalam perjalanan) Proses Pengiriman → (seluruh armada selesai bongkar) Selesai. Cabang: Dibatalkan (dari draft s.d. Ditugaskan).

### Acceptance Criteria

- **AC-01** (REQ-009..015) — Diberikan shipper di Step 2, ketika membuka modal "Pilih Barang", mencari barang by kode/nama, memilih beberapa barang via checkbox, lalu Simpan — maka baris barang muncul dengan Kode SKU, Nama Barang, Kemasan, Kubikasi, Dimensi, Berat ter-draft dari Master Barang dan read-only; counter modal mencerminkan jumlah terpilih; barang yang sudah masuk berlabel "Sudah Ditambahkan".
- **AC-02** (REQ-016, REQ-022) — Ketika Jumlah kosong lalu klik "Selanjutnya" — maka tampil helper error dan border error pada field, dan user tidak lanjut ke Step 3.
- **AC-03** (REQ-017, REQ-018) — Ketika "Tambahkan Asuransi" armada dicentang — maka kolom Nilai Barang tampil dan wajib untuk seluruh barang armada tersebut; ketika tidak dicentang — kolom tidak tampil dan tidak divalidasi.
- **AC-04** (REQ-019) — Ketika Nomor DO diisi "DO1,DO2" — maka tampil dua chip; Nomor DO kosong tidak memblokir.
- **AC-05** (REQ-021) — Ketika total kubikasi dan/atau berat melebihi kapasitas kontainer — maka alert informasional dengan teks yang sesuai kondisi tampil, dan "Selanjutnya" tetap dapat diklik.
- **AC-06** (REQ-026) — Ketika minimal satu kontainer diasuransikan — maka Total Harga di Step 3 memuat komponen Asuransi (persentase × Total Nilai Barang) di samping PPN & PPh.
- **AC-07** (REQ-029, REQ-030) — Di Step 4, bagian Data Barang menampilkan struktur Step 2 OMS + label "Diasuransikan" per kontainer yang diasuransikan; klik button visualisasi muatan menampilkan pop up visualisasi.
- **AC-08** (REQ-031, REQ-032) — Ketika Simpan di Step 4 — maka status order menjadi "Menunggu Penugasan".
- **AC-09** (REQ-033) — Ketika "Simpan ke Draf" diklik pada step manapun — maka order tersimpan dengan status draft yang sesuai step (Isi Data Pengiriman / Isi Data Muatan / Isi Data Vendor / Review Order).
- **AC-10** (REQ-034..038) — Order "Menunggu Penugasan" dapat diedit dengan Jenis & Tipe Pengiriman locked; order "Ditugaskan" tidak menampilkan aksi Edit; Simpan/Batal pada Edit menampilkan pop up konfirmasi.
- **AC-11** (REQ-039..041) — Order "Ditugaskan" masih dapat dibatalkan dengan Alasan Pembatalan wajib; order "Proses Pengiriman" tidak menampilkan aksi Batalkan Order.
- **AC-12** (REQ-042, REQ-043) — Action menu per-baris sesuai matriks status; toolbar "Riwayat Pembatalan" menampilkan seluruh order yang pernah dibatalkan.
- **AC-13** (REQ-045..050) — Order "Ditugaskan" menampilkan aksi "Lihat No. Perjalanan"; pop up menampilkan No. Perjalanan per armada/kontainer beserta Nopol/No. Kontainer dan Jenis Armada/Kontainer; icon copy menyalin nomor; jumlah No. Perjalanan = jumlah armada/kontainer; nomor juga tampil di Detail Order.
- **AC-14** (REQ-008) — Form Step 1 OMS tidak menampilkan field Metode Pengiriman.

## UI Inventory

> Sumber: `inputs/oms013-order-fcl-auto-stuffing/designs/058.png`–`095.png` (38 layar, dianalisis via vision 2026-08-24).
> Aplikasi: OMS "Mentari Sumber Kertas", role **Shipper / Staff Operasional** (header menampilkan badge role, notifikasi, profil, logout).
> Elemen global: sidebar (Dashboard, Order, Penugasan Tracking, Simulasi Muatan*, Master Wilayah, Master Operasional, Manajemen Vendor, Pengaturan Akun, Akun Saya, Pengaturan Sistem, Pusat Notifikasi), card "Kuota Order" (progress 120/300 = 40%), breadcrumb `Beranda > Daftar Order > …`. (*Simulasi Muatan hanya terlihat pada layar 062/063.)

### Pemetaan Layar → File Desain

| Halaman | Normal | Multipickup | Multidrop | Multipoint |
|---|---|---|---|---|
| Daftar Order (list) | 058, 069 (filter+aksi), 070 (pop up No. Perjalanan), 071, 079, 087 | 071, 087 | 079, 087 | 087 |
| Buat Order — Step 1 Data Pengiriman | 059 (initial), 060 (lengkap) | 072 | 080 | 088 |
| Buat Order — Step 2 Data Barang | 061 | 073 | 081 | 089 |
| Panel Visualisasi Muatan (auto stuffing) | 062 (Hitung Ulang Kontainer), 063 (Visualisasi Muatan Saat Ini) | — | — | — |
| Buat Order — Step 3 Vendor dan Harga | 064 | 074, 075 (modal Detail Multipickup) | 082, 083 (modal Detail Multidrop) | 090, 091, 092 |
| Buat Order — Step 4 Review | 065 | 076 | 084 | 093 |
| Detail Order | 066 (Menunggu Penugasan), 067 (Ditugaskan) | 077 | 085 | 094 |
| Edit Order | 068 | 078 | 086 | 095 |

### 1. Daftar Order (058, 069, 071, 079, 087)

| Elemen | Tipe | State/Perilaku | Pesan/Teks | SelectorHint |
|---|---|---|---|---|
| Buat Order | Button (primary) | Navigasi ke wizard Buat Order | "+ Buat Order" | role=button name="Buat Order" / testid=btn-buat-order |
| Batch Order | Button | Entry batch order | "Batch Order" | role=button name="Batch Order" |
| Riwayat Pembatalan | Button (toolbar) | Buka daftar order yang pernah dibatalkan | "Riwayat Pembatalan" | role=button name="Riwayat Pembatalan" |
| Filter | Button → panel | Toggle panel filter (069): ID Order, Jenis Order, Vendor, Kota Asal, Kota Tujuan, Total Harga, Tipe Pengiriman, Metode Pengiriman, Drop Point Asal, Drop Point Tujuan, Status + tombol Reset / Terapkan | "Filter" | role=button name="Filter"; panel: testid=filter-panel; role=button name="Terapkan"/"Reset" |
| Tampilkan N data | Select | Page size (default 20) | "Tampilkan 20 data" | role=combobox name="Tampilkan" |
| Tabel order | Table | Kolom: ID Order+badge jenis (FCL/FTL/LTL/LCL), Vendor, Kota Asal/Warehouse Asal, Kota Tujuan/Warehouse Tujuan, Total Harga, Status; sort pada Total Harga | — | role=table; row: testid=order-row-{idOrder} |
| Link Multipickup/Multidrop | Text link dalam kolom kota | Tipe multi: kolom asal/tujuan diganti link (087: Multipoint = link di kedua kolom) | "Multipickup" / "Multidrop" | role=link name="Multipickup"/"Multidrop" |
| Badge status | Badge | Warna per status. Teks pada desain: Isi Data Dasar, Isi Data Muatan, Isi Data Vendor, Review Order, Menunggu Penugasan, Ditugaskan, Proses Pengiriman, Terkirim, Dibatalkan | lihat catatan diskrepansi #13 | testid=badge-status |
| Action menu (⋯) | Icon button → menu | 069 (status Ditugaskan): Detail, Lihat No. Perjalanan, Order Kembali, Batalkan Order, Riwayat Perubahan | — | role=button name="Aksi"; menuitem name="Detail" dst. |
| Pagination | Nav | «, ‹, 1..12, ›, » + "Menampilkan 1 - 20 data dari 30 data" | — | role=navigation |

### 2. Pop up "Data No. Perjalanan" (070)

| Elemen | Tipe | State/Perilaku | Pesan/Teks | SelectorHint |
|---|---|---|---|---|
| Dialog | Modal | Dibuka dari aksi "Lihat No. Perjalanan" (hanya status Ditugaskan) | "Data No. Perjalanan" | role=dialog name="Data No. Perjalanan" |
| Chip ID Order + badge jenis | Chip/Badge | Identitas order | "ID Order: ORD-20260607009" + "FCL" | testid=trip-order-id |
| Baris per kontainer | List item | No. Perjalanan + No. Kontainer + jenis kontainer; jumlah baris = jumlah kontainer | "TRC79289802" / "TVW67892231 • 40 DRY" / "CTN68901072 • 40 DRY" | testid=trip-row-{i} |
| Icon copy | Icon button | Menyalin No. Perjalanan ke clipboard | — | role=button name="Salin No. Perjalanan" / testid=btn-copy-trip-{i} |
| Tutup | Icon button (X) | Menutup pop up | — | role=button name="Close" |

### 3. Buat Order — Step 1: Data Pengiriman (059, 060, 072, 080, 088)

Stepper 4 langkah: 01 Data Pengiriman → 02 Data Barang → 03 Vendor dan Harga → 04 Review (langkah selesai bertanda centang; testid=stepper).

| Elemen | Tipe | State/Perilaku | Pesan/Teks | SelectorHint |
|---|---|---|---|---|
| Jenis Pengiriman | Radio card ×4 | FTL / **FCL** / LTL / LCL; FCL terpilih untuk modul ini | "FCL — Full Container Load" | role=radio name="FCL" |
| Pelabuhan Asal * | Select | Wajib | placeholder/nilai mis. "Tanjung Perak (SUB)" | role=combobox name="Pelabuhan Asal" |
| Pelabuhan Tujuan * | Select | Wajib | "Panjang (PNJ)" | role=combobox name="Pelabuhan Tujuan" |
| Jenis Kontainer * | Select | Wajib | "20 DRY" | role=combobox name="Jenis Kontainer" |
| Jumlah Kontainer * | Input number | Wajib | "2" | role=spinbutton/textbox name="Jumlah Kontainer" |
| Tipe Pengiriman * | Select | Wajib: Normal / Multipickup / Multidrop / Multipoint; menentukan struktur section pengirim/penerima | "Pilih Tipe Pengiriman" (059 initial) | role=combobox name="Tipe Pengiriman" |
| Metode Pengiriman * | Radio card ×4 | Door to Door / Door to CY / CY to CY / CY to Door (dengan deskripsi); **tampil di desain meski spec REQ-008 menyatakan tidak diperlukan — lihat diskrepansi #10** | "Kontainer diambil dari lokasi pengirim…" | role=radio name="Door to Door" dst. |
| Data Pengirim | Section | Normal: 1 blok. Multipickup/Multipoint: blok "Pick Up 1", "Pick Up 2", … + link "Tambah Baris Input" + icon hapus per blok tambahan (088) + info alert | "Pastikan urutan pengiriman sudah sesuai saat membuat shipment" | testid=section-pengirim / pick-up-{i} |
| Drop Point Asal *, Pengirim *, PIC Pengirim *, No. WhatsApp PIC * | Select/Input | Wajib; memilih Drop Point → auto-draft Pengirim, Provinsi, Kota/Kab., Kecamatan, Desa/Kelurahan, Kode Pos, Alamat (read-only, latar abu) | helper "Nama PIC Pengirim", "Contoh: 081234567898" | role=combobox name="Drop Point Asal"; textbox name="PIC Pengirim" |
| Catatan | Textarea | Opsional per blok | "Masukkan Catatan" | textbox name="Catatan" |
| Data Penerima | Section | Normal/Multipickup: 1 blok. Multidrop/Multipoint: blok "Drop Off 1", "Drop Off 2", … + "Tambah Baris Input" + icon hapus + info alert | struktur field = Data Pengirim (Tujuan) | testid=section-penerima / drop-off-{i} |
| Batal | Button (outline merah) | Membatalkan pengisian | "Batal" | role=button name="Batal" |
| Simpan ke Draf | Button (outline) | Menyimpan draft (status: Isi Data Pengiriman); tidak tampil pada 059/088 sebelum form aktif | "Simpan ke Draf" | role=button name="Simpan ke Draf" |
| Selanjutnya | Button (primary) | Disabled saat form belum valid (059); lanjut ke Step 2 | "Selanjutnya →" | role=button name="Selanjutnya" |

### 4. Buat Order — Step 2: Data Barang (061, 073, 081, 089)

| Elemen | Tipe | State/Perilaku | Pesan/Teks | SelectorHint |
|---|---|---|---|---|
| Data Unit | Card ringkasan | Jenis Kontainer + Jumlah Kontainer (read-only, dari Step 1) | "20 Feet Dry / 2" | testid=card-data-unit |
| Card Kontainer N | Section per kontainer | Satu card per kontainer ("Kontainer 1", "Kontainer 2", …); tipe multi: di dalamnya terbagi per titik "Pick Up i"/"Drop Off j" (073/081) atau kombinasi "Pick Up i – Drop Off j" (089) dengan header alamat | — | testid=card-kontainer-{n} |
| Tambahkan Asuransi | Checkbox per kontainer | Saat dicentang: kolom "Nilai Barang" tampil & wajib untuk seluruh barang kontainer tsb | "Berlaku untuk seluruh barang pada armada ini" | role=checkbox name="Tambahkan Asuransi" (scoped per card) |
| Nomor DO | Input chips | Opsional; multi-nilai dipisah koma → chip dengan tombol × | "Pisahkan dengan koma untuk menambahkan beberapa nomor"; placeholder "Masukkan Nomor DO" | testid=input-nomor-do-{n}; chip: testid=chip-do |
| Tabel barang | Table | Kolom: Kode SKU/Nama Barang, Kemasan, Kubikasi/Dimensi, Berat (read-only dari Master Barang); Jumlah (input); Nilai Barang (input Rp, hanya saat asuransi); icon hapus per baris | — | testid=table-barang-{n}; row testid=row-barang-{sku} |
| Jumlah | Input number per baris | Wajib; error: helper + border merah | "Jumlah harus diisi" | textbox name="Jumlah" (scoped row) |
| Nilai Barang | Input currency per baris | Wajib bila asuransi aktif; error: helper + border merah | "Nilai Barang harus diisi"; prefix "Rp" | textbox name="Nilai Barang" (scoped row) |
| Pilih Barang | Button (outline, per kontainer/titik) | Membuka modal "Pilih Barang" (desain modal tidak tersedia — lihat asumsi #14) | "+ Pilih Barang" | role=button name="Pilih Barang" |
| Alert kapasitas | Inline alert (merah, non-blocking) | Tampil per kontainer/titik saat total melebihi kapasitas; tidak memblokir Selanjutnya | "Kubikasi melebihi kapasitas armada" / "Berat melebihi kapasitas armada" (desain memakai kata "armada" — diskrepansi #11) | testid=alert-kapasitas-{n} |
| Total Kubikasi / Total Berat | Text summary per kontainer | Format "19,2 / 17,86 m³" dan "19.200 / 24.800 kg" (terpakai / kapasitas) | — | testid=total-kubikasi-{n} / total-berat-{n} |
| Empty state barang | Text | Kontainer tanpa barang | "Belum ada barang. Klik 'Pilih Barang'" | testid=empty-barang |
| Icon mata / reset (kanan atas) | Floating icon buttons | Buka panel visualisasi muatan (lihat §5) / hitung ulang | — | testid=btn-visualisasi / btn-hitung-ulang |
| Batal / Simpan ke Draf / Sebelumnya / Selanjutnya | Buttons | Simpan ke Draf → status "Isi Data Muatan" | — | role=button name masing-masing |

### 5. Panel Visualisasi Muatan / Auto Stuffing (062, 063)

Slide-over panel dari kanan; dua judul: **"Hitung Ulang Kontainer"** (062, mode simulasi ulang) dan **"Visualisasi Muatan Saat Ini"** (063). Subjudul sama: "Simulasi ulang kebutuhan unit dari muatan order ini. Terapkan untuk ubah data order."

| Elemen | Tipe | State/Perilaku | Pesan/Teks | SelectorHint |
|---|---|---|---|---|
| Ringkasan muatan | Text rows | Total Kubikasi, Total Berat, Jenis Pengiriman | "22,8 m³ / 12.140 kg / FCL" | testid=viz-summary |
| Kontainer — Jenis Kontainer * | Input read-only + button "Pilih Jenis Kontainer" (062); baris teks read-only (063) | Ganti jenis kontainer untuk simulasi | "20 Feet Dry" | role=button name="Pilih Jenis Kontainer" |
| Jumlah Kontainer * | Stepper (− / angka / +) (062) | Ubah jumlah unit simulasi | "2" | testid=viz-jumlah-kontainer |
| Info kapasitas | Text | "Berat Maksimal 1 Kontainer: 28.280 kg • Kubikasi Maksimal 1 Kontainer: 38,27 m³" | — | testid=viz-kapasitas |
| Tab Kontainer 1 / Kontainer 2 | Tabs | Pilih unit yang divisualisasikan | — | role=tab name="Kontainer 1" |
| Berat Terpakai / Ruang Terpakai | Progress bars | Persentase per unit | "78%" / "82%" | testid=viz-berat / viz-ruang |
| Canvas 3D muatan | Interactive canvas | Drag putar 360°, scroll zoom, klik 2× reset; overlay info alokasi; overload ditandai outline merah | "1306 koli • 19.995 kg dialokasikan ke unit ini"; "110 koli melebihi kapasitas (outline merah)" (063) | testid=viz-canvas |
| Legend SKU | Legend berwarna | Warna per barang | "Kertas HVS A4 80 gsm" dst. | testid=viz-legend |
| Batal / Terapkan ke Order | Buttons | "Terapkan ke Order" menerapkan hasil simulasi (ubah jenis/jumlah kontainer order) | — | role=button name="Terapkan ke Order" |

### 6. Buat Order — Step 3: Vendor dan Harga (064, 074, 082, 090; modal 075, 083, 091, 092)

| Elemen | Tipe | State/Perilaku | Pesan/Teks | SelectorHint |
|---|---|---|---|---|
| Vendor * | Select | Wajib | "Pilih Vendor" | role=combobox name="Vendor" |
| Tanggal Permintaan Muat * | Datetime input | Wajib; format DD/MM/YYYY hh:mm | placeholder "DD/MM/YYYY hh:mm" | textbox name="Tanggal Permintaan Muat" |
| Ringkasan alamat | Text rows | Drop Point Asal / Drop Point Tujuan / Jenis Kontainer; tipe multi → label "Multipickup"/"Multidrop" + link "Lihat Detail" (090: dua link) | — | role=link name="Lihat Detail" |
| Modal Detail Multipickup / Multidrop | Modal | Daftar "Pick Up i – Kota" / "Drop Off i – Kota" + nama gudang + alamat lengkap; tombol X | "Detail Multipickup" / "Detail Multidrop" | role=dialog name="Detail Multipickup"/"Detail Multidrop" |
| Tabel ringkasan muatan | Table | No, Nama Item (Kontainer i), Total Berat, Total Kubikasi, Total Nilai Barang ("Tanpa Asuransi" bila tidak diasuransikan) | — | testid=table-ringkasan-muatan |
| Harga * | Input currency | Wajib | helper "Mencakup seluruh biaya armada pada order ini" | textbox name="Harga" |
| Simpan data ke master harga | Checkbox | Terlihat pada 075/083/091/092 (di bawah Harga) | "Simpan data ke master harga" | role=checkbox name="Simpan data ke master harga" |
| Gunakan komponen harga | Checkbox | Saat dicentang: input persentase PPN, PPh (dan Asuransi bila ada kontainer diasuransikan — 068/095) + panel Kalkulasi Harga | "Gunakan komponen harga" | role=checkbox name="Gunakan komponen harga" |
| Kalkulasi Harga | Panel | Harga DPP, PPN (1,1%), PPh (2%) minus, Asuransi (0,2%) + catatan "(Total Nilai Barang = RpX)", **Total Harga** | "Total Harga Rp. 29.730.000" | testid=panel-kalkulasi-harga |
| Batal / Sebelumnya / Simpan ke Draf / Selanjutnya | Buttons | Simpan ke Draf → status "Isi Data Vendor" | — | role=button |

### 7. Buat Order — Step 4: Review (065, 076, 084, 093)

| Elemen | Tipe | State/Perilaku | Pesan/Teks | SelectorHint |
|---|---|---|---|---|
| Section accordion | Collapsible sections | Jenis Pengiriman dan Rute; Data Pengirim (per Pick Up utk multi); Data Penerima (per Drop Off); Data Barang; Vendor dan Harga — semua read-only | — | testid=review-section-{nama} |
| Visualisasi Muatan | Button (outline, icon mata) di card Data Barang | Membuka pop up/panel visualisasi muatan (§5) | "Visualisasi Muatan" | role=button name="Visualisasi Muatan" |
| Struktur Data Barang | Table per kontainer (per titik utk multi) | Kode SKU, Nama Barang, Kemasan, Kubikasi/Dimensi, Berat, Jumlah + Nilai Barang (hanya kontainer diasuransikan); Nomor DO ditampilkan sebagai teks | — | testid=review-kontainer-{n} |
| Label Diasuransikan | Chip di judul kontainer | Hanya pada kontainer dengan asuransi | "Diasuransikan" | testid=chip-diasuransikan-{n} |
| Ringkasan Vendor dan Harga | Table + rows | Per kontainer: Total Berat/Kubikasi/Nilai Barang; Vendor; Tanggal Permintaan Muat; kalkulasi (DPP, PPN, PPh, Asuransi, Total Harga) | "Total Harga Rp13.905.500" | testid=review-total-harga |
| Batal / Sebelumnya / Simpan ke Draf / Simpan | Buttons | **Simpan** submit order → status "Menunggu Penugasan"; Simpan ke Draf → status "Review Order" | — | role=button name="Simpan" |

### 8. Detail Order (066, 067, 077, 085, 094)

| Elemen | Tipe | State/Perilaku | Pesan/Teks | SelectorHint |
|---|---|---|---|---|
| Header | Title + back arrow | "Detail Order" + breadcrumb | — | role=heading name="Detail Order" |
| Badge status | Badge (kanan atas card) | "Menunggu Penugasan" (066/077/085/094) / "Ditugaskan" (067) | — | testid=detail-badge-status |
| Batalkan Order | Button (outline merah, header) | Tampil pada Menunggu Penugasan & Ditugaskan | "Batalkan Order" | role=button name="Batalkan Order" |
| Edit Order | Button (outline, header) | Tampil pada Menunggu Penugasan; **desain 067 juga menampilkannya pada Ditugaskan — konflik dengan spec (diskrepansi #12)** | "Edit Order" | role=button name="Edit Order" |
| Visualisasi Muatan | Button (header, icon mata) | Tampil pada 067/077/085/094; tidak ada pada 066 | "Visualisasi Muatan" | role=button name="Visualisasi Muatan" |
| Info rute | Rows | ID Order, Jenis Pengiriman, Tanggal Dibuat, Pelabuhan Asal/Tujuan, Jenis & Jumlah Kontainer, Tipe & Metode Pengiriman; **Waktu Perjalanan hanya muncul saat Ditugaskan (067: "8 Jam")** | — | testid=detail-rute |
| Section data | Accordions | Data Pengirim / Data Penerima / Data Barang / Vendor dan Harga — struktur sama dengan Review | — | testid=detail-section-{nama} |

### 9. Edit Order (068, 078, 086, 095)

| Elemen | Tipe | State/Perilaku | Pesan/Teks | SelectorHint |
|---|---|---|---|---|
| Info read-only | Static rows | ID Order, Tanggal Dibuat, **Jenis Pengiriman** (FCL), **Tipe Pengiriman**, Metode Pengiriman, Waktu Perjalanan — locked sesuai REQ-036 | — | testid=edit-locked-info |
| Pelabuhan Asal */Tujuan * | Select | Editable pada 078/086/095; pada 068 ditampilkan statis (inkonsistensi kecil antar desain — asumsi #16) | — | role=combobox |
| Jenis Kontainer * / Jumlah Kontainer * | Select / input | Editable | — | role=combobox name="Jenis Kontainer" |
| Data Pengirim / Penerima | Form sections | Drop Point (select), PIC, WhatsApp editable; field alamat auto-draft read-only; multi: per Pick Up/Drop Off + Tambah Baris Input | — | testid=edit-section-pengirim |
| Data Barang — Kontainer N | Sections | Sama dengan Step 2 (asuransi, DO chips, tabel barang, Pilih Barang, alert kapasitas) | — | testid=edit-kontainer-{n} |
| Vendor dan Harga | Section | Vendor, Tanggal, tabel ringkasan, Harga, Gunakan komponen harga (+input % PPN/PPh/Asuransi), kalkulasi | — | testid=edit-vendor-harga |
| Batal | Button | Tampil pop up konfirmasi (REQ-038; desain pop up tidak tersedia) | "Batal" | role=button name="Batal" |
| Simpan | Button (primary) | Tampil pop up konfirmasi lalu menyimpan | "Simpan" | role=button name="Simpan" |

### Elemen yang Dirujuk Spec namun Tidak Ada dalam Set Desain

1. **Modal "Pilih Barang"** (REQ-009..014): pencarian, checkbox multi-select, label "Sudah Ditambahkan", counter, Batal/Simpan — tidak ada layarnya; selector disusun hipotetis dari spec.
2. **Pop up konfirmasi Batal/Simpan Edit Order** (REQ-038) dan **dialog Pembatalan Order + field "Alasan Pembatalan"** (REQ-041).
3. **Halaman/pop up "Riwayat Pembatalan"** (REQ-043) dan **"Riwayat Perubahan"**.
4. Layar **Batch Order** (REQ-001) — hanya tombolnya yang terlihat.
5. Tampilan **public tracking** (REQ-044) — di luar cakupan OMS UI.

## Assumptions Log

1. **[Proses]** Tahap spec-analyzer dijalankan langsung di sesi utama (bukan subagent) karena API subagent berulang kali mengembalikan error 529 Overloaded pada 2026-08-24 (6× gagal dalam ~15 menit, baik model opus maupun model sesi). Kualitas dan format output mengikuti kontrak agen spec-analyzer.
2. Detail rule "identik dengan TMS" (cascading Step 1, minimal baris per tipe pengiriman, perilaku button Batal/Draf/Sebelumnya/Selanjutnya, validasi field wajib Step 1 & 3) tidak dirinci ulang dalam spec ini; diasumsikan mengikuti spesifikasi Order FCL TMS sebagai baseline dan diuji sebatas perilaku yang dapat diamati di OMS.
3. Spec Step 2 melompat dari poin 2 ke poin 4 (tidak ada poin 3); diasumsikan murni kesalahan penomoran, tidak ada rule yang hilang.
4. "Armada" pada konteks FCL diasumsikan ekuivalen dengan "kontainer" (asuransi per armada = per kontainer; Nomor DO per armada = per kontainer), konsisten dengan penyebutan "armada/kontainer" pada bagian No. Perjalanan.
5. Persentase asuransi diasumsikan nilai konfigurasi sistem (spec tidak menyebut angka); pengujian memverifikasi formula (persentase × Total Nilai Barang) dan keikutsertaannya dalam Total Harga, bukan angka spesifik.
6. Pembatalan dengan "Alasan Pembatalan" diasumsikan dilakukan melalui pop up/dialog konfirmasi dari aksi "Batalkan Order" di Daftar Order.
7. "Batch order" disebut pada Ketentuan Umum namun tanpa detail alur di spec; diasumsikan di luar cakupan pengujian rinci modul ini kecuali UI Inventory (tahap 2) menemukan layarnya di desain.
8. Alert kapasitas kontainer (REQ-021) diasumsikan dievaluasi per kontainer/armada berdasarkan total kubikasi & berat barang di dalamnya terhadap kapasitas maksimal jenis kontainer terkait.
9. **[Proses]** Tahap design-analyzer juga dijalankan langsung di sesi utama karena error 529 Overloaded pada subagent masih berlanjut; ke-38 PNG dianalisis via vision di sesi utama.
10. **[Diskrepansi desain vs spec]** Field **Metode Pengiriman** (Door to Door/Door to CY/CY to CY/CY to Door) tampil di desain Step 1, Review, Detail, dan Edit (060, 065–068, 072, 076–078, 084–086, 088, 093–095) padahal REQ-008 menyatakan tidak diperlukan di OMS. Diasumsikan desain adalah sumber kebenaran tampilan (field ada di UI); scenario menguji keberadaannya sesuai desain dan konflik ini ditandai untuk klarifikasi ke pemilik produk.
11. **[Diskrepansi]** Teks alert kapasitas di desain memakai kata "armada" ("Kubikasi/Berat melebihi kapasitas armada") sedangkan spec menulis "kontainer". Scenario memakai teks desain sebagai expected text, dengan catatan konflik redaksional.
12. **[Diskrepansi]** Desain 067 menampilkan button "Edit Order" pada Detail Order berstatus **Ditugaskan**, padahal REQ-035/REQ-042 menyatakan Edit tidak tersedia setelah Ditugaskan. Scenario mengikuti **spec** (Edit tidak tersedia/ditolak pada Ditugaskan); diskrepansi dicatat untuk klarifikasi.
13. **[Diskrepansi]** Badge status pada desain Daftar Order memakai "Isi Data Dasar" (spec: "Isi Data Pengiriman") dan "Terkirim" (spec: "Selesai"). Scenario memakai istilah spec sebagai kanonik dan mencantumkan alias desain pada selectorHints.
14. Modal "Pilih Barang" tidak ada dalam set desain; elemen & selector modal (pencarian, checkbox, label "Sudah Ditambahkan", counter, Batal/Simpan) disusun hipotetis murni dari spec REQ-010..014.
15. Aksi "Order Kembali" muncul pada action menu desain 069 namun tidak disebut spec; dianggap di luar cakupan modul ini (tidak dibuatkan scenario fungsional, hanya verifikasi keberadaan menu).
16. Desain 061 menampilkan card "Kontainer 3" padahal Data Unit menyatakan Jumlah Kontainer = 2; juga 068 menampilkan Pelabuhan Asal/Tujuan statis sementara 078/086/095 editable. Keduanya dianggap inkonsistensi desain; aturan yang dipakai: jumlah card kontainer = nilai Jumlah Kontainer, dan Pelabuhan Asal/Tujuan editable di Edit Order (mayoritas desain).
17. Checkbox "Simpan data ke master harga" dan section "Kalkulasi Harga" terlihat pada sebagian desain Step 3 (075/083/091/092); diasumsikan fitur bawaan TMS yang ikut berlaku, diuji sebatas keberadaan dan efek non-blocking.
18. Panel visualisasi muatan tersedia dalam dua mode: "Hitung Ulang Kontainer" (062, bisa ubah jenis/jumlah kontainer + "Terapkan ke Order") dan "Visualisasi Muatan Saat Ini" (063), dapat diakses dari Step 2 (icon mata), Step 4 (button di card Data Barang), dan header Detail Order — melampaui REQ-030 yang hanya menyebut pop up di Review. Scenario mencakup akses dari Review (per spec) dan titik akses tambahan (per desain).
19. Overload muatan pada canvas visualisasi ditandai teks "N koli melebihi kapasitas (outline merah)" (063); diasumsikan indikator informasional konsisten dengan sifat non-blocking REQ-021.
20. Spec tidak menyebut eksplisit apakah kontainer tanpa barang boleh lanjut dari Step 2; diasumsikan setiap kontainer wajib memuat minimal 1 barang (empty state "Belum ada barang" memblokir Selanjutnya). Diuji pada OMS013-NEG-011.
21. Verifikasi REQ-040 (pembatalan bukan oleh vendor) membutuhkan akses aplikasi vendor di luar OMS shipper; scenario OMS013-NEG-014 ditandai sebagai uji lintas aplikasi/role yang mungkin memerlukan lingkungan tambahan.
22. **[Proses]** Tahap scenario-generator juga dijalankan langsung di sesi utama (error 529 subagent berlanjut). Hasil: 75 scenario (35 positive, 15 negative, 16 edge, 9 stress) pada file .feature + .scenarios.json.
