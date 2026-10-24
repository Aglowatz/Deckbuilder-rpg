# Bot report

Written by the playthrough bot (`bash tools/run_tour_bot.sh`, `tools/tour_bot.gd`) on 2026-10-23T23:52:47, 8.5 minutes.

- Areas: forest, town, beefcake, necrocrat, gourmand, refusemancer, capital
- Spots used (NPCs, shops, signs, chests...): 281
- Menus opened: deck_station, codex, character_screen, quest_log, full_map, wardrobe, vendor, item_vendor, pack_vendor
- Battles: beefcake (Flexing Brute), necrocrat (Shambling Middle Manager), gourmand (Meatloaf Golem), refusemancer (Mossy Trash Golem), final (Compliance Officer)
- Errors: 0, warnings: 0

## Frames over 33 ms

| Area | Frames | Over 33 ms | Worst (ms) |
|---|---|---|---|
| forest | 60 | 0 | 17 |
| town | 3202 | 43 | 139 |
| beefcake | 2465 | 23 | 81 |
| beefcake battle | 241 | 1 | 45 |
| necrocrat | 3039 | 26 | 82 |
| necrocrat battle | 241 | 0 | 20 |
| gourmand | 2618 | 14 | 75 |
| gourmand battle | 241 | 2 | 61 |
| refusemancer | 3863 | 23 | 92 |
| refusemancer battle | 241 | 0 | 20 |
| final | 8347 | 68 | 145 |
| final battle | 241 | 1 | 41 |

## Slowest moments (worst frame during one action)

- final: use seal_reek: 145 ms
- final: use complaint_1: 143 ms
- final: use seal_out_a: 142 ms
- final: use sign_1: 141 ms
- final: use sign_4: 140 ms
- final: use lost_poster_0: 139 ms
- town: use well: 139 ms
- final: use fig_crate: 139 ms
- final: use sign_34: 139 ms
- town: use pack_vendor: 136 ms
- town: use tailor: 131 ms
- town: use deck: 125 ms
- town: arrive: 124 ms
- town: open full_map: 117 ms
- town: open quest_log: 107 ms

## Where the slow frames are (frames over 33 ms per action, top 15)

- town: use item_vendor: 6
- final: use spotless: 5
- final: use wren: 5
- necrocrat: use dolores: 4
- necrocrat: use pip: 4
- final: use fig: 4
- final: use seal_reek: 4
- final: use sign_1: 4
- final: use sign_4: 4
- final: use sign_34: 4
- final: use lost_poster_0: 4
- town: use deck: 4
- town: arrive: 3
- final: use citizen_1: 3
- town: use well: 3

## Errors

None.

## Warnings

None.

## Log

- forest: no spot list to tour
