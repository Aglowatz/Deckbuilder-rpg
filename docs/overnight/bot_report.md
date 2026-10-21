# Bot report

Written by the playthrough bot (`bash tools/run_tour_bot.sh`, `tools/tour_bot.gd`) on 2026-10-21T01:19:40, 8.7 minutes.

- Areas: forest, town, beefcake, necrocrat, gourmand, refusemancer, capital
- Spots used (NPCs, shops, signs, chests...): 276
- Menus opened: deck_station, codex, character_screen, quest_log, full_map, wardrobe, vendor, item_vendor, pack_vendor
- Battles: beefcake (Flexing Brute), necrocrat (Shambling Middle Manager), gourmand (Meatloaf Golem), refusemancer (Mossy Trash Golem), final (Compliance Officer)
- Errors: 0, warnings: 0

## Frames over 33 ms

| Area | Frames | Over 33 ms | Worst (ms) |
|---|---|---|---|
| forest | 60 | 0 | 28 |
| town | 2959 | 77 | 202 |
| beefcake | 2538 | 23 | 78 |
| beefcake battle | 241 | 1 | 59 |
| necrocrat | 3103 | 18 | 68 |
| necrocrat battle | 240 | 1 | 64 |
| gourmand | 2699 | 14 | 72 |
| gourmand battle | 241 | 1 | 53 |
| refusemancer | 4021 | 20 | 82 |
| refusemancer battle | 241 | 1 | 54 |
| final | 8549 | 37 | 162 |
| final battle | 240 | 1 | 39 |

## Slowest moments (worst frame during one action)

- town: use well: 202 ms
- final: use sign_34: 162 ms
- final: use seal_out_a: 157 ms
- town: use deck: 154 ms
- final: use sign_1: 154 ms
- final: use complaint_1: 132 ms
- final: use sign_4: 125 ms
- town: use item_vendor: 123 ms
- final: use seal_reek: 123 ms
- final: use lost_poster_0: 115 ms
- town: open deck_station: 105 ms
- town: open deck_station (again): 103 ms
- town: use pack_vendor: 100 ms
- town: use tailor: 89 ms
- town: open wardrobe: 89 ms

## Where the slow frames are (frames over 33 ms per action, top 15)

- town: open vendor: 16
- town: use deck: 8
- town: open deck_station (again): 6
- town: use well: 6
- town: open vendor (again): 5
- beefcake: use brenda: 4
- town: open deck_station: 4
- necrocrat: use dolores: 3
- necrocrat: use matching: 3
- refusemancer: use minigame: 3
- beefcake: use minigame: 3
- beefcake: use tony: 3
- beefcake: use gus: 3
- town: open codex (again): 3
- town: open codex: 3

## Errors

None.

## Warnings

None.

## Log

- forest: no spot list to tour
