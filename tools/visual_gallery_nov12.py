"""Fable Nov 12 (Part 6.1): the side-by-side before/after gallery of the fixed shot set.

    python -I tools/visual_gallery_nov12.py [scores_before.csv] [scores_after.csv]

Reads docs/overnight_shots/nov12/before/*.jpg and .../after/*.jpg (same file names) and writes docs/review/visual_nov12/index.html
(relative links, opens from disk). The optional CSVs hold `file,score,note` rows from the art-director critic.
"""
import csv
import html
import os
import sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
SHOTS = os.path.join(ROOT, "docs", "overnight_shots", "nov12")
OUT = os.path.join(ROOT, "docs", "review", "visual_nov12")
GROUPS = [
    ("Opening Forest", "forest_"), ("Crosspath", "crosspath_"), ("The Gainlands", "gainlands_"), ("The Endless Buffet", "buffet_"),
    ("The Verdant Dump", "dump_"), ("The D.N.A.", "dna_"), ("The Capital before Primm", "capital_before_"),
    ("The Capital after Primm", "capital_after_"), ("Dungeons", "dungeon_"), ("Battles", "battle_"), ("Screens", "ui_"),
]


def scores(path):
    table = {}
    if path and os.path.exists(path):
        with open(path, encoding="utf-8") as handle:
            for row in csv.reader(handle):
                if len(row) >= 2 and row[0] != "file":
                    table[row[0]] = (row[1], row[2] if len(row) > 2 else "")
    return table


def main():
    before = scores(sys.argv[1] if len(sys.argv) > 1 else os.path.join(OUT, "scores_before.csv"))
    after = scores(sys.argv[2] if len(sys.argv) > 2 else os.path.join(OUT, "scores_after.csv"))
    names = sorted(name for name in os.listdir(os.path.join(SHOTS, "before")) if name.endswith(".jpg"))
    have_after = set(os.listdir(os.path.join(SHOTS, "after"))) if os.path.isdir(os.path.join(SHOTS, "after")) else set()
    os.makedirs(OUT, exist_ok=True)
    parts = ["<!doctype html><html lang='en'><head><meta charset='utf-8'><meta name='viewport' content='width=device-width, initial-scale=1'>",
             "<title>Visual pass Nov 12</title><style>",
             ":root{--bg:#f6f3ee;--fg:#1f1b16;--mute:#6b6257;--card:#fff;--line:#d9d2c6}",
             "@media (prefers-color-scheme: dark){:root{--bg:#17150f;--fg:#efe9df;--mute:#a59c8e;--card:#221f18;--line:#3a352b}}",
             "body{background:var(--bg);color:var(--fg);font:15px/1.45 system-ui,sans-serif;margin:0;padding:16px}",
             "h1{font-size:22px;margin:0 0 4px}h2{font-size:18px;margin:28px 0 8px;border-bottom:1px solid var(--line);padding-bottom:4px}",
             "p.lead{color:var(--mute);margin:0 0 12px;max-width:70ch}nav a{margin-right:12px;color:inherit}",
             ".pair{display:grid;grid-template-columns:1fr 1fr;gap:8px;background:var(--card);border:1px solid var(--line);border-radius:6px;padding:8px;margin:0 0 12px}",
             "@media (max-width:760px){.pair{grid-template-columns:1fr}}",
             ".pair figure{margin:0}.pair img{width:100%;height:auto;display:block;border-radius:3px}",
             ".pair figcaption{font-size:13px;color:var(--mute);margin-top:4px}.name{grid-column:1/-1;font-weight:600;font-size:14px}",
             ".score{font-variant-numeric:tabular-nums;color:var(--fg);font-weight:600}",
             "</style></head><body>",
             "<h1>The Wayward Path - visual pass, Nov 12</h1>",
             "<p class='lead'>The fixed shot set, before (left) and after (right), from the same cameras. Scores are the no-context art-director critic's per-shot averages (1-10).</p><nav>"]
    for title, prefix in GROUPS:
        parts.append("<a href='#%s'>%s</a>" % (prefix, html.escape(title)))
    parts.append("</nav>")
    for title, prefix in GROUPS:
        group = [name for name in names if name.startswith(prefix)]
        if not group:
            continue
        parts.append("<h2 id='%s'>%s</h2>" % (prefix, html.escape(title)))
        for name in group:
            parts.append("<div class='pair'><div class='name'>%s</div>" % html.escape(name[:-4]))
            for label, folder, table, present in (("Before", "before", before, True), ("After", "after", after, name in have_after)):
                caption = label
                if name in table:
                    caption += " - <span class='score'>%s</span> %s" % (html.escape(table[name][0]), html.escape(table[name][1]))
                if present:
                    parts.append("<figure><a href='../../overnight_shots/nov12/%s/%s'><img loading='lazy' src='../../overnight_shots/nov12/%s/%s' alt='%s, %s'></a><figcaption>%s</figcaption></figure>" % (folder, name, folder, name, html.escape(name[:-4]), label.lower(), caption))
                else:
                    parts.append("<figure><figcaption>%s - not captured</figcaption></figure>" % label)
            parts.append("</div>")
    parts.append("</body></html>")
    with open(os.path.join(OUT, "index.html"), "w", encoding="utf-8", newline="\n") as handle:
        handle.write("\n".join(parts))
    print("gallery: %d shots, %d with an after" % (len(names), len([n for n in names if n in have_after])))


if __name__ == "__main__":
    main()
