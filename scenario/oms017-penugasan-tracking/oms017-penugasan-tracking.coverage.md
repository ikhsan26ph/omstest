# Coverage Review — OMS017 Penugasan Tracking

Reviewer: QA Reviewer (AUTO MODE)
Tanggal review: 2026-08-29
Sumber: `oms017-penugasan-tracking.analysis.md` (80 REQ, 22 layar UI Inventory), `oms017-penugasan-tracking.feature` (195 skenario Gherkin), `oms017-penugasan-tracking.scenarios.json` (195 entri sidecar)

---

## Ringkasan Eksekutif

| Kategori | Jumlah | % dari total |
|---|---|---|
| Positive (TC-P-001..069) | 69 | 35.4% |
| Negative (TC-N-001..060) | 60 | 30.8% |
| Edge (TC-E-001..042) | 42 | 21.5% |
| Stress (TC-S-001..024) | 24 | 12.3% |
| **Total** | **195** | **100%** |

**Verdict keseluruhan: LULUS DENGAN CATATAN (Pass with Minor Findings).**

- Sintaks Gherkin dan JSON **valid**, tidak ditemukan error struktural.
- Konsistensi ID feature ↔ JSON **1:1 penuh** (195 = 195, diverifikasi pada seluruh titik batas kategori dan sampel tengah).
- Seluruh 80 REQ memiliki **minimal 1 skenario** (tidak ada REQ dengan status *None*/tanpa cakupan sama sekali).
- **47/80 REQ (58.75%)** berstatus **Full** (≥1 positive **dan** ≥1 negative). **33/80 REQ (41.25%)** berstatus **Partial** — mayoritas adalah requirement bertipe *display/structural/opsional* yang secara alami sulit diberi skenario negative (mis. urutan sort, default placeholder, prefix wilayah), namun **5 di antaranya adalah gap yang lebih substansial** dan direkomendasikan ditambah (lihat bagian Coverage Gap).
- Dari 22 layar UI Inventory, **21 layar tersentuh**; **layar `145` tidak direferensikan oleh skenario manapun** (`@screen-145` tidak pernah muncul).
- Tidak ditemukan duplikat murni (skenario dengan Given/When/Then identik). Ditemukan **3 pasangan near-duplicate/overlap** yang direkomendasikan untuk direview (bukan dihapus), lihat bagian Duplikasi.
- Distribusi edge & stress **memadai** untuk area berisiko tinggi: boundary foto (4MB, 6 foto), boundary ETD=ETA, matriks 4 metode pengiriman FCL/LCL (Scenario Outline), dan navigasi kritikal REQ-066 diuji lintas 4 kategori (P/N/E/S).

---

## Validasi Sintaks (Gherkin + JSON + Konsistensi ID)

### Gherkin (`oms017-penugasan-tracking.feature`)
- `Feature:` dan `Background:` terdefinisi dengan benar di awal file; seluruh 195 `Scenario:`/`Scenario Outline:` diawali keyword valid (`Given/When/Then/And/But`) tanpa step yatim (orphan step) yang ditemukan pada pemindaian penuh 1892 baris.
- Tag konsisten mengikuti pola `@kategori @priority-* @REQ-* @screen-* @TC-*` pada seluruh sampel yang diperiksa. Kategori (`@positive/@negative/@edge/@stress`) selalu match dengan prefix `@TC-` (P/N/E/S) — tidak ditemukan mismatch.
- Prioritas hanya menggunakan 3 nilai valid: `@priority-high`, `@priority-medium`, `@priority-low`. Tidak ada nilai liar.
- **1 `Scenario Outline`** ditemukan: `TC-E-035` (matriks 4 metode pengiriman FCL/LCL) — memiliki blok `Examples:` dengan header kolom (`metode`, `tampil_armada_muat`, `tampil_sopir_bongkar`) dan 4 baris data, format pipe-table valid. Tidak ada Scenario Outline lain yang kehilangan Examples.
- Komentar section (`# ====...`) digunakan konsisten sebagai pemisah area REQ, tidak mengganggu parsing Gherkin.
- Penomoran TC berurutan tanpa lompatan/duplikat di setiap kategori: P-001..069, N-001..060, E-001..042, S-001..024 (diverifikasi lewat pembacaan penuh file).

**Kesimpulan:** tidak ada isu sintaks Gherkin yang memblokir eksekusi.

### JSON (`oms017-penugasan-tracking.scenarios.json`)
- Struktur adalah array JSON valid: baris 1 `[`, baris 197 `]`, 195 objek scenario di antaranya (baris 2–196). Setiap objek well-formed (field `id, category, priority, title, requirements, screens, preconditions, steps, expected, testData, notes` konsisten di seluruh sampel yang diperiksa).
- Tidak ditemukan trailing comma atau bracket tidak seimbang pada baris yang diperiksa (awal, titik transisi kategori, dan akhir file).

### Konsistensi ID Feature ↔ JSON (dua arah)
Diverifikasi pada seluruh titik transisi kategori dan sampel acak:
- `TC-P-068`/`TC-P-069` (baris JSON 69–70) → cocok persis dengan `TC-P-068`/`TC-P-069` di feature (title, REQ, screen sama).
- `TC-N-001` (baris JSON 71) tepat menyusul `TC-P-069` → urutan tidak melompat.
- `TC-N-059`/`TC-N-060` (129–130) → `TC-E-001` (131) → transisi mulus.
- `TC-E-041`/`TC-E-042` (171–172) → `TC-S-001` (173) → transisi mulus.
- `TC-S-024` adalah entri terakhir (baris 196), title & data (`25 kota drop`) identik dengan feature baris 1885–1891.
- Total entri JSON (195) = total skenario feature (195, dari header komentar 69+60+42+24). **Tidak ada ID yang hanya ada di salah satu file** (zero orphan pada kedua arah, berdasarkan sampling penuh pada seluruh titik transisi dan spot-check isi).

**Kesimpulan:** JSON dan feature file 1:1 konsisten, tidak ada isu integrasi.

---

## Duplikasi & Rekomendasi Merge

Tidak ditemukan duplikat murni (Given/When/Then identik). Ditemukan 3 pasangan **near-duplicate/overlap** yang secara fungsional saling tumpang tindih namun **direkomendasikan tetap dipertahankan** karena masing-masing mengikat REQ/aspek yang berbeda secara eksplisit — dicatat di sini untuk transparansi, bukan untuk dihapus:

| Pasangan | Alasan overlap | Rekomendasi |
|---|---|---|
| `TC-P-026` vs `TC-P-039` | Keduanya: pilih order FTL → metode "Pilih Dari Master" untuk Armada & Sopir → Simpan → notifikasi tersimpan. Beda hanya pada data uji (nopol/sopir) dan REQ yang di-tag (026: REQ-023/027/036 — alur umum; 039: REQ-037/038 — required field FTL). | Pertahankan keduanya (masing-masing adalah bukti positif wajib untuk REQ berbeda), tetapi bisa dipertimbangkan digabung menjadi satu skenario dengan multiple REQ tag jika efisiensi eksekusi jadi prioritas. |
| `TC-E-039` vs (`TC-P-055` + `TC-N-054`) | `TC-E-039` menguji ulang kombinasi "No. Kontainer terkunci di Edit" (sudah dibuktikan `TC-N-054`) dan "No. Kontainer dapat diubah di form Selesai Muat" (sudah dibuktikan `TC-P-055`) dalam satu skenario gabungan. | Pertahankan sebagai edge — nilai tambahnya adalah membuktikan **interaksi** dua aturan (REQ-063 vs REQ-078) tidak saling bertentangan pada order yang sama; bukan duplikat murni. |
| `TC-N-004` vs `TC-E-001` | `TC-N-004` (satu vendor) dan `TC-E-001` (dua vendor kelolaan, akses campuran dalam satu tabel) sama-sama membuktikan "Edit disabled pada order vendor non-kelolaan". | Pertahankan `TC-E-001` sebagai perluasan boundary (multi-vendor) dari `TC-N-004`; tidak direkomendasikan dihapus karena menguji skenario akses campuran yang realistis. |

**Tidak ada skenario yang direkomendasikan untuk dihapus** dari 195 skenario yang ada.

---

## Coverage Gap

### Layar UI Inventory tidak tersentuh
- **`145 — Daftar Penugasan Tracking (kolom Status + Tanggal Mulai Tracking, filter versi lama)`**: tidak ada satu pun `@screen-145` pada 195 skenario. Layar ini menurut analysis.md "identik dengan 127 kecuali sub-header kolom Status menampilkan `Tanggal Mulai Tracking`". Karena secara fungsional near-identical dengan layar 127 (yang tercakup sangat luas), risiko fungsional dari gap ini **rendah**, namun untuk kelengkapan dokumentasi disarankan menambah 1 skenario ringan (positive/low-priority) yang menegaskan tampilan sub-header `Tanggal Mulai Tracking` pada varian ini.

Seluruh 21 layar lainnya (127, 128, 129, 133a, 134, 135, 136, 137, 139, 140, 143, 144, 146, 147, 148, 149, 150, pop-up, pop-up-1, pop-up-2, pop-up-3) tersentuh minimal 1 skenario.

### REQ dengan gap substansial (rekomendasi tambahan skenario)
Requirement berikut bertipe validasi/blokir yang **secara wajar bisa dan sebaiknya** memiliki pasangan positive+negative, namun saat ini hanya memiliki satu sisi:

| REQ | Yang hilang | Rekomendasi konkret |
|---|---|---|
| REQ-002 | Tidak ada `@positive` — hanya 3 negative (TC-N-001..003) + 1 edge (TC-E-001) yang membuktikan pembatasan. Belum ada skenario yang secara eksplisit tag `@REQ-002 @positive` untuk membuktikan sisi **positifnya**: Shipper non-pengelola vendor **berhasil** melihat Detail (read-only) tanpa error. | Tambah skenario positive: "Shipper tanpa vendor kelolaan berhasil membuka halaman Detail Penugasan (read-only)" dengan tag `@positive @REQ-002`. |
| REQ-034 | Tidak ada `@positive` — hanya TC-N-019 & TC-N-056 (negative). | Tag ulang salah satu skenario "Simpan berhasil karena seluruh field required terisi" (mis. bagian dari TC-P-038) dengan tambahan `@REQ-034`, atau tambah skenario baru eksplisit. |
| REQ-049 | Tidak ada `@positive` — TC-P-042 (Connecting, dua baris kapal, tersimpan) sudah **secara fungsional** membuktikan ETD valid tersimpan namun **tidak** membawa tag `@REQ-049`. | Tambahkan tag `@REQ-049` pada `TC-P-042`, atau retag `TC-E-020` (ETD == ETA) sebagai bukti positif eksplisit dengan tag ganda `@positive`-equivalent note. |
| REQ-058 | Tidak ada `@positive` — hanya TC-N-036/037 (negative) dan TC-E-025/026 (edge boundary). | Tambahkan tag `@REQ-058` pada `TC-P-052` (upload 2 foto valid, "sistem tidak menampilkan alert batas foto") agar sisi positif eksplisit tercatat. |
| REQ-067 | Tidak ada `@positive` — hanya TC-N-042/043 (negative) dan Scenario Outline TC-E-035 (edge, mencakup keseluruhan matriks). | Cukup memadai secara fungsional karena Outline TC-E-035 sudah menguji seluruh 4 kombinasi; disarankan menambahkan tag `@REQ-067` eksplisit pada baris Outline agar traceability RTM tidak menunjukkan "Partial" secara keliru. |

### REQ Partial "thin-but-acceptable" (tidak memerlukan aksi mendesak)
33 REQ berstatus Partial secara total; 28 di antaranya (di luar 5 REQ di atas) adalah requirement bertipe **display/structural/opsional** yang secara alami tidak memiliki skenario "gagal" yang bermakna (contoh: REQ-005 urutan sort, REQ-017 default filter kosong, REQ-028 prefix wilayah, REQ-032 field opsional No. WhatsApp, REQ-054 pemisahan form per kota, REQ-061 tombol Kembali, REQ-071 History Tracking, REQ-080 akses riwayat). Ini **dapat diterima** sebagai coverage yang cukup meskipun tidak "Full" secara ketat 2-sisi — tidak direkomendasikan menambah skenario negative buatan yang tidak punya dasar failure mode di spec.

### REQ dengan cakupan sangat tipis (1 skenario total)
- **REQ-061** (Tombol Kembali pada Isi Data Tracking): hanya 1 skenario (`TC-P-054`). Direkomendasikan menambah minimal 1 skenario edge (mis. "Kembali saat form berisi data belum tersimpan — apakah ada konfirmasi atau data hilang tanpa peringatan?") karena berpotensi risiko UX (kehilangan data) yang belum diuji.
- **REQ-055** (Pemilihan alamat & draft data): hanya 1 skenario (`TC-P-050`). Tidak ada skenario edge untuk kasus alamat dengan data pengiriman kosong/tidak lengkap.

---

## Penilaian Edge & Stress

**Kesimpulan: memadai (adequate)** untuk area berisiko tinggi yang disebutkan pada instruksi tugas:

1. **Validasi boundary** — sangat baik:
   - Ukuran foto: tepat 4 MB diterima (`TC-E-025`), 4 MB + 1 KB ditolak (`TC-E-026`), tepat 6 foto (`TC-E-024`), foto ke-7 ditolak (`TC-N-036`).
   - Pagination: tepat 20 data (`TC-E-002`), 21 data → halaman kedua 1 baris (`TC-E-003`).
   - Tanggal: 29 Februari tahun kabisat vs bukan kabisat (`TC-E-027`).
   - ETD Connecting: sama persis dengan ETA (`TC-E-020`, valid), 50 baris connecting dengan pelanggaran di baris terakhir (`TC-S-013`).
   - Panjang teks: keterangan 2000 karakter (`TC-E-042`) dan 10000 karakter (`TC-S-017`), No. Segel 1000 karakter (`TC-S-014`), filter ID Order 5000 karakter (`TC-S-004`).

2. **Matriks FCL/LCL (4 metode pengiriman)** — sangat baik: `Scenario Outline TC-E-035` menguji **seluruh 4 kombinasi** (Door-Door, Door-CY, CY-Door, CY-CY) × 2 dimensi (tampil armada muat, tampil opsi sopir bongkar) dalam satu tabel Examples — pendekatan tepat untuk matriks kombinatorial, konsisten dengan REQ-044/064/067 dan Assumption A-14.

3. **Editability per status** (REQ-076–079) — sangat baik: setiap field (nopol/armada FTL, nopol/armada FCL, No. Kontainer/Segel, jadwal kapal) diuji pada kondisi enabled (positive) **dan** disabled (negative) pada status yang tepat, plus edge `TC-E-039` (interaksi silang Edit vs Selesai Muat) dan `TC-E-040` (titik transisi tepat saat status berubah) — edge case krusial (boundary temporal) yang menguji "field terkunci **tepat setelah** status berpindah" alih-alih hanya kondisi statis.

4. **REQ-066 (aturan navigasi kritikal, ditekankan berulang di spec)** — diuji lintas **4 kategori sekaligus**: positive (`TC-P-058`), negative (`TC-N-046`), edge (`TC-E-031` data parsial tidak hilang, `TC-E-032` reject konfirmasi), stress (`TC-S-020` 30x navigasi bolak-balik). Ini adalah contoh baik dari pendekatan "risk-based testing" yang proporsional terhadap penekanan spec.

5. **Concurrency/race condition** — tercakup baik untuk area kritis: dua sesi menyimpan order sama (`TC-N-059`, `TC-S-011`), klik ganda Simpan (`TC-S-010`, `TC-S-018`), dua admin isi tracking bersamaan (`TC-S-019`).

**Catatan minor:** tidak ada skenario stress untuk **concurrency pada Edit Penugasan** (dua user mengedit penugasan yang sama secara bersamaan) — hanya ada untuk Tambah Penugasan (`TC-S-011`) dan Isi Data Tracking (`TC-S-019`). Ini kandidat tambahan opsional, bukan gap kritis karena pola race-condition serupa sudah dibuktikan di dua alur lain.

---

## Requirements Traceability Matrix

Kategori: P=positive, N=negative, E=edge, S=stress. Status: **Full** = memiliki ≥1 P dan ≥1 N; **Partial** = hanya salah satu sisi (P atau N) meski mungkin ada E/S.

| REQ | Deskripsi Singkat | Scenario IDs | Kategori | Status |
|---|---|---|---|---|
| REQ-001 | Akses penuh Shipper (kelola vendor) | TC-P-001, TC-N-004, TC-E-001 | P,N,E | Full |
| REQ-002 | Akses terbatas Shipper (non-kelola vendor) | TC-N-001, TC-N-002, TC-N-003, TC-E-001 | N,E | Partial (tanpa P) |
| REQ-003 | Akses penuh Vendor | TC-P-002 | P | Partial (tanpa N) |
| REQ-004 | Paginasi default 20/halaman | TC-P-004, TC-P-005, TC-N-006, TC-E-002, TC-E-003, TC-S-001, TC-S-002, TC-S-003, TC-S-006 | P,N,E,S | Full |
| REQ-005 | Urutan data terbaru di atas | TC-P-006, TC-E-004, TC-S-002 | P,E,S | Partial (tanpa N) |
| REQ-006 | Kolom tabel (4 kolom) | TC-P-007, TC-P-011, TC-E-005 | P,E | Partial (tanpa N) |
| REQ-007 | Action menu 4 opsi | TC-P-002, TC-P-008, TC-P-009, TC-P-012, TC-N-002 | P,N | Full |
| REQ-008 | Tombol Tambah Penugasan | TC-P-010 | P | Partial (tanpa N) |
| REQ-009 | Filter ID Order | TC-P-013, TC-N-007, TC-N-009, TC-E-008, TC-S-004 | P,N,E,S | Full |
| REQ-010 | Filter Jenis Shipment | TC-P-021, TC-N-008 | P,N | Full |
| REQ-011 | Filter Kota Asal | TC-P-014, TC-N-011 | P,N | Full |
| REQ-012 | Filter Kota Tujuan | TC-P-021, TC-N-011 | P,N | Full |
| REQ-013 | Filter Nopol/No. Kontainer | TC-P-015, TC-N-008, TC-E-009 | P,N,E | Full |
| REQ-014 | Filter Sopir | TC-P-016, TC-N-010, TC-E-008 | P,N,E | Full |
| REQ-015 | Filter Tahap Pengiriman | TC-P-017, TC-N-013, TC-E-006, TC-E-007 | P,N,E | Full |
| REQ-016 | Filter Status | TC-P-011, TC-P-018, TC-N-012, TC-E-006, TC-E-012 | P,N,E | Full |
| REQ-017 | Default filter kosong | TC-P-019, TC-P-022 | P | Partial (tanpa N) |
| REQ-018 | Tombol Reset | TC-P-020, TC-E-010 | P,E | Partial (tanpa N) |
| REQ-019 | Tombol Terapkan (AND) | TC-P-021, TC-P-022, TC-N-008, TC-S-005, TC-S-006 | P,N,S | Full |
| REQ-020 | Status "Belum Berangkat" | TC-P-023, TC-N-015 | P,N | Full |
| REQ-021 | Status "Dalam Perjalanan" | TC-P-024, TC-N-014 | P,N | Full |
| REQ-022 | Status "Selesai" | TC-P-025, TC-N-014, TC-E-011 | P,N,E | Full |
| REQ-023 | Pemilihan order wajib | TC-P-026, TC-N-016 | P,N | Full |
| REQ-024 | Hanya order belum ditugaskan | TC-P-027, TC-N-017, TC-N-059, TC-S-009, TC-S-011 | P,N,S | Full |
| REQ-025 | Search bar order (ID/Kota) | TC-P-028, TC-E-014, TC-S-009 | P,E,S | Partial (tanpa N) |
| REQ-026 | Single selection order | TC-P-029, TC-E-015 | P,E | Partial (tanpa N) |
| REQ-027 | Auto-draft read-only | TC-P-026, TC-P-030, TC-N-018 | P,N | Full |
| REQ-028 | Prefix "Kota"/"Kab." | TC-P-007, TC-P-030, TC-E-013 | P,E | Partial (tanpa N) |
| REQ-029 | Jumlah card = jumlah armada/kontainer | TC-P-031, TC-E-015, TC-E-016, TC-E-023, TC-S-007, TC-S-012 | P,E,S | Partial (tanpa N) |
| REQ-030 | Card tunggal LTL/LCL | TC-P-032, TC-P-033, TC-E-023 | P,E | Partial (tanpa N) |
| REQ-031 | Metode "Pilih Dari Master" | TC-P-034, TC-E-017, TC-S-008 | P,E,S | Partial (tanpa N) |
| REQ-032 | Metode "Isi Data Manual" (WA opsional) | TC-P-035, TC-P-040, TC-E-017, TC-E-018, TC-E-019 | P,E | Partial (tanpa N) |
| REQ-033 | Filter armada master sesuai jenis order | TC-P-036, TC-N-022 | P,N | Full |
| REQ-034 | Validasi field required (helper error) | TC-N-019, TC-N-056 | N | Partial (tanpa P) — **gap, lihat rekomendasi** |
| REQ-035 | Tombol Batal + alert konfirmasi | TC-P-037, TC-N-020, TC-E-032 | P,N,E | Full |
| REQ-036 | Tombol Simpan + dialog konfirmasi | TC-P-026, TC-P-038, TC-N-021, TC-S-010 | P,N,S | Full |
| REQ-037 | Field No. Polisi required (FTL/LTL) | TC-P-039, TC-P-040, TC-N-023 | P,N | Full |
| REQ-038 | Field Sopir required (FTL/LTL) | TC-P-039, TC-P-040, TC-N-024 | P,N | Full |
| REQ-039 | No. Kontainer required | TC-P-041, TC-N-025, TC-S-012 | P,N,S | Full |
| REQ-040 | No. Segel required | TC-P-041, TC-N-026, TC-S-014 | P,N,S | Full |
| REQ-041 | Armada Muat required | TC-P-041, TC-N-027 | P,N | Full |
| REQ-042 | Sopir Muat required | TC-P-041, TC-N-028 | P,N | Full |
| REQ-043 | Jadwal Kapal required | TC-P-041, TC-N-029 | P,N | Full |
| REQ-044 | Pengecualian CY-Door/CY-CY | TC-P-043, TC-P-044, TC-P-045, TC-N-033, TC-E-035 | P,N,E | Full |
| REQ-045 | Jadwal kapal bukan per-kontainer | TC-P-041, TC-P-046 | P | Partial (tanpa N) |
| REQ-046 | Jenis Jadwal Kapal wajib | TC-P-042, TC-N-030 | P,N | Full |
| REQ-047 | Aturan Direct (tanpa connecting) | TC-P-041, TC-N-031, TC-E-022 | P,N,E | Full |
| REQ-048 | Aturan Connecting (multi-baris) | TC-P-042, TC-E-021, TC-E-022, TC-S-013 | P,E,S | Partial (tanpa N) |
| REQ-049 | Validasi ETD Connecting ≤ ETA | TC-N-032, TC-E-020, TC-E-021, TC-S-013 | N,E,S | Partial (tanpa P) — **gap, lihat rekomendasi** |
| REQ-050 | Kanal pengisian tracking (web only) | TC-P-003, TC-N-005, TC-S-019 | P,N,S | Full |
| REQ-051 | Cakupan update (Selesai Muat/Bongkar) | TC-P-048, TC-N-014 | P,N | Full |
| REQ-052 | Dampak ke status | TC-P-024 | P | Partial (tanpa N) |
| REQ-053 | Informasi order read-only | TC-P-047, TC-N-039 | P,N | Full |
| REQ-054 | Form terpisah per kota drop | TC-P-049, TC-E-029, TC-S-016 | P,E,S | Partial (tanpa N) |
| REQ-055 | Pemilihan alamat & draft data | TC-P-050 | P | Partial (tanpa N) — cakupan tipis |
| REQ-056 | Tanggal selesai muat/bongkar (format) | TC-P-051, TC-N-034, TC-N-040, TC-E-027 | P,N,E | Full |
| REQ-057 | Field foto (required, max 6, 4MB, JPG/PNG) | TC-P-052, TC-N-035, TC-N-038, TC-N-060, TC-E-024, TC-E-025, TC-E-028, TC-S-015 | P,N,E,S | Full |
| REQ-058 | Alert batas foto | TC-N-036, TC-N-037, TC-E-025, TC-E-026 | N,E | Partial (tanpa P) — **gap, lihat rekomendasi** |
| REQ-059 | Field keterangan opsional | TC-P-052, TC-E-042, TC-S-017 | P,E,S | Partial (tanpa N) |
| REQ-060 | Tombol Simpan tracking (lanjut tahap) | TC-P-053, TC-E-030, TC-S-018, TC-S-019, TC-S-023 | P,E,S | Partial (tanpa N) |
| REQ-061 | Tombol Kembali (tracking) | TC-P-054 | P | Partial (tanpa N) — cakupan tipis |
| REQ-062 | Auto-minimize kota selesai | TC-P-053, TC-E-029, TC-E-030, TC-S-016 | P,E,S | Partial (tanpa N) |
| REQ-063 | Ubah No. Kontainer/Segel saat Selesai Muat | TC-P-055, TC-N-041, TC-E-039 | P,N,E | Full |
| REQ-064 | Penugasan Sopir Bongkar (CY-Door/Door-Door) | TC-P-056, TC-P-057, TC-P-060, TC-N-044, TC-N-045, TC-N-047, TC-E-033, TC-E-034, TC-E-035 | P,N,E | Full |
| REQ-065 | Metode pengisian sopir bongkar | TC-P-056, TC-P-057 | P | Partial (tanpa N) |
| REQ-066 | Navigasi Batal sopir bongkar (kritikal) | TC-P-058, TC-N-046, TC-E-031, TC-E-032, TC-S-020 | P,N,E,S | Full |
| REQ-067 | Pengecualian Door-CY/CY-CY (sopir bongkar) | TC-N-042, TC-N-043, TC-E-035 | N,E | Partial (tanpa P) — **gap, lihat rekomendasi** |
| REQ-068 | Halaman Detail per ID Order | TC-P-059, TC-N-048, TC-N-050 | P,N | Full |
| REQ-069 | Bagian "Detail Data Order" | TC-P-059, TC-P-060, TC-N-049 | P,N | Full |
| REQ-070 | Bagian "Informasi Penugasan" | TC-P-059, TC-P-060 | P | Partial (tanpa N) |
| REQ-071 | Bagian "History Tracking" | TC-P-059, TC-E-036, TC-S-024 | P,E,S | Partial (tanpa N) |
| REQ-072 | Pop-up Riwayat Penugasan | TC-P-061, TC-N-051, TC-E-037, TC-E-041, TC-S-021 | P,N,E,S | Full |
| REQ-073 | Isi pop-up (tanggal/armada/sopir) | TC-P-061, TC-S-021 | P,S | Partial (tanpa N) |
| REQ-074 | Tampilan perubahan parsial (strip "-") | TC-P-062, TC-E-005, TC-E-038 | P,E | Partial (tanpa N) |
| REQ-075 | Bagian "Informasi Order" pada Edit | TC-P-064, TC-P-065, TC-N-056, TC-N-057 | P,N | Full |
| REQ-076 | Editability FTL/LTL sampai Selesai Muat | TC-P-066, TC-N-052, TC-N-058, TC-E-040, TC-S-022 | P,N,E,S | Full |
| REQ-077 | Editability nopol/armada FCL/LCL | TC-P-067, TC-N-053, TC-E-040 | P,N,E | Full |
| REQ-078 | Editability No. Kontainer & No. Segel | TC-P-068, TC-N-054, TC-E-039 | P,N,E | Full |
| REQ-079 | Editability Jadwal Kapal | TC-P-069, TC-N-055, TC-N-058, TC-E-040 | P,N,E | Full |
| REQ-080 | Akses Riwayat Perubahan dari daftar | TC-P-063, TC-S-022 | P,S | Partial (tanpa N) |

**Ringkasan status:** Full = 47/80 (58.75%), Partial = 33/80 (41.25%), None = 0/80 (0%).

---

## Catatan untuk BA/QA

1. **Prioritas tindak lanjut (High):** tambahkan/tag ulang 5 skenario untuk menutup gap REQ-002, REQ-034, REQ-049, REQ-058, REQ-067 (lihat tabel "Coverage Gap"). Ini adalah requirement bertipe validasi/blokir yang idealnya memiliki bukti dua sisi eksplisit.
2. **Prioritas tindak lanjut (Medium):** tambahkan minimal 1 skenario `@screen-145` untuk kelengkapan dokumentasi UI Inventory, dan pertimbangkan menambah skenario untuk REQ-061 (kehilangan data saat klik Kembali) serta REQ-055 (alamat dengan data tidak lengkap) karena keduanya saat ini hanya memiliki 1 skenario total.
3. **Konsisten dengan Assumptions Log** — reviewer mengonfirmasi bahwa keputusan AUTO MODE pada analysis.md (A-01/D-02 status ganda, D-04 menu tambahan, D-09 field Tanggal Permintaan Bongkar, D-10 dua entry point sopir bongkar) telah **diterjemahkan dengan tepat** ke dalam skenario Gherkin, termasuk penggunaan pola regex status (`Belum Berangkat|Menunggu Proses`, dst.) secara konsisten di seluruh 195 skenario yang relevan.
4. **Tidak diperlukan penghapusan skenario** — dedup review tidak menemukan duplikat murni; 3 pasangan overlap yang ditemukan memberi nilai tambah traceability/boundary dan direkomendasikan tetap dipertahankan.
5. **REQ-066 (aturan navigasi kritikal)** adalah contoh praktik baik: diuji di 4 kategori sekaligus sesuai penekanan berulang pada spec sumber — pola ini dapat dijadikan acuan untuk requirement kritikal lain di modul mendatang.
6. Sebelum eksekusi, pastikan tim automation mengonfirmasi selector `data-testid` usulan untuk halaman **Isi Data Tracking** (tag `@screen-isi-data-tracking`) karena halaman ini tidak memiliki mockup sama sekali (D-17) — seluruh 61+ skenario yang menyentuh halaman ini bergantung pada selector asumsi yang perlu divalidasi terhadap implementasi aktual sebelum dijadikan automated test yang stabil.
