# Bot report

Written by the playthrough bot (`bash tools/run_tour_bot.sh`, `tools/tour_bot.gd`) on 2026-10-24T00:19:55, 8.5 minutes.

- Areas: forest, town, beefcake, necrocrat, gourmand, refusemancer, capital
- Spots used (NPCs, shops, signs, chests...): 281
- Menus opened: deck_station, codex, character_screen, quest_log, full_map, wardrobe, vendor, item_vendor, pack_vendor
- Battles: beefcake (Flexing Brute), necrocrat (Shambling Middle Manager), gourmand (Meatloaf Golem), refusemancer (Mossy Trash Golem), final (Compliance Officer)
- Errors: 0, warnings: 0

## Frames over 33 ms

| Area | Frames | Over 33 ms | Worst (ms) |
|---|---|---|---|
| forest | 60 | 0 | 26 |
| town | 3216 | 38 | 171 |
| beefcake | 2489 | 23 | 72 |
| beefcake battle | 241 | 0 | 20 |
| necrocrat | 3060 | 12 | 68 |
| necrocrat battle | 241 | 1 | 42 |
| gourmand | 2620 | 12 | 76 |
| gourmand battle | 241 | 1 | 49 |
| refusemancer | 3881 | 16 | 74 |
| refusemancer battle | 241 | 1 | 53 |
| final | 8370 | 51 | 151 |
| final battle | 241 | 0 | 20 |

## Slowest moments (worst frame during one action)

- town: use pack_vendor: 171 ms
- final: use seal_reek: 151 ms
- final: use complaint_1: 143 ms
- final: use sign_1: 142 ms
- final: use sign_4: 142 ms
- final: use sign_34: 139 ms
- town: arrive: 139 ms
- final: use lost_poster_0: 138 ms
- town: use deck: 125 ms
- town: use tailor: 106 ms
- town: use well: 105 ms
- final: use seal_out_a: 102 ms
- final: use kestrel: 79 ms
- final: use spotless: 78 ms
- town: open full_map: 76 ms

## Where the slow frames are (frames over 33 ms per action, top 15)

- beefcake: use brenda: 5
- final: use lost_poster_0: 4
- final: use sign_34: 4
- final: use sign_4: 4
- final: use sign_1: 4
- final: use seal_reek: 4
- town: arrive: 4
- town: use hob: 4
- final: use complaint_1: 3
- final: use spotless: 3
- necrocrat: use barnaby: 3
- town: use deck: 3
- town: use well: 3
- final: use fig: 3
- necrocrat: use sign_0: 2

## Errors

None.

## Warnings

None.

## Log

- forest: no spot list to tour
