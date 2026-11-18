# Batch 17 + 17A import (Nov 18)

All 81 approved images are imported and in the game. Brief: `docs/prompts/opus_nov17_night.md`, Parts 1-3. Art lists:
`docs/art/batch17_nov17.csv` (64 rows) and `docs/art/batch17a_dna.csv` (17 rows), every row "In game (Nov 18)".
Shots: `docs/overnight_shots/nov18/` (named below). Prep and import tools: `tools/art/batch17_prep.py`, `tools/art/batch17_rows.py`,
`tools/art/town_map_warp.py`, `tools/batch17_shots.sh`.

## Drive filing

The 11 newest copies that sat outside their usual folders were moved into them (`Approved_UI`, `Approved_Maps`,
`Approved_Battleboards`, `Approved_Characters`); the 11 older same-named files were copied first to
`Superseded/Batch 17 replaced/`, so every id exists once. `Approved_ZoneKits/DNA/00_DONE_DNA_WALL_HALL-A.png` (a duplicate) was moved
there too. The CSV's paths now point at the usual folders.

## Import fixes (copies in `_art_inbox/batch17/`, the Drive files untouched)

| Image | Fix | Check |
|---|---|---|
| DNA-FLOOR-MARBLE | Cropped to an exact 2x2-square tile (618 px) whose edges run through the middle of the squares, so the seam sits inside marble, never on a grout line; edge blend (step 16 -> 8, 13 -> 7) | `p1_tile_DNA-FLOOR-MARBLE.jpg` (3x3) |
| DNA-RAIL-PARTITION | Cropped to its painted band (2172x416) | `p1_tile_DNA-RAIL-PARTITION.jpg` |
| DNA-WALL-HALL-A / -B / -NARROW, DNA-WALL-EXTERIOR, DNA-FLOOR-RUNNER | Edge blend across the wrap (seam step 3.6-9.8 -> 1.5-4.1) | `p1_tile_*.jpg` (each tiled 3x) |
| TOWN-PROP-CELLAR-FOURSEALS-OPEN | Every see-through pixel enclosed by the door laid over a painted-dark brown-black backing (a soft gradient, a little grain) | `p1_cellar_open_backed.jpg`, `p3_vault_open_zoom.jpg` |
| MAP-WORLD-TOWN | Resampled onto the town's world rectangle by a per-axis stretch matched on the gates, the fountain and the south wall, so the pins sit on their painted places | `p3_town_map_warp_check.jpg`, `p3_town_map_all.png` |
| BUFF-SHEET-FLIERS | Saved as a 4x2 frame sheet (1024x512) for the animation | `p3_buffet_east.jpg` |
| The ~1254 px images | Used as delivered, scaled to their slots; nothing upscaled | - |

The portrait importer overwrote NPC-PLAYER from the Drive again (the known opaque file); reverted, file and manifest line.

## Where each image is (Path icon guide checked where a Path sign shows)

| Images | In the game | Shot | Path icon guide |
|---|---|---|---|
| The 17 D.N.A. hall pieces | The rebuilt D.N.A. (Part 2): hall walls A/B/NARROW, exterior faces, partitions + posts, marble + runners, columns, chandeliers, sconces, lobby clock, banners, booths, the hall-interior backdrop at the north end | `p2_after_dna_*`, `walk/w_*` | the stamp banners and booths carry stamps and folders, no Path sign |
| DNA-SHEET-SIGNS (Batch 11, now used) | Every D.N.A. board is a brass plaque with the icon of what it points to (stamp, clock, arrow, folder, raised hand, ghost) | `p2_after_dna_door_low` | no Path sign |
| Five statues, standing and toppled (10) | The ruler's plinth in each zone hub, standing until the zone is freed, toppled beside the plinth after; same scale for all five (3.3 m standing, 1.5 m toppled) | `p3_statue_<zone>_<oppressed/freed>.jpg` | no Path sign |
| UI-CARDBACK-R / -G / -C | Card backs (same ids) | `b17_battle_backs.jpg` (the deck piles) | leaf in three arrows; chef's hat; the C back's compass carries the four medallions clockwise from the top left: arm, chef's hat, leaf, skull. Correct |
| UI-PACK-G, UI-PACK-GILDED-B (new) | The Gourmand pack and the Beefcake gilded pack; both carry their medallion, so the code overlay is off for them (`PackArt.PAINTED_MEDALLIONS`) | `b17_packs.jpg` | chef's hat and arm, whole in their rings. Correct |
| MAP-S-CAP, BB-S-CAP | Under the Capital's tunnel map and its battle board (same ids) | `b17_map_s_cap.jpg`, `b17_board_s_cap.jpg` | the four medallions in quadrants: arm top left, chef's hat top right, leaf bottom right, skull bottom left (clockwise). Correct |
| NPC-ELDER, _HAPPY, _WORRIED | Maren's dialogue portraits (same ids) | `b17_portrait_NPC-ELDER*.jpg` | no Path sign |
| NPC-PLAYER_CONFUSED, _DETERMINED | The hero's portraits, teal cloak | `b17_portrait_NPC-PLAYER_*.jpg` | no Path sign |
| DUMP-SHEET-ENTRANCE-FLAGS-07 / -08 | The two pennants on the Dump entrance landing (`HeapLandmarks.ENTRANCE_PENNANTS`) | covered by the Dump entrance | leaf in three arrows on green and on cream. Correct |
| ICON-NODE-WELL | The Hollow Well's node card banner and its node on the tutorial map | `b17_map_tutorial_well.jpg` (the node is fogged until reached) | no Path sign |
| CUT-QUADZILLA | Baron Quadzilla's boss-intro cut-out (`Bestiary.CUTOUTS_AWAITING_ART` is empty) | `b17_portrait_CUT-QUADZILLA.jpg` | no Path sign |
| The 7 BST-ECHO-OF-* and BST-THE-PERFECT-COPY | The Shattered Gallery's Bestiary entries | `b17_bestiary_*.jpg` | no Path sign |
| TOWN-PROP-CELLAR-FOURSEALS-CLOSED / -OPEN, TOWN-PROP-SEAL-LOCKED / -BLANK | Crosspath's Four Seals vault: the painted door (shut; open with the stair once all four seals have turned), the painted seals in the fixed diamond (arm top, chef's hat right, leaf bottom, skull left); a locked seal keeps the faint Path outline, a turned one shows its full icon on the blank seal | `p3_vault_locked/two/ajar/open(_zoom).jpg` | the icons are the canonical medallions. Note: the painting's four sockets sit in a row; the seals keep the owner's diamond (inbox) |
| MG-BG-PASS, MG-BG-CONVEYOR, MG-BG-FILING and the 15 MG-PROP pieces | The card games: Reps' bench, bar and plates (heaviest first, alternating ends); Order Up's pass, tickets (the game writes the target) and bell; Sort It Out's conveyor and four crates (the game draws the type icons on their plaques); File in Order's office, cabinet drawers and the APPROVED / REJECTED stamps | `p3_cardgame_<game>_<how/mid/win>.jpg` | type icons only. Correct |
| BUFF-PROP-FRUIT-TART, BUFF-PROP-CAKESTAND-TALL | The east food forest, among the cloches and stock pots | `p3_buffet_east.jpg` | no Path sign |
| BUFF-SHEET-FLIERS | The forest's butterflies and birds flap through their four painted frames (hidden on Low-end) | `p3_buffet_east.jpg` | no Path sign |
| BUFF-PROP-VEG-01..03 | The hub's cabbage beds (where the rows of untextured green balls sat) and the cabbages bobbing in the gravy river | `p3_buffet_hub.jpg` | no Path sign |
| DUMP-PROP-PIG | The escaped pig (was a pink Cube Pets cube) | `p3_dump_pig.jpg` | no Path sign |
| MAP-WORLD-TOWN | Crosspath's full map screen (M), under the pins and names, with a dark veil over unexplored cells | `p3_town_map_all.png`, `p3_town_map_fog.png` | no Path sign |

## Size

101 asset files written. Source art in `assets/`: **+14.7 MB** net (17.3 MB of new and replaced files against 2.6 MB replaced).
No export tonight (the brief), so the pack is not measured; at the import rules' compression this is roughly +15-25 MB of pack
on the 1.0.0 pack (784 MB, already over the 750 MB warning on purpose, `docs/build_size_policy.md`).
