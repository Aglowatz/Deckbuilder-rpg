# Bot report

Written by the playthrough bot (`bash tools/run_tour_bot.sh`, `tools/tour_bot.gd`) on 2026-10-20T16:39:11, 8.6 minutes.

- Areas: forest, town, beefcake, necrocrat, gourmand, refusemancer, capital
- Spots used (NPCs, shops, signs, chests...): 276
- Menus opened: deck_station, codex, character_screen, quest_log, full_map, wardrobe, vendor, item_vendor, pack_vendor
- Battles: beefcake (Flexing Brute), necrocrat (Shambling Middle Manager), gourmand (Meatloaf Golem), refusemancer (Mossy Trash Golem), final (Compliance Officer)
- Errors: 0, warnings: 0

## Frames over 33 ms

| Area | Frames | Over 33 ms | Worst (ms) |
|---|---|---|---|
| forest | 60 | 1 | 37 |
| town | 2951 | 62 | 144 |
| beefcake | 2520 | 23 | 74 |
| beefcake battle | 241 | 0 | 18 |
| necrocrat | 3085 | 21 | 80 |
| necrocrat battle | 241 | 0 | 18 |
| gourmand | 2677 | 14 | 79 |
| gourmand battle | 241 | 0 | 18 |
| refusemancer | 4021 | 14 | 66 |
| refusemancer battle | 241 | 0 | 18 |
| final | 8532 | 45 | 119 |
| final battle | 241 | 0 | 18 |

## Slowest moments (worst frame during one action)

- town: open full_map: 144 ms
- town: use deck: 132 ms
- town: open deck_station: 122 ms
- final: use fig_crate: 119 ms
- final: use complaint_1: 119 ms
- town: open vendor (again): 118 ms
- final: use seal_out_a: 113 ms
- final: use fern: 98 ms
- town: use codex: 98 ms
- town: open quest_log: 97 ms
- town: use notice_board: 95 ms
- final: use fig: 93 ms
- final: use kestrel: 88 ms
- town: use tailor: 88 ms
- final: use spotless: 86 ms

## Where the slow frames are (frames over 33 ms per action, top 15)

- town: open vendor: 15
- town: open vendor (again): 8
- final: use wren: 6
- town: use deck: 5
- necrocrat: use matching: 5
- gourmand: use dolcetta: 4
- beefcake: use quiz: 4
- town: use item_vendor: 4
- refusemancer: use hob: 3
- refusemancer: use minigame: 3
- gourmand: use odalys: 3
- final: use fig: 3
- necrocrat: use pip: 3
- final: use citizen_1: 3
- beefcake: use tony: 3

## Errors

None.

## Warnings

None.

## Log

- forest: no spot list to tour
