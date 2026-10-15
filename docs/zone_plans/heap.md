# The Verdant Dump: zone plan

Art Bible row: golden-hour sunset; warm haze, long shadows, fireflies; palette #7C8F45, #B5552D, #E3A857, #5C6B5E, #8B6D4C, #E9D8A6; mood scrappy, hopeful, nature reclaiming junk; building language patched shacks of scrap metal and old doors, overgrown with moss and vines, rusty windmills; shared kit in rusted metal, mossy wood, patchwork panels; junk gravel and compost ground. Style file `data/zone_styles/heap.json`. Kit: not yet imported (asset list `docs/art/zone_kits/heap.md`). The layout was fixed for the art pass on 2026-10-15 (`docs/art/heap_slice.md`, VD-1... in `docs/design/open_questions.md`).

**One walkable area** (Art Bible G-07, `docs/design/subarea_removal.md`): the whole zone is the scene `heap_zone.tscn`. There are no sub-area scenes; variety comes from the regions below. Every dungeon is node-based from an entrance in the zone.

## Regions (all in the one scene; `HeapLayout.REGION_IDS`)

| Region | What is there | Stand-in now, hero landmark when its concept exists |
|---|---|---|
| Compost Commons (hub, `commons`) | the arrival bridge, Brother Bramble, Gristle's shop, the Harvest Meal, Wren and the boar stable, the Rift Express, the compost bin, the trough, the shrine, the barn | the greenhouse stand-in at the plaza's centre (a concept is needed: the greenhouse centrepiece) |
| The Junk Peaks (`peaks`) | Mount Scrapmore with the county fair (Rhonda's minigame) at its foot, the scree fields and the scrap barn | HEAP-HERO-JUNK-MOUNTAIN (a view beyond the north-east corner, a mound stand-in now) |
| The Farm Rows (`farm`) | the crop plots, Thistlewick's quiz in the grove, the pickups, the animals, the giant chest | HEAP-HERO-RUSTY-WINDMILL (a region landmark at the rows' west edge, a windmill stand-in now) |
| The Stream, the Dam and the Vine Bridges (`stream`) | the water, the three vine bridges and their sprout mounds, Druid Sorrel, the dam, the goat stable, the bank roads | |
| The Wetlands (`wetlands`) | the district behind the junk barricade, reeds, the corruption gradient, the road to the Rotheart's root gate (the main dungeon's door) | HEAP-HERO-ROTHEART (a view beyond the north rim at castle scale, a giant-tree stand-in now) |
| The Throne Approach (`throne`) | the avenue through the west gap past Rust Peak (the Seed Shrine puzzle on its summit) to the throne's steps, the Landfill Depths door (the side dungeon's) | HEAP-HERO-TRASH-PANDA-THRONE (beyond the north-west rim with its steps on the land, a throne stand-in now) |

When the zone kit is dressed (the playbook), each hero landmark above replaces its stand-in in place by the declutter rules (section 5, SR-8); none gets a scene of its own.

## Dungeons (node maps)

| Dungeon | Entrance in the zone |
|---|---|
| Main: D-ROT, the Rotheart | the `main_dungeon` spot at the root gate (50, 9.2) in the wetlands |
| Side: S-REF, the Trash Panda Throne | the `mini_dungeon` spot ("The Landfill Depths") at the throne's steps (31, 9.5) in the throne approach, unlocked by its quest (VD-1) |

## What the removed sub-areas left behind

Nothing was kept: the Junk Mountains, Farm Rows, Wildflower Wetlands and Throne Approach scenes were stand-in blockouts (no modelled landmark); their chests, shrines, boards, vistas and vignettes are listed in `docs/design/subarea_removal.md`. Their names live on as the regions above.

## Art status

Paint-over inputs `docs/art/paintover_inputs/heap/PO-DUMP-<REGION>.png` (one per region, Part B of `docs/art/heap_slice.md`; the cameras are `HeapLayout.PO_CAMERAS`); contact sheet `docs/art/zone_plans_shots/heap.png`.
