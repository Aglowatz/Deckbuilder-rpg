# Art import Oct 31 - batch 10 (17 files)

Tag `pre-art-import-oct31`; commits "Art import Oct 31, Part 1..5". All 17 files from the Drive's `Approved_*` folders (copy-only); nothing read
from Pending Review. Replaced files backed up to `_art_source/superseded_oct31/` (the old Chef / Wizard / Leaf Crown sheets, their sliced views,
and `fit.json` / `fit_auto.json` as they were). Check: `node tools/art_check_oct31.js` -> **17 of 17 delivered files in game**.

## Files

| File | Bytes | Size (px) | Folder | In game as |
|---|---:|---|---|---|
| STORY-WAKE-NIGHT.png | 4,383,320 | 1792x1024 | Approved_KeyArt | `assets/art/keyart/STORY-WAKE-NIGHT.webp` |
| ICON-UI-GLOSSARY.png | 1,659,799 | 1024x1024 | Approved_Icons | `assets/art/icons/ICON-UI-GLOSSARY{,_24..128}.webp` |
| ICON-UI-FEATS.png | 1,188,289 | 1024x1024 | Approved_Icons | `assets/art/icons/ICON-UI-FEATS{,_24..128}.webp` |
| COS-HAT-CHEF-SHEET.png | 1,916,137 | 2560x1024 | Approved_Cosmetics | `assets/art/cosmetics/hats/CHEF/<DIR>.png` |
| COS-HAT-WIZARD-SHEET.png | 1,441,893 | 2560x1024 | Approved_Cosmetics | `assets/art/cosmetics/hats/WIZARD/<DIR>.png` |
| COS-HAT-LEAFCROWN-SHEET.png | 1,040,867 | 2560x1024 | Approved_Cosmetics | `assets/art/cosmetics/hats/LEAFCROWN/<DIR>.png` |
| SPR-FOE-CAPTAIN-SPOTLESS-FRONT_IDLE.png | 2,104,269 | 1024x1536 | Approved_Sprites | `assets/art/world_test/sprites/FOE_CAPTAIN_SPOTLESS/FRONT_IDLE.png` |
| SPR-FOE-CAPTAIN-SPOTLESS-FRONTSIDE_IDLE.png | 1,984,977 | 1024x1536 | Approved_Sprites | `.../FRONTSIDE_IDLE.png` |
| SPR-FOE-CAPTAIN-SPOTLESS-SIDE_IDLE.png | 1,623,671 | 1024x1536 | Approved_Sprites | `.../SIDE_IDLE.png` |
| SPR-FOE-CAPTAIN-SPOTLESS-BACKSIDE_IDLE.png | 1,572,324 | 1024x1536 | Approved_Sprites | `.../BACKSIDE_IDLE.png` |
| SPR-FOE-CAPTAIN-SPOTLESS-BACK_IDLE.png | 1,551,204 | 1024x1536 | Approved_Sprites | `.../BACK_IDLE.png` |
| SPR-FOE-CAPTAIN-SPOTLESS-FRONT_WALK.png | 2,677,482 | 1536x1024 | Approved_Sprites | `.../FRONT_WALK1..4.png` |
| SPR-FOE-CAPTAIN-SPOTLESS-FRONTSIDE_WALK.png | 2,647,095 | 1536x1024 | Approved_Sprites | `.../FRONTSIDE_WALK1..4.png` |
| SPR-FOE-CAPTAIN-SPOTLESS-SIDE_WALK.png | 2,392,591 | 1536x1024 | Approved_Sprites | `.../SIDE_WALK1..4.png` |
| SPR-FOE-CAPTAIN-SPOTLESS-BACKSIDE_WALK.png | 1,452,834 | 1536x1024 | Approved_Sprites | `.../BACKSIDE_WALK1..4.png` |
| SPR-FOE-CAPTAIN-SPOTLESS-BACK_WALK.png | 1,695,794 | 1536x1024 | Approved_Sprites | `.../BACK_WALK1..4.png` |
| SPR-FOE-CAPTAIN-SPOTLESS-FRONT_TALK.png | 2,089,968 | 1024x1536 | Approved_Sprites | `.../FRONT_TALK.png` |

## Part 1 - night wake-up still

- `import key art`, row STORY-WAKE-NIGHT added to `data/source/logo_title_art.csv` (status Done).
- `StoryStills.WAKE_NIGHT` + `opening_wake()`: the opening (`StartingAreaScene._play_awakening`) shows the night still when it is in the game,
  else STORY-WAKE. Dialogue freeze: the night still has no captions of its own; `StoryStills.CAPTION_FROM` makes it read `still.wake` (the
  same lines as before). STORY-WAKE stays imported and is the fallback; nothing else used it.
- Play script `docs/review/play_scripts/oct31_wake_night.txt` (`bash tools/play.sh ... oct31_wake`): shots
  `_screenshots/play/oct31_wake/01_wake.png`, `02_wake_line2.png`, `03_wake_line3.png`. The night still shows (moon, fireflies, the four-colour
  glow in the hand); the caption box sits on the lower quarter (y 675-820 of 900) over grass, cloak and ground, clear of the face and the
  glowing hand. It just touches the fingertips of the right hand (x ~1300).
- Test: `tests/test_story_stills.gd` (night still reads the wake captions, both stills imported, `opening_wake`).

## Part 2 - Glossary and Feats icons

- `import icons`, rows ICON-UI-GLOSSARY / ICON-UI-FEATS added to `data/source/icons.csv` (Menu icons). The importer trims each icon and fits its
  longest side into the same square as every ICON-UI-* icon, so they come out the same size as the neighbours.
- Where: pause menu Glossary / Feats buttons (40 px, like Save / Load / Settings), HUD Menu's Glossary / Feats entries (30 px, like Character ...
  Settings; they had no icon before), and the Glossary / Feats page headings (44 px before the 36 px heading). The title screen opens the
  Glossary only for a screenshot hook (no button there). Nothing borrowed was replaced: both had no icon.
- Shots (`bash tools/shot.sh res://scenes/town.tscn oct31/icons_<x> --open=<x>`, new hooks `hud_menu`, `pause_glossary`, `pause_feats`):
  `_screenshots/oct31/icons_pause.png`, `icons_hud_menu.png`, `icons_pause_glossary.png`, `icons_pause_feats.png`. Same left column and slot
  size as the icons above them. The Feats medal looks narrower than its neighbours because the medal is tall and thin (same box).
- Test: `tests/ui/test_art_import_oct31.gd`.

## Part 3 - hat sheet redos (Chef, Wizard, Leaf Crown)

Slicer: `HatSheet.split` as before, then new `HatSheet.normalise`: a view whose trimmed box is more than 8 % off FRONT's (width or height) is
scaled uniformly (its own shape kept) by the geometric mean of FRONT/view over width and height. The importer's fit now keeps that one scale
(`HatSheet.fit(..., one_scale = true)`: each view's card width = FRONT width x view width / FRONT width). The old "head band" rule ignored drawn
size, so a slicer rescale alone would not have changed the game; it also read the new Chef's side view at 0.76x (its bottom rows show the
hat's opening). Measure any sheet: `Godot --headless --path . -s res://tools/hat_measure.gd -- --dir=<folder> [--hats=..]`.

Only the three new sheets were imported (`world_test_import.gd -- --cosmetics --cos_inbox=res://_art_inbox/cosmetics_oct31/`), so Bowler, Tricorn
and Wide Brim are untouched (their Drive sheets are byte-identical to the imported ones; their contact-sheet fit rows match Oct 29 exactly).

### Measurements (opaque bounding box per view, ratio to FRONT)

**Before - the old sheets (2560x512)**

| View | Chef w x h | w / h vs FRONT | Wizard w x h | w / h vs FRONT | Leaf Crown w x h | w / h vs FRONT |
|---|---|---|---|---|---|---|
| FRONT | 251 x 256 | 1.00 / 1.00 | 261 x 282 | 1.00 / 1.00 | 289 x 193 | 1.00 / 1.00 |
| FRONTSIDE | 246 x 270 | 0.98 / 1.05 | 255 x 281 | 0.98 / 1.00 | 288 x 204 | 1.00 / 1.06 |
| SIDE | 244 x 273 | 0.97 / 1.07 | 237 x 268 | 0.91 / 0.95 | 276 x 201 | 0.96 / 1.04 |
| BACKSIDE | 266 x 290 | 1.06 / 1.13 | 264 x 287 | 1.01 / 1.02 | 294 x 200 | 1.02 / 1.04 |
| BACK | **348 x 359** | **1.39 / 1.40** | 260 x 285 | 1.00 / 1.01 | 296 x 198 | 1.02 / 1.03 |

**After - the new sheets (2560x1024), raw split -> after normalise**

| View | Chef raw | Chef normalised | Wizard raw (no change) | Leaf Crown raw | Leaf Crown normalised |
|---|---|---|---|---|---|
| FRONT | 477 x 461 (1.00 / 1.00) | same | 411 x 416 (1.00 / 1.00) | 426 x 261 (1.00 / 1.00) | same |
| FRONTSIDE | 475 x 462 (1.00 / 1.00) | same | 413 x 418 (1.00 / 1.00) | 418 x 282 (0.98 / 1.08) | 406 x 274 (0.95 / 1.05) |
| SIDE | 434 x 463 (0.91 / 1.00) | 454 x 484 (0.95 / 1.05) | 397 x 411 (0.97 / 0.99) | 416 x 302 (0.98 / **1.16**) | 391 x 284 (0.92 / 1.09) |
| BACKSIDE | 457 x 469 (0.96 / 1.02) | same | 417 x 415 (1.01 / 1.00) | 391 x 287 (0.92 / 1.10) | 389 x 286 (0.91 / 1.10) |
| BACK | 478 x 462 (1.00 / 1.00) | same | 413 x 422 (1.00 / 1.01) | 446 x 256 (1.05 / 0.98) | same |

- **Chef**: the redo fixed the oversized back view (1.39x -> 1.00x). Every view within 9 % raw; after normalise within 5 %.
- **Wizard**: every view within 3 %; nothing rescaled.
- **Leaf Crown**: the scale is consistent; the side views are a different SHAPE (a ring seen from the side is narrower and taller), not a
  different size, so a uniform scale cannot bring both width and height inside 8 % (the geometric mean leaves 0.91-0.95 wide, 1.05-1.10 tall).
  Left as drawn.
- Fit ratios written to `fit_auto.json` (card width vs FRONT): Chef FS 1.00 / S 0.95 / BS 0.96 / B 1.00; Wizard 1.00 / 0.97 / 1.01 / 1.00;
  Leaf Crown 0.95 / 0.92 / 0.91 / 1.05 (were band-based: Chef 0.91 / 0.80 / 0.85 / 1.03, Wizard 1.08 / 1.17 / 1.03 / 1.00).

### Anchors and offsets (re-checked against the Oct 29 hat-fit pass)

`tools/hat_contact_sheet.tscn` (world + wardrobe preview, idle + walk 1-4, all five directions); band offsets compared with
`_screenshots/oct29/hats_after/fit_table.md`:

- **Wizard**: the new art's band sits lower in its card, so with the Oct 29 sinks it rode 0.06-0.14 head widths lower. Sinks set back to the
  Oct 29 band heights (FRONT 0.59, FRONTSIDE 0.58, SIDE 0.60, BACKSIDE 1.03, BACK 1.06); the hand `width_SIDE 1.95` (made for the old sheet's
  1.17 side ratio) removed.
- **Chef**: FRONTSIDE and SIDE covered the eyes; sinks 0.64 / 0.60 -> 0.48 / 0.45 (band now level with the FRONT view's).
- **Leaf Crown**: placement already matched Oct 29 (sinks unchanged). The new sheet paints only the front arc, and from BACKSIDE / BACK that
  arc is on the far side of the head, so it drew across the back of the hair. New fit key `behind` (per direction, `behind_<DIR>`;
  `WorldSprite` sends a negative depth nudge so the body covers the card): Leaf Crown `behind_BACKSIDE` / `behind_BACK` = 1. Now the hair shows
  from behind and only the leaf tips peek out past the head.

Shots: `_screenshots/oct31/hats_final/ALL.png` (the 3 hats x 5 directions, idle + four walk frames, world | preview; the 15 idle cells are its
top row per hat), `fit_table.md` beside it; first pass `hats_v1/`, after retune `hats_v2/`; the other three hats `hats_others/` (unchanged).
Tests: `tests/world/test_hat_sheets.gd` (normalise, one-scale fit, `behind` key, Leaf Crown behind only from BACK / BACKSIDE).

## Part 4 - Captain Spotless walk set

- Row `NE-CAPTAIN-SPOTLESS` (rel height 1.05, the same as his NPC set) added to `data/source/npc_sprite_batch.csv` section G. Imported with the
  same importer and strip slicing as the other SPR-FOE sets, limited to this set with the new `--npc_inbox=` option
  (`world_test_import.gd -- --npcs --npc_inbox=res://_art_inbox/npc_sprites_oct31/`): 26 frames (5 idles, 5 x 4 walk, FRONT_TALK), canvas
  336x504, walk dirs all five. The importer rewrote the whole `manifest.json` (float formatting); HEAD's manifest was kept with only the new
  `FOE_CAPTAIN_SPOTLESS` entry spliced in (+52 lines).
- Key check: `CapitalEnemies.SPOTLESS` now names `FOE-CAPTAIN-SPOTLESS`; `ZoneEnemy._make_model` looks up `sprite_key().replace("-", "_")` =
  `FOE_CAPTAIN_SPOTLESS` = the imported folder and manifest key (tested in `tests/ui/test_art_import_oct31.gd` and the roster test
  `tests/core/data/test_enemy_art_oct28.gd`). The gate NPC keeps the stationary `SPOTLESS` set.
- Scale and ground line: rel height 1.05 and the same canvas foot line as his gate set (same `fig_h` 440, bottom pad 16); the Correction
  Officers are 1.2 by design, so he stands a little shorter than his officers.
- **He never spawns as a roamer.** The Capital's roamer list has no `spotless`; he is the gate NPC and his entry only supplies the gate
  battle. So in normal play the walk set shows nowhere yet. Inbox "Art import Oct 31" item 1.
- Shots via the lineup tool, which can now line up given kinds (`--lineup_kinds=officer,spotless`): `_screenshots/oct31/spotless_lineup_walk.png`
  (back row: Spotless walking FRONT, FRONTSIDE, SIDE, BACKSIDE, BACK, SIDE mirrored; front row Correction Officers for scale) and
  `spotless_lineup_threat.png` (the FRONT_TALK pose a roamer strikes when it spots the hero; finger raised). At the gate he still talks with
  the SPOTLESS set (unchanged).

## Part 5 - checks

- `node tools/art_check_oct31.js`: 17 of 17 in game. The importers' missing lists: key art none, icon kit none (ICON-GEAR-EARNEDBLADE still
  missing from before this batch).
- GUT, see the report at the end of this file.

## Looked off

1. **Spotless BACKSIDE** (idle and walk): drawn as a light three-quarter back. His face is in profile and the cape faces the camera, so at play
   size it reads close to SIDE. The idle and walk agree, so it is usable; a redo with more of his back would read better.
2. **Spotless walk strips** have loose yellow/red specks between the figures (alpha fringe); the importer drops them, and the frames are clean.
3. **Leaf Crown FRONT**: the arc's two ends point straight up and read a little like horns (inbox item 3).
4. Shots in the town and Capital carry two feat toasts at the top ("Leaves in Your Hair", "Old Stone, Cold Nights"): the dev shot's state earns
   them on load. Not this batch.

## GUT report (in groups, one Godot at a time)

| Group | Result |
|---|---|
| root files (`-gconfig= -gdir=res://tests`: story stills / prologue, icon art, compile-all, title / key art) | 287 / 287 |
| `tests/ui` (menus, pause, Glossary / Feats icons, Spotless set) | 169 / 169 |
| `tests/world` (hat sheets, sprite cosmetics, roamers, sprites) | 431 / 431 |
| `tests/core` + subdirs (enemy roster / art keys, data) | 1519 + 1 pending (the old "chef hat art" pending) |
| `tests/characters`, `tests/audio` | 92 / 92 |

A first try ran `-gdir=res://tests` without `-gconfig=`, which pulls in every subfolder (`.gutconfig.json`) and hit the 10-minute cap; in that
run three tests failed (`test_controller_input` "a hidden screen gives way", `test_playtest_stability` town recovery, `test_battle_pad` cursor).
All three pass on their own (24/24, 22/22, 8/8) and in their groups above: order effects of the long combined run, not this batch.
No build exported (as asked).
