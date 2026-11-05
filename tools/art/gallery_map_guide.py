"""Overnight Nov 4-5, Part 5: the node-position guide for the Shattered Gallery map (MAP-S-GALLERY), like deck_station_slots_guide.png.

Draws The Shattered Gallery's nodes (data/dungeons/postgame_dungeons.json, x / y in percent of the map) and the paths between them on a plain
background at the dungeon-map resolution (1536 x 1024, 3:2, MapArt.MAX_WIDTH / RATIO), with each node's number, kind and name, and the three
wings shaded, so the painted map can put a platform under every spot. Writes docs/art/paintover_inputs/gallery_map_guide.png.

    python tools/art/gallery_map_guide.py
"""
import json
import os

from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
OUT = os.path.join(ROOT, "docs", "art", "paintover_inputs", "gallery_map_guide.png")
W, H = 1536, 1024
KIND_COLOURS = {
    "start": (120, 200, 255), "battle": (230, 230, 240), "elite": (255, 170, 60), "boss": (255, 80, 110), "event": (150, 255, 170),
}
WINGS = [  # (label, node numbers, colour)
    ("Iron wing (2-4)", [2, 3, 4], (255, 140, 120, 40)),
    ("Order wing (5-8)", [5, 6, 7, 8], (180, 140, 255, 40)),
    ("Appetite wing (9-12)", [9, 10, 11, 12], (120, 220, 160, 40)),
    ("The mirror room (13)", [13], (255, 255, 255, 40)),
]


def font(size: int) -> ImageFont.FreeTypeFont:
    for name in ("arialbd.ttf", "arial.ttf", "ARIALNB.TTF"):
        path = os.path.join("C:/Windows/Fonts", name)
        if os.path.exists(path):
            return ImageFont.truetype(path, size)
    return ImageFont.load_default()


def main() -> None:
    with open(os.path.join(ROOT, "data", "dungeons", "postgame_dungeons.json"), encoding="utf-8") as handle:
        gallery = next(d for d in json.load(handle) if d["id"] == "S-GALLERY")
    nodes = {n["n"]: n for n in gallery["nodes"]}
    at = {n: (nodes[n]["x"] / 100.0 * W, nodes[n]["y"] / 100.0 * H) for n in nodes}
    image = Image.new("RGBA", (W, H), (34, 36, 46, 255))
    shade = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    draw_shade = ImageDraw.Draw(shade)
    for label, members, colour in WINGS:
        xs = [at[n][0] for n in members]
        ys = [at[n][1] for n in members]
        box = (min(xs) - 90, min(ys) - 80, max(xs) + 90, max(ys) + 80)
        draw_shade.rounded_rectangle(box, radius=40, fill=colour, outline=colour[:3] + (140,), width=3)
        draw_shade.text((box[0] + 14, box[1] + 8), label, fill=colour[:3] + (230,), font=font(22))
    image = Image.alpha_composite(image, shade)
    draw = ImageDraw.Draw(image)
    for n, node in nodes.items():
        for nxt in node["next"]:
            draw.line([at[n], at[nxt]], fill=(200, 210, 230), width=6)
    for n, node in nodes.items():
        x, y = at[n]
        radius = 46 if node["type"] == "boss" else 34
        draw.ellipse((x - radius, y - radius, x + radius, y + radius), fill=(20, 22, 30), outline=KIND_COLOURS.get(node["type"], (255, 255, 255)), width=6)
        draw.text((x, y), str(n), fill=(255, 255, 255), font=font(30), anchor="mm")
        caption = "%s - %s" % (node["type"].upper(), node["name"])
        draw.text((x, y + radius + 18), caption, fill=(255, 255, 255), font=font(20), anchor="mm", stroke_width=3, stroke_fill=(10, 10, 14))
    draw.text((24, H - 40), "MAP-S-GALLERY node guide: 1536 x 1024 (3:2). Paint a platform under every circle; the lines are the walkways. Node 8 is the optional rest.", fill=(230, 230, 240), font=font(20))
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    image.convert("RGB").save(OUT)
    print("wrote", OUT)


if __name__ == "__main__":
    main()
