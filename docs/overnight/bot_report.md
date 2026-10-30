# Bot report

Written by the playthrough bot (`bash tools/run_tour_bot.sh`, `tools/tour_bot.gd`) on 2026-10-30T15:13:21, 8.2 minutes.

- Areas: forest, town, beefcake, necrocrat, gourmand, refusemancer, capital
- Spots used (NPCs, shops, signs, chests...): 281
- Menus opened: deck_station, codex, character_screen, quest_log, full_map, wardrobe, vendor, item_vendor, pack_vendor
- Battles: beefcake (Quota Spotter), necrocrat (Shambling Middle Manager), gourmand (Meatloaf Golem), refusemancer (Mossy Trash Golem), final (Correction Officer)
- Errors: 0, warnings: 0

## Frames over 33 ms

| Area | Frames | Over 33 ms | Worst (ms) |
|---|---|---|---|
| forest | 61 | 0 | 18 |
| town | 3190 | 46 | 429 |
| beefcake | 2455 | 21 | 74 |
| beefcake battle | 241 | 1 | 44 |
| necrocrat | 3055 | 18 | 75 |
| necrocrat battle | 241 | 1 | 45 |
| gourmand | 2620 | 12 | 70 |
| gourmand battle | 241 | 1 | 62 |
| refusemancer | 3875 | 22 | 83 |
| refusemancer battle | 241 | 1 | 43 |
| final | 8374 | 60 | 364 |
| final battle | 241 | 1 | 39 |

## Slowest moments (worst frame during one action)

- town: use well: 429 ms
- final: use sign_1: 364 ms
- final: use sign_4: 363 ms
- final: use sign_34: 363 ms
- final: use seal_out_a: 361 ms
- final: use seal_reek: 359 ms
- final: use complaint_1: 358 ms
- final: use lost_poster_0: 356 ms
- town: use item_vendor: 115 ms
- town: use deck: 107 ms
- town: use tailor: 105 ms
- town: open full_map: 104 ms
- town: use pack_vendor: 95 ms
- final: use fig: 94 ms
- town: arrive: 92 ms

## Where the slow frames are (frames over 33 ms per action, top 15)

- town: use well: 5
- town: use vendor: 5
- town: use deck: 5
- final: use seal_reek: 4
- final: use sign_4: 4
- necrocrat: use barnaby: 3
- final: use complaint_1: 3
- final: use spotless: 3
- necrocrat: use dolores: 3
- final: use seal_out_a: 3
- town: open deck_station: 3
- final: use sign_1: 3
- refusemancer: use marigold: 3
- final: use sign_34: 3
- town: use item_vendor: 3

## Errors

None.

## Warnings

None.

## Log

- forest: no spot list to tour
