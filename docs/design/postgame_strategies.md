# The postgame solution hunt (Nov 26 night, Part D) - findings only, nothing changed

Brief: `docs/prompts/opus_nov26_night_v2.md`, Part D. The owner wants the postgame "hard but beatable with one of a few strong strategies".
This is a search for those strategies with the sim. **Nothing in the postgame was changed.**

## How it was searched

- **Tool:** `tools/postgame_hunt.gd` (`bash tools/run_postgame_hunt.sh fights` / `runs`). Tables: `sim/nov26n/postgame_fights.md` (every
  fight against 30 builds, 2 games each), `postgame_deep.md` (the hard fights against 60-80 builds, 3 games each), `postgame_runs.md` (whole
  dungeons on one HP pool).
- **A build** is a late deck, a gear kit and a set of items, played by the improved sim player (Nov 26 day) at level 25-26:
  - **decks:** each Path's reference deck at the fight's level, and six hand-built late decks from the full pool (Beefcake Titans,
    Necrocrat Control, Gourmand Golems, Refusemancer Heap, and two of drafted two-Path cards: Beef-Gourmand Feast, Necro-Refuse Rats);
  - **gear kits** (five slots, one piece each): *model* (`ProgressionModel`: Glass Jaw Gauntlets and the Crown of Mild Hubris, -16 max
    HP), *sturdy* (Four-Seal Signet, Flamethrower, the Colonel's Ladle, Booster-Wrapper Cape, Compost Boots...), *aggro* (Glass Jaw
    Gauntlets, Earned Blade, Elastic Waistband, Curve-Topper Boots, Compliance Clipboard), *control* (Flamethrower, Clipwell's Shears,
    Gladiator's Net, Seed Satchel, Booster-Wrapper Cape);
  - **items:** *heal* (2 Hearty Pot Pies, 2 Healing Salves) or *burn* (2 Firebrand Charms, a Sharpening Stone, a Hearty Pot Pie);
  - the Gallery runs take the best of the Silver Reserve's three offered boons. Event boons on the way are still not modelled.
- Every foe has its rules, its scripted moments and its full opening hand, as in the game.

**How to read "winning".** With 2-3 games a build, "2/2" or "3/3" is a strong build, not a certainty. A fight "has a winning build" here
when at least one build won half or more of its games.

## Every fight

| Dungeon | Fight | Builds that win (best first) | All builds | Verdict |
|---|---|---|---:|---|
| Swolympus | 1 Rival Lifter at Base Camp | most late decks, any kit (Necro-Refuse Rats, Beef-Gourmand Feast, Refusemancer Heap with control or sturdy gear: 2/2) | 45/60 | **beatable**, many ways |
| Swolympus | 2 Squat Rack Sentinel | the same late decks, any kit | 52/60 | **beatable**, many ways |
| Swolympus | 3 **The Ancient Spotter** | none (deep search: best Refusemancer Heap + aggro gear + burn items, 1/3) | 10/240 | **no winning build found** |
| The Vault | The Warden of the Four Seals | **aggro gear + burn items**: Necro-Refuse Rats (whole run 4/4), Refusemancer Heap (3/4), Necrocrat reference (2/4); with heals: the Gourmand and Necrocrat references (2/2) | 11/60 (heal kits) | **beatable** with the aggro/burn strategy |
| The Lab | 2 Intake Orderly | Beefcake and Necrocrat references with sturdy, control or model gear | 25/60 | beatable |
| The Lab | 3 Escaped Specimen | Beefcake and Necrocrat references, model gear | 19/60 | beatable |
| The Lab | 5 The Failed Experiment | **aggro gear**: Gourmand reference + burn (3/3), Necro-Refuse Rats (2/3) | 11/60 -> 40/180 (deep) | beatable with aggro gear |
| The Lab | 8 Hybrid Specimen | Necro-Refuse Rats, Beef-Gourmand Feast, Necrocrat Control, Beefcake Titans (sturdy) | 38/60 | beatable, many ways |
| The Lab | 10 Siphon's Research Assistant | Necro-Refuse Rats, Beef-Gourmand Feast, Necrocrat reference | 26/60 | beatable |
| The Lab | 13 The Drain Warden | Beef-Gourmand Feast, Necrocrat Control, Gourmand and Necrocrat references (control or sturdy) | 26/60 | beatable |
| The Lab | 15 Antechamber Sentry | Beefcake reference (any kit), Beef-Gourmand Feast, Gourmand Golems | 29/60 | beatable |
| The Lab | 16 **Dr. Ambrose Siphon** | **aggro gear + burn**: Refusemancer Heap (3/3), Necrocrat reference (2/3); Gourmand Golems sturdy/aggro (2/3) | 4/60 -> 52/240 (deep) | **beatable** with the aggro/burn strategy |
| The Gallery | 2 Echo of Vivienne Quota | Necro-Refuse Rats (sturdy), many others | 34/60 | beatable |
| The Gallery | 4 Echo of Chancellor Clench | Necrocrat reference (model), others | 27/60 | beatable |
| The Gallery | 5 **Echo of Percival Plume** | **aggro gear + burn**: Refusemancer and Necrocrat references, Necro-Refuse Rats (2/3 each) | 3/60 -> 20/240 (deep) | beatable, narrowly, with aggro/burn |
| The Gallery | 7 Echo of Mortimer Grimsby | **burn items**: Necrocrat Control (sturdy, 3/3), Refusemancer Heap (sturdy or control, 3/3) | 9/60 -> 41/180 (deep) | beatable with burn |
| The Gallery | 9 Echo of the Doppelganger | **burn items**: Necrocrat Control (sturdy 3/3, aggro 2/3), Necrocrat and Gourmand references (2/3) | 8/60 -> 46/180 (deep) | beatable with burn |
| The Gallery | 10 Echo of Hortensia Clipwell | Refusemancer reference + aggro (2/3, with burn or heal), control/burn builds | 8/60 -> 35/180 (deep) | beatable |
| The Gallery | 11 **Echo of the Rotheart** | none (deep search: best Necrocrat Control sturdy/heal, 1/3) | 4/180 | **no winning build found** |
| The Gallery | 13 The Perfect Copy | **aggro gear + burn**: Refusemancer reference (3/3), Necrocrat reference (2/3); Necro-Refuse Rats control/burn (2/3) | 4/60 -> 16/180 (deep) | beatable with aggro/burn |

## The strategies that work

1. **Burn items with aggressive gear** ("aggro/burn"): Glass Jaw Gauntlets, Earned Blade, Elastic Waistband, Curve-Topper Boots and the
   Compliance Clipboard, carrying two Firebrand Charms and a Sharpening Stone. It is the key to the Warden, Siphon, Plume, the Perfect
   Copy and the Failed Experiment: these fights punish a slow game, and the burn removes the one unit that holds the board.
2. **Burn items with sturdy gear** (Four-Seal Signet, Flamethrower, Colonel's Ladle, Booster-Wrapper Cape): the answer to the Gallery's
   long middle (Mortimer's and the Doppelganger's echoes), with Necrocrat Control or the Refusemancer Heap.
3. **Wide decks of drafted two-Path cards** (Necro-Refuse Rats, Beef-Gourmand Feast) with control or sturdy gear: the most reliable
   decks against Swolympus's first two fights and the Lab's middle rooms.

The heal-only item kit, which the sim carried by default until tonight, loses most of these fights: the owner's sense that "players use
items better than the sim" is right, and the difference is mostly **carrying burn**.

## Whole dungeons (one HP pool, one build for the whole run, 4 runs per build)

| Dungeon | Best build | Cleared | Fights won on average |
|---|---|---:|---:|
| The Warden (one fight) | Necro-Refuse Rats / aggro / burn | **4/4** | - |
| Swolympus | none cleared (best Necro-Refuse Rats / aggro / burn, 1.3 of 3; the Spotter stops every run) | 0/4 | 1.8 of 3 (Necro-Refuse Rats, sturdy) |
| The Lab, route B (4 fights) | Necro-Refuse Rats / aggro / burn | **1/4** | 1.5 of 4 |
| The Lab, route A (8 fights) | none cleared | 0/4 | 2.5 of 8 (Necrocrat reference, aggro/burn) |
| The Shattered Gallery | none cleared | 0/4 | 3.0 of 9 (Necro-Refuse Rats, aggro/burn) |

Whole runs are much harder than their fights: one build cannot fit every room, the HP carried over is what ends most runs (a spot check
shows a run ending at Plume on 2 HP left from Clench), and the items are spent by the middle. A human swaps nothing mid-run either, but
does take event boons, which the sim does not.

## Fights with no winning build found (the owner's real balance problems)

1. **The Ancient Spotter (Swolympus 3).** No build of 80 won half its games (10 wins in 240). Its rules: Beefcake units with Hustle,
   **+5/+4 to all its units**, an Infrastructure in play from the start, a heal of 4 at half health and two Young Spotters on its 6th turn.
   The +5/+4 on Hustle units kills before any setup. *Proposal (not applied): "Ancient Form" +5/+4 -> +3/+3*, or the Hustle rule off.
2. **The Echo of the Rotheart (Gallery 11).** 4 wins in 180. Its rules stack: 4 Garbage at the start, it heals 2 every turn, its units get
   +0/+1 and **+2/+2 more**, and the roots spread at half health. *Proposal (not applied): drop "heals 2 at the start of each of its turns"*
   (the heal outpaces every deck's damage once its +2/+3 units hold the ground).

Narrowly beatable (one strategy, about 2 wins in 3): **Echo of Percival Plume** and **the Perfect Copy** (aggro/burn only). That fits
"hard but beatable with one of a few strategies".
