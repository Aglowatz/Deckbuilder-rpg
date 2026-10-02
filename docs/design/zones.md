# Zones and the D.N.A.

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
