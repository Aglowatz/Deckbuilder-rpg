# Bot report

Written by the playthrough bot (`bash tools/run_tour_bot.sh`, `tools/tour_bot.gd`) on 2026-10-24T02:11:52, 8.5 minutes.

- Areas: forest, town, beefcake, necrocrat, gourmand, refusemancer, capital
- Spots used (NPCs, shops, signs, chests...): 281
- Menus opened: deck_station, codex, character_screen, quest_log, full_map, wardrobe, vendor, item_vendor, pack_vendor
- Battles: beefcake (Flexing Brute), necrocrat (Shambling Middle Manager), gourmand (Meatloaf Golem), refusemancer (Mossy Trash Golem), final (Compliance Officer)
- Errors: 0, warnings: 0

## Frames over 33 ms

| Area | Frames | Over 33 ms | Worst (ms) |
|---|---|---|---|
| forest | 60 | 1 | 39 |
| town | 3223 | 39 | 128 |
| beefcake | 2484 | 20 | 70 |
| beefcake battle | 241 | 0 | 20 |
| necrocrat | 3058 | 16 | 77 |
| necrocrat battle | 241 | 0 | 20 |
| gourmand | 2618 | 13 | 74 |
| gourmand battle | 241 | 1 | 53 |
| refusemancer | 3873 | 22 | 97 |
| refusemancer battle | 241 | 1 | 50 |
| final | 8362 | 54 | 134 |
| final battle | 241 | 0 | 20 |

## Slowest moments (worst frame during one action)

- final: use complaint_2: 134 ms
- final: use seal_reek: 133 ms
- final: use sign_4: 130 ms
- final: use lost_poster_0: 128 ms
- final: use sign_1: 128 ms
- town: use pack_vendor: 128 ms
- town: arrive: 127 ms
- final: use sign_34: 126 ms
- town: use well: 125 ms
- final: use seal_out_a: 123 ms
- final: use complaint_1: 114 ms
- town: use deck: 113 ms
- refusemancer: use sign_1: 97 ms
- final: use fern: 87 ms
- final: use fig: 86 ms

## Where the slow frames are (frames over 33 ms per action, top 15)

- beefcake: use brenda: 6
- final: use seal_reek: 5
- final: use lost_poster_0: 4
- necrocrat: use barnaby: 4
- final: use wren: 4
- final: use sign_34: 4
- final: use sign_4: 4
- final: use sign_1: 4
- beefcake: use spot_me: 3
- refusemancer: use hob: 3
- final: use fig: 3
- town: arrive: 3
- town: use well: 3
- town: use vendor: 3
- town: use deck: 3

## Errors

None.

## Warnings

None.

## Log

- forest: no spot list to tour
