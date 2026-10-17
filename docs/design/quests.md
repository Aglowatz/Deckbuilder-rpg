# Quests (Oct 16 overhaul)

Source of truth: `core/quests/quest_definitions.gd` (main lines, Brannoch, Maren, secrets) and `core/quests/zone_quest_definitions.gd` (zone favours, Capital
quests, side-dungeon hooks). `QuestCatalog` builds them at start-up (there are no generated `.tres` files any more). Regenerate the table below with
`Godot --headless --path . res://tools/quest_table.tscn`.

## Data model
- **QuestData**: id, category (`MAIN` story lines / `SIDE` favours), title (the player-facing name), a short summary, ordered objectives, completion
  rewards (gold, XP, items, cards, equipment, packs, unlock flags, in any combination), the giver and turn-in (display name + area + spot id for markers).
- **QuestObjective**: text, a `Condition` (flag, counter, quest completed, any-of...), a target (kind NPC / SPOT / ITEM_COUNT / BATTLE / DUNGEON /
  ZONE_FLAG, an area and a spot id, a "where to go" hint) and an optional **milestone** (`QuestReward`) paid the first time the step is met.
- Objectives are ordered: the first one not done is the current step (tracker highlight, world marker, "where to go").
- **QuestLog** (save): active, completed, counter baselines, tracked, `milestones_paid`, `progress_seen` (the tracker follows the most recently
  updated quest), `version` 2. `QuestMigration` upgrades version-1 saves (see below).

## Main quest lines
Each Path zone has one MAIN line: (1) beat its gatekeeper at the obstacle on its road out of the hub (**pays that Path's Path Pack + 40 gold**),
(2) cross into the zone, (3) finish any one of the zone's three favours (**pays an equipment piece**: the midpoint), (4) clear the main dungeon and
free the leader (**completion: the Path Pack, 200 gold, 150 XP**). Gatekeeper Brannoch, on the imperial road, gives **Free the Four Zones** (free
each zone, then storm the castle; 300 gold, 250 XP). **Fragments** (Maren's memories) is MAIN too.

| Zone | Main quest | Gatekeeper (obstacle) | Midpoint gear |
|---|---|---|---|
| The Gainlands | Raise the Bar | Brick Bronson, the Muscley Gatekeeper (the drawn-up gorge bridge) | Gotta-Go Galoshes (overworld speed +35%) |
| The D.N.A. | Take a Number | Prudence Pallor, Checkpoint Supervisor (the permit barrier) | Red Tape Dispenser |
| The Endless Buffet | Key Ingredients | Chef Fennel Gravois, Keeper of the Pantry Key (the great pantry door) | Doggy Bag |
| The Verdant Dump | Root Cause | Moss Mulligan, the Corrupted Druid (the thorn wall) | Dumpster Diving Gloves |

## Economy (docs/design/progression.md, docs/design/packs.md)
- Path Packs per zone: the main line pays 2 (gatekeeper, dungeon); one favour per zone pays 1 (was 2: `dna_audit`, `gain_spot_me`, `buf_mend`,
  `heap_dam` keep theirs; `dna_backlog`, `gain_lanes`, `buf_pantry`, `heap_fert` lost theirs); the minigame's first win pays 1; the dungeon's first
  clear still pays its own Path + Gilded Pack. Net: one more Path Pack per zone than before (4 in all), which keeps pack income close to the old curve.
- Gold from the main lines: 4 x (40 + 200) + 300 = 1,260 over the whole story (the retired Clear the Paths paid 150; Free the Kingdom kept 300).
- Equipment: four midpoint pieces from the main lines plus the side-quest pieces listed in docs/design/equipment.md.

## Old saves (`QuestMigration`, tested in `tests/core/quests/test_quests.gd`)
- "Clear the Paths" (retired) leaves the active list. A zone with its rift station unlocked (or freed) counts as entered.
- The new MAIN lines start at once; steps an old save had already done are **settled, not paid** (no retroactive packs or gear, so nobody double-dips),
  and a line that is entirely done is filed as completed with no reward box.

## Reward table
| Quest | Category | Giver | Steps (target; step reward) | Completion reward |
|---|---|---|---|---|
| Meet the Merchants (`meet_the_merchants`) | SIDE | auto | 1. Talk to Sable (cards) (town / vendor)<br>2. Talk to Tilly Tonic (items) (town / item_vendor)<br>3. Talk to Bertram Beetsworth (equipment) (town / equipment_vendor) | Participation Trophy, 50 gold, 40 XP |
| Raise the Bar (`main_beefcake`) | MAIN | auto | 1. Out-muscle Brick Bronson at the gorge (town / npc_beefcake) **pays: Beefcake Pack, 40 gold**<br>2. Cross the bridge into the Gainlands (town / portal_beefcake)<br>3. Spot the locals: finish a favour in the Gainlands (beefcake / gus) **pays: Gotta-Go Galoshes**<br>4. Storm the House of Gains and free Grandmaster Flex (beefcake / main_dungeon) | Beefcake Pack, 200 gold, 150 XP |
| Take a Number (`main_necrocrat`) | MAIN | auto | 1. Out-file Prudence Pallor at the checkpoint (town / npc_necrocrat) **pays: Necrocrat Pack, 40 gold**<br>2. Pass the checkpoint into the D.N.A. (town / portal_necrocrat)<br>3. Help the staff: finish a favour in the D.N.A. (necrocrat / dolores) **pays: Red Tape Dispenser**<br>4. Get final approval in the Hall of Final Approvals (necrocrat / main_dungeon) | Necrocrat Pack, 200 gold, 150 XP |
| Key Ingredients (`main_gourmand`) | MAIN | auto | 1. Win the pantry key from Chef Fennel Gravois (town / npc_gourmand) **pays: Gourmand Pack, 40 gold**<br>2. Step through the pantry door into the Endless Buffet (town / portal_gourmand)<br>3. Help the kitchen: finish a favour in the Endless Buffet (gourmand / odalys) **pays: Doggy Bag**<br>4. Shut down the Test Kitchen and expose the Doppelganger (gourmand / main_dungeon) | Gourmand Pack, 200 gold, 150 XP |
| Root Cause (`main_refusemancer`) | MAIN | auto | 1. Uproot Moss Mulligan at the thorn wall (town / npc_refusemancer) **pays: Refusemancer Pack, 40 gold**<br>2. Walk the forest path into the Verdant Dump (town / portal_refusemancer)<br>3. Lend a hand: finish a favour in the Verdant Dump (refusemancer / wren) **pays: Dumpster Diving Gloves**<br>4. Descend into the Rotheart and free Archdruid Compostella (refusemancer / main_dungeon) | Refusemancer Pack, 200 gold, 150 XP |
| Free the Four Zones (`free_the_kingdom`) | MAIN | Gatekeeper Brannoch | 1. Free The Gainlands (beefcake / main_dungeon)<br>2. Free The D.N.A. (necrocrat / main_dungeon)<br>3. Free The Endless Buffet (gourmand / main_dungeon)<br>4. Free The Verdant Dump (refusemancer / main_dungeon)<br>5. Storm Primm's castle (final / castle_door) | 300 gold, 250 XP |
| Fragments (`fragments`) | MAIN | auto | 1. Recover fragment 1: Warmth (town / elder)<br>2. Recover fragment 2: The Cells (town / elder)<br>3. Recover fragment 3: The Coup (town / elder)<br>4. Recover fragment 4: A Name (town / elder) | 200 gold, 150 XP |
| The Door Under the Well (`side_s_town`) | SIDE | Elder Maren | 1. Find a hidden chest in town | 40 gold, 30 XP |
| Clear the Backlog (`dna_backlog`) | SIDE | Agnes Overdue | 1. Defeat roaming staff | Healing Draught, 60 gold, 60 XP |
| Mandatory Onboarding (`dna_onboarding`) | SIDE | Gerald | 1. Punch in at the time clock (necrocrat / time_clock)<br>2. Pour a cup at the coffee machine (necrocrat / coffee) | Healing Salve, 40 gold, 30 XP |
| Compliance Audit (`dna_audit`) | SIDE | Clerk Ledgerbone | 1. Take the Compliance quiz (necrocrat / quiz)<br>2. Find a hidden stash | Necrocrat Pack, Compliance Clipboard, The Breakroom, 80 gold, 70 XP |
| The Oldest Trick in the Book (`oldest_trick`) | SIDE | event | 1. Open the giant chests<br>2. Face the Master of the Oldest Trick |  |
| Number 4,000,212 (`side_s_necro`) | SIDE | Gerald | 1. Defeat roaming staff | 40 gold, 30 XP |
| The Four Seals (`four_seals`) | SIDE | event | 1. Find the hidden levers<br>2. Open the vault and defeat its Warden (town / vault4) |  |
| Juice the Station (`gain_power`) | SIDE | Foreman Gus | 1. Run the Colossal Hamster Wheel (beefcake / run_wheel)<br>2. Buy a protein shake (beefcake / protein_stand) | Kettlebell Locket, Healing Salve, 50 gold, 40 XP |
| Spot Me! (`gain_spot_me`) | SIDE | Old Man Mountain | 1. Spot Gary (beefcake / spot_me)<br>2. Flex at a Flex Mirror (beefcake / flex_mirror) | Beefcake Pack, Pre-Workout Canister, 70 gold, 60 XP |
| Water for the Hermit (`side_s_beef`) | SIDE | Old Man Mountain | 1. Buy a protein shake (beefcake / protein_stand) | 40 gold, 30 XP |
| Clear the Lanes (`gain_lanes`) | SIDE | Coach Brutus Benchley | 1. Defeat roaming Gainlands enemies | Spotter's Barbell, Leg Day Survivor, 80 gold, 70 XP |
| Who Ate the Compost? (`side_s_ref`) | SIDE | Brother Bramble | 1. Defeat scavengers | 40 gold, 30 XP |
| Pantry Run (`buf_pantry`) | SIDE | Sous-Chef Tarragon | 1. Gather ingredients around the zone | Stock The Pantry, 60 gold, 50 XP |
| Bake Me a Pie (`buf_pie`) | SIDE | Madame Mirepoix | 1. Bake a Hearty Pot Pie in the Grand Oven (gourmand / oven) | Head Chef's Toque, Sous Chef, 70 gold, 60 XP |
| Mend the Meatloaf (`buf_mend`) | SIDE | Basil | 1. Repair Old Meatloaf (gourmand / old_meatloaf) | Gourmand Pack, Food Fight, 80 gold, 70 XP |
| The Golden Reservation (`side_s_gour`) | SIDE | Basil | 1. Find a hidden stash | 40 gold, 30 XP |
| The Older Way (`side_s_cap`) | SIDE | Kestrel | 1. Reach the resistance hideout (final / wren) | 40 gold, 30 XP |
| Round Up the Herd (`heap_herd`) | SIDE | Wren Muckfoot | 1. Shoo escaped animals back to the pen | Rubbish Goat, 60 gold, 50 XP |
| Fertilizer Run (`heap_fert`) | SIDE | Granny Gristle | 1. Gather sacks of fertilizer | Manure Miracle, 70 gold, 60 XP |
| Unblock the Stream (`heap_dam`) | SIDE | Brother Bramble | 1. Smash the junk dam on a charging mount (refusemancer / stable_1) | Refusemancer Pack, Compost Boots, 80 gold, 70 XP |
| Form 27-B/6: A Burial Permit (`cap_burial`) | SIDE | Widow Pell | 1. Find the Stamp of Final Approval (final / permit_window)<br>2. Lay Mr. Pell to rest (final / pell_plot) | Clerk's Stamp, Lich of Accounts Payable, Healing Draught, 150 gold, 120 XP, Insight into Primm |
| The Wheel Never Stops (`cap_wheels`) | SIDE | Rollo Spokes | 1. Free the wheel crews<br>2. Cut the facade's power cable (final / cable) | Iron Knuckles, Barbell of the Ancients, Vitality Charm, 150 gold, 120 XP, Insight into Primm |
| The Recipe Box (`cap_recipes`) | SIDE | Chef Marlo | 1. Find the hidden recipe cards<br>2. Spoil the Perfect Nutrient Paste dispenser (final / dispenser) | Pantry Apron, Recipe for wonder, Hearty Pot Pie, 150 gold, 120 XP, Insight into Primm |
| Untidy (`cap_untidy`) | SIDE | Old Fern | 1. Rescue the banished compost heaps<br>2. Plant the old seed in the Sick Patch (final / sick_patch) | Bin Lid Helm, The Mother Heap, Healing Salve, 150 gold, 120 XP, Insight into Primm |
