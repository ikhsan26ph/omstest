#!/usr/bin/env python3
"""Gabungkan file results/_batchNN__<modul>__<runId>.json menjadi satu file
results/<modul>__<runId>.json sesuai skema CLAUDE.md.

Skenario yang ada di scenarios.json tetapi tidak muncul di batch mana pun
ditambahkan dengan status `skipped` (mis. kategori stress) supaya jumlah
total tetap sama dengan dokumen skenario.

Usage: python scripts/merge_batches.py <modul> <runId>
"""
import glob
import json
import os
import sys
from datetime import datetime, timezone, timedelta

JKT = timezone(timedelta(hours=7))


def parse_ts(v):
    """Terima ISO8601 dgn 'Z', offset, atau tanpa zona (dianggap WIB)."""
    if not v:
        return None
    try:
        dt = datetime.fromisoformat(v.replace("Z", "+00:00"))
    except ValueError:
        return None
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=JKT)
    return dt.astimezone(JKT)


def main():
    if len(sys.argv) != 3:
        print(__doc__)
        sys.exit(1)
    module, run_id = sys.argv[1], sys.argv[2]
    pattern = f"results/_batch*__{module}__{run_id}.json"
    files = sorted(glob.glob(pattern))
    if not files:
        print(f"Tidak ada file batch cocok: {pattern}")
        sys.exit(1)

    scen_path = glob.glob(f"scenario/{module}/*.scenarios.json")
    if not scen_path:
        print(f"scenarios.json untuk {module} tidak ditemukan")
        sys.exit(1)
    source = json.load(open(scen_path[0]))
    source = source.get("scenarios", source) if isinstance(source, dict) else source
    source_by_id = {s["id"]: s for s in source}

    merged, seen = [], {}
    started, finished, env = None, None, None
    for f in files:
        d = json.load(open(f))
        if isinstance(d, list):  # batch yang menulis list skenario mentah
            d = {"scenarios": d}
        env = env or d.get("environment")
        st, fi = parse_ts(d.get("startedAt")), parse_ts(d.get("finishedAt"))
        if st:
            started = min(started, st) if started else st
        if fi:
            finished = max(finished, fi) if finished else fi
        for s in d.get("scenarios", []):
            sid = s["id"]
            if sid in seen:
                print(f"PERINGATAN: {sid} duplikat di {f} (sudah ada dari {seen[sid]}), dipakai yang terakhir")
            seen[sid] = os.path.basename(f)
            src = source_by_id.get(sid)
            # normalisasi field `screen`: harus string untuk Excel
            scr = s.get("screen")
            if isinstance(scr, list):
                s["screen"] = ", ".join(str(x) for x in scr)
            elif not scr and src:
                s["screen"] = ", ".join(str(x) for x in (src.get("screens") or []))
            for k in ("error", "bugCandidate", "notes", "screenshot"):
                if isinstance(s.get(k), (list, dict)):
                    s[k] = json.dumps(s[k], ensure_ascii=False)
            if src:
                # jaga traceability: field identitas disalin dari sumber
                for k in ("id", "title", "category", "priority", "requirements"):
                    s[k] = src.get(k, s.get(k))
            else:
                print(f"PERINGATAN: {sid} tidak ada di scenarios.json")
            merged.append(s)

    missing = [s for s in source if s["id"] not in seen]
    for src in missing:
        merged.append({
            "id": src["id"], "title": src["title"], "category": src.get("category"),
            "priority": src.get("priority"), "screen": ", ".join(src.get("screens", []) or []),
            "requirements": src.get("requirements", []), "status": "skipped",
            "durationSec": 0, "error": None, "screenshot": None, "bugCandidate": None,
            "notes": "Tidak dieksekusi pada run ini (kategori stress hanya dijalankan atas permintaan eksplisit)"
            if src.get("category") == "stress" else "Tidak tercakup batch mana pun pada run ini",
        })

    order = {s["id"]: i for i, s in enumerate(source)}
    merged.sort(key=lambda s: order.get(s["id"], 10**6))

    out = {
        "module": module, "runId": run_id,
        "startedAt": started.isoformat() if started else None,
        "finishedAt": finished.isoformat() if finished else None,
        "environment": env or {"baseUrl": "https://oms-staging.prahu-hub.com",
                               "user": "finance.roro1@gmail.com", "role": "Admin Utama"},
        "scenarios": merged,
    }
    out_path = f"results/{module}__{run_id}.json"
    json.dump(out, open(out_path, "w"), ensure_ascii=False, indent=2)

    from collections import Counter
    c = Counter(s["status"] for s in merged)
    print(f"{len(files)} batch digabung -> {out_path}")
    print(f"total {len(merged)} skenario: {dict(c)}")
    if missing:
        print(f"{len(missing)} skenario tidak ada di batch mana pun, ditandai skipped: "
              f"{[s['id'] for s in missing][:10]}{' ...' if len(missing) > 10 else ''}")


if __name__ == "__main__":
    main()
