"""Fable Nov 24 (Part 5): the owner's card changes, in the card sheet's CSV and the scripts.
  - Plate It (G-20): costs 1 less (2(G); it was 3(G)).
  - Staff Appreciation Dinner (GN-08): costs 1 less (1(G)(N); it was 2(G)(N)).
  - Dinner Is Served (G-16): costs 1 less (1(G); it was 2(G)).
  - Idiot Sandwich (GB-11): it can Plate ANY unit (the "attack 4 or less" limit is gone).
Idempotent.    python tools/nov24_card_changes.py   then   bash tools/import_cards.sh --write ; --stamp ; generate_content"""
import csv
import io
import os

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
SHEET = os.path.join(ROOT, 'data', 'source', 'card_list.csv')
COSTS = {'G-20': ('3(G)', '2(G)'), 'GN-08': ('2(G)(N)', '1(G)(N)'), 'G-16': ('2(G)', '1(G)')}
SANDWICH_OLD = 'Plate target unit with attack 4 or less. Deal 2 damage to its controller.'
SANDWICH_NEW = 'Plate target unit. Deal 2 damage to its controller.'
SCRIPT_OLD = 'play t=unit.atk<=4 => plate(t); damage(ctl(t),2)'
SCRIPT_NEW = 'play t=unit => plate(t); damage(ctl(t),2)'


def main():
    rows = list(csv.reader(io.open(SHEET, encoding='utf-8-sig', newline='')))
    changed = 0
    for row in rows:
        if len(row) <= 14:
            continue
        if row[14] in COSTS and row[3] == COSTS[row[14]][0]:
            row[3] = COSTS[row[14]][1]
            changed += 1
        if row[14] == 'GB-11' and row[5] == SANDWICH_OLD:
            row[5] = SANDWICH_NEW
            changed += 1
    out = io.StringIO()
    csv.writer(out, lineterminator='\n').writerows(rows)
    io.open(SHEET, 'w', encoding='utf-8', newline='').write(out.getvalue())
    path = os.path.join(ROOT, 'data', 'scripts', 'cards_dual.txt')
    text = io.open(path, encoding='utf-8', newline='').read()
    if SCRIPT_OLD in text:
        io.open(path, 'w', encoding='utf-8', newline='').write(text.replace(SCRIPT_OLD, SCRIPT_NEW, 1))
        changed += 1
    print('changes applied: %d' % changed)


if __name__ == '__main__':
    main()
