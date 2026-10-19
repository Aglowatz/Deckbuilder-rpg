# Bot report

Written by the playthrough bot (`bash tools/run_tour_bot.sh`, `tools/tour_bot.gd`) on 2026-10-18T23:10:07, 9.0 minutes.

- Areas: forest, town, beefcake, necrocrat, gourmand, refusemancer, capital
- Spots used (NPCs, shops, signs, chests...): 275
- Menus opened: deck_station, codex, character_screen, quest_log, full_map, wardrobe, vendor, item_vendor, pack_vendor
- Battles: beefcake (Flexing Brute), necrocrat (Shambling Middle Manager), gourmand (Meatloaf Golem), refusemancer (Mossy Trash Golem), final (Compliance Officer)
- Errors: 0, warnings: 0

## Frames over 33 ms

| Area | Frames | Over 33 ms | Worst (ms) |
|---|---|---|---|
| forest | 61 | 0 | 18 |
| town | 2898 | 88 | 186 |
| beefcake | 2933 | 20 | 116 |
| beefcake battle | 241 | 0 | 19 |
| necrocrat | 3702 | 14 | 99 |
| necrocrat battle | 241 | 0 | 18 |
| gourmand | 3167 | 14 | 97 |
| gourmand battle | 241 | 0 | 18 |
| refusemancer | 4451 | 14 | 119 |
| refusemancer battle | 241 | 0 | 18 |
| final | 8749 | 41 | 134 |
| final battle | 241 | 0 | 18 |

## Slowest moments (worst frame during one action)

- town: open character_screen: 186 ms
- town: use vendor: 156 ms
- town: use pack_vendor: 153 ms
- town: use deck: 150 ms
- final: use fig: 134 ms
- final: use sign_1: 123 ms
- refusemancer: use hob: 119 ms
- final: use seal_out_a: 118 ms
- beefcake: use tony: 116 ms
- town: use item_vendor: 115 ms
- town: use codex: 108 ms
- necrocrat: use pip: 99 ms
- gourmand: use dolcetta: 97 ms
- town: open deck_station: 90 ms
- town: open deck_station (again): 86 ms

## Where the slow frames are (frames over 33 ms per action, top 15)

- town: use vendor: 11
- town: open vendor: 10
- town: use deck: 6
- town: open vendor (again): 6
- town: use equipment_vendor: 6
- town: open deck_station (again): 5
- town: use elder: 4
- beefcake: use tony: 4
- town: open deck_station: 4
- town: use pack_vendor: 4
- town: open codex (again): 3
- final: use kestrel: 3
- final: use fig: 3
- final: use wren: 3
- gourmand: use dolcetta: 3

## Errors

None.

## Warnings

None.

## Log

- forest: no spot list to tour
