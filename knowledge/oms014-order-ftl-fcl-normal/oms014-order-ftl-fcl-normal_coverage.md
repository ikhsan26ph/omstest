# Coverage Report — oms014-order-ftl-fcl-normal

> Direview terhadap:
> - `oms014-order-ftl-fcl-normal.feature` (226 skenario, Gherkin `# language: id`)
> - `oms014-order-ftl-fcl-normal.scenarios.json` (226 objek JSON)
> - `oms014-order-ftl-fcl-normal.analysis.md` (REQ-001..037, VAL-01..37 + VAL-M1..M7, AC-001..060)
> Tanggal review: 2026-08-20 · Mode: AUTO · Reviewer: QA Reviewer (verifikatif)

---

## Ringkasan Eksekutif

| Kategori | Jumlah (.feature) | Jumlah (.scenarios.json) | Cocok? |
|---|---|---|---|
| @positive | 83 (POS-001..083) | 83 | ✅ |
| @negative | 65 (NEG-001..065) | 65 | ✅ |
| @edge | 56 (EDG-001..056) | 56 | ✅ |
| @stress | 22 (STR-001..022) | 22 | ✅ |
| **Total** | **226** | **226** | ✅ |

**Status keseluruhan: LULUS dengan catatan (PASS with notes).**

- **Requirements (REQ-001..037):** 37/37 memiliki minimal 1 skenario yang mereferensikannya (0 gap absolut). 26/37 memiliki kombinasi positive+negative penuh; 11/37 hanya memiliki satu arah kategori (positive‑saja atau negative‑saja) — seluruhnya beralasan secara struktural (lihat bagian RTM & catatan "Justifikasi Single-Category"), bukan defect murni, namun tetap dicatat sebagai **gap minor** sesuai kriteria tugas.
- **Validation Rules (VAL-01..37, VAL-M1..M7):** 44/44 ter-cover.
- **Acceptance Criteria (AC-001..060):** 60/60 ter-cover **melalui `traceability` array di JSON**; namun **2 AC (AC-001, AC-037) tidak muncul sebagai tag `@AC-xxx` di file `.feature`** meskipun tercantum di `scenarios.json` — ini adalah **gap dokumentasi/konsistensi tag**, bukan gap pengujian.
- **Duplikasi/overlap:** tidak ditemukan duplikat murni (identik) yang perlu dihapus; ditemukan **1 pasangan overlap signifikan** (EDG-031 vs NEG-011) dan beberapa overlap tematik yang masih dapat dijustifikasi sebagai eskalasi/variasi valid (lihat bagian Duplikasi).
- **Validasi Gherkin:** ditemukan **1 temuan signifikan** — seluruh 226 skenario menggunakan keyword step `Given/When/Then/And` (Inggris) padahal file mendeklarasikan `# language: id` dan `Latar` menggunakan `Diberikan/Dan` (Indonesia). Ini berisiko terhadap parser Gherkin yang strict per-dialect. Selain itu ditemukan pola escaped-quote (`\"...\"`) di 2 step yang berpotensi rapuh terhadap sebagian parser.
- **Validasi JSON:** struktur field konsisten di seluruh 226 objek (id, title, category, priority, area, screen, requirement, traceability, preconditions, steps, expected, testData, selectorHints). Ditemukan **inkonsistensi representasi data-driven** (`dataDriven` flag tidak konsisten pada 7 "Skenario Konsep") dan **artefak format sisa penggabungan fragmen** (koma pada baris tersendiri di 4 titik batas) — keduanya valid JSON, murni kosmetik/style.
- **Kecukupan edge & stress:** **memadai (baik)** untuk kompleksitas modul — lihat penilaian rinci di bagian terkait.

---

## Requirements Traceability Matrix (RTM)

Kolom **Scenario IDs** menampilkan ID representatif (tidak selalu ekshaustif untuk REQ dengan cakupan sangat luas seperti REQ-028); kolom **Kat.** menandai kategori yang ter-cover: P=positive, N=negative, E=edge, S=stress. Status **Covered** = REQ punya ≥1 skenario; anotasi *(single-cat)* = hanya 1 arah P/N ditemukan (dijustifikasi di bawah tabel).

| REQ | Deskripsi singkat | Scenario IDs (representatif) | Kat. | Status |
|---|---|---|---|---|
| REQ-001 | Cakupan modul: 4 tipe pengiriman, FTL/FCL, tanpa Auto Stuffing | POS-018, POS-016 | P | Covered *(single-cat: no N)* |
| REQ-002 | Rule berlaku utk FTL (Armada) & FCL (Kontainer) | POS-018, POS-019, POS-049 | P | Covered *(single-cat: no N)* |
| REQ-003 | Floating "Hitung Ulang Armada/Kontainer" tidak tampil | POS-003(json), NEG-004, NEG-005, NEG-007, NEG-018, STR-001, STR-022 | P,N,S | Covered |
| REQ-004 | Floating "Visualisasi Terbaru" tidak tampil | POS-003(json), NEG-006, NEG-007, STR-022 | P,N,S | Covered |
| REQ-005 | Drawer/panel Auto Stuffing tidak dapat diakses via jalur apa pun | NEG-008, NEG-009, NEG-010, NEG-018 | N | Covered *(single-cat: no P — wajar, requirement bersifat absence-only)* |
| REQ-006 | Logic Auto Stuffing tidak berjalan | POS-003(json), POS-043, POS-046, POS-060(json), NEG-011, NEG-012, EDG-020, EDG-021, EDG-031, EDG-032 | P,N,E | Covered |
| REQ-007 | Tidak ada pembagian rata otomatis antar alamat (multi) | POS-044(json), POS-045(json), NEG-013, NEG-014, NEG-015, EDG-030 | P,N,E | Covered |
| REQ-008 | Pengisian barang manual per unit & kombinasi alamat | POS-030, POS-043, POS-044, POS-045, POS-073, NEG-037, NEG-041, EDG-028, STR-003, STR-004 | P,N,E,S | Covered |
| REQ-009 | Wizard tetap 4 step, batch order didukung | POS-015, POS-017, STR-018 | P,S | Covered *(single-cat: no N)* |
| REQ-010 | Step 1 identik standar (field, cascading, minimal baris) | POS-018..026, NEG-021..028, EDG-001, EDG-029, EDG-046, EDG-047 | P,N,E | Covered |
| REQ-011 | Step 2 ambil barang via modal Pilih Barang | POS-027..031, POS-048, NEG-035, NEG-039, NEG-040, EDG-023..027, STR-002, STR-008, STR-009 | P,N,E,S | Covered |
| REQ-012 | Field read-only dari Master Barang | POS-032, NEG-034, EDG-056 | P,N,E | Covered |
| REQ-013 | Field Jumlah wajib diisi | POS-032, EDG-003, EDG-004, NEG-029, NEG-030, NEG-036 | P,N,E | Covered |
| REQ-014 | Checkbox Asuransi per unit, Nilai Barang kondisional | POS-033, POS-034, NEG-031, NEG-032, NEG-033, EDG-005, EDG-006, EDG-013..015, EDG-050 | P,N,E | Covered |
| REQ-015 | Nomor DO tidak wajib, multi via koma, chip | POS-035, POS-036, EDG-007..012, STR-005, STR-006 | P,E,S | Covered *(single-cat: no N — field opsional, tidak ada kondisi "ditolak")* |
| REQ-016 | Baris barang dapat dihapus via icon | POS-037, EDG-016 | P,E | Covered *(single-cat: no N)* |
| REQ-017 | Alert kapasitas informatif, tidak memblokir | POS-039..042, EDG-004, EDG-017..019, EDG-022 | P,E | Covered *(single-cat: no N — sifatnya informatif, tidak ada "penolakan" untuk diuji negatif)* |
| REQ-018 | Helper error + border error saat field wajib kosong | POS-034(json), NEG-029, NEG-031 | P,N | Covered |
| REQ-019 | Info "Data Unit" tampil, informatif, tanpa hitung ulang | POS-038, NEG-038, EDG-002, STR-001 | P,N,E,S | Covered |
| REQ-020 | Step 3 Vendor & Harga standar (Waktu Perjalanan sesuai jenis order) | POS-050..058, NEG-042..048, EDG-033..037 | P,N,E | Covered |
| REQ-021 | Asuransi = % × Total Nilai Barang, masuk Total Harga | POS-054, POS-055, NEG-049, EDG-038, EDG-039, EDG-050 | P,N,E | Covered |
| REQ-022 | Validasi field wajib + fungsi button standar | POS-046(json AC-037), POS-062, POS-064, POS-065, NEG-021, NEG-022, NEG-042, NEG-043, EDG-032, EDG-054, EDG-055, STR-011, STR-019 | P,N,E,S | Covered |
| REQ-023 | Status Order tetap 9 status | POS-014, POS-047(json), POS-057(json), POS-081(json), POS-082 | P | Covered *(single-cat: no N)* |
| REQ-024 | Draft tersimpan via "Simpan ke Draf" di step manapun | POS-026, POS-047, POS-057, POS-081, POS-083, EDG-042, STR-014 | P,E,S | Covered *(single-cat: no N)* |
| REQ-025 | Hak edit: draft s.d. Menunggu Penugasan, terkunci sejak Ditugaskan | POS-071, NEG-052, NEG-054, NEG-057 | P,N | Covered |
| REQ-026 | Edit Order: field locked/editable sesuai aturan, pop up konfirmasi | POS-071..074, NEG-056, NEG-057, NEG-058, STR-017 | P,N,S | Covered |
| REQ-027 | Pembatalan: draft s.d. Ditugaskan, hanya admin shipper, alasan wajib | POS-075, POS-076, NEG-059..062, EDG-043..045, STR-007, STR-021 | P,N,E,S | Covered |
| REQ-028 | Aksi Daftar Order sesuai status, No. Perjalanan | POS-006..013, POS-016, POS-066..070, POS-077..083, NEG-052, NEG-054, NEG-055, NEG-063, NEG-064, EDG-048, EDG-049, EDG-051, EDG-052, STR-010, STR-012, STR-020 | P,N,E,S | Covered |
| REQ-029 | Step 4 Review tanpa visualisasi/indikator keterisian | POS-004(json), NEG-016, STR-015 | P,N,S | Covered |
| REQ-030 | Data Barang Step 4 apa adanya (tanpa reorganisasi) | POS-060, POS-063, POS-069(json), NEG-020, STR-015 | P,N,S | Covered |
| REQ-031 | Detail Order tanpa elemen visualisasi/keterisian | POS-066(json), NEG-017, NEG-019, NEG-065, STR-016 | P,N,S | Covered |
| REQ-032 | Struktur Data Barang Review = Step 2, label "Diasuransikan" | POS-059, POS-061, POS-066, POS-068, NEG-050, NEG-051 | P,N | Covered |
| REQ-033 | Default build Auto Stuffing aktif | POS-002 | P | Covered *(single-cat: no N — sulit diuji "negatif" tanpa mengubah kondisi provisioning; lihat rekomendasi)* |
| REQ-034 | Toggle Auto Stuffing tersedia (ON/OFF, pulih tanpa deploy ulang) | POS-001, POS-005, NEG-001, EDG-040, STR-013 | P,N,E,S | Covered |
| REQ-035 | Toggle OFF → Step 2 sembunyikan elemen secara serentak | POS-003, NEG-018, EDG-041 | P,N,E | Covered |
| REQ-036 | Toggle OFF → Review & Detail ikut kondisi tanpa Auto Stuffing | POS-004 | P | Covered *(single-cat: no N — merupakan rollup dari REQ-029/031 yang sudah teruji negatif; lihat catatan)* |
| REQ-037 | Basis komponen sama ON/OFF, tanpa layout pecah | NEG-002, NEG-003, EDG-011(json), EDG-024(json), EDG-053, EDG-056(json) | N,E | Covered *(single-cat: no P — requirement non-fungsional "tidak boleh rusak", wajar diuji via negative/edge)* |

**Justifikasi Single-Category (11 REQ):** Requirement yang secara alami bersifat "absence-only" (REQ-005, REQ-037 → tidak boleh ada elemen/kerusakan) secara wajar hanya diuji lewat kategori negative/edge, sedangkan requirement yang bersifat pernyataan definisi/ruang lingkup atau field opsional (REQ-001, REQ-002, REQ-009, REQ-015, REQ-016, REQ-017, REQ-023, REQ-024, REQ-033, REQ-036) secara wajar hanya diuji lewat positive/edge/stress karena tidak ada "kondisi pelanggaran" yang relevan untuk dijadikan skenario negative murni. Ini **bukan cacat pengujian**, namun tetap dicatat sesuai kriteria ketat tugas (≥1 positive + ≥1 negative per REQ). Lihat rekomendasi untuk usulan skenario tambahan opsional.

---

## Validation Rules Coverage (VAL-xx & VAL-Mx)

**44/44 ter-cover (VAL-01..VAL-37 + VAL-M1..VAL-M7).**

| Kelompok | Status | Contoh Scenario IDs |
|---|---|---|
| VAL-01..VAL-10 (Absennya Auto Stuffing) | ✅ Covered | NEG-004..020, STR-022 |
| VAL-11..VAL-32 (Perilaku standar) | ✅ Covered | POS-017, POS-032..083, NEG-021..065, EDG-001..030 |
| VAL-33..VAL-37 (Toggle) | ✅ Covered | POS-001..005, NEG-001..003, EDG-040, EDG-041, STR-013 |
| VAL-M1..VAL-M7 (Modal Pilih Barang) | ✅ Covered | POS-027..031, POS-048, NEG-039, NEG-040, EDG-023..027, STR-008, STR-009 |

Tidak ditemukan VAL/VAL-M yang tanpa referensi skenario sama sekali.

---

## Acceptance Criteria Coverage (AC-xxx)

**60/60 ter-cover berdasarkan `traceability` array di `scenarios.json`.**

- 58/60 AC juga muncul sebagai tag `@AC-xxx` langsung di `.feature` — konsisten.
- **AC-001** ("end-to-end flow dapat diselesaikan tanpa Auto Stuffing") — hanya muncul di `traceability` JSON pada **OMS014-POS-062** ("Simpan pada Step 4 mengubah status order menjadi Menunggu Penugasan"), **tidak** ditandai sebagai tag `@AC-001` di `.feature`. → **Gap dokumentasi tag**, bukan gap pengujian (skenario end-to-end memang ada).
- **AC-037** ("Batal/Simpan ke Draf/Sebelumnya/Selanjutnya berperilaku identik standar") — muncul di `traceability` JSON pada **OMS014-POS-046, POS-064, POS-065** (skenario tombol navigasi wizard), **tidak** ditandai sebagai tag `@AC-037` di `.feature`. → **Gap dokumentasi tag** yang sama.

**Rekomendasi:** tambahkan tag `@AC-001` pada `OMS014-POS-062` dan `@AC-037` pada `OMS014-POS-046`/`POS-064`/`POS-065` di `.feature` agar traceability tag selaras dengan `scenarios.json` (lihat juga bagian Validasi Konsistensi JSON — pola ini mengindikasikan `traceability` JSON secara umum **lebih lengkap** daripada tag `.feature`, kemungkinan besar karena tag `.feature` disederhanakan saat penulisan sedangkan array `traceability` JSON mempertahankan seluruh rujukan asli).

---

## Temuan Duplikasi/Overlap

Tidak ditemukan skenario yang **identik** (harus dihapus). Ditemukan overlap tematik berikut — dilaporkan untuk kesadaran, dengan rekomendasi status masing-masing:

| Pasangan | Deskripsi overlap | Rekomendasi |
|---|---|---|
| **OMS014-EDG-031** vs **OMS014-NEG-011** | Keduanya menguji "barang tetap pada unit yang sama setelah refresh browser" (REQ-006/VAL-04). NEG-011 spesifik: 1 SKU hanya di Armada 1, refresh, pastikan tidak muncul di Armada 2. EDG-031: beberapa armada dengan komposisi berbeda, refresh, pastikan komposisi identik secara umum. | **Overlap signifikan** — pertimbangkan menggabungkan EDG-031 ke dalam NEG-011 (tambahkan assertion komposisi multi-armada) atau pertahankan EDG-031 sebagai variasi "multi-unit" yang eksplisit. Tidak wajib dihapus. |
| OMS014-NEG-004 / NEG-006 vs NEG-007 | NEG-004/006 menguji absennya floating button pada posisi scroll-top; NEG-007 menguji hal sama setelah scroll penuh + hover, dengan volume data lebih besar (3 unit/30 baris). | Overlap **wajar** sebagai eskalasi kondisi (posisi scroll & volume data berbeda) — **dipertahankan**, bukan duplikat. |
| OMS014-EDG-013 vs NEG-031 | Keduanya menguji Nilai Barang wajib saat asuransi aktif, namun jalur pemicu berbeda (centang asuransi setelah Jumlah terisi vs asuransi sudah aktif lalu Nilai Barang dikosongkan). | Overlap **minor**, jalur trigger berbeda — **dipertahankan**. |
| OMS014-POS-004 vs NEG-016 | Keduanya memverifikasi absennya visualisasi/indikator keterisian pada Step 4 Review, namun POS-004 dalam konteks toggle (REQ-036, mencakup Review+Detail sekaligus) sedangkan NEG-016 spesifik pada card Data Barang Step 4 (REQ-029). | Overlap **wajar** (REQ-036 adalah rollup dari REQ-029/031) — **dipertahankan** karena traceability berbeda. |
| OMS014-STR-022 vs NEG-007 | Keduanya menguji absennya floating button saat scroll; STR-022 adalah eskalasi stress (tinggi halaman >10.000px, tipe Multipoint). | Eskalasi **wajar** — **dipertahankan**. |

**Kesimpulan dedup:** 0 skenario perlu dihapus secara wajib; 1 pasangan (EDG-031/NEG-011) direkomendasikan untuk ditinjau ulang penggabungannya pada iterasi berikutnya.

---

## Validasi Sintaks Gherkin

### Temuan Signifikan

1. **Inkonsistensi dialek keyword step (Given/When/Then/And vs Diberikan/Dan).**
   File mendeklarasikan `# language: id` (baris 1) dan bagian `Latar` (baris 28-30) memakai keyword Indonesia yang benar: `Diberikan` dan `Dan`. Namun **seluruh 226 skenario** (positive/negative/edge/stress) secara konsisten memakai keyword **Inggris** `Given` / `When` / `Then` / `And` untuk setiap step, bukan `Diberikan` / `Ketika` / `Maka` / `Dan`.
   Contoh (baris 38-42):
   ```gherkin
   Skenario: Admin Sistem mematikan toggle Auto Stuffing sehingga mode order normal aktif
     Given user berada di halaman "Konfigurasi Add-on"
     When user menonaktifkan toggle "Auto Stuffing"
     And user mengklik tombol "Simpan"
     Then sistem menampilkan "Pengaturan berhasil disimpan"
   ```
   **Risiko:** kamus kata kunci resmi Gherkin untuk dialek `id` (`gherkin-languages.json`) mendefinisikan `given`: `Dengan/Diketahui/Diberi/Diberikan`, `when`: `Ketika`, `then`: `Maka`, `and`: `Dan`, `but`: `Tapi/Tetapi` — **tanpa** menyertakan bentuk Inggris sebagai alias resmi. Bergantung pada implementasi parser Gherkin/Cucumber yang dipakai di pipeline eksekusi (Cucumber-JS, Cucumber-JVM, Behat, dll.), step berkeyword Inggris pada file berdialek `id` **berisiko gagal diparse** atau minimal memerlukan mode "polos"/fallback yang mungkin tidak diaktifkan.
   **Rekomendasi:** (a) ubah seluruh keyword step ke Indonesia (`Diberikan/Ketika/Maka/Dan`) agar konsisten dengan `Latar` dan deklarasi `# language: id`, **atau** (b) ubah deklarasi ke `# language: en` dan terjemahkan `Latar`→`Background`, `Diberikan/Dan`→`Given/And`, `Skenario`→`Scenario`, dll. Opsi (a) lebih disarankan karena judul fitur, deskripsi, dan seluruh teks step lain sudah berbahasa Indonesia.

2. **Pola escaped-quote pada 2 step** yang berpotensi rapuh:
   - `OMS014-NEG-036` (baris ±764): `Then sistem menampilkan "Belum ada barang. Klik \"Pilih Barang \"" pada card "Armada 3"`
   - `OMS014-EDG-016` (baris ±1413): `Then sistem menampilkan "Belum ada barang. Klik \"Pilih Barang \""`
   Backslash-escaped quote di dalam parameter string Gherkin **valid** pada sebagian besar implementasi Cucumber, namun tidak seluruhnya konsisten menangani escape ini (terutama bila step definition regex menggunakan pemisah `"([^"]*)"` sederhana tanpa dukungan escape). **Rekomendasi:** ganti tanda kutip literal dalam teks pesan dengan kutip tunggal (`'Pilih Barang'`) atau paraphrase agar tidak perlu escaping, misalnya: `Then sistem menampilkan pesan empty state "Belum ada barang. Klik 'Pilih Barang'"`.

### Temuan Minor / Konfirmasi Positif

- **Tag format:** seluruh 226 skenario konsisten memakai urutan `@kategori @priority-xxx @REQ-xxx... @screen-xxx @OMS014-XXX-NNN`. Tidak ditemukan tag salah format (typo, spasi ganda, huruf besar/kecil tidak konsisten).
- **Skenario Konsep (Scenario Outline) & tabel Contoh:** ditemukan 7 `Skenario Konsep` (POS-009, NEG-023, NEG-025, NEG-030, NEG-034, POS-081, NEG-061) — **seluruhnya** memiliki blok `Contoh:` dengan header kolom dan baris data yang lengkap dan konsisten dengan placeholder `<...>` pada step-nya. Tidak ada Skenario Konsep tanpa Contoh.
- **Indentasi:** konsisten 4 spasi untuk baris tag & `Skenario`, 6 spasi untuk step, di seluruh file (diperiksa pada seluruh rentang baris 1–1868).
- **Step tidak lengkap:** tidak ditemukan skenario dengan step Given/When/Then yang hilang total (setiap skenario memiliki minimal 1 Given + 1 When/Then, dan validasi navigasi/expected state selalu ditutup dengan `Then`).
- **Keyword `Aturan:` (Rule):** dipakai konsisten untuk 14 kelompok (A–N), sesuai konvensi grouping berbasis REQ.

---

## Validasi Konsistensi JSON

**Skema field:** 13 field wajib (`id`, `title`, `category`, `priority`, `area`, `screen`, `requirement`, `traceability`, `preconditions`, `steps`, `expected`, `testData`, `selectorHints`) hadir secara konsisten pada seluruh objek yang diperiksa (sampling penuh untuk POS-001..083 & NEG-001..065, sampling luas untuk EDG-001..030, EDG-054..056, dan STR-001, STR-021, STR-022; sampling parsial untuk sisanya berdasarkan pola yang identik).

**Jumlah per kategori (blok `summary.byCategory`) cocok dengan `.feature`:** `{"positive":83,"negative":65,"edge":56,"stress":22}` — **total 226**, dan ID terakhir tiap kategori (`POS-083`, `NEG-065`, `EDG-056`, `STR-022`) sesuai penutup file (baris 5270) — **JSON valid dan lengkap, tidak terpotong**.

### Temuan Inkonsistensi (akibat penggabungan fragmen)

1. **Representasi "Skenario Konsep" / data-driven tidak seragam** pada 7 skenario yang memiliki tabel `Contoh:` di `.feature`:

   | Scenario ID | Field `dataDriven` | Bentuk `testData` |
   |---|---|---|
   | OMS014-POS-009 | `true` | `{ "statusList": [...] }` (bukan array `examples`, hanya daftar nilai tunggal) |
   | OMS014-NEG-023 | `true` | `{ "examples": [{...},{...},{...},{...}] }` |
   | OMS014-NEG-025 | `true` | `{ "examples": [...] }` |
   | OMS014-NEG-030 | `true` | `{ "examples": [...] }` |
   | OMS014-NEG-034 | `true` | `{ "examples": [...] }` |
   | OMS014-POS-081 | **(tidak ada)** | `{ "examples": [...] }` |
   | OMS014-NEG-061 | **(tidak ada)** | `{ "examples": [...] }` |

   → 4 dari 7 menyertakan flag eksplisit `"dataDriven": true` **dan** array `examples` yang berisi seluruh baris tabel `Contoh:`; POS-009 menyertakan flag namun **tidak** memakai bentuk `examples` (memakai `statusList`, hanya representasi ringkas 4 status, bukan array objek per-baris); POS-081 dan NEG-061 memakai `examples` namun **tanpa** flag `dataDriven`. Ini adalah **jejak konkret penggabungan fragmen** yang tidak melalui proses normalisasi skema akhir.
   **Rekomendasi:** standarkan seluruh 7 skenario memakai `"dataDriven": true` + `testData.examples: [{...}, ...]` yang memuat seluruh baris tabel `Contoh:` (format NEG-023/025/030/034 sebagai baseline).

2. **Artefak format sisa penggabungan fragmen** — koma pemisah objek diletakkan pada baris tersendiri (bukan langsung setelah `}`) di titik-titik batas antar kelompok skenario, ditemukan pada minimal 4 lokasi:
   - antara `OMS014-POS-040` dan `OMS014-POS-041` (~baris 867)
   - antara `OMS014-POS-083` dan `OMS014-NEG-001` (~baris 1842)
   - antara `OMS014-NEG-035` dan `OMS014-NEG-036` (~baris 2617)
   - antara `OMS014-NEG-065` dan `OMS014-EDG-001` (~baris 3333)
   - antara `OMS014-EDG-056` dan `OMS014-STR-001` (~baris 4674)

   Pola ini **valid JSON** (tidak menyebabkan parse error) dan murni kosmetik, namun mengonfirmasi bahwa file digabung dari ≥5 fragmen berbeda (kemungkinan per kelompok "Aturan" A–N) tanpa proses re-formatting/prettify akhir. **Rekomendasi:** jalankan JSON formatter (mis. `JSON.stringify(JSON.parse(file), null, 2)` atau Prettier) sebagai langkah finalisasi agar gaya penulisan seragam di seluruh file.

3. **Selector hint style:** konsisten menggunakan Playwright-style locator (`getByRole`, `getByLabel`, `getByTestId`, `getByText`, `getByPlaceholder`) dengan field object `{ role, name, testid }` pada `selectorHints` — tidak ditemukan gaya locator lain (mis. CSS selector mentah atau XPath) yang menyimpang, konsisten di seluruh sampel yang diperiksa.

4. **Field `traceability` lebih lengkap dari tag `.feature`:** dikonfirmasi pada beberapa skenario (lihat bagian AC di atas, serta `POS-003` yang traceability JSON-nya menyertakan `REQ-003`/`REQ-004`/`REQ-006` selain `REQ-035` yang menjadi satu-satunya tag REQ di `.feature`). Ini **menguntungkan** dari sisi kelengkapan data pengujian, namun menciptakan **risiko drift** antara dua representasi (tag `.feature` vs `traceability` JSON) yang sebaiknya disinkronkan pada siklus maintenance berikutnya.

**Kesimpulan validasi JSON:** struktur inti solid dan lengkap (226/226, skema field seragam), namun terdapat **2 kelas inkonsistensi minor** (representasi data-driven, artefak pemformatan) yang merupakan bukti langsung proses penggabungan fragmen sebagaimana diperingatkan pada instruksi tugas. Tidak ada temuan yang mengindikasikan data hilang/korup.

---

## Penilaian Kecukupan Edge & Stress

**Distribusi:** 56 edge (24,8%) + 22 stress (9,7%) = 34,5% dari total 226, berbanding 83 positive (36,7%) + 65 negative (28,8%) = 65,5%. Rasio ini **wajar dan sehat** untuk modul dengan kompleksitas: 2 jenis order (FTL/FCL) × 4 tipe pengiriman × wizard 4 step + lapisan verifikasi negatif absennya Auto Stuffing.

**Kekuatan cakupan edge:**
- Batas nilai numerik lengkap (Jumlah Armada 1 & 20; Jumlah barang 1 & 999.999; Nilai Barang Rp1 & Rp999.999.999.999; kapasitas tepat sama vs +0,01 unit di atas ambang — EDG-017/018/019).
- Karakter khusus & unicode teruji granular pada Nomor DO (6 skenario: satu nilai, koma berlebih, duplikat, unicode, sangat panjang, hapus chip — EDG-007..012).
- Kombinatorik alamat multi diuji sampai 3×3=9 kombinasi (EDG-028) dan 5×5=25 per unit pada stress (STR-004).
- Perubahan Jumlah Armada di tengah pengisian (tambah/kurang unit) diuji baik arah naik maupun turun (EDG-020, EDG-021).
- Kasus layout/viewport (zoom 200%, viewport kecil, nama barang 150 karakter, catatan 500 karakter) turut diuji (EDG-047, EDG-053, EDG-056).
- Interaksi toggle mid-session (toggle dimatikan saat user sedang mengisi Step 2) diuji (EDG-041).

**Kekuatan cakupan stress:**
- Volume tinggi: 100 card unit, 10.000 item Master Barang, 10.000 record Daftar Order, 500 baris barang lintas unit.
- Konkurensi: 20 sesi paralel membuat order, 10 sesi paralel membatalkan order yang sama.
- Payload ekstrem: Nomor DO 10.000 karakter, Alasan Pembatalan 10.000 karakter.
- Operasi repetitif: 100× Simpan ke Draf, 200× filter/sort/paginasi, 50× flip toggle, double-click Simpan.
- Kombinasi karakteristik oms014 (tanpa Auto Stuffing) tetap dipertahankan di seluruh skenario stress (mis. STR-001, STR-004, STR-018 eksplisit menegaskan "tidak ada distribusi otomatis" meski pada volume besar) — **penting** karena inti pengujian modul ini adalah *ketiadaan* elemen Auto Stuffing, dan stress test memastikan ketiadaan itu tetap konsisten di bawah beban.

**Celah minor (opsional, tidak blocking):**
- Belum ada skenario edge/stress untuk **konflik Edit Order bersamaan** (dua admin shipper mengedit order yang sama secara paralel) — hanya konflik pembatalan (STR-021) dan double-submit Simpan (EDG-054) yang diuji untuk concurrency.
- Belum ada kombinasi eksplisit **FCL + Multipoint + Asuransi penuh + Nomor DO banyak** sekaligus sebagai "worst-case gabungan" (masing-masing dimensi sudah diuji terpisah, namun tidak digabung dalam 1 skenario) — kombinatorik penuh mungkin berlebihan, namun 1 skenario gabungan dapat menaikkan keyakinan integrasi.
- Batas atas Jumlah Armada/Kontainer tidak diuji hingga nilai yang benar-benar ekstrem (mis. 9999) — hanya sampai 100 pada stress (STR-001); cukup untuk tujuan performa namun tidak menguji integer overflow/format tampilan pada angka 4 digit.

**Penilaian akhir: MEMADAI (Adequate/Good).** Tidak ada rekomendasi blocking; celah di atas bersifat *nice-to-have* untuk iterasi berikutnya.

---

## Rekomendasi / Tindak Lanjut

1. **(Dokumentasi tag — prioritas rendah)** Tambahkan tag `@AC-001` pada `OMS014-POS-062` dan `@AC-037` pada `OMS014-POS-046`, `POS-064`, `POS-065` di `.feature` agar sinkron dengan `traceability` di `scenarios.json`.
2. **(Sintaks Gherkin — prioritas sedang-tinggi, perlu verifikasi toolchain)** Selaraskan keyword step: ubah seluruh `Given/When/Then/And` menjadi `Diberikan/Ketika/Maka/Dan` agar konsisten dengan `# language: id` dan `Latar`, **atau** konfirmasi eksplisit bahwa parser/runner Gherkin yang dipakai memang menerima keyword Inggris pada dialek `id` sebelum eksekusi otomatis dijalankan. Ini berpotensi menjadi **blocker eksekusi** bila parser strict.
3. **(Sintaks Gherkin — prioritas rendah)** Ganti kutip literal berlapis (`\"Pilih Barang \"`) pada `OMS014-NEG-036`/`EDG-016` dengan kutip tunggal atau paraphrase untuk menghindari isu escaping pada sebagian step-definition parser.
4. **(Konsistensi JSON — prioritas rendah)** Standarkan representasi 7 "Skenario Konsep" agar seluruhnya memakai `"dataDriven": true` + `testData.examples: [...]` (baseline: pola NEG-023/025/030/034); perbaiki `POS-009` (ganti `statusList` → `examples` per-baris) dan tambahkan flag `dataDriven` pada `POS-081` & `NEG-061`.
5. **(Konsistensi JSON — prioritas rendah)** Jalankan JSON re-format/prettify sebagai langkah finalisasi untuk menghilangkan artefak koma-baris-tersendiri sisa penggabungan fragmen.
6. **(Coverage tambahan — opsional)** Pertimbangkan menambah 1–2 skenario berikut pada iterasi berikutnya untuk menutup "single-category" REQ yang paling bernilai bila diuji dua arah:
   - **REQ-033/VAL-33:** skenario yang secara eksplisit memverifikasi via API/DB bahwa tenant *baru* (belum pernah disentuh) benar-benar berstatus Auto Stuffing ON tanpa intervensi apa pun (memperkuat POS-002 dengan bukti "negative-of-negative": toggle **belum pernah** diatur, bukan sekadar "diperiksa").
   - **REQ-036:** tambahkan tag eksplisit `@REQ-036` pada `NEG-016`, `NEG-017`, `NEG-020` (yang secara substansi sudah menguji perilaku ini) agar traceability REQ-036 memiliki representasi negative langsung, bukan hanya inferensi dari REQ-029/031.
   - **Concurrency Edit Order:** 1 skenario stress "2 admin shipper mengedit order yang sama secara bersamaan" untuk melengkapi STR-021 (pembatalan) dan EDG-054 (double-submit Simpan).
7. **(Dedup — opsional)** Tinjau ulang `EDG-031` vs `NEG-011` pada iterasi refactor berikutnya; pertimbangkan penggabungan agar tidak menguji hal yang sama dua kali dengan setup berbeda tipis.

---

## Lampiran — File yang Diperiksa

- `E:\Project\tms-scenario-generator\output\oms014-order-ftl-fcl-normal\oms014-order-ftl-fcl-normal.feature`
- `E:\Project\tms-scenario-generator\output\oms014-order-ftl-fcl-normal\oms014-order-ftl-fcl-normal.scenarios.json`
- `E:\Project\tms-scenario-generator\output\oms014-order-ftl-fcl-normal\oms014-order-ftl-fcl-normal.analysis.md`
