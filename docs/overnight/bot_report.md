# Bot report

Written by the playthrough bot (`bash tools/run_tour_bot.sh`, `tools/tour_bot.gd`) on 2026-10-27T23:20:30, 8.2 minutes.

- Areas: forest, town, beefcake, necrocrat, gourmand, refusemancer, capital
- Spots used (NPCs, shops, signs, chests...): 281
- Menus opened: deck_station, codex, character_screen, quest_log, full_map, wardrobe, vendor, item_vendor, pack_vendor
- Battles: beefcake (Quota Spotter), necrocrat (Shambling Middle Manager), gourmand (Meatloaf Golem), refusemancer (Mossy Trash Golem), final (Correction Officer)
- Errors: 0, warnings: 0

## Frames over 33 ms

| Area | Frames | Over 33 ms | Worst (ms) |
|---|---|---|---|
| forest | 61 | 0 | 17 |
| town | 3207 | 52 | 590 |
| beefcake | 2452 | 21 | 93 |
| beefcake battle | 241 | 0 | 20 |
| necrocrat | 3058 | 19 | 70 |
| necrocrat battle | 241 | 1 | 47 |
| gourmand | 2615 | 15 | 94 |
| gourmand battle | 241 | 1 | 50 |
| refusemancer | 3875 | 19 | 79 |
| refusemancer battle | 241 | 1 | 35 |
| final | 8369 | 64 | 379 |
| final battle | 241 | 1 | 43 |

## Slowest moments (worst frame during one action)

- town: use well: 590 ms
- final: use complaint_1: 379 ms
- final: use sign_4: 379 ms
- final: use sign_1: 378 ms
- final: use seal_reek: 376 ms
- final: use sign_34: 371 ms
- final: use lost_poster_0: 370 ms
- town: use deck: 118 ms
- final: use seal_out_a: 116 ms
- town: use tailor: 114 ms
- town: use pack_vendor: 104 ms
- final: use fig: 102 ms
- town: use vendor: 101 ms
- town: arrive: 100 ms
- final: use fig_crate: 99 ms

## Where the slow frames are (frames over 33 ms per action, top 15)

- final: use seal_reek: 5
- final: use wren: 5
- town: arrive: 4
- town: use well: 4
- town: use vendor: 4
- town: use deck: 4
- final: use sign_4: 4
- final: use lost_poster_0: 4
- town: use item_vendor: 4
- final: use sign_34: 4
- final: use sign_1: 3
- beefcake: use quiz: 3
- necrocrat: use barnaby: 3
- final: use complaint_1: 3
- final: use fig: 3

## Errors

None.

## Warnings

None.

## Log

- forest: no spot list to tour
