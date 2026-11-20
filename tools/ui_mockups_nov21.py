"""Fable Nov 21 (Part 10): two NEW directions for the info screens, with more colour from the four Paths (Necrocrat violet, Gourmand
blue, Beefcake red, Refusemancer moss green). Design only: nothing here is game code, it only draws pictures.
   python tools/ui_mockups_nov21.py        -> docs/overnight_shots/nov20/ui_mockups_v2/<a|b>_<screen>.jpg
Direction A "Patchwork": a cream linen page inside a quilt border of four cloths, stitched seams, cloth tabs and banners.
Direction B "Stained glass": a night-blue page in a leaded gold frame, panes of coloured glass that glow, pale lettering.
The notes on each are in docs/art/ui_style_guide.md."""
import os, random
from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageChops

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
ICONS = os.path.join(ROOT, 'assets', 'art', 'icons')
OUT = os.path.join(ROOT, 'docs', 'overnight_shots', 'nov20', 'ui_mockups_v2')
BACK = os.path.join(ROOT, 'docs', 'overnight_shots', 'nov20', 'p1_well_1_maren_reminder.jpg')
W, H = 1600, 900
RED, BLUE, GREEN, VIOLET = (224, 50, 31), (90, 170, 242), (88, 147, 59), (154, 95, 199)
PATHS = {'B': RED, 'G': BLUE, 'R': GREEN, 'N': VIOLET}
PATH_NAMES = {'B': 'Beefcake', 'G': 'Gourmand', 'R': 'Refusemancer', 'N': 'Necrocrat'}
GOLD = (226, 184, 96)
CREAM = (246, 236, 212)
INK = (52, 36, 28)
INK_SOFT = (104, 84, 66)
NIGHT = (24, 19, 40)


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


def mix(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def dark(c, t=0.45):
    return mix(c, (18, 12, 20), t)


def light(c, t=0.45):
    return mix(c, (255, 250, 236), t)


def icon(path_key, size):
    img = Image.open(os.path.join(ICONS, 'ICON-ENERGY-%s.webp' % path_key)).convert('RGBA')
    return img.resize((size, size), Image.LANCZOS)


def backdrop(blur=7, dim=0.5):
    img = Image.open(BACK).convert('RGB').resize((W, H), Image.LANCZOS)
    if blur:
        img = img.filter(ImageFilter.GaussianBlur(blur))
    veil = Image.new('RGB', (W, H), (14, 10, 22))
    return Image.blend(img, veil, dim).convert('RGBA')


def grain(size, base, amount=10, seed=1, weave=False):
    """A painted, slightly uneven surface: soft blotches plus (for cloth) a faint weave."""
    w, h = size
    rnd = random.Random(seed)
    small = Image.new('L', (max(2, w // 24), max(2, h // 24)))
    small.putdata([rnd.randint(0, 255) for _ in range(small.size[0] * small.size[1])])
    blot = small.resize((w, h), Image.BICUBIC).filter(ImageFilter.GaussianBlur(6))
    img = Image.new('RGB', (w, h), base)
    shade = Image.new('RGB', (w, h), mix(base, (0, 0, 0), 0.5))
    tint = Image.new('RGB', (w, h), mix(base, (255, 255, 255), 0.35))
    img = Image.composite(shade, img, blot.point(lambda v: int(max(0, 128 - v) * amount / 64)))
    img = Image.composite(tint, img, blot.point(lambda v: int(max(0, v - 128) * amount / 64)))
    if weave:
        d = ImageDraw.Draw(img, 'RGBA')
        for y in range(0, h, 3):
            d.line([(0, y), (w, y)], fill=(0, 0, 0, 14))
        for x in range(0, w, 3):
            d.line([(x, 0), (x, h)], fill=(255, 255, 255, 9))
    return img.convert('RGBA')


def rounded(size, radius, fill):
    mask = Image.new('L', size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, size[0] - 1, size[1] - 1], radius, fill=255)
    if isinstance(fill, Image.Image):
        out = fill.copy()
    else:
        out = Image.new('RGBA', size, fill)
    out.putalpha(mask)
    return out


def shadow(base, box, radius=18, blur=18, alpha=150, offset=(0, 10)):
    x0, y0, x1, y1 = box
    layer = Image.new('RGBA', base.size, (0, 0, 0, 0))
    ImageDraw.Draw(layer).rounded_rectangle([x0 + offset[0], y0 + offset[1], x1 + offset[0], y1 + offset[1]], radius, fill=(0, 0, 0, alpha))
    base.alpha_composite(layer.filter(ImageFilter.GaussianBlur(blur)))


def stitches(d, pts, color, width=3, dash=11, gap=8):
    """A dashed thread along a polyline."""
    for (x0, y0), (x1, y1) in zip(pts, pts[1:]):
        length = max(1.0, ((x1 - x0) ** 2 + (y1 - y0) ** 2) ** 0.5)
        ux, uy = (x1 - x0) / length, (y1 - y0) / length
        pos = 0.0
        while pos < length:
            end = min(length, pos + dash)
            d.line([(x0 + ux * pos, y0 + uy * pos), (x0 + ux * end, y0 + uy * end)], fill=color, width=width)
            pos += dash + gap


def text(d, xy, s, f, fill, anchor='la'):
    d.text(xy, s, font=f, fill=fill, anchor=anchor)


def wrap(d, s, f, width):
    words, lines, line = s.split(), [], ''
    for word in words:
        trial = (line + ' ' + word).strip()
        if d.textlength(trial, font=f) <= width:
            line = trial
        else:
            lines.append(line)
            line = word
    if line:
        lines.append(line)
    return lines


def paragraph(d, xy, s, f, fill, width, leading=1.28):
    x, y = xy
    for line in wrap(d, s, f, width):
        d.text((x, y), line, font=f, fill=fill)
        y += int(f.size * leading)
    return y


def caption(base, s):
    d = ImageDraw.Draw(base)
    d.rectangle([0, H - 30, W, H], fill=(10, 8, 16, 255))
    d.text((14, H - 25), s, font=font('bold', 16), fill=(238, 232, 222))


def save(base, name):
    os.makedirs(OUT, exist_ok=True)
    base.convert('RGB').save(os.path.join(OUT, name + '.jpg'), quality=90)
    print('  ' + name + '.jpg')


# ===================================================== Direction A: Patchwork ===================================================

def a_panel(base, box, accent=None, band=26):
    """A cream linen page in a quilt border: red on top, blue on the right, green below, violet on the left; stitched seams; a gold
    button on every corner. `accent` gives the whole border one Path's cloth instead (a quest of that zone, a single-Path pop-up)."""
    x0, y0, x1, y1 = box
    w, h = x1 - x0, y1 - y0
    shadow(base, box, 22, 20, 170)
    sides = [accent] * 4 if accent else [RED, BLUE, GREEN, VIOLET]
    quilt = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    top = grain((w, band), dark(sides[0], 0.18), 9, 11, True)
    right = grain((band, h), dark(sides[1], 0.18), 9, 12, True)
    bottom = grain((w, band), dark(sides[2], 0.18), 9, 13, True)
    left = grain((band, h), dark(sides[3], 0.18), 9, 14, True)
    quilt.alpha_composite(top, (0, 0))
    quilt.alpha_composite(bottom, (0, h - band))
    # mitred corners: the side cloths cover the ends of the top and bottom cloths along a diagonal
    for cloth, x in ((left, 0), (right, w - band)):
        mask = Image.new('L', (band, h), 255)
        md = ImageDraw.Draw(mask)
        if x == 0:
            md.polygon([(0, 0), (band, 0), (band, band)], fill=0)
            md.polygon([(0, h), (band, h), (band, h - band)], fill=0)
        else:
            md.polygon([(0, 0), (band, 0), (0, band)], fill=0)
            md.polygon([(0, h), (band, h), (0, h - band)], fill=0)
        quilt.paste(cloth, (x, 0), mask)
    page = grain((w - band * 2, h - band * 2), (244, 233, 207), 7, 21, True)
    quilt.alpha_composite(page, (band, band))
    quilt = rounded((w, h), 20, quilt)
    base.alpha_composite(quilt, (x0, y0))
    d = ImageDraw.Draw(base, 'RGBA')
    d.rounded_rectangle([x0, y0, x1 - 1, y1 - 1], 20, outline=(60, 40, 30, 255), width=3)
    inner = [x0 + band, y0 + band, x1 - band, y1 - band]
    d.rectangle(inner, outline=(60, 40, 30, 200), width=2)
    half = band // 2
    stitches(d, [(x0 + half, y0 + half), (x1 - half, y0 + half), (x1 - half, y1 - half), (x0 + half, y1 - half), (x0 + half, y0 + half)], (250, 240, 214, 235), 3)
    for cx, cy in ((x0 + half, y0 + half), (x1 - half, y0 + half), (x1 - half, y1 - half), (x0 + half, y1 - half)):
        d.ellipse([cx - 10, cy - 10, cx + 10, cy + 10], fill=GOLD + (255,), outline=(96, 66, 30, 255), width=2)
        d.ellipse([cx - 3, cy - 5, cx - 1, cy - 3], fill=(96, 66, 30, 255))
        d.ellipse([cx + 1, cy + 3, cx + 3, cy + 5], fill=(96, 66, 30, 255))
    return inner


def a_banner(base, cx, y, width, s, color, size=30):
    """A cloth banner with swallow tails and a stitched edge: every title."""
    d = ImageDraw.Draw(base, 'RGBA')
    h = size + 26
    x0, x1 = cx - width // 2, cx + width // 2
    cloth = grain((width, h), dark(color, 0.12), 10, 31, True)
    mask = Image.new('L', (width, h), 0)
    md = ImageDraw.Draw(mask)
    md.polygon([(0, 0), (width, 0), (width - 22, h // 2), (width, h), (0, h), (22, h // 2)], fill=255)
    cloth.putalpha(mask)
    shadow(base, (x0 + 10, y + 4, x1 - 10, y + h), 6, 8, 120, (0, 5))
    base.alpha_composite(cloth, (x0, y))
    stitches(d, [(x0 + 34, y + 7), (x1 - 34, y + 7)], light(color, 0.75) + (255,), 2, 9, 7)
    stitches(d, [(x0 + 34, y + h - 8), (x1 - 34, y + h - 8)], light(color, 0.75) + (255,), 2, 9, 7)
    text(d, (cx, y + h // 2 - 1), s, font('title', size), (255, 248, 230), 'mm')


def a_patch(base, box, color, key=None, label=None, selected=False):
    """A cloth patch sewn on: tabs, tags, the coloured end of a row."""
    x0, y0, x1, y1 = box
    cloth = rounded((x1 - x0, y1 - y0), 9, grain((x1 - x0, y1 - y0), dark(color, 0.1), 9, x0 + y0, True))
    base.alpha_composite(cloth, (x0, y0))
    d = ImageDraw.Draw(base, 'RGBA')
    d.rounded_rectangle([x0, y0, x1 - 1, y1 - 1], 9, outline=(50, 34, 26, 255), width=2)
    thread = GOLD + (255,) if selected else light(color, 0.75) + (255,)
    stitches(d, [(x0 + 6, y0 + 6), (x1 - 6, y0 + 6), (x1 - 6, y1 - 6), (x0 + 6, y1 - 6), (x0 + 6, y0 + 6)], thread, 3 if selected else 2, 8, 6)
    cx = (x0 + x1) // 2
    if key:
        size = min(y1 - y0 - 14, 44)
        base.alpha_composite(icon(key, size), (x0 + 10 if label else cx - size // 2, (y0 + y1) // 2 - size // 2))
    if label:
        text(d, (cx + (22 if key else 0), (y0 + y1) // 2 - 1), label, font('bold', 21), (255, 248, 232), 'mm')


def a_row(base, box, color, key, title, sub, selected=False, tag=None):
    x0, y0, x1, y1 = box
    d = ImageDraw.Draw(base, 'RGBA')
    linen = rounded((x1 - x0, y1 - y0), 10, grain((x1 - x0, y1 - y0), (252, 244, 224) if selected else (236, 224, 196), 6, y0, True))
    base.alpha_composite(linen, (x0, y0))
    d.rounded_rectangle([x0, y0, x1 - 1, y1 - 1], 10, outline=dark(color, 0.2) + (255,) if selected else (120, 96, 72, 255), width=4 if selected else 2)
    a_patch(base, (x0 + 6, y0 + 6, x0 + 62, y1 - 6), color, key)
    text(d, (x0 + 76, y0 + 12), title, font('bold', 24), INK)
    text(d, (x0 + 76, y0 + 42), sub, font('body', 19), INK_SOFT)
    if tag:
        tw = int(d.textlength(tag, font=font('bold', 16))) + 22
        a_patch(base, (x1 - tw - 12, y0 + 12, x1 - 12, y0 + 42), color)
        text(d, (x1 - 12 - tw // 2, y0 + 26), tag, font('bold', 16), (255, 248, 232), 'mm')


def a_button(base, box, s, color, primary=False):
    x0, y0, x1, y1 = box
    shadow(base, box, 14, 7, 120, (0, 5))
    fill = grain((x1 - x0, y1 - y0), (232, 186, 88) if primary else dark(color, 0.08), 9, x0, True)
    base.alpha_composite(rounded((x1 - x0, y1 - y0), 14, fill), (x0, y0))
    d = ImageDraw.Draw(base, 'RGBA')
    d.rounded_rectangle([x0, y0, x1 - 1, y1 - 1], 14, outline=(58, 38, 24, 255), width=3)
    thread = (110, 70, 24, 255) if primary else light(color, 0.75) + (255,)
    stitches(d, [(x0 + 12, y0 + 8), (x1 - 12, y0 + 8)], thread, 2, 9, 7)
    stitches(d, [(x0 + 12, y1 - 9), (x1 - 12, y1 - 9)], thread, 2, 9, 7)
    text(d, ((x0 + x1) // 2, (y0 + y1) // 2 - 1), s, font('title', 23), INK if primary else (255, 248, 232), 'mm')


def a_steps(d, base, x, y, steps, color):
    for state, s in steps:
        if state == 'done':
            d.ellipse([x, y + 3, x + 22, y + 25], fill=dark(color, 0.1) + (255,), outline=(50, 34, 26, 255), width=2)
            d.line([(x + 5, y + 14), (x + 10, y + 19), (x + 17, y + 8)], fill=(255, 248, 232, 255), width=3)
            text(d, (x + 34, y), s, font('body', 21), INK_SOFT)
        elif state == 'now':
            d.polygon([(x + 2, y + 4), (x + 22, y + 14), (x + 2, y + 24)], fill=dark(color, 0.05) + (255,), outline=(50, 34, 26, 255))
            text(d, (x + 34, y), s, font('bold', 22), INK)
        else:
            d.ellipse([x + 2, y + 5, x + 20, y + 23], outline=(120, 96, 72, 255), width=2)
            text(d, (x + 34, y), s, font('italic', 21), (92, 74, 58))
        y += 36
    return y


def a_quest_box():
    base = backdrop(0, 0.12)
    inner = a_panel(base, (22, 22, 470, 230), BLUE, 16)
    d = ImageDraw.Draw(base, 'RGBA')
    a_patch(base, (inner[0] + 10, inner[1] + 10, inner[0] + 96, inner[1] + 42), BLUE, None, 'MAIN')
    base.alpha_composite(icon('G', 34), (inner[2] - 46, inner[1] + 9))
    text(d, (inner[0] + 106, inner[1] + 11), 'Key Ingredients', font('title', 24), INK)
    stitches(d, [(inner[0] + 10, inner[1] + 52), (inner[2] - 10, inner[1] + 52)], dark(BLUE, 0.1) + (255,), 2)
    y = a_steps(d, base, inner[0] + 14, inner[1] + 62, [('done', 'Win the pantry key'), ('now', 'Help the kitchen: finish a favour'), ('later', 'A step you have not found yet')], BLUE)
    text(d, (inner[0] + 14, y + 2), 'The Endless Buffet   -   step 2 of 5', font('body', 18), INK_SOFT)
    # the same box for a quest of another zone, to show the cloth follows the Path
    inner = a_panel(base, (22, 262, 470, 420), VIOLET, 16)
    a_patch(base, (inner[0] + 10, inner[1] + 10, inner[0] + 86, inner[1] + 42), VIOLET, None, 'SIDE')
    base.alpha_composite(icon('N', 34), (inner[2] - 46, inner[1] + 9))
    text(d, (inner[0] + 96, inner[1] + 11), 'Take a Number', font('title', 24), INK)
    stitches(d, [(inner[0] + 10, inner[1] + 52), (inner[2] - 10, inner[1] + 52)], dark(VIOLET, 0.1) + (255,), 2)
    a_steps(d, base, inner[0] + 14, inner[1] + 62, [('now', 'Find the lit elevator'), ('later', 'A step you have not found yet')], VIOLET)
    caption(base, 'MOCK-UP, direction A "Patchwork" (not in the game). The quest box: a linen page bound in the cloth of the quest\'s own Path (blue: the Buffet; violet: the D.N.A.).')
    save(base, 'a_quest_box')


def a_main_menu():
    base = backdrop()
    inner = a_panel(base, (540, 70, 1060, 820))
    d = ImageDraw.Draw(base, 'RGBA')
    cx = 800
    a_banner(base, cx, inner[1] + 18, 420, 'The Wayward Path', (150, 60, 44), 30)
    text(d, (cx, inner[1] + 96), 'Paused in Crosspath', font('italic', 21), INK_SOFT, 'mm')
    a_button(base, (cx - 190, inner[1] + 126, cx + 190, inner[1] + 186), 'Resume', GOLD, True)
    rows = [('Quest Log', BLUE, 'G'), ('Collection Book', VIOLET, 'N'), ('Feats', RED, 'B'), ('Glossary', GREEN, 'R'), ('Settings', BLUE, 'G'), ('Save and quit', VIOLET, 'N')]
    y = inner[1] + 204
    for label, color, key in rows:
        a_button(base, (cx - 190, y, cx + 190, y + 54), label, color)
        base.alpha_composite(icon(key, 34), (cx - 178, y + 10))
        y += 66
    y += 4
    for index, key in enumerate(['B', 'G', 'R', 'N']):
        base.alpha_composite(icon(key, 38), (cx - 92 + index * 48, y))
    text(d, (cx, inner[3] - 24), 'Four cloths, one seam each: the kingdom of Patchwork', font('italic', 18), INK_SOFT, 'mm')
    caption(base, 'MOCK-UP, direction A "Patchwork" (not in the game). The pause menu: one gold-thread button for what you most likely want, the rest in the four Path cloths.')
    save(base, 'a_main_menu')


def a_quest_log():
    base = backdrop()
    inner = a_panel(base, (120, 50, 1480, 840))
    d = ImageDraw.Draw(base, 'RGBA')
    a_banner(base, 800, inner[1] + 14, 380, 'Quest Log', (150, 60, 44), 30)
    x = inner[0] + 26
    for label, color, sel in (('Main', RED, True), ('Side', BLUE, False), ('Done', GREEN, False)):
        a_patch(base, (x, inner[1] + 22, x + 110, inner[1] + 64), color, None, label, sel)
        x += 122
    left = (inner[0] + 26, inner[1] + 100, inner[0] + 600, inner[3] - 26)
    quests = [('Key Ingredients', 'The Endless Buffet  -  step 3 of 5', BLUE, 'G', True), ('Raise the Bar', 'The Gainlands  -  step 1 of 4', RED, 'B', False),
              ('Root Cause', 'The Verdant Dump  -  step 2 of 6', GREEN, 'R', False), ('Take a Number', 'The D.N.A.  -  step 1 of 2', VIOLET, 'N', False),
              ('Fragments', 'Free a zone, then visit Elder Maren', (150, 110, 60), 'GENERIC', False)]
    y = left[1]
    for title, sub, color, key, sel in quests:
        a_row(base, (left[0], y, left[2], y + 78), color, key, title, sub, sel, 'TRACKED' if sel else None)
        y += 90
    px = left[2] + 34
    d.line([(px - 16, left[1]), (px - 16, left[3])], fill=(150, 124, 96, 255), width=2)
    stitches(d, [(px - 10, left[1]), (px - 10, left[3])], dark(BLUE, 0.1) + (255,), 2)
    base.alpha_composite(icon('G', 56), (px, left[1]))
    text(d, (px + 70, left[1] + 2), 'Key Ingredients', font('title', 32), INK)
    text(d, (px + 70, left[1] + 40), 'The Endless Buffet', font('italic', 22), dark(BLUE, 0.35))
    y = paragraph(d, (px, left[1] + 84), 'Chef Fennel Gravois holds the pantry key, and the kitchen will not help a stranger for nothing.', font('body', 23), INK, inner[2] - px - 30)
    y = a_steps(d, base, px, y + 14, [('done', 'Win the pantry key from Chef Fennel Gravois'), ('done', 'Step through the pantry door'), ('now', 'Help the kitchen: finish a favour'), ('later', 'A step you have not found yet'), ('later', 'A step you have not found yet')], BLUE)
    text(d, (px, y + 12), 'Reward', font('title', 22), INK)
    a_patch(base, (px, y + 46, px + 250, y + 86), (150, 110, 60), None, '320 gold  -  250 XP')
    a_patch(base, (px + 262, y + 46, px + 520, y + 86), BLUE, 'G', 'a Gourmand Path Pack')
    a_button(base, (inner[2] - 470, inner[3] - 84, inner[2] - 250, inner[3] - 28), 'Track', GOLD, True)
    a_button(base, (inner[2] - 236, inner[3] - 84, inner[2] - 26, inner[3] - 28), 'Show on map', BLUE)
    caption(base, 'MOCK-UP, direction A "Patchwork" (not in the game). The quest log: every quest wears its zone\'s Path cloth; unknown steps are dark ink in italics, never pale grey.')
    save(base, 'a_quest_log')


def a_tooltip():
    base = backdrop(3, 0.3)
    d = ImageDraw.Draw(base, 'RGBA')
    # a stand-in card the tooltip belongs to
    d.rounded_rectangle([420, 250, 660, 610], 14, fill=(40, 30, 44, 255), outline=dark(VIOLET, 0.1) + (255,), width=5)
    text(d, (540, 280), 'Vigor Mortis', font('title', 22), (240, 232, 220), 'mm')
    base.alpha_composite(icon('N', 40), (432, 560))
    base.alpha_composite(icon('B', 40), (476, 560))
    inner = a_panel(base, (690, 240, 1180, 520), None, 14)
    a_patch(base, (inner[0] + 10, inner[1] + 10, inner[0] + 150, inner[1] + 46), VIOLET, 'N', 'Reinstate')
    y = paragraph(d, (inner[0] + 12, inner[1] + 58), 'Return a unit from your Refuse Pile to the field. It arrives as a fresh copy: no damage, no buffs.', font('body', 21), INK, inner[2] - inner[0] - 24)
    stitches(d, [(inner[0] + 12, y + 8), (inner[2] - 12, y + 8)], (150, 124, 96, 255), 2)
    a_patch(base, (inner[0] + 10, y + 20, inner[0] + 128, y + 56), RED, 'B', 'Hustle')
    paragraph(d, (inner[0] + 12, y + 66), 'Can attack on the turn it enters.', font('body', 21), INK, inner[2] - inner[0] - 24)
    # a single-Path pop-up
    inner = a_panel(base, (690, 560, 1180, 760), GREEN, 14)
    text(d, (inner[0] + 14, inner[1] + 10), 'Wild Growth', font('title', 24), INK)
    paragraph(d, (inner[0] + 14, inner[1] + 46), 'A rule of this fight, for both sides: at the start of your turn one of your units gets +1/+1.', font('body', 21), INK, inner[2] - inner[0] - 28)
    a_button(base, (inner[2] - 132, inner[3] - 56, inner[2] - 12, inner[3] - 12), 'OK', GOLD, True)
    caption(base, 'MOCK-UP, direction A "Patchwork" (not in the game). A tooltip: each keyword is a sewn tag in its Path\'s cloth; a rule\'s pop-up is bound in that rule\'s Path.')
    save(base, 'a_tooltip')


def a_settings():
    base = backdrop()
    inner = a_panel(base, (200, 60, 1400, 830))
    d = ImageDraw.Draw(base, 'RGBA')
    a_banner(base, 800, inner[1] + 14, 340, 'Settings', (150, 60, 44), 30)
    x = inner[0] + 26
    for label, color, key, sel in (('Display', BLUE, 'G', True), ('Text', GREEN, 'R', False), ('Audio', VIOLET, 'N', False), ('Controls', RED, 'B', False)):
        a_patch(base, (x, inner[1] + 86, x + 196, inner[1] + 132), color, key, label, sel)
        x += 208
    stitches(d, [(inner[0] + 26, inner[1] + 146), (inner[2] - 26, inner[1] + 146)], dark(BLUE, 0.1) + (255,), 3)
    rows = [('Camera preset', 'How the camera sits behind you', 'choice', 'Cinematic'), ('Camera angle', 'How far it looks down (V cycles it)', 'choice', '+6 (default)'),
            ('Camera distance', 'Closer, default or further', 'slider', 0.5), ('Brightness', 'The world and the menus', 'slider', 0.7),
            ('Reduce motion', 'Fewer flashes, shakes and bobbing things', 'toggle', True), ('Full screen', '', 'toggle', False)]
    y = inner[1] + 164
    for title, sub, kind, value in rows:
        linen = rounded((inner[2] - inner[0] - 52, 76), 10, grain((inner[2] - inner[0] - 52, 76), (236, 224, 196), 6, y, True))
        base.alpha_composite(linen, (inner[0] + 26, y))
        d.rounded_rectangle([inner[0] + 26, y, inner[2] - 27, y + 75], 10, outline=(120, 96, 72, 255), width=2)
        d.rectangle([inner[0] + 26, y + 8, inner[0] + 34, y + 67], fill=dark(BLUE, 0.1) + (255,))
        text(d, (inner[0] + 50, y + (12 if sub else 24)), title, font('bold', 24), INK)
        if sub:
            text(d, (inner[0] + 50, y + 42), sub, font('body', 19), INK_SOFT)
        rx = inner[2] - 400
        if kind == 'choice':
            a_patch(base, (rx, y + 16, rx + 350, y + 60), BLUE, None, '<    %s    >' % value)
        elif kind == 'slider':
            d.rounded_rectangle([rx, y + 32, rx + 350, y + 44], 6, fill=(198, 182, 150, 255), outline=(90, 70, 52, 255), width=2)
            d.rounded_rectangle([rx, y + 32, rx + int(350 * value), y + 44], 6, fill=dark(BLUE, 0.1) + (255,))
            kx = rx + int(350 * value)
            d.ellipse([kx - 14, y + 24, kx + 14, y + 52], fill=GOLD + (255,), outline=(96, 66, 30, 255), width=3)
        else:
            d.rounded_rectangle([rx + 260, y + 22, rx + 350, y + 56], 17, fill=dark(BLUE, 0.1) + (255,) if value else (198, 182, 150, 255), outline=(60, 44, 32, 255), width=2)
            kx = rx + 333 if value else rx + 277
            d.ellipse([kx - 14, y + 25, kx + 14, y + 53], fill=GOLD + (255,), outline=(96, 66, 30, 255), width=3)
            text(d, (rx + 240, y + 38), 'On' if value else 'Off', font('bold', 21), INK, 'rm')
        y += 86
    a_button(base, (inner[2] - 250, inner[3] - 70, inner[2] - 26, inner[3] - 16), 'Done', GOLD, True)
    a_button(base, (inner[0] + 26, inner[3] - 70, inner[0] + 290, inner[3] - 16), 'Reset this page', VIOLET)
    caption(base, 'MOCK-UP, direction A "Patchwork" (not in the game). Settings: each tab is a Path\'s cloth and tints its own page (Display is blue); dark ink on linen for every line.')
    save(base, 'a_settings')


# ===================================================== Direction B: Stained glass ================================================

def glass(size, color, seed=1, glow=0.0):
    """A pane of coloured glass: lighter in the middle, mottled, a soft highlight."""
    w, h = size
    pane = grain((w, h), mix(color, (20, 14, 34), 0.25), 16, seed).convert('RGB')
    centre = Image.new('L', (w, h), 0)
    ImageDraw.Draw(centre).ellipse([-w * 0.1, -h * 0.5, w * 1.1, h * 1.5], fill=int(150 + 80 * glow))
    centre = centre.filter(ImageFilter.GaussianBlur(max(4, min(w, h) // 3)))
    pane = Image.composite(Image.new('RGB', (w, h), light(color, 0.45)), pane, centre.point(lambda v: v // 2))
    return pane.convert('RGBA')


def came(d, box, radius=0, width=4):
    """The lead-and-gold line round a pane."""
    d.rounded_rectangle(box, radius, outline=(30, 22, 30, 255), width=width + 3)
    d.rounded_rectangle(box, radius, outline=GOLD + (255,), width=max(1, width - 2))


def b_panel(base, box, accent=None, rose=True):
    """A night-blue page in a leaded gold frame; along its top a strip of four glowing panes (or one Path's pane)."""
    x0, y0, x1, y1 = box
    w, h = x1 - x0, y1 - y0
    shadow(base, box, 16, 24, 190)
    glow = Image.new('RGBA', base.size, (0, 0, 0, 0))
    ImageDraw.Draw(glow).rounded_rectangle([x0 - 4, y0 - 4, x1 + 4, y1 + 4], 18, outline=(accent or GOLD) + (150,), width=10)
    base.alpha_composite(glow.filter(ImageFilter.GaussianBlur(12)))
    page = rounded((w, h), 14, grain((w, h), NIGHT, 10, 41))
    base.alpha_composite(page, (x0, y0))
    d = ImageDraw.Draw(base, 'RGBA')
    strip = 18
    if rose:
        colours = [accent] * 4 if accent else [RED, BLUE, GREEN, VIOLET]
        step = (w - 24) / 8.0
        for index in range(8):
            px0 = int(x0 + 12 + index * step)
            px1 = int(x0 + 12 + (index + 1) * step)
            base.alpha_composite(glass((px1 - px0, strip), colours[index % 4], index + 3, 0.6), (px0, y0 + 10))
            came(d, [px0, y0 + 10, px1, y0 + 10 + strip], 0, 3)
    came(d, [x0, y0, x1 - 1, y1 - 1], 14, 5)
    for cx, cy in ((x0 + 3, y0 + 3), (x1 - 4, y0 + 3), (x1 - 4, y1 - 4), (x0 + 3, y1 - 4)):
        d.regular_polygon((cx, cy, 11), 4, rotation=45, fill=GOLD + (255,), outline=(40, 28, 20, 255))
    return [x0 + 16, y0 + (38 if rose else 14), x1 - 16, y1 - 16]


def b_title(base, cx, y, s, color, size=32):
    d = ImageDraw.Draw(base, 'RGBA')
    f = font('title', size)
    halo = Image.new('RGBA', base.size, (0, 0, 0, 0))
    ImageDraw.Draw(halo).text((cx, y), s, font=f, fill=light(color, 0.2) + (230,), anchor='ma')
    base.alpha_composite(halo.filter(ImageFilter.GaussianBlur(9)))
    text(d, (cx, y), s, f, (255, 246, 226), 'ma')
    tw = int(d.textlength(s, font=f))
    for side in (-1, 1):
        px = cx + side * (tw // 2 + 26)
        d.regular_polygon((px, y + size // 2 + 4, 8), 4, rotation=45, fill=light(color, 0.3) + (255,), outline=GOLD + (255,))
        d.line([(px + side * 14, y + size // 2 + 4), (px + side * 90, y + size // 2 + 4)], fill=GOLD + (255,), width=2)


def b_pane(base, box, color, key=None, label=None, selected=False, text_size=21):
    x0, y0, x1, y1 = box
    if selected:
        halo = Image.new('RGBA', base.size, (0, 0, 0, 0))
        ImageDraw.Draw(halo).rounded_rectangle([x0 - 3, y0 - 3, x1 + 3, y1 + 3], 9, fill=light(color, 0.25) + (190,))
        base.alpha_composite(halo.filter(ImageFilter.GaussianBlur(10)))
    pane = rounded((x1 - x0, y1 - y0), 7, glass((x1 - x0, y1 - y0), color if selected else mix(color, NIGHT, 0.35), x0 + y0, 1.0 if selected else 0.2))
    base.alpha_composite(pane, (x0, y0))
    d = ImageDraw.Draw(base, 'RGBA')
    came(d, [x0, y0, x1 - 1, y1 - 1], 7, 4 if selected else 3)
    cx = (x0 + x1) // 2
    if key:
        size = min(y1 - y0 - 12, 44)
        base.alpha_composite(icon(key, size), (x0 + 8 if label else cx - size // 2, (y0 + y1) // 2 - size // 2))
    if label:
        tx = cx + (20 if key else 0)
        d.text((tx + 1, (y0 + y1) // 2 + 1), label, font=font('bold', text_size), fill=(16, 10, 24, 255), anchor='mm')
        d.text((tx, (y0 + y1) // 2 - 1), label, font=font('bold', text_size), fill=(255, 250, 236, 255), anchor='mm')


def b_row(base, box, color, key, title, sub, selected=False, tag=None):
    x0, y0, x1, y1 = box
    d = ImageDraw.Draw(base, 'RGBA')
    if selected:
        halo = Image.new('RGBA', base.size, (0, 0, 0, 0))
        ImageDraw.Draw(halo).rounded_rectangle([x0 - 2, y0 - 2, x1 + 2, y1 + 2], 10, fill=color + (120,))
        base.alpha_composite(halo.filter(ImageFilter.GaussianBlur(12)))
    plate = rounded((x1 - x0, y1 - y0), 8, grain((x1 - x0, y1 - y0), mix(NIGHT, color, 0.34 if selected else 0.12), 9, y0))
    base.alpha_composite(plate, (x0, y0))
    came(d, [x0, y0, x1 - 1, y1 - 1], 8, 4 if selected else 3)
    b_pane(base, (x0 + 6, y0 + 6, x0 + 62, y1 - 6), color, key, None, True)
    text(d, (x0 + 76, y0 + 11), title, font('bold', 24), (255, 248, 230))
    text(d, (x0 + 76, y0 + 42), sub, font('body', 19), light(color, 0.62))
    if tag:
        tw = int(d.textlength(tag, font=font('bold', 16))) + 24
        b_pane(base, (x1 - tw - 12, y0 + 12, x1 - 12, y0 + 42), GOLD, None, tag, True, 16)


def b_button(base, box, s, color, primary=False):
    x0, y0, x1, y1 = box
    tone = (236, 176, 70) if primary else color
    halo = Image.new('RGBA', base.size, (0, 0, 0, 0))
    ImageDraw.Draw(halo).rounded_rectangle([x0, y0, x1, y1], 26, fill=tone + (150 if primary else 90,))
    base.alpha_composite(halo.filter(ImageFilter.GaussianBlur(11)))
    pane = rounded((x1 - x0, y1 - y0), 24, glass((x1 - x0, y1 - y0), tone if primary else mix(tone, NIGHT, 0.2), x0, 1.0 if primary else 0.4))
    base.alpha_composite(pane, (x0, y0))
    d = ImageDraw.Draw(base, 'RGBA')
    came(d, [x0, y0, x1 - 1, y1 - 1], 24, 4)
    cx, cy = (x0 + x1) // 2, (y0 + y1) // 2
    d.text((cx + 1, cy + 1), s, font=font('title', 23), fill=(20, 12, 20, 255), anchor='mm')
    d.text((cx, cy - 1), s, font=font('title', 23), fill=(48, 26, 10, 255) if primary else (255, 250, 236, 255), anchor='mm')


def b_steps(d, x, y, steps, color):
    for state, s in steps:
        if state == 'done':
            d.regular_polygon((x + 11, y + 14, 11), 4, rotation=45, fill=color + (255,), outline=GOLD + (255,))
            d.line([(x + 6, y + 14), (x + 10, y + 18), (x + 16, y + 9)], fill=(255, 250, 236, 255), width=3)
            text(d, (x + 34, y), s, font('body', 21), (196, 188, 204))
        elif state == 'now':
            d.polygon([(x + 2, y + 3), (x + 22, y + 14), (x + 2, y + 25)], fill=light(color, 0.35) + (255,), outline=GOLD + (255,))
            text(d, (x + 34, y), s, font('bold', 22), (255, 250, 236))
        else:
            d.regular_polygon((x + 11, y + 14, 10), 4, rotation=45, outline=(176, 168, 190, 255))
            text(d, (x + 34, y), s, font('italic', 21), (206, 198, 216))
        y += 36
    return y


def b_quest_box():
    base = backdrop(0, 0.12)
    inner = b_panel(base, (22, 22, 470, 236), BLUE)
    d = ImageDraw.Draw(base, 'RGBA')
    b_pane(base, (inner[0], inner[1] + 6, inner[0] + 86, inner[1] + 38), BLUE, None, 'MAIN', True, 17)
    base.alpha_composite(icon('G', 34), (inner[2] - 36, inner[1] + 5))
    text(d, (inner[0] + 98, inner[1] + 6), 'Key Ingredients', font('title', 24), (255, 248, 230))
    d.line([(inner[0], inner[1] + 48), (inner[2], inner[1] + 48)], fill=light(BLUE, 0.2) + (255,), width=2)
    y = b_steps(d, inner[0] + 4, inner[1] + 58, [('done', 'Win the pantry key'), ('now', 'Help the kitchen: finish a favour'), ('later', 'A step you have not found yet')], BLUE)
    text(d, (inner[0] + 4, y + 2), 'The Endless Buffet   -   step 2 of 5', font('body', 18), light(BLUE, 0.6))
    inner = b_panel(base, (22, 268, 470, 430), VIOLET)
    b_pane(base, (inner[0], inner[1] + 6, inner[0] + 76, inner[1] + 38), VIOLET, None, 'SIDE', True, 17)
    base.alpha_composite(icon('N', 34), (inner[2] - 36, inner[1] + 5))
    text(d, (inner[0] + 88, inner[1] + 6), 'Take a Number', font('title', 24), (255, 248, 230))
    d.line([(inner[0], inner[1] + 48), (inner[2], inner[1] + 48)], fill=light(VIOLET, 0.2) + (255,), width=2)
    b_steps(d, inner[0] + 4, inner[1] + 58, [('now', 'Find the lit elevator'), ('later', 'A step you have not found yet')], VIOLET)
    caption(base, 'MOCK-UP, direction B "Stained glass" (not in the game). The quest box: a night-blue pane, lit along its top in the glass of the quest\'s own Path.')
    save(base, 'b_quest_box')


def b_main_menu():
    base = backdrop(8, 0.62)
    inner = b_panel(base, (540, 70, 1060, 820))
    d = ImageDraw.Draw(base, 'RGBA')
    cx = 800
    # a rose window of the four Paths
    rcx, rcy, rr = cx, inner[1] + 86, 62
    for index, (key, color) in enumerate((('B', RED), ('G', BLUE), ('R', GREEN), ('N', VIOLET))):
        layer = Image.new('RGBA', base.size, (0, 0, 0, 0))
        ImageDraw.Draw(layer).pieslice([rcx - rr, rcy - rr, rcx + rr, rcy + rr], -135 + index * 90, -45 + index * 90, fill=light(color, 0.12) + (255,), outline=(30, 22, 30, 255), width=4)
        base.alpha_composite(layer)
    d.ellipse([rcx - rr, rcy - rr, rcx + rr, rcy + rr], outline=GOLD + (255,), width=4)
    d.ellipse([rcx - 16, rcy - 16, rcx + 16, rcy + 16], fill=GOLD + (255,), outline=(40, 28, 20, 255), width=3)
    for key, dx, dy in (('B', 0, -38), ('G', 38, 0), ('R', 0, 38), ('N', -38, 0)):
        base.alpha_composite(icon(key, 30), (rcx + dx - 15, rcy + dy - 15))
    b_title(base, cx, inner[1] + 160, 'The Wayward Path', GOLD, 30)
    text(d, (cx, inner[1] + 214), 'Paused in Crosspath', font('italic', 21), (206, 198, 216), 'mm')
    b_button(base, (cx - 190, inner[1] + 238, cx + 190, inner[1] + 296), 'Resume', GOLD, True)
    rows = [('Quest Log', BLUE, 'G'), ('Collection Book', VIOLET, 'N'), ('Feats', RED, 'B'), ('Glossary', GREEN, 'R'), ('Settings', BLUE, 'G'), ('Save and quit', VIOLET, 'N')]
    y = inner[1] + 312
    for label, color, key in rows:
        b_button(base, (cx - 190, y, cx + 190, y + 52), label, color)
        base.alpha_composite(icon(key, 32), (cx - 176, y + 10))
        y += 63
    caption(base, 'MOCK-UP, direction B "Stained glass" (not in the game). The pause menu: a rose window of the four Paths, an amber pane for Resume, a coloured pane for each page.')
    save(base, 'b_main_menu')


def b_quest_log():
    base = backdrop(8, 0.62)
    inner = b_panel(base, (120, 50, 1480, 840))
    d = ImageDraw.Draw(base, 'RGBA')
    b_title(base, 800, inner[1] + 2, 'Quest Log', GOLD, 32)
    x = inner[0] + 10
    for label, color, sel in (('Main', RED, True), ('Side', BLUE, False), ('Done', GREEN, False)):
        b_pane(base, (x, inner[1] + 6, x + 110, inner[1] + 48), color, None, label, sel)
        x += 122
    left = (inner[0] + 10, inner[1] + 76, inner[0] + 590, inner[3] - 10)
    quests = [('Key Ingredients', 'The Endless Buffet  -  step 3 of 5', BLUE, 'G', True), ('Raise the Bar', 'The Gainlands  -  step 1 of 4', RED, 'B', False),
              ('Root Cause', 'The Verdant Dump  -  step 2 of 6', GREEN, 'R', False), ('Take a Number', 'The D.N.A.  -  step 1 of 2', VIOLET, 'N', False),
              ('Fragments', 'Free a zone, then visit Elder Maren', GOLD, 'GENERIC', False)]
    y = left[1]
    for title, sub, color, key, sel in quests:
        b_row(base, (left[0], y, left[2], y + 78), color, key, title, sub, sel, 'TRACKED' if sel else None)
        y += 90
    px = left[2] + 36
    d.line([(px - 18, left[1]), (px - 18, left[3])], fill=(30, 22, 30, 255), width=6)
    d.line([(px - 18, left[1]), (px - 18, left[3])], fill=GOLD + (255,), width=2)
    b_pane(base, (px, left[1], px + 60, left[1] + 60), BLUE, 'G', None, True)
    text(d, (px + 76, left[1] + 0), 'Key Ingredients', font('title', 32), (255, 248, 230))
    text(d, (px + 76, left[1] + 38), 'The Endless Buffet', font('italic', 22), light(BLUE, 0.45))
    y = paragraph(d, (px, left[1] + 84), 'Chef Fennel Gravois holds the pantry key, and the kitchen will not help a stranger for nothing.', font('body', 23), (236, 230, 240), inner[2] - px - 20)
    y = b_steps(d, px, y + 14, [('done', 'Win the pantry key from Chef Fennel Gravois'), ('done', 'Step through the pantry door'), ('now', 'Help the kitchen: finish a favour'), ('later', 'A step you have not found yet'), ('later', 'A step you have not found yet')], BLUE)
    text(d, (px, y + 12), 'Reward', font('title', 22), GOLD)
    b_pane(base, (px, y + 46, px + 250, y + 86), GOLD, None, '320 gold  -  250 XP', False)
    b_pane(base, (px + 262, y + 46, px + 520, y + 86), BLUE, 'G', 'a Gourmand Path Pack', True)
    b_button(base, (inner[2] - 460, inner[3] - 66, inner[2] - 240, inner[3] - 10), 'Track', GOLD, True)
    b_button(base, (inner[2] - 226, inner[3] - 66, inner[2] - 10, inner[3] - 10), 'Show on map', BLUE)
    caption(base, 'MOCK-UP, direction B "Stained glass" (not in the game). The quest log: each quest is a plate with a lit pane in its zone\'s Path colour; the chosen one glows.')
    save(base, 'b_quest_log')


def b_tooltip():
    base = backdrop(3, 0.3)
    d = ImageDraw.Draw(base, 'RGBA')
    d.rounded_rectangle([420, 250, 660, 610], 14, fill=(40, 30, 44, 255), outline=dark(VIOLET, 0.1) + (255,), width=5)
    text(d, (540, 280), 'Vigor Mortis', font('title', 22), (240, 232, 220), 'mm')
    base.alpha_composite(icon('N', 40), (432, 560))
    base.alpha_composite(icon('B', 40), (476, 560))
    inner = b_panel(base, (690, 240, 1180, 520), None, False)
    b_pane(base, (inner[0], inner[1] + 2, inner[0] + 150, inner[1] + 40), VIOLET, 'N', 'Reinstate', True)
    y = paragraph(d, (inner[0] + 2, inner[1] + 52), 'Return a unit from your Refuse Pile to the field. It arrives as a fresh copy: no damage, no buffs.', font('body', 21), (236, 230, 240), inner[2] - inner[0] - 6)
    d.line([(inner[0], y + 8), (inner[2], y + 8)], fill=GOLD + (200,), width=1)
    b_pane(base, (inner[0], y + 20, inner[0] + 124, y + 58), RED, 'B', 'Hustle', True)
    paragraph(d, (inner[0] + 2, y + 68), 'Can attack on the turn it enters.', font('body', 21), (236, 230, 240), inner[2] - inner[0] - 6)
    inner = b_panel(base, (690, 560, 1180, 770), GREEN)
    text(d, (inner[0] + 2, inner[1] + 2), 'Wild Growth', font('title', 24), light(GREEN, 0.55))
    paragraph(d, (inner[0] + 2, inner[1] + 40), 'A rule of this fight, for both sides: at the start of your turn one of your units gets +1/+1.', font('body', 21), (236, 230, 240), inner[2] - inner[0] - 6)
    b_button(base, (inner[2] - 124, inner[3] - 46, inner[2], inner[3]), 'OK', GOLD, True)
    caption(base, 'MOCK-UP, direction B "Stained glass" (not in the game). A tooltip: each keyword is a small lit pane in its Path\'s colour; a rule\'s pop-up carries that Path\'s strip.')
    save(base, 'b_tooltip')


def b_settings():
    base = backdrop(8, 0.62)
    inner = b_panel(base, (200, 60, 1400, 830))
    d = ImageDraw.Draw(base, 'RGBA')
    b_title(base, 800, inner[1] + 2, 'Settings', GOLD, 32)
    x = inner[0] + 10
    for label, color, key, sel in (('Display', BLUE, 'G', True), ('Text', GREEN, 'R', False), ('Audio', VIOLET, 'N', False), ('Controls', RED, 'B', False)):
        b_pane(base, (x, inner[1] + 62, x + 200, inner[1] + 110), color, key, label, sel)
        x += 212
    d.line([(inner[0] + 10, inner[1] + 124), (inner[2] - 10, inner[1] + 124)], fill=light(BLUE, 0.2) + (255,), width=3)
    rows = [('Camera preset', 'How the camera sits behind you', 'choice', 'Cinematic'), ('Camera angle', 'How far it looks down (V cycles it)', 'choice', '+6 (default)'),
            ('Camera distance', 'Closer, default or further', 'slider', 0.5), ('Brightness', 'The world and the menus', 'slider', 0.7),
            ('Reduce motion', 'Fewer flashes, shakes and bobbing things', 'toggle', True), ('Full screen', '', 'toggle', False)]
    y = inner[1] + 142
    for title, sub, kind, value in rows:
        plate = rounded((inner[2] - inner[0] - 20, 76), 8, grain((inner[2] - inner[0] - 20, 76), mix(NIGHT, BLUE, 0.1), 8, y))
        base.alpha_composite(plate, (inner[0] + 10, y))
        came(d, [inner[0] + 10, y, inner[2] - 11, y + 75], 8, 3)
        base.alpha_composite(glass((8, 58), BLUE, y, 1.0), (inner[0] + 18, y + 9))
        text(d, (inner[0] + 40, y + (11 if sub else 24)), title, font('bold', 24), (255, 248, 230))
        if sub:
            text(d, (inner[0] + 40, y + 42), sub, font('body', 19), light(BLUE, 0.62))
        rx = inner[2] - 380
        if kind == 'choice':
            b_pane(base, (rx, y + 16, rx + 350, y + 60), BLUE, None, '<    %s    >' % value, True)
        elif kind == 'slider':
            d.rounded_rectangle([rx, y + 31, rx + 350, y + 45], 7, fill=(14, 10, 24, 255), outline=GOLD + (255,), width=2)
            base.alpha_composite(rounded((int(350 * value), 10), 5, glass((int(350 * value), 10), BLUE, y, 1.0)), (rx + 2, y + 33))
            kx = rx + int(350 * value)
            d.regular_polygon((kx, y + 38, 16), 4, rotation=45, fill=GOLD + (255,), outline=(40, 28, 20, 255))
        else:
            d.rounded_rectangle([rx + 260, y + 21, rx + 350, y + 57], 18, fill=(14, 10, 24, 255), outline=GOLD + (255,), width=2)
            if value:
                base.alpha_composite(rounded((84, 30), 15, glass((84, 30), BLUE, y, 1.0)), (rx + 263, y + 24))
            kx = rx + 332 if value else rx + 278
            d.ellipse([kx - 14, y + 25, kx + 14, y + 53], fill=GOLD + (255,), outline=(40, 28, 20, 255), width=3)
            text(d, (rx + 240, y + 38), 'On' if value else 'Off', font('bold', 21), (255, 248, 230), 'rm')
        y += 86
    b_button(base, (inner[2] - 240, inner[3] - 56, inner[2] - 10, inner[3] - 2), 'Done', GOLD, True)
    b_button(base, (inner[0] + 10, inner[3] - 56, inner[0] + 280, inner[3] - 2), 'Reset this page', VIOLET)
    caption(base, 'MOCK-UP, direction B "Stained glass" (not in the game). Settings: each tab is a Path\'s pane and lights its own page (Display is blue); pale lettering on night blue.')
    save(base, 'b_settings')


if __name__ == '__main__':
    print('ui_mockups_v2 ->', os.path.relpath(OUT, ROOT))
    a_quest_box(); a_main_menu(); a_quest_log(); a_tooltip(); a_settings()
    b_quest_box(); b_main_menu(); b_quest_log(); b_tooltip(); b_settings()
