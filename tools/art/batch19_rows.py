"""Batch 19 (Fable Nov 22 night, Part 1): marks the eight imported rows of docs/art/batch19.csv "In Game" with their Approved file, and
writes docs/art/batch20.csv (one redo row: the castle map's eleven missing walkways). Idempotent.
    python tools/art/batch19_rows.py"""
import csv
import io
import os

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..')
DEST = {
    'MAP-WORLD-BUFF': 'Approved_Maps/MAP-WORLD-BUFF.png',
    'UI-PACK-LOCKED-N': 'Approved_UI/UI-PACK-LOCKED-N.png',
    'MAP-PC': 'Approved_Maps/MAP-PC.png',
    'BST-THE-PANTRY-MIMIC': 'Approved_Bestiary/BST-THE-PANTRY-MIMIC.png',
    'UI-ALEMBIC-BREW': 'Approved_UI/UI-ALEMBIC-BREW.png',
    'UI-ALEMBIC-JAR': 'Approved_UI/UI-ALEMBIC-JAR.png',
    'T-PC-TRAINEE': 'Approved/T-PC-TRAINEE.png',
    'T-PC-STATUE': 'Approved/T-PC-STATUE.png',
}
MISSING = [
    "the Gilded Pantry (top of column 1) DOWN to the Portrait Gallery (column 2, second from the top)",
    "the Courtyard of Perfect Hedges (bottom of column 1) DOWN to the Garden of Uniform Flowers (bottom of column 2)",
    "the kitchen-like Lab Notes room (top of column 2) DOWN to the Hall of Mirrors (middle of column 3)",
    "the Portrait Gallery UP to the red Barracks (top of column 3)",
    "the Grand Foyer (column 2, third from the top) UP to the Hall of Mirrors",
    "the Garden of Uniform Flowers UP to the Hall of Mirrors (a long stair)",
    "the Hall of Mirrors UP to the violet Archives (top of column 4)",
    "the Correction Ward Cells (bottom of column 3) UP to the Ministry office (middle of column 4)",
    "the Ministry office UP to the greenhouse Seed Vault (top of column 5)",
    "the Safe Room bedroom (column 5, third from the top) UP to the Royal Stair (column 6, second)",
    "the Royal Kitchens (bottom of column 5) UP to the Clocktower (column 6, third)",
]


def main():
    path = os.path.join(ROOT, 'docs', 'art', 'batch19.csv')
    rows = list(csv.reader(io.open(path, encoding='utf-8', newline='')))
    for row in rows[1:]:
        if row[0] in DEST:
            row[2] = DEST[row[0]]
            row[6] = 'In Game (Batch 19, imported Nov 22)'
    out = io.StringIO()
    csv.writer(out, lineterminator='\n').writerows(rows)
    io.open(path, 'w', encoding='utf-8', newline='').write(out.getvalue())
    walkways = "; ".join("%d) %s" % (index + 1, text) for index, text in enumerate(MISSING))
    redo = [
        'MAP-PC', "Primm's Castle dungeon map (redo: eleven missing walkways)", '(to make)', '1536x1024 PNG (3:2, as now)',
        "The node map of Primm's Castle (the final dungeon)",
        "MAP-PC of Batch 19: every room and landing spot is right and 30 of the 41 links have a painted walkway. Eleven links have none, "
        "so the game still draws a plain line for each of them.",
        'To make (Batch 20) - Fable Nov 22 night',
        "Repaint of the Batch 19 MAP-PC, everything unchanged (the rooms, the landing spots, the 30 walkways, the sky), plus ELEVEN more "
        "walkways, each a white-and-gold arched bridge or stair like the others, from the first room's landing spot to the second's, "
        "always leading right: " + walkways + ". The first two matter most: they are on the all-allies route. No lettering.",
        "now_MAP-PC.jpg (Batch 20 Refs: the Batch 19 map in the game, with the eleven drawn lines on it), plan-primm-castle.jpg (the layout)",
    ]
    out = io.StringIO()
    csv.writer(out, lineterminator='\n').writerows([rows[0], redo])
    io.open(os.path.join(ROOT, 'docs', 'art', 'batch20.csv'), 'w', encoding='utf-8', newline='').write(out.getvalue())
    print('batch19.csv: %d rows In Game; batch20.csv: 1 redo row' % len(DEST))


if __name__ == '__main__':
    main()
