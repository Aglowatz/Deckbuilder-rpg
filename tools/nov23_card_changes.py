"""Fable big pass Nov 23 (Part 6): the owner's three number changes, in the card sheet's CSV, the scripts and the gear code.
  - Global Gains Platinum Membership (B-33): costs 2 less (1(B)), attaching costs 1, the unit gets Hustle, Overtime and Bulldoze,
    and it no longer returns to the hand.
  - Let Them Eat Cake (R-21): costs 1 less (1(R)).
  - Participation Trophy: 15 % more XP (it was 25 %).
Idempotent.    python tools/nov23_card_changes.py   then   bash tools/import_cards.sh --write ; --stamp ; generate_content"""
import csv
import io
import os

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
SHEET = os.path.join(ROOT, 'data', 'source', 'card_list.csv')
MEMBERSHIP = ("Exhaust, pay 1: attach to target unit you control. At the start of your turn, put a buff on attached unit; "
    "it gains Hustle, Overtime and Bulldoze.")


def main():
    rows = list(csv.reader(io.open(SHEET, encoding='utf-8-sig', newline='')))
    changed = 0
    for row in rows:
        if len(row) <= 14:
            continue
        if row[14] == 'B-33' and (row[3] != '1(B)' or row[5] != MEMBERSHIP):
            row[3] = '1(B)'
            row[5] = MEMBERSHIP
            changed += 1
        if row[14] == 'R-21' and row[3] != '1(R)':
            row[3] = '1(R)'
            changed += 1
    out = io.StringIO()
    csv.writer(out, lineterminator='\n').writerows(rows)
    io.open(SHEET, 'w', encoding='utf-8', newline='').write(out.getvalue())
    path = os.path.join(ROOT, 'data', 'scripts', 'cards_beefcake.txt')
    text = io.open(path, encoding='utf-8', newline='').read()
    old = ("attach\nsot => buff(host,1); kw_grant(host,hustle,perm); kw_grant(host,overtime,perm)\nwhen(attached_dies) => send_back(self)")
    new = ("attach | pay(1)\nsot => buff(host,1); kw_grant(host,hustle,perm); kw_grant(host,overtime,perm); kw_grant(host,bulldoze,perm)")
    newline = '\r\n' if '\r\n' in text else '\n'
    if old.replace('\n', newline) in text:
        text = text.replace(old.replace('\n', newline), new.replace('\n', newline), 1)
        io.open(path, 'w', encoding='utf-8', newline='').write(text)
        changed += 1
    gear = os.path.join(ROOT, 'core', 'data', 'expansion_gear.gd')
    code = io.open(gear, encoding='utf-8', newline='').read()
    before = '"Gain 25% more XP from everything.", "",'
    if before in code:
        code = code.replace(before, '"Gain 15% more XP from everything.", "",', 1)
        code = code.replace('[_mod(K.XP_BONUS_PERCENT, 25)])', '[_mod(K.XP_BONUS_PERCENT, 15)])  # Fable big pass Nov 23: 25 -> 15 (the owner)', 1)
        io.open(gear, 'w', encoding='utf-8', newline='').write(code)
        changed += 1
    print('changes applied: %d' % changed)


if __name__ == '__main__':
    main()
