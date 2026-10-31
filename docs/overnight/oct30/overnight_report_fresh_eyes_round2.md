# Report - Fresh eyes round 2 (Fable, overnight Oct 31)

Sat Oct 31 ~02:30 -> ~09:30 MDT. State `docs/overnight/loop_state.md`; questions `docs/overnight_inbox.md` ("Fresh eyes round 2").
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
- **Part 3 (commit e653daed)**: the starters stay at 19 Infrastructure. 17 and 15 cut flood turns but add dead turns and cost the cave
  1-2 points on three Paths; nothing met the "every Path improves" bar (`docs/design/sim/starter_infra_oct31.md`).
- **Part 4**: a mid-game critic (no project context, level-8 Gourmand snapshot through the three zones, their dungeons and bosses, the
  Capital, a lieutenant and Primm's first phase) scored **5.2 / 10**: story and visuals 7, pacing, rewards, UI consistency and bugs 4.
  Its snapshot was weaker than a real level-8 player (the cave never cleared), which explains its top finding (a locked card stall)
  and the empty quest log.
- **Part 5 (commit 7ae5ab5f)**: seven of its problems fixed - one Continue rule for keyboard and pad, same-named rules merged into one
  line, one pack ceremony at a time, no tutorial tips in boss fights, no "..." button, the HP loss number off the plate, the doubled
  baker label.

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

## Part 3 - starter deck study (sim only, commit e653daed)

`docs/design/sim/starter_infra_oct31.md` (tool `tools/starter_infra_study.gd`): each Path's 45-card starter rebuilt with 19 (as
shipped), 17 and 15 Infrastructure - the removed basics replaced by extra copies of the deck's own cheapest cards under the 3-copy cap -
played by the sim's Elite AI through the cave (3 fights, L1) and the Path's own first zone (its roamers and elites at the zone's level
with the model's gear and items), 50 games per fight on seeds 7000 and 8100. Measured: win rate, the player's turn of the first
non-Infrastructure play, dead turns (nothing played) and flood turns (3+ Infrastructure left in hand).

| Path | Infra | Cave win | Zone win | First real play (cave) | Dead turns / game (cave) | Flood turns / game (cave) |
|---|---:|---:|---:|---:|---:|---:|
| Beefcake | 19 / 17 / 15 | 97 / 96 / 95 | 85 / 89 / 87 | 2.7 / 2.5 / 2.5 | 2.41 / 2.46 / 2.66 | 0.93 / 0.36 / 0.27 |
| Gourmand | 19 / 17 / 15 | 99 / 97 / 97 | 96 / 96 / 95 | 2.5 / 2.3 / 2.4 | 2.78 / 2.88 / 2.91 | 1.02 / 0.40 / 0.31 |
| Refusemancer | 19 / 17 / 15 | 94 / 94 / 94 | 100 / 100 / 100 | 2.7 / 2.7 / 2.6 | 2.65 / 2.89 / 3.12 | 0.92 / 0.37 / 0.27 |
| Necrocrat | 19 / 17 / 15 | 98 / 97 / 97 | 100 / 100 / 100 | 2.8 / 2.6 / 2.6 | 2.73 / 2.97 / 3.13 | 0.95 / 0.38 / 0.28 |

**Result: nothing changed; the starters stay at 19.** Fewer basics do what the critics felt they would (flood turns drop by half to
two thirds, the first real play comes ~0.2 turns earlier) but every Path pays with more dead turns and three of the four lose 1-2 cave
points; only Beefcake's zone fights improve (85 -> 89 % at 17). The brief's bar (every Path improves, cave 80 %+) is not met. If the
flood feeling is what matters, the levers that do not cost tempo are a better fill than extra cheap copies (a cantrip Common) or a
mulligan rule that keeps 2-3 Infrastructure - deck design calls, in the inbox.

## Part 4 - the mid-game critic

A new critic subagent (brief `docs/review/critic_brief_midgame_oct31.md`, no project docs) played from a level-8 Gourmand snapshot
(`midgame_l8`: Gainlands freed, 1020 gold, nine packs) through Crosspath's packs, Deck Station and shops, the D.N.A. and the Hall of
Final Approvals, the Endless Buffet and the Test Kitchen, the Verdant Dump and the Rotheart, the Capital, Vivienne Quota and Primm's
first phase: 18 runs, ~2.5 h, 52 shots, no script errors. Report: `docs/review/fresh_eyes_midgame_oct31.md` (shots in
`docs/review/fresh_eyes_midgame_oct31/`). It could not open Primm's Castle's map or a side dungeon (the dev jumps did nothing after a
`dev encounter`), never found the Hall of Records, the item / equipment vendors or the tailor, and the Test Kitchen boss never started
inside its budget (eight story stills).

**Caveat: the snapshot was weaker than a real level-8 player.** It came from a forest save taken before the cave: the Forgotten Cave was
never cleared (Sable's stall, gated on it, stayed locked; Maren's quests never started), the deck was the bare 45-card starter, and
loading it resumed in the forest. Findings 1, 6 and part of 2 come from that (triage below). The snapshot script now sets the flag.

| Area | Score | Area | Score |
|---|---:|---|---:|
| Clarity | 5 | Story and humour | 7 |
| Pacing and friction | 4 | Visual cohesion and readability | 7 |
| Combat depth and feel | 5 | UI/UX consistency | 4 |
| Deck-building satisfaction | 6 | Audio | n/a |
| Reward rhythm | 4 | Performance | 6 |
| Exploration and world | 5 | Bugs | 4 |
| | | **Overall** | **5.2** |

Its top 15, one line each, with the triage verdict (`docs/review/fresh_eyes_midgame_triage_oct31.md`):

| # | Problem | Verdict | Tonight |
|---|---|---|---|
| 1 | The card vendor sells nothing at L8 | artefact (stall gated on the cave the snapshot never cleared) | snapshot fixed |
| 2 | Boss fights stall; the deck has no clock | partly / conflicts (bare starter at L8; balance needs sim evidence) | recommendation |
| 3 | Five different "continue" conventions | valid | Fix 1 |
| 4 | Maps do not help find anything | partly (fog by design; labels a design call) | recommendation |
| 5 | Pre-boss funnel long and layered | conflicts (stills frozen; rules card is a decision) | Fix 2 in part |
| 6 | Quest log empty while the HUD nags | artefact (cave never cleared) | - |
| 7 | Character screen is five padlocks | partly (hint on hover exists) | recommendation |
| 8 | Pack opener stacking; dead hotkeys | valid / artefact | Fix 3 |
| 9 | Doubled label, nameplate wrap, "-3" over YOU | valid | Fixes 6, 7 |
| 10 | Three HP numbers | partly / conflicts (each pool is a rule) | recommendation |
| 11 | Mortimer's defeat screen silent | artefact (the shot was the banner; the panel with the recap followed); the gold "..." button was real | Fix 5 |
| 12 | Tutorial tips in L8 boss fights | valid | Fix 4 |
| 13 | Rules popup overload, duplicate line | valid | Fix 2 |
| 14 | D.N.A. lobby looks greybox | valid, needs art | recommendation |
| 15 | Clicking a node only shows its tooltip | partly (click twice by design) | recommendation |

What it praised: the dungeon maps, the pack table and LEGENDARY flash, the boss intro splashes, the event writing (Agnes Overdue,
Mortimer), Compostella's fight, the Deck Station (filters, caps, keyword panel), and the "What beat you" panel from Part 2.

## Part 5 - triage and fixes (commit 7ae5ab5f)

| # | Fix | Where | Shots (`docs/review/fresh_eyes_fixes_oct31/`) |
|---|---|---|---|
| 1 | **One Continue rule**: `ConfirmKey.attach` - E / Enter / Space / pad A press the button (0.4 s guard) on the pre-fight rules card (both copies), the event result (now focused) and announcement cards | `ui/widgets/confirm_key.gd`, `rules_brief.gd`, `dungeon_map_screen.gd`, `event_screen.gd`, `announcement_screen.gd` | run `fix31_g`: E on the brief started the Mortimer fight |
| 2 | **Same-named rules merged** into one line ("Red Tape Everywhere: Start each battle with one Red Tape. Also: Starts the duel with 3 Red Tape."); test | `RulesBrief.distinct_by_name / line_text` | `before_boss_brief_duplicate.png` / `after_boss_brief_merged.png` |
| 3 | **One pack ceremony at a time** (Open while one is up does nothing) | `PackOpeningScreen.open_from_inventory` | `before_pack_double_open.png` / `after_pack_double_open.png` |
| 4 | **No tutorial tips in boss fights** | `BattleScreen` (`context.is_boss`) | `after_boss_fight_no_tips.png` |
| 5 | **No gold "..." button** (hidden during the mulligan and after the fight) | `BattleScreen._refresh_ui` | `before_boss_defeat_dots.png` / `after_boss_defeat_recap.png` |
| 6 | **The baker labelled once** | `TownScene` (spot label skipped for the wandering baker) | `before_baker_double_label.png` |
| 7 | **The HP loss number rises above the plate**, not over "YOU" | `BattleBoard._on_hp` | `after_boss_fight_no_tips.png` |

Harness: `dev flag <name> [off]` in the play driver (`docs/play_script.md`); `midgame_snapshot.txt` sets `trial_cleared` and the
snapshot resumes in Crosspath (`after_snapshot_resumes_in_town.png`). Checks: GUT ui 252, root 286, world 424 (all green); Crosspath
walk smoke OK; first-battles smoke OK twice (the first run listed the intro tip late - timing; the rerun had it first); driver runs
`fix31_f` (snapshot, packs, D-HFA) and `fix31_g` (the boss brief by E, the fight, the defeat recap on Mortimer).

## Recommendations that need art, dialogue or a design call

- **Design / balance (sim first)**: the mid-game boss stalls the critic saw came from a bare starter at L8, but a soft clock (a late-turn
  rule) or an AI that prefers units over a fourth Tool on an empty board are worth a sim pass; the starter study's levers (a cantrip
  fill, a mulligan rule) for the flood feeling.
- **Maps**: name buildings and vendors on the town map, a distinct dungeon-entrance icon, the hub revealed once visited, a "Where to?"
  list in the legend.
- **Character screen**: print each locked slot's unlock hint on the slot (it is only on hover now).
- **Dungeon nodes**: "Click again to go" in the node preview.
- **HP pools**: a banner when the max HP changes (zone, Capital, boss).
- **Boss nameplate**: long names ("Mortimer Grimsby, CE-No.") wrap over the heart; a second shrink step or a wider label.
- **Pre-boss story**: the Test Kitchen's eight stills (frozen; dialogue edit) - fewer stills, no dialogue box over a still.
- **Art**: the D.N.A. lobby's dressing density (a ceiling / fog plane, wall dressing); ICON-UI art for Glossary / Feats in the HUD menu.
- **Dialogue**: nothing new tonight needed a line change, so no `lines_to_update_oct31.csv` was written; the Oct 30 CSV still stands.

## Inbox (Fresh eyes round 2)

See `docs/overnight_inbox.md`, section "Fresh eyes round 2".
