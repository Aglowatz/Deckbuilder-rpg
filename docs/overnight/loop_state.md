# Overnight Oct 25 (b) - loop state (resume from here)

Start: Sun Oct 25 22:13 MDT 2026. Stop by ~06:13 MDT Mon Oct 26 (8 hours). Start tag: `pre-overnight-oct25b` (pushed, = f8dc126b).
Brief: `docs/overnight/oct25b/brief.md`. Previous loop state archived: `oct23/loop_state_oct23.md`; last report copy
`oct25b/prev_overnight_report_oct23.md`. Session model: Fable 5.1 (if the allowance runs out, continue on Opus from this file).

Rules in force: STOP_OVERNIGHT check per part/cycle; one Godot process at a time, foreground, close between runs; <= 10-12 shots per
part; GUT in groups (`bash tools/gut_group.sh root|core|ui|world`) + walkability + walk smokes + `bash tools/perf_budget.sh` + commit +
push per part, revert what can't pass; old saves keep loading; no enemy intent; NO new art generation; black market vendors untouched;
NO version bump or export tonight. Part 1 is PROPOSALS ONLY (no game/data/sheet change).

## Parts
| Part | Status | Notes |
|---|---|---|
| 0 - setup | done | tag pushed, brief copied, old loop state archived |
| 1 - card set review (proposals) | done 22:36 (29 changes + 14 new cards; no game change, so no GUT/smokes for this part) | out: `docs/design/card_review_oct25.csv` + `.md`; generator `_logs/card_review_oct25.js` (ignored); sims `docs/design/sim/review_*.md` |
| 2 - graphics Tier 2 | features done + committed: f1 height fog 669b0718, f2 bounce fd4ec9ab, f3 wind 43015ac7, f4 water a17851a5, f5 lanterns ca482c83, f6 FSR2 465bdba4, test/doc 15a53b2c; SSAO dropped (measured), vertex AO + decals already present. Verification: GUT all groups green (banner hang test updated), 7 walk smokes OK, structure budget OK; frame budget + after shots + after fps: see report | `docs/art/graphics_tier2.md` (fps + checks sections to fill); before shots `docs/art/graphics_tier1/t2_before/`, fps `fps_t2_before.md`; per-feature shots `docs/art/graphics_tier2/f<N>_*/` |
| Phase 2 - polish cycles | NOT started: the session dropped ~00:06, resumed 08:05 (past the 8 h window) | log: `docs/overnight/loop_log.md` (no entries) |
| Morning report | written 08:30, fps table + checks to fill from the final runs | `docs/overnight_report.md`; inbox section "Overnight Oct 25-26" |

## Scratch
- Budgets: `bash tools/perf_budget.sh structure` (1 min headless), `bash tools/perf_budget.sh frame <areas> "0 1"` (windowed).
- Shots from the fixed spots: `bash tools/tier1_shots.sh <tag> [areas]` -> `docs/art/graphics_tier1/<tag>/`; fps `bash tools/tier1_fps.sh <tag> ["0 1 2"] [areas]`.
- Sim: `Godot_console --headless --path . -s res://tools/run_balance_sim.gd -- --what=encounters --filter=<group> --games=N --seed=7000 --out=res://docs/design/sim/<name>.md`.
