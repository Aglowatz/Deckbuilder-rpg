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

## Fourth brief, Part E: 2 more hidden chests (equipment)

Same rules as the 5 above exactly - no markers, `[E] Open the chest` only within
`TownScene.HIDDEN_CHEST_RADIUS`, one-time. Placed in two of the five districts that already have
a proven-safe chest (D67 - avoiding the original core's unexplained rendering bug there), at a
cell well clear of every other anchor in that district, rather than risking an unverified new
spot. Each holds one **basic** equipment piece (never advanced - a hidden find should feel like a
nice head start, not a shortcut past the level-10 vendor unlock):

| id | Where | How it's tucked | Contents |
|----|-------|------------------|----------|
| `uplands_ridge` | North Uplands, world (11, -3) | A quiet grass shelf above the main overlook path, north of the district's existing chest | **Traveler's Boots** (equipment, Boots) |
| `harbor_dock_back` | Harbor Dock, world (16, 2) | Tucked in a stand of trees at the district's inland edge, a row over from the dock's main chest | **Solid Plate** (equipment, Armor) |

Verified with a real windowed run (`tools/town_interact_smoke.gd`, extended alongside Part C's
equipment-vendor coverage): walks to `uplands_ridge`, confirms no prompt from 4m, confirms the
prompt appears up close, opens it and confirms `owned_equipment` actually gains the piece.

**Why none of the 5 sit in the original core** (D67): the first draft put one behind a house near
the market/gate cluster (world (1, 2), then (2, 1) after a first relocation attempt). Both
positions reproducibly screenshotted as a blank sky-colored frame with only a small, correctly-
placed fragment of geometry in one corner - while every other position in town, including other
spots in that same original core (e.g. the Codex, the gate itself), screenshotted correctly.
Camera position/rotation logged at capture time were numerically normal and matched a working
example closely, so the cause was not root-caused in the time available; the chest was moved to
Ember Flats (a location already proven to render correctly) rather than ship something
unverified. Worth a fresh look if anyone ever revisits this area.

## Third follow-up brief, Newest Part D: the starting-area hidden tunnel

A hidden tunnel in the **starting area** (not town) - the tiny enclosed clearing the game opens
in, before any element/deck choice exists. `StartingAreaBuilder.MAP`'s bottom-left corner cell
(row 3, col 0 - the corner nearest the spawn row, carved out of what would otherwise be treeline
wall) is walkable and camouflaged by scattered trees exactly like the map's other wooded cells; the
only tell is the standard `[E] Slip through the tunnel` prompt, and only within
`StartingAreaScene.TUNNEL_RADIUS` (1.5m, same tightness as the town's hidden chests). No arrow,
glow, name plate or map icon of any kind.

**Using it** (`Session.skip_tutorial_via_secret_tunnel`, only reachable before a profile exists -
a first-ever visit): plays one short flavor dialogue line, then the same `ElementChoiceScreen` the
real cave-mouth gate uses. Choosing an element grants:
- The 42-card starter deck (`CampaignStart.starter_deck`) plus **3 random** (not curated) cards of
  that element (`CampaignStart.random_element_cards`) - a real, legal 45-card deck, same as a real
  tutorial clear leaves the player with, just reached a different way.
- The same total XP and gold the tutorial's 2 battles + boss would pay out
  (`TrialOfTheHollow.total_tutorial_rewards()` - the challenge/shrine nodes pay neither): 150 XP,
  280 gold, though the actual gold gained can be a little higher if that XP happens to cross a
  level with its own gold reward (exactly what a real tutorial run gaining the same XP the same
  way would also do - not specific to the skip).
- `intro_dungeon_cleared`, `cleared_dungeons`, and the `trial_cleared` flag - the same
  tutorial-complete state a real clear leaves, so town opens normally.
- One-time, tracked like any other secret: `Session.found_secret("starting_area_tunnel")`.

The player goes straight to town - no dungeon in between. Human-input e2e coverage:
`tools/starting_area_tunnel_smoke.gd` (run via `tools/run_starting_area_tunnel_smoke.sh`) walks to
the tunnel with injected WASD, interacts, dismisses the dialogue, picks an element through the real
`ElementChoiceScreen`, and asserts the deck/XP/gold/flags/secret all land correctly and the scene
actually transitions to town.
