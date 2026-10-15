# The D.N.A. slice (Department of Necrotic Affairs)

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
