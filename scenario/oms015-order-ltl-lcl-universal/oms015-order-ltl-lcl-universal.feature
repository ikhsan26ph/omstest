# ============================================================================
# Feature: OMS-015 — Order LTL & LCL (Universal)
# Tahap pipeline: 3/4 — scenario-generator
# Sumber: output/oms015-order-ltl-lcl-universal/oms015-order-ltl-lcl-universal.analysis.md
#         (Requirements REQ-001..REQ-058, UI Inventory UI-096..UI-105 + UI-D01..UI-D08,
#          Assumptions Log ASM-001..ASM-040)
#
# Konvensi tag:
#   @positive|@negative|@edge|@stress   — kategori
#   @priority-high|medium|low           — prioritas
#   @REQ-xxx                            — requirement yang diuji
#   @UI-xxx                             — layar rujukan pada UI Inventory
#   @screen-<nama>                      — nama layar versi manusia
#
# Kepatuhan Assumptions Log yang WAJIB dijaga:
#   ASM-001/007/033 — elemen FTL-only (alert kapasitas, ringkasan terpakai/kapasitas,
#                     floating button, Armada n, Simulasi Muatan) TIDAK PERNAH menjadi
#                     ekspektasi positif; hanya menjadi assertion negatif atau diabaikan.
#   ASM-002         — asuransi per-barang (checkbox per baris) + kontrol Asuransikan Semua.
#   ASM-004         — Jumlah Armada / Jumlah Kontainer: assert "tidak dapat diubah",
#                     bukan "tidak ada".
#   ASM-013         — matcher status toleran: Isi Data Pengiriman|Isi Data Dasar,
#                     Selesai|Terkirim.
#   ASM-017/018     — label kanonik "Lihat No. Resi", tersedia sejak Menunggu Penugasan.
#   ASM-038         — error inline muncul on-submit/on-blur: klik Selanjutnya / blur dulu,
#                     baru assert helper error.
#   ASM-040         — jangan menyalin nominal dummy desain; ekspektasi dihitung dari
#                     data input skenario.
# ============================================================================

Feature: OMS-015 Order LTL & LCL — pembuatan, pengeditan, dan pembatalan order

  Sebagai Staff Operasional / Admin Shipper pada Order Management System
  Saya ingin membuat, mengedit, dan membatalkan order LTL & LCL berbasis Master Barang
  Agar proses pengiriman less-than-load dapat dikelola dan dilacak melalui No. Resi

  # ==========================================================================
  # BAGIAN 1 — SKENARIO POSITIF (POS-001 .. POS-114)
  # ==========================================================================

  # -------- R1. Ketentuan Umum & Cakupan --------

  @positive @priority-high @REQ-001 @REQ-002 @REQ-037 @UI-097 @UI-098 @UI-099 @UI-100 @screen-buat-order-step1-ltl
  Scenario: OMS015-POS-001 Buat order LTL lengkap 4 step hingga tersimpan
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Buat Order"
    And user memilih kartu jenis order "LTL Less Than Truck Load"
    And user memilih dropdown "Kota Asal" dengan "Kota Surabaya"
    And user memilih dropdown "Kota Tujuan" dengan "Kota Malang"
    And user memilih dropdown "Drop Point Asal" dengan "Gudang MSK Region 2"
    And user memilih dropdown "Pengirim" dengan "PT Mentari Sumber Kertas"
    And user mengisi field "PIC Pengirim" dengan "Budianto Suwarno"
    And user mengisi field "No. WhatsApp PIC Pengirim" dengan "081234567898"
    And user memilih dropdown "Drop Point Tujuan" dengan "Gudang Jaya Retail Malang"
    And user memilih dropdown "Penerima" dengan "PT Retail Jaya Abadi"
    And user mengisi field "PIC Penerima" dengan "Basori"
    And user mengisi field "No. WhatsApp PIC Penerima" dengan "081298765432"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order — Step 2 Data Barang"
    When user mengklik tombol "Pilih Barang"
    And user mencentang checkbox "SKU-PPR-001"
    And user mengklik tombol "Simpan" pada modal "Pilih Barang"
    And user mengisi field "Jumlah" baris "SKU-PPR-001" dengan "200"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order — Step 3 Vendor dan Harga"
    When user memilih dropdown "Vendor" dengan "PT Logistik Transportasi Nusantara"
    And user mengisi field "Tanggal Permintaan Muat" dengan "24/07/2026 14:30"
    And user mengisi field "Waktu Perjalanan" dengan "8"
    And user mengisi field "Harga" dengan "12000000"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order — Step 4 Review"
    When user mengklik tombol "Simpan"
    And user mengklik tombol "Ya, Simpan" pada pop up konfirmasi
    Then sistem menampilkan "Order berhasil disimpan"
    And user diarahkan ke halaman "Daftar Order"
    And sistem menampilkan badge status "Menunggu Penugasan" pada baris order baru
    And sistem menampilkan badge jenis order "LTL" pada baris order baru

  @positive @priority-high @REQ-001 @REQ-007 @REQ-031 @UI-102 @UI-098 @UI-099 @UI-100 @screen-buat-order-step1-lcl
  Scenario: OMS015-POS-002 Buat order LCL lengkap 4 step hingga tersimpan
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Buat Order"
    And user memilih kartu jenis order "LCL Less Than Container Load"
    And user memilih dropdown "Pelabuhan Asal" dengan "Tanjung Perak (SUB)"
    And user memilih dropdown "Pelabuhan Tujuan" dengan "Panjang (PNJ)"
    And user memilih dropdown "Drop Point Asal" dengan "Gudang MSK Region 2"
    And user memilih dropdown "Pengirim" dengan "PT Mentari Sumber Kertas"
    And user mengisi field "PIC Pengirim" dengan "Budianto Suwarno"
    And user mengisi field "No. WhatsApp PIC Pengirim" dengan "081234567898"
    And user memilih dropdown "Drop Point Tujuan" dengan "Gudang Jaya Retail Malang"
    And user memilih dropdown "Penerima" dengan "PT Retail Jaya Abadi"
    And user mengisi field "PIC Penerima" dengan "Basori"
    And user mengisi field "No. WhatsApp PIC Penerima" dengan "081298765432"
    And user mengklik tombol "Selanjutnya"
    And user mengklik tombol "Pilih Barang"
    And user mencentang checkbox "SKU-PPR-002"
    And user mengklik tombol "Simpan" pada modal "Pilih Barang"
    And user mengisi field "Jumlah" baris "SKU-PPR-002" dengan "150"
    And user mengklik tombol "Selanjutnya"
    Then sistem tidak menampilkan field "Waktu Perjalanan"
    When user memilih dropdown "Vendor" dengan "PT Logistik Transportasi Nusantara"
    And user mengisi field "Tanggal Permintaan Muat" dengan "24/07/2026 14:30"
    And user mengisi field "Harga" dengan "9000000"
    And user mengklik tombol "Selanjutnya"
    And user mengklik tombol "Simpan"
    And user mengklik tombol "Ya, Simpan" pada pop up konfirmasi
    Then user diarahkan ke halaman "Daftar Order"
    And sistem menampilkan badge status "Menunggu Penugasan" pada baris order baru
    And sistem menampilkan badge jenis order "LCL" pada baris order baru

  @positive @priority-high @REQ-001 @UI-103 @UI-101 @UI-104 @screen-daftar-order
  Scenario: OMS015-POS-003 Badge jenis order LTL tampil di Daftar Order, Detail Order, dan pop up Data No. Resi
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat order LTL berstatus "Menunggu Penugasan" dengan ID "ORD-LTL-0001"
    And user berada di halaman "Daftar Order"
    Then sistem menampilkan badge jenis order "LTL" pada baris "ORD-LTL-0001"
    When user mengklik tombol "Aksi" pada baris "ORD-LTL-0001"
    And user mengklik menu "Detail"
    Then user diarahkan ke halaman "Detail Order"
    And sistem menampilkan "LTL (Less Than Truck Load)"
    When user kembali ke halaman "Daftar Order"
    And user mengklik tombol "Aksi" pada baris "ORD-LTL-0001"
    And user mengklik menu "Lihat No. Resi"
    Then sistem menampilkan dialog "Data No. Resi"
    And sistem menampilkan badge jenis order "LTL" pada dialog "Data No. Resi"

  @positive @priority-high @REQ-002 @UI-097 @UI-098 @screen-buat-order-step1-ltl
  Scenario: OMS015-POS-004 Stepper 4 langkah bernomor dengan state active, checked, dan untouched
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LTL)"
    Then sistem menampilkan "01 Data Pengiriman"
    And sistem menampilkan "02 Data Barang"
    And sistem menampilkan "03 Vendor dan Harga"
    And sistem menampilkan "04 Review"
    And sistem menampilkan step "Data Pengiriman" dalam state "active"
    And sistem menampilkan step "Data Barang" dalam state "untouched"
    When user melengkapi seluruh field wajib Step 1
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan step "Data Pengiriman" dalam state "checked"
    And sistem menampilkan step "Data Barang" dalam state "active"

  @positive @priority-high @REQ-002 @UI-099 @UI-098 @screen-buat-order-step3
  Scenario: OMS015-POS-005 Navigasi Selanjutnya dan Sebelumnya mempertahankan data tiap step
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 3 Vendor dan Harga" dengan Step 1 dan Step 2 sudah terisi
    When user mengisi field "Harga" dengan "12000000"
    And user mengklik tombol "Sebelumnya"
    Then user diarahkan ke halaman "Buat Order — Step 2 Data Barang"
    And sistem menampilkan "SKU-PPR-001"
    And sistem menampilkan nilai "200" pada field "Jumlah" baris "SKU-PPR-001"
    When user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order — Step 3 Vendor dan Harga"
    And sistem menampilkan nilai "12.000.000" pada field "Harga"

  @positive @priority-high @REQ-002 @REQ-037 @UI-100 @screen-buat-order-step4
  Scenario: OMS015-POS-006 Aksi utama Step 4 adalah Simpan bukan Selanjutnya
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 4 Review" dengan seluruh step terisi
    Then sistem menampilkan tombol "Simpan"
    And sistem tidak menampilkan tombol "Selanjutnya"
    And sistem menampilkan tombol "Batal"
    And sistem menampilkan tombol "Sebelumnya"
    And sistem menampilkan tombol "Simpan ke Draf"

  @positive @priority-medium @REQ-003 @UI-096 @screen-daftar-order
  Scenario: OMS015-POS-007 Toolbar Daftar Order menyediakan Buat Order dan Batch Order
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Daftar Order"
    Then sistem menampilkan tombol "Buat Order"
    And sistem menampilkan tombol "Batch Order"
    And sistem menampilkan tombol "Riwayat Pembatalan"
    And sistem menampilkan tombol "Filter"

  @positive @priority-medium @REQ-003 @UI-D08 @UI-103 @screen-batch-order
  Scenario: OMS015-POS-008 Order LTL hasil Batch Order tampil dengan badge LTL
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Batch Order"
    And user mengunggah berkas "batch-order-ltl-3-baris.xlsx"
    And user mengklik tombol "Proses"
    Then sistem menampilkan "3 order berhasil dibuat"
    And user diarahkan ke halaman "Daftar Order"
    And sistem menampilkan badge jenis order "LTL" pada 3 baris order hasil batch

  @positive @priority-medium @REQ-003 @REQ-010 @REQ-024 @REQ-055 @UI-D08 @screen-batch-order
  Scenario: OMS015-POS-009 Order hasil batch mengikuti rule 1 unit muatan, tipe Normal, dan No. Resi
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat order LTL hasil Batch Order berstatus "Menunggu Penugasan"
    When user membuka halaman "Detail Order" untuk order tersebut
    Then sistem menampilkan "Tipe Pengiriman : Normal"
    And sistem menampilkan jumlah unit muatan "1"
    And sistem menampilkan section "No. Resi"
    And sistem menampilkan tabel Data Barang dalam satu grup tunggal

  @positive @priority-high @REQ-004 @REQ-013 @UI-098 @UI-D01 @screen-buat-order-step2
  Scenario: OMS015-POS-010 Satu-satunya jalur penambahan barang adalah tombol Pilih Barang
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang"
    Then sistem menampilkan tombol "Pilih Barang"
    When user mengklik tombol "Pilih Barang"
    Then sistem menampilkan dialog "Pilih Barang"
    And sistem menampilkan input pencarian pada dialog "Pilih Barang"

  @positive @priority-high @REQ-005 @REQ-035 @UI-100 @screen-buat-order-step4
  Scenario: OMS015-POS-011 Section Data Barang Step 4 menampilkan kolom versi Step 2 OMS
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 4 Review" dengan 2 baris barang
    Then sistem menampilkan kolom "Kode SKU"
    And sistem menampilkan kolom "Nama Barang"
    And sistem menampilkan kolom "Kemasan"
    And sistem menampilkan kolom "Kubikasi"
    And sistem menampilkan kolom "Dimensi"
    And sistem menampilkan kolom "Berat"
    And sistem menampilkan kolom "Jumlah"
    And sistem menampilkan kolom "Nilai Barang"

  # -------- R2. Step 1 — Data Pengiriman --------

  @positive @priority-high @REQ-006 @UI-097 @screen-buat-order-step1-ltl
  Scenario: OMS015-POS-012 Step 1 menampilkan tiga section berurutan
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LTL)"
    Then sistem menampilkan "Jenis Pengiriman dan Rute"
    And sistem menampilkan "Data Pengirim"
    And sistem menampilkan "Data Penerima"
    And sistem menampilkan urutan section "Jenis Pengiriman dan Rute, Data Pengirim, Data Penerima"

  @positive @priority-high @REQ-007 @UI-102 @screen-buat-order-step1-lcl
  Scenario: OMS015-POS-013 LCL menampilkan Pelabuhan Asal dan Pelabuhan Tujuan dari Master Pelabuhan
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LCL)"
    Then sistem menampilkan field "Pelabuhan Asal"
    And sistem menampilkan field "Pelabuhan Tujuan"
    When user mengklik dropdown "Pelabuhan Asal"
    Then sistem menampilkan opsi "Tanjung Perak (SUB)"
    When user memilih dropdown "Pelabuhan Asal" dengan "Tanjung Perak (SUB)"
    And user memilih dropdown "Pelabuhan Tujuan" dengan "Panjang (PNJ)"
    Then sistem menampilkan nilai "Tanjung Perak (SUB)" pada field "Pelabuhan Asal"
    And sistem menampilkan nilai "Panjang (PNJ)" pada field "Pelabuhan Tujuan"

  @positive @priority-high @REQ-007 @REQ-024 @UI-102 @screen-buat-order-step1-lcl
  Scenario: OMS015-POS-014 Order LCL tersimpan tanpa user menyentuh Jumlah Kontainer
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LCL)"
    Then sistem menampilkan field "Jumlah Kontainer" dalam kondisi tidak dapat diubah bernilai "1"
    When user melengkapi seluruh field wajib Step 1 tanpa menyentuh field "Jumlah Kontainer"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order — Step 2 Data Barang"

  @positive @priority-high @REQ-008 @UI-097 @screen-buat-order-step1-ltl
  Scenario: OMS015-POS-015 LTL menampilkan Kota Asal dan Kota Tujuan dari Master Kota
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LTL)"
    Then sistem menampilkan field "Kota Asal" dengan placeholder "Pilih Kota Asal"
    And sistem menampilkan field "Kota Tujuan" dengan placeholder "Pilih Kota Tujuan"
    And sistem menampilkan field "Jumlah Armada" dalam kondisi tidak dapat diubah bernilai "1"
    When user mengklik dropdown "Kota Asal"
    Then sistem menampilkan opsi yang seluruhnya berasal dari "Master Kota"

  @positive @priority-high @REQ-009 @UI-097 @screen-buat-order-step1-ltl
  Scenario: OMS015-POS-016 Mengubah Kota Asal tidak memfilter Drop Point Asal
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LTL)"
    When user mengklik dropdown "Drop Point Asal"
    And user mencatat jumlah opsi "Drop Point Asal"
    And user memilih dropdown "Kota Asal" dengan "Kota Surabaya"
    And user mengklik dropdown "Drop Point Asal"
    Then sistem menampilkan jumlah opsi "Drop Point Asal" yang sama seperti sebelumnya
    And sistem menampilkan opsi "Gudang Jaya Retail Malang"

  @positive @priority-high @REQ-009 @UI-097 @screen-buat-order-step1-ltl
  Scenario: OMS015-POS-017 Mengubah Kota Tujuan tidak memfilter Drop Point Tujuan
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LTL)"
    When user memilih dropdown "Drop Point Tujuan" dengan "Gudang Jaya Retail Malang"
    And user memilih dropdown "Kota Tujuan" dengan "Kota Padangsidempuan"
    Then sistem menampilkan nilai "Gudang Jaya Retail Malang" pada field "Drop Point Tujuan"
    When user mengklik dropdown "Drop Point Tujuan"
    Then sistem menampilkan seluruh opsi Master Droppoint tanpa filter kota

  @positive @priority-high @REQ-009 @UI-102 @screen-buat-order-step1-lcl
  Scenario: OMS015-POS-018 Pilihan Pelabuhan LCL tidak dibatasi kota drop point
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LCL)"
    When user memilih dropdown "Drop Point Asal" dengan "Gudang MSK Region 2"
    And user mengklik dropdown "Pelabuhan Asal"
    Then sistem menampilkan seluruh opsi Master Pelabuhan tanpa filter kota
    When user memilih dropdown "Pelabuhan Asal" dengan "Panjang (PNJ)"
    Then sistem menampilkan nilai "Panjang (PNJ)" pada field "Pelabuhan Asal"

  @positive @priority-high @REQ-010 @UI-097 @screen-buat-order-step1-ltl
  Scenario: OMS015-POS-019 Tepat satu blok Data Pengirim dan satu blok Data Penerima
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LTL)"
    Then sistem menampilkan tepat 1 blok alamat pada section "Data Pengirim"
    And sistem menampilkan tepat 1 blok alamat pada section "Data Penerima"
    And sistem tidak menampilkan tombol "Tambah Baris Input"

  @positive @priority-high @REQ-010 @UI-100 @screen-buat-order-step4
  Scenario: OMS015-POS-020 Step 4 menampilkan Tipe Pengiriman Normal
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 4 Review" untuk order LTL
    Then sistem menampilkan "Tipe Pengiriman : Normal"

  @positive @priority-high @REQ-011 @UI-097 @screen-buat-order-step1-ltl
  Scenario: OMS015-POS-021 Drop Point Asal mengisi otomatis wilayah dan Alamat Asal
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LTL)"
    When user memilih dropdown "Drop Point Asal" dengan "Gudang MSK Region 2"
    Then sistem menampilkan nilai terisi pada field "Provinsi Asal"
    And sistem menampilkan nilai terisi pada field "Kota/Kab. Asal"
    And sistem menampilkan nilai terisi pada field "Kecamatan Asal"
    And sistem menampilkan nilai terisi pada field "Desa/Kelurahan Asal"
    And sistem menampilkan nilai terisi pada field "Kode Pos" pada section "Data Pengirim"
    And sistem menampilkan nilai terisi pada field "Alamat Asal"
    And sistem menampilkan field "Provinsi Asal" dalam kondisi tidak dapat diubah

  @positive @priority-high @REQ-011 @UI-097 @screen-buat-order-step1-ltl
  Scenario: OMS015-POS-022 Drop Point Tujuan mengisi otomatis wilayah dan Alamat Tujuan
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LTL)"
    When user memilih dropdown "Drop Point Tujuan" dengan "Gudang Jaya Retail Malang"
    Then sistem menampilkan nilai terisi pada field "Provinsi Tujuan"
    And sistem menampilkan nilai terisi pada field "Kota/Kab. Tujuan"
    And sistem menampilkan nilai terisi pada field "Kecamatan Tujuan"
    And sistem menampilkan nilai terisi pada field "Desa/Kelurahan Tujuan"
    And sistem menampilkan nilai terisi pada field "Alamat Tujuan"
    And sistem menampilkan field "Alamat Tujuan" dalam kondisi tidak dapat diubah

  @positive @priority-high @REQ-011 @UI-097 @screen-buat-order-step1-ltl
  Scenario: OMS015-POS-023 Mengganti drop point memperbarui seluruh field turunan
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LTL)"
    When user memilih dropdown "Drop Point Asal" dengan "Gudang MSK Region 2"
    And user mencatat nilai field "Alamat Asal"
    And user memilih dropdown "Drop Point Asal" dengan "Gudang MSK Region 5"
    Then sistem menampilkan nilai baru pada field "Alamat Asal"
    And sistem menampilkan nilai baru pada field "Kecamatan Asal"
    And sistem menampilkan nilai baru pada field "Kode Pos" pada section "Data Pengirim"

  @positive @priority-high @REQ-012 @UI-097 @screen-buat-order-step1-ltl
  Scenario: OMS015-POS-024 Field wajib Step 1 lengkap membawa user ke Step 2
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LTL)"
    When user melengkapi seluruh field wajib Step 1
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order — Step 2 Data Barang"
    And sistem tidak menampilkan "harus diisi"

  @positive @priority-high @REQ-012 @REQ-039 @UI-D03 @UI-103 @screen-pop-up-konfirmasi
  Scenario: OMS015-POS-025 Simpan ke Draf dari Step 1 menghasilkan status Isi Data Pengiriman
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LTL)"
    When user melengkapi seluruh field wajib Step 1
    And user mengklik tombol "Simpan ke Draf"
    And user mengklik tombol "Ya, Simpan" pada pop up konfirmasi
    Then sistem menampilkan "Draf berhasil disimpan"
    And user diarahkan ke halaman "Daftar Order"
    And sistem menampilkan badge status "Isi Data Pengiriman" pada baris order baru

  @positive @priority-high @REQ-012 @UI-D02 @screen-pop-up-konfirmasi
  Scenario: OMS015-POS-026 Batal pada Step 1 menampilkan konfirmasi lalu keluar tanpa menyimpan
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LTL)"
    When user mengisi field "PIC Pengirim" dengan "Budianto Suwarno"
    And user mengklik tombol "Batal"
    Then sistem menampilkan pop up konfirmasi pembatalan pengisian
    When user mengklik tombol "Ya, Keluar" pada pop up konfirmasi
    Then user diarahkan ke halaman "Daftar Order"
    And sistem tidak menampilkan order baru pada "Daftar Order"

  # -------- R3. Step 2 — Data Barang (pembeda inti) --------

  @positive @priority-high @REQ-013 @UI-D01 @screen-modal-pilih-barang
  Scenario: OMS015-POS-027 Tombol Pilih Barang membuka modal Master Barang
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang"
    When user mengklik tombol "Pilih Barang"
    Then sistem menampilkan dialog "Pilih Barang"
    And sistem menampilkan input pencarian pada dialog "Pilih Barang"
    And sistem menampilkan tombol "Batal" pada dialog "Pilih Barang"
    And sistem menampilkan tombol "Simpan" pada dialog "Pilih Barang"

  @positive @priority-high @REQ-013 @REQ-019 @UI-098 @UI-D01 @screen-buat-order-step2
  Scenario: OMS015-POS-028 Barang terpilih masuk tabel dengan seluruh atribut master
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang"
    And Master Barang memuat "SKU-PPR-001" dengan nama "Kertas HVS A4 80 gsm", kemasan "Dus", kubikasi "0,018 m³", dimensi "31 × 22 × 26,4 cm", berat "12,5 kg"
    When user mengklik tombol "Pilih Barang"
    And user mencentang checkbox "SKU-PPR-001"
    And user mengklik tombol "Simpan" pada modal "Pilih Barang"
    Then sistem menampilkan baris barang "SKU-PPR-001"
    And sistem menampilkan "Kertas HVS A4 80 gsm"
    And sistem menampilkan "Dus"
    And sistem menampilkan "0,018 m³"
    And sistem menampilkan "31 × 22 × 26,4 cm"
    And sistem menampilkan "12,5 kg"

  @positive @priority-high @REQ-014 @UI-D01 @screen-modal-pilih-barang
  Scenario: OMS015-POS-029 Pencarian berdasarkan kode barang memfilter daftar
    Given user login sebagai "Staff Operasional (Shipper)"
    And user membuka dialog "Pilih Barang" dari halaman "Buat Order — Step 2 Data Barang"
    When user mengisi field "Cari Barang" dengan "SKU-PPR"
    Then sistem menampilkan "SKU-PPR-001"
    And sistem menampilkan "SKU-PPR-002"
    And sistem tidak menampilkan "SKU-BKU-001"

  @positive @priority-high @REQ-014 @UI-D01 @screen-modal-pilih-barang
  Scenario: OMS015-POS-030 Pencarian berdasarkan nama barang memfilter daftar
    Given user login sebagai "Staff Operasional (Shipper)"
    And user membuka dialog "Pilih Barang" dari halaman "Buat Order — Step 2 Data Barang"
    When user mengisi field "Cari Barang" dengan "Kertas"
    Then sistem menampilkan "Kertas HVS A4 80 gsm"
    And sistem menampilkan "Kertas HVS F4 70 gsm"
    And sistem tidak menampilkan "Buku Tulis 38 Lembar"

  @positive @priority-medium @REQ-014 @UI-D01 @screen-modal-pilih-barang
  Scenario: OMS015-POS-031 Mengosongkan pencarian mengembalikan daftar penuh
    Given user login sebagai "Staff Operasional (Shipper)"
    And user membuka dialog "Pilih Barang" dari halaman "Buat Order — Step 2 Data Barang"
    When user mengisi field "Cari Barang" dengan "Kertas"
    And user mengosongkan field "Cari Barang"
    Then sistem menampilkan seluruh barang Master Barang
    And sistem menampilkan "Buku Tulis 38 Lembar"

  @positive @priority-high @REQ-015 @UI-D01 @UI-098 @screen-modal-pilih-barang
  Scenario: OMS015-POS-032 Multi-select tiga barang ditambahkan sekaligus
    Given user login sebagai "Staff Operasional (Shipper)"
    And user membuka dialog "Pilih Barang" dari halaman "Buat Order — Step 2 Data Barang"
    When user mencentang checkbox "SKU-PPR-001"
    And user mencentang checkbox "SKU-PPR-002"
    And user mencentang checkbox "SKU-BKU-001"
    Then sistem menampilkan "3 barang terpilih"
    When user mengklik tombol "Simpan" pada modal "Pilih Barang"
    Then sistem menampilkan 3 baris pada tabel "Data Barang"
    And sistem menampilkan baris barang "SKU-PPR-001"
    And sistem menampilkan baris barang "SKU-PPR-002"
    And sistem menampilkan baris barang "SKU-BKU-001"

  @positive @priority-medium @REQ-015 @UI-D01 @screen-modal-pilih-barang
  Scenario: OMS015-POS-033 Membatalkan centang mengembalikan barang ke kondisi tidak terpilih
    Given user login sebagai "Staff Operasional (Shipper)"
    And user membuka dialog "Pilih Barang" dari halaman "Buat Order — Step 2 Data Barang"
    When user mencentang checkbox "SKU-PPR-001"
    And user mencentang checkbox "SKU-PPR-002"
    And user membatalkan centang checkbox "SKU-PPR-002"
    Then sistem menampilkan "1 barang terpilih"
    When user mengklik tombol "Simpan" pada modal "Pilih Barang"
    Then sistem menampilkan 1 baris pada tabel "Data Barang"
    And sistem tidak menampilkan baris barang "SKU-PPR-002"

  @positive @priority-high @REQ-016 @UI-D01 @screen-modal-pilih-barang
  Scenario: OMS015-POS-034 Barang yang sudah masuk berlabel Sudah Ditambahkan
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan barang "SKU-PPR-001" sudah ditambahkan
    When user mengklik tombol "Pilih Barang"
    Then sistem menampilkan "Sudah Ditambahkan" pada baris "SKU-PPR-001"
    And sistem tidak menampilkan "Sudah Ditambahkan" pada baris "SKU-BKU-001"

  @positive @priority-medium @REQ-017 @UI-D01 @screen-modal-pilih-barang
  Scenario: OMS015-POS-035 Counter barang terpilih bertambah dan berkurang seketika
    Given user login sebagai "Staff Operasional (Shipper)"
    And user membuka dialog "Pilih Barang" dari halaman "Buat Order — Step 2 Data Barang"
    When user mencentang checkbox "SKU-PPR-001"
    Then sistem menampilkan "1 barang terpilih"
    When user mencentang checkbox "SKU-PPR-002"
    Then sistem menampilkan "2 barang terpilih"
    When user membatalkan centang checkbox "SKU-PPR-001"
    Then sistem menampilkan "1 barang terpilih"

  @positive @priority-high @REQ-018 @UI-D01 @screen-modal-pilih-barang
  Scenario: OMS015-POS-036 Batal menutup modal tanpa menambahkan barang
    Given user login sebagai "Staff Operasional (Shipper)"
    And user membuka dialog "Pilih Barang" dari halaman "Buat Order — Step 2 Data Barang"
    When user mencentang checkbox "SKU-PPR-001"
    And user mengklik tombol "Batal" pada modal "Pilih Barang"
    Then sistem menutup dialog "Pilih Barang"
    And sistem menampilkan 0 baris pada tabel "Data Barang"

  @positive @priority-high @REQ-018 @UI-D01 @screen-modal-pilih-barang
  Scenario: OMS015-POS-037 Simpan menutup modal dan menambahkan seluruh barang terpilih
    Given user login sebagai "Staff Operasional (Shipper)"
    And user membuka dialog "Pilih Barang" dari halaman "Buat Order — Step 2 Data Barang"
    When user mencentang checkbox "SKU-PPR-001"
    And user mencentang checkbox "SKU-BKU-001"
    And user mengklik tombol "Simpan" pada modal "Pilih Barang"
    Then sistem menutup dialog "Pilih Barang"
    And sistem menampilkan 2 baris pada tabel "Data Barang"

  @positive @priority-high @REQ-019 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-POS-038 Enam field identitas barang ter-draft dari Master Barang
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan barang "SKU-PPR-001" sudah ditambahkan
    Then sistem menampilkan kolom "Kode SKU" sebagai teks read-only
    And sistem menampilkan kolom "Nama Barang" sebagai teks read-only
    And sistem menampilkan kolom "Kemasan" sebagai teks read-only
    And sistem menampilkan kolom "Kubikasi" sebagai teks read-only
    And sistem menampilkan kolom "Dimensi" sebagai teks read-only
    And sistem menampilkan kolom "Berat" sebagai teks read-only

  @positive @priority-high @REQ-020 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-POS-039 Mengisi Jumlah pada setiap baris meloloskan navigasi ke Step 3
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan barang "SKU-PPR-001" dan "SKU-PPR-002" sudah ditambahkan
    When user mengisi field "Jumlah" baris "SKU-PPR-001" dengan "200"
    And user mengisi field "Jumlah" baris "SKU-PPR-002" dengan "350"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order — Step 3 Vendor dan Harga"
    And sistem tidak menampilkan "harus diisi"

  @positive @priority-high @REQ-020 @UI-100 @UI-101 @screen-buat-order-step4
  Scenario: OMS015-POS-040 Nilai Jumlah ter-carry ke Step 3, Step 4, dan Detail Order
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan barang "SKU-PPR-001" sudah ditambahkan
    When user mengisi field "Jumlah" baris "SKU-PPR-001" dengan "137"
    And user mengklik tombol "Selanjutnya"
    And user melengkapi seluruh field wajib Step 3
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan nilai "137" pada kolom "Jumlah" baris "SKU-PPR-001"
    When user mengklik tombol "Simpan"
    And user mengklik tombol "Ya, Simpan" pada pop up konfirmasi
    And user membuka halaman "Detail Order" untuk order tersebut
    Then sistem menampilkan nilai "137" pada kolom "Jumlah" baris "SKU-PPR-001"

  @positive @priority-high @REQ-021 @REQ-022 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-POS-041 Mengaktifkan asuransi baris memunculkan input Nilai Barang
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan barang "SKU-PPR-001" sudah ditambahkan
    Then sistem menampilkan "Tanpa Asuransi" pada baris "SKU-PPR-001"
    When user mencentang checkbox "Asuransi" baris "SKU-PPR-001"
    Then sistem menampilkan input "Nilai Barang" pada baris "SKU-PPR-001"
    And sistem menampilkan prefix "Rp" pada input "Nilai Barang" baris "SKU-PPR-001"

  @positive @priority-high @REQ-021 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-POS-042 Menonaktifkan asuransi mengembalikan teks Tanpa Asuransi
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan barang "SKU-PPR-001" sudah ditambahkan
    When user mencentang checkbox "Asuransi" baris "SKU-PPR-001"
    And user mengisi field "Nilai Barang" baris "SKU-PPR-001" dengan "365000"
    And user membatalkan centang checkbox "Asuransi" baris "SKU-PPR-001"
    Then sistem menampilkan "Tanpa Asuransi" pada baris "SKU-PPR-001"
    And sistem tidak menampilkan input "Nilai Barang" pada baris "SKU-PPR-001"

  @positive @priority-high @REQ-022 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-POS-043 Asuransikan Semua mencentang dan melepas seluruh baris
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan 3 baris barang
    When user mencentang checkbox "Asuransikan Semua"
    Then sistem menampilkan seluruh checkbox "Asuransi" baris dalam kondisi tercentang
    And sistem menampilkan input "Nilai Barang" pada seluruh baris barang
    When user membatalkan centang checkbox "Asuransikan Semua"
    Then sistem menampilkan seluruh checkbox "Asuransi" baris dalam kondisi tidak tercentang
    And sistem menampilkan "Tanpa Asuransi" pada seluruh baris barang

  @positive @priority-high @REQ-022 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-POS-044 Mencentang seluruh baris manual membuat Asuransikan Semua tercentang
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan 3 baris barang
    When user mencentang checkbox "Asuransi" baris "SKU-PPR-001"
    And user mencentang checkbox "Asuransi" baris "SKU-PPR-002"
    And user mencentang checkbox "Asuransi" baris "SKU-BKU-001"
    Then sistem menampilkan checkbox "Asuransikan Semua" dalam kondisi tercentang

  @positive @priority-high @REQ-022 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-POS-045 Asuransi sebagian baris diperbolehkan
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan 3 baris barang
    When user mencentang checkbox "Asuransi" baris "SKU-PPR-001"
    And user mengisi field "Nilai Barang" baris "SKU-PPR-001" dengan "365000"
    And user mengisi field "Jumlah" baris "SKU-PPR-001" dengan "100"
    And user mengisi field "Jumlah" baris "SKU-PPR-002" dengan "100"
    And user mengisi field "Jumlah" baris "SKU-BKU-001" dengan "100"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order — Step 3 Vendor dan Harga"
    And sistem menampilkan "Tanpa Asuransi" pada baris "SKU-PPR-002"

  @positive @priority-high @REQ-022 @REQ-032 @UI-099 @UI-100 @screen-buat-order-step3
  Scenario: OMS015-POS-046 Status asuransi per barang ter-carry ke Step 3 dan Step 4
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan 2 baris barang
    When user mencentang checkbox "Asuransi" baris "SKU-PPR-001"
    And user mengisi field "Nilai Barang" baris "SKU-PPR-001" dengan "500000"
    And user mengisi field "Jumlah" baris "SKU-PPR-001" dengan "100"
    And user mengisi field "Jumlah" baris "SKU-PPR-002" dengan "100"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan baris komponen "Asuransi"
    And sistem menampilkan "(Total Nilai Barang = Rp500.000)"
    When user melengkapi seluruh field wajib Step 3
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan nilai "Rp500.000" pada kolom "Nilai Barang" baris "SKU-PPR-001"
    And sistem menampilkan "Tanpa Asuransi" pada baris "SKU-PPR-002"

  @positive @priority-high @REQ-023 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-POS-047 Nomor DO dipisahkan koma dirender menjadi beberapa chip
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang"
    Then sistem menampilkan "Pisahkan dengan koma untuk menambahkan beberapa nomor"
    When user mengisi field "Nomor DO" dengan "TGK783898202U,TBL28371302"
    Then sistem menampilkan chip "TGK783898202U"
    And sistem menampilkan chip "TBL28371302"
    And sistem menampilkan 2 chip pada field "Nomor DO"

  @positive @priority-high @REQ-023 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-POS-048 Chip Nomor DO dapat dihapus individual
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang"
    When user mengisi field "Nomor DO" dengan "TGK783898202U,TBL28371302,DO-0003"
    And user mengklik tombol hapus pada chip "TBL28371302"
    Then sistem tidak menampilkan chip "TBL28371302"
    And sistem menampilkan chip "TGK783898202U"
    And sistem menampilkan chip "DO-0003"
    And sistem menampilkan 2 chip pada field "Nomor DO"

  @positive @priority-high @REQ-023 @UI-100 @screen-buat-order-step4
  Scenario: OMS015-POS-049 Order tanpa Nomor DO tetap lanjut dan ditampilkan sebagai strip
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan barang "SKU-PPR-001" sudah ditambahkan
    When user mengisi field "Jumlah" baris "SKU-PPR-001" dengan "50"
    And user mengosongkan field "Nomor DO"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order — Step 3 Vendor dan Harga"
    When user melengkapi seluruh field wajib Step 3
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Nomor DO" bernilai "-"

  @positive @priority-high @REQ-024 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-POS-050 Seluruh barang berada dalam satu tabel tunggal
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan 4 baris barang
    Then sistem menampilkan tepat 1 tabel "Data Barang"
    And sistem menampilkan 4 baris pada tabel "Data Barang"
    And sistem tidak menampilkan "Armada 1"
    And sistem tidak menampilkan "Kontainer 1"

  @positive @priority-high @REQ-024 @UI-099 @screen-buat-order-step3
  Scenario: OMS015-POS-051 Rekap muatan Step 3 menampilkan tepat satu baris unit
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 3 Vendor dan Harga" untuk order LTL dengan 3 baris barang
    Then sistem menampilkan tepat 1 baris pada tabel "Rekap Muatan"
    And sistem menampilkan kolom "Total Berat"
    And sistem menampilkan kolom "Total Kubikasi"
    And sistem menampilkan kolom "Total Nilai Barang"

  @positive @priority-high @REQ-024 @REQ-007 @UI-101 @screen-detail-order
  Scenario: OMS015-POS-052 Jumlah kontainer order LCL tercatat 1 pada Detail Order
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat order LCL berstatus "Menunggu Penugasan" dengan ID "ORD-LCL-0001"
    When user membuka halaman "Detail Order" untuk order "ORD-LCL-0001"
    Then sistem menampilkan "Jumlah Kontainer : 1"
    And sistem menampilkan "LCL (Less Than Container Load)"

  @positive @priority-high @REQ-026 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-POS-053 Ikon hapus menghilangkan satu baris tanpa mempengaruhi baris lain
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan 3 baris barang
    When user mengisi field "Jumlah" baris "SKU-PPR-001" dengan "10"
    And user mengisi field "Jumlah" baris "SKU-PPR-002" dengan "20"
    And user mengisi field "Jumlah" baris "SKU-BKU-001" dengan "30"
    And user mengklik tombol "Hapus" baris "SKU-PPR-002"
    Then sistem tidak menampilkan baris barang "SKU-PPR-002"
    And sistem menampilkan 2 baris pada tabel "Data Barang"
    And sistem menampilkan nilai "10" pada field "Jumlah" baris "SKU-PPR-001"
    And sistem menampilkan nilai "30" pada field "Jumlah" baris "SKU-BKU-001"

  @positive @priority-high @REQ-027 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-POS-054 Helper error dan border error hilang setelah field diperbaiki
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan barang "SKU-PPR-001" sudah ditambahkan
    When user mencentang checkbox "Asuransi" baris "SKU-PPR-001"
    And user mengisi field "Jumlah" baris "SKU-PPR-001" dengan "100"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Nilai Barang harus diisi"
    And sistem menampilkan field "Nilai Barang" baris "SKU-PPR-001" dengan border error
    When user mengisi field "Nilai Barang" baris "SKU-PPR-001" dengan "250000"
    Then sistem tidak menampilkan "Nilai Barang harus diisi"
    And sistem menampilkan field "Nilai Barang" baris "SKU-PPR-001" tanpa border error

  @positive @priority-medium @REQ-028 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-POS-055 Step 2 menampilkan tombol Batal Sebelumnya Simpan ke Draf dan Selanjutnya
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang"
    Then sistem menampilkan tombol "Batal"
    And sistem menampilkan tombol "Sebelumnya"
    And sistem menampilkan tombol "Simpan ke Draf"
    And sistem menampilkan tombol "Selanjutnya"

  @positive @priority-medium @REQ-028 @UI-097 @screen-buat-order-step1-ltl
  Scenario: OMS015-POS-056 Sebelumnya dari Step 2 kembali ke Step 1 dengan data utuh
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan Step 1 sudah terisi
    When user mengklik tombol "Sebelumnya"
    Then user diarahkan ke halaman "Buat Order — Step 1 Data Pengiriman (LTL)"
    And sistem menampilkan nilai "Kota Surabaya" pada field "Kota Asal"
    And sistem menampilkan nilai "Budianto Suwarno" pada field "PIC Pengirim"
    And sistem menampilkan nilai "Gudang MSK Region 2" pada field "Drop Point Asal"

  @positive @priority-medium @REQ-028 @REQ-039 @UI-D03 @screen-pop-up-konfirmasi
  Scenario: OMS015-POS-057 Simpan ke Draf dari Step 2 menghasilkan status Isi Data Muatan
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan 1 baris barang dan Jumlah terisi
    When user mengklik tombol "Simpan ke Draf"
    And user mengklik tombol "Ya, Simpan" pada pop up konfirmasi
    Then user diarahkan ke halaman "Daftar Order"
    And sistem menampilkan badge status "Isi Data Muatan" pada baris order baru

  # -------- R4. Step 3 — Vendor & Harga --------

  @positive @priority-high @REQ-029 @UI-099 @screen-buat-order-step3
  Scenario: OMS015-POS-058 Mengisi Vendor Tanggal Permintaan Muat dan Harga meloloskan ke Step 4
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 3 Vendor dan Harga" untuk order LTL
    When user memilih dropdown "Vendor" dengan "PT Logistik Transportasi Nusantara"
    And user mengisi field "Tanggal Permintaan Muat" dengan "24/07/2026 14:30"
    And user mengisi field "Waktu Perjalanan" dengan "8"
    And user mengisi field "Harga" dengan "12000000"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order — Step 4 Review"

  @positive @priority-medium @REQ-029 @UI-099 @screen-buat-order-step3
  Scenario: OMS015-POS-059 Step 3 menampilkan ringkasan read-only Drop Point Asal dan Tujuan
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 3 Vendor dan Harga" dengan Drop Point Asal "Gudang MSK Region 2" dan Drop Point Tujuan "Gudang Jaya Retail Malang"
    Then sistem menampilkan "Gudang MSK Region 2"
    And sistem menampilkan "Gudang Jaya Retail Malang"
    And sistem menampilkan "Drop Point Asal" sebagai teks read-only
    And sistem menampilkan "Drop Point Tujuan" sebagai teks read-only

  @positive @priority-high @REQ-029 @UI-099 @screen-buat-order-step3
  Scenario: OMS015-POS-060 Gunakan komponen harga menampilkan PPN PPh dan rincian dengan PPh sebagai pengurang
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 3 Vendor dan Harga" untuk order LTL tanpa barang diasuransikan
    Then sistem menampilkan checkbox "Gunakan komponen harga" dalam kondisi tidak tercentang
    And sistem tidak menampilkan field "PPN"
    When user mengisi field "Harga" dengan "10000000"
    And user mencentang checkbox "Gunakan komponen harga"
    Then sistem menampilkan field "PPN"
    And sistem menampilkan field "PPh"
    When user mengisi field "PPN" dengan "11"
    And user mengisi field "PPh" dengan "2"
    Then sistem menampilkan "Harga DPP" bernilai "Rp10.000.000"
    And sistem menampilkan "PPN (11%)" bernilai "Rp1.100.000"
    And sistem menampilkan "PPh (2%)" bernilai "- Rp200.000"
    And sistem menampilkan "Total Harga" bernilai "Rp10.900.000"

  @positive @priority-high @REQ-029 @UI-099 @screen-buat-order-step3
  Scenario: OMS015-POS-061 Tanpa komponen harga Total Harga sama dengan Harga
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 3 Vendor dan Harga" untuk order LTL tanpa barang diasuransikan
    When user mengisi field "Harga" dengan "7500000"
    And user tidak mencentang checkbox "Gunakan komponen harga"
    Then sistem menampilkan "Total Harga" bernilai "Rp7.500.000"
    And sistem tidak menampilkan "PPN ("
    And sistem tidak menampilkan "PPh ("

  @positive @priority-high @REQ-030 @UI-099 @screen-buat-order-step3
  Scenario: OMS015-POS-062 LTL rute baru menampilkan Waktu Perjalanan editable beserta info master
    Given user login sebagai "Staff Operasional (Shipper)"
    And rute "Kota Surabaya - Kota Malang" belum terdaftar pada "Master Waktu Perjalanan"
    And user berada di halaman "Buat Order — Step 3 Vendor dan Harga" untuk order LTL
    Then sistem menampilkan field "Waktu Perjalanan" dalam kondisi dapat diubah
    And sistem menampilkan "Jam"
    And sistem menampilkan "Rute belum ada di Master Waktu Perjalanan. Isi waktu perjalanan, nilainya akan otomatis tersimpan sebagai data master baru."
    When user mengisi field "Waktu Perjalanan" dengan "8"
    Then sistem menampilkan nilai "8" pada field "Waktu Perjalanan"

  @positive @priority-high @REQ-030 @UI-099 @screen-buat-order-step3
  Scenario: OMS015-POS-063 LTL rute sudah ada menampilkan Waktu Perjalanan sebagai text-only
    Given user login sebagai "Staff Operasional (Shipper)"
    And rute "Kota Surabaya - Kota Malang" sudah terdaftar pada "Master Waktu Perjalanan" dengan nilai "6"
    And user berada di halaman "Buat Order — Step 3 Vendor dan Harga" untuk order LTL
    Then sistem menampilkan "Waktu Perjalanan" bernilai "6 Jam" sebagai teks read-only
    And sistem tidak menampilkan "Rute belum ada di Master Waktu Perjalanan"

  @positive @priority-high @REQ-030 @UI-100 @UI-101 @screen-buat-order-step4
  Scenario: OMS015-POS-064 Waktu Perjalanan ter-carry ke Step 4 dan Detail Order
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 3 Vendor dan Harga" untuk order LTL
    When user mengisi field "Waktu Perjalanan" dengan "14"
    And user melengkapi seluruh field wajib Step 3
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Waktu Perjalanan : 14 Jam"
    When user mengklik tombol "Simpan"
    And user mengklik tombol "Ya, Simpan" pada pop up konfirmasi
    And user membuka halaman "Detail Order" untuk order tersebut
    Then sistem menampilkan "Waktu Perjalanan : 14 Jam"

  @positive @priority-high @REQ-031 @UI-099 @screen-buat-order-step3
  Scenario: OMS015-POS-065 Order LCL lanjut ke Step 4 tanpa mengisi Waktu Perjalanan
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 3 Vendor dan Harga" untuk order LCL
    Then sistem tidak menampilkan field "Waktu Perjalanan"
    When user memilih dropdown "Vendor" dengan "PT Logistik Transportasi Nusantara"
    And user mengisi field "Tanggal Permintaan Muat" dengan "24/07/2026 14:30"
    And user mengisi field "Harga" dengan "9000000"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order — Step 4 Review"

  @positive @priority-high @REQ-031 @UI-101 @screen-detail-order
  Scenario: OMS015-POS-066 Waktu Perjalanan LCL tampil saat status Ditugaskan sebesar ETA dikurangi ETD ditambah 4 hari
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat order LCL dengan ETD "01/08/2026" dan ETA "06/08/2026"
    And order tersebut berstatus "Ditugaskan"
    When user membuka halaman "Detail Order" untuk order tersebut
    Then sistem menampilkan "Waktu Perjalanan"
    And sistem menampilkan "Waktu Perjalanan" bernilai "9 Hari"

  @positive @priority-high @REQ-032 @UI-099 @screen-buat-order-step3
  Scenario: OMS015-POS-067 Baris Asuransi muncul saat ada barang diasuransikan
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan 2 baris barang
    When user mencentang checkbox "Asuransi" baris "SKU-PPR-001"
    And user mengisi field "Nilai Barang" baris "SKU-PPR-001" dengan "1000000"
    And user mengisi field "Jumlah" baris "SKU-PPR-001" dengan "10"
    And user mengisi field "Jumlah" baris "SKU-PPR-002" dengan "10"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Asuransi ("
    And sistem menampilkan "(Total Nilai Barang = Rp1.000.000)"

  @positive @priority-high @REQ-032 @UI-099 @screen-buat-order-step3
  Scenario: OMS015-POS-068 Total Harga sama dengan DPP ditambah PPN dikurangi PPh ditambah Asuransi
    Given user login sebagai "Staff Operasional (Shipper)"
    And persentase asuransi sistem bernilai "1%"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan 2 baris barang
    When user mencentang checkbox "Asuransi" baris "SKU-PPR-001"
    And user mengisi field "Nilai Barang" baris "SKU-PPR-001" dengan "20000000"
    And user mengisi field "Jumlah" baris "SKU-PPR-001" dengan "10"
    And user mengisi field "Jumlah" baris "SKU-PPR-002" dengan "10"
    And user mengklik tombol "Selanjutnya"
    And user mengisi field "Harga" dengan "10000000"
    And user mencentang checkbox "Gunakan komponen harga"
    And user mengisi field "PPN" dengan "11"
    And user mengisi field "PPh" dengan "2"
    Then sistem menampilkan "Asuransi (1%)" bernilai "Rp200.000"
    And sistem menampilkan "Total Harga" bernilai "Rp11.100.000"

  @positive @priority-high @REQ-032 @UI-099 @screen-buat-order-step3
  Scenario: OMS015-POS-069 Mengubah Nilai Barang di Step 2 memperbarui Asuransi dan Total Harga
    Given user login sebagai "Staff Operasional (Shipper)"
    And persentase asuransi sistem bernilai "1%"
    And user berada di halaman "Buat Order — Step 3 Vendor dan Harga" dengan barang "SKU-PPR-001" diasuransikan senilai "10000000" dan Harga "10000000"
    Then sistem menampilkan "Asuransi (1%)" bernilai "Rp100.000"
    When user mengklik tombol "Sebelumnya"
    And user mengisi field "Nilai Barang" baris "SKU-PPR-001" dengan "30000000"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Asuransi (1%)" bernilai "Rp300.000"
    And sistem menampilkan "(Total Nilai Barang = Rp30.000.000)"
    And sistem menampilkan "Total Harga" bernilai "Rp10.300.000"

  @positive @priority-medium @REQ-033 @REQ-039 @UI-D03 @screen-pop-up-konfirmasi
  Scenario: OMS015-POS-070 Simpan ke Draf dari Step 3 menghasilkan status Isi Data Vendor
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 3 Vendor dan Harga" dengan seluruh field wajib terisi
    When user mengklik tombol "Simpan ke Draf"
    And user mengklik tombol "Ya, Simpan" pada pop up konfirmasi
    Then user diarahkan ke halaman "Daftar Order"
    And sistem menampilkan badge status "Isi Data Vendor" pada baris order baru

  @positive @priority-medium @REQ-033 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-POS-071 Sebelumnya dari Step 3 kembali ke Step 2 dengan data barang utuh
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 3 Vendor dan Harga" dengan Step 2 memuat 3 baris barang
    When user mengklik tombol "Sebelumnya"
    Then user diarahkan ke halaman "Buat Order — Step 2 Data Barang"
    And sistem menampilkan 3 baris pada tabel "Data Barang"
    And sistem menampilkan chip "TGK783898202U"
    And sistem menampilkan checkbox "Asuransi" baris "SKU-PPR-001" dalam kondisi tercentang

  # -------- R5. Step 4 — Review --------

  @positive @priority-high @REQ-034 @UI-100 @screen-buat-order-step4
  Scenario: OMS015-POS-072 Step 4 menampilkan lima section read-only dengan nilai identik input
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 4 Review" dengan seluruh step terisi
    Then sistem menampilkan "Jenis Pengiriman dan Rute"
    And sistem menampilkan "Data Pengirim"
    And sistem menampilkan "Data Penerima"
    And sistem menampilkan "Data Barang"
    And sistem menampilkan "Vendor dan Harga"
    And sistem menampilkan nilai "Budianto Suwarno" pada "PIC Pengirim"
    And sistem menampilkan nilai "Basori" pada "PIC Penerima"
    And sistem menampilkan nilai "PT Logistik Transportasi Nusantara" pada "Vendor"

  @positive @priority-medium @REQ-034 @UI-100 @screen-buat-order-step4
  Scenario: OMS015-POS-073 Setiap section Step 4 dapat di-collapse dan expand
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 4 Review" dengan seluruh step terisi
    When user mengklik chevron pada section "Data Pengirim"
    Then sistem menyembunyikan isi section "Data Pengirim"
    When user mengklik chevron pada section "Data Pengirim"
    Then sistem menampilkan isi section "Data Pengirim"

  @positive @priority-medium @REQ-034 @UI-100 @screen-buat-order-step4
  Scenario: OMS015-POS-074 Field opsional kosong ditampilkan sebagai strip
    Given user login sebagai "Staff Operasional (Shipper)"
    And user membuat order LTL tanpa mengisi "Catatan" penerima dan tanpa "Nomor DO"
    And user berada di halaman "Buat Order — Step 4 Review"
    Then sistem menampilkan "Catatan : -"
    And sistem menampilkan "Nomor DO" bernilai "-"

  @positive @priority-high @REQ-035 @UI-100 @screen-buat-order-step4
  Scenario: OMS015-POS-075 Header dan jumlah baris tabel Data Barang identik dengan Step 2
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan 4 baris barang dan seluruh Jumlah terisi
    When user mengklik tombol "Selanjutnya"
    And user melengkapi seluruh field wajib Step 3
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan 4 baris pada tabel "Data Barang"
    And sistem menampilkan kolom "Kode SKU"
    And sistem menampilkan kolom "Kemasan"
    And sistem menampilkan kolom "Berat"
    And sistem menampilkan kolom "Jumlah"
    And sistem menampilkan kolom "Nilai Barang"

  @positive @priority-medium @REQ-035 @UI-100 @screen-buat-order-step4
  Scenario: OMS015-POS-076 Nomor DO ditampilkan sebagai chip di atas tabel Review
    Given user login sebagai "Staff Operasional (Shipper)"
    And user membuat order LTL dengan Nomor DO "DO-100,DO-200"
    And user berada di halaman "Buat Order — Step 4 Review"
    Then sistem menampilkan chip "DO-100"
    And sistem menampilkan chip "DO-200"
    And sistem menampilkan chip "Nomor DO" di atas tabel "Data Barang"

  @positive @priority-medium @REQ-036 @UI-100 @screen-buat-order-step4
  Scenario: OMS015-POS-077 Penanda asuransi menampilkan nominal untuk baris berasuransi dan Tanpa Asuransi untuk lainnya
    Given user login sebagai "Staff Operasional (Shipper)"
    And user membuat order LTL dengan barang "SKU-PPR-001" diasuransikan senilai "365000" dan barang "SKU-PPR-002" tanpa asuransi
    And user berada di halaman "Buat Order — Step 4 Review"
    Then sistem menampilkan nilai "Rp365.000" pada kolom "Nilai Barang" baris "SKU-PPR-001"
    And sistem menampilkan "Tanpa Asuransi" pada baris "SKU-PPR-002"

  @positive @priority-medium @REQ-036 @UI-101 @screen-detail-order
  Scenario: OMS015-POS-078 Penanda asuransi konsisten antara Step 4 dan Detail Order
    Given user login sebagai "Staff Operasional (Shipper)"
    And user membuat order LTL dengan barang "SKU-PPR-001" diasuransikan senilai "365000" dan barang "SKU-PPR-002" tanpa asuransi
    And user telah menyimpan order tersebut
    When user membuka halaman "Detail Order" untuk order tersebut
    Then sistem menampilkan nilai "Rp365.000" pada kolom "Nilai Barang" baris "SKU-PPR-001"
    And sistem menampilkan "Tanpa Asuransi" pada baris "SKU-PPR-002"
    And sistem menampilkan "Asuransi ("

  @positive @priority-high @REQ-037 @UI-100 @UI-096 @screen-buat-order-step4
  Scenario: OMS015-POS-079 Simpan mengubah status menjadi Menunggu Penugasan dan mengarahkan ke Daftar Order
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 4 Review" dengan seluruh step terisi
    When user mengklik tombol "Simpan"
    Then sistem menampilkan pop up konfirmasi penyimpanan order
    When user mengklik tombol "Ya, Simpan" pada pop up konfirmasi
    Then sistem menampilkan "Order berhasil disimpan"
    And user diarahkan ke halaman "Daftar Order"
    And sistem menampilkan badge status "Menunggu Penugasan" pada baris order baru

  @positive @priority-high @REQ-037 @REQ-039 @UI-D03 @screen-pop-up-konfirmasi
  Scenario: OMS015-POS-080 Simpan ke Draf dari Step 4 menghasilkan status Review Order
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 4 Review" dengan seluruh step terisi
    When user mengklik tombol "Simpan ke Draf"
    And user mengklik tombol "Ya, Simpan" pada pop up konfirmasi
    Then user diarahkan ke halaman "Daftar Order"
    And sistem menampilkan badge status "Review Order" pada baris order baru

  @positive @priority-medium @REQ-037 @UI-099 @screen-buat-order-step3
  Scenario: OMS015-POS-081 Sebelumnya dari Step 4 kembali ke Step 3 dengan data utuh
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 4 Review" dengan seluruh step terisi
    When user mengklik tombol "Sebelumnya"
    Then user diarahkan ke halaman "Buat Order — Step 3 Vendor dan Harga"
    And sistem menampilkan nilai "PT Logistik Transportasi Nusantara" pada field "Vendor"
    And sistem menampilkan nilai "24/07/2026 14:30" pada field "Tanggal Permintaan Muat"
    And sistem menampilkan nilai "12.000.000" pada field "Harga"

  # -------- R6. Status Order --------

  @positive @priority-high @REQ-038 @UI-096 @screen-daftar-order
  Scenario: OMS015-POS-082 Kolom Status menampilkan badge berwarna
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Daftar Order"
    Then sistem menampilkan kolom "Status"
    And sistem menampilkan badge status pada setiap baris order
    And sistem menampilkan badge status "Menunggu Penugasan"
    And sistem menampilkan badge status "Ditugaskan"
    And sistem menampilkan badge status "Dibatalkan"

  @positive @priority-high @REQ-038 @UI-103 @screen-daftar-order-filter
  Scenario: OMS015-POS-083 Filter Status memuat kesembilan status
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Filter"
    And user mengklik dropdown "Status"
    Then sistem menampilkan opsi "Isi Data Pengiriman"
    And sistem menampilkan opsi "Isi Data Muatan"
    And sistem menampilkan opsi "Isi Data Vendor"
    And sistem menampilkan opsi "Review Order"
    And sistem menampilkan opsi "Menunggu Penugasan"
    And sistem menampilkan opsi "Ditugaskan"
    And sistem menampilkan opsi "Proses Pengiriman"
    And sistem menampilkan opsi "Selesai"
    And sistem menampilkan opsi "Dibatalkan"

  @positive @priority-medium @REQ-038 @UI-101 @screen-detail-order
  Scenario: OMS015-POS-084 Status konsisten antara Daftar Order dan Detail Order
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat order LTL berstatus "Menunggu Penugasan" dengan ID "ORD-LTL-0001"
    And user berada di halaman "Daftar Order"
    Then sistem menampilkan badge status "Menunggu Penugasan" pada baris "ORD-LTL-0001"
    When user mengklik tombol "Aksi" pada baris "ORD-LTL-0001"
    And user mengklik menu "Detail"
    Then user diarahkan ke halaman "Detail Order"
    And sistem menampilkan badge status "Menunggu Penugasan"

  @positive @priority-high @REQ-039 @UI-103 @screen-daftar-order
  Scenario: OMS015-POS-085 Order draft muncul pada Daftar Order dengan badge sesuai step
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat draft order LTL yang disimpan dari Step 3
    When user berada di halaman "Daftar Order"
    Then sistem menampilkan badge status "Isi Data Vendor" pada draft order tersebut

  @positive @priority-high @REQ-039 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-POS-086 Lanjutkan Pengisian me-restore seluruh data termasuk chip DO dan status asuransi
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat draft order LTL berstatus "Isi Data Muatan" dengan 2 barang, Nomor DO "DO-100,DO-200", dan barang "SKU-PPR-001" diasuransikan senilai "365000"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada baris draft order tersebut
    And user mengklik menu "Lanjutkan Pengisian"
    Then user diarahkan ke halaman "Buat Order — Step 2 Data Barang"
    And sistem menampilkan 2 baris pada tabel "Data Barang"
    And sistem menampilkan chip "DO-100"
    And sistem menampilkan chip "DO-200"
    And sistem menampilkan checkbox "Asuransi" baris "SKU-PPR-001" dalam kondisi tercentang
    And sistem menampilkan nilai "365.000" pada field "Nilai Barang" baris "SKU-PPR-001"

  @positive @priority-low @REQ-039 @UI-D03 @screen-pop-up-konfirmasi
  Scenario: OMS015-POS-087 Simpan ke Draf menampilkan pop up konfirmasi sebelum menyimpan
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan 1 baris barang dan Jumlah terisi
    When user mengklik tombol "Simpan ke Draf"
    Then sistem menampilkan pop up konfirmasi penyimpanan draf
    And sistem menampilkan tombol "Ya, Simpan" pada pop up konfirmasi
    And sistem menampilkan tombol "Batal" pada pop up konfirmasi

  # -------- R7. Hak Edit Order --------

  @positive @priority-high @REQ-040 @UI-101 @UI-103 @screen-detail-order
  Scenario: OMS015-POS-088 Order Menunggu Penugasan menampilkan aksi Edit dan tombol Edit Order
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat order LTL berstatus "Menunggu Penugasan" dengan ID "ORD-LTL-0001"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada baris "ORD-LTL-0001"
    Then sistem menampilkan menu "Edit"
    When user mengklik menu "Detail"
    Then user diarahkan ke halaman "Detail Order"
    And sistem menampilkan tombol "Edit Order"

  @positive @priority-high @REQ-040 @REQ-051 @UI-D06 @UI-D07 @screen-riwayat-perubahan
  Scenario: OMS015-POS-089 Perubahan Edit Order tercermin di Detail Order dan tercatat di Riwayat Perubahan
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat order LTL berstatus "Menunggu Penugasan" dengan ID "ORD-LTL-0001"
    And user berada di halaman "Edit Order" untuk order "ORD-LTL-0001"
    When user mengisi field "PIC Pengirim" dengan "Andika Pratama"
    And user mengklik tombol "Simpan"
    And user mengklik tombol "Ya, Simpan" pada pop up konfirmasi
    Then sistem menampilkan "Perubahan berhasil disimpan"
    When user membuka halaman "Detail Order" untuk order "ORD-LTL-0001"
    Then sistem menampilkan "PIC Pengirim : Andika Pratama"
    When user kembali ke halaman "Daftar Order"
    And user mengklik tombol "Aksi" pada baris "ORD-LTL-0001"
    And user mengklik menu "Riwayat Perubahan"
    Then sistem menampilkan entri perubahan "PIC Pengirim"

  @positive @priority-high @REQ-042 @UI-D07 @screen-edit-order
  Scenario: OMS015-POS-090 Jenis Pengiriman dan Tipe Pengiriman read-only pada Edit Order
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat order LTL berstatus "Menunggu Penugasan" dengan ID "ORD-LTL-0001"
    When user berada di halaman "Edit Order" untuk order "ORD-LTL-0001"
    Then sistem menampilkan "Jenis Pengiriman" dalam kondisi tidak dapat diubah bernilai "LTL (Less Than Truck Load)"
    And sistem menampilkan "Tipe Pengiriman" dalam kondisi tidak dapat diubah bernilai "Normal"

  @positive @priority-high @REQ-043 @UI-D07 @screen-edit-order
  Scenario: OMS015-POS-091 Data Pengirim dan Data Penerima dapat diubah pada Edit Order
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Edit Order" untuk order LTL berstatus "Menunggu Penugasan"
    When user memilih dropdown "Drop Point Asal" dengan "Gudang MSK Region 5"
    And user mengisi field "PIC Pengirim" dengan "Rahmat Hidayat"
    And user mengisi field "No. WhatsApp PIC Pengirim" dengan "081211112222"
    And user mengisi field "Catatan" pada section "Data Pengirim" dengan "Muat pagi hari"
    And user mengklik tombol "Simpan"
    And user mengklik tombol "Ya, Simpan" pada pop up konfirmasi
    Then sistem menampilkan "Perubahan berhasil disimpan"
    And sistem menampilkan "PIC Pengirim : Rahmat Hidayat"

  @positive @priority-high @REQ-043 @UI-D07 @UI-D01 @screen-edit-order
  Scenario: OMS015-POS-092 Data Barang dapat diubah pada Edit Order
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Edit Order" untuk order LTL berstatus "Menunggu Penugasan" dengan 2 baris barang
    When user mengklik tombol "Pilih Barang"
    And user mencentang checkbox "SKU-ATK-001"
    And user mengklik tombol "Simpan" pada modal "Pilih Barang"
    And user mengisi field "Jumlah" baris "SKU-ATK-001" dengan "75"
    And user mengklik tombol "Hapus" baris "SKU-PPR-002"
    And user mengisi field "Nomor DO" dengan "DO-999"
    And user mengklik tombol "Simpan"
    And user mengklik tombol "Ya, Simpan" pada pop up konfirmasi
    Then sistem menampilkan "Perubahan berhasil disimpan"
    And sistem menampilkan baris barang "SKU-ATK-001"
    And sistem tidak menampilkan baris barang "SKU-PPR-002"
    And sistem menampilkan chip "DO-999"

  @positive @priority-high @REQ-043 @UI-D07 @screen-edit-order
  Scenario: OMS015-POS-093 Vendor dan Harga dapat diubah dan memperbarui Total Harga
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Edit Order" untuk order LTL berstatus "Menunggu Penugasan" tanpa barang diasuransikan
    When user memilih dropdown "Vendor" dengan "PT Andalan Kargo"
    And user mengisi field "Harga" dengan "15000000"
    And user mencentang checkbox "Gunakan komponen harga"
    And user mengisi field "PPN" dengan "11"
    And user mengisi field "PPh" dengan "2"
    Then sistem menampilkan "Total Harga" bernilai "Rp16.350.000"
    When user mengklik tombol "Simpan"
    And user mengklik tombol "Ya, Simpan" pada pop up konfirmasi
    Then sistem menampilkan "Perubahan berhasil disimpan"

  @positive @priority-high @REQ-044 @UI-D07 @UI-D03 @screen-edit-order
  Scenario: OMS015-POS-094 Simpan pada Edit Order menampilkan konfirmasi lalu notifikasi sukses
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Edit Order" untuk order LTL berstatus "Menunggu Penugasan"
    Then sistem menampilkan tombol "Batal"
    And sistem menampilkan tombol "Simpan"
    When user mengisi field "PIC Penerima" dengan "Sutrisno"
    And user mengklik tombol "Simpan"
    Then sistem menampilkan pop up konfirmasi penyimpanan perubahan
    When user mengklik tombol "Ya, Simpan" pada pop up konfirmasi
    Then sistem menampilkan "Perubahan berhasil disimpan"

  @positive @priority-high @REQ-044 @UI-D02 @screen-edit-order
  Scenario: OMS015-POS-095 Batal pada Edit Order menampilkan konfirmasi lalu keluar tanpa menyimpan
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Edit Order" untuk order LTL berstatus "Menunggu Penugasan"
    When user mengisi field "PIC Penerima" dengan "Nama Baru Yang Tidak Disimpan"
    And user mengklik tombol "Batal"
    Then sistem menampilkan pop up konfirmasi pembatalan pengisian
    When user mengklik tombol "Ya, Keluar" pada pop up konfirmasi
    Then user diarahkan ke halaman "Detail Order"
    And sistem tidak menampilkan "Nama Baru Yang Tidak Disimpan"

  # -------- R8. Pembatalan Order --------

  @positive @priority-high @REQ-045 @REQ-047 @UI-D04 @screen-pop-up-batalkan-order
  Scenario: OMS015-POS-096 Membatalkan order Menunggu Penugasan mengubah status menjadi Dibatalkan
    Given user login sebagai "Admin Shipper"
    And terdapat order LTL berstatus "Menunggu Penugasan" dengan ID "ORD-LTL-0001"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada baris "ORD-LTL-0001"
    And user mengklik menu "Batalkan Order"
    Then sistem menampilkan dialog "Batalkan Order"
    When user mengisi field "Alasan Pembatalan" dengan "Permintaan customer dibatalkan"
    And user mengklik tombol "Konfirmasi"
    Then sistem menampilkan "Order berhasil dibatalkan"
    And sistem menampilkan badge status "Dibatalkan" pada baris "ORD-LTL-0001"

  @positive @priority-high @REQ-045 @UI-D04 @screen-pop-up-batalkan-order
  Scenario: OMS015-POS-097 Membatalkan order draft mengubah status menjadi Dibatalkan
    Given user login sebagai "Admin Shipper"
    And terdapat order LTL berstatus "Isi Data Muatan" dengan ID "ORD-LTL-DRAFT1"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada baris "ORD-LTL-DRAFT1"
    And user mengklik menu "Batalkan Order"
    And user mengisi field "Alasan Pembatalan" dengan "Draft tidak dilanjutkan"
    And user mengklik tombol "Konfirmasi"
    Then sistem menampilkan badge status "Dibatalkan" pada baris "ORD-LTL-DRAFT1"

  @positive @priority-high @REQ-045 @UI-D04 @screen-pop-up-batalkan-order
  Scenario: OMS015-POS-098 Membatalkan order Ditugaskan mengubah status menjadi Dibatalkan
    Given user login sebagai "Admin Shipper"
    And terdapat order LCL berstatus "Ditugaskan" dengan ID "ORD-LCL-0002"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada baris "ORD-LCL-0002"
    And user mengklik menu "Batalkan Order"
    And user mengisi field "Alasan Pembatalan" dengan "Vendor tidak sanggup memenuhi jadwal"
    And user mengklik tombol "Konfirmasi"
    Then sistem menampilkan badge status "Dibatalkan" pada baris "ORD-LCL-0002"

  @positive @priority-high @REQ-046 @UI-103 @screen-daftar-order
  Scenario: OMS015-POS-099 Admin shipper memiliki aksi Batalkan Order
    Given user login sebagai "Admin Shipper"
    And terdapat order LTL berstatus "Menunggu Penugasan" dengan ID "ORD-LTL-0001"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada baris "ORD-LTL-0001"
    Then sistem menampilkan menu "Batalkan Order"

  @positive @priority-high @REQ-047 @REQ-050 @UI-D05 @screen-riwayat-pembatalan
  Scenario: OMS015-POS-100 Alasan Pembatalan tersimpan dan terlihat pada Riwayat Pembatalan
    Given user login sebagai "Admin Shipper"
    And terdapat order LTL berstatus "Menunggu Penugasan" dengan ID "ORD-LTL-0001"
    When user membatalkan order "ORD-LTL-0001" dengan alasan "Stok barang belum siap"
    And user mengklik tombol "Riwayat Pembatalan"
    Then sistem menampilkan "ORD-LTL-0001"
    And sistem menampilkan "Stok barang belum siap"

  # -------- R9. Aksi pada Daftar Order --------

  @positive @priority-high @REQ-048 @UI-103 @screen-daftar-order
  Scenario: OMS015-POS-101 Menu aksi order draft sesuai matriks
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat order LTL berstatus "Isi Data Vendor" dengan ID "ORD-LTL-DRAFT3"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada baris "ORD-LTL-DRAFT3"
    Then sistem menampilkan menu "Detail"
    And sistem menampilkan menu "Lanjutkan Pengisian"
    And sistem menampilkan menu "Batalkan Order"
    And sistem menampilkan menu "Riwayat Perubahan"
    And sistem tidak menampilkan menu "Edit"
    And sistem tidak menampilkan menu "Lihat No. Resi"

  @positive @priority-high @REQ-048 @REQ-055 @UI-103 @screen-daftar-order
  Scenario: OMS015-POS-102 Menu aksi order Menunggu Penugasan sesuai matriks
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat order LTL berstatus "Menunggu Penugasan" dengan ID "ORD-LTL-0001"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada baris "ORD-LTL-0001"
    Then sistem menampilkan menu "Detail"
    And sistem menampilkan menu "Edit"
    And sistem menampilkan menu "Batalkan Order"
    And sistem menampilkan menu "Riwayat Perubahan"
    And sistem menampilkan menu "Lihat No. Resi"
    And sistem tidak menampilkan menu "Lanjutkan Pengisian"

  @positive @priority-high @REQ-048 @REQ-049 @UI-103 @screen-daftar-order
  Scenario: OMS015-POS-103 Menu aksi order Ditugaskan sesuai matriks
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat order LTL berstatus "Ditugaskan" dengan ID "ORD-LTL-0005"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada baris "ORD-LTL-0005"
    Then sistem menampilkan menu "Detail"
    And sistem menampilkan menu "Batalkan Order"
    And sistem menampilkan menu "Riwayat Perubahan"
    And sistem menampilkan menu "Lihat No. Resi"
    And sistem tidak menampilkan menu "Edit"

  @positive @priority-high @REQ-048 @UI-103 @screen-daftar-order
  Scenario: OMS015-POS-104 Lanjutkan Pengisian membuka wizard pada step sesuai status draft
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat order LTL berstatus "Isi Data Vendor" dengan ID "ORD-LTL-DRAFT3"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada baris "ORD-LTL-DRAFT3"
    And user mengklik menu "Lanjutkan Pengisian"
    Then user diarahkan ke halaman "Buat Order — Step 3 Vendor dan Harga"
    And sistem menampilkan step "Vendor dan Harga" dalam state "active"

  @positive @priority-medium @REQ-050 @UI-D05 @screen-riwayat-pembatalan
  Scenario: OMS015-POS-105 Riwayat Pembatalan menampilkan seluruh order yang pernah dibatalkan
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat 3 order berstatus "Dibatalkan"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Riwayat Pembatalan"
    Then sistem menampilkan "Riwayat Pembatalan"
    And sistem menampilkan 3 baris pada daftar "Riwayat Pembatalan"
    And sistem menampilkan kolom "Alasan Pembatalan"

  @positive @priority-medium @REQ-051 @UI-D06 @screen-riwayat-perubahan
  Scenario: OMS015-POS-106 Riwayat Perubahan menampilkan histori order yang dipilih saja
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat order LTL "ORD-LTL-0001" dengan 2 entri perubahan dan order LTL "ORD-LTL-0002" dengan 5 entri perubahan
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada baris "ORD-LTL-0001"
    And user mengklik menu "Riwayat Perubahan"
    Then sistem menampilkan "Riwayat Perubahan"
    And sistem menampilkan 2 baris pada daftar "Riwayat Perubahan"
    And sistem menampilkan "ORD-LTL-0001"
    And sistem tidak menampilkan "ORD-LTL-0002"

  # -------- R10. No. Resi --------

  @positive @priority-high @REQ-052 @UI-D08 @screen-public-tracking
  Scenario: OMS015-POS-107 Public tracking dengan No. Resi valid menampilkan progress pengiriman
    Given terdapat order LTL berstatus "Proses Pengiriman" dengan No. Resi "LKL7920830903"
    And user berada di halaman "Public Tracking"
    When user mengisi field "No. Resi" dengan "LKL7920830903"
    And user mengklik tombol "Lacak"
    Then sistem menampilkan progress pengiriman untuk resi "LKL7920830903"
    And sistem menampilkan "Kertas HVS A4 80 gsm"

  @positive @priority-high @REQ-053 @UI-104 @screen-pop-up-data-no-resi
  Scenario: OMS015-POS-108 Setiap baris pop up memasangkan satu No. Resi dengan satu barang
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat order LTL berstatus "Menunggu Penugasan" dengan 4 barang
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada baris order tersebut
    And user mengklik menu "Lihat No. Resi"
    Then sistem menampilkan dialog "Data No. Resi"
    And sistem menampilkan 4 baris pada tabel "Data No. Resi"
    And setiap baris menampilkan "No. Resi", "Kode SKU", dan "Nama Barang" yang terisi

  @positive @priority-high @REQ-054 @UI-105 @screen-pop-up-data-no-resi
  Scenario: OMS015-POS-109 Aksi Lihat No. Resi tersedia pada order LCL dengan badge LCL
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat order LCL berstatus "Menunggu Penugasan" dengan ID "ORD-LCL-0001"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada baris "ORD-LCL-0001"
    Then sistem menampilkan menu "Lihat No. Resi"
    When user mengklik menu "Lihat No. Resi"
    Then sistem menampilkan dialog "Data No. Resi"
    And sistem menampilkan badge jenis order "LCL" pada dialog "Data No. Resi"

  @positive @priority-high @REQ-055 @UI-103 @screen-daftar-order
  Scenario: OMS015-POS-110 Lihat No. Resi langsung tersedia setelah Simpan Step 4
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 4 Review" dengan seluruh step terisi untuk order LTL
    When user mengklik tombol "Simpan"
    And user mengklik tombol "Ya, Simpan" pada pop up konfirmasi
    Then user diarahkan ke halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada baris order baru
    Then sistem menampilkan menu "Lihat No. Resi"

  @positive @priority-high @REQ-055 @UI-103 @screen-daftar-order
  Scenario: OMS015-POS-111 Lihat No. Resi tetap tersedia pada status Ditugaskan dan sesudahnya
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat order LTL berstatus "Ditugaskan" dengan ID "ORD-LTL-0005"
    And terdapat order LTL berstatus "Proses Pengiriman" dengan ID "ORD-LTL-0006"
    And terdapat order LTL berstatus "Selesai" dengan ID "ORD-LTL-0007"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada baris "ORD-LTL-0005"
    Then sistem menampilkan menu "Lihat No. Resi"
    When user mengklik tombol "Aksi" pada baris "ORD-LTL-0006"
    Then sistem menampilkan menu "Lihat No. Resi"
    When user mengklik tombol "Aksi" pada baris "ORD-LTL-0007"
    Then sistem menampilkan menu "Lihat No. Resi"

  @positive @priority-high @REQ-056 @UI-104 @screen-pop-up-data-no-resi
  Scenario: OMS015-POS-112 Dialog Data No. Resi menampilkan judul chip ID Order badge dan kolom tabel
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat order LTL berstatus "Menunggu Penugasan" dengan ID "ORD-20260607009"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada baris "ORD-20260607009"
    And user mengklik menu "Lihat No. Resi"
    Then sistem menampilkan dialog "Data No. Resi"
    And sistem menampilkan "ID Order: ORD-20260607009"
    And sistem menampilkan badge jenis order "LTL" pada dialog "Data No. Resi"
    And sistem menampilkan kolom "No"
    And sistem menampilkan kolom "No. Resi"
    And sistem menampilkan kolom "Kode SKU"
    And sistem menampilkan kolom "Nama Barang"

  @positive @priority-medium @REQ-057 @UI-104 @screen-pop-up-data-no-resi
  Scenario: OMS015-POS-113 Ikon copy menyalin No. Resi baris tersebut ke clipboard
    Given user login sebagai "Staff Operasional (Shipper)"
    And user membuka dialog "Data No. Resi" untuk order LTL berstatus "Menunggu Penugasan"
    And baris pertama menampilkan No. Resi "LKL7920830903"
    When user mengklik tombol "Salin" pada baris 1
    Then isi clipboard sama dengan "LKL7920830903"
    And sistem menampilkan "Tersalin"

  @positive @priority-medium @REQ-058 @UI-101 @screen-detail-order
  Scenario: OMS015-POS-114 No. Resi tampil pada Detail Order LTL dan identik dengan pop up
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat order LTL berstatus "Menunggu Penugasan" dengan ID "ORD-LTL-0001"
    When user membuka halaman "Detail Order" untuk order "ORD-LTL-0001"
    Then sistem menampilkan "No. Resi"
    And sistem menampilkan daftar No. Resi untuk seluruh barang order
    When user kembali ke halaman "Daftar Order"
    And user mengklik tombol "Aksi" pada baris "ORD-LTL-0001"
    And user mengklik menu "Lihat No. Resi"
    Then sistem menampilkan daftar No. Resi yang identik dengan halaman "Detail Order"

  # ==========================================================================
  # BAGIAN 2 — SKENARIO NEGATIF (NEG-001 .. NEG-090)
  # ==========================================================================

  # -------- R1. Ketentuan Umum & Cakupan --------

  @negative @priority-high @REQ-001 @UI-096 @screen-daftar-order
  Scenario: OMS015-NEG-001 Guest mengakses URL Buat Order dialihkan ke halaman Login
    Given user belum terautentikasi
    When user membuka URL "/order/create"
    Then user diarahkan ke halaman "Login"
    And sistem tidak menampilkan "Jenis Pengiriman dan Rute"

  @negative @priority-medium @REQ-002 @UI-097 @screen-buat-order-step1-ltl
  Scenario: OMS015-NEG-002 Melompat ke Step 3 melalui stepper tanpa mengisi Step 1 ditahan
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LTL)" dengan seluruh field kosong
    When user mengklik step "03 Vendor dan Harga" pada stepper
    Then user tetap berada di halaman "Buat Order — Step 1 Data Pengiriman (LTL)"
    And sistem tidak menampilkan "Vendor dan Harga" sebagai step aktif

  @negative @priority-medium @REQ-003 @UI-D08 @screen-batch-order
  Scenario: OMS015-NEG-003 Batch Order dengan format file tidak didukung menampilkan error
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Batch Order"
    And user mengunggah berkas "daftar-order.txt"
    Then sistem menampilkan "Format berkas tidak didukung"
    And sistem tidak membuat order baru

  @negative @priority-high @REQ-004 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-NEG-004 Step 2 tidak menyediakan input teks bebas identitas barang
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan 1 baris barang
    Then sistem tidak menampilkan input teks pada kolom "Kode SKU"
    And sistem tidak menampilkan input teks pada kolom "Nama Barang"
    And sistem tidak menampilkan input teks pada kolom "Kemasan"
    And sistem tidak menampilkan input teks pada kolom "Kubikasi"
    And sistem tidak menampilkan input teks pada kolom "Dimensi"
    And sistem tidak menampilkan input teks pada kolom "Berat"

  @negative @priority-high @REQ-004 @REQ-013 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-NEG-005 Tidak ada tombol tambah barang selain Pilih Barang
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang"
    Then sistem tidak menampilkan tombol "Tambah Baris"
    And sistem tidak menampilkan tombol "Tambah Barang"
    And sistem menampilkan tepat 1 tombol "Pilih Barang"

  @negative @priority-high @REQ-005 @UI-100 @screen-buat-order-step4
  Scenario: OMS015-NEG-006 Step 4 tidak memuat kolom deskripsi barang bebas
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 4 Review" dengan 2 baris barang
    Then sistem tidak menampilkan kolom "Deskripsi Barang"
    And sistem tidak menampilkan kolom "Nama Item"
    And sistem tidak menampilkan input teks pada tabel "Data Barang"

  # -------- R2. Step 1 — Data Pengiriman --------

  @negative @priority-medium @REQ-006 @UI-097 @screen-buat-order-step1-ltl
  Scenario: OMS015-NEG-007 Metode Pengiriman tidak dirender pada Step 1 LTL
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LTL)"
    Then sistem tidak menampilkan field "Metode Pengiriman"

  @negative @priority-high @REQ-007 @UI-102 @screen-buat-order-step1-lcl
  Scenario: OMS015-NEG-008 Kota Asal Kota Tujuan dan Jenis Kontainer tidak dirender saat LCL terpilih
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LCL)"
    Then sistem tidak menampilkan field "Kota Asal"
    And sistem tidak menampilkan field "Kota Tujuan"
    And sistem tidak menampilkan field "Jenis Kontainer"

  @negative @priority-high @REQ-007 @REQ-024 @UI-102 @screen-buat-order-step1-lcl
  Scenario: OMS015-NEG-009 Jumlah Kontainer tidak dapat diubah user
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LCL)"
    When user mencoba mengisi field "Jumlah Kontainer" dengan "5"
    Then sistem menampilkan field "Jumlah Kontainer" dalam kondisi tidak dapat diubah bernilai "1"
    And sistem tidak menampilkan nilai "5" pada field "Jumlah Kontainer"

  @negative @priority-high @REQ-008 @UI-097 @screen-buat-order-step1-ltl
  Scenario: OMS015-NEG-010 Pelabuhan Asal dan Pelabuhan Tujuan tidak dirender saat LTL terpilih
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LTL)"
    Then sistem tidak menampilkan field "Pelabuhan Asal"
    And sistem tidak menampilkan field "Pelabuhan Tujuan"

  @negative @priority-high @REQ-008 @REQ-024 @UI-097 @screen-buat-order-step1-ltl
  Scenario: OMS015-NEG-011 Jumlah Armada tidak dapat diubah user
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LTL)"
    When user mencoba mengisi field "Jumlah Armada" dengan "3"
    Then sistem menampilkan field "Jumlah Armada" dalam kondisi tidak dapat diubah bernilai "1"
    And sistem tidak menampilkan nilai "3" pada field "Jumlah Armada"

  @negative @priority-high @REQ-010 @UI-097 @screen-buat-order-step1-ltl
  Scenario: OMS015-NEG-012 Tombol Tambah Baris Input tidak dirender pada kedua section
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LTL)"
    Then sistem tidak menampilkan tombol "Tambah Baris Input" pada section "Data Pengirim"
    And sistem tidak menampilkan tombol "Tambah Baris Input" pada section "Data Penerima"

  @negative @priority-high @REQ-010 @UI-097 @screen-buat-order-step1-ltl
  Scenario: OMS015-NEG-013 Ikon hapus alamat tidak dirender
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LTL)"
    Then sistem tidak menampilkan tombol "Hapus" pada section "Data Pengirim"
    And sistem tidak menampilkan tombol "Hapus" pada section "Data Penerima"

  @negative @priority-high @REQ-010 @UI-097 @screen-buat-order-step1-ltl
  Scenario: OMS015-NEG-014 Tipe Pengiriman tidak dapat diubah dari Normal
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LTL)"
    Then sistem tidak menampilkan dropdown "Tipe Pengiriman" yang dapat diubah
    When user melengkapi seluruh field wajib Step 1
    And user menyelesaikan wizard hingga halaman "Buat Order — Step 4 Review"
    Then sistem menampilkan "Tipe Pengiriman : Normal"

  @negative @priority-high @REQ-011 @UI-097 @screen-buat-order-step1-ltl
  Scenario: OMS015-NEG-015 Field hasil auto-draft tidak dapat diedit manual
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LTL)"
    When user memilih dropdown "Drop Point Asal" dengan "Gudang MSK Region 2"
    And user mencoba mengisi field "Alamat Asal" dengan "Jl. Palsu No.1"
    Then sistem menampilkan field "Alamat Asal" dalam kondisi tidak dapat diubah
    And sistem tidak menampilkan nilai "Jl. Palsu No.1" pada field "Alamat Asal"

  @negative @priority-high @REQ-012 @UI-097 @screen-buat-order-step1-ltl
  Scenario: OMS015-NEG-016 Selanjutnya dengan seluruh field wajib kosong ditahan
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LTL)" dengan seluruh field kosong
    When user mengklik tombol "Selanjutnya"
    Then user tetap berada di halaman "Buat Order — Step 1 Data Pengiriman (LTL)"
    And sistem menampilkan "Kota Asal harus diisi"
    And sistem menampilkan "Kota Tujuan harus diisi"
    And sistem menampilkan "Drop Point Asal harus diisi"
    And sistem menampilkan "PIC Pengirim harus diisi"
    And sistem menampilkan "PIC Penerima harus diisi"

  @negative @priority-high @REQ-012 @UI-097 @screen-buat-order-step1-ltl
  Scenario: OMS015-NEG-017 Selanjutnya dengan Kota Asal kosong ditahan
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LTL)"
    When user melengkapi seluruh field wajib Step 1 kecuali "Kota Asal"
    And user mengklik tombol "Selanjutnya"
    Then user tetap berada di halaman "Buat Order — Step 1 Data Pengiriman (LTL)"
    And sistem menampilkan "Kota Asal harus diisi"
    And sistem tidak menampilkan "PIC Pengirim harus diisi"

  @negative @priority-medium @REQ-012 @UI-097 @screen-buat-order-step1-ltl
  Scenario: OMS015-NEG-018 No. WhatsApp PIC berisi huruf ditolak
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LTL)"
    When user mengisi field "No. WhatsApp PIC Pengirim" dengan "08ab12cd34"
    And user mengklik tombol "Selanjutnya"
    Then user tetap berada di halaman "Buat Order — Step 1 Data Pengiriman (LTL)"
    And sistem menampilkan pesan validasi pada field "No. WhatsApp PIC Pengirim"

  @negative @priority-high @REQ-012 @REQ-007 @UI-102 @screen-buat-order-step1-lcl
  Scenario: OMS015-NEG-019 Selanjutnya LCL tanpa Pelabuhan Asal ditahan
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LCL)"
    When user melengkapi seluruh field wajib Step 1 kecuali "Pelabuhan Asal"
    And user mengklik tombol "Selanjutnya"
    Then user tetap berada di halaman "Buat Order — Step 1 Data Pengiriman (LCL)"
    And sistem menampilkan "Pelabuhan Asal harus diisi"

  # -------- R3. Step 2 — Data Barang --------

  @negative @priority-high @REQ-013 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-NEG-020 SKU di luar Master Barang tidak dapat masuk tabel
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang"
    When user mencoba menambahkan SKU "SKU-TIDAK-ADA-999" melalui payload langsung
    Then sistem menolak penambahan barang tersebut
    And sistem tidak menampilkan baris barang "SKU-TIDAK-ADA-999"

  @negative @priority-high @REQ-014 @UI-D01 @screen-modal-pilih-barang
  Scenario: OMS015-NEG-021 Pencarian tanpa hasil menampilkan empty state bukan error
    Given user login sebagai "Staff Operasional (Shipper)"
    And user membuka dialog "Pilih Barang" dari halaman "Buat Order — Step 2 Data Barang"
    When user mengisi field "Cari Barang" dengan "ZZZZ-TIDAK-ADA"
    Then sistem menampilkan "Data tidak ditemukan"
    And sistem tidak menampilkan pesan error sistem
    And sistem menampilkan dialog "Pilih Barang" tetap terbuka

  @negative @priority-medium @REQ-015 @UI-D01 @screen-modal-pilih-barang
  Scenario: OMS015-NEG-022 Simpan tanpa mencentang barang tidak menambah baris
    Given user login sebagai "Staff Operasional (Shipper)"
    And user membuka dialog "Pilih Barang" dari halaman "Buat Order — Step 2 Data Barang"
    When user mengklik tombol "Simpan" pada modal "Pilih Barang"
    Then sistem menampilkan 0 baris pada tabel "Data Barang"

  @negative @priority-high @REQ-016 @UI-D01 @screen-modal-pilih-barang
  Scenario: OMS015-NEG-023 Memilih ulang barang berlabel Sudah Ditambahkan tidak membuat baris duplikat
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan barang "SKU-PPR-001" sudah ditambahkan
    When user mengklik tombol "Pilih Barang"
    And user mencentang checkbox "SKU-PPR-001"
    And user mengklik tombol "Simpan" pada modal "Pilih Barang"
    Then sistem menampilkan 1 baris pada tabel "Data Barang"
    And sistem menampilkan tepat 1 baris barang "SKU-PPR-001"

  @negative @priority-high @REQ-018 @UI-D01 @screen-modal-pilih-barang
  Scenario: OMS015-NEG-024 Menutup modal via ikon X berperilaku sama dengan Batal
    Given user login sebagai "Staff Operasional (Shipper)"
    And user membuka dialog "Pilih Barang" dari halaman "Buat Order — Step 2 Data Barang"
    When user mencentang checkbox "SKU-PPR-001"
    And user mengklik tombol "Tutup" pada modal "Pilih Barang"
    Then sistem menutup dialog "Pilih Barang"
    And sistem menampilkan 0 baris pada tabel "Data Barang"

  @negative @priority-high @REQ-019 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-NEG-025 Enam field identitas barang tidak dapat diedit
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan barang "SKU-PPR-001" sudah ditambahkan
    When user mencoba mengklik sel "Kode SKU" baris "SKU-PPR-001"
    Then sistem menampilkan sel "Kode SKU" sebagai teks read-only
    And sistem menampilkan sel "Berat" sebagai teks read-only
    And sistem menampilkan nilai "12,5 kg" pada sel "Berat" baris "SKU-PPR-001"

  @negative @priority-high @REQ-020 @REQ-027 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-NEG-026 Jumlah kosong menahan Selanjutnya dan menampilkan helper error
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan barang "SKU-PPR-001" sudah ditambahkan
    And field "Jumlah" baris "SKU-PPR-001" masih kosong
    When user mengklik tombol "Selanjutnya"
    Then user tetap berada di halaman "Buat Order — Step 2 Data Barang"
    And sistem menampilkan "Jumlah harus diisi"
    And sistem menampilkan field "Jumlah" baris "SKU-PPR-001" dengan border error

  @negative @priority-high @REQ-020 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-NEG-027 Jumlah bernilai 0 menahan navigasi
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan barang "SKU-PPR-001" sudah ditambahkan
    When user mengisi field "Jumlah" baris "SKU-PPR-001" dengan "0"
    And user mengklik tombol "Selanjutnya"
    Then user tetap berada di halaman "Buat Order — Step 2 Data Barang"
    And sistem menampilkan pesan validasi pada field "Jumlah" baris "SKU-PPR-001"

  @negative @priority-medium @REQ-020 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-NEG-028 Jumlah negatif ditolak
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan barang "SKU-PPR-001" sudah ditambahkan
    When user mengisi field "Jumlah" baris "SKU-PPR-001" dengan "-5"
    And user mengklik tombol "Selanjutnya"
    Then user tetap berada di halaman "Buat Order — Step 2 Data Barang"
    And sistem tidak menampilkan nilai "-5" pada field "Jumlah" baris "SKU-PPR-001"

  @negative @priority-high @REQ-021 @REQ-027 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-NEG-029 Nilai Barang kosong saat asuransi aktif menampilkan pesan Nilai Barang harus diisi
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan barang "SKU-PPR-001" sudah ditambahkan
    When user mengisi field "Jumlah" baris "SKU-PPR-001" dengan "200"
    And user mencentang checkbox "Asuransi" baris "SKU-PPR-001"
    And user mengklik tombol "Selanjutnya"
    Then user tetap berada di halaman "Buat Order — Step 2 Data Barang"
    And sistem menampilkan "Nilai Barang harus diisi"
    And sistem menampilkan field "Nilai Barang" baris "SKU-PPR-001" dengan border error

  @negative @priority-high @REQ-021 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-NEG-030 Nilai Barang bernilai 0 saat asuransi aktif menahan navigasi
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan barang "SKU-PPR-001" sudah ditambahkan
    When user mengisi field "Jumlah" baris "SKU-PPR-001" dengan "200"
    And user mencentang checkbox "Asuransi" baris "SKU-PPR-001"
    And user mengisi field "Nilai Barang" baris "SKU-PPR-001" dengan "0"
    And user mengklik tombol "Selanjutnya"
    Then user tetap berada di halaman "Buat Order — Step 2 Data Barang"
    And sistem menampilkan "Nilai Barang harus diisi"

  @negative @priority-medium @REQ-021 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-NEG-031 Nilai Barang negatif ditolak
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan barang "SKU-PPR-001" sudah ditambahkan
    When user mencentang checkbox "Asuransi" baris "SKU-PPR-001"
    And user mengisi field "Nilai Barang" baris "SKU-PPR-001" dengan "-100000"
    And user mengklik tombol "Selanjutnya"
    Then user tetap berada di halaman "Buat Order — Step 2 Data Barang"
    And sistem tidak menampilkan nilai "-100.000" pada field "Nilai Barang" baris "SKU-PPR-001"

  @negative @priority-high @REQ-022 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-NEG-032 Melepas satu baris setelah Asuransikan Semua membuat kontrol tidak tercentang penuh
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan 3 baris barang
    When user mencentang checkbox "Asuransikan Semua"
    And user membatalkan centang checkbox "Asuransi" baris "SKU-PPR-002"
    Then sistem menampilkan "Tanpa Asuransi" pada baris "SKU-PPR-002"
    And sistem menampilkan checkbox "Asuransikan Semua" dalam kondisi tidak tercentang penuh
    And sistem menampilkan checkbox "Asuransi" baris "SKU-PPR-001" dalam kondisi tercentang

  @negative @priority-high @REQ-023 @REQ-024 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-NEG-033 Hanya terdapat satu field Nomor DO untuk keseluruhan order
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan 4 baris barang
    Then sistem menampilkan tepat 1 field "Nomor DO"
    And sistem tidak menampilkan field "Nomor DO" pada baris barang

  @negative @priority-high @REQ-024 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-NEG-034 Step 2 tidak menampilkan card berulang Armada n atau Kontainer n
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan 4 baris barang
    Then sistem tidak menampilkan "Armada 1"
    And sistem tidak menampilkan "Armada 2"
    And sistem tidak menampilkan "Kontainer 1"
    And sistem tidak menampilkan "Kontainer 2"

  @negative @priority-high @REQ-024 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-NEG-035 Step 2 tidak menampilkan sub-section Pick Up n atau Drop Off n
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan 4 baris barang
    Then sistem tidak menampilkan "Pick Up 1"
    And sistem tidak menampilkan "Drop Off 1"

  @negative @priority-high @REQ-025 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-NEG-036 Step 2 tidak menampilkan badge melebihi kapasitas armada
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan 3 baris barang
    When user mengisi field "Jumlah" baris "SKU-PPR-001" dengan "50000"
    And user mengisi field "Jumlah" baris "SKU-PPR-002" dengan "50000"
    And user mengisi field "Jumlah" baris "SKU-BKU-001" dengan "50000"
    Then sistem tidak menampilkan "Kubikasi melebihi kapasitas armada"
    And sistem tidak menampilkan "Berat melebihi kapasitas armada"
    And sistem tidak menampilkan "melebihi kapasitas"

  @negative @priority-high @REQ-025 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-NEG-037 Step 2 tidak menampilkan ringkasan kapasitas berformat terpakai per kapasitas
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan 3 baris barang dan seluruh Jumlah terisi
    Then sistem tidak menampilkan "Total Kubikasi: 19,2 / 17,86 m³"
    And sistem tidak menampilkan ringkasan berformat "Total Kubikasi: <terpakai> / <kapasitas> m³"
    And sistem tidak menampilkan ringkasan berformat "Total Berat: <terpakai> / <kapasitas> kg"

  @negative @priority-high @REQ-025 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-NEG-038 Step 2 tidak menampilkan floating button hitung ulang dan visualisasi muatan
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan 3 baris barang
    Then sistem tidak menampilkan tombol "Hitung Ulang"
    And sistem tidak menampilkan tombol "Visualisasi Muatan"
    And sistem tidak menampilkan elemen hitung-ulang muatan pada halaman

  @negative @priority-high @REQ-026 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-NEG-039 Menghapus seluruh barang menahan Selanjutnya
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan 2 baris barang dan seluruh Jumlah terisi
    When user mengklik tombol "Hapus" baris "SKU-PPR-001"
    And user mengklik tombol "Hapus" baris "SKU-PPR-002"
    Then sistem menampilkan 0 baris pada tabel "Data Barang"
    And sistem menampilkan empty state pada tabel "Data Barang"
    When user mengklik tombol "Selanjutnya"
    Then user tetap berada di halaman "Buat Order — Step 2 Data Barang"
    And sistem menampilkan pesan validasi minimal satu barang

  @negative @priority-high @REQ-027 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-NEG-040 Error hanya muncul pada baris dan kolom yang bermasalah
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan 3 baris barang
    When user mengisi field "Jumlah" baris "SKU-PPR-001" dengan "100"
    And user mengisi field "Jumlah" baris "SKU-PPR-002" dengan "100"
    And user mengosongkan field "Jumlah" baris "SKU-BKU-001"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Jumlah harus diisi" pada baris "SKU-BKU-001"
    And sistem tidak menampilkan "Jumlah harus diisi" pada baris "SKU-PPR-001"
    And sistem tidak menampilkan "Jumlah harus diisi" pada baris "SKU-PPR-002"
    And sistem menampilkan tepat 1 helper error pada tabel "Data Barang"

  @negative @priority-medium @REQ-028 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-NEG-041 Selanjutnya ditahan selama masih ada field wajib Step 2 kosong
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan 2 baris barang
    When user mengisi field "Jumlah" baris "SKU-PPR-001" dengan "100"
    And user mengklik tombol "Selanjutnya"
    Then user tetap berada di halaman "Buat Order — Step 2 Data Barang"
    When user mengisi field "Jumlah" baris "SKU-PPR-002" dengan "100"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order — Step 3 Vendor dan Harga"

  # -------- R4. Step 3 — Vendor & Harga --------

  @negative @priority-high @REQ-029 @REQ-033 @UI-099 @screen-buat-order-step3
  Scenario: OMS015-NEG-042 Vendor kosong menahan navigasi
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 3 Vendor dan Harga" untuk order LTL
    When user mengisi field "Tanggal Permintaan Muat" dengan "24/07/2026 14:30"
    And user mengisi field "Waktu Perjalanan" dengan "8"
    And user mengisi field "Harga" dengan "12000000"
    And user mengklik tombol "Selanjutnya"
    Then user tetap berada di halaman "Buat Order — Step 3 Vendor dan Harga"
    And sistem menampilkan "Vendor harus diisi"

  @negative @priority-high @REQ-029 @REQ-033 @UI-099 @screen-buat-order-step3
  Scenario: OMS015-NEG-043 Tanggal Permintaan Muat kosong menahan navigasi
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 3 Vendor dan Harga" untuk order LTL
    When user memilih dropdown "Vendor" dengan "PT Logistik Transportasi Nusantara"
    And user mengisi field "Waktu Perjalanan" dengan "8"
    And user mengisi field "Harga" dengan "12000000"
    And user mengklik tombol "Selanjutnya"
    Then user tetap berada di halaman "Buat Order — Step 3 Vendor dan Harga"
    And sistem menampilkan "Tanggal Permintaan Muat harus diisi"

  @negative @priority-high @REQ-029 @REQ-033 @UI-099 @screen-buat-order-step3
  Scenario: OMS015-NEG-044 Harga kosong menahan navigasi
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 3 Vendor dan Harga" untuk order LTL
    When user memilih dropdown "Vendor" dengan "PT Logistik Transportasi Nusantara"
    And user mengisi field "Tanggal Permintaan Muat" dengan "24/07/2026 14:30"
    And user mengisi field "Waktu Perjalanan" dengan "8"
    And user mengklik tombol "Selanjutnya"
    Then user tetap berada di halaman "Buat Order — Step 3 Vendor dan Harga"
    And sistem menampilkan "Harga harus diisi"

  @negative @priority-medium @REQ-029 @UI-099 @screen-buat-order-step3
  Scenario: OMS015-NEG-045 Harga bernilai 0 ditolak
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 3 Vendor dan Harga" untuk order LTL
    When user melengkapi seluruh field wajib Step 3
    And user mengisi field "Harga" dengan "0"
    And user mengklik tombol "Selanjutnya"
    Then user tetap berada di halaman "Buat Order — Step 3 Vendor dan Harga"
    And sistem menampilkan pesan validasi pada field "Harga"

  @negative @priority-medium @REQ-029 @UI-099 @screen-buat-order-step3
  Scenario: OMS015-NEG-046 PPN di luar range 0 sampai 100 ditolak
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 3 Vendor dan Harga" untuk order LTL
    When user melengkapi seluruh field wajib Step 3
    And user mencentang checkbox "Gunakan komponen harga"
    And user mengisi field "PPN" dengan "150"
    And user mengklik tombol "Selanjutnya"
    Then user tetap berada di halaman "Buat Order — Step 3 Vendor dan Harga"
    And sistem menampilkan pesan validasi pada field "PPN"

  @negative @priority-medium @REQ-029 @UI-099 @screen-buat-order-step3
  Scenario: OMS015-NEG-047 Tanggal Permintaan Muat di masa lalu ditolak
    Given user login sebagai "Staff Operasional (Shipper)"
    And tanggal sistem saat ini adalah "26/08/2026"
    And user berada di halaman "Buat Order — Step 3 Vendor dan Harga" untuk order LTL
    When user melengkapi seluruh field wajib Step 3
    And user mengisi field "Tanggal Permintaan Muat" dengan "01/01/2026 08:00"
    And user mengklik tombol "Selanjutnya"
    Then user tetap berada di halaman "Buat Order — Step 3 Vendor dan Harga"
    And sistem menampilkan pesan validasi pada field "Tanggal Permintaan Muat"

  @negative @priority-high @REQ-030 @REQ-033 @UI-099 @screen-buat-order-step3
  Scenario: OMS015-NEG-048 Waktu Perjalanan LTL kosong menahan navigasi
    Given user login sebagai "Staff Operasional (Shipper)"
    And rute order belum terdaftar pada "Master Waktu Perjalanan"
    And user berada di halaman "Buat Order — Step 3 Vendor dan Harga" untuk order LTL
    When user memilih dropdown "Vendor" dengan "PT Logistik Transportasi Nusantara"
    And user mengisi field "Tanggal Permintaan Muat" dengan "24/07/2026 14:30"
    And user mengisi field "Harga" dengan "12000000"
    And user mengosongkan field "Waktu Perjalanan"
    And user mengklik tombol "Selanjutnya"
    Then user tetap berada di halaman "Buat Order — Step 3 Vendor dan Harga"
    And sistem menampilkan "Waktu Perjalanan harus diisi"

  @negative @priority-medium @REQ-030 @UI-099 @screen-buat-order-step3
  Scenario: OMS015-NEG-049 Waktu Perjalanan text-only tidak dapat diubah saat rute sudah ada di master
    Given user login sebagai "Staff Operasional (Shipper)"
    And rute "Kota Surabaya - Kota Malang" sudah terdaftar pada "Master Waktu Perjalanan" dengan nilai "6"
    And user berada di halaman "Buat Order — Step 3 Vendor dan Harga" untuk order LTL
    When user mencoba mengisi field "Waktu Perjalanan" dengan "20"
    Then sistem menampilkan "Waktu Perjalanan" bernilai "6 Jam" sebagai teks read-only
    And sistem tidak menampilkan nilai "20" pada "Waktu Perjalanan"

  @negative @priority-high @REQ-031 @UI-099 @screen-buat-order-step3
  Scenario: OMS015-NEG-050 Step 3 LCL tidak merender Waktu Perjalanan maupun info master rute
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 3 Vendor dan Harga" untuk order LCL
    Then sistem tidak menampilkan field "Waktu Perjalanan"
    And sistem tidak menampilkan "Rute belum ada di Master Waktu Perjalanan"
    And sistem tidak menampilkan satuan "Jam" pada section "Vendor dan Harga"

  @negative @priority-high @REQ-031 @UI-101 @screen-detail-order
  Scenario: OMS015-NEG-051 Detail Order LCL berstatus Menunggu Penugasan belum menampilkan Waktu Perjalanan
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat order LCL berstatus "Menunggu Penugasan" dengan ID "ORD-LCL-0001"
    When user membuka halaman "Detail Order" untuk order "ORD-LCL-0001"
    Then sistem tidak menampilkan "Waktu Perjalanan"

  @negative @priority-high @REQ-032 @UI-099 @screen-buat-order-step3
  Scenario: OMS015-NEG-052 Tanpa barang diasuransikan baris Asuransi tidak muncul dan rekap menampilkan Tanpa Asuransi
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan 3 baris barang tanpa asuransi dan seluruh Jumlah terisi
    When user mengklik tombol "Selanjutnya"
    Then sistem tidak menampilkan "Asuransi ("
    And sistem tidak menampilkan "(Total Nilai Barang = Rp"
    And sistem menampilkan "Tanpa Asuransi" pada kolom "Total Nilai Barang"

  @negative @priority-high @REQ-033 @REQ-024 @UI-099 @screen-buat-order-step3
  Scenario: OMS015-NEG-053 Rekap muatan LTL tidak menampilkan baris kedua Armada 2
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 3 Vendor dan Harga" untuk order LTL dengan 5 baris barang
    Then sistem menampilkan tepat 1 baris pada tabel "Rekap Muatan"
    And sistem tidak menampilkan "Armada 2"
    And sistem tidak menampilkan "Kontainer 2"

  # -------- R5. Step 4 — Review --------

  @negative @priority-high @REQ-034 @UI-100 @screen-buat-order-step4
  Scenario: OMS015-NEG-054 Step 4 tidak memuat input dropdown atau checkbox aktif
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 4 Review" dengan seluruh step terisi
    Then sistem tidak menampilkan input teks yang dapat diubah pada section "Data Pengirim"
    And sistem tidak menampilkan dropdown yang dapat diubah pada section "Vendor dan Harga"
    And sistem tidak menampilkan checkbox "Asuransi" yang dapat diubah pada tabel "Data Barang"
    And sistem tidak menampilkan checkbox "Asuransikan Semua"

  @negative @priority-high @REQ-035 @REQ-024 @UI-100 @screen-buat-order-step4
  Scenario: OMS015-NEG-055 Step 4 tidak mengelompokkan barang per armada atau kontainer
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 4 Review" dengan 4 baris barang
    Then sistem menampilkan tepat 1 tabel "Data Barang"
    And sistem tidak menampilkan "Armada 1"
    And sistem tidak menampilkan "Kontainer 1"
    And sistem tidak menampilkan "Pick Up 1"
    And sistem tidak menampilkan "Drop Off 1"

  @negative @priority-high @REQ-037 @UI-D02 @screen-pop-up-konfirmasi
  Scenario: OMS015-NEG-056 Batal pada Step 4 tidak menyimpan order
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 4 Review" dengan seluruh step terisi
    When user mengklik tombol "Batal"
    Then sistem menampilkan pop up konfirmasi pembatalan pengisian
    When user mengklik tombol "Ya, Keluar" pada pop up konfirmasi
    Then user diarahkan ke halaman "Daftar Order"
    And sistem tidak menampilkan order baru pada "Daftar Order"

  @negative @priority-high @REQ-037 @UI-D03 @screen-pop-up-konfirmasi
  Scenario: OMS015-NEG-057 Menolak konfirmasi Simpan menahan order di Step 4
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 4 Review" dengan seluruh step terisi
    When user mengklik tombol "Simpan"
    And user mengklik tombol "Batal" pada pop up konfirmasi
    Then user tetap berada di halaman "Buat Order — Step 4 Review"
    And sistem tidak menampilkan "Order berhasil disimpan"
    And sistem tidak membuat order baru

  # -------- R6. Status Order --------

  @negative @priority-medium @REQ-038 @UI-103 @screen-daftar-order-filter
  Scenario: OMS015-NEG-058 Filter Status tidak memuat status di luar sembilan status
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Filter"
    And user mengklik dropdown "Status"
    Then sistem menampilkan tepat 9 opsi pada dropdown "Status"
    And sistem tidak menampilkan opsi "Menunggu Konfirmasi"
    And sistem tidak menampilkan opsi "Draft"

  @negative @priority-medium @REQ-039 @UI-103 @screen-daftar-order
  Scenario: OMS015-NEG-059 Lanjutkan Pengisian tidak tersedia pada status Menunggu Penugasan
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat order LTL berstatus "Menunggu Penugasan" dengan ID "ORD-LTL-0001"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada baris "ORD-LTL-0001"
    Then sistem tidak menampilkan menu "Lanjutkan Pengisian"

  @negative @priority-medium @REQ-039 @UI-D03 @screen-pop-up-konfirmasi
  Scenario: OMS015-NEG-060 Menolak konfirmasi Simpan ke Draf tidak menyimpan order
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan 1 baris barang dan Jumlah terisi
    When user mengklik tombol "Simpan ke Draf"
    And user mengklik tombol "Batal" pada pop up konfirmasi
    Then user tetap berada di halaman "Buat Order — Step 2 Data Barang"
    And sistem tidak membuat order baru

  # -------- R7. Hak Edit Order --------

  @negative @priority-high @REQ-041 @REQ-049 @UI-103 @screen-daftar-order
  Scenario: OMS015-NEG-061 Aksi Edit tidak tersedia pada order Ditugaskan
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat order LTL berstatus "Ditugaskan" dengan ID "ORD-LTL-0005"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada baris "ORD-LTL-0005"
    Then sistem tidak menampilkan menu "Edit"

  @negative @priority-high @REQ-041 @UI-103 @screen-daftar-order
  Scenario: OMS015-NEG-062 Aksi Edit tidak tersedia pada Proses Pengiriman Selesai dan Dibatalkan
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat order LTL berstatus "Proses Pengiriman" dengan ID "ORD-LTL-0006"
    And terdapat order LTL berstatus "Selesai" dengan ID "ORD-LTL-0007"
    And terdapat order LTL berstatus "Dibatalkan" dengan ID "ORD-LTL-0008"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada baris "ORD-LTL-0006"
    Then sistem tidak menampilkan menu "Edit"
    When user mengklik tombol "Aksi" pada baris "ORD-LTL-0007"
    Then sistem tidak menampilkan menu "Edit"
    When user mengklik tombol "Aksi" pada baris "ORD-LTL-0008"
    Then sistem tidak menampilkan menu "Edit"

  @negative @priority-high @REQ-041 @UI-D07 @screen-edit-order
  Scenario: OMS015-NEG-063 Akses URL Edit Order langsung pada order Ditugaskan ditolak
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat order LTL berstatus "Ditugaskan" dengan ID "ORD-LTL-0005"
    When user membuka URL "/order/ORD-LTL-0005/edit"
    Then sistem menampilkan "Order tidak dapat diubah"
    And user diarahkan ke halaman "Detail Order"
    And sistem tidak menampilkan tombol "Simpan" pada halaman "Edit Order"

  @negative @priority-high @REQ-041 @UI-D07 @screen-edit-order
  Scenario: OMS015-NEG-064 Submit perubahan via API pada order Ditugaskan ditolak
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat order LTL berstatus "Ditugaskan" dengan ID "ORD-LTL-0005"
    When user mengirim permintaan PUT ke "/api/order/ORD-LTL-0005" dengan perubahan "PIC Pengirim"
    Then sistem mengembalikan status kode error otorisasi
    And data order "ORD-LTL-0005" tidak berubah

  @negative @priority-high @REQ-042 @UI-D07 @screen-edit-order
  Scenario: OMS015-NEG-065 Kartu jenis order tidak dapat diklik pada mode Edit Order
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Edit Order" untuk order LTL berstatus "Menunggu Penugasan"
    When user mencoba mengklik kartu jenis order "FTL Full Truck Load"
    Then sistem menampilkan kartu jenis order dalam kondisi tidak dapat diubah
    And sistem menampilkan "Jenis Pengiriman" bernilai "LTL (Less Than Truck Load)"

  @negative @priority-high @REQ-043 @UI-D07 @screen-edit-order
  Scenario: OMS015-NEG-066 Simpan Edit Order ditahan bila field wajib dikosongkan
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Edit Order" untuk order LTL berstatus "Menunggu Penugasan"
    When user mengosongkan field "PIC Pengirim"
    And user mengklik tombol "Simpan"
    Then user tetap berada di halaman "Edit Order"
    And sistem menampilkan "PIC Pengirim harus diisi"
    And sistem tidak menampilkan "Perubahan berhasil disimpan"

  @negative @priority-high @REQ-044 @UI-D03 @screen-edit-order
  Scenario: OMS015-NEG-067 Membatalkan pop up konfirmasi Simpan mempertahankan perubahan di Edit Order
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Edit Order" untuk order LTL berstatus "Menunggu Penugasan"
    When user mengisi field "PIC Penerima" dengan "Sutrisno Baru"
    And user mengklik tombol "Simpan"
    And user mengklik tombol "Batal" pada pop up konfirmasi
    Then user tetap berada di halaman "Edit Order"
    And sistem menampilkan nilai "Sutrisno Baru" pada field "PIC Penerima"
    And sistem tidak menampilkan "Perubahan berhasil disimpan"

  @negative @priority-high @REQ-040 @UI-D07 @screen-edit-order
  Scenario: OMS015-NEG-068 Akun vendor tidak dapat mengakses Edit Order LTL
    Given user login sebagai "Vendor"
    And terdapat order LTL berstatus "Menunggu Penugasan" dengan ID "ORD-LTL-0001"
    When user membuka URL "/order/ORD-LTL-0001/edit"
    Then sistem menolak akses
    And sistem tidak menampilkan halaman "Edit Order"

  # -------- R8. Pembatalan Order --------

  @negative @priority-high @REQ-045 @UI-103 @screen-daftar-order
  Scenario: OMS015-NEG-069 Batalkan Order tidak tersedia pada status Proses Pengiriman
    Given user login sebagai "Admin Shipper"
    And terdapat order LTL berstatus "Proses Pengiriman" dengan ID "ORD-LTL-0006"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada baris "ORD-LTL-0006"
    Then sistem tidak menampilkan menu "Batalkan Order"

  @negative @priority-high @REQ-045 @UI-103 @screen-daftar-order
  Scenario: OMS015-NEG-070 Batalkan Order tidak tersedia pada status Selesai dan Dibatalkan
    Given user login sebagai "Admin Shipper"
    And terdapat order LTL berstatus "Selesai" dengan ID "ORD-LTL-0007"
    And terdapat order LTL berstatus "Dibatalkan" dengan ID "ORD-LTL-0008"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada baris "ORD-LTL-0007"
    Then sistem tidak menampilkan menu "Batalkan Order"
    When user mengklik tombol "Aksi" pada baris "ORD-LTL-0008"
    Then sistem tidak menampilkan menu "Batalkan Order"

  @negative @priority-high @REQ-045 @UI-D04 @screen-pop-up-batalkan-order
  Scenario: OMS015-NEG-071 Pembatalan via akses langsung pada order Proses Pengiriman ditolak
    Given user login sebagai "Admin Shipper"
    And terdapat order LTL berstatus "Proses Pengiriman" dengan ID "ORD-LTL-0006"
    When user mengirim permintaan pembatalan langsung untuk order "ORD-LTL-0006" dengan alasan "Uji akses langsung"
    Then sistem menolak permintaan pembatalan
    And status order "ORD-LTL-0006" tetap "Proses Pengiriman"

  @negative @priority-high @REQ-045 @UI-103 @screen-daftar-order
  Scenario: OMS015-NEG-072 Order Dibatalkan tidak dapat diedit maupun dibatalkan ulang
    Given user login sebagai "Admin Shipper"
    And terdapat order LTL berstatus "Dibatalkan" dengan ID "ORD-LTL-0008"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada baris "ORD-LTL-0008"
    Then sistem tidak menampilkan menu "Edit"
    And sistem tidak menampilkan menu "Batalkan Order"
    And sistem tidak menampilkan menu "Lanjutkan Pengisian"
    And sistem menampilkan menu "Detail"
    And sistem menampilkan menu "Riwayat Perubahan"

  @negative @priority-high @REQ-046 @UI-103 @screen-daftar-order
  Scenario: OMS015-NEG-073 Akun vendor tidak memiliki aksi Batalkan Order
    Given user login sebagai "Vendor"
    And terdapat order LTL berstatus "Menunggu Penugasan" dengan ID "ORD-LTL-0001"
    When user membuka daftar order pada portal vendor
    Then sistem tidak menampilkan menu "Batalkan Order" untuk order "ORD-LTL-0001"

  @negative @priority-high @REQ-047 @UI-D04 @screen-pop-up-batalkan-order
  Scenario: OMS015-NEG-074 Alasan Pembatalan kosong menahan pembatalan
    Given user login sebagai "Admin Shipper"
    And terdapat order LTL berstatus "Menunggu Penugasan" dengan ID "ORD-LTL-0001"
    And user membuka dialog "Batalkan Order" untuk order "ORD-LTL-0001"
    When user mengosongkan field "Alasan Pembatalan"
    And user mengklik tombol "Konfirmasi"
    Then sistem menampilkan "Alasan Pembatalan harus diisi"
    And sistem menampilkan dialog "Batalkan Order" tetap terbuka
    And status order "ORD-LTL-0001" tetap "Menunggu Penugasan"

  @negative @priority-high @REQ-047 @UI-D04 @screen-pop-up-batalkan-order
  Scenario: OMS015-NEG-075 Alasan Pembatalan hanya spasi diperlakukan sebagai kosong
    Given user login sebagai "Admin Shipper"
    And terdapat order LTL berstatus "Menunggu Penugasan" dengan ID "ORD-LTL-0001"
    And user membuka dialog "Batalkan Order" untuk order "ORD-LTL-0001"
    When user mengisi field "Alasan Pembatalan" dengan "     "
    And user mengklik tombol "Konfirmasi"
    Then sistem menampilkan "Alasan Pembatalan harus diisi"
    And status order "ORD-LTL-0001" tetap "Menunggu Penugasan"

  # -------- R9. Aksi pada Daftar Order --------

  @negative @priority-high @REQ-049 @UI-103 @screen-daftar-order
  Scenario: OMS015-NEG-076 Menu aksi baris Ditugaskan tidak memuat item Edit namun tetap memuat aksi lain
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat order LTL berstatus "Ditugaskan" dengan ID "ORD-LTL-0005"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada baris "ORD-LTL-0005"
    Then sistem tidak menampilkan menu "Edit"
    And sistem menampilkan menu "Detail"
    And sistem menampilkan menu "Batalkan Order"
    And sistem menampilkan menu "Riwayat Perubahan"

  @negative @priority-high @REQ-049 @UI-101 @screen-detail-order
  Scenario: OMS015-NEG-077 Detail Order Ditugaskan tidak menampilkan tombol Edit Order
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat order LTL berstatus "Ditugaskan" dengan ID "ORD-LTL-0005"
    When user membuka halaman "Detail Order" untuk order "ORD-LTL-0005"
    Then sistem tidak menampilkan tombol "Edit Order"
    And sistem menampilkan tombol "Batalkan Order"

  @negative @priority-medium @REQ-048 @UI-103 @screen-daftar-order
  Scenario: OMS015-NEG-078 Menu aksi Proses Pengiriman tanpa Edit dan Batalkan Order
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat order LTL berstatus "Proses Pengiriman" dengan ID "ORD-LTL-0006"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada baris "ORD-LTL-0006"
    Then sistem tidak menampilkan menu "Edit"
    And sistem tidak menampilkan menu "Batalkan Order"
    And sistem menampilkan menu "Detail"
    And sistem menampilkan menu "Riwayat Perubahan"
    And sistem menampilkan menu "Lihat No. Resi"

  @negative @priority-medium @REQ-048 @UI-103 @screen-daftar-order
  Scenario: OMS015-NEG-079 Menu aksi Dibatalkan hanya memuat Detail dan Riwayat Perubahan
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat order LTL berstatus "Dibatalkan" dengan ID "ORD-LTL-0008"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada baris "ORD-LTL-0008"
    Then sistem menampilkan menu "Detail"
    And sistem menampilkan menu "Riwayat Perubahan"
    And sistem tidak menampilkan menu "Edit"
    And sistem tidak menampilkan menu "Batalkan Order"
    And sistem tidak menampilkan menu "Lanjutkan Pengisian"

  @negative @priority-medium @REQ-048 @UI-103 @screen-daftar-order
  Scenario: OMS015-NEG-080 Lanjutkan Pengisian tidak muncul pada status non-draft
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat order LTL berstatus "Ditugaskan" dengan ID "ORD-LTL-0005"
    And terdapat order LTL berstatus "Selesai" dengan ID "ORD-LTL-0007"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada baris "ORD-LTL-0005"
    Then sistem tidak menampilkan menu "Lanjutkan Pengisian"
    When user mengklik tombol "Aksi" pada baris "ORD-LTL-0007"
    Then sistem tidak menampilkan menu "Lanjutkan Pengisian"

  @negative @priority-low @REQ-051 @UI-096 @screen-daftar-order
  Scenario: OMS015-NEG-081 Riwayat Perubahan tidak tersedia pada toolbar Daftar Order
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Daftar Order"
    Then sistem tidak menampilkan tombol "Riwayat Perubahan" pada toolbar
    And sistem menampilkan tombol "Riwayat Pembatalan" pada toolbar

  @negative @priority-medium @REQ-050 @UI-D05 @screen-riwayat-pembatalan
  Scenario: OMS015-NEG-082 Riwayat Pembatalan tanpa data menampilkan empty state
    Given user login sebagai "Staff Operasional (Shipper)"
    And tidak terdapat order berstatus "Dibatalkan"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Riwayat Pembatalan"
    Then sistem menampilkan "Riwayat Pembatalan"
    And sistem menampilkan "Belum ada data"
    And sistem tidak menampilkan pesan error sistem

  # -------- R10. No. Resi --------

  @negative @priority-high @REQ-052 @UI-D08 @screen-public-tracking
  Scenario: OMS015-NEG-083 No. Resi tidak dikenal menampilkan pesan tidak ditemukan
    Given user berada di halaman "Public Tracking"
    When user mengisi field "No. Resi" dengan "XXX0000000000"
    And user mengklik tombol "Lacak"
    Then sistem menampilkan "Nomor resi tidak ditemukan"
    And sistem tidak menampilkan pesan error sistem

  @negative @priority-high @REQ-053 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-NEG-084 Tidak ada field input No. Resi pada seluruh step wizard
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LTL)"
    Then sistem tidak menampilkan field "No. Resi"
    When user berada di halaman "Buat Order — Step 2 Data Barang"
    Then sistem tidak menampilkan field "No. Resi"
    When user berada di halaman "Buat Order — Step 3 Vendor dan Harga"
    Then sistem tidak menampilkan field "No. Resi"
    When user berada di halaman "Buat Order — Step 4 Review"
    Then sistem tidak menampilkan field "No. Resi" yang dapat diubah

  @negative @priority-high @REQ-054 @UI-103 @screen-daftar-order
  Scenario: OMS015-NEG-085 Order FTL tidak memiliki aksi Lihat No. Resi
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat order FTL berstatus "Ditugaskan" dengan ID "ORD-FTL-0001"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada baris "ORD-FTL-0001"
    Then sistem tidak menampilkan menu "Lihat No. Resi"

  @negative @priority-medium @REQ-054 @UI-101 @screen-detail-order
  Scenario: OMS015-NEG-086 Detail Order FCL tidak menampilkan section No. Resi
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat order FCL berstatus "Menunggu Penugasan" dengan ID "ORD-FCL-0001"
    When user membuka halaman "Detail Order" untuk order "ORD-FCL-0001"
    Then sistem tidak menampilkan "No. Resi"

  @negative @priority-high @REQ-055 @UI-103 @screen-daftar-order
  Scenario: OMS015-NEG-087 Order berstatus draft tidak memiliki aksi Lihat No. Resi
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat order LTL berstatus "Isi Data Pengiriman" dengan ID "ORD-LTL-DRAFT1"
    And terdapat order LTL berstatus "Review Order" dengan ID "ORD-LTL-DRAFT4"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada baris "ORD-LTL-DRAFT1"
    Then sistem tidak menampilkan menu "Lihat No. Resi"
    When user mengklik tombol "Aksi" pada baris "ORD-LTL-DRAFT4"
    Then sistem tidak menampilkan menu "Lihat No. Resi"

  @negative @priority-medium @REQ-055 @UI-103 @screen-daftar-order
  Scenario: OMS015-NEG-088 Order FTL berstatus Menunggu Penugasan belum menampilkan Lihat No. Perjalanan
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat order FTL berstatus "Menunggu Penugasan" dengan ID "ORD-FTL-0002"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada baris "ORD-FTL-0002"
    Then sistem tidak menampilkan menu "Lihat No. Perjalanan"
    And sistem tidak menampilkan menu "Lihat No. Resi"

  @negative @priority-medium @REQ-056 @UI-104 @screen-pop-up-data-no-resi
  Scenario: OMS015-NEG-089 Menutup dialog Data No. Resi via ikon X tidak mengubah data order
    Given user login sebagai "Staff Operasional (Shipper)"
    And user membuka dialog "Data No. Resi" untuk order LTL "ORD-LTL-0001"
    When user mengklik tombol "Tutup" pada dialog "Data No. Resi"
    Then sistem menutup dialog "Data No. Resi"
    And user tetap berada di halaman "Daftar Order"
    And status order "ORD-LTL-0001" tetap "Menunggu Penugasan"

  @negative @priority-high @REQ-058 @UI-101 @screen-detail-order
  Scenario: OMS015-NEG-090 Guest mengakses Detail Order via URL ditolak
    Given user belum terautentikasi
    When user membuka URL "/order/ORD-LTL-0001/detail"
    Then user diarahkan ke halaman "Login"
    And sistem tidak menampilkan "No. Resi"

  # ==========================================================================
  # BAGIAN 3 — SKENARIO EDGE (EDG-001 .. EDG-071)
  # ==========================================================================

  @edge @priority-high @REQ-001 @REQ-007 @REQ-008 @UI-097 @UI-102 @screen-buat-order-step1-ltl
  Scenario: OMS015-EDG-001 Mengganti jenis order dari LTL ke LCL mengganti field rute
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LTL)"
    When user memilih dropdown "Kota Asal" dengan "Kota Surabaya"
    And user memilih kartu jenis order "LCL Less Than Container Load"
    Then sistem tidak menampilkan field "Kota Asal"
    And sistem tidak menampilkan field "Kota Tujuan"
    And sistem menampilkan field "Pelabuhan Asal"
    And sistem menampilkan field "Pelabuhan Tujuan"
    And sistem menampilkan field "Jumlah Kontainer" dalam kondisi tidak dapat diubah bernilai "1"

  @edge @priority-medium @REQ-002 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-EDG-002 Bolak-balik antar Step 1 Step 2 dan Step 3 mempertahankan seluruh data
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 3 Vendor dan Harga" dengan seluruh step sebelumnya terisi
    When user mengklik tombol "Sebelumnya"
    And user mengklik tombol "Sebelumnya"
    And user mengklik tombol "Selanjutnya"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order — Step 3 Vendor dan Harga"
    And sistem menampilkan nilai "PT Logistik Transportasi Nusantara" pada field "Vendor"
    And sistem menampilkan nilai "12.000.000" pada field "Harga"

  @edge @priority-low @REQ-003 @UI-D08 @screen-batch-order
  Scenario: OMS015-EDG-003 Batch Order dengan tepat satu baris data
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Batch Order"
    And user mengunggah berkas "batch-order-ltl-1-baris.xlsx"
    And user mengklik tombol "Proses"
    Then sistem menampilkan "1 order berhasil dibuat"
    And sistem menampilkan badge jenis order "LTL" pada 1 baris order hasil batch

  @edge @priority-high @REQ-009 @UI-097 @screen-buat-order-step1-ltl
  Scenario: OMS015-EDG-004 Kota Asal berbeda kota dengan Drop Point Asal tetap dapat disimpan
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LTL)"
    When user memilih dropdown "Kota Asal" dengan "Kota Jakarta Selatan"
    And user memilih dropdown "Drop Point Asal" dengan "Gudang MSK Region 2"
    And user melengkapi seluruh field wajib Step 1 lainnya
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order — Step 2 Data Barang"
    And sistem tidak menampilkan pesan error kombinasi kota dan drop point

  @edge @priority-medium @REQ-009 @UI-097 @screen-buat-order-step1-ltl
  Scenario: OMS015-EDG-005 Kota Asal sama dengan Kota Tujuan tetap dapat disimpan
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LTL)"
    When user memilih dropdown "Kota Asal" dengan "Kota Surabaya"
    And user memilih dropdown "Kota Tujuan" dengan "Kota Surabaya"
    And user melengkapi seluruh field wajib Step 1 lainnya
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order — Step 2 Data Barang"

  @edge @priority-medium @REQ-007 @UI-102 @screen-buat-order-step1-lcl
  Scenario: OMS015-EDG-006 Pelabuhan Asal sama dengan Pelabuhan Tujuan
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LCL)"
    When user memilih dropdown "Pelabuhan Asal" dengan "Tanjung Perak (SUB)"
    And user memilih dropdown "Pelabuhan Tujuan" dengan "Tanjung Perak (SUB)"
    And user melengkapi seluruh field wajib Step 1 lainnya
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order — Step 2 Data Barang"

  @edge @priority-medium @REQ-012 @UI-097 @screen-buat-order-step1-ltl
  Scenario: OMS015-EDG-007 No. WhatsApp PIC 10 digit sebagai batas bawah diterima
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LTL)"
    When user melengkapi seluruh field wajib Step 1
    And user mengisi field "No. WhatsApp PIC Pengirim" dengan "0812345678"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order — Step 2 Data Barang"

  @edge @priority-medium @REQ-012 @UI-097 @screen-buat-order-step1-ltl
  Scenario: OMS015-EDG-008 No. WhatsApp PIC 15 digit sebagai batas atas diterima
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LTL)"
    When user melengkapi seluruh field wajib Step 1
    And user mengisi field "No. WhatsApp PIC Pengirim" dengan "081234567890123"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order — Step 2 Data Barang"

  @edge @priority-medium @REQ-012 @UI-097 @screen-buat-order-step1-ltl
  Scenario: OMS015-EDG-009 No. WhatsApp PIC 9 digit ditolak
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LTL)"
    When user melengkapi seluruh field wajib Step 1
    And user mengisi field "No. WhatsApp PIC Pengirim" dengan "081234567"
    And user mengklik tombol "Selanjutnya"
    Then user tetap berada di halaman "Buat Order — Step 1 Data Pengiriman (LTL)"
    And sistem menampilkan pesan validasi pada field "No. WhatsApp PIC Pengirim"

  @edge @priority-medium @REQ-012 @UI-097 @screen-buat-order-step1-ltl
  Scenario: OMS015-EDG-010 No. WhatsApp PIC 16 digit ditolak
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LTL)"
    When user melengkapi seluruh field wajib Step 1
    And user mengisi field "No. WhatsApp PIC Pengirim" dengan "0812345678901234"
    And user mengklik tombol "Selanjutnya"
    Then user tetap berada di halaman "Buat Order — Step 1 Data Pengiriman (LTL)"
    And sistem menampilkan pesan validasi pada field "No. WhatsApp PIC Pengirim"

  @edge @priority-low @REQ-012 @UI-097 @screen-buat-order-step1-ltl
  Scenario: OMS015-EDG-011 PIC Pengirim berisi karakter spesial dan tanda kutip
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LTL)"
    When user melengkapi seluruh field wajib Step 1
    And user mengisi field "PIC Pengirim" dengan "O'Brien <Ándré> & Co. \"QA\""
    And user mengklik tombol "Selanjutnya"
    And user menyelesaikan wizard hingga halaman "Buat Order — Step 4 Review"
    Then sistem menampilkan "PIC Pengirim : O'Brien <Ándré> & Co. \"QA\""
    And sistem tidak menampilkan pesan error sistem

  @edge @priority-low @REQ-012 @UI-097 @screen-buat-order-step1-ltl
  Scenario: OMS015-EDG-012 Spasi di awal dan akhir PIC dipangkas sebelum disimpan
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LTL)"
    When user melengkapi seluruh field wajib Step 1
    And user mengisi field "PIC Penerima" dengan "   Basori   "
    And user menyelesaikan wizard hingga halaman "Buat Order — Step 4 Review"
    Then sistem menampilkan "PIC Penerima : Basori"

  @edge @priority-medium @REQ-011 @UI-097 @screen-buat-order-step1-ltl
  Scenario: OMS015-EDG-013 Mengganti Drop Point Asal tiga kali berturut-turut secara cepat
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LTL)"
    When user memilih dropdown "Drop Point Asal" dengan "Gudang MSK Region 2"
    And user memilih dropdown "Drop Point Asal" dengan "Gudang MSK Region 5"
    And user memilih dropdown "Drop Point Asal" dengan "Gudang MSK Region 9"
    Then sistem menampilkan field wilayah asal sesuai "Gudang MSK Region 9"
    And sistem tidak menampilkan sisa data dari "Gudang MSK Region 2"

  @edge @priority-low @REQ-012 @REQ-034 @UI-100 @screen-buat-order-step4
  Scenario: OMS015-EDG-014 Catatan kosong ditampilkan sebagai strip pada Step 4
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LTL)"
    When user melengkapi seluruh field wajib Step 1 tanpa mengisi "Catatan"
    And user menyelesaikan wizard hingga halaman "Buat Order — Step 4 Review"
    Then sistem menampilkan "Catatan : -" pada section "Data Pengirim"
    And sistem menampilkan "Catatan : -" pada section "Data Penerima"

  @edge @priority-medium @REQ-014 @UI-D01 @screen-modal-pilih-barang
  Scenario: OMS015-EDG-015 Pencarian tidak sensitif terhadap huruf besar dan kecil
    Given user login sebagai "Staff Operasional (Shipper)"
    And user membuka dialog "Pilih Barang" dari halaman "Buat Order — Step 2 Data Barang"
    When user mengisi field "Cari Barang" dengan "kErTaS"
    Then sistem menampilkan "Kertas HVS A4 80 gsm"
    When user mengisi field "Cari Barang" dengan "sku-ppr-001"
    Then sistem menampilkan "SKU-PPR-001"

  @edge @priority-low @REQ-014 @UI-D01 @screen-modal-pilih-barang
  Scenario: OMS015-EDG-016 Pencarian dengan satu karakter
    Given user login sebagai "Staff Operasional (Shipper)"
    And user membuka dialog "Pilih Barang" dari halaman "Buat Order — Step 2 Data Barang"
    When user mengisi field "Cari Barang" dengan "P"
    Then sistem menampilkan hasil pencarian yang memuat karakter "P"
    And sistem tidak menampilkan pesan error sistem

  @edge @priority-low @REQ-014 @UI-D01 @screen-modal-pilih-barang
  Scenario: OMS015-EDG-017 Pencarian dengan karakter spesial tidak menyebabkan error
    Given user login sebagai "Staff Operasional (Shipper)"
    And user membuka dialog "Pilih Barang" dari halaman "Buat Order — Step 2 Data Barang"
    When user mengisi field "Cari Barang" dengan "%_<script>'"
    Then sistem menampilkan "Data tidak ditemukan"
    And sistem tidak menampilkan pesan error sistem
    And sistem menampilkan dialog "Pilih Barang" tetap terbuka

  @edge @priority-medium @REQ-015 @UI-D01 @screen-modal-pilih-barang
  Scenario: OMS015-EDG-018 Memilih seluruh barang pada halaman modal sekaligus
    Given user login sebagai "Staff Operasional (Shipper)"
    And Master Barang memuat 7 barang
    And user membuka dialog "Pilih Barang" dari halaman "Buat Order — Step 2 Data Barang"
    When user mencentang checkbox "Pilih Semua"
    Then sistem menampilkan "7 barang terpilih"
    When user mengklik tombol "Simpan" pada modal "Pilih Barang"
    Then sistem menampilkan 7 baris pada tabel "Data Barang"

  @edge @priority-high @REQ-016 @REQ-026 @UI-D01 @screen-modal-pilih-barang
  Scenario: OMS015-EDG-019 Menghapus barang menghilangkan label Sudah Ditambahkan
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan barang "SKU-PPR-001" sudah ditambahkan
    When user mengklik tombol "Hapus" baris "SKU-PPR-001"
    And user mengklik tombol "Pilih Barang"
    Then sistem tidak menampilkan "Sudah Ditambahkan" pada baris "SKU-PPR-001"
    And sistem menampilkan checkbox "SKU-PPR-001" dalam kondisi tidak tercentang

  @edge @priority-low @REQ-017 @UI-D01 @screen-modal-pilih-barang
  Scenario: OMS015-EDG-020 Counter menampilkan nol saat tidak ada barang terpilih
    Given user login sebagai "Staff Operasional (Shipper)"
    And user membuka dialog "Pilih Barang" dari halaman "Buat Order — Step 2 Data Barang"
    Then sistem menampilkan counter barang terpilih bernilai "0" atau counter tidak dirender
    When user mencentang checkbox "SKU-PPR-001"
    And user membatalkan centang checkbox "SKU-PPR-001"
    Then sistem menampilkan counter barang terpilih bernilai "0" atau counter tidak dirender

  @edge @priority-medium @REQ-020 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-EDG-021 Jumlah bernilai 1 sebagai batas bawah diterima
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan barang "SKU-PPR-001" sudah ditambahkan
    When user mengisi field "Jumlah" baris "SKU-PPR-001" dengan "1"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order — Step 3 Vendor dan Harga"

  @edge @priority-medium @REQ-020 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-EDG-022 Jumlah desimal ditolak atau dinormalisasi menjadi integer
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan barang "SKU-PPR-001" sudah ditambahkan
    When user mengisi field "Jumlah" baris "SKU-PPR-001" dengan "1,5"
    And user mengklik tombol "Selanjutnya"
    Then sistem tidak menyimpan nilai "1,5" pada field "Jumlah" baris "SKU-PPR-001"
    And sistem menampilkan nilai integer atau pesan validasi pada field "Jumlah" baris "SKU-PPR-001"

  @edge @priority-medium @REQ-021 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-EDG-023 Nilai Barang dengan pemisah ribuan diformat benar
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan barang "SKU-PPR-001" sudah ditambahkan
    When user mencentang checkbox "Asuransi" baris "SKU-PPR-001"
    And user mengisi field "Nilai Barang" baris "SKU-PPR-001" dengan "1234567"
    Then sistem menampilkan nilai "1.234.567" pada field "Nilai Barang" baris "SKU-PPR-001"
    When user mengisi field "Jumlah" baris "SKU-PPR-001" dengan "10"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "(Total Nilai Barang = Rp1.234.567)"

  @edge @priority-high @REQ-021 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-EDG-024 Menonaktifkan asuransi menghapus kewajiban Nilai Barang dan navigasi diizinkan
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan barang "SKU-PPR-001" sudah ditambahkan
    When user mengisi field "Jumlah" baris "SKU-PPR-001" dengan "100"
    And user mencentang checkbox "Asuransi" baris "SKU-PPR-001"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Nilai Barang harus diisi"
    When user membatalkan centang checkbox "Asuransi" baris "SKU-PPR-001"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order — Step 3 Vendor dan Harga"
    And sistem tidak menampilkan "Nilai Barang harus diisi"

  @edge @priority-low @REQ-022 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-EDG-025 Asuransikan Semua ditekan saat tabel barang kosong
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" tanpa baris barang
    When user mencentang checkbox "Asuransikan Semua"
    Then sistem tidak menampilkan pesan error sistem
    And sistem menampilkan 0 baris pada tabel "Data Barang"
    When user mengklik tombol "Pilih Barang"
    And user mencentang checkbox "SKU-PPR-001"
    And user mengklik tombol "Simpan" pada modal "Pilih Barang"
    Then sistem menampilkan baris barang "SKU-PPR-001"

  @edge @priority-medium @REQ-023 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-EDG-026 Nomor DO dengan koma berlebih dan spasi tidak membentuk chip kosong
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang"
    When user mengisi field "Nomor DO" dengan " DO-001 , , DO-002 ,,, "
    Then sistem menampilkan 2 chip pada field "Nomor DO"
    And sistem menampilkan chip "DO-001"
    And sistem menampilkan chip "DO-002"
    And sistem tidak menampilkan chip kosong

  @edge @priority-medium @REQ-023 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-EDG-027 Nomor DO duplikat tidak digandakan
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang"
    When user mengisi field "Nomor DO" dengan "DO-001,DO-001,DO-002"
    Then sistem menampilkan 2 chip pada field "Nomor DO"
    And sistem menampilkan tepat 1 chip "DO-001"

  @edge @priority-low @REQ-023 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-EDG-028 Nomor DO berisi satu nomor tanpa koma membentuk satu chip
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang"
    When user mengisi field "Nomor DO" dengan "TGK783898202U"
    Then sistem menampilkan 1 chip pada field "Nomor DO"
    And sistem menampilkan chip "TGK783898202U"

  @edge @priority-high @REQ-025 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-EDG-029 Jumlah sangat besar tidak memunculkan peringatan kapasitas dan navigasi tetap lolos
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan barang "SKU-BKU-001" sudah ditambahkan
    When user mengisi field "Jumlah" baris "SKU-BKU-001" dengan "999999"
    Then sistem tidak menampilkan "melebihi kapasitas"
    And sistem tidak menampilkan ringkasan berformat "Total Berat: <terpakai> / <kapasitas> kg"
    When user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order — Step 3 Vendor dan Harga"

  @edge @priority-medium @REQ-026 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-EDG-030 Menghapus baris tengah tidak mempengaruhi nilai baris lain
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan 5 baris barang
    When user mengisi seluruh field "Jumlah" dengan nilai berbeda per baris
    And user mengklik tombol "Hapus" baris ke-3
    Then sistem menampilkan 4 baris pada tabel "Data Barang"
    And sistem menampilkan nilai "Jumlah" yang tidak berubah pada baris 1, 2, 4, dan 5

  @edge @priority-medium @REQ-019 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-EDG-031 Perubahan Master Barang tidak mengubah order yang sudah tersimpan
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat order LTL tersimpan yang memuat barang "SKU-PPR-001" dengan berat "12,5 kg"
    When admin master mengubah berat "SKU-PPR-001" menjadi "20 kg" pada Master Barang
    And user membuka halaman "Detail Order" untuk order tersebut
    Then sistem menampilkan nilai "12,5 kg" pada sel "Berat" baris "SKU-PPR-001"
    And sistem tidak menampilkan nilai "20 kg" pada sel "Berat" baris "SKU-PPR-001"

  @edge @priority-low @REQ-013 @REQ-016 @UI-D01 @screen-modal-pilih-barang
  Scenario: OMS015-EDG-032 Membuka modal saat seluruh barang master sudah ditambahkan
    Given user login sebagai "Staff Operasional (Shipper)"
    And Master Barang memuat 7 barang
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan seluruh 7 barang sudah ditambahkan
    When user mengklik tombol "Pilih Barang"
    Then sistem menampilkan "Sudah Ditambahkan" pada seluruh baris modal
    When user mengklik tombol "Simpan" pada modal "Pilih Barang"
    Then sistem menampilkan 7 baris pada tabel "Data Barang"

  @edge @priority-medium @REQ-029 @UI-099 @screen-buat-order-step3
  Scenario: OMS015-EDG-033 PPN dan PPh bernilai 0 membuat Total Harga sama dengan Harga DPP
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 3 Vendor dan Harga" untuk order LTL tanpa barang diasuransikan
    When user mengisi field "Harga" dengan "5000000"
    And user mencentang checkbox "Gunakan komponen harga"
    And user mengisi field "PPN" dengan "0"
    And user mengisi field "PPh" dengan "0"
    Then sistem menampilkan "Harga DPP" bernilai "Rp5.000.000"
    And sistem menampilkan "Total Harga" bernilai "Rp5.000.000"

  @edge @priority-medium @REQ-029 @UI-099 @screen-buat-order-step3
  Scenario: OMS015-EDG-034 PPN desimal 1 koma 1 persen dihitung benar
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 3 Vendor dan Harga" untuk order LTL tanpa barang diasuransikan
    When user mengisi field "Harga" dengan "12000000"
    And user mencentang checkbox "Gunakan komponen harga"
    And user mengisi field "PPN" dengan "1,1"
    And user mengisi field "PPh" dengan "2"
    Then sistem menampilkan "PPN (1,1%)" bernilai "Rp132.000"
    And sistem menampilkan "PPh (2%)" bernilai "- Rp240.000"
    And sistem menampilkan "Total Harga" bernilai "Rp11.892.000"

  @edge @priority-medium @REQ-029 @UI-099 @screen-buat-order-step3
  Scenario: OMS015-EDG-035 PPh lebih besar dari PPN membuat Total Harga lebih kecil dari Harga DPP
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 3 Vendor dan Harga" untuk order LTL tanpa barang diasuransikan
    When user mengisi field "Harga" dengan "10000000"
    And user mencentang checkbox "Gunakan komponen harga"
    And user mengisi field "PPN" dengan "1"
    And user mengisi field "PPh" dengan "10"
    Then sistem menampilkan "PPN (1%)" bernilai "Rp100.000"
    And sistem menampilkan "PPh (10%)" bernilai "- Rp1.000.000"
    And sistem menampilkan "Total Harga" bernilai "Rp9.100.000"

  @edge @priority-medium @REQ-029 @UI-099 @screen-buat-order-step3
  Scenario: OMS015-EDG-036 Menonaktifkan Gunakan komponen harga menyembunyikan PPN PPh dan mengembalikan Total Harga
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 3 Vendor dan Harga" untuk order LTL tanpa barang diasuransikan
    When user mengisi field "Harga" dengan "8000000"
    And user mencentang checkbox "Gunakan komponen harga"
    And user mengisi field "PPN" dengan "11"
    And user mengisi field "PPh" dengan "2"
    And user membatalkan centang checkbox "Gunakan komponen harga"
    Then sistem tidak menampilkan field "PPN"
    And sistem tidak menampilkan field "PPh"
    And sistem menampilkan "Total Harga" bernilai "Rp8.000.000"

  @edge @priority-medium @REQ-030 @UI-099 @screen-buat-order-step3
  Scenario: OMS015-EDG-037 Waktu Perjalanan bernilai 1 jam sebagai batas bawah diterima
    Given user login sebagai "Staff Operasional (Shipper)"
    And rute order belum terdaftar pada "Master Waktu Perjalanan"
    And user berada di halaman "Buat Order — Step 3 Vendor dan Harga" untuk order LTL
    When user melengkapi seluruh field wajib Step 3
    And user mengisi field "Waktu Perjalanan" dengan "1"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order — Step 4 Review"
    And sistem menampilkan "Waktu Perjalanan : 1 Jam"

  @edge @priority-medium @REQ-030 @UI-099 @screen-buat-order-step3
  Scenario: OMS015-EDG-038 Waktu Perjalanan bernilai 0 ditolak
    Given user login sebagai "Staff Operasional (Shipper)"
    And rute order belum terdaftar pada "Master Waktu Perjalanan"
    And user berada di halaman "Buat Order — Step 3 Vendor dan Harga" untuk order LTL
    When user melengkapi seluruh field wajib Step 3
    And user mengisi field "Waktu Perjalanan" dengan "0"
    And user mengklik tombol "Selanjutnya"
    Then user tetap berada di halaman "Buat Order — Step 3 Vendor dan Harga"
    And sistem menampilkan pesan validasi pada field "Waktu Perjalanan"

  @edge @priority-low @REQ-029 @UI-099 @screen-buat-order-step3
  Scenario: OMS015-EDG-039 Tanggal Permintaan Muat tepat satu menit setelah waktu sekarang diterima
    Given user login sebagai "Staff Operasional (Shipper)"
    And waktu sistem saat ini adalah "26/08/2026 10:00"
    And user berada di halaman "Buat Order — Step 3 Vendor dan Harga" untuk order LTL
    When user melengkapi seluruh field wajib Step 3
    And user mengisi field "Tanggal Permintaan Muat" dengan "26/08/2026 10:01"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order — Step 4 Review"

  @edge @priority-high @REQ-032 @UI-099 @screen-buat-order-step3
  Scenario: OMS015-EDG-040 Hanya satu dari lima barang diasuransikan menghasilkan Total Nilai Barang dari barang tersebut saja
    Given user login sebagai "Staff Operasional (Shipper)"
    And persentase asuransi sistem bernilai "1%"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan 5 baris barang dan seluruh Jumlah terisi
    When user mencentang checkbox "Asuransi" baris "SKU-BKU-001"
    And user mengisi field "Nilai Barang" baris "SKU-BKU-001" dengan "4500000"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "(Total Nilai Barang = Rp4.500.000)"
    And sistem menampilkan "Asuransi (1%)" bernilai "Rp45.000"

  @edge @priority-high @REQ-032 @UI-099 @screen-buat-order-step3
  Scenario: OMS015-EDG-041 Seluruh barang diasuransikan menghasilkan Total Nilai Barang dari seluruh baris
    Given user login sebagai "Staff Operasional (Shipper)"
    And persentase asuransi sistem bernilai "1%"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan 3 baris barang dan seluruh Jumlah terisi
    When user mencentang checkbox "Asuransikan Semua"
    And user mengisi field "Nilai Barang" baris "SKU-PPR-001" dengan "1000000"
    And user mengisi field "Nilai Barang" baris "SKU-PPR-002" dengan "2000000"
    And user mengisi field "Nilai Barang" baris "SKU-BKU-001" dengan "3000000"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "(Total Nilai Barang = Rp6.000.000)"
    And sistem menampilkan "Asuransi (1%)" bernilai "Rp60.000"
    And sistem tidak menampilkan "Tanpa Asuransi"

  @edge @priority-medium @REQ-031 @UI-101 @screen-detail-order
  Scenario: OMS015-EDG-042 Waktu Perjalanan LCL saat ETA dan ETD pada hari yang sama
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat order LCL dengan ETD "01/08/2026" dan ETA "01/08/2026"
    And order tersebut berstatus "Ditugaskan"
    When user membuka halaman "Detail Order" untuk order tersebut
    Then sistem menampilkan "Waktu Perjalanan" bernilai "4 Hari"

  @edge @priority-medium @REQ-033 @REQ-032 @UI-099 @screen-buat-order-step3
  Scenario: OMS015-EDG-043 Kembali ke Step 2 menghapus barang berasuransi lalu maju ke Step 3
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 3 Vendor dan Harga" dengan hanya barang "SKU-PPR-001" diasuransikan
    Then sistem menampilkan "Asuransi ("
    When user mengklik tombol "Sebelumnya"
    And user mengklik tombol "Hapus" baris "SKU-PPR-001"
    And user mengklik tombol "Selanjutnya"
    Then sistem tidak menampilkan "Asuransi ("
    And sistem menampilkan "Tanpa Asuransi" pada kolom "Total Nilai Barang"

  @edge @priority-medium @REQ-034 @UI-100 @screen-buat-order-step4
  Scenario: OMS015-EDG-044 Review order dengan tepat satu barang
    Given user login sebagai "Staff Operasional (Shipper)"
    And user membuat order LTL dengan tepat 1 barang "SKU-PPR-001" berjumlah "1"
    When user berada di halaman "Buat Order — Step 4 Review"
    Then sistem menampilkan 1 baris pada tabel "Data Barang"
    And sistem menampilkan tepat 1 tabel "Data Barang"

  @edge @priority-medium @REQ-035 @UI-100 @screen-buat-order-step4
  Scenario: OMS015-EDG-045 Review order dengan 50 baris barang tetap dalam satu grup
    Given user login sebagai "Staff Operasional (Shipper)"
    And user membuat order LTL dengan 50 baris barang dan seluruh Jumlah terisi
    When user berada di halaman "Buat Order — Step 4 Review"
    Then sistem menampilkan 50 baris pada tabel "Data Barang"
    And sistem menampilkan tepat 1 tabel "Data Barang"
    And sistem tidak menampilkan "Armada 1"
    And sistem tidak menampilkan "Kontainer 1"

  @edge @priority-medium @REQ-036 @UI-100 @screen-buat-order-step4
  Scenario: OMS015-EDG-046 Seluruh barang diasuransikan menampilkan nominal pada seluruh baris Review
    Given user login sebagai "Staff Operasional (Shipper)"
    And user membuat order LTL dengan 3 barang yang seluruhnya diasuransikan
    When user berada di halaman "Buat Order — Step 4 Review"
    Then sistem tidak menampilkan "Tanpa Asuransi"
    And sistem menampilkan nominal pada kolom "Nilai Barang" untuk seluruh baris
    And sistem menampilkan "Asuransi ("

  @edge @priority-high @REQ-037 @UI-100 @screen-buat-order-step4
  Scenario: OMS015-EDG-047 Klik Simpan dua kali secara cepat hanya membentuk satu order
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 4 Review" dengan seluruh step terisi
    When user mengklik tombol "Simpan" dua kali secara berurutan dalam 200 ms
    And user mengklik tombol "Ya, Simpan" pada pop up konfirmasi
    Then user diarahkan ke halaman "Daftar Order"
    And sistem membuat tepat 1 order baru
    And sistem tidak menampilkan 2 baris order dengan data identik

  @edge @priority-medium @REQ-038 @UI-096 @screen-daftar-order
  Scenario: OMS015-EDG-048 Badge status memakai penamaan alternatif Isi Data Dasar dan Terkirim
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Daftar Order"
    Then sistem menampilkan badge status yang cocok dengan pola "(Isi Data Pengiriman|Isi Data Dasar)"
    And sistem menampilkan badge status yang cocok dengan pola "(Selesai|Terkirim)"

  @edge @priority-medium @REQ-039 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-EDG-049 Simpan ke Draf dari Step 2 lalu Lanjutkan Pengisian membuka kembali Step 2
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan 2 baris barang dan seluruh Jumlah terisi
    When user mengklik tombol "Simpan ke Draf"
    And user mengklik tombol "Ya, Simpan" pada pop up konfirmasi
    And user mengklik tombol "Aksi" pada baris order baru
    And user mengklik menu "Lanjutkan Pengisian"
    Then user diarahkan ke halaman "Buat Order — Step 2 Data Barang"
    And sistem menampilkan step "Data Barang" dalam state "active"
    And sistem menampilkan 2 baris pada tabel "Data Barang"

  @edge @priority-medium @REQ-039 @UI-097 @screen-buat-order-step1-ltl
  Scenario: OMS015-EDG-050 Simpan ke Draf pada Step 1 dengan sebagian field wajib kosong
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LTL)"
    When user memilih dropdown "Kota Asal" dengan "Kota Surabaya"
    And user mengklik tombol "Simpan ke Draf"
    And user mengklik tombol "Ya, Simpan" pada pop up konfirmasi
    Then user diarahkan ke halaman "Daftar Order"
    And sistem menampilkan badge status "Isi Data Pengiriman" pada baris order baru

  @edge @priority-low @REQ-038 @UI-103 @screen-daftar-order-filter
  Scenario: OMS015-EDG-051 Filter Status dengan kombinasi dua status sekaligus
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Filter"
    And user memilih dropdown "Status" dengan "Menunggu Penugasan"
    And user memilih dropdown "Status" dengan "Ditugaskan"
    And user mengklik tombol "Terapkan"
    Then sistem menampilkan hanya baris berstatus "Menunggu Penugasan" atau "Ditugaskan"
    And sistem tidak menampilkan badge status "Dibatalkan"

  @edge @priority-high @REQ-043 @UI-D07 @screen-edit-order
  Scenario: OMS015-EDG-052 Menghapus seluruh barang pada Edit Order menahan Simpan
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Edit Order" untuk order LTL berstatus "Menunggu Penugasan" dengan 2 baris barang
    When user mengklik tombol "Hapus" baris "SKU-PPR-001"
    And user mengklik tombol "Hapus" baris "SKU-PPR-002"
    And user mengklik tombol "Simpan"
    Then user tetap berada di halaman "Edit Order"
    And sistem menampilkan pesan validasi minimal satu barang
    And sistem tidak menampilkan "Perubahan berhasil disimpan"

  @edge @priority-high @REQ-043 @REQ-032 @UI-D07 @screen-edit-order
  Scenario: OMS015-EDG-053 Mengubah status asuransi pada Edit Order memperbarui Asuransi dan Total Harga
    Given user login sebagai "Staff Operasional (Shipper)"
    And persentase asuransi sistem bernilai "1%"
    And user berada di halaman "Edit Order" untuk order LTL berstatus "Menunggu Penugasan" dengan Harga "10000000" tanpa barang diasuransikan
    Then sistem tidak menampilkan "Asuransi ("
    When user mencentang checkbox "Asuransi" baris "SKU-PPR-001"
    And user mengisi field "Nilai Barang" baris "SKU-PPR-001" dengan "5000000"
    Then sistem menampilkan "Asuransi (1%)" bernilai "Rp50.000"
    And sistem menampilkan "Total Harga" bernilai "Rp10.050.000"

  @edge @priority-medium @REQ-042 @UI-D07 @screen-edit-order
  Scenario: OMS015-EDG-054 ID Order dan Tanggal Dibuat read-only pada Edit Order
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Edit Order" untuk order LTL "ORD-LTL-0001" berstatus "Menunggu Penugasan"
    Then sistem menampilkan "ID Order" dalam kondisi tidak dapat diubah bernilai "ORD-LTL-0001"
    And sistem menampilkan "Tanggal Dibuat" dalam kondisi tidak dapat diubah

  @edge @priority-medium @REQ-040 @UI-103 @screen-daftar-order
  Scenario: OMS015-EDG-055 Order draft menampilkan Lanjutkan Pengisian bukan Edit
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat order LTL berstatus "Review Order" dengan ID "ORD-LTL-DRAFT4"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada baris "ORD-LTL-DRAFT4"
    Then sistem menampilkan menu "Lanjutkan Pengisian"
    And sistem tidak menampilkan menu "Edit"

  @edge @priority-medium @REQ-043 @REQ-024 @UI-D07 @screen-edit-order
  Scenario: OMS015-EDG-056 Jumlah Armada dan Jumlah Kontainer tetap 1 pada Edit Order LTL dan LCL
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat order LTL "ORD-LTL-0001" dan order LCL "ORD-LCL-0001" berstatus "Menunggu Penugasan"
    When user berada di halaman "Edit Order" untuk order "ORD-LTL-0001"
    Then sistem menampilkan field "Jumlah Armada" dalam kondisi tidak dapat diubah bernilai "1"
    When user berada di halaman "Edit Order" untuk order "ORD-LCL-0001"
    Then sistem menampilkan field "Jumlah Kontainer" dalam kondisi tidak dapat diubah bernilai "1"

  @edge @priority-low @REQ-047 @UI-D04 @screen-pop-up-batalkan-order
  Scenario: OMS015-EDG-057 Alasan Pembatalan satu karakter diterima
    Given user login sebagai "Admin Shipper"
    And user membuka dialog "Batalkan Order" untuk order LTL "ORD-LTL-0001" berstatus "Menunggu Penugasan"
    When user mengisi field "Alasan Pembatalan" dengan "X"
    And user mengklik tombol "Konfirmasi"
    Then sistem menampilkan "Order berhasil dibatalkan"
    And sistem menampilkan badge status "Dibatalkan" pada baris "ORD-LTL-0001"

  @edge @priority-low @REQ-047 @UI-D04 @screen-pop-up-batalkan-order
  Scenario: OMS015-EDG-058 Alasan Pembatalan berisi emoji dan karakter spesial
    Given user login sebagai "Admin Shipper"
    And user membuka dialog "Batalkan Order" untuk order LTL "ORD-LTL-0001" berstatus "Menunggu Penugasan"
    When user mengisi field "Alasan Pembatalan" dengan "Batal 🚚 <script>alert(1)</script> & 100% \"urgent\""
    And user mengklik tombol "Konfirmasi"
    Then sistem menampilkan "Order berhasil dibatalkan"
    When user mengklik tombol "Riwayat Pembatalan"
    Then sistem menampilkan "Batal 🚚 <script>alert(1)</script> & 100% \"urgent\""
    And sistem tidak mengeksekusi skrip pada halaman

  @edge @priority-medium @REQ-045 @UI-D04 @screen-pop-up-batalkan-order
  Scenario: OMS015-EDG-059 Menutup pop up pembatalan sebelum konfirmasi tidak mengubah status
    Given user login sebagai "Admin Shipper"
    And user membuka dialog "Batalkan Order" untuk order LTL "ORD-LTL-0001" berstatus "Menunggu Penugasan"
    When user mengisi field "Alasan Pembatalan" dengan "Coba batal"
    And user mengklik tombol "Tutup" pada dialog "Batalkan Order"
    Then sistem menutup dialog "Batalkan Order"
    And status order "ORD-LTL-0001" tetap "Menunggu Penugasan"

  @edge @priority-low @REQ-047 @UI-D04 @screen-pop-up-batalkan-order
  Scenario: OMS015-EDG-060 Alasan Pembatalan dengan spasi di awal dan akhir dipangkas
    Given user login sebagai "Admin Shipper"
    And user membuka dialog "Batalkan Order" untuk order LTL "ORD-LTL-0001" berstatus "Menunggu Penugasan"
    When user mengisi field "Alasan Pembatalan" dengan "   Barang belum siap   "
    And user mengklik tombol "Konfirmasi"
    And user mengklik tombol "Riwayat Pembatalan"
    Then sistem menampilkan "Barang belum siap"

  @edge @priority-medium @REQ-050 @UI-D05 @screen-riwayat-pembatalan
  Scenario: OMS015-EDG-061 Order yang baru dibatalkan langsung muncul di Riwayat Pembatalan
    Given user login sebagai "Admin Shipper"
    And terdapat order LTL berstatus "Menunggu Penugasan" dengan ID "ORD-LTL-0009"
    When user membatalkan order "ORD-LTL-0009" dengan alasan "Perubahan rencana distribusi"
    And user mengklik tombol "Riwayat Pembatalan"
    Then sistem menampilkan "ORD-LTL-0009" pada baris teratas daftar "Riwayat Pembatalan"
    And sistem menampilkan "Perubahan rencana distribusi"

  @edge @priority-medium @REQ-051 @UI-D06 @screen-riwayat-perubahan
  Scenario: OMS015-EDG-062 Isi Riwayat Perubahan berbeda dengan isi Riwayat Pembatalan
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat order LTL "ORD-LTL-0001" yang pernah diedit dan order LTL "ORD-LTL-0008" yang pernah dibatalkan
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada baris "ORD-LTL-0001"
    And user mengklik menu "Riwayat Perubahan"
    Then sistem menampilkan kolom histori perubahan field
    And sistem tidak menampilkan kolom "Alasan Pembatalan"
    When user menutup panel "Riwayat Perubahan"
    And user mengklik tombol "Riwayat Pembatalan"
    Then sistem menampilkan kolom "Alasan Pembatalan"
    And sistem tidak menampilkan "ORD-LTL-0001"

  @edge @priority-medium @REQ-048 @REQ-001 @UI-103 @screen-daftar-order-filter
  Scenario: OMS015-EDG-063 Filter Jenis Order LTL hanya menampilkan baris LTL
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Filter"
    And user memilih dropdown "Jenis Order" dengan "LTL"
    And user mengklik tombol "Terapkan"
    Then sistem menampilkan hanya baris dengan badge jenis order "LTL"
    And sistem tidak menampilkan badge jenis order "FTL"
    And sistem tidak menampilkan badge jenis order "FCL"
    And sistem tidak menampilkan badge jenis order "LCL"

  @edge @priority-low @REQ-048 @UI-103 @screen-daftar-order-filter
  Scenario: OMS015-EDG-064 Reset filter mengembalikan daftar penuh
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Filter"
    And user memilih dropdown "Jenis Order" dengan "LCL"
    And user mengklik tombol "Terapkan"
    And user mengklik tombol "Filter"
    And user mengklik tombol "Reset"
    Then sistem mengosongkan seluruh field filter
    And sistem menampilkan daftar order tanpa filter aktif

  @edge @priority-high @REQ-053 @UI-104 @screen-pop-up-data-no-resi
  Scenario: OMS015-EDG-065 Menambah barang melalui Edit Order menambah entri No. Resi baru
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat order LTL "ORD-LTL-0001" berstatus "Menunggu Penugasan" dengan 3 barang
    And user berada di halaman "Edit Order" untuk order "ORD-LTL-0001"
    When user mengklik tombol "Pilih Barang"
    And user mencentang checkbox "SKU-ATK-001"
    And user mengklik tombol "Simpan" pada modal "Pilih Barang"
    And user mengisi field "Jumlah" baris "SKU-ATK-001" dengan "10"
    And user mengklik tombol "Simpan"
    And user mengklik tombol "Ya, Simpan" pada pop up konfirmasi
    And user membuka dialog "Data No. Resi" untuk order LTL "ORD-LTL-0001"
    Then sistem menampilkan 4 baris pada tabel "Data No. Resi"
    And sistem menampilkan "SKU-ATK-001" dengan No. Resi terisi

  @edge @priority-high @REQ-053 @UI-104 @screen-pop-up-data-no-resi
  Scenario: OMS015-EDG-066 Menghapus barang melalui Edit Order menghapus entri No. Resi terkait
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat order LTL "ORD-LTL-0001" berstatus "Menunggu Penugasan" dengan 3 barang
    And user berada di halaman "Edit Order" untuk order "ORD-LTL-0001"
    When user mengklik tombol "Hapus" baris "SKU-PPR-002"
    And user mengklik tombol "Simpan"
    And user mengklik tombol "Ya, Simpan" pada pop up konfirmasi
    And user membuka dialog "Data No. Resi" untuk order LTL "ORD-LTL-0001"
    Then sistem menampilkan 2 baris pada tabel "Data No. Resi"
    And sistem tidak menampilkan "SKU-PPR-002"

  @edge @priority-high @REQ-053 @UI-104 @screen-pop-up-data-no-resi
  Scenario: OMS015-EDG-067 No. Resi barang yang tetap ada tidak berubah setelah Edit Order
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat order LTL "ORD-LTL-0001" berstatus "Menunggu Penugasan" dengan 3 barang
    And user mencatat No. Resi untuk barang "SKU-PPR-001"
    When user menambahkan barang "SKU-ATK-001" melalui halaman "Edit Order" dan menyimpannya
    And user membuka dialog "Data No. Resi" untuk order LTL "ORD-LTL-0001"
    Then sistem menampilkan No. Resi untuk "SKU-PPR-001" yang sama dengan yang dicatat sebelumnya

  @edge @priority-medium @REQ-056 @UI-104 @screen-pop-up-data-no-resi
  Scenario: OMS015-EDG-068 Order dengan satu barang menampilkan satu baris resi
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat order LTL berstatus "Menunggu Penugasan" dengan tepat 1 barang
    When user membuka dialog "Data No. Resi" untuk order tersebut
    Then sistem menampilkan 1 baris pada tabel "Data No. Resi"
    And sistem menampilkan kolom "No. Resi"

  @edge @priority-low @REQ-056 @UI-104 @screen-pop-up-data-no-resi
  Scenario: OMS015-EDG-069 Kolom Kode SKU dan Nama Barang pada dialog resi dapat di-sort
    Given user login sebagai "Staff Operasional (Shipper)"
    And user membuka dialog "Data No. Resi" untuk order LTL dengan 7 barang
    When user mengklik header kolom "Kode SKU"
    Then sistem menampilkan baris terurut naik berdasarkan "Kode SKU"
    When user mengklik header kolom "Nama Barang"
    Then sistem menampilkan baris terurut naik berdasarkan "Nama Barang"

  @edge @priority-medium @REQ-057 @UI-104 @screen-pop-up-data-no-resi
  Scenario: OMS015-EDG-070 Menyalin baris ketiga tidak mempengaruhi baris lain
    Given user login sebagai "Staff Operasional (Shipper)"
    And user membuka dialog "Data No. Resi" untuk order LTL dengan 7 barang
    When user mengklik tombol "Salin" pada baris 3
    Then isi clipboard sama dengan No. Resi pada baris 3
    And sistem menampilkan No. Resi pada baris 1 yang tidak berubah
    And sistem menampilkan No. Resi pada baris 7 yang tidak berubah

  @edge @priority-low @REQ-052 @UI-D08 @screen-public-tracking
  Scenario: OMS015-EDG-071 Public tracking dengan No. Resi berisi spasi di awal dan akhir
    Given terdapat order LTL berstatus "Proses Pengiriman" dengan No. Resi "LKL7920830903"
    And user berada di halaman "Public Tracking"
    When user mengisi field "No. Resi" dengan "  LKL7920830903  "
    And user mengklik tombol "Lacak"
    Then sistem menampilkan progress pengiriman untuk resi "LKL7920830903"
    And sistem tidak menampilkan "Nomor resi tidak ditemukan"

  # ==========================================================================
  # BAGIAN 4 — SKENARIO STRESS (STR-001 .. STR-030)
  # ==========================================================================

  @stress @priority-medium @REQ-003 @UI-D08 @screen-batch-order
  Scenario: OMS015-STR-001 Batch Order dengan 500 baris order LTL
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Batch Order"
    And user mengunggah berkas "batch-order-ltl-500-baris.xlsx"
    And user mengklik tombol "Proses"
    Then sistem menampilkan "500 order berhasil dibuat" dalam waktu kurang dari 120 detik
    And sistem tidak menampilkan pesan error sistem
    And sistem menampilkan badge jenis order "LTL" pada order hasil batch

  @stress @priority-low @REQ-002 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-STR-002 Navigasi bolak-balik antar step sebanyak 30 kali
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 3 Vendor dan Harga" dengan seluruh step sebelumnya terisi
    When user mengklik tombol "Sebelumnya" dan "Selanjutnya" bergantian sebanyak 30 kali
    Then sistem menampilkan nilai "PT Logistik Transportasi Nusantara" pada field "Vendor"
    And sistem menampilkan 2 baris pada tabel "Data Barang"
    And sistem tidak menampilkan pesan error sistem

  @stress @priority-low @REQ-012 @UI-097 @screen-buat-order-step1-ltl
  Scenario: OMS015-STR-003 Catatan pengirim berisi 5.000 karakter
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LTL)"
    When user melengkapi seluruh field wajib Step 1
    And user mengisi field "Catatan" pada section "Data Pengirim" dengan teks 5000 karakter
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan hasil yang konsisten yaitu navigasi berhasil atau pesan batas panjang
    And sistem tidak menampilkan pesan error sistem

  @stress @priority-low @REQ-012 @UI-097 @screen-buat-order-step1-ltl
  Scenario: OMS015-STR-004 PIC Pengirim berisi 255 karakter
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LTL)"
    When user melengkapi seluruh field wajib Step 1
    And user mengisi field "PIC Pengirim" dengan teks 255 karakter
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan hasil yang konsisten yaitu navigasi berhasil atau pesan batas panjang
    And sistem tidak menampilkan pesan error sistem

  @stress @priority-low @REQ-011 @UI-097 @screen-buat-order-step1-ltl
  Scenario: OMS015-STR-005 Dropdown Drop Point dengan 1.000 opsi
    Given user login sebagai "Staff Operasional (Shipper)"
    And Master Droppoint memuat 1000 drop point
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LTL)"
    When user mengklik dropdown "Drop Point Asal"
    Then sistem menampilkan daftar opsi dalam waktu kurang dari 5 detik
    When user mengisi pencarian dropdown "Drop Point Asal" dengan "Region 999"
    Then sistem menampilkan opsi "Gudang MSK Region 999"

  @stress @priority-medium @REQ-012 @UI-097 @screen-buat-order-step1-ltl
  Scenario: OMS015-STR-006 Klik Selanjutnya sepuluh kali beruntun hanya menavigasi sekali
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LTL)"
    When user melengkapi seluruh field wajib Step 1
    And user mengklik tombol "Selanjutnya" sebanyak 10 kali dalam 1 detik
    Then user diarahkan ke halaman "Buat Order — Step 2 Data Barang"
    And sistem tidak melewati step manapun
    And sistem tidak menampilkan pesan error sistem

  @stress @priority-medium @REQ-015 @UI-D01 @screen-modal-pilih-barang
  Scenario: OMS015-STR-007 Memilih 100 barang sekaligus dari modal Pilih Barang
    Given user login sebagai "Staff Operasional (Shipper)"
    And Master Barang memuat 100 barang
    And user membuka dialog "Pilih Barang" dari halaman "Buat Order — Step 2 Data Barang"
    When user mencentang seluruh 100 checkbox barang
    Then sistem menampilkan "100 barang terpilih"
    When user mengklik tombol "Simpan" pada modal "Pilih Barang"
    Then sistem menampilkan 100 baris pada tabel "Data Barang" dalam waktu kurang dari 10 detik

  @stress @priority-medium @REQ-020 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-STR-008 Mengisi Jumlah pada 100 baris barang
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan 100 baris barang
    When user mengisi seluruh field "Jumlah" pada 100 baris dengan nilai "10"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order — Step 3 Vendor dan Harga"
    And sistem tidak menampilkan "harus diisi"

  @stress @priority-low @REQ-023 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-STR-009 Nomor DO berisi 50 nomor sekaligus
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang"
    When user mengisi field "Nomor DO" dengan 50 nomor dipisahkan koma
    Then sistem menampilkan 50 chip pada field "Nomor DO"
    And sistem tidak menampilkan pesan error sistem
    When user menyelesaikan wizard hingga halaman "Buat Order — Step 4 Review"
    Then sistem menampilkan 50 chip pada section "Data Barang"

  @stress @priority-low @REQ-014 @UI-D01 @screen-modal-pilih-barang
  Scenario: OMS015-STR-010 Pengetikan pencarian cepat berturut-turut memicu debounce yang stabil
    Given user login sebagai "Staff Operasional (Shipper)"
    And user membuka dialog "Pilih Barang" dari halaman "Buat Order — Step 2 Data Barang"
    When user mengetik "K", "Ke", "Ker", "Kert", "Kerta", "Kertas" secara berurutan dalam 500 ms
    Then sistem menampilkan hasil akhir sesuai kata kunci "Kertas"
    And sistem tidak menampilkan hasil dari kata kunci antara
    And sistem tidak menampilkan pesan error sistem

  @stress @priority-low @REQ-013 @UI-D01 @screen-modal-pilih-barang
  Scenario: OMS015-STR-011 Membuka dan menutup modal Pilih Barang 20 kali
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang"
    When user membuka dan menutup dialog "Pilih Barang" sebanyak 20 kali
    Then sistem menampilkan dialog "Pilih Barang" dengan state bersih pada pembukaan terakhir
    And sistem menampilkan counter barang terpilih bernilai "0" atau counter tidak dirender
    And sistem tidak menampilkan pesan error sistem

  @stress @priority-low @REQ-021 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-STR-012 Nilai Barang berisi 15 digit
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan barang "SKU-PPR-001" sudah ditambahkan
    When user mencentang checkbox "Asuransi" baris "SKU-PPR-001"
    And user mengisi field "Nilai Barang" baris "SKU-PPR-001" dengan "999999999999999"
    And user mengisi field "Jumlah" baris "SKU-PPR-001" dengan "1"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan nominal Total Nilai Barang tanpa pemotongan digit
    And sistem tidak menampilkan pesan error sistem

  @stress @priority-low @REQ-026 @UI-098 @screen-buat-order-step2
  Scenario: OMS015-STR-013 Menghapus 100 baris barang berturut-turut
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan 100 baris barang
    When user mengklik tombol "Hapus" pada seluruh 100 baris berturut-turut
    Then sistem menampilkan 0 baris pada tabel "Data Barang"
    And sistem menampilkan empty state pada tabel "Data Barang"
    And sistem tidak menampilkan pesan error sistem

  @stress @priority-low @REQ-029 @UI-099 @screen-buat-order-step3
  Scenario: OMS015-STR-014 Harga bernilai 999.999.999.999
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 3 Vendor dan Harga" untuk order LTL tanpa barang diasuransikan
    When user melengkapi seluruh field wajib Step 3
    And user mengisi field "Harga" dengan "999999999999"
    Then sistem menampilkan "Total Harga" bernilai "Rp999.999.999.999"
    And sistem tidak menampilkan nilai yang terpotong pada "Total Harga"

  @stress @priority-medium @REQ-032 @UI-099 @screen-buat-order-step3
  Scenario: OMS015-STR-015 Perhitungan Asuransi atas 100 barang yang diasuransikan
    Given user login sebagai "Staff Operasional (Shipper)"
    And persentase asuransi sistem bernilai "1%"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan 100 baris barang dan seluruh Jumlah terisi
    When user mencentang checkbox "Asuransikan Semua"
    And user mengisi seluruh field "Nilai Barang" pada 100 baris dengan nilai "1000000"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "(Total Nilai Barang = Rp100.000.000)"
    And sistem menampilkan "Asuransi (1%)" bernilai "Rp1.000.000"

  @stress @priority-low @REQ-029 @UI-099 @screen-buat-order-step3
  Scenario: OMS015-STR-016 Toggle Gunakan komponen harga sebanyak 30 kali
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 3 Vendor dan Harga" untuk order LTL
    When user mengisi field "Harga" dengan "10000000"
    And user mencentang dan membatalkan centang checkbox "Gunakan komponen harga" sebanyak 30 kali
    Then sistem menampilkan "Total Harga" bernilai "Rp10.000.000"
    And sistem tidak menampilkan pesan error sistem

  @stress @priority-medium @REQ-034 @UI-100 @screen-buat-order-step4
  Scenario: OMS015-STR-017 Render Step 4 dengan 200 baris barang
    Given user login sebagai "Staff Operasional (Shipper)"
    And user membuat order LTL dengan 200 baris barang dan seluruh Jumlah terisi
    When user berada di halaman "Buat Order — Step 4 Review"
    Then sistem menampilkan 200 baris pada tabel "Data Barang" dalam waktu kurang dari 15 detik
    And sistem menampilkan tepat 1 tabel "Data Barang"
    And sistem tidak menampilkan pesan error sistem

  @stress @priority-medium @REQ-037 @UI-100 @screen-buat-order-step4
  Scenario: OMS015-STR-018 Sepuluh sesi pembuatan order berjalan paralel
    Given terdapat 10 sesi user "Staff Operasional (Shipper)" yang aktif bersamaan
    When seluruh sesi menyelesaikan wizard dan mengklik tombol "Simpan" dalam waktu bersamaan
    Then sistem membuat tepat 10 order baru
    And seluruh order memiliki ID Order yang unik
    And seluruh order berstatus "Menunggu Penugasan"

  @stress @priority-low @REQ-039 @UI-D03 @screen-pop-up-konfirmasi
  Scenario: OMS015-STR-019 Membuat 50 draft berturut-turut
    Given user login sebagai "Staff Operasional (Shipper)"
    When user membuat 50 draft order LTL melalui "Simpan ke Draf" secara berurutan
    Then sistem menampilkan 50 order draft pada "Daftar Order"
    And seluruh draft memiliki ID Order yang unik
    And sistem tidak menampilkan pesan error sistem

  @stress @priority-medium @REQ-044 @UI-D07 @screen-edit-order
  Scenario: OMS015-STR-020 Dua sesi Edit Order paralel atas order yang sama
    Given terdapat order LTL "ORD-LTL-0001" berstatus "Menunggu Penugasan"
    And sesi A dan sesi B membuka halaman "Edit Order" untuk order "ORD-LTL-0001" secara bersamaan
    When sesi A mengubah "PIC Pengirim" menjadi "Nama A" lalu menyimpan
    And sesi B mengubah "PIC Pengirim" menjadi "Nama B" lalu menyimpan
    Then sistem menampilkan hasil yang deterministik yaitu perubahan terakhir tersimpan atau pesan konflik
    And sistem mencatat kedua percobaan pada "Riwayat Perubahan"

  @stress @priority-low @REQ-043 @UI-D07 @screen-edit-order
  Scenario: OMS015-STR-021 Menambah 100 barang melalui Edit Order
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Edit Order" untuk order LTL berstatus "Menunggu Penugasan" dengan 1 baris barang
    When user menambahkan 100 barang melalui modal "Pilih Barang"
    And user mengisi seluruh field "Jumlah" dengan nilai "5"
    And user mengklik tombol "Simpan"
    And user mengklik tombol "Ya, Simpan" pada pop up konfirmasi
    Then sistem menampilkan "Perubahan berhasil disimpan"
    And sistem menampilkan 101 baris pada tabel "Data Barang"

  @stress @priority-low @REQ-047 @UI-D04 @screen-pop-up-batalkan-order
  Scenario: OMS015-STR-022 Alasan Pembatalan berisi 5.000 karakter
    Given user login sebagai "Admin Shipper"
    And user membuka dialog "Batalkan Order" untuk order LTL "ORD-LTL-0001" berstatus "Menunggu Penugasan"
    When user mengisi field "Alasan Pembatalan" dengan teks 5000 karakter
    And user mengklik tombol "Konfirmasi"
    Then sistem menampilkan hasil yang konsisten yaitu pembatalan berhasil atau pesan batas panjang
    And sistem tidak menampilkan pesan error sistem

  @stress @priority-medium @REQ-045 @UI-D04 @screen-pop-up-batalkan-order
  Scenario: OMS015-STR-023 Klik konfirmasi pembatalan dua kali secara cepat
    Given user login sebagai "Admin Shipper"
    And user membuka dialog "Batalkan Order" untuk order LTL "ORD-LTL-0001" berstatus "Menunggu Penugasan"
    When user mengisi field "Alasan Pembatalan" dengan "Dibatalkan customer"
    And user mengklik tombol "Konfirmasi" dua kali dalam 200 ms
    Then sistem mencatat tepat 1 entri pada "Riwayat Pembatalan" untuk order "ORD-LTL-0001"
    And sistem menampilkan badge status "Dibatalkan" pada baris "ORD-LTL-0001"

  @stress @priority-low @REQ-050 @UI-D05 @screen-riwayat-pembatalan
  Scenario: OMS015-STR-024 Riwayat Pembatalan dengan 1.000 entri
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat 1000 order berstatus "Dibatalkan"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Riwayat Pembatalan"
    Then sistem menampilkan daftar "Riwayat Pembatalan" dalam waktu kurang dari 10 detik
    And sistem menampilkan kontrol paginasi
    And sistem tidak menampilkan pesan error sistem

  @stress @priority-low @REQ-048 @UI-103 @screen-daftar-order
  Scenario: OMS015-STR-025 Membuka action menu pada 30 baris berturut-turut
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Daftar Order" dengan 30 baris order
    When user membuka action menu pada setiap baris secara berurutan
    Then sistem menampilkan tepat 1 action menu terbuka pada satu waktu
    And sistem menampilkan isi menu sesuai status masing-masing baris
    And sistem tidak menampilkan pesan error sistem

  @stress @priority-medium @REQ-056 @UI-104 @screen-pop-up-data-no-resi
  Scenario: OMS015-STR-026 Dialog Data No. Resi dengan 200 baris barang
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat order LTL berstatus "Menunggu Penugasan" dengan 200 barang
    When user membuka dialog "Data No. Resi" untuk order tersebut
    Then sistem menampilkan 200 baris pada tabel "Data No. Resi" dalam waktu kurang dari 15 detik
    And sistem tidak menampilkan pesan error sistem

  @stress @priority-low @REQ-057 @UI-104 @screen-pop-up-data-no-resi
  Scenario: OMS015-STR-027 Klik ikon copy 50 kali berturut-turut
    Given user login sebagai "Staff Operasional (Shipper)"
    And user membuka dialog "Data No. Resi" untuk order LTL dengan 7 barang
    When user mengklik tombol "Salin" pada baris 1 sebanyak 50 kali
    Then isi clipboard sama dengan No. Resi pada baris 1
    And sistem tidak menampilkan pesan error sistem
    And sistem menampilkan dialog "Data No. Resi" tetap terbuka

  @stress @priority-low @REQ-052 @UI-D08 @screen-public-tracking
  Scenario: OMS015-STR-028 Seratus permintaan public tracking secara paralel
    Given terdapat 100 No. Resi valid pada sistem
    When 100 permintaan tracking dikirim secara paralel ke halaman "Public Tracking"
    Then seluruh permintaan mengembalikan progress pengiriman yang benar
    And tidak ada permintaan yang mengembalikan error sistem

  @stress @priority-low @REQ-048 @UI-096 @screen-daftar-order
  Scenario: OMS015-STR-029 Daftar Order dengan 10.000 data dan paginasi
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat 10000 order pada tenant
    When user berada di halaman "Daftar Order"
    Then sistem menampilkan "Menampilkan 1 - 20 data dari 10000 data"
    And sistem menampilkan halaman pertama dalam waktu kurang dari 10 detik
    When user mengklik halaman terakhir pada paginasi
    Then sistem menampilkan baris terakhir tanpa error

  @stress @priority-low @REQ-051 @UI-D06 @screen-riwayat-perubahan
  Scenario: OMS015-STR-030 Riwayat Perubahan dengan 500 entri
    Given user login sebagai "Staff Operasional (Shipper)"
    And terdapat order LTL "ORD-LTL-0001" dengan 500 entri perubahan
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada baris "ORD-LTL-0001"
    And user mengklik menu "Riwayat Perubahan"
    Then sistem menampilkan daftar "Riwayat Perubahan" dalam waktu kurang dari 10 detik
    And sistem menampilkan hanya entri milik order "ORD-LTL-0001"

  # ==========================================================================
  # BAGIAN 5 — SKENARIO NEGATIF TAMBAHAN (NEG-091 .. NEG-094)
  # Melengkapi aturan "tiap requirement minimal 1 positive + 1 negative"
  # untuk REQ-009, REQ-017, REQ-036, dan REQ-057.
  # ==========================================================================

  @negative @priority-high @REQ-009 @UI-097 @screen-buat-order-step1-ltl
  Scenario: OMS015-NEG-091 Memilih Kota Asal tidak mengosongkan Drop Point Asal yang sudah dipilih
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 1 Data Pengiriman (LTL)"
    When user memilih dropdown "Drop Point Asal" dengan "Gudang MSK Region 2"
    And user memilih dropdown "Kota Asal" dengan "Kota Padangsidempuan"
    Then sistem menampilkan nilai "Gudang MSK Region 2" pada field "Drop Point Asal"
    And sistem tidak mengosongkan field "Drop Point Asal"
    And sistem tidak menampilkan pesan error kombinasi kota dan drop point
    And sistem tidak menampilkan nilai terhapus pada field "Alamat Asal"

  @negative @priority-medium @REQ-017 @UI-D01 @screen-modal-pilih-barang
  Scenario: OMS015-NEG-092 Counter tidak bertambah untuk barang berlabel Sudah Ditambahkan yang tidak dicentang
    Given user login sebagai "Staff Operasional (Shipper)"
    And user berada di halaman "Buat Order — Step 2 Data Barang" dengan barang "SKU-PPR-001" sudah ditambahkan
    When user mengklik tombol "Pilih Barang"
    Then sistem menampilkan "Sudah Ditambahkan" pada baris "SKU-PPR-001"
    And sistem menampilkan counter barang terpilih bernilai "0" atau counter tidak dirender
    When user mencentang checkbox "SKU-BKU-001"
    Then sistem menampilkan "1 barang terpilih"
    And sistem tidak menampilkan "2 barang terpilih"

  @negative @priority-medium @REQ-036 @UI-100 @screen-buat-order-step4
  Scenario: OMS015-NEG-093 Barang tanpa asuransi tidak menampilkan nominal Nilai Barang pada Review
    Given user login sebagai "Staff Operasional (Shipper)"
    And user membuat order LTL dengan barang "SKU-PPR-002" tanpa asuransi
    And user berada di halaman "Buat Order — Step 4 Review"
    Then sistem menampilkan "Tanpa Asuransi" pada baris "SKU-PPR-002"
    And sistem tidak menampilkan nominal "Rp" pada kolom "Nilai Barang" baris "SKU-PPR-002"
    And sistem tidak menampilkan kolom "Asuransi" berupa checkbox pada tabel "Data Barang"

  @negative @priority-medium @REQ-057 @UI-104 @screen-pop-up-data-no-resi
  Scenario: OMS015-NEG-094 Ikon copy hanya menyalin No. Resi dan tidak mengubah isi tabel
    Given user login sebagai "Staff Operasional (Shipper)"
    And user membuka dialog "Data No. Resi" untuk order LTL dengan 7 barang
    When user mengklik tombol "Salin" pada baris 1
    Then isi clipboard sama dengan No. Resi pada baris 1
    And isi clipboard tidak memuat "Kode SKU" pada baris 1
    And isi clipboard tidak memuat "Nama Barang" pada baris 1
    And sistem menampilkan 7 baris pada tabel "Data No. Resi"
    And sistem tidak menghapus baris manapun pada tabel "Data No. Resi"
