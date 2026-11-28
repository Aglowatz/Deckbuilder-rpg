# The Extra Pocket, measured (Nov 27 day, Part B)

**The Extra Pocket** (relic): "You can use each equipped item twice per duel. The first use spends one copy, and the second is free, even
if it was your last copy." Nothing was changed in the game. Raw rows: `pocket_draft_<path>.md`, `pocket_zone_runs.md`,
`pocket_postgame.md` / `pocket_postgame_by_kit.md`; runner `tools/run_nov27_pocket_sims.sh`; log `_logs/nov27/pocket.log`.

**The sim now plays the Pocket as the game does.** Until today the sim's item policy charged a copy for both uses, so with one copy the
second use never happened (Nov 26 night's run gave it each item twice instead). `SimItemPolicy.second_use_free` makes the second use of a
duel free when the Pocket is worn (test in `tests/test_nov27_soak.gd`); "with the Pocket" below simply wears it. Every comparison is
paired: the same decks, rivals and seeds with and without it.

## Verdict

- **Not a must-take, and it breaks no fight.** In the zone dungeons it adds **+2 points with heal items and +5 with burn items** over an
  empty relic slot; the other mid-game relic, the **Dog-Eared Bookmark** (draw 2 when a duel starts), adds **+16 / +17**. A player
  choosing between them should take the Bookmark nearly every time.
- **Its best use is the postgame with burn items: +11 points** (52 % -> 63 % over five fights; the Warden 42 % -> 58 %). That is the
  combo Nov 26 night suspected (two Firebrand Charms used four times), but it lifts hard fights rather than trivialising them: no fight
  went from "lost" to "won every time"; Siphon stays under half, the Echo of Hortensia Clipwell at a third.
- **In drafts it barely matters** (one draft run, one or two items): heal items +0, burn items +6 (54 games a kit: within chance).
- **No proposal.** If you want the Pocket to be a real rival to the Bookmark in the zones, that is a design choice (it would need a
  second effect); nothing in today's numbers calls for a nerf.

## Zone dungeons (route B, one HP pool, items carried fight to fight)

Each Path's reference deck and gear at the boss's level; 6 runs a Path (24 a row); the relic slot holds the Pocket, the Bookmark or
nothing; items: heal = 2 Hearty Pot Pies + 2 Healing Salves, burn = 2 Firebrand Charms + a Sharpening Stone + a Hearty Pot Pie.

| Dungeon | Heal: no relic | Heal: Pocket | Heal: Bookmark | Burn: no relic | Burn: Pocket | Burn: Bookmark |
|---|---:|---:|---:|---:|---:|---:|
| The House of Gains | 25 % | 29 % | 46 % | 42 % | 50 % | 54 % |
| The Test Kitchen | 54 % | 58 % | 79 % | 58 % | 63 % | 75 % |
| The Hall of Final Approvals | 50 % | 46 % | 67 % | 50 % | 54 % | 71 % |
| The Rotheart | 54 % | 58 % | 58 % | 42 % | 46 % | 58 % |
| **Average** | **46 %** | **48 %** | **62 %** | **48 %** | **53 %** | **64 %** |

24 runs a cell: a single cell moves about +-10 points by chance; the averages (96 runs) about +-5. The Bookmark's lead is clear in
every dungeon; the Pocket's over nothing is small and not certain.

## Postgame (the Pocket in the aggro kit's empty relic slot)

The six late decks x the aggro kit (Glass Jaw Gauntlets, Earned Blade, Elastic Waistband, Curve-Topper Boots, Compliance Clipboard)
with and without the Pocket x heal / burn items; 2 games each (12 a cell).

| Fight | Burn | Burn + Pocket | Heal | Heal + Pocket |
|---|---:|---:|---:|---:|
| Lab 8 - Hybrid Specimen | 83 % | 83 % | 83 % | 92 % |
| Lab 16 - Dr. Ambrose Siphon | 33 % | 42 % | 17 % | 33 % |
| Gallery 10 - Echo of Hortensia Clipwell | 8 % | 33 % | 17 % | 17 % |
| Swolympus 2 - Squat Rack Sentinel | 92 % | 100 % | 92 % | 92 % |
| The Warden of the Four Seals | 42 % | 58 % | 42 % | 58 % |
| **All five** | **52 %** | **63 %** | **50 %** | **58 %** |

## Drafts (Trey's zone drafts, level 12; one draft a Path, three rivals, 5 games each)

| Path | Bare deck | Heal | Heal + Pocket | Burn | Burn + Pocket |
|---|---:|---:|---:|---:|---:|
| Beefcake | 27 % | 40 % | 33 % | 47 % | 53 % |
| Gourmand | 13 % | 7 % | 7 % | 7 % | 7 % |
| Refusemancer | 13 % | 20 % | 27 % | 27 % | 33 % |
| Necrocrat (3 games a rival) | 0 % | 0 % | 0 % | 0 % | 11 % |
| **Four Paths (54 games)** | **15 %** | **19 %** | **19 %** | **22 %** | **28 %** |

The Necrocrat batch at 5 games a rival ran past its 20-minute limit and was killed (its table is written at the end); it was rerun at
3 games a rival.
