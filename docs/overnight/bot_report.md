# Bot report

Written by the playthrough bot (`bash tools/run_tour_bot.sh`, `tools/tour_bot.gd`) on 2026-10-19T03:07:02, 9.0 minutes.

- Areas: forest, town, beefcake, necrocrat, gourmand, refusemancer, capital
- Spots used (NPCs, shops, signs, chests...): 275
- Menus opened: deck_station, codex, character_screen, quest_log, full_map, wardrobe, vendor, item_vendor, pack_vendor
- Battles: beefcake (Flexing Brute), necrocrat (Shambling Middle Manager), gourmand (Meatloaf Golem), refusemancer (Mossy Trash Golem), final (Compliance Officer)
- Errors: 0, warnings: 0

## Frames over 33 ms

| Area | Frames | Over 33 ms | Worst (ms) |
|---|---|---|---|
| forest | 60 | 0 | 17 |
| town | 2877 | 85 | 192 |
| beefcake | 2925 | 25 | 129 |
| beefcake battle | 241 | 0 | 18 |
| necrocrat | 3697 | 18 | 112 |
| necrocrat battle | 241 | 0 | 18 |
| gourmand | 3163 | 14 | 121 |
| gourmand battle | 241 | 0 | 18 |
| refusemancer | 4447 | 21 | 129 |
| refusemancer battle | 241 | 0 | 18 |
| final | 8747 | 39 | 137 |
| final battle | 241 | 0 | 18 |

## Slowest moments (worst frame during one action)

- town: open character_screen: 192 ms
- town: use vendor: 180 ms
- town: use deck: 178 ms
- town: use pack_vendor: 156 ms
- final: use fig: 137 ms
- refusemancer: use hob: 129 ms
- beefcake: use tony: 129 ms
- town: use codex: 123 ms
- town: use item_vendor: 122 ms
- gourmand: use dolcetta: 121 ms
- necrocrat: use pip: 112 ms
- town: open vendor (again): 108 ms
- final: use complaint_1: 103 ms
- town: open vendor: 99 ms
- town: open full_map: 95 ms

## Where the slow frames are (frames over 33 ms per action, top 15)

- town: open vendor: 16
- town: open vendor (again): 12
- town: use deck: 6
- final: use wren: 5
- town: open codex (again): 5
- town: use equipment_vendor: 5
- town: open deck_station (again): 5
- town: use item_vendor: 4
- town: open deck_station: 4
- beefcake: use brenda: 3
- refusemancer: use hob: 3
- refusemancer: use marigold: 3
- final: use fig: 3
- gourmand: use tarragon: 3
- gourmand: use odalys: 3

## Errors

None.

## Warnings

None.

## Log

- forest: no spot list to tour
