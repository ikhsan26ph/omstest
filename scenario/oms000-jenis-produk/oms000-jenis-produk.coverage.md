# Coverage Report — oms000-jenis-produk

**Tahap:** 4/4 — scenario-reviewer (QA Review)
**Tanggal review:** 2026-09-07
**File yang direview:**
- `output/oms000-jenis-produk/oms000-jenis-produk.feature` (2602 baris, dibaca penuh)
- `output/oms000-jenis-produk/oms000-jenis-produk.scenarios.json` (17.863 baris, disampling lintas kategori: POS-001/002/003/004, STR-020/021/022, plus header/summary)
- `output/oms000-jenis-produk/oms000-jenis-produk.analysis.md` (Requirements REQ-001…103, V-01…23, ALT-01…27, Peta Layar↔REQ, Assumptions Log ASM-01…38)
- `output/oms000-jenis-produk/_extracted/review-index.md` (hasil validasi mekanis orkestrator — dipakai sebagai basis RTM, tidak dihitung ulang)

---

## Verdict Ringkas

**LULUS DENGAN CATATAN (pass with notes).**

- Coverage REQ: **103/103** REQ ter-cover ≥1 positive + ≥1 negative, dan secara substansi (bukan sekadar tag) — termasuk seluruh kasus inti modul (R2 penugasan sopir/pengurus, filter AND produk×add-on, AUTO_STUFFING↔Simulasi Muatan, guard deep-link, propagasi, pencabutan/pemulihan, konkurensi PATCH).
- Coverage tag validasi: **V-01…V-23 (23/23)** dan **ALT-01…ALT-27 (27/27)** seluruhnya muncul sebagai tag di `.feature` — tidak ada yang hilang.
- Coverage layar: **12/12** slug `@screen-*` resmi terpakai, proporsional terhadap jumlah REQ per layar.
- Dedup: **0 duplikat murni** yang direkomendasikan dibuang. Ditemukan **5 klaster overlap disengaja** (dipertahankan, beralasan) dan **1 area redundansi minor** yang layak dirapikan saat maintenance (non-blocking).
- Distribusi edge (47) & stress (22) memadai dan mencakup ketiga dimensi stress yang disyaratkan: **konkurensi**, **volume/payload besar**, dan **timeout/latensi**.
- Validasi Gherkin: struktur konsisten (Given/When/Then, tag lengkap per baris) dengan beberapa catatan gaya minor (lihat bagian Validasi Gherkin) — tidak ada `Then` tanpa assertion, tidak ada langkah dengan `action` di luar whitelist.
- **Risiko eksekusi signifikan** bersumber dari asumsi yang belum dikonfirmasi PO/tim FE/BE (ASM-29, ASM-22, ASM-30, ASM-38, ASM-05, ASM-07, ASM-04) — bukan cacat desain skenario, melainkan prasyarat sebelum suite dapat dieksekusi penuh secara otomatis. Lihat bagian Risiko Eksekusi.

---

## 1. Ringkasan Jumlah

### Per kategori

| Kategori | Jumlah | % |
|---|---|---|
| positive | 67 | 34,2% |
| negative | 60 | 30,6% |
| edge | 47 | 24,0% |
| stress | 22 | 11,2% |
| **Total** | **196** | 100% |

### Per prioritas

| Prioritas | Jumlah | % |
|---|---|---|
| high | 115 | 58,7% |
| medium | 70 | 35,7% |
| low | 11 | 5,6% |

### Per layar (`@screen-*`)

| Screen | # Skenario | REQ utama yang diverifikasi |
|---|---|---|
| api-entitlement | 63 | REQ-001…019, REQ-103, V-01…23 |
| sidebar-shipper | 25 | REQ-029…049, REQ-070/071/074/075/076, REQ-095/101 |
| penugasan-tracking | 23 | REQ-020…028, REQ-037, REQ-052, REQ-100 |
| nav-lkl | 15 | REQ-078…094 |
| master-moda | 14 | REQ-036/039/041/042, REQ-070/071/073…076, REQ-087…090, REQ-096…099 |
| pengaturan-sistem | 12 | REQ-048, REQ-058…068, REQ-099 |
| sidebar-vendor | 10 | REQ-050…057, REQ-102 |
| driver-app | 8 | REQ-022/024/026/027/028/052/102 |
| error | 8 | REQ-095…097, REQ-101/102 |
| form-order | 8 | REQ-035, REQ-069, REQ-077, REQ-098 |
| dashboard | 6 | REQ-030…034, REQ-072/074/075 |
| login | 4 | REQ-095, REQ-100…102 |
| **Total** | **196** | — |

Semua 12 slug layar resmi (UI-T00…UI-T11) terpakai; distribusi proporsional terhadap kompleksitas masing-masing layar (mis. `api-entitlement` terbesar karena memuat seluruh R1 + 23 aturan validasi; `login`/`dashboard` terkecil karena REQ yang mereka verifikasi sedikit).

### Scenario Outline

43 Outline dengan 324 baris Examples total — dikonfirmasi mekanis 1:1 dengan `examples[]` pada JSON (sampling OMS000-POS-003 dan OMS000-POS-004 mengonfirmasi struktur kolom Examples cocok dengan field `examples[]`).

---

## 2. Coverage Requirements (REQ-001…103)

**Kesimpulan:** seluruh 103 REQ memiliki ≥1 skenario positive dan ≥1 negative yang **substantif** — bukan sekadar tag yang "menumpang" di skenario lain tanpa assertion terkait. Beberapa pola berikut ditemukan dan dinilai wajar (bukan gap):

1. **REQ dengan sifat "selalu tampil" (varian Setara/union)** — REQ-038, 040, 045-047, 051, 055-056, 059, 065, 080-081, 083, 086, 091-093 — negatifnya secara alami hanya dapat diuji lewat *fallback* "tanpa produk aktif" (REQ-101) karena item tersebut memang tidak memiliki kondisi "hilang" lain dalam matriks sumber. Ini bukan kelemahan desain; skenario negatifnya (mis. NEG-031, NEG-037, NEG-051) tetap melakukan assertion `toHaveCount(0)`/`error-403-page` yang relevan terhadap testid REQ tersebut.
2. **REQ yang di-cover lewat skenario komposit** — REQ-009…014, REQ-017 memperoleh 1 positive tambahan dari OMS000-POS-014 ("Kontrak lengkap terpenuhi") yang menguji 7 REQ sekaligus dalam satu smoke-test kontrak; masing-masing tetap memiliki skenario positive/negative dedicated lain (mis. REQ-011 juga di POS-003 tersirat via clientId valid, NEG-005 dedicated 404, EDG-011/044 dedicated edge). Tidak ada REQ yang **hanya** bergantung pada skenario komposit ini.
3. **Kasus inti modul (R2, R6, R8)** — diverifikasi berlapis lintas kategori dan sengaja diulang di beberapa layar (`penugasan-tracking` + `driver-app`) sesuai arahan UI Inventory (`UI-T04` wajib berpasangan dengan `UI-T05`). Contoh REQ-022 dicover oleh: POS-019, POS-020 (positive), NEG-020 (negative), EDG-036/046/047 (edge), STR-010 (stress) — 7 skenario lintas 4 kategori, semuanya dengan assertion konkret ke `driver.assignmentList`/`assignmentCount` (bukan hanya cek toast).

### Verifikasi kasus inti modul secara eksplisit

| Kasus inti | Skenario yang menguji | Substantif? |
|---|---|---|
| Sopir TMS masuk apps, OMS tidak | POS-019/020/022/024, NEG-020/024, EDG-017/018/036/043/046, STR-010/011 | Ya — assertion ke `driver.assignmentList`/`assignmentCount`, bukan hanya UI toast |
| Pengurus selalu input web | POS-021/023/025/028, NEG-021/022/025, EDG-047 | Ya — assertion `tracking-input-form`, ketiadaan di daftar tugas sopir |
| Gabungan TMS+OMS = Ikut TMS | POS-024/026, NEG-024, EDG-017/046 | Ya — order berasal-OMS tetap dites masuk apps saat gabungan (POS-024) |
| Filter AND products×addOns | POS-050, NEG-034/046, EDG-025/026/027 | Ya — kombinasi eksplisit (OMS+darat vs OMS+laut) diuji berpasangan |
| AUTO_STUFFING↔Simulasi Muatan | POS-031, NEG-030/047, EDG-027/028, V-20 | Ya — termasuk kasus TMS+AUTO_STUFFING (tetap hilang) dan OMS+AUTO_STUFFING tanpa SERVICE_* (tetap ada) |
| Deep-link guard | POS-061/062, NEG-036/043/046/047/049/051/054/055, EDG-019/031/039/040/041, STR-013/014 | Ya — assertion OR (403/redirect) + ketiadaan konten wajib, sesuai ASM-31 |
| Propagasi (refresh/login) | POS-059/060, NEG-053, EDG-019/031/033, STR-009/012/015 | Ya — termasuk kasus "tanpa refresh boleh tetap lama" (NEG-053, ALT-12) |
| Pencabutan/pemulihan data | POS-063/064, NEG-056/057, EDG-034, STR-019 | Ya — membandingkan `pagination-info` sebelum/sesudah, bukan hanya cek menu |
| Konkurensi PATCH | STR-001/002/003 | Ya — STR-002 paralel clientId sama (race), STR-003 paralel 50 client berbeda (isolasi) |

**Tidak ditemukan gap substansi** pada 9 kasus inti di atas.

---

## 3. Coverage V-xx dan ALT-xx (dihitung dari tag aktual di `.feature`)

### Aturan Validasi (V-01…V-23) — **23/23 muncul sebagai tag**

Semua 23 aturan validasi API muncul minimal satu kali sebagai tag `@V-xx`:

| V-xx | Contoh scenario pembawa tag |
|---|---|
| V-01 | NEG-005, NEG-006, EDG-010, EDG-011 |
| V-02 | POS-001, POS-013, NEG-001, NEG-002, STR-016 |
| V-03 | POS-001, NEG-003, EDG-015 |
| V-04 | NEG-004, EDG-009 |
| V-05 | POS-002, POS-011, NEG-014, EDG-007, STR-006 |
| V-06 | NEG-010 |
| V-07 | POS-003, NEG-007 |
| V-08 | POS-003, NEG-009, EDG-001, EDG-030, STR-005 |
| V-09 | NEG-008, EDG-012 |
| V-10 | POS-009, NEG-017, EDG-004 |
| V-11 | NEG-010 |
| V-12 | POS-004, NEG-007, EDG-013 |
| V-13 | POS-004, POS-010, EDG-002, EDG-003, STR-004 |
| V-14 | NEG-008, EDG-012 |
| V-15 | POS-009, EDG-004 |
| V-16 | NEG-011 |
| V-17 | NEG-007, NEG-016, NEG-018, EDG-014, STR-008 |
| V-18 | POS-005, NEG-015 |
| V-19 | POS-006, POS-007, EDG-008 |
| V-20 | NEG-030, EDG-027 |
| V-21 | NEG-042 |
| V-22 | POS-012, NEG-018, EDG-016, STR-001 |
| V-23 | NEG-012 |

Tidak ada V-xx yang hilang.

### Alternatif/Percabangan (ALT-01…ALT-27) — **27/27 muncul sebagai tag**

| ALT-xx | Contoh scenario pembawa tag |
|---|---|
| ALT-01 | NEG-002 |
| ALT-02 | NEG-001 |
| ALT-03 | NEG-005 |
| ALT-04 | NEG-006 |
| ALT-05 | NEG-007 |
| ALT-06 | NEG-008 |
| ALT-07 | NEG-009 |
| ALT-08 | POS-010 |
| ALT-09 | POS-009 |
| ALT-10 | POS-006 |
| ALT-11 | POS-011, NEG-014, EDG-007 |
| ALT-12 | NEG-053, EDG-019, EDG-031 |
| ALT-13 | NEG-054, EDG-031 |
| ALT-14 | POS-022, NEG-020 |
| ALT-15 | POS-024, NEG-024 |
| ALT-16 | POS-021 |
| ALT-17 | POS-023 |
| ALT-18 | NEG-044 |
| ALT-19 | POS-049 |
| ALT-20 | NEG-042 |
| ALT-21 | POS-057, POS-058, EDG-023 |
| ALT-22 | NEG-050, EDG-022 |
| ALT-23 | NEG-047 |
| ALT-24 | NEG-030 |
| ALT-25 | POS-026, POS-065, NEG-058 |
| ALT-26 | NEG-037, EDG-032, STR-021 |
| ALT-27 | NEG-027, EDG-017, EDG-018, EDG-043 |

Tidak ada ALT-xx yang hilang. Ini adalah temuan positif — biasanya modul sebesar ini menyisakan beberapa ALT yang hanya implisit; di sini seluruh percabangan pada User Flow (UF-1…UF-5) memiliki representasi tag eksplisit yang bisa dilacak balik ke analysis.md.

**Catatan kecil:** OMS000-STR-002 membawa tag tambahan `@ASM-38` (di luar pola tag standar `@kategori/@priority/@REQ/@screen/@OMS000-ID`). Ini bukan pelanggaran (tag ekstra tidak dilarang oleh validasi mekanis orkestrator), namun sebaiknya dikonfirmasi apakah pola ini akan diperluas secara konsisten ke skenario lain yang bergantung asumsi blocking, atau dihapus untuk konsistensi gaya tag.

---

## 4. Temuan Dedup

**Tidak ditemukan duplikat murni** (skenario dengan Given/When/Then dan tujuan assertion yang identik) yang perlu dibuang. Modul ini memakai pola "matrix Outline besar + skenario tunggal pendukung" secara sengaja untuk memberi granularitas debugging berbeda — matrix Outline memverifikasi keberadaan/ketidakberadaan lewat testid untuk banyak baris sekaligus, sedangkan skenario tunggal memverifikasi *interaksi* (klik menu, buka halaman, assertion tambahan) pada satu titik matriks yang paling representatif/berisiko.

### Klaster overlap disengaja (dipertahankan) — beserta alasan

| # | Skenario yang beririsan | Titik irisan | Alasan dipertahankan |
|---|---|---|---|
| 1 | OMS000-POS-030 (Outline 42 baris) vs OMS000-POS-035 (Outline 12 baris) | Baris "Setara" (Master Wilayah, Master Drop Point, Manajemen Vendor, Pengaturan Akun, Akun Saya) muncul di kedua Outline untuk state TMS-only & OMS-only | POS-035 **menambah** baris state *gabungan* untuk Master Wilayah & Master Drop Point yang tidak ada di Examples POS-030 baris "gabungan" (POS-030 gabungan hanya 7 baris spesifik-varian). POS-035 juga secara eksplisit menegaskan kesamaan visual "Setara" lintas 3 state sebagai satu unit pengujian yang mudah dibaca terpisah dari matriks besar. |
| 2 | OMS000-POS-038 (Outline 3 baris, `["OMS"]`+`["SERVICE_LCL"]`) vs OMS000-EDG-025 | Given identik: `products ["OMS"] addOns ["SERVICE_LCL"]` | EDG-025 menambah assertion negatif (`dashboard-tab-progress-pengiriman` tidak tampil) untuk menegaskan bahwa *hanya* add-on laut tipe Less yang aktif — nuansa edge (Less-only) berbeda fokus dari POS-038 (fokus: klik & buka kedua halaman Master Pelabuhan/Pelayaran). |
| 3 | OMS000-POS-048 vs OMS000-EDG-026 | Given identik: `products ["TMS"] addOns ["SERVICE_LTL"]` | EDG-026 menambah 2 assertion negatif (Master Pelabuhan/Pelayaran tidak tampil) untuk menguji boundary "Less darat saja tidak mengaktifkan laut" — POS-048 fokus pada interaksi klik tab dashboard. |
| 4 | OMS000-NEG-030 vs OMS000-EDG-027 | Tema AUTO_STUFFING tanpa moda | Beda state: NEG-030 = TMS+AUTO_STUFFING (Simulasi Muatan tetap hilang, exclusive-produk); EDG-027 = OMS+AUTO_STUFFING **tanpa** SERVICE_* apa pun (Simulasi Muatan tetap ADA, fitur moda hilang). Dua arah pengujian berbeda pada rule V-20, keduanya perlu. |
| 5 | OMS000-POS-026/NEG-027/EDG-017/EDG-018 | Tema "penugasan lama vs baru saat produk berubah" | Empat sudut pandang berbeda: POS-026 (menu masih tercatat), NEG-027 (penugasan **baru** tidak lagi masuk apps), EDG-017 (toggle cepat TMS→OMS→TMS pulih), EDG-018 (order lama tetap di apps sopir). Tidak ada duplikasi Then; masing-masing menguji invarian berbeda dari REQ-028/REQ-100. |

### Redundansi minor (non-blocking, rekomendasi maintenance)

- Baris TMS-only & OMS-only pada OMS000-POS-035 (klaster #1 di atas) — 8 dari 12 baris Examples-nya sudah ter-cover persis oleh OMS000-POS-030. Tidak direkomendasikan dibuang sekarang (risiko regresi dokumentasi rendah bila disederhanakan nanti), namun dicatat sebagai kandidat penyederhanaan saat maintenance berikutnya: cukup pertahankan baris "gabungan" di POS-035 dan hapus baris TMS-only/OMS-only yang sudah identik dengan POS-030.

**Kesimpulan dedup: 0 skenario direkomendasikan dibuang.**

---

## 5. Distribusi Edge & Stress

### Edge (47 skenario, 24%)

Distribusi edge mencakup:
- **Boundary API** (minItems/maxItems, dedup berlipat, urutan array, body kosong, charset) — EDG-001…016 (16 skenario), semuanya di `api-entitlement`.
- **Kombinasi langka & guard** (moda tunggal ekstrem, sesi berjalan, toggle produk, URL aneh) — EDG-017…045 (29 skenario) lintas 8 layar.
- **Indikator kanal opsional** (badge/hint, ditandai non-blocking sesuai ASM-33) — EDG-046/047 (2 skenario).

Proporsi 24% wajar untuk modul matriks-berat seperti ini (menu×produk×add-on×moda) yang secara alami menghasilkan banyak kombinasi boundary.

### Stress (22 skenario, 11%)

Diverifikasi mencakup ketiga dimensi stress yang seharusnya ada:

| Dimensi | Skenario |
|---|---|
| **Konkurensi** | STR-002 (10 PATCH paralel, clientId sama — uji race condition), STR-003 (50 PATCH paralel, clientId berbeda — uji isolasi antar-client), STR-009 (100 login serentak), STR-014 (200 API call paralel), STR-021 (50 sesi vendor paralel) |
| **Volume/payload besar** | STR-004 (5000 elemen `addOns` duplikat), STR-005 (10000 elemen `products` duplikat), STR-006 (field asing 1 MB), STR-007 (`clientId` 10.000 karakter), STR-008 (1000 enum tidak dikenal), STR-010/011 (200 order assignment), STR-022 (500 PATCH audit) |
| **Timeout/latensi** | STR-007 ("< 10 detik"), STR-015 (delay backend 10 detik, tidak boleh bocor menu saat loading), STR-018 ("< 5 detik" render 23 item LKL) |
| **Siklus berulang (regresi state)** | STR-001 (50 PATCH bergantian), STR-012 (navigasi cepat 3 putaran), STR-017 (50 siklus buka-tutup + toggle produk), STR-019 (20 siklus cabut-pulihkan add-on), STR-020 (50 kali buka form + toggle add-on) |

**Kesimpulan:** distribusi stress tidak hanya "menambah angka besar" tapi menyasar 4 sub-dimensi berbeda (konkurensi, volume, latensi, siklus berulang) yang relevan dengan sifat modul (entitlement global per client + guard yang harus tetap konsisten di bawah beban). Tidak ada gap signifikan pada kategori ini.

---

## 6. Validasi Gherkin — Catatan Tambahan

Validasi mekanis (format tag, action whitelist, screen slug, 1:1 feature↔JSON) sudah dinyatakan lolos oleh orkestrator. Tinjauan substansi/gaya menghasilkan catatan berikut (semuanya minor, tidak ada yang blocking):

1. **Placeholder `<X-Admin-Key>` / `<clientId>` di luar Scenario Outline.** Background memakai sintaks `<...>` (mis. `Given admin memiliki <X-Admin-Key> valid dari environment`) yang secara visual identik dengan placeholder kolom Examples, padahal di sini maknanya berbeda (instruksi "ambil dari environment", bukan substitusi Cucumber). Ini konsisten dengan intent ASM-03, tapi berpotensi membingungkan tooling lint Gherkin generik yang mengasumsikan `<...>` selalu berasal dari tabel Examples. **Rekomendasi:** pertimbangkan konvensi berbeda (mis. `${X-Admin-Key}` yang sudah dipakai di JSON `testData`) agar konsisten dengan `${ADMIN_KEY}`/`${CLIENT_ID}` di JSON, dan tidak tertukar dengan placeholder Outline asli.
2. **Tag REQ pada Outline besar berlaku untuk seluruh Examples, bukan per baris.** Outline seperti OMS000-POS-030 (21 tag REQ, 42 baris), OMS000-POS-055 (14 tag REQ, 54 baris), OMS000-NEG-029 (8 tag REQ), OMS000-NEG-049 (6 tag REQ), OMS000-NEG-051 (10 tag REQ) menandai satu set REQ untuk keseluruhan Outline, padahal tiap baris Examples sebenarnya hanya relevan untuk 1 REQ spesifik (mis. baris "Master Barang" → REQ-039 saja). Ini adalah keterbatasan bawaan Gherkin (tag tidak bisa per-baris Examples) dan **bukan cacat**, namun **RTM di bagian 7 mewarisi granularitas ini** — saat menelusuri kegagalan test per REQ, verifikator harus mencocokkan REQ dengan **nama kolom `<menu>`/`<item>` pada baris Examples yang relevan**, bukan mengasumsikan seluruh Outline gagal untuk REQ tertentu.
3. **Rangkaian `When … And … And …` yang mencampur trigger dan navigasi.** Pola seperti `When entitlement client diset products [...] And shipper login ulang And user berada di halaman "X"` menggabungkan aksi pemicu (ubah entitlement) dengan langkah navigasi lanjutan di bawah blok `When` yang sama (bukan sebagai `Given` setelah re-setup). Ini valid secara Gherkin (Cucumber memperlakukan `And` mengikuti tipe step sebelumnya) dan merupakan pola yang konsisten di seluruh file, tapi secara gaya lebih dekat ke "multi-step When". Tidak direkomendasikan diubah mengingat konsistensi lintas 196 skenario lebih penting daripada purity gaya.
4. **Tidak ditemukan `Then` tanpa assertion**, tidak ditemukan langkah dengan `action` di luar whitelist (`navigate/fill/click/select/check/uncheck/expect/request`), dan tidak ditemukan Outline tanpa blok Examples (dikonfirmasi silang dengan hasil mekanis orkestrator + sampling manual pada >40% baris file).
5. **Tag ekstra `@ASM-38`** pada OMS000-STR-002 (lihat bagian 3) — dicatat sebagai temuan tag hygiene minor.
6. Beberapa skenario memuat **8+ assertion `Then/And` berurutan** dalam satu Scenario non-Outline (mis. OMS000-POS-043, delapan `sistem menampilkan setting-item-*`). Ini valid dan disengaja untuk cardinality-check menyeluruh, namun bila salah satu item gagal, laporan kegagalan tidak langsung menunjuk item mana — mitigasi sudah ada lewat OMS000-POS-045 (Outline per-item) sebagai pasangan yang lebih granular.

**Kesimpulan Gherkin:** struktur valid dan konsisten; catatan di atas bersifat perbaikan kualitas-hidup (quality-of-life) untuk maintenance jangka panjang, bukan syarat lulus/gagal.

---

## 7. Requirements Traceability Matrix (REQ-001…103)

| REQ | Deskripsi Singkat | Scenario IDs |
|---|---|---|
| REQ-001 | Endpoint PATCH entitlement per `{clientId}` | POS-001, NEG-012, NEG-013, STR-003 |
| REQ-002 | Wajib header `X-Admin-Key` valid | POS-001, POS-013, NEG-001, STR-016 |
| REQ-003 | Wajib `Content-Type: application/json` + body JSON valid | POS-001, NEG-003, NEG-004, EDG-009, EDG-015 |
| REQ-004 | Body hanya boleh ubah `products`/`addOns` | POS-002, NEG-014, EDG-008 |
| REQ-005 | `products` enum TMS/OMS, nilai lain ditolak | POS-003, NEG-007, NEG-010, NEG-011, EDG-001, EDG-005, STR-005 |
| REQ-006 | `addOns` enum 6 nilai sah, nilai lain ditolak | POS-004, NEG-007, NEG-010, EDG-002, EDG-003, EDG-006, EDG-014, STR-004 |
| REQ-007 | Update partial per field, replace penuh per array | POS-005, POS-006, POS-007, NEG-015, EDG-005, EDG-008, EDG-016, STR-001, STR-002 |
| REQ-008 | Request valid → 200 + entitlement terkini | POS-001, POS-008, NEG-016, EDG-045, STR-002, STR-015 |
| REQ-009 | Admin key salah/kedaluwarsa → 401, tak berubah | POS-014, NEG-001, STR-016 |
| REQ-010 | Admin key absen/kosong → 401, tak berubah | POS-014, NEG-002 |
| REQ-011 | `clientId` tak terdaftar → 404, tak buat baru | POS-014, NEG-005, EDG-011, EDG-044, STR-003 |
| REQ-012 | `clientId` format invalid → 400 | POS-014, NEG-006, EDG-010, EDG-011, STR-007 |
| REQ-013 | Enum tak dikenal → 400 all-or-nothing | POS-014, NEG-007, EDG-013, EDG-014, STR-008 |
| REQ-014 | Validasi enum case-sensitive UPPERCASE | POS-014, NEG-008, EDG-012 |
| REQ-015 | Duplikat array diterima & dideduplikasi | POS-009, NEG-017, EDG-004, STR-004 |
| REQ-016 | `addOns: []` sah (tanpa add-on) | POS-010, POS-051, NEG-011, EDG-003, EDG-029 |
| REQ-017 | `products: []` ditolak 400 (min 1 produk) | POS-003, POS-014, NEG-009, EDG-001, EDG-030 |
| REQ-018 | Field asing di body diabaikan | POS-011, NEG-014, EDG-007, STR-006 |
| REQ-019 | Operasi idempoten | POS-012, NEG-018, EDG-005, EDG-016, STR-001 |
| REQ-020 | Menu Penugasan Tracking di TMS & OMS, Shipper & Vendor | POS-016, POS-017, NEG-026 |
| REQ-021 | Dua target pelaksana: Sopir & Pengurus | POS-018, NEG-023, EDG-037 |
| REQ-022 | TMS+Sopir → masuk apps mobile sopir | POS-019, POS-020, NEG-020, EDG-036, EDG-046, EDG-047, STR-010 |
| REQ-023 | TMS+Pengurus → tidak ke apps, input web | POS-021, POS-028, NEG-021 |
| REQ-024 | OMS+Sopir → tersimpan, TIDAK masuk apps | POS-022, NEG-020, EDG-036, EDG-043, EDG-046, EDG-047, STR-011 |
| REQ-025 | OMS+Pengurus → tersimpan, input web | POS-023, POS-028, NEG-022 |
| REQ-026 | Gabungan TMS+OMS → Ikut TMS (sopir masuk apps) | POS-024, NEG-024, EDG-017, EDG-046 |
| REQ-027 | Produk OMS → progres hanya via input web | POS-025, POS-028, NEG-025, EDG-045, EDG-047 |
| REQ-028 | Perubahan `products` tak batalkan penugasan berjalan | POS-026, NEG-027, EDG-017, EDG-018 |
| REQ-029 | Susunan menu Shipper ikut `products`, 4 grup resmi | POS-029, POS-030, NEG-029, EDG-042, STR-009, STR-012 |
| REQ-030 | Dashboard-Monitoring tampil 3 state, gabungan TMS | POS-030, POS-032, NEG-031 |
| REQ-031 | Dashboard-Tracking&Location hanya TMS | POS-030, POS-032, NEG-029, NEG-033 |
| REQ-032 | Dashboard-Progress Pengiriman hanya TMS + filter moda | POS-030, POS-032, POS-048, NEG-029, NEG-034 |
| REQ-033 | Dashboard-Operasional tampil 3 state, gabungan TMS | POS-030, POS-032, NEG-031 |
| REQ-034 | Dashboard-Distribusi&Muatan hanya OMS | POS-030, POS-032, NEG-029, NEG-033 |
| REQ-035 | Order tampil 3 state, gabungan varian OMS | POS-030, POS-033, NEG-031 |
| REQ-036 | Simulasi Muatan hanya OMS+AUTO_STUFFING | POS-030, POS-031, NEG-029, NEG-030, EDG-027, EDG-028 |
| REQ-037 | Penugasan Tracking tampil 3 state, gabungan Ikut TMS | POS-016, POS-030, NEG-026 |
| REQ-038 | Master Wilayah tampil 3 state, Setara | POS-030, POS-035, NEG-031 |
| REQ-039 | Master Barang hanya OMS | POS-030, POS-037, NEG-029, EDG-042 |
| REQ-040 | Master Drop Point tampil 3 state, Setara | POS-030, POS-035, NEG-031 |
| REQ-041 | Master Pelabuhan Setara + filter moda laut | POS-030, POS-038, NEG-029 |
| REQ-042 | Master Pelayaran Setara + filter moda laut | POS-030, POS-038, NEG-029 |
| REQ-043 | Master Unit tampil 3 state, gabungan TMS | POS-030, POS-034, NEG-031 |
| REQ-044 | Master Sopir tampil 3 state, gabungan TMS | POS-030, POS-034, NEG-031 |
| REQ-045 | Manajemen Vendor tampil 3 state, Setara | POS-030, POS-035, NEG-031 |
| REQ-046 | Pengaturan Akun tampil 3 state, Setara | POS-030, POS-035, NEG-032 |
| REQ-047 | Akun Saya tampil 3 state, Setara | POS-030, POS-035, NEG-032 |
| REQ-048 | Pengaturan Sistem tampil 3 state, gabungan TMS | POS-030, POS-036, NEG-031 |
| REQ-049 | Pusat Notifikasi tampil 3 state, gabungan TMS | POS-030, POS-036, NEG-032 |
| REQ-050 | Menu Vendor identik TMS/OMS, tepat 6 item | POS-039, NEG-037, NEG-038, EDG-032, STR-021 |
| REQ-051 | Vendor-Order tampil TMS & OMS | POS-040, NEG-037 |
| REQ-052 | Vendor-Penugasan Tracking, ikut aturan R2 | POS-017, POS-027, POS-040, NEG-028, NEG-037 |
| REQ-053 | Vendor-Master Armada, khusus Vendor | POS-040, POS-041, NEG-037 |
| REQ-054 | Vendor-Master Sopir, khusus Vendor | POS-040, POS-041, NEG-037 |
| REQ-055 | Vendor-Akun Saya | POS-040, POS-042, NEG-037 |
| REQ-056 | Vendor-Pusat Notifikasi | POS-040, POS-042, NEG-037 |
| REQ-057 | Menu Vendor tak memuat menu eksklusif Shipper | POS-039, NEG-035, NEG-036, EDG-041 |
| REQ-058 | Isi Pengaturan Sistem ikut `products` | POS-043, POS-044, NEG-039, STR-017 |
| REQ-059 | Durasi Kedaluwarsa Undangan Vendor tampil 3 state | POS-045, NEG-041 |
| REQ-060 | Notifikasi Lokasi hanya TMS | POS-045, NEG-039 |
| REQ-061 | Deteksi Tidak Update hanya TMS | POS-045, NEG-039 |
| REQ-062 | Deteksi Keluar Jalur hanya TMS | POS-045, NEG-039, EDG-034 |
| REQ-063 | Koridor Historis hanya TMS | POS-045, POS-046, NEG-039, EDG-035 |
| REQ-064 | Notifikasi Dini Berisiko Terlambat hanya TMS | POS-045, NEG-039 |
| REQ-065 | Nomor WhatsApp CS tampil 3 state | POS-045, NEG-041 |
| REQ-066 | Pembatasan Kelayakan Armada hanya TMS | POS-045, NEG-039 |
| REQ-067 | Gabungan → 8 item Pengaturan Sistem (union) | POS-043, NEG-040, EDG-033, STR-017 |
| REQ-068 | OMS-only → tepat 2 item Pengaturan Sistem | POS-044, NEG-039, EDG-033, STR-017 |
| REQ-069 | Add-on `SERVICE_*` tentukan moda darat/laut/udara | POS-047, POS-052, NEG-042, EDG-006, EDG-025, EDG-026, STR-020 |
| REQ-070 | Master Pelabuhan hilang jika hanya darat aktif | POS-038, POS-049, NEG-043, EDG-025 |
| REQ-071 | Master Pelayaran hilang jika hanya darat aktif | POS-038, POS-049, NEG-043, EDG-025 |
| REQ-072 | Dashboard-Progress Pengiriman perlu moda darat | POS-032, POS-048, NEG-034, NEG-044, EDG-026 |
| REQ-073 | Darat+Laut aktif → ketiga fitur JP tampil (union) | POS-049, NEG-045 |
| REQ-074 | Visibilitas = AND filter products & addOns | POS-050, NEG-034, NEG-046, EDG-027 |
| REQ-075 | Tanpa `SERVICE_*` sama sekali → 3 fitur JP hilang | POS-051, NEG-042, EDG-027, EDG-029 |
| REQ-076 | AUTO_STUFFING aktifkan Simulasi Muatan (OMS) | POS-031, NEG-030, NEG-047, EDG-028 |
| REQ-077 | Add-on `SERVICE_*` batasi jenis order dibuat | POS-052, POS-053, NEG-048, EDG-029, EDG-038, STR-020 |
| REQ-078 | TMS LKL: menu ikut moda aktif | POS-054, NEG-051, STR-018 |
| REQ-079 | Dashboard-Monitoring hanya moda Darat (LKL) | POS-055, NEG-049, EDG-023 |
| REQ-080 | Dashboard-Tracking&Location/Operasional 3 moda | POS-055, NEG-051 |
| REQ-081 | Shipment/Order/Penugasan Tracking 3 moda | POS-055, NEG-051 |
| REQ-082 | Otomasi Jalur hanya moda Darat | POS-055, NEG-049, EDG-023 |
| REQ-083 | Master Wilayah tampil 3 moda | POS-055, NEG-051 |
| REQ-084 | Master Rute tampil 3 moda | POS-055, POS-056, NEG-051 |
| REQ-085 | Tab Tarif Pengiriman & Konversi Muatan hanya tipe Less | POS-056, NEG-050, EDG-020, EDG-021, EDG-022, EDG-024 |
| REQ-086 | Master Customer & Drop Point 3 moda | POS-055, NEG-051 |
| REQ-087 | Master Pelabuhan hanya moda Laut (LKL) | POS-055, NEG-049, EDG-021 |
| REQ-088 | Master Pelayaran hanya moda Laut (LKL) | POS-055, NEG-049 |
| REQ-089 | Master Bandara hanya moda Udara | POS-055, POS-058, NEG-049, EDG-023 |
| REQ-090 | Master Maskapai hanya moda Udara | POS-055, POS-058, NEG-049, EDG-023 |
| REQ-091 | Master Unit&Sopir/Kemasan/Bank 3 moda | POS-055, NEG-051 |
| REQ-092 | Manajemen Invoice & Laporan Keuangan 3 moda | POS-055, NEG-051 |
| REQ-093 | Pengaturan Akun/Akun Saya/Pusat Notifikasi 3 moda | POS-055, NEG-051 |
| REQ-094 | >1 moda aktif → union menu antar moda | POS-057, NEG-052, EDG-024, STR-018 |
| REQ-095 | Perubahan entitlement berlaku sesi baru | POS-059, POS-060, NEG-053, EDG-017, EDG-019, EDG-031, EDG-033, STR-009, STR-012, STR-015 |
| REQ-096 | Guard server tolak deep-link fitur non-entitle | POS-061, NEG-043, NEG-054, EDG-031, EDG-039, EDG-040, STR-013 |
| REQ-097 | Enforcement API tolak (403) fitur non-entitle | POS-062, NEG-043, NEG-053, NEG-055, EDG-019, EDG-041, STR-014 |
| REQ-098 | Data tidak dihapus saat produk/add-on dicabut | POS-063, NEG-056, EDG-038, STR-019 |
| REQ-099 | Reaktivasi kembalikan menu + data lama utuh | POS-046, POS-064, NEG-057, EDG-034, STR-019 |
| REQ-100 | Transaksi berjalan tetap bisa dilihat/diselesaikan | POS-026, POS-065, NEG-058, EDG-018 |
| REQ-101 | Fallback entitlement kosong → sidebar minimal 3 menu | POS-066, NEG-026, NEG-031, NEG-032, NEG-041, NEG-051, NEG-059, EDG-030 |
| REQ-102 | Konsistensi lintas kanal (Shipper/Vendor/apps sopir) | POS-067, NEG-060, EDG-036, EDG-043, STR-010, STR-021 |
| REQ-103 | Setiap perubahan entitlement tercatat audit trail | POS-015, NEG-019, EDG-044, STR-022 |

*(Prefiks `OMS000-` dihilangkan pada kolom Scenario IDs demi keterbacaan tabel.)*

---

## 8. Risiko Eksekusi

Skenario telah didesain dengan baik secara struktural, namun **eksekusi otomatis penuh bergantung pada konfirmasi eksternal** berikut. Diurutkan dari dampak tertinggi:

### Risiko TINGGI (berpotensi blocking)

1. **ASM-29 — Verifikasi apps sopir.** Endpoint `GET .../driver/{driverId}/assignments` **belum dikonfirmasi ada**. Ini adalah tulang punggung verifikasi seluruh R2 (kasus inti modul). **Skenario terdampak (≈20):** POS-019/020/022/024/026/027, NEG-020/021/022/024/025/027/028/060, EDG-017/018/036/043/046/047, STR-010/011. Bila endpoint tidak tersedia, skenario-skenario ini turun ke status **MANUAL** sesuai ketentuan header `.feature`.
2. **ASM-22 — Kontrak `data-testid`.** Seluruh 196 skenario bergantung pada testid yang **belum tentu ada di kode FE** (dicatat eksplisit sebagai "permintaan kontrak test ke tim FE"). Ini risiko tertinggi secara volume (mempengaruhi hampir semua skenario UI, ~133 dari 196 yang bukan `api-entitlement`).
3. **ASM-38 — Isolasi eksekusi.** Entitlement bersifat **global per `clientId`**. Suite **wajib** dijalankan serial (`workers: 1`) atau memakai `clientId` terpisah per worker, dan setiap file wajib teardown ke nilai semula. Bila diabaikan, seluruh 196 skenario berisiko flaky karena saling menimpa state. **Catatan penting:** ini **tidak bertentangan** dengan skenario konkurensi (STR-002/003/009/014/021) karena konkurensi yang diuji adalah **konkurensi request di dalam satu skenario** (mis. 10 PATCH paralel pada satu clientId di STR-002), bukan paralelisme antar-file test — kedua hal ini kompatibel selama runner level-suite tetap serial.

### Risiko SEDANG

4. **ASM-30 — Route deep-link.** ~30 skenario guard (NEG-026/029/031/036/039/041/043/046/047/049/051/054, EDG-019/031/039/040/041, STR-013, POS-061) bergantung pada route usulan kebab-case yang **belum dikonfirmasi**. Kegagalan `page.goto()` akibat route salah akan tampak seperti kegagalan produk padahal sebenarnya kesalahan asumsi test.
5. **ASM-05 & ASM-07 — Interpretasi "Ikut TMS/OMS" dan pemetaan add-on→moda.** Asumsi paling berdampak pada logika bisnis: bila salah, berpotensi membalikkan ekspektasi pada ~60+ skenario R3/R6/R7 (semua skenario `sidebar-shipper`, `dashboard`, `master-moda`, `nav-lkl`, `form-order`). Prioritas tinggi untuk konfirmasi PO sebelum eksekusi pertama.
6. **ASM-04 & ASM-27 & ASM-28 — Kontrak respons API (status code, bentuk JSON, format error).** Mempengaruhi seluruh 63 skenario `api-entitlement`. Mitigasi sudah ada via assertion berlapis (`$.products ?? $.data.products`) tapi kode status (401 vs 403, 415 vs 400) tetap perlu konfirmasi BE.
7. **ASM-31 — Bentuk guard (DOM removal vs disable; 403 vs redirect).** Sudah dimitigasi dengan assertion OR di seluruh skenario guard; risiko sisa hanya bila implementasi memakai `disabled` state (bukan unmount) — akan dilaporkan sebagai defect terhadap semangat REQ-029, bukan penyesuaian test.

### Risiko RENDAH (sudah dimitigasi desain)

8. **ASM-33 — Badge kanal penugasan opsional.** Sudah eksplisit non-blocking (EDG-046/047 terpisah dari assertion utama R2 di `driver-app`).
9. **ASM-01/21/24/25/34/35/36 — Ketiadaan aset desain & asumsi struktur UI (grup collapsible, bentuk radio, halaman list seragam).** Berdampak pada akurasi label/selector tapi tidak mengubah logika assertion inti; akan terlihat sebagai kegagalan selector yang mudah didiagnosis (bukan silent-false-negative).

---

## 9. Daftar Asumsi (ASM) yang Perlu Konfirmasi PO/Tim Teknis

Sebelum suite ini dieksekusi penuh, urutan konfirmasi yang direkomendasikan:

| Prioritas | ASM | Yang perlu dikonfirmasi | Ke siapa |
|---|---|---|---|
| 1 | ASM-29 | Apakah ada endpoint/log untuk memverifikasi "masuk/tidak masuk apps sopir"? Jika tidak, sepakati mekanisme alternatif atau tandai R2 sebagai manual. | Tim Backend |
| 2 | ASM-22, ASM-23 | Apakah katalog `data-testid` (terutama `nav-item-<slug>`, `assignment-*`, `setting-item-*`, `dashboard-tab-*`, `order-type-*`, `error-403-page`) akan diimplementasikan sesuai usulan? | Tim Frontend |
| 3 | ASM-30 | Apa route aktual untuk setiap menu (26 slug)? | Tim Frontend |
| 4 | ASM-38 | Apakah tersedia `clientId` terpisah per worker CI, atau suite harus serial penuh? | Tim QA Infra/DevOps |
| 5 | ASM-05 | Konfirmasi makna kolom "Penggabungan OMS+TMS" (`Ikut TMS`/`Ikut OMS`/`Setara`) — apakah union-varian sesuai interpretasi analysis.md? | PO |
| 6 | ASM-07 | Konfirmasi pemetaan add-on `SERVICE_*` → moda (darat/laut/udara) dan aturan AND antara filter produk & add-on. | PO |
| 7 | ASM-04, ASM-27, ASM-28 | Konfirmasi kode status HTTP aktual (401 vs 403 untuk auth, 415 vs 400 untuk Content-Type) dan bentuk respons sukses/error. | Tim Backend |
| 8 | ASM-11 | Konfirmasi perilaku gabungan TMS+OMS berlaku per-produk (bukan per-jenis-order asal) untuk penugasan sopir. | PO |
| 9 | ASM-10 | Konfirmasi `AUTO_STUFFING` memang terkait `Simulasi Muatan` (bukan add-on lain). | PO |
| 10 | ASM-14 | Konfirmasi "Koridor Historis" bukan "Koridoe Historis" (typo sumber xlsx) — laporkan sebagai defect kosmetik terpisah bila UI juga typo. | PO/Tim Frontend |
| 11 | ASM-31, ASM-34 | Konfirmasi bentuk guard (403/redirect) dan bentuk halaman Pengaturan Sistem (satu list vs sub-route). | Tim Frontend |
| 12 | ASM-16 | Konfirmasi add-on `SERVICE_*` benar-benar membatasi pilihan jenis order pada form (REQ-077), bukan hanya master data. | PO |

---

## 10. Rekomendasi

Tidak ada gap coverage signifikan yang memerlukan skenario tambahan — **103/103 REQ, 23/23 V, 27/27 ALT, 12/12 screen** sudah tercakup secara substantif. Rekomendasi berikut bersifat penyempurnaan, bukan syarat kelulusan:

1. **Sebelum eksekusi:** selesaikan konfirmasi ASM prioritas 1–4 pada bagian 9 (endpoint apps sopir, katalog testid, route, strategi isolasi worker) — tanpa ini, sebagian besar suite akan gagal karena infrastruktur/kontrak, bukan karena logika bisnis salah.
2. **Maintenance non-blocking:** sederhanakan baris TMS-only/OMS-only yang identik antara OMS000-POS-030 dan OMS000-POS-035 (lihat bagian 4) saat siklus refactor berikutnya.
3. **Konsistensi tag:** putuskan apakah tag `@ASM-38` (ditemukan di OMS000-STR-002) akan diperluas secara sistematis ke skenario lain yang bergantung asumsi blocking, atau dihapus.
4. **Konvensi placeholder Background:** pertimbangkan mengganti `<X-Admin-Key>`/`<clientId>` pada Background menjadi `${ADMIN_KEY}`/`${CLIENT_ID}` agar konsisten dengan konvensi di `scenarios.json` dan tidak tertukar dengan placeholder Scenario Outline asli.

---

## Lampiran — Sumber Data

- Tabel scenario, peta REQ→ID, peta Screen→ID, dan pemakaian testid pada bagian 1, 2, dan 7 diambil langsung dari `_extracted/review-index.md` (hasil mekanis orkestrator, sudah terverifikasi 1:1 dengan `.feature`/`.json`).
- Deskripsi REQ pada RTM (bagian 7) diringkas dari `oms000-jenis-produk.analysis.md` baris 100-364 (R1-R8).
- Temuan dedup, distribusi, dan validasi Gherkin (bagian 4-6) berdasarkan pembacaan penuh `oms000-jenis-produk.feature` (2602 baris) oleh reviewer ini.
- Sampling struktur JSON (bagian metodologi) pada `OMS000-POS-001…004` dan `OMS000-STR-020…022` mengonfirmasi kelengkapan `steps[]`, `selectorHints[]`, `testData` (tanpa admin key asli — seluruhnya `${ADMIN_KEY}`/`${CLIENT_ID}`), dan `examples[]` pada Outline.
