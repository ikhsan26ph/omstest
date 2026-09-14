Feature: Dashboard OMS2324
  Dashboard Monitoring dan Distribusi & Muatan menampilkan status armada berjalan, jangkauan distribusi, profil barang, dan utilitas armada.

  @positive @priority-high @REQ-001 @screen-monitoring
  Scenario: OMS2324-DASHBOARD-POS-001 - Admin melihat score card Monitoring
    Given user berada di halaman "Monitoring"
    When sistem memuat data order berjalan yang sudah ditugaskan
    Then sistem menampilkan "Total Armada"
    And sistem menampilkan "Melewati SLA"
    And sistem menampilkan nilai "8" pada "Total Armada"
    And sistem menampilkan nilai "4" pada "Melewati SLA"

  @negative @priority-high @REQ-001 @screen-monitoring
  Scenario: OMS2324-DASHBOARD-NEG-001 - Order belum ditugaskan tidak dihitung pada score card Monitoring
    Given user berada di halaman "Monitoring"
    When sistem memuat data order dengan status belum ditugaskan
    Then sistem tidak menghitung order tersebut pada "Total Armada"
    And sistem tidak menghitung order tersebut pada "Melewati SLA"

  @positive @priority-high @REQ-002 @screen-monitoring
  Scenario: OMS2324-DASHBOARD-POS-002 - Admin melihat daftar armada berjalan per nopol
    Given user berada di halaman "Monitoring"
    When sistem menampilkan section "Daftar Armada Berjalan"
    Then sistem menampilkan card armada dengan nopol "L 1234 KP"
    And sistem menampilkan "ID Order: TRC46135584"
    And sistem menampilkan "Multipickup -> Multidrop"
    And sistem menampilkan "PT Andalan Trans Nusantara"
    And sistem menampilkan "Selesai bongkar"
    And sistem menampilkan "Detail"

  @negative @priority-high @REQ-002 @screen-monitoring
  Scenario: OMS2324-DASHBOARD-NEG-002 - Daftar armada berjalan tidak menampilkan order dibatalkan atau belum ditugaskan
    Given user berada di halaman "Monitoring"
    When sistem memuat data order dibatalkan dan order belum ditugaskan
    Then sistem tidak menampilkan card untuk order dibatalkan
    And sistem tidak menampilkan card untuk order belum ditugaskan

  @positive @priority-high @REQ-003 @screen-monitoring
  Scenario: OMS2324-DASHBOARD-POS-003 - Admin memfilter armada dengan status Melewati SLA
    Given user berada di halaman "Monitoring"
    When user mengklik tombol "Melewati SLA"
    Then sistem menampilkan card armada yang memiliki badge "Melewati SLA"
    And sistem menyembunyikan card yang tidak melewati SLA

  @negative @priority-high @REQ-003 @screen-monitoring
  Scenario: OMS2324-DASHBOARD-NEG-003 - Filter Belum Ada Pencatatan menolak order yang belum H-1 tanggal pemuatan
    Given user berada di halaman "Monitoring"
    When user mengklik tombol "Belum Ada Pencatatan"
    Then sistem tidak menampilkan order yang tanggal pemuatannya belum H-1
    And sistem hanya menampilkan order ditugaskan yang belum "Selesai Muat" dan sudah H-1

  @positive @priority-medium @REQ-004 @screen-monitoring
  Scenario: OMS2324-DASHBOARD-POS-004 - Admin mencari daftar armada berdasarkan nopol
    Given user berada di halaman "Monitoring"
    When user mengisi field "Cari nopol, sopir, atau ID order" dengan "L 8888 RO"
    And user mengklik tombol "Cari"
    Then sistem menampilkan card armada dengan nopol "L 8888 RO"
    And sistem menyembunyikan card armada yang tidak cocok dengan pencarian

  @negative @priority-medium @REQ-004 @screen-monitoring
  Scenario: OMS2324-DASHBOARD-NEG-004 - Pencarian yang tidak ditemukan menampilkan empty state
    Given user berada di halaman "Monitoring"
    When user mengisi field "Cari nopol, sopir, atau ID order" dengan "ZZZ9999"
    And user mengklik tombol "Cari"
    Then sistem menampilkan "Data armada tidak ditemukan"
    And sistem tidak menampilkan card armada berjalan

  @positive @priority-high @REQ-005 @screen-monitoring
  Scenario: OMS2324-DASHBOARD-POS-005 - Admin membuka detail penugasan dari card armada
    Given user berada di halaman "Monitoring"
    When user mengklik tombol "Detail" pada card "TRC46135584"
    Then user diarahkan ke halaman "Detail Penugasan Tracking"
    And sistem menampilkan "TRC46135584"
    And sistem menampilkan "L 1234 KP"

  @negative @priority-high @REQ-005 @screen-monitoring
  Scenario: OMS2324-DASHBOARD-NEG-005 - User tanpa akses tidak dapat membuka detail penugasan
    Given user berada di halaman "Monitoring" sebagai "User tanpa akses detail penugasan"
    When user mengklik tombol "Detail" pada card "TRC46135584"
    Then sistem menampilkan "Anda tidak memiliki akses"
    And user tetap berada di halaman "Monitoring"

  @positive @priority-high @REQ-006 @screen-distribusi-muatan
  Scenario: OMS2324-DASHBOARD-POS-006 - Shipper melihat Dashboard Distribusi & Muatan dengan default Bulanan
    Given user berada di halaman "Distribusi & Muatan"
    When sistem memuat dashboard distribusi
    Then sistem menampilkan "Periode Permintaan Muat"
    And sistem memilih tombol "Bulanan"
    And sistem menampilkan "Jangkauan Distribusi"
    And sistem menampilkan "Utilitas Armada"
    And sistem menampilkan tombol "Export"

  @negative @priority-high @REQ-006 @screen-distribusi-muatan
  Scenario: OMS2324-DASHBOARD-NEG-006 - Custom tanggal menolak tanggal akhir sebelum tanggal awal
    Given user berada di halaman "Distribusi & Muatan"
    When user mengklik tombol "Pilih Tanggal"
    And user mengisi field "Tanggal Mulai" dengan "2026-09-14"
    And user mengisi field "Tanggal Akhir" dengan "2026-09-01"
    Then sistem menampilkan "Tanggal akhir tidak boleh sebelum tanggal mulai"
    And sistem tidak memperbarui data dashboard

  @positive @priority-high @REQ-007 @screen-distribusi-muatan
  Scenario: OMS2324-DASHBOARD-POS-007 - Shipper melihat Jangkauan Distribusi dan peta choropleth
    Given user berada di halaman "Distribusi & Muatan"
    When sistem memuat section "Jangkauan Distribusi"
    Then sistem menampilkan "Kota Terjangkau"
    And sistem menampilkan "Jumlah Pengirim Aktif"
    And sistem menampilkan "Jumlah Penerima Aktif"
    And sistem menampilkan peta "Jangkauan Distribusi"
    And sistem menampilkan legend "Jumlah Order"
    And sistem menampilkan filter "Kota Tujuan (Penerima)"

  @negative @priority-medium @REQ-007 @screen-distribusi-muatan
  Scenario: OMS2324-DASHBOARD-NEG-007 - Peta tidak menghitung order batal pada jangkauan distribusi
    Given user berada di halaman "Distribusi & Muatan"
    When sistem memuat data berisi order batal pada provinsi "Jawa Barat"
    Then sistem tidak menambahkan order batal ke label provinsi "Jawa Barat"
    And sistem tidak menaikkan gradasi warna peta karena order batal tersebut

  @positive @priority-high @REQ-008 @screen-distribusi-muatan
  Scenario: OMS2324-DASHBOARD-POS-008 - Shipper melihat Utilitas Armada lengkap
    Given user berada di halaman "Distribusi & Muatan"
    When sistem memuat section "Utilitas Armada"
    Then sistem menampilkan "Rata-rata Barang per Pengiriman"
    And sistem menampilkan "Pengiriman < 50% Kapasitas"
    And sistem menampilkan "Kelebihan Muatan"
    And sistem menampilkan chart "Profil Barang Terkirim"
    And sistem menampilkan "Tingkat Keterisian Armada"

  @negative @priority-high @REQ-008 @screen-distribusi-muatan
  Scenario: OMS2324-DASHBOARD-NEG-008 - Kelebihan kapasitas ditandai sebagai kesalahan data
    Given user berada di halaman "Distribusi & Muatan"
    When sistem menghitung keterisian ruang lebih dari "100%"
    Then sistem menampilkan bar pembatas berwarna "merah"
    And sistem menampilkan keterangan "Melebihi kapasitas"
    And sistem tidak menandai kondisi tersebut sebagai overload operasional armada

  @edge @priority-medium @REQ-003 @screen-monitoring
  Scenario: OMS2324-DASHBOARD-EDG-001 - Filter Semua Tahapan tetap menampilkan seluruh status aktif ketika jumlah tiap chip berbeda
    Given user berada di halaman "Monitoring"
    When user mengklik tombol "Semua Tahapan"
    Then sistem menampilkan card status "Selesai Muat"
    And sistem menampilkan card status "Selesai Bongkar"
    And sistem menampilkan card status "Belum Ada Pencatatan"
    And sistem menampilkan card dengan badge "Melewati SLA"

  @edge @priority-medium @REQ-006 @screen-distribusi-muatan
  Scenario: OMS2324-DASHBOARD-EDG-002 - Mingguan memakai ISO week Senin sampai Minggu
    Given user berada di halaman "Distribusi & Muatan"
    When user mengklik tombol "Mingguan"
    Then sistem memfilter data dari hari "Senin" sampai "Minggu" pada ISO week berjalan
    And sistem menghitung dashboard berdasarkan "Tanggal Permintaan Muat"

  @edge @priority-medium @REQ-007 @screen-distribusi-muatan
  Scenario: OMS2324-DASHBOARD-EDG-003 - Zoom peta menampilkan detail kota dan opsi Kota Asal
    Given user berada di halaman "Distribusi & Muatan"
    When user mengklik tombol "Perbesar" pada peta
    And user memilih opsi "Kota Asal (Pengirim)"
    Then sistem menampilkan label kota atau kabupaten pada peta
    And sistem memperbarui gradasi warna berdasarkan lokasi pengirim

  @edge @priority-medium @REQ-008 @screen-distribusi-muatan
  Scenario: OMS2324-DASHBOARD-EDG-004 - Selisih keterisian ruang dan berat kurang dari 5 poin membuat kedua bar non-pembatas
    Given user berada di halaman "Distribusi & Muatan"
    When sistem menghitung keterisian ruang "82%" dan keterisian berat "79%"
    Then sistem memperlakukan kedua bar sebagai non-pembatas
    And sistem mengosongkan keterangan pembatas pada kedua bar

  @stress @priority-medium @REQ-004 @screen-monitoring
  Scenario: OMS2324-DASHBOARD-STR-001 - Refresh berulang tidak menduplikasi card armada
    Given user berada di halaman "Monitoring"
    When user mengklik tombol "Muat ulang" sebanyak "10" kali
    Then sistem tetap menampilkan jumlah card sesuai data terakhir
    And sistem memperbarui "Pembaruan terakhir"
    And sistem tidak menampilkan card duplikat untuk ID order yang sama

  @stress @priority-medium @REQ-006 @screen-distribusi-muatan
  Scenario: OMS2324-DASHBOARD-STR-002 - Export PDF tetap berhasil untuk dashboard dengan data besar
    Given user berada di halaman "Distribusi & Muatan"
    When sistem memuat dashboard dengan "10000" order valid
    And user mengklik tombol "Export"
    Then sistem menghasilkan file PDF dashboard
    And sistem tetap menampilkan data dashboard setelah export selesai

  @stress @priority-medium @REQ-007 @screen-distribusi-muatan
  Scenario: OMS2324-DASHBOARD-STR-003 - Peta tetap responsif saat zoom dan pan pada banyak label kota
    Given user berada di halaman "Distribusi & Muatan"
    When user mengklik tombol "Perbesar" sebanyak "5" kali
    And user menggeser peta ke area "Jawa Timur"
    Then sistem menampilkan label kota tanpa saling tumpang tindih kritis
    And sistem tetap dapat membuka dropdown "Kota Asal (Pengirim)"

  @stress @priority-low @REQ-008 @screen-distribusi-muatan
  Scenario: OMS2324-DASHBOARD-STR-004 - Profil Barang Terkirim menggabungkan banyak jenis barang menjadi Lainnya
    Given user berada di halaman "Distribusi & Muatan"
    When sistem memuat "50" jenis barang terkirim pada periode terpilih
    Then sistem menampilkan maksimal "10" batang pada chart "Profil Barang Terkirim"
    And sistem menggabungkan sisa jenis barang menjadi "Lainnya"
