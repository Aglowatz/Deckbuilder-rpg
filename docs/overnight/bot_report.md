# Bot report

Written by the playthrough bot (`bash tools/run_tour_bot.sh`, `tools/tour_bot.gd`) on 2026-10-20T02:44:54, 8.5 minutes.

- Areas: forest, town, beefcake, necrocrat, gourmand, refusemancer, capital
- Spots used (NPCs, shops, signs, chests...): 275
- Menus opened: deck_station, codex, character_screen, quest_log, full_map, wardrobe, vendor, item_vendor, pack_vendor
- Battles: beefcake (Flexing Brute), necrocrat (Shambling Middle Manager), gourmand (Meatloaf Golem), refusemancer (Mossy Trash Golem), final (Compliance Officer)
- Errors: 0, warnings: 0

## Frames over 33 ms

| Area | Frames | Over 33 ms | Worst (ms) |
|---|---|---|---|
| forest | 60 | 1 | 54 |
| town | 2793 | 64 | 155 |
| beefcake | 2532 | 15 | 74 |
| beefcake battle | 241 | 0 | 17 |
| necrocrat | 3099 | 16 | 67 |
| necrocrat battle | 241 | 0 | 18 |
| gourmand | 2694 | 12 | 69 |
| gourmand battle | 241 | 0 | 18 |
| refusemancer | 4015 | 18 | 66 |
| refusemancer battle | 241 | 0 | 18 |
| final | 8547 | 39 | 107 |
| final battle | 241 | 0 | 18 |

## Slowest moments (worst frame during one action)

- town: use pack_vendor: 155 ms
- town: use deck: 127 ms
- town: open vendor (again): 124 ms
- town: open deck_station: 120 ms
- town: use well: 109 ms
- final: use seal_out_a: 107 ms
- town: open full_map: 91 ms
- final: use fig: 90 ms
- town: use tailor: 87 ms
- final: use lost_poster_0: 87 ms
- final: use kestrel: 81 ms
- final: use sign_1: 79 ms
- final: use sign_34: 78 ms
- final: use spotless: 78 ms
- beefcake: use spot_me: 74 ms

## Where the slow frames are (frames over 33 ms per action, top 15)

- town: open vendor: 9
- town: use deck: 7
- town: use equipment_vendor: 5
- town: open vendor (again): 4
- necrocrat: use dolores: 4
- final: use fig: 4
- refusemancer: use hob: 4
- town: use vendor: 4
- town: use item_vendor: 3
- refusemancer: use minigame: 3
- necrocrat: use matching: 3
- beefcake: use quiz: 3
- refusemancer: use marigold: 2
- town: open item_vendor: 2
- beefcake: use brenda: 2

## Errors

None.

## Warnings

None.

## Log

- forest: no spot list to tour
