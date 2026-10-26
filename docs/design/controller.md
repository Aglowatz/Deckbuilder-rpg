# Controller support

Oct 26 2026. Full gamepad play: the world, every menu, the battle screen, dialogue, Settings. Xbox and PlayStation pads use Godot's standard
(SDL) mapping, so a button means the same position on both; only the names in prompts differ. The mouse and keyboard work exactly as before:
every controller-only behaviour (the focus ring, the battle cursor, pad tooltips, hover-follows-focus, pad-clickable cards) is switched on only
while the controller is the device in use.

## The default layout

| Where | Button | Does |
|---|---|---|
| World | Left stick (tilt = speed, never below 40%) | walk |
| World | Right stick left / right, LT / RT (hold) | turn the camera |
| World | A (Cross) | interact / talk / enter |
| World | B (Circle) | dismount (rafts and mounts) |
| World | Y (Triangle) | Character screen |
| World | X (Square) | Deck builder |
| World | D-pad Up | the HUD menu (Character, Deck, Quests, Packs, Wardrobe), first entry focused |
| World | D-pad Left / Right / Down | Quest Log / Card packs / Wardrobe |
| World | LB / RB (L1 / R1) | tracked quest: previous / next |
| World | View (Create) | Map |
| World | LS / RS click (L3 / R3) | camera zoom / camera angle presets |
| Everywhere | Menu (Options) | pause menu (fixed) |
| Menus | D-pad / left stick | move the focus (held = repeat) |
| Menus | A | press the focused button, pick the focused card |
| Menus | B | back / close / cancel a dialog (fixed) |
| Menus | X on a card | right click (Deck Station: take one copy out) |
| Menus | Right stick up / down | scroll the open list (Glossary, quest text, long pages) |
| Quest Log | LB / RB | switch tabs |
| Dungeon map | Y | dungeon rules |
| Battle | D-pad / left stick | move the card cursor |
| Battle | A | what a click does on the cursor (play a hand card, pick an attacker / blocker / target, press a HUD button) |
| Battle | B | cancel a target choice, close the Refuse Pile viewer |
| Battle | X | the main button (To Combat / Attack / Confirm Blocks / End Turn) |
| Battle | View | end the turn at once |
| Battle | Y | card details (the preview and keyword box) on / off |
| Dialogue, popups, stills | A | next line / continue |
| Pack opening | A / B | next card / skip |
| Minigames | A, or the D-pad (the sorting game's bins) | the game's own presses |

Every action except the pause button is rebindable in **Settings > Controls** (the last column of each row: choose it, then press a controller
button, stick or trigger direction; Start or Esc cancels, Delete clears). A button another action of the same group used moves out of that
action, like keys. Overworld, Dungeon map and Battle are separate groups, so A can be "interact" and a battle action at once. The pad bindings
are saved in `settings.cfg` under `[pad]`; "Reset" and "Reset to defaults" restore them with the keys. **Controller button names** picks the
glyph names: Auto (read from the pad's name: "PS4/PS5/DualSense/Sony" = PlayStation, anything else = Xbox), Xbox or PlayStation.

## How it is built

- **`Keybinds`** (app/keybinds.gd) - one pad slot per action next to the two key slots. A pad code is a `JoyButton` index (0-99) or a
  stick / trigger direction (`PAD_AXIS_BASE + axis * 2 (+1 positive)`); `apply_to_input_map` writes both into the InputMap (dead zone 0.3) and
  adds A / B to `ui_accept` / `ui_cancel`. `hint`, `first_key`, `back_key`, `confirm_key`, `prompt` return pad names while a pad is in use.
- **`InputDevice`** (app/input_device.gd, a child of SceneManager) - the last real input decides the device (a pad button or a stick past 0.45 =
  pad; a key, a click or a mouse move of 6 px or more = keyboard). A switch emits `EventBus.input_device_changed`. `pad_text(code)` names a
  pad code ("A", "Cross", "LT", "L2", "Left stick up"); `layout_for_name` reads the pad's name.
- **`PromptText`** (ui/prompt_text.gd) - `bind(control, template, property, pad_template)` re-renders a label on every device switch. Templates:
  `{action}` (first key / pad button), `{hint:action}`, `{back}`, `{confirm}`, and the old literal `(Esc)` and `[E]`, so a keyboard player sees
  exactly the old text. Close buttons, the HUD hint line, the HUD menu, dialogue / popup hints, the quest tracker arrows, the dungeon's Deck /
  Rules buttons, the level-up hint and the title footer are bound.
- **`PadGlyph`** (ui/widgets/pad_glyph.gd) - a drawn button (no art): coloured Xbox discs with letters, dark PlayStation discs with the drawn
  shapes, rounded tags for the rest. The world's interact prompt shows it instead of "[A]".
- **`PadFocus`** (ui/pad_focus.gd, a child of SceneManager) - the menu side, for every screen at once. Screens register their root
  (`PadFocus.register`: every OverlayScreen, the pause menu, ConfirmDialog, popups, the battle's modal panels and ~20 stand-alone screens).
  The topmost visible one (canvas layer, then tree order) is the open screen. PadFocus:
  - focuses its first button when it opens (or when the player switches to the pad), or where the screen says (`pad_first_focus()`: the next
    dungeon node, the first card for sale, nothing while a pack is being opened);
  - moves the focus with the D-pad itself, **inside the open screen only** (`PadFocus.neighbor`: the screen's own `focus_neighbor_*` first, then
    the nearest focusable control in that direction, same-row / same-column first). Godot's own search spans the whole window and could jump
    from a dialog to a card behind it. Sliders, text fields and open drop-downs keep their arrows; a held direction repeats (0.4 s, then 0.12 s);
  - draws the gold focus ring on top of everything (also around controls whose theme has no focus box), shows the focused control's tooltip
    after 0.35 s, scrolls it into view, gives it the mouse's hover signals (card previews follow the focus), scrolls lists with the right stick,
    hides the mouse cursor, and keeps the focus from leaving the open screen. Back in the world it drops any focus left on a HUD control.
- **`PadClick`** (ui/pad_click.gd) - mouse-only controls made pad-clickable: Deck Station tiles, a vendor's stock, reward picks, dungeon map
  nodes. They are focusable only while a pad is in use; A sends the control the same left-click event the mouse would (X a right click).
- **`BattlePad`** (ui/battle/battle_pad.gd) - the battle's card cursor over every clickable thing on the board (both sides' cards except the
  enemy's hand, the portraits, the Refuse Piles, the HUD and tutorial buttons). Directions pick the nearest stop that way (straight ahead counts
  more than sideways); the cursor starts on the current decision (a target, an attacker, a blocker, a card to toss, a playable card, else the
  main button), lifts and previews the card under it like a hover, and aims the targeting arrow. A calls `BattleScreen.pad_click_card` (a
  click, except that a hand card plays at once - no drag). It waits while a modal panel (mulligan, result, Choose X, ability menu, confirm box,
  pause menu) holds menu focus, and while a boss intro plays. Battle instructions switch to pad words (`BattleScreen._how`).
- **World** - `TownPlayer._read_input` reads keys at full strength and the stick through `Input.get_vector` (speed follows the tilt). The
  world's shortcut checks use `UiInput.is_fresh_press` (keys, pad buttons, and a stick or trigger only on the frame it crosses half way), and
  ignore a pad press while a menu control has the focus (`UiInput.pad_focus_busy`: a focused button takes A without consuming it).
- **Minigames** - every station / bin is a button (focus + A); the rhythm game pumps on A, the sorting game's bins are on the D-pad.

## Tests

- `tests/test_controller_input.gd` - defaults (no two actions of a group share a pad button), the InputMap, A / B in menus, the stick's
  strength and dead zone, rebinding (displacement, Start reserved, pause fixed, sticks and triggers), persistence, the device switch, PlayStation
  names, hints and templates per device, the stick's fresh-press edge, the Settings capture, the focus helper.
- `tests/ui/test_pad_focus_screens.gd` - for 17 screens (Settings x5 pages, Deck Station, Sable's shop and its card grid, item and equipment
  vendors, Collection Book, Bestiary, Character / equipment, Quest Log, Packs, save slots, pause menu, a three-way question): the first focus is
  inside the screen, and every visible button, card and slider is reachable with the D-pad (`PadFocus.neighbor`, four directions, no Tab).
- `tests/ui/test_battle_pad.gd` - the mulligan box takes focus while the cursor waits; the cursor starts on a playable card, walks the hand,
  plays with A, starts on the target and cancels with B, Y toggles the details, the cursor is pad-only, the main button names Space or X.
- **Smoke**: `bash tools/run_gamepad_smoke.sh` - the opening hour with simulated controller events only (`tools/pad_driver.gd`; the smoke
  counts every key and mouse event that reaches the game: there must be none). Path choice by D-pad, a stick walk (and a half tilt walking
  slower), the gate's confirm box, Maren, Sable's shop (category, a card bought, B back), the HUD menu and a pack opened, the Deck Station (a
  rack slot, A adds / X removes a card, the unsaved-changes question), a real ghost-duel turn by the battle cursor (mulligan, cards played,
  combat, end-turn confirm), level 5, Bertram, the Character screen (Y), the Quest Log (D-pad Left, RB), the map (View), the pause menu
  (Start) with Settings > Controls, and B out of each. Screenshots in `_screenshots/gamepad/`. About 2.5 minutes.

## Not done / later

- Rumble, and the PlayStation touchpad / gyro.
- Nintendo pads read as Xbox names (their A / B positions swap on SDL's mapping: the prompts name the position, which may not match the label).
- One-off onboarding tips still say "click" / "hover" (the battle instructions, dialogue and hint lines switch; the tips' prose does not).
- The hero preview turns with the right stick; there is no pad drag elsewhere (nothing else needs one).
