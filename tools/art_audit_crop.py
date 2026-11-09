"""Overnight Nov 8-9, Part 2: crop a region of an art file for the audit (evidence for a flag).

    python tools/art_audit_crop.py <file> <name> [x0 y0 x1 y1 as fractions 0-1] [--max=900]

Writes docs/art/audit_nov9/crops/<name>.jpg (whole image when no box is given), scaled to at most --max px on the long side.
"""
import os
import sys
from PIL import Image

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
OUT = os.path.join(ROOT, "docs", "art", "audit_nov9", "crops")


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    limit = 900
    for a in sys.argv[1:]:
        if a.startswith("--max="):
            limit = int(a.split("=", 1)[1])
    path, name = args[0], args[1]
    if not os.path.isabs(path):
        path = os.path.join(ROOT, path)
    im = Image.open(path).convert("RGB")
    if len(args) >= 6:
        x0, y0, x1, y1 = (float(v) for v in args[2:6])
        w, h = im.size
        im = im.crop((int(x0 * w), int(y0 * h), int(x1 * w), int(y1 * h)))
    im.thumbnail((limit, limit), Image.LANCZOS)
    os.makedirs(OUT, exist_ok=True)
    out = os.path.join(OUT, name + ".jpg")
    im.save(out, quality=88)
    print(out)


if __name__ == "__main__":
    main()
