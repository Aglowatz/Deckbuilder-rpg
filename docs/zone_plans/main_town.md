# Crosspath: zone plan

Art Bible row: golden late afternoon; long warm shadows; lit windows and lanterns; palette #E8B86B, #F2E3C6, #C4573A, #6E8B4E, #5B4636, #6F8FB0; mood cozy, welcoming, home base; building language half-timbered storybook cottages and shops, stone foundations, red and slate roofs, flower boxes, hanging icon signs; material swaps current kit (env-*) as-is. Style file `data/zone_styles/main_town.json`. Data `data/subareas/main_town/`.

Hero landmarks (Art Bible): Fountain (redesign in palette), the four Path signpost plaza, graveyard chapel, lakeside dock, the Arena.

## Structure (G-07)

| Place | Scene | Mood | Hero landmark stand-in | Size (m) | Points of interest | Exits |
|---|---|---|---|---|---|---|
| **Market Square** (hub) | the existing scene `town.tscn` | existing | existing landmarks | existing | all existing content | gates to Residential Lanes, Lakeshore and Docks, Chapel Hill, Arena District |
| **Residential Lanes** | `residential_lanes` | Cozy and unhurried: washing lines, window boxes, somebody frying onions | TOWN-HERO-WASHING-TOWER | 72.0 x 60.0 | Cellar Hatch (chest); Lane Notice (lore); Neighbour (vignette); Rooftops (vista); Hearth Shrine (shrine) | Market Square, Chapel Hill |
| **Lakeshore and Docks** | `lakeshore_docks` | Golden and breezy: the lake takes the late sun and gives it back sideways | TOWN-HERO-DOCK | 76.0 x 60.0 | Tide Crate (chest); Net Basket (chest); Angler (vignette); End of the Pier (vista); Ferry Timetable (lore) | Market Square, Arena District |
| **Chapel Hill** | `chapel_hill` | Quiet and a little sad, with long shadows and nothing to be afraid of | TOWN-HERO-CHAPEL-LAWN | 68.0 x 60.0 | Sexton Box (chest); Weathered Stone (lore); Gardener (vignette); Quiet Shrine (shrine); Hill Crest (vista) | Market Square, Residential Lanes |
| **Arena District** | `arena_district` | Loud and golden: banners, a drum somewhere, a stall selling things shaped like swords | TOWN-HERO-ARENA-FACADE | 74.0 x 62.0 | Gladiator Locker (chest); Fixture Board (lore); Sword Seller (vignette); Victor Shrine (shrine); Gate View (vista) | Market Square, Lakeshore and Docks |

A 15-20 second walk is about 75-100 m at the 4.9 m/s walking pace; each sub-area lists 4 or more points of interest placed in walking order along its paths (chests, vistas, vignettes, lore pages, a rare card shrine, a lever).

## Loops, shortcuts, secrets

* Loops: every sub-area has at least one exit besides the way in (or a chest / shrine as the reward for the dead end); the links are in the table above and in `data/subareas/main_town/`.
* Secrets: the shrines and the far-corner chests.

## Where existing content goes

Everything stays in the town scene: Elder Maren and the Hall of Records, the card, potion, equipment, clothing and pack shops, the Deck Station inn, the Alchemist and the Arena (with its NPC challenges), the Graveyard cairn and its boss, the four zone passages and their guard NPCs, the Rift Express, the harbor chests and the giant chest, the hidden vendor, the four-lever Vault, the dev shrine, 12 hidden chests, the quest NPCs of the four Paths, and the Forgotten Cave road. The new scenes are walks beyond the square: Residential Lanes (west houses), Lakeshore and Docks (east harbor), Chapel Hill (the graveyard's chapel hill), Arena District (the Arena forecourt).

## New content

5 chests (rewards drawn from the zone's own chest tables: gold, items, cards), 3 card shrines, 4 lore pages, 4 vignettes, 4 vistas, 0 lever shortcuts. No new economy: `SubAreaRewards` reuses `ZoneDef.chest_rewards` and docs/design/progression.md is unchanged.

## Status

Planned, blocked out (scenes load from `data/subareas`), asset list `docs/art/zone_kits/main_town.md`, paint-over inputs `docs/art/paintover_inputs/main_town/`, camera contact sheet `docs/art/zone_plans_shots/main_town.png`. Details and numbers: `docs/overnight_report.md`.
