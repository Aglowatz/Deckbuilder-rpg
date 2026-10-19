# Bot report

Written by the playthrough bot (`bash tools/run_tour_bot.sh`, `tools/tour_bot.gd`) on 2026-10-18T23:28:45, 1.0 minutes.

- Areas: forest, town, beefcake, necrocrat, gourmand, refusemancer, capital
- Spots used (NPCs, shops, signs, chests...): 18
- Menus opened: deck_station, codex, character_screen, quest_log, full_map, wardrobe, vendor, item_vendor, pack_vendor
- Battles: 
- Errors: 0, warnings: 0

## Frames over 33 ms

| Area | Frames | Over 33 ms | Worst (ms) |
|---|---|---|---|
| town | 2959 | 45 | 148 |

## Slowest moments (worst frame during one action)

- town: open character_screen: 148 ms
- town: use deck: 141 ms
- town: use vendor: 120 ms
- town: use pack_vendor: 109 ms
- town: use item_vendor: 92 ms
- town: open deck_station (again): 85 ms
- town: open vendor (again): 80 ms
- town: open deck_station: 80 ms
- town: open vendor: 74 ms
- town: use codex: 74 ms
- town: use equipment_vendor: 61 ms
- town: open codex: 46 ms
- town: use tailor: 44 ms
- town: open codex (again): 44 ms
- town: open full_map: 44 ms

## Where the slow frames are (frames over 33 ms per action, top 15)

- town: use vendor: 11
- town: use deck: 6
- town: use equipment_vendor: 5
- town: open vendor (again): 3
- town: open vendor: 3
- town: open codex (again): 2
- town: open deck_station (again): 2
- town: open deck_station: 2
- town: use item_vendor: 2
- town: use tailor: 1
- town: use pack_vendor: 1
- town: open codex: 1
- town: open character_screen: 1
- town: open full_map: 1
- town: use codex: 1

## Errors

None.

## Warnings

None.

## Log

