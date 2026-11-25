"""Fable Nov 24 (Part 6): one ranked list from the draft ban sims' batch tables.
Reads docs/design/sim/nov24/ban_gear_*.md (the Common and Uncommon pieces), ban_items_*.md (the items) and, for the whole
picture, docs/design/sim/nov23/ban_gear_*.md (the Epic and Legendary pieces of the big pass), and writes
docs/design/sim/nov24/ban_summary.md: every piece by what it adds to a bare draft deck's win rate, then the items.
A piece is 48 games against elite-level rivals on the same decks and seeds, so read a change under about 10 points as noise.
    python tools/nov24_ban_summary.py"""
import glob
import io
import os
import re

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
SIM = os.path.join(ROOT, 'docs', 'design', 'sim')


def rows(pattern, columns):
    result = []
    for path in sorted(glob.glob(os.path.join(SIM, pattern))):
        with io.open(path, encoding='utf-8') as handle:
            for line in handle:
                cells = [cell.strip() for cell in line.strip().strip('|').split('|')]
                if len(cells) == columns and re.match(r'^[+-]?\d+$', cells[-1]) and cells[-2].endswith('%'):
                    result.append(cells + [os.path.basename(os.path.dirname(path)) + '/' + os.path.basename(path)])
    return result


def main():
    gear = rows('nov24/ban_gear_*.md', 5) + rows('nov23/ban_gear_*.md', 5)
    items = rows('nov24/ban_items_*.md', 3) + rows('nov24/ban_items_*.md', 4)
    seen = set()
    unique = []
    for row in gear:
        if row[0] not in seen:
            seen.add(row[0])
            unique.append(row)
    unique.sort(key=lambda row: -int(row[4]))
    lines = ['# Draft equipment and items, by what each adds (Fable Nov 24)', '',
        'Merged by `python tools/nov24_ban_summary.py` from the batch tables of `docs/design/sim/nov24/` (the Common and Uncommon pieces and the items, '
        'measured Nov 24) and `docs/design/sim/nov23/` (the Epic and Legendary pieces, measured Nov 23). Each piece: one drafted deck per Path with that piece alone, '
        '48 games against elite-level rivals on the same decks and seeds as the bare deck. **A change under about 10 points is noise at this sample.**', '',
        '## Equipment (%d pieces)' % len(unique), '', '| Piece | Slot | Rarity | Win rate with it | Change | Batch |', '|---|---|---|---:|---:|---|']
    for row in unique:
        lines.append('| %s | %s | %s | %s | %s | `%s` |' % (row[0], row[1], row[2], row[3], row[4] if row[4].startswith(('+', '-')) else '+' + row[4], row[5]))
    strong = [row for row in unique if int(row[4]) >= 20]
    lines += ['', '**At +20 or more:** ' + (', '.join('%s (%s)' % (row[0].split(' (`')[0], row[4]) for row in strong) if strong else 'none') + '.', '']
    lines += ['## Items (%d)' % len(items), '']
    if items:
        width = len(items[0]) - 1
        lines += ['| Item | ' + ('Rarity | ' if width == 4 else '') + 'Win rate with it | Change | Batch |', '|---|' + ('---|' if width == 4 else '') + '---:|---:|---|']
        for row in sorted(items, key=lambda row: -int(row[-2])):
            lines.append('| ' + ' | '.join(row[:-1]) + ' | `%s` |' % row[-1])
    else:
        lines.append('No item table yet.')
    with io.open(os.path.join(SIM, 'nov24', 'ban_summary.md'), 'w', encoding='utf-8', newline='\n') as handle:
        handle.write('\n'.join(lines) + '\n')
    print('\n'.join(lines[6:]))


if __name__ == '__main__':
    main()
