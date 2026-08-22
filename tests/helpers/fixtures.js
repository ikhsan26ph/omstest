// Fixture sesi OMS. PENTING: backend OMS menolak sesi yang dipindah antar browser-context
// (storageState/refresh-token tidak berlaku di context lain — diverifikasi 2026-08-22).
// Karena itu login dilakukan SEKALI per worker dan seluruh test berbagi context hidup yang sama.
// Konsekuensi: worker harus 1 (lihat playwright.config.js) dan test dalam satu file berjalan serial.
const fs = require('fs');
const path = require('path');
const base = require('@playwright/test');
const { parseEnv } = require('./env');

// Guard aturan CLAUDE.md: login gagal 2x berturut-turut -> BERHENTI (jangan sampai akun terkunci).
// Playwright me-restart worker setelah fixture gagal, yang tanpa guard ini akan mencoba login terus.
const FAIL_FILE = path.join(__dirname, '..', '..', 'artifacts', '.auth', 'login-failures.json');

function readFailures() {
  try {
    return JSON.parse(fs.readFileSync(FAIL_FILE, 'utf8')).count || 0;
  } catch {
    return 0;
  }
}

function writeFailures(count) {
  fs.mkdirSync(path.dirname(FAIL_FILE), { recursive: true });
  fs.writeFileSync(FAIL_FILE, JSON.stringify({ count, at: new Date().toISOString() }));
}

const test = base.test.extend({
  authedContext: [
    async ({ browser }, use) => {
      const { baseUrl, main } = parseEnv();
      if (readFailures() >= 2) {
        throw new Error(
          'Login sudah gagal 2x berturut-turut — eksekusi dihentikan demi keamanan akun. ' +
          'Periksa kredensial di config/env.md, lalu hapus artifacts/.auth/login-failures.json untuk mencoba lagi.'
        );
      }
      const context = await browser.newContext({
        baseURL: baseUrl,
        viewport: { width: 1440, height: 900 },
      });
      const page = await context.newPage();
      try {
        await page.goto('/login');
        await page.getByPlaceholder('Masukkan Email').fill(main.email);
        await page.getByPlaceholder('Masukkan Password').fill(main.password);
        await page.getByRole('button', { name: 'Login' }).click();
        // Login sukses redirect ke /monitoring (knowledge/module-map.md).
        await page.waitForURL(/\/monitoring/, { timeout: 30_000 });
        writeFailures(0);
      } catch (err) {
        writeFailures(readFailures() + 1);
        await context.close();
        throw new Error(`Login OMS gagal (percobaan ${readFailures()}/2): ${err.message}`);
      }
      await page.close();
      await use(context);
      await context.close();
    },
    { scope: 'worker' },
  ],

  context: async ({ authedContext }, use) => {
    await use(authedContext);
  },

  page: async ({ authedContext }, use) => {
    const page = await authedContext.newPage();
    await use(page);
    await page.close();
  },

  // Context manual tidak mendapat auto-screenshot dari konfigurasi `screenshot:` —
  // ambil manual saat gagal agar konverter tetap menemukan attachment "screenshot".
  attachScreenshotOnFailure: [
    async ({ page }, use, testInfo) => {
      await use();
      if (testInfo.status !== testInfo.expectedStatus && !page.isClosed()) {
        const shot = testInfo.outputPath('test-failed-1.png');
        try {
          await page.screenshot({ path: shot, fullPage: true });
          testInfo.attachments.push({ name: 'screenshot', path: shot, contentType: 'image/png' });
        } catch {
          /* halaman keburu mati — biarkan tanpa screenshot */
        }
      }
    },
    { auto: true },
  ],
});

module.exports = { test, expect: base.expect };
