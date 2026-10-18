# Bot report

Written by the playthrough bot (`bash tools/run_tour_bot.sh`, `tools/tour_bot.gd`) on 2026-10-18T05:34:55, 9.0 minutes.

- Areas: forest, town, beefcake, necrocrat, gourmand, refusemancer, capital
- Spots used (NPCs, shops, signs, chests...): 275
- Menus opened: deck_station, codex, character_screen, quest_log, full_map, wardrobe, vendor, item_vendor, pack_vendor
- Battles: beefcake (Flexing Brute), necrocrat (Shambling Middle Manager), gourmand (Meatloaf Golem), refusemancer (Mossy Trash Golem), final (Compliance Officer)
- Errors: 0, warnings: 0

## Frames over 33 ms

| Area | Frames | Over 33 ms | Worst (ms) |
|---|---|---|---|
| forest | 60 | 0 | 31 |
| town | 2987 | 66 | 284 |
| beefcake | 2926 | 24 | 130 |
| beefcake battle | 240 | 0 | 18 |
| necrocrat | 3697 | 18 | 112 |
| necrocrat battle | 241 | 0 | 18 |
| gourmand | 3160 | 13 | 121 |
| gourmand battle | 241 | 0 | 20 |
| refusemancer | 4434 | 16 | 143 |
| refusemancer battle | 241 | 0 | 18 |
| final | 8731 | 37 | 169 |
| final battle | 241 | 0 | 18 |

## Slowest moments (worst frame during one action)

- town: use deck: 284 ms
- town: use vendor: 191 ms
- town: use pack_vendor: 185 ms
- town: open character_screen: 176 ms
- final: use fig: 169 ms
- town: open full_map: 167 ms
- refusemancer: use hob: 143 ms
- final: use lost_poster_0: 136 ms
- beefcake: use tony: 130 ms
- final: use seal_out_a: 124 ms
- gourmand: use dolcetta: 121 ms
- town: use item_vendor: 119 ms
- necrocrat: use pip: 112 ms
- final: use complaint_1: 106 ms
- town: open wardrobe: 89 ms

## Errors

None.

## Warnings

None.

## Log

- forest: no spot list to tour
