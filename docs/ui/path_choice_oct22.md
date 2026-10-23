# Path choice screen (Overnight Oct 22, Part 3)

`ui/dungeon/element_choice_screen.gd` (data: `core/dungeon/element_choice.gd`, new field `plan`). Shots: `docs/ui/path_choice_oct22/`
(`path_before.png`, `path_after.png`, `path_after_hover.png`, `path_after_more_720.png`); shot tool
`bash tools/shot.sh res://tools/path_choice_shot.tscn <name> [--hover=gourmand] [--more=true] [--pick=necrocrat]`.

| | Before | After |
|---|---|---|
| On the tiles | name, identity paragraph (~25 words), three cards, playstyle (~20 words) | name, the Path's icon (always, not only with colour-blind symbols), three cards, a one-line plan (~11 words) |
| Intro line | 26 words | 16 words ("Pick the Path that feels like you. It shapes the deck you carry into the cave.") |
| Words to read | ~279 (~80 s) | ~70 (~20 s) |
| Full description | always on | the strip under the tiles: hovered or focused tile; **More** keeps it open for the focused / selected tile (shows the first Path when nothing is picked); **Less** closes it |
| Keyboard / controller | tiles could not take focus | left / right walk the tiles (wrapping), down reaches More / Begin, Enter picks |

The plans:
- Beefcake: "Hit hard and early. Save up Iron, then spend it all on one big swing."
- Gourmand: "Hold the line with sturdy chefs and cook Ingredients into huge Golems."
- Refusemancer: "Make Garbage, eat it for power, and bring your best cards back."
- Necrocrat: "Shrink their blockers with Red Tape, then outlast them."

Bots still click `_tiles[...]` and the "Begin" button; the playtest smoke checks the new intro line.
