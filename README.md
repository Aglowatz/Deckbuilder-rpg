# Wellspring (working title)

A single-player deckbuilder RPG built in **Godot 4.7.2** (Forward+), GDScript only. The rules
engine lives in `core/` and is pure logic; the playable demo is a presentation layer on top of it.

## Playing the demo

1. Open the project in Godot 4.7.2 (or run it from the command line) and press **F5**.
   `res://scenes/title.tscn` is the main scene.
2. **Title screen**: New Game / Continue / Settings / Quit.
3. **Starter town** (walk with **WASD** or the arrow keys, **E** to interact, **Esc** for the pause menu):
   - **Elder Maren** and **Gatekeeper Brannoch**: a few lines of story and advice.
   - **The Wellspring** (the well in the middle of town): choose your color (Ember, Tide, Root or Grave). This
     is the starter-deck choice; it sets the color of the 17 basic lands in your 45-card starter deck.
   - **Sable the Trader** (market stall): buy cards with gold.
   - **Deck Station** (the barrel-shaped tavern): browse your collection with filters, build and save decks.
     A legal deck has at least 45 cards, at most 3 copies of a card and at most 2 colors.
   - **Dungeon gate** (north): enter the **Trial of the Hollow**.
4. **Trial of the Hollow**: a node map with two battles, a deck challenge, a healing shrine and a boss.
   Your life carries from node to node and is shown on the map. The first battle is a guided tutorial.
   Win rewards (gold and a card of your choice); beat the boss and the Wellspring teaches you five cards of
   your color. Lose a duel and you are carried back to town with your collection intact.
5. **Battles**: click a card to play it (or drag it onto the table). Cards glow gold when playable. Targeted
   spells show an arrow: click the target, right-click to cancel. In combat click your creatures to attack,
   then press **Attack**; when blocking, click your blocker, then the attacker. Hover any card to zoom it and
   read its keywords. **End Turn** fast-forwards to the opponent.

Everything is keyboard/mouse. Settings (volumes, fullscreen) are on the title screen and in the pause menu.
Saves live in `user://save.json` (Continue on the title screen); the game saves in town and after each
purchase, deck edit and dungeon result.

## Project layout

| Folder | Purpose |
|--------|---------|
| `core/` | The rules engine and campaign rules (no scene tree): game state, combat, effects, AI, simulation, dungeon map, deck rules, rewards. |
| `data/` | Card, deck, challenge and AI resources (`.tres`, generated from `core/data/content_definitions.gd`). |
| `app/` | Autoloads: `EventBus`, `Settings`, `Audio` (+ `MusicSynth`), `Session` (campaign state, saves), `SceneManager`. |
| `ui/` | Presentation: theme, cards, battle screen, town menus, dungeon screens, tutorial. |
| `world/` | 3D scenes: hex town builder, player, town scene, backdrops, lighting. |
| `scenes/` | The top-level `.tscn` scenes (title, town, battle, dungeon map, rewards). |
| `tests/` | GUT tests for `core/` (260+). |
| `tools/` | Screenshot tool, UI driver, smoke and end-to-end tests, asset/theme/content scripts. |
| `docs/` | `design/combat_rules.md` (rules source of truth), open questions, progress log, balance report. |

The rules never touch the scene tree: the battle screen animates the engine's event log and submits
`GameAction`s. See `CLAUDE.md` for the conventions.

## Tests and tools

```
tools/run_tests.sh                  # GUT unit tests (headless)
tools/run_e2e.sh                    # plays the whole demo through the real UI with injected input (windowed, ~5 min)
tools/shot.sh <scene> <name> [--k=v] # screenshot of a scene to _screenshots/<name>.png (git-ignored)
Godot --path . res://tools/battle_smoke.tscn   # one battle through real mouse clicks
tools/sync_assets.sh                # copy the audio files named in app/audio_catalog.gd into assets/
```

## Assets

Art, audio and fonts come from approved free sources only; every pack is listed with its license in
`CREDITS.md`. Downloaded packs live in `_asset_library/` (git-ignored); only used files are in `assets/`.
Card art is a placeholder (game-icons.net silhouettes). Names, numbers and lore are placeholders.
