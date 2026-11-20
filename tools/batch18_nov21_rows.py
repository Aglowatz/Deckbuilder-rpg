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
    # Part 7.1: the Buffet's sushi side dungeon, "The Raw Deal" (built today from existing pieces: the pavilion model with its noren,
    # lanterns and counter, the freezer door in its base, a plain board for the sign)
    ['BUFF-HERO-RAWDEAL-FRONT', 'The Raw Deal: a painted sushi front (the side dungeon\'s entrance)',
     DRIVE + 'Approved_ZoneKits/Buffet/BUFF-HERO-RAWDEAL-FRONT.png', '1536x1024 PNG, transparent',
     'The front of the sushi spot in the Endless Buffet\'s east district, behind Colonel Casserole\'s gate (BuffetLayout.OMAKASE_PAVILION)',
     'The modelled pavilion BUFF-HERO-OMAKASE-PAVILION as seen from the front (a 3D stand-in)', 'To make (Batch 18)',
     "Painted storybook building front, seen straight on, transparent background: a small Japanese sushi counter shop on a white stone "
     "base. A red tiled roof with curled eaves, a short green noren curtain across the top of the opening, a row of round paper lanterns, "
     "a pale wooden counter with four stools and small plates of sushi, a bonsai in a pot, stone steps at the right. In the stone base at "
     "the left: a heavy steel walk-in freezer door with a round window and frost at its edges. Warm evening light. No text, no people.",
     'docs/overnight_shots/nov20/p7_raw_deal_front.jpg (today\'s stand-in, same layout); assets/art/vendors/VS-BELLOWS.webp (painting style only)'],
    ['BUFF-SIGN-RAWDEAL', 'The Raw Deal: its hanging sign',
     DRIVE + 'Approved_ZoneKits/Buffet/BUFF-SIGN-RAWDEAL.png', '1024x1024 PNG, transparent',
     'The sign beside the freezer door of the Raw Deal (sign.mini_dungeon)', 'A plain board with the freezer icon', 'To make (Batch 18)',
     "Painted storybook shop sign, transparent background: a dark wooden plaque hanging from a wrought-iron bracket, a cream paper panel "
     "in its middle with one picture and no lettering: a fish skeleton crossed with a pair of chopsticks, and a small snowflake in one "
     "corner (the way in is through a freezer). A red paper lantern hangs under the plaque. Warm colours, bold readable silhouette at "
     "small size. No text.",
     'assets/art/icons/ICON-ENERGY-G.webp (the Gourmand colours); docs/overnight_shots/nov20/p7_raw_deal_front.jpg (where it hangs)'],
    # Part 5.3: the one Wardrobe piece with no picture of its own (hats and the other cloaks all have ICON-COS-*)
    ['ICON-COS-PLAINCLOAK', 'The Plain Cloak by itself (the Wardrobe\'s Your Look)',
     DRIVE + 'Approved_Icons/ICON-COS-PLAINCLOAK.png', '1024x1024 PNG, transparent',
     'The Wardrobe and Pip Threadwell\'s shop when the Plain Cloak (or a dye for it) is shown', 'A generic character icon, tinted with the dye',
     'To make (Batch 18)',
     "A single game icon, transparent background, same style and framing as the attached cloak icon: a plain hooded travelling cloak by "
     "itself, hung as if on an invisible stand, three-quarter view, simple brass clasp at the neck, a worn hem. Painted in LIGHT NEUTRAL "
     "GREY-CREAM cloth with clear shading and folds and no pattern, because the game tints it to each dye colour. No text, no figure.",
     'assets/art/icons/ICON-COS-REDCAPE.webp (style and framing); assets/art/icons/ICON-COS-TATTERED.webp (a hooded cloak)'],
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
