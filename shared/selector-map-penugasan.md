# Selector Map — Modul Penugasan Tracking (`/penugasan-tracking`)

- **Tanggal harvest**: 2026-09-20 (harvest pertama untuk file ini — sebelumnya belum ada `shared/selector-map-penugasan.md`).
- **Modul pemicu**: `oms017-penugasan-tracking`.
- **Base URL**: `https://oms-staging.prahu-hub.com`.
- **Akun**: Admin Utama (`finance.roro1@gmail.com`, akun #1 `config/env.md`), sesi browser berkelanjutan (sudah login dari sesi sebelumnya).
- **Sumber acuan sebelum harvest**: `scenario/oms017-penugasan-tracking/oms017-penugasan-tracking.analysis.md` (UI Inventory — **diturunkan dari 22 file PNG desain/mockup, BUKAN live**, banyak varian layar yang saling bertentangan seperti 127 vs 139 vs 145 untuk Daftar) dipakai sebagai indeks awal; `explore/module-map.md` section "Detail Layar Modul Penugasan Tracking" (live explore 2026-09-06) dipakai sebagai referensi tambahan. **Live hari ini menunjukkan aplikasi sudah berubah signifikan dari kedua sumber tersebut** — lihat "Temuan Struktural Penting" di bawah.
- **Cakupan live 2026-09-20**: Daftar Penugasan Tracking + Panel Filter, Menu Aksi per baris (berbagai kombinasi jenis order/status/metode pengiriman), Tambah Penugasan (FTL 2-armada, FCL 1-kontainer Door to Door), Detail Penugasan (FTL Normal, FCL CY to Door Multidrop), Riwayat Penugasan (panel inline), Riwayat Perubahan (halaman terpisah), Edit Penugasan (FCL CY to Door, status Belum Berangkat), **bonus**: Isi Data Tracking, Penugasan Sopir Bongkar.
- **Skipped**: LTL/LCL varian Tambah/Detail/Edit tidak dibuka langsung sesi ini (representasi FCL sudah mewakili sebagian besar field khusus kontainer; LTL cukup terwakili oleh FTL karena struktur field identik per REQ-030/037/038); modal/dialog validasi error (REQ-034/049/056-058) tidak dipicu (perlu isi form penuh, di luar cakupan read-only harvest).

## Temuan Struktural Penting (perbedaan vs dokumen lama — DILAPORKAN APA ADANYA)

1. **Menu Aksi per baris JAUH lebih kaya dari catatan lama, dan JUMLAHNYA BERVARIASI per baris** — `module-map.md` (2026-09-06) mencatat "hanya 2 item: Detail, Riwayat Perubahan" untuk SEMUA baris. Live hari ini, jumlah item bervariasi 2–5 tergantung data/order:
   - Order **status Selesai** (SPK, FTL): **2 item** — Detail, Riwayat Perubahan.
   - Order **FTL lama** (dibuat sebelum batch 2026-09-19, data uji "asdfsadf1223"), status Belum Berangkat: **2 item saja** — Detail, Riwayat Perubahan (TIDAK ada Edit/Isi Data Tracking meski Belum Berangkat).
   - Order **FCL CY to Door** (AUTOTEST, dibuat 2026-09-19), status Belum Berangkat: **5 item** — Detail, Edit, Isi Data Tracking, **Penugasan Sopir Bongkar**, Riwayat Perubahan.
   - Order **LCL CY to CY** (AUTOTEST), status Belum Berangkat: **4 item** — Detail, Edit, Isi Data Tracking, Riwayat Perubahan (TANPA Penugasan Sopir Bongkar — sesuai REQ-067, CY to CY dikecualikan).
   - **Kesimpulan**: REQ-007 (4 item: Detail, Edit, Isi Data Tracking, Riwayat Perubahan) sudah terimplementasi, PLUS item ke-5 kondisional "Penugasan Sopir Bongkar" untuk metode pengiriman Door to Door/CY to Door (sesuai REQ-064). TAPI ada juga order lama yang cuma render 2 item walau statusnya Belum Berangkat — kemungkinan field/kondisi tertentu pada data lama (pra migrasi fitur) menyebabkan Edit/Isi Data Tracking tidak dirender. **Belum diselidiki root cause**; dicatat sebagai gap/observasi, bukan diverifikasi sebagai bug pasti karena baru diamati 1 sampel.
   - Menu 6-item dari mockup 139 (`Isi Kendala` + `Penugasan Sopir Bongkar`) **TIDAK sepenuhnya terimplementasi** — `Isi Kendala` tidak pernah muncul di sample manapun.
2. **Tombol Aksi (icon `...`) TIDAK punya `aria-label`, tapi punya atribut HTML `title="Aksi"`** — accessible name computation browser mengambil dari `title`, sehingga `getByRole('button', {name:'Aksi'})` tetap valid selama di-scope per baris (tidak unik lintas tabel).
3. **Filter panel field PERSIS 9 field seperti disebutkan di task** (sesuai juga dengan `module-map.md` 2026-09-06): ID Order, Jenis Order, Kota Asal, Kota Tujuan, No. Polisi/Kontainer, Sopir/Petugas, Status, Tahapan Tracking, Nama Vendor — **tanpa tanda wajib (`*`)**, kontras dengan mockup 139 yang memberi semua label tanda `*` (D-03 di analysis.md, dikonfirmasi tetap error styling mockup, bukan perilaku live). Panel filter tampak **selalu expanded** pada sesi ini terlepas dari klik tombol "Filter" — tidak berhasil diverifikasi apakah tombol itu memang toggle collapse/expand atau mengontrol elemen lain (mungkin dipengaruhi state sesi sebelumnya).
4. **Tabel kolom LIVE = 5 kolom**: `ID Order` + `Vendor` (gabung 1 header, cell berisi kode ORD + badge jenis FTL/FCL/LTL/LCL + badge Metode Pengiriman khusus FCL/LCL + nama vendor), `Rute`, `No. Polisi/No. Kontainer` + `Sopir` (gabung 1 header; sel FCL/LCL kontainer menampilkan `Muat: <nopol> • <sopir>` / `Bongkar: <nopol> • <sopir>` terpisah baris), `Status` (badge `Belum Berangkat`/`Dalam Perjalanan`/`Selesai` — HANYA 3 nilai terlihat, tidak ada `Dibatalkan` pada sample), kolom Aksi tanpa header teks. **Tidak ada** sub-header "Tanggal Mulai Tracking" (kontras mockup 139/145).
5. **Tambah Penugasan FCL/LCL/FTL kini punya field baru "Mode Penugasan"** (card button, bukan radiogroup HTML) — **dikonfirmasi HANYA render 1 opsi "Tugaskan ke Pengurus"** (`grid-cols-1`, 0 `<input type=radio>`, 1 `<button>`) baik untuk FTL maupun FCL. Ini **REPRODUCE LANGSUNG hari ini (2026-09-20)** dari bug **FND-OMS000-RUN-05** yang tercatat di `shared/decisions.md` (2026-09-07/08, 2026-09-18, 2026-09-19) — opsi "Tugaskan ke Sopir" masih hilang total dari DOM, bukan disabled. Field "Mode Penugasan" ternyata muncul juga di form FTL (bukan cuma FCL/LCL seperti tersirat REQ-065a), per-card (1 Mode Penugasan per Armada/Kontainer).
6. **Tombol "Batal" di Tambah Penugasan memicu native browser `confirm()` dialog** ("Perubahan akan hilang. Yakin ingin membatalkan?"), BUKAN modal custom React seperti diasumsikan beberapa dokumen lama — perlu `browser_handle_dialog` / `page.on('dialog')`, bukan selector DOM biasa.
7. **Tombol "Batal" di Edit Penugasan TIDAK memunculkan dialog apa pun** ketika tidak ada perubahan data — langsung navigasi ke `/penugasan-tracking`. Konsisten dengan catatan `shared/decisions.md` 2026-09-06 ("tombol Batal tanpa dialog konfirmasi, konsisten Batch 12").
8. **BUG-CANDIDATE BARU (live, REQ-066 violation)**: Tombol "Batal" pada halaman **Penugasan Sopir Bongkar**, ketika diakses dari tombol "Penugasan Sopir Bongkar" DI DALAM halaman **Isi Data Tracking**, menavigasi ke **`/penugasan-tracking`** (Daftar), BUKAN kembali ke `/penugasan-tracking/{uuid}/isi-tracking` (Isi Data Tracking) seperti disyaratkan REQ-066 ("kembali ke halaman Isi Data Tracking — BUKAN halaman Penugasan Tracking", ditekankan berulang di spec sebagai skenario kritikal). Dikonfirmasi via URL final: setelah klik Batal dari `/penugasan-tracking/{uuid}/tugaskan-bongkar` (yang dibuka dari dalam Isi Data Tracking), hasil akhir = `/penugasan-tracking`. Perlu retriase — kemungkinan `bugCandidate` baru untuk modul ini.
9. **Halaman Isi Data Tracking (route `/penugasan-tracking/{uuid}/isi-tracking`) untuk FCL/LCL punya alur bertahap lebih kaya dari REQ-051**: section berurutan **Muat → Kapal Berlayar → Kapal Sandar → Bongkar (per kota)**, dengan tahap terkunci ("Belum giliran" + pesan "Selesaikan Muat dulu sebelum bisa isi Kapal Berlayar.") sampai tahap sebelumnya selesai. REQ-051 hanya menyebut "Selesai Muat"/"Selesai Bongkar"; live menunjukkan tahap kapal (Berlayar/Sandar) sebagai tahap tersendiri yang wajib diisi berurutan, konsisten dengan History Tracking yang juga menampilkan tahap "Kapal Berlayar"/"Kapal Sandar" terpisah (lihat temuan #10). Field per tahap Muat: Tanggal Muat*, No. Kontainer* + No. Segel* (editable, sesuai REQ-063), Foto* (dropzone "Klik atau seret foto ke sini"), Keterangan (opsional).
10. **DISKREPANSI vs REQ-057**: dropzone foto pada Isi Data Tracking menampilkan teks **"Maks. 6 foto baru, 10MB per foto"** — REQ-057 mensyaratkan maksimal **4 MB** per foto. Belum diverifikasi apakah ini teks UI yang salah atau validasi backend benar-benar 10MB; dicatat sebagai discrepancy untuk klarifikasi/triase, BUKAN langsung disimpulkan sebagai bug.
11. **History Tracking (Detail Penugasan) untuk FCL/LCL dikelompokkan per label "Muat"/"Bongkar"**, bukan cuma daftar kota flat seperti FTL/LTL: grup "Muat" berisi 3 tahap bernama (`Muat`, `Kapal Berlayar`, `Kapal Sandar`, semuanya "Belum diisi" bila belum ada data), grup "Bongkar" berisi kartu per kota tujuan (label kota + alamat + "N/2 tahapan tercatat"). FTL/LTL History Tracking HANYA berisi grup kota (tanpa tahap kapal) — konsisten `module-map.md` lama.
12. **Detail Penugasan FCL memakai layout varian "148"** (satu section "Informasi Penugasan" dengan 3 sub-heading: Informasi Umum, Penugasan Muat, Penugasan Bongkar) — BUKAN varian "147" (2 section terpisah). Mengkonfirmasi keputusan D-13 di `analysis.md` yang memilih 148 sebagai acuan primer.
13. **Section "Jadwal Kapal" pada Detail & Edit Penugasan FCL adalah accordion TERPISAH dari "Informasi Penugasan"** (bukan sub-bagian), sesuai REQ-045.
14. **Riwayat Penugasan (panel inline, bukan modal popup)** — dikonfirmasi lagi sesuai `module-map.md`. Untuk penugasan dengan Muat+Bongkar terpisah, panel menampilkan **2 sub-grup label "Penugasan Awal" dan "Penugasan Bongkar"** (bukan tab yang bisa diklik — keduanya statis/plain div, ditampilkan sekaligus), masing-masing dengan Tanggal Perubahan/Armada/Sopir sendiri.
15. **Riwayat Perubahan (halaman terpisah) kolom filter "Tanggal Perubahan" memakai `id` auto-generated pola `dp-_r_0_`** — mengikuti pola id tidak stabil (`:r0:`-style React), TIDAK dipakai sebagai selector utama.
16. **REQ-065b terkonfirmasi live**: order dengan Mode Penugasan = "Tugaskan ke Pengurus" (satu-satunya mode yang tersedia karena temuan #5), pada form Penugasan Sopir Bongkar kedua radio "Pilih Dari Master"/"Isi Data Manual" (Armada Bongkar & Sopir Bongkar) sama-sama `disabled:false`.
17. **Field "Tanggal Permintaan Bongkar" pada Penugasan Sopir Bongkar punya validasi eksplisit "Tidak boleh sebelum ETA"** (ditampilkan sebagai helper text, bukan cuma required) — detail baru dibanding D-09 di `analysis.md` yang hanya mencatat field ini sebagai required tambahan di luar REQ-064.

## Tabel Selector

| SCR | Elemen | Selector terbaik | Sumber | Catatan |
|---|---|---|---|---|
| SCR-00 | Menu sidebar Penugasan Tracking | `getByRole('link', { name: 'Penugasan Tracking' })` | role+name | Route `/penugasan-tracking`. |
| SCR-01 | Judul halaman | `getByRole('heading', { name: 'Penugasan Tracking', level: 2 })` | role+name | — |
| SCR-01 | Tombol Tambah Penugasan | `getByRole('button', { name: 'Tambah Penugasan' })` | role+name | Navigasi `/penugasan-tracking/tambah`. |
| SCR-01 | Tombol toggle Filter | `getByRole('button', { name: 'Filter' })` | role+name | Perilaku toggle tidak terverifikasi jelas sesi ini (panel selalu terlihat expanded), lihat Temuan #3. |
| SCR-01 | Dropdown jumlah data (page size) | `locator('select').first()` scoped ke toolbar (opsi 10/20/50/100) | TIDAK STABIL | Native select tanpa label eksplisit; ada teks "Tampilkan ... data" di sekitarnya. |
| SCR-01 | Filter ID Order | `getByPlaceholder('Masukkan ID Order')` | placeholder | Label "ID Order", tanpa tanda wajib. |
| SCR-01 | Filter Jenis Order | `getByRole('button', { name: 'Pilih Jenis Order' })` | role+name | Dropdown custom (bukan native select); belum diverifikasi isi opsi (FTL/FCL/LTL/LCL diasumsikan). |
| SCR-01 | Filter Kota Asal | `getByRole('button', { name: 'Pilih Rute' })` scoped ke blok "Kota Asal" | role+name (tidak unik, ada 2× "Pilih Rute") | Wajib scope via label induk "Kota Asal" vs "Kota Tujuan". |
| SCR-01 | Filter Kota Tujuan | `getByRole('button', { name: 'Pilih Rute' })` scoped ke blok "Kota Tujuan" | role+name (tidak unik) | idem. |
| SCR-01 | Filter No. Polisi / Kontainer | `getByPlaceholder('Masukkan No. Polisi/No. Kontainer')` | placeholder | Label "No. Polisi / Kontainer". |
| SCR-01 | Filter Sopir / Petugas | `getByPlaceholder('Masukkan Nama Sopir/Petugas')` | placeholder | Label "Sopir / Petugas". |
| SCR-01 | Filter Status | `getByRole('button', { name: 'Pilih Status' })` | role+name | Dropdown custom. |
| SCR-01 | Filter Tahapan Tracking | `getByRole('button', { name: 'Pilih Tahapan' })` | role+name | Dropdown custom — mendukung REQ-015 (field ini historisnya absen di semua mockup, tapi ADA live). |
| SCR-01 | Filter Nama Vendor | `getByRole('button', { name: 'Semua Vendor' })` | role+name | Default value = "Semua Vendor" (bukan placeholder generik "Pilih Vendor"). |
| SCR-01 | Tombol Reset | `getByRole('button', { name: 'Reset' })` scoped ke panel filter | role+name | — |
| SCR-01 | Tombol Terapkan | `getByRole('button', { name: 'Terapkan' })` scoped ke panel filter | role+name | Terkonfirmasi berfungsi — filter ID Order menyaring tabel ke 1 baris tepat. |
| SCR-01 | Tabel | `getByRole('table')` | role | 5 kolom (lihat Temuan #4). |
| SCR-01 | Header kolom ID Order/Vendor | `getByRole('columnheader', { name: 'ID Order Vendor' })` | role+name | Gabungan 2 baris teks jadi 1 accessible name. |
| SCR-01 | Header kolom Rute | `getByRole('columnheader', { name: 'Rute' })` | role+name | — |
| SCR-01 | Header kolom Nopol/Kontainer+Sopir | `getByRole('columnheader', { name: 'No. Polisi/No. Kontainer Sopir' })` | role+name | — |
| SCR-01 | Header kolom Status | `getByRole('columnheader', { name: 'Status' })` | role+name | — |
| SCR-01 | Badge jenis order (per baris) | `row.getByText('FCL', { exact: true })` dst (FTL/FCL/LTL/LCL) | text, scoped per row | — |
| SCR-01 | Badge metode pengiriman (FCL/LCL, per baris) | `row.getByText('CY to Door', { exact: true })` dst | text, scoped per row | Hanya tampil utk FCL/LCL. |
| SCR-01 | Chip Multipickup/Multidrop (per baris, kolom Rute) | `row.getByRole('button', { name: 'Multipickup' })` / `'Multidrop'` | role+name, scoped per row | Sama pola dgn modul Order. |
| SCR-01 | Tombol Aksi (per baris) | `row.getByRole('button', { name: 'Aksi' })` | role+name (via `title="Aksi"`, TIDAK unik — scope wajib per row) | Icon-only (`lucide-ellipsis`), tanpa `aria-label`; accessible name berasal dari atribut `title`. |
| SCR-01 | Info pagination | `getByText(/Menampilkan \d+–\d+ data dari \d+ data/)` | text | Live: "Menampilkan 1–20 data dari 142 data" (142 total order — jauh lebih banyak dari 65 baris di catatan 2026-09-06). |
| SCR-01 | Kontrol pagination | `getByRole('button', { name: 'Halaman pertama' })` / `'Sebelumnya'` / `'Berikutnya'` / `'Halaman terakhir'` / angka halaman | role+name | — |
| SCR-02 | Item menu Aksi — Detail | `menu.getByRole('button', { name: 'Detail', exact: true })` | role+name, scoped ke container `div.fixed.z-9999` (bukan `role=menu`) | Selalu ada di semua sample. |
| SCR-02 | Item menu Aksi — Edit | `menu.getByRole('button', { name: 'Edit', exact: true })` | role+name (scoped) | Muncul kondisional (lihat Temuan #1) — jangan asumsikan selalu ada. |
| SCR-02 | Item menu Aksi — Isi Data Tracking | `menu.getByRole('button', { name: 'Isi Data Tracking' })` | role+name (scoped) | Navigasi ke `/penugasan-tracking/{uuid}/isi-tracking`. |
| SCR-02 | Item menu Aksi — Penugasan Sopir Bongkar | `menu.getByRole('button', { name: 'Penugasan Sopir Bongkar' })` | role+name (scoped) | Hanya utk metode Door to Door/CY to Door (REQ-064); absen utk CY to CY (REQ-067). Navigasi ke `/penugasan-tracking/{uuid}/tugaskan-bongkar`. |
| SCR-02 | Item menu Aksi — Riwayat Perubahan | `menu.getByRole('button', { name: 'Riwayat Perubahan' })` | role+name (scoped) | Navigasi ke `/penugasan-tracking/{uuid}/riwayat`. |
| SCR-02 | Container dropdown menu Aksi | `document.querySelector('div.fixed.z-9999')` (CSS, bukan role) | TIDAK STABIL (class Tailwind utility, bukan `role="menu"`) | Tidak punya `role`/`aria` sama sekali; harus di-scope via class CSS atau posisi DOM. Rekomendasi developer: tambah `role="menu"` + `data-testid`. |
| SCR-03 | Judul halaman | `getByRole('heading', { name: 'Tambah Penugasan', level: 1 })` | role+name | — |
| SCR-03 | Search order | `getByPlaceholder('Cari order...')` | placeholder | Huruf kecil "order...", sesuai gotcha `shared/decisions.md` 2026-08-29. |
| SCR-03 | Opsi order (list) | `getByRole('button', { name: /ORD\d+/ })` | role+name (teks dinamis panjang) | Format: `<ID Order> • <Vendor> <JENIS> <Rute> • <armada/kontainer info>`. |
| SCR-03 | Ringkasan order (read-only, setelah pilih) | `getByText('Kota Asal').locator('..')` dst, atau by label persis (`Kota Asal`, `Kota Tujuan`, `Pelabuhan Asal`, `Pelabuhan Tujuan`, `Jenis Kontainer`, `Jumlah Kontainer`, `Metode Pengiriman`, `Tanggal Permintaan Muat`) | text | Field FCL; FTL hanya `Kota Asal`/`Kota Tujuan`/`Jenis Armada`/`Jumlah Armada` (REQ-027/069). |
| SCR-03 | Card kontainer/armada — No. Kontainer | `getByLabel('No. Kontainer')` / `getByPlaceholder('Masukkan No. Kontainer')` | label/placeholder (tidak unik jika >1 card, scope per card) | FCL/LCL only. |
| SCR-03 | Card kontainer/armada — No. Segel | `getByLabel('No. Segel')` / `getByPlaceholder('Masukkan No. Segel')` | label/placeholder (tidak unik) | FCL/LCL only. |
| SCR-03 | Radio metode Armada Muat/Sopir Muat | `getByRole('radio', { name: 'Pilih Dari Master' })` / `'Isi Data Manual'` | role+name (tidak unik, banyak instance per halaman) | Wajib scope per card/section. |
| SCR-03 | Dropdown master No. Polisi/Jenis Armada | `getByRole('button', { name: 'Pilih No. Polisi/Jenis Armada' })` | role+name (tidak unik) | Custom combobox, scope per card. |
| SCR-03 | Dropdown master Sopir/No. WhatsApp | `getByRole('button', { name: 'Pilih Sopir/No. WhatsApp' })` | role+name (tidak unik) | idem. |
| SCR-03 | Field manual No. Polisi (FTL/LTL) | `getByLabel('No. Polisi')` / `getByPlaceholder('Masukkan No. Polisi')` | label/placeholder | Muncul saat metode "Isi Data Manual". |
| SCR-03 | Field manual Nama Sopir | `getByLabel('Nama Sopir')` / `getByPlaceholder('Masukkan Nama Sopir')` | label/placeholder | — |
| SCR-03 | Field manual No. WhatsApp (opsional) | `getByLabel('No. WhatsApp (opsional)')` / `getByPlaceholder('Contoh: 621234567898')` | label/placeholder | Placeholder BUKAN "Masukkan No. WhatsApp" (koreksi vs beberapa dokumen lama), sesuai `shared/decisions.md` 2026-08-29. |
| SCR-03 | Mode Penugasan (card button) | `getByRole('button', { name: /Tugaskan ke Pengurus/ })` | role+name (teks gabung dgn deskripsi) | **HANYA 1 opsi live** (lihat Temuan #5) — `getByRole('radio', {name:'Tugaskan ke Sopir'})` TIDAK akan ditemukan sampai bug FND-OMS000-RUN-05 diperbaiki. |
| SCR-03 | Jenis Jadwal Kapal | `getByRole('button', { name: /^Direct/ })` / `/^Connecting/` | role+name (teks gabung dgn deskripsi) | Card button, FCL/LCL only. |
| SCR-03 | Pelayaran | `getByRole('button', { name: 'Pilih Pelayaran' })` | role+name | — |
| SCR-03 | Nama Kapal | `getByLabel('Nama Kapal')` / `getByPlaceholder('Masukkan Nama Kapal')` | label/placeholder | — |
| SCR-03 | Voyage | `getByLabel('Voyage')` / `getByPlaceholder('Masukkan Voyage')` | label/placeholder | — |
| SCR-03 | Closing Time | `getByRole('button', { name: 'dd/mm/yyyy hh:mm' })` scoped label "Closing Time" | role (value=placeholder saat kosong, tidak unik) | Datetime picker custom. |
| SCR-03 | Berangkat (ETD) / Tiba (ETA) | `getByRole('button', { name: 'dd/mm/yyyy' })` scoped label masing-masing | role (tidak unik, 2 instance identik) | Date-only picker. |
| SCR-03 | Footer — Batal | `getByRole('button', { name: 'Batal' })` scoped footer | role+name | Memicu **native `confirm()` dialog** (Temuan #6) — pakai `browser_handle_dialog`/`page.on('dialog')`. |
| SCR-03 | Footer — Simpan | `getByRole('button', { name: 'Simpan' })` scoped footer | role+name | Aksi tulis — JANGAN diklik saat harvest/test read-only. |
| SCR-04 | Judul halaman | `getByRole('heading', { name: 'Detail Penugasan', level: 1 })` | role+name | — |
| SCR-04 | Tombol Kembali | `getByRole('button', { name: 'Kembali' })` | role+name | Navigasi ke `/penugasan-tracking`. |
| SCR-04 | Accordion Detail Data Order | `getByRole('button').filter({ has: page.getByRole('heading', { name: 'Detail Data Order' }) })` atau `getByRole('heading', {name:'Detail Data Order'}).locator('..')` | role (heading di dalam button, bukan button dgn accessible name langsung) | Klik toggle expand/collapse; expanded default. |
| SCR-04 | Field Detail Data Order (FTL) | `getByText('ID Order').locator('..')` dst: `ID Order`, `Jenis Order`, `Kota Asal`, `Kota Tujuan`, `Tanggal Permintaan Muat`, `Jenis Armada`, `Kapasitas Armada` | text | 7 field FTL. |
| SCR-04 | Field Detail Data Order (FCL, tambahan) | idem + `Pelabuhan Asal`, `Pelabuhan Tujuan`, `Jenis Kontainer`, `Kapasitas Kontainer`, `Metode Pengiriman` | text | 10 field FCL (REQ-069 terpenuhi). |
| SCR-04 | Accordion Informasi Penugasan | `getByRole('heading', { name: 'Informasi Penugasan', level: 3 })` (parent adalah button toggle) | role | — |
| SCR-04 | Sub-heading Informasi Umum/Penugasan Muat/Penugasan Bongkar (FCL) | `getByRole('heading', { name: 'Informasi Umum', level: 4 })` dst | role+name | Layout varian "148" (Temuan #12). |
| SCR-04 | Riwayat Penugasan — trigger | `getByRole('button', { name: 'Lihat Detail' })` scoped ke Informasi Umum/Informasi Penugasan | role+name (tidak unik jika >1 instance) | Membuka panel inline (Temuan #14), bukan modal popup. |
| SCR-04 | Accordion Jadwal Kapal (FCL) | `getByRole('heading', { name: 'Jadwal Kapal', level: 3 })` | role | Section terpisah, field: Pelayaran, Nama Kapal, Voyage, Closing Time, Berangkat (ETD), Tiba (ETA). |
| SCR-04 | Accordion History Tracking | `getByRole('heading', { name: 'History Tracking', level: 3 })` | role | — |
| SCR-04 | Tab Per Lokasi / Per Tahapan | `getByRole('button', { name: 'Per Lokasi' })` (FTL/LTL) | role+name | Untuk FCL, cek label tab aktual (belum terverifikasi ulang di sesi ini — `module-map.md` sebut "Per Tahapan" utk FCL, tapi live FCL sesi ini menampilkan grup Muat/Bongkar langsung tanpa tab terlihat berlabel beda; perlu cek ulang). |
| SCR-04 | Tab Timeline | `getByRole('button', { name: 'Timeline' })` | role+name | — |
| SCR-04 | Grup lokasi/tahap History Tracking | `getByText(/\(\d+\/\d+ alamat selesai\)/)` scoped per grup | text | FTL/LTL: grup per kota. FCL/LCL: grup "Muat" (3 tahap kapal) + grup "Bongkar" (per kota). |
| SCR-05 | Panel Riwayat Penugasan — judul | `getByText('Riwayat Penugasan')` (heading dalam panel) | text | Inline, bukan `role=dialog`. |
| SCR-05 | Panel — sub-grup label | `getByText('Penugasan Awal')` / `'Penugasan Bongkar'` | text (plain div, BUKAN tab/button interaktif) | Ditampilkan sekaligus, bukan toggle. |
| SCR-05 | Panel — field Tanggal Perubahan/Armada/Sopir | `getByText('Tanggal Perubahan').locator('..')` dst | text | — |
| SCR-05 | Panel — Tutup | `getByRole('button', { name: 'Tutup' })` | role+name | — |
| SCR-06 | Judul halaman (tab title) | `Riwayat Perubahan Penugasan \| Prahu Hub - OMS` | — | — |
| SCR-06 | Link Kembali (breadcrumb) | `getByRole('link', { name: '← Kembali' })` | role+name | Teks termasuk simbol panah. |
| SCR-06 | Filter Tanggal Perubahan | `getByPlaceholder('dd/mm/yyyy')` | placeholder | `id` auto-generated (`dp-_r_0_`-pola) — JANGAN dipakai sbg selector (Temuan #15). |
| SCR-06 | Filter Diubah Oleh | `getByPlaceholder('Nama atau email user')` | placeholder | — |
| SCR-06 | Tombol Reset/Terapkan | `getByRole('button', { name: 'Reset' })` / `'Terapkan'` | role+name | — |
| SCR-06 | Header kolom | `getByText('No', { exact: true })`, `'Tanggal Perubahan'`, `'Diubah Oleh'`, `'Total Perubahan'` | text | Bukan `<table>` — div-based grid, tanpa `role=columnheader`. |
| SCR-06 | Empty state | `getByText('Belum ada riwayat perubahan untuk penugasan ini.')` | text | Tampil untuk semua order yang belum pernah melalui Edit-Simpan sukses (masih terblokir FND-OMS017-16 per `shared/decisions.md`). |
| SCR-07 | Judul halaman | `getByRole('heading', { name: 'Edit Penugasan', level: 1 })` | role+name | Tidak redirect untuk status Belum Berangkat (beda dari status non-editable, lihat `module-map.md` Temuan lama #FND-11). |
| SCR-07 | Section Info Order (read-only) | `getByRole('heading', { name: 'Info Order', level: 3 })` | role | Field: ID Order, Vendor, Kota Asal, Kota Tujuan, Pelabuhan Asal, Pelabuhan Tujuan, Jenis Kontainer, Jumlah Kontainer, Metode Pengiriman, Tanggal Permintaan Muat (FCL — 10 field, sesuai REQ-075). |
| SCR-07 | Card Kontainer N — No. Kontainer/No. Segel | `getByLabel('No. Kontainer')` / `getByLabel('No. Segel')` (scope per card) | label (tidak unik) | Editable saat status masih Menunggu Proses/Belum Berangkat (REQ-078). |
| SCR-07 | Card — Armada Muat/Sopir Muat | **ABSEN untuk Metode Pengiriman CY to Door** pada sample ini | — | Sesuai REQ-044 (CY-Door/CY-CY sembunyikan Nopol/Armada) — dikonfirmasi live: 0 field Armada Muat/Sopir Muat dirender di Edit utk order CY to Door. |
| SCR-07 | Mode Penugasan (read-only card) | `getByText('Tugaskan ke Pengurus')` scoped ke card kontainer | text (bukan interaktif di Edit) | — |
| SCR-07 | Jenis Jadwal Kapal + Detail Kapal Utama | sama seperti SCR-03, sudah terisi (`value` non-empty) | role+name | Editable sampai Selesai Muat (REQ-079). |
| SCR-07 | Footer — Batal | `getByRole('button', { name: 'Batal' })` scoped footer | role+name | **TANPA dialog konfirmasi** jika tidak ada perubahan (Temuan #7) — beda dari Tambah Penugasan. |
| SCR-07 | Footer — Simpan | `getByRole('button', { name: 'Simpan' })` scoped footer | role+name | Aksi tulis, riskan FND-OMS017-16 (404) per `shared/decisions.md` — JANGAN diklik saat harvest. |
| SCR-08 | Judul halaman | `getByRole('heading', { name: 'Isi Data Tracking', level: 1 })` | role+name | Route `/penugasan-tracking/{uuid}/isi-tracking`. Bonus screen (di luar 5 layar wajib task, dipetakan krn baru bisa diakses read-only). |
| SCR-08 | Ringkasan order (read-only) | `getByText(/^ORD\d+/)`, teks rute, `Tanggal permintaan muat: ...` | text | — |
| SCR-08 | Section tahap "Muat" (aktif) | `getByRole('heading', { name: 'Muat', level: 3 })` + badge "Saat ini" | role+name/text | — |
| SCR-08 | Tanggal Muat | `getByRole('button', { name: 'DD/MM/YYYY HH:mm' })` scoped label "Tanggal Muat" | role (placeholder value) | Datetime picker. |
| SCR-08 | No. Kontainer/No. Segel (editable saat Selesai Muat) | `getByLabel('No. Kontainer')` / `getByLabel('No. Segel')` scoped section Muat | label | Sesuai REQ-063. |
| SCR-08 | Foto dropzone | `getByText('Klik atau seret foto ke sini')` | text | Teks batas: "Maks. 6 foto baru, 10MB per foto" — **beda dari REQ-057 (4 MB)**, lihat Temuan #10. |
| SCR-08 | Keterangan | `getByPlaceholder('Keterangan opsional...')` | placeholder | Textarea, opsional. |
| SCR-08 | Tombol Simpan (per tahap) | `getByRole('button', { name: 'Simpan' })` scoped section aktif | role+name | Aksi tulis — JANGAN diklik saat harvest. |
| SCR-08 | Section tahap terkunci (Kapal Berlayar/Kapal Sandar) | `getByRole('heading', { name: 'Kapal Berlayar', level: 3 })` + `getByText('Belum giliran')` | role+name/text | Terkunci sampai tahap sebelumnya selesai. |
| SCR-08 | Shortcut Penugasan Sopir Bongkar | `getByRole('button', { name: 'Penugasan Sopir Bongkar' })` | role+name | Navigasi ke `/penugasan-tracking/{uuid}/tugaskan-bongkar`. |
| SCR-08 | Grup kota Bongkar (collapsed) | `getByRole('heading', { name: '<Nama Kota>', level: 3 })` + `getByText(/\(\d+ alamat\)/)` | role+name/text | — |
| SCR-09 | Judul halaman | `getByRole('heading', { name: 'Penugasan Sopir Bongkar', level: 1 })` | role+name | Route `/penugasan-tracking/{uuid}/tugaskan-bongkar`. Bonus screen. |
| SCR-09 | Ringkasan order | `getByText('ID Order').locator('..')` dst: ID Order, Jenis Pengiriman, Pelabuhan Asal, Pelabuhan Tujuan, Jenis Kontainer, Metode Pengiriman, Tiba (ETA) | text | — |
| SCR-09 | No. Kontainer/No. Segel/Mode Penugasan (read-only) | `getByText('No. Kontainer').locator('..')` dst | text | Mode Penugasan read-only, mengikuti REQ-065a. |
| SCR-09 | Tanggal Permintaan Bongkar | `getByRole('button', { name: /\d{2}\/\d{2}\/\d{4}/ })` scoped label "Tanggal Permintaan Bongkar" | role (value dinamis) | Helper text validasi: "Tidak boleh sebelum ETA (...)" — detail baru (Temuan #17). |
| SCR-09 | Radio Armada Bongkar / Sopir Bongkar | `getByRole('radio', { name: 'Pilih Dari Master' })` / `'Isi Data Manual'` scoped per section | role+name (tidak unik) | Kedua opsi `disabled:false` saat Mode Penugasan = Tugaskan ke Pengurus (REQ-065b, Temuan #16). |
| SCR-09 | No. Polisi (manual) | `getByLabel('No. Polisi')` / `getByPlaceholder('Masukkan No. Polisi')` scoped section Armada Bongkar | label/placeholder | — |
| SCR-09 | Nama Sopir (manual) | `getByLabel('Sopir')` atau `getByPlaceholder('Masukkan Nama Sopir')` scoped section Sopir Bongkar | label/placeholder | — |
| SCR-09 | No. WhatsApp (opsional) | `getByPlaceholder('Contoh: 621234567898')` scoped section Sopir Bongkar | placeholder | — |
| SCR-09 | Footer — Batal | `getByRole('button', { name: 'Batal' })` scoped footer | role+name | **BUG-CANDIDATE**: saat diakses dari Isi Data Tracking, Batal menavigasi ke `/penugasan-tracking` (Daftar), BUKAN kembali ke Isi Data Tracking — pelanggaran REQ-066 (Temuan #8). |
| SCR-09 | Footer — Simpan | `getByRole('button', { name: 'Simpan' })` scoped footer | role+name | Aksi tulis — JANGAN diklik saat harvest. |

## Rekomendasi data-testid untuk developer

- `penugasan-row-action-menu` — root dropdown menu Aksi per baris (`div.fixed.z-9999` saat ini, tanpa `role="menu"` maupun `aria-label`); tambahkan `role="menu"` agar accessible dan mudah di-scope.
- `penugasan-row-action-trigger` — tombol `...` pemicu menu Aksi; saat ini hanya punya `title="Aksi"` (tidak ada `aria-label`/testid), dan TIDAK unik per baris (perlu scoping manual via row).
- `penugasan-filter-page-size` — native `<select>` jumlah data tanpa `<label>` terhubung.
- `penugasan-filter-tanggal-perubahan` (halaman Riwayat Perubahan) — input date filter memakai `id` auto-generated pola React (`dp-_r_0_`), butuh testid stabil.
- `penugasan-mode-penugasan-card` — card button "Tugaskan ke Pengurus"/"Tugaskan ke Sopir" (Tambah/Edit Penugasan); saat ini plain `<button>` tanpa `role="radio"` maupun testid, dan opsi kedua ("Tugaskan ke Sopir") hilang total dari DOM (bug FND-OMS000-RUN-05) sehingga tidak bisa diuji sampai diperbaiki.
- `penugasan-jadwal-kapal-jenis-card` — card button Direct/Connecting, sama pola dengan modul Order (tanpa `role=radio`).
- `penugasan-riwayat-panel` — root panel inline Riwayat Penugasan (Detail Penugasan); saat ini tanpa `role`/testid, sub-grup "Penugasan Awal"/"Penugasan Bongkar" juga plain `<div>`.
- `penugasan-tracking-stage-section` — section tahap (Muat/Kapal Berlayar/Kapal Sandar/Bongkar) pada Isi Data Tracking; testid per tahap akan membantu automation menunggu state "Saat ini" vs "Belum giliran" tanpa parsing teks.
- `penugasan-sopir-bongkar-batal` *(bukan testid baru, tapi catatan behavior)* — perlu diperbaiki agar navigasi Batal mengikuti REQ-066 (kembali ke Isi Data Tracking bila diakses dari sana), saat ini selalu ke Daftar Penugasan Tracking.

## Ringkasan Harvest 2026-09-20

- Layar/komponen berhasil dipetakan live: **Daftar Penugasan Tracking + Panel Filter (SCR-01), Menu Aksi per baris dengan 4 kombinasi jenis/status berbeda (SCR-02), Tambah Penugasan FTL 2-armada + FCL 1-kontainer (SCR-03), Detail Penugasan FTL + FCL (SCR-04), Riwayat Penugasan panel inline (SCR-05), Riwayat Perubahan (SCR-06), Edit Penugasan FCL (SCR-07), Isi Data Tracking (SCR-08, bonus), Penugasan Sopir Bongkar (SCR-09, bonus)** — total **9 layar/komponen**, 0 di-SKIP dari daftar wajib task.
- Jumlah baris pada Tabel Selector: **~95 baris**.
- Selector stabil (role+name, placeholder, label, text-partial terverifikasi): **~78**.
- Selector TIDAK STABIL/perlu scoping manual (page-size native select, tombol Aksi icon-only via `title`, dropdown menu Aksi tanpa `role=menu`, datepicker id auto-generated, Mode Penugasan/Jadwal Kapal card tanpa role radio): **~10**.
- **17 temuan struktural signifikan** dicatat, termasuk 1 reproduce langsung bug lama (FND-OMS000-RUN-05, Mode Penugasan "Tugaskan ke Sopir" hilang total) dan **1 bug-candidate BARU** (navigasi Batal Penugasan Sopir Bongkar melanggar REQ-066 saat diakses dari Isi Data Tracking).
- **Perbedaan signifikan vs `module-map.md` (2026-09-06)**: menu Aksi baris dulu tercatat KONSISTEN 2 item (Detail + Riwayat Perubahan) untuk SEMUA baris yang diuji; live hari ini menunjukkan menu Aksi sudah berkembang jadi 2–5 item tergantung data order (Edit, Isi Data Tracking, Penugasan Sopir Bongkar kini benar-benar bisa diakses via menu, bukan cuma lewat URL langsung seperti dicatat sebelumnya) — modul ini sudah mengalami perubahan besar sejak eksplorasi terakhir.
