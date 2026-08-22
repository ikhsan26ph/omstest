# language: id
# ============================================================================
# Modul   : OMS014 — Order FTL & FCL Tanpa Auto Stuffing ("Order Normal")
# Sumber  : output/oms014-order-ftl-fcl-normal/oms014-order-ftl-fcl-normal.analysis.md
#           (Requirements REQ-001..037, VAL-01..37 + VAL-M1..M7, AC-001..060,
#            UI Inventory §1..§18 + Ringkasan Selector Global, ASM-001..040)
# Tahap   : 2 — Test Scenario Generation (AUTO MODE)
# Tanggal : 2026-08-20
# ----------------------------------------------------------------------------
# Konvensi tag:
#   @positive | @negative | @edge | @stress   → kategori
#   @priority-high | @priority-medium | @priority-low
#   @REQ-xxx @VAL-xx @AC-xxx                  → traceability
#   @screen-<nama>                            → layar utama
#   @OMS014-XXX-NNN                           → id skenario (sinkron dengan .scenarios.json)
# ----------------------------------------------------------------------------
# Prakondisi global seluruh file: add-on Auto Stuffing dalam kondisi NONAKTIF
# (toggle OFF) pada tenant/lingkungan uji — REQ-034, UF-00.
# ============================================================================

Fitur: OMS014 — Pembuatan & Pengelolaan Order FTL/FCL Tanpa Auto Stuffing

  Sebagai Admin/Staff Operasional Shipper
  Saya ingin membuat dan mengelola order FTL & FCL untuk seluruh tipe pengiriman
  Tanpa bantuan Auto Stuffing (distribusi barang sepenuhnya manual)
  Agar flow order normal tetap dapat dijalankan dan diuji end-to-end

  Latar:
    Diberikan add-on "Auto Stuffing" berada pada kondisi "NONAKTIF" untuk tenant "Mentari Sumber Kertas"
    Dan user login sebagai "Staff Operasional Shipper" dengan email "andikamsk@gmail.com"

  # ==========================================================================
  Aturan: A. Toggle Auto Stuffing & Kondisi Build (REQ-033..REQ-037)
  # ==========================================================================

    @positive @priority-high @REQ-034 @AC-056 @VAL-33 @screen-konfigurasi-addon @OMS014-POS-001
    Skenario: Admin Sistem mematikan toggle Auto Stuffing sehingga mode order normal aktif
      Given user berada di halaman "Konfigurasi Add-on"
      When user menonaktifkan toggle "Auto Stuffing"
      And user mengklik tombol "Simpan"
      Then sistem menampilkan "Pengaturan berhasil disimpan"
      And sistem menerapkan mode order normal tanpa perlu deploy ulang

    @positive @priority-medium @REQ-033 @AC-055 @VAL-33 @screen-konfigurasi-addon @OMS014-POS-002
    Skenario: Kondisi default build adalah Auto Stuffing aktif
      Given user berada di halaman "Konfigurasi Add-on"
      When user memeriksa nilai default toggle "Auto Stuffing" pada tenant yang belum dikonfigurasi
      Then sistem menampilkan toggle "Auto Stuffing" dalam kondisi "Aktif"

    @positive @priority-high @REQ-035 @AC-057 @VAL-34 @screen-step2 @OMS014-POS-003
    Skenario: Toggle OFF menyembunyikan floating button, panel hitung ulang, dan logic penempatan otomatis secara serentak
      Given user berada di halaman "Buat Order - Step 2 Data Barang"
      When user memeriksa seluruh area halaman termasuk setelah scroll ke bawah
      Then sistem tidak menampilkan tombol "Hitung Ulang Armada"
      And sistem tidak menampilkan tombol "Visualisasi Terbaru"
      And sistem tidak menjalankan penempatan barang otomatis antar armada

    @positive @priority-high @REQ-036 @AC-058 @VAL-35 @screen-step4-review @OMS014-POS-004
    Skenario: Toggle OFF membuat Review dan Detail Order mengikuti kondisi tanpa elemen Auto Stuffing
      Given user berada di halaman "Buat Order - Step 4 Review"
      When user memeriksa kartu "Data Barang"
      Then sistem tidak menampilkan "Visualisasi Muatan"
      And sistem tidak menampilkan "Indikator Keterisian"
      And user diarahkan ke halaman "Detail Order" dan kondisi yang sama berlaku

    @positive @priority-medium @REQ-034 @AC-059 @VAL-36 @screen-konfigurasi-addon @OMS014-POS-005
    Skenario: Toggle dinyalakan kembali dan perilaku Auto Stuffing pulih tanpa deploy ulang
      Given user berada di halaman "Konfigurasi Add-on"
      When user mengaktifkan kembali toggle "Auto Stuffing"
      And user membuat order FTL baru sampai "Buat Order - Step 2 Data Barang"
      Then sistem menampilkan tombol "Hitung Ulang Armada"
      And sistem menampilkan tombol "Visualisasi Terbaru"

    @negative @priority-medium @REQ-034 @AC-055 @screen-daftar-order @OMS014-NEG-001
    Skenario: Toggle Auto Stuffing tidak tersedia pada UI Shipper
      Given user berada di halaman "Daftar Order"
      When user memeriksa seluruh menu sidebar dan halaman "Pengaturan Sistem"
      Then sistem tidak menampilkan kontrol "Auto Stuffing" bagi role Shipper

    @negative @priority-medium @REQ-037 @VAL-37 @AC-060 @screen-step2 @OMS014-NEG-002
    Skenario: Tidak terdapat route/halaman duplikat untuk mode Auto Stuffing nonaktif
      Given user berada di halaman "Buat Order - Step 2 Data Barang"
      When user memeriksa URL halaman pada mode Auto Stuffing OFF dan ON
      Then sistem menampilkan URL yang identik untuk kedua mode
      And sistem tidak menampilkan route alternatif seperti "/order/create-normal"

    @negative @priority-medium @REQ-037 @VAL-10 @AC-060 @screen-step2 @OMS014-NEG-003
    Skenario: Penghilangan elemen Auto Stuffing tidak menimbulkan layout pecah atau error console
      Given user berada di halaman "Buat Order - Step 2 Data Barang"
      When user memuat ulang halaman dan memeriksa console browser
      Then sistem tidak menampilkan "error" pada console
      And sistem tidak menampilkan area kosong bekas floating button pada pojok kanan bawah

  # ==========================================================================
  Aturan: B. Verifikasi Negatif — Absennya Elemen Auto Stuffing (REQ-003..008, REQ-029..031)
  # ==========================================================================

    @negative @priority-high @REQ-003 @VAL-01 @AC-003 @screen-step2 @OMS014-NEG-004
    Skenario: Floating button "Hitung Ulang Armada" tidak ditampilkan pada Step 2 order FTL
      Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FTL"
      When user memeriksa halaman pada posisi scroll paling atas
      Then sistem tidak menampilkan tombol "Hitung Ulang Armada"

    @negative @priority-high @REQ-003 @VAL-01 @AC-003 @screen-step2 @OMS014-NEG-005
    Skenario: Floating button "Hitung Ulang Kontainer" tidak ditampilkan pada Step 2 order FCL
      Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FCL"
      When user memeriksa halaman pada posisi scroll paling atas
      Then sistem tidak menampilkan tombol "Hitung Ulang Kontainer"

    @negative @priority-high @REQ-004 @VAL-02 @AC-004 @screen-step2 @OMS014-NEG-006
    Skenario: Floating button "Visualisasi Terbaru" tidak ditampilkan pada Step 2
      Given user berada di halaman "Buat Order - Step 2 Data Barang"
      When user memeriksa halaman pada posisi scroll paling atas
      Then sistem tidak menampilkan tombol "Visualisasi Terbaru"

    @negative @priority-high @REQ-003 @REQ-004 @VAL-01 @VAL-02 @AC-003 @screen-step2 @OMS014-NEG-007
    Skenario: Floating button tetap absen setelah halaman Step 2 di-scroll penuh dan saat hover
      Given user berada di halaman "Buat Order - Step 2 Data Barang" dengan 3 unit dan 30 baris barang
      When user melakukan scroll dari atas hingga akhir halaman
      And user melakukan hover pada pojok kanan bawah viewport
      Then sistem tidak menampilkan tombol "Hitung Ulang Armada"
      And sistem tidak menampilkan tombol "Visualisasi Terbaru"

    @negative @priority-high @REQ-005 @VAL-03 @AC-005 @screen-step2 @OMS014-NEG-008
    Skenario: Drawer "Hitung Ulang Armada/Kontainer" tidak dapat diakses melalui deep-link URL
      Given user berada di halaman "Buat Order - Step 2 Data Barang"
      When user membuka URL langsung "/order/create/step-2?panel=hitung-ulang"
      Then sistem tidak menampilkan panel "Hitung Ulang Armada"
      And user diarahkan ke halaman "Buat Order - Step 2 Data Barang" dalam kondisi normal

    @negative @priority-high @REQ-005 @VAL-03 @AC-005 @screen-step2 @OMS014-NEG-009
    Skenario: Panel "Visualisasi Terbaru" tidak dapat dibuka melalui shortcut keyboard maupun deep-link
      Given user berada di halaman "Buat Order - Step 2 Data Barang"
      When user menekan kombinasi shortcut keyboard yang sebelumnya membuka panel visualisasi
      And user membuka URL langsung "/order/create/step-2?panel=visualisasi"
      Then sistem tidak menampilkan panel "Visualisasi Terbaru"

    @negative @priority-high @REQ-005 @VAL-03 @screen-step2 @OMS014-NEG-010
    Skenario: Elemen turunan Auto Stuffing lain tidak ditemukan di Step 2
      Given user berada di halaman "Buat Order - Step 2 Data Barang"
      When user memeriksa seluruh elemen halaman
      Then sistem tidak menampilkan label "Paling Efisien"
      And sistem tidak menampilkan tombol "Terapkan ke Order"
      And sistem tidak menampilkan "Visualisasi 3D Muatan"
      And sistem tidak menampilkan "Berat Terpakai"
      And sistem tidak menampilkan "Ruang Terpakai"

    @negative @priority-high @REQ-006 @VAL-04 @AC-006 @screen-step2 @OMS014-NEG-011
    Skenario: Barang tetap berada pada unit tempat diinput setelah halaman di-refresh
      Given user berada di halaman "Buat Order - Step 2 Data Barang" dengan 2 armada
      When user menambahkan barang "SKU-PPR-001" hanya pada card "Armada 1"
      And user memuat ulang halaman
      Then sistem menampilkan barang "SKU-PPR-001" pada card "Armada 1"
      And sistem tidak menampilkan barang "SKU-PPR-001" pada card "Armada 2"

    @negative @priority-high @REQ-006 @VAL-04 @AC-006 @screen-step2 @OMS014-NEG-012
    Skenario: Barang tidak terdistribusi otomatis saat user berpindah step lalu kembali
      Given user berada di halaman "Buat Order - Step 2 Data Barang" dengan 3 armada terisi berbeda-beda
      When user mengklik tombol "Selanjutnya"
      And user mengklik tombol "Sebelumnya"
      Then sistem menampilkan komposisi barang per armada yang identik dengan sebelum berpindah step

    @negative @priority-high @REQ-007 @VAL-05 @AC-007 @screen-step2 @OMS014-NEG-013
    Skenario: Tipe Multipickup tidak melakukan pembagian rata barang antar alamat
      Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk tipe "Multipickup" dengan 2 alamat pickup
      When user menambahkan barang "SKU-PPR-001" dengan Jumlah "100" hanya pada kombinasi "Pick Up 1"
      Then sistem menampilkan Jumlah "100" pada kombinasi "Pick Up 1"
      And sistem menampilkan kondisi kosong pada kombinasi "Pick Up 2"

    @negative @priority-high @REQ-007 @VAL-05 @AC-007 @screen-step2 @OMS014-NEG-014
    Skenario: Tipe Multidrop tidak menempatkan sisa barang ke alamat pertama
      Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk tipe "Multidrop" dengan 2 alamat drop off
      When user mengisi Jumlah "7" pada kombinasi "Drop Off 2" dan membiarkan "Drop Off 1" kosong
      Then sistem tidak memindahkan barang ke kombinasi "Drop Off 1"
      And sistem menampilkan data barang apa adanya sesuai input manual

    @negative @priority-high @REQ-007 @REQ-008 @VAL-05 @VAL-06 @AC-007 @screen-step2 @OMS014-NEG-015
    Skenario: Tipe Multipoint dengan 4 kombinasi alamat tidak mengalami distribusi otomatis
      Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk tipe "Multipoint" dengan 2 pickup dan 2 drop off
      When user mengisi barang hanya pada kombinasi "Pick Up 2 - Drop Off 1"
      Then sistem menampilkan 4 kombinasi alamat pada card "Armada 1"
      And sistem menampilkan barang hanya pada kombinasi "Pick Up 2 - Drop Off 1"

    @negative @priority-high @REQ-029 @VAL-07 @AC-051 @screen-step4-review @OMS014-NEG-016
    Skenario: Step 4 Review tidak memuat button visualisasi muatan maupun indikator keterisian
      Given user berada di halaman "Buat Order - Step 4 Review"
      When user membuka kartu "Data Barang"
      Then sistem tidak menampilkan tombol "Lihat Visualisasi Muatan"
      And sistem tidak menampilkan "Indikator Keterisian"
      And sistem tidak menampilkan progress bar keterisian per unit

    @negative @priority-high @REQ-031 @VAL-08 @AC-053 @screen-detail-order @OMS014-NEG-017
    Skenario: Detail Order tidak memuat elemen visualisasi atau keterisian Auto Stuffing
      Given user berada di halaman "Detail Order" untuk order yang dibuat tanpa Auto Stuffing
      When user memeriksa kartu "Data Barang"
      Then sistem tidak menampilkan "Visualisasi Muatan"
      And sistem tidak menampilkan "Indikator Keterisian"

    @negative @priority-high @REQ-003 @REQ-005 @REQ-035 @AC-044 @screen-edit-order @OMS014-NEG-018
    Skenario: Halaman Edit Order tidak menampilkan floating button maupun panel hitung ulang
      Given user berada di halaman "Edit Order" untuk order berstatus "Menunggu Penugasan"
      When user membuka kartu "Data Barang - Kontainer 1"
      Then sistem tidak menampilkan tombol "Hitung Ulang Kontainer"
      And sistem tidak menampilkan tombol "Visualisasi Terbaru"

    @negative @priority-medium @REQ-031 @VAL-08 @screen-daftar-order @OMS014-NEG-019
    Skenario: Daftar Order tidak memuat kolom atau badge hasil Auto Stuffing
      Given user berada di halaman "Daftar Order"
      When user memeriksa header dan baris tabel order
      Then sistem tidak menampilkan kolom "Keterisian"
      And sistem tidak menampilkan badge "Stuffing"

    @negative @priority-high @REQ-030 @VAL-09 @AC-052 @screen-step4-review @OMS014-NEG-020
    Skenario: Data Barang pada Review tidak direorganisasi oleh sistem
      Given user telah menginput barang secara manual pada 2 armada di "Buat Order - Step 2 Data Barang"
      When user diarahkan ke halaman "Buat Order - Step 4 Review"
      Then sistem menampilkan unit, alamat, barang, dan jumlah yang identik dengan input manual Step 2

  # ==========================================================================
  Aturan: C. Daftar Order — Toolbar, Filter, Aksi Baris (REQ-028)
  # ==========================================================================

    @positive @priority-high @REQ-028 @screen-daftar-order @OMS014-POS-006
    Skenario: Halaman Daftar Order menampilkan toolbar lengkap
      Given user berada di halaman "Daftar Order"
      When halaman selesai dimuat
      Then sistem menampilkan "Daftar Order"
      And sistem menampilkan tombol "Buat Order"
      And sistem menampilkan tombol "Batch Order"
      And sistem menampilkan tombol "Riwayat Pembatalan"
      And sistem menampilkan tombol "Filter"

    @positive @priority-high @REQ-028 @VAL-31 @AC-048 @screen-daftar-order @OMS014-POS-007
    Skenario: Aksi baris pada order berstatus Ditugaskan sesuai matriks status
      Given user berada di halaman "Daftar Order"
      When user mengklik tombol "Aksi" pada baris order berstatus "Ditugaskan"
      Then sistem menampilkan "Detail"
      And sistem menampilkan "Lihat No. Perjalanan"
      And sistem menampilkan "Batalkan Order"
      And sistem menampilkan "Riwayat Perubahan"
      And sistem tidak menampilkan "Edit"

    @positive @priority-high @REQ-028 @VAL-31 @AC-048 @screen-daftar-order @OMS014-POS-008
    Skenario: Aksi baris pada order berstatus Menunggu Penugasan sesuai matriks status
      Given user berada di halaman "Daftar Order"
      When user mengklik tombol "Aksi" pada baris order berstatus "Menunggu Penugasan"
      Then sistem menampilkan "Detail"
      And sistem menampilkan "Edit"
      And sistem menampilkan "Batalkan Order"
      And sistem menampilkan "Riwayat Perubahan"
      And sistem tidak menampilkan "Lihat No. Perjalanan"

    @positive @priority-high @REQ-028 @VAL-31 @AC-048 @screen-daftar-order @OMS014-POS-009
    Skenario Konsep: Aksi baris pada order berstatus draft menampilkan Lanjutkan Pengisian
      Given user berada di halaman "Daftar Order"
      When user mengklik tombol "Aksi" pada baris order berstatus "<status>"
      Then sistem menampilkan "Detail"
      And sistem menampilkan "Lanjutkan Pengisian"
      And sistem menampilkan "Batalkan Order"
      And sistem menampilkan "Riwayat Perubahan"
      And sistem tidak menampilkan "Edit"

      Contoh:
        | status            |
        | Isi Data Dasar    |
        | Isi Data Muatan   |
        | Isi Data Vendor   |
        | Review Order      |

    @positive @priority-medium @REQ-028 @screen-daftar-order @OMS014-POS-010
    Skenario: Filter Daftar Order berdasarkan ID Order dan Status
      Given user berada di halaman "Daftar Order"
      When user mengklik tombol "Filter"
      And user mengisi field "ID Order" dengan "ORD769797FSH"
      And user memilih "Menunggu Penugasan" pada field "Status"
      And user mengklik tombol "Terapkan"
      Then sistem menampilkan baris order "ORD769797FSH"

    @positive @priority-low @REQ-028 @screen-daftar-order @OMS014-POS-011
    Skenario: Reset filter mengembalikan seluruh data order
      Given user berada di halaman "Daftar Order" dengan filter aktif
      When user mengklik tombol "Reset"
      Then sistem menampilkan seluruh data order tanpa filter
      And sistem menampilkan "Menampilkan 1 - 20 data dari 30 data"

    @positive @priority-medium @REQ-028 @screen-daftar-order @OMS014-POS-012
    Skenario: Membuka halaman Riwayat Pembatalan dari toolbar
      Given user berada di halaman "Daftar Order"
      When user mengklik tombol "Riwayat Pembatalan"
      Then user diarahkan ke halaman "Riwayat Pembatalan"
      And sistem menampilkan daftar order yang pernah dibatalkan

    @positive @priority-low @REQ-028 @screen-daftar-order @OMS014-POS-013
    Skenario: Mengubah jumlah data per halaman dan berpindah halaman
      Given user berada di halaman "Daftar Order"
      When user memilih "50" pada field "Tampilkan"
      And user mengklik tombol "2"
      Then sistem menampilkan halaman kedua daftar order

    @positive @priority-medium @REQ-023 @AC-039 @screen-daftar-order @OMS014-POS-014
    Skenario: Kolom status hanya memuat status order yang valid
      Given user berada di halaman "Daftar Order"
      When user memeriksa seluruh nilai badge status pada tabel
      Then sistem menampilkan hanya status "Isi Data Dasar, Isi Data Muatan, Isi Data Vendor, Review Order, Menunggu Penugasan, Ditugaskan, Proses Pengiriman, Terkirim, Dibatalkan"

    @positive @priority-low @REQ-009 @screen-daftar-order @OMS014-POS-015
    Skenario: Batch Order tetap tersedia saat Auto Stuffing nonaktif
      Given user berada di halaman "Daftar Order"
      When user mengklik tombol "Batch Order"
      Then sistem menampilkan "Batch Order"

    @positive @priority-medium @REQ-028 @screen-daftar-order @OMS014-POS-016
    Skenario: Tipe pengiriman multi ditampilkan sebagai text link pada kolom kota
      Given user berada di halaman "Daftar Order"
      When user memeriksa baris order bertipe "Multipickup"
      Then sistem menampilkan link "Multipickup" menggantikan nama kota asal

  # ==========================================================================
  Aturan: D. Step 1 — Data Pengiriman (REQ-009, REQ-010)
  # ==========================================================================

    @positive @priority-high @REQ-009 @VAL-11 @AC-009 @screen-step1 @OMS014-POS-017
    Skenario: Wizard order tetap terdiri dari 4 step
      Given user berada di halaman "Daftar Order"
      When user mengklik tombol "Buat Order"
      Then user diarahkan ke halaman "Buat Order - Step 1 Data Pengiriman"
      And sistem menampilkan "01 Data Pengiriman"
      And sistem menampilkan "02 Data Barang"
      And sistem menampilkan "03 Vendor dan Harga"
      And sistem menampilkan "04 Review"

    @positive @priority-high @REQ-001 @REQ-002 @REQ-010 @AC-002 @AC-010 @screen-step1 @OMS014-POS-018
    Skenario: Mengisi Step 1 order FTL tipe Normal secara lengkap
      Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
      When user memilih "FTL" pada field "Jenis Pengiriman"
      And user memilih "Tronton Wing Box" pada field "Jenis Armada"
      And user mengisi field "Jumlah Armada" dengan "2"
      And user memilih "Normal" pada field "Tipe Pengiriman"
      And user memilih "Gudang MSK Region 2" pada field "Drop Point Asal"
      And user mengisi field "PIC Pengirim" dengan "Andika"
      And user mengisi field "No. WhatsApp PIC" dengan "081234567898"
      And user memilih "Gudang Jaya Retail Malang" pada field "Drop Point Tujuan"
      And user mengisi field "PIC Penerima" dengan "Budi"
      And user mengklik tombol "Selanjutnya"
      Then user diarahkan ke halaman "Buat Order - Step 2 Data Barang"
      And sistem menampilkan card unit "Armada 1"
      And sistem menampilkan card unit "Armada 2"

    @positive @priority-high @REQ-002 @REQ-010 @AC-002 @AC-010 @screen-step1 @OMS014-POS-019
    Skenario: Mengisi Step 1 order FCL tipe Normal lengkap dengan pelabuhan
      Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
      When user memilih "FCL" pada field "Jenis Pengiriman"
      And user memilih "Tanjung Perak (SUB)" pada field "Pelabuhan Asal"
      And user memilih "Panjang (PNJ)" pada field "Pelabuhan Tujuan"
      And user memilih "20 DRY" pada field "Jenis Kontainer"
      And user mengisi field "Jumlah Kontainer" dengan "2"
      And user memilih "Normal" pada field "Tipe Pengiriman"
      And user melengkapi Data Pengirim dan Data Penerima
      And user mengklik tombol "Selanjutnya"
      Then user diarahkan ke halaman "Buat Order - Step 2 Data Barang"
      And sistem menampilkan card unit "Kontainer 1"
      And sistem menampilkan card unit "Kontainer 2"

    @positive @priority-high @REQ-010 @AC-012 @screen-step1 @OMS014-POS-020
    Skenario: Mengisi Step 1 FTL tipe Multipickup dengan 2 alamat pengirim
      Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
      When user memilih "Multipickup" pada field "Tipe Pengiriman"
      Then sistem menampilkan "Pastikan urutan pengiriman sudah sesuai saat membuat shipment"
      And sistem menampilkan "Pick Up 1"
      When user mengklik tombol "Tambah Baris Input"
      And user melengkapi alamat pada "Pick Up 2"
      And user mengklik tombol "Selanjutnya"
      Then user diarahkan ke halaman "Buat Order - Step 2 Data Barang"

    @positive @priority-high @REQ-010 @AC-012 @screen-step1 @OMS014-POS-021
    Skenario: Mengisi Step 1 FTL tipe Multidrop dengan 2 alamat penerima
      Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
      When user memilih "Multidrop" pada field "Tipe Pengiriman"
      And user mengklik tombol "Tambah Baris Input" pada kartu "Data Penerima"
      And user melengkapi alamat pada "Drop Off 2"
      And user mengklik tombol "Selanjutnya"
      Then user diarahkan ke halaman "Buat Order - Step 2 Data Barang"
      And sistem menampilkan 2 kombinasi alamat pada card "Armada 1"

    @positive @priority-high @REQ-010 @AC-012 @screen-step1 @OMS014-POS-022
    Skenario: Mengisi Step 1 FTL tipe Multipoint dengan 2 pengirim dan 2 penerima
      Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
      When user memilih "Multipoint" pada field "Tipe Pengiriman"
      And user menambahkan baris "Pick Up 2" dan "Drop Off 2"
      And user mengklik tombol "Selanjutnya"
      Then user diarahkan ke halaman "Buat Order - Step 2 Data Barang"
      And sistem menampilkan 4 kombinasi alamat pada card "Armada 1"

    @positive @priority-medium @REQ-010 @AC-010 @screen-step1 @OMS014-POS-023
    Skenario: FCL tipe Multidrop menampilkan pilihan Metode Pengiriman
      Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
      When user memilih "FCL" pada field "Jenis Pengiriman"
      And user memilih "Multidrop" pada field "Tipe Pengiriman"
      Then sistem menampilkan "Metode Pengiriman"
      And sistem menampilkan pilihan "Door to Door"
      And sistem menampilkan pilihan "Door to CY"
      And sistem menampilkan pilihan "CY to CY"
      And sistem menampilkan pilihan "CY to Door"

    @positive @priority-high @REQ-010 @AC-011 @screen-step1 @OMS014-POS-024
    Skenario: Data alamat ter-auto-draft dari Master Droppoint dengan cascading wilayah
      Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
      When user memilih "Gudang MSK Region 2" pada field "Drop Point Asal"
      Then sistem menampilkan field "Provinsi Asal" terisi "Jawa Timur"
      And sistem menampilkan field "Kota/Kab. Asal" terisi "Kota Surabaya"
      And sistem menampilkan field "Alamat Asal" terisi otomatis dan read-only

    @positive @priority-medium @REQ-010 @screen-step1 @OMS014-POS-025
    Skenario: Menghapus baris alamat tambahan pada tipe Multipickup
      Given user berada di halaman "Buat Order - Step 1 Data Pengiriman" dengan 3 baris Pick Up
      When user mengklik tombol "Hapus" pada "Pick Up 3"
      Then sistem menampilkan hanya "Pick Up 1" dan "Pick Up 2"

    @positive @priority-high @REQ-024 @VAL-27 @AC-040 @screen-step1 @OMS014-POS-026
    Skenario: Simpan ke Draf pada Step 1 menghasilkan status Isi Data Dasar
      Given user berada di halaman "Buat Order - Step 1 Data Pengiriman" dengan data terisi sebagian
      When user mengklik tombol "Simpan ke Draf"
      Then sistem menampilkan "Order berhasil disimpan sebagai draf"
      And user diarahkan ke halaman "Daftar Order"
      And sistem menampilkan badge status "Isi Data Dasar"

    @negative @priority-high @REQ-022 @AC-036 @screen-step1 @OMS014-NEG-021
    Skenario: Tombol Selanjutnya disabled sebelum Tipe Pengiriman dipilih
      Given user berada di halaman "Buat Order - Step 1 Data Pengiriman" dalam kondisi default
      When user memeriksa tombol "Selanjutnya"
      Then sistem menampilkan tombol "Selanjutnya" dalam kondisi disabled
      And sistem tidak menampilkan kartu "Data Pengirim"

    @negative @priority-high @REQ-022 @AC-036 @screen-step1 @OMS014-NEG-022
    Skenario: Navigasi diblokir saat field wajib Step 1 kosong
      Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
      When user memilih "Normal" pada field "Tipe Pengiriman"
      And user mengosongkan field "Jenis Armada"
      And user mengosongkan field "Jumlah Armada"
      And user mengklik tombol "Selanjutnya"
      Then sistem menampilkan "Wajib diisi" pada field "Jenis Armada"
      And sistem menampilkan "Wajib diisi" pada field "Jumlah Armada"
      And user tetap berada di halaman "Buat Order - Step 1 Data Pengiriman"

    @negative @priority-high @REQ-010 @screen-step1 @OMS014-NEG-023
    Skenario Konsep: Jumlah Armada dengan nilai tidak valid ditolak
      Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
      When user mengisi field "Jumlah Armada" dengan "<nilai>"
      And user mengklik tombol "Selanjutnya"
      Then sistem menampilkan pesan validasi pada field "Jumlah Armada"
      And user tetap berada di halaman "Buat Order - Step 1 Data Pengiriman"

      Contoh:
        | nilai |
        | 0     |
        | -1    |
        | 1,5   |
        | abc   |

    @negative @priority-high @REQ-010 @screen-step1 @OMS014-NEG-024
    Skenario: Pelabuhan Asal sama dengan Pelabuhan Tujuan ditolak pada FCL
      Given user berada di halaman "Buat Order - Step 1 Data Pengiriman" untuk order "FCL"
      When user memilih "Tanjung Perak (SUB)" pada field "Pelabuhan Asal"
      And user memilih "Tanjung Perak (SUB)" pada field "Pelabuhan Tujuan"
      And user mengklik tombol "Selanjutnya"
      Then sistem menampilkan "Pelabuhan Tujuan tidak boleh sama dengan Pelabuhan Asal"
      And user tetap berada di halaman "Buat Order - Step 1 Data Pengiriman"

    @negative @priority-high @REQ-010 @AC-012 @screen-step1 @OMS014-NEG-025
    Skenario Konsep: Jumlah baris alamat kurang dari minimal untuk tipe multi ditolak
      Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
      When user memilih "<tipe>" pada field "Tipe Pengiriman"
      And user hanya mengisi "<jumlahBaris>" baris alamat pada sisi "<sisi>"
      And user mengklik tombol "Selanjutnya"
      Then sistem menampilkan "Minimal 2 baris alamat untuk tipe pengiriman ini"
      And user tetap berada di halaman "Buat Order - Step 1 Data Pengiriman"

      Contoh:
        | tipe        | sisi      | jumlahBaris |
        | Multipickup | Pengirim  | 1           |
        | Multidrop   | Penerima  | 1           |
        | Multipoint  | Pengirim  | 1           |
        | Multipoint  | Penerima  | 1           |

    @negative @priority-medium @REQ-010 @screen-step1 @OMS014-NEG-026
    Skenario: Nomor WhatsApp PIC dengan format salah ditolak
      Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
      When user mengisi field "No. WhatsApp PIC" dengan "abcd-efgh"
      And user mengklik tombol "Selanjutnya"
      Then sistem menampilkan pesan validasi pada field "No. WhatsApp PIC"

    @negative @priority-medium @REQ-010 @ASM-036 @screen-step1 @OMS014-NEG-027
    Skenario: FCL tipe Normal tidak menampilkan Metode Pengiriman
      Given user berada di halaman "Buat Order - Step 1 Data Pengiriman" untuk order "FCL"
      When user memilih "Normal" pada field "Tipe Pengiriman"
      Then sistem tidak menampilkan "Metode Pengiriman"

    @negative @priority-medium @REQ-010 @screen-step1 @OMS014-NEG-028
    Skenario: Field wilayah hasil auto-draft tidak dapat diketik manual
      Given user berada di halaman "Buat Order - Step 1 Data Pengiriman" dengan Drop Point Asal terisi
      When user mencoba mengisi field "Provinsi Asal" dengan "Bali"
      Then sistem menampilkan field "Provinsi Asal" dalam kondisi read-only
      And sistem menampilkan nilai "Jawa Timur" tidak berubah

  # ==========================================================================
  Aturan: E. Step 2 — Data Barang & Modal Pilih Barang (REQ-011..REQ-019)
  # ==========================================================================

    @positive @priority-high @REQ-011 @VAL-M2 @AC-014 @screen-modal-pilih-barang @OMS014-POS-027
    Skenario: Mencari barang pada modal Pilih Barang berdasarkan kode SKU
      Given user berada di halaman "Buat Order - Step 2 Data Barang"
      When user mengklik tombol "Pilih Barang" pada card "Armada 1"
      Then sistem menampilkan "Pilih Barang"
      When user mengisi field "Cari kode/nama barang" dengan "SKU-PPR"
      Then sistem menampilkan "SKU-PPR-001 - Kertas HVS A4 80 gsm"
      And sistem menampilkan "SKU-PPR-002 - Kertas HVS F4 70 gsm"

    @positive @priority-high @REQ-011 @VAL-M2 @AC-014 @screen-modal-pilih-barang @OMS014-POS-028
    Skenario: Mencari barang pada modal Pilih Barang berdasarkan nama barang
      Given user berada di halaman "Modal Pilih Barang"
      When user mengisi field "Cari kode/nama barang" dengan "Buku Tulis"
      Then sistem menampilkan "SKU-BKU-001 - Buku Tulis 38 Lembar"
      And sistem menampilkan "SKU-BKU-002 - Buku Tulis Hard Cover A5"

    @positive @priority-high @REQ-011 @VAL-M3 @VAL-M5 @AC-015 @screen-modal-pilih-barang @OMS014-POS-029
    Skenario: Multi-select barang memperbarui counter jumlah barang terpilih
      Given user berada di halaman "Modal Pilih Barang"
      When user mencentang barang "SKU-PPR-001"
      And user mencentang barang "SKU-PPR-002"
      And user mencentang barang "SKU-BKU-001"
      Then sistem menampilkan "3 barang terpilih"

    @positive @priority-high @REQ-011 @REQ-008 @VAL-M6 @VAL-M7 @AC-017 @screen-modal-pilih-barang @OMS014-POS-030
    Skenario: Simpan pada modal memasukkan barang hanya ke unit tempat modal dibuka
      Given user berada di halaman "Buat Order - Step 2 Data Barang" dengan 2 armada
      When user mengklik tombol "Pilih Barang" pada card "Armada 2"
      And user mencentang barang "SKU-ATK-001"
      And user mengklik tombol "Simpan"
      Then sistem menampilkan baris barang "SKU-ATK-001" pada card "Armada 2"
      And sistem tidak menampilkan baris barang "SKU-ATK-001" pada card "Armada 1"

    @positive @priority-medium @REQ-011 @VAL-M4 @AC-016 @screen-modal-pilih-barang @OMS014-POS-031
    Skenario: Barang yang sudah masuk unit menampilkan label Sudah Ditambahkan
      Given user telah menambahkan barang "SKU-PPR-002" pada card "Armada 1"
      When user mengklik tombol "Pilih Barang" pada card "Armada 1"
      Then sistem menampilkan "Sudah Ditambahkan" pada item "SKU-PPR-002"

    @positive @priority-high @REQ-012 @REQ-013 @AC-018 @screen-step2 @OMS014-POS-032
    Skenario: Field barang ter-draft read-only dari Master Barang dan Jumlah diisi user
      Given user berada di halaman "Buat Order - Step 2 Data Barang" dengan barang "SKU-PPR-001" pada "Armada 1"
      When user memeriksa baris barang "SKU-PPR-001"
      Then sistem menampilkan "Kertas HVS A4 80 gsm"
      And sistem menampilkan "Dus"
      And sistem menampilkan "0,018 m³"
      And sistem menampilkan "31 × 22 × 26,4 cm"
      And sistem menampilkan "12,5 kg"
      When user mengisi field "Jumlah" dengan "200"
      And user mengklik tombol "Selanjutnya"
      Then user diarahkan ke halaman "Buat Order - Step 3 Vendor dan Harga"

    @positive @priority-high @REQ-014 @VAL-16 @AC-021 @screen-step2 @OMS014-POS-033
    Skenario: Mencentang Tambahkan Asuransi menampilkan kolom Nilai Barang untuk seluruh barang pada unit
      Given user berada di halaman "Buat Order - Step 2 Data Barang" dengan 3 barang pada "Armada 1"
      When user mencentang "Tambahkan Asuransi" pada card "Armada 1"
      Then sistem menampilkan kolom "Nilai Barang" pada card "Armada 1"
      And sistem menampilkan input "Nilai Barang" pada seluruh 3 baris barang
      And sistem menampilkan "Berlaku untuk seluruh barang pada armada ini"

    @positive @priority-high @REQ-014 @REQ-018 @screen-step2 @OMS014-POS-034
    Skenario: Mengisi Nilai Barang pada unit yang diasuransikan lalu lanjut ke Step 3
      Given user berada di halaman "Buat Order - Step 2 Data Barang" dengan asuransi aktif pada "Armada 1"
      When user mengisi field "Nilai Barang" dengan "365000"
      And user mengisi field "Jumlah" dengan "200"
      And user mengklik tombol "Selanjutnya"
      Then user diarahkan ke halaman "Buat Order - Step 3 Vendor dan Harga"

    @positive @priority-high @REQ-015 @VAL-17 @AC-022 @screen-step2 @OMS014-POS-035
    Skenario: Nomor DO multi-nilai dipisahkan koma dirender sebagai chip
      Given user berada di halaman "Buat Order - Step 2 Data Barang"
      When user mengisi field "Nomor DO" dengan "TGK783898202U,TBL28371302"
      Then sistem menampilkan chip "TGK783898202U"
      And sistem menampilkan chip "TBL28371302"

    @positive @priority-medium @REQ-015 @VAL-17 @AC-022 @screen-step2 @OMS014-POS-036
    Skenario: Nomor DO dikosongkan tetap dapat lanjut ke step berikutnya
      Given user berada di halaman "Buat Order - Step 2 Data Barang" dengan seluruh Jumlah terisi
      When user mengosongkan field "Nomor DO"
      And user mengklik tombol "Selanjutnya"
      Then user diarahkan ke halaman "Buat Order - Step 3 Vendor dan Harga"

    @positive @priority-high @REQ-016 @VAL-18 @AC-023 @screen-step2 @OMS014-POS-037
    Skenario: Menghapus baris barang memperbarui total kubikasi dan berat unit
      Given user berada di halaman "Buat Order - Step 2 Data Barang" dengan 3 baris barang pada "Armada 1"
      When user mengklik tombol "Hapus" pada baris barang "SKU-BKU-001"
      Then sistem tidak menampilkan baris barang "SKU-BKU-001"
      And sistem menampilkan "Total Kubikasi" dengan nilai yang berkurang
      And sistem menampilkan "Total Berat" dengan nilai yang berkurang

    @positive @priority-high @REQ-019 @VAL-22 @AC-029 @screen-step2 @OMS014-POS-038
    Skenario: Informasi Data Unit pada Step 2 konsisten dengan Step 1
      Given user telah mengisi "Jumlah Armada" dengan "3" dan "Jenis Armada" dengan "Tronton Wing Box" pada Step 1
      When user diarahkan ke halaman "Buat Order - Step 2 Data Barang"
      Then sistem menampilkan card unit "Armada 1"
      And sistem menampilkan card unit "Armada 2"
      And sistem menampilkan card unit "Armada 3"

    @positive @priority-high @REQ-017 @VAL-20 @AC-024 @screen-step2 @OMS014-POS-039
    Skenario: Alert informatif tampil saat kubikasi melebihi kapasitas armada
      Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk armada berkapasitas "17,86 m³"
      When user mengisi Jumlah barang sehingga total kubikasi menjadi "19,2 m³"
      Then sistem menampilkan "Kubikasi melebihi kapasitas armada"
      And sistem menampilkan "Total Kubikasi: 19,2 / 17,86 m³"

    @positive @priority-high @REQ-017 @VAL-20 @AC-025 @screen-step2 @OMS014-POS-040
    Skenario: Alert informatif tampil saat berat melebihi kapasitas armada
      Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk armada berkapasitas "24.800 kg"
      When user mengisi Jumlah barang sehingga total berat menjadi "26.000 kg"
      Then sistem menampilkan "Berat melebihi kapasitas armada"

    @positive @priority-medium @REQ-017 @VAL-20 @AC-026 @screen-step2 @OMS014-POS-041
    Skenario: Alert gabungan tampil saat kubikasi dan berat melebihi kapasitas
      Given user berada di halaman "Buat Order - Step 2 Data Barang"
      When user mengisi Jumlah barang sehingga kubikasi dan berat melebihi kapasitas
      Then sistem menampilkan "Kubikasi dan Berat melebihi kapasitas armada"

    @positive @priority-high @REQ-017 @VAL-19 @AC-027 @screen-step2 @OMS014-POS-042
    Skenario: Alert kapasitas bersifat informatif dan tidak memblokir navigasi
      Given user berada di halaman "Buat Order - Step 2 Data Barang" dengan alert kapasitas tampil
      When user mengklik tombol "Selanjutnya"
      Then user diarahkan ke halaman "Buat Order - Step 3 Vendor dan Harga"

    @positive @priority-high @REQ-008 @VAL-06 @AC-008 @screen-step2 @OMS014-POS-043
    Skenario: Pengisian barang manual dan independen untuk setiap armada
      Given user berada di halaman "Buat Order - Step 2 Data Barang" dengan 3 armada
      When user menambahkan barang "SKU-PPR-001" dengan Jumlah "100" pada "Armada 1"
      And user menambahkan barang "SKU-BKU-001" dengan Jumlah "50" pada "Armada 2"
      And user menambahkan barang "SKU-ATK-001" dengan Jumlah "25" pada "Armada 3"
      Then sistem menampilkan komposisi barang berbeda pada masing-masing armada sesuai input manual

    @positive @priority-high @REQ-008 @VAL-06 @VAL-M7 @AC-008 @screen-step2 @OMS014-POS-044
    Skenario: Pengisian barang manual per kombinasi alamat pada tipe Multipickup
      Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk tipe "Multipickup"
      When user mengklik tombol "Pilih Barang" pada kombinasi "Pick Up 1"
      And user mencentang barang "SKU-PPR-001" lalu mengklik tombol "Simpan"
      And user mengisi field "Jumlah" dengan "80" pada kombinasi "Pick Up 1"
      And user mengklik tombol "Pilih Barang" pada kombinasi "Pick Up 2"
      And user mencentang barang "SKU-BKU-002" lalu mengklik tombol "Simpan"
      And user mengisi field "Jumlah" dengan "40" pada kombinasi "Pick Up 2"
      Then sistem menampilkan barang berbeda pada tiap kombinasi alamat sesuai input manual

    @positive @priority-high @REQ-008 @VAL-06 @AC-008 @screen-step2 @OMS014-POS-045
    Skenario: Pengisian barang manual pada 4 kombinasi alamat tipe Multipoint
      Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk tipe "Multipoint" 2x2
      When user mengisi barang secara manual pada seluruh 4 kombinasi alamat card "Armada 1"
      And user mengklik tombol "Selanjutnya"
      Then user diarahkan ke halaman "Buat Order - Step 3 Vendor dan Harga"

    @positive @priority-medium @REQ-022 @REQ-006 @screen-step2 @OMS014-POS-046
    Skenario: Tombol Sebelumnya mengembalikan ke Step 1 tanpa rekomputasi penempatan barang
      Given user berada di halaman "Buat Order - Step 2 Data Barang" dengan data barang terisi
      When user mengklik tombol "Sebelumnya"
      Then user diarahkan ke halaman "Buat Order - Step 1 Data Pengiriman"
      And sistem menampilkan seluruh data Step 1 tetap tersimpan

    @positive @priority-high @REQ-024 @VAL-27 @AC-040 @screen-step2 @OMS014-POS-047
    Skenario: Simpan ke Draf pada Step 2 menghasilkan status Isi Data Muatan
      Given user berada di halaman "Buat Order - Step 2 Data Barang"
      When user mengklik tombol "Simpan ke Draf"
      Then user diarahkan ke halaman "Daftar Order"
      And sistem menampilkan badge status "Isi Data Muatan"

    @positive @priority-medium @REQ-011 @VAL-M6 @AC-017 @screen-modal-pilih-barang @OMS014-POS-048
    Skenario: Tombol Batal pada modal Pilih Barang menutup modal tanpa menambahkan barang
      Given user berada di halaman "Modal Pilih Barang"
      When user mencentang barang "SKU-BKU-002"
      And user mengklik tombol "Batal"
      Then sistem menutup "Pilih Barang"
      And sistem tidak menampilkan baris barang "SKU-BKU-002" pada card "Armada 1"

    @positive @priority-medium @REQ-002 @AC-002 @screen-step2 @OMS014-POS-049
    Skenario: Order FCL menampilkan card unit dengan satuan Kontainer
      Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk order "FCL" dengan 3 kontainer
      When halaman selesai dimuat
      Then sistem menampilkan card unit "Kontainer 1"
      And sistem menampilkan card unit "Kontainer 2"
      And sistem menampilkan card unit "Kontainer 3"

    @negative @priority-high @REQ-013 @REQ-018 @VAL-14 @AC-019 @screen-step2 @OMS014-NEG-029
    Skenario: Field Jumlah kosong menampilkan helper error dan memblokir navigasi
      Given user berada di halaman "Buat Order - Step 2 Data Barang" dengan barang terpilih
      When user mengosongkan field "Jumlah"
      And user mengklik tombol "Selanjutnya"
      Then sistem menampilkan "Jumlah harus diisi"
      And sistem menampilkan border error pada field "Jumlah"
      And user tetap berada di halaman "Buat Order - Step 2 Data Barang"

    @negative @priority-high @REQ-013 @VAL-14 @screen-step2 @OMS014-NEG-030
    Skenario Konsep: Field Jumlah dengan nilai tidak valid ditolak
      Given user berada di halaman "Buat Order - Step 2 Data Barang" dengan barang terpilih
      When user mengisi field "Jumlah" dengan "<nilai>"
      And user mengklik tombol "Selanjutnya"
      Then sistem menampilkan pesan validasi pada field "Jumlah"
      And user tetap berada di halaman "Buat Order - Step 2 Data Barang"

      Contoh:
        | nilai   |
        | 0       |
        | -5      |
        | 2,5     |
        | abc     |
        |         |

    @negative @priority-high @REQ-014 @REQ-018 @VAL-15 @screen-step2 @OMS014-NEG-031
    Skenario: Nilai Barang kosong saat asuransi aktif memblokir navigasi
      Given user berada di halaman "Buat Order - Step 2 Data Barang" dengan "Tambahkan Asuransi" tercentang pada "Armada 1"
      When user mengosongkan field "Nilai Barang"
      And user mengklik tombol "Selanjutnya"
      Then sistem menampilkan "Nilai Barang harus diisi"
      And sistem menampilkan border error pada field "Nilai Barang"
      And user tetap berada di halaman "Buat Order - Step 2 Data Barang"

    @negative @priority-medium @REQ-014 @VAL-15 @screen-step2 @OMS014-NEG-032
    Skenario: Nilai Barang bernilai nol ditolak saat asuransi aktif
      Given user berada di halaman "Buat Order - Step 2 Data Barang" dengan asuransi aktif
      When user mengisi field "Nilai Barang" dengan "0"
      And user mengklik tombol "Selanjutnya"
      Then sistem menampilkan pesan validasi pada field "Nilai Barang"

    @negative @priority-high @REQ-014 @VAL-15 @AC-020 @screen-step2 @OMS014-NEG-033
    Skenario: Kolom Nilai Barang tidak tampil dan tidak divalidasi saat asuransi tidak aktif
      Given user berada di halaman "Buat Order - Step 2 Data Barang" dengan "Tambahkan Asuransi" tidak tercentang pada "Armada 2"
      When user memeriksa tabel barang pada card "Armada 2"
      Then sistem tidak menampilkan kolom "Nilai Barang"
      When user mengisi field "Jumlah" dengan "50" dan mengklik tombol "Selanjutnya"
      Then user diarahkan ke halaman "Buat Order - Step 3 Vendor dan Harga"

    @negative @priority-high @REQ-012 @VAL-13 @AC-018 @screen-step2 @OMS014-NEG-034
    Skenario Konsep: Field barang hasil draft Master Barang tidak dapat diedit
      Given user berada di halaman "Buat Order - Step 2 Data Barang" dengan barang "SKU-PPR-001"
      When user mencoba mengubah nilai kolom "<kolom>"
      Then sistem menampilkan kolom "<kolom>" dalam kondisi read-only

      Contoh:
        | kolom       |
        | Kode SKU    |
        | Nama Barang |
        | Kemasan     |
        | Kubikasi    |
        | Dimensi     |
        | Berat       |

    @negative @priority-high @REQ-011 @VAL-12 @AC-013 @screen-step2 @OMS014-NEG-035
    Skenario: Tidak tersedia input deskripsi barang manual pada Step 2
      Given user berada di halaman "Buat Order - Step 2 Data Barang"
      When user memeriksa area data barang pada card "Armada 1"
      Then sistem tidak menampilkan field "Deskripsi Barang"
      And sistem tidak menampilkan tombol "Tambah Barang Manual"
      And sistem menampilkan tombol "Pilih Barang"

    @negative @priority-high @REQ-013 @ASM-017 @screen-step2 @OMS014-NEG-036
    Skenario: Armada tanpa barang tidak dapat lanjut ke Step 3
      Given user berada di halaman "Buat Order - Step 2 Data Barang" dengan "Armada 3" tanpa barang
      When user mengklik tombol "Selanjutnya"
      Then sistem menampilkan "Belum ada barang. Klik \"Pilih Barang \"" pada card "Armada 3"
      And sistem menampilkan pesan validasi minimal 1 barang per armada
      And user tetap berada di halaman "Buat Order - Step 2 Data Barang"

    @negative @priority-medium @REQ-008 @ASM-017 @screen-step2 @OMS014-NEG-037
    Skenario: Kombinasi alamat tanpa barang pada tipe Multipoint tidak dapat lanjut
      Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk tipe "Multipoint" dengan 1 kombinasi kosong
      When user mengklik tombol "Selanjutnya"
      Then sistem menampilkan pesan validasi pada kombinasi alamat yang kosong
      And user tetap berada di halaman "Buat Order - Step 2 Data Barang"

    @negative @priority-medium @REQ-019 @VAL-22 @AC-030 @screen-step2 @OMS014-NEG-038
    Skenario: Informasi Data Unit pada Step 2 tidak dapat diubah dan tidak menyediakan hitung ulang
      Given user berada di halaman "Buat Order - Step 2 Data Barang"
      When user mencoba mengubah jumlah unit dari Step 2
      Then sistem tidak menampilkan input "Jumlah Armada" pada Step 2
      And sistem tidak menampilkan tombol "Hitung Ulang Armada"

    @negative @priority-low @REQ-011 @VAL-M2 @screen-modal-pilih-barang @OMS014-NEG-039
    Skenario: Pencarian barang tanpa hasil menampilkan empty state
      Given user berada di halaman "Modal Pilih Barang"
      When user mengisi field "Cari kode/nama barang" dengan "SKU-TIDAK-ADA"
      Then sistem menampilkan "Data tidak ditemukan"
      And sistem menampilkan "0 barang terpilih"

    @negative @priority-medium @REQ-011 @VAL-M1 @screen-modal-pilih-barang @OMS014-NEG-040
    Skenario: Barang berstatus nonaktif tidak muncul pada modal Pilih Barang
      Given terdapat barang "SKU-OFF-001" berstatus "Nonaktif" pada Master Barang
      When user berada di halaman "Modal Pilih Barang"
      And user mengisi field "Cari kode/nama barang" dengan "SKU-OFF-001"
      Then sistem menampilkan "Data tidak ditemukan"

    @negative @priority-medium @REQ-008 @VAL-M7 @screen-step2 @OMS014-NEG-041
    Skenario: Barang yang dipilih untuk unit tertentu tidak muncul otomatis pada unit lain
      Given user berada di halaman "Buat Order - Step 2 Data Barang" dengan 2 armada
      When user menambahkan barang "SKU-PPR-002" pada card "Armada 1"
      And user membuka modal "Pilih Barang" pada card "Armada 2"
      Then sistem tidak menampilkan "Sudah Ditambahkan" pada item "SKU-PPR-002"

  # ==========================================================================
  Aturan: F. Step 3 — Vendor dan Harga (REQ-020, REQ-021)
  # ==========================================================================

    @positive @priority-high @REQ-020 @AC-031 @AC-032 @VAL-24 @screen-step3 @OMS014-POS-050
    Skenario: Step 3 FTL dengan rute belum ada di master menampilkan input Waktu Perjalanan
      Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga" untuk order "FTL"
      When user memilih "PT Logistik Transportasi Nusantara" pada field "Vendor"
      And user mengisi field "Tanggal Permintaan Muat" dengan "24/07/2026 14:30"
      Then sistem menampilkan "Rute belum ada di Master Waktu Perjalanan. Isi waktu perjalanan, nilainya akan otomatis tersimpan sebagai data master baru."
      When user mengisi field "Waktu Perjalanan" dengan "8"
      And user mengisi field "Harga" dengan "12000000"
      And user mengklik tombol "Selanjutnya"
      Then user diarahkan ke halaman "Buat Order - Step 4 Review"

    @positive @priority-high @REQ-020 @AC-032 @VAL-24 @screen-step3 @OMS014-POS-051
    Skenario: Step 3 FTL dengan rute sudah ada menampilkan Waktu Perjalanan text-only
      Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga" untuk rute yang sudah ada di master
      When halaman selesai dimuat
      Then sistem menampilkan "Waktu Perjalanan : 8 Jam"
      And sistem tidak menampilkan input "Waktu Perjalanan"

    @positive @priority-high @REQ-020 @AC-033 @VAL-24 @screen-step3 @OMS014-POS-052
    Skenario: Step 3 FCL tidak menampilkan Waktu Perjalanan sama sekali
      Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga" untuk order "FCL"
      When halaman selesai dimuat
      Then sistem tidak menampilkan "Waktu Perjalanan"
      And sistem menampilkan "Jenis Kontainer : 20 DRY"

    @positive @priority-medium @REQ-020 @AC-031 @screen-step3 @OMS014-POS-053
    Skenario: Mengaktifkan komponen harga menampilkan input PPN, PPh, dan Asuransi
      Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
      When user mencentang "Gunakan komponen harga"
      Then sistem menampilkan field "PPN"
      And sistem menampilkan field "PPh"
      And sistem menampilkan field "Asuransi"

    @positive @priority-high @REQ-021 @VAL-23 @AC-034 @screen-step3 @OMS014-POS-054
    Skenario: Komponen Asuransi dihitung dan ikut ke Total Harga saat ada unit diasuransikan
      Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga" dengan 1 unit diasuransikan
      When user mencentang "Gunakan komponen harga"
      And user mengisi field "PPN" dengan "1,1"
      And user mengisi field "PPh" dengan "2"
      And user mengisi field "Asuransi" dengan "0,2"
      Then sistem menampilkan "Asuransi (0,2%)"
      And sistem menampilkan "(Total Nilai Barang = Rp. 63.620.000)"
      And sistem menampilkan "Total Harga" yang mencakup PPN, PPh, dan Asuransi

    @positive @priority-high @REQ-021 @VAL-23 @AC-035 @screen-step3 @OMS014-POS-055
    Skenario: Komponen Asuransi tidak dihitung saat tidak ada unit diasuransikan
      Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga" tanpa unit diasuransikan
      When user memeriksa ringkasan harga
      Then sistem tidak menampilkan "Asuransi (0,2%)"
      And sistem menampilkan "Tanpa Asuransi" pada tabel ringkasan unit

    @positive @priority-medium @REQ-020 @screen-step3 @OMS014-POS-056
    Skenario: Membuka detail alamat multi melalui text link Lihat Detail
      Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga" untuk tipe "Multipickup"
      When user mengklik tombol "Lihat Detail" pada "Drop Point Asal"
      Then sistem menampilkan "Detail Multipickup"
      And sistem menampilkan "Pick Up 1 - Kota Surabaya"
      And sistem menampilkan "Pick Up 2 - Kota Malang"

    @positive @priority-medium @REQ-024 @VAL-27 @AC-040 @screen-step3 @OMS014-POS-057
    Skenario: Simpan ke Draf pada Step 3 menghasilkan status Isi Data Vendor
      Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
      When user mengklik tombol "Simpan ke Draf"
      Then user diarahkan ke halaman "Daftar Order"
      And sistem menampilkan badge status "Isi Data Vendor"

    @positive @priority-low @REQ-020 @screen-step3 @OMS014-POS-058
    Skenario: Tabel ringkasan unit pada Step 3 menampilkan total berat, kubikasi, dan nilai barang per unit
      Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
      When user memeriksa tabel ringkasan unit
      Then sistem menampilkan baris "Armada 1"
      And sistem menampilkan baris "Armada 2"
      And sistem menampilkan kolom "Total Berat"
      And sistem menampilkan kolom "Total Kubikasi"
      And sistem menampilkan kolom "Total Nilai Barang"

    @negative @priority-high @REQ-020 @REQ-022 @AC-036 @screen-step3 @OMS014-NEG-042
    Skenario: Vendor kosong memblokir navigasi ke Step 4
      Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
      When user mengosongkan field "Vendor"
      And user mengklik tombol "Selanjutnya"
      Then sistem menampilkan pesan validasi pada field "Vendor"
      And user tetap berada di halaman "Buat Order - Step 3 Vendor dan Harga"

    @negative @priority-high @REQ-020 @REQ-022 @screen-step3 @OMS014-NEG-043
    Skenario: Tanggal Permintaan Muat kosong memblokir navigasi ke Step 4
      Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
      When user mengosongkan field "Tanggal Permintaan Muat"
      And user mengklik tombol "Selanjutnya"
      Then sistem menampilkan pesan validasi pada field "Tanggal Permintaan Muat"

    @negative @priority-medium @REQ-020 @ASM-011 @screen-step3 @OMS014-NEG-044
    Skenario: Tanggal Permintaan Muat di masa lalu ditolak
      Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
      When user mengisi field "Tanggal Permintaan Muat" dengan "01/01/2020 08:00"
      And user mengklik tombol "Selanjutnya"
      Then sistem menampilkan pesan validasi tanggal tidak boleh di masa lalu

    @negative @priority-high @REQ-020 @screen-step3 @OMS014-NEG-045
    Skenario: Harga kosong memblokir navigasi ke Step 4
      Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
      When user mengosongkan field "Harga"
      And user mengklik tombol "Selanjutnya"
      Then sistem menampilkan pesan validasi pada field "Harga"

    @negative @priority-medium @REQ-020 @screen-step3 @OMS014-NEG-046
    Skenario: Harga bernilai negatif ditolak
      Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
      When user mengisi field "Harga" dengan "-1000"
      And user mengklik tombol "Selanjutnya"
      Then sistem menampilkan pesan validasi pada field "Harga"

    @negative @priority-medium @REQ-020 @AC-032 @screen-step3 @OMS014-NEG-047
    Skenario: Waktu Perjalanan kosong pada rute baru FTL memblokir navigasi
      Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga" dengan alert rute belum ada
      When user mengosongkan field "Waktu Perjalanan"
      And user mengklik tombol "Selanjutnya"
      Then sistem menampilkan pesan validasi pada field "Waktu Perjalanan"

    @negative @priority-medium @REQ-020 @VAL-24 @AC-033 @screen-step3 @OMS014-NEG-048
    Skenario: Order FCL tidak boleh memiliki input Waktu Perjalanan pada Step 3
      Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga" untuk order "FCL"
      When user memeriksa seluruh field pada kartu "Vendor dan Harga"
      Then sistem tidak menampilkan input "Waktu Perjalanan"
      And sistem tidak menampilkan teks "Waktu Perjalanan"

    @negative @priority-low @REQ-021 @screen-step3 @OMS014-NEG-049
    Skenario: Nilai persentase komponen harga di luar batas wajar ditolak
      Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga" dengan komponen harga aktif
      When user mengisi field "PPN" dengan "150"
      And user mengklik tombol "Selanjutnya"
      Then sistem menampilkan pesan validasi pada field "PPN"

  # ==========================================================================
  Aturan: G. Step 4 — Review & Simpan Order (REQ-022, REQ-029, REQ-030, REQ-032)
  # ==========================================================================

    @positive @priority-high @REQ-032 @VAL-25 @AC-054 @screen-step4-review @OMS014-POS-059
    Skenario: Review menampilkan seluruh data Step 1-3 secara read-only
      Given user berada di halaman "Buat Order - Step 4 Review"
      When halaman selesai dimuat
      Then sistem menampilkan "Jenis Pengiriman dan Rute"
      And sistem menampilkan "Data Pengirim"
      And sistem menampilkan "Data Penerima"
      And sistem menampilkan "Data Barang"
      And sistem menampilkan "Vendor dan Harga"
      And sistem menampilkan seluruh field dalam kondisi read-only

    @positive @priority-high @REQ-030 @VAL-09 @AC-052 @screen-step4-review @OMS014-POS-060
    Skenario: Data Barang pada Review identik dengan input manual Step 2
      Given user telah menginput "SKU-PPR-001" Jumlah "200" pada "Armada 1" dan "SKU-BKU-003" Jumlah "150" pada "Armada 2"
      When user diarahkan ke halaman "Buat Order - Step 4 Review"
      Then sistem menampilkan "SKU-PPR-001" dengan Jumlah "200" pada blok "Armada 1"
      And sistem menampilkan "SKU-BKU-003" dengan Jumlah "150" pada blok "Armada 2"

    @positive @priority-high @REQ-032 @VAL-25 @AC-054 @screen-step4-review @OMS014-POS-061
    Skenario: Label Diasuransikan hanya tampil pada unit yang diasuransikan
      Given user berada di halaman "Buat Order - Step 4 Review" dengan asuransi aktif pada "Armada 2"
      When user memeriksa blok unit pada kartu "Data Barang"
      Then sistem menampilkan "Diasuransikan" pada blok "Armada 2"
      And sistem tidak menampilkan "Diasuransikan" pada blok "Armada 1"
      And sistem menampilkan kolom "Nilai Barang" hanya pada blok "Armada 2"

    @positive @priority-high @REQ-022 @VAL-26 @AC-038 @screen-step4-review @OMS014-POS-062
    Skenario: Simpan pada Step 4 mengubah status order menjadi Menunggu Penugasan
      Given user berada di halaman "Buat Order - Step 4 Review" dengan seluruh data lengkap
      When user mengklik tombol "Simpan"
      Then sistem menampilkan "Order berhasil dibuat"
      And user diarahkan ke halaman "Daftar Order"
      And sistem menampilkan badge status "Menunggu Penugasan"

    @positive @priority-medium @REQ-030 @AC-052 @screen-step4-review @OMS014-POS-063
    Skenario: Review order tipe Multipoint menampilkan seluruh kombinasi alamat apa adanya
      Given user berada di halaman "Buat Order - Step 4 Review" untuk tipe "Multipoint" 2x2
      When user membuka kartu "Data Barang"
      Then sistem menampilkan 4 kombinasi alamat per unit sesuai input manual

    @positive @priority-medium @REQ-022 @screen-step4-review @OMS014-POS-064
    Skenario: Tombol Sebelumnya pada Step 4 mengembalikan ke Step 3 dengan data tetap
      Given user berada di halaman "Buat Order - Step 4 Review"
      When user mengklik tombol "Sebelumnya"
      Then user diarahkan ke halaman "Buat Order - Step 3 Vendor dan Harga"
      And sistem menampilkan seluruh data vendor dan harga tetap tersimpan

    @positive @priority-medium @REQ-022 @screen-step4-review @OMS014-POS-065
    Skenario: Tombol Batal pada wizard menampilkan pop up konfirmasi
      Given user berada di halaman "Buat Order - Step 4 Review"
      When user mengklik tombol "Batal"
      Then sistem menampilkan pop up konfirmasi pembatalan pengisian
      When user mengklik tombol "Ya"
      Then user diarahkan ke halaman "Daftar Order"

    @negative @priority-medium @REQ-032 @VAL-25 @screen-step4-review @OMS014-NEG-050
    Skenario: Field pada Step 4 Review tidak dapat diedit
      Given user berada di halaman "Buat Order - Step 4 Review"
      When user mencoba mengubah nilai "Jumlah" pada tabel barang
      Then sistem menampilkan tabel barang dalam kondisi read-only

    @negative @priority-medium @REQ-032 @screen-step4-review @OMS014-NEG-051
    Skenario: Badge Diasuransikan tidak muncul pada order tanpa asuransi
      Given user berada di halaman "Buat Order - Step 4 Review" tanpa unit diasuransikan
      When user memeriksa seluruh blok unit
      Then sistem tidak menampilkan "Diasuransikan"
      And sistem tidak menampilkan kolom "Nilai Barang"

  # ==========================================================================
  Aturan: H. Detail Order (REQ-031, REQ-032, REQ-028)
  # ==========================================================================

    @positive @priority-high @REQ-031 @REQ-032 @screen-detail-order @OMS014-POS-066
    Skenario: Detail Order menampilkan seluruh kartu data order
      Given user berada di halaman "Daftar Order"
      When user mengklik tombol "Aksi" pada baris order "ORD67890792"
      And user mengklik "Detail"
      Then user diarahkan ke halaman "Detail Order"
      And sistem menampilkan "ID Order : ORD67890792"
      And sistem menampilkan "Jenis Pengiriman dan Rute"
      And sistem menampilkan "Data Barang"
      And sistem menampilkan "Vendor dan Harga"

    @positive @priority-high @REQ-020 @AC-033 @screen-detail-order @OMS014-POS-067
    Skenario: Waktu Perjalanan FCL tampil pada Detail Order saat status Ditugaskan
      Given user berada di halaman "Detail Order" untuk order "FCL" berstatus "Ditugaskan"
      When user memeriksa kartu "Jenis Pengiriman dan Rute"
      Then sistem menampilkan "Waktu Perjalanan : 8 Jam"

    @positive @priority-medium @REQ-032 @screen-detail-order @OMS014-POS-068
    Skenario: Detail Order menampilkan label Diasuransikan dan Nilai Barang untuk unit terkait
      Given user berada di halaman "Detail Order" untuk order dengan asuransi pada "Kontainer 1"
      When user memeriksa kartu "Data Barang"
      Then sistem menampilkan "Diasuransikan" pada blok "Kontainer 1"
      And sistem menampilkan kolom "Nilai Barang" pada blok "Kontainer 1"

    @positive @priority-medium @REQ-030 @screen-detail-order @OMS014-POS-069
    Skenario: Detail Order tipe multi menampilkan seluruh kombinasi alamat sesuai input manual
      Given user berada di halaman "Detail Order" untuk order tipe "Multidrop"
      When user memeriksa kartu "Data Barang"
      Then sistem menampilkan seluruh kombinasi "Drop Off 1" dan "Drop Off 2" sesuai input manual

    @positive @priority-medium @REQ-028 @screen-detail-order @OMS014-POS-070
    Skenario: Detail Order menampilkan tombol aksi sesuai status Menunggu Penugasan
      Given user berada di halaman "Detail Order" untuk order berstatus "Menunggu Penugasan"
      When halaman selesai dimuat
      Then sistem menampilkan tombol "Batalkan Order"
      And sistem menampilkan tombol "Edit Order"

    @negative @priority-medium @REQ-025 @REQ-028 @screen-detail-order @OMS014-NEG-052
    Skenario: Tombol Edit Order tidak tampil pada Detail Order berstatus Ditugaskan
      Given user berada di halaman "Detail Order" untuk order berstatus "Ditugaskan"
      When halaman selesai dimuat
      Then sistem tidak menampilkan tombol "Edit Order"
      And sistem menampilkan tombol "Batalkan Order"

    @negative @priority-medium @REQ-020 @AC-033 @screen-detail-order @OMS014-NEG-053
    Skenario: Waktu Perjalanan FCL belum tampil sebelum status Ditugaskan
      Given user berada di halaman "Detail Order" untuk order "FCL" berstatus "Menunggu Penugasan"
      When user memeriksa kartu "Jenis Pengiriman dan Rute"
      Then sistem tidak menampilkan "Waktu Perjalanan"

  # ==========================================================================
  Aturan: I. Edit Order (REQ-025, REQ-026)
  # ==========================================================================

    @positive @priority-high @REQ-025 @REQ-026 @AC-041 @AC-043 @screen-edit-order @OMS014-POS-071
    Skenario: Mengedit order berstatus Menunggu Penugasan dan menyimpan dengan konfirmasi
      Given user berada di halaman "Daftar Order"
      When user mengklik tombol "Aksi" pada baris order berstatus "Menunggu Penugasan"
      And user mengklik "Edit"
      Then user diarahkan ke halaman "Edit Order"
      When user mengisi field "Jumlah Kontainer" dengan "3"
      And user mengklik tombol "Simpan"
      Then sistem menampilkan pop up konfirmasi
      When user mengklik tombol "Ya"
      Then sistem menampilkan "Perubahan berhasil disimpan"
      And user diarahkan ke halaman "Detail Order"

    @positive @priority-high @REQ-026 @VAL-28 @AC-042 @screen-edit-order @OMS014-POS-072
    Skenario: Field Jenis Pengiriman dan Tipe Pengiriman terkunci pada Edit Order
      Given user berada di halaman "Edit Order"
      When user memeriksa kartu "Jenis Pengiriman dan Rute"
      Then sistem menampilkan "Jenis Pengiriman : FCL (Full Container Load)" dalam kondisi read-only
      And sistem menampilkan "Tipe Pengiriman : Normal" dalam kondisi read-only
      And sistem menampilkan "Skema Pengiriman : Door to Door" dalam kondisi read-only
      And sistem menampilkan field "Jumlah Kontainer" dalam kondisi editable

    @positive @priority-medium @REQ-026 @REQ-008 @screen-edit-order @OMS014-POS-073
    Skenario: Mengubah Data Barang secara manual pada Edit Order
      Given user berada di halaman "Edit Order"
      When user membuka kartu "Data Barang - Kontainer 2"
      And user mengklik tombol "Pilih Barang"
      And user mencentang barang "SKU-ATK-001" lalu mengklik tombol "Simpan"
      And user mengisi field "Jumlah" dengan "75"
      Then sistem menampilkan baris barang "SKU-ATK-001" pada kartu "Data Barang - Kontainer 2"
      And sistem tidak memindahkan barang secara otomatis ke kontainer lain

    @positive @priority-medium @REQ-026 @VAL-29 @AC-043 @screen-edit-order @OMS014-POS-074
    Skenario: Tombol Batal pada Edit Order menampilkan pop up konfirmasi
      Given user berada di halaman "Edit Order" dengan perubahan belum disimpan
      When user mengklik tombol "Batal"
      Then sistem menampilkan pop up konfirmasi
      When user mengklik tombol "Ya"
      Then user diarahkan ke halaman "Detail Order"
      And sistem menampilkan data order tanpa perubahan

    @negative @priority-high @REQ-025 @VAL-28 @AC-041 @screen-daftar-order @OMS014-NEG-054
    Skenario: Aksi Edit tidak tersedia untuk order berstatus Ditugaskan
      Given user berada di halaman "Daftar Order"
      When user mengklik tombol "Aksi" pada baris order berstatus "Ditugaskan"
      Then sistem tidak menampilkan "Edit"

    @negative @priority-high @REQ-028 @AC-048 @screen-daftar-order @OMS014-NEG-055
    Skenario: Aksi Edit tidak tersedia untuk order berstatus draft
      Given user berada di halaman "Daftar Order"
      When user mengklik tombol "Aksi" pada baris order berstatus "Isi Data Muatan"
      Then sistem tidak menampilkan "Edit"
      And sistem menampilkan "Lanjutkan Pengisian"

    @negative @priority-high @REQ-026 @VAL-28 @screen-edit-order @OMS014-NEG-056
    Skenario: Jenis Pengiriman dan Tipe Pengiriman tidak dapat diubah pada Edit Order
      Given user berada di halaman "Edit Order"
      When user mencoba mengubah nilai "Tipe Pengiriman"
      Then sistem menampilkan "Tipe Pengiriman" dalam kondisi tidak editable
      When user mencoba mengubah nilai "Jenis Pengiriman"
      Then sistem menampilkan "Jenis Pengiriman" dalam kondisi tidak editable

    @negative @priority-high @REQ-025 @VAL-28 @screen-edit-order @OMS014-NEG-057
    Skenario: Membuka Edit Order via URL langsung untuk order Ditugaskan ditolak
      Given user berada di halaman "Daftar Order"
      When user membuka URL langsung "/order/ORD-20260607009/edit" untuk order berstatus "Ditugaskan"
      Then sistem menampilkan "Order tidak dapat diubah pada status ini"
      And user diarahkan ke halaman "Detail Order"

    @negative @priority-medium @REQ-026 @VAL-29 @screen-edit-order @OMS014-NEG-058
    Skenario: Menolak konfirmasi pada Edit Order tidak mengeksekusi penyimpanan
      Given user berada di halaman "Edit Order" dengan perubahan pada field "Jumlah Kontainer"
      When user mengklik tombol "Simpan"
      And user mengklik tombol "Tidak" pada pop up konfirmasi
      Then user tetap berada di halaman "Edit Order"
      And sistem tidak menyimpan perubahan

  # ==========================================================================
  Aturan: J. Pembatalan Order (REQ-027)
  # ==========================================================================

    @positive @priority-high @REQ-027 @VAL-30 @AC-046 @screen-popup-pembatalan @OMS014-POS-075
    Skenario: Membatalkan order berstatus Menunggu Penugasan dengan alasan pembatalan
      Given user berada di halaman "Daftar Order"
      When user mengklik tombol "Aksi" pada baris order berstatus "Menunggu Penugasan"
      And user mengklik "Batalkan Order"
      Then sistem menampilkan "Batalkan Order"
      When user mengisi field "Alasan Pembatalan" dengan "Perubahan rencana pengiriman dari customer"
      And user mengklik tombol "Batalkan Order"
      Then sistem menampilkan "Order berhasil dibatalkan"
      And sistem menampilkan badge status "Dibatalkan"

    @positive @priority-high @REQ-027 @AC-045 @screen-popup-pembatalan @OMS014-POS-076
    Skenario: Membatalkan order berstatus Ditugaskan masih diizinkan
      Given user berada di halaman "Daftar Order"
      When user mengklik tombol "Aksi" pada baris order berstatus "Ditugaskan"
      Then sistem menampilkan "Batalkan Order"
      When user mengklik "Batalkan Order"
      And user mengisi field "Alasan Pembatalan" dengan "Armada vendor bermasalah"
      And user mengklik tombol "Batalkan Order"
      Then sistem menampilkan badge status "Dibatalkan"

    @positive @priority-medium @REQ-028 @screen-daftar-order @OMS014-POS-077
    Skenario: Order yang dibatalkan muncul pada halaman Riwayat Pembatalan
      Given terdapat order berstatus "Dibatalkan"
      When user berada di halaman "Daftar Order"
      And user mengklik tombol "Riwayat Pembatalan"
      Then user diarahkan ke halaman "Riwayat Pembatalan"
      And sistem menampilkan order beserta alasan pembatalannya

    @negative @priority-high @REQ-027 @VAL-30 @AC-046 @screen-popup-pembatalan @OMS014-NEG-059
    Skenario: Alasan Pembatalan kosong ditolak
      Given user berada di halaman "Pop Up Pembatalan Order"
      When user mengosongkan field "Alasan Pembatalan"
      And user mengklik tombol "Batalkan Order"
      Then sistem menampilkan "Alasan Pembatalan wajib diisi"
      And sistem tidak mengubah status order

    @negative @priority-medium @REQ-027 @ASM-029 @screen-popup-pembatalan @OMS014-NEG-060
    Skenario: Alasan Pembatalan berisi spasi saja ditolak
      Given user berada di halaman "Pop Up Pembatalan Order"
      When user mengisi field "Alasan Pembatalan" dengan "     "
      And user mengklik tombol "Batalkan Order"
      Then sistem menampilkan "Alasan Pembatalan wajib diisi"

    @negative @priority-high @REQ-027 @VAL-30 @AC-045 @screen-daftar-order @OMS014-NEG-061
    Skenario Konsep: Aksi Batalkan Order tidak tersedia sejak status Proses Pengiriman
      Given user berada di halaman "Daftar Order"
      When user mengklik tombol "Aksi" pada baris order berstatus "<status>"
      Then sistem tidak menampilkan "Batalkan Order"

      Contoh:
        | status            |
        | Proses Pengiriman |
        | Terkirim          |
        | Dibatalkan        |

    @negative @priority-high @REQ-027 @VAL-30 @AC-047 @screen-daftar-order @OMS014-NEG-062
    Skenario: Vendor tidak memiliki akses membatalkan order
      Given user login sebagai "Vendor"
      When user berada di halaman "Daftar Order"
      And user mengklik tombol "Aksi" pada baris order berstatus "Ditugaskan"
      Then sistem tidak menampilkan "Batalkan Order"

  # ==========================================================================
  Aturan: K. No. Perjalanan (REQ-028)
  # ==========================================================================

    @positive @priority-high @REQ-028 @VAL-32 @AC-049 @AC-050 @screen-popup-no-perjalanan @OMS014-POS-078
    Skenario: Pop up Data No. Perjalanan menampilkan satu baris per unit
      Given terdapat order "FCL" dengan 2 kontainer berstatus "Ditugaskan"
      When user berada di halaman "Daftar Order"
      And user mengklik tombol "Aksi" pada baris order tersebut
      And user mengklik "Lihat No. Perjalanan"
      Then sistem menampilkan "Data No. Perjalanan"
      And sistem menampilkan "ID Order: ORD-20260607009"
      And sistem menampilkan 2 baris No. Perjalanan
      And sistem menampilkan "TVW67892231 • 40 DRY"

    @positive @priority-medium @REQ-028 @AC-050 @screen-popup-no-perjalanan @OMS014-POS-079
    Skenario: Icon copy menyalin No. Perjalanan ke clipboard
      Given user berada di halaman "Pop Up Data No. Perjalanan"
      When user mengklik tombol "Salin" pada baris "TRC79289802"
      Then sistem menampilkan "Nomor berhasil disalin"
      And clipboard berisi "TRC79289802"

    @positive @priority-high @REQ-028 @VAL-32 @AC-049 @screen-detail-order @OMS014-POS-080
    Skenario: Jumlah No. Perjalanan sama dengan jumlah unit yang dipesan dan bersifat unik
      Given terdapat order "FTL" dengan "5" armada berstatus "Ditugaskan"
      When user berada di halaman "Detail Order"
      Then sistem menampilkan 5 No. Perjalanan
      And seluruh No. Perjalanan bernilai unik

    @negative @priority-high @REQ-028 @VAL-32 @screen-daftar-order @OMS014-NEG-063
    Skenario: Aksi Lihat No. Perjalanan tidak tampil sebelum status Ditugaskan
      Given user berada di halaman "Daftar Order"
      When user mengklik tombol "Aksi" pada baris order berstatus "Menunggu Penugasan"
      Then sistem tidak menampilkan "Lihat No. Perjalanan"

    @negative @priority-medium @REQ-028 @VAL-32 @screen-daftar-order @OMS014-NEG-064
    Skenario: Order LTL dan LCL tidak memiliki aksi Lihat No. Perjalanan
      Given user berada di halaman "Daftar Order"
      When user mengklik tombol "Aksi" pada baris order berjenis "LTL" berstatus "Ditugaskan"
      Then sistem tidak menampilkan "Lihat No. Perjalanan"

    @negative @priority-low @REQ-028 @screen-popup-no-perjalanan @OMS014-NEG-065
    Skenario: Pop up No. Perjalanan tidak menampilkan elemen visualisasi muatan
      Given user berada di halaman "Pop Up Data No. Perjalanan"
      When user memeriksa isi modal
      Then sistem tidak menampilkan "Visualisasi Muatan"
      And sistem tidak menampilkan "Indikator Keterisian"

  # ==========================================================================
  Aturan: L. Status Order & Draft (REQ-023, REQ-024)
  # ==========================================================================

    @positive @priority-high @REQ-023 @REQ-024 @VAL-27 @AC-040 @screen-daftar-order @OMS014-POS-081
    Skenario Konsep: Simpan ke Draf pada setiap step menghasilkan status draft yang sesuai
      Given user berada di halaman "<layar>"
      When user mengklik tombol "Simpan ke Draf"
      Then user diarahkan ke halaman "Daftar Order"
      And sistem menampilkan badge status "<status>"

      Contoh:
        | layar                                    | status          |
        | Buat Order - Step 1 Data Pengiriman      | Isi Data Dasar  |
        | Buat Order - Step 2 Data Barang          | Isi Data Muatan |
        | Buat Order - Step 3 Vendor dan Harga     | Isi Data Vendor |
        | Buat Order - Step 4 Review               | Review Order    |

    @positive @priority-high @REQ-023 @screen-daftar-order @OMS014-POS-082
    Skenario: Transisi status order berjalan sesuai alur sistem
      Given order dibuat melalui wizard sampai Step 4 dan disimpan
      When vendor melakukan penugasan unit
      Then sistem menampilkan badge status "Ditugaskan"
      When pengiriman dimulai
      Then sistem menampilkan badge status "Proses Pengiriman"
      When pengiriman selesai
      Then sistem menampilkan badge status "Terkirim"

    @positive @priority-medium @REQ-024 @REQ-028 @screen-daftar-order @OMS014-POS-083
    Skenario: Melanjutkan pengisian order draft dari step terakhir
      Given terdapat order draft berstatus "Isi Data Muatan"
      When user mengklik tombol "Aksi" pada baris order tersebut
      And user mengklik "Lanjutkan Pengisian"
      Then user diarahkan ke halaman "Buat Order - Step 2 Data Barang"
      And sistem menampilkan seluruh data barang yang telah diisi sebelumnya

  # ==========================================================================
  Aturan: M. Edge Cases — Boundary, Kombinasi Langka, Karakter Spesial
  # ==========================================================================

    @edge @priority-medium @REQ-010 @ASM-010 @screen-step1 @OMS014-EDG-001
    Skenario: Jumlah Armada minimum satu menghasilkan satu card unit
      Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
      When user mengisi field "Jumlah Armada" dengan "1"
      And user mengklik tombol "Selanjutnya"
      Then sistem menampilkan card unit "Armada 1"
      And sistem tidak menampilkan card unit "Armada 2"

    @edge @priority-medium @REQ-010 @REQ-019 @screen-step2 @OMS014-EDG-002
    Skenario: Jumlah Armada besar menghasilkan card unit sebanyak nilai yang diinput
      Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
      When user mengisi field "Jumlah Armada" dengan "20"
      And user mengklik tombol "Selanjutnya"
      Then sistem menampilkan 20 card unit pada halaman "Buat Order - Step 2 Data Barang"
      And sistem tidak menampilkan tombol "Hitung Ulang Armada"

    @edge @priority-medium @REQ-013 @ASM-008 @screen-step2 @OMS014-EDG-003
    Skenario: Jumlah barang bernilai satu diterima sebagai batas bawah valid
      Given user berada di halaman "Buat Order - Step 2 Data Barang"
      When user mengisi field "Jumlah" dengan "1"
      And user mengklik tombol "Selanjutnya"
      Then user diarahkan ke halaman "Buat Order - Step 3 Vendor dan Harga"

    @edge @priority-low @REQ-013 @REQ-017 @screen-step2 @OMS014-EDG-004
    Skenario: Jumlah barang sangat besar memicu alert kapasitas namun tetap dapat lanjut
      Given user berada di halaman "Buat Order - Step 2 Data Barang"
      When user mengisi field "Jumlah" dengan "999999"
      Then sistem menampilkan "Kubikasi melebihi kapasitas armada"
      And sistem menampilkan "Berat melebihi kapasitas armada"
      When user mengklik tombol "Selanjutnya"
      Then user diarahkan ke halaman "Buat Order - Step 3 Vendor dan Harga"

    @edge @priority-low @REQ-014 @ASM-009 @screen-step2 @OMS014-EDG-005
    Skenario: Nilai Barang bernilai satu rupiah diterima
      Given user berada di halaman "Buat Order - Step 2 Data Barang" dengan asuransi aktif
      When user mengisi field "Nilai Barang" dengan "1"
      And user mengklik tombol "Selanjutnya"
      Then user diarahkan ke halaman "Buat Order - Step 3 Vendor dan Harga"

    @edge @priority-low @REQ-014 @REQ-021 @screen-step2 @OMS014-EDG-006
    Skenario: Nilai Barang sangat besar diformat mata uang dengan benar
      Given user berada di halaman "Buat Order - Step 2 Data Barang" dengan asuransi aktif
      When user mengisi field "Nilai Barang" dengan "999999999999"
      Then sistem menampilkan "Rp 999.999.999.999"
      And sistem menampilkan Total Nilai Barang yang konsisten pada Step 3

    @edge @priority-medium @REQ-015 @ASM-028 @screen-step2 @OMS014-EDG-007
    Skenario: Nomor DO satu nilai tanpa koma dirender sebagai satu chip
      Given user berada di halaman "Buat Order - Step 2 Data Barang"
      When user mengisi field "Nomor DO" dengan "TBL28371302"
      Then sistem menampilkan 1 chip "TBL28371302"

    @edge @priority-medium @REQ-015 @ASM-028 @screen-step2 @OMS014-EDG-008
    Skenario: Nomor DO dengan koma berlebih tidak menghasilkan chip kosong
      Given user berada di halaman "Buat Order - Step 2 Data Barang"
      When user mengisi field "Nomor DO" dengan "DO-001,,DO-002,"
      Then sistem menampilkan 2 chip
      And sistem tidak menampilkan chip kosong

    @edge @priority-low @REQ-015 @screen-step2 @OMS014-EDG-009
    Skenario: Nomor DO duplikat tidak menghasilkan chip ganda
      Given user berada di halaman "Buat Order - Step 2 Data Barang"
      When user mengisi field "Nomor DO" dengan "DO-001,DO-001"
      Then sistem menampilkan chip "DO-001" hanya satu kali

    @edge @priority-low @REQ-015 @ASM-028 @screen-step2 @OMS014-EDG-010
    Skenario: Nomor DO dengan karakter spesial dan unicode tetap tersimpan
      Given user berada di halaman "Buat Order - Step 2 Data Barang"
      When user mengisi field "Nomor DO" dengan "DO#001/@2026,DO-ÀÉÎ-002"
      Then sistem menampilkan chip "DO#001/@2026"
      And sistem menampilkan chip "DO-ÀÉÎ-002"

    @edge @priority-low @REQ-015 @screen-step2 @OMS014-EDG-011
    Skenario: Nomor DO sangat panjang tidak merusak layout card unit
      Given user berada di halaman "Buat Order - Step 2 Data Barang"
      When user mengisi field "Nomor DO" dengan teks sepanjang 200 karakter
      Then sistem menampilkan chip dengan pemotongan teks
      And sistem tidak menampilkan layout card yang pecah

    @edge @priority-medium @REQ-015 @screen-step2 @OMS014-EDG-012
    Skenario: Menghapus chip Nomor DO melalui ikon silang
      Given user berada di halaman "Buat Order - Step 2 Data Barang" dengan 2 chip Nomor DO
      When user mengklik tombol "Hapus TBL28371302"
      Then sistem tidak menampilkan chip "TBL28371302"
      And sistem menampilkan chip "TGK783898202U"

    @edge @priority-medium @REQ-014 @VAL-15 @screen-step2 @OMS014-EDG-013
    Skenario: Mencentang asuransi setelah Jumlah terisi memunculkan Nilai Barang kosong yang wajib
      Given user berada di halaman "Buat Order - Step 2 Data Barang" dengan Jumlah terisi dan asuransi tidak aktif
      When user mencentang "Tambahkan Asuransi" pada card "Armada 1"
      And user mengklik tombol "Selanjutnya"
      Then sistem menampilkan "Nilai Barang harus diisi"

    @edge @priority-medium @REQ-014 @VAL-15 @AC-020 @screen-step2 @OMS014-EDG-014
    Skenario: Membatalkan centang asuransi menyembunyikan kolom Nilai Barang dan menghentikan validasinya
      Given user berada di halaman "Buat Order - Step 2 Data Barang" dengan asuransi aktif dan Nilai Barang terisi
      When user membatalkan centang "Tambahkan Asuransi" pada card "Armada 1"
      Then sistem tidak menampilkan kolom "Nilai Barang"
      When user mengklik tombol "Selanjutnya"
      Then user diarahkan ke halaman "Buat Order - Step 3 Vendor dan Harga"

    @edge @priority-low @REQ-014 @screen-step2 @OMS014-EDG-015
    Skenario: Mengubah centang asuransi berulang kali secara cepat menghasilkan state yang konsisten
      Given user berada di halaman "Buat Order - Step 2 Data Barang"
      When user mengklik checkbox "Tambahkan Asuransi" sebanyak 10 kali secara cepat
      Then sistem menampilkan state checkbox yang konsisten dengan tampilan kolom "Nilai Barang"

    @edge @priority-medium @REQ-016 @VAL-18 @screen-step2 @OMS014-EDG-016
    Skenario: Menghapus seluruh barang pada unit menampilkan empty state
      Given user berada di halaman "Buat Order - Step 2 Data Barang" dengan 2 baris barang pada "Armada 3"
      When user menghapus seluruh baris barang pada card "Armada 3"
      Then sistem menampilkan "Belum ada barang. Klik \"Pilih Barang \""
      And sistem menampilkan "Total Kubikasi: 0"

    @edge @priority-high @REQ-017 @VAL-21 @AC-028 @screen-step2 @OMS014-EDG-017
    Skenario: Total kubikasi persis sama dengan kapasitas tidak memunculkan alert
      Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk armada berkapasitas "17,86 m³"
      When user mengisi Jumlah barang sehingga total kubikasi tepat "17,86 m³"
      Then sistem tidak menampilkan "Kubikasi melebihi kapasitas armada"

    @edge @priority-high @REQ-017 @VAL-20 @screen-step2 @OMS014-EDG-018
    Skenario: Total kubikasi melebihi kapasitas satu satuan terkecil memunculkan alert
      Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk armada berkapasitas "17,86 m³"
      When user mengisi Jumlah barang sehingga total kubikasi menjadi "17,87 m³"
      Then sistem menampilkan "Kubikasi melebihi kapasitas armada"

    @edge @priority-medium @REQ-017 @VAL-21 @screen-step2 @OMS014-EDG-019
    Skenario: Total berat persis sama dengan kapasitas tidak memunculkan alert
      Given user berada di halaman "Buat Order - Step 2 Data Barang" untuk armada berkapasitas "24.800 kg"
      When user mengisi Jumlah barang sehingga total berat tepat "24.800 kg"
      Then sistem tidak menampilkan "Berat melebihi kapasitas armada"

    @edge @priority-high @REQ-006 @ASM-016 @screen-step1 @OMS014-EDG-020
    Skenario: Mengurangi Jumlah Armada di Step 1 setelah Step 2 terisi menghapus card tanpa memindahkan barang
      Given user berada di halaman "Buat Order - Step 2 Data Barang" dengan 3 armada terisi barang
      When user mengklik tombol "Sebelumnya"
      And user mengisi field "Jumlah Armada" dengan "2"
      And user mengklik tombol "Selanjutnya"
      Then sistem menampilkan 2 card unit
      And sistem tidak memindahkan barang dari armada yang hilang ke armada lain

    @edge @priority-medium @REQ-006 @ASM-016 @screen-step1 @OMS014-EDG-021
    Skenario: Menambah Jumlah Armada di Step 1 menghasilkan card baru dalam kondisi kosong
      Given user berada di halaman "Buat Order - Step 2 Data Barang" dengan 2 armada terisi barang
      When user mengklik tombol "Sebelumnya"
      And user mengisi field "Jumlah Armada" dengan "4"
      And user mengklik tombol "Selanjutnya"
      Then sistem menampilkan card unit "Armada 3" dalam kondisi kosong
      And sistem menampilkan card unit "Armada 4" dalam kondisi kosong

    @edge @priority-medium @REQ-017 @VAL-21 @AC-028 @screen-step1 @OMS014-EDG-022
    Skenario: Mengubah Jenis Armada mengubah kapasitas pembanding alert kapasitas
      Given user berada di halaman "Buat Order - Step 2 Data Barang" dengan alert "Kubikasi melebihi kapasitas armada"
      When user mengklik tombol "Sebelumnya"
      And user memilih jenis armada berkapasitas lebih besar pada field "Jenis Armada"
      And user mengklik tombol "Selanjutnya"
      Then sistem tidak menampilkan "Kubikasi melebihi kapasitas armada"

    @edge @priority-low @REQ-011 @VAL-M2 @screen-modal-pilih-barang @OMS014-EDG-023
    Skenario: Pencarian barang bersifat case-insensitive dan mendukung kata kunci parsial
      Given user berada di halaman "Modal Pilih Barang"
      When user mengisi field "Cari kode/nama barang" dengan "kertas hvs"
      Then sistem menampilkan "SKU-PPR-001 - Kertas HVS A4 80 gsm"

    @edge @priority-low @REQ-011 @screen-modal-pilih-barang @OMS014-EDG-024
    Skenario: Pencarian dengan karakter spesial tidak menyebabkan error
      Given user berada di halaman "Modal Pilih Barang"
      When user mengisi field "Cari kode/nama barang" dengan "%_'\"<script>"
      Then sistem menampilkan "Data tidak ditemukan"
      And sistem tidak menampilkan error pada console

    @edge @priority-medium @REQ-011 @VAL-M5 @screen-modal-pilih-barang @OMS014-EDG-025
    Skenario: Memilih seluruh barang yang tersedia memperbarui counter sesuai jumlah
      Given user berada di halaman "Modal Pilih Barang" dengan 5 barang tersedia
      When user mencentang seluruh barang
      Then sistem menampilkan "5 barang terpilih"

    @edge @priority-low @REQ-011 @VAL-M5 @screen-modal-pilih-barang @OMS014-EDG-026
    Skenario: Membatalkan seluruh centang mengembalikan counter ke nol
      Given user berada di halaman "Modal Pilih Barang" dengan 3 barang tercentang
      When user membatalkan seluruh centang barang
      Then sistem menampilkan "0 barang terpilih"
      When user mengklik tombol "Simpan"
      Then sistem tidak menambahkan barang baru pada card "Armada 1"

    @edge @priority-medium @REQ-011 @VAL-M4 @ASM-013 @screen-modal-pilih-barang @OMS014-EDG-027
    Skenario: Memilih ulang barang berlabel Sudah Ditambahkan tidak menghasilkan baris duplikat
      Given user berada di halaman "Modal Pilih Barang" untuk card "Armada 1"
      When user mencentang barang "SKU-PPR-002" yang berlabel "Sudah Ditambahkan"
      And user mengklik tombol "Simpan"
      Then sistem menampilkan baris barang "SKU-PPR-002" hanya satu kali pada card "Armada 1"

    @edge @priority-medium @REQ-008 @VAL-06 @screen-step2 @OMS014-EDG-028
    Skenario: Multipoint dengan 3 pickup dan 3 drop off menghasilkan 9 kombinasi per unit
      Given user berada di halaman "Buat Order - Step 1 Data Pengiriman" tipe "Multipoint"
      When user mengisi 3 baris "Pick Up" dan 3 baris "Drop Off"
      And user mengklik tombol "Selanjutnya"
      Then sistem menampilkan 9 kombinasi alamat pada card "Armada 1"
      And setiap kombinasi menampilkan tombol "Pilih Barang" tersendiri

    @edge @priority-low @REQ-010 @screen-step1 @OMS014-EDG-029
    Skenario: Dua baris alamat pickup dengan drop point identik tetap dapat disimpan
      Given user berada di halaman "Buat Order - Step 1 Data Pengiriman" tipe "Multipickup"
      When user memilih drop point yang sama pada "Pick Up 1" dan "Pick Up 2"
      And user mengklik tombol "Selanjutnya"
      Then user diarahkan ke halaman "Buat Order - Step 2 Data Barang"
      And sistem menampilkan 2 kombinasi alamat pada card "Armada 1"

    @edge @priority-high @REQ-007 @AC-007 @screen-step2 @OMS014-EDG-030
    Skenario: Distribusi barang yang sengaja tidak merata antar alamat diterima apa adanya
      Given user berada di halaman "Buat Order - Step 2 Data Barang" tipe "Multidrop"
      When user mengisi Jumlah "900" pada kombinasi "Drop Off 1" dan "10" pada kombinasi "Drop Off 2"
      And user mengklik tombol "Selanjutnya"
      Then user diarahkan ke halaman "Buat Order - Step 3 Vendor dan Harga"
      And sistem tidak menyeimbangkan jumlah barang antar alamat

    @edge @priority-high @REQ-006 @VAL-04 @AC-006 @screen-step2 @OMS014-EDG-031
    Skenario: Refresh browser pada Step 2 mempertahankan penempatan barang per unit
      Given user berada di halaman "Buat Order - Step 2 Data Barang" dengan komposisi barang berbeda per armada
      When user menekan tombol refresh browser
      Then sistem menampilkan komposisi barang yang identik dengan sebelum refresh

    @edge @priority-medium @REQ-006 @REQ-022 @screen-step2 @OMS014-EDG-032
    Skenario: Navigasi bolak-balik antar step berulang tidak memicu rekomputasi penempatan barang
      Given user berada di halaman "Buat Order - Step 2 Data Barang" dengan data barang terisi
      When user berpindah antara Step 2 dan Step 3 sebanyak 5 kali
      Then sistem menampilkan komposisi barang per unit yang tidak berubah

    @edge @priority-medium @REQ-020 @ASM-011 @screen-step3 @OMS014-EDG-033
    Skenario: Tanggal Permintaan Muat sama dengan hari ini diterima
      Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
      When user mengisi field "Tanggal Permintaan Muat" dengan tanggal hari ini pukul "23:59"
      And user mengklik tombol "Selanjutnya"
      Then user diarahkan ke halaman "Buat Order - Step 4 Review"

    @edge @priority-low @REQ-020 @screen-step3 @OMS014-EDG-034
    Skenario: Tanggal Permintaan Muat jauh di masa depan diterima
      Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
      When user mengisi field "Tanggal Permintaan Muat" dengan "31/12/2030 08:00"
      And user mengklik tombol "Selanjutnya"
      Then user diarahkan ke halaman "Buat Order - Step 4 Review"

    @edge @priority-low @REQ-020 @screen-step3 @OMS014-EDG-035
    Skenario: Harga bernilai nol diterima sebagai batas bawah
      Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
      When user mengisi field "Harga" dengan "0"
      And user mengklik tombol "Selanjutnya"
      Then user diarahkan ke halaman "Buat Order - Step 4 Review"
      And sistem menampilkan "Total Harga" bernilai "Rp. 0"

    @edge @priority-low @REQ-020 @screen-step3 @OMS014-EDG-036
    Skenario: Waktu Perjalanan bernilai nol jam pada rute baru
      Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga" dengan alert rute belum ada
      When user mengisi field "Waktu Perjalanan" dengan "0"
      And user mengklik tombol "Selanjutnya"
      Then sistem menampilkan pesan validasi atau menerima nilai sesuai kebijakan master waktu perjalanan

    @edge @priority-low @REQ-020 @screen-step3 @OMS014-EDG-037
    Skenario: Waktu Perjalanan bernilai sangat besar tetap diformat dengan benar
      Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga" dengan alert rute belum ada
      When user mengisi field "Waktu Perjalanan" dengan "999"
      And user mengklik tombol "Selanjutnya"
      Then sistem menampilkan "Waktu Perjalanan : 999 Jam" pada halaman "Buat Order - Step 4 Review"

    @edge @priority-low @REQ-021 @VAL-23 @screen-step3 @OMS014-EDG-038
    Skenario: Komponen harga bernilai nol persen menghasilkan Total Harga sama dengan Harga DPP
      Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga" dengan komponen harga aktif
      When user mengisi field "PPN" dengan "0"
      And user mengisi field "PPh" dengan "0"
      And user mengisi field "Asuransi" dengan "0"
      Then sistem menampilkan "Total Harga" sama dengan "Harga DPP"

    @edge @priority-medium @REQ-021 @VAL-23 @AC-034 @screen-step3 @OMS014-EDG-039
    Skenario: Perhitungan Asuransi pada Total Nilai Barang besar dibulatkan konsisten
      Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga" dengan Total Nilai Barang "Rp1.006.750.000"
      When user mengisi field "Asuransi" dengan "0,2"
      Then sistem menampilkan komponen "Asuransi (0,2%)" sebesar "Rp2.013.500"
      And sistem menampilkan "Total Harga" yang mencakup komponen tersebut

    @edge @priority-medium @REQ-034 @ASM-030 @screen-step2 @OMS014-EDG-040
    Skenario: Order draft yang dibuat saat Auto Stuffing aktif dibuka saat toggle nonaktif
      Given terdapat order draft yang dibuat saat toggle "Auto Stuffing" aktif
      When toggle "Auto Stuffing" dimatikan
      And user mengklik "Lanjutkan Pengisian" pada order tersebut
      Then sistem menampilkan penempatan barang hasil sebelumnya tanpa perubahan
      And sistem tidak menampilkan tombol "Hitung Ulang Armada"

    @edge @priority-medium @REQ-035 @screen-step2 @OMS014-EDG-041
    Skenario: Toggle dimatikan saat sesi user sedang berada di Step 2
      Given user berada di halaman "Buat Order - Step 2 Data Barang" dengan toggle "Auto Stuffing" aktif
      When Admin Sistem mematikan toggle "Auto Stuffing"
      And user memuat ulang halaman
      Then sistem tidak menampilkan tombol "Hitung Ulang Armada"
      And sistem menampilkan seluruh data barang yang sudah diinput tetap utuh

    @edge @priority-medium @REQ-024 @screen-step4-review @OMS014-EDG-042
    Skenario: Simpan ke Draf pada Step 4 menghasilkan status Review Order bukan Menunggu Penugasan
      Given user berada di halaman "Buat Order - Step 4 Review"
      When user mengklik tombol "Simpan ke Draf"
      Then sistem menampilkan badge status "Review Order"
      And sistem tidak menampilkan badge status "Menunggu Penugasan"

    @edge @priority-low @REQ-027 @screen-popup-pembatalan @OMS014-EDG-043
    Skenario: Alasan Pembatalan dengan satu karakter diterima
      Given user berada di halaman "Pop Up Pembatalan Order"
      When user mengisi field "Alasan Pembatalan" dengan "x"
      And user mengklik tombol "Batalkan Order"
      Then sistem menampilkan badge status "Dibatalkan"

    @edge @priority-low @REQ-027 @screen-popup-pembatalan @OMS014-EDG-044
    Skenario: Alasan Pembatalan sepanjang 1000 karakter tersimpan utuh
      Given user berada di halaman "Pop Up Pembatalan Order"
      When user mengisi field "Alasan Pembatalan" dengan teks sepanjang 1000 karakter
      And user mengklik tombol "Batalkan Order"
      Then sistem menampilkan badge status "Dibatalkan"
      And sistem menampilkan alasan pembatalan lengkap pada halaman "Riwayat Pembatalan"

    @edge @priority-low @REQ-027 @screen-popup-pembatalan @OMS014-EDG-045
    Skenario: Alasan Pembatalan dengan emoji dan karakter spesial tersimpan tanpa merusak tampilan
      Given user berada di halaman "Pop Up Pembatalan Order"
      When user mengisi field "Alasan Pembatalan" dengan "Dibatalkan customer 🚚 <b>urgent</b> & 'mendadak'"
      And user mengklik tombol "Batalkan Order"
      Then sistem menampilkan badge status "Dibatalkan"
      And sistem menampilkan teks alasan tanpa render HTML mentah

    @edge @priority-low @REQ-010 @screen-step1 @OMS014-EDG-046
    Skenario: PIC Pengirim dengan nama panjang dan karakter spesial diterima
      Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
      When user mengisi field "PIC Pengirim" dengan "Andika Prasetyo Wibisono Kusuma Atmaja Nugroho Santoso"
      And user mengklik tombol "Selanjutnya"
      Then user diarahkan ke halaman "Buat Order - Step 2 Data Barang"

    @edge @priority-low @REQ-010 @screen-step1 @OMS014-EDG-047
    Skenario: Catatan pengirim sepanjang 500 karakter tidak merusak layout kartu
      Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
      When user mengisi field "Catatan" dengan teks sepanjang 500 karakter
      Then sistem menampilkan textarea dengan scroll internal
      And sistem tidak menampilkan layout kartu yang pecah

    @edge @priority-medium @REQ-028 @VAL-32 @screen-popup-no-perjalanan @OMS014-EDG-048
    Skenario: Order dengan satu unit menghasilkan satu baris No. Perjalanan
      Given terdapat order "FTL" dengan 1 armada berstatus "Ditugaskan"
      When user mengklik "Lihat No. Perjalanan"
      Then sistem menampilkan 1 baris No. Perjalanan

    @edge @priority-low @REQ-028 @screen-popup-no-perjalanan @OMS014-EDG-049
    Skenario: Menyalin No. Perjalanan berulang kali tetap menghasilkan nilai yang benar
      Given user berada di halaman "Pop Up Data No. Perjalanan"
      When user mengklik tombol "Salin" sebanyak 5 kali pada baris yang sama
      Then clipboard berisi nomor yang sama pada setiap penyalinan

    @edge @priority-medium @REQ-014 @REQ-021 @screen-step4-review @OMS014-EDG-050
    Skenario: Order dengan seluruh unit diasuransikan menampilkan label pada setiap unit
      Given user membuat order dengan 3 armada dan seluruhnya dicentang "Tambahkan Asuransi"
      When user diarahkan ke halaman "Buat Order - Step 4 Review"
      Then sistem menampilkan "Diasuransikan" pada 3 blok unit
      And sistem menampilkan komponen "Asuransi" pada ringkasan harga

    @edge @priority-low @REQ-028 @screen-daftar-order @OMS014-EDG-051
    Skenario: Filter dengan kombinasi banyak field sekaligus mengembalikan hasil yang tepat
      Given user berada di halaman "Daftar Order"
      When user mengklik tombol "Filter"
      And user mengisi seluruh field filter yang tersedia
      And user mengklik tombol "Terapkan"
      Then sistem menampilkan hasil sesuai seluruh kriteria filter

    @edge @priority-low @REQ-028 @screen-daftar-order @OMS014-EDG-052
    Skenario: Filter tanpa hasil menampilkan empty state tabel
      Given user berada di halaman "Daftar Order"
      When user mengisi field "ID Order" dengan "ORD-TIDAK-ADA"
      And user mengklik tombol "Terapkan"
      Then sistem menampilkan "Data tidak ditemukan"

    @edge @priority-medium @REQ-037 @VAL-10 @AC-060 @screen-step2 @OMS014-EDG-053
    Skenario: Layout Step 2 tetap rapi pada viewport kecil dan zoom 200 persen
      Given user berada di halaman "Buat Order - Step 2 Data Barang"
      When user mengubah viewport menjadi 1280x720 dan zoom 200 persen
      Then sistem tidak menampilkan tombol "Hitung Ulang Armada"
      And sistem tidak menampilkan area kosong pada pojok kanan bawah
      And sistem menampilkan seluruh card unit tanpa overlap

    @edge @priority-high @REQ-022 @screen-step4-review @OMS014-EDG-054
    Skenario: Klik ganda pada tombol Simpan Step 4 hanya menghasilkan satu order
      Given user berada di halaman "Buat Order - Step 4 Review" dengan data lengkap
      When user mengklik tombol "Simpan" dua kali secara cepat
      Then sistem membuat tepat 1 order baru
      And sistem menampilkan badge status "Menunggu Penugasan"

    @edge @priority-medium @REQ-022 @screen-step3 @OMS014-EDG-055
    Skenario: Menekan tombol Back browser dari Step 3 kembali ke Step 2 dengan data utuh
      Given user berada di halaman "Buat Order - Step 3 Vendor dan Harga"
      When user menekan tombol back pada browser
      Then user diarahkan ke halaman "Buat Order - Step 2 Data Barang"
      And sistem menampilkan seluruh data barang tetap tersimpan

    @edge @priority-low @REQ-012 @screen-step2 @OMS014-EDG-056
    Skenario: Nama barang sangat panjang tidak merusak layout tabel barang
      Given terdapat barang dengan nama sepanjang 150 karakter pada Master Barang
      When user menambahkan barang tersebut ke card "Armada 1"
      Then sistem menampilkan nama barang dengan wrap atau ellipsis
      And sistem tidak menampilkan tabel yang overflow horizontal berlebihan

  # ==========================================================================
  Aturan: N. Stress & Performance
  # ==========================================================================

    @stress @priority-medium @REQ-010 @REQ-019 @screen-step2 @OMS014-STR-001
    Skenario: Step 2 merender 100 card unit tanpa elemen Auto Stuffing dan tanpa error
      Given user berada di halaman "Buat Order - Step 1 Data Pengiriman"
      When user mengisi field "Jumlah Armada" dengan "100"
      And user mengklik tombol "Selanjutnya"
      Then sistem menampilkan 100 card unit dalam waktu kurang dari 10 detik
      And sistem tidak menampilkan tombol "Hitung Ulang Armada"

    @stress @priority-medium @REQ-011 @screen-step2 @OMS014-STR-002
    Skenario: Menambahkan 50 baris barang pada satu unit
      Given user berada di halaman "Buat Order - Step 2 Data Barang"
      When user menambahkan 50 barang berbeda pada card "Armada 1"
      And user mengisi field "Jumlah" pada seluruh 50 baris
      Then sistem menampilkan 50 baris barang tanpa lag
      And sistem menampilkan total kubikasi dan berat yang akurat

    @stress @priority-medium @REQ-008 @screen-step2 @OMS014-STR-003
    Skenario: Order dengan total 500 baris barang lintas unit tetap dapat disimpan
      Given user berada di halaman "Buat Order - Step 2 Data Barang" dengan 10 armada
      When user menambahkan 50 baris barang pada setiap armada
      And user mengklik tombol "Selanjutnya"
      Then user diarahkan ke halaman "Buat Order - Step 3 Vendor dan Harga"
      And sistem tidak menampilkan timeout

    @stress @priority-medium @REQ-007 @REQ-008 @screen-step2 @OMS014-STR-004
    Skenario: Multipoint 5x5 pada 10 unit menghasilkan 250 kombinasi alamat yang dapat diisi manual
      Given user membuat order tipe "Multipoint" dengan 5 pickup, 5 drop off, dan 10 armada
      When user diarahkan ke halaman "Buat Order - Step 2 Data Barang"
      Then sistem menampilkan 25 kombinasi alamat per card unit
      And sistem tidak melakukan pembagian barang otomatis pada kombinasi manapun

    @stress @priority-low @REQ-015 @screen-step2 @OMS014-STR-005
    Skenario: Nomor DO dengan 100 nilai dipisahkan koma dirender sebagai 100 chip
      Given user berada di halaman "Buat Order - Step 2 Data Barang"
      When user mengisi field "Nomor DO" dengan 100 nomor dipisahkan koma
      Then sistem menampilkan 100 chip
      And sistem tidak menampilkan layout card yang pecah

    @stress @priority-low @REQ-015 @screen-step2 @OMS014-STR-006
    Skenario: Payload Nomor DO sepanjang 10000 karakter ditangani tanpa crash
      Given user berada di halaman "Buat Order - Step 2 Data Barang"
      When user mengisi field "Nomor DO" dengan teks sepanjang 10000 karakter
      Then sistem menampilkan pesan validasi panjang maksimum atau memotong input secara aman
      And sistem tidak menampilkan error pada console

    @stress @priority-low @REQ-027 @screen-popup-pembatalan @OMS014-STR-007
    Skenario: Alasan Pembatalan sepanjang 10000 karakter ditangani secara graceful
      Given user berada di halaman "Pop Up Pembatalan Order"
      When user mengisi field "Alasan Pembatalan" dengan teks sepanjang 10000 karakter
      And user mengklik tombol "Batalkan Order"
      Then sistem menampilkan pesan validasi panjang maksimum atau menyimpan data secara utuh

    @stress @priority-medium @REQ-011 @VAL-M1 @screen-modal-pilih-barang @OMS014-STR-008
    Skenario: Modal Pilih Barang dengan Master Barang 10000 item tetap responsif
      Given Master Barang memiliki 10000 item aktif
      When user membuka modal "Pilih Barang"
      Then sistem menampilkan daftar barang dalam waktu kurang dari 5 detik
      When user mengisi field "Cari kode/nama barang" dengan "SKU-PPR-9999"
      Then sistem menampilkan hasil pencarian dalam waktu kurang dari 3 detik

    @stress @priority-low @REQ-011 @screen-modal-pilih-barang @OMS014-STR-009
    Skenario: Pencarian barang berulang cepat tidak menyebabkan request menumpuk
      Given user berada di halaman "Modal Pilih Barang"
      When user mengetik dan menghapus kata kunci sebanyak 100 kali secara cepat
      Then sistem menampilkan hasil akhir yang konsisten dengan kata kunci terakhir
      And sistem tidak menampilkan error pada console

    @stress @priority-medium @REQ-028 @screen-daftar-order @OMS014-STR-010
    Skenario: Daftar Order dengan 10000 record tetap responsif saat paginasi dan filter
      Given terdapat 10000 order pada tenant
      When user berada di halaman "Daftar Order"
      And user mengklik tombol "Terapkan" pada panel filter
      Then sistem menampilkan hasil dalam waktu kurang dari 5 detik
      And sistem menampilkan info paginasi yang akurat

    @stress @priority-medium @REQ-022 @screen-step4-review @OMS014-STR-011
    Skenario: 20 sesi paralel membuat order bersamaan tanpa ID order duplikat
      Given 20 user shipper login secara paralel
      When seluruh user mengklik tombol "Simpan" pada halaman "Buat Order - Step 4 Review" secara bersamaan
      Then sistem membuat 20 order dengan ID unik
      And seluruh order berstatus "Menunggu Penugasan"

    @stress @priority-medium @REQ-028 @VAL-32 @screen-detail-order @OMS014-STR-012
    Skenario: Generate No. Perjalanan untuk order dengan 100 unit menghasilkan 100 nomor unik
      Given terdapat order "FTL" dengan 100 armada
      When vendor melakukan penugasan sehingga status menjadi "Ditugaskan"
      Then sistem menampilkan 100 No. Perjalanan pada halaman "Detail Order"
      And seluruh No. Perjalanan bernilai unik

    @stress @priority-low @REQ-034 @VAL-36 @screen-konfigurasi-addon @OMS014-STR-013
    Skenario: Toggle Auto Stuffing di-flip berulang kali menghasilkan state akhir yang konsisten
      Given user berada di halaman "Konfigurasi Add-on"
      When user mengubah toggle "Auto Stuffing" sebanyak 50 kali secara berurutan
      Then sistem menampilkan state akhir toggle yang konsisten
      And halaman "Buat Order - Step 2 Data Barang" mengikuti state akhir tersebut

    @stress @priority-low @REQ-024 @screen-step2 @OMS014-STR-014
    Skenario: Simpan ke Draf berulang 100 kali pada order yang sama tidak menghasilkan duplikat
      Given user berada di halaman "Buat Order - Step 2 Data Barang" pada order draft
      When user mengklik tombol "Simpan ke Draf" sebanyak 100 kali
      Then sistem menyimpan tepat 1 order draft
      And sistem tidak menampilkan error pada console

    @stress @priority-medium @REQ-029 @REQ-030 @screen-step4-review @OMS014-STR-015
    Skenario: Review order berukuran sangat besar dirender tanpa elemen Auto Stuffing
      Given terdapat order dengan 100 unit dan 50 baris barang per unit
      When user diarahkan ke halaman "Buat Order - Step 4 Review"
      Then sistem menampilkan seluruh blok unit dalam waktu kurang dari 15 detik
      And sistem tidak menampilkan tombol "Lihat Visualisasi Muatan"
      And sistem tidak menampilkan "Indikator Keterisian"

    @stress @priority-medium @REQ-031 @screen-detail-order @OMS014-STR-016
    Skenario: Detail Order berukuran sangat besar dimuat tanpa timeout dan tanpa elemen Auto Stuffing
      Given terdapat order dengan 100 unit dan 50 baris barang per unit berstatus "Ditugaskan"
      When user berada di halaman "Detail Order"
      Then sistem menampilkan seluruh data barang tanpa timeout
      And sistem tidak menampilkan "Visualisasi Muatan"

    @stress @priority-medium @REQ-026 @screen-edit-order @OMS014-STR-017
    Skenario: Menyimpan Edit Order dengan 100 unit selesai dalam batas waktu wajar
      Given user berada di halaman "Edit Order" untuk order dengan 100 unit
      When user mengubah data barang pada 10 unit
      And user mengklik tombol "Simpan"
      And user mengklik tombol "Ya" pada pop up konfirmasi
      Then sistem menampilkan "Perubahan berhasil disimpan" dalam waktu kurang dari 20 detik

    @stress @priority-low @REQ-009 @ASM-024 @screen-daftar-order @OMS014-STR-018
    Skenario: Batch Order dengan 1000 baris diproses tanpa Auto Stuffing
      Given user berada di halaman "Daftar Order"
      When user mengunggah file batch order berisi 1000 baris
      Then sistem memproses seluruh baris dan menampilkan ringkasan hasil
      And sistem tidak melakukan distribusi barang otomatis pada order yang dihasilkan

    @stress @priority-medium @REQ-022 @screen-step4-review @OMS014-STR-019
    Skenario: Timeout jaringan saat Simpan order ditangani secara graceful tanpa order ganda
      Given user berada di halaman "Buat Order - Step 4 Review" dengan koneksi dibatasi hingga timeout
      When user mengklik tombol "Simpan"
      Then sistem menampilkan pesan kegagalan koneksi
      And sistem tidak membuat order duplikat setelah user mencoba ulang

    @stress @priority-low @REQ-028 @screen-daftar-order @OMS014-STR-020
    Skenario: Operasi filter, sort, dan paginasi berulang 200 kali tetap stabil
      Given user berada di halaman "Daftar Order"
      When user melakukan kombinasi filter, sort, dan paginasi sebanyak 200 kali
      Then sistem menampilkan data yang konsisten pada setiap operasi
      And sistem tidak menampilkan memory leak atau error pada console

    @stress @priority-medium @REQ-027 @screen-popup-pembatalan @OMS014-STR-021
    Skenario: 10 user paralel membatalkan order yang sama hanya menghasilkan satu pembatalan
      Given 10 user admin shipper membuka pop up pembatalan untuk order yang sama
      When seluruh user mengklik tombol "Batalkan Order" secara bersamaan
      Then sistem mencatat tepat 1 pembatalan
      And sistem menampilkan pesan konflik pada permintaan lainnya

    @stress @priority-high @REQ-003 @REQ-004 @VAL-01 @VAL-02 @screen-step2 @OMS014-STR-022
    Skenario: Scroll penuh halaman Step 2 setinggi 10000 piksel tidak memunculkan floating button
      Given user berada di halaman "Buat Order - Step 2 Data Barang" tipe "Multipoint" dengan tinggi halaman lebih dari 10000 piksel
      When user melakukan scroll bertahap dari posisi 0 hingga akhir halaman
      Then sistem tidak menampilkan tombol "Hitung Ulang Armada" pada seluruh posisi scroll
      And sistem tidak menampilkan tombol "Visualisasi Terbaru" pada seluruh posisi scroll
