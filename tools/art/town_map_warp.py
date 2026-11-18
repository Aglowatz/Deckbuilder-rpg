"""MAP-WORLD-TOWN (Batch 17, Overnight Nov 18, Part 3): the painted parchment map of Crosspath lined up with the world.

The painter followed the plan screenshot (`tools/crosspath_shots.sh`, `--top=25,27,110`) by eye, so the painting is the plan stretched a
little differently along each axis. Landmarks matched by hand (plan pixel -> world metres via the plan camera; painting pixel measured on
the 2048 px painting) give a piecewise-linear map per axis. This script resamples the painting onto a fixed world rectangle
(WORLD_RECT, PX_PER_M) so the game can draw it with the same world -> screen transform as its pins: every pin then sits on its painted
place. Adjusting for import only (a separable stretch); nothing is repainted.

    python tools/art/town_map_warp.py   -> assets/art/maps/MAP-WORLD-TOWN.webp (+ a check image in docs/overnight_shots/nov18/)
"""
import os

import numpy as np
from PIL import Image, ImageDraw

SRC = 'G:/My Drive/Card Game Art/Approved_Maps/MAP-WORLD-TOWN.png'
ROOT = os.path.join(os.path.dirname(__file__), '..', '..')
OUT = os.path.join(ROOT, 'assets', 'art', 'maps', 'MAP-WORLD-TOWN.webp')
CHECK = os.path.join(ROOT, 'docs', 'overnight_shots', 'nov18', 'p3_town_map_warp_check.jpg')

# Keep in sync with TownMapArt.WORLD_RECT / PX_PER_M (ui/minimap/town_map_art.gd).
WORLD_RECT = (-45.0, -35.0, 140.0, 130.0)  # x, z, width, depth in metres
PX_PER_M = 10.0

# (world metres, painting pixels) per axis. West gate, the fountain (TownLayout.PLAZA 25.2, 12.47), the east gate; the north ring road,
# the square, the lower west gate, the south wall.
X_POINTS = [(-21.5, 444.0), (25.2, 997.0), (72.3, 1525.0)]
Z_POINTS = [(-19.2, 382.0), (12.47, 756.0), (34.6, 1058.0), (75.1, 1554.0)]


def axis_map(points, world):
    w = np.array([p[0] for p in points])
    p = np.array([p[1] for p in points])
    out = np.interp(world, w, p)
    lo = (p[1] - p[0]) / (w[1] - w[0])
    hi = (p[-1] - p[-2]) / (w[-1] - w[-2])
    out = np.where(world < w[0], p[0] + (world - w[0]) * lo, out)
    out = np.where(world > w[-1], p[-1] + (world - w[-1]) * hi, out)
    return out


def main():
    src = Image.open(SRC).convert('RGBA')
    sw, sh = src.size
    x0, z0, wd, dp = WORLD_RECT
    ow, oh = int(wd * PX_PER_M), int(dp * PX_PER_M)
    wx = x0 + (np.arange(ow) + 0.5) / PX_PER_M
    wz = z0 + (np.arange(oh) + 0.5) / PX_PER_M
    px = axis_map(X_POINTS, wx) * sw / 2048.0
    py = axis_map(Z_POINTS, wz) * sh / 2048.0
    a = np.asarray(src).astype(np.float32)
    # bilinear sample (the stretch is near 1:1, so no mush)
    gx, gy = np.meshgrid(px, py)
    x_lo = np.clip(np.floor(gx).astype(int), 0, sw - 1)
    y_lo = np.clip(np.floor(gy).astype(int), 0, sh - 1)
    x_hi = np.clip(x_lo + 1, 0, sw - 1)
    y_hi = np.clip(y_lo + 1, 0, sh - 1)
    fx = (gx - np.floor(gx))[..., None]
    fy = (gy - np.floor(gy))[..., None]
    top = a[y_lo, x_lo] * (1 - fx) + a[y_lo, x_hi] * fx
    bottom = a[y_hi, x_lo] * (1 - fx) + a[y_hi, x_hi] * fx
    out = top * (1 - fy) + bottom * fy
    inside = ((gx >= 0) & (gx <= sw - 1) & (gy >= 0) & (gy <= sh - 1))[..., None]
    out = np.where(inside, out, 0.0)
    img = Image.fromarray(out.clip(0, 255).astype(np.uint8), 'RGBA')
    img.save(OUT, 'WEBP', quality=88)
    # check: the town's landmarks as red dots at their world positions
    check = img.convert('RGB')
    d = ImageDraw.Draw(check)
    for name, (x, z) in {'plaza': (25.2, 12.47), 'spawn': (25.2, 19.6), 'notice': (16.0, 22.4), 'arena': (25.2, 46.5)}.items():
        cx, cy = (x - x0) * PX_PER_M, (z - z0) * PX_PER_M
        d.ellipse((cx - 8, cy - 8, cx + 8, cy + 8), outline=(255, 0, 0), width=3)
        d.text((cx + 10, cy - 6), name, fill=(255, 0, 0))
    check.save(CHECK, quality=85)
    print('town map: %dx%d px -> %s' % (ow, oh, os.path.relpath(OUT, ROOT)))


if __name__ == '__main__':
    main()
