# Report - Fable pass Nov 1 (Fable 5.1): core gameplay + first hour + the designer's answers

Sun Nov 1 10:27 MST -> (end time below). Tag `pre-fable-nov1` before the run. State `docs/loop_state.md`; questions `docs/overnight_inbox.md`,
section "Fable pass Nov 1". Last run's report: `docs/overnight/oct31n/overnight_report_oct31n.md`.

## Morning summary

| Part | State | Commits |
|---|---|---|
| 1 Healing | done: the Crease's tea and the castle Safe Room already existed - made findable and reachable; the Capital's hit toast names its source | 17042af8 |
| 2 Boss tempo + tuning | done: 2-turn setup window on every boss, Wild Growth capped at +3, 17 of 22 bosses in band (table below) | ad42c84d |
| 3 Progression | done: tier-scaled dungeon-clear XP bonus; expected player within +1 of the model | 2c0c7b6d |
| 4 Naming | done: Grand Chef / Doppelganger / Escoffina agree on every surface | dd9bd479 |
| 5 Freed roamers | done: damage roamers wander in peace once the zone is freed; the Capital once Primm fell | 1112bf0a |
| 6 First hour | a-e done (teaching hand, right-click inspect, roofs dissolve, the fountain, starter study); critic 12 + fixes: see below | 23c02536, eda8d80e |
| 7 Yes-to-all | see below | |
| 8 Verify + build | see below | b91e4cb8 (dialogue export) |

- **Decide first** (inbox "Fable pass Nov 1"): 1 Primm's phases (gauntlet 47 %, per phase 83/100/67), 2 Siphon with Elowen 100 %,
  3 the Safe Room's place, 4 card G-33's name, 5 side dungeons' first-clear gold.
- **New dialogue rows for your review**: `docs/dialogue/new_rows_nov1.csv` (2 Capital toasts + the 11 Loose Ends quest rows the export added).
  **Typo fixes on frozen lines**: `docs/dialogue/typo_fixes_nov1.csv` (5: three double spaces, "judgment .", "color" in the Lab).
- **Disk**: 4.0 GB free. Deleting the v0.4.9 zip (762 MB) was blocked by the tool's permission classifier - delete `builds/TheWaywardPath-v0.4.9-windows.zip` by hand.

## Part 1 - Healing (the designer: no healing after battles in freed zones)

- **The Crease** already had a full heal (Nurse Hesper's "Tea of Dissent", `capital_zone.gd`) and **Primm's Castle** already had a full-heal
  node on every road to the boss (the Resistance Safe Room, step 7 of 10: 4 fights before it, the Royal Stair and the boss after). The critics
  never found either. Done: the nurse reads as a healer (her name floats over her, "Nurse Hesper Dray"; her spot carries her NPC so her body
  counts for E and a vendor's reach - a hero at her side got "Read the sign"), id-less spot NPCs show their short title, and a test pins the
  Safe Room as a full heal on the critical path. Moving it to the exact middle means re-fitting the painted map (inbox 3).
- **The Capital's "drain"** was rift contact (1-2 HP) and touch-damage roamers with one toast ("Ow! The Capital has hurt you again."). The toast
  names the source now: `fx.hit_rift` / `fx.hit_roamer` ("A Tidy-Bot knocks you flat. Please remain orderly. (-2 HP)"), through
  `ZoneStoryText.hit_text`; the other zones keep their own lines.
- Checks: `tests/core/zone/test_fable_nov1_healing.gd`; play scripts `fable_nov1_crease_heal` (prompt + tea toast in play) and
  `fable_nov1_safe_room` (the node opens as "mend all of your HP", Rest works). The play driver's `scene` now prints the hero's position and
  the spots in reach.

## Part 2 - Boss tempo + every boss into its band

- **Setup window**: `BossTempo` / `Modifier.Kind.SETUP_TURNS`: for its first 2 turns a boss's units do not attack ("Setting Up" badge on the
  node map, the brief, the HUD and in the sim). Data per boss: `setup_turns` in the boss block of `dungeon_content.json` (0 = off),
  `PrimmBoss.SETUP_TURNS`, the town bosses' setups. It moves the sims by nothing (the sim player never dies on turn 1-2); it is for people.
- **Wild Growth** caps at +3 per unit (`GameState.OVERGROWTH_CAP`); the Rotheart's rule text says so.
- **Tuning** (AI skill, deck, rule strength, some HP): `docs/design/sim/bosses_nov1.md` has the before / setup-only / after table and the
  gauntlet. Summary (3 games per Path, seed 7100): Restless Dead 75 -> 58, Shiro 67 -> 42, Warden 92 -> 58, Echo 75 -> 58, Compostella 50
  (cap + 26 HP), Spotter 83 -> 50, Betty 75 -> 42, Spotless 83 -> 67, Automaton 83 -> 50, Siphon without Elowen 33 -> 50; Clench 50,
  Doppelganger 42, Mortimer 58, Itamae 58, Raccoon 58, Crumb 58, Quadzilla 42 unchanged. Outside: Primm's phases 83 / 100 / 67 one at a time
  (gauntlet 47 %: Beefcake 0/8, Necrocrat 8/8), Siphon with Elowen 100, arena tier 3 100 (inbox 1-2).

## Part 3 - Progression

- `DungeonClearBonus`: a main dungeon's first clear pays 0.5 of a level at its tier (190 / 225 / 240 / 255; was a flat 160), a side
  dungeon's 0.15 (45-90; paid nothing); Primm's Castle keeps 400; per-fight XP unchanged. Timeline re-run (`docs/design/sim/economy_model.md`):
  the expected player arrives at the Dump at 18 (model 17) and the castle at 22 (model 21); 0.6 / 0.35 over-levelled by two and was dropped.

## Part 4 - Naming

- The real chef reads "The Grand Chef" everywhere (the registry strips "(formerly ...)"); the disguised figure reads as the chef it poses as
  before the reveal and "The Doppelganger" after (node blurb); the boss fight always reads "The Doppelganger" (the intro no longer applies the
  reveal); the apprentice reads "Escoffina" after the naming cutscene (`SpoilerFree.REVEALS`); a dialogue line keeps the label the writer gave
  the beat ("The Doppelganger" / "Escoffina"), so the naming cutscene moves name by name. Bestiary, music list, quest log and Buffet NPCs
  already agreed. No existing line contradicts the rule; G-33 and the Bestiary blurb are in the inbox (4).

## Part 5 - Freed zones

- `ZoneEnemies.is_freed` / `is_peaceful` + `ZoneEnemy.peaceful`: in a freed zone touch-damage roamers wander and never chase or hit (no -HP
  toast), battle roamers with a sparring deck keep their friendly rematch, the rest stand down; the Capital stands down once Primm fell and his
  fall closes every rift. Tests per zone.

## Part 6 - The first hour

- **First duel**: a teaching hand (`FirstDuel`: 2 basics, the 2 cheapest units, 1 trick, read from the Path's starter) dealt live and in the
  sims (`GameOptions.scripted_opening_hand`); the Scavenger lost its 2/2 Militia. Sim: 100 % in 4.3 player turns (was 8-10 for the critic).
- **Clicks**: a single click already played a hand card (press and release without a drag); a right-click now inspects any card; hover inspects.
- **Roofs**: the occlusion fader's building core was inset 2.6 m, so a roof covering the hero from its edge never counted; now 0.2 m, plus a
  sight line to the hero's head. Verified with `OCCLUSION_DEBUG=1` (the new "near" listing) on the square walk.
- **The fountain**: a quarter bigger (7.1 m, blocker 3.2), never ghosts or fades (its card keeps `fade_strength` 0 and `no_occlusion_fade`), and
  the hero shows through it as an x-ray silhouette (`WorldSprite.set_silhouette`, shown while the card's screen rectangle covers the figure).
- **Starter study** (`docs/design/sim/starter_nov1.md`): 45 / 35 / 30 cards at the same ratios - cave 88 / 92 / 96 %, first zone 85 / 89 / 87 %.
  **Recommendation: 35 cards (15 basics)** - same strength, each reward pick a third more of the deck; not applied.
- **Critic 12 (first hour, fresh, worktree)**: CRITIC_RESULT

## Part 7 - The yes-to-all list

PART7_RESULT

## Part 8 - Verify + build

PART8_RESULT
