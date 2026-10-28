# Balance log (major rebalance, Oct 18 2026)

Every number and rules-text change of the rebalance, in order: what changed (old -> new), why, and the simulation evidence where there
is any. Iteration tables (Part G) are at the bottom. The sheet-side list of the same changes is `docs/design/sheet_changes.md`.

## Part A - rules changes

| What | Old -> New | Why | Evidence |
|---|---|---|---|
| Iron (Beefcake resource) | Pay 1, use an Iron: +1 attack permanently -> **+1/+1 until end of turn** | Brief: Iron is a burst-turn tool, not a permanent snowball; the +1 defense keeps the pumped attacker alive through a block. | Sim after Part B (Iron-at-1-energy check). |
| Red Tape (Necrocrat resource) | Pay 1, use a Red Tape: -1 attack permanently -> **-2/-0 until the start of its controller's next turn** | Brief: a combat trick that blunts a blocker for one attack instead of a permanent nerf. Engine: `CardInstance.lingering`, expired in the controller's ready step. | - |
| Eat Garbage | Pay 1 energy, lose 1 HP, use a Garbage -> **pay 1 energy, use a Garbage** (no HP) | Brief: Refusemancer was too weak and every eat hurt. The Raccoon still removes the energy part. | - |
| New script cost `lose(N)` | - | "Lose N HP" as a written extra cost on the stronger Refusemancer abilities; never payable down to 0 HP. | - |
| R-03 Landfill Ox | "Exhaust, eat garbage twice: add (R)(R)(R)(R)." -> "..., lose 1 HP: ..." | Four energy for one card is the Path's biggest ramp burst; it keeps a small HP tax. | - |
| R-22 Acid Vomitor | "Exhaust, eat garbage: deal 2 damage to target unit." -> "..., lose 1 HP: ..." | Repeatable 2-damage removal every turn is the Path's best removal; keeps the old cost. | - |
| R-28 Poo-uid | "Exhaust, eat garbage: create a 3/3 Poo Golem token." -> "..., lose 1 HP: ..." | A 3/3 every turn for one Garbage is the Path's strongest engine. | - |
| R-33 Archdruid Compostella | recursion ability -> "Exhaust, eat garbage, lose 1 HP: return target card..." | Unlimited recursion on the Signature legendary keeps its tax. | - |
| NR-12 Conscripted Constrictor | "Exhaust, eat garbage twice: destroy target unit." -> "..., lose 2 HP: ..." | Repeatable hard removal on a 6/5 body. | - |
| BR-16 Tuskeroni | "Eat garbage: put a buff on this unit..." -> "Eat garbage, lose 1 HP: ..." | Legendary; a permanent buff per Garbage. | - |
| R-27 Raccoon | "...they don't pay energy or lose HP." -> "...they don't pay energy." | There is no HP cost to remove any more; the Raccoon does not waive the written "lose N HP" costs. | - |
| NB-16 Chancellor Clench | "Your Iron gives +2 attack instead of +1. Your Red Tape gives -2 attack instead of -1." -> "Your Iron gives +2/+2 instead of +1/+1. Your Red Tape gives -4 attack instead of -2." | Doubles the new effects, same as before. | - |
| T-14 Red Tape token text, Design Guidance rows (Iron, Red Tape, Eat Garbage) | old wording -> new wording | Sheet snapshot matches the engine. | - |
| Battle AI | - | Uses Iron only before combat and only on a unit that attacks this turn; Red Tape only before combat on a ready enemy blocker when it has an attack; its threat estimate ignores shrinks that end before the enemy's turn. | `test_resources.gd` |
| Arena: Cardboard Colossus (spells only) | Beefcake basics -> Gourmand basics (same Colorless cards, 28 cards, 8 HP) | With temporary Iron the AI saves Iron for one pre-attack burst (+4/+4 seen), which a unit-less spells deck cannot block; the encounter went from winnable to 0/12 seeds. Without Iron it is a race again. | `test_arena.gd` spells-only seeds |

## Part C - card rebalance, batch 1 (starting-deck level, deck round robin L1: Beefcake 86%, Gourmand 51%, Necrocrat 37%, Refusemancer 27%)

| Card | Old -> New | Why | Evidence |
|---|---|---|---|
| B-03 Dropped Weights | text: "Deal 2 damage to target unit or opponent." -> "Deal 2 damage to target unit." | Removal rate: 2 damage for 1 energy is unit-only; face damage costs more (Flex on 'Em is the face spell). Beefcake too strong. | decks_l1.md before: B 86 / G 51 / N 37 / R 27 |
| B-21 Flex on 'Em | cost: "1(B)" -> "2(B)" | 2 face (4 with a 5-attack unit) for 2 energy ended races too early; face damage costs more than unit damage. | decks_l1.md before: B 86 / G 51 / N 37 / R 27 |
| B-24 Overclocked Mill Worker | pt: "3/3" -> "2/3" | 3/3 Overtime that also makes an Iron on every attack for 3 energy was over the curve for an Uncommon engine. | decks_l1.md before: B 86 / G 51 / N 37 / R 27 |
| C-21 Old Kingdom Banner | cost: "3" -> "4" | A permanent +1 attack to every unit for 3 fits any deck; colorless should be below the Path cards. | decks_l1.md before: B 86 / G 51 / N 37 / R 27 |
| C-22 Mercenary Captain | pt: "3/3" -> "2/3" | 3/3 plus two 1/1s for 4 was above the curve for a colorless Uncommon. | decks_l1.md before: B 86 / G 51 / N 37 / R 27 |
| C-23 Resistance Scout | pt: "2/2" -> "1/2" | An unblockable 2/2 for 2 in any deck raced too well. | decks_l1.md before: B 86 / G 51 / N 37 / R 27 |
| C-13 Rally the Village | cost: "2" -> "3" | A team pump for 2 was the best colorless spell; colorless should be slightly worse than Path cards. | decks_l1.md before: B 86 / G 51 / N 37 / R 27 |
| C-09 Old Kingdom Automaton | pt: "5/5" -> "4/5" | On-curve vanilla in any deck; colorless bodies sit a point below the Path curve. | decks_l1.md before: B 86 / G 51 / N 37 / R 27 |
| R-07 Junkyard Giraffe | pt: "2/5" -> "3/5" | 2/5 Swat for 4 energy was two points under the curve with nothing else; Refusemancer too weak. | decks_l1.md before: B 86 / G 51 / N 37 / R 27 |
| R-09 Heap Tortoise | pt: "4/6" -> "5/6" | Refusemancer's top common should be the biggest body at its cost (Path skew: big top end). | decks_l1.md before: B 86 / G 51 / N 37 / R 27 |
| R-04 Rubbish Goat | pt: "2/2" -> "2/3" | A conditional Tool answer on a 2/2 for 3 energy was a weak body. | decks_l1.md before: B 86 / G 51 / N 37 / R 27 |
| R-28 Poo-uid | pt: "2/2" -> "2/3" | The Poo-uid engine now also costs HP; a sturdier body keeps it alive long enough to matter. | decks_l1.md before: B 86 / G 51 / N 37 / R 27 |
| R-02 Dumpster Diver | text: "Exhaust, pay 1: create a Garbage." -> "Exhaust: create a Garbage." | Paying 1 on top of exhausting made the Diver worse than a Rat; the Garbage engine needs to run every turn. | decks_l1.md before: B 86 / G 51 / N 37 / R 27 |
| N-02 Infernal Intern | pt: "1/2" -> "2/2" | Necrocrat's 1(N) Red Tape maker was a 1/2; a 2/2 trades with the colorless 2-drops. | decks_l1.md before: B 86 / G 51 / N 37 / R 27 |
| N-05 Corpseified Public Accountant | pt: "1/3" -> "2/3" | Necrocrat too weak: its bodies lost every race; 2/3 blocks a 2/2. | decks_l1.md before: B 86 / G 51 / N 37 / R 27 |
| N-07 Grave Shift Worker | pt: "2/3" -> "3/3" | 3 energy for a 2/3 plus a cheap Reinstate was under the curve. | decks_l1.md before: B 86 / G 51 / N 37 / R 27 |
| N-23 Middle Management Zombie | pt: "2/3" -> "2/4" | The token lord needs to survive to matter. | decks_l1.md before: B 86 / G 51 / N 37 / R 27 |
| N-03 Post-Human Resources Ghoul | pt: "2/2" -> "2/3" | An edict body that dies to a 2/2 never got to block. | decks_l1.md before: B 86 / G 51 / N 37 / R 27 |
| N-04 Body-builder | pt: "1/2" -> "2/2" | The Red Tape -> 2/2 engine on a 1/2 died to everything. | decks_l1.md before: B 86 / G 51 / N 37 / R 27 |
| N-18 Requisition Form | cost: "2(N)" -> "1(N)" | Spending a Red Tape AND 3 energy for two cards was too slow; 2 energy. | decks_l1.md before: B 86 / G 51 / N 37 / R 27 |
| N-09 Red Tape Dispenser | cost: "2(N)" -> "1(N)" | A Tool that makes one Red Tape per turn for 1 energy is a 2-energy card, not 3. | decks_l1.md before: B 86 / G 51 / N 37 / R 27 |
| G-05 Food Critic | pt: "2/2" -> "2/3" | A 3-energy bounce body that died to a 2/2. | decks_l1.md before: B 86 / G 51 / N 37 / R 27 |
| G-08 Pastry Artificer | text: "Exhaust, pay 2, use two Ingredients: create a 4/4 Cake Golem token." -> "Exhaust, pay 1, use two Ingredients: create a 4/4 Cake Golem token." | Pay 2 on top of two Ingredients and the exhaust made the Cake Golem a turn-5 play; pay 1 keeps Gourmand's Golems bigger than their cost. | decks_l1.md before: B 86 / G 51 / N 37 / R 27 |
| G-22 The Cullinator | pt: "3/3" -> "4/4" | 5 energy for a 3/3 and a kill was under the curve. | decks_l1.md before: B 86 / G 51 / N 37 / R 27 |
| G-29 Head Health Inspector | pt: "3/6" -> "4/6" | 6 energy for a 3/6 mass bounce; Gourmand's defensive skew wants a real body. | decks_l1.md before: B 86 / G 51 / N 37 / R 27 |

## Part C - card rebalance, batch 2 (matchups at L1: Beefcake beats Refusemancer 83% with Iron / 60% without; Necrocrat 3% vs Beefcake in 4.9 turns)

| Card | Old -> New | Why | Evidence |
|---|---|---|---|
| B-01 Gym Bro | pt: "2/1" -> "1/1" | A 2/1 Hustle for one energy dealt 2 on turn one into 10 HP; with six such bodies the race ended by turn 5. 1/1 Hustle is still the Path's 1-drop. | matchup_*.md (40 games); decks_l1_c1.md: B 82 / G 52 / N 44 / R 21 |
| B-07 Late-ish Courier | pt: "3/1" -> "2/1" | 3 Hustle damage for 2 energy on turn two was the second half of the turn-5 kill; it still cannot block. | matchup_*.md (40 games); decks_l1_c1.md: B 82 / G 52 / N 44 / R 21 |
| B-26 The Carpool | pt: "4/3" -> "3/3" | Highest lift in the Beefcake deck (+18 / +40): a 4/3 Hustle that also gives the team Hustle for 4 energy; 3/3 keeps the alpha strike, not the body. | matchup_*.md (40 games); decks_l1_c1.md: B 82 / G 52 / N 44 / R 21 |
| N-01 Skeleton Clerk | pt: "1/1" -> "1/2" | Necrocrat's 1-drop could not block a 1/1 Hustle without dying; 1/2 trades and still leaves a Red Tape. | matchup_*.md (40 games); decks_l1_c1.md: B 82 / G 52 / N 44 / R 21 |
| R-06 Curbside Rat | pt: "1/1" -> "1/2" | Refusemancer's 1-drop should block the Gym Bro; the Garbage is the card's point. | matchup_*.md (40 games); decks_l1_c1.md: B 82 / G 52 / N 44 / R 21 |
| R-08 Possum Prowler | pt: "1/2" -> "2/2" | The Possum is the Path's teaching card: 2/2 that eats into a 4/4 for one energy makes Garbage matter from turn two. | matchup_*.md (40 games); decks_l1_c1.md: B 82 / G 52 / N 44 / R 21 |
| R-22 Acid Vomitor | pt: "1/3" -> "2/3" | The Vomitor pays HP for every shot now; a 2/3 body for 3 energy is on the curve. | matchup_*.md (40 games); decks_l1_c1.md: B 82 / G 52 / N 44 / R 21 |
| R-03 Landfill Ox | pt: "2/4" -> "3/4" | 4 energy for a 2/4 whose ability costs HP; 3/4 is the Path's big-body skew. | matchup_*.md (40 games); decks_l1_c1.md: B 82 / G 52 / N 44 / R 21 |
| R-05 Kidding Around | pt: "2/2" -> "2/3" | 2/2 plus a 1/1 Goat for 3 energy lost both bodies to a 2/2; 2/3 holds the line. | matchup_*.md (40 games); decks_l1_c1.md: B 82 / G 52 / N 44 / R 21 |

## Part C - card rebalance, batch 3 (decks_l1_c2.md: Beefcake 73% overall, others 40-46%)

| Card | Old -> New | Why | Evidence |
|---|---|---|---|
| B-08 Spotter | pt: "2/3" -> "2/2" | Spotter was the highest-lift Beefcake common (+18/+20): a 2/3 whose buff lands on a Hustle attacker is 7 stats for 3 energy; 2/2 keeps the trick. | decks_l1_c2.md: B 73 / R 46 / G 41 / N 40 |
| B-04 Millstone Pusher | pt: "2/2" -> "1/2" | A 2/2 that also ramps (Overexert for two energy) let Beefcake play 4-drops on turn three; ramp bodies are small. | decks_l1_c2.md: B 73 / R 46 / G 41 / N 40 |

## Part E - encounters (the tutorial first, the rest after Part D)

| Encounter | Old -> New | Why | Evidence |
|---|---|---|---|
| Cave Scavenger (tutorial 1) | C-01 x4, C-02 x3, C-03 x2, C-04 x2, C-06 -> C-01 x5, C-02 x3, C-03 x1, C-04 x2 | The Path starting decks have no fliers; 1/3 Swat and 3/2 Sucker Punch walls stalled Gourmand and Necrocrat for 14 turns while 1/1s chipped them (replayed seeds 207002 / 207017). | tutorial_c3c.md: B 80 / R 68 / N 60 / G 53 cleared |
| Hollow Stalker (tutorial 2) | C-03 x2, C-05 (1/5 wall) -> C-02 x4, C-03 x1, no Shield Bearer | A 1/5 wall in front of a 3-HP enemy is a stall, not a lesson. | same |
| Hollow Warden (tutorial boss) | R-07 x2 (2/5 Swat), C-08 x2, C-09 -> C-01 x2, C-08 x1, R-05; Tavern Regular is the one real blocker | Three walls on a 3-HP boss made it a puzzle only burn or fliers solve. | same |
| Cave Scavenger, Hollow Stalker (second pass) | Scavenger 8 bodies / 26 cards -> 8 bodies / 26 with 18 Infrastructure (C-02 x2); Stalker 11 bodies / 30 -> 10 bodies (C-02 x3) | Thinner on attackers: the tutorial is gentle by design (old target 85%+) and Gourmand's slow start was chipped out before its Golems arrived. | tutorial_e1.md: B 80 / R 78 / N 73 / G 63 |

## Part C - card rebalance, batch 4 (Gourmand: round robin 36-42%, tutorial clear 68% vs 80-86% for the others)

| Card | Old -> New | Why | Evidence |
|---|---|---|---|
| G-01 Line Cook | pt: "1/1" -> "1/2" | Gourmand's 1-drop should block a 1/1 and live (Path skew: higher defense); the Curbside Rat got the same. | decks_l1_c3c.md: B 70 / R 53 / N 42 / G 36; tutorial_e2.md: B 86 / R 82 / N 80 / G 68 |
| G-02 Sushi Apprentice | pt: "1/1" -> "1/2" | The Weenie maker died to any attacker before it could cook once. | decks_l1_c3c.md: B 70 / R 53 / N 42 / G 36; tutorial_e2.md: B 86 / R 82 / N 80 / G 68 |
| G-06 Soup Kitchen Volunteer | pt: "1/3" -> "2/3" | A 1/3 that gains 2 HP never pressured anything; 2/3 trades with the colorless 2-drops and keeps the heal. | decks_l1_c3c.md: B 70 / R 53 / N 42 / G 36; tutorial_e2.md: B 86 / R 82 / N 80 / G 68 |
| G-07 Sous Chef | pt: "2/2" -> "2/3" | 3 energy for a 2/2 and a card was under the curve; 2/3 blocks a 2/2. | decks_l1_c3c.md: B 70 / R 53 / N 42 / G 36; tutorial_e2.md: B 86 / R 82 / N 80 / G 68 |

## Part C - card rebalance, batch 5 (Beefcake vs Necrocrat 75% at 100 games; Beefcake's top-lift card is the Mill Worker again)

| Card | Old -> New | Why | Evidence |
|---|---|---|---|
| B-24 Overclocked Mill Worker | cost: "2(B)" -> "3(B)" | Even as a 2/3 the Overtime Iron engine had the highest lift in the deck (+19): an Iron every attack that never exhausts. 4 energy is the price of an engine. | mirror_beefcake_necrocrat.md (100 games): 75%; matchup_beefcake_necrocrat.md lifts: B-24 +19, B-01 +12, B-08 +12 |
| Arena puzzle Zero to Hero | enemy HP 11 -> 10 | Gym Bro is a 1/1 now; the puzzle's three attackers deal exactly 10 once both blockers are cleared. | `test_arena.gd` |
| Battle AI (reverted) | - | A try at scaling the counter-attack worry by the AI's own HP made it chump-block at full HP; reverted, the attack look-ahead for Iron / Red Tape stays. | `test_ai_player.gd` |
| The Warden of the Four Seals (Vault) | 40 HP, escalation T-11, T-01, T-06, T-18, T-20, T-07 (one per turn) -> 34 HP, T-11, T-11, T-01, T-01, T-06, T-06, T-18, T-20, T-07 | 0% at level 24 for every Path: an 8/8 Bulldoze by the Warden's sixth turn on top of a 40-HP four-Path deck. The ladder now climbs two steps per size. | baseline_quick.md: 0% |
| Shiro Swindle | 18 HP -> 24 HP; deck + Health Code Violation x2, Processing Delay, Plate It, Head Health Inspector; starts with 2 Contracts (rule) | 100% at level 12 for every Path; a trickster boss should have tricks. | baseline_quick.md: 100% |
| Arena: Champion of the Four Fists | 22 -> 28 HP | 96% at level 12 (elite band 60-75). | baseline_quick.md |
| Arena: Announcer Grand Bellows | 30 -> 38 HP, + Swole Patrol Sergeant, Barbell of the Ancients; rule: units +1 attack | 96% at level 18 (boss band 40-60). | baseline_quick.md |

## Part E - encounter tuning, batch 1 (early game; e_town.md, e_zone:beefcake.md, e_D-HOG.md)

| Encounter | Old -> New | Why | Evidence |
|---|---|---|---|
| D-HOG node 2 (Treadmill Sprinter) | {"name":"Treadmill Sprinter"} -> {"name":"Treadmill Sprinter","hp":12,"size":26} | Normal node at level 7 was 73% (Necrocrat 42% under the zone's Processing Time); thinner and shorter. | e_D-HOG.md: 73 / 58 / 65 / 79 / 42 / 31 |
| D-HOG node 3 (Courtyard Lifter) | {"name":"Courtyard Lifter"} -> {"name":"Courtyard Lifter","hp":12,"size":26} | 58% for a normal node: the tools deck plus 15 HP was an elite in disguise. | e_D-HOG.md: 73 / 58 / 65 / 79 / 42 / 31 |
| D-HOG node 6 (Regime Checkpoint Captain) | {"name":"Regime Checkpoint Captain","deck":"beefcake_bruisers","size":31,"hp":19} -> {"name":"Regime Checkpoint Captain","deck":"beefcake_bruisers","size":30,"hp":18} | Elite at 65% is in band; a touch lighter so the Drill Sergeant rule does not push it under. | e_D-HOG.md: 73 / 58 / 65 / 79 / 42 / 31 |
| D-HOG node 8 (Cell Block Brawler) | {"name":"Cell Block Brawler"} -> {"name":"Cell Block Brawler","hp":13,"size":27} | 79%, one point short of the normal band; Necrocrat 50%. | e_D-HOG.md: 73 / 58 / 65 / 79 / 42 / 31 |
| D-HOG node 11 (Trophy Hall Honor Guard) | {"name":"Trophy Hall Honor Guard","deck":"beefcake_bruisers","size":33,"hp":22} -> {"name":"Trophy Hall Honor Guard","deck":"beefcake_bruisers","size":30,"hp":17} | 42% with the Honor Guard rule (two Militia at the start): 22 HP on top of that was too much. | e_D-HOG.md: 73 / 58 / 65 / 79 / 42 / 31 |
| D-HOG boss | {"deck":"beefcake_bruisers","extra":{},"hp":28,"icon":"delapouite/viking-head"} -> {"deck":"beefcake_bruisers","extra":{},"hp":24,"icon":"delapouite/viking-head"} | Clench at 31% with 3 Iron and reinforcements; the boss band is 40-60. | e_D-HOG.md: 73 / 58 / 65 / 79 / 42 / 31 |
| Gainlands roamers | Flexing Brute 27 cards 14 HP -> 25 cards 12 HP; Protein Shake Golem beefcake_bruisers 28 cards 16 HP -> beefcake_tools 26 cards 13 HP | 67% / 27% at level 5 (normal band 80+); the bruisers' 5/4 and 6/5 bodies were a boss deck. | e_zone:beefcake.md |
| Corrupted NPCs | Moss Mulligan Passive -> Balanced AI, 15 -> 17 HP; Prudence Pallor Balanced -> Aggressive, 15 -> 18 HP, starts with 2 Red Tape | 85% / 94% at level 3 (elite band 60-75); Brick 63 and Chef 69 untouched. | e_town.md |
| The Restless Dead (Graveyard) | ladder T-10, T-11, T-21, T-17, T-19, T-17 -> T-10, T-10, T-11, T-10, T-21, T-19, T-17 | 23% at level 7 (boss band 40-60). | e_town.md |
| Shiro Swindle | 24 -> 30 HP, Balanced -> Aggressive | still 100% at 24 HP. | e_town.md |
| The Warden of the Four Seals | 34 -> 28 HP, ladder starts with three Zombie Rats | 23% at level 24 (Gourmand 0%). | e_town.md |
| Chancellor Clench | reinforcements every 3rd turn -> every 4th; HP 28 -> 24 | 31% (boss band 40-60). | e_D-HOG.md |

## Part E - encounter tuning, batch 2 (Gainlands and House of Gains, 100 games per fight)

| Encounter | Old -> New | Why | Evidence |
|---|---|---|---|
| D-HOG node 3 (Courtyard Lifter) | {"name":"Courtyard Lifter","hp":12,"size":26} -> {"name":"Courtyard Lifter","hp":11,"size":25} | 69%: still under the normal band; Gourmand 50%. | e_D-HOG.md (batch 1): 79 / 69 / 46 / 81 / 40 / 42; one_D-HOG:6/11.md per Path |
| D-HOG node 6 (Regime Checkpoint Captain) | {"name":"Regime Checkpoint Captain","deck":"beefcake_bruisers","size":30,"hp":18} -> {"name":"Regime Checkpoint Captain","deck":"beefcake_bruisers","size":29,"hp":16} | Checkpoint Captain 46% with the Drill Sergeant rule (elite band 60-75); Gourmand 28%. | e_D-HOG.md (batch 1): 79 / 69 / 46 / 81 / 40 / 42; one_D-HOG:6/11.md per Path |
| D-HOG node 11 (Trophy Hall Honor Guard) | {"name":"Trophy Hall Honor Guard","deck":"beefcake_bruisers","size":30,"hp":17} -> {"name":"Trophy Hall Honor Guard","deck":"beefcake_bruisers","size":28,"hp":15} | Honor Guard 40% with two Militia at the start; Gourmand 20%. | e_D-HOG.md (batch 1): 79 / 69 / 46 / 81 / 40 / 42; one_D-HOG:6/11.md per Path |
| Gainlands roamers (second pass) | Brute 25 cards 12 HP Aggressive -> 24 cards 11 HP Balanced; Golem 26 cards 13 HP -> 24 cards 11 HP | 64% / 53% at 100 games: the zone's Pump It Up buffs the Beefcake enemy decks too, so the rival Paths (Necrocrat 24%) need the roamers thin. | e_zone_beefcake25.md |

## Part E - encounter tuning, batch 3 (House of Gains, 100 games per fight)

| Encounter | Old -> New | Why | Evidence |
|---|---|---|---|
| D-HOG node 3 (Courtyard Lifter) | {"name":"Courtyard Lifter","hp":11,"size":25} -> {"name":"Courtyard Lifter","hp":10,"size":25} | Courtyard Lifter 75%, five short of the normal band. | D-HOG at 100 games: 82 / 75 / 59 / 84 / 48 / 46 |
| D-HOG node 11 (Trophy Hall Honor Guard) | {"name":"Trophy Hall Honor Guard","deck":"beefcake_bruisers","size":28,"hp":15} -> {"name":"Trophy Hall Honor Guard","deck":"beefcake_bruisers","size":28,"hp":14} | Trophy Hall Honor Guard 48% with its two starting Militia; the elite band starts at 60. | D-HOG at 100 games: 82 / 75 / 59 / 84 / 48 / 46 |
| Gainlands roamers (third pass) | Brute and Golem 11 HP -> 9 HP | 57% / 50% at 100 games even with the level-5 package: the home zone's Pump It Up makes every roamer a Beefcake deck with +1 attack, and the rival Necrocrat enters exhausted; a first-zone speed bump must die fast. | e_zone_beefcake (100 games) |
| Progression model | second upgrade package at level 6 -> level 5 | The level-4 Path Pack and Crosspath's stalls put 4-6 extra cards in the deck before the first zone. | - |

## Part E - encounter tuning, batch 4 (House of Gains: fewer basics per foe)

| Encounter | Old -> New | Why | Evidence |
|---|---|---|---|
| D-HOG node 2 (Treadmill Sprinter) | {"name":"Treadmill Sprinter","hp":12,"size":26} -> {"name":"Treadmill Sprinter","hp":12,"size":26,"infra":13} | Beefcake foes run 13 basics instead of 16: fewer Iron bursts, more real cards. | replay of the Gainlands Golem (Iron bursts from 15 basics in 24 cards); D-HOG at 100 games: 82 / 77 / 59 / 84 / 51 / 46 |
| D-HOG node 3 (Courtyard Lifter) | {"name":"Courtyard Lifter","hp":10,"size":25} -> {"name":"Courtyard Lifter","hp":10,"size":25,"infra":13} | same | replay of the Gainlands Golem (Iron bursts from 15 basics in 24 cards); D-HOG at 100 games: 82 / 77 / 59 / 84 / 51 / 46 |
| D-HOG node 6 (Regime Checkpoint Captain) | {"name":"Regime Checkpoint Captain","deck":"beefcake_bruisers","size":29,"hp":16} -> {"name":"Regime Checkpoint Captain","deck":"beefcake_bruisers","size":29,"hp":16,"infra":13} | same | replay of the Gainlands Golem (Iron bursts from 15 basics in 24 cards); D-HOG at 100 games: 82 / 77 / 59 / 84 / 51 / 46 |
| D-HOG node 8 (Cell Block Brawler) | {"name":"Cell Block Brawler","hp":13,"size":27} -> {"name":"Cell Block Brawler","hp":13,"size":27,"infra":13} | same | replay of the Gainlands Golem (Iron bursts from 15 basics in 24 cards); D-HOG at 100 games: 82 / 77 / 59 / 84 / 51 / 46 |
| D-HOG node 11 (Trophy Hall Honor Guard) | {"name":"Trophy Hall Honor Guard","deck":"beefcake_bruisers","size":28,"hp":14} -> {"name":"Trophy Hall Honor Guard","deck":"beefcake_bruisers","size":28,"hp":14,"infra":13} | same | replay of the Gainlands Golem (Iron bursts from 15 basics in 24 cards); D-HOG at 100 games: 82 / 77 / 59 / 84 / 51 / 46 |
| D-HOG boss | {"deck":"beefcake_bruisers","extra":{},"hp":24,"icon":"delapouite/viking-head"} -> {"deck":"beefcake_bruisers","extra":{},"hp":24,"icon":"delapouite/viking-head","infra":14} | Clench starts with 3 Iron already; 14 basics instead of 17. | replay of the Gainlands Golem (Iron bursts from 15 basics in 24 cards); D-HOG at 100 games: 82 / 77 / 59 / 84 / 51 / 46 |
| Gainlands roamers (fourth pass) | 16 / 15 basic Infrastructure -> 12 each | Replay (tools/replay_encounter.gd, Gourmand vs the Golem): a 24-card deck with 15 basics draws a basic almost every turn and every basic is an Iron, so the roamer swung with +3/+3 Iron bursts on turn 9. Fewer basics, fewer bursts. | replay |
| Dungeon foes | new `infra` field in dungeon_content.json (default 16; `defaults.infra` per dungeon) | Same lever for dungeon foes; the House of Gains runs 13. | - |

## Part E - encounter tuning, batch 5 (mid and late game: everything from level 11 on was a 100% win in the baseline)

| Encounter | Old -> New | Why | Evidence |
|---|---|---|---|
| D-HFA node 3 (Intake Clerk) | {"name":"Intake Clerk"} -> {"name":"Intake Clerk","hp":18,"size":30} | Normal node at level 11 was 98-100%; the level-11 player has 15 HP and gear. | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| D-HFA node 4 (Returns Clerk) | {"name":"Returns Clerk"} -> {"name":"Returns Clerk","hp":18,"size":30} | same | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| D-HFA node 7 (Notary Wraith) | {"name":"Notary Wraith","deck":"necro_control","size":31,"hp":19} -> {"name":"Notary Wraith","deck":"necro_control","size":33,"hp":24} | Elite 100%: a real elite is 24 HP with the Notarized rule. | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| D-HFA node 9 (Resurrection Permits Zombie) | {"name":"Resurrection Permits Zombie"} -> {"name":"Resurrection Permits Zombie","hp":19,"size":31} | Normal 100%. | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| D-HFA node 11 (Undersecretary Vellum) | {"name":"Undersecretary Vellum","deck":"necro_control","size":30,"hp":20} -> {"name":"Undersecretary Vellum","deck":"necro_control","size":33,"hp":24} | Elite 100% (Undersecretary Vellum, 2 Contracts). | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| D-HFA node 13 (Executive Elevator Operator) | {"name":"Executive Elevator Operator"} -> {"name":"Executive Elevator Operator","hp":20,"size":31} | Normal 100%. | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| D-HFA boss | {"deck":"necro_control","extra":{"N-33":1,"N-32":1},"hp":28,"icon":"delapouite/stamper"} -> {"deck":"necro_control","extra":{"N-33":1,"N-32":1},"hp":34,"icon":"delapouite/stamper"} | Mortimer 98%: 34 HP plus Red Tape and the Temp Agency rule. | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| S-NECRO node 1 (Receptionist of Number One) | {"name":"Receptionist of Number One"} -> {"name":"Receptionist of Number One","hp":18,"size":30} | Side dungeon at level 11, 100%. | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| S-NECRO node 2 (The Eternal Queue) | {"name":"The Eternal Queue"} -> {"name":"The Eternal Queue","hp":19,"size":31} | same | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| S-NECRO boss | {"deck":"necro_control","extra":{"N-30":1},"hp":20,"icon":"delapouite/files"} -> {"deck":"necro_control","extra":{"N-30":1},"hp":28,"icon":"delapouite/files"} | Betty Bones 100%: 28 HP plus the Take a Number rule. | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| D-TTK node 2 (Prep Station Sous-Chef) | {"name":"Prep Station Sous-Chef"} -> {"name":"Prep Station Sous-Chef","hp":20,"size":31} | Level 14 normal at 77-90%; the level-14 player has 17 HP, Hover Boots and Salves. | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| D-TTK node 3 (Frozen Line Cook) | {"name":"Frozen Line Cook"} -> {"name":"Frozen Line Cook","hp":20,"size":31} | same | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| D-TTK node 6 (Unfinished War Machine) | {"name":"Unfinished War Machine","deck":"gourmand_golems","size":30,"hp":20,"icon":"delapouite/pirate-cannon"} -> {"name":"Unfinished War Machine","deck":"gourmand_golems","size":34,"hp":26,"icon":"delapouite/pirate-cannon"} | Elite 71%: fine, but with the Conveyor rule it keeps its HP up. | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| D-TTK node 8 (Assembly Line Golem) | {"name":"Assembly Line Golem"} -> {"name":"Assembly Line Golem","hp":21,"size":32} | Normal 85%. | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| D-TTK node 11 (Cannon-Blender Gunner) | {"name":"Cannon-Blender Gunner","deck":"gourmand_golems","size":33,"hp":22,"icon":"delapouite/pirate-cannon"} -> {"name":"Cannon-Blender Gunner","deck":"gourmand_golems","size":34,"hp":26,"icon":"delapouite/pirate-cannon"} | Elite 73% with the Shrapnel rule. | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| D-TTK node 12 (Expediter of the Pass) | {"name":"Expediter of the Pass"} -> {"name":"Expediter of the Pass","hp":21,"size":32} | Normal 85%. | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| D-TTK boss | {"deck":"gourmand_golems","extra":{"G-33":1},"hp":28,"icon":"delapouite/chef-toque"} -> {"deck":"gourmand_golems","extra":{"G-33":1},"hp":34,"icon":"delapouite/chef-toque"} | The Doppelganger 88%: 34 HP plus Mise en Place. | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| S-GOUR node 1 (Apprentice Itamae) | {"name":"Apprentice Itamae"} -> {"name":"Apprentice Itamae","hp":20,"size":31} | Level 14 side dungeon, 73-90%. | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| S-GOUR node 2 (Conveyor Belt Sushi Chef) | {"name":"Conveyor Belt Sushi Chef"} -> {"name":"Conveyor Belt Sushi Chef","hp":21,"size":32} | same | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| S-GOUR boss | {"deck":"gourmand_golems","extra":{"G-27":1},"hp":20,"icon":"delapouite/charging-bull"} -> {"deck":"gourmand_golems","extra":{"G-27":1},"hp":28,"icon":"delapouite/charging-bull"} | The Itamae Supreme 98%: 28 HP plus Omakase. | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| S-REF node 1 (Alley Gate Raccoon) | {"name":"Alley Gate Raccoon"} -> {"name":"Alley Gate Raccoon","hp":22,"size":32} | Level 17 side dungeon, 98%. | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| S-REF node 2 (Pizza Crust Courtier) | {"name":"Pizza Crust Courtier"} -> {"name":"Pizza Crust Courtier","hp":23,"size":33} | same | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| S-REF boss | {"deck":"refuse_rats","extra":{"R-27":1},"hp":20,"icon":"delapouite/imperial-crown"} -> {"deck":"refuse_rats","extra":{"R-27":1},"hp":30,"icon":"delapouite/imperial-crown"} | His Majesty the Raccoon 98%: 30 HP plus the Royal Larder. | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| S-CAP node 1 (Sewer Checkpoint Enforcer) | {"name":"Sewer Checkpoint Enforcer","deck":"colorless_regime","size":27,"hp":12,"mixed":["necrocrat","gourmand"]} -> {"name":"Sewer Checkpoint Enforcer","deck":"colorless_regime","size":33,"hp":24,"mixed":["necrocrat","gourmand"]} | Level 19 side dungeon, 100%. | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| S-CAP node 2 (Junction Patrol) | {"name":"Junction Patrol","deck":"colorless_regime","size":28,"hp":14,"mixed":["beefcake","refusemancer"]} -> {"name":"Junction Patrol","deck":"colorless_regime","size":34,"hp":26,"mixed":["beefcake","refusemancer"]} | same | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| S-CAP node 3 (Enforcer Captain Spotless) | {"name":"Enforcer Captain Spotless","deck":"colorless_regime","size":33,"hp":20,"mixed":["necrocrat","gourmand","beefcake","refusemancer"]} -> {"name":"Enforcer Captain Spotless","deck":"colorless_regime","size":36,"hp":32,"mixed":["necrocrat","gourmand","beefcake","refusemancer"]} | Enforcer Captain Spotless 100%: 32 HP plus the Spotless Drill. | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| S-CAP boss | {"deck":"colorless_regime","extra":{},"hp":20,"icon":"lorc/visored-helm"} -> {"deck":"colorless_regime","extra":{},"hp":32,"icon":"lorc/visored-helm"} | same (the side boss reads the boss block's HP). | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| D-PC node 2 (Hedge Trimmer Guard) | {"name":"Hedge Trimmer Guard","deck":"colorless_regime","size":28,"hp":14,"mixed":["necrocrat","gourmand"]} -> {"name":"Hedge Trimmer Guard","deck":"colorless_regime","size":36,"hp":24,"mixed":["necrocrat","gourmand"]} | Level 20 normal, 100%; the level-20 player has 20 HP, the Flamethrower and the Lifting Belt. | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| D-PC node 4 (Gallery Curator) | {"name":"Gallery Curator","deck":"colorless_regime","size":29,"hp":15,"mixed":["necrocrat","gourmand"]} -> {"name":"Gallery Curator","deck":"colorless_regime","size":36,"hp":25,"mixed":["necrocrat","gourmand"]} | same | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| D-PC node 5 (Mirror Knight) | {"name":"Mirror Knight","deck":"necrocrat_beefcake","size":30,"hp":18,"icon":"delapouite/shinto-shrine-mirror"} -> {"name":"Mirror Knight","deck":"necrocrat_beefcake","size":36,"hp":28,"icon":"delapouite/shinto-shrine-mirror"} | Mirror Knight elite 100% (Polished rule). | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| D-PC node 6 (Ministry Clerk) | {"name":"Ministry Clerk","deck":"gourmand_necrocrat","size":30,"hp":15,"icon":"delapouite/stamper"} -> {"name":"Ministry Clerk","deck":"gourmand_necrocrat","size":36,"hp":25,"icon":"delapouite/stamper"} | Normal 100%. | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| D-PC node 9 (Royal Staircase Guard) | {"name":"Royal Staircase Guard","deck":"colorless_regime","size":33,"hp":22,"mixed":["necrocrat","gourmand"]} -> {"name":"Royal Staircase Guard","deck":"colorless_regime","size":38,"hp":30,"mixed":["necrocrat","gourmand"]} | Royal Staircase Guard elite 100% (Royal Guard rule). | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| D-PC node 13 (Coup Barracks Sergeant) | {"name":"Coup Barracks Sergeant","deck":"necrocrat_beefcake","size":30,"hp":17} -> {"name":"Coup Barracks Sergeant","deck":"necrocrat_beefcake","size":36,"hp":26} | Normal 100%. | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| D-PC node 15 (Seed Vault Gardener) | {"name":"Seed Vault Gardener","deck":"necrocrat_refusemancer","size":30,"hp":17} -> {"name":"Seed Vault Gardener","deck":"necrocrat_refusemancer","size":36,"hp":26} | Normal 100%. | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| D-PC node 20 (Clocktower Sentinel) | {"name":"Clocktower Sentinel","deck":"colorless_regime","size":32,"hp":21,"mixed":["necrocrat","gourmand"]} -> {"name":"Clocktower Sentinel","deck":"colorless_regime","size":38,"hp":30,"mixed":["necrocrat","gourmand"]} | Clocktower Sentinel elite 100%. | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| S-BEEF node 1 (Rival Lifter at Base Camp) | {"name":"Rival Lifter at Base Camp"} -> {"name":"Rival Lifter at Base Camp","hp":26,"size":34} | Postgame side dungeon (level 22), 100%. | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| S-BEEF node 2 (Squat Rack Sentinel) | {"name":"Squat Rack Sentinel"} -> {"name":"Squat Rack Sentinel","hp":27,"size":35} | same | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| S-BEEF boss | {"deck":"beefcake_bruisers","extra":{"B-30":1},"hp":20,"icon":"delapouite/mammoth"} -> {"deck":"beefcake_bruisers","extra":{"B-30":1},"hp":32,"icon":"delapouite/mammoth"} | The Ancient Spotter 94%: 32 HP plus Hustle for its Beefcake units. | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| D-LAB node 2 (Decontamination Technician) | {"name":"Decontamination Technician","deck":"necro_control","size":38,"hp":30,"ai":"Aggressive"} -> {"name":"Decontamination Technician","deck":"necro_control","size":42,"hp":40,"ai":"Aggressive"} | Postgame (level 26), 100%; the level-26 player has 23 HP and a full kit. | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| D-LAB node 3 (Escaped Specimen) | {"name":"Escaped Specimen","deck":"refuse_garbage","size":38,"hp":30,"ai":"Aggressive","mixed":["refusemancer","beefcake"]} -> {"name":"Escaped Specimen","deck":"refuse_garbage","size":42,"hp":40,"ai":"Aggressive","mixed":["refusemancer","beefcake"]} | same | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| D-LAB node 5 (The Failed Experiment) | {"name":"The Failed Experiment","deck":"beefcake_bruisers","size":42,"hp":36,"ai":"Aggressive","mixed":["beefcake","necrocrat","gourmand"],"extra":{"B-28":1}} -> {"name":"The Failed Experiment","deck":"beefcake_bruisers","size":44,"hp":46,"ai":"Aggressive","mixed":["beefcake","necrocrat","gourmand"],"extra":{"B-28":1}} | Elite 90%. | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| D-LAB node 6 (Observation Ward Orderly) | {"name":"Observation Ward Orderly","deck":"gourmand_control","size":40,"hp":32,"ai":"Balanced"} -> {"name":"Observation Ward Orderly","deck":"gourmand_control","size":42,"hp":42,"ai":"Balanced"} | Normal 100%. | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| D-LAB node 10 (The Drain Warden) | {"name":"The Drain Warden","deck":"necro_control","size":42,"hp":38,"ai":"Aggressive","mixed":["necrocrat","refusemancer","gourmand","beefcake"],"extra":{"N-29":1,"C-30":1}} -> {"name":"The Drain Warden","deck":"necro_control","size":44,"hp":48,"ai":"Aggressive","mixed":["necrocrat","refusemancer","gourmand","beefcake"],"extra":{"N-29":1,"C-30":1}} | Elite 100% (Drained rule). | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| D-LAB node 11 (Siphon's Research Assistant) | {"name":"Siphon's Research Assistant","deck":"gourmand_control","size":40,"hp":34,"ai":"Balanced","mixed":["gourmand","necrocrat"]} -> {"name":"Siphon's Research Assistant","deck":"gourmand_control","size":42,"hp":44,"ai":"Balanced","mixed":["gourmand","necrocrat"]} | Normal 100%. | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| D-LAB boss | {"deck":"necro_control","extra":{"N-33":1,"B-32":1,"G-33":1,"R-33":1,"C-30":1,"C-31":1},"hp":50,"icon":"delapouite/warlock-eye"} -> {"deck":"necro_control","extra":{"N-33":1,"B-32":1,"G-33":1,"R-33":1,"C-30":1,"C-31":1},"hp":60,"icon":"delapouite/warlock-eye"} | Dr. Siphon 100%: 60 HP plus Siphoned Power. | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| S-IRON node 1 (Calf Raise Crusher) | {"name":"Calf Raise Crusher","deck":"beefcake_rush","hp":11,"size":24,"ai":"Aggressive","icon":"lorc/muscle-up"} -> {"name":"Calf Raise Crusher","deck":"beefcake_rush","hp":10,"size":24,"ai":"Aggressive","icon":"lorc/muscle-up","infra":12} | Level 6 side dungeon at 52/42/73 in the baseline: lighter, fewer basics (Iron). | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| S-IRON node 2 (Squat Rack Squatter) | {"name":"Squat Rack Squatter","deck":"beefcake_tools","hp":12,"size":25,"ai":"Defensive","icon":"delapouite/strong-man"} -> {"name":"Squat Rack Squatter","deck":"beefcake_tools","hp":11,"size":24,"ai":"Defensive","icon":"delapouite/strong-man","infra":12} | same | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| S-IRON boss | {"deck":"beefcake_rush","extra":{"B-12":2},"hp":16,"icon":"delapouite/mammoth"} -> {"deck":"beefcake_rush","extra":{"B-12":2},"hp":15,"icon":"delapouite/mammoth","infra":13} | Baron Quadzilla 73% (boss band 40-60) - but the two normals in front of him were the problem; 15 HP and 13 basics plus the Leg Day rule. | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| S-TOWN node 1 (Rusty Gate Clockwork) | {"name":"Rusty Gate Clockwork","deck":"colorless_militia","size":27,"hp":12} -> {"name":"Rusty Gate Clockwork","deck":"colorless_militia","size":26,"hp":11} | Level 6 town side dungeon: 71% normal. | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| S-TOWN node 2 (Banner Hall Guardian) | {"name":"Banner Hall Guardian","deck":"colorless_militia","size":29,"hp":14} -> {"name":"Banner Hall Guardian","deck":"colorless_militia","size":28,"hp":13} | 83%, keep close. | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| S-TOWN boss | {"deck":"four_paths","extra":{"C-21":1},"hp":20,"icon":"delapouite/cyborg-face"} -> {"deck":"four_paths","extra":{"C-21":1},"hp":22,"icon":"delapouite/cyborg-face"} | The Old Kingdom Automaton 96%: 22 HP plus one of each resource. | baseline_quick.md (pre-rebalance decks): D-HFA 98-100, S-NECRO 100, D-TTK 77-90 / boss 88, S-GOUR 73-98, S-REF 98, Capital 96-100, D-PC 100, Primm 98/83/83, S-CAP 100, S-BEEF 92-100, D-LAB 90-100; S-IRON 52/42/73 |
| Corrupted NPCs (second pass) | Moss Mulligan 17 -> 16 HP; Prudence Pallor necro_control 26 cards -> necro_zombies 30 cards / 15 basics, 18 -> 22 HP | Moss 55% after the first pass (band 60-75); Prudence still 95%: a control list with no bodies cannot threaten a level-3 deck. | e_town.md (60 games) |
| Shiro Swindle (second pass) | deck rebuilt: 3 Notary Wraiths, 2 Audit Wraiths, 2 Sous Boos, Ghoul Sommelier, the Breakroom, 2 Late Fees, 2 Underdog's Gambits, 2 Health Code Violations; the 1/1 Interns, Line Cooks and Mercenary Captains are out | Replay: at 30 HP and Aggressive he still lost 4/4 to a level-12 Necrocrat - the old list had no way to deal damage. | replay |
| Progression model: consumables per fight | Draught x2 / Salve x2 / Salve x3 + Firebrand x2 / + Stone x2 -> Draught x1 / Salve x1 / Salve x2 + Firebrand x1 / + Stone x1 | Three Salves (12 HP) and two Firebrands every fight made the level 10+ player unbeatable; charges are bought per use. | e_town.md: Shiro 98% at 30 HP |

## Part F - equipment and items

| Piece / item | Old -> New | Why | Evidence |
|---|---|---|---|
| Solid Plate | Common -> Uncommon | A team-wide +1 defense is the same weight as the Wicked Dagger (+1 attack, Uncommon); Commons are flat HP and draws. Price unchanged (110). | rarity audit |

### Overnight Oct 18 (Part 1): measured lifts

New sim mode `--what=gear` (`tools/balance_sim_tool.gd`): every Path's expected player plays the same seeds bare, with one piece or one
item (one charge), and with the level's model gear/items. Common random numbers, so a piece that changes nothing shows exactly the bare
number. Reports: `docs/design/sim/f_gear_l5.md` (Flexing Brute, L5, 40 games per variant), `f_gear_l12.md` (Meatloaf Golem, L12, 32 games).

- **L5** (bare 45%): every common +0..+8, Solid Plate / Wicked Dagger +10, model gear +8, model gear + items +10. Gear matters a little and trivializes nothing.
  Weak: Extra Pocket +0, Field Bandage +0, Scroll of Insight +2.
- **L12** (bare 28%): model gear +41, model items +19, both +50. Epics: Big Brain Beret +31, Overdue Library Book +25, Elastic Waistband +22,
  Compliance Clipboard +16, Gauntlets +9, Flamethrower +0. Path pieces on their own Path: Grandma's Rolling Pin Gourmand 50 -> 88 (+38),
  Trash Panda Tiara Refusemancer 13 -> 38, Notarized Seal Necrocrat 13 -> 38, Bandolier Beefcake 38 -> 50, Velvet Rope Gourmand 50 -> 75 (9.7 turns).
  Net-negative pieces: Hover Boots -13, Cheater's Dice -13, Thorned Loincloth -6. Reckless Tonic (one 6 HP gulp) +19, the best item.
- **Item use had no limit in battle**: a stack of Salves (3 charges each, stackable) could all be drunk in one fight, so consumables could
  carry any fight. The sim (and the progression model) always assumed "a fight-worth of charges".

| Piece / item | Old -> New | Why | Evidence |
|---|---|---|---|
| Items in battle (rule) | any number of uses per battle -> **each equipped item once per battle** (`GameState.items_used`; the bar greys it out, "Each item works once per battle") | Bounds consumables at 1 / 2 / 3 uses per fight (the item slots), the amount the encounters are tuned around; charges left over carry to later fights. | the model above; `test_items.gd` |
| Grandma's Rolling Pin | Uncommon -> **Epic** | +38 on Gourmand at L12, the largest single lift measured; as an Epic it competes for the one Epic slot (cap 1 until L13). Price unchanged (240). | f_gear_l12.md |
| Trash Panda Tiara | Epic -> **Uncommon** | Same effect as the Uncommon Protein Shaker Bandolier (+1/+1 for one Path's units); the Path buffs sit at one rarity. | rarity audit, f_gear_l12.md |
| Big Brain Beret (Epic, 300) | draw +1 each turn, one non-infra card per turn -> **same, and max HP -2** | +31 at L12, the strongest bought piece; the AI barely feels the one-card limit, so it gets a second drawback. | f_gear_l12.md |
| Cheater's Dice (Uncommon, 260) | always first, opening hand -1 -> **always first** | -13: worse than nothing. | f_gear_l12.md |
| Thorned Loincloth (Uncommon, 280) | max HP -5 -> **max HP -2**, retaliation unchanged | -6: worse than nothing. | f_gear_l12.md |
| Hover Boots | price 300 -> **220**; the model player no longer wears them at L14 (keeps the Traveler's Boots) | -13 for a deck that must block: a niche piece for racing decks, priced like one. | f_gear_l12.md |
| Extra Pocket (Common) | price 90 -> **60** | +0 at L5: a convenience piece. | f_gear_l5.md |
| Scroll of Insight | Draw a card -> **Draw 2 cards** (price 45, 2 charges) | +2: one card was not worth an item slot. | f_gear_l5.md |
| Field Bandage | price 35 -> **25** | +0: mending a unit rarely matters; cheap filler. | f_gear_l5.md |
| Reckless Tonic | price 30 -> **45** | +19, the best item, at the lowest price. | f_gear_l12.md |

### Overnight Oct 18 (Part 1): economy check

`tools/economy_audit.gd` (report `docs/design/sim/economy.md`) sums the one-time gold sources: level rewards 3,070 (L2-5 180, L6-10 320,
L11-20 1,020, L21-30 1,550), 25 quests 1,920, 67 dungeon battle nodes 3,645, 14 first clears 1,410 - about 10,000, plus hidden chests
(roughly 300-600 per area) and repeatable roamers (Crosspath 12-14, zones 25-50, Capital 35-120 each). Prices: cards 20-200 (rarity base
15/35/80/160 + 5 per energy), Path Pack 150, General 100/220, Gilded 600, Prismatic 900, gear 60-130 (basic) / 220-320 (advanced and the
freed-zone pieces), items 25-55.

- **Start to the Gainlands (L5)**: about 500-600 gold (tutorial, L2-5 rewards, the two starter quests, a few outskirts fights) against the
  model's shopping (Cuirass 60 + Helmet 70 + a Draught 40 + one Path Pack 150 = 320). Comfortable, not lavish.
- **Mid and late game**: income runs ahead of the fixed sinks (all gear about 3,300, a full Path collection about 2,600, items); the surplus
  goes into Path and Gilded packs, which is the intended open-ended sink. No price change needed beyond the item fixes above; card prices
  stay (a common at ~25 is a fight's pay).
- **Crosspath outskirts roamers** pay 12-14 gold and respawn every 240 s: a grind of ~3 gold a minute walking, far below a dungeon node
  (35-100). Left as is (they exist for the first levels, not for farming).
- **Alchemist**: under the copy caps a copy only becomes essence once you already own the cap (3 commons), so essence arrives slowly: 10 of
  two Paths meant roughly ten surplus commons of each, i.e. many off-Path packs, before the first brew.

| What | Old -> New | Why | Evidence |
|---|---|---|---|
| Alchemist minimum essence per Path | 10 -> **6** (gold cost 100 unchanged) | Copies only turn into essence above the cap, so 10 of two Paths came far later than the Alchemist opens; 6 is reachable by mid-game with one off-Path. | economy audit above |

## Part E - encounter tuning, batch 6 (basics ratio for every dungeon; the Hall's rules)

| Encounter | Old -> New | Why | Evidence |
|---|---|---|---|
| D-HFA defaults | {"archetypes":["necro_zombies","necro_control"],"icons":["delapouite/tie","delapouite/shambling-zombie","lorc/ghost","delapouite/warlock-eye","delapouite/full-folder","delapouite/stamper"],"ais":["Balanced","Defensive","Aggressive"]} -> {"archetypes":["necro_zombies","necro_control"],"icons":["delapouite/tie","delapouite/shambling-zombie","lorc/ghost","delapouite/warlock-eye","delapouite/full-folder","delapouite/stamper"],"ais":["Aggressive","Balanced","Aggressive"],"infra":12} | 16 basics in 30 cards is 53% Infrastructure; a real deck runs 42%. Necrocrat foes press instead of sitting back. | e_D-HFA.md at 48 games: 85 / 100 / 98 / 98 / 100 / 98 / 88 with 18-34 HP - the foes draw basics, not threats |
| D-TTK defaults | {"archetypes":["gourmand_golems","gourmand_control"],"icons":["delapouite/chef-toque","delapouite/ice-golem","delapouite/gingerbread-man","lorc/bubbling-flask","delapouite/pirate-cannon"],"ais":["Balanced","Defensive","Aggressive"]} -> {"archetypes":["gourmand_golems","gourmand_control"],"icons":["delapouite/chef-toque","delapouite/ice-golem","delapouite/gingerbread-man","lorc/bubbling-flask","delapouite/pirate-cannon"],"ais":["Balanced","Defensive","Aggressive"],"infra":13} | same ratio rule | e_D-HFA.md at 48 games: 85 / 100 / 98 / 98 / 100 / 98 / 88 with 18-34 HP - the foes draw basics, not threats |
| D-ROT defaults | {"archetypes":["refuse_rats","refuse_garbage"],"icons":["lorc/sprout","delapouite/mushrooms-cluster","delapouite/plant-roots","delapouite/tree-roots","lorc/root-tip","cathelineau/tree-face"],"ais":["Balanced","Aggressive","Defensive"]} -> {"archetypes":["refuse_rats","refuse_garbage"],"icons":["lorc/sprout","delapouite/mushrooms-cluster","delapouite/plant-roots","delapouite/tree-roots","lorc/root-tip","cathelineau/tree-face"],"ais":["Balanced","Aggressive","Defensive"],"infra":13} | same | e_D-HFA.md at 48 games: 85 / 100 / 98 / 98 / 100 / 98 / 88 with 18-34 HP - the foes draw basics, not threats |
| D-PC defaults | {"archetypes":["colorless_regime"],"icons":["delapouite/guards","delapouite/portrait","delapouite/shinto-shrine-mirror","delapouite/stamper","cathelineau/nun-face","delapouite/book-cover"],"ais":["Balanced","Defensive","Aggressive"]} -> {"archetypes":["colorless_regime"],"icons":["delapouite/guards","delapouite/portrait","delapouite/shinto-shrine-mirror","delapouite/stamper","cathelineau/nun-face","delapouite/book-cover"],"ais":["Balanced","Defensive","Aggressive"],"infra":14} | same (36-card decks) | e_D-HFA.md at 48 games: 85 / 100 / 98 / 98 / 100 / 98 / 88 with 18-34 HP - the foes draw basics, not threats |
| D-LAB defaults | {"archetypes":["necro_control","gourmand_control","refuse_garbage","beefcake_bruisers"],"icons":["lorc/bubbling-flask","delapouite/warlock-eye","lorc/brainstorm","delapouite/stamper","delapouite/shambling-zombie"],"ais":["Aggressive","Balanced","Defensive"]} -> {"archetypes":["necro_control","gourmand_control","refuse_garbage","beefcake_bruisers"],"icons":["lorc/bubbling-flask","delapouite/warlock-eye","lorc/brainstorm","delapouite/stamper","delapouite/shambling-zombie"],"ais":["Aggressive","Balanced","Defensive"],"infra":16} | same (42-card decks) | e_D-HFA.md at 48 games: 85 / 100 / 98 / 98 / 100 / 98 / 88 with 18-34 HP - the foes draw basics, not threats |
| S-NECRO defaults | {"archetypes":["necro_zombies","necro_control"],"icons":["delapouite/ticket","lorc/ghost","delapouite/files"],"ais":["Balanced","Defensive","Aggressive"]} -> {"archetypes":["necro_zombies","necro_control"],"icons":["delapouite/ticket","lorc/ghost","delapouite/files"],"ais":["Aggressive","Balanced","Aggressive"],"infra":12} | same | e_D-HFA.md at 48 games: 85 / 100 / 98 / 98 / 100 / 98 / 88 with 18-34 HP - the foes draw basics, not threats |
| S-GOUR defaults | {"archetypes":["gourmand_golems","gourmand_control"],"icons":["delapouite/chef-toque","delapouite/fish-monster","delapouite/charging-bull"],"ais":["Balanced","Defensive","Aggressive"]} -> {"archetypes":["gourmand_golems","gourmand_control"],"icons":["delapouite/chef-toque","delapouite/fish-monster","delapouite/charging-bull"],"ais":["Balanced","Defensive","Aggressive"],"infra":13} | same | e_D-HFA.md at 48 games: 85 / 100 / 98 / 98 / 100 / 98 / 88 with 18-34 HP - the foes draw basics, not threats |
| S-REF defaults | {"archetypes":["refuse_rats","refuse_garbage"],"icons":["delapouite/trash-can","lorc/recycle","delapouite/imperial-crown"],"ais":["Balanced","Defensive","Aggressive"]} -> {"archetypes":["refuse_rats","refuse_garbage"],"icons":["delapouite/trash-can","lorc/recycle","delapouite/imperial-crown"],"ais":["Balanced","Defensive","Aggressive"],"infra":13} | same | e_D-HFA.md at 48 games: 85 / 100 / 98 / 98 / 100 / 98 / 88 with 18-34 HP - the foes draw basics, not threats |
| S-CAP defaults | {"archetypes":["colorless_regime"],"icons":["delapouite/guards","delapouite/pipes","lorc/visored-helm"],"ais":["Balanced","Defensive","Aggressive"]} -> {"archetypes":["colorless_regime"],"icons":["delapouite/guards","delapouite/pipes","lorc/visored-helm"],"ais":["Balanced","Defensive","Aggressive"],"infra":14} | same | e_D-HFA.md at 48 games: 85 / 100 / 98 / 98 / 100 / 98 / 88 with 18-34 HP - the foes draw basics, not threats |
| S-BEEF defaults | {"archetypes":["beefcake_rush","beefcake_tools","beefcake_bruisers"],"icons":["lorc/muscle-up","delapouite/strong-man","delapouite/mammoth"],"ais":["Balanced","Defensive","Aggressive"]} -> {"archetypes":["beefcake_rush","beefcake_tools","beefcake_bruisers"],"icons":["lorc/muscle-up","delapouite/strong-man","delapouite/mammoth"],"ais":["Balanced","Defensive","Aggressive"],"infra":14} | same | e_D-HFA.md at 48 games: 85 / 100 / 98 / 98 / 100 / 98 / 88 with 18-34 HP - the foes draw basics, not threats |
| S-TOWN defaults | {"archetypes":["colorless_militia"],"icons":["delapouite/cyborg-face","delapouite/steampunk-goggles","delapouite/castle"],"ais":["Balanced","Defensive","Aggressive"]} -> {"archetypes":["colorless_militia"],"icons":["delapouite/cyborg-face","delapouite/steampunk-goggles","delapouite/castle"],"ais":["Balanced","Defensive","Aggressive"],"infra":12} | same | e_D-HFA.md at 48 games: 85 / 100 / 98 / 98 / 100 / 98 / 88 with 18-34 HP - the foes draw basics, not threats |
| D-HFA boss | {"deck":"necro_control","extra":{"N-33":1,"N-32":1},"hp":34,"icon":"delapouite/stamper"} -> {"deck":"necro_control","extra":{"N-33":1,"N-32":1,"N-28":1,"N-29":1},"hp":34,"icon":"delapouite/stamper","infra":15} | Mortimer 88% at 34 HP: a Lich and Mass Layoffs join his hand, 15 basics instead of 17. | e_D-HFA.md at 48 games: 85 / 100 / 98 / 98 / 100 / 98 / 88 with 18-34 HP - the foes draw basics, not threats |
| Hall of Final Approvals rules | Notary Wraith +0/+1 -> +1/+1; Undersecretary Vellum + a Zombie Temp every second turn; Mortimer: a Temp every turn (was every second) and +1 attack | Elites at 98-100% and the boss at 88% at 24 / 34 HP. | e_D-HFA.md |
| Capital roamers and gate | Compliance Officer 27 cards / 16 basics / 14 HP -> 32 / 13 / 22; Perfection Inspector 27 / 15 / 16 -> 32 / 13 / 24; Rift Wretch 30 / 15 / 15 -> 32 / 13 / 22; Captain Spotless 38 / 16 / 24 -> 38 / 15 / 30 + The Wanderer, Mirrored Hall | 96-100% at level 18 (the level-18 player has 19 HP and an Epic). | baseline_quick.md |
| Colonel Casserole (Buffet gate) | 30 cards / 16 basics / 16 HP -> 32 / 14 / 22 | 90% at level 12 (elite band 60-75), plus the Field Rations rule. | baseline_quick.md |

## Part E - encounter tuning, batch 7 (Hall third pass)

| Encounter | Old -> New | Why | Evidence |
|---|---|---|---|
| D-HFA node 7 (Notary Wraith) | {"name":"Notary Wraith","deck":"necro_control","size":33,"hp":24} -> {"name":"Notary Wraith","deck":"necro_control","size":33,"hp":26} | Notary Wraith 90% (elite band 60-75). | e_D-HFA.md after batch 6: 85 / 100 / 90 / 96 / 83 / 96 / 23 |
| D-HFA node 11 (Undersecretary Vellum) | {"name":"Undersecretary Vellum","deck":"necro_control","size":33,"hp":24} -> {"name":"Undersecretary Vellum","deck":"necro_control","size":33,"hp":26} | Undersecretary Vellum 83%. | e_D-HFA.md after batch 6: 85 / 100 / 90 / 96 / 83 / 96 / 23 |
| D-HFA boss | {"deck":"necro_control","extra":{"N-33":1,"N-32":1,"N-28":1,"N-29":1},"hp":34,"icon":"delapouite/stamper","infra":15} -> {"deck":"necro_control","extra":{"N-33":1,"N-32":1,"N-28":1,"N-29":1},"hp":30,"icon":"delapouite/stamper","infra":15} | Mortimer 23% with a Temp every turn; back to 30 HP with Temps every second turn. | e_D-HFA.md after batch 6: 85 / 100 / 90 / 96 / 83 / 96 / 23 |
| Mortimer Grimsby (third pass) | Temp every turn -> every second turn; 34 -> 30 HP | 23% after the second pass (boss band 40-60); elites 90 / 83 with 24 HP -> 26. | e_D-HFA.md |
| Colonel Casserole (second pass) | 32 cards / 22 HP -> 30 / 18 | 15% with the Field Rations Golem (elite band 60-75). | e_zone_gourmand.md |

## Part E - encounter tuning, batch 8 (Omakase)

| Encounter | Old -> New | Why | Evidence |
|---|---|---|---|
| S-GOUR node 1 (Apprentice Itamae) | {"name":"Apprentice Itamae","hp":20,"size":31} -> {"name":"Apprentice Itamae","hp":16,"size":28} | Apprentice Itamae 33% at 20 HP (normal band 80+): the first fight of a three-fight side dungeon must be a warm-up. | e_S-GOUR.md at 40 games: 33 / 80 / 40 |

## Part E - encounter tuning, batch 9 (Test Kitchen measured; the unmeasured batch-5 raises halved, to re-measure in Part G)

| Encounter | Old -> New | Why | Evidence |
|---|---|---|---|
| D-TTK node 2 (Prep Station Sous-Chef) | {"name":"Prep Station Sous-Chef","hp":20,"size":31} -> {"name":"Prep Station Sous-Chef","hp":16,"size":29} | Prep Station 50% at 20 HP (normal band 80+). | e_D-TTK.md at 40 games: 50 / 83 / 23 / 57 / 45 / 55 / 3 - batch 5 overshot |
| D-TTK node 3 (Frozen Line Cook) | {"name":"Frozen Line Cook","hp":20,"size":31} -> {"name":"Frozen Line Cook","hp":17,"size":29} | 83%: a touch lighter to match node 2. | e_D-TTK.md at 40 games: 50 / 83 / 23 / 57 / 45 / 55 / 3 - batch 5 overshot |
| D-TTK node 6 (Unfinished War Machine) | {"name":"Unfinished War Machine","deck":"gourmand_golems","size":34,"hp":26,"icon":"delapouite/pirate-cannon"} -> {"name":"Unfinished War Machine","deck":"gourmand_golems","size":31,"hp":20,"icon":"delapouite/pirate-cannon"} | Unfinished War Machine 23% at 26 HP with the Conveyor rule (elite band 60-75). | e_D-TTK.md at 40 games: 50 / 83 / 23 / 57 / 45 / 55 / 3 - batch 5 overshot |
| D-TTK node 8 (Assembly Line Golem) | {"name":"Assembly Line Golem","hp":21,"size":32} -> {"name":"Assembly Line Golem","hp":17,"size":30} | Assembly Line Golem 57%. | e_D-TTK.md at 40 games: 50 / 83 / 23 / 57 / 45 / 55 / 3 - batch 5 overshot |
| D-TTK node 11 (Cannon-Blender Gunner) | {"name":"Cannon-Blender Gunner","deck":"gourmand_golems","size":34,"hp":26,"icon":"delapouite/pirate-cannon"} -> {"name":"Cannon-Blender Gunner","deck":"gourmand_golems","size":31,"hp":21,"icon":"delapouite/pirate-cannon"} | Cannon-Blender Gunner 45% with Shrapnel. | e_D-TTK.md at 40 games: 50 / 83 / 23 / 57 / 45 / 55 / 3 - batch 5 overshot |
| D-TTK node 12 (Expediter of the Pass) | {"name":"Expediter of the Pass","hp":21,"size":32} -> {"name":"Expediter of the Pass","hp":17,"size":30} | Expediter 55%. | e_D-TTK.md at 40 games: 50 / 83 / 23 / 57 / 45 / 55 / 3 - batch 5 overshot |
| D-TTK boss | {"deck":"gourmand_golems","extra":{"G-33":1},"hp":34,"icon":"delapouite/chef-toque"} -> {"deck":"gourmand_golems","extra":{"G-33":1},"hp":26,"icon":"delapouite/chef-toque"} | The Doppelganger 3% at 34 HP with a starting Golem and 3 Ingredients (boss band 40-60); the rule stays, the HP goes back under the old 28. | e_D-TTK.md at 40 games: 50 / 83 / 23 / 57 / 45 / 55 / 3 - batch 5 overshot |
| S-REF node 1 (Alley Gate Raccoon) | {"name":"Alley Gate Raccoon","hp":22,"size":32} -> {"name":"Alley Gate Raccoon","hp":18,"size":30} | Batch 5 raise halved (unmeasured; the Test Kitchen showed the raises overshoot). | e_D-TTK.md at 40 games: 50 / 83 / 23 / 57 / 45 / 55 / 3 - batch 5 overshot |
| S-REF node 2 (Pizza Crust Courtier) | {"name":"Pizza Crust Courtier","hp":23,"size":33} -> {"name":"Pizza Crust Courtier","hp":19,"size":31} | same | e_D-TTK.md at 40 games: 50 / 83 / 23 / 57 / 45 / 55 / 3 - batch 5 overshot |
| S-REF boss | {"deck":"refuse_rats","extra":{"R-27":1},"hp":30,"icon":"delapouite/imperial-crown"} -> {"deck":"refuse_rats","extra":{"R-27":1},"hp":25,"icon":"delapouite/imperial-crown"} | same | e_D-TTK.md at 40 games: 50 / 83 / 23 / 57 / 45 / 55 / 3 - batch 5 overshot |
| S-CAP node 1 (Sewer Checkpoint Enforcer) | {"name":"Sewer Checkpoint Enforcer","deck":"colorless_regime","size":33,"hp":24,"mixed":["necrocrat","gourmand"]} -> {"name":"Sewer Checkpoint Enforcer","deck":"colorless_regime","size":30,"hp":18,"mixed":["necrocrat","gourmand"]} | same | e_D-TTK.md at 40 games: 50 / 83 / 23 / 57 / 45 / 55 / 3 - batch 5 overshot |
| S-CAP node 2 (Junction Patrol) | {"name":"Junction Patrol","deck":"colorless_regime","size":34,"hp":26,"mixed":["beefcake","refusemancer"]} -> {"name":"Junction Patrol","deck":"colorless_regime","size":31,"hp":20,"mixed":["beefcake","refusemancer"]} | same | e_D-TTK.md at 40 games: 50 / 83 / 23 / 57 / 45 / 55 / 3 - batch 5 overshot |
| S-CAP node 3 (Enforcer Captain Spotless) | {"name":"Enforcer Captain Spotless","deck":"colorless_regime","size":36,"hp":32,"mixed":["necrocrat","gourmand","beefcake","refusemancer"]} -> {"name":"Enforcer Captain Spotless","deck":"colorless_regime","size":34,"hp":26,"mixed":["necrocrat","gourmand","beefcake","refusemancer"]} | same | e_D-TTK.md at 40 games: 50 / 83 / 23 / 57 / 45 / 55 / 3 - batch 5 overshot |
| S-CAP boss | {"deck":"colorless_regime","extra":{},"hp":32,"icon":"lorc/visored-helm"} -> {"deck":"colorless_regime","extra":{},"hp":26,"icon":"lorc/visored-helm"} | same | e_D-TTK.md at 40 games: 50 / 83 / 23 / 57 / 45 / 55 / 3 - batch 5 overshot |
| D-PC node 2 (Hedge Trimmer Guard) | {"name":"Hedge Trimmer Guard","deck":"colorless_regime","size":36,"hp":24,"mixed":["necrocrat","gourmand"]} -> {"name":"Hedge Trimmer Guard","deck":"colorless_regime","size":32,"hp":19,"mixed":["necrocrat","gourmand"]} | same | e_D-TTK.md at 40 games: 50 / 83 / 23 / 57 / 45 / 55 / 3 - batch 5 overshot |
| D-PC node 4 (Gallery Curator) | {"name":"Gallery Curator","deck":"colorless_regime","size":36,"hp":25,"mixed":["necrocrat","gourmand"]} -> {"name":"Gallery Curator","deck":"colorless_regime","size":32,"hp":20,"mixed":["necrocrat","gourmand"]} | same | e_D-TTK.md at 40 games: 50 / 83 / 23 / 57 / 45 / 55 / 3 - batch 5 overshot |
| D-PC node 5 (Mirror Knight) | {"name":"Mirror Knight","deck":"necrocrat_beefcake","size":36,"hp":28,"icon":"delapouite/shinto-shrine-mirror"} -> {"name":"Mirror Knight","deck":"necrocrat_beefcake","size":33,"hp":23,"icon":"delapouite/shinto-shrine-mirror"} | same | e_D-TTK.md at 40 games: 50 / 83 / 23 / 57 / 45 / 55 / 3 - batch 5 overshot |
| D-PC node 6 (Ministry Clerk) | {"name":"Ministry Clerk","deck":"gourmand_necrocrat","size":36,"hp":25,"icon":"delapouite/stamper"} -> {"name":"Ministry Clerk","deck":"gourmand_necrocrat","size":32,"hp":20,"icon":"delapouite/stamper"} | same | e_D-TTK.md at 40 games: 50 / 83 / 23 / 57 / 45 / 55 / 3 - batch 5 overshot |
| D-PC node 9 (Royal Staircase Guard) | {"name":"Royal Staircase Guard","deck":"colorless_regime","size":38,"hp":30,"mixed":["necrocrat","gourmand"]} -> {"name":"Royal Staircase Guard","deck":"colorless_regime","size":35,"hp":26,"mixed":["necrocrat","gourmand"]} | same | e_D-TTK.md at 40 games: 50 / 83 / 23 / 57 / 45 / 55 / 3 - batch 5 overshot |
| D-PC node 13 (Coup Barracks Sergeant) | {"name":"Coup Barracks Sergeant","deck":"necrocrat_beefcake","size":36,"hp":26} -> {"name":"Coup Barracks Sergeant","deck":"necrocrat_beefcake","size":32,"hp":21} | same | e_D-TTK.md at 40 games: 50 / 83 / 23 / 57 / 45 / 55 / 3 - batch 5 overshot |
| D-PC node 15 (Seed Vault Gardener) | {"name":"Seed Vault Gardener","deck":"necrocrat_refusemancer","size":36,"hp":26} -> {"name":"Seed Vault Gardener","deck":"necrocrat_refusemancer","size":32,"hp":21} | same | e_D-TTK.md at 40 games: 50 / 83 / 23 / 57 / 45 / 55 / 3 - batch 5 overshot |
| D-PC node 20 (Clocktower Sentinel) | {"name":"Clocktower Sentinel","deck":"colorless_regime","size":38,"hp":30,"mixed":["necrocrat","gourmand"]} -> {"name":"Clocktower Sentinel","deck":"colorless_regime","size":35,"hp":26,"mixed":["necrocrat","gourmand"]} | same | e_D-TTK.md at 40 games: 50 / 83 / 23 / 57 / 45 / 55 / 3 - batch 5 overshot |
| S-BEEF node 1 (Rival Lifter at Base Camp) | {"name":"Rival Lifter at Base Camp","hp":26,"size":34} -> {"name":"Rival Lifter at Base Camp","hp":22,"size":32} | same | e_D-TTK.md at 40 games: 50 / 83 / 23 / 57 / 45 / 55 / 3 - batch 5 overshot |
| S-BEEF node 2 (Squat Rack Sentinel) | {"name":"Squat Rack Sentinel","hp":27,"size":35} -> {"name":"Squat Rack Sentinel","hp":23,"size":33} | same | e_D-TTK.md at 40 games: 50 / 83 / 23 / 57 / 45 / 55 / 3 - batch 5 overshot |
| S-BEEF boss | {"deck":"beefcake_bruisers","extra":{"B-30":1},"hp":32,"icon":"delapouite/mammoth"} -> {"deck":"beefcake_bruisers","extra":{"B-30":1},"hp":26,"icon":"delapouite/mammoth"} | same | e_D-TTK.md at 40 games: 50 / 83 / 23 / 57 / 45 / 55 / 3 - batch 5 overshot |
| D-LAB node 2 (Decontamination Technician) | {"name":"Decontamination Technician","deck":"necro_control","size":42,"hp":40,"ai":"Aggressive"} -> {"name":"Decontamination Technician","deck":"necro_control","size":40,"hp":34,"ai":"Aggressive"} | same | e_D-TTK.md at 40 games: 50 / 83 / 23 / 57 / 45 / 55 / 3 - batch 5 overshot |
| D-LAB node 3 (Escaped Specimen) | {"name":"Escaped Specimen","deck":"refuse_garbage","size":42,"hp":40,"ai":"Aggressive","mixed":["refusemancer","beefcake"]} -> {"name":"Escaped Specimen","deck":"refuse_garbage","size":40,"hp":34,"ai":"Aggressive","mixed":["refusemancer","beefcake"]} | same | e_D-TTK.md at 40 games: 50 / 83 / 23 / 57 / 45 / 55 / 3 - batch 5 overshot |
| D-LAB node 5 (The Failed Experiment) | {"name":"The Failed Experiment","deck":"beefcake_bruisers","size":44,"hp":46,"ai":"Aggressive","mixed":["beefcake","necrocrat","gourmand"],"extra":{"B-28":1}} -> {"name":"The Failed Experiment","deck":"beefcake_bruisers","size":42,"hp":40,"ai":"Aggressive","mixed":["beefcake","necrocrat","gourmand"],"extra":{"B-28":1}} | same | e_D-TTK.md at 40 games: 50 / 83 / 23 / 57 / 45 / 55 / 3 - batch 5 overshot |
| D-LAB node 6 (Observation Ward Orderly) | {"name":"Observation Ward Orderly","deck":"gourmand_control","size":42,"hp":42,"ai":"Balanced"} -> {"name":"Observation Ward Orderly","deck":"gourmand_control","size":40,"hp":36,"ai":"Balanced"} | same | e_D-TTK.md at 40 games: 50 / 83 / 23 / 57 / 45 / 55 / 3 - batch 5 overshot |
| D-LAB node 10 (The Drain Warden) | {"name":"The Drain Warden","deck":"necro_control","size":44,"hp":48,"ai":"Aggressive","mixed":["necrocrat","refusemancer","gourmand","beefcake"],"extra":{"N-29":1,"C-30":1}} -> {"name":"The Drain Warden","deck":"necro_control","size":42,"hp":42,"ai":"Aggressive","mixed":["necrocrat","refusemancer","gourmand","beefcake"],"extra":{"N-29":1,"C-30":1}} | same | e_D-TTK.md at 40 games: 50 / 83 / 23 / 57 / 45 / 55 / 3 - batch 5 overshot |
| D-LAB node 11 (Siphon's Research Assistant) | {"name":"Siphon's Research Assistant","deck":"gourmand_control","size":42,"hp":44,"ai":"Balanced","mixed":["gourmand","necrocrat"]} -> {"name":"Siphon's Research Assistant","deck":"gourmand_control","size":40,"hp":38,"ai":"Balanced","mixed":["gourmand","necrocrat"]} | same | e_D-TTK.md at 40 games: 50 / 83 / 23 / 57 / 45 / 55 / 3 - batch 5 overshot |
| D-LAB boss | {"deck":"necro_control","extra":{"N-33":1,"B-32":1,"G-33":1,"R-33":1,"C-30":1,"C-31":1},"hp":60,"icon":"delapouite/warlock-eye"} -> {"deck":"necro_control","extra":{"N-33":1,"B-32":1,"G-33":1,"R-33":1,"C-30":1,"C-31":1},"hp":52,"icon":"delapouite/warlock-eye"} | same | e_D-TTK.md at 40 games: 50 / 83 / 23 / 57 / 45 / 55 / 3 - batch 5 overshot |

## Playtest v0.4.0, Part E - Yeet and the Raccoon (the live sheet already carries these texts)

| Card | Old -> New | Why | Evidence |
|---|---|---|---|
| B-25 Yeet | text: "Target unit you control deals damage equal to its attack to target unit or opponent." -> "Target unit you control deals damage equal to its attack to target unit or opponent. Then destroy the unit you control." | Yeet is a sacrifice now: the thrown unit is destroyed after it lands (script `damage(b,atk(a),a); destroy(a)`); the AI weighs the loss through its normal look-ahead. | - |
| R-27 Raccoon | text: "When your units eat garbage, they don't pay energy." -> "You may eat garbage for free during your turn." | Same mechanic (the `free_eat` flag: no energy for the eat, the Garbage is still used, printed HP costs still apply), plainer wording. | - |

## Playtest v0.4.0, Part D - Crosspath outskirts roamers (new fights, tuned at level 1 with every Path's starter)

Three easy respawning enemies on the lanes round the edge of Crosspath (`core/zone/town_enemies.gd`; sim group `town:roamer`, report `docs/design/sim/s2_town_roamers.md`). Target: any Path's starter deck wins 85%+.

| Enemy | Deck | HP | AI | Gold / XP | Sim (40 games, B / N / G / R / all) | Earlier tries |
|---|---|---:|---|---|---|---|
| Stray Gym Hound | gourmand_control 20 cards / 13 infra | 4 | Defensive | 12 / 30 | 93 / 80 / 80 / 85 / **84%** | beefcake_rush 6 HP 62%; beefcake_tools 5 HP 67%; colorless_militia 5 HP 55%; necro_zombies 5 HP 72%; gourmand_control 5 HP 83% |
| Lost Junior Clerk | necro_control 20 / 10 | 5 | Defensive | 14 / 32 | 98 / 93 / 83 / 88 / **90%** | 7 HP 88%, 6 HP 88% |
| Bin Raccoon | refuse_rats 20 / 12 | 4 | Defensive | 12 / 30 | 90 / 85 / 83 / 83 / **85%** | refuse_rats 20/10 6 HP 68%; 20/12 5 HP 82% |

Level-5 pace: the Forgotten Cave pays 150 XP (15 + 15 + 120), the two starter quests 60 (Meet the Merchants 40, Make It Yours 20) = 210 of the 300 XP level 5 needs; three roamer wins (30 + 32 + 30 = 92) close the gap, so the armory quest opens after the tutorial, the two starter quests and three outskirts fights (four if one is lost). A beaten roamer is back after 240 s of game time.
Noise note: at 30-40 games a Path's column moves about +/-7 points between runs; the weakest cells (Necrocrat and Gourmand vs the hound, 80%) sit at the band's floor.

## Playtest v0.4.0, Part E (4) - the boxes on the battle board

The three small dark squares each side of the board are the **trap slots** (`BattleBoard._trap_slots`, UI-HUD-SLOT art, one per trap a player may set: `GameState.MAX_TRAPS` = 3; a set trap covers its slot). The slightly larger pale box on the right is the **token tray** (`_token_tray`, UI-HUD-TOKENS): where Contract tokens sit; it drew nothing when a player held none. Both stay, made obvious: a faint trap glyph in each empty slot, a "TRAPS - 0 of 3 set" caption with a tooltip (whose traps, what springs them), and a scroll glyph plus "TOKENS (none yet)" on the empty tray with a Contract tooltip. Before/after: `_screenshots/s2_battle_before.png` / `s2_battle_after.png`.

## Playtest v0.4.0, Part F - rules as icons

Every rule that bends a fight is one badge list (`RuleBadges`: zone buff/debuff, dungeon rules at the current node, boons, the Capital's broken services, the fight's one-sided encounter rules) drawn by `RuleIconRow` (hover = text, click = full list): on the node map under the title, in a brief when a run starts, in a brief before each battle, in the zone HUD (the old "+ Pump It Up - Processing Time" text pill) and as a persistent row in the battle HUD under the enemy portrait (the stacked text panels are gone). The enemy's intent stays hidden. Icons for the dungeon rules are listed in `RuleBadges.DUNGEON_ICONS`.

## Playtest v0.4.0, Part H - audio bitrate audit (no change)

`ffprobe` over the 123 music and ambience OGGs: 101-196 kbps, average 126 kbps, 246 minutes, about 218 MB packed. Re-encoding everything to ~96 kbps would save roughly 50 MB at an audible cost on the orchestral loops; with the zip already well under 1 GB the files ship as delivered (inbox item).

## Part G - iterate (Overnight Oct 18, Part 2)

Targets (on-level, first try): normal 80%+, elite 60-75%, boss 40-60%, 6-10 turns. Quick runs (6 games per Path = 24 per fight, about +/-10 points) because a late-game game takes ~1.3 s; every fight of the catalog in iteration 1 (`docs/design/sim/g_iter1.md`, 97 fights incl. the never-measured late groups and the arena), then only the changed fights (`g_iter2_*.md`, `g_iter3_*.md`).

### Iteration 1 (full catalog, after Part 1)

| Kind | Fights | In band | Too hard | Too easy | Mean win | Mean turns |
|---|---:|---:|---:|---:|---:|---:|
| Tutorial | 3 | 3 | 0 | 0 | 96% | 5.2 |
| Normal | 54 | 34 | 20 | 0 | 84% | 7.7 |
| Elite | 21 | 4 | 9 | 8 | 66% | 8.7 |
| Boss | 19 | 3 | 3 | 13 | 69% | 8.2 |

Outliers: the Gainlands roamers (63%), the Buffet gate (42%), Prudence Pallor (25%), the Test Kitchen (boss 21%), the Rotheart (normals 54-63%, an elite 17%, the boss 21%), the Iron Cave and the Forgotten Vault normals (50-58%); too easy: every Capital-side and postgame boss (S-CAP, S-REF, S-BEEF, S-NECRO 79-100%), Captain Spotless, the Castle (normals and elites 100%, Primm phase 1 100%), Shiro (92%), the Lab elites.

**Sim bug found and fixed:** the catalog gave all four corrupted town NPCs `CorruptedNpcs.STARTING_HP` (15) instead of their own `HP_BY_ID` (Prudence has 22), so the town NPC rows never matched the game (`EncounterCatalog.town`).

| Change (iteration 1) | Why |
|---|---|
| Brick Bronson HP 15 -> 13; Moss Mulligan 16 -> 15; Prudence Pallor HP 22 -> 11 | elite at 54% / 58% / 25% (band 60-75); the sim had played all four at 15 HP (catalog bug, fixed: it now reads CorruptedNpcs.HP_BY_ID), so Prudence at her real 22 was far harder than measured |
| Shiro Swindle HP 30 -> 38 | boss at 92% (band 40-60) |
| Flexing Brute HP 9 -> 7 | normal at 63% (band 80+) |
| Protein Shake Golem HP 9 -> 7 | normal at 63% (band 80+) |
| Meatloaf Golem HP 14 -> 12 | normal at 71% |
| Colonel Casserole HP 18 -> 15 | elite at 42% |
| Captain Spotless HP 30 -> 36 | elite at 100% |
| Primm phase 1 HP 30 -> 36 | boss phase at 100% |
| Primm phase 3 HP 28 -> 32 | boss phase at 83% |
| D-HOG node 3 (Courtyard Lifter) hp 10 -> 8 | normal 50% |
| D-HOG node 11 (Trophy Hall Honor Guard) hp 14 -> 12 | elite 46% |
| D-TTK node 2 (Prep Station Sous-Chef) hp 16 -> 14 | normal 71% |
| D-TTK node 6 (Unfinished War Machine) hp 20 -> 17 | elite 50% |
| D-TTK node 11 (Cannon-Blender Gunner) hp 21 -> 18 | elite 50% |
| D-TTK boss HP 26 -> 21 | boss 21% |
| D-ROT node 2 (Overgrown Scarecrow) hp default -> 12 | normal 63% (default 14-16) |
| D-ROT node 3 (Mutant Mushroom Troop) hp default -> 12 | normal 63% |
| D-ROT node 8 (Thorn Maze Stalker) hp default -> 12 | normal 54% |
| D-ROT node 10 (Hive of Mutant Bees) hp 18 -> 14 | elite 17% |
| D-ROT boss HP 28 -> 22 | boss 21% |
| D-PC node 2 (Hedge Trimmer Guard) hp 19 -> 24 | normal 100% |
| D-PC node 4 (Gallery Curator) hp 20 -> 25 | normal 100% |
| D-PC node 6 (Ministry Clerk) hp 20 -> 25 | normal 100% |
| D-PC node 9 (Royal Staircase Guard) hp 26 -> 32 | elite 100% |
| D-PC node 20 (Clocktower Sentinel) hp 26 -> 32 | elite 100% |
| S-BEEF boss HP 26 -> 34 | boss 88% |
| S-NECRO boss HP 28 -> 34 | boss 79% |
| S-REF boss HP 25 -> 34 | boss 100% |
| S-CAP node 3 (Enforcer Captain Spotless) hp 26 -> 34 | boss 100% |
| S-GOUR node 1 (Apprentice Itamae) hp 16 -> 13 | normal 56% |
| S-GOUR node 2 (Conveyor Belt Sushi Chef) hp 21 -> 18 | normal 71% |
| S-TOWN node 1 (Rusty Gate Clockwork) hp 11 -> 9 | normal 58% |
| S-TOWN node 2 (Banner Hall Guardian) hp 13 -> 10 | normal 50% |
| S-TOWN node 3 (The Old Kingdom Automaton) hp 20 -> 23 | boss 71% |
| S-IRON node 1 (Calf Raise Crusher) hp 10 -> 8 | normal 54% |
| S-IRON node 2 (Squat Rack Squatter) hp 11 -> 9 | normal 58% |
| S-IRON boss HP 15 -> 17 | boss 71% |
| D-LAB node 5 (The Failed Experiment) hp 40 -> 44 | elite 92% |
| D-LAB node 10 (The Drain Warden) hp 42 -> 48 | elite 100% |
| D-LAB boss HP 52 -> 58 | boss 71% |
| Arena: Sandbag Sentinel HP 16 -> 13 | normal 67% |
| Arena: Champion of the Four Fists HP 28 -> 33 | elite 88% |
| Arena: Announcer Grand Bellows HP 38 -> 46 | boss 88% |

### Iteration 2 (the changed fights)

HP cuts barely moved the too-hard fights and HP raises did not touch the too-easy ones: the hard ones are lost in 5-7 turns (the foe out-damages the player long before its HP matters) and the easy ones are won before the foe deploys. The lever is deck strength: the number of basics in the foe deck (more basics = fewer threats; for Beefcake foes also more Iron) and a few strong extras for the easy bosses. Results: `_logs/g_iter2_done.txt` / `docs/design/sim/g_iter2_*.md` (Lab boss now 58%, Primm phase 3 75%, D-HOG elite 54%, most others unchanged).

| Change (iteration 2) | Why |
|---|---|
| Flexing Brute basics 12 -> 14 (of 24) | still 67% at 7 HP, lost fast: fewer threats, not less HP |
| Protein Shake Golem basics 12 -> 14 (of 24) | still 63% at 7 HP, fast |
| Colonel Casserole basics 14 -> 16 (of 30) | still 46% at 15 HP |
| Captain Spotless basics 15 -> 12 (of 38) | still 100% at 36 HP |
| D-HOG node 3 (Courtyard Lifter) infra 13 -> 15 | normal 50% after the HP cut, lost fast |
| D-TTK node 2 (Prep Station Sous-Chef) infra default -> 15 | normal 71% |
| D-TTK node 6 (Unfinished War Machine) infra default -> 15 | elite 50% |
| D-TTK node 11 (Cannon-Blender Gunner) infra default -> 15 | elite 54% |
| D-TTK boss infra default -> 19 | boss 21% at 21 HP |
| D-ROT node 2 (Overgrown Scarecrow) infra default -> 16 | normal 63%, lost in ~6 turns |
| D-ROT node 3 (Mutant Mushroom Troop) infra default -> 16 | normal 67%, fast |
| D-ROT node 8 (Thorn Maze Stalker) infra default -> 16 | normal 58%, fast |
| D-ROT node 10 (Hive of Mutant Bees) infra default -> 17 | elite 21%, lost in ~5 turns |
| D-ROT node 10 (Hive of Mutant Bees) ai default -> "Balanced" | elite 21%, its default AI was Aggressive |
| D-ROT boss infra default -> 19 | boss 25%, fast |
| S-GOUR node 1 (Apprentice Itamae) infra default -> 15 | normal 67% |
| S-GOUR node 2 (Conveyor Belt Sushi Chef) infra default -> 15 | normal 75% |
| S-TOWN node 1 (Rusty Gate Clockwork) infra default -> 14 | normal 67% |
| S-TOWN node 2 (Banner Hall Guardian) infra default -> 14 | normal 63% |
| S-CAP node 3 (Enforcer Captain Spotless) infra default -> 11 | boss 100% at 34 HP |
| S-CAP node 3 (Enforcer Captain Spotless) extra default -> {"C-30":1,"C-32":1,"C-34":1} | boss 100%: Royal Audit, Mirrored Hall, the Harmony Engine |
| S-REF boss infra default -> 13 | boss 96% at 34 HP |
| S-BEEF boss infra default -> 13 | boss 79% at 34 HP |
| S-NECRO boss infra default -> 13 | boss 79% at 34 HP |
| S-IRON node 1 (Calf Raise Crusher) infra 12 -> 14, ai Aggressive -> Balanced | normal 58% at 8 HP, fast |
| S-IRON node 2 (Squat Rack Squatter) infra 12 -> 14 | normal 58% at 9 HP, fast |
| D-PC nodes 9 and 20 (Royal Staircase Guard, Clocktower Sentinel) basics 14 -> 11, + Royal Audit + Mirrored Hall | elites 100% at 32 HP |
| Primm phase 1 basics 16 -> 12, + Mirrored Hall | 100% at 36 HP |
| D-LAB nodes 5 and 10 (The Failed Experiment, The Drain Warden) basics 16 -> 13 | elites 92% / 100% at 44 / 48 HP |

### Iteration 3 (the changed fights)

The Test Kitchen came into band (normals 83/92%, elites 63/71%); the Tunnels and the Castle elites, Primm phase 1 and the Lab elites stayed at 92-100% even with fewer basics; the Rotheart normals and the Hive stayed at 17-63% lost in about 5 turns. Results `_logs/g_iter3_done.txt`.

### Iteration 4: encounter rules for the late bosses; the Rotheart; Prudence

| Change (iteration 4) | Why |
|---|---|
| Prudence Pallor deck 30 cards / 15 basics -> 26 / 16 (the trim drops her rarest threats first) | 29% at 11 HP: a level-3 player meets an Epic and a Legendary in a 30-card zombie deck |
| Prudence Pallor AI Aggressive -> Balanced | same |
| Prudence Pallor HP 11 -> 13 | with the lighter deck |
| Protein Shake Golem basics 14 -> 12 again | 58% with 14: for a Beefcake foe more basics also means more Iron |
| Colonel Casserole HP 15 -> 12 | still 42% (it starts with a 3/3 Golem on the field) |
| Hive of Mutant Bees rule Swarm: a Sporeling every turn -> every second turn | elite 17% in 5 turns: a token every turn plus the Rotheart's Overgrowth (every unit +1/+1 each turn) |
| Enforcer Captain Spotless rule Spotless Drill: +1/+1 -> +2/+1 | too easy |
| Royal Staircase Guard rule Royal Guard: +1/+0 -> +1/+1 | too easy |
| Clocktower Sentinel: new rule Clockwork Precision (+1/+1 for its units) | too easy |
| His Majesty the Raccoon: new rule Royal Guard of Bins (+1/+1 for its units) | too easy |
| The Ancient Spotter: new rule Ancient Form (+1/+0 for its units) | too easy |
| Betty Bones, Surly Secretary: new rule Surly (+1/+0 for its units) | too easy |
| The Drain Warden: new rule Drained Strength (+1/+1 for its units) | too easy |
| The Failed Experiment: new rule Unstable (+1/+1 for its units) | too easy |
| D-ROT foes: archetypes rats + garbage -> garbage only; the Hive refuse_rats -> refuse_garbage | the normals were lost in 5-6 turns: rat swarms grow fastest under Overgrowth |
| S-TOWN node 1 (Rusty Gate Clockwork) size 26 -> 24 | normal 50% |
| S-IRON node 2 (Squat Rack Squatter) HP 9 -> 7 | normal 50% |

Results (`_logs/g_iter4_done.txt`): the stat rules work where deck tweaks did not - the Tunnels boss 100 -> 83%, His Majesty 96 -> 67%, Betty 75 -> 71%, the Castle elites 100 -> 83/92%; the Rotheart boss 54 -> 63% (in band), the Hive 17 -> 33%. The Rotheart normals stayed at 58-63%: a replay (`tools/replay_encounter.gd --id=D-ROT:2 --path=gourmand`) shows the sim player turtling (lifegain abilities every turn, almost no attacks) while Overgrowth (every unit +1/+1 each turn) and Rot (1-defense units die at end of turn) grow the foe board - an AI limit under these two dungeon rules rather than a number to tune (inbox).

### Iteration 5

| Change (iteration 5) | Why |
|---|---|
| Prudence Pallor HP 13 -> 10 | 38% with the lighter deck |
| The Ancient Spotter rule Ancient Form: +1/+0 -> +2/+1 | still too easy after iteration 4 |
| Enforcer Captain Spotless rule Spotless Drill: +2/+1 -> +2/+2 | still too easy after iteration 4 |
| The Failed Experiment rule Unstable: +1/+1 -> +2/+1 | still too easy after iteration 4 |
| The Drain Warden rule Drained Strength: +1/+1 -> +2/+1 | still too easy after iteration 4 |
| Clocktower Sentinel rule Clockwork Precision: +1/+1 -> +2/+1 | still too easy after iteration 4 |
| S-TOWN node 1 (Rusty Gate Clockwork) size back to 26, HP 9 -> 7 | 38% at size 24 (worse: fewer basics per threat) |

Results (`_logs/g_iter5.txt`): the Tunnels boss 54% (in band); the Spotter 92%, the Lab elites 92-96%, the Clocktower Sentinel 88% still too easy; Prudence 38% at 13 and at 10 HP alike (lost before her HP matters); the Forgotten Vault gate 63%.

### Starting decks (round robin at level 1, 40 games per pairing)

Before: Beefcake 61% / Gourmand 54% / Refusemancer 48% / Necrocrat 37% (spread 24, `g_decks_l1.md`). Necrocrat vs Beefcake card impact (`g_match_n_b.md`, 80 games): Waiting Room +35, Ghoul +22, Red Tape Dispenser +21, Audit Wraith +16 ... Requisition Form +0, Notary Wraith -6, Invisible Ink -10.

| Change | Why |
|---|---|
| Necrocrat starter: Notary Wraith 3 -> 2, Requisition Form 2 -> 1, Invisible Ink 1 -> 0; Red Tape Dispenser 1 -> 2, Post-Human Resources Ghoul 1 -> 2, Waiting Room 1 -> 2 (45 cards) | the three best-lift cards were single copies, three no-lift cards filled slots |
| Beefcake starter: Overclocked Mill Worker 2 -> 1, Shot Putter 1 -> 2 (45 cards) | Beefcake on top; the Mill Worker is its top-lift card (Part C) |
| Sim reference decks: Necrocrat cuts Notary Wraith before the Red Tape Dispenser | keeps the Dispenser in the higher-level reference decks |

After (`g_decks_l1_after.md`): **Beefcake 52% / Gourmand 57% / Refusemancer 47% / Necrocrat 44%** (spread 13). Tutorial clears with the new decks (`g_tutorial_after.md`, 24 runs each): Beefcake 88%, Refusemancer 83%, Gourmand 79%, Necrocrat 71% (it was 80% at 12 runs).

### Where Part G ends (5 iterations)

| Kind | Fights | In band before -> after | Too hard | Too easy | Mean win | Mean turns |
|---|---:|---|---|---|---|---|
| Tutorial | 3 | 3 -> **3** | 0 -> 0 | 0 -> 0 | 96% -> 96% | 5.2 -> 5.2 |
| Normal | 54 | 34 -> **35** | 20 -> 19 | 0 -> 0 | 84% -> 85% | 7.7 -> 7.6 |
| Elite | 21 | 4 -> **6** | 9 -> 7 | 8 -> 8 | 66% -> 67% | 8.7 -> 8.7 |
| Boss | 19 | 3 -> **5** | 3 -> 2 | 13 -> 12 | 69% -> 65% | 8.2 -> 8.3 |

| Fight | Kind | Target | Before | After | Verdict now |
|---|---|---|---:|---:|---|
| Brick Bronson | Elite | 60-75% | 54% | **58%** | TOO HARD (-2) |
| Prudence Pallor | Elite | 60-75% | 25% | **38%** | TOO HARD (-22) |
| Shiro Swindle | Boss | 40-60% | 92% | **88%** | too easy (+28) |
| Flexing Brute | Normal | 80-100% | 63% | **75%** | TOO HARD (-5), fast |
| Protein Shake Golem | Normal | 80-100% | 63% | **58%** | TOO HARD (-22) |
| Meatloaf Golem | Normal | 80-100% | 71% | **75%** | TOO HARD (-5) |
| Captain Spotless | Elite | 60-75% | 100% | **88%** | too easy (+13) |
| Free Weight Courtyard - Courtyard Lifter | Normal | 80-100% | 50% | **71%** | TOO HARD (-9) |
| Hall of Trophies - Trophy Hall Honor Guard | Elite | 60-75% | 46% | **54%** | TOO HARD (-6) |
| Prep Station - Prep Station Sous-Chef | Normal | 80-100% | 71% | **83%** | ok |
| Prototype Bay - Unfinished War Machine | Elite | 60-75% | 50% | **63%** | ok |
| Weapons Test Range - Cannon-Blender Gunner | Elite | 60-75% | 50% | **71%** | ok |
| The Grand Kitchen - The Doppelganger | Boss | 40-60% | 21% | **29%** | TOO HARD (-11) |
| Overgrown Junkyard - Overgrown Scarecrow | Normal | 80-100% | 63% | **58%** | TOO HARD (-22), fast |
| Thorn Maze - Thorn Maze Stalker | Normal | 80-100% | 54% | **58%** | TOO HARD (-22), fast |
| Hive of Mutant Bees - Hive of Mutant Bees | Elite | 60-75% | 17% | **33%** | TOO HARD (-27), fast |
| Rot Tunnel - Rot Tunnel Horror | Normal | 80-100% | 79% | **75%** | TOO HARD (-5) |
| The Rotheart - Compostella, the Rotheart | Boss | 40-60% | 21% | **63%** | too easy (+3) |
| Royal Stair - Royal Staircase Guard | Elite | 60-75% | 100% | **83%** | too easy (+8) |
| Primm - phase 3 (unraveling) | Boss | 40-60% | 83% | **75%** | too easy (+15) |
| Clocktower Balcony - Clocktower Sentinel | Elite | 60-75% | 100% | **88%** | too easy (+13) |
| The Summit Altar - The Ancient Spotter | Boss | 40-60% | 88% | **92%** | too easy (+32) |
| The Counter Seat - Apprentice Itamae | Normal | 80-100% | 56% | **58%** | TOO HARD (-22) |
| The Conveyor Gauntlet - Conveyor Belt Sushi Chef | Normal | 80-100% | 71% | **75%** | TOO HARD (-5) |
| Betty's Desk - Betty Bones, Surly Secretary | Boss | 40-60% | 79% | **71%** | too easy (+11) |
| The Throne of Lids - His Majesty the Raccoon | Boss | 40-60% | 100% | **67%** | too easy (+7) |
| The Grate Beneath the Plaza - Enforcer Captain Spotless | Boss | 40-60% | 100% | **54%** | ok |
| The Rusty Gate - Rusty Gate Clockwork | Normal | 80-100% | 58% | **63%** | TOO HARD (-18) |
| The Hall of Four Banners - Banner Hall Guardian | Normal | 80-100% | 50% | **75%** | TOO HARD (-5) |
| The Failed Experiments - The Failed Experiment | Elite | 60-75% | 92% | **96%** | too easy (+21) |
| The Draining Chamber - The Drain Warden | Elite | 60-75% | 100% | **92%** | too easy (+17) |
| The Chief Path-ologist's Laboratory - Dr. Ambrose Siphon, Chief Path-ologist | Boss | 40-60% | 71% | **58%** | ok, slow |
| The Calf Raise Crawl - Calf Raise Crusher | Normal | 80-100% | 54% | **67%** | TOO HARD (-13) |
| The Squat Rack Gallery - Squat Rack Squatter | Normal | 80-100% | 58% | **63%** | TOO HARD (-18) |
| The Leg Press Throne - Baron Quadzilla | Boss | 40-60% | 71% | **63%** | too easy (+3) |

Not met: elites and bosses are still mostly too easy late (the gear-equipped late player outclasses most fixed decks; stat rules are the lever that works and are applied to the worst ones), several early fights stay too hard (the Gainlands roamers, Colonel Casserole, Prudence, the Rotheart normals, the Iron Cave and Vault normals: mostly Beefcake or swarm foes that win fast). The rest goes to the Phase 2 Balance cycles; questions in the inbox.

Kept inside the tests' design bounds: Prudence Pallor ends at **12 HP** (not 10; `test_corrupted_npcs` wants 12-30, and 13 and 10 HP both measured 38%), Baron Quadzilla at **16 HP** (not 17; `test_gainlands_v2` keeps the Iron Cave boss an early-game fight; 63% at 17).

## Overnight Oct 18, Phase 2 cycle 1 (Balance): the early walls' one-sided rules

| Encounter | Old -> New | Why | Evidence |
|---|---|---|---|
| Colonel Casserole rule Field Rations | starts with a 3/3 Meatloaf Golem -> a 1/1 Sashimi Weenie | 42% at 12-18 HP alike: the free 3/3 on turn one decided the fight, not HP | g_c1_zone_gourmand_casserole.md: 42% -> **73%** (elite band 60-75), 10 games per Path |
| Prudence Pallor rule Paperwork Ready | starts with 2 Red Tape -> 1 | 38% at 10-13 HP alike | g_c1_town_npc_necrocrat.md: 38% -> **53%** (band 60-75; -7) |

## Overnight Oct 18, Phase 2 cycle 2 (Balance): stat rules for the too-easy late elites and bosses

| Encounter | Rule (one-sided, its units) | Before -> after (6 games per Path) |
|---|---|---|
| Mirror Knight (Castle) | +1/+1 -> +2/+1 | 79% -> **75%** (in band) |
| Royal Staircase Guard (Castle) | +1/+1 -> +2/+1 | 83% -> **54%** (band 60-75, -6) |
| Clocktower Sentinel (Castle) | +2/+1 -> +2/+2 | 88% -> **58%** (-2) |
| The Failed Experiment (Lab) | +2/+1 -> +2/+2 | 96% -> **75%** (in band) |
| The Drain Warden (Lab) | +2/+1 -> +2/+2 | 92% -> **83%** (+8) |
| Betty Bones (Waiting Room) | +1/+0 -> +1/+1 | 71% -> **63%** (+3) |
| Grand Bellows (arena tier 3; HP 38 -> 46 in Part 2) | +1/+0 -> +1/+1 | 88% -> **71%** (+11) |
| Champion of the Four Fists (arena tier 2; HP 28 -> 33 in Part 2) | new +1/+0 | 88% -> 92% (noise; still too easy) |
| Captain Spotless (Capital gate) | +1/+1 -> +2/+1 | 88% -> 88% |
| The Ancient Spotter (Swolympus) | +2/+1 -> +3/+1 | 92% -> 92% |
| Shiro Swindle | new +1/+1 | 88% -> 88% |
| The Old Kingdom Automaton (Vault) | new +1/+0 | 71% -> 71% |
| Notary Wraith (Hall) | +1/+1 -> +2/+1, **reverted** to +1/+1 | 79% -> 46% (overshot) |
| Mortimer Grimsby (Hall boss) | +1/+0 -> +2/+0, **reverted** to +1/+0 | 71% -> 29% (overshot) |

The Spotter, Spotless, Shiro and the Automaton do not move with stat rules: their fights are decided by the player's level-18-24 deck and gear, not by board fights; they need a different lever (an Epic or two, or a start-of-duel effect).

## Overnight Oct 18, Phase 2 cycle 4 (Balance): Epics for the bosses that ignore stat rules

| Encounter | Old -> New | Before -> after (6 games per Path) |
|---|---|---|
| The Ancient Spotter (Mount Swolympus) | extra Barbell of the Ancients -> + Portal-Ripping Titan x2, Swole Patrol Sergeant, The Big Unit | 92% -> **79%** (boss band 40-60, +19) |
| Shiro Swindle | Late Fee x2 -> Lich of Accounts Payable + Mass Layoffs | 88% -> **83%** |
| Captain Spotless (Capital gate) | + a second The Wanderer, Unstable Rift | 88% -> 92% (no change within noise) |
| The Old Kingdom Automaton (Forgotten Vault) | + Unstable Rift, Mirrored Hall | 71% -> 71% |

Kept: all four moved toward the band or not at all, none overshot. These fights stay too easy for the geared late player; what is left is a design call (inbox 4).

## Overnight Oct 18, Phase 2 cycle 6 (Balance): two more head starts

| Encounter | Old -> New | Before -> after (6 games per Path) |
|---|---|---|
| The Doppelganger (Test Kitchen boss), Mise en Place | 2 Ingredients and a 3/3 Meatloaf Golem -> 2 Ingredients and a 1/1 Sashimi Weenie | 29% -> **63%** (boss band 40-60, +3) |
| Trophy Hall Honor Guard (House of Gains elite), Honor Guard | two 1/1 Militia -> one | 54% -> **63%** (in band) |
| Notary Wraith / Mortimer Grimsby after cycle 2's revert (re-measured) | - | **71% / 67%** (in band / +7) |

## Overnight Oct 18, Phase 2 cycle 7 (Balance): the Hollow Warden

Whole tutorial run (HP carried, the Well and the shrine, the 3 picks), 50 runs per Path (`c7_tutorial50.md`): Beefcake 82%, Gourmand 78%, Refusemancer 82%, Necrocrat 76% - each fight alone is 92-100%, the runs are lost mostly at the Warden.

| Encounter | Old -> New | After (`c7_tutorial50_after.md`) |
|---|---|---|
| Hollow Warden deck | 12 + 10 basics, Desperate Measures x1, Curbside Rat x2 -> 14 + 10 basics, no Desperate Measures, Curbside Rat x1 (3 HP unchanged) | runs: Beefcake **92%**, Gourmand **80%**, Refusemancer **82%**, Necrocrat **76%** (the Warden alone vs Necrocrat 80%) |

Necrocrat's control deck takes ~30 turns per run and still loses 7 of 50 at the Warden; a person who attacks sooner should do better, but it stays the Path to watch in playtests (inbox).

## Overnight Oct 18, Phase 2 cycle 9 (Onboarding): Necrocrat's tutorial run

Replays of Necrocrat vs the Hollow Warden (`tools/replay_encounter.gd --id=tutorial:6 --path=necrocrat`): the lost games had hands of Infrastructure and Red Tape Dispensers, and the AI spent its turns activating Dispensers instead of putting bodies down; the second Dispenser came in with Part 2's swap.

| Change | Before -> after |
|---|---|
| Necrocrat starter: Red Tape Dispenser 2 -> 1, + Corpseified Public Accountant (N-05, a 2/3) | tutorial run (50 runs) 76% -> **82%** (`c9_tutorial_n.md`); L1 round robin Necrocrat 44% -> 44% (`c9_decks_l1.md`: vs Beefcake 40, Gourmand 45, Refusemancer 47) |

## Overnight Oct 18, Phase 2 cycle 10 (Balance): full re-measure; the spells-only arena

The whole catalog again after Parts 1-2 and cycles 1-9 (`g_full_after.md`, 6 games per Path), against iteration 1 (`g_iter1.md`):

| Kind | Fights | In band before -> after | Too hard | Too easy | Mean win | Mean turns |
|---|---:|---|---|---|---|---|
| Tutorial | 3 | 3 -> **2** | 0 -> 1 | 0 -> 0 | 96% -> 92% | 5.2 -> 5.3 |
| Normal | 54 | 34 -> **35** | 20 -> 19 | 0 -> 0 | 84% -> 86% | 7.7 -> 7.5 |
| Elite | 21 | 4 -> **9** | 9 -> 7 | 8 -> 5 | 66% -> 64% | 8.7 -> 8.8 |
| Boss | 19 | 3 -> **6** | 3 -> 1 | 13 -> 12 | 69% -> 66% | 8.2 -> 8.3 |


| Encounter | Old -> New | Why | Evidence |
|---|---|---|---|
| Arena tier 2, spells only (Cardboard Colossus) | Colossus 8 -> **6 HP**; the fixed player kit Dropped Weights x6 -> x4, Flex on Em x4 -> x6 | Part C made Dropped Weights unit-only, so the kit's only face damage was 4 x Flex on Em (2 each) = exactly 8: the fight needed every Flex | 17% in 23 turns -> **56%** in 16 turns (12 games per Path, `c10_spells.md`) |

## Overnight Oct 18, Phase 2 cycle 14 (Balance): one more step for the late fights

| Encounter | Stat rule | Why |
|---|---|---|
| arena:arena_four_fists | +1/+0 -> +1/+1 | elite 92% |
| arena:arena_marshal | +1/+1 -> +2/+1 | boss 75% |
| The Old Kingdom Automaton | +1/+0 -> +1/+1 | boss 75% |
| The Ancient Spotter | +3/+1 -> +3/+2 | boss 71% |
| Enforcer Captain Spotless | +2/+2 -> +3/+2 | boss 71% |
| zone:final:spotless | +2/+1 -> +2/+2 | elite 88% |
| town:ninja | +1/+1 -> +2/+1 | boss 88% |

After (6 games per Path, `g_c14_*.md`): Champion of the Four Fists 92 -> **75%**, the Vault Automaton 75 -> **58%**, Spotless in the Tunnels 71 -> **42%**, Spotless at the Capital gate 88 -> **67%**, the Ancient Spotter 71 -> 67%, Grand Bellows 75 -> 79% (noise), Shiro 88 -> 88% (his deck is traps and control: board stats do not decide his fight).

Primm, read as one fight: the three phases are fought in a row; from full HP each they are 100% / 63% / 83% (`g_full_after.md`), roughly 50% for all three - inside the boss band, so phase 1 alone being easy is left as the warm-up.

## Overnight Oct 18, Phase 2 cycle 17 (Balance): the early Iron Cave and Vault normals

| Encounter | Old -> New | Before -> after (6 games per Path) |
|---|---|---|
| Squat Rack Squatter (Iron Cave) | deck beefcake_tools -> beefcake_rush (like the Calf Raise Crusher) | 58% -> **71%** |
| Rusty Gate Clockwork, Banner Hall Guardian (Forgotten Vault) | basics 14 -> 16 | 67% / 71% -> **75%** / 71% |
| Tried and reverted: Regime Checkpoint Captain's Drill Sergeant +1/+0 -> +0/+1 | sturdier units made it harder | 50% -> 42% (reverted to +1/+0) |
| Tried and reverted: Brick Bronson 13 -> 12 HP, Moss Mulligan 15 -> 12 HP | HP does not decide these fights | 54% / 54% unchanged (reverted) |

## Overnight Oct 18, Phase 2 cycle 22 (Balance): mid-game normals, more basics

| Encounter | Change | Why |
|---|---|---|
| S-GOUR node 1 (Apprentice Itamae) basics 15 -> 17 | normal 63% |
| S-GOUR node 2 (Conveyor Belt Sushi Chef) basics 15 -> 17 | normal 71% |
| D-TTK node 8 (Assembly Line Golem) basics default -> 15 | normal 75% |
| D-TTK node 12 (Expediter of the Pass) basics default -> 15 | normal 79% |
| D-HOG node 3 (Courtyard Lifter) basics 15 -> 17 | normal 71% |
| Meatloaf Golem (Buffet roamer) basics 16 -> 18 | normal 75% |

After (6 games per Path, `g_c22_*.md`): Apprentice Itamae 63 -> 71%, Conveyor Belt Sushi Chef 71 -> **88%**, Assembly Line Golem 75 -> **92%**, Expediter of the Pass 79 -> **92%**, Courtyard Lifter 71 -> 75%, Meatloaf Golem 75 -> 75%.

## Overnight Oct 18-19: end of the night (full catalog, `g_final.md` vs iteration 1 `g_iter1.md`, 6 games per Path)

| Kind | Fights | In band before -> after | Too hard | Too easy | Mean win | Mean turns |
|---|---:|---|---|---|---|---|
| Tutorial | 3 | 3 -> **2** | 0 -> 1 | 0 -> 0 | 96% -> 92% | 5.2 -> 5.3 |
| Normal | 54 | 34 -> **38** | 20 -> 16 | 0 -> 0 | 84% -> 87% | 7.7 -> 7.6 |
| Elite | 21 | 4 -> **11** | 9 -> 7 | 8 -> 3 | 66% -> 64% | 8.7 -> 8.5 |
| Boss | 19 | 3 -> **8** | 3 -> 1 | 13 -> 10 | 69% -> 63% | 8.2 -> 8.2 |


The tutorial row is one fight-alone dip at 24 games (92% vs 96%); the 50-run tutorial checks (cycles 7, 9) put whole runs at 80-92% per Path.

Every fight that moved:

|---|---|---|---:|---:|---|
| Heart of the Hollow (Hollow Warden) | Tutorial | 85-100% | 96% | **83%** | TOO HARD (-2), fast |
| Stray Gym Hound | Normal | 80-100% | 75% | **79%** | TOO HARD (-1) |
| Bin Raccoon | Normal | 80-100% | 83% | **88%** | ok, fast |
| Chef Fennel Gravois | Elite | 60-75% | 67% | **58%** | TOO HARD (-2), slow |
| Moss Mulligan | Elite | 60-75% | 58% | **54%** | TOO HARD (-6) |
| Prudence Pallor | Elite | 60-75% | 25% | **42%** | TOO HARD (-18) |
| The Restless Dead | Boss | 40-60% | 42% | **46%** | ok |
| Shiro Swindle | Boss | 40-60% | 92% | **88%** | too easy (+28) |
| The Warden of the Four Seals | Boss | 40-60% | 33% | **38%** | TOO HARD (-3) |
| Flexing Brute | Normal | 80-100% | 63% | **83%** | ok, fast |
| Shambling Middle Manager | Normal | 80-100% | 96% | **92%** | ok |
| Meatloaf Golem | Normal | 80-100% | 71% | **75%** | TOO HARD (-5) |
| Gelatin Sentinel | Normal | 80-100% | 96% | **100%** | ok |
| Colonel Casserole | Elite | 60-75% | 42% | **79%** | too easy (+4) |
| Mossy Trash Golem | Normal | 80-100% | 92% | **96%** | ok |
| Possessed Scarecrow Druid | Normal | 80-100% | 92% | **96%** | ok |
| Rift Wretch | Normal | 80-100% | 92% | **96%** | ok |
| Captain Spotless | Elite | 60-75% | 100% | **67%** | ok, slow |
| Cardio Corridor - Treadmill Sprinter | Normal | 80-100% | 88% | **83%** | ok |
| Free Weight Courtyard - Courtyard Lifter | Normal | 80-100% | 50% | **75%** | TOO HARD (-5) |
| Regime Checkpoint - Regime Checkpoint Captain | Elite | 60-75% | 63% | **50%** | TOO HARD (-10) |
| Prison Block - Cell Block Brawler | Normal | 80-100% | 83% | **79%** | TOO HARD (-1) |
| Hall of Trophies - Trophy Hall Honor Guard | Elite | 60-75% | 46% | **71%** | ok |
| Throne of Gains - Chancellor Clench, Iron Regent | Boss | 40-60% | 63% | **58%** | ok |
| Prep Station - Prep Station Sous-Chef | Normal | 80-100% | 71% | **88%** | ok |
| Walk-In Cooler - Frozen Line Cook | Normal | 80-100% | 92% | **83%** | ok |
| Prototype Bay - Unfinished War Machine | Elite | 60-75% | 50% | **63%** | ok |
| Golem Assembly Line - Assembly Line Golem | Normal | 80-100% | 79% | **92%** | ok |
| Weapons Test Range - Cannon-Blender Gunner | Elite | 60-75% | 50% | **67%** | ok |
| The Head Chef's Pass - Expediter of the Pass | Normal | 80-100% | 79% | **92%** | ok |
| The Grand Kitchen - The Doppelganger | Boss | 40-60% | 21% | **63%** | too easy (+3) |
| Notary Checkpoint - Notary Wraith | Elite | 60-75% | 79% | **71%** | ok |
| Appeals Court - Undersecretary Vellum | Elite | 60-75% | 75% | **79%** | too easy (+4), slow |
| Office of Final Approval - Mortimer Grimsby, CE-No | Boss | 40-60% | 71% | **67%** | too easy (+7) |
| Overgrown Junkyard - Overgrown Scarecrow | Normal | 80-100% | 63% | **54%** | TOO HARD (-26), fast |
| Fungal Hollow - Mutant Mushroom Troop | Normal | 80-100% | 63% | **58%** | TOO HARD (-22), fast |
| Root-Choked Mill - Rootbound Miller | Elite | 60-75% | 75% | **67%** | ok |
| Hive of Mutant Bees - Hive of Mutant Bees | Elite | 60-75% | 17% | **33%** | TOO HARD (-27), fast |
| The Rotheart - Compostella, the Rotheart | Boss | 40-60% | 21% | **58%** | ok, fast |
| Hall of Mirrors - Mirror Knight | Elite | 60-75% | 79% | **67%** | ok |
| Royal Stair - Royal Staircase Guard | Elite | 60-75% | 100% | **63%** | ok |
| Primm - phase 2 (reflection) | Boss | 40-60% | 58% | **63%** | too easy (+3) |
| Beefcake Wing: Coup Orders Barracks - Coup Barracks Sergeant | Normal | 80-100% | 92% | **100%** | ok |
| Refusemancer Wing: the Corrupted Seed Vault - Seed Vault Gardener | Normal | 80-100% | 96% | **100%** | ok |
| Clocktower Balcony - Clocktower Sentinel | Elite | 60-75% | 100% | **67%** | ok |
| Base Camp Bros - Rival Lifter at Base Camp | Normal | 80-100% | 100% | **96%** | ok |
| The Squat Rack Pass - Squat Rack Sentinel | Normal | 80-100% | 92% | **100%** | ok |
| The Summit Altar - The Ancient Spotter | Boss | 40-60% | 88% | **67%** | too easy (+7) |
| The Counter Seat - Apprentice Itamae | Normal | 80-100% | 56% | **71%** | TOO HARD (-9) |
| The Conveyor Gauntlet - Conveyor Belt Sushi Chef | Normal | 80-100% | 71% | **88%** | ok, slow |
| Chef's Choice - The Itamae Supreme | Boss | 40-60% | 54% | **50%** | ok |
| Betty's Desk - Betty Bones, Surly Secretary | Boss | 40-60% | 79% | **63%** | too easy (+3) |
| The Alley Gate - Alley Gate Raccoon | Normal | 80-100% | 96% | **92%** | ok |
| The Throne of Lids - His Majesty the Raccoon | Boss | 40-60% | 100% | **58%** | ok |
| The Grate Beneath the Plaza - Enforcer Captain Spotless | Boss | 40-60% | 100% | **42%** | ok |
| The Rusty Gate - Rusty Gate Clockwork | Normal | 80-100% | 58% | **75%** | TOO HARD (-5) |
| The Hall of Four Banners - Banner Hall Guardian | Normal | 80-100% | 50% | **71%** | TOO HARD (-9) |
| The Vault Core - The Old Kingdom Automaton | Boss | 40-60% | 71% | **58%** | ok |
| The Failed Experiments - The Failed Experiment | Elite | 60-75% | 92% | **75%** | ok |
| The Draining Chamber - The Drain Warden | Elite | 60-75% | 100% | **83%** | too easy (+8) |
| Siphon's Annex - Siphon's Research Assistant | Normal | 80-100% | 96% | **100%** | ok |
| The Chief Path-ologist's Laboratory - Dr. Ambrose Siphon, Chief Path-ologist | Boss | 40-60% | 71% | **58%** | ok, slow |
| The Calf Raise Crawl - Calf Raise Crusher | Normal | 80-100% | 54% | **75%** | TOO HARD (-5) |
| The Squat Rack Gallery - Squat Rack Squatter | Normal | 80-100% | 58% | **71%** | TOO HARD (-9) |
| The Leg Press Throne - Baron Quadzilla | Boss | 40-60% | 71% | **67%** | too easy (+7) |
| Arena tier 1 - Gladiator Rookie | Normal | 80-100% | 79% | **75%** | TOO HARD (-5) |
| Arena tier 1 - Sandbag Sentinel | Normal | 80-100% | 67% | **71%** | TOO HARD (-9) |
| Arena tier 2 - Cardboard Colossus | Elite | 60-75% | 17% | **54%** | TOO HARD (-6), slow |
| Arena tier 2 - Champion of the Four Fists | Elite | 60-75% | 88% | **75%** | ok |
| Arena tier 3 - Announcer Grand Bellows | Boss | 40-60% | 88% | **79%** | too easy (+19) |

## Overnight Oct 18, Phase 2 cycle 25 (Balance): two more normals

| Encounter | Change | Before -> after (6 games per Path) |
|---|---|---|
| Arena tier 1: Gladiator Rookie | basics 16 -> 18 | 75% -> **88%** |
| Apprentice Itamae (S-GOUR node 1) | basics 17 -> 19 | 71% -> **79%** |
| Tried and reverted: Sandbag Sentinel, Banner Hall Guardian basics 16 -> 18 | no change | 71% / 71% |

## Daytime Oct 19, Part 1: your decisions on the Oct 18 inbox

12 games per Path unless noted; before/after at the same seed. Raw reports: `docs/design/sim/d19p1*.md`, `d19b0_*.md`, `d19b1_*.md`.

**Processing Time (Gainlands debuff) softened**: only the first Necrocrat unit each turn enters exhausted (was every Necrocrat unit;
new `Modifier.Kind.FIRST_UNIT_ENTER_EXHAUSTED`, `PlayerState.first_unit_exhaust_done`). The tooltip, the zone panel, the rule badge and
the arrival warning all read `ZoneEffects.mechanic_text`, so they say so now.

| Fight | Beefcake | Necrocrat old -> new | Gourmand | Refusemancer |
|---|---:|---|---:|---:|
| Flexing Brute (zone roamer, L5) | 100% | 25% -> **33%** | 83% | 83% |
| Protein Shake Golem (zone roamer, L5) | 83% | 25% -> **25%** | 58% | 67% |
| Iron Cave: Calf Raise Crusher | 100% | 25% -> 25% | 92% | 67% |
| Iron Cave: Squat Rack Squatter | 92% | 33% -> **42%** | 83% | 67% |
| Iron Cave: Baron Quadzilla (boss) | 83% | 42% -> 42% | 33% | 67% |
| House of Gains: Treadmill Sprinter | 92% | 67% -> **83%** | 75% | 83% |
| House of Gains: Cell Block Brawler | 83% | 58% -> **67%** | 100% | 100% |
| House of Gains: Chancellor Clench (boss) | 100% | 33% -> **42%** | 67% | 50% |
| Other House of Gains fights and S-BEEF | unchanged | | | |

The other Paths did not move (their units are never Necrocrat). The level-5 Necrocrat roamer fights stay low in the sim, and a replay
(`replay_encounter --id=zone:beefcake:golem --path=necrocrat`) shows why: the sim's Necrocrat has the Golem at 1 HP by turn 12 and then
runs out of threats - from turn 19 it draws only Infrastructure and Red Tape (cashed every turn) while the Golem's blockers hold, and the
AI correctly declines attacks its lone units would lose (loop cycle 9 read `AIPlayer._choose_attack`: it scores each attack after the
opponent's best block). The level-5 Necrocrat deck floods late against walls; the debuff is not the cause.

**Late bosses: one-sided boss rules** (icons with tooltips in the pre-battle brief and the battle HUD):

- **Wiring fixes (the main finding)**: Shiro's rules (`town:ninja`) were applied **neither in the game nor in the sim**, which is why his
  stat rules "did not move" him. The arena's rules (`arena:*`: Grand Bellows, the Four Fists) were in the sim only. The gatekeepers'
  rules applied but were never shown. Now the game applies and shows all of them (`Session.make_ninja_battle` / `make_arena_battle` /
  `make_npc_challenge_battle`, `ArenaScenario.build_game`), Shiro's fight and the arena list show a "Before the fight" brief
  (`RulesBrief`), and five rule icons that pointed at missing files were replaced (Shiro, Bellows, the Checkpoint Captain, Clench, the
  War Machine). Test: `tests/core/dungeon/test_boss_rules_wiring.gd`.
- **Shiro Swindle**: no new numbers. With his existing rules (The Oldest Trick: 2 Contracts; Smoke and Mirrors: +2/+1) actually in play:
  **88% -> 48%** (B 58 / N 33 / G 50 / R 50), in the boss band.
- **Grand Bellows**: new rule **Heckling Crowd** (at the start of each of his turns you take 1 damage), on top of Crowd Favourite
  (+2/+1, which the game now applies): **77% -> 56%** (B 75 / N 42 / G 33 / R 75), in band.
- **Primm phase 1**: new rule **Royal Guard** (starts with 2 Militia on the field, 3/3 under Standardization). Phase 1 alone stays at
  **100%** (the hero ends it with 22.7 HP instead of 23.9). Measuring the three phases in a row (one HP pool, as in the game) showed
  last night's "~50%" was an estimate from full-HP phases: before tonight's changes and **without the leaders' boons** the sequence
  cleared only 4-21% per Path (`d19b0_primmseq.md`). The sim now gives the four freed leaders' boons (the game does, and the story frees
  every zone first); the sequence re-run with boons was stopped by a low-memory guard and is still open (inbox).

## Daytime Oct 19, Part 2: Necrocrat and Gourmand tutorial runs

Whole Forgotten Cave runs, 50 per Path (`--what=tutorial --games=25`; `d19p2_base.md` -> `d19p2_final.md`), and the level-1 round robin
(`d19p2_decks_l1.md`, 20 games per pairing). Only the two starting decks changed; the cave's foes did not, so Beefcake and Refusemancer
are untouched.

| Change | Tutorial run before -> after |
|---|---|
| Necrocrat: - Processing Delay, - I've Made a Huge Mistake (it destroys your own unit), + Corpseified Public Accountant (2nd), + Grave Shift Worker (3rd) | **82% -> 92%** |
| Gourmand: - Stock The Pantry (1 of 2), - Sourdough Sentry (1 of 2; a 1/6 that cannot attack), + Sous Chef (3rd), + Soup Kitchen Volunteer (3rd) | **80% -> 90%** |
| Beefcake / Refusemancer | 92% / 82% (unchanged) |

Tried on the way: Gourmand with only the Sous Chef swap 84%; Herb Garden -> Volunteer 82%; Meatloaf Mold -> Conveyor Belt Chef 82%.
Replays (`replay_encounter --id=tutorial:6 --path=gourmand`) showed why the Sentry swap mattered: the cave's foes have 3 HP, and the
lost games were walls that never pushed 3 damage before the Warden's swarm landed.

L1 round robin overall (B / G / R / N): 53 / 58 / 45 / 44 -> **50 / 58 / 47 / 45** (spread 13 -> 13 points). Refusemancer's tutorial run
(82%) is now the lowest.

## Daytime Oct 19, loop cycle 11: Part 2 re-checked on a second seed (correction)

Part 2 measured each starter swap on 50 runs at seed 7000. Re-measured with **100 runs on two seeds** (7000 and 8100):

| Deck | Seed 7000 | Seed 8100 | Verdict |
|---|---:|---:|---|
| Necrocrat, v0.4.0 deck | - | 79% | |
| Necrocrat, Part 2 deck (in the v0.4.1 build) | 81% | 77% | **Part 2's 82 -> 92% did not hold**: no better than before |
| Gourmand, v0.4.0 deck | - | 76% | |
| Gourmand, Part 2 deck (in the v0.4.1 build) | - | 87% | the gain holds (+11) |
| Beefcake / Refusemancer (unchanged) | - | 95% / 87% | |

New Necrocrat trials, judged on both seeds (100 + 100 runs):

| Necrocrat change (from the Part 2 deck) | 7000 | 8100 | Mean |
|---|---:|---:|---:|
| - Requisition Form + Ghoul (3rd); - Red Tape Dispenser + Accountant (3rd) | 82% | 88% | 85% |
| ... and - Audit Wraith + Pink Slip (3rd) - **kept** | 83% | 91% | **87%** |
| ... and - a Body-builder + Waiting Room (3rd) | 83% | 86% | 84.5% (not kept) |

Kept deck: N-01 x3, N-02 x3, N-04 x2, N-05 x3, N-06 x2, N-15 x3, N-07 x3, N-03 x3, N-13 x2, N-23 x2 (+19 Ghost Town). L1 round robin
(B / G / R / N, 20 games per pairing, `d19c11_decks_l1.md`): 52 / 48 / 47 / **53** - the spread narrows from 13 to 6 points. The Path
choice's Necrocrat game plan no longer promises "extra cards" (that was the Requisition Form). This deck is on main, not in the v0.4.1 zip.
Lesson: judge starter swaps on two seeds with 100 runs each; 50 runs on one seed moved by +/-10 points here.

## Daytime Oct 19, loop cycle 12: Part 1's bosses on a second seed

25 games per Path at seed 8100 (`d19c12_*.md`): **Shiro Swindle 60%** (B 60 / N 52 / G 68 / R 60; Part 1 at seed 7000, 12 games: 48%),
**Grand Bellows 60%** (B 68 / N 36 / G 68 / R 68; Part 1: 56%). Both inside the 40-60% boss band on both seeds, at its top on the second.

## Daytime Oct 19, loop cycle 13: the Gainlands roamers (no change kept)

25 games per Path on seeds 7000 / 8100 (`d19c13_*.md`): Flexing Brute 72 / 70%, Protein Shake Golem 63 / 64% (Beefcake 76-92, Necrocrat
44-48, Gourmand 64-84, Refusemancer 60-88). Fewer basics (Brute 14 -> 11, Golem 12 -> 10, fewer Iron bursts) gave 73 / 66% and 62 / 70%:
no real change, reverted. With HP (Oct 18) and deck size (cycle 27) also flat, the roamers need a content change (their bruisers) if
they should be easier.

## Daytime Oct 19, four improvements, Part 1: Red Tape timing

Rule: "Pay 1 energy, use a Red Tape: target unit gets -2/-0 until the start of your next turn." The shrink now expires at the start of
the **user's** next turn (it lasted until the start of the target controller's turn before, so a Red Tape used on your turn never blunted
the enemy's attack - it was only ever a blocker trick). It holds through the opponent's whole turn whoever uses it: an enemy Red Tape on
your unit lasts through your turn and ends when the enemy's next turn starts.

| What | Old | New |
|---|---|---|
| Expiry (`ResourceRules.use`, `GameState.change_stats_until_turn_of`) | the target controller's next ready step | the user's next ready step |
| AI threat estimate (`AIPlayer._threat`) | drops every lingering shrink on foe units | drops only shrinks the foe made itself (`get_attack(card, foe.index)`) |
| AI valuation (`_resource_gain_via_attack`) | attack gain this turn only | attack gain this turn + the threat the shrink takes off the foe's next attack; Red Tape is also sensible in Main 2 on a foe unit that attacks next turn |
| Texts | "until the start of its controller's next turn" | "until the start of your next turn" (resource tooltip, T-14 token, token sheet, Design Guidance snapshot, tutorial prompt, combat_rules.md) |
| Board | - | a debuff badge on the shrunk unit: Red Tape icon, "-2", "2 turns" right after the use / "1 turn" during the other player's turn (`CardView._build_debuff_badge`, `CardInstance.lingering_turns_left`) |

Tests (`tests/core/game/test_resources.gd`): the player's Red Tape stays -2 through the enemy turn and ends at the start of the player's next
turn; the enemy's Red Tape on the player's unit stays -2 through the player's turn and ends at the start of the enemy's next turn; the
threat estimate keeps the AI's own shrinks. Screenshot `_screenshots/oct19d/p1_red_tape_badge.png` (`--tape=0,1 --etape=1`).

Sim check (`d19_redtape_tutorial_necro_7000/8100.md`, `d19_redtape_decks_l1.md`): Necrocrat tutorial clears **89% / 93%** on seeds 7000 / 8100
(100 runs each; the cycle-11 deck measured 83 / 91 before the change), the three fights 96-100%. L1 round robin (20 games per pairing):
B 48 / G 50 / R 45 / **N 57** (was 52 / 48 / 47 / 53). The stronger Red Tape lifts the Necrocrat deck a few points on both checks, still
inside the noise band of these sample sizes; no deck change made.

## Overnight Oct 19 - The Wellspring's Echo (secret Old Well quest, Part 6)

New encounter `town:old_well` (sim group `secret:old_well`, Boss, intended level 16, target 40-60%). One rule, "The Spring Remembers" (one badge):
heal 2 at the start of its turns, one Iron / Red Tape / Ingredient / Garbage at the start, and a stat entry for its units.

| Version | Games/Path | Seed | Beefcake | Necrocrat | Gourmand | Refusemancer | All |
|---|---:|---|---:|---:|---:|---:|---:|
| no stat entry | 8 | default | 100% | 100% | 88% | 100% | 97% |
| +1/+1 | 8 | default | 88% | 100% | 75% | 63% | 81% |
| +2/+1 | 8 | default | 75% | 88% | 25% | 75% | 66% |
| **+2/+2 (kept)** | 25 | default | 48% | 60% | 44% | 56% | **52%** |
| **+2/+2 (kept)** | 25 | 8100 | 48% | 88% | 36% | 72% | **61%** |

Kept +2/+2 (two-seed mean ~56%: hard but fair). Gourmand is the weakest Path against it (36-44%), Necrocrat the strongest. Reports in
`docs/design/sim/old_well_oct19*.md`.

## Overnight Oct 19 - Primm's three phases WITH the four leaders' boons (measured, no change)

`--what=sequence --filter=boss:primm --games=6` (12 runs per Path, one HP pool, seed 7000; `docs/design/sim/primm_sequence_oct19n.md`):
Beefcake 50%, Gourmand 58%, Refusemancer 42%, Necrocrat 83% (mean ~58%). Without boons it was 4-21% (Daytime Oct 19), so the boons carry
the finale as designed. Most runs are lost in phase 2 (reflection). No change: in band for a final boss; Necrocrat is the easiest Path.

## Overnight Oct 19 - the cave run on a third seed (measured, no change)

`--what=tutorial --games=50 --seed=9200` (100 runs per Path, `docs/design/sim/oct19n_tutorial_9200.md`): Beefcake 92%, Gourmand 84%,
Refusemancer 84%, Necrocrat 90% (seeds 7000/8100 gave ~95 / ~87 / ~87 / ~87). Three seeds agree: Gourmand and Refusemancer sit at the
bottom edge of the 85-100% target (most losses at the Mossy Gallery and the Warden); no change tonight.

## Overnight Oct 19 - Gainlands roamers at level 5 (measured, no change)

12 games per Path (`docs/design/sim/oct19n_gainlands_roamers.md`): Flexing Brute 69% (B 100 / N 33 / G 58 / R 83), Protein Shake Golem 65%
(B 83 / N 50 / G 58 / R 67), target 80-100%. The number levers are spent (Daytime cycle 13); the next step is deck content (replays) or
a design call on the Beefcake/Necrocrat rivalry (Necrocrat players are warned on arrival and pointed to the D.N.A.). Left for the user.

## Oct 20 - the store room ghosts (`town:storeroom`, the early-game chain's first scripted fight)

Target ~90% for every Path's level-3 reference deck, 5-8 turns. Rule "Haunted Inventory": a 1/1 Ghost token joins the ghosts at the start of
each of their turns. 50 games per Path per seed (`--filter=town:storeroom`).

| Try | Ghosts | Token | Result |
|---|---|---|---|
| v1 | `necro_zombies` 20/10, 6 HP, Defensive | Hungry Ghost (Flying) | 0% (3 games): a fresh chump blocker every turn, Red Tape from the deck and its infrastructure, 7.1 turns |
| v2 | 20/13, 4 HP, Aggressive (tutorial) | Hungry Ghost (Flying) | 17%: an unblockable 1/1 every turn snowballs past a level-3 hero's 11 HP |
| v3 | as v2 | **Ghost: the Hungry Ghost without Flying** (`token_name`, `token_keywords`) | 25%: the zombie deck floods the board |
| v4 | 13 Hall of Records + 4 Cannon Fodder + 3 Skeleton Clerk, 4 HP | Ghost | 74% / 70% (seeds 7000 / 8100), 6.2 turns |
| v5 | 14 Hall of Records + 6 Cannon Fodder, 3 HP | Ghost | 80% / 74% |
| **v6 (kept)** | **18 Hall of Records + 2 Cannon Fodder, 3 HP, Aggressive (tutorial)** | Ghost | **93% / 94%**: Beefcake 96/98, Necrocrat 98/90, Gourmand 94/94, Refusemancer 84/92; **6.0 turns** (`docs/design/sim/storeroom_v6_*.md`) |

## Oct 21 - Part 1: Primm's lieutenants and the Paste Works (story-content brief)

New fights, 25 games per Path on two seeds (7000 / 8100), reports `docs/design/sim/oct21_*.md`. Each lieutenant has one-sided rules in
`data/encounters/modifiers.json` (keyed by the battle name), each fight's node is in `data/dungeons/dungeon_content.json`.

| Fight | Where (L) | Target | Change | Seed 7000 (B/N/G/R, all) | Seed 8100 |
|---|---|---|---|---|---|
| Vivienne Quota | D-HOG node 6, elite (L8) | 60-75 | replaces the Regime Checkpoint Captain: same deck (beefcake_bruisers 29 cards, 16 HP, 13 basics), rule "Stopwatch" = the old "Drill Sergeant" (+1 attack) | 88/68/44/80, **70%** | 88/80/64/84, **79%** |
| Hortensia Clipwell | D-ROT node 6, elite (L18) | 60-75 | replaces the Rootbound Miller: same deck (refuse_garbage 32, 19 HP), rule "Prize Topiary" = the old "Fungal Growth" (tokens +1/+1) | 48/84/64/96, **73%** | 28/88/76/92, **71%** |
| Percival Plume | D-PC node 14, elite (L21; was a deck challenge) | 60-75 | necro_control 32/23 HP: 100% (10 turns); + "Positive Spin" +2/+1: 94%; necrocrat_beefcake 33/24 HP Aggressive + spin +2/+1: 28%; spin +1/+1: 50%; no spin: 81%; **kept: spin +1/+0 + "Great News!" (extra draw)** | 72/44/68/68, **63%** | 80/56/56/68, **65%** |
| Ration Line Supervisor | S-PASTE 1 (L19) | 80+ | colorless_regime 30 cards / 18 HP, mixed Gourmand + Necrocrat | 100% (12 games) | - |
| Vat Floor Golem | S-PASTE 2 (L19) | 80+ | gourmand_golems 31 / 20 HP | 100% (12 games) | - |
| Colonel Crumb | S-PASTE 3, boss (L21) | 40-60 | gourmand_golems + C-30, G-29, 28 HP, Aggressive, "Whisk Formation" (a 3/3 Meatloaf Golem every 3rd turn): 94%; + "Fortified Rations" +2/+1: 46%; +1/+1: 69%; +2/+0: 79%; **kept +1/+2** | 52/40/76/52, **55%** | 48/32/80/60, **55%** |
| Quota's rematch | Capital, Transit Yards (L19) | 60-75 | beefcake_tools 30 + B-12x2, B-28, C-30; 26 HP; "Stopwatch" + "Time and Motion" (Hustle): +1/+0 90%; +2/+1 55%; **kept +1/+1** | 68/64/60/64, **64%** | 60/68/60/72, **65%** |

Notes: Gourmand is strongest in the Paste Works by design (the dungeon rule Real Food: the player's Gourmand cards cost 1 less). Clipwell
is hard for Beefcake (28-48%) as the Miller was; overall in band, no change. Bland Diet (healing does nothing) is `HP_GAIN_BONUS -99`.

## Oct 21 - Part 2: the sheet's 16-node Path-ology Lab, Siphon's Protocols, Elowen (T-24)

Dungeon rule Specimen Conditions (your max life -5; enemy units +1/+1). Siphon (L28): four_paths + the four leader cards, 44 HP (was a
necro_control deck, 58 HP, +1/+1 and an extra draw). His Protocols (`modifiers.json`, `ProtocolJam`), tuned on 6-15 games per Path:

| Try | Augmentation | Replication (T-25) | Extraction | Containment | Alone | With Elowen |
|---|---|---|---|---|---|---|
| sheet as written | +2/+2 | every turn | 1 life + 4 Resources | first card +2 | 0% (3 turns) | 13% |
| 2 | +1/+1 | every 2nd turn | as sheet | +2 | 0% | 33% |
| 3 | +1/+1 | every 2nd | as sheet | +1 | 0% | 71% (6 games) |
| 4: deck without C-30/C-31, 44 HP | +1/+1 | every 2nd | as sheet | +1 | 0% | 46% (6 games) |
| 5: Extraction = 1 life drained (you -1, he +1), no Resources | +1/+1 | every 2nd | drain | +1 | 6% | 63% |
| 6 | +1/+1 | every 3rd | drain | +1 | 13% | 78% |
| 7 | +1/+1 | every 2nd | drain | +1 | 5% | 68% (15 games) |
| **kept** | **+2/+1** | **every 2nd** | **drain** | **+1** | **2% / 2%** | **60% / 68%** (15 games per Path, seeds 7000 / 8100) |

The sim plays the solo fight in ~5 turns: the reference deck (L28, 24 life after Specimen Conditions) plays its first unit on its 4th turn.
Elowen's 3/5 Elusive, Unbreakable body and one jammed Protocol a turn are worth about 60 points, as the sheet intends ("she doesn't win it
for you, she gives you a chance"). The other Lab fights (8 games per Path, seed 7000): Decontamination Technician 100%, Escaped Specimen
97%, The Failed Experiment (elite) 63%, Hybrid Specimen 97%, Siphon's Research Assistant 94%, The Drain Warden (elite) 56%, Antechamber
Sentry 91%.

## Oct 21 - Part 4: the level-5 Necrocrat in the Gainlands, and the Old Well's Echo for Gourmand

**Gainlands roamers at L5** (25 games per Path, seeds 7000 / 8100; `docs/design/sim/oct21_gain_*.md`). Replays: the L5 Necrocrat deck played
no unit for four turns (it kept every 4-cost body and cut a 1-drop), then could not attack into the Golem's tool-buffed blockers and lost
late to Iron; against the Brute it lost the race. Tried and measured (Necrocrat, seed 7000):

| Change | Brute N | Golem N | Note |
|---|---:|---:|---|
| before | 40 / 44 | 40 / 60 | all Paths: Brute 71 / 69, Golem 62 / 67 |
| cut order keeps the 1-2 drops (sim) | 44 | 40 | the curve is fixed (units from its 2nd-3rd turn), the rate is not |
| + two Audit Wraiths in the L5 package (sim) | 40 | 48 | reverted |
| roamers 7 -> 5 HP | 60 | 64 | |
| + Brute 11 basics, Golem 10 | 64 | 64 | |
| Processing Time switched off (measure only) | 80 | 64 | the debuff costs ~15 points vs the Brute; the Golem walls every Path (~65%) |
| N-07 / N-23 cost 4 -> 3 (measure only, reverted) | 68 | 60 | noise |
| **Processing Time only for Necrocrat units costing 3+** | 68 | 64 | kept: "cheap paperwork is processed on the spot" |
| **L3 package: 2 Village Militia + 2 Watchtower Archers (General Pack 2-drops) for Processing Delay / Buried in Paperwork (sim)** | 76 | 56 | kept |
| **Golem without Kettlebell / Yeet / Pre-Workout, 9 basics** (Balanced AI tried and dropped) | - | 60-66 | kept; every Path still ~65% |
| **Golem: Aggressive AI** (it trades instead of walling) | - | 64 (all 73) | kept |
| **Golem 3 HP, Brute 4 HP** | **84 / 72** | **84 / 84** | kept |

After (all Paths, B/N/G/R): Flexing Brute 88/84/80/84 (84%) and 92/72/84/72 (80%); Protein Shake Golem 88/84/80/72 (81%) and
92/84/76/72 (81%). L5 Necrocrat mean 81%; every Path rose (Beefcake, Gourmand and Refusemancer were 60-88 before). The fights are short
(5 turns, "fast"): first-zone roamers. Necrocrat's town fights at L3 (the package change) measured before/after: unchanged within noise
(`oct21_town_necro*.md`). The tutorial does not use the reference packages (45-card starter, no cuts).

**The Old Well's Echo at L16** (25 per Path, seeds 7000 / 8100; `oct21_echo_*.md`). Before: 48/64/44/56 (53%) and the Oct 19 seed-8100
48/88/36/72. Tried: heal 1 instead of 2 (Gourmand 44, unchanged); player tokens +1/+1 (44); "whenever you gain HP, gain 1 / 2 more"
(52, then 36-40 on seed 8100, and every Path rose); Gourmand cards cost 1 less (84 / 80, too easy); Gourmand units +1 attack (72 / 68).
**Kept: a second, player-side rule "First, Water: your Gourmand units get +0/+1"** (the blue stream fed the Gourmands' first stockpot).
After: 48/64/44/56 (53%) and 48/56/56/72 (58%): Gourmand 44 / 56, mean 50; the rule touches no other Path.

## Oct 22 - UI + economy fixes, Part 4: starting decks with about 15 Colorless Commons

- `CampaignStart.STARTING_DECKS`: every Path keeps 45 cards / 19 Infrastructure; 26 others = 11-12 Path cards (the Resource makers and
  spenders, at most two Uncommon copies) + 14-15 Colorless Commons. Lists and reasons in `docs/design/starting_decks.md`.
- Tuning steps (tutorial, two seeds x 50): first lists B 91/92, N 92/95, G 75/80, R 87/91. Gourmand: Healing Potion x2 -> Village
  Militia +1 / Soup Kitchen Volunteer +1 (81/82); roamers still ~72 -> Herb Garden x2 -> Soup Kitchen Volunteer +2, Tavern Regular x2 ->
  Courier Pigeon x2 (tutorial 89/88). Necrocrat: Desperate Measures x2 -> Village Militia x2 (round robin L1 45 -> 42 within noise,
  roamers 82-94). Tried and reverted: Gourmand Brawlers/Medics (worse, 60-76), Beefcake Shield Bearers for Rally (stronger, 65% L1).
- `TownEnemies` (Crosspath outskirts, level 1): Stray Gym Hound hp 4 -> 3, Lost Junior Clerk hp 5 -> 4, Bin Raccoon hp 4 -> 3 and
  deck 20/12 -> 20/13 basics. Old decks on the same seeds: B ~90, N ~90, G ~83, R ~80; new decks after the change: B 86-96, N 82-94,
  G 76-86, R 72-96 (Refusemancer vs the Raccoon mirror 72/78, as the old deck's 76/80). Tried first: more basics for all three
  (13->14, 10->12, 12->13) at the old HP - no clear effect, reverted.
- `ProgressionModel.CUT_ORDER`: each Path cuts its Colorless filler first as upgrades arrive (the level-5 reference decks had been
  cutting Path cards and keeping filler).
- Store Room Ghosts (L3): 94-100% for every Path. Round robin L1: B 58 / G 51 / R 50 / N 42 (was 66 / 50 / 44 / 40); L5: B 67 / G 48 /
  R 46 / N 40. Reports: `docs/design/sim/oct22_final_*.md`, `oct22_n_*`, `oct22_b_*`, `oct22_g_*`.

## Overnight Oct 22 - Part 1: whole-game re-measure under the Oct 22 shops

**Model.** `ProgressionModel.UPGRADES` rewritten so every reference deck holds only cards a player can own at that level under the
Oct 22 shops (`docs/design/vendors.md`, `docs/design/progression_model.md`; audit `tools/reference_deck_audit.gd`: 82/82 package cards
ownable - the old packages had 40 cards that were not yet on sale, e.g. Necrocrat's and Refusemancer's Epics at 10-14). In effect
Beefcake is stronger from 8 (The Big Unit, its shelf Epic), the other Paths weaker until their own zone is freed.

**Re-measure** (whole catalog, 6 games per Path, seed 7000, `docs/design/sim/oct22n/m1_*.md`; summary `node tools/sim_summary.js`):

| Kind | Fights | In band | Too hard | Too easy | Mean win | Mean turns |
|---|---:|---:|---:|---:|---:|---:|
| Tutorial (50 runs per Path, two seeds) | 3 | 3 | 0 | 0 | 95-100% per fight; whole run B 91/92, G 89/88, R 87/91, N 94/93 | 5.0 |
| Normal | 58 | 48 | 10 | 0 | 90% | 7.3 |
| Elite | 22 | 11 | 5 | 6 | 67% | 8.3 |
| Boss | 22 | 10 | 2 | 10 | 59% | 8.0 |

(Oct 18's end of night for comparison, old model: Normal 38/54, Elite 11/21, Boss 8/19 in band.) Primm's three phases read "too easy"
alone (96/88/79%) but are judged as the one-HP-pool sequence (~58% on Oct 19), unchanged here. Siphon alone is 0% by design; with
Elowen (D-LAB:16:elowen) 58%.

**The biggest outliers, confirmed at 16 games per Path on seeds 7000 and 8100, then fixed (encounter side only, no card changes):**

| Encounter | Target | Before (7000 / 8100) | Change | After (7000 / 8100) |
|---|---|---|---|---|
| Prudence Pallor (town gatekeeper, L3) | 60-75% | 47% / 39% | `necro_zombies` basics 16 -> 20, the "Paperwork Ready" Red Tape head start removed (HP stays 12: tests bound it 12-30) | **56% / 56%** |
| Moss Mulligan (town gatekeeper, L3) | 60-75% | 50% / 56% | `refuse_garbage` basics 17 -> 19 | **55% / 59%** |
| Baron Quadzilla (Iron Cave boss, L8) | 40-60% | 78% / 84% | new rule "Max Pump": his units +1/+1 | **45% / 52%** |
| The Drain Warden (Lab elite, L27) | 60-75% | 45% / 59% | "Drained Strength" +2/+2 -> +1/+1 | **69% / 72%** |
| Calf Raise Crusher (Iron Cave, L6) | 80-100% | 73% / 67% | basics 14 -> 16, HP 8 -> 6 | **69% / 80%** |
| Squat Rack Squatter (Iron Cave, L6) | 80-100% | 78% / 69% | basics 14 -> 16 | **77% / 75%** |

Tried and dropped: a smaller deck `size` for Moss (27 -> 25) and the Crusher (24 -> 22) - identical numbers, the trim never applies to
those recipes. Left for a later pass (6-game noise or Path-specific): Beefcake in the Verdant Dump at L17 (Overgrown Scarecrow / Thorn
Maze 17% on 6 games, every other Path 83-100%), Captain Spotless 50%, Colonel Casserole 79%, the Doppelganger 67%, Clipwell 83%, the
Clocktower Sentinel 83%, Mount Swolympus's Ancient Spotter 67%. Reports: `docs/design/sim/oct22n/{c0,i1,i2,i3,tut}_*.md`.

## Overnight Oct 22, Phase 2 cycle 2 (Balance): Beefcake in the Rotheart (measured, no change)

Overgrown Scarecrow (D-ROT node 2, L17) for Beefcake alone, 16 games: **63% / 44%** on seeds 7000 / 8100 (other Paths 83-100% in the
sweep). Replay (`tools/replay_encounter.gd --id=D-ROT:2 --path=beefcake --show=1`): the L17 Beefcake deck's cheap units are x/1
(Hamster Wheel Runner, Gym Bro...), and the Rotheart's "Rot" rule kills 1-defense units at the end of each turn, so the board never
builds while Overgrowth grows the foe's. The Dump's zone effects have no Beefcake debuff. This is the Oct 18 inbox item 3 (Rot one-sided?)
that was answered "no change for now", so nothing was changed; it is back in the inbox with the Beefcake numbers.

## Overnight Oct 22, Phase 2 cycle 4 (Balance): the rest of the sweep's outliers on two seeds (measured, no change)

16 games per Path, seeds 7000 / 8100 (`docs/design/sim/oct22n/c4_*.md`). Not changed tonight because v0.4.5 is already built; proposals
for the next pass (levers that worked before: one-sided stat rules for late bosses, basics for normals and early elites):

| Encounter | Target | 7000 / 8100 | Proposal |
|---|---|---|---|
| The Doppelganger (D-TTK boss, L16) | 40-60% | **69% / 75%** | +1/+1 stat rule for its units (one step) |
| Colonel Casserole (Buffet elite, L12) | 60-75% | **81% / 81%** | 2 fewer basics or a +1/+0 rule |
| Captain Spotless (Capital elite, L18) | 60-75% | **55% / 52%** | soften his stat rule by one step |
| Clipwell (D-ROT elite) | 60-75% | 80% / 70% | within noise; Beefcake 31-56% (Rot again, inbox 7) |
| Clocktower Sentinel (D-PC elite) | 60-75% | 66% / 81% | within noise |
| The Ancient Spotter (S-BEEF boss, postgame) | 40-60% | 63% / 59% | within noise |

## Oct 23 - Battle AI upgrade, Part 5: the catalog under the new AI, and the first tuning pass

**What changed in the measurement.** Both seats now run the planning AI (`docs/design/ai_state.md`): the enemy at the skill its kind
calls for (Normal with 15% human mistakes / Elite / Boss with a signature), the player seat as a "decent human" (Elite, no mistakes).
The whole catalog was re-measured at 4 games per Path, seed 7000 (`docs/design/sim/ai_p5/*.md`, `bash tools/ai_sweep.sh ai_p5 4 7000`),
the tutorial at 25 games per fight and 50 runs per Path (`ai_p5/tutorial_7000.md`).

| Kind | Fights | In band | Too hard | Too easy | Mean win | Mean turns | Oct 22 (old AI, 6 games) |
|---|---:|---:|---:|---:|---:|---:|---|
| Tutorial fights | 3 | 3 | 0 | 0 | 98-99% | 5.1 | 95-100% |
| Tutorial runs | 4 Paths | - | - | - | B 88 / G 90 / R 88 / N 98 | 28 | B 91 / G 89 / R 87 / N 94 |
| Normal | 56 | 46 | 10 | 0 | 89% | 7.3 | 48 / 10 / 0, 90% |
| Elite | 23 | 10 | 8 | 5 | 66% | 8.7 | 11 / 5 / 6, 67% |
| Boss | 21 | 6 | 5 | 10 | 55% | 8.4 | 10 / 2 / 10, 59% |

The averages barely moved; the spread did. Decks with an engine (Prudence's Red Tape, Moss's Garbage, Gourmand golem makers) got
stronger because the new AI uses the engine every turn; vanilla decks did not. Opening-hour fights (16 games each): Stray Gym Hound
63% (Gourmand 25), the gatekeepers Brick 56 / Chef 56 / Moss 38 / Prudence 44, the Restless Dead 19% - all over the line. Walls
(under 35%): the Restless Dead 19, the Grate's Captain Spotless boss 31 (and Siphon alone 0 by design). Too-easy bosses (69%+):
Betty, Mortimer, the Doppelganger, Compostella, Primm's phases 1 / 3 (100 / 81), elites Mirror Knight 94, Clipwell 94, Casserole 88.

**Also found in the replays (AI side, fixed in the same pass):** the Refusemancer seat hoarded Garbage (a Possum Prowler sat for 13
turns on 7 Garbage) because held fuel was valued at 1.5 each - more than one use gains. Fuel now 0.8 held / 0.25 idle
(`AIEvaluator.FUEL_VALUE`), the Gourmand / Refusemancer profile bonus 0.25.

**Changes (encounter side only):**

| Encounter | Target | Before | Change |
|---|---|---|---|
| Brick, Chef, Moss, Prudence (town gatekeepers, L3) | 60-75% | 56 / 56 / 38 / 44 | played at Normal skill with mistakes (`AIPlayer.SKILL_OVERRIDES`): the first hour stays forgiving; the kind (Elite rewards, band) is unchanged |
| The Restless Dead (first boss, L7) | 40-60% | 19 | Elite skill instead of Boss (keeps the "patience" signature and the escalating summons) |
| Stray Gym Hound (outskirts, L1) | 80-100% | 63 (G 25) | its 20-card deck loses the Pastry Artificer and Plate It (`TownEnemies`): a level-1 roamer no longer cooks 4/4 golems |
| Enforcer Captain Spotless (S-CAP boss) | 40-60% | 31 | Spotless Drill +3/+2 -> +2/+2 |
| Captain Spotless (Capital roamer, elite) | 60-75% | 50 | Spotless Drill +2/+2 -> +2/+1 |
| Mortimer Grimsby (D-HFA boss) | 40-60% | 69 | Temp Agency +1/+0 -> +1/+1 |
| Betty Bones (S-NECRO boss) | 40-60% | 69 | Surly +1/+1 -> +2/+1 |
| The Doppelganger (D-TTK boss) | 40-60% | 69 | new rule Perfect Copy: its units +1/+1 (the Oct 22 proposal) |
| Compostella (D-ROT boss) | 40-60% | 69 | Rot Takes Root +0/+1 -> +1/+1 |
| Primm phase 1 / phase 3 | sequence ~50% | 100 / 81 | new rules Royal Standard / Last Decree: his units +1/+1 in those phases |
| Mirror Knight (D-PC elite) | 60-75% | 94 | Polished +2/+1 -> +3/+2 |
| Clipwell (D-ROT elite) | 60-75% | 94 | Prize Topiary tokens +1/+1 -> +2/+2 |
| Colonel Casserole (Buffet elite) | 60-75% | 88 | new rule: her units +1 attack (Field Rations) |

After (6 games per Path for the town on seeds 7000 / 8100, 8 per Path for the rest, seed 7000): see the table below.

**After** (seeds 7000 / 8100; the town at 6 games per Path, the rest 8; `docs/design/sim/p5b..p5j/`):

| Encounter | Target | Before | After | Note |
|---|---|---|---|---|
| Stray Gym Hound | 80-100% | 63 | **100 / 100** | no golem maker, no Plate It |
| Lost Junior Clerk / Bin Raccoon / Store Room Ghosts | 80-100% | 88 / 94 / 100 | 92-92 / 96-83 / 92-100 | unchanged, re-measured |
| Brick Bronson | 60-75% | 56 | **71 / 75** | Normal skill |
| Chef Fennel Gravois | 60-75% | 56 | **63 / 63** | Normal skill |
| Prudence Pallor | 60-75% | 44 | **75 / 54** | Normal skill |
| Moss Mulligan | 60-75% | 38 | 46 / 54 at Normal skill and 13 HP; 47 / 56 at 13 HP; **63 / 66** at 12 HP with a 28-card / 20-basics deck | three steps |
| The Restless Dead | 40-60% | 19 | 29 / 42 at Elite skill; **38 / 44** at Normal skill | the escalating summons stay the challenge |
| Shiro Swindle / Warden / Echo | 40-60% | 50 / 38 / 63 | 58-67 / 42-46 / 58-75 | unchanged, re-measured |
| Mortimer Grimsby | 40-60% | 69 | **47** | +1/+1 |
| The Doppelganger | 40-60% | 69 | **38** | +1/+1 (one step; the next read decides whether it stays) |
| Compostella | 40-60% | 69 | 69 | +1/+1 did not move it (Beefcake 25, the others 75-100: the Rot question, inbox 7) |
| Mirror Knight | 60-75% | 94 | 50 at +3/+2, **72** at +3/+1 | |
| Clipwell | 60-75% | 94 | 84 with tokens +2/+2; **72** with tokens +1/+1 and units +1/+1 | |
| Colonel Casserole | 60-75% | 88 | **78** | +1 attack |
| Captain Spotless (roamer) | 60-75% | 50 | **64** | +2/+1 |
| Enforcer Captain Spotless (S-CAP boss) | 40-60% | 31 | 69 at +2/+2; 91 / 81 at +3/+1; 69 / 81 at +2/+2 and 38 HP (HP does not move it) | see the last row below |
| Primm, three phases as one HP pool | ~50% | ~58% (Oct 19, old AI) | 0-6% cleared with +1/+1 in phases 1 and 3; 6-25% with phase 3 only; measured again without either (below) | the new AI makes the gauntlet itself harder - no rule step survives |
| Enforcer Captain Spotless (S-CAP boss), final | 40-60% | 31 | **47 / 72** | +3/+2 kept, his deck 11 -> 13 basics, 34 HP |
| Primm, three phases as one HP pool, without any rule step | ~50% | ~58% (old AI) | B 33 / G 17 / R 42 / N 58 = 38% at Boss skill (12 runs per Path) | next step: the phases at Elite skill (`AIPlayer.SKILL_OVERRIDES`), measured below |
| Primm, three phases as one HP pool, phases at Elite skill (kept) | ~50% | ~58% (old AI) | **B 50 / G 25 / R 50 / N 67 = 48%** (12 runs per Path, seed 7000) | Gourmand lags (inbox: its L22 reference deck against Standardization) |

**Kept, summary.** Skill: the four gatekeepers and the Restless Dead at Normal, Primm's phases at Elite (`AIPlayer.SKILL_OVERRIDES`).
Decks/HP: the hound without G-08 / G-20; Moss 12 HP, 28 cards / 20 basics; Spotless boss 13 basics. Rules: Mortimer +1/+1, Betty +2/+1,
Doppelganger +1/+1 (new), Compostella +1/+1, Mirror Knight +3/+1, Clipwell units +1/+1 (new) with tokens +1/+1, Casserole +1 attack
(new), Spotless roamer +2/+1, Spotless boss +3/+2 (unchanged number, diluted deck). Reverted: Primm's Royal Standard and Last Decree.
No card changes, so `docs/design/sheet_changes.md` is unchanged. Not touched (noise-level at 16-32 games, or a known question):
Betty's own read after +2/+1 (not re-measured alone - it is S-NECRO:3, 69% before), Compostella 69 (Rot and Beefcake, inbox 7),
Test Kitchen normals 63-75 (Refusemancer 25 before the fuel fix; re-measure in the next sweep), D-PC:20 81.

## Overnight Oct 23, Part 1: scripted boss and elite events (and Part 2's two-Path foes), measured on two seeds

Every boss, lieutenant, gatekeeper, arena champion and elite got 1-3 scripted mid-fight events (`data/encounters/encounter_scripts.json`,
table in `docs/design/encounter_scripts.md`). Measured with the new AI, 4 games per Path per seed (16 per cell), `SWEEP_KINDS=elite,boss
bash tools/ai_sweep.sh`. "Before" = the Oct 23 Battle AI Part 5 numbers (seed 7000, after its tuning pass where it re-measured).
The first versions overshot (Itamae 25, Hive 38, Bellows 19, Betty 38, Moss/Prudence 50, Restless Dead 31, Four Seals 25, Quota 38,
Mortimer 19-38); those triggers were turned into milder events or "mercy" moments (the foe's real self slipping through) before the
final reads below. No card changes, no HP changes, no rule-number changes: only the new scripts (and Part 2's decks).

| Fight | Target | Before | Seed 7000 | Seed 8100 | Notes |
|---|---|---:|---:|---:|---|
| Brick Bronson (L3) | 60-75 | 73 | 63 | 63 | Hydration Break (heals 3, stands down) |
| Chef Fennel Gravois (L3) | 60-75 | 62 | 63 | 69 | TASTE IT! (you heal 2, a Snack joins) |
| Moss Mulligan (L3) | 60-75 | 63 | (50 first version) | 69 | Did I Thorn at You? (you heal 3) |
| Prudence Pallor (L3) | 60-75 | 65 | (50 first version) | 63 | Stamped APPROVED (you heal 3) |
| The Restless Dead (L7) | 40-60 | 38-44 | (31 first version) | 50 | The Count Pauses + The Cairn Remembers (both ease it) |
| Shiro Swindle (L12) | 40-60 | 50 | 56 | 63 | SMOKE BOMB!!! + Body Double |
| The Warden of the Four Seals (L24) | 40-60 | 38 | (25 first version) | 44 | shield 3 at 50%, -1/-0 at 25% |
| The Wellspring's Echo (L16) | 40-60 | 63 | 50 | 56 | Ripples + Still Water |
| Quota, Regime Checkpoint (L8) | 60-75 | 75 | 69 | 63 | |
| Trophy Hall Honor Guard (L8) | 60-75 | 69 | 69 | 63 | |
| Chancellor Clench (L9) | 40-60 | 56 | 56 | 69 | Brownout (turn 5, warned), 2 Iron, Master...? |
| Baron Quadzilla (L8) | 40-60 | 63 | 56 | 63 | |
| The Old Kingdom Automaton (L8) | 40-60 | 50 | 50 | 81 | |
| Notary Wraith (L12) | 60-75 | 56 | 63 | 69 | |
| Undersecretary Vellum (L12) | 60-75 | 63 | 63 | 75 | |
| Mortimer Grimsby (L13) | 40-60 | 47 | 44 | 25 | scripts removed on seed 8100: 19 (the seed is hard for him; the scripts are neutral or easing) |
| Betty Bones (L13) | 40-60 | 69 | 44 | 44 | Out to Lunch now stands her units down |
| Colonel Casserole (L12) | 60-75 | 78-88 | 69 | 75 | Honour Duel (+1/+1) |
| Unfinished War Machine (L15) | 60-75 | 63 | 69 | 38 | |
| Cannon-Blender Gunner (L15, now Gourmand+Beefcake) | 60-75 | 69 | 69 | 69 | Part 2 deck |
| The Doppelganger (L16) | 40-60 | 38 | 44 | 38 | The Mask Slips ends Perfect Copy |
| The Itamae Supreme (L16) | 40-60 | 44 | 44 | 31 | scripts removed on seed 8100: 31 (same) |
| Hortensia Clipwell (L18) | 60-75 | 72 | 75 | 56 | |
| Hive of Mutant Bees (L18, now Gourmand+Refusemancer) | 60-75 | 69 | 81 | 75 | Part 2 deck, two flying bees after 2 deaths |
| Compostella (L19) | 40-60 | 66 / 44 | 63 | 31 | a 5-unit Overgrowth swing often kills her from above 50% |
| His Majesty the Raccoon (L19) | 40-60 | 38 | 38 | 50 | |
| Captain Spotless, Capital gate (L18) | 60-75 | 64 | 59 | 88 | |
| Enforcer Captain Spotless, Old Service Tunnels (L21) | 40-60 | 47 / 72 | 31 | 63 | Inspection now exhausts one unit |
| Colonel Crumb (L21) | 40-60 | 50 | 44 | 56 | |
| Mirror Knight (L21) | 60-75 | 72 | 63 | 88 | |
| Royal Staircase Guard (L21) | 60-75 | 69 | 69 | 75 | |
| Percival Plume (L21) | 60-75 | 63 | 56 | 88 | |
| Clocktower Sentinel (L21) | 60-75 | 81 | 75 | 72 | The Hour Strikes (turn 4) |
| Primm, three phases as one HP pool (L22) | ~50 | 48 | 40 (B 33 / G 17 / R 42 / N 67, 12 runs per Path) | - | Gourmand stays the weak Path here (inbox) |
| The Failed Experiment (L27) | 60-75 | 63 | 50 | 81 | |
| The Drain Warden (L27) | 60-75 | 69 | 63 | 75 | |
| Siphon with Elowen (L28) | 40-60 | 69 | 63 | 56 | alone 0 / 0 (by design) |
| Arena: Cardboard Colossus (L12) | 60-75 | 56 | 56 | 81 | |
| Arena: Champion of the Four Fists (L12) | 60-75 | 88 | 81 | 81 | |
| Arena: Announcer Grand Bellows (L18) | 40-60 | 56 | 38 | 56 | INTERMISSION stands his units down |
| Quota, Transit Yards rematch (L19) | 60-75 | 56 | 50 | 56 | Mandatory Break |

**Part 2 two-Path normals** (6 games per Path, seeds 7000 / 8100; target 80%+): Executive Elevator Operator (Necrocrat+Beefcake) 100 / 96,
Rot Tunnel Horror (Beefcake+Refusemancer "Junkyard Gym") 83 / 92, Conveyor Belt Sushi Chef (Gourmand+Necrocrat) 92 / 83, Pizza Crust
Courtier (Gourmand+Refusemancer "Farm to Table") 100 / 100, Junction Patrol (Beefcake+Refusemancer) 96 / 100.

Seed spread at 16 games per cell is wide (War Machine 69 / 38, Mirror Knight 63 / 88); every fight's two-seed mean is at or above ~35%
(lowest: Mortimer 34, Compostella 47 with one seed at 31, Itamae 38) and the scripts were shown not to cause the two low ones.

## Overnight Oct 23, Phase 2 cycle 1 (Balance): Mortimer and the Itamae

- **Mortimer Grimsby** (D-HFA:14, L13, target 40-60): Temp Agency stat rule +1/+1 -> **+1/+0** (its text already said +1/+0 in one of
  its two entries; both now agree). Before 44 / 25 (seeds 7000 / 8100) -> after **69 / 38** (mean 53). Kept.
- **The Itamae Supreme** (S-GOUR:3, L16): Omakase 4 -> 3 starting Ingredients measured 44 / 31, identical to before: reverted.
  Mean stays 38 (seed 8100 is hard for him with or without his scripts). Left for the designer (inbox).
- Cycle 8: **The Itamae Supreme** at Elite skill instead of Boss: 44 / 31 again (no change), reverted. Seed 8100 per Path: Beefcake 25,
  Gourmand 100, Refusemancer 0, Necrocrat 0 - a matchup question (the L16 Refusemancer/Necrocrat reference decks vs his golems), not
  a number on him. Inbox.

## Overnight Oct 23, Phase 2 cycle 13 (Part 2's freed-zone challenge fights)

Once a zone is freed, its roamers (not the zone elites) come back as two-Path sparring partners (`ZoneEnemies.FREED_DECKS`: Gainlands
Gourmand+Beefcake "Bulking Season", D.N.A. Necrocrat+Beefcake, Buffet Gourmand+Refusemancer "Farm to Table", Dump Beefcake+Refusemancer
"Junkyard Gym"), same deck size and basics as their own, **+10 HP** (`FREED_HP_BONUS`), measured two levels after the zone's dungeon
(`EncounterCatalog.freed_zones`, groups `freed:<zone>`, 6 games per Path): without the bonus 96-100% in 3-6 turns; with it 96-100% in
5-7 turns on seeds 7000 and 8100 (normal band 80%+). Kept: a friendly rematch long enough to see the synergy, not a new wall.

## Cards Oct 27, Part 1: the card review applied (29 changes + 14 new cards)

Every row of `docs/design/card_review_oct25.csv` was applied (no "Card Review Oct 25" sheet export existed, so every row counted as
approved, the three opposing-Path cards included). Rows per card: `docs/design/sheet_changes_oct27.csv`. Scripts, the `on_path(sel,X)`
value and the `pump(sel,a,d,next)` duration (a lingering change until the controller's next turn, like Red Tape) are the engine side;
`once` now also works on triggered abilities (Bulking Program). Tests: `tests/core/game/test_cards_oct27.gd`.

| Card | Old -> New | Why |
|---|---|---|
| R-21 Let Them Eat Cake | 1(R) "Destroy target Gourmand unit." -> 2(R) "Deal 3 damage to target unit. If it is a Gourmand unit, destroy it instead and create a Garbage." | never dead in PvE; Refusemancer removes with damage |
| R-03 Landfill Ox | "Exhaust, eat garbage twice, lose 1 HP: add (R)(R)(R)(R)." -> "Exhaust, eat garbage: add (R)(R)(R)." | one clear cost on a Common |
| R-26 The Recycling Center | end-of-turn recursion -> "Use two Garbage: return target card from your Refuse Pile to your hand. Do this only once per turn." | immediate on your turn (it was 0% helpful) |
| R-13 Reclaimed Land | count comparison + two Infrastructure -> one Infrastructure, no comparison | Common complexity |
| R-18 Rusty Can Opener | + "Create a Garbage." | never dead |
| R-22, R-28 | cost "2 (R)" -> "2(R)" | sheet format |
| G-22 The Cullinator | 3(G)(G) -> 4(G)(G) | the set's one Power row |
| B-02 Bronzer | 1(B) -> (B) | strictly worse than Lifting Gloves |
| B-20 Dry Scoop | + "+1/+0" | never a dud |
| B-22 Alarm-ish Clock | 2 -> 1(B) | reads as Beefcake |
| B-24 Overclocked Mill Worker | 3(B) -> 2(B) | a turn-3 engine |
| N-10 Push Broom of Undeath | 4(N) any-attack Shred -> 2(N) attached Tool, +0/+1, "whenever attached unit attacks, destroy up to two target resources your opponent controls" | a real Tool template |
| N-19 Resting In Peace Clause | Common -> Uncommon | three-step payoff |
| BR-06 Hamster Ball | + "Whenever attached unit deals combat damage to an opponent, create a Garbage." | a dual card rewards both Paths |
| NB-01 Shredded Spectre | two three-resource costs -> "Whenever you use a Red Tape or an Iron, +1/+0 and Elusive until end of turn" | the old Iron cost was a trap |
| NB-13 Jello Weights -> Wobble Weights | name, text ("if attached unit is a Necrocrat unit..."), flavour (the lyric) | IP |
| GR-16 Ratatouille | flavour: the film motto -> "Five stars. Zero health inspections." | IP |
| GB-07 Bulking Program | 3(G)(B) start-of-turn buff -> 2(G)(B) "Whenever you use an Ingredient, put a buff on target unit you control. Do this only once per turn." | Ingredient interplay |
| GRB-07 Harvest Festival | wording -> The Infinite Pantry's template (same flag) | clarity |
| C-01 Cannon Fodder | 1/1 -> 2/1 | vanilla rate |
| C-09 Old Kingdom Automaton | 4/5 -> 4/6 | the wall its flavour promises |
| G-31, GRN-08, GB-09, NB-04 | names to title case; N-22 / N-17 / N-12 / G-22 flavour | sheet consistency |
| NEW B-34 Hammer Thrower (C) 3(B) 3/3 | Overexert: damage equal to its attack to target unit or opponent | the first unit with Yeet |
| NEW B-35 Protein Shake (C) 1(B) | +2/+2 until end of turn, create an Iron | the turn-two trick (in the starter) |
| NEW B-36 Desk Flip (C) 1(B) | 2 damage, 4 to a Necrocrat unit | hate card |
| NEW N-34 Final Notice (U) **1(N)(N)** | destroy target unit, create a Red Tape | the missing removal; the review's 2(N)(N) measured first (below), 3 energy is inside the removal rate |
| NEW N-35 Pending Approval (C) 1(N) | Processing 1: two 1/1 Zombie Temps and a Red Tape | teaches Processing (in the starter) |
| NEW N-36 Service Charge (C) 1(N) Trap | the opponent's second card in a turn: they lose 2 HP, you create a Red Tape | a fee that stays live |
| NEW N-37 Compliance Review (C) 2(N) | -2/-0 until the start of your next turn; a Beefcake unit is destroyed instead | hate card |
| NEW G-34 Amuse-Bouche (C) (G) | create an Ingredient, Peek 1, draw | the one-energy play (in the starter) |
| NEW G-35 Pest Control (C) 2(G) | send back; a Refusemancer unit is Plated instead | hate card |
| NEW R-34 Curb Alert (C) 1(R) | Regrow a unit card, create a Garbage | the Common Regrow (in the starter) |
| NEW R-35 Sewer Choir (C) 2(R) 1/1 | enters with two 1/1 Rats | a Rat maker at Common |
| NEW R-36 Landfill Leviathan (U) 5(R)(R) 7/7 | enters with two Garbage; eat garbage: Bulldoze until end of turn | an Uncommon top end |
| NEW C-35 Hand-Me-Down Shield (C) 1 Tool | attach: +0/+2 | a cheap defensive Tool |
| NEW NB-17 Iron Filing Clerk (U) 1(N)(B) 2/2 | use an Iron: a Red Tape; use a Red Tape: an Iron | the Necrocrat/Beefcake engine |

**Placement.** Starters (`CampaignStart.STARTING_DECKS`): one Colorless swap each - Beefcake a Tripwire for Protein Shake, Necrocrat an
Ambush Party for Pending Approval, Gourmand a Tripwire for Amuse-Bouche, Refusemancer an Ambush Party for Curb Alert. Sable's sample sells
two Commons of the player's own Path (`VendorStocks.OWN_PATH_COMMONS`). Zone shelves, packs and every reward table pick the new cards up by
rarity and Path on their own (nothing is `not_in_packs`). The sim's expected player (`ProgressionModel.UPGRADES`) buys them where a player
would: Hammer Thrower and Desk Flip on the Gainlands shelf, Compliance Review and Service Charge on the D.N.A. shelf, Final Notice x2 after
the Hall, Pest Control on the Buffet shelf, Sewer Choir on the Dump shelf, the Leviathan after the Rotheart.

**The cave** (`--what=tutorial --games=25`, seeds 7000 / 8100, whole Forgotten Cave cleared): with the review as written the two aggressive
Paths fell under the 80% line - B 76 / 82, R 72 / 82 (G 92 / 90, N 94 / 90) - because Cannon Fodder, the cave foes' most common card
(x4 / x3 / x2), is a 2/1 now. Encounter fix, not a card: each cave deck carries one Fodder fewer and one more basic
(`TrialOfTheHollow.enemy_recipe`). After: **B 88 / 92, G 92 / 88, R 78 / 92, N 96 / 92** (two-seed means 90 / 90 / 85 / 94; the per-fight
boss rows show 84-100% per Path, so no Path is at 100% in the Warden fight across both seeds). Reports `docs/design/sim/cards27_tutorial_v2_*.md`.

**The first zone** (`--filter=zone:beefcake`, L5): Flexing Brute 72 / 91 and Protein Shake Golem 72 / 89 (8 games per Path on seed 7000,
then 16 per Path on seed 8100; the 8-game read swings 12 points per game). Mean in band; no change.

**Level-12 round robin** (`--what=decks --level=12`, both seats the planning AI, no gear). The review's 23% for Necrocrat turned out to be
the expected-player model, not the cards: the Necrocrat reference deck's cut order removed every Middle Management Zombie, Accountant and
Notary Wraith to fit the upgrades and kept Village Militia and situational spells. `ProgressionModel.CUT_ORDER` now cuts the situational
spells (Casket, Waiting Room, Endless Filing, Permission to Die, Service Charge) before the bodies. Then Final Notice at the review's
2(N)(N) vs 1(N)(N):

| Seed, games | Beefcake | Gourmand | Refusemancer | Necrocrat |
|---|---:|---:|---:|---:|
| 7000, 10 (review, Oct 25) | 63 | 77 | 40 | 23 |
| 7000, 10 (new cards, old cut order) | 63 | 77 | 40 | 20 |
| 8100, 20 (new cards, old cut order) | 65 | 75 | 35 | 25 |
| 8100, 20 (new cut order, Final Notice 2(N)(N)) | 62 | 73 | 35 | 30 |
| 8100, 20 (new cut order, Final Notice 1(N)(N)) | 60 | 73 | 33 | 33 |
| 7000, 20 (same) | 63 | 73 | 43 | 20 |

Kept Final Notice at 1(N)(N) (3 energy, the removal rate's "targeted destroy 3-4"). Necrocrat vs Gourmand stays 10% on both seeds: the
golem engine out-bodies a deck of 2/2s in an AI mirror, and no Path is above 75% now (Gourmand 73). Necrocrat's rise is small (23 -> 20-33,
mean 27); the fights a Necrocrat player actually meets at level 12 (the Buffet roamers, 100% in the Oct 25 review) are the measure that
matters. Inbox: whether the round robin should drive further Necrocrat changes (the next lever would be the Necrocrat Commons' bodies,
which the brief kept off limits).


## Overnight Oct 27-28, Part 1: Necrocrat Common / Uncommon units (the round robin's weakest Path)

Brief: Necrocrat's level-12 round robin read 20-33% overall and 10% vs Gourmand after Cards Oct 27; the target is ~40-50% overall, no
worse than ~30% vs any Path, every starter still 80%+ in the cave, nothing over ~75%. Lever: the Path's Common / Uncommon units (bodies
and a better early unit), inside the identity (Red Tape, Processing, destroy, paperwork undead). Final Notice stays 1(N)(N); the Gourmand
shelf's Epic tier and the Necrocrat / Beefcake pair's missing Alchemist Legendary are approved as they are. Rows for the sheet:
`docs/design/sheet_changes_oct28.csv` (`node tools/sheet_changes_oct28.js`). Tests `tests/core/game/test_cards_oct28.gd`.

| Card | Old -> New | Why |
|---|---|---|
| N-03 Post-Human Resources Ghoul (C) 3(N) | 2/3 -> **3/4** | a 3-drop that trades with the 2/4 Sucker Punch walls instead of bouncing off them |
| N-04 Body-builder (C) 2(N) | 2/2 -> **2/3** | the Red Tape -> 2/2 body engine has to survive a turn to run |
| N-05 Corpseified Public Accountant (C) 2(N) | 2/3 -> **2/4** | the wall that farms Red Tape (En Garde-Manger is 2/4 at 2(G)) |
| N-07 Grave Shift Worker (C) 3(N) | 3/3 -> **3/4** | same rate as the Ghoul |
| N-23 Middle Management Zombie (U) 3(N) | 2/4 -> **3/5** | the Uncommon lord was the Path's biggest body and died to every 3-power unit |
| NEW N-38 Hazmat Intern (C) 2(N) Unit 1/3 | **Toxic.** | the "better early unit": the Path's destroy identity on a body; a Common blocker that kills whatever it touches (Necro Cat, NR-15, is the dual precedent; the Pen, N-08, already hands out Toxic) |

Set A (the five bodies alone) measured 35% on seed 8100 (vs Gourmand still 10%): the Ghoul and the Worker never enter the sim's reference
deck (the D.N.A. package did not buy them), so only three of the five mattered. Set B adds the Hazmat Intern and puts the zone shelf's
Commons into the level-9 package the way the model's own comment says it should (two Interns, one Ghoul, one Worker;
`ProgressionModel.UPGRADES`; the cut order was not touched - the four extra cards push out Village Militia, the Waiting Room, Endless
Filing and Permission to Die).

**Level-12 round robin** (`--what=decks --level=12 --games=20`, both seats the planning AI, no gear; reports `docs/design/sim/oct28_decks_l12_*.md`):

| Seed | Beefcake | Gourmand | Refusemancer | Necrocrat | N vs B / G / R |
|---|---:|---:|---:|---:|---|
| 8100 before (Cards Oct 27) | 60 | 73 | 33 | 33 | 40 / 10 / 50 |
| 7000 before (Cards Oct 27) | 63 | 73 | 43 | 20 | 20 / 10 / 30 |
| 8100 set A | 60 | 73 | 32 | 35 | 40 / 10 / 55 |
| 8100 set B | 55 | 72 | 23 | **50** | 55 / 15 / 80 |
| 7000 set B | 60 | 65 | 35 | **40** | 30 / 35 / 55 |
| two-seed mean, set B | 58 | 68 | 29 | **45** | 43 / 25 / 68 |

Kept set B. Necrocrat reads 45% (target 40-50), nobody is above 75% (Gourmand 68, down from 73), and no Path sits at the old 20%. Two
numbers are outside the brief's lines and are logged rather than tuned away: Necrocrat vs Gourmand is 25% on the two-seed mean (15 / 35;
the golem deck's three 2/4 Sucker Punch walls kill a 1/3 Toxic blocker before it deals damage, so the Intern does little there), and the
Toxic blocker is a hard counter to Refusemancer's big bodies (Necrocrat vs Refusemancer 55 / 80, Refusemancer's overall 29 against 33-43
before). 20 games per pairing swing +/-11 points, so both are one-seed-sized; a third seed in the morning would settle them. The next
lever for the Gourmand cell, if wanted, is Pink Slip to "attack 4 or less" (a spell, outside tonight's unit-only brief).

**The cave** (`--what=tutorial --games=25 --seed=7000`): B 88 / G 92 / R 78 / N 96 - identical to the Cards Oct 27 run on this seed (the
cave foes run no Necrocrat cards; the Necrocrat starter's Body-builders and Middle Management Zombie did not change its 96%). Seed 8100
was not rerun (nothing in it changed: B 92 / G 88 / R 92 / N 92 stand; two-seed means 90 / 90 / 85 / 94).

**PvE with the buffed bodies** (the D.N.A. roamers and the Hall run the zombie archetype: N-03 x3, N-04 x3, N-05 x3, N-07 x3, N-23 x2):
`zone:necrocrat` 8 games/Path: Shambling Middle Manager 88% (B 88 / N 88 / G 100 / R 75), Zombie Intern 100% - the Oct 25 read was 90%
(75 / 100 / 100 / 83). `dungeon:D-HFA` 6 games/Path: every node "ok"; the elites 67 / 71%, Mortimer 58% (B 67 / N 50 / G 100 / R 17), the
Cards Oct 27 sweep had 63 / 56 / 56% with Refusemancer at 25% on all three. Within noise; no encounter changed. The Hazmat Intern is in no
enemy deck (archetypes list cards by id), so no foe gained Toxic.
