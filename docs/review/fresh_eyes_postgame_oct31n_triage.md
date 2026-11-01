# Triage - postgame critic, Overnight Oct 31 -> Nov 1 (first score 3.5/10)

Report: `docs/review/fresh_eyes_postgame_oct31n.md` (55 min, 13 runs, `postgame_real`: L23, Primm defeated; most fights by the weak pilot).

| # | Problem | Verdict | Action |
|---|---|---|---|
| 1 | Quest log empty after the credits | valid, design + text | Inbox: an auto-tracked "Loose Ends" quest (Swolympus, the Lab, the Arena) needs new quest text |
| 2 | Mount Swolympus can't be found or opened; Old Man Mountain gives no prompt | **valid bug (reach)** - his talk spot sits 1.5 m in front of him; standing at his side was out of reach (reproduced; one step south showed "[E] Talk", and he offers "Water for the Hermit", the way up) | **Fixed**: an NPC's own body counts for reach in zones (`ZoneScene.npc_body_position`); re-run: the prompt shows beside him. The same pattern explains the late critic's Spotless and both mid critics' Sable (town reach widened earlier) |
| 3 | Postgame bosses vs a 14-HP hero | partly artefact | The 14 HP is the snapshot's expected gear (Glass Jaw Gauntlets, Crown of Mild Hubris: -7), not a rule. Boss tuning = inbox |
| 4 | Freed zones still apply "the zone HP rule" ("Max 14 here (-7)") | **valid (label)** - the HUD called gear "here" | **Fixed**: "usual max" counts gear and items (`Session.usual_max_hp`); the zone panel and the HP banner only speak of a zone's own rules; the tooltip's first line says "your level" (gear follows as its own lines). No-healing in freed zones = the HP rules design call |
| 5 | The Capital doesn't feel liberated (Crease, Rift popup) | design / dev-jump artefact | Inbox |
| - | Arena 0 of 8, never pointed to | design | Inbox ("Loose Ends") |

Tests: `tests/ui/test_lategame_fixes_oct31n.gd` (+2). Full sharded suite after the fixes: 2540/2541 passed, 1 pending, 0 failing.
