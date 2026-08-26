# Coverage Report — oms012-order-ftl-auto-stuffing

> **Tahap pipeline:** 3/4 — QA Reviewer
> **Input diperiksa:**
> - `oms012-order-ftl-auto-stuffing.feature` (2.665 baris, 287 scenario — dibaca penuh end-to-end)
> - `oms012-order-ftl-auto-stuffing.scenarios.json` (6.993 baris, 287 scenario + blok `coverage` — dibaca penuh termasuk `requirementMatrix`/`screenCoverage`/`defectCandidates`/`openRisks`)
> - `oms012-order-ftl-auto-stuffing.analysis.md` (REQ-001 s.d. REQ-078, UI-00 s.d. UI-19, ASM-001 s.d. ASM-045 — dibaca penuh)
> **Metode verifikasi:** cross-check baris-per-baris antara tag `@REQ-*`/`@screen-*`/`@priority-*`/kategori pada `.feature` terhadap `coverage.requirementMatrix` & `coverage.screenCoverage` pada `.scenarios.json`; sampling terarah (>40% scenario diverifikasi individual, mencakup seluruh REQ dengan kardinalitas tinggi) plus pembacaan penuh seluruh 287 judul/steps untuk deteksi duplikat semantik.

---

## 1. Ringkasan Jumlah per Kategori

| Kategori | Jumlah | % | high | medium | low |
|---|--:|--:|--:|--:|--:|
| positive | 109 | 38.0% | 81 | 25 | 3 |
| negative | 88 | 30.7% | 67 | 21 | 0 |
| edge | 60 | 20.9% | 17 | 36 | 7 |
| stress | 30 | 10.5% | 4 | 19 | 7 |
| **Total** | **287** | 100% | **169** | **101** | **17** |

ID range: `OMS012-POS-001..109`, `OMS012-NEG-001..088`, `OMS012-EDG-001..060`, `OMS012-STR-001..030`. Diverifikasi **sequential lengkap tanpa gap/lompatan nomor** pada keempat kategori (dibaca end-to-end).

**Verdict distribusi:** memadai. Proporsi edge (20.9%) dan stress (10.5%) berada di atas rasio umum industri (biasanya edge+stress 15-20% gabungan; di sini 31.4%), sesuai karakter modul yang eksplisit disebut analysis.md sebagai "algoritmik" (distribusi Auto Stuffing) dan "kondisional/state-driven". Edge mencakup boundary numerik bermakna (Jumlah Armada 1/99/50, No. WhatsApp 10/15/9 digit, PPN 0%/100%/101%, kapasitas tepat batas vs 1 unit di atas batas, dsb) — bukan sekadar filler. Stress mencakup volume (10.000 order, 10.000 item master, 100 baris barang, 50 armada), konkurensi (20 sesi simpan paralel, edit paralel 2 sesi, klik ganda), dan resiliency (timeout API, jaringan lambat) — kombinasi yang tepat untuk modul dengan komponen kalkulasi & drawer real-time.

---

## 2. Requirements Traceability Matrix (RTM)

Sumber Scenario IDs = `coverage.requirementMatrix` pada `.scenarios.json`, diverifikasi silang terhadap tag `@REQ-*` pada `.feature` (sampel luas, 0 mismatch ditemukan pada scenario yang diperiksa individual).

| REQ | Deskripsi Singkat | Positive | Negative | Edge | Stress |
|---|---|---|---|---|---|
| REQ-001 | Acuan spec Order FTL TMS, satuan Armada | POS-001, POS-109 | NEG-001 | – | – |
| REQ-002 | Wizard 4 step | POS-002, POS-003 | NEG-002 | – | STR-028 |
| REQ-003 | Order manual wizard & batch order | POS-004, POS-005 | NEG-003 | – | STR-017 |
| REQ-004 | Step 2 = pembeda utama (barang dari Master Barang) | POS-006 | NEG-004 | – | – |
| REQ-005 | Add-on Auto Stuffing aktif hanya bila dibeli beserta modul | POS-007 | NEG-005, NEG-006 | – | – |
| REQ-006 | Auto Stuffing hanya untuk FTL & FCL | POS-008, POS-009 | NEG-007 | – | – |
| REQ-007 | Logic pakai tools existing, OMS hanya atur penempatan | POS-010 | NEG-008 | – | STR-019 |
| REQ-008 | Step 4: struktur ikuti Step 2 + pop up Visualisasi Muatan | POS-011 | NEG-009 | – | – |
| REQ-009 | Step 1 field inti | POS-012 | NEG-010 | EDG-001..008 (8) | STR-004, STR-010 |
| REQ-010 | Tipe Pengiriman 4 opsi | POS-013 | NEG-011 | EDG-011 | – |
| REQ-011 | Auto-draft dari Master Droppoint | POS-014, POS-015 | NEG-012 | EDG-010 | – |
| REQ-012 | Rule cascading wilayah bertingkat | POS-016 | NEG-013 | – | – |
| REQ-013 | Minimal baris alamat per tipe pengiriman | POS-017, POS-018, POS-019 | NEG-014, NEG-015 | – | – |
| REQ-014 | Validasi field wajib Step 1 | POS-020 | NEG-016 | – | – |
| REQ-015 | Fungsi button Step 1 | POS-021, POS-022 | NEG-017 | – | – |
| REQ-016 | Barang dari Master Barang via modal Pilih Barang | POS-023 | NEG-018 | – | STR-021 |
| REQ-017 | Modal: pencarian by kode/nama | POS-024, POS-025 | NEG-019 | EDG-012..015 (4) | STR-006, STR-007 |
| REQ-018 | Modal: multi-select checkbox | POS-026 | NEG-020 | – | – |
| REQ-019 | Label "Sudah Ditambahkan" per armada | POS-027 | NEG-021 | EDG-016 | – |
| REQ-020 | Counter barang terpilih | POS-028 | NEG-022 | EDG-017 | – |
| REQ-021 | Button Batal/Simpan modal | POS-029, POS-030 | NEG-023 | – | – |
| REQ-022 | Field read-only dari Master Barang | POS-031 | NEG-024 | – | – |
| REQ-023 | Field Jumlah wajib per baris | POS-032 | NEG-025 | EDG-018..021 (4) | STR-001 |
| REQ-024 | Nilai Barang wajib saat asuransi aktif | POS-033 | NEG-026 | EDG-023, EDG-024, EDG-025 | – |
| REQ-025 | Checkbox Tambahkan Asuransi per armada | POS-034 | NEG-027 | – | – |
| REQ-026 | Nomor DO (opsional, chip, koma) | POS-035, POS-036, POS-106 | NEG-028 | EDG-026, EDG-027, EDG-028 | STR-008 |
| REQ-027 | Icon hapus per baris | POS-037 | NEG-029 | EDG-029 | – |
| REQ-028 | Alert kapasitas non-blocking | POS-038 | NEG-030 | EDG-033 | – |
| REQ-029 | Pesan alert kapasitas sesuai kondisi | POS-039, POS-040, POS-041 | NEG-031 | EDG-022, EDG-030, EDG-031, EDG-032 | – |
| REQ-030 | Helper error & border error | POS-042 | NEG-032 | – | – |
| REQ-031 | Card Data Unit dari Step 1 | POS-043 | NEG-033 | – | – |
| REQ-032 | Fungsi button Step 2 | POS-044, POS-045 | NEG-034 | – | – |
| REQ-033 | Floating button Hitung Ulang Armada & Visualisasi Terbaru | POS-046 | NEG-035 | EDG-059 | STR-020 |
| REQ-034 | Floating button tetap saat scroll | POS-047 | NEG-036 | – | STR-027 |
| REQ-035 | Floating button ikon default, label saat hover | POS-048 | NEG-037 | – | – |
| REQ-036 | Hitung Ulang aktif hanya bila ≥1 barang terisi | POS-049 | NEG-038 | EDG-034, EDG-035 | STR-011 |
| REQ-037 | Distribusi antar armada (Logic Auto Stuffing) | POS-050, POS-051 | NEG-039 | EDG-036, EDG-037 | – ⚠ |
| REQ-038 | Pembagian rata antar alamat, sisa ke alamat pertama | POS-052, POS-053, POS-107 | NEG-040 | EDG-038, EDG-039, EDG-040 | STR-003 |
| REQ-039 | Drawer: Total Kubikasi & Total Berat | POS-054 | NEG-041 | – | STR-002 |
| REQ-040 | Drawer: Jenis Pengiriman dari Step 1 | POS-055 | NEG-042 | – | – |
| REQ-041 | Drawer: rekomendasi 3 teratas + Paling Efisien | POS-056, POS-057 | NEG-043 | EDG-041 | – |
| REQ-042 | Drawer: Jenis/Jumlah Armada dapat diubah | POS-058, POS-059 | NEG-044 | EDG-042 | – |
| REQ-043 | Drawer: Visualisasi 3D update saat armada berubah | POS-060 | NEG-045 | EDG-043 | STR-005 |
| REQ-044 | Terapkan ke Order | POS-061 | NEG-046 | EDG-044, EDG-060 | STR-012 |
| REQ-045 | Perubahan armada tercermin ke Step 1 & Data Unit | POS-062 | NEG-047 | EDG-045 | – |
| REQ-046 | Batal drawer tanpa menerapkan perubahan | POS-063 | NEG-048 | EDG-046 | – |
| REQ-047 | Visualisasi Terbaru: panel read-only | POS-064 | NEG-049, NEG-050 | – | – |
| REQ-048 | Step 3 identik TMS | POS-065 | NEG-051 | EDG-047, EDG-048 | – |
| REQ-049 | Waktu Perjalanan: 2 kondisi (textfield/read-only) | POS-066, POS-067 | NEG-052, NEG-053 | EDG-049 | – |
| REQ-050 | Ringkasan alamat: label + text link (tipe multi) | POS-068, POS-069 | NEG-054 | – | – |
| REQ-051 | Komponen harga opsional | POS-070 | NEG-055 | EDG-050, EDG-051 | – |
| REQ-052 | Komponen Asuransi = % × Total Nilai Barang | POS-071 | NEG-056 | EDG-052, EDG-053 | – |
| REQ-053 | Validasi & button Step 3 | POS-072 | NEG-057 | – | – |
| REQ-054 | Step 4 read-only ringkasan Step 1-3 | POS-073 | NEG-058 | EDG-009 | – |
| REQ-055 | Data Barang Step 4 ikuti struktur Step 2 | POS-074 | NEG-059 | – | – |
| REQ-056 | Label "Diasuransikan" per armada | POS-075 | NEG-060 | – | – |
| REQ-057 | Button pop up Visualisasi Muatan (card Data Barang) | POS-076, POS-108 | NEG-061 | – | STR-024 |
| REQ-058 | Fungsi button Step 4; Simpan → Menunggu Penugasan | POS-077, POS-078 | NEG-062 | – | STR-030 |
| REQ-059 | 9 status Order FTL | POS-079 | NEG-063 | EDG-058 | – |
| REQ-060 | Status 1-4 = draft, Simpan ke Draf di step manapun | POS-080, POS-105 | NEG-064 | – | STR-018 |
| REQ-061 | Shipper dapat ubah order s.d. Menunggu Penugasan | POS-081 | NEG-065 | – | – |
| REQ-062 | Tidak dapat ubah order setelah Ditugaskan | POS-082 | NEG-066 | – | – |
| REQ-063 | Jenis/Tipe Pengiriman locked di Edit Order | POS-083 | NEG-067 | – | – |
| REQ-064 | Field lain tetap dapat diubah di Edit Order | POS-084 | NEG-068 | – | STR-015 |
| REQ-065 | Button Batal/Simpan Edit Order → pop up konfirmasi | POS-085, POS-086 | NEG-069 | – | – |
| REQ-066 | Order dapat dibatalkan draft s.d. Ditugaskan | POS-087 | NEG-070, NEG-071 | – | STR-016 |
| REQ-067 | Pembatalan oleh admin shipper, bukan vendor | POS-088 | NEG-072, NEG-073, NEG-086, NEG-087 | – | – |
| REQ-068 | Alasan Pembatalan wajib diisi | POS-089 | NEG-074, NEG-075 | EDG-054 | STR-009 |
| REQ-069 | Aksi per baris menyesuaikan status order | POS-090, POS-091, POS-102†, POS-103†, POS-104† | NEG-076, NEG-088† | – | STR-013†, STR-014†, STR-029† |
| REQ-070 | Status Ditugaskan: Edit hilang, Lihat No. Perjalanan ada | POS-092 | NEG-077 | – | – |
| REQ-071 | Riwayat Pembatalan (toolbar) vs Riwayat Perubahan (baris) | POS-093, POS-094 | NEG-078 | – | STR-025, STR-026 |
| REQ-072 | No. Perjalanan untuk public tracking | POS-095 | NEG-079 | – | STR-022 |
| REQ-073 | No. Perjalanan auto-generate, jumlah = jumlah armada | POS-096 | NEG-080 | EDG-056 | – |
| REQ-074 | No. Perjalanan hanya untuk FTL & FCL | POS-097 | NEG-081 | – | – |
| REQ-075 | Lihat No. Perjalanan tampil setelah Ditugaskan | POS-098 | NEG-082 | – | – |
| REQ-076 | Pop up Data No. Perjalanan per armada | POS-099 | NEG-083 | EDG-055 | – |
| REQ-077 | Icon copy No. Perjalanan | POS-100 | NEG-084 | EDG-057 | STR-023 |
| REQ-078 | No. Perjalanan juga di Detail Order | POS-101 | NEG-085 | – | – |

`†` = lihat **Temuan 3** pada §4 (Catatan Validasi) — scenario ini secara konten menguji Filter/Sort/Paginasi Daftar Order (UI-01/UI-02), bukan matriks aksi-per-status yang menjadi definisi literal REQ-069.

**Hasil verifikasi klaim coverage:**
- ✅ **78/78 REQ memiliki ≥1 skenario positive DAN ≥1 skenario negative.** Tidak ditemukan REQ dengan 0 cakupan pada kategori manapun yang disyaratkan. Klaim generator **TERVERIFIKASI BENAR**.
- ✅ **20/20 layar (UI-00 s.d. UI-19) memiliki ≥1 skenario** — diverifikasi melalui `coverage.screenCoverage`, seluruh 20 key non-kosong. Klaim generator **TERVERIFIKASI BENAR** (lihat detail §3).

---

## 3. Verifikasi Cakupan Layar (Screen Coverage)

| UI | Layar | Jumlah scenario | Status |
|---|---|--:|---|
| UI-00 | Shell Global | 1 | ✅ (via POS-109, `@screen-daftar-order`, menguji elemen shell secara eksplisit — lihat catatan) |
| UI-01 | Daftar Order | 5 | ✅ |
| UI-02 | Panel Filter | 5 | ✅ |
| UI-03 | Menu Aksi per Status | 5 | ✅ (sub-state dari UI-01, tanpa tag `@screen-*` tersendiri — wajar) |
| UI-04 | Pop up Data No. Perjalanan | 5 | ✅ |
| UI-05 | Step 1 Normal | 4 | ✅ |
| UI-06 | Step 1 Multi | 4 | ✅ (sub-state Step 1) |
| UI-07 | Step 2 Normal | 5 | ✅ |
| UI-08 | Modal Pilih Barang | 5 | ✅ |
| UI-09 | Drawer Hitung Ulang Armada | 5 | ✅ |
| UI-10 | Panel Visualisasi Terbaru | 3 | ✅ |
| UI-11 | Step 2 Multi | 4 | ✅ (sub-state Step 2) |
| UI-12 | Step 3 Normal | 5 | ✅ |
| UI-13 | Step 3 Multi + pop up alamat | 2 | ✅ (minimum tapi cukup) |
| UI-14 | Step 4 Review | 5 | ✅ |
| UI-15 | Pop up Konfirmasi Simpan Draf | 2 | ✅ |
| UI-16 | Detail Order | 4 | ✅ |
| UI-17 | Pop up Visualisasi Muatan | 3 | ✅ |
| UI-18 | Modal Batalkan Order | 5 | ✅ |
| UI-19 | Edit Order | 5 | ✅ |

**Catatan:** UI-00 (Shell Global), UI-03, UI-06, UI-11, UI-13 tidak memiliki nilai `@screen-*` tersendiri dalam konvensi tag (hanya 19 nilai `@screen-*` terdaftar di `conventions.screens`). Keempatnya adalah *sub-state/komponen bersama* dari layar induk (Daftar Order, Step 1, Step 2, Step 3) — bukan route terpisah — sehingga wajar tidak memiliki tag khusus. Cakupannya tetap valid karena skenario yang relevan (mis. POS-090/091/092 untuk menu aksi; POS-017/018/019 untuk Step 1 Multi; POS-106/107 untuk Step 2 Multi; POS-068 untuk Step 3 Multi) menguji konten spesifik sub-state tersebut secara eksplisit di dalam step Gherkin-nya. **Tidak direkomendasikan menambah tag `@screen-*` baru** untuk sub-state ini karena akan memecah taksonomi 19-layar yang sudah konsisten dipakai di seluruh 287 skenario.

---

## 4. Catatan Validasi Gherkin

### 4.1 Struktur & Sintaks
- **Format tag**: seluruh 287 scenario diperiksa memiliki **persis 4 tag** dalam urutan konsisten: `@<kategori> @priority-<level> @REQ-<NNN> @screen-<slug>`. Tidak ditemukan scenario dengan tag hilang, tag ganda, atau urutan tag yang berbeda.
- **Konsistensi ID↔kategori**: prefiks ID (`POS`/`NEG`/`EDG`/`STR`) selalu selaras dengan tag kategori (`@positive`/`@negative`/`@edge`/`@stress`) pada seluruh scenario yang diperiksa — 0 mismatch.
- **Keyword bahasa**: `Feature`/`Scenario`/`Given`/`When`/`And`/`Then` konsisten berbahasa Inggris; isi step berbahasa Indonesia. Tidak ditemukan baris `# language: id`, sesuai instruksi header file.
- **Struktur Given-When-Then**: seluruh scenario diawali `Given` (konteks), diikuti `When` (aksi) dan `Then`/`And` (assersi). Sebagian scenario (terutama yang menguji alur toggle/hover/navigasi bolak-balik, mis. POS-020, POS-028, POS-098, EDG-025) memakai **pola berulang When→Then→When→Then** dalam satu scenario — ini valid secara Gherkin dan merupakan praktik umum untuk skenario "state transition sekuensial", bukan pelanggaran. Tidak direkomendasikan dipecah karena assersi antar-state saling bergantung dalam satu alur.
- **Penomoran ID sekuensial**: diverifikasi lengkap tanpa lompatan/duplikat pada keempat kategori: `POS-001..109`, `NEG-001..088`, `EDG-001..060`, `STR-001..030` (dibaca end-to-end).
- **Judul scenario**: seluruh judul mengikuti pola `Scenario: <ID> - <deskripsi ringkas>`, konsisten di seluruh file.

**Verdict Gherkin: PASS.** Tidak ada defect struktural/sintaksis yang ditemukan.

### 4.2 Temuan (bukan blocking, untuk dicatat)

**Temuan 1 — Presisi angka boundary pada OMS012-EDG-030 (minor).**
Judul: "Kubikasi tepat sama dengan kapasitas tidak memunculkan alert". Data: `SKU-ATK-001` (kubikasi satuan `0,035 m³`) × `Jumlah 1714` pada armada `Tronton Box` (kapasitas `60 m³`) = `59,99 m³` (bukan tepat `60 m³`, karena `60 / 0,035 = 1714,2857`). Skenario tetap valid sebagai *boundary-below* test, namun judul & narasi "tepat sama" tidak akurat secara matematis. **Rekomendasi:** ubah judul menjadi "Kubikasi sedikit di bawah kapasitas tidak memunculkan alert", atau ganti test data agar hasil perkalian genap 60 (mis. SKU dengan kubikasi `0,03 m³` × `Jumlah 2000` = `60 m³` tepat). Tidak mempengaruhi validitas assersi (`tidak menampilkan alert` tetap benar untuk 59,99 m³), sehingga tidak diklasifikasikan sebagai gap.

**Temuan 2 — Berat tepat sama (EDG-032) sudah presisi.** Sebagai pembanding: EDG-032 menggunakan SKU-PPR-001 (berat `12,5 kg`) × `Jumlah 1600` = `20.000 kg` — **tepat** sama dengan kapasitas `Tronton Box`. Ini adalah contoh yang benar; disebut di sini hanya sebagai referensi kontras terhadap Temuan 1.

**Temuan 3 — Tag `@REQ-069` dipakai untuk fitur di luar definisi literalnya (traceability dilution, minor-medium).**
REQ-069 pada `analysis.md` didefinisikan spesifik sebagai *"Aksi per baris menyesuaikan status order sesuai matriks"* (menu `...` per baris: Detail/Lanjutkan Pengisian/Edit/Batalkan Order/Riwayat Perubahan/Lihat No. Perjalanan). Namun 7 scenario ditandai `@REQ-069` padahal kontennya menguji **Filter, Sort, dan Paginasi** Daftar Order (fitur UI-01/UI-02 yang **tidak memiliki REQ formal** di `analysis.md`):
- `OMS012-POS-102` — Filter Status menyaring Daftar Order
- `OMS012-POS-103` — Reset filter mengembalikan daftar penuh
- `OMS012-POS-104` — Sort Total Harga dan paginasi berfungsi
- `OMS012-NEG-088` — Filter ID Order tidak dikenal → empty state
- `OMS012-STR-013` — Daftar Order 10.000 baris dengan paginasi
- `OMS012-STR-014` — Menampilkan 100 data per halaman
- `OMS012-STR-029` — Filter/sort/paginasi dijalankan berulang cepat

Nilai uji ketujuh scenario ini **valid dan berguna** (UI-02 Panel Filter terdokumentasi lengkap di UI Inventory), tetapi pen-tag-an ke REQ-069 mengaburkan RTM: pembaca RTM REQ-069 akan mengira seluruh 5 positive + 2 negative + 3 stress menguji matriks aksi-per-status, padahal hanya `POS-090`, `POS-091`, `NEG-076` (ditambah `POS-092`/`NEG-077` yang justru ditag `REQ-070`) yang benar-benar menguji matriks tersebut. **Rekomendasi:** pada revisi `analysis.md` berikutnya, tambahkan REQ baru (mis. `REQ-079` "Filter, Sort, dan Paginasi Daftar Order") berbasis UI-02, lalu retag ketujuh scenario di atas ke REQ tersebut. Sampai revisi dilakukan, RTM pada §2 laporan ini menandai baris REQ-069 dengan `†` sebagai pengingat.

**Temuan 4 — Kolom `stress` kosong pada REQ-037 (gap kedalaman minor, ditandai ⚠ di §2).**
REQ-037 (algoritma inti Auto Stuffing: distribusi kubikasi/berat mengisi 1 armada hingga maksimal sebelum berpindah) memiliki positive (POS-050/051) dan edge (EDG-036/037) yang solid, tetapi **tidak ada scenario stress** yang memvalidasi konservasi kuantitas pada skala besar (banyak armada + volume sangat besar) untuk algoritma distribusi itu sendiri. Volume besar yang ada di modul ini (STR-002/REQ-039 — 50 baris barang; STR-004/REQ-009 — 50 blok armada; STR-005/REQ-043 — 50 tab visualisasi) menguji rendering/perhitungan total, bukan *hasil penempatan* algoritma distribusi pada skala tersebut. **Lihat rekomendasi tambahan di §6 (poin 1).**

---

## 5. Deduplikasi — Hasil Pemeriksaan

Seluruh 287 judul, tag, dan langkah Given/When/Then dibaca dan diperiksa untuk kemiripan/tumpang tindih. **Tidak ditemukan scenario duplikat identik** (dua scenario dengan Given/When/Then yang secara substansial sama). Beberapa pasangan/kelompok scenario yang **terlihat mirip pada judul** diperiksa lebih lanjut dan **direkomendasikan tetap dipertahankan** (bukan duplikat) karena menguji kondisi/trigger/nilai batas yang berbeda:

| Pasangan | Alasan bukan duplikat — direkomendasikan **tetap ada** |
|---|---|
| `POS-050` vs `EDG-036` (REQ-037) | POS-050 memakai `Jumlah 500` (jauh di bawah kapasitas, kasus umum "muat 1 armada"); EDG-036 memakai `Jumlah 1600` (persis di batas kapasitas berat). Titik uji numerik berbeda — komplementer, bukan duplikat. |
| `NEG-039` (REQ-037) vs `NEG-046` (REQ-044) | Keduanya menegaskan "total Jumlah tidak berubah", tetapi NEG-039 menguji *hasil distribusi* (logic Auto Stuffing) sedangkan NEG-046 menguji *aksi Terapkan ke Order* (penulisan ke order). REQ & AC yang mendasari berbeda; overlap assersi wajar untuk regression-in-depth. |
| `EDG-059`/`EDG-060` (double-click, 200ms) vs `STR-011`/`STR-012` (20×/10× berturut-turut) | Berbeda kelas pengujian: EDG menguji *debounce* interaksi ganda-cepat (UI edge case), STR menguji *stabilitas berulang* dalam skala iterasi (load/regresi state). Pola & tujuan pengujian berbeda. |
| `POS-039`/`POS-040`/`POS-041` vs `EDG-022` (REQ-029) | POS-03x menetapkan pesan alert per kondisi (kubikasi-saja/berat-saja/gabungan) dengan nilai moderat; EDG-022 memakai nilai ekstrem (`Jumlah 999999`) untuk memastikan tidak ada masalah formatting/overflow pada pesan gabungan. Nilai data & tujuan berbeda. |
| `NEG-025` (REQ-023, Jumlah **kosong**) vs `EDG-019` (REQ-023, Jumlah **"0"**) | Boundary berbeda: field kosong (belum diisi) vs nilai eksplisit nol. Keduanya valid sebagai kasus negatif terpisah. |

**Kesimpulan deduplikasi: 0 scenario direkomendasikan untuk dibuang.** Tidak ada tindakan dedup yang diperlukan pada `.feature` maupun `.scenarios.json`.

---

## 6. Rekomendasi Scenario Tambahan (gap kedalaman, non-blocking)

Karena **tidak ada gap wajib** (semua REQ & layar tercakup), rekomendasi berikut bersifat **penguatan kedalaman**, bukan prasyarat rilis:

1. **REQ-037 (stress)** — Tambahkan: *"Distribusi Auto Stuffing pada 30 armada dengan total muatan sangat besar (mis. 500.000 koli) tetap menghasilkan konservasi total Jumlah dan urutan pengisian sekuensial yang benar (Armada 1 penuh dulu sebelum Armada 2, dst.)."* Kategori: stress, priority-medium, `@REQ-037`.
2. **REQ-038 (stress)** — Tambahkan: *"Pembagian 10.000 koli antar 7 alamat pengirim (Multipickup) dalam 1 armada tetap konsisten: pembagian rata sejauh mungkin, sisa terbesar ke alamat pertama, total tetap 10.000."* Kategori: stress, priority-medium, `@REQ-038`.
3. **REQ-013 (negative)** — Tambahkan kasus Multipoint yang belum eksplisit: *"Multipoint dengan 2 alamat pengirim namun hanya 1 alamat penerima ditahan (kedua syarat ≥2 harus terpenuhi bersamaan)."* Kategori: negative, priority-medium, `@REQ-013`.
4. **Retag / REQ baru untuk Filter-Sort-Paginasi** — lihat Temuan 3 (§4.2): usulkan `REQ-079` pada revisi `analysis.md` berikutnya, lalu retag `POS-102/103/104`, `NEG-088`, `STR-013/014/029` dari `@REQ-069` ke `@REQ-079`. Ini adalah perbaikan traceability, bukan penambahan scenario baru.
5. **EDG-030 (perbaikan data, bukan penambahan)** — lihat Temuan 1 (§4.2): sesuaikan test data atau judul agar konsisten secara matematis.

---

## 7. Referensi Silang: Defect Candidates & Open Risks (dari `.scenarios.json`)

Dicatat ulang di sini untuk kelengkapan sign-off QA (bukan temuan baru dari tahap ini, sudah ada di `coverage.defectCandidates`/`coverage.openRisks` pada JSON sumber):

| ID | Temuan | Assumption | Severity |
|---|---|---|---|
| OMS012-NEG-049 | Panel Visualisasi Terbaru (`025.png`) masih memuat `Terapkan ke Order` padahal AC-047.2 melarangnya | ASM-030 | high |
| OMS012-NEG-001 | Edit Order Multipickup (`043.png`) memakai judul "Data Barang - Kontainer n" pada order FTL | ASM-041 | medium |
| OMS012-NEG-031 | Varian pesan alert gabungan tidak pernah muncul di 46 aset desain — risiko dua chip terpisah | ASM-031 | medium |
| OMS012-NEG-038 | State disabled `Hitung Ulang Armada` belum tervisualisasi pada desain | ASM-045 | medium |
| OMS012-EDG-016 | Perilaku melepas centang item "Sudah Ditambahkan" belum dikonfirmasi produk | ASM-034 | medium |

Open risks tertinggi yang relevan untuk regresi lanjutan: **ASM-010** (waktu eksekusi Auto Stuffing eksplisit-triggered — memengaruhi POS-050/051, NEG-064, EDG-036), **ASM-012** (basis Nilai Barang = nilai total baris — memengaruhi seluruh skenario Total Harga/Asuransi), **ASM-016** (aksi status lanjut bersifat inferensi — memengaruhi NEG-065/070/071).

---

## 8. Kesimpulan

| Aspek | Status |
|---|---|
| Coverage REQ (≥1 positive + ≥1 negative per REQ) | ✅ 78/78 terverifikasi |
| Coverage layar (20 UI) | ✅ 20/20 terverifikasi |
| Duplikat/tumpang tindih yang perlu dibuang | ✅ 0 ditemukan |
| Distribusi edge & stress | ✅ Memadai dan bermakna (31.4% gabungan, boundary & volume nyata) |
| Validasi sintaks Gherkin (tag, struktur Given/When/Then) | ✅ PASS, 0 defect struktural |
| Gap signifikan (blocking) | ❌ Tidak ada |
| Catatan non-blocking | 4 temuan (§4.2) + 3 rekomendasi penguatan (§6) |

**Rekomendasi keseluruhan: scenario set LAYAK LANJUT ke tahap berikutnya (test-generator).** Perbaikan pada §4.2/§6 bersifat opsional/penguatan kualitas, dapat dikerjakan sebagai backlog perbaikan tanpa memblokir progres pipeline.
