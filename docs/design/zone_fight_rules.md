# Zone dungeon fights: a rule set for every fight (Nov 26 day, Part C)

Every fight of the four zones' main dungeons and Primm's Castle now has rules of its own; the postgame is unchanged (the owner). Before today only the elites and bosses had rules. Each ordinary fight got a rule that questions how the deck was built and something the player can use; the elites and bosses keep their sets. Written by `tools/nov26_zone_fight_rules.py` (data) and `tools/nov26_zone_fight_doc.py` (this page). Test: `tests/test_nov26_zone_fight_rules.gd`.

**Win rates** are the sims' whole runs (`tools/zone_runs_nov26_tool.gd`, `tools/run_nov26_zone_sims.sh`): one HP pool along each route, each Path's reference deck, gear and items at the boss's level, played by the planning AI, 25 runs per Path and route. Per fight: won of the times it was reached, both routes together. The sim's player is weaker than a careful human (it plays its items plainly and takes no event boons), so the absolute numbers are low; the comparison is what matters.

## Whole runs

| Dungeon | Route | Cleared before | Cleared after |
|---|---|---:|---:|
| The House of Gains | A | 14 % | 7 % |
| The House of Gains | B | 24 % | 24 % |
| The Test Kitchen | A | 41 % | 43 % |
| The Test Kitchen | B | 50 % | 50 % |
| The Hall of Final Approvals | A | 36 % | 34 % |
| The Hall of Final Approvals | B | 45 % | 45 % |
| The Rotheart | A | 41 % | 41 % |
| The Rotheart | B | 52 % | 51 % |
| Primm's Castle | A (beat Primm) | 17% | 14% |
| Primm's Castle | B (beat Primm) | 3% | 3% |
| Primm's Castle | C (beat Primm) | 45% | 43% |
| Primm's Castle | D (beat Primm) | 4% | 4% |
| Primm's Castle | E (beat Primm) | 20% | 20% |

## The House of Gains

| Room | Foe | Rules (new in bold) | Scripted beats (new in bold) | The idea | Won before | Won after |
|---:|---|---|---|---|---:|---:|
| 2 | Treadmill Sprinter | **Treadmill: The Sprinter's units have Hustle: they can attack the turn they arrive.**<br>**Interval Training: Your units with Hustle get +1 attack. Keep up!** | - | a race: slow decks get run over, fast (Hustle) decks hit harder | 91 % | 85 % |
| 3 | Courtyard Lifter | **Heavy Plates: The Lifter's units get +0/+2.**<br>**Free Weights: Your Beefcake cards cost 1 less. The courtyard is open to all.** | - | tough blockers; Beefcake cards come cheaper | 96 % | 90 % |
| 8 | Cell Block Brawler | Smuggled Weights: He has been curling contraband plates under his bunk for years. The Brawler's units get +1 attack.<br>**Lights Out: You may play at most 2 cards a turn (Infrastructure does not count). The guards count heads.**<br>**Care Package: You start with one more card in your opening hand.** | - | swarms of cheap cards are capped; big single plays are not (and a deck change: necrocrat_beefcake, the prison guards) | 70 % | 70 % |
| 11 | Trophy Hall Honor Guard | **Display Case: The Guard starts with a 0/4 Trophy Case on the field (Wallflower: it blocks, it never attacks).**<br>**Hall of Fame: Your units with Flying get +1 attack. Champions fly over the cases.** | At half health a reserve guard steps off a pedestal: a 1/1 Reserve Guard joins. | a wall for ground attackers; flyers go over it | 78 % | 58 % |

Elites and bosses whose sets are unchanged (win rates move with the HP the run brings them): Vivienne Quota 55 % -> 55 %; Chancellor Clench 47 % -> 44 %

## The Test Kitchen

| Room | Foe | Rules (new in bold) | Scripted beats (new in bold) | The idea | Won before | Won after |
|---:|---|---|---|---|---:|---:|
| 2 | Prep Station Sous-Chef | **Prepped: The Sous-Chef starts the fight with 2 Ingredients.**<br>**Staff Meal: You start the fight with 2 Ingredients as well. Help yourself.** | - | both sides start with Ingredients: a Gourmand deck makes better use of them | 97 % | 95 % |
| 3 | Frozen Line Cook | **Walk-In Cooler: The Cook starts with two 0/4 Ice Blocks on the field (Wallflower: they block, they never attack).**<br>**Defrost: You start with one more card in your opening hand.** | - | walls for ground attackers; flyers, Elusive units and direct damage go round them | 99 % | 99 % |
| 8 | Assembly Line Golem | **Quality Control: Each unit that attacks the Golem takes 1 damage. Every unit is inspected.**<br>**Overtime Shift: You draw an extra card on your first turn.** | - | swarms of 1-defence units pay for attacking; big units shrug it off | 100 % | 100 % |
| 12 | Expediter of the Pass | **Plate Up: The Expediter's units get +1/+0. Hot plates, coming through.**<br>**Tasting Spoon: Whenever you gain HP, you gain 1 more.** | **On its 4th turn the pass sends out staff meal: you heal 3.** | it hits harder; decks that heal gain more (and a staff meal on its 4th turn) | 95 % | 95 % |

Elites and bosses whose sets are unchanged (win rates move with the HP the run brings them): Unfinished War Machine 79 % -> 80 %; Cannon-Blender Gunner 83 % -> 84 %; The Doppelganger 67 % -> 68 %

## The Hall of Final Approvals

| Room | Foe | Rules (new in bold) | Scripted beats (new in bold) | The idea | Won before | Won after |
|---:|---|---|---|---|---:|---:|
| 3 | Intake Clerk | **Forms Only: You cannot play Tools in this fight. The form has no box for them.**<br>**Expedited: Your units get +1/+0.** | - | Tool decks are refused at the desk; unit decks are waved through faster | 95 % | 95 % |
| 4 | Returns Clerk | **Refund Policy: At the start of its turn the Clerk heals 1.**<br>**Receipt Kept: You start the fight with a Contract (pay 1, use it: exhaust target unit).** | - | a slow grind punishes slow decks; a Contract to stop its best blocker | 97 % | 99 % |
| 9 | Resurrection Permits Zombie | **Burial Fees Waived: Your Necrocrat cards cost 1 less.** | **When two of its units have died, a permit is granted: two 1/1 Zombie Temps climb back up.** | trading units feeds it more; a Necrocrat deck pays less | 95 % | 92 % |
| 13 | Executive Elevator Operator | **Express Lift: Your units with Flying get +1 attack. The shaft goes all the way up.** | **On its 4th turn the lift reaches the executive floors: the Operator's units get +1/+1.** | win before the lift reaches the top; flyers get there first | 100 % | 99 % |

Elites and bosses whose sets are unchanged (win rates move with the HP the run brings them): Notary Wraith 89 % -> 90 %; Undersecretary Vellum 78 % -> 79 %; Mortimer Grimsby 54 % -> 53 %

## The Rotheart

| Room | Foe | Rules (new in bold) | Scripted beats (new in bold) | The idea | Won before | Won after |
|---:|---|---|---|---|---:|---:|
| 2 | Overgrown Scarecrow | **Crows: Every third turn of its, a 1/1 Crow with Flying flaps in.**<br>**Shoo!: Your units with Swat get +1 attack. Swatters can block flyers.** | - | flyers come in over a slow deck; units that can swat them get stronger | 100 % | 100 % |
| 3 | Mutant Mushroom Troop | **Spore Cloud: At the start of its turn, you take 1 damage.**<br>**Fungal Feast: Your tokens get +1/+1.** | - | a clock against slow decks; token decks grow faster | 100 % | 96 % |
| 8 | Thorn Maze Stalker | **Thorns: Each unit that attacks the Stalker takes 1 damage.**<br>**Hedge Cutter: Your units with Bulldoze get +1 attack.** | **On its 5th turn you find a clearing in the maze: you heal 3.** | small attackers bleed on the thorns; big tramplers cut through | 95 % | 96 % |
| 11 | Rot Tunnel Horror | **Bad Air: No one can use Garbage in this fight. The tunnel air spoils it.**<br>**Fresh Draught: At the start of your turn you heal 1.** | - | a Garbage plan stalls; any deck heals a little each turn | 97 % | 99 % |

Elites and bosses whose sets are unchanged (win rates move with the HP the run brings them): Hortensia Clipwell 92 % -> 92 %; Hive of Mutant Bees 96 % -> 96 %; Compostella 54 % -> 54 %

## Primm's Castle

| Room | Foe | Rules (new in bold) | Scripted beats (new in bold) | The idea | Won before | Won after |
|---:|---|---|---|---|---:|---:|
| 3 | Hedge Trimmer Guard | **Pruning Shears: The Guard's units have Sucker Punch: they deal combat damage first.**<br>**Overgrowth: Your units get +0/+1.** | - | its units strike first; sturdier units survive it | - | - |
| 5 | Gallery Curator | **Do Not Touch: You cannot play Wonders in this fight. Please do not touch the exhibits.**<br>**Audio Guide: You draw an extra card on your first turn.** | **At half health the Curator restores a portrait: it heals 3.** | Wonder decks are turned away at the rope; everyone gets the audio guide (and a deck change: gourmand_refusemancer) | - | - |
| 12 | Ministry Clerk | **Correction Quota: You may play at most 3 cards a turn (Infrastructure does not count).**<br>**Approved Stamp: Your Pathless cards cost 1 less.** | - | a cap on very wide turns; Pathless cards come cheaper | - | - |

