"""Overnight Nov 8-9, Part 2: contact sheets of every image the game shows, per category, for the art audit.

    python tools/art_audit_sheets.py            -> docs/art/audit_nov9/sheets/<category>_NN.jpg + index.csv

Each tile carries its id (and the card name / rules for cards) so a reviewer can name what they flag. Icons use the master file only
(the _24/_32/... sizes are resamples), sprites one frame per character (FRONT idle), cards the full art (not the thumbs).
"""
import csv
import os
import re
import sys
from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
ART = os.path.join(ROOT, "assets", "art")
OUT = os.path.join(ROOT, "docs", "art", "audit_nov9", "sheets")
EXTS = (".webp", ".png", ".jpg")


def font(size):
    for name in ("arial.ttf", "segoeui.ttf", "DejaVuSans.ttf"):
        try:
            return ImageFont.truetype(name, size)
        except OSError:
            continue
    return ImageFont.load_default()


def card_names():
    names = {}
    folder = os.path.join(ROOT, "data", "cards")
    for path_dir, _dirs, files in os.walk(folder):
        for f in files:
            if not f.endswith(".tres"):
                continue
            text = open(os.path.join(path_dir, f), encoding="utf-8", errors="ignore").read()
            cid = re.search(r'^id = "([^"]+)"', text, re.M)
            name = re.search(r'^display_name = "([^"]+)"', text, re.M)
            rules = re.search(r'^rules_text = "([^"]*)"', text, re.M)
            if cid:
                names[cid.group(1)] = (name.group(1) if name else "", rules.group(1) if rules else "")
    return names


def files_in(folder, recursive=True):
    result = []
    base = os.path.join(ART, folder)
    for path_dir, _dirs, files in os.walk(base):
        for f in sorted(files):
            if f.lower().endswith(EXTS):
                result.append(os.path.join(path_dir, f))
        if not recursive:
            break
    return sorted(result)


def is_icon_size(path):
    return re.search(r"_(16|20|24|32|40|48|64|96|128|256)\.(webp|png|jpg)$", path) is not None


def sprite_reps():
    reps = []
    base = os.path.join(ART, "world_test", "sprites")
    for who in sorted(os.listdir(base)):
        folder = os.path.join(base, who)
        if not os.path.isdir(folder):
            continue
        frames = [f for f in sorted(os.listdir(folder)) if f.lower().endswith(EXTS)]
        if not frames:
            continue
        pick = None
        for pref in ("FRONT_IDLE", "FRONT-IDLE", "FRONT", "IDLE"):
            for f in frames:
                if pref in f.upper():
                    pick = f
                    break
            if pick:
                break
        reps.append(os.path.join(folder, pick or frames[0]))
    return reps


def categories():
    names = card_names()
    cats = {}
    cards = []
    for p in files_in("cards"):
        cid = os.path.splitext(os.path.basename(p))[0]
        name, rules = names.get(cid, ("", ""))
        cards.append((cid, p, "%s %s | %s" % (cid, name, rules[:60])))
    cats["cards"] = (cards, 300, 4, 3)
    cats["portraits"] = ([(os.path.splitext(os.path.basename(p))[0], p, "") for p in files_in("portraits")], 300, 4, 3)
    cats["characters_bestiary"] = ([(os.path.splitext(os.path.basename(p))[0], p, "") for p in files_in("characters") + files_in("bestiary")], 260, 5, 3)
    cats["sprites"] = ([(os.path.basename(os.path.dirname(p)), p, os.path.basename(p)) for p in sprite_reps()], 200, 6, 3)
    cats["keyart_stills"] = ([(os.path.splitext(os.path.basename(p))[0], p, "") for p in files_in("keyart")], 560, 3, 3)
    cats["boards_maps"] = ([(os.path.splitext(os.path.basename(p))[0], p, "") for p in files_in("battleboards") + files_in("maps")], 560, 3, 3)
    cats["ui_vendors"] = ([(os.path.splitext(os.path.basename(p))[0], p, "") for p in files_in("ui") + files_in("vendors")], 420, 4, 3)
    cats["icons"] = ([(os.path.splitext(os.path.basename(p))[0], p, "") for p in files_in("icons") if not is_icon_size(p)], 150, 8, 5)
    cats["cosmetics"] = ([(os.path.splitext(os.path.basename(p))[0], p, "") for p in files_in("cosmetics")], 200, 6, 3)
    kit = files_in("zone_kits") + files_in("env_kit") + files_in("decals")
    cats["zone_kits"] = ([(os.path.relpath(p, ART).replace("\\", "/").split("/")[1] + "/" + os.path.splitext(os.path.basename(p))[0], p, "") for p in kit], 260, 5, 3)
    tex = files_in("textures") + files_in(os.path.join("world_test", "backdrop")) + files_in(os.path.join("world_test", "sky")) \
        + files_in(os.path.join("world_test", "dec")) + files_in(os.path.join("world_test", "foliage")) + files_in(os.path.join("world_test", "tex"))
    cats["textures_backdrops"] = ([(os.path.splitext(os.path.basename(p))[0], p, "") for p in tex], 300, 4, 3)
    return cats


def checker(size):
    img = Image.new("RGB", size, (60, 60, 66))
    d = ImageDraw.Draw(img)
    step = 16
    for y in range(0, size[1], step):
        for x in range(0, size[0], step):
            if (x // step + y // step) % 2:
                d.rectangle([x, y, x + step - 1, y + step - 1], fill=(80, 80, 88))
    return img


def build(name, items, tile, cols, rows, writer):
    per = cols * rows
    label_h = 34 if tile >= 250 else 22
    f = font(13 if tile >= 250 else 11)
    pages = (len(items) + per - 1) // per
    for page in range(pages):
        chunk = items[page * per:(page + 1) * per]
        sheet = Image.new("RGB", (cols * tile, rows * (tile + label_h)), (24, 24, 28))
        d = ImageDraw.Draw(sheet)
        for i, (iid, path, extra) in enumerate(chunk):
            x = (i % cols) * tile
            y = (i // cols) * (tile + label_h)
            try:
                im = Image.open(path)
                im.load()
                w, h = im.size
                im = im.convert("RGBA")
                im.thumbnail((tile - 6, tile - 6), Image.LANCZOS)
                bg = checker((tile - 6, tile - 6))
                bg.paste(im, ((tile - 6 - im.size[0]) // 2, (tile - 6 - im.size[1]) // 2), im)
                sheet.paste(bg, (x + 3, y + 3))
                dims = "%dx%d" % (w, h)
            except Exception as e:  # noqa: BLE001
                dims = "ERR %s" % e
            text = "%s  %s" % (iid, dims)
            d.text((x + 4, y + tile), text[:int(tile / 6.5)], fill=(240, 230, 200), font=f)
            if extra:
                d.text((x + 4, y + tile + label_h // 2), extra[:int(tile / 6.0)], fill=(170, 170, 170), font=f)
            writer.writerow([name, "%s_%02d.jpg" % (name, page + 1), iid, os.path.relpath(path, ROOT).replace("\\", "/"), dims])
        sheet.save(os.path.join(OUT, "%s_%02d.jpg" % (name, page + 1)), quality=88)
    return pages


def main():
    os.makedirs(OUT, exist_ok=True)
    only = sys.argv[1:]
    with open(os.path.join(OUT, "index.csv"), "w", newline="", encoding="utf-8") as fh:
        writer = csv.writer(fh)
        writer.writerow(["category", "sheet", "id", "file", "size"])
        for name, (items, tile, cols, rows) in categories().items():
            if only and name not in only:
                continue
            pages = build(name, items, tile, cols, rows, writer)
            print("%s: %d images on %d sheets" % (name, len(items), pages))


if __name__ == "__main__":
    main()
