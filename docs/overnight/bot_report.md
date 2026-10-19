# Bot report

Written by the playthrough bot (`bash tools/run_tour_bot.sh`, `tools/tour_bot.gd`) on 2026-10-19T09:09:53, 9.1 minutes.

- Areas: forest, town, beefcake, necrocrat, gourmand, refusemancer, capital
- Spots used (NPCs, shops, signs, chests...): 275
- Menus opened: deck_station, codex, character_screen, quest_log, full_map, wardrobe, vendor, item_vendor, pack_vendor
- Battles: beefcake (Flexing Brute), necrocrat (Shambling Middle Manager), gourmand (Meatloaf Golem), refusemancer (Mossy Trash Golem), final (Compliance Officer)
- Errors: 0, warnings: 0

## Frames over 33 ms

| Area | Frames | Over 33 ms | Worst (ms) |
|---|---|---|---|
| forest | 60 | 0 | 27 |
| town | 2961 | 63 | 150 |
| beefcake | 2946 | 22 | 64 |
| beefcake battle | 241 | 0 | 18 |
| necrocrat | 3708 | 18 | 65 |
| necrocrat battle | 241 | 0 | 18 |
| gourmand | 3175 | 12 | 73 |
| gourmand battle | 241 | 0 | 18 |
| refusemancer | 4451 | 23 | 72 |
| refusemancer battle | 240 | 0 | 18 |
| final | 8754 | 37 | 123 |
| final battle | 241 | 0 | 18 |

## Slowest moments (worst frame during one action)

- town: use deck: 150 ms
- final: use sign_1: 123 ms
- final: use seal_out_a: 116 ms
- town: open vendor (again): 111 ms
- town: use pack_vendor: 104 ms
- final: use complaint_1: 92 ms
- town: open deck_station: 89 ms
- final: use fig: 85 ms
- town: open full_map: 78 ms
- town: use item_vendor: 77 ms
- town: open deck_station (again): 76 ms
- final: use fern: 75 ms
- gourmand: use pickup_hot_pepper: 73 ms
- final: use sign_34: 73 ms
- final: use pell: 73 ms

## Where the slow frames are (frames over 33 ms per action, top 15)

- town: open vendor: 9
- final: use wren: 7
- town: use deck: 6
- town: open vendor (again): 5
- town: use item_vendor: 5
- town: use elder: 4
- refusemancer: use marigold: 4
- town: use pack_vendor: 4
- necrocrat: use pip: 3
- necrocrat: use matching: 3
- necrocrat: use dolores: 3
- town: use tailor: 3
- town: use equipment_vendor: 3
- town: use notice_board: 3
- town: use vendor: 3

## Errors

None.

## Warnings

None.

## Log

- forest: no spot list to tour
