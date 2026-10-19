# Bot report

Written by the playthrough bot (`bash tools/run_tour_bot.sh`, `tools/tour_bot.gd`) on 2026-10-19T01:24:30, 9.0 minutes.

- Areas: forest, town, beefcake, necrocrat, gourmand, refusemancer, capital
- Spots used (NPCs, shops, signs, chests...): 275
- Menus opened: deck_station, codex, character_screen, quest_log, full_map, wardrobe, vendor, item_vendor, pack_vendor
- Battles: beefcake (Flexing Brute), necrocrat (Shambling Middle Manager), gourmand (Meatloaf Golem), refusemancer (Mossy Trash Golem), final (Compliance Officer)
- Errors: 0, warnings: 0

## Frames over 33 ms

| Area | Frames | Over 33 ms | Worst (ms) |
|---|---|---|---|
| forest | 60 | 0 | 30 |
| town | 2868 | 96 | 179 |
| beefcake | 2938 | 27 | 95 |
| beefcake battle | 241 | 0 | 18 |
| necrocrat | 3699 | 20 | 102 |
| necrocrat battle | 241 | 0 | 18 |
| gourmand | 3170 | 13 | 105 |
| gourmand battle | 241 | 0 | 18 |
| refusemancer | 4436 | 23 | 121 |
| refusemancer battle | 240 | 0 | 18 |
| final | 8749 | 40 | 195 |
| final battle | 241 | 0 | 19 |

## Slowest moments (worst frame during one action)

- final: use fig: 195 ms
- town: use vendor: 179 ms
- town: open character_screen: 164 ms
- town: use deck: 156 ms
- town: use pack_vendor: 152 ms
- town: use item_vendor: 147 ms
- town: open full_map: 139 ms
- refusemancer: use hob: 121 ms
- final: use seal_out_a: 111 ms
- gourmand: use dolcetta: 105 ms
- necrocrat: use pip: 102 ms
- beefcake: use tony: 95 ms
- town: open vendor (again): 94 ms
- town: open deck_station (again): 88 ms
- final: use complaint_1: 87 ms

## Where the slow frames are (frames over 33 ms per action, top 15)

- town: open vendor: 18
- town: use vendor: 12
- town: open vendor (again): 12
- final: use wren: 7
- town: use item_vendor: 6
- town: use deck: 5
- necrocrat: use matching: 5
- town: use elder: 4
- beefcake: use tony: 4
- beefcake: use brenda: 4
- gourmand: use odalys: 4
- town: use equipment_vendor: 4
- town: use pack_vendor: 4
- town: open codex (again): 3
- necrocrat: use pip: 3

## Errors

None.

## Warnings

None.

## Log

- forest: no spot list to tour
