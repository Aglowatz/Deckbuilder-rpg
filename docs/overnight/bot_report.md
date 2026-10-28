# Bot report

Written by the playthrough bot (`bash tools/run_tour_bot.sh`, `tools/tour_bot.gd`) on 2026-10-27T18:20:10, 8.2 minutes.

- Areas: forest, town, beefcake, necrocrat, gourmand, refusemancer, capital
- Spots used (NPCs, shops, signs, chests...): 281
- Menus opened: deck_station, codex, character_screen, quest_log, full_map, wardrobe, vendor, item_vendor, pack_vendor
- Battles: beefcake (Flexing Brute), necrocrat (Shambling Middle Manager), gourmand (Meatloaf Golem), refusemancer (Mossy Trash Golem), final (Compliance Officer)
- Errors: 0, warnings: 0

## Frames over 33 ms

| Area | Frames | Over 33 ms | Worst (ms) |
|---|---|---|---|
| forest | 60 | 0 | 17 |
| town | 3217 | 48 | 441 |
| beefcake | 2450 | 19 | 74 |
| beefcake battle | 241 | 0 | 20 |
| necrocrat | 3039 | 19 | 306 |
| necrocrat battle | 241 | 1 | 42 |
| gourmand | 2623 | 14 | 79 |
| gourmand battle | 241 | 1 | 47 |
| refusemancer | 3883 | 18 | 61 |
| refusemancer battle | 241 | 0 | 28 |
| final | 8333 | 63 | 390 |
| final battle | 241 | 1 | 43 |

## Slowest moments (worst frame during one action)

- town: use well: 441 ms
- final: use sign_34: 390 ms
- final: use sign_1: 390 ms
- final: use complaint_2: 388 ms
- final: use sign_4: 380 ms
- final: use seal_out_a: 379 ms
- final: use seal_reek: 376 ms
- final: use lost_poster_0: 374 ms
- necrocrat: use quiz: 306 ms
- town: use deck: 153 ms
- town: use tailor: 112 ms
- final: use fig: 108 ms
- town: use pack_vendor: 104 ms
- town: open full_map: 99 ms
- final: use complaint_1: 97 ms

## Where the slow frames are (frames over 33 ms per action, top 15)

- town: arrive: 5
- town: use vendor: 5
- final: use sign_34: 5
- final: use sign_1: 5
- final: use lost_poster_0: 4
- final: use sign_4: 4
- final: use seal_reek: 4
- final: use fig: 4
- refusemancer: use marigold: 4
- gourmand: use quiz: 4
- necrocrat: use quiz: 4
- town: use deck: 4
- beefcake: use sign_0: 3
- final: use wren: 3
- beefcake: use minigame: 3

## Errors

None.

## Warnings

None.

## Log

- forest: no spot list to tour
