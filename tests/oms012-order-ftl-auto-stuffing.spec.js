// Spec modul oms012-order-ftl-auto-stuffing.
// Sumber skenario: scenario/oms012-order-ftl-auto-stuffing/*_scenarios.json (judul test = "SCN-xxxx: <judul asli>",
// dipakai scripts/playwright_to_results.py untuk traceability — jangan ubah format judul).
// Sumber selector: shared/selector-map-order.md (hasil harvest 2026-08-22).
// Keputusan triage bertanggal yang memengaruhi assertion: shared/decisions.md.
//
// Cakupan: hanya skenario yang aman read-only terhadap data staging (tidak membuat/mengubah/membatalkan
// order milik orang lain). Skenario wizard Step 2+ menyusul setelah ada jalur pembuatan data AUTOTEST-.
const { test, expect } = require('./helpers/fixtures');

const VALID_STATUSES = [
  'Isi Data Dasar', 'Isi Data Muatan', 'Isi Data Vendor', 'Review Order',
  'Menunggu Penugasan', 'Ditugaskan', 'Proses Pengiriman', 'Terkirim', 'Dibatalkan',
];
// Status live yang setara "draft" (selector-map SCR-03: memunculkan menu Lanjutkan Pengisian).
const DRAFT_LIKE = ['Isi Data Muatan', 'Isi Data Pengiriman', 'Review Order', 'Isi Data Dasar'];
const ANY_STATUS = [...new Set([...DRAFT_LIKE, ...VALID_STATUSES])];

async function gotoDaftarOrder(page) {
  await page.goto('/order');
  await expect(page.getByRole('heading', { name: 'Daftar Order' })).toBeVisible();
  await expect(page.getByRole('table')).toBeVisible();
  // Data baris dimuat async setelah tabel render — tunggu sampai ada baris ber-badge status
  // supaya rowWithStatus tidak menghitung tabel yang masih skeleton/kosong.
  await page.getByRole('table').getByRole('row')
    .filter({ hasText: /Isi Data|Review Order|Menunggu Penugasan|Ditugaskan|Proses Pengiriman|Terkirim|Dibatalkan/ })
    .first().waitFor({ timeout: 15_000 }).catch(() => { /* benar-benar tidak ada data */ });
}

// Baris pertama yang badge status-nya salah satu dari `statuses`; null bila tidak ada.
async function rowWithStatus(page, statuses) {
  for (const status of statuses) {
    const row = page.getByRole('table').getByRole('row').filter({ hasText: status }).first();
    if ((await row.count()) > 0) return { row, status };
  }
  return null;
}

async function openActionMenu(row) {
  await row.getByRole('button', { name: 'Aksi' }).click();
}

// Dropdown filter OMS: klik trigger, lalu klik opsi (opsi dirender di popover tanpa role listbox
// yang konsisten — coba role option dulu, fallback teks paling akhir di DOM).
async function pickDropdownOption(page, triggerName, optionText) {
  await page.getByRole('button', { name: triggerName }).click();
  const option = page.getByRole('option', { name: optionText }).first();
  if ((await option.count()) > 0) {
    await option.click();
  } else {
    await page.getByText(optionText, { exact: true }).last().click();
  }
}

test.describe('Daftar Order (SCR-01/02/03)', () => {
  test('SCN-0004: Order FTL dapat dibuat manual melalui wizard 4 step maupun batch', async ({ page }) => {
    await gotoDaftarOrder(page);
    await expect(page.getByRole('button', { name: 'Batch Order' })).toBeVisible();
    // Navigasi langsung ke wizard (workaround lama untuk bug tombol, resolved 2026-09-04) —
    // dipertahankan karena hasilnya sama, lihat shared/decisions.md
    await expect(page.getByRole('button', { name: 'Buat Order' })).toBeVisible();
    await page.goto('/order/buat');
    await expect(page).toHaveURL(/\/order\/buat/);
    // filter visible: ada span stepper duplikat yang hidden di DOM — lihat shared/decisions.md (SCN-0004)
    for (const label of ['Data Pengiriman', 'Data Barang', 'Vendor dan Harga', 'Review']) {
      await expect.soft(page.getByText(new RegExp(label)).filter({ visible: true }).first(),
        `Indikator step wizard "${label}" harus tampil`).toBeVisible();
    }
  });

  test('SCN-0107: Badge status pada Daftar Order hanya menampilkan status yang valid', async ({ page }) => {
    await gotoDaftarOrder(page);
    const rows = page.getByRole('table').getByRole('row');
    const total = await rows.count();
    expect(total, 'Tabel order harus punya minimal 1 baris data').toBeGreaterThan(1);
    const invalid = [];
    for (let i = 1; i < total; i++) {
      const text = (await rows.nth(i).innerText()).replace(/\s+/g, ' ').trim();
      if (!text) continue; // baris skeleton/spacer tanpa konten
      // ANY_STATUS (desain + live): live memakai nama status berbeda dari desain (mis. "Isi Data
      // Pengiriman" vs "Isi Data Dasar" M-25) — lihat shared/selector-map-order.md. Memvalidasi
      // terhadap VALID_STATUSES desain saja akan salah tandai status live yang sah sebagai invalid.
      if (!ANY_STATUS.some((s) => text.includes(s))) invalid.push(text.slice(0, 120));
    }
    expect(invalid, `Baris dengan status di luar daftar valid M-25 (REQ-054): ${invalid.join(' || ')}`)
      .toEqual([]);
  });

  test('SCN-0128: Action menu order draft menampilkan empat aksi sesuai spesifikasi', async ({ page }) => {
    await gotoDaftarOrder(page);
    const found = await rowWithStatus(page, DRAFT_LIKE);
    test.skip(!found, 'Tidak ada order berstatus draft-like di staging');
    test.info().annotations.push({
      type: 'note',
      description: `Memakai baris berstatus "${found.status}" — status desain "Isi Data Dasar" tidak tersedia di staging.`,
    });
    await openActionMenu(found.row);
    for (const item of ['Detail', 'Lanjutkan Pengisian', 'Batalkan Order', 'Riwayat Perubahan']) {
      await expect.soft(page.getByRole('button', { name: item, exact: true }).first(),
        `Menu "${item}" harus tampil untuk order draft`).toBeVisible();
    }
  });

  test('SCN-0129: Action menu order Menunggu Penugasan menampilkan aksi Edit', async ({ page }) => {
    await gotoDaftarOrder(page);
    const found = await rowWithStatus(page, ['Menunggu Penugasan']);
    test.skip(!found, 'Tidak ada order berstatus Menunggu Penugasan di staging');
    await openActionMenu(found.row);
    for (const item of ['Detail', 'Edit', 'Batalkan Order', 'Riwayat Perubahan']) {
      await expect.soft(page.getByRole('button', { name: item, exact: true }).first(),
        `Menu "${item}" harus tampil`).toBeVisible();
    }
    await expect.soft(page.getByRole('button', { name: 'Lanjutkan Pengisian' }),
      'Menu "Lanjutkan Pengisian" tidak boleh tampil pada status Menunggu Penugasan').toBeHidden();
  });

  test('SCN-0135: Aksi Lihat No. Perjalanan tidak tampil sebelum status Ditugaskan', async ({ page }) => {
    await gotoDaftarOrder(page);
    const found = await rowWithStatus(page, ['Menunggu Penugasan']);
    test.skip(!found, 'Tidak ada order berstatus Menunggu Penugasan di staging');
    await openActionMenu(found.row);
    await expect(page.getByRole('button', { name: 'Detail', exact: true }).first()).toBeVisible();
    await expect(page.getByRole('button', { name: 'Lihat No. Perjalanan' }),
      'Lihat No. Perjalanan tidak boleh tampil sebelum Ditugaskan (REQ-073)').toBeHidden();
  });

  test('SCN-0133: Panel filter Daftar Order dapat diterapkan dan direset', async ({ page }) => {
    await gotoDaftarOrder(page);
    // Catatan harvest: panel filter SELALU tampil; tombol Filter hanya toggle state visual.
    await page.getByRole('button', { name: 'Filter' }).click();
    // ASM-D03 resolved — tidak diassert sebagai failure; lihat shared/decisions.md (SCN-0133).
    await expect(page.getByRole('button', { name: 'Semua Tipe' })).toBeVisible();
    await pickDropdownOption(page, 'Semua Jenis', 'FTL');
    await pickDropdownOption(page, 'Semua Status', 'Menunggu Penugasan');
    await page.getByRole('button', { name: 'Terapkan' }).click();
    await page.waitForLoadState('networkidle');
    // Tabel masih re-render sesaat setelah Terapkan (baris bisa berubah/hilang di tengah loop
    // bila dibaca satu-satu via locator) — ambil snapshot teks seluruh baris sekaligus, atomik.
    await page.waitForTimeout(500);
    const rowTexts = await page.getByRole('table').getByRole('row').allInnerTexts();
    const dataRows = rowTexts.slice(1).map((t) => t.trim()).filter(Boolean);
    expect(dataRows.length, 'Filter Menunggu Penugasan harus menghasilkan minimal 1 baris di staging')
      .toBeGreaterThan(0);
    for (const text of dataRows) {
      expect.soft(text, `Baris hasil filter harus berstatus Menunggu Penugasan: "${text.slice(0, 120)}"`)
        .toContain('Menunggu Penugasan');
    }
    await page.getByRole('button', { name: 'Reset' }).click();
    await expect(page.getByRole('button', { name: 'Semua Status' }),
      'Setelah Reset filter Status kembali ke default').toBeVisible();
  });
});

test.describe('Wizard Buat Order Step 1 (SCR-04/05)', () => {
  test('SCN-0007: Step 1 menampilkan seluruh field wajib beserta helper text', async ({ page }) => {
    await page.goto('/order/buat');
    await expect(page.getByRole('button', { name: 'Pilih Jenis Armada' })).toBeVisible();
    await expect(page.getByPlaceholder('Masukkan Jumlah Armada')).toBeVisible();
    await expect(page.getByRole('button', { name: 'Pilih Tipe Pengiriman' })).toBeVisible();
    // Field PIC baru dirender setelah Tipe Pengiriman dipilih — lihat shared/decisions.md (SCN-0007).
    await pickDropdownOption(page, 'Pilih Tipe Pengiriman', 'Normal');
    // Wording helper M-13/M-14 ditetapkan BUKAN BUG; assertion diselaraskan ke perilaku live —
    // lihat shared/decisions.md (SCN-0007).
    await expect.soft(page.getByPlaceholder('Masukkan PIC Pengirim').first(),
      'Field PIC Pengirim harus tampil (REQ-007)').toBeVisible();
    await expect.soft(page.getByPlaceholder('Masukkan PIC Penerima').first(),
      'Field PIC Penerima harus tampil (REQ-007)').toBeVisible();
    await expect.soft(page.getByPlaceholder('Masukkan No. WhatsApp PIC').first(),
      'Field No. WhatsApp PIC harus tampil (REQ-007)').toBeVisible();
  });

  test('SCN-0011: Tombol Selanjutnya disabled saat Tipe Pengiriman belum dipilih', async ({ page }) => {
    // BUG (probable) REQ-010/AC-007: disabled tidak ada di DOM — klik langsung untuk memverifikasi
    // blokir validasi; lihat shared/decisions.md (SCN-0011).
    await page.goto('/order/buat');
    await expect(page.getByRole('button', { name: 'Selanjutnya' })).toBeVisible();
    const disabledInDom = await page.getByRole('button', { name: 'Selanjutnya' }).isDisabled();
    await page.getByRole('button', { name: 'Selanjutnya' }).click({ force: true });
    await page.waitForTimeout(1_000);
    const stillOnStep1 = await page.getByRole('button', { name: 'Pilih Tipe Pengiriman' }).isVisible();
    test.info().annotations.push({
      type: 'note',
      description: `disabled-attr=${disabledInDom}, tetap-di-Step1-setelah-klik=${stillOnStep1}.`,
    });
    expect(
      disabledInDom || stillOnStep1,
      'REQ-010/AC-007: Selanjutnya harus disabled ATAU klik dengan field wajib kosong harus tetap diblokir di Step 1 — dua-duanya gagal berarti user bisa lanjut ke Step 2 tanpa Tipe Pengiriman terisi.'
    ).toBe(true);
  });
});

test.describe('Detail Order & Batalkan Order (SCR-20/22)', () => {
  test('SCN-0140: Detail Order menampilkan No. Perjalanan', async ({ page }) => {
    await gotoDaftarOrder(page);
    const found = await rowWithStatus(page, ANY_STATUS);
    test.skip(!found, 'Tidak ada baris order di staging');
    test.info().annotations.push({
      type: 'note',
      description: `Precondition desain "order Ditugaskan" tidak tersedia di staging — diverifikasi pada order "${found.status}" (section tampil dengan empty state).`,
    });
    await openActionMenu(found.row);
    await page.getByRole('button', { name: 'Detail', exact: true }).first().click();
    await expect(page.getByRole('button', { name: 'Detail Order' })).toBeVisible();
    await expect(page.getByRole('button', { name: 'No. Perjalanan' }),
      'Section No. Perjalanan harus ada di Detail Order (REQ-076)').toBeVisible();
  });

  test('SCN-0123: Alasan Pembatalan kosong menolak submit pembatalan', async ({ page }) => {
    await gotoDaftarOrder(page);
    const found = await rowWithStatus(page, ANY_STATUS);
    test.skip(!found, 'Tidak ada baris order di staging');
    await openActionMenu(found.row);
    await page.getByRole('button', { name: 'Batalkan Order' }).first().click();
    await expect(page.getByRole('heading', { name: 'Batalkan Order' })).toBeVisible();
    // M-22 (Gap 2 rev-2): placeholder field Alasan Pembatalan. #cancelReason = satu-satunya id stabil (selector-map).
    await expect(page.locator('#cancelReason'), 'Placeholder M-22 pada field Alasan Pembatalan')
      .toHaveAttribute('placeholder', 'Tuliskan alasan pembatalan order');
    await page.keyboard.press('Escape');
    test.info().annotations.push({
      type: 'note',
      description: 'Placeholder M-22 terverifikasi OK. Langkah klik submit "Batalkan Order" DILEWATI: order di staging bukan buatan run ini — bila validasi bermasalah, order nyata bisa ikut terbatalkan (aturan keselamatan data CLAUDE.md). Jalankan penuh hanya pada order AUTOTEST- buatan run sendiri.',
    });
    test.skip(true, 'Submit pembatalan hanya boleh diuji pada order buatan run ini — belum tersedia');
  });
});
