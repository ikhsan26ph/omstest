# =====================================================================
# Modul   : oms000-jenis-produk
# Sumber  : output/oms000-jenis-produk/oms000-jenis-produk.analysis.md
# Spec    : inputs/oms000-jenis-produk/spec.txt
# Extras  : inputs/oms000-jenis-produk/extras/oms000-jenis-produk.xlsx (5 sheet)
# Desain  : TIDAK ADA (ASM-01, ASM-21) — SELURUH selector adalah USULAN
# Tahap   : 3/4 — scenario-generator
# ---------------------------------------------------------------------
# ATURAN ASSERTION WAJIB (turunan Assumptions Log — jangan dilanggar):
#  - ASM-03  Admin key & clientId TIDAK PERNAH di-hard-code. Pakai
#            <X-Admin-Key> / ${ADMIN_KEY} dan <clientId> / ${CLIENT_ID}
#            yang di-inject dari environment/secret store.
#  - ASM-38  Entitlement bersifat GLOBAL per clientId. Suite modul ini
#            WAJIB dijalankan SERIAL (workers: 1 / fullyParallel: false)
#            atau memakai clientId terpisah per worker. Setiap file
#            wajib mengembalikan entitlement ke nilai semula (teardown).
#  - ASM-29  "Masuk / tidak masuk apps sopir" TIDAK diverifikasi lewat UI
#            native. Verifikasi WAJIB lewat API daftar tugas sopir
#            (GET .../driver/{driverId}/assignments -> $.data[]), log/mock
#            push notification, atau efek tidak langsung pada timeline web.
#            Bila API tersebut tidak tersedia, skenario R2 ditandai MANUAL.
#  - ASM-30  Seluruh route deep-link (/master-pelabuhan, /simulasi-muatan,
#            dst.) adalah USULAN kebab-case; WAJIB di-parameterisasi lewat
#            fixture route sebelum eksekusi — kegagalan page.goto() bukan
#            defect produk.
#  - ASM-37  Setelah PATCH entitlement, SELALU page.reload() (dan pada
#            skenario ketat logout-login) sebelum meng-assert menu.
#            Skenario "tanpa refresh" = menu lama BOLEH tetap tampil.
#  - ASM-31  Menu/tab/opsi non-entitle DIHAPUS dari DOM. Assertion
#            ketiadaan memakai toHaveCount(0), BUKAN not.toBeVisible().
#            Guard deep-link = halaman 403 ATAU redirect (assertion OR),
#            dengan satu assertion keras: konten fitur tidak boleh muncul.
#  - ASM-33  Badge/hint kanal penugasan (assignment-row-channel,
#            assignment-channel-hint) bersifat OPSIONAL & NON-BLOCKING.
#            Assertion utama R2 tetap di daftar tugas sopir (UI-T05).
#  - ASM-27  JSON path respons ditulis berlapis: $.products ?? $.data.products
#  - ASM-23  Selector primer = getByRole + accessible name (regex CI);
#            testid nav memakai dua kandidat: nav-item-<slug> ATAU nav-<slug>
#  - ASM-25  Grup MASTER OPERASIONAL mungkin collapsible — buka grup dulu
#            sebelum meng-assert anaknya.
#  - Angka absolut hanya boleh di-assert pada REQ-050 (6 item Vendor),
#    REQ-067 (8 item Pengaturan Sistem), REQ-068 (2 item).
# =====================================================================

Feature: OMS-000 — Jenis Produk & Add-On (entitlement TMS/OMS + addOns)

  Sebagai Admin platform Prahu-Hub
  Saya ingin mengatur products (TMS/OMS) dan addOns (AUTO_STUFFING, SERVICE_*)
  pada level client melalui API PATCH .../entitlement
  Agar menu Shipper, menu Vendor, isi Pengaturan Sistem, susunan menu TMS LKL,
  jenis pengiriman yang aktif, dan terutama JALUR PENUGASAN TRACKING
  (sopir masuk aplikasi mobile pada TMS vs tidak masuk pada OMS)
  berperilaku tepat sesuai hak pakai client tersebut.

  Background:
    Given admin memiliki <X-Admin-Key> valid dari environment
    And client uji "<clientId>" tersedia di environment staging

  # ===================================================================
  # === KATEGORI: POSITIVE (bagian A) — R1 Kontrak API & R2 Penugasan ===
  # ===================================================================

  @positive @priority-high @REQ-001 @REQ-002 @REQ-003 @REQ-008 @AC-001.1 @AC-002.1 @AC-003.1 @AC-008.1 @V-02 @V-03 @screen-api-entitlement @OMS000-POS-001
  Scenario: PATCH entitlement dengan products dan addOns lengkap mengembalikan 200
    Given admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    And admin menyertakan header "X-Admin-Key" dari environment
    And admin menyertakan header "Content-Type" dengan "application/json"
    When admin mengirim body dengan products ["TMS","OMS"] dan addOns ["AUTO_STUFFING","SERVICE_FTL","SERVICE_FCL","SERVICE_LTL","SERVICE_LCL","SERVICE_AIR_FREIGHT"]
    Then respons berstatus 200
    And respons field "$.products" berisi ["TMS","OMS"]
    And respons field "$.addOns" berisi ["AUTO_STUFFING","SERVICE_FTL","SERVICE_FCL","SERVICE_LTL","SERVICE_LCL","SERVICE_AIR_FREIGHT"]

  @positive @priority-high @REQ-004 @AC-004.1 @AC-004.2 @V-05 @screen-api-entitlement @OMS000-POS-002
  Scenario: Hanya field products dan addOns yang berubah, atribut client lain tetap
    Given admin mencatat atribut client "nama, status, kontak" sebelum request
    And admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    When admin mengirim body dengan products ["TMS"] dan addOns ["SERVICE_FTL"]
    Then respons berstatus 200
    And respons field "$.products" berisi ["TMS"]
    And respons field "$.addOns" berisi ["SERVICE_FTL"]
    And sistem menampilkan atribut client "nama, status, kontak" tidak berubah

  @positive @priority-high @REQ-005 @REQ-017 @AC-005.1 @V-07 @V-08 @screen-api-entitlement @OMS000-POS-003
  Scenario Outline: Kombinasi products yang sah diterima sistem
    Given admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    When admin mengirim body dengan products <products> dan addOns ["SERVICE_FTL"]
    Then respons berstatus 200
    And respons field "$.products" berisi <products>

    Examples:
      | products        | state produk |
      | ["TMS"]         | TMS-only     |
      | ["OMS"]         | OMS-only     |
      | ["TMS","OMS"]   | gabungan     |

  @positive @priority-high @REQ-006 @AC-006.1 @AC-006.3 @V-12 @V-13 @screen-api-entitlement @OMS000-POS-004
  Scenario Outline: Subset addOns yang sah diterima sistem
    Given admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    When admin mengirim body dengan products ["TMS","OMS"] dan addOns <addOns>
    Then respons berstatus 200
    And respons field "$.addOns" berisi <addOns>

    Examples:
      | addOns                                          | moda yang diaktifkan |
      | ["SERVICE_FTL"]                                 | darat                |
      | ["SERVICE_LTL"]                                 | darat (Less)         |
      | ["SERVICE_FCL"]                                 | laut                 |
      | ["SERVICE_LCL"]                                 | laut (Less)          |
      | ["SERVICE_AIR_FREIGHT"]                         | udara                |
      | ["AUTO_STUFFING","SERVICE_FTL","SERVICE_FCL"]   | darat+laut+stuffing  |

  @positive @priority-high @REQ-007 @AC-007.1 @V-18 @screen-api-entitlement @OMS000-POS-005
  Scenario: Array addOns bersifat replace penuh, bukan append
    Given entitlement client diset products ["TMS","OMS"] addOns ["AUTO_STUFFING","SERVICE_FTL","SERVICE_FCL","SERVICE_LTL","SERVICE_LCL","SERVICE_AIR_FREIGHT"]
    And admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    When admin mengirim body dengan addOns ["SERVICE_FTL"]
    Then respons berstatus 200
    And respons field "$.addOns" berisi ["SERVICE_FTL"]
    And respons field "$.addOns" memiliki tepat 1 elemen

  @positive @priority-high @REQ-007 @AC-007.2 @V-19 @ALT-10 @screen-api-entitlement @OMS000-POS-006
  Scenario: Mengirim hanya field addOns tidak mengubah products
    Given entitlement client diset products ["TMS","OMS"] addOns ["SERVICE_FTL"]
    And admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    When admin mengirim body dengan addOns ["SERVICE_FCL"]
    Then respons berstatus 200
    And respons field "$.addOns" berisi ["SERVICE_FCL"]
    And respons field "$.products" berisi ["TMS","OMS"]

  @positive @priority-medium @REQ-007 @AC-007.3 @V-19 @screen-api-entitlement @OMS000-POS-007
  Scenario: Mengirim hanya field products tidak mengubah addOns
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FTL","SERVICE_LTL"]
    And admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    When admin mengirim body dengan products ["OMS"]
    Then respons berstatus 200
    And respons field "$.products" berisi ["OMS"]
    And respons field "$.addOns" berisi ["SERVICE_FTL","SERVICE_LTL"]

  @positive @priority-high @REQ-008 @AC-008.2 @AC-008.3 @screen-api-entitlement @OMS000-POS-008
  Scenario: Pembacaan ulang entitlement identik dengan respons PATCH
    Given admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    When admin mengirim body dengan products ["OMS"] dan addOns ["AUTO_STUFFING","SERVICE_LCL"]
    Then respons berstatus 200
    And admin membaca ulang entitlement client "<clientId>"
    And hasil pembacaan ulang field "$.products" berisi ["OMS"]
    And hasil pembacaan ulang field "$.addOns" berisi ["AUTO_STUFFING","SERVICE_LCL"]

  @positive @priority-medium @REQ-015 @AC-015.1 @AC-015.2 @AC-015.3 @V-10 @V-15 @ALT-09 @screen-api-entitlement @OMS000-POS-009
  Scenario: Nilai duplikat pada products dan addOns dideduplikasi saat disimpan
    Given admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    When admin mengirim body dengan products ["TMS","TMS"] dan addOns ["SERVICE_FTL","SERVICE_FTL","SERVICE_FCL"]
    Then respons berstatus 200
    And respons field "$.products" berisi ["TMS"]
    And respons field "$.addOns" berisi ["SERVICE_FTL","SERVICE_FCL"]
    And respons field "$.products" memiliki tepat 1 elemen

  @positive @priority-high @REQ-016 @AC-016.1 @AC-016.2 @V-13 @ALT-08 @screen-api-entitlement @OMS000-POS-010
  Scenario: addOns array kosong diterima sebagai client tanpa add-on
    Given admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    When admin mengirim body dengan products ["TMS"] dan addOns []
    Then respons berstatus 200
    And respons field "$.addOns" berisi []
    And admin membaca ulang entitlement client "<clientId>"
    And hasil pembacaan ulang field "$.addOns" berisi []

  @positive @priority-medium @REQ-018 @AC-018.1 @AC-018.2 @V-05 @ALT-11 @screen-api-entitlement @OMS000-POS-011
  Scenario: Field asing pada body diabaikan tanpa efek samping
    Given admin mencatat atribut client "clientName" sebelum request
    And admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    When admin mengirim body dengan products ["TMS"] dan field asing {"clientName":"Client Palsu QA","features":["X"]}
    Then respons berstatus 200
    And respons field "$.products" berisi ["TMS"]
    And sistem menampilkan atribut client "clientName" tidak berubah

  @positive @priority-medium @REQ-019 @AC-019.1 @AC-019.2 @V-22 @screen-api-entitlement @OMS000-POS-012
  Scenario: Payload identik dikirim dua kali bersifat idempoten
    Given admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    When admin mengirim body dengan products ["TMS","OMS"] dan addOns ["SERVICE_FTL","SERVICE_FCL"]
    Then respons berstatus 200
    And admin mengirim ulang body yang identik
    And respons berstatus 200
    And respons field "$.products" berisi ["TMS","OMS"]
    And respons field "$.addOns" berisi ["SERVICE_FTL","SERVICE_FCL"]

  @positive @priority-high @REQ-002 @AC-002.2 @V-02 @screen-api-entitlement @OMS000-POS-013
  Scenario: Nilai admin key tidak pernah bocor pada respons sukses
    Given admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    When admin mengirim body dengan products ["TMS"] dan addOns ["SERVICE_FTL"]
    Then respons berstatus 200
    And sistem tidak menampilkan nilai "<X-Admin-Key>" pada body respons
    And sistem tidak menampilkan nilai "<X-Admin-Key>" pada header respons

  @positive @priority-high @REQ-009 @REQ-010 @REQ-011 @REQ-012 @REQ-013 @REQ-014 @REQ-017 @screen-api-entitlement @OMS000-POS-014
  Scenario: Kontrak lengkap terpenuhi (key valid, clientId UUID terdaftar, enum UPPERCASE, minimal satu produk) diproses 200
    Given admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    And admin menyertakan header "X-Admin-Key" dari environment
    When admin mengirim body dengan products ["TMS"] dan addOns ["SERVICE_FTL","SERVICE_LTL"]
    Then respons berstatus 200
    And respons field "$.products" berisi ["TMS"]
    And sistem tidak menampilkan "$.errors"

  @positive @priority-low @REQ-103 @AC-103.1 @AC-103.2 @screen-api-entitlement @OMS000-POS-015
  Scenario: Perubahan entitlement yang sukses tercatat pada audit trail
    Given admin mencatat jumlah entri audit entitlement client "<clientId>"
    And admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    When admin mengirim body dengan products ["OMS"] dan addOns ["AUTO_STUFFING"]
    Then respons berstatus 200
    And sistem menampilkan 1 entri audit baru untuk client "<clientId>"
    And entri audit memuat "waktu, aktor, nilai sebelum, nilai sesudah"

  @positive @priority-high @REQ-020 @REQ-037 @AC-020.1 @AC-020.2 @AC-037.1 @screen-sidebar-shipper @screen-penugasan-tracking @OMS000-POS-016
  Scenario Outline: Menu Penugasan Tracking tampil pada seluruh state produk sisi Shipper
    Given entitlement client diset products <products> addOns ["SERVICE_FTL"]
    And shipper login ulang
    And user berada di halaman "Sidebar Shipper"
    When user mengklik menu "Penugasan Tracking"
    Then sistem menampilkan "nav-item-penugasan-tracking"
    And sistem menampilkan "assignment-page"
    And user diarahkan ke halaman "Penugasan Tracking"

    Examples:
      | products        | state produk |
      | ["TMS"]         | TMS-only     |
      | ["OMS"]         | OMS-only     |
      | ["TMS","OMS"]   | gabungan     |

  @positive @priority-high @REQ-020 @REQ-052 @AC-052.1 @screen-sidebar-vendor @screen-penugasan-tracking @OMS000-POS-017
  Scenario Outline: Menu Penugasan Tracking tampil pada sisi Vendor untuk TMS maupun OMS
    Given entitlement client diset products <products> addOns ["SERVICE_FTL"]
    And vendor login ulang
    And user berada di halaman "Sidebar Vendor"
    When user mengklik menu "Penugasan Tracking"
    Then sistem menampilkan "sidebar-vendor"
    And sistem menampilkan "assignment-page"
    And user diarahkan ke halaman "Penugasan Tracking"

    Examples:
      | products  | state produk |
      | ["TMS"]   | TMS-only     |
      | ["OMS"]   | OMS-only     |

  @positive @priority-high @REQ-021 @AC-021.1 @AC-021.2 @screen-penugasan-tracking @OMS000-POS-018
  Scenario Outline: Form penugasan menyediakan opsi Sopir dan Pengurus pada seluruh state produk
    Given entitlement client diset products <products> addOns ["SERVICE_FTL"]
    And shipper login ulang
    And user berada di halaman "Penugasan Tracking"
    When user mengklik tombol "Tugaskan"
    Then sistem menampilkan "assignment-form"
    And sistem menampilkan "assignment-assignee-type-sopir"
    And sistem menampilkan "assignment-assignee-type-pengurus"
    And sistem tidak menampilkan opsi "Sopir" dalam keadaan disabled

    Examples:
      | products        | state produk |
      | ["TMS"]         | TMS-only     |
      | ["OMS"]         | OMS-only     |
      | ["TMS","OMS"]   | gabungan     |

  @positive @priority-high @REQ-022 @AC-022.1 @AC-022.2 @UF-2 @screen-penugasan-tracking @screen-driver-app @OMS000-POS-019
  Scenario: TMS — penugasan ke Sopir diteruskan ke aplikasi mobile sopir
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FTL"]
    And shipper login ulang
    And user berada di halaman "Penugasan Tracking"
    When user mengklik tombol "Tugaskan"
    And user memilih opsi "Sopir" pada field "Tipe Penerima Tugas"
    And user memilih "ORD769797FSH" pada field "Pilih Order"
    And user memilih "Sopir A" pada field "Pilih Sopir"
    And user mengklik tombol "Simpan"
    Then sistem menampilkan "toast-success"
    And daftar tugas sopir "Sopir A" memuat order "ORD769797FSH"
    And sopir "Sopir A" dapat membuka penugasan tersebut di aplikasi

  @positive @priority-high @REQ-022 @AC-022.3 @screen-driver-app @screen-penugasan-tracking @OMS000-POS-020
  Scenario: TMS — progres yang dilaporkan sopir dari apps tercermin pada tracking web
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FTL"]
    And penugasan order "ORD769797FSH" telah diberikan kepada "Sopir A"
    And daftar tugas sopir "Sopir A" memuat order "ORD769797FSH"
    When sopir "Sopir A" melaporkan progres "Selesai Muat" dari aplikasi
    And user berada di halaman "Penugasan Tracking"
    Then sistem menampilkan "tracking-timeline"
    And sistem menampilkan teks "Selesai Muat"

  @positive @priority-high @REQ-023 @AC-023.1 @AC-023.2 @ALT-16 @UF-3 @screen-penugasan-tracking @screen-driver-app @OMS000-POS-021
  Scenario: TMS — penugasan ke Pengurus tidak dikirim ke apps dan tracking diinput dari web
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FTL"]
    And shipper login ulang
    And user berada di halaman "Penugasan Tracking"
    When user mengklik tombol "Tugaskan"
    And user memilih opsi "Pengurus" pada field "Tipe Penerima Tugas"
    And user memilih "ORD769797FSH" pada field "Pilih Order"
    And user memilih "Pengurus B" pada field "Pilih Pengurus"
    And user mengklik tombol "Simpan"
    Then sistem menampilkan "toast-success"
    And daftar tugas sopir "Sopir A" tidak memuat order "ORD769797FSH"
    And sistem menampilkan "tracking-input-form"

  @positive @priority-high @REQ-024 @AC-024.1 @ALT-14 @screen-penugasan-tracking @OMS000-POS-022
  Scenario: OMS — penugasan ke Sopir tetap dapat disimpan dan tidak diblokir
    Given entitlement client diset products ["OMS"] addOns ["SERVICE_FTL"]
    And shipper login ulang
    And user berada di halaman "Penugasan Tracking"
    When user mengklik tombol "Tugaskan"
    And user memilih opsi "Sopir" pada field "Tipe Penerima Tugas"
    And user memilih "ORD769797FSH" pada field "Pilih Order"
    And user memilih "Sopir A" pada field "Pilih Sopir"
    And user mengklik tombol "Simpan"
    Then sistem menampilkan "toast-success"
    And sistem menampilkan baris penugasan order "ORD769797FSH"
    And sistem tidak menampilkan "assignment-form-error"

  @positive @priority-high @REQ-025 @AC-025.1 @AC-025.2 @ALT-17 @screen-penugasan-tracking @OMS000-POS-023
  Scenario: OMS — penugasan ke Pengurus tersimpan dan progres diinput dari web
    Given entitlement client diset products ["OMS"] addOns ["SERVICE_LCL"]
    And shipper login ulang
    And user berada di halaman "Penugasan Tracking"
    When user mengklik tombol "Tugaskan"
    And user memilih opsi "Pengurus" pada field "Tipe Penerima Tugas"
    And user memilih "ORD769797FSH" pada field "Pilih Order"
    And user memilih "Pengurus B" pada field "Pilih Pengurus"
    And user mengklik tombol "Simpan"
    Then sistem menampilkan "toast-success"
    And pengurus "Pengurus B" membuka "tracking-input-form" di web
    And user memilih "Selesai Muat" pada field "Status"
    And user mengklik tombol "Simpan"
    And sistem menampilkan "toast-success"

  @positive @priority-high @REQ-026 @AC-026.1 @AC-026.2 @ALT-15 @screen-penugasan-tracking @screen-driver-app @OMS000-POS-024
  Scenario: Gabungan TMS+OMS — penugasan ke Sopir mengikuti perilaku TMS dan masuk apps
    Given entitlement client diset products ["TMS","OMS"] addOns ["SERVICE_FTL","SERVICE_FCL"]
    And shipper login ulang
    And user berada di halaman "Penugasan Tracking"
    When user mengklik tombol "Tugaskan"
    And user memilih opsi "Sopir" pada field "Tipe Penerima Tugas"
    And user memilih "ORD769797FSH" pada field "Pilih Order"
    And user memilih "Sopir A" pada field "Pilih Sopir"
    And user mengklik tombol "Simpan"
    Then sistem menampilkan "toast-success"
    And daftar tugas sopir "Sopir A" memuat order "ORD769797FSH"
    And daftar tugas sopir "Sopir A" memuat order asal alur OMS "ORD888111OMS"

  @positive @priority-high @REQ-027 @AC-027.1 @screen-penugasan-tracking @OMS000-POS-025
  Scenario: OMS-only — progres pengiriman hanya bertambah melalui input web
    Given entitlement client diset products ["OMS"] addOns ["SERVICE_LTL"]
    And penugasan order "ORD769797FSH" telah diberikan kepada "Sopir A"
    And shipper login ulang
    And user berada di halaman "Penugasan Tracking"
    When user membuka "tracking-input-form" untuk order "ORD769797FSH"
    And user memilih "Selesai Muat" pada field "Status"
    And user mengisi field "Lokasi" dengan "Gudang Cakung"
    And user mengklik tombol "Simpan"
    Then sistem menampilkan "toast-success"
    And sistem menampilkan teks "Selesai Muat"
    And daftar tugas sopir "Sopir A" tidak memuat order "ORD769797FSH"

  @positive @priority-medium @REQ-028 @REQ-100 @AC-028.1 @AC-028.2 @ALT-25 @screen-penugasan-tracking @OMS000-POS-026
  Scenario: Penugasan lama tetap tercatat setelah products diubah dari TMS ke OMS
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FTL"]
    And penugasan order "ORD769797FSH" telah diberikan kepada "Sopir A"
    And entitlement client diset products ["OMS"] addOns ["SERVICE_FTL"]
    And shipper login ulang
    When user berada di halaman "Penugasan Tracking"
    Then sistem menampilkan baris penugasan order "ORD769797FSH"
    And sistem menampilkan "assignment-row-assignee" berisi "Sopir A"
    And sistem tidak menampilkan status "Dibatalkan" pada order "ORD769797FSH"

  @positive @priority-high @REQ-052 @AC-052.2 @screen-penugasan-tracking @screen-driver-app @screen-sidebar-vendor @OMS000-POS-027
  Scenario: Vendor pada client TMS menugaskan sopir dan penugasan masuk apps
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FTL"]
    And vendor login ulang
    And user berada di halaman "Penugasan Tracking"
    When user mengklik tombol "Tugaskan"
    And user memilih opsi "Sopir" pada field "Tipe Penerima Tugas"
    And user memilih "ORD553311VND" pada field "Pilih Order"
    And user memilih "Sopir V1" pada field "Pilih Sopir"
    And user mengklik tombol "Simpan"
    Then sistem menampilkan "toast-success"
    And daftar tugas sopir "Sopir V1" memuat order "ORD553311VND"

  @positive @priority-high @REQ-023 @REQ-025 @REQ-027 @AC-023.2 @AC-025.2 @UF-3 @screen-penugasan-tracking @OMS000-POS-028
  Scenario Outline: Pengurus dapat menginput progres tracking dari web pada TMS maupun OMS
    Given entitlement client diset products <products> addOns ["SERVICE_FTL"]
    And penugasan order "ORD769797FSH" telah diberikan kepada "Pengurus B"
    And user berada di halaman "Penugasan Tracking"
    When user membuka "tracking-input-form" untuk order "ORD769797FSH"
    And user memilih "<status>" pada field "Status"
    And user mengisi field "Lokasi" dengan "Pelabuhan Tanjung Priok"
    And user mengklik tombol "Simpan"
    Then sistem menampilkan "toast-success"
    And sistem menampilkan teks "<status>"
    And daftar tugas sopir "Sopir A" tidak memuat order "ORD769797FSH"

    Examples:
      | products  | status          |
      | ["TMS"]   | Selesai Muat    |
      | ["OMS"]   | Selesai Muat    |
      | ["OMS"]   | Selesai Bongkar |

  # =========================================================================
  # === KATEGORI: POSITIVE (bagian B) — R3 Menu Shipper, R4 Vendor, R5 PS ===
  # =========================================================================

  @positive @priority-high @REQ-029 @AC-029.1 @AC-029.3 @screen-sidebar-shipper @OMS000-POS-029
  Scenario: Sidebar Shipper menampilkan empat grup menu resmi
    Given entitlement client diset products ["TMS","OMS"] addOns ["AUTO_STUFFING","SERVICE_FTL","SERVICE_FCL"]
    And shipper login ulang
    When user berada di halaman "Sidebar Shipper"
    Then sistem menampilkan "sidebar-shipper"
    And sistem menampilkan "nav-group-dashboard"
    And sistem menampilkan "nav-group-menu-utama"
    And sistem menampilkan "nav-group-master-operasional"
    And sistem menampilkan "nav-group-menu-lainnya"

  @positive @priority-high @REQ-029 @REQ-030 @REQ-031 @REQ-032 @REQ-033 @REQ-034 @REQ-035 @REQ-036 @REQ-037 @REQ-038 @REQ-039 @REQ-040 @REQ-041 @REQ-042 @REQ-043 @REQ-044 @REQ-045 @REQ-046 @REQ-047 @REQ-048 @REQ-049 @screen-sidebar-shipper @OMS000-POS-030
  Scenario Outline: Menu Shipper "<menu>" tampil pada state <state>
    Given entitlement client diset products <products> addOns <addOns>
    And shipper login ulang
    And user membuka grup menu "MASTER OPERASIONAL"
    When user berada di halaman "Sidebar Shipper"
    Then sistem menampilkan "<testid>"
    And sistem menampilkan menu "<menu>" pada "sidebar-shipper"

    Examples: TMS-only + moda darat & laut
      | menu                            | testid                                  | products  | addOns                                        | state    |
      | Dashboard - Monitoring          | nav-item-dashboard-monitoring           | ["TMS"]   | ["SERVICE_FTL","SERVICE_FCL"]                 | TMS-only |
      | Dashboard - Tracking & Location | nav-item-dashboard-tracking-location    | ["TMS"]   | ["SERVICE_FTL","SERVICE_FCL"]                 | TMS-only |
      | Dashboard - Progress Pengiriman | nav-item-dashboard-progress-pengiriman  | ["TMS"]   | ["SERVICE_FTL","SERVICE_FCL"]                 | TMS-only |
      | Dashboard - Operasional         | nav-item-dashboard-operasional          | ["TMS"]   | ["SERVICE_FTL","SERVICE_FCL"]                 | TMS-only |
      | Order                           | nav-item-order                          | ["TMS"]   | ["SERVICE_FTL","SERVICE_FCL"]                 | TMS-only |
      | Penugasan Tracking              | nav-item-penugasan-tracking             | ["TMS"]   | ["SERVICE_FTL","SERVICE_FCL"]                 | TMS-only |
      | Master Wilayah                  | nav-item-master-wilayah                 | ["TMS"]   | ["SERVICE_FTL","SERVICE_FCL"]                 | TMS-only |
      | Master Drop Point               | nav-item-master-drop-point              | ["TMS"]   | ["SERVICE_FTL","SERVICE_FCL"]                 | TMS-only |
      | Master Pelabuhan                | nav-item-master-pelabuhan               | ["TMS"]   | ["SERVICE_FTL","SERVICE_FCL"]                 | TMS-only |
      | Master Pelayaran                | nav-item-master-pelayaran               | ["TMS"]   | ["SERVICE_FTL","SERVICE_FCL"]                 | TMS-only |
      | Master Unit                     | nav-item-master-unit                    | ["TMS"]   | ["SERVICE_FTL","SERVICE_FCL"]                 | TMS-only |
      | Master Sopir                    | nav-item-master-sopir                   | ["TMS"]   | ["SERVICE_FTL","SERVICE_FCL"]                 | TMS-only |
      | Manajemen Vendor                | nav-item-manajemen-vendor               | ["TMS"]   | ["SERVICE_FTL","SERVICE_FCL"]                 | TMS-only |
      | Pengaturan Akun                 | nav-item-pengaturan-akun                | ["TMS"]   | ["SERVICE_FTL","SERVICE_FCL"]                 | TMS-only |
      | Akun Saya                       | nav-item-akun-saya                      | ["TMS"]   | ["SERVICE_FTL","SERVICE_FCL"]                 | TMS-only |
      | Pengaturan Sistem               | nav-item-pengaturan-sistem              | ["TMS"]   | ["SERVICE_FTL","SERVICE_FCL"]                 | TMS-only |
      | Pusat Notifikasi                | nav-item-pusat-notifikasi               | ["TMS"]   | ["SERVICE_FTL","SERVICE_FCL"]                 | TMS-only |

    Examples: OMS-only + moda laut + AUTO_STUFFING
      | menu                            | testid                                  | products  | addOns                                        | state    |
      | Dashboard - Monitoring          | nav-item-dashboard-monitoring           | ["OMS"]   | ["AUTO_STUFFING","SERVICE_FCL"]               | OMS-only |
      | Dashboard - Operasional         | nav-item-dashboard-operasional          | ["OMS"]   | ["AUTO_STUFFING","SERVICE_FCL"]               | OMS-only |
      | Dashboard - Distribusi & Muatan | nav-item-dashboard-distribusi-muatan    | ["OMS"]   | ["AUTO_STUFFING","SERVICE_FCL"]               | OMS-only |
      | Order                           | nav-item-order                          | ["OMS"]   | ["AUTO_STUFFING","SERVICE_FCL"]               | OMS-only |
      | Simulasi Muatan                 | nav-item-simulasi-muatan                | ["OMS"]   | ["AUTO_STUFFING","SERVICE_FCL"]               | OMS-only |
      | Penugasan Tracking              | nav-item-penugasan-tracking             | ["OMS"]   | ["AUTO_STUFFING","SERVICE_FCL"]               | OMS-only |
      | Master Wilayah                  | nav-item-master-wilayah                 | ["OMS"]   | ["AUTO_STUFFING","SERVICE_FCL"]               | OMS-only |
      | Master Barang                   | nav-item-master-barang                  | ["OMS"]   | ["AUTO_STUFFING","SERVICE_FCL"]               | OMS-only |
      | Master Drop Point               | nav-item-master-drop-point              | ["OMS"]   | ["AUTO_STUFFING","SERVICE_FCL"]               | OMS-only |
      | Master Pelabuhan                | nav-item-master-pelabuhan               | ["OMS"]   | ["AUTO_STUFFING","SERVICE_FCL"]               | OMS-only |
      | Master Pelayaran                | nav-item-master-pelayaran               | ["OMS"]   | ["AUTO_STUFFING","SERVICE_FCL"]               | OMS-only |
      | Master Unit                     | nav-item-master-unit                    | ["OMS"]   | ["AUTO_STUFFING","SERVICE_FCL"]               | OMS-only |
      | Master Sopir                    | nav-item-master-sopir                   | ["OMS"]   | ["AUTO_STUFFING","SERVICE_FCL"]               | OMS-only |
      | Manajemen Vendor                | nav-item-manajemen-vendor               | ["OMS"]   | ["AUTO_STUFFING","SERVICE_FCL"]               | OMS-only |
      | Pengaturan Akun                 | nav-item-pengaturan-akun                | ["OMS"]   | ["AUTO_STUFFING","SERVICE_FCL"]               | OMS-only |
      | Akun Saya                       | nav-item-akun-saya                      | ["OMS"]   | ["AUTO_STUFFING","SERVICE_FCL"]               | OMS-only |
      | Pengaturan Sistem               | nav-item-pengaturan-sistem              | ["OMS"]   | ["AUTO_STUFFING","SERVICE_FCL"]               | OMS-only |
      | Pusat Notifikasi                | nav-item-pusat-notifikasi               | ["OMS"]   | ["AUTO_STUFFING","SERVICE_FCL"]               | OMS-only |

    Examples: Gabungan TMS+OMS + darat & laut + AUTO_STUFFING (union 20 item)
      | menu                            | testid                                  | products      | addOns                                                   | state    |
      | Dashboard - Tracking & Location | nav-item-dashboard-tracking-location    | ["TMS","OMS"] | ["AUTO_STUFFING","SERVICE_FTL","SERVICE_FCL"]            | gabungan |
      | Dashboard - Progress Pengiriman | nav-item-dashboard-progress-pengiriman  | ["TMS","OMS"] | ["AUTO_STUFFING","SERVICE_FTL","SERVICE_FCL"]            | gabungan |
      | Dashboard - Distribusi & Muatan | nav-item-dashboard-distribusi-muatan    | ["TMS","OMS"] | ["AUTO_STUFFING","SERVICE_FTL","SERVICE_FCL"]            | gabungan |
      | Simulasi Muatan                 | nav-item-simulasi-muatan                | ["TMS","OMS"] | ["AUTO_STUFFING","SERVICE_FTL","SERVICE_FCL"]            | gabungan |
      | Master Barang                   | nav-item-master-barang                  | ["TMS","OMS"] | ["AUTO_STUFFING","SERVICE_FTL","SERVICE_FCL"]            | gabungan |
      | Master Pelabuhan                | nav-item-master-pelabuhan               | ["TMS","OMS"] | ["AUTO_STUFFING","SERVICE_FTL","SERVICE_FCL"]            | gabungan |
      | Master Pelayaran                | nav-item-master-pelayaran               | ["TMS","OMS"] | ["AUTO_STUFFING","SERVICE_FTL","SERVICE_FCL"]            | gabungan |

  @positive @priority-high @REQ-036 @REQ-076 @AC-036.1 @AC-076.1 @screen-sidebar-shipper @screen-master-moda @OMS000-POS-031
  Scenario: OMS dengan AUTO_STUFFING menampilkan dan membuka Simulasi Muatan
    Given entitlement client diset products ["OMS"] addOns ["AUTO_STUFFING","SERVICE_FTL"]
    And shipper login ulang
    And user berada di halaman "Sidebar Shipper"
    When user mengklik menu "Simulasi Muatan"
    Then sistem menampilkan "nav-item-simulasi-muatan"
    And sistem menampilkan "simulasi-muatan-page"
    And user diarahkan ke halaman "Simulasi Muatan"
    And sistem tidak menampilkan "error-403-page"

  @positive @priority-high @REQ-030 @REQ-031 @REQ-032 @REQ-033 @REQ-034 @REQ-072 @AC-030.1 @AC-031.1 @AC-032.1 @AC-033.1 @AC-034.2 @screen-dashboard @OMS000-POS-032
  Scenario Outline: Tab Dashboard "<tab>" tampil pada state <state>
    Given entitlement client diset products <products> addOns <addOns>
    And shipper login ulang
    When user berada di halaman "Dashboard Shipper"
    Then sistem menampilkan "dashboard-tabs"
    And sistem menampilkan "<testid>"
    And sistem menampilkan tab "<tab>"

    Examples:
      | tab                 | testid                                 | products      | addOns                          | state    |
      | Monitoring          | dashboard-tab-monitoring               | ["TMS"]       | ["SERVICE_FTL"]                 | TMS-only |
      | Tracking & Location | dashboard-tab-tracking-location        | ["TMS"]       | ["SERVICE_FTL"]                 | TMS-only |
      | Progress Pengiriman | dashboard-tab-progress-pengiriman      | ["TMS"]       | ["SERVICE_FTL"]                 | TMS-only |
      | Operasional         | dashboard-tab-operasional              | ["TMS"]       | ["SERVICE_FTL"]                 | TMS-only |
      | Monitoring          | dashboard-tab-monitoring               | ["OMS"]       | ["SERVICE_FCL"]                 | OMS-only |
      | Operasional         | dashboard-tab-operasional              | ["OMS"]       | ["SERVICE_FCL"]                 | OMS-only |
      | Distribusi & Muatan | dashboard-tab-distribusi-muatan        | ["OMS"]       | ["SERVICE_FCL"]                 | OMS-only |
      | Progress Pengiriman | dashboard-tab-progress-pengiriman      | ["TMS","OMS"] | ["SERVICE_FTL","SERVICE_FCL"]   | gabungan |
      | Distribusi & Muatan | dashboard-tab-distribusi-muatan        | ["TMS","OMS"] | ["SERVICE_FTL","SERVICE_FCL"]   | gabungan |

  @positive @priority-high @REQ-035 @AC-035.1 @AC-035.2 @AC-035.3 @screen-sidebar-shipper @screen-form-order @OMS000-POS-033
  Scenario: Menu Order tampil pada seluruh state dan memakai varian OMS saat gabungan
    Given entitlement client diset products ["TMS","OMS"] addOns ["SERVICE_FTL","SERVICE_LTL"]
    And shipper login ulang
    And user berada di halaman "Sidebar Shipper"
    When user mengklik menu "Order"
    Then sistem menampilkan "nav-item-order"
    And user diarahkan ke halaman "Order"
    And user mengklik tombol "Buat Order"
    And sistem menampilkan "section-jenis-rute"
    And sistem menampilkan "order-type-group"

  @positive @priority-medium @REQ-043 @REQ-044 @AC-043.1 @AC-043.3 @AC-044.1 @AC-044.3 @screen-sidebar-shipper @OMS000-POS-034
  Scenario: Master Unit dan Master Sopir tampil sebagai data vendor yang dikelola Admin
    Given entitlement client diset products ["TMS","OMS"] addOns ["SERVICE_FTL"]
    And shipper login ulang
    And user membuka grup menu "MASTER OPERASIONAL"
    When user mengklik menu "Master Unit"
    Then sistem menampilkan "master-unit-page"
    And user mengklik menu "Master Sopir"
    And sistem menampilkan "master-sopir-page"
    And sistem menampilkan teks "dikelola Admin"

  @positive @priority-medium @REQ-038 @REQ-040 @REQ-045 @REQ-046 @REQ-047 @AC-038.1 @AC-038.2 @AC-040.1 @AC-045.1 @AC-046.1 @AC-047.1 @screen-sidebar-shipper @OMS000-POS-035
  Scenario Outline: Menu bervarian Setara "<menu>" tampil identik pada state <state>
    Given entitlement client diset products <products> addOns ["SERVICE_FTL","SERVICE_FCL"]
    And shipper login ulang
    And user membuka grup menu "MASTER OPERASIONAL"
    When user berada di halaman "Sidebar Shipper"
    Then sistem menampilkan "<testid>"
    And sistem menampilkan menu "<menu>" pada "sidebar-shipper"

    Examples:
      | menu              | testid                      | products      | state    |
      | Master Wilayah    | nav-item-master-wilayah     | ["TMS"]       | TMS-only |
      | Master Wilayah    | nav-item-master-wilayah     | ["OMS"]       | OMS-only |
      | Master Wilayah    | nav-item-master-wilayah     | ["TMS","OMS"] | gabungan |
      | Master Drop Point | nav-item-master-drop-point  | ["TMS"]       | TMS-only |
      | Master Drop Point | nav-item-master-drop-point  | ["OMS"]       | OMS-only |
      | Master Drop Point | nav-item-master-drop-point  | ["TMS","OMS"] | gabungan |
      | Manajemen Vendor  | nav-item-manajemen-vendor   | ["TMS"]       | TMS-only |
      | Manajemen Vendor  | nav-item-manajemen-vendor   | ["OMS"]       | OMS-only |
      | Pengaturan Akun   | nav-item-pengaturan-akun    | ["TMS"]       | TMS-only |
      | Pengaturan Akun   | nav-item-pengaturan-akun    | ["OMS"]       | OMS-only |
      | Akun Saya         | nav-item-akun-saya          | ["TMS"]       | TMS-only |
      | Akun Saya         | nav-item-akun-saya          | ["OMS"]       | OMS-only |

  @positive @priority-high @REQ-048 @REQ-049 @AC-048.1 @AC-048.2 @AC-049.1 @AC-049.2 @screen-sidebar-shipper @screen-pengaturan-sistem @OMS000-POS-036
  Scenario: Pengaturan Sistem dan Pusat Notifikasi tampil pada gabungan dengan varian TMS
    Given entitlement client diset products ["TMS","OMS"] addOns ["SERVICE_FTL"]
    And shipper login ulang
    And user berada di halaman "Sidebar Shipper"
    When user mengklik menu "Pengaturan Sistem"
    Then sistem menampilkan "system-settings-page"
    And sistem menampilkan "system-settings-list" berisi 8 item
    And user mengklik menu "Pusat Notifikasi"
    And sistem menampilkan "nav-item-pusat-notifikasi"

  @positive @priority-high @REQ-039 @AC-039.2 @AC-039.3 @screen-sidebar-shipper @screen-master-moda @OMS000-POS-037
  Scenario: Master Barang tampil dan dapat dibuka pada client dengan OMS aktif
    Given entitlement client diset products ["OMS"] addOns ["SERVICE_FTL"]
    And shipper login ulang
    And user membuka grup menu "MASTER OPERASIONAL"
    When user mengklik menu "Master Barang"
    Then sistem menampilkan "nav-item-master-barang"
    And sistem menampilkan "master-barang-page"
    And user diarahkan ke halaman "Master Barang"

  @positive @priority-high @REQ-041 @REQ-042 @REQ-070 @REQ-071 @AC-041.1 @AC-042.1 @AC-070.2 @AC-071.2 @screen-master-moda @screen-sidebar-shipper @OMS000-POS-038
  Scenario Outline: Moda laut aktif menampilkan Master Pelabuhan dan Master Pelayaran pada state <state>
    Given entitlement client diset products <products> addOns <addOns>
    And shipper login ulang
    And user membuka grup menu "MASTER OPERASIONAL"
    When user mengklik menu "Master Pelabuhan"
    Then sistem menampilkan "master-pelabuhan-page"
    And user mengklik menu "Master Pelayaran"
    And sistem menampilkan "master-pelayaran-page"

    Examples:
      | products      | addOns                        | state    |
      | ["TMS"]       | ["SERVICE_FCL"]               | TMS-only |
      | ["OMS"]       | ["SERVICE_LCL"]               | OMS-only |
      | ["TMS","OMS"] | ["SERVICE_FTL","SERVICE_FCL"] | gabungan |

  @positive @priority-high @REQ-050 @REQ-057 @AC-050.1 @AC-050.2 @AC-057.1 @screen-sidebar-vendor @OMS000-POS-039
  Scenario Outline: Sidebar Vendor memuat tepat 6 item resmi pada state <state>
    Given entitlement client diset products <products> addOns <addOns>
    And vendor login ulang
    When user berada di halaman "Sidebar Vendor"
    Then sistem menampilkan "sidebar-vendor"
    And sistem menampilkan "sidebar-vendor" berisi 6 item
    And sistem menampilkan menu "Order, Penugasan Tracking, Master Armada, Master Sopir, Akun Saya, Pusat Notifikasi"

    Examples:
      | products      | addOns                                        | state    |
      | ["TMS"]       | ["SERVICE_FTL"]                               | TMS-only |
      | ["OMS"]       | ["SERVICE_FCL"]                               | OMS-only |
      | ["TMS","OMS"] | ["AUTO_STUFFING","SERVICE_FTL","SERVICE_FCL"] | gabungan |

  @positive @priority-medium @REQ-051 @REQ-052 @REQ-053 @REQ-054 @REQ-055 @REQ-056 @AC-051.1 @AC-051.2 @AC-053.1 @AC-054.1 @AC-055.1 @AC-056.1 @screen-sidebar-vendor @OMS000-POS-040
  Scenario Outline: Menu Vendor "<menu>" tampil pada produk <state>
    Given entitlement client diset products <products> addOns ["SERVICE_FTL"]
    And vendor login ulang
    When user berada di halaman "Sidebar Vendor"
    Then sistem menampilkan "<testid>"
    And sistem menampilkan menu "<menu>" pada "sidebar-vendor"

    Examples:
      | menu               | testid                       | products  | state |
      | Order              | nav-item-order               | ["TMS"]   | TMS   |
      | Order              | nav-item-order               | ["OMS"]   | OMS   |
      | Penugasan Tracking | nav-item-penugasan-tracking  | ["TMS"]   | TMS   |
      | Penugasan Tracking | nav-item-penugasan-tracking  | ["OMS"]   | OMS   |
      | Master Armada      | nav-item-master-armada       | ["TMS"]   | TMS   |
      | Master Armada      | nav-item-master-armada       | ["OMS"]   | OMS   |
      | Master Sopir       | nav-item-master-sopir        | ["TMS"]   | TMS   |
      | Master Sopir       | nav-item-master-sopir        | ["OMS"]   | OMS   |
      | Akun Saya          | nav-item-akun-saya           | ["TMS"]   | TMS   |
      | Akun Saya          | nav-item-akun-saya           | ["OMS"]   | OMS   |
      | Pusat Notifikasi   | nav-item-pusat-notifikasi    | ["TMS"]   | TMS   |
      | Pusat Notifikasi   | nav-item-pusat-notifikasi    | ["OMS"]   | OMS   |

  @positive @priority-medium @REQ-053 @REQ-054 @AC-053.1 @AC-054.1 @screen-sidebar-vendor @OMS000-POS-041
  Scenario: Vendor membuka Master Armada dan Master Sopir miliknya sendiri
    Given entitlement client diset products ["OMS"] addOns ["SERVICE_FCL"]
    And vendor login ulang
    And user berada di halaman "Sidebar Vendor"
    When user mengklik menu "Master Armada"
    Then sistem menampilkan "master-armada-page"
    And user mengklik menu "Master Sopir"
    And sistem menampilkan "master-sopir-page"
    And sistem menampilkan "nav-group-master-operasional"

  @positive @priority-low @REQ-055 @REQ-056 @AC-055.1 @AC-056.1 @screen-sidebar-vendor @screen-login @OMS000-POS-042
  Scenario: Vendor membuka Akun Saya dan Pusat Notifikasi pada client OMS-only
    Given entitlement client diset products ["OMS"] addOns []
    And vendor login ulang
    And user berada di halaman "Sidebar Vendor"
    When user mengklik menu "Akun Saya"
    Then sistem menampilkan "akun-saya-page"
    And user mengklik tombol "Notifikasi"
    And sistem menampilkan "header-notification"
    And sistem menampilkan "header-tenant-context" berisi "Vendor"

  @positive @priority-high @REQ-058 @REQ-067 @AC-058.1 @AC-067.1 @AC-067.2 @AC-048.2 @screen-pengaturan-sistem @OMS000-POS-043
  Scenario: Pengaturan Sistem menampilkan seluruh 8 item pada gabungan TMS+OMS
    Given entitlement client diset products ["TMS","OMS"] addOns ["SERVICE_FTL"]
    And shipper login ulang
    When user berada di halaman "Pengaturan Sistem"
    Then sistem menampilkan "system-settings-list" berisi 8 item
    And sistem menampilkan "setting-item-durasi-undangan-vendor"
    And sistem menampilkan "setting-item-notifikasi-lokasi"
    And sistem menampilkan "setting-item-deteksi-tidak-update"
    And sistem menampilkan "setting-item-deteksi-keluar-jalur"
    And sistem menampilkan "setting-item-koridor-historis"
    And sistem menampilkan "setting-item-notifikasi-dini-terlambat"
    And sistem menampilkan "setting-item-nomor-whatsapp-cs"
    And sistem menampilkan "setting-item-pembatasan-kelayakan-armada"

  @positive @priority-high @REQ-068 @REQ-058 @AC-068.1 @AC-068.2 @screen-pengaturan-sistem @OMS000-POS-044
  Scenario: Pengaturan Sistem menampilkan tepat 2 item pada OMS-only
    Given entitlement client diset products ["OMS"] addOns ["SERVICE_FCL"]
    And shipper login ulang
    When user berada di halaman "Pengaturan Sistem"
    Then sistem menampilkan "system-settings-list" berisi 2 item
    And sistem menampilkan "setting-item-durasi-undangan-vendor"
    And sistem menampilkan "setting-item-nomor-whatsapp-cs"

  @positive @priority-high @REQ-059 @REQ-060 @REQ-061 @REQ-062 @REQ-063 @REQ-064 @REQ-065 @REQ-066 @AC-059.1 @AC-060.1 @AC-061.1 @AC-062.1 @AC-063.1 @AC-064.1 @AC-065.1 @AC-066.1 @screen-pengaturan-sistem @OMS000-POS-045
  Scenario Outline: Item Pengaturan Sistem "<item>" tampil pada state <state>
    Given entitlement client diset products <products> addOns ["SERVICE_FTL"]
    And shipper login ulang
    When user berada di halaman "Pengaturan Sistem"
    Then sistem menampilkan "<testid>"
    And sistem menampilkan teks "<item>"

    Examples: TMS-only (8 item)
      | item                               | testid                                    | products | state    |
      | Durasi Kedaluwarsa Undangan Vendor | setting-item-durasi-undangan-vendor       | ["TMS"]  | TMS-only |
      | Notifikasi Lokasi                  | setting-item-notifikasi-lokasi            | ["TMS"]  | TMS-only |
      | Deteksi Tidak Update               | setting-item-deteksi-tidak-update         | ["TMS"]  | TMS-only |
      | Deteksi Keluar Jalur               | setting-item-deteksi-keluar-jalur         | ["TMS"]  | TMS-only |
      | Koridor Historis                   | setting-item-koridor-historis             | ["TMS"]  | TMS-only |
      | Notifikasi Dini Berisiko Terlambat | setting-item-notifikasi-dini-terlambat    | ["TMS"]  | TMS-only |
      | Nomor WhatsApp CS                  | setting-item-nomor-whatsapp-cs            | ["TMS"]  | TMS-only |
      | Pembatasan Kelayakan Armada        | setting-item-pembatasan-kelayakan-armada  | ["TMS"]  | TMS-only |

    Examples: OMS-only (2 item)
      | item                               | testid                                    | products | state    |
      | Durasi Kedaluwarsa Undangan Vendor | setting-item-durasi-undangan-vendor       | ["OMS"]  | OMS-only |
      | Nomor WhatsApp CS                  | setting-item-nomor-whatsapp-cs            | ["OMS"]  | OMS-only |

    Examples: Gabungan (union 8 item)
      | item                               | testid                                    | products      | state    |
      | Notifikasi Lokasi                  | setting-item-notifikasi-lokasi            | ["TMS","OMS"] | gabungan |
      | Deteksi Tidak Update               | setting-item-deteksi-tidak-update         | ["TMS","OMS"] | gabungan |
      | Deteksi Keluar Jalur               | setting-item-deteksi-keluar-jalur         | ["TMS","OMS"] | gabungan |
      | Koridor Historis                   | setting-item-koridor-historis             | ["TMS","OMS"] | gabungan |
      | Notifikasi Dini Berisiko Terlambat | setting-item-notifikasi-dini-terlambat    | ["TMS","OMS"] | gabungan |
      | Pembatasan Kelayakan Armada        | setting-item-pembatasan-kelayakan-armada  | ["TMS","OMS"] | gabungan |
      | Durasi Kedaluwarsa Undangan Vendor | setting-item-durasi-undangan-vendor       | ["TMS","OMS"] | gabungan |
      | Nomor WhatsApp CS                  | setting-item-nomor-whatsapp-cs            | ["TMS","OMS"] | gabungan |

  @positive @priority-medium @REQ-099 @REQ-063 @AC-099.3 @UF-5 @screen-pengaturan-sistem @OMS000-POS-046
  Scenario: Nilai setting TMS kembali seperti terakhir setelah produk TMS diaktifkan lagi
    Given entitlement client diset products ["TMS","OMS"] addOns ["SERVICE_FTL"]
    And shipper login ulang
    And user berada di halaman "Pengaturan Sistem"
    When user mengisi field "Koridor Historis" dengan "30"
    And user mengklik tombol "Simpan"
    And sistem menampilkan "toast-success"
    And entitlement client diset products ["OMS"] addOns ["SERVICE_FTL"]
    And shipper login ulang
    And entitlement client diset products ["TMS","OMS"] addOns ["SERVICE_FTL"]
    And shipper login ulang
    Then user berada di halaman "Pengaturan Sistem"
    And sistem menampilkan "setting-item-koridor-historis"
    And sistem menampilkan field "Koridor Historis" berisi "30"

  # ==========================================================================
  # === KATEGORI: POSITIVE (bagian C) — R6 Add-on, R7 TMS LKL, R8 Propagasi ===
  # ==========================================================================

  @positive @priority-high @REQ-069 @AC-069.1 @AC-069.2 @AC-069.3 @screen-form-order @screen-sidebar-shipper @OMS000-POS-047
  Scenario Outline: Add-on <addOns> mengaktifkan moda <moda>
    Given entitlement client diset products ["TMS","OMS"] addOns <addOns>
    And shipper login ulang
    When user berada di halaman "Form Order"
    Then sistem menampilkan "order-type-group"
    And sistem menampilkan "<orderTypeTestid>"
    And sistem menampilkan moda aktif "<moda>"

    Examples:
      | addOns                          | moda  | orderTypeTestid        |
      | ["SERVICE_FTL","SERVICE_LTL"]   | Darat | order-type-ftl         |
      | ["SERVICE_FCL","SERVICE_LCL"]   | Laut  | order-type-fcl         |
      | ["SERVICE_AIR_FREIGHT"]         | Udara | order-type-air-freight |

  @positive @priority-high @REQ-072 @REQ-032 @AC-072.1 @AC-032.1 @UF-4 @screen-dashboard @OMS000-POS-048
  Scenario: Moda darat aktif pada TMS menampilkan Dashboard - Progress Pengiriman
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_LTL"]
    And shipper login ulang
    When user berada di halaman "Dashboard Shipper"
    Then sistem menampilkan "dashboard-tabs"
    And sistem menampilkan "dashboard-tab-progress-pengiriman"
    And user mengklik tab "Progress Pengiriman"
    And sistem menampilkan "dashboard-panel"

  @positive @priority-high @REQ-073 @REQ-070 @REQ-071 @AC-073.1 @ALT-19 @screen-sidebar-shipper @screen-dashboard @OMS000-POS-049
  Scenario: Moda darat dan laut aktif bersamaan menampilkan ketiga fitur matriks jenis pengiriman
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FTL","SERVICE_FCL"]
    And shipper login ulang
    And user membuka grup menu "MASTER OPERASIONAL"
    When user berada di halaman "Sidebar Shipper"
    Then sistem menampilkan "nav-item-master-pelabuhan"
    And sistem menampilkan "nav-item-master-pelayaran"
    And user berada di halaman "Dashboard Shipper"
    And sistem menampilkan "dashboard-tab-progress-pengiriman"

  @positive @priority-high @REQ-074 @AC-074.2 @screen-sidebar-shipper @screen-master-moda @OMS000-POS-050
  Scenario: Filter AND terpenuhi — OMS-only dengan moda laut menampilkan Master Pelabuhan
    Given entitlement client diset products ["OMS"] addOns ["SERVICE_FCL"]
    And shipper login ulang
    And user membuka grup menu "MASTER OPERASIONAL"
    When user mengklik menu "Master Pelabuhan"
    Then sistem menampilkan "nav-item-master-pelabuhan"
    And sistem menampilkan "master-pelabuhan-page"
    And sistem menampilkan "master-pelabuhan-table"
    And sistem tidak menampilkan "error-403-page"

  @positive @priority-high @REQ-075 @REQ-016 @AC-075.1 @UF-5 @screen-sidebar-shipper @screen-master-moda @OMS000-POS-051
  Scenario: Menambahkan kembali add-on moda laut memunculkan ulang fitur berbasis moda
    Given entitlement client diset products ["TMS"] addOns []
    And shipper login ulang
    And sistem tidak menampilkan "nav-item-master-pelabuhan"
    When entitlement client diset products ["TMS"] addOns ["SERVICE_FCL"]
    And shipper login ulang
    And user membuka grup menu "MASTER OPERASIONAL"
    Then sistem menampilkan "nav-item-master-pelabuhan"
    And sistem menampilkan "nav-item-master-pelayaran"
    And user diarahkan ke halaman "Master Pelabuhan"

  @positive @priority-medium @REQ-077 @REQ-069 @AC-077.1 @screen-form-order @OMS000-POS-052
  Scenario Outline: Opsi jenis pengiriman "<jenis>" tersedia ketika add-on <addOn> aktif
    Given entitlement client diset products ["OMS"] addOns <addOns>
    And shipper login ulang
    And user berada di halaman "Form Order"
    When user mengklik tombol "Buat Order"
    Then sistem menampilkan "order-type-group"
    And sistem menampilkan "<testid>"
    And user memilih opsi "<jenis>" pada field "Jenis Pengiriman"

    Examples:
      | jenis       | testid                 | addOn                | addOns                    |
      | FTL         | order-type-ftl         | SERVICE_FTL          | ["SERVICE_FTL"]           |
      | LTL         | order-type-ltl         | SERVICE_LTL          | ["SERVICE_LTL"]           |
      | FCL         | order-type-fcl         | SERVICE_FCL          | ["SERVICE_FCL"]           |
      | LCL         | order-type-lcl         | SERVICE_LCL          | ["SERVICE_LCL"]           |
      | Air Freight | order-type-air-freight | SERVICE_AIR_FREIGHT  | ["SERVICE_AIR_FREIGHT"]   |

  @positive @priority-medium @REQ-077 @AC-077.2 @screen-form-order @OMS000-POS-053
  Scenario: Menambahkan SERVICE_LTL memunculkan opsi jenis order LTL setelah refresh
    Given entitlement client diset products ["OMS"] addOns ["SERVICE_FTL"]
    And shipper login ulang
    And user berada di halaman "Form Order"
    And sistem tidak menampilkan "order-type-ltl"
    When entitlement client diset products ["OMS"] addOns ["SERVICE_FTL","SERVICE_LTL"]
    And user memuat ulang halaman
    Then sistem menampilkan "order-type-ftl"
    And sistem menampilkan "order-type-ltl"

  @positive @priority-high @REQ-078 @AC-078.1 @AC-078.2 @screen-nav-lkl @OMS000-POS-054
  Scenario: Navigasi TMS LKL menampilkan lima grup menu resmi
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FTL","SERVICE_FCL","SERVICE_AIR_FREIGHT"]
    And shipper login ulang
    When user berada di halaman "Navigasi TMS LKL"
    Then sistem menampilkan "nav-group-dashboard"
    And sistem menampilkan "nav-group-menu-utama"
    And sistem menampilkan "nav-group-master-operasional"
    And sistem menampilkan "nav-group-menu-keuangan"
    And sistem menampilkan "nav-group-menu-lainnya"

  @positive @priority-high @REQ-079 @REQ-080 @REQ-081 @REQ-082 @REQ-083 @REQ-084 @REQ-086 @REQ-087 @REQ-088 @REQ-089 @REQ-090 @REQ-091 @REQ-092 @REQ-093 @screen-nav-lkl @OMS000-POS-055
  Scenario Outline: Menu TMS LKL "<menu>" tampil pada moda <moda>
    Given entitlement client diset products ["TMS"] addOns <addOns>
    And shipper login ulang
    And user membuka grup menu "MASTER OPERASIONAL"
    When user berada di halaman "Navigasi TMS LKL"
    Then sistem menampilkan "<testid>"
    And sistem menampilkan menu "<menu>" pada "sidebar-shipper"

    Examples: Moda Darat
      | menu                            | testid                                 | addOns            | moda  |
      | Dashboard - Monitoring          | nav-item-dashboard-monitoring          | ["SERVICE_FTL"]   | Darat |
      | Dashboard - Tracking & Location | nav-item-dashboard-tracking-location   | ["SERVICE_FTL"]   | Darat |
      | Dashboard - Operasional         | nav-item-dashboard-operasional         | ["SERVICE_FTL"]   | Darat |
      | Shipment                        | nav-item-shipment                      | ["SERVICE_FTL"]   | Darat |
      | Order                           | nav-item-order                         | ["SERVICE_FTL"]   | Darat |
      | Penugasan Tracking              | nav-item-penugasan-tracking            | ["SERVICE_FTL"]   | Darat |
      | Otomasi Jalur                   | nav-item-otomasi-jalur                 | ["SERVICE_FTL"]   | Darat |
      | Master Wilayah                  | nav-item-master-wilayah                | ["SERVICE_FTL"]   | Darat |
      | Master Rute                     | nav-item-master-rute                   | ["SERVICE_FTL"]   | Darat |
      | Master Customer                 | nav-item-master-customer               | ["SERVICE_FTL"]   | Darat |
      | Master Drop Point               | nav-item-master-drop-point             | ["SERVICE_FTL"]   | Darat |
      | Master Unit & Sopir             | nav-item-master-unit-sopir             | ["SERVICE_FTL"]   | Darat |
      | Master Kemasan                  | nav-item-master-kemasan                | ["SERVICE_FTL"]   | Darat |
      | Master Bank                     | nav-item-master-bank                   | ["SERVICE_FTL"]   | Darat |
      | Manajemen Invoice               | nav-item-manajemen-invoice             | ["SERVICE_FTL"]   | Darat |
      | Laporan Keuangan                | nav-item-laporan-keuangan              | ["SERVICE_FTL"]   | Darat |
      | Pengaturan Akun                 | nav-item-pengaturan-akun               | ["SERVICE_FTL"]   | Darat |
      | Akun Saya                       | nav-item-akun-saya                     | ["SERVICE_FTL"]   | Darat |
      | Pusat Notifikasi                | nav-item-pusat-notifikasi              | ["SERVICE_FTL"]   | Darat |

    Examples: Moda Laut
      | menu                            | testid                                 | addOns            | moda |
      | Dashboard - Tracking & Location | nav-item-dashboard-tracking-location   | ["SERVICE_FCL"]   | Laut |
      | Dashboard - Operasional         | nav-item-dashboard-operasional         | ["SERVICE_FCL"]   | Laut |
      | Shipment                        | nav-item-shipment                      | ["SERVICE_FCL"]   | Laut |
      | Order                           | nav-item-order                         | ["SERVICE_FCL"]   | Laut |
      | Penugasan Tracking              | nav-item-penugasan-tracking            | ["SERVICE_FCL"]   | Laut |
      | Master Wilayah                  | nav-item-master-wilayah                | ["SERVICE_FCL"]   | Laut |
      | Master Rute                     | nav-item-master-rute                   | ["SERVICE_FCL"]   | Laut |
      | Master Customer                 | nav-item-master-customer               | ["SERVICE_FCL"]   | Laut |
      | Master Drop Point               | nav-item-master-drop-point             | ["SERVICE_FCL"]   | Laut |
      | Master Pelabuhan                | nav-item-master-pelabuhan              | ["SERVICE_FCL"]   | Laut |
      | Master Pelayaran                | nav-item-master-pelayaran              | ["SERVICE_FCL"]   | Laut |
      | Master Unit & Sopir             | nav-item-master-unit-sopir             | ["SERVICE_FCL"]   | Laut |
      | Master Kemasan                  | nav-item-master-kemasan                | ["SERVICE_FCL"]   | Laut |
      | Master Bank                     | nav-item-master-bank                   | ["SERVICE_FCL"]   | Laut |
      | Manajemen Invoice               | nav-item-manajemen-invoice             | ["SERVICE_FCL"]   | Laut |
      | Laporan Keuangan                | nav-item-laporan-keuangan              | ["SERVICE_FCL"]   | Laut |

    Examples: Moda Udara
      | menu                            | testid                                 | addOns                     | moda  |
      | Dashboard - Tracking & Location | nav-item-dashboard-tracking-location   | ["SERVICE_AIR_FREIGHT"]    | Udara |
      | Dashboard - Operasional         | nav-item-dashboard-operasional         | ["SERVICE_AIR_FREIGHT"]    | Udara |
      | Shipment                        | nav-item-shipment                      | ["SERVICE_AIR_FREIGHT"]    | Udara |
      | Order                           | nav-item-order                         | ["SERVICE_AIR_FREIGHT"]    | Udara |
      | Penugasan Tracking              | nav-item-penugasan-tracking            | ["SERVICE_AIR_FREIGHT"]    | Udara |
      | Master Wilayah                  | nav-item-master-wilayah                | ["SERVICE_AIR_FREIGHT"]    | Udara |
      | Master Rute                     | nav-item-master-rute                   | ["SERVICE_AIR_FREIGHT"]    | Udara |
      | Master Customer                 | nav-item-master-customer               | ["SERVICE_AIR_FREIGHT"]    | Udara |
      | Master Drop Point               | nav-item-master-drop-point             | ["SERVICE_AIR_FREIGHT"]    | Udara |
      | Master Bandara                  | nav-item-master-bandara                | ["SERVICE_AIR_FREIGHT"]    | Udara |
      | Master Maskapai                 | nav-item-master-maskapai               | ["SERVICE_AIR_FREIGHT"]    | Udara |
      | Master Unit & Sopir             | nav-item-master-unit-sopir             | ["SERVICE_AIR_FREIGHT"]    | Udara |
      | Master Kemasan                  | nav-item-master-kemasan                | ["SERVICE_AIR_FREIGHT"]    | Udara |
      | Master Bank                     | nav-item-master-bank                   | ["SERVICE_AIR_FREIGHT"]    | Udara |
      | Manajemen Invoice               | nav-item-manajemen-invoice             | ["SERVICE_AIR_FREIGHT"]    | Udara |
      | Laporan Keuangan                | nav-item-laporan-keuangan              | ["SERVICE_AIR_FREIGHT"]    | Udara |
      | Pengaturan Akun                 | nav-item-pengaturan-akun               | ["SERVICE_AIR_FREIGHT"]    | Udara |
      | Akun Saya                       | nav-item-akun-saya                     | ["SERVICE_AIR_FREIGHT"]    | Udara |
      | Pusat Notifikasi                | nav-item-pusat-notifikasi              | ["SERVICE_AIR_FREIGHT"]    | Udara |

  @positive @priority-high @REQ-085 @REQ-084 @AC-085.1 @AC-085.2 @AC-085.4 @screen-nav-lkl @OMS000-POS-056
  Scenario Outline: Tipe pengiriman Less <addOns> memunculkan tab Tarif Pengiriman dan Konversi Muatan
    Given entitlement client diset products ["TMS"] addOns <addOns>
    And shipper login ulang
    And user berada di halaman "Navigasi TMS LKL"
    When user mengklik menu "Master Rute"
    Then sistem menampilkan "master-rute-tabs"
    And sistem menampilkan "master-rute-tab-tarif-pengiriman"
    And sistem menampilkan "master-rute-tab-konversi-muatan"

    Examples:
      | addOns                          | tipe Less |
      | ["SERVICE_LTL"]                 | LTL saja  |
      | ["SERVICE_LCL"]                 | LCL saja  |
      | ["SERVICE_LTL","SERVICE_LCL"]   | keduanya  |

  @positive @priority-high @REQ-094 @AC-094.1 @AC-094.2 @AC-094.3 @ALT-21 @screen-nav-lkl @OMS000-POS-057
  Scenario Outline: Kombinasi moda <kombinasi> menampilkan union menu TMS LKL
    Given entitlement client diset products ["TMS"] addOns <addOns>
    And shipper login ulang
    And user membuka grup menu "MASTER OPERASIONAL"
    When user berada di halaman "Navigasi TMS LKL"
    Then sistem menampilkan "<wajibAda1>"
    And sistem menampilkan "<wajibAda2>"
    And sistem menampilkan "nav-item-master-rute"

    Examples:
      | addOns                                                    | kombinasi         | wajibAda1                       | wajibAda2                  |
      | ["SERVICE_FTL","SERVICE_FCL"]                             | Darat+Laut        | nav-item-otomasi-jalur          | nav-item-master-pelabuhan  |
      | ["SERVICE_FTL","SERVICE_AIR_FREIGHT"]                     | Darat+Udara       | nav-item-dashboard-monitoring   | nav-item-master-bandara    |
      | ["SERVICE_LTL","SERVICE_LCL","SERVICE_AIR_FREIGHT"]       | Darat+Laut+Udara  | nav-item-master-pelayaran       | nav-item-master-maskapai   |

  @positive @priority-high @REQ-089 @REQ-090 @AC-089.1 @AC-090.1 @ALT-21 @screen-nav-lkl @screen-master-moda @OMS000-POS-058
  Scenario: Moda udara aktif menampilkan dan membuka Master Bandara serta Master Maskapai
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_AIR_FREIGHT"]
    And shipper login ulang
    And user membuka grup menu "MASTER OPERASIONAL"
    When user mengklik menu "Master Bandara"
    Then sistem menampilkan "master-bandara-page"
    And user mengklik menu "Master Maskapai"
    And sistem menampilkan "master-maskapai-page"
    And user diarahkan ke halaman "Master Maskapai"

  @positive @priority-high @REQ-095 @AC-095.1 @AC-095.3 @UF-1 @screen-login @screen-sidebar-shipper @OMS000-POS-059
  Scenario: Perubahan entitlement tercermin pada navigasi setelah refresh halaman
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FTL"]
    And shipper login ulang
    And sistem tidak menampilkan "nav-item-master-barang"
    When entitlement client diset products ["TMS","OMS"] addOns ["SERVICE_FTL"]
    And user memuat ulang halaman
    And user membuka grup menu "MASTER OPERASIONAL"
    Then sistem menampilkan "nav-item-master-barang"
    And sistem menampilkan "nav-item-dashboard-distribusi-muatan"

  @positive @priority-high @REQ-095 @AC-095.2 @screen-login @screen-sidebar-shipper @OMS000-POS-060
  Scenario: Perubahan entitlement tercermin setelah logout dan login ulang
    Given entitlement client diset products ["TMS","OMS"] addOns ["AUTO_STUFFING","SERVICE_FTL"]
    And shipper login ulang
    And sistem menampilkan "nav-item-simulasi-muatan"
    When entitlement client diset products ["TMS"] addOns ["SERVICE_FTL"]
    And user mengklik tombol "Keluar"
    And user berada di halaman "Login"
    And user mengisi field "Email" dengan "shipper.qa@prahu-hub.test"
    And user mengisi field "Kata Sandi" dengan "${SHIPPER_PASSWORD}"
    And user mengklik tombol "Masuk"
    Then user diarahkan ke halaman "Dashboard Shipper"
    And sistem tidak menampilkan "nav-item-simulasi-muatan"
    And sistem menampilkan "nav-item-dashboard-tracking-location"

  @positive @priority-high @REQ-096 @AC-096.1 @screen-master-moda @screen-error @OMS000-POS-061
  Scenario: Route fitur yang ter-entitle dapat dibuka langsung tanpa guard
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FCL"]
    And shipper login ulang
    When user membuka URL "/master-pelabuhan"
    Then sistem menampilkan "master-pelabuhan-page"
    And sistem menampilkan "master-pelabuhan-table"
    And sistem tidak menampilkan "error-403-page"
    And user diarahkan ke halaman "Master Pelabuhan"

  @positive @priority-high @REQ-097 @AC-097.1 @screen-api-entitlement @screen-master-moda @OMS000-POS-062
  Scenario: API fitur yang ter-entitle mengembalikan 200 untuk user shipper
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FCL"]
    And shipper login ulang
    When user memanggil API fitur "master-pelabuhan" dengan token shipper
    Then respons berstatus 200
    And respons field "$.data" berisi daftar pelabuhan
    And sistem tidak menampilkan "$.message" berisi "403"

  @positive @priority-high @REQ-098 @AC-098.1 @AC-098.2 @UF-5 @screen-master-moda @OMS000-POS-063
  Scenario: Data master tetap utuh setelah add-on moda laut dicabut
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FCL"]
    And shipper login ulang
    And user mencatat "master-pelabuhan-pagination-info" pada halaman "Master Pelabuhan"
    When entitlement client diset products ["TMS"] addOns ["SERVICE_FTL"]
    And shipper login ulang
    And admin memverifikasi data master pelabuhan melalui jalur admin
    Then sistem menampilkan jumlah record master pelabuhan tidak berkurang
    And sistem tidak menampilkan notifikasi penghapusan data

  @positive @priority-high @REQ-099 @AC-099.1 @AC-099.2 @UF-5 @screen-master-moda @OMS000-POS-064
  Scenario: Reaktivasi add-on mengembalikan menu beserta data lama secara utuh
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FCL"]
    And shipper login ulang
    And user mencatat "master-pelabuhan-pagination-info" pada halaman "Master Pelabuhan"
    And entitlement client diset products ["TMS"] addOns ["SERVICE_FTL"]
    And shipper login ulang
    When entitlement client diset products ["TMS"] addOns ["SERVICE_FCL"]
    And shipper login ulang
    And user membuka grup menu "MASTER OPERASIONAL"
    And user mengklik menu "Master Pelabuhan"
    Then sistem menampilkan "master-pelabuhan-page"
    And sistem menampilkan "master-pelabuhan-pagination-info" identik dengan catatan sebelumnya

  @positive @priority-medium @REQ-100 @AC-100.1 @AC-100.3 @ALT-25 @screen-penugasan-tracking @OMS000-POS-065
  Scenario: Order berjalan tetap dapat dibuka dan diselesaikan setelah entitlement berubah
    Given entitlement client diset products ["TMS","OMS"] addOns ["SERVICE_FTL","SERVICE_FCL"]
    And order "ORD769797FSH" berstatus "Ditugaskan"
    When entitlement client diset products ["OMS"] addOns ["SERVICE_FTL"]
    And shipper login ulang
    And user berada di halaman "Penugasan Tracking"
    Then sistem menampilkan baris penugasan order "ORD769797FSH"
    And user mengklik baris penugasan order "ORD769797FSH"
    And sistem menampilkan "assignment-row-status" berisi "Ditugaskan"
    And sistem tidak menampilkan "error-403-page"

  @positive @priority-medium @REQ-101 @AC-101.1 @AC-101.2 @screen-login @screen-sidebar-shipper @screen-error @OMS000-POS-066
  Scenario: Client tanpa produk aktif tetap dapat login dengan sidebar minimal tiga menu
    Given entitlement client legacy tidak memiliki produk aktif
    And user berada di halaman "Login"
    When user mengisi field "Email" dengan "shipper.qa@prahu-hub.test"
    And user mengisi field "Kata Sandi" dengan "${SHIPPER_PASSWORD}"
    And user mengklik tombol "Masuk"
    Then user diarahkan ke halaman "Dashboard Shipper"
    And sistem menampilkan "nav-item-pengaturan-akun"
    And sistem menampilkan "nav-item-akun-saya"
    And sistem menampilkan "nav-item-pusat-notifikasi"
    And sistem tidak menampilkan "login-error"

  @positive @priority-high @REQ-102 @AC-102.1 @AC-102.2 @screen-sidebar-shipper @screen-sidebar-vendor @screen-driver-app @OMS000-POS-067
  Scenario: Entitlement yang sama menghasilkan keputusan konsisten pada tiga kanal
    Given entitlement client diset products ["OMS"] addOns ["SERVICE_FCL"]
    And shipper login ulang
    And sistem tidak menampilkan "nav-item-dashboard-tracking-location"
    When vendor login ulang
    Then sistem menampilkan "sidebar-vendor" berisi 6 item
    And penugasan order "ORD769797FSH" telah diberikan kepada "Sopir A"
    And daftar tugas sopir "Sopir A" tidak memuat order "ORD769797FSH"
    And sistem tidak menampilkan fitur di luar entitlement pada kanal mana pun

  # ===================================================================
  # === KATEGORI: NEGATIVE (bagian A) — R1 Kontrak & Keamanan API ===
  # ===================================================================

  @negative @priority-high @REQ-002 @REQ-009 @AC-009.1 @AC-009.2 @V-02 @ALT-02 @screen-api-entitlement @OMS000-NEG-001
  Scenario: Admin key salah ditolak 401 dan entitlement tidak berubah
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FTL"]
    And admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    And admin menyertakan header "X-Admin-Key" dengan "kunci-admin-salah-qa"
    When admin mengirim body dengan products ["OMS"] dan addOns ["SERVICE_FCL"]
    Then respons berstatus 401
    And respons field "$.message" berisi "Unauthorized"
    And admin membaca ulang entitlement client "<clientId>"
    And hasil pembacaan ulang field "$.products" berisi ["TMS"]
    And hasil pembacaan ulang field "$.addOns" berisi ["SERVICE_FTL"]

  @negative @priority-high @REQ-010 @AC-010.1 @AC-010.2 @AC-010.3 @V-02 @ALT-01 @screen-api-entitlement @OMS000-NEG-002
  Scenario Outline: Header X-Admin-Key <kondisi> ditolak 401 tanpa mengubah entitlement
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FTL"]
    And admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    And admin menyertakan header "X-Admin-Key" dengan <nilaiHeader>
    When admin mengirim body dengan products ["OMS"] dan addOns []
    Then respons berstatus 401
    And admin membaca ulang entitlement client "<clientId>"
    And hasil pembacaan ulang field "$.products" berisi ["TMS"]

    Examples:
      | kondisi          | nilaiHeader |
      | tidak dikirim    | ABSEN       |
      | bernilai kosong  | ""          |
      | hanya spasi      | "   "       |

  @negative @priority-medium @REQ-003 @AC-003.2 @V-03 @screen-api-entitlement @OMS000-NEG-003
  Scenario: Content-Type selain application/json ditolak
    Given admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    And admin menyertakan header "Content-Type" dengan "text/plain"
    When admin mengirim body dengan products ["TMS"] dan addOns []
    Then respons berstatus 415
    And respons field "$.message" berisi "Content-Type"
    And admin membaca ulang entitlement client "<clientId>"
    And hasil pembacaan ulang field "$.products" tidak berubah

  @negative @priority-medium @REQ-003 @AC-003.3 @V-04 @screen-api-entitlement @OMS000-NEG-004
  Scenario: Body bukan JSON valid ditolak 400
    Given admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    And admin menyertakan header "Content-Type" dengan "application/json"
    When admin mengirim body mentah "products=TMS&addOns=SERVICE_FTL"
    Then respons berstatus 400
    And respons field "$.message" berisi "JSON"
    And admin membaca ulang entitlement client "<clientId>"
    And hasil pembacaan ulang field "$.products" tidak berubah

  @negative @priority-high @REQ-011 @AC-011.1 @AC-011.2 @V-01 @ALT-03 @screen-api-entitlement @OMS000-NEG-005
  Scenario: clientId UUID yang tidak terdaftar ditolak 404 tanpa membuat client baru
    Given admin menyiapkan request PATCH entitlement untuk client "00000000-0000-4000-8000-000000000000"
    When admin mengirim body dengan products ["TMS"] dan addOns ["SERVICE_FTL"]
    Then respons berstatus 404
    And respons field "$.message" berisi "Client not found"
    And sistem tidak menampilkan client baru dengan id "00000000-0000-4000-8000-000000000000"

  @negative @priority-medium @REQ-012 @AC-012.1 @AC-012.2 @V-01 @ALT-04 @screen-api-entitlement @OMS000-NEG-006
  Scenario Outline: clientId berformat tidak valid ditolak 400
    Given admin menyiapkan request PATCH entitlement untuk client "<clientIdInvalid>"
    When admin mengirim body dengan products ["TMS"] dan addOns []
    Then respons berstatus 400
    And respons field "$.errors[0].field" berisi "clientId"

    Examples:
      | clientIdInvalid                        | bentuk               |
      | abc123                                 | bukan UUID           |
      | 123                                    | numerik              |
      | 550e8400-e29b-41d4-a716               | UUID terpotong       |
      | 550e8400e29b41d4a716446655440000       | UUID tanpa tanda -   |

  @negative @priority-high @REQ-005 @REQ-006 @REQ-013 @AC-013.1 @AC-013.2 @AC-013.3 @V-07 @V-12 @V-17 @ALT-05 @screen-api-entitlement @OMS000-NEG-007
  Scenario Outline: Nilai enum tidak dikenal pada <field> ditolak 400 secara all-or-nothing
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FTL"]
    And admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    When admin mengirim body dengan field "<field>" berisi <nilai>
    Then respons berstatus 400
    And respons field "$.message" berisi "<field>"
    And respons field "$.errors[0].field" berisi "<field>"
    And admin membaca ulang entitlement client "<clientId>"
    And hasil pembacaan ulang field "$.products" berisi ["TMS"]
    And hasil pembacaan ulang field "$.addOns" berisi ["SERVICE_FTL"]

    Examples:
      | field    | nilai                            | catatan                          |
      | products | ["TMS","XMS"]                    | satu sah satu tidak, all-or-nothing |
      | products | ["LMS"]                          | seluruhnya tidak sah             |
      | addOns   | ["SERVICE_RAIL"]                 | enum add-on tidak dikenal        |
      | addOns   | ["SERVICE_FTL","SERVICE_TRAIN"]  | campuran sah & tidak sah         |

  @negative @priority-high @REQ-014 @AC-014.1 @AC-014.2 @AC-014.3 @V-09 @V-14 @ALT-06 @screen-api-entitlement @OMS000-NEG-008
  Scenario Outline: Enum dengan kapitalisasi salah ditolak 400
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FTL"]
    And admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    When admin mengirim body dengan field "<field>" berisi <nilai>
    Then respons berstatus 400
    And respons field "$.errors[0].field" berisi "<field>"
    And admin membaca ulang entitlement client "<clientId>"
    And hasil pembacaan ulang field "$.products" berisi ["TMS"]

    Examples:
      | field    | nilai              |
      | products | ["tms"]            |
      | products | ["Tms"]            |
      | products | ["oMS"]            |
      | addOns   | ["service_ftl"]    |
      | addOns   | ["Service_FTL"]    |
      | addOns   | ["auto_stuffing"]  |

  @negative @priority-high @REQ-017 @AC-017.1 @AC-017.2 @V-08 @ALT-07 @screen-api-entitlement @OMS000-NEG-009
  Scenario: products array kosong ditolak 400 karena minimal satu produk wajib
    Given entitlement client diset products ["TMS","OMS"] addOns ["SERVICE_FTL"]
    And admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    When admin mengirim body dengan products [] dan addOns ["SERVICE_FTL"]
    Then respons berstatus 400
    And respons field "$.errors[0].field" berisi "products"
    And admin membaca ulang entitlement client "<clientId>"
    And hasil pembacaan ulang field "$.products" berisi ["TMS","OMS"]

  @negative @priority-high @REQ-005 @REQ-006 @V-06 @V-11 @screen-api-entitlement @OMS000-NEG-010
  Scenario Outline: Field <field> bertipe bukan array ditolak 400
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FTL"]
    And admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    When admin mengirim body dengan field "<field>" berisi <nilai>
    Then respons berstatus 400
    And respons field "$.errors[0].field" berisi "<field>"
    And admin membaca ulang entitlement client "<clientId>"
    And hasil pembacaan ulang field "$.products" berisi ["TMS"]

    Examples:
      | field    | nilai                    | tipe   |
      | products | "TMS"                    | string |
      | products | 1                        | angka  |
      | addOns   | "SERVICE_FTL"            | string |
      | addOns   | {"0":"SERVICE_FTL"}      | objek  |

  @negative @priority-medium @REQ-016 @REQ-005 @V-16 @screen-api-entitlement @OMS000-NEG-011
  Scenario Outline: Nilai null atau elemen kosong ditolak 400
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FTL"]
    And admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    When admin mengirim body dengan field "<field>" berisi <nilai>
    Then respons berstatus 400
    And admin membaca ulang entitlement client "<clientId>"
    And hasil pembacaan ulang field "$.addOns" berisi ["SERVICE_FTL"]

    Examples:
      | field    | nilai                 |
      | products | null                  |
      | addOns   | null                  |
      | products | ["TMS",""]            |
      | addOns   | ["SERVICE_FTL",null]  |

  @negative @priority-medium @REQ-001 @AC-001.3 @V-23 @screen-api-entitlement @OMS000-NEG-012
  Scenario Outline: Method <method> pada path entitlement ditolak 405
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FTL"]
    And admin menyiapkan request <method> entitlement untuk client "<clientId>"
    When admin mengirim body dengan products ["OMS"] dan addOns []
    Then respons berstatus 405
    And admin membaca ulang entitlement client "<clientId>"
    And hasil pembacaan ulang field "$.products" berisi ["TMS"]

    Examples:
      | method |
      | POST   |
      | PUT    |
      | DELETE |

  @negative @priority-medium @REQ-001 @AC-001.2 @screen-api-entitlement @OMS000-NEG-013
  Scenario: Path tanpa segmen /entitlement tidak memproses perubahan entitlement
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FTL"]
    And admin menyiapkan request PATCH ke path "/api/v1/service/registry/clients/<clientId>"
    When admin mengirim body dengan products ["OMS"] dan addOns ["SERVICE_FCL"]
    Then respons bukan berstatus 200
    And admin membaca ulang entitlement client "<clientId>"
    And hasil pembacaan ulang field "$.products" berisi ["TMS"]
    And hasil pembacaan ulang field "$.addOns" berisi ["SERVICE_FTL"]

  @negative @priority-medium @REQ-004 @REQ-018 @AC-004.2 @AC-018.1 @V-05 @ALT-11 @screen-api-entitlement @OMS000-NEG-014
  Scenario: Upaya mengubah field selain products dan addOns tidak berpengaruh
    Given admin mencatat atribut client "clientName, status" sebelum request
    And admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    When admin mengirim body dengan field asing {"clientName":"Nama Baru QA","status":"SUSPENDED","products":["TMS"]}
    Then respons berstatus 200
    And sistem menampilkan atribut client "clientName" tidak berubah
    And sistem menampilkan atribut client "status" tidak berubah
    And respons field "$.products" berisi ["TMS"]

  @negative @priority-high @REQ-007 @V-18 @screen-api-entitlement @OMS000-NEG-015
  Scenario: Array yang dikirim tidak ditambahkan ke nilai lama (bukan append)
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FTL","SERVICE_LTL"]
    And admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    When admin mengirim body dengan addOns ["SERVICE_FCL"]
    Then respons berstatus 200
    And sistem tidak menampilkan "SERVICE_FTL" pada field "$.addOns"
    And sistem tidak menampilkan "SERVICE_LTL" pada field "$.addOns"
    And respons field "$.addOns" memiliki tepat 1 elemen

  @negative @priority-high @REQ-008 @AC-008.1 @V-17 @screen-api-entitlement @OMS000-NEG-016
  Scenario: Request gagal tidak mengembalikan 200 dan tidak menulis entitlement sebagian
    Given entitlement client diset products ["TMS","OMS"] addOns ["SERVICE_FCL"]
    And admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    When admin mengirim body dengan products ["OMS","XMS"] dan addOns ["SERVICE_FTL"]
    Then respons bukan berstatus 200
    And sistem tidak menampilkan "$.products" pada body respons sukses
    And admin membaca ulang entitlement client "<clientId>"
    And hasil pembacaan ulang field "$.products" berisi ["TMS","OMS"]
    And hasil pembacaan ulang field "$.addOns" berisi ["SERVICE_FCL"]

  @negative @priority-medium @REQ-015 @AC-015.2 @V-10 @screen-api-entitlement @OMS000-NEG-017
  Scenario: Respons tidak boleh mengembalikan nilai duplikat pada array entitlement
    Given admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    When admin mengirim body dengan products ["OMS","OMS","OMS"] dan addOns ["SERVICE_LCL","SERVICE_LCL"]
    Then respons berstatus 200
    And respons field "$.products" memiliki tepat 1 elemen
    And respons field "$.addOns" memiliki tepat 1 elemen
    And sistem tidak menampilkan nilai duplikat pada field "$.products"

  @negative @priority-medium @REQ-019 @V-22 @V-17 @screen-api-entitlement @OMS000-NEG-018
  Scenario: Request kedua yang tidak valid tidak mengubah hasil request pertama
    Given admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    And admin mengirim body dengan products ["TMS"] dan addOns ["SERVICE_FTL"]
    And respons berstatus 200
    When admin mengirim body dengan products ["TMS"] dan addOns ["SERVICE_FTL","SERVICE_XYZ"]
    Then respons berstatus 400
    And admin membaca ulang entitlement client "<clientId>"
    And hasil pembacaan ulang field "$.addOns" berisi ["SERVICE_FTL"]
    And hasil pembacaan ulang field "$.addOns" memiliki tepat 1 elemen

  @negative @priority-low @REQ-103 @AC-103.3 @screen-api-entitlement @OMS000-NEG-019
  Scenario: Request yang ditolak tidak menghasilkan entri audit perubahan entitlement
    Given admin mencatat jumlah entri audit entitlement client "<clientId>"
    And admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    And admin menyertakan header "X-Admin-Key" dengan "kunci-admin-salah-qa"
    When admin mengirim body dengan products ["OMS"] dan addOns []
    Then respons berstatus 401
    And sistem tidak menampilkan entri audit perubahan baru untuk client "<clientId>"

  # =============================================================================
  # === KATEGORI: NEGATIVE (bagian B) — R2 Penugasan, R3 Shipper, R4 Vendor, R5 ===
  # =============================================================================

  @negative @priority-high @REQ-022 @REQ-024 @AC-024.2 @AC-024.3 @ALT-14 @screen-penugasan-tracking @screen-driver-app @OMS000-NEG-020
  Scenario: OMS-only — penugasan ke Sopir tidak masuk ke aplikasi mobile sopir
    Given entitlement client diset products ["OMS"] addOns ["SERVICE_FTL"]
    And shipper login ulang
    And user berada di halaman "Penugasan Tracking"
    When user mengklik tombol "Tugaskan"
    And user memilih opsi "Sopir" pada field "Tipe Penerima Tugas"
    And user memilih "ORD769797FSH" pada field "Pilih Order"
    And user memilih "Sopir A" pada field "Pilih Sopir"
    And user mengklik tombol "Simpan"
    Then sistem menampilkan "toast-success"
    And daftar tugas sopir "Sopir A" tidak memuat order "ORD769797FSH"
    And daftar tugas sopir "Sopir A" memiliki 0 entri
    And sistem tidak menampilkan push notification penugasan ke sopir "Sopir A"

  @negative @priority-high @REQ-023 @AC-023.1 @screen-penugasan-tracking @screen-driver-app @OMS000-NEG-021
  Scenario: TMS — penugasan ke Pengurus tidak muncul pada daftar tugas sopir
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FTL"]
    And penugasan order "ORD769797FSH" telah diberikan kepada "Pengurus B"
    When daftar tugas sopir "Sopir A" diperiksa melalui API
    Then daftar tugas sopir "Sopir A" tidak memuat order "ORD769797FSH"
    And sistem tidak menampilkan push notification penugasan ke sopir "Sopir A"

  @negative @priority-high @REQ-025 @AC-025.3 @screen-penugasan-tracking @screen-driver-app @OMS000-NEG-022
  Scenario: OMS — penugasan ke Pengurus tidak muncul di apps sopir mana pun
    Given entitlement client diset products ["OMS"] addOns ["SERVICE_LCL"]
    And penugasan order "ORD769797FSH" telah diberikan kepada "Pengurus B"
    When daftar tugas sopir "Sopir A" diperiksa melalui API
    Then daftar tugas sopir "Sopir A" tidak memuat order "ORD769797FSH"
    And sistem tidak menampilkan kanal pelaporan progres dari apps

  @negative @priority-medium @REQ-021 @screen-penugasan-tracking @OMS000-NEG-023
  Scenario: Simpan penugasan tanpa memilih tipe pelaksana ditolak dengan pesan validasi
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FTL"]
    And shipper login ulang
    And user berada di halaman "Penugasan Tracking"
    When user mengklik tombol "Tugaskan"
    And user memilih "ORD769797FSH" pada field "Pilih Order"
    And user mengklik tombol "Simpan"
    Then sistem menampilkan "assignment-form-error"
    And sistem menampilkan pesan "/(harus diisi|wajib diisi|tidak boleh kosong)/i"
    And sistem tidak menampilkan "toast-success"
    And user tidak diarahkan ke halaman "Penugasan Tracking"

  @negative @priority-high @REQ-026 @AC-026.1 @ALT-15 @screen-penugasan-tracking @screen-driver-app @OMS000-NEG-024
  Scenario: Gabungan TMS+OMS tidak boleh berperilaku OMS — daftar tugas sopir tidak boleh kosong
    Given entitlement client diset products ["TMS","OMS"] addOns ["SERVICE_FTL","SERVICE_FCL"]
    And penugasan order "ORD888111OMS" telah diberikan kepada "Sopir A"
    When daftar tugas sopir "Sopir A" diperiksa melalui API
    Then daftar tugas sopir "Sopir A" tidak memiliki 0 entri
    And daftar tugas sopir "Sopir A" memuat order "ORD888111OMS"

  @negative @priority-high @REQ-027 @AC-027.2 @screen-driver-app @screen-error @OMS000-NEG-025
  Scenario: OMS-only — pelaporan progres dari apps sopir ditolak sistem
    Given entitlement client diset products ["OMS"] addOns ["SERVICE_FTL"]
    And penugasan order "ORD769797FSH" telah diberikan kepada "Sopir A"
    When sopir "Sopir A" mencoba melaporkan progres "Selesai Muat" dari aplikasi
    Then respons berstatus 403
    And sistem tidak menampilkan entri timeline bersumber apps pada order "ORD769797FSH"
    And sistem menampilkan "tracking-input-form" sebagai satu-satunya kanal

  @negative @priority-medium @REQ-020 @REQ-037 @REQ-101 @AC-101.3 @screen-sidebar-shipper @screen-error @OMS000-NEG-026
  Scenario: Client tanpa produk aktif tidak menampilkan menu Penugasan Tracking dan menolak deep-link
    Given entitlement client legacy tidak memiliki produk aktif
    And shipper login ulang
    When user berada di halaman "Sidebar Shipper"
    Then sistem tidak menampilkan "nav-item-penugasan-tracking"
    And user membuka URL "/penugasan-tracking"
    And sistem tidak menampilkan "assignment-page"
    And sistem menampilkan "error-403-page"

  @negative @priority-high @REQ-028 @AC-028.3 @ALT-27 @screen-penugasan-tracking @screen-driver-app @OMS000-NEG-027
  Scenario: Penugasan baru setelah produk berubah ke OMS tidak lagi masuk apps sopir
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FTL"]
    And penugasan order "ORD111LAMA" telah diberikan kepada "Sopir A"
    And daftar tugas sopir "Sopir A" memuat order "ORD111LAMA"
    When entitlement client diset products ["OMS"] addOns ["SERVICE_FTL"]
    And shipper login ulang
    And penugasan order "ORD222BARU" telah diberikan kepada "Sopir A"
    Then daftar tugas sopir "Sopir A" tidak memuat order "ORD222BARU"
    And sistem menampilkan baris penugasan order "ORD111LAMA"

  @negative @priority-high @REQ-052 @AC-052.3 @screen-penugasan-tracking @screen-sidebar-vendor @screen-driver-app @OMS000-NEG-028
  Scenario: Vendor pada client OMS menugaskan sopir namun penugasan tidak masuk apps
    Given entitlement client diset products ["OMS"] addOns ["SERVICE_FCL"]
    And vendor login ulang
    And user berada di halaman "Penugasan Tracking"
    When user mengklik tombol "Tugaskan"
    And user memilih opsi "Sopir" pada field "Tipe Penerima Tugas"
    And user memilih "ORD553311VND" pada field "Pilih Order"
    And user memilih "Sopir V1" pada field "Pilih Sopir"
    And user mengklik tombol "Simpan"
    Then sistem menampilkan "toast-success"
    And daftar tugas sopir "Sopir V1" tidak memuat order "ORD553311VND"

  @negative @priority-high @REQ-029 @REQ-031 @REQ-032 @REQ-034 @REQ-036 @REQ-039 @REQ-041 @REQ-042 @AC-029.1 @AC-029.2 @AC-031.2 @AC-034.1 @AC-039.1 @screen-sidebar-shipper @screen-error @OMS000-NEG-029
  Scenario Outline: Menu Shipper "<menu>" tidak dirender pada state <state> dan route-nya dijaga
    Given entitlement client diset products <products> addOns <addOns>
    And shipper login ulang
    And user membuka grup menu "MASTER OPERASIONAL"
    When user berada di halaman "Sidebar Shipper"
    Then sistem tidak menampilkan "<testid>"
    And user membuka URL "<route>"
    And sistem tidak menampilkan "<contentTestid>"
    And sistem menampilkan "error-403-page"

    Examples: TMS-only — menu eksklusif OMS absen
      | menu                            | testid                                 | route              | contentTestid              | products | addOns                            | state    |
      | Dashboard - Distribusi & Muatan | nav-item-dashboard-distribusi-muatan   | /dashboard         | dashboard-tab-distribusi-muatan | ["TMS"]  | ["AUTO_STUFFING","SERVICE_FTL"]   | TMS-only |
      | Master Barang                   | nav-item-master-barang                 | /master-barang     | master-barang-table        | ["TMS"]  | ["AUTO_STUFFING","SERVICE_FTL"]   | TMS-only |
      | Simulasi Muatan                 | nav-item-simulasi-muatan               | /simulasi-muatan   | simulasi-muatan-page       | ["TMS"]  | ["AUTO_STUFFING","SERVICE_FTL"]   | TMS-only |

    Examples: OMS-only — menu eksklusif TMS absen
      | menu                            | testid                                 | route              | contentTestid                        | products | addOns                            | state    |
      | Dashboard - Tracking & Location | nav-item-dashboard-tracking-location   | /dashboard         | dashboard-tab-tracking-location      | ["OMS"]  | ["SERVICE_FTL","SERVICE_FCL"]     | OMS-only |
      | Dashboard - Progress Pengiriman | nav-item-dashboard-progress-pengiriman | /dashboard         | dashboard-tab-progress-pengiriman    | ["OMS"]  | ["SERVICE_FTL","SERVICE_FCL"]     | OMS-only |

    Examples: Moda darat saja — menu bergantung moda laut absen
      | menu             | testid                     | route              | contentTestid            | products      | addOns                          | state          |
      | Master Pelabuhan | nav-item-master-pelabuhan  | /master-pelabuhan  | master-pelabuhan-table   | ["TMS","OMS"] | ["SERVICE_FTL","SERVICE_LTL"]   | darat saja     |
      | Master Pelayaran | nav-item-master-pelayaran  | /master-pelayaran  | master-pelayaran-table   | ["TMS","OMS"] | ["SERVICE_FTL","SERVICE_LTL"]   | darat saja     |

    Examples: OMS tanpa AUTO_STUFFING — Simulasi Muatan absen
      | menu            | testid                    | route             | contentTestid         | products | addOns              | state         |
      | Simulasi Muatan | nav-item-simulasi-muatan  | /simulasi-muatan  | simulasi-muatan-page  | ["OMS"]  | ["SERVICE_FCL"]     | tanpa stuffing |

  @negative @priority-high @REQ-036 @REQ-076 @AC-036.3 @ALT-24 @V-20 @screen-sidebar-shipper @screen-error @OMS000-NEG-030
  Scenario: AUTO_STUFFING aktif tanpa produk OMS tidak memunculkan Simulasi Muatan
    Given entitlement client diset products ["TMS"] addOns ["AUTO_STUFFING","SERVICE_FTL"]
    And shipper login ulang
    When user berada di halaman "Sidebar Shipper"
    Then sistem tidak menampilkan "nav-item-simulasi-muatan"
    And user membuka URL "/simulasi-muatan"
    And sistem tidak menampilkan "simulasi-muatan-page"
    And sistem menampilkan "error-403-page"

  @negative @priority-medium @REQ-030 @REQ-033 @REQ-035 @REQ-038 @REQ-040 @REQ-043 @REQ-044 @REQ-045 @REQ-046 @REQ-047 @REQ-048 @REQ-049 @REQ-101 @AC-101.2 @AC-101.3 @screen-sidebar-shipper @screen-error @OMS000-NEG-031
  Scenario Outline: Tanpa produk aktif, menu operasional "<menu>" tidak tampil dan aksesnya ditolak
    Given entitlement client legacy tidak memiliki produk aktif
    And shipper login ulang
    When user berada di halaman "Sidebar Shipper"
    Then sistem tidak menampilkan "<testid>"
    And user membuka URL "<route>"
    And sistem menampilkan "error-403-page"

    Examples:
      | menu                    | testid                          | route              |
      | Dashboard - Monitoring  | nav-item-dashboard-monitoring   | /dashboard         |
      | Dashboard - Operasional | nav-item-dashboard-operasional  | /dashboard         |
      | Order                   | nav-item-order                  | /order             |
      | Master Wilayah          | nav-item-master-wilayah         | /master-wilayah    |
      | Master Drop Point       | nav-item-master-drop-point      | /master-drop-point |
      | Master Unit             | nav-item-master-unit            | /master-unit       |
      | Master Sopir            | nav-item-master-sopir           | /master-sopir      |
      | Manajemen Vendor        | nav-item-manajemen-vendor       | /manajemen-vendor  |
      | Pengaturan Sistem       | nav-item-pengaturan-sistem      | /pengaturan-sistem |

  @negative @priority-medium @REQ-046 @REQ-047 @REQ-049 @REQ-101 @AC-101.2 @screen-sidebar-shipper @OMS000-NEG-032
  Scenario: Tanpa produk aktif, hanya tiga menu non-operasional yang tersisa
    Given entitlement client legacy tidak memiliki produk aktif
    And shipper login ulang
    When user berada di halaman "Sidebar Shipper"
    Then sistem menampilkan "nav-item-pengaturan-akun"
    And sistem menampilkan "nav-item-akun-saya"
    And sistem menampilkan "nav-item-pusat-notifikasi"
    And sistem tidak menampilkan "nav-item-penugasan-tracking"
    And sistem tidak menampilkan "nav-item-master-barang"

  @negative @priority-high @REQ-031 @REQ-034 @AC-031.2 @AC-034.1 @screen-dashboard @OMS000-NEG-033
  Scenario Outline: Tab Dashboard "<tab>" tidak dirender pada state <state>
    Given entitlement client diset products <products> addOns ["SERVICE_FTL","SERVICE_FCL"]
    And shipper login ulang
    When user berada di halaman "Dashboard Shipper"
    Then sistem menampilkan "dashboard-tabs"
    And sistem tidak menampilkan "<testid>"
    And user membuka URL "/dashboard#<anchor>"
    And sistem tidak menampilkan konten tab "<tab>"

    Examples:
      | tab                 | testid                            | anchor              | products | state    |
      | Tracking & Location | dashboard-tab-tracking-location   | tracking-location   | ["OMS"]  | OMS-only |
      | Progress Pengiriman | dashboard-tab-progress-pengiriman | progress-pengiriman | ["OMS"]  | OMS-only |
      | Distribusi & Muatan | dashboard-tab-distribusi-muatan   | distribusi-muatan   | ["TMS"]  | TMS-only |

  @negative @priority-high @REQ-032 @REQ-072 @REQ-074 @AC-032.2 @AC-074.3 @screen-dashboard @OMS000-NEG-034
  Scenario: OMS dengan moda darat tetap tidak menampilkan Dashboard - Progress Pengiriman
    Given entitlement client diset products ["OMS"] addOns ["SERVICE_FTL","SERVICE_LTL"]
    And shipper login ulang
    When user berada di halaman "Dashboard Shipper"
    Then sistem menampilkan "dashboard-tabs"
    And sistem tidak menampilkan "dashboard-tab-progress-pengiriman"
    And sistem menampilkan "dashboard-tab-distribusi-muatan"

  @negative @priority-medium @REQ-057 @AC-057.1 @screen-sidebar-vendor @OMS000-NEG-035
  Scenario Outline: Sidebar Vendor tidak memuat menu eksklusif Shipper "<menu>"
    Given entitlement client diset products ["TMS","OMS"] addOns ["AUTO_STUFFING","SERVICE_FTL","SERVICE_FCL"]
    And vendor login ulang
    When user berada di halaman "Sidebar Vendor"
    Then sistem menampilkan "sidebar-vendor"
    And sistem tidak menampilkan "<testid>"

    Examples:
      | menu              | testid                       |
      | Manajemen Vendor  | nav-item-manajemen-vendor    |
      | Pengaturan Sistem | nav-item-pengaturan-sistem   |
      | Master Barang     | nav-item-master-barang       |
      | Simulasi Muatan   | nav-item-simulasi-muatan     |
      | Master Wilayah    | nav-item-master-wilayah      |
      | Master Pelabuhan  | nav-item-master-pelabuhan    |
      | Master Pelayaran  | nav-item-master-pelayaran    |
      | Master Drop Point | nav-item-master-drop-point   |
      | Dashboard Shipper | dashboard-tabs               |

  @negative @priority-medium @REQ-057 @AC-057.2 @screen-sidebar-vendor @screen-error @OMS000-NEG-036
  Scenario Outline: Deep-link menu Shipper oleh user Vendor ditolak
    Given entitlement client diset products ["TMS","OMS"] addOns ["AUTO_STUFFING","SERVICE_FTL","SERVICE_FCL"]
    And vendor login ulang
    When user membuka URL "<route>"
    Then sistem tidak menampilkan "<contentTestid>"
    And sistem menampilkan "error-403-page"
    And user diarahkan ke halaman "Halaman Error"

    Examples:
      | route              | contentTestid           |
      | /manajemen-vendor  | manajemen-vendor-page   |
      | /pengaturan-sistem | system-settings-list    |
      | /master-barang     | master-barang-table     |
      | /simulasi-muatan   | simulasi-muatan-page    |
      | /master-pelabuhan  | master-pelabuhan-table  |

  @negative @priority-high @REQ-050 @REQ-051 @REQ-052 @REQ-053 @REQ-054 @REQ-055 @REQ-056 @AC-050.2 @ALT-26 @screen-sidebar-vendor @OMS000-NEG-037
  Scenario Outline: Menu Vendor "<menu>" tidak hilang meskipun entitlement client diubah ke <state>
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FTL","SERVICE_FCL"]
    And vendor login ulang
    And sistem menampilkan "<testid>"
    When entitlement client diset products <products> addOns <addOns>
    And user memuat ulang halaman
    Then sistem menampilkan "<testid>"
    And sistem menampilkan "sidebar-vendor" berisi 6 item

    Examples:
      | menu               | testid                       | products | addOns              | state             |
      | Order              | nav-item-order               | ["OMS"]  | []                  | OMS tanpa add-on  |
      | Penugasan Tracking | nav-item-penugasan-tracking  | ["OMS"]  | []                  | OMS tanpa add-on  |
      | Master Armada      | nav-item-master-armada       | ["OMS"]  | ["SERVICE_LCL"]     | OMS moda laut     |
      | Master Sopir       | nav-item-master-sopir        | ["OMS"]  | ["SERVICE_LCL"]     | OMS moda laut     |
      | Akun Saya          | nav-item-akun-saya           | ["OMS"]  | ["AUTO_STUFFING"]   | OMS stuffing saja |
      | Pusat Notifikasi   | nav-item-pusat-notifikasi    | ["OMS"]  | ["AUTO_STUFFING"]   | OMS stuffing saja |

  @negative @priority-medium @REQ-050 @screen-sidebar-vendor @OMS000-NEG-038
  Scenario: Sidebar Vendor tidak berubah ketika seluruh add-on dicabut
    Given entitlement client diset products ["TMS","OMS"] addOns ["AUTO_STUFFING","SERVICE_FTL","SERVICE_FCL","SERVICE_AIR_FREIGHT"]
    And vendor login ulang
    And user mencatat daftar label pada "sidebar-vendor"
    When entitlement client diset products ["TMS","OMS"] addOns []
    And user memuat ulang halaman
    Then sistem menampilkan "sidebar-vendor" berisi 6 item
    And sistem menampilkan daftar label identik dengan catatan sebelumnya
    And sistem tidak menampilkan "nav-item-master-pelabuhan"

  @negative @priority-high @REQ-058 @REQ-060 @REQ-061 @REQ-062 @REQ-063 @REQ-064 @REQ-066 @REQ-068 @AC-058.2 @AC-060.2 @AC-061.2 @AC-062.2 @AC-063.2 @AC-064.2 @AC-066.2 @AC-068.3 @screen-pengaturan-sistem @screen-error @OMS000-NEG-039
  Scenario Outline: OMS-only — item Pengaturan Sistem "<item>" tidak tampil dan aksesnya ditolak
    Given entitlement client diset products ["OMS"] addOns ["SERVICE_FCL"]
    And shipper login ulang
    When user berada di halaman "Pengaturan Sistem"
    Then sistem menampilkan "system-settings-list" berisi 2 item
    And sistem tidak menampilkan "<testid>"
    And user membuka URL "/pengaturan-sistem/<slug>"
    And sistem tidak menampilkan "<testid>"
    And sistem menampilkan "error-403-page"

    Examples:
      | item                               | testid                                    | slug                          |
      | Notifikasi Lokasi                  | setting-item-notifikasi-lokasi            | notifikasi-lokasi             |
      | Deteksi Tidak Update               | setting-item-deteksi-tidak-update         | deteksi-tidak-update          |
      | Deteksi Keluar Jalur               | setting-item-deteksi-keluar-jalur         | deteksi-keluar-jalur          |
      | Koridor Historis                   | setting-item-koridor-historis             | koridor-historis              |
      | Notifikasi Dini Berisiko Terlambat | setting-item-notifikasi-dini-terlambat    | notifikasi-dini-terlambat     |
      | Pembatasan Kelayakan Armada        | setting-item-pembatasan-kelayakan-armada  | pembatasan-kelayakan-armada   |

  @negative @priority-high @REQ-067 @AC-067.1 @screen-pengaturan-sistem @OMS000-NEG-040
  Scenario: Gabungan TMS+OMS tidak boleh menyusut menjadi 2 item Pengaturan Sistem
    Given entitlement client diset products ["OMS"] addOns ["SERVICE_FCL"]
    And shipper login ulang
    And sistem menampilkan "system-settings-list" berisi 2 item
    When entitlement client diset products ["TMS","OMS"] addOns ["SERVICE_FCL"]
    And user memuat ulang halaman
    Then sistem tidak menampilkan "system-settings-list" berisi 2 item
    And sistem menampilkan "system-settings-list" berisi 8 item
    And sistem menampilkan "setting-item-pembatasan-kelayakan-armada"

  @negative @priority-medium @REQ-059 @REQ-065 @REQ-101 @AC-101.3 @screen-pengaturan-sistem @screen-error @OMS000-NEG-041
  Scenario: Tanpa produk aktif, halaman Pengaturan Sistem tidak dapat diakses
    Given entitlement client legacy tidak memiliki produk aktif
    And shipper login ulang
    When user membuka URL "/pengaturan-sistem"
    Then sistem tidak menampilkan "system-settings-list"
    And sistem tidak menampilkan "setting-item-durasi-undangan-vendor"
    And sistem tidak menampilkan "setting-item-nomor-whatsapp-cs"
    And sistem menampilkan "error-403-page"

  # ==========================================================================
  # === KATEGORI: NEGATIVE (bagian C) — R6 Add-on, R7 TMS LKL, R8 Propagasi ===
  # ==========================================================================

  @negative @priority-high @REQ-069 @REQ-075 @AC-075.2 @V-21 @ALT-20 @screen-sidebar-shipper @screen-dashboard @OMS000-NEG-042
  Scenario: Hanya AUTO_STUFFING aktif tidak mengaktifkan moda apa pun
    Given entitlement client diset products ["TMS","OMS"] addOns ["AUTO_STUFFING"]
    And shipper login ulang
    And user membuka grup menu "MASTER OPERASIONAL"
    When user berada di halaman "Sidebar Shipper"
    Then sistem tidak menampilkan "nav-item-master-pelabuhan"
    And sistem tidak menampilkan "nav-item-master-pelayaran"
    And user berada di halaman "Dashboard Shipper"
    And sistem tidak menampilkan "dashboard-tab-progress-pengiriman"
    And sistem menampilkan "nav-item-simulasi-muatan"

  @negative @priority-high @REQ-070 @REQ-071 @REQ-096 @REQ-097 @AC-070.1 @AC-071.1 @AC-096.1 @AC-097.1 @UF-4 @screen-master-moda @screen-error @OMS000-NEG-043
  Scenario: Moda darat saja — Master Pelabuhan & Master Pelayaran hilang dan API-nya menolak 403
    Given entitlement client diset products ["TMS","OMS"] addOns ["SERVICE_FTL","SERVICE_LTL"]
    And shipper login ulang
    And user membuka grup menu "MASTER OPERASIONAL"
    When user berada di halaman "Sidebar Shipper"
    Then sistem tidak menampilkan "nav-item-master-pelabuhan"
    And sistem tidak menampilkan "nav-item-master-pelayaran"
    And user membuka URL "/master-pelabuhan"
    And sistem tidak menampilkan "master-pelabuhan-table"
    And sistem menampilkan "error-403-page"
    And user memanggil API fitur "master-pelabuhan" dengan token shipper
    And respons berstatus 403

  @negative @priority-high @REQ-072 @AC-072.2 @ALT-18 @screen-dashboard @screen-error @OMS000-NEG-044
  Scenario: Moda laut saja — Dashboard - Progress Pengiriman hilang pada client TMS
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FCL","SERVICE_LCL"]
    And shipper login ulang
    When user berada di halaman "Dashboard Shipper"
    Then sistem menampilkan "dashboard-tabs"
    And sistem tidak menampilkan "dashboard-tab-progress-pengiriman"
    And sistem menampilkan "dashboard-tab-tracking-location"

  @negative @priority-medium @REQ-073 @AC-073.1 @screen-sidebar-shipper @screen-dashboard @OMS000-NEG-045
  Scenario: Satu moda saja tidak memunculkan ketiga fitur matriks jenis pengiriman sekaligus
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FCL"]
    And shipper login ulang
    And user membuka grup menu "MASTER OPERASIONAL"
    When user berada di halaman "Sidebar Shipper"
    Then sistem menampilkan "nav-item-master-pelabuhan"
    And sistem menampilkan "nav-item-master-pelayaran"
    And user berada di halaman "Dashboard Shipper"
    And sistem tidak menampilkan "dashboard-tab-progress-pengiriman"

  @negative @priority-high @REQ-074 @AC-074.1 @screen-sidebar-shipper @screen-master-moda @screen-error @OMS000-NEG-046
  Scenario: Filter AND gagal — OMS-only dengan moda darat tidak menampilkan Master Pelabuhan
    Given entitlement client diset products ["OMS"] addOns ["SERVICE_FTL"]
    And shipper login ulang
    And user membuka grup menu "MASTER OPERASIONAL"
    When user berada di halaman "Sidebar Shipper"
    Then sistem tidak menampilkan "nav-item-master-pelabuhan"
    And sistem menampilkan "nav-item-master-barang"
    And user membuka URL "/master-pelabuhan"
    And sistem tidak menampilkan "master-pelabuhan-table"
    And sistem menampilkan "error-403-page"

  @negative @priority-high @REQ-076 @AC-076.2 @ALT-23 @screen-master-moda @screen-error @OMS000-NEG-047
  Scenario: OMS tanpa AUTO_STUFFING menolak akses langsung ke Simulasi Muatan
    Given entitlement client diset products ["OMS"] addOns ["SERVICE_FTL","SERVICE_FCL"]
    And shipper login ulang
    When user berada di halaman "Sidebar Shipper"
    Then sistem tidak menampilkan "nav-item-simulasi-muatan"
    And user membuka URL "/simulasi-muatan"
    And sistem tidak menampilkan "simulasi-muatan-page"
    And sistem menampilkan "error-403-page"
    And user memanggil API fitur "simulasi-muatan" dengan token shipper
    And respons berstatus 403

  @negative @priority-medium @REQ-077 @AC-077.1 @screen-form-order @OMS000-NEG-048
  Scenario Outline: Opsi jenis pengiriman "<jenis>" tidak dirender ketika add-on padanannya tidak aktif
    Given entitlement client diset products ["OMS"] addOns ["SERVICE_FTL"]
    And shipper login ulang
    And user berada di halaman "Form Order"
    When user mengklik tombol "Buat Order"
    Then sistem menampilkan "order-type-ftl"
    And sistem tidak menampilkan "<testid>"

    Examples:
      | jenis       | testid                 |
      | LTL         | order-type-ltl         |
      | FCL         | order-type-fcl         |
      | LCL         | order-type-lcl         |
      | Air Freight | order-type-air-freight |

  @negative @priority-high @REQ-079 @REQ-082 @REQ-087 @REQ-088 @REQ-089 @REQ-090 @AC-079.2 @AC-079.3 @AC-082.2 @AC-082.3 @AC-087.2 @AC-087.3 @AC-088.2 @AC-088.3 @AC-089.3 @AC-090.2 @screen-nav-lkl @screen-error @OMS000-NEG-049
  Scenario Outline: Menu TMS LKL "<menu>" tidak dirender pada moda <moda>
    Given entitlement client diset products ["TMS"] addOns <addOns>
    And shipper login ulang
    And user membuka grup menu "MASTER OPERASIONAL"
    When user berada di halaman "Navigasi TMS LKL"
    Then sistem tidak menampilkan "<testid>"
    And user membuka URL "<route>"
    And sistem menampilkan "error-403-page"

    Examples: Moda Laut saja
      | menu                   | testid                          | route          | addOns            | moda |
      | Dashboard - Monitoring | nav-item-dashboard-monitoring   | /dashboard     | ["SERVICE_FCL"]   | Laut |
      | Otomasi Jalur          | nav-item-otomasi-jalur          | /otomasi-jalur | ["SERVICE_FCL"]   | Laut |
      | Master Bandara         | nav-item-master-bandara         | /master-bandara | ["SERVICE_FCL"]  | Laut |
      | Master Maskapai        | nav-item-master-maskapai        | /master-maskapai | ["SERVICE_FCL"] | Laut |

    Examples: Moda Darat saja
      | menu             | testid                     | route             | addOns            | moda  |
      | Master Pelabuhan | nav-item-master-pelabuhan  | /master-pelabuhan | ["SERVICE_FTL"]   | Darat |
      | Master Pelayaran | nav-item-master-pelayaran  | /master-pelayaran | ["SERVICE_FTL"]   | Darat |
      | Master Bandara   | nav-item-master-bandara    | /master-bandara   | ["SERVICE_FTL"]   | Darat |
      | Master Maskapai  | nav-item-master-maskapai   | /master-maskapai  | ["SERVICE_FTL"]   | Darat |

    Examples: Moda Udara saja
      | menu                   | testid                          | route             | addOns                     | moda  |
      | Dashboard - Monitoring | nav-item-dashboard-monitoring   | /dashboard        | ["SERVICE_AIR_FREIGHT"]    | Udara |
      | Otomasi Jalur          | nav-item-otomasi-jalur          | /otomasi-jalur    | ["SERVICE_AIR_FREIGHT"]    | Udara |
      | Master Pelabuhan       | nav-item-master-pelabuhan       | /master-pelabuhan | ["SERVICE_AIR_FREIGHT"]    | Udara |
      | Master Pelayaran       | nav-item-master-pelayaran       | /master-pelayaran | ["SERVICE_AIR_FREIGHT"]    | Udara |

  @negative @priority-high @REQ-085 @AC-085.3 @AC-085.4 @ALT-22 @screen-nav-lkl @OMS000-NEG-050
  Scenario Outline: Tanpa tipe pengiriman Less, tab Tarif Pengiriman & Konversi Muatan tidak tampil
    Given entitlement client diset products ["TMS"] addOns <addOns>
    And shipper login ulang
    And user berada di halaman "Navigasi TMS LKL"
    When user mengklik menu "Master Rute"
    Then sistem menampilkan "master-rute-tabs"
    And sistem tidak menampilkan "master-rute-tab-tarif-pengiriman"
    And sistem tidak menampilkan "master-rute-tab-konversi-muatan"

    Examples:
      | addOns                          | kondisi              |
      | ["SERVICE_FTL"]                 | FTL saja             |
      | ["SERVICE_FCL"]                 | FCL saja             |
      | ["SERVICE_FTL","SERVICE_FCL"]   | FTL+FCL tanpa Less   |
      | ["SERVICE_AIR_FREIGHT"]         | Udara saja           |

  @negative @priority-medium @REQ-078 @REQ-080 @REQ-081 @REQ-083 @REQ-084 @REQ-086 @REQ-091 @REQ-092 @REQ-093 @REQ-101 @screen-nav-lkl @screen-error @OMS000-NEG-051
  Scenario Outline: Tanpa produk aktif, menu TMS LKL "<menu>" tidak tampil dan aksesnya ditolak
    Given entitlement client legacy tidak memiliki produk aktif
    And shipper login ulang
    When user berada di halaman "Navigasi TMS LKL"
    Then sistem tidak menampilkan "<testid>"
    And user membuka URL "<route>"
    And sistem menampilkan "error-403-page"

    Examples:
      | menu                            | testid                                | route               |
      | Dashboard - Tracking & Location | nav-item-dashboard-tracking-location  | /dashboard          |
      | Dashboard - Operasional         | nav-item-dashboard-operasional        | /dashboard          |
      | Shipment                        | nav-item-shipment                     | /shipment           |
      | Order                           | nav-item-order                        | /order              |
      | Penugasan Tracking              | nav-item-penugasan-tracking           | /penugasan-tracking |
      | Master Wilayah                  | nav-item-master-wilayah               | /master-wilayah     |
      | Master Rute                     | nav-item-master-rute                  | /master-rute        |
      | Master Customer                 | nav-item-master-customer              | /master-customer    |
      | Master Drop Point               | nav-item-master-drop-point            | /master-drop-point  |
      | Master Unit & Sopir             | nav-item-master-unit-sopir            | /master-unit-sopir  |
      | Master Kemasan                  | nav-item-master-kemasan               | /master-kemasan     |
      | Master Bank                     | nav-item-master-bank                  | /master-bank        |
      | Manajemen Invoice               | nav-item-manajemen-invoice            | /manajemen-invoice  |
      | Laporan Keuangan                | nav-item-laporan-keuangan             | /laporan-keuangan   |

  @negative @priority-high @REQ-094 @AC-094.2 @screen-nav-lkl @OMS000-NEG-052
  Scenario: Kombinasi Darat+Udara tetap tidak memunculkan Master Pelabuhan dan Master Pelayaran
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FTL","SERVICE_AIR_FREIGHT"]
    And shipper login ulang
    And user membuka grup menu "MASTER OPERASIONAL"
    When user berada di halaman "Navigasi TMS LKL"
    Then sistem menampilkan "nav-item-master-bandara"
    And sistem menampilkan "nav-item-master-maskapai"
    And sistem tidak menampilkan "nav-item-master-pelabuhan"
    And sistem tidak menampilkan "nav-item-master-pelayaran"

  @negative @priority-high @REQ-095 @REQ-097 @ALT-12 @screen-sidebar-shipper @screen-error @OMS000-NEG-053
  Scenario: Tanpa refresh, menu lama boleh tampil namun aksi ke fitur non-entitle sudah ditolak
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FCL"]
    And shipper login ulang
    And user membuka grup menu "MASTER OPERASIONAL"
    And sistem menampilkan "nav-item-master-pelabuhan"
    When entitlement client diset products ["TMS"] addOns ["SERVICE_FTL"]
    And user mengklik menu "Master Pelabuhan" tanpa memuat ulang halaman
    Then sistem tidak menampilkan "master-pelabuhan-table"
    And sistem menampilkan "error-403-page"
    And user memuat ulang halaman
    And sistem tidak menampilkan "nav-item-master-pelabuhan"

  @negative @priority-high @REQ-096 @AC-096.1 @AC-096.2 @ALT-13 @screen-master-moda @screen-error @OMS000-NEG-054
  Scenario Outline: Deep-link ke halaman dan sub-halaman fitur non-entitle ditolak
    Given entitlement client diset products ["OMS"] addOns ["SERVICE_FTL"]
    And shipper login ulang
    When user membuka URL "<route>"
    Then sistem tidak menampilkan "master-pelabuhan-table"
    And sistem tidak menampilkan "master-pelabuhan-page"
    And sistem menampilkan "error-403-page"

    Examples:
      | route                                            | bentuk        |
      | /master-pelabuhan                                | halaman list  |
      | /master-pelabuhan/create                         | form tambah   |
      | /master-pelabuhan/1f0f8f6c-6a1f-4d0e-9d4d-01     | detail        |
      | /master-pelabuhan?page=2&search=priok            | dengan query  |

  @negative @priority-high @REQ-097 @AC-097.1 @AC-097.2 @screen-error @screen-api-entitlement @OMS000-NEG-055
  Scenario: Panggilan API fitur non-entitle ditolak 403 dan tidak membocorkan data
    Given entitlement client diset products ["OMS"] addOns ["SERVICE_FTL"]
    And shipper login ulang
    When user memanggil API fitur "master-pelayaran" dengan token shipper
    Then respons berstatus 403
    And sistem tidak menampilkan "$.data" pada body respons
    And sistem tidak menampilkan data master pelayaran pada respons halaman lain

  @negative @priority-high @REQ-098 @AC-098.1 @AC-098.3 @UF-5 @screen-master-moda @OMS000-NEG-056
  Scenario: Pencabutan add-on tidak menghapus data master yang sudah tersimpan
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FCL"]
    And user mencatat "master-pelayaran-pagination-info" pada halaman "Master Pelayaran"
    When entitlement client diset products ["TMS"] addOns ["SERVICE_FTL"]
    And shipper login ulang
    Then sistem tidak menampilkan "nav-item-master-pelayaran"
    And sistem menampilkan jumlah record master pelayaran tidak berkurang
    And sistem tidak menampilkan notifikasi penghapusan data

  @negative @priority-high @REQ-099 @AC-099.2 @UF-5 @screen-master-moda @OMS000-NEG-057
  Scenario: Reaktivasi add-on tidak boleh menghasilkan halaman master kosong
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FCL"]
    And user mencatat "master-pelabuhan-pagination-info" pada halaman "Master Pelabuhan"
    And entitlement client diset products ["TMS"] addOns []
    And shipper login ulang
    When entitlement client diset products ["TMS"] addOns ["SERVICE_FCL"]
    And shipper login ulang
    And user membuka URL "/master-pelabuhan"
    Then sistem tidak menampilkan "master-pelabuhan-empty"
    And sistem menampilkan "master-pelabuhan-pagination-info" identik dengan catatan sebelumnya

  @negative @priority-medium @REQ-100 @AC-100.2 @AC-100.3 @ALT-25 @screen-penugasan-tracking @OMS000-NEG-058
  Scenario: Perubahan entitlement tidak membatalkan order dan penugasan yang sedang berjalan
    Given entitlement client diset products ["TMS","OMS"] addOns ["SERVICE_FTL","SERVICE_FCL"]
    And order "ORD769797FSH" berstatus "Ditugaskan"
    When entitlement client diset products ["OMS"] addOns []
    And shipper login ulang
    And user berada di halaman "Penugasan Tracking"
    Then sistem tidak menampilkan status "Dibatalkan" pada order "ORD769797FSH"
    And sistem menampilkan "assignment-row-status" berisi "Ditugaskan"
    And sistem tidak menampilkan halaman kosong pada detail order "ORD769797FSH"

  @negative @priority-medium @REQ-101 @AC-101.1 @AC-101.3 @screen-login @screen-error @OMS000-NEG-059
  Scenario: Client tanpa produk aktif tidak boleh gagal login namun akses operasionalnya ditolak
    Given entitlement client legacy tidak memiliki produk aktif
    And user berada di halaman "Login"
    When user mengisi field "Email" dengan "shipper.qa@prahu-hub.test"
    And user mengisi field "Kata Sandi" dengan "${SHIPPER_PASSWORD}"
    And user mengklik tombol "Masuk"
    Then sistem tidak menampilkan "login-error"
    And user membuka URL "/order"
    And sistem tidak menampilkan "order-list-create"
    And sistem menampilkan "error-403-page"

  @negative @priority-high @REQ-102 @AC-102.2 @AC-102.3 @screen-driver-app @screen-sidebar-vendor @screen-sidebar-shipper @OMS000-NEG-060
  Scenario: Tidak ada kanal yang menampilkan fitur di luar entitlement
    Given entitlement client diset products ["OMS"] addOns ["SERVICE_FTL"]
    And penugasan order "ORD769797FSH" telah diberikan kepada "Sopir A"
    When daftar tugas sopir "Sopir A" diperiksa melalui API
    Then daftar tugas sopir "Sopir A" tidak memuat order "ORD769797FSH"
    And shipper login ulang
    And sistem tidak menampilkan "nav-item-master-pelabuhan"
    And vendor login ulang
    And sistem tidak menampilkan "nav-item-master-pelabuhan"

  # =====================================================================
  # === KATEGORI: EDGE (bagian A) — boundary & kontrak API entitlement ===
  # =====================================================================

  @edge @priority-high @REQ-005 @REQ-017 @V-08 @screen-api-entitlement @OMS000-EDG-001
  Scenario: Boundary minItems — products dengan tepat satu elemen diterima
    Given admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    When admin mengirim body dengan products ["OMS"] dan addOns []
    Then respons berstatus 200
    And respons field "$.products" memiliki tepat 1 elemen
    And respons field "$.products" berisi ["OMS"]

  @edge @priority-high @REQ-006 @V-13 @screen-api-entitlement @OMS000-EDG-002
  Scenario: Boundary maxItems — keenam add-on dikirim sekaligus diterima
    Given admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    When admin mengirim body dengan products ["TMS","OMS"] dan addOns ["AUTO_STUFFING","SERVICE_FTL","SERVICE_FCL","SERVICE_LTL","SERVICE_LCL","SERVICE_AIR_FREIGHT"]
    Then respons berstatus 200
    And respons field "$.addOns" memiliki tepat 6 elemen
    And admin membaca ulang entitlement client "<clientId>"
    And hasil pembacaan ulang field "$.addOns" memiliki tepat 6 elemen

  @edge @priority-medium @REQ-006 @REQ-016 @V-13 @screen-api-entitlement @OMS000-EDG-003
  Scenario: Boundary minItems addOns — satu elemen lalu dikosongkan kembali
    Given admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    And admin mengirim body dengan products ["TMS"] dan addOns ["SERVICE_AIR_FREIGHT"]
    And respons berstatus 200
    When admin mengirim body dengan addOns []
    Then respons berstatus 200
    And respons field "$.addOns" memiliki tepat 0 elemen
    And respons field "$.products" berisi ["TMS"]

  @edge @priority-medium @REQ-015 @V-10 @V-15 @screen-api-entitlement @OMS000-EDG-004
  Scenario: Duplikat berlipat pada kedua array tetap dideduplikasi menjadi himpunan unik
    Given admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    When admin mengirim body dengan products ["TMS","TMS","OMS","OMS","TMS"] dan addOns ["SERVICE_FTL","SERVICE_FTL","SERVICE_FTL","SERVICE_FCL"]
    Then respons berstatus 200
    And respons field "$.products" memiliki tepat 2 elemen
    And respons field "$.addOns" memiliki tepat 2 elemen

  @edge @priority-medium @REQ-005 @REQ-007 @REQ-019 @screen-api-entitlement @OMS000-EDG-005
  Scenario: Urutan elemen array yang berbeda menghasilkan himpunan entitlement yang sama
    Given admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    And admin mengirim body dengan products ["TMS","OMS"] dan addOns ["SERVICE_FTL","SERVICE_FCL"]
    And respons berstatus 200
    When admin mengirim body dengan products ["OMS","TMS"] dan addOns ["SERVICE_FCL","SERVICE_FTL"]
    Then respons berstatus 200
    And respons field "$.products" memiliki tepat 2 elemen
    And hasil pembacaan ulang field "$.products" berisi himpunan sama dengan ["TMS","OMS"]

  @edge @priority-low @REQ-006 @REQ-069 @screen-api-entitlement @screen-sidebar-shipper @OMS000-EDG-006
  Scenario: Urutan addOns diacak tidak mengubah hasil visibilitas menu
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_AIR_FREIGHT","SERVICE_FCL","SERVICE_FTL"]
    And shipper login ulang
    And user membuka grup menu "MASTER OPERASIONAL"
    When user berada di halaman "Sidebar Shipper"
    Then sistem menampilkan "nav-item-master-pelabuhan"
    And sistem menampilkan "nav-item-master-pelayaran"
    And sistem menampilkan "dashboard-tab-progress-pengiriman"

  @edge @priority-medium @REQ-018 @V-05 @ALT-11 @screen-api-entitlement @OMS000-EDG-007
  Scenario: Banyak field asing termasuk objek bersarang tetap diabaikan
    Given admin mencatat atribut client "clientName, status" sebelum request
    And admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    When admin mengirim body dengan field asing {"clientName":"X","features":{"beta":true},"meta":{"nested":{"deep":[1,2,3]}},"products":["OMS"]}
    Then respons berstatus 200
    And respons field "$.products" berisi ["OMS"]
    And sistem tidak menampilkan "features" pada body respons
    And sistem menampilkan atribut client "clientName" tidak berubah

  @edge @priority-medium @REQ-004 @REQ-007 @V-19 @screen-api-entitlement @OMS000-EDG-008
  Scenario: Body JSON object kosong tidak mengubah entitlement apa pun
    Given entitlement client diset products ["TMS","OMS"] addOns ["SERVICE_FTL"]
    And admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    When admin mengirim body mentah "{}"
    Then respons berstatus 200
    And respons field "$.products" berisi ["TMS","OMS"]
    And respons field "$.addOns" berisi ["SERVICE_FTL"]

  @edge @priority-medium @REQ-003 @V-04 @screen-api-entitlement @OMS000-EDG-009
  Scenario: Body benar-benar kosong tanpa isi ditolak 400
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FTL"]
    And admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    When admin mengirim body mentah ""
    Then respons berstatus 400
    And admin membaca ulang entitlement client "<clientId>"
    And hasil pembacaan ulang field "$.products" berisi ["TMS"]

  @edge @priority-medium @REQ-012 @V-01 @screen-api-entitlement @OMS000-EDG-010
  Scenario Outline: clientId dengan karakter spesial atau spasi ditolak tanpa error server
    Given admin menyiapkan request PATCH entitlement untuk client "<clientIdAneh>"
    When admin mengirim body dengan products ["TMS"] dan addOns []
    Then respons berstatus 400
    And respons bukan berstatus 500
    And respons field "$.errors[0].field" berisi "clientId"

    Examples:
      | clientIdAneh                            | bentuk                |
      | 550e8400-e29b-41d4-a716-44665544 0000   | mengandung spasi      |
      | ../../etc/passwd                        | path traversal        |
      | %3Cscript%3Ealert(1)%3C%2Fscript%3E     | XSS ter-URL-encode    |
      | 550e8400-e29b-41d4-a716-446655440000'   | kutip tunggal ekstra  |

  @edge @priority-low @REQ-011 @REQ-012 @V-01 @screen-api-entitlement @OMS000-EDG-011
  Scenario: clientId UUID dengan huruf kapital diperlakukan konsisten tanpa menduplikasi client
    Given admin menyiapkan request PATCH entitlement untuk client "<clientId dalam huruf kapital>"
    When admin mengirim body dengan products ["TMS"] dan addOns ["SERVICE_FTL"]
    Then respons bukan berstatus 500
    And sistem tidak menampilkan client baru hasil duplikasi
    And admin membaca ulang entitlement client "<clientId>"
    And hasil pembacaan ulang field "$.products" memiliki tepat 1 elemen

  @edge @priority-medium @REQ-014 @V-09 @V-14 @screen-api-entitlement @OMS000-EDG-012
  Scenario Outline: Nilai enum dengan spasi atau karakter tak terlihat ditolak 400
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FTL"]
    And admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    When admin mengirim body dengan field "<field>" berisi <nilai>
    Then respons berstatus 400
    And admin membaca ulang entitlement client "<clientId>"
    And hasil pembacaan ulang field "$.products" berisi ["TMS"]

    Examples:
      | field    | nilai              | bentuk              |
      | products | ["TMS "]           | spasi di akhir      |
      | products | [" TMS"]           | spasi di awal       |
      | addOns   | ["SERVICE_FTL\t"]  | tab di akhir        |
      | addOns   | ["SERVICE FTL"]    | spasi di tengah     |

  @edge @priority-medium @REQ-013 @V-12 @screen-api-entitlement @OMS000-EDG-013
  Scenario Outline: Nilai enum yang mirip tetapi tidak persis ditolak 400
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FTL"]
    And admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    When admin mengirim body dengan field "addOns" berisi <nilai>
    Then respons berstatus 400
    And respons field "$.errors[0].field" berisi "addOns"

    Examples:
      | nilai                       |
      | ["SERVICE_FTL_EXTRA"]       |
      | ["SERVICE_AIRFREIGHT"]      |
      | ["AUTOSTUFFING"]            |
      | ["SERVICE_FTL2"]            |

  @edge @priority-high @REQ-006 @REQ-013 @V-17 @screen-api-entitlement @OMS000-EDG-014
  Scenario: Enam enum sah plus satu enum asing ditolak seluruhnya (all-or-nothing)
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FTL"]
    And admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    When admin mengirim body dengan field "addOns" berisi ["AUTO_STUFFING","SERVICE_FTL","SERVICE_FCL","SERVICE_LTL","SERVICE_LCL","SERVICE_AIR_FREIGHT","SERVICE_RAIL"]
    Then respons berstatus 400
    And admin membaca ulang entitlement client "<clientId>"
    And hasil pembacaan ulang field "$.addOns" memiliki tepat 1 elemen
    And hasil pembacaan ulang field "$.addOns" berisi ["SERVICE_FTL"]

  @edge @priority-low @REQ-003 @V-03 @screen-api-entitlement @OMS000-EDG-015
  Scenario: Content-Type application/json dengan parameter charset tetap diterima
    Given admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    And admin menyertakan header "Content-Type" dengan "application/json; charset=utf-8"
    When admin mengirim body dengan products ["TMS"] dan addOns ["SERVICE_LTL"]
    Then respons berstatus 200
    And respons field "$.addOns" berisi ["SERVICE_LTL"]

  @edge @priority-medium @REQ-019 @REQ-007 @V-22 @screen-api-entitlement @OMS000-EDG-016
  Scenario: Tiga PATCH identik berturut-turut menghasilkan state akhir yang sama
    Given admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    When admin mengirim body dengan products ["TMS","OMS"] dan addOns ["AUTO_STUFFING"] sebanyak 3 kali
    Then respons berstatus 200
    And respons field "$.products" memiliki tepat 2 elemen
    And respons field "$.addOns" memiliki tepat 1 elemen
    And admin membaca ulang entitlement client "<clientId>"
    And hasil pembacaan ulang field "$.addOns" berisi ["AUTO_STUFFING"]

  @edge @priority-high @REQ-026 @REQ-028 @REQ-095 @ALT-27 @screen-penugasan-tracking @screen-driver-app @OMS000-EDG-017
  Scenario: Toggle cepat TMS ke OMS lalu kembali ke TMS — penugasan baru kembali masuk apps
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FTL"]
    And entitlement client diset products ["OMS"] addOns ["SERVICE_FTL"]
    And entitlement client diset products ["TMS","OMS"] addOns ["SERVICE_FTL"]
    And shipper login ulang
    When user berada di halaman "Penugasan Tracking"
    And user mengklik tombol "Tugaskan"
    And user memilih opsi "Sopir" pada field "Tipe Penerima Tugas"
    And user memilih "ORD333TOGGLE" pada field "Pilih Order"
    And user memilih "Sopir A" pada field "Pilih Sopir"
    And user mengklik tombol "Simpan"
    Then sistem menampilkan "toast-success"
    And daftar tugas sopir "Sopir A" memuat order "ORD333TOGGLE"

  @edge @priority-high @REQ-028 @REQ-100 @AC-028.1 @AC-028.3 @ALT-27 @screen-penugasan-tracking @screen-driver-app @OMS000-EDG-018
  Scenario: Order yang sudah ditugaskan tetap berada di apps sopir saat produk berubah ke OMS
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FTL"]
    And penugasan order "ORD444MIDFLIGHT" telah diberikan kepada "Sopir A"
    And daftar tugas sopir "Sopir A" memuat order "ORD444MIDFLIGHT"
    When entitlement client diset products ["OMS"] addOns ["SERVICE_FTL"]
    And shipper login ulang
    Then sistem menampilkan baris penugasan order "ORD444MIDFLIGHT"
    And sistem tidak menampilkan status "Dibatalkan" pada order "ORD444MIDFLIGHT"
    And penugasan order "ORD555SETELAH" telah diberikan kepada "Sopir A"
    And daftar tugas sopir "Sopir A" tidak memuat order "ORD555SETELAH"

  @edge @priority-high @REQ-095 @REQ-097 @ALT-12 @screen-master-moda @screen-sidebar-shipper @screen-error @OMS000-EDG-019
  Scenario: Entitlement dicabut saat sesi aktif — halaman yang sedang dibuka menjadi terlarang
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FCL"]
    And shipper login ulang
    And user berada di halaman "Master Operasional"
    And sistem menampilkan "master-pelabuhan-table"
    When entitlement client diset products ["TMS"] addOns ["SERVICE_FTL"]
    And user mengklik tombol "Muat data berikutnya"
    Then respons berstatus 403
    And user memuat ulang halaman
    And sistem tidak menampilkan "master-pelabuhan-table"
    And sistem menampilkan "error-403-page"

  @edge @priority-high @REQ-085 @AC-085.1 @screen-nav-lkl @OMS000-EDG-020
  Scenario: Hanya SERVICE_LTL aktif — tab Tarif Pengiriman & Konversi Muatan tetap tampil
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_LTL"]
    And shipper login ulang
    And user berada di halaman "Navigasi TMS LKL"
    When user mengklik menu "Master Rute"
    Then sistem menampilkan "master-rute-tab-tarif-pengiriman"
    And sistem menampilkan "master-rute-tab-konversi-muatan"
    And sistem tidak menampilkan "nav-item-master-pelabuhan"

  @edge @priority-high @REQ-085 @REQ-087 @AC-085.2 @screen-nav-lkl @OMS000-EDG-021
  Scenario: Hanya SERVICE_LCL aktif — tab Less tampil bersamaan dengan menu moda laut
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_LCL"]
    And shipper login ulang
    And user membuka grup menu "MASTER OPERASIONAL"
    When user mengklik menu "Master Rute"
    Then sistem menampilkan "master-rute-tab-tarif-pengiriman"
    And sistem menampilkan "master-rute-tab-konversi-muatan"
    And sistem menampilkan "nav-item-master-pelabuhan"
    And sistem tidak menampilkan "nav-item-dashboard-monitoring"

  @edge @priority-medium @REQ-085 @AC-085.3 @ALT-22 @screen-nav-lkl @OMS000-EDG-022
  Scenario: SERVICE_FTL dan SERVICE_FCL bersama tanpa Less tidak memunculkan tab Less
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FTL","SERVICE_FCL"]
    And shipper login ulang
    And user berada di halaman "Navigasi TMS LKL"
    When user mengklik menu "Master Rute"
    Then sistem menampilkan "master-rute-tabs"
    And sistem tidak menampilkan "master-rute-tab-tarif-pengiriman"
    And sistem tidak menampilkan "master-rute-tab-konversi-muatan"
    And sistem menampilkan "nav-item-master-pelabuhan"

  @edge @priority-high @REQ-079 @REQ-082 @REQ-089 @REQ-090 @ALT-21 @screen-nav-lkl @OMS000-EDG-023
  Scenario: Moda tunggal Udara — hanya master udara yang tampil, Monitoring & Otomasi Jalur hilang
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_AIR_FREIGHT"]
    And shipper login ulang
    And user membuka grup menu "MASTER OPERASIONAL"
    When user berada di halaman "Navigasi TMS LKL"
    Then sistem menampilkan "nav-item-master-bandara"
    And sistem menampilkan "nav-item-master-maskapai"
    And sistem tidak menampilkan "nav-item-dashboard-monitoring"
    And sistem tidak menampilkan "nav-item-otomasi-jalur"
    And sistem tidak menampilkan "nav-item-master-pelabuhan"

  @edge @priority-high @REQ-094 @REQ-085 @AC-094.3 @screen-nav-lkl @OMS000-EDG-024
  Scenario: Ketiga moda aktif dengan tipe Less menampilkan seluruh 23 baris matriks LKL
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_LTL","SERVICE_LCL","SERVICE_AIR_FREIGHT"]
    And shipper login ulang
    And user membuka grup menu "MASTER OPERASIONAL"
    When user berada di halaman "Navigasi TMS LKL"
    Then sistem menampilkan "nav-item-dashboard-monitoring"
    And sistem menampilkan "nav-item-otomasi-jalur"
    And sistem menampilkan "nav-item-master-pelabuhan"
    And sistem menampilkan "nav-item-master-bandara"
    And sistem menampilkan "master-rute-tab-tarif-pengiriman"

  # ===========================================================================
  # === KATEGORI: EDGE (bagian B) — kombinasi langka, guard, & sesi berjalan ===
  # ===========================================================================

  @edge @priority-high @REQ-070 @REQ-071 @REQ-069 @screen-sidebar-shipper @screen-master-moda @OMS000-EDG-025
  Scenario: Add-on laut tipe Less saja (SERVICE_LCL) tetap memunculkan Master Pelabuhan & Pelayaran
    Given entitlement client diset products ["OMS"] addOns ["SERVICE_LCL"]
    And shipper login ulang
    And user membuka grup menu "MASTER OPERASIONAL"
    When user mengklik menu "Master Pelabuhan"
    Then sistem menampilkan "master-pelabuhan-page"
    And sistem menampilkan "nav-item-master-pelayaran"
    And sistem tidak menampilkan "dashboard-tab-progress-pengiriman"

  @edge @priority-high @REQ-072 @REQ-069 @AC-072.1 @screen-dashboard @OMS000-EDG-026
  Scenario: Add-on darat tipe Less saja (SERVICE_LTL) tetap memunculkan Progress Pengiriman
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_LTL"]
    And shipper login ulang
    When user berada di halaman "Dashboard Shipper"
    Then sistem menampilkan "dashboard-tab-progress-pengiriman"
    And sistem tidak menampilkan "nav-item-master-pelabuhan"
    And sistem tidak menampilkan "nav-item-master-pelayaran"

  @edge @priority-high @REQ-074 @REQ-036 @REQ-075 @V-20 @screen-sidebar-shipper @OMS000-EDG-027
  Scenario: OMS dengan AUTO_STUFFING tanpa SERVICE_ apa pun — Simulasi Muatan ada, fitur moda hilang
    Given entitlement client diset products ["OMS"] addOns ["AUTO_STUFFING"]
    And shipper login ulang
    And user membuka grup menu "MASTER OPERASIONAL"
    When user berada di halaman "Sidebar Shipper"
    Then sistem menampilkan "nav-item-simulasi-muatan"
    And sistem tidak menampilkan "nav-item-master-pelabuhan"
    And sistem tidak menampilkan "nav-item-master-pelayaran"
    And sistem tidak menampilkan "dashboard-tab-progress-pengiriman"

  @edge @priority-medium @REQ-036 @REQ-076 @AC-036.4 @screen-sidebar-shipper @screen-master-moda @OMS000-EDG-028
  Scenario: Gabungan TMS+OMS dengan AUTO_STUFFING menampilkan Simulasi Muatan varian OMS
    Given entitlement client diset products ["TMS","OMS"] addOns ["AUTO_STUFFING","SERVICE_FTL"]
    And shipper login ulang
    When user mengklik menu "Simulasi Muatan"
    Then sistem menampilkan "simulasi-muatan-page"
    And user diarahkan ke halaman "Simulasi Muatan"
    And sistem tidak menampilkan "error-403-page"

  @edge @priority-medium @REQ-016 @REQ-075 @REQ-077 @screen-form-order @OMS000-EDG-029
  Scenario: addOns kosong membuat form order tanpa opsi jenis pengiriman yang dapat dipilih
    Given entitlement client diset products ["OMS"] addOns []
    And shipper login ulang
    And user berada di halaman "Form Order"
    When user mengklik tombol "Buat Order"
    Then sistem tidak menampilkan "order-type-ftl"
    And sistem tidak menampilkan "order-type-ltl"
    And sistem tidak menampilkan "order-type-fcl"
    And sistem tidak menampilkan "order-type-lcl"
    And sistem tidak menampilkan "order-type-air-freight"
    And sistem menampilkan "order-type-empty"

  @edge @priority-medium @REQ-017 @REQ-101 @V-08 @screen-api-entitlement @screen-sidebar-shipper @OMS000-EDG-030
  Scenario: products kosong ditolak API namun client legacy tanpa produk tetap menampilkan sidebar minimal
    Given admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    When admin mengirim body dengan products [] dan addOns []
    Then respons berstatus 400
    And entitlement client legacy tidak memiliki produk aktif
    And shipper login ulang
    And sistem menampilkan "nav-item-akun-saya"
    And sistem tidak menampilkan "nav-item-order"

  @edge @priority-high @REQ-095 @REQ-096 @ALT-13 @screen-sidebar-shipper @screen-error @OMS000-EDG-031
  Scenario: Perubahan entitlement saat user berada di halaman yang akan hilang
    Given entitlement client diset products ["TMS","OMS"] addOns ["AUTO_STUFFING","SERVICE_FTL"]
    And shipper login ulang
    And user berada di halaman "Simulasi Muatan"
    When entitlement client diset products ["TMS"] addOns ["SERVICE_FTL"]
    And user memuat ulang halaman
    Then sistem tidak menampilkan "simulasi-muatan-page"
    And sistem menampilkan "error-403-page"
    And sistem tidak menampilkan "nav-item-simulasi-muatan"

  @edge @priority-medium @REQ-050 @ALT-26 @screen-sidebar-vendor @OMS000-EDG-032
  Scenario: Vendor login saat entitlement client sedang diubah tetap melihat 6 item
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FTL","SERVICE_FCL","SERVICE_AIR_FREIGHT"]
    And vendor login ulang
    When entitlement client diset products ["OMS"] addOns []
    And user memuat ulang halaman
    Then sistem menampilkan "sidebar-vendor" berisi 6 item
    And sistem menampilkan "nav-item-master-armada"
    And sistem menampilkan "nav-item-master-sopir"

  @edge @priority-high @REQ-067 @REQ-068 @REQ-095 @screen-pengaturan-sistem @OMS000-EDG-033
  Scenario: TMS dicabut saat halaman Pengaturan Sistem terbuka — setelah reload menyisakan 2 item
    Given entitlement client diset products ["TMS","OMS"] addOns ["SERVICE_FTL"]
    And shipper login ulang
    And user berada di halaman "Pengaturan Sistem"
    And sistem menampilkan "system-settings-list" berisi 8 item
    When entitlement client diset products ["OMS"] addOns ["SERVICE_FTL"]
    And user memuat ulang halaman
    Then sistem menampilkan "system-settings-list" berisi 2 item
    And sistem tidak menampilkan "setting-item-koridor-historis"
    And sistem menampilkan "setting-item-nomor-whatsapp-cs"

  @edge @priority-medium @REQ-099 @REQ-062 @AC-099.3 @UF-5 @screen-pengaturan-sistem @OMS000-EDG-034
  Scenario: Nilai Deteksi Keluar Jalur kembali seperti terakhir setelah siklus cabut-pulihkan produk
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FTL"]
    And shipper login ulang
    And user berada di halaman "Pengaturan Sistem"
    And user mengisi field "Deteksi Keluar Jalur" dengan "500"
    And user mengklik tombol "Simpan"
    When entitlement client diset products ["OMS"] addOns ["SERVICE_FTL"]
    And shipper login ulang
    And entitlement client diset products ["TMS"] addOns ["SERVICE_FTL"]
    And shipper login ulang
    Then sistem menampilkan "setting-item-deteksi-keluar-jalur"
    And sistem menampilkan field "Deteksi Keluar Jalur" berisi "500"

  @edge @priority-low @REQ-063 @screen-pengaturan-sistem @OMS000-EDG-035
  Scenario: Label Koridor Historis dikenali walau UI memakai ejaan typo dari sumber xlsx
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FTL"]
    And shipper login ulang
    When user berada di halaman "Pengaturan Sistem"
    Then sistem menampilkan "setting-item-koridor-historis"
    And sistem menampilkan teks yang cocok dengan "/korido[re] historis/i"

  @edge @priority-high @REQ-022 @REQ-024 @REQ-102 @screen-driver-app @screen-penugasan-tracking @OMS000-EDG-036
  Scenario: Sopir yang sama pada dua client berbeda hanya menerima tugas dari client TMS
    Given entitlement client "CLIENT_TMS" diset products ["TMS"] addOns ["SERVICE_FTL"]
    And entitlement client "CLIENT_OMS" diset products ["OMS"] addOns ["SERVICE_FTL"]
    And penugasan order "ORD-TMS-01" pada client "CLIENT_TMS" diberikan kepada "Sopir A"
    And penugasan order "ORD-OMS-01" pada client "CLIENT_OMS" diberikan kepada "Sopir A"
    When daftar tugas sopir "Sopir A" diperiksa melalui API
    Then daftar tugas sopir "Sopir A" memuat order "ORD-TMS-01"
    And daftar tugas sopir "Sopir A" tidak memuat order "ORD-OMS-01"

  @edge @priority-medium @REQ-021 @screen-penugasan-tracking @OMS000-EDG-037
  Scenario: Mengganti pilihan pelaksana Sopir ke Pengurus lalu kembali ke Sopir sebelum menyimpan
    Given entitlement client diset products ["TMS","OMS"] addOns ["SERVICE_FTL"]
    And shipper login ulang
    And user berada di halaman "Penugasan Tracking"
    When user mengklik tombol "Tugaskan"
    And user memilih opsi "Sopir" pada field "Tipe Penerima Tugas"
    And user memilih opsi "Pengurus" pada field "Tipe Penerima Tugas"
    And user memilih opsi "Sopir" pada field "Tipe Penerima Tugas"
    Then sistem menampilkan "assignment-driver-select"
    And sistem tidak menampilkan "assignment-handler-select"
    And user memilih "ORD666SWITCH" pada field "Pilih Order"
    And user memilih "Sopir A" pada field "Pilih Sopir"
    And user mengklik tombol "Simpan"
    And sistem menampilkan "toast-success"

  @edge @priority-medium @REQ-077 @REQ-098 @AC-077.3 @screen-form-order @OMS000-EDG-038
  Scenario: Order lama berjenis LCL tetap terlihat setelah add-on SERVICE_LCL dicabut
    Given entitlement client diset products ["OMS"] addOns ["SERVICE_LCL","SERVICE_FTL"]
    And order "ORD777LCL" berjenis "LCL" telah dibuat
    When entitlement client diset products ["OMS"] addOns ["SERVICE_FTL"]
    And shipper login ulang
    And user berada di halaman "Order"
    Then sistem menampilkan baris order "ORD777LCL"
    And sistem menampilkan "order-row-type-badge" berisi "LCL"
    And user mengklik tombol "Buat Order"
    And sistem tidak menampilkan "order-type-lcl"

  @edge @priority-medium @REQ-096 @AC-096.1 @screen-error @screen-master-moda @OMS000-EDG-039
  Scenario Outline: Variasi bentuk URL non-entitle tetap dijaga guard
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FTL"]
    And shipper login ulang
    When user membuka URL "<route>"
    Then sistem tidak menampilkan "master-pelayaran-table"
    And sistem menampilkan "error-403-page"

    Examples:
      | route                             | bentuk            |
      | /master-pelayaran/                | trailing slash    |
      | /MASTER-PELAYARAN                 | huruf kapital     |
      | /master-pelayaran?tab=detail      | dengan query      |
      | /master-pelayaran#section         | dengan hash       |

  @edge @priority-high @REQ-096 @AC-096.2 @screen-error @screen-master-moda @OMS000-EDG-040
  Scenario: Deep-link ke form tambah master non-entitle tidak membocorkan form
    Given entitlement client diset products ["OMS"] addOns ["SERVICE_FTL"]
    And shipper login ulang
    When user membuka URL "/master-pelabuhan/create"
    Then sistem tidak menampilkan "master-pelabuhan-create"
    And sistem tidak menampilkan field "Nama Pelabuhan"
    And sistem menampilkan "error-403-page"

  @edge @priority-high @REQ-097 @REQ-057 @AC-097.1 @screen-error @screen-sidebar-vendor @OMS000-EDG-041
  Scenario: Panggilan API master Shipper memakai token Vendor ditolak 403
    Given entitlement client diset products ["TMS","OMS"] addOns ["SERVICE_FCL"]
    And vendor login ulang
    When user memanggil API fitur "master-pelabuhan" dengan token vendor
    Then respons berstatus 403
    And sistem tidak menampilkan "$.data" pada body respons

  @edge @priority-medium @REQ-029 @REQ-039 @screen-sidebar-shipper @OMS000-EDG-042
  Scenario: Grup MASTER OPERASIONAL dalam keadaan tertutup — item non-entitle tetap absen setelah dibuka
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FTL"]
    And shipper login ulang
    And sistem menampilkan "nav-group-master-operasional"
    When user membuka grup menu "MASTER OPERASIONAL"
    Then sistem menampilkan "nav-item-master-drop-point"
    And sistem tidak menampilkan "nav-item-master-barang"
    And sistem tidak menampilkan "nav-item-master-pelabuhan"

  @edge @priority-high @REQ-102 @REQ-024 @ALT-27 @screen-driver-app @OMS000-EDG-043
  Scenario: Entitlement dicabut saat sopir sedang login di apps dengan penugasan TMS aktif
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FTL"]
    And penugasan order "ORD888ACTIVE" telah diberikan kepada "Sopir A"
    And sopir "Sopir A" sedang login di aplikasi mobile
    When entitlement client diset products ["OMS"] addOns ["SERVICE_FTL"]
    And penugasan order "ORD999AFTER" telah diberikan kepada "Sopir A"
    Then daftar tugas sopir "Sopir A" tidak memuat order "ORD999AFTER"
    And sistem tidak menampilkan pesan error pada aplikasi sopir

  @edge @priority-low @REQ-011 @REQ-103 @screen-api-entitlement @OMS000-EDG-044
  Scenario: clientId valid tetapi client berstatus nonaktif ditolak tanpa mengubah data
    Given admin menyiapkan request PATCH entitlement untuk client "<clientId client nonaktif>"
    When admin mengirim body dengan products ["TMS"] dan addOns ["SERVICE_FTL"]
    Then respons bukan berstatus 200
    And sistem tidak menampilkan entri audit perubahan baru untuk client "<clientId client nonaktif>"
    And respons bukan berstatus 500

  @edge @priority-medium @REQ-008 @REQ-027 @screen-api-entitlement @OMS000-EDG-045
  Scenario: Respons dengan pembungkus data tetap lolos assertion berlapis
    Given admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    When admin mengirim body dengan products ["OMS"] dan addOns ["SERVICE_LCL"]
    Then respons berstatus 200
    And respons field "$.products ?? $.data.products" berisi ["OMS"]
    And respons field "$.addOns ?? $.data.addOns" berisi ["SERVICE_LCL"]

  # ==========================================================================
  # === KATEGORI: EDGE (bagian C) — indikator kanal penugasan (OPSIONAL) ======
  # --- ASM-33: assignment-row-channel & assignment-channel-hint mungkin
  # --- TIDAK dirender sama sekali. Assertion di bawah bersifat NON-BLOCKING:
  # --- bila elemen tidak ada, skenario di-skip, BUKAN dianggap gagal.
  # --- Assertion lulus/gagal R2 tetap berada di UI-T05 (daftar tugas sopir).
  # ==========================================================================

  @edge @priority-medium @REQ-022 @REQ-024 @REQ-026 @screen-penugasan-tracking @OMS000-EDG-046
  Scenario Outline: Badge kanal penyampaian pada daftar penugasan mencerminkan produk aktif
    Given entitlement client diset products <products> addOns ["SERVICE_FTL"]
    And shipper login ulang
    And penugasan order "ORD123KANAL" telah diberikan kepada "<pelaksana>"
    When user berada di halaman "Penugasan Tracking"
    Then sistem menampilkan baris penugasan order "ORD123KANAL"
    And sistem menampilkan "assignment-row-channel" berisi "<kanal>"
    And sistem menampilkan atribut "data-assignment-channel" bernilai "<atribut>"

    Examples:
      | products      | pelaksana  | kanal          | atribut    | catatan                 |
      | ["TMS"]       | Sopir A    | Aplikasi Sopir | driver-app | TMS + Sopir -> apps     |
      | ["OMS"]       | Sopir A    | Input Web      | web        | OMS + Sopir -> web      |
      | ["TMS"]       | Pengurus B | Input Web      | web        | Pengurus selalu web     |
      | ["OMS"]       | Pengurus B | Input Web      | web        | Pengurus selalu web     |
      | ["TMS","OMS"] | Sopir A    | Aplikasi Sopir | driver-app | gabungan -> Ikut TMS    |

  @edge @priority-low @REQ-022 @REQ-024 @REQ-027 @screen-penugasan-tracking @OMS000-EDG-047
  Scenario Outline: Hint kanal pada form penugasan berubah mengikuti produk dan pelaksana terpilih
    Given entitlement client diset products <products> addOns ["SERVICE_FTL"]
    And shipper login ulang
    And user berada di halaman "Penugasan Tracking"
    When user mengklik tombol "Tugaskan"
    And user memilih opsi "<pelaksana>" pada field "Tipe Penerima Tugas"
    Then sistem menampilkan "assignment-channel-hint"
    And sistem menampilkan teks yang cocok dengan "<matcher>"

    Examples:
      | products      | pelaksana | matcher                                | catatan              |
      | ["TMS"]       | Sopir     | /masuk ke aplikasi sopir/i             | hint apps            |
      | ["OMS"]       | Sopir     | /input tracking dari web/i             | hint web             |
      | ["TMS","OMS"] | Sopir     | /masuk ke aplikasi sopir/i             | gabungan ikut TMS    |
      | ["OMS"]       | Pengurus  | /input tracking dari web/i             | pengurus selalu web  |

  # =====================================================================
  # === KATEGORI: STRESS — volume, konkurensi, payload besar, timeout ===
  # =====================================================================

  @stress @priority-high @REQ-019 @REQ-007 @V-22 @screen-api-entitlement @OMS000-STR-001
  Scenario: Lima puluh PATCH beruntun bergantian TMS dan OMS menghasilkan state akhir konsisten
    Given admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    When admin mengirim 50 request PATCH bergantian products ["TMS"] dan ["OMS"] secara berurutan
    Then seluruh respons berstatus 200
    And admin membaca ulang entitlement client "<clientId>"
    And hasil pembacaan ulang field "$.products" berisi payload request terakhir
    And hasil pembacaan ulang field "$.products" memiliki tepat 1 elemen

  @stress @priority-high @REQ-007 @REQ-008 @ASM-38 @screen-api-entitlement @OMS000-STR-002
  Scenario: Sepuluh PATCH paralel pada clientId yang sama tidak merusak entitlement
    Given admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    When admin mengirim 10 request PATCH paralel dengan payload valid yang berbeda
    Then seluruh respons berstatus 200
    And admin membaca ulang entitlement client "<clientId>"
    And hasil pembacaan ulang field "$.products" sama dengan salah satu payload yang dikirim
    And sistem tidak menampilkan nilai duplikat pada field "$.addOns"

  @stress @priority-medium @REQ-001 @REQ-011 @screen-api-entitlement @OMS000-STR-003
  Scenario: PATCH entitlement ke 50 client berbeda secara paralel diproses tanpa saling menimpa
    Given admin menyiapkan 50 clientId uji yang terdaftar
    When admin mengirim 50 request PATCH paralel dengan payload berbeda per client
    Then seluruh respons berstatus 200
    And admin membaca ulang entitlement seluruh 50 client
    And setiap client memiliki entitlement sesuai payload masing-masing

  @stress @priority-medium @REQ-006 @REQ-015 @V-13 @screen-api-entitlement @OMS000-STR-004
  Scenario: Payload addOns berisi 5000 elemen duplikat ditangani tanpa error server
    Given admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    When admin mengirim body dengan addOns berisi 5000 pengulangan "SERVICE_FTL"
    Then respons bukan berstatus 500
    And respons berstatus 200 atau 400 atau 413
    And admin membaca ulang entitlement client "<clientId>"
    And hasil pembacaan ulang field "$.addOns" memiliki maksimal 6 elemen

  @stress @priority-medium @REQ-005 @V-08 @screen-api-entitlement @OMS000-STR-005
  Scenario: Payload products berisi 10000 elemen duplikat ditangani tanpa error server
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FTL"]
    And admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    When admin mengirim body dengan products berisi 10000 pengulangan "OMS"
    Then respons bukan berstatus 500
    And admin membaca ulang entitlement client "<clientId>"
    And hasil pembacaan ulang field "$.products" memiliki maksimal 2 elemen

  @stress @priority-medium @REQ-018 @V-05 @screen-api-entitlement @OMS000-STR-006
  Scenario: Field asing berisi string satu megabyte tidak disimpan dan tidak menimbulkan 500
    Given admin mencatat atribut client "clientName" sebelum request
    And admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    When admin mengirim body dengan field asing "notes" berisi string sepanjang 1000000 karakter dan products ["TMS"]
    Then respons bukan berstatus 500
    And sistem menampilkan atribut client "clientName" tidak berubah
    And sistem tidak menampilkan "notes" pada body respons

  @stress @priority-medium @REQ-012 @V-01 @screen-api-entitlement @OMS000-STR-007
  Scenario: clientId sepanjang 10000 karakter ditolak tanpa membuat sistem tidak responsif
    Given admin menyiapkan request PATCH entitlement untuk client "<clientId sepanjang 10000 karakter>"
    When admin mengirim body dengan products ["TMS"] dan addOns []
    Then respons berstatus 400 atau 414
    And respons bukan berstatus 500
    And respons diterima dalam waktu kurang dari 10 detik

  @stress @priority-medium @REQ-013 @V-17 @screen-api-entitlement @OMS000-STR-008
  Scenario: Seribu nilai enum tidak dikenal ditolak dalam satu respons tanpa perubahan data
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FTL"]
    And admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    When admin mengirim body dengan addOns berisi 1000 nilai enum acak yang tidak dikenal
    Then respons berstatus 400
    And respons bukan berstatus 500
    And admin membaca ulang entitlement client "<clientId>"
    And hasil pembacaan ulang field "$.addOns" berisi ["SERVICE_FTL"]

  @stress @priority-high @REQ-095 @REQ-029 @AC-095.2 @screen-login @screen-sidebar-shipper @OMS000-STR-009
  Scenario: Seratus user shipper login serentak setelah perubahan entitlement melihat menu yang sama
    Given entitlement client diset products ["TMS","OMS"] addOns ["AUTO_STUFFING","SERVICE_FTL"]
    And 100 user shipper terdaftar pada client "<clientId>"
    When entitlement client diset products ["TMS"] addOns ["SERVICE_FTL"]
    And 100 user shipper melakukan login serentak
    Then seluruh sesi menampilkan "nav-item-dashboard-tracking-location"
    And seluruh sesi tidak menampilkan "nav-item-simulasi-muatan"
    And seluruh sesi tidak menampilkan "nav-item-master-barang"

  @stress @priority-high @REQ-022 @REQ-102 @AC-022.1 @screen-penugasan-tracking @screen-driver-app @OMS000-STR-010
  Scenario: Penugasan massal 200 order ke sopir pada client TMS seluruhnya masuk apps
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FTL"]
    And 200 order siap ditugaskan
    When 200 penugasan dibuat untuk "Sopir A" secara berurutan
    Then seluruh penugasan menampilkan "toast-success"
    And daftar tugas sopir "Sopir A" memuat 200 entri
    And daftar tugas sopir "Sopir A" tidak kehilangan entri setelah muat ulang

  @stress @priority-high @REQ-024 @AC-024.2 @screen-penugasan-tracking @screen-driver-app @OMS000-STR-011
  Scenario: Penugasan massal 200 order ke sopir pada client OMS tidak menghasilkan satu pun entri apps
    Given entitlement client diset products ["OMS"] addOns ["SERVICE_FTL"]
    And 200 order siap ditugaskan
    When 200 penugasan dibuat untuk "Sopir A" secara berurutan
    Then seluruh penugasan tersimpan pada "assignment-list"
    And daftar tugas sopir "Sopir A" memiliki 0 entri
    And sistem tidak menampilkan push notification penugasan ke sopir "Sopir A"

  @stress @priority-medium @REQ-029 @REQ-095 @screen-sidebar-shipper @OMS000-STR-012
  Scenario: Navigasi cepat seluruh menu sidebar tiga kali berturut tidak membocorkan menu non-entitle
    Given entitlement client diset products ["OMS"] addOns ["SERVICE_FTL"]
    And shipper login ulang
    When user menavigasi seluruh menu pada "sidebar-shipper" sebanyak 3 putaran tanpa jeda
    Then sistem tidak menampilkan "nav-item-dashboard-tracking-location"
    And sistem tidak menampilkan "nav-item-master-pelabuhan"
    And sistem tidak menampilkan "nav-item-master-pelayaran"
    And sistem tidak menampilkan "error-403-page"

  @stress @priority-high @REQ-096 @AC-096.1 @screen-error @screen-master-moda @OMS000-STR-013
  Scenario: Seratus deep-link berturut ke route non-entitle seluruhnya ditolak guard
    Given entitlement client diset products ["OMS"] addOns ["SERVICE_FTL"]
    And shipper login ulang
    When user membuka 100 URL non-entitle secara berurutan
    Then seluruh navigasi tidak menampilkan konten fitur non-entitle
    And seluruh navigasi menampilkan "error-403-page"
    And sistem tidak menampilkan kebocoran data pada respons mana pun

  @stress @priority-high @REQ-097 @AC-097.1 @screen-api-entitlement @screen-error @OMS000-STR-014
  Scenario: Dua ratus request API fitur non-entitle secara paralel seluruhnya 403
    Given entitlement client diset products ["OMS"] addOns ["SERVICE_FTL"]
    And shipper login ulang
    When user memanggil API fitur "master-pelabuhan" sebanyak 200 kali secara paralel
    Then seluruh respons berstatus 403
    And sistem tidak menampilkan "$.data" pada body respons mana pun
    And sistem tidak menampilkan respons berstatus 200

  @stress @priority-medium @REQ-008 @REQ-095 @screen-sidebar-shipper @screen-error @OMS000-STR-015
  Scenario: Backend lambat sepuluh detik tidak membuat menu non-entitle sempat terlihat
    Given entitlement client diset products ["OMS"] addOns ["SERVICE_FTL"]
    And backend entitlement diberi delay 10 detik
    When shipper login ulang
    Then sistem menampilkan "sidebar-shipper"
    And sistem tidak menampilkan "nav-item-dashboard-tracking-location" pada fase loading
    And sistem tidak menampilkan "nav-item-master-pelabuhan" setelah data siap

  @stress @priority-high @REQ-002 @REQ-009 @V-02 @screen-api-entitlement @OMS000-STR-016
  Scenario: Seratus request dengan admin key salah seluruhnya 401 tanpa perubahan entitlement
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FTL"]
    And admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    When admin mengirim 100 request dengan header "X-Admin-Key" bernilai acak salah
    Then seluruh respons berstatus 401
    And sistem tidak menampilkan nilai "<X-Admin-Key>" pada body respons mana pun
    And admin membaca ulang entitlement client "<clientId>"
    And hasil pembacaan ulang field "$.products" berisi ["TMS"]

  @stress @priority-medium @REQ-058 @REQ-067 @REQ-068 @screen-pengaturan-sistem @OMS000-STR-017
  Scenario: Lima puluh siklus buka-tutup Pengaturan Sistem sambil produk di-toggle tetap konsisten
    Given entitlement client diset products ["TMS","OMS"] addOns ["SERVICE_FTL"]
    And shipper login ulang
    When user membuka dan menutup halaman "Pengaturan Sistem" sebanyak 50 kali sambil produk di-toggle TMS dan OMS
    Then sistem menampilkan "system-settings-list" sesuai state produk terakhir
    And sistem tidak menampilkan item Pengaturan Sistem di luar matriks state terakhir
    And sistem tidak menampilkan "toast-error"

  @stress @priority-medium @REQ-078 @REQ-094 @screen-nav-lkl @OMS000-STR-018
  Scenario: Navigasi TMS LKL dengan seluruh moda aktif dirender lengkap dalam waktu wajar
    Given entitlement client diset products ["TMS"] addOns ["AUTO_STUFFING","SERVICE_FTL","SERVICE_FCL","SERVICE_LTL","SERVICE_LCL","SERVICE_AIR_FREIGHT"]
    And shipper login ulang
    When user berada di halaman "Navigasi TMS LKL"
    Then sistem menampilkan seluruh 23 item menu matriks LKL
    And sistem menampilkan "nav-group-menu-keuangan"
    And navigasi selesai dirender dalam waktu kurang dari 5 detik

  @stress @priority-medium @REQ-098 @REQ-099 @UF-5 @screen-master-moda @OMS000-STR-019
  Scenario: Dua puluh siklus cabut dan pulihkan add-on tidak mengurangi data master
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FCL"]
    And user mencatat "master-pelabuhan-pagination-info" pada halaman "Master Pelabuhan"
    When entitlement client di-toggle antara addOns ["SERVICE_FCL"] dan ["SERVICE_FTL"] sebanyak 20 siklus
    And shipper login ulang
    And user membuka URL "/master-pelabuhan"
    Then sistem menampilkan "master-pelabuhan-pagination-info" identik dengan catatan sebelumnya
    And sistem tidak menampilkan "master-pelabuhan-empty"

  @stress @priority-low @REQ-077 @REQ-069 @screen-form-order @OMS000-STR-020
  Scenario: Form order dibuka lima puluh kali sambil add-on berubah selalu menampilkan opsi yang sinkron
    Given entitlement client diset products ["OMS"] addOns ["SERVICE_FTL"]
    And shipper login ulang
    When user membuka "Form Order" sebanyak 50 kali sambil addOns di-toggle antara ["SERVICE_FTL"] dan ["SERVICE_FTL","SERVICE_LTL"]
    Then sistem menampilkan opsi jenis pengiriman sesuai addOns terakhir setelah muat ulang
    And sistem tidak menampilkan "order-type-fcl"
    And sistem tidak menampilkan "order-type-air-freight"

  @stress @priority-medium @REQ-050 @REQ-102 @ALT-26 @screen-sidebar-vendor @OMS000-STR-021
  Scenario: Lima puluh sesi vendor paralel saat entitlement client berubah tetap melihat 6 item
    Given entitlement client diset products ["TMS"] addOns ["SERVICE_FTL","SERVICE_FCL"]
    And 50 user vendor terdaftar pada client "<clientId>"
    When entitlement client diset products ["OMS"] addOns []
    And 50 user vendor melakukan login serentak
    Then seluruh sesi menampilkan "sidebar-vendor" berisi 6 item
    And seluruh sesi tidak menampilkan "nav-item-pengaturan-sistem"

  @stress @priority-low @REQ-103 @AC-103.1 @screen-api-entitlement @OMS000-STR-022
  Scenario: Lima ratus PATCH sukses menghasilkan 500 entri audit tanpa kehilangan data
    Given admin mencatat jumlah entri audit entitlement client "<clientId>"
    And admin menyiapkan request PATCH entitlement untuk client "<clientId>"
    When admin mengirim 500 request PATCH valid secara berurutan
    Then seluruh respons berstatus 200
    And sistem menampilkan 500 entri audit baru untuk client "<clientId>"
    And setiap entri audit memuat "waktu, aktor, nilai sebelum, nilai sesudah"

