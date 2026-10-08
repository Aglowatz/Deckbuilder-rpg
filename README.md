# Wellspring (working title)

A single-player deckbuilder RPG built in **Godot 4.7.2** (Forward+), GDScript only. The rules
engine lives in `core/` and is pure logic; the playable demo is a presentation layer on top of it.

## Playing the demo

1. Open the project in Godot 4.7.2 (or run it from the command line) and press **F5**.
   `res://scenes/title.tscn` is the main scene.
2. **Title screen**: New Game / Continue / Settings / Quit.
3. **The forest (the prologue)**: pick a hat and cloak, then the Wanderer wakes alone in a small forest
   clearing outside Crosspath with no memory of how they got there. A hooded **Rescuer** kneels
   beside them, asks if they can still fight and pull energy from the Paths, and asks which Path they
   walked the most: **this is where you choose your starting deck** (one of the four Paths, each shown
   with its identity, playstyle and key cards). The Rescuer then points to the cave and vanishes into the
   trees. Walk with **WASD** / arrow keys; **E**, **Space** or **left-click the object/person in range**
   all interact - watch for the on-screen "[E] ..." prompt. Walking into the treeline makes the Wanderer
   talk themselves back to the cave (all story text is in `data/story/intro_story.tres`).
4. **The Forgotten Cave**: the cave gate starts the tutorial dungeon with your 42-card starter deck
   (23 cards: colorless spells plus eight of your Path's own Resource cards, and 19 basic
   Infrastructure) - a node map with two battles, a deck challenge, a healing shrine (a full heal, right
   before the boss) and a boss, the Hollow Warden. The cave has no Beefcake or Necrocrat enemies or
   Resources. Life carries from node to node. The first battle is a guided tutorial. Losing sends you back
   to the forest to try again.
5. **Elder Maren at the cave mouth**: after the boss, the three reward picks grow your deck to 45 cards,
   and **Elder Maren** (a tortoise) is waiting outside. She takes you in, guarded and kind, and you
   arrive in Crosspath.
6. **Crosspath** (same controls: **WASD**/arrows to move, **E**/**Space**/click to interact, **Esc** for
   the pause menu, **B** to open the deck builder from anywhere, **C** for the character screen)
   is laid out as a real town: a central plaza with a fountain bearing the royal crest (the four Path
   symbols in a ring), a notice board (the quest log), West and East Market Streets (Sable's cards, Tilly
   Tonic's items, Bertram Beetsworth's equipment, Pip Threadwell's clothing, Foil Fenwick's packs, Auntie Alembic's
   alchemy, the Rift Express), the Gate Road north (Elder Maren's home, the Hall of Records, the Forgotten
   Cave) and Champions' Road south (the chapel, the Deck Station, the Wellspring) ending at the Grand
   Clashatorium, with signposts and lamps at every junction. Around it, in several districts:
   - **The original core**: **Elder Maren** and **Gatekeeper Brannoch** (story/advice), the
     **Wellspring** (now a flavor spot - it already recognizes your color), **Sable the Trader**
     (buy cards with gold - stock starts small and grows as you spend and explore, with locked
     cards shown as "???"), the **Deck Station** (a flavorful way to reach the deck builder - the
     **B** hotkey/HUD button open the exact same screen from anywhere in town), and the
     **dungeon gate** (north) to replay the Trial for gold.
   - **The Harbor Quarter** (east, across the canal bridge near the market): the **Hall of
     Records** (the Codex - every card in the game, cards you have not yet owned, bought or faced
     in battle show as a silhouette) and **Tilly Tonic's Supplies** (buy consumable items with gold, then
     equip up to your item-slot limit from the Character screen to carry them into a fight).
   - **The Secluded Grove** (south of the spawn point): three placeholder secrets - a hidden chest
     behind the trees, a sealed vault and the easy-to-miss lever that opens it, and a hidden vendor
     who only appears once you have found the chest.
   - **West Woods, Harbor Dock, North Uplands, Beefcake Flats and Grave Hollow**: 5 new outer
     districts, each with a corrupted NPC to find and fight (a mono-color deck, 15 life - defeat
     them for a one-time reward and to unlock that element's entrance) and a hidden chest tucked
     away with no marker of any kind - the standard interact prompt only shows up within about
     1.5m. Each district ends at an edge entrance to a zone (placeholder "coming soon" areas for
     now); the 4 element entrances stay sealed behind a translucent barrier until their corrupted
     NPC falls, the final entrance is open from the start.
   - **Zones**: the Necrocrat entrance leads into **The D.N.A.** (an office complex), the Beefcake Path into
     **The Gainlands** (a bright open land of mills, giant hamster wheels and outdoor boulder gyms, with
     floating islands you reach by being *thrown* by a Beefcake or through a *portal* one tears open by hand).
     The Gourmand entrance (the Path of the Gourmand) leads into **The Endless Buffet**, a whimsical land made of
     giant food: a gravy river crossed on crouton rafts and a rotating lazy susan, jelly bounce pads up to pancake
     and cheese mesas, and golem gate guardians that only let you pass for an ingredient, a quest or a card battle.
     The Refusemancer entrance (the Path of the Refusemancer) leads into **The Verdant Dump**, an overgrown junkyard-farm:
     druids grow vine bridges and beanstalks, you ride giant boars and goats through junk barricades and over scree,
     and trash chutes whoosh you down the junk mountains.
     Both share one zone framework: a hub, zone life (no healing after battles), roaming enemies, a mini
     dungeon, a puzzle, a quiz, a minigame, hidden chests and a locked main-dungeon door. Press **M** in any
     walkable area for the map; a minimap with fog of war (toggle in Settings) fills in as you explore.
7. **Battles**: click a card to play it (or drag it onto the table). Cards glow gold when playable. Targeted
   spells show an arrow: click the target, right-click to cancel. In combat click your creatures to attack,
   then press **Attack**; when blocking, click your blocker, then the attacker. Hover any card to zoom it and
   read its keywords. Equipped items show on a bar next to your portrait - click one to use it on your turn
   (targeting, if it needs one, works the same way spells do). **End Turn** fast-forwards to the opponent.

Everything is keyboard/mouse. Settings (volumes, fullscreen) are on the title screen and in the pause menu.
Saves live in `user://save.json` (Continue on the title screen); the game saves in town and after each
purchase, deck edit and dungeon result. Continuing a save from before the starting deck was chosen resumes
at the starting area, not town (gold/cards earned so far are kept).

### Story progression (story v2)

- **One Path at first**: the Wanderer is too weak to walk more than one Path, so a deck may use **one Path** until
  the first zone is freed, **two** after that, and **three or four** once Primm has fallen. Dual-Path cards wait
  for the second Path. Old saves keep decks that become illegal (they are marked "not legal yet" and the town
  tells you to fix them at the Deck Station).
- **Memory fragments**: each freed zone (the Nth, in any order) returns a fragment, played the next time you
  talk to **Elder Maren** (a dimmed screen with a four-colour vignette, then her answer). The first announces the
  second Path; the fourth reveals who the Wanderer is, after which people address them by name. The "Fragments"
  quest tracks them. If you rush the castle first, Primm tells you instead.
- **The finale and after**: the Pathwork Throne restores your memory and every Path; the Capital becomes
  **Pathordia**; Primm works under guard on infrastructure. Rip Tearson then opens a rift station in the forest
  where it all began, and a hatch there leads to the postgame **Path-ology Lab** (extremely hard; placeholder
  encounters and art).
- Names that may change (the prince, the royal house, the Rescuer, place names) live in
  `data/story/royal_family.tres` and are used by token (`{prince}`, `{town}`, `{capital}`, `{rescuer}`...).
- End-to-end checks with human-style input: `bash tools/run_prologue_smoke.sh` (forest to Crosspath) and
  `bash tools/run_story_v2_final_smoke.sh [--only=streets,deck,memory,hog,hall,reveal,ending,forest]` (Crosspath on foot,
  the deck rule, Maren's memory, the House of Gains, the Hall, the Primm reveal, the ending, Rip's portal and the Lab).


## Project layout

| Folder | Purpose |
|--------|---------|
| `core/` | The rules engine and campaign rules (no scene tree): game state, combat, effects, AI, simulation, dungeon map, deck rules, rewards. |
| `data/` | Card, deck, challenge and AI resources (`.tres`, generated from `core/data/content_definitions.gd`). |
| `app/` | Autoloads: `EventBus`, `Settings`, `Audio` (+ `MusicSynth`), `Session` (campaign state, saves), `SceneManager`. |
| `ui/` | Presentation: theme, cards, battle screen, town menus, dungeon screens, tutorial. |
| `world/` | 3D scenes: hex town builder, player, town scene, backdrops, lighting. |
| `scenes/` | The top-level `.tscn` scenes (title, starting area, town, battle, dungeon map, rewards). |
| `tests/` | GUT tests for `core/` (330+). |
| `tools/` | Screenshot tool, UI driver, smoke and end-to-end tests, dungeon balance simulator, asset/theme/content scripts. |
| `docs/` | `design/combat_rules.md` (rules source of truth), open questions, progress log, balance report. |

The rules never touch the scene tree: the battle screen animates the engine's event log and submits
`GameAction`s. See `CLAUDE.md` for the conventions.

## Tests and tools

```
tools/run_tests.sh                  # GUT unit tests (headless)
tools/run_e2e.sh                    # plays the whole demo through the real UI with injected input (windowed, ~2 min)
tools/run_battle_human_smoke.sh     # regression test: 6+ human battle turns via injected mouse only (windowed)
tools/run_town_interact_smoke.sh    # regression test: NPC/vendor/station interaction via E/Space/Click (windowed)
tools/shot.sh <scene> <name> [--k=v] # screenshot of a scene to _screenshots/<name>.png (git-ignored)
Godot --path . res://tools/battle_smoke.tscn   # one battle through real mouse clicks
Godot --headless --path . -s res://tools/run_dungeon_simulation.gd -- --runs=500  # tutorial-dungeon win rate -> docs/balance_report.md
tools/sync_assets.sh                # copy the audio files named in app/audio_catalog.gd into assets/
```

The two `run_*_smoke.sh` scripts and `run_e2e.sh` open a real window for injected mouse/keyboard
input; run them one at a time, not alongside each other or the editor, on a memory-constrained
machine.

## Assets

Art, audio and fonts come from approved free sources only; every pack is listed with its license in
`CREDITS.md`. Downloaded packs live in `_asset_library/` (git-ignored); only used files are in `assets/`.
Card art is a placeholder (game-icons.net silhouettes). Names, numbers and lore are placeholders.
