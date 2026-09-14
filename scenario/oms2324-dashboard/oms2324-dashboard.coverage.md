# Coverage - oms2324-dashboard

## Ringkasan

| Kategori | Jumlah |
|---|---:|
| positive | 8 |
| negative | 8 |
| edge | 4 |
| stress | 4 |
| total | 24 |

## Requirements Traceability Matrix

| REQ | Deskripsi | Scenario IDs |
|---|---|---|
| REQ-001 | Score card Monitoring: Total Armada dan Melewati SLA | OMS2324-DASHBOARD-POS-001, OMS2324-DASHBOARD-NEG-001 |
| REQ-002 | Daftar Armada Berjalan per nopol | OMS2324-DASHBOARD-POS-002, OMS2324-DASHBOARD-NEG-002 |
| REQ-003 | Filter status daftar armada berjalan | OMS2324-DASHBOARD-POS-003, OMS2324-DASHBOARD-NEG-003, OMS2324-DASHBOARD-EDG-001 |
| REQ-004 | Search dan muat ulang daftar armada | OMS2324-DASHBOARD-POS-004, OMS2324-DASHBOARD-NEG-004, OMS2324-DASHBOARD-STR-001 |
| REQ-005 | Aksi Detail menuju detail penugasan | OMS2324-DASHBOARD-POS-005, OMS2324-DASHBOARD-NEG-005 |
| REQ-006 | Filter periode dan export PDF Dashboard Distribusi & Muatan | OMS2324-DASHBOARD-POS-006, OMS2324-DASHBOARD-NEG-006, OMS2324-DASHBOARD-EDG-002, OMS2324-DASHBOARD-STR-002 |
| REQ-007 | Jangkauan Distribusi dan peta choropleth | OMS2324-DASHBOARD-POS-007, OMS2324-DASHBOARD-NEG-007, OMS2324-DASHBOARD-EDG-003, OMS2324-DASHBOARD-STR-003 |
| REQ-008 | Utilitas Armada, Profil Barang Terkirim, dan Tingkat Keterisian Armada | OMS2324-DASHBOARD-POS-008, OMS2324-DASHBOARD-NEG-008, OMS2324-DASHBOARD-EDG-004, OMS2324-DASHBOARD-STR-004 |

## Validasi Coverage

| Pemeriksaan | Hasil |
|---|---|
| Tiap REQ memiliki minimal 1 positive | Lulus |
| Tiap REQ memiliki minimal 1 negative | Lulus |
| Edge scenario tersedia | Lulus, 4 scenario |
| Stress scenario tersedia | Lulus, 4 scenario |
| Layar Monitoring ter-cover | Lulus |
| Layar Distribusi & Muatan ter-cover | Lulus |
| Elemen UI penting tersentuh | Lulus: score card, filter chip, search, refresh, detail, date range, export, peta, dropdown peta, chart profil barang, progress keterisian, pagination/state kosong tercakup |
| Order valid dan order batal | Lulus melalui REQ-006/REQ-007 |

## Validasi Gherkin & JSON

- Semua scenario di `.feature` memiliki tag kategori, priority, REQ, dan screen.
- Semua ID scenario di `.feature` memiliki padanan di `.scenarios.json`.
- `summary.total` JSON = 24 dan sama dengan jumlah scenario aktual.
- Distribusi kategori JSON sama dengan jumlah tag Gherkin: positive 8, negative 8, edge 4, stress 4.
- `category`, `requirement`, dan `screen` pada JSON konsisten dengan tag Gherkin.
- Pola Given/When/Then konsisten dan mudah diterjemahkan ke Playwright.

## Dedup

Tidak ada scenario duplikat yang dibuang. Scenario yang mirip tetap dipertahankan karena memverifikasi requirement berbeda, misalnya filter status Monitoring berbeda dari search/refresh, dan peta provinsi berbeda dari peta kota/zoom.

## Gap

Tidak ada gap signifikan berdasarkan spec dan desain yang tersedia.

## Rekomendasi Tambahan

- Saat implementasi Playwright, tambahkan fixture data eksplisit untuk status order: ditugaskan, belum ditugaskan, dibatalkan, selesai muat, selesai bongkar, melewati SLA, dan belum ada pencatatan H-1.
- Untuk validasi visual peta, gunakan assertion berbasis label/legend dan data layer bila tersedia, bukan hanya screenshot.
