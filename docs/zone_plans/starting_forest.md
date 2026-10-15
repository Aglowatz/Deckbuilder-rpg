# The Starting Forest: zone plan

Art Bible row: early morning; mist and soft god rays through the canopy; palette #3F5E3A, #8DAA6B, #C9B98A, #6B4E3A, #A8C3C9; mood quiet, mysterious, a fresh start; building language almost no buildings: a ruined shrine, an old waystone, a rope bridge, the cave mouth; stone and timber from the shared kit, heavily mossed. Style file `data/zone_styles/starting_forest.json`. Kit: not yet imported (asset list `docs/art/zone_kits/starting_forest.md`).

**One walkable area** (Art Bible G-07, `docs/design/subarea_removal.md`): the whole forest is the scene `starting_area.tscn` (`StartingAreaBuilder`). There are no sub-area scenes and no Lab antechamber; variety comes from the regions below. Every dungeon is node-based from an entrance in the clearing.

## Regions (all in the one scene)

| Region | What is there | Hero landmark (concept needed) |
|---|---|---|
| The Clearing (hub) | the awakening and the rescuer, Elder Maren, the waystone | the ancient waystone (START-HERO-WAYSTONE-OLD) |
| The cave mouth | the Forgotten Cave gate (the tutorial dungeon) | START-HERO-CAVE-MOUTH |
| The hidden tunnel | the secret in the bottom-left corner and its three hidden chests | START-HERO-TUNNEL-ARCH |
| The old path | the way to town | START-HERO-ROPE-BRIDGE |
| The hollow | a fallen giant tree | START-HERO-FALLEN-GIANT |
| The postgame corner | Rip's rift station, the Lab hatch (once revealed) and the freed Rescuer | LAB-HERO-HIDDEN-HATCH |

## Dungeons (node maps)

| Dungeon | Entrance in the clearing |
|---|---|
| D-TUT, the Trial of the Hollow (tutorial) | the Forgotten Cave gate |
| D-LAB, the Path-ology Lab (postgame) | the hatch in the clearing (`StartingAreaScene._enter_lab`), revealed by Rip |

## What the removed sub-areas left behind

Nothing was kept: the Old Path, Mossy Hollow, Cave Mouth and Hidden Tunnel scenes and the five Lab antechamber scenes (Hatch Yard, Decontamination Corridor, Specimen Gallery, Records and Break Room, Glass Tank Hall) were stand-in blockouts (no modelled landmark); their chests, shrines, boards, vistas, vignettes and the hidden lever are listed in `docs/design/subarea_removal.md`. The forest's existing content is untouched.

## Art status

Paint-over input `docs/art/paintover_inputs/starting_forest/PO-STARTING-FOREST-HUB.png`; contact sheet `docs/art/zone_plans_shots/starting_forest.png`.
