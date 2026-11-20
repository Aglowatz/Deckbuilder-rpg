"""Batch 18 (Fable Nov 20 day): line the five painted zone maps (MAP-WORLD-GAIN / BUFF / DUMP / DNA / CAP) up with the world.

The paintings follow top-down plans captured on Nov 17; the zones have moved on since. This tool registers each painting against a
FRESH plan of the zone (`tools/shot.sh res://scenes/<zone>_zone.tscn plan18_<zone> --top=auto --nocull=true --nofog=true`, which
prints `PLAN-TOP <id> cx,cz,size`: an orthographic view `size` metres tall centred on (cx, cz)) and writes, per zone, the world
rectangle the whole painting covers. The game draws the painting in that rectangle with the same world -> screen transform as its
pins (FullMapScreen.PAINTED_MAPS), so the pins sit on their painted places.

The fit is a stretch and a shift per axis (four numbers), found by correlating the two pictures: a coarse search over scale with an
FFT for the shift, then a fine search per axis. A score near 1 is a perfect match; the check sheets show the painting's outlines over
the fresh plan.

    python tools/art/world_map_fit.py            -> data/maps/world_map_fit.json, assets/art/maps/MAP-WORLD-*.webp, check sheets
"""
import json
import os

import numpy as np
from PIL import Image, ImageFilter

ROOT = os.path.join(os.path.dirname(__file__), '..', '..')
SRC = os.path.join(ROOT, '_art_inbox', 'batch18')
SHOTS = os.path.join(ROOT, '_screenshots')
OUT_JSON = os.path.join(ROOT, 'data', 'maps', 'world_map_fit.json')
OUT_ART = os.path.join(ROOT, 'assets', 'art', 'maps')
CHECK = os.path.join(ROOT, 'docs', 'overnight_shots', 'nov20b')
OUT_SIZE = 1536

# area id -> (painting id, plan shot, PLAN-TOP cx, cz, size)
ZONES = {
    'beefcake': ('MAP-WORLD-GAIN', 'plan18_gainlands', 54.5, 44.0, 159.0),
    'gourmand': ('MAP-WORLD-BUFF', 'plan18_buffet', 50.0, 49.0, 102.0),
    'refusemancer': ('MAP-WORLD-DUMP', 'plan18_heap', 50.0, 78.0, 158.0),
    'necrocrat': ('MAP-WORLD-DNA', 'plan18_dna', 45.0, 36.0, 96.0),
    'final': ('MAP-WORLD-CAP', 'plan18_capital', 56.0, 78.5, 163.0),
}
N = 384  # working size


def prep(img, n=N):
    """A blurred, zero-mean, unit-variance RGB array of the picture at n x n."""
    a = np.asarray(img.convert('RGB').resize((n, n), Image.LANCZOS).filter(ImageFilter.GaussianBlur(1.5))).astype(np.float32)
    a -= a.mean(axis=(0, 1), keepdims=True)
    a /= a.std(axis=(0, 1), keepdims=True) + 1e-6
    return a


def warp(paint_img, sx, tx, sy, ty, n=N):
    """The painting resampled into plan space: plan pixel (x, y) shows painting pixel (sx * x + tx, sy * y + ty), in n-pixel units."""
    k = paint_img.width / float(n)
    return paint_img.transform((n, n), Image.AFFINE, (sx, 0.0, tx * k, 0.0, sy, ty * k), Image.BILINEAR, fillcolor=(128, 128, 128)) \
        if paint_img.width == n else paint_img.resize((n, n), Image.LANCZOS).transform((n, n), Image.AFFINE, (sx, 0.0, tx, 0.0, sy, ty), Image.BILINEAR, fillcolor=(128, 128, 128))


def score(plan, paint_small, sx, tx, sy, ty, margin=0.0):
    w = prep(warp(paint_small, sx, tx, sy, ty))
    return float((plan * w).mean())


def best_shift(plan, w):
    """The whole-pixel shift of `w` that best matches `plan` (FFT cross-correlation, all channels)."""
    acc = np.zeros(plan.shape[:2], np.float64)
    for c in range(3):
        acc += np.fft.irfft2(np.fft.rfft2(plan[:, :, c]) * np.conj(np.fft.rfft2(w[:, :, c])), s=plan.shape[:2])
    dy, dx = np.unravel_index(np.argmax(acc), acc.shape)
    n = plan.shape[0]
    if dy > n // 2:
        dy -= n
    if dx > n // 2:
        dx -= n
    return int(dx), int(dy), float(acc.max() / (n * n * 3))


def fit(plan_img, paint_img):
    plan = prep(plan_img)
    small = paint_img.convert('RGB').resize((N, N), Image.LANCZOS)
    c = (N - 1) * 0.5
    best = (-9.0, 1.0, 0.0, 1.0, 0.0)
    # coarse: one scale for both axes about the centre, the shift from the FFT
    # (the painter kept each plan's framing within a few per cent, so the search stays near 1:1)
    for s in np.arange(0.90, 1.101, 0.01):
        t0 = c - s * c
        w = prep(warp(small, s, t0, s, t0))
        dx, dy, _ = best_shift(plan, w)
        if abs(dx) > N * 0.08 or abs(dy) > N * 0.08:
            continue
        # w shifted by (dx, dy) matches the plan: plan(x) = w(x - dx) = paint(s * (x - dx) + t0)
        tx, ty = t0 - s * dx, t0 - s * dy
        sc = score(plan, small, s, tx, s, ty)
        if sc > best[0]:
            best = (sc, s, tx, s, ty)
    sc, sx, tx, sy, ty = best
    # fine: each axis on its own (scale about the centre, then the shift), smaller steps each round
    for step_s, step_t in [(0.01, 2.0), (0.004, 1.0), (0.002, 0.5), (0.001, 0.25)]:
        for _ in range(3):
            improved = False
            for axis in (0, 1):
                for ds, dt in [(step_s, 0), (-step_s, 0), (0, step_t), (0, -step_t)]:
                    nsx, ntx, nsy, nty = sx, tx, sy, ty
                    if axis == 0:
                        nsx = sx + ds
                        ntx = tx + dt - ds * c
                    else:
                        nsy = sy + ds
                        nty = ty + dt - ds * c
                    nsc = score(plan, small, nsx, ntx, nsy, nty)
                    if nsc > sc + 1e-5:
                        sc, sx, tx, sy, ty = nsc, nsx, ntx, nsy, nty
                        improved = True
            if not improved:
                break
    return sc, sx, tx, sy, ty


def edges(img):
    g = np.asarray(img.convert('L').filter(ImageFilter.GaussianBlur(1.2))).astype(np.float32)
    gx = np.abs(np.diff(g, axis=1, prepend=g[:, :1]))
    gy = np.abs(np.diff(g, axis=0, prepend=g[:1, :]))
    return (gx + gy) > 22.0


def main():
    os.makedirs(os.path.dirname(OUT_JSON), exist_ok=True)
    os.makedirs(CHECK, exist_ok=True)
    result = {}
    for area, (paint_id, shot, cx, cz, size) in ZONES.items():
        shot_img = Image.open(os.path.join(SHOTS, shot + '.png')).convert('RGB')
        w, h = shot_img.size
        plan_img = shot_img.crop(((w - h) // 2, 0, (w - h) // 2 + h, h))  # the square `size` metres on a side
        paint_img = Image.open(os.path.join(SRC, paint_id + '.png')).convert('RGB')
        sc, sx, tx, sy, ty = fit(plan_img, paint_img)
        # plan pixel p (0..N) is world  x = cx - size/2 + p * size / N ; painting pixel q = sx * p + tx
        m_per_plan_px = size / N
        x_at = lambda q: cx - size * 0.5 + (q - tx) / sx * m_per_plan_px
        z_at = lambda q: cz - size * 0.5 + (q - ty) / sy * m_per_plan_px
        rect = [x_at(0.0), z_at(0.0), x_at(N) - x_at(0.0), z_at(N) - z_at(0.0)]
        result[area] = {'id': paint_id, 'rect': [round(v, 2) for v in rect], 'score': round(sc, 3),
                        'plan': [cx, cz, size], 'metres_per_painting_px': [round(rect[2] / 2048.0, 4), round(rect[3] / 2048.0, 4)]}
        print('%-13s %-15s score %.3f  rect x %.1f z %.1f w %.1f d %.1f' % (area, paint_id, sc, rect[0], rect[1], rect[2], rect[3]))
        paint_img.resize((OUT_SIZE, OUT_SIZE), Image.LANCZOS).save(os.path.join(OUT_ART, paint_id + '.webp'), quality=88, method=6)
        # check sheet: the fresh plan with the painting's outlines over it (left), and the painting warped into plan space (right)
        big = 900
        k = big / float(N)
        warped = paint_img.resize((big, big), Image.LANCZOS).transform((big, big), Image.AFFINE, (sx, 0.0, tx * k, 0.0, sy, ty * k), Image.BILINEAR, fillcolor=(40, 40, 40))
        base = np.asarray(plan_img.resize((big, big), Image.LANCZOS)).copy()
        base[edges(warped)] = (255, 0, 255)
        sheet = Image.new('RGB', (big * 2 + 8, big), (0, 0, 0))
        sheet.paste(Image.fromarray(base), (0, 0))
        sheet.paste(warped, (big + 8, 0))
        sheet.save(os.path.join(CHECK, 'p1_mapfit_%s.jpg' % paint_id), quality=84)
    json.dump({'_about': 'Made by tools/art/world_map_fit.py: the world rectangle (x, z, width, depth in metres) each painted zone map covers.', 'maps': result},
              open(OUT_JSON, 'w', encoding='utf-8', newline='\n'), indent='\t')
    print('wrote', os.path.relpath(OUT_JSON, ROOT))


if __name__ == '__main__':
    main()
