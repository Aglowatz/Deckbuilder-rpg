# The Starting Forest: zone plan

Art Bible row: early morning; mist and soft god rays through the canopy; palette #3F5E3A, #8DAA6B, #C9B98A, #6B4E3A, #A8C3C9; mood quiet, mysterious, a fresh start; building language almost no buildings: a ruined shrine, an old waystone, a rope bridge, the cave mouth; material swaps stone and timber from the shared kit, heavily mossed. Style file `data/zone_styles/starting_forest.json`. Data `data/subareas/starting_forest/`.

Hero landmarks (Art Bible): Ancient waystone, the Forgotten Cave entrance, a fallen giant tree, the secret tunnel.

## Structure (G-07)

| Place | Scene | Mood | Hero landmark stand-in | Size (m) | Points of interest | Exits |
|---|---|---|---|---|---|---|
| **The Clearing** (hub) | the existing scene `starting_area.tscn` | existing | existing landmarks | existing | all existing content | gates to The Old Path, Mossy Hollow, Cave Mouth |
| **The Old Path** | `old_path` | Misty and hushed: a track the forest has nearly taken back, with a rope bridge and a lot of light coming down in stripes | START-HERO-ROPE-BRIDGE | 72.0 x 64.0 | Hollow Stump (chest); The Rope Bridge (vista); Carved Marker (lore); Fellow Traveller (vignette); Wayside Shrine (shrine) | The Clearing, Mossy Hollow |
| **Mossy Hollow** | `mossy_hollow` | Green and soft: a bowl in the ground where the fallen giant tree lies and everything grows on it | START-HERO-FALLEN-GIANT | 64.0 x 56.0 | Hollow Trunk (chest); Ring of Mushrooms (lore); Hollow Hermit (vignette); On the Fallen Giant (vista); Mossy Shrine (shrine) | The Clearing, The Old Path, Cave Mouth |
| **Cave Mouth** | `cave_mouth` | Cool and watchful: stone, ferns, a dark opening that breathes out | START-HERO-CAVE-MOUTH | 60.0 x 56.0 | Pilgrim Cache (chest); Cave Marker (lore); Hidden Lever (shortcut); Before the Dark (vista); Ruined Shrine (shrine) | The Clearing, Mossy Hollow, Hidden Tunnel |
| **The Hidden Tunnel** | `hidden_tunnel` | Close and glowing: roots in the ceiling, old lamps, someone left a blanket | START-HERO-TUNNEL-ARCH | 48.0 x 40.0 | Forgotten Strongbox (chest); Scratched Tally (lore); Lantern Shrine (shrine); Glow Roots (vista) | Cave Mouth |

A 15-20 second walk is about 75-100 m at the 4.9 m/s walking pace; each sub-area lists 4 or more points of interest placed in walking order along its paths (chests, vistas, vignettes, lore pages, a rare card shrine, a lever).

## Loops, shortcuts, secrets

* Loops: every sub-area has at least one exit besides the way in (or a chest / shrine as the reward for the dead end); the links are in the table above and in `data/subareas/starting_forest/`.
* Shortcut / secret: Cave Mouth: Hidden Lever opens a barrier (tunnel_rock).

## Where existing content goes

Everything stays in the Clearing scene: the awakening and the rescuer, Elder Maren, the Forgotten Cave gate and tutorial dungeon, the hidden tunnel secret and its three hidden chests, the Path-ology Lab hatch and the postgame Rift station and rescuer. The new scenes appear after the trial is cleared, so the prologue is untouched.

## New content

4 chests (rewards drawn from the zone's own chest tables: gold, items, cards), 4 card shrines, 4 lore pages, 2 vignettes, 4 vistas, 1 lever shortcuts. No new economy: `SubAreaRewards` reuses `ZoneDef.chest_rewards` and docs/design/progression.md is unchanged.

## Status

Planned, blocked out (scenes load from `data/subareas`), asset list `docs/art/zone_kits/starting_forest.md`, paint-over inputs `docs/art/paintover_inputs/starting_forest/`, camera contact sheet `docs/art/zone_plans_shots/starting_forest.png`. Details and numbers: `docs/overnight_report.md`.
