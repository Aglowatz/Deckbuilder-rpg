# The Gainlands (Beefcake): zone plan

Art Bible row: bright midday sun, crisp shadows; palette #F2C14E #D9483B #8BC34A #F7EBD3 #7A5230 #5FA8D3; energetic, sunny, comically macho; sturdy timber-and-brick mills and gym halls with rope and iron, red-gold banners; kit in sun-bleached wood, red brick, brass; gym-mat and chalk ground. Style file `data/zone_styles/gainlands.json`. Data `data/subareas/gainlands/`.

## Structure (G-07)

| Place | Scene | Purpose | Mood | Hero landmark | Size |
|---|---|---|---|---|---|
| **Swole Station** (hub) | existing `gainlands_zone.tscn` | Arrival, healing, vendor, quest givers, rift station, every existing activity | Busy, sunny | Swole Station rift platform | 130 x 80 m (island map) |
| Mill Meadow / Hamster Wheel Heights / Boulder Gym / Studio 3AM / Leg Day Ridge (regions of the hub) | stay in the hub | The existing mills, wheels, gym, studio and the main dungeon ridge | | Giant hamster-wheel mill (existing wheels) | |
| Floating islands: Pec Perch, Delt Deck, Glute Garden, Calf Cove | stay in the hub (throw / rift travel) | Reward islands | | Floating islands | |
| **Proving Grounds** | `proving_grounds` | The outdoor arena everyone trains in: coach, records, a shrine | Energetic, mid-rep | Champion's Arch (GAIN-HERO-CHAMPIONS-ARCH) | 76 x 64 |
| **Mill Fields** | `mill_fields` | A quiet farm walk to the big wheel; hay, sunflowers | Golden, rhythmic | Giant hamster-wheel mill (GAIN-HERO-WHEEL) | 80 x 64 |
| **Swolympus Trailhead** | `swolympus_trailhead` | Foot of the mountain: gift shop, rock lever to the secret | Brave, windy | Mount Swolympus + trailhead gate | 72 x 72 |
| **Sky Garden** (secret) | `sky_garden` | Reward garden above the cloud | Hushed, bright | Sky tree + floating islets | 56 x 48 |

Gates in the hub (data `_zone.json`): Proving Grounds at the south edge (38, 73), Swolympus Trailhead on the main dungeon road (45, 24). Mill Fields hangs off the Proving Grounds; the Sky Garden off the Trailhead.

## Points of interest (a 15-20 s walk is about 75-100 m at 4.9 m/s)

| Area | POIs in walking order |
|---|---|
| Proving Grounds | spawn at the gate -> record board (lore) -> racks and coach vignette (coach heckles) -> central plaza -> Pump Shrine (rare card) -> Trophy Crate chest behind the east stand -> Overlook vista on the west stand; Gym Bag chest on the west side |
| Mill Fields | Miller log (lore) -> Wheel Keeper vignette under the wheel -> Millstone Cache chest east -> Harvest Shrine -> Grain Sack chest far NW |
| Swolympus Trailhead | Trail notice -> Gift Shop clerk -> Foot of the Mountain vista -> Rock Lever (opens the boulder wall) -> Hiker Pack chest NW |
| Sky Garden | Gardener note -> Rare Bloom Shrine -> Gardener Chest -> Above the Clouds vista |

## Loops, shortcuts, secrets

* Loop: hub gate (south) -> Proving Grounds -> east exit -> Trailhead -> hub gate (north). The Mill Fields branch returns through the Proving Grounds.
* Shortcut: the Rock Lever at the Trailhead removes the boulder wall; the Sky Garden exit behind it connects back down.
* Secrets: Sky Garden (lever), a second chest at the far NW of each sub-area behind a prop cluster.
* No dead end without a reward: Mill Fields and Sky Garden each hold a chest and a shrine.

## Where existing content goes

All stays in the hub scene (moving it would risk quests and saves): Brenda, Gus, Tony (vendor, Benchley's), the quiz master (Pump), Flex Mirror, the reps minigame studio, the wheels puzzle (swole belt), the mini dungeon entrance (66, 25), the main dungeon entrance (50, 19), Shiro Swindle's giant chest (24, 63.6), the vault lever (88.8, 55.2), the rift station, the heal spot, the zone exit (52, 74), 13 hidden chests, the four islands with throwers and rippers. The hub's own regions map to the Art Bible sub-areas Mill Fields (Mill Meadow), Floating Islands, and the Swolympus trailhead (Leg Day Ridge); the new scenes extend them.

## New content

12 points of interest per scene on average: 9 chests (tiers small / medium / large from the zone's own table), 4 shrines (cards from the zone table, once each), 6 lore pages, 5 vignettes, 4 vistas, 1 lever shortcut. Rewards come only from `ZoneDef.chest_rewards` (docs/design/progression.md is untouched).

## Status

Planned, blocked out, screenshots, asset list: see `docs/overnight_report.md`.
