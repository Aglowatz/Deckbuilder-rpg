# Report - Fresh eyes round 2 (Fable, overnight Oct 31)

Sat Oct 31 ~02:30 MDT -> (in progress). State `docs/overnight/loop_state.md`; questions `docs/overnight_inbox.md` ("Fresh eyes round 2").
Last run's report: `docs/overnight/oct30/overnight_report_fresh_eyes_oct30.md`. Dialogue freeze respected (no line or key changed;
rewrites, if any, in `docs/dialogue/lines_to_update_oct31.csv`); no art generated; the black market, prices and the XP curve untouched; no
enemy intent; no version bump, no export. Old saves load (nothing in the save format changed; one new settings key with a default).

## Read this first

- **Part 1 (commit 13ab312e)**: the second critic's problems are fixed. E, Enter, Space and the pad's A answer every confirm dialog
  ("Go in?"), every screen tip ("Got it"), the Hollow Well's Reveal / Continue and the duel's coach bubbles (E / Enter there; Space stays
  the phase key). The Path screen's More now really expands (the Path's Resource and its whole 45-card starting deck in words). The
  treeline self-talk is a speech bubble over the hero that never stops the walk. Tooltips re-fit to their text every frame (the box used
  to keep a first-frame height that ran to the bottom of the screen), the "cannot play" toast lives in a layer above the tooltips and
  higher on the board, the turn / result banner has its own layer above tooltips and units, and the tutorial bubbles keep off the card
  preview and both plates. The cave beacon and the reward pre-select stay as they were.
- **Part 2 (commit 6d1a96f0)**: the hand is drawn compact (whole card on screen, rules text readable without hovering; classic and
  fan kept behind `--hand_style=` for comparison, shots in `docs/review/fresh_eyes_fixes_oct31/hand_*.png`), the Settings pages have a
  visible gold scrollbar clear of the checkboxes, a defeat recap ("What beat you": the biggest damage source in numbers and one tip
  read from the fight) sits on the result panel, and Settings > Text has a "Tutorial tips" on/off.
- **Part 3**: the starter-deck Infrastructure study - see below (sim only).
- **Part 4 / 5**: the mid-game critic and the fixes from its top 15 - see below.

## Part 1 - the second critic's problems (commit 13ab312e)

| # | Problem (second look, Oct 30) | Fix | Where | Shots (`docs/review/fresh_eyes_fixes_oct31/`) |
|---|---|---|---|---|
| 1 | Confirmation popups ignore E | `ConfirmDialog._unhandled_input`: a confirm press (E / Enter / Space / pad A) presses the focused button (the safe one on a dangerous question), after a 0.35 s guard so the E that opened "Go in?" cannot answer it | `ui/widgets/confirm_dialog.gd` | `after_go_in_popup_e.png`, `after_cave_entered_by_e.png` |
| 2 | The Well's Reveal / Continue ignore E | Reveal is focused and a confirm press presses it (then Continue) after a 0.4 s guard | `ui/dungeon/challenge_screen.gd` | `after_well_reveal_by_e.png` |
| 3 | The duel's "Got it" tips ignore E | E / Enter press Got it on an info bubble (0.6 s guard; Space left to To Combat); screen tips ("Tip: The dungeon map") take any confirm press | `ui/battle/tutorial_layer.gd`, `ui/widgets/tip_panel.gd` | run `fix31_b` (the map tip and the intro tip gone after E) |
| 4 | "More" only renames itself | More adds the Path's Resource with its rule and the real starting deck (45 cards: 19 Infrastructure, the types, every named card with copies) under the identity and playstyle; the hint names it | `ui/dungeon/element_choice_screen.gd` | `before_path_more.png` / `after_path_more.png` |
| 5 | Treeline self-talk stops the walk | The line is a bark bubble over the hero (`NpcBarks.say`), the nudge back toward the cave stays; `self_talk_line()` for smokes | `world/starting_area_scene.gd`, `world/npc_barks.gd` | `before_treeline_box.png` / `after_treeline_bubble.png` |
| 6 | Tooltip hides the "cannot play" toast | The toast is in its own CanvasLayer (26) above the tooltip layer (25) and at y 585 (above a lifted card's tooltip); it stays 1.8 s | `ui/battle/battle_screen.gd` | `before_tooltip_over_toast.png` |
| 7 | Tooltip drawn as a dark column to the screen bottom | `_place_tip` re-fits the box to its text every frame (wrapping labels report a huge height on their first frame and a Control never shrinks by itself) | `ui/battle/battle_hud.gd` | `after_tooltip_height.png` |
| 8 | Tip boxes over the card preview and the player plate | `_avoid_rects` adds `hud.preview_rect()` and both `plate_rect()`s | `ui/battle/tutorial_layer.gd`, `ui/battle/battle_hud.gd` | `before_tip_over_preview.png` / `after_energy_tip_clear_of_plate.png` |
| 9 | VICTORY! under a tooltip / units for its first frames | The banner and the announce line live in a CanvasLayer (27) above tooltips and the board | `ui/battle/battle_hud.gd` | `after_victory_banner_on_top.png` |
| 10 | "1 of the 5 cards were Infrastructure" | The verb agrees with its number (test) | `core/dungeon/challenge_resolver.gd` | - |

Checks: GUT root 286, core 1500 (+1 pending, as before), ui 245, world 424 all green; opening forest smoke OK (the hero still walks the
path to the cave; the gate asks; Maren at the mouth; Crosspath); first-battles smoke OK (0 failures, 56 fps lowest); driver scripts
`docs/review/play_scripts/fix31_a*`, `fix31_b*`, `fix31_c` (new game -> Path screen -> More; the walk; "Go in?" with E; the map tip and
the duel tips with E; the toast; the banner; the Well with E).

## Part 2 - safe recommendations (commit 6d1a96f0)

| What | Done | Where | Shots |
|---|---|---|---|
| Hand readable without hovering | `BattleBoard.HAND_STYLES`: **compact** (scale 0.58, centre y 950: the whole card incl. the rules text on screen; the top stays under the Infrastructure row as before) is the default; **classic** (0.68, y 985: the rules box below the edge) and **fan** (0.68, wider arc, more tilt: the text bands overlap) kept behind `--hand_style=` on battle shots. Compact reads best: every card's whole text is visible in the duel | `ui/battle/battle_board.gd`, `ui/battle/battle_screen.gd` | `hand_classic.png`, `hand_compact.png`, `hand_fan.png`, `after_hand_compact_in_duel.png` |
| Settings scrollbar | The page scroller's bar restyled (gold grabber on a visible track, 16 px) and the page body given a right margin so the bar no longer lies over the checkboxes | `ui/screens/settings_panel.gd` | `before_settings_no_scrollbar.png` / `after_settings_scrollbar.png` |
| Defeat recap | A "What beat you" box on the result panel after a loss: the biggest damage source by name, its share of the damage and its hits (or "X outlasted you over N turns"), plus one tip read from the fight (missed Infrastructure drops, a hand left unplayed, a repeat attacker to block, an unspent Resource, else rest/heal) | `ui/battle/battle_screen.gd` (`_track_for_recap`, `defeat_recap_lines`) | `after_defeat_recap.png` |
| Tutorial tips toggle | Settings > Text > "Tutorial tips (first-time hints in duels and on new screens)"; off = no duel bubbles (`TutorialLayer.wanted`) and no screen tips (`TipPanel.show_once`), unseen ones stay unseen; saved in settings.cfg | `app/settings.gd`, `ui/screens/settings_panel.gd` | `after_settings_tutorial_toggle.png` |

ICON-UI art for Glossary / Feats stays a recommendation (no art tonight).

## Part 3 - starter deck study (sim only)

(filled in below once the run finishes)

## Part 4 - the mid-game critic

(filled in below)

## Part 5 - triage and fixes

(filled in below)

## Recommendations that need art, dialogue or a design call

(filled in below)

## Inbox (Fresh eyes round 2)

See `docs/overnight_inbox.md`, section "Fresh eyes round 2".
