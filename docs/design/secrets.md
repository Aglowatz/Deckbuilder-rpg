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
| `west_woods` | West Woods, world (-4, 5) | Among a small stand of trees, off the main path through the woods, roughly level with the Refusemancer gate | 45 gold |
| `harbor_dock` | Harbor Dock, world (17, 6) | In a back-alley pocket between the dock's crates and buildings, south of the main Gourmand-gate corridor | 30 gold + **Healing Draught** (item) |
| `grave_hollow` | Grave Hollow (the southwest corner), world (-4, 12) | In a misty, tree-ringed hollow off the causeway to the Grave gate | **Reckless Tonic** (item) + **Stag Warden** (card, Uncommon Guard) |
| `uplands` | North Uplands, world (8, -2) | On the overlook meadow, tucked onto a small grassy islet between two ponds, just off the path up to the Final gate | 50 gold + **Stone Sentinel** (card, Common Guard) |
| `beefcake_flats` | Beefcake Flats, world (9, 12) | In a small stand of trees off the causeway down to the Beefcake gate, east of the vault's row | **Vitality Charm** (item) |

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
Beefcake Flats (a location already proven to render correctly) rather than ship something
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

## Brief 5, Part I: the D.N.A. zone's hidden stashes (8) and interactables

Same rules as the town's chests: a `chest_gold` prop at 1/4 scale (0.225), **no markers, no plate, no glow** - the only tell is the `[E] Open the chest` prompt, shown only within `DnaScene.HIDDEN_CHEST_RADIUS` (1.5 m). One-time, saved as `Session.found_secret("dna_<id>")`. Each also bumps the `dna_chests_opened` counter (Compliance Audit quest). Rewards: `DnaScene.CHEST_REWARDS`; positions: `DnaLayout` (`chests`).

| id | Where | Contents |
|----|-------|----------|
| `chest_farm_a` | Cubicle Farm A, the far north-east corner behind the last row of cubicles | 35 gold |
| `chest_farm_b` | Cubicle Farm B, the far north-west corner | Healing Salve |
| `chest_maze_0` | Filing Department maze, the north-most dead end | 50 gold |
| `chest_maze_1` | Filing Department maze, the south-most dead end | Scroll of Insight + Overdue Intern (card) |
| `chest_maze_2` | Filing Department maze, a middle dead end | 25 gold + Firebrand Charm |
| `chest_records_0` | Records Basement, south-east corner | 60 gold |
| `chest_records_1` | Records Basement, north-west corner (behind the first shelving rows) | Vitality Charm + Cubicle Zombie (card) |
| `chest_exec` | Executive Floor, the north-west corner by the boardroom wall | 80 gold + Healing Draught |

(The maze is generated from a fixed seed, so the three maze chests are always in the same dead ends.)

### Interactables (real effects; `world/dna/dna_interactables.gd`)
- **Breakroom coffee machine** (5 gold): random - 30% heal 2, 15% heal 4, 20% bad cup (-1 life, never kills), 15% a coin back (+15 gold), 20% empty cup. Counts toward Mandatory Onboarding.
- **Time clock** (breakroom wall): "punch in" once per visit for +2 max life (and +2 life) until you leave. Counts toward Mandatory Onboarding.
- **Haunted printer** (Cubicle Farm B, far west): 40 gold prints a random Necrocrat vendor card; 20% of the time it jams and keeps your money.
- **Suggestion box** (breakroom, by the lobby door): the first suggestion pays 25 gold and an Overdue Intern card; afterwards it is empty (`dna_suggestion_box` secret).
- **Puzzle terminal** (Mail Room): see progress.md Part F. **Quiz** (Cubicle Farm B corner office) and **Rec Room matching game** (Filing maze NW corner): see Parts G/H.

## Brief 6: the Gainlands - 7 hidden chests

Same rules as the town's and the D.N.A.'s: a `chest_gold` prop at 1/4 scale (0.225), **no marker, no plate,
no minimap icon** (never on any map), the only tell is `[E] Open the chest` within
`ZoneScene.HIDDEN_CHEST_RADIUS` (~1.5 m); one-time per chest, secret id `gain_<chest id>`. If a chest and an
NPC spot are both in reach, whichever is closer to the player wins the E key. Rewards live in
`GainlandsZone.CHEST_REWARDS`, positions in `GainlandsLayout._chests()`; keep all three in sync.

| id | Where (world x, z) | How it's tucked | Contents |
|----|--------------------|-----------------|----------|
| `chest_ground_0` | Mill Meadow, (18, 36) | Behind the west mills, off the quiz master's path | 40 gold |
| `chest_ground_1` | The Boulder Gym, (78, 64) | Behind the boulder gym equipment, south-east | 20 gold + **Healing Salve** |
| `chest_ground_2` | Leg Day Ridge, (58, 22) | In the trees north-east of the Closed-for-Leg-Day gate | **Wheel Runner** (card) |
| `chest_pec` | **Pec Perch** (floating island), (7.8, 13) | On the island's west rim, away from the thrower and the ripper | 60 gold + **Scroll of Insight** |
| `chest_delt` | **Delt Deck** (floating island), (95, 7) | At the island's far east end - mind the edge | **Max Rep** (card, Epic) |
| `chest_glute` | **Glute Garden** (floating island), (114, 54) | East end of the island (only reachable by the locked long-haul throw) | 90 gold + **Healing Draught** |
| `chest_calf` | **Calf Cove** (floating island), (-10, 58) | West end of the island (only reachable by Pec Perch's locked portal) | 50 gold + **Vitality Charm** + **Cheat Day** (card) |

Verified in `tests/core/zone/test_gainlands.gd` (rewards defined for every chest, >= 6 chests, >= 2 on islands,
reachable on foot / by travel) and the windowed e2e (`tools/sixth_brief_final_smoke.gd`: one island chest and one
ground chest opened with real input, prompt only up close).

## Brief 7: the Endless Buffet - 8 hidden chests

Same rules as every zone: a `chest_gold` prop at 1/4 scale (0.225), **no marker, no plate, no minimap icon**
(never on any map), the only tell is `[E] Open the chest` within `ZoneScene.HIDDEN_CHEST_RADIUS` (~1.5 m);
one-time per chest, secret id `buf_<chest id>`. Rewards live in `BuffetZone.CHEST_REWARDS`, positions in
`BuffetLayout._chests()`; keep all three in sync. The Fortune Cookie Dispenser's hints (`fortune.hints` in
`data/story/gourmand_story.tres`) point at them in the same order as this table.

| id | Where (world x, z) | How it's tucked | Contents |
|----|--------------------|-----------------|----------|
| `chest_loaf` | Broccoli Forest, (11.5, 68.5) | In front of a hollowed-out loaf of bread, in the far south-west corner | 40 gold |
| `chest_butte` | **Butter Butte** (mesa, needs the jelly pad), (66, 52.8) | On the mesa top, behind the butter pat, next to the honey | 20 gold + **Healing Salve** |
| `chest_candy` | Candy Field, (73.5, 71.5) | Beside a giant candy jar in the south-east corner | **Tasting Menu** (card) |
| `chest_salt` | The Salt Flats, (27.5, 52) | Hidden between two giant salt and pepper shakers by the river bank | 30 gold + **Scroll of Insight** |
| `chest_cheddar` | **Cheddar Overlook** (mesa, behind Brisket's gate + a pad), (11.5, 12) | On top of the cheese mesa | 20 gold + **Cheese Wheel Golem** (card, Epic) |
| `chest_wheel` | Cheddar Cliffs (behind Brisket's gate), (29, 8.4) | Behind a giant wheel of cheese, against the table's back edge | 60 gold + **Healing Draught** |
| `chest_pancake` | **Pancake Summit** (mesa, behind Colonel Casserole's gate + a pad), (87, 17) | On the pancake mesa top, east of the stew pot | 50 gold + **Vitality Charm** |
| `chest_cake` | Layer-Cake Town (behind Sir Loin's gate), (60.5, 22) | Between two layer-cake buildings | 90 gold + **Firebrand Charm** |

Verified in `tests/core/zone/test_buffet.gd` (rewards defined for every chest, >= 6 chests, >= 3 on mesas, none
inside an interact spot, reachability with the right crossings/pads/gates) and the windowed e2e
(`tools/seventh_brief_final_smoke.gd`).

## Brief 8: the Verdant Dump - 8 hidden chests

Same rules as every zone: a `chest_gold` prop at 1/4 scale (0.225), **no marker, no plate, no minimap icon**
(never on any map), the only tell is `[E] Open the chest` within `ZoneScene.HIDDEN_CHEST_RADIUS` (~1.5 m); one-time per
chest, secret id `heap_<chest id>`. Rewards live in `HeapZone.CHEST_REWARDS`, positions in `HeapLayout._chests()`;
keep all three in sync.

| id | Where (world x, z) | How it's tucked | Contents |
|----|--------------------|-----------------|----------|
| `chest_fridge` | County fair grounds, (73.6, 72.4) | Next to a rusted fridge in the south-east corner | 40 gold |
| `chest_compost` | The Patchwork Fields, (7.5, 72.5) | Beside a compost heap in the far south-west corner | 25 gold + **Healing Salve** |
| `chest_peak_a` | **Mount Scrapmore** summit (beanstalk), (84, 54.4) | On top of the junk mountain, near the chute | **Recycle Bin** (card) |
| `chest_hay` | The North Bank, (68, 37) | Behind a haybale, east of the second stable | 30 gold + **Scroll of Insight** |
| `chest_log` | Rust Peak yards, (26, 7) | Inside a hollow log against the back edge | 60 gold + **Healing Draught** |
| `chest_peak_b` | **Rust Peak** summit (beanstalk), (12.5, 14) | On top, west of the Seed Shrine | 20 gold + **Moss Titan** (card, Epic) |
| `chest_car` | The Landfill Rim (behind the barricade), (60.5, 22) | By a rusted car husk turned planter | 90 gold + **Firebrand Charm** |
| `chest_barn` | The Scree Fields (mount only), (88, 21) | Beside the scrap barn | 50 gold + **Vitality Charm** |

Verified in `tests/core/zone/test_heap.gd` (rewards defined for every chest, >= 6 chests, >= 2 on summits, none inside an
interact spot, reachability with the right bridges / beanstalks / mount / barricade) and the windowed e2e
(`tools/eighth_brief_final_smoke.gd`).
