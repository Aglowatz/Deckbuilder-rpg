# Bot report

Written by the playthrough bot (`bash tools/run_tour_bot.sh`, `tools/tour_bot.gd`) on 2026-10-20T00:39:03, 8.9 minutes.

- Areas: forest, town, beefcake, necrocrat, gourmand, refusemancer, capital
- Spots used (NPCs, shops, signs, chests...): 275
- Menus opened: deck_station, codex, character_screen, quest_log, full_map, wardrobe, vendor, item_vendor, pack_vendor
- Battles: beefcake (Flexing Brute), necrocrat (Shambling Middle Manager), gourmand (Meatloaf Golem), refusemancer (Mossy Trash Golem), final (Compliance Officer)
- Errors: 0, warnings: 0

## Frames over 33 ms

| Area | Frames | Over 33 ms | Worst (ms) |
|---|---|---|---|
| forest | 60 | 1 | 37 |
| town | 2801 | 69 | 140 |
| beefcake | 2944 | 23 | 83 |
| beefcake battle | 241 | 0 | 17 |
| necrocrat | 3347 | 20 | 74 |
| necrocrat battle | 241 | 0 | 18 |
| gourmand | 3171 | 11 | 67 |
| gourmand battle | 241 | 0 | 18 |
| refusemancer | 4011 | 18 | 79 |
| refusemancer battle | 241 | 0 | 18 |
| final | 8627 | 40 | 177 |
| final battle | 240 | 0 | 18 |

## Slowest moments (worst frame during one action)

- final: use seal_reek: 177 ms
- town: use deck: 140 ms
- town: use pack_vendor: 125 ms
- town: open full_map: 120 ms
- town: open deck_station: 113 ms
- final: use fig: 104 ms
- town: use well: 103 ms
- final: use seal_out_a: 97 ms
- town: open vendor: 86 ms
- beefcake: use quiz: 83 ms
- final: use sign_1: 83 ms
- town: open quest_log: 82 ms
- town: use vendor: 80 ms
- final: use fig_crate: 80 ms
- refusemancer: use stable_1: 79 ms

## Where the slow frames are (frames over 33 ms per action, top 15)

- town: open vendor: 16
- town: open vendor (again): 10
- town: use deck: 5
- town: use equipment_vendor: 5
- final: use spotless: 5
- town: use item_vendor: 4
- beefcake: use sign_0: 3
- beefcake: use quiz: 3
- gourmand: use minigame: 3
- beefcake: use tony: 3
- necrocrat: use dolores: 3
- necrocrat: use matching: 3
- final: use fig: 3
- necrocrat: use sign_3: 2
- necrocrat: use shrine: 2

## Errors

None.

## Warnings

None.

## Log

- forest: no spot list to tour
