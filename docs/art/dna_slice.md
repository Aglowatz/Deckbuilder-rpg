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
