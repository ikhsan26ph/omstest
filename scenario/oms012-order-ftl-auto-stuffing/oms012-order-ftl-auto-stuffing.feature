# =============================================================================
# Feature  : OMS-012 — Order FTL dengan Add-on Auto Stuffing
# Tahap    : 2/4 — scenario-generator
# Sumber   : output/oms012-order-ftl-auto-stuffing/oms012-order-ftl-auto-stuffing.analysis.md
# Cakupan  : REQ-001 s.d. REQ-078 · UI-00 s.d. UI-19
# Catatan  : Keyword Gherkin tetap bahasa Inggris (Feature/Scenario/Given/When/Then/And),
#            isi langkah berbahasa Indonesia — JANGAN menambahkan '# language: id'.
#            Angka pada testData bersifat TERKONTROL (bukan salinan mockup) — ASM-041.
#            Auto Stuffing bersifat eksplisit-triggered (ASM-010).
#            Assertion status memakai matcher toleran (ASM-027).
#            Basis asuransi: Nilai Barang = nilai total baris (ASM-012).
# Bagian   : PART 1/4 — Skenario POSITIVE OMS012-POS-001 s.d. OMS012-POS-055
# =============================================================================

Feature: OMS-012 Order FTL dengan Add-on Auto Stuffing
  Sebagai Shipper pengguna Order Management System dengan add-on Auto Stuffing,
  saya ingin membuat, mengelola, dan mengoptimasi penempatan muatan Order FTL,
  agar kebutuhan armada terhitung optimal dan order dapat diproses sampai selesai.

  # ---------------------------------------------------------------------------
  # KATEGORI: POSITIVE
  # ---------------------------------------------------------------------------

  @positive @priority-high @REQ-001 @screen-step-1-data-pengiriman
  Scenario: OMS012-POS-001 - Satuan unit order FTL ditampilkan sebagai Armada
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    And add-on Auto Stuffing aktif pada tenant
    When user memilih "Jenis Pengiriman" dengan "FTL"
    And user memilih "Jenis Armada" dengan "Tronton Box"
    And user mengisi field "Jumlah Armada" dengan "2"
    Then sistem menampilkan "Jenis Armada"
    And sistem menampilkan "Jumlah Armada"
    And sistem tidak menampilkan "Jumlah Kontainer"

  @positive @priority-high @REQ-002 @screen-step-1-data-pengiriman
  Scenario: OMS012-POS-002 - Stepper menampilkan empat langkah wizard
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    Then sistem menampilkan "01 Data Pengiriman"
    And sistem menampilkan "02 Data Barang"
    And sistem menampilkan "03 Vendor dan Harga"
    And sistem menampilkan "04 Review"
    And sistem menampilkan "step 01 dalam keadaan aktif"

  @positive @priority-high @REQ-002 @screen-step-2-data-barang
  Scenario: OMS012-POS-003 - Navigasi maju dan mundur antar step mempertahankan data
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And user telah mengisi seluruh field wajib Step 1
    When user mengklik tombol "Sebelumnya"
    Then user diarahkan ke halaman "Buat Order - Step 1 Data Pengiriman"
    And sistem menampilkan "Tronton Box"
    When user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 2 Data Barang"
    And sistem menampilkan "SKU-PPR-001"

  @positive @priority-medium @REQ-003 @screen-daftar-order
  Scenario: OMS012-POS-004 - Entry point Buat Order dan Batch Order tersedia
    Given user berada di halaman "Daftar Order"
    Then sistem menampilkan "Buat Order"
    And sistem menampilkan "Batch Order"
    When user mengklik tombol "Buat Order"
    Then user diarahkan ke halaman "Buat Order - Step 1 Data Pengiriman"

  @positive @priority-medium @REQ-003 @screen-batch-order
  Scenario: OMS012-POS-005 - Order hasil batch muncul di Daftar Order
    Given user berada di halaman "Daftar Order"
    When user mengklik tombol "Batch Order"
    And user mengunggah berkas "batch-order-ftl-3-baris.xlsx"
    And user mengklik tombol "Simpan"
    Then sistem menampilkan "3 order berhasil dibuat"
    And user diarahkan ke halaman "Daftar Order"
    And sistem menampilkan "3 baris order baru pada tabel daftar order"

  @positive @priority-high @REQ-004 @screen-step-2-data-barang
  Scenario: OMS012-POS-006 - Penambahan barang hanya melalui tombol Pilih Barang
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    Then sistem menampilkan "Pilih Barang"
    And sistem menampilkan "Belum ada barang"
    And sistem tidak menampilkan "field input bebas Nama Barang"
    When user mengklik tombol "Pilih Barang"
    Then sistem menampilkan "Pilih barang yang ingin ditambahkan ke order"

  @positive @priority-high @REQ-005 @screen-step-2-data-barang
  Scenario: OMS012-POS-007 - Tenant dengan add-on menampilkan seluruh elemen Auto Stuffing
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And add-on Auto Stuffing aktif pada tenant
    Then sistem menampilkan "Hitung Ulang Armada"
    And sistem menampilkan "Visualisasi Terbaru"
    When user mengklik tombol "Selanjutnya"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 4 Review"
    And sistem menampilkan "Visualisasi Muatan"

  @positive @priority-high @REQ-006 @screen-step-2-data-barang
  Scenario: OMS012-POS-008 - Order FTL menampilkan elemen Auto Stuffing dengan istilah Armada
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user memilih "Jenis Pengiriman" dengan "FTL"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 2 Data Barang"
    And sistem menampilkan "Armada 1"
    And sistem menampilkan "Hitung Ulang Armada"

  @positive @priority-medium @REQ-006 @screen-step-2-data-barang
  Scenario: OMS012-POS-009 - Order FCL menampilkan elemen Auto Stuffing dengan istilah Kontainer
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user memilih "Jenis Pengiriman" dengan "FCL"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 2 Data Barang"
    And sistem menampilkan "Kontainer 1"
    And sistem menampilkan "Hitung Ulang Kontainer"

  @positive @priority-medium @REQ-007 @screen-drawer-hitung-ulang-armada
  Scenario: OMS012-POS-010 - Hitung Ulang dua kali berturut-turut menghasilkan rekomendasi identik
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And terdapat 1 baris barang "SKU-PPR-001" dengan Jumlah "200"
    When user mengklik tombol "Hitung Ulang Armada"
    Then sistem menampilkan "Paling Efisien"
    When user mengklik tombol "Batal"
    And user mengklik tombol "Hitung Ulang Armada"
    Then sistem menampilkan "rekomendasi armada yang sama persis dengan eksekusi sebelumnya"

  @positive @priority-high @REQ-008 @screen-step-4-review
  Scenario: OMS012-POS-011 - Tombol Visualisasi Muatan membuka pop up pada Step 4
    Given user berada di halaman "Buat Order - Step 4 Review"
    Then sistem menampilkan "Visualisasi Muatan"
    When user mengklik tombol "Visualisasi Muatan"
    Then sistem menampilkan "Visualisasi Muatan"
    And sistem menampilkan "Berat Terpakai"
    And sistem menampilkan "Ruang Terpakai"

  @positive @priority-high @REQ-009 @screen-step-1-data-pengiriman
  Scenario: OMS012-POS-012 - Field inti Step 1 tersedia lengkap
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    Then sistem menampilkan "Jenis Pengiriman dan Rute"
    And sistem menampilkan "Jenis Armada"
    And sistem menampilkan "Jumlah Armada"
    And sistem menampilkan "Tipe Pengiriman"
    And sistem menampilkan "Data Pengirim"
    And sistem menampilkan "Data Penerima"

  @positive @priority-high @REQ-010 @screen-step-1-data-pengiriman
  Scenario: OMS012-POS-013 - Dropdown Tipe Pengiriman memuat tepat empat opsi
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user mengklik tombol "Tipe Pengiriman"
    Then sistem menampilkan "Normal"
    And sistem menampilkan "Multipickup"
    And sistem menampilkan "Multidrop"
    And sistem menampilkan "Multipoint"
    And sistem menampilkan "tepat 4 opsi pada dropdown Tipe Pengiriman"

  @positive @priority-high @REQ-011 @screen-step-1-data-pengiriman
  Scenario: OMS012-POS-014 - Drop Point Asal mengisi otomatis data wilayah asal
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user memilih "Drop Point Asal" dengan "Gudang MSK Region 2"
    Then sistem menampilkan "Jawa Timur"
    And sistem menampilkan "Kota Surabaya"
    And sistem menampilkan "Wonokromo"
    And sistem menampilkan "60241"
    And sistem menampilkan "field Provinsi Asal dalam keadaan read-only"

  @positive @priority-high @REQ-011 @screen-step-1-data-pengiriman
  Scenario: OMS012-POS-015 - Mengganti Drop Point Tujuan memperbarui seluruh field turunan
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    And user telah memilih "Drop Point Tujuan" dengan "Gudang Jaya Retail Malang"
    When user memilih "Drop Point Tujuan" dengan "Gudang Sentra Kediri"
    Then sistem menampilkan "Kota Kediri"
    And sistem tidak menampilkan "Kota Malang"

  @positive @priority-medium @REQ-012 @screen-step-1-data-pengiriman
  Scenario: OMS012-POS-016 - Rule cascading wilayah berjalan sesuai urutan induk-turunan
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    Then sistem menampilkan "field Kota/Kab. Asal dalam keadaan kosong dan tidak dapat diisi"
    When user memilih "Drop Point Asal" dengan "Gudang MSK Region 2"
    Then sistem menampilkan "Kota Surabaya"
    And sistem menampilkan "Alamat Asal terisi otomatis"

  @positive @priority-high @REQ-013 @screen-step-1-data-pengiriman
  Scenario: OMS012-POS-017 - Multipickup merender minimal dua blok Pick Up
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user memilih "Tipe Pengiriman" dengan "Multipickup"
    Then sistem menampilkan "Pick Up 1"
    And sistem menampilkan "Tambah Baris Input"
    When user mengklik tombol "Tambah Baris Input"
    Then sistem menampilkan "Pick Up 2"
    And sistem menampilkan "satu blok Data Penerima"

  @positive @priority-high @REQ-013 @screen-step-1-data-pengiriman
  Scenario: OMS012-POS-018 - Multidrop merender minimal dua blok Drop Off
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user memilih "Tipe Pengiriman" dengan "Multidrop"
    And user mengklik tombol "Tambah Baris Input"
    Then sistem menampilkan "Drop Off 1"
    And sistem menampilkan "Drop Off 2"
    And sistem menampilkan "satu blok Data Pengirim"

  @positive @priority-high @REQ-013 @screen-step-1-data-pengiriman
  Scenario: OMS012-POS-019 - Multipoint merender blok pengirim dan penerima berulang
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user memilih "Tipe Pengiriman" dengan "Multipoint"
    And user mengklik tombol "Tambah Baris Input"
    Then sistem menampilkan "Pick Up 1"
    And sistem menampilkan "Pick Up 2"
    And sistem menampilkan "Drop Off 1"
    And sistem menampilkan "Drop Off 2"

  @positive @priority-high @REQ-014 @screen-step-1-data-pengiriman
  Scenario: OMS012-POS-020 - Pesan validasi hilang setelah field wajib diperbaiki
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    And user telah mengosongkan field "PIC Pengirim"
    When user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "PIC Pengirim harus diisi"
    When user mengisi field "PIC Pengirim" dengan "Budi Santoso"
    Then sistem tidak menampilkan "PIC Pengirim harus diisi"
    When user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 2 Data Barang"

  @positive @priority-high @REQ-015 @screen-step-1-data-pengiriman
  Scenario: OMS012-POS-021 - Simpan ke Draf pada Step 1 menghasilkan status Isi Data Pengiriman
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    And user telah mengisi seluruh field wajib Step 1
    When user mengklik tombol "Simpan ke Draf"
    Then sistem menampilkan "Anda yakin ingin menyimpan data dalam draf?"
    When user mengklik tombol "Simpan Draf"
    Then user diarahkan ke halaman "Daftar Order"
    And sistem menampilkan "Isi Data Pengiriman"

  @positive @priority-high @REQ-015 @screen-step-1-data-pengiriman
  Scenario: OMS012-POS-022 - Selanjutnya memvalidasi Step 1 lalu berpindah ke Step 2
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user memilih "Jenis Armada" dengan "Tronton Box"
    And user mengisi field "Jumlah Armada" dengan "2"
    And user memilih "Tipe Pengiriman" dengan "Normal"
    And user memilih "Drop Point Asal" dengan "Gudang MSK Region 2"
    And user memilih "Pengirim" dengan "PT Mentari Sumber Kertas"
    And user mengisi field "PIC Pengirim" dengan "Budi Santoso"
    And user mengisi field "No. WhatsApp PIC" dengan "081234567898"
    And user memilih "Drop Point Tujuan" dengan "Gudang Jaya Retail Malang"
    And user memilih "Penerima" dengan "PT Jaya Retail"
    And user mengisi field "PIC Penerima" dengan "Rina Dewi"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 2 Data Barang"

  @positive @priority-high @REQ-016 @screen-modal-pilih-barang
  Scenario: OMS012-POS-023 - Tombol Pilih Barang membuka modal Master Barang
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    When user mengklik tombol "Pilih Barang"
    Then sistem menampilkan "Pilih Barang"
    And sistem menampilkan "Pilih barang yang ingin ditambahkan ke order"
    And sistem menampilkan "Cari kode/nama barang"
    And sistem menampilkan "SKU-PPR-001 - Kertas HVS A4 80 gsm"

  @positive @priority-high @REQ-017 @screen-modal-pilih-barang
  Scenario: OMS012-POS-024 - Pencarian by kode barang memfilter daftar
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And modal "Pilih Barang" dalam keadaan terbuka
    When user mengisi field "Cari kode/nama barang" dengan "SKU-BKU"
    Then sistem menampilkan "SKU-BKU-001"
    And sistem menampilkan "SKU-BKU-002"
    And sistem tidak menampilkan "SKU-PPR-001"

  @positive @priority-high @REQ-017 @screen-modal-pilih-barang
  Scenario: OMS012-POS-025 - Pencarian by nama barang bersifat partial dan case-insensitive
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And modal "Pilih Barang" dalam keadaan terbuka
    When user mengisi field "Cari kode/nama barang" dengan "kertas hvs"
    Then sistem menampilkan "Kertas HVS A4 80 gsm"
    And sistem menampilkan "Kertas HVS F4 70 gsm"
    And sistem tidak menampilkan "Pulpen Gel Hitam 0.5 mm"

  @positive @priority-high @REQ-018 @screen-modal-pilih-barang
  Scenario: OMS012-POS-026 - Multi-select beberapa barang dalam satu sesi modal
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And modal "Pilih Barang" dalam keadaan terbuka
    When user mencentang checkbox "SKU-PPR-001 - Kertas HVS A4 80 gsm"
    And user mencentang checkbox "SKU-BKU-002 - Buku Tulis Hard Cover A5"
    And user mencentang checkbox "SKU-ATK-001 - Pulpen Gel Hitam 0.5 mm"
    Then sistem menampilkan "3 barang terpilih"
    When user mengklik tombol "Simpan"
    Then sistem menampilkan "3 baris barang pada tabel Armada 1"

  @positive @priority-high @REQ-019 @screen-modal-pilih-barang
  Scenario: OMS012-POS-027 - Label Sudah Ditambahkan tampil pada barang yang sudah masuk armada
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And barang "SKU-PPR-002" sudah ditambahkan pada "Armada 1"
    When user mengklik tombol "Pilih Barang"
    Then sistem menampilkan "Sudah Ditambahkan"
    And sistem menampilkan "checkbox SKU-PPR-002 dalam keadaan tercentang"

  @positive @priority-medium @REQ-020 @screen-modal-pilih-barang
  Scenario: OMS012-POS-028 - Counter barang terpilih ter-update secara real time
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And modal "Pilih Barang" dalam keadaan terbuka
    When user mencentang checkbox "SKU-PPR-001 - Kertas HVS A4 80 gsm"
    Then sistem menampilkan "1 barang terpilih"
    When user mencentang checkbox "SKU-BKU-001 - Buku Tulis 38 Lembar"
    Then sistem menampilkan "2 barang terpilih"
    When user melepas centang checkbox "SKU-PPR-001 - Kertas HVS A4 80 gsm"
    Then sistem menampilkan "1 barang terpilih"

  @positive @priority-high @REQ-021 @screen-modal-pilih-barang
  Scenario: OMS012-POS-029 - Simpan menambahkan seluruh barang terpilih ke tabel armada
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And modal "Pilih Barang" dalam keadaan terbuka
    When user mencentang checkbox "SKU-PPR-001 - Kertas HVS A4 80 gsm"
    And user mencentang checkbox "SKU-BKU-002 - Buku Tulis Hard Cover A5"
    And user mengklik tombol "Simpan"
    Then sistem menampilkan "SKU-PPR-001"
    And sistem menampilkan "SKU-BKU-002"
    And sistem tidak menampilkan "Pilih barang yang ingin ditambahkan ke order"

  @positive @priority-high @REQ-021 @screen-modal-pilih-barang
  Scenario: OMS012-POS-030 - Batal menutup modal tanpa menambahkan barang
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And modal "Pilih Barang" dalam keadaan terbuka
    When user mencentang checkbox "SKU-ATK-001 - Pulpen Gel Hitam 0.5 mm"
    And user mengklik tombol "Batal"
    Then sistem tidak menampilkan "Pilih barang yang ingin ditambahkan ke order"
    And sistem menampilkan "Belum ada barang"

  @positive @priority-high @REQ-022 @screen-step-2-data-barang
  Scenario: OMS012-POS-031 - Enam field master barang terisi otomatis dan read-only
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And barang "SKU-PPR-001" sudah ditambahkan pada "Armada 1"
    Then sistem menampilkan "SKU-PPR-001"
    And sistem menampilkan "Kertas HVS A4 80 gsm"
    And sistem menampilkan "Dus"
    And sistem menampilkan "0,018 m³"
    And sistem menampilkan "31 × 22 × 26,4 cm"
    And sistem menampilkan "12,5 kg"
    And sistem menampilkan "seluruh sel tersebut dalam keadaan read-only"

  @positive @priority-high @REQ-023 @screen-step-2-data-barang
  Scenario: OMS012-POS-032 - Mengisi Jumlah memperbarui Total Kubikasi dan Total Berat
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And barang "SKU-PPR-001" sudah ditambahkan pada "Armada 1"
    When user mengisi field "Jumlah" dengan "100"
    Then sistem menampilkan "Total Kubikasi: 1,8"
    And sistem menampilkan "Total Berat: 1.250"

  @positive @priority-high @REQ-024 @screen-step-2-data-barang
  Scenario: OMS012-POS-033 - Mencentang asuransi memunculkan kolom Nilai Barang yang wajib
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And barang "SKU-PPR-001" sudah ditambahkan pada "Armada 1"
    Then sistem tidak menampilkan "Nilai Barang"
    When user mencentang checkbox "Tambahkan Asuransi"
    Then sistem menampilkan "Nilai Barang"
    And sistem menampilkan "Berlaku untuk seluruh barang pada armada ini"
    When user mengisi field "Nilai Barang" dengan "1320000"
    Then sistem menampilkan "Rp1.320.000"

  @positive @priority-high @REQ-025 @screen-step-2-data-barang
  Scenario: OMS012-POS-034 - Status asuransi per armada terbawa ke Step 3 dan Step 4
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And barang "SKU-PPR-001" sudah ditambahkan pada "Armada 1" dengan Jumlah "100"
    When user mencentang checkbox "Tambahkan Asuransi"
    And user mengisi field "Nilai Barang" dengan "1320000"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 3 Vendor dan Harga"
    When user mencentang checkbox "Gunakan komponen harga"
    Then sistem menampilkan "Asuransi"
    When user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 4 Review"
    And sistem menampilkan "Diasuransikan"

  @positive @priority-medium @REQ-026 @screen-step-2-data-barang
  Scenario: OMS012-POS-035 - Nomor DO dipisah koma menghasilkan tiga chip
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    When user mengisi field "Nomor DO" dengan "DO-A001, DO-B002, DO-C003"
    Then sistem menampilkan "DO-A001"
    And sistem menampilkan "DO-B002"
    And sistem menampilkan "DO-C003"
    And sistem menampilkan "3 chip Nomor DO"

  @positive @priority-medium @REQ-026 @screen-step-2-data-barang
  Scenario: OMS012-POS-036 - Chip Nomor DO dapat dihapus secara individual
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And field "Nomor DO" berisi chip "DO-A001, DO-B002, DO-C003"
    When user mengklik tombol "Hapus chip DO-B002"
    Then sistem tidak menampilkan "DO-B002"
    And sistem menampilkan "DO-A001"
    And sistem menampilkan "DO-C003"

  @positive @priority-medium @REQ-027 @screen-step-2-data-barang
  Scenario: OMS012-POS-037 - Icon hapus menghapus satu baris dan total ter-update
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And "Armada 1" berisi barang "SKU-PPR-001" Jumlah "100" dan "SKU-BKU-002" Jumlah "100"
    Then sistem menampilkan "Total Kubikasi: 6"
    When user mengklik tombol "Hapus baris SKU-BKU-002"
    Then sistem tidak menampilkan "SKU-BKU-002"
    And sistem menampilkan "SKU-PPR-001"
    And sistem menampilkan "Total Kubikasi: 1,8"

  @positive @priority-high @REQ-028 @screen-step-2-data-barang
  Scenario: OMS012-POS-038 - Alert kapasitas tidak memblokir navigasi Selanjutnya
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And "Armada 1" memakai jenis armada "Tronton Box" berkapasitas "20.000 kg / 60 m³"
    When user mengisi field "Jumlah" dengan "4000"
    Then sistem menampilkan "Kubikasi melebihi kapasitas armada"
    And sistem menampilkan "tombol Selanjutnya dalam keadaan aktif"
    When user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 3 Vendor dan Harga"

  @positive @priority-high @REQ-029 @screen-step-2-data-barang
  Scenario: OMS012-POS-039 - Pesan alert saat hanya kubikasi melebihi kapasitas
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And "Armada 1" memakai jenis armada "Tronton Box" berkapasitas "20.000 kg / 60 m³"
    And "Armada 1" berisi barang "SKU-ATK-001" dengan kubikasi satuan "0,035 m³" dan berat satuan "9,5 kg"
    When user mengisi field "Jumlah" dengan "1800"
    Then sistem menampilkan "Kubikasi melebihi kapasitas armada"
    And sistem tidak menampilkan "Berat melebihi kapasitas armada"

  @positive @priority-high @REQ-029 @screen-step-2-data-barang
  Scenario: OMS012-POS-040 - Pesan alert saat hanya berat melebihi kapasitas
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And "Armada 1" memakai jenis armada "Tronton Box" berkapasitas "20.000 kg / 60 m³"
    And "Armada 1" berisi barang "SKU-PPR-001" dengan kubikasi satuan "0,018 m³" dan berat satuan "12,5 kg"
    When user mengisi field "Jumlah" dengan "2000"
    Then sistem menampilkan "Berat melebihi kapasitas armada"
    And sistem tidak menampilkan "Kubikasi melebihi kapasitas armada"

  @positive @priority-high @REQ-029 @screen-step-2-data-barang
  Scenario: OMS012-POS-041 - Pesan gabungan saat kubikasi dan berat melebihi kapasitas
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And "Armada 1" memakai jenis armada "Tronton Box" berkapasitas "20.000 kg / 60 m³"
    And "Armada 1" berisi barang "SKU-BKU-002" dengan kubikasi satuan "0,042 m³" dan berat satuan "13,2 kg"
    When user mengisi field "Jumlah" dengan "2000"
    Then sistem menampilkan "Kubikasi dan Berat melebihi kapasitas armada"
    And sistem menampilkan "tepat satu chip alert kapasitas pada Armada 1"

  @positive @priority-high @REQ-030 @screen-step-2-data-barang
  Scenario: OMS012-POS-042 - Helper error hilang setelah Jumlah diisi valid
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And barang "SKU-PPR-001" sudah ditambahkan pada "Armada 1" tanpa Jumlah
    When user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Jumlah harus diisi"
    And sistem menampilkan "border field Jumlah berwarna error"
    When user mengisi field "Jumlah" dengan "50"
    Then sistem tidak menampilkan "Jumlah harus diisi"
    And sistem menampilkan "border field Jumlah kembali normal"

  @positive @priority-medium @REQ-031 @screen-step-2-data-barang
  Scenario: OMS012-POS-043 - Card Data Unit menampilkan Jenis dan Jumlah Armada dari Step 1
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user memilih "Jenis Armada" dengan "Tronton Box"
    And user mengisi field "Jumlah Armada" dengan "2"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 2 Data Barang"
    And sistem menampilkan "Tronton Box"
    And sistem menampilkan "Jumlah Armada"
    And sistem menampilkan "2 blok Armada"

  @positive @priority-high @REQ-032 @screen-step-2-data-barang
  Scenario: OMS012-POS-044 - Simpan ke Draf pada Step 2 menghasilkan status Isi Data Muatan
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And "Armada 1" berisi barang "SKU-PPR-001" Jumlah "100"
    When user mengklik tombol "Simpan ke Draf"
    And user mengklik tombol "Simpan Draf"
    Then user diarahkan ke halaman "Daftar Order"
    And sistem menampilkan "Isi Data Muatan"

  @positive @priority-high @REQ-032 @screen-step-2-data-barang
  Scenario: OMS012-POS-045 - Sebelumnya kembali ke Step 1 dengan data utuh
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And "Armada 1" berisi barang "SKU-PPR-001" Jumlah "100"
    When user mengklik tombol "Sebelumnya"
    Then user diarahkan ke halaman "Buat Order - Step 1 Data Pengiriman"
    And sistem menampilkan "Tronton Box"
    And sistem menampilkan "Budi Santoso"

  @positive @priority-high @REQ-033 @screen-step-2-data-barang
  Scenario: OMS012-POS-046 - Dua floating button tampil dan membuka panel masing-masing
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And "Armada 1" berisi barang "SKU-PPR-001" Jumlah "100"
    When user mengklik tombol "Hitung Ulang Armada"
    Then sistem menampilkan "Hitung Ulang Armada"
    And sistem menampilkan "Simulasi ulang kebutuhan unit dari muatan order ini. Terapkan untuk ubah data order."
    When user mengklik tombol "Batal"
    And user mengklik tombol "Visualisasi Terbaru"
    Then sistem menampilkan "Visualisasi Muatan Saat Ini"

  @positive @priority-medium @REQ-034 @screen-step-2-data-barang
  Scenario: OMS012-POS-047 - Floating button tetap terlihat setelah halaman di-scroll
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And terdapat "5" blok armada pada Step 2
    When user menggulir halaman ke bagian paling bawah
    Then sistem menampilkan "Hitung Ulang Armada"
    And sistem menampilkan "Visualisasi Terbaru"
    And sistem menampilkan "tombol Selanjutnya tetap dapat diklik"

  @positive @priority-medium @REQ-035 @screen-step-2-data-barang
  Scenario: OMS012-POS-048 - Hover pada floating button menampilkan label
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    Then sistem menampilkan "floating button hanya berupa ikon"
    When user mengarahkan pointer ke tombol "Hitung Ulang Armada"
    Then sistem menampilkan "Hitung Ulang Armada"
    When user mengarahkan pointer ke tombol "Visualisasi Terbaru"
    Then sistem menampilkan "Visualisasi Terbaru"
    And sistem menampilkan "aria-label tetap tersedia untuk assistive technology"

  @positive @priority-high @REQ-036 @screen-step-2-data-barang
  Scenario: OMS012-POS-049 - Hitung Ulang Armada aktif setelah minimal satu barang terisi
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    Then sistem menampilkan "tombol Hitung Ulang Armada dalam keadaan nonaktif"
    When user mengklik tombol "Pilih Barang"
    And user mencentang checkbox "SKU-PPR-001 - Kertas HVS A4 80 gsm"
    And user mengklik tombol "Simpan"
    And user mengisi field "Jumlah" dengan "10"
    Then sistem menampilkan "tombol Hitung Ulang Armada dalam keadaan aktif"

  @positive @priority-high @REQ-037 @screen-step-2-data-barang
  Scenario: OMS012-POS-050 - Muatan yang muat satu armada ditempatkan seluruhnya di Armada 1
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And "Jumlah Armada" bernilai "2" dengan jenis armada "Tronton Box" berkapasitas "20.000 kg / 60 m³"
    And terdapat barang "SKU-PPR-001" dengan total Jumlah "500"
    When user mengklik tombol "Hitung Ulang Armada"
    And user mengklik tombol "Terapkan ke Order"
    Then sistem menampilkan "Armada 1 berisi 500 koli SKU-PPR-001"
    And sistem menampilkan "Belum ada barang"

  @positive @priority-high @REQ-037 @screen-step-2-data-barang
  Scenario: OMS012-POS-051 - Armada 1 terisi hingga kapasitas sebelum Armada 2 mulai terisi
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And "Jumlah Armada" bernilai "2" dengan jenis armada "Tronton Box" berkapasitas "20.000 kg / 60 m³"
    And terdapat barang "SKU-PPR-001" dengan total Jumlah "2000"
    When user mengklik tombol "Hitung Ulang Armada"
    And user mengklik tombol "Terapkan ke Order"
    Then sistem menampilkan "Armada 1 terisi hingga batas kapasitas"
    And sistem menampilkan "Armada 2 berisi sisa muatan"
    And sistem menampilkan "total Jumlah seluruh armada tetap 2000"

  @positive @priority-high @REQ-038 @screen-step-2-data-barang
  Scenario: OMS012-POS-052 - Pembagian habis sepuluh koli untuk dua alamat menjadi lima dan lima
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And order bertipe pengiriman "Multidrop" dengan 2 alamat penerima
    And terdapat barang "SKU-PPR-001" dengan total Jumlah "10" pada "Armada 1"
    When user mengklik tombol "Hitung Ulang Armada"
    And user mengklik tombol "Terapkan ke Order"
    Then sistem menampilkan "Drop Off 1 menerima 5 koli"
    And sistem menampilkan "Drop Off 2 menerima 5 koli"

  @positive @priority-high @REQ-038 @screen-step-2-data-barang
  Scenario: OMS012-POS-053 - Sisa pembagian yang lebih besar ditempatkan pada alamat pertama
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And order bertipe pengiriman "Multidrop" dengan 2 alamat penerima
    And terdapat barang "SKU-PPR-001" dengan total Jumlah "7" pada "Armada 1"
    When user mengklik tombol "Hitung Ulang Armada"
    And user mengklik tombol "Terapkan ke Order"
    Then sistem menampilkan "Drop Off 1 menerima 4 koli"
    And sistem menampilkan "Drop Off 2 menerima 3 koli"

  @positive @priority-high @REQ-039 @screen-drawer-hitung-ulang-armada
  Scenario: OMS012-POS-054 - Drawer menampilkan Total Kubikasi dan Total Berat dari data barang
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And "Armada 1" berisi barang "SKU-PPR-001" Jumlah "100" dan "SKU-BKU-002" Jumlah "100"
    When user mengklik tombol "Hitung Ulang Armada"
    Then sistem menampilkan "Total Kubikasi"
    And sistem menampilkan "6 m³"
    And sistem menampilkan "Total Berat"
    And sistem menampilkan "2.570 kg"

  @positive @priority-medium @REQ-040 @screen-drawer-hitung-ulang-armada
  Scenario: OMS012-POS-055 - Drawer menampilkan Jenis Pengiriman dari Step 1
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And order memiliki "Jenis Pengiriman" bernilai "FTL"
    When user mengklik tombol "Hitung Ulang Armada"
    Then sistem menampilkan "Jenis Pengiriman"
    And sistem menampilkan "FTL"
    And sistem menampilkan "field Jenis Pengiriman dalam keadaan read-only"
  # ---------------------------------------------------------------------------
  # PART 2/4 — lanjutan POSITIVE (OMS012-POS-056 s.d. OMS012-POS-109)
  # ---------------------------------------------------------------------------

  @positive @priority-high @REQ-041 @screen-drawer-hitung-ulang-armada
  Scenario: OMS012-POS-056 - Drawer menampilkan tiga kartu rekomendasi dengan badge Paling Efisien
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And "Armada 1" berisi barang "SKU-PPR-001" Jumlah "600"
    When user mengklik tombol "Hitung Ulang Armada"
    Then sistem menampilkan "3 kartu rekomendasi armada"
    And sistem menampilkan "Berat Terpakai"
    And sistem menampilkan "Ruang Terpakai"
    And sistem menampilkan "Paling Efisien"
    And sistem menampilkan "tepat satu badge Paling Efisien"

  @positive @priority-high @REQ-041 @screen-drawer-hitung-ulang-armada
  Scenario: OMS012-POS-057 - Memilih kartu rekomendasi mengisi Jenis dan Jumlah Armada pada drawer
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And drawer "Hitung Ulang Armada" dalam keadaan terbuka
    When user mengklik tombol "Kartu rekomendasi 3"
    Then sistem menampilkan "kartu rekomendasi 3 dalam keadaan terpilih"
    And sistem menampilkan "Jenis Armada"
    And sistem menampilkan "Jumlah Armada"

  @positive @priority-high @REQ-042 @screen-drawer-hitung-ulang-armada
  Scenario: OMS012-POS-058 - Mengubah Jenis Armada melalui modal Pilih Jenis Armada
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And drawer "Hitung Ulang Armada" dalam keadaan terbuka
    When user mengklik tombol "Pilih Jenis Armada"
    Then sistem menampilkan "Pilih Jenis Armada"
    When user memilih "Jenis Armada" dengan "Fuso Box"
    And user mengklik tombol "Simpan"
    Then sistem menampilkan "Fuso Box"
    And sistem menampilkan "Berat Maksimal 1 Armada"

  @positive @priority-high @REQ-042 @screen-drawer-hitung-ulang-armada
  Scenario: OMS012-POS-059 - Mengubah Jumlah Armada melalui stepper tambah dan kurang
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And drawer "Hitung Ulang Armada" dalam keadaan terbuka dengan "Jumlah Armada" bernilai "2"
    When user mengklik tombol "Tambah Jumlah Armada"
    Then sistem menampilkan "3"
    When user mengklik tombol "Kurang Jumlah Armada"
    Then sistem menampilkan "2"
    When user mengisi field "Jumlah Armada" dengan "5"
    Then sistem menampilkan "5"

  @positive @priority-high @REQ-043 @screen-drawer-hitung-ulang-armada
  Scenario: OMS012-POS-060 - Visualisasi 3D diperbarui saat Jumlah Armada diubah
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And drawer "Hitung Ulang Armada" dalam keadaan terbuka dengan "Jumlah Armada" bernilai "2"
    Then sistem menampilkan "Armada 1"
    And sistem menampilkan "Armada 2"
    When user mengisi field "Jumlah Armada" dengan "3"
    Then sistem menampilkan "Armada 3"
    And sistem menampilkan "3 tab visualisasi armada"
    And sistem menampilkan "Visualisasi Muatan"

  @positive @priority-high @REQ-044 @screen-drawer-hitung-ulang-armada
  Scenario: OMS012-POS-061 - Terapkan ke Order menerapkan armada dan penempatan barang
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And drawer "Hitung Ulang Armada" dalam keadaan terbuka
    When user mengklik tombol "Kartu rekomendasi 1"
    And user mengklik tombol "Terapkan ke Order"
    Then sistem tidak menampilkan "Simulasi ulang kebutuhan unit dari muatan order ini. Terapkan untuk ubah data order."
    And user diarahkan ke halaman "Buat Order - Step 2 Data Barang"
    And sistem menampilkan "hasil penempatan barang terbaru pada setiap armada"
    And sistem menampilkan "total Jumlah barang tidak berubah"

  @positive @priority-high @REQ-045 @screen-step-1-data-pengiriman
  Scenario: OMS012-POS-062 - Hasil Terapkan ke Order tercermin di Step 1 dan Data Unit Step 2
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And order memiliki "Jenis Armada" bernilai "Tronton Box" dan "Jumlah Armada" bernilai "2"
    When user mengklik tombol "Hitung Ulang Armada"
    And user memilih "Jenis Armada" dengan "Fuso Box"
    And user mengisi field "Jumlah Armada" dengan "3"
    And user mengklik tombol "Terapkan ke Order"
    Then sistem menampilkan "Fuso Box"
    And sistem menampilkan "3 blok Armada"
    When user mengklik tombol "Sebelumnya"
    Then user diarahkan ke halaman "Buat Order - Step 1 Data Pengiriman"
    And sistem menampilkan "Fuso Box"
    And sistem menampilkan "3"

  @positive @priority-high @REQ-046 @screen-drawer-hitung-ulang-armada
  Scenario: OMS012-POS-063 - Batal menutup drawer tanpa menerapkan perubahan
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And order memiliki "Jenis Armada" bernilai "Tronton Box" dan "Jumlah Armada" bernilai "2"
    When user mengklik tombol "Hitung Ulang Armada"
    And user memilih "Jenis Armada" dengan "Fuso Box"
    And user mengisi field "Jumlah Armada" dengan "4"
    And user mengklik tombol "Batal"
    Then sistem tidak menampilkan "Terapkan ke Order"
    And sistem menampilkan "Tronton Box"
    And sistem menampilkan "2 blok Armada"

  @positive @priority-high @REQ-047 @screen-panel-visualisasi-terbaru
  Scenario: OMS012-POS-064 - Panel Visualisasi Terbaru menampilkan armada terkini secara read-only
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And order memiliki "Jenis Armada" bernilai "Tronton Box" dan "Jumlah Armada" bernilai "2"
    When user mengklik tombol "Visualisasi Terbaru"
    Then sistem menampilkan "Visualisasi Muatan Saat Ini"
    And sistem menampilkan "Tronton Box"
    And sistem menampilkan "Jumlah Armada"
    And sistem tidak menampilkan "Paling Efisien"
    And sistem tidak menampilkan "Pilih Jenis Armada"

  @positive @priority-high @REQ-048 @screen-step-3-vendor-harga
  Scenario: OMS012-POS-065 - Mengisi Vendor, Tanggal Permintaan Muat, dan Harga
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    When user memilih "Vendor" dengan "PT Logistik Transportasi Nusantara"
    And user mengisi field "Tanggal Permintaan Muat" dengan "24/07/2026 14:30"
    And user mengisi field "Harga" dengan "12000000"
    Then sistem menampilkan "PT Logistik Transportasi Nusantara"
    And sistem menampilkan "Rp 12.000.000"
    And sistem menampilkan "Mencakup seluruh biaya armada pada order ini"

  @positive @priority-high @REQ-049 @screen-step-3-vendor-harga
  Scenario: OMS012-POS-066 - Waktu Perjalanan berupa textfield saat rute belum ada di master
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    And rute asal-tujuan belum terdaftar pada Master Waktu Perjalanan
    Then sistem menampilkan "Rute belum ada di Master Waktu Perjalanan. Isi waktu perjalanan, nilainya akan otomatis tersimpan sebagai data master baru."
    When user mengisi field "Waktu Perjalanan" dengan "8"
    Then sistem menampilkan "8"
    And sistem menampilkan "Jam"

  @positive @priority-high @REQ-049 @screen-step-3-vendor-harga
  Scenario: OMS012-POS-067 - Waktu Perjalanan berupa teks read-only saat rute sudah ada di master
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    And rute asal-tujuan sudah terdaftar pada Master Waktu Perjalanan dengan nilai "8 Jam"
    Then sistem menampilkan "Waktu Perjalanan"
    And sistem menampilkan "8 Jam"
    And sistem tidak menampilkan "Rute belum ada di Master Waktu Perjalanan"

  @positive @priority-medium @REQ-050 @screen-step-3-vendor-harga
  Scenario: OMS012-POS-068 - Ringkasan alamat tipe multi ditampilkan sebagai text link Lihat Detail
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    And order bertipe pengiriman "Multipickup" dengan 3 alamat pengirim
    Then sistem menampilkan "Multipickup"
    And sistem menampilkan "Lihat Detail"
    When user mengklik tombol "Lihat Detail"
    Then sistem menampilkan "Detail Multipickup"
    And sistem menampilkan "Pick Up 1 - Kota Surabaya"
    And sistem menampilkan "3 entri alamat"

  @positive @priority-medium @REQ-050 @screen-step-3-vendor-harga
  Scenario: OMS012-POS-069 - Tipe Normal menampilkan ringkasan alamat langsung tanpa text link
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    And order bertipe pengiriman "Normal"
    Then sistem menampilkan "Gudang MSK Region 2"
    And sistem menampilkan "Gudang Jaya Retail Malang"
    And sistem tidak menampilkan "Lihat Detail"

  @positive @priority-medium @REQ-051 @screen-step-3-vendor-harga
  Scenario: OMS012-POS-070 - Gunakan komponen harga memunculkan input PPN dan PPh
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    And user telah mengisi field "Harga" dengan "12000000"
    Then sistem menampilkan "checkbox Gunakan komponen harga dalam keadaan tidak tercentang"
    And sistem menampilkan "Total Harga"
    When user mencentang checkbox "Gunakan komponen harga"
    And user mengisi field "PPN" dengan "1,1"
    And user mengisi field "PPh" dengan "2"
    Then sistem menampilkan "PPN (1,1%)"
    And sistem menampilkan "PPh (2%)"
    And sistem menampilkan "Rp11.892.000"

  @positive @priority-high @REQ-052 @screen-step-3-vendor-harga
  Scenario: OMS012-POS-071 - Komponen Asuransi dihitung ke dalam Total Harga
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    And terdapat armada dengan "Tambahkan Asuransi" tercentang dan Total Nilai Barang "100.000.000"
    And user telah mengisi field "Harga" dengan "12000000"
    When user mencentang checkbox "Gunakan komponen harga"
    And user mengisi field "Asuransi" dengan "0,2"
    Then sistem menampilkan "Asuransi (0,2%)"
    And sistem menampilkan "Rp200.000"
    And sistem menampilkan "Total Nilai Barang = Rp100.000.000"

  @positive @priority-high @REQ-053 @screen-step-3-vendor-harga
  Scenario: OMS012-POS-072 - Simpan ke Draf pada Step 3 menghasilkan status Isi Data Vendor
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    And user telah mengisi seluruh field wajib Step 3
    When user mengklik tombol "Simpan ke Draf"
    And user mengklik tombol "Simpan Draf"
    Then user diarahkan ke halaman "Daftar Order"
    And sistem menampilkan "Isi Data Vendor"

  @positive @priority-high @REQ-054 @screen-step-4-review
  Scenario: OMS012-POS-073 - Step 4 menampilkan ringkasan Step 1 sampai Step 3 secara read-only
    Given user berada di halaman "Buat Order - Step 4 Review"
    Then sistem menampilkan "Jenis Pengiriman dan Rute"
    And sistem menampilkan "Data Pengirim"
    And sistem menampilkan "Data Penerima"
    And sistem menampilkan "Data Barang"
    And sistem menampilkan "Vendor dan Harga"
    And sistem menampilkan "seluruh field dalam keadaan read-only"

  @positive @priority-high @REQ-055 @screen-step-4-review
  Scenario: OMS012-POS-074 - Tabel Data Barang Step 4 mengikuti struktur Step 2
    Given user berada di halaman "Buat Order - Step 4 Review"
    And "Armada 1" berisi barang "SKU-PPR-001" Jumlah "100" tanpa asuransi
    Then sistem menampilkan "Kode SKU"
    And sistem menampilkan "Nama Barang"
    And sistem menampilkan "Kemasan"
    And sistem menampilkan "Kubikasi"
    And sistem menampilkan "Berat"
    And sistem menampilkan "Jumlah"
    And sistem menampilkan "isi tabel identik dengan hasil penempatan Step 2"

  @positive @priority-medium @REQ-056 @screen-step-4-review
  Scenario: OMS012-POS-075 - Badge Diasuransikan tampil pada armada yang diasuransikan
    Given user berada di halaman "Buat Order - Step 4 Review"
    And "Armada 2" memiliki "Tambahkan Asuransi" tercentang
    Then sistem menampilkan "Armada 2"
    And sistem menampilkan "Diasuransikan"
    And sistem menampilkan "Nilai Barang"

  @positive @priority-high @REQ-057 @screen-popup-visualisasi-muatan
  Scenario: OMS012-POS-076 - Pop up visualisasi muatan dapat ditutup tanpa mengubah data
    Given user berada di halaman "Buat Order - Step 4 Review"
    When user mengklik tombol "Visualisasi Muatan"
    Then sistem menampilkan "Visualisasi Muatan"
    And sistem menampilkan "Armada 1"
    And sistem menampilkan "dialokasikan ke unit ini"
    When user mengklik tombol "Tutup"
    Then sistem tidak menampilkan "dialokasikan ke unit ini"
    And user diarahkan ke halaman "Buat Order - Step 4 Review"
    And sistem menampilkan "data order tidak berubah"

  @positive @priority-high @REQ-058 @screen-step-4-review
  Scenario: OMS012-POS-077 - Simpan pada Step 4 mengubah status order menjadi Menunggu Penugasan
    Given user berada di halaman "Buat Order - Step 4 Review"
    And seluruh data Step 1 sampai Step 3 sudah lengkap
    When user mengklik tombol "Simpan"
    Then user diarahkan ke halaman "Daftar Order"
    And sistem menampilkan "Menunggu Penugasan"
    And sistem menampilkan "order baru pada baris pertama tabel"

  @positive @priority-high @REQ-058 @screen-step-4-review
  Scenario: OMS012-POS-078 - Simpan ke Draf pada Step 4 menghasilkan status Review Order
    Given user berada di halaman "Buat Order - Step 4 Review"
    When user mengklik tombol "Simpan ke Draf"
    And user mengklik tombol "Simpan Draf"
    Then user diarahkan ke halaman "Daftar Order"
    And sistem menampilkan "Review Order"

  @positive @priority-high @REQ-059 @screen-daftar-order
  Scenario: OMS012-POS-079 - Kolom Status menampilkan sembilan status Order FTL
    Given user berada di halaman "Daftar Order"
    When user mengklik tombol "Filter"
    And user mengklik tombol "Status"
    Then sistem menampilkan "Isi Data Pengiriman"
    And sistem menampilkan "Isi Data Muatan"
    And sistem menampilkan "Isi Data Vendor"
    And sistem menampilkan "Review Order"
    And sistem menampilkan "Menunggu Penugasan"
    And sistem menampilkan "Ditugaskan"
    And sistem menampilkan "Proses Pengiriman"
    And sistem menampilkan "Selesai"
    And sistem menampilkan "Dibatalkan"

  @positive @priority-high @REQ-060 @screen-daftar-order
  Scenario: OMS012-POS-080 - Lanjutkan Pengisian membuka wizard pada step terakhir dengan data ter-restore
    Given user berada di halaman "Daftar Order"
    And terdapat order draft berstatus "Isi Data Muatan" hasil Terapkan ke Order
    When user mengklik tombol "Aksi baris order"
    And user mengklik tombol "Lanjutkan Pengisian"
    Then user diarahkan ke halaman "Buat Order - Step 2 Data Barang"
    And sistem menampilkan "hasil penempatan Auto Stuffing yang tersimpan"
    And sistem menampilkan "SKU-PPR-001"

  @positive @priority-high @REQ-061 @screen-detail-order
  Scenario: OMS012-POS-081 - Edit Order tersedia pada status Menunggu Penugasan
    Given user berada di halaman "Detail Order"
    And order berstatus "Menunggu Penugasan"
    Then sistem menampilkan "Edit Order"
    When user mengklik tombol "Edit Order"
    Then user diarahkan ke halaman "Edit Order"
    And sistem menampilkan "Edit Order"

  @positive @priority-high @REQ-062 @screen-daftar-order
  Scenario: OMS012-POS-082 - Order berstatus Ditugaskan hanya dapat dilihat detailnya
    Given user berada di halaman "Daftar Order"
    And terdapat order berstatus "Ditugaskan"
    When user mengklik tombol "Aksi baris order"
    Then sistem menampilkan "Detail"
    And sistem menampilkan "Lihat No. Perjalanan"
    And sistem tidak menampilkan "Edit"

  @positive @priority-high @REQ-063 @screen-edit-order
  Scenario: OMS012-POS-083 - Jenis Pengiriman dan Tipe Pengiriman terkunci pada Edit Order
    Given user berada di halaman "Edit Order"
    Then sistem menampilkan "FTL (Full Truck Load)"
    And sistem menampilkan "Normal"
    And sistem menampilkan "field Jenis Pengiriman dalam keadaan read-only"
    And sistem menampilkan "field Tipe Pengiriman dalam keadaan read-only"

  @positive @priority-high @REQ-064 @screen-edit-order
  Scenario: OMS012-POS-084 - Jenis Armada, alamat, barang, dan vendor dapat diubah lalu tersimpan
    Given user berada di halaman "Edit Order"
    When user memilih "Jenis Armada" dengan "Fuso Box"
    And user mengisi field "Jumlah Armada" dengan "3"
    And user mengisi field "PIC Pengirim" dengan "Dewi Lestari"
    And user mengisi field "Harga" dengan "15000000"
    And user mengklik tombol "Simpan"
    And user mengklik tombol "Simpan"
    Then user diarahkan ke halaman "Detail Order"
    And sistem menampilkan "Fuso Box"
    And sistem menampilkan "Dewi Lestari"
    And sistem menampilkan "Rp15.000.000"

  @positive @priority-high @REQ-065 @screen-edit-order
  Scenario: OMS012-POS-085 - Simpan pada Edit Order menampilkan pop up konfirmasi
    Given user berada di halaman "Edit Order"
    And user telah mengubah field "Jumlah Armada" dengan "3"
    When user mengklik tombol "Simpan"
    Then sistem menampilkan "dialog konfirmasi penyimpanan perubahan"
    When user mengklik tombol "Simpan"
    Then user diarahkan ke halaman "Detail Order"
    And sistem menampilkan "3"

  @positive @priority-high @REQ-065 @screen-edit-order
  Scenario: OMS012-POS-086 - Batal pada Edit Order menampilkan pop up konfirmasi
    Given user berada di halaman "Edit Order"
    And user telah mengubah field "PIC Penerima" dengan "Rina Baru"
    When user mengklik tombol "Batal"
    Then sistem menampilkan "dialog konfirmasi pembatalan pengisian data"
    When user mengklik tombol "Batal"
    Then user diarahkan ke halaman "Edit Order"
    And sistem menampilkan "Rina Baru"

  @positive @priority-high @REQ-066 @screen-detail-order
  Scenario: OMS012-POS-087 - Batalkan Order berhasil pada status Menunggu Penugasan
    Given user berada di halaman "Detail Order"
    And user login sebagai "Admin Shipper"
    And order berstatus "Menunggu Penugasan"
    When user mengklik tombol "Batalkan Order"
    And user mengisi field "Alasan Pembatalan" dengan "Permintaan customer dibatalkan"
    And user mengklik tombol "Batalkan Order"
    Then sistem menampilkan "Dibatalkan"
    And sistem menampilkan "Permintaan customer dibatalkan"

  @positive @priority-high @REQ-067 @screen-modal-batalkan-order
  Scenario: OMS012-POS-088 - Admin shipper dapat mengakses dan mengeksekusi Batalkan Order
    Given user berada di halaman "Daftar Order"
    And user login sebagai "Admin Shipper"
    And terdapat order berstatus "Ditugaskan"
    When user mengklik tombol "Aksi baris order"
    Then sistem menampilkan "Batalkan Order"
    When user mengklik tombol "Batalkan Order"
    Then sistem menampilkan "Batalkan Order"
    And sistem menampilkan "Tuliskan alasan pembatalan order"

  @positive @priority-high @REQ-068 @screen-modal-batalkan-order
  Scenario: OMS012-POS-089 - Pembatalan diproses setelah Alasan Pembatalan diisi
    Given user berada di halaman "Detail Order"
    And modal "Batalkan Order" dalam keadaan terbuka
    Then sistem menampilkan "Alasan Pembatalan"
    When user mengisi field "Alasan Pembatalan" dengan "Stok barang tidak tersedia di gudang asal"
    And user mengklik tombol "Batalkan Order"
    Then sistem menampilkan "Dibatalkan"
    And sistem menampilkan "Stok barang tidak tersedia di gudang asal"

  @positive @priority-high @REQ-069 @screen-daftar-order
  Scenario: OMS012-POS-090 - Menu aksi status draft sesuai matriks
    Given user berada di halaman "Daftar Order"
    And terdapat order berstatus "Isi Data Muatan"
    When user mengklik tombol "Aksi baris order"
    Then sistem menampilkan "Detail"
    And sistem menampilkan "Lanjutkan Pengisian"
    And sistem menampilkan "Batalkan Order"
    And sistem menampilkan "Riwayat Perubahan"

  @positive @priority-high @REQ-069 @screen-daftar-order
  Scenario: OMS012-POS-091 - Menu aksi status Menunggu Penugasan sesuai matriks
    Given user berada di halaman "Daftar Order"
    And terdapat order berstatus "Menunggu Penugasan"
    When user mengklik tombol "Aksi baris order"
    Then sistem menampilkan "Detail"
    And sistem menampilkan "Edit"
    And sistem menampilkan "Batalkan Order"
    And sistem menampilkan "Riwayat Perubahan"
    And sistem tidak menampilkan "Lanjutkan Pengisian"

  @positive @priority-high @REQ-070 @screen-daftar-order
  Scenario: OMS012-POS-092 - Menu aksi status Ditugaskan memuat Lihat No. Perjalanan
    Given user berada di halaman "Daftar Order"
    And terdapat order berstatus "Ditugaskan"
    When user mengklik tombol "Aksi baris order"
    Then sistem menampilkan "Lihat No. Perjalanan"
    And sistem menampilkan "Detail"
    And sistem menampilkan "Riwayat Perubahan"
    And sistem tidak menampilkan "Edit"

  @positive @priority-medium @REQ-071 @screen-riwayat-pembatalan
  Scenario: OMS012-POS-093 - Riwayat Pembatalan pada toolbar menampilkan seluruh order yang dibatalkan
    Given user berada di halaman "Daftar Order"
    And terdapat 3 order berstatus "Dibatalkan"
    When user mengklik tombol "Riwayat Pembatalan"
    Then sistem menampilkan "Riwayat Pembatalan"
    And sistem menampilkan "3 baris order dibatalkan"
    And sistem menampilkan "Alasan Pembatalan"

  @positive @priority-medium @REQ-071 @screen-riwayat-perubahan
  Scenario: OMS012-POS-094 - Riwayat Perubahan pada baris menampilkan histori order tersebut
    Given user berada di halaman "Daftar Order"
    And terdapat order "ORD67890792" yang pernah diedit 2 kali
    When user mengklik tombol "Aksi baris order"
    And user mengklik tombol "Riwayat Perubahan"
    Then sistem menampilkan "ORD67890792"
    And sistem menampilkan "2 entri perubahan"

  @positive @priority-medium @REQ-072 @screen-public-tracking
  Scenario: OMS012-POS-095 - Public tracking dengan No. Perjalanan valid menampilkan progress
    Given user berada di halaman "Public Tracking"
    When user mengisi field "No. Perjalanan" dengan "TRC79289802"
    And user mengklik tombol "Lacak"
    Then sistem menampilkan "TRC79289802"
    And sistem menampilkan "progress perjalanan armada"

  @positive @priority-high @REQ-073 @screen-popup-no-perjalanan
  Scenario: OMS012-POS-096 - Jumlah No. Perjalanan sama dengan Jumlah Armada order
    Given user berada di halaman "Daftar Order"
    And terdapat order berstatus "Ditugaskan" dengan "Jumlah Armada" bernilai "2"
    When user mengklik tombol "Aksi baris order"
    And user mengklik tombol "Lihat No. Perjalanan"
    Then sistem menampilkan "Data No. Perjalanan"
    And sistem menampilkan "2 baris No. Perjalanan"
    And sistem menampilkan "nomor perjalanan yang unik pada setiap baris"

  @positive @priority-high @REQ-074 @screen-popup-no-perjalanan
  Scenario: OMS012-POS-097 - Order FTL menampilkan informasi No. Perjalanan
    Given user berada di halaman "Daftar Order"
    And terdapat order jenis "FTL" berstatus "Ditugaskan"
    When user mengklik tombol "Aksi baris order"
    And user mengklik tombol "Lihat No. Perjalanan"
    Then sistem menampilkan "FTL"
    And sistem menampilkan "TRC79289802"
    And sistem menampilkan "Jenis Armada"

  @positive @priority-high @REQ-075 @screen-daftar-order
  Scenario: OMS012-POS-098 - Aksi Lihat No. Perjalanan muncul setelah proses penugasan
    Given user berada di halaman "Daftar Order"
    And terdapat order berstatus "Menunggu Penugasan"
    When user mengklik tombol "Aksi baris order"
    Then sistem tidak menampilkan "Lihat No. Perjalanan"
    Given vendor telah melakukan penugasan sehingga order berstatus "Ditugaskan"
    When user mengklik tombol "Aksi baris order"
    Then sistem menampilkan "Lihat No. Perjalanan"

  @positive @priority-high @REQ-076 @screen-popup-no-perjalanan
  Scenario: OMS012-POS-099 - Pop up Data No. Perjalanan menampilkan data per armada
    Given user berada di halaman "Daftar Order"
    And pop up "Data No. Perjalanan" dalam keadaan terbuka untuk order 2 armada
    Then sistem menampilkan "Data No. Perjalanan"
    And sistem menampilkan "ID Order: ORD-20260607009"
    And sistem menampilkan "TRC79289802"
    And sistem menampilkan "L 1892 PGS"
    And sistem menampilkan "Fuso Box"

  @positive @priority-medium @REQ-077 @screen-popup-no-perjalanan
  Scenario: OMS012-POS-100 - Icon copy menyalin No. Perjalanan ke clipboard
    Given user berada di halaman "Daftar Order"
    And pop up "Data No. Perjalanan" dalam keadaan terbuka untuk order 2 armada
    When user mengklik tombol "Salin No. Perjalanan"
    Then sistem menampilkan "Tersalin"
    And sistem menampilkan "isi clipboard bernilai TRC79289802"

  @positive @priority-medium @REQ-078 @screen-detail-order
  Scenario: OMS012-POS-101 - Detail Order menampilkan No. Perjalanan untuk order yang sudah ditugaskan
    Given user berada di halaman "Detail Order"
    And order berstatus "Ditugaskan" dengan "Jumlah Armada" bernilai "2"
    Then sistem menampilkan "No. Perjalanan"
    And sistem menampilkan "TRC79289802"
    And sistem menampilkan "2 baris No. Perjalanan"

  @positive @priority-medium @REQ-069 @screen-panel-filter
  Scenario: OMS012-POS-102 - Filter Status menyaring Daftar Order
    Given user berada di halaman "Daftar Order"
    When user mengklik tombol "Filter"
    And user memilih "Status" dengan "Menunggu Penugasan"
    And user mengklik tombol "Terapkan"
    Then sistem menampilkan "Menunggu Penugasan"
    And sistem menampilkan "hanya baris berstatus Menunggu Penugasan"

  @positive @priority-low @REQ-069 @screen-panel-filter
  Scenario: OMS012-POS-103 - Reset filter mengembalikan daftar penuh
    Given user berada di halaman "Daftar Order"
    And panel "Filter" dalam keadaan terbuka dengan filter "Status" bernilai "Dibatalkan"
    When user mengklik tombol "Reset"
    Then sistem menampilkan "Pilih Status"
    When user mengklik tombol "Terapkan"
    Then sistem menampilkan "Menampilkan 1 - 20 data dari 30 data"

  @positive @priority-low @REQ-069 @screen-daftar-order
  Scenario: OMS012-POS-104 - Sort Total Harga dan paginasi berfungsi
    Given user berada di halaman "Daftar Order"
    When user mengklik tombol "Total Harga"
    Then sistem menampilkan "daftar terurut berdasarkan Total Harga"
    When user memilih "Tampilkan" dengan "20"
    And user mengklik tombol "2"
    Then sistem menampilkan "Menampilkan 21 - 30 data dari 30 data"

  @positive @priority-medium @REQ-060 @screen-popup-konfirmasi-draf
  Scenario: OMS012-POS-105 - Pop up konfirmasi Simpan Draf tampil pada setiap step
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    When user mengklik tombol "Simpan ke Draf"
    Then sistem menampilkan "Anda yakin ingin menyimpan data dalam draf?"
    And sistem menampilkan "Data yang telah diisi akan disimpan sebagai draf"
    When user mengklik tombol "Batal"
    Then sistem tidak menampilkan "Anda yakin ingin menyimpan data dalam draf?"
    And user diarahkan ke halaman "Buat Order - Step 3 Vendor dan Harga"

  @positive @priority-medium @REQ-026 @screen-step-2-data-barang
  Scenario: OMS012-POS-106 - Nomor DO tersedia per sub-section alamat pada tipe multi
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And order bertipe pengiriman "Multipickup" dengan 2 alamat pengirim
    Then sistem menampilkan "Pick Up 1"
    And sistem menampilkan "Pick Up 2"
    And sistem menampilkan "2 field Nomor DO pada Armada 1"
    When user mengisi field "Nomor DO Pick Up 1" dengan "DO-P1-001"
    Then sistem menampilkan "DO-P1-001"

  @positive @priority-high @REQ-038 @screen-step-2-data-barang
  Scenario: OMS012-POS-107 - Multipoint merender sub-section kartesian Pick Up kali Drop Off
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And order bertipe pengiriman "Multipoint" dengan 2 alamat pengirim dan 2 alamat penerima
    Then sistem menampilkan "4 sub-section alamat pada Armada 1"
    And sistem menampilkan "Pick Up 1"
    And sistem menampilkan "Drop Off 2"
    And sistem menampilkan "Tambahkan Asuransi"

  @positive @priority-high @REQ-057 @screen-detail-order
  Scenario: OMS012-POS-108 - Pop up Visualisasi Muatan dapat dibuka dari Detail Order
    Given user berada di halaman "Detail Order"
    Then sistem menampilkan "Visualisasi Muatan"
    When user mengklik tombol "Visualisasi Muatan"
    Then sistem menampilkan "Armada 1"
    And sistem menampilkan "Berat Terpakai"
    And sistem menampilkan "Drag: putar 360° • Scroll: zoom • Klik 2×: reset"

  @positive @priority-low @REQ-001 @screen-daftar-order
  Scenario: OMS012-POS-109 - Shell global dan breadcrumb tersedia pada halaman modul
    Given user berada di halaman "Daftar Order"
    Then sistem menampilkan "Mentari Sumber Kertas"
    And sistem menampilkan "Order"
    And sistem menampilkan "Kuota Order"
    And sistem menampilkan "Staff Operasional"
    And sistem menampilkan "Beranda > Daftar Order"
    When user mengklik tombol "Buat Order"
    Then sistem menampilkan "Beranda > Daftar Order > Buat Order"
  # ---------------------------------------------------------------------------
  # PART 3/4 — KATEGORI: NEGATIVE (OMS012-NEG-001 s.d. OMS012-NEG-088)
  # ---------------------------------------------------------------------------

  @negative @priority-medium @REQ-001 @screen-edit-order
  Scenario: OMS012-NEG-001 - Order FTL tidak boleh memakai istilah Kontainer pada card Data Barang
    Given user berada di halaman "Edit Order"
    And order berjenis "FTL" bertipe pengiriman "Multipickup"
    Then sistem menampilkan "Data Barang - Armada 1"
    And sistem tidak menampilkan "Data Barang - Kontainer 1"

  @negative @priority-high @REQ-002 @screen-step-1-data-pengiriman
  Scenario: OMS012-NEG-002 - Melompat ke Step 4 melalui stepper tanpa mengisi Step 1 ditolak
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    And seluruh field wajib Step 1 masih kosong
    When user mengklik tombol "04 Review"
    Then user diarahkan ke halaman "Buat Order - Step 1 Data Pengiriman"
    And sistem menampilkan "Lengkapi data pada step sebelumnya"

  @negative @priority-medium @REQ-003 @screen-batch-order
  Scenario: OMS012-NEG-003 - Batch Order dengan format berkas tidak didukung ditolak
    Given user berada di halaman "Batch Order"
    When user mengunggah berkas "batch-order.pdf"
    And user mengklik tombol "Simpan"
    Then sistem menampilkan "Format berkas tidak didukung"
    And sistem tidak menampilkan "order berhasil dibuat"

  @negative @priority-high @REQ-004 @screen-step-2-data-barang
  Scenario: OMS012-NEG-004 - Tidak tersedia input bebas untuk nama atau deskripsi barang
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    Then sistem tidak menampilkan "field input Nama Barang yang dapat diketik"
    And sistem tidak menampilkan "field input Deskripsi Barang"
    And sistem menampilkan "Pilih Barang"

  @negative @priority-high @REQ-005 @screen-step-2-data-barang
  Scenario: OMS012-NEG-005 - Tenant tanpa add-on tidak merender elemen Auto Stuffing
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And add-on Auto Stuffing tidak aktif pada tenant
    Then sistem tidak menampilkan "Hitung Ulang Armada"
    And sistem tidak menampilkan "Visualisasi Terbaru"
    When user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 3 Vendor dan Harga"

  @negative @priority-high @REQ-005 @screen-drawer-hitung-ulang-armada
  Scenario: OMS012-NEG-006 - Deep link drawer Auto Stuffing pada tenant tanpa add-on ditolak
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And add-on Auto Stuffing tidak aktif pada tenant
    When user membuka URL "/order/buat?step=2&panel=hitung-ulang-armada"
    Then sistem tidak menampilkan "Simulasi ulang kebutuhan unit dari muatan order ini. Terapkan untuk ubah data order."
    And sistem menampilkan "Fitur tidak tersedia"

  @negative @priority-high @REQ-006 @screen-step-2-data-barang
  Scenario: OMS012-NEG-007 - Order jenis LTL tidak menampilkan elemen Auto Stuffing
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user memilih "Jenis Pengiriman" dengan "LTL"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 2 Data Barang"
    And sistem tidak menampilkan "Hitung Ulang Armada"
    And sistem tidak menampilkan "Visualisasi Terbaru"

  @negative @priority-medium @REQ-007 @screen-drawer-hitung-ulang-armada
  Scenario: OMS012-NEG-008 - Rekomendasi tidak boleh berbeda untuk input yang identik
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And "Armada 1" berisi barang "SKU-PPR-001" Jumlah "600"
    When user mengklik tombol "Hitung Ulang Armada"
    And user mengklik tombol "Batal"
    And user mengklik tombol "Hitung Ulang Armada"
    Then sistem tidak menampilkan "urutan rekomendasi yang berbeda dari eksekusi sebelumnya"
    And sistem menampilkan "Paling Efisien"

  @negative @priority-high @REQ-008 @screen-step-4-review
  Scenario: OMS012-NEG-009 - Tombol Visualisasi Muatan tidak dirender tanpa add-on
    Given user berada di halaman "Buat Order - Step 4 Review"
    And add-on Auto Stuffing tidak aktif pada tenant
    Then sistem tidak menampilkan "Visualisasi Muatan"
    And sistem menampilkan "Data Barang"
    When user mengklik tombol "Simpan"
    Then user diarahkan ke halaman "Daftar Order"

  @negative @priority-high @REQ-009 @screen-step-1-data-pengiriman
  Scenario: OMS012-NEG-010 - Jumlah Armada bernilai nol ditolak
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user mengisi field "Jumlah Armada" dengan "0"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Jumlah Armada minimal 1"
    And user diarahkan ke halaman "Buat Order - Step 1 Data Pengiriman"

  @negative @priority-high @REQ-010 @screen-step-1-data-pengiriman
  Scenario: OMS012-NEG-011 - Tipe Pengiriman tidak memuat opsi di luar empat nilai valid
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user mengklik tombol "Tipe Pengiriman"
    Then sistem tidak menampilkan "Multipick"
    And sistem tidak menampilkan "Multi Drop"
    And sistem tidak menampilkan "Regular"

  @negative @priority-high @REQ-011 @screen-step-1-data-pengiriman
  Scenario: OMS012-NEG-012 - Field wilayah hasil auto-draft tidak dapat diedit manual
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    And user telah memilih "Drop Point Asal" dengan "Gudang MSK Region 2"
    When user mengisi field "Provinsi Asal" dengan "Jawa Barat"
    Then sistem menampilkan "Jawa Timur"
    And sistem tidak menampilkan "Jawa Barat"

  @negative @priority-medium @REQ-012 @screen-step-1-data-pengiriman
  Scenario: OMS012-NEG-013 - Field turunan tidak dapat diisi sebelum field induk terisi
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    And field "Drop Point Asal" masih kosong
    When user mengisi field "Kota/Kab. Asal" dengan "Kota Surabaya"
    Then sistem menampilkan "field Kota/Kab. Asal dalam keadaan kosong"
    And sistem tidak menampilkan "Kota Surabaya"

  @negative @priority-high @REQ-013 @screen-step-1-data-pengiriman
  Scenario: OMS012-NEG-014 - Multipickup dengan hanya satu alamat pengirim ditahan
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user memilih "Tipe Pengiriman" dengan "Multipickup"
    And user mengisi seluruh field wajib pada "Pick Up 1"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Minimal 2 alamat pengirim untuk tipe Multipickup"
    And user diarahkan ke halaman "Buat Order - Step 1 Data Pengiriman"

  @negative @priority-high @REQ-013 @screen-step-1-data-pengiriman
  Scenario: OMS012-NEG-015 - Menghapus Drop Off hingga tersisa satu pada Multidrop ditolak
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    And order bertipe pengiriman "Multidrop" dengan 2 blok "Drop Off"
    Then sistem tidak menampilkan "tombol hapus pada Drop Off 1"
    When user mengklik tombol "Hapus Drop Off 2"
    Then sistem menampilkan "Minimal 2 alamat penerima untuk tipe Multidrop"
    And sistem menampilkan "Drop Off 2"

  @negative @priority-high @REQ-014 @screen-step-1-data-pengiriman
  Scenario: OMS012-NEG-016 - Selanjutnya dengan field wajib kosong ditahan
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    And seluruh field wajib Step 1 masih kosong
    When user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Tipe Pengiriman harus diisi"
    And sistem menampilkan "Drop Point Asal harus diisi"
    And user diarahkan ke halaman "Buat Order - Step 1 Data Pengiriman"

  @negative @priority-high @REQ-015 @screen-step-1-data-pengiriman
  Scenario: OMS012-NEG-017 - Batal disertai konfirmasi tidak menyimpan order
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    And user telah mengisi seluruh field wajib Step 1
    When user mengklik tombol "Batal"
    And user mengklik tombol "Ya"
    Then user diarahkan ke halaman "Daftar Order"
    And sistem tidak menampilkan "order baru pada baris pertama tabel"

  @negative @priority-high @REQ-016 @screen-step-2-data-barang
  Scenario: OMS012-NEG-018 - Selanjutnya tanpa satu pun barang ditahan
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And seluruh armada belum berisi barang
    When user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Minimal 1 barang harus dipilih"
    And user diarahkan ke halaman "Buat Order - Step 2 Data Barang"

  @negative @priority-high @REQ-017 @screen-modal-pilih-barang
  Scenario: OMS012-NEG-019 - Pencarian tanpa hasil menampilkan empty state bukan error
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And modal "Pilih Barang" dalam keadaan terbuka
    When user mengisi field "Cari kode/nama barang" dengan "SKU-TIDAK-ADA-9999"
    Then sistem menampilkan "Barang tidak ditemukan"
    And sistem tidak menampilkan "Terjadi kesalahan"
    And sistem menampilkan "0 barang terpilih"

  @negative @priority-high @REQ-018 @screen-modal-pilih-barang
  Scenario: OMS012-NEG-020 - Simpan tanpa barang tercentang tidak menambahkan baris
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And modal "Pilih Barang" dalam keadaan terbuka tanpa item tercentang
    When user mengklik tombol "Simpan"
    Then sistem menampilkan "Belum ada barang"
    And sistem tidak menampilkan "SKU-PPR-001 pada tabel Armada 1"

  @negative @priority-high @REQ-019 @screen-modal-pilih-barang
  Scenario: OMS012-NEG-021 - SKU yang sudah ada tidak menghasilkan baris duplikat pada armada yang sama
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And barang "SKU-PPR-001" sudah ditambahkan pada "Armada 1"
    When user mengklik tombol "Pilih Barang"
    And user mengklik tombol "Simpan"
    Then sistem menampilkan "1 baris SKU-PPR-001 pada tabel Armada 1"
    And sistem tidak menampilkan "2 baris SKU-PPR-001 pada tabel Armada 1"

  @negative @priority-medium @REQ-020 @screen-modal-pilih-barang
  Scenario: OMS012-NEG-022 - Counter tidak boleh menyimpan nilai lama setelah modal ditutup via Batal
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And modal "Pilih Barang" dalam keadaan terbuka
    When user mencentang checkbox "SKU-ATK-001 - Pulpen Gel Hitam 0.5 mm"
    And user mengklik tombol "Batal"
    And user mengklik tombol "Pilih Barang"
    Then sistem tidak menampilkan "1 barang terpilih"
    And sistem menampilkan "0 barang terpilih"

  @negative @priority-high @REQ-021 @screen-modal-pilih-barang
  Scenario: OMS012-NEG-023 - Batal setelah mencentang tidak menambahkan barang ke armada
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And modal "Pilih Barang" dalam keadaan terbuka
    When user mencentang checkbox "SKU-BKU-002 - Buku Tulis Hard Cover A5"
    And user mengklik tombol "Batal"
    Then sistem tidak menampilkan "SKU-BKU-002"
    And sistem menampilkan "Belum ada barang"

  @negative @priority-high @REQ-022 @screen-step-2-data-barang
  Scenario: OMS012-NEG-024 - Field Berat dan Kubikasi tidak dapat diedit dari Step 2
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And barang "SKU-PPR-001" sudah ditambahkan pada "Armada 1"
    When user mengisi field "Berat" dengan "99"
    And user mengisi field "Kubikasi" dengan "9,9"
    Then sistem menampilkan "12,5 kg"
    And sistem menampilkan "0,018 m³"
    And sistem tidak menampilkan "99 kg"

  @negative @priority-high @REQ-023 @screen-step-2-data-barang
  Scenario: OMS012-NEG-025 - Jumlah kosong menahan navigasi dan memunculkan helper error
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And barang "SKU-PPR-001" sudah ditambahkan pada "Armada 1" tanpa Jumlah
    When user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Jumlah harus diisi"
    And sistem menampilkan "border field Jumlah berwarna error"
    And user diarahkan ke halaman "Buat Order - Step 2 Data Barang"

  @negative @priority-high @REQ-024 @screen-step-2-data-barang
  Scenario: OMS012-NEG-026 - Nilai Barang kosong saat asuransi aktif ditolak
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And barang "SKU-PPR-001" sudah ditambahkan pada "Armada 1" dengan Jumlah "100"
    When user mencentang checkbox "Tambahkan Asuransi"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Nilai Barang harus diisi"
    And sistem menampilkan "border field Nilai Barang berwarna error"
    And user diarahkan ke halaman "Buat Order - Step 2 Data Barang"

  @negative @priority-high @REQ-025 @screen-step-2-data-barang
  Scenario: OMS012-NEG-027 - Asuransi pada Armada 1 tidak memunculkan kolom Nilai Barang di Armada 2
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And terdapat 2 blok armada yang masing-masing berisi barang
    When user mencentang checkbox "Tambahkan Asuransi Armada 1"
    Then sistem menampilkan "kolom Nilai Barang pada tabel Armada 1"
    And sistem tidak menampilkan "kolom Nilai Barang pada tabel Armada 2"

  @negative @priority-medium @REQ-026 @screen-step-2-data-barang
  Scenario: OMS012-NEG-028 - Nomor DO kosong tidak boleh memblokir navigasi
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And "Armada 1" berisi barang "SKU-PPR-001" Jumlah "100" dengan "Nomor DO" kosong
    When user mengklik tombol "Selanjutnya"
    Then sistem tidak menampilkan "Nomor DO harus diisi"
    And user diarahkan ke halaman "Buat Order - Step 3 Vendor dan Harga"

  @negative @priority-medium @REQ-027 @screen-step-2-data-barang
  Scenario: OMS012-NEG-029 - Menghapus baris di Armada 1 tidak mempengaruhi Armada 2
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And "Armada 1" dan "Armada 2" sama-sama berisi barang "SKU-PPR-001"
    When user mengklik tombol "Hapus baris SKU-PPR-001 Armada 1"
    Then sistem menampilkan "Belum ada barang"
    And sistem menampilkan "SKU-PPR-001 pada tabel Armada 2"

  @negative @priority-high @REQ-028 @screen-step-2-data-barang
  Scenario: OMS012-NEG-030 - Alert kapasitas tidak boleh menonaktifkan tombol Selanjutnya
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And "Armada 1" melebihi kapasitas berat dan kubikasi
    Then sistem menampilkan "Kubikasi dan Berat melebihi kapasitas armada"
    And sistem tidak menampilkan "tombol Selanjutnya dalam keadaan nonaktif"
    When user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 3 Vendor dan Harga"

  @negative @priority-high @REQ-029 @screen-step-2-data-barang
  Scenario: OMS012-NEG-031 - Pelanggaran kubikasi dan berat tidak boleh dirender sebagai dua chip terpisah
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And "Armada 1" melebihi kapasitas berat dan kubikasi
    Then sistem menampilkan "Kubikasi dan Berat melebihi kapasitas armada"
    And sistem tidak menampilkan "2 chip alert kapasitas pada Armada 1"

  @negative @priority-high @REQ-030 @screen-step-2-data-barang
  Scenario: OMS012-NEG-032 - Jumlah diisi teks non-numerik ditolak
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And barang "SKU-PPR-001" sudah ditambahkan pada "Armada 1"
    When user mengisi field "Jumlah" dengan "seratus"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Jumlah harus diisi"
    And sistem tidak menampilkan "seratus"

  @negative @priority-medium @REQ-031 @screen-step-2-data-barang
  Scenario: OMS012-NEG-033 - Data Unit tidak boleh menampilkan nilai lama setelah Step 1 diubah
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And card "Data Unit" menampilkan "Tronton Box" dan "2"
    When user mengklik tombol "Sebelumnya"
    And user memilih "Jenis Armada" dengan "Fuso Box"
    And user mengisi field "Jumlah Armada" dengan "4"
    And user mengklik tombol "Selanjutnya"
    Then sistem tidak menampilkan "Tronton Box"
    And sistem menampilkan "Fuso Box"
    And sistem menampilkan "4 blok Armada"

  @negative @priority-high @REQ-032 @screen-step-2-data-barang
  Scenario: OMS012-NEG-034 - Selanjutnya ditahan bila terdapat baris barang dengan Jumlah kosong
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And "Armada 1" berisi barang "SKU-PPR-001" Jumlah "100" dan "SKU-BKU-002" tanpa Jumlah
    When user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Jumlah harus diisi"
    And user diarahkan ke halaman "Buat Order - Step 2 Data Barang"

  @negative @priority-medium @REQ-033 @screen-step-3-vendor-harga
  Scenario: OMS012-NEG-035 - Floating button Auto Stuffing tidak dirender di luar Step 2
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    Then sistem tidak menampilkan "Hitung Ulang Armada"
    And sistem tidak menampilkan "Visualisasi Terbaru"
    When user mengklik tombol "Sebelumnya"
    Then user diarahkan ke halaman "Buat Order - Step 2 Data Barang"
    And sistem menampilkan "Hitung Ulang Armada"

  @negative @priority-medium @REQ-034 @screen-step-2-data-barang
  Scenario: OMS012-NEG-036 - Floating button tidak boleh menutupi tombol aksi utama
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And terdapat "5" blok armada pada Step 2
    When user menggulir halaman ke bagian paling bawah
    And user mengklik tombol "Selanjutnya"
    Then sistem tidak menampilkan "klik tertahan oleh elemen floating"
    And user diarahkan ke halaman "Buat Order - Step 3 Vendor dan Harga"

  @negative @priority-medium @REQ-035 @screen-step-2-data-barang
  Scenario: OMS012-NEG-037 - Label floating button tidak boleh tetap tampil setelah pointer menjauh
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    When user mengarahkan pointer ke tombol "Hitung Ulang Armada"
    Then sistem menampilkan "Hitung Ulang Armada"
    When user memindahkan pointer keluar dari tombol "Hitung Ulang Armada"
    Then sistem tidak menampilkan "label teks Hitung Ulang Armada"
    And sistem menampilkan "ikon floating button"

  @negative @priority-high @REQ-036 @screen-step-2-data-barang
  Scenario: OMS012-NEG-038 - Hitung Ulang Armada tidak dapat dijalankan tanpa data barang
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And seluruh armada belum berisi barang
    When user mengklik tombol "Hitung Ulang Armada"
    Then sistem tidak menampilkan "Simulasi ulang kebutuhan unit dari muatan order ini. Terapkan untuk ubah data order."
    And sistem tidak menampilkan "Paling Efisien"
    And sistem menampilkan "tombol Hitung Ulang Armada dalam keadaan nonaktif"

  @negative @priority-high @REQ-037 @screen-step-2-data-barang
  Scenario: OMS012-NEG-039 - Total Jumlah barang tidak boleh berubah setelah distribusi Auto Stuffing
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And terdapat barang dengan total Jumlah "2000" sebelum distribusi
    When user mengklik tombol "Hitung Ulang Armada"
    And user mengklik tombol "Terapkan ke Order"
    Then sistem menampilkan "total Jumlah seluruh armada tetap 2000"
    And sistem tidak menampilkan "total Jumlah seluruh armada bernilai selain 2000"

  @negative @priority-high @REQ-038 @screen-step-2-data-barang
  Scenario: OMS012-NEG-040 - Sisa pembagian tidak boleh ditempatkan pada alamat terakhir
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And order bertipe pengiriman "Multidrop" dengan 2 alamat penerima
    And terdapat barang "SKU-PPR-001" dengan total Jumlah "7" pada "Armada 1"
    When user mengklik tombol "Hitung Ulang Armada"
    And user mengklik tombol "Terapkan ke Order"
    Then sistem tidak menampilkan "Drop Off 2 menerima 4 koli"
    And sistem menampilkan "Drop Off 1 menerima 4 koli"

  @negative @priority-high @REQ-039 @screen-drawer-hitung-ulang-armada
  Scenario: OMS012-NEG-041 - Total Kubikasi pada drawer tidak boleh memakai nilai basi
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And drawer "Hitung Ulang Armada" menampilkan "Total Kubikasi" bernilai "1,8 m³"
    When user mengklik tombol "Batal"
    And user mengisi field "Jumlah" dengan "200"
    And user mengklik tombol "Hitung Ulang Armada"
    Then sistem tidak menampilkan "1,8 m³"
    And sistem menampilkan "3,6 m³"

  @negative @priority-medium @REQ-040 @screen-drawer-hitung-ulang-armada
  Scenario: OMS012-NEG-042 - Jenis Pengiriman pada drawer tidak dapat diubah
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And drawer "Hitung Ulang Armada" dalam keadaan terbuka
    When user mengisi field "Jenis Pengiriman" dengan "FCL"
    Then sistem menampilkan "FTL"
    And sistem tidak menampilkan "FCL"

  @negative @priority-high @REQ-041 @screen-drawer-hitung-ulang-armada
  Scenario: OMS012-NEG-043 - Drawer tidak boleh menampilkan lebih dari tiga kartu atau lebih dari satu Paling Efisien
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And master armada memiliki 8 jenis armada relevan
    When user mengklik tombol "Hitung Ulang Armada"
    Then sistem tidak menampilkan "4 kartu rekomendasi armada"
    And sistem menampilkan "3 kartu rekomendasi armada"
    And sistem menampilkan "tepat satu badge Paling Efisien"

  @negative @priority-high @REQ-042 @screen-drawer-hitung-ulang-armada
  Scenario: OMS012-NEG-044 - Jumlah Armada pada drawer tidak dapat diturunkan di bawah satu
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And drawer "Hitung Ulang Armada" dalam keadaan terbuka dengan "Jumlah Armada" bernilai "1"
    When user mengisi field "Jumlah Armada" dengan "0"
    Then sistem menampilkan "Jumlah Armada minimal 1"
    And sistem tidak menampilkan "0 tab visualisasi armada"

  @negative @priority-high @REQ-043 @screen-drawer-hitung-ulang-armada
  Scenario: OMS012-NEG-045 - Visualisasi tidak boleh tetap memakai dimensi armada lama
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And drawer "Hitung Ulang Armada" menampilkan "Berat Maksimal 1 Armada" untuk "Tronton Box"
    When user mengklik tombol "Pilih Jenis Armada"
    And user memilih "Jenis Armada" dengan "Fuso Box"
    And user mengklik tombol "Simpan"
    Then sistem tidak menampilkan "kapasitas armada Tronton Box"
    And sistem menampilkan "Fuso Box"

  @negative @priority-high @REQ-044 @screen-drawer-hitung-ulang-armada
  Scenario: OMS012-NEG-046 - Terapkan ke Order tidak boleh menghilangkan barang dari order
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And terdapat 3 SKU berbeda dengan total Jumlah "1500"
    When user mengklik tombol "Hitung Ulang Armada"
    And user mengklik tombol "Terapkan ke Order"
    Then sistem menampilkan "3 SKU tetap ada pada order"
    And sistem tidak menampilkan "Belum ada barang"

  @negative @priority-high @REQ-045 @screen-step-1-data-pengiriman
  Scenario: OMS012-NEG-047 - Step 1 tidak boleh tetap menampilkan nilai armada lama setelah Terapkan
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And order memiliki "Jenis Armada" bernilai "Tronton Box" dan "Jumlah Armada" bernilai "2"
    When user mengklik tombol "Hitung Ulang Armada"
    And user memilih "Jenis Armada" dengan "Fuso Box"
    And user mengisi field "Jumlah Armada" dengan "3"
    And user mengklik tombol "Terapkan ke Order"
    And user mengklik tombol "Sebelumnya"
    Then sistem tidak menampilkan "Tronton Box"
    And sistem menampilkan "Fuso Box"

  @negative @priority-high @REQ-046 @screen-drawer-hitung-ulang-armada
  Scenario: OMS012-NEG-048 - Batal pada drawer tidak boleh mengubah Step 1 maupun Step 2
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And penempatan barang saat ini adalah "Armada 1 berisi 500 koli SKU-PPR-001"
    When user mengklik tombol "Hitung Ulang Armada"
    And user mengisi field "Jumlah Armada" dengan "5"
    And user mengklik tombol "Batal"
    Then sistem tidak menampilkan "5 blok Armada"
    And sistem menampilkan "Armada 1 berisi 500 koli SKU-PPR-001"

  @negative @priority-high @REQ-047 @screen-panel-visualisasi-terbaru
  Scenario: OMS012-NEG-049 - Panel Visualisasi Terbaru tidak boleh memuat tombol Terapkan ke Order
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    When user mengklik tombol "Visualisasi Terbaru"
    Then sistem menampilkan "Visualisasi Muatan Saat Ini"
    And sistem tidak menampilkan "Terapkan ke Order"

  @negative @priority-high @REQ-047 @screen-panel-visualisasi-terbaru
  Scenario: OMS012-NEG-050 - Panel Visualisasi Terbaru tidak boleh memuat rekomendasi dan pengubah armada
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    When user mengklik tombol "Visualisasi Terbaru"
    Then sistem tidak menampilkan "Paling Efisien"
    And sistem tidak menampilkan "Pilih Jenis Armada"
    And sistem tidak menampilkan "Tambah Jumlah Armada"
    When user mengklik tombol "Batal"
    Then sistem menampilkan "data order tidak berubah"

  @negative @priority-high @REQ-048 @screen-step-3-vendor-harga
  Scenario: OMS012-NEG-051 - Vendor kosong menahan navigasi ke Step 4
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    And field "Vendor" masih kosong
    When user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Vendor harus diisi"
    And user diarahkan ke halaman "Buat Order - Step 3 Vendor dan Harga"

  @negative @priority-high @REQ-049 @screen-step-3-vendor-harga
  Scenario: OMS012-NEG-052 - Waktu Perjalanan kosong saat rute belum ada di master ditolak
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    And rute asal-tujuan belum terdaftar pada Master Waktu Perjalanan
    When user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Waktu Perjalanan harus diisi"
    And user diarahkan ke halaman "Buat Order - Step 3 Vendor dan Harga"

  @negative @priority-high @REQ-049 @screen-step-3-vendor-harga
  Scenario: OMS012-NEG-053 - Waktu Perjalanan bertipe teks read-only tidak dapat diedit
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    And rute asal-tujuan sudah terdaftar pada Master Waktu Perjalanan dengan nilai "8 Jam"
    When user mengisi field "Waktu Perjalanan" dengan "20"
    Then sistem menampilkan "8 Jam"
    And sistem tidak menampilkan "20 Jam"

  @negative @priority-medium @REQ-050 @screen-step-3-vendor-harga
  Scenario: OMS012-NEG-054 - Tipe Normal tidak boleh menampilkan text link Lihat Detail
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    And order bertipe pengiriman "Normal"
    Then sistem tidak menampilkan "Lihat Detail"
    And sistem tidak menampilkan "Detail Multipickup"

  @negative @priority-medium @REQ-051 @screen-step-3-vendor-harga
  Scenario: OMS012-NEG-055 - Input komponen harga tidak muncul tanpa mencentang checkbox
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    And checkbox "Gunakan komponen harga" tidak tercentang
    Then sistem tidak menampilkan "PPN"
    And sistem tidak menampilkan "PPh"
    And sistem tidak menampilkan "Asuransi"

  @negative @priority-high @REQ-052 @screen-step-3-vendor-harga
  Scenario: OMS012-NEG-056 - Komponen Asuransi tidak dirender tanpa armada berasuransi
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    And tidak ada armada dengan "Tambahkan Asuransi" tercentang
    When user mencentang checkbox "Gunakan komponen harga"
    Then sistem menampilkan "PPN"
    And sistem tidak menampilkan "Asuransi"
    And sistem menampilkan "Tanpa Asuransi"

  @negative @priority-high @REQ-053 @screen-step-3-vendor-harga
  Scenario: OMS012-NEG-057 - Harga kosong menahan navigasi ke Step 4
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    And field "Harga" masih kosong
    When user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Harga harus diisi"
    And user diarahkan ke halaman "Buat Order - Step 3 Vendor dan Harga"

  @negative @priority-high @REQ-054 @screen-step-4-review
  Scenario: OMS012-NEG-058 - Field pada Step 4 tidak dapat diedit
    Given user berada di halaman "Buat Order - Step 4 Review"
    When user mengisi field "PIC Pengirim" dengan "Nama Baru"
    And user mengisi field "Jumlah" dengan "999"
    Then sistem tidak menampilkan "Nama Baru"
    And sistem tidak menampilkan "999"
    And sistem menampilkan "seluruh field dalam keadaan read-only"

  @negative @priority-high @REQ-055 @screen-step-4-review
  Scenario: OMS012-NEG-059 - Kolom Nilai Barang tidak tampil pada armada tanpa asuransi
    Given user berada di halaman "Buat Order - Step 4 Review"
    And "Armada 1" tidak memiliki "Tambahkan Asuransi" tercentang
    Then sistem tidak menampilkan "kolom Nilai Barang pada tabel Armada 1"
    And sistem menampilkan "Jumlah"

  @negative @priority-medium @REQ-056 @screen-step-4-review
  Scenario: OMS012-NEG-060 - Badge Diasuransikan tidak tampil pada armada tanpa asuransi
    Given user berada di halaman "Buat Order - Step 4 Review"
    And "Armada 1" tidak memiliki "Tambahkan Asuransi" tercentang
    Then sistem menampilkan "Armada 1"
    And sistem tidak menampilkan "badge Diasuransikan pada Armada 1"

  @negative @priority-high @REQ-057 @screen-step-4-review
  Scenario: OMS012-NEG-061 - Visualisasi Muatan tidak boleh menavigasi keluar dari Step 4
    Given user berada di halaman "Buat Order - Step 4 Review"
    When user mengklik tombol "Visualisasi Muatan"
    Then user diarahkan ke halaman "Buat Order - Step 4 Review"
    And sistem tidak menampilkan "Daftar Order"
    And sistem menampilkan "Visualisasi Muatan"

  @negative @priority-high @REQ-058 @screen-step-4-review
  Scenario: OMS012-NEG-062 - Batal pada Step 4 disertai konfirmasi tidak menyimpan order
    Given user berada di halaman "Buat Order - Step 4 Review"
    When user mengklik tombol "Batal"
    And user mengklik tombol "Ya"
    Then user diarahkan ke halaman "Daftar Order"
    And sistem tidak menampilkan "Menunggu Penugasan pada baris pertama tabel"

  @negative @priority-high @REQ-059 @screen-panel-filter
  Scenario: OMS012-NEG-063 - Dropdown Status tidak memuat status di luar sembilan nilai
    Given user berada di halaman "Daftar Order"
    When user mengklik tombol "Filter"
    And user mengklik tombol "Status"
    Then sistem tidak menampilkan "Menunggu Pembayaran"
    And sistem tidak menampilkan "Draft"
    And sistem tidak menampilkan "Kadaluarsa"

  @negative @priority-high @REQ-060 @screen-step-2-data-barang
  Scenario: OMS012-NEG-064 - Restore draft tidak boleh menghitung ulang Auto Stuffing secara otomatis
    Given user berada di halaman "Daftar Order"
    And terdapat order draft dengan penempatan "Armada 1 berisi 500 koli SKU-PPR-001"
    When user mengklik tombol "Aksi baris order"
    And user mengklik tombol "Lanjutkan Pengisian"
    Then user diarahkan ke halaman "Buat Order - Step 2 Data Barang"
    And sistem menampilkan "Armada 1 berisi 500 koli SKU-PPR-001"
    And sistem tidak menampilkan "Simulasi ulang kebutuhan unit dari muatan order ini. Terapkan untuk ubah data order."

  @negative @priority-high @REQ-061 @screen-daftar-order
  Scenario: OMS012-NEG-065 - Order berstatus Proses Pengiriman tidak menampilkan aksi Edit
    Given user berada di halaman "Daftar Order"
    And terdapat order berstatus "Proses Pengiriman"
    When user mengklik tombol "Aksi baris order"
    Then sistem tidak menampilkan "Edit"
    And sistem tidak menampilkan "Lanjutkan Pengisian"
    And sistem menampilkan "Detail"

  @negative @priority-high @REQ-062 @screen-edit-order
  Scenario: OMS012-NEG-066 - Akses URL Edit Order untuk order Ditugaskan ditolak
    Given user berada di halaman "Daftar Order"
    And terdapat order "ORD67890792" berstatus "Ditugaskan"
    When user membuka URL "/order/ORD67890792/edit"
    Then sistem menampilkan "Order tidak dapat diedit pada status ini"
    And user diarahkan ke halaman "Detail Order"
    And sistem tidak menampilkan "Edit Order"

  @negative @priority-high @REQ-063 @screen-edit-order
  Scenario: OMS012-NEG-067 - Tipe Pengiriman tidak dapat diubah dari halaman Edit Order
    Given user berada di halaman "Edit Order"
    When user mengisi field "Tipe Pengiriman" dengan "Multidrop"
    Then sistem menampilkan "Normal"
    And sistem tidak menampilkan "Multidrop"
    And sistem tidak menampilkan "combobox Tipe Pengiriman"

  @negative @priority-high @REQ-064 @screen-edit-order
  Scenario: OMS012-NEG-068 - Menyimpan Edit Order dengan Jumlah Armada kosong ditolak
    Given user berada di halaman "Edit Order"
    When user mengisi field "Jumlah Armada" dengan ""
    And user mengklik tombol "Simpan"
    Then sistem menampilkan "Jumlah Armada harus diisi"
    And user diarahkan ke halaman "Edit Order"

  @negative @priority-high @REQ-065 @screen-edit-order
  Scenario: OMS012-NEG-069 - Simpan pada Edit Order tidak boleh tersimpan tanpa konfirmasi
    Given user berada di halaman "Edit Order"
    And user telah mengubah field "Harga" dengan "20000000"
    When user mengklik tombol "Simpan"
    Then sistem menampilkan "dialog konfirmasi penyimpanan perubahan"
    And user diarahkan ke halaman "Edit Order"
    And sistem tidak menampilkan "Perubahan berhasil disimpan"

  @negative @priority-high @REQ-066 @screen-daftar-order
  Scenario: OMS012-NEG-070 - Batalkan Order tidak tersedia pada status Proses Pengiriman
    Given user berada di halaman "Daftar Order"
    And user login sebagai "Admin Shipper"
    And terdapat order berstatus "Proses Pengiriman"
    When user mengklik tombol "Aksi baris order"
    Then sistem tidak menampilkan "Batalkan Order"
    And sistem menampilkan "Lihat No. Perjalanan"

  @negative @priority-high @REQ-066 @screen-daftar-order
  Scenario: OMS012-NEG-071 - Order berstatus Dibatalkan tidak dapat dibatalkan ulang maupun diedit
    Given user berada di halaman "Daftar Order"
    And user login sebagai "Admin Shipper"
    And terdapat order berstatus "Dibatalkan"
    When user mengklik tombol "Aksi baris order"
    Then sistem tidak menampilkan "Batalkan Order"
    And sistem tidak menampilkan "Edit"
    And sistem menampilkan "Riwayat Perubahan"

  @negative @priority-high @REQ-067 @screen-daftar-order
  Scenario: OMS012-NEG-072 - Akun vendor tidak memiliki aksi Batalkan Order
    Given user berada di halaman "Daftar Order"
    And user login sebagai "Vendor"
    When user membuka URL "/order/ORD67890792/batalkan"
    Then sistem menampilkan "Anda tidak memiliki akses"
    And sistem tidak menampilkan "Tuliskan alasan pembatalan order"

  @negative @priority-medium @REQ-067 @screen-daftar-order
  Scenario: OMS012-NEG-073 - Staff Operasional tidak dapat mengeksekusi Batalkan Order
    Given user berada di halaman "Daftar Order"
    And user login sebagai "Shipper - Staff Operasional"
    And terdapat order berstatus "Menunggu Penugasan"
    When user mengklik tombol "Aksi baris order"
    Then sistem tidak menampilkan "Batalkan Order"
    And sistem menampilkan "Edit"

  @negative @priority-high @REQ-068 @screen-modal-batalkan-order
  Scenario: OMS012-NEG-074 - Submit pembatalan dengan Alasan Pembatalan kosong ditolak
    Given user berada di halaman "Detail Order"
    And modal "Batalkan Order" dalam keadaan terbuka
    When user mengklik tombol "Batalkan Order"
    Then sistem menampilkan "Alasan Pembatalan harus diisi"
    And sistem menampilkan "Batalkan Order"
    And sistem tidak menampilkan "Dibatalkan"

  @negative @priority-high @REQ-068 @screen-modal-batalkan-order
  Scenario: OMS012-NEG-075 - Alasan Pembatalan berisi spasi saja ditolak
    Given user berada di halaman "Detail Order"
    And modal "Batalkan Order" dalam keadaan terbuka
    When user mengisi field "Alasan Pembatalan" dengan "     "
    And user mengklik tombol "Batalkan Order"
    Then sistem menampilkan "Alasan Pembatalan harus diisi"
    And sistem tidak menampilkan "Dibatalkan"

  @negative @priority-high @REQ-069 @screen-daftar-order
  Scenario: OMS012-NEG-076 - Menu aksi status draft tidak memuat Edit
    Given user berada di halaman "Daftar Order"
    And terdapat order berstatus "Isi Data Vendor"
    When user mengklik tombol "Aksi baris order"
    Then sistem tidak menampilkan "Edit"
    And sistem tidak menampilkan "Lihat No. Perjalanan"
    And sistem menampilkan "Lanjutkan Pengisian"

  @negative @priority-high @REQ-070 @screen-daftar-order
  Scenario: OMS012-NEG-077 - Menu aksi status Ditugaskan tidak memuat Edit
    Given user berada di halaman "Daftar Order"
    And terdapat order berstatus "Ditugaskan"
    When user mengklik tombol "Aksi baris order"
    Then sistem tidak menampilkan "Edit"
    And sistem menampilkan "Lihat No. Perjalanan"

  @negative @priority-medium @REQ-071 @screen-riwayat-perubahan
  Scenario: OMS012-NEG-078 - Riwayat Perubahan tidak menampilkan histori order lain
    Given user berada di halaman "Daftar Order"
    And terdapat order "ORD67890792" dan order "ORD67890793"
    When user mengklik tombol "Aksi baris order"
    And user mengklik tombol "Riwayat Perubahan"
    Then sistem menampilkan "ORD67890792"
    And sistem tidak menampilkan "ORD67890793"

  @negative @priority-medium @REQ-072 @screen-public-tracking
  Scenario: OMS012-NEG-079 - Public tracking dengan nomor perjalanan tidak valid
    Given user berada di halaman "Public Tracking"
    When user mengisi field "No. Perjalanan" dengan "TRC00000000"
    And user mengklik tombol "Lacak"
    Then sistem menampilkan "No. Perjalanan tidak ditemukan"
    And sistem tidak menampilkan "progress perjalanan armada"

  @negative @priority-high @REQ-073 @screen-popup-no-perjalanan
  Scenario: OMS012-NEG-080 - No. Perjalanan tidak dapat diinput atau diedit manual
    Given user berada di halaman "Daftar Order"
    And pop up "Data No. Perjalanan" dalam keadaan terbuka untuk order 2 armada
    When user mengisi field "No. Perjalanan" dengan "TRC-MANUAL-01"
    Then sistem tidak menampilkan "TRC-MANUAL-01"
    And sistem menampilkan "TRC79289802"
    And sistem tidak menampilkan "field input No. Perjalanan yang dapat diketik"

  @negative @priority-high @REQ-074 @screen-daftar-order
  Scenario: OMS012-NEG-081 - Order jenis LTL tidak menampilkan aksi Lihat No. Perjalanan
    Given user berada di halaman "Daftar Order"
    And terdapat order jenis "LTL" berstatus "Ditugaskan"
    When user mengklik tombol "Aksi baris order"
    Then sistem tidak menampilkan "Lihat No. Perjalanan"
    And sistem menampilkan "Detail"

  @negative @priority-high @REQ-075 @screen-daftar-order
  Scenario: OMS012-NEG-082 - Status Menunggu Penugasan tidak memuat Lihat No. Perjalanan
    Given user berada di halaman "Daftar Order"
    And terdapat order berstatus "Menunggu Penugasan"
    When user mengklik tombol "Aksi baris order"
    Then sistem tidak menampilkan "Lihat No. Perjalanan"
    And sistem menampilkan "Edit"

  @negative @priority-high @REQ-076 @screen-popup-no-perjalanan
  Scenario: OMS012-NEG-083 - Jumlah baris pop up tidak boleh berbeda dari jumlah armada
    Given user berada di halaman "Daftar Order"
    And terdapat order berstatus "Ditugaskan" dengan "Jumlah Armada" bernilai "3"
    When user mengklik tombol "Aksi baris order"
    And user mengklik tombol "Lihat No. Perjalanan"
    Then sistem tidak menampilkan "2 baris No. Perjalanan"
    And sistem menampilkan "3 baris No. Perjalanan"

  @negative @priority-medium @REQ-077 @screen-popup-no-perjalanan
  Scenario: OMS012-NEG-084 - Penyalinan tanpa umpan balik visual dianggap gagal
    Given user berada di halaman "Daftar Order"
    And pop up "Data No. Perjalanan" dalam keadaan terbuka untuk order 2 armada
    Then sistem menampilkan "Salin No. Perjalanan"
    When user mengklik tombol "Salin No. Perjalanan"
    Then sistem tidak menampilkan "clipboard dalam keadaan kosong"
    And sistem menampilkan "Tersalin"

  @negative @priority-medium @REQ-078 @screen-detail-order
  Scenario: OMS012-NEG-085 - Detail Order yang belum ditugaskan tidak menampilkan No. Perjalanan
    Given user berada di halaman "Detail Order"
    And order berstatus "Menunggu Penugasan"
    Then sistem tidak menampilkan "No. Perjalanan"
    And sistem tidak menampilkan "TRC79289802"
    And sistem menampilkan "Menunggu Penugasan"

  @negative @priority-high @REQ-067 @screen-daftar-order
  Scenario: OMS012-NEG-086 - Guest tidak dapat mengakses URL Daftar Order
    Given user belum terautentikasi
    When user membuka URL "/order/daftar"
    Then user diarahkan ke halaman "Login"
    And sistem tidak menampilkan "Daftar Order"

  @negative @priority-high @REQ-067 @screen-step-1-data-pengiriman
  Scenario: OMS012-NEG-087 - Akun vendor tidak dapat mengakses wizard Buat Order
    Given user login sebagai "Vendor"
    When user membuka URL "/order/buat"
    Then sistem menampilkan "Anda tidak memiliki akses"
    And sistem tidak menampilkan "01 Data Pengiriman"

  @negative @priority-medium @REQ-069 @screen-panel-filter
  Scenario: OMS012-NEG-088 - Filter ID Order yang tidak dikenal menampilkan empty state
    Given user berada di halaman "Daftar Order"
    When user mengklik tombol "Filter"
    And user mengisi field "ID Order" dengan "ORD-TIDAK-ADA-999"
    And user mengklik tombol "Terapkan"
    Then sistem menampilkan "Data tidak ditemukan"
    And sistem tidak menampilkan "Terjadi kesalahan"
  # ---------------------------------------------------------------------------
  # PART 4/4 — KATEGORI: EDGE (OMS012-EDG-001..060) & STRESS (OMS012-STR-001..030)
  # ---------------------------------------------------------------------------

  @edge @priority-medium @REQ-009 @screen-step-1-data-pengiriman
  Scenario: OMS012-EDG-001 - Jumlah Armada bernilai satu sebagai batas minimum
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user mengisi field "Jumlah Armada" dengan "1"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 2 Data Barang"
    And sistem menampilkan "1 blok Armada"

  @edge @priority-medium @REQ-009 @screen-step-1-data-pengiriman
  Scenario: OMS012-EDG-002 - Jumlah Armada bernilai sembilan puluh sembilan
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user mengisi field "Jumlah Armada" dengan "99"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 2 Data Barang"
    And sistem menampilkan "99 blok Armada"
    And sistem menampilkan "Hitung Ulang Armada"

  @edge @priority-medium @REQ-009 @screen-step-1-data-pengiriman
  Scenario: OMS012-EDG-003 - No. WhatsApp PIC sepanjang sepuluh digit diterima
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user mengisi field "No. WhatsApp PIC" dengan "0812345678"
    And user mengklik tombol "Selanjutnya"
    Then sistem tidak menampilkan "No. WhatsApp PIC tidak valid"
    And user diarahkan ke halaman "Buat Order - Step 2 Data Barang"

  @edge @priority-medium @REQ-009 @screen-step-1-data-pengiriman
  Scenario: OMS012-EDG-004 - No. WhatsApp PIC sepanjang lima belas digit diterima
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user mengisi field "No. WhatsApp PIC" dengan "081234567890123"
    And user mengklik tombol "Selanjutnya"
    Then sistem tidak menampilkan "No. WhatsApp PIC tidak valid"
    And user diarahkan ke halaman "Buat Order - Step 2 Data Barang"

  @edge @priority-medium @REQ-009 @screen-step-1-data-pengiriman
  Scenario: OMS012-EDG-005 - No. WhatsApp PIC sepanjang sembilan digit ditolak
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user mengisi field "No. WhatsApp PIC" dengan "081234567"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "No. WhatsApp PIC tidak valid"
    And user diarahkan ke halaman "Buat Order - Step 1 Data Pengiriman"

  @edge @priority-low @REQ-009 @screen-step-1-data-pengiriman
  Scenario: OMS012-EDG-006 - PIC Pengirim sepanjang seratus karakter diterima
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user mengisi field "PIC Pengirim" dengan "Aaaaaaaaaa Bbbbbbbbbb Cccccccccc Dddddddddd Eeeeeeeeee Ffffffffff Gggggggggg Hhhhhhhhhh Iiiiiiiiii Jjjjjjjjjj"
    Then sistem tidak menampilkan "PIC Pengirim terlalu panjang"
    And sistem menampilkan "Nama PIC Pengirim"

  @edge @priority-low @REQ-009 @screen-step-1-data-pengiriman
  Scenario: OMS012-EDG-007 - PIC Pengirim sepanjang satu karakter diterima
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user mengisi field "PIC Pengirim" dengan "B"
    And user mengklik tombol "Selanjutnya"
    Then sistem tidak menampilkan "PIC Pengirim harus diisi"
    And user diarahkan ke halaman "Buat Order - Step 2 Data Barang"

  @edge @priority-low @REQ-009 @screen-step-1-data-pengiriman
  Scenario: OMS012-EDG-008 - PIC Pengirim dengan karakter spesial dan unicode
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user mengisi field "PIC Pengirim" dengan "Budi <script>alert(1)</script> & Sons — 東京"
    And user mengklik tombol "Selanjutnya"
    Then sistem tidak menampilkan "alert(1) dieksekusi"
    And sistem menampilkan "Budi <script>alert(1)</script> & Sons — 東京"

  @edge @priority-low @REQ-054 @screen-step-4-review
  Scenario: OMS012-EDG-009 - Catatan yang dikosongkan ditampilkan sebagai tanda hubung di Review
    Given user berada di halaman "Buat Order - Step 4 Review"
    And field "Catatan" pada Data Penerima dikosongkan pada Step 1
    Then sistem menampilkan "Catatan"
    And sistem menampilkan "-"

  @edge @priority-high @REQ-011 @screen-step-1-data-pengiriman
  Scenario: OMS012-EDG-010 - Mengganti Drop Point Asal tidak menyisakan nilai wilayah lama
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    And user telah memilih "Drop Point Asal" dengan "Gudang MSK Region 2"
    When user memilih "Drop Point Asal" dengan "Gudang MSK Region 5"
    Then sistem tidak menampilkan "Wonokromo"
    And sistem tidak menampilkan "60241"
    And sistem menampilkan "alamat asal sesuai Gudang MSK Region 5"

  @edge @priority-medium @REQ-010 @screen-step-1-data-pengiriman
  Scenario: OMS012-EDG-011 - Mengubah Tipe Pengiriman dari Multipoint menjadi Normal
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    And order bertipe pengiriman "Multipoint" dengan 3 alamat pengirim dan 2 alamat penerima
    When user memilih "Tipe Pengiriman" dengan "Normal"
    Then sistem tidak menampilkan "Pick Up 2"
    And sistem tidak menampilkan "Drop Off 2"
    And sistem menampilkan "Data Pengirim"
    And sistem menampilkan "Data Penerima"

  @edge @priority-medium @REQ-017 @screen-modal-pilih-barang
  Scenario: OMS012-EDG-012 - Pencarian dengan karakter wildcard tidak menyebabkan error
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And modal "Pilih Barang" dalam keadaan terbuka
    When user mengisi field "Cari kode/nama barang" dengan "%_'"
    Then sistem menampilkan "Barang tidak ditemukan"
    And sistem tidak menampilkan "Terjadi kesalahan"

  @edge @priority-medium @REQ-017 @screen-modal-pilih-barang
  Scenario: OMS012-EDG-013 - Pencarian dengan huruf kecil seluruhnya tetap menemukan hasil
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And modal "Pilih Barang" dalam keadaan terbuka
    When user mengisi field "Cari kode/nama barang" dengan "sku-ppr-001"
    Then sistem menampilkan "SKU-PPR-001 - Kertas HVS A4 80 gsm"

  @edge @priority-medium @REQ-017 @screen-modal-pilih-barang
  Scenario: OMS012-EDG-014 - Pencarian potongan nama di tengah string
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And modal "Pilih Barang" dalam keadaan terbuka
    When user mengisi field "Cari kode/nama barang" dengan "Tulis Hard"
    Then sistem menampilkan "Buku Tulis Hard Cover A5"
    And sistem tidak menampilkan "Pulpen Gel Hitam 0.5 mm"

  @edge @priority-low @REQ-017 @screen-modal-pilih-barang
  Scenario: OMS012-EDG-015 - Pencarian dengan spasi di awal dan akhir tetap menemukan hasil
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And modal "Pilih Barang" dalam keadaan terbuka
    When user mengisi field "Cari kode/nama barang" dengan "   SKU-ATK-001   "
    Then sistem menampilkan "SKU-ATK-001 - Pulpen Gel Hitam 0.5 mm"

  @edge @priority-high @REQ-019 @screen-modal-pilih-barang
  Scenario: OMS012-EDG-016 - Melepas centang item berlabel Sudah Ditambahkan menghapus barang dari armada
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And barang "SKU-PPR-002" sudah ditambahkan pada "Armada 1"
    When user mengklik tombol "Pilih Barang"
    And user melepas centang checkbox "SKU-PPR-002 - Kertas HVS F4 70 gsm"
    And user mengklik tombol "Simpan"
    Then sistem tidak menampilkan "SKU-PPR-002"
    And sistem menampilkan "Belum ada barang"

  @edge @priority-medium @REQ-020 @screen-modal-pilih-barang
  Scenario: OMS012-EDG-017 - Counter bernilai nol saat belum ada barang dipilih
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    When user mengklik tombol "Pilih Barang"
    Then sistem menampilkan "0 barang terpilih"
    And sistem tidak menampilkan "1 barang terpilih"

  @edge @priority-high @REQ-023 @screen-step-2-data-barang
  Scenario: OMS012-EDG-018 - Jumlah bernilai satu sebagai batas minimum
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And barang "SKU-PPR-001" sudah ditambahkan pada "Armada 1"
    When user mengisi field "Jumlah" dengan "1"
    Then sistem menampilkan "Total Kubikasi: 0,018"
    And sistem tidak menampilkan "Jumlah harus diisi"

  @edge @priority-high @REQ-023 @screen-step-2-data-barang
  Scenario: OMS012-EDG-019 - Jumlah bernilai nol ditolak
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And barang "SKU-PPR-001" sudah ditambahkan pada "Armada 1"
    When user mengisi field "Jumlah" dengan "0"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Jumlah harus diisi"
    And user diarahkan ke halaman "Buat Order - Step 2 Data Barang"

  @edge @priority-medium @REQ-023 @screen-step-2-data-barang
  Scenario: OMS012-EDG-020 - Jumlah bernilai negatif ditolak
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And barang "SKU-PPR-001" sudah ditambahkan pada "Armada 1"
    When user mengisi field "Jumlah" dengan "-5"
    Then sistem tidak menampilkan "-5"
    And sistem menampilkan "border field Jumlah berwarna error"

  @edge @priority-medium @REQ-023 @screen-step-2-data-barang
  Scenario: OMS012-EDG-021 - Jumlah bernilai desimal ditolak
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And barang "SKU-PPR-001" sudah ditambahkan pada "Armada 1"
    When user mengisi field "Jumlah" dengan "1,5"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Jumlah harus berupa bilangan bulat"
    And user diarahkan ke halaman "Buat Order - Step 2 Data Barang"

  @edge @priority-medium @REQ-029 @screen-step-2-data-barang
  Scenario: OMS012-EDG-022 - Jumlah sangat besar memicu alert kapasitas gabungan
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And "Armada 1" memakai jenis armada "Tronton Box" berkapasitas "20.000 kg / 60 m³"
    And barang "SKU-BKU-002" sudah ditambahkan pada "Armada 1"
    When user mengisi field "Jumlah" dengan "999999"
    Then sistem menampilkan "Kubikasi dan Berat melebihi kapasitas armada"
    And sistem menampilkan "tombol Selanjutnya dalam keadaan aktif"

  @edge @priority-medium @REQ-024 @screen-step-2-data-barang
  Scenario: OMS012-EDG-023 - Nilai Barang bernilai nol diterima
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And "Armada 1" memiliki "Tambahkan Asuransi" tercentang
    When user mengisi field "Nilai Barang" dengan "0"
    And user mengklik tombol "Selanjutnya"
    Then sistem tidak menampilkan "Nilai Barang harus diisi"
    And user diarahkan ke halaman "Buat Order - Step 3 Vendor dan Harga"

  @edge @priority-medium @REQ-024 @screen-step-2-data-barang
  Scenario: OMS012-EDG-024 - Nilai Barang diformat dengan pemisah ribuan dan prefiks Rp
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And "Armada 1" memiliki "Tambahkan Asuransi" tercentang
    When user mengisi field "Nilai Barang" dengan "1320000"
    Then sistem menampilkan "Rp"
    And sistem menampilkan "1.320.000"

  @edge @priority-high @REQ-024 @screen-step-2-data-barang
  Scenario: OMS012-EDG-025 - Toggle asuransi bolak-balik mempertahankan konsistensi validasi
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And barang "SKU-PPR-001" sudah ditambahkan pada "Armada 1" dengan Jumlah "100"
    When user mencentang checkbox "Tambahkan Asuransi"
    And user mengisi field "Nilai Barang" dengan "1320000"
    And user melepas centang checkbox "Tambahkan Asuransi"
    Then sistem tidak menampilkan "Nilai Barang"
    When user mencentang checkbox "Tambahkan Asuransi"
    Then sistem menampilkan "Nilai Barang"
    And sistem tidak menampilkan "Terjadi kesalahan"

  @edge @priority-medium @REQ-026 @screen-step-2-data-barang
  Scenario: OMS012-EDG-026 - Nomor DO dengan koma ganda dan spasi tidak membuat chip kosong
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    When user mengisi field "Nomor DO" dengan "DO-A001,,  , DO-B002 ,"
    Then sistem menampilkan "DO-A001"
    And sistem menampilkan "DO-B002"
    And sistem menampilkan "2 chip Nomor DO"

  @edge @priority-low @REQ-026 @screen-step-2-data-barang
  Scenario: OMS012-EDG-027 - Nomor DO berisi sepuluh chip sekaligus
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    When user mengisi field "Nomor DO" dengan "DO-01,DO-02,DO-03,DO-04,DO-05,DO-06,DO-07,DO-08,DO-09,DO-10"
    Then sistem menampilkan "10 chip Nomor DO"
    And sistem menampilkan "DO-10"

  @edge @priority-low @REQ-026 @screen-step-2-data-barang
  Scenario: OMS012-EDG-028 - Nomor DO dengan karakter spesial tetap dirender sebagai chip
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    When user mengisi field "Nomor DO" dengan "DO/2026#01, DO-2026&02"
    Then sistem menampilkan "DO/2026#01"
    And sistem menampilkan "DO-2026&02"
    And sistem tidak menampilkan "Terjadi kesalahan"

  @edge @priority-medium @REQ-027 @screen-step-2-data-barang
  Scenario: OMS012-EDG-029 - Menghapus seluruh baris mengembalikan armada ke empty state
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And "Armada 1" berisi 2 baris barang
    When user mengklik tombol "Hapus baris SKU-PPR-001"
    And user mengklik tombol "Hapus baris SKU-BKU-002"
    Then sistem menampilkan "Belum ada barang"
    And sistem menampilkan "Total Kubikasi: 0"
    And sistem menampilkan "tombol Hitung Ulang Armada dalam keadaan nonaktif"

  @edge @priority-high @REQ-029 @screen-step-2-data-barang
  Scenario: OMS012-EDG-030 - Kubikasi tepat sama dengan kapasitas tidak memunculkan alert
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And "Armada 1" memakai jenis armada "Tronton Box" berkapasitas "20.000 kg / 60 m³"
    And barang "SKU-ATK-001" berkubikasi satuan "0,035 m³" dan berat satuan "9,5 kg"
    When user mengisi field "Jumlah" dengan "1714"
    Then sistem tidak menampilkan "Kubikasi melebihi kapasitas armada"
    And sistem tidak menampilkan "Berat melebihi kapasitas armada"

  @edge @priority-high @REQ-029 @screen-step-2-data-barang
  Scenario: OMS012-EDG-031 - Kubikasi melampaui kapasitas sedikit di atas ambang memunculkan alert
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And "Armada 1" memakai jenis armada "Tronton Box" berkapasitas "20.000 kg / 60 m³"
    And barang "SKU-ATK-001" berkubikasi satuan "0,035 m³" dan berat satuan "9,5 kg"
    When user mengisi field "Jumlah" dengan "1715"
    Then sistem menampilkan "Kubikasi melebihi kapasitas armada"
    And sistem tidak menampilkan "Berat melebihi kapasitas armada"

  @edge @priority-high @REQ-029 @screen-step-2-data-barang
  Scenario: OMS012-EDG-032 - Berat tepat sama dengan kapasitas tidak memunculkan alert
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And "Armada 1" memakai jenis armada "Tronton Box" berkapasitas "20.000 kg / 60 m³"
    And barang "SKU-PPR-001" berkubikasi satuan "0,018 m³" dan berat satuan "12,5 kg"
    When user mengisi field "Jumlah" dengan "1600"
    Then sistem tidak menampilkan "Berat melebihi kapasitas armada"
    And sistem menampilkan "Total Berat: 20.000"

  @edge @priority-high @REQ-028 @screen-step-2-data-barang
  Scenario: OMS012-EDG-033 - Alert kapasitas hilang setelah Jumlah diturunkan
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And "Armada 1" melebihi kapasitas berat
    Then sistem menampilkan "Berat melebihi kapasitas armada"
    When user mengisi field "Jumlah" dengan "100"
    Then sistem tidak menampilkan "Berat melebihi kapasitas armada"

  @edge @priority-high @REQ-036 @screen-step-2-data-barang
  Scenario: OMS012-EDG-034 - Hitung Ulang aktif dengan tepat satu baris ber-Jumlah lebih dari nol
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And "Armada 1" berisi 3 baris barang tanpa Jumlah
    When user mengisi field "Jumlah" dengan "1"
    Then sistem menampilkan "tombol Hitung Ulang Armada dalam keadaan aktif"

  @edge @priority-high @REQ-036 @screen-step-2-data-barang
  Scenario: OMS012-EDG-035 - Baris terpilih tanpa Jumlah tidak mengaktifkan Hitung Ulang
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    When user mengklik tombol "Pilih Barang"
    And user mencentang checkbox "SKU-PPR-001 - Kertas HVS A4 80 gsm"
    And user mengklik tombol "Simpan"
    Then sistem menampilkan "SKU-PPR-001"
    And sistem menampilkan "tombol Hitung Ulang Armada dalam keadaan nonaktif"

  @edge @priority-high @REQ-037 @screen-step-2-data-barang
  Scenario: OMS012-EDG-036 - Muatan yang tepat memenuhi kapasitas satu armada
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And "Jumlah Armada" bernilai "2" dengan jenis armada "Tronton Box" berkapasitas "20.000 kg / 60 m³"
    And terdapat barang "SKU-PPR-001" dengan total Jumlah "1600"
    When user mengklik tombol "Hitung Ulang Armada"
    And user mengklik tombol "Terapkan ke Order"
    Then sistem menampilkan "Armada 1 berisi 1600 koli SKU-PPR-001"
    And sistem menampilkan "Belum ada barang"

  @edge @priority-medium @REQ-037 @screen-step-2-data-barang
  Scenario: OMS012-EDG-037 - Jumlah armada melebihi kebutuhan menyisakan armada kosong tanpa error
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And "Jumlah Armada" bernilai "5" dengan jenis armada "Tronton Box" berkapasitas "20.000 kg / 60 m³"
    And terdapat barang "SKU-PPR-001" dengan total Jumlah "100"
    When user mengklik tombol "Hitung Ulang Armada"
    And user mengklik tombol "Terapkan ke Order"
    Then sistem menampilkan "Armada 1 berisi 100 koli SKU-PPR-001"
    And sistem menampilkan "Belum ada barang"
    And sistem tidak menampilkan "Terjadi kesalahan"

  @edge @priority-high @REQ-038 @screen-step-2-data-barang
  Scenario: OMS012-EDG-038 - Sepuluh koli untuk tiga alamat menjadi empat tiga tiga
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And order bertipe pengiriman "Multipickup" dengan 3 alamat pengirim
    And terdapat barang "SKU-PPR-001" dengan total Jumlah "10" pada "Armada 1"
    When user mengklik tombol "Hitung Ulang Armada"
    And user mengklik tombol "Terapkan ke Order"
    Then sistem menampilkan "Pick Up 1 menerima 4 koli"
    And sistem menampilkan "Pick Up 2 menerima 3 koli"
    And sistem menampilkan "Pick Up 3 menerima 3 koli"

  @edge @priority-medium @REQ-038 @screen-step-2-data-barang
  Scenario: OMS012-EDG-039 - Satu koli untuk dua alamat menempatkan seluruhnya pada alamat pertama
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And order bertipe pengiriman "Multidrop" dengan 2 alamat penerima
    And terdapat barang "SKU-PPR-001" dengan total Jumlah "1" pada "Armada 1"
    When user mengklik tombol "Hitung Ulang Armada"
    And user mengklik tombol "Terapkan ke Order"
    Then sistem menampilkan "Drop Off 1 menerima 1 koli"
    And sistem menampilkan "Drop Off 2 menerima 0 koli"

  @edge @priority-medium @REQ-038 @screen-step-2-data-barang
  Scenario: OMS012-EDG-040 - Multipoint tiga Pick Up kali dua Drop Off menghasilkan enam sub-section
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And order bertipe pengiriman "Multipoint" dengan 3 alamat pengirim dan 2 alamat penerima
    Then sistem menampilkan "6 sub-section alamat pada Armada 1"
    And sistem menampilkan "Pick Up 3"
    And sistem menampilkan "Drop Off 2"

  @edge @priority-medium @REQ-041 @screen-drawer-hitung-ulang-armada
  Scenario: OMS012-EDG-041 - Master armada relevan kurang dari tiga menampilkan rekomendasi seadanya
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And master armada hanya memiliki 2 jenis armada relevan
    When user mengklik tombol "Hitung Ulang Armada"
    Then sistem menampilkan "2 kartu rekomendasi armada"
    And sistem menampilkan "tepat satu badge Paling Efisien"
    And sistem tidak menampilkan "Terjadi kesalahan"

  @edge @priority-medium @REQ-042 @screen-drawer-hitung-ulang-armada
  Scenario: OMS012-EDG-042 - Stepper kurang pada Jumlah Armada bernilai satu tetap bernilai satu
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And drawer "Hitung Ulang Armada" dalam keadaan terbuka dengan "Jumlah Armada" bernilai "1"
    When user mengklik tombol "Kurang Jumlah Armada"
    Then sistem menampilkan "1"
    And sistem tidak menampilkan "0"

  @edge @priority-medium @REQ-043 @screen-drawer-hitung-ulang-armada
  Scenario: OMS012-EDG-043 - Jumlah Armada sepuluh merender sepuluh tab visualisasi
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And drawer "Hitung Ulang Armada" dalam keadaan terbuka
    When user mengisi field "Jumlah Armada" dengan "10"
    Then sistem menampilkan "10 tab visualisasi armada"
    And sistem menampilkan "Armada 10"

  @edge @priority-medium @REQ-044 @screen-drawer-hitung-ulang-armada
  Scenario: OMS012-EDG-044 - Terapkan ke Order tanpa memilih kartu rekomendasi
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And drawer "Hitung Ulang Armada" dalam keadaan terbuka
    When user mengklik tombol "Pilih Jenis Armada"
    And user memilih "Jenis Armada" dengan "Fuso Box"
    And user mengklik tombol "Simpan"
    And user mengklik tombol "Terapkan ke Order"
    Then sistem menampilkan "Fuso Box"
    And sistem menampilkan "hasil penempatan barang terbaru pada setiap armada"

  @edge @priority-medium @REQ-045 @screen-drawer-hitung-ulang-armada
  Scenario: OMS012-EDG-045 - Menurunkan Jumlah Armada memunculkan badge overflow pada visualisasi
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And drawer "Hitung Ulang Armada" dalam keadaan terbuka dengan "Jumlah Armada" bernilai "3"
    When user mengisi field "Jumlah Armada" dengan "1"
    Then sistem menampilkan "melebihi kapasitas (outline merah)"
    And sistem menampilkan "1 tab visualisasi armada"

  @edge @priority-medium @REQ-046 @screen-drawer-hitung-ulang-armada
  Scenario: OMS012-EDG-046 - Membuka ulang drawer setelah Batal menampilkan nilai order terkini
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And order memiliki "Jenis Armada" bernilai "Tronton Box" dan "Jumlah Armada" bernilai "2"
    When user mengklik tombol "Hitung Ulang Armada"
    And user mengisi field "Jumlah Armada" dengan "6"
    And user mengklik tombol "Batal"
    And user mengklik tombol "Hitung Ulang Armada"
    Then sistem menampilkan "2"
    And sistem tidak menampilkan "6"

  @edge @priority-medium @REQ-048 @screen-step-3-vendor-harga
  Scenario: OMS012-EDG-047 - Tanggal Permintaan Muat sama dengan waktu saat ini diterima
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    When user mengisi field "Tanggal Permintaan Muat" dengan "waktu sekarang"
    And user mengklik tombol "Selanjutnya"
    Then sistem tidak menampilkan "Tanggal Permintaan Muat tidak boleh di masa lalu"
    And user diarahkan ke halaman "Buat Order - Step 4 Review"

  @edge @priority-medium @REQ-048 @screen-step-3-vendor-harga
  Scenario: OMS012-EDG-048 - Tanggal Permintaan Muat di masa lalu ditolak
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    When user mengisi field "Tanggal Permintaan Muat" dengan "01/01/2020 08:00"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Tanggal Permintaan Muat tidak boleh di masa lalu"
    And user diarahkan ke halaman "Buat Order - Step 3 Vendor dan Harga"

  @edge @priority-medium @REQ-049 @screen-step-3-vendor-harga
  Scenario: OMS012-EDG-049 - Waktu Perjalanan satu jam diterima dan nol ditolak
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    And rute asal-tujuan belum terdaftar pada Master Waktu Perjalanan
    When user mengisi field "Waktu Perjalanan" dengan "0"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Waktu Perjalanan minimal 1 Jam"
    When user mengisi field "Waktu Perjalanan" dengan "1"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 4 Review"

  @edge @priority-medium @REQ-051 @screen-step-3-vendor-harga
  Scenario: OMS012-EDG-050 - PPN bernilai nol dan seratus persen sebagai batas
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    And user telah mencentang checkbox "Gunakan komponen harga"
    When user mengisi field "PPN" dengan "0"
    Then sistem menampilkan "PPN (0%)"
    When user mengisi field "PPN" dengan "100"
    Then sistem menampilkan "PPN (100%)"
    And sistem tidak menampilkan "PPN tidak valid"

  @edge @priority-medium @REQ-051 @screen-step-3-vendor-harga
  Scenario: OMS012-EDG-051 - PPh melebihi seratus persen ditolak
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    And user telah mencentang checkbox "Gunakan komponen harga"
    When user mengisi field "PPh" dengan "101"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "PPh maksimal 100"
    And user diarahkan ke halaman "Buat Order - Step 3 Vendor dan Harga"

  @edge @priority-high @REQ-052 @screen-step-3-vendor-harga
  Scenario: OMS012-EDG-052 - Asuransi persentase pecahan dengan Total Nilai Barang besar
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    And terdapat armada dengan "Tambahkan Asuransi" tercentang dan Total Nilai Barang "1.000.000.000"
    When user mencentang checkbox "Gunakan komponen harga"
    And user mengisi field "Asuransi" dengan "0,2"
    Then sistem menampilkan "Asuransi (0,2%)"
    And sistem menampilkan "Rp2.000.000"

  @edge @priority-high @REQ-052 @screen-step-3-vendor-harga
  Scenario: OMS012-EDG-053 - Mengubah Nilai Barang di Step 2 memperbarui Asuransi dan Total Harga
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    And komponen "Asuransi" bernilai "0,2" dengan Total Nilai Barang "100.000.000"
    When user mengklik tombol "Sebelumnya"
    And user mengisi field "Nilai Barang" dengan "200000000"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Total Nilai Barang = Rp200.000.000"
    And sistem menampilkan "Rp400.000"

  @edge @priority-medium @REQ-068 @screen-modal-batalkan-order
  Scenario: OMS012-EDG-054 - Alasan Pembatalan satu karakter diterima
    Given user berada di halaman "Detail Order"
    And modal "Batalkan Order" dalam keadaan terbuka
    When user mengisi field "Alasan Pembatalan" dengan "X"
    And user mengklik tombol "Batalkan Order"
    Then sistem menampilkan "Dibatalkan"
    And sistem tidak menampilkan "Alasan Pembatalan harus diisi"

  @edge @priority-medium @REQ-076 @screen-popup-no-perjalanan
  Scenario: OMS012-EDG-055 - Order dengan satu armada menghasilkan satu baris No. Perjalanan
    Given user berada di halaman "Daftar Order"
    And terdapat order berstatus "Ditugaskan" dengan "Jumlah Armada" bernilai "1"
    When user mengklik tombol "Aksi baris order"
    And user mengklik tombol "Lihat No. Perjalanan"
    Then sistem menampilkan "1 baris No. Perjalanan"
    And sistem menampilkan "Data No. Perjalanan"

  @edge @priority-high @REQ-073 @screen-edit-order
  Scenario: OMS012-EDG-056 - Mengubah Jumlah Armada sebelum penugasan menyesuaikan jumlah No. Perjalanan
    Given user berada di halaman "Edit Order"
    And order berstatus "Menunggu Penugasan" dengan "Jumlah Armada" bernilai "2"
    When user mengisi field "Jumlah Armada" dengan "4"
    And user mengklik tombol "Simpan"
    And user mengklik tombol "Simpan"
    Given vendor telah melakukan penugasan sehingga order berstatus "Ditugaskan"
    When user mengklik tombol "Lihat No. Perjalanan"
    Then sistem menampilkan "4 baris No. Perjalanan"

  @edge @priority-medium @REQ-077 @screen-popup-no-perjalanan
  Scenario: OMS012-EDG-057 - Nilai hasil salin identik dengan yang ditampilkan
    Given user berada di halaman "Daftar Order"
    And pop up "Data No. Perjalanan" dalam keadaan terbuka untuk order 2 armada
    When user mengklik tombol "Salin No. Perjalanan"
    Then sistem menampilkan "isi clipboard bernilai TRC79289802"
    And sistem tidak menampilkan "isi clipboard mengandung spasi tambahan"

  @edge @priority-medium @REQ-059 @screen-daftar-order
  Scenario: OMS012-EDG-058 - Label status pada UI dapat berupa varian Isi Data Dasar atau Terkirim
    Given user berada di halaman "Daftar Order"
    Then sistem menampilkan "Isi Data Dasar"
    And sistem menampilkan "Terkirim"
    And sistem menampilkan "chip status order pada setiap baris"

  @edge @priority-medium @REQ-033 @screen-step-2-data-barang
  Scenario: OMS012-EDG-059 - Klik ganda cepat pada Hitung Ulang hanya membuka satu drawer
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And "Armada 1" berisi barang "SKU-PPR-001" Jumlah "100"
    When user mengklik tombol "Hitung Ulang Armada" dua kali dalam 200 ms
    Then sistem menampilkan "1 drawer Hitung Ulang Armada"
    And sistem tidak menampilkan "2 drawer Hitung Ulang Armada"

  @edge @priority-high @REQ-044 @screen-drawer-hitung-ulang-armada
  Scenario: OMS012-EDG-060 - Klik ganda cepat pada Terapkan ke Order hanya diterapkan sekali
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And drawer "Hitung Ulang Armada" dalam keadaan terbuka
    When user mengklik tombol "Terapkan ke Order" dua kali dalam 200 ms
    Then sistem menampilkan "total Jumlah barang tidak berubah"
    And sistem tidak menampilkan "baris barang terduplikasi"

  # ---------------------------------------------------------------------------
  # KATEGORI: STRESS
  # ---------------------------------------------------------------------------

  @stress @priority-medium @REQ-023 @screen-step-2-data-barang
  Scenario: OMS012-STR-001 - Seratus baris barang dalam satu armada
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    When user menambahkan "100" baris barang pada "Armada 1"
    And user mengisi field "Jumlah" pada seluruh baris dengan "10"
    Then sistem menampilkan "100 baris barang pada tabel Armada 1"
    And sistem menampilkan "Total Kubikasi"
    And sistem menampilkan "halaman selesai dirender di bawah 5 detik"

  @stress @priority-medium @REQ-039 @screen-drawer-hitung-ulang-armada
  Scenario: OMS012-STR-002 - Total kubikasi dan berat dari lima puluh baris dengan Jumlah sangat besar
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And "Armada 1" berisi 50 baris barang dengan Jumlah masing-masing "1000000"
    When user mengklik tombol "Hitung Ulang Armada"
    Then sistem menampilkan "Total Kubikasi"
    And sistem menampilkan "Total Berat"
    And sistem tidak menampilkan "NaN"
    And sistem tidak menampilkan "Infinity"

  @stress @priority-medium @REQ-038 @screen-step-2-data-barang
  Scenario: OMS012-STR-003 - Multipoint lima Pick Up kali lima Drop Off menghasilkan dua puluh lima sub-section
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And order bertipe pengiriman "Multipoint" dengan 5 alamat pengirim dan 5 alamat penerima
    Then sistem menampilkan "25 sub-section alamat pada Armada 1"
    And sistem menampilkan "Pick Up 5"
    And sistem menampilkan "Drop Off 5"

  @stress @priority-medium @REQ-009 @screen-step-1-data-pengiriman
  Scenario: OMS012-STR-004 - Jumlah Armada lima puluh merender lima puluh blok armada
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user mengisi field "Jumlah Armada" dengan "50"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 2 Data Barang"
    And sistem menampilkan "50 blok Armada"
    And sistem menampilkan "Armada 50"

  @stress @priority-medium @REQ-043 @screen-drawer-hitung-ulang-armada
  Scenario: OMS012-STR-005 - Drawer merender lima puluh tab visualisasi armada
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And drawer "Hitung Ulang Armada" dalam keadaan terbuka
    When user mengisi field "Jumlah Armada" dengan "50"
    Then sistem menampilkan "50 tab visualisasi armada"
    And sistem menampilkan "Armada 50"
    And sistem tidak menampilkan "Terjadi kesalahan"

  @stress @priority-medium @REQ-017 @screen-modal-pilih-barang
  Scenario: OMS012-STR-006 - Modal Pilih Barang dengan sepuluh ribu item master
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And Master Barang berisi 10000 item aktif
    When user mengklik tombol "Pilih Barang"
    And user mengisi field "Cari kode/nama barang" dengan "SKU-PPR-9999"
    Then sistem menampilkan "SKU-PPR-9999"
    And sistem menampilkan "hasil pencarian tampil di bawah 3 detik"

  @stress @priority-low @REQ-017 @screen-modal-pilih-barang
  Scenario: OMS012-STR-007 - Kata kunci pencarian sepanjang seribu karakter
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And modal "Pilih Barang" dalam keadaan terbuka
    When user mengisi field "Cari kode/nama barang" dengan "string acak sepanjang 1000 karakter"
    Then sistem menampilkan "Barang tidak ditemukan"
    And sistem tidak menampilkan "Terjadi kesalahan"

  @stress @priority-low @REQ-026 @screen-step-2-data-barang
  Scenario: OMS012-STR-008 - Nomor DO berisi dua ratus chip
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    When user mengisi field "Nomor DO" dengan "200 nomor DO dipisahkan koma"
    Then sistem menampilkan "200 chip Nomor DO"
    And sistem menampilkan "halaman selesai dirender di bawah 5 detik"

  @stress @priority-medium @REQ-068 @screen-modal-batalkan-order
  Scenario: OMS012-STR-009 - Alasan Pembatalan sepanjang lima ribu karakter
    Given user berada di halaman "Detail Order"
    And modal "Batalkan Order" dalam keadaan terbuka
    When user mengisi field "Alasan Pembatalan" dengan "teks acak sepanjang 5000 karakter"
    And user mengklik tombol "Batalkan Order"
    Then sistem menampilkan "Dibatalkan"
    And sistem tidak menampilkan "Terjadi kesalahan"

  @stress @priority-low @REQ-009 @screen-step-1-data-pengiriman
  Scenario: OMS012-STR-010 - PIC Pengirim sepanjang seribu karakter ditolak
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user mengisi field "PIC Pengirim" dengan "teks acak sepanjang 1000 karakter"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "PIC Pengirim maksimal 100 karakter"
    And user diarahkan ke halaman "Buat Order - Step 1 Data Pengiriman"

  @stress @priority-medium @REQ-036 @screen-step-2-data-barang
  Scenario: OMS012-STR-011 - Menjalankan Hitung Ulang Armada dua puluh kali berturut-turut
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And "Armada 1" berisi barang "SKU-PPR-001" Jumlah "500"
    When user mengklik tombol "Hitung Ulang Armada" sebanyak 20 siklus buka-tutup
    Then sistem menampilkan "Paling Efisien"
    And sistem menampilkan "rekomendasi armada yang sama persis dengan eksekusi sebelumnya"
    And sistem tidak menampilkan "Terjadi kesalahan"

  @stress @priority-medium @REQ-044 @screen-drawer-hitung-ulang-armada
  Scenario: OMS012-STR-012 - Terapkan ke Order dijalankan sepuluh kali berturut-turut
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And terdapat barang dengan total Jumlah "2000" sebelum distribusi
    When user menjalankan "Hitung Ulang Armada" dan "Terapkan ke Order" sebanyak 10 kali
    Then sistem menampilkan "total Jumlah seluruh armada tetap 2000"
    And sistem tidak menampilkan "baris barang terduplikasi"

  @stress @priority-medium @REQ-069 @screen-daftar-order
  Scenario: OMS012-STR-013 - Daftar Order berisi sepuluh ribu baris dengan paginasi
    Given user berada di halaman "Daftar Order"
    And terdapat 10000 order pada tenant
    Then sistem menampilkan "Menampilkan 1 - 20 data dari 10000 data"
    When user mengklik tombol "»"
    Then sistem menampilkan "halaman terakhir paginasi"
    And sistem menampilkan "halaman selesai dirender di bawah 5 detik"

  @stress @priority-low @REQ-069 @screen-daftar-order
  Scenario: OMS012-STR-014 - Menampilkan seratus data per halaman
    Given user berada di halaman "Daftar Order"
    And terdapat 10000 order pada tenant
    When user memilih "Tampilkan" dengan "100"
    Then sistem menampilkan "100 baris pada tabel daftar order"
    And sistem tidak menampilkan "Terjadi kesalahan"

  @stress @priority-high @REQ-064 @screen-edit-order
  Scenario: OMS012-STR-015 - Dua sesi paralel mengedit order yang sama
    Given user berada di halaman "Edit Order"
    And order "ORD67890792" dibuka pada dua sesi browser berbeda
    When sesi pertama mengisi field "Jumlah Armada" dengan "3" lalu menyimpan
    And sesi kedua mengisi field "Jumlah Armada" dengan "5" lalu menyimpan
    Then sistem menampilkan "Data order telah diperbarui pengguna lain"
    And sistem tidak menampilkan "dua versi order yang saling menimpa tanpa peringatan"

  @stress @priority-high @REQ-066 @screen-daftar-order
  Scenario: OMS012-STR-016 - Pembatalan dan pengeditan paralel pada order yang sama
    Given user berada di halaman "Daftar Order"
    And order "ORD67890792" berstatus "Menunggu Penugasan"
    When admin shipper mengeksekusi "Batalkan Order" pada sesi pertama
    And staff operasional menyimpan perubahan Edit Order pada sesi kedua
    Then sistem menampilkan "Dibatalkan"
    And sistem menampilkan "Order tidak dapat diedit pada status ini"

  @stress @priority-medium @REQ-003 @screen-batch-order
  Scenario: OMS012-STR-017 - Batch Order dengan lima ribu baris
    Given user berada di halaman "Batch Order"
    When user mengunggah berkas "batch-order-5000-baris.xlsx"
    And user mengklik tombol "Simpan"
    Then sistem menampilkan "proses batch berjalan tanpa timeout"
    And sistem menampilkan "ringkasan hasil batch"
    And sistem tidak menampilkan "Terjadi kesalahan"

  @stress @priority-medium @REQ-060 @screen-step-2-data-barang
  Scenario: OMS012-STR-018 - Simpan ke Draf dijalankan dua puluh kali beruntun
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    When user menjalankan "Simpan ke Draf" sebanyak 20 kali beruntun
    Then sistem menampilkan "Isi Data Muatan"
    And sistem tidak menampilkan "20 order draft duplikat"

  @stress @priority-high @REQ-007 @screen-drawer-hitung-ulang-armada
  Scenario: OMS012-STR-019 - Timeout pada tools Auto Stuffing ditangani dengan pesan error
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And layanan Auto Stuffing dikonfigurasi merespons melebihi batas waktu
    When user mengklik tombol "Hitung Ulang Armada"
    Then sistem menampilkan "Gagal menghitung rekomendasi armada"
    And sistem tidak menampilkan "halaman dalam keadaan tergantung tanpa umpan balik"
    And sistem menampilkan "hasil penempatan barang terbaru pada setiap armada"

  @stress @priority-medium @REQ-033 @screen-step-2-data-barang
  Scenario: OMS012-STR-020 - Jaringan lambat saat membuka drawer menampilkan loading state
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And jaringan dibatasi pada profil "Slow 3G"
    When user mengklik tombol "Hitung Ulang Armada"
    Then sistem menampilkan "indikator loading drawer"
    And sistem menampilkan "Paling Efisien"

  @stress @priority-medium @REQ-016 @screen-modal-pilih-barang
  Scenario: OMS012-STR-021 - Timeout API Master Barang menampilkan pesan error bukan modal kosong
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And layanan Master Barang dikonfigurasi merespons melebihi batas waktu
    When user mengklik tombol "Pilih Barang"
    Then sistem menampilkan "Gagal memuat data barang"
    And sistem tidak menampilkan "daftar barang dalam keadaan kosong tanpa pesan"

  @stress @priority-medium @REQ-072 @screen-public-tracking
  Scenario: OMS012-STR-022 - Seratus permintaan public tracking secara paralel
    Given user berada di halaman "Public Tracking"
    When 100 permintaan tracking dikirim secara paralel dengan No. Perjalanan valid
    Then sistem menampilkan "seluruh permintaan mendapat respons sukses"
    And sistem tidak menampilkan "Terjadi kesalahan"

  @stress @priority-low @REQ-077 @screen-popup-no-perjalanan
  Scenario: OMS012-STR-023 - Menyalin No. Perjalanan pada order dengan lima puluh armada
    Given user berada di halaman "Daftar Order"
    And terdapat order berstatus "Ditugaskan" dengan "Jumlah Armada" bernilai "50"
    When user mengklik tombol "Aksi baris order"
    And user mengklik tombol "Lihat No. Perjalanan"
    Then sistem menampilkan "50 baris No. Perjalanan"
    When user mengklik tombol "Salin No. Perjalanan"
    Then sistem menampilkan "Tersalin"

  @stress @priority-medium @REQ-057 @screen-popup-visualisasi-muatan
  Scenario: OMS012-STR-024 - Visualisasi tiga dimensi dengan sepuluh ribu koli
    Given user berada di halaman "Detail Order"
    And order memiliki total muatan "10000 koli"
    When user mengklik tombol "Visualisasi Muatan"
    Then sistem menampilkan "dialokasikan ke unit ini"
    And sistem menampilkan "Berat Terpakai"
    And sistem menampilkan "halaman selesai dirender di bawah 5 detik"

  @stress @priority-medium @REQ-071 @screen-riwayat-pembatalan
  Scenario: OMS012-STR-025 - Riwayat Pembatalan berisi lima ribu order
    Given user berada di halaman "Daftar Order"
    And terdapat 5000 order berstatus "Dibatalkan"
    When user mengklik tombol "Riwayat Pembatalan"
    Then sistem menampilkan "Riwayat Pembatalan"
    And sistem menampilkan "paginasi daftar riwayat pembatalan"
    And sistem menampilkan "halaman selesai dirender di bawah 5 detik"

  @stress @priority-low @REQ-071 @screen-riwayat-perubahan
  Scenario: OMS012-STR-026 - Riwayat Perubahan berisi seribu entri
    Given user berada di halaman "Daftar Order"
    And order "ORD67890792" memiliki 1000 entri perubahan
    When user mengklik tombol "Aksi baris order"
    And user mengklik tombol "Riwayat Perubahan"
    Then sistem menampilkan "ORD67890792"
    And sistem menampilkan "paginasi daftar riwayat perubahan"

  @stress @priority-medium @REQ-034 @screen-step-2-data-barang
  Scenario: OMS012-STR-027 - Scroll panjang dengan lima puluh armada tetap menampilkan floating button
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And terdapat "50" blok armada pada Step 2
    When user menggulir halaman ke bagian paling bawah
    Then sistem menampilkan "Hitung Ulang Armada"
    And sistem menampilkan "Visualisasi Terbaru"
    And sistem menampilkan "tombol Selanjutnya tetap dapat diklik"

  @stress @priority-medium @REQ-002 @screen-step-4-review
  Scenario: OMS012-STR-028 - Navigasi bolak-balik Step 1 sampai Step 4 sebanyak tiga puluh kali
    Given user berada di halaman "Buat Order - Step 4 Review"
    When user menavigasi bolak-balik Step 1 sampai Step 4 sebanyak 30 kali
    Then sistem menampilkan "SKU-PPR-001"
    And sistem menampilkan "PT Logistik Transportasi Nusantara"
    And sistem tidak menampilkan "data step yang hilang"

  @stress @priority-low @REQ-069 @screen-panel-filter
  Scenario: OMS012-STR-029 - Filter, sort, dan paginasi dijalankan berulang secara cepat
    Given user berada di halaman "Daftar Order"
    When user menjalankan kombinasi filter, sort, dan paginasi sebanyak 30 iterasi cepat
    Then sistem menampilkan "Menampilkan 1 - 20 data dari 30 data"
    And sistem tidak menampilkan "Terjadi kesalahan"

  @stress @priority-high @REQ-058 @screen-step-4-review
  Scenario: OMS012-STR-030 - Dua puluh order disimpan paralel dari sesi berbeda
    Given user berada di halaman "Buat Order - Step 4 Review"
    When 20 sesi berbeda mengklik tombol "Simpan" secara paralel
    Then sistem menampilkan "20 order berstatus Menunggu Penugasan"
    And sistem tidak menampilkan "ID Order duplikat"
