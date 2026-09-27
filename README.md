# Wellspring (working title)

A single-player deckbuilder RPG built in **Godot 4.7.2** (Forward+), GDScript only. The rules
engine lives in `core/` and is pure logic; the playable demo is a presentation layer on top of it.

## Playing the demo

1. Open the project in Godot 4.7.2 (or run it from the command line) and press **F5**.
   `res://scenes/title.tscn` is the main scene.
2. **Title screen**: New Game / Continue / Settings / Quit.
3. **The starting area**: you wake up alone in a small forest clearing outside town, with no deck
   and no memory of how you got there (placeholder lines, easy to rewrite - see
   `data/story/intro_story.tres`). Walk with **WASD** / arrow keys; the only way forward is the
   cave mouth. **E**, **Space** or **left-click the object/person in range** all interact - watch
   for the on-screen "[E] ..." prompt.
4. **The Trial of the Hollow**: entering the cave starts the tutorial dungeon with a fixed neutral
   deck - a node map with two battles, a deck challenge, a healing shrine (a full heal, right
   before the boss) and a boss. Life carries from node to node. The first battle is a guided
   tutorial. Losing sends you back to the starting area to try again, not to a town you have not
   reached yet.
5. **Choosing a starting deck**: right after the boss, pick one of four decks (one per color -
   Ember, Tide, Root, Grave), each shown with its identity, playstyle and key cards. Every card in
   the deck you pick joins your collection immediately, and the road to town opens.
6. **Town** (same controls: **WASD**/arrows to move, **E**/**Space**/click to interact, **Esc** for
   the pause menu) is about 2.4x its original size, in three districts:
   - **The original core**: **Elder Maren** and **Gatekeeper Brannoch** (story/advice), the
     **Wellspring** (now a flavor spot - it already recognizes your color), **Sable the Trader**
     (buy cards with gold - stock starts small and grows as you spend and explore, with locked
     cards shown as "???"), the **Deck Station** (browse your collection with filters, build and
     save decks - a legal deck has at least 45 cards, at most 3 copies of a card and at most 2
     colors), and the **dungeon gate** (north) to replay the Trial for gold.
   - **The Harbor Quarter** (east, across the canal bridge near the market): the **Hall of
     Records** (the Codex - every card in the game, cards you have not yet owned, bought or faced
     in battle show as a silhouette) and open plots left for future vendors.
   - **The Secluded Grove** (south of the spawn point): three placeholder secrets - a hidden chest
     behind the trees, a sealed vault and the easy-to-miss lever that opens it, and a hidden vendor
     who only appears once you have found the chest.
7. **Battles**: click a card to play it (or drag it onto the table). Cards glow gold when playable. Targeted
   spells show an arrow: click the target, right-click to cancel. In combat click your creatures to attack,
   then press **Attack**; when blocking, click your blocker, then the attacker. Hover any card to zoom it and
   read its keywords. **End Turn** fast-forwards to the opponent.

Everything is keyboard/mouse. Settings (volumes, fullscreen) are on the title screen and in the pause menu.
Saves live in `user://save.json` (Continue on the title screen); the game saves in town and after each
purchase, deck edit and dungeon result. Continuing a save from before the starting deck was chosen resumes
at the starting area, not town (gold/cards earned so far are kept).

## Project layout

| Folder | Purpose |
|--------|---------|
| `core/` | The rules engine and campaign rules (no scene tree): game state, combat, effects, AI, simulation, dungeon map, deck rules, rewards. |
| `data/` | Card, deck, challenge and AI resources (`.tres`, generated from `core/data/content_definitions.gd`). |
| `app/` | Autoloads: `EventBus`, `Settings`, `Audio` (+ `MusicSynth`), `Session` (campaign state, saves), `SceneManager`. |
| `ui/` | Presentation: theme, cards, battle screen, town menus, dungeon screens, tutorial. |
| `world/` | 3D scenes: hex town builder, player, town scene, backdrops, lighting. |
| `scenes/` | The top-level `.tscn` scenes (title, starting area, town, battle, dungeon map, rewards). |
| `tests/` | GUT tests for `core/` (280+). |
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
