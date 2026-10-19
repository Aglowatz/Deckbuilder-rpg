# Bot report

Written by the playthrough bot (`bash tools/run_tour_bot.sh`, `tools/tour_bot.gd`) on 2026-10-19T02:09:47, 1.0 minutes.

- Areas: forest, town, beefcake, necrocrat, gourmand, refusemancer, capital
- Spots used (NPCs, shops, signs, chests...): 18
- Menus opened: deck_station, codex, character_screen, quest_log, full_map, wardrobe, vendor, item_vendor, pack_vendor
- Battles: 
- Errors: 0, warnings: 0

## Frames over 33 ms

| Area | Frames | Over 33 ms | Worst (ms) |
|---|---|---|---|
| town | 2908 | 80 | 214 |

## Slowest moments (worst frame during one action)

- town: open character_screen: 214 ms
- town: use deck: 152 ms
- town: use pack_vendor: 148 ms
- town: use vendor: 130 ms
- town: use item_vendor: 116 ms
- town: use codex: 106 ms
- town: open deck_station: 91 ms
- town: open deck_station (again): 88 ms
- town: use notice_board: 80 ms
- town: use tailor: 76 ms
- town: use elder: 62 ms
- town: use chest: 61 ms
- town: open quest_log: 57 ms
- town: open vendor: 56 ms
- town: use alchemist: 54 ms

## Where the slow frames are (frames over 33 ms per action, top 15)

- town: use vendor: 13
- town: use deck: 6
- town: open deck_station: 6
- town: open deck_station (again): 5
- town: use equipment_vendor: 5
- town: use tailor: 4
- town: use item_vendor: 4
- town: open codex (again): 3
- town: use pack_vendor: 3
- town: open vendor: 3
- town: open vendor (again): 3
- town: use well: 3
- town: use alchemist: 2
- town: use notice_board: 2
- town: use elder: 2

## Errors

None.

## Warnings

None.

## Log

