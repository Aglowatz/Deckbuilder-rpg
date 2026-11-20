"""Fable Nov 21: copies a play run's screenshots into docs/overnight_shots/nov20/ as JPEGs (quality 86).
   python tools/shots_nov21.py <run name under _screenshots/play> [name prefix]"""
import os, sys
from PIL import Image

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
src = os.path.join(ROOT, '_screenshots', 'play', sys.argv[1])
prefix = sys.argv[2] if len(sys.argv) > 2 else ''
out = os.path.join(ROOT, 'docs', 'overnight_shots', 'nov20')
os.makedirs(out, exist_ok=True)
count = 0
for name in sorted(os.listdir(src)):
    if name.endswith('.png') and name.startswith(prefix):
        Image.open(os.path.join(src, name)).convert('RGB').save(os.path.join(out, name[:-4] + '.jpg'), quality=86)
        count += 1
print('%d shots -> docs/overnight_shots/nov20' % count)
