"""Batch 17 / 17A: append the sheet rows the importers need (Overnight Nov 18, Part 1). Idempotent: a row whose ID is already on the
sheet is left alone. Usage: python tools/art/batch17_rows.py"""
import os

ROOT = os.path.join(os.path.dirname(__file__), '..', '..')
B17 = 'See docs/art/batch17_nov17.csv (Batch 17, Nov 18).'
B17A = 'See docs/art/batch17a_dna.csv (Batch 17A, Nov 18).'


def zrow(id_, asset, category, lock, size, use, desc=B17):
    return '%s,"%s",%s,%s,"%s","%s","%s",2,Approved' % (id_, asset, category, lock, desc, size, use)


ZONE_ROWS = {
    'dna': [
        zrow('DNA-WALL-HALL-A', 'Hall wall bay (doors)', 'Surface', 'SURFACE', '1254x1254 PNG, tileable horizontally', 'The hall outer walls inside (wall)', B17A),
        zrow('DNA-WALL-HALL-B', 'Hall wall bay (shelves)', 'Surface', 'SURFACE', '1254x1254 PNG, tileable horizontally', 'The hall outer walls inside (wall)', B17A),
        zrow('DNA-WALL-HALL-NARROW', 'Hall wall bay (narrow)', 'Surface', 'SURFACE', '887x1774 PNG, tileable horizontally', 'Short hall wall runs and corners (wall)', B17A),
        zrow('DNA-WALL-EXTERIOR', 'Hall exterior wall', 'Surface', 'SURFACE', '1254x1254 PNG, tileable horizontally', 'The building outside faces (wall)', B17A),
        zrow('DNA-RAIL-PARTITION', 'Waist-high partition', 'Surface', 'SURFACE', '2172x416 PNG, transparent, tileable horizontally', 'Partitions on the old interior wall footprints (trim)', B17A),
        zrow('DNA-FLOOR-MARBLE', 'Checker marble floor', 'Surface', 'SURFACE', '618x618 PNG, tileable', 'The hall floor (ground)', B17A),
        zrow('DNA-FLOOR-RUNNER', 'Red carpet runner', 'Surface', 'SURFACE', '887x1774 PNG, tileable vertically', 'Carpet runners on the main routes (ground)', B17A),
        zrow('DNA-PROP-COLUMN', 'Hall column', 'Prop', 'CUTOUT', '887x1774 PNG, transparent', 'Freestanding columns on the hall floor', B17A),
        zrow('DNA-RAIL-POST', 'Partition post', 'Prop', 'CUTOUT', '887x1774 PNG, transparent', 'Partition ends and joins', B17A),
        zrow('DNA-PROP-CHANDELIER', 'Chandelier', 'Prop', 'CUTOUT', '1024x1536 PNG, transparent', 'Hanging over the hall floor', B17A),
        zrow('DNA-PROP-SCONCE', 'Ghost-flame sconce', 'Prop', 'CUTOUT', '1254x1254 PNG, transparent', 'On the wall pilasters', B17A),
        zrow('DNA-PROP-LOBBY-CLOCK', 'Lobby clock', 'Prop', 'CUTOUT', '887x1774 PNG, transparent', 'The hall landmark', B17A),
        zrow('DNA-BANNER-STAMP-01', 'Stamp banner', 'Prop', 'CUTOUT', '724x2172 PNG, transparent', 'Hanging from the gallery and on posts', B17A),
        zrow('DNA-BANNER-STAMP-02', 'Stamp banner (torn)', 'Prop', 'CUTOUT', '724x2172 PNG, transparent', 'Hanging from the gallery and on posts', B17A),
        zrow('DNA-PROP-OFFICE-BOOTH-01', 'Clerk booth', 'Prop', 'CUTOUT', '1254x1254 PNG, transparent', 'Booths along the hall sides', B17A),
        zrow('DNA-PROP-OFFICE-BOOTH-02', 'Glazed office booth', 'Prop', 'CUTOUT', '1254x1254 PNG, transparent', 'Booths along the hall sides', B17A),
        zrow('DNA-BD-HALL-INTERIOR', 'Hall interior backdrop', 'Sky / backdrop', 'BACKDROP', '1774x887 PNG, opaque', 'The north end of the hall', B17A),
        zrow('DNA-STATUE-MORTIMER-STANDING', 'Mortimer statue, standing', 'Prop', 'CUTOUT', '1024x1536 PNG, transparent', 'Zone hub statue (standing)'),
        zrow('DNA-STATUE-MORTIMER-TOPPLED', 'Mortimer statue, toppled', 'Prop', 'CUTOUT', '1536x1024 PNG, transparent', 'Zone hub statue after the zone is freed'),
    ],
    'gainlands': [
        zrow('GAIN-STATUE-CLENCH-STANDING', 'Clench statue, standing', 'Prop', 'CUTOUT', '1024x1536 PNG, transparent', 'Zone hub statue (standing)'),
        zrow('GAIN-STATUE-CLENCH-TOPPLED', 'Clench statue, toppled', 'Prop', 'CUTOUT', '1536x1024 PNG, transparent', 'Zone hub statue after the zone is freed'),
    ],
    'buffet': [
        zrow('BUFF-STATUE-GRANDCHEF-STANDING', 'Grand Chef statue, standing', 'Prop', 'CUTOUT', '1024x1536 PNG, transparent', 'Zone hub statue (standing)'),
        zrow('BUFF-STATUE-GRANDCHEF-TOPPLED', 'Grand Chef statue, toppled', 'Prop', 'CUTOUT', '1536x1024 PNG, transparent', 'Zone hub statue after the zone is freed'),
        zrow('BUFF-PROP-FRUIT-TART', 'Giant fruit tart', 'Prop', 'CUTOUT', '1024x1024 PNG, transparent', 'The east food forest'),
        zrow('BUFF-PROP-CAKESTAND-TALL', 'Tall cake stand', 'Prop', 'CUTOUT', '1024x1536 PNG, transparent', 'The east food forest'),
        zrow('BUFF-PROP-VEG-01', 'Cabbage 1', 'Prop', 'CUTOUT', '512x512 PNG, transparent', 'The hub vegetable patch'),
        zrow('BUFF-PROP-VEG-02', 'Cabbage 2', 'Prop', 'CUTOUT', '512x512 PNG, transparent', 'The hub vegetable patch'),
        zrow('BUFF-PROP-VEG-03', 'Cabbage 3', 'Prop', 'CUTOUT', '512x512 PNG, transparent', 'The hub vegetable patch'),
    ],
    'heap': [
        zrow('DUMP-STATUE-COMPOSTELLA-STANDING', 'Compostella statue, standing', 'Prop', 'CUTOUT', '1024x1536 PNG, transparent', 'Zone hub statue (standing)'),
        zrow('DUMP-STATUE-COMPOSTELLA-TOPPLED', 'Compostella statue, toppled', 'Prop', 'CUTOUT', '1536x1024 PNG, transparent', 'Zone hub statue after the zone is freed'),
        zrow('DUMP-SHEET-ENTRANCE-FLAGS-07', 'Entrance pennant (green)', 'Prop', 'CUTOUT', '640x640 PNG, transparent', 'Pennants at the Dump entrance'),
        zrow('DUMP-SHEET-ENTRANCE-FLAGS-08', 'Entrance pennant (cream)', 'Prop', 'CUTOUT', '640x640 PNG, transparent', 'Pennants at the Dump entrance'),
        zrow('DUMP-PROP-PIG', 'Pig', 'Prop', 'CUTOUT', '512x512 PNG, transparent', 'The farm animals'),
    ],
    'capital': [
        zrow('CAP-STATUE-PRIMM-STANDING', 'Primm statue, standing', 'Prop', 'CUTOUT', '1024x1536 PNG, transparent', 'Zone hub statue (standing)'),
        zrow('CAP-STATUE-PRIMM-TOPPLED', 'Primm statue, toppled', 'Prop', 'CUTOUT', '1536x1024 PNG, transparent', 'Zone hub statue after the zone is freed'),
    ],
    'town': [
        zrow('TOWN-PROP-CELLAR-FOURSEALS-CLOSED', 'Four Seals cellar door, closed', 'Prop', 'CUTOUT', '1536x1024 PNG, transparent', 'The vault cellar door'),
        zrow('TOWN-PROP-CELLAR-FOURSEALS-OPEN', 'Four Seals cellar door, open', 'Prop', 'CUTOUT', '1536x1024 PNG, transparent', 'The vault cellar door, opened'),
        zrow('TOWN-PROP-SEAL-LOCKED', 'Seal, locked', 'Prop', 'CUTOUT', '512x512 PNG, transparent', 'The four seals on the vault door'),
        zrow('TOWN-PROP-SEAL-BLANK', 'Seal, blank', 'Prop', 'CUTOUT', '512x512 PNG, transparent', 'The four seals on the vault door (turned)'),
    ],
}

UI_ROWS = [
    ('UI-PACK-GILDED-B', 'Gilded Pack (Beefcake)', 'Packs', 'The Gilded Beefcake pack', '1024x1536 PNG, transparent'),
    ('MG-BG-PASS', 'Order Up background', 'Minigames', 'Order Up (Buffet card game)', '1536x1024 PNG'),
    ('MG-BG-CONVEYOR', 'Sort It Out background', 'Minigames', 'Sort It Out (Dump card game)', '1536x1024 PNG'),
    ('MG-BG-FILING', 'File in Order background', 'Minigames', 'File in Order (D.N.A. card game)', '1536x1024 PNG'),
    ('MG-PROP-BENCH', 'Reps bench', 'Minigames', 'Reps card game', '1024x1024 PNG, transparent'),
    ('MG-PROP-BARBELL', 'Reps barbell', 'Minigames', 'Reps: plates slide onto its ends', '1536x256 PNG, transparent'),
    ('MG-PROP-PLATE-01', 'Plate (heaviest)', 'Minigames', 'Reps: one plate per correct guess', '256x512 PNG, transparent'),
    ('MG-PROP-PLATE-02', 'Plate 2', 'Minigames', 'Reps: one plate per correct guess', '256x512 PNG, transparent'),
    ('MG-PROP-PLATE-03', 'Plate 3', 'Minigames', 'Reps: one plate per correct guess', '256x512 PNG, transparent'),
    ('MG-PROP-PLATE-04', 'Plate (lightest)', 'Minigames', 'Reps: one plate per correct guess', '256x512 PNG, transparent'),
    ('MG-PROP-TICKET', 'Order ticket', 'Minigames', 'Order Up: the target', '512x384 PNG, transparent'),
    ('MG-PROP-BELL', 'Service bell', 'Minigames', 'Order Up', '512x512 PNG, transparent'),
    ('MG-PROP-BIN-01', 'Sorting bin (red)', 'Minigames', 'Sort It Out', '768x512 PNG, transparent'),
    ('MG-PROP-BIN-02', 'Sorting bin (blue)', 'Minigames', 'Sort It Out', '768x512 PNG, transparent'),
    ('MG-PROP-BIN-03', 'Sorting bin (yellow)', 'Minigames', 'Sort It Out', '768x512 PNG, transparent'),
    ('MG-PROP-BIN-04', 'Sorting bin (purple)', 'Minigames', 'Sort It Out', '768x512 PNG, transparent'),
    ('MG-PROP-CABINET', 'Filing cabinet row', 'Minigames', 'File in Order', '2048x512 PNG, transparent'),
    ('MG-PROP-STAMP-APPROVED', 'APPROVED stamp', 'Minigames', 'File in Order win', '1536x512 PNG, transparent'),
    ('MG-PROP-STAMP-REJECTED', 'REJECTED stamp', 'Minigames', 'File in Order loss', '1536x512 PNG, transparent'),
]


def append(path, rows):
    text = open(path, encoding='utf-8').read()
    have = {line.split(',', 1)[0] for line in text.splitlines()}
    new = [r for r in rows if r.split(',', 1)[0] not in have]
    if new:
        if not text.endswith('\n'):
            text += '\n'
        text += '\n'.join(new) + '\n'
        open(path, 'w', encoding='utf-8', newline='\n').write(text)
    print('%s: +%d' % (os.path.relpath(path, ROOT), len(new)))


def main():
    for zone, rows in ZONE_ROWS.items():
        append(os.path.join(ROOT, 'data', 'source', '%s_kit.csv' % zone), rows)
    ui = ['%s,%s,%s,"%s","%s","%s",,Approved' % (i, a, c, u, s, B17) for i, a, c, u, s in UI_ROWS]
    append(os.path.join(ROOT, 'data', 'source', 'ui_art_kit.csv.csv'), ui)


if __name__ == '__main__':
    main()
