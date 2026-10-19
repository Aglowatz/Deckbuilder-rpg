# Bot report

Written by the playthrough bot (`bash tools/run_tour_bot.sh`, `tools/tour_bot.gd`) on 2026-10-19T03:41:56, 9.0 minutes.

- Areas: forest, town, beefcake, necrocrat, gourmand, refusemancer, capital
- Spots used (NPCs, shops, signs, chests...): 275
- Menus opened: deck_station, codex, character_screen, quest_log, full_map, wardrobe, vendor, item_vendor, pack_vendor
- Battles: beefcake (Flexing Brute), necrocrat (Shambling Middle Manager), gourmand (Meatloaf Golem), refusemancer (Mossy Trash Golem), final (Compliance Officer)
- Errors: 0, warnings: 0

## Frames over 33 ms

| Area | Frames | Over 33 ms | Worst (ms) |
|---|---|---|---|
| forest | 60 | 0 | 27 |
| town | 2927 | 68 | 174 |
| beefcake | 2946 | 18 | 89 |
| beefcake battle | 241 | 0 | 18 |
| necrocrat | 3705 | 17 | 112 |
| necrocrat battle | 241 | 0 | 18 |
| gourmand | 3164 | 12 | 108 |
| gourmand battle | 241 | 0 | 18 |
| refusemancer | 4448 | 21 | 107 |
| refusemancer battle | 241 | 0 | 19 |
| final | 8754 | 39 | 139 |
| final battle | 241 | 0 | 18 |

## Slowest moments (worst frame during one action)

- town: use deck: 174 ms
- town: open character_screen: 156 ms
- final: use seal_out_a: 139 ms
- town: use pack_vendor: 136 ms
- town: use vendor: 135 ms
- final: use sign_1: 124 ms
- final: use fig: 120 ms
- town: use item_vendor: 114 ms
- necrocrat: use pip: 112 ms
- gourmand: use dolcetta: 108 ms
- refusemancer: use hob: 107 ms
- town: use codex: 96 ms
- town: open vendor: 93 ms
- town: open vendor (again): 92 ms
- beefcake: use tony: 89 ms

## Where the slow frames are (frames over 33 ms per action, top 15)

- town: open vendor: 13
- town: open vendor (again): 7
- town: use deck: 6
- necrocrat: use dolores: 4
- refusemancer: use hob: 4
- final: use wren: 4
- town: use equipment_vendor: 4
- town: use item_vendor: 4
- town: use vendor: 4
- necrocrat: use barnaby: 3
- town: use pack_vendor: 3
- town: use tailor: 3
- beefcake: use quiz: 3
- town: open deck_station (again): 3
- final: use kestrel: 3

## Errors

None.

## Warnings

None.

## Log

- forest: no spot list to tour
