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

## Brief 10: the Capital - the secret entrance and 9 hidden chests

Same rules as every zone: a `chest_gold` prop at 1/4 scale (0.225), **no marker, no plate, no minimap icon** (never on any map),
the only tell is `[E] Open the chest` within `ZoneScene.HIDDEN_CHEST_RADIUS` (~1.5 m); one-time per chest, secret id
`cap_<chest id>`. Rewards live in `CapitalZone.CHEST_REWARDS`, positions in `CapitalLayout._chests()`; keep all three in sync.

### The secret entrance: the Old Joint Works

A forgotten service tunnel the four Paths built together back when they cooperated. It is the only way past the Approved Gate
that is not the Gate Captain's card battle. **No marker, no plate, no minimap icon** (it is a `hidden` spot, the same rules as a
chest: only an up-close `[E] Squeeze through the gap` prompt, and only within 1.5 m).

| Where | How it is tucked | Hint (only for those who read signs) | What it does |
|-------|------------------|---------------------------------------|---------------|
| South-west corner of the **Outskirts**, (7, 72), behind a toppled statue of Primm and a rubble heap | Looks like rubble; the hatch under it is a hole | A pinned note by a post at (12, 74) ("forgotten service shaft, SW of the wall, behind the fallen statue") and a faded Old Joint Works sign at the far east edge (115, 80) | Leads straight into **the Crease** (the hideout), sets `cap_hub_known`, `cap_inside` and the secret `capital_old_joint_works` (the **gate stays closed**: you simply sneaked past it). The Crease's tunnel arch leads back out to the same place. |

### The nine hidden chests

| id | Where (world x, z) | How it's tucked | Contents |
|----|--------------------|-----------------|----------|
| `chest_wreck` | The Outskirts, (14, 89) | Behind a wrecked wagon stack in the south-west corner | 60 gold + **Field Bandage** |
| `chest_rock` | The Outskirts, (113, 70) | Behind a boulder against the east edge | 80 gold + **Tasting Menu** (card) |
| `chest_reek` | The Reek, (5, 52) | Behind a heap of junk against the west wall | 40 gold + **Healing Salve** |
| `chest_crypt` | Grave Row, (5, 21) | In the corner behind the mausoleum row | 90 gold + **Necromancer** (card, Epic) |
| `chest_cellar` | The Hungry Quarter, (114, 18) | Behind a shuttered stall at the north-east corner | 70 gold + **Hearty Pie** |
| `chest_wheel` | The Transit Yards, (114, 56) | Beyond the third energy wheel, against the south-east wall | 100 gold + **Max Rep** (card) |
| `chest_lane` | The service lane behind the facade, (45, 13.5) | Between the facade's back wall and the Castle Approach | 120 gold + **Vitality Charm** |
| `chest_corner` | The Castle Approach, (90, 3.5) | In the north-east corner behind the last statue | 50 gold + **Ward Sigil** |
| `chest_ward` | The Correction Ward, (115, 4) | In the ward's north-east corner (beyond the rift) | 150 gold + **Recycle Bin** (card) |

Verified in `tests/core/zone/test_capital.gd` (rewards defined for every chest, >= 6 chests, none inside an interact spot, none
a minimap kind, the tunnel spot hidden and not a POI, reachability from the road through the gate) and the windowed e2e
(`tools/tenth_brief_final_smoke.gd`).

## Brief 12, Part F: three special cosmetics (spoilers)

None of these is sold by the tailor (Tilda Thimble hints at all three once the first zone is freed). Each is purely visual.

| Cosmetic | Where | How |
|---|---|---|
| **Crown of Leaves** (hat) | Verdant Dump, the hidden chest `chest_fridge` (`HeapZone.CHEST_REWARDS`) | one-time hidden chest, no marker; also pays 40 gold. Granted by `ZoneScene._open_chest` through the new `"cosmetic"` reward key |
| **Tattered Cloak** (cloak) | Gainlands, the hidden chest `chest_ground_0` (`GainlandsZone.CHEST_REWARDS`) | one-time hidden chest; also pays 40 gold |
| **Royal Mantle** (cloak) | beating Primm for the first time | `Session._grant_dungeon_packs` (Capital first clear); announced as a town notice |

The tailor's regular stock (zones and levels): Tricorn (level 5), Top Hat (1 zone), Cat-Ear Band (level 8), Mushroom Cap (2 zones), Patchwork Cloak (level 4), Leaf Cloak (1 zone), Starfall Cloak (3 zones).

## Polish round: 37 more hidden chests (4 in town, 3 in the starting area, 6 in each of the five zones)

Same rules as every chest above: a `chest_gold` prop at 1/4 scale (0.225), **no marker, no plate, no glow, no minimap icon**, the only tell is the
`[E] Open the chest` prompt within 1.5 m, one-time, saved as a found secret. New this round:

- **An opened chest stays open.** Its lid (the model's separate `chest_gold_lid`) swings up when you open it and is shown up and empty from then on,
  including after saving, loading and re-entering the area (`ChestKit.apply_saved`, run by every world scene when it builds).
- **A reward box** opens a moment after the lid: gold, cards drawn as real cards with their art, items, equipment, packs and cosmetics. The hero stands
  still until the player clicks or presses Enter / Space / E (`RewardPopup`, on the shared `PopupFrame`).
- **Reward quality scales with how hard the chest is to reach.** Tiers used below: I (a corner or edge you can simply walk to) pays gold and a basic
  item; II (a long walk, a deep dead end, behind a gate) pays more gold plus an Epic card, a path pack or a basic/advanced equipment piece; III (a floating
  island, a mesa top, a summit, the deepest maze end, the far corners) pays a **gilded pack** (guaranteed Epic or Legendary), advanced equipment or a
  rare cosmetic. The ordering is checked in `tests/world/test_polish_chests.gd`.
- **How "hard to reach" is done.** The game has no jump or climb button, so rooftops, ledges and tricky jumps are not new mechanics: the hard spots use the
  traversal the game already has (a throw or portal to a floating island, a jelly pad up a mesa, a beanstalk up a summit, the Brisket/Casserole/Sir Loin
  gates, the mount up the scree, the maze, the tunnel into the Crease, the walk behind the facade houses) or sit in the far, tucked corners of a map. Every
  chest is also covered by the walkability check (`tests/world/test_walkability_zones.gd`), which fails if one cannot be reached from the spawn.

### Main town: 4 more (11 hidden chests in all)

Locations are in `TownBuilder.HIDDEN_CHEST_CELLS` / `HIDDEN_CHEST_OFFSETS`, contents in `TownScene.HIDDEN_CHEST_REWARDS`; each is 60-75 m (a long walk) from the spawn.

| id | Where | How it's tucked | Tier | Contents |
|----|-------|-----------------|------|----------|
| `clashatorium_west` | South-west shore, world cell (0, 20) | In a quiet grove at the far end of the shore, west of the Grand Clashatorium | I | 60 gold + **Healing Draught** |
| `harbor_pier` | North peninsula of the Harbor, cell (20, 0) | At the tip of the peninsula past the Gourmand gate road | II | 50 gold + **Mercenary Captain** (card, Uncommon) |
| `northeast_ridge` | Far north-east ridge, cell (14, -5) | At the very end of the Uplands' eastern ridge | II | 60 gold + **The Wanderer** (card, Epic) |
| `southeast_shore` | South-east shore beyond the Dev Shrine, cell (14, 17) | In a nook on the far south-east shore, the longest walk in town | III | 80 gold + **Gilded Gourmand Pack** |

### Starting area: 3 more (gold only)

Three camouflaged nooks in the treeline (`N` in `StartingAreaBuilder.MAP`), each with trees growing around it like the hidden tunnel's corner. They pay gold only,
because the hero has no profile yet (no items, cards or equipment exist before the element is chosen); like everything before the cave, the found state is saved
with the first save the cave creates.

| id | Where | Tier | Contents |
|----|-------|------|----------|
| `start_east` | East edge of the clearing, behind the trees right of the spawn | I | 25 gold |
| `start_west` | West edge, a nook opposite the tunnel's corner | I | 40 gold |
| `start_cave` | Behind the cave mouth's rocks, north-east | II | 70 gold |

### D.N.A.: 6 more (14 in all)

`DnaLayout._polish_chests()` / `DnaZone.CHEST_REWARDS`; secret id `dna_<id>`.

| id | Where (world x, z) | How it's tucked | Tier | Contents |
|----|--------------------|-----------------|------|----------|
| `chest_maze_3` | Filing Department maze, (2.4, 11.4) | The deepest dead end, far west | III | 60 gold + **Gilded Necrocrat Pack** |
| `chest_maze_4` | Filing Department maze, (9.6, 4.8) | A second dead end behind the north wall of the maze | II | 40 gold + **Thorned Loincloth** (advanced armor) |
| `chest_maze_5` | Filing Department maze, (8.4, 17.4) | The south-west pocket of the maze | II | 25 gold + **Necrocrat Pack** |
| `chest_records_2` | Records Basement, (87.6, 4.8) | North-east corner behind the last shelving row | II | 50 gold + **Mandatory Optional Team Meeting** (card, Epic) |
| `chest_exec_2` | Executive Floor, (52.2, 2.4) | Against the north wall behind the boardroom | I | 120 gold + **Healing Draught** |
| `chest_farm_c` | Cubicle Farm B, (87.6, 43.2) | The far south-east corner behind the last cubicle | I | 35 gold + **Vitality Charm** |

### The Gainlands: 6 more (13 in all)

`GainlandsLayout._chests()` / `GainlandsZone.CHEST_REWARDS`; secret id `gain_<id>`. Every floating island now has two chests.

| id | Where (world x, z) | How it's tucked | Tier | Contents |
|----|--------------------|-----------------|------|----------|
| `chest_pec_2` | **Pec Perch** (island), (19, 11.1) | On the island's east side, opposite the first chest | II | 80 gold + **Reckless Tonic** |
| `chest_delt_2` | **Delt Deck** (island), (85.2, 7.5) | On the west side, away from the thrower | II | 40 gold + **Portal-Ripping Titan** (card, Epic) |
| `chest_glute_2` | **Glute Garden** (island, locked long-haul throw), (111.5, 46.6) | On the island's north side | III | 60 gold + **Gilded Beefcake Pack** |
| `chest_calf_2` | **Calf Cove** (island, locked portal), (-8.8, 51.5) | North-west of the island, behind its crystal | III | 100 gold + **Hover Boots** (advanced boots) |
| `chest_ground_3` | Hamster Wheel Heights, (93, 36) | Tucked between the first wheel and the east cliff | I | 50 gold + **Healing Draught** |
| `chest_ground_4` | The Gainlands, (17.4, 25.2) | On the north-west cliff shelf above Mill Meadow | I | 30 gold + **Beefcake Pack** |

### The Endless Buffet: 6 more (14 in all)

`BuffetLayout._chests()` / `BuffetZone.CHEST_REWARDS`; secret id `buf_<id>`.

| id | Where (world x, z) | How it's tucked | Tier | Contents |
|----|--------------------|-----------------|------|----------|
| `chest_pancake_2` | **Pancake Summit** (mesa, jelly pad), (76.8, 11.4) | West edge of the pancake top, away from the stew pot | III | 70 gold + **Gilded Gourmand Pack** |
| `chest_cheddar_2` | **Cheddar Overlook** (mesa, gate + pad), (16.8, 18) | South side of the cheese top | II | 40 gold + **Chef de Golem** (card, Epic) |
| `chest_meadow_ne` | Mashed Potato Meadow, (90.6, 6.6) | The far north-east corner of the table | I | 90 gold + **Hearty Pie** |
| `chest_cliffs_w` | Cheddar Cliffs (behind Brisket's gate), (5.4, 11.4) | Against the west edge of the table | II | 30 gold + **Gourmand Pack** |
| `chest_crust` | Mashed Potato Meadow, (42.6, 4.8) | A tight nook against the back edge, behind the crust | II | 60 gold + the **Chef's Toque** (hat) |
| `chest_edge_sw` | Broccoli Forest edge, (4.8, 24.6) | In a pocket on the west rim | I | 45 gold + **Scroll of Insight** |

### The Verdant Dump: 6 more (14 in all)

`HeapLayout._chests()` / `HeapZone.CHEST_REWARDS`; secret id `heap_<id>`.

| id | Where (world x, z) | How it's tucked | Tier | Contents |
|----|--------------------|-----------------|------|----------|
| `chest_peak_c` | **Rust Peak** summit (beanstalk), (19.8, 11.4) | The summit's north-east lip | III | 70 gold + **Gilded Refusemancer Pack** |
| `chest_peak_d` | **Mount Scrapmore** summit (beanstalk), (90, 54) | The summit's east lip, past the chute | II | 60 gold + **Poo-uid** (card, Epic) |
| `chest_scree_ne` | The Scree Fields (mount only), (82.2, 4.8) | North-east corner of the scree | II | 50 gold + **Big Brain Beret** (advanced helm) |
| `chest_corner_nw` | The Verdant Dump, (8.4, 7.2) | The far north-west corner | I | 90 gold + **Hearty Pie** |
| `chest_back_edge` | The Verdant Dump, (34.8, 4.8) | A nook against the back edge | I | **Refusemancer Pack** |
| `chest_thicket_s` | The Patchwork Fields, (4.8, 28.2) | A thicket on the west rim | I | 40 gold + **Healing Salve** |

### The Capital: 6 more (15 in all)

`CapitalLayout._chests()` / `CapitalZone.CHEST_REWARDS`; secret id `cap_<id>`.

| id | Where (world x, z) | How it's tucked | Tier | Contents |
|----|--------------------|-----------------|------|----------|
| `chest_facade_back` | Primm's Perfection, (75.6, 16.8) | Behind the facade: against the back wall behind the last identical house | II | 100 gold + **Royal Audit** (card, Epic) |
| `chest_facade_west` | Primm's Perfection, (43.8, 22.2) | Behind the facade: squeezed between the west wall and the first row of houses | II | 80 gold + **Ward Sigil** |
| `chest_crease_e` | The Crease (through the tunnel or the manhole), (40.2, 100.8) | East end of the hideout | I | 60 gold + **General Pack** (expanded) |
| `chest_crease_w` | The Crease, (4.8, 100.8) | West end, past the ladder | I | 70 gold + **Hearty Pie** |
| `chest_ward_n` | The Correction Ward, (95.4, 8.4) | North side of the ward, beyond the rift | II | 120 gold + **Cheater's Dice** (advanced relic) |
| `chest_yard_corner` | Checkpoint Row, (2.4, 2.4) | The farthest corner of the whole map | III | 150 gold + the **Top Hat** (hat) |

## Brief 16, Group B: the giant chests and Shiro Swindle (spoilers)

**Five giant chests, all joke chests.** Each is the big `chest_gold` model (scale 0.9, four times the size of a hidden chest) with no marker and no plate; the usual `[E] Open the chest` prompt appears within 1.9 m. Opening one starts the scene in `world/ninja/giant_chest_event.gd`:
the lid swings up, **Shiro Swindle, Master of the Oldest Trick** (`NPC-NINJA`, placeholder portrait drawn in code until real art is imported) leaps out, delivers that chest's own taunt, steals **50 gold** (or all of it when the player has less), a floating "-50 gold" and a toast show the amount,
he shouts **SMOKE BOMB!!!** and vanishes in a puff of smoke (synthesized `smoke_bomb` sound). An opened chest stays open. The first chest opened adds the quest **The Oldest Trick in the Book** to the log ("Open the giant chests n/5").

| Chest id | Where | Notes |
|----------|-------|-------|
| `town` | The tip of a lonely peninsula in the far south-east of the main town (hex (18, 12), MAP row 17, reached by the south-east shore) | The ORIGINAL chest (moved from beside Bertram Beetsworth in the Secluded Grove). Opening it still reveals the Secret Dealer the first time. |
| `beefcake` (Gainlands) | (24.0, 63.6): out on the open meadow west of the Swole Station | 28 m from the hub |
| `necrocrat` (D.N.A.) | (28.2, 42.6): the open floor north-west of the lobby, beside the cubicle farm | 20 m from the spawn |
| `gourmand` (Endless Buffet) | (28.8, 72.6): down at the front edge of the table, west of the Grand Pantry | 22 m from the spawn |
| `refusemancer` (Verdant Dump) | (22.8, 73.8): the heap's south-west shoulder | 27 m from the spawn |

**After all five are opened (any order):** the fifth chest's taunt adds "come and meet me where it all began". The original chest (in town) closes again and glows faintly (a pulsing gold light and sparkles). Opening it plays his lines and starts a duel against Shiro Swindle on the main town battleboard
(`NinjaBoss`: 18 HP, a trap deck: Tripwire, Ambush Party, Dinner Is Served, Sent Back to the Kitchen, Invisible Ink, Underdog's Gambit, Pink Slip, Unconscionable Contract and a swarm of Elusive/Flying scouts; the Balanced AI). **Winning** returns every coin he stole, pays **3 Gilded Packs (one random Path each)**, ends the questline and leaves the chest open for good.
**Losing** changes nothing: the chest stays closed and glowing, retry any time. All progress is saved (`ninja_chest_<id>` secrets, the `ninja_gold_stolen` and `ninja_chests_opened` counters, the `ninja_defeated` flag, the quest log).

## Brief 16, Group C: the Capital's secret wall passage (spoilers)

A 2 m wide gap through the city wall, **far along the LEFT-hand (west) side of the wall, at x = 22..23** (the wall's far-west stretch, about 37 m west of the Approved Gate), lets a player who sneaks along the wall slip into the main area (the Reek's north end, then Checkpoint Plaza) while the gate is still shut and its guards stand at the gate.
No marker, no sign, no map icon, no prompt. The only hints are visual: two thin dark **cracks** climbing the wall face either side of the gap, a few **loose stones** fallen at its foot and three clumps of **dry scrub** half-hiding the opening (scrub does not block walking).
Walking through sets the secret `capital_wall_passage` (toast: "You squeeze through a gap in the wall, right past the gate guards.") and the usual inside-the-walls changes (the bright Neatropolis look, the `cap_inside` flag) apply by position as for the gate.
It is separate from the Old Service Tunnels (S-CAP, which comes up in the Crease). Code: `CapitalLayout.PASSAGE_X0/PASSAGE_W`, props `wall_crack`, `loose_stones`, `scrub` (`world/capital/capital_props.gd`); tests: `tests/core/zone/test_capital_wall_passage.gd`.
