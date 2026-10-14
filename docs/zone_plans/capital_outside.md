# The Capital: Outside: zone plan

Art Bible row: flat eerie overcast dusk; purple rift glow; palette #8C8A86, #5E5B57, #B9B2A4, #9B59D0, #D8D0C0; mood bleak, uneasy, drained; building language ruined outposts, broken roads, the huge perfect walls; material swaps shared kit broken and ashen; cracked road and ash ground. Style file `data/zone_styles/capital_outside.json`. Data `data/subareas/capital_outside/`.

Hero landmarks (Art Bible): The great white walls and gate, open rifts, the Old Service Tunnels entrance, the secret wall passage.

## Structure (G-07)

| Place | Scene | Mood | Hero landmark stand-in | Size (m) | Points of interest | Exits |
|---|---|---|---|---|---|---|
| **The Gate Road** (hub) | the existing scene `capital_zone.tscn` | existing | existing landmarks | existing | all existing content | gates to Rift Fields, Ruined Outpost, Tunnel Entrance |
| **Rift Fields** | `rift_fields` | Flat, ashen and humming: purple tears hanging in the air above cracked ground, crystals growing where the light leaks | CAPO-HERO-RIFT-A | 80.0 x 64.0 | Scavenger Pack (chest); Survey Stake (lore); Rift Scout (vignette); Rift Shard Shrine (shrine); Under the Walls (vista) | The Gate Road, Ruined Outpost |
| **Ruined Outpost** | `ruined_outpost` | Cold, grey and empty: a guard post that was told to hold and held until there was nothing to hold, with a lamp still burning | CAPO-HERO-BROKEN-WATCHTOWER | 72.0 x 60.0 | Duty Locker (chest); Watch Log (lore); Last Sentry (vignette); Soldier Shrine (shrine); Rooftop of the Hall (vista) | The Gate Road, Rift Fields, Tunnel Entrance |
| **Tunnel Entrance** | `tunnel_entrance` | Close and sullen: a service door in the wall of the world, rust, drip and a draught that smells of old machinery | CAPO-HERO-SERVICE-TUNNEL | 64.0 x 56.0 | Maintenance Chest (chest); Walled-up Cache (chest); Wall Lever (shortcut); Service Plate (lore); Gear Shrine (shrine); Foot of the Wall (vista) | The Gate Road, Ruined Outpost |

A 15-20 second walk is about 75-100 m at the 4.9 m/s walking pace; each sub-area lists 4 or more points of interest placed in walking order along its paths (chests, vistas, vignettes, lore pages, a rare card shrine, a lever).

## Loops, shortcuts, secrets

* Loops: every sub-area has at least one exit besides the way in (or a chest / shrine as the reward for the dead end); the links are in the table above and in `data/subareas/capital_outside/`.
* Shortcut / secret: Tunnel Entrance: Wall Lever opens a barrier (wall_slab).

## Where existing content goes

Everything stays in the Capital scene: the checkpoints, the Resistance camp and Kestrel, Fig's vendor, the Old Service Tunnels mini dungeon, the wall passage secret, the rift stations and the Rift Express, the heal spot, Wren and the other hub NPCs.

## New content

4 chests (rewards drawn from the zone's own chest tables: gold, items, cards), 3 card shrines, 3 lore pages, 2 vignettes, 3 vistas, 1 lever shortcuts. No new economy: `SubAreaRewards` reuses `ZoneDef.chest_rewards` and docs/design/progression.md is unchanged.

## Status

Planned, blocked out (scenes load from `data/subareas`), asset list `docs/art/zone_kits/capital_outside.md`, paint-over inputs `docs/art/paintover_inputs/capital_outside/`, camera contact sheet `docs/art/zone_plans_shots/capital_outside.png`. Details and numbers: `docs/overnight_report.md`.
