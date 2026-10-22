# Art import, Oct 22 ("Art Batch Oct 22"): what to say and run, in order

ChatGPT's batch lands in the Drive's `Pending Review` folder; nothing reads that folder (every importer refuses `Pending Review` and `Superseded`). Approve the pictures
into the `Approved_*` folders below, then run the lines here **one at a time** (this PC runs one Godot process at a time; close the editor's game if it is running).
Every importer only COPIES from the Drive (never moves, renames or deletes) and keeps the old look for anything still missing, so a partial delivery is fine and a
line can be run again later. Every ID below was checked against its importer's known-ID list on Oct 22: none of them will come back as "matching no ID".

Already in `Pending Review` on Oct 22 (seen, not imported): the six `COS-HAT-*-SHEET.png`, `NPC-RESCUER.png`, `SPR-RESCUER.png`, `ICON-COS-TRICORN.png` and seven
`ICON-GEAR-*` / `ICON-ITEM-*` icons. The hat sheets and SPR-RESCUER were dry-run through their importers on copies (see lines 3 and 5).

## The lines, in order

| # | Say | Run | Approve into (Drive) | What it reports |
|---|-----|-----|----------------------|-----------------|
| 1 | import card art | `bash tools/import_art.sh` | `Approved` | Added / replaced card IDs, still missing, files matching no card ID; writes `docs/art/art_status.md`. |
| 2 | import portraits | `bash tools/import_portraits.sh` | `Approved_Characters` | Added / replaced Portrait Image IDs (also `NPC-X_EXPRESSION`), flat background removed, IDs still missing, files matching no ID. |
| 3 | import npc sprites | `bash tools/import_npc_sprites.sh` | `Approved_Sprites` | Splits one-sheet `SPR-<KEY>.png` deliveries, cuts out, aligns feet and scale; report `docs/art/npc_sprite_import_report.md` + `docs/art/npc_sheet_split_report.md`. |
| 4 | import icons | `bash tools/import_icons.sh` | `Approved_Icons` | Added / replaced, forgiving name matches, then the Gear / Items / Cosmetics icon counts "n of N in the game; missing: ...". |
| 5 | import cosmetics | `bash tools/import_cosmetics.sh` | `Approved_Cosmetics` (**new folder**: create it) | `COS-HAT-<NAME>: directions FRONT, ... (from the sheet)` per hat, then "hat X: ready / arriving soon" and "cloak X: ready" for all ten. |
| 6 | import maps | `bash tools/import_maps.sh` | `Approved_Maps` | Added / replaced Map Image IDs, not 3:2 (kept, never cropped), still missing, files matching no ID. |
| 7 | import battleboards | `bash tools/import_battleboards.sh` | `Approved_Battleboards` | Added / replaced, cropped to 16:9, still missing, files matching no ID, boards mapped to nothing. |
| 8 | import bestiary | `bash tools/import_bestiary.sh` | `Approved_Bestiary` | Added / replaced BST IDs, not square (cropped from the top), forgiving name matches, "Bestiary IDs with no picture (n of 96)". |
| 9 | import zone kit gainlands | `bash tools/import_zone_kit.sh gainlands` | `Approved_ZoneKits/Gainlands` | `import_zone_kit gainlands: n imported, n missing, n unmatched`; report `docs/art/zone_kits/gainlands_import_report.md`. |
| 10 | import zone kit heap | `bash tools/import_zone_kit.sh heap` | `Approved_ZoneKits/VerdantDump` | The same for the DUMP-\* kit; report `docs/art/zone_kits/heap_import_report.md`. |

After the last line: `bash tools/run_tests.sh` (all GUT, compile check) once, then the checks at the bottom.

## What each line expects

**1. Card art** (`assets/art/cards/<ID>.webp`; known IDs = `CardImporter.build_all()`: `data/source/card_list.csv`, `token_list.csv`, the resource tokens and the junk card):
- **T-24** "Elowen Vey, Defector" (the ally token who starts on your field in the Path-ology Lab boss fight if you rescued her) and **T-25** "Failed Experiment"
  (3/3, from Siphon's Replication protocol) - both rows of `data/source/token_list.csv`.
- **RES-IRON, RES-INGREDIENT, RES-GARBAGE** (the resource tokens, `ResourceKind.card_id`) and **JUNK-01** "Heap of Rubbish" (`CardImporter._junk_entry`).
- Note: there is no `RES-REDTAPE` card - Red Tape is T-14 and a Contract T-13; a file named RES-REDTAPE would be "matching no ID" (the icon is `ICON-RES-REDTAPE`).

**2. Portraits** (`assets/art/portraits/<ID>.webp`, 768 px tall):
- **NPC-RESCUER** - the disguised Rescuer (hooded, scarf over the face). Known through `Portraits.EXTRA_PORTRAITS` (it is a second picture of NPC-ELOWEN, not a new
  NPC). Shown from the prologue until Plume names her at the castle gate, NPC-ELOWEN after (`RescuerDisguise`, docs/art/cosmetics.md Part 4).
- **NPC-OLDWELL** - the Old Well's portrait. **Wired**: `NPC-OLDWELL` is an extra NPC in `data/npcs/npc_game_map.json` named "The Old Well", and every Old Well
  line in `data/story/old_well_story.json` has that speaker, so the vision, the hums, the confirm and the brief show the portrait as soon as the file exists
  (until then: no portrait, as before). "The Wellspring's Echo" keeps its own (no) portrait.
- **The 13 portrait fixes** (replaced in place when the file's MD5 changed; all are list NPCs in `data/npcs/npcs.json`): NPC-ELDER, NPC-GATEKEEPER, NPC-RIP,
  NPC-PUMP, NPC-THUNDERABS, NPC-MOUNTAIN, NPC-ECTOMUND, NPC-PATE, NPC-FLAMBE, NPC-BASIL, NPC-WREN, NPC-KESTREL, NPC-SPOTLESS. Expression files
  (`NPC-ELDER_HAPPY.png`) are matched too.

**3. NPC sprites**: **SPR-RESCUER** (one sheet `SPR-RESCUER.png`, four frames left to right FRONT_IDLE, FRONT_TALK, SIDE_IDLE, BACK_IDLE; row NS-RESCUER of
`data/source/npc_sprite_batch.csv`, relative height 1.0). `tools/split_sprite_sheets.gd` splits it exactly like the Oct 20 sheets (side view mirrored to face left,
background removed). Dry run on the pending copy: 4 figures, 0 specks, clean (`docs/art/apparel/rescuer_split_dry.png`). In the game it becomes the character
RESCUER, which the prologue and the Cave Mouth use until she is named.

**4. Icons** (known IDs = `icons.csv` + `IconArt.game_ids()` from the gear, item and cosmetic data): ICON-COS-TRICORN, ICON-GEAR-CHAMPIONSLAURELS,
ICON-GEAR-DUMPSTERGLOVES, ICON-GEAR-STARTERBLADE, ICON-ITEM-BAGOFRUBBISH, ICON-ITEM-SHARPENINGSTONE, ICON-ITEM-SILENCEPOWDER, ICON-ITEM-SPICEPOUCH (and any other
`ICON-GEAR-*` / `ICON-ITEM-*` / `ICON-COS-*` of the game).

**5. Cosmetics - the hat sheets** `COS-HAT-<NAME>-SHEET.png` (2560x512, five views FRONT, FRONTSIDE, SIDE, BACKSIDE, BACK) for WIDEBRIM, CHEF, BOWLER, TRICORN,
WIZARD, LEAFCROWN. Split by `HatSheet.split`, fitted to the hero's head per direction into `assets/art/cosmetics/hats/fit_auto.json`; hand tuning in
`assets/art/cosmetics/hats/fit.json` (docs/art/cosmetics.md Part 2). After the import the hats are for sale at Pip Threadwell's (no more "Soon"), and the wardrobe
lists the owned ones. The line also re-measures the head anchors (`tools/sprite_anchors.gd`) and makes the normal maps. Dry run on the pending copies: all 30
views split cleanly (`docs/art/apparel/pending_hats_split.png`, walking `hat_pending_<NAME>.png`). Seen in those sheets, worth a redo: CHEF FRONT and FRONTSIDE are
clipped at the right edge in the painting; LEAFCROWN FRONTSIDE / SIDE / BACK are clipped at an edge.
The four cloaks need nothing: they are made from the hero's own cloak (`bash tools/make_cloaks.sh`, Part 1). A painted `SPR-PLAYER-CLOAK-*` set dropped into
`Approved_Cosmetics` later would replace the generated one.

**6. Maps** (known = every dungeon blueprint's `map_id`): **MAP-S-PASTE** (The Paste Works, the Capital side dungeon behind Chef Marlo's quest; until it exists the
game shows MAP-S-CAP, `MapArt.STANDIN_MAPS`) and **MAP-LAB** (the Path-ology Lab, D-LAB, postgame). 3:2, about 1536x1024; re-fit the node spots with
`bash tools/map_fit_sheet.sh S-PASTE` / `D-LAB` if the painted stops differ from `data/dungeons/map_layout.json`.

**7. Battleboards**: **BB-S-PASTE** (`Battleboards.EXTRA_BOARDS` and the S-PASTE blueprint; stand-in BB-TTK until it exists) and **BB-LAB** (the D-LAB blueprint).
Cropped to 16:9.

**8. Bestiary** (known = `Bestiary.art_id` of the 96 entries in `data/bestiary/bestiary.json`, BST-<NAME IN CAPS, other characters as one dash>): any BST-\* of the
batch. Square 512 px.

**9-10. Zone kits**: the importer walks the ids of `data/source/gainlands_kit.csv` (66 ids, GAIN-\* and TEX-GAIN-\*) and `data/source/heap_kit.csv` (59 ids, DUMP-\*)
and looks for `<ID>.png/.webp/.jpg` in the zone's folder; ids without a file are "missing", other files are ignored. New pieces register at once; pieces that
replace a built stand-in need the short wiring pass noted in each request list (docs/art/import_oct20.md, note for 5 and 6).

## Checks after the import
1. `bash tools/run_tests.sh` - all green (includes `test_cloak_sets`, `test_hat_sheets`, `test_apparel_shop`, `test_rescuer_disguise`).
2. Hats on the hero, every direction and the walk:
   `for h in WIDEBRIM CHEF BOWLER TRICORN WIZARD LEAFCROWN; do Godot --path . --resolution 1700x420 res://tools/sprite_sheet_shot.tscn -- --hat=$h --mode=walk --rows=2 --every=18 --out=apparel/hat_$h; done`
   A hat that sits too high/low or too wide: edit `assets/art/cosmetics/hats/fit.json` (`sink`, `width`, per direction `sink_SIDE` ...) and re-shoot; no re-import needed.
3. Wardrobe: `bash tools/shot.sh res://scenes/town.tscn apparel/wardrobe_hat --open=wardrobe --wear=hat_wizard,cloak_red_cape`.
4. The Rescuer: `bash tools/run_prologue_smoke.sh` (the prologue with SPR-RESCUER and the NPC-RESCUER portrait), then a Cave Mouth talk with
   `bash tools/dialogue_shots.sh res://scenes/town.tscn rescuer call:_talk_rescuer` after freeing a zone (or the playthrough bot); after the castle gate
   (`rescuer_named`) she shows NPC-ELOWEN.
5. The Old Well: `bash tools/run_old_well_smoke.sh` - the vision and the hums show NPC-OLDWELL.
