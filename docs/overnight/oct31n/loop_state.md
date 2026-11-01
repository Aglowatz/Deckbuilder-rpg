# Loop state - Overnight Oct 31 -> Nov 1 (Opus)

Brief: pasted "OVERNIGHT LOOP Oct 31 -> Nov 1" (8 parts + the designer's 11 answers). Questions: `docs/overnight_inbox.md`
("Overnight Oct 31 - Nov 1"). Report: `docs/overnight_report.md`. Tag `pre-overnight-oct31n` at the start.
Stop when `STOP_OVERNIGHT` exists in the repo root (check before every part/cycle).
Rules: one Godot process at a time; <= 3 agents and never while Godot runs; commit + push per part; critics play in a worktree at HEAD;
dialogue freeze (new lines -> `docs/dialogue/new_lines_proposed_oct31.csv`); no art requests in game.
Previous states: `docs/overnight/oct31_dialogue/loop_state.md` (dialogue critic pass).

Start (20:46 MDT): disk was 1.7 GB free -> deleted `builds/_export` (unpacked v0.4.9) + Oct 30 `_screenshots/play` runs -> 4.9 GB.

| Part | What | State |
|---|---|---|
| 1a | push | done (origin was level) |
| 1b | sharded GUT runner | done (2506/2507 + 1 pending) |
| 1c | 37 rewrites (already applied in 657af1f1), labels | done |
| 1d | Spotless pacing, first-view Esc confirm, Doppelganger reveal name, feats re-check on load, boss plate wrap | done |
| 2 | music overlap fix + re-render all | done (509d532f) |
| 3 | perf | partial (83329b97): frame budget done, loading measured not cached |
| 4 | mid-game critic cycle | done: 4.8 -> 5.5 (df634833, cfd95045), docs/review/midgame_cycle_oct31n.md |
| 5 | UX wish list + boss stall AI | done (3a2cbaf5) except D.N.A. lobby dressing |
| 6 | late-game + postgame critic cycles | late 4.5 (fixes 9c3a0181), postgame 3.5 (fixes 1729ed90); second looks running in Part 8 |
| 7 | v0.5.0 RC | done: builds/TheWaywardPath-v0.5.0-windows.zip 762 MB, release smoke + exported playtest OK |
| 8 | keep improving | 3 critic cycles (late 4.6, postgame 4.0, first hour 5.0) + fixes; lobby dressing; dev newgame; re-open guard (5b47569f) |

Next: the inbox design calls (HP/healing, boss tempo, Loose Ends, roofs over the hero, first duel, hand clicks); battle UI leftovers (inbox 17); second look on the first hour.
