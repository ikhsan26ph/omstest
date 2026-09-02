# Coverage Review — oms022-public-tracking-improve

- **Pipeline stage:** 4/4 — scenario-reviewer
- **Tanggal review:** 2026-09-01
- **File yang direview:** `oms022-public-tracking-improve.analysis.md`, `oms022-public-tracking-improve.feature`, `oms022-public-tracking-improve.scenarios.json`

## Verdict Ringkas

**PASS dengan catatan minor (non-blocking).** Test suite berkualitas tinggi dan komprehensif:
- 1:1 alignment ID **feature ↔ JSON: 98 = 98** (POS-001..030, NEG-001..025, EDG-001..027, STR-001..016) — semua ID berurutan tanpa gap/duplikat ID.
- Distribusi kategori sesuai klaim: positive 30, negative 25, edge 27, stress 16 = 98.
- Matriks 13-baris event→tahap stepper (R3) **direplikasi 100% akurat** — `OMS022-POS-028` dibandingkan baris demi baris terhadap tabel matriks di `analysis.md`, seluruh 13 baris (termasuk collapse +2 pada baris 1 & 7, no-op pada baris 6/8/12) cocok persis.
- Kasus jebakan inti modul (collapse REQ-012, no-op REQ-013/014, divergensi stepper-vs-riwayat) **eksplisit diuji dan diberi label jelas** — bahkan ada kasus ganda-no-op (`EDG-022`, Multipoint 3×3).
- Tidak ditemukan skenario duplikat yang layak dibuang; overlap yang ada bersifat disengaja (defense-in-depth).
- Ditemukan sejumlah **gap tagging** (bukan gap substansi pengujian) dan **beberapa inkonsistensi tag antara `.feature` dan `.scenarios.json`** yang perlu diperbaiki sebelum RTM dianggap 100% akurat untuk audit formal.

---

## 1. Temuan Dedup (dilaporkan, tidak dihapus dari sumber)

Tidak ada duplikat murni (assertion identik, kategori sama, tanpa nilai tambah). Overlap yang ditemukan bersifat *intentional*:

| Pasangan/Grup | Alasan overlap | Rekomendasi |
|---|---|---|
| `POS-028` (Outline 13-baris) vs `POS-006/007/008/009/010/012/013/014/015/016` dan `NEG-010/012/021` | `POS-028` adalah *matrix cross-check* ringkas (hanya assert 3 state stepper); 13 skenario naratif lain menguji baris yang sama dengan assertion lebih kaya (jumlah entri riwayat, AC spesifik). | Pertahankan keduanya — pola *smoke-matrix + narrative detail* adalah praktik baik untuk regresi cepat. |
| `POS-024` vs `NEG-014` vs `EDG-020` | Ketiganya pakai precondition sama (`LKL3300112244`, Normal, tanpa event) tapi fokus beda: POS-024 = struktur halaman lengkap + empty state; NEG-014 = assertion negatif stepper; EDG-020 = persistensi setelah reload berulang. | Bukan duplikat — pertahankan, opsional dokumentasikan relasi. |
| `NEG-003` vs `NEG-004` | Precondition sama (resi tidak ditemukan) — NEG-003 fokus pesan+nilai input, NEG-004 fokus ketiadaan komponen (stepper/riwayat/summary). | Overlap kecil, bisa digabung tapi tidak wajib. |
| `EDG-016` vs `STR-010` | Pola sama (klik ganda cepat pada tombol Lacak, cek tidak ada duplikasi hasil) — beda skala (2× vs 10×) dan tipe data (Normal vs Multi Pick Up 3). | Eskalasi edge→stress yang sah, pertahankan. |
| `NEG-019` vs `STR-012` vs `STR-013` | Tiga mode kegagalan berbeda (HTTP 500, timeout lambat, network terputus) berbagi pola assertion (`tracking-error` + tombol "Coba Lagi"). | Bukan duplikat — tiga *failure mode* berbeda, valid semua dipertahankan. |
| `POS-016` vs `STR-006` | Multipoint 2×2 (logic) vs Multipoint 10×10 (skala). | Variant skala, bukan duplikat. |

---

## 2. Gap Coverage

### 2a. Gap substansi (tidak ditemukan yang blocking)
Semua REQ-001..027, V-01..13, ALT-01..10, dan UI-T00..T10 **tersentuh minimal satu skenario**.

### 2b. Gap tagging — REQ tanpa pasangan positive+negative eksplisit
Sifatnya *soft gap*: perilaku negatif/positifnya **sudah teruji secara substansi**, hanya saja tag `@REQ-xxx` yang presisi tidak dipasang pada skenario yang relevan (sering karena REQ dipecah jadi "mekanisme" R3 vs "tipe pengiriman" R4).

| REQ | Kategori yang hilang | Catatan |
|---|---|---|
| REQ-001 | negative | Struktural/baseline TMS (ASM-002 — spec TMS tidak tersedia), sulit punya "negative" natural. |
| REQ-002, REQ-005 | positive | Closed-set rule, inherently diuji via negative (NEG-008/009). Bisa tambah tag `@REQ-002`/`@REQ-005` pada `POS-018`/`POS-021` (yang secara substansi memvalidasi hanya 2 jenis event). |
| REQ-006 | positive | Kardinalitas diuji positif luas (`POS-018/021`, `STR-004/006/007`) tapi tanpa tag `@REQ-006`. |
| REQ-007 | positive (tag) | AC-007.1/007.2 diuji di `POS-017`/`POS-020` tapi tag `@REQ-007` tidak dipasang di sana — hanya `NEG-025` yang membawa tag ini. |
| REQ-008 | negative | Structural label-check, negative counterpart tumpang tindih dengan REQ-002/V-05. |
| REQ-009, REQ-011 | negative | Negative counterpart secara substansi ada tapi tertag REQ-010/REQ-016, bukan REQ-009/011. |
| REQ-012 | negative | Aturan collapse inherently positive-only, wajar tanpa negative. |
| REQ-017, REQ-018, REQ-019 | negative (tag) | Substansi negative ada (mis. `NEG-013` untuk pola REQ-018, `NEG-012` untuk pola REQ-019) tapi tertag REQ-010/REQ-014, bukan REQ tipe-spesifik. |
| REQ-022 | negative | Kardinalitas entri muat diuji negatif via `NEG-024` tapi tertag REQ-006/V-07, bukan REQ-022. |
| REQ-025 | negative | Serupa — substansi ada di bawah tag lain. |
| REQ-026, REQ-027 | negative | Bersifat invariant/consistency check, `EDG-024` cukup relevan tapi berkategori edge bukan negative. |

**Rekomendasi**: tambahkan tag REQ tambahan (bukan skenario baru) pada skenario yang sudah ada sesuai tabel di atas, khususnya `POS-017`/`POS-020` → `@REQ-007`, `POS-018` → `@REQ-002 @REQ-006`, `POS-021` → `@REQ-005 @REQ-025` — cukup evaluasi bila strict RTM per-REQ diperlukan untuk audit compliance.

### 2c. Gap ALT flow tagging
`ALT-04` (Pengiriman Normal) dan `ALT-05` (Multi Pick Up 2) **tidak pernah muncul sebagai tag eksplisit** di `.feature`, meskipun tipe pengiriman ini adalah yang paling banyak diuji di seluruh suite (`POS-006/007` untuk Normal, `POS-008/009/010` untuk Multi Pick Up 2). Klaim `summary.altFlowsCovered` di JSON yang menyebut ALT-01..10 "covered" **tidak sepenuhnya akurat secara tag-level** untuk ALT-04/ALT-05 (meski secara fungsional tercakup).

### 2d. Inkonsistensi tag `.feature` vs `.scenarios.json` (perlu diperbaiki)
Beberapa skenario memiliki field `requirement`/`tags` JSON yang **tidak identik** dengan tag Gherkin di `.feature` — melanggar prinsip 1:1 (ASM-037):

| ID | Temuan |
|---|---|
| `OMS022-POS-011` | JSON `requirement: ["REQ-013","REQ-010"]`, tapi `.feature` hanya bertag `@REQ-013` (tidak ada `@REQ-010`). |
| `OMS022-POS-014` | JSON `tags` menyertakan `@ALT-08`, tapi `.feature` **tidak** memiliki tag `@ALT-08` pada skenario ini. |
| `OMS022-POS-027` | JSON `requirement: ["REQ-001"]`, tapi `.feature` **sama sekali tidak** memiliki tag `@REQ-xxx` (hanya `@ASM-025`). |
| `OMS022-EDG-009` | JSON `requirement` menyertakan `REQ-022`, tapi `.feature` hanya bertag `@REQ-013` (`AC-022.5` disebut di body, tapi tag REQ-022 tidak dipasang). |

**Rekomendasi**: sinkronkan field `requirement`/`tags` JSON dengan tag aktual di `.feature` (atau sebaliknya, tambahkan tag yang hilang di `.feature`), agar RTM otomatis dari JSON tidak menyesatkan.

### 2e. Minor: inkonsistensi teks judul
`OMS022-STR-007` — judul di `.feature` menyebut **"100 entri"**, judul di `.json` menyebut **"101 entri"**. Data aktual (50 muat + 50 bongkar + 1 sintetis = 101 entri total) membuat judul JSON lebih akurat; judul feature under-count. Tidak memengaruhi assertion (keduanya expect muat=50, bongkar=50, sintetis=1), murni kosmetik.

---

## 3. Kecukupan Edge & Stress

**Cukup memadai** (27 edge + 16 stress = 43/98 = 44% dari total, proporsi sehat untuk modul dengan logic komputasi kompleks). Cakupan meliputi: trim/whitespace, case sensitivity, panjang ekstrem, injection (SQL/XSS/template/path traversal), non-ASCII/zero-width, boundary transisi tahap, monotonisitas, persistensi reload, keunikan entri sintetis, invariant konsistensi stepper↔riwayat, volume besar (20/100 alamat, 10×10, 50×50), concurrency (10 sesi sama, 2 sesi beda resi), race condition (klik ganda/beruntun, ganti resi cepat), timeout/network failure + recovery, viewport responsif.

**Gap konkret yang direkomendasikan ditambahkan** (opsional, prioritas rendah–sedang):
1. **Output-encoding pada teks berasal dari backend** — `EDG-004` hanya menguji *input* No. Resi terhadap payload berbahaya (sisi client-search). Belum ada skenario yang menguji apakah **keterangan/alamat pada entri Riwayat** (data dari seed/backend, mis. lokasi drop point) di-*escape* dengan benar saat berisi karakter HTML/script — surface injection yang berbeda dari input pencarian. Rekomendasi: tambah 1 edge scenario "entri riwayat dengan keterangan/lokasi mengandung karakter HTML tidak dieksekusi sebagai markup".
2. **Stress isolasi data pada skala lebih besar** — `STR-009` hanya menguji 2 sesi paralel resi berbeda. Untuk memperkuat V-13 pada skala produksi, bisa ditambah varian dengan lebih banyak sesi berbeda resi (mis. 10 sesi, masing-masing resi unik) untuk menangkap kebocoran cache/CDN yang mungkin tidak muncul pada N kecil (relevan dengan ASM-034).

Tidak ada gap kritis yang blocking; kedua rekomendasi bersifat penguatan, bukan prasyarat rilis.

---

## 4. Validasi Sintaks Gherkin

- Struktur `Feature` → deskripsi (as a/I want/so that) → `Background` (2 step, dipakai bersama) → daftar `Scenario`/`Scenario Outline` per kategori dengan header komentar pemisah — **valid dan konsisten**.
- **18 `Scenario Outline`** teridentifikasi, seluruhnya memiliki blok `Examples:` dengan header kolom yang cocok jumlah kolom pada setiap baris data (diverifikasi silang dengan `testData.examples[]` di JSON — jumlah baris & kolom identik). Field `isOutline: true` di JSON konsisten dipasang pada seluruh 18 ID ini, dan hanya pada ID ini.
- Tag format konsisten: `@kategori` (positive/negative/edge/stress), `@priority-{high|medium|low}`, `@REQ-xxx`, `@AC-xxx.x`, `@V-xx`, `@ALT-xx`, `@ASM-xxx`, `@screen-public-tracking`, diakhiri tag ID unik `@OMS022-{POS|NEG|EDG|STR}-NNN`. Tidak ditemukan tag malformed/typo selama pembacaan penuh.
- Tidak memakai keyword `Rule:` (Gherkin 6) untuk mengelompokkan R1–R6 dari analysis.md; sebagai gantinya memakai comment header per kategori — pilihan gaya yang sah, bukan error.
- Penggunaan Background dikonfirmasi bekerja benar: skenario seperti `NEG-001` langsung mulai dari `When` tanpa mengulang `Given` lokasi halaman, mengandalkan Background — konsisten di seluruh file.
- Token ekspansi whitespace (`{sp}`, `{tab}`, `{nl}`, `{zwsp}`) didokumentasikan jelas di komentar section EDGE dan `testData.tokenMap` — solusi valid untuk keterbatasan Gherkin Examples yang memangkas whitespace literal (ASM-031).

**Kesimpulan validasi Gherkin: LULUS**, tanpa cacat struktural.

---

## 5. Requirements Traceability Matrix (RTM)

Status: **F** = full (≥1 positive & ≥1 negative bertag REQ eksplisit), **P** = partial (hanya salah satu kategori bertag REQ eksplisit — substansi tetap teruji, lihat §2b).

| REQ | Deskripsi singkat | Scenario IDs (positive / negative / edge / stress) | Status |
|---|---|---|---|
| REQ-001 | Halaman identik baseline TMS Shipper | Pos: POS-002, POS-027 · Str: STR-016 | P (no neg) |
| REQ-002 | Hanya 2 event OMS | Neg: NEG-008, NEG-009 | P (no pos) |
| REQ-003 | Akses publik tanpa login | Pos: POS-001,003,026 · Neg: NEG-005,022 · Edg: EDG-014,016 · Str: STR-003,008,014 | F |
| REQ-004 | Read-only, tanpa mutasi | Pos: POS-004 · Neg: NEG-006,007,015 | F |
| REQ-005 | Event tertutup 2 jenis | Neg: NEG-008 | P (no pos) |
| REQ-006 | Kardinalitas event = alamat | Neg: NEG-024 · Str: STR-015 | P (no pos) |
| REQ-007 | Urutan muat sebelum bongkar | Neg: NEG-025 (AC diuji juga di POS-017/020 tanpa tag) | P (no pos tag) |
| REQ-008 | Stepper 3 tahap | Pos: POS-005, POS-029 | P (no neg) |
| REQ-009 | Muat pertama→Pick Up | Pos: POS-008, POS-028 · Edg: EDG-006 | P (no neg) |
| REQ-010 | Muat terakhir→On Delivery | Pos: POS-009, POS-028 · Neg: NEG-013 | F |
| REQ-011 | Bongkar terakhir→Delivered | Pos: POS-007,010, POS-028 | P (no neg) |
| REQ-012 | Collapse (1 alamat muat) | Pos: POS-006,012, POS-028 · Edg: EDG-007,026 | P (inheren) |
| REQ-013 | No-op muat tengah | Pos: POS-011, POS-028 · Neg: NEG-010 · Edg: EDG-006,009,022 | F |
| REQ-014 | No-op bongkar non-terakhir | Pos: POS-028 · Neg: NEG-012,021 · Edg: EDG-008,022 · Str: STR-005 | F |
| REQ-015 | Progresi monoton | Pos: POS-025 · Neg: NEG-018 · Edg: EDG-010,011 · Str: STR-011 | F |
| REQ-016 | State awal (belum ada event) | Pos: POS-024 · Neg: NEG-014 · Edg: EDG-020 | F |
| REQ-017 | Normal — matriks tipe | Pos: POS-006,007, POS-028 | P (no neg) |
| REQ-018 | Multi Pick Up 2 — matriks | Pos: POS-008,009,010, POS-028 | P (no neg) |
| REQ-019 | Multi Drop 2 — matriks | Pos: POS-012,013, POS-028 · Edg: EDG-008 | P (no neg) |
| REQ-020 | Multipoint — matriks | Pos: POS-014,015,016, POS-028 · Neg: NEG-021 · Edg: EDG-022 · Str: STR-006 | F |
| REQ-021 | Riwayat kronologis | Pos: POS-017 · Neg: NEG-020 · Str: STR-006,007 | F |
| REQ-022 | Entri muat = jml alamat | Pos: POS-018 · Str: STR-004 | P (no neg) |
| REQ-023 | Entri sintetis auto-inject | Pos: POS-019 · Neg: NEG-011 · Edg: EDG-007,019 | F |
| REQ-024 | Entri sintetis tepat 1× & posisi benar | Pos: POS-019,020 · Neg: NEG-017 · Edg: EDG-012,019 | F |
| REQ-025 | Entri bongkar = jml alamat | Pos: POS-021 · Str: STR-005 | P (no neg) |
| REQ-026 | Keterangan + timestamp | Pos: POS-022 · Edg: EDG-018,025 | P (no neg) |
| REQ-027 | Konsistensi stepper↔riwayat | Pos: POS-023,030 · Edg: EDG-024 | P (no neg) |

**V-rules**: V-01(NEG-001,002,EDG-015,027) · V-02(POS-026,NEG-002,EDG-001) · V-03(NEG-016,EDG-002..005,STR-001,002) · V-04(NEG-003,004,019,023,EDG-003..005,STR-001) · V-05(POS-005,NEG-009) · V-06(NEG-008) · V-07(POS-018,NEG-024,EDG-019,STR-004,015) · V-08(POS-019,NEG-011,017,EDG-019,STR-004,015) · V-09(POS-021,STR-005) · V-10(NEG-018,EDG-010) · V-11(NEG-010,013) · V-12(NEG-012,021) · V-13(POS-001,NEG-005,015,EDG-013,STR-008,009) — semua terpenuhi ≥1 skenario.

**ALT-flows**: ALT-01(NEG-001) · ALT-02(NEG-003,004) · ALT-03(POS-024,NEG-020) · ALT-04(tidak eksplisit ditag — fungsional tercakup POS-006,007) · ALT-05(tidak eksplisit ditag — fungsional tercakup POS-008,009,010) · ALT-06(NEG-010) · ALT-07(NEG-012) · ALT-08(NEG-021) · ALT-09(EDG-017) · ALT-10(POS-030).

**Screens UI-T00..T10**: seluruh 11 layar tersentuh — UI-T00(POS-001,NEG-022,EDG-023) · UI-T01(POS-026,EDG-001,014,015) · UI-T02(NEG-001,002,EDG-003,004,005,STR-001,002) · UI-T03(POS-027,EDG-016,STR-010,012) · UI-T04(NEG-003,004,EDG-002,003,017) · UI-T05(POS-002,003,004,NEG-007,EDG-013,STR-003,014,016) · UI-T06(POS-005..016,028,029, dst) · UI-T07(POS-017..022, dst) · UI-T08(POS-024,NEG-020,EDG-020) · UI-T09(NEG-019,STR-012,013) · UI-T10(NEG-005,006,007,008,009,015,022,STR-009).

---

## 6. Rekomendasi Prioritas

1. **Sinkronkan tag `.feature` ↔ `requirement`/`tags` JSON** untuk `POS-011`, `POS-014`, `POS-027`, `EDG-009` (§2d) — perbaikan data, bukan penambahan skenario.
2. **Tambahkan tag REQ pelengkap** pada skenario existing sesuai §2b (mis. `@REQ-007` di `POS-017`/`POS-020`) agar RTM presisi per-REQ mencapai "F" penuh tanpa menambah skenario baru.
3. **Opsional**: tag eksplisit `@ALT-04`/`@ALT-05` pada `POS-006/007` dan `POS-008/009/010` agar klaim `altFlowsCovered` di JSON akurat.
4. **Rekomendasi tambahan (opsional, non-blocking)**: 1 edge scenario baru untuk output-encoding teks berasal-backend pada Riwayat; 1 stress scenario opsional untuk isolasi data pada >2 sesi paralel resi berbeda.
5. Perbaiki inkonsistensi kosmetik judul `STR-007` (100 vs 101 entri).
