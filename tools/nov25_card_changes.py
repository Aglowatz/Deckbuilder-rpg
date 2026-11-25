"""Fable Nov 25 (Part 6): the owner's card changes, in the card sheet's CSV and the scripts.
  - First Pick (C-37): peeks at 1 card (it was 3).
  - The Haunted Buffet (GN-07): costs 1 less (1(G)(N)) and uses one Ingredient (it was two).
  - Final Meal Request (GN-10): costs 1 less ((G)(N)).
  - "Ratatouille, Rodent de Cuisine" (GR-16) is renamed "Rodent De Cuisine".
  - Vigor Mortis (NB-03): costs 1 more (3(N)(B)).
  - Circle of Life Insurance (GRN-03): costs 1 less (1(G)(R)(N)).
  - Global Gains Platinum Membership (B-33): the attached unit has Hustle, Overtime and Bulldoze from the moment it is
    attached (a static grant of the host); only the buff comes at the start of each turn.
Idempotent.    python tools/nov25_card_changes.py   then   bash tools/import_cards.sh --write ; --stamp ; generate_content"""
import csv
import io
import os

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
SHEET = os.path.join(ROOT, 'data', 'source', 'card_list.csv')
COSTS = {'GN-07': ('2(G)(N)', '1(G)(N)'), 'GN-10': ('1(G)(N)', '(G)(N)'), 'NB-03': ('2(N)(B)', '3(N)(B)'), 'GRN-03': ('2(G)(R)(N)', '1(G)(R)(N)')}
TEXTS = {
    'C-37': ('Peek 3, then draw a card.', 'Peek 1, then draw a card.'),
    'GN-07': ('Use two Ingredients: create a 1/1 Hungry Ghost token with Flying. Do this only once per turn.',
              'Use an Ingredient: create a 1/1 Hungry Ghost token with Flying. Do this only once per turn.'),
    'B-33': ('Exhaust, pay 1: attach to target unit you control. At the start of your turn, put a buff on attached unit; it gains Hustle, Overtime and Bulldoze.',
             'Exhaust, pay 1: attach to target unit you control. Attached unit has Hustle, Overtime and Bulldoze. At the start of your turn, put a buff on attached unit.'),
}
NAMES = {'GR-16': ('Ratatouille, Rodent de Cuisine', 'Rodent De Cuisine')}
SCRIPTS = [
    ('data/scripts/cards_colorless.txt', 'play => peek(3); draw(1)', 'play => peek(1); draw(1)'),
    ('data/scripts/cards_dual.txt', 'act once | use(ingredient,2) => create(T-19)', 'act once | use(ingredient,1) => create(T-19)'),
    ('data/scripts/cards_dual.txt', '# Ratatouille, Rodent de Cuisine', '# Rodent De Cuisine'),
    ('data/scripts/cards_beefcake.txt',
     'attach | pay(1)\nsot => buff(host,1); kw_grant(host,hustle,perm); kw_grant(host,overtime,perm); kw_grant(host,bulldoze,perm)',
     'attach | pay(1)\nhost => kw(hustle,overtime,bulldoze)\nsot => buff(host,1)'),
]


def main():
    rows = list(csv.reader(io.open(SHEET, encoding='utf-8-sig', newline='')))
    changed = 0
    for row in rows:
        if len(row) <= 14:
            continue
        cid = row[14]
        if cid in COSTS and row[3] == COSTS[cid][0]:
            row[3] = COSTS[cid][1]
            changed += 1
        if cid in TEXTS and row[5] == TEXTS[cid][0]:
            row[5] = TEXTS[cid][1]
            changed += 1
        if cid in NAMES and row[2] == NAMES[cid][0]:
            row[2] = NAMES[cid][1]
            changed += 1
    out = io.StringIO()
    csv.writer(out, lineterminator='\n').writerows(rows)
    io.open(SHEET, 'w', encoding='utf-8', newline='').write(out.getvalue())
    for rel, old, new in SCRIPTS:
        path = os.path.join(ROOT, rel)
        text = io.open(path, encoding='utf-8', newline='').read()
        crlf = '\r\n' in text
        body = text.replace('\r\n', '\n')
        if old in body:
            body = body.replace(old, new, 1)
            changed += 1
            io.open(path, 'w', encoding='utf-8', newline='').write(body.replace('\n', '\r\n') if crlf else body)
    print('changes applied: %d (of 13 on a first run)' % changed)


if __name__ == '__main__':
    main()
