# Loop state - Capital inner-city rebuild (Nov 1-2, Fable 5.1)

Brief: pasted "CAPITAL INNER-CITY REBUILD (overnight)" (Parts A-G). Questions: `docs/overnight_inbox.md` ("Capital rebuild Nov 1-2").
Report: `docs/art/capital_rebuild_nov1.md` (before/after, scores per iteration, perf, art requests); summary in `docs/overnight_report.md`.
Tag `pre-capital-rebuild-nov1` at the start. Stop when `STOP_OVERNIGHT` exists in the repo root (check before every part).
Rules: one Godot at a time; <= 3 agents and never while Godot/tests run; GUT sharded (`bash tools/run_tests.sh`); commit + push per part;
DIALOGUE FREEZE (no line changes). Art rule: only art already in the game or approved on Drive; new geometry in code is encouraged.
Previous state: `docs/overnight/nov1/loop_state.md` (the Fable pass Nov 1).

Target: `docs/art/paintovers/PAINTOVER-CAP-INNER-CITY.png`. Shots: `bash tools/capital_rebuild_shots.sh <phase> [prefixes] [--flags=...]` ->
`docs/art/capital_rebuild_nov1/<phase>/`. Scoring: a fresh critic agent sees only the reference and the shots
(`docs/review/critic_brief_capital_nov1.md` -> `docs/review/capital_critic_<phase>.md`).

| Part | What | State |
|---|---|---|
| A | Audit + plan (before shots, the plan in the report) | done (fc73c016) |
| B | The kit: townhouse generator, towers, plinth + gilded statue, fountain, planters/urns/topiary, lamps, banners, paving borders, balustrades; lineup shots | done (`world/capital/capital_grand.gd`, `tools/capital_lineup.tscn`; 663bf3af) |
| C | Layout: boulevard, plazas and gardens with strict symmetry; buildings and towers; skyline stepping to the castle; the scatter removed | done (663bf3af, b69feace): 16 townhouses on the old footprints, towers, statue pairs, parterres, paving + borders, skyline beyond the walls |
| D | Light + atmosphere | done: four grade passes (see the report); the sky's horizon band bluer |
| E | Gameplay + perf checks | done: world 431/431, core 1564/1564 after moving the Transit tower off a Tidy-Bot home and dropping the Ward tower (it cut the strip to the Ward chest), walk smoke OK, capital_in Medium 1004 -> 847 draw calls (budget 850) |
| F | Compare + iterate with a fresh critic | c2 -> c5 scored (4/5/4/2/7/4/6/3/4 -> 6/7/6/4/7/6/7/4/5); towers (4) and light (4) are bounded by the play camera's six degrees of sky (inbox 4) |
| G | Finish: gallery, scores, perf, art requests, commit + push | done (c6 6/6/5/4/7/6/7/4/5; report, overnight report, inbox 1-4) |
