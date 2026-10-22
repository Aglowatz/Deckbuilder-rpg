# Starting decks (Rebalance Part D, Oct 18 2026)

## Oct 22 2026 (UI + economy fixes, Part 4): more neutral cards

Each deck keeps 45 cards and 19 Infrastructure, but now about **15 of the 26 are Colorless Commons** and the rest are the Path's own
Commons with one or two Uncommon copies. The key Path cards stay, so the tutorial still has a Resource maker and spender to point at:

| Path | Path cards (makes / spends its Resource) | Colorless Commons |
|---|---|---|
| Beefcake (11 + 15) | Hamster Wheel Runner x3 (makes Iron), Personal Trainer x2 (uses Iron), Leg Day Survivor x2, Dropped Weights x2, Flex on 'Em x1, Overclocked Mill Worker x1 (U) | Village Militia x3, Traveling Brawler x2, Courier Pigeon x2, Tavern Regular x2, Traveler's Sword x2, Rally the Village x2, Tripwire x2 |
| Necrocrat (11 + 15) | Skeleton Clerk x3, Infernal Intern x3 (make Red Tape), Body-builder x2 (uses it), Pink Slip x2, Middle Management Zombie x1 (U) | Watchtower Archer x3, Shield Bearer x2, Wandering Medic x2, Courier Pigeon x2, Second Wind x2, Village Militia x2, Ambush Party x2 |
| Gourmand (12 + 14) | Line Cook x3, En Garde-Manger x2 (U) (make Ingredients), Meatloaf Mold x2, Pastry Artificer x2 (cook them), Soup Kitchen Volunteer x3 | Watchtower Archer x3, Village Militia x3, Shield Bearer x2, Courier Pigeon x2, Second Wind x2, Tripwire x2 |
| Refusemancer (11 + 15) | Curbside Rat x3, Dumpster Diver x2 (make Garbage), Possum Prowler x3, Acid Vomitor x2 (U) (eat it), Rusty Spring Trap x1 | Village Militia x3, Watchtower Archer x2, Traveling Brawler x2, Old Kingdom Automaton x2, Traveler's Sword x2, Ambush Party x2, Desperate Measures x2 |

The choice screen's sample cards (`ElementChoice.RECIPES`) are all still in their decks. Old saves keep the cards and decks they own.

**Simulation** (`tools/run_balance_sim.gd`, reports `docs/design/sim/oct22_final_*.md`; two seeds, 7000 / 8100, 50 runs each):

| | Beefcake | Necrocrat | Gourmand | Refusemancer |
|---|---:|---:|---:|---:|
| Tutorial, whole Forgotten Cave cleared | 91 / 92 | 94 / 93 | 89 / 88 | 87 / 91 |
| Stray Gym Hound (L1) | 96 / 96 | 86 / 88 | 80 / 76 | 78 / 78 |
| Lost Junior Clerk (L1) | 92 / 90 | 92 / 94 | 84 / 80 | 92 / 96 |
| Bin Raccoon (L1) | 88 / 86 | 82 / 90 | 86 / 76 | 72 / 78 |
| Store Room Ghosts (L3) | 94 / 94 | 100 / 98 * | 98 / 100 | 96 / 100 |
| Round robin L1 (40 games a pairing) | 58 | 42 | 51 | 50 |
| Round robin L5 | 67 | 40 | 48 | 46 |

- * measured before Necrocrat's last swap (two Desperate Measures for two Village Militia); the other Necrocrat rows are after it.
- Tutorial: every Path 87%+ (target 80%+). Gourmand started at 75/80 with a Herb Garden list; three Soup Kitchen Volunteers instead
  of the Herb Gardens and Healing Potions took it to 89/88.
- The Crosspath outskirts roamers lost one HP each (Hound 4->3, Clerk 5->4, Raccoon 4->3) and the Raccoon one spell for a basic
  (20/13): the neutral decks are a few points weaker than the old all-Path ones in these first duels (old decks, same seeds: Beefcake
  ~90, Necrocrat ~90, Gourmand ~83, Refusemancer ~80). Two cells stay in the 70s: Gourmand vs the aggressive Hound and the Refusemancer
  Garbage mirror (it was 76-80 with the old deck too).
- Round robin: the level-1 spread is 16 points (58 to 42; it was 26 with the old decks, 66 to 40). Beefcake still leads, as before
  (its Path identity: Hustle and burst turns; the AI-vs-AI mirror favours the aggressor). Not within ~10 yet; the encounters the
  player actually meets are in band. Level 5 uses the progression model's reference decks, which now cut the Colorless filler first
  (`ProgressionModel.CUT_ORDER`).


One unique 45-card starting deck per Path: 19 basic Infrastructure of the Path plus 26 cards, legal from the first turn (the old
42-card colorless starter and its tutorial size waiver are history; the waiver only still exists for old saves). The player gets the
deck of the Path they choose in the Rescuer's conversation (`Session.choose_starting_path` -> `CampaignStart.starter_deck`), the 26
cards are their whole collection, and the tutorial's 3 on-Path reward picks grow the deck to 48 by Crosspath. Every deck is mostly
Commons, has two or three Uncommon kinds (2 copies each at most: the level-1 cap), no Epics or Legendaries, and never more than 3
copies of a card. Source of truth: `CampaignStart.STARTING_DECKS` and `CampaignStart.GAME_PLANS`; the choice screen's sample cards
and playstyle lines are in `ElementChoice.RECIPES`.

Design rule for all four: the deck must **make** its Resource with several cards and **spend** it with several, so the tutorial's
"You made a Resource / Spend it" prompts always have something to point at, whichever Path is chosen. Each list also carries a way
to get past blockers (burn, fliers, removal or traps), because the Forgotten Cave's enemies have 3 HP and a few bodies.

## Beefcake - Iron burst turns

| Card | Copies | Role |
|---|---:|---|
| Hamster Wheel Runner (B-05) | 3 | 1-drop that makes an Iron |
| Gym Bro (B-01) | 2 | 1/1 Hustle, the first attacker |
| Late-ish Courier (B-07) | 1 | 2/1 Hustle that cannot block: early pressure |
| Millstone Pusher (B-04) | 2 | ramp (Overexert for a burst turn) |
| Personal Trainer (B-09) | 2 | grows with every Iron you use |
| Spotter (B-08) | 2 | a buff on entering |
| Leg Day Survivor (B-12) | 2 | 4/2 Hustle |
| Beefy Bouncer (B-11) | 1 | the 5/4 Bulldoze top end |
| Shot Putter (B-10) | 2 | 3/3 that Overexerts to shoot a unit |
| Dropped Weights (B-03) | 2 | 2 damage to a unit |
| Flex on 'Em (B-21) | 2 | face damage to close the race |
| Dry Scoop (B-20) | 1 | Hustle for a surprise swing |
| Weight Belt (B-14) | 1 | +1/+1 and Bulldoze Tool |
| Counterweight (B-19) | 1 | trap: 3 damage to an attacker |
| Overclocked Mill Worker (B-24, U) | 1 | makes an Iron whenever it attacks |
| The Carpool (B-26, U) | 1 | everyone gets Hustle for the big turn |

**Game plan.** Play a body every turn, let Powerhouses and Runners pile up Iron, and on the turn you attack spend every Iron on the
attackers: each is +1/+1 until end of turn, so three Iron on a Leg Day Survivor is a 7/5 for a turn. Dropped Weights clears the
one blocker that matters; Flex on 'Em finishes. **Why these cards:** every Beefcake Common that makes or benefits from Iron, the
cheapest Hustle bodies, and (after the simulation) one trap and a Shot Putter so the deck can also hold a turn; the two Uncommons
are the Iron engine (Mill Worker) and the alpha-strike enabler (Carpool).

## Necrocrat - Red Tape and small tokens

| Card | Copies | Role |
|---|---:|---|
| Skeleton Clerk (N-01) | 3 | 1/2 1-drop; Red Tape when it dies |
| Infernal Intern (N-02) | 3 | 2/2, Red Tape on entering |
| Body-builder (N-04) | 2 | Red Tape -> a 2/2 Patchwork Body each turn |
| Notary Wraith (N-06) | 2 | Flying; drains when it dies - the deck's way past blockers |
| Red Tape Dispenser (N-09) | 1 | Red Tape on demand |
| Corpseified Public Accountant (N-05) | 1 | 2/3 body; makes Red Tape when an enemy unit dies (Phase 2 cycle 9: a body instead of the second Dispenser) |
| Pink Slip (N-15) | 2 | destroys a small unit |
| Processing Delay (N-16) | 1 | destroys any unit, two turns later |
| Post-Human Resources Ghoul (N-03) | 2 | edict |
| Requisition Form (N-18) | 1 | a Red Tape into two cards |
| I've Made a Huge Mistake (N-20) | 1 | sacrifice a Clerk: two cards and a Red Tape |
| Grave Shift Worker (N-07) | 2 | brings a cheap unit back |
| Waiting Room (N-13) | 2 | their units enter exhausted (Hustle insurance) |
| Middle Management Zombie (N-23, U) | 2 | Zombie Temps hit harder; Red Tape -> Temps |
| Audit Wraith (N-26, U) | 1 | Flying drain, Red Tape on entering |

**Game plan.** Go wide with cheap units that leave Red Tape behind, use Red Tape on their biggest blocker before you attack (-2
attack until their next turn, so your 2/2s survive the block), and turn spare Red Tape into Patchwork Bodies or cards. Fliers
drain, removal clears the one wall that matters, the Worker brings things back. **Why:** the Commons that make Red Tape, the two
that spend it on bodies and cards, cheap removal, two anti-Hustle cards, and the two Uncommon token payoffs.

## Gourmand - Ingredients into Golems

| Card | Copies | Role |
|---|---:|---|
| Line Cook (G-01) | 3 | 1/2 1-drop Ingredient |
| Kitchen Porter (G-09) | 2 | two Ingredients when it dies |
| Sushi Apprentice (G-02) | 1 | Ingredient -> a 1/1 Weenie each turn |
| Conveyor Belt Chef (G-03) | 1 | two Ingredients -> two Weenies |
| Windowsill Herb Garden (G-15) | 2 | an Ingredient every turn |
| Meatloaf Mold (G-12) | 2 | two Ingredients -> a 3/3 Golem each turn |
| Pastry Artificer (G-08) | 2 | pay 1 and two Ingredients -> a 4/4 Cake Golem |
| Soup Kitchen Volunteer (G-06) | 2 | 2/3 body, 2 HP |
| Sourdough Sentry (G-04) | 2 | 1/6 wall |
| Sous Chef (G-07) | 2 | 2/3, Peek 2, draw |
| Food Critic (G-05) | 1 | bounce a small unit |
| Plate It (G-20) | 1 | turns their best unit into a Snack |
| Dinner Is Served (G-16) | 1 | trap: Plates an attacker |
| Stock the Pantry (G-25, U) | 2 | three Ingredients at once |
| En Garde-Manger (G-23, U) | 2 | Sucker Punch blocker that makes Ingredients |

**Game plan.** Hold the ground with cheap, sturdy chefs while Feastforges, Line Cooks and the Herb Garden stack Ingredients; from
turn three on, cook a Golem every turn (Mold, Artificer, Chefs) that is bigger than anything the enemy paid energy for, and Plate
or bounce the one threat that gets through. **Why:** every Common that makes or cooks Ingredients, the defensive bodies the Path
identity asks for, card selection, a trap, and the two Uncommons that speed the engine up. The simulation showed the deck's slow
start was its weakness, so the Seasoning Station gave way to a second cooking body and the Cookbook to the trap.

## Refusemancer - Garbage effects and recursion

| Card | Copies | Role |
|---|---:|---|
| Curbside Rat (R-06) | 3 | 1/2 1-drop Garbage |
| Possum Prowler (R-08) | 3 | 2/2 that eats Garbage for +2/+2 |
| Dumpster Diver (R-02) | 2 | Garbage every turn |
| Community Compost Bin (R-10) | 1 | never run out of Garbage |
| Kidding Around (R-05) | 2 | 2/3 and a Goat |
| Alley Scrap (R-19) | 2 | brawl: your fat unit eats theirs |
| Mulch Mole (R-01) | 1 | ramp |
| Landfill Ox (R-03) | 1 | 3/4; eat twice and lose 1 HP for four energy |
| Heap Tortoise (R-09) | 1 | 5/6 Swat top end |
| Junkyard Giraffe (R-07) | 1 | 3/5 Swat wall |
| Raised Bed (R-11) | 1 | Garbage -> a buff each turn |
| Rusty Spring Trap (R-14) | 2 | trap: 2 damage to an attacker |
| Garbage Pit (R-12) | 1 | trap: destroys an entering unit, pays Garbage |
| Rubbish Goat (R-04) | 1 | 2/3, Tool hate, Garbage |
| Hayfork Harpoon (R-17) | 1 | +1/+1 Swat Tool |
| Acid Vomitor (R-22, U) | 2 | 2/3; eat Garbage and lose 1 HP: 2 damage to a unit, every turn |
| Second-Hand Life (R-24, U) | 1 | trap: a dead unit comes back to hand |

**Game plan.** Every Wasteworks and Rat makes Garbage; eating it costs 1 energy and no HP now, so the Possum swings as a 4/4, the
Vomitor shoots a unit every turn and the Raised Bed grows something. Traps punish their attacks and their new units, Alley Scrap
turns a pumped Possum into removal, and Second-Hand Life brings the pieces back. **Why:** the Garbage makers and eaters among the
Commons, a few sturdy Swat bodies (the Path's Flying answer), three traps, and the two Uncommons that give it removal and recursion.
The Recycling Center was the deck's least helpful card in the simulation (0% when played) and gave way to the Garbage Pit.

## Flow and tutorial

- `Session.choose_starting_path(color)` builds the profile (26 owned cards) and the 45-card deck; `ensure_game` and the secret tunnel
  add 3 picks on top like a real clear would (48 cards).
- The tutorial (`TutorialLayer`) reads the player's Resource kind for its prompts and the `SPEND_WORDS` list to find a spending
  card; every deck has both. The Forgotten Cave's enemies still use no Beefcake or Necrocrat cards; their decks were retuned for
  the new starters (few walls, see `docs/design/balance_log.md`, Part E).
- Old saves: a profile saved mid-tutorial with the old 42-card starter keeps playing under the legacy size waiver; a saved deck short of
  the minimum is topped up with basic Infrastructure on load (`Session.rebuild_starter_deck`).

## Simulation results (Part D, `tools/run_balance_sim.gd --what=tutorial`, 50 real runs per Path)

| Path | Fight 1 (full HP) | Fight 2 | Boss | Whole cave cleared |
|---|---:|---:|---:|---:|
| Beefcake | 100% | 96% | 96% | 86% |
| Refusemancer | 96% | 100% | 92% | 82% |
| Necrocrat | 100% | 96% | 88% | 80% |
| Gourmand | 92% | 88% | 88% | 78% |

Within the brief's "about 10 points of each other"; Part G's iterations re-check this table after every change to the cards.
Level-1 deck round robin (40 games per pairing, both seats the AI): Beefcake 66%, Gourmand 50%, Refusemancer 44%, Necrocrat 40%
overall (was 86 / 51 / 27 / 37 before Part C); Beefcake's remaining edge is its Path identity (first-player wins reach 64% even in
the Beefcake mirror), and the per-encounter targets of Part E are what the player actually meets.

## Daytime Oct 19 changes

- **Necrocrat** (loop cycle 11, after Part 2): N-01 x3, N-02 x3, N-04 x2, N-05 x3, N-06 x2, N-15 x3, N-07 x3, N-03 x3, N-13 x2, N-23 x2 +
  19 Ghost Town. Out since v0.4.0: Requisition Form, Red Tape Dispenser, Processing Delay, I've Made a Huge Mistake, Audit Wraith.
- **Gourmand** (Part 2): - Stock The Pantry, - Sourdough Sentry, + Sous Chef (3rd), + Soup Kitchen Volunteer (3rd).
- Cave runs (100 per Path on two seeds): Beefcake ~93-95, Gourmand ~87-90, Refusemancer ~85-87, Necrocrat ~87 (was ~79). Details in
  balance_log.md.
