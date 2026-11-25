"""Fable Nov 24: the Bestiary entries of the Shuffled Halls' eight hand-made dealers (Trey and Octavia had theirs), so each
one's signature moves have a page to be listed on (tests/core/dungeon/test_encounter_scripts.gd). Inserted before Trey Pickett's
row, in room order. Safe to run again.
    python tools/nov24_bestiary_rows.py"""
import io
import json
import os

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
PATH = os.path.join(ROOT, 'data', 'bestiary', 'bestiary.json')
WHERE = 'The Shuffled Halls'
ROWS = [
    ('Maurice, Head of Security', 'foe', 'delapouite/guards', "The Velvet Gate's doorman: a neck like a tree stump, a clipboard, and a velvet rope he has never once unhooked for anybody."),
    ('Tilda Tinsel, Confetti Cannoneer', 'foe', 'delapouite/party-popper', "She fires the confetti cannon at the Tinsel Gate, on the hour and whenever she is losing. Some of the confetti has teeth."),
    ('Madame Darjeeling', 'elite', 'delapouite/coffee-cup', "The Tea Garden's hostess. She pours for everyone, herself first, and nobody has ever seen the bottom of her pot."),
    ('"Honest" Hal Lowball', 'elite', 'lorc/poker-hand', "The Back-Room Table's dealer. The ante is his idea, the deck is his own, and the quotation marks were the sign painter's."),
    ('Dizzy Lizzie, Carousel Queen', 'elite', 'lorc/flame-spin', "She rides the Carousel standing up and backwards. Everything of hers arrives at a gallop, until the music stops."),
    ('Professor Fineprint', 'elite', 'delapouite/scroll-quill', "The Rules Library's only reader. He wrote Rule 1, he will amend Rule 1, and he has a footnote ready for whatever you do next."),
    ('Dex Shufflewick', 'elite', 'delapouite/dice-six-faces-six', "The Roulette Pit's champion. He always goes first, the wheel always spins, and he swears those two things are not related."),
    ('Penny Sleeves', 'elite', 'delapouite/shop', "She runs the Card Shop and sleeves everything in it, the customers included if they stand still. You break it, you bought it."),
]


def main():
    with io.open(PATH, encoding='utf-8', newline='') as handle:
        text = handle.read()
    newline = '\r\n' if '\r\n' in text else '\n'
    lines = text.replace('\r\n', '\n').split('\n')
    anchor = next(index for index, line in enumerate(lines) if '"name": "Trey Pickett"' in line)
    indent = lines[anchor][:len(lines[anchor]) - len(lines[anchor].lstrip())]
    added = 0
    for name, kind, icon, blurb in ROWS:
        if any('"name": %s' % json.dumps(name, ensure_ascii=False) in line for line in lines):
            continue
        row = indent + '{"name": %s, "kind": "%s", "where": "%s", "icon": "%s", "blurb": %s},' % (
            json.dumps(name, ensure_ascii=False), kind, WHERE, icon, json.dumps(blurb, ensure_ascii=False))
        lines.insert(anchor + added, row)
        added += 1
    json.loads('\n'.join(lines))  # still valid
    with io.open(PATH, 'w', encoding='utf-8', newline='') as handle:
        handle.write(newline.join(lines))
    print('%d Bestiary rows added' % added)


if __name__ == '__main__':
    main()
