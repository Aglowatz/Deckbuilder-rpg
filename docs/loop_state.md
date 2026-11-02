# Loop state - Capital sides pass (Nov 2, Fable 5.1)

Brief: pasted "CAPITAL SIDES PASS (follow-up to the inner-city rebuild)" (items 1-7). Questions: `docs/overnight_inbox.md` ("Capital sides Nov 2").
Report: appended to `docs/art/capital_rebuild_nov1.md` ("The sides pass, Nov 2"). Tag `pre-capital-sides-nov2` at the start.
Stop when `STOP_OVERNIGHT` exists in the repo root (check before every part).
Rules: one Godot at a time; <= 3 agents and never while Godot/tests run; GUT sharded (`bash tools/run_tests.sh --only=...`); verify + commit + push
per part; DIALOGUE FREEZE; existing art only (kit textures/meshes; code-built geometry); gameplay keeps working (NPCs, talk spots, quests, rifts,
district service states, the Crease, tram, roamer routes, walkability probe, Capital world tests); perf inside budget on Medium (capital_in 850
draw calls); tall masses never hide the hero (occlusion fade; statues and fountains never fade).
Previous state: `docs/overnight/nov1/loop_state_rebuild.md` (the inner-city rebuild, Nov 1-2).

What the user's screenshot shows (matched to `docs/art/capital_rebuild_nov1/c6/the_reek.jpg`): the Reek from its paint-over camera - the two
Reek yards' rear walls seen edge-on (the "pink-capped gateposts"), the lane planters' topiary cards and rose beds on the district checker (the
"scatter"), the yards' bins / bags / rubble card (the "black objects"), the compost heap pickup (the "brown mud disc"), the empty Reek floor
against the west wall.

Plan (sides = everything inside the wall west of the ring_w street and east of ring_e: Grave Row, the Reek, the Ward, the Hungry Quarter, the
Transit Yards):

| Part | What | State |
|---|---|---|
| 1 | Scatter: rows / lane cards only on LAWN cells; lanes and separators get continuous white planter runs instead; restored-state blooms in rows; the compost heaps, the sick patch, the junk, the yards' bins, the crates restyled white-and-gold (no near-black surface inside the wall); tests: scatter on paving = 0, no near-black surface inside | done (434.8 -> 0.31 m2 near-black; sides test green) |
| 2 | Buildings: the Reek yards, the Grave Row crypts and the Hungry stalls become CapitalGrand townhouses (wide, 3-4 storeys) with their district's service layer at the foot (broken / restored); the district "spire" pylons dropped; the plaza-corner spires become gate piers (plinth, pilaster, gilded urn); the inner faces of the west, east and north walls dressed with a blind arcade, attached facades and engaged towers in rhythm | done (`world/capital/capital_sides.gd`) |
| 3 | Side plazas at the boulevard / lane junctions (19, 58) and (100, 58): a two-tier side fountain variant, a gilded statue pair each, a paving disc with ring borders; the routes end at the rim; moved props (chest_reek, the junk, the inspector, the transit rift, the wheels, the pylons) | done |
| 4 | Gardens: parterres and topiary-urn rows on the district lawns, planter runs along the separators, small statues in niches, wall basins; lane lamps in rows | done (grid gardens yield little: blocks crowded; two hand beds on Grave Row) |
| 5 | Tests (world + core shards), walk smoke, walkability probe, perf frame capital_in | |
| 6 | Shots (the standard set + a side shot at the user's angle each side), contact sheet, fresh critic on the SIDES; fix the lowest, repeat | |
| 7 | Report: before/after gallery, scores, perf, tests; commit + push | |
