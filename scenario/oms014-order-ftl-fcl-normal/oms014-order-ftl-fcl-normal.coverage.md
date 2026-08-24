# Coverage Review — oms014-order-ftl-fcl-normal

> **Tahap pipeline:** 4/4 — qa-reviewer (verifikatif)
> **Sumber:** `oms014-order-ftl-fcl-normal.analysis.md` (32 REQ, UI Inventory S-00..S-14, checklist AS-OFF A1-A15), `oms014-order-ftl-fcl-normal.feature` (170 scenario), `oms014-order-ftl-fcl-normal.scenarios.json` (sidecar 1:1)
> **Metode:** pembacaan penuh ketiga file (analysis 1060 baris, feature 1755 baris, JSON 2139 baris) dan cross-check manual tag `@REQ-*`/`@screen-*` pada `.feature` terhadap field `requirements`/`screens` pada `.json` serta terhadap Acceptance Criteria di `.analysis.md`.

---

## Addendum — Perbaikan Diterapkan (2026-08-23, pasca-review)

Rekomendasi **#1–#5** telah diaplikasikan ke `.feature` dan `.scenarios.json` oleh orchestrator. Suite kini berisi **173 scenario (positive 73 / negative 45 / edge 37 / stress 18; P1 58 / P2 74 / P3 41)**; proporsi edge+stress = 55/173 = **31,8%**.

| Rekomendasi | Tindakan |
|---|---|
| #1 Bypass Step 4 & Detail Order | **+ OMS014-NEG-041** (deep-link & shortcut di Step 4 Review) dan **+ OMS014-NEG-042** (Detail Order) — padanan NEG-020/021. |
| #2 Minimum alamat Multidrop/Multipoint | **+ OMS014-NEG-043** (Multidrop) dan **+ OMS014-NEG-044** (Multipoint, kedua sisi alamat) — padanan NEG-033. |
| #3 Perluasan POS-060 | Assertion absen A8 (`Berat/Ruang Terpakai`), A9 (`koli melebihi kapasitas`), `load-visualization-canvas`, `capacity-progress` ditambahkan; Examples diperluas 2 → **8 kombinasi** jenis×tipe. Kolom Edit Order pada tabel AS-OFF di bawah kini setara Step 2/4/Detail. |
| #4 Sinkronisasi tag | Verifikasi menyeluruh (bukan sampling) menemukan **32 tag-line** drift — semuanya disinkronkan (arah: `.feature` mengikuti `.json`). `NEG-027` kini ber-tag `@REQ-022`; `NEG-039` dibiarkan tanpa tag REQ dan field `requirements`-nya dikosongkan + `requirementsNote` (ASM-016). Drift kini **nol** (tervalidasi skrip). |
| #5 Merge & rekategorisasi | **POS-063 digabung ke POS-018** (assertion REQ-023+REQ-008 digabung, ID POS-063 pensiun). **EDG-004 → NEG-045** (konvensi: nilai `0` pada field wajib = negative, selaras NEG-009; ID EDG-004 pensiun). |

**Perubahan status RTM** (tabel RTM di bawah = kondisi saat review awal; daftar per-REQ terkini ada di `summary.requirementCoverage` pada `.scenarios.json`):

| REQ | Status awal | Status kini | Sebab |
|---|---|---|---|
| REQ-022 | Partial | **Covered** | NEG-027 kini ber-tag @REQ-022 (P/N/E/S = 5/1/2/2) |
| REQ-025 | Partial | **Covered** | + NEG-041 (2/1/0/1) |
| REQ-027 | Partial | **Covered** | + NEG-042 (3/1/1/0) |
| REQ-031 | Partial | **Covered** | + NEG-043 (3/1/0/0) |
| REQ-032 | Partial | **Covered** | + NEG-044 (2/1/1/1) |

**Ringkasan status kini: Covered = 21, Partial = 11 (mayoritas rendah/by-design), Gap = 0.** Rekomendasi #6–#8 (tag NEG-027 sudah tercakup di #4; prioritas EDG-038; helper matcher kustom; negative ringan REQ-018/REQ-019) **belum** diterapkan dan tetap terbuka.

---

## Ringkasan Review

**Verdict: PASS WITH NOTES** *(rekomendasi #1–#5 telah diterapkan — lihat Addendum di atas; angka pada bagian-bagian di bawah ini adalah kondisi saat review awal atas 170 scenario)*

Kunci angka:

| Metrik | Nilai |
|---|---|
| Total scenario | 170 (positive 74 / negative 40 / edge 38 / stress 18) — sesuai klaim orchestrator |
| Proporsi edge+stress | 56/170 = **32.9%** (≥ target 25%) ✅ |
| REQ dengan status **Covered** | **16 / 32** |
| REQ dengan status **Partial** | **16 / 32** (0 di antaranya berupa gap total — semua REQ punya ≥1 scenario positive) |
| REQ dengan status **Gap** (0 scenario) | **0 / 32** |
| Layar S-00..S-14 ter-cover | 15/15 ✅ (+ halaman `Pengaturan Sistem`, ASM-030) |
| Duplikat/overlap signifikan ditemukan | **2 pasangan** (1 rekomendasi merge, 1 rekomendasi penyelarasan kategori) + 1 overlap yang **dijustifikasi** (bukan duplikat) |
| Pelanggaran struktur Gherkin murni (Feature/Background/Outline/Examples) | **0** |
| Temuan tagging (scenario tanpa `@REQ-*`, drift tag vs JSON) | **10** item (2 scenario tanpa tag REQ + 8 scenario dengan drift `@REQ`/`@screen` vs field JSON) |
| Assertion non-standar (pseudo-matcher di JSON, perlu helper kustom) | **~16 langkah** di 13 scenario (EDG/STR dominan) |

**Kesimpulan umum:** Kualitas keseluruhan suite **tinggi** — struktur Gherkin valid, ID stabil, RTM dapat ditelusuri, distribusi kategori sehat, dan checklist AS-OFF (Auto Stuffing OFF) mendapat perhatian eksplisit di Step 2/Step 4/Detail Order/Edit Order. Tidak ada REQ yang sama sekali tidak ter-cover. Namun ditemukan sejumlah **gap spesifik dan dapat ditindaklanjuti** (bukan blocker rilis, tetapi signifikan untuk kelengkapan regresi): kurangnya test bypass/deep-link untuk Step 4 & Detail Order (paralel dengan yang sudah ada di Step 2), checklist AS-OFF di Edit Order yang lebih tipis dibanding tiga layar lain, tidak adanya test "minimal alamat" untuk Multidrop/Multipoint (padahal Multipickup sudah punya), serta drift antara tag `@REQ-*`/`@screen-*` di `.feature` dengan field `requirements`/`screens` di `.json` pada sejumlah scenario. Rekomendasi diberikan di bagian akhir.

---

## Requirements Traceability Matrix

Kolom **Scenario IDs** dihitung dari tag `@REQ-xxx` yang **benar-benar tertulis** pada `.feature` (sumber otoritatif untuk validasi Gherkin), bukan dari field `requirements` di `.json` (lihat § Temuan Validasi Gherkin untuk daftar drift antara keduanya). P/N/E/S = jumlah scenario positive/negative/edge/stress.

| REQ | Deskripsi singkat | Scenario IDs | P/N/E/S | Status |
|---|---|---|---|---|
| REQ-001 | Cakupan FTL/FCL × 4 tipe pengiriman | POS-003,004,005,011; NEG-037,038; EDG-001,028; STR-012 | 4/2/2/1 | **Covered** |
| REQ-002 | Auto Stuffing aktif = default | POS-008,009 | 2/0/0/0 | Partial — tidak ada negative (state/default fact, severity rendah) |
| REQ-003 | Toggle Auto Stuffing (ubah, persist) | POS-007,010; NEG-028; EDG-022; STR-018 | 2/1/1/1 | **Covered** |
| REQ-004 | Efek toggle OFF di Step2/4/Detail | POS-057,060,064; NEG-020,021 | 3/2/0/0 | **Covered** (tanpa edge/stress eksplisit ber-tag) |
| REQ-005 | Basis komponen identik ON/OFF | POS-070 | 1/0/0/0 | Partial — hanya 1 scenario (FTL Normal saja) |
| REQ-006 | Floating "Hitung Ulang" absen | POS-057,069; NEG-020 | 2/1/0/0 | **Covered** (tipis — lihat catatan under-tagging) |
| REQ-007 | Floating "Visualisasi Terbaru" absen | POS-057; NEG-021 | 1/1/0/0 | **Covered** (tipis) |
| REQ-008 | Tidak ada distribusi otomatis antar unit | POS-018,061,062,063,064; EDG-019,021; STR-001 | 5/0/2/1 | Partial — tidak ada scenario ber-tag `@negative` |
| REQ-009 | Tidak ada pembagian otomatis antar alamat | POS-065,066,067,068; EDG-020,035; STR-002 | 4/0/2/1 | Partial — tidak ada `@negative` |
| REQ-010 | Pengisian barang manual per unit | POS-041,071; NEG-008,009; EDG-002,017; STR-003,004 | 2/2/2/2 | **Covered** |
| REQ-011 | Pengisian manual per kombinasi alamat | POS-012..016; EDG-032; STR-002 | 5/0/1/1 | Partial — tidak ada `@negative` |
| REQ-012 | Wizard 4 step | POS-002,011,030,031; NEG-001; EDG-021,034; STR-008,014 | 4/1/2/2 | **Covered** |
| REQ-013 | Master Barang Step 2 | POS-019,020; NEG-029,030,031,032,035; EDG-024,025; STR-003,011 | 2/5/2/2 | **Covered** (kuat) |
| REQ-014 | Asuransi & Nilai Barang | POS-021,022,023; NEG-010,011; EDG-004,005,026,027 | 3/2/4/0 | **Covered** |
| REQ-015 | Nomor DO | POS-024,025,026; EDG-006,007,008; STR-005 | 3/0/3/1 | Partial — tidak ada `@negative` (field opsional, wajar) |
| REQ-016 | Alert kapasitas informatif, non-blocking | POS-027,028,029; EDG-003,015,016; STR-004(shared) | 3/0/3/1 | **Covered** — negative memang **tidak relevan by design** (REQ eksplisit "tidak memblokir") |
| REQ-017 | Validasi field wajib | POS-006,011; NEG-002..009,012..019,036 (17); EDG-009,010,011; STR-006 | 2/17/3/1 | **Covered** (paling kuat) |
| REQ-018 | No. Perjalanan | POS-046; EDG-031; STR-017 | 1/0/1/1 | Partial — tidak ada `@negative` |
| REQ-019 | Status Order | POS-047,048; STR-008,012(shared) | 2/0/0/1 | Partial — tidak ada `@negative` maupun `@edge` |
| REQ-020 | Hak Edit | POS-049,050,051,056(shared),060; NEG-022,023,026,040; EDG-037; STR-009,015 | 4/4/1/2 | **Covered** (kuat) |
| REQ-021 | Pembatalan Order | POS-052,053; NEG-024,025,026; STR-015(shared) | 2/3/0/1 | **Covered** |
| REQ-022 | Aksi Daftar Order (Filter, dsb.) | POS-001,054,055,056,073; EDG-029,030; STR-007,016 | 5/0/2/2 | Partial — tidak ada scenario `@negative` yang tag-nya `@REQ-022` (lihat catatan NEG-027/NEG-039) |
| REQ-023 | Data Unit read-only, tanpa hitung ulang | POS-017,018; NEG-034; EDG-019(shared); STR-001(shared) | 2/1/1/1 | **Covered** |
| REQ-024 | Simpan ke Draf / Lanjutkan Pengisian | POS-042,043,048(shared); NEG-040(shared); EDG-022(shared),023,033; STR-010,018(shared) | 2/1/3/2 | **Covered** |
| REQ-025 | Step 4 tanpa elemen Auto Stuffing | POS-038,058; STR-013 | 2/0/0/1 | Partial — tidak ada `@negative`/`@edge` (lihat gap bypass Step 4) |
| REQ-026 | Step 4 Data Barang apa adanya | POS-039,040,041,045; EDG-009(shared),017,028; STR-006(shared),013(shared) | 4/0/3/2 | Partial — tidak ada `@negative` |
| REQ-027 | Detail Order konsisten tanpa Auto Stuffing | POS-044,045,059; EDG-038 | 3/0/1/0 | Partial — tidak ada `@negative`/`@stress` (lihat gap bypass Detail Order) |
| REQ-028 | Step 3 rekap dari input manual Step 2 | POS-032,033,034,035; EDG-012,013,014,036 | 4/0/4/0 | Partial — tidak ada `@negative`/`@stress` (severity rendah, sifat kalkulasi) |
| REQ-029 | Tipe Normal | POS-012(shared),044(shared),074 | 3/0/0/0 | Partial — hanya positive, tidak ada negative/edge |
| REQ-030 | Tipe Multipickup | POS-013(shared),036,068; NEG-033; EDG-020(shared),035(shared) | 3/1/2/0 | **Covered** |
| REQ-031 | Tipe Multidrop | POS-014(shared),037,072 | 3/0/0/0 | Partial — **tidak ada negative padanan NEG-033** (lihat rekomendasi) |
| REQ-032 | Tipe Multipoint | POS-015(shared),067(shared); EDG-018; STR-002(shared) | 2/0/1/1 | Partial — **tidak ada negative padanan NEG-033** (lihat rekomendasi) |

**Ringkasan status:** Covered = 16 (001,003,004,006,007,010,012,013,014,016,017,020,021,023,024,030); Partial = 16 (002,005,008,009,011,015,018,019,022,025,026,027,028,029,031,032); Gap = 0.

Catatan tingkat keparahan Partial (agar tidak disalahartikan sebagai kegagalan besar):
- **Rendah / by-design** (tidak perlu tindakan mendesak): REQ-002, REQ-005, REQ-015, REQ-016(justified), REQ-026, REQ-028, REQ-029.
- **Sedang** (secara fungsional sudah teruji tetapi tag `@negative` hilang — rekomendasi: retag atau tambah scenario khusus): REQ-008, REQ-009, REQ-011, REQ-018, REQ-019, REQ-022.
- **Signifikan / disarankan ditambah** (gap fungsional nyata, bukan sekadar tagging): **REQ-025, REQ-027** (tidak ada test bypass/deep-link untuk Step 4 & Detail Order — padahal Step 2 sudah punya NEG-020/NEG-021 untuk requirement sejenis REQ-004), **REQ-031, REQ-032** (tidak ada test "hapus alamat sampai kurang dari minimum ditolak" padahal Multipickup sudah punya NEG-033).

---

## Coverage Layar & Checklist AS-OFF

### Layar S-00 s.d. S-14

Seluruh 15 layar pada UI Inventory (S-00 Kerangka Aplikasi s.d. S-14 Edit Order) memiliki ≥1 scenario, dikonfirmasi dari tag `@screen-*` pada `.feature` maupun field `screens` pada `.json` (keduanya konsisten untuk pemetaan layar, berbeda dengan field `requirements` yang punya drift — lihat bagian Gherkin). Halaman `Pengaturan Sistem` (lokasi toggle, ASM-030) juga ter-cover (POS-007, POS-008, POS-010, NEG-028, STR-018).

Layar dengan kedalaman tipis (wajar mengingat kompleksitas rendah, bukan gap): S-02 modal-no-perjalanan (3), S-09 modal-alamat (2, keduanya positive), S-11 modal-draf (3), S-13 modal-batalkan (2, sudah punya 1 negative).

### Checklist AS-OFF A1–A15 di Step 2 / Step 4 / Detail Order / Edit Order

| Item | Step 2 | Step 4 | Detail Order | Edit Order |
|---|---|---|---|---|
| A1 `Hitung Ulang Armada` | ✅ POS-057, NEG-020, NEG-034 | n/a (tidak pernah muncul di desain ON) | n/a | ✅ POS-060 |
| A2 `Hitung Ulang Kontainer` | ✅ POS-057 (regex gabungan) | n/a | n/a | ✅ POS-060 (regex gabungan) |
| A3 `Visualisasi Terbaru` | ✅ POS-057, NEG-021, POS-069, EDG-018, EDG-021 | n/a | n/a | ✅ POS-060 |
| A4 `Visualisasi Muatan` (tombol) | n/a (tombolnya "Visualisasi Terbaru", beda nama) | ✅ POS-058, STR-013 | ✅ POS-059, EDG-038 | ✅ POS-060 |
| A5 `Visualisasi Muatan Saat Ini` | ✅ POS-057 (regex), NEG-021 | n/a | n/a | tidak diuji (drawer ini hanya dapat dipicu dari Step 2, wajar tidak diuji ulang) |
| A6 subtitle "Simulasi ulang kebutuhan…" | ✅ NEG-020 | tidak diuji | tidak diuji | tidak diuji |
| A7 `Paling Efisien` | ✅ POS-057 | tidak diuji | tidak diuji | tidak diuji |
| A8 `Berat Terpakai`/`Ruang Terpakai` | ✅ POS-057 | ✅ POS-058, STR-013 | ✅ POS-059 | ❌ **tidak diuji** (gap) |
| A9 `n koli melebihi kapasitas` | ✅ POS-057 | ✅ POS-058 | ✅ POS-059 | ❌ **tidak diuji** (gap) |
| A10 `dialokasikan ke unit ini` | ✅ POS-057 | tidak diuji | tidak diuji | tidak diuji |
| A11 `Drag: putar 360°…` | ✅ POS-057 | tidak diuji | tidak diuji | tidak diuji |
| A12 `Terapkan ke Order` | ✅ POS-057, NEG-020 | tidak diuji | tidak diuji | tidak diuji |
| A13 `Pilih Jenis Armada/Kontainer` | ✅ POS-057 | tidak diuji | tidak diuji | tidak diuji |
| A14 `Berat/Kubikasi Maksimal 1 Armada/Kontainer` | ✅ POS-057 | tidak diuji | tidak diuji | tidak diuji |
| A15 menu sidebar `Simulasi Muatan` | Tidak diuji otomatis di layar manapun — **keputusan terdokumentasi** (ASM-026/ASM-037): diverifikasi manual di luar suite | | | |
| Testid `capacity-progress` | ✅ POS-057 | ✅ POS-058 | ✅ POS-059(tidak eksplisit di POS-059 tapi ada di EDG-038) | ❌ **tidak diuji** (gap) |
| Cakupan kombinasi jenis×tipe (8 kombinasi FTL/FCL × 4 tipe) | ✅ POS-057 (8/8) | ✅ POS-058 (8/8) | ✅ POS-059 (8/8) | ❌ **hanya 2/8** (POS-060 cuma varian FTL-Armada & FCL-Kontainer, tidak menguji Multipickup/Multidrop/Multipoint pada Edit Order) |

**Temuan utama** *(✅ teratasi — POS-060 diperluas, lihat Addendum)*: Checklist AS-OFF di **Edit Order lebih tipis** dibanding Step 2/Step 4/Detail Order pada dua aspek:
1. A8 (`Berat Terpakai`/`Ruang Terpakai`), A9 (`n koli melebihi kapasitas`), dan testid `capacity-progress` **tidak diverifikasi absen** di Edit Order (POS-060), padahal S-14 UI Inventory secara eksplisit menyatakan elemen AS-OFF wajib absen juga di Edit Order.
2. POS-060 hanya menguji 2 kombinasi (FTL/FCL tipe default), berbeda dengan POS-057/058/059 yang menguji seluruh 8 kombinasi jenis×tipe pengiriman. Multipickup/Multidrop/Multipoint pada Edit Order tidak pernah divalidasi bebas elemen Auto Stuffing.

A6, A7, A10-A14 memang secara desain hanya muncul di dalam drawer Step 2 (tidak pernah tergambar di Step4/Detail/Edit pada mode ON sekalipun), sehingga ketiadaan pengujian di 3 layar lain **bukan gap** — kecuali untuk kebutuhan "no alternate route" (AC-004.3) yang idealnya juga diuji di Step 4/Detail Order/Edit Order via deep-link (lihat gap REQ-025/027 di atas).

---

## Temuan Duplikasi

1. **OMS014-POS-018 vs OMS014-POS-063 — kandidat merge.** Precondition, Given, dan langkah When keduanya identik (Step 2 FTL Normal 2 armada terisi → Sebelumnya → ubah Jumlah Armada jadi 3 → Selanjutnya). Perbedaan hanya pada baris `Then`: POS-018 menegaskan REQ-023 (Data Unit ter-update, jumlah blok = 3), POS-063 menegaskan REQ-008 (Armada 3 kosong, Armada 1 tidak berubah). Karena setup ~90% sama, direkomendasikan **digabung menjadi satu scenario** dengan gabungan assertion (tanpa kehilangan cakupan REQ-008 maupun REQ-023), mengurangi 1 scenario redundan tanpa mengurangi coverage.
2. **OMS014-NEG-009 vs OMS014-EDG-004 — inkonsistensi kategorisasi.** Keduanya menguji pola yang identik secara konsep: nilai numerik `0` pada field wajib-bersyarat diperlakukan sebagai "kosong" dan memicu pesan `"<Field> harus diisi"` — NEG-009 untuk field `Jumlah` (dikategorikan **negative**), EDG-004 untuk field `Nilai Barang` (dikategorikan **edge**). Direkomendasikan **menyelaraskan kategori** (pilih salah satu konvensi: `0` = negative test atau `0` = edge/boundary test) agar konsisten di seluruh suite — bukan untuk dihapus, karena dua-duanya menguji field berbeda dan tetap perlu dipertahankan.
3. **OMS014-POS-041 vs OMS014-EDG-017 — overlap yang dijustifikasi (bukan duplikat, tidak perlu tindakan).** Keduanya menggunakan skenario dasar yang sama (order 3 unit, hanya sebagian terisi, unit lain harus tetap kosong) dan sama-sama ber-tag REQ-026+REQ-010, namun memverifikasi checkpoint siklus-hidup yang **berbeda**: POS-041 di Step 2 (empty state) + Step 4 (Review), EDG-017 setelah **disimpan** hingga ke Detail Order. Ini konsisten dengan AC-026.5/AC-027.4 yang menuntut kesesuaian di kedua titik (Step 4 **dan** Detail Order), sehingga overlap ini disengaja dan bermanfaat (deteksi regresi pasca-simpan), bukan pemborosan.

**Kesimpulan dedup** *(✅ poin 1 & 2 teratasi — merge POS-018+POS-063 dan rekategorisasi EDG-004→NEG-045, lihat Addendum)*: tidak ditemukan duplikat murni (exact duplicate — steps & assertion 100% sama). Dua pasangan di atas (poin 1 dan 2) direkomendasikan untuk ditindaklanjuti; poin 3 dicatat untuk transparansi saja.

---

## Temuan Validasi Gherkin

### Struktur (PASS, 0 pelanggaran)
- Satu `Feature` tunggal dengan judul jelas dan narasi "Sebagai/Saya ingin/Agar" — sesuai.
- Satu `Background` berisi 4 `Given` (login, toggle OFF, master data, kuota) — dipakai konsisten sebagai prasyarat global, tidak ada Scenario yang mengulang Background secara redundan.
- Urutan Given→When→Then pada seluruh scenario yang diperiksa logis; scenario "assertion-only" (Given+Then tanpa When, mis. POS-001, POS-005, POS-038) valid secara Gherkin untuk verifikasi state.
- Seluruh `Scenario Outline` (POS-003,011,017,046,048,056,057,058,059,060; NEG-022,023,024; EDG-011,012,024) memiliki blok `Examples` dengan placeholder `<...>` yang **cocok persis** dengan header kolom — tidak ditemukan placeholder yatim atau kolom Examples tak terpakai.
- Tidak ditemukan step yatim (step yang mereferensikan variabel/placeholder tak terdefinisi) maupun keyword yang salah tempat.
- Penamaan ID `OMS014-<KATEGORI>-NNN` 100% konsisten dengan tag kategori (`@positive`→POS, `@negative`→NEG, `@edge`→EDG, `@stress`→STR) pada seluruh sampel yang diperiksa (mencakup seluruh 170 baris judul Scenario).

### Tagging (10 catatan, tidak fatal tapi perlu diperbaiki)

1. **2 scenario tanpa tag `@REQ-*` sama sekali**: `OMS014-NEG-027` (guest ditolak akses — hanya `@negative @priority-high @screen-app-shell @screen-daftar-order`) dan `OMS014-NEG-039` (kuota habis — hanya `@negative @priority-low @screen-daftar-order`). Untuk NEG-039 ini **wajar/terdokumentasi** karena kuota order memang sengaja tidak dijadikan REQ formal (ASM-016 di analysis.md). Untuk NEG-027 tidak ada dokumentasi serupa — direkomendasikan menambahkan tag REQ terdekat (mis. REQ-022, konsisten dengan `.json`) atau catatan eksplisit "di luar 32 REQ formal, berbasis Roles & Permissions" mengikuti pola NEG-039.
2. **Drift antara tag `@REQ-*`/`@screen-*` pada `.feature` dan field `requirements`/`screens` pada `.json`** ditemukan pada minimal 8 scenario: `OMS014-POS-011` (json +REQ-004), `OMS014-POS-057` (json +REQ-008), `OMS014-EDG-020` (json +REQ-030), `OMS014-EDG-035` (json +REQ-009), `OMS014-EDG-022` (json +REQ-008, +screen `pengaturan-sistem`), `OMS014-STR-001` (json +REQ-006), `OMS014-STR-002` (json +REQ-009), `OMS014-STR-018` (json +REQ-024). Pada semua kasus, `.json` mencantumkan REQ/screen **tambahan** yang secara tematik relevan dengan isi langkah tetapi tidak tertulis sebagai tag di `.feature`. Ini tidak membuat scenario salah, namun **mengurangi keandalan RTM otomatis** jika tooling downstream membaca `.json` sebagai sumber kebenaran sementara reviewer manusia membaca tag `.feature` — kedua artefak sebaiknya disinkronkan (baik dengan menambah tag di `.feature`, atau mempersempit field `requirements`/`screens` di `.json` agar 1:1 dengan tag).

Tidak ditemukan pelanggaran lain seperti tag kategori yang tidak cocok dengan prefix ID, prioritas tanpa tag, atau REQ tag yang menunjuk REQ tidak dikenal (REQ-001..032 seluruhnya valid, tidak ada REQ-033+ yang dirujuk).

---

## Temuan Kualitas

1. **Proporsi kategori sehat**: edge+stress = 32.9% dari total, melebihi target 25%. Distribusi prioritas dari `.json`: P1 57 (33.5%), P2 72 (42.4%), P3 41 (24.1%) — wajar, tidak timpang.
2. **Prioritas P1 untuk happy path inti & AS-OFF**: seluruh scenario penanda inti AS-OFF (POS-057, POS-058, POS-059, POS-060, NEG-020, NEG-021, STR-008, STR-013) memang ber-`priority-high`/P1, konsisten dengan arahan "P1 untuk happy path inti & AS-OFF". Satu pengecualian ringan: `OMS014-EDG-038` (verifikasi elemen AS-OFF tetap absen setelah accordion Detail Order dilipat/dibuka) ber-`priority-low`/P3 padahal tetap menguji regresi elemen AS-OFF — bisa dipertimbangkan naik ke P2 karena berpotensi menangkap bug "elemen muncul saat re-render lazy".
3. **SelectorHints pada `.json`**: sangat spesifik dan ter-scope dengan baik (pola `getByTestId('unit-card-1').getByRole(...)` konsisten di seluruh 170 scenario) — tidak ditemukan selectorHint kosong/placeholder kosong. Satu selector tergolong generik/rapuh: `OMS014-POS-070` step 1/3 menggunakan `page.locator('section h2, section h3')` (bergantung pada struktur tag HTML, bukan role/testid) — wajar mengingat scenario ini menguji "urutan section" secara generik, tapi disarankan diperkuat dengan `getByTestId` per section jika tersedia di implementasi nanti.
4. **Assertion non-standar / pseudo-matcher** yang memerlukan helper kustom di luar API Playwright bawaan, ditemukan pada ±13 scenario: `toEqualSnapshot(...)` (POS-045), `toBeSortedAscending(...)` (POS-055), `capturedAsBaseline`/`toEqualBaselineExcept(...)`/`toEqualBaselineLabels` (POS-070), `notCalled` (POS-064), `notTriggered` (EDG-007), `toBeWithinViewportWidth()` (EDG-008, EDG-032), `toEqualBaseline` (EDG-022, STR-018), `toHaveRowCountUnchanged` (EDG-023, EDG-034), `toHaveIncreasedBy(n)` (STR-008, STR-010, STR-012), `lessThan(ms)` dipasangkan dengan `performance.now()`/`page.waitForResponse(...)` (STR-001, STR-007, STR-011, STR-013). Ini bukan kesalahan konseptual (skenario non-fungsional seperti snapshot/perf/idempotency memang butuh helper kustom), namun **tim automation perlu membangun fixture/matcher kustom** sebelum implementasi Playwright — direkomendasikan didaftar sebagai prasyarat teknis terpisah.
5. **Golden reference tunggal**: REQ-027/Detail Order memakai `066.png` sebagai satu-satunya referensi visual mode OFF (ASM-025) — sudah dicatat dengan baik di `testData.goldenReference` pada POS-059, cukup transparan.
6. Tidak ditemukan scenario tanpa assertion eksplisit (`Then`/`assert`) — seluruh 170 scenario pada `.feature` memiliki minimal satu baris `Then`, dan seluruh step JSON berjenis `assert` memiliki field `expected`.

---

## Rekomendasi (terurut prioritas)

> **Status:** #1–#5 ✅ **diterapkan** (lihat Addendum di bagian atas). #6–#8 masih terbuka, kecuali bagian tag NEG-027 pada #6 yang sudah tercakup oleh #4.

1. **[Tinggi]** Tambahkan scenario negative "bypass/deep-link" untuk **Step 4 Review dan Detail Order** setara `OMS014-NEG-020`/`NEG-021` (mis. akses `?panel=visualisasi-muatan` langsung di route Step 4/Detail Order, atau shortcut keyboard) — menutup gap REQ-025/REQ-027 dan menegakkan AC-004.3 "tidak ada jalur alternatif" secara menyeluruh, bukan hanya di Step 2.
2. **[Tinggi]** Tambahkan scenario negative "hapus alamat sampai kurang dari minimum ditolak" untuk **Multidrop** dan **Multipoint**, setara `OMS014-NEG-033` (yang saat ini hanya ada untuk Multipickup) — menutup gap REQ-031/REQ-032.
3. **[Sedang]** Perluas `OMS014-POS-060` (checklist AS-OFF Edit Order): (a) tambahkan assertion absen untuk `Berat Terpakai`/`Ruang Terpakai` (A8), `n koli melebihi kapasitas` (A9), dan testid `capacity-progress`, agar setara kedalaman dengan POS-057/058/059; (b) perluas Examples dari 2 kombinasi (FTL/FCL Normal) menjadi 8 kombinasi (seluruh tipe pengiriman) seperti pola POS-057/058/059.
4. **[Sedang]** Sinkronkan tag `@REQ-*`/`@screen-*` pada `.feature` dengan field `requirements`/`screens` pada `.json` untuk 8+ scenario yang teridentifikasi drift (lihat § Temuan Validasi Gherkin poin 2) — pilih satu arah kebenaran (tag Gherkin atau field JSON) agar tooling RTM tidak memberi hasil berbeda tergantung sumber yang dibaca.
5. **[Sedang]** Gabungkan `OMS014-POS-018` dan `OMS014-POS-063` menjadi satu scenario (setup identik), dan selaraskan kategori `OMS014-NEG-009` vs `OMS014-EDG-004` (nilai `0` pada field wajib-bersyarat) agar konsisten sebagai negative atau edge di seluruh suite.
6. **[Rendah]** Tambahkan tag `@REQ-*` (atau catatan eksplisit ala ASM-016) pada `OMS014-NEG-027`; pertimbangkan menaikkan prioritas `OMS014-EDG-038` dari P3 ke P2 karena tetap menguji regresi elemen AS-OFF.
7. **[Rendah, prasyarat teknis]** Sebelum implementasi Playwright, siapkan helper/matcher kustom untuk pseudo-assertion yang terdaftar di § Temuan Kualitas poin 4 (`toEqualBaseline`, `toHaveIncreasedBy`, `toBeWithinViewportWidth`, dll.), atau ganti dengan pola assertion standar Playwright yang setara.
8. **[Opsional]** Tambah 1 scenario negative ringan untuk REQ-018 (mis. menu "Lihat No. Perjalanan" tidak tersedia/tidak relevan sebelum order berstatus `Ditugaskan`) dan REQ-019 (mis. label status tak dikenal tidak pernah dirender) untuk melengkapi baris Partial bersevrasi sedang pada RTM.
