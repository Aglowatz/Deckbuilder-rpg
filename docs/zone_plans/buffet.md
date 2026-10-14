# The Endless Buffet: zone plan

Art Bible row: warm dinner-time evening; candle and oven glow, steam; palette #F4D8B0, #E07A5F, #C98B3A, #F6B8C4, #6B8E3D, #7A4A2A; mood indulgent, warm, absurdly delicious; building language cake and pastry buildings, oven-brick kitchens, copper domes, tablecloth awnings; material swaps shared kit in frosting, biscuit, copper, oven brick; mashed-potato and biscuit ground. Style file `data/zone_styles/buffet.json`. Data `data/subareas/buffet/`.

Hero landmarks (Art Bible): Cake cathedral, gravy river with bridges, broccoli forest, the Test Kitchen facade, Omakase cliffs.

## Structure (G-07)

| Place | Scene | Mood | Hero landmark stand-in | Size (m) | Points of interest | Exits |
|---|---|---|---|---|---|---|
| **Grand Dining Hall** (hub) | the existing scene `buffet_zone.tscn` | existing | existing landmarks | existing | all existing content | gates to Bakery District, Broccoli Forest, Mashed Potato Hills |
| **Mashed Potato Hills** | `mashed_potato_hills` | Soft and rolling, warm to the touch: gravy streams, butter-yellow light, a faint smell of dinner being thought about | BUFF-HERO-POTATO-PEAK | 80.0 x 64.0 | Tureen (chest); Butter Crock (chest); Recipe Card (lore); Hill Cook (vignette); Gravy Boat Shrine (shrine); Crest of the Hills (vista) | Grand Dining Hall, Bakery District, Omakase Cliffs |
| **Broccoli Forest** | `broccoli_forest` | Green, deep and slightly steamy: trees that are very obviously vegetables and refuse to discuss it | BUFF-HERO-BROCCOLI-GIANT | 72.0 x 64.0 | Colander Chest (chest); Forager Notes (lore); Forager (vignette); Herb Shrine (shrine); Under the Canopy (vista) | Grand Dining Hall, Bakery District |
| **Bakery District** | `bakery_district` | Warm, pink and golden: oven glow in every window, a queue of loaves that all look pleased with themselves | BUFF-HERO-CAKE-CATHEDRAL | 76.0 x 62.0 | Proving Drawer (chest); Day Menu (lore); Master Baker (vignette); Rising Shrine (shrine); Sugar Spires (vista) | Grand Dining Hall, Mashed Potato Hills, Broccoli Forest |
| **Omakase Cliffs** | `omakase_cliffs` | Cool, bright and slightly formal: white stone terraces over a sea of rice, a chef somewhere deciding about you | BUFF-HERO-OMAKASE-PAVILION | 68.0 x 60.0 | Lacquer Box (chest); Course Card (lore); Itamae (vignette); Chef Knife Shrine (shrine); Terrace Edge (vista) | Mashed Potato Hills |

A 15-20 second walk is about 75-100 m at the 4.9 m/s walking pace; each sub-area lists 4 or more points of interest placed in walking order along its paths (chests, vistas, vignettes, lore pages, a rare card shrine, a lever).

## Loops, shortcuts, secrets

* Loops: every sub-area has at least one exit besides the way in (or a chest / shrine as the reward for the dead end); the links are in the table above and in `data/subareas/buffet/`.
* Secrets: the shrines and the far-corner chests.

## Where existing content goes

Everything stays in the Dining Hall scene: Grandchef Escoffina and her quests, Odalys, Dolcetta's vendor, the quiz (Pate), the Flambe minigame, the fortune cookie, the taste test, the oven, the soup fountain, the Walk-In Freezer mini dungeon, the main dungeon, the three progression gates, ingredient pickups, the giant chest, the vault lever and 14 hidden chests across the rafts, butte, cheddar cliffs and pancake meadow.

## New content

5 chests (rewards drawn from the zone's own chest tables: gold, items, cards), 4 card shrines, 4 lore pages, 4 vignettes, 4 vistas, 0 lever shortcuts. No new economy: `SubAreaRewards` reuses `ZoneDef.chest_rewards` and docs/design/progression.md is unchanged.

## Status

Planned, blocked out (scenes load from `data/subareas`), asset list `docs/art/zone_kits/buffet.md`, paint-over inputs `docs/art/paintover_inputs/buffet/`, camera contact sheet `docs/art/zone_plans_shots/buffet.png`. Details and numbers: `docs/overnight_report.md`.
