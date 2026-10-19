# Bot report

Written by the playthrough bot (`bash tools/run_tour_bot.sh`, `tools/tour_bot.gd`) on 2026-10-18T22:44:22, 1.0 minutes.

- Areas: forest, town, beefcake, necrocrat, gourmand, refusemancer, capital
- Spots used (NPCs, shops, signs, chests...): 18
- Menus opened: deck_station, codex, character_screen, quest_log, full_map, wardrobe, vendor, item_vendor, pack_vendor
- Battles: 
- Errors: 0, warnings: 0

## Frames over 33 ms

| Area | Frames | Over 33 ms | Worst (ms) |
|---|---|---|---|
| town | 2935 | 45 | 143 |

## Slowest moments (worst frame during one action)

- town: open character_screen: 143 ms
- town: use deck: 137 ms
- town: use vendor: 124 ms
- town: use pack_vendor: 108 ms
- town: use item_vendor: 91 ms
- town: open vendor (again): 86 ms
- town: open deck_station: 84 ms
- town: open deck_station (again): 78 ms
- town: use codex: 74 ms
- town: open vendor: 68 ms
- town: use tailor: 46 ms
- town: use well: 42 ms
- town: use equipment_vendor: 42 ms
- town: open full_map: 41 ms
- town: use signpost_4: 41 ms

## Where the slow frames are (frames over 33 ms per action, top 15)

- town: use vendor: 13
- town: use deck: 6
- town: open vendor (again): 3
- town: open vendor: 3
- town: use equipment_vendor: 2
- town: open deck_station: 2
- town: open deck_station (again): 2
- town: open item_vendor (again): 1
- town: open item_vendor: 1
- town: open full_map: 1
- town: open character_screen: 1
- town: open codex (again): 1
- town: open codex: 1
- town: use tailor: 1
- town: use pack_vendor: 1

## Errors

None.

## Warnings

None.

## Log

