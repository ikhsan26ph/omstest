# Analysis — oms000-jenis-produk

> **Tahap pipeline:** 1/4 — spec-analyzer → 2/4 — design-analyzer (UI Inventory ditambahkan; tanpa PNG, seluruh selector adalah usulan)
> **Sumber spesifikasi:** `inputs/oms000-jenis-produk/spec.txt` (19 baris — 1 contoh request `curl` + 3 baris aturan naratif)
> **Sumber extras:** `inputs/oms000-jenis-produk/extras/oms000-jenis-produk.xlsx` (5 sheet), dibaca melalui hasil ekstraksi teks `output/oms000-jenis-produk/_extracted/oms000-jenis-produk.xlsx.md`. Sheet ini adalah **sumber utama** penjelasan efek entitlement terhadap fitur/menu.
> **Aset desain:** **TIDAK ADA** — direktori `inputs/oms000-jenis-produk/designs/` tidak tersedia (hanya `spec.txt` + `extras/`). Seluruh nama menu/fitur diambil apa adanya dari matriks xlsx (lihat ASM-01).
> **Aplikasi:** platform logistik **Prahu-Hub** — dua produk: **TMS** (Transport Management System) dan **OMS** (Order Management System); kanal **Shipper (web)**, **Vendor (web)**, **Sopir (mobile apps)**.
> **Modul terkait:** `oms015-order-ltl-lcl-universal` (jenis order LTL/LCL, Master Barang, Master Pelabuhan), `oms022-public-tracking-improve` (timeline tracking hasil penugasan).
> **Catatan keamanan:** nilai `X-Admin-Key` dan `clientId` asli pada `spec.txt` **tidak disalin** ke dokumen ini; ditulis sebagai placeholder `<X-Admin-Key>` dan `<clientId>` (lihat ASM-03).

---

## Ringkasan Modul

Modul **OMS-000 — Jenis Produk & Add-On** adalah **modul pengaturan entitlement (hak pakai) tingkat client/tenant**. Modul ini tidak memiliki layar transaksional sendiri; keluarannya adalah **konfigurasi** yang menentukan **apa yang terlihat dan bagaimana sistem berperilaku** di seluruh modul lain.

Entitlement terdiri dari dua dimensi:

| Dimensi | Nilai | Efek utama |
|---|---|---|
| **`products`** | subset dari `{TMS, OMS}` | Menentukan menu sisi Shipper, isi Pengaturan Sistem, dan **perilaku penugasan tracking** (sopir masuk apps atau tidak) |
| **`addOns`** | subset dari `{AUTO_STUFFING, SERVICE_FTL, SERVICE_FCL, SERVICE_LTL, SERVICE_LCL, SERVICE_AIR_FREIGHT}` | Menentukan fitur yang bergantung **moda/jenis pengiriman aktif** (Master Pelabuhan, Master Pelayaran, Dashboard Progress Pengiriman, Master Bandara/Maskapai) dan fitur ber-add-on (Simulasi Muatan) |

**Aktor:** **Admin platform** (satu-satunya pihak yang mengubah entitlement, melalui API dengan header `X-Admin-Key`), lalu efeknya dirasakan oleh **Shipper user**, **Vendor user**, **Sopir** (mobile apps), dan **Pengurus** (input tracking dari web).

**Kenapa modul ini kritikal untuk QA:**

1. **Blast radius terbesar di platform.** Satu request PATCH mengubah visibilitas **20 menu Shipper**, **6 menu Vendor**, **8 item Pengaturan Sistem**, dan **23 baris matriks TMS LKL**. Salah konfigurasi = fitur hilang/bocor untuk seluruh user client tersebut.
2. **Ada perilaku fungsional, bukan sekadar show/hide.** Aturan paling penting dari spec: **produk TMS → penugasan ke sopir masuk ke aplikasi mobile sopir; produk OMS → penugasan ke sopir TIDAK masuk apps**. Ini bukan perbedaan tampilan, melainkan perbedaan **jalur data tracking**.
3. **Dua filter yang saling bertumpuk.** Visibilitas sebuah menu adalah **AND** antara filter `products` dan filter `addOns` (contoh: `Master Pelabuhan` "ada di TMS & OMS", tetapi **hilang** bila hanya add-on darat yang aktif). Kombinasi inilah yang paling rawan bug (lihat ASM-07).
4. **Kondisi gabungan (TMS + OMS) punya semantik sendiri**: kolom *Penggabungan OMS + TMS* bernilai `Ikut TMS` / `Ikut OMS` / `Setara`, yaitu **varian mana** yang dipakai saat kedua produk aktif — bukan sekadar tampil/tidak (lihat ASM-05).

**Prioritas pengujian:** (1) matriks penugasan TMS vs OMS terhadap masuk/tidaknya ke apps sopir, (2) kontrak & keamanan API entitlement, (3) matriks visibilitas menu Shipper untuk 3 state produk, (4) interaksi filter add-on `SERVICE_*` terhadap menu yang sudah lolos filter produk, (5) propagasi perubahan ke sesi berjalan dan guard server-side terhadap deep-link.

---

## Requirements

### Legenda Kolom

| Kolom | Keterangan |
|---|---|
| **ID** | Identifier requirement, dipakai sebagai tag `@REQ-xxx` di tahap scenario-generator |
| **Requirement** | Pernyataan yang harus dapat diverifikasi (testable) |
| **Sumber** | `spec:Lx` = baris pada `spec.txt`. `xlsx:<Sheet>!<Cell>` = sel pada hasil ekstraksi xlsx. `INF` = inferensi/asumsi (lihat Assumptions Log) |
| **Prioritas** | `high` = inti modul / blocking / berdampak keamanan; `medium` = rule matriks yang harus diregresi; `low` = pelengkap |

**Kode sheet (dipakai pada kolom Sumber):**

| Kode | Nama sheet asli |
|---|---|
| `SH` | `Shipper - TMS vs OMS` |
| `VD` | `Vendor - TMS vs OMS` |
| `PS` | `Pengaturan Sistem - TMS vs OMS` |
| `JP` | `Jenis Pengiriman - TMS vs OMS` |
| `LKL` | `TMS LKL` |

### Glosarium Istilah

| Istilah | Definisi operasional |
|---|---|
| **Entitlement** | Konfigurasi hak pakai satu client (shipper/tenant), terdiri dari `products[]` dan `addOns[]`. |
| **Client** | Tenant/shipper yang diidentifikasi `clientId` pada path API. |
| **Produk** | `TMS` atau `OMS`. Satu client boleh punya salah satu, keduanya. |
| **Add-on** | Kapabilitas tambahan: `AUTO_STUFFING`, `SERVICE_FTL`, `SERVICE_FCL`, `SERVICE_LTL`, `SERVICE_LCL`, `SERVICE_AIR_FREIGHT`. |
| **State produk** | Salah satu dari 3 kondisi uji: **TMS-only**, **OMS-only**, **TMS+OMS (gabungan)**. |
| **Penggabungan** | Kolom xlsx yang menjelaskan perilaku menu saat **kedua** produk aktif. |
| **`Ikut TMS`** | Saat gabungan, menu **tampil** dan menggunakan **varian/perilaku TMS**. |
| **`Ikut OMS`** | Saat gabungan, menu **tampil** dan menggunakan **varian/perilaku OMS**. |
| **`Setara`** | Tidak ada perbedaan varian antar produk; menu tampil dengan satu varian yang sama. |
| **Moda darat** | Diaktifkan oleh add-on `SERVICE_FTL` dan/atau `SERVICE_LTL` (kolom `FTL / LTL saja` pada sheet JP; kolom `Darat` pada LKL). |
| **Moda laut** | Diaktifkan oleh add-on `SERVICE_FCL` dan/atau `SERVICE_LCL` (kolom `FCL / LCL saja` pada JP; kolom `Laut` pada LKL). |
| **Moda udara** | Diaktifkan oleh add-on `SERVICE_AIR_FREIGHT` (kolom `Udara` pada LKL). |
| **Tipe pengiriman "Less"** | Jenis order LTL dan/atau LCL (*Less Than Truck/Container Load*), yaitu add-on `SERVICE_LTL` / `SERVICE_LCL`. |
| **Penugasan Tracking** | Menu untuk menugaskan sebuah perjalanan/order kepada pelaksana tracking. |
| **Sopir** | Pelaksana tracking yang (pada TMS) menerima penugasan di **aplikasi mobile**. |
| **Pengurus** | Pelaksana tracking yang meng-input progres **dari web**, bukan dari apps. |
| **Tampil / Hilang** | `✓` = menu/fitur muncul & dapat diakses; `✗` = menu/fitur tidak muncul & akses langsung ditolak. |

---

### R1. Kontrak API Pengaturan Entitlement

**Kontrak acuan (nilai sensitif diredaksi):**

```
PATCH /api/v1/service/registry/clients/<clientId>/entitlement
Host: apicore-staging.prahu-hub.com
X-Admin-Key: <X-Admin-Key>
Content-Type: application/json

{
  "products": ["TMS","OMS"],
  "addOns": ["AUTO_STUFFING","SERVICE_FTL","SERVICE_FCL","SERVICE_LTL","SERVICE_LCL","SERVICE_AIR_FREIGHT"]
}
```

| ID | Requirement | Sumber | Prioritas |
|---|---|---|---|
| **REQ-001** | Pengaturan entitlement client dilakukan melalui endpoint **`PATCH /api/v1/service/registry/clients/{clientId}/entitlement`**; `{clientId}` adalah identifier client yang dikonfigurasi. | spec:L6 | high |
| **REQ-002** | Request **wajib** menyertakan header autentikasi **`X-Admin-Key`** berisi admin key yang valid. | spec:L7 | high |
| **REQ-003** | Request **wajib** menyertakan header **`Content-Type: application/json`** dan body ber-format JSON object. | spec:L8-L12 | medium |
| **REQ-004** | Body request hanya boleh membawa **dua field**: **`products`** dan **`addOns`**; **tidak ada field lain yang dapat diubah** melalui endpoint ini. | spec:L14 | high |
| **REQ-005** | **`products`** adalah array string dengan nilai enum yang sah: **`TMS`**, **`OMS`**. Nilai di luar enum ditolak. | spec:L10 | high |
| **REQ-006** | **`addOns`** adalah array string dengan nilai enum yang sah: **`AUTO_STUFFING`**, **`SERVICE_FTL`**, **`SERVICE_FCL`**, **`SERVICE_LTL`**, **`SERVICE_LCL`**, **`SERVICE_AIR_FREIGHT`**. Nilai di luar enum ditolak. | spec:L11 | high |
| **REQ-007** | **Semantik update**: pada level *field*, request bersifat **partial** — field yang tidak dikirim tidak berubah. Pada level *array*, nilai bersifat **replace penuh** (bukan append/merge) — array yang dikirim menggantikan seluruh isi sebelumnya. | INF (ASM-04) | high |
| **REQ-008** | Request valid menghasilkan **HTTP 200** dan body respons berisi **entitlement terkini** (`products` dan `addOns` setelah perubahan). | INF (ASM-04) | high |
| **REQ-009** | Request dengan **`X-Admin-Key` salah/kedaluwarsa** ditolak dengan **HTTP 401** dan entitlement client **tidak berubah**. | INF (ASM-04) | high |
| **REQ-010** | Request **tanpa header `X-Admin-Key`** (absen atau bernilai kosong) ditolak dengan **HTTP 401** dan entitlement client **tidak berubah**. | INF (ASM-04) | high |
| **REQ-011** | Request dengan **`clientId` yang tidak terdaftar** ditolak dengan **HTTP 404** dan tidak membuat data client baru. | INF (ASM-04) | high |
| **REQ-012** | Request dengan **`clientId` berformat tidak valid** (bukan UUID) ditolak dengan **HTTP 400**. | INF (ASM-04, ASM-12) | medium |
| **REQ-013** | Request dengan **nilai enum tidak dikenal** (mis. `"XMS"`, `"SERVICE_RAIL"`) ditolak dengan **HTTP 400**, menyebutkan field & nilai yang bermasalah, dan **tidak menyimpan sebagian** (bersifat *all-or-nothing*). | INF (ASM-04) | high |
| **REQ-014** | Validasi enum bersifat **case-sensitive** — hanya bentuk **UPPERCASE** persis yang diterima; `"tms"`, `"Tms"`, `"service_ftl"` ditolak **HTTP 400**. | INF (ASM-06) | high |
| **REQ-015** | **Nilai duplikat** dalam array (mis. `["TMS","TMS"]`) diterima dan **dideduplikasi** saat disimpan; respons mengembalikan array unik. | INF (ASM-06) | medium |
| **REQ-016** | **`addOns: []`** (array kosong) adalah nilai **sah** dan berarti client tidak memiliki add-on apa pun. | INF (ASM-08) | high |
| **REQ-017** | **`products: []`** (array kosong) **ditolak HTTP 400** — setiap client wajib memiliki **minimal satu** produk aktif. | INF (ASM-08) | high |
| **REQ-018** | Field asing di body (mis. `"features"`, `"clientName"`) **tidak menyebabkan perubahan data** — request tetap hanya memproses `products` dan `addOns`. | spec:L14, INF (ASM-09) | medium |
| **REQ-019** | Operasi bersifat **idempoten** — mengirim payload yang identik dua kali menghasilkan status akhir yang sama dan tidak menduplikasi entitlement. | INF (ASM-04) | medium |

---

### R2. Aturan Penugasan Tracking (TMS vs OMS) — **inti modul**

**Matriks acuan:**

| Produk aktif | Penugasan ke **Sopir** | Masuk **apps mobile sopir**? | Penugasan ke **Pengurus** | Input tracking pengurus |
|---|---|---|---|---|
| **TMS** | ✓ boleh | **✓ YA** | ✓ boleh | dari **web** |
| **OMS** | ✓ boleh | **✗ TIDAK** | ✓ boleh | dari **web** |
| **TMS + OMS** | ✓ boleh | **✓ YA** (`Penugasan Tracking` = `Ikut TMS`) | ✓ boleh | dari **web** |

| ID | Requirement | Sumber | Prioritas |
|---|---|---|---|
| **REQ-020** | Menu **`Penugasan Tracking`** tersedia pada **kedua produk** (TMS `✓`, OMS `✓`), baik di sisi Shipper maupun Vendor. | xlsx:SH!A13, xlsx:VD!A5 | high |
| **REQ-021** | Penugasan tracking memiliki **dua jenis target pelaksana**: **Sopir** dan **Pengurus**; keduanya tersedia pada produk TMS maupun OMS. | spec:L17-L18 | high |
| **REQ-022** | **TMS + Sopir** — penugasan yang diberikan kepada sopir **diteruskan ke aplikasi mobile sopir**; sopir menerima dan melihat penugasan tersebut di apps. | spec:L17 | high |
| **REQ-023** | **TMS + Pengurus** — penugasan yang diberikan kepada pengurus **tidak** dikirim ke apps; pengurus meng-input tracking **melalui web**. | spec:L17 | high |
| **REQ-024** | **OMS + Sopir** — penugasan **tetap dapat** diberikan kepada sopir, namun penugasan tersebut **TIDAK masuk ke aplikasi mobile sopir** (tidak muncul di apps). | spec:L18 | high |
| **REQ-025** | **OMS + Pengurus** — penugasan yang diberikan kepada pengurus **tidak** dikirim ke apps; pengurus meng-input tracking **melalui web**. | spec:L18 | high |
| **REQ-026** | **Gabungan TMS + OMS** — kolom Penggabungan untuk `Penugasan Tracking` bernilai **`Ikut TMS`**, sehingga perilaku yang berlaku adalah **perilaku TMS**: penugasan ke sopir **masuk ke apps**. | xlsx:SH!E13, spec:L17 (ASM-05, ASM-11) | high |
| **REQ-027** | Pada produk **OMS** (tanpa TMS), progres pengiriman **hanya** dapat masuk melalui **input web** (oleh pengurus, atau oleh pihak yang mengelola order sopir dari web) — tidak ada jalur pelaporan dari apps sopir. | spec:L18, INF | high |
| **REQ-028** | Perubahan `products` **tidak membatalkan penugasan yang sedang berjalan**; penugasan yang sudah dibuat tetap ada, hanya **jalur penyampaiannya** yang mengikuti aturan produk terbaru sejak perubahan berlaku. | INF (ASM-15) | medium |

---

### R3. Matriks Menu Sisi Shipper per State Produk

**Matriks acuan (salinan sheet `SH`):**

| # | Fitur / Menu | TMS | OMS | Keterangan | Penggabungan OMS + TMS |
|---|---|:--:|:--:|---|---|
| DASHBOARD | | | | | |
| 1 | Dashboard - Monitoring | ✓ | ✓ | Ada di keduanya | Ikut TMS |
| 2 | Dashboard - Tracking & Location | ✓ | ✗ | TMS saja | Ikut TMS |
| 3 | Dashboard - Progress Pengiriman | ✓ | ✗ | TMS saja | Ikut TMS |
| 4 | Dashboard - Operasional | ✓ | ✓ | Ada di keduanya | Ikut TMS |
| 5 | Dashboard - Distribusi & Muatan | ✗ | ✓ | OMS saja | Ikut OMS |
| MENU UTAMA | | | | | |
| 6 | Order | ✓ | ✓ | Ada di keduanya | Ikut OMS |
| 7 | Simulasi Muatan | ✗ | ✓ | OMS saja (Jika ada Add On) | Ikut OMS |
| 8 | Penugasan Tracking | ✓ | ✓ | Ada di keduanya | Ikut TMS |
| 9 | Master Wilayah | ✓ | ✓ | Ada di keduanya | Setara |
| MASTER OPERASIONAL | | | | | |
| 10 | Master Barang | ✗ | ✓ | OMS saja | Ikut OMS |
| 11 | Master Drop Point (Include Customer) | ✓ | ✓ | Ada di keduanya | Setara |
| 12 | Master Pelabuhan | ✓ | ✓ | Ada di keduanya | Setara |
| 13 | Master Pelayaran | ✓ | ✓ | Ada di keduanya | Setara |
| 14 | Master Unit (Armada - Vendor dikelola Admin) | ✓ | ✓ | Ada di keduanya | Ikut TMS |
| 15 | Master Sopir (Vendor dikelola Admin) | ✓ | ✓ | Ada di keduanya | Ikut TMS |
| MENU LAINNYA | | | | | |
| 16 | Manajemen Vendor | ✓ | ✓ | Ada di keduanya | Setara |
| 17 | Pengaturan Akun | ✓ | ✓ | Ada di keduanya | Setara |
| 18 | Akun Saya | ✓ | ✓ | Ada di keduanya | Setara |
| 19 | Pengaturan Sistem | ✓ | ✓ | Ada di keduanya | Ikut TMS |
| 20 | Pusat Notifikasi | ✓ | ✓ | Ada di keduanya | Ikut TMS |

| ID | Requirement | Sumber | Prioritas |
|---|---|---|---|
| **REQ-029** | Susunan menu sisi **Shipper** ditentukan oleh nilai **`products`** pada entitlement; menu bertanda `✗` untuk produk aktif **tidak ditampilkan** pada navigasi maupun dashboard. Struktur grup menu adalah `DASHBOARD`, `MENU UTAMA`, `MASTER OPERASIONAL`, `MENU LAINNYA`. | xlsx:SH!A3-E27 | high |
| **REQ-030** | **`Dashboard - Monitoring`** — tampil pada TMS-only, OMS-only, dan gabungan; saat gabungan menggunakan varian **TMS**. | xlsx:SH!A5-E5 | medium |
| **REQ-031** | **`Dashboard - Tracking & Location`** — tampil **hanya bila `TMS` aktif**; **tidak tampil** pada OMS-only; tampil saat gabungan (varian TMS). | xlsx:SH!A6-E6 | high |
| **REQ-032** | **`Dashboard - Progress Pengiriman`** — tampil **hanya bila `TMS` aktif**; **tidak tampil** pada OMS-only; saat gabungan tampil (varian TMS). Visibilitasnya **juga tunduk pada filter add-on moda** (REQ-072). | xlsx:SH!A7-E7, xlsx:JP!A6 | high |
| **REQ-033** | **`Dashboard - Operasional`** — tampil pada TMS-only, OMS-only, dan gabungan; saat gabungan menggunakan varian **TMS**. | xlsx:SH!A8-E8 | medium |
| **REQ-034** | **`Dashboard - Distribusi & Muatan`** — tampil **hanya bila `OMS` aktif**; **tidak tampil** pada TMS-only; tampil saat gabungan (varian OMS). | xlsx:SH!A9-E9 | high |
| **REQ-035** | **`Order`** — tampil pada TMS-only, OMS-only, dan gabungan; saat gabungan menggunakan varian **OMS**. | xlsx:SH!A11-E11 | high |
| **REQ-036** | **`Simulasi Muatan`** — tampil **hanya bila `OMS` aktif DAN add-on terkait aktif** (`AUTO_STUFFING`); tidak tampil pada TMS-only; saat gabungan tampil dengan varian **OMS**. | xlsx:SH!A12-E12 (ASM-10) | high |
| **REQ-037** | **`Penugasan Tracking`** — tampil pada TMS-only, OMS-only, dan gabungan; saat gabungan perilakunya **Ikut TMS** (lihat REQ-026). | xlsx:SH!A13-E13 | high |
| **REQ-038** | **`Master Wilayah`** — tampil pada ketiga state produk; varian **Setara** (tidak ada perbedaan antar produk). | xlsx:SH!A14-E14 | medium |
| **REQ-039** | **`Master Barang`** — tampil **hanya bila `OMS` aktif**; **tidak tampil** pada TMS-only; tampil saat gabungan (varian OMS). | xlsx:SH!A16-E16 | high |
| **REQ-040** | **`Master Drop Point (Include Customer)`** — tampil pada ketiga state produk; varian **Setara**; menu ini mencakup data Customer. | xlsx:SH!A17-E17 | medium |
| **REQ-041** | **`Master Pelabuhan`** — tampil pada ketiga state produk (varian **Setara**), namun **tunduk pada filter add-on moda laut** (REQ-070). | xlsx:SH!A18-E18, xlsx:JP!A4 | high |
| **REQ-042** | **`Master Pelayaran`** — tampil pada ketiga state produk (varian **Setara**), namun **tunduk pada filter add-on moda laut** (REQ-071). | xlsx:SH!A19-E19, xlsx:JP!A5 | high |
| **REQ-043** | **`Master Unit (Armada)`** — tampil pada ketiga state produk; saat gabungan varian **TMS**. Data armada milik Vendor **dikelola oleh Admin**. | xlsx:SH!A20-E20 | medium |
| **REQ-044** | **`Master Sopir`** — tampil pada ketiga state produk; saat gabungan varian **TMS**. Data sopir milik Vendor **dikelola oleh Admin**. | xlsx:SH!A21-E21 | medium |
| **REQ-045** | **`Manajemen Vendor`** — tampil pada ketiga state produk; varian **Setara**. | xlsx:SH!A23-E23 | medium |
| **REQ-046** | **`Pengaturan Akun`** — tampil pada ketiga state produk; varian **Setara**. | xlsx:SH!A24-E24 | low |
| **REQ-047** | **`Akun Saya`** — tampil pada ketiga state produk; varian **Setara**. | xlsx:SH!A25-E25 | low |
| **REQ-048** | **`Pengaturan Sistem`** — tampil pada ketiga state produk; saat gabungan varian **TMS** (isi item mengikuti R5). | xlsx:SH!A26-E26 | high |
| **REQ-049** | **`Pusat Notifikasi`** — tampil pada ketiga state produk; saat gabungan varian **TMS**. | xlsx:SH!A27-E27 | medium |

---

### R4. Matriks Menu Sisi Vendor

**Matriks acuan (salinan sheet `VD`):**

| # | Fitur / Menu | Vendor TMS | Vendor OMS | Keterangan |
|---|---|:--:|:--:|---|
| 1 | Order | ✓ | ✓ | Ada di keduanya |
| 2 | Penugasan Tracking | ✓ | ✓ | Ada di keduanya |
| 3 | Master Operasional - Master Armada | ✓ | ✓ | Ada di keduanya (khusus Vendor) |
| 4 | Master Operasional - Master Sopir | ✓ | ✓ | Ada di keduanya (khusus Vendor) |
| 5 | Akun Saya | ✓ | ✓ | Ada di keduanya |
| 6 | Pusat Notifikasi | ✓ | ✓ | Ada di keduanya |

| ID | Requirement | Sumber | Prioritas |
|---|---|---|---|
| **REQ-050** | Susunan menu sisi **Vendor** **identik** antara TMS dan OMS — **tidak ada** menu yang muncul/hilang akibat perbedaan `products`. Menu Vendor terdiri tepat dari 6 item pada matriks di atas. | xlsx:VD!A1, VD!A3-D9 | high |
| **REQ-051** | **Vendor — `Order`** tampil pada TMS maupun OMS. | xlsx:VD!A4-D4 | medium |
| **REQ-052** | **Vendor — `Penugasan Tracking`** tampil pada TMS maupun OMS; **perilaku penugasan** tetap mengikuti aturan produk (R2): pada OMS penugasan ke sopir tidak masuk apps. | xlsx:VD!A5-D5, spec:L17-L18 | high |
| **REQ-053** | **Vendor — `Master Operasional - Master Armada`** tampil pada TMS maupun OMS; menu ini **khusus Vendor** (dikelola sendiri oleh vendor, bukan oleh shipper). | xlsx:VD!A6-D6 | medium |
| **REQ-054** | **Vendor — `Master Operasional - Master Sopir`** tampil pada TMS maupun OMS; menu ini **khusus Vendor**. | xlsx:VD!A7-D7 | medium |
| **REQ-055** | **Vendor — `Akun Saya`** tampil pada TMS maupun OMS. | xlsx:VD!A8-D8 | low |
| **REQ-056** | **Vendor — `Pusat Notifikasi`** tampil pada TMS maupun OMS. | xlsx:VD!A9-D9 | low |
| **REQ-057** | Menu sisi Vendor **tidak boleh** memuat menu eksklusif Shipper (`Manajemen Vendor`, `Pengaturan Sistem`, `Master Barang`, `Simulasi Muatan`, `Master Wilayah`, `Master Pelabuhan`, `Master Pelayaran`, `Master Drop Point`, dashboard Shipper) pada state produk mana pun. | xlsx:VD (INF, ASM-13) | medium |

---

### R5. Matriks Pengaturan Sistem

**Matriks acuan (salinan sheet `PS`):**

| # | Fitur | TMS | OMS | Penggabungan OMS + TMS |
|---|---|:--:|:--:|:--:|
| 1 | Durasi Kedaluwarsa Undangan Vendor | ✓ | ✓ | ✓ |
| 2 | Notifikasi Lokasi | ✓ | ✗ | ✓ |
| 3 | Deteksi Tidak Update | ✓ | ✗ | ✓ |
| 4 | Deteksi Keluar Jalur | ✓ | ✗ | ✓ |
| 5 | Koridor Historis *(xlsx tertulis "Koridoe Historis" — typo, lihat ASM-14)* | ✓ | ✗ | ✓ |
| 6 | Notifikasi Dini Berisiko Terlambat | ✓ | ✗ | ✓ |
| 7 | Nomor WhatsApp CS | ✓ | ✓ | ✓ |
| 8 | Pembatasan Kelayakan Armada | ✓ | ✗ | ✓ |

| ID | Requirement | Sumber | Prioritas |
|---|---|---|---|
| **REQ-058** | Isi halaman **`Pengaturan Sistem`** ditentukan oleh `products`; item bertanda `✗` untuk produk aktif **tidak ditampilkan** pada halaman tersebut. | xlsx:PS!A3-D11 | high |
| **REQ-059** | **`Durasi Kedaluwarsa Undangan Vendor`** tampil pada TMS-only, OMS-only, dan gabungan. | xlsx:PS!A4-D4 | medium |
| **REQ-060** | **`Notifikasi Lokasi`** tampil **hanya bila `TMS` aktif**; tidak tampil pada OMS-only; tampil saat gabungan. | xlsx:PS!A5-D5 | high |
| **REQ-061** | **`Deteksi Tidak Update`** tampil **hanya bila `TMS` aktif**; tidak tampil pada OMS-only; tampil saat gabungan. | xlsx:PS!A6-D6 | high |
| **REQ-062** | **`Deteksi Keluar Jalur`** tampil **hanya bila `TMS` aktif**; tidak tampil pada OMS-only; tampil saat gabungan. | xlsx:PS!A7-D7 | high |
| **REQ-063** | **`Koridor Historis`** tampil **hanya bila `TMS` aktif**; tidak tampil pada OMS-only; tampil saat gabungan. | xlsx:PS!A8-D8 (ASM-14) | high |
| **REQ-064** | **`Notifikasi Dini Berisiko Terlambat`** tampil **hanya bila `TMS` aktif**; tidak tampil pada OMS-only; tampil saat gabungan. | xlsx:PS!A9-D9 | high |
| **REQ-065** | **`Nomor WhatsApp CS`** tampil pada TMS-only, OMS-only, dan gabungan. | xlsx:PS!A10-D10 | medium |
| **REQ-066** | **`Pembatasan Kelayakan Armada`** tampil **hanya bila `TMS` aktif**; tidak tampil pada OMS-only; tampil saat gabungan. | xlsx:PS!A11-D11 | high |
| **REQ-067** | **Gabungan TMS + OMS** — Pengaturan Sistem menampilkan **seluruh 8 item** (kolom Penggabungan bernilai `✓` untuk semua baris), yaitu **union** dari item TMS dan OMS. | xlsx:PS!D4-D11 | high |
| **REQ-068** | **OMS-only** — Pengaturan Sistem menampilkan **tepat 2 item**: `Durasi Kedaluwarsa Undangan Vendor` dan `Nomor WhatsApp CS`; 6 item lainnya tidak boleh muncul. | xlsx:PS!C4-C11 | high |

---

### R6. Fitur Berdasarkan Jenis Pengiriman Aktif (add-on `SERVICE_*`)

**Matriks acuan (salinan sheet `JP`):**

| # | Fitur | FTL / LTL saja | FCL / LCL saja | Keduanya aktif |
|---|---|:--:|:--:|:--:|
| 1 | Master Pelabuhan (TMS & OMS - Shipper) | ✗ Hilang | ✓ Ada | ✓ Ada |
| 2 | Master Pelayaran (TMS & OMS - Shipper) | ✗ Hilang | ✓ Ada | ✓ Ada |
| 3 | Dashboard - Progress Pengiriman (TMS - Shipper) | ✓ Ada | ✗ Hilang | ✓ Ada |

**Pemetaan add-on → kolom/moda (keputusan analisis, lihat ASM-07):**

| Add-on | Moda | Kolom sheet JP | Kolom sheet LKL |
|---|---|---|---|
| `SERVICE_FTL` | Darat | `FTL / LTL saja` | `Darat` |
| `SERVICE_LTL` | Darat (tipe "Less") | `FTL / LTL saja` | `Darat` |
| `SERVICE_FCL` | Laut | `FCL / LCL saja` | `Laut` |
| `SERVICE_LCL` | Laut (tipe "Less") | `FCL / LCL saja` | `Laut` |
| `SERVICE_AIR_FREIGHT` | Udara | *(tidak ada kolom)* | `Udara` |
| `AUTO_STUFFING` | — (fitur, bukan moda) | — | — |

| ID | Requirement | Sumber | Prioritas |
|---|---|---|---|
| **REQ-069** | Add-on `SERVICE_*` menentukan **jenis pengiriman yang aktif** bagi client; `SERVICE_FTL`/`SERVICE_LTL` mengaktifkan **moda darat**, `SERVICE_FCL`/`SERVICE_LCL` mengaktifkan **moda laut**, `SERVICE_AIR_FREIGHT` mengaktifkan **moda udara**. | spec:L11, xlsx:JP!B3-D3 (ASM-07) | high |
| **REQ-070** | **`Master Pelabuhan`** (Shipper, berlaku pada TMS & OMS) **hilang** bila hanya moda darat yang aktif; **ada** bila moda laut aktif (sendiri maupun bersama darat). | xlsx:JP!A4-D4 | high |
| **REQ-071** | **`Master Pelayaran`** (Shipper, berlaku pada TMS & OMS) **hilang** bila hanya moda darat yang aktif; **ada** bila moda laut aktif (sendiri maupun bersama darat). | xlsx:JP!A5-D5 | high |
| **REQ-072** | **`Dashboard - Progress Pengiriman`** (Shipper, TMS) **ada** bila moda darat aktif; **hilang** bila hanya moda laut yang aktif; **ada** bila keduanya aktif. | xlsx:JP!A6-D6 | high |
| **REQ-073** | Bila **kedua moda aktif** (darat **dan** laut), ketiga fitur pada matriks JP **tampil semua** — perilaku gabungan bersifat **union**, bukan interseksi. | xlsx:JP!D4-D6 | high |
| **REQ-074** | Visibilitas akhir sebuah menu adalah **AND** antara filter `products` (R3) dan filter `addOns` (R6): menu tampil hanya bila **lolos kedua filter**. Contoh: `Master Pelabuhan` pada OMS-only dengan add-on hanya `SERVICE_FTL` → **tidak tampil**. | INF (ASM-07) | high |
| **REQ-075** | Bila client **tidak memiliki add-on `SERVICE_*` sama sekali** (`addOns: []` atau hanya `AUTO_STUFFING`), maka `Master Pelabuhan`, `Master Pelayaran`, dan `Dashboard - Progress Pengiriman` **tidak tampil** (tidak ada moda yang aktif). | INF (ASM-08) | high |
| **REQ-076** | **`AUTO_STUFFING`** mengaktifkan fitur **`Simulasi Muatan`** pada OMS; tanpa add-on ini, `Simulasi Muatan` **tidak tampil** meskipun `OMS` aktif. | xlsx:SH!D12 (ASM-10) | high |
| **REQ-077** | **Jenis order** yang dapat dibuat client dibatasi oleh add-on `SERVICE_*` yang aktif — pilihan jenis order FTL/LTL/FCL/LCL/Air Freight hanya muncul bila add-on padanannya aktif. | INF (ASM-16) | medium |

---

### R7. Matriks TMS LKL (Darat / Laut / Udara)

**Matriks acuan (salinan sheet `LKL`):**

| # | Fitur / Menu | Darat | Laut | Udara | Keterangan |
|---|---|:--:|:--:|:--:|---|
| DASHBOARD | | | | | |
| 1 | Dashboard - Monitoring | ✓ | ✗ | ✗ | |
| 2 | Dashboard - Tracking & Location | ✓ | ✓ | ✓ | |
| 3 | Dashboard - Operasional | ✓ | ✓ | ✓ | |
| MENU UTAMA | | | | | |
| 4 | Shipment | ✓ | ✓ | ✓ | |
| 5 | Order | ✓ | ✓ | ✓ | |
| 6 | Penugasan Tracking | ✓ | ✓ | ✓ | |
| 7 | Otomasi Jalur | ✓ | ✗ | ✗ | |
| 8 | Master Wilayah | ✓ | ✓ | ✓ | |
| 9 | Master Rute | ✓ | ✓ | ✓ | Tab `Tarif Pengiriman` & `Konversi Muatan` hanya tampil ketika ada tipe pengiriman "Less" |
| MASTER OPERASIONAL | | | | | |
| 10 | Master Customer | ✓ | ✓ | ✓ | |
| 11 | Master Drop Point | ✓ | ✓ | ✓ | |
| 12 | Master Pelabuhan | ✗ | ✓ | ✗ | |
| 13 | Master Pelayaran | ✗ | ✓ | ✗ | |
| 14 | Master Bandara | ✗ | ✗ | ✓ | |
| 15 | Master Maskapai | ✗ | ✗ | ✓ | |
| 16 | Master Unit & Sopir | ✓ | ✓ | ✓ | |
| 17 | Master Kemasan | ✓ | ✓ | ✓ | |
| 18 | Master Bank | ✓ | ✓ | ✓ | |
| MENU KEUANGAN | | | | | |
| 19 | Manajemen Invoice | ✓ | ✓ | ✓ | |
| 20 | Laporan Keuangan | ✓ | ✓ | ✓ | |
| MENU LAINNYA | | | | | |
| 21 | Pengaturan Akun | ✓ | ✓ | ✓ | |
| 22 | Akun Saya | ✓ | ✓ | ✓ | |
| 23 | Pusat Notifikasi | ✓ | ✓ | ✓ | |

| ID | Requirement | Sumber | Prioritas |
|---|---|---|---|
| **REQ-078** | **TMS LKL** adalah varian/konfigurasi TMS yang susunan menunya ditentukan oleh **moda aktif** (`Darat`, `Laut`, `Udara`) hasil pemetaan add-on `SERVICE_*` (REQ-069). Grup menu: `DASHBOARD`, `MENU UTAMA`, `MASTER OPERASIONAL`, `MENU KEUANGAN`, `MENU LAINNYA`. | xlsx:LKL!A1-E31 (ASM-17) | high |
| **REQ-079** | **`Dashboard - Monitoring`** tampil **hanya pada moda Darat**; tidak tampil bila hanya Laut dan/atau Udara yang aktif. | xlsx:LKL!A5-D5 | high |
| **REQ-080** | **`Dashboard - Tracking & Location`** dan **`Dashboard - Operasional`** tampil pada **ketiga moda** (Darat, Laut, Udara). | xlsx:LKL!A6-D7 | medium |
| **REQ-081** | **`Shipment`**, **`Order`**, dan **`Penugasan Tracking`** tampil pada **ketiga moda**. | xlsx:LKL!A9-D11 | medium |
| **REQ-082** | **`Otomasi Jalur`** tampil **hanya pada moda Darat**; tidak tampil bila hanya Laut dan/atau Udara yang aktif. | xlsx:LKL!A12-D12 | high |
| **REQ-083** | **`Master Wilayah`** tampil pada **ketiga moda**. | xlsx:LKL!A13-D13 | low |
| **REQ-084** | **`Master Rute`** tampil pada **ketiga moda**. | xlsx:LKL!A14-D14 | medium |
| **REQ-085** | Pada **`Master Rute`**, tab **`Tarif Pengiriman`** dan **`Konversi Muatan`** **hanya tampil bila ada tipe pengiriman "Less"** aktif, yaitu add-on `SERVICE_LTL` dan/atau `SERVICE_LCL`. Tanpa add-on "Less", kedua tab tersebut tidak tampil. | xlsx:LKL!E14 (ASM-07) | high |
| **REQ-086** | **`Master Customer`** dan **`Master Drop Point`** tampil pada **ketiga moda**. | xlsx:LKL!A16-D17 | low |
| **REQ-087** | **`Master Pelabuhan`** tampil **hanya pada moda Laut**; tidak tampil pada Darat maupun Udara. | xlsx:LKL!A18-D18 | high |
| **REQ-088** | **`Master Pelayaran`** tampil **hanya pada moda Laut**; tidak tampil pada Darat maupun Udara. | xlsx:LKL!A19-D19 | high |
| **REQ-089** | **`Master Bandara`** tampil **hanya pada moda Udara** (add-on `SERVICE_AIR_FREIGHT`); tidak tampil pada Darat maupun Laut. | xlsx:LKL!A20-D20 (ASM-07) | high |
| **REQ-090** | **`Master Maskapai`** tampil **hanya pada moda Udara** (add-on `SERVICE_AIR_FREIGHT`); tidak tampil pada Darat maupun Laut. | xlsx:LKL!A21-D21 (ASM-07) | high |
| **REQ-091** | **`Master Unit & Sopir`**, **`Master Kemasan`**, dan **`Master Bank`** tampil pada **ketiga moda**. | xlsx:LKL!A22-D24 | low |
| **REQ-092** | **MENU KEUANGAN** — **`Manajemen Invoice`** dan **`Laporan Keuangan`** tampil pada **ketiga moda**. | xlsx:LKL!A26-D27 | medium |
| **REQ-093** | **MENU LAINNYA** — **`Pengaturan Akun`**, **`Akun Saya`**, dan **`Pusat Notifikasi`** tampil pada **ketiga moda**. | xlsx:LKL!A29-D31 | low |
| **REQ-094** | Bila **lebih dari satu moda aktif** bersamaan (mis. `SERVICE_FTL` + `SERVICE_FCL` + `SERVICE_AIR_FREIGHT`), menu yang tampil adalah **union** dari kolom moda-moda yang aktif (mis. Darat+Udara → `Dashboard - Monitoring`, `Otomasi Jalur`, `Master Bandara`, `Master Maskapai` semuanya tampil; `Master Pelabuhan`/`Master Pelayaran` tetap tidak tampil). | INF (ASM-18) | high |

---

### R8. Propagasi Perubahan Entitlement & Efek Samping

| ID | Requirement | Sumber | Prioritas |
|---|---|---|---|
| **REQ-095** | Perubahan entitlement berlaku untuk **sesi baru**: menu user yang sedang login berubah setelah **refresh halaman / navigasi ulang** atau paling lambat setelah **login ulang**. Sesi berjalan tidak wajib berubah seketika (tanpa refresh). | INF (ASM-15) | high |
| **REQ-096** | **Guard sisi server** — mengakses langsung URL/deep-link menu yang tidak ter-*entitle* (mis. `/master-pelabuhan` saat hanya moda darat aktif) **ditolak** (redirect ke halaman utama atau halaman 403), bukan sekadar disembunyikan dari navigasi. | INF (ASM-15) | high |
| **REQ-097** | **Enforcement pada API** — endpoint backend milik fitur yang tidak ter-*entitle* menolak request user tersebut (**403**), sehingga penyembunyian menu tidak dapat di-*bypass* melalui pemanggilan API langsung. | INF (ASM-15) | high |
| **REQ-098** | **Data tidak dihapus** — menonaktifkan produk/add-on hanya **menyembunyikan** menu dan fitur; data yang sudah tersimpan (order, master, penugasan, riwayat tracking) **tetap ada** di sistem. | INF (ASM-15) | high |
| **REQ-099** | **Reaktivasi mengembalikan data** — mengaktifkan kembali produk/add-on yang sebelumnya dicabut membuat menu tampil kembali **beserta data lama** yang masih utuh, tanpa perlu input ulang. | INF (ASM-15) | high |
| **REQ-100** | **Transaksi berjalan** — order/penugasan yang sudah dibuat sebelum perubahan entitlement tetap dapat dilihat dan diselesaikan; sistem tidak membatalkan atau menghapusnya secara otomatis. | INF (ASM-15) | medium |
| **REQ-101** | **Fallback entitlement kosong** — bila karena kondisi data legacy sebuah client tidak memiliki produk aktif, user tetap dapat login namun hanya melihat menu non-operasional (`Akun Saya`, `Pengaturan Akun`, `Pusat Notifikasi`); seluruh menu operasional tidak tampil dan aksesnya ditolak. | INF (ASM-08) | medium |
| **REQ-102** | **Konsistensi lintas kanal** — entitlement yang sama berlaku konsisten pada web Shipper, web Vendor, dan aplikasi mobile sopir; tidak boleh ada kanal yang menampilkan fitur di luar entitlement. | INF (ASM-15) | high |
| **REQ-103** | **Auditability** — setiap perubahan entitlement tercatat (siapa/kapan/nilai sebelum-sesudah) sehingga perubahan dapat ditelusuri. | INF (ASM-04) | low |

---

### Aturan Validasi

| ID | Field / Aspek | Aturan | Sumber |
|---|---|---|---|
| **V-01** | `clientId` (path param) | **Wajib**; format **UUID v4**; harus merujuk client yang terdaftar. Tidak terdaftar → `404`; format salah → `400`. | spec:L6, INF (ASM-12) |
| **V-02** | Header `X-Admin-Key` | **Wajib**; harus cocok dengan admin key yang berlaku. Absen/kosong/salah → `401`. Nilai tidak boleh muncul di log/respons. | spec:L7, INF (ASM-03) |
| **V-03** | Header `Content-Type` | **Wajib** `application/json`. Tipe lain → `415` (atau `400`). | spec:L8 |
| **V-04** | Body request | **Wajib** berupa JSON object valid. Body kosong / JSON malformed → `400`. | spec:L9-L12 |
| **V-05** | Field yang boleh diubah | **Hanya** `products` dan `addOns`. Field lain tidak diproses dan tidak mengubah data. | spec:L14 |
| **V-06** | `products` — tipe | Array of string. Bukan array (string/objek/angka) → `400`. | spec:L10 |
| **V-07** | `products` — enum | Nilai sah **hanya** `TMS`, `OMS`. Nilai lain → `400`. | spec:L10 |
| **V-08** | `products` — jumlah | **minItems = 1**, **maxItems = 2**. Array kosong → `400` (REQ-017). | INF (ASM-08) |
| **V-09** | `products` — case | **Case-sensitive UPPERCASE**. `"tms"`, `"Oms"` → `400`. | INF (ASM-06) |
| **V-10** | `products` — duplikat | Duplikat diterima lalu **dideduplikasi**; hasil simpan berupa himpunan unik. | INF (ASM-06) |
| **V-11** | `addOns` — tipe | Array of string. Bukan array → `400`. | spec:L11 |
| **V-12** | `addOns` — enum | Nilai sah **hanya** `AUTO_STUFFING`, `SERVICE_FTL`, `SERVICE_FCL`, `SERVICE_LTL`, `SERVICE_LCL`, `SERVICE_AIR_FREIGHT`. Nilai lain → `400`. | spec:L11 |
| **V-13** | `addOns` — jumlah | **minItems = 0** (boleh kosong), **maxItems = 6**. `[]` sah (REQ-016). | INF (ASM-08) |
| **V-14** | `addOns` — case | **Case-sensitive UPPERCASE**. `"service_ftl"` → `400`. | INF (ASM-06) |
| **V-15** | `addOns` — duplikat | Duplikat diterima lalu **dideduplikasi**. | INF (ASM-06) |
| **V-16** | Nilai `null` / elemen kosong | `products: null`, `addOns: null`, atau elemen `""`/`null` di dalam array → `400`. | INF (ASM-04) |
| **V-17** | Atomicity | Bila ada satu nilai tidak valid, **tidak ada** perubahan yang tersimpan (all-or-nothing). | INF (ASM-04) |
| **V-18** | Semantik array | Array yang dikirim **mengganti seluruh** nilai lama (replace), bukan menambah. | INF (ASM-04) |
| **V-19** | Semantik field | Field yang **tidak dikirim** tidak berubah (partial update tingkat field). | INF (ASM-04) |
| **V-20** | Konsistensi produk vs add-on | `AUTO_STUFFING` hanya berdampak bila `OMS` aktif; add-on tanpa produk pendukung tetap **tersimpan** namun **tidak menampilkan fitur apa pun**. | INF (ASM-10) |
| **V-21** | Konsistensi moda | Bila tidak ada satu pun add-on `SERVICE_*`, tidak ada moda aktif → fitur yang bergantung moda seluruhnya tidak tampil (REQ-075). | INF (ASM-08) |
| **V-22** | Idempotensi | Payload identik dikirim berulang → status akhir sama, tanpa duplikasi entri entitlement. | INF (ASM-04) |
| **V-23** | Method | Hanya **PATCH** yang didukung pada path ini; `GET`/`POST`/`PUT`/`DELETE` → `405`. | spec:L6, INF |

---

### Role / Aktor

| Aktor | Kanal | Hak akses | Batasan |
|---|---|---|---|
| **Admin platform** | API `PATCH .../entitlement` dengan header `X-Admin-Key` | Satu-satunya pihak yang dapat **mengubah `products` dan `addOns`** untuk client mana pun. Juga mengelola data Vendor (Master Unit/Armada & Master Sopir milik vendor) atas nama shipper. | Tidak dapat mengubah field entitlement selain `products`/`addOns` (V-05). Tanpa admin key valid → `401`. |
| **Shipper user** | Web Shipper | Mengakses menu sesuai entitlement client-nya: Dashboard, Order, Penugasan Tracking, Master Operasional, Manajemen Vendor, Pengaturan Sistem, Pengaturan Akun, Akun Saya, Pusat Notifikasi. Membuat penugasan ke Sopir/Pengurus. | **Tidak dapat** mengubah entitlement. Menu di luar entitlement tidak tampil dan aksesnya ditolak (REQ-096, REQ-097). |
| **Vendor user** | Web Vendor | Mengakses 6 menu tetap: `Order`, `Penugasan Tracking`, `Master Armada`, `Master Sopir`, `Akun Saya`, `Pusat Notifikasi` — identik pada TMS maupun OMS. | Tidak melihat menu Shipper (REQ-057). Perilaku penugasan tetap tunduk aturan produk (REQ-052). |
| **Sopir** | Aplikasi mobile sopir | Menerima dan mengeksekusi penugasan tracking **hanya bila produk `TMS` aktif** (REQ-022, REQ-026). | Pada **OMS-only**, penugasan tetap dapat dibuat untuknya namun **tidak muncul di apps** (REQ-024). |
| **Pengurus** | Web | Menerima penugasan tracking dan meng-**input progres tracking dari web** pada produk TMS maupun OMS. | Tidak menggunakan aplikasi mobile sopir. |

---

### User Flow

#### UF-1 — Admin mengubah entitlement, Shipper melihat efeknya *(alur utama)*

1. Admin menyiapkan request `PATCH /api/v1/service/registry/clients/<clientId>/entitlement`.
2. Admin menyertakan header `X-Admin-Key: <X-Admin-Key>` dan `Content-Type: application/json`.
3. Admin mengirim body `{"products":[...], "addOns":[...]}` berisi nilai enum yang sah.
4. Sistem memvalidasi admin key → clientId → enum `products` → enum `addOns`.
5. Sistem menyimpan entitlement (replace array) dan mengembalikan **200** beserta entitlement terkini.
6. Shipper user melakukan **refresh/login ulang** pada web Shipper.
7. Navigasi menampilkan **tepat** menu hasil kombinasi `products` (R3) **AND** `addOns` (R6); isi `Pengaturan Sistem` mengikuti R5.

| ID | Percabangan / alternatif | Hasil yang diharapkan |
|---|---|---|
| **ALT-01** | Step 2 — header `X-Admin-Key` tidak dikirim atau bernilai kosong | `401`; entitlement tidak berubah (REQ-010) |
| **ALT-02** | Step 2 — `X-Admin-Key` salah/kedaluwarsa | `401`; entitlement tidak berubah (REQ-009) |
| **ALT-03** | Step 4 — `clientId` tidak terdaftar | `404`; tidak membuat client baru (REQ-011) |
| **ALT-04** | Step 4 — `clientId` bukan UUID | `400` (REQ-012) |
| **ALT-05** | Step 4 — `products` berisi nilai di luar enum (mis. `"XMS"`) | `400`, all-or-nothing, tidak ada perubahan tersimpan (REQ-013, V-17) |
| **ALT-06** | Step 4 — nilai enum huruf kecil (`"tms"`, `"service_ftl"`) | `400` (REQ-014) |
| **ALT-07** | Step 4 — `products: []` | `400`, minimal 1 produk wajib (REQ-017) |
| **ALT-08** | Step 4 — `addOns: []` | `200`; client tanpa add-on; seluruh fitur berbasis moda & `Simulasi Muatan` tidak tampil (REQ-016, REQ-075) |
| **ALT-09** | Step 4 — array berisi duplikat (`["TMS","TMS"]`) | `200`; nilai tersimpan terdeduplikasi (REQ-015) |
| **ALT-10** | Step 3 — hanya field `addOns` dikirim | `200`; `products` tidak berubah (REQ-007, V-19) |
| **ALT-11** | Step 3 — body memuat field asing selain `products`/`addOns` | Field asing tidak berpengaruh; hanya kedua field resmi yang diproses (REQ-018) |
| **ALT-12** | Step 6 — user belum refresh/login ulang | Menu lama boleh tetap tampil; namun akses ke fitur non-entitle sudah ditolak server (REQ-095, REQ-097) |
| **ALT-13** | Step 7 — user mengetik URL menu yang sudah disembunyikan | Akses ditolak (redirect/403), bukan halaman fitur (REQ-096) |

#### UF-2 — Penugasan tracking ke **Sopir** pada produk **TMS**

1. Entitlement client: `products: ["TMS"]`.
2. Shipper membuka menu `Penugasan Tracking`.
3. Shipper memilih perjalanan/order dan memilih target **Sopir**.
4. Shipper menyimpan penugasan.
5. Penugasan **muncul di aplikasi mobile sopir**; sopir dapat melaporkan progres dari apps.

| ID | Percabangan / alternatif | Hasil yang diharapkan |
|---|---|---|
| **ALT-14** | Step 1 — `products: ["OMS"]` (OMS-only) | Penugasan ke sopir tetap **dapat dibuat**, namun **tidak muncul di apps sopir**; progres hanya bisa masuk lewat web (REQ-024, REQ-027) |
| **ALT-15** | Step 1 — `products: ["TMS","OMS"]` | Perilaku **Ikut TMS**: penugasan ke sopir **masuk apps** (REQ-026) |

#### UF-3 — Penugasan tracking ke **Pengurus**

1. Entitlement client memuat `TMS` atau `OMS` (salah satu atau keduanya).
2. Shipper membuka `Penugasan Tracking` dan memilih target **Pengurus**.
3. Shipper menyimpan penugasan.
4. Pengurus login ke **web** dan meng-input progres tracking pada perjalanan/order tersebut.

| ID | Percabangan / alternatif | Hasil yang diharapkan |
|---|---|---|
| **ALT-16** | Step 1 — produk `TMS` | Penugasan pengurus tidak dikirim ke apps; input tracking via web (REQ-023) |
| **ALT-17** | Step 1 — produk `OMS` | Perilaku identik dengan TMS untuk jalur pengurus: input tracking via web (REQ-025) |

#### UF-4 — Kombinasi add-on menentukan fitur berbasis moda

1. Admin mengirim `addOns: ["SERVICE_FTL","SERVICE_LTL"]` (moda darat saja).
2. Shipper login/refresh.
3. `Master Pelabuhan` dan `Master Pelayaran` **hilang**; `Dashboard - Progress Pengiriman` **ada** (jika `TMS` aktif).

| ID | Percabangan / alternatif | Hasil yang diharapkan |
|---|---|---|
| **ALT-18** | `addOns: ["SERVICE_FCL","SERVICE_LCL"]` (laut saja) | `Master Pelabuhan` & `Master Pelayaran` **ada**; `Dashboard - Progress Pengiriman` **hilang** (REQ-070…REQ-072) |
| **ALT-19** | Darat + laut aktif bersama | Ketiga fitur **ada** — union (REQ-073) |
| **ALT-20** | `addOns` tanpa `SERVICE_*` sama sekali | Ketiga fitur **hilang** (REQ-075) |
| **ALT-21** | `SERVICE_AIR_FREIGHT` aktif (TMS LKL) | `Master Bandara` & `Master Maskapai` **tampil**; `Master Pelabuhan`/`Master Pelayaran` tidak (REQ-089, REQ-090) |
| **ALT-22** | Add-on "Less" (`SERVICE_LTL`/`SERVICE_LCL`) **tidak** aktif | Tab `Tarif Pengiriman` & `Konversi Muatan` pada `Master Rute` **tidak tampil** (REQ-085) |
| **ALT-23** | `AUTO_STUFFING` tidak aktif pada client OMS | Menu `Simulasi Muatan` **tidak tampil** (REQ-076) |
| **ALT-24** | `AUTO_STUFFING` aktif tetapi `products: ["TMS"]` | `Simulasi Muatan` **tetap tidak tampil** (butuh OMS) (REQ-036, V-20) |

#### UF-5 — Pencabutan produk/add-on dan pemulihannya

1. Client aktif dengan `products: ["TMS","OMS"]`, add-on lengkap.
2. Admin mengirim `products: ["OMS"]`.
3. Shipper refresh → menu eksklusif TMS (`Dashboard - Tracking & Location`, `Dashboard - Progress Pengiriman`) **hilang**; `Pengaturan Sistem` menyisakan 2 item.
4. Data lama (riwayat tracking, konfigurasi deteksi) **tidak dihapus**.
5. Admin mengembalikan `products: ["TMS","OMS"]` → menu & data lama **muncul kembali utuh**.

| ID | Percabangan / alternatif | Hasil yang diharapkan |
|---|---|---|
| **ALT-25** | Step 3 — ada penugasan/order yang sedang berjalan | Order/penugasan tetap dapat dilihat & diselesaikan (REQ-100) |
| **ALT-26** | Step 3 — user vendor sedang login | Menu vendor **tidak berubah** (identik TMS/OMS), hanya perilaku penugasan yang mengikuti produk baru (REQ-050, REQ-052) |
| **ALT-27** | Step 3 — sopir sedang login di apps dengan penugasan TMS aktif | Setelah produk menjadi OMS-only, penugasan **baru** tidak lagi masuk apps (REQ-024, REQ-028) |

---

### Acceptance Criteria

#### R1 — Kontrak API Entitlement

- **REQ-001** — AC-001.1: Request `PATCH /api/v1/service/registry/clients/<clientId>/entitlement` dengan payload valid mengembalikan `200`. AC-001.2: Path tanpa segmen `/entitlement` tidak memproses perubahan entitlement. AC-001.3: Method selain `PATCH` pada path yang sama mengembalikan `405`.
- **REQ-002** — AC-002.1: Request dengan `X-Admin-Key` valid diproses. AC-002.2: Nilai admin key tidak pernah dikembalikan pada body respons maupun tercetak di pesan error.
- **REQ-003** — AC-003.1: `Content-Type: application/json` diterima. AC-003.2: `Content-Type: text/plain` ditolak `415`/`400`. AC-003.3: Body bukan JSON valid ditolak `400`.
- **REQ-004** — AC-004.1: Payload berisi `products` + `addOns` mengubah kedua nilai tersebut. AC-004.2: Atribut client lain (nama, status, kontak) tidak berubah setelah request.
- **REQ-005** — AC-005.1: `["TMS"]`, `["OMS"]`, `["TMS","OMS"]` seluruhnya diterima `200`. AC-005.2: `["TMS","XMS"]` ditolak `400`.
- **REQ-006** — AC-006.1: Keenam nilai add-on sah diterima dalam satu request. AC-006.2: `["SERVICE_RAIL"]` ditolak `400`. AC-006.3: Subset add-on mana pun diterima.
- **REQ-007** — AC-007.1: Kondisi awal `addOns` 6 nilai, kirim `addOns: ["SERVICE_FTL"]` → hasil akhir tepat 1 nilai (bukan 7). AC-007.2: Kirim hanya `addOns` → `products` tetap seperti sebelumnya. AC-007.3: Kirim hanya `products` → `addOns` tetap seperti sebelumnya.
- **REQ-008** — AC-008.1: Respons sukses berstatus `200`. AC-008.2: Body respons memuat `products` dan `addOns` yang sama persis dengan hasil simpan. AC-008.3: `GET`/pembacaan ulang entitlement menghasilkan nilai identik dengan respons.
- **REQ-009** — AC-009.1: `X-Admin-Key` salah → `401`. AC-009.2: Pembacaan ulang menunjukkan entitlement **tidak berubah**.
- **REQ-010** — AC-010.1: Header dihilangkan → `401`. AC-010.2: Header dikirim bernilai string kosong → `401`. AC-010.3: Entitlement tidak berubah pada kedua kasus.
- **REQ-011** — AC-011.1: `clientId` UUID acak yang tidak terdaftar → `404`. AC-011.2: Tidak terbentuk record client baru setelah request tersebut.
- **REQ-012** — AC-012.1: `clientId` = `abc123` → `400`. AC-012.2: Pesan error menunjuk pada parameter `clientId`.
- **REQ-013** — AC-013.1: `products: ["TMS","XMS"]` → `400`. AC-013.2: Pembacaan ulang menunjukkan `TMS` **tidak** ikut tersimpan (all-or-nothing). AC-013.3: Pesan error menyebut field & nilai yang ditolak.
- **REQ-014** — AC-014.1: `products: ["tms"]` → `400`. AC-014.2: `addOns: ["service_ftl"]` → `400`. AC-014.3: `products: ["Tms"]` → `400`.
- **REQ-015** — AC-015.1: `products: ["TMS","TMS"]` → `200`. AC-015.2: Nilai tersimpan/dikembalikan hanya `["TMS"]`. AC-015.3: Perilaku sama untuk duplikat pada `addOns`.
- **REQ-016** — AC-016.1: `addOns: []` → `200`. AC-016.2: Pembacaan ulang menunjukkan `addOns` kosong. AC-016.3: Menu bergantung add-on tidak tampil (lihat AC-075.x).
- **REQ-017** — AC-017.1: `products: []` → `400`. AC-017.2: Entitlement sebelumnya tidak berubah.
- **REQ-018** — AC-018.1: Body `{"products":["TMS"],"clientName":"X"}` tidak mengubah nama client. AC-018.2: Perubahan `products` tetap diproses (atau ditolak konsisten) tanpa efek samping pada field lain.
- **REQ-019** — AC-019.1: Mengirim payload identik dua kali menghasilkan `200` dua kali. AC-019.2: Nilai entitlement setelah request kedua sama persis dengan setelah request pertama.

#### R2 — Aturan Penugasan

- **REQ-020** — AC-020.1: Pada `products: ["TMS"]`, menu `Penugasan Tracking` tampil di Shipper dan Vendor. AC-020.2: Pada `products: ["OMS"]`, menu `Penugasan Tracking` tampil di Shipper dan Vendor.
- **REQ-021** — AC-021.1: Form penugasan menyediakan opsi target **Sopir** dan **Pengurus** pada produk TMS. AC-021.2: Opsi yang sama tersedia pada produk OMS.
- **REQ-022** — AC-022.1: `products: ["TMS"]`, penugasan disimpan untuk Sopir A → penugasan **muncul** pada daftar tugas Sopir A di aplikasi mobile. AC-022.2: Sopir A dapat membuka penugasan dan melaporkan progres dari apps. AC-022.3: Progres dari apps tercermin pada tracking di web.
- **REQ-023** — AC-023.1: `products: ["TMS"]`, penugasan disimpan untuk Pengurus B → penugasan **tidak** muncul di apps sopir. AC-023.2: Pengurus B dapat meng-input progres tracking dari web.
- **REQ-024** — AC-024.1: `products: ["OMS"]`, penugasan ke Sopir A berhasil disimpan (tidak diblokir). AC-024.2: Daftar tugas Sopir A di aplikasi mobile **tidak memuat** penugasan tersebut. AC-024.3: Tidak ada push notification penugasan ke apps sopir.
- **REQ-025** — AC-025.1: `products: ["OMS"]`, penugasan ke Pengurus B tersimpan. AC-025.2: Pengurus B dapat meng-input progres tracking dari web. AC-025.3: Penugasan tidak muncul di apps.
- **REQ-026** — AC-026.1: `products: ["TMS","OMS"]`, penugasan ke Sopir A **muncul di apps** (perilaku TMS). AC-026.2: Perilaku ini konsisten baik untuk order yang dibuat dari alur TMS maupun OMS.
- **REQ-027** — AC-027.1: Pada OMS-only, timeline tracking hanya bertambah melalui input web. AC-027.2: Tidak tersedia kanal pelaporan progres dari apps sopir pada client OMS-only.
- **REQ-028** — AC-028.1: Penugasan yang dibuat saat `TMS` aktif tetap tercatat setelah produk diubah ke OMS-only. AC-028.2: Sistem tidak menghapus/membatalkan penugasan tersebut secara otomatis. AC-028.3: Penugasan **baru** setelah perubahan mengikuti aturan produk terbaru.

#### R3 — Menu Sisi Shipper

- **REQ-029** — AC-029.1: Pada TMS-only, navigasi Shipper memuat tepat menu berkolom `✓` di kolom TMS. AC-029.2: Pada OMS-only, navigasi memuat tepat menu berkolom `✓` di kolom OMS. AC-029.3: Grup menu ditampilkan dengan judul `DASHBOARD`, `MENU UTAMA`, `MASTER OPERASIONAL`, `MENU LAINNYA`.
- **REQ-030** — AC-030.1: TMS-only → `Dashboard - Monitoring` tampil. AC-030.2: OMS-only → tampil. AC-030.3: Gabungan → tampil dengan varian TMS.
- **REQ-031** — AC-031.1: TMS-only → `Dashboard - Tracking & Location` tampil. AC-031.2: OMS-only → **tidak** tampil. AC-031.3: Gabungan → tampil (varian TMS).
- **REQ-032** — AC-032.1: TMS-only + moda darat → `Dashboard - Progress Pengiriman` tampil. AC-032.2: OMS-only → **tidak** tampil apa pun add-on-nya. AC-032.3: Gabungan + moda darat → tampil (varian TMS).
- **REQ-033** — AC-033.1: TMS-only → `Dashboard - Operasional` tampil. AC-033.2: OMS-only → tampil. AC-033.3: Gabungan → tampil (varian TMS).
- **REQ-034** — AC-034.1: TMS-only → `Dashboard - Distribusi & Muatan` **tidak** tampil. AC-034.2: OMS-only → tampil. AC-034.3: Gabungan → tampil (varian OMS).
- **REQ-035** — AC-035.1: TMS-only → `Order` tampil. AC-035.2: OMS-only → tampil. AC-035.3: Gabungan → tampil dan menggunakan varian **OMS** (mis. mengikuti alur order OMS, bukan TMS).
- **REQ-036** — AC-036.1: OMS-only + `AUTO_STUFFING` → `Simulasi Muatan` tampil. AC-036.2: OMS-only tanpa `AUTO_STUFFING` → **tidak** tampil. AC-036.3: TMS-only (+`AUTO_STUFFING`) → **tidak** tampil. AC-036.4: Gabungan + `AUTO_STUFFING` → tampil (varian OMS).
- **REQ-037** — AC-037.1: Ketiga state produk menampilkan `Penugasan Tracking`. AC-037.2: Pada gabungan, perilaku penugasan mengikuti TMS (AC-026.1).
- **REQ-038** — AC-038.1: `Master Wilayah` tampil pada TMS-only, OMS-only, dan gabungan. AC-038.2: Tampilan/isi menu ini sama pada ketiga state (Setara).
- **REQ-039** — AC-039.1: TMS-only → `Master Barang` **tidak** tampil. AC-039.2: OMS-only → tampil. AC-039.3: Gabungan → tampil (varian OMS).
- **REQ-040** — AC-040.1: `Master Drop Point` tampil pada ketiga state. AC-040.2: Data Customer dapat diakses dari dalam menu ini. AC-040.3: Isi menu sama pada ketiga state (Setara).
- **REQ-041** — AC-041.1: Dengan moda laut aktif, `Master Pelabuhan` tampil pada TMS-only, OMS-only, dan gabungan. AC-041.2: Dengan hanya moda darat aktif, menu **tidak** tampil pada state produk mana pun.
- **REQ-042** — AC-042.1: Dengan moda laut aktif, `Master Pelayaran` tampil pada ketiga state. AC-042.2: Dengan hanya moda darat aktif, menu **tidak** tampil.
- **REQ-043** — AC-043.1: `Master Unit (Armada)` tampil pada ketiga state. AC-043.2: Pada gabungan menggunakan varian TMS. AC-043.3: Data armada vendor tampil sebagai data yang dikelola Admin.
- **REQ-044** — AC-044.1: `Master Sopir` tampil pada ketiga state. AC-044.2: Pada gabungan menggunakan varian TMS. AC-044.3: Data sopir vendor tampil sebagai data yang dikelola Admin.
- **REQ-045** — AC-045.1: `Manajemen Vendor` tampil pada ketiga state dengan isi sama (Setara).
- **REQ-046** — AC-046.1: `Pengaturan Akun` tampil pada ketiga state dengan isi sama.
- **REQ-047** — AC-047.1: `Akun Saya` tampil pada ketiga state dengan isi sama.
- **REQ-048** — AC-048.1: `Pengaturan Sistem` tampil pada ketiga state. AC-048.2: Pada gabungan, isinya mengikuti varian TMS (8 item — lihat REQ-067).
- **REQ-049** — AC-049.1: `Pusat Notifikasi` tampil pada ketiga state. AC-049.2: Pada gabungan menggunakan varian TMS.

#### R4 — Menu Sisi Vendor

- **REQ-050** — AC-050.1: Daftar menu Vendor pada client TMS-only dan client OMS-only **identik** (6 item, urutan sama). AC-050.2: Tidak ada menu vendor yang hilang/muncul akibat perubahan `products`.
- **REQ-051** — AC-051.1: `Order` tampil pada Vendor TMS. AC-051.2: `Order` tampil pada Vendor OMS.
- **REQ-052** — AC-052.1: `Penugasan Tracking` tampil pada Vendor TMS dan Vendor OMS. AC-052.2: Vendor pada client TMS menugaskan sopir → masuk apps. AC-052.3: Vendor pada client OMS menugaskan sopir → **tidak** masuk apps.
- **REQ-053** — AC-053.1: `Master Operasional - Master Armada` tampil pada Vendor TMS dan OMS. AC-053.2: Menu ini tidak muncul pada navigasi Shipper dengan label yang sama (menu vendor bersifat khusus vendor).
- **REQ-054** — AC-054.1: `Master Operasional - Master Sopir` tampil pada Vendor TMS dan OMS.
- **REQ-055** — AC-055.1: `Akun Saya` tampil pada Vendor TMS dan OMS.
- **REQ-056** — AC-056.1: `Pusat Notifikasi` tampil pada Vendor TMS dan OMS.
- **REQ-057** — AC-057.1: Navigasi Vendor tidak memuat `Manajemen Vendor`, `Pengaturan Sistem`, `Master Barang`, `Simulasi Muatan`, `Master Wilayah`, `Master Pelabuhan`, `Master Pelayaran`, `Master Drop Point`. AC-057.2: Akses langsung URL menu Shipper oleh user Vendor ditolak.

#### R5 — Pengaturan Sistem

- **REQ-058** — AC-058.1: Halaman `Pengaturan Sistem` menampilkan hanya item ber-`✓` untuk state produk aktif. AC-058.2: Item ber-`✗` tidak tampil dan tidak dapat diakses langsung.
- **REQ-059** — AC-059.1: `Durasi Kedaluwarsa Undangan Vendor` tampil pada TMS-only, OMS-only, dan gabungan.
- **REQ-060** — AC-060.1: TMS-only → `Notifikasi Lokasi` tampil. AC-060.2: OMS-only → tidak tampil. AC-060.3: Gabungan → tampil.
- **REQ-061** — AC-061.1: TMS-only → `Deteksi Tidak Update` tampil. AC-061.2: OMS-only → tidak tampil. AC-061.3: Gabungan → tampil.
- **REQ-062** — AC-062.1: TMS-only → `Deteksi Keluar Jalur` tampil. AC-062.2: OMS-only → tidak tampil. AC-062.3: Gabungan → tampil.
- **REQ-063** — AC-063.1: TMS-only → `Koridor Historis` tampil. AC-063.2: OMS-only → tidak tampil. AC-063.3: Gabungan → tampil.
- **REQ-064** — AC-064.1: TMS-only → `Notifikasi Dini Berisiko Terlambat` tampil. AC-064.2: OMS-only → tidak tampil. AC-064.3: Gabungan → tampil.
- **REQ-065** — AC-065.1: `Nomor WhatsApp CS` tampil pada TMS-only, OMS-only, dan gabungan.
- **REQ-066** — AC-066.1: TMS-only → `Pembatasan Kelayakan Armada` tampil. AC-066.2: OMS-only → tidak tampil. AC-066.3: Gabungan → tampil.
- **REQ-067** — AC-067.1: Pada gabungan, jumlah item pada halaman `Pengaturan Sistem` = **8**. AC-067.2: Kedelapan label sesuai matriks PS.
- **REQ-068** — AC-068.1: Pada OMS-only, jumlah item = **2**. AC-068.2: Label yang tampil tepat `Durasi Kedaluwarsa Undangan Vendor` dan `Nomor WhatsApp CS`. AC-068.3: Enam item TMS-only tidak dapat diakses melalui URL langsung.

#### R6 — Jenis Pengiriman / Add-on

- **REQ-069** — AC-069.1: Client dengan `SERVICE_FTL` dan/atau `SERVICE_LTL` diperlakukan sebagai **moda darat aktif**. AC-069.2: Client dengan `SERVICE_FCL` dan/atau `SERVICE_LCL` diperlakukan sebagai **moda laut aktif**. AC-069.3: Client dengan `SERVICE_AIR_FREIGHT` diperlakukan sebagai **moda udara aktif**.
- **REQ-070** — AC-070.1: `addOns: ["SERVICE_FTL","SERVICE_LTL"]` → `Master Pelabuhan` **tidak** tampil. AC-070.2: `addOns: ["SERVICE_FCL"]` → tampil. AC-070.3: Berlaku identik pada client TMS maupun OMS.
- **REQ-071** — AC-071.1: `addOns: ["SERVICE_FTL"]` → `Master Pelayaran` **tidak** tampil. AC-071.2: `addOns: ["SERVICE_LCL"]` → tampil. AC-071.3: Berlaku identik pada client TMS maupun OMS.
- **REQ-072** — AC-072.1: TMS + `addOns: ["SERVICE_LTL"]` → `Dashboard - Progress Pengiriman` tampil. AC-072.2: TMS + `addOns: ["SERVICE_FCL","SERVICE_LCL"]` → **tidak** tampil. AC-072.3: TMS + darat & laut → tampil.
- **REQ-073** — AC-073.1: `addOns` memuat minimal satu add-on darat dan satu add-on laut → `Master Pelabuhan`, `Master Pelayaran`, `Dashboard - Progress Pengiriman` ketiganya tampil.
- **REQ-074** — AC-074.1: OMS-only + hanya add-on darat → `Master Pelabuhan` tidak tampil meskipun matriks produk menandainya `✓`. AC-074.2: OMS-only + add-on laut → `Master Pelabuhan` tampil. AC-074.3: OMS-only + add-on darat → `Dashboard - Progress Pengiriman` tetap **tidak** tampil (gagal filter produk).
- **REQ-075** — AC-075.1: `addOns: []` → ketiga fitur matriks JP tidak tampil. AC-075.2: `addOns: ["AUTO_STUFFING"]` → ketiga fitur matriks JP tidak tampil.
- **REQ-076** — AC-076.1: OMS + `AUTO_STUFFING` → `Simulasi Muatan` tampil dan dapat dibuka. AC-076.2: OMS tanpa `AUTO_STUFFING` → menu tidak tampil dan URL langsung ditolak.
- **REQ-077** — AC-077.1: Client dengan hanya `SERVICE_FTL` tidak dapat memilih jenis order LTL/FCL/LCL/Air Freight. AC-077.2: Menambahkan `SERVICE_LTL` memunculkan pilihan jenis order LTL. AC-077.3: Order lama berjenis yang add-on-nya dicabut tetap dapat dilihat (REQ-098).

#### R7 — TMS LKL

- **REQ-078** — AC-078.1: Navigasi TMS LKL menampilkan grup `DASHBOARD`, `MENU UTAMA`, `MASTER OPERASIONAL`, `MENU KEUANGAN`, `MENU LAINNYA`. AC-078.2: Isi tiap grup sesuai kolom moda yang aktif.
- **REQ-079** — AC-079.1: Moda Darat → `Dashboard - Monitoring` tampil. AC-079.2: Moda Laut saja → tidak tampil. AC-079.3: Moda Udara saja → tidak tampil.
- **REQ-080** — AC-080.1: `Dashboard - Tracking & Location` tampil pada Darat, Laut, dan Udara. AC-080.2: `Dashboard - Operasional` tampil pada ketiga moda.
- **REQ-081** — AC-081.1: `Shipment` tampil pada ketiga moda. AC-081.2: `Order` tampil pada ketiga moda. AC-081.3: `Penugasan Tracking` tampil pada ketiga moda.
- **REQ-082** — AC-082.1: Moda Darat → `Otomasi Jalur` tampil. AC-082.2: Moda Laut saja → tidak tampil. AC-082.3: Moda Udara saja → tidak tampil.
- **REQ-083** — AC-083.1: `Master Wilayah` tampil pada ketiga moda.
- **REQ-084** — AC-084.1: `Master Rute` tampil pada ketiga moda.
- **REQ-085** — AC-085.1: Dengan `SERVICE_LTL` aktif, `Master Rute` menampilkan tab `Tarif Pengiriman` dan `Konversi Muatan`. AC-085.2: Dengan `SERVICE_LCL` aktif, kedua tab tersebut tampil. AC-085.3: Hanya `SERVICE_FTL`/`SERVICE_FCL` (tanpa "Less") → kedua tab **tidak** tampil. AC-085.4: Tab lain pada `Master Rute` tetap tampil pada semua kondisi.
- **REQ-086** — AC-086.1: `Master Customer` tampil pada ketiga moda. AC-086.2: `Master Drop Point` tampil pada ketiga moda.
- **REQ-087** — AC-087.1: Moda Laut → `Master Pelabuhan` tampil. AC-087.2: Moda Darat saja → tidak tampil. AC-087.3: Moda Udara saja → tidak tampil.
- **REQ-088** — AC-088.1: Moda Laut → `Master Pelayaran` tampil. AC-088.2: Moda Darat saja → tidak tampil. AC-088.3: Moda Udara saja → tidak tampil.
- **REQ-089** — AC-089.1: `SERVICE_AIR_FREIGHT` aktif → `Master Bandara` tampil. AC-089.2: Tanpa add-on udara → tidak tampil. AC-089.3: Moda Darat/Laut saja → tidak tampil.
- **REQ-090** — AC-090.1: `SERVICE_AIR_FREIGHT` aktif → `Master Maskapai` tampil. AC-090.2: Tanpa add-on udara → tidak tampil.
- **REQ-091** — AC-091.1: `Master Unit & Sopir` tampil pada ketiga moda. AC-091.2: `Master Kemasan` tampil pada ketiga moda. AC-091.3: `Master Bank` tampil pada ketiga moda.
- **REQ-092** — AC-092.1: `Manajemen Invoice` tampil pada ketiga moda. AC-092.2: `Laporan Keuangan` tampil pada ketiga moda.
- **REQ-093** — AC-093.1: `Pengaturan Akun`, `Akun Saya`, `Pusat Notifikasi` tampil pada ketiga moda.
- **REQ-094** — AC-094.1: Darat + Laut aktif → `Dashboard - Monitoring`, `Otomasi Jalur`, `Master Pelabuhan`, `Master Pelayaran` semuanya tampil. AC-094.2: Darat + Udara aktif → `Master Bandara` & `Master Maskapai` tampil, `Master Pelabuhan` & `Master Pelayaran` tidak. AC-094.3: Ketiga moda aktif → seluruh 23 baris matriks LKL tampil.

#### R8 — Propagasi & Efek Samping

- **REQ-095** — AC-095.1: Setelah PATCH sukses dan user melakukan refresh, navigasi mencerminkan entitlement baru. AC-095.2: Setelah logout-login, navigasi mencerminkan entitlement baru. AC-095.3: Tidak diperlukan tindakan manual lain (mis. clear cache) agar menu berubah.
- **REQ-096** — AC-096.1: Mengakses URL menu non-entitle mengembalikan redirect ke halaman utama atau halaman 403 — bukan konten fitur. AC-096.2: Perilaku sama untuk deep-link ke sub-halaman (mis. detail/form) fitur tersebut.
- **REQ-097** — AC-097.1: Memanggil API fitur non-entitle dengan token user tersebut menghasilkan `403`. AC-097.2: Data fitur tersebut tidak terkirim pada respons mana pun.
- **REQ-098** — AC-098.1: Setelah produk/add-on dicabut, jumlah record terkait di sistem tidak berkurang. AC-098.2: Data masih dapat diverifikasi melalui jalur admin/DB. AC-098.3: Tidak ada notifikasi/aksi penghapusan yang terpicu.
- **REQ-099** — AC-099.1: Setelah reaktivasi, menu tampil kembali. AC-099.2: Data yang tampil sama persis dengan sebelum pencabutan (jumlah record & isinya). AC-099.3: Konfigurasi Pengaturan Sistem yang tersembunyi kembali dengan nilai terakhirnya.
- **REQ-100** — AC-100.1: Order berjalan tetap muncul di daftar order setelah perubahan entitlement (selama menu `Order` masih ter-entitle). AC-100.2: Penugasan berjalan tidak berubah status secara otomatis. AC-100.3: Tidak ada error/blank page saat membuka detail order lama.
- **REQ-101** — AC-101.1: Client tanpa produk aktif → user tetap dapat login. AC-101.2: Navigasi hanya memuat `Akun Saya`, `Pengaturan Akun`, `Pusat Notifikasi`. AC-101.3: Akses URL menu operasional ditolak.
- **REQ-102** — AC-102.1: Entitlement yang sama menghasilkan keputusan tampil/tidak yang konsisten di web Shipper dan web Vendor. AC-102.2: Apps sopir tidak menampilkan penugasan yang tidak ter-entitle (OMS-only). AC-102.3: Tidak ada kanal yang memberi akses ke fitur di luar entitlement.
- **REQ-103** — AC-103.1: Setiap PATCH sukses menghasilkan satu entri audit. AC-103.2: Entri audit memuat waktu, aktor, nilai sebelum & sesudah. AC-103.3: Request yang ditolak tidak menghasilkan entri perubahan data.

---

## UI Inventory

> ## ⚠ SELURUH ISI SECTION INI ADALAH **USULAN (HIPOTESIS)** — BELUM DIVERIFIKASI
>
> **Mode: TANPA-DESAIN.** Direktori `inputs/oms000-jenis-produk/designs/` sudah **diverifikasi tidak ada / kosong** (0 file PNG; `inputs/oms000-jenis-produk/` hanya memuat `spec.txt` dan `extras/oms000-jenis-produk.xlsx`) — lihat **ASM-01** dan **ASM-21**.
> Inventaris di bawah **diturunkan sepenuhnya dari `Requirements` (R1–R8), `Aturan Validasi`, `Role/Aktor`, dan `User Flow`** pada dokumen ini — **bukan** dari pengamatan visual.
>
> Konsekuensinya, untuk **setiap** baris tabel di bawah:
> - **Nama layar** = penamaan kerja (bukan judul resmi produk);
> - **Label / teks / placeholder** = **usulan**; satu-satunya teks yang *ter-grounding* adalah **nama menu & nama fitur** yang disalin **verbatim dari matriks xlsx** (sheet `SH`, `VD`, `PS`, `JP`, `LKL`) — kolom "Label/teks" menandai mana yang verbatim dengan ✅;
> - **Selector `getByRole` / `getByLabel` / `getByTestId`** = **usulan**, belum tentu ada di DOM;
> - **`data-testid`** = **permintaan kontrak test kepada tim FE** (**ASM-22**), bukan fakta — wajib disepakati sebelum test ditulis.
>
> **Modul ini tidak punya layar transaksional sendiri.** Yang diuji adalah **efek entitlement** pada layar milik modul lain. Karena itu "layar" di bawah lebih tepat disebut **permukaan uji (test surface)**: satu permukaan API (UI-T00) + sebelas permukaan UI.
>
> **Acuan konvensi:** penamaan `data-testid` dan urutan prioritas selector mengikuti UI Inventory modul **`oms015-order-ltl-lcl-universal`** (section `UI-COMMON`, `UI-096`–`UI-105`) dan **`oms022-public-tracking-improve`** (section `UI-T00`–`UI-T10`) agar konsisten lintas modul — lihat **ASM-22**, **ASM-23**.

---

### Konvensi Selector (berlaku untuk seluruh permukaan di bawah)

| Prioritas | Strategi | Bentuk | Kapan dipakai |
|---|---|---|---|
| **1** | **ARIA role + accessible name** | `getByRole('<role>', { name: /<regex>/i })` | Default untuk seluruh elemen interaktif, heading, dan **item navigasi** (`role=link`). Nama memakai **regex case-insensitive** karena kapitalisasi label UI belum diketahui. |
| **2** | **`data-testid`** | `getByTestId('<kebab-case>')` | Untuk elemen struktural/stateful tanpa role bermakna (grup menu, kartu setting, badge kanal penugasan, container hasil) **dan** sebagai jangkar stabil untuk assertion *ketiadaan* (`toHaveCount(0)`). |
| **3** | **Label text** | `getByLabel(/<regex>/i)` | Untuk field form (`Sopir`, `Pengurus`, `Jenis Pengiriman`). Fallback bila role/name tidak reliabel. |
| **4** | **Text matcher parsial + CI** | `getByText(/<regex>/i)` | Fallback terakhir untuk teks statis & pesan. **Selalu parsial + `i`** — jangan `exact: true`. |

**Aturan tambahan (wajib dipatuhi scenario-generator):**

1. **Selalu scoping ke container navigasi** sebelum mencari item menu: `getByRole('navigation')` / `getByTestId('sidebar-shipper')`. Label seperti `Order`, `Master Sopir`, `Penugasan Tracking` berpotensi muncul juga pada breadcrumb, judul halaman, dan tabel.
2. **Assertion inti modul ini adalah assertion NEGATIF** (menu tidak tampil). Gunakan **`toHaveCount(0)`**, **bukan** `not.toBeVisible()` — elemen yang tidak dirender akan membuat `not.toBeVisible()` ambigu/flaky.
3. **Jangan** meng-assert jumlah total item sidebar dengan angka absolut kecuali requirement menyebut angkanya secara eksplisit (REQ-050 = 6 item Vendor, REQ-067 = 8 item Pengaturan Sistem, REQ-068 = 2 item). Untuk selebihnya, assert **keberadaan/ketiadaan item spesifik**.
4. **Jangan** memakai `exact: true` pada label menu — kapitalisasi xlsx (`Dashboard - Monitoring`) belum tentu sama dengan UI (mungkin `Monitoring` saja di dalam halaman Dashboard). Pakai regex kata kunci: `/monitoring/i`.
5. **Visibilitas ≠ akses.** Setiap assertion "menu tidak tampil" **wajib** dipasangkan dengan assertion guard: akses langsung ke route menu tersebut menghasilkan 403/redirect (REQ-096) dan API-nya menolak 403 (REQ-097).
6. **Propagasi**: sebelum meng-assert perubahan menu setelah PATCH entitlement, lakukan `page.reload()` (dan pada skenario ketat, logout–login ulang) — REQ-095, **ASM-37**.

**Pola penamaan `data-testid` yang diusulkan:**

| Prefiks | Pola | Contoh | Dipakai untuk |
|---|---|---|---|
| `nav-group-` | `nav-group-<slug-grup>` | `nav-group-master-operasional` | Header/grup menu pada sidebar |
| `nav-item-` | `nav-item-<slug-menu>` | `nav-item-master-pelabuhan` | Satu item menu (link) pada sidebar |
| `dashboard-tab-` | `dashboard-tab-<slug>` | `dashboard-tab-progress-pengiriman` | Tab/kartu pada halaman Dashboard |
| `setting-item-` | `setting-item-<slug>` | `setting-item-koridor-historis` | Satu item/kartu pada halaman Pengaturan Sistem |
| `assignment-` | `assignment-<elemen>[-<varian>]` | `assignment-assignee-type-sopir` | Layar & form Penugasan Tracking |
| `order-type-` | `order-type-<jenis>` | `order-type-air-freight` | Opsi Jenis Pengiriman pada form order (**selaras `oms015` UI-097**) |
| `<domain>-page` | `<domain>-page` | `master-pelabuhan-page` | Root halaman list/detail |

> **Catatan kompatibilitas:** `oms015` memakai pola **`nav-order`**, **`nav-simulasi-muatan`** (tanpa segmen `item`). Dokumen ini mengusulkan **`nav-item-<slug>`** agar seragam dengan `nav-group-<slug>`. Selama kontrak FE belum final, skenario **wajib** memakai selector prioritas-1 (`getByRole('link', { name: /…/i })`) sebagai primer dan menyediakan **dua** kandidat testid (`nav-item-order` **atau** `nav-order`) sebagai fallback — lihat **ASM-23**.

---

### Notasi State Entitlement (dipakai pada kolom "State/Visibilitas")

Karena visibilitas di modul ini adalah fungsi dari **dua dimensi**, kolom state memakai notasi ringkas berikut.

| Kode | Arti | Payload PATCH acuan |
|---|---|---|
| **`P-TMS`** | Produk TMS saja | `{"products":["TMS"]}` |
| **`P-OMS`** | Produk OMS saja | `{"products":["OMS"]}` |
| **`P-BOTH`** | Gabungan TMS + OMS | `{"products":["TMS","OMS"]}` |
| **`A-DARAT`** | Moda darat aktif | `addOns` memuat `SERVICE_FTL` dan/atau `SERVICE_LTL` |
| **`A-LAUT`** | Moda laut aktif | `addOns` memuat `SERVICE_FCL` dan/atau `SERVICE_LCL` |
| **`A-UDARA`** | Moda udara aktif | `addOns` memuat `SERVICE_AIR_FREIGHT` |
| **`A-LESS`** | Tipe pengiriman "Less" aktif | `addOns` memuat `SERVICE_LTL` dan/atau `SERVICE_LCL` |
| **`A-STUFF`** | Add-on stuffing aktif | `addOns` memuat `AUTO_STUFFING` |
| **`A-NONE`** | Tanpa add-on `SERVICE_*` | `addOns: []` atau hanya `["AUTO_STUFFING"]` |

Notasi sel: `✓` = tampil & dapat diakses · `✗` = **tidak dirender** (`toHaveCount(0)`) **dan** route-nya dijaga (403/redirect) · `(TMS)` / `(OMS)` = varian yang dipakai saat `P-BOTH` (ASM-05).

---

### Daftar Permukaan Uji

| ID | Slug tag | Permukaan | Jenis | Kanal / Aktor | REQ utama |
|---|---|---|---|---|---|
| **UI-T00** | `@screen-api-entitlement` | API Pengaturan Entitlement | **API** (bukan layar) | Admin platform | REQ-001…REQ-019, REQ-103 |
| **UI-T01** | `@screen-login` | Login / Sesi Shipper & Vendor | Halaman | Shipper, Vendor | REQ-095, REQ-101, REQ-102 |
| **UI-T02** | `@screen-sidebar-shipper` | Sidebar / Navigasi utama Shipper | Komponen global | Shipper | REQ-029…REQ-049, REQ-070…REQ-076 |
| **UI-T03** | `@screen-dashboard` | Dashboard Shipper (tab/kartu) | Halaman | Shipper | REQ-030…REQ-034, REQ-072 |
| **UI-T04** | `@screen-penugasan-tracking` | Penugasan Tracking (Shipper & Vendor) — **inti modul** | Halaman + form | Shipper, Vendor, Pengurus | REQ-020…REQ-028, REQ-052 |
| **UI-T05** | `@screen-driver-app` | Aplikasi mobile Sopir — daftar tugas | Aplikasi eksternal / API | Sopir | REQ-022, REQ-024, REQ-026, REQ-102 |
| **UI-T06** | `@screen-pengaturan-sistem` | Pengaturan Sistem | Halaman | Shipper | REQ-058…REQ-068 |
| **UI-T07** | `@screen-sidebar-vendor` | Sidebar / Navigasi Vendor | Komponen global | Vendor | REQ-050…REQ-057 |
| **UI-T08** | `@screen-master-moda` | Master Operasional bergantung moda | Halaman list | Shipper | REQ-041, REQ-042, REQ-070…REQ-076, REQ-087…REQ-090, REQ-096 |
| **UI-T09** | `@screen-nav-lkl` | Navigasi TMS LKL (Darat/Laut/Udara) | Komponen global | Shipper (varian LKL) | REQ-078…REQ-094 |
| **UI-T10** | `@screen-form-order` | Form Order Shipper — `Jenis Pengiriman` | Wizard step 1 | Shipper | REQ-077, REQ-069 |
| **UI-T11** | `@screen-error` | Notifikasi/Toast & halaman error entitlement | State global | Semua | REQ-096, REQ-097, REQ-101 |

> Prefiks `UI-T` dipakai (mengikuti `oms022`, bukan `UI-D`/`UI-0xx` seperti `oms015`) agar ID tidak berbenturan saat beberapa dokumen dirujuk bersamaan oleh scenario-generator.

---

### UI-T00 — API Pengaturan Entitlement *(permukaan uji, bukan layar)*

**Deskripsi:** satu-satunya kanal untuk **mengubah** entitlement (**ASM-19** — tidak ada layar admin). Dipakai scenario-generator sebagai **langkah setup** untuk seluruh permukaan lain, **dan** sebagai objek uji tersendiri untuk R1.

**Kapan tampil / dipakai:** selalu — setiap skenario UI-T01…UI-T11 diawali satu `PATCH` untuk mengunci state entitlement, lalu `page.reload()` (ASM-37, ASM-38).

**Adaptasi kolom:** karena ini bukan DOM, kolom `Role+Name (ARIA)` diisi **JSON path / nama header**, dan kolom `data-testid` diisi **kunci fixture** yang disarankan (nama variabel pada test data), bukan atribut DOM.

| Elemen | Tipe | Selector — JSON path / header (pengganti ARIA) | Kunci fixture (usulan) | Nilai / contoh | Kondisi | REQ terkait |
|---|---|---|---|---|---|---|
| Endpoint | Path | `PATCH {baseUrl}/api/v1/service/registry/clients/{clientId}/entitlement` | `api.entitlement.path` | `apicore-staging.prahu-hub.com` (ASM-20) | selalu | REQ-001 |
| Method | HTTP verb | `PATCH` | `api.entitlement.method` | selain `PATCH` → `405` | selalu | REQ-001, V-23 |
| Header autentikasi | Header | `X-Admin-Key` | `env.ADMIN_KEY` | **`<X-Admin-Key>`** — **DILARANG hard-code**; inject dari secret/env (ASM-03) | wajib | REQ-002, REQ-009, REQ-010, V-02 |
| Header tipe konten | Header | `Content-Type` | `api.contentType` | `application/json` | wajib | REQ-003, V-03 |
| Path param | Param | `{clientId}` | `env.CLIENT_ID` | UUID v4 — **`<clientId>`** (ASM-03, ASM-12) | wajib | REQ-011, REQ-012, V-01 |
| Body — produk | Array\<string\> | `$.request.products` | `payload.products` | `["TMS"]` \| `["OMS"]` \| `["TMS","OMS"]` | wajib, minItems 1 | REQ-004, REQ-005, REQ-017, V-06…V-10 |
| Body — add-on | Array\<string\> | `$.request.addOns` | `payload.addOns` | subset dari 6 enum; `[]` sah | opsional, minItems 0 | REQ-006, REQ-016, V-11…V-15 |
| Status sukses | HTTP status | `response.status()` → `200` | `expect.statusOk` | `200` | payload valid | REQ-008 |
| Respons — produk | Array\<string\> | **`$.products`** (fallback `$.data.products` — ASM-27) | `resp.products` | `["TMS","OMS"]` | pada `200` | REQ-008, REQ-015 |
| Respons — add-on | Array\<string\> | **`$.addOns`** (fallback `$.data.addOns`) | `resp.addOns` | `["SERVICE_FTL"]` | pada `200` | REQ-007, REQ-008, REQ-016 |
| Respons — pesan | String | **`$.message`** | `resp.message` | mis. `Entitlement updated` | opsional | REQ-008 |
| Error — pesan | String | **`$.message`** | `err.message` | menyebut field & nilai yang ditolak | pada `4xx` | REQ-013, AC-013.3 |
| Error — detail field | Array/objek | `$.errors[0].field` \| `$.errors[0].message` (fallback `$.error.details[]`) | `err.field` | `products` \| `addOns` \| `clientId` | pada `400` | REQ-012, REQ-013 |
| Kebocoran kredensial | Assertion negatif | seluruh body & header respons | `expect.noAdminKeyLeak` | body **tidak** memuat nilai admin key | selalu | REQ-002, AC-002.2 |
| Read-back | Verifikasi | pembacaan ulang entitlement (`GET` atau efek UI) | `verify.readBack` | identik dengan `$.products`/`$.addOns` | setelah tiap request | REQ-008 (AC-008.3), REQ-009, REQ-013, V-17 |
| Audit trail | Entri log | `$.auditId` (bila ada) / verifikasi via jalur admin | `resp.auditId` | 1 entri per PATCH sukses | opsional | REQ-103 |

**Contoh respons yang diasumsikan (ASM-27, ASM-28)**

Sukses `200`:

```json
{ "products": ["TMS", "OMS"], "addOns": ["SERVICE_FTL", "SERVICE_LTL"] }
```

Gagal validasi `400`:

```json
{ "message": "Invalid value for field 'products': XMS", "errors": [{ "field": "products", "message": "must be one of TMS, OMS" }] }
```

Gagal autentikasi `401`:

```json
{ "message": "Unauthorized" }
```

Tidak ditemukan `404`:

```json
{ "message": "Client not found" }
```

**State yang harus dapat dibedakan**

| State | Indikator | Assertion usulan |
|---|---|---|
| **success** | `200` + entitlement terkini | `expect(res.status()).toBe(200)` + `expect(body.products ?? body.data.products).toEqual(['TMS'])` |
| **error — auth** | `401`, entitlement tidak berubah | status `401` **dan** read-back sama dengan nilai sebelum request |
| **error — validasi** | `400`, all-or-nothing | status `400` **dan** read-back **tidak** memuat nilai parsial (`TMS` tidak ikut tersimpan) |
| **error — not found** | `404`, tidak membuat client baru | status `404` |
| **error — method/media** | `405` / `415` | status sesuai V-03, V-23 |
| **idempoten** | dua PATCH identik → hasil sama | dua kali `200` + read-back identik |

**Pesan/notifikasi yang mungkin tampak:** hanya pada level API (`$.message`). Tidak ada toast UI karena tidak ada layar admin (**ASM-26**).

---

### UI-T01 — Login / Sesi Shipper & Vendor

**Deskripsi:** titik masuk untuk **melihat efek** entitlement. Bukan objek uji fungsional login, melainkan **prasyarat** dan **mekanisme propagasi** (R8).

**Kapan tampil:** awal setiap skenario UI. Berlaku pada seluruh state entitlement — **login tidak boleh gagal** karena entitlement, termasuk pada client tanpa produk aktif (REQ-101).

| Elemen | Tipe | Role+Name (ARIA) | data-testid (usulan) | Label/teks | State/Visibilitas per entitlement | REQ terkait |
|---|---|---|---|---|---|---|
| Root halaman login | Container | — | `login-page` | — | selalu tampil, tidak terpengaruh entitlement | REQ-101 |
| Judul | Heading h1 | `getByRole('heading', { level: 1 })` | `login-title` | `Masuk` \| `Login` (usulan) | selalu | — |
| Input email/username | `textbox` | `getByRole('textbox', { name: /email\|username\|pengguna/i })` | `login-email` | `Email` (usulan) | selalu, enabled | — |
| Input password | `textbox` (password) | `getByLabel(/password\|kata sandi/i)` | `login-password` | `Kata Sandi` (usulan) | selalu, enabled | — |
| Toggle lihat password | Button ikon | `getByRole('button', { name: /(lihat\|show).*(sandi\|password)/i })` | `login-password-toggle` | ikon mata | opsional | — |
| Tombol masuk | `button` submit | `getByRole('button', { name: /(masuk\|login\|sign in)/i })` | `login-submit` | `Masuk` (usulan) | enabled; **disabled** saat loading | — |
| Indikator loading | `status` | `getByRole('status')` | `login-loading` | spinner | transien — jangan dijadikan assertion blocking | ASM-25 (oms022) |
| Pesan error kredensial | `alert` | `getByRole('alert')` | `login-error` | `Email atau kata sandi salah` (usulan) | hanya pada kredensial salah — **bukan** akibat entitlement | REQ-101 |
| Konteks tenant (pasca-login) | Teks/badge | `getByText(/shipper\|vendor/i)` | `header-tenant-context` | `Shipper` \| `Vendor` ✅ (`oms015`) | menentukan sidebar mana yang di-assert (UI-T02 vs UI-T07) | REQ-050, REQ-057 |
| Badge peran | Badge | `getByText(/staff operasional\|admin/i)` | `header-role-badge` | `Staff Operasional` ✅ (`oms015`) | tidak terpengaruh entitlement | — |
| Menu profil / user | Menu | `getByRole('button', { name: /profil\|akun/i })` | `header-user` | email user | selalu | — |
| Tombol logout | Button ikon | `getByRole('button', { name: /(keluar\|logout)/i })` | `header-logout` | ikon keluar ✅ (`oms015`) | selalu — dipakai untuk **propagasi via logout-login** | REQ-095 (AC-095.2) |
| Ikon notifikasi | Button | `getByRole('button', { name: /notifikasi/i })` | `header-notification` | ikon bel ✅ (`oms015`) | selalu (`Pusat Notifikasi` ✓ di semua state) | REQ-049, REQ-056 |
| Versi aplikasi | Teks | — | `sidebar-app-version` | `Order Management System` / `Versi 1.0.0` ✅ (`oms015`) | selalu | — |

**Aksi propagasi (R8) — bukan elemen, tapi langkah wajib**

| Aksi | Implementasi Playwright | Ekspektasi | REQ |
|---|---|---|---|
| **Refresh** | `await page.reload()` | Navigasi merefleksikan entitlement baru | REQ-095, AC-095.1 |
| **Navigasi ulang** | klik menu lain lalu kembali | Idem | REQ-095 |
| **Logout → Login** | klik `header-logout` → isi ulang `login-*` → `login-submit` | Navigasi merefleksikan entitlement baru | REQ-095, AC-095.2 |
| **Tanpa refresh** | tidak melakukan apa pun setelah PATCH | Menu lama **boleh** tetap tampil (bukan bug), **tetapi** akses fiturnya sudah ditolak server | REQ-095, ALT-12, REQ-097 |
| **Tanpa clear cache** | tidak menghapus storage | Menu tetap berubah setelah refresh | AC-095.3 |

**State terlihat:** `empty` (form kosong) · `loading` (submit berjalan) · `error` (kredensial salah) · `success` (redirect ke dashboard/beranda) · **`success-minimal`** (client tanpa produk aktif → login berhasil, sidebar hanya 3 item — REQ-101).

**Pesan validasi/notifikasi yang mungkin tampak:** `Email atau kata sandi salah` (usulan). **Tidak boleh** muncul pesan bertema entitlement pada layar login — bila client tanpa produk gagal login, itu **defect** terhadap REQ-101 (AC-101.1).

---

### UI-T02 — Sidebar / Navigasi utama Shipper

**Deskripsi:** permukaan verifikasi **terbesar** modul ini — 20 item menu dari sheet `SH` dalam 4 grup. Visibilitas = **AND** antara filter `products` (R3) dan filter `addOns` (R6) — REQ-074.

**Kapan tampil:** setelah login sebagai **Shipper** pada seluruh state entitlement.

**Elemen kerangka**

| Elemen | Tipe | Role+Name (ARIA) | data-testid (usulan) | Label/teks | State/Visibilitas per entitlement | REQ terkait |
|---|---|---|---|---|---|---|
| Container sidebar | `navigation` | `getByRole('navigation')` | `sidebar-shipper` | — | selalu tampil di semua state | REQ-029 |
| Toggle sidebar | Button ikon | `getByRole('button', { name: /menu\|sidebar/i })` | `sidebar-toggle` | hamburger ✅ (`oms015`) | selalu | — |
| Logo / nama tenant | Link | `getByRole('link', { name: /<tenant>/i })` | `app-logo` | mis. `Mentari Sumber Kertas` ✅ (`oms015`) | selalu | — |
| Kartu kuota order | Widget | — | `sidebar-order-quota` | `Kuota Order` ✅ (`oms015`) | tidak diatur entitlement — **jangan** di-assert di modul ini | — |
| Indikator item aktif | State | `getByRole('link', { current: 'page' })` \| `aria-current="page"` | — | — | opsional | — |
| Grup `DASHBOARD` | Group header | `getByRole('navigation').getByText(/dashboard/i)` | `nav-group-dashboard` | `DASHBOARD` ✅ | selalu (min. 1 anak selalu ✓) | REQ-029 (AC-029.3) |
| Grup `MENU UTAMA` | Group header | `getByText(/menu utama/i)` | `nav-group-menu-utama` | `MENU UTAMA` ✅ | selalu | REQ-029 |
| Grup `MASTER OPERASIONAL` | Group header / collapsible | `getByRole('button', { name: /master operasional/i })` | `nav-group-master-operasional` | `MASTER OPERASIONAL` ✅ | selalu (ASM-25) | REQ-029 |
| Grup `MENU LAINNYA` | Group header | `getByText(/menu lainnya/i)` | `nav-group-menu-lainnya` | `MENU LAINNYA` ✅ | selalu | REQ-029 |

**Item menu — grup `DASHBOARD`** *(sheet `SH` baris 1–5; detail elemen ada di **UI-T03** — di sidebar diasumsikan satu link `Dashboard` dengan 5 tab di dalamnya, **ASM-24**)*

| Elemen | Tipe | Role+Name (ARIA) | data-testid (usulan) | Label/teks | `P-TMS` / `P-OMS` / `P-BOTH` + dependensi add-on | REQ terkait |
|---|---|---|---|---|---|---|
| `Dashboard` (link induk) | Link | `getByRole('link', { name: /^dashboard/i })` | `nav-item-dashboard` | `Dashboard` (usulan) | ✓ / ✓ / ✓ — selalu ada (min. 1 tab ✓) | REQ-029 |
| `Dashboard - Monitoring` | Link/tab | `getByRole('link', { name: /monitoring/i })` | `nav-item-dashboard-monitoring` | `Dashboard - Monitoring` ✅ | ✓ / ✓ / ✓ **(TMS)** | REQ-030 |
| `Dashboard - Tracking & Location` | Link/tab | `getByRole('link', { name: /tracking\s*&?\s*location/i })` | `nav-item-dashboard-tracking-location` | `Dashboard - Tracking & Location` ✅ | ✓ / **✗** / ✓ **(TMS)** | REQ-031 |
| `Dashboard - Progress Pengiriman` | Link/tab | `getByRole('link', { name: /progress pengiriman/i })` | `nav-item-dashboard-progress-pengiriman` | `Dashboard - Progress Pengiriman` ✅ | ✓ / **✗** / ✓ **(TMS)** — **AND** `A-DARAT`; **✗** bila `A-LAUT` saja atau `A-NONE` | REQ-032, REQ-072, REQ-075 |
| `Dashboard - Operasional` | Link/tab | `getByRole('link', { name: /operasional/i })` | `nav-item-dashboard-operasional` | `Dashboard - Operasional` ✅ | ✓ / ✓ / ✓ **(TMS)** | REQ-033 |
| `Dashboard - Distribusi & Muatan` | Link/tab | `getByRole('link', { name: /distribusi\s*&?\s*muatan/i })` | `nav-item-dashboard-distribusi-muatan` | `Dashboard - Distribusi & Muatan` ✅ | **✗** / ✓ / ✓ **(OMS)** | REQ-034 |

**Item menu — grup `MENU UTAMA`**

| Elemen | Tipe | Role+Name (ARIA) | data-testid (usulan) | Label/teks | `P-TMS` / `P-OMS` / `P-BOTH` + dependensi add-on | REQ terkait |
|---|---|---|---|---|---|---|
| `Order` | Link | `getByRole('link', { name: /^order$/i })` | `nav-item-order` *(alias `oms015`: `nav-order`)* | `Order` ✅ | ✓ / ✓ / ✓ **(OMS)** | REQ-035 |
| `Simulasi Muatan` | Link | `getByRole('link', { name: /simulasi muatan/i })` | `nav-item-simulasi-muatan` *(alias: `nav-simulasi-muatan`)* | `Simulasi Muatan` ✅ | **✗** / ✓ / ✓ **(OMS)** — **AND** `A-STUFF`; **✗** tanpa `AUTO_STUFFING` meski OMS aktif | REQ-036, REQ-076, ASM-10 |
| `Penugasan Tracking` | Link | `getByRole('link', { name: /penugasan tracking/i })` | `nav-item-penugasan-tracking` | `Penugasan Tracking` ✅ | ✓ / ✓ / ✓ **(TMS)** — perilaku, bukan hanya tampilan (UI-T04) | REQ-020, REQ-037 |
| `Master Wilayah` | Link | `getByRole('link', { name: /master wilayah/i })` | `nav-item-master-wilayah` | `Master Wilayah` ✅ | ✓ / ✓ / ✓ *(Setara)* | REQ-038 |

**Item menu — grup `MASTER OPERASIONAL`**

| Elemen | Tipe | Role+Name (ARIA) | data-testid (usulan) | Label/teks | `P-TMS` / `P-OMS` / `P-BOTH` + dependensi add-on | REQ terkait |
|---|---|---|---|---|---|---|
| `Master Barang` | Link | `getByRole('link', { name: /master barang/i })` | `nav-item-master-barang` | `Master Barang` ✅ | **✗** / ✓ / ✓ **(OMS)** | REQ-039 |
| `Master Drop Point (Include Customer)` | Link | `getByRole('link', { name: /master drop point/i })` | `nav-item-master-drop-point` | `Master Drop Point` ✅ *(xlsx: `(Include Customer)`)* | ✓ / ✓ / ✓ *(Setara)* | REQ-040 |
| `Master Pelabuhan` | Link | `getByRole('link', { name: /master pelabuhan/i })` | `nav-item-master-pelabuhan` | `Master Pelabuhan` ✅ | ✓ / ✓ / ✓ *(Setara)* — **AND** `A-LAUT`; **✗** bila `A-DARAT` saja atau `A-NONE` | REQ-041, REQ-070, REQ-074, REQ-075 |
| `Master Pelayaran` | Link | `getByRole('link', { name: /master pelayaran/i })` | `nav-item-master-pelayaran` | `Master Pelayaran` ✅ | ✓ / ✓ / ✓ *(Setara)* — **AND** `A-LAUT`; **✗** bila `A-DARAT` saja atau `A-NONE` | REQ-042, REQ-071, REQ-075 |
| `Master Unit (Armada)` | Link | `getByRole('link', { name: /master unit\|armada/i })` | `nav-item-master-unit` | `Master Unit` ✅ *(xlsx: `(Armada - Vendor dikelola Admin)`)* | ✓ / ✓ / ✓ **(TMS)** | REQ-043 |
| `Master Sopir` | Link | `getByRole('link', { name: /master sopir/i })` | `nav-item-master-sopir` | `Master Sopir` ✅ *(xlsx: `(Vendor dikelola Admin)`)* | ✓ / ✓ / ✓ **(TMS)** | REQ-044 |

**Item menu — grup `MENU LAINNYA`**

| Elemen | Tipe | Role+Name (ARIA) | data-testid (usulan) | Label/teks | `P-TMS` / `P-OMS` / `P-BOTH` + dependensi add-on | REQ terkait |
|---|---|---|---|---|---|---|
| `Manajemen Vendor` | Link | `getByRole('link', { name: /manajemen vendor/i })` | `nav-item-manajemen-vendor` | `Manajemen Vendor` ✅ | ✓ / ✓ / ✓ *(Setara)* — **tidak** boleh muncul di sidebar Vendor | REQ-045, REQ-057 |
| `Pengaturan Akun` | Link | `getByRole('link', { name: /pengaturan akun/i })` | `nav-item-pengaturan-akun` | `Pengaturan Akun` ✅ | ✓ / ✓ / ✓ *(Setara)* — tetap tampil pada fallback entitlement kosong | REQ-046, REQ-101 |
| `Akun Saya` | Link | `getByRole('link', { name: /akun saya/i })` | `nav-item-akun-saya` | `Akun Saya` ✅ | ✓ / ✓ / ✓ *(Setara)* — tetap tampil pada fallback entitlement kosong | REQ-047, REQ-101 |
| `Pengaturan Sistem` | Link | `getByRole('link', { name: /pengaturan sistem/i })` | `nav-item-pengaturan-sistem` | `Pengaturan Sistem` ✅ | ✓ / ✓ / ✓ **(TMS)** — **isi halaman** berbeda per produk (UI-T06) | REQ-048, REQ-058 |
| `Pusat Notifikasi` | Link | `getByRole('link', { name: /pusat notifikasi/i })` | `nav-item-pusat-notifikasi` | `Pusat Notifikasi` ✅ | ✓ / ✓ / ✓ **(TMS)** — tetap tampil pada fallback entitlement kosong | REQ-049, REQ-101 |

**Matriks assertion ringkas per state (untuk scenario-generator)**

| State entitlement | Menu yang **WAJIB ADA** | Menu yang **WAJIB ABSEN** (`toHaveCount(0)`) | REQ |
|---|---|---|---|
| `P-TMS` + `A-DARAT` | Monitoring, Tracking & Location, Progress Pengiriman, Operasional, Order, Penugasan Tracking, Master Wilayah, Master Drop Point, Master Unit, Master Sopir, Manajemen Vendor, Pengaturan Akun, Akun Saya, Pengaturan Sistem, Pusat Notifikasi | Distribusi & Muatan, Simulasi Muatan, Master Barang, Master Pelabuhan, Master Pelayaran | REQ-029…REQ-049, REQ-070…REQ-072 |
| `P-TMS` + `A-LAUT` | idem, **plus** Master Pelabuhan, Master Pelayaran | **plus** Progress Pengiriman | REQ-070…REQ-072 |
| `P-OMS` + `A-DARAT` + `A-STUFF` | Monitoring, Operasional, Distribusi & Muatan, Order, **Simulasi Muatan**, Penugasan Tracking, Master Wilayah, Master Barang, Master Drop Point, Master Unit, Master Sopir, Manajemen Vendor, Pengaturan Akun, Akun Saya, Pengaturan Sistem, Pusat Notifikasi | Tracking & Location, **Progress Pengiriman**, Master Pelabuhan, Master Pelayaran | REQ-031, REQ-032, REQ-036, REQ-074 |
| `P-OMS` + `A-LAUT`, tanpa `AUTO_STUFFING` | + Master Pelabuhan, Master Pelayaran | **Simulasi Muatan** absen | REQ-076, ALT-23 |
| `P-BOTH` + darat & laut + `A-STUFF` | **union** seluruh 20 item | — | REQ-073, ASM-05 |
| `P-TMS`/`P-OMS` + `A-NONE` | menu non-moda saja | Master Pelabuhan, Master Pelayaran, Progress Pengiriman | REQ-075 |
| Produk kosong *(fallback)* | Pengaturan Akun, Akun Saya, Pusat Notifikasi | seluruh menu operasional lainnya | REQ-101 |

**State terlihat:** `default` (sidebar terisi) · `collapsed` (via `sidebar-toggle`) · `hidden` (item tidak dirender — state paling sering diuji) · `active` (item terpilih). **Tidak diasumsikan** adanya state `disabled` pada item menu — hipotesis kerja: item non-entitle **dihapus dari DOM**, bukan di-*disable* (**ASM-31**). Bila implementasi ternyata memakai `disabled`, ini **defect terhadap semangat REQ-029** dan wajib dilaporkan, bukan diakomodasi diam-diam.

**Pesan/notifikasi:** tidak ada pesan pada sidebar. Efek "menu hilang" bersifat senyap — karena itu pasangkan selalu dengan UI-T11 (guard 403).

---

### UI-T03 — Dashboard Shipper

**Deskripsi:** halaman dashboard dengan 5 permukaan dari sheet `SH` grup `DASHBOARD`. Diasumsikan berupa **tab atau kartu** dalam satu halaman `/dashboard` (**ASM-24**); bila implementasi memakai 5 route terpisah, selector `dashboard-tab-*` diganti `nav-item-dashboard-*` dan sisanya tetap berlaku.

**Kapan tampil:** setelah login Shipper, pada seluruh state produk (minimal satu tab selalu ter-*entitle*).

| Elemen | Tipe | Role+Name (ARIA) | data-testid (usulan) | Label/teks | State/Visibilitas per entitlement | REQ terkait |
|---|---|---|---|---|---|---|
| Root halaman | Container | — | `dashboard-page` | — | selalu | REQ-029 |
| Judul halaman | Heading h1 | `getByRole('heading', { level: 1, name: /dashboard/i })` | `dashboard-title` | `Dashboard` (usulan) | selalu | — |
| Tablist | `tablist` | `getByRole('tablist')` | `dashboard-tabs` | — | selalu | — |
| Tab `Monitoring` | `tab` | `getByRole('tab', { name: /monitoring/i })` | `dashboard-tab-monitoring` | `Monitoring` ✅ | `P-TMS` ✓ · `P-OMS` ✓ · `P-BOTH` ✓ **(TMS)** | REQ-030 |
| Tab `Tracking & Location` | `tab` | `getByRole('tab', { name: /tracking\s*&?\s*location/i })` | `dashboard-tab-tracking-location` | `Tracking & Location` ✅ | `P-TMS` ✓ · `P-OMS` **✗** · `P-BOTH` ✓ **(TMS)** | REQ-031 |
| Tab `Progress Pengiriman` | `tab` | `getByRole('tab', { name: /progress pengiriman/i })` | `dashboard-tab-progress-pengiriman` | `Progress Pengiriman` ✅ | `P-TMS` **AND** `A-DARAT` → ✓ · `P-TMS` + `A-LAUT` saja → **✗** · `P-OMS` → **✗** (apa pun add-on-nya) · `A-NONE` → **✗** | REQ-032, REQ-072, REQ-074, REQ-075 |
| Tab `Operasional` | `tab` | `getByRole('tab', { name: /operasional/i })` | `dashboard-tab-operasional` | `Operasional` ✅ | `P-TMS` ✓ · `P-OMS` ✓ · `P-BOTH` ✓ **(TMS)** | REQ-033 |
| Tab `Distribusi & Muatan` | `tab` | `getByRole('tab', { name: /distribusi\s*&?\s*muatan/i })` | `dashboard-tab-distribusi-muatan` | `Distribusi & Muatan` ✅ | `P-TMS` **✗** · `P-OMS` ✓ · `P-BOTH` ✓ **(OMS)** | REQ-034 |
| Panel isi tab aktif | `tabpanel` | `getByRole('tabpanel')` | `dashboard-panel` | — | mengikuti tab aktif | REQ-030…REQ-034 |
| Kartu/widget di dalam panel | Widget | — | `dashboard-card-<slug>` | tidak diketahui (tanpa desain) | **jangan** di-assert isinya — di luar cakupan modul | ASM-28 (oms022, analog) |
| Empty state panel | Container | — | `dashboard-empty` | mis. `Belum ada data` (usulan) | mungkin muncul pada tenant baru — non-blocking | — |
| Skeleton/loading | `status` | `getByRole('status')` | `dashboard-loading` | — | transien — non-blocking | — |

**State terlihat:** `default` · `loading` · `empty` (widget tanpa data) · `hidden` (tab tidak dirender — **state utama yang diuji**). Tidak ada state `error` khusus entitlement pada halaman ini; kegagalan entitlement dimanifestasikan sebagai **tab yang hilang**.

**Assertion kritikal (kombinasi dua filter — REQ-074):**

| Skenario | Ekspektasi |
|---|---|
| `products:["TMS"]`, `addOns:["SERVICE_LTL"]` | `dashboard-tab-progress-pengiriman` **ADA** |
| `products:["TMS"]`, `addOns:["SERVICE_FCL","SERVICE_LCL"]` | `dashboard-tab-progress-pengiriman` **`toHaveCount(0)`** |
| `products:["OMS"]`, `addOns:["SERVICE_FTL"]` | `dashboard-tab-progress-pengiriman` **`toHaveCount(0)`** (gagal filter produk meski lolos filter add-on) |
| `products:["TMS","OMS"]`, darat+laut | ke-5 tab **ADA** |

**Pesan/notifikasi:** tidak ada pesan validasi. Bila tab yang hilang tetap dapat dibuka via URL/hash langsung → **defect REQ-096**.

---

### UI-T04 — Penugasan Tracking (Shipper & Vendor) — **inti modul**

**Deskripsi:** permukaan tempat aturan **R2** diverifikasi. Perbedaan TMS vs OMS di sini **bukan** show/hide melainkan **jalur data**: penugasan ke sopir masuk apps (TMS) atau tidak (OMS). Menu ini **selalu tampil** pada semua state produk — sehingga assertion visibilitas saja **tidak cukup**; wajib dilanjutkan ke UI-T05.

**Kapan tampil:** `P-TMS`, `P-OMS`, `P-BOTH` — sisi **Shipper** (REQ-020, REQ-037) maupun **Vendor** (REQ-052).

**Daftar penugasan / order**

| Elemen | Tipe | Role+Name (ARIA) | data-testid (usulan) | Label/teks | State/Visibilitas per entitlement | REQ terkait |
|---|---|---|---|---|---|---|
| Root halaman | Container | — | `assignment-page` | — | ✓ pada `P-TMS`/`P-OMS`/`P-BOTH` | REQ-020 |
| Judul halaman | Heading h1 | `getByRole('heading', { level: 1, name: /penugasan tracking/i })` | `assignment-title` | `Penugasan Tracking` ✅ | ✓ semua state | REQ-020 |
| Tabel daftar | `table` | `getByRole('table')` | `assignment-list` | — | ✓ semua state | REQ-020 |
| Baris penugasan | `row` | `getByRole('row', { name: /<idOrder>/i })` | `assignment-row-<idOrder>` | mis. `ORD769797FSH` (pola `oms015`) | ✓ semua state; baris lama **tetap ada** setelah entitlement berubah | REQ-028, REQ-100 |
| Badge status penugasan | Badge | `row.getByTestId('assignment-row-status')` | `assignment-row-status` | `Menunggu Penugasan` \| `Ditugaskan` (pola `oms015`) | tidak berubah otomatis saat produk diubah | REQ-028, REQ-100 |
| Kolom pelaksana | Cell | `row.getByTestId('assignment-row-assignee')` | `assignment-row-assignee` | nama Sopir / Pengurus | ✓ semua state | REQ-021 |
| **Badge kanal penyampaian** | Badge | `row.getByTestId('assignment-row-channel')` | `assignment-row-channel` | usulan: `Aplikasi Sopir` \| `Input Web` (**ASM-33**) | `P-TMS`/`P-BOTH` + Sopir → `Aplikasi Sopir`; `P-OMS` + Sopir → `Input Web`; Pengurus → selalu `Input Web` | REQ-022…REQ-027 |
| Tombol buat penugasan | `button` | `getByRole('button', { name: /(tugaskan\|buat penugasan\|assign)/i })` | `assignment-create` | `Tugaskan` (usulan) | ✓ semua state | REQ-021 |
| Empty state daftar | Container | — | `assignment-empty` | `Belum ada penugasan` (usulan) | tenant baru | — |
| Loading daftar | `status` | `getByRole('status')` | `assignment-loading` | — | transien | — |

**Form penugasan (modal/halaman)**

| Elemen | Tipe | Role+Name (ARIA) | data-testid (usulan) | Label/teks | State/Visibilitas per entitlement | REQ terkait |
|---|---|---|---|---|---|---|
| Container form | `dialog` / `form` | `getByRole('dialog', { name: /penugasan/i })` | `assignment-form` | — | ✓ semua state | REQ-021 |
| **Pilih tipe penerima tugas** | `radiogroup` (fallback `combobox`, **ASM-32**) | `getByRole('radiogroup', { name: /(jenis\|tipe).*(penerima\|pelaksana\|petugas)/i })` | `assignment-assignee-type` | `Tipe Penerima Tugas` (usulan) | ✓ pada TMS **dan** OMS — **kedua opsi selalu tersedia** | REQ-021, AC-021.1, AC-021.2 |
| Opsi **`Sopir`** | `radio` | `getByRole('radio', { name: /^sopir/i })` | `assignment-assignee-type-sopir` | `Sopir` ✅ *(glosarium)* | ✓ `P-TMS` · ✓ `P-OMS` · ✓ `P-BOTH` — **tidak boleh disabled pada OMS** (REQ-024, AC-024.1) | REQ-021, REQ-024 |
| Opsi **`Pengurus`** | `radio` | `getByRole('radio', { name: /^pengurus/i })` | `assignment-assignee-type-pengurus` | `Pengurus` ✅ *(glosarium)* | ✓ semua state | REQ-021, REQ-023, REQ-025 |
| Dropdown pilih sopir | `combobox` | `getByRole('combobox', { name: /sopir/i })` | `assignment-driver-select` | placeholder `Pilih Sopir` (usulan, pola `oms015`) | tampil hanya saat opsi `Sopir` terpilih; sumber data = `Master Sopir` | REQ-021, REQ-044 |
| Dropdown pilih pengurus | `combobox` | `getByRole('combobox', { name: /pengurus/i })` | `assignment-handler-select` | placeholder `Pilih Pengurus` (usulan) | tampil hanya saat opsi `Pengurus` terpilih | REQ-021 |
| Pilih order/perjalanan | `combobox` | `getByRole('combobox', { name: /(order\|perjalanan)/i })` | `assignment-order-select` | placeholder `Pilih Order` (usulan) | ✓ semua state | UF-2 step 3 |
| **Hint kanal penyampaian** | Teks bantu | `getByText(/(masuk ke aplikasi sopir\|input tracking dari web)/i)` | `assignment-channel-hint` | usulan: `Penugasan akan masuk ke aplikasi sopir` / `Tracking diinput dari web` (**ASM-33**) | `P-TMS`+Sopir → teks apps · `P-OMS`+Sopir → teks web · Pengurus → teks web | REQ-022…REQ-027 |
| Tombol simpan | `button` submit | `getByRole('button', { name: /(simpan\|tugaskan\|submit)/i })` | `assignment-submit` | `Simpan` (usulan) | enabled setelah field wajib terisi | UF-2 step 4 |
| Tombol batal | `button` | `getByRole('button', { name: /(batal\|tutup)/i })` | `assignment-cancel` | `Batal` (usulan) | selalu | — |
| Dialog konfirmasi | `dialog` | `getByRole('dialog', { name: /konfirmasi/i })` | `assignment-confirm-dialog` | `Simpan penugasan?` (usulan, pola `oms015`) | opsional | — |
| Pesan validasi field | `alert` | `getByRole('alert')` | `assignment-form-error` | `Sopir harus diisi` \| `Pengurus harus diisi` (usulan, pola `oms015`) | muncul saat submit tanpa memilih pelaksana | ASM-21 (oms022, analog) |
| Toast sukses | `status`/`alert` | `getByRole('status')` | `toast-success` | `Penugasan berhasil disimpan` (usulan) | pada seluruh state produk — **termasuk OMS + Sopir** | REQ-024, AC-024.1 |

**Form input tracking manual oleh Pengurus (web)**

| Elemen | Tipe | Role+Name (ARIA) | data-testid (usulan) | Label/teks | State/Visibilitas per entitlement | REQ terkait |
|---|---|---|---|---|---|---|
| Container form tracking | `form` | `getByRole('form', { name: /tracking\|progres/i })` | `tracking-input-form` | — | ✓ `P-TMS` · ✓ `P-OMS` · ✓ `P-BOTH` — **jalur web selalu ada** | REQ-023, REQ-025, REQ-027 |
| Pilih status/progres | `combobox` | `getByRole('combobox', { name: /status/i })` | `tracking-status-select` | mis. `Selesai Muat`, `Selesai Bongkar` (lihat `oms022`) | ✓ semua state | REQ-027 |
| Waktu kejadian | `textbox` (datetime) | `getByLabel(/(waktu\|tanggal)/i)` | `tracking-datetime` | `Waktu` (usulan) | ✓ semua state | REQ-027 |
| Lokasi | `textbox` | `getByLabel(/lokasi/i)` | `tracking-location` | `Lokasi` (usulan) | ✓ semua state | REQ-027 |
| Catatan | `textbox` | `getByLabel(/(catatan\|keterangan)/i)` | `tracking-note` | `Catatan` (usulan) | opsional | — |
| Unggah foto/bukti | `button`/input file | `getByRole('button', { name: /(unggah\|upload\|foto)/i })` | `tracking-photo` | `Unggah Foto` (usulan) | opsional | — |
| Tombol simpan tracking | `button` submit | `getByRole('button', { name: /simpan/i })` | `tracking-submit` | `Simpan` (usulan) | ✓ semua state | REQ-023, REQ-025, REQ-027 |

**Perbedaan perilaku TMS vs OMS vs gabungan — tabel state inti**

| # | State produk | Pelaksana dipilih | Penugasan tersimpan? | Masuk apps sopir (UI-T05)? | Jalur input progres | Assertion utama | REQ / AC |
|---|---|---|---|---|---|---|---|
| 1 | `P-TMS` | **Sopir** | ✓ `toast-success` | **✓ YA** | apps sopir | daftar tugas sopir memuat penugasan | REQ-022, AC-022.1–022.3 |
| 2 | `P-TMS` | **Pengurus** | ✓ | **✗ TIDAK** | web (`tracking-input-form`) | daftar tugas sopir **`toHaveCount(0)`** | REQ-023, AC-023.1–023.2 |
| 3 | `P-OMS` | **Sopir** | ✓ — **tidak diblokir** | **✗ TIDAK** | web | penugasan tersimpan **DAN** apps sopir kosong **DAN** tidak ada push notif | REQ-024, AC-024.1–024.3 |
| 4 | `P-OMS` | **Pengurus** | ✓ | **✗ TIDAK** | web | identik baris 2 | REQ-025, AC-025.1–025.3 |
| 5 | `P-BOTH` | **Sopir** | ✓ | **✓ YA** *(Ikut TMS)* | apps sopir | identik baris 1, berlaku untuk order asal alur OMS maupun TMS | REQ-026, ASM-11 |
| 6 | `P-BOTH` | **Pengurus** | ✓ | ✗ | web | identik baris 2 | REQ-023, REQ-025 |
| 7 | `P-TMS` → diubah ke `P-OMS` | Sopir (penugasan **lama**) | tetap ada | penugasan **lama tidak dibatalkan** | — | daftar penugasan tetap memuat baris lama | REQ-028, AC-028.1–028.2, ALT-27 |
| 8 | `P-TMS` → diubah ke `P-OMS` | Sopir (penugasan **baru**) | ✓ | **✗ TIDAK** | web | penugasan baru tidak masuk apps | REQ-028 (AC-028.3), ALT-27 |
| 9 | Vendor pada client `P-TMS` | Sopir | ✓ | **✓ YA** | apps sopir | identik baris 1 dari kanal Vendor | REQ-052, AC-052.2 |
| 10 | Vendor pada client `P-OMS` | Sopir | ✓ | **✗ TIDAK** | web | identik baris 3 dari kanal Vendor | REQ-052, AC-052.3 |

**State terlihat:** `empty` (belum ada penugasan) · `loading` · `success` (toast setelah simpan) · `error` (validasi field) · `disabled` (tombol simpan sebelum field wajib terisi). **Yang TIDAK boleh terjadi:** opsi `Sopir` ber-state `disabled` atau form menolak simpan pada `P-OMS` — itu **defect terhadap REQ-024 (AC-024.1)**.

**Pesan validasi/notifikasi yang mungkin tampak:**

| Kondisi | Pesan usulan | Matcher yang disarankan | Sumber |
|---|---|---|---|
| Simpan tanpa memilih tipe pelaksana | `Tipe Penerima Tugas harus diisi` | `/(harus diisi\|wajib diisi\|tidak boleh kosong)/i` | pola `oms015` (usulan) |
| Simpan tanpa memilih sopir | `Sopir harus diisi` | idem | pola `oms015` (usulan) |
| Simpan berhasil | `Penugasan berhasil disimpan` | `/(berhasil\|sukses)/i` | usulan |
| Akses saat menu tidak ter-*entitle* | lihat **UI-T11** | `/(tidak tersedia\|tidak memiliki akses\|403)/i` | REQ-096 |

> **Peringatan akurasi:** seluruh teks pada tabel di atas **tidak** bersumber dari desain maupun spec. Skenario sebaiknya meng-assert **keberadaan** elemen `role=alert`/`assignment-form-error` dan **tertahannya submit**, bukan teks persis (**ASM-33**).

---

### UI-T05 — Aplikasi Mobile Sopir *(permukaan verifikasi, di luar DOM web)*

**Deskripsi:** permukaan tempat **konsekuensi** aturan R2 diverifikasi. Aplikasi sopir adalah **aplikasi mobile native**, sehingga **tidak dapat diotomasi Playwright web** (**ASM-29**). Verifikasi dilakukan lewat **kanal pengganti**.

**Kapan diverifikasi:** setiap skenario UI-T04 baris 1–5, 8–10.

| Elemen / Sinyal | Tipe | Selector / kanal verifikasi (pengganti ARIA) | Kunci fixture (usulan) | Label/teks | State per entitlement | REQ terkait |
|---|---|---|---|---|---|---|
| Daftar tugas sopir | Response API | `GET /…/driver/{driverId}/assignments` → `$.data[]` (endpoint **belum diketahui** — ASM-29) | `driver.assignmentList` | — | `P-TMS`/`P-BOTH` → memuat penugasan · `P-OMS` → **tidak memuat** | REQ-022, REQ-024, REQ-026 |
| Entri penugasan | Item array | `$.data[?(@.orderId=='<idOrder>')]` | `driver.assignmentItem` | — | ✓ TMS · ✗ OMS | REQ-022, AC-022.1 / REQ-024, AC-024.2 |
| Jumlah entri | Assertion | `expect(body.data).toHaveLength(0)` pada `P-OMS` | `driver.assignmentCount` | — | **assertion negatif utama modul** | AC-024.2 |
| Push notification | Event | log notifikasi / mock push provider | `driver.pushEvent` | — | `P-TMS` → 1 event · `P-OMS` → **0 event** | AC-024.3 |
| Pelaporan progres dari apps | Efek | timeline tracking di web bertambah entri bersumber apps | `tracking-timeline` (lihat `oms022`: `history-list`, `history-item`) | — | `P-TMS` ✓ · `P-OMS` **✗ tidak ada kanal apps** | REQ-022 (AC-022.3), REQ-027 |
| UI daftar tugas (native) | Layar mobile | **di luar cakupan Playwright** — verifikasi manual / Appium bila tersedia | — | `Daftar Tugas` (usulan) | — | ASM-29 |

**Strategi eksekusi yang disarankan (urut prioritas):**

1. **API sopir** — panggil endpoint daftar tugas dengan token sopir, assert isi/`length`. Paling deterministik.
2. **Efek tidak langsung di web** — assert timeline tracking (`oms022` `history-list`/`history-item`) **tidak** bertambah dari kanal apps pada `P-OMS`.
3. **Manual/Appium** — hanya bila kanal 1 dan 2 tidak tersedia; ditandai sebagai skenario **manual** pada output scenario-generator.

**State terlihat (bila UI native diuji manual):** `empty` (tidak ada tugas — kondisi wajib pada `P-OMS`) · `terisi` (kondisi wajib pada `P-TMS`/`P-BOTH`) · `loading`.

**Pesan/notifikasi:** tidak ada pesan error yang diharapkan pada `P-OMS` — penugasan **senyap** tidak muncul. **Jangan** meng-assert adanya pesan "penugasan ditolak" di apps.

---

### UI-T06 — Pengaturan Sistem

**Deskripsi:** halaman dengan 8 item dari sheet `PS`. Menu induknya selalu tampil (REQ-048), tetapi **isinya** berubah menurut `products`: **8 item** pada `P-TMS`/`P-BOTH`, **tepat 2 item** pada `P-OMS`.

**Kapan tampil:** semua state produk (via `nav-item-pengaturan-sistem`). Tidak dipengaruhi `addOns`.

| Elemen | Tipe | Role+Name (ARIA) | data-testid (usulan) | Label/teks | `P-TMS` / `P-OMS` / `P-BOTH` | REQ terkait |
|---|---|---|---|---|---|---|
| Root halaman | Container | — | `system-settings-page` | — | ✓ / ✓ / ✓ | REQ-048, REQ-058 |
| Judul halaman | Heading h1 | `getByRole('heading', { level: 1, name: /pengaturan sistem/i })` | `system-settings-title` | `Pengaturan Sistem` ✅ | ✓ / ✓ / ✓ | REQ-048 |
| Container daftar item | List/section | `getByRole('list')` | `system-settings-list` | — | ✓ / ✓ / ✓ — dipakai untuk `toHaveCount(8\|2)` | REQ-067, REQ-068 |
| `Durasi Kedaluwarsa Undangan Vendor` | Item/kartu setting | `getByRole('heading', { name: /durasi kedaluwarsa undangan vendor/i })` | `setting-item-durasi-undangan-vendor` | `Durasi Kedaluwarsa Undangan Vendor` ✅ | ✓ / **✓** / ✓ | REQ-059 |
| `Notifikasi Lokasi` | Item/kartu setting | `getByRole('heading', { name: /notifikasi lokasi/i })` | `setting-item-notifikasi-lokasi` | `Notifikasi Lokasi` ✅ | ✓ / **✗** / ✓ | REQ-060 |
| `Deteksi Tidak Update` | Item/kartu setting | `getByRole('heading', { name: /deteksi tidak update/i })` | `setting-item-deteksi-tidak-update` | `Deteksi Tidak Update` ✅ | ✓ / **✗** / ✓ | REQ-061 |
| `Deteksi Keluar Jalur` | Item/kartu setting | `getByRole('heading', { name: /deteksi keluar jalur/i })` | `setting-item-deteksi-keluar-jalur` | `Deteksi Keluar Jalur` ✅ | ✓ / **✗** / ✓ | REQ-062 |
| `Koridor Historis` | Item/kartu setting | `getByRole('heading', { name: /korido[re] historis/i })` | `setting-item-koridor-historis` | `Koridor Historis` ✅ *(xlsx typo: `Koridoe Historis` — **ASM-14**)* | ✓ / **✗** / ✓ | REQ-063 |
| `Notifikasi Dini Berisiko Terlambat` | Item/kartu setting | `getByRole('heading', { name: /notifikasi dini.*terlambat/i })` | `setting-item-notifikasi-dini-terlambat` | `Notifikasi Dini Berisiko Terlambat` ✅ | ✓ / **✗** / ✓ | REQ-064 |
| `Nomor WhatsApp CS` | Item/kartu setting | `getByRole('heading', { name: /nomor whatsapp cs/i })` | `setting-item-nomor-whatsapp-cs` | `Nomor WhatsApp CS` ✅ | ✓ / **✓** / ✓ | REQ-065 |
| `Pembatasan Kelayakan Armada` | Item/kartu setting | `getByRole('heading', { name: /pembatasan kelayakan armada/i })` | `setting-item-pembatasan-kelayakan-armada` | `Pembatasan Kelayakan Armada` ✅ | ✓ / **✗** / ✓ | REQ-066 |
| Kontrol on/off per item | `switch`/`checkbox` | `getByRole('switch', { name: /<nama item>/i })` | `setting-toggle-<slug>` | — | mengikuti visibilitas item induknya | REQ-058 |
| Input nilai per item | `textbox`/`spinbutton` | `getByLabel(/<nama item>/i)` | `setting-input-<slug>` | mis. durasi (hari), nomor WA | mengikuti item induk | REQ-058 |
| Tombol simpan | `button` | `getByRole('button', { name: /simpan/i })` | `system-settings-save` | `Simpan` (usulan) | ✓ / ✓ / ✓ | — |
| Toast sukses simpan | `status` | `getByRole('status')` | `toast-success` | `Pengaturan berhasil disimpan` (usulan) | ✓ / ✓ / ✓ | — |
| Nilai tersimpan pasca-reaktivasi | Assertion | nilai pada `setting-input-<slug>` | — | — | setelah produk dicabut lalu diaktifkan lagi, nilai **kembali seperti terakhir** | REQ-099, AC-099.3 |

**Assertion kardinalitas (satu-satunya tempat angka absolut diizinkan):**

| State | Assertion | REQ |
|---|---|---|
| `P-TMS` | `expect(getByTestId('system-settings-list').getByRole('listitem')).toHaveCount(8)` | REQ-058 |
| `P-BOTH` | `toHaveCount(8)` + ke-8 label sesuai matriks `PS` | REQ-067, AC-067.1–067.2 |
| `P-OMS` | `toHaveCount(2)` + hanya `setting-item-durasi-undangan-vendor` & `setting-item-nomor-whatsapp-cs` | REQ-068, AC-068.1–068.2 |
| `P-OMS` + akses langsung | route/anchor 6 item TMS-only ditolak (403/redirect) | REQ-068 (AC-068.3), REQ-096 |

**State terlihat:** `default` (8 item) · `reduced` (2 item pada OMS) · `hidden` (item TMS-only tidak dirender) · `success` (toast simpan) · `loading`. **Tidak diasumsikan** adanya item ber-state `disabled` — item non-entitle **dihapus** (**ASM-31**).

**Pesan validasi yang mungkin tampak:** validasi nilai per setting (mis. `Nomor WhatsApp CS tidak valid`, `Durasi harus berupa angka`) — **di luar cakupan modul ini**; jangan jadikan assertion.

---

### UI-T07 — Sidebar / Navigasi Vendor

**Deskripsi:** 6 item dari sheet `VD`, **identik** antara TMS dan OMS. Nilai uji terbesarnya adalah **assertion invarian** (tidak berubah) + **assertion negatif** (tidak memuat menu Shipper).

**Kapan tampil:** setelah login sebagai **Vendor**, pada seluruh state produk **dan** seluruh kombinasi add-on (**ASM-13** — add-on tidak memengaruhi sidebar Vendor).

| Elemen | Tipe | Role+Name (ARIA) | data-testid (usulan) | Label/teks | Vendor `P-TMS` / `P-OMS` / `P-BOTH` | REQ terkait |
|---|---|---|---|---|---|---|
| Container sidebar Vendor | `navigation` | `getByRole('navigation')` | `sidebar-vendor` | — | ✓ / ✓ / ✓ | REQ-050 |
| `Order` | Link | `getByRole('link', { name: /^order$/i })` | `nav-item-order` | `Order` ✅ | ✓ / ✓ / ✓ | REQ-051 |
| `Penugasan Tracking` | Link | `getByRole('link', { name: /penugasan tracking/i })` | `nav-item-penugasan-tracking` | `Penugasan Tracking` ✅ | ✓ / ✓ / ✓ — perilaku tetap tunduk R2 (UI-T04 baris 9–10) | REQ-052 |
| `Master Operasional - Master Armada` | Link | `getByRole('link', { name: /master armada/i })` | `nav-item-master-armada` | `Master Armada` ✅ *(khusus Vendor)* | ✓ / ✓ / ✓ | REQ-053 |
| `Master Operasional - Master Sopir` | Link | `getByRole('link', { name: /master sopir/i })` | `nav-item-master-sopir` | `Master Sopir` ✅ *(khusus Vendor)* | ✓ / ✓ / ✓ | REQ-054 |
| `Akun Saya` | Link | `getByRole('link', { name: /akun saya/i })` | `nav-item-akun-saya` | `Akun Saya` ✅ | ✓ / ✓ / ✓ | REQ-055 |
| `Pusat Notifikasi` | Link | `getByRole('link', { name: /pusat notifikasi/i })` | `nav-item-pusat-notifikasi` | `Pusat Notifikasi` ✅ | ✓ / ✓ / ✓ | REQ-056 |
| Grup `MASTER OPERASIONAL` (Vendor) | Group header | `getByText(/master operasional/i)` | `nav-group-master-operasional` | `Master Operasional` ✅ | ✓ / ✓ / ✓ | REQ-053, REQ-054 |

**Assertion invarian & negatif**

| # | Assertion | Ekspektasi | REQ |
|---|---|---|---|
| 1 | Jumlah item sidebar Vendor | `toHaveCount(6)` pada `P-TMS` **dan** `P-OMS`, urutan sama | REQ-050, AC-050.1 |
| 2 | Perbandingan snapshot daftar label | array label pada TMS **identik** dengan OMS | REQ-050, AC-050.2 |
| 3 | Menu eksklusif Shipper **absen** | `nav-item-manajemen-vendor`, `nav-item-pengaturan-sistem`, `nav-item-master-barang`, `nav-item-simulasi-muatan`, `nav-item-master-wilayah`, `nav-item-master-pelabuhan`, `nav-item-master-pelayaran`, `nav-item-master-drop-point`, `dashboard-tabs` → seluruhnya `toHaveCount(0)` | REQ-057, AC-057.1 |
| 4 | Deep-link menu Shipper oleh Vendor | 403 / redirect (UI-T11) | REQ-057, AC-057.2 |
| 5 | Sidebar Vendor tidak berubah saat `addOns` diubah | daftar 6 item tetap pada `A-DARAT`, `A-LAUT`, `A-UDARA`, `A-NONE` | ASM-13 |
| 6 | Sidebar Vendor tidak berubah saat produk diubah mid-session | setelah refresh, tetap 6 item | REQ-050, ALT-26 |

**State terlihat:** `default` · `collapsed` · `active`. **Tidak ada** state hidden yang diharapkan pada sidebar Vendor — bila ada item Vendor yang hilang saat produk diubah, itu **defect REQ-050**.

**Pesan/notifikasi:** tidak ada.

---

### UI-T08 — Master Operasional yang bergantung moda

**Deskripsi:** halaman list untuk master yang visibilitasnya ditentukan add-on `SERVICE_*`. Struktur halaman diasumsikan seragam: judul h1 + tombol tambah + tabel + paginasi (**ASM-36**, pola `oms015` UI-096). Fokus uji bukan CRUD-nya, melainkan **ada/tidaknya halaman** dan **guard akses langsung**.

**Kapan tampil:** hanya bila lolos **filter produk** (R3/R7) **DAN** **filter add-on** (R6) — REQ-074.

**Struktur halaman list (berlaku untuk seluruh master di bawah)**

| Elemen | Tipe | Role+Name (ARIA) | data-testid (usulan) | Label/teks | State/Visibilitas per entitlement | REQ terkait |
|---|---|---|---|---|---|---|
| Root halaman | Container | — | `<slug>-page` (mis. `master-pelabuhan-page`) | — | mengikuti matriks di bawah | REQ-070…REQ-076 |
| Judul halaman | Heading h1 | `getByRole('heading', { level: 1, name: /<nama master>/i })` | `<slug>-title` | nama master ✅ | idem | idem |
| Tombol tambah | `button` | `getByRole('button', { name: /(tambah\|buat\|\+)/i })` | `<slug>-create` | `Tambah` (usulan) | idem | idem |
| Tabel data | `table` | `getByRole('table')` | `<slug>-table` | — | idem | idem |
| Baris data | `row` | `getByRole('row')` | `<slug>-row` | — | **jumlah baris tidak berkurang** setelah add-on dicabut & dipulihkan | REQ-098, REQ-099 |
| Empty state | Container | — | `<slug>-empty` | `Belum ada data` (usulan) | tenant baru | — |
| Info paginasi | Teks | `getByText(/Menampilkan \d+ - \d+ data dari \d+ data/)` | `<slug>-pagination-info` | pola `oms015` ✅ | dipakai untuk verifikasi keutuhan data pasca-reaktivasi | REQ-099, AC-099.2 |

**Matriks visibilitas per master**

| Master | Route usulan | `nav-item` testid | Shipper standar (sheet `SH` + `JP`) | TMS LKL (sheet `LKL`) | REQ terkait |
|---|---|---|---|---|---|
| `Master Pelabuhan` | `/master-pelabuhan` | `nav-item-master-pelabuhan` | produk: ✓ semua · add-on: **`A-LAUT` wajib**; `A-DARAT` saja / `A-NONE` → ✗ | hanya moda **Laut** | REQ-041, REQ-070, REQ-075, REQ-087 |
| `Master Pelayaran` | `/master-pelayaran` | `nav-item-master-pelayaran` | produk: ✓ semua · add-on: **`A-LAUT` wajib** | hanya moda **Laut** | REQ-042, REQ-071, REQ-075, REQ-088 |
| `Master Bandara` | `/master-bandara` | `nav-item-master-bandara` | **tidak ada** pada sheet `SH` — eksklusif LKL (ASM-17) | hanya moda **Udara** (`SERVICE_AIR_FREIGHT`) | REQ-089 |
| `Master Maskapai` | `/master-maskapai` | `nav-item-master-maskapai` | **tidak ada** pada sheet `SH` — eksklusif LKL | hanya moda **Udara** | REQ-090 |
| `Master Barang` | `/master-barang` | `nav-item-master-barang` | produk: **OMS wajib** (`P-TMS` → ✗) · add-on: tidak bergantung | tidak ada di `LKL` | REQ-039 |
| `Simulasi Muatan` | `/simulasi-muatan` | `nav-item-simulasi-muatan` | produk: **OMS wajib** · add-on: **`A-STUFF` wajib** | tidak ada di `LKL` | REQ-036, REQ-076, ALT-23, ALT-24 |

**Perilaku akses langsung via URL saat menu disembunyikan (guard)**

| # | Aksi | Ekspektasi | Assertion usulan | REQ |
|---|---|---|---|---|
| 1 | `page.goto('/master-pelabuhan')` saat hanya `A-DARAT` | 403 / redirect ke beranda — **bukan** konten master | `expect(getByTestId('master-pelabuhan-table')).toHaveCount(0)` **dan** (`getByTestId('error-403-page')` tampil **atau** `expect(page).toHaveURL(/\/(dashboard\|beranda)/)`) | REQ-096, AC-096.1 |
| 2 | Deep-link sub-halaman (`/master-pelabuhan/create`, `/master-pelabuhan/<id>`) | idem | idem | REQ-096, AC-096.2 |
| 3 | Panggilan API master non-entitle dengan token user | `403` | `expect(res.status()).toBe(403)` | REQ-097, AC-097.1 |
| 4 | Kebocoran data pada respons lain | tidak ada data master non-entitle | assert payload halaman lain tidak memuat data tersebut | REQ-097, AC-097.2 |
| 5 | `/simulasi-muatan` pada OMS tanpa `AUTO_STUFFING` | ditolak | idem #1 | REQ-076, AC-076.2 |
| 6 | Reaktivasi add-on lalu buka ulang halaman | halaman tampil, jumlah baris & isi **identik** dengan sebelum pencabutan | bandingkan `<slug>-pagination-info` sebelum vs sesudah | REQ-098, REQ-099 |

**State terlihat:** `default` (tabel terisi) · `empty` · `loading` · **`hidden`** (menu tidak dirender) · **`forbidden`** (403 saat deep-link) · `redirected`.

**Pesan/notifikasi yang mungkin tampak:** lihat **UI-T11** — `Fitur tidak tersedia` / `Anda tidak memiliki akses ke halaman ini` (usulan).

---

### UI-T09 — Navigasi TMS LKL (Darat / Laut / Udara)

**Deskripsi:** varian navigasi TMS yang susunan menunya ditentukan **moda aktif** (**ASM-17**). 23 baris sheet `LKL` dalam 5 grup. Uji pada client dengan `products` memuat `TMS` + kombinasi `addOns`.

**Kapan tampil:** client TMS varian LKL. Kombinasi moda → **union** (REQ-094, **ASM-18**).

**Grup navigasi**

| Elemen | Tipe | Role+Name (ARIA) | data-testid (usulan) | Label/teks | Visibilitas | REQ terkait |
|---|---|---|---|---|---|---|
| Grup `DASHBOARD` | Group header | `getByText(/dashboard/i)` | `nav-group-dashboard` | `DASHBOARD` ✅ | selalu | REQ-078 |
| Grup `MENU UTAMA` | Group header | `getByText(/menu utama/i)` | `nav-group-menu-utama` | `MENU UTAMA` ✅ | selalu | REQ-078 |
| Grup `MASTER OPERASIONAL` | Group header | `getByText(/master operasional/i)` | `nav-group-master-operasional` | `MASTER OPERASIONAL` ✅ | selalu | REQ-078 |
| Grup `MENU KEUANGAN` | Group header | `getByText(/menu keuangan/i)` | `nav-group-menu-keuangan` | `MENU KEUANGAN` ✅ | selalu | REQ-078, REQ-092 |
| Grup `MENU LAINNYA` | Group header | `getByText(/menu lainnya/i)` | `nav-group-menu-lainnya` | `MENU LAINNYA` ✅ | selalu | REQ-078, REQ-093 |

**Item menu LKL — visibilitas per moda**

| Elemen | Tipe | Role+Name (ARIA) | data-testid (usulan) | Label/teks | `A-DARAT` / `A-LAUT` / `A-UDARA` | REQ terkait |
|---|---|---|---|---|---|---|
| `Dashboard - Monitoring` | Link/tab | `getByRole('link', { name: /monitoring/i })` | `nav-item-dashboard-monitoring` | `Dashboard - Monitoring` ✅ | ✓ / **✗** / **✗** | REQ-079 |
| `Dashboard - Tracking & Location` | Link/tab | `getByRole('link', { name: /tracking\s*&?\s*location/i })` | `nav-item-dashboard-tracking-location` | `Dashboard - Tracking & Location` ✅ | ✓ / ✓ / ✓ | REQ-080 |
| `Dashboard - Operasional` | Link/tab | `getByRole('link', { name: /operasional/i })` | `nav-item-dashboard-operasional` | `Dashboard - Operasional` ✅ | ✓ / ✓ / ✓ | REQ-080 |
| **`Shipment`** | Link | `getByRole('link', { name: /shipment/i })` | `nav-item-shipment` | `Shipment` ✅ *(eksklusif LKL)* | ✓ / ✓ / ✓ | REQ-081 |
| `Order` | Link | `getByRole('link', { name: /^order$/i })` | `nav-item-order` | `Order` ✅ | ✓ / ✓ / ✓ | REQ-081 |
| `Penugasan Tracking` | Link | `getByRole('link', { name: /penugasan tracking/i })` | `nav-item-penugasan-tracking` | `Penugasan Tracking` ✅ | ✓ / ✓ / ✓ | REQ-081 |
| **`Otomasi Jalur`** | Link | `getByRole('link', { name: /otomasi jalur/i })` | `nav-item-otomasi-jalur` | `Otomasi Jalur` ✅ *(eksklusif LKL)* | ✓ / **✗** / **✗** | REQ-082 |
| `Master Wilayah` | Link | `getByRole('link', { name: /master wilayah/i })` | `nav-item-master-wilayah` | `Master Wilayah` ✅ | ✓ / ✓ / ✓ | REQ-083 |
| **`Master Rute`** | Link | `getByRole('link', { name: /master rute/i })` | `nav-item-master-rute` | `Master Rute` ✅ *(eksklusif LKL)* | ✓ / ✓ / ✓ | REQ-084 |
| **`Master Customer`** | Link | `getByRole('link', { name: /master customer/i })` | `nav-item-master-customer` | `Master Customer` ✅ *(eksklusif LKL)* | ✓ / ✓ / ✓ | REQ-086 |
| `Master Drop Point` | Link | `getByRole('link', { name: /master drop point/i })` | `nav-item-master-drop-point` | `Master Drop Point` ✅ | ✓ / ✓ / ✓ | REQ-086 |
| `Master Pelabuhan` | Link | `getByRole('link', { name: /master pelabuhan/i })` | `nav-item-master-pelabuhan` | `Master Pelabuhan` ✅ | **✗** / ✓ / **✗** | REQ-087 |
| `Master Pelayaran` | Link | `getByRole('link', { name: /master pelayaran/i })` | `nav-item-master-pelayaran` | `Master Pelayaran` ✅ | **✗** / ✓ / **✗** | REQ-088 |
| **`Master Bandara`** | Link | `getByRole('link', { name: /master bandara/i })` | `nav-item-master-bandara` | `Master Bandara` ✅ | **✗** / **✗** / ✓ | REQ-089 |
| **`Master Maskapai`** | Link | `getByRole('link', { name: /master maskapai/i })` | `nav-item-master-maskapai` | `Master Maskapai` ✅ | **✗** / **✗** / ✓ | REQ-090 |
| `Master Unit & Sopir` | Link | `getByRole('link', { name: /master unit.*sopir/i })` | `nav-item-master-unit-sopir` | `Master Unit & Sopir` ✅ | ✓ / ✓ / ✓ | REQ-091 |
| **`Master Kemasan`** | Link | `getByRole('link', { name: /master kemasan/i })` | `nav-item-master-kemasan` | `Master Kemasan` ✅ *(eksklusif LKL)* | ✓ / ✓ / ✓ | REQ-091 |
| **`Master Bank`** | Link | `getByRole('link', { name: /master bank/i })` | `nav-item-master-bank` | `Master Bank` ✅ *(eksklusif LKL)* | ✓ / ✓ / ✓ | REQ-091 |
| **`Manajemen Invoice`** | Link | `getByRole('link', { name: /manajemen invoice/i })` | `nav-item-manajemen-invoice` | `Manajemen Invoice` ✅ *(eksklusif LKL)* | ✓ / ✓ / ✓ | REQ-092 |
| **`Laporan Keuangan`** | Link | `getByRole('link', { name: /laporan keuangan/i })` | `nav-item-laporan-keuangan` | `Laporan Keuangan` ✅ *(eksklusif LKL)* | ✓ / ✓ / ✓ | REQ-092 |
| `Pengaturan Akun` | Link | `getByRole('link', { name: /pengaturan akun/i })` | `nav-item-pengaturan-akun` | `Pengaturan Akun` ✅ | ✓ / ✓ / ✓ | REQ-093 |
| `Akun Saya` | Link | `getByRole('link', { name: /akun saya/i })` | `nav-item-akun-saya` | `Akun Saya` ✅ | ✓ / ✓ / ✓ | REQ-093 |
| `Pusat Notifikasi` | Link | `getByRole('link', { name: /pusat notifikasi/i })` | `nav-item-pusat-notifikasi` | `Pusat Notifikasi` ✅ | ✓ / ✓ / ✓ | REQ-093 |

**Sub-permukaan: tab pada `Master Rute`** *(bergantung tipe pengiriman "Less" — REQ-085)*

| Elemen | Tipe | Role+Name (ARIA) | data-testid (usulan) | Label/teks | Visibilitas | REQ terkait |
|---|---|---|---|---|---|---|
| Tablist `Master Rute` | `tablist` | `getByRole('tablist')` | `master-rute-tabs` | — | selalu (saat `Master Rute` tampil) | REQ-084 |
| Tab `Tarif Pengiriman` | `tab` | `getByRole('tab', { name: /tarif pengiriman/i })` | `master-rute-tab-tarif-pengiriman` | `Tarif Pengiriman` ✅ | **hanya bila `A-LESS`** (`SERVICE_LTL` dan/atau `SERVICE_LCL`); `SERVICE_FTL`/`SERVICE_FCL` saja → **✗** | REQ-085, AC-085.1–085.3 |
| Tab `Konversi Muatan` | `tab` | `getByRole('tab', { name: /konversi muatan/i })` | `master-rute-tab-konversi-muatan` | `Konversi Muatan` ✅ | idem | REQ-085 |
| Tab lain pada `Master Rute` | `tab` | `getByRole('tab')` | `master-rute-tab-<slug>` | tidak diketahui | **tetap tampil pada semua kondisi** — jangan di-assert hilang | REQ-085, AC-085.4 |

**Assertion kombinasi moda (union — REQ-094)**

| Kombinasi `addOns` | WAJIB ADA | WAJIB ABSEN | REQ / AC |
|---|---|---|---|
| `["SERVICE_FTL"]` (Darat) | Monitoring, Otomasi Jalur | Master Pelabuhan, Master Pelayaran, Master Bandara, Master Maskapai, tab Tarif/Konversi | REQ-079, REQ-082, REQ-085, REQ-087…REQ-090 |
| `["SERVICE_FCL"]` (Laut) | Master Pelabuhan, Master Pelayaran | Monitoring, Otomasi Jalur, Master Bandara, Master Maskapai, tab Tarif/Konversi | REQ-079, REQ-082, REQ-087…REQ-090 |
| `["SERVICE_AIR_FREIGHT"]` (Udara) | Master Bandara, Master Maskapai | Monitoring, Otomasi Jalur, Master Pelabuhan, Master Pelayaran | REQ-089, REQ-090, ALT-21 |
| `["SERVICE_FTL","SERVICE_FCL"]` | Monitoring, Otomasi Jalur, Master Pelabuhan, Master Pelayaran | Master Bandara, Master Maskapai | REQ-094, AC-094.1 |
| `["SERVICE_FTL","SERVICE_AIR_FREIGHT"]` | Monitoring, Otomasi Jalur, Master Bandara, Master Maskapai | Master Pelabuhan, Master Pelayaran | REQ-094, AC-094.2 |
| `["SERVICE_LTL","SERVICE_LCL","SERVICE_AIR_FREIGHT"]` | seluruh 23 baris + tab `Tarif Pengiriman` & `Konversi Muatan` | — | REQ-094 (AC-094.3), REQ-085 |

**State terlihat:** `default` · `hidden` (item non-moda) · `active`. Tab `Master Rute` menambah state `tab-hidden`.

**Pesan/notifikasi:** tidak ada pada navigasi; guard deep-link → UI-T11.

---

### UI-T10 — Form Order (Shipper) — pemilihan `Jenis Pengiriman`

**Deskripsi:** permukaan tempat REQ-077 (**ASM-16**) diverifikasi — opsi jenis pengiriman dibatasi add-on `SERVICE_*`. Struktur mengikuti `oms015` UI-097/UI-102: **radio card**, bukan `<select>` (**ASM-35**).

**Kapan tampil:** `nav-item-order` → tombol `Buat Order` → Step 1 `Data Pengiriman`, pada seluruh state produk (menu `Order` ✓ di semua state — REQ-035).

| Elemen | Tipe | Role+Name (ARIA) | data-testid (usulan) | Label/teks | State/Visibilitas per entitlement | REQ terkait |
|---|---|---|---|---|---|---|
| Tombol buat order | `button` | `getByRole('button', { name: /buat order/i })` | `order-list-create` ✅ (`oms015`) | `+ Buat Order` ✅ | ✓ semua state produk | REQ-035 |
| Section jenis & rute | Heading | `getByRole('heading', { name: /jenis pengiriman dan rute/i })` | `section-jenis-rute` ✅ (`oms015`) | `Jenis Pengiriman dan Rute` ✅ | ✓ | REQ-077 |
| Grup opsi jenis pengiriman | `radiogroup` (fallback `combobox`, ASM-35) | `getByRole('radiogroup', { name: /jenis pengiriman/i })` | `order-type-group` | `Jenis Pengiriman` ✅ | ✓ — **jumlah opsi = jumlah add-on `SERVICE_*` aktif** | REQ-077, REQ-069 |
| Opsi **`FTL`** | `radio` | `getByRole('radio', { name: /FTL/i })` | `order-type-ftl` ✅ (`oms015`) | `FTL` / `Full Truck Load` ✅ | tampil **hanya bila** `SERVICE_FTL` aktif | REQ-077, AC-077.1 |
| Opsi **`LTL`** | `radio` | `getByRole('radio', { name: /LTL/i })` | `order-type-ltl` ✅ (`oms015`) | `LTL` / `Less Than Truck Load` ✅ | tampil **hanya bila** `SERVICE_LTL` aktif | REQ-077, AC-077.2 |
| Opsi **`FCL`** | `radio` | `getByRole('radio', { name: /FCL/i })` | `order-type-fcl` ✅ (`oms015`) | `FCL` / `Full Container Load` ✅ | tampil **hanya bila** `SERVICE_FCL` aktif | REQ-077 |
| Opsi **`LCL`** | `radio` | `getByRole('radio', { name: /LCL/i })` | `order-type-lcl` ✅ (`oms015`) | `LCL` / `Less Than Container Load` ✅ | tampil **hanya bila** `SERVICE_LCL` aktif | REQ-077 |
| Opsi **`Air Freight`** | `radio` | `getByRole('radio', { name: /air freight/i })` | `order-type-air-freight` | `Air Freight` (usulan) | tampil **hanya bila** `SERVICE_AIR_FREIGHT` aktif | REQ-077, REQ-069 |
| Field rute (turunan jenis) | Dropdown | `getByLabel(/^Kota Asal\|^Pelabuhan Asal/)` | `field-kota-asal` / `field-pelabuhan-asal` ✅ (`oms015`) | `Kota Asal` \| `Pelabuhan Asal` ✅ | mengikuti jenis terpilih — **di luar cakupan modul**, jangan di-assert detail | ASM-16 |
| Badge jenis order pada daftar | Badge | `row.getByTestId('order-row-type-badge')` | `order-row-type-badge` ✅ (`oms015`) | `FTL`/`LTL`/`FCL`/`LCL` ✅ | order lama tetap tampil meski add-on-nya dicabut | REQ-077 (AC-077.3), REQ-098 |
| Pesan/empty saat tanpa add-on | Teks/alert | `getByRole('alert')` | `order-type-empty` | usulan: `Belum ada jenis pengiriman aktif` | `A-NONE` → tidak ada opsi yang dapat dipilih (**ASM-31**) | REQ-075, REQ-077 |

**Assertion kunci**

| Skenario | Ekspektasi | REQ / AC |
|---|---|---|
| `addOns:["SERVICE_FTL"]` | hanya `order-type-ftl` ada; `order-type-ltl/fcl/lcl/air-freight` → `toHaveCount(0)` | REQ-077, AC-077.1 |
| Tambah `SERVICE_LTL` lalu refresh | `order-type-ltl` **muncul** | REQ-077, AC-077.2 |
| Cabut `SERVICE_LCL` setelah ada order LCL | order lama tetap terlihat pada `Daftar Order` dengan badge `LCL` | REQ-077 (AC-077.3), REQ-098 |
| `addOns:[]` | tidak ada opsi jenis pengiriman yang dapat dipilih | REQ-075, REQ-016 |

**State terlihat:** `default` (opsi terisi) · `selected` (satu opsi ter-*check*) · `hidden` (opsi non-entitle tidak dirender) · `empty` (tanpa add-on). **Tidak diasumsikan** state `disabled` pada opsi non-entitle (**ASM-31**).

**Pesan validasi yang mungkin tampak:** validasi wizard order (`Kota Asal harus diisi`, dst.) — **milik modul `oms015`**, bukan modul ini. Jangan dijadikan assertion di sini.

---

### UI-T11 — Notifikasi/Toast & halaman error entitlement

**Deskripsi:** permukaan generik untuk memverifikasi **guard** (REQ-096, REQ-097) dan **fallback** (REQ-101). Dipakai sebagai pasangan wajib setiap assertion "menu hilang".

**Kapan tampil:** saat user membuka route/anchor fitur yang tidak ter-*entitle*, atau saat API fitur non-entitle dipanggil.

| Elemen | Tipe | Role+Name (ARIA) | data-testid (usulan) | Label/teks | State/Visibilitas per entitlement | REQ terkait |
|---|---|---|---|---|---|---|
| Halaman 403 | Container | — | `error-403-page` | — | muncul saat deep-link non-entitle (**ASM-31** — alternatifnya redirect) | REQ-096 |
| Judul 403 | Heading | `getByRole('heading', { name: /(tidak tersedia\|tidak memiliki akses\|403)/i })` | `error-403-title` | usulan: `Fitur tidak tersedia` | idem | REQ-096, AC-096.1 |
| Deskripsi 403 | Teks | `getByText(/(tidak tersedia untuk akun\|hubungi admin)/i)` | `error-403-desc` | usulan: `Fitur ini tidak tersedia untuk akun Anda` | idem | REQ-096 |
| Tombol kembali | `button`/link | `getByRole('link', { name: /(kembali\|beranda\|dashboard)/i })` | `error-403-back` | `Kembali ke Beranda` (usulan) | idem | REQ-096 |
| Halaman 404 | Container | — | `error-404-page` | `Halaman tidak ditemukan` (usulan) | **alternatif** implementasi guard — diterima sebagai lulus bila konten fitur tidak bocor | REQ-096, ASM-31 |
| Redirect ke beranda | Navigasi | `expect(page).toHaveURL(/\/(dashboard\|beranda\|home)/)` | — | — | **alternatif** implementasi guard | REQ-096, AC-096.1 |
| Toast sukses | `status` | `getByRole('status')` | `toast-success` | `Berhasil disimpan` (usulan) | pada aksi simpan yang sah | — |
| Toast error | `alert` | `getByRole('alert')` | `toast-error` | usulan: `Fitur tidak tersedia` / `Terjadi kesalahan` | saat aksi ke fitur non-entitle | REQ-097 |
| Banner sesi kedaluwarsa | `alert` | `getByRole('alert')` | `session-expired-banner` | usulan: `Sesi Anda telah berubah, muat ulang halaman` | **opsional** — bila FE mendorong refresh setelah entitlement berubah | REQ-095, ALT-12 |
| Sidebar minimal (fallback) | `navigation` | `getByRole('navigation')` | `sidebar-shipper` | hanya `Pengaturan Akun`, `Akun Saya`, `Pusat Notifikasi` | client tanpa produk aktif | REQ-101, AC-101.2 |
| Status API non-entitle | HTTP status | `expect(res.status()).toBe(403)` | — | — | selalu, lintas kanal | REQ-097, REQ-102 |

**Assertion guard yang toleran (disarankan)**

Karena bentuk guard belum disepakati (**ASM-31**), gunakan assertion **OR** berikut, bukan assertion tunggal:

```
// 1) Konten fitur TIDAK boleh muncul  — WAJIB, blocking
await expect(page.getByTestId('master-pelabuhan-table')).toHaveCount(0);
// 2) Salah satu bentuk guard harus terpenuhi — WAJIB, blocking
const forbidden = page.getByTestId('error-403-page');
const redirected = /\/(dashboard|beranda|home)/.test(page.url());
expect((await forbidden.count()) > 0 || redirected).toBeTruthy();
```

**State terlihat:** `forbidden` (403) · `notfound` (404, alternatif) · `redirected` · `toast-success` · `toast-error` · `fallback-minimal` (sidebar 3 item).

**Pesan/notifikasi yang mungkin tampak:**

| Kondisi | Pesan usulan | Matcher | REQ |
|---|---|---|---|
| Deep-link fitur non-entitle | `Fitur tidak tersedia` | `/(tidak tersedia\|tidak memiliki akses\|forbidden\|403)/i` | REQ-096 |
| Aksi/API fitur non-entitle | `Anda tidak memiliki akses` | idem | REQ-097 |
| Client tanpa produk aktif | *(tidak ada pesan)* — hanya sidebar minimal | assert **ketiadaan** pesan error blocking | REQ-101 |
| Entitlement berubah saat sesi aktif | `Muat ulang halaman` (opsional) | `/(muat ulang\|refresh)/i` — **non-blocking** | REQ-095, ALT-12 |

---

### Ringkasan Selector Kunci

`data-testid` yang paling sering dipakai lintas skenario — **daftar ini adalah permintaan kontrak test kepada tim FE** (**ASM-22**). Prioritas `tinggi` = tanpa testid ini, assertion hanya bisa mengandalkan teks (rapuh).

| `data-testid` | Elemen | Permukaan | Prioritas |
|---|---|---|---|
| **`sidebar-shipper`** | Container navigasi Shipper (scoping wajib) | UI-T02, UI-T09, UI-T11 | **tinggi** |
| **`sidebar-vendor`** | Container navigasi Vendor | UI-T07 | **tinggi** |
| **`nav-item-<slug>`** | Setiap item menu (26 slug — Shipper, Vendor, LKL) | UI-T02, UI-T07, UI-T09 | **tinggi** |
| `nav-group-<slug>` | 5 grup menu (`dashboard`, `menu-utama`, `master-operasional`, `menu-keuangan`, `menu-lainnya`) | UI-T02, UI-T09 | sedang |
| **`nav-item-master-pelabuhan`** | Menu paling rawan (dua filter bertumpuk) | UI-T02, UI-T08, UI-T09 | **tinggi** |
| **`nav-item-master-pelayaran`** | idem | UI-T02, UI-T08, UI-T09 | **tinggi** |
| **`nav-item-simulasi-muatan`** | Menu ber-add-on `AUTO_STUFFING` | UI-T02, UI-T08 | **tinggi** |
| **`dashboard-tabs`** | Container tab dashboard (scoping) | UI-T03 | **tinggi** |
| **`dashboard-tab-progress-pengiriman`** | Tab dengan dua filter bertumpuk | UI-T03 | **tinggi** |
| `dashboard-tab-tracking-location` | Tab TMS-only | UI-T03 | tinggi |
| `dashboard-tab-distribusi-muatan` | Tab OMS-only | UI-T03 | tinggi |
| **`assignment-page`** | Root Penugasan Tracking | UI-T04 | **tinggi** |
| **`assignment-assignee-type-sopir`** | Opsi pelaksana `Sopir` — inti R2 | UI-T04 | **tinggi** |
| **`assignment-assignee-type-pengurus`** | Opsi pelaksana `Pengurus` | UI-T04 | **tinggi** |
| **`assignment-driver-select`** | Dropdown pilih sopir | UI-T04 | **tinggi** |
| `assignment-handler-select` | Dropdown pilih pengurus | UI-T04 | tinggi |
| **`assignment-submit`** | Simpan penugasan | UI-T04 | **tinggi** |
| **`assignment-row-channel`** | Badge kanal (`Aplikasi Sopir` vs `Input Web`) | UI-T04 | **tinggi** *(bila ada — ASM-33)* |
| `assignment-channel-hint` | Hint kanal pada form | UI-T04 | sedang |
| **`tracking-input-form`** | Form input tracking pengurus (web) | UI-T04 | **tinggi** |
| **`system-settings-list`** | Container item Pengaturan Sistem (untuk `toHaveCount`) | UI-T06 | **tinggi** |
| **`setting-item-<slug>`** | 8 item Pengaturan Sistem | UI-T06 | **tinggi** |
| **`order-type-<jenis>`** | 5 opsi Jenis Pengiriman | UI-T10 | **tinggi** |
| `order-type-group` | Container opsi jenis pengiriman | UI-T10 | sedang |
| **`<slug>-page`** | Root halaman master (`master-pelabuhan-page`, dll.) | UI-T08 | **tinggi** |
| `<slug>-table` | Tabel master (assertion ketiadaan konten) | UI-T08 | tinggi |
| `<slug>-pagination-info` | Verifikasi keutuhan data pasca-reaktivasi | UI-T08 | sedang |
| **`master-rute-tab-tarif-pengiriman`** | Tab bergantung `A-LESS` | UI-T09 | **tinggi** |
| **`master-rute-tab-konversi-muatan`** | idem | UI-T09 | **tinggi** |
| **`error-403-page`** | Guard deep-link | UI-T08, UI-T09, UI-T11 | **tinggi** |
| `error-403-title` | Judul `Fitur tidak tersedia` | UI-T11 | sedang |
| `toast-success` / `toast-error` | Notifikasi aksi | UI-T04, UI-T06, UI-T11 | sedang |
| `header-logout` | Propagasi via logout-login | UI-T01 | tinggi |
| `login-email` / `login-password` / `login-submit` | Login | UI-T01 | tinggi |
| `header-tenant-context` | Membedakan kanal Shipper vs Vendor | UI-T01, UI-T07 | sedang |

**Atribut data tambahan yang diminta** (bukan testid, tapi krusial untuk assertion):

| Atribut | Elemen | Nilai | Dipakai untuk |
|---|---|---|---|
| `data-entitlement-product` | `nav-item-*`, `dashboard-tab-*`, `setting-item-*` | `TMS` \| `OMS` \| `BOTH` | Assertion matriks R3/R5 tanpa bergantung label (**ASM-23**) |
| `data-entitlement-addon` | `nav-item-master-pelabuhan`, `nav-item-simulasi-muatan`, `dashboard-tab-progress-pengiriman`, `order-type-*` | `SERVICE_FCL` \| `AUTO_STUFFING` \| … | Assertion matriks R6 (**ASM-23**) |
| `data-assignment-channel` | `assignment-row-*` | `driver-app` \| `web` | Assertion R2 tanpa bergantung teks badge (**ASM-33**) |

---

### Peta Layar ↔ REQ

**Daftar slug layar resmi** — dipakai scenario-generator sebagai tag `@screen-<slug>` (satu skenario boleh membawa >1 tag bila lintas permukaan):

| # | Slug tag | Permukaan (ID) | Kanal |
|---|---|---|---|
| 1 | `@screen-api-entitlement` | UI-T00 | API (Admin) |
| 2 | `@screen-login` | UI-T01 | Web Shipper & Vendor |
| 3 | `@screen-sidebar-shipper` | UI-T02 | Web Shipper |
| 4 | `@screen-dashboard` | UI-T03 | Web Shipper |
| 5 | `@screen-penugasan-tracking` | UI-T04 | Web Shipper & Vendor |
| 6 | `@screen-driver-app` | UI-T05 | Mobile Sopir / API |
| 7 | `@screen-pengaturan-sistem` | UI-T06 | Web Shipper |
| 8 | `@screen-sidebar-vendor` | UI-T07 | Web Vendor |
| 9 | `@screen-master-moda` | UI-T08 | Web Shipper |
| 10 | `@screen-nav-lkl` | UI-T09 | Web Shipper (varian LKL) |
| 11 | `@screen-form-order` | UI-T10 | Web Shipper |
| 12 | `@screen-error` | UI-T11 | Semua kanal |

**Pemetaan permukaan → REQ yang diverifikasi di sana**

| Permukaan | Slug tag | REQ yang diverifikasi | Catatan cakupan |
|---|---|---|---|
| **UI-T00** | `@screen-api-entitlement` | REQ-001…REQ-019, REQ-103 · V-01…V-23 | Seluruh R1 diuji murni di level API (**ASM-19**, **ASM-26**). Juga menjadi **setup wajib** seluruh permukaan lain. |
| **UI-T01** | `@screen-login` | REQ-095, REQ-100, REQ-101, REQ-102 | Titik masuk + mekanisme propagasi (refresh / logout-login). |
| **UI-T02** | `@screen-sidebar-shipper` | REQ-029…REQ-049 · REQ-070, REQ-071, REQ-074, REQ-075, REQ-076 · REQ-095, REQ-101 | Permukaan dengan REQ terbanyak (26 REQ). |
| **UI-T03** | `@screen-dashboard` | REQ-030…REQ-034 · REQ-072, REQ-074, REQ-075 | Interseksi filter produk × add-on paling representatif. |
| **UI-T04** | `@screen-penugasan-tracking` | REQ-020…REQ-028 · REQ-037, REQ-052 · REQ-100 | **Inti modul.** Wajib berpasangan dengan `@screen-driver-app`. |
| **UI-T05** | `@screen-driver-app` | REQ-022, REQ-024, REQ-026, REQ-027, REQ-028, REQ-052, REQ-102 | Di luar DOM web (**ASM-29**) — verifikasi via API/efek tidak langsung. |
| **UI-T06** | `@screen-pengaturan-sistem` | REQ-048, REQ-058…REQ-068 · REQ-099 | Satu-satunya permukaan dengan assertion kardinalitas absolut (8 / 2). |
| **UI-T07** | `@screen-sidebar-vendor` | REQ-050…REQ-057 · REQ-102 | Assertion invarian + negatif. |
| **UI-T08** | `@screen-master-moda` | REQ-036, REQ-039, REQ-041, REQ-042 · REQ-070, REQ-071, REQ-073…REQ-076 · REQ-087…REQ-090 · REQ-096, REQ-097, REQ-098, REQ-099 | Tempat guard deep-link diuji paling intensif. |
| **UI-T09** | `@screen-nav-lkl` | REQ-078…REQ-094 · REQ-085 | Varian LKL (**ASM-17**); 17 REQ. |
| **UI-T10** | `@screen-form-order` | REQ-035, REQ-069, REQ-077 · REQ-098 | Bergantung **ASM-16** — prioritas `medium`. |
| **UI-T11** | `@screen-error` | REQ-095, REQ-096, REQ-097, REQ-101, REQ-102 | Pasangan wajib setiap assertion "menu hilang". |

**REQ yang TIDAK memiliki permukaan UI khusus** (diverifikasi lintas permukaan atau di luar UI):

| REQ | Cara verifikasi | Permukaan pendukung |
|---|---|---|
| REQ-098, REQ-099 | Bandingkan jumlah/isi data sebelum vs sesudah pencabutan & reaktivasi | UI-T06, UI-T08, UI-T10 |
| REQ-102 | Jalankan assertion entitlement yang sama pada 3 kanal | UI-T02 + UI-T07 + UI-T05 |
| REQ-103 | Verifikasi entri audit (jalur admin/DB) | UI-T00 |

---

## Assumptions Log

| ID | Asumsi | Alasan | Dampak |
|---|---|---|---|
| **ASM-01** | **Tidak ada aset desain.** Direktori `inputs/oms000-jenis-produk/designs/` tidak tersedia; hanya ada `spec.txt` dan `extras/`. Seluruh nama menu, label, dan struktur grup diambil **verbatim** dari matriks xlsx. | Tidak ada sumber visual lain untuk grounding label. | Nama menu pada scenario harus diverifikasi ulang terhadap UI aktual saat eksekusi. Tahap design-analyzer tidak memiliki input untuk modul ini. |
| **ASM-02** | **File xlsx dibaca melalui hasil ekstraksi teks** `output/oms000-jenis-produk/_extracted/oms000-jenis-produk.xlsx.md`, bukan file biner aslinya. Merge range, warna sel, dan legenda warna (`Fitur hanya di TMS`/`OMS`) tidak dapat dibaca nilainya. | Keterbatasan tooling pembacaan biner. | Legenda warna diasumsikan hanya penanda visual yang **redundan** dengan kolom `✓/✗`; tidak menambah rule baru. |
| **ASM-03** | **Redaksi kredensial.** Nilai `X-Admin-Key` dan `clientId` asli dari `spec.txt` **tidak** disalin ke dokumen output; ditulis sebagai `<X-Admin-Key>` dan `<clientId>`. | Spec memuat admin key produksi/staging yang bersifat rahasia; dokumen analisis akan mengalir ke tahap berikutnya dan berpotensi tersebar. | Test data untuk eksekusi harus di-*inject* dari secret store/environment variable, bukan hard-code dari dokumen ini. |
| **ASM-04** | **Kontrak API dilengkapi secara inferensi**: kode respons (`200/400/401/404/405/415`), semantik replace-array + partial-field, atomicity, idempotensi, dan audit trail. Spec hanya memberi contoh `curl` sukses. | Spec tidak mendokumentasikan respons maupun error handling. | Diambil konvensi REST yang paling umum. Bila implementasi berbeda (mis. `403` alih-alih `401`), REQ-009…REQ-013 perlu penyesuaian nilai status, bukan perubahan logika. |
| **ASM-05** | **Arti kolom "Penggabungan OMS + TMS"**: nilai `Ikut TMS`/`Ikut OMS` berarti saat kedua produk aktif menu **tampil** dan menggunakan **varian/perilaku** produk yang disebut; `Setara` berarti tidak ada perbedaan varian antar produk. Konsekuensinya, **menu saat gabungan = union** dari menu TMS dan menu OMS. | Baris seperti `Dashboard - Distribusi & Muatan` (✗TMS/✓OMS, `Ikut OMS`) dan `Dashboard - Tracking & Location` (✓TMS/✗OMS, `Ikut TMS`) hanya konsisten bila kolom ini dibaca sebagai "varian mana yang dipakai", bukan "produk mana yang menang". | Menentukan seluruh ekspektasi state gabungan (REQ-030…REQ-049). Bila maksud sebenarnya adalah "menu hanya tampil bila produk yang disebut aktif", hasilnya identik untuk 20 baris tersebut — sehingga risiko interpretasi rendah. |
| **ASM-06** | **Validasi enum bersifat case-sensitive UPPERCASE**, dan **duplikat dideduplikasi** (bukan ditolak). | Seluruh nilai pada spec ditulis UPPERCASE; validasi ketat mengurangi ambiguitas. Deduplikasi lebih ramah klien daripada menolak. | Kasus uji `"tms"` diklasifikasikan sebagai **negatif** (`400`). Bila implementasi ternyata case-insensitive, REQ-014 berubah menjadi kasus positif. |
| **ASM-07** | **Pemetaan add-on → kolom matriks**: `SERVICE_FTL`+`SERVICE_LTL` → kolom `FTL / LTL saja` (moda **Darat**); `SERVICE_FCL`+`SERVICE_LCL` → kolom `FCL / LCL saja` (moda **Laut**); `SERVICE_AIR_FREIGHT` → kolom `Udara` pada sheet LKL. Tipe pengiriman **"Less"** = `SERVICE_LTL`/`SERVICE_LCL`. Visibilitas akhir = **AND** antara filter produk dan filter add-on. | Nama add-on identik dengan nama kolom sheet JP. Sheet JP tidak punya kolom udara, sedangkan LKL punya kolom `Udara` dengan `Master Bandara`/`Master Maskapai` — sesuai `SERVICE_AIR_FREIGHT`. Sifat AND diperlukan agar konflik `Master Pelabuhan` (✓ di SH tapi ✗ di JP) dapat direkonsiliasi. | Menentukan REQ-069…REQ-077, REQ-085, REQ-089, REQ-090. Ini asumsi **paling berdampak** setelah ASM-05 — perlu konfirmasi PO bila hasil eksekusi menyimpang. |
| **ASM-08** | **Kardinalitas array**: `products` minimal 1 (array kosong → `400`); `addOns` boleh kosong (array kosong → `200`). Tidak ada add-on `SERVICE_*` = tidak ada moda aktif → fitur berbasis moda seluruhnya hilang. | Client tanpa produk tidak dapat menggunakan aplikasi sama sekali sehingga tidak masuk akal sebagai state valid; sebaliknya client tanpa add-on adalah state bisnis yang wajar (paket dasar). | REQ-016, REQ-017, REQ-075. REQ-101 disiapkan sebagai *fallback* defensif bila ternyata `products: []` diterima sistem. |
| **ASM-09** | **Field asing di body diabaikan** (bukan ditolak `400`). | Sifat PATCH yang toleran adalah konvensi umum; spec hanya menyatakan "perubahan hanya pada products dan addOns". | REQ-018 diuji sebagai "tidak ada efek samping", bukan sebagai error. Bila implementasi ternyata *strict*, ekspektasi berubah menjadi `400`. |
| **ASM-10** | Keterangan **"OMS saja (Jika ada Add On)"** pada baris `Simulasi Muatan` merujuk pada add-on **`AUTO_STUFFING`**. | `AUTO_STUFFING` (stuffing/pemuatan otomatis) adalah satu-satunya add-on non-`SERVICE_*` dan secara semantik paling dekat dengan simulasi muatan. | REQ-036, REQ-076, V-20. Bila salah, dampaknya terbatas pada satu menu. |
| **ASM-11** | Pada state **gabungan TMS+OMS**, perilaku penugasan mengikuti **TMS** (sopir masuk apps) untuk **semua** order, termasuk order yang berasal dari alur OMS. | Kolom Penggabungan untuk `Penugasan Tracking` bernilai `Ikut TMS`, dan aturan penugasan pada spec dinyatakan pada level **produk**, bukan level order. | REQ-026. Alternatif yang mungkin (perilaku per-jenis-order) tidak didukung teks spec mana pun; bila ternyata berlaku, dibutuhkan REQ tambahan. |
| **ASM-12** | **`clientId` berformat UUID v4** dan bersifat wajib pada path. | Contoh pada spec berbentuk UUID v4. | V-01, REQ-012. |
| **ASM-13** | Menu sisi Vendor **tidak terpengaruh** oleh `addOns` — sheet VD tidak memiliki dimensi add-on/moda. | Sheet VD hanya membandingkan `Vendor TMS` vs `Vendor OMS` dan menyatakan keduanya "Identik". | REQ-050, REQ-057. Bila ternyata vendor juga terdampak add-on moda, dibutuhkan matriks tambahan. |
| **ASM-14** | Label **`Koridoe Historis`** pada sel `PS!A8` adalah **typo** dari **`Koridor Historis`**. | Tidak ada istilah "Koridoe" dalam domain; konteks (deteksi jalur, keluar jalur) menunjukkan "koridor". | REQ-063. Verifikasi label aktual di UI saat eksekusi; jika UI juga typo, laporkan sebagai defect kosmetik terpisah. |
| **ASM-15** | **Model propagasi & efek samping**: perubahan berlaku pada sesi baru (setelah refresh/login ulang); guard diberlakukan di server (UI + API); data lama **tidak dihapus** saat fitur disembunyikan; transaksi berjalan tidak dibatalkan. | Spec dan xlsx sama sekali tidak membahas propagasi, namun ini area risiko tinggi yang wajib diuji. Model ini adalah perilaku paling aman & paling lazim untuk sistem entitlement multi-tenant. | Seluruh R8 (REQ-095…REQ-103) bersifat inferensi. Perlu konfirmasi PO; bila propagasi ditetapkan real-time (tanpa refresh), REQ-095 diperketat. |
| **ASM-16** | **Add-on `SERVICE_*` juga membatasi jenis order yang dapat dibuat**, bukan sekadar menyembunyikan master data. | Nama add-on (`SERVICE_FTL`, `SERVICE_LTL`, …) merujuk layanan pengiriman, dan sheet JP berjudul "Fitur Berdasarkan **Jenis Pengiriman yang Diaktifkan**". | REQ-077. Diberi prioritas `medium` karena tidak dinyatakan eksplisit di matriks. |
| **ASM-17** | **TMS LKL** diperlakukan sebagai **varian/konfigurasi TMS** (bukan produk ketiga pada enum `products`), yang susunan menunya ditentukan oleh **moda aktif** hasil pemetaan add-on. | Enum `products` pada spec hanya memuat `TMS` dan `OMS`; sheet LKL berjudul "Perbandingan Fitur **TMS** LKL" dengan dimensi Darat/Laut/Udara yang selaras dengan add-on `SERVICE_*`. | Seluruh R7 diuji pada client dengan `products` memuat `TMS` dan kombinasi `addOns` yang sesuai. Menu LKL (`Shipment`, `Master Kemasan`, `Master Bank`, `Manajemen Invoice`, `Laporan Keuangan`, `Otomasi Jalur`, `Master Customer`, `Master Rute`) **tidak** muncul pada sheet Shipper — diasumsikan eksklusif varian LKL, bukan kontradiksi. |
| **ASM-18** | Bila **beberapa moda aktif bersamaan**, menu yang tampil adalah **union** kolom-kolom moda yang aktif (konsisten dengan kolom `Keduanya Aktif` pada sheet JP). | Sheet JP secara eksplisit menetapkan perilaku union untuk kombinasi darat+laut; pola yang sama diterapkan untuk kombinasi apa pun di sheet LKL. | REQ-073, REQ-094. |
| **ASM-19** | **Kanal admin** untuk mengubah entitlement adalah **API saja** — tidak ada layar UI admin dalam cakupan modul ini. | Spec hanya menyediakan contoh `curl`; tidak ada desain maupun deskripsi layar admin. | Pengujian R1 dilakukan pada level API (bukan UI). Bila kelak ada UI admin, dibutuhkan requirement tambahan. |
| **ASM-20** | **Base URL pengujian** adalah environment **staging** (`apicore-staging.prahu-hub.com`) sesuai contoh pada spec. | Satu-satunya host yang disebut spec. | Test suite di-*parameterize* per environment; host tidak di-hard-code pada skenario. |
| **ASM-21** | **Aset desain terverifikasi tidak ada (menyempurnakan ASM-01).** Tahap design-analyzer memverifikasi ulang dengan Glob: `inputs/oms000-jenis-produk/designs/**` mengembalikan **0 file**; direktori `inputs/oms000-jenis-produk/` hanya berisi `spec.txt` dan `extras/oms000-jenis-produk.xlsx`. | Tidak ada satu pun PNG untuk di-*grounding*. | **Tinggi.** Section `UI Inventory` diisi 100% dari `Requirements` + `Aturan Validasi` + `User Flow`; **tidak ada** elemen berstatus "terverifikasi". Skenario wajib memprioritaskan assertion **struktural/kardinalitas** di atas assertion **teks persis**. Satu-satunya teks ter-*grounding* adalah nama menu/fitur verbatim dari xlsx (ditandai ✅ pada kolom Label/teks). |
| **ASM-22** | **Konvensi selector & ketersediaan `data-testid`.** Prioritas selector: `getByRole` + accessible name → `getByTestId` → `getByLabel` → teks parsial CI; `data-testid` kebab-case berpola `<domain>-<elemen>[-<varian>]`. Seluruh testid pada UI Inventory ini **belum tentu ada** di kode. | Mengadopsi konvensi `oms015-order-ltl-lcl-universal` (`UI-COMMON`, `UI-096`) dan `oms022-public-tracking-improve` (`ASM-017`, `ASM-030`) agar page object dapat di-*reuse* lintas modul. | **Tinggi.** Katalog testid diperlakukan sebagai **permintaan kontrak test kepada tim FE**. Bila testid tidak pernah ditambahkan, item menu masih dapat dijangkau lewat `getByRole('link', {name})`, tetapi grup menu, kartu setting, dan badge kanal penugasan hanya dapat dijangkau lewat teks — rapuh terhadap perubahan copywriting. |
| **ASM-23** | **Pola testid navigasi = `nav-item-<slug>` dan `nav-group-<slug>`**, sedangkan `oms015` memakai pola lama `nav-<slug>` (mis. `nav-order`, `nav-simulasi-muatan`). Diusulkan pula atribut `data-entitlement-product` dan `data-entitlement-addon` pada elemen yang visibilitasnya diatur entitlement. | Pola `nav-item-`/`nav-group-` diperlukan agar item dan grup dapat dibedakan; atribut `data-entitlement-*` memungkinkan assertion matriks R3/R6 tanpa bergantung label yang belum pasti. | **Sedang.** Selama kontrak FE belum final, skenario memakai selector prioritas-1 sebagai primer dan **dua** kandidat testid (`nav-item-order` **atau** `nav-order`) sebagai fallback. Bila atribut `data-entitlement-*` tidak disediakan, assertion tetap bisa berjalan lewat kombinasi role+name, hanya lebih verbose. |
| **ASM-24** | **Lima baris grup `DASHBOARD` pada sheet `SH` adalah tab/kartu di dalam satu halaman `Dashboard`**, bukan lima link sidebar terpisah. | `oms015` `UI-COMMON` menunjukkan sidebar hanya memuat **satu** link `Dashboard`; kelima nama pada xlsx berpola `Dashboard - <sesuatu>` yang lazim berarti sub-tampilan. | **Sedang.** Bila implementasi ternyata memakai lima route/link terpisah, selector `dashboard-tab-<slug>` diganti `nav-item-dashboard-<slug>` — **logika matriks visibilitas (REQ-030…REQ-034) tidak berubah**. UI-T02 dan UI-T03 sengaja memuat kedua penamaan agar skenario tetap valid pada kedua bentuk. |
| **ASM-25** | **`MASTER OPERASIONAL` adalah grup collapsible pada sidebar**, bukan halaman tunggal; keenam master (Barang, Drop Point, Pelabuhan, Pelayaran, Unit, Sopir) adalah anak di dalamnya. | `oms015` `UI-COMMON` mencantumkan `Master Operasional` sebagai satu entri sidebar sementara sheet `SH` mendaftarkan enam item di bawah judul grup tersebut. | Rendah–Sedang. Skenario perlu **membuka grup** sebelum meng-assert anak-anaknya bila grup ter-*collapse* secara default. Assertion `toHaveCount(0)` tetap valid tanpa membuka grup **hanya jika** anak tidak dirender saat collapse — karena itu skenario disarankan membuka grup lebih dulu. |
| **ASM-26** | **Tidak ada layar UI untuk mengubah entitlement** (menegaskan ASM-19); UI-T00 murni permukaan API. | Spec hanya menyediakan contoh `curl`; tidak ada desain maupun deskripsi layar admin. | Rendah. Seluruh R1 (19 REQ + 23 aturan validasi) menjadi skenario **API-only**, dan setiap skenario UI diawali langkah setup `PATCH` via `request.newContext()`, bukan via UI. |
| **ASM-27** | **Bentuk respons sukses API entitlement = objek datar** `{ "products": [...], "addOns": [...] }`, dengan kemungkinan pembungkus `data`. | Spec hanya menunjukkan request, tidak menunjukkan respons sama sekali (ASM-04). Dua bentuk ini adalah yang paling lazim pada REST. | **Sedang.** JSON path assertion ditulis berlapis: `body.products ?? body.data?.products`. Bila bentuk sebenarnya berbeda (mis. `entitlement.products`), seluruh assertion R1 perlu penyesuaian **path saja**, bukan logika. |
| **ASM-28** | **Pesan error API berada pada `$.message`**, dengan detail opsional pada `$.errors[].field` / `$.errors[].message`. | Konvensi REST paling umum; spec tidak mendefinisikan format error. | Rendah–Sedang. AC-012.2 dan AC-013.3 (pesan menyebut field/nilai bermasalah) di-assert dengan matcher longgar `/(products\|addOns\|clientId)/i` pada gabungan `$.message` + `$.errors[*]`, bukan pada path tunggal. |
| **ASM-29** | **Aplikasi mobile sopir berada di luar cakupan otomasi Playwright web.** Verifikasi "masuk/tidak masuk apps" dilakukan melalui **API daftar tugas sopir**, log/mock **push notification**, atau **efek tidak langsung** pada timeline tracking di web. Endpoint daftar tugas sopir **belum diketahui**. | Playwright mengotomasi browser, bukan aplikasi native. Spec tidak mencantumkan endpoint apa pun selain `PATCH .../entitlement`. | **TINGGI — potensi blocking.** REQ-022, REQ-024, REQ-026 adalah **inti modul** namun tidak dapat diverifikasi langsung. Bila API daftar tugas sopir tidak tersedia untuk test, skenario R2 turun menjadi **manual** dan hanya bagian "penugasan tersimpan" yang terotomasi. Wajib dikonfirmasi ke tim backend sebelum test ditulis. |
| **ASM-30** | **Route/URL menu diusulkan sebagai slug kebab-case** dari nama menu: `/dashboard`, `/order`, `/simulasi-muatan`, `/penugasan-tracking`, `/master-wilayah`, `/master-barang`, `/master-drop-point`, `/master-pelabuhan`, `/master-pelayaran`, `/master-unit`, `/master-sopir`, `/manajemen-vendor`, `/pengaturan-akun`, `/akun-saya`, `/pengaturan-sistem`, `/pusat-notifikasi`, `/shipment`, `/otomasi-jalur`, `/master-rute`, `/master-customer`, `/master-kemasan`, `/master-bank`, `/manajemen-invoice`, `/laporan-keuangan`, `/master-bandara`, `/master-maskapai`. | Tidak ada satu pun URL yang tercantum pada spec/xlsx; slug kebab-case adalah pola paling umum dan konsisten dengan penamaan testid. | **Sedang.** Seluruh skenario guard deep-link (REQ-096, REQ-097 — 4 AC) bergantung pada route ini. Bila route sebenarnya berbeda, skenario gagal pada langkah `page.goto()` — bukan karena bug produk. Route wajib dikonfirmasi/di-parameterisasi lewat fixture sebelum eksekusi. |
| **ASM-31** | **Menu/tab/opsi non-entitle DIHAPUS dari DOM, bukan di-*disable***; dan guard deep-link berupa **halaman 403 ATAU redirect ke beranda** (kedua bentuk diterima). | REQ-029 menyatakan menu "tidak ditampilkan"; REQ-096 secara eksplisit menyebut "redirect ke halaman utama **atau** halaman 403". Tidak ada indikasi state `disabled` di mana pun pada spec/xlsx. | **Sedang.** Assertion memakai `toHaveCount(0)` (bukan `not.toBeVisible()`) dan guard memakai assertion **OR** (403 **atau** redirect) dengan satu assertion keras: **konten fitur tidak boleh muncul**. Bila implementasi ternyata hanya men-*disable* menu, itu dilaporkan sebagai **defect terhadap semangat REQ-029**, bukan diakomodasi. |
| **ASM-32** | **Pemilihan tipe penerima tugas (`Sopir` vs `Pengurus`) berbentuk radio group**, dengan kemungkinan berbentuk dropdown/`combobox`. | Dua opsi yang saling eksklusif paling lazim dirender sebagai radio; `oms015` UI-097 juga memakai pola radio card untuk pilihan eksklusif (`FTL`/`FCL`/`LTL`/`LCL`). | **Sedang.** Selector ditulis berlapis: `getByRole('radio', { name: /^sopir/i })` → `getByRole('option', { name: /^sopir/i })` → `getByTestId('assignment-assignee-type-sopir')`. Bila bentuknya dropdown, langkah interaksi berubah (buka combobox lebih dulu) tetapi matriks state UI-T04 tidak berubah. |
| **ASM-33** | **Indikator kanal penugasan** ("masuk ke aplikasi sopir" vs "input tracking dari web") **mungkin tidak dirender sama sekali** di UI web. | Spec hanya menyatakan perilaku sistem (L17–L18), bukan tampilan. Sangat mungkin perbedaan TMS/OMS bersifat **senyap** dari sisi UI Shipper. | **Tinggi.** `assignment-row-channel` dan `assignment-channel-hint` diperlakukan **opsional & non-blocking** — bila tidak ada, bukan defect. **Assertion utama R2 tetap di UI-T05** (daftar tugas sopir), bukan di badge UI. Meng-assert badge sebagai kriteria lulus akan menghasilkan kegagalan palsu. |
| **ASM-34** | **`Pengaturan Sistem` adalah satu halaman berisi daftar item/kartu** (bukan tab atau sub-menu terpisah), sehingga jumlah item dapat dihitung dengan satu `toHaveCount`. | REQ-067/REQ-068 mensyaratkan penghitungan jumlah item (8 vs 2), yang hanya praktis bila item berada pada satu container. | **Sedang.** Bila item ternyata tersebar sebagai sub-menu/route terpisah, assertion `toHaveCount(8)`/`toHaveCount(2)` diganti dengan assertion keberadaan per item (`setting-item-<slug>`) — daftar slug pada UI-T06 sudah menyediakan keduanya. |
| **ASM-35** | **Opsi `Jenis Pengiriman` pada form order berbentuk radio card, bukan `<select>`**, dan opsi non-entitle **tidak dirender** (bukan disabled). | `oms015` UI-097/UI-102 memperlihatkan kartu radio `FTL`/`FCL`/`LTL`/`LCL` dengan testid `order-type-<jenis>`. Nama opsi untuk `SERVICE_AIR_FREIGHT` (`Air Freight`) **belum pernah muncul** pada desain mana pun — murni usulan. | **Sedang.** Testid `order-type-ftl/ltl/fcl/lcl` mewarisi `oms015` sehingga stabil; **`order-type-air-freight` sepenuhnya baru** dan berisiko tidak ada. REQ-077 berprioritas `medium` (bersandar ASM-16), sehingga kegagalan di sini tidak boleh memblokir rilis suite. |
| **ASM-36** | **Halaman list master bergantung moda punya struktur seragam**: judul `h1` + tombol tambah + tabel + info paginasi, mengikuti pola `oms015` UI-096 (`Menampilkan 1 - 20 data dari 30 data`). | Konsistensi antar halaman master dalam satu produk adalah pola desain lazim; `oms015` menyediakan satu contoh konkret. | Rendah–Sedang. Dipakai untuk (a) assertion ketiadaan konten saat deep-link ditolak, dan (b) verifikasi keutuhan data pasca-reaktivasi (REQ-098, REQ-099) dengan membandingkan `<slug>-pagination-info` sebelum vs sesudah. Bila format teks paginasi berbeda, gunakan jumlah baris tabel sebagai gantinya. |
| **ASM-37** | **Propagasi entitlement diverifikasi dengan `page.reload()`** sebagai langkah default, dan **logout–login** untuk skenario ketat; skenario "tanpa refresh" diperlakukan sebagai **boleh-tetap-lama** (bukan bug). | REQ-095 menyatakan perubahan berlaku pada sesi baru "setelah refresh/navigasi ulang atau paling lambat setelah login ulang"; ALT-12 mengizinkan menu lama tetap tampil sebelum refresh. | **Sedang.** Tanpa langkah reload eksplisit, seluruh skenario matriks menu akan gagal palsu. Sebaliknya, meng-assert perubahan **seketika tanpa reload** akan memaksa perilaku yang tidak diwajibkan requirement. Bila PO menetapkan propagasi real-time, REQ-095 diperketat dan asumsi ini gugur. |
| **ASM-38** | **Setup state entitlement dilakukan lewat API (`PATCH`), bukan lewat UI**, dan setiap file skenario bertanggung jawab mengembalikan entitlement ke nilai semula (teardown) agar tidak saling mengganggu. | Tidak ada layar admin (ASM-19, ASM-26); satu `clientId` staging kemungkinan dipakai bersama beberapa test. | **Tinggi (risiko flakiness).** Entitlement bersifat **global per client**, sehingga skenario yang berjalan **paralel** pada `clientId` yang sama akan saling menimpa. Rekomendasi: jalankan suite modul ini **serial** (`fullyParallel: false` / `workers: 1`) atau sediakan `clientId` terpisah per worker. |

---

## Ringkasan Kuantitatif

| Artefak | Jumlah |
|---|---|
| Requirements (`REQ-001` … `REQ-103`) | **103** |
| — R1 Kontrak API Entitlement | 19 (REQ-001…019) |
| — R2 Aturan Penugasan | 9 (REQ-020…028) |
| — R3 Menu Shipper | 21 (REQ-029…049) |
| — R4 Menu Vendor | 8 (REQ-050…057) |
| — R5 Pengaturan Sistem | 11 (REQ-058…068) |
| — R6 Jenis Pengiriman / Add-on | 9 (REQ-069…077) |
| — R7 TMS LKL | 17 (REQ-078…094) |
| — R8 Propagasi & Efek Samping | 9 (REQ-095…103) |
| Aturan validasi (`V-01` … `V-23`) | **23** |
| Role / Aktor | **5** |
| User flow utama (`UF-1` … `UF-5`) | **5** |
| Alternatif / percabangan (`ALT-01` … `ALT-27`) | **27** |
| Acceptance criteria (`AC-xxx.n`) | **± 280** (2–4 per REQ) |
| Asumsi (`ASM-01` … `ASM-38`) | **38** (ASM-01…20 spec-analyzer, ASM-21…38 design-analyzer) |
| Permukaan uji / layar (`UI-T00` … `UI-T11`) | **12** (1 API + 11 UI), 199 baris elemen |
