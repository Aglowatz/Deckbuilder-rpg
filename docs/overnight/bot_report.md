# Bot report

Written by the playthrough bot (`bash tools/run_tour_bot.sh`, `tools/tour_bot.gd`) on 2026-10-22T01:08:25, 8.8 minutes.

- Areas: forest, town, beefcake, necrocrat, gourmand, refusemancer, capital
- Spots used (NPCs, shops, signs, chests...): 281
- Menus opened: deck_station, codex, character_screen, quest_log, full_map, wardrobe, vendor, item_vendor, pack_vendor
- Battles: beefcake (Flexing Brute), necrocrat (Shambling Middle Manager), gourmand (Meatloaf Golem), refusemancer (Mossy Trash Golem), final (Compliance Officer)
- Errors: 0, warnings: 0

## Frames over 33 ms

| Area | Frames | Over 33 ms | Worst (ms) |
|---|---|---|---|
| forest | 61 | 1 | 45 |
| town | 3151 | 70 | 142 |
| beefcake | 2671 | 24 | 80 |
| beefcake battle | 241 | 1 | 40 |
| necrocrat | 3250 | 19 | 63 |
| necrocrat battle | 241 | 1 | 41 |
| gourmand | 2813 | 9 | 65 |
| gourmand battle | 241 | 0 | 20 |
| refusemancer | 4103 | 22 | 73 |
| refusemancer battle | 241 | 1 | 40 |
| final | 8678 | 52 | 166 |
| final battle | 241 | 0 | 20 |

## Slowest moments (worst frame during one action)

- final: use seal_out_a: 166 ms
- final: use complaint_2: 150 ms
- final: use seal_reek: 143 ms
- final: use sign_4: 142 ms
- town: arrive: 142 ms
- town: use pack_vendor: 141 ms
- final: use lost_poster_0: 141 ms
- final: use sign_1: 140 ms
- final: use sign_34: 138 ms
- town: use deck: 128 ms
- town: use well: 126 ms
- town: open deck_station: 125 ms
- town: use tailor: 98 ms
- town: open full_map: 98 ms
- final: use complaint_1: 96 ms

## Where the slow frames are (frames over 33 ms per action, top 15)

- town: open vendor: 17
- town: open vendor (again): 7
- town: use deck: 5
- final: use seal_reek: 5
- necrocrat: use dolores: 5
- town: use item_vendor: 5
- final: use wren: 4
- beefcake: use brenda: 4
- final: use sign_1: 4
- final: use sign_4: 4
- final: use sign_34: 4
- town: use hob: 4
- final: use lost_poster_0: 4
- refusemancer: use hob: 3
- refusemancer: use quiz: 3

## Errors

None.

## Warnings

None.

## Log

- forest: no spot list to tour
