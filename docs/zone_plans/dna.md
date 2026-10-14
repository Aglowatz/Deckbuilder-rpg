# The Department of Necrotic Affairs: zone plan

Art Bible row: perpetual 4:59 pm overcast gloom; cold flat light with green ghost glows; palette #6E7470, #9BB59A, #3D4A44, #C9C6B8, #4FBF7A, #8A2E2E; mood bureaucratic, gloomy, deadpan funny; building language gray stone office blocks, filing-cabinet towers, queue barriers, columned civic halls; material swaps shared kit in gray stone, dark paneling, wallpaper; carpet, marble, linoleum ground. Style file `data/zone_styles/dna.json`. Data `data/subareas/dna/`.

Hero landmarks (Art Bible): Filing-cabinet tower, the endless queue, the Hall of Final Approvals facade, the Records Basement entrance.

## Structure (G-07)

| Place | Scene | Mood | Hero landmark stand-in | Size (m) | Points of interest | Exits |
|---|---|---|---|---|---|---|
| **Lobby Plaza** (hub) | the existing scene `dna_zone.tscn` | existing | existing landmarks | existing | all existing content | gates to Cubicle Fields, The Queue, Records Basement |
| **Cubicle Fields** | `cubicle_fields` | Flat and endless: grey partitions to the horizon, one plant, a distant phone ringing for nobody | DNA-HERO-FILING-TOWER | 80.0 x 64.0 | Desk Drawer (chest); Memo (lore); Junior Associate (vignette); Overlook (vista); Approvals Shrine (shrine) | Lobby Plaza, The Queue |
| **The Queue** | `the_queue` | Patient to the point of geology: a line that began before the building and has no intention of finishing | DNA-HERO-ENDLESS-QUEUE | 76.0 x 56.0 | Lost Property (chest); Number Board (lore); Veteran of the Line (vignette); Patience Shrine (shrine); End of the Line (vista) | Lobby Plaza, Cubicle Fields, Records Basement |
| **Records Basement** | `records_basement` | Dim and enormous: shelving in canyons, a green ghost-lamp every forty feet, dust that has formed opinions | DNA-HERO-RECORDS-STAIR | 72.0 x 60.0 | Sealed Folder (chest); Cold Cabinet (chest); Filed Complaint (lore); Archivist (vignette); Stamp Shrine (shrine) | Lobby Plaza, The Queue, Executive Approach |
| **Executive Approach** | `executive_approach` | Cold marble and a long, polite hush: the sort of corridor where you start to apologise before you are spoken to | DNA-HERO-FINAL-APPROVALS | 70.0 x 64.0 | Executive Safe (chest); Plaque (lore); Door Usher (vignette); Stamp of Approval (shrine); Under the Facade (vista) | Records Basement |

A 15-20 second walk is about 75-100 m at the 4.9 m/s walking pace; each sub-area lists 4 or more points of interest placed in walking order along its paths (chests, vistas, vignettes, lore pages, a rare card shrine, a lever).

## Loops, shortcuts, secrets

* Loops: every sub-area has at least one exit besides the way in (or a chest / shrine as the reward for the dead end); the links are in the table above and in `data/subareas/dna/`.
* Secrets: the shrines and the far-corner chests.

## Where existing content goes

Everything stays in the Lobby scene: Agnes, Prudence, Mortimer, Dolores and Barnaby (quests), Pip Ledgerbone's vendor, Ectomund's quiz, Kyle's matching minigame, the time clock, the suggestion box, the coffee machine, the mail-room puzzle, the Sub-Basement 3 mini dungeon, the Executive main dungeon at the north stair, Shiro Swindle's giant chest, the vault lever, the Rift station, the heal spot and the 14 hidden chests of the farms, maze, records and executive wing. Cubicle farms, the maze and the records wing in the hub are the Art Bible's Cubicle Fields, Records and Executive regions; the new scenes extend them.

## New content

5 chests (rewards drawn from the zone's own chest tables: gold, items, cards), 4 card shrines, 4 lore pages, 4 vignettes, 3 vistas, 0 lever shortcuts. No new economy: `SubAreaRewards` reuses `ZoneDef.chest_rewards` and docs/design/progression.md is unchanged.

## Status

Planned, blocked out (scenes load from `data/subareas`), asset list `docs/art/zone_kits/dna.md`, paint-over inputs `docs/art/paintover_inputs/dna/`, camera contact sheet `docs/art/zone_plans_shots/dna.png`. Details and numbers: `docs/overnight_report.md`.
