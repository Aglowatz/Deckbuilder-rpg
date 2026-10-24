# Bot report

Written by the playthrough bot (`bash tools/run_tour_bot.sh`, `tools/tour_bot.gd`) on 2026-10-24T00:54:41, 8.5 minutes.

- Areas: forest, town, beefcake, necrocrat, gourmand, refusemancer, capital
- Spots used (NPCs, shops, signs, chests...): 281
- Menus opened: deck_station, codex, character_screen, quest_log, full_map, wardrobe, vendor, item_vendor, pack_vendor
- Battles: beefcake (Flexing Brute), necrocrat (Shambling Middle Manager), gourmand (Meatloaf Golem), refusemancer (Mossy Trash Golem), final (Compliance Officer)
- Errors: 0, warnings: 0

## Frames over 33 ms

| Area | Frames | Over 33 ms | Worst (ms) |
|---|---|---|---|
| forest | 60 | 1 | 38 |
| town | 3181 | 52 | 190 |
| beefcake | 2475 | 23 | 75 |
| beefcake battle | 241 | 1 | 61 |
| necrocrat | 3058 | 13 | 60 |
| necrocrat battle | 241 | 0 | 20 |
| gourmand | 2619 | 13 | 67 |
| gourmand battle | 241 | 1 | 52 |
| refusemancer | 3883 | 21 | 67 |
| refusemancer battle | 241 | 1 | 51 |
| final | 8356 | 56 | 155 |
| final battle | 241 | 0 | 21 |

## Slowest moments (worst frame during one action)

- town: use pack_vendor: 190 ms
- final: use complaint_2: 155 ms
- town: use tailor: 153 ms
- town: use deck: 147 ms
- final: use seal_reek: 143 ms
- final: use sign_4: 142 ms
- final: use sign_1: 140 ms
- final: use lost_poster_0: 139 ms
- final: use sign_34: 138 ms
- town: use well: 133 ms
- town: open full_map: 126 ms
- town: arrive: 120 ms
- final: use seal_out_a: 119 ms
- final: use complaint_1: 102 ms
- town: use notice_board: 85 ms

## Where the slow frames are (frames over 33 ms per action, top 15)

- town: use item_vendor: 8
- final: use wren: 5
- town: use deck: 5
- final: use seal_reek: 5
- final: use sign_34: 5
- refusemancer: use hob: 4
- beefcake: use tony: 4
- beefcake: use brenda: 4
- final: use sign_1: 4
- final: use lost_poster_0: 4
- town: use vendor: 4
- final: use sign_4: 4
- town: use equipment_vendor: 3
- town: arrive: 3
- necrocrat: use barnaby: 3

## Errors

None.

## Warnings

None.

## Log

- forest: no spot list to tour
