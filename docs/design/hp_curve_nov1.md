# Hero max HP: 15 -> 30 (Nov 1 2026)

**Question (designer)**: "Items and cards can be used to heal, but maybe the max HP is starting too low. Evaluate whether we should start
at 15 HP and build up to 30 at end game; if so, implement it."

**Before**: 10 at level 1, +1 every second level, cap 25 (16 at L13, 20 at L20, 25 at L30).
**After**: 15 at level 1, +1 every second level, cap 30 (21 at L13, 25 at L20, 30 at L30). Same slope, +5 everywhere.

## Evidence

**Critics (four reviews, all played mostly by the weak driver pilot)**: every one put HP in its top two problems - "16 HP at level 13",
the first tutorial duel lost 2 of 3 times at 10 HP, the Doppelganger / Compostella / Primm phase 1 / Siphon winning before their scripted
phases.

**Sims (the competent sim player, `--kinds=boss --games=3 --seed=7100`, the expected built deck at each fight's level)**:
`docs/design/sim/stall_oct31n/built_after.md` (old curve) vs `docs/design/sim/hp_curve_nov1/built_hp15.md` (new curve).

| Boss | Old | New |
|---|---|---|
| The Doppelganger (Test Kitchen) | 25 % (TOO HARD) | 42 % (ok) |
| Compostella (Rotheart) | 42 % | 50 % |
| Dr. Ambrose Siphon, without Elowen | 0 % | 33 % |
| Baron Quadzilla | 42 % | 42 % |
| Chancellor Clench | 50 % | 50 % |
| Betty Bones | 50 % | 75 % (too easy) |
| The Ancient Spotter | 67 % | 83 % |
| Primm phases 1 / 2 / 3 | 100 / 100 / 83 % | 100 / 100 / 92 % |
| In the 40-60 % band | 7 of 22 | 7 of 22 |

Tutorial fights (8 games per Path, `docs/design/sim/hp_curve_nov1/tutorial_hp{10,15}.md`): the sim player wins them either way
(Warden 94 % -> 97 %); the gain is for human players, who lose those duels.

## Decision: implemented

The three fights that stop players (the Doppelganger, Compostella, Siphon) move into or toward the band, and the opening becomes forgiving
for a new player; healing items and cards stay as they are. The cost: bosses that were already easy for a strong deck get easier (Betty,
the Spotter, the arena tier 3). That is a boss-tuning pass for later - the designer asked to leave bosses for now.

## What changed

- `data/progression/level_track.json` `stats.hp_start: 15` (data-driven; `ProgressionTable` reads it), `PlayerProfile.ENDGAME_MAX_HP` 30.
- New campaigns start at the level-1 row (15); loaded saves already re-apply their level's row, so old saves get the new max on load.
- `PlayerProfile.START_MAX_HP` (10) is unchanged on purpose: enemy setups use it as their floor (`maxi(enemy_hp, START_MAX_HP)`).
- Tests updated to the new numbers (7). Full sharded suite: 2545/2546 passed, 1 pending, 0 failing.
