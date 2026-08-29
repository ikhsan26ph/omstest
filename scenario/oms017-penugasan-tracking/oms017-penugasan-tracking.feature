# ============================================================================
# OMS017 - Penugasan Tracking
# Sumber : output/oms017-penugasan-tracking/oms017-penugasan-tracking.analysis.md
#          (80 Requirements, 6 User Flows, 22 layar UI Inventory, A-01..A-15 / D-01..D-20)
# Catatan:
#  - Assertion status memakai pola alternatif/regex karena penamaan status ganda
#    (A-01 / D-02): "Belum Berangkat|Menunggu Proses", "Dalam Perjalanan|Selesai Muat",
#    "Selesai|Selesai Bongkar".
#  - Halaman "Isi Data Tracking" tidak memiliki desain (D-17) -> selector asumsi
#    (data-testid usulan) didokumentasikan pada file .scenarios.json.
#  - Teks pesan error tidak di-assert literal (D-07); yang di-assert adalah
#    kemunculan error/alert dan blokir penyimpanan.
#  - Tag: @positive|@negative|@edge|@stress + @priority-* + @REQ-* + @screen-* + @TC-*
# ============================================================================

Feature: OMS017 Penugasan Tracking
  Sebagai pengguna OMS (Shipper pengelola vendor, Vendor, atau Pengurus/Admin)
  Saya ingin mengelola penugasan armada/sopir dan mengisi data tracking order
  Sehingga status pengiriman FTL/LTL/FCL/LCL dapat dipantau sampai selesai

  Background:
    Given aplikasi TMS tersedia dan dapat diakses
    And data master kota, armada, sopir, dan pelayaran tersedia

  # ==========================================================================
  # POSITIVE - AREA 1: HAK AKSES & AKTOR (REQ-001 s.d. REQ-003, REQ-050)
  # ==========================================================================

  @positive @priority-high @REQ-001 @screen-127 @TC-P-001
  Scenario: Shipper pengelola vendor memiliki akses penuh pada order vendor kelolaannya
    Given user login sebagai "Shipper" yang mengelola vendor "JNE"
    And user berada di halaman "Penugasan Tracking"
    When user mengklik tombol "Aksi" pada baris order bervendor "JNE"
    Then sistem menampilkan "Detail Penugasan"
    And sistem menampilkan "Edit Penugasan"
    And sistem menampilkan "Isi Data Tracking"
    And sistem menampilkan "Riwayat Perubahan"
    And tombol "Tambah Penugasan" dalam keadaan enabled

  @positive @priority-high @REQ-003 @REQ-007 @screen-128 @TC-P-002
  Scenario: Akun Vendor memiliki akses penuh pada modul Penugasan Tracking
    Given user login sebagai "Vendor"
    And user berada di halaman "Penugasan Tracking"
    When user mengklik tombol "Aksi" pada baris "ORD76392092"
    Then sistem menampilkan 4 menu aksi Penugasan Tracking
    And seluruh menu aksi dalam keadaan enabled

  @positive @priority-medium @REQ-050 @screen-isi-data-tracking @TC-P-003
  Scenario: Pengurus/Admin web dapat membuka form pengisian data tracking
    Given user login sebagai "Pengurus" dengan akses penuh
    And user berada di halaman "Penugasan Tracking"
    When user mengklik menu aksi "Isi Data Tracking" pada baris "ORD19283005"
    Then user diarahkan ke halaman "Isi Data Tracking"
    And sistem menampilkan form pengisian tahap tracking dalam keadaan enabled

  # ==========================================================================
  # POSITIVE - AREA 2: DAFTAR PENUGASAN TRACKING (REQ-004 s.d. REQ-008)
  # ==========================================================================

  @positive @priority-high @REQ-004 @screen-127 @TC-P-004
  Scenario: Daftar penugasan menampilkan maksimal 20 baris per halaman
    Given tersedia 30 data penugasan tracking
    And user login sebagai "Vendor"
    When user berada di halaman "Penugasan Tracking"
    Then sistem menampilkan maksimal 20 baris pada tabel penugasan
    And sistem menampilkan "Menampilkan 1 - 20 data dari 30 data"
    And kontrol pagination ditampilkan

  @positive @priority-medium @REQ-004 @screen-127 @TC-P-005
  Scenario: Pindah ke halaman berikutnya melalui pagination
    Given tersedia 30 data penugasan tracking
    And user berada di halaman "Penugasan Tracking"
    When user mengklik tombol "2" pada kontrol pagination
    Then sistem menampilkan 10 baris pada tabel penugasan
    And sistem menampilkan "Menampilkan 21 - 30 data dari 30 data"

  @positive @priority-medium @REQ-005 @screen-127 @TC-P-006
  Scenario: Urutan data terbaru berada pada posisi teratas
    Given terdapat penugasan baru "ORD99999001" yang dibuat paling akhir
    When user berada di halaman "Penugasan Tracking"
    Then baris pertama tabel penugasan menampilkan "ORD99999001"

  @positive @priority-high @REQ-006 @REQ-028 @screen-127 @TC-P-007
  Scenario: Tabel menampilkan empat kolom sesuai ketentuan
    Given user berada di halaman "Penugasan Tracking"
    Then sistem menampilkan kolom "ID Order"
    And sistem menampilkan kolom "Rute"
    And sistem menampilkan kolom "No. Polisi/No. Kontainer"
    And sistem menampilkan kolom "Status"
    And baris "ORD82090192" menampilkan badge jenis shipment "LTL"
    And baris "ORD82090192" menampilkan rute "Kota Surabaya - Kota Malang"
    And baris "ORD82090192" menampilkan nopol "L 1892 PGS" dan sopir "Murtiono"

  @positive @priority-high @REQ-007 @screen-128 @TC-P-008
  Scenario: Action menu pada baris trucking menampilkan empat opsi
    Given user berada di halaman "Penugasan Tracking"
    When user mengklik tombol "Aksi" pada baris "ORD82090192"
    Then sistem menampilkan "Detail Penugasan"
    And sistem menampilkan "Edit Penugasan"
    And sistem menampilkan "Isi Data Tracking"
    And sistem menampilkan "Riwayat Perubahan"

  @positive @priority-medium @REQ-007 @screen-129 @TC-P-009
  Scenario: Action menu pada baris kontainer menampilkan opsi yang sama dengan trucking
    Given user berada di halaman "Penugasan Tracking"
    When user mengklik tombol "Aksi" pada baris "ORD76392092"
    Then sistem menampilkan "Detail Penugasan"
    And sistem menampilkan "Edit Penugasan"
    And sistem menampilkan "Isi Data Tracking"
    And sistem menampilkan "Riwayat Perubahan"

  @positive @priority-high @REQ-008 @screen-127 @screen-134 @TC-P-010
  Scenario: Tombol Tambah Penugasan mengarahkan ke halaman Tambah Penugasan
    Given user login sebagai "Vendor"
    And user berada di halaman "Penugasan Tracking"
    When user mengklik tombol "Tambah Penugasan"
    Then user diarahkan ke halaman "Tambah Penugasan"
    And sistem menampilkan "Pilih Order"

  @positive @priority-medium @REQ-006 @REQ-016 @REQ-020 @REQ-021 @REQ-022 @screen-127 @TC-P-011
  Scenario: Badge status ditampilkan pada setiap baris penugasan
    Given user berada di halaman "Penugasan Tracking"
    Then baris "ORD82090192" menampilkan badge status yang cocok dengan pola "Belum Berangkat|Menunggu Proses"
    And baris "ORD19283005" menampilkan badge status yang cocok dengan pola "Dalam Perjalanan|Selesai Muat"
    And baris "ORD00986289" menampilkan badge status yang cocok dengan pola "Selesai|Selesai Bongkar"

  @positive @priority-low @REQ-007 @screen-139 @TC-P-012
  Scenario: Action menu versi revisi tetap memuat empat menu wajib
    Given user berada di halaman "Penugasan Tracking" versi revisi
    When user mengklik tombol "Aksi" pada baris "ORD62838963"
    Then sistem menampilkan "Detail Penugasan"
    And sistem menampilkan "Edit Penugasan"
    And sistem menampilkan "Isi Data Tracking"
    And sistem menampilkan "Riwayat Perubahan"
    But sistem tidak membatasi menu hanya empat item

  # ==========================================================================
  # POSITIVE - AREA 3: FILTER DAFTAR (REQ-009 s.d. REQ-019)
  # ==========================================================================

  @positive @priority-high @REQ-009 @screen-127 @TC-P-013
  Scenario: Filter data berdasarkan ID Order
    Given user berada di halaman "Penugasan Tracking"
    When user mengisi field "ID Order" dengan "ORD76392092"
    And user mengklik tombol "Terapkan"
    Then seluruh baris tabel menampilkan ID Order "ORD76392092"

  @positive @priority-medium @REQ-011 @screen-127 @TC-P-014
  Scenario: Filter Kota Asal menggunakan opsi dari data master kota
    Given user berada di halaman "Penugasan Tracking"
    When user mengklik field "Kota Asal"
    Then opsi dropdown berasal dari data master kota
    When user memilih "Kota Surabaya" pada field "Kota Asal"
    And user mengklik tombol "Terapkan"
    Then seluruh baris tabel menampilkan kota asal "Kota Surabaya"

  @positive @priority-medium @REQ-013 @screen-127 @TC-P-015
  Scenario: Filter berdasarkan No. Polisi atau No. Kontainer
    Given user berada di halaman "Penugasan Tracking"
    When user mengisi field "No. Polisi/No. Kontainer" dengan "CNT728900287"
    And user mengklik tombol "Terapkan"
    Then seluruh baris tabel menampilkan nomor "CNT728900287"

  @positive @priority-medium @REQ-014 @screen-127 @TC-P-016
  Scenario: Filter berdasarkan nama Sopir
    Given user berada di halaman "Penugasan Tracking"
    When user mengisi field "Sopir" dengan "Murtiono"
    And user mengklik tombol "Terapkan"
    Then seluruh baris tabel menampilkan sopir "Murtiono"

  @positive @priority-high @REQ-015 @screen-127 @TC-P-017
  Scenario: Filter Tahap Pengiriman menampilkan order yang pernah mencapai tahap tersebut
    Given order "ORD123" sudah melakukan update "Selesai Muat" dan berstatus "Dalam Perjalanan"
    And user berada di halaman "Penugasan Tracking"
    When user memilih "Selesai Muat" pada field "Tahap Pengiriman"
    And user mengklik tombol "Terapkan"
    Then tabel menampilkan baris "ORD123"
    And badge status baris "ORD123" cocok dengan pola "Dalam Perjalanan|Selesai Muat"

  @positive @priority-high @REQ-016 @screen-127 @TC-P-018
  Scenario: Filter berdasarkan Status penugasan terkini
    Given user berada di halaman "Penugasan Tracking"
    When user memilih "Dalam Perjalanan" pada field "Status"
    And user mengklik tombol "Terapkan"
    Then seluruh baris tabel menampilkan badge status yang cocok dengan pola "Dalam Perjalanan|Selesai Muat"

  @positive @priority-medium @REQ-017 @screen-127 @TC-P-019
  Scenario: Seluruh field filter default kosong dengan placeholder
    When user berada di halaman "Penugasan Tracking"
    Then field "ID Order" kosong dengan placeholder "Masukkan ID Order"
    And field "Jenis Shipment" kosong dengan placeholder "Pilih Jenis Shipment"
    And field "Kota Asal" kosong dengan placeholder "Pilih Rute"
    And field "Kota Tujuan" kosong dengan placeholder "Pilih Rute"
    And field "No. Polisi/No. Kontainer" kosong dengan placeholder "Masukkan No. Polisi/No. Kontainer"
    And field "Sopir" kosong dengan placeholder "Masukkan Nama Sopir"
    And field "Status" kosong dengan placeholder "Pilih Status"

  @positive @priority-high @REQ-018 @screen-127 @TC-P-020
  Scenario: Tombol Reset mengosongkan seluruh filter dan mengembalikan data default
    Given user berada di halaman "Penugasan Tracking"
    And user mengisi field "ID Order" dengan "ORD76392092"
    And user memilih "FCL" pada field "Jenis Shipment"
    And user mengklik tombol "Terapkan"
    When user mengklik tombol "Reset"
    Then field "ID Order" kosong dengan placeholder "Masukkan ID Order"
    And field "Jenis Shipment" kosong dengan placeholder "Pilih Jenis Shipment"
    And tabel menampilkan data default dengan maksimal 20 baris
    And baris pertama tabel adalah data terbaru

  @positive @priority-high @REQ-019 @REQ-010 @REQ-012 @screen-127 @TC-P-021
  Scenario: Kombinasi beberapa filter diterapkan secara AND
    Given user berada di halaman "Penugasan Tracking"
    When user memilih "FCL" pada field "Jenis Shipment"
    And user memilih "Kab. Bima" pada field "Kota Tujuan"
    And user mengisi field "Sopir" dengan "Reza"
    And user mengklik tombol "Terapkan"
    Then seluruh baris tabel memenuhi jenis shipment "FCL" dan kota tujuan "Kab. Bima" dan sopir "Reza"

  @positive @priority-medium @REQ-019 @REQ-017 @screen-139 @TC-P-022
  Scenario: Terapkan tanpa mengisi filter apa pun tetap menampilkan data default
    Given user berada di halaman "Penugasan Tracking"
    When user mengklik tombol "Terapkan"
    Then sistem tidak menampilkan pesan error required pada panel filter
    And tabel menampilkan data default dengan maksimal 20 baris

  # ==========================================================================
  # POSITIVE - AREA 4: STATUS PENUGASAN (REQ-020 s.d. REQ-022, REQ-052)
  # ==========================================================================

  @positive @priority-high @REQ-020 @screen-143 @screen-127 @TC-P-023
  Scenario: Status awal penugasan adalah Belum Berangkat setelah tersimpan
    Given user berada di halaman "Tambah Penugasan"
    And user memilih order "LKL903902399"
    And user mengisi seluruh field required penugasan FTL
    When user mengklik tombol "Simpan"
    And user mengklik tombol "Ya" pada dialog konfirmasi
    Then sistem menampilkan notifikasi data tersimpan
    And user diarahkan ke halaman "Penugasan Tracking"
    And baris "LKL903902399" menampilkan badge status yang cocok dengan pola "Belum Berangkat|Menunggu Proses"

  @positive @priority-high @REQ-021 @REQ-052 @screen-isi-data-tracking @TC-P-024
  Scenario: Status berubah menjadi Dalam Perjalanan setelah data Selesai Muat tersimpan
    Given penugasan "ORD82090192" berstatus "Belum Berangkat"
    And user berada di halaman "Isi Data Tracking"
    When user memilih alamat muat pertama
    And user mengisi field "Tanggal Selesai Muat" dengan "01/06/2026 08:30"
    And user mengunggah 2 foto bukti berformat JPG
    And user mengklik tombol "Simpan"
    Then sistem menampilkan notifikasi data tersimpan
    And status penugasan "ORD82090192" cocok dengan pola "Dalam Perjalanan|Selesai Muat"

  @positive @priority-high @REQ-022 @screen-isi-data-tracking @TC-P-025
  Scenario: Status berubah menjadi Selesai setelah data Selesai Bongkar terakhir tersimpan
    Given penugasan "ORD82090192" berstatus "Dalam Perjalanan"
    And seluruh tahap Selesai Muat sudah terisi
    And user berada di halaman "Isi Data Tracking"
    When user mengisi field "Tanggal Selesai Bongkar" dengan "02/06/2026 16:00"
    And user mengunggah 1 foto bukti berformat PNG
    And user mengklik tombol "Simpan"
    Then sistem menampilkan notifikasi data tersimpan
    And status penugasan "ORD82090192" cocok dengan pola "Selesai|Selesai Bongkar"

  # ==========================================================================
  # POSITIVE - AREA 5: TAMBAH PENUGASAN UMUM (REQ-023 s.d. REQ-038)
  # ==========================================================================

  @positive @priority-high @REQ-023 @REQ-027 @REQ-036 @screen-143 @TC-P-026
  Scenario: Tambah penugasan FTL berhasil dari pemilihan order sampai notifikasi tersimpan
    Given user login sebagai "Vendor"
    And user berada di halaman "Tambah Penugasan"
    When user memilih order "LKL903902399" pada daftar "Pilih Order"
    Then field ringkasan order terisi otomatis dan read-only
    When user memilih "Pilih Dari Master" pada "Armada"
    And user memilih "L 1892 PGS" pada field "No. Polisi"
    And user memilih "Pilih Dari Master" pada "Sopir"
    And user memilih "Murtiono" pada field "Sopir"
    And user mengklik tombol "Simpan"
    And user mengklik tombol "Ya" pada dialog konfirmasi
    Then sistem menampilkan notifikasi data tersimpan
    And user diarahkan ke halaman "Penugasan Tracking"

  @positive @priority-high @REQ-024 @screen-134 @TC-P-027
  Scenario: Daftar Pilih Order hanya menampilkan order yang belum ditugaskan
    Given order "LKL903901897" belum memiliki penugasan
    And order "ORD82090192" sudah memiliki penugasan
    When user berada di halaman "Tambah Penugasan"
    Then daftar "Pilih Order" menampilkan "LKL903901897"
    And daftar "Pilih Order" tidak menampilkan "ORD82090192"

  @positive @priority-medium @REQ-025 @screen-134 @TC-P-028
  Scenario: Search order berdasarkan ID Order dan nama Kota
    Given user berada di halaman "Tambah Penugasan"
    When user mengisi field "Cari Order" dengan "LKL903902398"
    Then daftar "Pilih Order" hanya menampilkan order dengan ID "LKL903902398"
    When user mengisi field "Cari Order" dengan "Semarang"
    Then seluruh order pada daftar "Pilih Order" memuat kota "Semarang"

  @positive @priority-medium @REQ-026 @screen-134 @TC-P-029
  Scenario: Pemilihan order bersifat single selection
    Given user berada di halaman "Tambah Penugasan"
    And user memilih order "LKL903901897"
    When user memilih order "LKL903902398"
    Then order "LKL903902398" dalam keadaan terpilih
    And order "LKL903901897" tidak lagi terpilih
    And jumlah order terpilih adalah 1

  @positive @priority-high @REQ-027 @REQ-028 @screen-143 @TC-P-030
  Scenario: Data order ter-draft otomatis read-only dengan prefix wilayah
    Given user berada di halaman "Tambah Penugasan"
    When user memilih order "LKL903902399"
    Then field "Kota Asal" terisi otomatis dan read-only
    And field "Kota Tujuan" terisi otomatis dan read-only
    And field "Jenis Armada" terisi otomatis dan read-only
    And field "Jumlah Armada" terisi otomatis dan read-only
    And nilai "Kota Tujuan" adalah "Kota Semarang"
    And nilai "Kota Asal" cocok dengan pola "^(Kota|Kab\.) .+"

  @positive @priority-high @REQ-029 @screen-134 @TC-P-031
  Scenario: Jumlah card armada mengikuti jumlah armada pada order
    Given order "ORD-FTL-3ARM" memiliki Jumlah Armada 3
    And user berada di halaman "Tambah Penugasan"
    When user memilih order "ORD-FTL-3ARM"
    Then sistem menampilkan 3 card input armada
    And sistem menampilkan "Armada 1"
    And sistem menampilkan "Armada 3"

  @positive @priority-high @REQ-030 @screen-134 @TC-P-032
  Scenario: Order LTL selalu menampilkan satu card meskipun jumlah armada lebih dari satu
    Given order "LKL903901897" berjenis "LTL" dengan Jumlah Armada 4
    And user berada di halaman "Tambah Penugasan"
    When user memilih order "LKL903901897"
    Then sistem menampilkan 1 card input armada

  @positive @priority-high @REQ-030 @screen-134 @TC-P-033
  Scenario: Order LCL selalu menampilkan satu card kontainer
    Given order "LKL903900010" berjenis "LCL" dengan Jumlah Kontainer 2
    And user berada di halaman "Tambah Penugasan"
    When user memilih order "LKL903900010"
    Then sistem menampilkan 1 card input kontainer

  @positive @priority-high @REQ-031 @screen-143 @TC-P-034
  Scenario: Metode Pilih Dari Master menampilkan dropdown data master
    Given user berada di halaman "Tambah Penugasan"
    And user memilih order "LKL903902399"
    When user memilih "Pilih Dari Master" pada "Armada"
    Then sistem menampilkan dropdown "No. Polisi" dengan placeholder "Cari No. Polisi/Jenis Armada"
    When user memilih "Pilih Dari Master" pada "Sopir"
    Then sistem menampilkan dropdown "Sopir" dengan placeholder "Cari Sopir/No. WhatsApp"

  @positive @priority-high @REQ-032 @screen-144 @TC-P-035
  Scenario: Metode Isi Data Manual dapat disimpan tanpa mengisi No. WhatsApp
    Given user berada di halaman "Tambah Penugasan"
    And user memilih order "LKL903902399"
    When user memilih "Isi Data Manual" pada "Armada"
    And user mengisi field "No. Polisi" dengan "L 1892 PGS"
    And user memilih "Isi Data Manual" pada "Sopir"
    And user mengisi field "Nama Sopir" dengan "Murtiono"
    And user mengosongkan field "No. WhatsApp (opsional)"
    And user mengklik tombol "Simpan"
    And user mengklik tombol "Ya" pada dialog konfirmasi
    Then sistem menampilkan notifikasi data tersimpan

  @positive @priority-high @REQ-033 @screen-143 @TC-P-036
  Scenario: Dropdown master armada hanya menampilkan jenis armada yang dipesan
    Given order "LKL903902399" memesan jenis armada "Tronton Box"
    And user berada di halaman "Tambah Penugasan"
    And user memilih order "LKL903902399"
    When user memilih "Pilih Dari Master" pada "Armada"
    And user mengklik field "No. Polisi"
    Then seluruh opsi dropdown berjenis armada "Tronton Box"

  @positive @priority-high @REQ-035 @screen-134 @TC-P-037
  Scenario: Tombol Batal menampilkan alert konfirmasi dan membatalkan proses
    Given user berada di halaman "Tambah Penugasan"
    And user memilih order "LKL903902399"
    When user mengklik tombol "Batal"
    Then sistem menampilkan alert konfirmasi pembatalan
    When user mengklik tombol "Ya" pada alert konfirmasi
    Then user diarahkan ke halaman "Penugasan Tracking"
    And data penugasan tidak tersimpan

  @positive @priority-high @REQ-036 @screen-134 @TC-P-038
  Scenario: Tombol Simpan menampilkan dialog konfirmasi sebelum menyimpan
    Given user berada di halaman "Tambah Penugasan"
    And seluruh field required sudah terisi valid
    When user mengklik tombol "Simpan"
    Then sistem menampilkan dialog konfirmasi penyimpanan
    When user mengklik tombol "Ya" pada dialog konfirmasi
    Then sistem menampilkan notifikasi data tersimpan

  @positive @priority-high @REQ-037 @REQ-038 @screen-143 @TC-P-039
  Scenario: Tambah penugasan FTL dengan No. Polisi dan Sopir dari master
    Given user berada di halaman "Tambah Penugasan"
    And user memilih order "LKL903902399"
    When user memilih "Pilih Dari Master" pada "Armada"
    And user memilih "L54543 FDS - FUSO" pada field "No. Polisi"
    And user memilih "Pilih Dari Master" pada "Sopir"
    And user memilih "Alex - 62895397310385" pada field "Sopir"
    And user mengklik tombol "Simpan"
    And user mengklik tombol "Ya" pada dialog konfirmasi
    Then sistem menampilkan notifikasi data tersimpan

  @positive @priority-high @REQ-032 @REQ-037 @REQ-038 @screen-144 @TC-P-040
  Scenario: Tambah penugasan FTL dengan metode Isi Data Manual lengkap
    Given user berada di halaman "Tambah Penugasan"
    And user memilih order "LKL903902399"
    When user memilih "Isi Data Manual" pada "Armada"
    And user mengisi field "No. Polisi" dengan "P 7872 UJ"
    And user memilih "Isi Data Manual" pada "Sopir"
    And user mengisi field "Nama Sopir" dengan "M. Putra"
    And user mengisi field "No. WhatsApp (opsional)" dengan "082139240985"
    And user mengklik tombol "Simpan"
    And user mengklik tombol "Ya" pada dialog konfirmasi
    Then sistem menampilkan notifikasi data tersimpan

  # ==========================================================================
  # POSITIVE - AREA 6: TAMBAH PENUGASAN FCL/LCL (REQ-039 s.d. REQ-049)
  # ==========================================================================

  @positive @priority-high @REQ-039 @REQ-040 @REQ-041 @REQ-042 @REQ-043 @REQ-045 @REQ-047 @screen-134 @TC-P-041
  Scenario: Tambah penugasan FCL Door to Door dua kontainer dengan jadwal kapal Direct
    Given user berada di halaman "Tambah Penugasan"
    When user memilih order "LKL903902398" dengan metode pengiriman "Door to Door"
    Then sistem menampilkan 2 card input kontainer
    When user mengisi field "No. Kontainer" pada kontainer 1 dengan "CTN698383902"
    And user mengisi field "No. Segel" pada kontainer 1 dengan "SGL67930"
    And user memilih "L54543 FDS - FUSO" pada field "No. Polisi/Jenis Armada" kontainer 1
    And user memilih "Alex - 62895397310385" pada field "Sopir/No. WhatsApp" kontainer 1
    And user mengisi field "No. Kontainer" pada kontainer 2 dengan "CTN698383903"
    And user mengisi field "No. Segel" pada kontainer 2 dengan "SGL67931"
    And user memilih "L54544 FDS - FUSO" pada field "No. Polisi/Jenis Armada" kontainer 2
    And user memilih "Aldam - 62895397310211" pada field "Sopir/No. WhatsApp" kontainer 2
    And user memilih "Direct" pada "Jenis Jadwal Kapal"
    And user memilih "Parade" pada field "Pelayaran"
    And user mengisi field "Nama Kapal" dengan "KM. Malboure"
    And user mengisi field "Voyage" dengan "2"
    And user mengisi field "Closing Time" dengan "20/08/2026"
    And user mengisi field "Berangkat (ETD)" dengan "20/08/2026"
    And user mengisi field "Tiba (ETA)" dengan "25/08/2026"
    And user mengklik tombol "Simpan"
    And user mengklik tombol "Ya" pada dialog konfirmasi
    Then sistem menampilkan notifikasi data tersimpan
    And sistem tidak menampilkan tombol "Tambah Kapal Connecting"

  @positive @priority-high @REQ-046 @REQ-048 @screen-135 @TC-P-042
  Scenario: Jenis Jadwal Kapal Connecting dapat menambahkan lebih dari satu baris kapal
    Given user berada di halaman "Tambah Penugasan"
    And user memilih order FCL "LKL903902398"
    When user memilih "Connecting" pada "Jenis Jadwal Kapal"
    Then sistem menampilkan "Data Kapal Connecting"
    And sistem menampilkan tombol "Tambah Kapal Connecting"
    When user memilih "Tanjung Emas (SMG)" pada field "Pelabuhan Connecting"
    And user mengisi field "Kapal Connecting" dengan "KM. Nusantara"
    And user mengisi field "ETD Connecting" dengan "24/08/2026"
    And user mengklik tombol "Tambah Kapal Connecting"
    Then sistem menampilkan 2 baris "Data Kapal Connecting"
    When user melengkapi baris connecting kedua dengan ETD "25/08/2026"
    And user mengklik tombol "Simpan"
    And user mengklik tombol "Ya" pada dialog konfirmasi
    Then sistem menampilkan notifikasi data tersimpan

  @positive @priority-high @REQ-044 @screen-137 @TC-P-043
  Scenario: Metode CY to Door hanya menampilkan No. Kontainer dan No. Segel
    Given user berada di halaman "Tambah Penugasan"
    When user memilih order FCL dengan metode pengiriman "CY to Door"
    Then sistem menampilkan field "No. Kontainer"
    And sistem menampilkan field "No. Segel"
    And sistem tidak menampilkan field "Armada Muat"
    And sistem tidak menampilkan field "Sopir Muat"
    When user mengisi field "No. Kontainer" dengan "CTN700000001"
    And user mengisi field "No. Segel" dengan "SGL70001"
    And user melengkapi jadwal kapal
    And user mengklik tombol "Simpan"
    And user mengklik tombol "Ya" pada dialog konfirmasi
    Then sistem menampilkan notifikasi data tersimpan

  @positive @priority-high @REQ-044 @screen-137 @TC-P-044
  Scenario: Metode CY to CY hanya menampilkan No. Kontainer dan No. Segel
    Given user berada di halaman "Tambah Penugasan"
    When user memilih order FCL dengan metode pengiriman "CY to CY"
    Then sistem tidak menampilkan field "Armada Muat"
    And sistem tidak menampilkan field "Sopir Muat"
    When user mengisi field "No. Kontainer" dengan "CTN700000002"
    And user mengisi field "No. Segel" dengan "SGL70002"
    And user melengkapi jadwal kapal
    And user mengklik tombol "Simpan"
    And user mengklik tombol "Ya" pada dialog konfirmasi
    Then sistem menampilkan notifikasi data tersimpan

  @positive @priority-high @REQ-044 @screen-136 @TC-P-045
  Scenario: Metode Door to CY tetap menampilkan Armada Muat dan Sopir Muat
    Given user berada di halaman "Tambah Penugasan"
    When user memilih order FCL dengan metode pengiriman "Door to CY"
    Then sistem menampilkan field "Armada Muat"
    And sistem menampilkan field "Sopir Muat"
    And sistem menampilkan field "No. Kontainer"
    And sistem menampilkan field "No. Segel"

  @positive @priority-medium @REQ-045 @screen-134 @TC-P-046
  Scenario: Jadwal kapal ditetapkan satu kali untuk seluruh kontainer
    Given user berada di halaman "Tambah Penugasan"
    When user memilih order FCL dengan Jumlah Kontainer 2
    Then sistem menampilkan 2 card input kontainer
    And sistem menampilkan 1 section "Detail Kapal Utama"
    And section "Detail Kapal Utama" berada di luar card kontainer

  # ==========================================================================
  # POSITIVE - AREA 7: ISI DATA TRACKING (REQ-050 s.d. REQ-063) - selector asumsi D-17
  # ==========================================================================

  @positive @priority-high @REQ-053 @screen-isi-data-tracking @TC-P-047
  Scenario: Halaman Isi Data Tracking menampilkan informasi order secara read-only
    Given user berada di halaman "Penugasan Tracking"
    When user mengklik menu aksi "Isi Data Tracking" pada baris "ORD82090192"
    Then user diarahkan ke halaman "Isi Data Tracking"
    And sistem menampilkan informasi "ID Order" read-only
    And sistem menampilkan informasi "Jenis Order" read-only
    And sistem menampilkan informasi "Rute" read-only
    And sistem menampilkan informasi "Tanggal Muat" read-only
    And sistem menampilkan informasi "Nopol" read-only
    And sistem menampilkan informasi "Jenis Armada/Kontainer" read-only
    And sistem menampilkan informasi "Sopir" read-only

  @positive @priority-high @REQ-051 @screen-isi-data-tracking @TC-P-048
  Scenario: Halaman Isi Data Tracking hanya menyediakan tahap Selesai Muat dan Selesai Bongkar
    Given user berada di halaman "Isi Data Tracking"
    Then sistem menampilkan tahap "Selesai Muat"
    And sistem menampilkan tahap "Selesai Bongkar"
    And form input tidak menyediakan tahap selain "Selesai Muat" dan "Selesai Bongkar"

  @positive @priority-high @REQ-054 @screen-isi-data-tracking @TC-P-049
  Scenario: Form Isi Data Tracking dipisah per kota drop
    Given order "ORD-MULTIDROP-3" memiliki 3 kota drop
    When user berada di halaman "Isi Data Tracking" untuk order "ORD-MULTIDROP-3"
    Then sistem menampilkan 3 section form tracking terpisah
    And setiap section diberi judul sesuai nama kota drop

  @positive @priority-high @REQ-055 @screen-isi-data-tracking @TC-P-050
  Scenario: Memilih alamat membuat data pengiriman dan nama perusahaan ter-draft read-only
    Given user berada di halaman "Isi Data Tracking"
    When user memilih alamat "Jl. Raya Bandara No.1, Kota Surabaya"
    Then field data pengiriman terisi otomatis dan read-only
    And field nama perusahaan terisi otomatis dan read-only

  @positive @priority-high @REQ-056 @screen-isi-data-tracking @TC-P-051
  Scenario: Tanggal selesai muat diisi melalui datepicker dengan format DD/MM/YYYY HH:mm
    Given user berada di halaman "Isi Data Tracking"
    When user mengklik field "Tanggal Selesai Muat"
    Then sistem menampilkan date picker
    When user memilih tanggal "01/06/2026" dan waktu "08:30"
    Then nilai field "Tanggal Selesai Muat" adalah "01/06/2026 08:30"

  @positive @priority-high @REQ-057 @REQ-059 @screen-isi-data-tracking @TC-P-052
  Scenario: Upload foto JPG dan PNG berhasil serta keterangan bersifat opsional
    Given user berada di halaman "Isi Data Tracking"
    And user mengisi field "Tanggal Selesai Muat" dengan "01/06/2026 08:30"
    When user mengunggah file "bukti-1.jpg" berukuran 1 MB
    And user mengunggah file "bukti-2.png" berukuran 2 MB
    Then sistem menampilkan 2 thumbnail foto terunggah
    And sistem tidak menampilkan alert batas foto
    When user mengosongkan field "Keterangan"
    And user mengklik tombol "Simpan"
    Then sistem menampilkan notifikasi data tersimpan

  @positive @priority-high @REQ-060 @REQ-062 @screen-isi-data-tracking @TC-P-053
  Scenario: Simpan data tracking melanjutkan ke tahap berikutnya tanpa keluar halaman
    Given order "ORD-MULTIDROP-3" memiliki 3 kota drop
    And user berada di halaman "Isi Data Tracking" untuk order "ORD-MULTIDROP-3"
    And user melengkapi form tahap "Selesai Muat" untuk kota drop "Kota Semarang"
    When user mengklik tombol "Simpan"
    Then sistem menampilkan notifikasi data tersimpan
    And user tetap berada di halaman "Isi Data Tracking"
    And section "Kota Semarang" dalam keadaan ter-collapse
    And section kota/tahap berikutnya dalam keadaan terbuka

  @positive @priority-high @REQ-061 @screen-isi-data-tracking @TC-P-054
  Scenario: Tombol Kembali mengarahkan user ke halaman Penugasan Tracking
    Given user berada di halaman "Isi Data Tracking"
    When user mengklik tombol "Kembali"
    Then user diarahkan ke halaman "Penugasan Tracking"

  @positive @priority-high @REQ-063 @screen-isi-data-tracking @TC-P-055
  Scenario: FCL dapat mengubah No. Kontainer dan No. Segel pada tahap Selesai Muat
    Given penugasan FCL "ORD76392092" berada pada tahap "Selesai Muat"
    And user berada di halaman "Isi Data Tracking"
    Then field "No. Kontainer" dalam keadaan editable
    And field "No. Segel" dalam keadaan editable
    When user mengisi field "No. Kontainer" dengan "CTN999888777"
    And user mengisi field "No. Segel" dengan "SGL99988"
    And user melengkapi tanggal dan foto tahap "Selesai Muat"
    And user mengklik tombol "Simpan"
    Then sistem menampilkan notifikasi data tersimpan
    And nilai "No. Kontainer" tersimpan sebagai "CTN999888777"

  # ==========================================================================
  # POSITIVE - AREA 8: PENUGASAN SOPIR BONGKAR (REQ-064 s.d. REQ-067)
  # ==========================================================================

  @positive @priority-high @REQ-064 @REQ-065 @screen-140 @TC-P-056
  Scenario: Metode CY to Door menampilkan opsi tugaskan sopir bongkar dan tersimpan dari master
    Given penugasan FCL "ORD45672033" memiliki metode pengiriman "CY to Door"
    And penugasan berada pada tahap "Selesai Bongkar"
    And user berada di halaman "Isi Data Tracking"
    Then sistem menampilkan opsi "Penugasan Sopir Bongkar"
    When user mengklik tombol "Penugasan Sopir Bongkar"
    And user memilih "Pilih Dari Master" pada "Armada Bongkar"
    And user memilih "L54543 FDS - FUSO" pada field "No. Polisi/Jenis Armada"
    And user memilih "Pilih Dari Master" pada "Sopir Bongkar"
    And user memilih "Bahlyl Lyla - 082139240985" pada field "Sopir/No. WhatsApp"
    And user mengisi field "Tanggal Permintaan Bongkar" dengan "07/06/2026 13:30"
    And user mengklik tombol "Simpan"
    Then sistem menampilkan notifikasi data tersimpan

  @positive @priority-high @REQ-064 @REQ-065 @screen-140 @TC-P-057
  Scenario: Metode Door to Door dapat menugaskan sopir bongkar dengan metode Isi Data Manual
    Given penugasan FCL "ORD45672033" memiliki metode pengiriman "Door to Door"
    And user berada di halaman "Penugasan Sopir Bongkar"
    When user memilih "Isi Data Manual" pada "Armada Bongkar"
    And user mengisi field "No. Polisi" dengan "B 7930 HD"
    And user memilih "Isi Data Manual" pada "Sopir Bongkar"
    And user mengisi field "Nama Sopir" dengan "Yunita"
    And user mengisi field "Tanggal Permintaan Bongkar" dengan "07/06/2026 13:30"
    And user mengklik tombol "Simpan"
    Then sistem menampilkan notifikasi data tersimpan

  @positive @priority-high @REQ-066 @screen-140 @screen-isi-data-tracking @TC-P-058
  Scenario: Batal pada form penugasan sopir bongkar mengembalikan user ke halaman Isi Data Tracking
    Given penugasan FCL "ORD45672033" memiliki metode pengiriman "Door to Door"
    And user berada di halaman "Isi Data Tracking" pada tahap "Selesai Bongkar"
    And user mengklik tombol "Penugasan Sopir Bongkar"
    And user berada di halaman "Penugasan Sopir Bongkar"
    When user mengklik tombol "Batal"
    And user mengonfirmasi pembatalan
    Then user diarahkan ke halaman "Isi Data Tracking"
    But user tidak diarahkan ke halaman "Penugasan Tracking"

  # ==========================================================================
  # POSITIVE - AREA 9: DETAIL PENUGASAN & RIWAYAT (REQ-068 s.d. REQ-074, REQ-080)
  # ==========================================================================

  @positive @priority-high @REQ-068 @REQ-069 @REQ-070 @REQ-071 @screen-133a @screen-146 @TC-P-059
  Scenario: Detail Penugasan LTL menampilkan seluruh bagian informasi
    Given user berada di halaman "Penugasan Tracking"
    When user mengklik menu aksi "Detail Penugasan" pada baris "LTL0152708249"
    Then user diarahkan ke halaman "Detail Penugasan"
    And sistem menampilkan "Detail Data Order"
    And sistem menampilkan field "ID Order" bernilai "LTL0152708249"
    And sistem menampilkan field "Jenis Armada" bernilai "Tronton Wing Box"
    And sistem menampilkan field "Kapasitas Armada" bernilai "5000 kg / 36 m³"
    And sistem menampilkan field "Tanggal Permintaan Muat" bernilai "31/05/2026 14:30"
    And sistem tidak menampilkan field "Metode Pengiriman"
    And sistem menampilkan "Informasi Penugasan"
    And sistem menampilkan field "No. Polisi" bernilai "GK6802BOX"
    And sistem menampilkan field "Nama Sopir" bernilai "Kenzo Nonoya"
    And sistem menampilkan field "No. WA Sopir" bernilai "082139240985"
    And sistem menampilkan "History Tracking"

  @positive @priority-high @REQ-069 @REQ-070 @REQ-064 @screen-147 @screen-148 @TC-P-060
  Scenario: Detail Penugasan FCL menampilkan Jenis Kontainer, Metode Pengiriman, serta penugasan muat dan bongkar
    Given user berada di halaman "Detail Penugasan" untuk order "FCL0152708249"
    Then sistem menampilkan field "Jenis Kontainer" bernilai "20 DRY"
    And sistem menampilkan field "Kapasitas Kontainer"
    And sistem menampilkan field "Metode Pengiriman" bernilai "Door to Door"
    And sistem menampilkan field "Pelabuhan Asal" bernilai "Tanjung Perak (SUB)"
    And sistem menampilkan field "No. Kontainer"
    And sistem menampilkan field "No. Segel"
    And sistem menampilkan informasi penugasan muat dengan "No. Polisi" bernilai "GK6802BOX"
    And sistem menampilkan informasi penugasan bongkar dengan "Nama Sopir" bernilai "Bahlyl Lyla"
    And sistem menampilkan field "Tanggal Permintaan Bongkar" bernilai "07/06/2026 13:30"

  @positive @priority-high @REQ-072 @REQ-073 @screen-pop-up-2 @TC-P-061
  Scenario: Pop-up Riwayat Penugasan menampilkan tanggal perubahan, armada, dan sopir
    Given user berada di halaman "Detail Penugasan" untuk order "LTL0152708249"
    When user mengklik pemicu riwayat penugasan "Lihat Detail"
    Then sistem menampilkan dialog "Riwayat Penugasan"
    And dialog menampilkan "Tanggal Perubahan" bernilai "16/04/2026 12:05"
    And dialog menampilkan "Armada" bernilai "L 6818 PLT • Tronton Box"
    And dialog menampilkan "Sopir" bernilai "Suwarna Warni • 0815678929332"
    And dialog bersifat read-only

  @positive @priority-high @REQ-074 @screen-pop-up-3 @TC-P-062
  Scenario: Perubahan parsial menampilkan strip pada data yang tidak berubah
    Given penugasan "LTL0152708249" pernah diubah hanya pada data armada
    And user berada di halaman "Detail Penugasan" untuk order "LTL0152708249"
    When user mengklik pemicu riwayat penugasan "Lihat Detail"
    Then baris riwayat "11/09/2026 10:05" menampilkan armada "L 1820 PLT • Tronton Box"
    And baris riwayat "11/09/2026 10:05" menampilkan sopir "-"

  @positive @priority-high @REQ-080 @screen-128 @screen-pop-up-3 @TC-P-063
  Scenario: Riwayat Perubahan dapat dibuka langsung dari action menu daftar
    Given user berada di halaman "Penugasan Tracking"
    When user mengklik menu aksi "Riwayat Perubahan" pada baris "ORD76392092"
    Then sistem menampilkan dialog "Riwayat Penugasan"
    And dialog menampilkan kolom "Tanggal Perubahan"
    And dialog menampilkan kolom "Armada"
    And dialog menampilkan kolom "Sopir"

  # ==========================================================================
  # POSITIVE - AREA 10: EDIT PENUGASAN (REQ-075 s.d. REQ-079)
  # ==========================================================================

  @positive @priority-high @REQ-075 @screen-149 @TC-P-064
  Scenario: Informasi Order pada halaman Edit untuk order FCL menampilkan seluruh field
    Given user berada di halaman "Penugasan Tracking"
    When user mengklik menu aksi "Edit Penugasan" pada baris "ORD6093390506"
    Then user diarahkan ke halaman "Edit Penugasan"
    And sistem menampilkan field "ID Order" bernilai "ORD6093390506"
    And sistem menampilkan field "Vendor" bernilai "SPS SF"
    And sistem menampilkan field "Kota Asal"
    And sistem menampilkan field "Kota Tujuan"
    And sistem menampilkan field "Pelabuhan Asal" bernilai "Tanjung Perak (SUB)"
    And sistem menampilkan field "Pelabuhan Tujuan" bernilai "Makassar (MAK)"
    And sistem menampilkan field "Jenis Kontainer" bernilai "20 DRY"
    And sistem menampilkan field "Jumlah Kontainer" bernilai "2"
    And sistem menampilkan field "Metode Pengiriman" bernilai "Door to Door"
    And sistem menampilkan field "Tanggal Permintaan Muat"

  @positive @priority-high @REQ-075 @screen-149 @TC-P-065
  Scenario: Informasi Order pada halaman Edit untuk order FTL tanpa field khusus FCL
    Given user berada di halaman "Edit Penugasan" untuk order FTL "LKL903902399"
    Then sistem menampilkan field "Jenis Armada"
    And sistem menampilkan field "Jumlah Armada"
    And sistem tidak menampilkan field "Pelabuhan Asal"
    And sistem tidak menampilkan field "Pelabuhan Tujuan"
    And sistem tidak menampilkan field "Metode Pengiriman"

  @positive @priority-high @REQ-076 @screen-149 @TC-P-066
  Scenario: Mengubah nopol dan sopir FTL saat status Belum Berangkat berhasil dan tercatat
    Given penugasan FTL "LKL903902399" berstatus "Belum Berangkat"
    And user berada di halaman "Edit Penugasan"
    Then field "No. Polisi" dalam keadaan enabled
    And field "Sopir" dalam keadaan enabled
    When user mengisi field "No. Polisi" dengan "L 6818 PLT"
    And user memilih "Isi Data Manual" pada "Sopir"
    And user mengisi field "Nama Sopir" dengan "Darmaji"
    And user mengklik tombol "Simpan"
    And user mengklik tombol "Ya" pada dialog konfirmasi
    Then sistem menampilkan notifikasi data tersimpan
    And riwayat penugasan memuat armada "L 6818 PLT"
    And riwayat penugasan memuat sopir "Darmaji"

  @positive @priority-high @REQ-077 @screen-150 @TC-P-067
  Scenario: Mengubah nopol/armada FCL sebelum status Selesai Muat berhasil
    Given penugasan FCL "ORD6093390506" berstatus "Belum Berangkat"
    And user berada di halaman "Edit Penugasan"
    Then field "No. Polisi/Jenis Armada" dalam keadaan enabled
    When user memilih "L54544 FDS - FUSO" pada field "No. Polisi/Jenis Armada"
    And user mengklik tombol "Simpan"
    And user mengklik tombol "Ya" pada dialog konfirmasi
    Then sistem menampilkan notifikasi data tersimpan

  @positive @priority-high @REQ-078 @screen-149 @TC-P-068
  Scenario: Mengubah No. Kontainer dan No. Segel saat status Menunggu Proses berhasil
    Given penugasan FCL "ORD6093390506" berstatus "Menunggu Proses"
    And user berada di halaman "Edit Penugasan"
    Then field "No. Kontainer" dalam keadaan enabled
    And field "No. Segel" dalam keadaan enabled
    When user mengisi field "No. Kontainer" dengan "KTN5778290939"
    And user mengisi field "No. Segel" dengan "SGL09892798232"
    And user mengklik tombol "Simpan"
    And user mengklik tombol "Ya" pada dialog konfirmasi
    Then sistem menampilkan notifikasi data tersimpan

  @positive @priority-high @REQ-079 @screen-150 @TC-P-069
  Scenario: Mengubah jadwal kapal sebelum status Selesai Muat berhasil
    Given penugasan FCL "ORD6093390506" berstatus "Belum Berangkat"
    And user berada di halaman "Edit Penugasan"
    Then section "Detail Kapal Utama" dalam keadaan enabled
    When user mengisi field "Nama Kapal" dengan "KM. Sinar Jaya"
    And user mengisi field "Tiba (ETA)" dengan "27/08/2026"
    And user mengklik tombol "Simpan"
    And user mengklik tombol "Ya" pada dialog konfirmasi
    Then sistem menampilkan notifikasi data tersimpan

  # ==========================================================================
  # NEGATIVE - HAK AKSES (REQ-001 s.d. REQ-003, REQ-050)
  # ==========================================================================

  @negative @priority-high @REQ-002 @screen-127 @TC-N-001
  Scenario: Shipper tanpa vendor kelolaan tidak dapat menambah penugasan
    Given user login sebagai "Shipper" yang tidak mengelola vendor manapun
    When user berada di halaman "Penugasan Tracking"
    Then tombol "Tambah Penugasan" tidak tersedia atau dalam keadaan disabled

  @negative @priority-high @REQ-002 @REQ-007 @screen-128 @TC-N-002
  Scenario: Shipper tanpa vendor kelolaan hanya dapat melihat detail
    Given user login sebagai "Shipper" yang tidak mengelola vendor manapun
    And user berada di halaman "Penugasan Tracking"
    When user mengklik tombol "Aksi" pada baris "ORD82090192"
    Then menu "Detail Penugasan" dalam keadaan enabled
    And menu "Edit Penugasan" tidak tersedia atau dalam keadaan disabled
    And menu "Isi Data Tracking" tidak tersedia atau dalam keadaan disabled

  @negative @priority-high @REQ-002 @screen-134 @TC-N-003
  Scenario: Shipper tanpa vendor kelolaan mengakses URL Tambah Penugasan secara langsung
    Given user login sebagai "Shipper" yang tidak mengelola vendor manapun
    When user membuka URL halaman "Tambah Penugasan" secara langsung
    Then sistem menolak akses dan menampilkan pesan tidak berwenang
    And user tidak berada di halaman "Tambah Penugasan"

  @negative @priority-high @REQ-001 @screen-127 @TC-N-004
  Scenario: Shipper pengelola vendor X tidak dapat mengubah order milik vendor Y
    Given user login sebagai "Shipper" yang mengelola vendor "JNE"
    And terdapat order "ORD-VENDOR-Y" milik vendor "SPS SF"
    And user berada di halaman "Penugasan Tracking"
    When user mengklik tombol "Aksi" pada baris "ORD-VENDOR-Y"
    Then menu "Edit Penugasan" tidak tersedia atau dalam keadaan disabled
    And menu "Isi Data Tracking" tidak tersedia atau dalam keadaan disabled

  @negative @priority-medium @REQ-050 @screen-isi-data-tracking @TC-N-005
  Scenario: Update tracking dari Driver Hub tidak memengaruhi data tracking OMS
    Given penugasan "ORD82090192" berstatus "Belum Berangkat"
    When driver melakukan update tahap "Selesai Muat" melalui Driver Hub
    And user berada di halaman "Penugasan Tracking"
    Then badge status baris "ORD82090192" tetap cocok dengan pola "Belum Berangkat|Menunggu Proses"
    And form tahap "Selesai Muat" pada halaman "Isi Data Tracking" masih kosong

  # ==========================================================================
  # NEGATIVE - DAFTAR & FILTER (REQ-004 s.d. REQ-019)
  # ==========================================================================

  @negative @priority-low @REQ-004 @screen-127 @TC-N-006
  Scenario: Navigasi ke nomor halaman melebihi total halaman tidak menimbulkan error
    Given tersedia 30 data penugasan tracking
    And user berada di halaman "Penugasan Tracking"
    When user membuka halaman pagination nomor 99
    Then sistem tidak menampilkan error aplikasi
    And sistem menampilkan halaman terakhir yang valid atau state data kosong

  @negative @priority-medium @REQ-009 @screen-127 @TC-N-007
  Scenario: Filter ID Order yang tidak terdaftar menampilkan state data kosong
    Given user berada di halaman "Penugasan Tracking"
    When user mengisi field "ID Order" dengan "ORD00000000"
    And user mengklik tombol "Terapkan"
    Then sistem menampilkan state data kosong
    And tabel penugasan tidak menampilkan baris data

  @negative @priority-medium @REQ-019 @REQ-010 @REQ-013 @screen-127 @TC-N-008
  Scenario: Kombinasi filter yang saling bertentangan menampilkan state data kosong
    Given user berada di halaman "Penugasan Tracking"
    When user memilih "FTL" pada field "Jenis Shipment"
    And user mengisi field "No. Polisi/No. Kontainer" dengan "CNT728900287"
    And user mengklik tombol "Terapkan"
    Then sistem menampilkan state data kosong

  @negative @priority-medium @REQ-009 @screen-127 @TC-N-009
  Scenario: Input SQL injection pada filter ID Order tidak merusak sistem
    Given user berada di halaman "Penugasan Tracking"
    When user mengisi field "ID Order" dengan "' OR 1=1; DROP TABLE penugasan;--"
    And user mengklik tombol "Terapkan"
    Then sistem tidak menampilkan error aplikasi
    And sistem menampilkan state data kosong
    And data penugasan tetap utuh

  @negative @priority-medium @REQ-014 @screen-127 @TC-N-010
  Scenario: Input script XSS pada filter Sopir di-escape oleh sistem
    Given user berada di halaman "Penugasan Tracking"
    When user mengisi field "Sopir" dengan "<script>alert('xss')</script>"
    And user mengklik tombol "Terapkan"
    Then sistem tidak mengeksekusi script
    And sistem menampilkan state data kosong

  @negative @priority-low @REQ-011 @REQ-012 @screen-127 @TC-N-011
  Scenario: Filter Kota Asal tidak menerima nilai di luar data master
    Given user berada di halaman "Penugasan Tracking"
    When user mengetik "Kota Antah Berantah" pada field "Kota Asal"
    Then dropdown tidak menampilkan opsi yang cocok
    And nilai field "Kota Asal" tidak tersimpan sebagai kriteria filter

  @negative @priority-low @REQ-016 @screen-127 @TC-N-012
  Scenario: Nilai status di luar daftar ditolak oleh sistem
    Given user berada di halaman "Penugasan Tracking"
    When user mengirim permintaan filter dengan status "STATUS_TIDAK_VALID"
    Then sistem menolak nilai status tersebut
    And sistem tidak menampilkan error aplikasi

  @negative @priority-high @REQ-015 @screen-127 @TC-N-013
  Scenario: Filter Tahap Pengiriman tidak menampilkan order yang belum pernah mencapai tahap tersebut
    Given order "ORD-BARU-001" berstatus "Belum Berangkat" dan belum pernah update tahap manapun
    And user berada di halaman "Penugasan Tracking"
    When user memilih "Selesai Muat" pada field "Tahap Pengiriman"
    And user mengklik tombol "Terapkan"
    Then tabel tidak menampilkan baris "ORD-BARU-001"

  # ==========================================================================
  # NEGATIVE - STATUS & TRANSISI (REQ-020 s.d. REQ-022, REQ-051)
  # ==========================================================================

  @negative @priority-high @REQ-021 @REQ-022 @REQ-051 @screen-isi-data-tracking @TC-N-014
  Scenario: Mengisi Selesai Bongkar sebelum Selesai Muat diblokir sistem
    Given penugasan "ORD82090192" berstatus "Belum Berangkat"
    And user berada di halaman "Isi Data Tracking"
    When user mencoba membuka form tahap "Selesai Bongkar"
    Then form tahap "Selesai Bongkar" dalam keadaan disabled atau tidak dapat disimpan
    And status penugasan tetap cocok dengan pola "Belum Berangkat|Menunggu Proses"

  @negative @priority-low @REQ-020 @screen-127 @TC-N-015
  Scenario: Penugasan berstatus Dibatalkan tidak dapat diisi data tracking
    Given penugasan "ORD0082636" berstatus "Dibatalkan"
    And user berada di halaman "Penugasan Tracking"
    When user mengklik tombol "Aksi" pada baris "ORD0082636"
    Then menu "Isi Data Tracking" tidak tersedia atau dalam keadaan disabled

  # ==========================================================================
  # NEGATIVE - TAMBAH PENUGASAN UMUM (REQ-023 s.d. REQ-038)
  # ==========================================================================

  @negative @priority-high @REQ-023 @screen-134 @TC-N-016
  Scenario: Menyimpan penugasan tanpa memilih order diblokir
    Given user berada di halaman "Tambah Penugasan"
    And user belum memilih order manapun
    When user mengklik tombol "Simpan"
    Then sistem menampilkan pesan error pada bagian "Pilih Order"
    And data penugasan tidak tersimpan
    And user tetap berada di halaman "Tambah Penugasan"

  @negative @priority-high @REQ-024 @screen-134 @TC-N-017
  Scenario: Order yang sudah ditugaskan tidak muncul pada hasil pencarian
    Given order "ORD82090192" sudah memiliki penugasan
    And user berada di halaman "Tambah Penugasan"
    When user mengisi field "Cari Order" dengan "ORD82090192"
    Then daftar "Pilih Order" tidak menampilkan "ORD82090192"
    And sistem menampilkan state hasil pencarian kosong

  @negative @priority-medium @REQ-027 @screen-143 @TC-N-018
  Scenario: Field hasil auto-draft tidak dapat diubah user
    Given user berada di halaman "Tambah Penugasan"
    And user memilih order "LKL903902399"
    When user mencoba mengisi field "Kota Asal" dengan "Kota Malang"
    Then nilai field "Kota Asal" tidak berubah
    And field "Kota Asal" dalam keadaan read-only

  @negative @priority-high @REQ-034 @screen-143 @TC-N-019
  Scenario: Field required kosong menampilkan helper error dan border error
    Given user berada di halaman "Tambah Penugasan"
    And user memilih order "LKL903902399"
    When user mengosongkan field "No. Polisi"
    And user mengklik tombol "Simpan"
    Then sistem menampilkan helper error di bawah field "No. Polisi"
    And border field "No. Polisi" berwarna error
    And data penugasan tidak tersimpan

  @negative @priority-medium @REQ-035 @screen-134 @TC-N-020
  Scenario: Membatalkan alert konfirmasi Batal membuat user tetap di form dengan data utuh
    Given user berada di halaman "Tambah Penugasan"
    And user telah mengisi field "No. Polisi" dengan "L 1892 PGS"
    When user mengklik tombol "Batal"
    And user mengklik tombol "Tidak" pada alert konfirmasi
    Then user tetap berada di halaman "Tambah Penugasan"
    And nilai field "No. Polisi" tetap "L 1892 PGS"

  @negative @priority-high @REQ-036 @screen-134 @TC-N-021
  Scenario: Membatalkan dialog konfirmasi Simpan membuat data tidak tersimpan
    Given user berada di halaman "Tambah Penugasan"
    And seluruh field required sudah terisi valid
    When user mengklik tombol "Simpan"
    And user mengklik tombol "Tidak" pada dialog konfirmasi
    Then sistem tidak menampilkan notifikasi data tersimpan
    And user tetap berada di halaman "Tambah Penugasan"
    And data penugasan tidak tersimpan

  @negative @priority-high @REQ-033 @screen-143 @TC-N-022
  Scenario: Dropdown master armada tidak menampilkan jenis armada di luar pesanan order
    Given order "LKL903902399" memesan jenis armada "Tronton Box"
    And terdapat armada master berjenis "Engkel Bak"
    And user berada di halaman "Tambah Penugasan"
    And user memilih order "LKL903902399"
    When user mengklik field "No. Polisi"
    Then dropdown tidak menampilkan armada berjenis "Engkel Bak"

  @negative @priority-high @REQ-037 @screen-143 @TC-N-023
  Scenario: Menyimpan penugasan FTL tanpa No. Polisi diblokir
    Given user berada di halaman "Tambah Penugasan"
    And user memilih order FTL "LKL903902399"
    And user telah mengisi field "Nama Sopir" dengan "Murtiono"
    When user mengklik tombol "Simpan"
    Then sistem menampilkan helper error di bawah field "No. Polisi"
    And data penugasan tidak tersimpan

  @negative @priority-high @REQ-038 @screen-143 @TC-N-024
  Scenario: Menyimpan penugasan FTL tanpa Sopir diblokir
    Given user berada di halaman "Tambah Penugasan"
    And user memilih order FTL "LKL903902399"
    And user telah mengisi field "No. Polisi" dengan "L 1892 PGS"
    When user mengklik tombol "Simpan"
    Then sistem menampilkan helper error di bawah field "Sopir"
    And data penugasan tidak tersimpan

  # ==========================================================================
  # NEGATIVE - TAMBAH PENUGASAN FCL/LCL (REQ-039 s.d. REQ-049)
  # ==========================================================================

  @negative @priority-high @REQ-039 @screen-134 @TC-N-025
  Scenario: Menyimpan penugasan FCL tanpa No. Kontainer diblokir
    Given user berada di halaman "Tambah Penugasan"
    And user memilih order FCL "LKL903902398"
    And user mengosongkan field "No. Kontainer" pada kontainer 1
    When user mengklik tombol "Simpan"
    Then sistem menampilkan helper error di bawah field "No. Kontainer"
    And data penugasan tidak tersimpan

  @negative @priority-high @REQ-040 @screen-134 @TC-N-026
  Scenario: Menyimpan penugasan FCL tanpa No. Segel diblokir
    Given user berada di halaman "Tambah Penugasan"
    And user memilih order FCL "LKL903902398"
    And user mengosongkan field "No. Segel" pada kontainer 1
    When user mengklik tombol "Simpan"
    Then sistem menampilkan helper error di bawah field "No. Segel"
    And data penugasan tidak tersimpan

  @negative @priority-high @REQ-041 @screen-134 @TC-N-027
  Scenario: Menyimpan penugasan FCL Door to Door tanpa Armada Muat diblokir
    Given user berada di halaman "Tambah Penugasan"
    And user memilih order FCL dengan metode pengiriman "Door to Door"
    And user mengosongkan field "No. Polisi/Jenis Armada" pada kontainer 1
    When user mengklik tombol "Simpan"
    Then sistem menampilkan helper error pada field "Armada Muat"
    And data penugasan tidak tersimpan

  @negative @priority-high @REQ-042 @screen-134 @TC-N-028
  Scenario: Menyimpan penugasan FCL Door to Door tanpa Sopir Muat diblokir
    Given user berada di halaman "Tambah Penugasan"
    And user memilih order FCL dengan metode pengiriman "Door to Door"
    And user mengosongkan field "Sopir/No. WhatsApp" pada kontainer 1
    When user mengklik tombol "Simpan"
    Then sistem menampilkan helper error pada field "Sopir Muat"
    And data penugasan tidak tersimpan

  @negative @priority-high @REQ-043 @screen-134 @TC-N-029
  Scenario: Menyimpan penugasan FCL tanpa jadwal kapal diblokir
    Given user berada di halaman "Tambah Penugasan"
    And user memilih order FCL "LKL903902398"
    And seluruh field kontainer sudah terisi valid
    When user mengosongkan field "Pelayaran"
    And user mengosongkan field "Nama Kapal"
    And user mengklik tombol "Simpan"
    Then sistem menampilkan helper error pada section "Detail Kapal Utama"
    And data penugasan tidak tersimpan

  @negative @priority-high @REQ-046 @screen-134 @TC-N-030
  Scenario: Menyimpan penugasan FCL tanpa memilih Jenis Jadwal Kapal diblokir
    Given user berada di halaman "Tambah Penugasan"
    And user memilih order FCL "LKL903902398"
    And user belum memilih "Jenis Jadwal Kapal"
    When user mengklik tombol "Simpan"
    Then sistem menampilkan helper error pada field "Jenis Jadwal Kapal"
    And data penugasan tidak tersimpan

  @negative @priority-high @REQ-047 @screen-134 @TC-N-031
  Scenario: Jenis Jadwal Kapal Direct tidak menyediakan penambahan kapal connecting
    Given user berada di halaman "Tambah Penugasan"
    And user memilih order FCL "LKL903902398"
    When user memilih "Direct" pada "Jenis Jadwal Kapal"
    Then sistem tidak menampilkan tombol "Tambah Kapal Connecting"
    And sistem tidak menampilkan "Data Kapal Connecting"

  @negative @priority-high @REQ-049 @screen-135 @TC-N-032
  Scenario: ETD kapal connecting melebihi ETA kapal utama diblokir
    Given user berada di halaman "Tambah Penugasan"
    And user memilih order FCL "LKL903902398"
    And user mengisi field "Tiba (ETA)" dengan "25/08/2026"
    When user memilih "Connecting" pada "Jenis Jadwal Kapal"
    And user mengisi field "ETD Connecting" dengan "26/08/2026"
    And user mengklik tombol "Simpan"
    Then sistem menampilkan pesan error validasi pada field "ETD Connecting"
    And data penugasan tidak tersimpan

  @negative @priority-high @REQ-044 @screen-137 @TC-N-033
  Scenario: Field armada dan sopir tidak dirender pada metode CY to Door
    Given user berada di halaman "Tambah Penugasan"
    When user memilih order FCL dengan metode pengiriman "CY to Door"
    Then field "No. Polisi/Jenis Armada" tidak ada pada halaman
    And field "Sopir/No. WhatsApp" tidak ada pada halaman
    And sistem tidak memvalidasi required untuk Armada Muat dan Sopir Muat

  # ==========================================================================
  # NEGATIVE - ISI DATA TRACKING (REQ-053 s.d. REQ-063)
  # ==========================================================================

  @negative @priority-high @REQ-056 @screen-isi-data-tracking @TC-N-034
  Scenario: Menyimpan data tracking tanpa tanggal diblokir
    Given user berada di halaman "Isi Data Tracking"
    And user mengunggah 1 foto bukti berformat JPG
    When user mengosongkan field "Tanggal Selesai Muat"
    And user mengklik tombol "Simpan"
    Then sistem menampilkan helper error di bawah field "Tanggal Selesai Muat"
    And data tracking tidak tersimpan

  @negative @priority-high @REQ-057 @screen-isi-data-tracking @TC-N-035
  Scenario: Menyimpan data tracking tanpa foto diblokir
    Given user berada di halaman "Isi Data Tracking"
    And user mengisi field "Tanggal Selesai Muat" dengan "01/06/2026 08:30"
    When user tidak mengunggah foto apa pun
    And user mengklik tombol "Simpan"
    Then sistem menampilkan helper error pada field foto
    And data tracking tidak tersimpan

  @negative @priority-high @REQ-058 @screen-isi-data-tracking @TC-N-036
  Scenario: Mengunggah foto ketujuh memunculkan alert batas jumlah foto
    Given user berada di halaman "Isi Data Tracking"
    And user sudah mengunggah 6 foto bukti
    When user mengunggah file "bukti-7.jpg" berukuran 1 MB
    Then sistem menampilkan alert batas jumlah foto
    And jumlah foto terunggah tetap 6

  @negative @priority-high @REQ-058 @screen-isi-data-tracking @TC-N-037
  Scenario: Mengunggah foto lebih dari 4 MB memunculkan alert batas ukuran
    Given user berada di halaman "Isi Data Tracking"
    When user mengunggah file "bukti-besar.jpg" berukuran 5 MB
    Then sistem menampilkan alert batas ukuran foto
    And file tidak ditambahkan ke daftar foto terunggah

  @negative @priority-high @REQ-057 @screen-isi-data-tracking @TC-N-038
  Scenario: Mengunggah file di luar format JPG dan PNG ditolak
    Given user berada di halaman "Isi Data Tracking"
    When user mengunggah file "bukti.pdf" berukuran 1 MB
    Then sistem menolak file dan menampilkan alert format tidak didukung
    When user mengunggah file "bukti.gif" berukuran 1 MB
    Then sistem menolak file dan menampilkan alert format tidak didukung

  @negative @priority-medium @REQ-053 @screen-isi-data-tracking @TC-N-039
  Scenario: Informasi order pada halaman Isi Data Tracking tidak dapat diedit
    Given user berada di halaman "Isi Data Tracking"
    When user mencoba mengubah informasi "Nopol"
    Then nilai informasi "Nopol" tidak berubah
    And seluruh informasi order dalam keadaan read-only

  @negative @priority-medium @REQ-056 @screen-isi-data-tracking @TC-N-040
  Scenario: Mengetik tanggal dengan format tidak valid ditolak
    Given user berada di halaman "Isi Data Tracking"
    When user mengisi field "Tanggal Selesai Muat" dengan "32/13/2026 99:99"
    And user mengklik tombol "Simpan"
    Then sistem menampilkan pesan error format tanggal
    And data tracking tidak tersimpan

  @negative @priority-medium @REQ-063 @screen-isi-data-tracking @TC-N-041
  Scenario: No. Kontainer tidak dapat diubah pada tahap Selesai Bongkar
    Given penugasan FCL "ORD76392092" berada pada tahap "Selesai Bongkar"
    When user berada di halaman "Isi Data Tracking"
    Then field "No. Kontainer" tidak tersedia atau dalam keadaan disabled
    And field "No. Segel" tidak tersedia atau dalam keadaan disabled

  # ==========================================================================
  # NEGATIVE - PENUGASAN SOPIR BONGKAR (REQ-064 s.d. REQ-067)
  # ==========================================================================

  @negative @priority-high @REQ-067 @screen-isi-data-tracking @TC-N-042
  Scenario: Metode Door to CY tidak menampilkan opsi penugasan sopir bongkar
    Given penugasan FCL "ORD-DOORCY-001" memiliki metode pengiriman "Door to CY"
    And penugasan berada pada tahap "Selesai Bongkar"
    When user berada di halaman "Isi Data Tracking"
    Then sistem tidak menampilkan opsi "Penugasan Sopir Bongkar"

  @negative @priority-high @REQ-067 @screen-isi-data-tracking @TC-N-043
  Scenario: Metode CY to CY tidak menampilkan opsi penugasan sopir bongkar
    Given penugasan FCL "ORD-CYCY-001" memiliki metode pengiriman "CY to CY"
    And penugasan berada pada tahap "Selesai Bongkar"
    When user berada di halaman "Isi Data Tracking"
    Then sistem tidak menampilkan opsi "Penugasan Sopir Bongkar"

  @negative @priority-high @REQ-064 @screen-140 @TC-N-044
  Scenario: Menyimpan penugasan sopir bongkar tanpa Nopol diblokir
    Given user berada di halaman "Penugasan Sopir Bongkar"
    And user telah memilih sopir bongkar "Bahlyl Lyla"
    When user mengosongkan field "No. Polisi/Jenis Armada"
    And user mengklik tombol "Simpan"
    Then sistem menampilkan helper error pada field "Armada Bongkar"
    And data penugasan sopir bongkar tidak tersimpan

  @negative @priority-high @REQ-064 @screen-140 @TC-N-045
  Scenario: Menyimpan penugasan sopir bongkar tanpa Sopir diblokir
    Given user berada di halaman "Penugasan Sopir Bongkar"
    And user telah memilih armada bongkar "L54543 FDS - FUSO"
    When user mengosongkan field "Sopir/No. WhatsApp"
    And user mengklik tombol "Simpan"
    Then sistem menampilkan helper error pada field "Sopir Bongkar"
    And data penugasan sopir bongkar tidak tersimpan

  @negative @priority-high @REQ-066 @screen-140 @TC-N-046
  Scenario: Batal pada penugasan sopir bongkar tidak boleh mengarah ke daftar Penugasan Tracking
    Given user berada di halaman "Isi Data Tracking" pada tahap "Selesai Bongkar"
    And user mengklik tombol "Penugasan Sopir Bongkar"
    When user mengklik tombol "Batal"
    And user mengonfirmasi pembatalan
    Then user tidak berada di halaman "Penugasan Tracking"
    And URL halaman tidak mengarah ke daftar penugasan tracking
    And user berada di halaman "Isi Data Tracking"

  @negative @priority-low @REQ-064 @screen-140 @TC-N-047
  Scenario: Menyimpan penugasan sopir bongkar tanpa Tanggal Permintaan Bongkar
    Given user berada di halaman "Penugasan Sopir Bongkar"
    And user telah mengisi armada dan sopir bongkar
    When user mengosongkan field "Tanggal Permintaan Bongkar"
    And user mengklik tombol "Simpan"
    Then sistem menampilkan helper error di bawah field "Tanggal Permintaan Bongkar"
    And data penugasan sopir bongkar tidak tersimpan

  # ==========================================================================
  # NEGATIVE - DETAIL & RIWAYAT (REQ-068 s.d. REQ-074)
  # ==========================================================================

  @negative @priority-medium @REQ-068 @screen-133a @TC-N-048
  Scenario: Halaman Detail Penugasan bersifat read-only
    Given user berada di halaman "Detail Penugasan" untuk order "LTL0152708249"
    Then tidak terdapat field input yang dapat diisi pada section "Detail Data Order"
    And tidak terdapat field input yang dapat diisi pada section "Informasi Penugasan"

  @negative @priority-medium @REQ-069 @screen-133a @TC-N-049
  Scenario: Detail order FTL tidak menampilkan Metode Pengiriman dan Jenis Kontainer
    Given user berada di halaman "Detail Penugasan" untuk order FTL "LKL903902399"
    Then sistem tidak menampilkan field "Metode Pengiriman"
    And sistem tidak menampilkan field "Jenis Kontainer"

  @negative @priority-low @REQ-068 @screen-133a @TC-N-050
  Scenario: Membuka Detail Penugasan dengan ID Order tidak dikenal
    Given user login sebagai "Vendor"
    When user membuka halaman "Detail Penugasan" untuk ID Order "ORD-TIDAK-ADA"
    Then sistem menampilkan pesan data tidak ditemukan
    And sistem tidak menampilkan section "Informasi Penugasan"

  @negative @priority-low @REQ-072 @screen-pop-up-2 @TC-N-051
  Scenario: Pop-up Riwayat Penugasan tanpa data perubahan menampilkan state kosong
    Given penugasan "ORD-BARU-001" belum pernah mengalami perubahan armada atau sopir
    And user berada di halaman "Detail Penugasan" untuk order "ORD-BARU-001"
    When user mengklik pemicu riwayat penugasan "Lihat Detail"
    Then dialog "Riwayat Penugasan" menampilkan state data kosong

  # ==========================================================================
  # NEGATIVE - EDIT PENUGASAN (REQ-075 s.d. REQ-079)
  # ==========================================================================

  @negative @priority-high @REQ-076 @screen-149 @TC-N-052
  Scenario: Nopol FTL tidak dapat diubah setelah status Selesai Muat
    Given penugasan FTL "LKL903902399" sudah mencapai tahap "Selesai Muat"
    When user berada di halaman "Edit Penugasan"
    Then field "No. Polisi" dalam keadaan disabled
    And field "Sopir" dalam keadaan disabled

  @negative @priority-high @REQ-077 @screen-150 @TC-N-053
  Scenario: Nopol/armada FCL terkunci setelah status Selesai Muat
    Given penugasan FCL "ORD6093390506" sudah mencapai tahap "Selesai Muat"
    When user berada di halaman "Edit Penugasan"
    Then field "No. Polisi/Jenis Armada" dalam keadaan disabled
    And field "Sopir/No. WhatsApp" dalam keadaan disabled

  @negative @priority-high @REQ-078 @screen-150 @TC-N-054
  Scenario: No. Kontainer dan No. Segel terkunci setelah status melewati Menunggu Proses
    Given penugasan FCL "ORD6093390506" berstatus "Dalam Perjalanan"
    When user berada di halaman "Edit Penugasan"
    Then field "No. Kontainer" dalam keadaan disabled
    And field "No. Segel" dalam keadaan disabled

  @negative @priority-high @REQ-079 @screen-150 @TC-N-055
  Scenario: Jadwal kapal terkunci setelah status Selesai Muat
    Given penugasan FCL "ORD6093390506" sudah mencapai tahap "Selesai Muat"
    When user berada di halaman "Edit Penugasan"
    Then field "Pelayaran" dalam keadaan disabled
    And field "Nama Kapal" dalam keadaan disabled
    And field "Berangkat (ETD)" dalam keadaan disabled
    And field "Tiba (ETA)" dalam keadaan disabled
    And radio "Jenis Jadwal Kapal" dalam keadaan disabled

  @negative @priority-high @REQ-034 @REQ-075 @screen-149 @TC-N-056
  Scenario: Mengosongkan field required pada Edit Penugasan diblokir
    Given penugasan FCL "ORD6093390506" berstatus "Belum Berangkat"
    And user berada di halaman "Edit Penugasan"
    When user mengosongkan field "No. Kontainer"
    And user mengklik tombol "Simpan"
    Then sistem menampilkan helper error di bawah field "No. Kontainer"
    And border field "No. Kontainer" berwarna error
    And perubahan tidak tersimpan

  @negative @priority-medium @REQ-075 @screen-150 @TC-N-057
  Scenario: Informasi Order pada halaman Edit tidak dapat diubah
    Given user berada di halaman "Edit Penugasan" untuk order "ORD6093390506"
    When user mencoba mengubah nilai "Vendor"
    Then nilai "Vendor" tetap "SPS SF"
    And seluruh field Informasi Order dalam keadaan read-only

  @negative @priority-medium @REQ-076 @REQ-079 @screen-127 @TC-N-058
  Scenario: Penugasan berstatus Selesai tidak dapat diedit
    Given penugasan "ORD00986289" berstatus "Selesai"
    And user berada di halaman "Penugasan Tracking"
    When user mengklik menu aksi "Edit Penugasan" pada baris "ORD00986289"
    Then seluruh field penugasan dalam keadaan disabled atau menu Edit tidak tersedia

  @negative @priority-medium @REQ-024 @screen-134 @TC-N-059
  Scenario: Menyimpan penugasan untuk order yang baru saja ditugaskan user lain ditolak
    Given user A dan user B membuka halaman "Tambah Penugasan" dengan order "LKL903901897" tersedia
    And user B telah menyimpan penugasan untuk order "LKL903901897"
    When user A mengklik tombol "Simpan"
    And user A mengklik tombol "Ya" pada dialog konfirmasi
    Then sistem menampilkan pesan error bahwa order sudah memiliki penugasan
    And penugasan ganda tidak terbentuk

  @negative @priority-low @REQ-057 @screen-isi-data-tracking @TC-N-060
  Scenario: Mengunggah file gambar kosong atau korup ditolak
    Given user berada di halaman "Isi Data Tracking"
    When user mengunggah file "bukti-korup.jpg" berukuran 0 byte
    Then sistem menolak file dan menampilkan alert
    And jumlah foto terunggah tetap 0

  # ==========================================================================
  # EDGE - BOUNDARY, KOMBINASI LANGKA, KARAKTER SPESIAL
  # ==========================================================================

  @edge @priority-medium @REQ-001 @REQ-002 @screen-127 @TC-E-001
  Scenario: Shipper pengelola dua vendor hanya berakses penuh pada order vendor kelolaannya
    Given user login sebagai "Shipper" yang mengelola vendor "JNE" dan "SPS SF"
    And tabel memuat order dari vendor "JNE", "SPS SF", dan "Vendor Lain"
    When user membuka action menu pada baris order vendor "SPS SF"
    Then menu "Edit Penugasan" dalam keadaan enabled
    When user membuka action menu pada baris order vendor "Vendor Lain"
    Then menu "Edit Penugasan" tidak tersedia atau dalam keadaan disabled

  @edge @priority-medium @REQ-004 @screen-127 @TC-E-002
  Scenario: Total data tepat 20 hanya menghasilkan satu halaman
    Given tersedia tepat 20 data penugasan tracking
    When user berada di halaman "Penugasan Tracking"
    Then sistem menampilkan 20 baris pada tabel penugasan
    And kontrol pagination hanya menampilkan halaman 1
    And tombol next pagination dalam keadaan disabled

  @edge @priority-medium @REQ-004 @screen-127 @TC-E-003
  Scenario: Total data 21 menghasilkan halaman kedua berisi satu baris
    Given tersedia tepat 21 data penugasan tracking
    And user berada di halaman "Penugasan Tracking"
    When user mengklik tombol "2" pada kontrol pagination
    Then sistem menampilkan 1 baris pada tabel penugasan
    And sistem menampilkan "Menampilkan 21 - 21 data dari 21 data"

  @edge @priority-low @REQ-005 @screen-127 @TC-E-004
  Scenario: Dua penugasan dengan waktu pembuatan identik tetap terurut deterministik
    Given terdapat 2 penugasan dengan waktu dibuat yang sama persis
    When user berada di halaman "Penugasan Tracking"
    And user memuat ulang halaman
    Then urutan kedua baris tersebut tetap sama pada setiap pemuatan

  @edge @priority-low @REQ-006 @REQ-074 @screen-139 @TC-E-005
  Scenario: Baris tanpa data sopir menampilkan strip
    Given penugasan "ORD00986289" belum memiliki sopir
    When user berada di halaman "Penugasan Tracking"
    Then sel sopir pada baris "ORD00986289" menampilkan "-"

  @edge @priority-high @REQ-015 @REQ-016 @screen-127 @TC-E-006
  Scenario: Filter Tahap Pengiriman historis berbeda hasil dengan filter Status terkini
    Given order "ORD123" pernah update "Selesai Muat" dan kini berstatus "Dalam Perjalanan"
    And user berada di halaman "Penugasan Tracking"
    When user memilih "Selesai Muat" pada field "Tahap Pengiriman"
    And user mengklik tombol "Terapkan"
    Then tabel menampilkan baris "ORD123"
    When user mengklik tombol "Reset"
    And user memilih "Belum Berangkat" pada field "Status"
    And user mengklik tombol "Terapkan"
    Then tabel tidak menampilkan baris "ORD123"

  @edge @priority-high @REQ-015 @screen-127 @TC-E-007
  Scenario: Order multi pick-up tampil pada filter tahap jika salah satu pick-up sudah selesai muat
    Given order "ORD-MULTIPICKUP-1" memiliki 3 pick-up dan baru 1 pick-up yang Selesai Muat
    And user berada di halaman "Penugasan Tracking"
    When user memilih "Selesai Muat" pada field "Tahap Pengiriman"
    And user mengklik tombol "Terapkan"
    Then tabel menampilkan baris "ORD-MULTIPICKUP-1"

  @edge @priority-medium @REQ-009 @REQ-014 @screen-127 @TC-E-008
  Scenario: Filter mengabaikan spasi berlebih dan tidak membedakan huruf besar kecil
    Given user berada di halaman "Penugasan Tracking"
    When user mengisi field "ID Order" dengan "   ORD76392092   "
    And user mengklik tombol "Terapkan"
    Then seluruh baris tabel menampilkan ID Order "ORD76392092"
    When user mengklik tombol "Reset"
    And user mengisi field "Sopir" dengan "mUrTiOnO"
    And user mengklik tombol "Terapkan"
    Then seluruh baris tabel menampilkan sopir "Murtiono"

  @edge @priority-low @REQ-013 @screen-127 @TC-E-009
  Scenario: Filter nopol dengan pencarian sebagian karakter
    Given user berada di halaman "Penugasan Tracking"
    When user mengisi field "No. Polisi/No. Kontainer" dengan "CNT"
    And user mengklik tombol "Terapkan"
    Then seluruh baris tabel menampilkan nomor yang memuat "CNT"

  @edge @priority-low @REQ-018 @screen-127 @TC-E-010
  Scenario: Menekan Reset saat filter masih kosong tidak mengubah tabel
    Given user berada di halaman "Penugasan Tracking"
    And seluruh field filter dalam keadaan kosong
    When user mengklik tombol "Reset"
    Then tabel menampilkan data default dengan maksimal 20 baris
    And sistem tidak menampilkan error aplikasi

  @edge @priority-high @REQ-022 @screen-isi-data-tracking @TC-E-011
  Scenario: Status baru menjadi Selesai setelah seluruh kota drop menyelesaikan bongkar
    Given order "ORD-MULTIDROP-3" memiliki 3 kota drop
    And 2 kota drop sudah menyelesaikan tahap "Selesai Bongkar"
    When user berada di halaman "Penugasan Tracking"
    Then status penugasan cocok dengan pola "Dalam Perjalanan|Selesai Muat"
    When user melengkapi tahap "Selesai Bongkar" untuk kota drop ketiga
    And user mengklik tombol "Simpan"
    Then status penugasan cocok dengan pola "Selesai|Selesai Bongkar"

  @edge @priority-medium @REQ-016 @screen-127 @screen-133a @TC-E-012
  Scenario: Nilai status konsisten antara daftar dan halaman detail
    Given user berada di halaman "Penugasan Tracking"
    And badge status baris "ORD19283005" dicatat sebagai nilai referensi
    When user mengklik menu aksi "Detail Penugasan" pada baris "ORD19283005"
    Then badge status pada halaman "Detail Penugasan" merepresentasikan tahap yang sama dengan nilai referensi

  @edge @priority-medium @REQ-028 @screen-134 @TC-E-013
  Scenario: Order multipickup menampilkan seluruh kota asal dengan prefix wilayah
    Given order "LKL903902398" memiliki 3 kota asal
    And user berada di halaman "Tambah Penugasan"
    When user memilih order "LKL903902398"
    Then nilai "Kota Asal" adalah "Kota Surabaya, Kab. Sidoarjo, Kab. Mojokerto"
    And setiap nama kota diawali "Kota" atau "Kab."

  @edge @priority-low @REQ-025 @screen-134 @TC-E-014
  Scenario: Pencarian order tanpa hasil menampilkan state kosong
    Given user berada di halaman "Tambah Penugasan"
    When user mengisi field "Cari Order" dengan "ZZZZZZZZZ"
    Then daftar "Pilih Order" menampilkan state hasil pencarian kosong

  @edge @priority-medium @REQ-026 @REQ-029 @screen-134 @TC-E-015
  Scenario: Mengganti order terpilih mereset card input sesuai order baru
    Given user berada di halaman "Tambah Penugasan"
    And user memilih order "LKL903902398" dengan 2 kontainer
    And user mengisi field "No. Kontainer" pada kontainer 1 dengan "CTN111"
    When user memilih order "LKL903902399" dengan 1 armada
    Then sistem menampilkan 1 card input armada
    And nilai input pada card sebelumnya sudah tereset

  @edge @priority-medium @REQ-029 @screen-143 @TC-E-016
  Scenario: Order dengan satu armada hanya menampilkan satu card
    Given order "LKL903902399" memiliki Jumlah Armada 1
    And user berada di halaman "Tambah Penugasan"
    When user memilih order "LKL903902399"
    Then sistem menampilkan 1 card input armada
    And sistem menampilkan "Armada 1"

  @edge @priority-medium @REQ-031 @REQ-032 @screen-135 @TC-E-017
  Scenario: Metode pengisian dapat berbeda antar card pada satu penugasan
    Given user berada di halaman "Tambah Penugasan"
    And user memilih order FCL dengan 2 kontainer
    When user memilih "Isi Data Manual" pada "Armada Muat" kontainer 1
    And user memilih "Pilih Dari Master" pada "Sopir Muat" kontainer 2
    Then kontainer 1 menampilkan input teks "No. Polisi"
    And kontainer 2 menampilkan dropdown "Sopir/No. WhatsApp"

  @edge @priority-low @REQ-032 @REQ-037 @screen-144 @TC-E-018
  Scenario: Data manual dengan karakter spesial dan spasi berlebih dinormalisasi
    Given user berada di halaman "Tambah Penugasan"
    And user memilih order "LKL903902399"
    When user memilih "Isi Data Manual" pada "Armada"
    And user mengisi field "No. Polisi" dengan "  l 1892  pgs  "
    And user memilih "Isi Data Manual" pada "Sopir"
    And user mengisi field "Nama Sopir" dengan "M. O'Brien-Sanjaya"
    And user mengklik tombol "Simpan"
    And user mengklik tombol "Ya" pada dialog konfirmasi
    Then sistem menampilkan notifikasi data tersimpan
    And nilai nopol tersimpan tanpa spasi ganda di awal dan akhir

  @edge @priority-low @REQ-032 @screen-144 @TC-E-019
  Scenario: No. WhatsApp menerima format internasional
    Given user berada di halaman "Tambah Penugasan"
    And user memilih "Isi Data Manual" pada "Sopir"
    When user mengisi field "No. WhatsApp (opsional)" dengan "+62 821-3924-0985"
    And user mengklik tombol "Simpan"
    And user mengklik tombol "Ya" pada dialog konfirmasi
    Then sistem menampilkan notifikasi data tersimpan

  @edge @priority-high @REQ-049 @screen-135 @TC-E-020
  Scenario: ETD kapal connecting sama dengan ETA kapal utama tetap valid
    Given user berada di halaman "Tambah Penugasan"
    And user memilih order FCL "LKL903902398"
    And user mengisi field "Tiba (ETA)" dengan "25/08/2026"
    When user memilih "Connecting" pada "Jenis Jadwal Kapal"
    And user mengisi field "ETD Connecting" dengan "25/08/2026"
    And user mengklik tombol "Simpan"
    And user mengklik tombol "Ya" pada dialog konfirmasi
    Then sistem menampilkan notifikasi data tersimpan
    And sistem tidak menampilkan pesan error validasi pada field "ETD Connecting"

  @edge @priority-high @REQ-048 @REQ-049 @screen-135 @TC-E-021
  Scenario: Pelanggaran ETD pada baris connecting ketiga tetap memblokir penyimpanan
    Given user berada di halaman "Tambah Penugasan"
    And user mengisi field "Tiba (ETA)" dengan "25/08/2026"
    And user memilih "Connecting" pada "Jenis Jadwal Kapal"
    And user menambahkan 3 baris data kapal connecting
    When user mengisi ETD baris 1 dengan "22/08/2026"
    And user mengisi ETD baris 2 dengan "23/08/2026"
    And user mengisi ETD baris 3 dengan "30/08/2026"
    And user mengklik tombol "Simpan"
    Then sistem menampilkan pesan error validasi pada baris connecting ke-3
    And data penugasan tidak tersimpan

  @edge @priority-medium @REQ-047 @REQ-048 @screen-136 @TC-E-022
  Scenario: Mengubah Connecting menjadi Direct menghapus baris kapal connecting
    Given user berada di halaman "Tambah Penugasan"
    And user memilih "Connecting" pada "Jenis Jadwal Kapal"
    And user mengisi 2 baris data kapal connecting
    When user memilih "Direct" pada "Jenis Jadwal Kapal"
    Then sistem tidak menampilkan "Data Kapal Connecting"
    And sistem tidak menampilkan tombol "Tambah Kapal Connecting"
    And data connecting tidak ikut tersimpan saat Simpan ditekan

  @edge @priority-high @REQ-030 @REQ-029 @screen-134 @TC-E-023
  Scenario: Order LCL dengan tiga kontainer tetap hanya menampilkan satu card
    Given order "ORD-LCL-3KTN" berjenis "LCL" dengan Jumlah Kontainer 3
    And user berada di halaman "Tambah Penugasan"
    When user memilih order "ORD-LCL-3KTN"
    Then sistem menampilkan 1 card input kontainer

  @edge @priority-high @REQ-057 @screen-isi-data-tracking @TC-E-024
  Scenario: Mengunggah tepat enam foto berhasil disimpan
    Given user berada di halaman "Isi Data Tracking"
    And user mengisi field "Tanggal Selesai Muat" dengan "01/06/2026 08:30"
    When user mengunggah 6 foto berformat JPG dan PNG
    Then sistem menampilkan 6 thumbnail foto terunggah
    And sistem tidak menampilkan alert batas foto
    When user mengklik tombol "Simpan"
    Then sistem menampilkan notifikasi data tersimpan

  @edge @priority-high @REQ-057 @REQ-058 @screen-isi-data-tracking @TC-E-025
  Scenario: Foto berukuran tepat 4 MB diterima sistem
    Given user berada di halaman "Isi Data Tracking"
    When user mengunggah file "bukti-4mb.jpg" berukuran tepat 4 MB
    Then sistem menerima file tersebut
    And sistem tidak menampilkan alert batas ukuran foto

  @edge @priority-high @REQ-058 @screen-isi-data-tracking @TC-E-026
  Scenario: Foto sedikit di atas 4 MB ditolak sistem
    Given user berada di halaman "Isi Data Tracking"
    When user mengunggah file "bukti-4mb-plus.jpg" berukuran 4 MB lebih 1 KB
    Then sistem menampilkan alert batas ukuran foto
    And file tidak ditambahkan ke daftar foto terunggah

  @edge @priority-medium @REQ-056 @screen-isi-data-tracking @TC-E-027
  Scenario: Tanggal 29 Februari hanya valid pada tahun kabisat
    Given user berada di halaman "Isi Data Tracking"
    When user mengisi field "Tanggal Selesai Muat" dengan "29/02/2028 10:00"
    Then nilai field "Tanggal Selesai Muat" adalah "29/02/2028 10:00"
    When user mengisi field "Tanggal Selesai Muat" dengan "29/02/2027 10:00"
    Then sistem menampilkan pesan error format tanggal

  @edge @priority-low @REQ-057 @screen-isi-data-tracking @TC-E-028
  Scenario: Nama file unicode dan ekstensi huruf besar tetap diterima
    Given user berada di halaman "Isi Data Tracking"
    When user mengunggah file "bukti muat — gudang #1 (東京).JPG" berukuran 1 MB
    Then sistem menerima file tersebut
    And sistem menampilkan 1 thumbnail foto terunggah

  @edge @priority-medium @REQ-054 @REQ-062 @screen-isi-data-tracking @TC-E-029
  Scenario: Order single drop hanya menampilkan satu section tracking
    Given order "ORD-SINGLEDROP" hanya memiliki 1 kota drop
    When user berada di halaman "Isi Data Tracking" untuk order "ORD-SINGLEDROP"
    Then sistem menampilkan 1 section form tracking
    When user melengkapi tahap "Selesai Muat" dan "Selesai Bongkar"
    Then status penugasan cocok dengan pola "Selesai|Selesai Bongkar"

  @edge @priority-medium @REQ-060 @REQ-062 @screen-isi-data-tracking @TC-E-030
  Scenario: Progres tahap tracking tetap tersimpan setelah halaman dimuat ulang
    Given user berada di halaman "Isi Data Tracking"
    And user telah menyimpan tahap "Selesai Muat"
    When user memuat ulang halaman
    Then tahap "Selesai Muat" tetap dalam keadaan tersimpan dan ter-collapse
    And form aktif adalah tahap berikutnya

  @edge @priority-high @REQ-066 @screen-140 @screen-isi-data-tracking @TC-E-031
  Scenario: Batal setelah mengisi sebagian data sopir bongkar tidak menghapus tahap tracking sebelumnya
    Given user berada di halaman "Isi Data Tracking" pada tahap "Selesai Bongkar"
    And tahap "Selesai Muat" sudah tersimpan
    And user mengklik tombol "Penugasan Sopir Bongkar"
    When user mengisi field "No. Polisi" dengan "B 7930 HD"
    And user mengklik tombol "Batal"
    And user mengonfirmasi pembatalan
    Then user diarahkan ke halaman "Isi Data Tracking"
    And data tahap "Selesai Muat" tetap tersimpan
    And data sopir bongkar tidak tersimpan

  @edge @priority-high @REQ-066 @REQ-035 @screen-140 @TC-E-032
  Scenario: Menolak konfirmasi Batal membuat user tetap berada di form sopir bongkar
    Given user berada di halaman "Penugasan Sopir Bongkar" dari alur Isi Data Tracking
    And user telah mengisi field "No. Polisi" dengan "B 7930 HD"
    When user mengklik tombol "Batal"
    And user mengklik tombol "Tidak" pada alert konfirmasi
    Then user tetap berada di halaman "Penugasan Sopir Bongkar"
    And nilai field "No. Polisi" tetap "B 7930 HD"

  @edge @priority-medium @REQ-064 @screen-139 @screen-140 @TC-E-033
  Scenario: Penugasan sopir bongkar yang diakses dari action menu daftar kembali ke daftar saat Batal
    Given user berada di halaman "Penugasan Tracking" versi revisi
    When user mengklik menu aksi "Penugasan Sopir Bongkar" pada baris "ORD45672033"
    Then user diarahkan ke halaman "Penugasan Sopir Bongkar"
    When user mengklik tombol "Batal"
    And user mengonfirmasi pembatalan
    Then user diarahkan ke halaman "Penugasan Tracking"

  @edge @priority-medium @REQ-064 @screen-isi-data-tracking @TC-E-034
  Scenario: Order FTL dan LTL tidak menampilkan opsi penugasan sopir bongkar
    Given penugasan "ORD19283005" berjenis "FTL"
    And penugasan berada pada tahap "Selesai Bongkar"
    When user berada di halaman "Isi Data Tracking"
    Then sistem tidak menampilkan opsi "Penugasan Sopir Bongkar"

  @edge @priority-high @REQ-044 @REQ-064 @REQ-067 @screen-134 @screen-137 @screen-140 @TC-E-035
  Scenario Outline: Matriks metode pengiriman FCL/LCL pada form penugasan dan tahap bongkar
    Given user berada di halaman "Tambah Penugasan"
    When user memilih order FCL dengan metode pengiriman "<metode>"
    Then field armada dan sopir muat "<tampil_armada_muat>" pada form penugasan
    When penugasan tersebut mencapai tahap "Selesai Bongkar"
    And user berada di halaman "Isi Data Tracking"
    Then opsi penugasan sopir bongkar "<tampil_sopir_bongkar>"

    Examples:
      | metode       | tampil_armada_muat | tampil_sopir_bongkar |
      | Door to Door | ditampilkan        | ditampilkan          |
      | Door to CY   | ditampilkan        | tidak ditampilkan    |
      | CY to Door   | tidak ditampilkan  | ditampilkan          |
      | CY to CY     | tidak ditampilkan  | tidak ditampilkan    |

  @edge @priority-low @REQ-071 @screen-133a @screen-147 @TC-E-036
  Scenario: Tab History Tracking berbeda antara order LTL dan FCL
    Given user berada di halaman "Detail Penugasan" untuk order "LTL0152708249"
    Then sistem menampilkan tab "Per Lokasi" dalam keadaan terpilih
    And sistem menampilkan tab "Timeline"
    When user membuka halaman "Detail Penugasan" untuk order "FCL0152708249"
    Then sistem menampilkan tab "Per Tahapan" dalam keadaan terpilih
    And sistem menampilkan tab "Timeline"

  @edge @priority-medium @REQ-072 @screen-pop-up @screen-pop-up-1 @screen-pop-up-2 @TC-E-037
  Scenario: Pemicu Riwayat Penugasan dikenali pada semua varian dan modal dapat ditutup
    Given user berada di halaman "Detail Penugasan" untuk order "LTL0152708249"
    When user mengklik pemicu riwayat penugasan "Lihat Detail"
    Then sistem menampilkan dialog "Riwayat Penugasan"
    When user mengklik tombol "Tutup" pada dialog
    Then dialog "Riwayat Penugasan" tertutup
    And user tetap berada di halaman "Detail Penugasan"

  @edge @priority-medium @REQ-074 @screen-pop-up-3 @TC-E-038
  Scenario: Perubahan hanya pada data sopir menampilkan strip pada kolom armada
    Given penugasan "LTL0152708249" pernah diubah hanya pada data sopir
    And user berada di halaman "Detail Penugasan" untuk order "LTL0152708249"
    When user mengklik pemicu riwayat penugasan "Lihat Detail"
    Then baris riwayat terkait menampilkan sopir dengan nama dan nomor WA
    And baris riwayat terkait menampilkan armada "-"

  @edge @priority-high @REQ-063 @REQ-078 @screen-150 @screen-isi-data-tracking @TC-E-039
  Scenario: No. Kontainer terkunci di halaman Edit namun tetap dapat diubah pada form Selesai Muat
    Given penugasan FCL "ORD6093390506" berstatus "Dalam Perjalanan"
    When user berada di halaman "Edit Penugasan"
    Then field "No. Kontainer" dalam keadaan disabled
    When user membuka halaman "Isi Data Tracking" pada tahap "Selesai Muat"
    Then field "No. Kontainer" dalam keadaan editable

  @edge @priority-high @REQ-076 @REQ-077 @REQ-079 @screen-150 @TC-E-040
  Scenario: Field terkunci tepat setelah status berpindah ke Selesai Muat
    Given penugasan FCL "ORD6093390506" berstatus "Belum Berangkat"
    And field "No. Polisi/Jenis Armada" dalam keadaan enabled
    When user menyimpan data tracking tahap "Selesai Muat"
    And user membuka halaman "Edit Penugasan"
    Then field "No. Polisi/Jenis Armada" dalam keadaan disabled
    And field "Nama Kapal" dalam keadaan disabled

  @edge @priority-medium @REQ-072 @screen-149 @TC-E-041
  Scenario: Membatalkan Edit Penugasan tidak menambah entri riwayat
    Given penugasan "LKL903902399" memiliki 2 entri riwayat penugasan
    And user berada di halaman "Edit Penugasan"
    When user mengisi field "No. Polisi" dengan "L 9999 ZZ"
    And user mengklik tombol "Batal"
    And user mengonfirmasi pembatalan
    And user membuka pop-up riwayat penugasan
    Then dialog menampilkan tepat 2 entri riwayat
    And dialog tidak menampilkan armada "L 9999 ZZ"

  @edge @priority-low @REQ-059 @screen-isi-data-tracking @TC-E-042
  Scenario: Keterangan panjang 2000 karakter tetap tersimpan
    Given user berada di halaman "Isi Data Tracking"
    And user melengkapi tanggal dan foto tahap "Selesai Muat"
    When user mengisi field "Keterangan" dengan teks 2000 karakter
    And user mengklik tombol "Simpan"
    Then sistem menampilkan notifikasi data tersimpan
    And keterangan tersimpan utuh tanpa terpotong

  # ==========================================================================
  # STRESS - VOLUME BESAR, SESI PARALEL, PAYLOAD PANJANG, TIMEOUT
  # ==========================================================================

  @stress @priority-medium @REQ-004 @screen-127 @TC-S-001
  Scenario: Lima puluh sesi paralel membuka daftar Penugasan Tracking
    Given 50 user aktif membuka halaman "Penugasan Tracking" secara bersamaan
    Then seluruh sesi menerima respons tanpa error server
    And setiap sesi menampilkan maksimal 20 baris pada tabel penugasan

  @stress @priority-medium @REQ-004 @REQ-005 @screen-127 @TC-S-002
  Scenario: Daftar dengan sepuluh ribu data tetap dibatasi dua puluh baris per halaman
    Given tersedia 10000 data penugasan tracking
    When user berada di halaman "Penugasan Tracking"
    Then sistem menampilkan maksimal 20 baris pada tabel penugasan
    And halaman selesai dimuat dalam waktu wajar
    And baris pertama tabel adalah data terbaru

  @stress @priority-low @REQ-004 @screen-127 @TC-S-003
  Scenario: Klik cepat berulang pada tombol next pagination tidak merusak state tabel
    Given tersedia 10000 data penugasan tracking
    And user berada di halaman "Penugasan Tracking"
    When user mengklik tombol next pagination 50 kali secara cepat
    Then nomor halaman aktif konsisten dengan data yang ditampilkan
    And sistem tidak menampilkan error aplikasi

  @stress @priority-low @REQ-009 @screen-127 @TC-S-004
  Scenario: Filter ID Order dengan lima ribu karakter ditangani sistem
    Given user berada di halaman "Penugasan Tracking"
    When user mengisi field "ID Order" dengan teks 5000 karakter
    And user mengklik tombol "Terapkan"
    Then sistem tidak menampilkan error aplikasi
    And sistem menampilkan state data kosong atau pesan validasi panjang input

  @stress @priority-low @REQ-019 @screen-127 @TC-S-005
  Scenario: Menekan Terapkan berulang kali tidak menghasilkan permintaan bertumpuk yang gagal
    Given user berada di halaman "Penugasan Tracking"
    And user mengisi field "ID Order" dengan "ORD76392092"
    When user mengklik tombol "Terapkan" 30 kali secara cepat
    Then hasil akhir tabel konsisten dengan kriteria filter
    And sistem tidak menampilkan error aplikasi

  @stress @priority-medium @REQ-019 @REQ-004 @screen-127 @TC-S-006
  Scenario: Filter yang menghasilkan lima ribu baris tetap terpaginasi
    Given tersedia 10000 data penugasan tracking
    And user berada di halaman "Penugasan Tracking"
    When user memilih "FTL" pada field "Jenis Shipment"
    And user mengklik tombol "Terapkan"
    Then sistem menampilkan maksimal 20 baris pada tabel penugasan
    And info paginasi menampilkan total data hasil filter

  @stress @priority-medium @REQ-029 @screen-134 @TC-S-007
  Scenario: Order dengan dua puluh armada menampilkan dan menyimpan dua puluh card
    Given order "ORD-FTL-20ARM" memiliki Jumlah Armada 20
    And user berada di halaman "Tambah Penugasan"
    When user memilih order "ORD-FTL-20ARM"
    Then sistem menampilkan 20 card input armada
    When user mengisi seluruh 20 card dengan data valid
    And user mengklik tombol "Simpan"
    And user mengklik tombol "Ya" pada dialog konfirmasi
    Then sistem menampilkan notifikasi data tersimpan

  @stress @priority-low @REQ-031 @REQ-033 @screen-143 @TC-S-008
  Scenario: Dropdown master dengan lima ribu armada tetap responsif saat dicari
    Given data master memuat 5000 armada
    And user berada di halaman "Tambah Penugasan"
    When user mengklik field "No. Polisi"
    And user mengetik "L545" pada dropdown master
    Then dropdown menampilkan hasil pencarian yang terfilter
    And dropdown tidak mengalami freeze

  @stress @priority-low @REQ-024 @REQ-025 @screen-134 @TC-S-009
  Scenario: Daftar Pilih Order dengan dua ribu order tetap dapat dicari dan dipilih
    Given terdapat 2000 order yang belum ditugaskan
    And user berada di halaman "Tambah Penugasan"
    When user mengisi field "Cari Order" dengan "LKL9039023"
    Then daftar "Pilih Order" menampilkan hasil terfilter
    When user memilih order pertama pada hasil pencarian
    Then jumlah order terpilih adalah 1

  @stress @priority-high @REQ-036 @screen-134 @TC-S-010
  Scenario: Klik ganda pada tombol Simpan tidak membuat penugasan duplikat
    Given user berada di halaman "Tambah Penugasan"
    And seluruh field required sudah terisi valid
    When user mengklik tombol "Simpan" dua kali secara cepat
    And user mengklik tombol "Ya" pada dialog konfirmasi
    Then hanya 1 penugasan yang tersimpan untuk order tersebut
    And sistem menampilkan notifikasi data tersimpan

  @stress @priority-high @REQ-024 @screen-134 @TC-S-011
  Scenario: Dua sesi paralel menyimpan penugasan untuk order yang sama
    Given user A dan user B memilih order "LKL903901897" pada waktu bersamaan
    When keduanya mengklik tombol "Simpan" dan mengonfirmasi
    Then hanya 1 penugasan yang terbentuk untuk order "LKL903901897"
    And sesi kedua menerima pesan error bahwa order sudah ditugaskan

  @stress @priority-medium @REQ-029 @REQ-039 @REQ-040 @screen-134 @TC-S-012
  Scenario: Order FCL dengan sepuluh kontainer dapat diisi dan disimpan
    Given order "ORD-FCL-10KTN" memiliki Jumlah Kontainer 10
    And user berada di halaman "Tambah Penugasan"
    When user memilih order "ORD-FCL-10KTN"
    Then sistem menampilkan 10 card input kontainer
    When user mengisi No. Kontainer dan No. Segel pada seluruh card
    And user melengkapi jadwal kapal
    And user mengklik tombol "Simpan"
    And user mengklik tombol "Ya" pada dialog konfirmasi
    Then sistem menampilkan notifikasi data tersimpan

  @stress @priority-low @REQ-048 @REQ-049 @screen-135 @TC-S-013
  Scenario: Menambahkan lima puluh baris kapal connecting tetap tervalidasi
    Given user berada di halaman "Tambah Penugasan"
    And user mengisi field "Tiba (ETA)" dengan "25/08/2026"
    And user memilih "Connecting" pada "Jenis Jadwal Kapal"
    When user mengklik tombol "Tambah Kapal Connecting" 49 kali
    Then sistem menampilkan 50 baris "Data Kapal Connecting"
    When user mengisi ETD baris ke-50 dengan "30/08/2026"
    And user mengklik tombol "Simpan"
    Then sistem menampilkan pesan error validasi pada field "ETD Connecting"

  @stress @priority-low @REQ-040 @screen-134 @TC-S-014
  Scenario: Input No. Segel sepanjang seribu karakter ditangani sistem
    Given user berada di halaman "Tambah Penugasan"
    And user memilih order FCL "LKL903902398"
    When user mengisi field "No. Segel" dengan teks 1000 karakter
    And user mengklik tombol "Simpan"
    Then sistem menampilkan pesan validasi panjang input atau menyimpan nilai secara utuh
    And sistem tidak menampilkan error aplikasi

  @stress @priority-medium @REQ-057 @screen-isi-data-tracking @TC-S-015
  Scenario: Mengunggah enam foto berukuran empat MB sekaligus
    Given user berada di halaman "Isi Data Tracking"
    When user mengunggah 6 file JPG masing-masing berukuran 4 MB
    Then seluruh 6 foto berhasil terunggah
    And sistem tidak menampilkan alert batas foto
    When user mengklik tombol "Simpan"
    Then sistem menampilkan notifikasi data tersimpan

  @stress @priority-medium @REQ-054 @REQ-060 @REQ-062 @screen-isi-data-tracking @TC-S-016
  Scenario: Order dengan lima belas kota drop diisi berurutan sampai selesai
    Given order "ORD-MULTIDROP-15" memiliki 15 kota drop
    When user berada di halaman "Isi Data Tracking" untuk order "ORD-MULTIDROP-15"
    Then sistem menampilkan 15 section form tracking terpisah
    When user melengkapi seluruh tahap untuk 15 kota drop secara berurutan
    Then setiap section yang selesai ter-collapse otomatis
    And status penugasan cocok dengan pola "Selesai|Selesai Bongkar"

  @stress @priority-low @REQ-059 @screen-isi-data-tracking @TC-S-017
  Scenario: Keterangan sepuluh ribu karakter ditangani tanpa error
    Given user berada di halaman "Isi Data Tracking"
    And user melengkapi tanggal dan foto tahap "Selesai Muat"
    When user mengisi field "Keterangan" dengan teks 10000 karakter
    And user mengklik tombol "Simpan"
    Then sistem menampilkan notifikasi data tersimpan atau pesan validasi panjang input
    And sistem tidak menampilkan error aplikasi

  @stress @priority-high @REQ-060 @screen-isi-data-tracking @TC-S-018
  Scenario: Klik ganda pada Simpan tracking tidak menduplikasi tahap
    Given user berada di halaman "Isi Data Tracking"
    And user melengkapi form tahap "Selesai Muat"
    When user mengklik tombol "Simpan" dua kali secara cepat
    Then hanya 1 entri tahap "Selesai Muat" yang tercatat pada History Tracking
    And status penugasan cocok dengan pola "Dalam Perjalanan|Selesai Muat"

  @stress @priority-medium @REQ-050 @REQ-060 @screen-isi-data-tracking @TC-S-019
  Scenario: Dua admin mengisi data tracking order yang sama secara bersamaan
    Given admin A dan admin B membuka halaman "Isi Data Tracking" untuk order "ORD82090192"
    When keduanya menyimpan tahap "Selesai Muat" pada waktu hampir bersamaan
    Then hanya 1 entri tahap yang tercatat
    And sesi kedua menerima notifikasi konflik atau data sudah diperbarui

  @stress @priority-high @REQ-066 @screen-140 @screen-isi-data-tracking @TC-S-020
  Scenario: Navigasi bolak-balik Isi Data Tracking dan Penugasan Sopir Bongkar tiga puluh kali
    Given user berada di halaman "Isi Data Tracking" pada tahap "Selesai Bongkar"
    When user membuka form "Penugasan Sopir Bongkar" lalu mengklik "Batal" sebanyak 30 kali
    Then setiap pembatalan mengembalikan user ke halaman "Isi Data Tracking"
    And user tidak pernah diarahkan ke halaman "Penugasan Tracking"
    And data tahap tracking sebelumnya tetap utuh

  @stress @priority-low @REQ-072 @REQ-073 @screen-pop-up-3 @TC-S-021
  Scenario: Modal riwayat penugasan dengan dua ratus entri tetap dapat digulir
    Given penugasan "LTL0152708249" memiliki 200 entri riwayat perubahan
    And user berada di halaman "Detail Penugasan"
    When user mengklik pemicu riwayat penugasan "Lihat Detail"
    Then dialog "Riwayat Penugasan" menampilkan daftar entri yang dapat digulir
    And sistem tidak menampilkan error aplikasi

  @stress @priority-medium @REQ-076 @REQ-080 @screen-149 @TC-S-022
  Scenario: Tiga puluh kali perubahan penugasan tercatat seluruhnya pada riwayat
    Given penugasan "LKL903902399" berstatus "Belum Berangkat"
    When user melakukan 30 kali perubahan nopol melalui halaman "Edit Penugasan"
    And user membuka menu aksi "Riwayat Perubahan" pada baris "LKL903902399"
    Then dialog menampilkan 30 entri riwayat perubahan
    And setiap entri memuat tanggal perubahan

  @stress @priority-medium @REQ-060 @screen-isi-data-tracking @TC-S-023
  Scenario: Sesi kedaluwarsa saat mengisi form tracking panjang ditangani dengan aman
    Given user berada di halaman "Isi Data Tracking"
    And user mengisi form selama lebih dari batas waktu sesi
    When user mengklik tombol "Simpan"
    Then sistem menampilkan pesan sesi berakhir dan meminta login ulang
    And data tracking tidak tersimpan sebagian

  @stress @priority-low @REQ-071 @screen-133a @TC-S-024
  Scenario: History Tracking dengan dua puluh lima kota drop tetap dapat ditampilkan
    Given order "ORD-MULTIDROP-25" memiliki 25 kota drop yang seluruh tahapnya terisi
    When user berada di halaman "Detail Penugasan" untuk order "ORD-MULTIDROP-25"
    And user membuka section "History Tracking"
    Then seluruh grup lokasi ditampilkan tanpa error
    And halaman tetap responsif saat digulir
