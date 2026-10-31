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
| 1 | in progress | | |
| 2 | pending | | |
| 3 | pending | | |
| 4 | pending | | |
| 5 | pending | | |
| Report | pending | | |

## How to resume

1. Read this file, `docs/overnight/oct30/overnight_report_fresh_eyes_oct30.md`, `docs/review/fresh_eyes_second_look_oct30.md`.
2. Continue at the first Part whose State is not "done". A critic is a fresh `general-purpose` subagent given ONLY its brief
   (it runs Godot itself through `tools/play.sh`; run nothing else that starts Godot while it works).
