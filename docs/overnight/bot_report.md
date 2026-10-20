# Bot report

Written by the playthrough bot (`bash tools/run_tour_bot.sh`, `tools/tour_bot.gd`) on 2026-10-20T03:11:38, 8.6 minutes.

- Areas: forest, town, beefcake, necrocrat, gourmand, refusemancer, capital
- Spots used (NPCs, shops, signs, chests...): 275
- Menus opened: deck_station, codex, character_screen, quest_log, full_map, wardrobe, vendor, item_vendor, pack_vendor
- Battles: beefcake (Flexing Brute), necrocrat (Shambling Middle Manager), gourmand (Meatloaf Golem), refusemancer (Mossy Trash Golem), final (Compliance Officer)
- Errors: 0, warnings: 0

## Frames over 33 ms

| Area | Frames | Over 33 ms | Worst (ms) |
|---|---|---|---|
| forest | 61 | 0 | 32 |
| town | 2732 | 78 | 186 |
| beefcake | 2521 | 29 | 73 |
| beefcake battle | 241 | 0 | 18 |
| necrocrat | 3074 | 26 | 83 |
| necrocrat battle | 241 | 0 | 18 |
| gourmand | 2686 | 14 | 71 |
| gourmand battle | 241 | 0 | 18 |
| refusemancer | 3994 | 22 | 83 |
| refusemancer battle | 241 | 0 | 20 |
| final | 8526 | 49 | 117 |
| final battle | 241 | 0 | 19 |

## Slowest moments (worst frame during one action)

- town: use pack_vendor: 186 ms
- town: use deck: 162 ms
- town: open full_map: 120 ms
- town: open deck_station: 117 ms
- final: use complaint_1: 117 ms
- final: use seal_out_a: 115 ms
- town: use well: 115 ms
- town: open vendor (again): 111 ms
- final: use fig: 105 ms
- town: open vendor: 102 ms
- town: use notice_board: 95 ms
- town: open quest_log: 88 ms
- town: use item_vendor: 85 ms
- town: open deck_station (again): 85 ms
- necrocrat: use sign_22: 83 ms

## Where the slow frames are (frames over 33 ms per action, top 15)

- town: open vendor: 12
- town: open vendor (again): 9
- town: use deck: 6
- final: use fig: 6
- town: use equipment_vendor: 6
- final: use spotless: 5
- beefcake: use brenda: 5
- town: use vendor: 4
- necrocrat: use barnaby: 4
- gourmand: use odalys: 4
- gourmand: use minigame: 4
- town: use item_vendor: 4
- final: use wren: 4
- beefcake: use tony: 4
- refusemancer: use sign_1: 3

## Errors

None.

## Warnings

None.

## Log

- forest: no spot list to tour
