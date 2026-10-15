# The Endless Buffet slice: the zone remade with its approved kit

The Endless Buffet (area id `buffet`, zone id `gourmand`, `scenes/buffet_zone.tscn`) remade with `Approved_ZoneKits/Buffet` by the rollout playbook (`docs/art/zone_rollout_playbook.md`), with the Gainlands and D.N.A. lessons (the declutter rules of section 5) applied from the start. The Endless Buffet is ONE walkable zone: there are no sub-areas and no walkable dungeon interiors (`docs/design/subarea_removal.md`); its dungeons are node maps entered from the zone. Gameplay, quests, NPC logic and the camera system are untouched. Judgment calls are BF-1... in `docs/design/open_questions.md`.

## The region mapping (fixed before the work started)

The five `PAINTOVER-BUFFET-*` images show regions of the one zone. Each paint-over maps onto the zone's existing regions (`BuffetLayout._areas`) by what fits best; no quest content moved. Coordinates are metres, x east, z south (north is up the screen, where the Test Kitchen stands).

| Paint-over | Existing regions of the zone (unchanged positions) | Hero landmark | Notes |
|---|---|---|---|
| **HUB** (the Grand Dining Hall) | The Grand Pantry hub (50, 64) with the arrival at the table's south edge, Basil, Tarragon, Madame Mirepoix, the Hearty Meal, the Grand Oven, the Soup Fountain, the fortune cookies, Old Meatloaf, the Rift Express; the Candy Field (82, 62: Chef Flambe's Dinner in a Dash stage, the Taste-Test Station) joins it as the Dining Hall's east terrace (the show kitchen) | the Test Kitchen seen across the whole zone; the arrival bridge | the paint-over's water in the foreground is the moat the way in crosses |
| **MASHED-POTATO-HILLS** | The Salt Flats (36, 52), the Mashed Potato Meadow between the hub and the river, Butter Butte (68, 54, the butter pat and the honey), the Gravy River with its three crossings (the two crouton rafts and the lazy susan) and the Gravy Bank (50, 35) up to the golem gates | **BUFF-HERO-POTATO-PEAK** as a view beyond the west rim where the Gravy River leaves the table (-20, 46): its gravy streams feed the river | the paint-over puts the Peak on the left and the Test Kitchen far right: looking north from the west meadow does exactly that |
| **BROCCOLI-FOREST** | Broccoli Forest (17, 61): Professor Pate's bread gazebo and the quiz, the truffle and basil pickups, the loaf chest | **BUFF-HERO-BROCCOLI-GIANT** at the forest's west edge (7, 63.5), its canopy over the rim | the windmill at the paint-over's left edge is a Gainlands piece and is not matched |
| **BAKERY-DISTRICT** | Layer-Cake Town (50, 17), the cake square behind Sir Loin's gate: the Test Kitchen gate (57, 10), the cake chest, the crust chest; the two gated yards either side belong to it too: the Cheddar Cliffs (20, 17, the cheese end) and the Pancake Plateau (80, 18, the pancake end with the Mystery Stew Pot) | **BUFF-HERO-CAKE-CATHEDRAL** in the square's west half (38.5, 22); **BUFF-HERO-TEST-KITCHEN** beyond the north rim behind the gate (57, -14.5) | the paint-over's bakery cottages replace the layer-cake stand-ins in Part C |
| **OMAKASE-CLIFFS** | The Walk-In Freezer door (44, 10) in the north-west corner of the cake square. The zone has two dungeons (`data/dungeons/dungeons.json`): D-TTK the Test Kitchen (main) and S-GOUR Omakase (side); the Walk-In Freezer door is the entrance that opens the Omakase node map (`ZoneScene._ask_mini_dungeon` through `DungeonCatalog.side_for_zone`), so the Omakase Cliffs are a white-stone terrace round that door, grown within the square's footprint | **BUFF-HERO-OMAKASE-PAVILION** over the freezer door (43, 6.5): the steel door sits in the pavilion's stone base where the spot stands | the paint-over's sea of rice and its far-left Test Kitchen cannot both be matched from this corner (the Test Kitchen stands right beside it); BF-2 |

What the brief lists as three entrances (the Walk-In Freezer, the Test Kitchen, the Omakase) are two: the Walk-In Freezer door *is* the way into the Omakase. Nothing was added or moved.

## Part A: import

- `bash tools/import_zone_kit.sh buffet`: 28 imported, 0 missing, 6 unmatched files (the five paint-overs and `Grand Dining Hall at Dusk.png`, none with a sheet row: the paint-overs are used from `docs/art/paintovers/`, the dusk picture is a mood reference), one note: `BUFF-SKY-DINNER` is opaque (a full-frame sky, used as the `sky.panorama` of the mood like the D.N.A. gloom). Report: `docs/art/zone_kits/buffet_import_report.md`. The paint-overs sat in the kit folder, not in `Paintovers/` (BF-1).
- Style: every image is painted (soft cel-shaded, clean shapes); nothing reads as pixel art.
- Hand numbers in `data/art/zone_kits/buffet.json`: card heights (broccoli 5.5 m, cauliflower 4.8, herb 1.3, leek 2.1, cloche 1.0, pot 1.6, cutlery 3.4, flour 1.2, cake stand 1.4), window and awning widths, and the aliases of the painted textures the zone reuses (TEX-BUFF-MASHED / -FROSTING / -BISCUIT / -CHEESE / -GRAVY / -CRUMBSOIL, DEC-CRUMBS, DEC-SAUCE).
- Hero landmarks: `world/buffet/buffet_landmarks.gd` (registered in `HeroLandmarks.BUILDERS` under `BUFF-HERO-`), placed by `BuffetBuilder._build_landmarks` at `BuffetLayout.TEST_KITCHEN` / `POTATO_PEAK` / `CAKE_CATHEDRAL` / `BROCCOLI_GIANT` / `OMAKASE_PAVILION` with flat kept-clear ground (`LANDMARK_SPOTS`). The freezer box and the taped kitchen door stand-ins are gone.
- Sky and backdrop: `data/art/zone_looks.json` buffet: `sky.panorama` BUFF-SKY-DINNER (mix 0.82), three BUFF-BD-CAKE cards on the near ring (north, east, west); the sea plane is off (it flooded the table, BF-3).
- Tests: `tests/world/test_buffet_slice.gd`, `test_zone_kit.gd` (the Buffet registry).


| Part A | Before (the zone as found) | After Part A |
|---|---|---|
| The hub at the paint-over camera (Cinematic / Normal) | ![](buffet_slice/before_PO-BUFFET-HUB.jpg) | ![](buffet_slice/a_PO-BUFFET-HUB.jpg) |
| The 9 camera combinations | ![](buffet_slice/before_buffet.jpg) | ![](buffet_slice/a_buffet.jpg) |
| The Test Kitchen gate (main_dungeon) | ![](buffet_slice/before_region_main_dungeon.jpg) | ![](buffet_slice/a_region_main_dungeon.jpg) |
| The Walk-In Freezer door (mini_dungeon) | ![](buffet_slice/before_region_mini_dungeon.jpg) | ![](buffet_slice/a_region_mini_dungeon.jpg) |
| Broccoli Forest (quiz) | ![](buffet_slice/before_region_quiz.jpg) | ![](buffet_slice/a_region_quiz.jpg) |
| The Gravy Bank (bank_center) | ![](buffet_slice/before_region_bank_center.jpg) | ![](buffet_slice/a_region_bank_center.jpg) |

The "before" shots show the sea plane flooding the table (BF-3), the taped pink box with its lettered plate at the Test Kitchen, the white freezer box, and the Kenney scatter.

| The five landmarks on the kit bench (`tools/kit_bench.tscn --landmarks=<id> --zone=buffet`) | |
|---|---|
| ![](buffet_slice/bench_test-kitchen.jpg) The Test Kitchen (60 x 30 x 34 m) | ![](buffet_slice/bench_cake-cathedral.jpg) The Cake Cathedral (11 x 24 x 11 m) |
| ![](buffet_slice/bench_potato-peak.jpg) Potato Peak (36 x 22 x 36 m) | ![](buffet_slice/bench_broccoli-giant.jpg) The Broccoli Giant (16 x 18 x 16 m) |
| ![](buffet_slice/bench_omakase-pavilion.jpg) The Omakase Pavilion (8 x 7 x 5 m) | ![](buffet_slice/kit_sheet.jpg) The kit on a checker: the sliced doors, windows, signs and awnings, the trees, plants, props and decals |

Checks: 1544 GUT tests, 1541 passing (the one failure is GC-6, the local camera FOV, pre-existing); `bash tools/fps.sh res://scenes/buffet_zone.tscn 1`: 60.0 fps Medium (773 draw calls); `bash tools/run_seventh_brief_final_smoke.sh buffet`: passes (109 checks; its stale Walk-In Freezer step updated for the sealed side dungeon, BF-13).

## Part B: layout and declutter

The playbook's declutter rules (section 5) applied to the one zone before any dressing; every anchor, chest, pad, raft, mesa and gate stays where it was.

- **The way in is walked** (BF-8): a biscuit bridge (`BuffetLandmarks.entrance_bridge`) from the table's south rim out over a gravy moat; a fresh visit starts on it facing north, the exit spot waits at the far landing, walking off the landing leaves for town (`BuffetScene._update_bridge_exit`), the fork arch and the light pillar are gone, and the Buffet's town passage lost its far glow. Waking after a faint puts the hero in the plaza.
- **The hub** (BF-9): an empty plaza (8.5 m) round the Soup Fountain; the hub's things keep their rim positions; the Grand Dining Hall is two oven-brick kitchen wings (glowing oven arches, sliced sweet windows, copper domes, steaming chimneys, a banquet table under a tablecloth awning) north of the plaza with the road to the river between them; the five cabinets, the pot, the standing forks, the donut arches and the generic Kenney scatter are gone.
- **Routes** (BF-12): main roads 4.2 m, spurs 3.6 m, nothing solid within 2.4 m of a route edge, 5.5 m of open ground round every anchor, every region on a loop.
- **Trees and props** (BF-12): the forest keeps 30 broccoli and 12 cauliflower as painted kit cards (one MultiMesh field each, they fade per card); every other tree stands in a framing group at an edge; the lollipops, cabbages, cupcakes, muffins, cheese blocks, sundaes, standing cutlery and the layer-cake stand-ins are gone.
- **The district walls** (BF-11): the 90 fork pickets and 50 divider posts are one knee-high biscuit wall with a herb hedge (`BuffetLandmarks.district_walls`); the blockers and the three gate gaps are unchanged.
- **Boards** (BF-9): 37 -> 11, none a memo, every one with a pictogram; the two dungeon doors have no lettered plate (`no_plate`), their boards carry the icons.
- **Crossings** (BF-10): biscuit landing stages with meringue posts and lanterns on both banks of the two raft lanes and the lazy susan; the rafts and the susan stay (gameplay).
- **Occlusion**: the tree cards fade per card in their shader, the walls are knee-high and never fade, the wings, the pavilion and the stages fade as a group through the OcclusionFader (plain transparency, no dither), the bridge deck and the landmarks never dissolve.

| Part B | After Part A | After Part B |
|---|---|---|
| The hub at the paint-over camera (the plaza, where the painter stood) | ![](buffet_slice/a_PO-BUFFET-HUB.jpg) | ![](buffet_slice/b_PO-BUFFET-HUB.jpg) |
| The 9 camera combinations (the arrival on the bridge) | ![](buffet_slice/a_buffet.jpg) | ![](buffet_slice/b_buffet.jpg) |
| The plaza from the fountain (hub) | | ![](buffet_slice/b_region_hub.jpg) |
| The way in (exit) | | ![](buffet_slice/b_region_exit.jpg) |
| The Test Kitchen gate (main_dungeon) | ![](buffet_slice/a_region_main_dungeon.jpg) | ![](buffet_slice/b_region_main_dungeon.jpg) |
| The Walk-In Freezer door (mini_dungeon) | ![](buffet_slice/a_region_mini_dungeon.jpg) | ![](buffet_slice/b_region_mini_dungeon.jpg) |
| Broccoli Forest (quiz) | ![](buffet_slice/a_region_quiz.jpg) | ![](buffet_slice/b_region_quiz.jpg) |
| The Gravy Bank (bank_center) | ![](buffet_slice/a_region_bank_center.jpg) | ![](buffet_slice/b_region_bank_center.jpg) |
| The show kitchen (minigame) | | ![](buffet_slice/b_region_minigame.jpg) |

Checks: 1552 GUT tests, 1551 passing (GC-6 pre-existing); the walkability probe reaches every key location; `bash tools/fps.sh res://scenes/buffet_zone.tscn 1`: 60.0 fps Medium (432 draw calls, was 773); the new windowed walk smoke `bash tools/run_buffet_walk_smoke.sh` (about 4 minutes, real input: the bridge, the plaza, every NPC and the vendor, every interactable, the quiz, Dinner in a Dash, the taste test, the stew pot, the Walk-In Freezer sealed and unlocked, the Test Kitchen gate, the giant chest, the lever, the walk back out over the bridge to town) passes 85 checks; the long Buffet smoke found the two Part B regressions of BF-16 on its first run and its rerun was stopped by the machine's low-memory reaper, so it is rerun in Part E. Tests added in `tests/world/test_buffet_slice.gd` (routes, open ground, scatter, plaza, boards, the bridge, the fresh visit, the walls); `tests/core/zone/test_buffet.gd` lets the spawn and the exit stand on the bridge and floods as far as it.

## Part C: dress

Material swaps, three presets, six zone clusters as data, `BuffetDressing` (clusters at edges, kit decals), four preset buildings; the decluttered layout of Part B is kept (every cluster is refused on a route, in the plaza, at the bridge head or the forecourt, or within reach of an anchor or a chest, and tested so). BF-14, BF-15.

| Part C | After Part B | After Part C |
|---|---|---|
| The hub at the paint-over camera | ![](buffet_slice/b_PO-BUFFET-HUB.jpg) | ![](buffet_slice/c_PO-BUFFET-HUB.jpg) |
| The plaza from the fountain (hub) | ![](buffet_slice/b_region_hub.jpg) | ![](buffet_slice/c_region_hub.jpg) |
| The cake square: the bakery and the Cathedral (gate_quest) | | ![](buffet_slice/c_region_gate_quest.jpg) |
| The show kitchen (minigame) | ![](buffet_slice/b_region_minigame.jpg) | ![](buffet_slice/c_region_minigame.jpg) |
| The Walk-In Freezer door (mini_dungeon) | ![](buffet_slice/b_region_mini_dungeon.jpg) | ![](buffet_slice/c_region_mini_dungeon.jpg) |
| The kit bench: the three presets with the zone's swaps | | ![](buffet_slice/c_bench_presets.jpg) |

Checks: 66 Buffet GUT tests (the swaps land on the zone art untinted, the presets and clusters build, the three buildings and the twelve dressing spots stay clear of routes, chests and anchors); `bash tools/fps.sh res://scenes/buffet_zone.tscn 1`: 60.0 fps Medium (444 draw calls); the walk smoke passes (85 checks).

(Parts B-E follow below as they land.)
