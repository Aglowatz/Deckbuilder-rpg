"""Fable Nov 21 castle: adds this pass's rows to docs/art/batch19.csv and puts their reference pictures (each under 1 MB) into the
   Drive folder 'Batch 19 Refs'.   python tools/batch19_nov21c_rows.py [refs folder]
   Every row is self-contained and its description is under 600 characters."""
import csv, io, os, sys
from PIL import Image

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
REFS = sys.argv[1] if len(sys.argv) > 1 else 'G:/My Drive/Card Game Art/Batch 19 Refs'
STATUS = 'To make (Batch 19) - Fable Nov 21 castle'

ROWS = [
    ['MAP-PC', "Primm's Castle dungeon map (redo for the new layout)", '(to make)', '2048x1365 PNG (3:2, as now)',
     "The node map of Primm's Castle (the final dungeon)",
     "MAP-PC as it is: painted for the old one-path castle. The game now draws the new routes over it with plain lines.",
     STATUS,
     "Repaint of ref now_MAP-PC in the same style (a white-and-gold palace of open rooms on cloud-high terraces, deep blue sky, violet cracks of lightning below). New layout from ref plan-primm-castle: the gate on the left, six columns of rooms (2, 4, 3, 3, 4, 4), the Model Room on the right; a clear walkway for EVERY line of the plan, always leading right; each room an open diorama with an empty round landing spot in front. Keep the rooms' looks (pantry, hedge courtyard, hall of mirrors, archive, clocktower, vault). No lettering.",
     'plan-primm-castle.jpg (the new layout), now_MAP-PC.jpg (the style and the rooms to keep)'],
    ['BST-THE-PANTRY-MIMIC', 'The Pantry Mimic (Bestiary portrait, also its battle portrait)', '(to make)', '1024x1024 PNG',
     "The Gilded Pantry's optional fight in Primm's Castle; the Collection Book",
     "The Echo of the Doppelganger's picture stands in.",
     STATUS,
     "A gilded pantry cupboard that is alive: tall, white and gold, one door hanging open like a mouth, jars and a chewed cookbook on its shelves, two round preserve-jar lids for eyes, a ladle for a tongue, small clawed cabinet feet. It is trying to look like a chef: a toque sits crooked on top and an apron is tied round its middle. Mischievous, not scary. Painterly, bold shapes, warm kitchen light, the same style as the other Bestiary portraits (ref). Square, the creature centred, plain soft pantry background.",
     'now_BST-ECHO-OF-THE-DOPPELGANGER.jpg (the stand-in; the style and framing to match)'],
    ['UI-ALEMBIC-BREW', "Auntie Alembic's brewing scene (the centre of her shop)", '(to make)', '1024x768 PNG, transparent background',
     "Auntie Alembic's shop: the middle of 'The brew' panel, in place of the small cauldron",
     'UI-CAULDRON (a small copper cauldron alone)',
     STATUS,
     "Auntie Alembic (ref: grey-haired, green headscarf, paint-splashed apron, warm smile) stirring a big copper cauldron with a long wooden spoon, seen from the front, half figure behind the pot. Four streams of glowing liquid pour into it from glass pipes above: red, blue, green and violet (the four Paths), and coloured steam curls up. The scene feels alive: bubbles, sparks, a happy face. Same painterly style as her shop. Transparent background, nothing cropped at the edges, no lettering.",
     'now_UI-CAULDRON.png (the cauldron to keep), now_V-ALEMBIC.jpg (her look), now_alembic_shop.jpg (where it goes)'],
    ['UI-ALEMBIC-JAR', 'An empty glass essence jar', '(to make)', '512x640 PNG, transparent background',
     "Auntie Alembic's shop: the four essence jars (the game fills and tints the liquid behind the glass)",
     'A jar drawn by the game (ref now_alembic_shop)',
     STATUS,
     "One EMPTY apothecary jar, seen straight from the front: clear glass with a soft highlight down the left side and a darker rim, a short neck, a cork stopper, a thin brass band round the neck with a blank oval tag. The inside must be truly transparent (see-through glass, no liquid, no background), because the game draws the coloured liquid behind it and a number on it. Painterly, bold outline, the same style as the shop. The jar fills the frame with a small margin. No lettering.",
     'now_alembic_shop.jpg (the drawn jars it replaces, and their size)'],
    ['T-PC-TRAINEE', "Captured Trainee (token art, optional)", '(to make)', '768x1152 PNG (card art)',
     "The Beefcake wing of Primm's Castle: the two allied units of 'Hold the Line'",
     "The Flexing Brute's Bestiary picture, tinted, stands in.",
     'Optional (Batch 19) - Fable Nov 21 castle; the stand-in works',
     "A young Beefcake trainee in a plain grey regime tunic over a red gym vest, wrists still in loose rope, standing straight with clenched fists and a stubborn, frightened face, refusing to move. Behind: a white-and-gold castle barracks with coup orders pinned to the door. Card art, portrait format, the figure in the upper two thirds, painterly with bold shapes like the Beefcake cards (ref). No lettering.",
     'now_BST-FLEXING-BRUTE.jpg (the stand-in; the Beefcake look)'],
    ['T-PC-STATUE', "Spotless Statue (token art, optional)", '(to make)', '768x1152 PNG (card art)',
     "The Refusemancer wing of Primm's Castle: the three statues to destroy in 'Clean Out the Polish'",
     "Captain Spotless's Bestiary picture, tinted, stands in.",
     'Optional (Batch 19) - Fable Nov 21 castle; the stand-in works',
     "A gleaming white marble statue of a smug, perfectly groomed official holding a polishing cloth, on a gold plinth, so polished that it shines; a tiny green shoot is pushing through a crack at its foot. Behind: a spotless seed vault of glass drawers. Card art, portrait format, the statue in the upper two thirds, painterly with bold shapes like the game's cards (ref). No lettering.",
     'now_BST-CAPTAIN-SPOTLESS.jpg (the stand-in and the face to carve)'],
]


def save_ref(source, name, size=1400):
    if not os.path.exists(source):
        print('missing ref source: %s' % source)
        return
    image = Image.open(source)
    target = os.path.join(REFS, name)
    if name.endswith('.png'):
        image = image.convert('RGBA')
        image.thumbnail((size, size))
        image.save(target)
    else:
        image = image.convert('RGB')
        image.thumbnail((size, size))
        quality = 88
        while True:
            image.save(target, quality=quality)
            if os.path.getsize(target) < 1000000 or quality <= 50:
                break
            quality -= 6
    print('%s  %d KB' % (target, os.path.getsize(target) // 1024))


def main():
    path = os.path.join(ROOT, 'docs', 'art', 'batch19.csv')
    raw = io.open(path, encoding='utf-8', newline='').read()
    rows = list(csv.reader(io.StringIO(raw)))
    known = {row[0]: index for index, row in enumerate(rows)}
    for row in ROWS:
        assert len(row[7]) < 600, (row[0], len(row[7]))
        if row[0] in known:
            rows[known[row[0]]] = row
        else:
            rows.append(row)
    out = io.StringIO()
    csv.writer(out, lineterminator='\r\n' if '\r\n' in raw else '\n').writerows(rows)
    io.open(path, 'w', encoding='utf-8', newline='').write(out.getvalue())
    print('%d rows in docs/art/batch19.csv' % (len(rows) - 1))
    os.makedirs(REFS, exist_ok=True)
    art = os.path.join(ROOT, 'assets', 'art')
    shots = os.path.join(ROOT, 'docs', 'overnight_shots', 'nov21c')
    save_ref(os.path.join(art, 'bestiary', 'BST-ECHO-OF-THE-DOPPELGANGER.webp'), 'now_BST-ECHO-OF-THE-DOPPELGANGER.jpg')
    save_ref(os.path.join(art, 'bestiary', 'BST-FLEXING-BRUTE.webp'), 'now_BST-FLEXING-BRUTE.jpg')
    save_ref(os.path.join(art, 'bestiary', 'BST-CAPTAIN-SPOTLESS.webp'), 'now_BST-CAPTAIN-SPOTLESS.jpg')
    save_ref(os.path.join(art, 'ui', 'UI-CAULDRON.webp'), 'now_UI-CAULDRON.png', 768)
    save_ref(os.path.join(shots, 'p8_after_two_paths.jpg'), 'now_alembic_shop.jpg', 1600)
    for folder, name in (('vendors', 'VS-ALEMBIC.webp'), ('portraits', 'V-ALEMBIC.webp')):
        source = os.path.join(art, folder, name)
        if os.path.exists(source):
            save_ref(source, 'now_V-ALEMBIC.jpg')
            break
    else:
        print('no Alembic picture found for the ref')


if __name__ == '__main__':
    main()
