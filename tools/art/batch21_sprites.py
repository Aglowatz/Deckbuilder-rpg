"""Batch 21 (Fable Nov 25, Part 1): slices the mole farm hand's four walk sheets (SPR-DUMPWORKER-WALK-<DIR>.png, four frames
left to right, 1536x1024, transparent) into assets/art/world_test/sprites/DUMPWORKER/<DIR>_WALK<1-4>.png on the set's own
canvas (368x504, feet on the baseline 16 px above the bottom, the figure as tall as his standing frames), and adds the walk
directions to the sprite manifest. The set's art looks LEFT, so the SIDE and FRONTSIDE sheets (painted looking right) are
mirrored. The standing frames are not touched. Also writes a check sheet. Idempotent.
    python tools/art/batch21_sprites.py"""
import io
import json
import os

import numpy as np
from PIL import Image, ImageOps

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
SOURCE = 'G:/My Drive/Card Game Art/Approved_Sprites'
OUT = os.path.join(ROOT, 'assets', 'art', 'world_test', 'sprites', 'DUMPWORKER')
MANIFEST = os.path.join(ROOT, 'assets', 'art', 'world_test', 'sprites', 'manifest.json')
CANVAS = (368, 504)
BASELINE = 504 - 16
DIRS = ['FRONT', 'FRONTSIDE', 'SIDE', 'BACK']
MIRROR = {'FRONTSIDE', 'SIDE'}
# the standing frame whose height and middle each direction follows
IDLE_OF = {'FRONT': 'FRONT_IDLE', 'FRONTSIDE': 'FRONT_IDLE', 'SIDE': 'SIDE_IDLE', 'BACK': 'BACK_IDLE'}
ALPHA_MIN = 24


def clean_edges(image):
    """No chroma was found on these sheets (measured: no green or magenta edge pixels). Faint stray alpha (under 10 %) is dropped."""
    data = np.asarray(image).copy()
    data[data[..., 3] < ALPHA_MIN] = 0
    return Image.fromarray(data, 'RGBA')


def split_four(sheet):
    alpha = np.asarray(sheet)[..., 3]
    columns = (alpha >= ALPHA_MIN).sum(axis=0) > 0
    runs, start = [], None
    for x, on in enumerate(columns):
        if on and start is None:
            start = x
        if not on and start is not None:
            runs.append([start, x])
            start = None
    if start is not None:
        runs.append([start, len(columns)])
    # join slivers (a pitchfork tine apart from its body) to the nearest big run
    runs = [run for run in runs if run[1] - run[0] > 4]
    while len(runs) > 4:
        gaps = [runs[i + 1][0] - runs[i][1] for i in range(len(runs) - 1)]
        i = gaps.index(min(gaps))
        runs[i] = [runs[i][0], runs[i + 1][1]]
        del runs[i + 1]
    assert len(runs) == 4, 'expected four frames, found %d' % len(runs)
    frames = []
    for x0, x1 in runs:
        frame = sheet.crop((x0, 0, x1, sheet.size[1]))
        frames.append(frame.crop(frame.getbbox()))
    return frames


def main():
    report = []
    idle_box = {}
    for key in set(IDLE_OF.values()):
        idle = Image.open(os.path.join(OUT, key + '.png')).convert('RGBA')
        idle_box[key] = idle.getbbox()
    sheet_cells = []
    for direction in DIRS:
        sheet = clean_edges(Image.open('%s/SPR-DUMPWORKER-WALK-%s.png' % (SOURCE, direction)).convert('RGBA'))
        frames = split_four(sheet)
        if direction in MIRROR:
            frames = [ImageOps.mirror(frame) for frame in frames]
        box = idle_box[IDLE_OF[direction]]
        idle_height = box[3] - box[1]
        middle = (box[0] + box[2]) / 2.0 if direction != 'FRONTSIDE' else CANVAS[0] / 2.0
        heights = sorted(frame.size[1] for frame in frames)
        scale = idle_height / float((heights[1] + heights[2]) / 2.0)
        for n, frame in enumerate(frames, 1):
            size = (max(1, int(round(frame.size[0] * scale))), max(1, int(round(frame.size[1] * scale))))
            small = frame.resize(size, Image.LANCZOS)
            canvas = Image.new('RGBA', CANVAS, (0, 0, 0, 0))
            x = int(round(middle - size[0] / 2.0))
            x = max(0, min(CANVAS[0] - size[0], x))
            canvas.alpha_composite(small, (x, BASELINE - size[1]))
            name = '%s_WALK%d' % (direction, n)
            canvas.save(os.path.join(OUT, name + '.png'))
            sheet_cells.append((name, canvas))
            report.append('%s %dx%d' % (name, size[0], size[1]))
        report.append('  %s scale %.3f' % (direction, scale))
    # manifest: walk directions and frames
    with io.open(MANIFEST, encoding='utf-8', newline='') as handle:
        text = handle.read()
    data = json.loads(text)
    entry = data['DUMPWORKER']
    frames = set(entry['frames'])
    for direction in DIRS:
        for n in range(1, 5):
            frames.add('%s_WALK%d' % (direction, n))
    entry['frames'] = sorted(frames)
    entry['walk_dirs'] = DIRS
    newline = '\r\n' if '\r\n' in text else '\n'
    out = json.dumps(data, indent='\t', ensure_ascii=False).replace('\n', newline)
    if text.endswith(newline):
        out += newline
    with io.open(MANIFEST, 'w', encoding='utf-8', newline='') as handle:
        handle.write(out)
    # check sheet: the standing frames, then the walk frames, on a grey ground with the baseline drawn
    idles = [(key, Image.open(os.path.join(OUT, key + '.png')).convert('RGBA')) for key in ['FRONT_IDLE', 'SIDE_IDLE', 'BACK_IDLE', 'FRONT_TALK']]
    rows = [idles] + [sheet_cells[i:i + 4] for i in range(0, 16, 4)]
    check = Image.new('RGBA', (CANVAS[0] * 4, CANVAS[1] * len(rows)), (110, 120, 110, 255))
    for r, row in enumerate(rows):
        for c, (_name, picture) in enumerate(row):
            check.alpha_composite(picture, (c * CANVAS[0], r * CANVAS[1]))
        for x in range(check.size[0]):
            check.putpixel((x, r * CANVAS[1] + BASELINE), (255, 60, 60, 255))
    shots = os.path.join(ROOT, 'docs', 'overnight_shots', 'nov25')
    os.makedirs(shots, exist_ok=True)
    check.convert('RGB').resize((check.size[0] // 2, check.size[1] // 2), Image.LANCZOS).save(os.path.join(shots, 'p1_farmhand_walk_frames.jpg'), quality=85)
    print('\n'.join(report))


if __name__ == '__main__':
    main()
