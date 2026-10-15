# The Gainlands (Beefcake): zone plan

Art Bible row: bright midday sun, crisp shadows; palette #F2C14E #D9483B #8BC34A #F7EBD3 #7A5230 #5FA8D3; energetic, sunny, comically macho; sturdy timber-and-brick mills and gym halls with rope and iron, red-gold banners; kit in sun-bleached wood, red brick, brass; gym-mat and chalk ground. Style file `data/zone_styles/gainlands.json`, kit `data/art/zone_kits/gainlands.json` (imported, `docs/art/gainlands_slice.md`), corrections `docs/art/gainlands_corrections.md`.

**One walkable area** (Art Bible G-07, `docs/design/subarea_removal.md`): the whole zone is the scene `gainlands_zone.tscn` (`GainlandsLayout` / `GainlandsBuilder` / `GainlandsDressing`). There are no sub-area scenes; variety comes from the regions below. Every dungeon is node-based from an entrance in the zone.

## Regions

| Region | Where | What is there | Landmark |
|---|---|---|---|
| The rope bridge | south rim (BRIDGE_*) | Arrival from town facing north; walking off the far end leaves for town | `GainlandsLandmarks.rope_bridge` |
| Swole Station (hub) | plaza round (52, 64), PLAZA_RADIUS 8.5 | Old Man Mountain, Foreman Gus, Benchley's (vendor), the hot tub, the flex mirror, the protein stand, the Rift Express, the quiz-answer boards | GAIN-HERO-SWOLE-STATION (modelled) |
| Mill Meadow | west (mills at (22, 52), (30, 32), (40, 46)) | The three giant mills, the hero Wheel, Professor Pump's quiz (22, 40), the hut | GAIN-HERO-WHEEL (modelled, 9 m, turns) at (33, 55) |
| The training field | between the mills and the dungeon road | The Champions Arch, the Record Board (lore sign), the Pump Shrine (one card from the zone table, once) | GAIN-HERO-CHAMPIONS-ARCH (modelled, 9 m) at (41, 36.5) |
| Hamster Wheel Heights | east (wheels at (86, 38), (73, 36), (92, 58)) | The hamster wheels, the Colossal Hamster Wheel (run_wheel), the power-grid puzzle (77, 44), the vault lever on the east rim | the wheels (GainlandsProps) |
| Studio 3 AM | (69, 49.5) | Chet Thunderabs and the reps minigame stage | the stage |
| The Boulder Gym | south-east (62-80, 63-76) | Bench presses, racks, logs, boulders, Gary under a barbell (spot_me) | the gym |
| The House of Gains causeway | north (50, 10) | The main dungeon entrance on the causeway in front of the fortress doors (no plate, icon board) | GAIN-HERO-HOUSE-OF-GAINS (fortress model, 48 x 34 x 30 m, beyond the north rim) |
| The locked Swolympus rim | north-east (86, 31) | The closed trailhead gate ("Mount Swolympus (coming soon)", E toasts) and the sealed Iron Cavern beside it (78, 27) | GAIN-HERO-TRAILHEAD-GATE (modelled, closed) with GAIN-HERO-SWOLYMPUS in the distance at (112, 2) |
| The floating islands | Pec Perch, Delt Deck, Glute Garden, Calf Cove | Thrower and ripper travel, island chests, the Pec Perch mirror | the islands |
| The sky | north-west, high | A view: the Sky Tree on its own islet | GAIN-HERO-SKY-TREE (modelled) at (4, 15, -12) |

## Dungeons (node maps)

| Dungeon | Entrance in the zone |
|---|---|
| Main: the House of Gains | the `main_dungeon` spot on the causeway (50, 10) |
| Mini: the Iron Cavern | the `mini_dungeon` spot (78, 27), sealed until the postgame (GC-11): the prompt says coming soon |
| Side: S-BEEF, the Ascent of Mount Swolympus | the same cavern once its quest ("Water for the Hermit", postgame) unlocks it |

## What the removed sub-areas left behind (SR-7, SR-8)

Kept: the Wheel, the Champions Arch, the Sky Tree (views and region landmarks above), the Pump Shrine, the Record Board, the locked trailhead gate. Dropped: the Proving Grounds, Mill Fields, Swolympus Trailhead and Sky Garden scenes with their chests, vistas, vignettes, the rock lever and the other shrines and boards (their words stay in the audit, `docs/design/subarea_removal.md`).

## Art status

Kit imported (33 ids), hub dressed and matched to the paint-overs (`docs/art/gainlands_slice.md`); paint-over input `docs/art/paintover_inputs/gainlands/PO-GAINLANDS-HUB.png`; contact sheet `docs/art/zone_plans_shots/gainlands.png`; asset list `docs/art/zone_kits/gainlands.md`. The PAINTOVER-GAINLANDS-* pictures in `docs/art/paintovers/` show regions of this one map.
