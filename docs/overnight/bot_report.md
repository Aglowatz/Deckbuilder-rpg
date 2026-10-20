# Bot report

Written by the playthrough bot (`bash tools/run_tour_bot.sh`, `tools/tour_bot.gd`) on 2026-10-20T01:44:04, 8.6 minutes.

- Areas: forest, town, beefcake, necrocrat, gourmand, refusemancer, capital
- Spots used (NPCs, shops, signs, chests...): 275
- Menus opened: deck_station, codex, character_screen, quest_log, full_map, wardrobe, vendor, item_vendor, pack_vendor
- Battles: beefcake (Flexing Brute), necrocrat (Shambling Middle Manager), gourmand (Meatloaf Golem), refusemancer (Mossy Trash Golem), final (Compliance Officer)
- Errors: 0, warnings: 0

## Frames over 33 ms

| Area | Frames | Over 33 ms | Worst (ms) |
|---|---|---|---|
| forest | 58 | 2 | 55 |
| town | 2812 | 61 | 169 |
| beefcake | 2521 | 19 | 81 |
| beefcake battle | 241 | 0 | 17 |
| necrocrat | 3087 | 18 | 79 |
| necrocrat battle | 241 | 0 | 18 |
| gourmand | 2684 | 14 | 75 |
| gourmand battle | 241 | 0 | 18 |
| refusemancer | 3999 | 22 | 82 |
| refusemancer battle | 241 | 0 | 18 |
| final | 8529 | 41 | 129 |
| final battle | 241 | 0 | 19 |

## Slowest moments (worst frame during one action)

- town: open deck_station: 169 ms
- town: use pack_vendor: 153 ms
- town: use deck: 140 ms
- final: use seal_out_a: 129 ms
- final: use complaint_1: 125 ms
- final: use fig: 124 ms
- town: open full_map: 103 ms
- town: use vendor: 99 ms
- town: open vendor (again): 97 ms
- town: use item_vendor: 89 ms
- town: use well: 88 ms
- refusemancer: use hob: 82 ms
- beefcake: use tony: 81 ms
- final: use sign_1: 81 ms
- beefcake: use minigame: 79 ms

## Where the slow frames are (frames over 33 ms per action, top 15)

- town: open vendor: 8
- town: open vendor (again): 7
- town: use deck: 6
- final: use wren: 4
- necrocrat: use pip: 4
- town: use equipment_vendor: 4
- refusemancer: use hob: 3
- final: use fig: 3
- gourmand: use minigame: 3
- final: use spotless: 3
- town: use item_vendor: 3
- gourmand: use dolcetta: 3
- beefcake: use quiz: 3
- town: use vendor: 3
- necrocrat: use dolores: 3

## Errors

None.

## Warnings

None.

## Log

- forest: no spot list to tour
