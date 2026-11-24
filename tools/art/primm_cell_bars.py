"""Fable big pass Nov 23 (Part 5.4): the bars-only front layer of Primm's cell, so Primm can stand BEHIND the bars of the painted
cell (CAP-PROP-PRIMM-CELL is one opaque picture: stone arch, bars, dark interior). Inside the arch's opening every pixel that is
not the dark interior (the bars, the door frame, the padlock, the bottom rail) is kept; everything else is transparent. The game
draws the whole cell, then Primm, then this layer (`CapitalProps.primm_cell`).
    python tools/art/primm_cell_bars.py
Reads assets/art/zone_kits/final/CAP-PROP-PRIMM-CELL.webp, writes assets/art/derived/CAP-PROP-PRIMM-CELL-BARS.webp."""
import os
from PIL import Image, ImageDraw, ImageFilter

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..')
SOURCE = os.path.join(ROOT, 'assets', 'art', 'zone_kits', 'final', 'CAP-PROP-PRIMM-CELL.webp')
OUT_DIR = os.path.join(ROOT, 'assets', 'art', 'derived')
OUT = os.path.join(OUT_DIR, 'CAP-PROP-PRIMM-CELL-BARS.webp')
# The opening, as shares of the picture: a rectangle with a round top (an ellipse over its upper part)
LEFT, RIGHT, TOP, BOTTOM, SPRING = 0.262, 0.708, 0.185, 0.905, 0.42
DARK = 62  # a pixel darker than this (max of r, g, b) is the cell's interior
BENCH = (0.24, 0.66, 0.50, 0.80)  # the bench and the straw stay BEHIND Primm: [left, top, right, bottom], bars excepted by colour


def main():
    image = Image.open(SOURCE).convert('RGBA')
    w, h = image.size
    opening = Image.new('L', (w, h), 0)
    draw = ImageDraw.Draw(opening)
    draw.rectangle([LEFT * w, SPRING * h, RIGHT * w, BOTTOM * h], fill=255)
    draw.ellipse([LEFT * w, TOP * h, RIGHT * w, (2 * SPRING - TOP) * h], fill=255)
    pixels = image.load()
    mask = Image.new('L', (w, h), 0)
    mask_px = mask.load()
    open_px = opening.load()
    # the bar columns: where the band just above the middle rail (only bars against the dark there) is lit
    bar_column = [False] * w
    for x in range(w):
        lit = 0
        rows = range(int(0.44 * h), int(0.54 * h))
        for y in rows:
            r, g, b, a = pixels[x, y]
            if open_px[x, y] and a >= 200 and max(r, g, b) >= DARK:
                lit += 1
        bar_column[x] = lit > len(rows) * 0.7
    for y in range(h):
        for x in range(w):
            if open_px[x, y] == 0:
                continue
            r, g, b, a = pixels[x, y]
            if a < 200 or max(r, g, b) < DARK:
                continue
            fx, fy = x / w, y / h
            if fy > 0.61:
                # below the middle rail the bench, the straw and the floor stay BEHIND Primm: only the bar columns, the bottom
                # rail and the padlock are in front
                padlock = 0.545 < fx < 0.625 and fy < 0.72
                rail = fy > 0.868
                if not (bar_column[x] or padlock or rail):
                    continue
            mask_px[x, y] = 255
    mask = mask.filter(ImageFilter.MedianFilter(3))
    out = image.copy()
    out.putalpha(mask)
    os.makedirs(OUT_DIR, exist_ok=True)
    out.save(OUT, quality=92, method=6)
    print('bars layer: %s (%d x %d)' % (os.path.relpath(OUT, ROOT), w, h))


if __name__ == '__main__':
    main()
