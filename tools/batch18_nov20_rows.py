"""Fable Nov 20 (Parts 1 and 8): tidies docs/art/batch18_nov18.csv. Removes NPC-PLAYER, STORY-MEMORY-4 and
TOWN-PROP-CELLAR-FOURSEALS-CLOSED (the owner: no change to the cloak; the vault seals stay in a row), re-does the colour rows for the
palette of Nov 20 (Gourmand blue, Necrocrat violet): the Necrocrat card back and pack stay (violet now, not slate), V-ALEMBIC goes
(red, blue, green and violet are all Path colours again), VS-ALEMBIC shrinks to one jar; adds the underground Arena's two pictures.
Run once; rows already present by id are replaced.   python tools/batch18_nov20_rows.py"""
import csv, os

PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'docs', 'art', 'batch18_nov18.csv')
STATUS = 'To make (Batch 18)'
REMOVE = {'NPC-PLAYER', 'STORY-MEMORY-4', 'TOWN-PROP-CELLAR-FOURSEALS-CLOSED', 'V-ALEMBIC'}
CAVE = ('A low-key UNDERGROUND cave dueling arena, NOT a colosseum: rough rock walls, a low rock ceiling, warm lantern light, a ring of chalk '
        'and rope on a worn stone floor, crates and plank benches for a small crowd, a few faded banners pinned to the rock. ')
ROWS = [
    ['UI-CARDBACK-N', 'Necrocrat card back, recoloured violet', '(to make)', '1024x1536 PNG (2:3), same layout as UI-CARDBACK-R', 'The back of Necrocrat cards (collection, packs, Alembic)',
     'UI-CARDBACK-N (its green field reads as the Refusemancer back; the Necrocrat colour is violet)', STATUS,
     'A fantasy trading-card back, portrait 2:3, same ornate gold filigree layout as the attached Refusemancer back, but in the Necrocrat colour: the four corner fields in deep VIOLET (about #9A5FC7, darker in the folds; no green fields), pale bone-white leaf scrolls, thin gold lines. In the centre the attached medallion unchanged: a pale skull wrapped in bright green ghost-flame on a dark slate disc in a cracked stone rim (the green flame stays). Painted storybook style, no text.',
     'assets/art/ui/UI-CARDBACK-N.webp (layout); UI-CARDBACK-R.webp (the back it must not look like); ICON-ENERGY-N.webp (medallion); docs/art/path_colour_swatches.png'],
    ['UI-PACK-N', 'Necrocrat card pack, recoloured violet (and its locked version)', '(to make)', '1024x1536 PNG, transparent, same layout as UI-PACK-R; plus UI-PACK-LOCKED-N as the same picture desaturated with a small padlock', 'The Necrocrat Path Pack in the pack shop and the pack opening',
     'UI-PACK-N and UI-PACK-LOCKED-N (the green wrapper reads as the Refusemancer pack; the Necrocrat colour is violet)', STATUS,
     'A sealed foil booster pack, portrait, gold crimped top and bottom edges, a cream band down the middle, exactly the layout of the attached pack, but the wrapper in deep VIOLET foil (about #9A5FC7; no green foil) with small pale stamped form-and-seal motifs. In the centre the attached medallion unchanged: a pale skull in bright green ghost-flame on a slate disc (the green flame stays). Painted storybook style, transparent background, no text.',
     'assets/art/ui/UI-PACK-N.webp (layout); UI-PACK-R.webp (the pack it must not look like); ICON-ENERGY-N.webp; docs/art/path_colour_swatches.png'],
    ['VS-ALEMBIC', "Auntie Alembic's shop picture, the four jars in the four Path colours", '(to make)', 'Same canvas as VS-ALEMBIC (16:9)', "The backdrop of Auntie Alembic's shop screen",
     'VS-ALEMBIC (the jars are blue, red, orange and green: orange is no Path, violet is missing). Low priority.', 'To make (Batch 18), low priority',
     'Repaint of the attached alchemy shop interior, everything unchanged (warm lamplit workshop, a black cauldron on the left with its many-coloured flame, a wooden counter across the front) except the four glowing crystal jars on the tray: they stand in this order left to right and in these colours: strong RED, clear BLUE, deep MOSS GREEN, VIOLET. No orange jar. No text.',
     'assets/art/vendors/VS-ALEMBIC.webp; docs/art/path_colour_swatches.png'],
    ['ARENA-MENU-BG', 'The Arena menu screen: an underground cave dueling arena', '(to make)', '1672x941 PNG (16:9), opaque', "The backdrop of the Arena's menu (Announcer Grand Bellows's screen: tiers, battles, puzzles)",
     'VS-BELLOWS (a colosseum; the story says a hidden cave under Crosspath)', STATUS,
     CAVE + 'Seen from the doorway at eye level: the ring on the left third under hanging lanterns; the right two thirds calmer and darker (a rock wall with a blank chalk slate, stacked crates) because menus sit there. Nobody in the picture. Painted storybook fantasy style, warm amber on cool grey rock. No text.',
     'assets/art/vendors/VS-BELLOWS.webp (framing and style only, not its colosseum); Approved_Portraits/NPC-BELLOWS.png'],
    ['BB-ARENA', 'The Arena battle board: the cave ring from above', '(to make)', '1536x864 PNG (16:9), opaque', "The battle board of every Arena battle and puzzle",
     'BB-ARENA (a sunlit colosseum floor)', STATUS,
     CAVE + 'A battle board seen steeply from above, framed like the attached board: the stone floor fills the middle as a wide, flat, evenly lit, empty playing surface with a faint chalk line across its centre; ring rope, lanterns, crates, benches and rock stay in the outer 12 %. Nobody in the picture. Painted storybook style. No text.',
     'assets/art/battleboards/BB-ARENA.webp (framing only, not its colosseum); BB-S-IRON.webp (a cave board that works)'],
]

if __name__ == '__main__':
    with open(PATH, newline='', encoding='utf-8') as handle:
        rows = list(csv.reader(handle))
    header, body = rows[0], rows[1:]
    ids = {row[0] for row in ROWS}
    out = []
    done = set()
    for row in body:
        if row[0] in REMOVE:
            continue
        if row[0] in ids:
            out.append(next(r for r in ROWS if r[0] == row[0]))
            done.add(row[0])
        else:
            out.append(row)
    out.extend(r for r in ROWS if r[0] not in done)
    for row in ROWS:
        assert len(row) == len(header), row[0]
        assert len(row[7]) < 600, '%s: %d characters' % (row[0], len(row[7]))
    with open(PATH, 'w', newline='', encoding='utf-8') as handle:
        csv.writer(handle).writerows([header] + out)
    print('%d rows' % len(out))
    for row in ROWS:
        print('  %-16s %d characters' % (row[0], len(row[7])))
