# Bot report

Written by the playthrough bot (`bash tools/run_tour_bot.sh`, `tools/tour_bot.gd`) on 2026-10-29T18:01:21, 8.3 minutes.

- Areas: forest, town, beefcake, necrocrat, gourmand, refusemancer, capital
- Spots used (NPCs, shops, signs, chests...): 281
- Menus opened: deck_station, codex, character_screen, quest_log, full_map, wardrobe, vendor, item_vendor, pack_vendor
- Battles: beefcake (Quota Spotter), necrocrat (Shambling Middle Manager), gourmand (Meatloaf Golem), refusemancer (Mossy Trash Golem), final (Correction Officer)
- Errors: 0, warnings: 0

## Frames over 33 ms

| Area | Frames | Over 33 ms | Worst (ms) |
|---|---|---|---|
| forest | 60 | 0 | 29 |
| town | 3205 | 46 | 526 |
| beefcake | 2455 | 18 | 68 |
| beefcake battle | 241 | 1 | 42 |
| necrocrat | 3052 | 21 | 64 |
| necrocrat battle | 241 | 1 | 44 |
| gourmand | 2619 | 17 | 81 |
| gourmand battle | 241 | 1 | 59 |
| refusemancer | 3853 | 32 | 73 |
| refusemancer battle | 241 | 1 | 57 |
| final | 8359 | 58 | 378 |
| final battle | 241 | 1 | 42 |

## Slowest moments (worst frame during one action)

- town: arrive: 526 ms
- final: use complaint_2: 378 ms
- final: use sign_4: 363 ms
- final: use seal_reek: 362 ms
- final: use sign_34: 361 ms
- final: use lost_poster_0: 356 ms
- final: use sign_1: 356 ms
- town: use deck: 163 ms
- town: use tailor: 123 ms
- final: use seal_out_a: 106 ms
- town: use pack_vendor: 103 ms
- final: use complaint_1: 102 ms
- final: use fig_crate: 100 ms
- town: use vendor: 98 ms
- town: open full_map: 89 ms

## Where the slow frames are (frames over 33 ms per action, top 15)

- town: arrive: 6
- town: use vendor: 4
- gourmand: use odalys: 4
- final: use seal_reek: 4
- refusemancer: use hob: 3
- refusemancer: use quiz: 3
- refusemancer: use minigame: 3
- refusemancer: use sign_9: 3
- final: use wren: 3
- necrocrat: use matching: 3
- final: use spotless: 3
- beefcake: use quiz: 3
- beefcake: use brenda: 3
- final: use sign_1: 3
- final: use sign_4: 3

## Errors

None.

## Warnings

None.

## Log

- forest: no spot list to tour
