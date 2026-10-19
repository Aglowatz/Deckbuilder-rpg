# Bot report

Written by the playthrough bot (`bash tools/run_tour_bot.sh`, `tools/tour_bot.gd`) on 2026-10-19T04:57:14, 9.0 minutes.

- Areas: forest, town, beefcake, necrocrat, gourmand, refusemancer, capital
- Spots used (NPCs, shops, signs, chests...): 275
- Menus opened: deck_station, codex, character_screen, quest_log, full_map, wardrobe, vendor, item_vendor, pack_vendor
- Battles: beefcake (Flexing Brute), necrocrat (Shambling Middle Manager), gourmand (Meatloaf Golem), refusemancer (Mossy Trash Golem), final (Compliance Officer)
- Errors: 0, warnings: 0

## Frames over 33 ms

| Area | Frames | Over 33 ms | Worst (ms) |
|---|---|---|---|
| forest | 60 | 0 | 28 |
| town | 2881 | 87 | 185 |
| beefcake | 2925 | 23 | 130 |
| beefcake battle | 241 | 0 | 18 |
| necrocrat | 3703 | 18 | 103 |
| necrocrat battle | 241 | 0 | 18 |
| gourmand | 3164 | 12 | 119 |
| gourmand battle | 241 | 0 | 18 |
| refusemancer | 4442 | 20 | 96 |
| refusemancer battle | 241 | 0 | 18 |
| final | 8715 | 53 | 188 |
| final battle | 241 | 0 | 18 |

## Slowest moments (worst frame during one action)

- final: use fig: 188 ms
- town: use vendor: 185 ms
- town: open character_screen: 184 ms
- town: use deck: 178 ms
- town: open full_map: 149 ms
- final: use seal_out_a: 140 ms
- town: use item_vendor: 139 ms
- beefcake: use tony: 130 ms
- town: use pack_vendor: 122 ms
- final: use sign_34: 120 ms
- gourmand: use dolcetta: 119 ms
- final: use sign_1: 119 ms
- town: open vendor (again): 112 ms
- final: use complaint_1: 109 ms
- necrocrat: use pip: 103 ms

## Where the slow frames are (frames over 33 ms per action, top 15)

- town: open vendor: 16
- town: open vendor (again): 12
- final: use wren: 8
- town: use equipment_vendor: 7
- town: use deck: 5
- refusemancer: use hob: 5
- necrocrat: use dolores: 5
- town: use item_vendor: 5
- town: use pack_vendor: 5
- town: open deck_station: 5
- final: use kestrel: 4
- beefcake: use brenda: 4
- final: use fig: 4
- town: open deck_station (again): 4
- town: open codex: 4

## Errors

None.

## Warnings

None.

## Log

- forest: no spot list to tour
