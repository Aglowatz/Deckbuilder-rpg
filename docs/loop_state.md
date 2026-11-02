# Loop state - Fix + polish pass (Nov 2, Fable 5.1)

Brief: pasted "FIX + POLISH PASS Nov 2 - The Wayward Path" (Parts 1-8). Questions: docs/overnight_inbox.md ("Nov 2 pass").
Report: docs/overnight_report.md ("Nov 2 pass"). Tag pre-nov2 at the start.
Stop when STOP_OVERNIGHT exists in the repo root (check before every part).
Rules: one Godot at a time; <= 3 agents and never while Godot/tests run; GUT sharded (bash tools/run_tests.sh); verify + commit + push per
part; DIALOGUE FREEZE on existing lines (item / UI descriptions are game text and may change - each change listed in the report).
Previous state: docs/overnight/nov2/loop_state_capital_sides.md (the Capital sides pass, Nov 2 morning).

| Part | What | State |
|---|---|---|
| 1 | Art audit: 3D figures -> painted sets or the art list; docs/art/art_needed_nov2.csv (Rescuer redo, Leaf Crown, cutscene stills, greybox, icons, flagged placeholders); "ART LIST READY" at the top of the report | done: 7 swaps (5 guards, patient, Gus), 45-row list, report + shots; commit pending |
| 2 | Capital: no scatter inside the walls on every build path (gate, side passage, fast travel, save load, back from battle, freed, cache); a test per path; side screenshot | done: mood foliage density 0 (capital_inside / capital_freed), test_capital_no_scatter_paths 9/9, side shot; commit pending |
| 3 | Loading times: measure cold/warm, keep the zone alive through a fight, cache layouts, threaded loads, shader pre-warm, loading screen; docs/perf/loading_nov2.md | PARTLY DONE (usage limit): parked scene (back from a fight 0.9-1.0 s, was 2.5-8.6 s), Capital townhouse/tower cache (builder 7.5 -> 4.9 s), loading hold 0.9 s; committed. Left: more Capital/town caching, threaded preload, shader pre-warm, final after-measurement |
| 4 | Usable items + economy: exact descriptions, Scroll of Insight, Reckless Tonic, Field Bandage, high shelf at 17-20; docs/design/items_nov2.md; tests | done: descriptions, Scroll Draw 1, Tonic 30 g, Bandage +0/+2 for the battle, high shelf L17 retuned, LATE/PREMIUM bands, .tres regenerated, test_items_nov2 6/6, docs/design/items_nov2.md |
| 5 | Wardrobe hat try-on scale / anchor unified with the world; screenshots per hat | done: fit.json widths / sinks for Wide-Brim, Wizard, Tricorn, Bowler (world = preview, contact sheets before/after), shots |
| 6 | Crosspath fountain as solid geometry (basin, four pillars, four coloured spouts, ivy, animated water); 4-angle before / after | done: solid KitMesh fountain + fountain_water shader, 4-angle before/after, pillar symbol shot |
| 7 | Reward pack / card art centred on every reward screen; screenshots | done: holder shrink-centre + resize re-centre (reward popup, pack shop), shot |
| 8 | Sharded GUT, walk smokes, perf budget, play-script run, report, commit + push | not run |
