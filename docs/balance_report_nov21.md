# Balance report, Nov 21 2026 (measured; nothing changed. Sections 5 to 7 added by Fable Nov 21 castle)

Fable Nov 21 review, Part 3. **No card, enemy or Arena number was changed.** One rules bug was fixed in Part 2 (Recipe for Wonder
charged less energy than its text says). Everything below is measurement and proposal; the decisions are yours.

How it was measured: the game's own balance simulator (`core/sim/`, `tools/run_balance_sim.gd`). The hero's seat is the planning AI
at Elite skill ("a decent player who makes no mistakes") with the expected player's level, deck, gear and items for that point of the
game (`ProgressionModel`); enemies play at the skill their kind has in the game. Seed 7100 and 8 games per Path and fight, as in the
last pass (Nov 11), so the tables compare line by line; the Arena got 12 to 20. **One game in 32 is 3 points: read +/- 10 as noise,
and a single Path's cell (8 games) as +/- 20.** The raw tables are in `docs/design/sim/nov21r/`.

What the sim is not: a person. It never over-levels, never goes back to town for cards, and plays every Path equally well. Read a
low number as "a wall for a player who arrives on level with a typical deck", not as "nobody gets past".

## The headlines

1. **The Nov 21 changes moved little.** Of 60 fights simulated, 55 have a number from an earlier pass, and 47 of those are within 10 points of it (the other eight are listed in 1c). The foe's new
   opening hand (two Infrastructure) did not make the ordinary fights harder: the gatekeepers sit at 66 to 81 %, where they were.
2. **The new heal rooms cost HP, not clears:** 0 to 3 points of first-try clear rate in every dungeon, and 0 to 4 HP at the end.
   The dial you named (5 HP to 7) would change almost nothing.
3. **Whole dungeons were simulated as runs for the first time, and the House of Gains is steep:** about one run in four clears
   it at the first try on level 8, with the old room or the new one. The Hall is four in ten; the Test Kitchen and the Rotheart
   one in two. This is older than Nov 21; it has just never been measured as a run.
4. **A few bosses wall one Path:** Beefcake against Mortimer (0 of 8 fights, 0 of 10 runs), Refusemancer against Clench (0 of 8),
   Beefcake against Compostella (1 of 8) and against Siphon (1 of 8), Gourmand against the Warden of the Four Seals (1 of 8).
   Every one of them was already the weak cell in the last pass.
5. **The Arena is far too easy, and more HP does not fix it.** Four battles of six are won nine times in ten or more; Diamond
   Sand, meant as the hardest, 98 %. Section 2 has one proposed row per battle, each simulated into its band.
6. **The economy runs 9 % over your target** (23,131 gold against 21.2k), and "three copies of everything plus every brew" costs
   about 75,800 gold by the game's own prices, not 21,200 (section 3).

## 1. The Nov 21 changes

The changes that had not been simulated: the foe's opening hand holds at least two Infrastructure (so foes stall less), the four
zone dungeons' full heal became a "heal 5 for a price" choice room with six new drawbacks, five cards changed, and three- and
four-Path cards wait for Primm (no reference deck held one before the postgame, so that rule moves no number here).

### 1a. Fight by fight, beside the last pass

"Last" is the newest older table that holds the same fight (Nov 11 for the three later dungeons, Nov 7 for the gatekeepers,
Oct 30 for the House of Gains and the castle, Nov 1 for the bosses not simulated since). The "Flag" column marks a fair deck above
95 % or below 35 %, and a single Path below 35 %. An ordinary room at 97 to 100 % carries the flag and is as designed (its band is
80 to 100 %); the ones worth reading are picked out in 1c. Made by `python tools/balance_compare_nov21.py`
(`docs/design/sim/nov21r/compare.md`).

#### town

| Encounter | Kind | L | Target | Beefcake | Necrocrat | Gourmand | Refusemancer | All now | Last | Change | Turns | HP left | Flag |
|---|---|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| Pantry Hound | Normal | 1 | 80-100% | 100% | 100% | 100% | 100% | **100%** | - | - | 5.8 | 14.8 | above 95 % |
| Lost Junior Clerk | Normal | 1 | 80-100% | 100% | 100% | 100% | 100% | **100%** | - | - | 6.4 | 13.9 | above 95 % |
| Bin Raccoon | Normal | 1 | 80-100% | 100% | 100% | 100% | 100% | **100%** | - | - | 5.8 | 13.8 | above 95 % |
| Store Room Ghosts | Normal | 3 | 80-100% | 100% | 100% | 100% | 100% | **100%** | - | - | 5.9 | 14.3 | above 95 % |
| Brick Bronson | Elite | 3 | 60-75% | 88% | 75% | 88% | 75% | **81%** | 81% (gatekeepers_after) | +0 | 7.9 | 10.2 |  |
| Chef Fennel Gravois | Elite | 3 | 60-75% | 100% | 75% | 50% | 38% | **66%** | 63% (gatekeepers_after) | +3 | 11.7 | 15.0 |  |
| Moss Mulligan | Elite | 3 | 60-75% | 88% | 100% | 50% | 38% | **69%** | 81% (gatekeepers_after) | -12 | 7.3 | 13.9 |  |
| Prudence Pallor | Elite | 3 | 60-75% | 100% | 50% | 50% | 88% | **72%** | 70% (gatekeepers_after) | +2 | 9.5 | 13.3 |  |
| The Restless Dead | Boss | 8 | 40-60% | 50% | 75% | 75% | 50% | **63%** | 58% (bosses_nov1) | +5 | 9.4 | 15.7 |  |
| Shiro Swindle | Boss | 12 | 40-60% | 38% | 75% | 63% | 25% | **50%** | 42% (bosses_nov1) | +8 | 9.2 | 13.2 | one Path below 35 % |
| The Warden of the Four Seals | Boss | 24 | 40-60% | 63% | 50% | 13% | 63% | **47%** | 58% (bosses_nov1) | -11 | 7.4 | 12.9 | one Path below 35 % |
| The Wellspring's Echo | Boss | 16 | 40-60% | 50% | 88% | 63% | 50% | **63%** | 58% (bosses_nov1) | +5 | 7.8 | 18.2 |  |

#### dungeon: D-HOG

| Encounter | Kind | L | Target | Beefcake | Necrocrat | Gourmand | Refusemancer | All now | Last | Change | Turns | HP left | Flag |
|---|---|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| Cardio Corridor - Treadmill Sprinter | Normal | 8 | 80-100% | 88% | 75% | 50% | 88% | **75%** | 78% (oct30_D-HOG) | -3 | 7.5 | 15.0 |  |
| Free Weight Courtyard - Courtyard Lifter | Normal | 8 | 80-100% | 88% | 100% | 88% | 100% | **94%** | 91% (oct30_D-HOG) | +3 | 5.8 | 17.9 |  |
| Regime Checkpoint - Vivienne Quota, Minister of Efficiency | Elite | 8 | 60-75% | 75% | 50% | 50% | 50% | **56%** | 66% (oct30_D-HOG) | -10 | 6.4 | 17.5 |  |
| Prison Block - Cell Block Brawler | Normal | 8 | 80-100% | 88% | 88% | 100% | 63% | **84%** | 72% (nov4b_cell_block_after) | +12 | 7.4 | 16.1 |  |
| Hall of Trophies - Trophy Hall Honor Guard | Elite | 8 | 60-75% | 88% | 88% | 88% | 75% | **84%** | 47% (oct30_D-HOG) | +37 | 6.4 | 18.0 |  |
| Throne of Gains - Chancellor Clench, Iron Regent | Boss | 8 | 40-60% | 88% | 75% | 25% | 0% | **47%** | 34% (oct30_D-HOG) | +13 | 7.7 | 17.0 | one Path below 35 % |

#### dungeon: D-HFA

| Encounter | Kind | L | Target | Beefcake | Necrocrat | Gourmand | Refusemancer | All now | Last | Change | Turns | HP left | Flag |
|---|---|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| Department of Intake - Intake Clerk | Normal | 11 | 80-100% | 88% | 100% | 100% | 100% | **97%** | 97% (after2_dungeon_D-HFA) | +0 | 6.2 | 18.0 | above 95 % |
| Department of Returns - Returns Clerk | Normal | 11 | 80-100% | 100% | 100% | 100% | 100% | **100%** | 100% (after2_dungeon_D-HFA) | +0 | 6.4 | 18.0 | above 95 % |
| Notary Checkpoint - Notary Wraith | Elite | 11 | 60-75% | 75% | 100% | 100% | 88% | **91%** | 88% (after2_dungeon_D-HFA) | +3 | 8.5 | 15.7 |  |
| Resurrection Permits Desk - Resurrection Permits Zombie | Normal | 11 | 80-100% | 88% | 100% | 100% | 100% | **97%** | 97% (after2_dungeon_D-HFA) | +0 | 7.4 | 17.9 | above 95 % |
| Appeals Court - Undersecretary Vellum | Elite | 11 | 60-75% | 63% | 100% | 100% | 75% | **84%** | 88% (after2_dungeon_D-HFA) | -4 | 9.6 | 17.1 |  |
| Executive Elevator - Executive Elevator Operator | Normal | 11 | 80-100% | 88% | 100% | 100% | 100% | **97%** | 97% (after2_dungeon_D-HFA) | +0 | 6.3 | 18.7 | above 95 % |
| Office of Final Approval - Mortimer Grimsby, CE-No | Boss | 11 | 40-60% | 0% | 88% | 75% | 63% | **56%** | 66% (after2_dungeon_D-HFA) | -10 | 9.0 | 17.7 | one Path below 35 % |

#### dungeon: D-TTK

| Encounter | Kind | L | Target | Beefcake | Necrocrat | Gourmand | Refusemancer | All now | Last | Change | Turns | HP left | Flag |
|---|---|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| Prep Station - Prep Station Sous-Chef | Normal | 14 | 80-100% | 88% | 100% | 100% | 100% | **97%** | 97% (after2_dungeon_D-TTK) | +0 | 5.3 | 21.2 | above 95 % |
| Walk-In Cooler - Frozen Line Cook | Normal | 14 | 80-100% | 88% | 100% | 100% | 100% | **97%** | 97% (after2_dungeon_D-TTK) | +0 | 6.0 | 21.5 | above 95 % |
| Prototype Bay - Unfinished War Machine | Elite | 14 | 60-75% | 88% | 100% | 100% | 75% | **91%** | 94% (after2_dungeon_D-TTK) | -3 | 7.5 | 18.5 |  |
| Golem Assembly Line - Assembly Line Golem | Normal | 14 | 80-100% | 88% | 100% | 100% | 100% | **97%** | 97% (after2_dungeon_D-TTK) | +0 | 5.7 | 20.9 | above 95 % |
| Weapons Test Range - Cannon-Blender Gunner | Elite | 14 | 60-75% | 100% | 100% | 100% | 88% | **97%** | 97% (after2_dungeon_D-TTK) | +0 | 5.5 | 14.4 | above 95 % |
| The Head Chef's Pass - Expediter of the Pass | Normal | 14 | 80-100% | 88% | 100% | 100% | 100% | **97%** | 97% (after2_dungeon_D-TTK) | +0 | 5.6 | 21.0 | above 95 % |
| The Grand Kitchen - The Doppelganger | Boss | 14 | 40-60% | 75% | 75% | 88% | 75% | **78%** | 78% (after2_dungeon_D-TTK) | +0 | 8.9 | 19.1 |  |

#### dungeon: D-ROT

| Encounter | Kind | L | Target | Beefcake | Necrocrat | Gourmand | Refusemancer | All now | Last | Change | Turns | HP left | Flag |
|---|---|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| Overgrown Junkyard - Overgrown Scarecrow | Normal | 17 | 80-100% | 88% | 100% | 100% | 100% | **97%** | 100% (after2_dungeon_D-ROT) | -3 | 4.7 | 19.5 | above 95 % |
| Fungal Hollow - Mutant Mushroom Troop | Normal | 17 | 80-100% | 88% | 100% | 100% | 100% | **97%** | 100% (after2_dungeon_D-ROT) | -3 | 4.6 | 18.7 | above 95 % |
| Root-Choked Mill - Hortensia Clipwell, Royal Groundskeeper | Elite | 17 | 60-75% | 63% | 100% | 88% | 100% | **88%** | 81% (after2_dungeon_D-ROT) | +7 | 5.9 | 18.5 |  |
| Thorn Maze - Thorn Maze Stalker | Normal | 17 | 80-100% | 88% | 100% | 100% | 100% | **97%** | 97% (after2_dungeon_D-ROT) | +0 | 4.5 | 19.3 | above 95 % |
| Hive of Mutant Bees - Hive of Mutant Bees | Elite | 17 | 60-75% | 88% | 100% | 88% | 100% | **94%** | 94% (after2_dungeon_D-ROT) | +0 | 5.5 | 18.5 |  |
| Rot Tunnel - Rot Tunnel Horror | Normal | 17 | 80-100% | 100% | 100% | 100% | 100% | **100%** | 100% (after2_dungeon_D-ROT) | +0 | 4.6 | 19.6 | above 95 % |
| The Rotheart - Compostella, the Rotheart | Boss | 17 | 40-60% | 13% | 75% | 100% | 75% | **66%** | 59% (after2_dungeon_D-ROT) | +7 | 6.5 | 16.2 | one Path below 35 % |

#### dungeon: D-PC

| Encounter | Kind | L | Target | Beefcake | Necrocrat | Gourmand | Refusemancer | All now | Last | Change | Turns | HP left | Flag |
|---|---|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| Courtyard of Perfect Hedges - Hedge Trimmer Guard | Normal | 21 | 80-100% | 100% | 100% | 100% | 100% | **100%** | 100% (oct30_D-PC) | +0 | 5.6 | 22.9 | above 95 % |
| Portrait Gallery - Gallery Curator | Normal | 21 | 80-100% | 100% | 100% | 100% | 100% | **100%** | 100% (oct30_D-PC) | +0 | 5.7 | 23.0 | above 95 % |
| Hall of Mirrors - Mirror Knight | Elite | 21 | 60-75% | 50% | 88% | 75% | 75% | **72%** | 88% (oct30_D-PC) | -16 | 6.1 | 14.3 |  |
| Ministry of Correction - Ministry Clerk | Normal | 21 | 80-100% | 100% | 100% | 100% | 100% | **100%** | 100% (oct30_D-PC) | +0 | 5.5 | 22.1 | above 95 % |
| Royal Stair - Royal Staircase Guard | Elite | 21 | 60-75% | 88% | 88% | 88% | 100% | **91%** | 88% (oct30_D-PC) | +3 | 8.3 | 15.5 |  |
| Primm - phase 1 (standardization) | Boss | 22 | 40-60% | 100% | 100% | 88% | 100% | **97%** | 83% (tune3_s7100_D-PC) | +14 | 6.9 | 22.1 | above 95 % |
| Primm - phase 2 (reflection) | Boss | 22 | 40-60% | 88% | 100% | 100% | 100% | **97%** | 100% (tune3_s7100_D-PC) | -3 | 7.2 | 24.0 | above 95 % |
| Primm - phase 3 (unraveling) | Boss | 22 | 40-60% | 38% | 100% | 50% | 63% | **63%** | 67% (tune3_s7100_D-PC) | -4 | 7.1 | 18.1 |  |
| Beefcake Wing: Coup Orders Barracks - Coup Barracks Sergeant | Normal | 21 | 80-100% | 100% | 100% | 100% | 100% | **100%** | 100% (oct30_D-PC) | +0 | 4.8 | 22.0 | above 95 % |
| Necrocrat Wing: Notarized Archives - Percival Plume, Deputy Minister of Good News | Elite | 21 | 60-75% | 75% | 88% | 100% | 100% | **91%** | 91% (oct30_D-PC) | +0 | 5.8 | 17.6 |  |
| Refusemancer Wing: the Corrupted Seed Vault - Seed Vault Gardener | Normal | 21 | 80-100% | 100% | 100% | 100% | 100% | **100%** | 100% (oct30_D-PC) | +0 | 5.1 | 22.5 | above 95 % |
| Clocktower Balcony - Clocktower Sentinel | Elite | 21 | 60-75% | 100% | 88% | 100% | 100% | **97%** | 91% (oct30_D-PC) | +6 | 7.5 | 18.9 | above 95 % |

#### postgame: D-LAB

| Encounter | Kind | L | Target | Beefcake | Necrocrat | Gourmand | Refusemancer | All now | Last | Change | Turns | HP left | Flag |
|---|---|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| Intake Corridor - Intake Orderly | Normal | 25 | 80-100% | 100% | 100% | 100% | 100% | **100%** | - | - | 6.1 | 13.1 | above 95 % |
| Specimen Storage - Escaped Specimen | Normal | 25 | 80-100% | 100% | 100% | 100% | 100% | **100%** | 100% (oct30_lab) | +0 | 5.9 | 12.4 | above 95 % |
| Failed Experiments Ward - The Failed Experiment | Elite | 25 | 60-75% | 75% | 88% | 100% | 63% | **81%** | 75% (oct30_lab) | +6 | 6.3 | 13.3 |  |
| Hall of Hybrids - Hybrid Specimen | Normal | 25 | 80-100% | 100% | 100% | 100% | 100% | **100%** | 100% (oct30_lab) | +0 | 5.7 | 14.5 | above 95 % |
| Cell Block - Siphon's Research Assistant | Normal | 25 | 80-100% | 100% | 100% | 100% | 100% | **100%** | 100% (oct30_lab) | +0 | 6.0 | 14.5 | above 95 % |
| Containment Breach - The Drain Warden | Elite | 25 | 60-75% | 63% | 100% | 100% | 88% | **88%** | 75% (oct30_lab) | +13 | 6.1 | 8.5 |  |
| The Antechamber - Antechamber Sentry | Normal | 25 | 80-100% | 100% | 100% | 100% | 100% | **100%** | 92% (oct30_lab) | +8 | 5.9 | 12.5 | above 95 % |
| The Extraction Theater - Dr. Ambrose Siphon, Chief Path-ologist | Boss | 25 | 40-60% | 13% | 75% | 75% | 63% | **56%** | 50% (tune3_s7100_D-LAB) | +6 | 7.6 | 8.0 | one Path below 35 % |
| The Extraction Theater - Dr. Ambrose Siphon, Chief Path-ologist (with Elowen) | Boss | 25 | 40-60% | 100% | 88% | 88% | 88% | **91%** | 100% (tune3_s7100_D-LAB) | -9 | 6.2 | 8.3 |  |

### 1b. Whole dungeon runs, and what the heal room costs

New tool: `tools/dungeon_runs_nov21.gd`. A run is one walk from the entrance to the boss along the map's own arrows with one HP
pool, as in the game (the maps fork: a run of the House of Gains is three to five fights, not all six). At the heal room the same
run is continued four ways from the same HP with the same seeds, so the differences between the four columns are the room's and
nothing else's. The hero walks the way with the fewest fights; "most" is the way with the most (the House of Gains' includes the
rescue, so Grandmaster Flex stands on your field against Clench). Reference deck = the expected player's deck at that dungeon's
level; starter = the bare starter deck with the same level and gear. Raw tables: `docs/design/sim/nov21r/dungeon_runs_*.md`.

**Runs that clear the dungeon at the first try, all four Paths together** (and the HP left after the boss in those runs):

| Dungeon (level) | Walk | Deck | Runs | Reach the heal room | Old room: full heal | **Today: 5 HP for gold** | Today: 5 HP for the drawback | Walk on | Most runs end at |
|---|---|---|---:|---:|---:|---:|---:|---:|---|
| House of Gains (8) | fewest: 3 fights | reference | 40 | 50 % | 23 % / 18.0 HP | **23 % / 14.0** | 18 % / 14.9 | 20 % / 10.6 | Vivienne Quota (14 of 40) |
| | | starter | 24 | 75 % | 33 % / 18.8 | **33 % / 15.3** | 29 % / 10.9 | 33 % / 11.9 | Chancellor Clench (10 of 24) |
| | most: 5 fights, Flex rescued | reference | 40 | 25 % | 23 % / 18.4 | **23 % / 16.1** | 20 % / 14.5 | 23 % / 13.1 | Vivienne Quota (14 of 40) |
| Hall of Final Approvals (11) | fewest: 4 fights | reference | 40 | 80 % | 38 % / 14.9 | **38 % / 14.9** | 35 % / 14.9 | 35 % / 13.7 | Mortimer Grimsby (16 of 40) |
| Test Kitchen (14) | fewest: 4 fights | reference | 40 | 85 % | 63 % / 17.2 | **65 % / 16.1** | 65 % / 16.0 | 60 % / 15.4 | the Doppelganger (8 of 40) |
| | | starter | 24 | 79 % | 54 % / 18.9 | **54 % / 18.5** | 54 % / 18.5 | 58 % / 16.9 | the Doppelganger (6 of 24) |
| | most: 6 fights | reference | 40 | 85 % | 50 % / 13.1 | **48 % / 13.1** | 48 % / 13.1 | 48 % / 12.3 | the Doppelganger (12 of 40) |
| The Rotheart (17) | fewest: 4 fights | reference | 32 | 88 % | 53 % / 12.4 | **50 % / 12.9** | 50 % / 12.2 | 50 % / 12.1 | Compostella (11 of 32) |

(40 runs: one run is 2.5 points. The Hall's other walk and starter rows, the Rotheart's, and the Lab were cut for time: a fight
at those levels takes the simulator over a second.)

What it says:

1. **The new heal rooms cost HP, not clears.** Swapping the full heal for "5 HP for gold" moves the first-try clear rate by
   0 to 3 points in every dungeon (inside the noise) and leaves the hero 0 to 4 HP poorer after the boss. The reason is in the
   HP a hero has at the room (`dungeon_runs_*.md`, "HP there"): 12 to 18 of the 19 to 24 a hero of those levels has (15 plus half
   the level, plus gear). The full heal was worth a few HP at the door, 5 HP gives most of them back, and the boss fight is
   decided by the boss, not by those few HP.
2. **The free choice (heal 5 and take the drawback) costs up to 5 points** in the House of Gains ("Slept on the Mats": your first
   unit has -2 attack) and nothing measurable elsewhere. Walking on costs 0 to 5.
3. **So the dial you named (5 HP to 7) would do very little either way.** If the last stretch of a dungeon feels too hard when
   you play it, the heal room is not where the difficulty is.
4. **Where it is: the fights in front of the room.** In the House of Gains half of all runs never see the heal room: Vivienne
   Quota, the second fight, ends 14 runs in 40 on her own. A first-try clear of that dungeon is about one run in four for an
   on-level hero, with either room. That is not a Nov 21 change (fight by fight she is at 56 %, and was at 66 % on Oct 30: inside the
   noise of 32 games); it is what three fights at 75 %, 56 % and 47 % multiply to. The Test Kitchen and the Rotheart sit at one run in two; the Hall at four in ten.
   A lost run sends the hero back to the zone with the gold and XP of the fights won, so the second try is a level stronger.
   Whether one in four is the House of Gains you want as most players' first dungeon is the real question this table raises.
5. **The starter deck does no worse than the reference deck** at these levels (33 % against 23 % in the House of Gains, 54 %
   against 63 % in the Test Kitchen; 24 runs, so +/- 10). A player who never rebuilt the deck is not locked out, the gear and the
   level carry it.

### 1c. Far off (a fair deck above 95 % or below 35 %)

**Too hard for one Path (a single Path below 35 %, all Paths together inside or near the band):**

| Fight | Level | All | The wall | Last pass, same cell | Read |
|---|---:|---:|---|---|---|
| **Mortimer Grimsby** (the D.N.A.'s boss) | 11 | 56 % | **Beefcake 0 %** (0 of 8; and 0 of 10 whole runs) | 25 % (Nov 11) | the clearest wall in the game: an on-level Beefcake deck does not beat him |
| **Chancellor Clench** (the Gainlands' boss) | 8 | 47 % | **Refusemancer 0 %, Gourmand 25 %** | 25 % and 0 % (Oct 30) | the two slower Paths against a rush boss, at the level of a first zone; a Refusemancer who comes here third or fourth is levels above this |
| **Compostella** (the Dump's boss) | 17 | 66 % | **Beefcake 13 %** | 25 % (Nov 11) | Beefcake again, against the board that grows |
| **Dr. Siphon** (the Lab's boss, without Elowen) | 25 | 56 % | **Beefcake 13 %** | - | with Elowen rescued: 100 % for Beefcake. The rescue is the answer the game gives |
| **The Warden of the Four Seals** (the cellar) | 24 | 47 % | **Gourmand 13 %** | 58 % all Paths (Nov 1) | optional, postgame |
| **Shiro Swindle** (the ninja of the chests) | 12 | 50 % | **Refusemancer 25 %** | 42 % all Paths (Nov 1) | optional |
| **Primm, phase 3** | 22 | 63 % | Beefcake 38 % | 67 % all Paths (Nov 1) | not below 35, but the lowest cell of his fight; unchanged, as you ruled |

Beefcake is the Path that hits walls (Mortimer, Compostella, Siphon, Primm's last phase): its reference deck wins fast or not at
all, and these four bosses are the ones that survive the rush. The sim plays a one-Path Beefcake deck; a Beefcake player with a
second Path has answers the sim's deck lacks.

**Too easy for what it is meant to be (an elite above 90 %, a boss above 75 %):**

| Fight | Kind | Level | All | Last pass | |
|---|---|---:|---:|---:|---|
| Cannon-Blender Gunner (Test Kitchen) | Elite | 14 | 97 % | 97 % | band 60-75 % |
| Clocktower Sentinel (Primm's Castle) | Elite | 21 | 97 % | 91 % | unchanged by your rule |
| Hive of Mutant Bees (the Rotheart) | Elite | 17 | 94 % | 94 % | |
| Notary Wraith (Hall of Final Approvals) | Elite | 11 | 91 % | 88 % | |
| Unfinished War Machine (Test Kitchen) | Elite | 14 | 91 % | 94 % | |
| Royal Staircase Guard, Percival Plume (the castle) | Elite | 21 | 91 %, 91 % | 88 %, 91 % | unchanged by your rule |
| The Doppelganger (Test Kitchen's boss) | Boss | 14 | 78 % | 78 % | band 40-60 % |
| Primm, phases 1 and 2 | Boss | 22 | 97 %, 97 % | 83 %, 100 % | each phase with fresh HP; the three in a row on one HP pool are the number that matters, and were 47 % on Nov 1. Unchanged by your rule. |
| Siphon with Elowen rescued | Boss | 25 | 91 % | 100 % | the reward for the rescue |

None of these moved with the Nov 21 changes; they are the standing state of the mid-game elites. They make the dungeons kinder
than the bands say, which, given headline 3, may be why the dungeons are passable at all.

**Moved by more than 10 points since the last pass** (8 games a Path; +/- 10 is noise, so read these as "look", not "broken"):
Trophy Hall Honor Guard 47 -> 84 % and Cell Block Brawler 72 -> 84 % (both compared with tables from before the Nov 4
House of Gains pass), Chancellor Clench 34 -> 47 %, Primm phase 1 83 -> 97 %, The Drain Warden 75 -> 88 %; down: Mirror Knight
88 -> 72 %, Moss Mulligan 81 -> 69 %, the Warden of the Four Seals 58 -> 47 % (and, at exactly 10 down, Vivienne Quota 66 -> 56 %
and Mortimer 66 -> 56 %).

## 2. The Arena

Six battles and four puzzles in four tiers. The puzzles are boards with one proven solution each and are not balance (the solver's
tests cover them). The battles, as they are today, 20 games per Path (`docs/design/sim/nov21r/arena.md`; tier 4 from the proposal
runs, because the first table played it at the wrong level, see the note under the table):

| Tier | Battle | Player level | Meant to be | Beefcake | Necrocrat | Gourmand | Refusemancer | All | Turns | HP left |
|---|---|---:|---|---:|---:|---:|---:|---:|---:|---:|
| 1 Bronze | Gladiator Rookie ("Warm-Up Brawl") | 8 | a first test (80-100 %) | 95% | 100% | 100% | 95% | **98%** | 6.5 | 15.8 |
| 1 Bronze | Sandbag Sentinel ("The Neutral Mile", borrowed kit) | 8 | a first test (80-100 %) | 100% | 100% | 100% | 100% | **100%** | 6.1 | 21.7 |
| 2 Silver | Cardboard Colossus ("Spells Only, Please", borrowed kit, no units) | 13 | an elite (60-75 %) | 50% | 60% | 45% | 40% | **49%** (see below) | 17.8 | 21.0 |
| 2 Silver | Champion of the Four Fists | 13 | an elite (60-75 %) | 95% | 100% | 95% | 75% | **91%** | 8.1 | 19.0 |
| 3 Gold | Announcer Grand Bellows | 22 | a boss (40-60 %) | 80% | 85% | 95% | 90% | **88%** | 6.4 | 9.8 |
| 4 Diamond | The Four Fists, Unbound | 25 (assumed) | the Arena's hardest (40-60 %) | 100% | 100% | 92% | 100% | **98%** | 6.4 | 18.8 |

**You were right: they are far too easy.** Four of the six are won nine times in ten or more, and the last tier is the easiest
fight of its level in the whole game. Three things the tables show:

- **More HP alone does almost nothing.** Every battle is over in six to eight of the hero's turns; ten more HP is one more turn.
  The Rookie at 22 HP instead of 14: 96 %. The Unbound champion at 62 instead of 54: 98 %.
- **What moves a bout is the enemy's units and how well it plays them:** a small stat rule on its units (as the dungeon bosses
  have), a higher skill level, an extra opening card.
- **The Four Fists deck stumbles on its own energy.** It plays four Paths on 17 basic Infrastructure split four ways. Three Old
  Kingdom Crossroads (energy of any Path) let it play its hand; that is the "opening-hand rule" you said was fine for the Arena.

Two notes on the table. *Tier 4 had no level:* `ProgressionModel.LEVELS` has no entry for it, so the first sim played it with a
level-1 hero (26 %). The same table sets the game's prize multiplier for a first clear, so I did not add an entry; the sim now
assumes level 25 (the Lab's, the postgame) for that tier only. If you would rather have the prize of Diamond Sand grow with the
player's level like the other tiers', say which level it is meant for. *The Cardboard Colossus cannot be judged by the sim:* the
planning AI plays the no-units kit badly (it takes 18 turns and loses half the time), and a person does not: the Colossus has 6 HP,
is Passive, and the kit holds six Flex on 'Em (2 damage each, 4 with a big unit, which the kit cannot have). Three of them end
it. Play it once by hand before deciding; my guess is that it is the easiest of all.

### The proposals, one row per battle, each simulated

Simulated with `tools/arena_proposals_nov21.gd` (12 games per Path and row; `docs/design/sim/nov21r/arena_proposals*.md` hold all
41 rows tried; the 12 worth choosing between are shown here). "Skill" is how carefully the enemy AI plays (Normal, Elite, Boss: the dungeons' own three
levels). A "rule" is a line on the enemy's rule badges, like a dungeon boss's; in the game it is one entry in
`data/encounters/modifiers.json`. **Tick the rows you want; nothing is applied.**

| # | Battle | Today | Proposed row | Simulated (B / N / G / R = all) | Turns | Approve? |
|---|---|---|---|---|---:|---|
| 1 | **Gladiator Rookie** (Bronze, level 8) | 14 HP, Normal skill: **98-100 %** | **20 HP; plays at Elite skill; rule "Home Crowd": its units get +1/+1** | 83 / 83 / 83 / 75 = **81 %** | 7.6 | [ ] |
| 1b | | | *softer:* 20 HP and Elite skill, no rule | 100 / 92 / 92 / 92 = 94 % | 7.2 | [ ] |
| 2 | **Sandbag Sentinel** (Bronze, level 8, borrowed kit) | 13 HP, Defensive, Normal skill: **100 %** | **20 HP; Elite skill; rule "Packed Sand": its units get +0/+2** | 92 / 100 / 83 / 83 = **90 %** | 8.3 | [ ] |
| 2b | | | *harder:* 22 HP; Elite skill; Balanced instead of Defensive; "Packed Sand" +1/+1 | 75 / 83 / 75 / 50 = 71 % | 8.6 | [ ] |
| 3 | **Cardboard Colossus** (Silver, level 13, borrowed kit, no units) | 6 HP, Passive: the sim cannot play this kit (49 %, 18 turns) | **10 HP** (three Flex on 'Em end it today; five would be needed) - *by reading, not measured; play it once first* | sim: 29 % (not meaningful) | - | [ ] |
| 4 | **Champion of the Four Fists** (Silver, level 13) | 33 HP: **90 %** (meant: 60-75 %) | **40 HP; 3 Old Kingdom Crossroads in its deck; rule "Four Fists": its units get +1/+1** | 33 / 92 / 58 / 67 = **63 %** | 9.9 | [ ] |
| 4b | | | *harder:* the same at 44 HP | 33 / 83 / 58 / 58 = 58 % | 10.0 | [ ] |
| 5 | **Announcer Grand Bellows** (Gold, level 22) | 46 HP: **88-90 %** (meant: 40-60 %) | **64 HP; rule "The Crowd Roars": his units get +1/+1** | 58 / 67 / 33 / 58 = **54 %** | 6.6 | [ ] |
| 5b | | | *harder:* 64 HP and "The Crowd Roars" +2/+1 | 33 / 50 / 42 / 58 = 46 % | 6.0 | [ ] |
| 6 | **The Four Fists, Unbound** (Diamond, level 25 assumed) | 54 HP: **98 %** (meant: the hardest, 40-60 %) | **80 HP; 3 Old Kingdom Crossroads; one more opening card; rule "Unbound": its units get +4/+4** | 42 / 83 / 50 / 25 = **50 %** | 7.8 | [ ] |
| 6b | | | *another way:* the Marshal's deck under the Champion's name, 80 HP, one more opening card, "Unbound" +3/+2 | 25 / 83 / 50 / 58 = 54 % | 6.6 | [ ] |
| 6c | | | *softer:* 80 HP, Crossroads, one more opening card, "Unbound" +3/+3 | 58 / 92 / 92 / 58 = 75 % | 8.9 | [ ] |

What did **not** work, so you need not try it: HP alone (Rookie 22 HP: 96 %; Sentinel 24 HP: 98 %; Four Fists 40 HP: 88 %;
Bellows 56 HP: 83 %; Unbound 62 HP: 98 %); heavier cards alone (Bellows with one more Titan and Hauler at 56 HP: 88 %; the
Unbound champion with eight Epics and Legendaries added at 80 HP and +2/+2: 92 %, *easier* than without them, because its hand
clogs); a higher skill alone (the Champion at Boss skill and 44 HP: 88 %).

Three cautions. **The spread between Paths is wide** in every proposed row (a 12-game cell is +/- 15): Beefcake has the hardest
time against the Four Fists and Refusemancer against the Unbound champion. **+4/+4 is a big rule to read on a badge;** row 6b gets
the same result with a smaller rule and a deck that already works. **The sim's hero does not misplay,** so a person will find
each row a little harder than its number.

Not simulated, for you to weigh by hand:

- **A set opening hand** (the Champion always opens with two Crossroads and a two-drop, say). The game has the machinery only for
  the first duel of the tutorial (`FirstDuel`); giving it to an Arena foe is a small code change, and it would make a bout play the
  same way every time, which suits a "boss with a script" and suits a ladder less. The Crossroads rows above get most of the way
  with data alone.
- **The tier prizes** (Champion's Laurels, Crowd-Pleaser's Cape, Gladiator's Net, Bloodsand Boots and the Bellows card): first
  numbers from Nov 19, untouched. If the bouts get harder the prizes can stay.

## 3. The economy

Measured with the tool that set the target (`tools/gold_study_nov8.gd`, the Nov 8 pass; today's output:
`docs/design/sim/nov21r/gold_study_nov21.md`) and with the economy model (`tools/economy_model.gd`,
`docs/design/sim/economy_model.md`, regenerated today).

| | Nov 8 | Today | |
|---|---:|---:|---|
| **Gold earned in a playthrough with no grinding** | 21,332 | **23,131** | **+1,799 over Nov 8; +1,931 (9 %) over your 21.2k target** |
| The model's "expected" player (most side content, half the chests) | - | 23,037 | the same answer from the second tool |
| A rusher (main line only) | - | 9,857 | |
| A thorough player (everything, some repeat clears) | - | 30,570 | |
| A playthrough's shopping list (38 cards, 6 pieces of gear, 20 item charges, 3 hats, 4 packs) | 9,800 | 9,800 | unchanged |
| **Left after that list** | 11,532 | **13,331** | about 111 more cards at the average price |
| One copy of every single-Path and Pathless card at shelf prices | 18,800 (178 cards) | 19,550 (181 cards) | |
| **Everything: three copies of every card and every multi-Path card brewed** | 56,619 | **75,823** | see below |
| ... of which a no-grind run's leftover covers | 20 % | 17 % | |
| ... and the rest in repeat clears | 9.4 h (57 % on top of a 16.5 h run) | **13.0 h (79 %)** | |

Where the expected player's 23,000 comes from (the model): the main line 6,545; clear bonuses 3,222; the level track 2,425;
side quests 2,240; chests 1,960; the postgame 1,745; roamers 1,379; side dungeons 1,365; feats 735; minigames 420; secrets 400;
the Arena 300; side rooms 275.

**The gap to your target: +1,931 gold, 9 % over.** I did not trace the extra source by source. What has been added since Nov 8
that pays gold: the defeat-three quests (Nov 18), the well quest and the one-step dungeon quests (Nov 19), and Diamond Sand
(Nov 19, 900 gold of first clears); against them, the -20 % on clear rewards of Nov 10.

**A second gap, in your sentence rather than in the game.** The brief describes the target as "enough for three copies of every
card plus crafting all multi-Path cards". By the game's own prices that goal costs about 75,800 gold today, not 21,200: 58,650
for the copies (a no-grind run's starter, picks and 43 free packs supply about 15,100 of that), 6,800 gold for the brews, and
the essence for 136 brews. The essence is what grew: a brew costs 6 essence a Path again since Nov 19 (it was 2 on Nov 8), so
the cauldron needs 1,836 essence where it needed 612, and a no-grind run gets about 80 free. 21.2k was the Nov 8 pass's
*no-grind income*; it buys a playthrough's shopping list with 13,000 to spare, and about a sixth of the full collection.

Options, cheapest first (nothing changed):

| Option | What it does |
|---|---|
| **Leave the income** | 1,900 extra gold over 16 hours is one Epic and a few Commons; nobody will feel it |
| Trim the income back to 21.2k | take about 10 % off the newest quests' gold (the defeat-three and one-step quests) |
| Make "finish everything" shorter | more essence per extra copy (2 / 4 / 8 / 16 by rarity today), or 4 essence a brew: the dial is essence, not gold |
| Keep it long on purpose | leave it: a full collection then takes about 13 hours of repeat clears after the story |

## 4. What I would decide, in order

1. **The Arena table (section 2).** Tick the bold row of each battle. It is the one place where the game is plainly not what
   you meant, the fix is data, and every row has its number.
2. **The House of Gains as a first dungeon.** One run in four at the first try. If that is steeper than you want for most
   players' first dungeon, the lever is Vivienne Quota (she ends a third of all runs alone), not the heal room. I would play it
   before deciding: the sim does not go back to town, and a second try is a level stronger.
3. **The heal rooms: leave them at 5.** The sim says the number barely matters; your playtest decides whether the *choice* is
   fun, which no sim can.
4. **The one-Path walls.** Leave Clench, Compostella, Siphon and the optional two. Look at **Mortimer for Beefcake**: 0 wins in
   18 tries is the only cell in the game where the answer to "can my Path do this on level" is no. One step (30 HP to 28, or one
   fewer of the four Epics and Legendaries added to his deck) would be a first number to try; I changed nothing.
5. **The mid-game elites that are not elite** (five at 91 to 97 %): leave them until the dungeons' run rates are where you want
   them; they are part of why the dungeons are passable.
6. **The economy: leave the income; decide what "finish everything" should cost** (section 3).

## 5. Items and equipment: how much each one is worth (Fable Nov 21 castle, Part 7)

**Nothing beyond Part 1's four was changed** (Wobble Weights, the Crown of Mild Hubris, Silence Powder, the Summoning Charm; they
are measured here as they are now). Tick the rows you want.

How it was measured: every piece of equipment, and every item with one charge, carried alone by each Path's expected level-21
player into two of Primm's Castle fights, the Ministry Clerk (a normal fight) and the Royal Staircase Guard (an elite), 6 games per
Path and fight: **48 games a row, the same seeds in every row**, so a row differs from the bare row only by what the piece changes.
Bare (no gear, no items) wins **46 %**: about 90 % of the normal fight and none of the elite. One game is 2 points; **read +/- 8 as
noise.** Raw tables: `docs/design/sim/nov21c/gear_strength_l21.md` (equipment), `gear_strength_l21_items.md` (items); an earlier,
coarser run against the Mirror Knight alone: `gear_late.md`.

**The whole kit matters more than any one piece.** The level's model equipment takes the bare 46 % to 71 %, the model items to
60 %, both together to **88 %**; against the Mirror Knight alone it is 6 % bare and 81 % equipped. The castle's elites are tuned
for a hero with gear, which is what the game hands out, so the kit as a whole is not the problem, and no single piece carries it:
the strongest is worth about half of the equipment's lift.

### The ranking (equipment)

| Rank | Piece | Rarity | What it does | Lift |
|---:|---|---|---|---:|
| 1 | Gladiator's Net (the Arena, Gold prize) | Epic | each enemy unit gets -1/-1 when it enters | **+23** |
| 2 | Clipwell's Golden Shears (the Rotheart) | Epic | 2 damage to each attacker when the foe attacks | **+22** |
| 3 | Bloodsand Boots (the Arena, Diamond prize) | Uncommon | draw a card whenever you are dealt damage | **+19** |
| 3 | Siphon's Lens | Epic | +1 card each turn, max HP +2 | **+19** |
| 5 | Elastic Waistband of Victory | Epic | units +1/+1; at most 2 non-Infrastructure cards a turn | +18 |
| 6 | Dex's Matching Pair | Epic | the first non-Infrastructure card each turn draws a copy of itself | +17 |
| 6 | Glass Jaw Gauntlets | Epic | units +2 attack; max HP -3 | +17 |
| 8 | Big Brain Beret | Epic | +1 card each turn; one non-Infrastructure card a turn; max HP -2 | +13 |
| 9 | Phial of First Water | Legendary | multi-Path cards cheaper, a little healing each turn | +11 |
| 10 | Soul Courier's Lanyard, the Colonel's Ladle, the Head Chef's Ladle, Quota's Stopwatch | Uncommon to Epic | a first-turn card, or HP | +10 |
| - | 26 pieces | all | small stat or one-Path bonuses | +2 to +8 (noise) |
| - | 12 pieces: Wicked Dagger, Spotter's Barbell, A Very Pointy Stick, Overdue Library Book, Cheater's Dice, Bin Lid Helm, Head Chef's Toque, Extra Pocket, X-Ray Goggles, and three that act outside battle (Hall Pass Slippers, Gotta-Go Galoshes, Participation Trophy) | all | | +0 |
| - | Velvet Rope, Saucepan Helmet, Hover Boots | Common, Uncommon | | -1 to -3 |

Three readings. *A card a turn is worth about +19* (Siphon's Lens); the Overdue Library Book draws one and tosses one at random and
nets zero, and the Beret pays for its card with a hard limit and lands at +13: the drawbacks work as meant. *The +0 pieces are not
broken:* one-Path pieces do nothing for three Paths of four (Wicked Dagger, the Barbell, the Velvet Rope), the Extra Pocket needs an
item, X-Ray Goggles show the foe's hand to a person, not to the sim, and three pieces act outside battle. *Hover Boots cost
fights:* Flying for all, but nobody can block, and an elite punishes that.

### Items (one charge each)

| Item | Lift | Note |
|---|---:|---|
| Firebrand Charm | **+13** | the only item clearly above noise |
| Healing Salve, Scroll of Insight | +6 | |
| Grave Dust, Hearty Pie, Iron Ration, Reckless Tonic, Silence Powder (now 1 card), Summoning Charm (now 2 Militia), Vitality Charm | +4 | |
| Blank Form, Power Wraps | +2 | |
| Bag of Rubbish, Binding Chains, Energy Draught, Sharpening Stone, Spice Pouch, Ward Sigil | +0 | the sim's item pilot uses these badly or never (no rule for Binding Chains or the Ward Sigil; resources only from turn 3): not a verdict |

One charge is small next to a piece of equipment that works every turn. With the Extra Pocket (two uses of each) an item's lift
roughly doubles; the Pocket stays as it is (your note, Nov 21) and is on the backlog.

### Proposals, one line each (nothing applied)

| # | What | Today | Proposed | Why | Approve? |
|---|---|---|---|---|---|
| 1 | **Gladiator's Net** | every enemy unit -1/-1 as it enters | **the first enemy unit each turn** gets -1/-1 | it erases every 1-toughness token for good (Primm's Militia, the Mimic's copies, the Arena's fans) | [ ] |
| 2 | **Clipwell's Golden Shears** | 2 damage to each attacker | **1 damage** to each attacker | at 2 the foe's small units cannot attack at all; at 1 the tokens still can't, the real units can | [ ] |
| 3 | **Bloodsand Boots** | a card whenever you are dealt damage | **at most once per turn** | an Uncommon worth a Siphon's Lens; a wide board of small attackers draws you three cards a turn | [ ] |
| 4 | **Siphon's Lens** | +1 card each turn, max HP +2 | **+1 card each turn, max HP -2** (the Beret's price) | an extra card a turn with no price at all; the HP is the wrong way round | [ ] |
| 5 | **Glass Jaw Gauntlets** | units +2 attack, max HP -3 | units +2 attack, **max HP -6** | in line with your Crown (-10) and the castle's curses; the attack is the fun part, keep it | [ ] |
| 6 | **Dex's Matching Pair** | a copy of the first non-Infrastructure card each turn | **only of a card that costs 3 or less** | copying a 6-drop every turn is the most card advantage in the game, for a minigame prize | [ ] |
| 7 | Elastic Waistband of Victory | | **leave** | strong, but its two-card limit is a real price | [ ] |
| 8 | Hover Boots | Flying for all, cannot block | **your units can still block units with Flying** | today the only piece that loses fights | [ ] |
| 9 | Velvet Rope | Gourmand units +0/+3 | **+1/+2** | a defensive bonus wins nothing in the sim; a little attack would | [ ] |

Rows 1 to 6 together would take the hero's kit down a few points, not tens. I would tick 1 to 4 first (the four at the top, all
with no price), play, and leave 5 and 6 for the next look.

## 6. The Arena after your rows (Fable Nov 21 castle, Part 9)

Your bold row of every battle was applied as written. Re-simulated, 12 games per Path (`docs/design/sim/nov21c/arena_after.md`):

| Battle | Before | The proposal's number | After (in the game now) | Meant to be |
|---|---:|---:|---:|---|
| Gladiator Rookie | 98 % | 81 % | **79 %** | 80-100 % |
| Sandbag Sentinel | 100 % | 90 % | **85 %** | 80-100 % |
| Cardboard Colossus (10 HP) | 49 % (the sim cannot play the kit) | - | 31 % (same caveat) | 60-75 % |
| Champion of the Four Fists | 91 % | 63 % | **52 %** | 60-75 % |
| Announcer Grand Bellows | 88 % | 54 % | **25 %** | 40-60 % |
| The Four Fists, Unbound | 98 % | 50 % | **46 %** | 40-60 % |

Four of six where you wanted them (the Rookie and the Four Fists within a game or two of the band, which a 12-game cell cannot
tell apart). **Bellows came out far harder than his proposal** (25 % against 54 %; Beefcake 0 %, Necrocrat 8 %). The likely reason:
the in-game encounter keeps his scripted events (a Rowdy Fan climbs in on his 3rd turn, the intermission), which the proposal
tool's row did not play, and Part 1 weakened two items. Not changed; it is in the inbox with a softer row (64 HP without "The Crowd
Roars", his old +2/+1 alone).

## 7. Primm after the castle pass (Fable Nov 21 castle, Part 6)

The three phases on one HP pool, an endgame deck, gear and items, 16 runs per Path (`docs/design/sim/nov21c/primm_final_*.md`):

| Leaders at your side | Beefcake | Gourmand | Refusemancer | Necrocrat | All | Target |
|---|---:|---:|---:|---:|---:|---|
| none | 6 % | 31 % | 44 % | 50 % | **33 %** | about 30 % |
| Flex | 25 % | 69 % | 63 % | 63 % | **55 %** | in between |
| the Grand Chef | 6 % | 25 % | 44 % | 56 % | **33 %** | |
| Agnes | 0 % | 63 % | 31 % | 25 % | **30 %** | |
| Compostella | 0 % | 25 % | 44 % | 50 % | **30 %** | |
| Flex and the Chef | 13 % | 69 % | 69 % | 81 % | **58 %** | |
| Agnes and Compostella | 0 % | 56 % | 50 % | 50 % | **39 %** | |
| three (Flex, the Chef, Agnes) | 44 % | 81 % | 69 % | 100 % | **74 %** | |
| all four | 25 % | 75 % | 75 % | 75 % | **63 %** | about 65 % |

On target at both ends. Two things to know: **Flex is worth more than the other three** (a body on the board from turn 2, at 3/5
already, down from 4/6), and **Beefcake struggles against Primm** at every count. Both are in the inbox. The whole castle on one
HP pool (`castle_runs.md`, 6 runs per Path and route, final numbers) is harder still: the all-allies route
was cleared in 13 % of runs, the three-ally route in 0 %, the middle road in 4 %, the quiet south in 21 %, the one-ally route with
the Safe Room in 42 %. The Pantry Mimic ends 11 of 24 runs on both ally routes; it is optional, but the Grand Chef waits there.

## 8. After your answers (Fable Nov 22 night, Part 2)

Applied from your table: Gladiator's Net (the first enemy unit each turn), Siphon's Lens (max HP -2), Glass Jaw Gauntlets (max HP
-6), Dex's Matching Pair (a first card of cost 3 or less), Hover Boots (their units can block flyers), Velvet Rope (+1/+2). No
change: the Shears, the Bloodsand Boots, the Elastic Waistband. Tests: `tests/test_fable_nov22_night.gd`.

**Grand Bellows** without "The Crowd Roars", 64 HP, his scripted events played (24 games per Path, `docs/design/sim/nov22/bellows.md`):
Beefcake 38 %, Necrocrat 46 %, Gourmand 54 %, Refusemancer 58 %, **all 49 %** (was 25 %; his band is 40 to 60 %).

**Primm.** Flex was already 3/5 with no Unbreakable in both places (the House of Gains and the Model Room); a test holds it now.
The first re-run was off target all the same: **17 % alone, 48 % with all four** (33 and 63 the night before). The cause is the
item table, not Flex: the sim's player wears the Glass Jaw Gauntlets from level 10, and 6 max HP instead of 3 is felt over three
duels on one HP pool. (Taking the Gauntlets off is worse: 3 % alone; their +2 attack is worth more than the HP.) So Primm was
eased, by HP only: his phases **40 / 46 / 44 to 30 / 36 / 34**, and "A Plan for Everyone" **8 to 7 HP** a leader. Nothing else of
his changed (8 opening cards, 1 Militia, the guards for Flex and for all four). 32 runs per Path and cell
(`docs/design/sim/nov22/primm_t2_*.md`; the untuned run is `primm_<allies>.md` beside it):

| Leaders at your side | Beefcake | Gourmand | Refusemancer | Necrocrat | All | Target |
|---|---:|---:|---:|---:|---:|---|
| none | 6 % | 16 % | 38 % | 47 % | **27 %** | about 30 % |
| one (Flex) | 56 % | 72 % | 78 % | 75 % | **70 %** | |
| two (Flex and the Chef) | 34 % | 63 % | 69 % | 84 % | **63 %** | |
| three (Flex, the Chef, Agnes) | 50 % | 78 % | 81 % | 94 % | **76 %** | |
| all four | 31 % | 69 % | 78 % | 81 % | **65 %** | about 65 % |

On target at both ends. Two things stand as before: **Flex is worth more than the rest** (with him alone the fight is already at
70 %, because the plan's extra HP grows with every further leader and the second guard comes only with all four), and
**Beefcake is the weak Path** (6 % alone). The single cells for the Chef, Agnes and Compostella were run before the tuning only
(22 to 30 % for all Paths together, beside 17 % alone), so each is worth a few points on their own.

**The whole castle on one HP pool**, gate to the end of phase 3, with the Archivists' Kettle (heal 6 after Agnes's room) and the
eased Primm, 8 runs per Path and route (`docs/design/sim/nov22/castle_runs_t2.md`; before the easing: `castle_runs.md`):

| Route | Allies | Reach Primm | Cleared | Nov 21 | Most lost at |
|---|---:|---:|---:|---:|---|
| A: all four allies, the kettle, one treasure | 4 | 31 % | **16 %** | 13 % | the Pantry Mimic (18 of 32 runs) |
| B: three allies (Chef, Flex, Agnes), the kettle | 3 | 3 % | **3 %** | 0 % | the Pantry Mimic (18 of 32) |
| C: one ally (Flex) and the Safe Room | 1 | 75 % | **53 %** | 42 % | the Clocktower Sentinel (7) |
| D: no ally, the middle road with the Safe Room | 0 | 13 % | **3 %** | 4 % | the Mirror Knight (14) |
| E: no ally, the quiet south | 0 | 100 % | **22 %** | 21 % | Primm, phase 1 (12) |

**The all-allies route did not reach 35 %.** The kettle is in the fourth room; more than half of the runs on that route end in
the first, at the Pantry Mimic, and a heal three rooms later cannot help them. Of the runs that pass the Mimic about half go on to
beat Primm. The lever is the Mimic (36 HP, +1/+1 and Mirrors), not a second heal; it is in the inbox, not changed.
