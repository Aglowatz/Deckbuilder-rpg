# Bot report

Written by the playthrough bot (`bash tools/run_tour_bot.sh`, `tools/tour_bot.gd`) on 2026-11-21T08:27:20, 7.8 minutes.

- Areas: forest, town, beefcake, necrocrat, gourmand, refusemancer, capital
- Spots used (NPCs, shops, signs, chests...): 287
- Menus opened: deck_station, codex, character_screen, quest_log, full_map, wardrobe, vendor, item_vendor, pack_vendor
- Battles: beefcake (Quota Spotter), necrocrat (Shambling Middle Manager), gourmand (Meatloaf Golem), refusemancer (Mossy Trash Golem), final (Correction Officer)
- Errors: 0, warnings: 0

## Frames over 33 ms

| Area | Frames | Over 33 ms | Worst (ms) |
|---|---|---|---|
| forest | 142 | 0 | 29 |
| town | 5724 | 55 | 403 |
| beefcake | 4169 | 29 | 139 |
| beefcake battle | 1653 | 0 | 5 |
| necrocrat | 4306 | 24 | 277 |
| necrocrat battle | 1687 | 0 | 28 |
| gourmand | 4154 | 25 | 91 |
| gourmand battle | 1708 | 0 | 25 |
| refusemancer | 4688 | 39 | 82 |
| refusemancer battle | 1693 | 1 | 35 |
| final | 8938 | 100 | 433 |
| final battle | 1642 | 0 | 28 |

## Slowest moments (worst frame during one action)

- final: use seal_grave: 433 ms
- final: use seal_reek: 433 ms
- final: use complaint_2: 431 ms
- final: use sign_33: 429 ms
- final: use sign_1: 429 ms
- final: use lost_poster_0: 427 ms
- final: use sign_4: 425 ms
- town: arrive: 403 ms
- town: open full_map: 350 ms
- necrocrat: use puzzle: 277 ms
- town: use deck: 150 ms
- town: use pack_vendor: 145 ms
- beefcake: use quiz: 139 ms
- town: open deck_station: 129 ms
- town: open wardrobe: 103 ms

## Where the slow frames are (frames over 33 ms per action, top 15)

- final: use fig: 5
- town: open vendor (again): 4
- beefcake: use spot_me: 4
- beefcake: use cardsharp: 4
- final: use seal_reek: 4
- final: use sign_1: 4
- final: use sign_4: 4
- refusemancer: use marigold: 4
- final: use sign_33: 4
- town: arrive: 4
- final: use lost_poster_0: 4
- town: open vendor: 3
- beefcake: use quiz: 3
- refusemancer: use cardsharp: 3
- refusemancer: use pickup_fert_3: 3

## Errors

None.

## Warnings

None.

## Log

- forest: no spot list to tour
