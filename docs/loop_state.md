# Loop state - Fable pass Nov 1 (Fable 5.1)

Brief: pasted "FABLE PASS Nov 1 - core gameplay + first hour + designer answers" (8 parts). Questions: `docs/overnight_inbox.md`
("Fable pass Nov 1"). Report: `docs/overnight_report.md` (section "Fable pass Nov 1"). Tag `pre-fable-nov1` at the start.
Stop when `STOP_OVERNIGHT` exists in the repo root (check before every part).
Rules: one Godot at a time; <= 3 agents and never while Godot/tests run; GUT sharded (`bash tools/run_tests.sh`); commit + push per part;
critics play from a worktree at HEAD; DIALOGUE FREEZE on existing lines - new lines go to `docs/dialogue/new_rows_nov1.csv`.
Previous state: `docs/overnight/oct31n/loop_state.md`.

Already done this morning (d2d5fedb, a796eb84): max HP 15 -> 30, Loose Ends quest, opening typos, Doppelganger plate.

| Part | What | State |
|---|---|---|
| 1 | Healing: Crease heal, castle halfway heal node, Capital drain toast names its source | done (the Crease tea and the Safe Room already existed: made findable + reachable; toast names rift/roamer; tests + 2 play scripts) |
| 2 | Boss tempo (setup_turns) + Wild Growth cap + boss sims + tuning | done: 17/22 in band; Primm phases 83/100/67 (gauntlet 47 %), Spotless 67, Siphon+Elowen 100, arena 100 left (inbox); docs/design/sim/bosses_nov1.md |
| 3 | Dungeon-clear XP bonus + curve recheck | done (DungeonClearBonus 0.5 / 0.15 of a level; expected +1 at the Dump/castle) |
| 4 | Escoffina / Doppelganger / Grand Chef naming | done (REVEALS name Escoffina, boss intro never reveals, formerly/posing handling, plate_for; inbox 4) |
| 5 | Roamers stop hurting once freed | done (ZoneEnemy.peaceful via ZoneEnemies.is_peaceful/is_freed; Capital on primm_defeated, rifts close) |
| 6 | First hour: first duel, click-to-play, roofs fade, fountain, starter study, critic | a-e done (23c02536, eda8d80e); critic 12 running from /c/Dev/wp_critic (brief critic_brief_firsthour_nov1.md) |
| 7 | Yes-to-all list | done (33dc7eeb) except the Spotless repro (walk blocked) |
| 8 | Verify + build v0.5.1 | Loose Ends checked, saves made, suite green, v0.5.1 exported + smokes PASSED; critics 13 running (mid, late, post in sequence from /c/Dev/wp_critic) |
