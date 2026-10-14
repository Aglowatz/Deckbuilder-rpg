# Primm Castle Grounds: zone plan

Art Bible row: cold, crisp morning; gleaming highlights; palette #FFFFFF, #D4AF37, #2E2A4F, #B8B8C8, #8E44AD; mood grand, cold, imposing; building language gleaming marble and gold palace, mirrors, colonnades; material swaps shared kit in marble and gold. Style file `data/zone_styles/castle_grounds.json`. Data `data/subareas/castle_grounds/`.

Hero landmarks (Art Bible): Palace facade, mirrored colonnade, the grand stair.

## Structure (G-07)

| Place | Scene | Mood | Hero landmark stand-in | Size (m) | Points of interest | Exits |
|---|---|---|---|---|---|---|
| **The Courtyard** (hub) | the existing scene `capital_zone.tscn` | existing | existing landmarks | existing | all existing content | gates to (entered from another sub-area) |
| **The Courtyard** | `courtyard` | Cold, crisp morning light on marble: a courtyard so clean the shadows look drawn on, and every window facing you | CAST-HERO-PALACE-FACADE | 76.0 x 66.0 | Guard Locker (chest); Dedication (lore); Gate Guard (vignette); Crown Shrine (shrine); In the Reflection (vista) | Palace Approach, Mirror Colonnade |
| **Mirror Colonnade** | `mirror_colonnade` | A long hall without a roof: columns, mirrors, and your own steps repeating a half-second late | CAST-HERO-MIRROR-COLONNADE | 74.0 x 56.0 | Frame Case (chest); Silvered Lever (shortcut); Hand Mirror (lore); Glass Shrine (shrine); Looking Glass (vista) | The Courtyard, Grand Stair, Palace Gardens |
| **The Grand Stair** | `grand_stair` | A staircase wide as a road and just as long, ending at a door small enough to feel the whole weight of the building above it | CAST-HERO-GRAND-STAIR | 72.0 x 66.0 | Regal Coffer (chest); Notice at the Foot (lore); Last Rest Shrine (shrine); Foot of the Stair (vista) | Mirror Colonnade, Primm Castle |
| **Palace Gardens** | `palace_gardens` | A secret garden clipped to within an inch of its life: topiary cones, mirror ponds, one rose that is allowed to be crooked | CAST-HERO-CROOKED-ROSE | 60.0 x 52.0 | Gardener Strongbox (chest); Gardener Note (lore); Hidden Rose Shrine (shrine); Mirror Pond (vista) | Mirror Colonnade |

A 15-20 second walk is about 75-100 m at the 4.9 m/s walking pace; each sub-area lists 4 or more points of interest placed in walking order along its paths (chests, vistas, vignettes, lore pages, a rare card shrine, a lever).

## Loops, shortcuts, secrets

* Loops: every sub-area has at least one exit besides the way in (or a chest / shrine as the reward for the dead end); the links are in the table above and in `data/subareas/castle_grounds/`.
* Shortcut / secret: Mirror Colonnade: Silvered Lever opens a barrier (garden_door).

## Where existing content goes

A new approach: the dungeon is still the 2D castle map, started from the same flow (`Session.enter_main_dungeon`) as the Capital's castle door. The Capital's own castle door keeps working.

## New content

4 chests (rewards drawn from the zone's own chest tables: gold, items, cards), 4 card shrines, 4 lore pages, 1 vignettes, 4 vistas, 1 lever shortcuts. No new economy: `SubAreaRewards` reuses `ZoneDef.chest_rewards` and docs/design/progression.md is unchanged.

## Status

Planned, blocked out (scenes load from `data/subareas`), asset list `docs/art/zone_kits/castle_grounds.md`, paint-over inputs `docs/art/paintover_inputs/castle_grounds/`, camera contact sheet `docs/art/zone_plans_shots/castle_grounds.png`. Details and numbers: `docs/overnight_report.md`.
