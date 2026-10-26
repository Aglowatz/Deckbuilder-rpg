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
| 1 - card set review (proposals) | todo | out: `docs/design/card_review_oct25.csv` + `.md` |
| 2 - graphics Tier 2 | todo | out: `docs/art/graphics_tier2.md`; one commit per feature |
| Phase 2 - polish cycles | todo | log: `docs/overnight/loop_log.md` |
| Morning report | todo | `docs/overnight_report.md` |

## Scratch
- Budgets: `bash tools/perf_budget.sh structure` (1 min headless), `bash tools/perf_budget.sh frame <areas> "0 1"` (windowed).
- Shots from the fixed spots: `bash tools/tier1_shots.sh <tag> [areas]` -> `docs/art/graphics_tier1/<tag>/`; fps `bash tools/tier1_fps.sh <tag> ["0 1 2"] [areas]`.
- Sim: `Godot_console --headless --path . -s res://tools/run_balance_sim.gd -- --what=encounters --filter=<group> --games=N --seed=7000 --out=res://docs/design/sim/<name>.md`.
