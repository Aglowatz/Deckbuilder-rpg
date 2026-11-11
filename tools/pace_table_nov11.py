"""Overnight Nov 10-11, Part 3: summarise the pace sims (docs/design/sim/nov11/<tag>_<group>.md, written by tools/pace_sims_nov11.sh)
into one table per tag: for every ordinary (Normal kind) encounter its turns and win rate per Path, plus a per-group mean, and a
before/after comparison when two tags are given.
    python -I tools/pace_table_nov11.py before [after]
"""
import glob
import os
import re
import sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "docs", "design", "sim", "nov11")
PATHS = ["Beefcake", "Necrocrat", "Gourmand", "Refusemancer"]


def rows_of(tag):
    """{group: [ {encounter, kind, level, wins: {path: pct}, all, turns} ]} for one tag."""
    result = {}
    for path in sorted(glob.glob(os.path.join(ROOT, "%s_*.md" % tag))):
        group = os.path.basename(path)[len(tag) + 1:-3].replace("_", ":", 1)
        rows = []
        with open(path, encoding="utf-8") as handle:
            for line in handle:
                if not line.startswith("| ") or line.startswith("| Encounter") or line.startswith("|---"):
                    continue
                cells = [c.strip() for c in line.strip().strip("|").split("|")]
                if len(cells) < 12:
                    continue
                try:
                    wins = {p: int(cells[4 + i].rstrip("%")) for i, p in enumerate(PATHS)}
                    rows.append({
                        "encounter": cells[0], "kind": cells[1], "level": int(cells[2]), "wins": wins,
                        "all": int(cells[8].strip("*").rstrip("%")), "turns": float(cells[9]),
                    })
                except ValueError:
                    continue
        if rows:
            result[group] = rows
    return result


def mean(values):
    return sum(values) / float(len(values)) if values else 0.0


def table(tag, data, kinds=("Normal",)):
    lines = ["### %s" % tag, "", "| Group | Fights | Turns (mean) | Beefcake | Necrocrat | Gourmand | Refusemancer | All | Slowest fight |", "|---|---:|---:|---:|---:|---:|---:|---:|---|"]
    totals = []
    for group, rows in data.items():
        picked = [r for r in rows if r["kind"] in kinds]
        if not picked:
            continue
        totals.extend(picked)
        slowest = max(picked, key=lambda r: r["turns"])
        lines.append("| %s | %d | %.1f | %s | %d%% | %s (%.1f) |" % (
            group, len(picked), mean([r["turns"] for r in picked]),
            " | ".join("%d%%" % mean([r["wins"][p] for r in picked]) for p in PATHS),
            mean([r["all"] for r in picked]), slowest["encounter"], slowest["turns"]))
    if totals:
        lines.append("| **all ordinary fights** | %d | **%.1f** | %s | **%d%%** | %d fights over 7 turns |" % (
            len(totals), mean([r["turns"] for r in totals]),
            " | ".join("%d%%" % mean([r["wins"][p] for r in totals]) for p in PATHS),
            mean([r["all"] for r in totals]), len([r for r in totals if r["turns"] > 7.0])))
    return lines


def detail(tag, data, kinds=("Normal",)):
    lines = ["### %s - every ordinary fight" % tag, "", "| Encounter | L | Turns | Beefcake | Necrocrat | Gourmand | Refusemancer | All |", "|---|---:|---:|---:|---:|---:|---:|---:|"]
    for group, rows in data.items():
        for r in rows:
            if r["kind"] in kinds:
                lines.append("| %s | %d | %.1f | %s | %d%% |" % (r["encounter"], r["level"], r["turns"], " | ".join("%d%%" % r["wins"][p] for p in PATHS), r["all"]))
    return lines


def compare(before, after, kinds=("Normal",)):
    lines = ["### before -> after (ordinary fights)", "", "| Encounter | Turns before | Turns after | Win before | Win after |", "|---|---:|---:|---:|---:|"]
    for group, rows in after.items():
        old = {r["encounter"]: r for r in before.get(group, [])}
        for r in rows:
            if r["kind"] not in kinds or r["encounter"] not in old:
                continue
            o = old[r["encounter"]]
            lines.append("| %s | %.1f | %.1f | %d%% | %d%% |" % (r["encounter"], o["turns"], r["turns"], o["all"], r["all"]))
    return lines


def main(argv):
    if len(argv) < 2:
        print(__doc__)
        return 2
    before = rows_of(argv[1])
    out = table(argv[1], before) + [""] + detail(argv[1], before)
    if len(argv) > 2:
        after = rows_of(argv[2])
        out += [""] + table(argv[2], after) + [""] + compare(before, after)
    print("\n".join(out))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
