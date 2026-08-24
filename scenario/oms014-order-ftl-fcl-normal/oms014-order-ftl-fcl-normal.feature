# language: id-compat (keyword Gherkin bahasa Inggris, narasi bahasa Indonesia)
# Modul  : OMS-014 — Order FTL & FCL (Normal/Multipickup/Multidrop/Multipoint) tanpa Auto Stuffing
# Sumber : output/oms014-order-ftl-fcl-normal/oms014-order-ftl-fcl-normal.analysis.md
# Dibuat : 2026-08-23
# Catatan : Semua Scenario ber-ID stabil "OMS014-<POS|NEG|EDG|STR>-NNN" yang 1:1 dengan
#           oms014-order-ftl-fcl-normal.scenarios.json

@oms014
Feature: OMS-014 Pembuatan Order FTL & FCL dengan add-on Auto Stuffing dinonaktifkan

  Sebagai Staff Operasional (Shipper)
  Saya ingin membuat, meninjau, mengedit, dan membatalkan Order FTL/FCL untuk seluruh tipe pengiriman
  Agar order dapat diproses tanpa keterlibatan logic maupun elemen UI Auto Stuffing

  Background:
    Given user login sebagai "Staff Operasional" pada tenant "Mentari Sumber Kertas"
    And toggle add-on "Auto Stuffing" berada dalam kondisi "OFF"
    And master data "Drop Point, Partner, Armada, Kontainer, Barang, Vendor, Pelabuhan" tersedia
    And kuota order masih tersedia

  # ==========================================================================================
  # KATEGORI: POSITIVE
  # ==========================================================================================

  @positive @priority-high @REQ-022 @screen-daftar-order @screen-app-shell
  Scenario: OMS014-POS-001: Halaman Daftar Order menampilkan aksi utama, kerangka aplikasi, dan tabel order
    Given user berada di halaman "Daftar Order"
    Then sistem menampilkan "Daftar Order"
    And sistem menampilkan "Buat Order"
    And sistem menampilkan "Batch Order"
    And sistem menampilkan "Riwayat Pembatalan"
    And sistem menampilkan "Filter"
    And sistem menampilkan "Kuota Order"
    And sistem menampilkan "Menampilkan 1 - 20 data dari 30 data"

  @positive @priority-high @REQ-012 @screen-daftar-order @screen-step1
  Scenario: OMS014-POS-002: Tombol Buat Order membuka wizard 4 step dengan stepper lengkap
    Given user berada di halaman "Daftar Order"
    When user mengklik tombol "Buat Order"
    Then user diarahkan ke halaman "Buat Order - Step 1 Data Pengiriman"
    And sistem menampilkan "01 Data Pengiriman"
    And sistem menampilkan "02 Data Barang"
    And sistem menampilkan "03 Vendor dan Harga"
    And sistem menampilkan "04 Review"

  @positive @priority-high @REQ-001 @screen-step1 @ftl @fcl
  Scenario Outline: OMS014-POS-003: Kartu jenis order <jenis> dapat dipilih dan menampilkan form Step 1 yang sesuai
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user memilih kartu jenis order "<jenis>"
    Then sistem menampilkan "<field1>"
    And sistem menampilkan "<field2>"
    And sistem menampilkan "Tipe Pengiriman"

    Examples:
      | jenis | field1            | field2         |
      | FTL   | Jenis Armada      | Jumlah Armada  |
      | FCL   | Pelabuhan Asal    | Jenis Kontainer|

  @positive @priority-high @REQ-001 @screen-step1
  Scenario: OMS014-POS-004: Dropdown Tipe Pengiriman memuat tepat empat opsi
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    And user memilih kartu jenis order "FTL"
    When user mengklik dropdown "Tipe Pengiriman"
    Then sistem menampilkan "Normal"
    And sistem menampilkan "Multipickup"
    And sistem menampilkan "Multidrop"
    And sistem menampilkan "Multipoint"
    And jumlah opsi pada dropdown "Tipe Pengiriman" adalah "4"

  @positive @priority-medium @REQ-001 @screen-step1 @fcl
  Scenario: OMS014-POS-005: FCL menampilkan empat opsi Metode Pengiriman
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user memilih kartu jenis order "FCL"
    Then sistem menampilkan "Door to Door"
    And sistem menampilkan "Door to CY"
    And sistem menampilkan "CY to CY"
    And sistem menampilkan "CY to Door"

  @positive @priority-medium @REQ-017 @screen-step1
  Scenario: OMS014-POS-006: Memilih Drop Point Asal melakukan auto-fill wilayah yang bersifat read-only
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    And user memilih kartu jenis order "FTL"
    And user memilih "Normal" pada dropdown "Tipe Pengiriman"
    When user memilih "Gudang MSK Region 2" pada dropdown "Drop Point Asal"
    Then field "Provinsi Asal" terisi otomatis dan bersifat read-only
    And field "Kota/Kab. Asal" terisi otomatis dan bersifat read-only
    And field "Kode Pos" terisi otomatis dan bersifat read-only
    And field "Alamat Asal" terisi otomatis dan bersifat read-only

  @positive @priority-high @REQ-003 @screen-pengaturan-sistem
  Scenario: OMS014-POS-007: System Admin mematikan toggle Auto Stuffing dan perubahan persist setelah reload
    Given user login sebagai "System Admin"
    And user berada di halaman "Pengaturan Sistem"
    When user menghapus centang checkbox "Auto Stuffing"
    And user mengklik tombol "Simpan"
    Then sistem menampilkan "Pengaturan berhasil disimpan"
    When user memuat ulang halaman "Pengaturan Sistem"
    Then toggle "Auto Stuffing" bernilai "OFF"

  @positive @priority-medium @REQ-002 @screen-pengaturan-sistem
  Scenario: OMS014-POS-008: Nilai default toggle Auto Stuffing pada instalasi baru adalah aktif
    Given sistem berada pada kondisi instalasi baru tanpa perubahan konfigurasi
    And user login sebagai "System Admin"
    When user berada di halaman "Pengaturan Sistem"
    Then toggle "Auto Stuffing" bernilai "ON"

  @positive @priority-medium @REQ-002 @screen-step2 @ftl
  Scenario: OMS014-POS-009: Kondisi kontrol - dengan toggle ON floating button Auto Stuffing tampil di Step 2
    Given toggle add-on "Auto Stuffing" berada dalam kondisi "ON"
    And user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal"
    Then sistem menampilkan "Hitung Ulang Armada"
    And sistem menampilkan "Visualisasi Terbaru"

  @positive @priority-medium @REQ-003 @screen-pengaturan-sistem @screen-daftar-order
  Scenario: OMS014-POS-010: Mengubah toggle Auto Stuffing tidak menghapus order yang sudah ada dan tidak memicu error
    Given terdapat 5 order tersimpan pada "Daftar Order"
    And user login sebagai "System Admin"
    When user mengubah toggle "Auto Stuffing" dari "ON" ke "OFF"
    Then sistem tidak menampilkan "500"
    And sistem menampilkan "Pengaturan berhasil disimpan"
    When user login sebagai "Staff Operasional"
    And user berada di halaman "Daftar Order"
    Then jumlah order pada tabel adalah "5"

  @positive @priority-high @REQ-001 @REQ-004 @REQ-012 @REQ-017 @REQ-026 @screen-step1 @screen-step2 @screen-step3 @screen-step4 @screen-daftar-order @ftl @fcl @normal @multipickup @multidrop @multipoint
  Scenario Outline: OMS014-POS-011: Order <jenis> tipe <tipe> dapat diselesaikan sampai Step 4 dan disimpan tanpa Auto Stuffing
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user memilih kartu jenis order "<jenis>"
    And user melengkapi seluruh field wajib Step 1 untuk jenis "<jenis>"
    And user memilih "<tipe>" pada dropdown "Tipe Pengiriman"
    And user melengkapi seluruh alamat wajib untuk tipe "<tipe>"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 2 Data Barang"
    And sistem tidak menampilkan "Hitung Ulang Armada"
    And sistem tidak menampilkan "Hitung Ulang Kontainer"
    And sistem tidak menampilkan "Visualisasi Terbaru"
    When user mengisi data barang manual pada seluruh <unit> dan seluruh sub-section alamat
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 3 Vendor dan Harga"
    When user memilih "PT Logistik Transportasi Nusantara" pada dropdown "Vendor"
    And user mengisi field "Tanggal Permintaan Muat" dengan "24/07/2026 14:30"
    And user mengisi field "Waktu Perjalanan" dengan "8"
    And user mengisi field "Harga" dengan "30.000.000"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 4 Review"
    And sistem tidak menampilkan "Visualisasi Muatan"
    When user mengklik tombol "Simpan"
    Then user diarahkan ke halaman "Daftar Order"
    And sistem menampilkan "Menunggu Penugasan"

    Examples:
      | jenis | tipe        | unit      |
      | FTL   | Normal      | Armada    |
      | FTL   | Multipickup | Armada    |
      | FTL   | Multidrop   | Armada    |
      | FTL   | Multipoint  | Armada    |
      | FCL   | Normal      | Kontainer |
      | FCL   | Multipickup | Kontainer |
      | FCL   | Multidrop   | Kontainer |
      | FCL   | Multipoint  | Kontainer |

  @positive @priority-high @REQ-029 @REQ-011 @screen-step2 @ftl @normal
  Scenario: OMS014-POS-012: Step 2 tipe Normal menampilkan satu blok barang per armada tanpa sub-section alamat
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal" dengan "2" armada
    Then sistem menampilkan "Armada 1"
    And sistem menampilkan "Armada 2"
    And sistem tidak menampilkan "Pick Up 1 -"
    And sistem tidak menampilkan "Drop Off 1 -"
    And jumlah tabel barang pada "Armada 1" adalah "1"

  @positive @priority-high @REQ-030 @REQ-011 @screen-step2 @ftl @multipickup
  Scenario: OMS014-POS-013: Step 2 tipe Multipickup menampilkan sub-section Pick Up di dalam setiap armada
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Multipickup" dengan "2" armada dan "2" alamat pickup
    Then sistem menampilkan "Pick Up 1 - Jl. Jambi No.35, Darmo, Wonokromo, Kota Surabaya, Jawa Timur 60241"
    And sistem menampilkan "Pick Up 2 -"
    And jumlah sub-section alamat pada "Armada 1" adalah "2"
    And jumlah sub-section alamat pada "Armada 2" adalah "2"
    And setiap sub-section alamat memiliki field "Nomor DO" dan tombol "Pilih Barang"

  @positive @priority-high @REQ-031 @REQ-011 @screen-step2 @fcl @multidrop
  Scenario: OMS014-POS-014: Step 2 tipe Multidrop menampilkan sub-section Drop Off di dalam setiap kontainer
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FCL" tipe "Multidrop" dengan "2" kontainer dan "2" alamat dropoff
    Then sistem menampilkan "Drop Off 1 - Jl. Yos Sudarso No.80, Bumi Waras, Kec. Bumi Waras, Kota Bandar Lampung, Lampung 35225"
    And sistem menampilkan "Drop Off 2 -"
    And jumlah sub-section alamat pada "Kontainer 1" adalah "2"
    And setiap sub-section alamat memiliki field "Nomor DO" dan tombol "Pilih Barang"

  @positive @priority-high @REQ-032 @REQ-011 @screen-step2 @ftl @multipoint
  Scenario: OMS014-POS-015: Step 2 tipe Multipoint menampilkan sub-section untuk setiap kombinasi Pick Up x Drop Off
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Multipoint" dengan "2" armada, "2" alamat pickup, dan "2" alamat dropoff
    Then jumlah sub-section kombinasi pada "Armada 1" adalah "4"
    And jumlah sub-section kombinasi pada "Armada 2" adalah "4"
    And sistem menampilkan "Pick Up 1 -"
    And sistem menampilkan "Drop Off 1 -"
    And setiap sub-section kombinasi memiliki field "Nomor DO" dan tabel barang independen

  @positive @priority-medium @REQ-011 @screen-step2 @ftl @multipickup
  Scenario: OMS014-POS-016: Judul sub-section menampilkan alamat lengkap alamat terkait
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Multipickup" dengan "2" alamat pickup
    Then sistem menampilkan "Pick Up 1 - Jl. Jambi No.35, Darmo, Wonokromo, Kota Surabaya, Jawa Timur 60241"

  @positive @priority-high @REQ-023 @screen-step2 @ftl @fcl
  Scenario Outline: OMS014-POS-017: Card Data Unit <jenis> bersifat informatif read-only tanpa mekanisme hitung ulang
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "<jenis>" tipe "Normal"
    Then sistem menampilkan "<labelJenis>"
    And sistem menampilkan "<labelJumlah>"
    And card "Data Unit" tidak memiliki input, dropdown, stepper, maupun tombol aksi
    And sistem tidak menampilkan "Hitung Ulang Armada"
    And sistem tidak menampilkan "Hitung Ulang Kontainer"

    Examples:
      | jenis | labelJenis      | labelJumlah      |
      | FTL   | Jenis Armada    | Jumlah Armada    |
      | FCL   | Jenis Kontainer | Jumlah Kontainer |

  # Hasil merge review rec #5: OMS014-POS-063 digabung ke scenario ini (setup identik; assertion REQ-023 + REQ-008 digabung)
  @positive @priority-high @REQ-023 @REQ-008 @screen-step1 @screen-step2 @ftl
  Scenario: OMS014-POS-018: Mengubah Jumlah Armada di Step 1 memperbarui Data Unit dan menghasilkan unit baru yang kosong di Step 2
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal" dengan "2" armada terisi
    When user mengklik tombol "Sebelumnya"
    And user mengisi field "Jumlah Armada" dengan "3"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Armada 3"
    And nilai "Jumlah Armada" pada card "Data Unit" adalah "3"
    And jumlah blok unit pada Step 2 adalah "3"
    And "Armada 3" tidak memiliki baris barang
    And sistem menampilkan "Belum ada barang. Klik"
    And nilai field "Jumlah" pada baris "SKU-PPR-001" di "Armada 1" tetap "200"

  @positive @priority-high @REQ-013 @screen-modal-pilih-barang @screen-step2
  Scenario: OMS014-POS-019: Modal Pilih Barang mendukung pencarian, pemilihan multi-SKU, counter, dan Simpan
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal"
    When user mengklik tombol "Pilih Barang" pada "Armada 1"
    Then sistem menampilkan "Pilih Barang"
    And sistem menampilkan "Pilih barang yang ingin ditambahkan ke order"
    When user mengisi field "Cari kode/nama barang" dengan "SKU-PPR"
    Then sistem menampilkan "SKU-PPR-001 - Kertas HVS A4 80 gsm"
    And sistem menampilkan "SKU-PPR-002 - Kertas HVS F4 70 gsm"
    When user mencentang checkbox "SKU-PPR-001 - Kertas HVS A4 80 gsm"
    And user mencentang checkbox "SKU-PPR-002 - Kertas HVS F4 70 gsm"
    Then sistem menampilkan "2 barang terpilih"
    When user mengklik tombol "Simpan"
    Then sistem menampilkan "SKU-PPR-001"
    And sistem menampilkan "SKU-PPR-002"

  @positive @priority-medium @REQ-013 @screen-modal-pilih-barang
  Scenario: OMS014-POS-020: Barang yang sudah ada di unit ditandai Sudah Ditambahkan dan checkbox tercentang
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal"
    And "Armada 1" sudah memiliki barang "SKU-PPR-002"
    When user mengklik tombol "Pilih Barang" pada "Armada 1"
    Then sistem menampilkan "Sudah Ditambahkan"
    And checkbox "SKU-PPR-002 - Kertas HVS F4 70 gsm" dalam keadaan tercentang

  @positive @priority-high @REQ-014 @screen-step2 @ftl
  Scenario: OMS014-POS-021: Mencentang Tambahkan Asuransi memunculkan kolom Nilai Barang pada unit tersebut
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal" dengan "2" armada
    And "Armada 1" sudah memiliki barang "SKU-PPR-001"
    Then sistem menampilkan "Berlaku untuk seluruh barang pada armada ini"
    When user mencentang checkbox "Tambahkan Asuransi" pada "Armada 1"
    Then kolom "Nilai Barang" tampil pada tabel barang "Armada 1"
    And kolom "Nilai Barang" tidak tampil pada tabel barang "Armada 2"

  @positive @priority-high @REQ-014 @screen-step3 @screen-step4 @screen-detail-order @screen-step2 @ftl
  Scenario: OMS014-POS-022: Status asuransi ter-carry ke Step 3, Step 4 Review, dan Detail Order
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal" dengan "2" armada
    And "Armada 1" diasuransikan dengan "Nilai Barang" terisi
    And "Armada 2" tidak diasuransikan
    When user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Tanpa Asuransi"
    And baris rekap "Armada 1" menampilkan nominal pada kolom "Total Nilai Barang"
    When user melengkapi Step 3 dan mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Diasuransikan"
    When user mengklik tombol "Simpan"
    And user membuka "Detail Order" dari baris order terbaru
    Then sistem menampilkan "Diasuransikan"

  @positive @priority-medium @REQ-014 @screen-step3 @ftl
  Scenario: OMS014-POS-023: Komponen biaya Asuransi muncul pada ringkasan harga hanya bila ada unit diasuransikan
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga" untuk order "FTL" dengan minimal satu unit diasuransikan
    When user mencentang checkbox "Gunakan komponen harga"
    And user mengisi field "PPN" dengan "1,1"
    And user mengisi field "PPh" dengan "2"
    And user mengisi field "Asuransi" dengan "0,2"
    Then sistem menampilkan "Asuransi (0,2%)"
    And sistem menampilkan "Total Harga"

  @positive @priority-medium @REQ-015 @screen-step2
  Scenario: OMS014-POS-024: Nomor DO yang dipisahkan koma dirender menjadi beberapa chip terpisah
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal"
    Then sistem menampilkan "Pisahkan dengan koma untuk menambahkan beberapa nomor"
    When user mengisi field "Nomor DO" pada "Armada 1" dengan "TGK783898202U, TBL28371302"
    Then sistem menampilkan "TGK783898202U"
    And sistem menampilkan "TBL28371302"
    And jumlah chip "Nomor DO" pada "Armada 1" adalah "2"

  @positive @priority-low @REQ-015 @screen-step2
  Scenario: OMS014-POS-025: Chip Nomor DO dapat dihapus secara individual
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal"
    And field "Nomor DO" pada "Armada 1" berisi chip "TGK783898202U" dan "TBL28371302"
    When user mengklik tombol "Hapus TGK783898202U"
    Then sistem tidak menampilkan "TGK783898202U"
    And sistem menampilkan "TBL28371302"

  @positive @priority-medium @REQ-015 @screen-step4 @screen-detail-order @screen-step2
  Scenario: OMS014-POS-026: Nomor DO bersifat opsional dan ditampilkan sebagai tanda hubung bila kosong
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal"
    And field "Nomor DO" pada "Armada 1" dibiarkan kosong
    When user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 3 Vendor dan Harga"
    When user melengkapi Step 3 dan mengklik tombol "Selanjutnya"
    Then baris "Nomor DO" pada "Armada 1" menampilkan "-"

  @positive @priority-high @REQ-016 @screen-step2 @ftl
  Scenario: OMS014-POS-027: Melebihi kapasitas kubikasi menampilkan peringatan informatif namun Selanjutnya tetap aktif
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal" dengan armada "Tronton Box"
    And "Armada 1" memiliki barang "SKU-PPR-001"
    When user mengisi field "Jumlah" pada baris "SKU-PPR-001" dengan "1200"
    Then sistem menampilkan "Kubikasi melebihi kapasitas armada"
    And sistem menampilkan "Total Kubikasi: 21,6 / 17,86 m³"
    And tombol "Selanjutnya" dalam keadaan enabled

  @positive @priority-high @REQ-016 @screen-step2 @screen-step4 @screen-daftar-order @screen-step3 @ftl
  Scenario: OMS014-POS-028: Melebihi kapasitas berat tetap memungkinkan order disimpan sampai Step 4
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal"
    And "Armada 2" memiliki barang "SKU-BKU-001" dengan "Jumlah" melebihi kapasitas berat
    Then sistem menampilkan "Berat melebihi kapasitas armada"
    When user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 3 Vendor dan Harga"
    When user melengkapi Step 3 dan mengklik tombol "Selanjutnya"
    And user mengklik tombol "Simpan"
    Then user diarahkan ke halaman "Daftar Order"

  @positive @priority-medium @REQ-016 @screen-step2
  Scenario: OMS014-POS-029: Peringatan kapasitas hilang otomatis saat Jumlah diturunkan kembali di bawah kapasitas
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal"
    And "Armada 1" menampilkan "Kubikasi melebihi kapasitas armada"
    When user mengisi field "Jumlah" pada baris "SKU-PPR-001" dengan "200"
    Then sistem tidak menampilkan "Kubikasi melebihi kapasitas armada"
    And sistem menampilkan "Total Kubikasi: 3,6 / 17,86 m³"

  @positive @priority-high @REQ-012 @screen-step1 @screen-step2 @screen-step3
  Scenario: OMS014-POS-030: Navigasi Selanjutnya dan Sebelumnya mempertahankan data setiap step
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga" untuk order "FTL" tipe "Normal"
    When user mengklik tombol "Sebelumnya"
    Then user diarahkan ke halaman "Buat Order - Step 2 Data Barang"
    And nilai field "Jumlah" pada baris "SKU-PPR-001" adalah "200"
    When user mengklik tombol "Sebelumnya"
    Then user diarahkan ke halaman "Buat Order - Step 1 Data Pengiriman"
    And nilai field "Jumlah Armada" adalah "2"
    When user mengklik tombol "Selanjutnya"
    And user mengklik tombol "Selanjutnya"
    Then nilai field "Harga" adalah "30.000.000"

  @positive @priority-medium @REQ-012 @screen-step4
  Scenario: OMS014-POS-031: Tombol aksi utama pada Step 4 adalah Simpan dan bukan Selanjutnya
    Given user berada di halaman "Buat Order - Step 4 Review" untuk order "FTL" tipe "Normal"
    Then sistem menampilkan "Simpan"
    And sistem tidak menampilkan "Selanjutnya"
    And sistem menampilkan "Sebelumnya"
    And sistem menampilkan "Simpan ke Draf"

  @positive @priority-high @REQ-028 @screen-step3 @screen-step2 @ftl
  Scenario: OMS014-POS-032: Step 3 merekap Total Berat, Total Kubikasi, dan Total Nilai Barang dari input manual Step 2
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal" dengan "2" armada
    And "Armada 1" memiliki barang "SKU-PPR-001" dengan "Jumlah" "200"
    When user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Armada 1"
    And baris rekap "Armada 1" menampilkan "Total Berat" "2.500 kg"
    And baris rekap "Armada 1" menampilkan "Total Kubikasi" "3,6 m³"
    And baris rekap "Armada 2" menampilkan "Tanpa Asuransi"

  @positive @priority-medium @REQ-028 @screen-step2 @screen-step3
  Scenario: OMS014-POS-033: Rekap Step 3 ikut berubah bila Jumlah diubah kembali di Step 2
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga" untuk order "FTL" tipe "Normal"
    And baris rekap "Armada 1" menampilkan "Total Berat" "2.500 kg"
    When user mengklik tombol "Sebelumnya"
    And user mengisi field "Jumlah" pada baris "SKU-PPR-001" dengan "400"
    And user mengklik tombol "Selanjutnya"
    Then baris rekap "Armada 1" menampilkan "Total Berat" "5.000 kg"

  @positive @priority-medium @REQ-028 @screen-step3
  Scenario: OMS014-POS-034: Komponen harga PPN dan PPh menghasilkan Total Harga sesuai formula
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga" untuk order "FTL" tipe "Normal"
    When user mengisi field "Harga" dengan "30.000.000"
    And user mencentang checkbox "Gunakan komponen harga"
    And user mengisi field "PPN" dengan "1,1"
    And user mengisi field "PPh" dengan "2"
    Then sistem menampilkan "PPN (1,1%)"
    And sistem menampilkan "PPh (2%)"
    And sistem menampilkan "Total Harga"

  @positive @priority-low @REQ-028 @screen-step3
  Scenario: OMS014-POS-035: Info rute baru muncul saat rute belum ada di Master Waktu Perjalanan
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga" untuk order "FTL" dengan rute yang belum ada di master
    Then sistem menampilkan "Rute belum ada di Master Waktu Perjalanan. Isi waktu perjalanan, nilainya akan otomatis tersimpan sebagai data master baru."
    When user mengisi field "Waktu Perjalanan" dengan "8"
    Then nilai field "Waktu Perjalanan" adalah "8"

  @positive @priority-medium @REQ-030 @screen-step3 @screen-modal-alamat @ftl @multipickup
  Scenario: OMS014-POS-036: Step 3 menyediakan modal Detail Multipickup berisi seluruh alamat pickup
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga" untuk order "FTL" tipe "Multipickup"
    Then sistem menampilkan "Multipickup"
    When user mengklik tombol "Lihat Detail"
    Then sistem menampilkan "Detail Multipickup"
    And sistem menampilkan "Pick Up 1 - Kota Surabaya"
    And sistem menampilkan "Jl. Jambi No.35, Darmo, Wonokromo, Kota Surabaya, Jawa Timur 60241"
    When user mengklik tombol "Tutup"
    Then sistem tidak menampilkan "Detail Multipickup"

  @positive @priority-medium @REQ-031 @screen-step3 @screen-modal-alamat @fcl @multidrop
  Scenario: OMS014-POS-037: Step 3 menyediakan modal Detail Multidrop berisi nama drop point dan alamat lengkap
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga" untuk order "FCL" tipe "Multidrop"
    When user mengklik tombol "Lihat Detail"
    Then sistem menampilkan "Detail Multidrop"
    And sistem menampilkan "Drop Off 2 - Kab. Lampung Tengah"
    And sistem menampilkan "Jl. Proklamator Raya, Seputih Jaya, Kec. Gn. Sugih, Kabupaten Lampung Tengah, Lampung 34161"

  @positive @priority-high @REQ-025 @screen-step4 @ftl
  Scenario: OMS014-POS-038: Step 4 Review menampilkan seluruh section secara lengkap
    Given user berada di halaman "Buat Order - Step 4 Review" untuk order "FTL" tipe "Normal"
    Then sistem menampilkan "Jenis Pengiriman dan Rute"
    And sistem menampilkan "Data Pengirim"
    And sistem menampilkan "Data Penerima"
    And sistem menampilkan "Data Barang"
    And sistem menampilkan "Vendor dan Harga"
    And sistem menampilkan "Harga DPP"
    And sistem menampilkan "Total Harga"

  @positive @priority-high @REQ-026 @screen-step2 @screen-step4 @ftl @normal
  Scenario: OMS014-POS-039: Step 4 menampilkan Data Barang persis seperti input manual Step 2
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal" dengan "2" armada
    And "Armada 1" memiliki barang "SKU-PPR-001" dengan "Jumlah" "200"
    And "Armada 2" memiliki barang "SKU-BKU-001" dengan "Jumlah" "50"
    When user melengkapi Step 3 dan mengklik tombol "Selanjutnya"
    Then baris "SKU-PPR-001" pada "Armada 1" menampilkan "Jumlah" "200"
    And baris "SKU-BKU-001" pada "Armada 2" menampilkan "Jumlah" "50"
    And jumlah baris barang pada "Armada 1" adalah "1"
    And sistem tidak menampilkan "SKU-BKU-001" pada "Armada 1"

  @positive @priority-high @REQ-026 @screen-step4 @fcl @multidrop
  Scenario: OMS014-POS-040: Step 4 mengelompokkan Data Barang per alamat sesuai struktur input Step 2
    Given user berada di halaman "Buat Order - Step 4 Review" untuk order "FCL" tipe "Multidrop" dengan "1" kontainer dan "2" alamat dropoff
    Then sistem menampilkan "Kontainer 1"
    And sistem menampilkan "Drop Off 1"
    And sistem menampilkan "Drop Off 2"
    And jumlah kelompok alamat pada "Kontainer 1" adalah "2"

  @positive @priority-medium @REQ-010 @REQ-026 @screen-step4 @screen-step2 @ftl
  Scenario: OMS014-POS-041: Unit yang dibiarkan kosong ditampilkan apa adanya tanpa pengisian otomatis
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal" dengan "3" armada
    And "Armada 3" dibiarkan kosong
    Then sistem menampilkan "Belum ada barang. Klik"
    And sistem menampilkan "Total Kubikasi: 0 / 17,86 m³"
    When user melengkapi Step 3 dan mengklik tombol "Selanjutnya"
    Then "Armada 3" pada Step 4 tidak memiliki baris barang

  @positive @priority-medium @REQ-024 @screen-step2 @screen-modal-draf @screen-daftar-order
  Scenario: OMS014-POS-042: Simpan ke Draf dari Step 2 menampilkan konfirmasi dan order muncul di Daftar Order
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal"
    When user mengklik tombol "Simpan ke Draf"
    Then sistem menampilkan "Anda yakin ingin menyimpan data dalam draf?"
    And sistem menampilkan "Data yang telah diisi akan disimpan sebagai draf"
    When user mengklik tombol "Simpan Draf"
    Then user diarahkan ke halaman "Daftar Order"
    And sistem menampilkan "Isi Data Muatan"

  @positive @priority-high @REQ-024 @screen-daftar-order @screen-step2
  Scenario: OMS014-POS-043: Lanjutkan Pengisian me-restore data barang manual per unit secara persis
    Given terdapat order draft "FTL" tipe "Multipickup" berstatus "Isi Data Muatan"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada baris order draft
    And user mengklik menu "Lanjutkan Pengisian"
    Then user diarahkan ke halaman "Buat Order - Step 2 Data Barang"
    And nilai field "Jumlah" pada baris "SKU-PPR-001" di "Pick Up 1" adalah "200"
    And "Pick Up 2" tidak memiliki baris barang
    And sistem tidak menampilkan "Hitung Ulang Armada"

  @positive @priority-high @REQ-027 @REQ-029 @screen-detail-order @fcl
  Scenario: OMS014-POS-044: Detail Order menampilkan seluruh section secara lengkap
    Given terdapat order "FCL" tipe "Normal" berstatus "Menunggu Penugasan"
    When user membuka halaman "Detail Order" untuk order tersebut
    Then sistem menampilkan "Detail Order"
    And sistem menampilkan "Jenis Pengiriman dan Rute"
    And sistem menampilkan "Data Pengirim"
    And sistem menampilkan "Data Penerima"
    And sistem menampilkan "Data Barang"
    And sistem menampilkan "Vendor dan Harga"
    And sistem menampilkan "Tipe Pengiriman"

  @positive @priority-high @REQ-027 @REQ-026 @screen-step4 @screen-detail-order
  Scenario: OMS014-POS-045: Isi Data Barang pada Detail Order identik dengan Step 4 Review saat order disimpan
    Given user berada di halaman "Buat Order - Step 4 Review" untuk order "FTL" tipe "Normal"
    And user mencatat isi tabel "Data Barang" pada Step 4
    When user mengklik tombol "Simpan"
    And user membuka "Detail Order" dari baris order terbaru
    Then isi tabel "Data Barang" pada Detail Order sama dengan catatan Step 4
    And sistem tidak menampilkan "Visualisasi Muatan"

  @positive @priority-medium @REQ-018 @screen-daftar-order @screen-modal-no-perjalanan @ftl @fcl
  Scenario Outline: OMS014-POS-046: Modal Data No. Perjalanan menampilkan nomor perjalanan dan identitas unit untuk order <jenis>
    Given terdapat order "<jenis>" berstatus "Ditugaskan" dengan "2" unit
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada baris order tersebut
    And user mengklik menu "Lihat No. Perjalanan"
    Then sistem menampilkan "Data No. Perjalanan"
    And sistem menampilkan "ID Order:"
    And sistem menampilkan "<jenis>"
    And sistem menampilkan "TRC79289802"
    And sistem menampilkan "<identitasUnit>"
    And jumlah baris nomor perjalanan adalah "2"
    When user mengklik tombol "Salin" pada baris pertama
    Then sistem menampilkan "Nomor perjalanan disalin"

    Examples:
      | jenis | identitasUnit         |
      | FTL   | L 1892 PGS • Fuso Box |
      | FCL   | TVW67892231 • 40 DRY  |

  @positive @priority-medium @REQ-019 @screen-daftar-order @screen-detail-order
  Scenario: OMS014-POS-047: Status order ditampilkan konsisten pada Daftar Order dan Detail Order
    Given terdapat order "FTL" berstatus "Menunggu Penugasan"
    And user berada di halaman "Daftar Order"
    Then badge status pada baris order menampilkan "Menunggu Penugasan"
    When user mengklik menu "Detail" pada baris order tersebut
    Then user diarahkan ke halaman "Detail Order"
    And badge status pada Detail Order menampilkan "Menunggu Penugasan"

  @positive @priority-medium @REQ-019 @REQ-024 @screen-daftar-order
  Scenario Outline: OMS014-POS-048: Status pengisian bertahap sesuai step terakhir yang diselesaikan - <status>
    Given user menyimpan draft order setelah menyelesaikan "<step>"
    When user berada di halaman "Daftar Order"
    Then badge status pada baris order menampilkan "<status>"

    Examples:
      | step                       | status          |
      | Step 1 Data Pengiriman     | Isi Data Muatan |
      | Step 2 Data Barang         | Isi Data Vendor |
      | Step 3 Vendor dan Harga    | Review Order    |

  @positive @priority-high @REQ-020 @screen-daftar-order @screen-edit-order
  Scenario: OMS014-POS-049: Aksi Edit tersedia pada status Menunggu Penugasan dan membuka Edit Order satu halaman
    Given terdapat order "FCL" tipe "Normal" berstatus "Menunggu Penugasan"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada baris order tersebut
    Then sistem menampilkan "Edit"
    When user mengklik menu "Edit"
    Then user diarahkan ke halaman "Edit Order"
    And sistem menampilkan "Jenis Pengiriman dan Rute"
    And sistem menampilkan "Data Pengirim"
    And sistem menampilkan "Data Penerima"
    And sistem menampilkan "Data Barang - Kontainer 1"
    And sistem menampilkan "Vendor dan Harga"
    And sistem menampilkan "Simpan"

  @positive @priority-medium @REQ-020 @screen-edit-order
  Scenario: OMS014-POS-050: Field identitas order bersifat read-only pada halaman Edit Order
    Given user berada di halaman "Edit Order" untuk order "FCL" berstatus "Menunggu Penugasan"
    Then field "ID Order" bersifat read-only
    And field "Tanggal Dibuat" bersifat read-only
    And field "Jenis Pengiriman" bersifat read-only
    And field "Tipe Pengiriman" bersifat read-only
    And field "Jenis Kontainer" dalam keadaan enabled
    And field "Jumlah Kontainer" dalam keadaan enabled

  @positive @priority-high @REQ-020 @screen-edit-order @screen-detail-order
  Scenario: OMS014-POS-051: Mengubah Jumlah barang pada Edit Order tersimpan dan tercermin di Detail Order
    Given user berada di halaman "Edit Order" untuk order "FTL" berstatus "Menunggu Penugasan"
    When user mengisi field "Jumlah" pada baris "SKU-PPR-001" dengan "350"
    And user mengklik tombol "Simpan"
    Then user diarahkan ke halaman "Detail Order"
    And baris "SKU-PPR-001" menampilkan "Jumlah" "350"
    And sistem tidak menampilkan "Visualisasi Muatan"

  @positive @priority-medium @REQ-021 @screen-detail-order @screen-modal-batalkan
  Scenario: OMS014-POS-052: Batalkan Order dari Detail Order dengan alasan mengubah status menjadi Dibatalkan
    Given user berada di halaman "Detail Order" untuk order "FTL" berstatus "Menunggu Penugasan"
    When user mengklik tombol "Batalkan Order"
    Then sistem menampilkan "Batalkan Order"
    And sistem menampilkan "Tuliskan alasan pembatalan order"
    When user mengisi field "Alasan Pembatalan" dengan "Permintaan customer dibatalkan"
    And user mengklik tombol "Batalkan Order" pada dialog
    Then sistem menampilkan "Dibatalkan"
    And sistem tidak menampilkan "Edit Order"

  @positive @priority-medium @REQ-021 @screen-daftar-order
  Scenario: OMS014-POS-053: Order yang dibatalkan tercatat pada Riwayat Pembatalan
    Given terdapat order "FTL" berstatus "Dibatalkan" dengan alasan "Permintaan customer dibatalkan"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Riwayat Pembatalan"
    Then sistem menampilkan "Riwayat Pembatalan"
    And sistem menampilkan "Permintaan customer dibatalkan"

  @positive @priority-medium @REQ-022 @screen-daftar-order
  Scenario: OMS014-POS-054: Panel Filter Daftar Order dapat diterapkan dan direset
    Given user berada di halaman "Daftar Order"
    When user mengklik tombol "Filter"
    Then sistem menampilkan "ID Order"
    And sistem menampilkan "Jenis Order"
    And sistem menampilkan "Vendor"
    And sistem menampilkan "Kota Asal"
    And sistem menampilkan "Kota Tujuan"
    And sistem menampilkan "Total Harga"
    And sistem menampilkan "Tipe Pengiriman"
    And sistem menampilkan "Metode Pengiriman"
    And sistem menampilkan "Drop Point Asal"
    And sistem menampilkan "Drop Point Tujuan"
    And sistem menampilkan "Status"
    When user memilih "FTL" pada dropdown "Jenis Order"
    And user mengklik tombol "Terapkan"
    Then seluruh baris tabel memiliki badge jenis order "FTL"
    When user mengklik tombol "Reset"
    Then nilai dropdown "Jenis Order" kosong

  @positive @priority-low @REQ-022 @screen-daftar-order
  Scenario: OMS014-POS-055: Kontrol tampilkan data, info paginasi, dan sorting Total Harga berfungsi
    Given user berada di halaman "Daftar Order"
    When user memilih "50" pada dropdown "Tampilkan"
    Then sistem menampilkan "Menampilkan 1 - 30 data dari 30 data"
    When user mengklik tombol sorting pada kolom "Total Harga"
    Then nilai kolom "Total Harga" terurut menaik
    When user mengklik halaman "2" pada paginasi
    Then sistem menampilkan "Menampilkan"

  @positive @priority-medium @REQ-022 @REQ-020 @screen-daftar-order
  Scenario Outline: OMS014-POS-056: Menu aksi baris menampilkan opsi sesuai status <status>
    Given terdapat order berstatus "<status>"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada baris order tersebut
    Then sistem menampilkan "<aksiAda>"
    And sistem tidak menampilkan "<aksiTidakAda>"

    Examples:
      | status             | aksiAda               | aksiTidakAda        |
      | Isi Data Muatan    | Lanjutkan Pengisian   | Edit                |
      | Menunggu Penugasan | Edit                  | Lanjutkan Pengisian |
      | Ditugaskan         | Lihat No. Perjalanan  | Edit                |

  @positive @priority-high @REQ-004 @REQ-006 @REQ-007 @REQ-008 @screen-step2 @ftl @fcl @normal @multipickup @multidrop @multipoint
  Scenario Outline: OMS014-POS-057: Step 2 order <jenis> tipe <tipe> tidak merender satu pun elemen Auto Stuffing
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "<jenis>" tipe "<tipe>"
    Then sistem tidak menampilkan "Hitung Ulang Armada"
    And sistem tidak menampilkan "Hitung Ulang Kontainer"
    And sistem tidak menampilkan "Visualisasi Terbaru"
    And sistem tidak menampilkan "Visualisasi Muatan"
    And sistem tidak menampilkan "Visualisasi Muatan Saat Ini"
    And sistem tidak menampilkan "Terapkan ke Order"
    And sistem tidak menampilkan "Paling Efisien"
    And sistem tidak menampilkan "Berat Terpakai"
    And sistem tidak menampilkan "Ruang Terpakai"
    And sistem tidak menampilkan "Pilih Jenis Armada"
    And sistem tidak menampilkan "Pilih Jenis Kontainer"
    And sistem tidak menampilkan "Berat Maksimal 1 Armada"
    And sistem tidak menampilkan "koli melebihi kapasitas"
    And sistem tidak menampilkan "dialokasikan ke unit ini"
    And sistem tidak menampilkan "Drag: putar 360° • Scroll: zoom • Klik 2×: reset"
    And elemen "recalc-fab" memiliki jumlah "0"
    And elemen "visualisasi-fab" memiliki jumlah "0"
    And elemen "load-visualization-canvas" memiliki jumlah "0"
    And elemen "capacity-progress" memiliki jumlah "0"

    Examples:
      | jenis | tipe        |
      | FTL   | Normal      |
      | FTL   | Multipickup |
      | FTL   | Multidrop   |
      | FTL   | Multipoint  |
      | FCL   | Normal      |
      | FCL   | Multipickup |
      | FCL   | Multidrop   |
      | FCL   | Multipoint  |

  @positive @priority-high @REQ-025 @screen-step4 @ftl @fcl @normal @multipickup @multidrop @multipoint
  Scenario Outline: OMS014-POS-058: Step 4 Review order <jenis> tipe <tipe> tidak menampilkan elemen turunan Auto Stuffing
    Given user berada di halaman "Buat Order - Step 4 Review" untuk order "<jenis>" tipe "<tipe>"
    Then sistem menampilkan "Data Barang"
    And sistem tidak menampilkan "Visualisasi Muatan"
    And sistem tidak menampilkan "Berat Terpakai"
    And sistem tidak menampilkan "Ruang Terpakai"
    And sistem tidak menampilkan "koli melebihi kapasitas"
    And elemen "load-visualization-canvas" memiliki jumlah "0"
    And elemen "capacity-progress" memiliki jumlah "0"

    Examples:
      | jenis | tipe        |
      | FTL   | Normal      |
      | FTL   | Multipickup |
      | FTL   | Multidrop   |
      | FTL   | Multipoint  |
      | FCL   | Normal      |
      | FCL   | Multipickup |
      | FCL   | Multidrop   |
      | FCL   | Multipoint  |

  @positive @priority-high @REQ-027 @screen-detail-order @ftl @fcl @normal @multipickup @multidrop @multipoint
  Scenario Outline: OMS014-POS-059: Detail Order <jenis> tipe <tipe> tidak menampilkan elemen visualisasi maupun keterisian
    Given terdapat order "<jenis>" tipe "<tipe>" berstatus "Menunggu Penugasan"
    When user membuka halaman "Detail Order" untuk order tersebut
    Then sistem menampilkan "Batalkan Order"
    And sistem menampilkan "Edit Order"
    And sistem tidak menampilkan "Visualisasi Muatan"
    And sistem tidak menampilkan "Berat Terpakai"
    And sistem tidak menampilkan "Ruang Terpakai"
    And sistem tidak menampilkan "koli melebihi kapasitas"
    And elemen "load-visualization-canvas" memiliki jumlah "0"

    Examples:
      | jenis | tipe        |
      | FTL   | Normal      |
      | FTL   | Multipickup |
      | FTL   | Multidrop   |
      | FTL   | Multipoint  |
      | FCL   | Normal      |
      | FCL   | Multipickup |
      | FCL   | Multidrop   |
      | FCL   | Multipoint  |

  # Diperluas per review rec #3: assertion A8/A9/capacity-progress ditambahkan dan Examples diperluas 2 -> 8 kombinasi (setara POS-057/058/059)
  @positive @priority-high @REQ-004 @REQ-020 @screen-edit-order @ftl @fcl @normal @multipickup @multidrop @multipoint
  Scenario Outline: OMS014-POS-060: Halaman Edit Order <jenis> tipe <tipe> tidak menampilkan elemen Auto Stuffing
    Given user berada di halaman "Edit Order" untuk order "<jenis>" tipe "<tipe>" berstatus "Menunggu Penugasan"
    Then sistem menampilkan "Data Barang - <unit> 1"
    And sistem tidak menampilkan "Hitung Ulang Armada"
    And sistem tidak menampilkan "Hitung Ulang Kontainer"
    And sistem tidak menampilkan "Visualisasi Terbaru"
    And sistem tidak menampilkan "Visualisasi Muatan"
    And sistem tidak menampilkan "Berat Terpakai"
    And sistem tidak menampilkan "Ruang Terpakai"
    And sistem tidak menampilkan "koli melebihi kapasitas"
    And elemen "recalc-fab" memiliki jumlah "0"
    And elemen "visualisasi-fab" memiliki jumlah "0"
    And elemen "load-visualization-canvas" memiliki jumlah "0"
    And elemen "capacity-progress" memiliki jumlah "0"

    Examples:
      | jenis | tipe        | unit      |
      | FTL   | Normal      | Armada    |
      | FTL   | Multipickup | Armada    |
      | FTL   | Multidrop   | Armada    |
      | FTL   | Multipoint  | Armada    |
      | FCL   | Normal      | Kontainer |
      | FCL   | Multipickup | Kontainer |
      | FCL   | Multidrop   | Kontainer |
      | FCL   | Multipoint  | Kontainer |

  @positive @priority-high @REQ-008 @screen-step2 @ftl
  Scenario: OMS014-POS-061: Menambah barang pada Armada 1 tidak mengubah isi tabel barang armada lain
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal" dengan "3" armada
    When user menambahkan barang "SKU-PPR-001" pada "Armada 1"
    And user mengisi field "Jumlah" pada baris "SKU-PPR-001" di "Armada 1" dengan "200"
    Then "Armada 2" tidak memiliki baris barang
    And "Armada 3" tidak memiliki baris barang
    And sistem menampilkan "Belum ada barang. Klik"

  @positive @priority-high @REQ-008 @screen-step2 @ftl
  Scenario: OMS014-POS-062: Mengubah Jumlah pada satu baris hanya memperbarui total unit terkait
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal" dengan "2" armada
    And "Armada 1" memiliki barang "SKU-PPR-001" dengan "Jumlah" "200"
    And "Armada 2" memiliki barang "SKU-BKU-001" dengan "Jumlah" "50"
    When user mengisi field "Jumlah" pada baris "SKU-PPR-001" di "Armada 1" dengan "300"
    Then ringkasan kapasitas "Armada 1" berubah
    And nilai field "Jumlah" pada baris "SKU-BKU-001" di "Armada 2" tetap "50"
    And ringkasan kapasitas "Armada 2" tidak berubah

  # OMS014-POS-063 dihapus: digabung ke OMS014-POS-018 (review rec #5, setup ~90% identik)

  @positive @priority-high @REQ-008 @REQ-004 @screen-step2
  Scenario: OMS014-POS-064: Tidak ada proses kalkulasi penempatan yang dieksekusi saat Step 2 dimuat atau data barang berubah
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman" untuk order "FTL" tipe "Normal"
    When user mengklik tombol "Selanjutnya"
    Then tidak ada request ke endpoint "auto-stuffing"
    When user menambahkan barang "SKU-PPR-001" pada "Armada 1"
    And user mengisi field "Jumlah" pada baris "SKU-PPR-001" dengan "200"
    Then tidak ada request ke endpoint "auto-stuffing"

  @positive @priority-high @REQ-009 @screen-step2 @ftl @multipickup
  Scenario: OMS014-POS-065: Multipickup - barang pada Pick Up 1 tidak tersalin ke Pick Up 2
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Multipickup" dengan "2" alamat pickup
    When user menambahkan barang "SKU-PPR-001" pada "Pick Up 1" di "Armada 1"
    And user mengisi field "Jumlah" pada baris "SKU-PPR-001" dengan "200"
    Then "Pick Up 2" pada "Armada 1" tidak memiliki baris barang
    And "Pick Up 1" pada "Armada 2" tidak memiliki baris barang

  @positive @priority-high @REQ-009 @screen-step2 @fcl @multidrop
  Scenario: OMS014-POS-066: Multidrop - barang pada Drop Off 1 tidak tersalin ke Drop Off 2
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FCL" tipe "Multidrop" dengan "2" alamat dropoff
    When user menambahkan barang "SKU-BKU-001" pada "Drop Off 1" di "Kontainer 1"
    And user mengisi field "Jumlah" pada baris "SKU-BKU-001" dengan "80"
    Then "Drop Off 2" pada "Kontainer 1" tidak memiliki baris barang

  @positive @priority-high @REQ-009 @REQ-032 @screen-step2 @ftl @multipoint
  Scenario: OMS014-POS-067: Multipoint - barang pada kombinasi Pick Up 1 - Drop Off 1 tidak tersalin ke kombinasi lain
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Multipoint" dengan "2" alamat pickup dan "2" alamat dropoff
    When user menambahkan barang "SKU-PPR-002" pada kombinasi "Pick Up 1 - Drop Off 1" di "Armada 1"
    And user mengisi field "Jumlah" pada baris "SKU-PPR-002" dengan "120"
    Then kombinasi "Pick Up 1 - Drop Off 2" tidak memiliki baris barang
    And kombinasi "Pick Up 2 - Drop Off 1" tidak memiliki baris barang
    And kombinasi "Pick Up 2 - Drop Off 2" tidak memiliki baris barang

  @positive @priority-medium @REQ-009 @REQ-030 @screen-step1 @screen-step2 @ftl @multipickup
  Scenario: OMS014-POS-068: Tambah Baris Input menghasilkan sub-section alamat baru dalam kondisi kosong
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman" untuk order "FTL" tipe "Multipickup" dengan "2" alamat pickup
    When user mengklik tombol "Tambah Baris Input" pada section "Data Pengirim"
    And user melengkapi seluruh field wajib pada "Pick Up 3"
    And user mengklik tombol "Selanjutnya"
    Then jumlah sub-section alamat pada "Armada 1" adalah "3"
    And "Pick Up 3" pada "Armada 1" tidak memiliki baris barang

  @positive @priority-medium @REQ-006 @screen-step1 @screen-step2 @ftl
  Scenario: OMS014-POS-069: Jenis dan Jumlah Armada tidak berubah otomatis karena rekomendasi sistem
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman" untuk order "FTL" tipe "Normal"
    And user memilih "Tronton Box" pada dropdown "Jenis Armada"
    And user mengisi field "Jumlah Armada" dengan "2"
    When user mengklik tombol "Selanjutnya"
    And user mengisi data barang melebihi kapasitas pada "Armada 1"
    And user mengklik tombol "Sebelumnya"
    Then nilai dropdown "Jenis Armada" tetap "Tronton Box"
    And nilai field "Jumlah Armada" tetap "2"

  @positive @priority-medium @REQ-005 @screen-step1 @screen-step2 @screen-step3 @screen-step4
  Scenario: OMS014-POS-070: Struktur section dan label field identik antara mode Auto Stuffing ON dan OFF
    Given user mencatat urutan section dan label field Step 1 sampai Step 4 pada mode "ON"
    When toggle add-on "Auto Stuffing" diubah ke "OFF"
    And user membuka wizard "Buat Order" untuk order "FTL" tipe "Normal"
    Then urutan section Step 1 sampai Step 4 sama dengan catatan mode "ON"
    And label field Step 1 sampai Step 4 sama dengan catatan mode "ON"
    And perbedaan yang muncul hanya ketiadaan elemen Auto Stuffing

  @positive @priority-medium @REQ-010 @screen-step2
  Scenario: OMS014-POS-071: Baris barang dapat dihapus per unit tanpa mempengaruhi unit lain
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal" dengan "2" armada
    And "Armada 1" memiliki barang "SKU-PPR-001" dan "SKU-PPR-002"
    And "Armada 2" memiliki barang "SKU-PPR-001"
    When user mengklik tombol "Hapus" pada baris "SKU-PPR-001" di "Armada 1"
    Then sistem tidak menampilkan "SKU-PPR-001" pada "Armada 1"
    And "Armada 2" tetap memiliki baris barang "SKU-PPR-001"

  @positive @priority-medium @REQ-031 @screen-step1 @multidrop
  Scenario: OMS014-POS-072: Info alert urutan pengiriman ditampilkan pada section Data Penerima tipe Multidrop
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    And user memilih kartu jenis order "FTL"
    When user memilih "Multidrop" pada dropdown "Tipe Pengiriman"
    Then sistem menampilkan "Pastikan urutan pengiriman sudah sesuai saat membuat shipment"
    And sistem menampilkan "Tambah Baris Input"
    And sistem menampilkan "Drop Off 1"
    And sistem menampilkan "Drop Off 2"

  @positive @priority-low @REQ-022 @screen-daftar-order
  Scenario: OMS014-POS-073: Riwayat Perubahan order dapat dibuka dari menu aksi baris
    Given terdapat order "FTL" berstatus "Menunggu Penugasan" yang pernah diedit
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada baris order tersebut
    And user mengklik menu "Riwayat Perubahan"
    Then sistem menampilkan "Riwayat Perubahan"

  @positive @priority-medium @REQ-029 @screen-step1 @screen-detail-order @normal
  Scenario: OMS014-POS-074: Tipe Normal menampilkan satu blok Data Pengirim dan Data Penerima tanpa Tambah Baris Input
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    And user memilih kartu jenis order "FTL"
    When user memilih "Normal" pada dropdown "Tipe Pengiriman"
    Then jumlah blok "Data Pengirim" adalah "1"
    And jumlah blok "Data Penerima" adalah "1"
    And sistem tidak menampilkan "Tambah Baris Input"

  # ==========================================================================================
  # KATEGORI: NEGATIVE
  # ==========================================================================================

  @negative @priority-high @REQ-012 @REQ-017 @screen-step1
  Scenario: OMS014-NEG-001: Tombol Selanjutnya Step 1 disabled selama Tipe Pengiriman belum dipilih
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user memilih kartu jenis order "FTL"
    And user memilih "Tronton Box" pada dropdown "Jenis Armada"
    And user mengisi field "Jumlah Armada" dengan "2"
    Then tombol "Selanjutnya" dalam keadaan disabled
    When user memilih "Normal" pada dropdown "Tipe Pengiriman"
    And user melengkapi seluruh field wajib alamat
    Then tombol "Selanjutnya" dalam keadaan enabled

  @negative @priority-high @REQ-017 @screen-step1 @ftl
  Scenario: OMS014-NEG-002: Klik Selanjutnya dengan Jenis Armada kosong menahan navigasi dan menampilkan validasi
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    And user memilih kartu jenis order "FTL"
    And user mengisi field "Jumlah Armada" dengan "2"
    And user memilih "Normal" pada dropdown "Tipe Pengiriman"
    When user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "harus diisi"
    And user tetap berada di halaman "Buat Order - Step 1 Data Pengiriman"

  @negative @priority-high @REQ-017 @screen-step1 @fcl
  Scenario: OMS014-NEG-003: Klik Selanjutnya dengan Pelabuhan Asal dan Pelabuhan Tujuan kosong ditolak
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    And user memilih kartu jenis order "FCL"
    And user memilih "20 Feet Dry" pada dropdown "Jenis Kontainer"
    And user mengisi field "Jumlah Kontainer" dengan "2"
    And user memilih "Normal" pada dropdown "Tipe Pengiriman"
    When user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "harus diisi"
    And user tetap berada di halaman "Buat Order - Step 1 Data Pengiriman"

  @negative @priority-medium @REQ-017 @screen-step1 @fcl
  Scenario: OMS014-NEG-004: Klik Selanjutnya tanpa memilih Metode Pengiriman pada FCL ditolak
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    And user memilih kartu jenis order "FCL"
    And user melengkapi seluruh field wajib FCL kecuali "Metode Pengiriman"
    When user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "harus diisi"
    And user tetap berada di halaman "Buat Order - Step 1 Data Pengiriman"

  @negative @priority-high @REQ-017 @screen-step1
  Scenario: OMS014-NEG-005: Field PIC Pengirim kosong menahan navigasi ke Step 2
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman" dengan seluruh field terisi
    When user mengosongkan field "PIC Pengirim"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "harus diisi"
    And user tetap berada di halaman "Buat Order - Step 1 Data Pengiriman"

  @negative @priority-medium @REQ-017 @screen-step1
  Scenario: OMS014-NEG-006: No. WhatsApp PIC berisi huruf dan karakter non-digit ditolak
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman" dengan seluruh field terisi
    When user mengisi field "No. WhatsApp PIC" dengan "08ab-123!xyz"
    And user mengklik tombol "Selanjutnya"
    Then nilai field "No. WhatsApp PIC" tidak mengandung karakter non-digit
    And user tetap berada di halaman "Buat Order - Step 1 Data Pengiriman"

  @negative @priority-medium @REQ-017 @screen-step1
  Scenario: OMS014-NEG-007: No. WhatsApp PIC kurang dari 10 digit ditolak
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman" dengan seluruh field terisi
    When user mengisi field "No. WhatsApp PIC" dengan "0812345"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "tidak valid"
    And user tetap berada di halaman "Buat Order - Step 1 Data Pengiriman"

  @negative @priority-high @REQ-017 @screen-step2
  Scenario: OMS014-NEG-008: Baris barang dengan Jumlah kosong menampilkan pesan Jumlah harus diisi
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal"
    And "Armada 2" memiliki barang "SKU-BKU-001"
    When user mengosongkan field "Jumlah" pada baris "SKU-BKU-001"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Jumlah harus diisi"
    And user tetap berada di halaman "Buat Order - Step 2 Data Barang"

  @negative @priority-high @REQ-017 @screen-step2
  Scenario: OMS014-NEG-009: Baris barang dengan Jumlah bernilai nol ditolak
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal"
    And "Armada 1" memiliki barang "SKU-PPR-001"
    When user mengisi field "Jumlah" pada baris "SKU-PPR-001" dengan "0"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Jumlah harus diisi"
    And user tetap berada di halaman "Buat Order - Step 2 Data Barang"

  @negative @priority-high @REQ-014 @REQ-017 @screen-step2
  Scenario: OMS014-NEG-010: Unit diasuransikan dengan Nilai Barang kosong menampilkan pesan Nilai Barang harus diisi
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal"
    And "Armada 1" memiliki barang "SKU-PPR-001" dengan "Jumlah" "200"
    When user mencentang checkbox "Tambahkan Asuransi" pada "Armada 1"
    And user mengosongkan field "Nilai Barang" pada baris "SKU-PPR-001"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Nilai Barang harus diisi"
    And user tetap berada di halaman "Buat Order - Step 2 Data Barang"

  @negative @priority-medium @REQ-014 @screen-step2
  Scenario: OMS014-NEG-011: Nilai Barang bernilai negatif ditolak sistem
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal"
    And "Armada 1" diasuransikan dan memiliki barang "SKU-PPR-001"
    When user mengisi field "Nilai Barang" pada baris "SKU-PPR-001" dengan "-1.000.000"
    And user mengklik tombol "Selanjutnya"
    Then nilai field "Nilai Barang" tidak bernilai negatif
    And user tetap berada di halaman "Buat Order - Step 2 Data Barang"

  @negative @priority-high @REQ-017 @screen-step2
  Scenario: OMS014-NEG-012: Order tanpa satu pun barang pada seluruh unit tidak dapat lanjut ke Step 3
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal" dengan "2" armada
    And seluruh armada dibiarkan kosong
    When user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "harus diisi"
    And user tetap berada di halaman "Buat Order - Step 2 Data Barang"

  @negative @priority-high @REQ-017 @screen-step3
  Scenario: OMS014-NEG-013: Step 3 tanpa Vendor menahan navigasi ke Step 4
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga" untuk order "FTL" tipe "Normal"
    When user mengisi field "Harga" dengan "30.000.000"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "harus diisi"
    And user tetap berada di halaman "Buat Order - Step 3 Vendor dan Harga"

  @negative @priority-medium @REQ-017 @screen-step3
  Scenario: OMS014-NEG-014: Tanggal Permintaan Muat dengan format tidak sesuai mask ditolak
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga" untuk order "FTL" tipe "Normal"
    When user mengisi field "Tanggal Permintaan Muat" dengan "2026-07-24 14.30"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "tidak valid"
    And user tetap berada di halaman "Buat Order - Step 3 Vendor dan Harga"

  @negative @priority-medium @REQ-017 @screen-step3
  Scenario: OMS014-NEG-015: Tanggal Permintaan Muat di masa lalu ditolak
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga" untuk order "FTL" tipe "Normal"
    When user mengisi field "Tanggal Permintaan Muat" dengan "01/01/2020 08:00"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "tidak valid"
    And user tetap berada di halaman "Buat Order - Step 3 Vendor dan Harga"

  @negative @priority-medium @REQ-017 @screen-step3
  Scenario: OMS014-NEG-016: Waktu Perjalanan bernilai nol ditolak
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga" untuk order "FTL" tipe "Normal"
    When user mengisi field "Waktu Perjalanan" dengan "0"
    And user melengkapi field wajib lain pada Step 3
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "harus diisi"
    And user tetap berada di halaman "Buat Order - Step 3 Vendor dan Harga"

  @negative @priority-high @REQ-017 @screen-step3
  Scenario: OMS014-NEG-017: Harga bernilai nol atau kosong menahan navigasi ke Step 4
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga" untuk order "FTL" tipe "Normal"
    When user mengisi field "Harga" dengan "0"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "harus diisi"
    And user tetap berada di halaman "Buat Order - Step 3 Vendor dan Harga"

  @negative @priority-low @REQ-017 @screen-step3
  Scenario: OMS014-NEG-018: PPN lebih besar dari 100 persen ditolak
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga" untuk order "FTL" tipe "Normal"
    And user mencentang checkbox "Gunakan komponen harga"
    When user mengisi field "PPN" dengan "150"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "tidak valid"
    And user tetap berada di halaman "Buat Order - Step 3 Vendor dan Harga"

  @negative @priority-low @REQ-017 @screen-step3
  Scenario: OMS014-NEG-019: PPh bernilai negatif ditolak
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga" untuk order "FTL" tipe "Normal"
    And user mencentang checkbox "Gunakan komponen harga"
    When user mengisi field "PPh" dengan "-5"
    And user mengklik tombol "Selanjutnya"
    Then nilai field "PPh" tidak bernilai negatif
    And user tetap berada di halaman "Buat Order - Step 3 Vendor dan Harga"

  @negative @priority-high @REQ-004 @REQ-006 @screen-step2
  Scenario: OMS014-NEG-020: Deep link URL ke panel Hitung Ulang Armada tidak memunculkan drawer
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal"
    When user membuka URL "/order/create/step-2?panel=hitung-ulang-armada"
    Then sistem tidak menampilkan "Hitung Ulang Armada"
    And sistem tidak menampilkan "Simulasi ulang kebutuhan unit dari muatan order ini. Terapkan untuk ubah data order."
    And sistem tidak menampilkan "Terapkan ke Order"

  @negative @priority-high @REQ-004 @REQ-007 @screen-step2
  Scenario: OMS014-NEG-021: Deep link URL dan shortcut keyboard tidak memunculkan panel Visualisasi Muatan
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FCL" tipe "Normal"
    When user membuka URL "/order/create/step-2?panel=visualisasi-muatan"
    Then sistem tidak menampilkan "Visualisasi Muatan Saat Ini"
    When user menekan shortcut keyboard "Control+Shift+V"
    Then sistem tidak menampilkan "Visualisasi Muatan"
    And elemen "load-visualization-canvas" memiliki jumlah "0"

  @negative @priority-high @REQ-020 @screen-edit-order
  Scenario Outline: OMS014-NEG-022: Akses URL Edit Order langsung pada status <status> ditolak sistem
    Given terdapat order "FTL" berstatus "<status>"
    When user membuka URL "/order/<idOrder>/edit"
    Then user tidak berada di halaman "Edit Order"
    And sistem menampilkan "tidak diizinkan"

    Examples:
      | status            | idOrder         |
      | Ditugaskan        | ORD-20260607009 |
      | Proses Pengiriman | ORD-20260607010 |
      | Terkirim          | ORD-20260607011 |
      | Dibatalkan        | ORD-20260607012 |

  @negative @priority-high @REQ-020 @screen-daftar-order
  Scenario Outline: OMS014-NEG-023: Aksi Edit tidak tersedia pada order berstatus <status>
    Given terdapat order "FCL" berstatus "<status>"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada baris order tersebut
    Then sistem tidak menampilkan "Edit"

    Examples:
      | status            |
      | Ditugaskan        |
      | Proses Pengiriman |
      | Terkirim          |
      | Dibatalkan        |

  @negative @priority-medium @REQ-021 @screen-daftar-order
  Scenario Outline: OMS014-NEG-024: Aksi Batalkan Order tidak tersedia pada order berstatus <status>
    Given terdapat order "FTL" berstatus "<status>"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada baris order tersebut
    Then sistem tidak menampilkan "Batalkan Order"

    Examples:
      | status     |
      | Terkirim   |
      | Dibatalkan |

  @negative @priority-medium @REQ-021 @screen-modal-batalkan @screen-detail-order
  Scenario: OMS014-NEG-025: Konfirmasi pembatalan tanpa mengisi Alasan Pembatalan ditolak
    Given user berada di halaman "Detail Order" untuk order "FTL" berstatus "Menunggu Penugasan"
    When user mengklik tombol "Batalkan Order"
    And user mengosongkan field "Alasan Pembatalan"
    And user mengklik tombol "Batalkan Order" pada dialog
    Then sistem menampilkan "harus diisi"
    And status order tetap "Menunggu Penugasan"

  @negative @priority-high @REQ-020 @REQ-021 @screen-detail-order
  Scenario: OMS014-NEG-026: Order berstatus Dibatalkan tidak dapat diedit dari Detail Order
    Given terdapat order "FTL" berstatus "Dibatalkan"
    When user membuka halaman "Detail Order" untuk order tersebut
    Then sistem tidak menampilkan "Edit Order"
    And sistem tidak menampilkan "Batalkan Order"
    And badge status pada Detail Order menampilkan "Dibatalkan"

  @negative @priority-high @REQ-022 @screen-app-shell @screen-daftar-order
  Scenario: OMS014-NEG-027: Guest yang belum terautentikasi ditolak mengakses URL modul order
    Given user belum terautentikasi
    When user membuka URL "/order/list"
    Then user diarahkan ke halaman "Login"
    And sistem tidak menampilkan "Daftar Order"

  @negative @priority-medium @REQ-003 @screen-pengaturan-sistem
  Scenario: OMS014-NEG-028: Staff Operasional tidak dapat mengubah toggle Auto Stuffing
    Given user login sebagai "Staff Operasional"
    When user membuka URL "/pengaturan-sistem"
    Then sistem menampilkan "tidak diizinkan"
    And sistem tidak menampilkan "Auto Stuffing"

  @negative @priority-medium @REQ-013 @screen-modal-pilih-barang
  Scenario: OMS014-NEG-029: Pencarian barang dengan kata kunci tidak dikenal menampilkan hasil kosong
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal"
    When user mengklik tombol "Pilih Barang" pada "Armada 1"
    And user mengisi field "Cari kode/nama barang" dengan "SKU-TIDAK-ADA-999"
    Then sistem menampilkan "Tidak ada data"
    And sistem menampilkan "0 barang terpilih"

  @negative @priority-medium @REQ-013 @screen-modal-pilih-barang @screen-step2
  Scenario: OMS014-NEG-030: Tombol Batal pada modal Pilih Barang menutup modal tanpa perubahan
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal"
    And "Armada 1" tidak memiliki baris barang
    When user mengklik tombol "Pilih Barang" pada "Armada 1"
    And user mencentang checkbox "SKU-PPR-001 - Kertas HVS A4 80 gsm"
    And user mengklik tombol "Batal"
    Then sistem tidak menampilkan "Pilih barang yang ingin ditambahkan ke order"
    And "Armada 1" tidak memiliki baris barang

  @negative @priority-medium @REQ-013 @screen-modal-pilih-barang @screen-step2
  Scenario: OMS014-NEG-031: SKU duplikat dalam satu unit tidak dapat ditambahkan dua kali
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal"
    And "Armada 1" sudah memiliki barang "SKU-PPR-001"
    When user mengklik tombol "Pilih Barang" pada "Armada 1"
    And user mengklik tombol "Simpan"
    Then jumlah baris "SKU-PPR-001" pada "Armada 1" adalah "1"

  @negative @priority-low @REQ-013 @screen-modal-pilih-barang @screen-step2
  Scenario: OMS014-NEG-032: Simpan pada modal Pilih Barang tanpa memilih barang tidak menambah baris
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal"
    And "Armada 3" tidak memiliki baris barang
    When user mengklik tombol "Pilih Barang" pada "Armada 3"
    And user mengklik tombol "Simpan"
    Then "Armada 3" tidak memiliki baris barang
    And sistem menampilkan "Belum ada barang. Klik"

  @negative @priority-medium @REQ-030 @screen-step1 @multipickup
  Scenario: OMS014-NEG-033: Menghapus alamat pickup sampai tersisa kurang dari dua ditolak
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman" untuk order "FTL" tipe "Multipickup" dengan "2" alamat pickup
    When user mengklik tombol "Hapus" pada "Pick Up 2"
    Then jumlah blok "Pick Up" adalah "2"
    And tombol "Hapus" pada "Pick Up 2" dalam keadaan disabled

  @negative @priority-medium @REQ-023 @screen-step2
  Scenario: OMS014-NEG-034: Card Data Unit pada Step 2 tidak dapat diedit
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal"
    When user mencoba mengubah nilai pada card "Data Unit"
    Then card "Data Unit" tidak memiliki elemen input
    And card "Data Unit" tidak memiliki elemen dropdown
    And sistem tidak menampilkan "Hitung Ulang Armada"

  @negative @priority-medium @REQ-013 @screen-step2
  Scenario: OMS014-NEG-035: Kode SKU bebas tidak dapat diinput langsung pada tabel barang
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal"
    Then kolom "Kode SKU" pada tabel barang tidak memiliki elemen input
    And satu-satunya cara menambah barang adalah melalui tombol "Pilih Barang"

  @negative @priority-medium @REQ-017 @screen-step1
  Scenario: OMS014-NEG-036: Field auto-fill wilayah tidak dapat diubah manual
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman" dengan "Drop Point Asal" terpilih
    When user mencoba mengisi field "Provinsi Asal" dengan "Jawa Barat"
    Then field "Provinsi Asal" bersifat read-only
    And nilai field "Provinsi Asal" tidak berubah

  @negative @priority-low @REQ-001 @screen-step1 @ftl
  Scenario: OMS014-NEG-037: Jumlah Armada bernilai nol atau negatif ditolak
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    And user memilih kartu jenis order "FTL"
    When user mengisi field "Jumlah Armada" dengan "0"
    And user mengklik tombol "Selanjutnya"
    Then user tetap berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user mengisi field "Jumlah Armada" dengan "-3"
    Then nilai field "Jumlah Armada" tidak bernilai negatif

  @negative @priority-low @REQ-001 @screen-step1 @fcl
  Scenario: OMS014-NEG-038: Pelabuhan Tujuan sama dengan Pelabuhan Asal memunculkan peringatan
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    And user memilih kartu jenis order "FCL"
    When user memilih "Tanjung Perak (SUB)" pada dropdown "Pelabuhan Asal"
    And user memilih "Tanjung Perak (SUB)" pada dropdown "Pelabuhan Tujuan"
    Then sistem menampilkan "tidak boleh sama"

  @negative @priority-low @screen-daftar-order
  Scenario: OMS014-NEG-039: Pembuatan order ditolak ketika kuota order sudah habis
    Given kuota order tenant menunjukkan "300/300"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Buat Order"
    Then sistem menampilkan "Kuota order habis"
    And user tetap berada di halaman "Daftar Order"

  @negative @priority-medium @REQ-020 @REQ-024 @screen-daftar-order
  Scenario: OMS014-NEG-040: Aksi Lanjutkan Pengisian tidak tersedia pada order yang sudah lengkap
    Given terdapat order "FTL" berstatus "Menunggu Penugasan"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi" pada baris order tersebut
    Then sistem tidak menampilkan "Lanjutkan Pengisian"
    And sistem menampilkan "Edit"

  # --- OMS014-NEG-041..045: tambahan hasil review (coverage.md rec #1, #2, #5) ---

  @negative @priority-high @REQ-004 @REQ-025 @screen-step4
  Scenario: OMS014-NEG-041: Deep link URL dan shortcut keyboard tidak memunculkan Visualisasi Muatan pada Step 4 Review
    Given user berada di halaman "Buat Order - Step 4 Review" untuk order "FTL" tipe "Normal"
    When user membuka URL "/order/create/step-4?panel=visualisasi-muatan"
    Then sistem tidak menampilkan "Visualisasi Muatan"
    And sistem tidak menampilkan "Visualisasi Muatan Saat Ini"
    When user menekan shortcut keyboard "Control+Shift+V"
    Then sistem tidak menampilkan "Visualisasi Muatan"
    And elemen "load-visualization-canvas" memiliki jumlah "0"

  @negative @priority-high @REQ-004 @REQ-027 @screen-detail-order
  Scenario: OMS014-NEG-042: Deep link URL dan shortcut keyboard tidak memunculkan Visualisasi Muatan pada Detail Order
    Given terdapat order "FCL" tipe "Normal" berstatus "Menunggu Penugasan"
    When user membuka halaman "Detail Order" untuk order tersebut dengan query "?panel=visualisasi-muatan"
    Then sistem tidak menampilkan "Visualisasi Muatan"
    And sistem tidak menampilkan "Berat Terpakai"
    When user menekan shortcut keyboard "Control+Shift+V"
    Then sistem tidak menampilkan "Visualisasi Muatan"
    And elemen "load-visualization-canvas" memiliki jumlah "0"

  @negative @priority-medium @REQ-031 @screen-step1 @multidrop
  Scenario: OMS014-NEG-043: Menghapus alamat dropoff sampai tersisa kurang dari dua ditolak
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman" untuk order "FTL" tipe "Multidrop" dengan "2" alamat dropoff
    When user mengklik tombol "Hapus" pada "Drop Off 2"
    Then jumlah blok "Drop Off" adalah "2"
    And tombol "Hapus" pada "Drop Off 2" dalam keadaan disabled

  @negative @priority-medium @REQ-032 @screen-step1 @multipoint
  Scenario: OMS014-NEG-044: Multipoint - menghapus alamat pickup maupun dropoff di bawah minimum ditolak
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman" untuk order "FCL" tipe "Multipoint" dengan "2" alamat pickup dan "2" alamat dropoff
    When user mengklik tombol "Hapus" pada "Pick Up 2"
    Then jumlah blok "Pick Up" adalah "2"
    And tombol "Hapus" pada "Pick Up 2" dalam keadaan disabled
    When user mengklik tombol "Hapus" pada "Drop Off 2"
    Then jumlah blok "Drop Off" adalah "2"
    And tombol "Hapus" pada "Drop Off 2" dalam keadaan disabled

  # Direkategorisasi dari OMS014-EDG-004 (review rec #5 - konvensi: nilai 0 pada field wajib = negative, selaras NEG-009)
  @negative @priority-medium @REQ-014 @screen-step2
  Scenario: OMS014-NEG-045: Nilai Barang bernilai nol saat asuransi aktif diperlakukan sebagai kosong
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal"
    And "Armada 1" diasuransikan dan memiliki barang "SKU-PPR-001" dengan "Jumlah" "200"
    When user mengisi field "Nilai Barang" pada baris "SKU-PPR-001" dengan "0"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Nilai Barang harus diisi"
    And user tetap berada di halaman "Buat Order - Step 2 Data Barang"

  # ==========================================================================================
  # KATEGORI: EDGE
  # ==========================================================================================

  @edge @priority-medium @REQ-001 @REQ-023 @screen-step1 @screen-step2 @ftl
  Scenario: OMS014-EDG-001: Batas bawah Jumlah Armada bernilai satu menghasilkan satu blok unit
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    And user memilih kartu jenis order "FTL"
    When user mengisi field "Jumlah Armada" dengan "1"
    And user melengkapi field wajib Step 1 lalu mengklik tombol "Selanjutnya"
    Then jumlah blok unit pada Step 2 adalah "1"
    And sistem menampilkan "Armada 1"
    And sistem tidak menampilkan "Armada 2"

  @edge @priority-medium @REQ-010 @screen-step2 @screen-step3
  Scenario: OMS014-EDG-002: Batas bawah Jumlah barang bernilai satu diterima sistem
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal"
    And "Armada 1" memiliki barang "SKU-PPR-001"
    When user mengisi field "Jumlah" pada baris "SKU-PPR-001" dengan "1"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 3 Vendor dan Harga"
    And baris rekap "Armada 1" menampilkan "Total Berat" "12,5 kg"

  @edge @priority-medium @REQ-016 @screen-step2
  Scenario: OMS014-EDG-003: Jumlah barang sangat besar tetap non-blocking dengan peringatan kapasitas
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal"
    And "Armada 1" memiliki barang "SKU-PPR-001"
    When user mengisi field "Jumlah" pada baris "SKU-PPR-001" dengan "999999"
    Then sistem menampilkan "Kubikasi melebihi kapasitas armada"
    And sistem menampilkan "Berat melebihi kapasitas armada"
    And tombol "Selanjutnya" dalam keadaan enabled

  # OMS014-EDG-004 dipindahkan menjadi OMS014-NEG-045 (review rec #5 - rekategorisasi edge -> negative)

  @edge @priority-low @REQ-014 @screen-step2 @screen-step3
  Scenario: OMS014-EDG-005: Nilai Barang bernilai sangat besar diformat ribuan dengan benar
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal"
    And "Armada 1" diasuransikan dan memiliki barang "SKU-PPR-001" dengan "Jumlah" "1"
    When user mengisi field "Nilai Barang" pada baris "SKU-PPR-001" dengan "999999999999"
    Then nilai field "Nilai Barang" ditampilkan sebagai "999.999.999.999"
    When user mengklik tombol "Selanjutnya"
    Then baris rekap "Armada 1" menampilkan "Rp999.999.999.999"

  @edge @priority-low @REQ-015 @screen-step2
  Scenario: OMS014-EDG-006: Nomor DO dengan koma berturut dan spasi berlebih menghasilkan chip bersih
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal"
    When user mengisi field "Nomor DO" pada "Armada 1" dengan "TGK783898202U,,   ,TBL28371302  ,"
    Then jumlah chip "Nomor DO" pada "Armada 1" adalah "2"
    And sistem menampilkan "TGK783898202U"
    And sistem menampilkan "TBL28371302"

  @edge @priority-low @REQ-015 @screen-step2 @screen-step4
  Scenario: OMS014-EDG-007: Nomor DO berisi karakter spesial dan unicode ditampilkan apa adanya
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal"
    When user mengisi field "Nomor DO" pada "Armada 1" dengan "DO-#001/&é中文, DO<script>alert(1)</script>"
    Then jumlah chip "Nomor DO" pada "Armada 1" adalah "2"
    And sistem tidak mengeksekusi skrip pada halaman
    And sistem menampilkan "DO-#001/&é中文"

  @edge @priority-low @REQ-015 @screen-step2
  Scenario: OMS014-EDG-008: Nomor DO tunggal sepanjang 255 karakter ditangani tanpa merusak layout
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal"
    When user mengisi field "Nomor DO" pada "Armada 1" dengan teks sepanjang "255" karakter
    Then jumlah chip "Nomor DO" pada "Armada 1" adalah "1"
    And chip "Nomor DO" tidak melampaui lebar kontainer

  @edge @priority-low @REQ-017 @REQ-026 @screen-step1 @screen-step4
  Scenario: OMS014-EDG-009: Catatan dengan karakter spesial dan emoji tersimpan dan ditampilkan benar
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman" dengan seluruh field terisi
    When user mengisi field "Catatan" dengan "Muat pagi ✅ — pintu gudang #3 & ramp <B>"
    And user mengklik tombol "Selanjutnya"
    And user melengkapi Step 2 dan Step 3 lalu membuka Step 4
    Then sistem menampilkan "Muat pagi ✅ — pintu gudang #3 & ramp <B>"

  @edge @priority-low @REQ-017 @screen-step1
  Scenario: OMS014-EDG-010: PIC Pengirim dengan apostrof dan tanda hubung diterima
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman" dengan seluruh field terisi
    When user mengisi field "PIC Pengirim" dengan "R. O'Brien-Sutrisno"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 2 Data Barang"

  @edge @priority-medium @REQ-017 @screen-step1
  Scenario Outline: OMS014-EDG-011: Boundary panjang No. WhatsApp PIC sebanyak <digit> digit
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman" dengan seluruh field terisi
    When user mengisi field "No. WhatsApp PIC" dengan "<nilai>"
    And user mengklik tombol "Selanjutnya"
    Then hasil validasi adalah "<hasil>"

    Examples:
      | digit | nilai            | hasil    |
      | 9     | 081234567        | ditolak  |
      | 10    | 0812345678       | diterima |
      | 15    | 081234567898765  | diterima |
      | 16    | 0812345678987654 | ditolak  |

  @edge @priority-low @REQ-028 @screen-step3
  Scenario Outline: OMS014-EDG-012: Boundary nilai PPN <ppn> persen pada komponen harga
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga" untuk order "FTL" tipe "Normal"
    And user mencentang checkbox "Gunakan komponen harga"
    When user mengisi field "PPN" dengan "<ppn>"
    Then hasil validasi adalah "<hasil>"

    Examples:
      | ppn   | hasil    |
      | 0     | diterima |
      | 100   | diterima |
      | 100,1 | ditolak  |

  @edge @priority-low @REQ-028 @screen-step3
  Scenario: OMS014-EDG-013: Waktu Perjalanan pada batas bawah satu jam dan nilai sangat besar
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga" untuk order "FTL" tipe "Normal"
    When user mengisi field "Waktu Perjalanan" dengan "1"
    And user melengkapi field wajib lain pada Step 3
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 4 Review"
    When user mengklik tombol "Sebelumnya"
    And user mengisi field "Waktu Perjalanan" dengan "9999"
    Then nilai field "Waktu Perjalanan" adalah "9999"

  @edge @priority-low @REQ-028 @screen-step3
  Scenario: OMS014-EDG-014: Tanggal Permintaan Muat tepat pada waktu saat ini diterima
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga" untuk order "FTL" tipe "Normal"
    When user mengisi field "Tanggal Permintaan Muat" dengan waktu saat ini
    And user melengkapi field wajib lain pada Step 3
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 4 Review"

  @edge @priority-medium @REQ-016 @screen-step2
  Scenario: OMS014-EDG-015: Total kubikasi tepat sama dengan kapasitas tidak memunculkan badge peringatan
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal" dengan armada berkapasitas "17,86 m³"
    And "Armada 1" memiliki barang "SKU-PPR-001"
    When user mengisi field "Jumlah" pada baris "SKU-PPR-001" sehingga total kubikasi tepat "17,86"
    Then sistem tidak menampilkan "Kubikasi melebihi kapasitas armada"
    And sistem menampilkan "Total Kubikasi: 17,86 / 17,86 m³"

  @edge @priority-medium @REQ-016 @screen-step2
  Scenario: OMS014-EDG-016: Total berat satu satuan di atas kapasitas memunculkan badge peringatan
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal" dengan armada berkapasitas "24.800 kg"
    And "Armada 2" memiliki barang "SKU-BKU-001"
    When user mengisi field "Jumlah" pada baris "SKU-BKU-001" sehingga total berat melebihi kapasitas sebesar "1" kg
    Then sistem menampilkan "Berat melebihi kapasitas armada"
    And tombol "Selanjutnya" dalam keadaan enabled

  @edge @priority-medium @REQ-010 @REQ-026 @screen-step4 @screen-detail-order @screen-step2
  Scenario: OMS014-EDG-017: Order dengan hanya satu unit terisi dari tiga unit tetap dapat disimpan
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal" dengan "3" armada
    And hanya "Armada 1" yang memiliki barang
    When user melengkapi Step 3 dan mengklik tombol "Selanjutnya"
    And user mengklik tombol "Simpan"
    Then user diarahkan ke halaman "Daftar Order"
    When user membuka "Detail Order" dari baris order terbaru
    Then "Armada 2" tidak memiliki baris barang
    And "Armada 3" tidak memiliki baris barang

  @edge @priority-medium @REQ-032 @screen-step2 @multipoint
  Scenario: OMS014-EDG-018: Multipoint dengan tiga pickup dan dua dropoff menghasilkan enam sub-section per unit
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Multipoint" dengan "3" alamat pickup dan "2" alamat dropoff
    Then jumlah sub-section kombinasi pada "Armada 1" adalah "6"
    And seluruh sub-section kombinasi dalam kondisi kosong
    And sistem tidak menampilkan "Visualisasi Terbaru"

  @edge @priority-medium @REQ-008 @REQ-023 @screen-step1 @screen-step2
  Scenario: OMS014-EDG-019: Menurunkan Jumlah Armada dari tiga ke dua menghapus unit terakhir tanpa redistribusi
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal" dengan "3" armada terisi
    When user mengklik tombol "Sebelumnya"
    And user mengisi field "Jumlah Armada" dengan "2"
    And user mengklik tombol "Selanjutnya"
    Then jumlah blok unit pada Step 2 adalah "2"
    And nilai field "Jumlah" pada baris "SKU-PPR-001" di "Armada 1" tetap "200"
    And nilai field "Jumlah" pada baris "SKU-BKU-001" di "Armada 2" tetap "50"

  @edge @priority-medium @REQ-009 @REQ-030 @screen-step1 @screen-step2 @multipickup
  Scenario: OMS014-EDG-020: Menghapus alamat Pick Up di tengah menyesuaikan sub-section Step 2 tanpa memindahkan barang
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman" untuk order "FTL" tipe "Multipickup" dengan "3" alamat pickup
    And barang sudah diisi pada "Pick Up 1" dan "Pick Up 3"
    When user mengklik tombol "Hapus" pada "Pick Up 2"
    And user mengklik tombol "Selanjutnya"
    Then jumlah sub-section alamat pada "Armada 1" adalah "2"
    And barang pada sub-section pertama tetap sesuai input "Pick Up 1"
    And tidak ada barang yang berpindah antar sub-section

  @edge @priority-low @REQ-008 @REQ-012 @screen-step2 @screen-step3
  Scenario: OMS014-EDG-021: Bolak-balik antar step sebanyak sepuluh kali tidak mengubah data barang
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal" terisi lengkap
    When user berpindah antara Step 2 dan Step 3 sebanyak "10" kali
    Then nilai field "Jumlah" pada baris "SKU-PPR-001" tetap "200"
    And jumlah baris barang pada "Armada 1" tetap "1"
    And sistem tidak menampilkan "Hitung Ulang Armada"

  @edge @priority-high @REQ-003 @REQ-008 @REQ-024 @screen-daftar-order @screen-step2 @screen-pengaturan-sistem
  Scenario: OMS014-EDG-022: Toggle Auto Stuffing diubah ke ON saat terdapat draft mode OFF tidak mengubah data barang manual
    Given terdapat order draft "FTL" tipe "Multidrop" yang diisi pada mode "OFF"
    And user mencatat isi tabel barang seluruh unit pada draft tersebut
    When System Admin mengubah toggle "Auto Stuffing" ke "ON"
    And user membuka draft melalui aksi "Lanjutkan Pengisian"
    Then isi tabel barang seluruh unit sama dengan catatan sebelumnya
    And tidak ada barang yang terdistribusi ulang secara otomatis

  @edge @priority-low @REQ-024 @screen-step2 @screen-daftar-order
  Scenario: OMS014-EDG-023: Refresh browser pada Step 2 tanpa simpan draf tidak menyisakan data setengah jadi
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal" terisi sebagian
    When user memuat ulang halaman "Buat Order - Step 2 Data Barang"
    Then sistem menampilkan konfirmasi kehilangan data atau mengembalikan user ke halaman "Daftar Order"
    And tidak terbentuk order baru pada "Daftar Order"

  @edge @priority-low @REQ-013 @screen-modal-pilih-barang
  Scenario Outline: OMS014-EDG-024: Pencarian barang bersifat case-insensitive dan partial untuk kata kunci <kunci>
    Given user membuka modal "Pilih Barang" dari "Armada 1"
    When user mengisi field "Cari kode/nama barang" dengan "<kunci>"
    Then sistem menampilkan "<hasil>"

    Examples:
      | kunci | hasil                              |
      | hvs   | SKU-PPR-001 - Kertas HVS A4 80 gsm |
      | PPR   | SKU-PPR-002 - Kertas HVS F4 70 gsm |
      | buku  | SKU-BKU-001 - Buku Tulis 38 Lembar |

  @edge @priority-low @REQ-013 @screen-modal-pilih-barang
  Scenario: OMS014-EDG-025: Pencarian dengan karakter wildcard dan simbol SQL tidak menyebabkan error
    Given user membuka modal "Pilih Barang" dari "Armada 1"
    When user mengisi field "Cari kode/nama barang" dengan "%_' OR 1=1 --"
    Then sistem tidak menampilkan "500"
    And sistem menampilkan "Tidak ada data"

  @edge @priority-medium @REQ-014 @screen-step2 @screen-step3
  Scenario: OMS014-EDG-026: Menghapus centang Tambahkan Asuransi menyembunyikan kolom Nilai Barang
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal"
    And "Armada 1" diasuransikan dan "Nilai Barang" sudah terisi
    When user menghapus centang checkbox "Tambahkan Asuransi" pada "Armada 1"
    Then kolom "Nilai Barang" tidak tampil pada tabel barang "Armada 1"
    When user mengklik tombol "Selanjutnya"
    Then baris rekap "Armada 1" menampilkan "Tanpa Asuransi"

  @edge @priority-low @REQ-014 @screen-step2
  Scenario: OMS014-EDG-027: Mencentang ulang Tambahkan Asuransi setelah dilepas mewajibkan pengisian Nilai Barang kembali
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal"
    And "Armada 1" pernah diasuransikan lalu centangnya dilepas
    When user mencentang checkbox "Tambahkan Asuransi" pada "Armada 1"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Nilai Barang harus diisi"

  @edge @priority-medium @REQ-001 @REQ-026 @screen-step4 @screen-daftar-order @screen-step1 @screen-step2 @fcl @normal
  Scenario: OMS014-EDG-028: Order minimal satu kontainer dengan satu SKU dapat disimpan
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    And user memilih kartu jenis order "FCL"
    When user mengisi field "Jumlah Kontainer" dengan "1"
    And user melengkapi field wajib Step 1 lalu mengklik tombol "Selanjutnya"
    And user menambahkan barang "SKU-ATK-001" pada "Kontainer 1"
    And user mengisi field "Jumlah" pada baris "SKU-ATK-001" dengan "1"
    And user melengkapi Step 3 dan mengklik tombol "Selanjutnya"
    And user mengklik tombol "Simpan"
    Then user diarahkan ke halaman "Daftar Order"
    And sistem menampilkan "FCL"

  @edge @priority-low @REQ-022 @screen-daftar-order
  Scenario: OMS014-EDG-029: Filter dengan kombinasi seluruh kriteria menghasilkan tabel kosong yang tertangani
    Given user berada di halaman "Daftar Order"
    When user mengklik tombol "Filter"
    And user mengisi seluruh kriteria filter dengan nilai yang tidak mungkin cocok
    And user mengklik tombol "Terapkan"
    Then sistem menampilkan "Tidak ada data"
    And sistem tidak menampilkan "500"

  @edge @priority-low @REQ-022 @screen-daftar-order
  Scenario: OMS014-EDG-030: Navigasi ke halaman terakhir paginasi menampilkan info jumlah data yang benar
    Given user berada di halaman "Daftar Order" dengan "30" order
    When user memilih "20" pada dropdown "Tampilkan"
    And user mengklik tombol paginasi "»"
    Then sistem menampilkan "Menampilkan 21 - 30 data dari 30 data"

  @edge @priority-low @REQ-018 @screen-modal-no-perjalanan
  Scenario: OMS014-EDG-031: Menyalin nomor perjalanan menempatkan nilai persis ke clipboard
    Given user membuka modal "Data No. Perjalanan" untuk order "FCL" berstatus "Ditugaskan"
    When user mengklik tombol "Salin" pada baris pertama
    Then isi clipboard adalah "TRC79289802"

  @edge @priority-low @REQ-011 @REQ-013 @screen-step2
  Scenario: OMS014-EDG-032: Nama barang dan alamat sub-section yang sangat panjang tidak merusak layout tabel
    Given terdapat SKU dengan nama sepanjang "180" karakter pada master barang
    And user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Multipoint"
    When user menambahkan SKU tersebut pada kombinasi "Pick Up 1 - Drop Off 1"
    Then tabel barang tetap terlihat penuh tanpa overflow horizontal
    And judul sub-section tetap terbaca

  @edge @priority-low @REQ-024 @screen-step1 @screen-modal-draf
  Scenario: OMS014-EDG-033: Simpan ke Draf tersedia tepat setelah Tipe Pengiriman dipilih pada Step 1
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    And user memilih kartu jenis order "FTL"
    Then sistem tidak menampilkan "Simpan ke Draf"
    When user memilih "Normal" pada dropdown "Tipe Pengiriman"
    Then sistem menampilkan "Simpan ke Draf"
    When user mengklik tombol "Simpan ke Draf"
    Then sistem menampilkan "Anda yakin ingin menyimpan data dalam draf?"

  @edge @priority-low @REQ-012 @screen-step2 @screen-daftar-order
  Scenario: OMS014-EDG-034: Klik Batal di tengah wizard memunculkan konfirmasi dan tidak menyimpan order
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal" terisi sebagian
    When user mengklik tombol "Batal"
    Then sistem menampilkan konfirmasi pembatalan pengisian
    When user mengonfirmasi pembatalan
    Then user diarahkan ke halaman "Daftar Order"
    And tidak terbentuk order baru pada "Daftar Order"

  @edge @priority-low @REQ-009 @REQ-030 @screen-step1 @screen-step2 @multipickup
  Scenario: OMS014-EDG-035: Dua alamat Pick Up dengan Drop Point Asal yang sama tetap menghasilkan dua sub-section terpisah
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman" untuk order "FTL" tipe "Multipickup"
    When user memilih "Gudang MSK Region 2" pada dropdown "Drop Point Asal" untuk "Pick Up 1"
    And user memilih "Gudang MSK Region 2" pada dropdown "Drop Point Asal" untuk "Pick Up 2"
    And user mengklik tombol "Selanjutnya"
    Then jumlah sub-section alamat pada "Armada 1" adalah "2"
    And barang yang diisi pada "Pick Up 1" tidak muncul pada "Pick Up 2"

  @edge @priority-low @REQ-014 @REQ-028 @screen-step3 @screen-step4
  Scenario: OMS014-EDG-036: Order tanpa komponen harga hanya menampilkan Harga DPP dan Total Harga
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga" untuk order "FTL" tipe "Normal" tanpa unit diasuransikan
    When user mengisi field "Harga" dengan "30.000.000"
    And user tidak mencentang checkbox "Gunakan komponen harga"
    Then sistem tidak menampilkan "PPN ("
    And sistem tidak menampilkan "PPh ("
    And sistem tidak menampilkan "Asuransi ("
    And sistem menampilkan "Harga DPP"
    And sistem menampilkan "Total Harga"

  @edge @priority-low @REQ-008 @REQ-020 @screen-edit-order @screen-detail-order
  Scenario: OMS014-EDG-037: Menurunkan Jumlah Armada pada Edit Order menghapus unit terakhir beserta barangnya
    Given user berada di halaman "Edit Order" untuk order "FTL" berstatus "Menunggu Penugasan" dengan "3" armada
    When user mengisi field "Jumlah Armada" dengan "2"
    Then sistem menampilkan konfirmasi penghapusan unit
    When user mengonfirmasi penghapusan
    And user mengklik tombol "Simpan"
    Then user diarahkan ke halaman "Detail Order"
    And sistem tidak menampilkan "Armada 3"

  @edge @priority-low @REQ-027 @screen-detail-order
  Scenario: OMS014-EDG-038: Section Detail Order dapat dilipat dan dibuka kembali tanpa memunculkan elemen Auto Stuffing
    Given user berada di halaman "Detail Order" untuk order "FCL" tipe "Normal"
    When user melipat seluruh section pada Detail Order
    And user membuka kembali seluruh section pada Detail Order
    Then sistem menampilkan "Data Barang"
    And sistem tidak menampilkan "Visualisasi Muatan"
    And elemen "capacity-progress" memiliki jumlah "0"

  # ==========================================================================================
  # KATEGORI: STRESS
  # ==========================================================================================

  @stress @priority-medium @REQ-006 @REQ-008 @REQ-023 @screen-step1 @screen-step2 @ftl
  Scenario: OMS014-STR-001: Step 2 merender dua puluh blok armada tanpa elemen Auto Stuffing dan tetap responsif
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    And user memilih kartu jenis order "FTL"
    When user mengisi field "Jumlah Armada" dengan "20"
    And user melengkapi field wajib Step 1 lalu mengklik tombol "Selanjutnya"
    Then jumlah blok unit pada Step 2 adalah "20"
    And seluruh blok unit dalam kondisi kosong
    And sistem tidak menampilkan "Hitung Ulang Armada"
    And sistem tidak menampilkan "Visualisasi Terbaru"
    And waktu render halaman kurang dari "10" detik

  @stress @priority-medium @REQ-009 @REQ-011 @REQ-032 @screen-step2 @screen-step1 @ftl @multipoint
  Scenario: OMS014-STR-002: Multipoint lima pickup kali lima dropoff pada tiga armada menghasilkan tujuh puluh lima sub-section
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman" untuk order "FTL" tipe "Multipoint"
    When user menambahkan "5" alamat pickup dan "5" alamat dropoff
    And user mengisi field "Jumlah Armada" dengan "3"
    And user mengklik tombol "Selanjutnya"
    Then jumlah sub-section kombinasi pada "Armada 1" adalah "25"
    And total sub-section kombinasi pada Step 2 adalah "75"
    And seluruh sub-section kombinasi dalam kondisi kosong
    And sistem tidak menampilkan "Visualisasi Terbaru"

  @stress @priority-medium @REQ-010 @REQ-013 @REQ-016 @screen-step2 @screen-modal-pilih-barang
  Scenario: OMS014-STR-003: Menambahkan lima puluh SKU dalam satu unit dan mengisi Jumlah seluruhnya
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal"
    When user mengklik tombol "Pilih Barang" pada "Armada 1"
    And user mencentang "50" SKU pada modal "Pilih Barang"
    Then sistem menampilkan "50 barang terpilih"
    When user mengklik tombol "Simpan"
    Then jumlah baris barang pada "Armada 1" adalah "50"
    When user mengisi seluruh field "Jumlah" pada "Armada 1" dengan "100"
    Then sistem menampilkan "Kubikasi melebihi kapasitas armada"
    And tombol "Selanjutnya" dalam keadaan enabled

  @stress @priority-low @REQ-010 @REQ-016 @screen-step2
  Scenario: OMS014-STR-004: Jumlah barang bernilai maksimum integer pada banyak baris tidak menyebabkan overflow
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal"
    And "Armada 1" memiliki "10" baris barang
    When user mengisi seluruh field "Jumlah" pada "Armada 1" dengan "2147483647"
    Then sistem tidak menampilkan "NaN"
    And sistem tidak menampilkan "Infinity"
    And sistem menampilkan "Berat melebihi kapasitas armada"

  @stress @priority-low @REQ-015 @screen-step2
  Scenario: OMS014-STR-005: Lima puluh Nomor DO dipisahkan koma dirender menjadi lima puluh chip
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal"
    When user mengisi field "Nomor DO" pada "Armada 1" dengan "50" nomor yang dipisahkan koma
    Then jumlah chip "Nomor DO" pada "Armada 1" adalah "50"
    And sistem tidak menampilkan "500"

  @stress @priority-low @REQ-017 @REQ-026 @screen-step1 @screen-step4
  Scenario: OMS014-STR-006: Catatan sepanjang lima ribu karakter tersimpan dan ditampilkan pada Review
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman" dengan seluruh field terisi
    When user mengisi field "Catatan" dengan teks sepanjang "5000" karakter
    And user melengkapi Step 2 dan Step 3 lalu membuka Step 4
    Then sistem menampilkan potongan awal catatan tersebut
    And sistem tidak menampilkan "500"

  @stress @priority-medium @REQ-022 @screen-daftar-order
  Scenario: OMS014-STR-007: Daftar Order dengan sepuluh ribu order tetap dapat difilter dan dipaginasi
    Given terdapat "10000" order pada tenant
    And user berada di halaman "Daftar Order"
    Then sistem menampilkan "Menampilkan 1 - 20 data dari 10000 data"
    When user mengklik tombol "Filter"
    And user memilih "FCL" pada dropdown "Jenis Order"
    And user mengklik tombol "Terapkan"
    Then tabel order menampilkan hasil terfilter
    And waktu respons filter kurang dari "10" detik

  @stress @priority-high @REQ-012 @REQ-019 @screen-step4 @screen-daftar-order
  Scenario: OMS014-STR-008: Klik ganda cepat pada tombol Simpan Step 4 tidak menghasilkan order duplikat
    Given user berada di halaman "Buat Order - Step 4 Review" untuk order "FTL" tipe "Normal"
    When user mengklik tombol "Simpan" sebanyak "5" kali secara cepat
    Then user diarahkan ke halaman "Daftar Order"
    And jumlah order baru yang terbentuk adalah "1"

  @stress @priority-medium @REQ-020 @screen-edit-order
  Scenario: OMS014-STR-009: Dua sesi paralel mengedit order yang sama ditangani tanpa kehilangan data diam-diam
    Given sesi A dan sesi B membuka halaman "Edit Order" untuk order yang sama berstatus "Menunggu Penugasan"
    When sesi A mengisi field "Jumlah" pada baris "SKU-PPR-001" dengan "300" lalu mengklik tombol "Simpan"
    And sesi B mengisi field "Jumlah" pada baris "SKU-PPR-001" dengan "400" lalu mengklik tombol "Simpan"
    Then sesi B menerima pesan konflik atau perubahan terakhir tersimpan secara konsisten
    And sistem tidak menampilkan "500"

  @stress @priority-low @REQ-024 @screen-step2 @screen-modal-draf @screen-daftar-order
  Scenario: OMS014-STR-010: Simpan ke Draf ditekan sepuluh kali berturut-turut hanya menghasilkan satu draft
    Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL" tipe "Normal"
    When user mengklik tombol "Simpan ke Draf" lalu "Simpan Draf" sebanyak "10" kali secara cepat
    Then jumlah order draft yang terbentuk adalah "1"
    And sistem tidak menampilkan "500"

  @stress @priority-medium @REQ-013 @screen-modal-pilih-barang
  Scenario: OMS014-STR-011: Modal Pilih Barang dengan master lima ribu SKU tetap responsif saat pencarian
    Given master barang berisi "5000" SKU
    And user membuka modal "Pilih Barang" dari "Armada 1"
    When user mengisi field "Cari kode/nama barang" dengan "SKU-PPR-0001"
    Then sistem menampilkan "SKU-PPR-0001"
    And waktu respons pencarian kurang dari "5" detik
    And sistem tidak menampilkan "500"

  @stress @priority-low @REQ-001 @REQ-019 @screen-daftar-order @screen-step1 @screen-step2 @screen-step3 @screen-step4
  Scenario: OMS014-STR-012: Membuat dua puluh order berturut-turut dalam satu sesi tanpa degradasi
    Given user berada di halaman "Daftar Order"
    When user membuat "20" order "FTL" tipe "Normal" secara berturut-turut
    Then jumlah order baru yang terbentuk adalah "20"
    And seluruh order baru berstatus "Menunggu Penugasan"
    And sistem tidak menampilkan "500"

  @stress @priority-high @REQ-025 @REQ-026 @screen-step4
  Scenario: OMS014-STR-013: Step 4 Review order berukuran besar tetap bebas elemen Auto Stuffing
    Given user berada di halaman "Buat Order - Step 4 Review" untuk order "FCL" tipe "Multipoint" dengan "10" kontainer dan "20" SKU per kombinasi
    Then sistem menampilkan "Data Barang"
    And sistem tidak menampilkan "Visualisasi Muatan"
    And sistem tidak menampilkan "Berat Terpakai"
    And sistem tidak menampilkan "Ruang Terpakai"
    And elemen "load-visualization-canvas" memiliki jumlah "0"
    And waktu render halaman kurang dari "15" detik

  @stress @priority-medium @REQ-012 @screen-step4 @screen-daftar-order
  Scenario: OMS014-STR-014: Timeout jaringan saat menyimpan order menampilkan pesan error tanpa duplikasi order
    Given user berada di halaman "Buat Order - Step 4 Review" untuk order "FTL" tipe "Normal"
    And jaringan disimulasikan timeout pada endpoint penyimpanan order
    When user mengklik tombol "Simpan"
    Then sistem menampilkan "Terjadi kesalahan"
    And user tetap berada di halaman "Buat Order - Step 4 Review"
    When jaringan dipulihkan dan user mengklik tombol "Simpan"
    Then jumlah order baru yang terbentuk adalah "1"

  @stress @priority-medium @REQ-020 @REQ-021 @screen-edit-order @screen-detail-order
  Scenario: OMS014-STR-015: Pembatalan order oleh sesi lain saat sesi ini membuka Edit Order ditangani dengan benar
    Given sesi A membuka halaman "Edit Order" untuk order "FTL" berstatus "Menunggu Penugasan"
    When sesi B membatalkan order yang sama melalui "Batalkan Order"
    And sesi A mengklik tombol "Simpan"
    Then sistem menampilkan "tidak diizinkan"
    And status order tetap "Dibatalkan"

  @stress @priority-low @REQ-022 @screen-daftar-order
  Scenario: OMS014-STR-016: Filter, sorting, dan paginasi dijalankan tiga puluh kali berturut tanpa error
    Given user berada di halaman "Daftar Order"
    When user menjalankan kombinasi filter, sorting, dan paginasi sebanyak "30" kali
    Then sistem tidak menampilkan "500"
    And tabel order tetap menampilkan data yang konsisten

  @stress @priority-low @REQ-018 @screen-modal-no-perjalanan
  Scenario: OMS014-STR-017: Modal Data No. Perjalanan dengan seratus unit menampilkan seluruh baris dengan benar
    Given terdapat order "FCL" berstatus "Ditugaskan" dengan "100" kontainer
    When user membuka modal "Data No. Perjalanan" untuk order tersebut
    Then jumlah baris nomor perjalanan adalah "100"
    And modal dapat digulir sampai baris terakhir
    And sistem tidak menampilkan "500"

  @stress @priority-medium @REQ-003 @REQ-024 @screen-pengaturan-sistem @screen-daftar-order
  Scenario: OMS014-STR-018: Mengubah toggle Auto Stuffing saat terdapat lima puluh order draft tidak memicu error server
    Given terdapat "50" order draft pada tenant
    And user login sebagai "System Admin"
    When user mengubah toggle "Auto Stuffing" dari "OFF" ke "ON" lalu kembali ke "OFF"
    Then sistem tidak menampilkan "500"
    And jumlah order draft tetap "50"
    And data barang manual pada seluruh draft tidak berubah

  # ==========================================================================================
  # CATATAN ASUMSI BARU (scenario-generator) — tambahan atas ASM-001..ASM-028 pada analysis.md
  # ==========================================================================================
  # ASM-029  Pesan sukses/generik yang tidak tercantum pada katalog teks desain ditulis sebagai
  #          matcher longgar: "Pengaturan berhasil disimpan", "Terjadi kesalahan", "Tidak ada data",
  #          "Nomor perjalanan disalin", "Kuota order habis", "tidak diizinkan", "tidak valid",
  #          "tidak boleh sama". Implementasi Playwright disarankan memakai regex case-insensitive.
  # ASM-030  Lokasi toggle Auto Stuffing ditetapkan pada halaman "Pengaturan Sistem" (turunan ASM-006);
  #          layar ini tidak ada pada UI Inventory sehingga selectorHints memakai getByRole/getByTestId usulan.
  # ASM-031  Minimal satu baris barang per ORDER (bukan per unit) dijadikan aturan blocking Step 2
  #          (V3 "Ya (minimal 1 per order)"). Unit kosong tetap sah selama ada minimal satu unit terisi.
  # ASM-032  Kapasitas referensi memakai angka desain: armada "Tronton Box" 17,86 m³ / 24.800 kg,
  #          kontainer "20 Feet Dry" 38,27 m³ / 28.280 kg. Skenario boundary kapasitas memakai angka ini.
  # ASM-033  Endpoint auto stuffing diasumsikan mengandung segmen URL "auto-stuffing" untuk keperluan
  #          network assertion pada OMS014-POS-064; nama pasti harus dikonfirmasi ke tim BE.
  # ASM-034  Deep link/query param pada OMS014-NEG-020/021 ("?panel=hitung-ulang-armada",
  #          "?panel=visualisasi-muatan") adalah usulan; bila implementasi memakai skema lain,
  #          skenario tetap valid dengan menyesuaikan URL.
  # ASM-035  Sesuai D1–D9 pada analysis.md, skenario ini TIDAK meng-assert: judul card Step 3
  #          (D9 — assert per field), label "No. WhatsApp PIC" secara persis (D1 — pakai regex toleran),
  #          nilai "Tipe Pengiriman" pada layar dummy (D2), penamaan "Kontainer" pada order FTL (D3),
  #          highlight menu sidebar (D8), dan keberadaan "Waktu Perjalanan" pada Step 3 FCL secara
  #          kaku (D5/ASM-027 — dipakai conditional).
  # ASM-036  Empty state di-assert dengan partial match "Belum ada barang. Klik" (ASM-024) agar tolerans
  #          terhadap anomali spasi pada teks desain.
  # ASM-037  Menu sidebar "Simulasi Muatan" (A15) TIDAK dijadikan assertion wajib sesuai ASM-026;
  #          verifikasi dilakukan manual di luar suite otomatis.

  # ==========================================================================================
  # CHANGELOG PASCA-REVIEW (2026-08-23) — aplikasi rekomendasi #1-#5 coverage.md
  # ==========================================================================================
  # + OMS014-NEG-041/042  Bypass deep-link & shortcut untuk Step 4 Review dan Detail Order
  #                       (rec #1 — menutup gap REQ-025/REQ-027, AC-004.3).
  # + OMS014-NEG-043/044  Hapus alamat di bawah minimum ditolak untuk Multidrop & Multipoint
  #                       (rec #2 — menutup gap REQ-031/REQ-032, padanan NEG-033).
  # * OMS014-POS-060      Diperluas: assertion A8/A9/capacity-progress/load-visualization-canvas
  #                       + Examples 2 -> 8 kombinasi jenis x tipe (rec #3).
  # * OMS014-POS-018      Merge dengan OMS014-POS-063 (dihapus); assertion REQ-023 + REQ-008 digabung (rec #5).
  # * OMS014-NEG-045      Rekategorisasi dari OMS014-EDG-004 (dihapus); konvensi: nilai 0 pada
  #                       field wajib = negative, selaras NEG-009 (rec #5).
  # * Tag sync (rec #4)   POS-011 +REQ-004; POS-057 +REQ-008; NEG-027 +REQ-022; EDG-020 +REQ-030;
  #                       EDG-022 +REQ-008 +screen-pengaturan-sistem; EDG-035 +REQ-009;
  #                       STR-001 +REQ-006; STR-002 +REQ-009; STR-018 +REQ-024.
  # Total scenario: 173 (positive 73 / negative 45 / edge 37 / stress 18). ID EDG-004 & POS-063 sengaja tidak dipakai ulang.
