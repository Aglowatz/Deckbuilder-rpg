# Loop state - Overnight Nov 7-8 (Opus 5.5)

Brief: docs/prompts/overnight_nov7.md (Parts 0-9 + Finish, in priority order). Tag `pre-overnight-nov7` at the start.
Questions/decisions: docs/overnight_inbox.md ("Overnight Nov 7-8"). Report: docs/overnight_report.md. Shots: docs/overnight_shots/nov8/.
Sims: docs/design/sim/nov8/. Stop when STOP_OVERNIGHT exists in the repo root. Previous state: fixes_nov7 (see git history). NO export.
Single-file GUT runner used: godot --headless -s res://addons/gut/gut_cmdln.gd -gconfig= -gtest=res://tests/x.gd -gexit

| Part | What | State |
|---|---|---|
| 0 | Leftovers (fixes_nov7 + critic CF) | done: cave ramp 3->5->9 (94-100 % clears), capped reward pick (no double grant, AT CAP tag + text), shop buy says collection + Deck Station, Fennel out of the trees, Brannoch clear of the travel trigger (1.8), battle toast cleared on phase change, unopened pack count under Menu |
| 1 | Playtest bugs (11 items) | done: Peek modal layer 29 + dim (test), gatekeeper quests from Maren after the armory (PathDirection.FLAG gate, intro-step tracker line, not-yet lines, old-save migration), send-off + cave-mouth lines rewritten, 1987 cut (2), store room ghosts darker + Maren lines, Capital debuff tutorial + Glossary, "(full heal)" off exits, Brannoch moved (Part 0), Swolympus crag + flood test, Pip x1.5, pack results zoom on hover/focus |
| 2 | Economy | done: cards 50/100/250/500, gear 250-1150, packs 100/150/175/350/400, income 21.2k -> 11.3k (knobs in Economy/QuestCatalog/EncounterRewards/PackConfig), late fights x(1+0.15/level from 18), checkpoint ~700 vs 590 (test), collection +33 % est (tools/gold_study_nov8.gd), Extra Pocket = items twice per battle (ITEM_USES_PER_BATTLE) |
| 3 | Story finale | done: 58 rows via apply_dialogue_pass (docs/dialogue/pass_nov8/edit_rows.csv, revertible) + 3 new boxes (additions.md: Memory 4 absolution, Elowen in the Lab at beat 10, Clipwell walks off); castle opens; Quota arrested, Clipwell refuses, Crumb works; review CSV docs/dialogue/edit_nov8.csv; story tests green |
| 4 | Balance retune | edits in, sims pending: Clench Iron 1, Snack Bar (B) +2/+0, B-24 2/4, Surly +2/+1, Automaton -C-33, no Honor Guard Militia, ZoneOrderEase floor 0.65 + ease by places, Siphon alone drops Containment, castle main line 6 rooms, L18+ normals pick, Gallery owners + Perfect Form on 11-12 only + node 10 elite |
| 5 | UI redesigns | pending |
| 6 | Minigames | pending |
| 7 | Load times + Low-end | pending |
| 8 | Primm write-up | pending |
| 9 | Art list | pending |
| Finish | shards, critic, report | pending |
