# Crosspath: zone plan

Art Bible row: golden late afternoon; long warm shadows; lit windows and lanterns; palette #E8B86B, #F2E3C6, #C4573A, #6E8B4E, #5B4636, #6F8FB0; mood cozy, welcoming, home base; building language half-timbered storybook cottages and shops, stone foundations, red and slate roofs, flower boxes, hanging icon signs. Style file `data/zone_styles/main_town.json`; the town kit (48 ids) is in; the square was built from the Environment Kit (`docs/art/town_slice.md`).

**One walkable area** (Art Bible G-07, `docs/design/subarea_removal.md`): the whole town is the scene `town.tscn`. There are no sub-area scenes; variety comes from the regions below. Dungeons are node-based from entrances in the town (and the zones are reached through their passages at the map edges).

## Regions (all in the one scene)

| Region | What is there | Hero landmark |
|---|---|---|
| Market Square (hub) | the fountain, the four-Path signpost plaza, Elder Maren and the Hall of Records, the card, potion, equipment, clothing and pack shops, the Deck Station inn, the Rift Express | the fountain (redesign in palette) |
| The lanes | homes and cottages | TOWN-HERO-WASHING-TOWER (a region landmark when its art exists) |
| The harbor and docks | the lake, Shiro Swindle's giant chest | TOWN-HERO-DOCK |
| The graveyard | the chapel, the cairn and its boss | TOWN-HERO-CHAPEL-LAWN |
| The Arena | the Arena and its NPC challenges, the Alchemist | TOWN-HERO-ARENA-FACADE |
| The four passages | the ways into the Gainlands, the D.N.A., the Buffet and the Dump (and the Capital), each a walked gate or bridge | |

## Dungeons (node maps)

| Dungeon | Entrance |
|---|---|
| Side: S-TOWN | from the town (`Session.enter_town_side_dungeon`) |
| The Arena | the Arena building |

## What the removed sub-areas left behind

Nothing was kept: the Residential Lanes, Lakeshore and Docks, Chapel Hill and Arena District scenes were stand-in blockouts (no modelled landmark); their chests, shrines, boards, vistas and vignettes are listed in `docs/design/subarea_removal.md`. The town's existing content is untouched.

## Art status

Paint-over input `docs/art/paintover_inputs/main_town/PO-MAIN-TOWN-HUB.png`; contact sheet `docs/art/zone_plans_shots/main_town.png`; the approved paint-over PAINTOVER-TOWN is the style target of the whole game.
