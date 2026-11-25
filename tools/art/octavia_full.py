"""Fable Nov 25 (Part 4, the owner's item 15): Octavia Eightfold whole, for the Shuffle House menu. Her dialogue portrait
(NPC-OCTAVIA) is cut off below the knees, so in the menu she floated in her panel with a cut edge. Her talking world sprite
(Approved_Sprites/SPR-OCTAVIA-FRONT_TALK.png, 1024x1536) shows her down to the hem of her gown: it is trimmed to the figure
and stored 1,100 px tall as assets/art/derived/NPC-OCTAVIA-FULL.webp. Idempotent.
    python tools/art/octavia_full.py"""
import os

import numpy as np
from PIL import Image

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
SOURCE = 'G:/My Drive/Card Game Art/Approved_Sprites/SPR-OCTAVIA-FRONT_TALK.png'
OUT = os.path.join(ROOT, 'assets', 'art', 'derived', 'NPC-OCTAVIA-FULL.webp')
HEIGHT = 1100


def main():
    image = Image.open(SOURCE).convert('RGBA')
    data = np.asarray(image).copy()
    data[data[..., 3] < 24] = 0  # faint stray alpha round the figure
    image = Image.fromarray(data, 'RGBA')
    image = image.crop(image.getbbox())
    scale = HEIGHT / float(image.size[1])
    image = image.resize((int(round(image.size[0] * scale)), HEIGHT), Image.LANCZOS)
    image.save(OUT, lossless=False, quality=90, method=6)
    print('%s %dx%d' % (os.path.relpath(OUT, ROOT), image.size[0], image.size[1]))


if __name__ == '__main__':
    main()
