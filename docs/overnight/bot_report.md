# Bot report

Written by the playthrough bot (`bash tools/run_tour_bot.sh`, `tools/tour_bot.gd`) on 2026-10-28T22:05:23, 8.2 minutes.

- Areas: forest, town, beefcake, necrocrat, gourmand, refusemancer, capital
- Spots used (NPCs, shops, signs, chests...): 281
- Menus opened: deck_station, codex, character_screen, quest_log, full_map, wardrobe, vendor, item_vendor, pack_vendor
- Battles: beefcake (Quota Spotter), necrocrat (Shambling Middle Manager), gourmand (Meatloaf Golem), refusemancer (Mossy Trash Golem), final (Correction Officer)
- Errors: 0, warnings: 0

## Frames over 33 ms

| Area | Frames | Over 33 ms | Worst (ms) |
|---|---|---|---|
| forest | 60 | 0 | 29 |
| town | 3187 | 54 | 464 |
| beefcake | 2455 | 26 | 82 |
| beefcake battle | 241 | 1 | 44 |
| necrocrat | 3059 | 15 | 67 |
| necrocrat battle | 241 | 1 | 46 |
| gourmand | 2619 | 17 | 79 |
| gourmand battle | 241 | 1 | 41 |
| refusemancer | 3867 | 25 | 72 |
| refusemancer battle | 241 | 1 | 61 |
| final | 8387 | 52 | 368 |
| final battle | 241 | 1 | 40 |

## Slowest moments (worst frame during one action)

- town: arrive: 464 ms
- final: use seal_reek: 368 ms
- final: use sign_1: 361 ms
- final: use sign_4: 359 ms
- final: use complaint_1: 359 ms
- final: use sign_34: 359 ms
- final: use lost_poster_0: 355 ms
- town: use deck: 169 ms
- town: use vendor: 111 ms
- town: use pack_vendor: 107 ms
- final: use seal_out_a: 104 ms
- town: open full_map: 87 ms
- final: use fig_crate: 86 ms
- final: use fig: 86 ms
- town: use tailor: 85 ms

## Where the slow frames are (frames over 33 ms per action, top 15)

- town: arrive: 7
- town: use vendor: 7
- beefcake: use sign_0: 6
- final: use wren: 4
- beefcake: use brenda: 4
- final: use seal_reek: 4
- town: use deck: 4
- gourmand: use quiz: 3
- refusemancer: use quiz: 3
- refusemancer: use minigame: 3
- town: open deck_station: 3
- final: use lost_poster_0: 3
- town: use well: 3
- final: use complaint_1: 3
- final: use sign_34: 3

## Errors

None.

## Warnings

None.

## Log

- forest: no spot list to tour
