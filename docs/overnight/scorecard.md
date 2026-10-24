# Overnight Oct 23-24 - scorecard

Scores 1-10. "Last" = the Oct 22-23 scorecard's end (`docs/overnight/oct22/scorecard_oct22.md`); "Phase 2 start" = after Parts 1-6
(Fri Oct 23 ~23:30); "End" = the morning.

| Category | Last | Phase 2 start | End | Evidence |
|---|---|---|---|---|
| Combat feel | 8.5 | 9 | | Every boss/elite has scripted events (banner, line, warning), boss entrances, status help in tooltips. |
| Visuals | 9 | 9 | | Unchanged (no new art). |
| UI consistency | 8.5 | 8.5 | | Amber scripted badges in the same RuleIconRow; Glossary and slot screens use the shared panels. |
| Onboarding / first hour | 9 | 9 | | 4 new first-time tips; gatekeepers' events are mercy moments; tutorial 88/90/88/100. |
| Rewards & progression feel | 8.5 | 9 | | 1-of-3 themed card pick after every elite/boss (world + dungeons), smaller on repeats. |
| Collection / bestiary | 8.5 | 8.5 | | Unchanged. |
| NPC life & dialogue | 9 | 9 | | 64 new boss lines in voice; 28 entrance lines. |
| Dialogue & story | 9 | 9 | | Mercy moments tie to each boss's arc (Clench "Master...?", Compostella's tree, Primm). |
| Audio mix | 7.5 | 7.5 | | Stings reused for entrances; no listen pass possible. Skipped by rule. |
| Performance | 8.5 | 8.5 | | Unchanged; ~33 MB per Crosspath visit leak still open (next_up). |
| Stability | 9 | 9 | | GUT 2221/2222 (+1 pending); story bot 90/90; playtest, release, first-battles, boss-rules smokes OK; a test that overwrote the real Slot 1 fixed. |
| Balance (sim evidence) | 8.5 | 8.5 | | All elites/bosses on two seeds; Mortimer 34 / Itamae 38 two-seed means. |
| Playtest readiness | 9 | 9 | | No build tonight (by rule); three save slots. |

## Cycles
1. **Balance** (23:39, 9e56be59): Mortimer's Temp Agency +1/+1 -> +1/+0: 44/25 -> 69/38 on two seeds (mean 53). The Itamae's 3-Ingredient
   start measured 44/31 (no change) and reverted.
2. **UI consistency** (bf1b7024): the "Before the fight" brief lists scripted events under an amber "What can happen in this fight (once
   each)" heading (shot `docs/overnight/oct23/c2_brief_bellows.png`); boss-rules smoke OK.
3. **Collection / bestiary** (c65ba68a): a met boss's Bestiary page lists its "Signature moves" (its scripted events); test.
4. **Performance** (measured, no change): AI think time with scripts on Clench / Compostella / Bellows: avg 0.5-23 ms, max 0.48 s, none
   over 1 s - the same as the Oct 23 AI baseline (the clones carry the script runs at no visible cost).
5. **Combat feel** (Part 3 leftover): in Crosspath the camera pushes in (0.75 s) on the hero facing the foe before the gatekeepers, the
   Restless Dead, Shiro and the Echo, then the board entrance plays; boss-rules smoke OK.
6. **Rewards & progression feel**: the VICTORY card-pick box shows its three cards at a readable size (0.62) and drops the redundant
   "REWARDS" label when it holds only the pick (shot `docs/overnight/oct23/c6_pick.png`; town `--open=pick` screenshot hook).
7. **Onboarding / first hour**: the battle tooltip's status lines checked on screen (Hustle + Exhausted + Red Tape on one unit, shot
   `docs/overnight/oct23/c7_status.png`); wording now matches the cards ("-2/-0", "1 turn left").
8. **Balance** (measured, reverted): the Itamae at Elite skill 44 / 31 - no change; per Path on seed 8100 B 25 / G 100 / R 0 / N 0, a
   matchup question for the designer (inbox 3).
9. **Combat feel**: the zones push the camera in before an elite or lieutenant fight (Colonel Casserole, Captain Spotless, Quota in the
   Transit Yards); Colonel Casserole gets a board entrance too (29 entrances).
10. **Stability**: the dungeons smoke's last failure ("the Swolympus gate says it is sealed", open since Oct 21) was the smoke, not the
    game - the freed Gainlands' "Quota fled" scene was on screen when it pressed E at the gate. The smoke now finishes open dialogue
    first: dungeons smoke OK, 49 checks, 0 failures (D-TUT and D-HOG start to boss, with the new scripts and entrances).
11. **Dialogue & story**: voice pass over tonight's 93 lines (64 scripted, 29 entrances): ten entrance lines repeated their boss's own
    scripted line nearly word for word (Clench, the Doppelganger, the Raccoon, Plume, Siphon, Crumb, Brick, Compostella, the Spotter,
    Betty, the Itamae) - each pair now says two different things; no line over 160 characters; a check script in the cycle log.
12. **Balance** (measured, reverted): the Automaton with a 4-point shield and its falter at 15% reads 50 / 81 again - its scripts fire
    (replay) but its fights are decided by its Old Kingdom heal; reverted. Mean 65 left (boss band 40-60, one seed high).
