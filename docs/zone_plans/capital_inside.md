# The Capital: Inside: zone plan

Art Bible row: flat, shadowless, unnaturally perfect noon; palette #F7F3EA, #E6C35C, #F5C6D0, #BFE3D0, #A7C7E7, #7FC97F; mood too perfect, eerie, quietly wrong; building language identical pastel facade houses, white-and-gold civic buildings, perfectly symmetrical; material swaps shared kit in pristine white plaster, gold trim, pastel paint; pastel plaza and perfect lawn. Style file `data/zone_styles/capital_inside.json`. Data `data/subareas/capital_inside/`.

Hero landmarks (Art Bible): Primm statue fountain, identical houses row, the four broken-service districts, the palace approach.

## Structure (G-07)

| Place | Scene | Mood | Hero landmark stand-in | Size (m) | Points of interest | Exits |
|---|---|---|---|---|---|---|
| **Gate Plaza** (hub) | the existing scene `capital_zone.tscn` | existing | existing landmarks | existing | all existing content | gates to Transit Yards, Hungry Quarter, Grave Row, Palace Approach |
| **Transit Yards** | `transit_yards` | Pristine and stalled: pastel trams that run to schedule and never leave, a tannoy announcing the weather that is already here | CAPI-HERO-TRAM-SHED | 80.0 x 62.0 | Lost Umbrella Bin (chest); Timetable (lore); Conductor (vignette); Platform Shrine (shrine); Platform Nine (vista) | Gate Plaza, Hungry Quarter |
| **Hungry Quarter** | `hungry_quarter` | Immaculate and empty-bellied: a street of identical bakeries, every window gleaming, every shelf perfectly bare | CAPI-HERO-IDENTICAL-ROW | 76.0 x 60.0 | Empty Breadbox (chest); Window Menu (lore); Resident (vignette); Plate Shrine (shrine); Window Row (vista) | Gate Plaza, Transit Yards, Grave Row |
| **Grave Row** | `grave_row` | Tidy to the point of grief: gleaming plots in perfect lines, every name polished, every flower the same flower | CAPI-HERO-GRAVE-ROW | 72.0 x 60.0 | Wreath Box (chest); Polished Name (lore); Plot Keeper (vignette); Unwritten Shrine (shrine); End of the Row (vista) | Gate Plaza, Hungry Quarter, Palace Approach |
| **Palace Approach** | `palace_approach` | Symmetrical, gleaming, cold: a long white road between two identical rows of identical lamps, and a door at the end that watches you arrive | CAPI-HERO-PALACE-FACADE | 70.0 x 70.0 | Gilded Hamper (chest); Plaque (lore); Palace Herald (vignette); Mirror Shrine (shrine); Castle View (vista) | Gate Plaza, Grave Row, Castle Grounds |

A 15-20 second walk is about 75-100 m at the 4.9 m/s walking pace; each sub-area lists 4 or more points of interest placed in walking order along its paths (chests, vistas, vignettes, lore pages, a rare card shrine, a lever).

## Loops, shortcuts, secrets

* Loops: every sub-area has at least one exit besides the way in (or a chest / shrine as the reward for the dead end); the links are in the table above and in `data/subareas/capital_inside/`.
* Secrets: the shrines and the far-corner chests.

## Where existing content goes

Everything stays in the Capital scene: the facade gate, Gate Plaza and the Primm statue, the four broken-service districts (Transit, Hungry, Grave, the Reek) with Pell, Rollo, Marlo and Fern and their quests, Spotless, the Correction Ward, the castle door and the main dungeon.

## New content

4 chests (rewards drawn from the zone's own chest tables: gold, items, cards), 4 card shrines, 4 lore pages, 4 vignettes, 4 vistas, 0 lever shortcuts. No new economy: `SubAreaRewards` reuses `ZoneDef.chest_rewards` and docs/design/progression.md is unchanged.

## Status

Planned, blocked out (scenes load from `data/subareas`), asset list `docs/art/zone_kits/capital_inside.md`, paint-over inputs `docs/art/paintover_inputs/capital_inside/`, camera contact sheet `docs/art/zone_plans_shots/capital_inside.png`. Details and numbers: `docs/overnight_report.md`.
