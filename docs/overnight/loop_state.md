# Overnight Oct 30-31 (Opus): eight improvements + v0.4.9 - loop state (resume from here)

Start: Fri Oct 30 22:13 MDT 2026. Tag `pre-overnight-oct30b`. Questions: `docs/overnight_inbox.md`, section "Overnight Oct 30-31".
Brief: Parts 1-8 (each <= ~75-80 min), Part 9 = v0.4.9 build (last 75 min reserved, always done). Previous state archived as
`docs/overnight/oct30/loop_state_fresh_eyes_round2.md`.

Rules: STOP_OVERNIGHT check per part; one Godot at a time, foreground; <= 12 shots per part; GUT in groups (`bash tools/gut_group.sh
root|core|ui|world`); per part GUT + walkability + walk smokes + first-battles smoke + perf budgets + memory round-trip smoke + commit +
push. Old saves load; NO enemy intent; no new art; black market untouched; prices / XP / starters / bosses only with sim evidence (no
mulligan, no boss clock). DIALOGUE FREEZE (new UI text in new keys; rewrites to `docs/dialogue/lines_to_update_oct31.csv`).
Disk: 5.2 GB free at start; RAM ~2 GB free at start.

## Progress

| Part | What | State | Commit | Notes |
|---|---|---|---|---|
| 1 | Mid-game critic rerun from a story-bot snapshot, triage, 4-6 fixes | in progress | | snapshot: `bash tools/run_story_playthrough.sh --snapshot_after=2 --snapshot=midgame_real` |
| 2 | Goal pointer everywhere | todo | | |
| 3 | Fast travel + sprint | todo | | |
| 4 | Attack previews | todo | | |
| 5 | Faster loading | todo | | |
| 6 | Dialogue presentation | todo | | |
| 7 | Smarter Deck Station | todo | | |
| 8 | Sound pass | todo | | |
| 9 | v0.4.9 build | todo | | |
| Report | docs/overnight_report.md | todo | | |

## How to resume

Read this file; continue at the first Part not "done"; check the clock against the time rule (Part 9 needs the last 75 min).
