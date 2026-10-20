# Art import, Oct 20: what to say and run, in order

Prepared overnight Oct 19-20 (Part 3). Tonight's art is generated into the Drive's `Pending Review` folder; nothing reads that folder (every importer refuses
`Pending Review` and `Superseded`). In the morning, approve the pictures into the `Approved_*` folders below, then run the lines here **one at a time**
(this PC runs one Godot process at a time). Every importer only COPIES from the Drive (never moves, renames or deletes) and keeps the old look for
anything still missing, so a partial delivery is fine and a line can be run again later.

## The lines, in order

| # | Say | Run | Drive folder | What it reports |
|---|-----|-----|--------------|-----------------|
| 1 | import card art | `bash tools/import_art.sh` | `Approved` | Added / replaced card IDs, still missing (11 today, see below), files matching no card ID. Writes `docs/art/art_status.md`. |
| 2 | import portraits | `bash tools/import_portraits.sh` | `Approved_Characters` | Added / replaced Portrait Image IDs (also `NPC-X_EXPRESSION`), background removed, IDs still missing, files matching no ID. |
| 3 | import npc sprites | `bash tools/import_npc_sprites.sh` | `Approved_Sprites` | Copies `SPR-*` into `_art_inbox/npc_sprites`, cuts them out, aligns feet and scale; report in `docs/art/npc_sprite_import_report.md` (missing, unmatched). |
| 4 | import icons | `bash tools/import_icons.sh` | `Approved_Icons` | Added / replaced, names matched forgivingly, files matching no ID, then three lines: **Gear icons (ICON-GEAR-\*)**, **Items icons (ICON-ITEM-\*)**, **Cosmetics icons (ICON-COS-\*)**: "n of N in the game; missing: ...". |
| 5 | import zone kit gainlands | `bash tools/import_zone_kit.sh gainlands` | `Approved_ZoneKits/Gainlands` | `import_zone_kit gainlands: n imported, n missing, n unmatched` + each missing id and unmatched file; full report `docs/art/zone_kits/gainlands_import_report.md`. |
| 6 | import zone kit heap | `bash tools/import_zone_kit.sh heap` | `Approved_ZoneKits/VerdantDump` (`zonekit_folders`) | The same for the DUMP-\* kit; report `docs/art/zone_kits/heap_import_report.md`. |
| 7 | import maps | `bash tools/import_maps.sh` | `Approved_Maps` | Added / replaced Map Image IDs (MAP-S-IRON), not 3:2 (kept, never cropped), still missing, files matching no ID. |
| 8 | import battleboards | `bash tools/import_battleboards.sh` | `Approved_Battleboards` | Added / replaced (BB-S-IRON), cropped to 16:9, still missing, files matching no ID, boards mapped to nothing. |
| 9 | import bestiary | `bash tools/import_bestiary.sh` | `Approved_Bestiary` (new folder) | Added / replaced BST IDs, not square (cropped from the top), names matched forgivingly, files matching no ID, "Bestiary IDs with no picture (n of 90)". |
| 10 | import UI art | `bash tools/import_ui_art.sh` | `Approved_UI` | Added / replaced UI IDs (UI-BG-CHARACTER), then `Character screen: UI-BG-CHARACTER has no painted frames -> data/ui_config.cfg background_painted_slots=false`. |

After the last line: `bash tools/run_tests.sh` (all GUT, compile check) once, then the screenshots below.

## What each line expects (IDs and counts)

**1. Card art** (`assets/art/cards/<ID>.webp`): the 11 cards still without art - C-17, INF-08, INF-09, INF-10, INF-11, JUNK-01, NB-10, NR-09, RES-GARBAGE,
RES-INGREDIENT, RES-IRON. Any other approved card file replaces the old picture when its MD5 changed.

**2. Portraits** (`assets/art/portraits/<ID>.webp`): 10 NPCs have none yet - NPC-KING, NPC-QUEEN, NPC-ELOWEN, NPC-SIPHON, NPC-QUOTA, NPC-CRUMB, NPC-PLUME,
NPC-CLIPWELL, NPC-ISLA, NPC-VAULTWARDEN. The sprite batch (`data/source/npc_sprite_batch.csv`, rows not Approved) also asks for portrait fixes of NPC-ELDER,
NPC-GATEKEEPER, NPC-RIP, NPC-PUMP, NPC-THUNDERABS, NPC-MOUNTAIN, NPC-ECTOMUND, NPC-PATE, NPC-FLAMBE, NPC-BASIL, NPC-WREN, NPC-KESTREL, NPC-SPOTLESS (replaced in place).

**3. NPC sprites** (`assets/art/world_test/sprites/<KEY>/`): the batch's open rows - SPR-BEETSWORTH, SPR-THREADWELL, SPR-ALEMBIC, SPR-RIP, SPR-PUMP, SPR-THUNDERABS,
SPR-MOUNTAIN, SPR-LEDGERBONE, SPR-ECTOMUND, SPR-PATE, SPR-FLAMBE, SPR-BASIL, SPR-WREN, SPR-FIGSLY, SPR-KESTREL, SPR-SPOTLESS, SPR-PLAYER (file names
`SPR-<KEY>-<DIR>_<IDLE|TALK|WALK>.png` as in the batch's "Files" column).

**4. Icons** (`assets/art/icons/<ID>.webp` + 24/32/48/64/96/128 px variants). The importer now accepts every ID below even though `icons.csv` has no row for it
(`IconArt.import_ids`, generated from the game data); a file named `ICON-GEAR-LUCKY-SOCK.png` or `icon-item-healing_draught.png` is matched and saved under the ID.
- **Gear, 54** (`ICON-GEAR-<equipment id, upper case, no underscores>`; 10 already in: WICKEDDAGGER, FLAMETHROWER, EXTRAPOCKET, CHEATERSDICE, TRAVELERSBOOTS,
  HOVERBOOTS, SOLIDPLATE, THORNEDLOINCLOTH, XRAYGOGGLES, BIGBRAINBERET). The 44 new: BINLID, BLOODSANDBOOTS, CARDBOARDCUIRASS, CHAMPIONSLAURELS, CLERKSSTAMP,
  COMPLIANCECLIPBOARD, COMPOSTBOOTS, COURIERLANYARD, CROWDPLEASERSCAPE, DOGEAREDBOOKMARK, DOGGYBAG, DUMPSTERGLOVES, ELASTICWAISTBAND, FLIPFLOPS, FOURSEALSIGNET,
  GLADIATORSNET, GLASSJAWGAUNTLETS, GOTTAGOGALOSHES, HEADCHEFLADLE, HEADCHEFTOQUE, HUBRISCROWN, HUSTLEHEADBAND, IRONKNUCKLES, KETTLEBELLLOCKET, LUCKYSOCK,
  MYSTERYSTAINBIB, NOTARYSEAL, OVERDUELIBRARYBOOK, PANTRYAPRON, PAPERPLANECAPE, PARTICIPATIONTROPHY, POINTYSTICK, PROTEINBANDOLIER, RACCOONCROWN, REDTAPEDISPENSER,
  ROLLINGPIN, SAUCEPANHELMET, SEEDSATCHEL, SIPHONSLENS, SPOTTERSBARBELL, STARTERBLADE, SUCKERPUNCHMITTS, SWOLEBELT, VELVETROPE (each prefixed `ICON-GEAR-`; the 25
  of `docs/art/zone_kits/equipment_icons.md` are among them).
- **Items, 18** (`ICON-ITEM-<item id, upper case, no underscores>`): BAGOFRUBBISH, BINDINGCHAINS, BLANKFORM, FIELDBANDAGE, FIREBRANDCHARM, GRAVEDUST, HEALINGDRAUGHT,
  HEALINGSALVE, HEARTYPIE, IRONRATION, RECKLESSTONIC, SCROLLOFINSIGHT, SHARPENINGSTONE, SILENCEPOWDER, SPICEPOUCH, SUMMONINGCHARM, VITALITYCHARM, WARDSIGIL.
- **Cosmetics, 10** (`ICON-COS-<CosmeticData.art_name>`): hats WIDEBRIM, CHEF, BOWLER, TRICORN, WIZARD, LEAFCROWN; cloaks PATCHWORK, REDCAPE, TATTERED, ROYAL
  (`ICON-COS-HAT-WIDEBRIM` style names are accepted too).
Where they show: gear on the Character screen, the equipment picker, vendors and the reward box; items on the battle item bar, Tilly Tonic's stall, the reward box and the
Character screen's item slots; cosmetics on Pip Threadwell's tailor tiles, the wardrobe buttons and the reward box. Missing ones keep the old picture.

**5. Gainlands kit** (`assets/art/zone_kits/gainlands/`, registry `data/art/zone_kits/gainlands.json`). The 33 ids of the first kit are in (a changed file is simply
re-prepared). `data/source/gainlands_kit.csv` now also lists the 33 requested ones (Status "Requested"), so they import instead of being "unmatched":
the Gainlands v2 requests (`docs/art/zone_kits/gainlands_v2_requests.md`): GAIN-HERO-GYM-HALL, GAIN-PROP-TOWER-MILL, GAIN-HERO-IRON-CAVE, GAIN-HERO-STONE-GATEWAY,
GAIN-PROP-SQUAT-RACK, GAIN-PROP-BENCH, GAIN-PROP-DUMBBELL-RACK, GAIN-PROP-KETTLEBELL-RACK, GAIN-PROP-ATLAS-STONES, GAIN-PROP-TIRE-PILE, GAIN-PROP-SLED-TRACK,
GAIN-PROP-PULLUP-FRAME, GAIN-PROP-ROPE-STATION, GAIN-PROP-PLATE-STACK, GAIN-PROP-CHALK-BUCKET, GAIN-PROP-LEG-PRESS, GAIN-TREE-WINDBENT, GAIN-TREE-CYPRESS,
GAIN-PROP-PYLON, GAIN-PROP-STONE-SPAN, TEX-GAIN-SANDSTONE-CLIFF, TEX-GAIN-FLAGSTONE-ROAD, TEX-GAIN-DRY-SCRUB, GAIN-FX-WATERFALL, GAIN-HERO-SWOLYMPUS-RIDGE,
GAIN-BD-MESAS, GAIN-PROP-KERB, GAIN-PROP-BANNER-POST, GAIN-PROP-STAIRS; and four from the first sheet that were never delivered: GAIN-GROUND-MAT,
GAIN-GROUND-CHALK, GAIN-GROUND-FIELD, GAIN-DEC-CHALK. PNG, WebP or JPG are all read now.

**6. Verdant Dump kit, DUMP-\*** (`assets/art/zone_kits/heap/`, area id `heap`, Drive folder `VerdantDump`). The 33 ids of the first kit are in.
`data/source/heap_kit.csv` now also lists 26 requested ones: from `docs/art/verdant_dump_v2.md` DUMP-TREE-WISTERIA, DUMP-PLANT-VIOLETS, DUMP-SURF-CLIFF, DUMP-DEC-VINES,
DUMP-SURF-WATER, DUMP-PROP-WATERFALL, DUMP-PROP-WATERWHEEL, DUMP-PROP-STALL, DUMP-BD-VALLEY, DUMP-PROP-STAIRS; from `docs/art/heap_slice.md` DUMP-PLANT-LUPIN,
DUMP-PLANT-LILY, DUMP-TREE-CANOPY, DUMP-SKY-SUNSET-SOFT, DUMP-WALL-SCRAP, DUMP-HERO-SCRAPMORE, DUMP-PROP-STABLE; from the first request list
(`docs/art/zone_kits/heap.md`) DUMP-ROOF-THATCH, DUMP-GROUND-GRAVEL, DUMP-GROUND-COMPOST, DUMP-TREE-ROTHEART, DUMP-PROP-WINDMILL, DUMP-DEC-RUST, DUMP-DEC-PETAL,
DUMP-DEC-MOSS, DUMP-BD-ROTHEART. Paint-overs (`*-PO-*`) stay "unmatched" on purpose (they are references, kept in `docs/art/paintovers/`).

Note for 5 and 6: importing registers the art (EnvKit resolves the id at once), but the world keeps its built STANDINs for the new pieces until a short wiring pass
swaps them (the ids are marked `STANDIN` / "replaces ..." in `world/gainlands/*` and the requests' "In-Game Use" column). Material swaps and existing ids that are
re-delivered show at once.

**7. Maps**: MAP-S-IRON (the Iron Cave; until it exists the game shows MAP-S-BEEF, `MapArt.STANDIN_MAPS`). 3:2, about 1536 x 1024; node spots at 24 %/76 %,
54 %/44 %, 81 %/20 % (`data/dungeons/map_layout.json` "S-IRON"; re-fit with `bash tools/map_fit_sheet.sh S-IRON` if the painted stops differ).

**8. Battleboards**: BB-S-IRON (the Iron Cave now names its own board in `data/dungeons/postgame_dungeons.json`; until the file exists it shows BB-S-BEEF,
`Battleboards.STANDIN_BOARDS`, and its battles keep the Swolympus music). `known_boards` also knows every dungeon blueprint's board (BB-LAB), so neither is "matching no ID".

**9. Bestiary, 90** (`assets/art/bestiary/<ID>.webp`, square 512 px; prompts in `docs/art/bestiary_image_requests.md`): BST-CAVE-SCAVENGER, BST-HOLLOW-STALKER,
BST-HOLLOW-WARDEN, BST-FLEXING-BRUTE, BST-PROTEIN-SHAKE-GOLEM, BST-SPRINTING-ENERGY-SPRITE, BST-SHAMBLING-MIDDLE-MANAGER, BST-ZOMBIE-INTERN, BST-SPEEDY-GHOST-COURIER,
BST-MEATLOAF-GOLEM, BST-GELATIN-SENTINEL, BST-RUNAWAY-MEATBALL, BST-COLONEL-CASSEROLE, BST-MOSSY-TRASH-GOLEM, BST-POSSESSED-SCARECROW-DRUID, BST-JUNK-GULL-FLOCK,
BST-COMPLIANCE-OFFICER, BST-PERFECTION-INSPECTOR, BST-TIDY-BOT, BST-RIFT-WRETCH, BST-SHARD-SWARM, BST-CAPTAIN-SPOTLESS, BST-TREADMILL-SPRINTER, BST-COURTYARD-LIFTER,
BST-REGIME-CHECKPOINT-CAPTAIN, BST-CELL-BLOCK-BRAWLER, BST-TROPHY-HALL-HONOR-GUARD, BST-CHANCELLOR-CLENCH-IRON-REGENT, BST-PREP-STATION-SOUS-CHEF, BST-FROZEN-LINE-COOK,
BST-UNFINISHED-WAR-MACHINE, BST-ASSEMBLY-LINE-GOLEM, BST-CANNON-BLENDER-GUNNER, BST-EXPEDITER-OF-THE-PASS, BST-THE-DOPPELGANGER, BST-INTAKE-CLERK, BST-RETURNS-CLERK,
BST-NOTARY-WRAITH, BST-RESURRECTION-PERMITS-ZOMBIE, BST-UNDERSECRETARY-VELLUM, BST-EXECUTIVE-ELEVATOR-OPERATOR, BST-MORTIMER-GRIMSBY-CE-NO, BST-OVERGROWN-SCARECROW,
BST-MUTANT-MUSHROOM-TROOP, BST-ROOTBOUND-MILLER, BST-THORN-MAZE-STALKER, BST-HIVE-OF-MUTANT-BEES, BST-ROT-TUNNEL-HORROR, BST-COMPOSTELLA-THE-ROTHEART,
BST-HEDGE-TRIMMER-GUARD, BST-GALLERY-CURATOR, BST-MIRROR-KNIGHT, BST-MINISTRY-CLERK, BST-ROYAL-STAIRCASE-GUARD, BST-COUP-BARRACKS-SERGEANT, BST-SEED-VAULT-GARDENER,
BST-CLOCKTOWER-SENTINEL, BST-PRIMM-HIS-PERFECTION, BST-CALF-RAISE-CRUSHER, BST-SQUAT-RACK-SQUATTER, BST-BARON-QUADZILLA, BST-RIVAL-LIFTER-AT-BASE-CAMP,
BST-SQUAT-RACK-SENTINEL, BST-THE-ANCIENT-SPOTTER, BST-APPRENTICE-ITAMAE, BST-CONVEYOR-BELT-SUSHI-CHEF, BST-THE-ITAMAE-SUPREME, BST-RECEPTIONIST-OF-NUMBER-ONE,
BST-THE-ETERNAL-QUEUE, BST-BETTY-BONES-SURLY-SECRETARY, BST-ALLEY-GATE-RACCOON, BST-PIZZA-CRUST-COURTIER, BST-HIS-MAJESTY-THE-RACCOON, BST-SEWER-CHECKPOINT-ENFORCER,
BST-JUNCTION-PATROL, BST-ENFORCER-CAPTAIN-SPOTLESS, BST-DECONTAMINATION-TECHNICIAN, BST-ESCAPED-SPECIMEN, BST-THE-FAILED-EXPERIMENT, BST-OBSERVATION-WARD-ORDERLY,
BST-THE-DRAIN-WARDEN, BST-SIPHON-S-RESEARCH-ASSISTANT, BST-DR-AMBROSE-SIPHON-CHIEF-PATH-OLOGIST, BST-RUSTY-GATE-CLOCKWORK, BST-BANNER-HALL-GUARDIAN,
BST-THE-OLD-KINGDOM-AUTOMATON, BST-SHIRO-SWINDLE, BST-THE-RESTLESS-DEAD, BST-CORRUPTED-WANDERERS, BST-THE-WARDEN-OF-THE-FOUR-SEALS.
Lower case and `_` in the file name are accepted (`bst_cave_scavenger.png`).

**10. UI art**: UI-BG-CHARACTER, the redone Character screen background **without painted equipment frames** (same file name; any other name is "matching no ID").
When its MD5 differs from the first picture, the importer sets `background_painted_slots=false` in `data/ui_config.cfg` and the screen draws its own five slot frames on the
figure (head, chest, hands, feet). If the new figure stands somewhere else, tune the five centres with `slot_centers` in the same section (screen units of 1920 x 1080;
the comment there shows the format) - no code change.

## Checks after the imports (screenshots; one Godot at a time)

| What | Command | Look for |
|------|---------|----------|
| Character screen (gear on) | `bash tools/shot.sh res://scenes/town.tscn oct20_character --open=character_gear --wait=6` | Five slots only: helm on the head, armor on the chest, weapon at the figure's right hand (screen left), relic at its left hand (screen right), boots at the feet; the item slots row ("Item slots (carried into battle)") in the right-hand frame; ICON-GEAR icons in the slots. |
| Character screen, other layout | add `--character_bg=painted` or `--character_bg=clean` to the line above | Forces the layout for a side-by-side check. |
| Bestiary | `bash tools/shot.sh res://scenes/town.tscn oct20_bestiary --open=bestiary --wait=6` | The fourth entry's picture; met entries show BST pictures in the grid. |
| Wardrobe (ICON-COS) | `bash tools/shot.sh res://scenes/town.tscn oct20_wardrobe --open=wardrobe --wait=6` | Hat / cloak buttons with their shop icons. |
| Item icons | `bash tools/shot.sh res://scenes/town.tscn oct20_chest --open=chest_popup --wait=6` | The reward box: the Healing Draught tile in full colour (ICON-ITEM-HEALINGDRAUGHT). |
| Icon contact sheet | `bash tools/shot.sh res://scenes/dev/icon_gallery.tscn oct20_icons` | Every icon crisp at all sizes. |
| Iron Cave map / board | `bash tools/map_fit_sheet.sh S-IRON` | The node dots on the painted stops (edit `data/dungeons/map_layout.json` if not). |
| Gainlands / Dump kits | `"/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe" --path . --resolution 1600x900 -s res://tools/zone_shots.gd -- --area=gainlands --mode=po --out=res://_screenshots/oct20_gainlands` (then `--area=heap`), or `bash tools/run_gainlands_walk_smoke.sh` / `bash tools/run_heap_walk_smoke.sh` | Changed kit art in place; no pink / missing textures. |

## Tests touching this

`tests/ui/test_icon_conventions.gd`, `tests/core/data/test_bestiary_import.gd`, `tests/ui/test_character_layout.gd`, `tests/ui/test_character_badges.gd`,
`tests/core/data/test_art_dropin.gd`, plus the existing `tests/test_icon_art.gd`, `tests/core/data/test_battleboards.gd`, `tests/core/data/test_map_art.gd`,
`tests/core/data/test_bestiary_art.gd`, `tests/world/test_zone_kit.gd`.

## Also done tonight

- `docs/.gdignore`: Godot no longer imports anything under `docs/` (its CSVs were imported as translations: the stray `docs/art/portrait_expression_requests.*.translation`
  files are deleted). Nothing in the game or the tools loads `res://docs/...` through the ResourceLoader (only `FileAccess` / `Image.load_from_file`, which still work).
