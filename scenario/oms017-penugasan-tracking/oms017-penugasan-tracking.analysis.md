# Analysis — OMS017 Penugasan Tracking

Modul: **OMS017 — Penugasan Tracking**
Sumber spesifikasi: `inputs/oms017-penugasan-tracking/spec.txt`
Tanggal analisis: 2026-08-28

Ruang lingkup modul: pengelolaan penugasan armada/sopir terhadap order (FTL, LTL, FCL, LCL) beserta pengisian data tracking (Selesai Muat / Selesai Bongkar), edit penugasan, detail penugasan, dan riwayat perubahan.

---

## Requirements

### A. Hak Akses & Aktor

| ID | Requirement | Deskripsi | Role | Aturan / Kondisi | Acceptance Criteria |
|---|---|---|---|---|---|
| REQ-001 | Akses penuh Shipper (mengelola vendor) | Jika terdapat vendor yang dikelola oleh Shipper (sebagai admin vendor tersebut), maka menu Penugasan Tracking untuk order yang ditujukan ke vendor tersebut dapat dijalankan oleh Shipper dengan hak akses penuh. | Shipper (admin vendor) | Berlaku hanya untuk order yang vendornya dikelola Shipper. Contoh: Vendor JNE dikelola Shipper → semua order ke JNE dapat dikelola penuh oleh Shipper. | Login sebagai Shipper pengelola vendor X → pada order bervendor X, seluruh aksi (Tambah Penugasan, Edit, Isi Data Tracking, Detail, Riwayat Perubahan) tersedia dan dapat dieksekusi. |
| REQ-002 | Akses terbatas Shipper (tidak mengelola vendor) | Jika tidak ada vendor yang dikelola oleh Shipper, akses Shipper pada menu Penugasan Tracking hanya **lihat detail** (read-only). | Shipper (non-pengelola vendor) | Aksi Tambah Penugasan, Edit, dan Isi Data Tracking tidak dapat dijalankan. | Login sebagai Shipper tanpa vendor kelolaan → hanya aksi Detail yang tersedia/aktif; aksi ubah data tidak tersedia. |
| REQ-003 | Akses penuh Vendor | Pada akun Vendor, user memiliki akses penuh pada Penugasan Tracking. | Vendor | Berlaku untuk order milik vendor yang bersangkutan. | Login sebagai Vendor → seluruh aksi pada modul Penugasan Tracking tersedia dan dapat dieksekusi. |

### B. Halaman Daftar Penugasan Tracking

| ID | Requirement | Deskripsi | Aturan Validasi / Kondisi | Acceptance Criteria |
|---|---|---|---|---|
| REQ-004 | Paginasi daftar | Data pada tabel Penugasan Tracking ditampilkan default 20 baris per halaman dan tersedia pagination. | Default page size = 20. | Saat halaman dibuka, maksimal 20 baris tampil; kontrol pagination tersedia dan berfungsi pindah halaman. |
| REQ-005 | Urutan data | Urutan data pada tabel adalah terbaru di posisi teratas. | Sort default: data terbaru → terlama. | Baris pertama tabel adalah penugasan/entri terbaru. |
| REQ-006 | Kolom tabel | Tabel menampilkan kolom: (a) ID Order + Jenis Shipment, (b) Rute (Kota Asal – Kota Tujuan), (c) Nopol/No. Kontainer + Sopir, (d) Status. | Kolom Status menampilkan salah satu nilai status penugasan (lihat REQ-016). | Seluruh 4 kolom tampil dengan data yang sesuai order terkait. |
| REQ-007 | Action menu | Setiap baris memiliki action menu: Detail, Edit, Isi Data Tracking, Riwayat Perubahan. | Ketersediaan aksi tunduk pada hak akses (REQ-001 s.d. REQ-003) dan aturan editability (REQ-060 s.d. REQ-062). | Membuka action menu pada satu baris menampilkan 4 opsi tersebut dan tiap opsi mengarah ke halaman/pop-up yang benar. |
| REQ-008 | Tombol Tambah Penugasan | Tersedia tombol "Tambah Penugasan" pada halaman Penugasan Tracking yang mengarahkan ke halaman "Tambah Penugasan". | Hanya untuk role dengan akses penuh (REQ-001, REQ-003). | Klik "Tambah Penugasan" → user diarahkan ke halaman Tambah Penugasan. |

### C. Filter Daftar Penugasan Tracking

| ID | Requirement | Field / Deskripsi | Tipe Input | Aturan Validasi | Acceptance Criteria |
|---|---|---|---|---|---|
| REQ-009 | Filter ID Order | Filter data berdasarkan ID Order. | Text field | Opsional; default kosong dengan placeholder. | Mengisi ID Order + Terapkan → tabel hanya menampilkan order dengan ID yang cocok. |
| REQ-010 | Filter Jenis Shipment | Filter data berdasarkan jenis shipment. | Text field | Opsional; default kosong dengan placeholder. | Mengisi Jenis Shipment + Terapkan → tabel terfilter sesuai jenis shipment. |
| REQ-011 | Filter Kota Asal | Filter data berdasarkan Kota Asal. | Dropdown (sumber: data master kota) | Opsional; opsi berasal dari master. | Opsi dropdown berasal dari master kota; pilih nilai + Terapkan → tabel terfilter. |
| REQ-012 | Filter Kota Tujuan | Filter data berdasarkan Kota Tujuan. | Dropdown (sumber: data master kota) | Opsional; opsi berasal dari master. | Opsi dropdown berasal dari master kota; pilih nilai + Terapkan → tabel terfilter. |
| REQ-013 | Filter Nopol/No. Kontainer | Filter data berdasarkan Nomor Polisi atau Nomor Kontainer. | Text field | Opsional; default kosong dengan placeholder. | Mengisi nilai + Terapkan → tabel terfilter sesuai nopol/no. kontainer. |
| REQ-014 | Filter Sopir | Filter data berdasarkan nama Sopir. | Text field | Opsional; default kosong dengan placeholder. | Mengisi nama sopir + Terapkan → tabel terfilter. |
| REQ-015 | Filter Tahap Pengiriman | Filter menampilkan order yang **sudah** melakukan update tahap pengiriman tertentu, terlepas dari status terkini. Contoh: ID Order 123 sudah update "Selesai Muat" sehingga statusnya "Dalam Perjalanan"; saat difilter Tahap Pengiriman = "Selesai Muat", order 123 tetap tampil. Berlaku juga untuk skenario multi pick-up. | Dropdown | Opsional. Logika berbasis riwayat tahap yang pernah tercapai (bukan status terkini). | Filter Tahap Pengiriman = "Selesai Muat" → seluruh order yang pernah update Selesai Muat tampil, termasuk yang statusnya sudah berubah menjadi Dalam Perjalanan/Selesai. |
| REQ-016 | Filter Status | Filter data berdasarkan Status penugasan. | Dropdown | Opsional; nilai sesuai daftar status (REQ-017). | Pilih status + Terapkan → tabel hanya menampilkan penugasan berstatus tersebut. |
| REQ-017 | Default filter kosong | Seluruh field filter default kosong dan menampilkan placeholder. | — | Tidak ada nilai preselected. | Saat halaman pertama dibuka, semua field filter kosong dan placeholder terlihat. |
| REQ-018 | Tombol Reset filter | Tombol "Reset" menghapus seluruh isi kolom filter dan mereset tabel ke data default. | — | Reset mengembalikan tabel ke urutan & paging default (REQ-004, REQ-005). | Setelah filter diterapkan, klik Reset → semua field filter kosong dan tabel kembali menampilkan data default. |
| REQ-019 | Tombol Terapkan filter | Tombol "Terapkan" menampilkan data sesuai kombinasi kolom filter yang diisi. | — | Field kosong diabaikan (tidak menjadi kriteria). Multi-field bersifat AND. | Mengisi >1 filter lalu Terapkan → tabel menampilkan data yang memenuhi seluruh kriteria terisi. |

### D. Status Penugasan

| ID | Requirement | Deskripsi | Aturan Transisi | Acceptance Criteria |
|---|---|---|---|---|
| REQ-020 | Status "Belum Berangkat" | Order sudah ditugaskan namun belum ada update status muat. | State awal setelah penugasan tersimpan. | Setelah Tambah Penugasan berhasil, status penugasan = "Belum Berangkat". |
| REQ-021 | Status "Dalam Perjalanan" | Penugasan telah melakukan update status muat (Selesai Muat). | Transisi: Belum Berangkat → Dalam Perjalanan saat data Selesai Muat tersimpan. | Menyimpan data tracking Selesai Muat → status berubah menjadi "Dalam Perjalanan" di daftar & detail. |
| REQ-022 | Status "Selesai" | Penugasan telah melakukan update status bongkar; menandakan order selesai. | Transisi: Dalam Perjalanan → Selesai saat data Selesai Bongkar tersimpan (seluruh tahap/kota selesai). | Menyimpan data tracking Selesai Bongkar terakhir → status berubah menjadi "Selesai". |

### E. Tambah Penugasan — Ketentuan Umum

| ID | Requirement | Deskripsi | Aturan Validasi | Acceptance Criteria |
|---|---|---|---|---|
| REQ-023 | Pemilihan order | User wajib memilih order yang akan ditugaskan pada bagian "Pilih Order". | Wajib; harus memilih sebelum dapat menyimpan. | Tanpa memilih order, proses penyimpanan tidak dapat dilanjutkan. |
| REQ-024 | Hanya order belum ditugaskan | Pada bagian "Pilih Order" hanya ditampilkan order yang belum memiliki penugasan. | Order yang sudah ditugaskan tidak muncul di daftar. | Order yang sudah punya penugasan tidak tampil pada daftar/search "Pilih Order". |
| REQ-025 | Search bar order | Tersedia search bar untuk mencari order berdasarkan ID Order dan Kota. | Pencarian mendukung 2 kriteria: ID dan kota. | Mengetik ID order atau nama kota → daftar order terfilter sesuai kata kunci. |
| REQ-026 | Single selection | Hanya dapat memilih 1 order per penugasan. | Selection = single (bukan multi-select). | Memilih order kedua akan menggantikan pilihan pertama / tidak diizinkan memilih lebih dari 1. |
| REQ-027 | Auto-draft data order | Setelah memilih order, field Kota Asal, Kota Tujuan, Jenis Armada, dan Jumlah Armada otomatis ter-draft dari data order dan bersifat **read-only**. | Read-only; nilai bersumber dari data order. | Setelah order dipilih, keempat field terisi otomatis dan tidak dapat diedit user. |
| REQ-028 | Prefix wilayah | Kota Asal & Kota Tujuan hasil draft harus menyertakan prefix "Kota" atau "Kab.". | Format wajib: `Kota <Nama>` atau `Kab. <Nama>`. | Nilai draft tampil misalnya "Kota Surabaya" / "Kab. Bekasi", bukan "Surabaya"/"Bekasi". |
| REQ-029 | Jumlah card armada/kontainer | Jumlah card input Armada/Kontainer mengikuti Jumlah Armada/Kontainer pada order yang dipilih. | Jumlah card = jumlah armada/kontainer pada order. | Order dengan 3 armada → tampil 3 card input; order dengan 1 armada → 1 card. |
| REQ-030 | Card tunggal untuk LTL/LCL | Untuk jenis shipment LTL/LCL, jumlah card selalu 1. | Override terhadap REQ-029 untuk LTL/LCL. | Memilih order LTL atau LCL → hanya 1 card input yang tampil apapun jumlah armada. |
| REQ-031 | Metode pengisian: Pilih Dari Master | Untuk field No. Polisi/Jenis Armada dan Sopir tersedia metode "Pilih Dari Master" berupa dropdown yang mengambil data master. | Nilai harus berasal dari data master. | Memilih metode "Pilih Dari Master" → tampil dropdown berisi data master armada/sopir. |
| REQ-032 | Metode pengisian: Isi Data Manual | Tersedia metode "Isi Data Manual" berupa text field yang diisi manual oleh user. | Untuk Sopir manual, field **No. WhatsApp bersifat opsional** (tidak wajib). | Memilih "Isi Data Manual" → tampil text field; menyimpan tanpa mengisi No. WhatsApp sopir manual tetap berhasil. |
| REQ-033 | Filter armada dari master | Saat memilih armada dari master, armada yang tampil hanya yang sesuai dengan jenis armada yang dipesan pada order. | Dropdown master armada difilter berdasarkan jenis armada order. | Order memesan armada jenis X → dropdown master hanya menampilkan armada jenis X. |
| REQ-034 | Validasi field required | Jika field required tidak diisi, tampilkan helper error dan border field berubah menjadi warna error. | Trigger saat submit/validasi. | Klik Simpan dengan field required kosong → helper error muncul di bawah field dan border field berwarna error; data tidak tersimpan. |
| REQ-035 | Tombol Batal | Tombol "Batal" membatalkan proses tambah penugasan dan menampilkan alert konfirmasi terlebih dahulu. | Konfirmasi wajib sebelum keluar. | Klik Batal → muncul alert konfirmasi; konfirmasi ya → proses dibatalkan, data tidak tersimpan. |
| REQ-036 | Tombol Simpan | Tombol "Simpan" menyimpan data penugasan dengan konfirmasi, lalu menampilkan notifikasi data tersimpan. | Validasi seluruh field required lolos sebelum simpan. | Klik Simpan → muncul dialog konfirmasi; setelah dikonfirmasi data tersimpan dan notifikasi "tersimpan" muncul. |

### F. Tambah Penugasan — FTL / LTL

| ID | Requirement | Field | Wajib | Tipe Input | Acceptance Criteria |
|---|---|---|---|---|---|
| REQ-037 | Field No. Polisi (FTL/LTL) | No. Polisi | Required | Pilih dari master atau isi manual | Menyimpan tanpa No. Polisi → error required tampil dan data tidak tersimpan. |
| REQ-038 | Field Sopir (FTL/LTL) | Sopir | Required | Pilih dari master atau isi manual | Menyimpan tanpa Sopir → error required tampil dan data tidak tersimpan. |

### G. Tambah Penugasan — FCL / LCL

| ID | Requirement | Field / Aturan | Wajib | Aturan Validasi | Acceptance Criteria |
|---|---|---|---|---|---|
| REQ-039 | No. Kontainer | No. Kontainer | Required | Diisi per card kontainer. | Simpan tanpa No. Kontainer → error required. |
| REQ-040 | No. Segel | No. Segel | Required | Diisi per card kontainer. | Simpan tanpa No. Segel → error required. |
| REQ-041 | Armada Muat (Nopol) | Armada Muat (Nopol) | Required | Pilih dari master atau isi manual. | Simpan tanpa Armada Muat → error required. |
| REQ-042 | Sopir Muat | Sopir Muat | Required | Pilih dari master atau isi manual. | Simpan tanpa Sopir Muat → error required. |
| REQ-043 | Jadwal Kapal | Pilih jadwal kapal | Required | Wajib dipilih untuk FCL/LCL. | Simpan tanpa jadwal kapal → error required. |
| REQ-044 | Pengecualian CY-Door / CY-CY | Jika Metode Pengiriman adalah CY-Door atau CY-CY, kolom Nopol dan Armada **tidak ditampilkan**; hanya No. Kontainer dan No. Segel. | — | REQ-041 & REQ-042 tidak berlaku pada kondisi ini. | Memilih order FCL dengan metode CY-Door/CY-CY → form hanya menampilkan No. Kontainer & No. Segel (tanpa nopol/armada) dan dapat disimpan. |
| REQ-045 | Jadwal kapal bukan per-kontainer | Jadwal kapal ditetapkan di level penugasan/order, bukan per kontainer. | 1 jadwal kapal berlaku untuk seluruh kontainer pada penugasan tersebut. | Order dengan >1 kontainer → hanya ada 1 section jadwal kapal, bukan 1 per card kontainer. |
| REQ-046 | Jenis Jadwal Kapal | Field "Jenis Jadwal Kapal" wajib dipilih salah satu: **Direct** atau **Connecting**. | Required, single choice. | Simpan tanpa memilih jenis jadwal kapal → error required. |
| REQ-047 | Aturan Direct | Jika Jenis Jadwal Kapal = Direct, user **tidak dapat** menambahkan baris data kapal connecting. | Kontrol tambah baris connecting disembunyikan/nonaktif. | Pilih Direct → section/tombol tambah "Data Kapal Connecting" tidak tersedia. |
| REQ-048 | Aturan Connecting | Jika Jenis Jadwal Kapal = Connecting, user dapat menambahkan baris data kapal connecting (dapat lebih dari 1 baris). | Field "Data Kapal Connecting" muncul saat Connecting dipilih; mendukung multi-baris. | Pilih Connecting → field Data Kapal Connecting muncul dan dapat ditambah lebih dari 1 baris. |
| REQ-049 | Validasi ETD Connecting | ETD kapal connecting **tidak boleh melebihi** ETA kapal utama. | `ETD Connecting <= ETA Kapal Utama`. Jika dilanggar → tampilkan error dan blokir penyimpanan. | Mengisi ETD Connecting > ETA kapal utama → muncul pesan error validasi dan data tidak tersimpan. |

### H. Isi Data Tracking — Ketentuan Umum

| ID | Requirement | Deskripsi | Aturan Validasi | Acceptance Criteria |
|---|---|---|---|---|
| REQ-050 | Kanal pengisian | Isi Data Tracking hanya dapat diisi oleh pengurus/admin melalui web dan **tidak terhubung dengan Driver Hub**. | Tidak ada sinkronisasi/otomatisasi dari aplikasi driver. | Update tracking dari Driver Hub tidak memengaruhi data tracking OMS; hanya input web yang tercatat. |
| REQ-051 | Cakupan update tahap | Isi Data Tracking pada OMS hanya meng-update data "Selesai Muat" dan "Selesai Bongkar". | Tahap lain tidak tersedia di OMS. | Halaman Isi Data Tracking hanya menyediakan tahap Selesai Muat dan Selesai Bongkar. |
| REQ-052 | Dampak ke status | Pengisian data tracking akan mengubah status penugasan. | Mengacu pada REQ-020 s.d. REQ-022. | Setelah simpan data tracking, status pada daftar Penugasan Tracking berubah sesuai tahap. |
| REQ-053 | Informasi order read-only | Halaman Isi Data Tracking menampilkan informasi singkat order secara read-only: ID Order, Jenis Order, Rute, Tanggal Muat, Nopol, Jenis Armada/Kontainer, Sopir. | Read-only, tidak dapat diedit di halaman ini. | Seluruh 7 informasi tampil dan tidak dapat diubah. |
| REQ-054 | Form terpisah per kota drop | Form Isi Data Tracking dipisah berdasarkan kota drop (mengacu pola TMS-S). | Satu section per kota drop. | Order multi-drop → tampil section form terpisah untuk masing-masing kota drop. |
| REQ-055 | Pemilihan alamat & draft data | User perlu memilih alamat, lalu data pengiriman ter-draft (read-only) sesuai alamat terpilih, beserta nama perusahaan yang dituju. | Data pengiriman & nama perusahaan read-only, mengikuti alamat terpilih. | Memilih alamat → data pengiriman dan nama perusahaan terisi otomatis dan read-only. |
| REQ-056 | Field tanggal selesai muat/bongkar | Field tanggal selesai muat/bongkar dengan format `DD/MM/YYYY HH:mm`, menggunakan date picker. | **Required**; format DD/MM/YYYY HH:mm; input via datepicker. | Simpan tanpa tanggal → error required; tanggal terpilih tampil dalam format DD/MM/YYYY HH:mm. |
| REQ-057 | Field foto | Upload foto bukti tahap tracking. | **Required**; maksimal **6 foto**; maksimal **4 MB per foto**; format **JPG & PNG**. | Simpan tanpa foto → error required; foto tersimpan bila memenuhi batas. |
| REQ-058 | Alert batas foto | Jika jumlah foto melebihi 6 atau ukuran melebihi 4 MB per foto, tampilkan alert. | Alert muncul saat pelanggaran batas jumlah/ukuran. | Upload foto ke-7 atau file >4 MB → muncul alert dan file tidak diterima. |
| REQ-059 | Field keterangan | Field keterangan berupa text box. | **Opsional**. | Simpan tanpa keterangan tetap berhasil. |
| REQ-060 | Tombol Simpan (tracking) | Tombol "Simpan" menyimpan data dan melanjutkan ke tahap berikutnya hingga selesai, dengan tetap berada pada halaman Isi Data Tracking. | Tidak melakukan navigasi keluar halaman. | Klik Simpan → data tersimpan, form berpindah ke tahap berikutnya, user tetap di halaman Isi Data Tracking. |
| REQ-061 | Tombol Kembali (tracking) | Tombol "Kembali" mengarahkan user ke halaman Penugasan Tracking. | — | Klik Kembali → user diarahkan ke halaman daftar Penugasan Tracking. |
| REQ-062 | Auto-minimize kota selesai | Saat data tersimpan, kota yang sudah lengkap otomatis ter-minimize dan tampilan berpindah ke kota/tahap berikutnya. | Berlaku pada form multi kota drop. | Menyimpan data untuk Kota A → section Kota A ter-collapse dan section kota/tahap berikutnya terbuka. |

### I. Isi Data Tracking — Ketentuan Khusus FCL / LCL

| ID | Requirement | Deskripsi | Aturan Validasi / Kondisi | Acceptance Criteria |
|---|---|---|---|---|
| REQ-063 | Ubah No. Kontainer & No. Segel saat Selesai Muat | Khusus pengiriman FCL/LCL, pada saat update status Selesai Muat, user dapat mengubah No. Kontainer dan No. Segel. | Hanya tersedia pada tahap Selesai Muat untuk FCL/LCL. | Pada form Selesai Muat FCL/LCL, field No. Kontainer & No. Segel editable dan perubahannya tersimpan. |
| REQ-064 | Penugasan Sopir Bongkar | Jika Metode Pengiriman adalah **CY-Door** atau **Door-Door**, maka pada saat update Selesai Bongkar tampil pilihan untuk menugaskan sopir bongkar. | Field yang perlu diisi hanya **Nopol** dan **Sopir**. | Update Selesai Bongkar pada order CY-Door/Door-Door → tampil opsi tugaskan sopir bongkar dengan field Nopol dan Sopir. |
| REQ-065 | Metode pengisian sopir bongkar | Pengisian data sopir bongkar (Nopol & Sopir) dapat diambil dari data master atau diisi manual. | Sama dengan REQ-031 & REQ-032. | Tersedia dua metode (Pilih Dari Master / Isi Data Manual) pada form sopir bongkar. |
| REQ-066 | Navigasi Batal pada sopir bongkar | Saat menugaskan sopir bongkar lalu user klik **Batal**, sistem harus kembali ke halaman **Isi Data Tracking** — BUKAN halaman Penugasan Tracking. | Aturan navigasi kritikal (ditekankan berulang pada spesifikasi). | Buka form tugaskan sopir bongkar → klik Batal → user berada di halaman Isi Data Tracking, bukan daftar Penugasan Tracking. |
| REQ-067 | Pengecualian Door-CY / CY-CY | Jika Metode Pengiriman adalah **Door-CY** atau **CY-CY**, maka aturan penugasan sopir bongkar (REQ-064) dan metode pengisiannya (REQ-065) **tidak berlaku**. | Opsi tugaskan sopir bongkar tidak ditampilkan. | Update Selesai Bongkar pada order Door-CY/CY-CY → tidak ada opsi tugaskan sopir bongkar. |

### J. Detail Penugasan

| ID | Requirement | Deskripsi | Aturan / Kondisi | Acceptance Criteria |
|---|---|---|---|---|
| REQ-068 | Halaman Detail per ID Order | Halaman Detail Penugasan menampilkan informasi penugasan per ID Order. | Read-only. | Membuka Detail dari action menu → tampil informasi penugasan untuk ID Order tersebut. |
| REQ-069 | Bagian "Detail Data Order" | Menampilkan: ID Order, Jenis Order, Kota Asal, Kota Tujuan, Tanggal Permintaan Muat, Jenis Armada (FTL) / Jenis Kontainer (FCL), Kapasitas Armada/Kontainer, Metode Pengiriman (khusus FCL/LCL). | Field "Metode Pengiriman" hanya tampil untuk FCL/LCL. Label Jenis Armada vs Jenis Kontainer menyesuaikan jenis order. | Order FTL → tampil "Jenis Armada" tanpa Metode Pengiriman; Order FCL → tampil "Jenis Kontainer" dan Metode Pengiriman. |
| REQ-070 | Bagian "Informasi Penugasan" | Menampilkan: No. Polisi, Jenis Armada (FTL) / Jenis Kontainer (FCL), Nama Sopir, No. WA Sopir, dan Riwayat Penugasan (dengan aksi lihat detail). | Label menyesuaikan jenis order. | Seluruh field tampil sesuai data penugasan dan aksi "lihat detail" pada Riwayat Penugasan tersedia. |
| REQ-071 | Bagian "History Tracking" | Halaman Detail menampilkan bagian History Tracking. | Menampilkan riwayat tahap tracking yang telah diisi. | Bagian History Tracking tampil pada halaman Detail Penugasan. |
| REQ-072 | Pop-up Riwayat Penugasan | Aksi "lihat detail" pada Riwayat Penugasan menampilkan pop-up berisi informasi data armada dan/atau sopir yang telah diubah. | Pop-up read-only. | Klik lihat detail → pop-up terbuka berisi data perubahan. |
| REQ-073 | Isi pop-up Riwayat Penugasan | Pop-up menampilkan: tanggal perubahan, armada (nopol & jenis), sopir (nama & No. WA). | Seluruh atribut ditampilkan. | Pop-up memuat keempat kelompok informasi tersebut. |
| REQ-074 | Tampilan perubahan parsial | Jika hanya salah satu data yang diubah, maka hanya data yang berubah yang ditampilkan; data yang tidak berubah ditampilkan sebagai strip ("-"). Contoh: mengubah nopol saja → kolom sopir menampilkan "-". | Placeholder untuk data tidak berubah = "-". | Mengubah hanya nopol → pop-up riwayat menampilkan nopol baru dan kolom sopir bernilai "-". |

### K. Edit Penugasan

| ID | Requirement | Deskripsi | Aturan Validasi / Kondisi | Acceptance Criteria |
|---|---|---|---|---|
| REQ-075 | Bagian "Informasi Order" pada Edit | Halaman Edit menampilkan Informasi Order: ID Order, Vendor, Kota Asal, Kota Tujuan, Pelabuhan Asal (khusus FCL/LCL), Pelabuhan Tujuan (khusus FCL/LCL), Jenis Armada/Kontainer, Jumlah Armada/Kontainer, Metode Pengiriman (khusus FCL/LCL), Tanggal Permintaan Muat. | Pelabuhan Asal, Pelabuhan Tujuan, dan Metode Pengiriman hanya tampil untuk FCL/LCL. Informasi order bersifat read-only. | Order FTL → 3 field khusus FCL/LCL tidak tampil; Order FCL → seluruh field tampil. |
| REQ-076 | Editability FTL/LTL | Untuk FTL/LTL, nopol/armada (dan sopir) dapat diubah sampai status Selesai Muat. | Setelah status Selesai Muat tercapai/terlewati, field tidak dapat diubah lagi. | Status Belum Berangkat → nopol dapat diubah; setelah Selesai Muat → nopol tidak dapat diubah. |
| REQ-077 | Editability nopol/armada FCL/LCL | Untuk FCL/LCL, nopol/armada dapat diubah sampai status Selesai Muat. | Setelah Selesai Muat, nopol/armada terkunci. | Sesuai kondisi status, field nopol/armada aktif atau terkunci. |
| REQ-078 | Editability No. Kontainer & No. Segel | Untuk FCL/LCL, No. Kontainer dan No. Segel hanya dapat diubah sampai status Menunggu Proses (belum berangkat). | Setelah status berpindah dari Menunggu Proses, No. Kontainer & No. Segel terkunci pada halaman Edit. Catatan: perubahan tetap dimungkinkan lewat form Selesai Muat (REQ-063). | Status masih Menunggu Proses → field editable; status sudah lanjut → field terkunci di halaman Edit. |
| REQ-079 | Editability Jadwal Kapal | Jadwal kapal dapat diubah sampai status Selesai Muat. | Setelah Selesai Muat, jadwal kapal terkunci. | Sebelum Selesai Muat → jadwal kapal editable; setelah Selesai Muat → terkunci. |

### L. Riwayat Perubahan

| ID | Requirement | Deskripsi | Aturan / Kondisi | Acceptance Criteria |
|---|---|---|---|---|
| REQ-080 | Akses Riwayat Perubahan dari daftar | Action menu "Riwayat Perubahan" pada daftar Penugasan Tracking menampilkan riwayat perubahan penugasan untuk order terkait. | Konsisten dengan isi Riwayat Penugasan (REQ-072 s.d. REQ-074). | Klik "Riwayat Perubahan" → tampil riwayat perubahan armada/sopir beserta tanggal perubahan. |

---

## User Flows

### UF-01 — Melihat & Memfilter Daftar Penugasan Tracking (REQ-004 s.d. REQ-019)
**Flow Utama**
1. User membuka menu Penugasan Tracking.
2. Sistem menampilkan tabel default 20 data, urut terbaru teratas, dengan pagination.
3. User mengisi satu atau lebih field filter (ID Order, Jenis Shipment, Kota Asal, Kota Tujuan, Nopol/No. Kontainer, Sopir, Tahap Pengiriman, Status).
4. User klik "Terapkan".
5. Sistem menampilkan data sesuai kriteria filter.

**Alternatif**
- 3a. User klik "Reset" → seluruh field filter dikosongkan dan tabel kembali ke data default.
- 5a. Tidak ada data yang cocok → tampil state data kosong.
- 3b. Filter "Tahap Pengiriman" digunakan → sistem menampilkan order yang **pernah** mencapai tahap tersebut, meski status terkini sudah berbeda (REQ-015).

### UF-02 — Tambah Penugasan FTL/LTL (REQ-023 s.d. REQ-038)
**Flow Utama**
1. User klik "Tambah Penugasan" di halaman Penugasan Tracking.
2. Sistem membuka halaman Tambah Penugasan.
3. User mencari order via search bar (by ID/kota) dan memilih 1 order yang belum ditugaskan.
4. Sistem meng-auto-draft Kota Asal (prefix Kota/Kab.), Kota Tujuan, Jenis Armada, Jumlah Armada sebagai read-only, serta membuat card input sesuai jumlah armada (1 card untuk LTL).
5. Per card, user memilih metode pengisian No. Polisi dan Sopir: "Pilih Dari Master" atau "Isi Data Manual".
6. User klik "Simpan" → sistem menampilkan konfirmasi.
7. User mengonfirmasi → data tersimpan, notifikasi "tersimpan" muncul, status penugasan = Belum Berangkat.

**Alternatif / Percabangan**
- 5a. Metode master → dropdown hanya menampilkan armada sesuai jenis yang dipesan (REQ-033).
- 5b. Metode manual pada Sopir → No. WhatsApp opsional (REQ-032).
- 6a. Field required kosong → helper error tampil + border error, penyimpanan diblokir (REQ-034).
- 6b. User klik "Batal" → alert konfirmasi tampil; konfirmasi ya → proses dibatalkan.

### UF-03 — Tambah Penugasan FCL/LCL (REQ-039 s.d. REQ-049)
**Flow Utama**
1. Langkah 1–4 sama dengan UF-02 (untuk LCL: 1 card).
2. Per card, user mengisi No. Kontainer dan No. Segel (required).
3. User mengisi Armada Muat (Nopol) dan Sopir Muat (required) — master atau manual.
4. User memilih Jadwal Kapal (level penugasan, bukan per kontainer) dan memilih Jenis Jadwal Kapal: Direct atau Connecting.
5. User klik "Simpan" → konfirmasi → data tersimpan + notifikasi.

**Alternatif / Percabangan**
- 2a. Metode Pengiriman = CY-Door atau CY-CY → kolom Nopol & Armada tidak ditampilkan; hanya No. Kontainer & No. Segel (REQ-044).
- 4a. Jenis Jadwal Kapal = Direct → tidak dapat menambahkan baris kapal connecting (REQ-047).
- 4b. Jenis Jadwal Kapal = Connecting → field "Data Kapal Connecting" muncul, dapat ditambah >1 baris (REQ-048).
- 4c. ETD Connecting > ETA kapal utama → error validasi, penyimpanan diblokir (REQ-049).

### UF-04 — Isi Data Tracking (Selesai Muat → Selesai Bongkar) (REQ-050 s.d. REQ-067)
**Flow Utama**
1. Dari daftar, user memilih action "Isi Data Tracking".
2. Sistem menampilkan informasi singkat order (read-only) dan form terpisah per kota drop.
3. User memilih alamat → data pengiriman dan nama perusahaan ter-draft read-only.
4. User mengisi tanggal Selesai Muat (DD/MM/YYYY HH:mm, datepicker), upload foto (max 6, ≤4 MB, JPG/PNG), dan keterangan (opsional).
5. User klik "Simpan" → data tersimpan; status berubah menjadi "Dalam Perjalanan"; kota yang sudah lengkap ter-minimize; form berpindah ke tahap/kota berikutnya; user tetap di halaman Isi Data Tracking.
6. User mengulangi langkah 3–5 untuk tahap Selesai Bongkar hingga seluruh kota selesai.
7. Setelah Selesai Bongkar terakhir tersimpan, status menjadi "Selesai".

**Alternatif / Percabangan**
- 4a. Foto >6 atau file >4 MB → alert tampil, file ditolak (REQ-058).
- 4b. Tanggal kosong → error required (REQ-056).
- 4c. FCL/LCL pada tahap Selesai Muat → user dapat mengubah No. Kontainer & No. Segel (REQ-063).
- 6a. FCL/LCL dengan Metode Pengiriman CY-Door atau Door-Door → pada Selesai Bongkar tampil opsi tugaskan sopir bongkar (isi Nopol & Sopir, master/manual).
  - 6a-i. User klik "Batal" pada form sopir bongkar → **kembali ke halaman Isi Data Tracking**, bukan Penugasan Tracking (REQ-066).
- 6b. Metode Pengiriman Door-CY atau CY-CY → opsi tugaskan sopir bongkar tidak ditampilkan (REQ-067).
- 5a. User klik "Kembali" → diarahkan ke halaman Penugasan Tracking (REQ-061).

### UF-05 — Melihat Detail Penugasan & Riwayat Penugasan (REQ-068 s.d. REQ-074, REQ-080)
**Flow Utama**
1. User memilih action "Detail" pada baris penugasan.
2. Sistem menampilkan bagian Detail Data Order, Informasi Penugasan, dan History Tracking.
3. User klik "lihat detail" pada Riwayat Penugasan.
4. Sistem menampilkan pop-up berisi tanggal perubahan, armada (nopol & jenis), sopir (nama & WA).

**Alternatif**
- 4a. Hanya sebagian data yang berubah → kolom data yang tidak berubah ditampilkan "-" (REQ-074).
- 2a. Order FTL → tampil "Jenis Armada", tanpa Metode Pengiriman; Order FCL/LCL → tampil "Jenis Kontainer" dan Metode Pengiriman.
- 1a. User memilih action "Riwayat Perubahan" langsung dari daftar (REQ-080).

### UF-06 — Edit Penugasan (REQ-075 s.d. REQ-079)
**Flow Utama**
1. User memilih action "Edit" pada baris penugasan.
2. Sistem menampilkan Informasi Order (read-only) dan form penugasan yang dapat diubah.
3. User mengubah data yang diizinkan sesuai status penugasan.
4. User klik "Simpan" → konfirmasi → data tersimpan, perubahan tercatat pada Riwayat Penugasan.

**Alternatif / Percabangan**
- 3a. FTL/LTL, status sudah Selesai Muat → nopol/armada tidak dapat diubah.
- 3b. FCL/LCL, status sudah lewat Menunggu Proses → No. Kontainer & No. Segel tidak dapat diubah di halaman Edit.
- 3c. FCL/LCL, status sudah Selesai Muat → nopol/armada dan jadwal kapal tidak dapat diubah.
- 4a. Field required dikosongkan → helper error + border error, penyimpanan diblokir.

---

## Roles & Permissions

| Role | Lihat Daftar | Lihat Detail | Tambah Penugasan | Edit Penugasan | Isi Data Tracking | Riwayat Perubahan | Catatan |
|---|---|---|---|---|---|---|---|
| **Shipper (mengelola vendor)** | Ya | Ya | Ya | Ya | Ya | Ya | Akses penuh hanya untuk order yang ditujukan ke vendor yang dikelola Shipper (REQ-001). |
| **Shipper (tidak mengelola vendor)** | Ya | Ya | Tidak | Tidak | Tidak | Ya (read-only) | Akses terbatas hanya lihat detail (REQ-002). |
| **Vendor** | Ya | Ya | Ya | Ya | Ya | Ya | Akses penuh pada penugasan tracking (REQ-003). |
| **Pengurus/Admin (web)** | Ya | Ya | Ya | Ya | Ya | Ya | Satu-satunya pihak yang dapat mengisi data tracking; tidak melalui Driver Hub (REQ-050). |

Catatan matriks:
- Aksi Edit tetap tunduk pada aturan editability berbasis status (REQ-076 s.d. REQ-079) meskipun role memiliki akses penuh.
- Driver / Driver Hub **tidak** memiliki akses tulis pada modul ini.

---

## UI Inventory

Sumber: 22 file PNG pada `inputs/oms017-penugasan-tracking/designs/`.
Semua layar menggunakan shell aplikasi yang sama (sidebar + header). Elemen shell didokumentasikan sekali pada §Global Shell dan tidak diulang per layar.

### Global Shell (berlaku di semua layar)

| Elemen | Tipe | State terlihat | Teks/label persis | Selector hint Playwright |
|---|---|---|---|---|
| Logo aplikasi | image/text | — | `Mentari Sumber Kertas` | `getByRole('link', { name: 'Mentari Sumber Kertas' })` / `data-testid="app-logo"` |
| Toggle sidebar | button (icon hamburger) | enabled | — (icon only) | `getByRole('button', { name: 'Menu' })` / `data-testid="btn-toggle-sidebar"` |
| Badge role user | badge | — | `Shipper` / `Staff Operasional` | `getByText('Staff Operasional', { exact: true })` / `data-testid="badge-user-role"` |
| Notifikasi | button (icon bell + dot merah) | ada unread (dot merah) | — | `getByRole('button', { name: 'Notifikasi' })` / `data-testid="btn-notifikasi"` |
| Profil user | text | — | `Andika` / `andikamsk@gmail.com` | `data-testid="user-profile"` |
| Logout | button (icon) | enabled | — | `getByRole('button', { name: 'Keluar' })` / `data-testid="btn-logout"` |
| Menu sidebar: Penugasan Tracking | link | **selected/active** (highlight biru) | `Penugasan Tracking` | `getByRole('link', { name: 'Penugasan Tracking' })` / `data-testid="nav-penugasan-tracking"` |
| Menu sidebar lain | link | enabled | `Dashboard`, `Order`, `Master Wilayah`, `Master Operasional`, `Manajemen Vendor`, `Pengaturan Akun`, `Akun Saya`, `Pengaturan Sistem`, `Pusat Notifikasi` | `getByRole('link', { name: '<label>' })` |
| Menu sidebar: Simulasi Muatan | link | enabled — **hanya muncul pada pop-up*.png** | `Simulasi Muatan` | `getByRole('link', { name: 'Simulasi Muatan' })` / `data-testid="nav-simulasi-muatan"` |
| Kuota Order | progress + text | 40% terisi | `Kuota Order`, `120/300`, `40%` | `data-testid="kuota-order"` |
| Versi aplikasi | text | — | `Transportation Management System - Versi 1.0.0` | `getByText('Transportation Management System - Versi 1.0.0')` |
| Breadcrumb | navigation | link aktif/non-aktif | `Beranda` > `Penugasan Tracking` > `<halaman>` | `getByRole('navigation', { name: 'breadcrumb' })` / `data-testid="breadcrumb"` |

---

### 127 — Daftar Penugasan Tracking (FTL/LTL)

Layar utama modul (entry point UF-01). Menampilkan panel filter yang sudah ter-expand, tabel penugasan 6 baris contoh, dan pagination. Ini adalah versi baseline daftar (tanpa kolom Petugas, tanpa filter tanggal).

| Elemen | Tipe | State | Teks/label persis | Selector hint |
|---|---|---|---|---|
| Judul halaman | heading | — | `Penugasan Tracking` | `getByRole('heading', { name: 'Penugasan Tracking' })` |
| Tombol Tambah Penugasan | button (primary, icon +) | enabled | `Tambah Penugasan` | `getByRole('button', { name: 'Tambah Penugasan' })` / `data-testid="btn-tambah-penugasan"` |
| Tombol Filter | button (outline, icon) | enabled (panel terbuka) | `Filter` | `getByRole('button', { name: 'Filter' })` / `data-testid="btn-toggle-filter"` |
| Page size | select | value `20` | `Tampilkan` … `data` | `getByLabel('Tampilkan')` / `data-testid="select-page-size"` |
| Filter ID Order | input text | empty (placeholder) | label `ID Order`, placeholder `Masukkan ID Order` | `getByLabel('ID Order')` / `getByPlaceholder('Masukkan ID Order')` / `data-testid="filter-id-order"` |
| Filter Jenis Shipment | select/dropdown | empty | label `Jenis Shipment`, placeholder `Pilih Jenis Shipment` | `getByLabel('Jenis Shipment')` / `data-testid="filter-jenis-shipment"` |
| Filter Kota Asal | select/dropdown | empty | label `Kota Asal`, placeholder `Pilih Rute` | `getByLabel('Kota Asal')` / `data-testid="filter-kota-asal"` |
| Filter Kota Tujuan | select/dropdown | empty | label `Kota Tujuan`, placeholder `Pilih Rute` | `getByLabel('Kota Tujuan')` / `data-testid="filter-kota-tujuan"` |
| Filter No. Polisi/No. Kontainer | input text | empty | label `No. Polisi/No. Kontainer`, placeholder `Masukkan No. Polisi/No. Kontainer` | `getByLabel('No. Polisi/No. Kontainer')` / `data-testid="filter-nopol-kontainer"` |
| Filter Sopir | input text | empty | label `Sopir`, placeholder `Masukkan Nama Sopir` | `getByLabel('Sopir')` / `data-testid="filter-sopir"` |
| Filter Status | select/dropdown | empty | label `Status`, placeholder `Pilih Status` | `getByLabel('Status')` / `data-testid="filter-status"` |
| Tombol Reset | button (outline merah) | enabled | `Reset` | `getByRole('button', { name: 'Reset' })` / `data-testid="btn-reset-filter"` |
| Tombol Terapkan | button (primary) | enabled | `Terapkan` | `getByRole('button', { name: 'Terapkan' })` / `data-testid="btn-terapkan-filter"` |
| Tabel penugasan | table | 6 baris terisi | — | `getByRole('table')` / `data-testid="tabel-penugasan-tracking"` |
| Header ID Order (sortable) | columnheader + sort icon `⇅` | sortable | `ID Order` | `getByRole('columnheader', { name: 'ID Order' })` / `data-testid="th-id-order"` |
| Header Rute (sortable) | columnheader + sort icon `⇅` | sortable | `Rute` | `getByRole('columnheader', { name: 'Rute' })` / `data-testid="th-rute"` |
| Header No. Polisi/No. Kontainer + Sopir | columnheader (2 baris) | — | `No. Polisi/No. Kontainer` / `Sopir` | `data-testid="th-nopol-sopir"` |
| Header Status | columnheader | — | `Status` | `getByRole('columnheader', { name: 'Status' })` / `data-testid="th-status"` |
| Badge jenis shipment (per baris) | badge | warna berbeda per jenis | `LTL` (oranye), `FCL` (biru), `LCL` (biru), `FTL` (hijau) | `getByRole('row', { name: /ORD82090192/ }).getByText('LTL')` / `data-testid="badge-jenis-shipment"` |
| Badge status (per baris) | badge | 5 varian warna | `Menunggu Proses` (abu), `Selesai Muat` (biru), `Selesai Bongkar` (hijau), `Dalam Perjalanan` (kuning), `Dibatalkan` (merah) | `getByRole('row', { name: /ORD76392092/ }).getByText('Selesai Muat')` / `data-testid="badge-status"` |
| Tombol action per baris | button (icon `...`) | enabled | — | `getByRole('row', { name: /ORD82090192/ }).getByRole('button', { name: 'Aksi' })` / `data-testid="btn-row-action"` |
| Info paginasi | text | — | `Menampilkan 1 - 20 data dari 30 data` | `getByText(/Menampilkan \d+ - \d+ data dari \d+ data/)` / `data-testid="pagination-info"` |
| Kontrol pagination | navigation | halaman `1` selected | `1`,`2`,`3`,`...`,`12` + tombol first/prev/next/last | `getByRole('button', { name: '2' })` / `data-testid="pagination"` |

**Data contoh yang terlihat:** ORD82090192 (LTL, Kota Surabaya - Kota Malang, L 1892 PGS / Murtiono, Menunggu Proses); ORD76392092 (FCL, Kota Surabaya - Kab. Bima, CNT728900287 / Reza, Selesai Muat); ORD62838963 (FCL, Kota Jakarta - Kota Pontianak, TGH672890 / Rizki, Selesai Muat); ORD00986289 (LCL, Kota Bandar Lampung - Kota Banjarmasin, THY78920009 / Joko, Selesai Bongkar); ORD19283005 (FTL, Kab. Banyuwangi - Kota Semarang, P 7872 UJ / M. Putra, Dalam Perjalanan); ORD0082636 (LTL, Kota Jakarta - Kota Pontianak, B 7930 HD / Yunita, Dibatalkan).

**Validasi/empty-state terlihat:** tidak ada. Tidak ada empty-state maupun error-state pada desain daftar.

**Catatan perilaku:**
- Rute selalu ditulis dengan prefix `Kota`/`Kab.` (mendukung REQ-028).
- Kolom Status memuat **campuran** nilai dari dua set penamaan (lihat A-01 & D-02).
- Tidak ada filter "Tahap Pengiriman" pada desain ini meski REQ-015 mensyaratkannya (lihat D-01).
- Info paginasi (`30 data`) tidak konsisten dengan jumlah halaman (`12`) — data dummy.

---

### 128 — Action Menu Trucking (dropdown pada baris FTL/LTL)

Sama dengan layar 127, dengan dropdown action menu terbuka pada baris ORD76392092. Digunakan untuk memverifikasi REQ-007.

| Elemen | Tipe | State | Teks/label persis | Selector hint |
|---|---|---|---|---|
| Dropdown action menu | menu | open | — | `getByRole('menu')` / `data-testid="menu-row-action"` |
| Item Detail Penugasan | menuitem | enabled | `Detail Penugasan` | `getByRole('menuitem', { name: 'Detail Penugasan' })` / `data-testid="menu-detail-penugasan"` |
| Item Edit Penugasan | menuitem | enabled | `Edit Penugasan` | `getByRole('menuitem', { name: 'Edit Penugasan' })` / `data-testid="menu-edit-penugasan"` |
| Item Isi Data Tracking | menuitem | enabled | `Isi Data Tracking` | `getByRole('menuitem', { name: 'Isi Data Tracking' })` / `data-testid="menu-isi-data-tracking"` |
| Item Riwayat Perubahan | menuitem | enabled | `Riwayat Perubahan` | `getByRole('menuitem', { name: 'Riwayat Perubahan' })` / `data-testid="menu-riwayat-perubahan"` |
| Header kolom Status (varian) | columnheader (2 baris) | — | `Status` / `Tanggal Mulai Tracking` | `data-testid="th-status"` |

**Catatan perilaku:** menu memuat tepat 4 item sesuai REQ-007. Panel filter tetap terlihat di belakang overlay (menu bersifat popover, bukan modal).

---

### 129 — Action Menu Container (dropdown pada baris FCL/LCL)

Identik dengan 128 (4 item menu yang sama), hanya berbeda posisi/anchor dropdown. Menegaskan bahwa action menu untuk shipment kontainer **sama** dengan trucking pada versi desain ini.

| Elemen | Tipe | State | Teks/label persis | Selector hint |
|---|---|---|---|---|
| Dropdown action menu | menu | open (anchor bergeser ke kiri) | `Detail Penugasan`, `Edit Penugasan`, `Isi Data Tracking`, `Riwayat Perubahan` | `getByRole('menu')` / `data-testid="menu-row-action"` |

**Catatan perilaku:** tidak ada item khusus kontainer (mis. Penugasan Sopir Bongkar) pada versi ini — item tersebut baru muncul pada layar 139 (lihat D-04).

---

### 133a — Detail Penugasan LTL (History Tracking — tab Per Lokasi)

Halaman Detail Penugasan untuk order LTL berstatus Dalam Perjalanan (UF-05 langkah 2). Menampilkan 3 section collapsible.

| Elemen | Tipe | State | Teks/label persis | Selector hint |
|---|---|---|---|---|
| Tombol kembali | button (icon `<`) | enabled | — | `getByRole('button', { name: 'Kembali' })` / `data-testid="btn-back"` |
| Judul halaman | heading | — | `Detail Penugasan` | `getByRole('heading', { name: 'Detail Penugasan' })` |
| Badge status halaman | badge | biru muda | `Dalam Perjalanan` | `data-testid="badge-status-penugasan"` |
| Section Detail Data Order | accordion header | **expanded** (chevron ke atas) | `Detail Data Order` | `getByRole('button', { name: 'Detail Data Order' })` / `data-testid="section-detail-data-order"` |
| ID Order | read-only field | — | label `ID Order`, nilai `LTL0152708249` | `data-testid="detail-id-order"` |
| Jenis Shipment | read-only field | — | label `Jenis Shipment`, nilai `LTL (Less Than Truckload)` | `data-testid="detail-jenis-shipment"` |
| Kota Asal | read-only field | multi-kota | label `Kota Asal`, nilai `Kota Surabaya, Kab. Sidoarjo, Kab. Mojokerto` | `data-testid="detail-kota-asal"` |
| Kota Tujuan | read-only field | — | label `Kota Tujuan`, nilai `Kota Probolinggo` | `data-testid="detail-kota-tujuan"` |
| Tanggal Permintaan Muat | read-only field | format DD/MM/YYYY HH:mm | label `Tanggal Permintaan Muat`, nilai `31/05/2026 14:30` | `data-testid="detail-tgl-permintaan-muat"` |
| Jenis Armada | read-only field | — | label `Jenis Armada`, nilai `Tronton Wing Box` | `data-testid="detail-jenis-armada"` |
| Kapasitas Armada | read-only field | — | label `Kapasitas Armada`, nilai `5000 kg / 36 m³` | `data-testid="detail-kapasitas-armada"` |
| Section Informasi Penugasan | accordion header | expanded | `Informasi Penugasan` | `getByRole('button', { name: 'Informasi Penugasan' })` / `data-testid="section-informasi-penugasan"` |
| No. Polisi | read-only field | — | label `No. Polisi`, nilai `GK6802BOX` | `data-testid="detail-no-polisi"` |
| Jenis Armada (penugasan) | read-only field | — | label `Jenis Armada`, nilai `Tronton Box` | `data-testid="detail-penugasan-jenis-armada"` |
| Riwayat Penugasan — Lihat Detail | link | enabled | label `Riwayat Penugasan`, link `Lihat Detail` | `getByRole('link', { name: 'Lihat Detail' })` / `data-testid="link-riwayat-penugasan"` |
| Nama Sopir | read-only field | — | label `Nama Sopir`, nilai `Kenzo Nonoya` | `data-testid="detail-nama-sopir"` |
| No. WA Sopir | read-only field | — | label `No. WA Sopir`, nilai `082139240985` | `data-testid="detail-no-wa-sopir"` |
| Section History Tracking | accordion header | expanded | `History Tracking` | `getByRole('button', { name: 'History Tracking' })` / `data-testid="section-history-tracking"` |
| Tab Per Lokasi | tab | **selected** (biru solid) | `Per Lokasi` | `getByRole('tab', { name: 'Per Lokasi' })` / `data-testid="tab-per-lokasi"` |
| Tab Timeline | tab | unselected | `Timeline` | `getByRole('tab', { name: 'Timeline' })` / `data-testid="tab-timeline"` |
| Grup lokasi | list item (icon pin) | — | `Kabupaten Sidoarjo` `(1/1 alamat selesai)` | `data-testid="tracking-lokasi-group"` |
| Kartu alamat | card | selesai (check hijau) | `Surabaya - Gempol Toll Rd No.KM. 754, Ngepung, Sidokepung, Buduran, Sidoarjo Regency, East Java 61252` | `data-testid="tracking-alamat-card"` |
| Progress tahapan alamat | text | — | `2/2 tahapan tercatat` • `Selesai` | `getByText('2/2 tahapan tercatat')` / `data-testid="tracking-progress-alamat"` |
| Kartu tahapan | card (bg hijau) | selesai | `Berangkat Muat` • `31 Mei 2026, 04.29`, `PIC: Minul (6282139240985)` | `data-testid="tracking-tahapan-card"` |
| Aksi Detail (tahapan) | link/button (icon mata) | enabled | `Detail` | `getByRole('button', { name: 'Detail' })` / `data-testid="btn-detail-tahapan"` |
| Aksi Edit (tahapan) | link/button (icon pensil) | enabled | `Edit` | `getByRole('button', { name: 'Edit' })` / `data-testid="btn-edit-tahapan"` |

**Validasi/empty-state terlihat:** tidak ada.

**Catatan perilaku:**
- Tahapan yang muncul adalah `Berangkat Muat` — bukan `Selesai Muat`/`Selesai Bongkar` seperti REQ-051 (lihat D-06).
- Ada konsep `PIC` pada tahapan tracking yang tidak dijelaskan spec (lihat D-05).
- Section Detail Data Order tampil collapsible dengan chevron; expand/collapse adalah perilaku tersirat.

---

### 134 — Tambah Penugasan FCL (Door to Door, 2 kontainer, Direct, master)

Form Tambah Penugasan untuk order FCL dengan 2 kontainer (UF-03). Order terpilih = LKL903902398.

| Elemen | Tipe | State | Teks/label persis | Selector hint |
|---|---|---|---|---|
| Judul halaman | heading | — | `Tambah Penugasan` | `getByRole('heading', { name: 'Tambah Penugasan' })` |
| Label Pilih Order | label (required `*`) | — | `Pilih Order *` | `getByText('Pilih Order')` / `data-testid="label-pilih-order"` |
| Search order | input search (icon kaca pembesar) | empty | placeholder `Cari Order` | `getByPlaceholder('Cari Order')` / `data-testid="input-cari-order"` |
| Daftar order (radio group) | radiogroup, scrollable | 1 terpilih | — | `getByRole('radiogroup')` / `data-testid="list-pilih-order"` |
| Opsi order 1 | radio | unselected | `LKL903901897 • PT Agri Persada Sejahtera` / `Surabaya - Semarang • Tronton Wing Box` / badge `LTL` | `getByRole('radio', { name: /LKL903901897/ })` / `data-testid="opt-order-LKL903901897"` |
| Opsi order 2 | radio | **selected** | `LKL903902398 • PT Sumber Makmur Jaya` / `Tanjung Perak (SUB) - Makassar (MAK) • 40 DRY` / badge `FCL` | `getByRole('radio', { name: /LKL903902398/ })` |
| Opsi order 3 | radio | unselected | `LKL903902399 • PT Sumber Makmur Jaya` / `Multipickup → Kota Semarang • Tronton Box` / badge `FTL` | `getByRole('radio', { name: /LKL903902399/ })` |
| Opsi order 4 | radio | unselected | `LKL903900010 • Andrea Mustika` / `Tanjung Perak (SUB) - Tanjung Emas (SMG) • 20 DRY` / badge `LCL` | `getByRole('radio', { name: /LKL903900010/ })` |
| Ringkasan order (auto-draft) | read-only definition list | terisi, read-only | `Kota Asal : Kota Surabaya, Kab. Sidoarjo, Kab. Mojokerto`; `Kota Tujuan : Kota Makassar`; `Pelabuhan Asal : Tanjung Perak (SUB)`; `Pelabuhan Tujuan : Makassar (MAK)`; `Jenis Kontainer : 20 DRY`; `Jumlah Kontainer : 2`; `Metode Pengiriman : Door to Door` | `data-testid="ringkasan-order"` |
| Card Kontainer 1 | section/card | — | `Kontainer 1` | `data-testid="card-kontainer-1"` |
| No. Kontainer | input text (required) | empty | label `No. Kontainer *`, placeholder `Masukkan No. Kontainer` | `getByLabel('No. Kontainer')` / `getByPlaceholder('Masukkan No. Kontainer')` / `data-testid="input-no-kontainer-1"` |
| No. Segel | input text (required) | empty | label `No. Segel *`, placeholder `Masukkan No. Segel` | `getByLabel('No. Segel')` / `getByPlaceholder('Masukkan No. Segel')` / `data-testid="input-no-segel-1"` |
| Armada Muat — metode | radiogroup (required) | `Pilih Dari Master` **selected** | `Armada Muat *`, opsi `Pilih Dari Master` / `Isi Data Manual` | `getByRole('radio', { name: 'Pilih Dari Master' })` / `data-testid="radio-armada-muat-master-1"` |
| No. Polisi/Jenis Armada | select (master) | empty | label `No. Polisi/Jenis Armada`, placeholder `Cari No. Polisi/Jenis Armada` | `getByLabel('No. Polisi/Jenis Armada')` / `data-testid="select-armada-muat-1"` |
| Sopir Muat — metode | radiogroup (required) | `Pilih Dari Master` **selected** | `Sopir Muat *`, opsi `Pilih Dari Master` / `Isi Data Manual` | `getByRole('radio', { name: 'Pilih Dari Master' })` / `data-testid="radio-sopir-muat-master-1"` |
| Sopir/No. WhatsApp | select (master) | empty | label `Sopir/No. WhatsApp`, placeholder `Cari Sopir/No. WhatsApp` | `getByLabel('Sopir/No. WhatsApp')` / `data-testid="select-sopir-muat-1"` |
| Card Kontainer 2 | section/card | struktur identik card 1 | `Kontainer 2` | `data-testid="card-kontainer-2"` |
| Jenis Jadwal Kapal | radiogroup (required) | `Direct` **selected** | `Jenis Jadwal Kapal *`, opsi `Direct` / `Connecting` | `getByRole('radio', { name: 'Direct' })` / `data-testid="radio-jadwal-direct"` |
| Detail Kapal Utama | fieldset | — | `Detail Kapal Utama` | `data-testid="fieldset-kapal-utama"` |
| Pelayaran | select (required) | empty | label `Pelayaran *`, placeholder `Pilih Pelayaran` | `getByLabel('Pelayaran')` / `data-testid="select-pelayaran"` |
| Nama Kapal | input text (required) | empty | label `Nama Kapal *`, placeholder `Masukkan Nama Kapal` | `getByLabel('Nama Kapal')` / `data-testid="input-nama-kapal"` |
| Voyage | input text (required) | empty | label `Voyage *`, placeholder `Masukkan Voyage` | `getByLabel('Voyage')` / `data-testid="input-voyage"` |
| Closing Time | datepicker (required) | empty | label `Closing Time *`, placeholder `DD/MM/YYYY` | `getByLabel('Closing Time')` / `getByPlaceholder('DD/MM/YYYY')` / `data-testid="date-closing-time"` |
| Berangkat (ETD) | datepicker (required) | empty | label `Berangkat (ETD) *`, placeholder `DD/MM/YYYY` | `getByLabel('Berangkat (ETD)')` / `data-testid="date-etd"` |
| Tiba (ETA) | datepicker (required) | empty | label `Tiba (ETA) *`, placeholder `DD/MM/YYYY` | `getByLabel('Tiba (ETA)')` / `data-testid="date-eta"` |
| Tombol Batal | button (outline merah) | enabled | `Batal` | `getByRole('button', { name: 'Batal' })` / `data-testid="btn-batal"` |
| Tombol Simpan | button (primary) | enabled | `Simpan` | `getByRole('button', { name: 'Simpan' })` / `data-testid="btn-simpan"` |

**Validasi/empty-state terlihat:** tidak ada pesan error; hanya penanda required `*` (merah) pada label.

**Catatan perilaku:**
- Jumlah card = `Jumlah Kontainer` (2) → mendukung REQ-029.
- Section jadwal kapal berada di luar card kontainer (1 jadwal untuk semua kontainer) → mendukung REQ-045.
- Saat `Direct` dipilih, section `Data Kapal Connecting` dan tombol `Tambah Kapal Connecting` **tidak dirender** → mendukung REQ-047.
- Field ETD/ETA hanya `DD/MM/YYYY` (tanpa jam).

---

### 135 — Tambah Penugasan FCL (Connecting + kombinasi metode manual/master)

Varian 134 dengan `Connecting` terpilih dan campuran metode pengisian. Digunakan untuk menguji REQ-032, REQ-048, REQ-049.

| Elemen | Tipe | State | Teks/label persis | Selector hint |
|---|---|---|---|---|
| Ringkasan order | read-only list | terisi | `Pelabuhan Asal : Kota Surabaya, Kab. Sidoarjo, Kab. Mojokerto`; `Pelabuhan Tujuan : Kota Semarang`; `Jenis Kontainer : Tronton Box`; `Jumlah Kontainer : 2`; `Metode Pengiriman : Door to Door` | `data-testid="ringkasan-order"` |
| Kontainer 1 — Armada Muat | radiogroup | `Isi Data Manual` **selected** | `Isi Data Manual` | `getByRole('radio', { name: 'Isi Data Manual' })` / `data-testid="radio-armada-muat-manual-1"` |
| Kontainer 1 — No. Polisi | input text | empty | label `No. Polisi` (tanpa `*`), placeholder `Masukkan No. Polisi` | `getByLabel('No. Polisi')` / `data-testid="input-no-polisi-1"` |
| Kontainer 1 — Sopir Muat | radiogroup | `Isi Data Manual` **selected** | `Isi Data Manual` | `data-testid="radio-sopir-muat-manual-1"` |
| Kontainer 1 — Nama Sopir | input text | empty | label `Nama Sopir`, placeholder `Masukkan Nama Sopir` | `getByLabel('Nama Sopir')` / `data-testid="input-nama-sopir-1"` |
| Kontainer 1 — No. WhatsApp | input text | empty, **opsional** | label `No. WhatsApp (opsional)`, placeholder `Masukkan No. WhatsApp` | `getByLabel('No. WhatsApp (opsional)')` / `data-testid="input-no-wa-sopir-1"` |
| Kontainer 2 — Armada Muat | radiogroup | `Isi Data Manual` selected | `Isi Data Manual` | `data-testid="radio-armada-muat-manual-2"` |
| Kontainer 2 — Sopir Muat | radiogroup | `Pilih Dari Master` selected | `Pilih Dari Master` | `data-testid="radio-sopir-muat-master-2"` |
| Jenis Jadwal Kapal | radiogroup | `Connecting` **selected** (catatan: kedua radio tampak ter-highlight — anomali desain) | `Direct` / `Connecting` | `getByRole('radio', { name: 'Connecting' })` / `data-testid="radio-jadwal-connecting"` |
| Data Kapal Connecting | fieldset (muncul saat Connecting) | 1 baris | `Data Kapal Connecting` | `data-testid="fieldset-kapal-connecting"` |
| Pelabuhan Connecting | select (required) | empty | label `Pelabuhan Connecting *`, placeholder `Pilih Pelabuhan` | `getByLabel('Pelabuhan Connecting')` / `data-testid="select-pelabuhan-connecting-1"` |
| Kapal Connecting | input text (required) | empty | label `Kapal Connecting *`, placeholder `Masukkan Nama Kapal` | `getByLabel('Kapal Connecting')` / `data-testid="input-kapal-connecting-1"` |
| Voyage (connecting) | input text (required) | empty | label `Voyage *`, placeholder `Masukkan Voyage` | `data-testid="input-voyage-connecting-1"` |
| ETD Connecting | datepicker (required) | empty | label `ETD Connecting *`, placeholder `DD/MM/YYYY` | `getByLabel('ETD Connecting')` / `data-testid="date-etd-connecting-1"` |
| Tombol Tambah Kapal Connecting | button/link (icon +) | enabled | `Tambah Kapal Connecting` | `getByRole('button', { name: 'Tambah Kapal Connecting' })` / `data-testid="btn-tambah-kapal-connecting"` |

**Validasi/empty-state terlihat:** tidak ada pesan error tampil. Tidak ada desain untuk pesan error REQ-049 (ETD Connecting > ETA) — lihat D-07.

**Catatan perilaku:**
- Field `No. WhatsApp (opsional)` hanya muncul pada metode manual Sopir → mendukung REQ-032.
- Metode pengisian dapat berbeda antar card (card 1 manual, card 2 master).
- Ringkasan order pada layar ini memakai label `Pelabuhan Asal`/`Pelabuhan Tujuan` untuk nilai kota → inkonsistensi label (lihat D-08).

---

### 136 — Tambah Penugasan FCL (Metode Door to CY, radio-card Jenis Jadwal Kapal)

Varian dengan `Metode Pengiriman : Door to CY`. Kolom armada/sopir **tetap ditampilkan** (konsisten REQ-044 yang hanya mengecualikan CY-Door & CY-CY). Jenis Jadwal Kapal dirender sebagai radio-card dengan deskripsi.

| Elemen | Tipe | State | Teks/label persis | Selector hint |
|---|---|---|---|---|
| Ringkasan order | read-only list | terisi | `Metode Pengiriman : Door to CY` | `data-testid="ringkasan-metode-pengiriman"` |
| Kontainer 1 — Armada Muat | radiogroup | `Isi Data Manual` selected | `Isi Data Manual` | `data-testid="radio-armada-muat-manual-1"` |
| Kontainer 1 — Sopir Muat | radiogroup | `Pilih Dari Master` selected | `Pilih Dari Master` | `data-testid="radio-sopir-muat-master-1"` |
| Kontainer 2 — Sopir Muat | radiogroup | `Isi Data Manual` selected | `Isi Data Manual` | `data-testid="radio-sopir-muat-manual-2"` |
| Radio-card Direct | radio card | unselected | `Direct` / deskripsi `Satu kapal langsung ke tujuan` | `getByRole('radio', { name: /Direct/ })` / `data-testid="radiocard-jadwal-direct"` |
| Radio-card Connecting | radio card | **selected** (border & bg biru) | `Connecting` / deskripsi `Kapal transit melalui pelabuhan lain` | `getByRole('radio', { name: /Connecting/ })` / `data-testid="radiocard-jadwal-connecting"` |
| Data Kapal Connecting | fieldset | tampil, 1 baris | `Data Kapal Connecting` | `data-testid="fieldset-kapal-connecting"` |
| Tombol Tambah Kapal Connecting | button (icon +) | enabled | `Tambah Kapal Connecting` | `data-testid="btn-tambah-kapal-connecting"` |

**Validasi/empty-state terlihat:** tidak ada.

**Catatan perilaku:** Jenis Jadwal Kapal punya **2 varian tampilan** (radio inline pada 134/135/149/150 vs radio-card pada 136/137) — selector sebaiknya berbasis `getByRole('radio', { name: /Connecting/ })` agar tahan terhadap kedua varian.

---

### 137 — Tambah Penugasan FCL (Metode CY to Door — Pilih PIC Penugasan)

Varian `Metode Pengiriman : CY to Door`. Sesuai REQ-044, card kontainer **tidak** menampilkan Armada Muat/Sopir Muat; sebagai gantinya muncul komponen baru **Pilih PIC Penugasan** (multi-select dengan chip) yang tidak ada di spec.

| Elemen | Tipe | State | Teks/label persis | Selector hint |
|---|---|---|---|---|
| Ringkasan order | read-only list | terisi | `Metode Pengiriman : CY to Door` | `data-testid="ringkasan-metode-pengiriman"` |
| No. Kontainer | input text (required) | empty | label `No. Kontainer *`, placeholder `Masukkan No. Kontainer` | `getByLabel('No. Kontainer')` / `data-testid="input-no-kontainer-1"` |
| No. Segel | input text (required) | empty | label `No. Segel *`, placeholder `Masukkan No. Segel` | `getByLabel('No. Segel')` / `data-testid="input-no-segel-1"` |
| Pilih PIC Penugasan | multi-select (required) + icon info | 2 terpilih | `Pilih PIC Penugasan *` | `getByLabel('Pilih PIC Penugasan')` / `data-testid="multiselect-pic-penugasan"` |
| Chip PIC terpilih | chip/tag dengan tombol hapus `×` | selected | `Andi Darmawan ×`, `Mustika Putri ×` | `getByRole('button', { name: 'Hapus Andi Darmawan' })` / `data-testid="chip-pic-andi-darmawan"` |
| Search PIC | input search (icon) | empty | — (icon kaca pembesar di kanan) | `data-testid="input-cari-pic"` |
| Checkbox Pilih Semua | checkbox | **checked** | `Pilih Semua` | `getByRole('checkbox', { name: 'Pilih Semua' })` / `data-testid="cb-pic-pilih-semua"` |
| Opsi PIC | checkbox (4 opsi) | semua checked | `Andi Darmawan` `082579795536 • Surabaya`; `Andika Budianto` `081257379890 • Gresik`; `Mustika Putri` `081257379890 • Gresik`; `Dedi Kurniawan` `081257379890 • Gresik` | `getByRole('checkbox', { name: /Andi Darmawan/ })` / `data-testid="cb-pic-andi-darmawan"` |
| Info note PIC | alert/info banner (icon i) | info | `PIC akan menerima notifikasi dan dapat membantu pengelolaan data tracking dari sisi web.` | `getByText('PIC akan menerima notifikasi dan dapat membantu pengelolaan data tracking dari sisi web.')` / `data-testid="info-pic-penugasan"` |
| Radio-card Connecting | radio card | selected | `Connecting` / `Kapal transit melalui pelabuhan lain` | `data-testid="radiocard-jadwal-connecting"` |

**Validasi/empty-state terlihat:** tidak ada error; hanya info banner.

**Catatan perilaku:**
- Konfirmasi visual REQ-044: pada CY-Door tidak ada input Nopol/Armada/Sopir.
- Chip terpilih (2) tidak sinkron dengan checkbox (4 checked + Pilih Semua) — inkonsistensi data dummy desain.
- Fitur PIC Penugasan tidak tercakup requirement manapun (lihat D-05).

---

### 139 — Daftar Penugasan Tracking (versi revisi: kolom Petugas, filter Tanggal, action menu 6 item)

Versi daftar yang lebih baru. Berbeda signifikan dari 127/145 dan menjadi sumber utama discrepancy desain vs spec.

| Elemen | Tipe | State | Teks/label persis | Selector hint |
|---|---|---|---|---|
| Filter ID Order | input text | empty, **bertanda `*`** | `ID Order *`, placeholder `Masukkan ID Order` | `getByLabel('ID Order')` / `data-testid="filter-id-order"` |
| Filter Jenis Shipment | select | empty, `*` | `Jenis Shipment *`, placeholder `Pilih Jenis Shipment` | `data-testid="filter-jenis-shipment"` |
| Filter Kota Asal | select | empty, `*` | `Kota Asal *`, placeholder `Pilih Rute` | `data-testid="filter-kota-asal"` |
| Filter Kota Tujuan | select | empty, `*` | `Kota Tujuan *`, placeholder `Pilih Rute` | `data-testid="filter-kota-tujuan"` |
| Filter No. Polisi/No. Kontainer | input text | empty, `*` | `No. Polisi/No. Kontainer *`, placeholder `Masukkan No. Polisi/No. Kontainer` | `data-testid="filter-nopol-kontainer"` |
| Filter Sopir/Petugas | input text | empty, `*` | `Sopir/Petugas *`, placeholder `Masukkan Nama Sopir/Petugas` | `getByLabel('Sopir/Petugas')` / `data-testid="filter-sopir-petugas"` |
| Filter Tanggal Mulai Tracking | datepicker | empty, `*` | `Tanggal Mulai Tracking *`, placeholder `DD/MM/YYYY` | `getByLabel('Tanggal Mulai Tracking')` / `data-testid="filter-tanggal-mulai-tracking"` |
| Filter Status | select | empty, `*` | `Status *`, placeholder `Pilih Status` | `data-testid="filter-status"` |
| Header kolom 3 | columnheader (2 baris) | — | `No. Polisi/No. Kontainer` / `Sopir • Petugas` | `data-testid="th-nopol-sopir-petugas"` |
| Header kolom 4 | columnheader (2 baris) | — | `Status` / `Tanggal Mulai Tracking` | `data-testid="th-status-tgl-tracking"` |
| Sel Sopir/Petugas + counter | text + badge | — | `Murtiono • Suwarno` `+ 3`; `Reza • Suwarno` `+ 2`; `- • Joko`; `- • Yunita` `+ 2` | `data-testid="cell-sopir-petugas"` |
| Badge status | badge | 3 varian terlihat | `Belum Berangkat` (abu), `Dalam Perjalanan` (biru muda), — | `data-testid="badge-status"` |
| Icon tambah petugas (inline) | button (icon person+) | enabled, muncul di sel status baris 2 | — | `data-testid="btn-tambah-petugas"` |
| Sel Tanggal Mulai Tracking | text | — | `15/07/2026` | `data-testid="cell-tgl-mulai-tracking"` |
| Dropdown action menu | menu | open (6 item) | — | `getByRole('menu')` / `data-testid="menu-row-action"` |
| Item Detail Penugasan | menuitem | enabled | `Detail Penugasan` | `getByRole('menuitem', { name: 'Detail Penugasan' })` |
| Item Edit Penugasan | menuitem | enabled | `Edit Penugasan` | `getByRole('menuitem', { name: 'Edit Penugasan' })` |
| Item Isi Data Tracking | menuitem | enabled | `Isi Data Tracking` | `getByRole('menuitem', { name: 'Isi Data Tracking' })` |
| Item Isi Kendala | menuitem | enabled | `Isi Kendala` | `getByRole('menuitem', { name: 'Isi Kendala' })` / `data-testid="menu-isi-kendala"` |
| Item Penugasan Sopir Bongkar | menuitem | enabled | `Penugasan Sopir Bongkar` | `getByRole('menuitem', { name: 'Penugasan Sopir Bongkar' })` / `data-testid="menu-penugasan-sopir-bongkar"` |
| Item Riwayat Perubahan | menuitem | enabled | `Riwayat Perubahan` | `getByRole('menuitem', { name: 'Riwayat Perubahan' })` |

**Data contoh:** ORD82090192 (LTL, Belum Berangkat); ORD76392092 (**LCL** pada versi ini — berbeda dari 127 yang FCL, Dalam Perjalanan); ORD62838963 (FCL, B 7289 TMX / Rizki • Yunita); ORD00986289 (**FCL**, BE 1739 AB, `- • Joko`); ORD19283005 (FTL, P 7872 UJ / M. Putra • Fahrizal); ORD0082636 (LTL, B 7930 HD, `- • Yunita +2`, 15/07/2026).

**Validasi/empty-state terlihat:** tidak ada; nilai `-` dipakai untuk sopir kosong (pola strip yang konsisten dengan REQ-074).

**Catatan perilaku:**
- Tanda `*` pada semua label filter bertentangan dengan REQ-017/REQ-019 (filter opsional) — lihat D-03.
- 2 item action menu tambahan (`Isi Kendala`, `Penugasan Sopir Bongkar`) di luar REQ-007 — lihat D-04.
- Kolom `Sopir • Petugas` dengan counter `+N` memperkenalkan konsep Petugas/PIC — lihat D-05.

---

### 140 — Penugasan Sopir Bongkar

Halaman penuh (bukan modal) untuk menugaskan armada & sopir bongkar pada order FCL Door to Door. Diakses dari action menu `Penugasan Sopir Bongkar` (139). Breadcrumb: `Beranda > Penugasan Tracking > Penugasan Sopir Bongkar`.

| Elemen | Tipe | State | Teks/label persis | Selector hint |
|---|---|---|---|---|
| Judul halaman | heading | — | `Penugasan Sopir Bongkar` | `getByRole('heading', { name: 'Penugasan Sopir Bongkar' })` |
| Ringkasan order | read-only list | terisi | `ID Order : ORD45672033`; `Jenis Pengiriman : FCL (Full Container Load)`; `Pelabuhan Asal : Kota Surabaya, Kab. Sidoarjo, Kab. Mojokerto`; `Pelabuhan Tujuan : Kota Semarang`; `Jenis Kontainer : 20 DRY`; `Metode Pengiriman : Door to Door` | `data-testid="ringkasan-order"` |
| No. Kontainer | read-only field | — | label `No. Kontainer`, nilai `CTN698383902` | `data-testid="detail-no-kontainer"` |
| No. Segel | read-only field | — | label `No. Segel`, nilai `SGL67930` | `data-testid="detail-no-segel"` |
| Mode Penugasan | read-only field | — | label `Mode Penugasan`, nilai `Tugaskan ke Sopir` | `data-testid="detail-mode-penugasan"` |
| Tanggal Permintaan Bongkar | datepicker (required) | empty | label `Tanggal Permintaan Bongkar *`, placeholder `DD/MM/YYYY hh:mm` | `getByLabel('Tanggal Permintaan Bongkar')` / `getByPlaceholder('DD/MM/YYYY hh:mm')` / `data-testid="date-tgl-permintaan-bongkar"` |
| Armada Bongkar — metode | radiogroup (required) | `Pilih Dari Master` **selected** | `Armada Bongkar *`, opsi `Pilih Dari Master` / `Isi Data Manual` | `getByRole('radio', { name: 'Pilih Dari Master' })` / `data-testid="radio-armada-bongkar-master"` |
| No. Polisi/Jenis Armada | select | empty | label `No. Polisi/Jenis Armada`, placeholder `Cari No. Polisi/Jenis Armada` | `getByLabel('No. Polisi/Jenis Armada')` / `data-testid="select-armada-bongkar"` |
| Sopir Bongkar — metode | radiogroup (required) | `Pilih Dari Master` **selected**; opsi `Isi Data Manual` tampak **disabled/abu** | `Sopir Bongkar *`, opsi `Pilih Dari Master` / `Isi Data Manual` | `getByRole('radio', { name: 'Isi Data Manual' })` / `data-testid="radio-sopir-bongkar-manual"` |
| Sopir/No. WhatsApp | select | empty | label `Sopir/No. WhatsApp`, placeholder `Cari Sopir/No. WhatsApp` | `getByLabel('Sopir/No. WhatsApp')` / `data-testid="select-sopir-bongkar"` |
| Tombol Batal | button (outline merah) | enabled | `Batal` | `getByRole('button', { name: 'Batal' })` / `data-testid="btn-batal"` |
| Tombol Simpan | button (primary) | enabled | `Simpan` | `getByRole('button', { name: 'Simpan' })` / `data-testid="btn-simpan"` |

**Validasi/empty-state terlihat:** tidak ada pesan error.

**Catatan perilaku:**
- Terdapat field wajib tambahan `Tanggal Permintaan Bongkar` yang tidak disebut REQ-064 (spec: hanya Nopol & Sopir) — lihat D-09.
- Halaman berdiri sendiri dengan breadcrumb kembali ke `Penugasan Tracking`, sedangkan REQ-066 mensyaratkan Batal kembali ke `Isi Data Tracking` — lihat D-10.
- Radio `Isi Data Manual` pada Sopir Bongkar dirender lebih redup (kemungkinan disabled) — perlu konfirmasi; bila disabled maka bertentangan dengan REQ-065.

---

### 143 — Tambah Penugasan FTL (1 armada, metode Pilih Dari Master)

Form Tambah Penugasan untuk order FTL multipickup (UF-02). Order terpilih = LKL903902399.

| Elemen | Tipe | State | Teks/label persis | Selector hint |
|---|---|---|---|---|
| Daftar order | radiogroup, scrollable | LKL903902399 **selected** | opsi: `LKL903901897` (LTL), `LKL903902398` (FCL, `Surabaya - Semarang • Engkel Bak`), `LKL903902399` (FTL, `Multipickup → Kota Semarang • Tronton Box`), `LKL903900010` (LCL) | `getByRole('radio', { name: /LKL903902399/ })` / `data-testid="opt-order-LKL903902399"` |
| Ringkasan order (auto-draft) | read-only list | terisi, read-only | `Kota Asal : Kota Surabaya, Kab. Sidoarjo, Kab. Mojokerto`; `Kota Tujuan : Kota Semarang`; `Jenis Armada : Tronton Box`; `Jumlah Armada : 1` | `data-testid="ringkasan-order"` |
| Card Armada 1 | section/card | — | `Armada 1` | `data-testid="card-armada-1"` |
| Armada — metode | radiogroup (required) | `Pilih Dari Master` **selected** | `Armada *`, opsi `Pilih Dari Master` / `Isi Data Manual` | `getByRole('radio', { name: 'Pilih Dari Master' })` / `data-testid="radio-armada-master-1"` |
| No. Polisi | select (master) | empty | label `No. Polisi`, placeholder `Cari No. Polisi/Jenis Armada` | `getByLabel('No. Polisi')` / `data-testid="select-no-polisi-1"` |
| Sopir — metode | radiogroup (required) | `Pilih Dari Master` **selected** | `Sopir *`, opsi `Pilih Dari Master` / `Isi Data Manual` | `data-testid="radio-sopir-master-1"` |
| Sopir | select (master) | empty | label `Sopir`, placeholder `Cari Sopir/No. WhatsApp` | `getByLabel('Sopir')` / `data-testid="select-sopir-1"` |
| Tombol Batal | button | enabled | `Batal` | `getByRole('button', { name: 'Batal' })` |
| Tombol Simpan | button | enabled | `Simpan` | `getByRole('button', { name: 'Simpan' })` |

**Validasi/empty-state terlihat:** tidak ada.

**Catatan perilaku:**
- Untuk FTL, ringkasan **tidak** menampilkan Pelabuhan Asal/Tujuan maupun Metode Pengiriman → mendukung REQ-069/REQ-075.
- Label section required adalah `Armada` dan `Sopir` (bukan `No. Polisi` seperti pada REQ-037) — lihat D-11.
- `Jumlah Armada : 1` → 1 card. Order multipickup ditandai `Multipickup →` pada opsi order.

---

### 144 — Tambah Penugasan FTL (metode Isi Data Manual)

Identik dengan 143, dengan kedua metode di-set ke `Isi Data Manual`.

| Elemen | Tipe | State | Teks/label persis | Selector hint |
|---|---|---|---|---|
| Armada — metode | radiogroup | `Isi Data Manual` **selected** | `Isi Data Manual` | `getByRole('radio', { name: 'Isi Data Manual' })` / `data-testid="radio-armada-manual-1"` |
| No. Polisi | input text | empty | label `No. Polisi`, placeholder `Masukkan No. Polisi` | `getByPlaceholder('Masukkan No. Polisi')` / `data-testid="input-no-polisi-1"` |
| Sopir — metode | radiogroup | `Isi Data Manual` **selected** | `Isi Data Manual` | `data-testid="radio-sopir-manual-1"` |
| Nama Sopir | input text | empty | label `Nama Sopir`, placeholder `Masukkan Nama Sopir` | `getByLabel('Nama Sopir')` / `data-testid="input-nama-sopir-1"` |
| No. WhatsApp | input text | empty, opsional | label `No. WhatsApp (opsional)`, placeholder `Masukkan No. WhatsApp` | `getByLabel('No. WhatsApp (opsional)')` / `data-testid="input-no-wa-sopir-1"` |

**Validasi/empty-state terlihat:** tidak ada.

**Catatan perilaku:** label `(opsional)` eksplisit pada No. WhatsApp → bukti visual REQ-032.

---

### 145 — Daftar Penugasan Tracking (kolom Status + Tanggal Mulai Tracking, filter versi lama)

Identik dengan 127 kecuali sub-header kolom Status yang menampilkan `Tanggal Mulai Tracking`. Panel filter masih versi 7 field tanpa tanda `*`.

| Elemen | Tipe | State | Teks/label persis | Selector hint |
|---|---|---|---|---|
| Header kolom Status | columnheader (2 baris) | — | `Status` / `Tanggal Mulai Tracking` | `data-testid="th-status-tgl-tracking"` |
| Filter (7 field) | lihat 127 | empty, tanpa `*` | `ID Order`, `Jenis Shipment`, `Kota Asal`, `Kota Tujuan`, `No. Polisi/No. Kontainer`, `Sopir`, `Status` | lihat 127 |
| Baris tabel & badge status | table row + badge | `Menunggu Proses`, `Selesai Muat`, `Selesai Bongkar`, `Dalam Perjalanan`, `Dibatalkan` | — | lihat 127 |

**Catatan perilaku:** sub-header `Tanggal Mulai Tracking` ada namun sel data tanggal tidak terisi pada baris manapun — kemungkinan kolom baru belum ter-populate di mockup.

---

### 146 — Detail Penugasan LTL (Informasi Penugasan dengan Metode Penugasan)

Varian 133a. Bagian `Informasi Penugasan` mengganti kolom `Riwayat Penugasan` dengan `Metode Penugasan`.

| Elemen | Tipe | State | Teks/label persis | Selector hint |
|---|---|---|---|---|
| Badge status halaman | badge | biru muda | `Dalam Perjalanan` | `data-testid="badge-status-penugasan"` |
| Detail Data Order | read-only group | expanded | `ID Order : LTL0152708249`, `Jenis Shipment : LTL (Less Than Truckload)`, `Kota Asal : Kota Surabaya, Kab. Sidoarjo, Kab. Mojokerto`, `Kota Tujuan : Kota Probolinggo`, `Tanggal Permintaan Muat : 31/05/2026 14:30`, `Jenis Armada : Tronton Wing Box`, `Kapasitas Armada : 5000 kg / 36 m³` | `data-testid="section-detail-data-order"` |
| No. Polisi | read-only field | — | `No. Polisi` / `GK6802BOX` | `data-testid="detail-no-polisi"` |
| Jenis Armada | read-only field | — | `Jenis Armada` / `Tronton Box` | `data-testid="detail-penugasan-jenis-armada"` |
| Metode Penugasan | read-only field | — | `Metode Penugasan` / `Tugaskan ke Sopir` | `data-testid="detail-metode-penugasan"` |
| Nama Sopir | read-only field | — | `Nama Sopir` / `Kenzo Nonoya` | `data-testid="detail-nama-sopir"` |
| No. WA Sopir | read-only field | — | `No. WA Sopir` / `082139240985` | `data-testid="detail-no-wa-sopir"` |
| Section History Tracking | accordion header | expanded (isi ter-crop) | `History Tracking` | `data-testid="section-history-tracking"` |

**Catatan perilaku:** `Metode Penugasan` (`Tugaskan ke Sopir`) adalah atribut baru yang tidak ada pada REQ-070 — lihat D-12. Pada layar ini link `Lihat Detail` Riwayat Penugasan tidak ditampilkan.

---

### 147 — Detail Penugasan FCL (Informasi Penugasan Muat & Bongkar terpisah)

Detail untuk order FCL berstatus `Belum Berangkat`, dengan tombol Edit di header dan dua section penugasan.

| Elemen | Tipe | State | Teks/label persis | Selector hint |
|---|---|---|---|---|
| Badge status halaman | badge | abu | `Belum Berangkat` | `data-testid="badge-status-penugasan"` |
| Tombol Edit Penugasan | button (outline biru, header kanan) | enabled | `Edit Penugasan` | `getByRole('button', { name: 'Edit Penugasan' })` / `data-testid="btn-edit-penugasan"` |
| Detail Data Order | read-only group | expanded | `ID Order : FCL0152708249`; `Jenis Shipment : FCL (Full Container Load)`; `Kota Asal : Kab. Sidoarjo, Kota Surabaya`; `Kota Tujuan : Kota Makassar`; `Pelabuhan Asal : Tanjung Perak (SUB)`; `Pelabuhan Tujuan : Maksassar (MAK)`; `Tanggal Permintaan Muat : 31/05/2026 14:30`; `Jenis Kontainer : 20 DRY`; `Kapasitas Kontainer : 5000 kg / 36 m³`; `Metode Pengiriman : Door to Door` | `data-testid="section-detail-data-order"` |
| Section Informasi Penugasan Muat | accordion header | expanded | `Informasi Penugasan Muat` | `getByRole('button', { name: 'Informasi Penugasan Muat' })` / `data-testid="section-penugasan-muat"` |
| Muat — No. Polisi | read-only field | — | `No. Polisi` / `GK6802BOX` | `data-testid="muat-no-polisi"` |
| Muat — Jenis Armada | read-only field | — | `Jenis Armada` / `Tronton Box` | `data-testid="muat-jenis-armada"` |
| Muat — Metode Penugasan | read-only field | — | `Metode Penugasan` / `Tugaskan ke Sopir` | `data-testid="muat-metode-penugasan"` |
| Muat — Nama Sopir | read-only field | — | `Nama Sopir` / `Kenzo Nonoya` | `data-testid="muat-nama-sopir"` |
| Muat — No. WA Sopir | read-only field | — | `No. WA Sopir` / `082139240985` | `data-testid="muat-no-wa-sopir"` |
| Muat — Riwayat Penugasan | link | enabled | `Riwayat Penugasan` / `Lihat Detail` | `getByRole('link', { name: 'Lihat Detail' })` / `data-testid="link-riwayat-penugasan-muat"` |
| Section Informasi Penugasan Bongkar | accordion header | expanded | `Informasi Penugasan Bongkar` | `getByRole('button', { name: 'Informasi Penugasan Bongkar' })` / `data-testid="section-penugasan-bongkar"` |
| Bongkar — No. Polisi | read-only field | — | `No. Polisi` / `GK6802BOX` | `data-testid="bongkar-no-polisi"` |
| Bongkar — Jenis Armada | read-only field | — | `Jenis Armada` / `Tronton Box` | `data-testid="bongkar-jenis-armada"` |
| Bongkar — Metode Penugasan | read-only field | — | `Metode Penugasan` / `Tugaskan ke Sopir` | `data-testid="bongkar-metode-penugasan"` |
| Bongkar — Nama Sopir | read-only field | — | `Nama Sopir` / `Bahlyl Lyla` | `data-testid="bongkar-nama-sopir"` |
| Bongkar — No. WA Sopir | read-only field | — | `No. WA Sopir` / `082139240985` | `data-testid="bongkar-no-wa-sopir"` |
| Bongkar — Tanggal Permintaan Bongkar | read-only field | — | `Tanggal Permintaan Bongkar` / `07/06/2026 13:30` | `data-testid="bongkar-tgl-permintaan"` |
| Section History Tracking | accordion header | expanded | `History Tracking` | `data-testid="section-history-tracking"` |
| Tab Per Tahapan | tab | **selected** | `Per Tahapan` | `getByRole('tab', { name: 'Per Tahapan' })` / `data-testid="tab-per-tahapan"` |
| Tab Timeline | tab | unselected | `Timeline` | `getByRole('tab', { name: 'Timeline' })` / `data-testid="tab-timeline"` |

**Catatan perilaku:**
- Untuk FCL, tab pertama History Tracking bernama `Per Tahapan` (vs `Per Lokasi` pada LTL di 133a) — selector harus per-jenis shipment.
- Tombol `Edit Penugasan` tampil di header hanya saat status `Belum Berangkat` (dukungan REQ-076–REQ-079).
- Typo pada data dummy: `Maksassar (MAK)`.

---

### 148 — Detail Penugasan FCL (Informasi Penugasan dengan sub-section Informasi Umum)

Varian struktur 147: satu section `Informasi Penugasan` yang memuat 3 sub-blok.

| Elemen | Tipe | State | Teks/label persis | Selector hint |
|---|---|---|---|---|
| Badge status halaman | badge | abu | `Belum Berangkat` | `data-testid="badge-status-penugasan"` |
| Tombol Edit Penugasan | button (outline) | enabled | `Edit Penugasan` | `getByRole('button', { name: 'Edit Penugasan' })` |
| Section Informasi Penugasan | accordion header | expanded | `Informasi Penugasan` | `data-testid="section-informasi-penugasan"` |
| Sub-heading Informasi Umum | heading | — | `Informasi Umum` | `getByRole('heading', { name: 'Informasi Umum' })` / `data-testid="subsection-informasi-umum"` |
| No. Kontainer | read-only field | — | `No. Kontainer` / `KTN5778290939` | `data-testid="detail-no-kontainer"` |
| No. Segel | read-only field | — | `No. Segel` / `SGL09892798232` | `data-testid="detail-no-segel"` |
| Sub-heading Penugasan Muat | heading | — | `Penugasan Muat` | `getByRole('heading', { name: 'Penugasan Muat' })` / `data-testid="subsection-penugasan-muat"` |
| Muat — No. Polisi / Jenis Armada / Metode Penugasan / Nama Sopir / No. WA Sopir | read-only fields | — | `GK6802BOX`, `Tronton Box`, `Tugaskan ke Sopir`, `Kenzo Nonoya`, `082139240985` | `data-testid="muat-*"` |
| Sub-heading Penugasan Bongkar | heading | — | `Penugasan Bongkar` | `getByRole('heading', { name: 'Penugasan Bongkar' })` / `data-testid="subsection-penugasan-bongkar"` |
| Bongkar — No. Polisi / Jenis Armada / Metode Penugasan / Nama Sopir / No. WA Sopir / Tanggal Permintaan Bongkar | read-only fields | — | `GK6802BOX`, `Tronton Box`, `Tugaskan ke Sopir`, `Bahlyl Lyla`, `082139240985`, `07/06/2026 13:30` | `data-testid="bongkar-*"` |
| Section History Tracking | accordion header | expanded (isi ter-crop) | `History Tracking` | `data-testid="section-history-tracking"` |

**Catatan perilaku:** pada varian ini **tidak ada** link `Lihat Detail` Riwayat Penugasan. 147 vs 148 adalah dua alternatif layout untuk layar yang sama — lihat D-13.

---

### 149 — Tambah/Edit Penugasan FCL (form terisi, order read-only, Direct)

Form penugasan FCL dengan seluruh field terisi dan bagian `Pilih Order` sudah berupa ringkasan read-only (bukan daftar radio). Struktur ini sesuai `Informasi Order` pada halaman Edit (REQ-075), meski judul halaman tertulis `Tambah Penugasan`.

| Elemen | Tipe | State | Teks/label persis | Selector hint |
|---|---|---|---|---|
| Judul halaman | heading | — | `Tambah Penugasan` | `getByRole('heading', { name: 'Tambah Penugasan' })` |
| Blok Pilih Order (read-only) | definition list | terisi, tidak ada search/radio | `Pilih Order *`; `ID Order : ORD6093390506`; `Vendor : SPS SF`; `Kota Asal : Kota Surabaya, Kab. Sidoarjo, Kab. Mojokerto`; `Kota Tujuan : Kota Makassar`; `Pelabuhan Asal : Tanjung Perak (SUB)`; `Pelabuhan Tujuan : Makassar (MAK)`; `Jenis Kontainer : 20 DRY`; `Jumlah Kontainer : 2`; `Metode Pengiriman : Door to Door` | `data-testid="informasi-order"` |
| Kontainer 1 — No. Kontainer | input text (required) | **filled**, enabled | label `No. Kontainer *`, value `1` | `getByLabel('No. Kontainer')` / `data-testid="input-no-kontainer-1"` |
| Kontainer 1 — No. Segel | input text (required) | filled, enabled | label `No. Segel *`, value `1` | `data-testid="input-no-segel-1"` |
| Kontainer 1 — Armada Muat | radiogroup | `Pilih Dari Master` selected | `Armada Muat *` | `data-testid="radio-armada-muat-master-1"` |
| Kontainer 1 — No. Polisi/Jenis Armada | select | filled | value `L54543 FDS - FUSO` | `getByLabel('No. Polisi/Jenis Armada')` / `data-testid="select-armada-muat-1"` |
| Kontainer 1 — Sopir/No. WhatsApp | select | filled | value `Alex - 62895397310385` | `getByLabel('Sopir/No. WhatsApp')` / `data-testid="select-sopir-muat-1"` |
| Kontainer 2 — No. Kontainer / No. Segel | input text | filled `2` / `2` | — | `data-testid="input-no-kontainer-2"` / `data-testid="input-no-segel-2"` |
| Kontainer 2 — No. Polisi/Jenis Armada | select | filled | value `L54544 FDS - FUSO` | `data-testid="select-armada-muat-2"` |
| Kontainer 2 — Sopir/No. WhatsApp | select | filled | value `Aldam - 62895397310211` | `data-testid="select-sopir-muat-2"` |
| Jenis Jadwal Kapal | radiogroup | `Direct` selected | `Jenis Jadwal Kapal *` | `getByRole('radio', { name: 'Direct' })` |
| Pelayaran | select | filled | value `Parade` | `getByLabel('Pelayaran')` |
| Nama Kapal | input text | filled | value `KM. Malboure` | `getByLabel('Nama Kapal')` |
| Voyage | input text | filled | value `2` | `getByLabel('Voyage')` |
| Closing Time | datepicker | filled | value `20/08/2026` | `getByLabel('Closing Time')` |
| Berangkat (ETD) | datepicker | filled | value `20/08/2026` | `getByLabel('Berangkat (ETD)')` |
| Tiba (ETA) | datepicker | filled | value `25/08/2026` | `getByLabel('Tiba (ETA)')` |
| Tombol Batal / Simpan | button | enabled | `Batal` / `Simpan` | `getByRole('button', { name: 'Simpan' })` |

**Catatan perilaku:** semua field kontainer & jadwal **enabled** pada state ini (status penugasan setara `Menunggu Proses`/`Belum Berangkat`) → baseline untuk REQ-077/REQ-078/REQ-079.

---

### 150 — Edit Penugasan FCL (No. Kontainer & No. Segel terkunci)

Varian 149 dengan hanya 1 card kontainer, dan field `No. Kontainer` & `No. Segel` dirender **abu/disabled**. Ini adalah bukti visual REQ-078.

| Elemen | Tipe | State | Teks/label persis | Selector hint |
|---|---|---|---|---|
| Blok Informasi Order | definition list read-only | terisi | `ID Order : ORD6093390506`; `Vendor : SPS SF`; `Kota Asal`, `Kota Tujuan`, `Pelabuhan Asal`, `Pelabuhan Tujuan`, `Jenis Kontainer : 20 DRY`, `Jumlah Kontainer : 2`, `Metode Pengiriman : Door to Door` | `data-testid="informasi-order"` |
| No. Kontainer | input text | **disabled** (bg abu, teks abu) | label `No. Kontainer *`, value `1` | `getByLabel('No. Kontainer')` → assert `toBeDisabled()` / `data-testid="input-no-kontainer-1"` |
| No. Segel | input text | **disabled** | label `No. Segel *`, value `1` | `getByLabel('No. Segel')` → assert `toBeDisabled()` / `data-testid="input-no-segel-1"` |
| Armada Muat / Sopir Muat | radiogroup + select | **enabled**, terisi `L54543 FDS - FUSO`, `Alex - 62895397310385` | `Armada Muat *`, `Sopir Muat *` | `data-testid="select-armada-muat-1"` |
| Jenis Jadwal Kapal | radiogroup | `Direct` selected, enabled | `Direct` / `Connecting` | `getByRole('radio', { name: 'Direct' })` |
| Detail Kapal Utama | fieldset | enabled, terisi (`Parade`, `KM. Malboure`, `2`, `20/08/2026`, `20/08/2026`, `25/08/2026`) | — | `data-testid="fieldset-kapal-utama"` |
| Tombol Batal / Simpan | button | enabled | `Batal` / `Simpan` | `getByRole('button', { name: 'Simpan' })` |

**Catatan perilaku:**
- Kombinasi state (No. Kontainer/No. Segel terkunci, armada & jadwal kapal masih editable) = status sudah lewat `Menunggu Proses` namun belum `Selesai Muat` → tepat mencerminkan REQ-077 + REQ-078 + REQ-079.
- `Jumlah Kontainer : 2` tetapi hanya 1 card kontainer dirender — inkonsistensi mockup vs REQ-029 (lihat D-14).

---

### pop-up — Detail Penugasan LTL (entry point Riwayat Penugasan sebagai text link)

State awal sebelum modal Riwayat Penugasan terbuka. Identik dengan 133a plus menu sidebar `Simulasi Muatan`.

| Elemen | Tipe | State | Teks/label persis | Selector hint |
|---|---|---|---|---|
| Riwayat Penugasan — pemicu | link (teks biru) | enabled | label `Riwayat Penugasan`, teks `Lihat Detail` | `getByRole('link', { name: 'Lihat Detail' })` / `data-testid="link-riwayat-penugasan"` |
| History Tracking | section + tabs | `Per Lokasi` selected | `Per Lokasi` / `Timeline` | `getByRole('tab', { name: 'Per Lokasi' })` |
| Kartu tahapan | card hijau | selesai | `Berangkat Muat • 31 Mei 2026, 04.29`, `PIC: Minul (6282139240985)`, `tes 1` | `data-testid="tracking-tahapan-card"` |

---

### pop-up-1 — Detail Penugasan LTL (pemicu Riwayat Penugasan sebagai tombol primary)

Varian visual dari `pop-up`: pemicu Riwayat Penugasan dirender sebagai tombol solid biru.

| Elemen | Tipe | State | Teks/label persis | Selector hint |
|---|---|---|---|---|
| Riwayat Penugasan — pemicu | button (primary solid) | enabled | label `Riwayat Penugasan`, tombol `Lihat Detail` | `getByRole('button', { name: 'Lihat Detail' })` / `data-testid="btn-riwayat-penugasan"` |

**Catatan perilaku:** karena pemicu punya 3 varian (text link / button solid / button outline), gunakan selector `getByRole('link').or(getByRole('button'))` dengan name `Lihat Detail`, atau `data-testid` tunggal `riwayat-penugasan-trigger` (lihat D-15).

---

### pop-up-2 — Modal Riwayat Penugasan (layout kartu / list)

Modal terbuka di atas halaman Detail Penugasan. Layout list dengan ikon per atribut, 2 entri.

| Elemen | Tipe | State | Teks/label persis | Selector hint |
|---|---|---|---|---|
| Modal | dialog | open, overlay gelap | — | `getByRole('dialog')` / `data-testid="modal-riwayat-penugasan"` |
| Judul modal | heading | — | `Riwayat Penugasan` | `getByRole('heading', { name: 'Riwayat Penugasan' })` |
| Tombol tutup | button (icon `×`) | enabled | — | `getByRole('button', { name: 'Tutup' })` / `data-testid="btn-close-modal"` |
| Entri — Tanggal Perubahan | label + value (icon jam) | — | `Tanggal Perubahan` / `16/04/2026 12:05` | `data-testid="riwayat-tanggal-perubahan"` |
| Entri — Armada | label + value (icon truk) | — | `Armada` / `L 6818 PLT • Tronton Box` | `data-testid="riwayat-armada"` |
| Entri — Sopir | label + value (icon orang) | — | `Sopir` / `Suwarna Warni • 0815678929332` | `data-testid="riwayat-sopir"` |
| Baris kedua | list item | duplikat data yang sama | `16/04/2026 12:05`, `L 6818 PLT • Tronton Box`, `Suwarna Warni • 0815678929332` | `data-testid="riwayat-row"` |
| Field di halaman belakang | read-only | terlihat | `Penugasan Sebelumnya` / tombol outline `Lihat Detail` | `data-testid="link-penugasan-sebelumnya"` |

**Catatan perilaku:** label pemicu berubah menjadi `Penugasan Sebelumnya` pada layar latar — penamaan ketiga untuk entitas yang sama (lihat D-15).

---

### pop-up-3 — Modal Riwayat Penugasan (layout tabel, dengan strip "-")

Layout alternatif modal: tabel dengan header kolom dan 4 baris riwayat. Bukti visual REQ-074.

| Elemen | Tipe | State | Teks/label persis | Selector hint |
|---|---|---|---|---|
| Modal | dialog | open | `Riwayat Penugasan` | `getByRole('dialog', { name: 'Riwayat Penugasan' })` / `data-testid="modal-riwayat-penugasan"` |
| Tombol tutup | button (icon `×`) | enabled | — | `getByRole('button', { name: 'Tutup' })` |
| Header kolom | columnheader (dengan ikon) | — | `Tanggal Perubahan` / `Armada` / `Sopir` | `getByRole('columnheader', { name: 'Tanggal Perubahan' })` / `data-testid="th-riwayat-tanggal"` |
| Baris 1 | row | — | `16/04/2026 12:05` \| `L 6818 PLT • Tronton Box` \| `Suwarna Warni • 0815678929332` | `getByRole('row', { name: /16\/04\/2026/ })` |
| Baris 2 | row | — | `12/08/2026 12:05` \| `L 6800 PLT • Wings Box` \| `Darmaji • 08156707028193` | — |
| Baris 3 | row | **perubahan parsial** | `11/09/2026 10:05` \| `L 1820 PLT • Tronton Box` \| `-` | `getByRole('row', { name: /11\/09\/2026/ }).getByText('-')` / `data-testid="riwayat-sopir-strip"` |
| Baris 4 | row | — | `10/09/2026 12:05` \| `L 1820 PLT • Tronton Box` \| `Aguswi • 08291836891002` | — |
| Pemicu di halaman belakang | link | enabled | `Penugasan Sebelumnya` / `Lihat Detail` | `data-testid="link-penugasan-sebelumnya"` |

**Pesan/empty-state:** strip `-` pada kolom Sopir baris 3 = data sopir tidak berubah → **bukti langsung REQ-074**.

**Catatan perilaku:**
- Urutan tanggal pada tabel tidak monoton (16/04, 12/08, 11/09, 10/09) → tidak dapat dipakai untuk memverifikasi sort riwayat.
- Modal tidak memiliki tombol footer (Tutup/OK); satu-satunya cara keluar adalah ikon `×` atau klik overlay.

---

### Pemetaan Layar → REQ

| Layar (file) | REQ yang tercakup | Catatan cakupan |
|---|---|---|
| `127-daftar-penugasan-tracking-ftl-ltl.png` | REQ-004, REQ-005, REQ-006, REQ-008, REQ-009 s.d. REQ-014, REQ-016, REQ-017, REQ-018, REQ-019, REQ-020, REQ-021, REQ-022, REQ-028 | REQ-015 (filter Tahap Pengiriman) **tidak ada** di desain |
| `128-action-menu-trucking.png` | REQ-007, REQ-080 | 4 item persis sesuai spec |
| `129-action-menu-container.png` | REQ-007, REQ-080 | idem, konteks FCL/LCL |
| `133a.png` | REQ-068, REQ-069, REQ-070, REQ-071, REQ-072 (pemicu) | Tahapan tracking bernama `Berangkat Muat` (≠ REQ-051) |
| `134.png` | REQ-023, REQ-024, REQ-025, REQ-026, REQ-027, REQ-028, REQ-029, REQ-031, REQ-035, REQ-036, REQ-039, REQ-040, REQ-041, REQ-042, REQ-043, REQ-045, REQ-046, REQ-047 | — |
| `135.png` | REQ-030 (LCL 1 card, via opsi order), REQ-032, REQ-046, REQ-048, REQ-049 (field ETD Connecting) | Pesan error REQ-049 tidak digambar |
| `136.png` | REQ-032, REQ-044 (kondisi Door-CY tetap tampil), REQ-046, REQ-048 | — |
| `137.png` | REQ-039, REQ-040, REQ-044 (CY-Door: tanpa nopol/armada), REQ-046, REQ-048 | Komponen `Pilih PIC Penugasan` di luar spec |
| `139.png` | REQ-004 s.d. REQ-008, REQ-016 s.d. REQ-019, REQ-020, REQ-021, REQ-064 (entry point) | 2 menu tambahan & filter tanggal di luar spec; label filter bertanda `*` |
| `140.png` | REQ-064, REQ-065, REQ-066 (tombol Batal), REQ-067 (kondisi metode) | Field `Tanggal Permintaan Bongkar` di luar REQ-064 |
| `143.png` | REQ-023 s.d. REQ-029, REQ-031, REQ-033, REQ-037, REQ-038, REQ-035, REQ-036 | Label `Armada`/`Sopir` (≠ `No. Polisi`) |
| `144.png` | REQ-032, REQ-037, REQ-038 | `No. WhatsApp (opsional)` eksplisit |
| `145.png` | REQ-004, REQ-005, REQ-006, REQ-009 s.d. REQ-014, REQ-016 s.d. REQ-019 | Sub-header `Tanggal Mulai Tracking` |
| `146.png` | REQ-068, REQ-069, REQ-070, REQ-071 | `Metode Penugasan` di luar REQ-070 |
| `147.png` | REQ-068, REQ-069 (varian FCL), REQ-070, REQ-071, REQ-072 (pemicu), REQ-064 (data bongkar) | Section penugasan dipisah Muat/Bongkar |
| `148.png` | REQ-068, REQ-069, REQ-070, REQ-071 | Varian layout sub-section |
| `149.png` | REQ-075, REQ-045, REQ-046, REQ-047, REQ-036, REQ-035 | State semua field editable |
| `150.png` | REQ-075, REQ-077, REQ-078, REQ-079 | Bukti visual field terkunci |
| `pop-up.png` | REQ-070, REQ-071, REQ-072 | Pemicu = text link |
| `pop-up-1.png` | REQ-070, REQ-072 | Pemicu = button primary |
| `pop-up-2.png` | REQ-072, REQ-073 | Layout kartu |
| `pop-up-3.png` | REQ-072, REQ-073, REQ-074, REQ-080 | Layout tabel + strip `-` |
| **Tidak ada desain** | REQ-001, REQ-002, REQ-003, REQ-015, REQ-034, REQ-050 s.d. REQ-063 | Gap desain terbesar: **seluruh halaman Isi Data Tracking** dan state error validasi |

---

## Assumptions Log

| # | Area | Ambiguitas pada Spec | Keputusan (AUTO MODE) | Alasan |
|---|---|---|---|---|
| A-01 | Nilai Status | Spec menyebut dua set nilai status berbeda: kolom tabel menyebut "Menunggu Proses / Selesai Muat / Selesai Bongkar / Dibatalkan", sedangkan bagian "Status" menyebut "Belum Berangkat / Dalam Perjalanan / Selesai". | Bagian "Status" (Belum Berangkat / Dalam Perjalanan / Selesai) diperlakukan sebagai **sumber kebenaran** untuk nilai status yang ditampilkan; daftar pada kolom tabel diperlakukan sebagai penamaan lama/tahap pengiriman. "Menunggu Proses" dianggap ekuivalen dengan "Belum Berangkat" (dipakai pada aturan edit REQ-078). | Bagian "Status" merupakan section khusus yang mendefinisikan status secara eksplisit beserta maknanya, sehingga lebih otoritatif. |
| A-02 | Status "Dibatalkan" | Status "Dibatalkan" muncul di kolom tabel namun tidak dijelaskan pada bagian Status maupun ada flow pembatalan penugasan. | Status "Dibatalkan" **tidak** dimasukkan sebagai requirement transisi status; hanya dicatat sebagai kemungkinan nilai tampilan. Tidak ada REQ khusus untuk pembatalan penugasan. | Tidak ada aturan/flow pendukung di spec; membuat REQ tanpa dasar berisiko menghasilkan skenario uji yang salah. |
| A-03 | Penomoran spec | Section "Tambah Penugasan (Ketentuan Umum)" melompat dari poin 2 ke poin 4 (tidak ada poin 3). | Diasumsikan sebagai typo penomoran; tidak ada requirement yang hilang. Seluruh poin yang tertulis tetap diekstrak. | Tidak ada indikasi konten yang terpotong selain penomoran. |
| A-04 | Filter Tahap Pengiriman multi pick-up | Contoh poin 2c pada section Filter terpotong ("contoh: jika multi pick up --> ID order 123"). | Diasumsikan perilaku sama dengan contoh 2b: order multi pick-up akan tampil pada filter tahap pengiriman jika salah satu pick-up sudah mencapai tahap tersebut. | Konsisten dengan logika "menampilkan order yang sudah update tahap pengiriman". |
| A-05 | Kolom Status pada Edit FCL/LCL | Spec menyatakan No. Kontainer & No. Segel dapat diubah "sampai status menunggu proses", namun juga menyatakan bisa diubah saat update Selesai Muat (section Isi Data Tracking 3a). | Dua aturan diperlakukan berdampingan: pembatasan "sampai Menunggu Proses" berlaku pada **halaman Edit Penugasan**, sedangkan perubahan saat Selesai Muat berlaku pada **form Isi Data Tracking**. | Kedua aturan berada pada konteks halaman yang berbeda sehingga tidak saling bertentangan. |
| A-06 | Sopir pada aturan Edit FTL/LTL | Spec hanya menyebut "bisa ubah nopol/armada sampai status selesai muat", tidak menyebut sopir secara eksplisit. | Diasumsikan Sopir mengikuti aturan yang sama dengan nopol/armada (dapat diubah sampai status Selesai Muat). | Riwayat Penugasan (REQ-073) mencatat perubahan sopir, sehingga sopir memang dapat diubah; batas waktunya paling logis mengikuti nopol/armada. |
| A-07 | Sumber jumlah card kontainer | Spec menyebut "Jumlah card input Armada/Kontainer mengikuti Jumlah Armada/Kontainer pada order". | Diasumsikan berlaku untuk kedua jenis (armada untuk FTL, kontainer untuk FCL), dengan pengecualian LTL/LCL selalu 1 card. | Penulisan "Armada/Kontainer" secara eksplisit mencakup keduanya. |
| A-08 | Kombinasi filter | Spec tidak menyatakan apakah kombinasi beberapa filter bersifat AND atau OR. | Diasumsikan **AND** (data harus memenuhi seluruh kriteria yang diisi). | Pola standar filter tabel pada sistem sejenis. |
| A-09 | Konten "History Tracking" | Spec hanya menyebut judul bagian "History Tracking" tanpa detail field. | Diasumsikan menampilkan riwayat tahap tracking yang telah diisi (tahap, tanggal/waktu, foto, keterangan) sesuai data yang di-input pada Isi Data Tracking. | Sumber data satu-satunya untuk tracking adalah form Isi Data Tracking. |
| A-10 | Aksi "Riwayat Perubahan" pada daftar | Spec mencantumkan action menu "Riwayat Perubahan" tanpa penjelasan terpisah. | Diasumsikan menampilkan konten yang sama dengan "Riwayat Penugasan" pada halaman Detail (REQ-072 s.d. REQ-074). | Keduanya merujuk pada riwayat perubahan data armada/sopir; tidak ada indikasi entitas riwayat lain. |
| A-11 | Format & validasi format field bebas | Spec tidak mendefinisikan panjang min/maks maupun pola untuk No. Polisi, No. Kontainer, No. Segel, nama Sopir, dan No. WhatsApp. | Tidak dibuat requirement panjang/format spesifik; hanya aturan **required/optional** yang ditegakkan. Validasi format diserahkan ke standar sistem. | Menambahkan batasan yang tidak ada di spec dapat menghasilkan skenario uji yang tidak valid. |
| A-12 | Konfirmasi pada Edit Penugasan | Spec tidak menyebut tombol/konfirmasi pada halaman Edit Penugasan. | Diasumsikan pola tombol sama dengan Tambah Penugasan: Batal (dengan alert konfirmasi) dan Simpan (dengan konfirmasi + notifikasi). | Konsistensi antar halaman pada modul yang sama. |
| A-13 | Field "Data Kapal Connecting" | Spec terpotong pada deskripsi field ("dapat lebih dari 1 baris" tanpa penutup) dan tidak merinci atribut per baris. | Diasumsikan minimal memuat nama/jadwal kapal connecting beserta ETD dan ETA agar validasi REQ-049 dapat dijalankan. | Validasi ETD Connecting vs ETA kapal utama mensyaratkan adanya field ETD pada baris connecting. |
| A-14 | Metode Pengiriman Door-Door | Section Tambah Penugasan menyebut pengecualian untuk CY-Door dan CY-CY; section Isi Data Tracking menyebut CY-Door dan Door-Door untuk sopir bongkar. | Diasumsikan terdapat 4 metode pengiriman FCL/LCL: Door-Door, Door-CY, CY-Door, CY-CY. Aturan diterapkan tepat sesuai metode yang disebut pada masing-masing section. | Kombinasi lengkap dari terminologi yang muncul di spec. |
| A-15 | Transisi status pada multi-drop | Spec tidak menjelaskan kapan status menjadi "Selesai" pada order multi-drop. | Diasumsikan status menjadi "Selesai" setelah seluruh kota drop menyelesaikan tahap Selesai Bongkar. | Konsisten dengan REQ-060 ("lanjut ke tahap berikutnya hingga selesai") dan REQ-062 (auto-minimize per kota). |
| D-01 | Filter "Tahap Pengiriman" tidak ada di desain | REQ-015 mensyaratkan filter "Tahap Pengiriman", namun tidak satu pun desain daftar (127, 139, 145) menampilkannya. Layar 139 justru menampilkan filter `Tanggal Mulai Tracking`. | Filter Tahap Pengiriman tetap diuji sebagai requirement (spec = sumber kebenaran fungsional), dengan selector usulan `getByLabel('Tahap Pengiriman')` / `data-testid="filter-tahap-pengiriman"`. Filter `Tanggal Mulai Tracking` dicatat sebagai elemen tambahan desain dan diuji terpisah bila diimplementasi. | Spec bersifat kontraktual; ketidakhadiran di mockup lebih mungkin karena mockup belum diperbarui daripada requirement dibatalkan. Ditandai sebagai discrepancy untuk klarifikasi. |
| D-02 | Nilai badge Status pada desain | Desain 127/145 menampilkan `Menunggu Proses`, `Selesai Muat`, `Selesai Bongkar`, `Dalam Perjalanan`, `Dibatalkan`; desain 139 menampilkan `Belum Berangkat` dan `Dalam Perjalanan`. Campuran dua set penamaan (lih. A-01). | Untuk assertion UI, badge status diuji dengan pola regex yang menerima kedua penamaan pada tahap yang setara: `Belum Berangkat|Menunggu Proses`, `Dalam Perjalanan|Selesai Muat`, `Selesai|Selesai Bongkar`. Warna badge dicatat sebagai atribut sekunder (abu / biru / kuning / hijau / merah). | Menghindari test brittle sebelum penamaan final dikonfirmasi, sambil tetap menegakkan REQ-020 s.d. REQ-022. |
| D-03 | Tanda required `*` pada label filter (139) | Semua label filter pada layar 139 diberi asterisk merah, padahal REQ-017/REQ-019 menyatakan filter opsional dan default kosong. | Diasumsikan **error styling desain**. Perilaku yang diuji tetap: filter opsional, tombol `Terapkan` dapat diklik tanpa mengisi field apa pun, dan filter kosong diabaikan. | Bertentangan langsung dengan requirement eksplisit; tidak ada pesan validasi required yang digambar pada panel filter. |
| D-04 | Action menu 6 item pada layar 139 | Desain 139 menambahkan `Isi Kendala` dan `Penugasan Sopir Bongkar` ke action menu, sementara REQ-007 hanya menyebut 4 item (dan 128/129 menampilkan 4 item). | Kedua item tambahan dicatat sebagai elemen UI yang ada di desain namun **belum ber-requirement**. Test coverage utama tetap pada 4 item REQ-007; keberadaan item ekstra diuji sebagai smoke check saja (tidak sebagai assertion "menu berisi tepat 4 item"). | Menghindari test gagal karena elemen sah yang belum terdokumentasi di spec; sekaligus menandai kebutuhan requirement baru. |
| D-05 | Konsep "Petugas" / "PIC Penugasan" | Layar 137 memuat komponen `Pilih PIC Penugasan` (multi-select, required, dengan info "PIC akan menerima notifikasi..."), layar 139 memuat kolom `Sopir • Petugas` dengan counter `+N` dan filter `Sopir/Petugas`, dan layar 133a/pop-up memuat `PIC: Minul (...)` pada kartu tahapan. Tidak ada requirement apa pun tentang PIC/Petugas. | Fitur PIC/Petugas didokumentasikan penuh pada UI Inventory namun **tidak diturunkan menjadi REQ**. Diusulkan sebagai kandidat requirement baru untuk klarifikasi ke BA. Test hanya melakukan verifikasi keberadaan elemen, bukan aturan bisnisnya. | Fitur ini punya aturan bisnis (required, notifikasi, hak kelola tracking) yang tidak dapat direka-reka tanpa sumber. |
| D-06 | Penamaan tahap pada History Tracking | REQ-051 menyatakan OMS hanya meng-update `Selesai Muat` dan `Selesai Bongkar`, tetapi kartu tahapan pada desain menampilkan `Berangkat Muat`. Tab juga berbeda antar jenis shipment (`Per Lokasi` untuk LTL, `Per Tahapan` untuk FCL). | Diasumsikan History Tracking menampilkan **seluruh** tahap perjalanan (termasuk yang berasal dari sumber lain seperti Driver Hub), sedangkan form input OMS tetap terbatas pada 2 tahap sesuai REQ-051. Assertion tahap menggunakan pencocokan parsial, bukan daftar tertutup. | Menampilkan (read) dan mengisi (write) adalah dua kapabilitas berbeda; membatasi tampilan ke 2 tahap akan membuat test gagal pada data nyata. |
| D-07 | Tidak ada desain untuk state error/validasi | REQ-034 (helper error + border error), REQ-049 (error ETD Connecting), REQ-056/REQ-057 (required tanggal & foto), dan REQ-058 (alert batas foto) tidak memiliki mockup. Tidak ada pula desain empty-state tabel. | Selector untuk pesan error distandarkan secara generik: `getByRole('alert')` untuk alert/toast, dan helper error per field dengan `data-testid="<field-testid>-error"`. Empty-state tabel diasumsikan `data-testid="tabel-penugasan-empty-state"`. Teks pesan **tidak** di-assert secara literal. | Tanpa mockup, teks pesan tidak dapat dipastikan; assertion difokuskan pada keberadaan error dan blokir penyimpanan. |
| D-08 | Label ringkasan order tidak konsisten | Layar 135 & 136 memberi label `Pelabuhan Asal` / `Pelabuhan Tujuan` pada nilai yang jelas berupa nama kota (`Kota Surabaya, Kab. Sidoarjo, Kab. Mojokerto` / `Kota Semarang`), dan `Jenis Kontainer : Tronton Box` (nilai jenis armada). Layar 134/149/150 memakai label yang benar. | Diperlakukan sebagai **bug label pada mockup**. Label yang dijadikan acuan test adalah versi 134/149/150 (`Kota Asal`, `Kota Tujuan`, `Pelabuhan Asal`, `Pelabuhan Tujuan`, `Jenis Kontainer`) sesuai REQ-075. | REQ-075 mendefinisikan daftar field Informasi Order secara eksplisit; versi 134/149/150 konsisten dengannya. |
| D-09 | Field `Tanggal Permintaan Bongkar` pada Penugasan Sopir Bongkar | REQ-064 menyatakan "field yang perlu diisi hanya Nopol dan Sopir", namun layar 140 menambahkan `Tanggal Permintaan Bongkar *` (required, format `DD/MM/YYYY hh:mm`) dan menampilkan `Mode Penugasan` read-only. | Field `Tanggal Permintaan Bongkar` dimasukkan ke UI Inventory sebagai field required yang terlihat, dan ditandai sebagai discrepancy. Skenario "simpan tanpa tanggal → error required" ditulis sebagai skenario kandidat (bertanda perlu konfirmasi), bukan skenario wajib. | Desain lebih baru dan konkret; namun bertentangan dengan kata "hanya" pada spec sehingga perlu keputusan BA. |
| D-10 | Entry point & navigasi Penugasan Sopir Bongkar | REQ-064/REQ-066 memposisikan penugasan sopir bongkar sebagai bagian dari alur **Isi Data Tracking** (tahap Selesai Bongkar), dengan Batal kembali ke Isi Data Tracking. Desain menempatkannya sebagai **halaman mandiri** yang diakses dari action menu daftar (139) dengan breadcrumb `Beranda > Penugasan Tracking > Penugasan Sopir Bongkar`. | Kedua entry point diperlakukan valid: (a) dari action menu daftar → Batal kembali ke daftar Penugasan Tracking; (b) dari form Selesai Bongkar → Batal kembali ke Isi Data Tracking (REQ-066 tetap ditegakkan sebagai skenario kritikal). | REQ-066 ditekankan berulang di spec sehingga tidak boleh digugurkan; sementara halaman mandiri jelas ada di desain. |
| D-11 | Label field FTL: `Armada`/`Sopir` vs `No. Polisi` | REQ-037 menamai field sebagai `No. Polisi`, sedangkan desain 143/144 memakai label group `Armada *` dan `Sopir *` dengan sub-label `No. Polisi` / `Nama Sopir`. Pada FCL desain memakai `Armada Muat *` / `Sopir Muat *`. | Selector utama menggunakan sub-label yang lebih spesifik (`getByLabel('No. Polisi')`, `getByLabel('Nama Sopir')`) karena itulah yang menempel pada input; label group dipakai untuk memilih radio metode (`Armada` / `Sopir` / `Armada Muat` / `Sopir Muat`). | Sub-label adalah `<label>` aktual dari input; label group hanya judul fieldset. |
| D-12 | Field `Metode Penugasan` pada Detail Penugasan | Layar 146/147/148 menampilkan `Metode Penugasan : Tugaskan ke Sopir` yang tidak tercantum pada REQ-070. | Dicatat sebagai field read-only tambahan pada Informasi Penugasan; hanya diverifikasi keberadaannya (bukan aturan nilainya). Nilai lain dari enum ini tidak diketahui. | Tidak ada sumber untuk daftar nilai `Metode Penugasan` selain satu contoh. |
| D-13 | Dua varian layout Detail Penugasan FCL | Layar 147 memakai dua section terpisah (`Informasi Penugasan Muat`, `Informasi Penugasan Bongkar`); layar 148 memakai satu section `Informasi Penugasan` dengan sub-heading `Informasi Umum` / `Penugasan Muat` / `Penugasan Bongkar`. Layar 147 punya link Riwayat Penugasan, 148 tidak. | Varian **148** dijadikan acuan primer (lebih lengkap: memuat No. Kontainer & No. Segel di `Informasi Umum`). Selector ditulis berbasis label field (bukan struktur section) agar tahan terhadap kedua layout. | Menghindari test yang bergantung pada hierarki DOM yang belum final. |
| D-14 | Jumlah card kontainer pada layar 150 | Ringkasan menyatakan `Jumlah Kontainer : 2` namun hanya 1 card `Kontainer 1` dirender (layar 149 dengan data order sama merender 2 card). | Diperlakukan sebagai **crop/penyederhanaan mockup**, bukan aturan bisnis. REQ-029 (jumlah card = jumlah kontainer) tetap ditegakkan pada test. | Layar 149 dengan order identik menampilkan 2 card, membuktikan aturan REQ-029 berlaku. |
| D-15 | Tiga varian pemicu "Riwayat Penugasan" | Pemicu modal muncul sebagai: text link `Lihat Detail` (133a, 147, pop-up, pop-up-3), button primary solid `Lihat Detail` (pop-up-1), dan button outline dengan label field `Penugasan Sebelumnya` (pop-up-2). | Selector distandarkan ke satu `data-testid="riwayat-penugasan-trigger"`, dengan fallback role-agnostic `getByText('Lihat Detail')` di dalam scope section Informasi Penugasan. Label field diuji dengan regex `Riwayat Penugasan|Penugasan Sebelumnya`. | Ketiga varian adalah eksplorasi desain untuk elemen yang sama; test tidak boleh terikat pada satu varian. |
| D-16 | Judul halaman pada layar 149/150 | Kedua layar berjudul `Tambah Penugasan` namun strukturnya (order read-only tanpa search/radio, field terisi, field terkunci) sesuai halaman **Edit Penugasan** (REQ-075 s.d. REQ-079). | Layar 149 & 150 diperlakukan sebagai desain **Edit Penugasan** untuk keperluan pemetaan REQ; judul `Tambah Penugasan` dianggap salah pada mockup. Test Edit tetap meng-assert heading `Edit Penugasan`. | Blok `Pilih Order` read-only dengan field `Vendor` adalah definisi persis `Informasi Order` pada REQ-075 yang hanya berlaku di halaman Edit. |
| D-17 | Tidak ada desain halaman Isi Data Tracking | REQ-050 s.d. REQ-063 (form per kota drop, pilih alamat, tanggal, upload foto max 6 / 4 MB, keterangan, tombol Simpan & Kembali, auto-minimize) sama sekali tidak memiliki mockup pada 22 file yang tersedia. | UI Inventory untuk halaman ini **tidak diturunkan**; selector untuk skenario Isi Data Tracking harus memakai `data-testid` usulan (`form-tracking-<kota>`, `date-selesai-muat`, `upload-foto-tracking`, `textarea-keterangan`, `btn-simpan-tracking`, `btn-kembali-tracking`) dan ditandai sebagai asumsi. | Menebak struktur UI dari spec saja berisiko menghasilkan selector yang salah; lebih baik ditandai eksplisit sebagai gap desain. |
| D-18 | Menu `Simulasi Muatan` pada sidebar | Menu `Simulasi Muatan` hanya muncul pada 4 file `pop-up*.png`, tidak pada 18 file lainnya. | Diasumsikan menu tersebut milik rilis berbeda / feature flag, dan **tidak** dijadikan bagian dari assertion navigasi modul OMS017. | Di luar cakupan modul Penugasan Tracking. |
| D-19 | Inkonsistensi data dummy pagination | Info `Menampilkan 1 - 20 data dari 30 data` tidak konsisten dengan kontrol pagination yang menampilkan hingga halaman `12`. | Diperlakukan sebagai data dummy. Test pagination memverifikasi **relasi** (jumlah halaman = ceil(total/page size)) berdasarkan data uji nyata, bukan angka pada mockup. | Angka pada mockup tidak dapat dijadikan expected value. |
| D-20 | Format tanggal ETD/ETA & Closing Time | REQ-056 menetapkan format `DD/MM/YYYY HH:mm` untuk tanggal tracking. Desain 134/135/136/149/150 memakai placeholder `DD/MM/YYYY` (tanpa jam) untuk Closing Time/ETD/ETA, sedangkan 140 memakai `DD/MM/YYYY hh:mm` untuk Tanggal Permintaan Bongkar. | Diasumsikan dua format berbeda memang disengaja: field **jadwal kapal** = tanggal saja (`DD/MM/YYYY`); field **tanggal tracking / permintaan bongkar** = tanggal + jam (`DD/MM/YYYY HH:mm`). REQ-056 hanya mengikat field tracking. | REQ-056 secara eksplisit hanya membahas "tanggal selesai muat/bongkar", bukan jadwal kapal. |
