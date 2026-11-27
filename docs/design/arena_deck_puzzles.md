# Octavia's deck-building puzzles (the Shuffle House's Puzzle Tables)

Nov 26 night, Part A2 (brief `docs/prompts/opus_nov26_night_v2.md`). Five harder puzzles, one in each level of the arena quest line, presented by Octavia Eightfold at a new door of the Shuffle House's menu, **Puzzle Tables**. Code: `core/arena/deck_puzzles.gd`; data: `data/arena/deck_puzzles.json` (written by `tools/nov26n_deck_puzzles.py`, which also writes each puzzle's rules to `data/encounters/modifiers.json` and `encounter_scripts.json` under `arena:<id>`); sims: `tools/deck_puzzle_sim.gd` (`bash tools/run_deck_puzzle_sims.sh`); test: `tests/test_nov26n_deck_puzzles.gd`.

## The rules of every puzzle

- **The opponent plays no cards.** Its deck is 60 basic Infrastructure, so its draws never matter; everything it does comes from its house rules and timed moments, listed in full in its "Before the fight" panel. Its search has no time cut-off and makes no mistakes (Boss skill, deterministic), so the same board gets the same answer every time. Three puzzles add a new house rule, **Always Block** (`Modifier.Kind.ALWAYS_BLOCK`): its units block every attacker they legally can, strongest attacker first (a blocker that survives, else the sturdiest), so a wall is a wall and the same wall every attempt.
- **The player always goes first**, so a bout depends only on the player's own deck order. The same rules are in effect every attempt.
- **The player brings their own deck, gear and items**, as in any main-game fight (the deck check runs before the bout).
- **Unlimited retries, no entry fee.** The first win pays the prize; a replay pays nothing (a deterministic bout would be a farm).
- **Order:** each table opens when the one before it is won (the first with the Shuffle House; the fifth also waits for Primm). Winning a table is the last step of its arena quest, so a save that finished a quest before tonight keeps it finished and can still play the table.

## The five tables

| # | Table | Opponent | Arena quest (level) | Player level | The weakness to find | Prize |
|---:|---|---|---|---:|---|---|
| 1 | **The Tea Garden Grows** | Madame Darjeeling | arena_open_table | 14 | the snowball: kill the sprouts while they are small (cheap removal, Toxic blockers, bounce: a token sent back is gone) | 150 gold, 120 XP, a General Pack |
| 2 | **Behind the Velvet Rope** | Maurice, Head of Security | arena_spin_the_wheel | 16 | a wall of 1/4 blockers: a board wipe (4 damage to every unit, or destroy them all) clears the lot | 200 gold, 160 XP, your Path's Pack |
| 3 | **The Last Ride** | Dizzy Lizzie, Carousel Queen | arena_high_rollers | 18 | a clock and a ground wall: damage that is never blocked (Flying, Elusive, damage straight to her) wins before her turn 7 | 250 gold, 200 XP, a Gilded Pack |
| 4 | **The Confetti Cannon** | Tilda Tinsel, Confetti Cannoneer | arena_two_of_a_kind | 20 | a rule that cuts both ways: the cannon kills your small units too, and every unit of yours that dies costs HER 2 HP | 300 gold, 250 XP, a Gilded Pack |
| 5 | **All In** | "Honest" Hal Lowball | arena_full_house | 23 | an alternate win: control seven units at once and Hal folds on the spot, however much HP he has left | 400 gold, 300 XP, a Prismatic Pack |

## 1. The Tea Garden Grows (Madame Darjeeling)

*One sprout a turn, and every one of them grows by two. By teatime they are taller than the house.*  Octavia's hint: "Every great oak was a sprout once, darling. The trick is to weed the garden before it learns to bite."

**HP 56.** House rules:

- **The House Plays No Cards** (hers): Madame Darjeeling's deck is all Infrastructure: no card is ever played from it. Everything that happens is on this list, the same way, in the same order, every time you sit down.
- **Steeping** (hers): At the start of each of her turns, every unit she controls gets +2/+2 for good.
- **Wild Growth** (hers): Her sprouts never block: they only grow, and charge.
- **Deep Roots** (hers): Her sprouts have Bulldoze: whatever a blocker can't soak goes through to you.
- **Tea Time** (hers): Then, each of her turns, a new 1/1 Tea Sprout comes up (it grows from her next turn on).

**The weakness:** the snowball: kill the sprouts while they are small (cheap removal, Toxic blockers, bounce: a token sent back is gone).

**Simulated** (`docs/design/sim/nov26n/puzzles_final_deckpuzzle_tea_garden.md`, 12 games a deck (table 2: 8), seeds 8100+; the sim's player is the planning AI at Elite skill with its level's gear, or the gear listed):

| Puzzle | Deck | Kind | L | Won | Turns (wins) | HP left (wins) | Foe HP left (losses) |
|---|---|---|---:|---:|---:|---:|---:|
| The Tea Garden Grows | Exploit: Weed Whacker (Beefcake removal) | exploit | 14 | **10/12** | 8.5 | 8.8 | 23.0 |
| The Tea Garden Grows | Exploit: Garden Pests (Refusemancer traps) | exploit | 14 | **7/12** | 9.4 | 14.7 | 44.6 |
| The Tea Garden Grows | Exploit: Kitchen Traps (Gourmand) | exploit | 14 | **4/12** | 10.8 | 10.5 | 32.0 |
| The Tea Garden Grows | Late: Beefcake Titans (L25) | late | 25 | **2/12** | 8.0 | 17.5 | 23.0 |
| The Tea Garden Grows | Late: Necrocrat Board Control (L25) | late | 25 | **12/12** | 9.0 | 18.1 | - |
| The Tea Garden Grows | Late: Gourmand Golem Kitchen (L25) | late | 25 | **11/12** | 8.6 | 21.4 | 43.0 |
| The Tea Garden Grows | Late: Refusemancer Heap (L25) | late | 25 | **12/12** | 7.5 | 20.0 | - |
| The Tea Garden Grows | Reference: Beefcake L14 | reference | 14 | **1/12** | 8.0 | 12.0 | 21.2 |
| The Tea Garden Grows | Reference: Necrocrat L14 | reference | 14 | **6/12** | 9.7 | 14.2 | 24.5 |
| The Tea Garden Grows | Reference: Gourmand L14 | reference | 14 | **6/12** | 8.2 | 12.3 | 23.2 |
| The Tea Garden Grows | Reference: Refusemancer L14 | reference | 14 | **4/12** | 7.0 | 16.8 | 18.1 |

**The decks** (every list is 45+ cards within the copy caps of its level):

- **Exploit: Weed Whacker (Beefcake removal)** (L14): 3x Dropped Weights, 3x Desk Flip, 3x Kettlebell, 3x Shot Putter, 3x Hammer Thrower, 3x Overclocked Mill Worker, 3x Late-ish Courier, 3x Portal Ripper, 3x Leg Day Survivor, 3x Counterweight, 16x basic Beefcake Infrastructure.
- **Exploit: Garden Pests (Refusemancer traps)** (L14): 3x Garbage Pit, 3x Rusty Spring Trap, 3x Turf War, 3x Junkyard Giraffe, 3x Heap Tortoise, 3x Kidding Around, 3x Curbside Rat, 3x Let Them Eat Cake, 3x Alley Scrap, 3x Acid Vomitor, 16x basic Refusemancer Infrastructure.
- **Exploit: Kitchen Traps (Gourmand)** (L14): 3x Health Code Violation, 3x Sent Back to the Kitchen, 3x Dinner Is Served, 3x Pest Control, 3x Food Critic, 3x Sourdough Sentry, 3x En Garde-Manger, 3x Soup Kitchen Volunteer, 3x Sous Chef, 2x Plate It, 17x basic Gourmand Infrastructure.
- **Late: Beefcake Titans (L25)** (L25): 3x Portal-Ripping Titan, 3x Hulking Hauler, 3x Bomb in the Pack, 3x Protein Farts, 3x Swole Patrol Sergeant, 3x Baron Quadzilla, Lord of Leg Day, 3x Beefy Bouncer, 3x The Carpool, 3x Yeet, 3x Flex on 'Em, 2x The Big Unit, 2x Barbell of the Ancients, 3x Hammer Thrower, 18x basic Beefcake Infrastructure. Gear: saucepan_helmet, cardboard_cuirass, glass_jaw_gauntlets, dog_eared_bookmark, travelers_boots.
- **Late: Necrocrat Board Control (L25)** (L25): 3x Mass Layoffs, 3x Final Notice, 3x Pink Slip, 3x Lich of Accounts Payable, 3x Middle Management Zombie, 3x Post-Human Resources Ghoul, 3x Grave Shift Worker, 3x Audit Wraith, 3x Notary Wraith, 3x Hazmat Intern, 3x Pending Approval, 2x Mandatory Optional Team Meeting, 2x Unconscionable Contract, 3x Hall of Records, 15x basic Necrocrat Infrastructure. Gear: saucepan_helmet, cardboard_cuirass, glass_jaw_gauntlets, dog_eared_bookmark, travelers_boots.
- **Late: Gourmand Golem Kitchen (L25)** (L25): 2x Grand Chef Escoffina, 3x Chef de Golem, 2x The Infinite Pantry, 1x The Eternal Banquet, 3x Head Health Inspector, 3x Toro Toro, 3x Meatloaf Mold, 3x The Cullinator, 3x Pastry Artificer, 3x Stock The Pantry, 2x Banquet Hall, 3x Plate It, 3x Food Critic, 16x basic Gourmand Infrastructure. Gear: saucepan_helmet, cardboard_cuirass, glass_jaw_gauntlets, dog_eared_bookmark, travelers_boots.
- **Late: Refusemancer Heap (L25)** (L25): 2x Archdruid Compostella, 2x The Mother Heap, 2x Mount Trashmore, 3x Landfill Leviathan, 3x Poo-uid, 2x Raccoon, 3x Sewer Choir, 3x Acid Vomitor, 3x Manure Miracle, 3x Heap Tortoise, 3x Junkyard Giraffe, 3x Kidding Around, 16x basic Refusemancer Infrastructure. Gear: saucepan_helmet, cardboard_cuirass, glass_jaw_gauntlets, dog_eared_bookmark, travelers_boots.
- **Reference decks**: each Path's `ProgressionModel.reference_deck` at L14 with `equipment_for` / `items_for` of that level.

**A recorded winning line** (Exploit: Weed Whacker (Beefcake removal), the player's shuffle seed 8101, won on turn 9; the test replays it):

```
turn 0 begins: you 19 HP, Madame Darjeeling 56 HP; her side: nothing; your side: nothing
turn 1 begins: you 19 HP, Madame Darjeeling 56 HP; her side: nothing; your side: nothing
turn 2 begins: you 19 HP, Madame Darjeeling 56 HP; her side: Tea Sprout 1/1; your side: nothing
turn 2: you use an item
turn 3 begins: you 19 HP, Madame Darjeeling 56 HP; her side: Tea Sprout 1/1; your side: nothing
turn 3, you: plays Overclocked Mill Worker
turn 4 begins: you 19 HP, Madame Darjeeling 56 HP; her side: Tea Sprout 3/3, Tea Sprout 1/1; your side: Overclocked Mill Worker 4/4
turn 4, you: plays Leg Day Survivor
turn 4, you: attacks with Overclocked Mill Worker, Leg Day Survivor
turn 4, Madame Darjeeling: attacks with Tea Sprout
turn 5 begins: you 14 HP, Madame Darjeeling 46 HP; her side: Tea Sprout 5/5, Tea Sprout 3/3, Tea Sprout 1/1; your side: Overclocked Mill Worker 4/4, Leg Day Survivor 6/2
turn 5: you use an item
turn 5, you: plays Hammer Thrower
turn 5, you: uses a resource
turn 5, you: attacks with Overclocked Mill Worker, Leg Day Survivor
turn 5, Madame Darjeeling: attacks with Tea Sprout, Tea Sprout
turn 5, you: Hammer Thrower blocks Tea Sprout
turn 6 begins: you 9 HP, Madame Darjeeling 35 HP; her side: Tea Sprout 7/7, Tea Sprout 3/3, Tea Sprout 1/1; your side: Overclocked Mill Worker 4/4, Leg Day Survivor 6/2
turn 6: you use an item
turn 6, you: plays Desk Flip on Tea Sprout
turn 6, you: plays Counterweight
turn 6, you: uses a resource
turn 6, you: attacks with Overclocked Mill Worker, Leg Day Survivor
turn 6, Madame Darjeeling: attacks with Tea Sprout
turn 6, you: Overclocked Mill Worker blocks Tea Sprout
turn 7 begins: you 8 HP, Madame Darjeeling 24 HP; her side: Tea Sprout 3/3, Tea Sprout 1/1; your side: Leg Day Survivor 6/2
turn 7, you: plays Portal Ripper on Tea Sprout
turn 7, you: plays Counterweight
turn 7, you: attacks with Leg Day Survivor, Portal Ripper
turn 7, Madame Darjeeling: attacks with Tea Sprout, Tea Sprout
turn 8 begins: you 5 HP, Madame Darjeeling 14 HP; her side: Tea Sprout 3/3, Tea Sprout 1/1; your side: Leg Day Survivor 6/2, Portal Ripper 4/2
turn 8, you: plays Desk Flip on Tea Sprout
turn 8, you: uses a resource
turn 8, you: uses a resource
turn 8, you: attacks with Leg Day Survivor, Portal Ripper
turn 8, Madame Darjeeling: attacks with Tea Sprout
turn 9 begins: you 2 HP, Madame Darjeeling 2 HP; her side: Tea Sprout 3/3, Tea Sprout 1/1; your side: Leg Day Survivor 6/2, Portal Ripper 4/2
turn 9, you: plays Kettlebell
turn 9, you: uses Kettlebell
turn 9, you: uses a resource
turn 9, you: attacks with Leg Day Survivor, Portal Ripper
result: WIN (turn 9, your HP 2, Madame Darjeeling HP -9)
```

## 2. Behind the Velvet Rope (Maurice, Head of Security)

*Twenty-four bouncers in six turns, a cover charge every turn, and Maurice drinks for free.*  Octavia's hint: "Twenty-four bouncers and one velvet rope. Nobody gets past them one at a time, darling. All at once, though..."

**HP 40.** House rules:

- **The House Plays No Cards** (hers): Maurice's deck is all Infrastructure: no card is ever played from it. Everything that happens is on this list, the same way, in the same order, every time you sit down.
- **Doors Open** (hers): For his first six turns, four 4/4 Velvet Bouncers take their places each turn (Wallflower, Swat and Sucker Punch: they block, flyers too, hit first, and never attack).
- **Nobody Gets Past** (hers): Maurice's bouncers block every attacker they can, every time.
- **Cover Charge** (hers): At the start of each of his turns you pay the cover: you take 2 damage.
- **Comped Drinks** (hers): At the start of each of his turns Maurice gains 2 HP.
- **Last Call** (timed, shown from the start): On his turn 6, once that turn's bouncers are in, the doors close: no more Velvet Bouncers arrive after it.

**The weakness:** a wall of 1/4 blockers: a board wipe (4 damage to every unit, or destroy them all) clears the lot.

**Simulated** (`docs/design/sim/nov26n/puzzles_final_deckpuzzle_velvet_rope.md`, 12 games a deck (table 2: 8), seeds 8100+; the sim's player is the planning AI at Elite skill with its level's gear, or the gear listed):

| Puzzle | Deck | Kind | L | Won | Turns (wins) | HP left (wins) | Foe HP left (losses) |
|---|---|---|---:|---:|---:|---:|---:|
| Behind the Velvet Rope | Exploit: Bomb Squad (Beefcake) | exploit | 16 | **8/8** | 10.3 | 6.1 | - |
| Behind the Velvet Rope | Exploit: The Layoff (Necrocrat) | exploit | 16 | **2/8** | 12.5 | 3.5 | 30.5 |
| Behind the Velvet Rope | Exploit: Velvet Gloves (Elusive scouts + Beefcake tools) | exploit | 16 | **6/8** | 7.3 | 9.3 | 40.0 |
| Behind the Velvet Rope | Late: Beefcake Titans (L25) | late | 25 | **8/8** | 9.5 | 13.3 | - |
| Behind the Velvet Rope | Late: Necrocrat Board Control (L25) | late | 25 | **6/8** | 12.2 | 6.0 | 26.5 |
| Behind the Velvet Rope | Late: Gourmand Golem Kitchen (L25) | late | 25 | **8/8** | 12.0 | 13.3 | - |
| Behind the Velvet Rope | Late: Refusemancer Heap (L25) | late | 25 | **8/8** | 11.4 | 4.8 | - |
| Behind the Velvet Rope | Reference: Beefcake L16 | reference | 16 | **6/8** | 11.5 | 7.3 | 40.0 |
| Behind the Velvet Rope | Reference: Necrocrat L16 | reference | 16 | **0/8** | - | - | 39.9 |
| Behind the Velvet Rope | Reference: Gourmand L16 | reference | 16 | **6/8** | 12.5 | 8.3 | 35.5 |
| Behind the Velvet Rope | Reference: Refusemancer L16 | reference | 16 | **1/8** | 11.0 | 2.0 | 40.0 |

**The decks** (every list is 45+ cards within the copy caps of its level):

- **Exploit: Bomb Squad (Beefcake)** (L16): 2x Bomb in the Pack, 3x Flex on 'Em, 3x Hammer Thrower, 3x Hulking Hauler, 3x Leg Day Survivor, 3x Beefy Bouncer, 3x The Carpool, 3x Portal Ripper, 3x Late-ish Courier, 3x Yeet, 2x Protein Shake, 18x basic Beefcake Infrastructure.
- **Exploit: The Layoff (Necrocrat)** (L16): 2x Mass Layoffs, 3x Pending Approval, 3x Infernal Intern, 3x Notary Wraith, 3x Audit Wraith, 3x Soul Collector, 2x Middle Management Zombie, 3x Post-Human Resources Ghoul, 3x Grave Shift Worker, 3x Pink Slip, 2x Final Notice, 18x basic Necrocrat Infrastructure.
- **Exploit: Velvet Gloves (Elusive scouts + Beefcake tools)** (L16): 3x Resistance Scout, 3x Traveler's Sword, 3x Adventurer's Pack, 3x Bronzer, 3x Lifting Gloves, 3x Sledgehammer, 3x Weight Belt, 3x Pre-Workout Canister, 3x Flex on 'Em, 3x Late-ish Courier, 18x basic Beefcake Infrastructure.
- **Late: Beefcake Titans (L25)** (L25): 3x Portal-Ripping Titan, 3x Hulking Hauler, 3x Bomb in the Pack, 3x Protein Farts, 3x Swole Patrol Sergeant, 3x Baron Quadzilla, Lord of Leg Day, 3x Beefy Bouncer, 3x The Carpool, 3x Yeet, 3x Flex on 'Em, 2x The Big Unit, 2x Barbell of the Ancients, 3x Hammer Thrower, 18x basic Beefcake Infrastructure. Gear: saucepan_helmet, cardboard_cuirass, glass_jaw_gauntlets, dog_eared_bookmark, travelers_boots.
- **Late: Necrocrat Board Control (L25)** (L25): 3x Mass Layoffs, 3x Final Notice, 3x Pink Slip, 3x Lich of Accounts Payable, 3x Middle Management Zombie, 3x Post-Human Resources Ghoul, 3x Grave Shift Worker, 3x Audit Wraith, 3x Notary Wraith, 3x Hazmat Intern, 3x Pending Approval, 2x Mandatory Optional Team Meeting, 2x Unconscionable Contract, 3x Hall of Records, 15x basic Necrocrat Infrastructure. Gear: saucepan_helmet, cardboard_cuirass, glass_jaw_gauntlets, dog_eared_bookmark, travelers_boots.
- **Late: Gourmand Golem Kitchen (L25)** (L25): 2x Grand Chef Escoffina, 3x Chef de Golem, 2x The Infinite Pantry, 1x The Eternal Banquet, 3x Head Health Inspector, 3x Toro Toro, 3x Meatloaf Mold, 3x The Cullinator, 3x Pastry Artificer, 3x Stock The Pantry, 2x Banquet Hall, 3x Plate It, 3x Food Critic, 16x basic Gourmand Infrastructure. Gear: saucepan_helmet, cardboard_cuirass, glass_jaw_gauntlets, dog_eared_bookmark, travelers_boots.
- **Late: Refusemancer Heap (L25)** (L25): 2x Archdruid Compostella, 2x The Mother Heap, 2x Mount Trashmore, 3x Landfill Leviathan, 3x Poo-uid, 2x Raccoon, 3x Sewer Choir, 3x Acid Vomitor, 3x Manure Miracle, 3x Heap Tortoise, 3x Junkyard Giraffe, 3x Kidding Around, 16x basic Refusemancer Infrastructure. Gear: saucepan_helmet, cardboard_cuirass, glass_jaw_gauntlets, dog_eared_bookmark, travelers_boots.
- **Reference decks**: each Path's `ProgressionModel.reference_deck` at L16 with `equipment_for` / `items_for` of that level.

**A recorded winning line** (Exploit: Bomb Squad (Beefcake), the player's shuffle seed 8100, won on turn 9; the test replays it):

```
turn 0 begins: you 18 HP, Maurice, Head of Security 40 HP; her side: nothing; your side: nothing
turn 1 begins: you 18 HP, Maurice, Head of Security 40 HP; her side: nothing; your side: nothing
turn 2 begins: you 16 HP, Maurice, Head of Security 40 HP; her side: Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4; your side: nothing
turn 2, you: plays Late-ish Courier
turn 3 begins: you 14 HP, Maurice, Head of Security 40 HP; her side: Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4; your side: Late-ish Courier 5/2
turn 3: you use an item
turn 3, you: plays Portal Ripper on Velvet Bouncer
turn 4 begins: you 16 HP, Maurice, Head of Security 40 HP; her side: Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4; your side: Late-ish Courier 5/2, Portal Ripper 5/3
turn 4, you: plays The Carpool
turn 5 begins: you 14 HP, Maurice, Head of Security 40 HP; her side: Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4; your side: Late-ish Courier 5/2, Portal Ripper 5/3, The Carpool 6/4
turn 5, you: plays The Carpool
turn 6 begins: you 12 HP, Maurice, Head of Security 40 HP; her side: Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4; your side: Late-ish Courier 5/2, Portal Ripper 5/3, The Carpool 6/4, The Carpool 6/4
turn 6, you: plays Bomb in the Pack
turn 6, you: attacks with Late-ish Courier, Portal Ripper, The Carpool, The Carpool
turn 6: a scripted moment fires (1 so far)
turn 7 begins: you 10 HP, Maurice, Head of Security 20 HP; her side: Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4, Velvet Bouncer 4/4; your side: Late-ish Courier 5/2, Portal Ripper 5/3, The Carpool 6/4, The Carpool 6/4
turn 7, you: uses a resource
turn 7, you: uses a resource
turn 7, you: plays Flex on 'Em
turn 7, you: attacks with The Carpool, The Carpool
turn 7, Maurice, Head of Security: Velvet Bouncer blocks The Carpool, Velvet Bouncer blocks The Carpool
turn 8 begins: you 8 HP, Maurice, Head of Security 18 HP; her side: Velvet Bouncer 4/4, Velvet Bouncer 4/4; your side: Late-ish Courier 5/2, Portal Ripper 5/3, The Carpool 6/4, The Carpool 6/4
turn 8, you: plays Beefy Bouncer
turn 9 begins: you 6 HP, Maurice, Head of Security 20 HP; her side: Velvet Bouncer 4/4, Velvet Bouncer 4/4; your side: Late-ish Courier 5/2, Portal Ripper 5/3, The Carpool 6/4, The Carpool 6/4, Beefy Bouncer 8/5
turn 9, you: plays Portal Ripper on Velvet Bouncer
turn 9, you: uses a resource
turn 9, you: uses a resource
turn 9, you: attacks with Late-ish Courier, Portal Ripper, The Carpool, The Carpool, Beefy Bouncer, Portal Ripper
turn 9, Maurice, Head of Security: Velvet Bouncer blocks Beefy Bouncer
result: WIN (turn 9, your HP 6, Maurice, Head of Security HP -13)
```

## 3. The Last Ride (Dizzy Lizzie, Carousel Queen)

*A wall of painted ponies, a pony more every turn, and the ride ends on her seventh turn - whoever is still standing.*  Octavia's hint: "My ponies are lovely, sweetheart, but they never leave the ground. Mind the clock: the music always stops."

**HP 22.** House rules:

- **The House Plays No Cards** (hers): Dizzy Lizzie's deck is all Infrastructure: no card is ever played from it. Everything that happens is on this list, the same way, in the same order, every time you sit down.
- **All Aboard** (hers): She starts with four 0/6 Painted Ponies (Wallflower: they block, they never attack).
- **Round and Round** (hers): Two more 0/6 Painted Ponies join the carousel at the start of each of her turns.
- **Hold the Reins** (hers): Her ponies block every attacker they can, every time.
- **The Ride Ends** (timed, shown from the start): At the start of her 7th turn the music stops for good: if Lizzie is still standing, you lose the bout.

**The weakness:** a clock and a ground wall: damage that is never blocked (Flying, Elusive, damage straight to her) wins before her turn 7.

**Simulated** (`docs/design/sim/nov26n/puzzles_final_deckpuzzle_last_ride.md`, 12 games a deck (table 2: 8), seeds 8100+; the sim's player is the planning AI at Elite skill with its level's gear, or the gear listed):

| Puzzle | Deck | Kind | L | Won | Turns (wins) | HP left (wins) | Foe HP left (losses) |
|---|---|---|---:|---:|---:|---:|---:|
| The Last Ride | Exploit: Flying Circus (Necrocrat flyers) | exploit | 18 | **11/12** | 5.9 | 19.0 | 7.0 |
| The Last Ride | Exploit: Burn Notice (Beefcake burn to face) | exploit | 18 | **1/12** | 6.0 | 19.0 | 17.5 |
| The Last Ride | Exploit: Ghost Kitchen (Gourmand-Necrocrat flyers) | exploit | 18 | **12/12** | 5.3 | 19.0 | - |
| The Last Ride | Late: Beefcake Titans (L25) | late | 25 | **8/12** | 6.8 | 11.0 | 6.5 |
| The Last Ride | Late: Necrocrat Board Control (L25) | late | 25 | **10/12** | 6.9 | 11.0 | 15.0 |
| The Last Ride | Late: Gourmand Golem Kitchen (L25) | late | 25 | **0/12** | - | - | 21.3 |
| The Last Ride | Late: Refusemancer Heap (L25) | late | 25 | **0/12** | - | - | 19.6 |
| The Last Ride | Reference: Beefcake L18 | reference | 18 | **1/12** | 7.0 | 19.0 | 20.8 |
| The Last Ride | Reference: Necrocrat L18 | reference | 18 | **1/12** | 6.0 | 19.0 | 13.7 |
| The Last Ride | Reference: Gourmand L18 | reference | 18 | **0/12** | - | - | 20.3 |
| The Last Ride | Reference: Refusemancer L18 | reference | 18 | **0/12** | - | - | 18.0 |

**The decks** (every list is 45+ cards within the copy caps of its level):

- **Exploit: Flying Circus (Necrocrat flyers)** (L18): 3x Notary Wraith, 3x Audit Wraith, 3x Soul Collector, 3x Courier Pigeon, 3x Corporate-Approved Pen, 3x Traveler's Sword, 3x Rally the Village, 3x Infernal Intern, 3x Skeleton Clerk, 3x Compliance Review, 18x basic Necrocrat Infrastructure.
- **Exploit: Burn Notice (Beefcake burn to face)** (L18): 3x Flex on 'Em, 3x Hammer Thrower, 3x Yeet, 3x Hulking Hauler, 3x Leg Day Survivor, 3x The Carpool, 3x Portal Ripper, 3x Shot Putter, 3x Protein Shake, 3x Pre-Workout Canister, 18x basic Beefcake Infrastructure.
- **Exploit: Ghost Kitchen (Gourmand-Necrocrat flyers)** (L18): 2x The Haunted Buffet, 3x Ghost Pepper, 2x Ghoul Sommelier, 3x Line Cook, 3x Stock The Pantry, 3x Notary Wraith, 3x Audit Wraith, 3x Soul Collector, 3x Amuse-Bouche, 3x Sous Boo, 9x basic Gourmand Infrastructure, 9x basic Necrocrat Infrastructure.
- **Late: Beefcake Titans (L25)** (L25): 3x Portal-Ripping Titan, 3x Hulking Hauler, 3x Bomb in the Pack, 3x Protein Farts, 3x Swole Patrol Sergeant, 3x Baron Quadzilla, Lord of Leg Day, 3x Beefy Bouncer, 3x The Carpool, 3x Yeet, 3x Flex on 'Em, 2x The Big Unit, 2x Barbell of the Ancients, 3x Hammer Thrower, 18x basic Beefcake Infrastructure.
- **Late: Necrocrat Board Control (L25)** (L25): 3x Mass Layoffs, 3x Final Notice, 3x Pink Slip, 3x Lich of Accounts Payable, 3x Middle Management Zombie, 3x Post-Human Resources Ghoul, 3x Grave Shift Worker, 3x Audit Wraith, 3x Notary Wraith, 3x Hazmat Intern, 3x Pending Approval, 2x Mandatory Optional Team Meeting, 2x Unconscionable Contract, 3x Hall of Records, 15x basic Necrocrat Infrastructure.
- **Late: Gourmand Golem Kitchen (L25)** (L25): 2x Grand Chef Escoffina, 3x Chef de Golem, 2x The Infinite Pantry, 1x The Eternal Banquet, 3x Head Health Inspector, 3x Toro Toro, 3x Meatloaf Mold, 3x The Cullinator, 3x Pastry Artificer, 3x Stock The Pantry, 2x Banquet Hall, 3x Plate It, 3x Food Critic, 16x basic Gourmand Infrastructure. Gear: saucepan_helmet, cardboard_cuirass, glass_jaw_gauntlets, dog_eared_bookmark, travelers_boots.
- **Late: Refusemancer Heap (L25)** (L25): 2x Archdruid Compostella, 2x The Mother Heap, 2x Mount Trashmore, 3x Landfill Leviathan, 3x Poo-uid, 2x Raccoon, 3x Sewer Choir, 3x Acid Vomitor, 3x Manure Miracle, 3x Heap Tortoise, 3x Junkyard Giraffe, 3x Kidding Around, 16x basic Refusemancer Infrastructure. Gear: saucepan_helmet, cardboard_cuirass, glass_jaw_gauntlets, dog_eared_bookmark, travelers_boots.
- **Reference decks**: each Path's `ProgressionModel.reference_deck` at L18 with `equipment_for` / `items_for` of that level.

**A recorded winning line** (Exploit: Flying Circus (Necrocrat flyers), the player's shuffle seed 8100, won on turn 7; the test replays it):

```
turn 0 begins: you 19 HP, Dizzy Lizzie, Carousel Queen 22 HP; her side: nothing; your side: nothing
turn 1 begins: you 19 HP, Dizzy Lizzie, Carousel Queen 22 HP; her side: Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6; your side: nothing
turn 2 begins: you 19 HP, Dizzy Lizzie, Carousel Queen 22 HP; her side: Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6; your side: nothing
turn 2, you: plays Infernal Intern
turn 3 begins: you 19 HP, Dizzy Lizzie, Carousel Queen 22 HP; her side: Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6; your side: Infernal Intern 5/3
turn 3, you: plays Infernal Intern
turn 3, you: attacks with Infernal Intern
turn 3, Dizzy Lizzie, Carousel Queen: Painted Pony blocks Infernal Intern
turn 3: you use an item
turn 4 begins: you 19 HP, Dizzy Lizzie, Carousel Queen 22 HP; her side: Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6; your side: Infernal Intern 5/3, Infernal Intern 5/3
turn 4, you: plays Soul Collector
turn 4, you: attacks with Infernal Intern, Infernal Intern
turn 4, Dizzy Lizzie, Carousel Queen: Painted Pony blocks Infernal Intern, Painted Pony blocks Infernal Intern
turn 5 begins: you 19 HP, Dizzy Lizzie, Carousel Queen 20 HP; her side: Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6; your side: Infernal Intern 5/3, Infernal Intern 5/3, Soul Collector 5/4
turn 5, you: plays Audit Wraith
turn 5, you: plays Traveler's Sword
turn 5, you: uses Traveler's Sword
turn 5, you: attacks with Infernal Intern, Infernal Intern, Soul Collector
turn 5, Dizzy Lizzie, Carousel Queen: Painted Pony blocks Infernal Intern, Painted Pony blocks Infernal Intern
turn 6 begins: you 19 HP, Dizzy Lizzie, Carousel Queen 15 HP; her side: Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6; your side: Infernal Intern 7/3, Infernal Intern 5/3, Soul Collector 5/4, Audit Wraith 5/3
turn 6, you: plays Traveler's Sword
turn 6, you: plays Courier Pigeon
turn 6, you: uses Traveler's Sword
turn 6, you: attacks with Infernal Intern, Infernal Intern, Soul Collector, Audit Wraith
turn 6, Dizzy Lizzie, Carousel Queen: Painted Pony blocks Infernal Intern, Painted Pony blocks Infernal Intern
turn 7 begins: you 19 HP, Dizzy Lizzie, Carousel Queen 3 HP; her side: Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6, Painted Pony 0/6; your side: Infernal Intern 7/3, Infernal Intern 5/3, Soul Collector 7/4, Audit Wraith 5/3, Courier Pigeon 4/2
turn 7, you: uses Traveler's Sword
turn 7, you: plays Corporate-Approved Pen
turn 7, you: uses Corporate-Approved Pen
turn 7, you: attacks with Infernal Intern, Infernal Intern, Soul Collector, Audit Wraith, Courier Pigeon
turn 7, Dizzy Lizzie, Carousel Queen: Painted Pony blocks Infernal Intern, Painted Pony blocks Infernal Intern
result: WIN (turn 7, your HP 19, Dizzy Lizzie, Carousel Queen HP -15)
```

## 4. The Confetti Cannon (Tilda Tinsel, Confetti Cannoneer)

*Two critters a turn, a cannon that pops every unit on the table, and a crowd that cheers every time one of hers falls.*  Octavia's hint: "The crowd adores a tragic exit, darling, and they're not fussy about whose. Count the curtain calls."

**HP 38.** House rules:

- **The House Plays No Cards** (hers): Tilda Tinsel's deck is all Infrastructure: no card is ever played from it. Everything that happens is on this list, the same way, in the same order, every time you sit down.
- **Fire the Cannon!** (hers): At the start of each of her turns the cannon goes off: 1 damage to every unit on the table, hers and yours.
- **Encore!** (hers): Then two 1/1 Confetti Critters land on her side, each of her turns.
- **Into the Breach** (hers): Her critters throw themselves in front of every attacker they can, every time.
- **Showstopper** (hers): Whenever one of HER units dies, you lose 2 HP.
- **Showstopper (Both Ways)** (yours): Whenever one of YOUR units dies, Tilda loses 2 HP. The crowd isn't fussy.

**The weakness:** a rule that cuts both ways: the cannon kills your small units too, and every unit of yours that dies costs HER 2 HP.

**Simulated** (`docs/design/sim/nov26n/puzzles_final_deckpuzzle_confetti.md`, 12 games a deck (table 2: 8), seeds 8100+; the sim's player is the planning AI at Elite skill with its level's gear, or the gear listed):

| Puzzle | Deck | Kind | L | Won | Turns (wins) | HP left (wins) | Foe HP left (losses) |
|---|---|---|---:|---:|---:|---:|---:|
| The Confetti Cannon | Exploit: Rat Parade (Refusemancer tokens) | exploit | 20 | **11/12** | 6.1 | 4.0 | 15.0 |
| The Confetti Cannon | Exploit: Temp Agency (Necrocrat sacrifice) | exploit | 20 | **7/12** | 5.4 | 7.1 | 14.6 |
| The Confetti Cannon | Exploit: Militia Muster (Pathless tokens) | exploit | 20 | **5/12** | 6.0 | 4.0 | 9.1 |
| The Confetti Cannon | Late: Beefcake Titans (L25) | late | 25 | **11/12** | 7.2 | 6.2 | -1.0 |
| The Confetti Cannon | Late: Necrocrat Board Control (L25) | late | 25 | **6/12** | 8.0 | 3.7 | 11.7 |
| The Confetti Cannon | Late: Gourmand Golem Kitchen (L25) | late | 25 | **10/12** | 7.4 | 4.8 | 20.0 |
| The Confetti Cannon | Late: Refusemancer Heap (L25) | late | 25 | **2/12** | 7.5 | 3.0 | 14.5 |
| The Confetti Cannon | Reference: Beefcake L20 | reference | 20 | **3/12** | 7.3 | 2.7 | 16.2 |
| The Confetti Cannon | Reference: Necrocrat L20 | reference | 20 | **6/12** | 7.0 | 3.0 | 19.3 |
| The Confetti Cannon | Reference: Gourmand L20 | reference | 20 | **7/12** | 6.7 | 4.9 | 15.8 |
| The Confetti Cannon | Reference: Refusemancer L20 | reference | 20 | **4/12** | 6.0 | 3.5 | 23.3 |

**The decks** (every list is 45+ cards within the copy caps of its level):

- **Exploit: Rat Parade (Refusemancer tokens)** (L20): 3x Sewer Choir, 3x Kidding Around, 3x Curbside Rat, 3x Bird of Paradump, 3x Dumpster Diver, 3x Mulch Mole, 3x Late-Pick Hero, 3x Curb Alert, 3x Junkyard Giraffe, 3x Heap Tortoise, 18x basic Refusemancer Infrastructure.
- **Exploit: Temp Agency (Necrocrat sacrifice)** (L20): 3x Pending Approval, 2x The Breakroom, 3x I've Made a Huge Mistake, 3x Become Useful at Work, 3x Skeleton Clerk, 3x Infernal Intern, 3x Body-builder, 3x Hazmat Intern, 3x Middle Management Zombie, 3x Grave Shift Worker, 18x basic Necrocrat Infrastructure.
- **Exploit: Militia Muster (Pathless tokens)** (L20): 3x Mercenary Captain, 3x Ambush Party, 3x Cannon Fodder, 3x Courier Pigeon, 3x Village Militia, 3x Watchtower Archer, 3x Shield Bearer, 3x Tavern Regular, 3x Second Wind, 3x Rally the Village, 18x basic Beefcake Infrastructure.
- **Late: Beefcake Titans (L25)** (L25): 3x Portal-Ripping Titan, 3x Hulking Hauler, 3x Bomb in the Pack, 3x Protein Farts, 3x Swole Patrol Sergeant, 3x Baron Quadzilla, Lord of Leg Day, 3x Beefy Bouncer, 3x The Carpool, 3x Yeet, 3x Flex on 'Em, 2x The Big Unit, 2x Barbell of the Ancients, 3x Hammer Thrower, 18x basic Beefcake Infrastructure. Gear: saucepan_helmet, cardboard_cuirass, glass_jaw_gauntlets, dog_eared_bookmark, travelers_boots.
- **Late: Necrocrat Board Control (L25)** (L25): 3x Mass Layoffs, 3x Final Notice, 3x Pink Slip, 3x Lich of Accounts Payable, 3x Middle Management Zombie, 3x Post-Human Resources Ghoul, 3x Grave Shift Worker, 3x Audit Wraith, 3x Notary Wraith, 3x Hazmat Intern, 3x Pending Approval, 2x Mandatory Optional Team Meeting, 2x Unconscionable Contract, 3x Hall of Records, 15x basic Necrocrat Infrastructure. Gear: saucepan_helmet, cardboard_cuirass, glass_jaw_gauntlets, dog_eared_bookmark, travelers_boots.
- **Late: Gourmand Golem Kitchen (L25)** (L25): 2x Grand Chef Escoffina, 3x Chef de Golem, 2x The Infinite Pantry, 1x The Eternal Banquet, 3x Head Health Inspector, 3x Toro Toro, 3x Meatloaf Mold, 3x The Cullinator, 3x Pastry Artificer, 3x Stock The Pantry, 2x Banquet Hall, 3x Plate It, 3x Food Critic, 16x basic Gourmand Infrastructure. Gear: saucepan_helmet, cardboard_cuirass, glass_jaw_gauntlets, dog_eared_bookmark, travelers_boots.
- **Late: Refusemancer Heap (L25)** (L25): 2x Archdruid Compostella, 2x The Mother Heap, 2x Mount Trashmore, 3x Landfill Leviathan, 3x Poo-uid, 2x Raccoon, 3x Sewer Choir, 3x Acid Vomitor, 3x Manure Miracle, 3x Heap Tortoise, 3x Junkyard Giraffe, 3x Kidding Around, 16x basic Refusemancer Infrastructure. Gear: saucepan_helmet, cardboard_cuirass, glass_jaw_gauntlets, dog_eared_bookmark, travelers_boots.
- **Reference decks**: each Path's `ProgressionModel.reference_deck` at L20 with `equipment_for` / `items_for` of that level.

**A recorded winning line** (Exploit: Rat Parade (Refusemancer tokens), the player's shuffle seed 8100, won on turn 7; the test replays it):

```
turn 0 begins: you 20 HP, Tilda Tinsel, Confetti Cannoneer 38 HP; her side: nothing; your side: nothing
turn 1 begins: you 20 HP, Tilda Tinsel, Confetti Cannoneer 38 HP; her side: nothing; your side: nothing
turn 1, you: plays Curbside Rat
turn 2 begins: you 20 HP, Tilda Tinsel, Confetti Cannoneer 38 HP; her side: Confetti Critter 1/1, Confetti Critter 1/1; your side: Curbside Rat 4/3
turn 2: you use an item
turn 2: you use an item
turn 2, you: plays Dumpster Diver
turn 2, you: attacks with Curbside Rat
turn 2, Tilda Tinsel, Confetti Cannoneer: Confetti Critter blocks Curbside Rat
turn 2: you use an item
turn 3 begins: you 20 HP, Tilda Tinsel, Confetti Cannoneer 38 HP; her side: Confetti Critter 1/1, Confetti Critter 1/1; your side: Curbside Rat 4/3, Dumpster Diver 4/3
turn 3, you: plays Mulch Mole
turn 3, you: attacks with Curbside Rat, Dumpster Diver
turn 3, Tilda Tinsel, Confetti Cannoneer: Confetti Critter blocks Curbside Rat, Confetti Critter blocks Dumpster Diver
turn 4 begins: you 16 HP, Tilda Tinsel, Confetti Cannoneer 38 HP; her side: Confetti Critter 1/1, Confetti Critter 1/1; your side: Curbside Rat 4/3, Dumpster Diver 4/3, Mulch Mole 3/3
turn 4, you: uses Mulch Mole
turn 4, you: plays Heap Tortoise
turn 4, you: attacks with Curbside Rat, Dumpster Diver
turn 4, Tilda Tinsel, Confetti Cannoneer: Confetti Critter blocks Curbside Rat, Confetti Critter blocks Dumpster Diver
turn 5 begins: you 12 HP, Tilda Tinsel, Confetti Cannoneer 38 HP; her side: Confetti Critter 1/1, Confetti Critter 1/1; your side: Curbside Rat 4/3, Dumpster Diver 4/3, Mulch Mole 3/3, Heap Tortoise 8/7
turn 5, you: plays Kidding Around
turn 5, you: plays Mulch Mole
turn 5, you: attacks with Heap Tortoise, Curbside Rat, Dumpster Diver
turn 5, Tilda Tinsel, Confetti Cannoneer: Confetti Critter blocks Heap Tortoise, Confetti Critter blocks Curbside Rat
turn 6 begins: you 8 HP, Tilda Tinsel, Confetti Cannoneer 34 HP; her side: Confetti Critter 1/1, Confetti Critter 1/1; your side: Curbside Rat 4/3, Dumpster Diver 4/3, Mulch Mole 3/3, Heap Tortoise 8/7, Kidding Around 5/4, Goat 4/2, Mulch Mole 3/3
turn 6, you: plays Bird of Paradump
turn 6, you: attacks with Heap Tortoise, Kidding Around, Curbside Rat, Dumpster Diver, Goat, Mulch Mole
turn 6, Tilda Tinsel, Confetti Cannoneer: Confetti Critter blocks Heap Tortoise, Confetti Critter blocks Kidding Around
turn 6, you: uses Mulch Mole
turn 6, you: uses Mulch Mole
turn 7 begins: you 6 HP, Tilda Tinsel, Confetti Cannoneer 19 HP; her side: Confetti Critter 1/1, Confetti Critter 1/1; your side: Curbside Rat 4/3, Dumpster Diver 4/3, Mulch Mole 3/3, Heap Tortoise 8/7, Kidding Around 5/4, Goat 4/2, Mulch Mole 3/3, Bird of Paradump 3/2
turn 7, you: attacks with Curbside Rat, Dumpster Diver, Mulch Mole, Heap Tortoise, Kidding Around, Goat, Mulch Mole, Bird of Paradump
turn 7, Tilda Tinsel, Confetti Cannoneer: Confetti Critter blocks Heap Tortoise, Confetti Critter blocks Kidding Around
result: WIN (turn 7, your HP 2, Tilda Tinsel, Confetti Cannoneer HP -2)
```

## 5. All In ("Honest" Hal Lowball)

*A pit boss every turn, a sweep of the felt every turn, fifty-two HP - and a dealer who has never once sat at a full table.*  Octavia's hint: "Hal can't abide a crowded table, darling. He's never beaten one. Then again, he's never let one sit down."

**HP 52.** House rules:

- **The House Plays No Cards** (hers): Hal's deck is all Infrastructure: no card is ever played from it. Everything that happens is on this list, the same way, in the same order, every time you sit down.
- **Sweep the Felt** (hers): At the start of each of his turns Hal sweeps the table: 2 damage to each of your units.
- **The Pit Boss** (hers): Then a 3/4 Pit Boss with Bulldoze joins him, each of his turns.
- **Hal Folds** (timed, shown from the start): The moment you control seven or more units at once, Hal folds: you win the bout on the spot, however much HP he has.

**The weakness:** an alternate win: control seven units at once and Hal folds on the spot, however much HP he has left.

**Simulated** (`docs/design/sim/nov26n/puzzles_final_deckpuzzle_all_in.md`, 12 games a deck (table 2: 8), seeds 8100+; the sim's player is the planning AI at Elite skill with its level's gear, or the gear listed):

| Puzzle | Deck | Kind | L | Won | Turns (wins) | HP left (wins) | Foe HP left (losses) |
|---|---|---|---:|---:|---:|---:|---:|
| All In | Exploit: Full Table (Refusemancer-Necrocrat swarm) | exploit | 23 | **0/12** | - | - | 52.0 |
| All In | Exploit: Brick Wall (Gourmand walls) | exploit | 23 | **6/12** | 7.5 | 8.8 | 42.7 |
| All In | Exploit: Mercenary Company (Pathless tokens) | exploit | 23 | **6/12** | 6.2 | 7.5 | 49.7 |
| All In | Late: Beefcake Titans (L25) | late | 25 | **9/12** | 8.7 | 8.3 | 28.3 |
| All In | Late: Necrocrat Board Control (L25) | late | 25 | **8/12** | 9.1 | 10.8 | 47.0 |
| All In | Late: Gourmand Golem Kitchen (L25) | late | 25 | **9/12** | 8.1 | 10.2 | 35.3 |
| All In | Late: Refusemancer Heap (L25) | late | 25 | **0/12** | - | - | 52.0 |
| All In | Reference: Beefcake L23 | reference | 23 | **3/12** | 9.3 | 3.3 | 37.6 |
| All In | Reference: Necrocrat L23 | reference | 23 | **8/12** | 8.6 | 4.6 | 31.3 |
| All In | Reference: Gourmand L23 | reference | 23 | **8/12** | 7.4 | 4.8 | 41.3 |
| All In | Reference: Refusemancer L23 | reference | 23 | **1/12** | 11.0 | 2.0 | 30.5 |

**The decks** (every list is 45+ cards within the copy caps of its level):

- **Exploit: Full Table (Refusemancer-Necrocrat swarm)** (L23): 3x Sewer Choir, 3x Sewer Rat Courier, 3x Plague of Rats, 3x Rat Swarm, 3x Kidding Around, 3x Pending Approval, 3x Curbside Rat, 3x Infernal Intern, 3x Bird of Paradump, 3x Skeleton Clerk, 9x basic Refusemancer Infrastructure, 9x basic Necrocrat Infrastructure. Gear: saucepan_helmet, cardboard_cuirass, glass_jaw_gauntlets, dog_eared_bookmark, travelers_boots.
- **Exploit: Brick Wall (Gourmand walls)** (L23): 3x Sourdough Sentry, 3x Shield Bearer, 3x En Garde-Manger, 3x Soup Kitchen Volunteer, 3x Sous Chef, 3x Conveyor Belt Chef, 3x Meatloaf Mold, 2x Chef de Golem, 3x Stock The Pantry, 3x Heap Tortoise, 15x basic Gourmand Infrastructure, 3x basic Refusemancer Infrastructure. Gear: saucepan_helmet, cardboard_cuirass, glass_jaw_gauntlets, dog_eared_bookmark, travelers_boots.
- **Exploit: Mercenary Company (Pathless tokens)** (L23): 3x Mercenary Captain, 3x Ambush Party, 3x Pending Approval, 3x Shield Bearer, 3x Tavern Regular, 3x Old Kingdom Automaton, 3x Watchtower Archer, 3x Middle Management Zombie, 3x Body-builder, 3x Grave Shift Worker, 18x basic Necrocrat Infrastructure. Gear: saucepan_helmet, cardboard_cuirass, glass_jaw_gauntlets, dog_eared_bookmark, travelers_boots.
- **Late: Beefcake Titans (L25)** (L25): 3x Portal-Ripping Titan, 3x Hulking Hauler, 3x Bomb in the Pack, 3x Protein Farts, 3x Swole Patrol Sergeant, 3x Baron Quadzilla, Lord of Leg Day, 3x Beefy Bouncer, 3x The Carpool, 3x Yeet, 3x Flex on 'Em, 2x The Big Unit, 2x Barbell of the Ancients, 3x Hammer Thrower, 18x basic Beefcake Infrastructure. Gear: saucepan_helmet, cardboard_cuirass, glass_jaw_gauntlets, dog_eared_bookmark, travelers_boots.
- **Late: Necrocrat Board Control (L25)** (L25): 3x Mass Layoffs, 3x Final Notice, 3x Pink Slip, 3x Lich of Accounts Payable, 3x Middle Management Zombie, 3x Post-Human Resources Ghoul, 3x Grave Shift Worker, 3x Audit Wraith, 3x Notary Wraith, 3x Hazmat Intern, 3x Pending Approval, 2x Mandatory Optional Team Meeting, 2x Unconscionable Contract, 3x Hall of Records, 15x basic Necrocrat Infrastructure. Gear: saucepan_helmet, cardboard_cuirass, glass_jaw_gauntlets, dog_eared_bookmark, travelers_boots.
- **Late: Gourmand Golem Kitchen (L25)** (L25): 2x Grand Chef Escoffina, 3x Chef de Golem, 2x The Infinite Pantry, 1x The Eternal Banquet, 3x Head Health Inspector, 3x Toro Toro, 3x Meatloaf Mold, 3x The Cullinator, 3x Pastry Artificer, 3x Stock The Pantry, 2x Banquet Hall, 3x Plate It, 3x Food Critic, 16x basic Gourmand Infrastructure. Gear: saucepan_helmet, cardboard_cuirass, glass_jaw_gauntlets, dog_eared_bookmark, travelers_boots.
- **Late: Refusemancer Heap (L25)** (L25): 2x Archdruid Compostella, 2x The Mother Heap, 2x Mount Trashmore, 3x Landfill Leviathan, 3x Poo-uid, 2x Raccoon, 3x Sewer Choir, 3x Acid Vomitor, 3x Manure Miracle, 3x Heap Tortoise, 3x Junkyard Giraffe, 3x Kidding Around, 16x basic Refusemancer Infrastructure. Gear: saucepan_helmet, cardboard_cuirass, glass_jaw_gauntlets, dog_eared_bookmark, travelers_boots.
- **Reference decks**: each Path's `ProgressionModel.reference_deck` at L23 with `equipment_for` / `items_for` of that level.

**A recorded winning line** (Exploit: Brick Wall (Gourmand walls), the player's shuffle seed 8100, won on turn 6; the test replays it):

```
turn 0 begins: you 23 HP, "Honest" Hal Lowball 52 HP; her side: nothing; your side: nothing
turn 1 begins: you 23 HP, "Honest" Hal Lowball 52 HP; her side: nothing; your side: nothing
turn 2 begins: you 23 HP, "Honest" Hal Lowball 52 HP; her side: Pit Boss 3/4; your side: nothing
turn 2, you: plays Soup Kitchen Volunteer
turn 2, "Honest" Hal Lowball: uses a resource
turn 2, "Honest" Hal Lowball: uses a resource
turn 2, "Honest" Hal Lowball: attacks with Pit Boss
turn 3 begins: you 20 HP, "Honest" Hal Lowball 52 HP; her side: Pit Boss 3/4, Pit Boss 3/4; your side: Soup Kitchen Volunteer 0/3
turn 3: you use an item
turn 3, you: plays En Garde-Manger
turn 3, you: attacks with Soup Kitchen Volunteer
turn 3, "Honest" Hal Lowball: Pit Boss blocks Soup Kitchen Volunteer
turn 3: you use an item
turn 3, "Honest" Hal Lowball: uses a resource
turn 3, "Honest" Hal Lowball: attacks with Pit Boss
turn 4 begins: you 17 HP, "Honest" Hal Lowball 52 HP; her side: Pit Boss 3/4, Pit Boss 3/4; your side: Soup Kitchen Volunteer 4/3, En Garde-Manger 2/4
turn 4: you use an item
turn 4, you: plays Conveyor Belt Chef
turn 4, "Honest" Hal Lowball: uses a resource
turn 5 begins: you 21 HP, "Honest" Hal Lowball 52 HP; her side: Pit Boss 3/4, Pit Boss 3/4, Pit Boss 3/4; your side: Soup Kitchen Volunteer 2/3, En Garde-Manger 4/4, Conveyor Belt Chef 4/3
turn 5, you: uses Conveyor Belt Chef
turn 5, you: plays Conveyor Belt Chef
turn 5, "Honest" Hal Lowball: uses a resource
turn 6 begins: you 21 HP, "Honest" Hal Lowball 52 HP; her side: Pit Boss 3/4, Pit Boss 3/4, Pit Boss 3/4, Pit Boss 3/4; your side: Soup Kitchen Volunteer 2/3, En Garde-Manger 4/4, Conveyor Belt Chef 4/3, Conveyor Belt Chef 4/3
turn 6, you: plays Sous Chef
turn 6, you: uses Conveyor Belt Chef
turn 6: a scripted moment fires (1 so far)
result: WIN (turn 6, your HP 21, "Honest" Hal Lowball HP 52)
```

