# Layout check, Oct 22 2026 (UI + economy fixes, Part 1)

Every full-screen menu checked for two problems at every supported resolution: anything cut off at the screen edge, and no visible exit.

## How the game scales (why the UI scale matters more than the window size)

The project draws on a 1920x1080 canvas (`display/window/stretch/mode = canvas_items`, aspect `keep`). Any window size shows that same
canvas scaled to fit: 1280x720, 1366x768, 1600x900, 1920x1080 and 2560x1440 all lay out identically, and a 16:10 window (1280x800,
1920x1200) gets thin bars above and below. What does shrink the room a menu has is the **UI scale** setting (90-150 %): every full-screen
menu is fitted with `UiScale.fit`, which draws it at that scale, so at 150 % a menu only has 1920/1.5 x 1080/1.5 = **1280x720** of room.

## What was wrong

- **Deck Station** (reported): the right-hand "Your Deck" panel was 590 px at least and grew with its longest line (the copy caps rule,
  about 760 px), and the collection grid had a fixed 7 columns, so even at 1920x1080 the panel ran past the right edge (Rename / In use /
  Cover / Copy / Delete and the rules lines were cut) and the close button was pushed off the screen - no visible exit.
- **At a UI scale above 100 %** nearly every menu ran off the screen (vendors, tailor, alchemist, wardrobe, character, Collection Book,
  Bestiary, quest log, arena, reward boxes, the level-up moment, the pause menu, settings, the Load page), several losing their close
  button.
- Screens opened inside a fitted screen (a confirm dialog over a menu, the Load page inside the pause menu) were scaled twice.
- The one-time tip panels sat at fixed 1920x1080 positions and could hang off a smaller canvas.

## What changed

- **Deck Station** (`ui/town/deckbuilder_screen.gd`): the deck panel takes 31 % of the width (440-600 px); the collection's columns follow
  the room it has; the gaps kept free for the slot racks are measured on the racks at the screen's real size; every rules line wraps
  (the copy caps line is also shorter: "Copy caps: Common 3, Uncommon 2, Epic 1, Legendary 1; infrastructure unlimited"); deck list names
  end with an ellipsis; Save / Reset / Fill Infrastructure flow onto a second line on a narrow panel; on a short canvas (a big UI scale)
  the tiles, buttons and headings are smaller and the title hides where the painted top rack covers it (the book icon stays).
- **Exit**: the Deck Station keeps the game's standard round close button in the top-right ("Leave the Deck Station (Esc)"), now always on
  screen; Esc does the same. With unsaved changes both ask **Save / Discard / Cancel** (`ConfirmDialog.ask_three`): Save writes the deck
  back into its own slot (a new deck: the empty slot it was started in) and leaves.
- **Every menu** (`ui/ui_scale.gd`): `UiScale.fit` measures what the screen's content needs (its children's combined minimum size,
  looking inside plain Controls) once the layout has settled (two frames without a size change) and takes only as much of the UI scale as
  still fits; a screen that needs more than the canvas is drawn smaller (down to 70 %) rather than cut. A screen inside a fitted screen
  is no longer fitted again. The level-up moment (laid out at fixed places) asks for the full 1920x1080.
- **Tips** (`TipPanel`) move back inside the screen when their place would hang off it.
- **Filter chips** (`CardFilterBar`, Deck Station and vendors) flow onto another line instead of forcing the screen wider.

## How it was checked

`tools/layout_check.gd` (runner `bash tools/layout_check.sh <tag> "<sizes>" [screens]`, `UI_SCALE=1.5`, `SHOTS=true`) opens every
full-screen menu of the town in a real window and reports, per screen: controls past the screen edge (outside any scroll area that
clips them; the vendor's painted portrait is allowed to run off the bottom), buttons whose text is clipped, and whether a Close / Back /
Continue / Done button sits fully on screen. Menus checked (25): Deck Station, Sable's card stall, Tilly's supplies, the equipment
vendor, the pack stall, the tailor, the Alchemist, the wardrobe, the character screen, the Collection Book, the Bestiary, the quest log,
the full map, the arena, the chest and quest reward boxes, the level-up moment, the pause menu, settings (all five pages) and the Load
page. Zone vendors and the dungeon screens use the same `OverlayScreen` + `UiScale.fit` path (zone vendors are pictured in Part 5).

## Results (after)

| Run | Menus | Cut off | No exit | Notes |
|---|---:|---:|---:|---|
| 1280x720, UI 100 % | 25 | 0 | 0 | |
| 1366x768, UI 100 % | 25 | 0 | 0 | |
| 1600x900, UI 100 % | 25 | 0 | 0 | |
| 1920x1080, UI 100 % | 25 | 0 | 0 | the window is 1920x1061 on this 1080p desktop (title bar) |
| 1280x800 (16:10), UI 100 % | 25 | 0 | 0 | letterboxed 1920x1080 canvas |
| 1920x1200 (16:10), UI 100 % | 25 | 0 | 0 | clamped to the desktop; same canvas |
| 1920x1080, UI 90 % | 25 | 0 | 0 | |
| 1280x720, **UI 150 %** (1280x720 of room) | 25 | 0 | 0 | was: 24 of 25 cut off, 19 with no visible exit |
| 2560x1440 | - | - | - | not openable on a 1080p desktop; it draws the identical 1920x1080 canvas, so it is covered by the 1920x1080 run |

Before (1920x1080, UI 100 %): the Deck Station's panel and close button ran off the right edge (the checker was written after that fix;
the "before" pictures are `docs/ui/layout_oct22/before/deck_1280.jpg` and `deck_1920.jpg`); three other menus only had the vendor portrait
running off the bottom, which is intended. At UI 150 % the scale each menu is now drawn at (it takes as much of the 150 % as fits):
Deck Station 1.40, Sable 1.38, Tilly 1.11, equipment vendor 1.16, packs 1.03, tailor 0.99, Alchemist 1.01, wardrobe 1.06, character
1.01, Collection Book 1.17, Bestiary 1.08, quest log 1.39, map 1.50, arena 1.04, reward boxes 1.13 / 1.21, level-up 1.00, pause and
settings 1.27, Load 1.05. The full logs are `_logs/layout_final_all.txt`, `_logs/layout_final_150.txt`, `_logs/layout_final_090.txt`.

Known cosmetic leftover: at UI 150 % the character screen's "Boots" label sits on the painted parchment's lower edge (on screen and
readable).

## Screenshots

`docs/ui/layout_oct22/` (`<menu>_1920.jpg`, `<menu>_ui150.jpg`) - twelve menus at 1920x1080 (UI 100 %) and the same twelve at 1280x720 with UI 150 %: Deck Station, Sable,
Tilly's supplies, the pack stall, the Alchemist, the character screen, the Collection Book, the quest log, the arena, the level-up
moment, settings (display) and the Load page.
