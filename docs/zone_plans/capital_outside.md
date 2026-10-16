# The Capital: Outside: zone plan

Art Bible row: flat eerie overcast dusk; purple rift glow; palette #8C8A86, #5E5B57, #B9B2A4, #9B59D0, #D8D0C0; mood bleak, uneasy, drained; building language ruined outposts, broken roads, the huge perfect walls; shared kit broken and ashen; cracked road and ash ground. Style file `data/zone_styles/capital_outside.json` (preset `capital_outskirts`). Kit: not yet imported (asset list `docs/art/zone_kits/capital_outside.md`).

**One walkable area** (Art Bible G-07, `docs/design/subarea_removal.md`): the Capital outside the wall is the southern half of the one scene `capital_zone.tscn` (the inside is the northern half; the wall passage joins them). There are no sub-area scenes; variety comes from the regions below. Every dungeon is node-based from an entrance in the zone.

## Regions (in the one Capital scene, south of the wall)

| Region | What is there | Hero landmark (concept needed) |
|---|---|---|
| The Gate Road (hub) | the arrival from town and the way home, Captain Spotless and the gate guards, the queue | the great wall (9 m) and the Approved Gate (14 m towers); Primm's Castle over it |
| The Resistance camp | Kestrel, the fire, two tents, a lean-to, a lantern rope (the Crease, with Wren, Fig's black market, the heal and the station, stays the underground hall: CAP-1) | the camp stand-in |
| The rift fields | open rifts and crystals | CAPO-HERO-RIFT-A / RIFT-B (region landmarks when their art exists) |
| The ruined outpost | the old guard post | CAPO-HERO-BROKEN-WATCHTOWER |
| The Old Service Tunnels entrance | the mini dungeon door in the wall | CAPO-HERO-SERVICE-TUNNEL |
| The wall passage | the secret way inside | |

## Dungeons (node maps)

| Dungeon | Entrance in the zone |
|---|---|
| Mini: the Old Service Tunnels | the `mini_dungeon` spot outside the wall |
| Side: S-CAP | unlocked by its quest |
| Main: Primm's Castle | inside the wall (see `capital_inside.md`) |

## What the removed sub-areas left behind

Nothing was kept: the Rift Fields, Ruined Outpost and Tunnel Entrance scenes were stand-in blockouts (no modelled landmark); their chests, shrines, boards, vistas, vignettes and the wall lever are listed in `docs/design/subarea_removal.md`. The zone's existing content is untouched.

## Layout

Fixed by the Capital layout pass (`docs/art/capital_slice.md`): routes, regions, clearances and stand-ins; paint-over inputs `docs/art/paintover_inputs/capital/PO-CAP-*.png` from `CapitalLayout.PO_CAMERAS`.

## Art status

Paint-over input `docs/art/paintover_inputs/capital_outside/PO-CAPITAL-OUTSIDE-HUB.png`; contact sheet `docs/art/zone_plans_shots/capital_outside.png`.
