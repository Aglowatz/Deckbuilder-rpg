"""Batch 17 / 17A import prep (Overnight Nov 18, Part 1): copies the approved files that need an import fix into a local inbox
(_art_inbox/batch17/, git-ignored) and fixes them there. The Drive files are never changed.

    python tools/art/batch17_prep.py            -> _art_inbox/batch17/zk/<ZoneFolder>/*.png, _art_inbox/batch17/Approved_EnvKit/*.png,
                                                   and 3x3 tiling previews in docs/overnight_shots/nov18/p1_tile_*.jpg

Fixes (the brief's "import fixes"):
- DNA-FLOOR-MARBLE: the painting is ~4 squares across with a border, so it does not tile. Crop an exact 2x2-square tile whose edges run
  through the middle of squares (the seam lies inside marble, never on a grout line), then blend the seams.
- DNA-RAIL-PARTITION: crop to the painted area (it fills only the middle of its canvas).
- The tileable pieces (three hall walls, the exterior wall, the partition, the floor, the runner): edge blend so the wrap is continuous
  (each row's / column's step across the seam is spread over a band on both sides; the painting's detail is kept).
- TOWN-PROP-CELLAR-FOURSEALS-OPEN: the doorway and stairs are partly transparent: every see-through pixel that is enclosed by the door
  (not reachable from the image border) is laid over a painted-dark brown-black backing, darker at the top.
No upscaling: images keep their delivered size (about 1254 px); the game scales them to the slot.
"""
import os
import shutil
import sys
from collections import deque

import numpy as np
from PIL import Image

DRIVE = 'G:/My Drive/Card Game Art/'
ROOT = os.path.join(os.path.dirname(__file__), '..', '..')
INBOX = os.path.join(ROOT, '_art_inbox', 'batch17')
SHOTS = os.path.join(ROOT, 'docs', 'overnight_shots', 'nov18')

DNA = ['DNA-WALL-HALL-A', 'DNA-WALL-HALL-B', 'DNA-WALL-HALL-NARROW', 'DNA-WALL-EXTERIOR', 'DNA-PROP-COLUMN', 'DNA-RAIL-PARTITION',
       'DNA-RAIL-POST', 'DNA-FLOOR-MARBLE', 'DNA-FLOOR-RUNNER', 'DNA-PROP-CHANDELIER', 'DNA-PROP-SCONCE', 'DNA-PROP-LOBBY-CLOCK',
       'DNA-BANNER-STAMP-01', 'DNA-BANNER-STAMP-02', 'DNA-PROP-OFFICE-BOOTH-01', 'DNA-PROP-OFFICE-BOOTH-02', 'DNA-BD-HALL-INTERIOR',
       'DNA-STATUE-MORTIMER-STANDING', 'DNA-STATUE-MORTIMER-TOPPLED']
# id -> (tile x, tile y)
TILEABLE = {'DNA-WALL-HALL-A': (True, False), 'DNA-WALL-HALL-B': (True, False), 'DNA-WALL-HALL-NARROW': (True, False),
            'DNA-WALL-EXTERIOR': (True, False), 'DNA-RAIL-PARTITION': (True, False), 'DNA-FLOOR-MARBLE': (True, True),
            'DNA-FLOOR-RUNNER': (False, True)}
OTHER_ZONES = {
    'Gainlands': ['GAIN-STATUE-CLENCH-STANDING', 'GAIN-STATUE-CLENCH-TOPPLED'],
    'Buffet': ['BUFF-STATUE-GRANDCHEF-STANDING', 'BUFF-STATUE-GRANDCHEF-TOPPLED', 'BUFF-PROP-FRUIT-TART', 'BUFF-PROP-CAKESTAND-TALL',
               'BUFF-PROP-VEG-01', 'BUFF-PROP-VEG-02', 'BUFF-PROP-VEG-03'],
    'VerdantDump': ['DUMP-STATUE-COMPOSTELLA-STANDING', 'DUMP-STATUE-COMPOSTELLA-TOPPLED', 'DUMP-SHEET-ENTRANCE-FLAGS-07',
                    'DUMP-SHEET-ENTRANCE-FLAGS-08', 'DUMP-PROP-PIG'],
    'Capital': ['CAP-STATUE-PRIMM-STANDING', 'CAP-STATUE-PRIMM-TOPPLED'],
}
TOWN = {'TOWN-PROP-CELLAR-FOURSEALS-CLOSED': 'Approved_EnvKit', 'TOWN-PROP-CELLAR-FOURSEALS-OPEN': 'Approved_EnvKit',
        'TOWN-PROP-SEAL-LOCKED': 'Approved_Icons', 'TOWN-PROP-SEAL-BLANK': 'Approved_Icons'}


def seam_step(a, horizontal):
    """Mean absolute step across the wrap seam (0-255), the same idea as the importer's seam ratio."""
    if horizontal:
        return float(np.abs(a[:, 0, :3] - a[:, -1, :3]).mean())
    return float(np.abs(a[0, :, :3] - a[-1, :, :3]).mean())


def blend_seam(a, horizontal, band):
    """Spreads each row's (column's) step across the wrap over `band` pixels on both sides: the left edge moves half way toward the
    right edge's colour and vice versa, fading to nothing at `band`. Uses a small vertical blur of the step so single noisy pixels do not
    streak."""
    a = a.copy()
    if not horizontal:
        a = a.transpose(1, 0, 2)
    left = a[:, :3, :3].mean(axis=1)
    right = a[:, -3:, :3].mean(axis=1)
    step = right - left  # per row
    kernel = np.ones(5) / 5.0
    for c in range(3):
        step[:, c] = np.convolve(step[:, c], kernel, mode='same')
    w = a.shape[1]
    for k in range(band):
        t = 0.5 * (1.0 - k / float(band))
        t = t * t * (3 - 2 * t) if False else t
        a[:, k, :3] += step * t
        a[:, w - 1 - k, :3] -= step * t
    a = np.clip(a, 0, 255)
    if not horizontal:
        a = a.transpose(1, 0, 2)
    return a


def crop_marble(a):
    """An exact 2x2-square tile with its edges through square centres. Square boundaries are found from the green-vs-cream split."""
    g = a[:, :, 1] - a[:, :, 0]
    dark = g > 8

    def boundaries(profile):
        sm = np.convolve(profile.astype(float), np.ones(31) / 31.0, mode='same')
        on = sm > 0.5
        return [i for i in range(1, len(on)) if on[i] != on[i - 1]]

    # Column profile: fraction of dark pixels per column inside one band of rows is useless on a checker, so use the XOR with the
    # square row: sample several rows and vote on boundary positions.
    cols, rows = [], []
    h, w = dark.shape
    for y in range(int(h * 0.1), int(h * 0.9), 23):
        cols += boundaries(dark[y, :])
    for x in range(int(w * 0.1), int(w * 0.9), 23):
        rows += boundaries(dark[:, x])

    def cluster(values):
        values = sorted(values)
        groups, cur = [], [values[0]]
        for v in values[1:]:
            if v - cur[-1] <= 25:
                cur.append(v)
            else:
                groups.append(cur)
                cur = [v]
        groups.append(cur)
        return [int(np.median(gr)) for gr in groups if len(gr) >= 4]

    bx, by = cluster(cols), cluster(rows)

    # Grout lines are evenly spaced (~310 px); veins also flip the dark/light vote, so keep the longest chain of boundaries whose gaps
    # are all one square wide, then step half a square in from its ends: square centres.
    def chain(b):
        best = []
        for i in range(len(b)):
            cur = [b[i]]
            for v in b[i + 1:]:
                if 270 <= v - cur[-1] <= 350:
                    cur.append(v)
            if len(cur) > len(best):
                best = cur
        return best

    def pick(b, size):
        c = chain(b)
        step = (c[-1] - c[0]) / float(len(c) - 1)
        centres = [int(round(c[0] - step / 2 + i * step)) for i in range(len(c) + 1)]
        centres = [v for v in centres if v >= 0 and v <= size]
        best = None
        for i in range(len(centres) - 2):
            mid = (centres[i] + centres[i + 2]) / 2.0
            if best is None or abs(mid - size / 2.0) < abs((best[0] + best[1]) / 2.0 - size / 2.0):
                best = (centres[i], centres[i + 2])
        return best

    x0, x1 = pick(bx, w)
    y0, y1 = pick(by, h)
    side = min(x1 - x0, y1 - y0)
    print('  marble boundaries x=%s y=%s -> crop x %d..%d y %d..%d (%d px)' % (bx, by, x0, x0 + side, y0, y0 + side, side))
    return a[y0:y0 + side, x0:x0 + side].copy()


def crop_painted(a):
    al = a[:, :, 3]
    ys, xs = np.nonzero(al > 16)
    return a[max(ys.min() - 2, 0):ys.max() + 3, xs.min():xs.max() + 1].copy()


def back_doorway(a):
    """Lays every see-through pixel enclosed by the door over a painted-dark backing (brown-black, a soft vertical gradient and a
    little noise so it reads as deep shadow, not a flat black hole)."""
    h, w = a.shape[:2]
    passable = a[:, :, 3] < 128
    outside = np.zeros((h, w), bool)
    q = deque()
    for x in range(w):
        for y in (0, h - 1):
            if passable[y, x] and not outside[y, x]:
                outside[y, x] = True
                q.append((y, x))
    for y in range(h):
        for x in (0, w - 1):
            if passable[y, x] and not outside[y, x]:
                outside[y, x] = True
                q.append((y, x))
    while q:
        y, x = q.popleft()
        for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            ny, nx = y + dy, x + dx
            if 0 <= ny < h and 0 <= nx < w and passable[ny, nx] and not outside[ny, nx]:
                outside[ny, nx] = True
                q.append((ny, nx))
    # Enclosed = not outside and not fully opaque. Grow the outside mask by 2 px so the outer edge antialiasing stays.
    enclosed = (~outside) & (a[:, :, 3] < 250)
    ys, xs = np.nonzero(enclosed)
    if len(ys) == 0:
        return a, 0
    top, bottom = ys.min(), ys.max()
    rng = np.random.default_rng(7)
    out = a.copy()
    t = (np.arange(h)[:, None] - top) / max(bottom - top, 1)
    t = np.clip(t, 0, 1)
    # brown-black: top (deep) 20,14,10 -> bottom (near the light) 46,32,22
    base = np.stack([20 + 26 * t, 14 + 18 * t, 10 + 12 * t], axis=-1) * np.ones((1, w, 1))
    base = base + rng.normal(0, 2.0, size=(h, w, 1))
    alpha = out[:, :, 3:4] / 255.0
    comp = out[:, :, :3] * alpha + base * (1 - alpha)
    out[:, :, :3] = np.where(enclosed[:, :, None], comp, out[:, :, :3])
    out[:, :, 3] = np.where(enclosed, 255, out[:, :, 3])
    return out, int(enclosed.sum())


def tile_preview(a, name, tx, ty):
    reps_x = 3 if tx else 1
    reps_y = 3 if ty else 1
    img = np.tile(a, (reps_y, reps_x, 1))
    im = Image.fromarray(img.astype(np.uint8), 'RGBA' if img.shape[2] == 4 else 'RGB').convert('RGB')
    im.thumbnail((1800, 1800), Image.LANCZOS)
    im.save(os.path.join(SHOTS, 'p1_tile_%s.jpg' % name), quality=85)


def load(path):
    return np.array(Image.open(path).convert('RGBA')).astype(np.float64)


def save(a, path):
    Image.fromarray(np.clip(a, 0, 255).round().astype(np.uint8), 'RGBA').save(path)


def main():
    os.makedirs(SHOTS, exist_ok=True)
    zk = os.path.join(INBOX, 'zk')
    out_dna = os.path.join(zk, 'DNA')
    os.makedirs(out_dna, exist_ok=True)
    for id_ in DNA:
        src = DRIVE + 'Approved_ZoneKits/DNA/%s.png' % id_
        a = load(src)
        note = []
        if id_ == 'DNA-FLOOR-MARBLE':
            a = crop_marble(a)
            note.append('cropped to 2x2 squares')
        if id_ == 'DNA-RAIL-PARTITION':
            a = crop_painted(a)
            note.append('cropped to the painted area %dx%d' % (a.shape[1], a.shape[0]))
        if id_ in TILEABLE:
            tx, ty = TILEABLE[id_]
            for horizontal, on in ((True, tx), (False, ty)):
                if not on:
                    continue
                before = seam_step(a, horizontal)
                band = max(8, int((a.shape[1] if horizontal else a.shape[0]) * 0.03))
                a = blend_seam(a, horizontal, band)
                note.append('%s seam %.1f -> %.1f' % ('x' if horizontal else 'y', before, seam_step(a, horizontal)))
            tile_preview(a, id_, tx, ty)
        save(a, os.path.join(out_dna, id_ + '.png'))
        print('%s %dx%d %s' % (id_, a.shape[1], a.shape[0], '; '.join(note)))
    for folder, ids in OTHER_ZONES.items():
        os.makedirs(os.path.join(zk, folder), exist_ok=True)
        for id_ in ids:
            shutil.copy2(DRIVE + 'Approved_ZoneKits/%s/%s.png' % (folder, id_), os.path.join(zk, folder, id_ + '.png'))
    env = os.path.join(INBOX, 'Approved_EnvKit')
    os.makedirs(env, exist_ok=True)
    for id_, folder in TOWN.items():
        src = DRIVE + '%s/%s.png' % (folder, id_)
        if id_ == 'TOWN-PROP-CELLAR-FOURSEALS-OPEN':
            a, n = back_doorway(load(src))
            save(a, os.path.join(env, id_ + '.png'))
            Image.fromarray(a.astype(np.uint8), 'RGBA').convert('RGB').save(os.path.join(SHOTS, 'p1_cellar_open_backed.jpg'), quality=85)
            print('%s: %d see-through pixels backed' % (id_, n))
        else:
            shutil.copy2(src, os.path.join(env, id_ + '.png'))
    print('inbox: %s' % os.path.abspath(INBOX))


if __name__ == '__main__':
    sys.exit(main())
