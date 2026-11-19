"""Fable Nov 19: a labelled contact sheet.  python tools/contact_sheet.py <out.jpg> <cols> <cell_width> <label=file> [<label=file> ...]"""
import sys
from PIL import Image, ImageDraw, ImageFont

out, cols, cell_w = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
items = [a.split('=', 1) for a in sys.argv[4:]]
try:
    font = ImageFont.truetype('arialbd.ttf', max(14, cell_w // 28))
except Exception:
    font = ImageFont.load_default()
cells = []
for label, path in items:
    try:
        im = Image.open(path).convert('RGB')
    except Exception:
        im = Image.new('RGB', (1600, 900), (40, 20, 20))
    h = int(im.height * cell_w / im.width)
    im = im.resize((cell_w, h), Image.LANCZOS)
    d = ImageDraw.Draw(im)
    box = d.textbbox((0, 0), label, font=font)
    d.rectangle((0, 0, box[2] + 14, box[3] + 10), fill=(0, 0, 0))
    d.text((7, 4), label, fill=(255, 235, 170), font=font)
    cells.append(im)
rows = (len(cells) + cols - 1) // cols
ch = max(c.height for c in cells)
sheet = Image.new('RGB', (cols * cell_w + (cols + 1) * 6, rows * ch + (rows + 1) * 6), (18, 18, 22))
for i, c in enumerate(cells):
    sheet.paste(c, (6 + (i % cols) * (cell_w + 6), 6 + (i // cols) * (ch + 6)))
sheet.save(out, quality=86)
print(out, sheet.size)
