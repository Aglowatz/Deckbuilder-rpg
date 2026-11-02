# Loop state - Capital inner-city rebuild (Nov 1-2, Fable 5.1)

Brief: pasted "CAPITAL INNER-CITY REBUILD (overnight)" (Parts A-G). Questions: `docs/overnight_inbox.md` ("Capital rebuild Nov 1-2").
Report: `docs/art/capital_rebuild_nov1.md` (before/after, scores per iteration, perf, art requests); summary in `docs/overnight_report.md`.
Tag `pre-capital-rebuild-nov1` at the start. Stop when `STOP_OVERNIGHT` exists in the repo root (check before every part).
Rules: one Godot at a time; <= 3 agents and never while Godot/tests run; GUT sharded (`bash tools/run_tests.sh`); commit + push per part;
DIALOGUE FREEZE (no line changes). Art rule: only art already in the game or approved on Drive; new geometry in code is encouraged.
Previous state: `docs/overnight/nov1/loop_state.md` (the Fable pass Nov 1).

Target: `docs/art/paintovers/PAINTOVER-CAP-INNER-CITY.png`. Shots: `bash tools/capital_rebuild_shots.sh <phase> [prefixes]` ->
`docs/art/capital_rebuild_nov1/<phase>/`. Scoring: a fresh critic agent sees only the reference and the shots.

| Part | What | State |
|---|---|---|
| A | Audit + plan (before shots, the plan in the report) | in progress |
| B | The kit: townhouse generator, towers, plinth + gilded statue, fountain, planters/urns/topiary, lamps, banners, paving borders, balustrades; lineup shots | - |
| C | Layout: boulevard, plazas, gardens, buildings, towers, skyline; remove the scatter | - |
| D | Light + atmosphere | - |
| E | Gameplay + perf checks (GUT world + core, walk smoke, walkability, perf_budget frame) | - |
| F | Compare + iterate with a fresh critic until every score is 8+ | - |
| G | Finish: gallery, scores, perf, art requests, commit + push | - |
