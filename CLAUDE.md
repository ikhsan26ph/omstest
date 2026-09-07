# OMS — Claude Code

Baca dan ikuti `docs/agent-guide.md` sebagai sumber utama aturan proyek.
Semua path relatif terhadap root repository.

Slash command di `.claude/commands/` meneruskan tugas dan argumen ke
`docs/workflows/`. Definisi `.claude/agents/` merujuk `docs/roles/`.
Gunakan peran secara berurutan; delegasi opsional mengikuti izin dan kemampuan sesi.
Konfigurasi browser MCP Claude ada di `.mcp.json`.
Perbarui prosedur bersama di `docs/`, bukan menyalinnya ke adapter ini.
