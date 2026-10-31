# Bot report

Written by the playthrough bot (`bash tools/run_tour_bot.sh`, `tools/tour_bot.gd`) on 2026-10-31T01:16:55, 8.2 minutes.

- Areas: forest, town, beefcake, necrocrat, gourmand, refusemancer, capital
- Spots used (NPCs, shops, signs, chests...): 281
- Menus opened: deck_station, codex, character_screen, quest_log, full_map, wardrobe, vendor, item_vendor, pack_vendor
- Battles: beefcake (Quota Spotter), necrocrat (Shambling Middle Manager), gourmand (Meatloaf Golem), refusemancer (Mossy Trash Golem), final (Correction Officer)
- Errors: 0, warnings: 0

## Frames over 33 ms

| Area | Frames | Over 33 ms | Worst (ms) |
|---|---|---|---|
| forest | 59 | 2 | 46 |
| town | 3186 | 54 | 447 |
| beefcake | 2441 | 22 | 79 |
| beefcake battle | 241 | 2 | 46 |
| necrocrat | 3057 | 24 | 63 |
| necrocrat battle | 241 | 0 | 21 |
| gourmand | 2615 | 21 | 71 |
| gourmand battle | 241 | 1 | 57 |
| refusemancer | 3882 | 30 | 65 |
| refusemancer battle | 241 | 1 | 63 |
| final | 8367 | 62 | 360 |
| final battle | 241 | 1 | 44 |

## Slowest moments (worst frame during one action)

- town: use well: 447 ms
- final: use sign_4: 360 ms
- final: use sign_34: 358 ms
- final: use complaint_1: 357 ms
- final: use sign_1: 356 ms
- final: use seal_reek: 356 ms
- final: use lost_poster_0: 355 ms
- town: use deck: 183 ms
- town: use pack_vendor: 134 ms
- town: arrive: 132 ms
- town: use tailor: 123 ms
- final: use seal_out_a: 117 ms
- town: open full_map: 111 ms
- town: use notice_board: 100 ms
- town: use item_vendor: 98 ms

## Where the slow frames are (frames over 33 ms per action, top 15)

- town: use vendor: 6
- gourmand: use odalys: 5
- refusemancer: use hob: 5
- final: use lost_poster_0: 4
- town: arrive: 4
- final: use seal_reek: 4
- final: use spotless: 4
- beefcake: use sign_0: 3
- beefcake: use brenda: 3
- gourmand: use quiz: 3
- refusemancer: use quiz: 3
- final: use wren: 3
- final: use fig: 3
- town: open deck_station (again): 3
- town: open deck_station: 3

## Errors

None.

## Warnings

None.

## Log

- forest: no spot list to tour
