// Parser config/env.md — satu-satunya sumber baseUrl & kredensial (aturan CLAUDE.md:
// jangan pernah menebak URL/kredensial). Jangan pernah mencetak password ke log/report.
const fs = require('fs');
const path = require('path');

function parseEnv() {
  const file = path.join(__dirname, '..', '..', 'config', 'env.md');
  const md = fs.readFileSync(file, 'utf8');
  let baseUrl = null;
  const accounts = [];
  for (const line of md.split('\n')) {
    const cells = line.split('|').map((c) => c.trim());
    if (cells.length >= 4 && cells[1] === 'baseUrl') {
      baseUrl = cells[2].replace(/\(contoh:[^)]*\)/i, '').trim();
    }
    // Baris tabel akun: | 1 | email | password | role | ket |
    if (cells.length >= 6 && /^\d+$/.test(cells[1])) {
      const email = cells[2];
      const password = cells[3];
      const role = cells[4];
      if (email.includes('@') && password && !/ISI_DISINI/i.test(password) && !/ISI_DISINI/i.test(email)) {
        accounts.push({ email, password, role });
      }
    }
  }
  if (!baseUrl || /ISI_DISINI/i.test(baseUrl)) {
    throw new Error('config/env.md: baseUrl belum diisi — hentikan dan minta user mengisinya.');
  }
  if (!/^https?:\/\//.test(baseUrl)) baseUrl = 'https://' + baseUrl;
  if (accounts.length === 0) {
    throw new Error('config/env.md: tidak ada akun dengan email+password terisi.');
  }
  return { baseUrl, accounts, main: accounts[0] };
}

module.exports = { parseEnv };
