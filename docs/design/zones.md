# Zones and the D.N.A.

## Story (brief 9)

The whole world's story, factions and rulers are in `docs/design/story_bible.md` (source of truth: `docs/design/story_source.md`). In short: ten years ago Primm ("His Perfection") took over or corrupted all four Paths; every zone lives under an oppressive ruler and the player frees each one by beating the boss of its final dungeon (zone completion, `ZoneCompletion`).

| Zone | Faction | Ruler / corruption | Final dungeon |
|---|---|---|---|
| The Gainlands | Beefcakes | Commander Gristle's regime; true leader Heartlift imprisoned in the Iron-less Prison | The House of Gains |
| The Endless Buffet | Gourmands | A doppelgänger (the False Aurelio), corrupted food (the Special Sauce), a hidden war-machine R&D complex | The Test Kitchen |
| The D.N.A. | Necrocrats | Legally valid paperwork ("Yes, but the authorization is valid"), absurd bureaucracy | The Hall of Final Approvals |
| The Verdant Dump | Refusemancers | The leader corrupted through nature itself; the ecosystem is unnaturally alive | The Rotheart |

Every zone's story file (`data/story/<zone>_story.tres`) has an oppressed text and, for the key signs, hub NPCs and objectives, a `<key>.freed` variant that `ZoneStoryText.get_lines` uses once the zone is completed.


Source of truth for zone rules. Code: `core/zone/`, `world/dna/`. Text: `core/data/zone_story_text.gd`.

## Zone life rules (every zone)
- Entering a zone from town starts a **ZoneRun** at full life (`core/zone/zone_run.gd`).
- Life **persists** between battles and enemy hits for the whole visit. A battle starts at current zone life and the life left afterwards is kept. **No healing after battles.**
- You heal only: at the hub's healing spot, with items/cards (consumable healing items work from the Character screen in the zone), or by returning to town (a new visit is full life).
- At **0 life** you wake at the hub at full life and pay a **paperwork fee** (`ZoneRun.PAPERWORK_FEE` = 15 gold, never more than you have). Every fee is logged to `Session.zone_log` (saved) and shown on screen.
- Defeated roaming enemies stay gone until the zone is re-entered.
- The mini dungeon follows the same life (see Part E in progress.md).

## The D.N.A. (Department of Necrotic Affairs)
The Necrocrat zone (`ZonePortals` id `necrocrat`, town gate at the southwest corner). The Necrocrats run Afterlife Services and Labor.
- ~3x the town's area (measured in `tests/core/zone/test_dna_layout.gd`), 1 m cells, ASCII-free: rooms are rectangles in `world/dna/dna_layout.gd`.
- Hub (safe, no enemies): **Lobby** (Dolores, Pip's Requisitions vendor, elevator to town) + **Breakroom** (healing couch, coffee machine, time clock, suggestion box, Barnaby).
- Cubicle Farm A/B (roaming enemies, haunted printer, quiz master), Mail Room (pneumatic-tube puzzle), Filing Department maze (Skylar's Rec Room, stashes), Elevator Bank (mini dungeon elevator), Records Basement (coffins, vault), Executive Floor (locked main dungeon door "Under renovation, please hold").
- Performance: chunked merged floors, MultiMesh-batched props/walls, chunks hidden beyond 30 m, pooled lights (8) hopping between fixtures.

## Hub NPCs and quests
| NPC | Quest (id) | Objective | Reward |
|-----|-----------|-----------|--------|
| Dolores | Clear the Backlog (`dna_backlog`) | defeat 3 roaming staff | 60g, 60xp, Healing Draught |
| Barnaby | Mandatory Onboarding (`dna_onboarding`) | punch in + pour a coffee | 40g, 30xp, Healing Salve |
| Pip | Compliance Audit (`dna_audit`) | take the quiz + find a stash | 80g, 70xp, File for Death Benefits |
Each is offered by and handed in to the same NPC.

## The shared zone framework (brief 6, Part B)
A zone is mostly **data + layout**; everything reusable lives in the framework. D.N.A. behaviour is unchanged (verified by `tools/run_fifth_brief_final_smoke.sh`).

| Piece | Where | Zone-specific part |
|-------|-------|--------------------|
| `ZoneDef` (+ `ZoneDefs` registry) | `core/zone/zone_def.gd`, `zone_defs.gd` | `DnaZone.build_def()`, `GainlandsZone.build_def()`: ids, flags, hub NPCs, interact spots, vendor stock, chest rewards, mini dungeon battles, which puzzle/minigame, fee, music, story file, minimap POI kinds |
| `ZoneRun` (life rules, 0-life respawn, fee from the def) | `core/zone/zone_run.gd` | - |
| `ZoneEnemyInfo` / `ZoneEnemies` (roaming enemy kinds: `BATTLE` slow battle-starters, `DAMAGE` fast damage-dealers) | `core/zone/zone_enemy_info.gd`, `zone_enemies.gd` | `DnaEnemies`, `GainlandsEnemies` (stats, deck recipes, model, accessories) |
| `MiniDungeon` (3 battles, one-time unique card) | `core/zone/mini_dungeon.gd` | the def's `mini` battles |
| `QuizRules`, `MatchGame`/`RepGame` rewards | `core/zone/` | questions/rewards in the zone's story file |
| `ZoneMap` (anchors, walkability, line of sight, chests, enemy spawns, area names, ground height, minimap extent) | `world/zone/zone_map.gd` | `DnaBuilder`, `GainlandsBuilder` |
| `ZoneScene` (hub, spots, quest NPCs, vendor, heal spot, exit, mini dungeon prompt, main dungeon placeholder, puzzle/quiz/minigame launchers, chests, enemies, damage/faint/wake, HUD, overlays, minimap) | `world/zone/zone_scene.gd` | subclasses `DnaScene`, `GainlandsScene` override hooks (`_build_environment`, `_interact_zone`, `_make_puzzle_screen`, `_make_minigame_screen`, `_extra_pois`, ...) |
| `ZoneEnemy` (patrol/chase/return AI) | `world/zone/zone_enemy.gd` | look comes from `ZoneEnemyInfo` |
| Story text | `core/data/zone_story_text.gd` + `data/story/<zone>_story.tres` | all dialogue/signs/quiz text; the Gainlands' lives in its `.tres` |

Adding a zone = a `ZoneDef` + a `ZoneMap` + a story `.tres` + a thin `ZoneScene` subclass, then register it in `ZoneDefs`.

## The Gainlands (brief 6, Part D)
The Beefcake zone (`ZonePortals` id `beefcake`, reached from the town's **Beefcake Path**, still unlocked by defeating Torvin the Over-Pumped). The Beefcakes are huge, muscular people responsible for **energy** (pushing mills, running giant hamster wheels) and **transportation** (throwing people across distances, physically ripping open portals). Code: `core/zone/gainlands_*.gd`, `world/gainlands/`, `ui/zone/wheel_puzzle_screen.gd`, `rep_game_screen.gd`. All text: `data/story/gainlands_story.tres`.

- **Map** (`GainlandsLayout`, pure data): a rolling main land (wobbly ellipse ~4,700 m2, a bit bigger than the D.N.A.'s floor) with giant windmills (KayKit windmill at 3x, sails spinning), colossal hamster wheels, outdoor gym equipment built from boulders and logs, copper energy pipes with travelling pulses, a stage, signs and posters; plus **4 floating islands** (Pec Perch, Delt Deck, Glute Garden, Calf Cove) hovering high above a sea of clouds, outside the main land's footprint. Sunny bright lighting (`GainlandsLook`), wind-blown leaves, music track `gainlands` with wind and birds.
- **Hub: The Swole Station** (south): Cooldown Hot Tub (heal), Tiny Tony's Protein & Pasteboard (10 placeholder advanced Beefcake cards, `ZoneCards.GAINLANDS_VENDOR_IDS`), Coach Brenda, Foreman Gus, Tiny Tony, the Beefcake Path arch, a protein shake stand and a flex mirror.
- **Zone life**: same rules as every zone (no healing after battles; heal at the hub tub / items / cards / town; 0 life = wake at the hub, **20 gold "protein tab"**, logged).
- **Quests** (hub NPCs): *Juice the Station* (Gus: run the wheel + buy a shake), *Spot Me!* (Brenda: spot Gary + flex; unlocks Calf Cove), *Clear the Lanes* (Tony: beat 3 roaming enemies).
- **Enemies** (`GainlandsEnemies`): Flexing Brute and Protein Shake Golem (slow, start Beefcake-deck battles), Sprinting Energy Sprite (fast, 2 damage with knockback + invulnerability window, never starts a battle).
- **Travel network** (`GainlandsTravel`): *throwers* hurl you in an arc (grab, wind-up, tumble, camera pulls out and follows, landing dust / impact ring / shake); *portal rippers* tear open a portal (ring + swirl + sparks + sound) that teleports you to the linked place. Locks: Delt Deck portal needs the wheel run (flag); Calf Cove portal needs the *Spot Me!* quest; Glute Garden throw needs 2 enemies beaten; the cross-country throw needs a Gym Rat card. Every island has an always-open way back. Calf Cove is only reachable from Pec Perch, Glute Garden only from Delt Deck.
- **Falling**: stepping past an island's rim = falling; respawn at the last safe spot, **1 damage** to zone life (`GainlandsZone.FALL_DAMAGE`), logged in `Session.zone_log`; at 0 life you wake at the hub.
- **Mini dungeon** "The Iron Cavern: Three Sets" (3 battles, no healing between, one-time unique card **The Iron Titan**), **puzzle** "Power Routing" (`WheelPuzzle`: 6 hamster wheels, 3 machines, exactly one of 729 settings works; reward one-time **Gainsmith's Lifting Belt**), **quiz master** Professor Quad (4 questions on Beefcake energy and transport, every answer on a sign), **minigame** "Rep Counter" by Jazzy Jules (a timing/rhythm lifting game, `RepGame`; rewards by stars, one-time first-clear bonus), **7 hidden chests** (docs/design/secrets.md), **interactables**: hamster wheel (powers the grid), protein shake stand (random buff/heal), flex mirrors (heal), "spot me" Gary (visit buff), **main dungeon placeholder** "Closed for Leg Day".

## The Endless Buffet (brief 7, Part B)
The Gourmand zone (`ZonePortals` id `gourmand`, reached from the town's **Path of the Gourmand**, still unlocked by defeating Maris the Over-Seasoned). The Gourmands are magical chefs who **feed the kingdom** and **protect it with food golems** they cook; golems answer every order with "Yes, Chef!". Code: `core/zone/buffet_*.gd`, `recipe_puzzle.gd`, `order_game.gd`, `world/buffet/`, `ui/zone/recipe_puzzle_screen.gd`, `order_game_screen.gd`. All text: `data/story/gourmand_story.tres`.

- **Map** (`BuffetLayout`, pure data): a rounded-rectangle table (~6,400 m2, a bit bigger than the D.N.A.) of rolling mashed-potato hills, a **Gravy River** (hot brown soup) cutting it in two, broccoli forest (Kenney Food Kit broccoli as trees), a candy field of lollipops with a pink/mint checkerboard, a salt flat, layer-cake buildings, pancake / cheese / butter **mesas**, giant cutlery as a picket fence and pillars, a bread-hollow gazebo, a soup fountain, steam vents. The table rim is a stack of cheese / frosting / sponge layers hanging over a giant gingham tablecloth. Warm saturated lighting (`BuffetLook`), drifting sprinkles, synthesized music track `buffet`. Dressing: **Kenney Food Kit** (food) and **KayKit Restaurant Bits** (kitchen).
- **Hub: The Grand Pantry** (south): a kitchen hall of counters/stoves, the Hearty Meal table (heal), Dolcetta's Dessert & Deckery (10 placeholder advanced Gourmand cards, `ZoneCards.BUFFET_VENDOR_IDS`), three chefs (**Head Chef Odalys**, **Sous-Chef Tarragon**, **Dolcetta Crumb**, all with toques), the Grand Oven, the Soup Fountain, a fortune-cookie dispenser, Old Meatloaf (a broken golem) and the arch back to the Path of the Gourmand.
- **Zone life**: same rules as every zone (no healing after battles; heal at the hub meal / items / cards / town; 0 life = wake at the hub, **20 gold "dish duty fee"**, logged).
- **Signature traversal** (all tested):
  - **Jelly bounce pads** (`BuffetLayout.Pad`): step on one and you are launched in an arc (camera pulls out and follows, tumble, squashy landing with crumbs) to a mesa top: Butter Butte (near the hub), Cheddar Overlook, Pancake Summit; each mesa has a pad on top that bounces you back down. Mesas have steep cliff walls you cannot walk up.
  - **Crouton rafts** (`BuffetLayout.Raft`): two ferries that wait at a bank, glide across the river and wait again (slower than the player). Step on, ride (you are carried), step off. **Falling into the soup** (stepping off a raft or the susan, or wading in) respawns you at the last safe spot for **1 zone life** (`BuffetZone.SOUP_DAMAGE`), logged in `Session.zone_log`.
  - **The Lazy Susan**: a giant serving platter in the middle of the river that turns slowly; riders are carried round its central pepper-mill pillar (`BuffetLayout.Susan`).
  - **Golem gate guardians** (`BuffetGates`): a fence of giant forks along the "Pass" with three gaps, each blocked by a golem and leading to its own district (isolated by dividers): **Brisket** (ingredient: hand over Saffron Threads, used up) -> Cheddar Cliffs; **Sir Loin** (quest: complete *Mend the Meatloaf*) -> Layer-Cake Town (the Walk-In Freezer); **Colonel Casserole** (defeat him in a card battle) -> Pancake Plateau (the stew pot puzzle). Gates stay open (flags `buf_gate_*_open`); the golem steps aside.
- **Quests** (hub chefs): *Pantry Run* (Tarragon: gather 3 ingredients scattered around the zone), *Bake Me a Pie* (Dolcetta: bake a Hearty Pot Pie in the Grand Oven and deliver it), *Mend the Meatloaf* (Odalys: repair the broken golem with sea salt + a truffle; unlocks Sir Loin's gate).
- **Ingredients**: 6 pickups (saffron, truffle, sea salt, basil, ghost pepper, honey), once per visit each, stock persists in the campaign (`buf_stock_<id>` counters). Honey is up on Butter Butte and the ghost pepper is across the river, so the pad and the rafts matter.
- **Enemies** (`BuffetEnemies`): Meatloaf Golem and Gelatin Sentinel (slow, start Gourmand-deck battles), Runaway Meatball (fast, 2 damage + knockback + invulnerability window, never starts a battle; the model rolls). Enemies never enter the soup or climb cliffs (`ZoneMap.is_enemy_walkable`).
- **Mini dungeon** "The Walk-In Freezer: Three Courses" (3 battles, no healing between, one-time unique card **Colossus of the Endless Buffet**), **puzzle** "The Mystery Stew" (`RecipePuzzle`: a logic puzzle - pick 4 of 6 ingredients in order from 7 clues, exactly one of 360 stews works, serving says only right/wrong; reward one-time **Head Chef's Ladle**), **quiz master** Lady Brioche (4 questions on the Gourmands, answers on signs), **minigame** "Order Up!" by Chef Turbo Tartine (an assembly/time-pressure game, `OrderGame`: stack the right ingredients in order for six tickets before each timer runs out; wrong ingredient tosses the plate; rewards by stars, one-time first-clear bonus), **8 hidden chests** (docs/design/secrets.md), **interactables**: Taste-Test Station (random good/bad effects), the Grand Oven (bakes a Hearty Pot Pie from honey + basil + ghost pepper), the Soup Fountain (3 ladles per visit), the Fortune Cookie Dispenser (hints about the secrets), Old Meatloaf (mend him), **main dungeon placeholder** "Kitchen Closed for Health Inspection".


## The Verdant Dump (brief 8, Part B)
The Refusemancer zone (`ZonePortals` id `refusemancer`, reached from the town's **Path of the Refusemancer**, still unlocked by defeating Old Thistlebark the Over-Composted). The Refusemancers are druids responsible for **waste removal and agriculture**: they summon animals that eat the kingdom's garbage and turn it into fertilizer, and use magic to help crops grow. Code: `core/zone/heap_*.gd`, `growth_grid.gd`, `sort_game.gd`, `core/data/heap_content.gd`, `world/heap/`, `ui/zone/growth_grid_screen.gd`, `sort_game_screen.gd`. All text: `data/story/refusemancer_story.tres`.

- **Map** (`HeapLayout`, pure data): a rounded-rectangle stretch of farmland and junkyard (~6,400 m2, like the Buffet): patchwork fields, an appliance-ring druid grove, a county-fair ground, scrap barns and windmills, overgrown rusted car wrecks used as planters, junk piles, two **junk mountains** (Mount Scrapmore, Rust Peak), a **recycling stream** across the middle, two **compost pits**, a **scree field** and a **wall of tyres** with three gaps. Golden-hour lighting (`HeapLook`), fireflies, synthesized `heap` music. Dressing: Kenney **Nature Kit**, **Survival Kit**, **Car Kit** and **Cube Pets** (animated animals) plus the Food Kit for the harvest table.
- **Hub: The Compost Grange** (south): Harvest Meal table (heal), Hob's Swap Shed (10 placeholder advanced Refusemancer cards, `ZoneCards.HEAP_VENDOR_IDS`), **Druid Marigold**, **Farmer Hob**, **Wren Muckfoot** (animal handler), the compost bin, a druid shrine, a feeding trough, a stable with **Boris the giant boar**, the arch back to the Path of the Refusemancer.
- **Zone life**: same rules (no healing after battles; heal at the hub / items / cards / town; 0 life = wake at the hub, **20 gold mucking-out fee**, logged).
- **Signature traversal** (all tested):
  - **Growing** (`HeapGrowth`): three **vine bridges** over the stream and two **beanstalk ladders** up the junk mountains. The centre bridge is grown by **Druid Sorrel** once *Round Up the Herd* is complete; the others by planting a **Magic Bean** at their sprout mound (three beans lie around the zone). Growing is animated (the vines/stalk grow segment by segment, you can cross as far as it has grown), permanent (a flag) and counted.
  - **Rideable animals**: mount a giant boar (hub stable) or goat (north-bank stable): **x1.8 speed**, crosses the **scree** (rough terrain that is impassable on foot) and **charges through junk barricades** (smash = flag + debris + shake). **Q** dismounts (not allowed on the scree); the animal trots home.
  - **Trash chutes**: step onto a chute's top (on each junk mountain) and you slide down a metal trough to the ground (camera pulls out and follows).
  - **Falling** into the stream or a compost pit (stepping off a bridge, or wading in) respawns you at the last safe spot for **1 zone life** (`HeapZone.HAZARD_DAMAGE`), logged in `Session.zone_log`.
- **Districts** north of the stream: Rust Peak yards (open gap in the tyre wall; Rust Peak beanstalk, Seed Shrine on top), the Landfill Depths (centre gap plugged by a **junk barricade** only a charging mount smashes), the scree fields and the scrap barn (east gap: scree, mount only).
- **Quests**: *Round Up the Herd* (Wren: shoo 3 escaped animals), *Fertilizer Run* (Hob: gather 3 sacks), *Unblock the Stream* (Marigold: smash the junk dam on a mount; rewards the **Compost Boots**).
- **Enemies** (`HeapEnemies`): Mossy Trash Golem and Possessed Scarecrow Druid (slow, start Refusemancer-deck battles), Junk Gull Flock (fast, 2 damage + knockback, flaps; never starts a battle). Enemies never enter the water/pits or climb cliffs.
- **Mini dungeon** "The Landfill Depths: Three Levels" (3 battles, one-time unique card **Mother of the Dump**), **puzzle** "The Seed Shrine" (`GrowthGrid`: a 5 x 5 garden where planting flips a plot and its neighbours; solvable, shortest solution checked by tests; reward one-time **Refusemancer Seed Satchel**), **quiz master** Elder Fennel (4 questions on the Refusemancers), **minigame** "Sort It Out!" by the original **Blue-Ribbon Bev Pettigrew** (a sorting game, `SortGame`: 20 junk pieces ride a conveyor, sort each to Compost / Metal / Glass / Paper before it falls off; streak scoring; rewards by stars, one-time first-clear bonus; nods to 90s environmental PSAs, county-fair blue ribbons and dumpster-diving), **8 hidden chests** (docs/design/secrets.md), **interactables**: compost bin (junk -> max-life buff), crop plots (plant with fertilizer, harvest later in the visit), druid shrine (blessing), animal trough (junk -> gold), escaped animals, **main dungeon placeholder** "Closed for Composting".

## Zone effects: buff and debuff (brief 9, Part C)

Every zone (and every dungeon inside it - the mini dungeon now, the final dungeons in Part E) has one **buff** for its own Path and one **debuff** for the rival Path. They are `Modifier`s in a `ZONE` `ModifierSource` (`ZoneEffects.source_for(zone_id)`) fed to **both** the player's and the enemy's modifier set, so they affect every card of that Path regardless of who plays it (`Session.make_zone_battle`, `Session.make_dungeon_battle` via `DungeonRun.start_encounter(enemy, zone_source)`). Rivalries: Beefcakes (chaotic, "there-ish, on-time-ish") vs Necrocrats (orderly, by the book); Gourmands (snooty, proper) vs Refusemancers ("garbage eaters"). Zone completion does not remove them.

| Zone | Buff | Debuff (rival) |
|---|---|---|
| Gainlands | **Pump It Up**: Beefcake creatures +1 power | **Processing Time**: Necrocrat creatures enter exhausted (new `Modifier.Kind.ENTER_EXHAUSTED`) |
| D.N.A. | **Approved Procedure**: Necrocrat creatures +1 toughness | **Unauthorized Activity**: Beefcake cards cost 1 more (`COST_CHANGE`) |
| Endless Buffet | **Well Fed**: Gourmand creatures +1/+1 | **Dress Code Violation**: Refusemancer creatures -1 power |
| Verdant Dump | **Overgrowth**: Refusemancer creatures +2 toughness | **Spoilage**: Gourmand creatures -1 toughness (a debuff never takes a creature below 1 toughness by itself) |

Names and flavor are in each zone's story file (`effect.buff.name`, `effect.debuff.flavor`, ...); the mechanical text is generated from the modifier. The active effects show in the zone HUD (left column, under the objective) and in battle (a panel under the enemy portrait), each with a tooltip. Tests: `tests/core/zone/test_zone_effects.gd`.

## Zone completion (brief 9, Part D)

A zone is **completed** (freed) when its final dungeon's boss is defeated. `Session.complete_zone(zone_id)` sets the saved flag `zone_<id>_completed` once, switches the zone's story to its freed text (`ZoneStoryText`'s `<key>.freed` variants), fires `EventBus.zone_completed(zone_id)` (the Arena and the Alchemist unlock from it) and saves. `Session.completed_zone_count()`, `arena_unlocked()` (>= 1 zone) and `alchemist_unlocked()` (>= 2 zones) read it (`ZoneCompletion`).

What changes in a freed zone (`ZoneScene._build_completion_state`):

| | Oppressed | Freed |
|---|---|---|
| Lighting (`ZoneCompletionLook`) | dimmer, desaturated, fog and sky pulled toward the ruler's gloom tint | brighter, warmer, clearer, fog lifts |
| The ruler (`RulerPresence`) | a looming statue with a plaque and tall banners in the ruler's colors at the hub | the statue lies toppled with a new plaque, bunting where the banners were |
| Signage | regime/permit/Special-Sauce/Rot signs | the same signs' `.freed` variants (rules abolished, notices revoked) |
| NPCs | frightened/guarded dialogue | `.freed` dialogue; the freed leader (Heartlift / Grand Chef Aurelio / Director Vellum / Archdruid Fernwick) stands at the hub and talks (`freed_npc.<id>`) |
| Announcement | - | a full-screen "THE X IS FREE!" screen with what just unlocked (`AnnouncementScreen`), then the zone |

The quest *Free the Kingdom* tracks the four completions. Tests: `tests/core/zone/test_zone_completion.gd`.

## The four final dungeons (brief 9, Part E)

Each zone's old "closed" placeholder is now a full dungeon on the shared node-map system (`DungeonMap`), entered from the zone's dungeon spot (`Session.enter_main_dungeon`, zone life rules: it starts at the zone's current life, nothing heals except at shrines, a loss wakes you at the hub and charges the fee, retreating returns you to the zone). **Beating the boss completes the zone** (`Session.resolve_main_dungeon` -> unique card, gold, XP, `complete_zone`, then the zone shows its freed state and the announcement). The zone's buff/debuff (Part C) applies to every duel in the dungeon, and it has its own map diorama (`DungeonBackdrop`).

New shared node kinds (appended to `DungeonMap.Kind`): **ELITE** (a harder battle with a card choice), **EVENT** (a story choice screen, `DungeonEvent`/`EventResolver`/`EventScreen`), **TREASURE** (`TreasureScreen`, `Session.apply_treasure`). Nodes also carry `section`, `story_before`/`story_after`, `scene`/`after_scene` (cutscenes, `CutsceneDefs`/`CutsceneScreen`). `DungeonMap` can report `branch_points()`, `rejoin_points()`, `route_count()` and `problems()`; tests assert every dungeon has real route choices that rejoin.

| Dungeon (zone) | Nodes | Branches | Highlights |
|---|---:|---|---|
| **The Test Kitchen** (Buffet) | 12 | 3 (rejoin at the canteen, the armory, the boss) | taste-panel deck challenge, canteen shrine, food construct and Mk. IX elites, cannon-bay and whistleblower events, armory treasure; boss **The False Aurelio** with the **reveal** cutscene (the face slides off the doppelganger). Reward: **Aurelio, the True Chef** |
| **The House of Gains** (Gainlands) | 13 | 2 | **The Iron-less Prison** section (descent event, cell block / calisthenics check, the Iron-less Warden elite), then **the rescue**: Heartlift, emaciated, joins as the dungeon-wide boon *Heartlift Fights Beside You* (+1/+1 to all your creatures, +3 max life), a cell stretch shrine, barracks / gear-locker choice, honor guard elite, trophy hall; boss **Commander Gristle** with the **flex** cutscene (he throws off his outer clothing: still incredibly muscular; "true strength comes from the heart and the mind"). Reward: **Heartlift, the Unbroken** |
| **The Hall of Final Approvals** (D.N.A.) | 14 | 3 | "take a number" wait event, **forms that require forms** (a 3-step chained event), waiting-room shrine, audit challenge, mailroom, lost-and-found treasure, compliance elite, appeals / notary choice, senior clerk elite; boss **The Registrar of Final Approvals** ("filed on a Tuesday"). Reward: **The Final Approval** |
| **The Rotheart** (Dump) | 13 | 3 | sections that grow stranger (outskirts, grove, root tunnels, heartwood), whispering-mushrooms and pulsing-wall events, spore-gauntlet challenge, clean-soil shrine, seed-vault treasure, golem / treant elites; boss **Archdruid Fernwick Loam** with the **sever** cutscene (cutting the heart severs the big bad's influence). Reward: **Heart of the Dump** |

Code: `core/dungeon/main_dungeon_def.gd` (+ `main_dungeons.gd`, `test_kitchen_dungeon.gd`, `house_of_gains_dungeon.gd`, `hall_of_approvals_dungeon.gd`, `rotheart_dungeon.gd`, `dungeon_event.gd`, `event_resolver.gd`, `cutscene_defs.gd`), UI `ui/dungeon/` (`event_screen.gd`, `treasure_screen.gd`, `cutscene_screen.gd`), `world/dungeon_backdrop.gd`. All titles, blurbs, dialogue, events and cutscene lines are in the zone story files (`dungeon.<node key>.*`, `event.<id>.*`, `challenge.<id>.*`, `cutscene.<id>.<n>`). Tests: `tests/core/dungeon/test_main_dungeons.gd`.


## The Capital (brief 10, Part A)

The final area (`ZonePortals` id `final`, zone id `final`, the town's last gate: **open from the start**, no zone needs to be free).
Story and names: `docs/design/story_bible.md` Part 10. Code: `core/zone/capital_*.gd`, `core/data/capital_content.gd`, `world/capital/`,
`ui/widgets/service_debuffs_panel.gd`. All text: `data/story/capital_story.tres`. Not one of the four Path zones: `ZoneDefs.ids()` are
the four (what `ZoneCompletion` counts), `ZoneDefs.all_ids()` adds the Capital.

- **Map** (`CapitalLayout`, pure data, 1 m grid `120 x 126`, ~8,500 m2 of walkable ground, more than any other zone): the **Outskirts** (south:
  the road from town, abandoned checkpoints, rifts, a hidden service-tunnel hatch), the **city wall** with the **Approved Gate** (a 10 m
  opening closed by a barrier until the gate battle is won), **Checkpoint Plaza**, then inside the walls **the Reek** (Refusemancers) and
  **Grave Row** (Necrocrats) in the west, **the Transit Yards** (Beefcakes) and **the Hungry Quarter** (Gourmands) in the east,
  **Primm's Perfection** (the facade town) in the middle behind its own low white wall, **the Castle Approach** (doors of Primm's Castle)
  and **the Correction Ward** and **Checkpoint Row** in the north. **The Crease** (the hideout hub) is a separate underground hall far to the
  south on its own visual layer (the sun does not light it), reached by ladder/hatch/shaft. Minimap + fog of war from the framework.
- **Entry** is strictly controlled: the **Approved Gate Captain** (`CapitalEnemies.GATE_CAPTAIN`, a deliberately hard Necrocrat/Gourmand
  deck, 24 life) gives absurd entry requirements in dialogue and the **Entry Examination** is a card battle (`Session.start_gate_battle`);
  winning sets `cap_gate_open` + `cap_inside` and the barrier lifts. Losing = wake outside the gate with the **Correction fee** (20 gold,
  logged). Exits are controlled too (flavor): the Exit Interview booth, exit-control guards and signs.
- **Secret entrance**: the **Old Joint Works** hatch in the south-west of the Outskirts (a `hidden` spot: no marker/plate/icon, an up-close
  prompt only) leads into the Crease and sneaks the player past the gate (`docs/design/secrets.md`).
- **Hub: the Crease** (safe, no enemies): Nurse Hesper's **Tea of Dissent** (heal), **Fig Sly's** black market (rare cards:
  `CapitalContent.BLACK_MARKET_CARD_IDS`, and a crate of supplies: `CapitalZone.BLACK_MARKET_ITEMS`), **Mabbit Quill** (the resistance's
  keeper of records; reacts to your collected insights), the **service-shaft network** (six shafts to the six streets; **down while the Beefcake
  service is broken**), a ladder up to the plaza manhole and the tunnel back to the Outskirts. You wake here at 0 life once you know it
  (`cap_hub_known`), otherwise outside the gate.
- **Primm's Perfection** (the facade): 16 identical houses (2 are painted storefronts), regulation lawns/hedges, a fountain with a golden
  statue, loudspeakers (rotating cheerful announcements), portraits and statues of Primm, decree signs ("Approved Hat Sizes: 1",
  "Spontaneity by Permit Only", "Smiling Is Mandatory"), 9 citizens in matching clothes with fixed smiles (each says an approved phrase
  and, the next times you talk, slips up with a hint of fear), painted doors that do not open (4 `door` spots).
- **Outside the facade**: cracked streets (crack decals), crumbling/leaning buildings, gray districts, dead street lamps, abandoned checkpoints,
  the Correction Ward, and **rifts**.
- **Rifts** (`CapitalRifts`, 9 of them): standing in one **damages you** (1, or 2 for the big ones, with knockback and the usual 1.6 s
  invulnerability), the world **wobbles** (camera shake) and a refractive lens warps the light around it (`rift_distortion.gdshader`);
  roaming enemies whose home is within 9 m of an unsealed rift are **empowered** (+3 life, +1/+1 on their creatures; they glow violet) and
  sealable rifts have a **Rift Wretch guardian**. **5 can be sealed** (beat the guardian this visit, then use the rift-stone) for a reward
  (gold + an item or card); the 4 big/unsealable ones stay until Primm falls. Sealing is saved (`cap_rift_<id>_sealed`).
- **Broken-service debuffs** (`CapitalDebuffs`, applied through the Modifier pipeline: `Session.begin_zone_visit` adds the player-side
  `ModifierSource` to the visit, `Session.make_zone_battle`/dungeon battles add the enemy-side one; three new `Modifier.Kind`s):

  | Zone not free | Debuff | In duels | In the world |
  |---|---|---|---|
  | Gainlands | Blackout | your creatures enter exhausted (`ENTER_EXHAUSTED`) | darkness, -20% speed, no shaft travel |
  | Endless Buffet | Famine | max life -5 (`MAX_LIFE`) | healing items do nothing (`Session.healing_blocked_for`) |
  | D.N.A. | Restless Dead | enemy creatures return from the graveyard 35% of the time (`GRAVEYARD_RETURN_CHANCE`, enemy side) | - |
  | Verdant Dump | Clutter | 3 Heaps of Rubbish shuffled into your deck (`SHUFFLE_JUNK_INTO_DECK`) | - |

  Each completed zone removes its debuff and the Capital shows it (lights return and the lamps light, stalls reopen with awnings/lanterns/
  steam, the graves become tidy, the heaps shrink and bloom). The HUD shows all four (`ServiceDebuffsPanel`, a row each with tooltip, red
  while broken, green "restored" when free). Tests: `tests/core/zone/test_capital.gd`.
- **Enemies** (`CapitalEnemies`, the shared framework): **Compliance Officer** and **Perfection Inspector** (slow, start battles), **Tidy-Bot**
  (fast, 2 damage + knockback, never starts a battle), **Rift Wretch** (slow, rift guardian) and **Shard Swarm** (fast, 2 damage).
- **9 hidden chests** (docs/design/secrets.md) and **interactables with real effects**: *deface propaganda* (6 portraits, +12 gold each, once),
  *seal a rift* (reward), the **Anonymous Complaint Box** (2 per visit; replies cycle: compensation gold, a heal, "noted", an Inspector
  who costs you 1 life), plus the objects of the four Path quests (wheels, cable, paste dispenser, recipe cards, compost heaps, seed, stamp,
  the Marrow plot, the Sick Patch).
- **The four Path quests** (`ZoneQuestDefinitions.capital_quests`, tracked in the quest log; each pays gold, XP, a card, an item and a
  **story insight** into Primm via `reward_unlock_flags`): *Form 27-B/6: A Burial Permit* (Tilda Marrow, Necrocrat), *The Wheel Never Stops*
  (Bram Haulsworth, Beefcake), *The Recipe Box* (Odile Bisque, Gourmand), *Untidy* (Gus Peelings, Refusemancer).
- **Zone life rules** as every zone; the fee is 20 gold ("Correction fee"). Famine lowers the visit's max life, so the Capital is hard
  until the Paths are free; this is by design (and balance is out of scope).
- **Dev/screenshot helpers**: `tools/shot.sh res://scenes/capital_zone.tscn <name> --at=<anchor> [--gate] [--hub] [--paths[=N]] [--freed]`.


## Primm's Castle (brief 10, Part C)

The Capital's main dungeon (`MainDungeons` id `final`, entered from the **Castle Approach** door `castle_door`; `Session.enter_main_dungeon`
starts it at the visit's current life, nothing heals except shrines, and the Capital's broken-service debuffs apply to every duel).
Code: `core/dungeon/primms_castle_dungeon.gd` (def + map), `primm_boss.gd`, `world/dungeon_backdrop.gd` (`castle`). All text: the Capital story
(`dungeon.pc_*`, `event.pc_*`, `challenge.pc_*`, `cutscene.primm_*`, `boss.*`, `boon.*`).

- **30 nodes**, heavy branching, **8 dead-end side branches that double back** (`DungeonMap.MapNode.return_to`: once a dead end is done the
  party returns to the branch point; `DungeonMap.problems()` accepts a dead end only when it hangs off an earlier node and has nothing after it),
  12 branch points, 8+ routes to the boss.
- **Sections**: the Great Hall (doors, a hall guard) -> **the Portrait Gallery** (the *Improved Portraits* event, the Curator, a forgotten alcove
  with a prize) -> **the Hall of Mirrors** (the Mirror Knight, a *mirror* deck challenge, **the One Honest Mirror** as a dead-end event, the Quiet
  Room shrine) -> **the Ministry of Correction** (the Desk of Correction challenge, a clerk, the **Chief Corrector** elite, **the Corrected**: the
  citizens he "corrected", a serious dead-end event) -> **the Hall of the Four Wings**: four dead-end wings, one per Path (the Doppelganger's lab
  notes, the coup orders, the notarized Form 1-A, the corrupted seed; each a battle with its document as the story) and two ways on (the servants'
  corridor, the grand staircase) -> the Wing Vault (treasure; the card *Correction*) -> **the Archive of Good Intentions** (the Archive Warden, the
  **Early Journals** event: his reforms that really did help, the Reading Room shrine, the Blueprint Vault dead end, the Escalation Shelf challenge,
  the Archive Automaton elite, and **the Last Journal**: the moment you see that he truly believes he is the hero) -> **the Scale Model Chamber**
  (the Model Warden elite and the boss).
- Node kinds used: battle, elite, deck challenge (3), event (7), shrine (2), treasure (3), start, boss. The map screen draws maps of more than 18
  nodes with smaller nodes (`DENSE_NODE_SCALE`) so rows and columns do not overlap.
- Reward for the first clear: the unique card **The Paths, United**, 500 gold, 400 XP; the Capital becomes "freed" (`zone_final_completed`).

## The final boss: Primm (brief 10, Part D)

`PrimmBoss`: an EXTREMELY challenging three-phase fight on the boss node (**balance is out of scope**: every number is a placeholder, nothing was
simulated). The phases are three duels back to back (`Session.boss_phase`), life carrying over, with a cutscene between them (`CutsceneDefs`:
`primm_intro` before, `primm_p1` and `primm_p2` between, `primm_end` after; played by the map screen; the duel's music is `primm`).

| Phase | Rule | How (Modifier pipeline) |
|---|---|---|
| 1. **Standardization** | every creature (yours and his) is a 3/3; you may cast at most two non-infrastructure cards a turn | `STANDARDIZE_CREATURES` (new) on his seat + `MAX_NON_INFRASTRUCTURE_CASTS_PER_TURN` 2 on yours |
| 2. **Reflection** | his deck is a copy of yours; he draws an extra card each turn | the enemy seat is built from your current deck; `EXTRA_DRAWS` |
| 3. **Unraveling** | his creatures get +1/+1 and he draws extra, but loses 1 life at the start of each of his turns | `STAT_CHANGE`, `EXTRA_DRAWS`, `START_OF_TURN_EFFECT` (lose life) |

The battle screen shows the phase's rule and the active broken services (`BattleHud.set_capital_panels`). **Freed leaders lend a boon**: for each
completed zone its freed leader (Heartlift, Aurelio, Director Vellum, Fernwick) joins you when the boss is entered (dialogue, then a dungeon-wide
boon: +2 max life and +1 power to Beefcakes / +1 toughness and bigger life gain to Gourmands / Necrocrat cards 1 cheaper / +2 toughness to
Refusemancers; once per run). Dialogue is comedic self-importance first ("it has just been polished by seventeen people"), then real tragedy:
he insists he did it all for the people, and the player's victory shows him (and the player) that his perfection was really about himself.

## The ending and the postgame (brief 10, Part E)

Defeating Primm (`Session.resolve_main_dungeon` -> kind `primm_defeated`) sets `postgame_unlocked` and `primm_defeated`, **frees the four Paths**
(his fall ends every ruler's authority; no zone rewards), and plays `EndingScreen` (`scenes/ending.tscn`, text `ending.*`): the model falls and the castle
crumbles, the facade falls, the rifts close, the Wrinkles come into the light, the four Paths meet, the theme in plain words (Primm demanded one
way for everyone; his fall frees the Paths to mix again; different Paths working together is what made the kingdom strong), a dove and the new
decree; then **placeholder credits**; then the postgame announcement **"The Paths Unbound"**: decks may now combine cards from **all Paths** (3 or 4
Path decks: `DeckValidator.max_colors` = 4, the deck builder reads it) and the **Alchemist's tri-Path crafting hook** opens (`Alchemy.tri_path_unlocked`;
still no tri/quad cards). Then the player returns to the world: the **changed Capital** (`CapitalBuilder.story_context().final`): the facade has crumbled
(houses ruined, statues toppled, painted shops fallen), every rift is sealed, the lights are on, the citizens are free and say new things (`.freed`
story variants), the four freed leaders stand in the Crease, the castle is open for a replay. Tests: `tests/core/dungeon/test_ending_postgame.gd`.
