# Health cards and card changes, draft sims (Nov 25 night, Parts A and F)

Generated from `card_<id>_before|after.md` (`tools/run_nov25n_card_sims.sh 2 3`: level 12, 3 seeds, 2 games per rival and seed, 18 games per row; "before" is tag pre-nov25-night). "Change" is the win-rate change from putting one copy in place of the deck's weakest pick. Small samples: a swing of 5-10 points is noise.

| Card | Before: change | After: change | Games |
|---|---:|---:|---:|
| Hulking Hauler (`B-13`) | -11 | -5 | 18 |
| Counterweight (`B-19`) | -5 | -5 | 18 |
| Snack Bar (`B-23`) | -5 | -5 | 18 |
| Cool-Down Stretch (`B-39`) | new card | -5 | 18 |
| Field Bandages (`C-41`) | new card | +0 | 18 |
| Bone Broth Cook (`G-36`) | new card | -11 | 18 |
| Push Broom of Undeath (`N-10`) | +0 | +0 | 18 |
| Resting In Peace Clause (`N-19`) | +0 | +0 | 18 |
| I've Made a Huge Mistake (`N-20`) | +0 | +0 | 18 |
| Soul Collector (`N-39`) | new card | +5 | 18 |
| Membership Cancellation (`NB-06`) | +0 | +0 | 18 |
| Mulch Mole (`R-01`) | +0 | +0 | 18 |
| Community Compost Bin (`R-10`) | +0 | +0 | 18 |
| Compost Tea (`R-38`) | new card | +0 | 18 |

**Reading.** The sensible drafter beats the draft rivals 94% of the time at this level, so the sims sit near the ceiling: they show no card breaks a deck (nothing swings above +5) and none of the reworks made a card worse than before (Hulking Hauler -11 -> -5). They cannot show small gains. The new healers are tools for sustain over a run (postgame, dungeons), which a single duel does not measure; see `docs/design/health_by_path.md`.
