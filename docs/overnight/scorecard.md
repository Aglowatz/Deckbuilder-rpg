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
