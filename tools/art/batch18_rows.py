"""Batch 18: append the sheet rows the importers need (Fable Nov 20 day, Part 1). Idempotent: a row whose ID is already on a sheet
is left alone. Usage: python tools/art/batch18_rows.py"""
import os

ROOT = os.path.join(os.path.dirname(__file__), '..', '..')
B18 = 'See docs/art/batch18_nov18.csv (Batch 18, Nov 20).'


def zrow(id_, asset, category, lock, size, use):
    return '%s,"%s",%s,%s,"%s","%s","%s",2,Approved' % (id_, asset, category, lock, B18, size, use)


ZONE_ROWS = {
    'dna': [
        zrow('DNA-HERO-CLOCK-TOWER', 'Clock tower (painted)', 'Prop', 'CUTOUT', '1024x2048 PNG, transparent', 'The clock tower by the Hall stair'),
        zrow('DNA-SIGN-HOURGLASS', 'Hourglass plaque', 'Prop', 'CUTOUT', '1024x1024 PNG, transparent', 'The sign over the Waiting Room elevator'),
        zrow('DNA-PROP-HEAL-COUCH', 'Breakroom couch', 'Prop', 'CUTOUT', '1536x1024 PNG, transparent', 'The healing couch'),
    ],
    'buffet': [
        zrow('BUFF-HERO-RAWDEAL-FRONT', 'The Raw Deal front', 'Prop', 'CUTOUT', '1536x1024 PNG, transparent', 'The front of the sushi spot (side dungeon entrance)'),
        zrow('BUFF-SIGN-RAWDEAL', 'The Raw Deal sign', 'Prop', 'CUTOUT', '1024x1024 PNG, transparent', 'The sign beside the freezer door'),
    ],
    'capital': [
        zrow('CAP-PROP-SERVICE-MANHOLE', 'Service tunnel manhole', 'Prop', 'CUTOUT', '1024x1024 PNG, transparent', 'The way into the Old Service Tunnels'),
    ],
    'town': [
        zrow('TOWN-PROP-CAVE-MOUTH-BRUSH', 'Cave mouth in the brush', 'Prop', 'CUTOUT', '1024x1024 PNG, transparent', 'The Forgotten Cave mouth on the north edge'),
    ],
}

UI_ROWS = [
    ('UI-INFO-PAGE', 'Info page (night glass, leaded gold frame)', 'Info screens', 'The background of every info screen', '1536x1024 PNG, transparent; 9-slice'),
    ('UI-GLASS-STRIP', 'Strip of eight Path panes', 'Info screens', 'Across the top of every info page and the quest box', '1536x96 PNG, transparent'),
    ('UI-GLASS-PANE', 'Glass pane, idle (tinted in code)', 'Info screens', 'Rows, tabs, tags, chips and toggles when idle', '512x160 PNG, transparent; 9-slice'),
    ('UI-GLASS-PANE-LIT', 'Glass pane, lit (tinted in code)', 'Info screens', 'The chosen or focused row, tab, tag or toggle', '512x160 PNG, transparent; 9-slice'),
    ('UI-ROSE-WINDOW', 'Rose window of the four Paths', 'Info screens', 'The top of the pause menu', '1024x1024 PNG, transparent'),
    ('UI-INFO-DIVIDER', 'Gold divider', 'Info screens', 'Beside every screen title and between sections', '1024x48 PNG, transparent; 3-slice'),
    ('UI-BTN-AMBER', 'Amber glass button', 'Info screens', 'The one main action of each screen', '1024x235 PNG, transparent; 9-slice'),
    ('UI-BTN-GLASS', 'Glass button (tinted in code)', 'Info screens', 'Every other button of the info screens', '1024x235 PNG, transparent; 9-slice'),
    ('UI-QUESTBOX', 'Quest box', 'Info screens', 'The tracked-quest box, top left', '768x512 PNG, transparent; 9-slice'),
    ('UI-INFO-TOOLTIP', 'Tooltip and small pop-up panel', 'Info screens', 'Hover tooltips and small pop-ups', '640x320 PNG, transparent; 9-slice'),
    ('UI-MAP-FRAME', 'Map frame', 'Info screens', 'The frame round the full map screen (M)', '2048x1152 PNG, transparent centre; 9-slice'),
    ('UI-QUEST-MARKS', 'Quest step marks (three cells)', 'Info screens', 'Quest step bullets: open, done, next', '384x128 PNG, transparent'),
    ('UI-SCROLL-RAIL', 'Scroll bar rail', 'Info screens', 'Every scrolling list', '48x512 PNG, transparent; 3-slice'),
    ('UI-SCROLL-GRIP', 'Scroll bar grip', 'Info screens', 'Every scrolling list', '48x160 PNG, transparent; 3-slice'),
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
    ui = ['%s,%s,%s,"%s","%s","%s",,Approved' % (i, a, c, u, s, B18) for i, a, c, u, s in UI_ROWS]
    append(os.path.join(ROOT, 'data', 'source', 'ui_art_kit.csv.csv'), ui)


if __name__ == '__main__':
    main()
