# Bot report

Written by the playthrough bot (`bash tools/run_tour_bot.sh`, `tools/tour_bot.gd`) on 2026-10-18T22:20:36, 9.0 minutes.

- Areas: forest, town, beefcake, necrocrat, gourmand, refusemancer, capital
- Spots used (NPCs, shops, signs, chests...): 275
- Menus opened: deck_station, codex, character_screen, quest_log, full_map, wardrobe, vendor, item_vendor, pack_vendor
- Battles: beefcake (Flexing Brute), necrocrat (Shambling Middle Manager), gourmand (Meatloaf Golem), refusemancer (Mossy Trash Golem), final (Compliance Officer)
- Errors: 0, warnings: 0

## Frames over 33 ms

| Area | Frames | Over 33 ms | Worst (ms) |
|---|---|---|---|
| forest | 61 | 0 | 18 |
| town | 2899 | 82 | 193 |
| beefcake | 2937 | 26 | 125 |
| beefcake battle | 241 | 0 | 18 |
| necrocrat | 3696 | 20 | 113 |
| necrocrat battle | 241 | 0 | 18 |
| gourmand | 3161 | 14 | 120 |
| gourmand battle | 241 | 0 | 18 |
| refusemancer | 4431 | 23 | 132 |
| refusemancer battle | 241 | 0 | 18 |
| final | 8740 | 44 | 173 |
| final battle | 241 | 0 | 18 |

## Slowest moments (worst frame during one action)

- town: open character_screen: 193 ms
- town: use vendor: 192 ms
- town: use deck: 179 ms
- final: use fig: 173 ms
- town: use pack_vendor: 154 ms
- town: use item_vendor: 151 ms
- refusemancer: use hob: 132 ms
- town: open full_map: 128 ms
- beefcake: use tony: 125 ms
- gourmand: use dolcetta: 120 ms
- necrocrat: use pip: 113 ms
- town: open vendor (again): 109 ms
- town: open vendor: 107 ms
- final: use seal_out_a: 105 ms
- final: use complaint_1: 96 ms

## Errors

None.

## Warnings

None.

## Log

- forest: no spot list to tour
