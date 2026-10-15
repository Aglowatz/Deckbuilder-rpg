# The D.N.A. slice (Department of Necrotic Affairs)

Note (2026-10-15): the four sub-area scenes this report dresses were removed by design (docs/design/subarea_removal.md); the hub, the kit, the swaps, the presets, the clusters and the four modelled landmarks stay (the Filing Tower, the Endless Queue and the Records Stair now stand as views beyond the balustrades, SR-8). The sub-area sections and the balustrade / ground keys are history.

The D.N.A. hub (Lobby Plaza) and its four sub-areas remade with the approved zone kit (`G:\My Drive\Card Game Art\Approved_ZoneKits\DNA`, 24 ids, imported by
`bash tools/import_zone_kit.sh dna`), following `docs/art/zone_rollout_playbook.md` step by step with the Gainlands corrections (`docs/art/gainlands_corrections.md`) applied
from the start, and matched against the five paint-overs `docs/art/paintovers/PAINTOVER-DNA-{HUB,CUBICLE-FIELDS,THE-QUEUE,RECORDS-BASEMENT,EXECUTIVE-APPROACH}.png` from the
paint-over cameras (`tools/zone_shots.gd`). Judgment calls are DN-1 .. in `docs/design/open_questions.md`. Gameplay, quests, NPC logic, sub-area connections and the camera
system are untouched; nothing new was added to the zone's map (scope rule).

## What the D.N.A. has (before this pass; nothing is added or removed from this list)

| Place | Scene / data | Notes |
|---|---|---|
| **Lobby Plaza** (hub) | `scenes/dna_zone.tscn` (`DnaScene`, layout `world/dna/dna_layout.gd`, builder `dna_builder.gd`) | The way in from town (the "exit" spot), Agnes Overdue (front desk, quests), Clerk Ledgerbone (Requisitions, vendor), Gerald (barista, quests), the breakroom couch (heal), the coffee machine, the time clock, the suggestion box, the haunted printer, Director Ectomund (quiz), Kyle (matching minigame), the Soul Routing Terminal (puzzle), the Rift Express station, Shiro Swindle's giant chest, the vault lever, 14 hidden chests, the regions below |
| Hub regions (inside the hub scene) | The Lobby, The Breakroom, Cubicle Farm A, Cubicle Farm B, The Mail Room, The Filing Department (maze), The Elevator Bank, The Records Basement, The Executive Floor | the roaming managers, interns and couriers; Sub-Basement 3 (S-NECRO, the mini dungeon) at the elevator bank; the Hall of Final Approvals (main dungeon) at the executive floor's north wall |
| **Cubicle Fields** | `data/subareas/dna/cubicle_fields.json` | hub gate `gate_cubicles` (55.5, 56.5); the Filing Tower (DNA-HERO-FILING-TOWER), Desk Drawer chest, Memo, Junior Associate, Overlook, Approvals Shrine; exits to the hub and The Queue |
| **The Queue** | `data/subareas/dna/the_queue.json` | hub gate `gate_queue` (34.5, 58.5); the Endless Queue (DNA-HERO-ENDLESS-QUEUE), Lost Property chest, Number Board, Veteran of the Line, Patience Shrine, End of the Line; exits to the hub, Cubicle Fields, Records Basement |
| **Records Basement** | `data/subareas/dna/records_basement.json` | hub gate `gate_basement` (70.5, 24.5); the Records Stair (DNA-HERO-RECORDS-STAIR), Sealed Folder and Cold Cabinet chests, Filed Complaint, Archivist, Stamp Shrine; exits to the hub, The Queue, Executive Approach |
| **Executive Approach** | `data/subareas/dna/executive_approach.json` | off the Records Basement; the Hall of Final Approvals facade (DNA-HERO-FINAL-APPROVALS), Executive Safe chest, Plaque, Door Usher, Stamp of Approval, Under the Facade; exit to the Records Basement |
| Side dungeon | S-NECRO "The Waiting Room of Eternity" (entered at the hub's Sub-Basement 3 elevator) | |
| Main dungeon | HFA, the Hall of Final Approvals (entered at the hub's executive floor) | |

## Part A: import, landmarks, sky and backdrop

**Import result: 24 of 24 ids imported, 0 missing, 6 files that match no id** (`docs/art/zone_kits/dna_import_report.md`). The six unmatched files are the five
paint-overs (copies of `Paintovers/PAINTOVER-DNA-*.png` that also sit in the kit folder; the repo copies are in `docs/art/paintovers/`) and `Haunted Office of Necrotic
Affairs.png`, an interior concept full of lettering that is on no sheet row: a reference only (DN-3). One note from the importer: `DNA-SKY-GLOOM` is an opaque full-frame
sky picture, not a ring strip; that is what the sheet asked for, and it is now wrapped round the sky dome as a panorama (DN-2, a new `sky.panorama` key in
`data/art/zone_looks.json` read by `world/look/world_sky.gd`). Everything in the kit is painted (soft cel-shaded, clean shapes), nothing reads as pixel art.

- **Slices and pivots**: the four 3x2 sheets sliced cleanly into 24 parts; the cabinets sheet was first filed as wall plaques (pivot at the bracket) because its use text
  says "props", so the importer now files a prop sheet as ground props (bottom-centre pivot, DN-1) and the sheet was re-sliced.
- **Hand numbers** in `data/art/zone_kits/dna.json`: card heights (desk 1.3 m, stamp 1.0, rope post 1.0, ghost lamp 2.6, paper towers 1.4, office plant 1.8, lilies 1.3,
  dead topiary 2.2, cabinets 1.2-1.6), window width 0.9 m, and the aliases for the painted textures the zone reuses (TEX-DNA-CARPET / -MARBLE / -LINOLEUM / -CHECKERTILE /
  -PANELING / -WALLPAPER, DEC-PAPERS, DEC-ECTOPLASM).
- **Hero landmarks** (`world/dna/dna_landmarks.gd`, registered in `HeroLandmarks.BUILDERS`): the Hall of Final Approvals (plinth and marble forecourt with a balustrade,
  a grand stair between hooded statues and ghost lamps, two wings of kit windows with pilasters, banners, brass cornices and slate roofs, corner cupolas, a central block
  with six columns, a laurelled pediment, the clock stopped at 4:59, the gold stamp relief in its laurel over the kit double doors with warm lamps, a dome with a glowing
  drum and lantern, four turrets, dead topiary and lilies); the Filing Tower (a plinth, nine teetering cabinet boxes with brass-handled drawers, open drawers spilling
  paper, a brass ladder winding up, banners, fluttering pages, ghost lamps on pedestals, paper towers, a stamp and an office plant at the foot); the Endless Queue (the
  worn queue-lane floor, brass stanchions and red rope snaking along, ghost and skeleton citizens with clipboards, planters of dead topiary and lilies, ghost lamps,
  banner posts, the service booth with its warm window and clerk, the number post); the Records Stair (a landing with the vault door in its frame, banners, the wheel
  lock, a grand stair with balustrades and ghost lamps, paneled shelving canyons full of files either side). Sizes come from the sub-area data.
- **Sky and backdrop**: DNA-SKY-GLOOM round the dome (mirrored twice so it has no seam, the gradient under it lifted to the picture's grey-green), DNA-BD-TOWERS as four
  kit cards ringing the zone at the hills ring (north, east, south, west), the scenery haze cooled to the palette.

| Spot | Before | After |
|---|---|---|
| Hub, Cinematic / Normal (`--at=spawn`) | ![](dna_slice/a_before_hub.jpg) | ![](dna_slice/a_after_hub.jpg) |
| Cubicle Fields (paint-over camera) | ![](dna_slice/a_before_cubicle_fields.jpg) | ![](dna_slice/a_after_cubicle_fields.jpg) |
| The Queue (paint-over camera) | ![](dna_slice/a_before_the_queue.jpg) | ![](dna_slice/a_after_the_queue.jpg) |
| Records Basement (paint-over camera) | ![](dna_slice/a_before_records_basement.jpg) | ![](dna_slice/a_after_records_basement.jpg) |
| Executive Approach (paint-over camera) | ![](dna_slice/a_before_executive_approach.jpg) | ![](dna_slice/a_after_executive_approach.jpg) |
| The four landmarks on the kit bench | ![](dna_slice/a_bench_hall.jpg) ![](dna_slice/a_bench_tower.jpg) | ![](dna_slice/a_bench_queue.jpg) ![](dna_slice/a_bench_stair.jpg) |

fps (Medium, `tools/fps.sh res://scenes/dna_zone.tscn 1`, the untouched hub with the new sky and backdrop): avg 60.0, min 60.0, 778 draw calls. GUT: 1528 / 1530 after
the kit tests were added (one failure is GC-6, pre-existing and local to this PC; the other was the new test asking for art files of concept and sheet ids, fixed).
The 9-camera contact sheet of the untouched hub is `dna_slice/a_before_grid.jpg`.

## Part B: layout and declutter (the Gainlands lessons, before dressing)

Done: see DN-5 .. DN-8. The office is an open-air plaza of courts under the overcast sky: every doorway 4-5 cells wide, knee-high balustrades with brass caps and ghost
lamps on them instead of 1.25 m walls, cabinets and cubicle partitions that fade per piece when they stand between the camera and the hero, one kit desk per cubicle and
a handful of kit pieces against the walls instead of the furniture scatter, 21 boards instead of 38, an empty lobby middle with Agnes, the Requisitions desk, the Rift
Express and the gate round its rim. The way in is the approach causeway through the gate (arrival facing the gate, the exit at the far end, walking off leaves). The Hall
of Final Approvals towers beyond the executive floor's north edge with its stair coming down to the floor; the dungeon spot waits at the foot, no placeholder door, no
lettered plate. Sub-area data: main paths 4.2-4.4 m, spurs 3.6 m, scatter cut to three grouped pieces per scene, every poi, exit, entry, spawn and gate position unchanged.

| Spot | Before | After |
|---|---|---|
| Arrival (`--at=spawn`): the old spawn in the lobby beside the elevator; now the approach causeway, the gate and the lobby ahead, the Hall at the far end | ![](dna_slice/b_before_hub.jpg) | ![](dna_slice/b_after_hub_spawn.jpg) |
| The Lobby Plaza (`--at=lobby_center`) | ![](dna_slice/b_before_hub.jpg) | ![](dna_slice/b_after_hub_center.jpg) |
| The Lobby Plaza, Overview | ![](dna_slice/b_before_hub_overview.jpg) | ![](dna_slice/b_after_hub_overview.jpg) |
| The Hall of Final Approvals (`--at=main_dungeon`): a taped door; now the stair's foot under the Hall | ![](dna_slice/b_before_main_dungeon.jpg) | ![](dna_slice/b_after_main_dungeon.jpg) |
| The Hall from the Mail Room and the Elevator Bank | ![](dna_slice/b_after_hall_from_mail.jpg) | ![](dna_slice/b_after_hall_from_bank.jpg) |
| The way out (`--at=exit`): the elevator; now the causeway's far end, the gate (`--at=gate`) behind | ![](dna_slice/b_before_exit.jpg) | ![](dna_slice/b_after_exit.jpg) ![](dna_slice/b_after_gate.jpg) |
| Cubicle Farm A (`--at=farm_a_aisle`): 72 desk sets, chairs, boxes, 1.25 m walls; now one kit desk per cubicle, knee-high paneling, balustrade lamps | ![](dna_slice/b_before_farm_a.jpg) | ![](dna_slice/b_after_farm_a.jpg) |
| The Filing Department (`--at=chest_maze_0`): cabinets that fade piece by piece | ![](dna_slice/b_before_maze.jpg) | ![](dna_slice/b_after_maze.jpg) |
| The Records Basement (`--at=records_center`) | ![](dna_slice/b_before_records.jpg) | ![](dna_slice/b_after_records.jpg) |
| The Breakroom (`--at=coffee`): counter, coffee urn, table, bench; the clutter gone | ![](dna_slice/b_before_breakroom.jpg) | ![](dna_slice/b_after_breakroom.jpg) |

fps (Medium, `tools/fps.sh`): 60.0 / 60.0 at the spawn, 60.0 at the Hall's stair, 60.0 in the maze; 458 draw calls (778 before). GUT: 1535 / 1537 (GC-6 pre-existing, plus
one assertion of the new test that asked a chest's own cell to be walkable, fixed); `tests/world/test_dna_corrections.gd` adds 7 checks (doorway widths, wall heights,
prop and board counts, the walked entrance, the Hall's placement and cull exemption, the open plaza). `SMOKE_ONLY=dna,save_load bash tools/run_subarea_smoke.sh` passes
(it now reads the Rift Express unlock speech before pressing E at a gate, DN-9). The walkability probe (`tests/world/test_walkability_zones.gd`) reaches all 46 key
locations with 0.7 m lanes.

## Part C: dress (playbook section 2)

Done: see DN-10. Material swaps in `data/zone_styles/dna.json` (timber -> gray stone, plank -> paneling, every roof -> slate, eaves -> brass, the sliced doors, windows and
plaques, dirt paths -> the queue lane, trees -> dead topiary, office plants and lilies); three presets (`dna_office_block`, `dna_records_annex`, `dna_booth`); seven zone
clusters as data (`data/art/zone_kits/dna_clusters.json`); the stand-in landmarks and the hub's sub-area gates in kit surfaces; the sub-areas' ground kinds (marble under
the Executive Approach), kit decals and a building or two each; the hub dressed by `DnaDressing` (eight clusters against walls, coffee rings and queue footprints) with the
generic furniture scatter off. The decluttered layout of Part B is untouched: the dressing test checks the plaza middle, the forecourt, the causeway and every anchor's
approach stay open.

| Spot | Before (Part B) | After |
|---|---|---|
| The Lobby Plaza (`--at=lobby_center`) | ![](dna_slice/b_after_hub_center.jpg) | ![](dna_slice/c_after_hub_center.jpg) |
| The Mail Room (`--at=mail_center`): cabinet rows at the wall, paper towers in a corner, the console | | ![](dna_slice/c_after_mail.jpg) |
| Cubicle Fields (paint-over camera): paneled partitions with clerk desks, an office block, the Filing Tower | ![](dna_slice/a_after_cubicle_fields.jpg) | ![](dna_slice/c_after_cubicle_fields.jpg) |
| The Queue (paint-over camera): the brass-and-rope line, the booth, planters and lamps | ![](dna_slice/a_after_the_queue.jpg) | ![](dna_slice/c_after_the_queue.jpg) |
| Records Basement (paint-over camera): paneled shelving, the annex, lamps between the stacks | ![](dna_slice/a_after_records_basement.jpg) | ![](dna_slice/c_after_records_basement.jpg) |
| Executive Approach (paint-over camera): marble court, lamp planters, the Hall | ![](dna_slice/a_after_executive_approach.jpg) | ![](dna_slice/c_after_executive_approach.jpg) |

fps (Medium, `tools/fps.sh`): hub 60.0 / 60.0 (494 draw calls); Cubicle Fields 60.0 / 49.8; The Queue 60.0 / 52.9; Records Basement 60.0 / 59.7; Executive Approach 60.0 / 56.1
(the minimums are the first frames after the scene opens). GUT: 1536 / 1537 (GC-6).

## Part D: match the paint-overs (playbook section 3)

Three passes per scene (DN-11, DN-12), numbers first (`tools/image_stats.gd`):

1. **Composition and landmark size**: balustrade edges round every sub-area, the Hall of Final Approvals on the skyline of the Cubicle Fields, The Queue and the
   Records Basement (a far landmark, never culled), the tower skyline brought in to about 100 m and the fog thinned so it shows; the hub paint-over camera moved to
   the lobby centre where the painter stood.
2. **Palette and buildings**: desaturation 0.97 -> 0.45 (the kit's sage, brass, red tape and ghost green come back; characters keep their colour and stay the clearest
   thing on screen), the marble court tinted to the paint-over's mid grey, the far Hall sized down to 52-56 m so it sits on the horizon instead of filling it.
3. **Light, shadows and haze**: key 0.95 -> 0.66, ambient 0.6 -> 0.4, contrast 1.16, vignette 0.4, the sky panorama blended at 0.72 over a darker gradient, the painted
   floors of the hub 15-20% darker, fog colour, apron and sky foot matched so the horizon dissolves.

### Grade (paint-over then result; mean RGB, luma p5 / p50 / p95, mean saturation, sky / mid / ground thirds)

| image | mean RGB | luma p5 / p50 / p95 | saturation | sky / mid / ground |
|---|---|---|---|---|
| PAINTOVER-DNA-HUB | 80, 80, 78 | 27 / 73 / 158 | 0.17 | 85,91,97 / 88,87,80 / 67,62,57 |
| result (lobby centre) | 83, 93, 87 | 27 / 91 / 150 | 0.17 | 92,104,98 / 78,86,78 / 80,90,83 |
| PAINTOVER-DNA-CUBICLE-FIELDS | 83, 83, 83 | 37 / 77 / 146 | 0.14 | 90,93,98 / 81,78,74 / 80,77,76 |
| result | 72, 78, 69 | 20 / 77 / 139 | 0.18 | 100,113,107 / 63,68,59 / 52,52,42 |
| PAINTOVER-DNA-THE-QUEUE | 83, 83, 82 | 30 / 77 / 154 | 0.14 | 85,87,90 / 72,70,67 / 93,91,89 |
| result | 78, 85, 76 | 27 / 88 / 141 | 0.17 | 100,113,107 / 62,69,62 / 72,71,59 |
| PAINTOVER-DNA-RECORDS-BASEMENT | 63, 62, 57 | 22 / 55 / 133 | 0.16 | 55,57,55 / 67,66,61 / 67,62,56 |
| result | 66, 71, 63 | 13 / 68 / 138 | 0.20 | 98,111,105 / 52,56,48 / 46,45,35 |
| PAINTOVER-DNA-EXECUTIVE-APPROACH | 87, 82, 81 | 31 / 79 / 154 | 0.17 | 91,88,90 / 88,85,83 / 82,75,70 |
| result | 79, 89, 84 | 32 / 88 / 139 | 0.15 | 95,107,101 / 77,87,82 / 65,72,67 |

Before the passes the Executive Approach ran at luma 132 (its marble court near white) and every scene sat 10-15 points green of the paint-overs; now the medians are
within 9-18 of the paint-overs (the Cubicle Fields exact), saturation within 0.04, and the remaining cast is the sky third (the painted sky picture is lighter and
greener than the painter's sky, 100,113,107 against 85-91). The hub measured from the lobby centre matches the painting's mean within 3-13 per channel.

### Paint-over beside the result (left the paint-over, right the game, same camera)

| Scene | |
|---|---|
| **Lobby Plaza (hub)** | ![](dna_slice/compare_hub.jpg) |
| **Cubicle Fields** | ![](dna_slice/compare_cubicle_fields.jpg) |
| **The Queue** | ![](dna_slice/compare_the_queue.jpg) |
| **Records Basement** | ![](dna_slice/compare_records_basement.jpg) |
| **Executive Approach** | ![](dna_slice/compare_executive_approach.jpg) |

Full-size results: `dna_slice/d_after_*.jpg`.

### The hub at all nine camera combinations

Rows: Cinematic, Classic, Overview. Columns: Close, Normal, Far (`tools/zone_shots.gd --mode=grid`, from the lobby centre).

![](dna_slice/d_grid.jpg)

### The Hall of Final Approvals from the hub and two other spots

| From the causeway (`--at=spawn`) | From the Mail Room (`--at=mail_center`) | From the Elevator Bank (`--at=bank_center`) |
|---|---|---|
| ![](dna_slice/d_after_hub_spawn.jpg) | ![](dna_slice/d_after_hall_from_mail.jpg) | ![](dna_slice/d_after_hall_from_bank.jpg) |

### fps (Medium, 1600x900, `tools/fps.sh`, after the passes)

| Scene / spot | avg fps | min fps |
|---|---|---|
| Lobby Plaza (spawn) | 60.0 | 60.0 |
| The Hall's stair foot | 60.0 | 58.6 |
| Cubicle Fields | 60.0 | 60.0 |
| The Queue | 60.0 | 60.0 |
| Records Basement | 60.0 | 60.0 |
| Executive Approach | 60.0 | 60.0 |

## Part E: verify and report

Two windowed e2e runs with real input, both passing (DN-13):

- `bash tools/run_dna_walk_smoke.sh` (new, about 4 minutes): arrival on the approach causeway and the walk through the gate into the Lobby Plaza; Agnes, Clerk
  Ledgerbone (the shop opens), Gerald; the coffee machine, the time clock, the suggestion box, the haunted printer, the couch; Director Ectomund's quiz, Kyle's matching
  game, the Soul Routing Terminal (each opens on E and gives the hero back); Sub-Basement 3 (the elevator answers E); the Hall of Final Approvals at its stair foot
  (prompt, no lettered plate, E asks to enter, Not yet gives the hero back); the giant chest and the vault lever (prompts up); Cubicle Fields -> The Queue -> Records
  Basement -> Executive Approach -> Records Basement -> hub through every gate and exit, every arrival on walkable ground; then down the causeway and off its end into
  town. 27 screenshots in `_screenshots/dna_walk/`.
- `bash tools/run_fifth_brief_final_smoke.sh` (the D.N.A. smoke, about 8 minutes): town quests, vendor, the D.N.A., the courier hit, a battle, the couch, a card bought,
  the quiz, the matching game, the puzzle, a chest, the mini dungeon with its battles and reward: 42 screenshots, every check ok. One stale step fixed (the heal step now
  reads the Rift Express speech at the lobby centre, DN-13).
- `SMOKE_ONLY=dna,save_load bash tools/run_subarea_smoke.sh`: the hub gates, a chest, the exit back, save and load inside a sub-area: passes.
- The walkability probe (`tests/world/test_walkability_zones.gd`): all 46 key locations of the D.N.A. reachable from the spawn with 0.7 m lanes.

| Spot (walk smoke, real input) | |
|---|---|
| Arrival on the causeway, the gate and the Hall ahead | ![](dna_slice/e_w_01_arrival_on_the_causeway.jpg) |
| The Lobby Plaza, walked to through the gate | ![](dna_slice/e_w_02_the_lobby_plaza.jpg) |
| Agnes at the front counter; Director Ectomund | ![](dna_slice/e_w_03_agnes.jpg) ![](dna_slice/e_w_11_quiz.jpg) |
| Sub-Basement 3; the Hall of Final Approvals asks to enter | ![](dna_slice/e_w_14_sub_basement_3.jpg) ![](dna_slice/e_w_16_hall_ask.jpg) |
| The giant chest and the vault lever | ![](dna_slice/e_w_17_giant_chest.jpg) ![](dna_slice/e_w_17_vault_lever.jpg) |
| Cubicle Fields, The Queue, Records Basement, Executive Approach | ![](dna_slice/e_w_19_cubicle_fields.jpg) ![](dna_slice/e_w_20_the_queue.jpg) ![](dna_slice/e_w_21_records_basement.jpg) ![](dna_slice/e_w_22_executive_approach.jpg) |
| Leaving down the causeway; back in town | ![](dna_slice/e_w_25_leaving_down_the_causeway.jpg) ![](dna_slice/e_w_26_back_in_town.jpg) |

## What matches

- **Materials**: every shared kit surface the zone uses is the zone's own art (gray stone, slate, brass trim, the queue lane, the six sliced doors, windows, plaques and
  cabinets, the three plant cards, five prop cards, two decals) plus the painted textures the zone already had (carpet, marble, linoleum, checker tile, paneling,
  wallpaper, papers, ectoplasm); the hub's balustrades, counters, consoles, elevators, gate and bridge wear the kit surfaces too.
- **Landmarks** modelled to their concepts: the Hall (clock at 4:59, stamp relief, columns, wings, dome), the Filing Tower, the Endless Queue, the Records Stair.
- **The goal you can see**: the Hall stands beyond the executive floor and shows from the causeway, the lobby, the mail room, the elevator bank and three sub-areas.
- **Declutter and readability**: wide doorways, knee-high balustrades, per-piece fading cabinets and partitions, open plaza, a few tidy clusters at walls; the hero and
  the NPCs keep their colour and read against every floor.
- **No readable text**; **60 fps on Medium** in all five scenes.

## What still does not match (honest list)

1. **The painted sky**: DNA-SKY-GLOOM is a lighter, greener overcast than the painter's (sky thirds 95-100,107-113 against 85-91); it is blended at 0.72 over a darker
   gradient and the horizon dissolves, but the paint-overs' heavy, nearly colourless cloud deck is not there.
2. **The Hall's scale in the hub**: in the paint-over the Hall fills the top of the lobby picture with its stair reaching the plaza; in the game it stands 50 m beyond the
   executive floor (the floor plan between the lobby and the Hall is gameplay: the mail room, the elevator bank and the executive floor), so from the lobby it is a
   building on the skyline, not a backdrop wall.
3. **The sub-area floors**: the paint-overs' Cubicle Fields and Queue floors are wet grey flagstones; the game's are the shared cobble (the kit has no office-floor
   surface for outdoor sub-areas; the marble court is the only kit ground there). See the asset table.
4. **The cubicle partitions in the sub-areas** are LandmarkKit boxes in paneling (1.1 m), not the paint-over's glass-and-brass desks with ghosts at them; the hub's
   cubicles have the desks but no clerks (the roaming enemies are the staff).
5. **The Endless Queue's citizens** are translucent blobs with clipboards, not painted ghosts; the paint-over's queue curls round the whole plaza, the model is one 56 m
   serpentine.
6. **Stand-ins remain**: the water cooler, the ticket machine, the window wall, the shelving towers, the colonnades, the reception desk and the shrines are kit-textured
   LandmarkKit shapes.
7. **The near-side framing** of every paint-over (topiary, a lamp, a balustrade at the lens edge) is only partly there (the balustrade edge and the lamp planters).
8. **Hero size**: unchanged by design; the paint-overs draw the hero a little larger.

## Extra assets that would close the gap (sheet-ready)

| ID | Asset | Category | Lock | Image Description | Size / Format | In-Game Use | Priority |
|---|---|---|---|---|---|---|---|
| DNA-SKY-GLOOM-2 | Overcast sky strip | Sky / backdrop | BACKDROP | A heavy, almost colourless grey cloud deck, darker overhead and paler at the horizon, no objects, no green cast; a panorama strip that wraps (left and right edges match) | 2048x1024 PNG | The zone sky (replaces the blend over the gradient) | 1 |
| DNA-GROUND-FLAGSTONE | Wet office flagstones | Surface | SURFACE | Large cool grey flagstones with narrow joints, faintly wet, seamless, flat light | 1024x1024 PNG, tileable | The Cubicle Fields and Queue ground (shared cobble now) | 1 |
| DNA-PROP-CUBICLE | Clerk cubicle | Prop | CUTOUT | A glass-and-brass office cubicle with a desk, a lamp and a translucent ghost clerk at it, straight on | 1536x1024 PNG, transparent | Cubicle Fields rows (paneling boxes now) | 1 |
| DNA-SHEET-CITIZENS | Queue citizens | Cutout sheet | SHEET | 6 patient citizens of the queue (ghosts and skeletons, clipboards, tickets, a hat), each straight on | 2048x1365 PNG, transparent | The Endless Queue and the hub's lobby (blobs now) | 2 |
| DNA-PROP-COOLER | Water cooler | Prop | CUTOUT | A tall glass water cooler on a brass stand, a ghost bubble inside | 1024x1536 PNG, transparent | Cubicle Fields (stand-in now) | 3 |
| DNA-PROP-TICKET | Take-a-number machine | Prop | CUTOUT | A red ticket dispenser on a brass post, a long paper tongue | 1024x1536 PNG, transparent | The Queue (stand-in now) | 3 |
| DNA-PROP-SHELVING | Records shelving | Prop | CONCEPT | Concept of a 14 x 5 m paneled shelving canyon of files and boxes with a rolling ladder, 3/4 view | 1536x1024 PNG | Records Basement (stand-in now) | 3 |
| DNA-WALL-WINDOWS | Office window wall | Surface | SURFACE | A wall of tall office windows with blinds, some green-lit, seamless left-right | 1024x1024 PNG, tileable horizontally | The Queue's window wall, the hub's office blocks | 3 |
| DNA-DEC-TAPE | Red tape | Decal | CUTOUT | A tangle of red tape and a wax seal, top-down, soft edges | 1024x1024 PNG, transparent | The executive court and the Hall's forecourt | 3 |
| DNA-BD-TOWERS-NIGHT | Tower skyline, lit | Sky / backdrop | BACKDROP | The office skyline with more green-lit windows and a darker haze, for the Records Basement side | 2048x1024 PNG, transparent sky | Backdrop ring, north and east | 3 |

## Kit status (`data/art/zone_kits/dna.json`)

The 24 sheet ids and the 24 sheet parts now in the game (the painted-texture aliases are listed in `docs/art/art_status.md`):

| Kit ID | Lock | Family | px | Pivot | Tile |
|---|---|---|---|---|---|
| `DNA-BD-TOWERS` | BACKDROP | backdrop | 2048x680 | 0.50,1.00 |  |
| `DNA-DEC-COFFEE` | CUTOUT | decal | 897x894 | 0.50,0.50 |  |
| `DNA-DEC-FOOT` | CUTOUT | decal | 131x950 | 0.50,0.50 |  |
| `DNA-HERO-ENDLESS-QUEUE` | CONCEPT | concept | 1536x1024 |  |  |
| `DNA-HERO-FILING-TOWER` | CONCEPT | concept | 1536x1024 |  |  |
| `DNA-HERO-FINAL-APPROVALS` | CONCEPT | concept | 1536x1024 |  |  |
| `DNA-HERO-RECORDS-STAIR` | CONCEPT | concept | 1536x1024 |  |  |
| `DNA-PATH-QUEUE` | SURFACE | ground | 1024x1024 |  | 2.56 m |
| `DNA-PLANT-LILY` | TREE | tree | 784x1490 | 0.51,1.00 |  |
| `DNA-PLANT-OFFICE` | TREE | tree | 866x1484 | 0.48,1.00 |  |
| `DNA-PROP-DESK` | CUTOUT | prop | 1014x808 | 0.50,1.00 |  |
| `DNA-PROP-GHOSTLAMP` | CUTOUT | prop | 402x1496 | 0.50,1.00 |  |
| `DNA-PROP-PAPER` | CUTOUT | prop | 972x1005 | 0.50,1.00 |  |
| `DNA-PROP-ROPE` | CUTOUT | prop | 961x964 | 0.50,1.00 |  |
| `DNA-PROP-STAMP` | CUTOUT | prop | 884x996 | 0.50,1.00 |  |
| `DNA-ROOF-SLATE` | SURFACE | roof | 1024x1024 |  | 2.56 m |
| `DNA-SHEET-CABINETS` | SHEET | prop | 2048x1365 |  |  |
| `DNA-SHEET-CABINETS-01` | CUTOUT | prop | 332x686 | 0.50,1.00 |  |
| `DNA-SHEET-CABINETS-02` | CUTOUT | prop | 565x470 | 0.50,1.00 |  |
| `DNA-SHEET-CABINETS-03` | CUTOUT | prop | 380x659 | 0.50,1.00 |  |
| `DNA-SHEET-CABINETS-04` | CUTOUT | prop | 596x510 | 0.50,1.00 |  |
| `DNA-SHEET-CABINETS-05` | CUTOUT | prop | 329x558 | 0.50,1.00 |  |
| `DNA-SHEET-CABINETS-06` | CUTOUT | prop | 429x504 | 0.50,1.00 |  |
| `DNA-SHEET-DOORS` | SHEET | door | 2048x1365 |  |  |
| `DNA-SHEET-DOORS-01` | CUTOUT | door | 497x576 | 0.50,1.00 |  |
| `DNA-SHEET-DOORS-02` | CUTOUT | door | 515x568 | 0.50,1.00 |  |
| `DNA-SHEET-DOORS-03` | CUTOUT | door | 508x568 | 0.50,1.00 |  |
| `DNA-SHEET-DOORS-04` | CUTOUT | door | 538x602 | 0.50,1.00 |  |
| `DNA-SHEET-DOORS-05` | CUTOUT | door | 443x601 | 0.50,1.00 |  |
| `DNA-SHEET-DOORS-06` | CUTOUT | door | 519x562 | 0.50,1.00 |  |
| `DNA-SHEET-SIGNS` | SHEET | sign | 2048x1365 |  |  |
| `DNA-SHEET-SIGNS-01` | CUTOUT | sign | 582x594 | 0.00,0.50 |  |
| `DNA-SHEET-SIGNS-02` | CUTOUT | sign | 579x591 | 0.00,0.50 |  |
| `DNA-SHEET-SIGNS-03` | CUTOUT | sign | 581x591 | 0.00,0.50 |  |
| `DNA-SHEET-SIGNS-04` | CUTOUT | sign | 574x590 | 0.00,0.50 |  |
| `DNA-SHEET-SIGNS-05` | CUTOUT | sign | 578x592 | 0.00,0.50 |  |
| `DNA-SHEET-SIGNS-06` | CUTOUT | sign | 574x593 | 0.00,0.50 |  |
| `DNA-SHEET-WINDOWS` | SHEET | window | 2048x1365 |  |  |
| `DNA-SHEET-WINDOWS-01` | CUTOUT | window | 327x596 | 0.50,1.00 |  |
| `DNA-SHEET-WINDOWS-02` | CUTOUT | window | 329x596 | 0.50,1.00 |  |
| `DNA-SHEET-WINDOWS-03` | CUTOUT | window | 327x597 | 0.50,1.00 |  |
| `DNA-SHEET-WINDOWS-04` | CUTOUT | window | 329x595 | 0.50,1.00 |  |
| `DNA-SHEET-WINDOWS-05` | CUTOUT | window | 331x595 | 0.50,1.00 |  |
| `DNA-SHEET-WINDOWS-06` | CUTOUT | window | 329x595 | 0.50,1.00 |  |
| `DNA-SKY-GLOOM` | BACKDROP | backdrop | 2048x1024 | 0.50,1.00 |  |
| `DNA-TREE-DEAD` | TREE | tree | 857x1498 | 0.49,1.00 |  |
| `DNA-TRIM-BRASS` | SURFACE | trim | 1024x512 |  | 2.56 m |
| `DNA-WALL-GREY` | SURFACE | wall | 1024x1024 |  | 2.56 m |
