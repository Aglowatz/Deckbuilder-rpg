# Equipment (Oct 16: 25 new pieces)

Source of truth: `core/data/expansion_gear.gd` (pieces, `SOURCES`, `DUNGEON_GEAR`, `zone_vendor_stock`), `core/data/chest_loot.gd` (chest rolls),
`core/quests/*_definitions.gd` (quest rewards). The game loads the generated `data/equipment/zone/*.tres`: after editing a piece run
`Godot --headless --path . -s res://tools/generate_content.gd`. Regenerate the table below with `Godot --headless --path . res://tools/equipment_table.tscn`.
Older pieces (the town vendor's ten, the zone pieces, the arena, vault and Lab gear) are unchanged; none of the new names or effects duplicates them
(the starting-resource pieces Iron Knuckles, Pantry Apron, Bin Lid and Clerk's Stamp exist, so the new resource pieces *generate* resources instead;
Hover Boots already grants Flying to every unit, so the Paper-Plane Cape grants it to Necrocrat units only; Traveler's Boots is the first-turn draw, so
the weak boots are Flip-Flops of Fortitude).

Effects all run through the Modifier pipeline. Two new Modifier kinds work outside battle: `OVERWORLD_SPEED_PERCENT` (read by `TownPlayer.gear_speed`)
and `XP_BONUS_PERCENT` (read by `Session.add_xp`). Balance is not tuned: functionality first.

## Where they come from
| Source | Pieces |
|---|---|
| Main dungeons, first clear | House of Gains: Glass Jaw Gauntlets; Hall of Final Approvals: Overdue Library Book; Test Kitchen: Elastic Waistband of Victory; Rotheart: Trash Panda Tiara |
| Side (mini) dungeons, first clear | Door Under the Well (town): A Very Pointy Stick; Sub-Basement 3: Paper-Plane Cape; Walk-In Freezer: Velvet Rope; Landfill Depths: Mystery-Stain Bib; Old Service Tunnels: Crown of Mild Hubris; Mount Swolympus (postgame): Side-Hustle Headband |
| Main quest midpoints | Raise the Bar: Gotta-Go Galoshes (the movement piece, early-mid game); Take a Number: Red Tape Dispenser; Key Ingredients: Doggy Bag; Root Cause: Dumpster Diving Gloves |
| Side quests | Meet the Merchants: Participation Trophy; Juice the Station: Kettlebell Locket |
| Vendors (prices from `Economy.gear_price`, Oct 29: Common 60 / 90, Uncommon 120 / 180 / 240, Epic 450 by tier) | Crosspath (Bertram): Cardboard Cuirass 60, Saucepan Helmet 60. Gainlands (Benchley, "Gear" button): Flip-Flops 90, Protein Shaker Bandolier 180 (once freed). D.N.A. (Ledgerbone): Dog-Eared Bookmark 180, Notarized Seal 180 (once freed). Buffet (Mirepoix): Saucepan Helmet 60, Dog-Eared Bookmark 180, Grandma's Rolling Pin 450 (once freed). Dump (Gristle): Flip-Flops 90, Sucker Punch Mitts 450 (once freed) |
| Chests (rolled) | Hidden chests in town and every zone, and dungeon treasure nodes, roll a piece (tier 1: 20 %, 2: 25 %, 3: 30 %) from Lucky Sock, Saucepan Helmet, Cardboard Cuirass, Flip-Flops (tier 1), Dog-Eared Bookmark, Sucker Punch Mitts (tier 2-3) - never one already owned, never over a fixed reward - else maybe a pack (the zone's Path Pack, a General Pack elsewhere). Lucky Sock is only found this way. |

Chest tiers: town, forest, Gainlands, D.N.A. 1; Buffet, Dump 2; the Capital 3. Dungeon treasure: side dungeons 1, main dungeons 2, the castle and the Lab 3.

## The 25 pieces
| Piece | Slot | Rarity / tier | Effect | Drawback | Flavor | Source |
|---|---|---|---|---|---|---|
| Lucky Sock (`lucky_sock`) | Relic | Common / 1 | Start every duel with 2 extra HP. | - | Unwashed since the tutorial. That's what makes it lucky. | Hidden chests (tier 1) |
| Cardboard Cuirass (`cardboard_cuirass`) | Armor | Common / 1 | Max HP +2. | - | Box-fresh armour. Literally. Do not get it wet. | Bertram's equipment stall, Crosspath |
| A Very Pointy Stick (`pointy_stick`) | Weapon | Common / 1 | When a duel starts, deal 1 damage to the opponent. | - | Found on the ground. Sharpened on a rock. Named with love. | The Door Under the Well (first clear) |
| Saucepan Helmet (`saucepan_helmet`) | Helm | Common / 1 | Max HP +1, and start every duel with 1 extra HP. | - | Handle in the back, for steering. Smells faintly of soup. | Bertram's equipment stall, Crosspath |
| Flip-Flops of Fortitude (`flip_flops`) | Boots | Common / 1 | Whenever one of your units dies, gain 1 HP. | - | Thwap. Thwap. Thwap. The sound of a hero who has given up on socks. | Benchley's Protein & Pasteboard (the Gainlands); the Compost Grange (the Dump) |
| Kettlebell Locket (`kettlebell_locket`) | Relic | Uncommon / 2 | Whenever you declare attackers, create 1 Iron. | - | Every rep counts. Mostly toward a sore neck. | Quest: Juice the Station (Foreman Gus) |
| Red Tape Dispenser (`red_tape_dispenser`) | Relic | Uncommon / 2 | At the start of your turn, create 1 Red Tape. | - | Pull here. Then fill out a form explaining why you pulled. | Main quest Take a Number (midpoint) |
| Doggy Bag (`doggy_bag`) | Armor | Uncommon / 2 | At the end of your turn, create 1 Ingredient. | - | Leftovers are just tomorrow's lunch with better self-esteem. | Main quest Key Ingredients (midpoint) |
| Dumpster Diving Gloves (`dumpster_gloves`) | Weapon | Uncommon / 2 | Whenever one of your units dies, create 2 Garbage. | - | One person's trash is another person's starting hand. | Main quest Root Cause (midpoint) |
| Glass Jaw Gauntlets (`glass_jaw_gauntlets`) | Weapon | Epic / 3 | Your units get +2 attack. | Max HP -3. | Hits like a truck. Takes a punch like a soufflé. | The House of Gains (first clear) |
| Overdue Library Book (`overdue_library_book`) | Relic | Epic / 3 | Draw 2 extra cards each turn. | Then discard a random card at the start of your turn. | Due back in 1987. The fines are now sentient. | The Hall of Final Approvals (first clear) |
| Elastic Waistband of Victory (`elastic_waistband`) | Armor | Epic / 3 | Your units get +1/+1. | You can play only 2 non-infrastructure cards per turn. | Built for the Endless Buffet. Stretches to fit any ambition. | The Test Kitchen (first clear) |
| Crown of Mild Hubris (`hubris_crown`) | Helm | Legendary / 3 | You always go first, draw an extra card on your first turn, and your units get +1 attack. | Max HP -4. | Heavy is the head that wears the crown. Mostly because it's very heavy. | The Old Service Tunnels (first clear) |
| Protein Shaker Bandolier (`protein_bandolier`) | Armor | Uncommon / 2 | Your Beefcake units get +1/+1. | - | Six shakers, one for every meal, and a seventh for emotional support. | Benchley's Protein & Pasteboard, once the Gainlands are free |
| Notarized Seal of Unlife (`notary_seal`) | Relic | Uncommon / 2 | Your Necrocrat units get +0/+2. | - | Signed, sealed, deceased. Valid in all known afterlives. | Clerk Ledgerbone's Requisitions, once the D.N.A. is free |
| Grandma's Rolling Pin (`rolling_pin`) | Weapon | Epic / 2 | Your Gourmand cards cost 1 less generic energy. | - | Rolls dough, flattens arguments. Grandma never lost either. | Mirepoix's Dessert & Deckery, once the Buffet is free |
| Trash Panda Tiara (`raccoon_crown`) | Helm | Uncommon / 2 | Your Refusemancer units get +1/+1. | - | Worn by the true monarch of the bins. All hail. All scavenge. | The Rotheart (first clear) |
| Side-Hustle Headband (`hustle_headband`) | Helm | Uncommon / 2 | Your Beefcake units have Hustle. | - | For when one grind just isn't enough grind. | Mount Swolympus (first clear, postgame) |
| Paper-Plane Cape (`paper_plane_cape`) | Armor | Uncommon / 2 | Your Necrocrat units have Flying. | - | Folded from a rejected appeal. It flies better than it was ever filed. | Sub-Basement 3 (first clear) |
| Mystery-Stain Bib (`mystery_stain_bib`) | Armor | Uncommon / 2 | Your Refusemancer units have Toxic. | - | Nobody knows what the stain is. Nobody wants to. It is load-bearing now. | The Landfill Depths (first clear) |
| Velvet Rope (`velvet_rope`) | Relic | Uncommon / 2 | Your Gourmand units get +0/+3. | They have Wallflower (they cannot attack). | Sorry, the kitchen is reservation-only. You are not on the list. | The Walk-In Freezer (first clear) |
| Sucker Punch Mitts (`sucker_punch_mitts`) | Weapon | Uncommon / 2 | Your units have Sucker Punch (they deal combat damage first). | Max HP -3. | Rule one of the fight club: hit first, apologise never. | Granny Gristle's Compost Grange, once the Dump is free; hidden chests (tier 2) |
| Dog-Eared Bookmark (`dog_eared_bookmark`) | Relic | Uncommon / 2 | When a duel starts, draw 2 cards. | - | Saves your place. And sometimes your life. | Mirepoix's Dessert & Deckery; hidden chests (tier 2) |
| Participation Trophy (`participation_trophy`) | Relic | Common / 1 | Gain 25% more XP from everything. | - | You showed up. That's basically winning. The trophy agrees. | Quest: Meet the Merchants |
| Gotta-Go Galoshes (`gotta_go_galoshes`) | Boots | Common / 2 | You walk 35% faster in the overworld. | - | For when you absolutely, positively have to be somewhere else. Now. | Main quest Raise the Bar (midpoint) |

## Overnight Oct 29, Part 3: the power budget

Every piece and item was reviewed against a power budget by rarity and tier (`docs/design/equipment_budget_oct29.md`: the points per effect, the
budget, the verdict for every piece, the slot progression per zone). Changes: the Wicked Dagger and the Solid Plate buff Colorless units only
(a board-wide +1 is never sold at level 5); the **Blade of Earned Reputation** (Epic, Bertram's advanced rack, 450) carries the any-colour
+1 attack; the Spotter's Barbell and the Gainsmith's Lifting Belt are Beefcake-only (the Belt Uncommon); the Glass Jaw Gauntlets' cost is
max HP; the Sucker Punch Mitts are an Uncommon with a max-HP cost; the Galoshes are Common, the Laurels Uncommon, the Gladiator's Net Epic;
the four lieutenants' relics, the Crown of Mild Hubris, the Four-Seal Signet, Siphon's Lens and the Phial of First Water were brought up to
their rarity's worth; the Reckless Tonic heals 5. Prices: `docs/design/economy.md`.
