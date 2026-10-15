# Sub-area removal: the audit (Part A)

Design rule correction (replaces the old Art Bible rule G-07): the only walkable, explorable areas in the game are the starting forest, the main town, the four Path zones (Gainlands, D.N.A., Endless Buffet, Verdant Dump) and the Capital (outside and inside). There are no sub-area scenes, no walkable dungeon interiors and no walkable antechambers. Every dungeon (main, mini and side) is node-based: an entrance in the zone opens the node map. Variety comes from regions within each zone.

This file lists everything the sub-area system put in the game before any of it is changed. The removal itself is Part B; what is kept inside the main zones is Part C; the docs and the verification are Part D. Decisions are logged as SR-1... in `docs/design/open_questions.md`.

## 1. What the system is

| Piece | Files | Used by anything else? |
|---|---|---|
| Data | `data/subareas/<area>/_zone.json` (10 areas: the style preset, the hub scene, the gates the hub shows, the sub-area list) and `data/subareas/<area>/<sub>.json` (40 blockouts: ground, paths, plazas, buildings, landmarks, clusters, scatter, flowers, water, decals, points of interest, exits, entries, spawn) | Only the sub-area code, the smokes, the doc generator and five tests |
| Definitions | `core/zone/subarea_defs.gd` (`SubAreaDefs`: AREAS, area / sub / gates / zone_id / hub_scene / areas_of_scene, the save token `sub:<area>/<sub>`) | `GameSession.scene_kind` / `resume_loaded_game` (the save token), `GainlandsLayout.keep_clear` (open ground round the gates), the three hub scenes (`SubAreaGates.install`), `tools/zone_docs.gd` |
| Rewards | `core/zone/subarea_rewards.gd` (`SubAreaRewards`: chest and shrine rewards drawn from the zone's own `chest_rewards` table by tier) | Only `SubAreaScene` |
| Scene | `scenes/sub_area.tscn` + `world/subarea/subarea_scene.gd` (`SubAreaScene`: loads a blockout, the points of interest, exits to the hub / another sub-area / another area / `dungeon:main` / `dungeon:lab`, the flags `sa_<area>_<sub>_<poi>`, saves `sub:<area>/<sub>`) | Only the gates, the session (save token) and the smokes |
| Map builder | `world/subarea/subarea_map.gd` (`SubAreaMap`: ground kinds, paths, edges incl. the D.N.A. balustrade, buildings, landmarks, clusters, scatter, flowers, decals, `pos3`) | `SubAreaScene`, `SubAreaGates` (`pos3`), the smokes, `test_dna_slice` (ground-kind assertion) |
| Hub gates | `world/subarea/subarea_gates.gd` (`SubAreaGates`: the arches with a light pillar and a pictogram in the hub, the locked Swolympus barrier, the prompt, E loads the sub-area) | Installed by `ZoneScene`, `TownScene`, `StartingAreaScene` |
| Landmark stand-ins | `world/subarea/landmark_kit.gd` (`LandmarkKit`: generic arch / tower / facade / mound / ... boxes, kit surfaces) and `world/subarea/hero_landmarks.gd` (`HeroLandmarks`: dispatches `GAIN-HERO-*` / `DNA-HERO-*` to the modelled builders) | **Yes, by the hubs**: the Gainlands (Swole Station platform, the distant Mount Swolympus, the House of Gains), the D.N.A. (the Hall of Final Approvals), the gates, `tools/kit_bench.gd`. These two stay (moved out of `world/subarea/`). |
| Zone styles | `data/zone_styles/castle_grounds.json` (no preset maps to it; sub-area only) and `data/zone_styles/pathology_lab.json` (the `lab` preset, also used by the Lab dungeon backdrop: stays). `ZoneStyles.AREAS` lists castle_grounds and pathology_lab. | The `lab` preset stays for the node-map backdrop; `castle_grounds.json` goes |
| Session | `GameSession.scene_kind()` returns `sub:<area>/<sub>` from a sub-area; `resume_loaded_game()` loads it back into the sub-area; `location_name()` / `can_save_now()` know the scene; `start_return_position` / `town_return_position` carry the gate return point (the town one is also used by the rift station) | The save token needs a migration (Part B) |
| Tools | `tools/subarea_smoke.gd/.tscn` + `tools/run_subarea_smoke.sh` (the sub-area e2e), the sub-area legs of `tools/gainlands_walk_smoke.gd` and `tools/dna_walk_smoke.gd`, `tools/zone_shots.gd` (paint-over inputs per sub-area, hub cameras for castle_grounds / pathology_lab), `tools/zone_docs.gd` + `zone_docs_vocab.gd` + `zone_docs.tscn` (generate `docs/zone_plans/*.md` and `docs/art/zone_kits/*.md` from the sub-area data) | The walk smokes keep their hub legs; the paint-over tool keeps the hub shot; the doc generator has nothing to generate from and goes |
| Tests | `tests/world/test_subareas.gd` (7), `test_subarea_scene.gd` (3), `test_subarea_gates.gd` (1), plus the sub-area parts of `test_gainlands_corrections.gd` (`test_subarea_data_stays_open`, the Swolympus gate test), `test_dna_slice.gd` (ground kinds), `test_icon_signs.gd` (gate icons), `test_icon_signs_hubs.gd` (the Verdant Dump name read from the area file) | The first three go; the others are rewritten against the hubs |
| Docs | Art Bible G-07 and the "Hub + sub-areas" line of every area, `docs/zone_rollout_playbook.md` (steps 1, 7, 13, 15, 22, 26, 27, the files table, section 6 keys), `docs/zone_plans/*.md` (10), `docs/art/zone_kits/*.md` (11 + ALL.md: paint-over rows per sub-area, hero landmark rows "replaces the stand-in in <sub>"), `docs/art/paintover_inputs/<area>/PO-<AREA>-<SUB>.png` (40 sub-area shots; the 10 hub shots stay), the reports `docs/art/gainlands_slice.md`, `gainlands_corrections.md`, `dna_slice.md` (history: a note each), `data/source/art_bible.csv` column "Hub + sub-areas" | Part D |

Nothing else loads a sub-area: no quest, hint, quest tracker entry, minimap marker or fast-travel destination names one. The quest summaries that say "Grave Row", "Transit Yards" and "Hungry Quarter" (`cap_burial`, `cap_wheels`, `cap_recipes`) and the audio registry rows with those zone names mean the Capital hub's own broken-service districts (which share the names), not the sub-areas; they stay. The sub-area vignette figures are placeholder characters, not `NpcRegistry` NPCs; no NPC was moved. Chest, lore and shrine state lives only in the flags `sa_<area>_<sub>_<poi>` (harmless once nothing reads them) and in `lore_pages_read`.

## 2. Walkable areas that are not main areas

| Walkable area | How it is reached | What is behind it | Dungeon entrance it duplicates |
|---|---|---|---|
| **The 32 sub-areas of the eight main areas** (town 4, forest 4, Gainlands 4, D.N.A. 4, Buffet 4, Dump 4, Capital outside 3, Capital inside 4) | Gate arches in the hub (`SubAreaGates`), then exits between sub-areas | Chests, shrines, lore boards, vistas, vignettes, four lever shortcuts, stand-in and modelled hero landmarks (table below) | none (they add places, not dungeons) |
| **Primm Castle Grounds** (4 scenes: Courtyard, Mirror Colonnade, Grand Stair, Palace Gardens; `preset: capital_inside`, `data/zone_styles/castle_grounds.json`) | From the Capital's Palace Approach sub-area (exit `area:castle_grounds/courtyard`); there is no gate in a hub | The Grand Stair's exit `dungeon:main` runs `Session.enter_main_dungeon()` (Primm's Castle node map); a courtyard, a colonnade with a lever, gardens with a pond | The Capital hub already has the `castle_door` spot ("Enter Primm's Castle", kind `main_dungeon`) in `CapitalZone` |
| **The Path-ology Lab antechamber** (5 scenes: Hatch Yard, Decontamination Corridor, Specimen Gallery, Records and Break Room, Glass Tank Hall; `preset: lab`) | A gate in the forest clearing at (6.4, 6.0) that appears once `lab_revealed` is set | The Hatch Yard and the Glass Tank Hall both exit to `dungeon:lab` (`Session.enter_lab()`, the D-LAB node map); the four wings hold the Lab's "one warm thing per room" lore (the child's drawing, the notes on the subject, the draining log) | The forest clearing already has the hatch (`StartingAreaScene._enter_lab`, "Descend into the Path-ology Lab", open once `lab_revealed`) |
| Mount Swolympus Trailhead + Sky Garden (Gainlands) | The trailhead gate is **locked** (coming soon, GC-11); the Sky Garden hangs off the Proving Grounds | Listed below; the S-BEEF side dungeon (the Iron Cavern) is a hub spot, node-based, sealed until the postgame | none |

Checked and not walkable areas: `scenes/zone_placeholder.tscn` (a stub `GameSession` can change to; no `ZoneDef` points at it any more), the dungeon node maps (`dungeon_map.tscn`, 2D), `dungeon_backdrop.gd` (the painted backdrop behind the node map, not walked), the dev scenes under `scenes/dev/` and `tools/*.tscn` (kit bench, look tests: not in the game). The Arena is a building in the town hub. The floating islands of the Gainlands are regions of the hub (thrower travel), not scenes.

## 3. Hero landmarks built for sub-areas

Modelled after approved concept art (a `has_model` builder exists):

| Id | Built for | Also in the hub today? | Part C plan |
|---|---|---|---|
| GAIN-HERO-WHEEL (14 x 14 x 6, spins) | Mill Fields | No (the hub has the smaller `GainlandsProps.wheel` hamster wheels) | Place as a region landmark of the hub's mill meadow |
| GAIN-HERO-CHAMPIONS-ARCH (12 x 8 x 1.6) | Proving Grounds | No | Place at the hub's studio / minigame region if it fits |
| GAIN-HERO-SKY-TREE (18 x 16 x 18) | Sky Garden | No | A distant view on an island or dropped |
| GAIN-HERO-TRAILHEAD-GATE (10 x 7 x 1.4) | Swolympus Trailhead | The locked hub gate is a `SubAreaGates` arch, not this model | Becomes the locked Mount Swolympus landmark in the hub (coming soon) |
| GAIN-HERO-SWOLYMPUS (38 x 30 x 22) | Swolympus Trailhead | Yes, in the distance beyond the north-east rim (GC-11) | Stays |
| GAIN-HERO-SWOLE-STATION, GAIN-HERO-HOUSE-OF-GAINS | the hub | Yes | Stay |
| DNA-HERO-FILING-TOWER (10 x 22 x 6) | Cubicle Fields | No | Place in the hub's cubicle farms region |
| DNA-HERO-ENDLESS-QUEUE (56 x 3 x 2) | The Queue | No | Place along the hub's queue / Requisitions wall if it fits |
| DNA-HERO-RECORDS-STAIR (9 x 5 x 8) | Records Basement | No | Place in the hub's records wing (beside Sub-Basement 3) if it fits |
| DNA-HERO-FINAL-APPROVALS | the hub and four sub-areas (far) | Yes (the main dungeon) | Stays |

Stand-ins only (a concept id on a `LandmarkKit` box; no model exists): BUFF-HERO-POTATO-PEAK, BROCCOLI-GIANT, CAKE-CATHEDRAL, OMAKASE-PAVILION; HEAP-HERO-JUNK-MOUNTAIN, RUSTY-WINDMILL, ROTHEART, TRASH-PANDA-THRONE; CAPO-HERO-RIFT-A / RIFT-B, BROKEN-WATCHTOWER, SERVICE-TUNNEL; CAPI-HERO-TRAM-SHED, IDENTICAL-ROW, GRAVE-ROW, PALACE-FACADE; CAST-HERO-PALACE-FACADE, MIRROR-COLONNADE, GRAND-STAIR, CROOKED-ROSE; TOWN-HERO-WASHING-TOWER, DOCK, CHAPEL-LAWN, ARENA-FACADE; START-HERO-ROPE-BRIDGE, WAYSTONE-OLD, FALLEN-GIANT, CAVE-MOUTH, TUNNEL-ARCH; LAB-HERO-HIDDEN-HATCH, DECON-ARCH, SPECIMEN-WALL, BREAK-ROOM, TANK-RED / YELLOW / PURPLE / GREEN. These go with their data; the ids stay in the kit docs only where the thing exists in the main zone (Part D).

## 4. Every sub-area and what it contains

40 sub-areas; 48 chests, 38 shrines, 41 lore boards, 36 vistas, 33 vignettes, 4 lever shortcuts. Every chest and shrine reward came from the zone's own `chest_rewards` table (no new economy), so removing them removes no unique item, card, equipment, cosmetic or pack.

### Crosspath (`main_town`, hub `town.tscn`)

Gates in the hub: Residential Lanes (4, 22); Lakeshore and Docks (63, 24); Chapel Hill (-5, 38); Arena District (32, 47).

| Sub-area | Size | Hero landmark (concept id) | Other stand-ins | Points of interest | Exits |
|---|---|---|---|---|---|
| Residential Lanes (`residential_lanes`) | 72 x 60 | TOWN-HERO-WASHING-TOWER (stand-in) | - | chest: Cellar Hatch (small); lore: Lane Notice; vignette: Neighbour; vista: Rooftops; shrine: Hearth Shrine | hub, chapel_hill |
| Lakeshore and Docks (`lakeshore_docks`) | 76 x 60 | TOWN-HERO-DOCK (stand-in) | lighthouse, boat | chest: Tide Crate (medium); chest: Net Basket (small); vignette: Angler; vista: End of the Pier; lore: Ferry Timetable | hub, arena_district |
| Chapel Hill (`chapel_hill`) | 68 x 60 | TOWN-HERO-CHAPEL-LAWN (stand-in) | stone_a, stone_b, stone_c, stone_d | chest: Sexton Box (small); lore: Weathered Stone; vignette: Gardener; shrine: Quiet Shrine; vista: Hill Crest | hub, residential_lanes |
| Arena District (`arena_district`) | 74 x 62 | TOWN-HERO-ARENA-FACADE (stand-in) | banner_w, banner_e | chest: Gladiator Locker (medium); lore: Fixture Board; vignette: Sword Seller; shrine: Victor Shrine; vista: Gate View | hub, lakeshore_docks |

### The Starting Forest (`starting_forest`, hub `starting_area.tscn`)

Gates in the hub: The Old Path (7.9, 4.6); Mossy Hollow (1.4, 3.6); Cave Mouth (6.4, 0) (all gates need the flag `trial_cleared`).

| Sub-area | Size | Hero landmark (concept id) | Other stand-ins | Points of interest | Exits |
|---|---|---|---|---|---|
| The Old Path (`old_path`) | 72 x 64 | START-HERO-ROPE-BRIDGE (stand-in), START-HERO-WAYSTONE-OLD (stand-in) | fallen_log | chest: Hollow Stump (small); vista: The Rope Bridge; lore: Carved Marker; vignette: Fellow Traveller; shrine: Wayside Shrine | hub, mossy_hollow |
| Mossy Hollow (`mossy_hollow`) | 64 x 56 | START-HERO-FALLEN-GIANT (stand-in) | root_ball, mushroom_ring | chest: Hollow Trunk (medium); lore: Ring of Mushrooms; vignette: Hollow Hermit; vista: On the Fallen Giant; shrine: Mossy Shrine | hub, old_path, cave_mouth |
| Cave Mouth (`cave_mouth`) | 60 x 56 | START-HERO-CAVE-MOUTH (stand-in) | cave_hole, ruined_shrine, boulder_a, boulder_b | chest: Pilgrim Cache (small); lore: Cave Marker; shortcut: Hidden Lever; vista: Before the Dark; shrine: Ruined Shrine | hub, mossy_hollow, hidden_tunnel |
| The Hidden Tunnel (`hidden_tunnel`) | 48 x 40 | START-HERO-TUNNEL-ARCH (stand-in) | wall_n, wall_s, wall_w, wall_e | chest: Forgotten Strongbox (large); lore: Scratched Tally; shrine: Lantern Shrine; vista: Glow Roots | cave_mouth |

### The Gainlands (`gainlands`, hub `gainlands_zone.tscn`)

Gates in the hub: Proving Grounds (38, 73); Mount Swolympus (86, 31), locked.

| Sub-area | Size | Hero landmark (concept id) | Other stand-ins | Points of interest | Exits |
|---|---|---|---|---|---|
| The Proving Grounds (`proving_grounds`) | 76 x 64 | GAIN-HERO-CHAMPIONS-ARCH (modelled) | stand_w, stand_e, scoreboard | chest: Gym Bag (small); chest: Trophy Crate (medium); lore: Record Board; vignette: Coach; shrine: Pump Shrine; vista: Overlook | hub, sky_garden, mill_fields |
| Mill Fields (`mill_fields`) | 80 x 64 | GAIN-HERO-WHEEL (modelled) | windmill_small | chest: Grain Sack (small); chest: Millstone Cache (medium); lore: Miller Log; vignette: Wheel Keeper; shrine: Harvest Shrine | proving_grounds |
| Mount Swolympus Trailhead (`swolympus_trailhead`) | 72 x 72 | GAIN-HERO-SWOLYMPUS (modelled), GAIN-HERO-TRAILHEAD-GATE (modelled) | statue_flex, boulder_wall, shack | chest: Hiker Pack (medium); lore: Trail Notice; vignette: Gift Shop Clerk; shortcut: Rock Lever; vista: Foot of the Mountain | proving_grounds, hub, sky_garden |
| The Sky Garden (secret) (`sky_garden`) | 56 x 48 | GAIN-HERO-SKY-TREE (modelled) | float_a, float_b | chest: Gardener Chest (large); shrine: Rare Bloom Shrine; lore: Gardener Note; vista: Above the Clouds | proving_grounds |

### The Department of Necrotic Affairs (`dna`, hub `dna_zone.tscn`)

Gates in the hub: Cubicle Fields (55.5, 56.5); The Queue (34.5, 58.5); Records Basement (70.5, 24.5).

| Sub-area | Size | Hero landmark (concept id) | Other stand-ins | Points of interest | Exits |
|---|---|---|---|---|---|
| Cubicle Fields (`cubicle_fields`) | 80 x 64 | DNA-HERO-FILING-TOWER (modelled), DNA-HERO-FINAL-APPROVALS (modelled) (far) | partition_1, partition_2, partition_3, partition_4, water_cooler | chest: Desk Drawer (small); lore: Memo; vignette: Junior Associate; vista: Overlook; shrine: Approvals Shrine | hub, the_queue |
| The Queue (`the_queue`) | 76 x 56 | DNA-HERO-ENDLESS-QUEUE (modelled), DNA-HERO-FINAL-APPROVALS (modelled) (far) | rope_row_a, window_wall, ticket_machine | chest: Lost Property (medium); lore: Number Board; vignette: Veteran of the Line; shrine: Patience Shrine; vista: End of the Line | hub, cubicle_fields, records_basement |
| Records Basement (`records_basement`) | 72 x 60 | DNA-HERO-RECORDS-STAIR (modelled), DNA-HERO-FINAL-APPROVALS (modelled) (far) | shelf_a, shelf_b, shelf_c, shelf_d, ghost_lamp_a, ghost_lamp_b | chest: Sealed Folder (medium); chest: Cold Cabinet (small); lore: Filed Complaint; vignette: Archivist; shrine: Stamp Shrine | hub, the_queue, executive_approach |
| Executive Approach (`executive_approach`) | 70 x 64 | DNA-HERO-FINAL-APPROVALS (modelled) | col_w, col_e, desk_reception | chest: Executive Safe (large); lore: Plaque; vignette: Door Usher; shrine: Stamp of Approval; vista: Under the Facade | records_basement |

### The Endless Buffet (`buffet`, hub `buffet_zone.tscn`)

Gates in the hub: Bakery District (72.5, 71.5); Broccoli Forest (22, 66); Mashed Potato Hills (82, 56).

| Sub-area | Size | Hero landmark (concept id) | Other stand-ins | Points of interest | Exits |
|---|---|---|---|---|---|
| Mashed Potato Hills (`mashed_potato_hills`) | 80 x 64 | BUFF-HERO-POTATO-PEAK (stand-in) | butter_dome, gravy_fall | chest: Tureen (medium); chest: Butter Crock (small); lore: Recipe Card; vignette: Hill Cook; shrine: Gravy Boat Shrine; vista: Crest of the Hills | hub, bakery_district, omakase_cliffs |
| Broccoli Forest (`broccoli_forest`) | 72 x 64 | BUFF-HERO-BROCCOLI-GIANT (stand-in) | cheese_boulder, pepper_mill | chest: Colander Chest (medium); lore: Forager Notes; vignette: Forager; shrine: Herb Shrine; vista: Under the Canopy | hub, bakery_district |
| Bakery District (`bakery_district`) | 76 x 62 | BUFF-HERO-CAKE-CATHEDRAL (stand-in) | copper_dome | chest: Proving Drawer (medium); lore: Day Menu; vignette: Master Baker; shrine: Rising Shrine; vista: Sugar Spires | hub, mashed_potato_hills, broccoli_forest |
| Omakase Cliffs (`omakase_cliffs`) | 68 x 60 | BUFF-HERO-OMAKASE-PAVILION (stand-in) | terrace_a, terrace_b, lantern_row | chest: Lacquer Box (large); lore: Course Card; vignette: Itamae; shrine: Chef Knife Shrine; vista: Terrace Edge | mashed_potato_hills |

### The Verdant Dump (`heap`, hub `heap_zone.tscn`)

Gates in the hub: Farm Rows (12, 62); Junk Mountains (84, 62); Wildflower Wetlands (60, 54).

| Sub-area | Size | Hero landmark (concept id) | Other stand-ins | Points of interest | Exits |
|---|---|---|---|---|---|
| Junk Mountains (`junk_mountains`) | 76 x 66 | HEAP-HERO-JUNK-MOUNTAIN (stand-in) | heap_a, heap_b, fridge_tower | chest: Dented Safe (medium); chest: Suitcase (small); lore: Collector Note; vignette: Picker; vista: Summit Seat; shrine: Hubcap Shrine | hub, throne_approach |
| Farm Rows (`farm_rows`) | 76 x 62 | HEAP-HERO-RUSTY-WINDMILL (stand-in) | tyre_bed_a, tyre_bed_b, car_roof | chest: Seed Tin (small); chest: Hubcap Hoard (medium); lore: Rota Board; vignette: Tyre Farmer; shrine: Scarecrow Shrine | hub, wildflower_wetlands |
| Wildflower Wetlands (`wildflower_wetlands`) | 72 x 60 | HEAP-HERO-ROTHEART (stand-in) | boardwalk | chest: Reed Basket (medium); lore: Naturalist Page; vignette: Frog Philosopher; shrine: Bog Shrine; vista: Firefly Hour | farm_rows, throne_approach |
| Throne Approach (`throne_approach`) | 72 x 66 | HEAP-HERO-TRASH-PANDA-THRONE (stand-in) | throne_back, door_arch_a, door_arch_b | chest: Royal Hamper (large); lore: Proclamation; vignette: Herald; shrine: Bottlecap Shrine; vista: Look Back | junk_mountains, wildflower_wetlands |

### The Capital: Outside (`capital_outside`, hub `capital_zone.tscn`)

Gates in the hub: Rift Fields (28.9, 93.2); Ruined Outpost (100, 92); Tunnel Entrance (74.1, 93.4).

| Sub-area | Size | Hero landmark (concept id) | Other stand-ins | Points of interest | Exits |
|---|---|---|---|---|---|
| Rift Fields (`rift_fields`) | 80 x 64 | CAPO-HERO-RIFT-A (stand-in), CAPO-HERO-RIFT-B (stand-in) | wall_far, crystal_a, crystal_b, crystal_c | chest: Scavenger Pack (medium); lore: Survey Stake; vignette: Rift Scout; shrine: Rift Shard Shrine; vista: Under the Walls | hub, ruined_outpost |
| Ruined Outpost (`ruined_outpost`) | 72 x 60 | CAPO-HERO-BROKEN-WATCHTOWER (stand-in) | broken_wall, cart_wreck | chest: Duty Locker (small); lore: Watch Log; vignette: Last Sentry; shrine: Soldier Shrine; vista: Rooftop of the Hall | hub, rift_fields, tunnel_entrance |
| Tunnel Entrance (`tunnel_entrance`) | 64 x 56 | CAPO-HERO-SERVICE-TUNNEL (stand-in) | great_wall, pipe_a, pipe_b, slab_n, slab_s, slab_w | chest: Maintenance Chest (medium); chest: Walled-up Cache (large); shortcut: Wall Lever; lore: Service Plate; shrine: Gear Shrine; vista: Foot of the Wall | hub, ruined_outpost |

### The Capital: Inside (`capital_inside`, hub `capital_zone.tscn`)

Gates in the hub: Transit Yards (100, 56); Hungry Quarter (101.2, 34.2); Grave Row (22, 34); Palace Approach (61, 18).

| Sub-area | Size | Hero landmark (concept id) | Other stand-ins | Points of interest | Exits |
|---|---|---|---|---|---|
| Transit Yards (`transit_yards`) | 80 x 62 | CAPI-HERO-TRAM-SHED (stand-in) | tram_a, tram_b, clock_tower | chest: Lost Umbrella Bin (small); lore: Timetable; vignette: Conductor; shrine: Platform Shrine; vista: Platform Nine | hub, hungry_quarter |
| Hungry Quarter (`hungry_quarter`) | 76 x 60 | CAPI-HERO-IDENTICAL-ROW (stand-in) | statue_fountain | chest: Empty Breadbox (medium); lore: Window Menu; vignette: Resident; shrine: Plate Shrine; vista: Window Row | hub, transit_yards, grave_row |
| Grave Row (`grave_row`) | 72 x 60 | CAPI-HERO-GRAVE-ROW (stand-in) | plot_a, plot_b, plot_c, plot_d, plot_e, plot_f | chest: Wreath Box (medium); lore: Polished Name; vignette: Plot Keeper; shrine: Unwritten Shrine; vista: End of the Row | hub, hungry_quarter, palace_approach |
| Palace Approach (`palace_approach`) | 70 x 70 | CAPI-HERO-PALACE-FACADE (stand-in) | lamp_row_w, lamp_row_e, primm_statue | chest: Gilded Hamper (large); lore: Plaque; vignette: Palace Herald; shrine: Mirror Shrine; vista: Castle View | hub, grave_row, castle_grounds/courtyard |

### Primm Castle Grounds (`castle_grounds`, hub `capital_zone.tscn`)

Gates in the hub: none; entered through `courtyard` from another sub-area.

| Sub-area | Size | Hero landmark (concept id) | Other stand-ins | Points of interest | Exits |
|---|---|---|---|---|---|
| The Courtyard (`courtyard`) | 76 x 66 | CAST-HERO-PALACE-FACADE (stand-in) | tower_w, tower_e, fountain_mirror, statue_w, statue_e | chest: Guard Locker (medium); lore: Dedication; vignette: Gate Guard; shrine: Crown Shrine; vista: In the Reflection | capital_inside/palace_approach, mirror_colonnade |
| Mirror Colonnade (`mirror_colonnade`) | 74 x 56 | CAST-HERO-MIRROR-COLONNADE (stand-in) | colonnade_south, mirror_a, mirror_b, mirror_c, garden_gate | chest: Frame Case (small); shortcut: Silvered Lever; lore: Hand Mirror; shrine: Glass Shrine; vista: Looking Glass | courtyard, grand_stair, palace_gardens |
| The Grand Stair (`grand_stair`) | 72 x 66 | CAST-HERO-GRAND-STAIR (stand-in) | door_frame, flank_w, flank_e | chest: Regal Coffer (large); lore: Notice at the Foot; shrine: Last Rest Shrine; vista: Foot of the Stair | mirror_colonnade, dungeon:main |
| Palace Gardens (`palace_gardens`) | 60 x 52 | CAST-HERO-CROOKED-ROSE (stand-in) | topiary_a, topiary_b, topiary_c, topiary_d | chest: Gardener Strongbox (large); lore: Gardener Note; shrine: Hidden Rose Shrine; vista: Mirror Pond | mirror_colonnade |

### The Path-ology Lab (`pathology_lab`, hub `starting_area.tscn`)

Gates in the hub: The Hatch Yard (6.4, 6), needs lab_revealed; entered through `hatch_yard` from another sub-area.

| Sub-area | Size | Hero landmark (concept id) | Other stand-ins | Points of interest | Exits |
|---|---|---|---|---|---|
| The Hatch Yard (`hatch_yard`) | 64 x 56 | LAB-HERO-HIDDEN-HATCH (stand-in) | vent_stack, tank_a, tank_b, root_wall | chest: Supply Case (medium); lore: Maintenance Tag; vignette: Rescuer; shrine: Lantern Shrine; vista: Pale Ferns | hub, decontamination_corridor, dungeon:lab |
| Decontamination Corridor (`decontamination_corridor`) | 72 x 40 | LAB-HERO-DECON-ARCH (stand-in) | wall_n, wall_s, locker_a, locker_b, root_a | chest: Changing Locker (small); lore: Procedure Sheet; vignette: Decontamination Tech; shrine: Sterile Shrine; vista: Cracked Tile | hatch_yard, specimen_gallery |
| Specimen Gallery (`specimen_gallery`) | 72 x 56 | LAB-HERO-SPECIMEN-WALL (stand-in) | case_a, case_b, case_c, case_d, case_e | chest: Cold Store (medium); lore: Specimen Card; vignette: Orderly; shrine: Specimen Shrine; vista: Down the Rows | decontamination_corridor, records_break_room, glass_tank_hall |
| Records and Break Room (`records_break_room`) | 60 x 52 | LAB-HERO-BREAK-ROOM (stand-in) | desk_a, desk_b, filing_wall, kettle_glow | chest: Lunch Locker (small); lore: Notes on the Subject; lore: Child Drawing; vignette: Research Assistant; shrine: Mug Shrine | specimen_gallery, glass_tank_hall |
| Glass Tank Hall (`glass_tank_hall`) | 72 x 60 | LAB-HERO-TANK-RED (stand-in), LAB-HERO-TANK-YELLOW (stand-in), LAB-HERO-TANK-PURPLE (stand-in), LAB-HERO-TANK-GREEN (stand-in) | drain_rig, wall_n | chest: Keycard Safe (large); lore: Draining Log; vignette: Intercom; shrine: Four-Colour Shrine; vista: Under the Tanks | specimen_gallery, records_break_room, dungeon:lab |


## 5. What the removal will do (the plan for Parts B and C)

1. Delete the data, the scene, `SubAreaScene`, `SubAreaMap`, `SubAreaGates`, `SubAreaDefs`, `SubAreaRewards`, the sub-area smoke, the doc generator and the three sub-area tests; drop the gate installs from the three hub scenes and the gate keep-clear from the Gainlands layout; cut the sub-area legs from the two walk smokes and the per-sub-area jobs from the paint-over tool.
2. Keep `LandmarkKit` and `HeroLandmarks` (the hubs build with them), moved to `world/kit/`.
3. The Capital's castle door and the forest's Lab hatch already open their node maps; nothing new is needed for the dungeons.
4. Mount Swolympus: the locked gate becomes a hub feature of the Gainlands (the trailhead gate model with the plank barrier, the coming-soon prompt and toast), still on the north-east rim; S-BEEF stays sealed.
5. Saves: `sub:<area>/<sub>` loads into the area's main scene at the old gate's return position (or the zone entrance when the gate is unknown); tested.
6. Part C places the modelled hero landmarks above inside their hubs by the declutter rules, and at most a few of the best rewards where there is open space.
