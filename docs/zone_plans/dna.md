# The Department of Necrotic Affairs: zone plan

Art Bible row: perpetual 4:59 pm overcast gloom; cold flat light with green ghost glows; palette #6E7470, #9BB59A, #3D4A44, #C9C6B8, #4FBF7A, #8A2E2E; mood bureaucratic, gloomy, deadpan funny; building language gray stone office blocks, filing-cabinet towers, queue barriers, columned civic halls. Style file `data/zone_styles/dna.json`, kit `data/art/zone_kits/dna.json` (imported, `docs/art/dna_slice.md`).

**One walkable area** (Art Bible G-07, `docs/design/subarea_removal.md`): the whole zone is the scene `dna_zone.tscn` (`DnaLayout` / `DnaBuilder` / `DnaDressing`): an open-air plaza of courts walled by knee-high balustrades, every doorway four cells wide. There are no sub-area scenes; variety comes from the courts below. Every dungeon is node-based from an entrance in the zone.

## Regions (courts of the one scene, grid 90 x 72 cells)

| Court | Cells | What is there | Landmark |
|---|---|---|---|
| The approach causeway and gate | x 44-48, z 60-68 | Arrival facing the gate; walking off the far end leaves for town | `DnaLandmarks.entrance_gate`, the bridge stub |
| The Lobby (hub) | 36-56 x 46-60 | Agnes Overdue (front desk), Clerk Ledgerbone's Requisitions (vendor), the Rift Express, an empty middle | the gate, the lamps |
| The Breakroom | 18-35 x 48-60 | Gerald the barista, the coffee machine, the couch (heal), the time clock, the suggestion box | kit pieces |
| Cubicle Farm A | 2-34 x 26-44 | Desks, the haunted printer, the giant chest, the vault lever on the far west | a view: the Filing Tower west of the Filing Department |
| The Mail Room | 36-54 x 28-42 | The soul-routing puzzle terminal | the tubes |
| Cubicle Farm B | 56-88 x 26-44 | Desks, Kyle's matching game, the quiz | a view: the Endless Queue along the east rim (95, 26) |
| The Filing Department | 2-34 x 4-22 | The cabinet maze | DNA-HERO-FILING-TOWER (modelled) as a view at (-8, 13) |
| The Elevator Bank | 36-54 x 16-24 | Sub-Basement 3 (the mini dungeon elevator) and the other elevators | the elevators |
| The Records Basement | 56-88 x 4-24 | Shelving stacks, coffins, chests, the Records board and the Filed Complaint board (lore) | DNA-HERO-RECORDS-STAIR (modelled) as a view beyond the north parapet (72, -4.5) |
| The Executive Floor | 36-54 x 2-14 | The forecourt of the Hall: the main dungeon spot at the stair foot (no plate, icon board), the Stamp of Approval shrine (one card from the zone table, once) at the east side | DNA-HERO-FINAL-APPROVALS (modelled, 64 x 40 x 24 m beyond the north edge) |

## Dungeons (node maps)

| Dungeon | Entrance in the zone |
|---|---|
| Main: the Hall of Final Approvals | the `main_dungeon` spot at the stair foot (45.5, 2.9) |
| Mini: Sub-Basement 3 (Quarterly Reviews) | the `mini_dungeon` elevator in the Elevator Bank (48.5, 17.4) |
| Side: S-NECRO, the Waiting Room of Eternity | unlocked by its quest; entered from the same elevator bank flow |

## What the removed sub-areas left behind (SR-7, SR-8)

Kept: the Filing Tower, the Endless Queue (30 m of it) and the Records Stair as views beyond the balustrades, the Stamp of Approval shrine, the Filed Complaint board. Dropped: the Cubicle Fields, The Queue, Records Basement and Executive Approach scenes with their chests, vistas, vignettes and the other shrines and boards (their words stay in `docs/design/subarea_removal.md`).

## Art status

Kit imported (24 ids), the plaza dressed and matched to the paint-overs (`docs/art/dna_slice.md`); paint-over input `docs/art/paintover_inputs/dna/PO-DNA-HUB.png` (the lobby centre); contact sheet `docs/art/zone_plans_shots/dna.png`; asset list `docs/art/zone_kits/dna.md`. The PAINTOVER-DNA-* pictures in `docs/art/paintovers/` show regions of this one map.
