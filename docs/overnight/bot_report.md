# Bot report

Written by the playthrough bot (`bash tools/run_tour_bot.sh`, `tools/tour_bot.gd`) on 2026-10-27T17:17:20, 8.2 minutes.

- Areas: forest, town, beefcake, necrocrat, gourmand, refusemancer, capital
- Spots used (NPCs, shops, signs, chests...): 281
- Menus opened: deck_station, codex, character_screen, quest_log, full_map, wardrobe, vendor, item_vendor, pack_vendor
- Battles: beefcake (Flexing Brute), necrocrat (Shambling Middle Manager), gourmand (Meatloaf Golem), refusemancer (Mossy Trash Golem), final (Compliance Officer)
- Errors: 0, warnings: 0

## Frames over 33 ms

| Area | Frames | Over 33 ms | Worst (ms) |
|---|---|---|---|
| forest | 61 | 0 | 17 |
| town | 3207 | 47 | 484 |
| beefcake | 2461 | 16 | 91 |
| beefcake battle | 241 | 1 | 40 |
| necrocrat | 3056 | 17 | 71 |
| necrocrat battle | 241 | 1 | 53 |
| gourmand | 2619 | 12 | 78 |
| gourmand battle | 241 | 0 | 21 |
| refusemancer | 3881 | 14 | 77 |
| refusemancer battle | 241 | 1 | 40 |
| final | 8373 | 60 | 381 |
| final battle | 241 | 0 | 20 |

## Slowest moments (worst frame during one action)

- town: use well: 484 ms
- final: use seal_reek: 381 ms
- final: use sign_4: 379 ms
- final: use sign_34: 379 ms
- final: use seal_out_a: 378 ms
- final: use complaint_1: 377 ms
- final: use sign_1: 377 ms
- final: use lost_poster_0: 371 ms
- town: use pack_vendor: 119 ms
- town: use deck: 115 ms
- final: use fig: 112 ms
- town: use item_vendor: 95 ms
- beefcake: use tony: 91 ms
- town: arrive: 89 ms
- final: use fig_crate: 89 ms

## Where the slow frames are (frames over 33 ms per action, top 15)

- town: use deck: 6
- final: use seal_reek: 5
- town: use well: 4
- final: use lost_poster_0: 4
- final: use sign_34: 4
- final: use sign_4: 4
- final: use sign_1: 4
- final: use complaint_1: 3
- final: use spotless: 3
- final: use fig: 3
- final: use wren: 3
- final: use seal_out_a: 3
- town: open deck_station: 3
- town: use item_vendor: 3
- refusemancer: use hob: 3

## Errors

None.

## Warnings

None.

## Log

- forest: no spot list to tour
