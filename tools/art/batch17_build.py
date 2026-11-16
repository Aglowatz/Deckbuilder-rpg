# Overnight Nov 16 (Part 5): Batch 17 - writes docs/art/batch17_nov16.csv (the same columns as batch16_nov14.csv), copies every reference
# to "G:/My Drive/Card Game Art/Batch 17 References/" as PNG numbered by item (NN_slug__NAME.png) and writes
# docs/prompts/chatgpt_batch17.md. Prepared only: nothing here is imported.
#   python tools/art/batch17_build.py [--no-drive]
import csv
import os
import sys
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
os.chdir(ROOT)
DRIVE = "G:/My Drive/Card Game Art/Batch 17 References"
ICON = "painted cozy-fantasy game icon, soft visible brushwork, warm painterly light, clean readable silhouette, transparent background, no text, "
PIECE = "painted cozy-fantasy game asset in the zone kit's style, soft visible brushwork, warm painterly light, clean readable silhouette, transparent background, no text, "
PORTRAIT = "painted cozy-fantasy character portrait, soft visible brushwork, warm painterly light, transparent background, no text, "
UI = "painted cozy-fantasy game UI asset, soft visible brushwork, warm painterly light, clean readable silhouette, transparent background, no text, "
STONE = ("a statue carved from one block of pale grey weathered stone: no skin or cloth colours anywhere, only stone, with a little moss and lichen in the folds and "
         "soft chisel marks; ")
STAND = ("STANDING: the whole figure upright on a low round stone base (the game stands it on its own square plinth, so paint no plinth), seen from the front, "
         "a little from the left, the same angle as the reference cut-out. ")
FALL = ("TOPPLED: the same statue after it was pulled down: lying on its side on the ground, broken off at the ankles and cracked into two or three large pieces, "
        "a few stone chips and a coil of rope beside it, seen from the same side (the game leaves the empty plinth standing next to it, so paint no plinth).")
STATUE_SHOT = "docs/overnight_shots/nov15/p3_statue_gainlands_after_zoom.png"
STONE_REFS = ["assets/art/zone_kits/heap/DUMP-HERO-RACCOON-STATUE.webp", "assets/art/zone_kits/final/CAPI-PROP-STATUE-FALLEN.webp"]


def statue(slug, zone_prefix, name, who, where, look, cutout, extra_refs, score):
    """One ruler statue item: two pictures (standing, toppled)."""
    base = "%s-STATUE-%s" % (zone_prefix, name)
    ids = "%s-STANDING, %s-TOPPLED" % (base, base)
    needed = PIECE + STONE + "the statue is of " + who + " (" + look + "). " + STAND + FALL
    prompt = ("**%s-STANDING** (1024x1536, transparent) and **%s-TOPPLED** (1536x1024, transparent). Two pictures of one stone statue of %s. "
              "Ref %%NN%% %s is the person: keep the pose, the costume and every prop (%s). The reference is cut off at the knees: finish the legs and feet in the same costume. Carve all of it from **one pale grey weathered stone**, "
              "like the stone statues in refs %%NN%% DUMP-HERO-RACCOON-STATUE and CAPI-PROP-STATUE-FALLEN: no skin, cloth or metal colours, only stone, a little moss and "
              "lichen in the folds, soft chisel marks. Ref %%NN%% %s shows how the game fakes this statue today (a flat picture tinted grey); yours replaces it.\n"
              "   - STANDING: the whole figure upright on a low round stone base, front view a little from the left, the same angle as the reference. No plinth: the game "
              "stands it on its own.\n"
              "   - TOPPLED: the same statue pulled down: lying on its side on the ground, broken off at the ankles and cracked into two or three large pieces, a few stone "
              "chips and a coil of rope beside it. No plinth.") % (base, base, who, os.path.splitext(os.path.basename(cutout))[0], look,
                                                                 os.path.splitext(os.path.basename(extra_refs[0] if extra_refs else STATUE_SHOT))[0])
    return (slug, "%s-STANDING / -TOPPLED" % base, where,
            "(a stand-in: the boss's painted cut-out drawn through a grey stone shader, RulerPresence)",
            "Fable Nov 15 replaced the capsule statue with the ruler's flat cut-out tinted grey. It reads as a grey photograph, not a carving; toppled, it is the same flat card lying down.",
            needed, ids, "assets/art/zone_kits/<zone>/%s-STANDING.webp, -TOPPLED.webp" % base, "1024x1536 (standing), 1536x1024 (toppled)", "PNG with transparency",
            [cutout] + (extra_refs if extra_refs else [STATUE_SHOT]) + STONE_REFS, score, prompt)


# slug, id, where, current file, problem, needed image, target ids, game file, size, format, references, score, prompt text
ROWS = [
    statue("statue_clench", "GAIN", "CLENCH", "Chancellor Clench, the Iron Regent, the ruler of the Gainlands",
           "The Gainlands' hub: the ruler's statue on its plinth while the zone is oppressed, lying beside the plinth once it is freed (every visit)",
           "a huge strongman in a regent's long coat with epaulettes and medals, chin up, curling a dumbbell in one hand, the other fist on his hip", "assets/art/portraits/CUT-CLENCH.webp",
           ["docs/overnight_shots/nov15b/p3_statue_gainlands_standing.png"], "20"),
    statue("statue_chef", "BUFF", "GRANDCHEF", "the Grand Chef, the ruler of the Endless Buffet",
           "The Endless Buffet's hub: the ruler's statue, standing or toppled (every visit)",
           "the proud chef in her towering hat and flounced apron, a ladle raised in one hand, the other hand on her hip", "assets/art/portraits/CUT-DOPPEL.webp",
           ["docs/overnight_shots/nov15b/p3_statue_buffet_standing.png"], "20"),
    statue("statue_mortimer", "DNA", "MORTIMER", "Mortimer Grimsby, the head of the Department of Necrotic Affairs (the D.N.A.)",
           "The D.N.A.'s lobby: the ruler's statue, standing or toppled (every visit)",
           "the skeleton in a pinstripe three-piece suit and tie, holding a form in both bony hands", "assets/art/portraits/CUT-MORTIMER.webp", [], "16"),
    statue("statue_compostella", "DUMP", "COMPOSTELLA", "Compostella, the Rotheart, the ruler of the Verdant Dump",
           "The Verdant Dump's hub plaza: the ruler's statue, standing or toppled (every visit)",
           "the old druid overgrown with roots and fungus, a crown of thorny branches, one hand reaching out, a gnarled staff in the other", "assets/art/portraits/CUT-ROTHEART.webp",
           ["docs/overnight_shots/nov15b/p3_statue_heap_standing.png", "assets/art/portraits/NPC-COMPOSTELLA.webp"], "20"),
    statue("statue_primm", "CAP", "PRIMM", "Primm, \"His Perfection\", the ruler of the Capital",
           "The Capital: the ruler's statue, standing until Primm falls and toppled after (every visit to the Capital)",
           "the slim, perfectly groomed ruler in his long ceremonial robes and laurel circlet, gloved hands clasped, a small fixed smile; leave his mirror out", "assets/art/portraits/CUT-PRIMM.webp",
           ["assets/art/zone_kits/final/CAPI-PROP-PRIMM-STATUE.webp"], "20"),
]

# The Part 4 critic's finds that only new art can fix, then what was still open from earlier batches.
CRITIC_ROWS = [
    ("well_icon", "ICON-NODE-WELL", "The Hollow Well's pop-up in the first cave and every later well (its banner's round picture)",
     "(none: the pop-up shows ICON-NODE-CHALLENGE, playing cards with a lightning bolt)",
     "Critic S1 (Nov 16), finding 10: the Hollow Well's header picture is not a well. The game uses ICON-NODE-WELL by itself once it is imported (NodeCard.WELL_ICON).",
     ICON + "a round dungeon-map medallion in the same style, rim and size as the attached healing-shrine icon: an old dry stone well with a mossy rim and a frayed rope, "
     "a faint blue-green glow rising out of it, on a dark cave-stone disc.",
     "ICON-NODE-WELL", "assets/art/icons/ICON-NODE-WELL.webp", "512x512", "PNG with transparency",
     ["assets/art/icons/ICON-NODE-HEAL.webp", "assets/art/icons/ICON-NODE-CHALLENGE.webp", "assets/art/icons/ICON-NODE-TREASURE.webp"], "12",
     "**ICON-NODE-WELL** (512x512, transparent). A round dungeon-map medallion in exactly the style, rim and size of ref %NN% ICON-NODE-HEAL and ICON-NODE-TREASURE: an "
     "old dry stone well with a mossy rim and a frayed rope, a faint blue-green glow rising out of it, on a dark cave-stone disc. (Ref %NN% ICON-NODE-CHALLENGE is what the "
     "game shows there today; do not copy its playing cards.)"),
    ("cardbacks", "UI-CARDBACK-R / UI-CARDBACK-G / UI-CARDBACK-C", "The back of every Refusemancer and Gourmand card, and the default back (the foe's deck and hand, pack reveals): seen in every fight",
     "assets/art/ui/UI-CARDBACK-R.webp, UI-CARDBACK-G.webp, UI-CARDBACK-C.webp",
     "Critic S2 (Nov 16), finding 6. Batch 16 fixed the Beefcake and Necrocrat backs; these three still show other symbols: R three leaves round a brass cog, G the chef's "
     "hat over a crossed ladle and whisk on dark wood, C a compass with a swirl, a leaf, a wave and a flame in its quarters.",
     ICON + "the same three card backs repainted exactly (same frames, filigree and colours), with only the centre medallions changed, in the style of the attached "
     "Beefcake back: R the green leaf inside three rust-orange recycling arrows on a moss-green disc; G the white chef's hat alone on a cream disc with a copper rim (no "
     "ladle, no whisk); C the compass star kept, with the four Path icons in its four quarters, clockwise from the top: arm, chef's hat, leaf, skull.",
     "UI-CARDBACK-R, UI-CARDBACK-G, UI-CARDBACK-C", "assets/art/ui/UI-CARDBACK-R.webp, -G.webp, -C.webp", "1024x1536 each", "PNG",
     ["assets/art/ui/UI-CARDBACK-R.webp", "assets/art/ui/UI-CARDBACK-G.webp", "assets/art/ui/UI-CARDBACK-C.webp", "assets/art/ui/UI-CARDBACK-B.webp", "docs/art/path_icon_sheet.png",
      "assets/art/icons/ICON-ENERGY-R.webp", "assets/art/icons/ICON-ENERGY-G.webp"], "20",
     "**UI-CARDBACK-R**, **UI-CARDBACK-G** and **UI-CARDBACK-C** (1024x1536 each, not transparent). Repaint refs %NN% UI-CARDBACK-R, -G and -C exactly: the same frames, "
     "filigree and colours. Only the centre medallions change, done the way ref %NN% UI-CARDBACK-B carries its icon:\n"
     "   - R: the Refusemancer Path icon (ref %NN% ICON-ENERGY-R): one green leaf inside three rust-orange recycling arrows on a moss-green disc. No cog, no ring of leaves.\n"
     "   - G: the Gourmand Path icon (ref %NN% ICON-ENERGY-G): the white chef's hat alone on a cream disc with a copper rim. No ladle, no whisk.\n"
     "   - C: keep the gold compass star; in its four quarters put the four Path icons of the sheet, small, clockwise from the top: arm, chef's hat, leaf, skull."),
    ("dump_pennants", "DUMP-SHEET-ENTRANCE-FLAGS-07 / -08", "The Verdant Dump's entrance bridge: the two pennants a player sees first in the zone",
     "assets/art/zone_kits/heap/DUMP-SHEET-ENTRANCE-FLAGS-01.webp (a single leaf: no longer used at the entrance)",
     "Critic S1 (Nov 16), finding 4: a single leaf on a pennant reads as the Path's sign and is not the Refusemancer icon. The game now hangs the two paw-print pennants there; "
     "these two would carry the real icon.",
     PIECE + "two triangular patched cloth pennants on a rope-bound stick, the same size, cut and hand-stitched look as the attached ones: 07 moss green, 08 cream, each "
     "with the Refusemancer Path icon stitched on as a round patch: a green leaf inside three rust-orange recycling arrows on a moss-green disc.",
     "DUMP-SHEET-ENTRANCE-FLAGS-07, DUMP-SHEET-ENTRANCE-FLAGS-08", "assets/art/zone_kits/heap/DUMP-SHEET-ENTRANCE-FLAGS-07.webp, -08.webp", "640x640 each", "PNG with transparency",
     ["assets/art/zone_kits/heap/DUMP-SHEET-ENTRANCE-FLAGS-01.webp", "assets/art/zone_kits/heap/DUMP-SHEET-ENTRANCE-FLAGS-05.webp", "docs/art/path_icon_sheet.png",
      "assets/art/icons/ICON-ENERGY-R.webp"], "9",
     "**DUMP-SHEET-ENTRANCE-FLAGS-07** and **DUMP-SHEET-ENTRANCE-FLAGS-08** (640x640 each, transparent). Two triangular patched cloth pennants on a rope-bound stick, the "
     "same size, cut and hand-stitched look as refs %NN% DUMP-SHEET-ENTRANCE-FLAGS-01 and -05. 07 is moss green, 08 is cream. Each carries the Refusemancer Path icon (ref "
     "%NN% ICON-ENERGY-R) as a round stitched patch: a green leaf inside three rust-orange recycling arrows on a moss-green disc. Not a single leaf, not a paw."),
    ("world_maps", "MAP-WORLD-TOWN / -GAIN / -BUFF / -DUMP / -DNA / -CAP", "The full map screen (M) of Crosspath and each zone: opened many times an hour",
     "(none: the map is drawn from the walk grid in flat blocks)",
     "Critic S1 (Nov 16), finding 6, and the art critic of Nov 12 (#17): the maps are blurry, blocky silhouettes inside an ornate painted frame, next to the cave's "
     "beautiful painted room map. Asked for in Batch 15 and not delivered. The biggest item of this batch; it can wait for its own batch.",
     "Hand-painted top-down adventure map on aged parchment, ink outlines and watercolour washes, north up, no lettering (the game draws labels and pins): the area's real "
     "layout from the attached plan screenshot - paths as dotted ink roads, buildings as small painted roofs, water in soft blue wash, trees as little ink tufts, a compass "
     "rose in one corner, the zone's palette. One image per area, the same parchment and line weight in all six.",
     "MAP-WORLD-TOWN, MAP-WORLD-GAIN, MAP-WORLD-BUFF, MAP-WORLD-DUMP, MAP-WORLD-DNA, MAP-WORLD-CAP", "assets/art/maps/MAP-WORLD-<AREA>.webp", "2048x2048 each", "PNG",
     ["docs/overnight_shots/nov16/p2_capital_map.png", "assets/art/maps/MAP-TUT.webp", "docs/art/crosspath_pass/final/plan.jpg"], "20",
     "**MAP-WORLD-TOWN**, **MAP-WORLD-GAIN**, **MAP-WORLD-BUFF**, **MAP-WORLD-DUMP**, **MAP-WORLD-DNA** and **MAP-WORLD-CAP** (2048x2048 each). Six hand-painted top-down "
     "adventure maps on aged parchment, in the style of ref %NN% MAP-TUT: ink outlines and watercolour washes, north up, **no lettering at all** (the game writes the names "
     "and pins). Paths as dotted ink roads, buildings as small painted roofs, water in a soft blue wash, trees as little ink tufts, a compass rose in one corner. The same "
     "parchment and line weight in all six. Palettes: TOWN (Crosspath) gold fields and red roofs round a fountain square with a lake to the east; GAIN sandstone and brick "
     "red; BUFF caramel and pink; DUMP moss green and violet, in terraces; DNA grey-green office blocks; CAP cream, pink and gold inside a white wall on grey waste. Ref "
     "%NN% p2_capital_map shows how blocky the game's own map is today, and ref %NN% plan is Crosspath seen from above: follow that layout for TOWN. For the other five I "
     "will send a top-down plan of each area with the request."),
]
CARRIED_ROWS = [
    ("quadzilla_cut", "CUT-QUADZILLA", "Baron Quadzilla's boss intro in the Iron Cave (the figure that slides in)",
     "(none: the intro slides his waist-up dialogue portrait in)",
     "Batch 16 gave him a dialogue portrait, which made him a speaking boss: every other speaking boss has a full-length entrance cut-out.",
     PORTRAIT + "full length, the same huge, cheerful toad Baron as his portrait, sitting on his leg-press throne with his enormous thighs, a sweaty headband and tiny "
     "dumbbell earrings, thumbs up, the whole throne in frame, same painted style and framing as the other boss cut-outs.",
     "CUT-QUADZILLA", "assets/art/portraits/CUT-QUADZILLA.webp", "1440x2160", "PNG with transparency",
     ["assets/art/portraits/NPC-QUADZILLA.webp", "assets/art/portraits/CUT-CLENCH.webp", "assets/art/bestiary/BST-BARON-QUADZILLA.webp"], "6",
     "**CUT-QUADZILLA** (1440x2160, transparent). A full-length boss entrance cut-out of Baron Quadzilla, the same character as ref %NN% NPC-QUADZILLA and "
     "BST-BARON-QUADZILLA: the huge, cheerful toad sitting on his leg-press throne, enormous thighs, a sweaty headband, tiny dumbbell earrings, thumbs up. The whole "
     "throne is in frame. The same painted style, framing and size on the canvas as ref %NN% CUT-CLENCH."),
    ("packs_old", "UI-PACK-G (redo) / UI-PACK-GILDED-B", "The Gourmand Path Pack and the Gilded Beefcake pack (the Pack Vendor, Fig Sly, the Card Packs page, pack opening)",
     "assets/art/ui/UI-PACK-G.webp; assets/art/ui/UI-PACK-GILDED.webp (still used for the Beefcake gilded pack)",
     "The last two pack paintings off the style guide. UI-PACK-G's medallion is the chef's hat on a brown disc (the guide: cream with a copper rim). The Beefcake gilded pack "
     "is the old shared painting with a dumbbell pattern in the foil. Batch 16 fixed the other five; the game still draws its own icon over these two.",
     UI + "G: the same copper-and-cream foil pack repainted exactly, with one change: the medallion shows the white chef's hat on a cream disc with a copper rim, whole and "
     "centred in the gold ring. GILDED-B: a gilded foil pack exactly like the attached gilded Gourmand pack (same shape, crimped ends, gold foil, cream centre stripe), with "
     "the Beefcake Path icon in the medallion (a gold flexed arm on a red disc in a gold rim) and a small repeating pattern of tiny flexed arms in the foil. No dumbbells.",
     "UI-PACK-G, UI-PACK-GILDED-B", "assets/art/ui/UI-PACK-G.webp, UI-PACK-GILDED-B.webp", "1024x1536 each", "PNG with transparency",
     ["assets/art/ui/UI-PACK-G.webp", "assets/art/ui/UI-PACK-GILDED-G.webp", "assets/art/ui/UI-PACK-GILDED.webp", "docs/art/path_icon_sheet.png",
      "assets/art/icons/ICON-ENERGY-B.webp", "assets/art/icons/ICON-ENERGY-G.webp"], "6",
     "**UI-PACK-G** and **UI-PACK-GILDED-B** (1024x1536 each, transparent).\n"
     "   - UI-PACK-G: repaint ref %NN% UI-PACK-G exactly, the same copper-and-cream foil pack. The only change: the medallion shows the Gourmand Path icon (ref %NN% "
     "ICON-ENERGY-G): a white chef's hat on a **cream** disc with a copper rim, whole and centred inside the gold ring.\n"
     "   - UI-PACK-GILDED-B: a gilded foil pack exactly like ref %NN% UI-PACK-GILDED-G (same shape, crimped ends, gold foil, cream centre stripe, round gold-rimmed "
     "medallion). In the medallion, the Beefcake Path icon (ref %NN% ICON-ENERGY-B): a gold flexed arm on a red disc. In the foil, a small repeating pattern of tiny "
     "flexed arms. No dumbbells anywhere (ref %NN% UI-PACK-GILDED is the old painting with the dumbbells: do not copy its pattern)."),
    ("echoes", "BST-ECHO-OF-* (7), BST-THE-PERFECT-COPY", "The Shattered Gallery's eight foes (postgame): Bestiary page and the battle portrait",
     "(missing: the Bestiary shows an icon; the boss shows the castle board's cut-out)",
     "Carried over: asked for in Batch 15 and not delivered. Eight Bestiary pictures are missing (the only ones left: 99 of 107 are in).",
     "Bestiary portrait in the existing BST style (bust, three-quarter, painterly, soft dark vignette): the named character as a MIRROR ECHO - the same face and costume as "
     "their own portrait but made of silvered glass, hairline cracks across one cheek, cold blue rim light, eyes blank and reflective, shards drifting off one shoulder. "
     "THE PERFECT COPY: the hooded Wanderer as a flawless silver reflection with no cracks at all and a faint gold halo.",
     "BST-ECHO-OF-CHANCELLOR-CLENCH, BST-ECHO-OF-HORTENSIA-CLIPWELL, BST-ECHO-OF-MORTIMER-GRIMSBY, BST-ECHO-OF-PERCIVAL-PLUME, BST-ECHO-OF-THE-DOPPELGANGER, "
     "BST-ECHO-OF-THE-ROTHEART, BST-ECHO-OF-VIVIENNE-QUOTA, BST-THE-PERFECT-COPY", "assets/art/bestiary/<ID>.webp", "1024x1024 each", "PNG",
     ["assets/art/portraits/NPC-CLENCH.webp", "assets/art/portraits/NPC-CLIPWELL.webp", "assets/art/portraits/NPC-MORTIMER.webp", "assets/art/portraits/NPC-PLUME.webp",
      "assets/art/portraits/NPC-DOPPEL.webp", "assets/art/portraits/NPC-ROTHEART.webp", "assets/art/portraits/NPC-QUOTA.webp", "assets/art/portraits/NPC-PLAYER.webp",
      "assets/art/bestiary/BST-ENFORCER-SERGEANT-SCUFF.webp"], "10",
     "**BST-ECHO-OF-CHANCELLOR-CLENCH**, **BST-ECHO-OF-HORTENSIA-CLIPWELL**, **BST-ECHO-OF-MORTIMER-GRIMSBY**, **BST-ECHO-OF-PERCIVAL-PLUME**, "
     "**BST-ECHO-OF-THE-DOPPELGANGER**, **BST-ECHO-OF-THE-ROTHEART**, **BST-ECHO-OF-VIVIENNE-QUOTA** and **BST-THE-PERFECT-COPY** (1024x1024 each, a painted background, "
     "not transparent). Eight square Bestiary pictures in the style of ref %NN% BST-ENFORCER-SERGEANT-SCUFF (head and shoulders, three-quarter view, a soft dark vignette). "
     "Each ECHO is the character of its own reference portrait (refs %NN% NPC-CLENCH, NPC-CLIPWELL, NPC-MORTIMER, NPC-PLUME, NPC-DOPPEL, NPC-ROTHEART, NPC-QUOTA) as a "
     "**mirror echo**: the same face and costume made of silvered glass, hairline cracks across one cheek, cold blue rim light, blank reflective eyes, shards drifting off "
     "one shoulder, a dark hall of mirrors behind. THE PERFECT COPY is the hooded hero of ref %NN% NPC-PLAYER as a flawless silver reflection: no cracks at all, a faint "
     "gold halo."),
]

HEAD = ["id", "where it is used", "current file", "problem", "needed image (existing style)", "target id(s)", "game file", "size", "format", "status", "references to attach", "severity x visibility"]


def ref_name(number, slug, path):
    return "%02d_%s__%s.png" % (number, slug, os.path.splitext(os.path.basename(path))[0])


def main():
    drive = "--no-drive" not in sys.argv
    if drive:
        os.makedirs(DRIVE, exist_ok=True)
    all_rows = ROWS + CRITIC_ROWS + CARRIED_ROWS
    rows = []
    copied = 0
    missing = []
    images = 0
    for number, row in enumerate(all_rows, 1):
        slug, idn, where, current, problem, needed, targets, game_file, size, fmt, refs, score, _prompt = row
        names = []
        for ref in refs:
            if not os.path.exists(ref):
                missing.append("%02d %s" % (number, ref))
                continue
            name = ref_name(number, slug, ref)
            names.append(name)
            if drive:
                Image.open(ref).convert("RGBA").save(os.path.join(DRIVE, name))
                copied += 1
        images += len([t for t in targets.split(",") if t.strip()])
        rows.append([idn, where, current, problem, needed, targets, game_file, size, fmt, "To make (Batch 17)", "; ".join(refs) + "  ->  " + ", ".join(names), score])
    with open("docs/art/batch17_nov16.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f, quoting=csv.QUOTE_ALL)
        w.writerow(HEAD)
        w.writerows(rows)
    lines = [
        "Batch 17 for my cozy-fantasy deckbuilder RPG \"The Wayward Path\". Make all %d items below (%d images in all), one at a time, without stopping to ask me questions. Save each one as a PNG named exactly as given in **bold**." % (len(all_rows), images),
        "",
        "I've attached reference images. Each reference's filename starts with the item number it belongs to (for example, 04_statue_compostella__... is for item 4).",
        "",
        "House style for everything: painted cozy-fantasy game art, soft visible brushwork, warm painterly light, clean readable silhouettes, matching the attached references. Family friendly. No text, letters or numbers anywhere, unless an item says otherwise. \"Transparent\" means a real transparent background with no checkerboard, no shadow box and no border.",
        "",
        "**The four Path icons** (only where an item names one). Paint them exactly as in the attached sheet and never swap in another symbol:",
        "- **Beefcake:** a gold flexed arm on a red disc in a gold rim. Never a dumbbell or a flame.",
        "- **Gourmand:** a white chef's hat on a cream disc in a copper rim. Never a ladle, a fork or a drop.",
        "- **Refusemancer:** a green leaf inside three rust-orange recycling arrows on a moss-green disc. Never a single maple leaf or a sprout in a tin.",
        "- **Necrocrat:** a pale skull facing front, wrapped in green ghost-flame, on a dark slate disc. Never a stamp, a moon or a quill.",
        "",
        "\"Repaint exactly\" means: keep everything in the reference as it is and change only what the item names.",
        "",
        "**Items 1 to 5 are one set:** five stone statues, each as two pictures (standing and toppled). All ten must look carved by the same hand from the same pale grey stone, at the same scale on the canvas.",
        "",
    ]
    for number, row in enumerate(all_rows, 1):
        lines.append("%d. %s" % (number, row[12].replace("%NN%", "%02d" % number)))
    with open("docs/prompts/chatgpt_batch17.md", "w", newline="\n", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")
    print("rows", len(rows), "images", images, "references copied", copied, "missing", missing)


main()
