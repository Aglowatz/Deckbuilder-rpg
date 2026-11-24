"""Fable big pass Nov 23: the eight draft cards (docs/design/draft_cards.md, the owner's "add them" of Nov 23) go into the card
sheet's CSV, each at the end of its Path section with the next free ID, and their scripts into data/scripts/. Idempotent.
    python tools/nov23_add_cards.py
Then: bash tools/import_cards.sh --write ; bash tools/import_cards.sh --stamp"""
import csv
import io
import os

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
SHEET = os.path.join(ROOT, 'data', 'source', 'card_list.csv')
SOURCE = 'Fable big pass Nov 23 (draft cards)'
STYLE = 'Batch 20 (docs/art/batch20.csv, %s).'

# section header -> rows [number, rarity, name, cost, type, text, P/T, flavour, art row, card id]
CARDS = {
    'Refusemancers:': [
        ['37', '(U)', 'Late-Pick Hero', '2(R)', 'Unit', 'This unit gets +1/+1 for each card in your Refuse Pile, up to +4/+4.', '1/1',
         'Nobody wanted him at pick three. Everybody wanted him by turn nine.', 'DR-05', 'R-37'],
    ],
    'Beefcake:': [
        ['38', '(E)', 'Bomb in the Pack', '3(B)(B)', 'Spell', 'Deal 4 damage to each enemy unit.', '',
         'You open the pack. You see it. You try very hard to keep a straight face.', 'DR-04', 'B-38'],
    ],
    'Gourmand / Necrocrat:': [
        ['17', '(E)', 'Table Captain', '2(G)(N)', 'Unit', 'When this unit enters, create an Ingredient and a Red Tape.\n\nYour other units get +0/+1.', '3/4',
         'He seats the living and the dead alike, and nobody gets the table by the window.', 'DR-06', 'GN-17'],
    ],
    '4 Color:': [
        ['4', '(L)', 'Octavia Eightfold', '2(B)(G)(N)(R)', 'Unit',
         'Swat.\n\nThe House Deals: when this unit enters, draw four cards.\n\nAt the start of your turn, choose one: create an Iron, a Red Tape, an Ingredient or a Garbage.', '4/8',
         'Eight arms, four Paths, one house. The house always deals, darling.', 'DR-07', 'P4-04'],
    ],
    'Colorless:': [
        ['37', '(U)', 'First Pick', '1', 'Spell', 'Peek 3, then draw a card.', '',
         'One of three. It is always one of three.', 'DR-01', 'C-37'],
        ['38', '(E)', 'Wheel the Table', '3', 'Spell', 'Each player shuffles their hand into their deck, then draws four cards.', '',
         'Everybody passes to the left. No, your other left.', 'DR-02', 'C-38'],
        ['39', '(C)', 'Signal Reader', '2', 'Unit', "When this unit enters, look at the opponent's hand.", '2/2',
         'She knows what you passed. She knows what it means. She is very disappointed.', 'DR-03', 'C-39'],
        ['40', '(E)', 'Trey Pickett', '3', 'Unit',
         'When this unit enters, Peek 3.\n\nPick It, Pick It, PICK IT!: at the start of your turn, choose one: draw a card, gain 2 HP, or put a buff on this unit.', '2/3',
         'Three cards, one choice, no refunds, and step right up!', 'DR-08', 'C-40'],
    ],
}

SCRIPTS = {
    'cards_refusemancer.txt': [
        ('R-37', 'Late-Pick Hero', ['static => selfstat(min(count(refuse.card.mine),4),min(count(refuse.card.mine),4))']),
    ],
    'cards_beefcake.txt': [
        ('B-38', 'Bomb in the Pack', ['play => damage(all(unit.opp),4)']),
    ],
    'cards_dual.txt': [
        ('GN-17', 'Table Captain', ['enter => create(ingredient); create(redtape)', 'aura(unit.mine.other) => stat(0,1)']),
    ],
    'cards_multi.txt': [
        ('P4-04', 'Octavia Eightfold', ['kw swat', 'enter => draw(4)', 'sot => choose({create(iron)},{create(redtape)},{create(ingredient)},{create(garbage)})']),
    ],
    'cards_colorless.txt': [
        ('C-37', 'First Pick', ['play => peek(3); draw(1)']),
        ('C-38', 'Wheel the Table', ['play => wheel(4)']),
        ('C-39', 'Signal Reader', ['enter => reveal_hand(opp)']),
        ('C-40', 'Trey Pickett', ['enter => peek(3)', 'sot => choose({draw(1)},{gain(me,2)},{buff(self,1)})']),
    ],
}


def main():
    rows = list(csv.reader(io.open(SHEET, encoding='utf-8-sig', newline='')))
    have = set(row[14] for row in rows if len(row) > 14)
    added = 0
    for section, cards in CARDS.items():
        start = next(i for i, row in enumerate(rows) if row and row[0] == section)
        last = start
        for i in range(start + 1, len(rows)):
            if rows[i] and rows[i][0].endswith(':') and not (len(rows[i]) > 14 and rows[i][14]):
                break
            if len(rows[i]) > 14 and rows[i][14]:
                last = i
        for card in cards:
            if card[9] in have:
                continue
            last += 1
            rows.insert(last, [card[0], card[1], card[2], card[3], card[4], card[5], card[6], card[7], STYLE % card[8], '', '', '', '', SOURCE, card[9]])
            added += 1
    out = io.StringIO()
    csv.writer(out, lineterminator='\n').writerows(rows)
    io.open(SHEET, 'w', encoding='utf-8', newline='').write(out.getvalue())
    scripted = 0
    for name, entries in SCRIPTS.items():
        path = os.path.join(ROOT, 'data', 'scripts', name)
        text = io.open(path, encoding='utf-8', newline='').read()
        newline = '\r\n' if '\r\n' in text else '\n'
        for card_id, title, lines in entries:
            if ('== %s ' % card_id) in text:
                continue
            if not text.endswith(newline):
                text += newline
            text += newline + '== %s @000000000000  # %s' % (card_id, title) + newline + newline.join(lines) + newline
            scripted += 1
        io.open(path, 'w', encoding='utf-8', newline='').write(text)
    print('card_list.csv: %d rows added; scripts: %d added' % (added, scripted))


if __name__ == '__main__':
    main()
