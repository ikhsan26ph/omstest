# Resep alur FTL end-to-end: Buat Order → Tambah Penugasan → Isi Data Tracking

> Hasil eksekusi ad hoc 2026-08-29 (12 order FTL: Normal/Multipickup/Multidrop/Multipoint × 1-3 armada, semua sampai Terkirim). Selector & langkah di bawah TERBUKTI bekerja di sesi Playwright MCP (`browser_run_code_unsafe`, `dispatchEvent('click')`). Log order: `results/_task__ftl-orders__20260829.json`.

# Resep FTL Order → Penugasan → Tracking (terbukti bekerja, 2026-08-29)

Base URL `https://oms-staging.prahu-hub.com`. Login Admin Utama (akun #1 env.md). SEMUA klik pakai
`locator.dispatchEvent('click')` (click biasa tidak bereaksi di sesi ini), fill pakai `.fill()` biasa.
Data uji: Pengirim `PT. Borneo Cinta Damai (IK)` (DP `IK - BPN Platinum`, Balikpapan) → Penerima
`PT. Trimurti Jayandaru (IK)` (DP `IK - Juicy Lucy Sumenep`, Kab. Sumenep). Vendor `PT. Jaya Karsa
(IK)` (master 42 armada, nopol `L 320X IK - CDE`, sopir `Mayora` boleh dipakai berulang tanpa ditolak).
## (a) Wizard Order → "Menunggu Penugasan"
```js
await page.goto(baseUrl + '/order/buat', { waitUntil: 'domcontentloaded' });
await page.getByRole('button', { name: /FTL/ }).first().dispatchEvent('click');
await page.getByRole('button', { name: 'Pilih Jenis Armada' }).dispatchEvent('click');
await page.getByRole('option', { name: 'CDE' }).dispatchEvent('click');
await page.getByPlaceholder('Masukkan Jumlah Armada').fill('N');
await page.getByRole('button', { name: 'Pilih Tipe Pengiriman' }).dispatchEvent('click');
await page.getByRole('option', { name: 'Normal' }).dispatchEvent('click'); // ganti Multipickup/dst
// Pengirim/Penerima SEBELUM Drop Point (wajib urut), lalu PIC/WA SETELAH DP (DP auto-fill PIC/WA)
await page.getByRole('button', { name: 'Semua Pengirim' }).dispatchEvent('click');
await page.getByRole('option', { name: 'PT. Borneo Cinta Damai (IK)' }).dispatchEvent('click');
await page.getByRole('button', { name: 'Pilih Drop Point Asal' }).dispatchEvent('click');
await page.getByRole('option', { name: 'IK - BPN Platinum' }).dispatchEvent('click');
await page.getByRole('button', { name: 'Semua Penerima' }).dispatchEvent('click');
await page.getByRole('option', { name: 'PT. Trimurti Jayandaru (IK)' }).dispatchEvent('click');
await page.getByRole('button', { name: 'Pilih Drop Point Tujuan' }).dispatchEvent('click');
await page.getByRole('option', { name: 'IK - Juicy Lucy Sumenep' }).dispatchEvent('click');
await page.getByPlaceholder('Masukkan PIC Pengirim').fill('AUTOTEST-...'); // + PIC Penerima
const wa = page.getByPlaceholder('Masukkan No. WhatsApp PIC'); // nth(0)=pengirim,nth(1)=penerima
await wa.nth(0).fill('0812...'); await wa.nth(1).fill('0812...');
const catatan = page.getByPlaceholder('Masukkan Catatan'); // isi semua index
for (let i=0;i<await catatan.count();i++) await catatan.nth(i).fill('AUTOTEST-...');
await page.getByRole('button', { name: 'Selanjutnya' }).dispatchEvent('click'); // -> Step 2
```
### Step 2 Data Barang (per blok "Armada N")
JEBAKAN: `getByRole('checkbox')` global index 0..(jumlahArmada-1) = checkbox "Tambahkan Asuransi"
tiap armada (ada di DOM walau modal belum dibuka). Item PERTAMA di modal "Pilih Barang" selalu ada
di index == jumlahArmada. Salah pilih index → tercentang Asuransi tanpa sengaja (klik ulang uncheck).
```js
for (i=0;i<jumlahArmada;i++){
  await page.getByRole('button',{name:'Pilih Barang'}).nth(i).dispatchEvent('click');
  await page.getByRole('checkbox').nth(jumlahArmada).dispatchEvent('click'); // item pertama modal
  await page.getByRole('button',{name:'Tambahkan'}).first().dispatchEvent('click');
  // baca body text utk tahu SKU yg masuk (beda2: IK-APT-001/002/003...), lalu:
  await page.getByRole('textbox',{name:`Jumlah ${skuKode}`}).fill('10');
}
await page.getByRole('button',{name:'Selanjutnya'}).dispatchEvent('click'); // -> Step 3
```
### Step 3 Vendor & Harga
```js
await page.getByRole('button',{name:'Pilih Vendor'}).dispatchEvent('click');
await page.getByRole('option',{name:'PT. Jaya Karsa (IK)'}).dispatchEvent('click');
await page.getByText('DD/MM/YYYY hh:mm').dispatchEvent('click');
const dateCells = page.locator('button.h-9.w-9'); // 43 sel; idx31 = tgl 25 bln berjalan (aman)
await dateCells.nth(31).dispatchEvent('click');
const timeBtns = page.locator('button.tabular-nums'); // 84: idx0-23 JAM, 24-83 MENIT
await timeBtns.nth(10).dispatchEvent('click'); await timeBtns.nth(24).dispatchEvent('click');
await page.getByRole('heading',{name:'Vendor dan Harga'}).first().dispatchEvent('click'); // tutup kalender
await page.getByPlaceholder('0').first().fill(String(1500000*jumlahArmada)); // Harga DPP
await page.getByRole('button',{name:'Selanjutnya'}).dispatchEvent('click'); // -> Step 4
```
`Waktu Perjalanan` rute Balikpapan↔Sumenep sudah ada di Master (read-only "5 Jam"). Checkbox
"Gunakan komponen harga" default ON — biarkan (PPN 11%/PPh 2% otomatis). Rute baru → field jadi
editable + alert kuning, isi manual.
### Step 4 → Simpan
```js
await page.getByRole('button',{name:'Simpan',exact:true}).dispatchEvent('click');
// ~2s -> dialog "Order Berhasil Dibuat" ("Order ORDxxxx telah tersimpan"). Order langsung Menunggu Penugasan.
```
## (b) Tambah Penugasan (multi-armada)
```js
await page.goto(baseUrl + '/penugasan-tracking/tambah', {waitUntil:'domcontentloaded'});
await page.getByPlaceholder('Cari order...').fill(orderId); // huruf kecil!
await page.getByText(orderId).first().dispatchEvent('click');
for (i=0;i<jumlahArmada;i++){
  await page.getByRole('button',{name:'Pilih No. Polisi/Jenis Armada'}).first().dispatchEvent('click');
  await page.getByRole('option',{name:`L 320${5-i} IK - CDE`}).dispatchEvent('click');
  await page.getByRole('button',{name:'Pilih Sopir/No. WhatsApp'}).first().dispatchEvent('click');
  await page.getByRole('option',{name:'Mayora - 6283830011881'}).dispatchEvent('click');
}
await page.getByRole('button',{name:'Simpan'}).first().dispatchEvent('click'); // dialog konfirmasi
await page.getByRole('button',{name:'Simpan'}).last().dispatchEvent('click'); // submit final
```
Hasil: N baris baru (status "Belum Berangkat"), tiap armada = 1 UUID penugasan terpisah. JEBAKAN
CACHE: setelah klik "Kembali" dari halaman tracking, status di list bisa STALE — pakai `page.goto()`
full reload sebelum baca status.
## (c) Isi Data Tracking (PER ARMADA, sampai Selesai)
Tracking berjalan per-penugasan (per baris), bukan per order.
```js
// filter list via getByPlaceholder('Masukkan ID Order') + 'Terapkan' dulu agar row index stabil
await page.locator('button[title="Aksi"]').nth(rowIndex).dispatchEvent('click');
await page.locator('div.fixed.z-9999').getByText('Isi Data Tracking').first().dispatchEvent('click');
// -> section "Selesai Muat" kota asal auto-expanded
await page.getByText('DD/MM/YYYY HH:mm').first().dispatchEvent('click');
await page.locator('button.h-9.w-9').nth(31).dispatchEvent('click');
await page.locator('button.tabular-nums').nth(12).dispatchEvent('click');
await page.locator('button.tabular-nums').nth(24).dispatchEvent('click');
await page.locator('input[type=file]').first().setInputFiles(pngPath); // PNG kecil valid
await page.locator('textarea').last().fill('AUTOTEST-...');
await page.getByRole('button',{name:'Simpan'}).first().dispatchEvent('click');
// -> toast "Event tercatat", kota asal collapse, kota tujuan "Selesai Bongkar" auto-expand; ULANGI blok yg sama utk Bongkar
```
Setelah Bongkar: **"Semua alamat selesai — pengiriman SELESAI."** Baris penugasan → **Selesai**;
status ORDER (`/order`) ikut naik ke **Terkirim** setelah SEMUA penugasan order selesai.
## Jebakan umum
- `locator.click()` biasa tidak bereaksi — selalu `dispatchEvent('click')`.
- Datepicker: grid 42+1 sel, baris 1 = sisa bulan lalu (tgl 26-31) — idx31 selalu = tgl 25 bulan
  berjalan, aman. Time-picker 84 tombol `.tabular-nums` flat (0-23 JAM, 24-83 MENIT).
- Drop Point HARUS diisi SETELAH field company (Pengirim/Penerima) — kebalik → DP reset silent.
- Sopir "Mayora" & nopol vendor "PT. Jaya Karsa (IK)" aman dipakai berulang lintas order/armada.
## Untuk agent Multidrop/Multipoint (Multipickup SUDAH selesai, lihat section di bawah)
- Drop Point tersisa setelah 3 order Multipickup (2026-08-29): **SEMUA 10 DP Borneo(4)+Trimurti(6)
  SUDAH TERPAKAI HABIS** (4 Borneo: BPN Platinum, BPN Market, Ban Jar Mechine Grand Tan, Ban Jar
  Mechine Hotel; 6 Trimurti: Juicy Lucy Sumenep, UMGresik, Slopeng MDR, Gressmall, Kota Lama Surabaya,
  Balai Pemuda). Agent Multidrop/Multipoint PERLU company/DP lain (cek Master Drop Point utk company
  ke-3, atau nego reuse — validasi keunikan DP hanya berlaku PER-ORDER, jadi order BARU boleh pakai DP
  yang sama dengan order lain, tidak lintas-order).
- Label blok Step 1 live: **"Pengirim 1/2/3.."** / **"Penerima 1/2/3.."** (bukan "Pick Up n"). 2 blok
  pertama otomatis muncul saat pilih tipe multi-alamat; "Tambah Baris Input" baru dibutuhkan blok ke-3+.

## Multipickup (FTL, terbukti bekerja 2026-08-29, 3 order: 1/2/3 armada — semua Terkirim)
- Step1: company DULU baru Drop Point tiap blok Pengirim (urutan sama spt Normal). Setelah company
  blok-N dipilih, tombol "Semua Pengirim"/"Pilih Drop Point Asal" blok itu BERGANTI LABEL ke nama
  terpilih → index `.nth()` blok berikutnya SELALU balik ke `nth(0)` (bukan nth(1),nth(2),...), karena
  blok yg sudah terisi hilang dari pool "belum terisi". Sama utk field Penugasan No.Polisi/Sopir.
- Step2 Data Barang: tiap Armada N berisi sub-section **"Pick Up 1..K"** (K = jumlah blok Pengirim),
  masing2 dgn tombol "Pilih Barang" SENDIRI (total tombol = jumlahArmada × K). Checkbox "Tambahkan
  Asuransi" tetap 1 per ARMADA (bukan per pickup) — index checkbox global 0..(jumlahArmada-1) spt
  Normal. Item pertama modal = `checkbox.nth(jumlahArmada)` (jebakan sama persis Normal) — TAPI di
  order 3-armada, 2 modal PERTAMA yang dibuka di halaman sempat salah pilih (item ke-2 bukan ke-1),
  diduga race-condition render list saat modal baru pertama kali mount; item alternatif yg terklik
  tetap valid, cukup fill `Jumlah <SKU-apa pun yg muncul>` — jangan hardcode nama SKU, selalu baca SKU
  aktual dari DOM/textbox name setelah klik "Tambahkan". Beri jeda ~600ms setelah klik "Pilih Barang"
  sebelum klik checkbox utk kurangi race ini.
- Step3 Vendor&Harga: kalau rute (kombinasi SEMUA DP asal+tujuan) baru → field **Waktu Perjalanan
  ikut jadi input editable dan muncul SEBELUM Harga DPP** dalam urutan DOM `getByPlaceholder('0')` →
  index bergeser: `.nth(0)`=Waktu Perjalanan, `.nth(1)`=Harga DPP (BUKAN `.first()`=Harga spt asumsi
  resep Normal). Selalu cek jumlah match `getByPlaceholder('0')` (4 jika rute baru, 3 jika rute lama)
  sebelum fill, jangan asumsi `.first()`.
- Penugasan (Tambah Penugasan) utk >1 armada: dropdown "Pilih No. Polisi/Jenis Armada" **TIDAK
  memfilter nopol yg sudah dipakai armada lain dalam order yg sama** → bisa ke-assign nopol duplikat
  antar-armada tanpa error/validasi (dicek ulang manual: baca body text tiap armada, pastikan nopol
  beda-beda sebelum klik Simpan). Kandidat bug-candidate, belum ada REQ yg dicek eksplisit.
- Tracking: jumlah "penugasan" (baris terpisah) = jumlah armada (spt Normal multi-armada). PER baris,
  jumlah event "Selesai Muat" = jumlah blok Pengirim (K), lalu 1x "Selesai Bongkar" di tujuan — total
  event = K+1. Kalau 2 blok Pengirim SATU KOTA yg sama (mis. order 1-armada: Borneo DP-A & DP-B
  sama2 Kota Balikpapan): UI grup per-kota, counter "X/Y alamat selesai" (mis. "0/2"→"1/2"→"2/2"),
  form berikutnya AUTO-EXPAND sendiri setelah Simpan tiap alamat — tidak perlu buka dropdown "Pilih
  Alamat" manual. Kalau beda kota, tiap kota py section terpisah "Kota X - Saat ini - 0/1", juga
  auto-advance. Loop generik (isi tanggal+foto+catatan+Simpan, ulangi sampai body mengandung "Semua
  alamat selesai") terbukti reliable utk K+1 putaran tanpa perlu tahu struktur kota persis di awal.

## Multidrop (FTL, terbukti bekerja 2026-08-29, 3 order: 1/2/3 armada — semua Terkirim)
- Kebalikan Multipickup: 1 blok **Pengirim** (bukan multi) + N blok **Penerima** ("Penerima 1/2..").
  2 blok Penerima pertama otomatis muncul saat pilih Tipe Pengiriman=Multidrop; "Tambah Baris Input"
  utk blok ke-3+ (klik sekali per blok tambahan). Urutan isi field, pool `.nth(0)` reset per blok
  terisi, dan validasi keunikan DP GLOBAL per-order — SAMA PERSIS spt Multipickup, tinggal tukar
  peran Pengirim<->Penerima.
- Step2 Data Barang: sub-section per Penerima diberi label **"Drop Off 1..N"** (bukan "Pick Up").
  Tiap Armada x tiap Drop Off = 1 tombol "Pilih Barang" sendiri (total = jumlahArmada x N). Checkbox
  "Tambahkan Asuransi" tetap 1 per ARMADA (index 0..jumlahArmada-1, sama jebakan `checkbox.nth
  (jumlahArmada)` = item pertama modal). Jeda 600-650ms setelah klik "Pilih Barang" sblm klik
  checkbox terbukti CUKUP menghindari race-condition modal (order 3-armada/9 tombol semua tepat
  sasaran tanpa perlu retry, beda dari Multipickup yg sempat salah 2x).
- Step3 Vendor&Harga: identik Multipickup — cek jumlah `getByPlaceholder('0')` (4 kalau rute baru:
  nth(0)=Waktu Perjalanan, nth(1)=Harga DPP; 3 kalau rute sudah ada di master: nth(0)=Harga DPP
  langsung, Waktu tampil read-only). Rute Multidrop dibaca sbg "Asal -> Tujuan1 -> Tujuan2..", jadi
  rute BARU utk arah A->B bisa jadi SUDAH ADA kalau order lain pernah pakai arah B->A dgn kota yg
  sama (Banjarmasin->Gresik->Surabaya lgsg read-only 7 Jam krn dipakai Multipickup order3 sebelumnya).
- Penugasan & Tracking: identik Normal/Multipickup multi-armada — 1 penugasan (baris) per armada,
  nopol dropdown TIDAK memfilter duplikat dlm 1 order (verifikasi manual per armada spt biasa).
  Tracking PER ARMADA: 1x Selesai Muat (asal) + 1x Selesai Bongkar PER KOTA TUJUAN UNIK (kalau 2+ DP
  Penerima satu kota yg sama, digrup jadi 1 section "Kota X - N/N alamat selesai", counter naik tiap
  Simpan, auto-advance ke DP berikutnya tanpa pilih ulang dropdown — sama persis mekanisme Multipickup
  tapi arahnya di sisi Bongkar bukan Muat). Loop generik (isi tanggal+foto+catatan+Simpan sampai body
  mengandung "Semua alamat selesai") reliable, jumlah putaran = 1 + (jumlah kota tujuan unik).

## Multipoint (FTL, terbukti bekerja 2026-08-29, 3 order: 1/2/3 armada — semua Terkirim)
- Gabungan Multipickup+Multidrop: N blok **Pengirim** DAN M blok **Penerima** SEKALIGUS, keduanya
  "Pengirim 1/2.." / "Penerima 1/2.." muncul otomatis (2 blok tiap sisi), "Tambah Baris Input" per
  sisi utk blok ke-3+ (dipanggil 2x independen kalau butuh 3 blok di KEDUA sisi — index tombol
  "Tambah Baris Input".nth(0)=sisi Pengirim, setelah diklik query ulang & pakai `.last()` utk sisi
  Penerima krn DOM berubah). Urutan isi field & pool `.nth(0)` reset per blok terisi sama persis
  Multipickup/Multidrop. Keunikan DP GLOBAL per-order tetap berlaku (semua N+M DP harus unik).
- **List `/order` menampilkan tipe Multipoint sbg 2 badge terpisah "Multipickup"+"Multidrop"** (bukan
  teks "Multipoint"), begitu juga panel Step3 "Drop Point Asal: Multipickup" / "Drop Point Tujuan:
  Multidrop" — kosmetik saja, field `tipePengiriman` di response API tetap benar "MULTIPOINT".
- Step2 Data Barang: **MATRIX Pick Up x Drop Off** — beda dari Multipickup(K section)/Multidrop(N
  section) yg linear, Multipoint py K x N section per ARMADA (label "Pick Up i - alamat / Drop Off j -
  alamat"), field `pickupPartyIdx`/`dropOffPartyIdx` di payload API mengonfirmasi tiap kombinasi
  tersimpan independen. Total tombol Pilih Barang = jumlahArmada x K x N (order 3 armada/3P/3P = 27
  tombol!). Checkbox "Tambahkan Asuransi" tetap 1 per ARMADA (index 0..jumlahArmada-1, item pertama
  modal = checkbox.nth(jumlahArmada), sama persis semua tipe lain). Jeda 650ms aman, 0 race-condition
  di ketiga order (termasuk yg 27 tombol).
- Step3 Vendor&Harga: identik tipe lain, cek jumlah getByPlaceholder('0') (4 kalau rute baru:
  nth(0)=Waktu, nth(1)=Harga; 3 kalau existing). Rute Multipoint dibaca sbg rangkaian SEMUA kota Asal
  lalu SEMUA kota Tujuan berurutan blok.
- Penugasan: identik multi-armada tipe lain (1 penugasan/baris per armada, nopol dropdown TIDAK
  memfilter duplikat, verifikasi manual).
- **JEBAKAN SERIUS — race UI vs API di Step4 Simpan**: klik Simpan pertama BISA sukses (POST
  /api/order 201) TAPI UI tetap diam di halaman Review tanpa dialog "Order Berhasil Dibuat"/redirect
  dlm ~2,5 detik — kalau ikut pola lama "tunggu dialog lalu klik lagi jika belum muncul", risiko klik
  Simpan KEDUA yang JUGA sukses → **order duplikat** (2x POST 201, data identik). Terjadi 1x di order
  1-armada (duplikat ORD7997900707, tidak bisa dibatalkan krn "Batalkan Order" diblokir classifier
  auto-mode Claude Code "Blocked by classifier" — beda dari kasus lain, ini bukan larangan aplikasi
  tapi guardrail harness). WAJIB utk order berikutnya: setelah klik Simpan Step4, pasang listener
  page.on('response', ...) filter /api/order method POST, baca resp.json() utk ambil
  data.orderCode/data.status langsung dari network layer — JANGAN klik Simpan kedua kalinya hanya
  krn UI belum berubah. Order 2 & 3 pakai pola ini, 0 duplikat.
- Tracking: gabungan mekanisme Multipickup(sisi Muat)+Multidrop(sisi Bongkar) — kota yg sama antar
  BEBERAPA Pengirim atau BEBERAPA Penerima digrup 1 section "Kota X - N/N", kota beda masing2 section
  sendiri; jumlah event per armada = (jumlah kota asal unik) + (jumlah kota tujuan unik). Loop generik
  (tanggal+foto+catatan+Simpan sampai "Semua alamat selesai") reliable di ketiga order (4/8/18 event
  total). Order 3-armada (3P x 3P, 6 DP, 2 kota digrup tiap sisi) = order FTL paling kompleks di
  seluruh task, selesai tanpa error selain jebakan duplikat di atas.
