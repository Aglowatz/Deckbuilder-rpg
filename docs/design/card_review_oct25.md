# Card set review - Oct 25 2026 (proposals only)

Overnight Oct 25b, Part 1. Every card in `data/source/card_list.csv` (312) and `token_list.csv` (25) was read against the Design
Guidance (`data/source/design_guidance.csv`). **Nothing in the game, the data or the sheet was changed**; this document and
`docs/design/card_review_oct25.csv` (one row per proposed change, 29 changes + 14 new cards) are the whole output.

Philosophy applied: PvE, so power differences are fine and only clear outliers are flagged (one). What matters is that a card is fun,
clear (templates, keywords, complexity fits rarity), true to its Path (identity, resource, removal rules, the opposing pairs), has a role
(no strictly-worse twin; each Path can build its plan from Commons and Uncommons; dual cards reward the pair), makes the early game fun
for every Path, and keeps its humour IP-safe. The eight Black Market cards (N-27, R-31, G-29, B-27, C-30, C-24, NR-12, GB-12) were
read but are excluded from proposals by the brief's rule.

Evidence used (modest runs, one Godot at a time, seed 7000): the reference-deck round robins at level 1 and 12
(`docs/design/sim/review_decks_l1.md`, `review_decks_l12.md`), one roamer per zone with per-card lift (`review_one_{beefcake,
necrocrat,gourmand,refusemancer}.md`, 12 games per Path), plus the Oct 18-23 sim notes already in `docs/design/starting_decks.md`,
`balance_log.md` and `ai_state.md`. Per-card lift at 12 games is noisy (one game is 8 points); it is cited as a hint, never as proof.

## Headline

| | Proposals | High | Medium | Low | New cards |
|---|---:|---:|---:|---:|---:|
| Refusemancer | 7 | 1 | 2 | 4 | 3 |
| Necrocrat | 5 | 1 | 2 | 2 | 4 |
| Beefcake | 4 | 0 | 1 | 3 | 3 |
| Gourmand | 2 | 0 | 1 | 1 | 2 |
| Dual / tri Path | 9 | 2 | 2 | 5 | 1 |
| Colorless | 2 | 0 | 0 | 2 | 1 |
| **Total** | **29** | **4** | **8** | **17** | **14** |

By category: Clarity 12, Role 6, Flavour 5 (two of them IP), Fun 3, Power 1, Identity 1, Early game 1, New card 14.

The set is in good shape. The templates are followed almost everywhere, the Path identities read clearly, the Commons are simple, and
the humour lands. The findings are mostly polish (title case, a cost format, two long flavour texts), a handful of cards whose role is
taken by a better twin, two IP slips, one Common that follows no template, and four real gaps: Necrocrat has no unconditional single-unit
removal below Epic, Refusemancer has no Common recursion and no Uncommon top end to ramp into, the Yeet and Processing mechanics each
have at most one card, and the "opposes" line on the Path identity exists in play for one pair only.

## Per Path

**Beefcake (33 cards).** Clear and fun: Hustle bodies, Iron, Tools, burst. The Tool suite has one redundancy (Bronzer is strictly worse
than Lifting Gloves at the same cost) and Dry Scoop overlaps Pre-Workout Canister. The Path's own mechanic Yeet exists only as a spell;
no unit throws. The only Beefcake card with no Beefcake pip is Alarm-ish Clock. The early game is the strongest of the four (tutorial
88-95%, first roamers 100%); its starter is 15 Colorless + 11 Path cards, so its burst identity shows late. Proposals: 4 changes, 3 new
(Hammer Thrower teaches Yeet, Protein Shake is the turn-two trick, Desk Flip the hate card).

**Necrocrat (33 cards).** The best-written flavour in the set and a coherent value plan, but the removal suite does not deliver the
identity's "strong vs any single unit": Pink Slip (attack 3 or less), Processing Delay (two turns later), edicts (the foe chooses) and
then nothing until Mass Layoffs (Epic). The level-12 round robin shows it: the Necrocrat reference deck won 23% overall and 0% against
Gourmand's golem engine (10 games a pairing). Push Broom of Undeath is the one Common in the set that follows no template. Processing,
a signature mechanic, has one mono-Necrocrat card. Proposals: 5 changes, 4 new (Final Notice fills the removal gap; Pending Approval
teaches Processing; Service Charge adds a fee that stays live; Compliance Review is the hate card).

**Gourmand (33 cards).** The most complete Path: makers, cookers, recipes, healing, bounce, Plate, a trap suite. Also the strongest in the
mid game (77% in the level-12 round robin, 100% vs Necrocrat), which is fine for PvE except for one Uncommon on the first-visit shelf: The
Cullinator is unconditional removal plus a 4/4 plus Ingredients for 5 energy; +1 energy proposed (the set's only Power row). The early
game is the slowest (tutorial 87-90%, 75% vs the Flexing Brute, 75-80% vs the Stray Gym Hound); Amuse-Bouche is a one-energy recipe for
turn one. Proposals: 2 changes, 2 new.

**Refusemancer (33 cards).** Fun, scrappy, on-theme, and the Path with the most small issues: Let Them Eat Cake is a dead card in PvE
(and uses Necrocrat's removal verb), Landfill Ox has a three-part cost on a Common, The Recycling Center's end-of-turn timing made it
the starter's least helpful card (0% when played, Oct 18), three cost cells have a stray space. Gaps: Regrow (a defined mechanic) only
at Uncommon, Rats (an identity piece with four payoffs) made by no mono-R Common, and the ramp (five cards) has only Heap Tortoise and an
Epic to ramp into. Proposals: 7 changes, 3 new (Curb Alert, Sewer Choir, Landfill Leviathan).

**Dual and tri Path (121 cards).** Almost every pair rewards combining its two resources; the exceptions are Hamster Ball (identical to
the Common Weight Belt but a pip more) and Bulking Program (a Colorless Wonder with two pips). Shredded Spectre's "use 3 Iron: +1 attack"
is worse than using the Iron normally. Two IP slips: Jello Weights (trademark name, song-lyric flavour) and Ratatouille's flavour (a
film's motto). Necrocrat/Beefcake, the pair the story says opposes each other, has the thinnest two-resource engine; Iron Filing Clerk
(new) is the reason to run both. Harvest Festival's wording should use The Infinite Pantry's template.

**Colorless (34 cards).** Does its job as glue. Cannon Fodder and Old Kingdom Automaton sit under the vanilla rate; the Common Tools are
all offensive or one-shot, so the defensive starters have no cheap way to keep a body alive (Hand-Me-Down Shield, new).

**Tokens (25).** Clean. T-24 and T-25 (the Lab's ally and the Failed Experiment) are listed as "new" in `docs/card_import_report.md`
only because the report is stale; both have scripts (`data/scripts/tokens.txt`).

## Top 15 proposals

| # | Card | Category | Priority | Proposal (short) |
|---|---|---|---|---|
| 1 | N-10 Push Broom of Undeath | Clarity | High | Make it a real Tool: 2(N), attach, +0/+1, "whenever attached unit attacks, destroy up to two target resources your opponent controls"; new flavour |
| 2 | R-21 Let Them Eat Cake | Role / Identity | High | 2(R): deal 3 damage; if a Gourmand unit, destroy it and create a Garbage (never dead, Refusemancer removal verb) |
| 3 | NB-13 Jello Weights | Flavour (IP) + Clarity | High | Rename (Wobble Weights), replace the lyric, "if attached unit is a Necrocrat unit..." |
| 4 | GR-16 Ratatouille | Flavour (IP) | High | Replace the film motto: "Five stars. Zero health inspections." |
| 5 | NEW Final Notice | New card | High | Necrocrat (U) 2(N)(N) Spell: destroy target unit, create a Red Tape |
| 6 | NEW Curb Alert | New card | High | Refusemancer (C) 1(R) Spell: Regrow a unit card, create a Garbage |
| 7 | NEW Iron Filing Clerk | New card | High | N/B (U) 1(N)(B) 2/2: using an Iron makes a Red Tape and the reverse |
| 8 | G-22 The Cullinator | Power | Medium | 3(G)(G) -> 4(G)(G) |
| 9 | R-26 The Recycling Center | Fun | Medium | your-turn, once per turn, instead of end of turn |
| 10 | BR-06 Hamster Ball | Role | Medium | + "whenever attached unit deals combat damage to an opponent, create a Garbage" |
| 11 | NB-01 Shredded Spectre | Clarity / Fun | Medium | "whenever you use a Red Tape or an Iron, +1/+0 and Elusive until end of turn" |
| 12 | R-03 Landfill Ox | Clarity | Medium | "Exhaust, eat garbage: add (R)(R)(R)." |
| 13 | B-02 Bronzer | Role | Medium | cost (B) |
| 14 | N-19 Resting In Peace Clause | Clarity | Medium | Common -> Uncommon |
| 15 | N-22 Working in Your Own Casket | Flavour | Medium | "Remote work. Very remote." (typo and length) |

## New cards (14)

Full text, flavour, reasons and ChatGPT-ready image descriptions (style lock + Path accent) are in the CSV, Category "New card".

| ID | Card | Path | Rarity | Cost | Type | Stats | Rules text |
|---|---|---|---|---|---|---|---|
| NEW-B1 | Hammer Thrower | Beefcake | C | 3(B) | Unit | 3/3 | Overexert: this unit deals damage equal to its attack to target unit or opponent. |
| NEW-B2 | Protein Shake | Beefcake | C | 1(B) | Spell | - | Target unit gets +2/+2 until end of turn. Create an Iron. |
| NEW-B3 | Desk Flip | Beefcake | C | 1(B) | Spell | - | Deal 2 damage to target unit. If it is a Necrocrat unit, deal 4 damage instead. |
| NEW-N1 | Final Notice | Necrocrat | U | 2(N)(N) | Spell | - | Destroy target unit. Create a Red Tape. |
| NEW-N2 | Pending Approval | Necrocrat | C | 1(N) | Spell | - | Processing 1: create two 1/1 Zombie Temp tokens and a Red Tape. |
| NEW-N3 | Service Charge | Necrocrat | C | 1(N) | Trap | - | When your opponent plays their second card in a turn, they lose 2 HP and you create a Red Tape. |
| NEW-N4 | Compliance Review | Necrocrat | C | 2(N) | Spell | - | Target unit gets -2/-0 until the start of your next turn. If it is a Beefcake unit, destroy it instead. |
| NEW-G1 | Amuse-Bouche | Gourmand | C | (G) | Spell | - | Create an Ingredient. Peek 1, then draw a card. |
| NEW-G2 | Pest Control | Gourmand | C | 2(G) | Spell | - | Send target unit back to its owner's hand. If it is a Refusemancer unit, Plate it instead. |
| NEW-R1 | Curb Alert | Refusemancer | C | 1(R) | Spell | - | Return target unit card from your Refuse Pile to your hand. Create a Garbage. |
| NEW-R2 | Sewer Choir | Refusemancer | C | 2(R) | Unit | 1/1 | When this unit enters, create two 1/1 Rat tokens. |
| NEW-R3 | Landfill Leviathan | Refusemancer | U | 5(R)(R) | Unit | 7/7 | When this unit enters, create two Garbage. Eat garbage: this unit gains Bulldoze until end of turn. |
| NEW-C1 | Hand-Me-Down Shield | Colorless | C | 1 | Tool | - | Exhaust: attach to target unit you control. Attached unit gets +0/+2. |
| NEW-NB1 | Iron Filing Clerk | Necrocrat / Beefcake | U | 1(N)(B) | Unit | 2/2 | Whenever you use an Iron, create a Red Tape. Whenever you use a Red Tape, create an Iron. |

The three hate cards (Desk Flip, Pest Control, Compliance Review) complete the set with Let Them Eat Cake: one cheap, never-dead Common
per Path whose upgrade fires against the Path it opposes. In PvE they are the cards a player buys before the opposing zone. Drop them
if the "opposes" line is meant as story only.

## Expected effect on the early game

- **Power is not the problem.** Every starter clears the Forgotten Cave 87-98% and the first roamers 75-100%; Beefcake leads, Gourmand
  trails, as the Oct 22 sims and tonight's level-1 round robin (50% everywhere at 10 games) agree. None of the proposals above changes
  a starter card's numbers except Bronzer (cost) and Dry Scoop (+1/+0); the Cullinator and Final Notice are mid-game cards.
- **Identity shows late.** The starters are 14-15 Colorless of 26, Sable's sample is five Colorless Commons plus one Common of each
  Path, and the first on-Path Uncommon arrives in the level-4 Path Pack. The new Commons are starter candidates, one Colorless swap each:
  Protein Shake (Beefcake), Pending Approval (Necrocrat), Amuse-Bouche (Gourmand), Curb Alert or Sewer Choir (Refusemancer). Each gives
  the tutorial's "make / spend your Resource" prompts one more thing to point at and shows the Path's verb (burst, inevitability, recipes,
  recycling) in the first hour. A vendor-side suggestion (not a card): Sable's sample sells two Commons of the player's own Path.
- **Gourmand's slow start** (the weakest early cell) gets a one-energy play; **Necrocrat's mid game** (23% at level 12) gets its missing
  removal; **Refusemancer** gets a plan to buy into (Rats, Regrow, a top end) instead of ten good Commons with no payoff shelf.
- Re-measure after any change with the two-seed rule (`--what=tutorial --games=50 --seed=7000` and `8100`) and the level-12 round robin.

## Notes for the designer (not card rows)

- **Design Guidance, "Buff" row: the definition cell is `#ERROR!`** (a broken formula in the sheet). The game treats a buff as a
  permanent +1/+1 counter; the cell should say so.
- **Defined keywords that no card uses as a keyword:** Cook X (every card writes "Use two Ingredients: create a ... Golem token"), Yeet
  (only the spell of that name), Regrow (cards write "return target card from your Refuse Pile to your hand"); Fertilize appears once,
  with reminder text. Recommended: keep the plain text on Commons and mark these as rules/UI terms in the guidance, or add reminder-text
  versions on the cards that would carry them. Also "Eat Garbage" is capitalised in the guidance and lower-case ("eat garbage") on every
  card; pick one.
- **Rarity labels** are "(L) Signature card" on R-33 and "(L) Signature" on G-33 and N-33; the importer copes, the sheet should match.
- **Dual-Path Infrastructure "enters refreshed":** the engine never makes Infrastructure enter exhausted, so the trade-off line in the
  guidance is a no-op; either the rule or the line should change.
- **Four-Path cards (P4-01..03) sit under the "Necrocrat / Beefcake / Refusemancer" section header** in the sheet; the importer gives
  them all four Paths by id, but a "Four Paths:" header row would make the sheet self-describing.
- **Stealing** (Unconscionable Contract, mono-Necrocrat Legendary) vs the guidance note "stealing stays in multi-path": the Legendary
  reads as the intended exception; add it to the note.
- **Watch list, no change proposed:** Possum Prowler (a 1-energy 2/2 with a repeatable pump; the Path's fun card and the starter's best
  performer), Hearth Kitchen (unlimited healing per turn; fine in PvE), Heap Tortoise (above the vanilla rate, which the Path skew allows),
  Idiot Sandwich (a chef meme as a parody name, within the IP rule).
- `docs/card_import_report.md` is stale (lists T-24 / T-25 as unscripted); rerun `bash tools/import_cards.sh` to refresh it.
