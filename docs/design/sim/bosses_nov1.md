# Boss tuning at the 15 -> 30 HP curve (Fable pass Nov 1, Part 2)

The expected built deck per stage (`ProgressionModel`), 3 games per Path and boss, seed 7100 (12 games per cell: one game is 8 points, so
read +/-15 as noise). Band: zone and side bosses 40-60 %, Primm phases 40-60 % each (the brief), the cave 70-90 % with the bare starter.

Columns: **before** = the morning's HP-curve table (`hp_curve_nov1/built_hp15.md`), **setup** = after the 2-turn setup window and the Wild
Growth cap alone (`bosses_nov1/after_setup_s7100.md`), **after** = after the tuning rounds (`tune2_s7100.md`, `tune3_s7100_*.md`).

| Boss | L | Before | Setup only | After | Turns | Change |
|---|---:|---:|---:|---:|---:|---|
| The Restless Dead | 8 | 75% | 75% | **58%** (ok) | 11.1 | AI skill Normal -> Elite |
| Shiro Swindle | 12 | 67% | 67% | **42%** (ok) | 10.1 | 38 -> 40 HP; Smoke and Mirrors +2/+1 -> +3/+1 |
| The Warden of the Four Seals | 24 | 92% | 92% | **58%** (ok) | 8.5 | 28 -> 30 HP; new rule Four Seals (+1/+1) |
| The Wellspring's Echo | 16 | 75% | 75% | **58%** (ok) | 7.9 | The Spring Remembers +2/+2 -> +3/+3 |
| Throne of Gains - Chancellor Clench, Iron Regent | 8 | 50% | 50% | **50%** (ok) | 6.8 | - |
| The Grand Kitchen - The Doppelganger | 14 | 42% | 42% | **42%** (ok) | 8.8 | - |
| Office of Final Approval - Mortimer Grimsby, CE-No | 11 | 67% | 58% | **58%** (ok) | 8.3 | - |
| The Rotheart - Compostella, the Rotheart | 17 | 50% | 67% | **50%** (ok) | 7.0 | 22 -> 26 HP (Wild Growth capped at +3 per unit) |
| Primm - phase 1 (standardization) | 22 | 100% | 100% | **83%** (too easy (+23)) | 7.0 | 44 -> 56 HP; Royal Guard 2 -> 4 Militia; C-30/C-32 x2 |
| Primm - phase 2 (reflection) | 22 | 100% | 100% | **100%** (too easy (+40)) | 7.7 | 42 -> 52 HP; He Already Knows draws 2; AI skill Elite -> Boss |
| Primm - phase 3 (unraveling) | 22 | 92% | 92% | **67%** (too easy (+7)) | 7.7 | 42 -> 50 HP; Everything He Cannot Control +2/+2 -> +3/+3 |
| The Summit Altar - The Ancient Spotter | 23 | 83% | 92% | **50%** (ok) | 5.8 | 34 -> 40 HP; Ancient Form +4/+3 -> +5/+4; +B-31 |
| Chef's Choice - The Itamae Supreme | 14 | 58% | 58% | **58%** (ok) | 9.1 | - |
| Betty's Desk - Betty Bones, Surly Secretary | 10 | 75% | 75% | **42%** (ok) | 10.0 | 34 -> 36 HP; Surly +2/+1 -> +3/+1; +N-32, +N-28 |
| The Throne of Lids - His Majesty the Raccoon | 16 | 58% | 58% | **58%** (ok) | 8.6 | - |
| The Grate Beneath the Plaza - Enforcer Captain Spotless | 21 | 83% | 83% | **67%** (too easy (+7)) | 8.7 | 26 -> 34 HP; Spotless Drill +4/+3 -> +5/+3; +C-30, C-34, C-32, C-33 |
| The Colonel's Kitchen - Colonel Cornelius Crumb, Director of Culinary Defense | 23 | 58% | 58% | **58%** (ok) | 6.9 | - |
| The Vault Core - The Old Kingdom Automaton | 7 | 83% | 83% | **50%** (ok) | 10.8 | 22 -> 28 HP; Old Kingdom Steel +1/+1 -> +2/+2 |
| The Extraction Theater - Dr. Ambrose Siphon, Chief Path-ologist | 25 | 33% | 33% | **50%** (ok) | 7.2 | 48 -> 42 HP; Replication every 2 -> 3 turns |
| The Extraction Theater - Dr. Ambrose Siphon, Chief Path-ologist (with Elowen) | 25 | 100% | 100% | **100%** (too easy (+40)) | 5.4 | 48 -> 42 HP; Replication every 2 -> 3 turns |
| The Leg Press Throne - Baron Quadzilla | 6 | 42% | 42% | **42%** (ok) | 6.8 | - |
| Arena tier 3 - Announcer Grand Bellows | 22 | 100% | 100% | **100%** (too easy (+40)) | 6.8 | - |

## Primm's gauntlet (three phases on one HP pool, `--what=sequence --filter=boss:primm --games=4 --seed=7100`)

| Path | Runs | Cleared | HP left | Lost at |
|---|---:|---:|---:|---|
| Beefcake | 8 | 0% | 0.0 | Primm - phase 3 (unraveling): 3, Primm - phase 2 (reflection): 3, Primm - phase 1 (standardization): 2 |
| Gourmand | 8 | 38% | 10.0 | Primm - phase 3 (unraveling): 5 |
| Refusemancer | 8 | 50% | 16.8 | Primm - phase 3 (unraveling): 4 |
| Necrocrat | 8 | 100% | 21.1 | - |

Overall 15 of 32 runs clear the castle (47 %). Per phase with fresh HP the sims read 83 / 100 / 67 % (the mirror phase cannot be made hard
with HP, draws or AI skill: it plays the player's own deck). The gauntlet is the number that matters (Oct 23 lesson) and it sits in the band,
but Beefcake clears it 0 of 8 (its units vs Standardization's 3/3 Militia) and Necrocrat 8 of 8: see the inbox.

## The setup window

Every boss now opens with `setup_turns` (default 2, `BossTempo`, per-boss in the boss block of `dungeon_content.json`): its units do not
attack during its first turns, shown as the "Setting Up" badge. Alone it moved nothing measurable (the setup column), as the stall rule did
not: the sim player does not die on turns 1-2. It is for people, who do (the critics' Doppelganger / Compostella deaths on turns 5-6).

## Not tuned

- **Siphon with Elowen** 100 %: Elowen's jam is worth ~50 points; the no-Elowen case is in band now (inbox).
- **Arena tier 3 (Announcer Grand Bellows)** 100 %: not a zone or side boss; the arena pays prizes, not progress (inbox).
