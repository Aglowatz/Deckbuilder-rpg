# Fresh eyes round 2 (Fable, overnight Oct 31) - loop state (resume from here)

Start: Sat Oct 31 ~02:30 MDT 2026 (after the Oct 30 fresh-eyes run; its state `docs/overnight/oct30/loop_state_fresh_eyes_oct30.md`,
its report archived as `docs/overnight/oct30/overnight_report_fresh_eyes_oct30.md`). Questions: `docs/overnight_inbox.md`, section
"Fresh eyes round 2". Target 9 hours, autonomous.

Rules: one Godot process at a time, foreground; GUT in groups (`bash tools/gut_group.sh root|core|ui|world`); per fix the GUT group(s)
touched + the smoke of the area touched + commit (push after each Part). Old saves keep loading; no enemy intent; no new art; black
market untouched. DIALOGUE FREEZE: rewrites go to `docs/dialogue/lines_to_update_oct31.csv`. No version bump, no export.

## Plan

| Part | What | Output |
|---|---|---|
| 1 | Second critic's problems: confirm popups / Well / duel tips accept E + pad confirm; Path "More" expands; treeline self-talk is a bubble; tooltips never overlap the toast, the preview, the plate, the banner. Cave beacon + reward pre-select stay | commit(s), before/after shots `docs/review/fresh_eyes_fixes_oct31/` |
| 2 | Safe recommendations: readable hand (fan vs smaller scale, shots of both), Settings scrollbar, defeat recap screen, "Tutorial tips" toggle | commit(s) |
| 3 | Starter deck study (sim only): 19 vs 17 vs 15 Infrastructure per Path | `docs/design/sim/starter_infra_oct31.md` |
| 4 | Mid/late-game critic subagent (no project docs), brief `docs/review/critic_brief_midgame_oct31.md` | `docs/review/fresh_eyes_midgame_oct31.md` + shots |
| 5 | Triage the 15, fix 6-8 safe ones, each verified + committed | `docs/review/fresh_eyes_midgame_triage_oct31.md`, commits |
| Report | `docs/overnight_report.md` | final commit + push |

## Progress

| Part | State | Commit | Notes |
|---|---|---|---|
| 1 | done | 13ab312e | ConfirmDialog / TipPanel / ChallengeScreen / TutorialLayer take E (+ Enter / Space / pad A; Space left alone in the duel); Path "More" = Resource + starting deck; treeline bubble (`StartingAreaScene._barks`, `NpcBarks.say`); toast layer 26 at y 585; tooltip re-fit each frame; banner layer 27; bubbles avoid `hud.preview_rect()` / `plate_rect()`. GUT all green, opening forest + first battles smokes OK; scripts `fix31_a*`, `fix31_b*`, `fix31_c` |
| 2 | done | 6d1a96f0 | `BattleBoard.HAND_STYLES` + `hand_style` (compact default; `--hand_style=` on battle shots), Settings scrollbar restyled + body margin, defeat recap (`BattleScreen.defeat_recap_lines`), `Settings.tutorial_tips` (TutorialLayer.wanted / TipPanel.show_once). GUT ui green, scripts `fix31_d`, `fix31_e` |
| 3 | done | e653daed | `docs/design/sim/starter_infra_oct31.md`: keep 19 (fewer basics cut flood turns but add dead turns and cost 1-2 cave points on 3 Paths; only Beefcake's zone improves). Nothing changed. Tool: `tools/starter_infra_study.gd` (32 min for 50 games x 2 seeds: background) |
| 4 | done | 7ae5ab5f | critic report `docs/review/fresh_eyes_midgame_oct31.md` (5.2 / 10, top 15, 52 shots, 18 scripts critic3_*); snapshot caveat (cave never cleared) |
| 5 | done | 7ae5ab5f | triage `docs/review/fresh_eyes_midgame_triage_oct31.md`; 7 fixes (ConfirmKey, merged rules, one pack ceremony, no boss tips, no "..." button, HP float, baker label); GUT ui/root/world green, Crosspath walk + first battles smokes OK |
| Report | done | (final commit) | `docs/overnight_report.md`, inbox "Fresh eyes round 2" 1-12 |

## How to resume

1. Read this file, `docs/overnight/oct30/overnight_report_fresh_eyes_oct30.md`, `docs/review/fresh_eyes_second_look_oct30.md`.
2. Continue at the first Part whose State is not "done". A critic is a fresh `general-purpose` subagent given ONLY its brief
   (it runs Godot itself through `tools/play.sh`; run nothing else that starts Godot while it works).
