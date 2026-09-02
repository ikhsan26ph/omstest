# Analysis — oms022-public-tracking-improve

> **Tahap pipeline:** 1/4 — spec-analyzer
> **Sumber spesifikasi:** `inputs/oms022-public-tracking-improve/spec.txt` (11 baris, 4 blok rule)
> **Aset desain:** **TIDAK ADA** — direktori `inputs/oms022-public-tracking-improve/designs/` tidak tersedia. Seluruh inventaris UI diturunkan dari spec (lihat ASM-001).
> **Aplikasi:** Order Management System (OMS) — halaman **Public Tracking** (kanal publik, tanpa login).
> **Modul terkait:** `oms015-order-ltl-lcl-universal` (REQ-052…REQ-058) — sumber **No. Resi** yang menjadi kunci masuk public tracking.

## Ringkasan Modul

Modul **OMS-022** adalah **penyempurnaan (improve)** halaman **Public Tracking** pada OMS. Halaman ini dipakai **pengirim/penerima** untuk memantau progres pengiriman menggunakan **No. Resi**, tanpa perlu login.

Modul bersifat **turunan penuh** dari Public Tracking **TMS Shipper**. Seluruh struktur, layout, dan alur akses identik, **kecuali satu pembeda inti**:

- **Sumber status di OMS hanya 2 event**: `Selesai Muat` dan `Selesai Bongkar`. Tidak ada event antara (mis. `Menuju Lokasi Muat`, `Tiba di Lokasi`, `Dalam Perjalanan`) yang dilaporkan armada.
- Konsekuensinya, **stepper 3 tahap** (`Pick Up` → `On Delivery` → `Delivered`) harus **diturunkan secara komputasi** dari urutan dan posisi (pertama/terakhir) dua event tersebut — bukan dipetakan 1:1.
- **Riwayat Pengiriman** memperoleh **satu entri sintetis** yang **tidak berasal dari event armada**: `armada dalam perjalanan menuju lokasi bongkar`, di-*inject* otomatis setelah seluruh `Selesai Muat` tuntas.

**Karakter pembeda yang menentukan bentuk test suite:**

| Aspek | Public Tracking TMS Shipper | **Public Tracking OMS (modul ini)** |
|---|---|---|
| Event sumber dari armada | Banyak status perjalanan | **Hanya 2**: `Selesai Muat`, `Selesai Bongkar` |
| Relasi event → tahap stepper | Cenderung 1:1 | **N:M komputasi** — 1 event bisa memicu **2 tahap** sekaligus, atau **0 tahap** |
| Penentu tahap | Nilai status | **Posisi ordinal** event (pertama / terakhir / tengah) |
| Entri Riwayat | Turunan event | Event **+ 1 entri sintetis** yang di-generate sistem |

**Prioritas pengujian:** (1) matriks pemetaan event→stepper untuk keempat tipe pengiriman (**inti modul**), (2) kasus *collapse* — satu `Selesai Muat` tunggal memicu `Pick Up` **dan** `On Delivery` bersamaan, (3) kasus *no-op* — `Selesai Bongkar` non-terakhir **tidak** menggerakkan stepper, (4) kemunculan entri sintetis Riwayat tepat satu kali pada posisi yang benar.

---

## Requirements

### Legenda

| Kolom | Keterangan |
|---|---|
| **ID** | Identifier requirement, dipakai sebagai tag `@REQ-xxx` di tahap scenario-generator |
| **Sumber** | Baris pada `spec.txt` yang menjadi dasar. `INF` = inferensi (lihat Assumptions Log) |
| **Prioritas** | `high` = inti pembeda modul / blocking; `medium` = rule turunan yang harus regresi; `low` = pelengkap |

### Glosarium Istilah

| Istilah | Definisi operasional |
|---|---|
| **Event** | Pelaporan progres oleh armada/driver di OMS. Hanya bernilai `Selesai Muat` atau `Selesai Bongkar`. |
| **`Selesai Muat` ke-*n*** | Event selesai muat pada **alamat pick up ke-*n***. |
| **`Selesai Bongkar` ke-*n*** | Event selesai bongkar pada **alamat drop off ke-*n***. |
| **Muat terakhir** | Event `Selesai Muat` pada alamat pick up **terakhir** (ke-*N*, di mana *N* = jumlah alamat pick up). |
| **Bongkar terakhir** | Event `Selesai Bongkar` pada alamat drop off **terakhir** (ke-*M*, di mana *M* = jumlah alamat drop off). |
| **Tahap (stepper)** | Simpul visual progres: `Pick Up`, `On Delivery`, `Delivered`. |
| **Entri sintetis** | Entri Riwayat Pengiriman yang **tidak** berasal dari event armada, melainkan digenerate sistem. |

---

### R1. Ketentuan Umum & Cakupan

| ID | Requirement | Sumber | Prioritas |
|---|---|---|---|
| **REQ-001** | Halaman **Public Tracking OMS** mengacu penuh pada **Public Tracking TMS Shipper** — struktur halaman, komponen, alur akses, dan penyajian informasi identik. | L1 | high |
| **REQ-002** | **Satu-satunya pembeda terhadap TMS**: pada OMS hanya terdapat **2 status/event pengiriman**, yaitu **`Selesai Muat`** dan **`Selesai Bongkar`**. | L2 | high |
| **REQ-003** | Halaman bersifat **publik** — dapat diakses **tanpa login/autentikasi** oleh pengirim/penerima dengan memasukkan **No. Resi**. | INF | high |
| **REQ-004** | Halaman bersifat **read-only** — pengunjung publik **tidak dapat** mengubah status, membatalkan, maupun mengedit data pengiriman apa pun. | INF | high |

**Acceptance Criteria**

- **REQ-001**
  - AC-001.1: Halaman public tracking OMS menampilkan komponen inti yang sama dengan versi TMS Shipper: form pencarian No. Resi, ringkasan pengiriman, **stepper progres**, dan **Riwayat Pengiriman**.
  - AC-001.2: Urutan dan penamaan section identik dengan versi TMS Shipper.
  - AC-001.3: Perilaku di luar pemetaan status (pencarian, empty state, layout responsif) mengikuti TMS Shipper tanpa modifikasi.
- **REQ-002**
  - AC-002.1: Data event yang ditampilkan pada Riwayat Pengiriman OMS **hanya** berjenis `Selesai Muat` dan `Selesai Bongkar` (di luar entri sintetis REQ-023).
  - AC-002.2: **Tidak ada** entri berjenis status antara TMS (mis. `Menuju Lokasi Muat`, `Tiba di Lokasi Muat`, `Tiba di Lokasi Bongkar`) pada tracking order OMS.
  - AC-002.3: Stepper tetap menampilkan tahap `Pick Up`/`On Delivery`/`Delivered` meskipun event sumbernya hanya dua jenis (tahap **tidak** direduksi menjadi dua).
- **REQ-003**
  - AC-003.1: URL public tracking dapat dibuka pada sesi anonim (tanpa cookie/token login) dan **tidak** melakukan redirect ke halaman login.
  - AC-003.2: Memasukkan No. Resi yang valid menampilkan data pengiriman tanpa prompt autentikasi.
  - AC-003.3: No. Resi berfungsi sebagai satu-satunya kredensial akses ke data pengiriman terkait.
- **REQ-004**
  - AC-004.1: Halaman **tidak** menampilkan tombol aksi mutasi data (`Edit`, `Batalkan`, `Simpan`, ubah status).
  - AC-004.2: Seluruh nilai ditampilkan sebagai teks read-only, bukan input aktif.
  - AC-004.3: Data pengiriman milik resi lain tidak dapat diakses tanpa mengetahui No. Resi-nya.

---

### R2. Model Event Sumber

| ID | Requirement | Sumber | Prioritas |
|---|---|---|---|
| **REQ-005** | Sistem OMS hanya mengenal **dua jenis event** progres pengiriman: **`Selesai Muat`** dan **`Selesai Bongkar`**. Tidak ada event perantara yang dilaporkan armada. | L2 | high |
| **REQ-006** | **Kardinalitas event mengikuti jumlah alamat**: jumlah event `Selesai Muat` = jumlah **alamat pick up**; jumlah event `Selesai Bongkar` = jumlah **alamat drop off**. | L5, L6, L8–L10 (INF) | high |
| **REQ-007** | **Urutan event**: seluruh event `Selesai Muat` terjadi **mendahului** event `Selesai Bongkar` pertama (armada memuat seluruh alamat pick up sebelum berangkat ke lokasi bongkar). | L7, L11 (INF) | high |

**Acceptance Criteria**

- **REQ-005**
  - AC-005.1: Tidak ada jenis event ketiga yang dapat muncul pada timeline tracking order OMS.
  - AC-005.2: Pemetaan stepper dihitung **eksklusif** dari kedua event tersebut (REQ-009…REQ-011).
- **REQ-006**
  - AC-006.1: Pengiriman **Normal** (1 pick up, 1 drop off) menghasilkan tepat **1** `Selesai Muat` dan **1** `Selesai Bongkar`.
  - AC-006.2: Pengiriman **Multi Pick Up 2** menghasilkan tepat **2** `Selesai Muat`.
  - AC-006.3: Pengiriman **Multi Pick Up 3** menghasilkan tepat **3** `Selesai Muat` (L8–L10).
  - AC-006.4: Pengiriman **Multi Drop 2** menghasilkan tepat **2** `Selesai Bongkar`.
  - AC-006.5: Setiap event `Selesai Muat`/`Selesai Bongkar` merujuk pada **satu alamat** yang berbeda — tidak ada dua event untuk alamat yang sama.
- **REQ-007**
  - AC-007.1: Pada Riwayat Pengiriman, seluruh entri `Selesai Muat` muncul **di atas/sebelum** entri `Selesai Bongkar` pertama (sesuai arah kronologi yang berlaku).
  - AC-007.2: Entri sintetis `armada dalam perjalanan menuju lokasi bongkar` berada **di antara** blok muat dan blok bongkar (REQ-024).
  - AC-007.3: `Selesai Bongkar` **tidak** dapat terjadi selagi masih ada alamat pick up yang belum `Selesai Muat`.

---

### R3. Stepper — Tahapan & Aturan Pemetaan *(pembeda inti modul)*

| ID | Requirement | Sumber | Prioritas |
|---|---|---|---|
| **REQ-008** | Stepper public tracking menampilkan tahapan progres: **`Pick Up`** → **`On Delivery`** → **`Delivered`**. | L3 | high |
| **REQ-009** | **`Selesai Muat` PERTAMA** → stepper mencapai tahap **`Pick Up`**. | L3 | high |
| **REQ-010** | **`Selesai Muat` TERAKHIR** → stepper mencapai tahap **`On Delivery`**. | L3 | high |
| **REQ-011** | **`Selesai Bongkar` TERAKHIR** → stepper mencapai tahap **`Delivered`**. | L3 | high |
| **REQ-012** | **Kasus *collapse*** — bila hanya ada **satu** `Selesai Muat` (alamat pick up tunggal), event tersebut sekaligus **pertama dan terakhir**, sehingga **satu event mengaktifkan `Pick Up` DAN `On Delivery` bersamaan**. | L4, L6 | high |
| **REQ-013** | **Kasus *no-op* muat** — `Selesai Muat` yang **bukan pertama dan bukan terakhir** (alamat tengah pada multi pick up ≥ 3) **tidak menaikkan** tahap stepper; stepper tetap pada `Pick Up`. | L3, L5 (INF) | high |
| **REQ-014** | **Kasus *no-op* bongkar** — `Selesai Bongkar` yang **bukan terakhir** **tidak menaikkan** tahap stepper; stepper **tetap** pada `On Delivery`. | L6 | high |
| **REQ-015** | **Progresi monoton** — tahap yang sudah tercapai **tidak pernah mundur**; event berikutnya hanya dapat mempertahankan atau menaikkan tahap. | INF | high |
| **REQ-016** | **State awal** — sebelum ada event `Selesai Muat` apa pun, stepper **belum** mencapai `Pick Up` (seluruh tiga tahap belum tercapai). | INF | medium |

**Matriks Pemetaan Event → Tahap Stepper** *(acuan utama scenario-generator)*

| # | Tipe Pengiriman | Event | Posisi ordinal | Tahap tercapai **setelah** event | Perubahan |
|---|---|---|---|---|---|
| 1 | Normal (1 muat / 1 bongkar) | `Selesai Muat` | 1 dari 1 → pertama **&** terakhir | `Pick Up` + `On Delivery` | **+2 tahap** |
| 2 | Normal | `Selesai Bongkar` | 1 dari 1 → terakhir | `Delivered` | +1 tahap |
| 3 | Multi Pick Up 2 | `Selesai Muat` 1 | 1 dari 2 → pertama | `Pick Up` | +1 tahap |
| 4 | Multi Pick Up 2 | `Selesai Muat` 2 | 2 dari 2 → terakhir | `Pick Up` + `On Delivery` | +1 tahap |
| 5 | Multi Pick Up 2 | `Selesai Bongkar` | 1 dari 1 → terakhir | `Delivered` | +1 tahap |
| 6 | Multi Pick Up 3 | `Selesai Muat` 2 | 2 dari 3 → **tengah** | `Pick Up` (tetap) | **0 (no-op)** |
| 7 | Multi Drop 2 | `Selesai Muat` | 1 dari 1 → pertama **&** terakhir | `Pick Up` + `On Delivery` | **+2 tahap** |
| 8 | Multi Drop 2 | `Selesai Bongkar` 1 | 1 dari 2 → **bukan terakhir** | `On Delivery` (tetap) | **0 (no-op)** |
| 9 | Multi Drop 2 | `Selesai Bongkar` 2 | 2 dari 2 → terakhir | `Delivered` | +1 tahap |
| 10 | Multipoint 2×2 *(INF, ASM-006)* | `Selesai Muat` 1 | 1 dari 2 → pertama | `Pick Up` | +1 tahap |
| 11 | Multipoint 2×2 *(INF)* | `Selesai Muat` 2 | 2 dari 2 → terakhir | `Pick Up` + `On Delivery` | +1 tahap |
| 12 | Multipoint 2×2 *(INF)* | `Selesai Bongkar` 1 | 1 dari 2 → bukan terakhir | `On Delivery` (tetap) | **0 (no-op)** |
| 13 | Multipoint 2×2 *(INF)* | `Selesai Bongkar` 2 | 2 dari 2 → terakhir | `Delivered` | +1 tahap |

> **Aturan umum yang menyatukan seluruh baris di atas:**
> `Pick Up` tercapai ⟺ minimal **1** `Selesai Muat` sudah terjadi.
> `On Delivery` tercapai ⟺ **seluruh** `Selesai Muat` sudah terjadi.
> `Delivered` tercapai ⟺ **seluruh** `Selesai Bongkar` sudah terjadi.

**Acceptance Criteria**

- **REQ-008**
  - AC-008.1: Stepper menampilkan minimal tiga simpul berlabel `Pick Up`, `On Delivery`, dan `Delivered` dengan urutan tersebut.
  - AC-008.2: Setiap simpul memiliki state visual yang dapat dibedakan: **tercapai/aktif** vs **belum tercapai**.
  - AC-008.3: Label tahap ditampilkan konsisten untuk seluruh tipe pengiriman (tidak berubah mengikuti jumlah alamat).
- **REQ-009**
  - AC-009.1: Setelah event `Selesai Muat` pertama, simpul `Pick Up` berubah menjadi tercapai.
  - AC-009.2: Pada saat yang sama, `Delivered` **belum** tercapai.
  - AC-009.3: Berlaku identik untuk seluruh tipe pengiriman (Normal, Multi Pick Up, Multi Drop, Multipoint).
- **REQ-010**
  - AC-010.1: Setelah event `Selesai Muat` terakhir, simpul `On Delivery` berubah menjadi tercapai.
  - AC-010.2: Simpul `Pick Up` tetap dalam state tercapai (tidak ter-reset).
  - AC-010.3: `On Delivery` **tidak** tercapai selama masih ada alamat pick up yang belum `Selesai Muat` (uji negatif pada multi pick up).
- **REQ-011**
  - AC-011.1: Setelah event `Selesai Bongkar` terakhir, simpul `Delivered` berubah menjadi tercapai.
  - AC-011.2: Ketiga simpul (`Pick Up`, `On Delivery`, `Delivered`) berada dalam state tercapai — stepper penuh.
  - AC-011.3: `Delivered` **tidak** tercapai selama masih ada alamat drop off yang belum `Selesai Bongkar` (uji negatif pada multi drop).
- **REQ-012**
  - AC-012.1: **Pengiriman Normal** — setelah satu-satunya `Selesai Muat`, **kedua** simpul `Pick Up` dan `On Delivery` tercapai dalam satu kali pembaruan.
  - AC-012.2: **Multi Drop 2** — setelah satu-satunya `Selesai Muat`, `Pick Up` dan `On Delivery` tercapai bersamaan (L6).
  - AC-012.3: Tidak ada state antara di mana `Pick Up` tercapai namun `On Delivery` belum, pada pengiriman berjumlah alamat pick up = 1.
  - AC-012.4: `Delivered` tetap belum tercapai pada kondisi ini.
- **REQ-013**
  - AC-013.1: **Multi Pick Up 3** — setelah `Selesai Muat` alamat ke-2, stepper **tetap** pada `Pick Up`; `On Delivery` **belum** tercapai.
  - AC-013.2: Baru setelah `Selesai Muat` alamat ke-3 (terakhir), `On Delivery` tercapai.
  - AC-013.3: Event muat tengah tetap menambah entri pada Riwayat Pengiriman meskipun tidak menggerakkan stepper (REQ-022).
- **REQ-014**
  - AC-014.1: **Multi Drop 2** — setelah `Selesai Bongkar` alamat ke-1, stepper **tetap** pada `On Delivery`.
  - AC-014.2: Simpul `Delivered` **belum** tercapai pada kondisi tersebut.
  - AC-014.3: Baru setelah `Selesai Bongkar` alamat ke-2 (terakhir), `Delivered` tercapai.
  - AC-014.4: Event bongkar non-terakhir tetap tercatat pada Riwayat Pengiriman meskipun tidak menggerakkan stepper (REQ-025).
- **REQ-015**
  - AC-015.1: Simpul yang sudah tercapai tetap tercapai setelah event berikutnya diproses.
  - AC-015.2: Tidak ada urutan event yang menyebabkan `Delivered` tercapai sebelum `On Delivery`.
  - AC-015.3: Tidak ada urutan event yang menyebabkan `On Delivery` tercapai sebelum `Pick Up`.
  - AC-015.4: Memuat ulang halaman menampilkan tahap yang sama (state persisten, bukan hasil animasi sesi).
- **REQ-016**
  - AC-016.1: Sebelum event `Selesai Muat` pertama, simpul `Pick Up` berada dalam state **belum tercapai**.
  - AC-016.2: `On Delivery` dan `Delivered` juga belum tercapai.
  - AC-016.3: Halaman tetap menampilkan stepper (tidak kosong/error) meskipun belum ada event.

---

### R4. Matriks Skenario per Tipe Pengiriman

| ID | Requirement | Sumber | Prioritas |
|---|---|---|---|
| **REQ-017** | **Pengiriman Normal** — `Selesai Muat` → `Pick Up` **dan** `On Delivery`; `Selesai Bongkar` (terakhir) → `Delivered`. | L4 | high |
| **REQ-018** | **Multi Pick Up 2** — `Selesai Muat 1` → `Pick Up`; `Selesai Muat 2` → `Pick Up` + `On Delivery`; `Selesai Bongkar` (terakhir) → `Delivered`. | L5 | high |
| **REQ-019** | **Multi Drop 2** — `Selesai Muat` → `Pick Up` + `On Delivery`; `Selesai Bongkar 1` → tetap `On Delivery`; `Selesai Bongkar 2` → `Delivered`. | L6 | high |
| **REQ-020** | **Multipoint (multi pick up + multi drop)** — mengikuti aturan umum REQ-009…REQ-011 tanpa pengecualian: `Pick Up` pada muat pertama, `On Delivery` pada muat terakhir, `Delivered` pada bongkar terakhir. | INF | medium |

**Acceptance Criteria**

- **REQ-017**
  - AC-017.1: Pada order Normal, stepper setelah `Selesai Muat` menunjukkan `Pick Up` **dan** `On Delivery` tercapai.
  - AC-017.2: `Delivered` belum tercapai sampai `Selesai Bongkar` dilaporkan.
  - AC-017.3: Setelah `Selesai Bongkar`, stepper penuh (`Delivered` tercapai).
  - AC-017.4: Spec L4 tidak menyebut tahap `Delivered` untuk kasus Normal; kelengkapan ini mengikuti aturan umum L3 (lihat ASM-005).
- **REQ-018**
  - AC-018.1: Setelah `Selesai Muat` alamat 1, hanya `Pick Up` yang tercapai.
  - AC-018.2: Setelah `Selesai Muat` alamat 2, `Pick Up` dan `On Delivery` tercapai.
  - AC-018.3: `Delivered` tercapai setelah `Selesai Bongkar` terakhir (mengikuti aturan umum L3 — ASM-005).
  - AC-018.4: Urutan transisi teramati adalah dua langkah terpisah, berbeda dari kasus Normal yang satu langkah (kontras terhadap AC-017.1).
- **REQ-019**
  - AC-019.1: Setelah `Selesai Muat`, `Pick Up` dan `On Delivery` tercapai bersamaan.
  - AC-019.2: Setelah `Selesai Bongkar` alamat 1, tahap **tidak berubah** — tetap `On Delivery`, `Delivered` belum tercapai.
  - AC-019.3: Setelah `Selesai Bongkar` alamat 2, `Delivered` tercapai.
  - AC-019.4: Jumlah entri bongkar pada Riwayat = 2, meskipun perubahan stepper hanya 1 kali.
- **REQ-020**
  - AC-020.1: Pada multipoint 2 pick up × 2 drop off, `Pick Up` tercapai setelah muat ke-1.
  - AC-020.2: `On Delivery` tercapai setelah muat ke-2 (terakhir).
  - AC-020.3: Bongkar ke-1 tidak mengubah tahap; bongkar ke-2 memicu `Delivered`.
  - AC-020.4: Entri sintetis `armada dalam perjalanan menuju lokasi bongkar` tetap muncul tepat satu kali setelah muat terakhir (REQ-023, REQ-024).

---

### R5. Riwayat Pengiriman

| ID | Requirement | Sumber | Prioritas |
|---|---|---|---|
| **REQ-021** | Halaman menampilkan section **`Riwayat Pengiriman`** berupa daftar entri progres secara **kronologis**. | L7 | high |
| **REQ-022** | Setiap event **`Selesai Muat`** menghasilkan **satu entri** riwayat dengan keterangan **`barang telah dimuat`** — satu entri per alamat muat. | L8–L10 | high |
| **REQ-023** | Setelah **seluruh** `Selesai Muat` tuntas, sistem **otomatis menambahkan** entri keterangan **`armada dalam perjalanan menuju lokasi bongkar`** (spec L7 menyebutnya `berangkat ke lokasi bongkar` — lihat ASM-003). | L7, L11 | high |
| **REQ-024** | Entri otomatis tersebut muncul **tepat satu kali** per pengiriman dan diposisikan **persis setelah** entri `Selesai Muat` terakhir, **sebelum** entri bongkar pertama. | L11 (INF) | high |
| **REQ-025** | Setiap event **`Selesai Bongkar`** menghasilkan **satu entri** riwayat — satu entri per alamat bongkar. | INF | high |
| **REQ-026** | Setiap entri riwayat menampilkan **keterangan** beserta **penanda waktu** (dan **lokasi/alamat** bila tersedia). | INF | medium |

**Contoh Riwayat — Multi Pick Up 3** *(sesuai L8–L11, urutan kronologis)*

| # | Pemicu | Keterangan entri | Jenis |
|---|---|---|---|
| 1 | `Selesai Muat` alamat 1 | `barang telah dimuat` | Event |
| 2 | `Selesai Muat` alamat 2 | `barang telah dimuat` | Event |
| 3 | `Selesai Muat` alamat 3 **(terakhir)** | `barang telah dimuat` | Event |
| 4 | *(otomatis oleh sistem)* | `armada dalam perjalanan menuju lokasi bongkar` | **Sintetis** |
| 5 | `Selesai Bongkar` alamat terakhir | *(keterangan bongkar — ASM-004)* | Event |

**Acceptance Criteria**

- **REQ-021**
  - AC-021.1: Section `Riwayat Pengiriman` dirender pada halaman public tracking.
  - AC-021.2: Entri ditampilkan berurutan secara kronologis dan konsisten arahnya (lihat ASM-007).
  - AC-021.3: Riwayat konsisten setelah reload halaman.
  - AC-021.4: Pengiriman tanpa event menampilkan empty state, bukan error.
- **REQ-022**
  - AC-022.1: Multi pick up 3 menghasilkan **tepat 3** entri berketerangan `barang telah dimuat`.
  - AC-022.2: Pengiriman Normal menghasilkan **tepat 1** entri `barang telah dimuat`.
  - AC-022.3: Multi pick up 2 menghasilkan **tepat 2** entri `barang telah dimuat`.
  - AC-022.4: Ketiga entri pada multi pick up 3 memakai keterangan yang **sama persis**, hanya berbeda alamat/waktu (L8–L10).
  - AC-022.5: Entri muat alamat tengah tetap muncul walau tidak menggerakkan stepper (konsisten REQ-013).
- **REQ-023**
  - AC-023.1: Setelah `Selesai Muat` terakhir, entri `armada dalam perjalanan menuju lokasi bongkar` muncul **tanpa** aksi tambahan dari armada.
  - AC-023.2: Entri tersebut **belum** muncul selama masih ada alamat pick up yang belum `Selesai Muat` (uji negatif pada multi pick up 3 setelah alamat ke-2).
  - AC-023.3: Pada pengiriman Normal (1 alamat muat), entri muncul langsung setelah satu-satunya `Selesai Muat`.
  - AC-023.4: Assertion teks memakai matcher toleran terhadap dua varian penamaan spec (ASM-003).
- **REQ-024**
  - AC-024.1: Entri sintetis muncul **tepat satu kali** — tidak digandakan meskipun jumlah alamat muat > 1.
  - AC-024.2: Posisinya **tepat setelah** entri `Selesai Muat` terakhir.
  - AC-024.3: Posisinya **sebelum** entri `Selesai Bongkar` pertama.
  - AC-024.4: Entri tetap ada (tidak hilang) setelah event bongkar berlangsung.
- **REQ-025**
  - AC-025.1: Multi drop 2 menghasilkan **tepat 2** entri bongkar.
  - AC-025.2: Pengiriman Normal menghasilkan **tepat 1** entri bongkar.
  - AC-025.3: Entri bongkar non-terakhir tetap muncul meskipun stepper tidak bergerak (konsisten REQ-014).
  - AC-025.4: Entri bongkar terakhir konsisten dengan tercapainya tahap `Delivered`.
- **REQ-026**
  - AC-026.1: Setiap entri menampilkan teks keterangan.
  - AC-026.2: Setiap entri menampilkan penanda waktu.
  - AC-026.3: Penanda waktu antar entri konsisten dengan urutan kronologis (tidak ada entri yang waktunya mendahului entri sebelumnya).
  - AC-026.4: Entri sintetis juga memiliki penanda waktu (mengikuti waktu `Selesai Muat` terakhir — ASM-008).

---

### R6. Konsistensi Stepper ↔ Riwayat

| ID | Requirement | Sumber | Prioritas |
|---|---|---|---|
| **REQ-027** | **Stepper dan Riwayat Pengiriman harus konsisten** — tahap yang ditampilkan stepper selalu sesuai dengan event terakhir yang tercatat pada Riwayat. | INF | high |

**Acceptance Criteria**

- **REQ-027**
  - AC-027.1: Bila Riwayat memuat minimal satu entri `barang telah dimuat`, simpul `Pick Up` tercapai.
  - AC-027.2: Bila Riwayat memuat entri `armada dalam perjalanan menuju lokasi bongkar`, simpul `On Delivery` tercapai.
  - AC-027.3: Bila seluruh entri bongkar sudah lengkap, simpul `Delivered` tercapai.
  - AC-027.4: Tidak ada kondisi di mana stepper menunjukkan tahap yang belum didukung entri Riwayat mana pun.

---

## Aturan Validasi

| ID | Field / Objek | Aturan | Sumber |
|---|---|---|---|
| **V-01** | `No. Resi` (input pencarian) | **Wajib diisi** — pencarian dengan input kosong ditolak/ditahan disertai pesan validasi. | INF (ASM-002) |
| **V-02** | `No. Resi` | Whitespace di awal/akhir di-**trim** sebelum pencarian. | INF (ASM-002) |
| **V-03** | `No. Resi` | Format alfanumerik tanpa spasi (mengacu pola OMS-015: prefix huruf + deret angka, mis. `LKL2567828992`). Panjang mengikuti generator sistem — **tidak** di-assert secara ketat. | INF (ASM-002) |
| **V-04** | `No. Resi` tidak ditemukan | Menampilkan **empty state / pesan tidak ditemukan**, bukan halaman error atau stack trace. | INF (ASM-002) |
| **V-05** | Jumlah tahap stepper | Tepat **3 tahap** wajib: `Pick Up`, `On Delivery`, `Delivered`. Tahap tambahan sebelum `Pick Up` tidak di-assert (ASM-009). | L3 |
| **V-06** | Jenis event | Nilai event **hanya** boleh `Selesai Muat` atau `Selesai Bongkar` — himpunan tertutup. | L2 |
| **V-07** | Kardinalitas entri muat | Jumlah entri `barang telah dimuat` **= jumlah alamat pick up** (bukan lebih, bukan kurang). | L8–L10 |
| **V-08** | Kardinalitas entri sintetis | Jumlah entri `armada dalam perjalanan menuju lokasi bongkar` **= tepat 1** per pengiriman. | L11 (INF) |
| **V-09** | Kardinalitas entri bongkar | Jumlah entri bongkar **= jumlah alamat drop off**. | INF |
| **V-10** | Monotonisitas stepper | Tahap tercapai tidak boleh berkurang antar pembaruan. | INF |
| **V-11** | Prasyarat `On Delivery` | Tidak boleh tercapai bila `count(Selesai Muat) < jumlah alamat pick up`. | L3, L5 |
| **V-12** | Prasyarat `Delivered` | Tidak boleh tercapai bila `count(Selesai Bongkar) < jumlah alamat drop off`. | L3, L6 |
| **V-13** | Otorisasi | Halaman **tidak** boleh mensyaratkan login; sebaliknya, tanpa No. Resi yang benar data tidak boleh terekspos. | INF |

### Katalog Teks Persis *(untuk assertion — verifikasi ke implementasi)*

| Teks | Jenis | Catatan |
|---|---|---|
| `Selesai Muat` | Nama status/event | L2 — kapitalisasi mengikuti spec |
| `Selesai Bongkar` | Nama status/event | L2 |
| `Pick Up` | Label tahap stepper | L3–L6 (spec menulis `Pick Up` dan `Pick up` — matcher case-insensitive, ASM-010) |
| `On Delivery` | Label tahap stepper | L3–L6 |
| `Delivered` | Label tahap stepper | L3, L6 |
| `barang telah dimuat` | Keterangan entri riwayat | L8–L10 |
| `armada dalam perjalanan menuju lokasi bongkar` | Keterangan entri sintetis | L11 — **kanonik** |
| `berangkat ke lokasi bongkar` | Varian keterangan entri sintetis | L7 — varian, lihat ASM-003 |
| `Riwayat Pengiriman` | Judul section | L7 |

> **Aturan pakai:** seluruh assertion teks memakai **partial + case-insensitive match**. Untuk entri sintetis gunakan matcher gabungan: `/(berangkat ke lokasi bongkar|dalam perjalanan menuju lokasi bongkar)/i`.

---

## Role / Aktor & Hak Akses

| Aktor | Kanal | Hak Akses | Catatan |
|---|---|---|---|
| **Pengirim / Penerima (publik)** | Halaman Public Tracking (tanpa login) | **Lihat saja** — input No. Resi, lihat ringkasan pengiriman, stepper, dan Riwayat Pengiriman. | Aktor **utama** modul ini. Tidak dapat mengubah data apa pun (REQ-004). |
| **Pengunjung anonim / Guest** | Halaman Public Tracking | Sama dengan di atas — akses dibatasi oleh **kepemilikan No. Resi**, bukan oleh sesi login. | Tanpa No. Resi yang benar, tidak ada data yang terekspos (V-13). |
| **Driver / Armada (aplikasi vendor)** | Aplikasi driver/vendor OMS | **Sumber event** — melaporkan `Selesai Muat` dan `Selesai Bongkar` per alamat. | **Bukan** pengguna halaman public tracking; berperan sebagai pemicu perubahan state (ASM-011). |
| **Vendor / Admin Vendor** | OMS (terautentikasi) | Melakukan penugasan armada; memantau progres. Tidak mengubah tampilan public tracking secara langsung. | Di luar cakupan pengujian UI modul ini. |
| **Staff Operasional / Admin Shipper** | OMS (terautentikasi) | Melihat No. Resi pada Detail Order & pop up `Data No. Resi`, lalu membagikannya ke pengirim/penerima. | Mengacu `oms015` REQ-052…REQ-058. |
| **Sistem OMS** | — | **Menghitung tahap stepper** dari posisi ordinal event (REQ-009…REQ-011) dan **meng-*inject* entri sintetis** Riwayat (REQ-023). | Aktor non-manusia; perilakunya adalah objek uji utama. |

---

## User Flow

### Flow Utama (Happy Path)

1. Pengirim/penerima menerima **No. Resi** dari shipper (hasil generate sistem OMS pada order LTL/LCL).
2. Membuka **halaman Public Tracking OMS** (URL publik, tanpa login).
3. Memasukkan **No. Resi** pada input pencarian.
4. Menekan aksi lacak/cari.
5. Sistem menampilkan **ringkasan pengiriman**, **stepper progres**, dan **Riwayat Pengiriman**.
6. **Stepper** menunjukkan tahap sesuai aturan pemetaan (matriks R3); **Riwayat** menampilkan entri kronologis termasuk entri sintetis bila muat sudah tuntas.
7. Pengunjung dapat memuat ulang halaman kapan pun untuk melihat progres terbaru.

### Flow Progres (dari sisi perubahan state)

| Langkah | Pemicu | Efek Stepper | Efek Riwayat |
|---|---|---|---|
| P0 | Belum ada event | Belum ada tahap tercapai (REQ-016) | Kosong / hanya entri awal |
| P1 | `Selesai Muat` **pertama** | `Pick Up` tercapai | +1 entri `barang telah dimuat` |
| P2 | `Selesai Muat` **tengah** *(hanya bila alamat muat ≥ 3)* | **Tidak berubah** | +1 entri `barang telah dimuat` |
| P3 | `Selesai Muat` **terakhir** | `On Delivery` tercapai | +1 entri `barang telah dimuat`, **lalu +1 entri sintetis** |
| P4 | `Selesai Bongkar` **bukan terakhir** | **Tidak berubah** | +1 entri bongkar |
| P5 | `Selesai Bongkar` **terakhir** | `Delivered` tercapai | +1 entri bongkar |

> **Catatan:** bila alamat pick up = 1, langkah **P1 dan P3 melebur** menjadi satu event (REQ-012).

### Flow Alternatif / Percabangan

| Kode | Kondisi | Perilaku yang diharapkan |
|---|---|---|
| **ALT-01** | Input No. Resi **kosong** lalu lacak | Pencarian ditahan + pesan validasi wajib (V-01). |
| **ALT-02** | No. Resi **tidak ditemukan** | Empty state / pesan tidak ditemukan, bukan error (V-04). |
| **ALT-03** | No. Resi valid namun **belum ada event** | Halaman tampil; stepper belum tercapai; riwayat empty state (REQ-016, AC-021.4). |
| **ALT-04** | Pengiriman **Normal** | Satu event muat memicu 2 tahap sekaligus (REQ-017). |
| **ALT-05** | Pengiriman **Multi Pick Up 2** | Dua transisi terpisah pada fase muat (REQ-018). |
| **ALT-06** | Pengiriman **Multi Pick Up 3** | Muat ke-2 adalah *no-op* stepper namun tetap menambah entri riwayat (REQ-013, AC-022.5). |
| **ALT-07** | Pengiriman **Multi Drop 2** | Bongkar ke-1 adalah *no-op* stepper (REQ-019). |
| **ALT-08** | Pengiriman **Multipoint** | Mengikuti aturan umum tanpa pengecualian (REQ-020, ASM-006). |
| **ALT-09** | Order **dibatalkan** sebelum/sedang berjalan | **Tidak diatur spec** — perilaku tracking untuk order `Dibatalkan` menjadi asumsi (ASM-012). |
| **ALT-10** | Satu order memiliki **beberapa No. Resi** (resi melekat pada barang) | Setiap resi menampilkan progres pengiriman yang sama untuk order tersebut (ASM-013). |

---

## UI Inventory

> ## ⚠ SELURUH ISI SECTION INI ADALAH **USULAN (HIPOTESIS)** — BELUM DIVERIFIKASI
>
> **Mode: TANPA-DESAIN.** Direktori `inputs/oms022-public-tracking-improve/designs/` sudah **diverifikasi kosong** (0 file PNG) — lihat **ASM-001** dan **ASM-016**.
> Inventaris di bawah **diturunkan sepenuhnya dari `Requirements`, `Aturan Validasi`, dan `User Flow`** pada dokumen ini — **bukan** dari pengamatan visual.
>
> Konsekuensinya, untuk **setiap** baris tabel di bawah:
> - **Nama layar** = penamaan kerja (bukan judul resmi produk);
> - **Teks / label / placeholder** = **usulan**, belum tentu sama dengan implementasi;
> - **Selector `getByRole` / `getByLabel` / `getByTestId`** = **usulan**, belum tentu ada di DOM;
> - **`data-testid`** = **permintaan kontrak test kepada tim FE** (ASM-030), bukan fakta.
>
> Sebelum dipakai sebagai assertion keras, seluruh selector **wajib** diverifikasi ke implementasi atau ke desain saat aset tersedia.
>
> **Acuan konvensi:** penamaan `data-testid` dan urutan prioritas selector mengikuti UI Inventory modul **`oms015-order-ltl-lcl-universal`** (`output/oms015-order-ltl-lcl-universal/oms015-order-ltl-lcl-universal.analysis.md`, section `UI-COMMON`, `UI-096`–`UI-105`, dan `UI-D01`–`UI-D08`) agar konsisten lintas modul — lihat **ASM-017**.

### Konvensi Selector (berlaku untuk seluruh layar di bawah)

| Prioritas | Strategi | Bentuk | Kapan dipakai |
|---|---|---|---|
| **1** | **ARIA role + accessible name** | `getByRole('<role>', { name: /<regex>/i })` | Default untuk seluruh elemen interaktif & heading. Nama memakai **regex case-insensitive** karena kapitalisasi label tidak konsisten pada spec (**ASM-010**). |
| **2** | **`data-testid`** | `getByTestId('<kebab-case>')` | Untuk elemen struktural/stateful yang tidak punya role bermakna (stepper node, item riwayat, container hasil). Testid = **usulan** (**ASM-030**). |
| **3** | **Label text** | `getByLabel(/<regex>/i)` | Untuk field form (`No. Resi`). Fallback bila role/name tidak reliabel. |
| **4** | **Text matcher parsial + CI** | `getByText(/<regex>/i)` | Fallback terakhir untuk teks statis, keterangan riwayat, dan pesan. **Selalu parsial + `i`** — jangan `exact: true`. |

**Aturan tambahan:**

1. **Jangan** memakai `exact: true` pada teks yang bersumber dari spec — kapitalisasi bervariasi (`Pick Up` vs `Pick up`, `Selesai bongkar` vs `Selesai Bongkar`) — **ASM-010**.
2. **Jangan** memakai indeks absolut (`.nth(2)`) untuk memverifikasi urutan riwayat — pakai perbandingan **posisi relatif** antar entri (**ASM-007**).
3. **Selalu** melakukan *scoping* ke container (`getByTestId('history-list')`, `getByTestId('tracking-stepper')`) sebelum mencari elemen anak, karena teks seperti `Pick Up` berpotensi muncul di stepper **dan** di ringkasan/riwayat.
4. Pola penamaan testid: `<domain>-<elemen>[-<varian>]`, kebab-case, tanpa spasi — mis. `resi-input`, `tracking-stepper`, `history-list`.

### Daftar Layar / Komponen — **seluruhnya turunan (tanpa aset desain)**

| ID | Layar / Komponen | Jenis | State yang dicakup | REQ / AC terkait |
|---|---|---|---|---|
| **UI-T00** | Kerangka halaman publik (shell) | Layout | default | REQ-003, REQ-004 |
| **UI-T01** | Halaman Public Tracking — state awal | Halaman | **default / empty** (form kosong, belum ada hasil) | REQ-001, REQ-003 |
| **UI-T02** | Form pencarian `No. Resi` — state validasi | Komponen | **error** (input kosong / tidak valid) | V-01, V-02, V-03, ALT-01 |
| **UI-T03** | Pencarian sedang berjalan | State | **loading** | ASM-025 |
| **UI-T04** | Hasil: `No. Resi` tidak ditemukan | State | **empty / not found** | V-04, ALT-02 |
| **UI-T05** | Hasil tracking — ringkasan pengiriman | Komponen | **success** (read-only) | REQ-001, REQ-004, AC-001.1 |
| **UI-T06** | **Stepper 3 tahap** *(pembeda inti)* | Komponen | **belum tercapai / partial progress / penuh** | REQ-008…REQ-020, V-05, V-10–V-12 |
| **UI-T07** | **`Riwayat Pengiriman`** — daftar terisi | Komponen | **success / partial** | REQ-021…REQ-026, V-07–V-09 |
| **UI-T08** | `Riwayat Pengiriman` — belum ada event | State | **empty** | AC-021.4, ALT-03 |
| **UI-T09** | Gangguan sistem / jaringan | State | **error (non-not-found)** | V-04 (kontras), ASM-022 |
| **UI-T10** | Elemen yang **HARUS ABSEN** | Assertion negatif | — | REQ-002, REQ-004, REQ-005, V-06, V-13 |

> Prefiks `UI-T` dipakai (bukan `UI-D` seperti pada `oms015`) agar ID tidak berbenturan saat kedua dokumen dirujuk bersamaan oleh scenario-generator.

---

### UI-T00 — Kerangka halaman publik (shell)

**Konteks:** kerangka yang diasumsikan membungkus seluruh state di bawah. Halaman **publik**, tanpa sesi login (REQ-003) — sehingga shell aplikasi terautentikasi milik `oms015` (sidebar, badge peran, profil, kuota) **tidak** diharapkan muncul (**ASM-026**).

| Elemen | Teks / label (**usulan**) | Tipe & state | Selector usulan (prioritas 1) | Fallback (label / teks) | `data-testid` **usulan** |
|---|---|---|---|---|---|
| Root halaman | — | Container | `getByTestId('public-tracking-page')` | `page.locator('main')` | `public-tracking-page` |
| Logo / brand | `Order Management System` \| nama tenant | Gambar / link | `getByRole('link', { name: /order management system\|tenant/i })` | `getByText(/order management system/i)` | `public-brand` |
| Judul halaman | `Lacak Pengiriman` \| `Public Tracking` \| `Tracking Pengiriman` | Heading (h1) | `getByRole('heading', { level: 1 })` | `getByText(/(lacak\|tracking)/i)` | `tracking-page-title` |
| Deskripsi / subjudul | mis. `Masukkan No. Resi untuk melacak pengiriman Anda` | Teks statis | — | `getByText(/no\.?\s*resi/i)` | `tracking-page-subtitle` |
| Footer | informasi hak cipta / versi | Contentinfo | `getByRole('contentinfo')` | — | `public-footer` |

**Catatan pemakaian:** judul halaman **belum diketahui** — jangan menjadikannya assertion blocking; cukup `expect(page.getByTestId('public-tracking-page')).toBeVisible()` atau assertion terhadap keberadaan input resi (UI-T01).

---

### UI-T01 — Halaman Public Tracking, **state awal / empty**

**Konteks:** halaman baru dibuka pada sesi anonim. Form pencarian kosong; **belum ada** ringkasan, stepper, maupun riwayat yang dirender. Diasumsikan form dan hasil berada pada **satu halaman** (**ASM-018**).

| Elemen | Teks / label / placeholder (**usulan**) | Tipe & state | Selector usulan (prioritas 1) | Fallback (label / teks) | `data-testid` **usulan** |
|---|---|---|---|---|---|
| Form pencarian | — | `form` | `getByRole('form', { name: /lacak\|cari\|resi/i })` | `getByTestId('resi-search-form')` | `resi-search-form` |
| Label field | `No. Resi` | Label | — | `getByText(/no\.?\s*resi/i)` | `resi-input-label` |
| **Input `No. Resi`** | placeholder `Masukkan No. Resi` (**ASM-019**) | `textbox` / `searchbox` — **empty**, enabled, **wajib** (V-01) | `getByRole('textbox', { name: /no\.?\s*resi/i })` \| `getByRole('searchbox')` | `getByLabel(/no\.?\s*resi/i)` \| `getByPlaceholder(/resi/i)` | **`resi-input`** |
| **Tombol lacak** | `Lacak` \| `Cari` \| `Lacak Pengiriman` (**ASM-020**) | `button` (submit) — enabled | `getByRole('button', { name: /(lacak\|cari\|track)/i })` | `getByTestId('resi-submit')` | **`resi-submit`** |
| Tombol reset (opsional) | `Reset` \| ikon `×` di dalam input | Button ikon — muncul saat input terisi | `getByRole('button', { name: /(reset\|hapus\|clear)/i })` | — | `resi-clear` |
| Helper text (opsional) | mis. `Contoh: LKL2567828992` | Teks bantu | — | `getByText(/contoh:/i)` | `resi-input-helper` |
| Area hasil | — | Container — **belum dirender** pada state ini | `getByTestId('tracking-result')` → `toHaveCount(0)` | — | `tracking-result` |

**State yang harus dapat dibedakan pada layar ini**

| State | Indikator yang diharapkan | Assertion usulan |
|---|---|---|
| **default / empty** | input kosong, tombol lacak enabled, area hasil belum ada | `expect(getByTestId('resi-input')).toHaveValue('')` + `expect(getByTestId('tracking-result')).toHaveCount(0)` |
| **terisi** | input bernilai resi | `toHaveValue('LKL2567828992')` |
| **submitted** | transisi ke UI-T03 (loading) lalu UI-T04/UI-T05 | — |

**Nilai contoh untuk seed/test data:** mengikuti pola `oms015` (pop up `Data No. Resi`) — `LKL7920830903`, `LKL2567828992`, `LKL8900765636`. **Jangan** meng-assert keunikan atau prefix resi (data dummy — `oms015` ASM-030).

---

### UI-T02 — Form pencarian, **state validasi / error**

**Konteks:** pengunjung menekan tombol lacak dengan input kosong (ALT-01) atau memasukkan nilai yang tidak lolos aturan format (V-03). Diasumsikan validasi terjadi **saat submit**, bukan saat render (pola `oms015` ASM-038).

| Elemen | Teks (**usulan**) | Tipe & state | Selector usulan | Fallback | `data-testid` **usulan** |
|---|---|---|---|---|---|
| Input `No. Resi` | — | `textbox` — **invalid** | `getByTestId('resi-input')` → `toHaveAttribute('aria-invalid', 'true')` | assertion visual border merah | `resi-input` |
| Pesan validasi inline | `No. Resi harus diisi` (**ASM-021**) | Teks error di bawah input | `getByRole('alert')` | `getByText(/(harus diisi\|wajib diisi\|tidak boleh kosong)/i)` | `resi-input-error` |
| Area hasil | — | **tidak dirender** | `getByTestId('tracking-result')` → `toHaveCount(0)` | — | `tracking-result` |

**Pesan validasi yang mungkin muncul** *(seluruhnya usulan — belum diverifikasi)*

| # | Pemicu | Teks usulan | Matcher yang disarankan | Aturan |
|---|---|---|---|---|
| 1 | Submit dengan input **kosong** | `No. Resi harus diisi` | `/(no\.?\s*resi).*(harus\|wajib)\s*diisi/i` — longgar: `/(harus diisi\|wajib diisi)/i` | V-01 |
| 2 | Input hanya **spasi** | sama dengan #1 (setelah trim) | idem | V-02 |
| 3 | Format tidak valid (mengandung spasi/simbol) | `Format No. Resi tidak valid` | `/(format).*(tidak valid\|salah)/i` | V-03 — **opsional**, jangan blocking |
| 4 | Resi **tidak ditemukan** | lihat UI-T04 | `/(tidak ditemukan\|tidak tersedia\|belum terdaftar)/i` | V-04 |

> **Peringatan akurasi:** teks pada tabel ini **tidak** bersumber dari desain maupun spec — hanya dari pola penamaan `oms015` (`<Nama Field> harus diisi`). Skenario sebaiknya meng-assert **keberadaan pesan error** (`role=alert` / testid) dan **tertahannya pencarian**, bukan teks persis (**ASM-021**).

---

### UI-T03 — **State loading**

**Konteks:** setelah tombol lacak ditekan, sebelum hasil dirender. Spec **tidak menyebut** state ini sama sekali (**ASM-025**) — diinventarisasi agar test tidak *flaky*, bukan sebagai requirement.

| Elemen | Teks (**usulan**) | Tipe & state | Selector usulan | Fallback | `data-testid` **usulan** |
|---|---|---|---|---|---|
| Indikator loading | `Memuat…` \| spinner tanpa teks | `status` / spinner | `getByRole('status')` | `getByText(/(memuat\|loading\|mohon tunggu)/i)` | `tracking-loading` |
| Skeleton stepper | — | Placeholder | `getByTestId('tracking-stepper-skeleton')` | — | `tracking-stepper-skeleton` |
| Skeleton riwayat | — | Placeholder | `getByTestId('history-list-skeleton')` | — | `history-list-skeleton` |
| Tombol lacak | `Lacak` | Button — **disabled** selama loading | `getByTestId('resi-submit')` → `toBeDisabled()` | — | `resi-submit` |

**Pemakaian pada test:** jangan menjadikan kemunculan loading sebagai assertion wajib (dapat terlewat bila respons cepat). Pakai sebagai **kondisi tunggu**: `await expect(getByTestId('tracking-loading')).toBeHidden()` sebelum meng-assert stepper/riwayat.

---

### UI-T04 — Hasil: **`No. Resi` tidak ditemukan (empty / not found)**

**Konteks:** ALT-02 / V-04. Harus berupa **empty state**, bukan halaman error atau stack trace.

| Elemen | Teks (**usulan**) | Tipe & state | Selector usulan | Fallback | `data-testid` **usulan** |
|---|---|---|---|---|---|
| Container empty state | — | Container | `getByTestId('tracking-not-found')` | — | `tracking-not-found` |
| Ilustrasi | — | `img` (dekoratif) | `getByRole('img')` | — | `tracking-not-found-illustration` |
| Judul pesan | `No. Resi tidak ditemukan` (**ASM-022**) | Heading / teks tebal | `getByRole('heading', { name: /tidak ditemukan/i })` | `getByText(/(tidak ditemukan\|tidak tersedia\|belum terdaftar)/i)` | `tracking-not-found-title` |
| Deskripsi | mis. `Periksa kembali No. Resi Anda` | Teks | — | `getByText(/periksa kembali/i)` | `tracking-not-found-desc` |
| Input `No. Resi` | nilai yang dicari tetap ada | `textbox` — terisi | `getByTestId('resi-input')` | — | `resi-input` |

**Assertion inti (lebih tahan perubahan teks):**

| Yang di-assert | Bentuk usulan | Alasan |
|---|---|---|
| Empty state muncul | `expect(getByTestId('tracking-not-found')).toBeVisible()` **atau** `expect(getByText(/tidak ditemukan/i)).toBeVisible()` | teks persis tidak diketahui |
| Stepper **tidak** dirender | `expect(getByTestId('tracking-stepper')).toHaveCount(0)` | V-04 |
| Riwayat **tidak** dirender | `expect(getByTestId('history-list')).toHaveCount(0)` | V-04 |
| **Bukan** halaman error | `expect(getByText(/(error 500\|stack trace\|terjadi kesalahan sistem)/i)).toHaveCount(0)` | V-04 |
| Tidak redirect ke login | `expect(page).not.toHaveURL(/login/i)` | AC-003.1 |

---

### UI-T05 — Hasil tracking: **ringkasan pengiriman (read-only)**

**Konteks:** resi valid ditemukan. Spec **tidak merinci** field apa saja yang tampil pada ringkasan — daftar di bawah adalah **kandidat** hasil inferensi dari `oms015` (**ASM-028**) dan **tidak boleh** dijadikan assertion wajib satu per satu.

| Elemen | Teks / label (**usulan**) | Tipe & state | Selector usulan | Fallback | `data-testid` **usulan** |
|---|---|---|---|---|---|
| Container hasil | — | Container | `getByTestId('tracking-result')` | — | `tracking-result` |
| Container ringkasan | — | Section | `getByRole('region', { name: /(ringkasan\|informasi pengiriman)/i })` | `getByTestId('tracking-summary')` | `tracking-summary` |
| Judul section | `Informasi Pengiriman` \| `Detail Pengiriman` | Heading | `getByRole('heading', { name: /(informasi\|detail)\s+pengiriman/i })` | — | `tracking-summary-title` |
| `No. Resi` (echo) | `No. Resi : LKL2567828992` | Teks read-only | — | `getByText(/LKL\d+/)` | `summary-no-resi` |
| `ID Order` *(kandidat)* | `ID Order : ORD-20260607009` | Teks read-only | — | `getByText(/^ID Order/i)` | `summary-id-order` |
| Badge jenis order *(kandidat)* | `LTL` / `LCL` | Badge | — | `getByText(/^(LTL\|LCL)$/)` | `summary-order-type-badge` |
| `Pengirim` *(kandidat)* | nama pengirim | Teks read-only | — | `getByText(/^Pengirim/i)` | `summary-pengirim` |
| `Penerima` *(kandidat)* | nama penerima | Teks read-only | — | `getByText(/^Penerima/i)` | `summary-penerima` |
| Alamat asal / tujuan *(kandidat)* | kota / drop point | Teks read-only | — | — | `summary-alamat-asal` / `summary-alamat-tujuan` |
| Status ringkas *(kandidat)* | tahap terkini | Badge | — | `/(pick ?up\|on delivery\|delivered)/i` | `summary-current-stage` |

**Assertion yang disarankan (tahan perubahan):**

1. `expect(getByTestId('tracking-result')).toBeVisible()` — hasil dirender.
2. `expect(getByText(new RegExp(noResi, 'i'))).toBeVisible()` — resi yang dicari benar-benar tampil (AC-003.2).
3. **Read-only** (REQ-004 / AC-004.2): `expect(getByTestId('tracking-result').getByRole('textbox')).toHaveCount(0)` dan `…getByRole('combobox')).toHaveCount(0)` — di luar `resi-input` yang berada di luar container hasil.

---

### UI-T06 — **Stepper 3 tahap** *(pembeda inti modul)*

**Konteks:** komponen paling kritikal pada modul ini (REQ-008…REQ-020). Karena tidak ada desain, **cara state simpul diekspos ke DOM tidak diketahui** — ini risiko blocking terbesar untuk otomasi (**ASM-023**).

**Struktur & selector usulan**

| Elemen | Teks / label (**usulan**) | Tipe & state | Selector usulan (prioritas 1) | Fallback | `data-testid` **usulan** |
|---|---|---|---|---|---|
| Container stepper | — | `list` / container | `getByRole('list', { name: /(progres\|tracking\|pengiriman)/i })` | `getByTestId('tracking-stepper')` | **`tracking-stepper`** |
| Simpul 1 | `Pick Up` (spec juga menulis `Pick up` — **ASM-010**) | `listitem` — `reached` \| `pending` | `getByTestId('tracking-stepper').getByRole('listitem').filter({ hasText: /pick ?up/i })` | `getByText(/pick ?up/i)` | **`tracking-step-pickup`** |
| Simpul 2 | `On Delivery` | `listitem` — `reached` \| `pending` | idem, `filter({ hasText: /on ?delivery/i })` | `getByText(/on ?delivery/i)` | **`tracking-step-on-delivery`** |
| Simpul 3 | `Delivered` | `listitem` — `reached` \| `pending` | idem, `filter({ hasText: /delivered/i })` | `getByText(/delivered/i)` | **`tracking-step-delivered`** |
| Label simpul | teks tahap | Teks | `step.getByTestId('tracking-step-label')` | — | `tracking-step-label` |
| Ikon/indikator simpul | ✓ (tercapai) / lingkaran kosong | Ikon | — | — | `tracking-step-icon` |
| Konektor antar simpul | garis progres | Dekorasi | — | — | `tracking-step-connector` |

**Kontrak state yang diminta ke tim FE (ASM-023)**

| Atribut usulan | Nilai | Makna | Assertion usulan |
|---|---|---|---|
| `data-state` | `reached` | tahap **tercapai** | `expect(getByTestId('tracking-step-pickup')).toHaveAttribute('data-state', 'reached')` |
| `data-state` | `pending` | tahap **belum tercapai** | `…toHaveAttribute('data-state', 'pending')` |
| `aria-current` | `step` | tahap terkini (opsional) | `…toHaveAttribute('aria-current', 'step')` |

> Bila atribut di atas **tidak** tersedia di implementasi, fallback yang dapat dipakai (berurutan): (a) `class` yang mengandung `active`/`done`/`completed` → `toHaveClass(/(done|completed|active)/)`; (b) keberadaan ikon centang di dalam simpul; (c) *screenshot comparison* (**tidak disarankan** — rapuh dan tidak menjelaskan kegagalan). **Ini harus dikonfirmasi sebelum menulis test.**

**Matriks state stepper per kondisi progres** *(turunan Flow P0–P5 + matriks R3)*

| Kondisi | `tracking-step-pickup` | `tracking-step-on-delivery` | `tracking-step-delivered` | Nama state | REQ / AC |
|---|---|---|---|---|---|
| P0 — belum ada event | `pending` | `pending` | `pending` | **empty / belum mulai** | REQ-016, AC-016.1–016.3 |
| P1 — muat pertama (dari ≥2 alamat muat) | `reached` | `pending` | `pending` | **partial progress** | REQ-009, AC-009.1 |
| P2 — muat tengah (multi pick up 3) | `reached` | `pending` | `pending` | **partial (no-op)** — identik P1 | REQ-013, AC-013.1 |
| P3 — muat terakhir | `reached` | `reached` | `pending` | **partial progress** | REQ-010, AC-010.1 |
| P1+P3 melebur — 1 alamat muat (*collapse*) | `reached` | `reached` | `pending` | **partial (collapse, +2 tahap)** | REQ-012, AC-012.1–012.4 |
| P4 — bongkar bukan terakhir | `reached` | `reached` | `pending` | **partial (no-op)** — identik P3 | REQ-014, AC-014.1–014.2 |
| P5 — bongkar terakhir | `reached` | `reached` | `reached` | **complete / penuh** | REQ-011, AC-011.1–011.2 |

**Assertion pendukung**

| Tujuan | Bentuk usulan | Sumber |
|---|---|---|
| Ketiga label ada & berurutan | assert keberadaan ketiga testid, **bukan** `toHaveCount(3)` pada seluruh simpul | V-05 + **ASM-009** (boleh ada tahap pendahulu) |
| Urutan visual benar | bandingkan `boundingBox().x` (horizontal) atau `.y` (vertikal) antar simpul | AC-008.1 |
| Monotonisitas | snapshot state sebelum & sesudah event, assert tidak ada `reached` → `pending` | REQ-015, V-10 |
| Persistensi setelah reload | `page.reload()` lalu ulangi assertion state | AC-015.4, **ASM-014** |
| Label tidak berubah antar tipe pengiriman | jalankan assertion label yang sama pada seluruh tipe | AC-008.3 |

---

### UI-T07 — **`Riwayat Pengiriman`** — daftar entri (terisi)

**Konteks:** REQ-021…REQ-026. Struktur DOM tidak diketahui (list vs timeline vs tabel) — diasumsikan **list** (**ASM-024**).

| Elemen | Teks / label (**usulan**) | Tipe & state | Selector usulan (prioritas 1) | Fallback | `data-testid` **usulan** |
|---|---|---|---|---|---|
| Judul section | `Riwayat Pengiriman` *(teks dari spec L7)* | Heading | `getByRole('heading', { name: /riwayat pengiriman/i })` | `getByText(/riwayat pengiriman/i)` | `history-title` |
| Container daftar | — | `list` | `getByRole('list', { name: /riwayat pengiriman/i })` | `getByTestId('history-list')` | **`history-list`** |
| Entri riwayat (generik) | — | `listitem` | `getByTestId('history-list').getByRole('listitem')` | `getByTestId('history-item')` | **`history-item`** |
| Keterangan entri | lihat tabel jenis entri di bawah | Teks | `item.getByTestId('history-item-text')` | `item.getByText(/…/i)` | `history-item-text` |
| Penanda waktu entri | mis. `07/06/2026 14:30` | Teks | `item.getByTestId('history-item-timestamp')` | `item.getByText(/\d{2}\/\d{2}\/\d{4}/)` | `history-item-timestamp` |
| Lokasi/alamat entri *(opsional)* | nama drop point / alamat | Teks — **muncul bila tersedia** (REQ-026, **ASM-029**) | `item.getByTestId('history-item-location')` | — | `history-item-location` |
| Marker/ikon timeline | titik + garis | Dekorasi | — | — | `history-item-marker` |

**Jenis entri & matcher yang disarankan**

| Jenis entri | Sumber | Teks (**dari spec**) | Matcher usulan | Atribut penanda usulan | Kardinalitas |
|---|---|---|---|---|---|
| Entri **muat** | event `Selesai Muat` | `barang telah dimuat` | `/barang telah dimuat/i` | `data-history-type="muat"` | = jumlah alamat pick up (V-07) |
| Entri **sintetis** | di-*inject* sistem | `armada dalam perjalanan menuju lokasi bongkar` (kanonik) / `berangkat ke lokasi bongkar` (varian) | `/(berangkat ke lokasi bongkar\|dalam perjalanan menuju lokasi bongkar)/i` (**ASM-003**) | `data-history-type="sintetis"` | **tepat 1** (V-08) |
| Entri **bongkar** | event `Selesai Bongkar` | **tidak disebut spec** (**ASM-004**) — kandidat `barang telah dibongkar` | `/(dibongkar\|bongkar\|selesai bongkar)/i` — **jangan** assert teks persis | `data-history-type="bongkar"` | = jumlah alamat drop off (V-09) |

**Selector siap pakai (usulan)**

| Kebutuhan | Bentuk usulan |
|---|---|
| Semua entri | `const items = page.getByTestId('history-list').getByRole('listitem')` |
| Hitung entri muat | `items.filter({ hasText: /barang telah dimuat/i })` → `toHaveCount(N)` |
| Entri sintetis tepat 1 | `items.filter({ hasText: /(berangkat ke lokasi bongkar\|dalam perjalanan menuju lokasi bongkar)/i })` → `toHaveCount(1)` |
| Hitung entri bongkar | filter via atribut `[data-history-type="bongkar"]` (lebih aman daripada matcher teks — lihat peringatan di bawah) |
| Urutan relatif (sintetis setelah muat terakhir) | ambil `allTextContents()` lalu bandingkan **indeks** entri sintetis > indeks entri muat terakhir dan < indeks entri bongkar pertama (**ASM-007**) |

> **Peringatan matcher:** teks entri sintetis mengandung kata `bongkar`, sehingga filter `/bongkar/i` akan **ikut menangkap entri sintetis**. Untuk V-09, gunakan atribut `data-history-type` (usulan) atau matcher negatif: `.filter({ hasText: /bongkar/i }).filter({ hasNotText: /perjalanan menuju|berangkat ke/i })`.

**Contoh state — Multi Pick Up 3 setelah muat tuntas** *(mengikuti contoh spec L8–L11)*

| Indeks | `data-history-type` | Keterangan | Timestamp |
|---|---|---|---|
| 0 | `muat` | `barang telah dimuat` | ada |
| 1 | `muat` | `barang telah dimuat` | ada |
| 2 | `muat` | `barang telah dimuat` | ada |
| 3 | `sintetis` | `armada dalam perjalanan menuju lokasi bongkar` | ada (**ASM-008**) |

Arah render diasumsikan **terlama di atas** (**ASM-007**) — assertion **wajib** memakai perbandingan posisi relatif, bukan indeks absolut, agar tetap lulus bila UI membalik urutan.

---

### UI-T08 — `Riwayat Pengiriman` — **empty state** (resi valid, belum ada event)

**Konteks:** ALT-03 / AC-021.4 / REQ-016. Halaman tetap tampil; stepper dirender penuh dengan seluruh simpul `pending`; riwayat kosong — **bukan error**.

| Elemen | Teks (**usulan**) | Tipe & state | Selector usulan | Fallback | `data-testid` **usulan** |
|---|---|---|---|---|---|
| Container empty riwayat | — | Container | `getByTestId('history-empty')` | — | `history-empty` |
| Pesan empty | `Belum ada riwayat pengiriman` | Teks | — | `getByText(/(belum ada\|tidak ada).*(riwayat\|progres)/i)` | `history-empty-text` |
| Section riwayat | `Riwayat Pengiriman` | Heading — **tetap dirender** | `getByRole('heading', { name: /riwayat pengiriman/i })` | — | `history-title` |
| Stepper | — | **tetap dirender**, seluruh simpul `pending` | `getByTestId('tracking-stepper')` → `toBeVisible()` | — | `tracking-stepper` |

**Assertion inti:** (1) `history-list` kosong (`getByRole('listitem')` → `toHaveCount(0)`) **atau** `history-empty` terlihat; (2) `tracking-stepper` **tetap** terlihat (AC-016.3); (3) tidak ada teks error.

---

### UI-T09 — **State error sistem / gangguan jaringan**

**Konteks:** dibedakan dari UI-T04 (*not found* = kondisi normal). Tidak diatur spec — diinventarisasi agar test dapat membedakan kegagalan infrastruktur dari empty state yang benar (**ASM-022**).

| Elemen | Teks (**usulan**) | Tipe & state | Selector usulan | Fallback | `data-testid` **usulan** |
|---|---|---|---|---|---|
| Container error | — | Container | `getByRole('alert')` | `getByTestId('tracking-error')` | `tracking-error` |
| Pesan error | `Terjadi kesalahan. Coba lagi.` | Teks | — | `getByText(/(terjadi kesalahan\|gagal memuat\|coba lagi)/i)` | `tracking-error-text` |
| Tombol coba lagi | `Coba Lagi` | Button | `getByRole('button', { name: /coba lagi/i })` | — | `tracking-error-retry` |

**Pemakaian:** dipakai sebagai **assertion negatif** pada skenario happy path & not-found — `expect(getByTestId('tracking-error')).toHaveCount(0)` (V-04: not found **bukan** error).

---

### UI-T10 — Elemen yang **HARUS ABSEN** (assertion negatif lintas layar)

| # | Elemen | Alasan | Assertion usulan | REQ / AC |
|---|---|---|---|---|
| 1 | Tombol mutasi data (`Edit`, `Batalkan`, `Simpan`, ubah status) | Halaman read-only | `getByRole('button', { name: /(edit\|batalkan\|simpan\|ubah status)/i })` → `toHaveCount(0)` | REQ-004, AC-004.1 |
| 2 | Input aktif di area hasil | Read-only | `getByTestId('tracking-result').getByRole('textbox')` → `toHaveCount(0)` | AC-004.2 |
| 3 | Redirect / form login | Halaman publik | `expect(page).not.toHaveURL(/login/i)`; `getByRole('textbox', { name: /(email\|password\|kata sandi)/i })` → `toHaveCount(0)` | REQ-003, AC-003.1, V-13 |
| 4 | Status antara TMS: `Menuju Lokasi Muat`, `Tiba di Lokasi Muat`, `Tiba di Lokasi Bongkar`, `Dalam Perjalanan` | OMS hanya 2 event | `getByText(/(menuju lokasi muat\|tiba di lokasi)/i)` → `toHaveCount(0)` | REQ-002, AC-002.2, REQ-005, V-06 |
| 5 | Simpul stepper ke-4 bertema status antara | Stepper tetap 3 tahap | tidak di-assert jumlah total (**ASM-009**); assert **ketiadaan label** status antara pada `tracking-stepper` | AC-002.3, V-05 |
| 6 | Entri sintetis **duplikat** | Tepat satu kali | `toHaveCount(1)`, bukan `toBeVisible()` | REQ-024, V-08 |
| 7 | Shell aplikasi terautentikasi (sidebar `Order`, badge `Staff Operasional`, profil, `Kuota Order`) | Halaman publik (**ASM-026**) | `getByText(/staff operasional\|kuota order/i)` → `toHaveCount(0)` — **prioritas rendah**, non-blocking | REQ-003 |
| 8 | Data pengiriman milik resi lain | Isolasi akses | resi A tidak menampilkan konten resi B | AC-004.3, V-13 |

---

### Katalog `data-testid` **usulan** (permintaan kontrak ke tim FE — ASM-030)

| `data-testid` | Elemen | Layar | Prioritas |
|---|---|---|---|
| `public-tracking-page` | Root halaman publik | UI-T00 | sedang |
| `resi-search-form` | Form pencarian | UI-T01 | sedang |
| **`resi-input`** | Input `No. Resi` | UI-T01, UI-T02, UI-T04 | **tinggi** |
| **`resi-submit`** | Tombol lacak/cari | UI-T01, UI-T03 | **tinggi** |
| `resi-input-error` | Pesan validasi input | UI-T02 | tinggi |
| `tracking-loading` | Indikator loading | UI-T03 | sedang |
| `tracking-result` | Container hasil | UI-T05 | tinggi |
| `tracking-summary` | Ringkasan pengiriman | UI-T05 | sedang |
| `tracking-not-found` | Empty state resi tidak ditemukan | UI-T04 | **tinggi** |
| `tracking-error` | Error sistem | UI-T09 | sedang |
| **`tracking-stepper`** | Container stepper | UI-T06 | **tinggi** |
| **`tracking-step-pickup`** | Simpul `Pick Up` | UI-T06 | **tinggi** |
| **`tracking-step-on-delivery`** | Simpul `On Delivery` | UI-T06 | **tinggi** |
| **`tracking-step-delivered`** | Simpul `Delivered` | UI-T06 | **tinggi** |
| `tracking-step-label` | Label di dalam simpul | UI-T06 | rendah |
| **`history-list`** | Container `Riwayat Pengiriman` | UI-T07 | **tinggi** |
| **`history-item`** | Satu entri riwayat | UI-T07 | **tinggi** |
| `history-item-text` | Keterangan entri | UI-T07 | tinggi |
| `history-item-timestamp` | Penanda waktu entri | UI-T07 | sedang |
| `history-item-location` | Lokasi/alamat entri (opsional) | UI-T07 | rendah |
| `history-empty` | Empty state riwayat | UI-T08 | tinggi |
| `history-title` | Judul section riwayat | UI-T07, UI-T08 | rendah |

**Atribut data tambahan yang diminta** (bukan testid, tapi krusial untuk assertion):

| Atribut | Elemen | Nilai | Dipakai untuk |
|---|---|---|---|
| `data-state` | `tracking-step-*` | `reached` \| `pending` | seluruh matriks R3 (**ASM-023**) |
| `data-history-type` | `history-item` | `muat` \| `sintetis` \| `bongkar` | V-07, V-08, V-09 tanpa bergantung teks (**ASM-004**) |

### Traceability: komponen UI → Requirement

| Komponen | REQ yang diverifikasi lewat komponen ini |
|---|---|
| `resi-input` + `resi-submit` | REQ-003, V-01, V-02, V-03, ALT-01 |
| `tracking-not-found` | REQ-003, V-04, ALT-02 |
| `tracking-summary` | REQ-001 (AC-001.1), REQ-004 |
| **`tracking-stepper` + `tracking-step-*`** | **REQ-008…REQ-020**, V-05, V-10, V-11, V-12, REQ-027 |
| **`history-list` + `history-item`** | **REQ-021…REQ-026**, V-07, V-08, V-09, REQ-002 (AC-002.1) |
| Assertion negatif UI-T10 | REQ-002, REQ-004, REQ-005, V-06, V-13 |

---

## Assumptions Log

| ID | Area | Ambiguitas / Konflik pada Spec | Keputusan yang Diambil | Dampak / Risiko |
|---|---|---|---|---|
| **ASM-001** | Aset desain | **Tidak ada file desain UI (PNG)** di `inputs/oms022-public-tracking-improve/designs/` — direktori tersebut tidak tersedia sama sekali. | **UI Inventory akan diturunkan dari spec, bukan dari desain visual.** Seluruh label, struktur, dan selector bersifat hipotesis dan wajib diverifikasi ke implementasi. | **Tinggi.** Tidak ada grounding visual untuk label/layout; assertion teks harus memakai matcher toleran agar tidak rapuh. |
| **ASM-002** | Baseline TMS Shipper | Spec L1 hanya menyatakan "Sama seperti public tracking TMS Shipper" **tanpa melampirkan** spesifikasi TMS tersebut. Tidak ada file baseline di `inputs/`. | Elemen baseline (form pencarian No. Resi, validasi wajib, empty state, ringkasan pengiriman) **diinferensikan** sebagai perilaku standar public tracking dan dicatat sebagai V-01…V-04 serta REQ-003/REQ-004. Fokus pengujian tetap pada **delta OMS** (R2–R6). | **Tinggi.** Requirement baseline (REQ-003, REQ-004, V-01…V-04) tidak dapat diverifikasi ke sumber. Wajib dikonfirmasi ke PO atau dilengkapi dengan spec TMS Shipper. |
| **ASM-003** | Teks entri sintetis | **Konflik internal spec:** L7 menyebut keterangan **`"berangkat ke lokasi bongkar"`**, sedangkan contoh konkret pada L11 menuliskan **`"armada dalam perjalanan menuju lokasi bongkar"`**. | Teks pada **L11 dijadikan kanonik** karena merupakan contoh konkret rendering. Assertion memakai matcher gabungan case-insensitive: `/(berangkat ke lokasi bongkar\|dalam perjalanan menuju lokasi bongkar)/i`. | **Sedang–Tinggi.** Salah pilih teks persis akan menggagalkan seluruh skenario R5. Wajib dikonfirmasi ke PO agar satu penamaan dipakai konsisten. |
| **ASM-004** | Keterangan entri bongkar | Spec **sama sekali tidak menyebut** teks keterangan untuk entri `Selesai Bongkar` — contoh L8–L11 berhenti pada fase muat. | Diasumsikan setiap `Selesai Bongkar` menghasilkan **satu entri riwayat** (REQ-025) dengan keterangan bertema bongkar (mis. `barang telah dibongkar`), dan bongkar terakhir dapat disertai keterangan penyelesaian. **Assertion menguji jumlah entri dan konsistensi stepper**, bukan teks persis. | **Sedang.** Skenario R5 untuk fase bongkar tidak dapat meng-assert teks; wajib dikonfirmasi. |
| **ASM-005** | Kelengkapan contoh per tipe | Contoh L4 (Normal) dan L5 (Multi Pick Up 2) **hanya merinci fase muat** dan tidak menyebut transisi ke `Delivered`; hanya L6 (Multi Drop) yang lengkap sampai `Delivered`. | Diperlakukan sebagai **contoh yang disingkat**, bukan pengecualian rule. **Aturan umum L3 berlaku penuh**: bongkar terakhir selalu memicu `Delivered` untuk seluruh tipe pengiriman (AC-017.3, AC-018.3). | **Sedang.** Bila ternyata Normal/Multi Pick Up punya perlakuan berbeda, REQ-017/REQ-018 perlu revisi — namun tafsir ini jauh lebih konsisten dengan L3. |
| **ASM-006** | Tipe **Multipoint** | Spec hanya mencontohkan tiga tipe: Normal (L4), Multi Pick Up 2 (L5), Multi Drop 2 (L6). **Multipoint** (multi pick up **dan** multi drop bersamaan) tidak disebut sama sekali. | Diasumsikan multipoint **mengikuti aturan umum L3 tanpa pengecualian** (REQ-020), yaitu kombinasi perilaku L5 pada fase muat + L6 pada fase bongkar. | **Sedang.** Merupakan kombinasi paling kompleks dan paling rawan bug (dua *no-op* dalam satu pengiriman); wajib dikonfirmasi apakah tipe ini memang didukung OMS. |
| **ASM-007** | Arah kronologi Riwayat | Contoh L8–L11 tersusun dari muat pertama ke entri terakhir (**ascending/terlama di atas**), namun spec tidak menyatakan arah render pada UI. | Diasumsikan urutan **mengikuti contoh spec (terlama di atas)**. Assertion memakai pemeriksaan **urutan relatif** antar entri, bukan indeks absolut, agar tetap lulus bila UI membalik urutan. | Rendah–Sedang. Assertion berbasis indeks absolut akan rapuh — hindari. |
| **ASM-008** | Timestamp entri sintetis | Spec tidak menyebut penanda waktu untuk entri `armada dalam perjalanan menuju lokasi bongkar`. | Diasumsikan entri sintetis memakai **waktu yang sama atau sesaat setelah** event `Selesai Muat` terakhir, sehingga posisinya konsisten pada urutan kronologis. | Rendah. |
| **ASM-009** | Jumlah tahap stepper | Spec hanya menyebut tiga tahap (`Pick Up`, `On Delivery`, `Delivered`). Tidak diketahui apakah terdapat tahap pendahulu (mis. `Order Dibuat` / `Ditugaskan`) seperti lazimnya public tracking. | Diasumsikan **minimal tiga tahap tersebut wajib ada**; keberadaan tahap pendahulu **tidak di-assert** (tidak positif, tidak negatif). Assertion memakai `V-05` yang toleran terhadap tahap tambahan. | **Sedang.** Assertion "tepat 3 simpul" akan rapuh — gunakan assertion keberadaan ketiga label, bukan jumlah total simpul. |
| **ASM-010** | Kapitalisasi & label tahap | Spec menulis label secara tidak konsisten: `Pick Up` (L4, L6) vs `Pick up` (L5); `Selesai Muat` vs `selesai muat`; `Selesai bongkar` vs `Selesai Bongkar`. Label UI sesungguhnya tidak diketahui (tanpa desain). | Seluruh assertion teks memakai **partial match case-insensitive**. Label kanonik untuk dokumentasi ditetapkan: `Pick Up`, `On Delivery`, `Delivered`, `Selesai Muat`, `Selesai Bongkar`. | **Sedang.** Tanpa aset desain, ini satu-satunya cara menjaga skenario tidak rapuh. |
| **ASM-011** | Pemicu event | Spec tidak menyebut **siapa** dan **melalui kanal apa** event `Selesai Muat`/`Selesai Bongkar` dilaporkan. | Diasumsikan dilaporkan oleh **driver/armada melalui aplikasi vendor OMS**, dan public tracking hanya **mengonsumsi** event tersebut. Skenario public tracking menyiapkan state event via *seed data*/API, bukan via UI driver. | **Sedang.** Menentukan strategi *setup* test — bila event hanya dapat dibuat lewat UI driver, skenario butuh langkah lintas-aplikasi. |
| **ASM-012** | Order dibatalkan | Spec tidak mengatur tampilan tracking untuk order berstatus `Dibatalkan` (lihat `oms015` REQ-045). | Diasumsikan **di luar cakupan modul ini**. Dicatat sebagai ALT-09 agar tidak dijadikan assertion wajib dan tidak dianggap bug bila perilakunya berbeda. | Rendah–Sedang. |
| **ASM-013** | Relasi No. Resi ↔ pengiriman | Menurut `oms015` (REQ-053), **No. Resi melekat pada barang**, sehingga satu order dapat memiliki beberapa resi. Spec modul ini hanya bicara di level pengiriman/armada. | Diasumsikan seluruh resi dalam satu order menampilkan **progres pengiriman yang sama** (stepper & riwayat identik), karena event berasal dari armada, bukan dari barang. | **Sedang.** Bila tracking ternyata per-barang (mis. barang di drop off berbeda punya progres berbeda), REQ-019/REQ-027 perlu diperluas. Wajib dikonfirmasi ke PO. |
| **ASM-014** | Pembaruan real-time | Spec tidak menyebut apakah halaman memperbarui progres secara otomatis (polling/websocket) atau butuh reload manual. | Diasumsikan **butuh reload/pencarian ulang**. Skenario melakukan reload eksplisit sebelum meng-assert perubahan tahap (AC-015.4). | Rendah–Sedang. Bila ternyata real-time, skenario tetap lulus; sebaliknya skenario tanpa reload akan gagal palsu. |
| **ASM-015** | Kardinalitas event per alamat | Spec tidak menyatakan apakah satu alamat dapat menghasilkan lebih dari satu event (mis. muat parsial/ulang). | Diasumsikan **tepat satu event per alamat** (AC-006.5), sehingga posisi "pertama"/"terakhir" dapat ditentukan secara deterministik. | **Sedang.** Bila event dapat berulang per alamat, definisi "muat terakhir" menjadi ambigu dan seluruh matriks R3 perlu ditinjau ulang. |
| **ASM-016** | Aset desain — verifikasi ulang *(menyempurnakan ASM-001)* | ASM-001 mencatat direktori `designs/` "tidak tersedia". Verifikasi ulang pada tahap design-analyzer menemukan direktori **ada namun kosong** (**0 file PNG**). | Perlakuan tidak berubah: **mode tanpa-desain**. Section `UI Inventory` diisi penuh dari `Requirements` + `Aturan Validasi` + `User Flow`, dan **seluruh isinya ditandai eksplisit sebagai USULAN**. Tidak ada satu pun elemen yang berstatus "terverifikasi". | **Tinggi.** Setiap label, teks, struktur DOM, dan selector berpeluang meleset. Skenario tahap berikutnya harus memprioritaskan assertion **struktural/kardinalitas** di atas assertion **teks persis**. |
| **ASM-017** | Konvensi selector & `data-testid` | Spec tidak menetapkan standar selector maupun konvensi `data-testid`. | Mengadopsi konvensi UI Inventory modul **`oms015-order-ltl-lcl-universal`** (`output/oms015-order-ltl-lcl-universal/oms015-order-ltl-lcl-universal.analysis.md`): prioritas `getByRole` + accessible name → `getByTestId` → `getByLabel` → text parsial CI; `data-testid` **kebab-case** berpola `<domain>-<elemen>[-<varian>]`. | Rendah. Konsistensi lintas modul memudahkan reuse page object. |
| **ASM-018** | Arsitektur halaman (satu vs dua halaman) | Spec tidak menyatakan apakah form pencarian dan hasil tracking berada pada **satu halaman** (hasil dirender di bawah form) atau **dua route terpisah** (`/tracking` → `/tracking/<resi>`). | Diasumsikan **satu halaman**: form tetap tampil setelah pencarian, hasil dirender di bawahnya. Selector **tidak boleh** bergantung pada perubahan URL/route; navigasi diverifikasi lewat kemunculan `tracking-result`. | **Sedang.** Bila ternyata dua route, langkah `waitForURL` perlu ditambahkan; assertion elemen tetap valid. |
| **ASM-019** | Label & placeholder input `No. Resi` | Label/placeholder sesungguhnya tidak diketahui (tanpa desain). | Ditetapkan usulan: label `No. Resi`, placeholder `Masukkan No. Resi` (mengikuti pola `oms015`: `Masukkan <Field>` untuk textbox). Selector berlapis: `getByRole('textbox', { name: /no\.?\s*resi/i })` → `getByLabel(/no\.?\s*resi/i)` → `getByPlaceholder(/resi/i)` → `getByTestId('resi-input')`. | **Sedang.** Bila field tidak punya `<label>` terasosiasi, hanya testid/placeholder yang bekerja. |
| **ASM-020** | Label tombol lacak | Tidak diketahui apakah tombol bernama `Lacak`, `Cari`, `Lacak Pengiriman`, atau `Track`. | Assertion memakai matcher gabungan case-insensitive `/(lacak\|cari\|track)/i`, dengan `data-testid="resi-submit"` sebagai jangkar utama. | **Sedang.** Matcher gabungan berisiko menangkap tombol lain bila halaman punya beberapa aksi bertema pencarian — lakukan *scoping* ke `resi-search-form`. |
| **ASM-021** | Pola teks pesan validasi | Spec tidak memuat satu pun teks pesan validasi. | Mengadopsi pola `oms015` (`<Nama Field> harus diisi`) sebagai **usulan** → `No. Resi harus diisi`. Assertion memakai matcher longgar `/(harus diisi\|wajib diisi\|tidak boleh kosong)/i`, dan **assertion utama** adalah *pencarian tertahan* + kemunculan elemen `role=alert`/`resi-input-error`, bukan teks persis. | **Sedang.** Assertion teks persis akan gagal bila copywriting berbeda; assertion struktural lebih tahan. |
| **ASM-022** | Teks empty state *not found* & pembedaan dari error | Spec (V-04) hanya menyatakan "menampilkan empty state / pesan tidak ditemukan, bukan halaman error" tanpa teks. | Matcher usulan `/(tidak ditemukan\|tidak tersedia\|belum terdaftar\|not found)/i`. **State error sistem dipisahkan** menjadi UI-T09 agar skenario dapat membedakan *not found* (perilaku benar) dari kegagalan infrastruktur (bug). | **Sedang.** Tanpa pembedaan ini, test berisiko meloloskan halaman error 500 sebagai "empty state". |
| **ASM-023** | Penanda state simpul stepper di DOM | Spec hanya menyebut tahap "tercapai" tanpa menjelaskan bagaimana state itu direpresentasikan (kelas CSS, atribut, ikon, warna). **Tanpa desain, tidak ada petunjuk visual sama sekali.** | Diusulkan kontrak `data-state="reached\|pending"` (opsional `aria-current="step"`) pada tiap `tracking-step-*`. Fallback berurutan: `toHaveClass(/(done\|completed\|active)/)` → keberadaan ikon centang. Perbandingan screenshot **tidak** dipakai. | **TINGGI — potensi blocking.** Ini prasyarat teknis untuk **seluruh** skenario R3/R4 (inti modul). Wajib disepakati dengan tim FE sebelum test ditulis; bila state hanya dibedakan lewat warna, otomasi menjadi sangat rapuh. |
| **ASM-024** | Struktur DOM `Riwayat Pengiriman` | Tidak diketahui apakah riwayat dirender sebagai `<ul>/<li>`, timeline `<div>`, atau `<table>`. | Diasumsikan **list** (`role=list` / `role=listitem`) dengan container `data-testid="history-list"` dan item `data-testid="history-item"`. Diusulkan pula atribut `data-history-type="muat\|sintetis\|bongkar"` agar kardinalitas (V-07…V-09) dapat di-assert tanpa bergantung teks. | **Sedang.** Bila berupa tabel, selector `getByRole('listitem')` gagal total — testid container/item menjadi penyelamat. |
| **ASM-025** | State loading | Spec tidak menyebut adanya indikator loading saat pencarian berjalan. | Diasumsikan ada (spinner/skeleton) dengan `role=status` dan `data-testid="tracking-loading"`. Assertion loading bersifat **opsional & non-blocking**; dipakai sebagai kondisi tunggu, bukan sebagai kriteria lulus. | Rendah. Meng-assert kemunculan loading secara wajib akan *flaky* bila respons cepat. |
| **ASM-026** | Kerangka halaman publik | Tidak diketahui apakah halaman public tracking memakai shell aplikasi OMS (sidebar, badge peran `Staff Operasional`, profil, `Kuota Order`) seperti pada `oms015`, atau shell publik minimal. | Diasumsikan **shell publik minimal tanpa elemen terautentikasi**. Assertion negatif terhadap elemen shell terautentikasi dicatat pada UI-T10 #7 dengan **prioritas rendah / non-blocking**. | **Sedang.** Bila halaman ternyata memakai shell yang sama, assertion negatif tersebut menghasilkan *false failure* — karenanya sengaja tidak dijadikan blocking. |
| **ASM-027** | Deep link / query parameter resi | Tidak diketahui apakah halaman mendukung akses langsung berpola `?resi=<no>` atau `/tracking/<no>`. | **Tidak di-assert.** Seluruh skenario menyiapkan state lewat UI (isi `resi-input` → klik `resi-submit`) agar tidak bergantung pada kontrak URL yang belum pasti. | Rendah. Bila deep link tersedia, setup test dapat dipercepat pada iterasi berikutnya. |
| **ASM-028** | Isi ringkasan pengiriman | Spec **tidak merinci** field apa saja yang tampil pada ringkasan pengiriman (AC-001.1 hanya menyebut "ringkasan pengiriman"). | Field pada UI-T05 (`ID Order`, badge `LTL`/`LCL`, `Pengirim`, `Penerima`, alamat, status ringkas) diperlakukan sebagai **kandidat hasil inferensi dari `oms015`**, **bukan** requirement. Assertion dibatasi pada: container ringkasan terlihat + No. Resi yang dicari tampil + tidak ada input aktif. | **Sedang.** Meng-assert field kandidat satu per satu akan menghasilkan kegagalan palsu; wajib dikonfirmasi ke PO bila cakupan ringkasan ingin diuji. |
| **ASM-029** | Kelengkapan atribut entri riwayat | REQ-026 menyebut lokasi/alamat ditampilkan "bila tersedia" — kondisi ketersediaannya tidak didefinisikan. | `history-item-location` diperlakukan **opsional**: tidak di-assert wajib ada, dan tidak di-assert wajib absen. Assertion wajib terbatas pada keterangan (`history-item-text`) dan penanda waktu (`history-item-timestamp`). | Rendah–Sedang. |
| **ASM-030** | Ketersediaan `data-testid` di implementasi | Seluruh `data-testid` pada UI Inventory ini **belum tentu ada** di kode — tidak ada implementasi maupun desain yang dapat diperiksa. | Katalog testid diperlakukan sebagai **permintaan kontrak test kepada tim FE**. Skenario tahap berikutnya menuliskan selector primer berbasis `role`/`label`/teks agar tetap dapat dijalankan tanpa testid, dengan testid sebagai jalur yang disarankan. | **Tinggi.** Bila testid tidak pernah ditambahkan, elemen tanpa role bermakna (simpul stepper, item riwayat) hanya dapat dijangkau lewat teks — rapuh terhadap perubahan copywriting (bandingkan ASM-010). |
| **ASM-031** | Whitespace pada sel Examples Gherkin (uji trim V-02) | Gherkin memangkas whitespace di sel Examples sehingga input spasi/tab literal tidak bisa ditulis langsung. | Dipakai token `{sp}`/`{tab}`/`{nl}`/`{zwsp}` yang diekspansi oleh step definition; peta token ada di `testData.tokenMap` pada JSON. | Rendah. *(dicatat orkestrator dari laporan scenario-generator)* |
| **ASM-032** | Event duplikat per alamat (NEG-024) | Perilaku sistem terhadap event `Selesai Muat`/`Selesai Bongkar` ganda pada alamat yang sama tidak didefinisikan spec. | Diasumsikan sistem melakukan dedup/upsert; assertion memakai `count<=N`, bukan `count=N`, agar tidak memaksa perilaku yang belum dikonfirmasi. | Sedang. *(scenario-generator)* |
| **ASM-033** | Batas jumlah alamat untuk seed volume besar | Spec tidak menyebut batas maksimum alamat pick up/drop. | Seed Multi Pick Up 20/100, Multi Drop 20, Multipoint 3x3/10x10/50x50 diasumsikan didukung. Bila ada batas, STR-004…STR-007 dan STR-015 diturunkan ke batas tersebut. | Sedang. *(scenario-generator)* |
| **ASM-034** | Caching CDN halaman publik | Tidak diketahui apakah halaman publik di-cache CDN dengan varian per-resi. | Diasumsikan tidak di-cache tanpa varian per-resi — dasar STR-009 (kebocoran data antar sesi paralel). | Sedang. *(scenario-generator)* |
| **ASM-035** | Guard submit ganda / pembatalan request in-flight | Spec tidak menyebut proteksi submit ganda. | Diasumsikan ada guard; bila tidak, EDG-016, STR-010, STR-014 berfungsi sebagai kandidat bug report, bukan regresi. | Rendah–Sedang. *(scenario-generator)* |
| **ASM-036** | Virtualisasi `history-list` | Tidak diketahui apakah daftar riwayat memakai virtual list. | Diasumsikan **tidak** divirtualisasi. Bila ya, STR-007 (101 entri) harus menghitung via API atau scroll penuh sebelum count. | Sedang. *(scenario-generator)* |
| **ASM-037** | Konsistensi ID skenario Gherkin ↔ JSON | Perlu penautan 1:1 antara .feature dan .scenarios.json. | ID skenario ditulis sebagai tag Gherkin (`@OMS022-POS-001`); nama Scenario = field `title` JSON. | Rendah. *(scenario-generator)* |
| **ASM-038** | Penempatan blok meta pada JSON part-files | Setiap part-file wajib berupa JSON array valid (batasan teknis output). | Blok `summary`/`source`/`selectorCatalog` ditulis sebagai objek meta elemen pertama part1, lalu diangkat orkestrator ke wrapper top-level saat merge (mengikuti konvensi `oms015`). | Rendah. *(scenario-generator + orkestrator)* |
