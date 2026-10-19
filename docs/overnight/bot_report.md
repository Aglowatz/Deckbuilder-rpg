# Bot report

Written by the playthrough bot (`bash tools/run_tour_bot.sh`, `tools/tour_bot.gd`) on 2026-10-19T05:42:55, 9.1 minutes.

- Areas: forest, town, beefcake, necrocrat, gourmand, refusemancer, capital
- Spots used (NPCs, shops, signs, chests...): 275
- Menus opened: deck_station, codex, character_screen, quest_log, full_map, wardrobe, vendor, item_vendor, pack_vendor
- Battles: beefcake (Flexing Brute), necrocrat (Shambling Middle Manager), gourmand (Meatloaf Golem), refusemancer (Mossy Trash Golem), final (Compliance Officer)
- Errors: 0, warnings: 0

## Frames over 33 ms

| Area | Frames | Over 33 ms | Worst (ms) |
|---|---|---|---|
| forest | 61 | 1 | 38 |
| town | 2834 | 93 | 345 |
| beefcake | 2925 | 25 | 83 |
| beefcake battle | 241 | 0 | 18 |
| necrocrat | 3697 | 20 | 83 |
| necrocrat battle | 241 | 0 | 18 |
| gourmand | 3168 | 13 | 73 |
| gourmand battle | 241 | 0 | 18 |
| refusemancer | 4432 | 26 | 76 |
| refusemancer battle | 241 | 0 | 20 |
| final | 8727 | 48 | 121 |
| final battle | 241 | 0 | 18 |

## Slowest moments (worst frame during one action)

- town: open character_screen: 345 ms
- town: use item_vendor: 254 ms
- town: use vendor: 245 ms
- town: use deck: 167 ms
- town: use pack_vendor: 144 ms
- town: open full_map: 126 ms
- final: use fig: 121 ms
- final: use complaint_1: 113 ms
- final: use kestrel: 97 ms
- town: open vendor (again): 95 ms
- town: open deck_station: 88 ms
- town: open vendor: 88 ms
- town: use chest: 84 ms
- necrocrat: use sign_0: 83 ms
- town: use alchemist: 83 ms

## Where the slow frames are (frames over 33 ms per action, top 15)

- town: open vendor: 14
- town: open vendor (again): 11
- final: use wren: 6
- town: use item_vendor: 6
- necrocrat: use dolores: 5
- town: use deck: 5
- town: open deck_station (again): 5
- town: use equipment_vendor: 5
- necrocrat: use matching: 4
- town: open deck_station: 4
- final: use kestrel: 4
- refusemancer: use marigold: 4
- refusemancer: use hob: 4
- town: use notice_board: 4
- town: use elder: 4

## Errors

None.

## Warnings

None.

## Log

- forest: no spot list to tour
