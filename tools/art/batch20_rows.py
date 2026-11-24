"""Batch 20 (Fable big pass Nov 23, Part 1): appends the sheet rows the importers need, and marks docs/art/batch20.csv "In Game"
with each row's Approved file. Idempotent.    python tools/art/batch20_rows.py"""
import csv
import io
import os

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..')
B20 = 'See docs/art/batch20.csv (Batch 20, Nov 23).'


def zrow(id_, asset, category, lock, size, use):
    return '%s,"%s",%s,%s,"%s","%s","%s",2,Approved' % (id_, asset, category, lock, B20, size, use)


ZONE_ROWS = {
    'town': [
        zrow('TOWN-HERO-SHUFFLEHOUSE', 'The Shuffle House (painted)', 'Prop', 'CUTOUT', '1536x2048 PNG, transparent', 'The draft arena building in Crosspath'),
        zrow('TOWN-SIGN-SHUFFLEHOUSE', 'The Shuffle House sign', 'Prop', 'CUTOUT', '1024x1024 PNG, transparent', 'The hanging sign over the Shuffle House door'),
    ],
    'capital': [
        zrow('CAP-PROP-PRIMM-CELL', "Primm's cell", 'Prop', 'CUTOUT', '1536x1024 PNG, transparent', 'The barred cell Primm stands behind in the underground base after his defeat'),
    ],
}
UI_ROWS = [
    ('UI-DRAFT-BG', 'Draft pick table (baize)', 'Screen pieces', 'Behind the three offered cards on the draft pick screen', '1920x1080 PNG'),
    ('UI-DRAFT-HALL', 'The Shuffle House hall', 'Screen pieces', "The backdrop of the Shuffle House's arena menu", '1920x1080 PNG'),
]
ICON_ROWS = [
    'ICON-MAP-DRAFT,Minimap: Draft table,Minimap,"Trey Pickett in each zone and the Shuffle House in Crosspath, on the map and minimap.",512x512 PNG,"%s",,Approved' % B20,
    'ICON-UI-REROLL,Draft: Reroll,Menu icons,"The Reroll button of the draft pick screen.",256x256 PNG,"%s",,Approved' % B20,
]
BOARD_ROW = ('BB-SHUFFLE,The House Table,The Shuffle House and the Shuffled Halls (every draft arena fight),Carnival-casino card table,'
    '"A green baize card table framed by red velvet curtains, gold trim and marquee bulbs. %s",,,,,Generated' % B20)
SPRITE_ROWS = [
    'NS-TREY,NPC-TREY,Trey Pickett,Shark,Stationary set,"SPR-TREY-FRONT_IDLE, SPR-TREY-SIDE_IDLE, SPR-TREY-BACK_IDLE, SPR-TREY-FRONT_TALK",1.0,Approved,"Batch 20 (Nov 23): the card shark at his draft cart in every Path zone (DraftHost.SPRITE_KEY TREY); REF sheet kept as reference"',
    'NS-OCTAVIA,NPC-OCTAVIA,Octavia Eightfold,Octopus,Stationary set,"SPR-OCTAVIA-FRONT_IDLE, SPR-OCTAVIA-SIDE_IDLE, SPR-OCTAVIA-BACK_IDLE, SPR-OCTAVIA-FRONT_TALK",1.1,Approved,"Batch 20 (Nov 23): the showwoman of the Shuffle House in Crosspath; REF sheet kept as reference"',
]
DEST = {'MAP-PC': 'Approved_Maps', 'NPC-TREY': 'Approved_Characters', 'SPR-TREY-REF': 'Approved_Sprites', 'SPR-TREY-FRONT_IDLE': 'Approved_Sprites',
    'SPR-TREY-SIDE_IDLE': 'Approved_Sprites', 'SPR-TREY-BACK_IDLE': 'Approved_Sprites', 'SPR-TREY-FRONT_TALK': 'Approved_Sprites', 'VS-TREY': 'Approved_VendorScreens',
    'UI-DRAFT-BG': 'Approved_UI', 'UI-DRAFT-HALL': 'Approved_UI', 'ICON-MAP-DRAFT': 'Approved_Icons', 'ICON-UI-REROLL': 'Approved_Icons', 'MAP-DRAFT': 'Approved_Maps'}
CARDS = {'DR-01': 'C-37', 'DR-02': 'C-38', 'DR-03': 'C-39', 'DR-04': 'B-38', 'DR-05': 'R-37', 'DR-06': 'GN-17'}
GEAR = [
    ('PRACTICEFOIL', 'Practice Foil (weapon)'), ('ROLLEDRULEBOOK', 'Rolled-Up Rulebook (weapon)'), ('TINKERSWRENCH', "Tinker's Wrench (weapon)"),
    ('THINKINGCAP', 'Thinking Cap (helm)'), ('DEALERSVISOR', "Dealer's Visor (helm)"), ('PATHWORKWAISTCOAT', 'Pathwork Waistcoat (armor)'),
    ('CARDBOARDCUIRASS', 'Cardboard Cuirass (armor; redo of the existing icon)'), ('SHUFFLESLIPPERS', 'Shuffle Slippers (boots)'), ('STEADYSANDALS', 'Steady Sandals (boots)'),
    ('LUCKYDICE', 'Lucky Dice (relic)'), ('POCKETHOURGLASS', 'Pocket Hourglass (relic)'), ('FAIRPLAYBADGE', 'Fair-Play Badge (relic)'),
]
GEAR_USE = 'Its icon in the armory, the shops, the Character page and the draft picks'
DESIGN = '(a design, not imported)'
# Rows the owner's sheet tab "Batch 20 Nov 23" added after Phase 1 wrote the CSV: id, asset, where it went, use
LATER = [
    ('NPC-OCTAVIA', 'Dialogue portrait of Octavia Eightfold', 'Approved_Characters/NPC-OCTAVIA.png', 'Her dialogue portrait in the Shuffle House'),
    ('SPR-OCTAVIA-REF', "Reference sheet for Octavia Eightfold's world sprite set", 'Approved_Sprites/SPR-OCTAVIA-REF.png', 'Keeps her world frames consistent (not shown in the game)'),
    ('SPR-OCTAVIA-FRONT_IDLE', 'World sprite of Octavia Eightfold - front idle', 'Approved_Sprites/SPR-OCTAVIA-FRONT_IDLE.png', 'She stands inside the Shuffle House door in Crosspath'),
    ('SPR-OCTAVIA-SIDE_IDLE', 'World sprite of Octavia Eightfold - side idle', 'Approved_Sprites/SPR-OCTAVIA-SIDE_IDLE.png', 'The same, from the side'),
    ('SPR-OCTAVIA-BACK_IDLE', 'World sprite of Octavia Eightfold - back idle', 'Approved_Sprites/SPR-OCTAVIA-BACK_IDLE.png', 'The same, from behind'),
    ('SPR-OCTAVIA-FRONT_TALK', 'World sprite of Octavia Eightfold - front, talking', 'Approved_Sprites/SPR-OCTAVIA-FRONT_TALK.png', 'Shown while she speaks'),
    ('BST-TREY', 'Bestiary and battle portrait of Trey Pickett', 'Approved_Bestiary/BST-TREY.png', 'His battle plate and Collection Book picture (a fight in the Shuffled Halls)'),
    ('BST-OCTAVIA', 'Bestiary and battle portrait of Octavia Eightfold', 'Approved_Bestiary/BST-OCTAVIA.png', "Her battle plate and Collection Book picture (the Shuffled Halls' boss)"),
    ('DR-07', 'Card art: Octavia Eightfold (four-Path legendary)', 'Approved/P4-04.png', 'The picture of the card Octavia Eightfold (P4-04)'),
    ('DR-08', 'Card art: Trey Pickett (Pathless epic)', 'Approved/C-40.png', 'The picture of the card Trey Pickett (C-40)'),
    ('TOWN-HERO-SHUFFLEHOUSE', 'The Shuffle House (Crosspath building)', 'Approved_EnvKit/TOWN-HERO-SHUFFLEHOUSE.png', 'The draft arena building in Crosspath'),
    ('TOWN-SIGN-SHUFFLEHOUSE', 'The Shuffle House sign', 'Approved_EnvKit/TOWN-SIGN-SHUFFLEHOUSE.png', 'The hanging sign over its door'),
    ('BB-SHUFFLE', 'Battle board: the House Table', 'Approved_Battleboards/BB-SHUFFLE.png', 'Every Shuffle House and Shuffled Halls fight'),
    ('CAP-PROP-PRIMM-CELL', "Primm's cell", 'Approved_ZoneKits/Capital/CAP-PROP-PRIMM-CELL.png', 'Primm behind bars in the underground base after his defeat'),
    ('UI-ALEMBIC-BREW', 'Auntie Alembic brewing, four arms (redo)', 'Approved_UI/UI-ALEMBIC-BREW.png', "The centre of Auntie Alembic's shop (replaces Batch 19's two-armed picture)"),
] + [('ICON-GEAR-%s' % slug, 'Equipment icon: %s' % name, 'Approved_Icons/ICON-GEAR-%s.png' % slug, GEAR_USE) for slug, name in GEAR] + [
    ('UI-ALEMBIC-MOCK-A', "Mock-up A of Auntie Alembic's screen", DESIGN, 'The lighter card panel of the rebuilt screen is taken from it'),
    ('UI-ALEMBIC-MOCK-B', "Mock-up B of Auntie Alembic's screen", DESIGN, 'The rebuilt screen follows it'),
    ('UI-DRAFT-MOCK-ARENA', "Mock-up of the Shuffle House's arena menu", DESIGN, 'The arena menu follows it'),
    ('UI-DRAFT-MOCK-VERSUS', 'Mock-up of the next-opponent reveal', DESIGN, 'The next-opponent reveal follows it'),
    ('UI-DRAFT-MOCK-PICK', 'Mock-up of the draft pick screen', DESIGN, 'The pick screen follows it'),
]


def append(path, rows):
    text = io.open(path, encoding='utf-8', newline='').read()
    have = {line.split(',', 1)[0] for line in text.splitlines()}
    new = [r for r in rows if r.split(',', 1)[0] not in have]
    if new:
        if not text.endswith('\n'):
            text += '\n'
        text += '\n'.join(new) + '\n'
        io.open(path, 'w', encoding='utf-8', newline='').write(text)
    print('%s: +%d' % (os.path.relpath(path, ROOT), len(new)))


def main():
    source = os.path.join(ROOT, 'data', 'source')
    for zone, rows in ZONE_ROWS.items():
        append(os.path.join(source, '%s_kit.csv' % zone), rows)
    append(os.path.join(source, 'ui_art_kit.csv.csv'), ['%s,%s,%s,"%s","%s","%s",,Approved' % (i, a, c, u, s, B20) for i, a, c, u, s in UI_ROWS])
    append(os.path.join(source, 'icons.csv'), ICON_ROWS)
    append(os.path.join(source, 'battleboard_list.csv.csv'), [BOARD_ROW])
    append(os.path.join(source, 'npc_sprite_batch.csv'), SPRITE_ROWS)
    path = os.path.join(ROOT, 'docs', 'art', 'batch20.csv')
    rows = list(csv.reader(io.open(path, encoding='utf-8', newline='')))
    have = {row[0] for row in rows}
    for row in rows[1:]:
        folder = DEST.get(row[0], 'Approved_Icons' if row[0].startswith('ICON-GEAR-') else '')
        if row[0] in CARDS:
            row[2] = 'Approved/%s.png' % CARDS[row[0]]
        elif folder:
            row[2] = '%s/%s.png' % (folder, row[0])
        else:
            continue
        row[6] = 'In Game (Batch 20, imported Nov 23)'
    for id_, asset, where, use in LATER:
        if id_ not in have:
            status = 'Design reference (Batch 20)' if where == DESIGN else 'In Game (Batch 20, imported Nov 23)'
            rows.append([id_, asset, where, '', use, '', status, 'From the sheet tab "Batch 20 Nov 23".', ''])
    out = io.StringIO()
    csv.writer(out, lineterminator='\n').writerows(rows)
    io.open(path, 'w', encoding='utf-8', newline='').write(out.getvalue())
    print('batch20.csv: %d rows' % (len(rows) - 1))


if __name__ == '__main__':
    main()
