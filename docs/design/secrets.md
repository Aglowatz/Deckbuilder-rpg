# Town Secrets (Spoilers)

This file exists so you (the designer) can find everything without hunting for it. It is not
shown to players in-game. Keep it in sync with `world/town_builder.gd`
(`HIDDEN_CHEST_CELLS`/`HIDDEN_CHEST_REWARDS`) and `world/town_scene.gd`
(`_open_hidden_chest`/`HIDDEN_CHEST_REWARDS`) if either changes.

## Part D/E secrets (previous brief, D38)

Still in town, unrelated to the 5 new chests below - see `docs/progress.md`'s "Part D: town
expansion and its three secrets" section for the full writeup:

1. **A hidden chest** in the Secluded Grove, tucked behind trees near `cell_center(11, 7)` -
   grants 60 gold, one-time (`Session.discover_secret("harbor_chest")`).
2. **A sealed vault** (the `X` castle building) - opens once a nearby lever (an easy-to-miss
   ladder prop) sets `vault_lever_pulled`.
3. **A hidden vendor** - only constructed at all once the chest above (#1) has been found; sells
   a small always-open stock of Epic/Legendary cards.

## New brief, Part D: 5 hidden chests

No arrows, name plates, map icons, glow or objective hints on any of these - the only tell is the
standard `[E] Open the chest` prompt, and only within `TownScene.HIDDEN_CHEST_RADIUS` (~1.5m).
Each is a `chest_gold` prop at 1/4 scale (0.225, vs. 0.9 for the D38 chest above) and each is
one-time, tracked by its own secret id (`Session.found_secret("hidden_chest_<id>")`). World
coordinates are hex (col, row) as `HexGrid.cell_to_world` takes them - see
`world/town_builder.gd`'s MAP legend for the district layout.

| id | Where | How it's tucked | Contents |
|----|-------|------------------|----------|
| `west_woods` | West Woods, world (-4, 5) | Among a small stand of trees, off the main path through the woods, roughly level with the Root gate | 45 gold |
| `harbor_dock` | Harbor Dock, world (17, 6) | In a back-alley pocket between the dock's crates and buildings, south of the main Tide-gate corridor | 30 gold + **Healing Draught** (item) |
| `grave_hollow` | Grave Hollow (the southwest corner), world (-4, 12) | In a misty, tree-ringed hollow off the causeway to the Grave gate | **Reckless Tonic** (item) + **Stag Warden** (card, Uncommon Guard) |
| `uplands` | North Uplands, world (8, -2) | On the overlook meadow, tucked onto a small grassy islet between two ponds, just off the path up to the Final gate | 50 gold + **Stone Sentinel** (card, Common Guard) |
| `ember_flats` | Ember Flats, world (9, 12) | In a small stand of trees off the causeway down to the Ember gate, east of the vault's row | **Vitality Charm** (item) |

Total: 125 gold, 3 items, 2 cards, one per new district (not all clustered in one place). Both
cards (`stag_warden`, `stone_sentinel`) are Common/Uncommon on purpose - a hidden chest is a nice
find, not a power spike.

**Why none of the 5 sit in the original core** (D67): the first draft put one behind a house near
the market/gate cluster (world (1, 2), then (2, 1) after a first relocation attempt). Both
positions reproducibly screenshotted as a blank sky-colored frame with only a small, correctly-
placed fragment of geometry in one corner - while every other position in town, including other
spots in that same original core (e.g. the Codex, the gate itself), screenshotted correctly.
Camera position/rotation logged at capture time were numerically normal and matched a working
example closely, so the cause was not root-caused in the time available; the chest was moved to
Ember Flats (a location already proven to render correctly) rather than ship something
unverified. Worth a fresh look if anyone ever revisits this area.
