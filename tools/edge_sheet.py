"""Fable Nov 12d (Part 3.2): contact sheets of a zone's edge shots (the play-script driver's `edgeshots <prefix>`).

    python tools/edge_sheet.py <run dir> <prefix> <out dir>

Writes <out dir>/<prefix>_edges_default.jpg and <prefix>_edges_low.jpg: the eight compass points (N, NE, E, SE, S, SW, W, NW) in a
4 x 2 grid, each labelled, plus every single shot as a JPG next to them.
"""
import os
import sys

from PIL import Image, ImageDraw

DIRS = ["n", "ne", "e", "se", "s", "sw", "w", "nw"]
TILE = (640, 360)


def main() -> None:
    run_dir, prefix, out_dir = sys.argv[1], sys.argv[2], sys.argv[3]
    os.makedirs(out_dir, exist_ok=True)
    for cam in ("default", "low"):
        sheet = Image.new("RGB", (TILE[0] * 4, TILE[1] * 2), (20, 20, 20))
        draw = ImageDraw.Draw(sheet)
        found = 0
        for index, key in enumerate(DIRS):
            path = os.path.join(run_dir, "%s_%s_%s.png" % (prefix, key, cam))
            if not os.path.exists(path):
                continue
            found += 1
            shot = Image.open(path).convert("RGB")
            shot.save(os.path.join(out_dir, "%s_%s_%s.jpg" % (prefix, key, cam)), quality=82)
            at = ((index % 4) * TILE[0], (index // 4) * TILE[1])
            sheet.paste(shot.resize(TILE, Image.LANCZOS), at)
            draw.rectangle([at[0], at[1], at[0] + 70, at[1] + 22], fill=(0, 0, 0))
            draw.text((at[0] + 6, at[1] + 5), "%s %s" % (key.upper(), cam), fill=(255, 230, 120))
        if found:
            sheet.save(os.path.join(out_dir, "%s_edges_%s.jpg" % (prefix, cam)), quality=80)
            print("edge_sheet: %s_edges_%s.jpg (%d shots)" % (prefix, cam, found))


if __name__ == "__main__":
    main()
