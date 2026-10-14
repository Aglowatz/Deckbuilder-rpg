# The Path-ology Lab: zone plan

Art Bible row: tbd (claude fills from docs/design/pathology_lab.md); palette #E4EAEE, #9FB4C4, #4C5B66, #8A5A3C, #E0443A, #E8C13A, #8E5FD0, #5FBF6A; mood tbd; building language tbd; material swaps tbd. Style file `data/zone_styles/pathology_lab.json`. Data `data/subareas/pathology_lab/`.

Hero landmarks (Art Bible): TBD.

## Structure (G-07)

| Place | Scene | Mood | Hero landmark stand-in | Size (m) | Points of interest | Exits |
|---|---|---|---|---|---|---|
| **Hatch Yard** (hub) | the existing scene `starting_area.tscn` | existing | existing landmarks | existing | all existing content | gates to The Hatch Yard |
| **The Hatch Yard** | `hatch_yard` | A cold pre-dawn hush in a clearing that was never this clean: pale ferns, a steel hatch, a smell like a hospital | LAB-HERO-HIDDEN-HATCH | 64.0 x 56.0 | Supply Case (chest); Maintenance Tag (lore); Rescuer (vignette); Lantern Shrine (shrine); Pale Ferns (vista) | The Clearing, Decontamination Corridor, The Path-ology Lab |
| **Decontamination Corridor** | `decontamination_corridor` | White tile and cold flat light: a long corridor cracked open by roots, with a showerhead that has not been used and a draught that has | LAB-HERO-DECON-ARCH | 72.0 x 40.0 | Changing Locker (chest); Procedure Sheet (lore); Decontamination Tech (vignette); Sterile Shrine (shrine); Cracked Tile (vista) | The Hatch Yard, Specimen Gallery |
| **Specimen Gallery** | `specimen_gallery` | Quiet and lit from within: rows of green-blue glass cases, each with something pale in it, each with a small card in a neat hand | LAB-HERO-SPECIMEN-WALL | 72.0 x 56.0 | Cold Store (chest); Specimen Card (lore); Orderly (vignette); Specimen Shrine (shrine); Down the Rows (vista) | Decontamination Corridor, Records and Break Room, Glass Tank Hall |
| **Records and Break Room** | `records_break_room` | The one warm thing in a cold building: desks, mugs, a child's drawing pinned over a kettle | LAB-HERO-BREAK-ROOM | 60.0 x 52.0 | Lunch Locker (chest); Notes on the Subject (lore); Child Drawing (lore); Research Assistant (vignette); Mug Shrine (shrine) | Specimen Gallery, Glass Tank Hall |
| **Glass Tank Hall** | `glass_tank_hall` | A cathedral of glass: four great tanks in four colours, humming, with the bright stillness of something drained and kept | LAB-HERO-TANK-RED | 72.0 x 60.0 | Keycard Safe (chest); Draining Log (lore); Intercom (vignette); Four-Colour Shrine (shrine); Under the Tanks (vista) | Specimen Gallery, Records and Break Room, The Path-ology Lab |

A 15-20 second walk is about 75-100 m at the 4.9 m/s walking pace; each sub-area lists 4 or more points of interest placed in walking order along its paths (chests, vistas, vignettes, lore pages, a rare card shrine, a lever).

## Loops, shortcuts, secrets

* Loops: every sub-area has at least one exit besides the way in (or a chest / shrine as the reward for the dead end); the links are in the table above and in `data/subareas/pathology_lab/`.
* Secrets: the shrines and the far-corner chests.

## Where existing content goes

The Lab dungeon is still the 14-node 2D map and still starts from the forest hatch (`Session.enter_lab`). The Hatch Yard and the wings above it are a walkable antechamber with the same descent; the rescuer stands in the yard.

## New content

5 chests (rewards drawn from the zone's own chest tables: gold, items, cards), 5 card shrines, 6 lore pages, 5 vignettes, 4 vistas, 0 lever shortcuts. No new economy: `SubAreaRewards` reuses `ZoneDef.chest_rewards` and docs/design/progression.md is unchanged.

## Status

Planned, blocked out (scenes load from `data/subareas`), asset list `docs/art/zone_kits/pathology_lab.md`, paint-over inputs `docs/art/paintover_inputs/pathology_lab/`, camera contact sheet `docs/art/zone_plans_shots/pathology_lab.png`. Details and numbers: `docs/overnight_report.md`.
