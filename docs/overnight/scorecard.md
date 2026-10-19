# Daytime Oct 19 - scorecard

Scores 1-10. "Start" = last night's end (`docs/overnight/oct18/scorecard.md`); "Now" = end of the daytime run (Mon Oct 19 ~11:00). Only the
rows that moved carry new evidence; the rest are unchanged since last night.

| Category | Start | Now | Evidence |
|---|---|---|---|
| Combat feel | 8 | 8 | Unchanged; first-battles smoke OK. |
| Visuals (forest, Crosspath, four zones, Capital) | 8 | 8 | Unchanged. |
| UI consistency | 8 | 8.5 | Part 5: the Path choice, the equipment-slot choice and the Collection Book share one kit tile (`UiSkin.choice_tile`, parchment ring when selected); "Before the fight" brief reused outside the maps (`RulesBrief`); five missing rule icons fixed; "Choose your Path" (was "element"). |
| Onboarding / tutorial | 8 | 8.5 | Part 2: cave runs Necrocrat 82 -> 92, Gourmand 80 -> 90 (Beefcake 92, Refusemancer 82). Part 3: New Game -> first saved deck edit ~10.6 min for every Path (97 clicks/keys, 31 lines); the first deck save no longer needs a pointless change; the quest text matches. |
| Rewards & progression feel | 8.5 | 8.5 | Unchanged. |
| Collection / bestiary | 8 | 8 | Unchanged (new tile look). |
| NPC life & dialogue | 8 | 8 | Unchanged. |
| Audio mix | 7.5 | 7.5 | Unchanged (listen pass pending). |
| Performance | 9 | 9.5 | Part 4 + cycle 2: the first screens are built under the loading cover; full tour first opens <= 128 ms (character screen 345 -> off the list, vendors 245-254 -> 74-119, Deck Station 150 -> 128); zones 63-72 ms worst. |
| Stability | 8.5 | 8.5 | GUT 1907/1907, story 73/73, tour 0 errors; playtest, release, prologue, first-battles, gatekeeper (refreshed) and new boss-rules smokes OK. One regression found and fixed the same morning (warming used up the shops' tips; v0.4.1 rebuilt). |
| Balance (sim evidence) | 8 | 8 | Part 1: Shiro 88 -> 48% (his rules had never applied), Bellows 77 -> 56% (Heckling Crowd), Processing Time softened (Necrocrat +8-16 pts in the House of Gains). Open: Primm's three phases with boons unmeasured, L5 Necrocrat Gainlands 25-42%. |
| Playtest readiness | 8 | 9 | v0.4.1 built and smoke-tested on the exported pack (15/15); feedback log + `feedback_row.js` (single / batch / default folder, guesses category and severity, [Path Lx]); F8 reports name the hero's Path, deck, fights won and zones freed. |
