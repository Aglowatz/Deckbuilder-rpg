# Bot report

Written by the playthrough bot (`bash tools/run_tour_bot.sh`, `tools/tour_bot.gd`) on 2026-10-18T23:51:21, 9.0 minutes.

- Areas: forest, town, beefcake, necrocrat, gourmand, refusemancer, capital
- Spots used (NPCs, shops, signs, chests...): 275
- Menus opened: deck_station, codex, character_screen, quest_log, full_map, wardrobe, vendor, item_vendor, pack_vendor
- Battles: beefcake (Flexing Brute), necrocrat (Shambling Middle Manager), gourmand (Meatloaf Golem), refusemancer (Mossy Trash Golem), final (Compliance Officer)
- Errors: 0, warnings: 0

## Frames over 33 ms

| Area | Frames | Over 33 ms | Worst (ms) |
|---|---|---|---|
| forest | 60 | 0 | 25 |
| town | 2899 | 82 | 162 |
| beefcake | 2942 | 20 | 121 |
| beefcake battle | 240 | 0 | 18 |
| necrocrat | 3702 | 18 | 108 |
| necrocrat battle | 241 | 0 | 18 |
| gourmand | 3161 | 13 | 108 |
| gourmand battle | 241 | 0 | 19 |
| refusemancer | 4438 | 21 | 94 |
| refusemancer battle | 241 | 0 | 18 |
| final | 8750 | 36 | 125 |
| final battle | 241 | 0 | 18 |

## Slowest moments (worst frame during one action)

- town: open character_screen: 162 ms
- town: use vendor: 161 ms
- town: use pack_vendor: 158 ms
- town: use item_vendor: 157 ms
- town: use deck: 156 ms
- final: use fig: 125 ms
- beefcake: use tony: 121 ms
- final: use seal_out_a: 118 ms
- gourmand: use dolcetta: 108 ms
- necrocrat: use pip: 108 ms
- refusemancer: use hob: 94 ms
- town: open deck_station: 93 ms
- town: open deck_station (again): 91 ms
- final: use complaint_1: 86 ms
- town: open vendor (again): 85 ms

## Where the slow frames are (frames over 33 ms per action, top 15)

- town: open vendor: 13
- town: use vendor: 12
- town: open vendor (again): 7
- town: use deck: 6
- refusemancer: use marigold: 5
- beefcake: use sign_1: 4
- town: use equipment_vendor: 4
- town: use item_vendor: 4
- town: use elder: 4
- necrocrat: use barnaby: 3
- beefcake: use tony: 3
- beefcake: use brenda: 3
- town: use notice_board: 3
- necrocrat: use dolores: 2
- necrocrat: use pip: 2

## Errors

None.

## Warnings

None.

## Log

- forest: no spot list to tour
