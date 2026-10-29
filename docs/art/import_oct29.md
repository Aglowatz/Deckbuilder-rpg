# Art import Oct 29 (art batches 5-9: the rest of art_batch_oct28.csv)

The brief calls these "rows #87-164"; in the CSV's own order the delivered rows are **#75-152** (SPR-PRIMM is row 75, CAP-PATH-WHITE row 152)
and #153-164 are the twelve portrait-expression rows skipped by design. Same set of IDs either way (inbox "Art import Oct 29", item 1).

## Part 0 - inventory (Oct 29 MDT)

Copy-only from the Drive into `_art_inbox/oct29_check/` (86 files, 0 missing), then a full PNG decode of every file (every chunk CRC, IEND,
inflate, every row unfiltered; alpha coverage, edge touching, opaque corners, grey border) and three contact sheets looked at by eye:
`_screenshots/oct29/review_story.png`, `review_small.png`, `review_zone.png`.

- **86 / 86 present and structurally sound** (no truncation, no bad CRC, no decode error). assets/art before import: **447 MB**.
- Story stills: 15 x 1792x1024 (16:9), opaque paintings as the STILL lock asks; no lettering. The lower quarter is calmer in most; the
  caption box covers it.
- Cards: 16 x 1024x1536 RGB, full-bleed paintings (N-10 is the Push Broom redo).
- Icons: 12 x 1024x1024 RGBA, transparent around the emblem; the 8 feat icons share one shield frame (one set).
- Cosmetic: COS-HAT-LEAFCROWN-SHEET 2560x1024, five small crowns in one row on transparency (92% empty: the crowns sit in the middle band).
- Sprites: SPR-DUMPWORKER (a mole farmhand with a pitchfork) and SPR-PRIMM (postgame Primm in a plain grey coat), 4 x 1024x1536 each,
  transparent, no ground shadow, feet at y=1474.
- Backdrop strips (9): 2048x1024, sky fully transparent, content touches the bottom and both sides (expected for a tiling strip; the
  review tool's "touches the border" flag is that).
- Sheets / decals (12): 2048x1365, six pieces each on transparency, none touching the border. TOWN-SHEET-FREED-BANNERS holds four Path
  banners (red barbell, blue ladle, purple stamp, green leaf) and two cream crest banners.
- Cut-out props: cave mouth, hamster wheel, junk mountain, fountain 2048x2048; throne dumpster 2048x1536; statue 1024x1536 (the CSV asked
  2:3 - fine), fallen statue 2048x1024; lab hatch 1024x1024; three giant trees 1024x1536. All transparent, nothing touching the edge.
- CAP-PATH-WHITE: 1024x1024 opaque white marble flagstones with two gold seams (tileable).
- Nothing off enough to need a redo.

| File | Bytes | Px | Alpha (transparent share) | Touches |
|---|---:|---|---:|---|
| B-34.png | 2369603 | 1024x1536 | opaque | TBLR |
| B-35.png | 2091162 | 1024x1536 | opaque | TBLR |
| B-36.png | 2002094 | 1024x1536 | opaque | TBLR |
| BUFF-BD-CAKE-CATHEDRAL.png | 3142588 | 2048x1024 | 0.564 | BLR |
| BUFF-BD-TEST-KITCHEN.png | 3103687 | 2048x1024 | 0.565 | BLR |
| BUFF-DEC-ROSETTES.png | 3689861 | 2048x1365 | 0.53 |  |
| BUFF-SHEET-TASTING-STANDS.png | 2806725 | 2048x1365 | 0.686 |  |
| C-35.png | 2312735 | 1024x1536 | opaque | TBLR |
| CAP-PATH-WHITE.png | 1546833 | 1024x1024 | opaque | TBLR |
| CAPI-BD-CASTLE.png | 2670552 | 2048x1024 | 0.622 | BLR |
| CAPI-BD-GREAT-WALL.png | 2509094 | 2048x1024 | 0.554 | BLR |
| CAPI-DEC-LOST-PROPERTY.png | 3029414 | 2048x1365 | 0.635 |  |
| CAPI-PROP-PRIMM-STATUE.png | 2113463 | 1024x1536 | 0.555 |  |
| CAPI-PROP-STATUE-FALLEN.png | 4398015 | 2048x1024 | 0.369 |  |
| CAPI-SHEET-RIFTS.png | 1313292 | 2048x1365 | 0.88 |  |
| COS-HAT-LEAFCROWN-SHEET.png | 740669 | 2560x1024 | 0.924 |  |
| DNA-BD-HALL-FACADE.png | 3187958 | 2048x1024 | 0.441 | BLR |
| DNA-DEC-FORMS.png | 1768228 | 2048x1365 | 0.804 |  |
| DNA-SHEET-FILING-TOWERS.png | 1498742 | 2048x1365 | 0.845 |  |
| DNA-SHEET-GHOST-QUEUE.png | 1770107 | 2048x1365 | 0.818 |  |
| DNA-SHEET-PROPS.png | 1113637 | 2048x1365 | 0.894 |  |
| DUMP-BD-ROTHEART-SKY.png | 3929723 | 2048x1024 | 0.442 | BLR |
| DUMP-DEC-CORRUPTION.png | 3579309 | 2048x1365 | 0.653 |  |
| DUMP-HERO-JUNK-MOUNTAIN.png | 8518582 | 2048x2048 | 0.415 |  |
| DUMP-HERO-THRONE-DUMPSTER.png | 6767670 | 2048x1536 | 0.337 |  |
| DUMP-SHEET-ENTRANCE-FLAGS.png | 2216177 | 2048x1365 | 0.785 |  |
| G-34.png | 2006446 | 1024x1536 | opaque | TBLR |
| G-35.png | 2222032 | 1024x1536 | opaque | TBLR |
| GAIN-BD-HOUSE-OF-GAINS.png | 3156150 | 2048x1024 | 0.566 | BLR |
| GAIN-DEC-REGIME-POSTERS.png | 4573485 | 2048x1365 | 0.5 |  |
| GAIN-HERO-HAMSTER-WHEEL.png | 9072146 | 2048x2048 | 0.315 |  |
| GAIN-SHEET-FLOATING-ISLANDS.png | 1769893 | 2048x1365 | 0.829 |  |
| ICON-FEAT-CHALLENGES.png | 1668655 | 1024x1024 | 0.399 |  |
| ICON-FEAT-COLLECTION.png | 1502800 | 1024x1024 | 0.405 |  |
| ICON-FEAT-MIXED.png | 1553228 | 1024x1024 | 0.39 |  |
| ICON-FEAT-PATHS.png | 1378495 | 1024x1024 | 0.419 |  |
| ICON-FEAT-SECRET.png | 1440894 | 1024x1024 | 0.398 |  |
| ICON-FEAT-SIDE.png | 1527379 | 1024x1024 | 0.418 |  |
| ICON-FEAT-STORY.png | 1598306 | 1024x1024 | 0.397 |  |
| ICON-FEAT-ZONES.png | 1526071 | 1024x1024 | 0.412 |  |
| ICON-GEAR-CLIPWELLSSHEARS.png | 1005574 | 1024x1024 | 0.69 |  |
| ICON-GEAR-COLONELSLADLE.png | 1063067 | 1024x1024 | 0.678 |  |
| ICON-GEAR-PLUMESQUILL.png | 1146966 | 1024x1024 | 0.667 |  |
| ICON-GEAR-QUOTASSTOPWATCH.png | 1654748 | 1024x1024 | 0.456 |  |
| N-10.png | 2265948 | 1024x1536 | opaque | TBLR |
| N-34.png | 1908154 | 1024x1536 | opaque | TBLR |
| N-35.png | 1947514 | 1024x1536 | opaque | TBLR |
| N-36.png | 1993969 | 1024x1536 | opaque | TBLR |
| N-37.png | 2006917 | 1024x1536 | opaque | TBLR |
| N-38.png | 1960870 | 1024x1536 | opaque | TBLR |
| NB-17.png | 2043241 | 1024x1536 | opaque | TBLR |
| OF-BD-TORCHLINE.png | 2212762 | 2048x1024 | 0.601 | BLR |
| OF-HERO-CAVE-MOUTH.png | 9805173 | 2048x2048 | 0.284 |  |
| OF-PROP-LAB-HATCH.png | 2486743 | 1024x1024 | 0.275 |  |
| OF-TREE-GIANT-01.png | 3431459 | 1024x1536 | 0.375 |  |
| OF-TREE-GIANT-02.png | 3030725 | 1024x1536 | 0.464 |  |
| OF-TREE-GIANT-03.png | 3622547 | 1024x1536 | 0.347 |  |
| R-34.png | 2440070 | 1024x1536 | opaque | TBLR |
| R-35.png | 2289049 | 1024x1536 | opaque | TBLR |
| R-36.png | 2509189 | 1024x1536 | opaque | TBLR |
| SPR-DUMPWORKER-BACK_IDLE.png | 2372898 | 1024x1536 | 0.55 |  |
| SPR-DUMPWORKER-FRONT_IDLE.png | 2319111 | 1024x1536 | 0.544 |  |
| SPR-DUMPWORKER-FRONT_TALK.png | 2381453 | 1024x1536 | 0.536 |  |
| SPR-DUMPWORKER-SIDE_IDLE.png | 1985747 | 1024x1536 | 0.626 |  |
| SPR-PRIMM-BACK_IDLE.png | 1519609 | 1024x1536 | 0.648 |  |
| SPR-PRIMM-FRONT_IDLE.png | 1583369 | 1024x1536 | 0.649 |  |
| SPR-PRIMM-FRONT_TALK.png | 1620840 | 1024x1536 | 0.639 |  |
| SPR-PRIMM-SIDE_IDLE.png | 1357697 | 1024x1536 | 0.701 |  |
| STORY-CAPTURE.png | 4875769 | 1792x1024 | 0 | TBLR |
| STORY-CELL-4.png | 4583421 | 1792x1024 | 0 | TBLR |
| STORY-FACADE-FALLS.png | 5581441 | 1792x1024 | 0 | TBLR |
| STORY-FUNERAL.png | 5229450 | 1792x1024 | 0 | TBLR |
| STORY-HOME.png | 5315235 | 1792x1024 | 0 | TBLR |
| STORY-KEPT-FACE.png | 4914230 | 1792x1024 | 0 | TBLR |
| STORY-MEMORY-1.png | 4063064 | 1792x1024 | 0 | TBLR |
| STORY-MEMORY-2.png | 4126758 | 1792x1024 | 0 | TBLR |
| STORY-MEMORY-3.png | 4836023 | 1792x1024 | 0 | TBLR |
| STORY-MEMORY-4.png | 5288273 | 1792x1024 | 0 | TBLR |
| STORY-MODEL-ROOM.png | 5054914 | 1792x1024 | 0 | TBLR |
| STORY-SEVER.png | 5371658 | 1792x1024 | 0 | TBLR |
| STORY-THRONE.png | 5027674 | 1792x1024 | 0 | TBLR |
| STORY-VACANCY.png | 3914485 | 1792x1024 | 0 | TBLR |
| STORY-WONDER.png | 5335176 | 1792x1024 | 0 | TBLR |
| TOWN-BD-HORIZON.png | 2360699 | 2048x1024 | 0.645 | BLR |
| TOWN-HERO-FOUNTAIN.png | 8793710 | 2048x2048 | 0.373 |  |
| TOWN-SHEET-FREED-BANNERS.png | 4518166 | 2048x1365 | 0.511 |  |

## Part 1 - story stills

`import key art` (15 rows added to `data/source/logo_title_art.csv`, status "Done") -> `assets/art/keyart/STORY-*.webp` (16:9, upper part kept).
The new stills have no captions of their own (dialogue freeze: no new `still.*` keys); each sits **behind the scene's own narration**
(`StillBackdrop`, mapping in `StoryStills`):

| Still | Where | Hook |
|---|---|---|
| STORY-WONDER, -VACANCY, -SEVER, -MODEL-ROOM, -KEPT-FACE | dungeon cutscenes wonder / vacancy / sever / primm_intro / primm_reveal | `StoryStills.CUTSCENE_BACKDROPS`; the icon stage hides, the lines play over the picture |
| STORY-THRONE, -FACADE-FALLS | ending beats throne / facade | `StoryStills.ENDING_BACKDROPS`; the stage returns for the next beat |
| STORY-CAPTURE, -CELL-4, -FUNERAL, -HOME | story scenes pc_capture / lab_cell4 / royal_funeral / isla_homecoming (dialogue box) | `StoryStills.SCENE_BACKDROPS`; `StoryScenePlayer` puts it under the box, fades it out at the end |
| STORY-MEMORY-1..4 | memory fragments 1-4 | `StoryStills.memory_backdrop`; the dimming stops at 0.6 so the picture shows |

Shots: `_screenshots/oct29/stills.png` (all 15 in their real screens, first lines typed) and `still_story-*.png` full size, from
`res://scenes/dev/still_gallery.tscn` (windowed). Every narration box reads clearly (the dark band under the box; memory lines over a 0.6 dim).
Test: `tests/test_story_backdrops_oct29.gd`.

## Part 2 - cards, icons, the Leaf Crown, NPC sprites

- **Cards** (`import card art`): B-34, B-35, B-36, C-35, G-34, G-35, N-34..N-38, NB-17, R-34..R-36 added, **N-10 replaced** (the Push Broom
  redo; the importer re-copies on a changed MD5). 356 of 356 cards and tokens have art. Hand, zoom, Deck Station and packs all draw
  `CardArt` by card ID, so nothing else was needed. Shot: `_screenshots/oct29/cards_new.png` (the card gallery's new `--ids=` filter).
- **Gear icons** (`import icons`): ICON-GEAR-QUOTASSTOPWATCH / COLONELSLADLE / PLUMESQUILL / CLIPWELLSSHEARS. They are the pieces' own
  icons by convention (`IconArt.gear_icon_id`), so the character screen, Bertram's lists and the reward box show them by themselves
  (59 / 59 gear icons in the game).
- **Feat icons**: the importer accepts ICON-FEAT-* now (`IconArt.game_ids` lists `FeatDefs.GROUP_ICONS` + SECRET). Ten groups, eight
  pictures: Story, Zones, Side dungeons (SIDE), Challenges, Collection; the four one-Path groups share PATHS, Dual Path is MIXED; an
  unearned hidden feat shows SECRET. Menu > Feats shows the icon beside each group heading and each row; the unlock toast carries its
  group's icon (`Session._feat_toast_icons`). Shot: `_screenshots/oct29/feats.png`.
- **Leaf Crown** (`import cosmetics`): the redo sheet re-split and re-fitted. Auto-fit put the wreath on top of the hair, so it has a hand fit
  in `assets/art/cosmetics/hats/fit.json` (width 1.25, sunk to the brow; eyes clear in every direction). Shots
  `_screenshots/oct29/hat_leafcrown.png` (auto) and `hat_leafcrown_fit.png` (final, all five directions walking). The importer's NPC
  manifest rewrite was reverted (gotcha: it drops head anchors).
- **NPC sprites** (`import npc sprites`; rows NP-PRIMM, NP-DUMPWORKER in `npc_sprite_batch.csv`, rel height 1.0 as catalogued): the three
  Dump farmhands (bark.worker_1..3) are the mole set with a slight tint each (`HeapScene.WORKER_SET`, the 3D models stay the fallback);
  postgame Primm in the Crease draws SPR-PRIMM by himself (freed-NPC entries use any imported set). Manifest: the old entries kept, the
  two new sets added. Shots: `_screenshots/oct29/p2_primm_crease.png`, `p2_dump_worker.png` (Worker 1 stands behind the wind pump, an
  existing spot; only his face shows from the default camera).
- Checks: GUT core 1490 + 1 pending, ui 242, root 286, world 418 (the sprite-rollout test now names Primm as the second exception after
  the Doppelganger); Dump walk smoke OK; structure budget met. Test `tests/test_art_import_oct29.gd`.

## Part 3 - zone pieces

Kit rows: `node tools/kit_rows_oct29.js` (new sheets `data/source/openingforest_kit.csv` and `town_kit.csv`; rows added to gainlands / dna /
buffet / heap / capital; DUMP-HERO-JUNK-MOUNTAIN's lock CONCEPT -> CUTOUT since the redo is a painted cut-out). `town` reads the Drive's
`Approved_EnvKit` through `zonekit_folders` (its report lists the ENV-* files there as "unmatched": they belong to the env kit). Imported with
`bash tools/import_zone_kit.sh <zone> --only=<the new ids>` (the old kit entries untouched; CAP-PATH-WHITE re-imported as the real texture).
Backdrop strips are data: `node tools/kit_looks_oct29.js` writes them as `kit_cards` into `data/art/zone_looks.json`. Hand-placed pieces go
through `KitPieces` (`world/kit/kit_pieces.gd`: a standing card, a wall picture, a ground picture; nothing placed when the art is missing).

### 3a - Opening Forest, Crosspath, Gainlands

| Area | What | Where / how |
|---|---|---|
| Opening Forest | OF-HERO-CAVE-MOUTH | 6.6 m card just in front of the rock arch (`StartingAreaBuilder._build_kit_pieces`), lifted 1.7x out of the teal mood so the way forward reads; the mouth's blocker unchanged |
| | OF-TREE-GIANT-01..03 | 15-17 m cards beyond the west and east treeline (outside the floor, never on the camera side) |
| | OF-BD-TORCHLINE | kit card north, ring 0, lifted 16 m; from the play camera the canopy hides it (it shows only where the sky opens) |
| | OF-PROP-LAB-HATCH | postgame: the painted hatch (2.1 m) lies where the steel disc was; disc, ring and handle are left out, the light stays |
| Crosspath | TOWN-HERO-FOUNTAIN | the royal-crest fountain card (5.8 m) replaces the stone model in the square; same blocker and anchor |
| | TOWN-SHEET-FREED-BANNERS-01..04 | one Path banner per freed zone on the square's lamp posts (`TownScene._hang_freed_banners`; shot arg `--banners=true` shows all four) |
| | TOWN-BD-HORIZON | kit card north, ring 2 |
| Gainlands | GAIN-HERO-HAMSTER-WHEEL | 11 m card where the 3D wheel stood; the model stays hidden for its blocking circles |
| | GAIN-SHEET-FLOATING-ISLANDS-01..03 | a painted islet floating beyond and above each walkable island (decor, never walkable) |
| | GAIN-DEC-REGIME-POSTERS | four posters on the gym hall's front wall either side of the door |
| | GAIN-BD-HOUSE-OF-GAINS | kit card north, ring 1, in front of the mesas |

Shots (`_screenshots/oct29/`): `before_forest` / `after_forest`, `p3_forest_cave`; `before_town` / `after_town`; `before_gainlands` /
`after_gainlands`, `p3_gain_hall` (`p3_gain_wheel` caught a roamer and shows the battle instead). Checks: GUT world 418 (the Buffet and D.N.A.
skyline tests now expect the new strips), Crosspath / Gainlands walk smokes OK, prologue smoke OK, structure OK, frame budgets met on the
re-run (first run: p99 noise and Crosspath Medium 841 vs 840 draw calls, then 839).
