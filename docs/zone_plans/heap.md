# The Verdant Dump: zone plan

Art Bible row: golden-hour sunset; warm haze, long shadows, fireflies; palette #7C8F45, #B5552D, #E3A857, #5C6B5E, #8B6D4C, #E9D8A6; mood scrappy, hopeful, nature reclaiming junk; building language patched shacks of scrap metal and old doors, overgrown with moss and vines, rusty windmills; shared kit in rusted metal, mossy wood, patchwork panels; junk gravel and compost ground. Style file `data/zone_styles/heap.json`. Kit: not yet imported (asset list `docs/art/zone_kits/heap.md`).

**One walkable area** (Art Bible G-07, `docs/design/subarea_removal.md`): the whole zone is the scene `heap_zone.tscn`. There are no sub-area scenes; variety comes from the regions below. Every dungeon is node-based from an entrance in the zone.

## Regions (all in the one scene)

| Region | What is there | Hero landmark (concept needed) |
|---|---|---|
| Compost Commons (hub) | Compostella, Marigold, Hob's vendor (Gristle), Thistlewick's quiz, Rhonda's minigame, the compost bin, the shrine, the stables | |
| The junk peaks | the hills of junk | HEAP-HERO-JUNK-MOUNTAIN (a region landmark when its art exists) |
| The farm rows | tyre beds, the crops grown by the druid, the goats | HEAP-HERO-RUSTY-WINDMILL |
| The stream, the dam and the vine bridges | the water, the dam and gate barricades, the beanstalk ladders | |
| The wetlands | reeds and wildflowers | HEAP-HERO-ROTHEART (in the distance) |
| The throne approach | the way to the side dungeon | HEAP-HERO-TRASH-PANDA-THRONE (the entrance landmark of S-REF) |

When the zone kit is dressed (the playbook), each hero landmark above stands in its region as a region landmark or a distant view by the declutter rules (section 5, SR-8); none gets a scene of its own.

## Dungeons (node maps)

| Dungeon | Entrance in the zone |
|---|---|
| Main | the `main_dungeon` spot |
| Mini: the Landfill Depths | the `mini_dungeon` spot |
| Side: S-REF, the Trash Panda Throne | unlocked by its quest |

## What the removed sub-areas left behind

Nothing was kept: the Junk Mountains, Farm Rows, Wildflower Wetlands and Throne Approach scenes were stand-in blockouts (no modelled landmark); their chests, shrines, boards, vistas and vignettes are listed in `docs/design/subarea_removal.md`. The zone's existing content is untouched.

## Art status

Paint-over input `docs/art/paintover_inputs/heap/PO-HEAP-HUB.png`; contact sheet `docs/art/zone_plans_shots/heap.png`.
