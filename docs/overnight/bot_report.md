# Bot report

Written by the playthrough bot (`bash tools/run_tour_bot.sh`, `tools/tour_bot.gd`) on 2026-10-19T02:02:00, 9.0 minutes.

- Areas: forest, town, beefcake, necrocrat, gourmand, refusemancer, capital
- Spots used (NPCs, shops, signs, chests...): 275
- Menus opened: deck_station, codex, character_screen, quest_log, full_map, wardrobe, vendor, item_vendor, pack_vendor
- Battles: beefcake (Flexing Brute), necrocrat (Shambling Middle Manager), gourmand (Meatloaf Golem), refusemancer (Mossy Trash Golem), final (Compliance Officer)
- Errors: 0, warnings: 0

## Frames over 33 ms

| Area | Frames | Over 33 ms | Worst (ms) |
|---|---|---|---|
| forest | 60 | 0 | 31 |
| town | 2863 | 105 | 202 |
| beefcake | 2932 | 23 | 133 |
| beefcake battle | 241 | 0 | 19 |
| necrocrat | 3702 | 17 | 101 |
| necrocrat battle | 241 | 0 | 18 |
| gourmand | 3167 | 10 | 118 |
| gourmand battle | 241 | 0 | 18 |
| refusemancer | 4423 | 23 | 146 |
| refusemancer battle | 241 | 0 | 18 |
| final | 8729 | 41 | 212 |
| final battle | 241 | 0 | 18 |

## Slowest moments (worst frame during one action)

- final: use fig: 212 ms
- town: open character_screen: 202 ms
- town: use vendor: 173 ms
- town: use deck: 155 ms
- town: use item_vendor: 151 ms
- refusemancer: use hob: 146 ms
- town: use pack_vendor: 136 ms
- final: use seal_out_a: 134 ms
- beefcake: use tony: 133 ms
- final: use sign_1: 125 ms
- final: use complaint_1: 120 ms
- gourmand: use dolcetta: 118 ms
- necrocrat: use pip: 101 ms
- town: open vendor (again): 100 ms
- town: use codex: 99 ms

## Where the slow frames are (frames over 33 ms per action, top 15)

- town: open vendor: 17
- town: use vendor: 13
- town: open vendor (again): 11
- final: use wren: 7
- town: use deck: 6
- town: open codex: 5
- town: open deck_station (again): 5
- town: open deck_station: 5
- refusemancer: use hob: 5
- town: use equipment_vendor: 5
- necrocrat: use dolores: 4
- town: use item_vendor: 4
- town: use elder: 4
- gourmand: use dolcetta: 3
- town: use pack_vendor: 3

## Errors

None.

## Warnings

None.

## Log

- forest: no spot list to tour
