# =====================================================================
# Modul   : oms022-public-tracking-improve
# Sumber  : output/oms022-public-tracking-improve/oms022-public-tracking-improve.analysis.md
# Tahap   : 2/4 — scenario-generator
# ---------------------------------------------------------------------
# ATURAN ASSERTION WAJIB (turunan Assumptions Log — jangan dilanggar):
#  - State simpul stepper di-assert via atribut data-state="reached|pending"  (ASM-023)
#  - Kardinalitas entri riwayat di-assert via data-history-type="muat|sintetis|bongkar"
#    BUKAN via matcher /bongkar/i (teks sintetis juga mengandung kata "bongkar") (ASM-004)
#  - Urutan riwayat di-assert dengan posisi RELATIF antar entri, bukan indeks absolut (ASM-007)
#  - JANGAN meng-assert "tepat 3 simpul" pada stepper — hanya keberadaan 3 label (ASM-009, V-05)
#  - Seluruh matcher teks: partial + case-insensitive (ASM-010)
#  - Entri sintetis: matcher gabungan
#    /(berangkat ke lokasi bongkar|dalam perjalanan menuju lokasi bongkar)/i (ASM-003)
#  - Event disiapkan lewat seed data/API armada, bukan lewat UI driver (ASM-011)
#  - Perubahan progres diamati setelah reload / pencarian ulang (ASM-014)
# =====================================================================

Feature: OMS-022 — Public Tracking OMS: stepper 3 tahap & Riwayat Pengiriman

  Sebagai pengirim/penerima publik (tanpa login)
  Saya ingin melacak pengiriman menggunakan No. Resi
  Agar dapat memantau progres yang diturunkan secara komputasi dari dua event OMS
  (Selesai Muat & Selesai Bongkar) pada stepper Pick Up -> On Delivery -> Delivered

  Background:
    Given user berada di halaman "Public Tracking"
    And user tidak dalam sesi login

  # ===================================================================
  # KATEGORI: POSITIVE
  # ===================================================================

  @positive @priority-high @REQ-003 @AC-003.1 @V-13 @screen-public-tracking @OMS022-POS-001
  Scenario: Halaman Public Tracking terbuka pada sesi anonim tanpa redirect ke login
    Then sistem menampilkan "public-tracking-page"
    And sistem menampilkan field "No. Resi"
    And sistem menampilkan tombol "Lacak"
    And sistem tidak menampilkan "field Email/Kata Sandi"
    And user tidak diarahkan ke halaman "Login"

  @positive @priority-high @REQ-001 @AC-001.1 @AC-001.2 @screen-public-tracking @OMS022-POS-002
  Scenario: Halaman menampilkan komponen inti sesuai baseline TMS Shipper
    Given data pengiriman resi "LKL2567828992" bertipe "Normal" dengan 1 alamat pick up dan 1 alamat drop off
    And armada telah melaporkan event "Selesai Muat" ke-1
    When user mengisi field "No. Resi" dengan "LKL2567828992"
    And user mengklik tombol "Lacak"
    Then sistem menampilkan "tracking-result"
    And sistem menampilkan "tracking-summary"
    And sistem menampilkan "tracking-stepper"
    And sistem menampilkan "Riwayat Pengiriman"

  @positive @priority-high @REQ-003 @AC-003.2 @AC-003.3 @screen-public-tracking @OMS022-POS-003
  Scenario: No. Resi valid menampilkan data pengiriman tanpa prompt autentikasi
    Given data pengiriman resi "LKL2567828992" bertipe "Normal" dengan 1 alamat pick up dan 1 alamat drop off
    When user mengisi field "No. Resi" dengan "LKL2567828992"
    And user mengklik tombol "Lacak"
    Then sistem menampilkan "tracking-result"
    And sistem menampilkan teks "LKL2567828992"
    And sistem tidak menampilkan "dialog autentikasi"
    And user tidak diarahkan ke halaman "Login"

  @positive @priority-high @REQ-004 @AC-004.1 @AC-004.2 @screen-public-tracking @OMS022-POS-004
  Scenario: Hasil tracking bersifat read-only tanpa aksi mutasi data
    Given data pengiriman resi "LKL2567828992" bertipe "Normal" dengan 1 alamat pick up dan 1 alamat drop off
    And armada telah melaporkan seluruh event "Selesai Muat"
    When user mengisi field "No. Resi" dengan "LKL2567828992"
    And user mengklik tombol "Lacak"
    Then sistem menampilkan "tracking-result"
    And sistem tidak menampilkan tombol "Edit"
    And sistem tidak menampilkan tombol "Batalkan"
    And sistem tidak menampilkan tombol "Simpan"
    And sistem tidak menampilkan tombol "Ubah Status"
    And area hasil tidak memuat input aktif

  @positive @priority-high @REQ-008 @AC-008.1 @AC-008.2 @V-05 @screen-public-tracking @OMS022-POS-005
  Scenario: Stepper menampilkan tiga label tahap dengan urutan Pick Up, On Delivery, Delivered
    Given data pengiriman resi "LKL2567828992" bertipe "Normal" dengan 1 alamat pick up dan 1 alamat drop off
    When user mengisi field "No. Resi" dengan "LKL2567828992"
    And user mengklik tombol "Lacak"
    Then sistem menampilkan "tracking-stepper"
    And simpul stepper "Pick Up" tersedia pada stepper
    And simpul stepper "On Delivery" tersedia pada stepper
    And simpul stepper "Delivered" tersedia pada stepper
    And urutan visual simpul stepper adalah "Pick Up, On Delivery, Delivered"

  @positive @priority-high @REQ-012 @REQ-017 @AC-012.1 @AC-012.3 @AC-012.4 @AC-017.1 @screen-public-tracking @OMS022-POS-006
  Scenario: Normal — satu Selesai Muat memicu Pick Up dan On Delivery sekaligus (collapse)
    Given data pengiriman resi "LKL2567828992" bertipe "Normal" dengan 1 alamat pick up dan 1 alamat drop off
    And armada telah melaporkan event "Selesai Muat" ke-1
    When user mengisi field "No. Resi" dengan "LKL2567828992"
    And user mengklik tombol "Lacak"
    Then simpul stepper "Pick Up" berstate "reached"
    And simpul stepper "On Delivery" berstate "reached"
    And simpul stepper "Delivered" berstate "pending"
    And jumlah entri riwayat bertipe "muat" adalah 1

  @positive @priority-high @REQ-011 @REQ-017 @AC-011.1 @AC-011.2 @AC-017.3 @screen-public-tracking @OMS022-POS-007
  Scenario: Normal — Selesai Bongkar terakhir memicu Delivered dan stepper penuh
    Given data pengiriman resi "LKL2567828992" bertipe "Normal" dengan 1 alamat pick up dan 1 alamat drop off
    And armada telah melaporkan seluruh event "Selesai Muat"
    And armada telah melaporkan event "Selesai Bongkar" ke-1
    When user mengisi field "No. Resi" dengan "LKL2567828992"
    And user mengklik tombol "Lacak"
    Then simpul stepper "Pick Up" berstate "reached"
    And simpul stepper "On Delivery" berstate "reached"
    And simpul stepper "Delivered" berstate "reached"
    And jumlah entri riwayat bertipe "bongkar" adalah 1

  @positive @priority-high @REQ-009 @REQ-018 @AC-009.1 @AC-018.1 @screen-public-tracking @OMS022-POS-008
  Scenario: Multi Pick Up 2 — Selesai Muat ke-1 hanya memicu Pick Up
    Given data pengiriman resi "LKL7920830903" bertipe "Multi Pick Up 2" dengan 2 alamat pick up dan 1 alamat drop off
    And armada telah melaporkan event "Selesai Muat" ke-1
    When user mengisi field "No. Resi" dengan "LKL7920830903"
    And user mengklik tombol "Lacak"
    Then simpul stepper "Pick Up" berstate "reached"
    And simpul stepper "On Delivery" berstate "pending"
    And simpul stepper "Delivered" berstate "pending"
    And jumlah entri riwayat bertipe "muat" adalah 1

  @positive @priority-high @REQ-010 @REQ-018 @AC-010.1 @AC-010.2 @AC-018.2 @AC-018.4 @screen-public-tracking @OMS022-POS-009
  Scenario: Multi Pick Up 2 — Selesai Muat ke-2 (terakhir) memicu On Delivery tanpa mereset Pick Up
    Given data pengiriman resi "LKL7920830903" bertipe "Multi Pick Up 2" dengan 2 alamat pick up dan 1 alamat drop off
    And armada telah melaporkan seluruh event "Selesai Muat"
    When user mengisi field "No. Resi" dengan "LKL7920830903"
    And user mengklik tombol "Lacak"
    Then simpul stepper "Pick Up" berstate "reached"
    And simpul stepper "On Delivery" berstate "reached"
    And simpul stepper "Delivered" berstate "pending"
    And jumlah entri riwayat bertipe "muat" adalah 2
    And entri riwayat bertipe "sintetis" muncul tepat 1 kali

  @positive @priority-high @REQ-011 @REQ-018 @AC-018.3 @screen-public-tracking @OMS022-POS-010
  Scenario: Multi Pick Up 2 — Selesai Bongkar terakhir memicu Delivered
    Given data pengiriman resi "LKL7920830903" bertipe "Multi Pick Up 2" dengan 2 alamat pick up dan 1 alamat drop off
    And armada telah melaporkan seluruh event "Selesai Muat"
    And armada telah melaporkan event "Selesai Bongkar" ke-1
    When user mengisi field "No. Resi" dengan "LKL7920830903"
    And user mengklik tombol "Lacak"
    Then simpul stepper "Delivered" berstate "reached"
    And jumlah entri riwayat bertipe "bongkar" adalah 1

  @positive @priority-high @REQ-013 @AC-013.2 @screen-public-tracking @OMS022-POS-011
  Scenario: Multi Pick Up 3 — On Delivery baru tercapai setelah Selesai Muat ke-3
    Given data pengiriman resi "LKL8900765636" bertipe "Multi Pick Up 3" dengan 3 alamat pick up dan 1 alamat drop off
    And armada telah melaporkan seluruh event "Selesai Muat"
    When user mengisi field "No. Resi" dengan "LKL8900765636"
    And user mengklik tombol "Lacak"
    Then simpul stepper "Pick Up" berstate "reached"
    And simpul stepper "On Delivery" berstate "reached"
    And simpul stepper "Delivered" berstate "pending"
    And jumlah entri riwayat bertipe "muat" adalah 3
    And entri riwayat bertipe "sintetis" muncul tepat 1 kali

  @positive @priority-high @REQ-012 @REQ-019 @AC-012.2 @AC-019.1 @screen-public-tracking @OMS022-POS-012
  Scenario: Multi Drop 2 — satu Selesai Muat memicu Pick Up dan On Delivery bersamaan
    Given data pengiriman resi "LKL4410238877" bertipe "Multi Drop 2" dengan 1 alamat pick up dan 2 alamat drop off
    And armada telah melaporkan seluruh event "Selesai Muat"
    When user mengisi field "No. Resi" dengan "LKL4410238877"
    And user mengklik tombol "Lacak"
    Then simpul stepper "Pick Up" berstate "reached"
    And simpul stepper "On Delivery" berstate "reached"
    And simpul stepper "Delivered" berstate "pending"

  @positive @priority-high @REQ-011 @REQ-019 @AC-019.3 @AC-019.4 @AC-025.1 @screen-public-tracking @OMS022-POS-013
  Scenario: Multi Drop 2 — Selesai Bongkar ke-2 memicu Delivered dengan 2 entri bongkar di riwayat
    Given data pengiriman resi "LKL4410238877" bertipe "Multi Drop 2" dengan 1 alamat pick up dan 2 alamat drop off
    And armada telah melaporkan seluruh event "Selesai Muat"
    And armada telah melaporkan seluruh event "Selesai Bongkar"
    When user mengisi field "No. Resi" dengan "LKL4410238877"
    And user mengklik tombol "Lacak"
    Then simpul stepper "Delivered" berstate "reached"
    And jumlah entri riwayat bertipe "bongkar" adalah 2
    And entri riwayat bertipe "sintetis" muncul tepat 1 kali

  @positive @priority-medium @REQ-020 @AC-020.1 @screen-public-tracking @OMS022-POS-014
  Scenario: Multipoint 2x2 — Pick Up tercapai setelah Selesai Muat ke-1
    Given data pengiriman resi "LKL5521349900" bertipe "Multipoint 2x2" dengan 2 alamat pick up dan 2 alamat drop off
    And armada telah melaporkan event "Selesai Muat" ke-1
    When user mengisi field "No. Resi" dengan "LKL5521349900"
    And user mengklik tombol "Lacak"
    Then simpul stepper "Pick Up" berstate "reached"
    And simpul stepper "On Delivery" berstate "pending"
    And simpul stepper "Delivered" berstate "pending"

  @positive @priority-medium @REQ-020 @AC-020.2 @AC-020.4 @screen-public-tracking @OMS022-POS-015
  Scenario: Multipoint 2x2 — On Delivery tercapai setelah Selesai Muat ke-2 dan entri sintetis muncul sekali
    Given data pengiriman resi "LKL5521349900" bertipe "Multipoint 2x2" dengan 2 alamat pick up dan 2 alamat drop off
    And armada telah melaporkan seluruh event "Selesai Muat"
    When user mengisi field "No. Resi" dengan "LKL5521349900"
    And user mengklik tombol "Lacak"
    Then simpul stepper "On Delivery" berstate "reached"
    And simpul stepper "Delivered" berstate "pending"
    And entri riwayat bertipe "sintetis" muncul tepat 1 kali

  @positive @priority-medium @REQ-020 @AC-020.3 @screen-public-tracking @OMS022-POS-016
  Scenario: Multipoint 2x2 — Delivered tercapai setelah Selesai Bongkar ke-2
    Given data pengiriman resi "LKL5521349900" bertipe "Multipoint 2x2" dengan 2 alamat pick up dan 2 alamat drop off
    And armada telah melaporkan seluruh event "Selesai Muat"
    And armada telah melaporkan seluruh event "Selesai Bongkar"
    When user mengisi field "No. Resi" dengan "LKL5521349900"
    And user mengklik tombol "Lacak"
    Then simpul stepper "Pick Up" berstate "reached"
    And simpul stepper "On Delivery" berstate "reached"
    And simpul stepper "Delivered" berstate "reached"
    And jumlah entri riwayat bertipe "muat" adalah 2
    And jumlah entri riwayat bertipe "bongkar" adalah 2

  @positive @priority-high @REQ-021 @AC-021.1 @AC-021.2 @AC-007.1 @screen-public-tracking @OMS022-POS-017
  Scenario: Riwayat Pengiriman dirender kronologis dengan seluruh entri muat mendahului entri bongkar
    Given data pengiriman resi "LKL8900765636" bertipe "Multi Pick Up 3" dengan 3 alamat pick up dan 1 alamat drop off
    And armada telah melaporkan seluruh event "Selesai Muat"
    And armada telah melaporkan seluruh event "Selesai Bongkar"
    When user mengisi field "No. Resi" dengan "LKL8900765636"
    And user mengklik tombol "Lacak"
    Then sistem menampilkan "Riwayat Pengiriman"
    And sistem menampilkan "history-list"
    And seluruh entri bertipe "muat" berada sebelum entri pertama bertipe "bongkar"

  @positive @priority-high @REQ-022 @V-07 @AC-022.1 @AC-022.2 @AC-022.3 @AC-022.4 @screen-public-tracking @OMS022-POS-018
  Scenario Outline: Jumlah entri "barang telah dimuat" sama dengan jumlah alamat pick up — <tipe>
    Given data pengiriman resi "<resi>" bertipe "<tipe>" dengan <pickup> alamat pick up dan <drop> alamat drop off
    And armada telah melaporkan seluruh event "Selesai Muat"
    When user mengisi field "No. Resi" dengan "<resi>"
    And user mengklik tombol "Lacak"
    Then jumlah entri riwayat bertipe "muat" adalah <pickup>
    And setiap entri riwayat bertipe "muat" memuat keterangan "barang telah dimuat"

    Examples:
      | resi          | tipe            | pickup | drop |
      | LKL2567828992 | Normal          | 1      | 1    |
      | LKL7920830903 | Multi Pick Up 2 | 2      | 1    |
      | LKL8900765636 | Multi Pick Up 3 | 3      | 1    |
      | LKL4410238877 | Multi Drop 2    | 1      | 2    |
      | LKL5521349900 | Multipoint 2x2  | 2      | 2    |

  @positive @priority-high @REQ-023 @REQ-024 @V-08 @AC-023.1 @AC-023.3 @AC-024.1 @screen-public-tracking @OMS022-POS-019
  Scenario Outline: Entri sintetis "armada dalam perjalanan menuju lokasi bongkar" muncul tepat sekali — <tipe>
    Given data pengiriman resi "<resi>" bertipe "<tipe>" dengan <pickup> alamat pick up dan <drop> alamat drop off
    And armada telah melaporkan seluruh event "Selesai Muat"
    When user mengisi field "No. Resi" dengan "<resi>"
    And user mengklik tombol "Lacak"
    Then entri riwayat bertipe "sintetis" muncul tepat 1 kali
    And entri riwayat bertipe "sintetis" memuat keterangan "dalam perjalanan menuju lokasi bongkar"

    Examples:
      | resi          | tipe            | pickup | drop |
      | LKL2567828992 | Normal          | 1      | 1    |
      | LKL7920830903 | Multi Pick Up 2 | 2      | 1    |
      | LKL8900765636 | Multi Pick Up 3 | 3      | 1    |
      | LKL4410238877 | Multi Drop 2    | 1      | 2    |
      | LKL5521349900 | Multipoint 2x2  | 2      | 2    |

  @positive @priority-high @REQ-024 @AC-024.2 @AC-024.3 @AC-007.2 @screen-public-tracking @OMS022-POS-020
  Scenario: Entri sintetis berada setelah entri muat terakhir dan sebelum entri bongkar pertama
    Given data pengiriman resi "LKL8900765636" bertipe "Multi Pick Up 3" dengan 3 alamat pick up dan 1 alamat drop off
    And armada telah melaporkan seluruh event "Selesai Muat"
    And armada telah melaporkan seluruh event "Selesai Bongkar"
    When user mengisi field "No. Resi" dengan "LKL8900765636"
    And user mengklik tombol "Lacak"
    Then entri riwayat bertipe "sintetis" berada setelah entri terakhir bertipe "muat"
    And entri riwayat bertipe "sintetis" berada sebelum entri pertama bertipe "bongkar"

  @positive @priority-high @REQ-025 @V-09 @AC-025.1 @AC-025.2 @screen-public-tracking @OMS022-POS-021
  Scenario Outline: Jumlah entri bongkar sama dengan jumlah alamat drop off — <tipe>
    Given data pengiriman resi "<resi>" bertipe "<tipe>" dengan <pickup> alamat pick up dan <drop> alamat drop off
    And armada telah melaporkan seluruh event "Selesai Muat"
    And armada telah melaporkan seluruh event "Selesai Bongkar"
    When user mengisi field "No. Resi" dengan "<resi>"
    And user mengklik tombol "Lacak"
    Then jumlah entri riwayat bertipe "bongkar" adalah <drop>
    And entri riwayat bertipe "sintetis" muncul tepat 1 kali

    Examples:
      | resi          | tipe            | pickup | drop |
      | LKL2567828992 | Normal          | 1      | 1    |
      | LKL7920830903 | Multi Pick Up 2 | 2      | 1    |
      | LKL4410238877 | Multi Drop 2    | 1      | 2    |
      | LKL5521349900 | Multipoint 2x2  | 2      | 2    |

  @positive @priority-medium @REQ-026 @AC-026.1 @AC-026.2 @AC-026.4 @screen-public-tracking @OMS022-POS-022
  Scenario: Setiap entri riwayat menampilkan keterangan dan penanda waktu
    Given data pengiriman resi "LKL7920830903" bertipe "Multi Pick Up 2" dengan 2 alamat pick up dan 1 alamat drop off
    And armada telah melaporkan seluruh event "Selesai Muat"
    When user mengisi field "No. Resi" dengan "LKL7920830903"
    And user mengklik tombol "Lacak"
    Then setiap entri riwayat memiliki "history-item-text"
    And setiap entri riwayat memiliki "history-item-timestamp"
    And entri riwayat bertipe "sintetis" memiliki "history-item-timestamp"

  @positive @priority-high @REQ-027 @AC-027.1 @AC-027.2 @AC-027.3 @screen-public-tracking @OMS022-POS-023
  Scenario Outline: Stepper konsisten dengan isi Riwayat Pengiriman — <kondisi>
    Given data pengiriman resi "<resi>" bertipe "<tipe>" dengan <pickup> alamat pick up dan <drop> alamat drop off
    And armada telah melaporkan event kronologis sampai "<kondisi>"
    When user mengisi field "No. Resi" dengan "<resi>"
    And user mengklik tombol "Lacak"
    Then simpul stepper "Pick Up" berstate "<pickUp>"
    And simpul stepper "On Delivery" berstate "<onDelivery>"
    And simpul stepper "Delivered" berstate "<delivered>"
    And jumlah entri riwayat bertipe "muat" adalah <entriMuat>
    And jumlah entri riwayat bertipe "sintetis" adalah <entriSintetis>
    And jumlah entri riwayat bertipe "bongkar" adalah <entriBongkar>

    Examples:
      | resi          | tipe            | pickup | drop | kondisi              | pickUp  | onDelivery | delivered | entriMuat | entriSintetis | entriBongkar |
      | LKL8900765636 | Multi Pick Up 3 | 3      | 1    | belum ada event      | pending | pending    | pending   | 0         | 0             | 0            |
      | LKL8900765636 | Multi Pick Up 3 | 3      | 1    | Selesai Muat ke-1    | reached | pending    | pending   | 1         | 0             | 0            |
      | LKL8900765636 | Multi Pick Up 3 | 3      | 1    | Selesai Muat ke-3    | reached | reached    | pending   | 3         | 1             | 0            |
      | LKL8900765636 | Multi Pick Up 3 | 3      | 1    | Selesai Bongkar ke-1 | reached | reached    | reached   | 3         | 1             | 1            |
      | LKL4410238877 | Multi Drop 2    | 1      | 2    | Selesai Bongkar ke-1 | reached | reached    | pending   | 1         | 1             | 1            |
      | LKL4410238877 | Multi Drop 2    | 1      | 2    | Selesai Bongkar ke-2 | reached | reached    | reached   | 1         | 1             | 2            |

  @positive @priority-medium @REQ-016 @AC-016.1 @AC-016.2 @AC-016.3 @AC-021.4 @ALT-03 @screen-public-tracking @OMS022-POS-024
  Scenario: Resi valid tanpa event menampilkan stepper seluruhnya pending dan riwayat empty state
    Given data pengiriman resi "LKL3300112244" bertipe "Normal" dengan 1 alamat pick up dan 1 alamat drop off
    And belum ada event yang dilaporkan armada
    When user mengisi field "No. Resi" dengan "LKL3300112244"
    And user mengklik tombol "Lacak"
    Then sistem menampilkan "tracking-stepper"
    And simpul stepper "Pick Up" berstate "pending"
    And simpul stepper "On Delivery" berstate "pending"
    And simpul stepper "Delivered" berstate "pending"
    And sistem menampilkan "history-empty"
    And sistem tidak menampilkan "tracking-error"

  @positive @priority-high @REQ-015 @AC-015.4 @AC-021.3 @screen-public-tracking @OMS022-POS-025
  Scenario: State stepper dan riwayat persisten setelah halaman dimuat ulang
    Given data pengiriman resi "LKL7920830903" bertipe "Multi Pick Up 2" dengan 2 alamat pick up dan 1 alamat drop off
    And armada telah melaporkan seluruh event "Selesai Muat"
    When user mengisi field "No. Resi" dengan "LKL7920830903"
    And user mengklik tombol "Lacak"
    And user memuat ulang halaman lalu melacak resi yang sama
    Then simpul stepper "Pick Up" berstate "reached"
    And simpul stepper "On Delivery" berstate "reached"
    And simpul stepper "Delivered" berstate "pending"
    And jumlah entri riwayat bertipe "muat" adalah 2
    And entri riwayat bertipe "sintetis" muncul tepat 1 kali

  @positive @priority-medium @V-02 @REQ-003 @screen-public-tracking @OMS022-POS-026
  Scenario: Whitespace di awal dan akhir No. Resi di-trim sebelum pencarian
    Given data pengiriman resi "LKL2567828992" bertipe "Normal" dengan 1 alamat pick up dan 1 alamat drop off
    When user mengisi field "No. Resi" dengan "   LKL2567828992   "
    And user mengklik tombol "Lacak"
    Then sistem menampilkan "tracking-result"
    And sistem menampilkan teks "LKL2567828992"
    And sistem tidak menampilkan "tracking-not-found"

  @positive @priority-low @ASM-025 @screen-public-tracking @OMS022-POS-027
  Scenario: Indikator loading tampil saat pencarian berjalan lalu hilang setelah hasil dirender
    Given data pengiriman resi "LKL2567828992" bertipe "Normal" dengan 1 alamat pick up dan 1 alamat drop off
    When user mengisi field "No. Resi" dengan "LKL2567828992"
    And user mengklik tombol "Lacak"
    Then sistem menyembunyikan "tracking-loading"
    And sistem menampilkan "tracking-result"

  @positive @priority-high @REQ-009 @REQ-010 @REQ-011 @REQ-012 @REQ-013 @REQ-014 @REQ-017 @REQ-018 @REQ-019 @REQ-020 @screen-public-tracking @OMS022-POS-028
  Scenario Outline: Matriks pemetaan event -> tahap stepper baris <baris> — <tipe> / <event> ke-<ordinal>
    Given data pengiriman resi "<resi>" bertipe "<tipe>" dengan <pickup> alamat pick up dan <drop> alamat drop off
    And armada telah melaporkan event kronologis sampai "<event> ke-<ordinal>"
    When user mengisi field "No. Resi" dengan "<resi>"
    And user mengklik tombol "Lacak"
    Then simpul stepper "Pick Up" berstate "<pickUp>"
    And simpul stepper "On Delivery" berstate "<onDelivery>"
    And simpul stepper "Delivered" berstate "<delivered>"

    Examples:
      | baris | resi          | tipe            | pickup | drop | event           | ordinal | pickUp  | onDelivery | delivered | perubahan |
      | 1     | LKL2567828992 | Normal          | 1      | 1    | Selesai Muat    | 1       | reached | reached    | pending   | +2        |
      | 2     | LKL2567828992 | Normal          | 1      | 1    | Selesai Bongkar | 1       | reached | reached    | reached   | +1        |
      | 3     | LKL7920830903 | Multi Pick Up 2 | 2      | 1    | Selesai Muat    | 1       | reached | pending    | pending   | +1        |
      | 4     | LKL7920830903 | Multi Pick Up 2 | 2      | 1    | Selesai Muat    | 2       | reached | reached    | pending   | +1        |
      | 5     | LKL7920830903 | Multi Pick Up 2 | 2      | 1    | Selesai Bongkar | 1       | reached | reached    | reached   | +1        |
      | 6     | LKL8900765636 | Multi Pick Up 3 | 3      | 1    | Selesai Muat    | 2       | reached | pending    | pending   | 0         |
      | 7     | LKL4410238877 | Multi Drop 2    | 1      | 2    | Selesai Muat    | 1       | reached | reached    | pending   | +2        |
      | 8     | LKL4410238877 | Multi Drop 2    | 1      | 2    | Selesai Bongkar | 1       | reached | reached    | pending   | 0         |
      | 9     | LKL4410238877 | Multi Drop 2    | 1      | 2    | Selesai Bongkar | 2       | reached | reached    | reached   | +1        |
      | 10    | LKL5521349900 | Multipoint 2x2  | 2      | 2    | Selesai Muat    | 1       | reached | pending    | pending   | +1        |
      | 11    | LKL5521349900 | Multipoint 2x2  | 2      | 2    | Selesai Muat    | 2       | reached | reached    | pending   | +1        |
      | 12    | LKL5521349900 | Multipoint 2x2  | 2      | 2    | Selesai Bongkar | 1       | reached | reached    | pending   | 0         |
      | 13    | LKL5521349900 | Multipoint 2x2  | 2      | 2    | Selesai Bongkar | 2       | reached | reached    | reached   | +1        |

  @positive @priority-medium @REQ-008 @AC-008.3 @AC-009.3 @ASM-010 @screen-public-tracking @OMS022-POS-029
  Scenario Outline: Label tahap stepper konsisten untuk seluruh tipe pengiriman — <tipe>
    Given data pengiriman resi "<resi>" bertipe "<tipe>" dengan <pickup> alamat pick up dan <drop> alamat drop off
    And armada telah melaporkan event "Selesai Muat" ke-1
    When user mengisi field "No. Resi" dengan "<resi>"
    And user mengklik tombol "Lacak"
    Then simpul stepper "Pick Up" tersedia pada stepper
    And simpul stepper "On Delivery" tersedia pada stepper
    And simpul stepper "Delivered" tersedia pada stepper
    And simpul stepper "Pick Up" berstate "reached"

    Examples:
      | resi          | tipe            | pickup | drop |
      | LKL2567828992 | Normal          | 1      | 1    |
      | LKL7920830903 | Multi Pick Up 2 | 2      | 1    |
      | LKL8900765636 | Multi Pick Up 3 | 3      | 1    |
      | LKL4410238877 | Multi Drop 2    | 1      | 2    |
      | LKL5521349900 | Multipoint 2x2  | 2      | 2    |

  @positive @priority-low @ALT-10 @ASM-013 @REQ-027 @screen-public-tracking @OMS022-POS-030
  Scenario Outline: Beberapa No. Resi pada satu order menampilkan progres pengiriman yang sama — <resi>
    Given order "ORD-20260607009" memiliki resi "LKL7920830903" dan "LKL8900765636" pada armada yang sama
    And armada telah melaporkan seluruh event "Selesai Muat"
    When user mengisi field "No. Resi" dengan "<resi>"
    And user mengklik tombol "Lacak"
    Then simpul stepper "Pick Up" berstate "reached"
    And simpul stepper "On Delivery" berstate "reached"
    And simpul stepper "Delivered" berstate "pending"
    And entri riwayat bertipe "sintetis" muncul tepat 1 kali

    Examples:
      | resi          |
      | LKL7920830903 |
      | LKL8900765636 |

  # ===================================================================
  # KATEGORI: NEGATIVE
  # ===================================================================

  @negative @priority-high @V-01 @ALT-01 @ASM-021 @screen-public-tracking @OMS022-NEG-001
  Scenario: Submit dengan No. Resi kosong ditahan dan menampilkan pesan validasi wajib
    When user mengosongkan field "No. Resi"
    And user mengklik tombol "Lacak"
    Then sistem menampilkan "resi-input-error"
    And sistem menampilkan pesan "harus diisi"
    And field "No. Resi" bernilai aria-invalid "true"
    And sistem tidak menampilkan "tracking-result"

  @negative @priority-high @V-01 @V-02 @ALT-01 @screen-public-tracking @OMS022-NEG-002
  Scenario: Submit dengan No. Resi berisi hanya spasi diperlakukan sama dengan kosong
    When user mengisi field "No. Resi" dengan "      "
    And user mengklik tombol "Lacak"
    Then sistem menampilkan "resi-input-error"
    And sistem tidak menampilkan "tracking-result"
    And sistem tidak menampilkan "tracking-stepper"

  @negative @priority-high @V-04 @ALT-02 @ASM-022 @screen-public-tracking @OMS022-NEG-003
  Scenario: No. Resi tidak terdaftar menampilkan empty state, bukan halaman error
    Given tidak ada pengiriman dengan resi "LKL0000000000"
    When user mengisi field "No. Resi" dengan "LKL0000000000"
    And user mengklik tombol "Lacak"
    Then sistem menampilkan "tracking-not-found"
    And sistem menampilkan pesan "tidak ditemukan"
    And sistem tidak menampilkan "tracking-error"
    And field "No. Resi" tetap bernilai "LKL0000000000"

  @negative @priority-high @V-04 @ALT-02 @screen-public-tracking @OMS022-NEG-004
  Scenario: No. Resi tidak ditemukan tidak merender stepper maupun Riwayat Pengiriman
    Given tidak ada pengiriman dengan resi "LKL0000000000"
    When user mengisi field "No. Resi" dengan "LKL0000000000"
    And user mengklik tombol "Lacak"
    Then sistem tidak menampilkan "tracking-stepper"
    And sistem tidak menampilkan "history-list"
    And sistem tidak menampilkan "tracking-summary"

  @negative @priority-high @REQ-003 @AC-003.1 @V-13 @screen-public-tracking @OMS022-NEG-005
  Scenario: Halaman tidak pernah mengarahkan pengunjung ke halaman login
    Given data pengiriman resi "LKL2567828992" bertipe "Normal" dengan 1 alamat pick up dan 1 alamat drop off
    When user mengisi field "No. Resi" dengan "LKL2567828992"
    And user mengklik tombol "Lacak"
    Then user tidak diarahkan ke halaman "Login"
    And sistem tidak menampilkan "field Email/Kata Sandi"

  @negative @priority-high @REQ-004 @AC-004.1 @screen-public-tracking @OMS022-NEG-006
  Scenario Outline: Tombol mutasi data "<tombol>" tidak tersedia pada halaman public tracking
    Given data pengiriman resi "LKL4410238877" bertipe "Multi Drop 2" dengan 1 alamat pick up dan 2 alamat drop off
    And armada telah melaporkan seluruh event "Selesai Muat"
    When user mengisi field "No. Resi" dengan "LKL4410238877"
    And user mengklik tombol "Lacak"
    Then sistem tidak menampilkan tombol "<tombol>"

    Examples:
      | tombol      |
      | Edit        |
      | Batalkan    |
      | Simpan      |
      | Ubah Status |

  @negative @priority-high @REQ-004 @AC-004.2 @screen-public-tracking @OMS022-NEG-007
  Scenario: Area hasil tracking tidak memuat input aktif maupun dropdown
    Given data pengiriman resi "LKL2567828992" bertipe "Normal" dengan 1 alamat pick up dan 1 alamat drop off
    And armada telah melaporkan seluruh event "Selesai Muat"
    When user mengisi field "No. Resi" dengan "LKL2567828992"
    And user mengklik tombol "Lacak"
    Then area hasil tidak memuat input aktif
    And area hasil tidak memuat elemen "combobox"

  @negative @priority-high @REQ-002 @REQ-005 @V-06 @AC-002.1 @AC-002.2 @AC-005.1 @screen-public-tracking @OMS022-NEG-008
  Scenario Outline: Status antara TMS "<statusAntara>" tidak boleh muncul di Riwayat Pengiriman OMS
    Given data pengiriman resi "LKL5521349900" bertipe "Multipoint 2x2" dengan 2 alamat pick up dan 2 alamat drop off
    And armada telah melaporkan seluruh event "Selesai Muat"
    And armada telah melaporkan seluruh event "Selesai Bongkar"
    When user mengisi field "No. Resi" dengan "LKL5521349900"
    And user mengklik tombol "Lacak"
    Then sistem tidak menampilkan teks "<statusAntara>" pada "history-list"

    Examples:
      | statusAntara            |
      | Menuju Lokasi Muat      |
      | Tiba di Lokasi Muat     |
      | Tiba di Lokasi Bongkar  |
      | Dalam Perjalanan        |

  @negative @priority-high @REQ-002 @AC-002.3 @V-05 @ASM-009 @screen-public-tracking @OMS022-NEG-009
  Scenario: Stepper tidak memuat simpul berlabel status antara TMS
    Given data pengiriman resi "LKL7920830903" bertipe "Multi Pick Up 2" dengan 2 alamat pick up dan 1 alamat drop off
    And armada telah melaporkan seluruh event "Selesai Muat"
    When user mengisi field "No. Resi" dengan "LKL7920830903"
    And user mengklik tombol "Lacak"
    Then sistem tidak menampilkan teks "Menuju Lokasi Muat" pada "tracking-stepper"
    And sistem tidak menampilkan teks "Tiba di Lokasi" pada "tracking-stepper"
    And simpul stepper "Pick Up" tersedia pada stepper
    And simpul stepper "On Delivery" tersedia pada stepper
    And simpul stepper "Delivered" tersedia pada stepper

  @negative @priority-high @REQ-013 @V-11 @AC-013.1 @ALT-06 @screen-public-tracking @OMS022-NEG-010
  Scenario: Multi Pick Up 3 — Selesai Muat ke-2 tidak menaikkan tahap (no-op), On Delivery tetap pending
    Given data pengiriman resi "LKL8900765636" bertipe "Multi Pick Up 3" dengan 3 alamat pick up dan 1 alamat drop off
    And armada telah melaporkan event kronologis sampai "Selesai Muat ke-2"
    When user mengisi field "No. Resi" dengan "LKL8900765636"
    And user mengklik tombol "Lacak"
    Then simpul stepper "Pick Up" berstate "reached"
    And simpul stepper "On Delivery" berstate "pending"
    And simpul stepper "Delivered" berstate "pending"
    And jumlah entri riwayat bertipe "muat" adalah 2

  @negative @priority-high @REQ-023 @V-08 @AC-023.2 @screen-public-tracking @OMS022-NEG-011
  Scenario: Entri sintetis belum muncul selama masih ada alamat pick up yang belum Selesai Muat
    Given data pengiriman resi "LKL8900765636" bertipe "Multi Pick Up 3" dengan 3 alamat pick up dan 1 alamat drop off
    And armada telah melaporkan event kronologis sampai "Selesai Muat ke-2"
    When user mengisi field "No. Resi" dengan "LKL8900765636"
    And user mengklik tombol "Lacak"
    Then jumlah entri riwayat bertipe "sintetis" adalah 0
    And sistem tidak menampilkan teks "dalam perjalanan menuju lokasi bongkar" pada "history-list"

  @negative @priority-high @REQ-014 @V-12 @AC-014.1 @AC-014.2 @ALT-07 @screen-public-tracking @OMS022-NEG-012
  Scenario: Multi Drop 2 — Selesai Bongkar ke-1 tidak menaikkan tahap (no-op), Delivered tetap pending
    Given data pengiriman resi "LKL4410238877" bertipe "Multi Drop 2" dengan 1 alamat pick up dan 2 alamat drop off
    And armada telah melaporkan event kronologis sampai "Selesai Bongkar ke-1"
    When user mengisi field "No. Resi" dengan "LKL4410238877"
    And user mengklik tombol "Lacak"
    Then simpul stepper "Pick Up" berstate "reached"
    And simpul stepper "On Delivery" berstate "reached"
    And simpul stepper "Delivered" berstate "pending"
    And jumlah entri riwayat bertipe "bongkar" adalah 1

  @negative @priority-high @REQ-010 @V-11 @AC-010.3 @screen-public-tracking @OMS022-NEG-013
  Scenario: On Delivery tidak tercapai selagi masih ada alamat pick up yang belum Selesai Muat
    Given data pengiriman resi "LKL7920830903" bertipe "Multi Pick Up 2" dengan 2 alamat pick up dan 1 alamat drop off
    And armada telah melaporkan event kronologis sampai "Selesai Muat ke-1"
    When user mengisi field "No. Resi" dengan "LKL7920830903"
    And user mengklik tombol "Lacak"
    Then simpul stepper "On Delivery" berstate "pending"
    And jumlah entri riwayat bertipe "sintetis" adalah 0

  @negative @priority-medium @REQ-016 @AC-016.1 @AC-016.2 @screen-public-tracking @OMS022-NEG-014
  Scenario: Sebelum event Selesai Muat pertama seluruh simpul stepper belum tercapai
    Given data pengiriman resi "LKL3300112244" bertipe "Normal" dengan 1 alamat pick up dan 1 alamat drop off
    And belum ada event yang dilaporkan armada
    When user mengisi field "No. Resi" dengan "LKL3300112244"
    And user mengklik tombol "Lacak"
    Then simpul stepper "Pick Up" berstate "pending"
    And simpul stepper "On Delivery" berstate "pending"
    And simpul stepper "Delivered" berstate "pending"
    And jumlah entri riwayat bertipe "muat" adalah 0

  @negative @priority-high @REQ-004 @AC-004.3 @V-13 @screen-public-tracking @OMS022-NEG-015
  Scenario: Data pengiriman resi lain tidak terekspos saat melacak resi tertentu
    Given data pengiriman resi "LKL2567828992" bertipe "Normal" dengan 1 alamat pick up dan 1 alamat drop off
    And data pengiriman resi "LKL8900765636" bertipe "Multi Pick Up 3" dengan 3 alamat pick up dan 1 alamat drop off
    And armada telah melaporkan seluruh event "Selesai Muat"
    When user mengisi field "No. Resi" dengan "LKL2567828992"
    And user mengklik tombol "Lacak"
    Then sistem menampilkan teks "LKL2567828992"
    And sistem tidak menampilkan teks "LKL8900765636"
    And jumlah entri riwayat bertipe "muat" adalah 1

  @negative @priority-low @V-03 @ASM-021 @screen-public-tracking @OMS022-NEG-016
  Scenario Outline: No. Resi berformat tidak valid "<resi>" ditolak atau menghasilkan empty state (non-blocking)
    When user mengisi field "No. Resi" dengan "<resi>"
    And user mengklik tombol "Lacak"
    Then sistem menampilkan salah satu dari "resi-input-error" atau "tracking-not-found"
    And sistem tidak menampilkan "tracking-error"
    And sistem tidak menampilkan "tracking-stepper"

    Examples:
      | resi              |
      | LKL 2567 828992   |
      | LKL@2567#828992   |
      | ---------------   |
      | ///////           |

  @negative @priority-high @REQ-024 @V-08 @AC-024.1 @screen-public-tracking @OMS022-NEG-017
  Scenario: Entri sintetis tidak digandakan meskipun alamat pick up lebih dari satu
    Given data pengiriman resi "LKL8900765636" bertipe "Multi Pick Up 3" dengan 3 alamat pick up dan 1 alamat drop off
    And armada telah melaporkan seluruh event "Selesai Muat"
    When user mengisi field "No. Resi" dengan "LKL8900765636"
    And user mengklik tombol "Lacak"
    Then jumlah entri riwayat bertipe "sintetis" adalah 1
    And jumlah entri riwayat bertipe "sintetis" bukan 3

  @negative @priority-high @REQ-015 @V-10 @AC-015.2 @AC-015.3 @screen-public-tracking @OMS022-NEG-018
  Scenario: Delivered tidak pernah tercapai mendahului On Delivery maupun Pick Up
    Given data pengiriman resi "LKL5521349900" bertipe "Multipoint 2x2" dengan 2 alamat pick up dan 2 alamat drop off
    And armada telah melaporkan event kronologis sampai "Selesai Muat ke-1"
    When user mengisi field "No. Resi" dengan "LKL5521349900"
    And user mengklik tombol "Lacak"
    Then simpul stepper "Delivered" berstate "pending"
    And simpul stepper "On Delivery" berstate "pending"
    And tidak ada simpul stepper "reached" yang mendahului simpul sebelumnya bernilai "pending"

  @negative @priority-medium @ASM-022 @V-04 @screen-public-tracking @OMS022-NEG-019
  Scenario: Gangguan sistem menampilkan state error dengan tombol coba lagi, dibedakan dari not found
    Given layanan tracking mengembalikan gangguan sistem untuk resi "LKL2567828992"
    When user mengisi field "No. Resi" dengan "LKL2567828992"
    And user mengklik tombol "Lacak"
    Then sistem menampilkan "tracking-error"
    And sistem menampilkan tombol "Coba Lagi"
    And sistem tidak menampilkan "tracking-not-found"

  @negative @priority-medium @REQ-021 @AC-021.4 @ALT-03 @screen-public-tracking @OMS022-NEG-020
  Scenario: Riwayat kosong tidak memunculkan pesan error atau stack trace
    Given data pengiriman resi "LKL3300112244" bertipe "Normal" dengan 1 alamat pick up dan 1 alamat drop off
    And belum ada event yang dilaporkan armada
    When user mengisi field "No. Resi" dengan "LKL3300112244"
    And user mengklik tombol "Lacak"
    Then sistem menampilkan "Riwayat Pengiriman"
    And sistem tidak menampilkan teks "terjadi kesalahan sistem"
    And sistem tidak menampilkan teks "stack trace"
    And sistem tidak menampilkan teks "error 500"

  @negative @priority-medium @REQ-020 @V-12 @AC-020.3 @ALT-08 @screen-public-tracking @OMS022-NEG-021
  Scenario: Multipoint 2x2 — Selesai Bongkar ke-1 tidak memicu Delivered
    Given data pengiriman resi "LKL5521349900" bertipe "Multipoint 2x2" dengan 2 alamat pick up dan 2 alamat drop off
    And armada telah melaporkan event kronologis sampai "Selesai Bongkar ke-1"
    When user mengisi field "No. Resi" dengan "LKL5521349900"
    And user mengklik tombol "Lacak"
    Then simpul stepper "Delivered" berstate "pending"
    And simpul stepper "On Delivery" berstate "reached"
    And jumlah entri riwayat bertipe "bongkar" adalah 1

  @negative @priority-low @REQ-003 @ASM-026 @screen-public-tracking @OMS022-NEG-022
  Scenario: Shell aplikasi terautentikasi tidak muncul pada halaman publik (non-blocking)
    Given data pengiriman resi "LKL2567828992" bertipe "Normal" dengan 1 alamat pick up dan 1 alamat drop off
    When user mengisi field "No. Resi" dengan "LKL2567828992"
    And user mengklik tombol "Lacak"
    Then sistem tidak menampilkan teks "Staff Operasional"
    And sistem tidak menampilkan teks "Kuota Order"

  @negative @priority-high @V-04 @ASM-022 @screen-public-tracking @OMS022-NEG-023
  Scenario: Empty state not found tidak boleh berupa halaman error teknis
    Given tidak ada pengiriman dengan resi "ZZZ9999999999"
    When user mengisi field "No. Resi" dengan "ZZZ9999999999"
    And user mengklik tombol "Lacak"
    Then sistem menampilkan pesan "tidak ditemukan"
    And sistem tidak menampilkan teks "error 500"
    And sistem tidak menampilkan teks "stack trace"
    And sistem menampilkan field "No. Resi"

  @negative @priority-medium @REQ-006 @V-07 @AC-006.5 @ASM-015 @screen-public-tracking @OMS022-NEG-024
  Scenario: Jumlah entri muat tidak melebihi jumlah alamat pick up meskipun event dilaporkan berulang
    Given data pengiriman resi "LKL7920830903" bertipe "Multi Pick Up 2" dengan 2 alamat pick up dan 1 alamat drop off
    And armada melaporkan event "Selesai Muat" ke-1 sebanyak 2 kali pada alamat yang sama
    When user mengisi field "No. Resi" dengan "LKL7920830903"
    And user mengklik tombol "Lacak"
    Then jumlah entri riwayat bertipe "muat" tidak lebih dari 2
    And simpul stepper "On Delivery" berstate "pending"

  @negative @priority-medium @REQ-007 @AC-007.3 @screen-public-tracking @OMS022-NEG-025
  Scenario: Selesai Bongkar tidak boleh tercatat selagi masih ada alamat pick up yang belum Selesai Muat
    Given data pengiriman resi "LKL8900765636" bertipe "Multi Pick Up 3" dengan 3 alamat pick up dan 1 alamat drop off
    And armada telah melaporkan event kronologis sampai "Selesai Muat ke-2"
    When user mengisi field "No. Resi" dengan "LKL8900765636"
    And user mengklik tombol "Lacak"
    Then jumlah entri riwayat bertipe "bongkar" adalah 0
    And simpul stepper "Delivered" berstate "pending"

  # ===================================================================
  # KATEGORI: EDGE
  # Catatan step-def: token {sp}=spasi, {tab}=tab, {nl}=newline, {zwsp}=U+200B
  # dieskpansi oleh step definition sebelum diisikan ke field (Gherkin
  # memangkas whitespace pada sel Examples sehingga tidak bisa literal).
  # ===================================================================

  @edge @priority-medium @V-02 @screen-public-tracking @OMS022-EDG-001
  Scenario Outline: Trim whitespace pada berbagai bentuk input resi — <label>
    Given data pengiriman resi "LKL2567828992" bertipe "Normal" dengan 1 alamat pick up dan 1 alamat drop off
    When user mengisi field "No. Resi" dengan "<resi>"
    And user mengklik tombol "Lacak"
    Then sistem menampilkan "tracking-result"
    And sistem menampilkan teks "LKL2567828992"

    Examples:
      | label           | resi                     |
      | spasi-depan     | {sp}{sp}LKL2567828992    |
      | spasi-belakang  | LKL2567828992{sp}{sp}    |
      | spasi-dua-sisi  | {sp}LKL2567828992{sp}    |
      | tab-dan-newline | {tab}LKL2567828992{nl}   |

  @edge @priority-low @V-03 @ASM-010 @screen-public-tracking @OMS022-EDG-002
  Scenario: No. Resi dalam huruf kecil tetap menemukan pengiriman atau menampilkan empty state yang benar
    Given data pengiriman resi "LKL2567828992" bertipe "Normal" dengan 1 alamat pick up dan 1 alamat drop off
    When user mengisi field "No. Resi" dengan "lkl2567828992"
    And user mengklik tombol "Lacak"
    Then sistem menampilkan salah satu dari "tracking-result" atau "tracking-not-found"
    And sistem tidak menampilkan "tracking-error"

  @edge @priority-medium @V-03 @V-04 @screen-public-tracking @OMS022-EDG-003
  Scenario Outline: Panjang No. Resi ekstrem <label> tidak membuat halaman error
    When user mengisi field "No. Resi" dengan "<resi>"
    And user mengklik tombol "Lacak"
    Then sistem menampilkan salah satu dari "resi-input-error" atau "tracking-not-found"
    And sistem tidak menampilkan "tracking-error"

    Examples:
      | label       | resi |
      | 1-karakter  | L |
      | 2-karakter  | LK |
      | 64-karakter | LKL25678289921234567890123456789012345678901234567890123456789012 |
      | 256-karakter | LKL2567828992LKL2567828992LKL2567828992LKL2567828992LKL2567828992LKL2567828992LKL2567828992LKL2567828992LKL2567828992LKL2567828992LKL2567828992LKL2567828992LKL2567828992LKL2567828992LKL2567828992LKL2567828992LKL2567828992LKL2567828992LKL256782899212345 |

  @edge @priority-high @V-03 @V-04 @screen-public-tracking @OMS022-EDG-004
  Scenario Outline: Payload berbahaya <label> pada No. Resi tidak dieksekusi dan tidak menyebabkan error server
    When user mengisi field "No. Resi" dengan "<resi>"
    And user mengklik tombol "Lacak"
    Then sistem tidak menampilkan "tracking-error"
    And sistem tidak menampilkan teks "error 500"
    And sistem tidak menampilkan teks "SQL"
    And tidak ada dialog javascript yang terpicu

    Examples:
      | label           | resi |
      | sql-or          | ' OR '1'='1 |
      | sql-drop        | LKL1'; DROP TABLE orders;-- |
      | xss-script      | <script>alert(1)</script> |
      | xss-img-onerror | <img src=x onerror=alert(1)> |
      | template-inject | {{7*7}} |
      | path-traversal  | ../../etc/passwd |

  @edge @priority-low @V-03 @screen-public-tracking @OMS022-EDG-005
  Scenario Outline: Karakter non-ASCII <label> pada No. Resi ditangani tanpa crash
    When user mengisi field "No. Resi" dengan "<resi>"
    And user mengklik tombol "Lacak"
    Then sistem menampilkan salah satu dari "resi-input-error" atau "tracking-not-found"
    And sistem tidak menampilkan "tracking-error"

    Examples:
      | label       | resi |
      | emoji       | LKL256TRUCK8992 |
      | sirilik     | resiLKL256 |
      | angka-arab  | LKL0123456789 |
      | zero-width  | LKL25{zwsp}67828992 |

  @edge @priority-high @REQ-009 @REQ-013 @AC-009.1 @screen-public-tracking @OMS022-EDG-006
  Scenario: Multi Pick Up 3 dengan baru satu alamat termuat — Pick Up tercapai, sintetis belum ada
    Given data pengiriman resi "LKL8900765636" bertipe "Multi Pick Up 3" dengan 3 alamat pick up dan 1 alamat drop off
    And armada telah melaporkan event kronologis sampai "Selesai Muat ke-1"
    When user mengisi field "No. Resi" dengan "LKL8900765636"
    And user mengklik tombol "Lacak"
    Then simpul stepper "Pick Up" berstate "reached"
    And simpul stepper "On Delivery" berstate "pending"
    And jumlah entri riwayat bertipe "muat" adalah 1
    And jumlah entri riwayat bertipe "sintetis" adalah 0

  @edge @priority-high @REQ-023 @AC-023.3 @REQ-012 @screen-public-tracking @OMS022-EDG-007
  Scenario: Batas bawah alamat pick up = 1 — entri sintetis muncul langsung setelah satu-satunya Selesai Muat
    Given data pengiriman resi "LKL2567828992" bertipe "Normal" dengan 1 alamat pick up dan 1 alamat drop off
    And armada telah melaporkan event "Selesai Muat" ke-1
    When user mengisi field "No. Resi" dengan "LKL2567828992"
    And user mengklik tombol "Lacak"
    Then jumlah entri riwayat bertipe "muat" adalah 1
    And jumlah entri riwayat bertipe "sintetis" adalah 1
    And entri riwayat bertipe "sintetis" berada setelah entri terakhir bertipe "muat"
    And simpul stepper "On Delivery" berstate "reached"

  @edge @priority-high @REQ-014 @REQ-019 @AC-019.4 @AC-025.3 @screen-public-tracking @OMS022-EDG-008
  Scenario: Divergensi stepper vs riwayat — Multi Drop 2 mencatat 2 entri bongkar meski stepper hanya bergerak sekali
    Given data pengiriman resi "LKL4410238877" bertipe "Multi Drop 2" dengan 1 alamat pick up dan 2 alamat drop off
    And armada telah melaporkan event kronologis sampai "Selesai Bongkar ke-1"
    When user mengisi field "No. Resi" dengan "LKL4410238877"
    And user mengklik tombol "Lacak"
    Then jumlah entri riwayat bertipe "bongkar" adalah 1
    And simpul stepper "Delivered" berstate "pending"
    When armada melaporkan event "Selesai Bongkar" ke-2
    And user memuat ulang halaman lalu melacak resi yang sama
    Then jumlah entri riwayat bertipe "bongkar" adalah 2
    And simpul stepper "Delivered" berstate "reached"

  @edge @priority-high @REQ-013 @AC-013.3 @AC-022.5 @screen-public-tracking @OMS022-EDG-009
  Scenario: Divergensi stepper vs riwayat — muat tengah menambah entri riwayat tanpa mengubah state stepper
    Given data pengiriman resi "LKL8900765636" bertipe "Multi Pick Up 3" dengan 3 alamat pick up dan 1 alamat drop off
    And armada telah melaporkan event kronologis sampai "Selesai Muat ke-1"
    When user mengisi field "No. Resi" dengan "LKL8900765636"
    And user mengklik tombol "Lacak"
    Then jumlah entri riwayat bertipe "muat" adalah 1
    And simpul stepper "On Delivery" berstate "pending"
    When armada melaporkan event "Selesai Muat" ke-2
    And user memuat ulang halaman lalu melacak resi yang sama
    Then jumlah entri riwayat bertipe "muat" adalah 2
    And simpul stepper "Pick Up" berstate "reached"
    And simpul stepper "On Delivery" berstate "pending"
    And simpul stepper "Delivered" berstate "pending"

  @edge @priority-high @REQ-015 @V-10 @AC-015.1 @screen-public-tracking @OMS022-EDG-010
  Scenario: Monotonisitas — tidak ada simpul yang berubah dari reached menjadi pending sepanjang siklus event
    Given data pengiriman resi "LKL5521349900" bertipe "Multipoint 2x2" dengan 2 alamat pick up dan 2 alamat drop off
    And belum ada event yang dilaporkan armada
    When user mengisi field "No. Resi" dengan "LKL5521349900"
    And user mengklik tombol "Lacak"
    And sistem merekam snapshot state stepper
    And armada melaporkan seluruh event secara berurutan dengan snapshot state stepper setiap langkah
    Then tidak ada transisi state simpul dari "reached" menjadi "pending"
    And simpul stepper "Delivered" berstate "reached"

  @edge @priority-medium @REQ-015 @AC-015.4 @ASM-014 @screen-public-tracking @OMS022-EDG-011
  Scenario: Reload berulang tidak mengubah state stepper maupun jumlah entri riwayat
    Given data pengiriman resi "LKL8900765636" bertipe "Multi Pick Up 3" dengan 3 alamat pick up dan 1 alamat drop off
    And armada telah melaporkan seluruh event "Selesai Muat"
    When user mengisi field "No. Resi" dengan "LKL8900765636"
    And user mengklik tombol "Lacak"
    And user memuat ulang halaman lalu melacak resi yang sama sebanyak 3 kali
    Then simpul stepper "On Delivery" berstate "reached"
    And jumlah entri riwayat bertipe "muat" adalah 3
    And jumlah entri riwayat bertipe "sintetis" adalah 1

  @edge @priority-high @REQ-024 @AC-024.4 @screen-public-tracking @OMS022-EDG-012
  Scenario: Entri sintetis tetap ada dan tetap tunggal setelah seluruh event bongkar selesai
    Given data pengiriman resi "LKL5521349900" bertipe "Multipoint 2x2" dengan 2 alamat pick up dan 2 alamat drop off
    And armada telah melaporkan seluruh event "Selesai Muat"
    And armada telah melaporkan seluruh event "Selesai Bongkar"
    When user mengisi field "No. Resi" dengan "LKL5521349900"
    And user mengklik tombol "Lacak"
    Then jumlah entri riwayat bertipe "sintetis" adalah 1
    And entri riwayat bertipe "sintetis" berada sebelum entri pertama bertipe "bongkar"
    And simpul stepper "Delivered" berstate "reached"

  @edge @priority-medium @V-13 @AC-004.3 @screen-public-tracking @OMS022-EDG-013
  Scenario: Pencarian resi kedua mengganti hasil sepenuhnya tanpa menyisakan data resi sebelumnya
    Given data pengiriman resi "LKL8900765636" bertipe "Multi Pick Up 3" dengan 3 alamat pick up dan 1 alamat drop off
    And data pengiriman resi "LKL2567828992" bertipe "Normal" dengan 1 alamat pick up dan 1 alamat drop off
    And armada telah melaporkan seluruh event "Selesai Muat"
    When user mengisi field "No. Resi" dengan "LKL8900765636"
    And user mengklik tombol "Lacak"
    And user mengisi field "No. Resi" dengan "LKL2567828992"
    And user mengklik tombol "Lacak"
    Then sistem menampilkan teks "LKL2567828992"
    And sistem tidak menampilkan teks "LKL8900765636"
    And jumlah entri riwayat bertipe "muat" adalah 1

  @edge @priority-low @REQ-003 @screen-public-tracking @OMS022-EDG-014
  Scenario: Pencarian dapat disubmit dengan menekan tombol Enter pada field No. Resi
    Given data pengiriman resi "LKL2567828992" bertipe "Normal" dengan 1 alamat pick up dan 1 alamat drop off
    When user mengisi field "No. Resi" dengan "LKL2567828992"
    And user menekan tombol keyboard "Enter" pada field "No. Resi"
    Then sistem menampilkan "tracking-result"

  @edge @priority-low @V-01 @screen-public-tracking @OMS022-EDG-015
  Scenario: Tombol reset mengosongkan input dan tidak menyisakan hasil pencarian sebelumnya
    Given data pengiriman resi "LKL2567828992" bertipe "Normal" dengan 1 alamat pick up dan 1 alamat drop off
    When user mengisi field "No. Resi" dengan "LKL2567828992"
    And user mengklik tombol "Lacak"
    And user mengklik tombol "Reset"
    Then field "No. Resi" tetap bernilai ""
    And sistem tidak menampilkan "tracking-result"

  @edge @priority-medium @REQ-003 @ASM-025 @screen-public-tracking @OMS022-EDG-016
  Scenario: Klik ganda cepat pada tombol Lacak tidak menghasilkan hasil ganda
    Given data pengiriman resi "LKL2567828992" bertipe "Normal" dengan 1 alamat pick up dan 1 alamat drop off
    And armada telah melaporkan seluruh event "Selesai Muat"
    When user mengisi field "No. Resi" dengan "LKL2567828992"
    And user mengklik tombol "Lacak" sebanyak 2 kali secara cepat
    Then jumlah container "tracking-result" adalah 1
    And jumlah entri riwayat bertipe "muat" adalah 1
    And jumlah entri riwayat bertipe "sintetis" adalah 1

  @edge @priority-low @ALT-09 @ASM-012 @screen-public-tracking @OMS022-EDG-017
  Scenario: Order berstatus Dibatalkan tetap dapat dilacak tanpa error (non-blocking)
    Given data pengiriman resi "LKL6612009988" bertipe "Normal" dengan 1 alamat pick up dan 1 alamat drop off
    And order pada resi "LKL6612009988" berstatus "Dibatalkan"
    When user mengisi field "No. Resi" dengan "LKL6612009988"
    And user mengklik tombol "Lacak"
    Then sistem tidak menampilkan "tracking-error"
    And sistem menampilkan salah satu dari "tracking-result" atau "tracking-not-found"

  @edge @priority-medium @REQ-026 @AC-026.3 @ASM-008 @screen-public-tracking @OMS022-EDG-018
  Scenario: Penanda waktu antar entri riwayat tidak pernah mundur secara kronologis
    Given data pengiriman resi "LKL5521349900" bertipe "Multipoint 2x2" dengan 2 alamat pick up dan 2 alamat drop off
    And armada telah melaporkan seluruh event "Selesai Muat"
    And armada telah melaporkan seluruh event "Selesai Bongkar"
    When user mengisi field "No. Resi" dengan "LKL5521349900"
    And user mengklik tombol "Lacak"
    Then penanda waktu seluruh entri riwayat terurut non-menurun mengikuti urutan render
    And entri riwayat bertipe "sintetis" memiliki "history-item-timestamp"

  @edge @priority-medium @REQ-023 @REQ-024 @V-07 @V-08 @screen-public-tracking @OMS022-EDG-019
  Scenario: Multi Pick Up 3 setelah seluruh muat tuntas dan belum ada bongkar — komposisi riwayat tepat
    Given data pengiriman resi "LKL8900765636" bertipe "Multi Pick Up 3" dengan 3 alamat pick up dan 1 alamat drop off
    And armada telah melaporkan seluruh event "Selesai Muat"
    When user mengisi field "No. Resi" dengan "LKL8900765636"
    And user mengklik tombol "Lacak"
    Then jumlah entri riwayat bertipe "muat" adalah 3
    And jumlah entri riwayat bertipe "sintetis" adalah 1
    And jumlah entri riwayat bertipe "bongkar" adalah 0
    And entri riwayat bertipe "sintetis" berada setelah entri terakhir bertipe "muat"

  @edge @priority-low @REQ-016 @AC-021.4 @screen-public-tracking @OMS022-EDG-020
  Scenario: Resi valid tanpa event tetap konsisten setelah reload berulang
    Given data pengiriman resi "LKL3300112244" bertipe "Normal" dengan 1 alamat pick up dan 1 alamat drop off
    And belum ada event yang dilaporkan armada
    When user mengisi field "No. Resi" dengan "LKL3300112244"
    And user mengklik tombol "Lacak"
    And user memuat ulang halaman lalu melacak resi yang sama
    Then sistem menampilkan "history-empty"
    And simpul stepper "Pick Up" berstate "pending"
    And sistem tidak menampilkan "tracking-error"

  @edge @priority-low @ASM-010 @AC-008.3 @screen-public-tracking @OMS022-EDG-021
  Scenario Outline: Label tahap tetap dikenali walau kapitalisasi bervariasi — <variasi>
    Given data pengiriman resi "LKL7920830903" bertipe "Multi Pick Up 2" dengan 2 alamat pick up dan 1 alamat drop off
    And armada telah melaporkan seluruh event "Selesai Muat"
    When user mengisi field "No. Resi" dengan "LKL7920830903"
    And user mengklik tombol "Lacak"
    Then simpul stepper "<variasi>" tersedia pada stepper

    Examples:
      | variasi     |
      | Pick Up     |
      | pick up     |
      | ON DELIVERY |
      | delivered   |

  @edge @priority-medium @REQ-020 @REQ-013 @REQ-014 @ASM-006 @screen-public-tracking @OMS022-EDG-022
  Scenario: Multipoint 3x3 — dua no-op dalam satu pengiriman (muat tengah dan bongkar tengah)
    Given data pengiriman resi "LKL7788990011" bertipe "Multipoint 3x3" dengan 3 alamat pick up dan 3 alamat drop off
    And armada telah melaporkan event kronologis sampai "Selesai Muat ke-2"
    When user mengisi field "No. Resi" dengan "LKL7788990011"
    And user mengklik tombol "Lacak"
    Then simpul stepper "Pick Up" berstate "reached"
    And simpul stepper "On Delivery" berstate "pending"
    When armada melaporkan event kronologis sampai "Selesai Bongkar ke-2"
    And user memuat ulang halaman lalu melacak resi yang sama
    Then simpul stepper "On Delivery" berstate "reached"
    And simpul stepper "Delivered" berstate "pending"
    And jumlah entri riwayat bertipe "muat" adalah 3
    And jumlah entri riwayat bertipe "bongkar" adalah 2
    And jumlah entri riwayat bertipe "sintetis" adalah 1

  @edge @priority-low @ASM-018 @ASM-027 @screen-public-tracking @OMS022-EDG-023
  Scenario: Navigasi browser back setelah pencarian tidak meninggalkan halaman dalam keadaan rusak
    Given data pengiriman resi "LKL2567828992" bertipe "Normal" dengan 1 alamat pick up dan 1 alamat drop off
    When user mengisi field "No. Resi" dengan "LKL2567828992"
    And user mengklik tombol "Lacak"
    And user menekan navigasi browser "back"
    Then sistem menampilkan "public-tracking-page"
    And sistem menampilkan field "No. Resi"
    And sistem tidak menampilkan "tracking-error"

  @edge @priority-medium @REQ-027 @AC-027.4 @screen-public-tracking @OMS022-EDG-024
  Scenario Outline: Tidak ada tahap stepper yang tercapai tanpa dukungan entri riwayat — <kondisi>
    Given data pengiriman resi "<resi>" bertipe "<tipe>" dengan <pickup> alamat pick up dan <drop> alamat drop off
    And armada telah melaporkan event kronologis sampai "<kondisi>"
    When user mengisi field "No. Resi" dengan "<resi>"
    And user mengklik tombol "Lacak"
    Then simpul stepper "Pick Up" berstate "<pickUp>"
    And simpul stepper "On Delivery" berstate "<onDelivery>"
    And simpul stepper "Delivered" berstate "<delivered>"
    And state stepper konsisten dengan komposisi entri riwayat

    Examples:
      | resi          | tipe            | pickup | drop | kondisi              | pickUp  | onDelivery | delivered |
      | LKL8900765636 | Multi Pick Up 3 | 3      | 1    | belum ada event      | pending | pending    | pending   |
      | LKL8900765636 | Multi Pick Up 3 | 3      | 1    | Selesai Muat ke-2    | reached | pending    | pending   |
      | LKL4410238877 | Multi Drop 2    | 1      | 2    | Selesai Muat ke-1    | reached | reached    | pending   |
      | LKL4410238877 | Multi Drop 2    | 1      | 2    | Selesai Bongkar ke-1 | reached | reached    | pending   |
      | LKL5521349900 | Multipoint 2x2  | 2      | 2    | Selesai Bongkar ke-2 | reached | reached    | reached   |

  @edge @priority-low @REQ-026 @ASM-029 @screen-public-tracking @OMS022-EDG-025
  Scenario: Entri riwayat tanpa data lokasi tetap dirender lengkap dengan keterangan dan waktu
    Given data pengiriman resi "LKL9911223344" bertipe "Normal" dengan 1 alamat pick up dan 1 alamat drop off
    And data lokasi pada event tidak tersedia
    And armada telah melaporkan seluruh event "Selesai Muat"
    When user mengisi field "No. Resi" dengan "LKL9911223344"
    And user mengklik tombol "Lacak"
    Then setiap entri riwayat memiliki "history-item-text"
    And setiap entri riwayat memiliki "history-item-timestamp"
    And sistem tidak menampilkan "tracking-error"

  @edge @priority-medium @REQ-012 @AC-012.3 @screen-public-tracking @OMS022-EDG-026
  Scenario: Tidak ada state antara Pick Up tercapai tanpa On Delivery pada pengiriman beralamat pick up tunggal
    Given data pengiriman resi "LKL4410238877" bertipe "Multi Drop 2" dengan 1 alamat pick up dan 2 alamat drop off
    And belum ada event yang dilaporkan armada
    When user mengisi field "No. Resi" dengan "LKL4410238877"
    And user mengklik tombol "Lacak"
    Then simpul stepper "Pick Up" berstate "pending"
    When armada melaporkan event "Selesai Muat" ke-1
    And user memuat ulang halaman lalu melacak resi yang sama
    Then simpul stepper "Pick Up" berstate "reached"
    And simpul stepper "On Delivery" berstate "reached"
    And simpul stepper "Delivered" berstate "pending"

  @edge @priority-low @V-01 @screen-public-tracking @OMS022-EDG-027
  Scenario: Mengisi ulang field setelah pesan validasi menghilangkan error dan pencarian berhasil
    Given data pengiriman resi "LKL2567828992" bertipe "Normal" dengan 1 alamat pick up dan 1 alamat drop off
    When user mengosongkan field "No. Resi"
    And user mengklik tombol "Lacak"
    Then sistem menampilkan "resi-input-error"
    When user mengisi field "No. Resi" dengan "LKL2567828992"
    And user mengklik tombol "Lacak"
    Then sistem tidak menampilkan "resi-input-error"
    And sistem menampilkan "tracking-result"

  # ===================================================================
  # KATEGORI: STRESS
  # ===================================================================

  @stress @priority-medium @V-03 @V-04 @screen-public-tracking @OMS022-STR-001
  Scenario Outline: Input No. Resi bervolume sangat besar (<panjang> karakter) tidak membuat halaman menggantung
    When user mengisi field "No. Resi" dengan string berulang "LKL2567828992" sepanjang <panjang> karakter
    And user mengklik tombol "Lacak"
    Then sistem merespons dalam batas waktu 15 detik
    And sistem menampilkan salah satu dari "resi-input-error" atau "tracking-not-found"
    And sistem tidak menampilkan "tracking-error"
    And halaman tetap responsif

    Examples:
      | panjang |
      | 1000    |
      | 5000    |
      | 20000   |

  @stress @priority-medium @V-03 @screen-public-tracking @OMS022-STR-002
  Scenario: Payload karakter spesial sepanjang 2000 karakter tidak menyebabkan kegagalan server
    When user mengisi field "No. Resi" dengan string berulang "<>&'\"%;--/*" sepanjang 2000 karakter
    And user mengklik tombol "Lacak"
    Then sistem tidak menampilkan teks "error 500"
    And sistem tidak menampilkan "tracking-error"
    And tidak ada dialog javascript yang terpicu

  @stress @priority-medium @REQ-003 @screen-public-tracking @OMS022-STR-003
  Scenario: Lima puluh pencarian berturut-turut tetap menghasilkan tampilan yang stabil
    Given data pengiriman resi "LKL2567828992" bertipe "Normal" dengan 1 alamat pick up dan 1 alamat drop off
    And armada telah melaporkan seluruh event "Selesai Muat"
    When user melakukan pencarian resi "LKL2567828992" sebanyak 50 kali berturut-turut
    Then setiap pencarian menampilkan "tracking-result"
    And jumlah entri riwayat bertipe "muat" adalah 1
    And jumlah entri riwayat bertipe "sintetis" adalah 1
    And sistem tidak menampilkan "tracking-error"

  @stress @priority-high @REQ-022 @V-07 @V-08 @screen-public-tracking @OMS022-STR-004
  Scenario: Multi pick up bervolume besar (20 alamat) merender seluruh entri muat dengan satu entri sintetis
    Given data pengiriman resi "LKL2000000020" bertipe "Multi Pick Up 20" dengan 20 alamat pick up dan 1 alamat drop off
    And armada telah melaporkan seluruh event "Selesai Muat"
    When user mengisi field "No. Resi" dengan "LKL2000000020"
    And user mengklik tombol "Lacak"
    Then jumlah entri riwayat bertipe "muat" adalah 20
    And jumlah entri riwayat bertipe "sintetis" adalah 1
    And simpul stepper "Pick Up" berstate "reached"
    And simpul stepper "On Delivery" berstate "reached"
    And simpul stepper "Delivered" berstate "pending"
    And entri riwayat bertipe "sintetis" berada setelah entri terakhir bertipe "muat"

  @stress @priority-high @REQ-014 @REQ-025 @V-09 @screen-public-tracking @OMS022-STR-005
  Scenario: Multi drop bervolume besar (20 alamat) — 19 bongkar pertama no-op, bongkar ke-20 memicu Delivered
    Given data pengiriman resi "LKL2000000021" bertipe "Multi Drop 20" dengan 1 alamat pick up dan 20 alamat drop off
    And armada telah melaporkan event kronologis sampai "Selesai Bongkar ke-19"
    When user mengisi field "No. Resi" dengan "LKL2000000021"
    And user mengklik tombol "Lacak"
    Then jumlah entri riwayat bertipe "bongkar" adalah 19
    And simpul stepper "Delivered" berstate "pending"
    When armada melaporkan event "Selesai Bongkar" ke-20
    And user memuat ulang halaman lalu melacak resi yang sama
    Then jumlah entri riwayat bertipe "bongkar" adalah 20
    And simpul stepper "Delivered" berstate "reached"
    And jumlah entri riwayat bertipe "sintetis" adalah 1

  @stress @priority-medium @REQ-020 @REQ-021 @screen-public-tracking @OMS022-STR-006
  Scenario: Multipoint bervolume besar (10x10) merender 21 entri riwayat dengan stepper penuh
    Given data pengiriman resi "LKL2000000022" bertipe "Multipoint 10x10" dengan 10 alamat pick up dan 10 alamat drop off
    And armada telah melaporkan seluruh event "Selesai Muat"
    And armada telah melaporkan seluruh event "Selesai Bongkar"
    When user mengisi field "No. Resi" dengan "LKL2000000022"
    And user mengklik tombol "Lacak"
    Then jumlah entri riwayat bertipe "muat" adalah 10
    And jumlah entri riwayat bertipe "sintetis" adalah 1
    And jumlah entri riwayat bertipe "bongkar" adalah 10
    And simpul stepper "Delivered" berstate "reached"
    And seluruh entri bertipe "muat" berada sebelum entri pertama bertipe "bongkar"

  @stress @priority-medium @REQ-021 @screen-public-tracking @OMS022-STR-007
  Scenario: Riwayat sangat panjang (100 entri) tetap dapat digulir hingga entri terakhir
    Given data pengiriman resi "LKL2000000023" bertipe "Multipoint 50x50" dengan 50 alamat pick up dan 50 alamat drop off
    And armada telah melaporkan seluruh event "Selesai Muat"
    And armada telah melaporkan seluruh event "Selesai Bongkar"
    When user mengisi field "No. Resi" dengan "LKL2000000023"
    And user mengklik tombol "Lacak"
    And user menggulir "history-list" hingga entri terakhir
    Then jumlah entri riwayat bertipe "muat" adalah 50
    And jumlah entri riwayat bertipe "bongkar" adalah 50
    And jumlah entri riwayat bertipe "sintetis" adalah 1
    And sistem merespons dalam batas waktu 15 detik

  @stress @priority-medium @REQ-003 @V-13 @screen-public-tracking @OMS022-STR-008
  Scenario: Sepuluh sesi paralel melacak resi yang sama menampilkan progres identik
    Given data pengiriman resi "LKL7920830903" bertipe "Multi Pick Up 2" dengan 2 alamat pick up dan 1 alamat drop off
    And armada telah melaporkan seluruh event "Selesai Muat"
    When 10 sesi anonim paralel melacak resi "LKL7920830903"
    Then seluruh sesi menampilkan simpul stepper "On Delivery" berstate "reached"
    And seluruh sesi menampilkan jumlah entri riwayat bertipe "muat" adalah 2
    And seluruh sesi menampilkan jumlah entri riwayat bertipe "sintetis" adalah 1
    And tidak ada sesi yang menampilkan "tracking-error"

  @stress @priority-high @V-13 @AC-004.3 @screen-public-tracking @OMS022-STR-009
  Scenario: Sesi paralel dengan resi berbeda tidak saling membocorkan data
    Given data pengiriman resi "LKL2567828992" bertipe "Normal" dengan 1 alamat pick up dan 1 alamat drop off
    And data pengiriman resi "LKL8900765636" bertipe "Multi Pick Up 3" dengan 3 alamat pick up dan 1 alamat drop off
    And armada telah melaporkan seluruh event "Selesai Muat"
    When 2 sesi anonim paralel melacak resi "LKL2567828992" dan "LKL8900765636" secara bersamaan
    Then sesi pertama menampilkan jumlah entri riwayat bertipe "muat" adalah 1
    And sesi kedua menampilkan jumlah entri riwayat bertipe "muat" adalah 3
    And sesi pertama tidak menampilkan teks "LKL8900765636"
    And sesi kedua tidak menampilkan teks "LKL2567828992"

  @stress @priority-medium @ASM-025 @screen-public-tracking @OMS022-STR-010
  Scenario: Klik tombol Lacak sepuluh kali beruntun tidak menggandakan hasil maupun entri riwayat
    Given data pengiriman resi "LKL8900765636" bertipe "Multi Pick Up 3" dengan 3 alamat pick up dan 1 alamat drop off
    And armada telah melaporkan seluruh event "Selesai Muat"
    When user mengisi field "No. Resi" dengan "LKL8900765636"
    And user mengklik tombol "Lacak" sebanyak 10 kali secara cepat
    Then jumlah container "tracking-result" adalah 1
    And jumlah entri riwayat bertipe "muat" adalah 3
    And jumlah entri riwayat bertipe "sintetis" adalah 1
    And sistem tidak menampilkan "tracking-error"

  @stress @priority-medium @REQ-015 @AC-015.4 @screen-public-tracking @OMS022-STR-011
  Scenario: Reload halaman dua puluh kali berturut-turut mempertahankan state stepper
    Given data pengiriman resi "LKL4410238877" bertipe "Multi Drop 2" dengan 1 alamat pick up dan 2 alamat drop off
    And armada telah melaporkan event kronologis sampai "Selesai Bongkar ke-1"
    When user mengisi field "No. Resi" dengan "LKL4410238877"
    And user mengklik tombol "Lacak"
    And user memuat ulang halaman lalu melacak resi yang sama sebanyak 20 kali
    Then simpul stepper "On Delivery" berstate "reached"
    And simpul stepper "Delivered" berstate "pending"
    And jumlah entri riwayat bertipe "bongkar" adalah 1

  @stress @priority-medium @ASM-022 @ASM-025 @screen-public-tracking @OMS022-STR-012
  Scenario: Respons layanan sangat lambat menampilkan indikator loading lalu state error dengan tombol coba lagi
    Given layanan tracking dibatasi kecepatannya sehingga melebihi batas waktu untuk resi "LKL2567828992"
    When user mengisi field "No. Resi" dengan "LKL2567828992"
    And user mengklik tombol "Lacak"
    Then sistem menampilkan "tracking-loading"
    And sistem menampilkan "tracking-error"
    And sistem menampilkan tombol "Coba Lagi"
    And sistem tidak menampilkan "tracking-not-found"

  @stress @priority-medium @ASM-022 @screen-public-tracking @OMS022-STR-013
  Scenario: Jaringan terputus saat submit menampilkan error yang dapat dipulihkan tanpa halaman kosong
    Given data pengiriman resi "LKL2567828992" bertipe "Normal" dengan 1 alamat pick up dan 1 alamat drop off
    And koneksi jaringan diputus
    When user mengisi field "No. Resi" dengan "LKL2567828992"
    And user mengklik tombol "Lacak"
    Then sistem menampilkan "tracking-error"
    And sistem menampilkan "public-tracking-page"
    When koneksi jaringan dipulihkan
    And user mengklik tombol "Coba Lagi"
    Then sistem menampilkan "tracking-result"

  @stress @priority-medium @REQ-003 @screen-public-tracking @OMS022-STR-014
  Scenario: Pergantian resi secara cepat berturut-turut menampilkan hasil sesuai resi terakhir
    Given data pengiriman resi "LKL2567828992" bertipe "Normal" dengan 1 alamat pick up dan 1 alamat drop off
    And data pengiriman resi "LKL8900765636" bertipe "Multi Pick Up 3" dengan 3 alamat pick up dan 1 alamat drop off
    And data pengiriman resi "LKL4410238877" bertipe "Multi Drop 2" dengan 1 alamat pick up dan 2 alamat drop off
    And armada telah melaporkan seluruh event "Selesai Muat"
    When user melacak resi "LKL2567828992", "LKL8900765636", dan "LKL4410238877" berturut-turut tanpa menunggu hasil
    Then sistem menampilkan teks "LKL4410238877"
    And jumlah entri riwayat bertipe "muat" adalah 1
    And sistem tidak menampilkan teks "LKL8900765636"

  @stress @priority-low @REQ-006 @V-07 @screen-public-tracking @OMS022-STR-015
  Scenario: Burst 100 event muat pada satu pengiriman tetap menghasilkan tepat satu entri sintetis
    Given data pengiriman resi "LKL2000000024" bertipe "Multi Pick Up 100" dengan 100 alamat pick up dan 1 alamat drop off
    And armada melaporkan 100 event "Selesai Muat" secara beruntun dalam waktu singkat
    When user mengisi field "No. Resi" dengan "LKL2000000024"
    And user mengklik tombol "Lacak"
    Then jumlah entri riwayat bertipe "muat" adalah 100
    And jumlah entri riwayat bertipe "sintetis" adalah 1
    And simpul stepper "On Delivery" berstate "reached"
    And simpul stepper "Delivered" berstate "pending"

  @stress @priority-low @REQ-001 @AC-001.3 @screen-public-tracking @OMS022-STR-016
  Scenario Outline: Halaman hasil tetap utuh pada viewport <viewport> dengan riwayat panjang
    Given data pengiriman resi "LKL2000000022" bertipe "Multipoint 10x10" dengan 10 alamat pick up dan 10 alamat drop off
    And armada telah melaporkan seluruh event "Selesai Muat"
    And armada telah melaporkan seluruh event "Selesai Bongkar"
    And viewport diatur ke "<viewport>"
    When user mengisi field "No. Resi" dengan "LKL2000000022"
    And user mengklik tombol "Lacak"
    Then sistem menampilkan "tracking-stepper"
    And sistem menampilkan "history-list"
    And jumlah entri riwayat bertipe "sintetis" adalah 1
    And sistem tidak menampilkan "tracking-error"

    Examples:
      | viewport   |
      | 360x640    |
      | 768x1024   |
      | 1440x900   |
