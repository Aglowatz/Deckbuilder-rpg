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
| 1 | Mid-game critic rerun from a story-bot snapshot, triage, fixes | done | ae33e08e, 479ee8f2, f1666de8, 02d53ced, c2590aaf, 0ee91f96 | 5.5/10; fixes: basics tips, SpoilerFree, zone tracks its line, map names, why-not line, HP breakdown, vendor reach, Esc skips seen scenes; boss sim no change |
| 2 | Goal pointer everywhere | done | 28c058d6 | two goals (gold main / blue side), arrows, rings, map dots, legend, setting |
| 3 | Fast travel + sprint | done | 9b7528d7 | Shift / L3 / Always sprint; map > Fast travel; zoom pad -> Share |
| 4 | Attack previews | done | b3c1e0dd, 5eb21f37, 653cb843 | predict_action; chain-aware; HP left |
| 5 | Faster loading | done (partly) | 26611b07 | return to town 7.2 -> 6.0 s; first town / zones unchanged; threaded scene switch dropped |
| 6 | Dialogue presentation | done | 35f84069 | any key, per-letter blips, listener portrait |
| 7 | Smarter Deck Station | done | 089169e1 | curve, mix, filters, works-well-with, Suggest |
| 8 | Sound pass | done | a434016b | dungeon beds, 2 events, loudness tool + 21 moved |
| 9 | v0.4.9 build | todo | | |
| Report | docs/overnight_report.md | todo | | |

## How to resume

Read this file; continue at the first Part not "done"; check the clock against the time rule (Part 9 needs the last 75 min).

## Notes

- 22:20-22:40: the critic's runs loaded untested drafts (stashed when noticed; no script errors in any run).
- Bash heredocs turn \n into real newlines: write edit scripts with the Write tool.
