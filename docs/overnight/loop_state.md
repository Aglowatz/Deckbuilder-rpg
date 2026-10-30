# Fresh-eyes critique + fix Oct 30 (Fable) - loop state (resume from here)

Start: Fri Oct 30 ~18:00 MDT 2026. Previous run's state: `docs/overnight/oct30/loop_state_xp_oct30.md` (XP pass, v0.4.8); its report
`docs/overnight/oct30/overnight_report_xp_oct30.md`. Questions: `docs/overnight_inbox.md`, section "Fresh eyes Oct 30".

Rules: one Godot process at a time, foreground; GUT in groups (`bash tools/gut_group.sh root|core|ui|world`); per fix GUT + walkability +
walk smokes + first-battles smoke + `bash tools/perf_budget.sh structure` + commit + push; revert what can't pass. Old saves keep loading;
no enemy intent; no new art; black market untouched. DIALOGUE FREEZE (data/story/*, story_scenes.json, old_well_story.json, npcs.json,
boss_intros.json, encounter_scripts.json, dungeon_content.json text, core/quests text, story_beats.gd): rewrites go to
`docs/dialogue/lines_to_update_oct30.csv` (ID as in `docs/dialogue/edit_oct27.csv`). Black market, prices, XP curve: only with sim evidence.

## Plan

| Part | What | Output |
|---|---|---|
| 0 | Play-script driver so a critic can play from the title (`bash tools/play.sh <script> [name] [limit]`, `tools/play_script.gd`, doc `docs/play_script.md`) | commit |
| 1 | Critic subagent (no project docs, brief `docs/review/critic_brief_oct30.md`): 4 Paths x first 90 min + later samples, scores, top 20 | `docs/review/fresh_eyes_oct30.md` + `docs/review/fresh_eyes_oct30/` |
| 2 | Triage against CLAUDE.md, report, design docs, inbox; pick 10 safe fixes | `docs/review/fresh_eyes_triage_oct30.md` |
| 3 | Fix the 10, one at a time, each verified + committed; then first battles smoke, story bot, tour bot | commits |
| 4 | Second critic subagent on the changed areas + first 30 min of one Path | `docs/review/fresh_eyes_second_look_oct30.md` |
| Report | `docs/overnight_report.md` | final commit + push |

## Progress

| Part | State | Commit | Notes |
|---|---|---|---|
| 0 | done | (first commit) | title -> slot 3 -> wake-up -> Path choice -> cave; `pilot` plays a battle (Got it / Skip tips / End Turn confirm); `dev save/load` snapshots |
| 1 | - | - | |
| 2 | - | - | |
| 3 | - | - | |
| 4 | - | - | |
| Report | - | - | |

## How to resume (Opus)

1. Read this file, then `docs/review/fresh_eyes_oct30.md` (if it exists) and `docs/review/fresh_eyes_triage_oct30.md`.
2. Continue at the first Part whose State is not "done". Per fix: the GUT group(s) touched + `bash tools/run_first_battles_smoke.sh` +
   the walk smoke of any scene touched (`tools/run_crosspath_walk_smoke.sh`, `run_hub_walk_smoke.sh`, zone walks) +
   `bash tools/perf_budget.sh structure`, then commit + push.
3. A critic is a fresh `general-purpose` subagent given ONLY `docs/review/critic_brief_oct30.md` (it runs Godot itself through
   `tools/play.sh`; run nothing else that starts Godot while it works).
