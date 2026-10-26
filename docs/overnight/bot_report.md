# Bot report

Written by the playthrough bot (`bash tools/run_tour_bot.sh`, `tools/tour_bot.gd`) on 2026-10-25T18:50:10, 8.2 minutes.

- Areas: forest, town, beefcake, necrocrat, gourmand, refusemancer, capital
- Spots used (NPCs, shops, signs, chests...): 281
- Menus opened: deck_station, codex, character_screen, quest_log, full_map, wardrobe, vendor, item_vendor, pack_vendor
- Battles: beefcake (Flexing Brute), necrocrat (Shambling Middle Manager), gourmand (Meatloaf Golem), refusemancer (Mossy Trash Golem), final (Compliance Officer)
- Errors: 0, warnings: 0

## Frames over 33 ms

| Area | Frames | Over 33 ms | Worst (ms) |
|---|---|---|---|
| forest | 58 | 3 | 52 |
| town | 3206 | 45 | 139 |
| beefcake | 2452 | 21 | 87 |
| beefcake battle | 241 | 1 | 42 |
| necrocrat | 3059 | 19 | 64 |
| necrocrat battle | 241 | 1 | 55 |
| gourmand | 2619 | 10 | 68 |
| gourmand battle | 241 | 1 | 46 |
| refusemancer | 3881 | 21 | 68 |
| refusemancer battle | 241 | 1 | 46 |
| final | 8373 | 61 | 130 |
| final battle | 241 | 1 | 43 |

## Slowest moments (worst frame during one action)

- town: use pack_vendor: 139 ms
- final: use sign_4: 130 ms
- final: use seal_reek: 130 ms
- final: use complaint_1: 128 ms
- final: use sign_1: 126 ms
- final: use lost_poster_0: 126 ms
- final: use sign_34: 126 ms
- town: use tailor: 116 ms
- final: use fig: 115 ms
- town: use deck: 114 ms
- town: use well: 106 ms
- final: use fig_crate: 100 ms
- final: use seal_out_a: 98 ms
- town: open full_map: 96 ms
- town: use item_vendor: 93 ms

## Where the slow frames are (frames over 33 ms per action, top 15)

- town: use well: 6
- final: use seal_reek: 5
- final: use sign_4: 4
- town: use vendor: 4
- final: use sign_1: 4
- final: use wren: 4
- final: use lost_poster_0: 4
- final: use fig: 4
- beefcake: use quiz: 4
- final: use sign_34: 4
- beefcake: use tony: 3
- final: use complaint_1: 3
- final: use spotless: 3
- necrocrat: use pip: 3
- gourmand: use quiz: 3

## Errors

None.

## Warnings

None.

## Log

- forest: no spot list to tour
