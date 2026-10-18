# Bot report

Written by the playthrough bot (`bash tools/run_tour_bot.sh`, `tools/tour_bot.gd`) on 2026-10-18T06:24:54, 9.0 minutes.

- Areas: forest, town, beefcake, necrocrat, gourmand, refusemancer, capital
- Spots used (NPCs, shops, signs, chests...): 275
- Menus opened: deck_station, codex, character_screen, quest_log, full_map, wardrobe, vendor, item_vendor, pack_vendor
- Battles: beefcake (Flexing Brute), necrocrat (Shambling Middle Manager), gourmand (Meatloaf Golem), refusemancer (Mossy Trash Golem), final (Compliance Officer)
- Errors: 0, warnings: 0

## Frames over 33 ms

| Area | Frames | Over 33 ms | Worst (ms) |
|---|---|---|---|
| forest | 60 | 0 | 31 |
| town | 3027 | 28 | 223 |
| beefcake | 2944 | 13 | 118 |
| beefcake battle | 241 | 0 | 18 |
| necrocrat | 3703 | 16 | 95 |
| necrocrat battle | 241 | 0 | 18 |
| gourmand | 3164 | 12 | 106 |
| gourmand battle | 241 | 0 | 18 |
| refusemancer | 4446 | 24 | 88 |
| refusemancer battle | 241 | 0 | 18 |
| final | 8748 | 30 | 134 |
| final battle | 241 | 0 | 18 |

## Slowest moments (worst frame during one action)

- town: use deck: 223 ms
- town: use pack_vendor: 161 ms
- final: use fig: 134 ms
- town: open character_screen: 131 ms
- beefcake: use tony: 118 ms
- final: use seal_out_a: 114 ms
- town: use vendor: 113 ms
- gourmand: use dolcetta: 106 ms
- necrocrat: use pip: 95 ms
- final: use complaint_1: 95 ms
- town: use item_vendor: 92 ms
- refusemancer: use hob: 88 ms
- final: use kestrel: 83 ms
- final: use fern: 81 ms
- town: open deck_station: 79 ms

## Errors

None.

## Warnings

None.

## Log

- forest: no spot list to tour
