# Fable Nov 14 (Part 6): Batch 16 - writes docs/art/batch16_nov14.csv (the same columns as batch15_nov12.csv), copies every reference to
# "G:/My Drive/Card Game Art/Batch 16 References/" as PNG numbered by row (NN_slug__NAME.png) and writes docs/prompts/chatgpt_batch16.md.
#   python tools/art/batch16_build.py [--no-drive]
import csv
import os
import sys
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
os.chdir(ROOT)
DRIVE = "G:/My Drive/Card Game Art/Batch 16 References"
ICON = "painted cozy-fantasy game icon, soft visible brushwork, warm painterly light, clean readable silhouette, transparent background, no text, "
PIECE = "painted cozy-fantasy game asset in the zone kit's style, soft visible brushwork, warm painterly light, clean readable silhouette, transparent background, no text, "
STILL = "painted cozy-fantasy story illustration, soft visible brushwork, warm painterly light, no text, "
PORTRAIT = "painted cozy-fantasy character portrait, soft visible brushwork, warm painterly light, transparent background, waist up, three-quarter view, no text, "
FOUR = ("the four Path icons of the attached sheet: a gold flexed arm on a red disc (Beefcake), a white chef's hat on a cream disc with a copper rim (Gourmand), "
        "a green leaf inside three rust-orange recycling arrows on a moss-green disc (Refusemancer), and a pale skull wrapped in green ghost-flame on a dark slate disc (Necrocrat)")
RING = FOUR + ", arranged in a ring, clockwise from the top: arm, chef's hat, leaf, skull"
SHEET = "docs/art/path_icon_sheet.png"
IC = "assets/art/icons/ICON-ENERGY-%s.webp"
ALL_ICONS = [SHEET, IC % "B", IC % "G", IC % "R", IC % "N"]

# slug, id, where, current file, problem, needed image, target ids, game file, size, format, references, score, prompt text
ROWS = [
    ("figsly", "V-FIGSLY (redo)", "Fig Sly's dialogue and shop portrait (the Crease's Black Market: a main quest sends every player to him)",
     "assets/art/portraits/V-FIGSLY.webp", "The Batch 15 repaint still has two right hands (one at his lips, one on the lapel).",
     PORTRAIT + "the same stoat card dealer in the feathered hat, repainted exactly (face, outfit, colours, framing, style) with exactly one right arm and hand and one left arm and hand: his right hand (on the viewer's left) is raised with one finger to his lips; his left hand (on the viewer's right) holds his coat open by the lapel. Both hands are clearly visible and attached to their own arm; no hidden hand, no extra hand.",
     "V-FIGSLY", "assets/art/portraits/V-FIGSLY.webp", "1024x1536", "PNG with transparency", ["assets/art/portraits/V-FIGSLY.webp"], "25",
     "**V-FIGSLY** (1024x1536, transparent). Repaint ref 01 exactly: the same stoat card dealer in the feathered hat, the same face, outfit, colours, framing and painted style. The one thing to fix is his hands. He has exactly **one right arm and hand and one left arm and hand**:\n   - his right hand (on the viewer's left) is raised with one finger to his lips;\n   - his left hand (on the viewer's right) holds his coat open by the lapel.\n\n   Both hands are clearly visible and each is attached to its own arm. No hidden hand, no extra hand, no hand coming from behind the coat. Count the hands before you finish: two."),
    ("memory4", "STORY-MEMORY-4 (the picture after the fourth Path is freed)", "Fragment 4, \"A Name\": the still behind the fourth memory (once per run, the story's reveal)",
     "assets/art/keyart/STORY-MEMORY-4.webp", "The crest on the arch above the King is a ring of a star, a flame, a leaf and a moon. They must be the four real Path icons.",
     STILL + "the same picture repainted exactly as it is (the courtyard, the kneeling young man, the tortoise, the King and Queen on the steps, the light), with one change: the four symbols in the ring on the arch above the King become " + RING + ". Everything else stays exactly as it is.",
     "STORY-MEMORY-4", "assets/art/keyart/STORY-MEMORY-4.webp", "1792x1008", "PNG", ["assets/art/keyart/STORY-MEMORY-4.webp"] + ALL_ICONS, "25",
     "**STORY-MEMORY-4** (1792x1008). Repaint ref 02 STORY-MEMORY-4 exactly as it is: the same courtyard, people, composition, light and style. The only change: the four symbols in the ring on the arch above the King become the four Path icons of the attached icon sheet (ref 02 path_icon_sheet and the four icon files), in a ring, clockwise from the top: the gold flexed arm on red, the white chef's hat on cream and copper, the green leaf in three rust arrows, the pale skull in green flame. Carved and painted on the stone like the old ones. Everything else stays exactly as it is."),
    ("memory3", "STORY-MEMORY-3", "Fragment 3, \"The Coup\": the still behind the third memory (once per run)",
     "assets/art/keyart/STORY-MEMORY-3.webp", "The banners behind the King and the embroidery on his robe show a star, a moon, a leaf and a flame, not the Path icons.",
     STILL + "the same picture repainted exactly as it is, with one change: the devices on the four banners behind the King (and the small ones on his robe) become " + FOUR + ", one per banner, each on its own Path's colour.",
     "STORY-MEMORY-3", "assets/art/keyart/STORY-MEMORY-3.webp", "1792x1008", "PNG", ["assets/art/keyart/STORY-MEMORY-3.webp"] + ALL_ICONS, "16",
     "**STORY-MEMORY-3** (1792x1008). Repaint ref 03 STORY-MEMORY-3 exactly as it is: the same throne room, people, composition, light and style. The only change: the devices on the banners behind the King, and the small embroidered ones on his robe, become the four Path icons of the icon sheet (ref 03): the gold flexed arm on a red banner, the white chef's hat on a copper banner, the green leaf in three arrows on a moss-green banner, the pale skull in green flame on a slate banner."),
    ("scuff", "NPC-SCUFF / CUT-SCUFF / BST-ENFORCER-SERGEANT-SCUFF", "Enforcer Sergeant Scuff, the Old Service Tunnels' boss: dialogue portrait, boss-intro cut-out, Bestiary square",
     "(stand-ins: the Correction Officer's talk frame and BST-CORRECTION-OFFICER)", "New character (Fable Nov 14): one of Captain Spotless's officers, sent below to sweep the tunnels. He borrows the Correction Officer's art.",
     PORTRAIT + "a young, earnest Enforcer sergeant of the Capital's regime in Captain Spotless's white-and-gold uniform, but plainly a junior officer: a plain helmet with no plume, one small chevron, a lantern on his belt, an orders card in one hand, an apologetic, worried face. His boots and the hem of his trousers are muddy (the only dirty boots in the regime). Human. The cut-out is the same man full length; the Bestiary square is his head and shoulders in a brick tunnel with a grate of light above.",
     "NPC-SCUFF, CUT-SCUFF, BST-ENFORCER-SERGEANT-SCUFF", "assets/art/portraits/NPC-SCUFF.webp, CUT-SCUFF.webp; assets/art/bestiary/BST-ENFORCER-SERGEANT-SCUFF.webp", "1024x1536 (portrait), 1440x2160 (cut-out), 1024x1024 (square)", "PNG with transparency (the square: PNG)",
     ["assets/art/portraits/NPC-SPOTLESS.webp", "assets/art/portraits/CUT-SPOTLESS.webp", "assets/art/bestiary/BST-CORRECTION-OFFICER.webp"], "20",
     "**NPC-SCUFF** (1024x1536, transparent), **CUT-SCUFF** (1440x2160, transparent) and **BST-ENFORCER-SERGEANT-SCUFF** (1024x1024). A new character: Enforcer Sergeant Scuff, a junior officer under Captain Spotless (ref 04 NPC-SPOTLESS and CUT-SPOTLESS show the Captain and the regime's uniform; ref 04 BST-CORRECTION-OFFICER shows an ordinary officer).\n   - A young, earnest human man in the same white-and-gold Enforcer uniform, but clearly junior: a plain helmet with no plume, a single small chevron, a lantern on his belt, a card of written orders in one hand (no readable letters). An apologetic, worried face. His boots and trouser hems are muddy.\n   - NPC-SCUFF: waist up, three-quarter view, like the Captain's portrait.\n   - CUT-SCUFF: the same man full length, standing to attention in a puddle, same framing as the Captain's cut-out.\n   - BST-ENFORCER-SERGEANT-SCUFF: a square head-and-shoulders picture of him in a brick service tunnel, with light falling through a grate above. This one has a painted background."),
    ("cardback_b", "UI-CARDBACK-B", "The back of every Beefcake card (decks, the Refuse Pile, Dex's Beefcake table)",
     "assets/art/ui/UI-CARDBACK-B.webp", "The centre medallion shows a dumbbell. A Path is shown by its icon: the flexed arm.",
     ICON + "the same card back repainted exactly (red and gold, the same frame and filigree), with the centre medallion changed from a dumbbell to the Beefcake Path icon: a gold flexed arm on a red disc in a gold rim.",
     "UI-CARDBACK-B", "assets/art/ui/UI-CARDBACK-B.webp", "1024x1536", "PNG", ["assets/art/ui/UI-CARDBACK-B.webp", SHEET, IC % "B"], "16",
     "**UI-CARDBACK-B** (1024x1536). Repaint ref 05 UI-CARDBACK-B exactly: the same red-and-gold card back, frame and filigree. The only change: the dumbbell in the centre medallion becomes the Beefcake Path icon (ref 05 ICON-ENERGY-B): a gold flexed arm on a red disc in a gold rim."),
    ("cardback_n", "UI-CARDBACK-N", "The back of every Necrocrat card",
     "assets/art/ui/UI-CARDBACK-N.webp", "The centre medallion shows a skull with a quill; the Path icon is the skull in green ghost-flame.",
     ICON + "the same card back repainted exactly (green and gold, the same frame), with the centre medallion changed to the Necrocrat Path icon: a pale skull facing front wrapped in green ghost-flame on a dark slate disc. No quill.",
     "UI-CARDBACK-N", "assets/art/ui/UI-CARDBACK-N.webp", "1024x1536", "PNG", ["assets/art/ui/UI-CARDBACK-N.webp", SHEET, IC % "N"], "9",
     "**UI-CARDBACK-N** (1024x1536). Repaint ref 06 UI-CARDBACK-N exactly: the same green-and-gold card back and frame. The only change: the centre medallion becomes the Necrocrat Path icon (ref 06 ICON-ENERGY-N): a pale skull facing front, wrapped in green ghost-flame, on a dark slate disc. No quill."),
    ("featpaths", "ICON-FEAT-PATHS", "Feats: the badge of the four-Path feat groups (unused in the game until this redo)",
     "assets/art/icons/ICON-FEAT-PATHS.webp", "A shield with a dumbbell, a leaf, a ladle and a stamp: none is a Path icon.",
     ICON + "the same hexagonal bronze feat badge, with the four devices on it changed to " + FOUR + ", two above and two below.",
     "ICON-FEAT-PATHS", "assets/art/icons/ICON-FEAT-PATHS.webp", "512x512", "PNG with transparency", ["assets/art/icons/ICON-FEAT-PATHS.webp", "assets/art/icons/ICON-FEAT-STORY.webp"] + ALL_ICONS, "6",
     "**ICON-FEAT-PATHS** (512x512, transparent). Repaint ref 07 ICON-FEAT-PATHS: the same hexagonal bronze feat badge in the same style as ref 07 ICON-FEAT-STORY. The four devices on it become the four Path icons of the icon sheet: the gold flexed arm and the white chef's hat above, the green leaf in three arrows and the pale skull in green flame below."),
    ("plinths", "DEC-PLINTH-BEEF / -GOUR / -REF / -NECRO", "Crosspath's square: the statue that appears on each crest plinth when its zone is freed (seen every visit to town)",
     "assets/art/zone_kits/town/DEC-PLINTH-*.webp", "The statues carry a dumbbell, a cloche, a sprout in a tin and a book with a quill. Each should carry its Path's icon.",
     PIECE + "four small stone-and-bronze statues on the same square stone plinth, the same size and outline as the current ones, each holding up its Path's icon as a painted medallion: BEEF a gold flexed arm on red; GOUR a white chef's hat on cream and copper; REF a green leaf in three rust arrows on moss green; NECRO a pale skull in green flame on slate.",
     "DEC-PLINTH-BEEF, DEC-PLINTH-GOUR, DEC-PLINTH-REF, DEC-PLINTH-NECRO", "assets/art/zone_kits/town/DEC-PLINTH-BEEF.webp, -GOUR, -REF, -NECRO", "768x1088 each", "PNG with transparency",
     ["assets/art/zone_kits/town/DEC-PLINTH-BEEF.webp", "assets/art/zone_kits/town/DEC-PLINTH-GOUR.webp"] + ALL_ICONS, "20",
     "**DEC-PLINTH-BEEF**, **DEC-PLINTH-GOUR**, **DEC-PLINTH-REF** and **DEC-PLINTH-NECRO** (768x1088 each, transparent, front three-quarter view). Four small statues on the same square stone plinth as ref 08 (same plinth, same size, same outline, so they swap in). On each, a bronze hand or stand holds up that Path's icon as a painted medallion (icon sheet, ref 08):\n   - BEEF: the gold flexed arm on a red disc;\n   - GOUR: the white chef's hat on a cream disc with a copper rim;\n   - REF: the green leaf inside three rust-orange arrows on a moss-green disc;\n   - NECRO: the pale skull in green ghost-flame on a slate disc."),
    ("townbanners", "TOWN-SHEET-FREED-BANNERS-01 to -04", "Crosspath: the banner hung for each freed zone (the square and the roads)",
     "assets/art/zone_kits/town/TOWN-SHEET-FREED-BANNERS-01..04.webp", "The banners show a dumbbell, a ladle, a stamp and a maple leaf.",
     PIECE + "four hanging cloth banners on a wooden rod, the same size and cut as the current ones, hand-stitched, each with its Path's icon as the device: 01 red with the gold flexed arm; 02 copper with the white chef's hat; 03 slate grey-green with the pale skull in green flame; 04 moss green with the leaf in three rust arrows.",
     "TOWN-SHEET-FREED-BANNERS-01, -02, -03, -04", "assets/art/zone_kits/town/TOWN-SHEET-FREED-BANNERS-01.webp to -04.webp", "640x640 each", "PNG with transparency",
     ["assets/art/zone_kits/town/TOWN-SHEET-FREED-BANNERS-01.webp", "assets/art/zone_kits/town/TOWN-SHEET-FREED-BANNERS-03.webp"] + ALL_ICONS, "16",
     "**TOWN-SHEET-FREED-BANNERS-01**, **-02**, **-03** and **-04** (640x640 each, transparent). Four hanging cloth banners on a wooden rod, the same size, cut and hand-stitched look as ref 09. Each carries its Path's icon from the icon sheet as its device:\n   - 01: brick red, the gold flexed arm;\n   - 02: warm copper, the white chef's hat;\n   - 03: dark slate green, the pale skull in green ghost-flame;\n   - 04: moss green, the green leaf inside three rust-orange arrows."),
    ("townbanners4", "TOWN-SHEET-FREED-BANNERS-05 / -06", "Crosspath: the four-Path banners that go up when all four zones are free",
     "assets/art/zone_kits/town/TOWN-SHEET-FREED-BANNERS-05.webp, -06.webp", "The ring on the banner is a sun, a leaf, a moon and a drop.",
     PIECE + "the same cream banner on a wooden rod, with the ring's four devices changed to " + RING + ".",
     "TOWN-SHEET-FREED-BANNERS-05, -06", "assets/art/zone_kits/town/TOWN-SHEET-FREED-BANNERS-05.webp, -06.webp", "640x640 each", "PNG with transparency",
     ["assets/art/zone_kits/town/TOWN-SHEET-FREED-BANNERS-05.webp"] + ALL_ICONS, "12",
     "**TOWN-SHEET-FREED-BANNERS-05** and **-06** (640x640 each, transparent). Repaint ref 10 exactly: the same cream banner on a wooden rod with a ring of four devices. The four devices become the four Path icons in a ring, clockwise from the top: arm, chef's hat, leaf, skull. -06 is the same banner with a slightly more weathered cloth."),
    ("capbanners", "CAP-BANNER-FREED-03 / -04", "The freed Capital: the banners down the avenue and over Primm's emblem",
     "assets/art/zone_kits/final/CAP-BANNER-FREED-03.webp, -04.webp", "-03 shows a leaf swirl and -04 a stamp in laurels (Batch 15 asked for those). -01 (the arm) and -02 (the chef's hat) are right.",
     PIECE + "the same two swallow-tailed banners, same size and hem as -01 and -02: 03 moss green with the green leaf in three rust arrows; 04 dark slate teal with the pale skull in green flame.",
     "CAP-BANNER-FREED-03, CAP-BANNER-FREED-04", "assets/art/zone_kits/final/CAP-BANNER-FREED-03.webp, -04.webp", "384x768 each", "PNG with transparency",
     ["assets/art/zone_kits/final/CAP-BANNER-FREED-01.webp", "assets/art/zone_kits/final/CAP-BANNER-FREED-03.webp", "assets/art/zone_kits/final/CAP-BANNER-FREED-04.webp", SHEET, IC % "R", IC % "N"], "12",
     "**CAP-BANNER-FREED-03** and **CAP-BANNER-FREED-04** (384x768 each, transparent). The same swallow-tailed, hand-stitched banners as ref 11 (same size and hem as CAP-BANNER-FREED-01, so they hang in a row). Only the emblems change:\n   - 03: moss green, with the green leaf inside three rust-orange arrows;\n   - 04: dark slate teal, with the pale skull in green ghost-flame."),
    ("reunion", "STORY-REUNION", "The ending: the four leaders meet in the plaza (once per run, full screen)",
     "assets/art/keyart/STORY-REUNION.webp", "The banners in the crowd show a sun, a crescent and other devices.",
     STILL + "the same picture repainted exactly as it is, with one change: every banner in the crowd carries one of " + FOUR + ".",
     "STORY-REUNION", "assets/art/keyart/STORY-REUNION.webp", "1792x1008", "PNG", ["assets/art/keyart/STORY-REUNION.webp"] + ALL_ICONS, "12",
     "**STORY-REUNION** (1792x1008). Repaint ref 12 STORY-REUNION exactly as it is: the same four leaders, crowd, composition, light and style. The only change: every banner in the crowd carries one of the four Path icons (the arm on red, the chef's hat on copper, the leaf in arrows on green, the skull in green flame on slate) and no other device."),
    ("filecomplete", "STORY-EPI-FILE-COMPLETE", "The ending: Agnes stamps HEIR: ALIVE (once per run)",
     "assets/art/keyart/STORY-EPI-FILE-COMPLETE.webp", "The banners behind the crowd show a hammer, a book and a laurel (small in frame).",
     STILL + "the same picture repainted exactly as it is, the stamped form's words kept, with one change: the banners behind the crowd carry the four Path icons.",
     "STORY-EPI-FILE-COMPLETE", "assets/art/keyart/STORY-EPI-FILE-COMPLETE.webp", "1792x1008", "PNG", ["assets/art/keyart/STORY-EPI-FILE-COMPLETE.webp"] + ALL_ICONS, "6",
     "**STORY-EPI-FILE-COMPLETE** (1792x1008). Repaint ref 13 exactly as it is, including the words on the stamped form (HEIR: ALIVE / FILE COMPLETE: this is the one item where text stays). The only change: the banners behind the crowd carry the four Path icons and no other device."),
    ("logo", "LOGO-EMBLEM / APP-ICON", "The title screen's emblem, the window and exe icon, the itch page",
     "assets/art/keyart/LOGO-EMBLEM.webp, APP-ICON.webp", "The four roundels show a dumbbell, a chef's hat, a sprout in a tin and a skull with a quill. Only the chef's hat is a Path icon.",
     ICON + "the same gold crossroads emblem on midnight blue, repainted exactly, with the four roundels changed to the four Path icons: top the gold flexed arm on red, right the white chef's hat, bottom the green leaf in three arrows, left the pale skull in green flame. APP-ICON is the same emblem on its rounded blue square.",
     "LOGO-EMBLEM, APP-ICON", "assets/art/keyart/LOGO-EMBLEM.webp, APP-ICON.webp", "1254x1254 each", "PNG with transparency (APP-ICON: PNG)",
     ["assets/art/keyart/LOGO-EMBLEM.webp", "assets/art/keyart/APP-ICON.webp"] + ALL_ICONS, "20",
     "**LOGO-EMBLEM** (1254x1254, transparent) and **APP-ICON** (1254x1254). Repaint ref 14 exactly: the same gold crossroads emblem on midnight blue. The only change is the four roundels, which become the four Path icons, clockwise from the top: the gold flexed arm on red, the white chef's hat on cream, the green leaf in three rust arrows, the pale skull in green flame. APP-ICON is the same emblem on its rounded blue square, as in ref 14 APP-ICON."),
    ("wordmark", "LOGO-WORDMARK", "The title screen and the credits: the game's name",
     "assets/art/keyart/LOGO-WORDMARK.webp", "The four small roundels under the words show a dumbbell, a skull with a quill, a chef's hat and a sprout in a tin.",
     ICON + "the same wordmark repainted exactly, the lettering unchanged, with the four roundels under it changed to the four Path icons in the order arm, chef's hat, leaf, skull.",
     "LOGO-WORDMARK", "assets/art/keyart/LOGO-WORDMARK.webp", "1280x640", "PNG with transparency", ["assets/art/keyart/LOGO-WORDMARK.webp"] + ALL_ICONS, "16",
     "**LOGO-WORDMARK** (1280x640, transparent). Repaint ref 15 exactly, keeping the lettering \"THE WAYWARD PATH\" exactly as it is (this item keeps its text). The only change: the four small roundels under the words become the four Path icons, left to right: arm, chef's hat, leaf, skull."),
    ("stones", "TOWN-PROP-SHORE-STONES-01 / -02 / -03", "Crosspath's lake shore (and any bank in the hub): the stones along the water",
     "(none: rounded stones modelled in code with the rock texture)", "Fable Nov 14 replaced the faceted grey blobs with rounded stones in code; Crosspath has no painted rock prop, and a painted one would match the painted trees and reeds beside it.",
     PIECE + "three small groups of smooth river stones for a grassy lake bank, warm grey-brown with moss on top and a darker wet line at the base, a tuft of grass or a reed at one side: 01 one large stone with two pebbles; 02 three medium stones; 03 a low flat stone half sunk. Soft dark base so they sit on grass.",
     "TOWN-PROP-SHORE-STONES-01, -02, -03", "assets/art/zone_kits/town/TOWN-PROP-SHORE-STONES-01.webp to -03.webp", "512x384 each", "PNG with transparency",
     ["docs/overnight_shots/nov14/p3_shore_a_after.png", "assets/art/env_kit/ENV-TREE-OAK.webp"], "9",
     "**TOWN-PROP-SHORE-STONES-01**, **-02** and **-03** (512x384 each, transparent, front view from slightly above). Small groups of smooth river stones for the grassy lake bank in ref 16 (the screenshot shows where they go; the oak shows the village's painted style). Warm grey-brown stone, moss on top, a darker wet line at the base, a soft dark base so they sit on grass.\n   - 01: one large stone with two pebbles and a tuft of grass;\n   - 02: three medium stones in a row;\n   - 03: one low flat stone half sunk, with a reed beside it."),
    ("crease", "CAP-PROP-CREASE-STALL-01 / -02, CAP-PROP-CREASE-CRATES", "The Crease (the resistance hideout): Fig Sly's stall, the second stall beside it and the crate stacks round them",
     "(none: flat stand-in boxes)", "Batch 15's critic (#4): flat stand-in shapes round Fig Sly, beside painted people. A main quest sends every player here.",
     PIECE + "underground black-market furniture for a warm cellar hideout lit by lanterns: 01 a ramshackle stall of mismatched planks with a patched plum awning, shelves of card boxes and odd bottles, a lantern; 02 a second, plainer stall with a green awning and crates of supplies; CRATES a neat stack of three wooden crates with rope handles and a faded stencilled wrinkle mark (a small curved line, no letters).",
     "CAP-PROP-CREASE-STALL-01, CAP-PROP-CREASE-STALL-02, CAP-PROP-CREASE-CRATES", "assets/art/zone_kits/final/CAP-PROP-CREASE-STALL-01.webp, -02.webp, CAP-PROP-CREASE-CRATES.webp", "768x768 (stalls), 512x512 (crates)", "PNG with transparency",
     ["docs/overnight_shots/nov14/p2_crease_crate_after.png", "assets/art/zone_kits/buffet/BUFF-PROP-STALL-01.webp", "assets/art/portraits/V-FIGSLY.webp"], "16",
     "**CAP-PROP-CREASE-STALL-01**, **CAP-PROP-CREASE-STALL-02** (768x768 each) and **CAP-PROP-CREASE-CRATES** (512x512), all transparent, front three-quarter view. Furniture for the resistance's underground hideout, a warm cellar lit by lanterns (ref 17 screenshot shows the room and the flat boxes these replace; ref 17 BUFF-PROP-STALL shows the format of a stall; ref 17 V-FIGSLY is the dealer who stands at stall 01).\n   - STALL-01: a ramshackle stall of mismatched planks with a patched plum awning, shelves of card boxes and odd bottles, a hanging lantern;\n   - STALL-02: a plainer stall with a faded green awning and open crates of supplies;\n   - CRATES: a neat stack of three wooden crates with rope handles and a small curved wrinkle mark painted on one (no letters)."),
    ("rescuerwalk", "SPR-RESCUER-FRONT_WALK / -FRONTSIDE_WALK / -SIDE_WALK / -BACKSIDE_WALK / -BACK_WALK", "The Rescuer (Elowen in her disguise) walking away: the intro and the cave mouth after each freed zone",
     "(none: she walks in Elowen's undisguised frames)", "Batch 15 inbox 1: the disguise set has no walk frames, so the masked Rescuer walks away as the unmasked Elowen.",
     PIECE + "five walk-cycle sprite sheets of the Rescuer exactly as in her turnaround (hood up, a scarf over her face, green cloak, white coat, satchel), 4 walking frames side by side in one row per sheet, feet on one baseline, the same layout as Elowen's walk sheets.",
     "SPR-RESCUER-FRONT_WALK, -FRONTSIDE_WALK, -SIDE_WALK, -BACKSIDE_WALK, -BACK_WALK", "assets/art/world_test/sprites/RESCUER/*_WALK1..4.png", "1536x1024 each", "PNG with transparency",
     ["G:/My Drive/Card Game Art/Approved_Sprites/SPR-RESCUER.png", "G:/My Drive/Card Game Art/Approved_Sprites/SPR-ELOWEN-FRONT_WALK.png", "G:/My Drive/Card Game Art/Approved_Sprites/SPR-ELOWEN-BACK_WALK.png"], "12",
     "**The Rescuer's walk cycle: five sprite sheets** (1536x1024 each, transparent). Each sheet is 4 walking frames side by side in one row, evenly spaced, the same size, feet on the same baseline: exactly the layout of the two walk-format references (ref 18 SPR-ELOWEN-FRONT_WALK and -BACK_WALK). The character is the Rescuer exactly as in her turnaround (ref 18 SPR-RESCUER): hood up, a scarf over her face, green hooded cloak, white coat, leather satchel.\n   - **SPR-RESCUER-FRONT_WALK**: walking toward the viewer;\n   - **SPR-RESCUER-FRONTSIDE_WALK**: toward the viewer at a three-quarter angle, facing left;\n   - **SPR-RESCUER-SIDE_WALK**: side view, facing left;\n   - **SPR-RESCUER-BACKSIDE_WALK**: away from the viewer at a three-quarter angle, facing left;\n   - **SPR-RESCUER-BACK_WALK**: walking away from the viewer."),
    ("portraits", "NPC-QUADZILLA / NPC-CAIRN", "Baron Quadzilla (the Iron Cave's boss, open from the start) and the Restless Cairn: their closing lines show a name plate with no portrait",
     "(none)", "Fable Nov 12c inbox 2: two speaking bosses have Bestiary pictures but no dialogue portrait.",
     PORTRAIT + "QUADZILLA: a huge, cheerful Beefcake with enormous thighs sitting on a leg-press throne, a sweaty headband, tiny dumbbell earrings; CAIRN: a heap of old mossy grave stones with the restless dead of its Bestiary picture rising faintly out of it in ghost-green light. Each matches its Bestiary picture.",
     "NPC-QUADZILLA, NPC-CAIRN", "assets/art/portraits/NPC-QUADZILLA.webp, NPC-CAIRN.webp", "1024x1536 each", "PNG with transparency",
     ["assets/art/bestiary/BST-BARON-QUADZILLA.webp", "assets/art/bestiary/BST-THE-RESTLESS-DEAD.webp", "assets/art/portraits/NPC-SPOTTER.webp"], "9",
     "**NPC-QUADZILLA** and **NPC-CAIRN** (1024x1536 each, transparent, waist up, three-quarter view, in the style of ref 19 NPC-SPOTTER). Dialogue portraits of two bosses, each matching its square picture in ref 19:\n   - QUADZILLA: the huge, cheerful strongman with enormous thighs on his leg-press throne, a sweaty headband;\n   - CAIRN: a heap of old mossy grave stones, with the restless dead of its square picture rising faintly out of it in ghost-green light."),
    ("dnacrates", "DNA-PROP-CRATES / DNA-PROP-CABINET-TIPPED", "Outside the D.N.A.: the organised wasteland's rows (Fable Nov 14)",
     "(stand-ins: the town kit's crate tinted grey-green as boxes; cabinet cards turned on their side)", "The wasteland rows use a tinted village crate and rotated cabinet pictures; the D.N.A. kit has no crate and no fallen cabinet.",
     PIECE + "in the D.N.A. kit's grey-green office style: CRATES a neat stack of three grey archive crates with brass corner caps and a blank stamped label; CABINET-TIPPED a grey-green filing cabinet lying on its side with two drawers slid open and papers spilling out.",
     "DNA-PROP-CRATES, DNA-PROP-CABINET-TIPPED", "assets/art/zone_kits/dna/DNA-PROP-CRATES.webp, DNA-PROP-CABINET-TIPPED.webp", "512x512, 768x512", "PNG with transparency",
     ["assets/art/zone_kits/dna/DNA-SHEET-CABINETS-02.webp", "assets/art/zone_kits/dna/DNA-SHEET-FILING-TOWERS-01.webp", "docs/overnight_shots/nov14/p3_dna_apron_causeway_after.png"], "9",
     "**DNA-PROP-CRATES** (512x512) and **DNA-PROP-CABINET-TIPPED** (768x512), both transparent, front three-quarter view, in the grey-green office style of ref 20 (the cabinet and the filing tower; the screenshot shows the rows they stand in).\n   - CRATES: a neat stack of three grey archive crates with brass corner caps and a blank label;\n   - CABINET-TIPPED: a grey-green filing cabinet lying on its side, two drawers slid open, papers spilling out."),
]

HEAD = ["id", "where it is used", "current file", "problem", "needed image (existing style)", "target id(s)", "game file", "size", "format", "status", "references to attach", "severity x visibility"]


def ref_name(number, slug, path):
    return "%02d_%s__%s.png" % (number, slug, os.path.splitext(os.path.basename(path))[0])


def main():
    drive = "--no-drive" not in sys.argv
    if drive:
        os.makedirs(DRIVE, exist_ok=True)
    rows = []
    copied = 0
    missing = []
    for number, row in enumerate(ROWS, 1):
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
        rows.append([idn, where, current, problem, needed, targets, game_file, size, fmt, "In game", "; ".join(refs) + "  ->  " + ", ".join(names), score])
    with open("docs/art/batch16_nov14.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f, quoting=csv.QUOTE_ALL)
        w.writerow(HEAD)
        w.writerows(rows)
    images = sum(len([t for t in r[6].replace(" to ", ",").split(",")]) for r in ROWS)
    lines = [
        "Batch 16 for my cozy-fantasy deckbuilder RPG \"The Wayward Path\". Make all the images below, one at a time, without stopping to ask me questions. Save each one as a PNG named exactly as given in **bold**.",
        "",
        "I've attached reference images. Each reference's filename starts with the item number it belongs to (for example, 04_scuff__... is for item 4).",
        "",
        "House style for everything: painted cozy-fantasy game art, soft visible brushwork, warm painterly light, clean readable silhouettes, matching the attached references. Family friendly. No text, letters or numbers anywhere, unless an item says otherwise. \"Transparent\" means a real transparent background with no checkerboard and no shadow box.",
        "",
        "**The four Path icons.** Many items below replace wrong symbols with the game's four Path icons. They are on the attached sheet (every item that needs them has its own copy, named ..._path_icon_sheet) and as four separate files (ICON-ENERGY-B, -G, -R, -N). Paint them exactly as they are there, and never swap in another symbol:",
        "- **Beefcake:** a gold flexed arm on a red disc in a gold rim. Never a dumbbell or a flame.",
        "- **Gourmand:** a white chef's hat on a cream disc in a copper rim. Never a ladle, a fork or a drop.",
        "- **Refusemancer:** a green leaf inside three rust-orange recycling arrows on a moss-green disc. Never a single maple leaf or a sprout in a tin.",
        "- **Necrocrat:** a pale skull facing front, wrapped in green ghost-flame, on a dark slate disc. Never a stamp, a moon or a quill.",
        "- When all four appear in a ring, they go clockwise from the top: arm, chef's hat, leaf, skull.",
        "",
        "\"Repaint exactly\" means: keep everything in the reference as it is and change only what the item names.",
        "",
    ]
    for number, row in enumerate(ROWS, 1):
        lines.append("%d. %s" % (number, row[12]))
    with open("docs/prompts/chatgpt_batch16.md", "w", newline="\n", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")
    print("rows", len(rows), "references copied", copied, "missing", missing)


main()
