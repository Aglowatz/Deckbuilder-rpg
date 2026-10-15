# The Endless Buffet: zone plan

Art Bible row: warm dinner-time evening; candle and oven glow, steam; palette #F4D8B0, #E07A5F, #C98B3A, #F6B8C4, #6B8E3D, #7A4A2A; mood indulgent, warm, absurdly delicious; building language cake and pastry buildings, oven-brick kitchens, copper domes, tablecloth awnings; shared kit in frosting, biscuit, copper, oven brick; mashed-potato and biscuit ground. Style file `data/zone_styles/buffet.json`. Kit: not yet imported (sheet `data/source/buffet_kit.csv`, asset list `docs/art/zone_kits/buffet.md`).

**One walkable area** (Art Bible G-07, `docs/design/subarea_removal.md`): the whole zone is the scene `buffet_zone.tscn`. There are no sub-area scenes; variety comes from the regions below. Every dungeon is node-based from an entrance in the zone.

## Regions (all in the one scene)

| Region | What is there | Hero landmark (concept needed) |
|---|---|---|
| The Grand Dining Hall (hub) | Grandchef Escoffina and her quests, Odalys, Dolcetta's vendor, Pate's quiz, the Flambe minigame, the fortune cookie, the taste test, the oven, the soup fountain | the Test Kitchen facade (the main dungeon) |
| The soup rivers and bridges | the gravy river with its bridges | gravy river with bridges |
| The mashed-potato hills and the butte | the soft hills south of the hall | BUFF-HERO-POTATO-PEAK (a region landmark when its art exists) |
| The broccoli forest | the vegetable trees | BUFF-HERO-BROCCOLI-GIANT |
| The bakery and the cheddar cliffs | the ovens and the cliffs | BUFF-HERO-CAKE-CATHEDRAL |
| The Omakase cliffs | the way to the side dungeon | BUFF-HERO-OMAKASE-PAVILION (the entrance landmark of S-GOUR) |
| The pancake meadow | open ground | |

When the zone kit is dressed (the playbook), each hero landmark above stands in its region as a region landmark or a distant view by the declutter rules (section 5, SR-8); none gets a scene of its own.

## Dungeons (node maps)

| Dungeon | Entrance in the zone |
|---|---|
| Main: the Test Kitchen | the `main_dungeon` spot |
| Mini: the Walk-In Freezer | the `mini_dungeon` spot |
| Side: S-GOUR, Omakase | the Omakase door, unlocked by its quest |

## What the removed sub-areas left behind

Nothing was kept: the Mashed Potato Hills, Broccoli Forest, Bakery District and Omakase Cliffs scenes were stand-in blockouts (no modelled landmark); their chests, shrines, boards, vistas and vignettes are listed in `docs/design/subarea_removal.md`. The zone's existing content is untouched.

## Art status

Paint-over input `docs/art/paintover_inputs/buffet/PO-BUFFET-HUB.png`; contact sheet `docs/art/zone_plans_shots/buffet.png`; the approved paint-overs (PAINTOVER-BUFFET-*) show regions of this one map.
