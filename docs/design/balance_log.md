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
