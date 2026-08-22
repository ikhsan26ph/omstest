# language: id
# ============================================================================
# Modul   : oms013-order-fcl-auto-stuffing
# Sumber  : output/oms013-order-fcl-auto-stuffing/oms013-order-fcl-auto-stuffing.analysis.md
#           (Requirements REQ-001..REQ-060, VAL-01..VAL-27, VAL-M1..VAL-M6,
#            AC-001..AC-066, UI Inventory S-01..S-19, Assumptions ASM-001..ASM-056)
# Mode    : AUTO — konflik desain vs spec diselesaikan dengan aturan
#           "desain = sumber kebenaran visual (selector/teks), spec = sumber
#            kebenaran expected result" (ASM-051).
# Total   : 246 scenario (95 positive / 70 negative / 55 edge / 26 stress)
# ============================================================================

Feature: Order FCL dengan Add-on Auto Stuffing pada OMS
  Sebagai Admin/Staff Operasional Shipper
  Saya ingin membuat, mengedit, membatalkan, dan menelusuri order FCL bersatuan Kontainer
  Agar proses pengiriman kontainer terkelola lengkap dengan visualisasi Auto Stuffing

  Background:
    Given user login sebagai "Admin Shipper" pada OMS "Mentari Sumber Kertas"

  # ==========================================================================
  # KATEGORI: POSITIVE
  # ==========================================================================

  @positive @priority-high @REQ-002 @screen-step1-data-pengiriman
  Scenario: [OMS013-POS-001] Wizard order FCL menampilkan 4 step sesuai urutan
    Given user berada di halaman "Daftar Order"
    When user mengklik tombol "Buat Order"
    And user memilih "Jenis Pengiriman" dengan "FCL"
    Then sistem menampilkan "01 Data Pengiriman"
    And sistem menampilkan "02 Data Barang"
    And sistem menampilkan "03 Vendor dan Harga"
    And sistem menampilkan "04 Review"

  @positive @priority-high @REQ-002 @screen-step2-data-barang
  Scenario: [OMS013-POS-002] Satuan unit order FCL adalah Kontainer
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    Then sistem menampilkan "Jenis Kontainer"
    And sistem menampilkan "Jumlah Kontainer"
    And sistem menampilkan "Kontainer 1"

  @positive @priority-high @REQ-003 @REQ-010 @screen-step2-data-barang
  Scenario: [OMS013-POS-003] Penambahan barang hanya melalui modal Pilih Barang
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    When user mengklik tombol "Pilih Barang"
    Then sistem menampilkan "Pilih Barang"
    And sistem menampilkan "Cari kode atau nama barang"

  @positive @priority-high @REQ-004 @REQ-034 @screen-step4-review
  Scenario: [OMS013-POS-004] Struktur Data Barang pada Review mengikuti Step 2
    Given user berada di halaman "Buat Order - Step 4 Review"
    Then sistem menampilkan "Kode SKU / Nama Barang"
    And sistem menampilkan "Kemasan"
    And sistem menampilkan "Kubikasi / Dimensi"
    And sistem menampilkan "Berat"
    And sistem menampilkan "Jumlah"
    And sistem menampilkan "Visualisasi Muatan"

  @positive @priority-high @REQ-005 @screen-step1-data-pengiriman
  Scenario: [OMS013-POS-005] Seluruh field wajib Step 1 tersedia saat halaman dimuat
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    Then sistem menampilkan "Pelabuhan Asal"
    And sistem menampilkan "Pelabuhan Tujuan"
    And sistem menampilkan "Jenis Kontainer"
    And sistem menampilkan "Jumlah Kontainer"
    And sistem menampilkan "Tipe Pengiriman"

  @positive @priority-high @REQ-005 @REQ-008 @screen-step1-data-pengiriman
  Scenario: [OMS013-POS-006] Melengkapi Step 1 tipe Normal lalu lanjut ke Step 2
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user memilih "Pelabuhan Asal" dengan "Tanjung Perak (SUB)"
    And user memilih "Pelabuhan Tujuan" dengan "Panjang (PNJ)"
    And user memilih "Jenis Kontainer" dengan "20 DRY"
    And user mengisi field "Jumlah Kontainer" dengan "2"
    And user memilih "Tipe Pengiriman" dengan "Normal"
    And user memilih "Metode Pengiriman" dengan "Door to Door"
    And user memilih "Drop Point Asal" dengan "Gudang MSK Region 2"
    And user memilih "Pengirim" dengan "PT Mentari Sumber Kertas"
    And user mengisi field "PIC Pengirim" dengan "Budi Santoso"
    And user mengisi field "No. WhatsApp PIC" dengan "081234567898"
    And user memilih "Drop Point Tujuan" dengan "Gudang Jaya Retail Lampung"
    And user memilih "Penerima" dengan "PT Jaya Retail"
    And user mengisi field "PIC Penerima" dengan "Siti Rahayu"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 2 Data Barang"

  @positive @priority-high @REQ-006 @screen-step1-data-pengiriman
  Scenario: [OMS013-POS-007] Data Pengirim auto-draft dari Master Droppoint
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user memilih "Drop Point Asal" dengan "Gudang MSK Region 2"
    Then sistem menampilkan "Jawa Timur"
    And sistem menampilkan "Kota Surabaya"
    And sistem menampilkan "Jl. Jambi No.35, Darmo, Wonokromo, Kota Surabaya, Jawa Timur 60241"

  @positive @priority-high @REQ-006 @screen-step1-data-pengiriman
  Scenario: [OMS013-POS-008] Data Penerima auto-draft dari Master Droppoint
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user memilih "Drop Point Tujuan" dengan "Gudang Jaya Retail Lampung"
    Then sistem menampilkan "Lampung"
    And sistem menampilkan "Kota Bandar Lampung"

  @positive @priority-high @REQ-007 @REQ-001 @screen-step1-data-pengiriman
  Scenario: [OMS013-POS-009] Tipe Multipickup dengan 2 titik pickup dapat dilanjutkan
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user memilih "Tipe Pengiriman" dengan "Multipickup"
    And user mengklik tombol "Tambah Baris Input"
    Then sistem menampilkan "Pick Up 1"
    And sistem menampilkan "Pick Up 2"
    And sistem menampilkan "Pastikan urutan pengiriman sudah sesuai saat membuat shipment"

  @positive @priority-high @REQ-007 @REQ-001 @screen-step1-data-pengiriman
  Scenario: [OMS013-POS-010] Tipe Multidrop dengan 2 titik drop dapat dilanjutkan
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user memilih "Tipe Pengiriman" dengan "Multidrop"
    And user mengklik tombol "Tambah Baris Input"
    Then sistem menampilkan "Drop Off 1"
    And sistem menampilkan "Drop Off 2"

  @positive @priority-high @REQ-007 @REQ-001 @screen-step1-data-pengiriman
  Scenario: [OMS013-POS-011] Tipe Multipoint menampilkan grup Pick Up dan Drop Off sekaligus
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user memilih "Tipe Pengiriman" dengan "Multipoint"
    And user mengklik tombol "Tambah Baris Input"
    Then sistem menampilkan "Pick Up 2"
    And sistem menampilkan "Drop Off 2"

  @positive @priority-medium @REQ-007 @screen-step1-data-pengiriman
  Scenario: [OMS013-POS-012] Tambah Baris Input menambah satu grup pickup baru
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user memilih "Tipe Pengiriman" dengan "Multipickup"
    And user mengklik tombol "Tambah Baris Input"
    And user mengklik tombol "Tambah Baris Input"
    Then sistem menampilkan "Pick Up 3"

  @positive @priority-medium @REQ-007 @screen-step1-data-pengiriman
  Scenario: [OMS013-POS-013] Hapus baris Pick Up 3 pada tipe Multipoint
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user memilih "Tipe Pengiriman" dengan "Multipoint"
    And user mengklik tombol "Tambah Baris Input"
    And user mengklik tombol "Tambah Baris Input"
    And user mengklik tombol "Hapus Baris Pick Up 3"
    Then sistem menampilkan "Pick Up 2"

  @positive @priority-high @REQ-008 @screen-step1-data-pengiriman
  Scenario: [OMS013-POS-014] Tombol Selanjutnya aktif setelah seluruh field wajib terisi
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user mengisi seluruh field wajib Step 1 dengan data valid
    Then sistem menampilkan "Selanjutnya" dalam kondisi enabled

  @positive @priority-high @REQ-041 @REQ-039 @screen-step1-data-pengiriman
  Scenario: [OMS013-POS-015] Simpan ke Draf pada Step 1 menghasilkan status Isi Data Pengiriman
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user mengisi seluruh field wajib Step 1 dengan data valid
    And user mengklik tombol "Simpan ke Draf"
    Then sistem menampilkan "Draf order berhasil disimpan"
    And user diarahkan ke halaman "Daftar Order"
    And sistem menampilkan "Isi Data Dasar"

  @positive @priority-medium @REQ-009 @screen-step1-data-pengiriman
  Scenario: [OMS013-POS-016] Memilih Metode Pengiriman Door to Door sesuai desain (ASM-028)
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user memilih "Tipe Pengiriman" dengan "Normal"
    And user memilih "Metode Pengiriman" dengan "Door to Door"
    Then sistem menampilkan "Kontainer diambil dari lokasi pengirim dan diantar hingga lokasi penerima."

  @positive @priority-medium @REQ-008 @screen-step1-data-pengiriman
  Scenario: [OMS013-POS-017] Klik Batal pada Step 1 menampilkan pop up konfirmasi
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user mengklik tombol "Batal"
    Then sistem menampilkan "Batalkan pengisian order?"
    And sistem menampilkan "Ya, Batalkan"

  @positive @priority-high @REQ-005 @screen-step2-data-barang
  Scenario: [OMS013-POS-018] Jumlah card kontainer pada Step 2 sesuai Jumlah Kontainer Step 1
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user mengisi field "Jumlah Kontainer" dengan "2"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Kontainer 1"
    And sistem menampilkan "Kontainer 2"

  @positive @priority-high @REQ-010 @screen-modal-pilih-barang
  Scenario: [OMS013-POS-019] Membuka modal Pilih Barang dari card kontainer
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    When user mengklik tombol "Pilih Barang"
    Then sistem menampilkan "Pilih Barang"
    And sistem menampilkan "Simpan"
    And sistem menampilkan "Batal"

  @positive @priority-high @REQ-011 @screen-modal-pilih-barang
  Scenario: [OMS013-POS-020] Pencarian barang berdasarkan kode SKU
    Given user berada di halaman "Modal Pilih Barang"
    When user mengisi field "Cari Barang" dengan "SKU-PPR-001"
    Then sistem menampilkan "SKU-PPR-001"
    And sistem menampilkan "Kertas HVS A4 80 gsm"

  @positive @priority-high @REQ-011 @screen-modal-pilih-barang
  Scenario: [OMS013-POS-021] Pencarian barang berdasarkan nama barang
    Given user berada di halaman "Modal Pilih Barang"
    When user mengisi field "Cari Barang" dengan "Buku Tulis"
    Then sistem menampilkan "Buku Tulis 38 Lembar"

  @positive @priority-high @REQ-012 @REQ-014 @screen-modal-pilih-barang
  Scenario: [OMS013-POS-022] Multi-select barang memperbarui counter terpilih
    Given user berada di halaman "Modal Pilih Barang"
    When user mencentang checkbox "SKU-PPR-001"
    And user mencentang checkbox "SKU-PPR-002"
    And user mencentang checkbox "SKU-BKU-001"
    Then sistem menampilkan "3 barang dipilih"

  @positive @priority-high @REQ-015 @screen-modal-pilih-barang
  Scenario: [OMS013-POS-023] Simpan pada modal Pilih Barang menambahkan barang ke kontainer
    Given user berada di halaman "Modal Pilih Barang"
    When user mencentang checkbox "SKU-PPR-001"
    And user mengklik tombol "Simpan"
    Then user diarahkan ke halaman "Buat Order - Step 2 Data Barang"
    And sistem menampilkan "SKU-PPR-001"
    And sistem menampilkan "Kertas HVS A4 80 gsm"

  @positive @priority-high @REQ-015 @screen-modal-pilih-barang
  Scenario: [OMS013-POS-024] Batal pada modal Pilih Barang tidak menambahkan barang
    Given user berada di halaman "Modal Pilih Barang"
    When user mencentang checkbox "SKU-PPR-001"
    And user mengklik tombol "Batal"
    Then user diarahkan ke halaman "Buat Order - Step 2 Data Barang"
    And sistem menampilkan "Belum ada barang. Klik \"Pilih Barang \""

  @positive @priority-high @REQ-013 @screen-modal-pilih-barang
  Scenario: [OMS013-POS-025] Label Sudah Ditambahkan tampil pada barang yang sudah masuk kontainer
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And kontainer 1 sudah berisi barang "SKU-PPR-001"
    When user mengklik tombol "Pilih Barang"
    Then sistem menampilkan "Sudah Ditambahkan"

  @positive @priority-high @REQ-016 @screen-step2-data-barang
  Scenario: [OMS013-POS-026] Field barang dari Master Barang bersifat read-only
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And kontainer 1 sudah berisi barang "SKU-PPR-001"
    Then sistem menampilkan "SKU-PPR-001"
    And sistem menampilkan "Dus"
    And sistem menampilkan "0,018 m³"
    And sistem menampilkan "31 × 22 × 26,4 cm"
    And sistem menampilkan "12,5 kg"

  @positive @priority-high @REQ-017 @screen-step2-data-barang
  Scenario: [OMS013-POS-027] Mengisi Jumlah barang valid lalu lanjut ke Step 3
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And kontainer 1 sudah berisi barang "SKU-PPR-001"
    When user mengisi field "Jumlah" dengan "200"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 3 Vendor dan Harga"

  @positive @priority-high @REQ-018 @REQ-019 @screen-step2-data-barang
  Scenario: [OMS013-POS-028] Mencentang Tambahkan Asuransi memunculkan kolom Nilai Barang untuk seluruh barang
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And kontainer 1 sudah berisi barang "SKU-PPR-001" dan "SKU-PPR-002"
    When user mencentang checkbox "Tambahkan Asuransi"
    Then sistem menampilkan "Nilai Barang"
    And sistem menampilkan "Berlaku untuk seluruh barang pada armada ini"

  @positive @priority-high @REQ-018 @screen-step2-data-barang
  Scenario: [OMS013-POS-029] Mengisi Nilai Barang saat asuransi aktif lalu lanjut ke Step 3
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And checkbox "Tambahkan Asuransi" pada kontainer 1 dalam kondisi tercentang
    When user mengisi field "Jumlah" dengan "200"
    And user mengisi field "Nilai Barang" dengan "1.320.000"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 3 Vendor dan Harga"

  @positive @priority-high @REQ-020 @screen-step2-data-barang
  Scenario: [OMS013-POS-030] Nomor DO multi-nilai dipisahkan koma dirender sebagai chip
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    When user mengisi field "Nomor DO" dengan "TGK783898202U,TBL28371302"
    Then sistem menampilkan "TGK783898202U"
    And sistem menampilkan "TBL28371302"
    And sistem menampilkan "Pisahkan dengan koma untuk menambahkan beberapa nomor"

  @positive @priority-medium @REQ-020 @screen-step2-data-barang
  Scenario: [OMS013-POS-031] Menghapus salah satu chip Nomor DO
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And field "Nomor DO" pada kontainer 1 berisi chip "TGK783898202U" dan "TBL28371302"
    When user mengklik tombol "Hapus Chip TGK783898202U"
    Then sistem menampilkan "TBL28371302"

  @positive @priority-high @REQ-021 @screen-step2-data-barang
  Scenario: [OMS013-POS-032] Menghapus baris barang melalui icon hapus
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And kontainer 1 sudah berisi barang "SKU-PPR-001" dan "SKU-PPR-002"
    When user mengklik tombol "Hapus Barang SKU-PPR-001"
    Then sistem menampilkan "SKU-PPR-002"

  @positive @priority-high @REQ-022 @screen-step2-data-barang
  Scenario: [OMS013-POS-033] Alert kapasitas bersifat informatif dan tidak memblokir Selanjutnya
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And total kubikasi kontainer 1 melebihi kapasitas maksimal
    When user mengisi field "Jumlah" dengan "200"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 3 Vendor dan Harga"

  @positive @priority-high @REQ-023 @screen-step2-data-barang
  Scenario: [OMS013-POS-034] Alert kubikasi melebihi kapasitas tampil saat kubikasi berlebih
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And total kubikasi kontainer 1 melebihi kapasitas maksimal
    Then sistem menampilkan "Kubikasi melebihi kapasitas armada"
    And sistem menampilkan "Total Kubikasi: 19,2 / 17,86 m³"

  @positive @priority-high @REQ-023 @screen-step2-data-barang
  Scenario: [OMS013-POS-035] Alert berat melebihi kapasitas tampil saat berat berlebih
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And total berat kontainer 2 melebihi kapasitas maksimal
    Then sistem menampilkan "Berat melebihi kapasitas armada"

  @positive @priority-medium @REQ-025 @screen-step2-data-barang
  Scenario: [OMS013-POS-036] Tombol Sebelumnya mengembalikan ke Step 1 dengan data tetap tersimpan
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    When user mengklik tombol "Sebelumnya"
    Then user diarahkan ke halaman "Buat Order - Step 1 Data Pengiriman"
    And sistem menampilkan "Tanjung Perak (SUB)"
    And sistem menampilkan "Panjang (PNJ)"

  @positive @priority-high @REQ-041 @REQ-039 @screen-step2-data-barang
  Scenario: [OMS013-POS-037] Simpan ke Draf pada Step 2 menghasilkan status Isi Data Muatan
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    When user mengklik tombol "Simpan ke Draf"
    Then sistem menampilkan "Draf order berhasil disimpan"
    And user diarahkan ke halaman "Daftar Order"
    And sistem menampilkan "Isi Data Muatan"

  @positive @priority-high @REQ-001 @REQ-007 @screen-step2-data-barang
  Scenario: [OMS013-POS-038] Step 2 tipe Multipickup menampilkan sub-card per titik pickup
    Given user berada di halaman "Buat Order - Step 2 Data Barang" dengan tipe pengiriman "Multipickup"
    Then sistem menampilkan "Pick Up 1  -  Jl. Jambi No.35, Darmo, Wonokromo, Kota Surabaya, Jawa Timur 60241"
    And sistem menampilkan "Pick Up 2"

  @positive @priority-high @REQ-001 @screen-step2-data-barang
  Scenario: [OMS013-POS-039] Step 2 tipe Multipoint menampilkan sub-card kombinasi kartesian Pick Up x Drop Off
    Given user berada di halaman "Buat Order - Step 2 Data Barang" dengan tipe pengiriman "Multipoint"
    And order memiliki 2 titik Pick Up dan 2 titik Drop Off
    Then sistem menampilkan "4 sub-card muatan pada Kontainer 1"

  @positive @priority-medium @REQ-004 @screen-modal-hitung-ulang
  Scenario: [OMS013-POS-040] Membuka modal Hitung Ulang Kontainer dari floating button Step 2
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    When user mengklik tombol "Hitung Ulang Kontainer"
    Then sistem menampilkan "Hitung Ulang Kontainer"
    And sistem menampilkan "Simulasi ulang kebutuhan unit dari muatan order ini. Terapkan untuk ubah data order."
    And sistem menampilkan "Berat Maksimal 1 Kontainer: 28.280 kg"

  @positive @priority-medium @REQ-004 @screen-modal-hitung-ulang
  Scenario: [OMS013-POS-041] Terapkan ke Order dari modal Hitung Ulang mengubah Jumlah Kontainer
    Given user berada di halaman "Modal Hitung Ulang Kontainer"
    When user mengklik tombol "Tambah Jumlah Kontainer"
    And user mengklik tombol "Terapkan ke Order"
    Then user diarahkan ke halaman "Buat Order - Step 2 Data Barang"
    And sistem menampilkan "Kontainer 3"

  @positive @priority-high @REQ-036 @REQ-004 @screen-modal-visualisasi-muatan
  Scenario: [OMS013-POS-042] Membuka modal Visualisasi Muatan Saat Ini dari Step 2
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    When user mengklik tombol "Visualisasi Muatan Saat Ini"
    Then sistem menampilkan "Visualisasi Muatan Saat Ini"
    And sistem menampilkan "Berat Terpakai"
    And sistem menampilkan "Ruang Terpakai"
    And sistem menampilkan "Drag: putar 360° • Scroll: zoom • Klik 2×: reset"

  @positive @priority-medium @REQ-036 @screen-modal-visualisasi-muatan
  Scenario: [OMS013-POS-043] Berpindah tab kontainer pada modal visualisasi muatan
    Given user berada di halaman "Modal Visualisasi Muatan Saat Ini"
    When user mengklik tombol "Kontainer 2"
    Then sistem menampilkan "Kontainer 2"
    And sistem menampilkan "Kertas HVS A4 80 gsm"

  @positive @priority-medium @REQ-004 @screen-modal-hitung-ulang
  Scenario: [OMS013-POS-044] Batal pada modal Hitung Ulang tidak mengubah data order
    Given user berada di halaman "Modal Hitung Ulang Kontainer"
    When user mengklik tombol "Tambah Jumlah Kontainer"
    And user mengklik tombol "Batal"
    Then user diarahkan ke halaman "Buat Order - Step 2 Data Barang"
    And sistem menampilkan "Jumlah Kontainer: 2"

  @positive @priority-medium @REQ-010 @screen-step2-data-barang
  Scenario: [OMS013-POS-045] Kontainer tanpa barang menampilkan empty state
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    Then sistem menampilkan "Belum ada barang. Klik \"Pilih Barang \""

  @positive @priority-high @REQ-026 @REQ-028 @screen-step3-vendor-harga
  Scenario: [OMS013-POS-046] Seluruh field Step 3 tampil saat halaman dimuat
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    Then sistem menampilkan "Vendor"
    And sistem menampilkan "Tanggal Permintaan Muat"
    And sistem menampilkan "Harga"
    And sistem menampilkan "Gunakan komponen harga"
    And sistem menampilkan "Drop Point Asal"
    And sistem menampilkan "Drop Point Tujuan"

  @positive @priority-high @REQ-026 @REQ-032 @screen-step3-vendor-harga
  Scenario: [OMS013-POS-047] Mengisi Step 3 lengkap lalu lanjut ke Step 4
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    When user memilih "Vendor" dengan "PT Logistik Transportasi Nusantara"
    And user mengisi field "Tanggal Permintaan Muat" dengan "24/07/2026 14:30"
    And user mengisi field "Harga" dengan "30.000.000"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 4 Review"

  @positive @priority-medium @REQ-027 @screen-step3-vendor-harga
  Scenario: [OMS013-POS-048] Ringkasan alamat tipe multi tampil sebagai label dan text link
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga" dengan tipe pengiriman "Multipickup"
    Then sistem menampilkan "Multipickup"
    And sistem menampilkan "Lihat Detail"

  @positive @priority-medium @REQ-027 @screen-modal-detail-multi
  Scenario: [OMS013-POS-049] Klik Lihat Detail membuka modal Detail Multipickup
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga" dengan tipe pengiriman "Multipickup"
    When user mengklik tombol "Lihat Detail"
    Then sistem menampilkan "Detail Multipickup"
    And sistem menampilkan "Pick Up 1 - Kota Surabaya"
    And sistem menampilkan "Gudang MSK Region 2:"

  @positive @priority-medium @REQ-027 @screen-modal-detail-multi
  Scenario: [OMS013-POS-050] Klik Lihat Detail tujuan membuka modal Detail Multidrop
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga" dengan tipe pengiriman "Multidrop"
    When user mengklik tombol "Lihat Detail Tujuan"
    Then sistem menampilkan "Detail Multidrop"
    And sistem menampilkan "Drop Off 1 - Kota Bandar Lampung"
    And sistem menampilkan "Drop Off 2 - Kab. Lampung Tengah"

  @positive @priority-high @REQ-028 @screen-step3-vendor-harga
  Scenario: [OMS013-POS-051] Checkbox Gunakan komponen harga memunculkan input PPN dan PPh
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    When user mencentang checkbox "Gunakan komponen harga"
    Then sistem menampilkan "PPN"
    And sistem menampilkan "PPh"

  @positive @priority-medium @REQ-028 @screen-step3-vendor-harga
  Scenario: [OMS013-POS-052] Step 3 tetap dapat dilanjutkan tanpa komponen harga
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    When user memilih "Vendor" dengan "PT Logistik Transportasi Nusantara"
    And user mengisi field "Tanggal Permintaan Muat" dengan "24/07/2026 14:30"
    And user mengisi field "Harga" dengan "30.000.000"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 4 Review"

  @positive @priority-high @REQ-031 @screen-step3-vendor-harga
  Scenario: [OMS013-POS-053] Komponen Asuransi dihitung dari persentase dikali Total Nilai Barang
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    And terdapat kontainer yang diasuransikan dengan Total Nilai Barang "1.006.750.000"
    When user mencentang checkbox "Gunakan komponen harga"
    And user mengisi field "Asuransi" dengan "0,2"
    Then sistem menampilkan "Asuransi (0,2%)"
    And sistem menampilkan "Rp2.013.500"
    And sistem menampilkan "(Total Nilai Barang = Rp1.006.750.000)"

  @positive @priority-high @REQ-029 @screen-step3-vendor-harga
  Scenario: [OMS013-POS-054] Step 3 FCL tidak menampilkan input Waktu Perjalanan
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    Then sistem tidak menampilkan "Waktu Perjalanan"

  @positive @priority-high @REQ-041 @REQ-039 @screen-step3-vendor-harga
  Scenario: [OMS013-POS-055] Simpan ke Draf pada Step 3 menghasilkan status Isi Data Vendor
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    When user mengklik tombol "Simpan ke Draf"
    Then sistem menampilkan "Draf order berhasil disimpan"
    And user diarahkan ke halaman "Daftar Order"
    And sistem menampilkan "Isi Data Vendor"

  @positive @priority-medium @REQ-032 @screen-step3-vendor-harga
  Scenario: [OMS013-POS-056] Tombol Sebelumnya pada Step 3 kembali ke Step 2 dengan data barang tetap
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    When user mengklik tombol "Sebelumnya"
    Then user diarahkan ke halaman "Buat Order - Step 2 Data Barang"
    And sistem menampilkan "SKU-PPR-001"

  @positive @priority-medium @REQ-026 @screen-step3-vendor-harga
  Scenario: [OMS013-POS-057] Tabel ringkasan unit Step 3 menampilkan seluruh kontainer
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    Then sistem menampilkan "Kontainer 1"
    And sistem menampilkan "Kontainer 2"
    And sistem menampilkan "Total Berat"
    And sistem menampilkan "Total Kubikasi"
    And sistem menampilkan "Total Nilai Barang"

  @positive @priority-high @REQ-033 @screen-step4-review
  Scenario: [OMS013-POS-058] Step 4 menampilkan seluruh data Step 1-3 secara read-only
    Given user berada di halaman "Buat Order - Step 4 Review"
    Then sistem menampilkan "Jenis Pengiriman : FCL (Full Container Load)"
    And sistem menampilkan "Jenis Kontainer : 20ft Dry Box"
    And sistem menampilkan "Jumlah Kontainer : 2"
    And sistem menampilkan "Pelabuhan Asal : Tanjung Perak (SUB)"
    And sistem menampilkan "Pelabuhan Tujuan : Panjang (PNJ)"
    And sistem menampilkan "Vendor : PT Logistik Transportasi Nusantara"

  @positive @priority-high @REQ-034 @screen-step4-review
  Scenario: [OMS013-POS-059] Data Barang Review menampilkan Nilai Barang hanya pada kontainer berasuransi
    Given user berada di halaman "Buat Order - Step 4 Review"
    And kontainer 2 diasuransikan dan kontainer 1 tidak diasuransikan
    Then sistem menampilkan "Nilai Barang"
    And sistem menampilkan "Tanpa Asuransi"

  @positive @priority-high @REQ-035 @screen-step4-review
  Scenario: [OMS013-POS-060] Badge Diasuransikan tampil pada kontainer yang diasuransikan
    Given user berada di halaman "Buat Order - Step 4 Review"
    And kontainer 2 diasuransikan
    Then sistem menampilkan "Diasuransikan"

  @positive @priority-high @REQ-036 @REQ-004 @screen-step4-review
  Scenario: [OMS013-POS-061] Klik button Visualisasi Muatan pada card Data Barang membuka pop up
    Given user berada di halaman "Buat Order - Step 4 Review"
    When user mengklik tombol "Visualisasi Muatan"
    Then sistem menampilkan "Visualisasi Muatan Saat Ini"
    And sistem menampilkan "Berat Terpakai"

  @positive @priority-high @REQ-037 @REQ-040 @screen-step4-review
  Scenario: [OMS013-POS-062] Simpan pada Step 4 mengubah status order menjadi Menunggu Penugasan
    Given user berada di halaman "Buat Order - Step 4 Review"
    When user mengklik tombol "Simpan"
    Then sistem menampilkan "Order berhasil disimpan"
    And user diarahkan ke halaman "Daftar Order"
    And sistem menampilkan "Menunggu Penugasan"

  @positive @priority-medium @REQ-041 @REQ-039 @screen-step4-review
  Scenario: [OMS013-POS-063] Simpan ke Draf pada Step 4 menghasilkan status Review Order
    Given user berada di halaman "Buat Order - Step 4 Review"
    When user mengklik tombol "Simpan ke Draf"
    Then user diarahkan ke halaman "Daftar Order"
    And sistem menampilkan "Review Order"

  @positive @priority-low @REQ-033 @screen-step4-review
  Scenario: [OMS013-POS-064] Section Review dapat di-collapse dan di-expand
    Given user berada di halaman "Buat Order - Step 4 Review"
    When user mengklik tombol "Collapse Data Pengirim"
    Then sistem tidak menampilkan "PIC Pengirim"
    When user mengklik tombol "Collapse Data Pengirim"
    Then sistem menampilkan "PIC Pengirim"

  @positive @priority-medium @REQ-033 @REQ-001 @screen-step4-review
  Scenario: [OMS013-POS-065] Review tipe Multipoint menampilkan seluruh pasangan alamat
    Given user berada di halaman "Buat Order - Step 4 Review" dengan tipe pengiriman "Multipoint"
    Then sistem menampilkan "Pick Up 1"
    And sistem menampilkan "Pick Up 2"
    And sistem menampilkan "Drop Off 1"
    And sistem menampilkan "Drop Off 2"

  @positive @priority-high @REQ-038 @screen-daftar-order
  Scenario: [OMS013-POS-066] Daftar Order menampilkan chip status yang valid
    Given user berada di halaman "Daftar Order"
    Then sistem menampilkan "Menunggu Penugasan"
    And sistem menampilkan "Ditugaskan"
    And sistem menampilkan "FCL"

  @positive @priority-high @REQ-050 @screen-daftar-order
  Scenario: [OMS013-POS-067] Action menu status draft menyediakan Lanjutkan Pengisian
    Given user berada di halaman "Daftar Order"
    And terdapat order FCL berstatus "Isi Data Muatan"
    When user mengklik tombol "Aksi Baris Order"
    Then sistem menampilkan "Detail"
    And sistem menampilkan "Lanjutkan Pengisian"
    And sistem menampilkan "Batalkan Order"
    And sistem menampilkan "Riwayat Perubahan"

  @positive @priority-high @REQ-051 @screen-daftar-order
  Scenario: [OMS013-POS-068] Action menu status Menunggu Penugasan menyediakan Edit
    Given user berada di halaman "Daftar Order"
    And terdapat order FCL berstatus "Menunggu Penugasan"
    When user mengklik tombol "Aksi Baris Order"
    Then sistem menampilkan "Detail"
    And sistem menampilkan "Edit"
    And sistem menampilkan "Batalkan Order"
    And sistem menampilkan "Riwayat Perubahan"

  @positive @priority-high @REQ-052 @REQ-057 @screen-daftar-order
  Scenario: [OMS013-POS-069] Action menu status Ditugaskan menyediakan Lihat No. Perjalanan
    Given user berada di halaman "Daftar Order"
    And terdapat order FCL berstatus "Ditugaskan"
    When user mengklik tombol "Aksi Baris Order"
    Then sistem menampilkan "Detail"
    And sistem menampilkan "Lihat No. Perjalanan"
    And sistem menampilkan "Batalkan Order"
    And sistem menampilkan "Riwayat Perubahan"

  @positive @priority-medium @REQ-053 @screen-daftar-order
  Scenario: [OMS013-POS-070] Tombol Riwayat Pembatalan menampilkan daftar order yang dibatalkan
    Given user berada di halaman "Daftar Order"
    When user mengklik tombol "Riwayat Pembatalan"
    Then sistem menampilkan "Riwayat Pembatalan"
    And sistem menampilkan "Dibatalkan"

  @positive @priority-medium @REQ-053 @screen-daftar-order
  Scenario: [OMS013-POS-071] Aksi Riwayat Perubahan menampilkan histori order terpilih saja
    Given user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi Baris Order"
    And user mengklik tombol "Riwayat Perubahan"
    Then sistem menampilkan "Riwayat Perubahan"
    And sistem menampilkan "ORD67890792"

  @positive @priority-medium @REQ-050 @screen-daftar-order
  Scenario: [OMS013-POS-072] Menerapkan filter pada Daftar Order
    Given user berada di halaman "Daftar Order"
    When user mengklik tombol "Filter"
    And user mengisi field "ID Order" dengan "ORD67890792"
    And user memilih "Status" dengan "Menunggu Penugasan"
    And user mengklik tombol "Terapkan"
    Then sistem menampilkan "ORD67890792"

  @positive @priority-low @REQ-050 @screen-daftar-order
  Scenario: [OMS013-POS-073] Reset filter mengembalikan seluruh field ke kondisi kosong
    Given user berada di halaman "Daftar Order"
    When user mengklik tombol "Filter"
    And user mengisi field "ID Order" dengan "ORD67890792"
    And user mengklik tombol "Reset"
    Then sistem menampilkan "Masukkan ID Order"

  @positive @priority-low @REQ-050 @screen-daftar-order
  Scenario: [OMS013-POS-074] Mengurutkan Daftar Order berdasarkan Total Harga
    Given user berada di halaman "Daftar Order"
    When user mengklik tombol "Sort Total Harga"
    Then sistem menampilkan "Total Harga"

  @positive @priority-low @REQ-050 @screen-daftar-order
  Scenario: [OMS013-POS-075] Navigasi paginasi ke halaman berikutnya
    Given user berada di halaman "Daftar Order"
    When user mengklik tombol "2"
    Then sistem menampilkan "Menampilkan 21 - 40 data dari 30 data"

  @positive @priority-low @REQ-050 @screen-daftar-order
  Scenario: [OMS013-POS-076] Mengubah jumlah data yang ditampilkan per halaman
    Given user berada di halaman "Daftar Order"
    When user memilih "Tampilkan" dengan "50"
    Then sistem menampilkan "Menampilkan 1 - 50 data dari 30 data"

  @positive @priority-high @REQ-050 @screen-daftar-order
  Scenario: [OMS013-POS-077] Lanjutkan Pengisian membuka wizard pada step terakhir
    Given user berada di halaman "Daftar Order"
    And terdapat order FCL berstatus "Isi Data Vendor"
    When user mengklik tombol "Aksi Baris Order"
    And user mengklik tombol "Lanjutkan Pengisian"
    Then user diarahkan ke halaman "Buat Order - Step 3 Vendor dan Harga"

  @positive @priority-high @REQ-042 @screen-edit-order
  Scenario: [OMS013-POS-078] Edit order berstatus Menunggu Penugasan berhasil disimpan
    Given user berada di halaman "Daftar Order"
    And terdapat order FCL berstatus "Menunggu Penugasan"
    When user mengklik tombol "Aksi Baris Order"
    And user mengklik tombol "Edit"
    Then user diarahkan ke halaman "Edit Order"
    When user mengisi field "Jumlah Kontainer" dengan "3"
    And user mengklik tombol "Simpan"
    And user mengklik tombol "Ya, Simpan"
    Then sistem menampilkan "Perubahan order berhasil disimpan"

  @positive @priority-high @REQ-044 @screen-edit-order
  Scenario: [OMS013-POS-079] Jenis Pengiriman dan Tipe Pengiriman terkunci pada Edit Order
    Given user berada di halaman "Edit Order"
    Then sistem menampilkan "FCL (Full Container Load)"
    And sistem menampilkan "Normal"
    And sistem menampilkan "Jenis Pengiriman dalam kondisi read-only"
    And sistem menampilkan "Tipe Pengiriman dalam kondisi read-only"

  @positive @priority-high @REQ-045 @screen-edit-order
  Scenario: [OMS013-POS-080] Field kontainer, alamat, barang, dan vendor dapat diubah pada Edit Order
    Given user berada di halaman "Edit Order"
    When user memilih "Jenis Kontainer" dengan "40 DRY"
    And user mengisi field "Jumlah Kontainer" dengan "2"
    And user mengisi field "PIC Pengirim" dengan "Budi Revisi"
    And user mengisi field "Jumlah" dengan "150"
    And user mengisi field "Harga" dengan "15.000.000"
    Then sistem menampilkan "40 DRY"
    And sistem menampilkan "Budi Revisi"

  @positive @priority-high @REQ-046 @screen-edit-order
  Scenario: [OMS013-POS-081] Klik Simpan pada Edit Order menampilkan pop up konfirmasi
    Given user berada di halaman "Edit Order"
    When user mengklik tombol "Simpan"
    Then sistem menampilkan "Simpan perubahan order?"
    And sistem menampilkan "Ya, Simpan"

  @positive @priority-high @REQ-046 @screen-edit-order
  Scenario: [OMS013-POS-082] Klik Batal pada Edit Order menampilkan pop up konfirmasi
    Given user berada di halaman "Edit Order"
    When user mengklik tombol "Batal"
    Then sistem menampilkan "Batalkan pengeditan order?"
    And sistem menampilkan "Ya, Batalkan"

  @positive @priority-medium @REQ-031 @screen-edit-order
  Scenario: [OMS013-POS-083] Komponen Asuransi tampil pada Edit Order saat ada kontainer diasuransikan
    Given user berada di halaman "Edit Order"
    And kontainer 2 diasuransikan
    Then sistem menampilkan "Asuransi"
    And sistem menampilkan "Asuransi (0,2%)"
    And sistem menampilkan "(Total Nilai Barang = Rp1.150.350.000)"

  @positive @priority-high @REQ-047 @REQ-049 @screen-daftar-order
  Scenario: [OMS013-POS-084] Membatalkan order dengan mengisi Alasan Pembatalan
    Given user berada di halaman "Daftar Order"
    And terdapat order FCL berstatus "Menunggu Penugasan"
    When user mengklik tombol "Aksi Baris Order"
    And user mengklik tombol "Batalkan Order"
    And user mengisi field "Alasan Pembatalan" dengan "Perubahan rencana pengiriman dari customer"
    And user mengklik tombol "Ya, Batalkan"
    Then sistem menampilkan "Order berhasil dibatalkan"
    And sistem menampilkan "Dibatalkan"

  @positive @priority-medium @REQ-047 @screen-detail-order
  Scenario: [OMS013-POS-085] Membatalkan order dari halaman Detail Order
    Given user berada di halaman "Detail Order"
    When user mengklik tombol "Batalkan Order"
    And user mengisi field "Alasan Pembatalan" dengan "Kontainer tidak tersedia"
    And user mengklik tombol "Ya, Batalkan"
    Then sistem menampilkan "Order berhasil dibatalkan"
    And sistem menampilkan "Dibatalkan"

  @positive @priority-high @REQ-058 @screen-modal-no-perjalanan
  Scenario: [OMS013-POS-086] Pop up Data No. Perjalanan menampilkan data per kontainer
    Given user berada di halaman "Daftar Order"
    And terdapat order FCL berstatus "Ditugaskan"
    When user mengklik tombol "Aksi Baris Order"
    And user mengklik tombol "Lihat No. Perjalanan"
    Then sistem menampilkan "Data No. Perjalanan"
    And sistem menampilkan "ID Order: ORD-20260607009"
    And sistem menampilkan "40 DRY"

  @positive @priority-medium @REQ-059 @screen-modal-no-perjalanan
  Scenario: [OMS013-POS-087] Icon copy menyalin No. Perjalanan ke clipboard
    Given user berada di halaman "Modal Data No. Perjalanan"
    When user mengklik tombol "Salin No. Perjalanan"
    Then sistem menampilkan "No. Perjalanan berhasil disalin"

  @positive @priority-high @REQ-055 @screen-modal-no-perjalanan
  Scenario: [OMS013-POS-088] Jumlah No. Perjalanan sama dengan jumlah kontainer yang dipesan
    Given user berada di halaman "Daftar Order"
    And terdapat order FCL berstatus "Ditugaskan" dengan 2 kontainer
    When user mengklik tombol "Aksi Baris Order"
    And user mengklik tombol "Lihat No. Perjalanan"
    Then sistem menampilkan "2 baris No. Perjalanan"

  @positive @priority-high @REQ-060 @screen-detail-order
  Scenario: [OMS013-POS-089] No. Perjalanan tampil pada halaman Detail Order berstatus Ditugaskan
    Given user berada di halaman "Detail Order" dengan status "Ditugaskan"
    Then sistem menampilkan "No. Perjalanan"
    And sistem menampilkan "TRC79289802"

  @positive @priority-high @REQ-030 @REQ-029 @screen-detail-order
  Scenario: [OMS013-POS-090] Waktu Perjalanan tampil pada Detail Order saat status Ditugaskan
    Given user berada di halaman "Detail Order" dengan status "Ditugaskan"
    Then sistem menampilkan "Waktu Perjalanan"
    And sistem menampilkan "Ditugaskan"

  @positive @priority-medium @REQ-054 @screen-public-tracking
  Scenario: [OMS013-POS-091] Public tracking menampilkan progress berdasarkan No. Perjalanan
    Given user berada di halaman "Public Tracking"
    When user mengisi field "No. Perjalanan" dengan "TRC79289802"
    And user mengklik tombol "Lacak"
    Then sistem menampilkan "Progress Perjalanan"
    And sistem menampilkan "TRC79289802"

  @positive @priority-medium @REQ-033 @screen-detail-order
  Scenario: [OMS013-POS-092] Detail Order status Menunggu Penugasan menampilkan seluruh section
    Given user berada di halaman "Detail Order" dengan status "Menunggu Penugasan"
    Then sistem menampilkan "Data Pengirim"
    And sistem menampilkan "Data Penerima"
    And sistem menampilkan "Data Barang"
    And sistem menampilkan "Vendor dan Harga"
    And sistem menampilkan "Menunggu Penugasan"

  @positive @priority-medium @REQ-002 @screen-daftar-order
  Scenario: [OMS013-POS-093] Membuat order FCL melalui Batch Order
    Given user berada di halaman "Daftar Order"
    When user mengklik tombol "Batch Order"
    And user mengunggah file "batch-order-fcl-valid.xlsx"
    And user mengklik tombol "Unggah"
    Then sistem menampilkan "Batch order berhasil diproses"

  @positive @priority-medium @REQ-040 @screen-daftar-order
  Scenario: [OMS013-POS-094] Transisi status order dari Ditugaskan ke Proses Pengiriman hingga Selesai
    Given user berada di halaman "Daftar Order"
    And terdapat order FCL berstatus "Ditugaskan"
    When vendor mengubah status penugasan menjadi "Dalam Perjalanan"
    Then sistem menampilkan "Proses Pengiriman"
    When seluruh kontainer selesai bongkar
    Then sistem menampilkan "Terkirim"

  @positive @priority-medium @REQ-024 @screen-step2-data-barang
  Scenario: [OMS013-POS-095] Helper error hilang setelah field Jumlah diisi ulang
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And field "Jumlah" pada kontainer 1 menampilkan error "Jumlah harus diisi"
    When user mengisi field "Jumlah" dengan "100"
    Then sistem tidak menampilkan "Jumlah harus diisi"

  # ==========================================================================
  # KATEGORI: NEGATIVE
  # ==========================================================================

  @negative @priority-high @REQ-008 @screen-step1-data-pengiriman
  Scenario: [OMS013-NEG-001] Tombol Selanjutnya disabled saat Step 1 masih kosong
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    Then sistem menampilkan "Selanjutnya dalam kondisi disabled"

  @negative @priority-high @REQ-005 @REQ-008 @screen-step1-data-pengiriman
  Scenario: [OMS013-NEG-002] Pelabuhan Asal kosong memblokir navigasi ke Step 2
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user mengisi seluruh field wajib Step 1 kecuali "Pelabuhan Asal"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Pelabuhan Asal harus diisi"
    And user tetap berada di halaman "Buat Order - Step 1 Data Pengiriman"

  @negative @priority-high @REQ-005 @REQ-008 @screen-step1-data-pengiriman
  Scenario: [OMS013-NEG-003] Pelabuhan Tujuan kosong memblokir navigasi ke Step 2
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user mengisi seluruh field wajib Step 1 kecuali "Pelabuhan Tujuan"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Pelabuhan Tujuan harus diisi"

  @negative @priority-medium @REQ-005 @screen-step1-data-pengiriman
  Scenario: [OMS013-NEG-004] Pelabuhan Asal sama dengan Pelabuhan Tujuan ditolak
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user memilih "Pelabuhan Asal" dengan "Tanjung Perak (SUB)"
    And user memilih "Pelabuhan Tujuan" dengan "Tanjung Perak (SUB)"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Pelabuhan Tujuan tidak boleh sama dengan Pelabuhan Asal"

  @negative @priority-high @REQ-005 @screen-step1-data-pengiriman
  Scenario: [OMS013-NEG-005] Jenis Kontainer kosong memblokir navigasi
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user mengisi seluruh field wajib Step 1 kecuali "Jenis Kontainer"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Jenis Kontainer harus diisi"

  @negative @priority-high @REQ-005 @screen-step1-data-pengiriman
  Scenario: [OMS013-NEG-006] Jumlah Kontainer kosong memblokir navigasi
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user mengisi field "Jumlah Kontainer" dengan ""
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Jumlah Kontainer harus diisi"

  @negative @priority-high @REQ-005 @screen-step1-data-pengiriman
  Scenario: [OMS013-NEG-007] Jumlah Kontainer bernilai nol ditolak
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user mengisi field "Jumlah Kontainer" dengan "0"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Jumlah Kontainer minimal 1"

  @negative @priority-medium @REQ-005 @screen-step1-data-pengiriman
  Scenario: [OMS013-NEG-008] Jumlah Kontainer bernilai negatif ditolak
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user mengisi field "Jumlah Kontainer" dengan "-3"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Jumlah Kontainer minimal 1"

  @negative @priority-high @REQ-005 @screen-step1-data-pengiriman
  Scenario: [OMS013-NEG-009] Tipe Pengiriman kosong menyembunyikan section alamat dan memblokir navigasi
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    Then sistem tidak menampilkan "Data Pengirim"
    And sistem menampilkan "Selanjutnya dalam kondisi disabled"

  @negative @priority-high @REQ-007 @screen-step1-data-pengiriman
  Scenario: [OMS013-NEG-010] Multipickup dengan hanya 1 titik pickup ditolak
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user memilih "Tipe Pengiriman" dengan "Multipickup"
    And user mengisi hanya 1 baris Pick Up
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Minimal 2 titik Pick Up untuk tipe Multipickup"

  @negative @priority-high @REQ-007 @screen-step1-data-pengiriman
  Scenario: [OMS013-NEG-011] Multidrop dengan hanya 1 titik drop ditolak
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user memilih "Tipe Pengiriman" dengan "Multidrop"
    And user mengisi hanya 1 baris Drop Off
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Minimal 2 titik Drop Off untuk tipe Multidrop"

  @negative @priority-high @REQ-007 @REQ-001 @screen-step1-data-pengiriman
  Scenario: [OMS013-NEG-012] Multipoint dengan 1 pickup dan 1 drop ditolak
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user memilih "Tipe Pengiriman" dengan "Multipoint"
    And user mengisi hanya 1 baris Pick Up dan 1 baris Drop Off
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Minimal 2 titik Pick Up dan 2 titik Drop Off untuk tipe Multipoint"

  @negative @priority-high @REQ-008 @screen-step1-data-pengiriman
  Scenario: [OMS013-NEG-013] PIC Pengirim kosong memblokir navigasi
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user mengisi field "PIC Pengirim" dengan ""
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "PIC Pengirim harus diisi"

  @negative @priority-medium @REQ-008 @screen-step1-data-pengiriman
  Scenario: [OMS013-NEG-014] No. WhatsApp PIC dengan format tidak valid ditolak
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user mengisi field "No. WhatsApp PIC" dengan "abc-123"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Format No. WhatsApp tidak valid"

  @negative @priority-high @REQ-006 @screen-step1-data-pengiriman
  Scenario: [OMS013-NEG-015] Drop Point Asal kosong menyebabkan field wilayah tetap kosong
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user memilih "Tipe Pengiriman" dengan "Normal"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Drop Point Asal harus diisi"
    And sistem menampilkan "Provinsi Asal dalam kondisi kosong"

  @negative @priority-high @REQ-009 @screen-step1-data-pengiriman
  Scenario: [OMS013-NEG-016] Field Metode Pengiriman seharusnya tidak tersedia pada OMS
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user memilih "Tipe Pengiriman" dengan "Normal"
    Then sistem tidak menampilkan "Metode Pengiriman"

  @negative @priority-high @REQ-003 @REQ-010 @screen-step2-data-barang
  Scenario: [OMS013-NEG-017] Step 2 tidak boleh menyediakan input deskripsi barang manual
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    Then sistem tidak menampilkan "Deskripsi Barang"
    And sistem tidak menampilkan "Masukkan Deskripsi Barang"

  @negative @priority-high @REQ-017 @REQ-024 @screen-step2-data-barang
  Scenario: [OMS013-NEG-018] Field Jumlah kosong memunculkan helper error dan border error
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And kontainer 1 sudah berisi barang "SKU-PPR-001"
    When user mengisi field "Jumlah" dengan ""
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Jumlah harus diisi"
    And user tetap berada di halaman "Buat Order - Step 2 Data Barang"

  @negative @priority-high @REQ-017 @screen-step2-data-barang
  Scenario: [OMS013-NEG-019] Field Jumlah bernilai nol ditolak
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    When user mengisi field "Jumlah" dengan "0"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Jumlah harus diisi"

  @negative @priority-medium @REQ-017 @screen-step2-data-barang
  Scenario: [OMS013-NEG-020] Field Jumlah bernilai negatif ditolak
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    When user mengisi field "Jumlah" dengan "-10"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Jumlah harus diisi"

  @negative @priority-high @REQ-018 @REQ-024 @screen-step2-data-barang
  Scenario: [OMS013-NEG-021] Nilai Barang kosong saat asuransi aktif memunculkan helper error
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And checkbox "Tambahkan Asuransi" pada kontainer 1 dalam kondisi tercentang
    When user mengisi field "Jumlah" dengan "200"
    And user mengisi field "Nilai Barang" dengan ""
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Nilai Barang harus diisi"
    And user tetap berada di halaman "Buat Order - Step 2 Data Barang"

  @negative @priority-high @REQ-018 @screen-step2-data-barang
  Scenario: [OMS013-NEG-022] Nilai Barang bernilai nol saat asuransi aktif ditolak
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And checkbox "Tambahkan Asuransi" pada kontainer 1 dalam kondisi tercentang
    When user mengisi field "Nilai Barang" dengan "0"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Nilai Barang harus diisi"

  @negative @priority-high @REQ-024 @screen-step2-data-barang
  Scenario: [OMS013-NEG-023] Navigasi Step 2 diblokir saat terdapat error pada kontainer manapun
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And kontainer 1 terisi valid dan kontainer 2 memiliki field Jumlah kosong
    When user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Jumlah harus diisi"
    And user tetap berada di halaman "Buat Order - Step 2 Data Barang"

  @negative @priority-high @REQ-016 @screen-step2-data-barang
  Scenario: [OMS013-NEG-024] Field read-only Master Barang tidak dapat diedit
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And kontainer 1 sudah berisi barang "SKU-PPR-001"
    When user mengisi field "Kode SKU" dengan "SKU-HACK-999"
    Then sistem menampilkan "SKU-PPR-001"

  @negative @priority-high @REQ-018 @screen-step2-data-barang
  Scenario: [OMS013-NEG-025] Kolom Nilai Barang tidak tampil saat asuransi tidak aktif
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And checkbox "Tambahkan Asuransi" pada kontainer 2 dalam kondisi tidak tercentang
    Then sistem tidak menampilkan "Nilai Barang"

  @negative @priority-high @REQ-019 @screen-step2-data-barang
  Scenario: [OMS013-NEG-026] Asuransi tidak boleh diterapkan hanya pada sebagian barang dalam satu kontainer
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And kontainer 1 sudah berisi barang "SKU-PPR-001" dan "SKU-PPR-002"
    When user mencentang checkbox "Tambahkan Asuransi"
    Then sistem menampilkan "Nilai Barang pada seluruh baris barang kontainer 1"
    And sistem tidak menampilkan "Checkbox Asuransi per baris barang"

  @negative @priority-high @REQ-023 @screen-step2-data-barang
  Scenario: [OMS013-NEG-027] Teks alert kapasitas harus memakai kata kontainer bukan armada
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And total kubikasi kontainer 1 melebihi kapasitas maksimal
    Then sistem menampilkan "Kubikasi melebihi kapasitas kontainer"
    And sistem tidak menampilkan "Kubikasi melebihi kapasitas armada"

  @negative @priority-high @REQ-023 @screen-step2-data-barang
  Scenario: [OMS013-NEG-028] Varian pesan gabungan kubikasi dan berat harus tampil saat keduanya berlebih
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And total kubikasi dan total berat kontainer 1 melebihi kapasitas maksimal
    Then sistem menampilkan "Kubikasi dan Berat melebihi kapasitas kontainer"

  @negative @priority-medium @REQ-022 @screen-step2-data-barang
  Scenario: [OMS013-NEG-029] Alert kapasitas tidak boleh memakai kapasitas jenis kontainer lain
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user memilih "Jenis Kontainer" dengan "40 DRY"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Berat Maksimal 1 Kontainer: 28.280 kg"
    And sistem tidak menampilkan "Kubikasi melebihi kapasitas armada"

  @negative @priority-medium @REQ-011 @screen-modal-pilih-barang
  Scenario: [OMS013-NEG-030] Pencarian barang tanpa hasil menampilkan empty state
    Given user berada di halaman "Modal Pilih Barang"
    When user mengisi field "Cari Barang" dengan "ZZZZ-TIDAK-ADA"
    Then sistem menampilkan "Tidak ada barang yang sesuai"

  @negative @priority-medium @REQ-012 @REQ-015 @screen-modal-pilih-barang
  Scenario: [OMS013-NEG-031] Simpan pada modal Pilih Barang tanpa memilih barang ditolak
    Given user berada di halaman "Modal Pilih Barang"
    When user mengklik tombol "Simpan"
    Then sistem menampilkan "Pilih minimal 1 barang"

  @negative @priority-medium @REQ-010 @screen-modal-pilih-barang
  Scenario: [OMS013-NEG-032] Barang nonaktif atau milik tenant lain tidak tampil pada modal
    Given user berada di halaman "Modal Pilih Barang"
    When user mengisi field "Cari Barang" dengan "SKU-NONAKTIF-001"
    Then sistem tidak menampilkan "SKU-NONAKTIF-001"
    And sistem menampilkan "Tidak ada barang yang sesuai"

  @negative @priority-high @REQ-026 @REQ-032 @screen-step3-vendor-harga
  Scenario: [OMS013-NEG-033] Vendor kosong memblokir navigasi ke Step 4
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    When user mengisi field "Harga" dengan "30.000.000"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Vendor harus diisi"
    And user tetap berada di halaman "Buat Order - Step 3 Vendor dan Harga"

  @negative @priority-high @REQ-026 @REQ-032 @screen-step3-vendor-harga
  Scenario: [OMS013-NEG-034] Tanggal Permintaan Muat kosong memblokir navigasi ke Step 4
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    When user memilih "Vendor" dengan "PT Logistik Transportasi Nusantara"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Tanggal Permintaan Muat harus diisi"

  @negative @priority-medium @REQ-026 @screen-step3-vendor-harga
  Scenario: [OMS013-NEG-035] Tanggal Permintaan Muat di masa lalu ditolak
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    When user mengisi field "Tanggal Permintaan Muat" dengan "01/01/2020 08:00"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Tanggal Permintaan Muat tidak boleh di masa lalu"

  @negative @priority-high @REQ-026 @REQ-032 @screen-step3-vendor-harga
  Scenario: [OMS013-NEG-036] Harga kosong memblokir navigasi ke Step 4
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    When user mengisi field "Harga" dengan ""
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Harga harus diisi"

  @negative @priority-medium @REQ-026 @screen-step3-vendor-harga
  Scenario: [OMS013-NEG-037] Harga bernilai negatif ditolak
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    When user mengisi field "Harga" dengan "-1000000"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Harga tidak boleh kurang dari 0"

  @negative @priority-medium @REQ-028 @screen-step3-vendor-harga
  Scenario: [OMS013-NEG-038] PPN kosong saat komponen harga aktif ditolak
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    When user mencentang checkbox "Gunakan komponen harga"
    And user mengisi field "PPN" dengan ""
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "PPN harus diisi"

  @negative @priority-high @REQ-029 @screen-step3-vendor-harga
  Scenario: [OMS013-NEG-039] Input Waktu Perjalanan tidak boleh muncul pada Step 3 FCL
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    Then sistem tidak menampilkan "Masukkan Waktu Perjalanan"
    And sistem tidak menampilkan "Waktu Perjalanan"

  @negative @priority-high @REQ-030 @screen-detail-order
  Scenario: [OMS013-NEG-040] Waktu Perjalanan tidak tampil sebelum status Ditugaskan
    Given user berada di halaman "Detail Order" dengan status "Menunggu Penugasan"
    Then sistem tidak menampilkan "Waktu Perjalanan"

  @negative @priority-high @REQ-031 @screen-step3-vendor-harga
  Scenario: [OMS013-NEG-041] Komponen Asuransi tidak dihitung saat tidak ada kontainer diasuransikan
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    And tidak ada kontainer yang diasuransikan
    When user mencentang checkbox "Gunakan komponen harga"
    Then sistem tidak menampilkan "Asuransi"
    And sistem menampilkan "Tanpa Asuransi"

  @negative @priority-high @REQ-033 @screen-step4-review
  Scenario: [OMS013-NEG-042] Field pada Step 4 Review tidak boleh dapat diedit
    Given user berada di halaman "Buat Order - Step 4 Review"
    When user mengisi field "Jumlah" dengan "999"
    Then sistem menampilkan "Seluruh field Review dalam kondisi read-only"

  @negative @priority-high @REQ-035 @screen-step4-review
  Scenario: [OMS013-NEG-043] Badge Diasuransikan tidak tampil pada kontainer tanpa asuransi
    Given user berada di halaman "Buat Order - Step 4 Review"
    And kontainer 1 tidak diasuransikan
    Then sistem tidak menampilkan "Badge Diasuransikan pada Kontainer 1"

  @negative @priority-high @REQ-036 @screen-step4-review
  Scenario: [OMS013-NEG-044] Pop up visualisasi tidak boleh gagal tampil saat button diklik
    Given user berada di halaman "Buat Order - Step 4 Review"
    When user mengklik tombol "Visualisasi Muatan"
    Then sistem tidak menampilkan "Gagal memuat visualisasi muatan"
    And sistem menampilkan "Visualisasi Muatan Saat Ini"

  @negative @priority-high @REQ-037 @screen-step4-review
  Scenario: [OMS013-NEG-045] Simpan Step 4 dengan data barang tidak lengkap ditolak
    Given user berada di halaman "Buat Order - Step 4 Review"
    And terdapat kontainer tanpa barang
    When user mengklik tombol "Simpan"
    Then sistem menampilkan "Lengkapi data barang pada seluruh kontainer"
    And user tetap berada di halaman "Buat Order - Step 4 Review"

  @negative @priority-medium @REQ-037 @screen-step4-review
  Scenario: [OMS013-NEG-046] Simpan Step 4 gagal saat server mengembalikan error
    Given user berada di halaman "Buat Order - Step 4 Review"
    And API simpan order mengembalikan HTTP 500
    When user mengklik tombol "Simpan"
    Then sistem menampilkan "Terjadi kesalahan, silakan coba lagi"
    And sistem tidak menampilkan "Menunggu Penugasan"

  @negative @priority-medium @REQ-038 @screen-daftar-order
  Scenario: [OMS013-NEG-047] Chip status di luar 9 status valid tidak boleh tampil
    Given user berada di halaman "Daftar Order"
    Then sistem tidak menampilkan "Status Tidak Diketahui"
    And sistem tidak menampilkan "Draft"

  @negative @priority-high @REQ-043 @REQ-052 @screen-daftar-order
  Scenario: [OMS013-NEG-048] Aksi Edit tidak tersedia pada order berstatus Ditugaskan
    Given user berada di halaman "Daftar Order"
    And terdapat order FCL berstatus "Ditugaskan"
    When user mengklik tombol "Aksi Baris Order"
    Then sistem tidak menampilkan "Edit"

  @negative @priority-high @REQ-043 @screen-detail-order
  Scenario: [OMS013-NEG-049] Button Edit Order tidak boleh tampil pada Detail Order berstatus Ditugaskan
    Given user berada di halaman "Detail Order" dengan status "Ditugaskan"
    Then sistem tidak menampilkan "Edit Order"

  @negative @priority-high @REQ-044 @screen-edit-order
  Scenario: [OMS013-NEG-050] Jenis Pengiriman tidak dapat diubah pada Edit Order
    Given user berada di halaman "Edit Order"
    When user memilih "Jenis Pengiriman" dengan "FTL"
    Then sistem menampilkan "FCL (Full Container Load)"

  @negative @priority-high @REQ-044 @screen-edit-order
  Scenario: [OMS013-NEG-051] Tipe Pengiriman tidak dapat diubah pada Edit Order
    Given user berada di halaman "Edit Order"
    When user memilih "Tipe Pengiriman" dengan "Multidrop"
    Then sistem menampilkan "Normal"

  @negative @priority-high @REQ-046 @screen-edit-order
  Scenario: [OMS013-NEG-052] Simpan pada Edit Order tidak boleh langsung dieksekusi tanpa konfirmasi
    Given user berada di halaman "Edit Order"
    When user mengklik tombol "Simpan"
    Then sistem tidak menampilkan "Perubahan order berhasil disimpan"
    And sistem menampilkan "Simpan perubahan order?"

  @negative @priority-medium @REQ-042 @screen-daftar-order
  Scenario: [OMS013-NEG-053] Edit order tidak tersedia pada status Proses Pengiriman
    Given user berada di halaman "Daftar Order"
    And terdapat order FCL berstatus "Proses Pengiriman"
    When user mengklik tombol "Aksi Baris Order"
    Then sistem tidak menampilkan "Edit"
    And sistem tidak menampilkan "Lanjutkan Pengisian"

  @negative @priority-high @REQ-049 @screen-daftar-order
  Scenario: [OMS013-NEG-054] Pembatalan order dengan Alasan Pembatalan kosong ditolak
    Given user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi Baris Order"
    And user mengklik tombol "Batalkan Order"
    And user mengisi field "Alasan Pembatalan" dengan ""
    And user mengklik tombol "Ya, Batalkan"
    Then sistem menampilkan "Alasan Pembatalan harus diisi"

  @negative @priority-medium @REQ-049 @screen-daftar-order
  Scenario: [OMS013-NEG-055] Alasan Pembatalan berisi hanya spasi ditolak
    Given user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi Baris Order"
    And user mengklik tombol "Batalkan Order"
    And user mengisi field "Alasan Pembatalan" dengan "     "
    And user mengklik tombol "Ya, Batalkan"
    Then sistem menampilkan "Alasan Pembatalan harus diisi"

  @negative @priority-high @REQ-047 @screen-daftar-order
  Scenario: [OMS013-NEG-056] Aksi Batalkan Order tidak tersedia pada status Proses Pengiriman
    Given user berada di halaman "Daftar Order"
    And terdapat order FCL berstatus "Proses Pengiriman"
    When user mengklik tombol "Aksi Baris Order"
    Then sistem tidak menampilkan "Batalkan Order"

  @negative @priority-high @REQ-047 @screen-daftar-order
  Scenario: [OMS013-NEG-057] Aksi Batalkan Order tidak tersedia pada status Terkirim
    Given user berada di halaman "Daftar Order"
    And terdapat order FCL berstatus "Terkirim"
    When user mengklik tombol "Aksi Baris Order"
    Then sistem tidak menampilkan "Batalkan Order"

  @negative @priority-high @REQ-048 @screen-daftar-order
  Scenario: [OMS013-NEG-058] Vendor tidak memiliki aksi Batalkan Order
    Given user login sebagai "Vendor"
    And user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi Baris Order"
    Then sistem tidak menampilkan "Batalkan Order"

  @negative @priority-high @REQ-048 @screen-daftar-order
  Scenario: [OMS013-NEG-059] Vendor tidak dapat membuat order FCL
    Given user login sebagai "Vendor"
    And user berada di halaman "Daftar Order"
    Then sistem tidak menampilkan "Buat Order"

  @negative @priority-high @REQ-057 @screen-daftar-order
  Scenario: [OMS013-NEG-060] Aksi Lihat No. Perjalanan tidak tampil sebelum status Ditugaskan
    Given user berada di halaman "Daftar Order"
    And terdapat order FCL berstatus "Menunggu Penugasan"
    When user mengklik tombol "Aksi Baris Order"
    Then sistem tidak menampilkan "Lihat No. Perjalanan"

  @negative @priority-high @REQ-055 @screen-modal-no-perjalanan
  Scenario: [OMS013-NEG-061] No. Perjalanan antar kontainer tidak boleh duplikat
    Given user berada di halaman "Modal Data No. Perjalanan"
    And order memiliki 2 kontainer
    Then sistem menampilkan "Seluruh No. Perjalanan unik"
    And sistem tidak menampilkan "TRC79289802 pada dua baris berbeda"

  @negative @priority-high @REQ-055 @screen-modal-no-perjalanan
  Scenario: [OMS013-NEG-062] Jumlah No. Perjalanan tidak boleh berbeda dari jumlah kontainer
    Given user berada di halaman "Daftar Order"
    And terdapat order FCL berstatus "Ditugaskan" dengan 3 kontainer
    When user mengklik tombol "Aksi Baris Order"
    And user mengklik tombol "Lihat No. Perjalanan"
    Then sistem menampilkan "3 baris No. Perjalanan"

  @negative @priority-medium @REQ-056 @screen-daftar-order
  Scenario: [OMS013-NEG-063] No. Perjalanan tidak tersedia untuk jenis order LTL
    Given user berada di halaman "Daftar Order"
    And terdapat order berstatus "Ditugaskan" dengan jenis order "LTL"
    When user mengklik tombol "Aksi Baris Order"
    Then sistem tidak menampilkan "Lihat No. Perjalanan"

  @negative @priority-medium @REQ-054 @screen-public-tracking
  Scenario: [OMS013-NEG-064] Public tracking menolak No. Perjalanan tidak valid
    Given user berada di halaman "Public Tracking"
    When user mengisi field "No. Perjalanan" dengan "XXX00000000"
    And user mengklik tombol "Lacak"
    Then sistem menampilkan "No. Perjalanan tidak ditemukan"

  @negative @priority-medium @REQ-052 @screen-daftar-order
  Scenario: [OMS013-NEG-065] Action menu tidak boleh memuat aksi di luar daftar spesifikasi
    Given user berada di halaman "Daftar Order"
    And terdapat order FCL berstatus "Ditugaskan"
    When user mengklik tombol "Aksi Baris Order"
    Then sistem tidak menampilkan "Order Kembali"

  @negative @priority-medium @REQ-038 @screen-daftar-order
  Scenario: [OMS013-NEG-066] Label status harus memakai istilah spesifikasi Isi Data Pengiriman dan Selesai
    Given user berada di halaman "Daftar Order"
    Then sistem menampilkan "Isi Data Pengiriman"
    And sistem menampilkan "Selesai"
    And sistem tidak menampilkan "Isi Data Dasar"
    And sistem tidak menampilkan "Terkirim"

  @negative @priority-high @REQ-005 @screen-step2-data-barang
  Scenario: [OMS013-NEG-067] Jumlah card kontainer tidak boleh berbeda dari Jumlah Kontainer
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user mengisi field "Jumlah Kontainer" dengan "2"
    And user mengklik tombol "Selanjutnya"
    Then sistem tidak menampilkan "Kontainer 3"

  @negative @priority-medium @REQ-002 @screen-step3-vendor-harga
  Scenario: [OMS013-NEG-068] Step 3 order FCL tidak boleh memakai label Jenis Armada
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    Then sistem menampilkan "Jenis Kontainer"
    And sistem tidak menampilkan "Jenis Armada"

  @negative @priority-medium @REQ-041 @screen-step2-data-barang
  Scenario: [OMS013-NEG-069] Simpan ke Draf gagal saat server error dan data tetap dipertahankan
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And API simpan draf mengembalikan HTTP 500
    When user mengklik tombol "Simpan ke Draf"
    Then sistem menampilkan "Gagal menyimpan draf, silakan coba lagi"
    And sistem menampilkan "SKU-PPR-001"

  @negative @priority-medium @REQ-037 @screen-step4-review
  Scenario: [OMS013-NEG-070] Submit order dengan sesi kedaluwarsa diarahkan ke halaman login
    Given user berada di halaman "Buat Order - Step 4 Review"
    And sesi user telah kedaluwarsa
    When user mengklik tombol "Simpan"
    Then sistem menampilkan "Sesi Anda telah berakhir, silakan login kembali"
    And user diarahkan ke halaman "Login"

  # ==========================================================================
  # KATEGORI: EDGE
  # ==========================================================================

  @edge @priority-high @REQ-005 @screen-step1-data-pengiriman
  Scenario: [OMS013-EDG-001] Jumlah Kontainer bernilai minimum 1
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user mengisi field "Jumlah Kontainer" dengan "1"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 2 Data Barang"
    And sistem menampilkan "Kontainer 1"
    And sistem tidak menampilkan "Kontainer 2"

  @edge @priority-medium @REQ-005 @screen-step1-data-pengiriman
  Scenario: [OMS013-EDG-002] Jumlah Kontainer bernilai besar 99 menghasilkan 99 card
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user mengisi field "Jumlah Kontainer" dengan "99"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Kontainer 99"

  @edge @priority-medium @REQ-005 @screen-step1-data-pengiriman
  Scenario: [OMS013-EDG-003] Jumlah Kontainer melebihi sisa Kuota Order tenant ditolak
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    And widget Kuota Order menunjukkan "120/300"
    When user mengisi field "Jumlah Kontainer" dengan "500"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Jumlah melebihi kuota order yang tersedia"

  @edge @priority-medium @REQ-017 @screen-step2-data-barang
  Scenario: [OMS013-EDG-004] Field Jumlah bernilai minimum 1 diterima
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    When user mengisi field "Jumlah" dengan "1"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 3 Vendor dan Harga"

  @edge @priority-medium @REQ-017 @screen-step2-data-barang
  Scenario: [OMS013-EDG-005] Field Jumlah menolak input desimal
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    When user mengisi field "Jumlah" dengan "10,5"
    Then sistem menampilkan "Jumlah harus berupa bilangan bulat"

  @edge @priority-medium @REQ-018 @screen-step2-data-barang
  Scenario: [OMS013-EDG-006] Nilai Barang bernilai minimum 1 diterima
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And checkbox "Tambahkan Asuransi" pada kontainer 1 dalam kondisi tercentang
    When user mengisi field "Jumlah" dengan "10"
    And user mengisi field "Nilai Barang" dengan "1"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 3 Vendor dan Harga"

  @edge @priority-medium @REQ-018 @REQ-031 @screen-step2-data-barang
  Scenario: [OMS013-EDG-007] Nilai Barang sangat besar diformat locale id-ID tanpa overflow
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And checkbox "Tambahkan Asuransi" pada kontainer 1 dalam kondisi tercentang
    When user mengisi field "Nilai Barang" dengan "999999999999"
    Then sistem menampilkan "999.999.999.999"

  @edge @priority-low @REQ-020 @screen-step2-data-barang
  Scenario: [OMS013-EDG-008] Nomor DO tunggal tanpa koma menghasilkan satu chip
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    When user mengisi field "Nomor DO" dengan "TGK783898202U"
    Then sistem menampilkan "TGK783898202U"

  @edge @priority-medium @REQ-020 @screen-step2-data-barang
  Scenario: [OMS013-EDG-009] Nomor DO dengan koma di akhir tidak membuat chip kosong
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    When user mengisi field "Nomor DO" dengan "TGK783898202U,"
    Then sistem menampilkan "TGK783898202U"
    And sistem tidak menampilkan "Chip Nomor DO kosong"

  @edge @priority-medium @REQ-020 @screen-step2-data-barang
  Scenario: [OMS013-EDG-010] Nomor DO dengan spasi setelah koma dipangkas otomatis
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    When user mengisi field "Nomor DO" dengan "TGK783898202U ,  TBL28371302 "
    Then sistem menampilkan "TGK783898202U"
    And sistem menampilkan "TBL28371302"

  @edge @priority-medium @REQ-020 @screen-step2-data-barang
  Scenario: [OMS013-EDG-011] Nomor DO duplikat tidak menghasilkan chip ganda
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    When user mengisi field "Nomor DO" dengan "TBL28371302,TBL28371302"
    Then sistem menampilkan "1 chip Nomor DO"

  @edge @priority-low @REQ-020 @screen-step2-data-barang
  Scenario: [OMS013-EDG-012] Nomor DO dengan karakter spesial tetap dirender sebagai chip
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    When user mengisi field "Nomor DO" dengan "DO-#2026/07*01"
    Then sistem menampilkan "DO-#2026/07*01"

  @edge @priority-high @REQ-020 @screen-step2-data-barang
  Scenario: [OMS013-EDG-013] Nomor DO kosong tetap mengizinkan navigasi ke Step 3
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    When user mengisi field "Nomor DO" dengan ""
    And user mengisi field "Jumlah" dengan "100"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 3 Vendor dan Harga"

  @edge @priority-high @REQ-018 @REQ-019 @screen-step2-data-barang
  Scenario: [OMS013-EDG-014] Melepas checkbox asuransi menyembunyikan kolom Nilai Barang dan validasinya
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And checkbox "Tambahkan Asuransi" pada kontainer 1 dalam kondisi tercentang
    And field "Nilai Barang" pada kontainer 1 menampilkan error "Nilai Barang harus diisi"
    When user melepas centang checkbox "Tambahkan Asuransi"
    Then sistem tidak menampilkan "Nilai Barang harus diisi"
    And sistem tidak menampilkan "Nilai Barang"

  @edge @priority-high @REQ-019 @screen-step2-data-barang
  Scenario: [OMS013-EDG-015] Mencentang asuransi setelah barang terisi mewajibkan Nilai Barang seluruh baris
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And kontainer 1 sudah berisi 3 barang dengan Jumlah terisi
    When user mencentang checkbox "Tambahkan Asuransi"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Nilai Barang harus diisi"

  @edge @priority-medium @REQ-021 @screen-step2-data-barang
  Scenario: [OMS013-EDG-016] Menghapus baris barang terakhir mengembalikan empty state
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And kontainer 1 sudah berisi barang "SKU-PPR-001"
    When user mengklik tombol "Hapus Barang SKU-PPR-001"
    Then sistem menampilkan "Belum ada barang. Klik \"Pilih Barang \""

  @edge @priority-medium @REQ-021 @REQ-018 @screen-step2-data-barang
  Scenario: [OMS013-EDG-017] Menghapus seluruh barang saat asuransi aktif menghilangkan validasi Nilai Barang
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And checkbox "Tambahkan Asuransi" pada kontainer 1 dalam kondisi tercentang
    And kontainer 1 sudah berisi barang "SKU-PPR-001"
    When user mengklik tombol "Hapus Barang SKU-PPR-001"
    And user mengklik tombol "Selanjutnya"
    Then sistem tidak menampilkan "Nilai Barang harus diisi"

  @edge @priority-high @REQ-022 @REQ-023 @screen-step2-data-barang
  Scenario: [OMS013-EDG-018] Kubikasi tepat sama dengan kapasitas tidak memunculkan alert
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And total kubikasi kontainer 1 tepat sama dengan kapasitas maksimal
    Then sistem tidak menampilkan "Kubikasi melebihi kapasitas armada"

  @edge @priority-high @REQ-023 @screen-step2-data-barang
  Scenario: [OMS013-EDG-019] Kubikasi melebihi kapasitas sebesar 0,01 m3 memunculkan alert
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And total kubikasi kontainer 1 melebihi kapasitas maksimal sebesar "0,01"
    Then sistem menampilkan "Kubikasi melebihi kapasitas armada"

  @edge @priority-high @REQ-023 @screen-step2-data-barang
  Scenario: [OMS013-EDG-020] Berat tepat sama dengan kapasitas tidak memunculkan alert
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And total berat kontainer 1 tepat sama dengan kapasitas maksimal
    Then sistem tidak menampilkan "Berat melebihi kapasitas armada"

  @edge @priority-high @REQ-023 @screen-step2-data-barang
  Scenario: [OMS013-EDG-021] Kubikasi dan Berat sama-sama berlebih menampilkan satu alert gabungan
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And total kubikasi dan total berat kontainer 1 melebihi kapasitas maksimal
    Then sistem menampilkan "Kubikasi dan Berat melebihi kapasitas kontainer"

  @edge @priority-high @REQ-022 @screen-step2-data-barang
  Scenario: [OMS013-EDG-022] Mengubah Jenis Kontainer di Step 1 mengevaluasi ulang alert kapasitas Step 2
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And total kubikasi kontainer 1 melebihi kapasitas "20 DRY"
    When user mengklik tombol "Sebelumnya"
    And user memilih "Jenis Kontainer" dengan "40 DRY"
    And user mengklik tombol "Selanjutnya"
    Then sistem tidak menampilkan "Kubikasi melebihi kapasitas armada"

  @edge @priority-low @REQ-011 @screen-modal-pilih-barang
  Scenario: [OMS013-EDG-023] Pencarian barang dengan karakter spesial tidak menyebabkan error
    Given user berada di halaman "Modal Pilih Barang"
    When user mengisi field "Cari Barang" dengan "%%__''<script>"
    Then sistem menampilkan "Tidak ada barang yang sesuai"

  @edge @priority-medium @REQ-011 @screen-modal-pilih-barang
  Scenario: [OMS013-EDG-024] Pencarian barang bersifat case-insensitive
    Given user berada di halaman "Modal Pilih Barang"
    When user mengisi field "Cari Barang" dengan "kertas hvs"
    Then sistem menampilkan "Kertas HVS A4 80 gsm"

  @edge @priority-low @REQ-011 @screen-modal-pilih-barang
  Scenario: [OMS013-EDG-025] Pencarian dengan spasi di awal dan akhir tetap menemukan hasil
    Given user berada di halaman "Modal Pilih Barang"
    When user mengisi field "Cari Barang" dengan "  SKU-PPR-001  "
    Then sistem menampilkan "SKU-PPR-001"

  @edge @priority-medium @REQ-013 @screen-modal-pilih-barang
  Scenario: [OMS013-EDG-026] Barang berlabel Sudah Ditambahkan tetap dapat dipilih ulang
    Given user berada di halaman "Modal Pilih Barang"
    And barang "SKU-PPR-001" menampilkan label "Sudah Ditambahkan"
    When user mencentang checkbox "SKU-PPR-001"
    And user mengklik tombol "Simpan"
    Then sistem menampilkan "SKU-PPR-001"
    And sistem tidak menampilkan "Barang duplikat"

  @edge @priority-medium @REQ-014 @screen-modal-pilih-barang
  Scenario: [OMS013-EDG-027] Counter kembali ke nol setelah seluruh checkbox dilepas
    Given user berada di halaman "Modal Pilih Barang"
    When user mencentang checkbox "SKU-PPR-001"
    And user melepas centang checkbox "SKU-PPR-001"
    Then sistem menampilkan "0 barang dipilih"

  @edge @priority-medium @REQ-015 @screen-modal-pilih-barang
  Scenario: [OMS013-EDG-028] Menutup modal via icon silang berperilaku sama dengan Batal
    Given user berada di halaman "Modal Pilih Barang"
    When user mencentang checkbox "SKU-PPR-001"
    And user mengklik tombol "Tutup"
    Then user diarahkan ke halaman "Buat Order - Step 2 Data Barang"
    And sistem menampilkan "Belum ada barang. Klik \"Pilih Barang \""

  @edge @priority-medium @REQ-007 @screen-step1-data-pengiriman
  Scenario: [OMS013-EDG-029] Multipickup dengan 5 titik pickup tetap dapat dilanjutkan
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user memilih "Tipe Pengiriman" dengan "Multipickup"
    And user menambah baris Pick Up hingga berjumlah 5
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 2 Data Barang"
    And sistem menampilkan "Pick Up 5"

  @edge @priority-high @REQ-001 @screen-step2-data-barang
  Scenario: [OMS013-EDG-030] Multipoint 3 Pick Up dan 3 Drop Off menghasilkan 9 sub-card per kontainer
    Given user berada di halaman "Buat Order - Step 2 Data Barang" dengan tipe pengiriman "Multipoint"
    And order memiliki 3 titik Pick Up dan 3 titik Drop Off
    Then sistem menampilkan "9 sub-card muatan pada Kontainer 1"

  @edge @priority-medium @REQ-007 @screen-step1-data-pengiriman
  Scenario: [OMS013-EDG-031] Menghapus baris Pick Up saat jumlah baris sudah minimum ditolak
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user memilih "Tipe Pengiriman" dengan "Multipickup"
    And user mengklik tombol "Hapus Baris Pick Up 2"
    Then sistem menampilkan "Minimal 2 titik Pick Up untuk tipe Multipickup"

  @edge @priority-medium @REQ-026 @screen-step3-vendor-harga
  Scenario: [OMS013-EDG-032] Tanggal Permintaan Muat tepat hari ini diterima
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    When user mengisi field "Tanggal Permintaan Muat" dengan tanggal hari ini pukul "23:59"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 4 Review"

  @edge @priority-medium @REQ-026 @screen-step3-vendor-harga
  Scenario: [OMS013-EDG-033] Tanggal Permintaan Muat satu menit sebelum waktu sekarang ditolak
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    When user mengisi field "Tanggal Permintaan Muat" dengan waktu satu menit yang lalu
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Tanggal Permintaan Muat tidak boleh di masa lalu"

  @edge @priority-medium @REQ-028 @screen-step3-vendor-harga
  Scenario: [OMS013-EDG-034] Harga bernilai nol dengan komponen harga aktif menghasilkan Total Harga nol
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    When user mengisi field "Harga" dengan "0"
    And user mencentang checkbox "Gunakan komponen harga"
    Then sistem menampilkan "Total Harga Rp. 0"

  @edge @priority-low @REQ-028 @screen-step3-vendor-harga
  Scenario: [OMS013-EDG-035] PPN dan PPh bernilai nol persen tidak mengubah Total Harga
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    When user mencentang checkbox "Gunakan komponen harga"
    And user mengisi field "PPN" dengan "0"
    And user mengisi field "PPh" dengan "0"
    And user mengisi field "Harga" dengan "30.000.000"
    Then sistem menampilkan "Total Harga Rp. 30.000.000"

  @edge @priority-medium @REQ-028 @screen-step3-vendor-harga
  Scenario: [OMS013-EDG-036] PPN desimal format id-ID dihitung dengan benar
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    When user mencentang checkbox "Gunakan komponen harga"
    And user mengisi field "PPN" dengan "1,1"
    And user mengisi field "Harga" dengan "30.000.000"
    Then sistem menampilkan "PPN (1,1%)"
    And sistem menampilkan "Rp. 330.000"

  @edge @priority-medium @REQ-031 @screen-step3-vendor-harga
  Scenario: [OMS013-EDG-037] Persentase Asuransi nol menghasilkan nilai Asuransi nol
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    And terdapat kontainer yang diasuransikan dengan Total Nilai Barang "1.000.000.000"
    When user mencentang checkbox "Gunakan komponen harga"
    And user mengisi field "Asuransi" dengan "0"
    Then sistem menampilkan "Asuransi (0%)"
    And sistem menampilkan "Rp0"

  @edge @priority-medium @REQ-025 @REQ-032 @screen-step4-review
  Scenario: [OMS013-EDG-038] Navigasi mundur berantai dari Step 4 hingga Step 1 mempertahankan seluruh data
    Given user berada di halaman "Buat Order - Step 4 Review"
    When user mengklik tombol "Sebelumnya"
    And user mengklik tombol "Sebelumnya"
    And user mengklik tombol "Sebelumnya"
    Then user diarahkan ke halaman "Buat Order - Step 1 Data Pengiriman"
    And sistem menampilkan "Tanjung Perak (SUB)"

  @edge @priority-medium @REQ-041 @screen-step2-data-barang
  Scenario: [OMS013-EDG-039] Refresh browser di tengah Step 2 memuat kembali data draf terakhir
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And draf order sudah tersimpan
    When user memuat ulang halaman
    Then sistem menampilkan "SKU-PPR-001"
    And sistem menampilkan "Kontainer 1"

  @edge @priority-medium @REQ-041 @REQ-050 @screen-daftar-order
  Scenario: [OMS013-EDG-040] Draf Step 1 dilanjutkan dari Daftar Order membuka Step 1
    Given user berada di halaman "Daftar Order"
    And terdapat order FCL berstatus "Isi Data Dasar"
    When user mengklik tombol "Aksi Baris Order"
    And user mengklik tombol "Lanjutkan Pengisian"
    Then user diarahkan ke halaman "Buat Order - Step 1 Data Pengiriman"

  @edge @priority-medium @REQ-047 @screen-detail-order
  Scenario: [OMS013-EDG-041] Order dibatalkan di sesi lain saat halaman detail terbuka
    Given user berada di halaman "Detail Order" dengan status "Menunggu Penugasan"
    And order dibatalkan oleh sesi lain
    When user mengklik tombol "Batalkan Order"
    Then sistem menampilkan "Order sudah dibatalkan"

  @edge @priority-high @REQ-042 @REQ-043 @screen-edit-order
  Scenario: [OMS013-EDG-042] Menyimpan Edit Order setelah vendor melakukan penugasan ditolak
    Given user berada di halaman "Edit Order"
    And vendor melakukan penugasan sehingga status menjadi "Ditugaskan"
    When user mengklik tombol "Simpan"
    And user mengklik tombol "Ya, Simpan"
    Then sistem menampilkan "Order tidak dapat diubah karena sudah Ditugaskan"

  @edge @priority-high @REQ-045 @screen-edit-order
  Scenario: [OMS013-EDG-043] Mengurangi Jumlah Kontainer saat Edit Order menghapus card kontainer terakhir
    Given user berada di halaman "Edit Order"
    And order memiliki 3 kontainer
    When user mengisi field "Jumlah Kontainer" dengan "2"
    Then sistem menampilkan "Data barang pada Kontainer 3 akan dihapus"
    And sistem tidak menampilkan "Data Barang - Kontainer 3"

  @edge @priority-medium @REQ-045 @screen-edit-order
  Scenario: [OMS013-EDG-044] Menambah Jumlah Kontainer saat Edit Order menghasilkan card kosong
    Given user berada di halaman "Edit Order"
    And order memiliki 2 kontainer
    When user mengisi field "Jumlah Kontainer" dengan "3"
    Then sistem menampilkan "Data Barang - Kontainer 3"
    And sistem menampilkan "Belum ada barang. Klik \"Pilih Barang \""

  @edge @priority-medium @REQ-049 @screen-daftar-order
  Scenario: [OMS013-EDG-045] Alasan Pembatalan sepanjang batas maksimum 500 karakter diterima
    Given user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi Baris Order"
    And user mengklik tombol "Batalkan Order"
    And user mengisi field "Alasan Pembatalan" dengan teks sepanjang 500 karakter
    And user mengklik tombol "Ya, Batalkan"
    Then sistem menampilkan "Order berhasil dibatalkan"

  @edge @priority-low @REQ-049 @screen-daftar-order
  Scenario: [OMS013-EDG-046] Alasan Pembatalan satu karakter diterima
    Given user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi Baris Order"
    And user mengklik tombol "Batalkan Order"
    And user mengisi field "Alasan Pembatalan" dengan "X"
    And user mengklik tombol "Ya, Batalkan"
    Then sistem menampilkan "Order berhasil dibatalkan"

  @edge @priority-low @REQ-059 @screen-modal-no-perjalanan
  Scenario: [OMS013-EDG-047] Copy No. Perjalanan saat izin clipboard ditolak menampilkan fallback
    Given user berada di halaman "Modal Data No. Perjalanan"
    And izin clipboard browser ditolak
    When user mengklik tombol "Salin No. Perjalanan"
    Then sistem menampilkan "Gagal menyalin, salin manual nomor berikut"

  @edge @priority-medium @REQ-036 @screen-modal-visualisasi-muatan
  Scenario: [OMS013-EDG-048] Visualisasi 3D menampilkan fallback saat WebGL tidak didukung
    Given user berada di halaman "Buat Order - Step 4 Review"
    And browser tidak mendukung WebGL
    When user mengklik tombol "Visualisasi Muatan"
    Then sistem menampilkan "Visualisasi 3D tidak didukung pada browser ini"

  @edge @priority-medium @REQ-022 @screen-modal-visualisasi-muatan
  Scenario: [OMS013-EDG-049] Badge koli melebihi kapasitas tampil pada canvas visualisasi
    Given user berada di halaman "Modal Visualisasi Muatan Saat Ini"
    And terdapat koli yang melebihi kapasitas kontainer
    Then sistem menampilkan "110 koli melebihi kapasitas (outline merah)"

  @edge @priority-low @REQ-050 @screen-daftar-order
  Scenario: [OMS013-EDG-050] Filter Tipe Pengiriman dan Metode Pengiriman dalam kondisi disabled
    Given user berada di halaman "Daftar Order"
    When user mengklik tombol "Filter"
    Then sistem menampilkan "Tipe Pengiriman dalam kondisi disabled"
    And sistem menampilkan "Metode Pengiriman dalam kondisi disabled"

  @edge @priority-low @REQ-050 @screen-daftar-order
  Scenario: [OMS013-EDG-051] Kombinasi filter tanpa hasil menampilkan empty state tabel
    Given user berada di halaman "Daftar Order"
    When user mengklik tombol "Filter"
    And user mengisi field "ID Order" dengan "ORD-TIDAK-ADA"
    And user memilih "Status" dengan "Dibatalkan"
    And user mengklik tombol "Terapkan"
    Then sistem menampilkan "Data tidak ditemukan"

  @edge @priority-low @REQ-050 @screen-daftar-order
  Scenario: [OMS013-EDG-052] Mengubah page size saat berada di halaman terakhir mereset ke halaman 1
    Given user berada di halaman "Daftar Order"
    When user mengklik tombol "12"
    And user memilih "Tampilkan" dengan "100"
    Then sistem menampilkan "Menampilkan 1 - 100 data dari 30 data"

  @edge @priority-low @REQ-016 @screen-step2-data-barang
  Scenario: [OMS013-EDG-053] Nama barang sangat panjang ditampilkan tanpa merusak layout tabel
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And kontainer 1 berisi barang dengan nama sepanjang 255 karakter
    Then sistem menampilkan "Nama barang dalam kondisi truncate dengan tooltip"

  @edge @priority-low @REQ-006 @screen-step1-data-pengiriman
  Scenario: [OMS013-EDG-054] Catatan alamat menerima karakter unicode dan emoji
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user mengisi field "Catatan" dengan "Muat pagi 🚛 — gerbang B№2 (東門)"
    And user mengklik tombol "Selanjutnya"
    Then user diarahkan ke halaman "Buat Order - Step 2 Data Barang"

  @edge @priority-medium @REQ-034 @screen-step4-review
  Scenario: [OMS013-EDG-055] Review menampilkan tanda strip saat Nomor DO tidak diisi
    Given user berada di halaman "Buat Order - Step 4 Review"
    And kontainer 1 tidak memiliki Nomor DO
    Then sistem menampilkan "Nomor DO"
    And sistem menampilkan "-"

  # ==========================================================================
  # KATEGORI: STRESS
  # ==========================================================================

  @stress @priority-medium @REQ-005 @screen-step2-data-barang
  Scenario: [OMS013-STR-001] Order dengan 100 kontainer merender seluruh card Step 2
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user mengisi field "Jumlah Kontainer" dengan "100"
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Kontainer 100"
    And sistem merender halaman dalam waktu kurang dari 10 detik

  @stress @priority-medium @REQ-010 @screen-step2-data-barang
  Scenario: [OMS013-STR-002] Satu kontainer menampung 500 baris barang
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    When user menambahkan 500 barang ke kontainer 1
    Then sistem menampilkan "500 baris barang pada Kontainer 1"
    And sistem menampilkan "Total Kubikasi:"

  @stress @priority-medium @REQ-011 @screen-modal-pilih-barang
  Scenario: [OMS013-STR-003] Modal Pilih Barang dengan 10.000 master barang tetap responsif
    Given user berada di halaman "Modal Pilih Barang"
    And master barang berisi 10000 data aktif
    When user mengisi field "Cari Barang" dengan "Kertas"
    Then sistem menampilkan hasil pencarian dalam waktu kurang dari 5 detik

  @stress @priority-medium @REQ-012 @REQ-014 @screen-modal-pilih-barang
  Scenario: [OMS013-STR-004] Memilih 200 barang sekaligus dalam satu kali buka modal
    Given user berada di halaman "Modal Pilih Barang"
    When user mencentang 200 checkbox barang
    Then sistem menampilkan "200 barang dipilih"
    When user mengklik tombol "Simpan"
    Then sistem menampilkan "200 baris barang pada Kontainer 1"

  @stress @priority-medium @REQ-001 @screen-step2-data-barang
  Scenario: [OMS013-STR-005] Multipoint 5 Pick Up x 5 Drop Off pada 10 kontainer merender 250 sub-card
    Given user berada di halaman "Buat Order - Step 2 Data Barang" dengan tipe pengiriman "Multipoint"
    And order memiliki 5 titik Pick Up, 5 titik Drop Off, dan 10 kontainer
    Then sistem menampilkan "250 sub-card muatan"

  @stress @priority-medium @REQ-020 @screen-step2-data-barang
  Scenario: [OMS013-STR-006] Input 100 Nomor DO dipisahkan koma dirender sebagai 100 chip
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    When user mengisi field "Nomor DO" dengan 100 nomor dipisahkan koma
    Then sistem menampilkan "100 chip Nomor DO"

  @stress @priority-low @REQ-049 @screen-daftar-order
  Scenario: [OMS013-STR-007] Alasan Pembatalan sepanjang 10.000 karakter ditolak dengan pesan batas
    Given user berada di halaman "Daftar Order"
    When user mengklik tombol "Aksi Baris Order"
    And user mengklik tombol "Batalkan Order"
    And user mengisi field "Alasan Pembatalan" dengan teks sepanjang 10000 karakter
    And user mengklik tombol "Ya, Batalkan"
    Then sistem menampilkan "Alasan Pembatalan maksimal 500 karakter"

  @stress @priority-low @REQ-006 @screen-step1-data-pengiriman
  Scenario: [OMS013-STR-008] Catatan alamat sepanjang 5.000 karakter ditolak dengan pesan batas
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user mengisi field "Catatan" dengan teks sepanjang 5000 karakter
    And user mengklik tombol "Selanjutnya"
    Then sistem menampilkan "Catatan maksimal 500 karakter"

  @stress @priority-low @REQ-011 @screen-modal-pilih-barang
  Scenario: [OMS013-STR-009] Kata kunci pencarian 1.000 karakter tidak menyebabkan crash
    Given user berada di halaman "Modal Pilih Barang"
    When user mengisi field "Cari Barang" dengan teks sepanjang 1000 karakter
    Then sistem menampilkan "Tidak ada barang yang sesuai"

  @stress @priority-medium @REQ-050 @screen-daftar-order
  Scenario: [OMS013-STR-010] Daftar Order dengan 10.000 data pada page size maksimum tetap dimuat
    Given user berada di halaman "Daftar Order"
    And daftar order berisi 10000 data
    When user memilih "Tampilkan" dengan "100"
    Then sistem menampilkan "Menampilkan 1 - 100 data dari 10.000 data"
    And sistem merender halaman dalam waktu kurang dari 10 detik

  @stress @priority-high @REQ-008 @screen-step1-data-pengiriman
  Scenario: [OMS013-STR-011] Klik Selanjutnya berulang cepat tidak menghasilkan navigasi ganda
    Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
    When user mengisi seluruh field wajib Step 1 dengan data valid
    And user mengklik tombol "Selanjutnya" sebanyak 20 kali secara cepat
    Then user diarahkan ke halaman "Buat Order - Step 2 Data Barang"
    And sistem menampilkan "Kontainer 1"

  @stress @priority-high @REQ-037 @screen-step4-review
  Scenario: [OMS013-STR-012] Klik Simpan berulang pada Step 4 hanya membuat satu order
    Given user berada di halaman "Buat Order - Step 4 Review"
    When user mengklik tombol "Simpan" sebanyak 10 kali secara cepat
    Then sistem menampilkan "Order berhasil disimpan"
    And sistem menampilkan "1 order baru pada Daftar Order"

  @stress @priority-medium @REQ-037 @screen-step4-review
  Scenario: [OMS013-STR-013] Sepuluh sesi paralel membuat order FCL secara bersamaan
    Given terdapat 10 sesi shipper aktif secara paralel
    And setiap sesi berada di halaman "Buat Order - Step 4 Review"
    When seluruh sesi mengklik tombol "Simpan" secara bersamaan
    Then sistem menampilkan "10 order berstatus Menunggu Penugasan"

  @stress @priority-medium @REQ-042 @screen-edit-order
  Scenario: [OMS013-STR-014] Lima tab paralel mengedit order yang sama menerapkan penguncian optimistik
    Given terdapat 5 tab yang membuka halaman "Edit Order" untuk order "ORD67890792"
    When seluruh tab mengklik tombol "Simpan" secara bersamaan
    Then sistem menampilkan "Data order telah diperbarui pengguna lain, muat ulang halaman"

  @stress @priority-medium @REQ-037 @screen-step4-review
  Scenario: [OMS013-STR-015] Timeout API saat Simpan Step 4 menampilkan pesan error dan data tetap
    Given user berada di halaman "Buat Order - Step 4 Review"
    And API simpan order mengalami timeout 30 detik
    When user mengklik tombol "Simpan"
    Then sistem menampilkan "Permintaan melebihi batas waktu, silakan coba lagi"
    And sistem menampilkan "Jenis Pengiriman : FCL (Full Container Load)"

  @stress @priority-medium @REQ-010 @screen-modal-pilih-barang
  Scenario: [OMS013-STR-016] Timeout saat memuat modal Pilih Barang menampilkan retry
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    And API master barang mengalami timeout
    When user mengklik tombol "Pilih Barang"
    Then sistem menampilkan "Gagal memuat data barang"
    And sistem menampilkan "Coba Lagi"

  @stress @priority-low @REQ-036 @screen-modal-visualisasi-muatan
  Scenario: [OMS013-STR-017] Render visualisasi muatan pada koneksi lambat tetap menampilkan indikator loading
    Given user berada di halaman "Buat Order - Step 4 Review"
    And koneksi jaringan dibatasi pada profil "Slow 3G"
    When user mengklik tombol "Visualisasi Muatan"
    Then sistem menampilkan "Memuat visualisasi muatan"
    And sistem menampilkan "Visualisasi Muatan Saat Ini"

  @stress @priority-low @REQ-036 @screen-modal-visualisasi-muatan
  Scenario: [OMS013-STR-018] Canvas 3D dengan 20.000 koli tetap dapat dirender
    Given user berada di halaman "Modal Visualisasi Muatan Saat Ini"
    And muatan berisi 20000 koli
    Then sistem menampilkan "Berat Terpakai"
    And sistem merender canvas dalam waktu kurang dari 15 detik

  @stress @priority-low @REQ-005 @screen-modal-hitung-ulang
  Scenario: [OMS013-STR-019] Menekan Terapkan ke Order berulang tidak menggandakan kontainer
    Given user berada di halaman "Modal Hitung Ulang Kontainer"
    When user mengklik tombol "Terapkan ke Order" sebanyak 5 kali secara cepat
    Then user diarahkan ke halaman "Buat Order - Step 2 Data Barang"
    And sistem menampilkan "Jumlah Kontainer: 2"

  @stress @priority-low @REQ-041 @screen-step2-data-barang
  Scenario: [OMS013-STR-020] Simpan ke Draf 50 kali berturut-turut tidak menggandakan order draf
    Given user berada di halaman "Buat Order - Step 2 Data Barang"
    When user mengklik tombol "Simpan ke Draf" sebanyak 50 kali
    Then sistem menampilkan "1 order draf pada Daftar Order"

  @stress @priority-low @REQ-050 @screen-daftar-order
  Scenario: [OMS013-STR-021] Filter, sort, dan paginasi berulang cepat tidak menimbulkan race condition
    Given user berada di halaman "Daftar Order"
    When user melakukan 30 kali kombinasi filter, sort, dan pindah halaman secara cepat
    Then sistem menampilkan "Menampilkan 1 - 20 data dari 30 data"
    And sistem tidak menampilkan "Terjadi kesalahan"

  @stress @priority-low @REQ-059 @screen-modal-no-perjalanan
  Scenario: [OMS013-STR-022] Menyalin No. Perjalanan 50 kali berturut-turut tetap berhasil
    Given user berada di halaman "Modal Data No. Perjalanan"
    When user mengklik tombol "Salin No. Perjalanan" sebanyak 50 kali
    Then sistem menampilkan "No. Perjalanan berhasil disalin"

  @stress @priority-low @REQ-053 @screen-daftar-order
  Scenario: [OMS013-STR-023] Riwayat Pembatalan dengan 1.000 order dibatalkan tetap dapat dibuka
    Given user berada di halaman "Daftar Order"
    And terdapat 1000 order berstatus "Dibatalkan"
    When user mengklik tombol "Riwayat Pembatalan"
    Then sistem menampilkan "Riwayat Pembatalan"
    And sistem merender halaman dalam waktu kurang dari 10 detik

  @stress @priority-medium @REQ-002 @screen-daftar-order
  Scenario: [OMS013-STR-024] Batch Order dengan 1.000 baris diproses dengan ringkasan hasil
    Given user berada di halaman "Daftar Order"
    When user mengklik tombol "Batch Order"
    And user mengunggah file "batch-order-fcl-1000-baris.xlsx"
    And user mengklik tombol "Unggah"
    Then sistem menampilkan "1.000 baris berhasil diproses"

  @stress @priority-medium @REQ-031 @screen-step3-vendor-harga
  Scenario: [OMS013-STR-025] Kalkulasi asuransi atas 500 baris barang bernilai maksimum tetap akurat
    Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
    And terdapat 500 baris barang berasuransi dengan Nilai Barang maksimum
    When user mencentang checkbox "Gunakan komponen harga"
    And user mengisi field "Asuransi" dengan "0,2"
    Then sistem menampilkan "Total Harga"
    And sistem tidak menampilkan "NaN"

  @stress @priority-low @REQ-054 @screen-public-tracking
  Scenario: [OMS013-STR-026] Seribu permintaan public tracking bersamaan tetap dilayani
    Given terdapat 1000 permintaan public tracking secara bersamaan
    When seluruh permintaan mengirim No. Perjalanan valid
    Then sistem menampilkan "Progress Perjalanan"
    And sistem merespons dalam waktu kurang dari 5 detik
