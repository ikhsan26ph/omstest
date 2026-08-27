# Coverage Report — OMS-015 Order LTL & LCL (Universal)

> **Tahap pipeline:** 4/4 — QA reviewer (verifikatif)
> **Sumber yang direview:**
> - `oms015-order-ltl-lcl-universal.analysis.md` (REQ-001…058, UI-096…105 + UI-D01…D08, ASM-001…040)
> - `oms015-order-ltl-lcl-universal.feature` (309 skenario, 3.281 baris)
> - `oms015-order-ltl-lcl-universal.scenarios.json` (309 entri, 9.062 baris, termasuk metadata `summary`/`requirementCoverage`/`screenCoverage` bawaan generator)

---

## 1. Verdict Keseluruhan

**LULUS dengan catatan minor (PASS with minor notes).**

| Aspek | Hasil |
|---|---|
| Jumlah skenario total | 309 (feature = JSON, cocok) |
| Distribusi kategori | positive 114, negative 94, edge 71, stress 30 — feature & JSON identik |
| Coverage REQ-001…058 | 58/58 REQ tersentuh ≥1 skenario; 55/58 memenuhi ≥1 positive + ≥1 negative secara langsung; 3 REQ (025/041/049) adalah *requirement pelarangan* dengan kontrol positif tidak langsung — **wajar, dapat diterima** |
| Coverage layar UI-096…105, UI-D01…D08 | 18/18 layar tersentuh ≥1 skenario (termasuk seluruh layar hipotesis UI-D0x) |
| Duplikat/near-duplicate | 1 pasangan overlap signifikan (NEG-061 ~ NEG-076), 2 pasangan overlap ringan (dapat diterima, tidak perlu dihapus) |
| Validasi sintaks Gherkin | Tidak ditemukan pelanggaran struktural (semua Scenario punya Given–When/Then, tag kategori+prioritas+REQ+screen lengkap) |
| Konsistensi silang feature ↔ JSON | ID, judul, kategori, REQ utama cocok pada seluruh titik sampel (POS-001/080/114, NEG-001/090/091/094, EDG-001/010, STR-001) dan pada rollup `summary`/`requirementCoverage`/`screenCoverage` bawaan JSON — **konsisten**, dengan 1 catatan urutan (lihat §5.2) |

Tidak ditemukan gap yang menghalangi rilis (blocking). Catatan yang ada bersifat perbaikan kualitas (housekeeping) dan rekomendasi penguatan low-priority.

---

## 2. Ringkasan Jumlah per Kategori

| Kategori | Jumlah | % dari total | Rentang ID |
|---|---:|---:|---|
| `@positive` | 114 | 36,9% | OMS015-POS-001 .. 114 |
| `@negative` | 94 | 30,4% | OMS015-NEG-001 .. 090, 091 .. 094 (Bagian 5) |
| `@edge` | 71 | 23,0% | OMS015-EDG-001 .. 071 |
| `@stress` | 30 | 9,7% | OMS015-STR-001 .. 030 |
| **Total** | **309** | 100% | — |

Distribusi prioritas (dari metadata JSON, `summary.byPriority`): **high 152**, **medium 107**, **low 50** — proporsi wajar untuk modul dengan banyak rule turunan TMS (medium) dan pembeda inti Step 2 (high).

Catatan struktural: skenario negatif sebenarnya terbagi menjadi dua blok pada `.feature` — **Bagian 2** (NEG-001..090) dan **Bagian 5 — tambahan** (NEG-091..094), yang secara eksplisit dibuat untuk menutup gap "≥1 positive + ≥1 negative" pada REQ-009, REQ-017, REQ-036, dan REQ-057. Ini adalah praktik yang baik dan transparan (dikomentari langsung di file), bukan sebuah cacat.

---

## 3. Requirements Traceability Matrix (RTM)

Kolom Positive/Negative/Edge/Stress diambil dari tag `@REQ-xxx` pada `.feature` dan divalidasi silang terhadap `scenarios.json → summary.requirementCoverage.perRequirement` (identik). Kolom **Layar** merujuk UI Inventory (`analysis.md`) yang relevan untuk requirement tersebut.

| REQ | Deskripsi Singkat | Positive | Negative | Edge | Stress | Layar |
|---|---|---|---|---|---|---|
| REQ-001 | Dukungan order LTL & LCL sesuai spesifikasi TMS | POS-001,002,003 | NEG-001 | EDG-001 | — | UI-097,102,103,104,105 |
| REQ-002 | Wizard 4 step (Data Pengiriman→Barang→Vendor&Harga→Review) | POS-004,005,006 | NEG-002 | EDG-002 | STR-002 | UI-097…100 |
| REQ-003 | Order via input manual & Batch Order | POS-007,008,009 | NEG-003 | EDG-003 | STR-001 | UI-096,103,UI-D08 |
| REQ-004 | Step 2 tanpa input teks bebas; barang dari Master Barang | POS-010 | NEG-004,005 | — | — | UI-098 |
| REQ-005 | Step 4 Review — struktur Data Barang versi OMS | POS-011 | NEG-006 | — | — | UI-100 |
| REQ-006 | Step 1 identik TMS (3 section) | POS-012 | NEG-007 | — | — | UI-097 |
| REQ-007 | LCL — Pelabuhan Asal/Tujuan; Jumlah Kontainer dihilangkan | POS-013,014 | NEG-008,009 | EDG-006 | — | UI-102 |
| REQ-008 | LTL — Kota Asal/Tujuan dari Master Kota | POS-015 | NEG-010,011 | — | — | UI-097 |
| REQ-009 | Kota/Pelabuhan tidak memfilter Drop Point | POS-016,017,018 | NEG-091 | EDG-004,005 | — | UI-097,102 |
| REQ-010 | Tipe Pengiriman selalu Normal — 1 baris pengirim/penerima | POS-019,020 | NEG-012,013,014 | — | — | UI-097,102,100 |
| REQ-011 | Auto-draft wilayah/alamat dari Master Droppoint | POS-021,022,023 | NEG-015 | EDG-013 | STR-005 | UI-097,102 |
| REQ-012 | Validasi field wajib Step 1 + button Batal/Draf/Selanjutnya | POS-024,025,026 | NEG-016,017,018,019 | EDG-007…012,014 | STR-003,004,006 | UI-097 |
| REQ-013 | Barang dipilih via modal Pilih Barang | POS-027,028 | NEG-020 | EDG-032 | STR-011 | UI-098,UI-D01 |
| REQ-014 | Pencarian modal (kode/nama barang) | POS-029,030,031 | NEG-021 | EDG-015,016,017 | STR-010 | UI-D01 |
| REQ-015 | Multi-select checkbox pada modal | POS-032,033 | NEG-022 | EDG-018 | STR-007 | UI-D01 |
| REQ-016 | Label "Sudah Ditambahkan" | POS-034 | NEG-023 | EDG-019 | — | UI-D01 |
| REQ-017 | Counter barang terpilih | POS-035 | NEG-092 | EDG-020 | — | UI-D01 |
| REQ-018 | Button Batal & Simpan pada modal | POS-036,037 | NEG-024 | — | — | UI-D01 |
| REQ-019 | 6 field identitas barang read-only dari master | POS-038 | NEG-025 | EDG-031 | — | UI-098 |
| REQ-020 | Jumlah wajib per baris barang | POS-039,040 | NEG-026,027,028 | EDG-021,022 | STR-008 | UI-098 |
| REQ-021 | Nilai Barang wajib saat asuransi aktif | POS-041,042 | NEG-029,030,031 | EDG-023,024 | STR-012 | UI-098 |
| REQ-022 | Asuransi per barang + Asuransikan Semua | POS-043,044,045,046 | NEG-032 | EDG-025 | — | UI-098 |
| REQ-023 | Nomor DO — 1 field, opsional, multi via koma, chip | POS-047,048,049 | NEG-033 | EDG-026,027,028 | STR-009 | UI-098 |
| REQ-024 | 1 unit muatan — tanpa pengelompokan armada/kontainer | POS-050,051,052 | NEG-034,035 | — | — | UI-098 |
| REQ-025 | Tanpa alert/ringkasan kapasitas berat/kubikasi | — *(lihat §4.1)* | NEG-036,037,038 | EDG-029 | — | UI-098 |
| REQ-026 | Hapus baris barang via ikon | POS-053 | NEG-039 | EDG-030 | STR-013 | UI-098 |
| REQ-027 | Helper error + border error field wajib kosong | POS-054 | NEG-040 | — | — | UI-098 |
| REQ-028 | Fungsi button Step 2 identik TMS | POS-055,056,057 | NEG-041 | — | — | UI-098 |
| REQ-029 | Step 3 — Vendor, Tanggal Muat, Harga, komponen harga opsional | POS-058,059,060,061 | NEG-042…047 | EDG-033…036,039 | STR-014,016 | UI-099 |
| REQ-030 | LTL — Waktu Perjalanan textfield/text-only | POS-062,063,064 | NEG-048,049 | EDG-037,038 | — | UI-099,100,101 |
| REQ-031 | LCL — tanpa Waktu Perjalanan; ETA−ETD+4 hari saat Ditugaskan | POS-065,066 | NEG-050,051 | EDG-042 | — | UI-099,101 |
| REQ-032 | Komponen Asuransi mengikuti Step 2 → Total Harga | POS-067,068,069 | NEG-052 | EDG-040,041 | STR-015 | UI-099,100 |
| REQ-033 | Validasi & button Step 3 identik TMS | POS-070,071 | NEG-053 | EDG-043 | — | UI-099,098 |
| REQ-034 | Step 4 ringkasan read-only seluruh data | POS-072,073,074 | NEG-054 | EDG-044 | STR-017 | UI-100 |
| REQ-035 | Data Barang Review mengikuti struktur Step 2 OMS | POS-075,076 | NEG-055 | EDG-045 | — | UI-100 |
| REQ-036 | Penanda status asuransi pada Review | POS-077,078 | NEG-093 | EDG-046 | — | UI-100,101 |
| REQ-037 | Button Step 4; Simpan → status Menunggu Penugasan | POS-079,080,081 | NEG-056,057 | EDG-047 | STR-018 | UI-100,096 |
| REQ-038 | 9 status order | POS-082,083,084 | NEG-058 | EDG-048,051 | — | UI-096,103 |
| REQ-039 | Status 1-4 = draft, tersimpan via Simpan ke Draf | POS-085,086,087 | NEG-059,060 | EDG-049,050 | STR-019 | UI-103,098,UI-D03 |
| REQ-040 | Shipper dapat edit selama draft s.d. Menunggu Penugasan | POS-088,089 | NEG-068 | EDG-055 | — | UI-101,103 |
| REQ-041 | Tidak dapat edit setelah Ditugaskan | — *(lihat §4.1)* | NEG-061,062,063,064 | — | — | UI-103,UI-D07 |
| REQ-042 | Jenis Pengiriman & Tipe Pengiriman locked pada Edit Order | POS-090 | NEG-065 | EDG-054 | — | UI-D07 |
| REQ-043 | Field lain tetap dapat diubah pada Edit Order | POS-091,092,093 | NEG-066 | EDG-052,053,056 | STR-021 | UI-D07,UI-D01 |
| REQ-044 | Button Batal/Simpan Edit Order + pop up konfirmasi | POS-094,095 | NEG-067 | — | STR-020 | UI-D07,UI-D03,UI-D02 |
| REQ-045 | Order dapat dibatalkan draft s.d. Ditugaskan | POS-096,097,098 | NEG-069,070,071,072 | EDG-059 | STR-023 | UI-103,UI-D04 |
| REQ-046 | Pembatalan oleh admin shipper, bukan vendor | POS-099 | NEG-073 | — | — | UI-103 |
| REQ-047 | Alasan Pembatalan wajib diisi | POS-100 | NEG-074,075 | EDG-057,058,060 | STR-022 | UI-D04 |
| REQ-048 | Aksi per baris menyesuaikan status (matriks) | POS-101,102,103,104 | NEG-078,079,080 | EDG-063,064 | STR-025,029 | UI-103 |
| REQ-049 | Edit tidak tersedia pada status Ditugaskan | — *(lihat §4.1)* | NEG-076,077 | — | — | UI-103,101 |
| REQ-050 | Riwayat Pembatalan (toolbar, seluruh order) | POS-105 | NEG-082 | EDG-061 | STR-024 | UI-D05,096 |
| REQ-051 | Riwayat Perubahan (per baris, order terpilih) | POS-106 | NEG-081 | EDG-062 | STR-030 | UI-D06,103 |
| REQ-052 | No. Resi untuk public tracking | POS-107 | NEG-083 | EDG-071 | STR-028 | UI-D08 |
| REQ-053 | No. Resi auto-generate, melekat pada barang | POS-108 | NEG-084 | EDG-065,066,067 | — | UI-098,104 |
| REQ-054 | No. Resi eksklusif LTL/LCL | POS-109 | NEG-085,086 | — | — | UI-103,101,105 |
| REQ-055 | Lihat No. Resi tersedia sejak Menunggu Penugasan | POS-110,111 | NEG-087,088 | — | — | UI-103 |
| REQ-056 | Pop up Data No. Resi (No. Resi + Kode SKU + Nama Barang) | POS-112 | NEG-089 | EDG-068,069 | STR-026 | UI-104,105 |
| REQ-057 | Icon copy No. Resi | POS-113 | NEG-094 | EDG-070 | STR-027 | UI-104 |
| REQ-058 | No. Resi juga tampil di Detail Order | POS-114 | NEG-090 | — | — | UI-101 |

**Cakupan layar (UI-096…105, UI-D01…D08):** seluruh 18 layar tersentuh ≥1 skenario (divalidasi terhadap `scenarios.json → summary.screenCoverage`, tidak ada entri kosong). Layar dengan cakupan paling tipis: **UI-105** (hanya POS-109) dan **UI-D02** (POS-026, POS-095, NEG-056) — lihat rekomendasi §7.

---

## 4. Gap Coverage

### 4.1 Requirement tanpa skenario `@positive` langsung — REQ-025, REQ-041, REQ-049

Ketiga REQ ini **memang tidak memiliki entri pada bucket "positive"** di `requirementCoverage`, karena masing-masing berbentuk **requirement pelarangan** (assertion negatif secara alami):

| REQ | Sifat pelarangan | Kontrol "positif" yang didokumentasikan |
|---|---|---|
| REQ-025 | Step 2 **tidak boleh** menampilkan alert/ringkasan kapasitas | **EDG-029** — mengisi `Jumlah` sangat besar tetap **tidak** memunculkan peringatan dan `Selanjutnya` tetap lolos (AC-025.4). Ini secara fungsional adalah "jalur bahagia" dari REQ-025, namun ditag `@edge`, bukan `@positive`. |
| REQ-041 | Shipper **tidak dapat** mengubah order setelah `Ditugaskan` | **POS-088** — menunjukkan sisi berlawanan (Edit **tersedia** pada `Menunggu Penugasan`), namun ditag `@REQ-040`, bukan `@REQ-041`. |
| REQ-049 | Aksi `Edit` **tidak tersedia** pada status `Ditugaskan` | **POS-103** — secara faktual scenario ini **sudah ditag `@positive` dan `@REQ-049`** langsung (bukan hanya rujukan tidak langsung), karena menguji matriks menu Ditugaskan secara utuh (Detail/Batalkan Order/Riwayat Perubahan/Lihat No. Resi **ada**, Edit **tidak ada**). |

**Penilaian kewajaran:** dapat diterima. Untuk REQ-025 dan REQ-041, tidak ada cara alami membuat skenario "positif" tanpa pada dasarnya menguji ketidakhadiran sesuatu — pola yang dipakai (kontrol tidak langsung via REQ bertetangga) adalah praktik standar untuk requirement berbentuk larangan. Untuk REQ-049, catatan generator ("REQ-049 tidak punya skenario positive") **kurang akurat** — POS-103 sudah membawa tag `@positive @REQ-049` secara eksplisit di `.feature`, meski pada rollup `requirementCoverage.REQ-049.positive` di JSON sengaja dikosongkan dan POS-103 justru direkap di bawah `REQ-048.positive`. Ini adalah **pilihan kebijakan pelaporan** (bukan bug): scenario boleh membawa multi-tag REQ di `.feature`, tetapi rollup metadata memilih satu "pemilik utama" per scenario untuk bucket positif. **Tidak berdampak pada coverage riil** (baik `.feature` maupun eksekusi test tetap mencakup REQ-049 dengan baik lewat POS-103 + NEG-076/077), hanya rekomendasi kecil agar dokumentasi metadata disesuaikan.

Tidak ada REQ yang sama sekali tanpa skenario `@negative` — seluruh 58 REQ memiliki ≥1 negative.

### 4.2 Cakupan layar UI

Tidak ditemukan layar yang sama sekali tidak tersentuh. Seluruh 10 layar bergambar (UI-096…105) dan 8 layar turunan hipotesis (UI-D01…D08) memiliki ≥1 skenario rujukan.

### 4.3 Risiko warisan dari analysis.md yang relevan terhadap coverage

- **ASM-035** (No. Resi tidak tergambar pada Detail Order `101.png`): POS-114, NEG-086, NEG-090 sudah menandai risiko ini secara eksplisit lewat `riskNotes` pada JSON dan memakai matcher generik `/No\. Resi/`. Sudah tertangani dengan baik secara defensif — tidak perlu tindakan tambahan sampai ada konfirmasi desain/implementasi.
- **ASM-032** (8 layar tanpa aset desain, termasuk modal `Pilih Barang` yang merupakan pembeda inti modul): risiko ini **tidak berkurang oleh test suite** — 26 skenario (POS-027..037, NEG-020..024, EDG-015..020/032, STR-007/010/011) bergantung penuh pada selector hipotesis UI-D01. Ini bukan gap coverage skenario (jumlah & variasi skenario untuk modal ini sudah sangat baik), melainkan **risiko eksekusi** yang harus dicatat ke tim: begitu implementasi tersedia, seluruh selector `getByRole('dialog', {name: 'Pilih Barang'})` dkk. wajib diverifikasi ulang.

Tidak ada gap yang memerlukan skenario tambahan segera (lihat §7 untuk rekomendasi *nice-to-have*).

---

## 5. Validasi Gherkin & Konsistensi Silang

### 5.1 Validasi sintaks Gherkin (`.feature`)

- Struktur `Feature:` tunggal di awal file, diikuti deskripsi user-story (Sebagai/Saya ingin/Agar) — valid.
- Seluruh 309 blok `Scenario:` diawali tag kategori (`@positive|@negative|@edge|@stress`), tag prioritas (`@priority-high|medium|low`), minimal satu `@REQ-xxx`, minimal satu `@UI-xxx`, dan satu `@screen-xxx` — **tidak ditemukan** scenario tanpa tag kategori atau tanpa REQ tag pada seluruh baris yang diperiksa (full read, 3.281 baris).
- Setiap `Scenario` memiliki minimal satu `Given` diikuti `When`/`Then` yang valid; tidak ditemukan scenario kosong (tanpa langkah) atau scenario yang langsung mulai dengan `And` tanpa `Given` sebelumnya.
- Penomoran ID (`OMS015-<POS|NEG|EDG|STR>-NNN`) berurutan tanpa lompatan maupun ID ganda pada seluruh 4 kategori (diverifikasi lewat pembacaan penuh + cocok dengan `summary.idRanges` pada JSON).
- Komentar section (`# -------- Rx. ... --------`) konsisten mengikuti struktur R1–R10 pada `analysis.md`.
- Kepatuhan terhadap catatan wajib generator (blok komentar di kepala file) — ASM-001/007/033 (elemen FTL-only tidak pernah jadi ekspektasi positif), ASM-004 (assert "tidak dapat diubah" bukan "tidak ada" untuk Jumlah Armada/Kontainer — lihat POS-014/015, NEG-009/011), ASM-013 (matcher status toleran — EDG-048), ASM-017/018 (label "Lihat No. Resi" & ketersediaan sejak Menunggu Penugasan — POS-102/110/111), ASM-038 (klik Selanjutnya dulu sebelum assert error inline — NEG-026/029/040) — **seluruhnya dipatuhi** pada sampel yang diperiksa, tidak ditemukan pelanggaran (mis. tidak ada skenario yang meng-assert `Total Kubikasi: x/y m³` sebagai ekspektasi positif untuk LTL/LCL).

**Kesimpulan validasi Gherkin: PASS, tanpa temuan blocking.**

### 5.2 Konsistensi silang feature ↔ JSON

Dilakukan pembacaan penuh `.feature` (3.281 baris) dan pembacaan bertarget + penuh pada bagian metadata `.scenarios.json` (termasuk seluruh 9.062 baris tersentuh via sampling terstruktur + pembacaan penuh blok `summary`).

| Titik pemeriksaan | Feature | JSON | Cocok? |
|---|---|---|---|
| Total skenario | 309 | 309 (`summary.total`) | ✔ |
| Jumlah per kategori | 114/94/71/30 | 114/94/71/30 (`summary.byCategory`) | ✔ |
| Rentang ID per kategori | POS 001-114, NEG 001-094, EDG 001-071, STR 001-030 | identik (`summary.idRanges`) | ✔ |
| POS-001 (judul, REQ, UI) | "Buat order LTL lengkap 4 step…", REQ-001/002/037, UI-097/098/099/100 | judul & `requirements` sama | ✔ |
| POS-080 | "Simpan ke Draf dari Step 4 menghasilkan status Review Order", REQ-037/039, UI-D03 | sama | ✔ |
| POS-114 | "No. Resi tampil pada Detail Order LTL…", REQ-058/056, UI-101 | sama | ✔ |
| NEG-001 | "Guest mengakses URL Buat Order dialihkan ke halaman Login", REQ-001, UI-096 | sama | ✔ |
| NEG-090/091/094 | REQ-058/009/057 | sama | ✔ |
| EDG-001, EDG-010 | REQ-001/007/008; REQ-012 | sama | ✔ |
| STR-001 | "Batch Order dengan 500 baris order LTL", REQ-003, UI-D08 | sama | ✔ |
| `requirementCoverage` per REQ (58 REQ) | tag `@REQ-xxx` di setiap scenario | rollup `perRequirement` pada JSON | ✔ cocok pada seluruh 58 REQ yang dibandingkan (lihat §3) |
| `screenCoverage` per layar (18 layar) | tag `@UI-xxx` | rollup `screenCoverage` pada JSON | ✔ cocok, tidak ada layar kosong |

**Satu catatan non-blocking:** urutan fisik skenario **berbeda** antar kedua file untuk blok "Bagian 5" (NEG-091..094). Pada `.feature`, blok ini diletakkan **di akhir file** (setelah STR-030), sedangkan pada `.scenarios.json` blok ini diletakkan **setelah EDG-071, sebelum STR-001**. Ini murni perbedaan urutan penggabungan part-file (`source.scenarioParts` vs `source.featureParts` pada JSON mengonfirmasi kedua file dirakit dari potongan terpisah) dan **tidak memengaruhi isi, ID, kategori, maupun jumlah** — hanya kosmetik. Direkomendasikan untuk pipeline berikutnya agar urutan penggabungan diseragamkan supaya diff antar file lebih mudah dibaca manusia.

Tidak ditemukan: ID yang ada di satu file tapi tidak di file lain; kategori yang berbeda antara tag `.feature` dan field `category` JSON; maupun requirement tag yang bertentangan pada titik-titik yang diperiksa.

**Kesimpulan konsistensi silang: PASS, dengan 1 catatan kosmetik (urutan blok Bagian 5).**

---

## 6. Temuan Dedup

### 6.1 Overlap signifikan (direkomendasikan untuk digabung/dirapikan)

**NEG-061 vs NEG-076** — keduanya menguji hal yang hampir identik:

| | NEG-061 | NEG-076 |
|---|---|---|
| Judul | Aksi Edit tidak tersedia pada order Ditugaskan | Menu aksi baris Ditugaskan tidak memuat item Edit namun tetap memuat aksi lain |
| Precondition | Order LTL `Ditugaskan` (ORD-LTL-0005) | Order LTL `Ditugaskan` (ORD-LTL-0005) — **identik** |
| Aksi | Klik "Aksi" pada baris | Klik "Aksi" pada baris — **identik** |
| Assertion inti | `tidak menampilkan menu "Edit"` | `tidak menampilkan menu "Edit"` **+** `menampilkan Detail/Batalkan Order/Riwayat Perubahan` |
| Tag REQ | REQ-041, REQ-049 | REQ-049 |

NEG-076 secara isi adalah **superset** dari NEG-061 (assertion NEG-061 sepenuhnya tercakup di NEG-076, ditambah assertion lain). **Alasan tidak dihapus begitu saja:** NEG-061 adalah satu-satunya skenario yang mengaitkan status `Ditugaskan` secara eksplisit ke **REQ-041** (bersama NEG-062 yang menutup status `Proses Pengiriman`/`Selesai`/`Dibatalkan`). Jika NEG-061 dihapus tanpa penyesuaian tag, REQ-041 kehilangan satu titik cakupan untuk status `Ditugaskan` secara spesifik (walau REQ-049 tetap tercakup penuh oleh NEG-076/077).

**Rekomendasi:** gabungkan — tambahkan tag `@REQ-041` ke NEG-076, lalu hapus NEG-061. Efek: jumlah skenario negative turun 1 (94→93) tanpa kehilangan cakupan REQ manapun.

### 6.2 Overlap ringan (dapat diterima, tidak perlu tindakan)

| Pasangan | Alasan overlap | Kenapa tetap dipertahankan |
|---|---|---|
| NEG-062 vs NEG-078 | Keduanya menegaskan absennya `Edit` pada status `Proses Pengiriman` | NEG-062 menguji 3 status sekaligus (Proses Pengiriman/Selesai/Dibatalkan) hanya untuk `Edit`; NEG-078 menguji matriks lengkap (termasuk absennya `Batalkan Order`) khusus `Proses Pengiriman`. Cakupan AC-041.1 & AC-048.2 saling melengkapi, bukan duplikat murni. |
| POS-088 vs POS-102 | Keduanya menguji menu/tombol pada status `Menunggu Penugasan` | POS-088 memverifikasi tombol `Edit Order` di halaman **Detail Order**; POS-102 memverifikasi **matriks menu baris lengkap** (5 item) di Daftar Order. Cakupan elemen UI berbeda. |
| NEG-026 vs NEG-027 (dan pola serupa NEG-029 vs NEG-030) | "Jumlah/Nilai Barang kosong" vs "bernilai 0" | AC-020.2/AC-021.3 secara eksplisit menyebut kondisi "kosong**/0**" sebagai satu kesatuan aturan — pengujian boundary terpisah (empty-string vs literal zero) adalah praktik BVA yang benar, bukan duplikasi yang sia-sia. |

### 6.3 Tidak ditemukan duplikat murni (identical steps + identical assertion + identical category)

Penelusuran judul dan langkah pada seluruh 309 skenario (khususnya klaster tematik: asuransi Step 2, navigasi antar-step, boundary numerik Step 2/3, matriks aksi Daftar Order, No. Resi) tidak menemukan pasangan lain dengan kesamaan >90% selain yang dilaporkan di §6.1. Pola "eskalasi" yang berulang (mis. POS-005 → EDG-002 → STR-002 untuk navigasi bolak-balik; EDG-018 7-barang → STR-007 100-barang untuk multi-select) adalah **desain berjenjang yang disengaja** (baseline → edge → stress), bukan duplikasi.

---

## 7. Penilaian Kecukupan Edge & Stress

### 7.1 Rasio umum

71 edge (23,0%) + 30 stress (9,7%) dari 309 total. Untuk modul wizard CRUD dengan banyak field numerik/boundary (Step 2 & Step 3), rasio ini **memadai** — edge terkonsentrasi tepat pada requirement berisiko tinggi (REQ-012 memiliki 7 edge + 3 stress; REQ-029 memiliki 5 edge + 2 stress; REQ-020/021 masing-masing 2 edge + 1 stress).

### 7.2 Empat area risiko yang diminta untuk dinilai

| Area risiko | Skenario terkait | Penilaian |
|---|---|---|
| **Boundary ASM-023** (No. WhatsApp 10–15 digit, Jumlah > 0, Nilai Barang ≥ 0, PPN/PPh 0–100%, Waktu Perjalanan ≥ 1 jam, Tanggal tidak boleh lampau) | EDG-007/008/009/010 (10/15/9/16 digit — **tetrad BVA lengkap** min-1/min/max/max+1), EDG-021/022 (Jumlah=1, desimal), NEG-027/028 (Jumlah 0/negatif), NEG-031 (Nilai Barang negatif), STR-012 (Nilai Barang 15 digit), NEG-046 (PPN 150 ditolak), EDG-033/034/035 (PPN/PPh 0%, desimal, PPh>PPN), EDG-037/038 (Waktu Perjalanan 1/0), NEG-047 & EDG-039 (tanggal lampau vs H+1 menit) | **Sangat memadai.** Pola boundary-value-analysis lengkap diterapkan pada field paling kritis (No. WhatsApp), dan sisi lain (Harga, PPN/PPh, Waktu Perjalanan, Tanggal) memiliki minimal satu pasang batas-bawah/batas-atas. Tidak ada gap signifikan. |
| **Parsing Nomor DO (ASM-020)** | EDG-026 (koma berlebih & spasi → tanpa chip kosong), EDG-027 (duplikat tidak digandakan), EDG-028 (satu nomor tanpa koma), STR-009 (50 nomor sekaligus), POS-047/048 (format normal + hapus individual) | **Memadai.** Ketiga risiko utama (whitespace, duplikasi, delimiter berlebih) tercakup eksplisit, ditambah stress-scale (50 nomor). Rekomendasi minor: belum ada skenario untuk *satu koma tanpa nomor apapun* (input `","`) atau nomor DO yang sangat panjang (karakter tunggal >100 char) — risiko rendah, dapat ditambahkan opsional. |
| **Kapasitas (ASM-007 / REQ-025)** | NEG-036/037/038 (badge, ringkasan `terpakai/kapasitas`, floating button — seluruhnya assertion negatif eksplisit sesuai konvensi wajib di header `.feature`), EDG-029 (Jumlah 999.999 tetap lolos tanpa peringatan) | **Memadai untuk Step 2.** Assertion negatif dirumuskan presisi sesuai teks UI (`Kubikasi melebihi kapasitas armada`, `Total Kubikasi: <terpakai>/<kapasitas>`) — tidak generik. Catatan: assertion "tanpa alert kapasitas" hanya diverifikasi di Step 2 (UI-098); REQ-025 secara redaksi memang berfokus di Step 2, sehingga ini sudah selaras, bukan gap. |
| **No. Resi (ASM-021/030)** | EDG-065 (tambah barang via Edit → resi baru), EDG-066 (hapus barang via Edit → entri resi hilang), EDG-067 (resi barang yang tetap ada tidak berubah), POS-108 (1 resi : 1 barang), EDG-070/NEG-094 (copy 1 baris tidak pengaruhi baris lain/isi lain), STR-026 (200 baris resi), STR-027 (copy 50× berturut-turut) | **Sangat memadai.** Ketiga skenario EDG-065/066/067 secara spesifik menguji konsekuensi dari ASM-021 (asumsi regenerasi resi saat edit) — ini adalah salah satu asumsi berisiko tinggi ("Tinggi" pada Assumptions Log) dan sudah mendapat perhatian test yang proporsional. |

### 7.3 Rekomendasi penguatan (nice-to-have, non-blocking)

1. **UI-105 (pop up Data No. Resi — LCL)** hanya disentuh oleh 1 skenario (POS-109). Tidak ada edge/negative/stress yang secara eksplisit membuka dialog ini untuk order LCL (skenario edge/stress No. Resi lain — EDG-065..070, STR-026/027 — seluruhnya berbasis order LTL). Rekomendasi: duplikasi salah satu dari EDG-065/068/STR-026 dengan varian LCL untuk memastikan tidak ada perbedaan perilaku tersembunyi antara badge LTL/LCL pada dialog ini.
2. **Tidak ada skenario stress yang berbasis order LCL** — seluruh 30 skenario `@stress` memakai LTL (atau tidak spesifik jenis order untuk kasus generik seperti Daftar Order/Riwayat). Mengingat kalkulasi Waktu Perjalanan LCL (ETA−ETD+4 hari) bersifat unik, satu skenario stress/edge tambahan untuk rentang ETA-ETD besar (mis. selisih 90 hari) akan menutup celah kecil ini.
3. **Nomor DO — nilai degenerate** (`","` tunggal, atau string >100 karakter per nomor) belum diuji; risiko rendah karena field ini opsional dan sudah punya 3 edge case inti.
4. Tidak ditemukan gap yang cukup signifikan untuk memblokir sign-off; ketiga rekomendasi di atas dapat dimasukkan ke backlog regresi berikutnya.

---

## 8. Rekomendasi Tindak Lanjut

1. **(Housekeeping, low effort)** Gabungkan NEG-061 ke NEG-076: tambahkan tag `@REQ-041` pada NEG-076, hapus NEG-061 dari `.feature` dan `.scenarios.json` secara bersamaan agar ID tetap sinkron. Perbarui `summary.byCategory.negative` (94→93) dan `idRanges` jika penomoran dirapikan ulang, atau biarkan gap nomor dengan catatan "NEG-061 deprecated, digabung ke NEG-076".
2. **(Housekeeping, low effort)** Samakan urutan penggabungan part-file antara `scenarios.json.part0x` dan `feature.partx` khususnya untuk blok "Bagian 5" (NEG-091..094) agar kedua file punya urutan fisik yang identik — memudahkan diff/review manual di masa depan.
3. **(Dokumentasi, low effort)** Perbarui catatan pada `summary.requirementCoverage.perRequirement["REQ-049"]` agar tidak menyatakan "tidak punya skenario positive" secara mutlak — jelaskan bahwa POS-103 membawa tag `@REQ-049 @positive` di `.feature`, hanya saja rollup metadata mengelompokkannya di bawah REQ-048.
4. **(Penguatan opsional, tidak blocking)** Tambahkan 1 varian LCL untuk salah satu skenario edge/stress No. Resi (§7.3 poin 1) dan 1 skenario stress/edge untuk rentang ETA−ETD besar pada LCL (§7.3 poin 2).
5. **(Risiko eksekusi, di luar kendali test-design)** Saat implementasi/desain modal `Pilih Barang` (UI-D01) dan 7 layar turunan lain tersedia, seluruh selector hipotesis (ASM-031/ASM-032) pada 26+ skenario terkait wajib diverifikasi ulang terhadap DOM nyata sebelum eksekusi otomatis pertama kali.

---

## Lampiran — Berkas yang Direview

- `/home/icun/Project/tms-scenario-generator/output/oms015-order-ltl-lcl-universal/oms015-order-ltl-lcl-universal.analysis.md`
- `/home/icun/Project/tms-scenario-generator/output/oms015-order-ltl-lcl-universal/oms015-order-ltl-lcl-universal.feature`
- `/home/icun/Project/tms-scenario-generator/output/oms015-order-ltl-lcl-universal/oms015-order-ltl-lcl-universal.scenarios.json`
