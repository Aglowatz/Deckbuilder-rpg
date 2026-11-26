# Health for every Path (Nov 25 night, Part F)

The owner: each Path should have some way to restore the player's HP (Nourish units and spells, giving up resources or units for HP,
heal spells, tools or wonders); Pathless cards can do it too. Not a hard rule, but every Path's player should get through a dungeon.

## Before this pass

| Path | Cards that restore HP | What they are |
|---|---:|---|
| Beefcake | **0** | - |
| Necrocrat | 1 | Notary Wraith (1 HP when it dies) |
| Refusemancer | 1 | Back From the Heap (a trap: 5 HP when you are at 5 or less) |
| Gourmand | 4 | Soup Kitchen Volunteer, Hearth Kitchen, Lunchbox, Banquet Hall |
| Pathless | 5 | Wandering Medic (Nourish), Healing Potion, Emergency Rations, Village Well, Trey Pickett |
| Multi-Path | 6 | Freegan Forager, Potluck, Rodent De Cuisine, Mushroom Ring, Silver Serving Platter, Champion of the Four Paths |

## The reworks (weakest and least-used cards: no deck, recipe or dungeon list used them)

| Card | Old text | New text |
|---|---|---|
| Hulking Hauler (B-13, 5(B) 6/5) | Hustle. | Hustle. When this unit enters, gain 3 HP. |
| Snack Bar (B-23, (B) Wonder) | Pay 1: target unit gets +2/+0 until the end of your turn. Each unit can be targeted only once per turn. | Pay 1: gain 2 HP. Do this only once per turn. |
| I've Made a Huge Mistake (N-20, 1(N) Spell) | As an additional cost, destroy a unit you control. Draw 2 cards and create a Red Tape. | As an additional cost, destroy a unit you control. Draw two cards and gain HP equal to the destroyed unit's defense. |
| Push Broom of Undeath (N-10, 2(N) Tool) | ... Attached unit gets +0/+1. Whenever attached unit attacks, destroy up to two target resources your opponent controls. | ... Attached unit gets +0/+1 **and Nourish**. (the rest unchanged) |
| Community Compost Bin (R-10, 1(R) Wonder) | At the start of your turn, if you control no Garbage, create a Garbage. | (the same) **Eat garbage: gain 2 HP. Do this only once per turn.** |
| Mulch Mole (R-01, (R) Unit 0/2) | Exhaust: add (R). | (the same) **Eat garbage: gain 1 HP. Do this only once per turn.** |

## The new cards (GENERAL: packs, shops, rewards, drafts; temporary art copied from a related card; art rows in `docs/art/batch22.csv`)

| Card | Cost, type | Text | Temporary art from |
|---|---|---|---|
| Cool-Down Stretch (B-39, Common) | (B) Spell | Gain 4 HP. Create an Iron. | Protein Shake |
| Soul Collector (N-39, Common) | 3(N) Unit 2/3 | Flying. When this unit enters, your opponent loses 2 HP and you gain 2 HP. | Notary Wraith |
| Compost Tea (R-38, Common) | (R) Spell | As an additional cost to play this, use two Garbage. Gain 5 HP. | Community Compost Bin |
| Bone Broth Cook (G-36, Common) | 2(G) Unit 1/3 | Nourish. When this unit enters, create an Ingredient. | Soup Kitchen Volunteer |
| Field Bandages (C-41, Common) | 1 Tool | Destroy this Tool: gain 3 HP and draw a card. | Healing Potion |

## After this pass

| Path | Cards that restore HP (single-Path and Pathless; multi-Path cards on top) |
|---|---|
| Beefcake | Hulking Hauler, Snack Bar, Cool-Down Stretch (3) + the Pathless six |
| Necrocrat | Notary Wraith, I've Made a Huge Mistake, Push Broom of Undeath, Soul Collector (4) + the Pathless six |
| Refusemancer | Back From the Heap, Community Compost Bin, Mulch Mole, Compost Tea (4) + the Pathless six |
| Gourmand | the four before, Bone Broth Cook (5) + the Pathless six |
| Pathless | Wandering Medic, Healing Potion, Emergency Rations, Village Well, Trey Pickett, Field Bandages (6) |

The sims of the changed and new cards are in `docs/design/sim/nov25n/health_cards_summary.md`.
