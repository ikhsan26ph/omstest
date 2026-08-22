# ============================================================================
# Modul   : oms012-order-ftl-auto-stuffing
# Sumber  : oms012-order-ftl-auto-stuffing.analysis.md (76 REQ / 59 VAL / 80 AC)
#           oms012-order-ftl-auto-stuffing.ui-inventory.md (39 layar, M-01..M-25, FND-01..FND-15)
# Tanggal : 2026-08-18   | Mode: AUTO (asumsi diambil sendiri, dicatat di bawah)
# Bahasa  : teks Indonesia + keyword Gherkin Inggris (konsisten seluruh file)
# Total   : 151 skenario (positive 79 / negative 43 / edge 14 / stress 15)
# Revisi  : rev-2 (2026-08-18) - menutup 2 gap reviewer:
#           (1) FND-11 -> skenario baru SCN-0151 (Detail Order Multidrop),
#           (2) M-22 -> assertion placeholder "Tuliskan alasan pembatalan order"
#               ditambahkan pada SCN-0123.
#
# CATATAN & ASUMSI TAMBAHAN (AUTO MODE)
# A1. Scenario Outline di-expand 1 skenario per baris Examples; ID unik tiap
#     baris ada pada kolom <id>, sehingga jumlah skenario .feature == jumlah
#     entry .scenarios.json (151) dan ID-nya 1:1.
# A2. Background = konteks default (Admin Shipper + add-on Auto Stuffing aktif).
#     Skenario dengan konteks lain (add-on tidak dibeli, role Vendor, jenis LTL,
#     status order tertentu) menuliskan Given override eksplisit.
# A3. ASM-D09 dipakai: badge status memakai TEKS DESAIN ("Isi Data Dasar",
#     "Terkirim"), bukan teks spec ("Isi Data Pengiriman", "Selesai").
# A4. ASM-D07 dipakai: item "Sudah Ditambahkan" pada modal Pilih Barang TETAP
#     aktif (tidak disabled) -> SCN-0033 mengikuti desain, bukan VAL-M4 lama.
# A5. FND-05 (KANDIDAT BUG): panel "Visualisasi Terbaru" memiliki tombol
#     "Terapkan ke Order" yang bertentangan dengan REQ-042/VAL-16.
#     SCN-0079 meng-assert perilaku sesuai REQ (Jenis & Jumlah Armada pada
#     Step 1/Step 2 TIDAK berubah) dan menandai tombol tsb sebagai kandidat bug.
# A6. FND-12 (ASUMSI): pesan gabungan "Kubikasi dan Berat melebihi kapasitas
#     armada" (M-05) tidak ada di desain manapun. SCN-0057 tetap ditulis dari
#     spec: assert kondisi kubikasi & berat secara TERPISAH lebih dulu, lalu
#     assert pesan gabungan sebagai ekspektasi utama (kandidat gap desain).
# A7. Kandidat bug lain yang di-assert sesuai REQ (bukan sesuai desain):
#     FND-01 -> SCN-0131, FND-02 -> SCN-0060, FND-03 -> SCN-0037,
#     FND-08 -> SCN-0137, FND-09 -> SCN-0117, FND-10 -> SCN-0118,
#     FND-11 -> SCN-0151, FND-14 -> SCN-0106.
# A8. Batas nilai dari Assumptions Log: Jumlah Armada >= 1 (ASM-005), Jumlah
#     barang >= 1 (ASM-006), Nilai Barang > 0 (ASM-007), Tanggal Permintaan
#     Muat >= hari ini (ASM-009).
# A9. Teks pesan validasi yang tidak ada di desain (mis. "Jumlah Armada minimal
#     1") adalah ekspektasi fungsional; matcher Playwright disarankan memakai
#     regex/partial match, bukan exact string (lihat FND-07).
# A10. selectorHints lengkap (role/name/label/testid) ada pada file JSON
#      pendamping: oms012-order-ftl-auto-stuffing.scenarios.json.
# ============================================================================

Feature: OMS012 - Order FTL dengan Add-on Auto Stuffing
  Sebagai Admin/Staff Shipper pada OMS yang memiliki add-on Auto Stuffing
  Saya ingin membuat, mengubah, membatalkan, dan meninjau order FTL
  Agar penempatan barang ke armada dihitung otomatis dan order dapat diproses vendor

  Background:
    Given user login sebagai "Admin Shipper" pada OMS tenant "Mentari Sumber Kertas"
    And modul OMS aktif dengan add-on "Auto Stuffing"

  # ==========================================================================
  # A. KETENTUAN UMUM & ADD-ON (REQ-001 .. REQ-006)
  # ==========================================================================

  @SCN-0001 @positive @priority-high @REQ-001 @REQ-004 @screen-step2
  Scenario: Add-on Auto Stuffing aktif menampilkan seluruh elemen auto stuffing
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    When user memeriksa area floating button
    Then sistem menampilkan tombol "Hitung Ulang Armada"
    And sistem menampilkan tombol "Visualisasi Terbaru"

  @SCN-0002 @negative @priority-high @REQ-004 @screen-step2
  Scenario: Add-on Auto Stuffing tidak dibeli menyembunyikan elemen auto stuffing
    Given tenant tidak membeli add-on "Auto Stuffing"
    And user berada di halaman "Buat Order - Step 2 Data Barang"
    When user memeriksa area floating button
    Then sistem tidak menampilkan tombol "Hitung Ulang Armada"
    And sistem tidak menampilkan tombol "Visualisasi Terbaru"

  @SCN-0003 @negative @priority-medium @REQ-004 @screen-step1
  Scenario: Jenis pengiriman LTL tidak menerapkan fitur auto stuffing
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user memilih jenis pengiriman "LTL"
    And user mengklik tombol "Selanjutnya"
    Then sistem tidak menampilkan tombol "Hitung Ulang Armada"
    And sistem tidak menampilkan tombol "Visualisasi Terbaru"

  @SCN-0004 @positive @priority-high @REQ-002 @REQ-007 @screen-daftar-order
  Scenario: Order FTL dapat dibuat manual melalui wizard 4 step maupun batch
    Given user berada di halaman "Daftar Order"
    Then sistem menampilkan tombol "Batch Order"
    When user mengklik tombol "Buat Order"
    Then sistem menampilkan "01 Data Pengiriman"
    And sistem menampilkan "02 Data Barang"
    And sistem menampilkan "03 Vendor dan Harga"
    And sistem menampilkan "04 Review"

  @SCN-0005 @negative @priority-high @REQ-003 @REQ-011 @screen-step2
  Scenario: Step 2 tidak menyediakan input deskripsi barang manual
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    When user memeriksa card "Armada 1"
    Then sistem tidak menampilkan field "Deskripsi Barang"
    And sistem menampilkan tombol "Pilih Barang"

  @SCN-0006 @positive @priority-high @REQ-006 @REQ-052 @screen-step4
  Scenario: Step 4 menyediakan pop up visualisasi muatan
    Given user berada di halaman "Buat Order - Step 4 Review"
    When user mengklik tombol "Visualisasi Muatan"
    Then sistem menampilkan dialog "Visualisasi Muatan"

  # ==========================================================================
  # B. STEP 1 - DATA PENGIRIMAN (REQ-007 .. REQ-010, REQ-055, REQ-057)
  # ==========================================================================

  @SCN-0007 @positive @priority-high @REQ-007 @screen-step1
  Scenario: Step 1 menampilkan seluruh field wajib beserta helper text
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user memeriksa form data pengiriman
    Then sistem menampilkan field "Jenis Armada"
    And sistem menampilkan field "Jumlah Armada"
    And sistem menampilkan field "Tipe Pengiriman"
    And sistem menampilkan "Nama PIC Pengirim"
    And sistem menampilkan "Contoh: 081234567898"

  @SCN-0008 @positive @priority-high @REQ-008 @screen-step1
  Scenario: Data pengirim dan penerima auto-draft dari Master Droppoint
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user memilih field "Drop Point Asal" dengan "Gudang MSK Region 2"
    Then field "Provinsi Asal" terisi otomatis
    And field "Kota/Kab. Asal" terisi otomatis
    And field "Alamat Asal" terisi otomatis

  @SCN-0009 @negative @priority-medium @REQ-008 @screen-step1
  Scenario: Field alamat hasil auto-draft bersifat read-only
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    And field alamat telah ter-auto-draft dari Master Droppoint
    When user mencoba mengubah field "Alamat Asal"
    Then field "Alamat Asal" bersifat read-only
    And field "Kode Pos" bersifat read-only

  @SCN-0010 @positive @priority-high @REQ-010 @screen-step1
  Scenario: Data Step 1 valid mengantar user ke Step 2
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user memilih field "Jenis Armada" dengan "Tronton Box"
    And user mengisi field "Jumlah Armada" dengan "2"
    And user memilih field "Tipe Pengiriman" dengan "Normal"
    And user melengkapi data pengirim dan penerima
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 2 Data Barang"

  @SCN-0011 @negative @priority-high @REQ-010 @screen-step1
  Scenario: Tombol Selanjutnya disabled saat Tipe Pengiriman belum dipilih
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user belum memilih field "Tipe Pengiriman"
    Then tombol "Selanjutnya" dalam kondisi disabled

  @SCN-0012 @negative @priority-high @REQ-010 @screen-step1
  Scenario: Field wajib Step 1 kosong memblokir navigasi ke Step 2
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user mengosongkan field "PIC Pengirim"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "PIC Pengirim wajib diisi"
    And user tetap berada di halaman "Buat Order - Step 1 Data Pengiriman"

  @SCN-0013 @positive @priority-high @REQ-009 @screen-step1
  Scenario: Multipickup menampilkan minimal dua grup Pick Up
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user memilih field "Tipe Pengiriman" dengan "Multipickup"
    And user mengklik tombol "Tambah Baris Input"
    Then sistem menampilkan grup "Pick Up 1"
    And sistem menampilkan grup "Pick Up 2"
    And grup "Pick Up 1" tidak memiliki tombol "Hapus"

  @SCN-0014 @negative @priority-high @REQ-009 @screen-step1
  Scenario: Multipickup dengan satu baris pengirim ditolak
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    And user memilih field "Tipe Pengiriman" dengan "Multipickup"
    When user hanya mengisi grup "Pick Up 1"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Minimal 2 alamat pengirim untuk Multipickup"
    And user tetap berada di halaman "Buat Order - Step 1 Data Pengiriman"

  @SCN-0015 @positive @priority-high @REQ-009 @screen-step1
  Scenario: Multidrop menampilkan minimal dua grup Drop Off
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user memilih field "Tipe Pengiriman" dengan "Multidrop"
    And user mengklik tombol "Tambah Baris Input"
    Then sistem menampilkan grup "Drop Off 1"
    And sistem menampilkan grup "Drop Off 2"

  @SCN-0016 @negative @priority-high @REQ-009 @screen-step1
  Scenario: Multidrop dengan satu baris penerima ditolak
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    And user memilih field "Tipe Pengiriman" dengan "Multidrop"
    When user hanya mengisi grup "Drop Off 1"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Minimal 2 alamat penerima untuk Multidrop"
    And user tetap berada di halaman "Buat Order - Step 1 Data Pengiriman"

  @SCN-0017 @positive @priority-high @REQ-009 @screen-step1
  Scenario: Multipoint menampilkan grup Pick Up dan Drop Off sekaligus
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user memilih field "Tipe Pengiriman" dengan "Multipoint"
    And user menambah baris pengirim dan penerima
    Then sistem menampilkan grup "Pick Up 2"
    And sistem menampilkan grup "Drop Off 2"

  @SCN-0018 @negative @priority-high @REQ-009 @screen-step1
  Scenario: Multipoint dengan penerima kurang dari dua ditolak
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    And user memilih field "Tipe Pengiriman" dengan "Multipoint"
    When user mengisi 2 grup Pick Up dan hanya 1 grup Drop Off
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Minimal 2 alamat penerima untuk Multipoint"
    And user tetap berada di halaman "Buat Order - Step 1 Data Pengiriman"

  @SCN-0019 @edge @priority-medium @REQ-007 @screen-step1
  Scenario: Jumlah Armada minimal satu diterima
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user mengisi field "Jumlah Armada" dengan "1"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 2 Data Barang"
    And sistem menampilkan "Jumlah Armada: 1"

  @negative @priority-high @REQ-007 @screen-step1
  Scenario Outline: Jumlah Armada tidak valid ditolak pada Step 1 - <id>
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user mengisi field "Jumlah Armada" dengan "<jumlah>"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "<pesan>"
    And user tetap berada di halaman "Buat Order - Step 1 Data Pengiriman"

    Examples:
      | id       | jumlah | pesan                            |
      | SCN-0020 | 0      | Jumlah Armada minimal 1          |
      | SCN-0021 |        | Jumlah Armada wajib diisi        |
      | SCN-0022 | abc    | Jumlah Armada harus berupa angka |

  @SCN-0023 @edge @priority-low @REQ-007 @screen-step1
  Scenario: Karakter spesial pada PIC Pengirim dan Catatan tersimpan aman
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user mengisi field "PIC Pengirim" dengan "O'Brien <Budi> & Co."
    And user mengisi field "Catatan" dengan "Muat pagi <script>alert(1)</script>"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 2 Data Barang"
    And sistem tidak mengeksekusi skrip pada input

  @SCN-0024 @negative @priority-medium @REQ-007 @screen-step1
  Scenario: Format No. WhatsApp PIC tidak valid ditolak
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user mengisi field "No. WhatsApp PIC" dengan "0812-abc-xyz"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Format nomor WhatsApp tidak valid"
    And user tetap berada di halaman "Buat Order - Step 1 Data Pengiriman"

  @SCN-0025 @positive @priority-high @REQ-055 @REQ-057 @screen-step1
  Scenario: Simpan ke Draf dari Step 1 menghasilkan status Isi Data Dasar
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    And user telah mengisi sebagian data pengiriman
    When user mengklik tombol "Simpan ke Draf"
    Then sistem menampilkan "Anda yakin ingin menyimpan data dalam draf?"
    When user mengklik tombol "Simpan Draf"
    Then user diarahkan ke halaman "Daftar Order"
    And sistem menampilkan badge status "Isi Data Dasar"

  @SCN-0026 @negative @priority-medium @REQ-010 @screen-step1
  Scenario: Batal pada Step 1 menampilkan pop up konfirmasi
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user mengklik tombol "Batal"
    Then sistem menampilkan dialog konfirmasi pembatalan pengisian
    And data order belum tersimpan

  # ==========================================================================
  # C. MODAL "PILIH BARANG" (REQ-011 .. REQ-016)
  # ==========================================================================

  @SCN-0027 @positive @priority-high @REQ-011 @screen-modal-pilih-barang
  Scenario: Modal Pilih Barang terbuka dari card armada
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    When user mengklik tombol "Pilih Barang" pada "Armada 1"
    Then sistem menampilkan dialog "Pilih Barang"
    And sistem menampilkan "Pilih barang yang ingin ditambahkan ke order"

  @SCN-0028 @positive @priority-high @REQ-012 @screen-modal-pilih-barang
  Scenario: Pencarian barang berdasarkan kode SKU dan nama barang
    Given user berada di halaman "Modal Pilih Barang"
    When user mengisi field "Cari kode/nama barang" dengan "SKU-PPR-001"
    Then sistem menampilkan item "SKU-PPR-001 - Kertas HVS A4 80 gsm"
    When user mengisi field "Cari kode/nama barang" dengan "kertas hvs"
    Then sistem menampilkan item "Kertas HVS A4 80 gsm"
    And sistem menampilkan item "Kertas HVS F4 70 gsm"

  @SCN-0029 @negative @priority-medium @REQ-012 @screen-modal-pilih-barang
  Scenario: Pencarian dengan kata kunci tidak ditemukan
    Given user berada di halaman "Modal Pilih Barang"
    When user mengisi field "Cari kode/nama barang" dengan "SKU-TIDAK-ADA-999"
    Then sistem menampilkan "Data tidak ditemukan"
    And sistem menampilkan "0 barang terpilih"

  @SCN-0030 @edge @priority-low @REQ-012 @screen-modal-pilih-barang
  Scenario: Pencarian dengan karakter spesial tidak menyebabkan error
    Given user berada di halaman "Modal Pilih Barang"
    When user mengisi field "Cari kode/nama barang" dengan "%' OR 1=1 --"
    Then sistem menampilkan "Data tidak ditemukan"
    And dialog "Pilih Barang" tetap terbuka

  @SCN-0031 @positive @priority-high @REQ-013 @REQ-015 @screen-modal-pilih-barang
  Scenario: Multi-select barang memperbarui counter terpilih secara live
    Given user berada di halaman "Modal Pilih Barang"
    When user mencentang checkbox barang "SKU-PPR-001"
    And user mencentang checkbox barang "SKU-PPR-002"
    And user mencentang checkbox barang "SKU-BKU-001"
    Then sistem menampilkan "3 barang terpilih"
    When user melepas checkbox barang "SKU-BKU-001"
    Then sistem menampilkan "2 barang terpilih"

  @SCN-0032 @positive @priority-high @REQ-014 @screen-modal-pilih-barang
  Scenario: Label Sudah Ditambahkan tampil pada barang yang telah masuk armada
    Given barang "SKU-PPR-002" telah ditambahkan ke "Armada 1"
    And user berada di halaman "Buat Order - Step 2 Data Barang"
    When user mengklik tombol "Pilih Barang" pada "Armada 1"
    Then item "SKU-PPR-002" menampilkan badge "Sudah Ditambahkan"

  @SCN-0033 @edge @priority-high @REQ-014 @REQ-013 @screen-modal-pilih-barang
  Scenario: Barang berlabel Sudah Ditambahkan tetap aktif dan tidak menduplikasi baris
    Given barang "SKU-PPR-002" telah ditambahkan ke "Armada 1"
    And user berada di halaman "Modal Pilih Barang" untuk "Armada 1"
    When user memeriksa checkbox barang "SKU-PPR-002"
    Then checkbox barang "SKU-PPR-002" tidak dalam kondisi disabled
    When user mengklik tombol "Simpan"
    Then card "Armada 1" menampilkan tepat 1 baris "SKU-PPR-002"

  @SCN-0034 @positive @priority-medium @REQ-014 @screen-modal-pilih-barang
  Scenario: Label Sudah Ditambahkan bersifat kontekstual per armada
    Given barang "SKU-PPR-002" telah ditambahkan ke "Armada 1"
    And user berada di halaman "Buat Order - Step 2 Data Barang"
    When user mengklik tombol "Pilih Barang" pada "Armada 2"
    Then item "SKU-PPR-002" tidak menampilkan badge "Sudah Ditambahkan"

  @SCN-0035 @positive @priority-high @REQ-016 @screen-modal-pilih-barang
  Scenario: Tombol Simpan menambahkan seluruh barang terpilih ke armada
    Given user berada di halaman "Modal Pilih Barang" untuk "Armada 1"
    When user mencentang checkbox barang "SKU-PPR-001"
    And user mencentang checkbox barang "SKU-BKU-001"
    And user mengklik tombol "Simpan"
    Then dialog "Pilih Barang" tertutup
    And card "Armada 1" menampilkan baris "SKU-PPR-001"
    And card "Armada 1" menampilkan baris "SKU-BKU-001"

  @SCN-0036 @negative @priority-high @REQ-016 @REQ-011 @screen-modal-pilih-barang
  Scenario: Tombol Batal menutup modal tanpa menambahkan barang
    Given user berada di halaman "Modal Pilih Barang" untuk "Armada 3"
    When user mencentang checkbox barang "SKU-PPR-001"
    And user mengklik tombol "Batal"
    Then dialog "Pilih Barang" tertutup
    And card "Armada 3" menampilkan "Belum ada barang"

  @SCN-0037 @negative @priority-low @REQ-016 @screen-modal-pilih-barang
  Scenario: Modal Pilih Barang tidak menyediakan tombol close sehingga ditutup via Batal
    Given user berada di halaman "Modal Pilih Barang"
    When user memeriksa header dialog
    Then dialog "Pilih Barang" tidak memiliki tombol "Tutup"
    And user dapat menutup dialog dengan tombol "Batal"

  @SCN-0038 @stress @priority-medium @REQ-013 @screen-modal-pilih-barang
  Scenario: Memilih 50 barang sekaligus dan menyimpannya ke armada
    Given user berada di halaman "Modal Pilih Barang" untuk "Armada 1"
    When user mencentang 50 checkbox barang
    Then sistem menampilkan "50 barang terpilih"
    When user mengklik tombol "Simpan"
    Then card "Armada 1" menampilkan 50 baris barang

  # ==========================================================================
  # D. STEP 2 - TABEL DATA BARANG (REQ-017 .. REQ-026, REQ-032)
  # ==========================================================================

  @SCN-0039 @positive @priority-high @REQ-017 @screen-step2
  Scenario: Kolom data barang ter-draft dari Master Barang dan read-only
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And barang "SKU-PPR-001" telah ditambahkan ke "Armada 1"
    When user memeriksa baris barang "SKU-PPR-001"
    Then sistem menampilkan "Kertas HVS A4 80 gsm"
    And sistem menampilkan "0,018 m3"
    And sistem menampilkan "12,5 kg"
    And sel "Kode SKU" bersifat read-only
    And sel "Kubikasi" bersifat read-only

  @SCN-0040 @positive @priority-high @REQ-018 @screen-step2
  Scenario: Mengisi field Jumlah pada setiap baris barang
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And barang "SKU-PPR-001" telah ditambahkan ke "Armada 1"
    When user mengisi field "Jumlah" baris "SKU-PPR-001" dengan "200"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 3 Vendor dan Harga"

  @SCN-0041 @negative @priority-high @REQ-018 @REQ-025 @screen-step2
  Scenario: Field Jumlah kosong menampilkan helper error dan border error
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And barang "SKU-PPR-001" telah ditambahkan ke "Armada 1"
    When user mengosongkan field "Jumlah" baris "SKU-PPR-001"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Jumlah harus diisi"
    And field "Jumlah" baris "SKU-PPR-001" berstatus error
    And user tetap berada di halaman "Buat Order - Step 2 Data Barang"

  @negative @priority-high @REQ-018 @REQ-025 @screen-step2
  Scenario Outline: Nilai Jumlah barang tidak valid ditolak - <id>
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And barang "SKU-PPR-001" telah ditambahkan ke "Armada 1"
    When user mengisi field "Jumlah" baris "SKU-PPR-001" dengan "<jumlah>"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "<pesan>"
    And user tetap berada di halaman "Buat Order - Step 2 Data Barang"

    Examples:
      | id       | jumlah | pesan                     |
      | SCN-0042 | 0      | Jumlah minimal 1          |
      | SCN-0043 | abc    | Jumlah harus berupa angka |

  @SCN-0044 @edge @priority-medium @REQ-018 @screen-step2
  Scenario: Jumlah barang bernilai satu sebagai batas bawah diterima
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And barang "SKU-PPR-001" telah ditambahkan ke "Armada 1"
    When user mengisi field "Jumlah" baris "SKU-PPR-001" dengan "1"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 3 Vendor dan Harga"

  @SCN-0045 @stress @priority-medium @REQ-018 @REQ-023 @screen-step2
  Scenario: Jumlah barang sangat besar memicu alert kapasitas namun tetap dapat lanjut
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And barang "SKU-PPR-001" telah ditambahkan ke "Armada 1"
    When user mengisi field "Jumlah" baris "SKU-PPR-001" dengan "999999"
    Then sistem menampilkan "Kubikasi melebihi kapasitas armada"
    When user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 3 Vendor dan Harga"

  @SCN-0046 @positive @priority-high @REQ-019 @REQ-020 @screen-step2
  Scenario: Checkbox Tambahkan Asuransi menampilkan kolom Nilai Barang untuk seluruh barang armada
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And "Armada 1" memiliki 2 baris barang
    When user mencentang checkbox "Tambahkan Asuransi" pada "Armada 1"
    Then sistem menampilkan "Berlaku untuk seluruh barang pada armada ini"
    And kolom "Nilai Barang" tampil pada seluruh baris "Armada 1"
    And kolom "Nilai Barang" tidak tampil pada "Armada 2"

  @SCN-0047 @positive @priority-high @REQ-019 @screen-step2
  Scenario: Kolom Nilai Barang tidak tampil dan tidak divalidasi saat asuransi non-aktif
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And checkbox "Tambahkan Asuransi" pada "Armada 2" tidak tercentang
    When user mengisi field "Jumlah" seluruh baris "Armada 2"
    And user mengklik tombol "Selanjutnya"
    Then kolom "Nilai Barang" tidak tampil pada "Armada 2"
    And user diarahkan ke halaman "Buat Order - Step 3 Vendor dan Harga"

  @SCN-0048 @negative @priority-high @REQ-019 @REQ-025 @screen-step2
  Scenario: Nilai Barang kosong saat asuransi aktif memblokir navigasi
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And checkbox "Tambahkan Asuransi" pada "Armada 1" tercentang
    When user mengosongkan field "Nilai Barang" baris "SKU-PPR-001"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Nilai Barang harus diisi"
    And field "Nilai Barang" baris "SKU-PPR-001" berstatus error
    And user tetap berada di halaman "Buat Order - Step 2 Data Barang"

  @SCN-0049 @edge @priority-medium @REQ-020 @REQ-025 @screen-step2
  Scenario: Melepas checkbox asuransi menghilangkan error Nilai Barang dan navigasi lolos
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And sistem menampilkan "Nilai Barang harus diisi" pada "Armada 1"
    When user melepas checkbox "Tambahkan Asuransi" pada "Armada 1"
    Then kolom "Nilai Barang" tidak tampil pada "Armada 1"
    When user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 3 Vendor dan Harga"

  @SCN-0050 @positive @priority-high @REQ-021 @screen-step2
  Scenario: Nomor DO dipisahkan koma dirender sebagai chip terpisah
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    When user mengisi field "Nomor DO" pada "Armada 1" dengan "TGK783898202U,TBL28371302"
    Then sistem menampilkan chip "TGK783898202U"
    And sistem menampilkan chip "TBL28371302"
    And sistem menampilkan "Pisahkan dengan koma untuk menambahkan beberapa nomor"

  @SCN-0051 @positive @priority-medium @REQ-021 @screen-step2
  Scenario: Nomor DO kosong tidak memblokir navigasi ke Step 3
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And field "Nomor DO" pada "Armada 1" dikosongkan
    When user mengisi field "Jumlah" seluruh baris barang
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 3 Vendor dan Harga"

  @SCN-0052 @edge @priority-low @REQ-021 @screen-step2
  Scenario: Menghapus chip Nomor DO dari armada
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And "Armada 1" memiliki chip "TGK783898202U"
    When user mengklik tombol "Hapus TGK783898202U"
    Then sistem tidak menampilkan chip "TGK783898202U"

  @SCN-0053 @stress @priority-low @REQ-021 @screen-step2
  Scenario: Lima puluh Nomor DO dengan payload panjang tetap dirender sebagai chip
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    When user mengisi field "Nomor DO" pada "Armada 1" dengan 50 nomor dipisahkan koma
    Then sistem menampilkan 50 chip Nomor DO
    And halaman Step 2 tetap responsif

  @SCN-0054 @positive @priority-high @REQ-022 @screen-step2
  Scenario: Menghapus baris barang melalui icon hapus
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And "Armada 1" memiliki baris "SKU-BKU-001"
    When user mengklik tombol "Hapus" pada baris "SKU-BKU-001"
    Then card "Armada 1" tidak menampilkan baris "SKU-BKU-001"

  @SCN-0055 @positive @priority-high @REQ-024 @screen-step2
  Scenario: Alert kubikasi melebihi kapasitas armada tampil
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    When total kubikasi "Armada 1" melebihi kubikasi maksimal armada
    Then sistem menampilkan "Kubikasi melebihi kapasitas armada"
    And sistem tidak menampilkan "Berat melebihi kapasitas armada" pada "Armada 1"

  @SCN-0056 @positive @priority-high @REQ-024 @screen-step2
  Scenario: Alert berat melebihi kapasitas armada tampil
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    When total berat "Armada 2" melebihi berat maksimal armada
    Then sistem menampilkan "Berat melebihi kapasitas armada"
    And sistem tidak menampilkan "Kubikasi melebihi kapasitas armada" pada "Armada 2"

  @SCN-0057 @edge @priority-high @REQ-024 @screen-step2
  Scenario: Alert gabungan tampil saat kubikasi dan berat melebihi kapasitas
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    When total kubikasi dan total berat "Armada 1" melebihi kapasitas maksimal armada
    Then sistem menampilkan "Kubikasi dan Berat melebihi kapasitas armada"
    And sistem tidak menampilkan dua alert terpisah pada "Armada 1"

  @SCN-0058 @positive @priority-high @REQ-023 @screen-step2
  Scenario: Alert kapasitas bersifat informatif dan tidak memblokir navigasi
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And sistem menampilkan "Kubikasi melebihi kapasitas armada"
    When user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 3 Vendor dan Harga"

  @SCN-0059 @positive @priority-high @REQ-026 @screen-step2
  Scenario: Informasi Data Unit dibawa dari Step 1
    Given user mengisi "Jenis Armada" dengan "Tronton Box" dan "Jumlah Armada" dengan "2" pada Step 1
    When user diarahkan ke halaman "Buat Order - Step 2 Data Barang"
    Then sistem menampilkan "Jenis Armada: Tronton Box"
    And sistem menampilkan "Jumlah Armada: 2"

  @SCN-0060 @negative @priority-medium @REQ-026 @screen-step2
  Scenario: Jumlah card armada harus sama dengan Jumlah Armada pada Data Unit
    Given user mengisi "Jumlah Armada" dengan "2" pada Step 1
    When user diarahkan ke halaman "Buat Order - Step 2 Data Barang"
    Then sistem menampilkan tepat 2 card armada
    And sistem tidak menampilkan card "Armada 3"

  @SCN-0061 @positive @priority-medium @REQ-032 @screen-step2
  Scenario: Tombol Sebelumnya mengembalikan user ke Step 1 dengan data tetap tersimpan
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    When user mengklik tombol "Sebelumnya"
    Then user diarahkan ke halaman "Buat Order - Step 1 Data Pengiriman"
    And field "Jumlah Armada" tetap bernilai "2"

  @SCN-0062 @positive @priority-high @REQ-032 @REQ-057 @screen-step2
  Scenario: Simpan ke Draf dari Step 2 menghasilkan status Isi Data Muatan
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    When user mengklik tombol "Simpan ke Draf"
    And user mengklik tombol "Simpan Draf"
    Then user diarahkan ke halaman "Daftar Order"
    And sistem menampilkan badge status "Isi Data Muatan"

  # ==========================================================================
  # E. FLOATING BUTTON AUTO STUFFING (REQ-027 .. REQ-029)
  # ==========================================================================

  @SCN-0063 @positive @priority-medium @REQ-027 @screen-step2
  Scenario: Floating button tetap mengikuti posisi saat halaman di-scroll
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    When user men-scroll halaman ke bagian bawah
    Then tombol "Hitung Ulang Armada" tetap terlihat
    And tombol "Visualisasi Terbaru" tetap terlihat

  @SCN-0064 @positive @priority-low @REQ-028 @screen-step2
  Scenario: Floating button menampilkan ikon saja dan label saat di-hover
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    Then label "Hitung Ulang Armada" tidak terlihat
    When user melakukan hover pada floating button "Hitung Ulang Armada"
    Then sistem menampilkan "Hitung Ulang Armada"

  @SCN-0065 @negative @priority-high @REQ-029 @screen-step2
  Scenario: Hitung Ulang Armada tidak dapat dijalankan tanpa data barang
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And seluruh armada belum memiliki data barang
    When user mengklik tombol "Hitung Ulang Armada"
    Then sistem tidak menampilkan dialog "Hitung Ulang Armada"
    And sistem menolak aksi hitung ulang armada

  @SCN-0066 @positive @priority-high @REQ-029 @REQ-033 @screen-drawer-hitung-ulang
  Scenario: Hitung Ulang Armada terbuka saat minimal satu data barang terisi
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And "Armada 1" memiliki 1 barang dengan Jumlah terisi
    When user mengklik tombol "Hitung Ulang Armada"
    Then sistem menampilkan dialog "Hitung Ulang Armada"
    And sistem menampilkan "Simulasi ulang kebutuhan unit dari muatan order ini."

  @SCN-0067 @stress @priority-low @REQ-029 @screen-drawer-hitung-ulang
  Scenario: Klik Hitung Ulang Armada sepuluh kali beruntun hanya membuka satu drawer
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And "Armada 1" memiliki data barang lengkap
    When user mengklik tombol "Hitung Ulang Armada" sebanyak 10 kali cepat
    Then sistem menampilkan tepat 1 dialog "Hitung Ulang Armada"

  # ==========================================================================
  # F. DRAWER HITUNG ULANG ARMADA & PANEL VISUALISASI (REQ-033 .. REQ-042)
  # ==========================================================================

  @SCN-0068 @positive @priority-high @REQ-033 @REQ-034 @screen-drawer-hitung-ulang
  Scenario: Drawer menampilkan total kubikasi berat dan jenis pengiriman
    Given user berada di halaman "Drawer Hitung Ulang Armada"
    When user memeriksa blok ringkasan
    Then sistem menampilkan "Total Kubikasi"
    And sistem menampilkan "Total Berat"
    And sistem menampilkan "Jenis Pengiriman FTL"

  @SCN-0069 @positive @priority-high @REQ-035 @screen-drawer-hitung-ulang
  Scenario: Drawer menampilkan tiga rekomendasi armada dengan indikator pemakaian
    Given user berada di halaman "Drawer Hitung Ulang Armada"
    When user memeriksa blok rekomendasi
    Then sistem menampilkan 3 kartu rekomendasi armada
    And setiap kartu menampilkan "Berat Terpakai"
    And setiap kartu menampilkan "Ruang Terpakai"

  @SCN-0070 @positive @priority-medium @REQ-036 @screen-drawer-hitung-ulang
  Scenario: Tepat satu rekomendasi diberi label Paling Efisien
    Given user berada di halaman "Drawer Hitung Ulang Armada"
    When user memeriksa label rekomendasi
    Then sistem menampilkan tepat 1 badge "Paling Efisien"
    And badge "Paling Efisien" berada pada kartu rekomendasi pertama

  @SCN-0071 @positive @priority-high @REQ-037 @REQ-038 @screen-drawer-hitung-ulang
  Scenario: Mengubah Jenis Armada melalui modal Pilih Jenis Armada memperbarui visualisasi
    Given user berada di halaman "Drawer Hitung Ulang Armada"
    When user mengklik tombol "Pilih Jenis Armada"
    And user memilih jenis armada "Fuso Box"
    Then field "Jenis Armada" bernilai "Fuso Box"
    And visualisasi muatan diperbarui sesuai armada "Fuso Box"

  @SCN-0072 @positive @priority-high @REQ-037 @REQ-038 @screen-drawer-hitung-ulang
  Scenario: Mengubah Jumlah Armada melalui stepper memperbarui visualisasi
    Given user berada di halaman "Drawer Hitung Ulang Armada"
    And field "Jumlah Armada" bernilai "2"
    When user mengklik tombol "Tambah jumlah armada"
    Then field "Jumlah Armada" bernilai "3"
    And sistem menampilkan tab "Armada 3"

  @SCN-0073 @edge @priority-medium @REQ-037 @screen-drawer-hitung-ulang
  Scenario: Stepper tidak dapat menurunkan Jumlah Armada di bawah satu
    Given user berada di halaman "Drawer Hitung Ulang Armada"
    And field "Jumlah Armada" bernilai "1"
    When user mengklik tombol "Kurangi jumlah armada"
    Then field "Jumlah Armada" bernilai "1"

  @SCN-0074 @positive @priority-medium @REQ-038 @screen-drawer-hitung-ulang
  Scenario: Kanvas visualisasi menampilkan overlay hint badge dan legenda per armada
    Given user berada di halaman "Drawer Hitung Ulang Armada"
    When user mengklik tab "Armada 2"
    Then sistem menampilkan "dialokasikan ke unit ini"
    And sistem menampilkan "Drag: putar 360"
    And sistem menampilkan "koli melebihi kapasitas"
    And sistem menampilkan legenda warna barang

  @SCN-0075 @positive @priority-high @REQ-039 @REQ-040 @screen-drawer-hitung-ulang
  Scenario: Terapkan ke Order menyinkronkan armada ke Step 1 dan Step 2
    Given user berada di halaman "Drawer Hitung Ulang Armada"
    When user memilih jenis armada "Tronton Wing Box"
    And user mengisi field "Jumlah Armada" dengan "3"
    And user mengklik tombol "Terapkan ke Order"
    Then sistem menampilkan "Jenis Armada: Tronton Wing Box"
    And sistem menampilkan "Jumlah Armada: 3"
    When user mengklik tombol "Sebelumnya"
    Then field "Jumlah Armada" tetap bernilai "3"

  @SCN-0076 @positive @priority-high @REQ-041 @screen-drawer-hitung-ulang
  Scenario: Batal pada drawer menutup panel tanpa mengubah data order
    Given user berada di halaman "Drawer Hitung Ulang Armada"
    And field "Jenis Armada" pada order bernilai "Tronton Box"
    When user memilih jenis armada "Fuso Box"
    And user mengklik tombol "Batal"
    Then dialog "Hitung Ulang Armada" tertutup
    And sistem menampilkan "Jenis Armada: Tronton Box"

  @SCN-0077 @stress @priority-low @REQ-038 @screen-drawer-hitung-ulang
  Scenario: Jumlah armada 99 menghasilkan tab visualisasi sebanyak armada
    Given user berada di halaman "Drawer Hitung Ulang Armada"
    When user mengisi field "Jumlah Armada" dengan "99"
    Then sistem menampilkan 99 tab armada
    And kanvas visualisasi dirender tanpa error

  @SCN-0078 @positive @priority-high @REQ-042 @screen-panel-visualisasi-terbaru
  Scenario: Visualisasi Terbaru menampilkan muatan sesuai armada terkini
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And order memakai "Tronton Box" sebanyak "2"
    When user mengklik tombol "Visualisasi Terbaru"
    Then sistem menampilkan dialog "Visualisasi Muatan Saat Ini"
    And sistem menampilkan "Jenis Armada: Tronton Box"
    And sistem menampilkan "Jumlah Armada: 2"
    And sistem menampilkan "Simulasi ulang kebutuhan unit dari muatan order ini."

  @SCN-0079 @negative @priority-high @REQ-042 @screen-panel-visualisasi-terbaru
  Scenario: Panel Visualisasi Terbaru tidak boleh mengubah pilihan armada
    Given user berada di halaman "Panel Visualisasi Muatan Saat Ini"
    And order memakai "Tronton Box" sebanyak "2"
    When user mengklik tombol "Terapkan ke Order"
    Then sistem menampilkan "Jenis Armada: Tronton Box"
    And sistem menampilkan "Jumlah Armada: 2"
    And pilihan armada pada Step 1 tidak berubah

  @SCN-0080 @positive @priority-medium @REQ-042 @screen-panel-visualisasi-terbaru
  Scenario: Batal pada panel Visualisasi Terbaru menutup panel tanpa perubahan
    Given user berada di halaman "Panel Visualisasi Muatan Saat Ini"
    When user mengklik tombol "Batal"
    Then dialog "Visualisasi Muatan Saat Ini" tertutup
    And sistem menampilkan "Jenis Armada: Tronton Box"

  # ==========================================================================
  # G. LOGIC DISTRIBUSI AUTO STUFFING (REQ-005, REQ-030, REQ-031)
  # ==========================================================================

  @SCN-0081 @positive @priority-high @REQ-030 @REQ-005 @screen-drawer-hitung-ulang
  Scenario: Armada pertama diisi hingga maksimal sebelum armada berikutnya dipakai
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And total muatan melebihi kapasitas satu armada
    When user mengklik tombol "Hitung Ulang Armada"
    And user mengklik tombol "Terapkan ke Order"
    Then "Armada 1" terisi hingga mendekati kapasitas maksimal
    And sisa muatan ditempatkan pada "Armada 2"
    And seluruh muatan teralokasi tanpa sisa

  @SCN-0082 @positive @priority-high @REQ-031 @screen-step2
  Scenario: Multipickup membagi rata barang antar alamat dalam satu armada
    Given order bertipe "Multipickup" dengan 2 alamat pengirim
    And total barang "Armada 1" berjumlah 200 koli
    When user menjalankan Hitung Ulang Armada dan menerapkannya
    Then grup "Pick Up 1" pada "Armada 1" berisi 100 koli
    And grup "Pick Up 2" pada "Armada 1" berisi 100 koli

  @SCN-0083 @edge @priority-high @REQ-031 @screen-step2
  Scenario: Sisa pembagian yang lebih besar ditempatkan pada alamat pertama
    Given order bertipe "Multipickup" dengan 3 alamat pengirim
    And total barang "Armada 1" berjumlah 100 koli
    When user menjalankan Hitung Ulang Armada dan menerapkannya
    Then grup "Pick Up 1" pada "Armada 1" berisi 34 koli
    And grup "Pick Up 2" pada "Armada 1" berisi 33 koli
    And grup "Pick Up 3" pada "Armada 1" berisi 33 koli

  @SCN-0084 @positive @priority-medium @REQ-031 @screen-step2
  Scenario: Multipoint mendistribusikan barang per pasangan Pick Up dan Drop Off
    Given order bertipe "Multipoint" dengan 2 pengirim dan 2 penerima
    When user menjalankan Hitung Ulang Armada dan menerapkannya
    Then sistem menampilkan 4 sub-grup pasangan alamat pada "Armada 1"
    And setiap sub-grup memiliki tabel barang tersendiri

  @SCN-0085 @stress @priority-medium @REQ-030 @REQ-005 @screen-step2
  Scenario: Distribusi 200 SKU ke banyak armada diselesaikan sistem
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And user menambahkan 200 SKU dengan jumlah terisi
    When user mengklik tombol "Hitung Ulang Armada"
    Then sistem menampilkan dialog "Hitung Ulang Armada" dalam waktu wajar
    And seluruh 200 SKU teralokasi setelah "Terapkan ke Order"

  # ==========================================================================
  # H. STEP 3 - VENDOR DAN HARGA (REQ-043 .. REQ-048, REQ-057)
  # ==========================================================================

  @SCN-0086 @positive @priority-high @REQ-043 @screen-step3
  Scenario: Step 3 menampilkan seluruh field vendor dan harga
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    When user memeriksa form vendor dan harga
    Then sistem menampilkan field "Vendor"
    And sistem menampilkan field "Tanggal Permintaan Muat"
    And sistem menampilkan field "Harga"
    And sistem menampilkan "Mencakup seluruh biaya armada pada order ini"
    And sistem menampilkan checkbox "Gunakan komponen harga"

  @SCN-0087 @positive @priority-high @REQ-043 @REQ-048 @screen-step3
  Scenario: Data Step 3 lengkap mengantar user ke Step 4
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    When user memilih field "Vendor" dengan "PT Logistik Transportasi Nusantara"
    And user mengisi field "Tanggal Permintaan Muat" dengan "24/07/2026 14:30"
    And user mengisi field "Waktu Perjalanan" dengan "8"
    And user mengisi field "Harga" dengan "12000000"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 4 Review"

  @SCN-0088 @negative @priority-high @REQ-048 @screen-step3
  Scenario: Field wajib Step 3 kosong memblokir navigasi ke Step 4
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    When user mengosongkan field "Vendor"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Vendor wajib diisi"
    And user tetap berada di halaman "Buat Order - Step 3 Vendor dan Harga"

  @SCN-0089 @negative @priority-medium @REQ-043 @screen-step3
  Scenario: Tanggal Permintaan Muat di masa lalu ditolak
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    When user mengisi field "Tanggal Permintaan Muat" dengan "01/01/2020 08:00"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Tanggal Permintaan Muat tidak boleh di masa lalu"
    And user tetap berada di halaman "Buat Order - Step 3 Vendor dan Harga"

  @SCN-0090 @positive @priority-high @REQ-044 @screen-step3
  Scenario: Rute belum ada di master menampilkan Waktu Perjalanan sebagai textfield
    Given rute order belum terdaftar pada Master Waktu Perjalanan
    And user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    Then sistem menampilkan "Rute belum ada di Master Waktu Perjalanan."
    When user mengisi field "Waktu Perjalanan" dengan "8"
    Then field "Waktu Perjalanan" bernilai "8"

  @SCN-0091 @negative @priority-high @REQ-044 @screen-step3
  Scenario: Rute sudah ada di master menampilkan Waktu Perjalanan sebagai text-only
    Given rute order sudah terdaftar pada Master Waktu Perjalanan
    And user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    When user mencoba mengisi "Waktu Perjalanan"
    Then sistem menampilkan "Waktu Perjalanan : 8 Jam"
    And field "Waktu Perjalanan" tidak dapat diisi

  @SCN-0092 @positive @priority-medium @REQ-045 @screen-step3
  Scenario: Ringkasan alamat Multipickup tampil sebagai label dan text link
    Given order bertipe "Multipickup"
    And user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    Then sistem menampilkan "Drop Point Asal : Multipickup"
    When user mengklik link "Lihat Detail"
    Then sistem menampilkan dialog "Detail Multipickup"

  @SCN-0093 @positive @priority-medium @REQ-045 @screen-step3
  Scenario: Ringkasan alamat Multidrop membuka pop up Detail Multidrop
    Given order bertipe "Multidrop"
    And user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    When user mengklik link "Lihat Detail"
    Then sistem menampilkan dialog "Detail Multidrop"
    And sistem menampilkan "Drop Off 1"

  @SCN-0094 @positive @priority-high @REQ-046 @screen-step3
  Scenario: Checkbox Gunakan komponen harga menampilkan input PPN dan PPh
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    When user mencentang checkbox "Gunakan komponen harga"
    Then sistem menampilkan field "PPN"
    And sistem menampilkan field "PPh"
    When user mengisi field "PPN" dengan "1,1"
    Then rincian harga menampilkan "PPN (1,1%)"

  @SCN-0095 @positive @priority-high @REQ-047 @screen-step3
  Scenario: Komponen asuransi dihitung dari persentase dikali total nilai barang
    Given terdapat armada yang diasuransikan pada Step 2
    And user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    When user mencentang checkbox "Gunakan komponen harga"
    And user mengisi field "Asuransi" dengan "0,2"
    Then sistem menampilkan rincian "Asuransi (0,2%)"
    And nilai Asuransi sama dengan persentase dikali Total Nilai Barang
    And Total Harga mencakup komponen Asuransi PPN dan PPh

  @SCN-0096 @negative @priority-high @REQ-047 @screen-step3
  Scenario: Tanpa armada diasuransikan komponen asuransi tidak dihitung
    Given tidak ada armada yang diasuransikan pada Step 2
    And user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    When user mencentang checkbox "Gunakan komponen harga"
    Then sistem tidak menampilkan field "Asuransi"
    And tabel ringkasan armada menampilkan "Tanpa Asuransi"
    And Total Harga tidak mencakup komponen Asuransi

  @SCN-0097 @negative @priority-medium @REQ-043 @screen-step3
  Scenario: Harga bernilai negatif ditolak
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    When user mengisi field "Harga" dengan "-1000"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Harga tidak boleh negatif"
    And user tetap berada di halaman "Buat Order - Step 3 Vendor dan Harga"

  @SCN-0098 @positive @priority-medium @REQ-057 @screen-step3
  Scenario: Simpan ke Draf dari Step 3 menghasilkan status Isi Data Vendor
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    When user mengklik tombol "Simpan ke Draf"
    And user mengklik tombol "Simpan Draf"
    Then user diarahkan ke halaman "Daftar Order"
    And sistem menampilkan badge status "Isi Data Vendor"

  # ==========================================================================
  # I. STEP 4 - REVIEW (REQ-049 .. REQ-053, REQ-057)
  # ==========================================================================

  @SCN-0099 @positive @priority-high @REQ-049 @screen-step4
  Scenario: Step 4 menampilkan ringkasan seluruh data Step 1 sampai Step 3 secara read-only
    Given user berada di halaman "Buat Order - Step 4 Review"
    When user memeriksa seluruh accordion review
    Then sistem menampilkan "Jenis Pengiriman dan Rute"
    And sistem menampilkan "Data Pengirim"
    And sistem menampilkan "Data Penerima"
    And sistem menampilkan "Data Barang"
    And sistem menampilkan "Vendor dan Harga"
    And seluruh field pada Review bersifat read-only

  @SCN-0100 @positive @priority-high @REQ-050 @screen-step4
  Scenario: Data Barang pada Review mengikuti struktur Step 2
    Given user berada di halaman "Buat Order - Step 4 Review"
    When user memeriksa tabel Data Barang
    Then sistem menampilkan kolom "Kode SKU"
    And sistem menampilkan kolom "Kemasan"
    And sistem menampilkan kolom "Kubikasi"
    And sistem menampilkan kolom "Berat"
    And sistem menampilkan kolom "Jumlah"

  @SCN-0101 @positive @priority-high @REQ-050 @REQ-051 @screen-step4
  Scenario: Label Diasuransikan dan kolom Nilai Barang hanya untuk armada berasuransi
    Given "Armada 2" diasuransikan dan "Armada 1" tidak
    And user berada di halaman "Buat Order - Step 4 Review"
    Then grup "Armada 2" menampilkan badge "Diasuransikan"
    And grup "Armada 2" menampilkan kolom "Nilai Barang"
    And grup "Armada 1" tidak menampilkan badge "Diasuransikan"
    And grup "Armada 1" tidak menampilkan kolom "Nilai Barang"

  @SCN-0102 @positive @priority-high @REQ-052 @REQ-006 @screen-popup-visualisasi-muatan
  Scenario: Pop up Visualisasi Muatan menampilkan tab metrik dan dapat ditutup
    Given user berada di halaman "Buat Order - Step 4 Review"
    When user mengklik tombol "Visualisasi Muatan"
    Then sistem menampilkan dialog "Visualisasi Muatan"
    And sistem menampilkan "Berat Terpakai"
    And sistem menampilkan "Ruang Terpakai"
    When user mengklik tombol "Tutup"
    Then dialog "Visualisasi Muatan" tertutup

  @SCN-0103 @positive @priority-high @REQ-053 @screen-step4
  Scenario: Simpan pada Step 4 mengubah status order menjadi Menunggu Penugasan
    Given user berada di halaman "Buat Order - Step 4 Review"
    And seluruh data order telah lengkap
    When user mengklik tombol "Simpan"
    Then user diarahkan ke halaman "Daftar Order"
    And sistem menampilkan badge status "Menunggu Penugasan"

  @SCN-0104 @positive @priority-medium @REQ-057 @screen-step4
  Scenario: Simpan ke Draf dari Step 4 menghasilkan status Review Order
    Given user berada di halaman "Buat Order - Step 4 Review"
    When user mengklik tombol "Simpan ke Draf"
    And user mengklik tombol "Simpan Draf"
    Then user diarahkan ke halaman "Daftar Order"
    And sistem menampilkan badge status "Review Order"

  @SCN-0105 @negative @priority-medium @REQ-053 @screen-step4
  Scenario: Batal pada Step 4 menampilkan pop up konfirmasi dan tidak menyimpan order
    Given user berada di halaman "Buat Order - Step 4 Review"
    When user mengklik tombol "Batal"
    Then sistem menampilkan dialog konfirmasi pembatalan pengisian
    And order tidak berstatus "Menunggu Penugasan"

  @SCN-0106 @edge @priority-medium @REQ-050 @screen-step4
  Scenario: Jumlah grup armada pada Review sama dengan Jumlah Armada order
    Given order memakai "Jumlah Armada" bernilai "2"
    And user berada di halaman "Buat Order - Step 4 Review"
    When user memeriksa bagian Data Barang
    Then sistem menampilkan tepat 2 grup armada
    And penomoran grup armada tidak duplikat

  # ==========================================================================
  # J. STATUS ORDER & DRAFT (REQ-054 .. REQ-057)
  # ==========================================================================

  @SCN-0107 @positive @priority-high @REQ-054 @screen-daftar-order
  Scenario: Badge status pada Daftar Order hanya menampilkan status yang valid
    Given user berada di halaman "Daftar Order"
    When user memeriksa kolom Status
    Then setiap badge status bernilai salah satu dari "Isi Data Dasar, Isi Data Muatan, Isi Data Vendor, Review Order, Menunggu Penugasan, Ditugaskan, Proses Pengiriman, Terkirim, Dibatalkan"

  @SCN-0108 @negative @priority-medium @REQ-057 @screen-step2
  Scenario: Batal pada pop up Simpan Draf membatalkan penyimpanan draf
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    When user mengklik tombol "Simpan ke Draf"
    Then sistem menampilkan "Anda yakin ingin menyimpan data dalam draf?"
    When user mengklik tombol "Batal"
    Then dialog konfirmasi draf tertutup
    And user tetap berada di halaman "Buat Order - Step 2 Data Barang"

  @SCN-0109 @positive @priority-high @REQ-055 @REQ-066 @screen-daftar-order
  Scenario: Lanjutkan Pengisian membuka wizard pada step terakhir
    Given terdapat order berstatus "Isi Data Muatan"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada order tersebut
    And user mengklik menu "Lanjutkan Pengisian"
    Then user diarahkan ke halaman "Buat Order - Step 2 Data Barang"

  @SCN-0110 @positive @priority-medium @REQ-056 @screen-daftar-order
  Scenario: Status order berubah menjadi Ditugaskan setelah vendor melakukan penugasan
    Given order berstatus "Menunggu Penugasan"
    When vendor melakukan penugasan armada pada order tersebut
    And user membuka halaman "Daftar Order"
    Then sistem menampilkan badge status "Ditugaskan"

  # ==========================================================================
  # K. EDIT ORDER (REQ-058 .. REQ-062)
  # ==========================================================================

  @SCN-0111 @positive @priority-high @REQ-058 @screen-edit-order
  Scenario: Order berstatus Menunggu Penugasan dapat diedit dan disimpan
    Given terdapat order berstatus "Menunggu Penugasan"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada order tersebut
    And user mengklik menu "Edit"
    Then user diarahkan ke halaman "Edit Order"
    When user mengisi field "Jumlah Armada" dengan "3"
    And user mengklik tombol "Simpan"
    And user mengonfirmasi pop up konfirmasi
    Then sistem menampilkan "Perubahan order berhasil disimpan"

  @SCN-0112 @negative @priority-high @REQ-059 @screen-daftar-order
  Scenario: Aksi Edit tidak tersedia pada order berstatus Ditugaskan
    Given terdapat order berstatus "Ditugaskan"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada order tersebut
    Then sistem tidak menampilkan menu "Edit"
    And sistem menampilkan menu "Detail"

  @SCN-0113 @positive @priority-high @REQ-060 @screen-edit-order
  Scenario: Jenis Pengiriman dan Tipe Pengiriman terkunci pada Edit Order
    Given user berada di halaman "Edit Order"
    When user memeriksa bagian jenis dan tipe pengiriman
    Then sistem menampilkan "Jenis Pengiriman : FTL (Full Truck Load)"
    And sistem menampilkan "Tipe Pengiriman : Normal"
    And field "Tipe Pengiriman" bersifat read-only

  @SCN-0114 @positive @priority-high @REQ-061 @screen-edit-order
  Scenario: Jenis Armada Jumlah Armada dan Data Barang tetap dapat diubah pada Edit Order
    Given user berada di halaman "Edit Order"
    When user memilih field "Jenis Armada" dengan "Tronton Wing Box"
    And user mengisi field "Jumlah Armada" dengan "3"
    And user mengklik tombol "Pilih Barang" pada "Data Barang - Armada 1"
    Then dialog "Pilih Barang" terbuka
    And field "Jumlah Armada" bernilai "3"

  @SCN-0115 @positive @priority-high @REQ-062 @screen-edit-order
  Scenario: Simpan pada Edit Order menampilkan pop up konfirmasi
    Given user berada di halaman "Edit Order"
    And user telah mengubah field "Jumlah Armada"
    When user mengklik tombol "Simpan"
    Then sistem menampilkan dialog konfirmasi penyimpanan perubahan
    And perubahan belum tersimpan sebelum konfirmasi

  @SCN-0116 @positive @priority-high @REQ-062 @screen-edit-order
  Scenario: Batal pada Edit Order menampilkan pop up konfirmasi dan membatalkan perubahan
    Given user berada di halaman "Edit Order"
    And user telah mengubah field "Jumlah Armada" menjadi "5"
    When user mengklik tombol "Batal"
    Then sistem menampilkan dialog konfirmasi pembatalan pengeditan
    When user mengonfirmasi pembatalan
    Then user diarahkan ke halaman "Detail Order"
    And nilai "Jumlah Armada" tidak berubah menjadi "5"

  @SCN-0117 @negative @priority-medium @REQ-061 @screen-edit-order
  Scenario: Halaman Edit Order tidak menampilkan floating button auto stuffing
    Given user berada di halaman "Edit Order"
    When user memeriksa area floating button
    Then sistem tidak menampilkan tombol "Hitung Ulang Armada"
    And sistem tidak menampilkan tombol "Visualisasi Terbaru"

  @SCN-0118 @edge @priority-low @REQ-061 @screen-edit-order
  Scenario: Heading card Data Barang pada Edit Order Multipickup harus memakai istilah Armada
    Given order FTL bertipe "Multipickup" berstatus "Menunggu Penugasan"
    And user berada di halaman "Edit Order"
    When user memeriksa heading card data barang
    Then sistem menampilkan "Data Barang - Armada 1"
    And sistem tidak menampilkan "Data Barang - Kontainer 1"

  @SCN-0119 @negative @priority-high @REQ-059 @screen-edit-order
  Scenario: Akses langsung URL Edit Order untuk order Ditugaskan ditolak
    Given terdapat order berstatus "Ditugaskan"
    When user mengakses langsung URL halaman "Edit Order" untuk order tersebut
    Then sistem menolak akses pengeditan
    And user diarahkan ke halaman "Detail Order"

  # ==========================================================================
  # L. PEMBATALAN ORDER (REQ-063 .. REQ-065, REQ-069)
  # ==========================================================================

  @SCN-0120 @positive @priority-high @REQ-063 @REQ-065 @screen-popup-batalkan-order
  Scenario: Order berstatus draft dapat dibatalkan dengan alasan pembatalan
    Given terdapat order berstatus "Isi Data Muatan"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada order tersebut
    And user mengklik menu "Batalkan Order"
    Then sistem menampilkan dialog "Batalkan Order"
    When user mengisi field "Alasan Pembatalan" dengan "Perubahan rencana pengiriman dari customer"
    And user mengklik tombol "Batalkan Order"
    Then sistem menampilkan badge status "Dibatalkan"

  @SCN-0121 @positive @priority-medium @REQ-063 @screen-daftar-order
  Scenario: Order berstatus Ditugaskan masih dapat dibatalkan
    Given terdapat order berstatus "Ditugaskan"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada order tersebut
    Then sistem menampilkan menu "Batalkan Order"

  @SCN-0122 @negative @priority-high @REQ-063 @screen-daftar-order
  Scenario: Order berstatus Proses Pengiriman tidak dapat dibatalkan
    Given terdapat order berstatus "Proses Pengiriman"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada order tersebut
    Then sistem tidak menampilkan menu "Batalkan Order"

  @SCN-0123 @negative @priority-high @REQ-065 @screen-popup-batalkan-order
  Scenario: Alasan Pembatalan kosong menolak submit pembatalan
    Given user berada di halaman "Pop up Batalkan Order"
    Then field "Alasan Pembatalan" menampilkan placeholder "Tuliskan alasan pembatalan order"
    When user mengosongkan field "Alasan Pembatalan"
    And user mengklik tombol "Batalkan Order"
    Then sistem menampilkan "Alasan Pembatalan wajib diisi"
    And status order tidak berubah menjadi "Dibatalkan"

  @SCN-0124 @edge @priority-medium @REQ-065 @screen-popup-batalkan-order
  Scenario: Alasan Pembatalan berisi spasi saja ditolak
    Given user berada di halaman "Pop up Batalkan Order"
    When user mengisi field "Alasan Pembatalan" dengan "     "
    And user mengklik tombol "Batalkan Order"
    Then sistem menampilkan "Alasan Pembatalan wajib diisi"
    And status order tidak berubah menjadi "Dibatalkan"

  @SCN-0125 @stress @priority-low @REQ-065 @screen-popup-batalkan-order
  Scenario: Alasan Pembatalan sepanjang 5000 karakter ditangani sistem
    Given user berada di halaman "Pop up Batalkan Order"
    When user mengisi field "Alasan Pembatalan" dengan teks 5000 karakter
    And user mengklik tombol "Batalkan Order"
    Then sistem memberi respons tanpa error server
    And sistem menampilkan batas maksimal karakter atau status "Dibatalkan"

  @SCN-0126 @negative @priority-high @REQ-064 @screen-daftar-order
  Scenario: Vendor tidak memiliki aksi Batalkan Order
    Given user login sebagai "Vendor"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada order berstatus "Ditugaskan"
    Then sistem tidak menampilkan menu "Batalkan Order"

  @SCN-0127 @positive @priority-medium @REQ-069 @screen-daftar-order
  Scenario: Tombol Riwayat Pembatalan menampilkan seluruh order yang pernah dibatalkan
    Given user berada di halaman "Daftar Order"
    When user mengklik tombol "Riwayat Pembatalan"
    Then user diarahkan ke halaman "Riwayat Pembatalan"
    And sistem menampilkan daftar order berstatus "Dibatalkan"

  # ==========================================================================
  # M. AKSI PADA DAFTAR ORDER (REQ-066 .. REQ-069)
  # ==========================================================================

  @SCN-0128 @positive @priority-high @REQ-066 @screen-daftar-order
  Scenario: Action menu order draft menampilkan empat aksi sesuai spesifikasi
    Given terdapat order berstatus "Isi Data Dasar"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada order tersebut
    Then sistem menampilkan menu "Detail"
    And sistem menampilkan menu "Lanjutkan Pengisian"
    And sistem menampilkan menu "Batalkan Order"
    And sistem menampilkan menu "Riwayat Perubahan"

  @SCN-0129 @positive @priority-high @REQ-067 @screen-daftar-order
  Scenario: Action menu order Menunggu Penugasan menampilkan aksi Edit
    Given terdapat order berstatus "Menunggu Penugasan"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada order tersebut
    Then sistem menampilkan menu "Detail"
    And sistem menampilkan menu "Edit"
    And sistem menampilkan menu "Batalkan Order"
    And sistem menampilkan menu "Riwayat Perubahan"
    And sistem tidak menampilkan menu "Lanjutkan Pengisian"

  @SCN-0130 @positive @priority-high @REQ-068 @REQ-073 @screen-daftar-order
  Scenario: Action menu order Ditugaskan menampilkan Lihat No. Perjalanan
    Given terdapat order berstatus "Ditugaskan"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada order tersebut
    Then sistem menampilkan menu "Detail"
    And sistem menampilkan menu "Lihat No. Perjalanan"
    And sistem menampilkan menu "Batalkan Order"
    And sistem menampilkan menu "Riwayat Perubahan"

  @SCN-0131 @negative @priority-medium @REQ-068 @screen-daftar-order
  Scenario: Action menu order Ditugaskan tidak boleh memuat aksi di luar spesifikasi
    Given terdapat order berstatus "Ditugaskan"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada order tersebut
    Then sistem tidak menampilkan menu "Edit"
    And sistem tidak menampilkan menu "Order Kembali"

  @SCN-0132 @positive @priority-medium @REQ-069 @screen-daftar-order
  Scenario: Riwayat Perubahan menampilkan histori order terkait saja
    Given terdapat order dengan ID "ORD-20260607009"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada order tersebut
    And user mengklik menu "Riwayat Perubahan"
    Then sistem menampilkan histori perubahan order "ORD-20260607009"
    And sistem tidak menampilkan daftar seluruh order yang dibatalkan

  @SCN-0133 @edge @priority-low @REQ-069 @screen-daftar-order
  Scenario: Panel filter Daftar Order dapat diterapkan dan direset
    Given user berada di halaman "Daftar Order"
    When user mengklik tombol "Filter"
    Then field "Tipe Pengiriman" dalam kondisi disabled
    When user memilih field "Jenis Order" dengan "FTL"
    And user memilih field "Status" dengan "Menunggu Penugasan"
    And user mengklik tombol "Terapkan"
    Then seluruh baris tabel menampilkan badge status "Menunggu Penugasan"
    When user mengklik tombol "Reset"
    Then filter Daftar Order kembali kosong

  # ==========================================================================
  # N. NO. PERJALANAN (REQ-070 .. REQ-076)
  # ==========================================================================

  @SCN-0134 @positive @priority-high @REQ-073 @REQ-074 @screen-popup-no-perjalanan
  Scenario: Pop up Data No. Perjalanan menampilkan data per armada
    Given terdapat order FTL berstatus "Ditugaskan"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada order tersebut
    And user mengklik menu "Lihat No. Perjalanan"
    Then sistem menampilkan dialog "Data No. Perjalanan"
    And setiap baris menampilkan No. Perjalanan
    And setiap baris menampilkan Nopol dan Jenis Armada

  @SCN-0135 @negative @priority-high @REQ-073 @screen-daftar-order
  Scenario: Aksi Lihat No. Perjalanan tidak tampil sebelum status Ditugaskan
    Given terdapat order berstatus "Menunggu Penugasan"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada order tersebut
    Then sistem tidak menampilkan menu "Lihat No. Perjalanan"

  @SCN-0136 @positive @priority-high @REQ-071 @screen-popup-no-perjalanan
  Scenario: Jumlah No. Perjalanan sama dengan jumlah armada yang dipesan
    Given order FTL dengan "Jumlah Armada" bernilai "2" berstatus "Ditugaskan"
    And user berada di halaman "Pop up Data No. Perjalanan"
    When user memeriksa daftar unit
    Then sistem menampilkan tepat 2 No. Perjalanan

  @SCN-0137 @negative @priority-high @REQ-071 @screen-popup-no-perjalanan
  Scenario: No. Perjalanan antar armada harus unik
    Given order FTL dengan "Jumlah Armada" bernilai "2" berstatus "Ditugaskan"
    And user berada di halaman "Pop up Data No. Perjalanan"
    When user membandingkan No. Perjalanan pada kedua baris unit
    Then No. Perjalanan baris pertama tidak sama dengan baris kedua

  @SCN-0138 @positive @priority-low @REQ-075 @screen-popup-no-perjalanan
  Scenario: Ikon copy menyalin No. Perjalanan ke clipboard
    Given user berada di halaman "Pop up Data No. Perjalanan"
    When user mengklik tombol "Salin nomor perjalanan" pada baris pertama
    Then isi clipboard sama dengan No. Perjalanan baris pertama

  @SCN-0139 @negative @priority-medium @REQ-072 @screen-daftar-order
  Scenario: No. Perjalanan tidak tersedia untuk jenis pengiriman LTL
    Given terdapat order "LTL" berstatus "Ditugaskan"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada order tersebut
    Then sistem tidak menampilkan menu "Lihat No. Perjalanan"

  @SCN-0140 @positive @priority-medium @REQ-076 @screen-detail-order
  Scenario: Detail Order menampilkan No. Perjalanan
    Given terdapat order FTL berstatus "Ditugaskan"
    When user membuka halaman "Detail Order" untuk order tersebut
    Then sistem menampilkan No. Perjalanan pada halaman Detail Order

  @SCN-0141 @positive @priority-medium @REQ-070 @screen-public-tracking
  Scenario: Public tracking dengan No. Perjalanan valid menampilkan progress perjalanan
    Given terdapat No. Perjalanan valid dari order berstatus "Proses Pengiriman"
    And user berada di halaman "Public Tracking"
    When user mengisi field "No. Perjalanan" dengan nomor tersebut
    And user mengklik tombol "Lacak"
    Then sistem menampilkan progress perjalanan armada

  @SCN-0142 @negative @priority-medium @REQ-070 @screen-public-tracking
  Scenario: Public tracking dengan No. Perjalanan tidak valid ditolak
    Given user berada di halaman "Public Tracking"
    When user mengisi field "No. Perjalanan" dengan "TRC00000000"
    And user mengklik tombol "Lacak"
    Then sistem menampilkan "Nomor perjalanan tidak ditemukan"

  # ==========================================================================
  # O. STRESS, VOLUME & KONKURENSI
  # ==========================================================================

  @SCN-0143 @stress @priority-medium @REQ-071 @screen-popup-no-perjalanan
  Scenario: Order dengan 20 armada menghasilkan 20 No. Perjalanan unik
    Given order FTL dengan "Jumlah Armada" bernilai "20" berstatus "Ditugaskan"
    When user membuka halaman "Pop up Data No. Perjalanan"
    Then sistem menampilkan tepat 20 No. Perjalanan
    And seluruh No. Perjalanan bernilai unik

  @SCN-0144 @stress @priority-low @REQ-054 @screen-daftar-order
  Scenario: Menampilkan 100 data per halaman dan menavigasi paginasi
    Given user berada di halaman "Daftar Order"
    When user memilih field "Tampilkan data" dengan "100"
    Then sistem menampilkan informasi paginasi jumlah data
    When user mengklik tombol paginasi halaman terakhir
    Then tabel order dirender tanpa error

  @SCN-0145 @stress @priority-medium @REQ-011 @REQ-012 @screen-modal-pilih-barang
  Scenario: Modal Pilih Barang dengan 5000 item master tetap responsif
    Given Master Barang memiliki 5000 barang aktif
    And user berada di halaman "Buat Order - Step 2 Data Barang"
    When user mengklik tombol "Pilih Barang" pada "Armada 1"
    Then sistem menampilkan dialog "Pilih Barang"
    When user mengisi field "Cari kode/nama barang" dengan "SKU-PPR-4999"
    Then sistem menampilkan item "SKU-PPR-4999"

  @SCN-0146 @stress @priority-medium @REQ-030 @screen-step2
  Scenario: Sepuluh armada dengan 30 barang per armada dapat dirender dan dilanjutkan
    Given order memakai "Jumlah Armada" bernilai "10"
    And setiap armada memiliki 30 baris barang dengan Jumlah terisi
    When user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 3 Vendor dan Harga"

  @SCN-0147 @stress @priority-medium @REQ-058 @screen-edit-order
  Scenario: Dua sesi paralel mengedit order yang sama tidak menimpa data secara diam-diam
    Given order berstatus "Menunggu Penugasan" dibuka pada dua sesi browser
    When sesi pertama mengubah "Jumlah Armada" menjadi "3" lalu menyimpan
    And sesi kedua mengubah "Jumlah Armada" menjadi "4" lalu menyimpan
    Then sistem menampilkan peringatan konflik perubahan atau menyimpan perubahan terakhir secara konsisten
    And data order tidak menjadi tidak konsisten

  @SCN-0148 @stress @priority-high @REQ-053 @screen-step4
  Scenario: Klik ganda pada tombol Simpan Step 4 hanya membuat satu order
    Given user berada di halaman "Buat Order - Step 4 Review"
    When user mengklik tombol "Simpan" dua kali secara cepat
    Then sistem membuat tepat 1 order baru
    And sistem menampilkan badge status "Menunggu Penugasan"

  @SCN-0149 @stress @priority-medium @REQ-039 @screen-drawer-hitung-ulang
  Scenario: Klik Terapkan ke Order berulang cepat hanya menerapkan satu kali
    Given user berada di halaman "Drawer Hitung Ulang Armada"
    When user mengklik tombol "Terapkan ke Order" sebanyak 5 kali cepat
    Then dialog "Hitung Ulang Armada" tertutup
    And penempatan barang pada order tidak terduplikasi

  @SCN-0150 @stress @priority-medium @REQ-057 @screen-step3
  Scenario: Sesi timeout pada Step 3 tidak menghilangkan data draf
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    And user telah menyimpan order sebagai draf
    When sesi user timeout dan user login kembali
    And user membuka order draf tersebut melalui "Lanjutkan Pengisian"
    Then data Step 1 sampai Step 3 yang telah tersimpan tetap tersedia

  # ==========================================================================
  # P. TAMBAHAN REV-2 - TEMUAN DESAIN LANJUTAN (FND-11)
  # ==========================================================================

  @SCN-0151 @negative @priority-medium @REQ-076 @REQ-009 @screen-detail-order
  Scenario: Detail Order Multidrop harus menampilkan Tipe Pengiriman Multidrop
    Given terdapat order FTL bertipe "Multidrop" dengan 2 alamat penerima
    When user membuka halaman "Detail Order" untuk order tersebut
    Then sistem menampilkan "Tipe Pengiriman : Multidrop"
    And sistem tidak menampilkan "Tipe Pengiriman : Normal"
    And sistem menampilkan grup "Drop Off 2"
