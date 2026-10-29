# Bot report

Written by the playthrough bot (`bash tools/run_tour_bot.sh`, `tools/tour_bot.gd`) on 2026-10-29T00:38:49, 8.3 minutes.

- Areas: forest, town, beefcake, necrocrat, gourmand, refusemancer, capital
- Spots used (NPCs, shops, signs, chests...): 281
- Menus opened: deck_station, codex, character_screen, quest_log, full_map, wardrobe, vendor, item_vendor, pack_vendor
- Battles: beefcake (Quota Spotter), necrocrat (Shambling Middle Manager), gourmand (Meatloaf Golem), refusemancer (Mossy Trash Golem), final (Correction Officer)
- Errors: 0, warnings: 0

## Frames over 33 ms

| Area | Frames | Over 33 ms | Worst (ms) |
|---|---|---|---|
| forest | 60 | 0 | 33 |
| town | 3180 | 59 | 449 |
| beefcake | 2450 | 22 | 75 |
| beefcake battle | 240 | 0 | 22 |
| necrocrat | 3054 | 16 | 76 |
| necrocrat battle | 241 | 1 | 52 |
| gourmand | 2619 | 18 | 83 |
| gourmand battle | 241 | 1 | 53 |
| refusemancer | 3878 | 32 | 69 |
| refusemancer battle | 241 | 1 | 47 |
| final | 8347 | 69 | 371 |
| final battle | 241 | 1 | 41 |

## Slowest moments (worst frame during one action)

- town: use well: 449 ms
- final: use complaint_2: 371 ms
- final: use sign_1: 363 ms
- final: use sign_34: 362 ms
- final: use seal_reek: 359 ms
- final: use sign_4: 358 ms
- final: use lost_poster_0: 357 ms
- final: use seal_out_a: 356 ms
- town: arrive: 327 ms
- town: use pack_vendor: 134 ms
- town: use vendor: 117 ms
- final: use fig: 109 ms
- town: use tailor: 108 ms
- town: use deck: 108 ms
- town: open wardrobe: 95 ms

## Where the slow frames are (frames over 33 ms per action, top 15)

- town: use vendor: 11
- final: use wren: 6
- beefcake: use sign_0: 5
- final: use spotless: 5
- town: arrive: 5
- necrocrat: use dolores: 4
- final: use sign_4: 4
- beefcake: use quiz: 4
- final: use seal_reek: 4
- final: use fig: 4
- town: use deck: 4
- gourmand: use odalys: 3
- beefcake: use brenda: 3
- refusemancer: use hob: 3
- refusemancer: use puzzle: 3

## Errors

None.

## Warnings

None.

## Log

- forest: no spot list to tour
