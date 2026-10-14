# The Verdant Dump: zone plan

Art Bible row: golden-hour sunset; warm haze, long shadows, fireflies; palette #7C8F45, #B5552D, #E3A857, #5C6B5E, #8B6D4C, #E9D8A6; mood scrappy, hopeful, nature reclaiming junk; building language patched shacks of scrap metal and old doors, overgrown with moss and vines, rusty windmills; material swaps shared kit in rusted metal, mossy wood, patchwork panels; junk gravel and compost ground. Style file `data/zone_styles/heap.json`. Data `data/subareas/heap/`.

Hero landmarks (Art Bible): Junk mountain, rusty windmill, the Rotheart tree (in the distance), Trash Panda Throne.

## Structure (G-07)

| Place | Scene | Mood | Hero landmark stand-in | Size (m) | Points of interest | Exits |
|---|---|---|---|---|---|---|
| **Compost Commons** (hub) | the existing scene `heap_zone.tscn` | existing | existing landmarks | existing | all existing content | gates to Farm Rows, Junk Mountains, Wildflower Wetlands |
| **Junk Mountains** | `junk_mountains` | Rusty gold in a long sunset: hills of everything anyone ever threw out, with moss on top and goats on the very top | HEAP-HERO-JUNK-MOUNTAIN | 76.0 x 66.0 | Dented Safe (chest); Suitcase (chest); Collector Note (lore); Picker (vignette); Summit Seat (vista); Hubcap Shrine (shrine) | Compost Commons, Throne Approach |
| **Farm Rows** | `farm_rows` | Hopeful and crooked: tidy rows of vegetables growing out of old tyres, a goat in charge of morale | HEAP-HERO-RUSTY-WINDMILL | 76.0 x 62.0 | Seed Tin (chest); Hubcap Hoard (chest); Rota Board (lore); Tyre Farmer (vignette); Scarecrow Shrine (shrine) | Compost Commons, Wildflower Wetlands |
| **Wildflower Wetlands** | `wildflower_wetlands` | Soft, wet and luminous: reeds, still water the colour of tea, flowers refusing to be tidy, fireflies starting | HEAP-HERO-ROTHEART | 72.0 x 60.0 | Reed Basket (chest); Naturalist Page (lore); Frog Philosopher (vignette); Bog Shrine (shrine); Firefly Hour (vista) | Farm Rows, Throne Approach |
| **Throne Approach** | `throne_approach` | Grand in the way only rubbish can be: a road of old doors leading to a throne of every chair ever replaced | HEAP-HERO-TRASH-PANDA-THRONE | 72.0 x 66.0 | Royal Hamper (chest); Proclamation (lore); Herald (vignette); Bottlecap Shrine (shrine); Look Back (vista) | Junk Mountains, Wildflower Wetlands |

A 15-20 second walk is about 75-100 m at the 4.9 m/s walking pace; each sub-area lists 4 or more points of interest placed in walking order along its paths (chests, vistas, vignettes, lore pages, a rare card shrine, a lever).

## Loops, shortcuts, secrets

* Loops: every sub-area has at least one exit besides the way in (or a chest / shrine as the reward for the dead end); the links are in the table above and in `data/subareas/heap/`.
* Secrets: the shrines and the far-corner chests.

## Where existing content goes

Everything stays in the Compost Commons scene: Compostella, Marigold, Hob's vendor (Gristle), Thistlewick's quiz, Rhonda's minigame, the compost bin, the shrine, the stables, the stream, the dam and gate barricades, the Landfill Depths mini dungeon, the main dungeon, the giant chest, the vault lever, bean / fertiliser / junk pickups, the vine bridges and 14 hidden chests.

## New content

6 chests (rewards drawn from the zone's own chest tables: gold, items, cards), 4 card shrines, 4 lore pages, 4 vignettes, 3 vistas, 0 lever shortcuts. No new economy: `SubAreaRewards` reuses `ZoneDef.chest_rewards` and docs/design/progression.md is unchanged.

## Status

Planned, blocked out (scenes load from `data/subareas`), asset list `docs/art/zone_kits/heap.md`, paint-over inputs `docs/art/paintover_inputs/heap/`, camera contact sheet `docs/art/zone_plans_shots/heap.png`. Details and numbers: `docs/overnight_report.md`.
