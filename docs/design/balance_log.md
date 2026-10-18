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
