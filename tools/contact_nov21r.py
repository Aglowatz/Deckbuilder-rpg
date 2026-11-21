"""Fable Nov 21 review: contact sheets of a play run's shots, to look at many screens at once.
   python tools/contact_nov21r.py <run name under _screenshots/play> [prefix] [per_sheet=4] [cols=2]
   Writes _screenshots/play/<run>/sheet_NN.jpg"""
import os, sys
from PIL import Image, ImageDraw
ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
src = os.path.join(ROOT, '_screenshots', 'play', sys.argv[1])
prefix = sys.argv[2] if len(sys.argv) > 2 else ''
per = int(sys.argv[3]) if len(sys.argv) > 3 else 4
cols = int(sys.argv[4]) if len(sys.argv) > 4 else 2
names = [n for n in sorted(os.listdir(src)) if n.endswith('.png') and n.startswith(prefix)]
cw = 1600 // cols
for start in range(0, len(names), per):
    group = names[start:start + per]
    rows = (len(group) + cols - 1) // cols
    first = Image.open(os.path.join(src, group[0]))
    ch = int(cw * first.height / first.width)
    sheet = Image.new('RGB', (cw * cols, ch * rows), (20, 20, 20))
    draw = ImageDraw.Draw(sheet)
    for i, name in enumerate(group):
        im = Image.open(os.path.join(src, name)).convert('RGB').resize((cw, ch), Image.LANCZOS)
        x, y = (i % cols) * cw, (i // cols) * ch
        sheet.paste(im, (x, y))
        draw.rectangle([x, y, x + 8 + 6 * len(name), y + 14], fill=(0, 0, 0))
        draw.text((x + 4, y + 2), name[:-4], fill=(255, 255, 0))
    out = os.path.join(src, 'sheet_%02d.jpg' % (start // per))
    sheet.save(out, quality=88)
    print(out)
