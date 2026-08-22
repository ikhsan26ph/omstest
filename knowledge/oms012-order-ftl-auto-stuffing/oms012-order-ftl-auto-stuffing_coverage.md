# Coverage & QA Review — oms012-order-ftl-auto-stuffing

> Reviewer: QA Reviewer (verifikatif)
> Tanggal review awal: 2026-08-18
> **Revisi rev-2: 2026-08-18** — lihat §0 Catatan Revisi
> Sumber diverifikasi:
> - `oms012-order-ftl-auto-stuffing.analysis.md` (76 REQ, 59 validation rules, 80 AC)
> - `oms012-order-ftl-auto-stuffing.ui-inventory.md` (39 layar/state, M-01..M-25, FND-01..FND-15)
> - `oms012-order-ftl-auto-stuffing.feature` (rev-2: **151 skenario** Gherkin, 1344 baris)
> - `oms012-order-ftl-auto-stuffing.scenarios.json` (rev-2: **151 entri**, 657 baris, field `revision: "rev-2"`)

---

## 0. Catatan Revisi (rev-2, 2026-08-18)

Generator merilis revisi "rev-2" pada `.feature` dan `.scenarios.json` untuk menutup 2 temuan **Medium** dari review awal. Reviewer memverifikasi klaim tersebut **langsung dari isi kedua file** (bukan dari klaim `revisionNotes` semata). Hasil verifikasi:

| Temuan awal | Klaim generator | Hasil verifikasi independen | Status |
|---|---|---|---|
| **F-02** (FND-11 — Detail Order Multidrop salah menampilkan "Tipe Pengiriman: Normal") | Skenario baru `SCN-0151` ditambahkan | ✅ **Terverifikasi.** `.feature` baris 1337–1343: `@SCN-0151 @negative @priority-medium @REQ-076 @REQ-009 @screen-detail-order`, judul "Detail Order Multidrop harus menampilkan Tipe Pengiriman Multidrop", assert `Then sistem menampilkan "Tipe Pengiriman : Multidrop"` + `And sistem tidak menampilkan "Tipe Pengiriman : Normal"`. `.scenarios.json` baris 651–654: entri `SCN-0151` dengan `category:"negative"`, `priority:"medium"`, `requirements:["REQ-076","REQ-009"]`, `screen:"Detail Order"`, `expected` berisi assert `text`→`"Multidrop"` dan assert `hidden` untuk nilai salah `"Tipe Pengiriman : Normal"`, `testData.bugCandidate:"FND-11"`. **Tag, judul, kategori, prioritas, requirements 1:1 cocok feature↔JSON.** | ✅ **RESOLVED** |
| **F-06** (M-22 diklaim ter-assert padahal tidak) | `SCN-0123` kini meng-assert placeholder M-22; ditambah `summary.messageTraceability` | ✅ **Terverifikasi.** `.feature` baris 1096–1103: `SCN-0123` kini punya step tambahan `Then field "Alasan Pembatalan" menampilkan placeholder "Tuliskan alasan pembatalan order"` sebelum step lain. `.scenarios.json` baris 539–542: `expected` `SCN-0123` kini memuat entri baru `{"assert":"placeholder","target":"Field Alasan Pembatalan (M-22)",...,"value":"Tuliskan alasan pembatalan order"}` — assert type `"placeholder"` juga ditambahkan ke `assertVocabulary` (baris 39). `summary.messageTraceability` (baris 28–36) baru ditambahkan, memetakan seluruh M-01..M-25 → SCN-ID, termasuk `"M-22": ["SCN-0123"]`. | ✅ **RESOLVED** |

### Verifikasi tambahan (angka & validitas JSON)
- **Total skenario**: JSON `summary.total = 151` (baris 23) — **cocok** dengan penghitungan manual: 150 (rev-1, terverifikasi sebelumnya) + 1 (`SCN-0151`, satu-satunya skenario baru, tidak ada penghapusan/penggantian ID lain).
- **Distribusi kategori**: JSON `byCategory: {positive:79, negative:43, edge:14, stress:15}` (baris 24) — **cocok**: `SCN-0151` bertag `@negative`, sehingga negative naik dari 42→43, kategori lain tidak berubah (79+43+14+15=151 ✓).
- **Distribusi prioritas**: JSON `byPriority: {high:90, medium:48, low:13}` — **cocok**: `SCN-0151` berprioritas medium (47→48), sisanya tetap.
- **`bugCandidateScenarios`**: bertambah dari 9 → 10 entri, `"SCN-0151"` ditambahkan di akhir array (baris 37) — **cocok** dengan §4 review awal.
- **Validitas JSON**: struktur `scenarios[]` ditutup dengan benar di baris 655 (`]`) dan objek root di baris 656 (`}`), tidak ada trailing comma/bracket mismatch — **JSON tetap valid & parse-able**.
- **ID unik & berurutan**: `SCN-0001`..`SCN-0151` tanpa gap/duplikat (dicek pada seluruh entri baru + spot-check batas akhir file).

**Kesimpulan revisi:** Kedua klaim generator **lolos verifikasi 100%** dengan bukti langsung dari isi file (bukan hanya dari `revisionNotes`). Kedua temuan Medium dari review awal dinyatakan **RESOLVED**. Tidak ditemukan regresi baru akibat revisi (skenario SCN-0001..SCN-0150 tidak berubah selain SCN-0123).

---

## 1. Ringkasan Eksekutif

**Verdict: LAYAK RILIS (Pass)** — setelah rev-2, kedua temuan **Medium** yang tersisa dari review awal (F-02 gap FND-11, F-06 klaim message-coverage M-22 tidak akurat) telah **RESOLVED** dan diverifikasi langsung dari isi file. Artefak `.feature` dan `.scenarios.json` konsisten satu sama lain, 76/76 REQ ter-cover minimal 1 skenario, kategori/tag valid secara sintaks, dan JSON valid/parse-able dengan struktur seragam. Sisa temuan berseverity **Low** (varian layar Multidrop/Multipoint pada beberapa step lain, boundary edge tambahan, dan 2 FND kosmetik yang belum dikonversi) **tetap open** — tidak menghalangi rilis, direkomendasikan sebagai perbaikan lanjutan non-blocking.

### Angka kunci (rev-2, diverifikasi ulang manual dari isi file)

| Kategori | Klaim summary JSON (rev-2) | Hasil verifikasi manual | Status |
|---|---|---|---|
| positive | 79 | 79 (tidak berubah dari rev-1) | ✅ cocok |
| negative | 43 | 43 (naik dari 42, +1 `SCN-0151`) | ✅ cocok |
| edge | 14 | 14 (tidak berubah) | ✅ cocok |
| stress | 15 | 15 (tidak berubah) | ✅ cocok |
| **Total** | **151** | **151** | ✅ cocok |
| REQ tercover (≥1 skenario) | 76/76 | 76/76 (tidak berubah; `SCN-0151` menambah cakupan REQ-076 & REQ-009, bukan REQ baru) | ✅ cocok |
| ID unik & berurutan | SCN-0001..SCN-0151 | Terverifikasi tidak ada duplikat/ID hilang | ✅ cocok |
| Pesan M-01..M-25 diklaim "messagesCovered" | 25/25 | **25/25 kini benar-benar tervalidasi** — M-22 sekarang di-assert via `SCN-0123` (assert type `placeholder`) | ✅ **cocok (resolved)** |
| Bug candidate scenarios | 10 (dari 15 FND) | 10 terverifikasi ada & konsisten dgn FND; FND-11 kini tercover via `SCN-0151` | ✅ **cocok (resolved)** |

### Validasi sintaks & konsistensi (ringkas, rev-2)
- **Gherkin**: valid — blok baru `# P. TAMBAHAN REV-2 - TEMUAN DESAIN LANJUTAN (FND-11)` + `SCN-0151` mengikuti struktur & konvensi tag yang sama dengan skenario lain. `SCN-0123` yang direvisi tetap Given/When/Then valid, hanya menambah satu `Then` di awal (assertion placeholder).
- **JSON**: valid, parse-able, field baru (`revision`, `revisionNotes`, `messageTraceability`, assert type `"placeholder"` pada `assertVocabulary`) tidak merusak skema entri lain. `selectorHints` pada `SCN-0151` dan `SCN-0123` (revisi) **tidak kosong**.
- **1:1 feature ⇄ json**: `SCN-0151` dan `SCN-0123` (revisi) dicek silang penuh — id, judul, category↔tag, priority↔tag, requirements↔tag `@REQ-*`, assertion baru — **tidak ada mismatch**.

---

## 2. Temuan Review (dengan Severity) — Status Terkini

| # | Severity | Area | Temuan | Status | Rekomendasi |
|---|---|---|---|---|---|
| F-01 | **Low** | Sintaks/Tooling | 2 blok `Scenario Outline` (SCN-0020/21/22, SCN-0042/43) tidak memiliki tag `@SCN-XXXX` per baris di `.feature` — ID hanya ada di kolom `id` tabel `Examples`. | **OPEN** | Dokumentasikan konvensi ini di README runner test, atau gunakan tag granular per baris jika toolchain CI butuh. |
| F-02 | ~~Medium~~ | Coverage — kandidat bug | ~~FND-11 (Detail Order Multidrop menampilkan `Tipe Pengiriman : Normal`) tidak dikonversi jadi skenario.~~ | ✅ **RESOLVED (rev-2)** | Ditutup oleh `SCN-0151` (@negative, REQ-076/REQ-009, bugCandidate FND-11) — terverifikasi ada di `.feature` baris 1337–1343 dan `.scenarios.json` baris 651–654, konsisten 1:1. |
| F-03 | **Medium** | Coverage — varian layar | Beberapa layar/state UI Inventory terkait varian Multidrop/Multipoint belum disentuh skenario spesifik: **SCR-31** (Step 2 distribusi Multidrop, REQ-031), **SCR-38** (Step 3 Multipoint 2× "Lihat Detail"), **SCR-28/34/39** (Step 4 Review struktur multi-card), **SCR-36** (Edit Order Multidrop). *(SCR-30/35 Detail Order Multipickup/Multidrop sebagian tertutup oleh SCN-0151 untuk sisi Multidrop, namun Multipickup — SCR-30 — masih belum ada skenario Detail Order spesifik.)* | **OPEN** | Tambahkan 4–5 skenario tambahan (lihat §5 Rekomendasi rev-1, masih berlaku) untuk menutup varian yang belum tersentuh. |
| F-04 | **Low** | Coverage — boundary | Nilai Barang minimum valid (`>0`), Harga `=0`, Tanggal Permintaan Muat `=hari ini` belum diuji sbg edge "diterima". | **OPEN** | Tambahkan 2–3 skenario `@edge`. |
| F-05 | **Low** | Coverage — FND lain | FND-06 (label WhatsApp tidak konsisten Normal vs Multi) dan FND-07 (kurung tutup hilang pada teks rincian Asuransi) belum dikonversi jadi skenario regression-guard. | **OPEN** | Opsional, prioritas rendah. |
| F-06 | ~~Medium~~ | Akurasi klaim (JSON summary) | ~~`summary.messagesCovered` mengklaim M-01..M-25 semua di-assert, namun M-22 tidak ditemukan di skenario manapun.~~ | ✅ **RESOLVED (rev-2)** | Ditutup oleh revisi `SCN-0123` (assert type baru `"placeholder"`, value `"Tuliskan alasan pembatalan order"`) + penambahan `summary.messageTraceability` yang secara eksplisit memetakan `"M-22": ["SCN-0123"]`. Terverifikasi konsisten di `.feature` baris 1096–1103 dan `.scenarios.json` baris 539–542. |
| F-07 | **Info** | Distribusi kategori | Rasio edge+stress (14+15=29, ~19,2% dari 151) tetap **proporsional**. Tidak berubah oleh rev-2 (skenario baru berkategori negative). | **OPEN (info, tidak wajib ditindaklanjuti)** | Tidak wajib. |
| F-08 | **Info** | Dedup | Tidak ditemukan skenario duplikat/tumpang-tindih signifikan dari 151 skenario (150 rev-1 + `SCN-0151` yang unik, tidak overlap dengan skenario Detail Order lain). | **OPEN (info)** | Tidak ada aksi merge. |
| F-09 | **Info** | Konsistensi asumsi | Penanganan status order via teks desain (ASM-D09) tetap konsisten di rev-2. | **OPEN (info)** | Tidak ada aksi. |

**Ringkasan status:** 2 Medium **RESOLVED**, 1 Medium tersisa **OPEN** (F-03 — gap varian layar multi, bukan blocker rilis karena REQ induk tetap tercover via varian lain), 3 Low **OPEN**, 3 Info **OPEN**.

---

## 3. Requirements Traceability Matrix (RTM) — Lengkap 76 REQ (rev-2)

Legenda status: **Full** = ≥1 positive & ≥1 negative/edge/stress terkait; **Partial** = hanya 1 sisi kategori atau hanya varian sebagian (mis. hanya tipe Normal); **None** = tidak ada.

> Baris yang berubah pada rev-2 ditandai **[rev-2]** di kolom Catatan.

| REQ | Deskripsi Singkat | AC Terkait | SCN-ID | Kategori | Status | Catatan |
|---|---|---|---|---|---|---|
| REQ-001 | Cakupan modul: Normal/Multipickup/Multidrop/Multipoint FTL + Auto Stuffing | *(tidak ada AC spesifik — requirement umum)* | SCN-0001 | positive | Partial | Requirement umum tanpa AC dedicated di analysis.md |
| REQ-002 | Sistem mengacu spesifikasi Order FTL TMS (4 step, manual & batch) | *(tidak ada AC spesifik)* | SCN-0004 | positive | Partial | Hanya cek tombol "Batch Order" tampil |
| REQ-003 | Step 2 beda dari TMS: barang dari Master Barang, bukan manual | AC-008 | SCN-0005 | negative | Full | |
| REQ-004 | Auto Stuffing aktif hanya jika add-on dibeli & FTL/FCL | AC-001, AC-002, AC-003 | SCN-0001, 0002, 0003 | positive, negative, negative | Full | |
| REQ-005 | Logic Auto Stuffing pakai tools eksisting | AC-080 | SCN-0081, 0085 | positive, stress | Full | |
| REQ-006 | Step 4: visualisasi muatan via pop up | AC-053 | SCN-0006, 0102 | positive, positive | Partial | |
| REQ-007 | Step 1 identik TMS: field wajib | AC-004 | SCN-0004, 0007, 0019, 0020, 0021, 0022, 0023, 0024 | positive, negative, edge, stress-none | Full | |
| REQ-008 | Data Pengirim/Penerima auto-draft Master Droppoint | AC-005 | SCN-0008, 0009 | positive, negative | Full | |
| REQ-009 | Rule cascading & minimal baris per tipe pengiriman | AC-006 | SCN-0013–0018, **0151** | positive×3, negative×3, negative | Full | **[rev-2]** `SCN-0151` menambah dimensi negative (Detail Order Multidrop, kandidat bug FND-11) selain fokus cascading Step 1 |
| REQ-010 | Validasi wajib & fungsi button Step 1 | AC-007 | SCN-0010, 0011, 0012, 0026 | positive, negative×3 | Full | |
| REQ-011 | Barang dipilih dari Master Barang via modal | AC-008 | SCN-0005, 0027, 0036, 0145 | negative, positive, negative, stress | Full | |
| REQ-012 | Pencarian by kode/nama barang | AC-009 | SCN-0028, 0029, 0030, 0145 | positive, negative, edge, stress | Full | |
| REQ-013 | Multi-select checkbox | AC-010 | SCN-0031, 0033, 0038 | positive, edge, stress | Full | |
| REQ-014 | Label "Sudah Ditambahkan" kontekstual per armada | AC-011 | SCN-0032, 0033, 0034 | positive, edge, positive | Full | |
| REQ-015 | Counter jumlah barang terpilih | AC-010 | SCN-0031 | positive | Partial | |
| REQ-016 | Button Batal & Simpan pada modal | AC-012 | SCN-0035, 0036, 0037 | positive, negative, negative | Full | |
| REQ-017 | Field read-only dari Master Barang | AC-013 | SCN-0039 | positive | Partial | |
| REQ-018 | Field Jumlah wajib per baris | AC-014 | SCN-0040, 0041, 0042, 0043, 0044, 0045 | positive, negative×3, edge, stress | Full | |
| REQ-019 | Nilai Barang wajib kondisional (asuransi aktif) | AC-015, AC-016, AC-017 | SCN-0046, 0047, 0048 | positive, positive, negative | Full | |
| REQ-020 | Checkbox Asuransi per armada, seluruh barang | AC-016 | SCN-0046, 0049 | positive, edge | Full | |
| REQ-021 | Nomor DO opsional, multi via koma, chip | AC-018, AC-019 | SCN-0050, 0051, 0052, 0053 | positive, positive, edge, stress | Full | |
| REQ-022 | Hapus baris barang via icon | AC-020 | SCN-0054 | positive | Partial | |
| REQ-023 | Alert kapasitas informatif, tidak blocking | AC-024 | SCN-0045, 0058 | stress, positive | Full | |
| REQ-024 | Pesan alert sesuai 3 kondisi kapasitas | AC-021, AC-022, AC-023 | SCN-0055, 0056, 0057 | positive, positive, edge | Full | M-05 (gabungan) tidak ada referensi desain — FND-12 |
| REQ-025 | Helper error + border error saat field wajib kosong | AC-014, AC-017 | SCN-0041, 0042, 0043, 0048, 0049 | negative×4, edge | Full | |
| REQ-026 | Informasi Data Unit dari Step 1 | AC-025 | SCN-0059, 0060 | positive, negative | Full | SCN-0060 = kandidat bug FND-02 |
| REQ-027 | Floating button tetap saat scroll | AC-026 | SCN-0063 | positive | Partial | |
| REQ-028 | FAB ikon default, label saat hover | AC-027 | SCN-0064 | positive | Partial | |
| REQ-029 | Hitung Ulang Armada butuh ≥1 barang | AC-028, AC-029 | SCN-0065, 0066, 0067 | negative, positive, stress | Full | |
| REQ-030 | Distribusi armada: isi 1 penuh dulu, lalu pindah | AC-039 | SCN-0081, 0085, 0146 | positive, stress, stress | Full | |
| REQ-031 | Multi: dibagi rata antar alamat, sisa ke alamat pertama | AC-040, AC-041 | SCN-0082, 0083, 0084 | positive, edge, positive | Partial | Hanya Multipickup & Multipoint diuji; Multidrop tidak (F-03, masih open) |
| REQ-032 | Button Batal/Draf/Sebelumnya/Selanjutnya Step 2 identik TMS | AC-042 | SCN-0061, 0062 | positive, positive | Partial | |
| REQ-033 | Drawer: Total Kubikasi & Berat | AC-029 | SCN-0066, 0068 | positive, positive | Partial | |
| REQ-034 | Drawer: Jenis Pengiriman dari Step 1 | AC-030 | SCN-0068 | positive | Partial | |
| REQ-035 | Drawer: 3 rekomendasi armada + indikator | AC-031 | SCN-0069 | positive | Partial | |
| REQ-036 | Label "Paling Efisien" tepat 1 | AC-032 | SCN-0070 | positive | Partial | |
| REQ-037 | Jenis/Jumlah Armada dapat diubah di drawer | AC-033, AC-034 | SCN-0071, 0072, 0073 | positive, positive, edge | Full | |
| REQ-038 | Visualisasi 3D update otomatis | AC-033, AC-034 | SCN-0071, 0072, 0074, 0077 | positive×3, stress | Full | |
| REQ-039 | "Terapkan ke Order" menerapkan Jenis/Jumlah/penempatan | AC-035 | SCN-0075, 0149 | positive, stress | Full | |
| REQ-040 | Sinkronisasi dua arah Step 1 ⇄ Step 2 | AC-036 | SCN-0075 | positive | Partial | |
| REQ-041 | Batal drawer tidak mengubah data | AC-037 | SCN-0076 | positive | Partial | |
| REQ-042 | Visualisasi Terbaru tanpa ubah pilihan armada | AC-038 | SCN-0078, 0079, 0080 | positive, negative, positive | Full | SCN-0079 = kandidat bug FND-05 |
| REQ-043 | Step 3 field vendor & harga identik TMS | AC-043 | SCN-0086, 0087, 0089, 0097 | positive, positive, negative, negative | Full | |
| REQ-044 | Waktu Perjalanan textfield/text-only kondisional rute | AC-044, AC-045 | SCN-0090, 0091 | positive, negative | Full | |
| REQ-045 | Ringkasan alamat multi: label + text link | AC-046 | SCN-0092, 0093 | positive, positive | Partial | Multipoint (2 link) tidak diuji spesifik (F-03) |
| REQ-046 | Komponen harga opsional via checkbox | AC-043 | SCN-0094 | positive | Partial | |
| REQ-047 | Asuransi = % × Total Nilai Barang, masuk Total Harga | AC-047, AC-048 | SCN-0095, 0096 | positive, negative | Full | |
| REQ-048 | Validasi wajib & button Step 3 identik TMS | AC-049 | SCN-0087, 0088 | positive, negative | Full | |
| REQ-049 | Step 4 read-only ringkasan Step 1–3 | AC-050 | SCN-0099 | positive | Partial | |
| REQ-050 | Data Barang Review sesuai struktur Step 2 | AC-051 | SCN-0100, 0101, 0106 | positive, positive, edge | Partial | Varian Multi (SCR-28/34/39) belum (F-03) |
| REQ-051 | Label "Diasuransikan" per armada | AC-052 | SCN-0101 | positive | Partial | |
| REQ-052 | Button visualisasi pada card Data Barang | AC-053 | SCN-0006, 0102 | positive, positive | Partial | |
| REQ-053 | Button Step 4 identik TMS; Simpan → Menunggu Penugasan | AC-054 | SCN-0103, 0105, 0148 | positive, negative, stress | Full | |
| REQ-054 | 9 status order valid | AC-055 | SCN-0107, 0144 | positive, stress | Full | Nama status desain ≠ spec (FND-13), ditangani via ASM-D09 |
| REQ-055 | Definisi status 1–4 (draft) | AC-056 | SCN-0025, 0109 | positive, positive | Partial | |
| REQ-056 | Definisi status lanjutan (Ditugaskan dst.) | AC-057, AC-067 | SCN-0110 | positive | Partial | |
| REQ-057 | Status draft tersimpan via "Simpan ke Draf" dari step manapun | AC-056 | SCN-0025, 0062, 0098, 0104, 0108, 0150 | positive×5, negative | Full | |
| REQ-058 | Shipper dapat ubah order: draft s.d. Menunggu Penugasan | AC-058 | SCN-0111, 0147 | positive, stress | Full | |
| REQ-059 | Tidak dapat ubah setelah Ditugaskan | AC-059 | SCN-0112, 0119 | negative, negative | Partial | |
| REQ-060 | Jenis/Tipe Pengiriman locked di Edit Order | AC-060 | SCN-0113 | positive | Partial | |
| REQ-061 | Jenis Armada/Jumlah/Data Barang/Vendor tetap dapat diubah | AC-061 | SCN-0114, 0117, 0118 | positive, negative, edge | Full | SCN-0117=FND-09, SCN-0118=FND-10 |
| REQ-062 | Batal & Simpan Edit Order munculkan konfirmasi | AC-062 | SCN-0115, 0116 | positive, positive | Partial | |
| REQ-063 | Order dibatalkan: draft s.d. Ditugaskan | AC-063, AC-064 | SCN-0120, 0121, 0122 | positive, positive, negative | Full | |
| REQ-064 | Pembatalan oleh admin shipper, bukan vendor | AC-065 | SCN-0126 | negative | Partial | |
| REQ-065 | Alasan Pembatalan wajib diisi | AC-066, AC-067 | SCN-0120, **0123**, 0124, 0125 | positive, negative, edge, stress | Full | **[rev-2]** `SCN-0123` kini juga meng-assert placeholder M-22 ("Tuliskan alasan pembatalan order") — F-06 RESOLVED, tidak lagi ada gap message-coverage pada REQ ini |
| REQ-066 | Aksi status draft: Detail/Lanjutkan/Batalkan/Riwayat | AC-068 | SCN-0109, 0128 | positive, positive | Partial | |
| REQ-067 | Aksi status Menunggu Penugasan: +Edit | AC-069 | SCN-0129 | positive | Partial | |
| REQ-068 | Aksi status Ditugaskan: +Lihat No. Perjalanan, -Edit | AC-070 | SCN-0130, 0131 | positive, negative | Full | SCN-0131=FND-01 |
| REQ-069 | Riwayat Pembatalan (toolbar) vs Riwayat Perubahan (per-order) | AC-071, AC-072 | SCN-0127, 0132, 0133 | positive, positive, edge | Full | |
| REQ-070 | No. Perjalanan untuk public tracking | AC-079 | SCN-0141, 0142 | positive, negative | Full | |
| REQ-071 | No. Perjalanan auto-generate, jumlah = armada | AC-073 | SCN-0136, 0137, 0143 | positive, negative, stress | Full | SCN-0137=FND-08 |
| REQ-072 | No. Perjalanan hanya FTL & FCL | AC-074 | SCN-0139 | negative | Partial | |
| REQ-073 | "Lihat No. Perjalanan" tampil hanya setelah Ditugaskan | AC-075 | SCN-0130, 0134, 0135 | positive, positive, negative | Full | |
| REQ-074 | Pop up Data No. Perjalanan: No. Perjalanan/Nopol/Jenis Armada | AC-076 | SCN-0134 | positive | Partial | |
| REQ-075 | Icon copy No. Perjalanan | AC-077 | SCN-0138 | positive | Partial | |
| REQ-076 | No. Perjalanan juga di Detail Order | AC-078 | SCN-0140, **0151** | positive, negative | **Full** | **[rev-2]** Naik dari Partial→**Full**: `SCN-0151` menambah sisi negative (Detail Order Multidrop harus tampilkan "Tipe Pengiriman : Multidrop", kandidat bug FND-11) — F-02 RESOLVED |

**Ringkasan status RTM (rev-2):** Full = **43 REQ** (naik dari 42; REQ-076 naik dari Partial→Full), Partial = **33 REQ** (turun dari 34), None = 0 REQ. Sisa "Partial" pada umumnya requirement yang secara alami hanya punya sisi positive (mis. "field tampil", "label tampil"). Perhatian sisa hanya pada REQ-031, REQ-045, REQ-050 (terkait varian layar Multidrop/Multipoint yang belum diuji spesifik, F-03 — masih open, non-blocking).

---

## 4. Kandidat Bug Desain-vs-Spec (dari FND-01..FND-15) — rev-2

| FND | Deskripsi | Dikonversi jadi SCN? | Status |
|---|---|---|---|
| FND-01 | Action menu status Ditugaskan memuat "Order Kembali" (tidak ada di REQ-068) | ✅ SCN-0131 | Tercover |
| FND-02 | Step 2 menampilkan 3 card Armada padahal Jumlah Armada = 2 | ✅ SCN-0060 | Tercover |
| FND-03 | Modal Pilih Barang tanpa tombol close (×) | ✅ SCN-0037 | Tercover |
| FND-04 | Subjudul panel Visualisasi Terbaru identik dgn drawer Hitung Ulang | ➖ Tidak perlu SCN (panduan desain selector) | N/A — wajar diabaikan |
| FND-05 | Panel Visualisasi Terbaru punya tombol "Terapkan ke Order" (melanggar REQ-042) | ✅ SCN-0079 | Tercover |
| FND-06 | Label WhatsApp tidak konsisten ("No. WhatsApp PIC" vs "Nomor WhatsApp PIC") | ❌ Tidak dikonversi | **Gap minor (F-05, open)** |
| FND-07 | Rincian Asuransi: kurung tutup hilang pada teks | ❌ Tidak dikonversi | **Gap minor (F-05, open)** |
| FND-08 | Dua No. Perjalanan bernilai identik pada desain | ✅ SCN-0137 | Tercover |
| FND-09 | Edit Order tidak menampilkan FAB Hitung Ulang/Visualisasi Terbaru | ✅ SCN-0117 | Tercover |
| FND-10 | Edit Order Multipickup pakai heading "Kontainer" bukan "Armada" | ✅ SCN-0118 | Tercover |
| FND-11 | Detail Order Multidrop menampilkan "Tipe Pengiriman: Normal" (seharusnya Multidrop) | ✅ **SCN-0151 (rev-2)** | **Tercover — RESOLVED rev-2** |
| FND-12 | Pesan gabungan M-05 tidak ada referensi desain | ✅ SCN-0057 (dgn asumsi eksplisit) | Tercover |
| FND-13 | Nama status desain ≠ spec ("Isi Data Dasar", "Terkirim") | ➖ Ditangani sistemik via ASM-D09 | Tercover (metode berbeda) |
| FND-14 | Penomoran grup armada duplikat pada desain (Step 3/Review multi) | ✅ SCN-0106 | Tercover |
| FND-15 | Sidebar aktif salah pada 036/050 (cosmetic) | ➖ Tidak relevan untuk skenario fungsional | N/A — wajar diabaikan |

**Kesimpulan (rev-2):** 14/15 FND kini tertangani memadai (10 via skenario dedicated + 2 diabaikan wajar + 2 ditangani sistemik). Hanya FND-06 dan FND-07 yang tersisa sebagai gap opsional berseverity Low (F-05, non-blocking).

---

## 5. Rekomendasi Tindak Lanjut (Status Terkini)

### 5.1 Sebelumnya wajib (Medium) — kini **SELESAI**
1. ~~Perbaiki `summary.messagesCovered` / tambahkan assertion M-22~~ → ✅ **Selesai rev-2** (`SCN-0123` + `messageTraceability`).
2. ~~Tambahkan skenario baru untuk FND-11~~ → ✅ **Selesai rev-2** (`SCN-0151`).

### 5.2 Masih disarankan (Low/Medium sisa, non-blocking)
3. **[F-03, Medium]** Tambahkan skenario distribusi Multidrop di Step 2 (REQ-031, mirip SCN-0082/83 tapi untuk `Drop Off`) — menutup SCR-31.
4. **[F-03]** Tambahkan skenario Step 3 Multipoint dengan 2 link "Lihat Detail" (REQ-045) — menutup SCR-38.
5. **[F-03]** Tambahkan 1 skenario Step 4 Review khusus tipe Multipickup/Multidrop (struktur sub-card `Pick Up 1..3` / `Drop Off 1..2`) — menutup SCR-28/34.
6. **[F-03]** Tambahkan 1 skenario Edit Order tipe Multidrop (mirip SCN-0118) — menutup SCR-36; juga pertimbangkan 1 skenario Detail Order Multipickup (SCR-30) sebagai pasangan `SCN-0151`.
7. **[F-04, Low]** Tambahkan boundary-edge: Nilai Barang minimum valid (`Rp1`), Harga `= 0`, Tanggal Permintaan Muat `= hari ini`.
8. **[F-05, Low, opsional]** Regression-guard untuk FND-06 (label WhatsApp per varian) dan FND-07 (partial-match teks rincian Asuransi).
9. **[F-01, Low, opsional]** Dokumentasikan konvensi ID pada Scenario Outline untuk toolchain CI.

### 5.3 Tidak perlu tindakan
- Dedup: tidak ditemukan skenario yang perlu di-merge (F-08), termasuk `SCN-0151` yang unik terhadap set skenario Detail Order lainnya.
- Struktur JSON/Gherkin: valid pada rev-1 maupun rev-2, tidak ada error sintaks yang menghambat eksekusi test.
- Proporsi edge/stress: tetap memadai dan proporsional (F-07).

---

## 6. Catatan Metodologi Review
- Review awal: seluruh 150 skenario `.feature` (1327 baris) & 150 entri `.scenarios.json` (638 baris) dibaca penuh (bukan sampling).
- Review rev-2: perubahan/penambahan (`SCN-0151` baru, revisi `SCN-0123`, header `revision`/`revisionNotes`/`messageTraceability`, `assertVocabulary`) diverifikasi **langsung dari isi file** (baris spesifik dikutip di §0), bukan hanya dari klaim `revisionNotes` generator — termasuk cross-check tag↔field, kesesuaian judul, dan integritas struktur JSON (penutupan array/objek).
- RTM dibangun dengan mencocokkan tag `@REQ-XXX` per skenario terhadap tabel Requirements (76 baris) di `analysis.md`, kolom AC diisi via reverse-lookup dari kolom "Traceability" pada tabel Acceptance Criteria (80 baris) di `analysis.md`.
