# Overnight Oct 18 - scorecard

Scores 1-10 with the evidence behind each. "Start" = Phase 2 start (after Parts 1-8, Sun Oct 18 ~22:20), re-scored with fresh evidence:
story bot 73/73, full tour bot (275 spots, 9 menus, 5 battles, 0 errors), first-battles / playtest / release smokes, the balance sim
(Parts 1-2), title-card and forest shots. Last night's categories are kept; Balance and Playtest readiness are new. Later columns are
updated by the Phase 2 cycles (`docs/overnight/loop_log.md`). Last night's sheet: `docs/overnight/oct17/scorecard.md`.

| Category | Start | Now | Evidence |
|---|---|---|---|
| Combat feel | 8 | 8 | First-battles smoke at 1x / 1.5x / 2x: 58 fps lowest while animating; auto-end turn works (4 / 6 / 1 turns ended by themselves); end-turn warning names the energy left. Unchanged otherwise since Oct 17 (wind-ups, scaled numbers, card-play arcs). |
| Visuals - starting forest | 8 | 8 | Rebuilt today (Opening Forest): teal dusk, lantern pool, cave glow; the purple top-edge shapes are gone (on18_forest_top). Reads dark at the screen edges. |
| Visuals - Crosspath (town) | 8 | 8 | Unchanged since Oct 17 (square, six storefronts, lake, roamers); tour bot 0 errors. |
| Visuals - Gainlands | 8 | 8 | on18_card_gainlands: the bridge, gym gate, banners read well; the title card's flourish sits under the ribbon. |
| Visuals - D.N.A. | 7.5 | 7.5 | Unchanged since Oct 17. |
| Visuals - Endless Buffet | 7.5 | 7.5 | Unchanged since Oct 17 (the gravy moat is still a flat plane in front). |
| Visuals - Verdant Dump | 7.5 | 7.5 | Unchanged since Oct 17. |
| Visuals - Capital | 8 | 8 | Unchanged since Oct 17. |
| UI consistency | 8 | 8 | Zone and dungeon arrival cards in the banner style with a Path icon + subtitle; Report a Problem form; settings rows for the battle options. Still: several screens hand-style their choice tiles. |
| Onboarding / tutorial | 7.5 | 7.5 | Playtest smoke (forest -> Path -> cave -> Crosspath -> fight -> level 5 -> armory) OK; tracker names the area of a step elsewhere ("Go to the Gainlands"). Tutorial clears 71-88% per Path with the new starters (Necrocrat lowest). |
| Rewards & progression feel | 8.5 | 8.5 | Unchanged; items now once per battle (a cap, not a reward change); Alchemist reachable sooner (6 essence). |
| Collection / bestiary | 7.5 | 7.5 | Unchanged (enemy pictures still missing). |
| NPC life & dialogue | 8 | 8 | Unchanged; the dialogue presentation plan is written (Part 5). |
| Audio mix | 7.5 | 7.5 | Unchanged since Oct 17. |
| Performance | 7.5 | 7.5 | Tour bot: town 82 frames over 33 ms (Oct 17 end: 30-39), worst 193 ms (character screen), vendor 192 ms; zones 14-44 over 33 ms, worst 113-173; battles 0. Not a save cost (the bot never saves) and steady town is 60.1 fps (p95 16.7 ms): the slow frames sit in first menu opens, 2-5 each (bot report per action). |
| Stability | 8.5 | 8.5 | Story bot 73/73, tour bot 0 errors / 0 warnings, smokes OK, GUT 1888/1888 - the long-failing camera test passes everywhere now. |
| Balance (sim evidence) | 5 | 6 | Cycle 2: four late elites into or near band (Castle 75/54/58%, Lab 75%), Betty 63%, Bellows 71%. Cycle 1: Casserole 42 -> 73% (in band), Prudence 38 -> 53%. Part 2 end table (balance_log.md Part G): in band normals 35/54, elites 6/21, bosses 5/19; late elites/bosses mostly too easy, early Beefcake/swarm fights too hard; starting decks 52/57/47/44 at L1 (spread 13); gear lifts +0..+10 at L5, model gear +41 at L12. |
| Playtest readiness | 7 | 7 | Report a Problem (F8 / pause): screenshot, log, save copy, area + quest, opens the folder; crash-safe saves with a backup; autosave on area change, after battles and quest steps; version on title + pause. First hour: the Gainlands roamers are the first wall (58-75% for the AI at L5). |
