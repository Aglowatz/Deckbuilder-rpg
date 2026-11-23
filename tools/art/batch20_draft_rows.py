"""Draft mode, Phase 1 (Part 4): adds the draft rows to docs/art/batch20.csv and draws the draft dungeon's top-down plan
(docs/design/draft_dungeon_plan.jpg, copied to the Drive's Batch 20 Refs).      python tools/art/batch20_draft_rows.py
Every description stands on its own and is under 600 characters."""
import csv
import io
import os
import shutil

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..')
SHEET = os.path.join(ROOT, 'docs', 'art', 'batch20.csv')
REFS = 'G:/My Drive/Card Game Art/Batch 20 Refs/'
STATUS = 'To make (Batch 20) - Draft mode, Phase 1'
STYLE = 'Painterly digital art, clean bold shapes, soft cel shading, the whimsical look of the other art of The Wayward Path.'
TREY = ('Trey Pickett, a tall, tidy travelling draft-master in his forties: a long midnight-blue travelling coat with brass buttons, a mustard waistcoat, '
        'round spectacles, neat grey-streaked hair, a calm half-smile; a folding card table strapped to his back and three playing cards fanned in one gloved hand.')

ROWS = [
    ('NPC-TREY', 'Dialogue portrait of Trey Pickett, the travelling draft-master', '1024x1536 PNG, transparent background', 'His dialogue portrait (every Path zone) and the draft quests',
     '(none - NPC-TOWNSFOLK stands in)', 'Character portrait from the waist up, turned three-quarters to the viewer. ' + TREY + ' ' + STYLE, 'NPC-DEX.png (Approved_NPCs: the same kind of travelling card person), now_draft_host.jpg'),
    ('SPR-TREY-REF', "Reference sheet for Trey Pickett's world sprite set", '1536x1024 PNG', 'Keeps his four world frames consistent (not shown in the game)',
     '(none)', 'Turnaround reference, front, side and back views side by side on a plain background, full body. ' + TREY + ' ' + STYLE, 'NPC-TREY (this batch), SPR-DEX-REF.png'),
    ('SPR-TREY-FRONT_IDLE', 'World sprite of Trey Pickett - front idle', '1024x1536 PNG, transparent background', 'He stands by the trivia corner of each Path zone',
     '(none - the CITIZEN set stands in)', 'Full body, facing the viewer, standing still, three cards fanned in one hand, the folded table on his back. ' + TREY, 'SPR-TREY-REF (this batch), SPR-DEX-FRONT_IDLE.png'),
    ('SPR-TREY-SIDE_IDLE', 'World sprite of Trey Pickett - side idle', '1024x1536 PNG, transparent background', 'The same, seen from the side (the game mirrors it)',
     '(none)', 'Full body, seen from his right side, standing still, three cards fanned in one hand, the folded card table strapped to his back. ' + TREY, 'SPR-TREY-REF (this batch)'),
    ('SPR-TREY-BACK_IDLE', 'World sprite of Trey Pickett - back idle', '1024x1536 PNG, transparent background', 'The same, seen from behind',
     '(none)', 'Full body, seen from behind, standing still: the long midnight-blue coat and the folded card table strapped across his back fill the view. ' + TREY, 'SPR-TREY-REF (this batch)'),
    ('SPR-TREY-FRONT_TALK', 'World sprite of Trey Pickett - front, talking', '1024x1536 PNG, transparent background', 'Shown while he speaks',
     '(none)', 'Full body, facing the viewer, mid-sentence, holding out three fanned cards toward the viewer with one eyebrow raised. ' + TREY, 'SPR-TREY-FRONT_IDLE (this batch)'),
    ('VS-TREY', "Trey Pickett's draft table (screen backdrop)", '1920x1080 PNG', 'The backdrop of the Draft Table screen, behind the glass page',
     '(none - the plain glass page)', 'A folding card table set up under a striped travelling awning at dusk: a green baize top, three face-down cards in a row, a brass lantern, a tin cash box, a rolled map and a stack of card packs; four Path-coloured pennants (red, amber, green, violet) on the awning. No people, no text. The middle of the picture is calm and dark so cards read on top of it. '
     + STYLE, 'VS-BELLOWS.png (Approved_VendorScreens: how a vendor backdrop is framed), now_draft_pick.jpg'),
    ('UI-DRAFT-BG', 'The pick screen backdrop', '1920x1080 PNG', 'Behind the three offered cards on the pick screen',
     '(none - the plain glass page)', 'A close top-down view of dark green card-table baize with a faint gold border line, three slightly lighter card-shaped rectangles side by side in the middle (where the three offered cards sit), a brass lantern glow from the top left, and a few loose card sleeves at the edges. Very low contrast, no text, no cards with faces. ' + STYLE,
     'now_draft_pick.jpg (the screen it goes behind)'),
    ('UI-DRAFT-HALL', 'The Crosspath draft arena hall (optional: Phase 2)', '1920x1080 PNG', "The backdrop of the Crosspath draft arena's menu in Phase 2",
     '(none - the cave arena menu VS-BELLOWS can be reused, so this is optional)', 'A torch-lit underground hall under Crosspath, like the Grand Clashatorium but smaller and quieter: a ring of eleven card tables around a sunken floor, four Path banners (red, amber, green, violet) and one four-coloured banner, a prize shelf of sealed packs. No people, no text; calm dark middle. '
     + STYLE, 'VS-BELLOWS.png (the cave arena menu it would replace)'),
    ('ICON-MAP-DRAFT', 'Map and minimap marker: the draft table', '512x512 PNG, transparent background', "Trey Pickett's marker on each zone's map and minimap",
     '(none - the minigame marker stands in)', 'A simple icon readable at 32 pixels: three playing cards fanned upright, the middle one raised and glowing gold, on a round dark-blue badge with a thin gold rim. Flat colours, thick outline, no text. Same family as the other ICON-MAP icons.', 'ICON-MAP-ARENA.png (Approved_Icons: the family)'),
    ('ICON-UI-REROLL', 'The reroll icon', '256x256 PNG, transparent background', 'On the Reroll button of the pick screen',
     '(none - the button has words only)', 'A simple icon readable at 24 pixels: two curved gold arrows chasing each other in a circle around three small face-down cards. Flat colours, thick outline, no text. Same family as the other ICON-UI icons.', 'ICON-UI-DECK.png (Approved_Icons: the family)'),
]
GEAR = [
    ('LUCKYPACKWRAPPER', 'Lucky Pack Wrapper (relic)', 'A crumpled, opened foil card-pack wrapper, silver with a faded four-leaf clover printed on it, folded into a little good-luck charm on a string.'),
    ('CARDSLEEVEGAUNTLETS', 'Card-Sleeve Gauntlets (weapon)', 'A pair of leather gauntlets whose backs are armoured with overlapping clear card sleeves, each holding a different coloured card, a few sleeves glinting.'),
    ('FIRSTPICKFEDORA', 'First-Pick Fedora (helm)', 'A sharp charcoal fedora with a gold band; one playing card with a gold star on it is tucked into the band.'),
    ('CURVETOPPERBOOTS', 'Curve-Topper Boots (boots)', 'Tall red leather boots whose stacked heels are shaped like a rising bar chart, the tallest bar at the back, with brass toe caps.'),
    ('SIDEBOARDSATCHEL', 'Sideboard Satchel (relic)', 'A worn leather satchel with fifteen cards poking out of its front pocket in a neat row and a wrapped sandwich sticking out of the top.'),
    ('BOOSTERWRAPPERCAPE', 'Booster-Wrapper Cape (armor)', 'A short cape stitched from hundreds of shiny foil card-pack wrappers in red, amber, green and violet, crinkled and glittering, with a brass clasp.'),
    ('THEBOMBRARE', 'The Bomb Rare (weapon)', 'A round black cartoon bomb with a lit fuse, wrapped in a gold-bordered card frame like a trading card that became real; a small gold star in its corner.'),
    ('DRAFTCHAMPIONSLAURELS', "Draft Champion's Laurels (helm)", 'A laurel wreath whose leaves are the cut-off corners of gold-bordered playing cards, woven on a gold wire, with one whole tiny card as the centre jewel.'),
]
for slug, name, look in GEAR:
    ROWS.append(('ICON-GEAR-' + slug, 'Equipment icon: ' + name, '512x512 PNG, transparent background', 'Its icon in the armory, the shops, the Character page and the draft picks',
                 '(none - the slot\'s plain icon stands in)', 'One object, centred, three-quarter view, on a transparent background. ' + look + ' Thick outline, bright painterly colours, no text. Same family as the other ICON-GEAR icons.',
                 'ICON-GEAR-GLASSJAWGAUNTLETS.png (Approved_Icons: the family)'))
CARDS = [
    ('DR-01', 'First Pick', 'Pathless spell', 'A hand in a blue coat sleeve lifting one glowing card out of a fan of three on green baize, the other two cards dimming; warm lantern light.'),
    ('DR-02', 'Wheel the Table', 'Pathless spell', 'A round card table spinning like a carousel, cards flying off it in a spiral toward the viewer, four startled players leaning back in their chairs.'),
    ('DR-03', 'Signal Reader', 'Pathless unit', 'A sharp-eyed young woman in a travelling cloak peering over a fan of cards with a spyglass, tiny chalk arrows and question marks floating around her head.'),
    ('DR-04', 'Bomb in the Pack', 'Beefcake spell', 'A torn-open foil card pack on a gym bench with a round cartoon bomb with a lit fuse rolling out of it among ordinary cards; a muscular hand recoiling.'),
    ('DR-05', 'Late-Pick Hero', 'Refusemancer unit', 'A scruffy, cheerful raccoon knight in armour made of bent card tins and bottle caps, standing proudly on a heap of discarded cards under a moss-green sky.'),
    ('DR-06', 'Table Captain', 'Gourmand and Necrocrat unit', 'A stout ghostly maitre d\' in a chef\'s jacket and a clerk\'s visor, pointing guests to seats at a long card table with a ladle in one hand and a seating ledger in the other.'),
]
for cid, name, kind, look in CARDS:
    ROWS.append((cid, 'Card art: %s (%s; a new card designed for draft pools)' % (name, kind), '1024x1024 PNG', 'The picture of the new card "%s" (docs/design/draft_cards.md)' % name,
                 '(none - the card is designed, not yet in the game)', look + ' Square card illustration, no text, no frame. ' + STYLE, 'any Approved card art of the same Path (the style)'))
ROWS.append(('MAP-DRAFT', 'The draft dungeon map (Phase 3): the Shuffled Halls', '2048x1365 PNG (3:2)', 'The node map of the draft dungeon in Phase 3: 18 rooms in 6 columns, every link leading right',
             '(none)', 'A top-down fantasy map in the style of the other dungeon maps: a huge card table seen from above whose surface is a maze of small rooms. 18 rooms in 6 columns (2, 3, 4, 4, 3, 2 from left to right) exactly as on the plan, each a different little chamber (card shops, a kettle nook, an arena pit, a cursed vault), joined by felt-green walkways that always lead right, the last room a gold champion\'s dais. Leave a clear round landing spot in front of each room. No text.',
             'plan-draft-dungeon.jpg (the layout to follow exactly), MAP-PC.png (Approved_Maps: landing spots and painted walkways done right)'))


def draw_plan(path):
    from PIL import Image, ImageDraw
    w, h = 1536, 1024
    image = Image.new('RGB', (w, h), (34, 44, 38))
    draw = ImageDraw.Draw(image)
    columns = [2, 3, 4, 4, 3, 2]
    names = [['Gate: the first fight', 'Gate: the first fight'], ['Trade Counter (multi-Path offers)', 'Fight', 'Kettle (heal for a cost)'], ['Fight', 'Champion (hard, big prize)', 'Buff room', 'Fight'],
             ['Curse vault (a curse for a prize)', 'Fight', 'Trade Counter', 'Champion'], ['Kettle', 'Fight', 'Buff room'], ['The House (boss)', 'The House (boss)']]
    spots = []
    for c, count in enumerate(columns):
        x = 130 + c * 255
        column = []
        for r in range(count):
            y = h * (r + 1) / (count + 1)
            column.append((x, y))
        spots.append(column)
    for c in range(len(spots) - 1):
        for i, a in enumerate(spots[c]):
            for j, b in enumerate(spots[c + 1]):
                fa, fb = (i + 0.5) / len(spots[c]), (j + 0.5) / len(spots[c + 1])
                if abs(fa - fb) < 0.34:
                    draw.line([a, b], fill=(214, 190, 120), width=5)
    number = 1
    for c, column in enumerate(spots):
        for r, (x, y) in enumerate(column):
            draw.ellipse([x - 46, y - 46, x + 46, y + 46], fill=(60, 84, 120), outline=(240, 220, 150), width=4)
            draw.text((x - 8, y - 8), str(number), fill=(255, 255, 255))
            draw.text((x - 110, y + 52), names[c][r], fill=(235, 235, 220))
            number += 1
    draw.text((40, 24), 'The Shuffled Halls - draft dungeon plan (Phase 3): 18 rooms, 6 columns, every link leads right. A run walks 6 rooms.', fill=(255, 255, 255))
    image.save(path, quality=88)


def main():
    rows = list(csv.reader(io.open(SHEET, encoding='utf-8', newline='')))
    have = {row[0] for row in rows[1:]}
    added = 0
    for rid, asset, size, use, replaces, description, refs in ROWS:
        assert len(description) < 600, (rid, len(description))
        if rid in have:
            continue
        rows.append([rid, asset, '(to make)', size, use, replaces, STATUS, description, refs])
        added += 1
    out = io.StringIO()
    csv.writer(out, lineterminator='\n').writerows(rows)
    io.open(SHEET, 'w', encoding='utf-8', newline='').write(out.getvalue())
    plan = os.path.join(ROOT, 'docs', 'design', 'draft_dungeon_plan.jpg')
    draw_plan(plan)
    if os.path.isdir(REFS):
        shutil.copy(plan, REFS + 'plan-draft-dungeon.jpg')
        shots = os.path.join(ROOT, 'docs', 'overnight_shots', 'draft1')
        for source, name in [('beefcake_02_pick_1.jpg', 'now_draft_pick.jpg'), ('beefcake_00_host_in_zone.jpg', 'now_draft_host.jpg')]:
            if os.path.exists(os.path.join(shots, source)):
                shutil.copy(os.path.join(shots, source), REFS + name)
    print('%d rows added, %d in the sheet' % (added, len(rows) - 1))


if __name__ == '__main__':
    main()
