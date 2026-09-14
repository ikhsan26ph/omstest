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

## Update pasca-explore (2026-09-06, `/explore oms022-public-tracking-improve`)

Koreksi/pelengkap atas tabel di atas (detail: `explore/module-map.md` section oms022, `shared/decisions.md` 2026-09-06 lanjutan 2):

- **Modal verifikasi auto-close setelah 4 digit salah** — toast `Data yang diinputkan salah` muncul lalu modal tertutup sendiri (kontra baris "— Verifikasi gagal" di atas yang menyebut modal tetap terbuka). Retry = klik `Lihat Detail` lagi.
- Modal verifikasi punya subjudul `No. Perjalanan: <no>` (`page.getByText('No. Perjalanan: TRC69283535')`) — berguna memastikan modal milik nomor yang benar saat multi-nomor.
- **Deep link `?resi=<no>` auto-search on-load** (kartu ringkas langsung muncul tanpa klik) — koreksi catatan "hanya mengisi ulang kotak pencarian". Direct `/tracking/<no>` tanpa verifikasi **selalu redirect** ke `/tracking?resi=<no>`; verifikasi tidak bisa di-bypass.
- State awal punya section baru `page.getByRole('heading', { name: 'Cara Lacak Pengiriman', level: 2 })` dengan 3 langkah `Masukkan Nomor Perjalanan` / `Verifikasi Nomor Telepon` / `Lihat Status Kiriman` — jangan dihitung sebagai elemen terlarang UI-T10.
- Teks hero: tagline `Pelacakan Pengiriman`; paragraf `Pantau perjalanan pengiriman barang Anda secara real-time. Masukkan nomor perjalanan untuk mendapatkan informasi terkini.`; helper input `Maksimal 10 nomor perjalanan dalam satu pencarian. Pisahkan nomor perjalanan dengan koma atau spasi.`
- **UI-T08 (riwayat kosong) kini terpetakan**: `page.getByText('Belum ada riwayat pengiriman untuk nomor perjalanan ini.')` — semua order Ditugaskan (status publik `Pickup`) menampilkannya, mis. `TRC46182058` (4 digit 7901).
- Badge status kartu ringkas: `Pickup` / `On Delivery` / `Delivered` (mapping admin Ditugaskan / Proses Pengiriman / Terkirim).
- Halaman publik **menerima No. Resi LTL/LCL** (`RES…`); layar detail identik (label tetap `No. Perjalanan`).
- Batas 10 nomor: nomor ke-11 di-drop diam-diam, tidak ada pesan untuk di-assert.

### Data uji nyata tambahan (per 2026-09-06)

| No. Perjalanan/Resi | Order | Tipe | Status admin → publik | 4 digit | Catatan |
|---|---|---|---|---|---|
| TRC37808714 | ORD7997900707 | FTL Multipoint | Proses Pengiriman → On Delivery | 1002 / 1003 | 3 entri, 0 sintetis (FND-01) |
| TRC03546401 | ORD8338721286 | FCL Multipoint | Proses Pengiriman → On Delivery | 7702 / 7703 | 6 entri, timestamp masa depan |
| TRC62627090 | ORD7466529895 | FCL Multipickup | Proses Pengiriman → On Delivery | 1881 | 3 entri, 0 sintetis |
| TRC46182058 | ORD8337252940 | FTL Multidrop | Ditugaskan → Pickup | 7901 / 7902 | UI-T08 empty |
| TRC11182633 / TRC90557595 | ORD7556205186 | FCL Normal 2 kontainer | Ditugaskan → Pickup | 7802 | POS-030 |
| TRC08170473 | ORD8404971711 | FTL Normal | Proses Pengiriman | 2313 | belum dites publik |
| RES90584378 | ORD8337730685 | LTL | Ditugaskan → Pickup | 6001 | resi diterima |
| RES53860041 | ORD8416187200 | LCL | Ditugaskan → Pickup | 6761 | resi diterima |
| RES16310509 / RES55726511 | ORD8331456722 / ORD8331533103 | LTL / LCL | **Dibatalkan** → "tidak ditemukan" | 0002 | EDG-017 |

Daftar lengkap (19 nomor): `explore/module-map.md` section oms022.

## Update Harvest Public Tracking — `oms022-public-tracking-improve` 2026-09-14

- **Output mentah**: `artifacts/explore-scripts/harvest-selectors-oms022-public-tracking-improve.json`
- **Route**: `/tracking` dan `/tracking/<no>`
- **Cakupan live**: state awal, hasil tidak ditemukan, hasil pencarian valid, modal OTP, detail tracking setelah OTP, deep link query `?resi=<no>`, dan deep link path `/tracking/<no>`.
- **Skipped live**: tidak ada.
- **Data uji live utama**: `TRC46182058`, OTP `7901`; data negatif `TRC00000000`.
- **Catatan akses**: halaman publik, tidak perlu login.

| SCR | Elemen (nama sesuai analysis.md) | Selector terbaik | Sumber | Catatan |
|---|---|---|---|---|
| UI-T01 | Brand/link publik | `page.getByRole('link', { name: 'PT. OMESH' })` | role+name | Link header publik. |
| UI-T01 | Input nomor perjalanan | `page.getByPlaceholder('Masukkan nomor perjalanan...')` | placeholder | Pada state awal placeholder terlihat; setelah chip dibuat input kosong tidak lagi punya placeholder di harvest mentah. |
| UI-T01 | Tombol Lacak Pengiriman | `page.getByRole('button', { name: 'Lacak Pengiriman' })` | role+name | Disabled sampai ada nomor perjalanan. Gunakan `dispatchEvent('click')` sesuai catatan lama. |
| UI-T01 | Hero pelacakan | `page.getByRole('heading', { name: 'Lacak Pengiriman Anda dengan Mudah' })` | role+name | Heading non-interaktif untuk assertion state awal. |
| UI-T01 | Section cara lacak | `page.getByRole('heading', { name: 'Cara Lacak Pengiriman' })` | role+name | Heading non-interaktif untuk assertion state awal. |
| UI-T04 | Reset chip nomor tidak ditemukan | `page.getByRole('button', { name: 'Hapus TRC00000000' })` | aria-label | Nomor dinamis; gunakan regex `name: /^Hapus /` bila nomor tidak fixed. |
| UI-T04 | Pesan nomor tidak ditemukan | `page.getByText('Nomor perjalanan tidak ditemukan')` | text | Assertion utama state negatif. |
| UI-T04 | Input setelah chip | `page.locator('input').first()` scoped ke form tracking | tag scoped | Placeholder tidak muncul setelah token/chip aktif; lebih baik scope ke form/search container bila ada wrapper stabil. |
| UI-T05 | Reset chip nomor valid | `page.getByRole('button', { name: 'Hapus TRC46182058' })` | aria-label | Nomor dinamis; chip tidak menghapus kartu hasil lama menurut catatan sebelumnya. |
| UI-T05 | Kartu hasil pencarian valid | `page.getByText('TRC46182058')` atau card/list scope `hasText: 'TRC46182058'` | text dinamis | Root kartu belum punya role/testid stabil; scope assertions ke nomor perjalanan. |
| UI-T05 | Tombol Lihat Detail | `page.getByRole('button', { name: 'Lihat Detail' })` | role+name | Gunakan `dispatchEvent('click')`; pada multi-nomor wajib scope ke kartu nomor yang dimaksud. |
| UI-OTP | Modal verifikasi OTP | `page.getByText('Masukkan 4 Digit Terakhir Nomor Telepon Penerima')` | text | Root modal tidak punya `role="dialog"` pada harvest mentah. |
| UI-OTP | Subjudul nomor perjalanan di modal | `page.getByText('No. Perjalanan: TRC46182058')` | text dinamis | Gunakan untuk memastikan OTP modal milik nomor benar. |
| UI-OTP | Tombol tutup modal | `page.getByRole('button', { name: 'Tutup' })` | aria-label | Stabil via aria-label. |
| UI-OTP | Input digit OTP | `page.locator('input').nth(i)` scoped ke modal OTP | tag scoped | Tidak ada placeholder/name/aria/testid. Isi 4 input terakhir/ter-scope; selector masih lemah. |
| UI-OTP | Tombol Verifikasi | `page.getByRole('button', { name: 'Verifikasi' })` | role+name | Disabled sampai 4 digit terisi; gunakan `dispatchEvent('click')`. |
| UI-T06/T07/T08 | Halaman detail tracking | `page.getByRole('button', { name: 'Detail Tracking' })` | role+name | Live berupa button/accordion, bukan heading. URL setelah OTP: `/tracking/TRC46182058`. |
| UI-T06/T07/T08 | Nomor perjalanan di detail | `page.getByText('TRC46182058')` | text dinamis | Assertion identitas detail. |
| UI-T06/T07/T08 | Step Pick Up | `page.getByText('Pick Up')` | text | Status publik untuk order `Ditugaskan`. |
| UI-T06/T07/T08 | Step On Delivery | `page.getByText('On Delivery')` | text | Stepper non-interaktif; perlu data-testid untuk state reached/pending. |
| UI-T06/T07/T08 | Step Delivered | `page.getByText('Delivered')` | text | Stepper non-interaktif; perlu data-testid untuk state reached/pending. |
| UI-T06/T07/T08 | Riwayat Pengiriman | `page.getByText('Riwayat Pengiriman')` | text | Section riwayat detail. |
| UI-T08 | Riwayat kosong | `page.getByText('Belum ada riwayat pengiriman untuk nomor perjalanan ini.')` | text | Terkonfirmasi untuk `TRC46182058`. |
| UI-DEEPLINK-QUERY | Deep link query auto-search | `page.goto('/tracking?resi=TRC46182058'); page.getByRole('button', { name: 'Lihat Detail' })` | route+role | Kartu hasil muncul otomatis tanpa klik submit. |
| UI-DEEPLINK-PATH | Deep link path setelah session OTP | `page.goto('/tracking/TRC46182058'); page.getByRole('button', { name: 'Detail Tracking' })` | route+role | Pada sesi yang sudah verifikasi, detail bisa dibuka langsung. Tanpa verifikasi ikuti catatan lama: redirect ke query/search. |

### Ringkasan Harvest Public Tracking 2026-09-14

- Layar/state berhasil dipetakan live: **7**.
- Layar skipped live: **0**.
- Elemen mentah dari query workflow: **28**.
- Selector Public Tracking di tabel tambahan: **25**.
- Selector stabil (`role/name`, `aria-label`, `placeholder`, text assertion): **20**.
- Selector tidak stabil/perlu scoping khusus: **5** (`input` setelah chip, root kartu hasil, tombol `Lihat Detail` multi-nomor, input OTP, stepper state).

## Tambahan Penugasan Tracking Admin — Harvest `oms017-penugasan-tracking` 2026-09-14

- **Output mentah**: `artifacts/explore-scripts/harvest-selectors-oms017-penugasan-tracking.json`
- **Route**: `/penugasan-tracking`
- **Cakupan live**: Daftar Penugasan Tracking, Panel Filter, Daftar filter FCL, Detail Penugasan, Riwayat Penugasan inline, Riwayat Perubahan, Tambah Penugasan, Edit Penugasan direct URL.
- **Skipped live**: tidak ada.
- **Catatan perubahan data/precondition**: pada harvest 2026-09-14, `/penugasan-tracking/tambah` menampilkan kandidat order campuran FTL/FCL/LTL/LCL, bukan hanya FTL seperti catatan explore 2026-09-06.

| SCR | Elemen (nama sesuai ui-inventory) | Selector terbaik | Sumber | Catatan |
|---|---|---|---|---|
| PT-LIST | Menu sidebar Penugasan Tracking | `getByRole('link', { name: 'Penugasan Tracking' })` | role+name | Route `/penugasan-tracking`. |
| PT-LIST | Tombol Tambah Penugasan | `getByRole('button', { name: 'Tambah Penugasan' })` | role+name | Navigasi ke `/penugasan-tracking/tambah`. |
| PT-LIST | Tombol Filter | `getByRole('button', { name: /Filter/ })` | role+name | Saat ada filter aktif teks bisa menjadi `Filter (1)`. |
| PT-LIST | Input ID Order | `getByPlaceholder('Masukkan ID Order')` | placeholder | Stabil. |
| PT-LIST | Filter Jenis Order | `getByRole('button', { name: 'Pilih Jenis Order' })` | role+name | Dropdown custom. |
| PT-LIST | Filter Jenis Order FCL selected | `getByRole('button', { name: 'FCL - Full Container Load' })` | role+name | Setelah pilihan FCL aktif. |
| PT-LIST | Filter Rute | `getByRole('button', { name: 'Pilih Rute' })` | role+name | Dropdown custom; menggantikan pemisahan Kota Asal/Tujuan pada catatan lama. |
| PT-LIST | Filter No. Polisi/No. Kontainer | `getByPlaceholder('Masukkan No. Polisi/No. Kontainer')` | placeholder | Stabil. |
| PT-LIST | Filter Sopir/Petugas | `getByPlaceholder('Masukkan Nama Sopir/Petugas')` | placeholder | Stabil. |
| PT-LIST | Filter Status | `getByRole('button', { name: 'Pilih Status' })` | role+name | Dropdown custom. |
| PT-LIST | Filter Tahapan Tracking | `getByRole('button', { name: 'Pilih Tahapan' })` | role+name | Dropdown custom; label live lebih pendek dari catatan `Tahapan Tracking`. |
| PT-LIST | Filter Nama Vendor | `getByRole('button', { name: 'Semua Vendor' })` | role+name | Dropdown custom. |
| PT-LIST | Tombol Terapkan filter | `getByRole('button', { name: 'Terapkan' })` | role+name | Submit filter list; bukan perubahan data. |
| PT-LIST | Tombol Reset filter | `getByRole('button', { name: 'Reset' })` | role+name | Reset filter. |
| PT-LIST | Tabel Penugasan Tracking | `getByRole('table')` | role | Gunakan row-scope. |
| PT-LIST | Aksi row | `getByRole('button', { name: 'Aksi' }).nth(i)` scoped ke row | role+name (tidak unik) | Menu floating, perlu row/index. |
| PT-LIST | Menu item Detail | `getByRole('button', { name: 'Detail', exact: true })` scoped ke menu aksi | role+name | Terlihat pada action menu. |
| PT-LIST | Menu item Riwayat Perubahan | `getByRole('button', { name: 'Riwayat Perubahan' })` scoped ke menu aksi | role+name | Navigasi ke `/penugasan-tracking/{uuid}/riwayat`. |
| PT-DETAIL | Tombol Kembali detail | `getByRole('button', { name: 'Kembali' })` | role+name | Detail Penugasan. |
| PT-DETAIL | Accordion Detail Data Order | `getByRole('button', { name: 'Detail Data Order' })` | role+name | Detail Penugasan. |
| PT-DETAIL | Accordion Informasi Penugasan | `getByRole('button', { name: 'Informasi Penugasan' })` | role+name | Detail Penugasan. |
| PT-DETAIL | Tombol Lihat Detail Riwayat Penugasan | `getByRole('button', { name: 'Lihat Detail' })` scoped ke Informasi Penugasan | role+name | Membuka panel inline, bukan modal dialog. |
| PT-DETAIL | Accordion Jadwal Kapal | `getByRole('button', { name: 'Jadwal Kapal' })` | role+name | Detail Penugasan. |
| PT-DETAIL | Accordion History Tracking | `getByRole('button', { name: 'History Tracking' })` | role+name | Detail Penugasan. |
| PT-DETAIL | Tab Per Lokasi | `getByRole('button', { name: 'Per Lokasi' })` | role+name | Live berupa button. |
| PT-DETAIL | Tab Timeline | `getByRole('button', { name: 'Timeline' })` | role+name | Live berupa button. |
| PT-DETAIL | Tombol Detail di History Tracking | `getByRole('button', { name: 'Detail' })` scoped ke History Tracking | role+name (tidak unik) | Nama generik; wajib scope. |
| PT-RIWAYAT-PERUBAHAN | Link Kembali riwayat | `getByRole('link', { name: /Kembali/ })` | role+name | Teks live `← Kembali`. |
| PT-RIWAYAT-PERUBAHAN | Filter riwayat perubahan | `getByRole('button', { name: 'Filter' })` | role+name | Membuka filter riwayat. |
| PT-TAMBAH | Cari order | `getByPlaceholder('Cari order...')` | placeholder | Stabil. |
| PT-TAMBAH | Kandidat order | `getByRole('button', { name: /^ORD/ })` | role+name dinamis | Contoh live berisi campuran FTL/FCL/LTL/LCL. |
| PT-TAMBAH | Kandidat order FCL | `getByRole('button', { name: /FCL/ })` scoped ke daftar kandidat | role+name dinamis | Gunakan hanya bila butuh order FCL tersedia. |
| PT-TAMBAH | Kandidat order LTL | `getByRole('button', { name: /LTL/ })` scoped ke daftar kandidat | role+name dinamis | Live 2026-09-14 tersedia. |
| PT-TAMBAH | Kandidat order LCL | `getByRole('button', { name: /LCL/ })` scoped ke daftar kandidat | role+name dinamis | Live 2026-09-14 tersedia. |
| PT-TAMBAH | Batal Tambah Penugasan | `getByRole('button', { name: 'Batal' })` | role+name | Memicu konfirmasi bila ada perubahan/pilihan. |
| PT-TAMBAH | Simpan Tambah Penugasan | `getByRole('button', { name: 'Simpan' })` | role+name | Aksi tulis; jangan diklik saat harvest. |
| PT-EDIT | Edit Penugasan direct URL - Kembali ke List | `getByRole('button', { name: 'Kembali ke List' })` | role+name | Pada URL direct edit yang dibuka dari FCL live. |
| PT-EDIT | Edit Penugasan direct URL - Batal | `getByRole('button', { name: 'Batal' })` | role+name | Live 2026-09-14. |
| PT-EDIT | Edit Penugasan direct URL - Simpan | `getByRole('button', { name: 'Simpan' })` | role+name | Aksi tulis; jangan diklik saat harvest. |

## Rekomendasi data-testid untuk developer — Penugasan Tracking

- `tracking-assignment-filter-panel` — root panel filter daftar penugasan.
- `tracking-assignment-row` dan `tracking-assignment-row-action` — row dan action menu agar tidak bergantung index.
- `tracking-assignment-filter-order-type`, `tracking-assignment-filter-route`, `tracking-assignment-filter-status`, `tracking-assignment-filter-stage`, `tracking-assignment-filter-vendor` — dropdown filter custom.
- `tracking-assignment-detail-history-button` — tombol `Lihat Detail` pada Informasi Penugasan yang saat ini terlalu generik.
- `tracking-assignment-history-panel` — panel inline Riwayat Penugasan.
- `tracking-assignment-order-search` dan `tracking-assignment-order-option` — daftar kandidat pada Tambah Penugasan.
- `tracking-assignment-edit-form` — root form/edit state, termasuk state blocked direct edit.

## Ringkasan Harvest Penugasan Tracking 2026-09-14

- Layar berhasil dipetakan live: **8**.
- Layar skipped live: **0**.
- Elemen mentah dari query workflow: **391**.
- Selector Penugasan Tracking di tabel tambahan: **39**.
- Selector stabil (`data-testid`, id stabil, role/name, placeholder): **33**.
- Selector tidak stabil/perlu scoping khusus: **6**.
