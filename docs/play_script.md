# Play scripts (Fresh eyes Oct 30)

`bash tools/play.sh <script.txt> [run_name] [limit_seconds]` plays the real game from the title screen following a plain-text script:
injected keys and mouse events (the same path a human's input takes), screenshots and a few debug jumps. Nothing is ever saved
(`--no-save`), so every run starts at the title with the player's real slots untouched; `dev save <name>` / `dev load <name>` keep a
snapshot in `user://dev_saves/` so a later run can continue where one stopped. Output: `_screenshots/play/<run_name>/<shot>.png`,
`play.log` (every line with a timestamp, plus the output of `dump` / `scene`) and `stdout.log` (Godot's own output, script errors).
Windowed; one Godot at a time; the default window is 1600x900 (`SHOT_RES=WxH` changes it).

One command per line, `#` comments. **Coordinates are screenshot pixels** (the window), not canvas units.

| Command | Does |
|---|---|
| `wait <s>` | let the game run |
| `key <Name>` | tap a key: `E`, `Space`, `Escape`, `Enter`, `W`, `Tab`, `F10`, `Up`, `1` ... |
| `hold <Name>[+<Name>] <s>` | hold one or more keys (walking: `hold W 2`, `hold W+A 1.5`) |
| `click <x> <y>` / `rclick` / `move` | left click / right click / hover |
| `drag <x1> <y1> <x2> <y2>` | drag and drop (play a card from the hand onto the board) |
| `button <text>` | click the first visible button whose text contains `<text>` (logs NOT FOUND otherwise) |
| `shot <name>` | save a screenshot |
| `dump` | log every visible label and button with its text and screenshot position |
| `scene` | log the current scene, level, gold, run HP |
| `pilot <s>` | a simple built-in player plays the current battle for up to `<s>` seconds (mulligan, plays, attacks, blocks; reads a tip and presses Got it; presses Skip tips if a tip holds the duel; confirms End Turn) |
| `skip_dialogue [max]` | tap E / click through dialogue boxes, story stills and reward popups (default 40 taps) |
| `dev level N` / `dev gold N` / `dev heal` | debug: silent level, gold, full heal |
| `dev travel town|forest|capital|arena` | debug jumps |
| `dev travel zone <beefcake|gourmand|refusemancer|necrocrat>` | a Path zone (gatekeeper ignored) |
| `dev travel dungeon <id> [node]` | any dungeon at its entrance, a node, or the boss (`-2`) |
| `dev encounters <query>` / `dev encounter <query>` | list / start a fight from the balance catalog (by name or group) |
| `dev quest <id> <step>` / `dev freed <zone>` / `dev gate <zone>` | quest step, zone freed, gatekeeper beaten |
| `dev card <id>` / `dev item <id>` / `dev gear <id>` / `dev slots` / `dev packs <id> <n>` | give things |
| `dev autowin on|off` / `dev win` / `dev lose` | the Dev Menu's auto-win; end the current battle |
| `dev save <name>` / `dev load <name>` | snapshot / resume |
| `log <text>` | a note in the log |

Code: `tools/play_script.gd` (`PlayScript`), launcher `tools/play_script_launcher.tscn`, wrapper `tools/play.sh`. Built on `UiDriver`
(input) and `BattlePilot` (the simple battle player) and `DevActions` (the Dev Menu's actions). Example scripts: `docs/review/play_scripts/`.
