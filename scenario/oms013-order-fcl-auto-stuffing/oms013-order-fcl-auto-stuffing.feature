# Catatan bahasa: keywords Gherkin dalam Inggris (Feature/Background/Scenario/Given/When/Then/And/Examples); teks langkah dalam Bahasa Indonesia.
# Modul: OMS013 — Order FCL Auto Stuffing (OMS)
# Sumber: output/oms013-order-fcl-auto-stuffing/oms013-order-fcl-auto-stuffing.analysis.md
# Catatan: teks alert kapasitas mengikuti desain ("... kapasitas armada"); istilah status mengikuti spec
#          (alias desain: "Isi Data Dasar"="Isi Data Pengiriman", "Terkirim"="Selesai").

@oms013 @order-fcl @auto-stuffing
Feature: Order FCL dengan Auto Stuffing pada OMS
  Sebagai Staff Operasional Shipper
  Saya ingin membuat, mengelola, dan memantau Order FCL yang barangnya diambil dari Master Barang
  Agar order terkirim dengan muatan tervisualisasi (auto stuffing) dan dapat dilacak via No. Perjalanan

  Background:
    Given saya login sebagai "Staff Operasional" pada OMS shipper "Mentari Sumber Kertas"
    And saya berada di halaman "Daftar Order"

  # ============================================================
  # POSITIVE
  # ============================================================

  @positive @e2e @REQ-001 @REQ-031 @REQ-032 @step1 @step2 @step3 @step4
  Scenario: OMS013-POS-001 — Buat Order FCL Normal end-to-end hingga status Menunggu Penugasan
    When saya klik button "Buat Order"
    And saya memilih jenis pengiriman "FCL"
    And saya mengisi seluruh field wajib Step 1 dengan tipe pengiriman "Normal"
    And saya klik button "Selanjutnya"
    And saya menambahkan barang dari Master Barang ke setiap kontainer dan mengisi Jumlah
    And saya klik button "Selanjutnya"
    And saya mengisi Vendor, Tanggal Permintaan Muat, dan Harga
    And saya klik button "Selanjutnya"
    And saya klik button "Simpan" pada Step Review
    Then order baru tampil di Daftar Order dengan status "Menunggu Penugasan"

  @positive @REQ-004 @REQ-005 @REQ-006 @REQ-007 @REQ-008 @spec-conflict @step1
  Scenario: OMS013-POS-002 — Step 1: mengisi field wajib lalu lanjut ke Step 2
    When saya klik button "Buat Order"
    And saya memilih jenis pengiriman "FCL"
    And saya memilih Pelabuhan Asal "Tanjung Perak (SUB)"
    And saya memilih Pelabuhan Tujuan "Panjang (PNJ)"
    And saya memilih Jenis Kontainer "20 DRY"
    And saya mengisi Jumlah Kontainer "2"
    And saya memilih Tipe Pengiriman "Normal"
    And saya memilih Metode Pengiriman "Door to Door"
    And saya melengkapi Data Pengirim dan Data Penerima
    And saya klik button "Selanjutnya"
    Then stepper menampilkan langkah aktif "Data Barang"

  @positive @REQ-004 @step1
  Scenario: OMS013-POS-003 — Step 1: auto-draft Data Pengirim dari Master Droppoint
    When saya klik button "Buat Order" dan memilih jenis pengiriman "FCL" dengan tipe "Normal"
    And saya memilih Drop Point Asal "Gudang MSK Region 2"
    Then field "Pengirim" terisi otomatis
    And field Provinsi Asal, Kota/Kab. Asal, Kecamatan Asal, Desa/Kelurahan Asal, Kode Pos, dan Alamat Asal terisi otomatis dan bersifat read-only

  @positive @REQ-004 @step1
  Scenario: OMS013-POS-004 — Step 1: auto-draft Data Penerima dari Master Droppoint
    When saya klik button "Buat Order" dan memilih jenis pengiriman "FCL" dengan tipe "Normal"
    And saya memilih Drop Point Tujuan "Gudang Jaya Retail Lampung"
    Then field "Penerima" terisi otomatis
    And field alamat tujuan terisi otomatis dan bersifat read-only

  @positive @REQ-002 @REQ-009 @REQ-010 @REQ-011 @REQ-014 @step2 @modal-pilih-barang
  Scenario: OMS013-POS-005 — Step 2: memilih barang dari Master Barang via modal Pilih Barang
    Given saya berada di Step 2 "Data Barang" pada order FCL baru
    When saya klik button "Pilih Barang" pada card "Kontainer 1"
    And saya mencari barang dengan kata kunci "Kertas HVS"
    And saya mencentang checkbox barang "SKU-PPR-001" dan "SKU-PPR-002"
    And saya klik button "Simpan" pada modal
    Then tabel barang Kontainer 1 menampilkan baris "SKU-PPR-001" dan "SKU-PPR-002"

  @positive @REQ-015 @step2
  Scenario: OMS013-POS-006 — Step 2: field barang ter-draft read-only dari Master Barang
    Given saya berada di Step 2 dengan barang "SKU-PPR-001" pada Kontainer 1
    Then kolom Kode SKU, Nama Barang, Kemasan, Kubikasi, Dimensi, dan Berat terisi dari Master Barang
    And kolom-kolom tersebut tidak dapat diubah

  @positive @REQ-012 @step2 @modal-pilih-barang
  Scenario: OMS013-POS-007 — Step 2: label "Sudah Ditambahkan" pada barang yang sudah masuk kontainer
    Given Kontainer 1 sudah memuat barang "SKU-PPR-001"
    When saya klik button "Pilih Barang" pada card "Kontainer 1"
    Then barang "SKU-PPR-001" pada modal berlabel "Sudah Ditambahkan"

  @positive @REQ-013 @step2 @modal-pilih-barang
  Scenario: OMS013-POS-008 — Step 2: counter jumlah barang terpilih pada modal
    Given saya membuka modal "Pilih Barang" pada Kontainer 1
    When saya mencentang 3 barang
    Then counter modal menampilkan jumlah barang terpilih "3"

  @positive @REQ-016 @REQ-023 @step2
  Scenario: OMS013-POS-009 — Step 2: mengisi Jumlah per baris barang lalu lanjut
    Given saya berada di Step 2 dengan 2 barang pada Kontainer 1
    When saya mengisi Jumlah "200" untuk setiap baris barang
    And saya klik button "Selanjutnya"
    Then stepper menampilkan langkah aktif "Vendor dan Harga"

  @positive @REQ-017 @REQ-018 @step2
  Scenario: OMS013-POS-010 — Step 2: centang Tambahkan Asuransi memunculkan kolom Nilai Barang per kontainer
    Given saya berada di Step 2 dengan barang pada Kontainer 1 dan Kontainer 2
    When saya mencentang checkbox "Tambahkan Asuransi" pada Kontainer 1
    Then kolom "Nilai Barang" tampil pada seluruh baris barang Kontainer 1
    And kolom "Nilai Barang" tidak tampil pada Kontainer 2
    When saya mengisi Nilai Barang untuk seluruh baris Kontainer 1
    And saya klik button "Selanjutnya"
    Then stepper menampilkan langkah aktif "Vendor dan Harga"

  @positive @REQ-019 @step2
  Scenario: OMS013-POS-011 — Step 2: Nomor DO multi-nilai dipisah koma tampil sebagai chip
    Given saya berada di Step 2 pada Kontainer 1
    When saya mengisi Nomor DO "TGK783898202U,TBL28371302"
    Then field Nomor DO menampilkan 2 chip "TGK783898202U" dan "TBL28371302"
    And setiap chip memiliki tombol hapus "×"

  @positive @REQ-020 @step2
  Scenario: OMS013-POS-012 — Step 2: menghapus barang per baris
    Given Kontainer 1 memuat 3 baris barang
    When saya klik icon hapus pada baris "SKU-BKU-001"
    Then baris "SKU-BKU-001" hilang dari tabel Kontainer 1
    And total kubikasi dan total berat Kontainer 1 terhitung ulang

  @positive @REQ-024 @step3
  Scenario: OMS013-POS-013 — Step 3: mengisi Vendor, Tanggal Permintaan Muat, dan Harga
    Given saya berada di Step 3 "Vendor dan Harga"
    When saya memilih Vendor "PT Logistik Transportasi Nusantara"
    And saya mengisi Tanggal Permintaan Muat "24/07/2026 14:30"
    And saya mengisi Harga "12.000.000"
    Then ringkasan menampilkan Drop Point Asal, Drop Point Tujuan, dan Jenis Kontainer
    And tabel ringkasan muatan menampilkan Total Berat, Total Kubikasi, dan Total Nilai Barang per kontainer

  @positive @REQ-024 @step3
  Scenario: OMS013-POS-014 — Step 3: komponen harga PPN dan PPh via checkbox Gunakan komponen harga
    Given saya berada di Step 3 dengan Harga "30.000.000"
    When saya mencentang checkbox "Gunakan komponen harga"
    Then input persentase "PPN" dan "PPh" tampil
    And panel kalkulasi menampilkan "Harga DPP", "PPN (1,1%)", "PPh (2%)", dan "Total Harga"
    And Total Harga terhitung "Rp. 29.730.000"

  @positive @REQ-026 @step3
  Scenario: OMS013-POS-015 — Step 3: komponen Asuransi ikut terhitung saat ada kontainer diasuransikan
    Given order memiliki Kontainer 2 yang diasuransikan dengan Total Nilai Barang "Rp1.006.750.000"
    When saya berada di Step 3 dan mencentang "Gunakan komponen harga"
    Then baris "Asuransi (0,2%)" tampil pada kalkulasi harga dengan catatan Total Nilai Barang
    And nilai Asuransi = persentase × Total Nilai Barang ikut dijumlahkan ke Total Harga bersama PPN dan PPh

  @positive @REQ-028 @REQ-029 @step4
  Scenario: OMS013-POS-016 — Step 4: review read-only dengan struktur Data Barang OMS dan label Diasuransikan
    Given saya berada di Step 4 "Review" dengan Kontainer 2 diasuransikan
    Then seluruh section Review bersifat read-only
    And section Data Barang menampilkan Kode SKU, Nama Barang, Kemasan, Kubikasi/Dimensi, Berat, dan Jumlah
    And kolom "Nilai Barang" hanya tampil pada Kontainer 2
    And judul Kontainer 2 menampilkan label "Diasuransikan"

  @positive @REQ-003 @REQ-030 @step4 @visualisasi
  Scenario: OMS013-POS-017 — Step 4: membuka pop up Visualisasi Muatan dari card Data Barang
    Given saya berada di Step 4 "Review"
    When saya klik button "Visualisasi Muatan" pada card Data Barang
    Then pop up visualisasi muatan tampil
    And pop up menampilkan Total Kubikasi, Total Berat, tab per kontainer, progress "Berat Terpakai" dan "Ruang Terpakai", serta canvas muatan 3D

  @positive @REQ-031 @REQ-032 @step4
  Scenario: OMS013-POS-018 — Step 4: Simpan mengubah status menjadi Menunggu Penugasan
    Given saya berada di Step 4 "Review" dengan seluruh data valid
    When saya klik button "Simpan"
    Then status order menjadi "Menunggu Penugasan"
    And order tampil di Daftar Order dengan badge status "Menunggu Penugasan"

  @positive @REQ-033 @draft
  Scenario Outline: OMS013-POS-019 — Simpan ke Draf pada tiap step menghasilkan status draft yang sesuai
    Given saya berada di Step <step> pada pengisian Order FCL
    When saya klik button "Simpan ke Draf"
    Then order tersimpan dengan status "<status>"
    And order tampil di Daftar Order dengan badge status "<status>"

    Examples:
      | step | status              |
      | 1    | Isi Data Pengiriman |
      | 2    | Isi Data Muatan     |
      | 3    | Isi Data Vendor     |
      | 4    | Review Order        |

  @positive @REQ-033 @REQ-042 @daftar-order
  Scenario: OMS013-POS-020 — Lanjutkan Pengisian membuka draft pada step terakhir
    Given terdapat order draft berstatus "Isi Data Muatan"
    When saya membuka action menu order tersebut dan memilih "Lanjutkan Pengisian"
    Then wizard Buat Order terbuka pada Step 2 "Data Barang" dengan data tersimpan

  @positive @REQ-034 @REQ-036 @REQ-037 @REQ-038 @edit-order
  Scenario: OMS013-POS-021 — Edit order berstatus Menunggu Penugasan lalu simpan dengan konfirmasi
    Given terdapat order berstatus "Menunggu Penugasan"
    When saya membuka action menu order tersebut dan memilih "Edit"
    Then halaman Edit Order menampilkan Jenis Pengiriman dan Tipe Pengiriman sebagai read-only
    And Jenis Kontainer, Jumlah Kontainer, Data Pengirim, Data Penerima, Data Barang, serta Vendor dan Harga dapat diubah
    When saya mengubah Jumlah Kontainer menjadi "1" dan klik button "Simpan"
    Then pop up konfirmasi simpan tampil
    When saya mengonfirmasi simpan
    Then perubahan tersimpan dan halaman kembali ke Detail Order

  @positive @REQ-039 @REQ-040 @REQ-041 @pembatalan
  Scenario: OMS013-POS-022 — Membatalkan order draft dengan Alasan Pembatalan
    Given terdapat order berstatus "Review Order"
    When saya membuka action menu order tersebut dan memilih "Batalkan Order"
    And saya mengisi "Alasan Pembatalan" dengan "Perubahan jadwal produksi"
    And saya mengonfirmasi pembatalan
    Then status order menjadi "Dibatalkan"

  @positive @REQ-039 @pembatalan
  Scenario: OMS013-POS-023 — Membatalkan order berstatus Ditugaskan
    Given terdapat order berstatus "Ditugaskan"
    When saya membuka action menu order tersebut dan memilih "Batalkan Order"
    And saya mengisi "Alasan Pembatalan" dengan "Vendor tidak tersedia"
    And saya mengonfirmasi pembatalan
    Then status order menjadi "Dibatalkan"

  @positive @REQ-046 @REQ-047 @REQ-048 @no-perjalanan
  Scenario: OMS013-POS-024 — Lihat No. Perjalanan menampilkan pop up Data No. Perjalanan per kontainer
    Given terdapat order FCL berstatus "Ditugaskan" dengan 2 kontainer
    When saya membuka action menu order tersebut dan memilih "Lihat No. Perjalanan"
    Then pop up "Data No. Perjalanan" tampil dengan ID Order dan badge "FCL"
    And pop up menampilkan 2 baris berisi No. Perjalanan, No. Kontainer, dan Jenis Kontainer

  @positive @REQ-044 @REQ-049 @no-perjalanan
  Scenario: OMS013-POS-025 — Menyalin No. Perjalanan via icon copy
    Given pop up "Data No. Perjalanan" terbuka
    When saya klik icon copy pada baris pertama
    Then No. Perjalanan baris pertama tersalin ke clipboard

  @positive @REQ-050 @no-perjalanan @detail-order
  Scenario: OMS013-POS-026 — No. Perjalanan dapat dilihat pada halaman Detail Order
    Given terdapat order FCL berstatus "Ditugaskan"
    When saya membuka halaman Detail Order order tersebut
    Then informasi No. Perjalanan per kontainer tampil pada Detail Order

  @positive @REQ-043 @daftar-order
  Scenario: OMS013-POS-027 — Riwayat Pembatalan menampilkan seluruh order yang pernah dibatalkan
    Given terdapat minimal 1 order berstatus "Dibatalkan"
    When saya klik button "Riwayat Pembatalan" pada toolbar Daftar Order
    Then daftar seluruh order yang pernah dibatalkan tampil

  @positive @REQ-042 @daftar-order
  Scenario: OMS013-POS-028 — Riwayat Perubahan menampilkan histori perubahan order tertentu
    Given terdapat order berstatus "Menunggu Penugasan" yang pernah diedit
    When saya membuka action menu order tersebut dan memilih "Riwayat Perubahan"
    Then histori perubahan order tersebut tampil

  @positive @REQ-004 @REQ-005 @multipickup @step1 @step2
  Scenario: OMS013-POS-029 — Buat Order FCL Multipickup dengan 2 titik pick up
    When saya membuat Order FCL dengan Tipe Pengiriman "Multipickup"
    Then section Data Pengirim menampilkan blok "Pick Up 1" dan "Pick Up 2" serta link "Tambah Baris Input"
    And info alert "Pastikan urutan pengiriman sudah sesuai saat membuat shipment" tampil
    When saya melengkapi kedua blok pick up dan lanjut ke Step 2
    Then setiap kontainer menampilkan sub-section per titik "Pick Up 1" dan "Pick Up 2" dengan tabel barang masing-masing

  @positive @REQ-004 @REQ-005 @multidrop @step1 @step2
  Scenario: OMS013-POS-030 — Buat Order FCL Multidrop dengan 2 titik drop off
    When saya membuat Order FCL dengan Tipe Pengiriman "Multidrop"
    Then section Data Penerima menampilkan blok "Drop Off 1" dan "Drop Off 2" serta link "Tambah Baris Input"
    When saya melengkapi kedua blok drop off dan lanjut ke Step 2
    Then setiap kontainer menampilkan sub-section per titik "Drop Off 1" dan "Drop Off 2" dengan tabel barang masing-masing

  @positive @REQ-004 @REQ-005 @multipoint @step1 @step2
  Scenario: OMS013-POS-031 — Buat Order FCL Multipoint dengan kombinasi pick up dan drop off
    When saya membuat Order FCL dengan Tipe Pengiriman "Multipoint"
    Then section Data Pengirim menampilkan blok "Pick Up 1" dan "Pick Up 2"
    And section Data Penerima menampilkan blok "Drop Off 1" dan "Drop Off 2"
    When saya melengkapi seluruh blok dan lanjut ke Step 2
    Then setiap kontainer menampilkan sub-section kombinasi "Pick Up i – Drop Off j" dengan tabel barang masing-masing

  @positive @REQ-024 @multipickup @multidrop @step3
  Scenario: OMS013-POS-032 — Step 3: link Lihat Detail menampilkan modal Detail Multipickup/Multidrop
    Given saya berada di Step 3 pada order Multipoint
    When saya klik link "Lihat Detail" pada baris Drop Point Asal
    Then modal "Detail Multipickup" menampilkan daftar titik pick up beserta nama gudang dan alamat lengkap
    When saya menutup modal dan klik link "Lihat Detail" pada baris Drop Point Tujuan
    Then modal "Detail Multidrop" menampilkan daftar titik drop off beserta nama gudang dan alamat lengkap

  @positive @REQ-003 @visualisasi @auto-stuffing
  Scenario: OMS013-POS-033 — Hitung Ulang Kontainer: simulasi ubah jumlah kontainer lalu Terapkan ke Order
    Given panel "Hitung Ulang Kontainer" terbuka dari Step 2
    When saya menambah Jumlah Kontainer menggunakan stepper "+"
    Then visualisasi muatan dan persentase "Berat Terpakai"/"Ruang Terpakai" terhitung ulang
    When saya klik button "Terapkan ke Order"
    Then data order diperbarui sesuai hasil simulasi

  @positive @REQ-042 @daftar-order
  Scenario Outline: OMS013-POS-034 — Action menu per-baris sesuai status order
    Given terdapat order berstatus "<status>"
    When saya membuka action menu order tersebut
    Then aksi yang tampil adalah <aksi>

    Examples:
      | status              | aksi                                                                        |
      | Isi Data Pengiriman | "Detail, Lanjutkan Pengisian, Batalkan Order, Riwayat Perubahan"            |
      | Isi Data Muatan     | "Detail, Lanjutkan Pengisian, Batalkan Order, Riwayat Perubahan"            |
      | Isi Data Vendor     | "Detail, Lanjutkan Pengisian, Batalkan Order, Riwayat Perubahan"            |
      | Review Order        | "Detail, Lanjutkan Pengisian, Batalkan Order, Riwayat Perubahan"            |
      | Menunggu Penugasan  | "Detail, Edit, Batalkan Order, Riwayat Perubahan"                           |
      | Ditugaskan          | "Detail, Batalkan Order, Riwayat Perubahan, Lihat No. Perjalanan"           |

  @positive @daftar-order @filter
  Scenario: OMS013-POS-035 — Filter Daftar Order berdasarkan status
    When saya klik button "Filter"
    And saya memilih Status "Menunggu Penugasan"
    And saya klik button "Terapkan"
    Then tabel hanya menampilkan order berstatus "Menunggu Penugasan"
    When saya klik button "Reset"
    Then seluruh filter kembali kosong

  # ============================================================
  # NEGATIVE
  # ============================================================

  @negative @REQ-006 @step1 @validasi
  Scenario: OMS013-NEG-001 — Step 1: field wajib kosong memblokir lanjut ke Step 2
    Given saya berada di Step 1 dengan jenis pengiriman "FCL" tanpa mengisi field wajib
    Then button "Selanjutnya" tidak dapat digunakan atau menampilkan error validasi saat diklik
    And indikasi error tampil pada field wajib yang kosong

  @negative @REQ-016 @REQ-022 @step2 @validasi
  Scenario: OMS013-NEG-002 — Step 2: Jumlah kosong menampilkan helper error dan border merah
    Given Kontainer 1 memuat barang dengan field Jumlah kosong
    When saya klik button "Selanjutnya"
    Then helper error "Jumlah harus diisi" tampil pada baris tersebut
    And border field Jumlah berubah menjadi warna error
    And saya tetap berada di Step 2

  @negative @REQ-017 @REQ-022 @step2 @validasi
  Scenario: OMS013-NEG-003 — Step 2: Nilai Barang kosong saat asuransi aktif menampilkan error
    Given checkbox "Tambahkan Asuransi" Kontainer 1 dicentang dan Nilai Barang salah satu baris kosong
    When saya klik button "Selanjutnya"
    Then helper error "Nilai Barang harus diisi" tampil pada baris tersebut
    And border field Nilai Barang berubah menjadi warna error
    And saya tetap berada di Step 2

  @negative @REQ-027 @step3 @validasi
  Scenario: OMS013-NEG-004 — Step 3: Vendor, Tanggal Permintaan Muat, atau Harga kosong memblokir lanjut
    Given saya berada di Step 3 tanpa mengisi Vendor, Tanggal Permintaan Muat, dan Harga
    When saya klik button "Selanjutnya"
    Then indikasi error tampil pada field wajib yang kosong
    And saya tetap berada di Step 3

  @negative @REQ-041 @pembatalan @validasi
  Scenario: OMS013-NEG-005 — Pembatalan tanpa Alasan Pembatalan ditolak
    Given dialog pembatalan order terbuka
    When saya mengosongkan field "Alasan Pembatalan" dan mengonfirmasi pembatalan
    Then pembatalan tidak diproses
    And indikasi error tampil pada field "Alasan Pembatalan"

  @negative @REQ-036 @edit-order
  Scenario: OMS013-NEG-006 — Edit Order: Jenis Pengiriman dan Tipe Pengiriman tidak dapat diubah
    Given saya membuka halaman Edit Order pada order berstatus "Menunggu Penugasan"
    Then field Jenis Pengiriman ditampilkan read-only tanpa kontrol input
    And field Tipe Pengiriman ditampilkan read-only tanpa kontrol input

  @negative @REQ-035 @REQ-042 @daftar-order @spec-conflict
  Scenario: OMS013-NEG-007 — Order berstatus Ditugaskan tidak menyediakan aksi Edit
    Given terdapat order berstatus "Ditugaskan"
    When saya membuka action menu order tersebut
    Then aksi "Edit" tidak tampil pada menu
    # Catatan: desain 067 menampilkan button Edit Order pada Detail Ditugaskan — konflik dengan spec (Assumptions Log #12); spec menang.

  @negative @REQ-039 @daftar-order @pembatalan
  Scenario: OMS013-NEG-008 — Order berstatus Proses Pengiriman tidak dapat dibatalkan
    Given terdapat order berstatus "Proses Pengiriman"
    When saya membuka action menu order tersebut
    Then aksi "Batalkan Order" tidak tampil pada menu

  @negative @REQ-017 @REQ-018 @step2
  Scenario: OMS013-NEG-009 — Menghapus centang Tambahkan Asuransi menyembunyikan kolom Nilai Barang
    Given checkbox "Tambahkan Asuransi" Kontainer 1 dicentang dan kolom Nilai Barang tampil
    When saya menghapus centang checkbox "Tambahkan Asuransi" pada Kontainer 1
    Then kolom "Nilai Barang" tidak lagi tampil pada Kontainer 1
    And validasi Nilai Barang tidak diberlakukan saat klik "Selanjutnya"

  @negative @REQ-047 @no-perjalanan @daftar-order
  Scenario: OMS013-NEG-010 — Aksi Lihat No. Perjalanan tidak tampil sebelum status Ditugaskan
    Given terdapat order berstatus "Menunggu Penugasan"
    When saya membuka action menu order tersebut
    Then aksi "Lihat No. Perjalanan" tidak tampil pada menu

  @negative @step2 @validasi @assumption-20
  Scenario: OMS013-NEG-011 — Step 2: kontainer tanpa barang tidak dapat lanjut
    Given Kontainer 2 belum memiliki barang dan menampilkan pesan "Belum ada barang. Klik 'Pilih Barang'"
    When saya klik button "Selanjutnya"
    Then saya tetap berada di Step 2
    And indikasi kontainer belum berisi barang tampil

  @negative @REQ-007 @REQ-038 @step1
  Scenario: OMS013-NEG-012 — Batal pengisian menampilkan konfirmasi dan tidak menyimpan order
    Given saya berada di Step 1 dengan sebagian field terisi tanpa pernah menyimpan draf
    When saya klik button "Batal"
    Then pop up konfirmasi pembatalan pengisian tampil
    When saya mengonfirmasi batal
    Then saya kembali ke Daftar Order
    And tidak ada order baru yang tersimpan

  @negative @REQ-010 @step2 @modal-pilih-barang
  Scenario: OMS013-NEG-013 — Modal Pilih Barang: pencarian tanpa hasil menampilkan keadaan kosong
    Given saya membuka modal "Pilih Barang"
    When saya mencari barang dengan kata kunci "zzz-tidak-ada"
    Then daftar barang kosong dan pesan tidak ada hasil tampil
    And counter barang terpilih tetap "0"

  @negative @REQ-040 @pembatalan @role @assumption-21
  Scenario: OMS013-NEG-014 — Pembatalan hanya tersedia bagi admin shipper, bukan vendor
    Given saya login pada aplikasi vendor untuk order yang sama
    Then aksi "Batalkan Order" tidak tersedia bagi akun vendor

  @negative @REQ-034 @REQ-035 @daftar-order
  Scenario Outline: OMS013-NEG-015 — Order berstatus akhir tidak menyediakan aksi Edit maupun Batalkan
    Given terdapat order berstatus "<status>"
    When saya membuka action menu order tersebut
    Then aksi "Edit" tidak tampil pada menu
    And aksi "Batalkan Order" tidak tampil pada menu

    Examples:
      | status    |
      | Selesai   |
      | Dibatalkan|

  # ============================================================
  # EDGE
  # ============================================================

  @edge @REQ-021 @step2 @alert-kapasitas
  Scenario: OMS013-EDG-001 — Alert kubikasi melebihi kapasitas bersifat informasional dan tidak memblokir
    Given total kubikasi barang Kontainer 1 melebihi kapasitas kontainer
    Then alert "Kubikasi melebihi kapasitas armada" tampil pada Kontainer 1
    When saya klik button "Selanjutnya"
    Then stepper menampilkan langkah aktif "Vendor dan Harga"

  @edge @REQ-021 @step2 @alert-kapasitas
  Scenario: OMS013-EDG-002 — Alert berat melebihi kapasitas bersifat informasional dan tidak memblokir
    Given total berat barang Kontainer 1 melebihi kapasitas kontainer
    Then alert "Berat melebihi kapasitas armada" tampil pada Kontainer 1
    When saya klik button "Selanjutnya"
    Then stepper menampilkan langkah aktif "Vendor dan Harga"

  @edge @REQ-021 @step2 @alert-kapasitas
  Scenario: OMS013-EDG-003 — Alert kubikasi dan berat melebihi kapasitas tampil sekaligus
    Given total kubikasi dan total berat barang Kontainer 1 melebihi kapasitas kontainer
    Then alert "Kubikasi dan Berat melebihi kapasitas armada" tampil pada Kontainer 1
    And user tetap dapat melanjutkan ke step berikutnya

  @edge @REQ-019 @step2
  Scenario: OMS013-EDG-004 — Nomor DO dengan koma berlebih dan duplikat dinormalisasi menjadi chip
    Given saya berada di Step 2 pada Kontainer 1
    When saya mengisi Nomor DO "DO-1,,DO-2, DO-1 ,"
    Then chip yang terbentuk hanya "DO-1" dan "DO-2" tanpa chip kosong maupun duplikat

  @edge @REQ-020 @step2
  Scenario: OMS013-EDG-005 — Menghapus seluruh barang mengembalikan keadaan kosong kontainer
    Given Kontainer 1 memuat 2 baris barang
    When saya menghapus seluruh baris barang pada Kontainer 1
    Then pesan "Belum ada barang. Klik 'Pilih Barang'" tampil pada Kontainer 1
    And total kubikasi dan total berat Kontainer 1 menjadi "0"

  @edge @REQ-017 @step2 @validasi
  Scenario: OMS013-EDG-006 — Nilai Barang bernilai 0 saat asuransi aktif dianggap belum diisi
    Given checkbox "Tambahkan Asuransi" Kontainer 1 dicentang
    When saya mengisi Nilai Barang "0" lalu klik button "Selanjutnya"
    Then helper error "Nilai Barang harus diisi" tampil
    And saya tetap berada di Step 2

  @edge @REQ-045 @no-perjalanan @visualisasi
  Scenario: OMS013-EDG-007 — Jumlah No. Perjalanan mengikuti jumlah kontainer order
    Given terdapat order FCL berstatus "Ditugaskan" dengan 3 kontainer
    When saya membuka pop up "Data No. Perjalanan"
    Then pop up menampilkan tepat 3 baris No. Perjalanan

  @edge @multipoint @step2
  Scenario: OMS013-EDG-008 — Multipoint: setiap kombinasi Pick Up × Drop Off memiliki tabel barang terpisah
    Given order Multipoint memiliki 2 titik pick up dan 2 titik drop off
    When saya berada di Step 2
    Then setiap kontainer menampilkan 4 sub-section kombinasi: "Pick Up 1 – Drop Off 1", "Pick Up 1 – Drop Off 2", "Pick Up 2 – Drop Off 1", dan "Pick Up 2 – Drop Off 2"
    And setiap sub-section memiliki Nomor DO, tabel barang, button "Pilih Barang", dan total masing-masing

  @edge @REQ-026 @REQ-029 @step3 @step4
  Scenario: OMS013-EDG-009 — Asuransi parsial: hanya kontainer terasuransi yang memengaruhi komponen Asuransi
    Given Kontainer 1 tanpa asuransi dan Kontainer 2 diasuransikan
    When saya berada di Step 3
    Then tabel ringkasan menampilkan "Tanpa Asuransi" untuk Kontainer 1 dan nominal Total Nilai Barang untuk Kontainer 2
    And komponen Asuransi dihitung hanya dari Total Nilai Barang Kontainer 2
    When saya lanjut ke Step 4
    Then hanya Kontainer 2 yang berlabel "Diasuransikan"

  @edge @visualisasi @auto-stuffing @assumption-19
  Scenario: OMS013-EDG-010 — Visualisasi muatan menandai koli yang melebihi kapasitas dengan outline merah
    Given muatan Kontainer 1 melebihi kapasitas unit
    When saya membuka panel visualisasi muatan
    Then canvas menampilkan indikator "koli melebihi kapasitas (outline merah)"
    And koli berlebih digambarkan dengan outline merah pada canvas 3D

  @edge @REQ-025 @detail-order
  Scenario: OMS013-EDG-011 — Waktu Perjalanan hanya tampil pada Detail Order berstatus Ditugaskan
    Given terdapat order berstatus "Menunggu Penugasan" dan order lain berstatus "Ditugaskan"
    When saya membuka Detail Order pada order "Menunggu Penugasan"
    Then baris "Waktu Perjalanan" tidak tampil
    When saya membuka Detail Order pada order "Ditugaskan"
    Then baris "Waktu Perjalanan" tampil dengan nilai durasi

  @edge @visualisasi @auto-stuffing
  Scenario: OMS013-EDG-012 — Hitung Ulang Kontainer: mengubah jenis kontainer memperbarui kapasitas maksimal
    Given panel "Hitung Ulang Kontainer" terbuka
    When saya mengganti Jenis Kontainer melalui button "Pilih Jenis Kontainer"
    Then informasi "Berat Maksimal 1 Kontainer" dan "Kubikasi Maksimal 1 Kontainer" diperbarui
    And persentase keterpakaian dihitung ulang terhadap kapasitas baru

  @edge @REQ-005 @multipickup @multipoint @step1
  Scenario: OMS013-EDG-013 — Tambah dan hapus baris titik pick up/drop off
    Given saya berada di Step 1 order Multipoint dengan 2 pick up dan 2 drop off
    When saya klik link "Tambah Baris Input" pada Data Pengirim
    Then blok "Pick Up 3" tampil
    When saya klik icon hapus pada blok "Pick Up 3"
    Then blok "Pick Up 3" hilang
    And blok tambahan pada Data Penerima juga dapat ditambah dan dihapus dengan cara yang sama

  @edge @REQ-032 @status-lifecycle
  Scenario: OMS013-EDG-014 — Siklus status penuh dari draft hingga Selesai
    Given order FCL disubmit hingga berstatus "Menunggu Penugasan"
    When vendor melakukan penugasan
    Then status order menjadi "Ditugaskan"
    When seluruh armada berstatus penugasan "Dalam Perjalanan"
    Then status order menjadi "Proses Pengiriman"
    When seluruh armada selesai bongkar
    Then status order menjadi "Selesai"

  @edge @REQ-012 @step2 @modal-pilih-barang @assumption-15
  Scenario: OMS013-EDG-015 — Barang berlabel Sudah Ditambahkan tidak dapat ditambahkan ganda ke kontainer yang sama
    Given Kontainer 1 sudah memuat barang "SKU-PPR-001"
    When saya membuka modal "Pilih Barang" pada Kontainer 1
    Then barang "SKU-PPR-001" berlabel "Sudah Ditambahkan" dan tidak dapat dicentang ulang
    And menutup lalu menyimpan modal tidak menghasilkan baris duplikat "SKU-PPR-001"

  @edge @REQ-033 @draft
  Scenario: OMS013-EDG-016 — Draft menyimpan seluruh isian dan dapat dilanjutkan lintas sesi
    Given saya mengisi Step 1 dan Step 2 lalu klik "Simpan ke Draf" pada Step 2
    When saya logout lalu login kembali dan memilih "Lanjutkan Pengisian" pada order tersebut
    Then wizard terbuka pada Step 2 dengan barang, jumlah, asuransi, dan Nomor DO tetap tersimpan

  # ============================================================
  # STRESS
  # ============================================================

  @stress @REQ-016 @step2
  Scenario: OMS013-STR-001 — Step 2 memuat 50 baris barang per kontainer
    Given Master Barang memiliki minimal 50 barang aktif
    When saya menambahkan 50 barang ke Kontainer 1 dan mengisi Jumlah setiap baris
    Then seluruh 50 baris tampil tanpa kegagalan render
    And total kubikasi dan total berat terhitung benar sesuai penjumlahan seluruh baris

  @stress @REQ-019 @step2
  Scenario: OMS013-STR-002 — Nomor DO dengan 20 nomor sekaligus
    Given saya berada di Step 2 pada Kontainer 1
    When saya mengisi Nomor DO berisi 20 nomor dipisah koma
    Then 20 chip tampil pada field Nomor DO
    And setiap chip tetap dapat dihapus satu per satu

  @stress @REQ-045 @no-perjalanan @step2
  Scenario: OMS013-STR-003 — Order dengan 10 kontainer
    When saya membuat Order FCL dengan Jumlah Kontainer "10" dan melengkapinya hingga submit
    Then Step 2 menampilkan 10 card kontainer
    And setelah order ditugaskan, pop up "Data No. Perjalanan" menampilkan 10 baris

  @stress @multipoint @step1 @step2
  Scenario: OMS013-STR-004 — Multipoint dengan 5 pick up dan 5 drop off
    When saya membuat Order FCL Multipoint dengan 5 titik pick up dan 5 titik drop off
    Then Step 1 menampilkan 5 blok Pick Up dan 5 blok Drop Off
    And Step 2 menampilkan 25 sub-section kombinasi per kontainer tanpa kegagalan render

  @stress @daftar-order @pagination
  Scenario: OMS013-STR-005 — Navigasi pagination Daftar Order dengan banyak data
    Given Daftar Order memiliki lebih dari 200 order
    When saya mengubah Tampilkan menjadi nilai terbesar dan menavigasi ke halaman terakhir via "»"
    Then tabel tetap responsif dan menampilkan data halaman terakhir dengan benar
    And navigasi "«" kembali ke halaman pertama

  @stress @REQ-026 @step3
  Scenario: OMS013-STR-006 — Nilai Barang bernominal sangat besar
    Given seluruh baris Kontainer 1 diasuransikan dengan Nilai Barang "999.999.999.999"
    When saya berada di Step 3 dengan komponen harga aktif
    Then Total Nilai Barang dan komponen Asuransi terhitung tanpa overflow
    And format pemisah ribuan tampil konsisten di seluruh ringkasan

  @stress @REQ-021 @step2 @visualisasi
  Scenario: OMS013-STR-007 — Muatan 500% dari kapasitas tetap non-blocking
    Given total kubikasi dan berat Kontainer 1 mencapai 5 kali kapasitas maksimal
    Then alert "Kubikasi dan Berat melebihi kapasitas armada" tampil
    And panel visualisasi menampilkan jumlah koli berlebih dengan outline merah tanpa crash
    And saya tetap dapat melanjutkan hingga Step 4 dan submit

  @stress @REQ-031 @step4
  Scenario: OMS013-STR-008 — Klik Simpan berulang kali pada Review tidak membuat order ganda
    Given saya berada di Step 4 "Review" dengan seluruh data valid
    When saya klik button "Simpan" 5 kali secara cepat
    Then hanya 1 order berstatus "Menunggu Penugasan" yang terbentuk
    And kuota order hanya berkurang 1

  @stress @visualisasi @auto-stuffing
  Scenario: OMS013-STR-009 — Interaksi canvas visualisasi dengan ribuan koli
    Given Kontainer 1 memuat lebih dari 1.300 koli sesuai baseline desain
    When saya membuka panel visualisasi dan melakukan drag putar 360°, scroll zoom, dan klik 2× reset
    Then canvas merespons setiap interaksi tanpa macet
    And overlay informasi alokasi ("N koli • N kg dialokasikan ke unit ini") tetap akurat
