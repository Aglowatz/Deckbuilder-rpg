# Balance report, Nov 21 2026 (measured; nothing changed)

Fable Nov 21 review, Part 3. **No card, enemy or Arena number was changed.** One rules bug was fixed in Part 2 (Recipe for Wonder
charged less energy than its text says). Everything below is measurement and proposal; the decisions are yours.

How it was measured: the game's own balance simulator (`core/sim/`, `tools/run_balance_sim.gd`). The hero's seat is the planning AI
at Elite skill ("a decent player who makes no mistakes") with the expected player's level, deck, gear and items for that point of the
game (`ProgressionModel`); enemies play at the skill their kind has in the game. Seed 7100 and 8 games per Path and fight, as in the
last pass (Nov 11), so the tables compare line by line; the Arena got 12 to 20. **One game in 32 is 3 points: read +/- 10 as noise,
and a single Path's cell (8 games) as +/- 20.** The raw tables are in `docs/design/sim/nov21r/`.

What the sim is not: a person. It never over-levels, never goes back to town for cards, and plays every Path equally well. Read a
low number as "a wall for a player who arrives on level with a typical deck", not as "nobody gets past".

<<HEADLINES>>

## 1. The Nov 21 changes

The changes that had not been simulated: the foe's opening hand holds at least two Infrastructure (so foes stall less), the four
zone dungeons' full heal became a "heal 5 for a price" choice room with six new drawbacks, five cards changed, and three- and
four-Path cards wait for Primm (no reference deck held one before the postgame, so that rule moves no number here).

### 1a. Fight by fight, beside the last pass

<<COMPARE>>

### 1b. Whole dungeon runs, and what the heal room costs

<<DUNGEON_RUNS>>

### 1c. Far off (a fair deck above 95 % or below 35 %)

<<FAR_OFF>>

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

Simulated with `tools/arena_proposals_nov21.gd` (12 games per Path and row; `docs/design/sim/nov21r/arena_proposals*.md` hold every
row tried, 14 more than are shown here). "Skill" is how carefully the enemy AI plays (Normal, Elite, Boss: the dungeons' own three
levels). A "rule" is a line on the enemy's rule badges, like a dungeon boss's; in the game it is one entry in
`data/encounters/modifiers.json`. **Tick the rows you want; nothing is applied.**

<<ARENA_TABLE>>

Not simulated, for you to weigh by hand:

- **A set opening hand** (the Champion always opens with two Crossroads and a two-drop, say). The game has the machinery only for
  the first duel of the tutorial (`FirstDuel`); giving it to an Arena foe is a small code change, and it would make a bout play the
  same way every time, which suits a "boss with a script" and suits a ladder less. The Crossroads rows above get most of the way
  with data alone.
- **The tier prizes** (Champion's Laurels, Crowd-Pleaser's Cape, Gladiator's Net, Bloodsand Boots and the Bellows card): first
  numbers from Nov 19, untouched. If the bouts get harder the prizes can stay.

## 3. The economy

<<ECONOMY>>

## 4. What I would decide, in order

<<DECISIONS>>
