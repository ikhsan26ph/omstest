# Selector Map — Public Tracking (`/tracking`)

> Dihasilkan oleh `/harvest-selectors oms022-public-tracking-improve`, 2026-09-02.
> Modul ini **tidak punya `ui-inventory.md`**, jadi indeks layar diambil dari tabel UI-Txx di
> `scenario/oms022-public-tracking-improve/oms022-public-tracking-improve.analysis.md` (baris 428-438).
>
> **Temuan penting sebelum pakai file ini:**
> - Implementasi **tidak punya satupun `data-testid`, `data-state`, atau `data-history-type`**
>   di seluruh halaman `/tracking` maupun `/tracking/<no>`. Seluruh `selectorCatalog` /
>   `selectorHints` di `oms022-public-tracking-improve.scenarios.json` (berbasis testid) **tidak
>   berlaku** — gunakan tabel di bawah ini (role/text) sebagai pengganti, bukan pelengkap.
> - UI memakai istilah **"Nomor Perjalanan"** (placeholder: *"Masukkan nomor perjalanan..."*),
>   BUKAN "No. Resi" seperti asumsi dokumen skenario. Field API tetap bernama `resi` (lihat
>   `POST /api/v1/public/tracking/search`, body `{"resi":["..."]}`), jadi istilah "resi" di
>   `scenarios.json` masih valid sebagai *konsep*, hanya label UI-nya beda.
> - Alur nyata **3 langkah** dan ada **langkah verifikasi yang sama sekali tidak dimodelkan**
>   di dokumen skenario: (1) isi nomor perjalanan → submit → muncul **kartu hasil ringkas**
>   (status saja, mis. "Delivered") → (2) klik **"Lihat Detail"** → **modal verifikasi 4 digit
>   terakhir no. HP penerima** → (3) baru redirect ke `/tracking/<no-perjalanan>` yang berisi
>   stepper + riwayat. Skenario `scenarios.json` yang langsung expect stepper/riwayat setelah
>   submit form (tanpa langkah verifikasi) TIDAK akan match alur nyata — perlu disesuaikan saat
>   eksekusi atau ditandai gap saat triage.
> - Deep link `?resi=<no>` hanya **mengisi ulang kotak pencarian**, bukan langsung ke halaman
>   detail (kontra ASM-027 di analysis.md yang bilang "tidak di-assert"). Halaman detail asli
>   ada di route path `/tracking/<no-perjalanan>` (setelah verifikasi sukses), bukan query param.
> - Data uji nyata yang ditemukan di staging (order asli, BUKAN `testDataSeeds` fiktif di
>   scenarios.json yang semuanya tidak ada di DB): No. Perjalanan `TRC69283535` (order
>   `ORD8160410409`, FCL, status Delivered), 4 digit verifikasi `1881` (dari No. WhatsApp PIC
>   Penerima `6283830011881` di halaman Detail Order admin). `testDataSeeds` (`LKL...`) di
>   scenarios.json semuanya menghasilkan "Nomor perjalanan tidak ditemukan" — **tidak bisa
>   dipakai**, ganti dengan No. Perjalanan asli (format `TRC...`) yang diambil dari Detail Order
>   pada akun admin sebelum eksekusi skenario positive/stepper/riwayat.

## Tabel Selector

| SCR | Elemen (nama sesuai analysis.md) | Selector terbaik | Sumber | Catatan |
|---|---|---|---|---|
| UI-T01 | Input nomor perjalanan | `page.getByPlaceholder('Masukkan nomor perjalanan...')` | getByPlaceholder | Tidak ada label/aria-label eksplisit; tidak ada `name` attr. Bukan `getByRole('textbox', {name: /no\.?\s*resi/i})` seperti asumsi doc. |
| UI-T01 | Tombol submit | `page.getByRole('button', { name: 'Lacak Pengiriman' })` | getByRole | Disabled saat input kosong; enabled begitu ada 1 karakter apa pun (tidak ada validasi format/panjang di klien). |
| UI-T01 | Chip nomor yang sudah diketik + hapus | `page.getByRole('button', { name: /^Hapus / })` | getByRole | Muncul sebagai chip di atas textbox setelah Enter/submit; mendukung multi-nomor (maks 10, pisah koma/spasi) — fitur ini sama sekali tidak ada di scenarios.json. |
| UI-T01 | Judul halaman | `page.getByRole('heading', { name: 'Lacak Pengiriman Anda dengan Mudah', level: 1 })` | getByRole | Analysis.md bilang "judul belum diketahui" — sekarang sudah diketahui, boleh dipakai sebagai assertion non-blocking. |
| UI-T01 | Section "Hasil Pencarian" | `page.getByRole('heading', { name: 'Hasil Pencarian', level: 2 })` | getByRole | Section ini SELALU ada setelah submit pertama (positif, not-found, maupun error) — bedakan lewat isi di bawahnya, bukan keberadaan section. |
| UI-T02 | Validasi input kosong | Tombol submit `[disabled]`, TIDAK ADA pesan error/alert teks | Observasi langsung | `resi-input-error` (role alert, testid) di scenarios.json **tidak ada implementasinya**. Assertion V-01/V-02/V-03 harus diganti jadi `expect(submitButton).toBeDisabled()`, bukan cari pesan error. |
| UI-T04 | Hasil tidak ditemukan — judul | `page.getByText('Nomor perjalanan tidak ditemukan')` | getByText | Match doc `tracking-not-found` (`/tidak ditemukan/i`) secara teks, tapi bukan `role="heading"` — dia `paragraph`. |
| UI-T04 | Hasil tidak ditemukan — subtext | `page.getByText('Pastikan nomor perjalanan yang Anda masukkan sudah benar.')` | getByText | — |
| UI-T05 (kartu ringkas, BARU — tidak ada di doc) | Kartu hasil per nomor (status ringkas) | `page.getByRole('listitem').filter({ hasText: '<no-perjalanan>' })` | getByRole (list/listitem, tanpa aria-label) | Berisi: teks nomor perjalanan, status singkat (mis. "Delivered"), tombol "Lihat Detail". Ini state ANTARA sebelum verifikasi — tidak dimodelkan di UI-Txx manapun di analysis.md. |
| UI-T05 (kartu ringkas) | Tombol "Lihat Detail" | `page.getByRole('button', { name: 'Lihat Detail' })` | getByRole | Klik ini membuka modal verifikasi HP, BUKAN langsung ke stepper/riwayat. |
| — Verifikasi HP (BARU, tidak ada UI-Txx) | Modal verifikasi — judul | `page.getByRole('heading', { name: 'Masukkan 4 Digit Terakhir Nomor Telepon Penerima', level: 2 })` | getByRole | Modal muncul setelah klik "Lihat Detail". |
| — Verifikasi HP | 4 kotak input digit | `page.locator('input').nth(-4)` s/d `.nth(-1)` (4 textbox terakhir di halaman saat modal terbuka) | Posisional (tidak ada label per-digit) | Tidak stabil kalau ada input lain ditambah di masa depan — TIDAK STABIL, usulkan `data-testid="otp-digit-0..3"` ke dev. |
| — Verifikasi HP | Tombol "Verifikasi" | `page.getByRole('button', { name: 'Verifikasi' })` | getByRole | Disabled sampai 4 digit terisi. |
| — Verifikasi HP | Tombol tutup modal | `page.getByRole('button', { name: 'Tutup' })` | getByRole | — |
| — Verifikasi gagal (BARU, tidak ada UI-Txx) | Pesan error verifikasi salah | `page.getByText('Data yang diinputkan salah')` | getByText | Muncul sbg alert/toast setelah submit 4 digit salah. Modal tetap terbuka (perlu dicek retry behavior utk skenario negative). |
| UI-T05/T06/T07 (halaman detail) | Judul halaman detail | `page.getByRole('heading', { name: 'Detail Tracking' })` atau cek `page.title()` = "Detail Tracking \| PT. OMESH" | getByRole/title | Route: `/tracking/<no-perjalanan>` (path, bukan query param). |
| UI-T06 Stepper | Container 3 tahap | Tidak ada role list/landmark; 3 elemen `generic` sejajar | Posisional, TIDAK STABIL | Tidak match `tracking-stepper` (role="list") di doc. Assert keberadaan teks saja (sesuai ASM-009): `page.getByText('Pick Up')`, `page.getByText('On Delivery')`, `page.getByText('Delivered')`. |
| UI-T06 Stepper | Label tiap tahap | `page.getByText('Pick Up', { exact: true })` / `'On Delivery'` / `'Delivered'` | getByText | Bahasa **Inggris** (Pick Up/On Delivery/Delivered), bukan istilah lain — cocok dgn selectorHints doc (`tracking-step-pickup` name `/pick ?up/i` dst). Tidak ada `data-state`, TAPI progres reached/current/pending **BISA** dibedakan lewat class Tailwind pada lingkaran step (temuan Batch 8, 2026-09-02): `bg-brand-500` = completed/reached, `bg-brand-100` = current/aktif, `bg-gray-100` = pending. Ini class utility, bukan semantik — rapuh terhadap redesign warna, tapi berfungsi untuk kondisi staging saat ini. Assertion minimal tetap cukup cek keberadaan teks label saja (ASM-009) kalau tidak butuh presisi reached/pending. |
| UI-T07 Riwayat Pengiriman | Judul section | `page.getByRole('heading', { name: 'Riwayat Pengiriman', level: 2 })` | getByRole | Match `history-title` doc dengan baik. |
| UI-T07 Riwayat Pengiriman | List riwayat | `page.getByRole('list').filter({ has: page.getByRole('heading', { name: 'Riwayat Pengiriman' }) }).locator('..')` atau lebih simpel: cari `list` terakhir di halaman | getByRole | ARIA role list/listitem ADA di sini (beda dgn stepper). Match `history-list`/`history-item` doc secara role. |
| UI-T07 Riwayat Pengiriman | Item riwayat — teks & waktu | Tiap `listitem` berisi 2 `paragraph`: teks event, lalu timestamp `DD/MM/YYYY HH:mm` | getByRole (paragraph di dalam listitem) | TIDAK ADA `data-history-type` — klasifikasi muat/sintetis/bongkar HARUS dari regex teks, persis seperti fallback yang sudah disiapkan doc (assertionRules), bukan attribute. |
| UI-T07 | Teks event "muat" | Match regex doc `/barang telah dimuat/i` | Text regex | Contoh nyata: "Barang telah dimuat di Kabupaten Gresik, IK - UMGresik (PT. Trimurti Jayandaru (IK))" — regex doc **cocok**. |
| UI-T07 | Teks event "sintetis" (dalam perjalanan) | Regex doc `/(berangkat ke lokasi bongkar|dalam perjalanan menuju lokasi bongkar)/i` **cocok sebagian** | Text regex | Contoh nyata cocok: "Armada dalam perjalanan menuju lokasi bongkar". TAPI ada event lain yang doc tidak antisipasi: "Barang telah tiba di ...", "Barang sedang dalam penyebrangan menuju ...", "Dalam perjalanan menuju <tujuan>, ... ", "Armada dalam perjalanan menuju lokasi penjemputan di ...". Regex doc tidak menangkap semua ini — perlu regex tambahan atau anggap gap desain saat triage. |
| UI-T07 | Teks event "bongkar" (selesai) | Regex doc `/(dibongkar\|selesai bongkar)/i` **TIDAK ditemukan match** di data nyata yang dicoba | Text regex | Order status "Delivered" tapi riwayatnya berhenti di "Barang telah diterima di ..." — tidak ada teks "dibongkar"/"selesai bongkar" eksplisit. Kemungkinan istilah beda atau event ini belum dites di order lain — cek order lain saat eksekusi, jangan langsung failed. |

## Data uji nyata (pengganti `testDataSeeds` di scenarios.json)

| No. Perjalanan | Order (internal) | Tipe | Status | 4 digit HP verifikasi |
|---|---|---|---|---|
| TRC69283535 | ORD8160410409 | FCL | Delivered | 1881 |

Cara ambil nomor lain kalau perlu variasi (multi-pickup/drop, in-progress, dsb): login admin →
`/order` → filter Status (Proses Pengiriman/Ditugaskan/Terkirim) → buka baris → tombol **⋮ "Aksi"**
(dropdown `position:fixed`, TIDAK muncul di accessibility snapshot biasa — screenshot atau
`page.getByRole('button', {name:'Detail'})` setelah klik Aksi) → **Detail** → field **"No.
Perjalanan"** di section "Vendor dan Harga", dan **"No. WhatsApp PIC" Penerima** untuk 4 digit
verifikasi.

## Layar yang di-SKIP

| SCR | Alasan |
|---|---|
| UI-T03 (loading) | State transien < 1 detik pada koneksi staging, tidak berhasil ditangkap konsisten via automation tanpa network throttling. Perlu `page.route()` delay-injection kalau mau dipetakan presisi. |
| UI-T08 (riwayat empty state) | Butuh order dengan No. Perjalanan aktif tapi nol event tracking — tidak ditemukan kandidat di 20 order pertama yang dicek (semua yang punya No. Perjalanan sudah punya riwayat). Perlu order "Ditugaskan"/baru saja mulai perjalanan tanpa event apa pun. |
| UI-T09 (gangguan sistem) | Tidak bisa dipicu tanpa memutus koneksi API secara sengaja (di luar scope read-only harvest). |
| UI-T10 (assertion negatif) | Bukan layar terpisah — kumpulan assertion "elemen X harus absen" di layar T01/T04/T05, sudah tercakup di baris-baris di atas. |

## Update pasca-eksekusi (2026-09-02, run `20260902-094941`)

- **WAJIB pakai `locator.dispatchEvent('click')`, BUKAN `locator.click()` biasa**, untuk tombol "Lacak Pengiriman", "Lihat Detail", dan "Verifikasi" di halaman `/tracking` — pola yang sama seperti sudah tercatat di `shared/decisions.md` (2026-08-23) untuk wizard Buat Order dan modul Penugasan Tracking, sekarang terkonfirmasi berlaku juga di halaman publik ini (Batch 4-8, `locator.click()` 0 network request sama sekali). Batch 1-3 sempat berhasil pakai `.click()` biasa — kemungkinan tergantung state/timing sesi CDP, jadi executor berikutnya: langsung pakai `dispatchEvent('click')` sejak awal untuk 3 tombol ini, jangan diagnosis ulang.
- Tombol **hapus/reset chip** (`Hapus <no>`) hanya mengosongkan kotak input teks — **kartu "Hasil Pencarian" beserta tombol "Lihat Detail" sebelumnya TETAP tampil**, tidak ikut ter-reset. Lihat FND-OMS022-04 di `results/_triage__oms022-public-tracking-improve__20260902-094941.md`.
- **Enter di field input TIDAK memicu submit** — hanya menokenisasi input jadi chip. Harus klik tombol "Lacak Pengiriman" secara eksplisit. Lihat FND-OMS022-03.
- **Fitur multi-resi nyata** (tidak dimodelkan dokumen skenario sama sekali): input mendukung hingga 10 nomor perjalanan dipisah koma/spasi; tiap pencarian baru **MENAMBAHKAN** chip+kartu hasil baru ke daftar yang sudah ada (bukan mengganti). URL jadi `?resi=A%2CB` (koma di-encode). Lihat FND-OMS022-05.
- State error sistem (UI-T09) **tidak terimplementasi** — kegagalan API (`POST /api/v1/public/tracking/search` 500) menghasilkan silent failure total (halaman diam di state awal, tombol submit balik enabled, TANPA pesan/toast/tombol retry). Lihat FND-OMS022-02.
- Entri riwayat "sintetis" (transit pasca-muat-sebelum-bongkar) **tidak pernah ditemukan** pada order multi-alamat manapun yang diuji (Multi Pick Up 2/3, Multi Drop 2, Multipoint 2x2/3x3) — order Normal justru punya entri transit nyata tapi dengan wording nama-lokasi-asli (bukan frasa generik "lokasi bongkar" yang diasumsikan dokumen). Lihat FND-OMS022-01 (perlu verifikasi lanjut apakah ini bug asli atau artefak seeding data staging — order multi-alamat yang diuji semuanya punya timestamp riwayat identik per order, indikasi seeding massal).

## Rekomendasi data-testid untuk developer

Tidak ada satupun `data-testid` di implementasi saat ini. Usulan prioritas tertinggi (dipakai di
hampir semua skenario `scenarios.json`), pakai nilai yang sudah diusulkan dokumen:
- `resi-input`, `resi-submit` — form utama.
- `tracking-stepper`, `tracking-step-pickup`, `tracking-step-on-delivery`, `tracking-step-delivered`
  (+ `data-state="reached|pending"`) — supaya assertion progres tidak bergantung teks warna.
- `history-list`, `history-item` (+ `data-history-type="muat|transit|bongkar"` — sebaiknya
  tambah nilai `transit` terpisah dari `sintetis`, karena riwayat nyata punya lebih banyak
  variasi event daripada 3 kategori yang diasumsikan doc).
- Tambahan BARU yang perlu diusulkan (tidak ada di doc karena flow verifikasi tidak
  diantisipasi): `tracking-result-card`, `tracking-detail-button`, `otp-digit-0..3`,
  `otp-verify-button`, `otp-error-message`.
