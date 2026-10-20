# Art import Oct 20 - report

The "Art Batch Oct 19" (211 approved files) sorted out of `Pending Review` (`docs/art/import_oct20_sorted.md`), the one-sheet NPC sprites split
(`docs/art/npc_sheet_split_report.md`), every importer of `docs/art/import_oct20.md` run in order, and the new art wired into the Gainlands, the Verdant Dump
and the Character screen. Commits "Art import Oct 20 Part 1-5".

## In the game now vs still missing

| Category | New today | In the game | Still missing |
|---|---|---|---|
| Card art | 7 (C-17, INF-08..11, NB-10, NR-09) | 335 of 339 | JUNK-01, RES-GARBAGE, RES-INGREDIENT, RES-IRON (not in the batch) |
| Portraits | 11 (KING, QUEEN, ELOWEN, SIPHON, QUOTA, CRUMB, PLUME, CLIPWELL, ISLA, VAULTWARDEN + VILLAGER) | every Portrait Image ID of the NPC list | none (the batch's requested portrait fixes for ELDER, GATEKEEPER, RIP ... were not in the delivery) |
| NPC world sprites | 10 sets (the same ten NPCs, split from one sheet each) | 52 characters | the three player cloak sets PATCHWORK / REDCAPE / ROYAL (40 files, older rows) |
| Gear icons | 38 | 48 of 55 | BLOODSANDBOOTS, CHAMPIONSLAURELS, CROWDPLEASERSCAPE, FIRSTWATERPHIAL, GLADIATORSNET (not delivered); DUMPSTERGLOVES, STARTERBLADE (REDO) |
| Item icons | 14 | 14 of 18 | BAGOFRUBBISH, SHARPENINGSTONE, SILENCEPOWDER, SPICEPOUCH (REDO) |
| Cosmetic icons | 9 | 9 of 10 | TRICORN (REDO) |
| Gainlands kit | 29 | 62 of 66 | GAIN-GROUND-MAT, GAIN-GROUND-CHALK, GAIN-GROUND-FIELD, GAIN-DEC-CHALK (not delivered) |
| Verdant Dump kit | 9 | 42 of 59 | DUMP-PROP-STALL (REDO); not delivered: DUMP-PLANT-LUPIN, DUMP-PLANT-LILY, DUMP-TREE-CANOPY, DUMP-SKY-SUNSET-SOFT, DUMP-WALL-SCRAP, DUMP-HERO-SCRAPMORE, DUMP-PROP-STABLE, DUMP-ROOF-THATCH, DUMP-GROUND-GRAVEL, DUMP-GROUND-COMPOST, DUMP-TREE-ROTHEART, DUMP-PROP-WINDMILL, DUMP-DEC-RUST, DUMP-DEC-PETAL, DUMP-DEC-MOSS, DUMP-BD-ROTHEART |
| Maps | MAP-S-IRON | all | none (node spots re-fitted to the painted stops) |
| Battle boards | BB-S-IRON | all | none |
| Bestiary | 71 | 71 of 91 | BST-EXECUTIVE-ELEVATOR-OPERATOR, BST-FROZEN-LINE-COOK (REDO); not delivered: BST-BETTY-BONES-SURLY-SECRETARY, BST-CAPTAIN-SPOTLESS, BST-CHANCELLOR-CLENCH-IRON-REGENT, BST-COMPOSTELLA-THE-ROTHEART, BST-DR-AMBROSE-SIPHON-CHIEF-PATH-OLOGIST, BST-ENFORCER-CAPTAIN-SPOTLESS, BST-HIS-MAJESTY-THE-RACCOON, BST-HOLLOW-WARDEN, BST-MORTIMER-GRIMSBY-CE-NO, BST-PRIMM-HIS-PERFECTION, BST-SHIRO-SWINDLE, BST-THE-ANCIENT-SPOTTER, BST-THE-DOPPELGANGER, BST-THE-ITAMAE-SUPREME, BST-THE-OLD-KINGDOM-AUTOMATON, BST-THE-WARDEN-OF-THE-FOUR-SEALS, BST-THE-WELLSPRING-S-ECHO, BST-UNDERSECRETARY-VELLUM |
| UI | UI-BG-CHARACTER (redone, no painted frames) | all 55 | none |

## REDO list

| File ID | Reason |
|---|---|
| ICON-COS-TRICORN | Truncated file: the PNG stops before its end (no IEND chunk), unreadable. Same size as it had in Pending Review, so it arrived cut off. |
| ICON-GEAR-DUMPSTERGLOVES | Truncated file (unreadable). |
| ICON-GEAR-STARTERBLADE | Truncated file (unreadable). |
| ICON-ITEM-BAGOFRUBBISH | Truncated file (unreadable). |
| ICON-ITEM-SHARPENINGSTONE | Truncated file (unreadable). |
| ICON-ITEM-SILENCEPOWDER | Truncated file (unreadable). |
| ICON-ITEM-SPICEPOUCH | Truncated file (unreadable). |
| BST-EXECUTIVE-ELEVATOR-OPERATOR | Truncated file (unreadable). |
| BST-FROZEN-LINE-COOK | Truncated file (unreadable). |
| DUMP-PROP-STALL | Truncated file (unreadable). |
| GAIN-BD-MESAS | Wrong framing: an opaque full-frame picture, the sky is painted in; a backdrop ring strip needs a transparent sky above the skyline (the importer's note). Not wired; the old mesa ring stays. |
| SPR-ISLA (optional) | The BACK_IDLE frame turns her head so her face shows; a true back view would match the other sets. Imported and in use. |
| SPR-CLIPWELL (optional) | Her topiary is painted beside her in all four frames, so it stands on her right in the back view too and widens the sprite. Imported and in use. |

No text or letters were spotted in any delivered picture (cards, portraits, icons, bestiary at review size, map, board). No halos: `tools/art_review_sheet.gd`
flagged none of the 61 icons or 71 bestiary pictures.

Name mismatches fixed without a redo: `ICON-ITEM-HEARTYPOTPIE.png` (named after "Hearty Pot Pie") is saved as ICON-ITEM-HEARTYPIE (the icon importer now also
matches the display name); `UI-BG-CHARACTER-v2.png` (kept beside the first picture in the Drive) is imported as UI-BG-CHARACTER (the UI importer takes the
highest `-vN` revision of an ID). The ten sprite sheets drew the side view facing right; the splitter mirrors it to the game's left-facing SIDE.

## What was wired

**Gainlands** (before/after `_screenshots/oct20_gain_before_*` / `oct20_gain_after_*`, hub and west road):
- Painted cut-out cards (still, storybook size) replace the built gym equipment in every lifting yard: SQUAT-RACK, BENCH, DUMBBELL-RACK, KETTLEBELL-RACK,
  ATLAS-STONES, TIRE-PILE, PULLUP-FRAME, ROPE-STATION, PLATE-STACK, CHALK-BUCKET, LEG-PRESS (`GainlandsGym.CARDS`). The flat sled track stays built
  (a standing card cannot lie on the ground). Blocking circles are unchanged, so routes stay clear.
- GAIN-TREE-WINDBENT (5 m) and GAIN-TREE-CYPRESS (6.5 m) cards replace the built hardy trees; GAIN-PROP-BANNER-POST cards replace the kit banner posts along
  the roads.
- Surfaces (`data/art/texture_presets.json`): TEX-GAIN-FLAGSTONE-ROAD on the routes and plaza, TEX-GAIN-DRY-SCRUB on the scrub patches,
  TEX-GAIN-SANDSTONE-CLIFF on every cliff face. GAIN-FX-WATERFALL scrolls in the waterfalls' shader.
- Concepts (references, kept in `docs/art/zone_kits/gainlands/concepts/`): the gym hall now has cream pillars, an open timber truss in the gable and the
  dumbbell emblem in gold on a red disc; the tower mill has pennants round its gallery; the Iron Cave mouth has a banner post either side. The three are
  tagged `concept` instead of `standin`. The stone gateway, pylons, stone spans, Swolympus ridge and mesa stairs already follow their concepts' shapes and
  are unchanged.
- Not wired: GAIN-PROP-KERB (the kerb is a row of built stones along every road; a standing card cannot make it), GAIN-BD-MESAS (REDO above).

**Verdant Dump** (`_screenshots/oct20_dump_before_*` / `oct20_dump_after_*`, hub and stream):
- DUMP-SURF-CLIFF on every terrace cliff (preset), DUMP-DEC-VINES drapes (6 cut-outs) hung down the cliff faces instead of the tube strands,
  DUMP-TREE-WISTERIA and DUMP-PLANT-VIOLETS cards (one MultiMesh each) instead of the built jacarandas and blossom clumps, DUMP-PROP-WATERWHEEL cards
  for both gorge wheels, DUMP-PROP-STAIRS on the stone stairs, DUMP-SURF-WATER as a painted layer under the toon water (`StyleWater.painted`; other zones
  unchanged), DUMP-PROP-WATERFALL under the falls' streaks, DUMP-BD-VALLEY for the five far backdrop cards (`data/art/zone_looks.json`, was DUMP-BD-JUNK).

**Character screen** (`_screenshots/oct20_character.png`): the new background has no painted frames; `background_painted_slots=false` and `slot_centers`
in `data/ui_config.cfg` put the five slots on the head, chest, right hand (screen left), left hand (screen right) and feet. Nothing else in the equipment area.

**Checked in game** (`tests/core/data/test_art_import_oct20.gd`): gear / item / cosmetic icons resolve through `IconArt` (the Character screen, picker,
vendors, reward box, item bar, Tilly's stall, Pip's tailor and the wardrobe all draw through it), the ten NPCs have portraits and stand in the world as
their painted sprites (`NpcSprites.character_for`), the Bestiary shows BST pictures, the Iron Cave has its own map and board. Review sheets:
`_screenshots/oct20_sheet_icons.png`, `oct20_sheet_bestiary.png`, `oct20_sheet_portraits.png`, `oct20_sheet_cards.png`, `npc_sheet_split.png`,
`map_fit/S-IRON.png`.

## Build size

The new imported textures add about 43 MB to the pack (zone kits 26 MB, icons 7 MB, bestiary 5 MB, the rest under 2 MB each): about 652 -> 695 MB
estimated, well under the 800 MB warning and 1 GB, so nothing needed extra compression (the folder rules in `tools/art_import_rules.json` already cover
every new folder).

## Verification (Part 5)

- Full GUT: 2049 tests, all passing (two older tests updated for the new art: the Swole Belt now has its own icon, Elowen has her sprite set);
  the walkability tests (`test_walkability_town`, `test_walkability_zones`) are part of it.
- Gainlands walk smoke OK (bridge -> plaza -> Iron Cave -> west span -> mesa stairs -> House of Gains gate -> sealed Swolympus gate -> town).
- Verdant Dump walk smoke OK (21 screenshots), Crosspath walk smoke OK (19), first-battles smoke OK.
- Tour bot OK: 276 spots, 9 menus, 5 battles, 0 errors, 0 warnings (`docs/overnight/bot_report.md`).
- The first full GUT attempt was stopped by Claude Code when the PC ran low on memory; it was re-run on request and passed.
