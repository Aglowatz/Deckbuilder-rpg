# Bot report

Written by the playthrough bot (`bash tools/run_tour_bot.sh`, `tools/tour_bot.gd`) on 2026-10-19T10:07:44, 9.1 minutes.

- Areas: forest, town, beefcake, necrocrat, gourmand, refusemancer, capital
- Spots used (NPCs, shops, signs, chests...): 275
- Menus opened: deck_station, codex, character_screen, quest_log, full_map, wardrobe, vendor, item_vendor, pack_vendor
- Battles: beefcake (Flexing Brute), necrocrat (Shambling Middle Manager), gourmand (Meatloaf Golem), refusemancer (Mossy Trash Golem), final (Compliance Officer)
- Errors: 0, warnings: 0

## Frames over 33 ms

| Area | Frames | Over 33 ms | Worst (ms) |
|---|---|---|---|
| forest | 60 | 0 | 27 |
| town | 2941 | 57 | 128 |
| beefcake | 2949 | 22 | 63 |
| beefcake battle | 241 | 0 | 19 |
| necrocrat | 3703 | 17 | 72 |
| necrocrat battle | 241 | 0 | 18 |
| gourmand | 3176 | 14 | 64 |
| gourmand battle | 241 | 0 | 18 |
| refusemancer | 4451 | 21 | 66 |
| refusemancer battle | 241 | 0 | 18 |
| final | 8757 | 40 | 109 |
| final battle | 241 | 0 | 18 |

## Slowest moments (worst frame during one action)

- town: use deck: 128 ms
- town: use pack_vendor: 119 ms
- final: use seal_out_a: 109 ms
- town: open deck_station: 102 ms
- final: use kestrel: 75 ms
- final: use marlo: 75 ms
- final: use fig: 74 ms
- town: open vendor (again): 74 ms
- final: use sign_1: 73 ms
- town: use tailor: 72 ms
- necrocrat: use pip: 72 ms
- town: use well: 71 ms
- town: use vendor: 71 ms
- final: use complaint_1: 69 ms
- town: open deck_station (again): 69 ms

## Where the slow frames are (frames over 33 ms per action, top 15)

- town: open vendor: 11
- town: use deck: 6
- final: use wren: 5
- beefcake: use brenda: 4
- town: use equipment_vendor: 4
- town: use item_vendor: 4
- gourmand: use odalys: 4
- necrocrat: use dolores: 4
- town: use elder: 4
- necrocrat: use pip: 3
- gourmand: use dolcetta: 3
- necrocrat: use barnaby: 3
- refusemancer: use marigold: 3
- town: use vendor: 3
- refusemancer: use minigame: 3

## Errors

None.

## Warnings

None.

## Log

- forest: no spot list to tour
