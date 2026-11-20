"""Fable Nov 21 (Part 9): Batch 18 rows. Marks the 11 info-screen rows on hold, and adds / replaces tonight's rows in
docs/art/batch18_nov18.csv (safe to re-run: a row with the same id is replaced). Every description is self-contained and under 600
characters; every reference is a small file that exists.
   python tools/batch18_nov21_rows.py"""
import csv, os

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
PATH = os.path.join(ROOT, 'docs', 'art', 'batch18_nov18.csv')
HOLD = ['UI-INFO-PAGE', 'UI-INFO-RIBBON', 'UI-INFO-DIVIDER', 'UI-INFO-ROW', 'UI-INFO-TAB', 'UI-INFO-BTN-STATES', 'UI-INFO-SCROLLBAR',
        'UI-QUESTBOX', 'UI-QUEST-MARKS', 'UI-INFO-TOOLTIP', 'UI-MAP-FRAME']
HOLD_STATUS = 'ON HOLD (Nov 21): the owner is rethinking the look; do not make'
DRIVE = 'G:/My Drive/Card Game Art/'

# The Doppelganger before the Test Kitchen's last fight: one character and one room for both pictures (docs/art/doppelganger_nov21.md).
DOPPEL_WHO = ("She wears the Grand Chef's outfit: white toque with a gold fleur-de-lis band and red bow, silver curls, pearl "
              "earrings, white coat with gold filigree, red neckerchief.")
DOPPEL_ROOM = ("Room: a warm vaulted stone kitchen, arched windows, gold evening light, hanging copper pans, a copper vat at the right "
               "breathing green fumes.")

# id, asset, approved file, size, in-game use, replaces, status, description, references
ROWS = [
    ['STORY-REVEAL-KITCHEN', "The Doppelganger starts to take the Grand Chef's face off (remake, pair with STORY-DOPPEL)",
     DRIVE + 'Approved_KeyArt/STORY-REVEAL-KITCHEN.png', '1672x941 PNG (16:9), opaque',
     'The Test Kitchen cutscene before its last fight, beats 1 to 4',
     'STORY-REVEAL-KITCHEN (it does not match STORY-DOPPEL: see docs/art/doppelganger_nov21.md)', 'To make (Batch 18), a pair',
     "Painted storybook still. A woman chef behind a steel counter lifts her own smiling face off by the jaw like a soft mask; "
     "under it her chin is smooth, blank porcelain white,, a thin seam of violet light. " + DOPPEL_WHO + " Left foreground, "
     "from behind: a young man in a teal hooded cloak. " + DOPPEL_ROOM + " No text.",
     'assets/art/keyart/STORY-REVEAL-KITCHEN.webp (keep this framing); assets/art/portraits/NPC-DOPPEL.webp (her outfit)'],
    ['STORY-DOPPEL', "The Doppelganger with the face off: no face of its own (remake, pair with STORY-REVEAL-KITCHEN)",
     DRIVE + 'Approved_KeyArt/STORY-DOPPEL.png', '1672x941 PNG (16:9), opaque',
     'The same cutscene, beat 5 (full screen, then behind the last line before the fight)',
     'STORY-DOPPEL (a black smoke creature with claws in a cannon factory: another character in another room)', 'To make (Batch 18), a pair',
     "Painted storybook still, a moment after the attached picture. The woman chef stands behind the steel counter, her "
     "removed smiling face in one hand like a limp mask. Her head is a smooth, blank porcelain-white oval, a thin seam of violet light "
     "at the hairline. Sad, not a monster. " + DOPPEL_WHO + " " + DOPPEL_ROOM + " No text.",
     'assets/art/keyart/STORY-REVEAL-KITCHEN.webp (the room, the counter, the light); assets/art/portraits/CUT-DOPPEL.webp (her outfit)'],
]


def main():
    rows = list(csv.reader(open(PATH, encoding='utf-8', newline='')))
    header, body = rows[0], rows[1:]
    status = header.index('status')
    held = 0
    for row in body:
        if row[0] in HOLD:
            row[status] = HOLD_STATUS
            held += 1
    assert held == len(HOLD), held
    for new in ROWS:
        assert len(new) == len(header), new[0]
        assert len(new[7]) < 600, (new[0], len(new[7]))
        for ref in new[8].split(';'):
            name = ref.strip().split(' (')[0]
            if name.startswith('assets/') or name.startswith('docs/'):
                assert os.path.exists(os.path.join(ROOT, name)), name
        body = [row for row in body if row[0] != new[0]] + [new]
    with open(PATH, 'w', encoding='utf-8', newline='') as handle:
        writer = csv.writer(handle, lineterminator='\n')
        writer.writerow(header)
        writer.writerows(body)
    print('%d rows held, %d rows added or replaced, %d rows in all' % (held, len(ROWS), len(body)))
    for new in ROWS:
        print('  %-24s %3d chars' % (new[0], len(new[7])))


if __name__ == '__main__':
    main()
