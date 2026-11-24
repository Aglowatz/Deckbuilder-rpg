"""Fable big pass Nov 23 (Part 1): a contact sheet of Batch 20's pictures as they sit in the game (the imported, compressed
files), for the report. Writes docs/overnight_shots/nov23b/p1_batch20_in_game_files.jpg and prints any id it cannot find.
    python tools/art/batch20_sheet.py"""
import csv
import io
import os

from PIL import Image, ImageDraw

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..')
CARD_IDS = {'DR-01': 'C-37', 'DR-02': 'C-38', 'DR-03': 'C-39', 'DR-04': 'B-38', 'DR-05': 'R-37', 'DR-06': 'GN-17', 'DR-07': 'P4-04', 'DR-08': 'C-40'}


def main():
    rows = list(csv.DictReader(io.open(os.path.join(ROOT, 'docs', 'art', 'batch20.csv'), encoding='utf-8')))
    index = {}
    for folder, _dirs, files in os.walk(os.path.join(ROOT, 'assets')):
        for name in files:
            if name.endswith(('.webp', '.png')):
                index.setdefault(os.path.splitext(name)[0], os.path.join(folder, name))
    found, missing = [], []
    for row in rows:
        key = CARD_IDS.get(row['id'], row['id'])
        path = index.get(key)
        if path is None and key.startswith('SPR-'):
            # a sprite frame: assets/art/world_test/sprites/<CHARACTER>/<FRAME>.png
            parts = key[4:].split('-', 1)
            if len(parts) == 2:
                guess = os.path.join(ROOT, 'assets', 'art', 'world_test', 'sprites', parts[0], parts[1] + '.png')
                path = guess if os.path.exists(guess) else None
        if path is None:
            missing.append(row['id'])
        else:
            found.append((row['id'], path))
    cols, cell = 10, 190
    lines = (len(found) + cols - 1) // cols
    sheet = Image.new('RGB', (cols * cell, lines * (cell + 18)), (40, 36, 52))
    draw = ImageDraw.Draw(sheet)
    for n, (label, path) in enumerate(found):
        picture = Image.open(path).convert('RGBA')
        picture.thumbnail((cell - 10, cell - 10))
        x = (n % cols) * cell + (cell - picture.size[0]) // 2
        y = (n // cols) * (cell + 18) + (cell - picture.size[1]) // 2
        sheet.paste(picture, (x, y), picture)
        draw.text(((n % cols) * cell + 4, (n // cols) * (cell + 18) + cell + 2), label[:28], fill=(240, 230, 200))
    out = os.path.join(ROOT, 'docs', 'overnight_shots', 'nov23b', 'p1_batch20_in_game_files.jpg')
    sheet.save(out, quality=85)
    print('%d rows, %d on the sheet, not found as a file of that name: %s' % (len(rows), len(found), ', '.join(missing) or 'none'))


if __name__ == '__main__':
    main()
