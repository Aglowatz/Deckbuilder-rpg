# Deckbuilder-RPG — Project Conventions

Godot 4.7.2, Forward+ renderer, single-player deckbuilder RPG.

## Language

- GDScript only. No C#, no GDExtension/native modules unless explicitly decided otherwise.
- Every script declares `class_name` when it's meant to be referenced elsewhere, and every
  file starts with `extends <Type>`.
- **Static typing is required.** Type all variables, function parameters, and return values
  (`var hp: int = 10`, `func apply(card: CardData) -> void:`). Avoid `var x = ...` inference
  for anything beyond obvious local temporaries, and never leave a function return type
  unannotated. Enable/keep the project's static-typing warnings on.
- Prefer `enum`s and typed `Resource` classes over stringly-typed data (magic strings for
  card ids, effect types, etc.).

## Architecture: rules vs. presentation

Card game rules logic must stay separate from presentation. This is the most important
structural rule in the project.

- `core/` — the rules engine. Deck, hand, turn order, card effect resolution, combat math,
  win/loss conditions. Pure GDScript logic: no `Node` scene-tree dependencies where avoidable,
  no direct references to `ui/` or `scenes/`, no `get_node()` reaching into presentation.
  Communicate outward via signals or return values, not by poking scene nodes directly.
- `data/` — card and encounter definitions (as `Resource`/`.tres` data, not baked into logic).
  `data/cards/` for card definitions, `data/encounters/` for encounter/enemy layouts.
- `scenes/` — top-level game scenes (`.tscn`) that assemble `core/` + `ui/` + `data/` together.
- `ui/` — presentation: visuals, animations, input handling, HUD, card visuals. UI reads game
  state from `core/` and calls into it to make moves; it never contains rules logic itself
  (e.g. "can this card be played" belongs in `core/`, not in a button's `_pressed()`).
- `assets/` — art, audio, fonts. See `CREDITS.md` — every non-original asset added here must
  get a corresponding license entry.
- `tests/` — GUT test scripts (`test_*.gd`), mirroring the structure of what they test.

Rule of thumb: `core/` should be testable and runnable with no scene tree and no rendering.
If a test for game logic needs a running scene to pass, that's a sign logic leaked into
presentation.

## Testing

- Tests use the [GUT](https://github.com/bitwes/Gut) addon (`addons/gut/`), test scripts live
  in `tests/`, named `test_*.gd`, extending `GutTest`.
- Run headlessly from the project root:

  ```
  C:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests -gexit
  ```

- `core/` rules logic should be the primary thing under test — it's the part that doesn't
  need a scene tree to exercise.
