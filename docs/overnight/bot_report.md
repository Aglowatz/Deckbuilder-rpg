# Bot report

Written by the playthrough bot (`bash tools/run_tour_bot.sh`, `tools/tour_bot.gd`) on 2026-10-30T11:20:06, 8.3 minutes.

- Areas: forest, town, beefcake, necrocrat, gourmand, refusemancer, capital
- Spots used (NPCs, shops, signs, chests...): 281
- Menus opened: deck_station, codex, character_screen, quest_log, full_map, wardrobe, vendor, item_vendor, pack_vendor
- Battles: beefcake (Quota Spotter), necrocrat (Shambling Middle Manager), gourmand (Meatloaf Golem), refusemancer (Mossy Trash Golem), final (Correction Officer)
- Errors: 0, warnings: 0

## Frames over 33 ms

| Area | Frames | Over 33 ms | Worst (ms) |
|---|---|---|---|
| forest | 59 | 1 | 47 |
| town | 3188 | 56 | 551 |
| beefcake | 2457 | 15 | 68 |
| beefcake battle | 240 | 1 | 40 |
| necrocrat | 3054 | 15 | 70 |
| necrocrat battle | 241 | 1 | 48 |
| gourmand | 2617 | 18 | 81 |
| gourmand battle | 241 | 1 | 48 |
| refusemancer | 3881 | 24 | 71 |
| refusemancer battle | 241 | 0 | 20 |
| final | 8363 | 74 | 410 |
| final battle | 241 | 2 | 37 |

## Slowest moments (worst frame during one action)

- town: use well: 551 ms
- final: use seal_reek: 410 ms
- final: use seal_grave: 398 ms
- final: use complaint_1: 361 ms
- final: use sign_34: 361 ms
- final: use sign_1: 360 ms
- final: use sign_4: 359 ms
- final: use lost_poster_0: 357 ms
- town: arrive: 208 ms
- town: use pack_vendor: 127 ms
- town: use tailor: 109 ms
- town: use vendor: 105 ms
- final: use seal_out_a: 103 ms
- town: use deck: 100 ms
- final: use fig: 100 ms

## Where the slow frames are (frames over 33 ms per action, top 15)

- town: use well: 6
- town: use vendor: 6
- town: use hob: 5
- final: use wren: 5
- final: use fig: 5
- final: use seal_reek: 5
- town: arrive: 4
- town: use deck: 4
- final: use spotless: 4
- refusemancer: use hob: 3
- beefcake: use brenda: 3
- beefcake: use sign_0: 3
- final: use seal_grave: 3
- final: use sign_1: 3
- gourmand: use minigame: 3

## Errors

None.

## Warnings

None.

## Log

- forest: no spot list to tour
