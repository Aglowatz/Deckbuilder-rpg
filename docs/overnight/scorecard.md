# Overnight Oct 22-23 - scorecard

Scores 1-10. "Last" = the Oct 19-20 scorecard's end (`docs/overnight/oct19/scorecard_oct19.md`); "Phase 2 start" = after Parts 1-6
(Fri Oct 23 ~03:00); "End" = the morning (~05:30).

| Category | Last | Phase 2 start | End | Evidence |
|---|---|---|---|---|
| Combat feel | 8.5 | 8.5 | 8.5 | Battle lights + board grade (Tier 1); card crops keep heads (exported shot). |
| Visuals | 9 | 9 | 9 | Tier 1 light per zone; hats and cloaks walking in every zone (exported shots). |
| UI consistency | 8.5 | 8.5 | 8.5 | Deck Station fits 1280x720 and 1920x1080; the new Path choice tiles. |
| Onboarding / first hour | 9 | 9 | 9 | Path choice ~279 -> ~70 words; long first talks split; opening hour OK on 5 exported configs. |
| Rewards & progression feel | 8.5 | 8.5 | 8.5 | Zone shops open with their bosses; lieutenant relics. |
| Collection / bestiary | 8.5 | 8.5 | 8.5 | All 341 cards and tokens have art. |
| NPC life & dialogue | 9 | 9 | 9 | Freed barks in the Capital, Maren's progress greetings. |
| Dialogue & story | 9 | 9 | 9 | Lieutenants, Elowen, funeral; Primm quotes only freed leaders; no shared names. |
| Audio mix | 7.5 | 7.5 | 7.5 | Unchanged (no listen pass possible overnight, no new audio). Skipped by rule. |
| Performance | 9.5 | 8.5 | 8.5 | Post-fade-in frames <= 119 ms in every area; textures creep 437 -> 733 MB over a tour (cycle 1: probe stalled, next_up 2). |
| Stability | 9 | 9 | 9 | GUT 2168/2169 (+1 pending); story bot 90/90 x3; release smoke PASSED; export model fix. |
| Balance (sim evidence) | 8.5 | 8.5 | 8.5 | Model follows the shops; six outliers fixed; Beefcake in the Rotheart measured (cycle 2, waits for a call). |
| Playtest readiness | 9 | 9 | 9 | v0.4.5 zip built and smoked; the PC's disk is nearly full. |

Cycles: 1 Performance (texture creep: first probe stalled, removed), 2 Balance (Beefcake vs Rot: two seeds, replay, no change -
inbox 7), 3 Performance (tools/memory_probe.gd: textures bounded; ~33 MB video + ~530 objects leak per Crosspath visit, outside the
node tree - next_up 2), 4 Balance (six 6-game outliers re-measured on two seeds: three confirmed, proposals logged, not applied so the zip stays current),
5 Balance (Primm's three-phase sequence with the new decks: did not finish inside 15 min at 12 games - next time run it alone, ~30 min). Audio (7.5) needs a listen pass or new audio - skipped.
