"""Fable Nov 24: the new art needs of this pass, appended to docs/art/batch21.csv (the owner's rule: new art needs go there).
Nothing here blocks the build: every row has a stand-in in the game today (a game icon, a procedural emblem, a borrowed token).
Idempotent.    python tools/nov24_batch21_rows.py"""
import csv
import io
import os

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
PATH = os.path.join(ROOT, 'docs', 'art', 'batch21.csv')
STYLE = "Same painted storybook style as the other bestiary squares; carnival-casino palette of the Shuffle House (velvet red, marquee gold, baize green); family friendly."

ROWS = [
    ['BST-MAURICE', 'Maurice, Head of Security (bestiary square)', 'Approved_Bestiary/BST-MAURICE.png', '1024x1024 PNG', "The Shuffled Halls, the Velvet Gate: the battle plate and the next-fight picture", 'a game icon (guards)', 'To make',
     "A huge, gentle-faced walrus bouncer in a too-tight velvet tuxedo and an earpiece, arms folded behind a velvet rope on brass posts, a tiny guest list on a clipboard. " + STYLE, 'TOWN-HERO-SHUFFLEHOUSE, NPC-OCTAVIA'],
    ['BST-TILDA', 'Tilda Tinsel, Confetti Cannoneer (bestiary square)', 'Approved_Bestiary/BST-TILDA.png', '1024x1024 PNG', "The Shuffled Halls, the Tinsel Gate", 'a game icon (party popper)', 'To make',
     "A small, wiry raccoon girl in a sequinned ringmaster's jacket and goggles, grinning beside a brass confetti cannon twice her size, tinsel and paper streamers everywhere, a lit match in one paw. " + STYLE, 'NPC-RHONDA, NPC-OCTAVIA'],
    ['BST-DARJEELING', 'Madame Darjeeling (bestiary square)', 'Approved_Bestiary/BST-DARJEELING.png', '1024x1024 PNG', "The Shuffled Halls, the Tea Garden", 'a game icon (coffee cup)', 'To make',
     "An elegant elderly crane in a lace collar and a wide garden hat, pouring tea with perfect posture at a wrought-iron table among striped tents and potted roses, a deck of cards fanned beside the teapot, a cake stand, a steely polite smile. " + STYLE, 'V-MIREPOIX, NPC-OCTAVIA'],
    ['BST-HAL', '"Honest" Hal Lowball (bestiary square)', 'Approved_Bestiary/BST-HAL.png', '1024x1024 PNG', "The Shuffled Halls, the Back-Room Table", 'a game icon (poker hand)', 'To make',
     "A shifty weasel card sharp in a green eyeshade, sleeve garters and a pinstripe waistcoat, at a small round table under one hanging lamp, an ace poking out of his sleeve, chips stacked in front of him, an innocent face. " + STYLE, 'V-FIGSLY, NPC-DEX'],
    ['BST-LIZZIE', 'Dizzy Lizzie, Carousel Queen (bestiary square)', 'Approved_Bestiary/BST-LIZZIE.png', '1024x1024 PNG', "The Shuffled Halls, the Carousel", 'a game icon (spinning flame)', 'To make',
     "A cheerful, slightly cross-eyed pony in a carousel operator's striped blazer and a paper crown, one hoof on a big brass lever, painted carousel horses blurring past behind her, music notes in the air. " + STYLE, 'NPC-THUNDERABS, NPC-OCTAVIA'],
    ['BST-FINEPRINT', 'Professor Fineprint (bestiary square)', 'Approved_Bestiary/BST-FINEPRINT.png', '1024x1024 PNG', "The Shuffled Halls, the Rules Library", 'a game icon (scroll and quill)', 'To make',
     "A tiny, very old owl in half-moon glasses and a barrister's wig, perched on a tower of rulebooks, holding up one enormous page of tiny print with a magnifying glass, floor-to-ceiling shelves behind him. " + STYLE, 'NPC-ECTOMUND, NPC-PATE'],
    ['BST-PENNY', 'Penny Sleeves (bestiary square)', 'Approved_Bestiary/BST-PENNY.png', '1024x1024 PNG', "The Shuffled Halls, the Card Shop", 'a game icon (shop)', 'To make',
     "A fussy hamster shopkeeper in white cotton gloves and an apron, behind a glass counter of cards in sleeves and top-loaders, a DO NOT TOUCH sign, a price gun in one paw, glaring over her glasses. " + STYLE, 'V-SABLE, NPC-OCTAVIA'],
    ['TOK-VELVETROPE', 'Velvet Rope (token art)', 'Approved/Cards/TOK-VELVETROPE.png', 'card art, same size as the other tokens', "Maurice's starting token in the Shuffled Halls (a 0/4 with Wallflower)", "the Schmuck token's art", 'To make',
     "A red velvet rope on two brass posts standing very firmly in front of a doorway, a small brass sign: NOT TONIGHT. Card art in the game's token style.", 'T-23'],
    ['TOK-CONFETTI', 'Confetti Critter (token art)', 'Approved/Cards/TOK-CONFETTI.png', 'card art, same size as the other tokens', "Tilda Tinsel's cannon token in the Shuffled Halls (a 1/1)", "the Rat token's art", 'To make',
     "A small, delighted creature made entirely of paper streamers and confetti, mid-bounce, trailing glitter. Card art in the game's token style.", 'T-02'],
    ['TOK-HOUSESECURITY', 'House Security (token art)', 'Approved/Cards/TOK-HOUSESECURITY.png', 'card art, same size as the other tokens', "Maurice's backup in the Shuffled Halls (a 2/2)", "the Militia token's art", 'To make',
     "Two identical badgers in black suits and sunglasses stepping out from behind a red curtain, arms folded. Card art in the game's token style.", 'T-16'],
    ['UI-DRAFT-MODE-CLASSIC', 'Classic Draft (mode tile emblem)', 'Approved_UI/UI-DRAFT-MODE-CLASSIC.png', '768x512 PNG, transparent', "The Shuffle House menu, the Classic Draft tile (four modes, Nov 24)", 'four Path badges drawn by the game', 'To make',
     "The mock-up UI-DRAFT-MOCK-ARENA's Open Draft tile: four Path cards fanned out (red, blue, green, purple, each with its Path symbol) on a gold stand between velvet ropes, spotlight from above. No text.", 'UI-DRAFT-MOCK-ARENA'],
    ['UI-DRAFT-MODE-DUNGEON', 'Dungeon Draft (mode tile emblem)', 'Approved_UI/UI-DRAFT-MODE-DUNGEON.png', '768x512 PNG, transparent', "The Shuffle House menu, the Dungeon Draft tile", 'a castle game icon', 'To make',
     "A small folded dungeon map with a wax seal lying on a fan of cards, a tiny stone doorway rising out of the map like a pop-up book, torches either side. Same framing and light as UI-DRAFT-MODE-CLASSIC. No text.", 'UI-DRAFT-MOCK-ARENA'],
    ['UI-DRAFT-MODE-MYSTERY', 'Mystery Mini (mode tile emblem)', 'Approved_UI/UI-DRAFT-MODE-MYSTERY.png', '768x512 PNG, transparent', "The Shuffle House menu, the Mystery Mini tile", 'a question mark drawn by the game', 'To make',
     "The mock-up's Mystery Mini tile: two purple card backs with a glowing gold question mark, gold sparkle burst behind, with a small prize wheel peeking in at one side. No text.", 'UI-DRAFT-MOCK-ARENA'],
    ['UI-DRAFT-MODE-HIGH', 'High Rollers Draft (mode tile emblem)', 'Approved_UI/UI-DRAFT-MODE-HIGH.png', '768x512 PNG, transparent', "The Shuffle House menu, the High Rollers Draft tile", 'a coin pile game icon', 'To make',
     "A tall stack of gold chips and coins on green baize with a pair of gold dice and one face-down card on top wearing a tiny crown, red velvet curtain behind. Same framing and light as UI-DRAFT-MODE-CLASSIC. No text.", 'UI-DRAFT-MOCK-ARENA'],
    ['TOWN-HERO-SHUFFLEHOUSE-BACK', 'The Shuffle House, back and roof (texture sheet)', 'Approved_ZoneKits/town/TOWN-HERO-SHUFFLEHOUSE-BACK.png', '2048x1024 PNG', "The 3D body behind the painted front (Nov 24): one strip for the half-timbered wall, one for the big top's striped canvas", 'flat colours on the 3D body', 'To make',
     "A flat, unlit texture sheet painted in the same style and colours as TOWN-HERO-SHUFFLEHOUSE: the top half a seamless strip of the striped big-top canvas (red, blue, red, green, red, purple panels with gold seams and a row of marquee bulbs along the lower edge); the bottom half a seamless strip of cream half-timbered wall with dark beams, two card-suit stained-glass windows and ivy. No perspective, no shadows.", 'TOWN-HERO-SHUFFLEHOUSE'],
]


def main():
    text = io.open(PATH, encoding='utf-8-sig', newline='').read()
    rows = list(csv.reader(io.StringIO(text)))
    have = {row[0] for row in rows if row}
    added = 0
    out = io.StringIO()
    writer = csv.writer(out, lineterminator='\n')
    for row in rows:
        writer.writerow(row)
    for row in ROWS:
        if row[0] in have:
            continue
        writer.writerow(row)
        added += 1
    if added:
        io.open(PATH, 'w', encoding='utf-8', newline='').write(out.getvalue())
    print('batch 21 rows added: %d (now %d rows)' % (added, len(rows) - 1 + added))


if __name__ == '__main__':
    main()
