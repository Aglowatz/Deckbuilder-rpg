# Bot report

Written by the playthrough bot (`bash tools/run_tour_bot.sh`, `tools/tour_bot.gd`) on 2026-10-17T23:45:41, 8.9 minutes.

- Areas: forest, town, beefcake, necrocrat, gourmand, refusemancer, capital
- Spots used (NPCs, shops, signs, chests...): 275
- Menus opened: deck_station, codex, character_screen, quest_log, full_map, wardrobe, vendor, item_vendor, pack_vendor
- Battles: beefcake (Flexing Brute), necrocrat (Shambling Middle Manager), gourmand (Meatloaf Golem), refusemancer (Mossy Trash Golem), final (Compliance Officer)
- Errors: 0, warnings: 0

## Frames over 33 ms

| Area | Frames | Over 33 ms | Worst (ms) |
|---|---|---|---|
| forest | 60 | 0 | 22 |
| town | 2390 | 29 | 146 |
| beefcake | 2940 | 5 | 108 |
| beefcake battle | 241 | 0 | 17 |
| necrocrat | 3688 | 5 | 147 |
| necrocrat battle | 241 | 0 | 17 |
| gourmand | 3163 | 7 | 90 |
| gourmand battle | 241 | 0 | 17 |
| refusemancer | 4435 | 4 | 146 |
| refusemancer battle | 241 | 0 | 17 |
| final | 8741 | 18 | 125 |
| final battle | 241 | 0 | 17 |

## Slowest moments (worst frame during one action)

- necrocrat: use pip: 147 ms
- town: open deck_station: 146 ms
- town: use pack_vendor: 146 ms
- refusemancer: use hob: 146 ms
- town: open codex: 143 ms
- town: use deck: 143 ms
- town: use codex: 142 ms
- town: use vendor: 141 ms
- town: open character_screen: 138 ms
- town: use item_vendor: 136 ms
- town: open vendor: 133 ms
- town: open full_map: 125 ms
- final: use fig: 125 ms
- beefcake: use tony: 108 ms
- town: use notice_board: 101 ms

## Errors

None.

## Warnings

None.

## Log

- forest: no spot list to tour
