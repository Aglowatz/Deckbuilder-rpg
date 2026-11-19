"""Fable Nov 19 (Part 4): mock-ups of the proposed info-screen look (docs/art/ui_style_guide.md), composed from the art already in
the game plus clearly marked placeholders for the new art asked for in Batch 18 (magenta dashed boxes labelled with the asset id).
   python tools/ui_mockups_nov19.py        -> docs/overnight_shots/nov19b/ui_mockups/*.jpg
Nothing here is game code: it only draws pictures."""
import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
UI = os.path.join(ROOT, 'assets', 'art', 'ui')
ICONS = os.path.join(ROOT, 'assets', 'art', 'icons')
OUT = os.path.join(ROOT, 'docs', 'overnight_shots', 'nov19b', 'ui_mockups')
SHOTS = os.path.join(ROOT, 'docs', 'overnight_shots', 'nov19b')
W, H = 1600, 900
INK = (58, 40, 28)
INK_SOFT = (104, 82, 60)
GOLD = (222, 178, 92)
CREAM = (244, 232, 204)
NEW = (255, 60, 200)


def font(kind, size):
    paths = {
        'title': os.path.join(ROOT, 'assets', 'fonts', 'Cinzel', 'Cinzel-Variable.ttf'),
        'body': os.path.join(ROOT, 'assets', 'fonts', 'AlegreyaSans', 'AlegreyaSans-Regular.ttf'),
        'bold': os.path.join(ROOT, 'assets', 'fonts', 'AlegreyaSans', 'AlegreyaSans-Bold.ttf'),
        'italic': os.path.join(ROOT, 'assets', 'fonts', 'AlegreyaSans', 'AlegreyaSans-Italic.ttf'),
    }
    f = ImageFont.truetype(paths[kind], size)
    if kind == 'title':
        try:
            f.set_variation_by_axes([700])
        except Exception:
            pass
    return f


def art(name, folder=UI):
    return Image.open(os.path.join(folder, name + '.webp')).convert('RGBA')


def nine(img, margins, size, cap=0.5):
    """9-slice: margins (left, top, right, bottom) in source pixels, drawn at `scale` so the corners keep a sensible size."""
    l, t, r, b = margins
    w, h = size
    sw, sh = img.size
    scale = min(1.0, w / (l + r + 8), h / (t + b + 8), cap)
    dl, dt, dr, db = [max(1, int(m * scale)) for m in (l, t, r, b)]
    out = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    xs = [(0, l, 0, dl), (l, sw - r, dl, w - dr), (sw - r, sw, w - dr, w)]
    ys = [(0, t, 0, dt), (t, sh - b, dt, h - db), (sh - b, sh, h - db, h)]
    for sx0, sx1, dx0, dx1 in xs:
        for sy0, sy1, dy0, dy1 in ys:
            if dx1 <= dx0 or dy1 <= dy0:
                continue
            out.paste(img.crop((sx0, sy0, sx1, sy1)).resize((dx1 - dx0, dy1 - dy0), Image.LANCZOS), (dx0, dy0))
    return out


def paste(base, img, xy):
    base.alpha_composite(img, (int(xy[0]), int(xy[1])))


def placeholder(base, box, label):
    """A clearly marked stand-in for art that does not exist yet."""
    d = ImageDraw.Draw(base)
    x0, y0, x1, y1 = [int(v) for v in box]
    step = 10
    for x in range(x0, x1, step * 2):
        d.line((x, y0, min(x + step, x1), y0), fill=NEW, width=2)
        d.line((x, y1, min(x + step, x1), y1), fill=NEW, width=2)
    for y in range(y0, y1, step * 2):
        d.line((x0, y, x0, min(y + step, y1)), fill=NEW, width=2)
        d.line((x1, y, x1, min(y + step, y1)), fill=NEW, width=2)
    f = font('bold', 13)
    tw = d.textlength(label, font=f)
    d.rectangle((x0 + 2, y0 + 2, x0 + tw + 10, y0 + 19), fill=(40, 0, 30, 230))
    d.text((x0 + 6, y0 + 3), label, fill=NEW, font=f)


def backdrop(name, blur=6, dim=0.55):
    path = os.path.join(SHOTS, name)
    if os.path.exists(path):
        im = Image.open(path).convert('RGB').resize((W, H), Image.LANCZOS)
    else:
        im = Image.new('RGB', (W, H), (52, 44, 60))
    if blur:
        im = im.filter(ImageFilter.GaussianBlur(blur))
    if dim < 1.0:
        im = Image.blend(im, Image.new('RGB', (W, H), (14, 10, 20)), 1.0 - dim)
    return im.convert('RGBA')


def ribbon(base, cx, y, width, text):
    """The header ribbon: the ribbon of UI-PANEL-POPUP as its stand-in (the new UI-INFO-RIBBON is the same idea, on its own)."""
    src = art('UI-PANEL-POPUP').crop((0, 40, 1024, 250))
    h = int(width * src.height / src.width)
    img = src.resize((width, h), Image.LANCZOS)
    paste(base, img, (cx - width // 2, y))
    d = ImageDraw.Draw(base)
    f = font('title', max(20, width // 22))
    tw = d.textlength(text, font=f)
    d.text((cx - tw / 2 + 1, y + h * 0.36 + 1), text, fill=(70, 12, 10), font=f)
    d.text((cx - tw / 2, y + h * 0.36), text, fill=(255, 236, 190), font=f)
    placeholder(base, (cx - width // 2 + 20, y + 6, cx + width // 2 - 20, y + h - 30), 'NEW ART: UI-INFO-RIBBON')
    return h


def divider(base, x0, x1, y):
    d = ImageDraw.Draw(base)
    cx = (x0 + x1) // 2
    d.line((x0, y, x1, y), fill=(170, 130, 70), width=2)
    d.polygon([(cx, y - 7), (cx + 9, y), (cx, y + 7), (cx - 9, y)], fill=GOLD, outline=(120, 84, 40))
    placeholder(base, (x0, y - 12, x1, y + 12), 'NEW ART: UI-INFO-DIVIDER')


def button(base, box, text, primary=True):
    x0, y0, x1, y1 = box
    src = art('UI-BTN-PRIMARY' if primary else 'UI-BTN-SECONDARY')
    img = nine(src, (150, 70, 150, 70), (x1 - x0, y1 - y0))
    paste(base, img, (x0, y0))
    d = ImageDraw.Draw(base)
    f = font('title', 22)
    tw = d.textlength(text, font=f)
    d.text(((x0 + x1) / 2 - tw / 2, (y0 + y1) / 2 - 15), text, fill=(64, 36, 12) if primary else (246, 226, 180), font=f)


def seal(d, x, y, kind):
    if kind == 'done':
        d.ellipse((x, y, x + 20, y + 20), fill=(168, 38, 30), outline=(96, 20, 16), width=2)
        d.line((x + 5, y + 10, x + 9, y + 14, x + 15, y + 6), fill=(255, 226, 150), width=3)
    elif kind == 'next':
        d.polygon([(x + 3, y + 3), (x + 19, y + 10), (x + 3, y + 17)], fill=(196, 140, 40), outline=(110, 74, 20))
    else:
        d.ellipse((x + 2, y + 2, x + 18, y + 18), outline=INK_SOFT, width=2)


def caption(base, text):
    d = ImageDraw.Draw(base)
    f = font('bold', 15)
    d.rectangle((0, H - 30, W, H), fill=(10, 8, 14, 235))
    d.text((14, H - 25), 'MOCK-UP (not in the game). ' + text + '   Magenta dashed boxes = new art asked for in Batch 18.', fill=(235, 225, 205), font=f)


def save(base, name):
    os.makedirs(OUT, exist_ok=True)
    path = os.path.join(OUT, name + '.jpg')
    base.convert('RGB').save(path, quality=90)
    print(path)


# ---- 1: the quest box -------------------------------------------------------------------------------------------------------------
def quest_box():
    base = backdrop('p1_after_signpost_default.jpg', blur=0, dim=1.0)
    d = ImageDraw.Draw(base)
    x, y, w, h = 18, 34, 440, 268
    shadow = Image.new('RGBA', (w + 40, h + 40), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle((20, 24, w + 20, h + 24), 16, fill=(0, 0, 0, 120))
    paste(base, shadow.filter(ImageFilter.GaussianBlur(10)), (x - 20, y - 20))
    paste(base, nine(art('UI-PANEL-MAIN'), (110, 110, 110, 110), (w, h), 0.26), (x, y))
    # header strip
    paste(base, nine(art('UI-PANEL-HUD'), (70, 60, 70, 60), (w - 28, 44)), (x + 14, y + 12))
    d = ImageDraw.Draw(base)
    d.rounded_rectangle((x + 26, y + 20, x + 92, y + 46), 6, fill=(214, 168, 70), outline=(110, 76, 24))
    d.text((x + 36, y + 23), 'MAIN', fill=(60, 34, 10), font=font('bold', 17))
    d.text((x + 104, y + 20), 'Key Ingredients', fill=(250, 234, 196), font=font('title', 20))
    rows = [('done', 'Win the pantry key from Chef Fennel Gravois'), ('done', 'Step through the pantry door'), ('next', 'Help the kitchen: finish a favour in the'), ('', 'Endless Buffet'), ('open', '???')]
    yy = y + 68
    for kind, text in rows:
        if kind:
            seal(d, x + 30, yy + 2, kind)
        f = font('bold', 19) if kind == 'next' or kind == '' and text == 'Endless Buffet' else font('body', 18)
        colour = INK if kind in ('next', '') else INK_SOFT
        d.text((x + 60, yy), text, fill=colour, font=f)
        yy += 27 if kind != 'next' else 24
    d.line((x + 30, yy + 6, x + w - 30, yy + 6), fill=(190, 160, 110), width=1)
    d.text((x + 30, yy + 12), 'Next: go to the Endless Buffet', fill=(120, 60, 20), font=font('italic', 17))
    d.text((x + w - 110, yy + 12), '<  1 of 10  >', fill=INK_SOFT, font=font('body', 16))
    placeholder(base, (x - 4, y - 24, x + w + 4, y + h + 4), 'NEW ART: UI-QUESTBOX (a pinned parchment note; UI-PANEL-MAIN stands in) + UI-QUEST-MARKS')
    # the notes
    notes = ['Parchment with dark ink: 7:1 contrast over any zone (today: pale text on a see-through dark box).',
             'One header strip: tag (MAIN / SIDE), quest name. The current step in bold; done steps keep their red seal.',
             'The "what next" line sits at the foot in copper italics; the pager is small and out of the way.',
             'Width 430 px (27 % of 1600), text 18 px, rows 27 px apart, 16 px padding on every side.']
    yy = 330
    for n in notes:
        d.rounded_rectangle((18, yy, 18 + 690, yy + 30), 6, fill=(12, 10, 16, 215))
        d.text((28, yy + 5), n, fill=(240, 232, 214), font=font('body', 16))
        yy += 36
    caption(base, 'The quest box, top left.')
    save(base, 'mock_quest_box')


# ---- 2: the main (pause) menu ------------------------------------------------------------------------------------------------------
def main_menu():
    base = backdrop('p1_after_signpost_default.jpg')
    w, h = 560, 700
    x, y = (W - w) // 2, 110
    paste(base, nine(art('UI-PANEL-MAIN'), (110, 110, 110, 110), (w, h)), (x, y))
    placeholder(base, (x, y, x + w, y + h), 'NEW ART: UI-INFO-PAGE (UI-PANEL-MAIN stands in)')
    ribbon(base, W // 2, y - 64, 620, 'PAUSED')
    d = ImageDraw.Draw(base)
    d.text((x + 70, y + 84), 'Crosspath   -   Level 12   -   2 h 14 min', fill=INK_SOFT, font=font('italic', 19))
    yy = y + 130
    button(base, (x + 80, yy, x + w - 80, yy + 70), 'Resume', True)
    yy += 86
    for label in ['Quest Log', 'Settings', 'Glossary', 'Feats']:
        button(base, (x + 80, yy, x + w - 80, yy + 62), label, False)
        yy += 72
    divider(base, x + 90, x + w - 90, yy + 12)
    yy += 34
    for label in ['Save and quit to title']:
        button(base, (x + 80, yy, x + w - 80, yy + 62), label, False)
    d = ImageDraw.Draw(base)
    d.text((x + 150, y + h - 66), 'Esc   Back          E   Choose', fill=INK_SOFT, font=font('body', 18))
    caption(base, 'The pause / main menu: one parchment page in a gilt frame, a ribbon title, the gold button for the usual choice, wood buttons for the rest.')
    save(base, 'mock_main_menu')


# ---- 3: the quest log -------------------------------------------------------------------------------------------------------------
def quest_log():
    base = backdrop('p1_after_signpost_default.jpg')
    book = art('UI-BG-QUESTLOG').resize((1320, 880), Image.LANCZOS)
    bx, by = (W - 1320) // 2, 6
    paste(base, book, (bx, by))
    d = ImageDraw.Draw(base)
    # tabs
    tx = bx + 120
    for index, label in enumerate(['Main', 'Side', 'Done']):
        active = index == 0
        d.rounded_rectangle((tx, by + 58, tx + 120, by + 100), 8, fill=(240, 226, 192) if active else (86, 56, 34), outline=(170, 124, 56), width=2)
        d.text((tx + 34, by + 67), label, fill=INK if active else (240, 220, 180), font=font('title', 19))
        tx += 128
    placeholder(base, (bx + 116, by + 54, bx + 116 + 384, by + 104), 'NEW ART: UI-INFO-TAB')
    lx, ly = bx + 110, by + 122
    d.text((lx, ly), 'Main story', fill=INK, font=font('title', 26))
    divider(base, lx, lx + 470, ly + 44)
    yy = ly + 64
    quests = [('Key Ingredients', 'Step 3 of 5', True), ('Raise the Bar', 'Step 1 of 4', False), ('Root Cause', 'Step 2 of 6', False), ('Take a Number', 'Step 1 of 3', False), ('Fragments', 'Free a zone', False)]
    for name, step, selected in quests:
        row = nine(art('UI-NAMEPLATE'), (120, 70, 120, 70), (470, 62))
        paste(base, row, (lx, yy))
        d = ImageDraw.Draw(base)
        if selected:
            d.rounded_rectangle((lx + 4, yy + 4, lx + 466, yy + 58), 12, outline=(214, 150, 40), width=3)
        d.text((lx + 44, yy + 10), name, fill=INK, font=font('bold', 20))
        d.text((lx + 44, yy + 33), step, fill=INK_SOFT, font=font('body', 16))
        d.rounded_rectangle((lx + 380, yy + 18, lx + 440, yy + 42), 6, fill=(214, 168, 70), outline=(110, 76, 24))
        d.text((lx + 388, yy + 20), 'MAIN', fill=(60, 34, 10), font=font('bold', 15))
        yy += 70
    placeholder(base, (lx - 4, ly + 60, lx + 474, ly + 64 + 70 * 5), 'NEW ART: UI-INFO-ROW (normal / hover / selected; UI-NAMEPLATE stands in)')
    rx, ry = bx + 710, by + 122
    d.text((rx, ry), 'Key Ingredients', fill=INK, font=font('title', 28))
    d.text((rx, ry + 40), 'The Endless Buffet', fill=(140, 70, 30), font=font('italic', 19))
    divider(base, rx, rx + 480, ry + 78)
    body = ['Chef Fennel Gravois holds the pantry key, and the', 'kitchen will not help a stranger for nothing.']
    yy = ry + 98
    for line in body:
        d.text((rx, yy), line, fill=INK, font=font('body', 19))
        yy += 26
    yy += 12
    for kind, text in [('done', 'Win the pantry key from Chef Fennel Gravois'), ('done', 'Step through the pantry door'), ('next', 'Help the kitchen: finish a favour'), ('open', '???'), ('open', '???')]:
        seal(d, rx, yy + 2, kind)
        d.text((rx + 32, yy), text, fill=INK if kind == 'next' else INK_SOFT, font=font('bold' if kind == 'next' else 'body', 19))
        yy += 30
    yy += 14
    d.text((rx, yy), 'Reward', fill=INK, font=font('title', 20))
    d.text((rx, yy + 30), '120 gold   -   a Gourmand Path Pack   -   250 XP', fill=INK_SOFT, font=font('body', 18))
    button(base, (rx + 40, by + 700, rx + 300, by + 760), 'Track', True)
    button(base, (rx + 316, by + 700, rx + 520, by + 756), 'Show on map', False)
    caption(base, 'The quest log: the book that is already painted, with tabs, one row plate, the same step marks as the quest box.')
    save(base, 'mock_quest_log')


# ---- 4: a tooltip -----------------------------------------------------------------------------------------------------------------
def tooltip():
    base = backdrop('p3_after_deck.jpg', blur=0, dim=0.9)
    x, y, w, h = 560, 250, 440, 214
    shadow = Image.new('RGBA', (w + 60, h + 60), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle((30, 36, w + 30, h + 36), 14, fill=(0, 0, 0, 170))
    paste(base, shadow.filter(ImageFilter.GaussianBlur(12)), (x - 30, y - 30))
    paste(base, nine(art('UI-PANEL-TOOLTIP'), (80, 80, 80, 80), (w, h)), (x, y))
    d = ImageDraw.Draw(base)
    d.text((x + 28, y + 22), 'Bulldoze', fill=(244, 206, 120), font=font('title', 22))
    d.text((x + w - 120, y + 26), 'Keyword', fill=(170, 158, 140), font=font('italic', 16))
    d.line((x + 28, y + 56, x + w - 28, y + 56), fill=(150, 112, 56), width=1)
    yy = y + 68
    for line in ['Damage beyond what kills a blocker goes on', 'to the player behind it.']:
        d.text((x + 28, yy), line, fill=(240, 232, 214), font=font('body', 19))
        yy += 25
    yy += 8
    d.text((x + 28, yy), 'Example: a 5 attack unit blocked by a 2 defense', fill=(190, 180, 160), font=font('italic', 16))
    d.text((x + 28, yy + 20), 'unit deals 3 to its owner.', fill=(190, 180, 160), font=font('italic', 16))
    placeholder(base, (x - 3, y - 3, x + w + 3, y + h + 3), 'NEW ART: UI-INFO-TOOLTIP (UI-PANEL-TOOLTIP stands in)')
    for index, n in enumerate(['Always dark with pale text: it must read over parchment, wood, art and the battle board alike.',
                               'Title in gold Cinzel 22, kind in grey italics at the right, body 19, example 16 italics.',
                               'At most 440 px wide; 28 px padding; a soft shadow lifts it off the screen under it.']):
        d.rounded_rectangle((560, 490 + index * 36, 560 + 700, 520 + index * 36), 6, fill=(12, 10, 16, 225))
        d.text((570, 495 + index * 36), n, fill=(240, 232, 214), font=font('body', 16))
    caption(base, 'A tooltip (here over the Deck Station).')
    save(base, 'mock_tooltip')


# ---- 5: a settings page -----------------------------------------------------------------------------------------------------------
def settings():
    base = backdrop('p1_after_signpost_default.jpg')
    w, h = 1120, 720
    x, y = (W - w) // 2, 110
    paste(base, nine(art('UI-PANEL-MAIN'), (110, 110, 110, 110), (w, h)), (x, y))
    placeholder(base, (x, y, x + w, y + h), 'NEW ART: UI-INFO-PAGE')
    ribbon(base, W // 2, y - 66, 700, 'SETTINGS')
    d = ImageDraw.Draw(base)
    tx = x + 70
    for index, label in enumerate(['Display', 'Text', 'Audio', 'Controls', 'Accessibility']):
        active = index == 0
        tw = 150 if len(label) < 10 else 196
        d.rounded_rectangle((tx, y + 74, tx + tw, y + 118), 8, fill=(250, 238, 208) if active else (86, 56, 34), outline=(170, 124, 56), width=2)
        f = font('title', 19)
        d.text((tx + tw / 2 - d.textlength(label, font=f) / 2, y + 84), label, fill=INK if active else (240, 220, 180), font=f)
        tx += tw + 8
    placeholder(base, (x + 66, y + 70, tx, y + 122), 'NEW ART: UI-INFO-TAB (active / inactive)')
    d.line((x + 60, y + 120, x + w - 60, y + 120), fill=(170, 124, 56), width=2)
    yy = y + 146
    d.text((x + 80, yy), 'Picture', fill=INK, font=font('title', 22))
    yy += 40
    rows = [('Graphics quality', 'choice', 'Medium'), ('Window', 'choice', 'Fullscreen'), ('Camera angle', 'choice', 'Low'), ('Camera distance', 'slider', 0.5), ('Reduce motion', 'toggle', False)]
    for label, kind, value in rows:
        d.rounded_rectangle((x + 70, yy, x + w - 110, yy + 54), 10, fill=(236, 220, 184), outline=(196, 170, 122), width=1)
        d.text((x + 92, yy + 14), label, fill=INK, font=font('body', 21))
        cx = x + w - 470
        if kind == 'choice':
            plate = nine(art('UI-NAMEPLATE'), (120, 70, 120, 70), (330, 46))
            paste(base, plate, (cx, yy + 4))
            d = ImageDraw.Draw(base)
            d.text((cx + 40, yy + 13), '<', fill=INK_SOFT, font=font('bold', 20))
            d.text((cx + 280, yy + 13), '>', fill=INK_SOFT, font=font('bold', 20))
            f = font('bold', 20)
            d.text((cx + 165 - d.textlength(str(value), font=f) / 2, yy + 13), str(value), fill=INK, font=f)
        elif kind == 'slider':
            d.rounded_rectangle((cx + 10, yy + 23, cx + 320, yy + 31), 4, fill=(96, 66, 40))
            d.rounded_rectangle((cx + 10, yy + 23, cx + 10 + int(310 * value), yy + 31), 4, fill=(214, 160, 56))
            d.ellipse((cx + int(310 * value), yy + 15, cx + 24 + int(310 * value), yy + 39), fill=(240, 196, 96), outline=(120, 84, 30), width=2)
        else:
            d.rounded_rectangle((cx + 250, yy + 13, cx + 320, yy + 41), 14, fill=(120, 96, 70), outline=(90, 64, 40), width=2)
            d.ellipse((cx + 254, yy + 16, cx + 276, yy + 38), fill=(232, 220, 196))
            d.text((cx + 180, yy + 15), 'Off', fill=INK_SOFT, font=font('body', 19))
        yy += 62
    divider(base, x + 80, x + w - 120, yy + 10)
    yy += 30
    d.text((x + 80, yy), 'Battles', fill=INK, font=font('title', 22))
    yy += 40
    d.rounded_rectangle((x + 70, yy, x + w - 110, yy + 54), 10, fill=(236, 220, 184), outline=(196, 170, 122), width=1)
    d.text((x + 92, yy + 14), 'Opponent spells and traps', fill=INK, font=font('body', 21))
    plate = nine(art('UI-NAMEPLATE'), (120, 70, 120, 70), (330, 46))
    paste(base, plate, (x + w - 470, yy + 4))
    d = ImageDraw.Draw(base)
    d.text((x + w - 470 + 86, yy + 13), 'Wait for click', fill=INK, font=font('bold', 20))
    placeholder(base, (x + 66, y + 182, x + w - 106, y + 182 + 62 * 5 - 6), 'NEW ART: UI-INFO-ROW')
    # scroll bar
    d.rounded_rectangle((x + w - 86, y + 150, x + w - 70, y + h - 150), 8, fill=(86, 56, 34))
    d.rounded_rectangle((x + w - 88, y + 160, x + w - 68, y + 300), 9, fill=(226, 180, 84), outline=(120, 84, 30), width=2)
    placeholder(base, (x + w - 94, y + 146, x + w - 62, y + h - 146), 'UI-INFO-SCROLLBAR')
    button(base, (x + w - 560, y + h - 106, x + w - 330, y + h - 44), 'Defaults', False)
    button(base, (x + w - 310, y + h - 110, x + w - 70, y + h - 40), 'Done', True)
    d = ImageDraw.Draw(base)
    d.text((x + 84, y + h - 86), 'Q / E   Change tab        Esc   Back', fill=INK_SOFT, font=font('body', 18))
    caption(base, 'A settings page: tabs across the top, one row plate per setting (label left, control right), sections under a gold rule.')
    save(base, 'mock_settings')


if __name__ == '__main__':
    quest_box()
    main_menu()
    quest_log()
    tooltip()
    settings()
