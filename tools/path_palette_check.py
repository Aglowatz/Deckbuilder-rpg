"""Fable Nov 19 (Part 3): checks the Path palette - the pairwise colour difference (CIE76 in Lab) for normal vision and for simulated
protanopia / deuteranopia / tritanopia (Vienot 1999 matrices on linear RGB), and the WCAG contrast on the dark panel and on
parchment. Draws the swatch sheet.   python tools/path_palette_check.py [out.png]
The palette is read from core/data/path_palette.json (the file the game reads)."""
import json, sys, os, itertools
from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
DARK = (0x1c, 0x17, 0x22)
PARCHMENT = (0xe9, 0xdc, 0xbf)
NAMES = ['beefcake', 'gourmand', 'refusemancer', 'necrocrat']


def lin(c):
    c = c / 255.0
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4


def unlin(v):
    v = max(0.0, min(1.0, v))
    return int(round((v * 12.92 if v <= 0.0031308 else 1.055 * v ** (1 / 2.4) - 0.055) * 255))


SIMS = {
    'protan': ((0.11238, 0.88762, 0.0), (0.11238, 0.88762, 0.0), (0.00401, -0.00401, 1.0)),
    'deutan': ((0.29275, 0.70725, 0.0), (0.29275, 0.70725, 0.0), (-0.02234, 0.02234, 1.0)),
    'tritan': ((1.01277, 0.13548, -0.14826), (-0.01243, 0.86812, 0.14431), (0.07589, 0.805, 0.11911)),
}


def sim(rgb_value, kind):
    if kind == 'normal':
        return rgb_value
    l = [lin(c) for c in rgb_value]
    m = SIMS[kind]
    return tuple(unlin(sum(m[r][k] * l[k] for k in range(3))) for r in range(3))


def lab(rgb_value):
    r, g, b = [lin(c) for c in rgb_value]
    x = (0.4124 * r + 0.3576 * g + 0.1805 * b) / 0.95047
    y = 0.2126 * r + 0.7152 * g + 0.0722 * b
    z = (0.0193 * r + 0.1192 * g + 0.9505 * b) / 1.08883
    f = lambda t: t ** (1 / 3) if t > 0.008856 else 7.787 * t + 16 / 116
    return (116 * f(y) - 16, 500 * (f(x) - f(y)), 200 * (f(y) - f(z)))


def de(a, b):
    la, lb = lab(a), lab(b)
    return sum((p - q) ** 2 for p, q in zip(la, lb)) ** 0.5


def lum(rgb_value):
    r, g, b = [lin(c) for c in rgb_value]
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def contrast(a, b):
    la, lb = lum(a), lum(b)
    return (max(la, lb) + 0.05) / (min(la, lb) + 0.05)


def rgb(hexs):
    hexs = hexs.lstrip('#')
    return tuple(int(hexs[i:i + 2], 16) for i in (0, 2, 4))


def worst_pair(mains):
    """mains: {name: hex}. The smallest difference between two Paths under each kind of vision."""
    result = {}
    for kind in ['normal', 'protan', 'deutan', 'tritan']:
        result[kind] = min(de(sim(rgb(mains[a]), kind), sim(rgb(mains[b]), kind)) for a, b in itertools.combinations(NAMES, 2))
    return result


def report(palette, label):
    print('==', label)
    worst = 1e9
    for kind in ['normal', 'protan', 'deutan', 'tritan']:
        row = []
        for a, b in itertools.combinations(NAMES, 2):
            d = de(sim(rgb(palette[a]['main']), kind), sim(rgb(palette[b]['main']), kind))
            worst = min(worst, d)
            row.append('%s-%s %.0f' % (a[0].upper(), b[0].upper(), d))
        print('  %-7s %s' % (kind, '  '.join(row)))
    for n in NAMES:
        print('  %-13s main %s on dark %.1f:1   ink %s on parchment %.1f:1' % (n, palette[n]['main'], contrast(rgb(palette[n]['main']), DARK), palette[n]['ink'], contrast(rgb(palette[n]['ink']), PARCHMENT)))
    print('  smallest difference between two Paths, any vision: %.0f' % worst)
    return worst


def sheet(palette, out):
    names = NAMES + ['colorless']
    try:
        font = ImageFont.truetype('arialbd.ttf', 22)
        small = ImageFont.truetype('arial.ttf', 17)
    except Exception:
        font = small = ImageFont.load_default()
    w, h = 1500, 880
    im = Image.new('RGB', (w, h), (30, 26, 36))
    d = ImageDraw.Draw(im)
    d.text((24, 16), 'The Wayward Path - one colour per Path (core/data/path_palette.json)', fill=(240, 226, 190), font=font)
    col_w = 290
    for i, n in enumerate(names):
        x = 24 + i * col_w
        p = palette[n]
        d.text((x, 60), n.capitalize(), fill=(240, 226, 190), font=font)
        d.rectangle((x, 96, x + 170, 236), fill=rgb(p['main']))
        d.rectangle((x + 170, 96, x + 260, 236), fill=rgb(p['accent']))
        d.text((x, 242), 'main %s' % p['main'].upper(), fill=(230, 225, 215), font=small)
        d.text((x, 264), 'accent %s' % p['accent'].upper(), fill=(230, 225, 215), font=small)
        d.text((x, 286), 'ink %s (on parchment)' % p['ink'].upper(), fill=(230, 225, 215), font=small)
        d.rectangle((x, 320, x + 260, 384), fill=DARK, outline=rgb(p['main']), width=3)
        d.text((x + 12, 338), '%s on dark' % n.capitalize(), fill=rgb(p['main']), font=small)
        d.rectangle((x, 394, x + 260, 458), fill=PARCHMENT, outline=rgb(p['ink']), width=3)
        d.text((x + 12, 412), '%s on parchment' % n.capitalize(), fill=rgb(p['ink']), font=small)
        d.rectangle((x, 470, x + 260, 496), fill=(12, 10, 16))
        d.rectangle((x + 2, 472, x + 180, 494), fill=rgb(p['main']))
        d.rectangle((x + 2, 472, x + 180, 477), fill=rgb(p['accent']))
        for k, kind in enumerate(['protan', 'deutan', 'tritan']):
            y = 540 + k * 100
            d.rectangle((x, y, x + 170, y + 70), fill=sim(rgb(p['main']), kind))
            d.rectangle((x + 170, y, x + 260, y + 70), fill=sim(rgb(p['accent']), kind))
            if i == 0:
                d.text((x + 4, y + 74), 'as seen with %sopia' % kind, fill=(170, 165, 160), font=small)
    d.text((24, 510), 'Colour-blind simulation (main | accent):', fill=(240, 226, 190), font=small)
    im.save(out)
    print(out)


if __name__ == '__main__':
    data = json.load(open(os.path.join(ROOT, 'core', 'data', 'path_palette.json')))
    report(data['paths'], 'core/data/path_palette.json')
    for name, alt in data.get('alternatives', {}).items():
        merged = {k: dict(v) for k, v in data['paths'].items()}
        for k, v in alt.items():
            if k in merged:
                merged[k].update(v)
        report(merged, 'alternative: ' + name)
    sheet(data['paths'], sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, 'docs', 'art', 'path_colour_swatches.png'))
