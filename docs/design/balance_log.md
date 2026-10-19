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
