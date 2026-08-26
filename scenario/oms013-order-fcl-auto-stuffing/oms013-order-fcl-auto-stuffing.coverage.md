# QA Coverage Review — oms013-order-fcl-auto-stuffing

> Reviewer: QA Reviewer (verifikatif/mekanis)
> Sumber: `oms013-order-fcl-auto-stuffing.feature`, `oms013-order-fcl-auto-stuffing.scenarios.json`, `oms013-order-fcl-auto-stuffing.analysis.md`
> Tanggal review: 2026-08-24

---

## 1. Ringkasan Angka

| Kategori | Jumlah |
|---|---|
| Positive | 35 (termasuk 2 Scenario Outline: POS-019 [4 examples], POS-034 [6 examples]) |
| Negative | 15 (termasuk 1 Scenario Outline: NEG-015 [2 examples]) |
| Edge | 16 |
| Stress | 9 |
| **Total scenario definitions** | **75** |
| Total baris eksekusi efektif (outline diperluas) | 75 − 3 + 4 + 6 + 2 = **84** |

Jumlah ini konsisten antara header komentar `.feature`, blok `# POSITIVE/NEGATIVE/EDGE/STRESS`, dan field `counts` pada `.scenarios.json` (35/15/16/9/75). Dihitung ulang manual dengan menghitung tiap `Scenario:`/`Scenario Outline:` pada `.feature` — cocok, tidak ada selisih.

**Cakupan Requirement**: seluruh **50/50 REQ (REQ-001–REQ-050)** memiliki minimal satu scenario terkait (via tag `@REQ-*` pada `.feature` dan/atau field `requirements[]` pada `.scenarios.json`). Rincian status per REQ ada di RTM (§6) — 40 REQ berstatus **Covered** penuh, 10 REQ berstatus **Partial** (gap dijelaskan di §3 dan §5/§7).

**Konsistensi `.feature` ↔ `.scenarios.json`**: 75 ID pada `.feature` (OMS013-POS-001..035, NEG-001..015, EDG-001..016, STR-001..009) sama persis dengan 75 objek `scenarios[]` pada JSON (diverifikasi ID, judul, kategori, dan urutan — 1:1 cocok). Tidak ditemukan ID yang hilang atau berlebih di salah satu file.

---

## 2. Hasil Dedup

Tidak ditemukan scenario yang benar-benar **duplikat** (identik precondition + aksi + expected). Ditemukan beberapa **pasangan/kelompok yang beririsan secara konsep** namun sengaja dipertahankan karena menguji aspek/skala berbeda (progressive coverage, bukan pengulangan) — semua **KEEP**, tidak ada yang dihapus:

| Pasangan/Kelompok | Kemiripan | Keputusan & Alasan |
|---|---|---|
| POS-017 vs EDG-010 vs STR-009 (visualisasi muatan) | Sama-sama membuka pop up visualisasi | **Keep semua** — POS-017 menguji keberadaan & konten dasar pop up; EDG-010 menguji indikator overload (outline merah); STR-009 menguji ketahanan interaksi canvas pada volume >1.300 koli. Aspek berbeda (fungsional vs kondisi batas vs beban). |
| POS-033 vs EDG-012 (Hitung Ulang Kontainer) | Sama-sama panel "Hitung Ulang Kontainer" (062) | **Keep semua** — POS-033 mengubah *jumlah* kontainer via stepper lalu Terapkan; EDG-012 mengubah *jenis* kontainer dan memverifikasi kapasitas maksimal ter-update. Trigger & assertion berbeda. |
| POS-024 vs EDG-007 vs STR-003 (jumlah baris No. Perjalanan) | Sama-sama memverifikasi jumlah baris = jumlah kontainer | **Keep semua** — nilai kontainer berbeda (2 / 3 / 10) merepresentasikan baseline, edge-count, dan stress-scale; ini pola scaling yang wajar, bukan duplikasi. |
| EDG-001/002/003 vs STR-007 (alert kapasitas) | Sama-sama menguji alert non-blocking | **Keep semua** — EDG-001..003 menguji 3 varian teks pesan tepat pada kondisi melebihi kapasitas; STR-007 menguji kondisi ekstrem (500% kapasitas) sekaligus interaksi visualisasi & submit end-to-end. Kedalaman berbeda. |
| POS-010 vs NEG-009 (checkbox Tambahkan Asuransi) | Field & area sama | **Keep keduanya** — POS-010 menguji arah "centang → kolom muncul & wajib"; NEG-009 menguji arah kebalikannya "uncentang → kolom hilang & validasi lepas". Pasangan positive/negative yang saling melengkapi, bukan duplikat. |
| EDG-013 vs STR-004 (tambah/hapus baris pick up/drop off) | Sama-sama menambah blok titik Multipoint | **Keep semua** — EDG-013 menguji fungsi tambah+hapus 1 baris (2→3→2) pada baseline 2×2; STR-004 menguji skala besar 5×5 tanpa fungsi hapus. Fungsional vs stress berbeda tujuan. |

**Kesimpulan dedup**: 0 scenario dibuang. Distribusi 75 scenario efisien — tidak ada pemborosan berarti.

---

## 3. Cek Coverage — Layar & Varian UI Inventory

| Layar/Varian | Status | Scenario ID pendukung |
|---|---|---|
| Daftar Order (list, filter, aksi kontekstual, pagination) | Covered | POS-020, POS-027, POS-028, POS-034, POS-035, NEG-007/008/010/015, STR-005 |
| Pop up "Data No. Perjalanan" (070) | Covered | POS-024, POS-025, EDG-007, STR-003 |
| Step 1 — Normal (059/060) | Covered | POS-002, POS-003, POS-004, NEG-001, NEG-012 |
| Step 1 — Multipickup (072) | Covered | POS-029, EDG-013 (fungsi tambah/hapus baris) |
| Step 1 — Multidrop (080) | Covered | POS-030 |
| Step 1 — Multipoint (088) | Covered | POS-031, EDG-013, STR-004 |
| Step 2 — Normal (061) | Covered (sangat kuat) | POS-005..012, NEG-002/003/009/011/013, EDG-001..006, EDG-015, STR-001/002 |
| Step 2 — Multipickup/Multidrop (073/081) | Covered | POS-029, POS-030 |
| Step 2 — Multipoint (089) | Covered | POS-031, EDG-008, STR-004 |
| Panel Visualisasi Muatan — mode "Hitung Ulang Kontainer" (062) | Covered | POS-033, EDG-012 |
| Panel Visualisasi Muatan — mode "Visualisasi Muatan Saat Ini" (063) | Covered | POS-017, EDG-010, STR-009 |
| Step 3 — Normal (064) | Covered | POS-013, POS-014, POS-015, NEG-004, EDG-009, STR-006 |
| Step 3 — modal Detail Multipickup/Multidrop (075/083/091/092) | Covered | POS-032 |
| Step 3 — Multipoint dua link (090) | Covered | POS-032 (order Multipoint, kedua link diuji dalam 1 scenario) |
| Step 4 — Review Normal (065) | Covered | POS-016, POS-017, POS-018, STR-008 |
| Step 4 — Review Multipickup/Multidrop/Multipoint (076/084/093) | **Not covered** | — tidak ada scenario yang membuka Step 4 Review untuk order tipe multi; POS-029/030/031 berhenti di Step 2. **Gap** (lihat §5). |
| Detail Order — Menunggu Penugasan & Ditugaskan, Normal (066/067) | Covered | POS-026, EDG-011 |
| Detail Order — Multipickup/Multidrop/Multipoint (077/085/094) | **Partial** | Tidak ada scenario eksplisit membuka Detail Order untuk order tipe multi (struktur section per Pick Up/Drop Off tidak diverifikasi di halaman ini). **Gap** (lihat §5). |
| Edit Order — Normal (068) | Covered | POS-021, NEG-006 |
| Edit Order — Multipickup/Multidrop/Multipoint (078/086/095) | **Partial** | Tidak ada scenario Edit Order untuk order tipe multi. **Gap** (lihat §5). |
| Modal "Pilih Barang" (hipotetis, asumsi #14) | Covered | POS-005, POS-007, POS-008, NEG-013, EDG-015 |
| Dialog Pembatalan + "Alasan Pembatalan" (hipotetis) | Covered | POS-022, POS-023, NEG-005 |
| Batch Order (hanya tombol terlihat di desain) | **Not covered** | Sesuai Assumptions Log #7 — di luar cakupan pengujian rinci modul ini (disengaja, bukan oversight) |
| Public tracking (di luar UI OMS) | **Not covered (out of scope)** | UI Inventory item #5 — di luar cakupan pengujian OMS; hanya sisi OMS (generate/copy No. Perjalanan) yang diuji (POS-024, POS-025) |

### REQ dengan cakupan parsial atau bercatatan khusus

- **REQ-008** (Metode Pengiriman tidak ada di OMS) — **spec-conflict**. Diuji mengikuti **desain** (field justru tampil dan diisi) via POS-002 (`@spec-conflict`), bukan mengikuti teks REQ-008. Ini konsisten dengan Assumptions Log #10, namun berarti REQ-008 **tidak diuji sesuai bunyi literalnya** — perlu keputusan produk (lihat §7).
- **REQ-044** (No. Perjalanan untuk public tracking oleh pengirim/penerima) — **Partial**. Hanya sisi OMS yang diuji (generate & copy nomor via POS-025); konsumsi nomor tersebut pada aplikasi public tracking di luar cakupan OMS dan tidak diuji (sesuai UI Inventory item #5).
- **REQ-046** (No. Perjalanan hanya tampil untuk FTL & FCL) — **Partial**. POS-024 hanya menguji sisi positif (FCL menampilkannya); tidak ada scenario lintas jenis pengiriman yang memverifikasi bahwa LTL/LCL **tidak** menampilkan No. Perjalanan, karena modul ini fokus FCL saja. Perbandingan lintas jenis di luar cakupan generator scenario modul FCL ini.
- **REQ-001** (mencakup batch order) — **Partial**. Alur manual order diuji lengkap (POS-001 dst.); alur batch order tidak diuji rinci (Assumptions Log #7).

---

## 4. Validasi Sintaks Gherkin

Struktur file `.feature` diperiksa baris-per-baris (`Feature` → `Background` → blok `Scenario`/`Scenario Outline` dengan tag di atasnya, 3 blok kategori dipisah komentar `# ====`).

**Temuan & perbaikan yang dilakukan (minimal, sesuai kewenangan):**

- **[Defect — diperbaiki]** Baris pertama file semula berbunyi `# language: id-keywords-en`. Pola `# language: <kode>` di baris pertama adalah **direktif fungsional resmi Gherkin/Cucumber** (bukan sekadar komentar bebas) yang dibaca oleh parser Cucumber (cucumber-js/-jvm/-ruby) untuk menentukan dialek keyword. `"id-keywords-en"` **bukan kode bahasa ISO yang valid** di `gherkin-languages.json` manapun, sehingga pada parser Cucumber yang strict ini berpotensi menyebabkan seluruh file gagal di-parse ("Unknown/unsupported language"). Sudah diperbaiki secara minimal menjadi komentar deskriptif biasa yang tidak memicu pola direktif tersebut:
  `# Catatan bahasa: keywords Gherkin dalam Inggris (Feature/Background/Scenario/Given/When/Then/And/Examples); teks langkah dalam Bahasa Indonesia.`
  Tidak ada baris lain yang diubah; seluruh Scenario, tag, dan step tetap identik dengan sebelumnya.

**Hasil pemeriksaan lain (tidak memerlukan perbaikan):**

- `Feature:` tunggal, deskripsi 3 baris (Sebagai/Saya ingin/Agar) — benar.
- `Background:` berisi 2 step `Given`/`And` — benar dan konsisten dipakai implisit oleh seluruh Scenario.
- Setiap `Scenario:`/`Scenario Outline:` didahului baris tag (≥1 kategori tag: `@positive`/`@negative`/`@edge`/`@stress`) — konsisten 75/75.
- Urutan keyword step (`Given`/`When`/`Then`/`And`) logis dan tidak ada step yang "menggantung" (mis. `And` tanpa `Given/When/Then` sebelumnya) di seluruh 75 scenario.
- 3 `Scenario Outline` (POS-019, POS-034, NEG-015) masing-masing memiliki blok `Examples:` dengan tabel pipe-delimited valid, dan setiap placeholder `<step>`, `<status>`, `<aksi>` pada step body memiliki kolom yang sama persis pada header tabel Examples — cocok, tidak ada placeholder yatim.
- Tabel Examples pada NEG-015 memiliki inkonsistensi spasi kosmetik (`| Selesai   |` vs `| Dibatalkan|` tanpa padding kanan) — ini **valid secara sintaks** (Gherkin men-trim isi sel), murni gaya penulisan, **tidak diperbaiki** karena bukan cacat fungsional.
- Tidak ditemukan tag ganda pada baris yang sama, tag tanpa `@`, atau penulisan `Scenario` yang seharusnya `Scenario Outline` (atau sebaliknya).

**Catatan konvensi tag (observasi, bukan defect):**

- Task template QA mengharapkan validasi tag `@priority-*` dan `@screen-*`, namun **tag-tag ini memang tidak dipakai sama sekali** di seluruh `.feature` (baik untuk 75 scenario maupun feature-level). Informasi layar tersedia di field `screen` pada `.scenarios.json`, bukan sebagai tag `.feature`. Ini konsisten di seluruh file (bukan kesalahan sebagian), kemungkinan merupakan konvensi pipeline yang belum mengadopsi kedua kategori tag tersebut. **Rekomendasi**: pertimbangkan menambahkan `@screen-*` (mis. `@screen-step2`, `@screen-daftar-order`) dan `@priority-*` (mis. `@priority-critical` untuk POS-001, POS-018, POS-021, POS-022) pada iterasi berikutnya untuk mempermudah filtering test run — bukan blocking untuk rilis saat ini.
- Beberapa scenario terkait fitur visualisasi/struktural tidak memiliki tag `@REQ-*` sama sekali di `.feature` meskipun field `requirements[]` pada `.scenarios.json` mengisinya: EDG-008 (→ REQ-005), EDG-010 (→ REQ-021/030), EDG-012 (→ REQ-003), STR-004 (→ REQ-005), STR-009 (→ REQ-030). **Rekomendasi**: tambahkan tag `@REQ-*` yang bersangkutan pada `.feature` agar traceability berbasis tag konsisten dengan JSON. Tidak mengubah file karena ini penambahan tag substantif (di luar kewenangan "perbaikan minimal cacat sintaks"), dicatat sebagai rekomendasi.

**Kesimpulan validasi**: setelah 1 perbaikan minimal di atas, file `.feature` **valid secara sintaks Gherkin** dan siap dieksekusi oleh parser Cucumber standar.

---

## 5. Kecukupan Edge & Stress

**Edge (16 scenario)** — menutupi kategori: validasi batas alert kapasitas (EDG-001..003, EDG-006), normalisasi input (EDG-004), penghapusan total (EDG-005), skala No. Perjalanan (EDG-007), struktur kombinasi Multipoint (EDG-008), asuransi parsial (EDG-009), indikator overload visualisasi (EDG-010), kondisi tampil bersyarat (EDG-011: Waktu Perjalanan), perubahan parameter simulasi (EDG-012), manipulasi baris dinamis (EDG-013), siklus status penuh (EDG-014), anti-duplikasi (EDG-015), dan persistensi lintas sesi (EDG-016). **Cakupan dinilai memadai dan cukup beragam** — tidak hanya varian happy-path yang "sedikit dimodifikasi", tetapi benar-benar menyasar kondisi batas (boundary), state transition, dan interaksi antar-field.

**Stress (9 scenario)** — menutupi skala data (STR-001: 50 baris barang, STR-002: 20 nomor DO, STR-003: 10 kontainer, STR-004: 5×5 Multipoint = 25 kombinasi, STR-005: >200 order/pagination), nilai ekstrem (STR-006: nominal hampir 1 triliun, STR-007: 500% kapasitas), konkurensi/idempotensi (STR-008: multi-klik Simpan), dan beban interaksi UI (STR-009: >1.300 koli pada canvas 3D). **Cakupan dinilai memadai** untuk level scenario BDD/Gherkin — mencakup volume, nominal ekstrem, dan idempotensi, yang merupakan tiga sumbu stress-test paling relevan untuk modul form-wizard + visualisasi ini.

**Gap yang diusulkan (rekomendasi tambahan, tidak wajib untuk rilis saat ini):**

1. **Step 4 Review untuk tipe Multipickup/Multidrop/Multipoint** — belum ada scenario (baik positive maupun edge) yang memverifikasi struktur Review (076/084/093) menampilkan Data Barang per titik pick up/drop off sesuai REQ-029. Usulan: 1 scenario positive/edge baru, mis. "Step 4 Review Multipoint menampilkan Data Barang per kombinasi Pick Up–Drop Off".
2. **Edit Order & Detail Order untuk tipe multi** (078/086/095, 077/085/094) — belum diuji. Usulan: 1 scenario edge yang membuka Edit Order pada order Multidrop dan memverifikasi field Jenis/Tipe Pengiriman tetap locked sementara struktur Drop Off tetap dapat diubah.
3. **Negative test untuk REQ-005 (minimal baris per Tipe Pengiriman)** — belum ada scenario yang mencoba menghapus baris Pick Up/Drop Off hingga di bawah jumlah minimum yang disyaratkan Tipe Pengiriman (mis. Multipickup harus ≥2 titik) untuk memverifikasi validasi/blokir. EDG-013 hanya menguji tambah-lalu-hapus-baris-tambahan (kembali ke baseline valid), bukan pelanggaran minimum.
4. **Stress untuk jumlah order per Daftar Order dengan filter kombinasi** — STR-005 hanya menguji pagination murni; belum ada stress test filter+pagination bersamaan pada volume besar.
5. **Edge untuk button Batal/Sebelumnya pada Step 2–4 dan Edit Order** — POS-019 hanya menguji "Simpan ke Draf" per step; NEG-012 hanya menguji "Batal" di Step 1. Tombol "Sebelumnya" dan "Batal" pada Step 2/3/4 serta pada halaman Edit Order (REQ-023, REQ-031, REQ-038) belum punya scenario dedicated (lihat detail per-REQ di RTM §6). Ini bukan gap kritikal karena berlabel "identik dengan TMS" (Assumptions Log #2), tapi baik untuk kelengkapan regresi UI OMS.

Tidak ada penambahan scenario yang dilakukan langsung ke file (di luar kewenangan tugas ini); seluruh gap di atas dicatat sebagai rekomendasi untuk iterasi scenario-generator berikutnya.

---

## 6. Requirements Traceability Matrix (RTM)

Kolom **Kategori** menunjukkan kategori scenario pendukung yang tersedia (P=positive, N=negative, E=edge, S=stress). Status **Covered** = cakupan memadai relatif terhadap sifat requirement (validation rule → butuh P+N; requirement struktural/deskriptif → cukup P, opsional E/S). Status **Partial** = ada gap eksplisit yang dicatat.

| REQ | Deskripsi singkat | Scenario IDs | Kategori | Status |
|---|---|---|---|---|
| REQ-001 | Order FCL OMS mengacu spec TMS (FCL, Kontainer, 4 step, manual/batch) | POS-001 | P | **Partial** — alur batch order tidak diuji (asumsi #7) |
| REQ-002 | Step 2: barang dari Master Barang, bukan input manual | POS-005 | P | Covered |
| REQ-003 | Step 4: struktur Step 2 OMS + pop up visualisasi muatan | POS-017, POS-033, EDG-012 | P, E | Covered |
| REQ-004 | Step 1 identik TMS (field, tipe pengiriman, auto-draft) | POS-002, POS-003, POS-004, POS-029, POS-030, POS-031 | P | Covered (nego lintas-terkait: NEG-001) |
| REQ-005 | Rule cascading & minimal baris per Tipe Pengiriman | POS-002, POS-029, POS-030, POS-031, EDG-008, EDG-013 | P, E | **Partial** — tidak ada negative test pelanggaran minimum baris (lihat §5 gap #3) |
| REQ-006 | Validasi field wajib Step 1 | POS-002, NEG-001 | P, N | Covered |
| REQ-007 | Fungsi button Step 1 (Batal/Draf/Selanjutnya) | POS-002, POS-019, NEG-012 | P, N | Covered |
| REQ-008 | Metode Pengiriman TIDAK ada di OMS | POS-002 (`@spec-conflict`) | P | **Partial / spec-conflict** — diuji sesuai desain (field ADA), berlawanan dengan bunyi REQ-008; perlu keputusan PO (§7) |
| REQ-009 | Barang dipilih dari Master Barang via modal | POS-005 | P | Covered |
| REQ-010 | Modal pencarian by kode/nama | POS-005, NEG-013 | P, N | Covered |
| REQ-011 | Modal multi-select checkbox | POS-005 | P | Covered |
| REQ-012 | Label "Sudah Ditambahkan" | POS-007, EDG-015 | P, E | Covered |
| REQ-013 | Counter jumlah barang terpilih | POS-008 | P | Covered |
| REQ-014 | Modal button Batal & Simpan | POS-005 | P | **Partial** — hanya "Simpan" diuji; button "Batal" pada modal Pilih Barang tidak ada scenario dedicated |
| REQ-015 | Field ter-draft read-only dari Master Barang | POS-006 | P | Covered |
| REQ-016 | Field Jumlah wajib per baris | POS-009, NEG-002, STR-001 | P, N, S | Covered |
| REQ-017 | Nilai Barang wajib saat asuransi aktif | POS-010, NEG-003, EDG-006 | P, N, E | Covered |
| REQ-018 | Checkbox Tambahkan Asuransi per armada/kontainer | POS-010, NEG-009 | P, N | Covered |
| REQ-019 | Nomor DO multi-nilai koma → chip | POS-011, EDG-004, STR-002 | P, E, S | Covered |
| REQ-020 | Hapus baris barang | POS-012, EDG-005 | P, E | Covered |
| REQ-021 | Alert kapasitas non-blocking | EDG-001, EDG-002, EDG-003, STR-007 | E, S | Covered |
| REQ-022 | Helper error + border error saat field wajib kosong | NEG-002, NEG-003 | N | Covered |
| REQ-023 | Fungsi button Step 2 (Batal/Draf/Sebelumnya/Selanjutnya) | POS-009 | P | **Partial** — hanya "Selanjutnya" diuji eksplisit untuk Step 2; "Sebelumnya"/"Batal" khusus Step 2 belum ada scenario dedicated |
| REQ-024 | Step 3 identik TMS (Vendor, Tanggal, Harga, ringkasan alamat) | POS-013, POS-014, POS-032 | P | Covered |
| REQ-025 | FCL tanpa input Waktu Perjalanan; tampil saat Ditugaskan | EDG-011 | E | Covered (formula ETA−ETD+4hari tidak diverifikasi numerik — minor) |
| REQ-026 | Komponen Asuransi ikut Total Harga | POS-015, EDG-009, STR-006 | P, E, S | Covered |
| REQ-027 | Validasi field wajib & button Step 3 | NEG-004 | N | Covered (positive implisit via POS-013/014) |
| REQ-028 | Step 4 read-only ringkasan Step 1–3 | POS-016 | P | Covered |
| REQ-029 | Data Barang Step 4 struktur Step 2 OMS + label Diasuransikan | POS-016, EDG-009 | P, E | Covered |
| REQ-030 | Button visualisasi auto stuffing di Step 4 | POS-017, EDG-010, STR-009 | P, E, S | Covered |
| REQ-031 | Button Step 4 (Batal/Draf/Sebelumnya/Simpan); Simpan → Menunggu Penugasan | POS-001, POS-018, STR-008 | P, S | **Partial** — "Sebelumnya"/"Batal" khusus Step 4 belum ada scenario dedicated |
| REQ-032 | 9 status order FCL | POS-001, POS-018, EDG-014 | P, E | Covered |
| REQ-033 | Status 1–4 = draft, auto-save via Simpan ke Draf | POS-019, EDG-016 | P, E | Covered |
| REQ-034 | Edit dapat dilakukan hingga Menunggu Penugasan | POS-021, NEG-015 | P, N | Covered |
| REQ-035 | Tidak dapat edit setelah Ditugaskan | NEG-007, NEG-015 | N | Covered |
| REQ-036 | Edit Order: Jenis & Tipe Pengiriman locked | POS-021, NEG-006 | P, N | Covered |
| REQ-037 | Field lain tetap dapat diubah saat Edit | POS-021 | P | Covered |
| REQ-038 | Button Edit Order Batal/Simpan + pop up konfirmasi | POS-021 | P | **Partial** — hanya jalur "Simpan" pada Edit Order yang diuji; NEG-012 menguji "Batal" pada wizard Step 1 (REQ-007), bukan "Batal" pada halaman Edit Order — tag `@REQ-038` di NEG-012 kurang tepat sasaran |
| REQ-039 | Order dapat dibatalkan draft s.d. Ditugaskan | POS-022, POS-023, NEG-008 | P, N | Covered |
| REQ-040 | Pembatalan hanya oleh admin shipper, bukan vendor | POS-022, NEG-014 | P, N | Covered (NEG-014 memerlukan lingkungan lintas-aplikasi — asumsi #21) |
| REQ-041 | Alasan Pembatalan wajib | POS-022, POS-023, NEG-005 | P, N | Covered |
| REQ-042 | Aksi per-baris sesuai matriks status | POS-020, POS-028, POS-034, NEG-007 | P, N | Covered |
| REQ-043 | Riwayat Pembatalan (toolbar) vs Riwayat Perubahan (per-baris) | POS-027, POS-028 | P | Covered |
| REQ-044 | No. Perjalanan untuk public tracking | POS-025 | P | **Partial** — sisi OMS saja; konsumsi di public tracking di luar cakupan (UI Inventory #5) |
| REQ-045 | No. Perjalanan auto-generate, jumlah = jumlah kontainer | POS-024, EDG-007, STR-003 | P, E, S | Covered |
| REQ-046 | No. Perjalanan hanya untuk FTL & FCL | POS-024 | P | **Partial** — tidak ada verifikasi lintas jenis pengiriman (LTL/LCL tidak menampilkan) |
| REQ-047 | "Lihat No. Perjalanan" tampil hanya setelah Ditugaskan | POS-024, NEG-010 | P, N | Covered |
| REQ-048 | Pop up Data No. Perjalanan: nomor, nopol/no. kontainer, jenis | POS-024 | P | Covered |
| REQ-049 | Icon copy No. Perjalanan | POS-025 | P | Covered |
| REQ-050 | No. Perjalanan juga di Detail Order | POS-026 | P | Covered |

**Ringkasan status RTM**: 40 REQ Covered penuh, 10 REQ Partial (REQ-001, REQ-005, REQ-008, REQ-014, REQ-023, REQ-025†, REQ-031, REQ-038, REQ-044, REQ-046). †REQ-025 ditandai Partial ringan (catatan minor, bukan gap struktural).

---

## 7. Temuan & Rekomendasi

### 7.1 Perbaikan yang sudah diterapkan pada `.feature`
- Direktif Gherkin tidak valid `# language: id-keywords-en` di baris 1 diganti menjadi komentar deskriptif biasa (lihat §4) agar file dapat di-parse oleh Cucumber standar. Tidak ada perubahan lain pada `.feature`/`.json`.

### 7.2 Empat item klarifikasi ke Product Owner (diskrepansi desain vs spec, Assumptions Log #10–#13)
1. **[#10] Field "Metode Pengiriman" pada OMS** — Spec (REQ-008) menyatakan field ini tidak diperlukan di OMS, namun **seluruh 14 layar desain terkait** (060, 065–068, 072, 076–078, 084–086, 088, 093–095) menampilkannya lengkap dengan 4 opsi (Door to Door/CY/dst.). Scenario POS-002 mengikuti desain (field ADA) dan ditandai `@spec-conflict`. **Perlu keputusan**: apakah REQ-008 harus direvisi (field tetap ada di OMS), atau seluruh 14 desain perlu direvisi (field dihapus) sebelum implementasi. Dampak: berbeda hasil test-case pass/fail tergantung mana yang jadi acuan final.
2. **[#11] Redaksi alert kapasitas** — Desain memakai kata **"armada"** ("Kubikasi/Berat melebihi kapasitas **armada**"), spec (REQ-021, VAL-05) memakai kata **"kontainer"**. Scenario EDG-001..003, STR-007 memakai teks desain sebagai *expected text*. **Perlu keputusan**: samakan istilah — dampaknya kecil (redaksional) tapi memengaruhi assertion string-matching test otomatis.
3. **[#12] Button "Edit Order" pada Detail Order status Ditugaskan** — Desain 067 menampilkan button "Edit Order" pada Detail Order berstatus Ditugaskan, **berlawanan langsung** dengan REQ-035/REQ-042 yang menyatakan Edit tidak tersedia setelah Ditugaskan. Scenario NEG-007 mengikuti **spec** (Edit tidak tampil). **Perlu keputusan segera** karena ini kontradiksi fungsional (bukan sekadar redaksional) — implementasi backend perlu tahu apakah endpoint edit untuk status Ditugaskan harus diblokir (ikuti spec) atau diizinkan (ikuti desain).
4. **[#13] Istilah badge status** — Desain Daftar Order memakai "Isi Data Dasar" (spec: "Isi Data Pengiriman") dan "Terkirim" (spec: "Selesai"). Scenario memakai istilah spec sebagai kanonik dengan alias desain dicatat di `statusAliases`/selectorHints. **Perlu keputusan**: tentukan istilah final untuk copy produksi agar tidak ada mismatch antara UI aktual dan dokumentasi/test.

### 7.3 Rekomendasi tambahan (non-blocking)
- Tambahkan tag `@REQ-*` yang hilang pada EDG-008, EDG-010, EDG-012, STR-004, STR-009 agar traceability tag `.feature` selaras dengan `requirements[]` di `.scenarios.json` (lihat §4).
- Perbaiki penandaan tag `@REQ-038` pada NEG-012 — scenario tersebut sebenarnya menguji button "Batal" pada **wizard Step 1** (REQ-007), bukan pada halaman **Edit Order** (REQ-038). Sebagai gantinya, tambahkan 1 scenario baru khusus untuk "Batal pada Edit Order menampilkan pop up konfirmasi" agar REQ-038 (bagian Batal) benar-benar teruji.
- Pertimbangkan menambah `@priority-*` dan `@screen-*` tag pada iterasi berikutnya (lihat §4) untuk mempermudah eksekusi test bertarget.
- Tambahkan scenario untuk 5 gap yang diuraikan di §5 (Step 4 Review multi-tipe, Edit/Detail Order multi-tipe, negative minimal-baris REQ-005, stress filter+pagination gabungan, button Batal/Sebelumnya Step 2–4 & Edit Order) pada backlog scenario-generator berikutnya — tidak wajib untuk rilis saat ini karena bersifat pelengkap regresi, bukan risiko fungsional utama yang belum tersentuh sama sekali.

### 7.4 Kesimpulan keseluruhan
Set 75 scenario (35P/15N/16E/9S) untuk modul `oms013-order-fcl-auto-stuffing` **layak dilanjutkan ke tahap berikutnya (step generator / eksekusi otomasi)** setelah 1 perbaikan sintaks minor pada baris direktif bahasa. Cakupan REQ 50/50 dengan mayoritas (40/50) berstatus Covered penuh; 10 REQ Partial seluruhnya sudah teridentifikasi dan terdokumentasi dengan alasan jelas (out-of-scope by design, spec-conflict yang menunggu keputusan PO, atau gap regresi minor). Tidak ada duplikasi yang perlu dibuang. Distribusi edge/stress memadai dan menyasar kondisi nyata (boundary, state-transition, volume, nominal ekstrem, idempotensi), bukan sekadar variasi kosmetik dari scenario positive.
