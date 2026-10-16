# The Capital: Inside: zone plan

Art Bible row: flat, shadowless, unnaturally perfect noon; palette #F7F3EA, #E6C35C, #F5C6D0, #BFE3D0, #A7C7E7, #7FC97F; mood too perfect, eerie, quietly wrong; building language identical pastel facade houses, white-and-gold civic buildings, perfectly symmetrical; shared kit in pristine white plaster, gold trim, pastel paint; pastel plaza and perfect lawn. Style file `data/zone_styles/capital_inside.json`. Kit: not yet imported (asset list `docs/art/zone_kits/capital_inside.md`).

**One walkable area** (Art Bible G-07, `docs/design/subarea_removal.md`): the Capital inside the wall is the northern half of the one scene `capital_zone.tscn`. There are no sub-area scenes and no walkable castle grounds: Primm's Castle is a node map opened by the castle door at the end of the palace approach. Variety comes from the regions below.

## Regions (in the one Capital scene, north of the wall)

| Region | What is there | Hero landmark (concept needed) |
|---|---|---|
| Gate Plaza (hub) | the gate, the exit-control guards, the exit interview booth, the complaint box, the manholes, the Primm statue fountain | the Primm statue fountain |
| The Transit Yards | Rollo and the wheel crews (quest) | CAPI-HERO-TRAM-SHED (a region landmark when its art exists) |
| The Hungry Quarter | Marlo and the recipes (quest) | CAPI-HERO-IDENTICAL-ROW |
| Grave Row | Pell and the burial permit (quest) | CAPI-HERO-GRAVE-ROW |
| The Reek | Fern (quest), the compost heaps, the seed, the back lane from the wall passage | the back lane |
| The Correction Ward | the permit window, the corrected citizen | the ward |
| The palace approach | the grand avenue between the sixteen identical houses of the Showcase (citizens, perfect doors, loudspeakers, portraits), the castle door at the stair's foot (`castle_door`) | Primm's Castle on its hill at the city's heart (CAPI-HERO-PALACE-FACADE) |

## Dungeons (node maps)

| Dungeon | Entrance in the zone |
|---|---|
| Main: Primm's Castle | the `castle_door` spot at the palace approach ("Enter Primm's Castle") |
| Mini and side | outside the wall (see `capital_outside.md`) |

## What the removed sub-areas left behind

Nothing was kept: the Transit Yards, Hungry Quarter, Grave Row and Palace Approach scenes and the four Castle Grounds scenes (Courtyard, Mirror Colonnade, Grand Stair, Palace Gardens) were stand-in blockouts (no modelled landmark); their chests, shrines, boards, vistas, vignettes and the silvered lever are listed in `docs/design/subarea_removal.md`. The districts and quests of the hub share the old names and are untouched.

## Layout

Fixed by the Capital layout pass (`docs/art/capital_slice.md`): routes, regions, clearances and stand-ins; paint-over inputs `docs/art/paintover_inputs/capital/PO-CAP-*.png` from `CapitalLayout.PO_CAMERAS`.

## Art status

Paint-over input `docs/art/paintover_inputs/capital_inside/PO-CAPITAL-INSIDE-HUB.png`; contact sheet `docs/art/zone_plans_shots/capital_inside.png`.
