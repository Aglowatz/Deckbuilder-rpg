"""Fable Nov 21 castle (Part 2.6): a clean top-down plan of the new Primm's Castle map, for the painter.
   python tools/castle_plan_nov21.py [out folder]
   Writes plan-primm-castle.jpg (rooms, paths, the gate, the Model Room; the rooms stand where the game puts its node icons) and
   now_MAP-PC.jpg (the current painting, under 1 MB) into the Batch 19 Refs folder on the Drive (or the folder given).
   The layout is the ROOMS table of tools/castle_nov21.py. The plan is drawn as tidy columns; the painter is free to bend it into a castle."""
import os, sys
from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from castle_nov21 import ROOMS  # noqa: E402

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
OUT = sys.argv[1] if len(sys.argv) > 1 else 'G:/My Drive/Card Game Art/Batch 19 Refs'
W, H = 2048, 1365  # the painted map's 3:2 frame
INK = (58, 46, 40)
PAPER = (244, 236, 216)
KIND_COLOURS = {
    'Start': (120, 120, 120), 'Battle': (196, 78, 68), 'Elite': (150, 40, 70), 'Boss': (40, 30, 60), 'Treasure': (214, 168, 48),
    'Event': (92, 130, 190), 'Full Heal': (88, 160, 96), 'Deck Challenge': (140, 104, 180),
}
KIND_WORDS = {
    'Start': 'the gate', 'Battle': 'fight', 'Elite': 'hard fight', 'Boss': 'Primm', 'Treasure': 'treasure', 'Event': 'choice room',
    'Full Heal': 'heal', 'Deck Challenge': 'deck test',
}
ALLY = {2: 'ally room: the Grand Chef', 8: 'ally room: Grandmaster Flex', 11: 'ally room: Agnes', 14: 'ally room: Compostella'}
SHORT = {4: 'Gourmand Wing', 8: 'Beefcake Wing', 11: 'Necrocrat Wing', 14: 'Refusemancer Wing', 3: 'Courtyard of Hedges', 7: 'Garden of Uniform Flowers',
         10: 'Correction Ward Cells', 12: 'Ministry of Correction', 15: 'Archive of Good Intentions', 16: 'Safe Room', 18: 'Private Gallery', 20: 'Clocktower'}


def font(size, bold=False):
    for name in (('arialbd.ttf' if bold else 'arial.ttf'), 'DejaVuSans.ttf'):
        try:
            return ImageFont.truetype(name, size)
        except OSError:
            continue
    return ImageFont.load_default()


MAP_TOP, MAP_BOTTOM = 190, 1110  # the band the rooms are drawn in; the legend has the strip below it


def centre(number):
    """A tidy layered layout for the painter: one column per row (the gate left, the Model Room right), the rooms of a row spread
    top to bottom in the order they have on the current painting."""
    rows = {}
    for n, _name, _kind, _note, row, (_x, y), _exits in ROOMS:
        rows.setdefault(row, []).append((y, n))
    for row, members in rows.items():
        members.sort()
        for index, (_y, n) in enumerate(members):
            if n == number:
                x = int(150 + row * (W - 300) / 7.0)
                span = MAP_BOTTOM - MAP_TOP
                y = int(MAP_TOP + span * (index + 0.5) / len(members))
                return (x, y)
    raise KeyError(number)


def main():
    image = Image.new('RGB', (W, H), PAPER)
    draw = ImageDraw.Draw(image)
    draw.rectangle([18, 18, W - 18, H - 18], outline=INK, width=6)
    draw.text((60, 44), "PRIMM'S CASTLE - plan of the new map (Nov 21)", font=font(46, True), fill=INK)
    draw.text((60, 104), "Left to right: the Castle Gate, six rows of rooms, the Model Room. Every path leads forward (to the right). One room per row is visited.", font=font(26), fill=INK)
    # the paths first
    for number, _name, _kind, _note, _row, _pos, exits in ROOMS:
        for target in exits:
            draw.line([centre(number), centre(target)], fill=(150, 128, 100), width=14)
            draw.line([centre(number), centre(target)], fill=(226, 210, 176), width=8)
    # the rooms
    for number, name, kind, _note, _row, _pos, _exits in ROOMS:
        x, y = centre(number)
        colour = KIND_COLOURS[kind]
        radius = 64 if kind in ('Boss', 'Start') else 52
        draw.ellipse([x - radius, y - radius, x + radius, y + radius], fill=colour, outline=INK, width=5)
        if number in ALLY:
            draw.ellipse([x - radius - 12, y - radius - 12, x + radius + 12, y + radius + 12], outline=(214, 168, 48), width=8)
        label = str(number)
        box = draw.textbbox((0, 0), label, font=font(44, True))
        draw.text((x - (box[2] - box[0]) / 2, y - (box[3] - box[1]) / 2 - 10), label, font=font(44, True), fill=(255, 255, 255))
        title = SHORT.get(number, name)
        words = KIND_WORDS[kind] if number not in ALLY else ALLY[number]
        for index, (text, size, bold) in enumerate(((title, 25, True), (words, 21, False))):
            face = font(size, bold)
            box = draw.textbbox((0, 0), text, font=face)
            tx = min(max(x - (box[2] - box[0]) / 2, 30), W - 30 - (box[2] - box[0]))
            ty = y + radius + 8 + index * 30
            draw.rectangle([tx - 6, ty - 2, tx + (box[2] - box[0]) + 6, ty + (box[3] - box[1]) + 8], fill=PAPER)
            draw.text((tx, ty), text, font=face, fill=INK)
    # the legend
    lx, ly = 60, H - 150
    draw.line([40, H - 215, W - 40, H - 215], fill=INK, width=3)
    draw.text((lx, ly - 50), 'Room kinds', font=font(28, True), fill=INK)
    for index, kind in enumerate(('Battle', 'Elite', 'Event', 'Treasure', 'Full Heal', 'Deck Challenge', 'Boss')):
        cx = lx + (index % 4) * 330
        cy = ly + (index // 4) * 60
        draw.ellipse([cx, cy, cx + 40, cy + 40], fill=KIND_COLOURS[kind], outline=INK, width=3)
        draw.text((cx + 54, cy + 4), KIND_WORDS[kind], font=font(26), fill=INK)
    draw.ellipse([lx + 990, ly + 60, lx + 1030, ly + 100], outline=(214, 168, 48), width=7)
    draw.text((lx + 1044, ly + 64), 'gold ring: an ally room (a zone leader waits here)', font=font(26), fill=INK)
    os.makedirs(OUT, exist_ok=True)
    plan = os.path.join(OUT, 'plan-primm-castle.jpg')
    image.save(plan, quality=88)
    # the current painting, under 1 MB
    current = Image.open(os.path.join(ROOT, 'assets', 'art', 'maps', 'MAP-PC.webp')).convert('RGB')
    current.thumbnail((2048, 2048))
    now = os.path.join(OUT, 'now_MAP-PC.jpg')
    quality = 88
    while True:
        current.save(now, quality=quality)
        if os.path.getsize(now) < 1000000 or quality <= 50:
            break
        quality -= 6
    for path in (plan, now):
        print('%s  %d KB' % (path, os.path.getsize(path) // 1024))


if __name__ == '__main__':
    main()
