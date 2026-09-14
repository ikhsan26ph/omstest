# Eksplorasi OMS000 Jenis Produk
Eksplorasi oms000-jenis-produk — 2026-09-07 12:18 WIB (run 1, blocked) + 13:05 WIB (run 2, sukses)

## Run 2 (13:05 WIB) — sukses, read-only, via Playwright lokal headless

Root cause run 1: bukan masalah aplikasi/kredensial — script eksplorasi custom (`artifacts/oms000-current/explore.cjs`) gagal pada `page.waitForURL`, kemungkinan pola tunggu yang tidak cocok. Bukti: modul lain (`tests/*.spec.js` via `scripts/run-playwright.sh`) berhasil login dengan akun yang sama di hari yang sama (run `oms000-jenis-produk__20260907-115730.json`, 174 skenario dieksekusi). Run 2 memakai helper `artifacts/explore-scripts/lib.js` (pola login terbukti, dipakai berulang kali untuk modul Order) → **login sukses first-try** untuk akun Admin maupun Vendor. Script: `artifacts/explore-scripts/probe-oms000-entitlement.js`.

**Entitlement aktif saat eksplorasi** (`GET /api/system/status`, dibaca dari response network saat load `/monitoring`, read-only):
```
products: ["OMS"]        (TMS TIDAK aktif)
addOns:   AUTO_STUFFING, SERVICE_FTL, SERVICE_LTL, SERVICE_LCL, SERVICE_AIR_FREIGHT, SERVICE_FCL
productSource: core, addOnSource: core
```
Nilai ini identik dengan hasil pemulihan run test-module API `20260907-115730` (products [OMS], 6 add-on) — **tidak ada bukti langsung state entitlement "asli" sebelum run API hari ini** (snapshot tertua yang tercatat sudah dari run 1, setelah pemulihan).

### Verifikasi live menu Admin vs matriks R3/R5 (`oms000-jenis-produk.analysis.md`) untuk state **OMS-only**

| Item | Prediksi spec (OMS-only) | Observasi live 2026-09-07 | Match? |
|---|---|---|---|
| Dashboard ▸ Tracking & Location (`/tracking-location`) | **Hilang** (TMS-only, REQ-031) | **Tidak ada di sidebar** — satu-satunya route yang hilang dari baseline 26 route lama (`explore/module-map.md` baris #3) | ✅ Sesuai spec |
| Dashboard ▸ Distribusi & Muatan (`/dashboard-distribusi`) | Tampil (OMS-only, REQ-034) | Ada | ✅ |
| Simulasi Muatan (`/simulasi-muatan`) | Tampil (OMS + AUTO_STUFFING, REQ-036) | Ada | ✅ |
| Master Barang (`/master/barang`) | Tampil (OMS-only, REQ-039) | Ada | ✅ |
| Master Pelabuhan/Pelayaran | Tampil (moda laut aktif via SERVICE_FCL/LCL, REQ-041/042/070/071) | Ada | ✅ |
| `/setting/sistem` isi accordion | **Tepat 2 item**: Durasi Kedaluwarsa Undangan Vendor + Nomor WhatsApp CS (REQ-068, OMS-only) | **Tepat 2 item** (dikonfirmasi dari heading terekstrak, setelah dikurangi "Kuota Order"/judul halaman) | ✅ Sesuai spec |

**Catatan penting**: `explore/module-map.md` baris #24 (update 2026-09-05 siang) mencatat **8 accordion** tampil di `/setting/sistem` — kontras dengan REQ-068 (OMS-only harus 2 item) dan kontras dengan observasi hari ini (2 item). Tidak bisa disimpulkan mana yang "benar" tanpa tahu apakah entitlement tenant staging berubah antara 09-05 dan 09-07 (mis. TMS pernah aktif lalu dicabut) atau apakah filtering ini baru diimplementasikan setelah 09-05. **Rekomendasi**: sebelum eksekusi skenario OMS000-POS-043/044/045/046 (REQ-058…068), konfirmasi riwayat perubahan entitlement tenant testing ke tim backend/PO — jangan asumsikan 8-item lama sebagai baseline valid.

### Sidebar Admin lengkap (25 route, turun dari 26 baseline lama — persis minus Tracking & Location)
Monitoring, Operasional, Distribusi & Muatan, Order, Penugasan Tracking, Simulasi Muatan, Master Provinsi/Kota/Kecamatan/Kelurahan, Master Drop Point, Master Waktu Perjalanan, Master Pelabuhan, Master Pelayaran, Master Barang, Master Kemasan, Master Unit, Master Sopir, Master CS, Manajemen Vendor, Pengaturan Akun, Akun Saya, Pengaturan Sistem, Pengaturan Notifikasi, Preferensi Notifikasi.

### Step 1 Buat Order — kartu Jenis Pengiriman
Hanya **FTL, FCL, LTL, LCL** terdeteksi di body text `/order/buat` — **tidak ada kartu "Air Freight"** meski `SERVICE_AIR_FREIGHT` aktif di entitlement. Konsisten dengan SELURUH eksplorasi Order sebelumnya (oms012-015, tidak pernah ada kartu ke-5). Kemungkinan besar Air Freight sebagai jenis order OMS **belum diimplementasikan di UI** (beda dari fitur "moda Udara" pada TMS LKL/R7 yang memang skema terpisah) — bukan temuan baru, tapi relevan untuk REQ-077 (INF/ASM-16): rekomendasikan NEED RECHECK, jangan langsung tandai bug tanpa konfirmasi apakah Air Freight order-type memang direncanakan utk kanal OMS.

### Vendor — login & sidebar (akun `pengirim.ph2021@gmail.com`)
Login sukses first-try. **Landing route berbeda dari Admin**: `/vendor-portal/order` (bukan `/monitoring`) — info baru, belum tercatat di `explore/module-map.md` (yang hanya mendokumentasikan redirect Admin ke `/monitoring`).

Sidebar Vendor — **tepat 6 item** (cocok REQ-050, identik apa pun produk aktif):
| Menu | Route |
|---|---|
| Order | `/vendor-portal/order` |
| Penugasan Tracking | `/penugasan-tracking` |
| Master Armada | `/vendor-portal/master/armada` |
| Master Sopir | `/vendor-portal/master/sopir` |
| Akun Saya | `/vendor-portal/akun-saya` |
| Pusat Notifikasi | `/vendor-portal/setting/preferensi-notifikasi` |

Label di UI sedikit berbeda dari nama sheet `VD` (mis. "Master Armada" vs "Master Operasional - Master Armada") — bukan masalah, hanya perbedaan label vs nama dokumen sumber.

### Kesimpulan run 2
- Login (Admin & Vendor) **tidak bermasalah** — kegagalan run 1 murni isu script eksplorasi, bukan aplikasi/kredensial. Tidak ada indikasi lockout.
- Filtering entitlement untuk state **OMS-only** hari ini **sesuai spec** pada 3 titik kritis yang diuji (Tracking & Location hilang, Pengaturan Sistem 2 item, Vendor 6 item identik) — ini bertentangan dengan catatan lama `module-map.md` soal Pengaturan Sistem (8 item), perlu klarifikasi riwayat entitlement sebelum eksekusi skenario terkait.
- Tidak ada PATCH/perubahan data. Read-only murni (GET `/api/system/status` via network listener + navigasi).

Screenshot baru: `artifacts/screenshots/explore/oms000-admin-sidebar-full.png`, `oms000-admin-setting-sistem.png`, `oms000-admin-order-step1.png`, `oms000-vendor-sidebar-full.png`. Script: `artifacts/explore-scripts/probe-oms000-entitlement.js` (reusable untuk re-check entitlement kapan pun).

---

## Run 1 (12:18 WIB) — blocked pada login (root cause sudah ditemukan di run 2, lihat di atas)

Status: **blocked pada login; peta navigasi internal belum diverifikasi ulang**. Eksplorasi read-only pada state yang sedang aktif, tanpa PATCH entitlement atau perubahan data.

| # | Modul | Route | Jenis Halaman | Aksi Utama | Ada Dokumen Skenario? | Catatan |
|---|---|---|---|---|---|---|
| OMS000-1 | Login OMS | /login | Form autentikasi | Login, Lupa Password? | Ya — oms000-jenis-produk | Heading Selamat Datang; input Masukkan Email dan Masukkan Password terlihat dan enabled pada diagnosis read-only |
| OMS000-2 | Status produk dan add-on | API: /api/system/status pada apioms-staging.prahu-hub.com | JSON konfigurasi frontend | GET read-only | Ya — oms000-jenis-produk | products=[OMS]; addOns=AUTO_STUFFING, SERVICE_FTL, SERVICE_LTL, SERVICE_LCL, SERVICE_AIR_FREIGHT, SERVICE_FCL; productSource=core, addOnSource=core |

Percobaan akun Admin Utama dan Vendor masing-masing timeout menunggu navigasi setelah klik Login. Belum ada bukti penolakan kredensial: daftar respons JSON yang tercatat hanya setting/site, system/status, auth/refresh; tidak ada respons login yang tertangkap. Masalah timing/hydration pada executor masih mungkin. Dua percobaan dihentikan mengikuti batas login panduan; tidak menyimpulkan akun terkunci atau akses produk ditolak.

Belum terpetakan ulang (saat run 1; sebagian sudah terisi run 2 di atas): matriks menu Shipper/Vendor, state TMS dan gabungan, Pengaturan Sistem, opsi Sopir/Pengurus, form order per add-on, varian TMS LKL. Peta modul dari eksplorasi sebelumnya tetap merupakan data historis. Tidak ada verdict test-module baru.

Screenshot: `artifacts/screenshots/explore/oms000-jenis-produk-login-20260907.png`. Bukti terstruktur: `artifacts/oms000-current/explore-2026-09-07T05-18-12-400Z/map.json`; diagnosis login: `artifacts/oms000-current/explore-2026-09-07T05-18-12-400Z/login-diagnosis.json`.
