# Batch 19 import (Fable Nov 22 night)

All 8 approved pictures are in the game. Source: `Pending Review/Batch 19/` (left in place); copies in the Approved folders; the three
files they replaced are in `Superseded/Batch 19 replaced/` (MAP-PC, MAP-WORLD-BUFF, UI-PACK-LOCKED-N).

| ID | Approved folder | In the game as | Wiring |
|---|---|---|---|
| MAP-PC | Approved_Maps | `assets/art/maps/MAP-PC.webp` | 22 room spots fitted to the painted landing spots (`data/dungeons/map_layout.json`, D-PC); 30 of 41 links have a painted walkway, the other 11 keep a drawn line (`drawn_links`); redo row in `docs/art/batch20.csv` |
| MAP-WORLD-BUFF | Approved_Maps | `assets/art/maps/MAP-WORLD-BUFF.webp` (1536 px, q88) | same world rectangle as Batch 18's (only the sushi shop moved in the painting) |
| BST-THE-PANTRY-MIMIC | Approved_Bestiary | `assets/art/bestiary/` | `Bestiary.ART_STAND_INS` is empty; the battle plate and the Collection Book read the same picture |
| UI-ALEMBIC-BREW | Approved_UI | `assets/art/ui/` | `AlchemistScreen.BREW_ART`: the centre of "The brew" (320 px tall stage); bubbles and flash start at the pot's mouth |
| UI-ALEMBIC-JAR | Approved_UI | `assets/art/ui/` | `EssenceJar`: the inside is truly transparent (one closed hole, alpha 0), so the liquid is drawn in `ART_HOLE` behind the painting |
| UI-PACK-LOCKED-N | Approved_UI | `assets/art/ui/` | same ID as before: no code change |
| T-PC-TRAINEE, T-PC-STATUE | Approved | `assets/art/cards/` | `tools/import_art.gd` `EXTRA_ART` (card-format pictures with no card ID); `token_art` of the two castle rules, no tint |

Tools: `python tools/castle_nov21.py --layout` (room spots and drawn links, then `bash tools/import_dungeons.sh`),
`python tools/art/batch19_rows.py` (sheet rows In Game, the Batch 20 row), `python tools/nov22_alembic_script.py <window width>`
(the shop's shot script). Shots: `docs/overnight_shots/nov22/p1_*.jpg`. Tests: `tests/test_batch19_import.gd`.

Size: `assets/art` 551.8 MB before, 552.4 MB after (+0.6 MB).
