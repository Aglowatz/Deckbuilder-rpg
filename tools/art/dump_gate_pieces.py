"""Fable Nov 16b (Part 3): the Verdant Dump's entrance as a real gate. Cuts the approved thorn wall painting (KIT-HEAP-THORNWALL: two old
trees with violet thorns between them) into its three parts - the left tree, the right tree and the thorn thicket - so the trees can
stand on either side of the path as an arch and the thorns can block the forest road on their own. No new painting: every pixel is
from the approved picture.

Usage: python tools/art/dump_gate_pieces.py            (writes assets/art/zone_kits/heap/KIT-HEAP-GATE-TREE-L / -R / KIT-HEAP-THORN-THICKET.webp)
       python tools/art/dump_gate_pieces.py --preview   (also writes PNG previews on a grey ground to _screenshots/gate_pieces/)

How: the thorns are the only violet / magenta thing in the picture. A tree is the connected run of opaque, non-violet pixels that
contains its trunk; the thicket is everything else (the glowing pods sit inside the thorns and stay with them)."""
import colorsys
import os
import sys

from PIL import Image, ImageChops, ImageDraw, ImageFilter

SRC = 'assets/art/zone_kits/heap/KIT-HEAP-THORNWALL.webp'
OUT = 'assets/art/zone_kits/heap/%s.webp'
# A point on each trunk, in source pixels.
SEEDS = {'L': (165, 700), 'R': (1290, 700)}


def violet_mask(image):
    """255 where a pixel is thorn-coloured (violet to magenta), else 0."""
    rgb = image.convert('RGB')
    mask = Image.new('L', image.size, 0)
    src = rgb.load()
    dst = mask.load()
    for y in range(image.height):
        for x in range(image.width):
            r, g, b = src[x, y]
            h, s, v = colorsys.rgb_to_hsv(r / 255.0, g / 255.0, b / 255.0)
            hue = h * 360.0
            if 255.0 <= hue <= 350.0 and s > 0.22:
                dst[x, y] = 255
    return mask


def main_body_only(piece, seed):
    """Keeps the connected part of `piece` that contains `seed` (loose specks go)."""
    solid = piece.getchannel('A').point(lambda v: 128 if v > 40 else 0)
    x, y = seed
    while solid.getpixel((x, y)) == 0 and x < piece.width - 1:
        x += 1
    ImageDraw.floodfill(solid, (x, y), 255, thresh=0)
    keep = solid.point(lambda v: 255 if v == 255 else 0).filter(ImageFilter.MaxFilter(3))
    piece.putalpha(ImageChops.multiply(piece.getchannel('A'), keep))
    return piece


def main():
    image = Image.open(SRC).convert('RGBA')
    alpha = image.getchannel('A')
    violet = violet_mask(image)
    # Opaque and not violet: where a flood fill from a trunk may run. 128 = fillable, 0 = wall.
    solid = alpha.point(lambda a: 128 if a > 60 else 0)
    fillable = ImageChops.multiply(solid, ImageChops.invert(violet).point(lambda v: 255 if v > 0 else 0)).point(lambda v: 128 if v > 0 else 0)
    # Close one-pixel violet seams so a leaf drawn over a thorn stays with its tree, but do not bridge into the thicket.
    trees = Image.new('L', image.size, 0)
    pieces = {}
    for side, seed in SEEDS.items():
        work = fillable.copy()
        ImageDraw.floodfill(work, seed, 255, thresh=0)
        mask = work.point(lambda v: 255 if v == 255 else 0)
        # A soft, slightly drawn-in edge: no violet fringe.
        # Thin loose vines that ran into the thorns are dropped (an opening: shrink, then grow back), then a soft, slightly drawn-in edge.
        opened = mask.filter(ImageFilter.MinFilter(9)).filter(ImageFilter.MaxFilter(11))
        mask = ImageChops.multiply(mask, opened).filter(ImageFilter.MinFilter(3)).filter(ImageFilter.GaussianBlur(0.9))
        trees = ImageChops.lighter(trees, mask)
        piece = image.copy()
        piece.putalpha(ImageChops.multiply(alpha, mask))
        piece = main_body_only(piece, seed)
        pieces['KIT-HEAP-GATE-TREE-%s' % side] = piece.crop(piece.getbbox())
    # The thicket: what is left, without the trees (their mask grown a little so no trunk-coloured rim stays behind).
    grown = trees.filter(ImageFilter.MaxFilter(5)).filter(ImageFilter.GaussianBlur(1.0))
    thicket = image.copy()
    thicket.putalpha(ImageChops.multiply(alpha, ImageChops.invert(grown)))
    # Drop loose specks (bits of leaf or rock that were not joined to a trunk): keep what touches the violet mass.
    keep = violet.filter(ImageFilter.MaxFilter(21))
    thicket.putalpha(ImageChops.multiply(thicket.getchannel('A'), keep))
    # ... and thin leftovers along the cut (an opening again).
    body = thicket.getchannel('A').point(lambda v: 255 if v > 90 else 0)
    body = body.filter(ImageFilter.MinFilter(9)).filter(ImageFilter.MaxFilter(13)).filter(ImageFilter.GaussianBlur(1.0))
    thicket.putalpha(ImageChops.multiply(thicket.getchannel('A'), body))
    thicket = main_body_only(thicket, (image.width // 2, image.height // 2))
    pieces['KIT-HEAP-THORN-THICKET'] = thicket.crop(thicket.getbbox())
    for name, piece in pieces.items():
        piece.save(OUT % name, 'WEBP', quality=92, method=6, exact=True)
        print('%s %dx%d' % (name, piece.width, piece.height))
        if '--preview' in sys.argv:
            os.makedirs('_screenshots/gate_pieces', exist_ok=True)
            ground = Image.new('RGBA', piece.size, (120, 130, 120, 255))
            ground.alpha_composite(piece)
            ground.convert('RGB').save('_screenshots/gate_pieces/%s.png' % name)


if __name__ == '__main__':
    main()
