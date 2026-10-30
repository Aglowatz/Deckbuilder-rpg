# Equipment power budget (Overnight Oct 29, Part 3)

The rule the brief gave: effects that scale with board size are worth far more than single-unit effects, and must be priced and placed
late, or reworded. This file turns that into a budget every piece and item is checked against; the review and the changes are below.
Measured lifts come from `--what=gear` (one piece alone vs bare, each Path's expected player): `docs/design/sim/oct29_gear_l5_before.md`
(Gainlands roamers, L5), `oct29_gear_l12_before.md` (Meatloaf Golem, L12), `*_after.md`, and Oct 18's `f_gear_l5.md` / `f_gear_l12.md`.

## Power points

| Effect | Points | Note |
|---|---:|---|
| Max HP +1 | 0.5 | +2 = a Common; +3 = 1.5 |
| Starting HP +1 (not max) | 0.4 | does nothing inside a dungeon run (inbox, Oct 27) |
| Draw an extra card on the first turn / max hand +1 | 1 / 0.5 | |
| Draw 2 at the start of the duel | 1.5 | |
| Draw an extra card every turn | 3 | two: 5 |
| Always go first | 1.5 | |
| One resource per turn (or per attack, per death) / start with 2 / +1 whenever you make one | 1.5 | |
| One-Path units +1/+1 (or +0/+2, +0/+3) | 2.5 (2, 2.5) | conditional on building that Path |
| One-Path keyword (Flying, Toxic, Hustle, Sucker Punch) | 2 (2.5 for Toxic) | |
| **Any-colour** units +1 attack or +1 defense | **3** | scales with the board: never at tier 1 |
| Any-colour +1/+1 / +2 attack / a keyword | 4.5 / 5 / 3 | |
| Per-turn board effects (1 damage to each enemy unit, +0/+1 to all your units) | 4 | |
| The opponent loses 1 HP per turn / takes 1 whenever a unit enters | 2.5 | a clock; strong against low-HP early foes |
| Enemy units enter with -1/-1 | 3.5 | kills tokens |
| Reveal the opponent's hand / +25 % XP / +35 % walking | 1 | out of battle or information only |
| Drawbacks: max HP -2 / -3 / -4 | -1 / -1.5 / -2 | |
| Drawbacks: only 2 (1) non-infrastructure cards a turn; cannot block; Wallflower on a Path; random discard each turn; -1 defense to all | -1.5 (-2.5); -2; -2; -2; -3 | |

## The budget

| Rarity | Points | Where it may first appear (tier) | Board-wide (any-colour)? |
|---|---:|---|---|
| Common | up to 1 | tier 1 (Crosspath L5, side dungeons, chests) | never |
| Uncommon | 1.5-2.5 (up to 3 with a drawback) | tier 1 (Crosspath) only single-unit, Colorless-only or information; tier 2 (a zone freed, L9+) one-Path board-wide | one Path only |
| Epic | 3.5-5 | tier 2 (a main dungeon's first clear, L9+) with a drawback; tier 3 (Bertram's rack L13, the later zones) without | yes, from L9 with a drawback, from L13 without |
| Legendary | 5-6 | tier 3-4 (L19+, worn from L22) | yes |

Tier = where the piece is first obtained: 1 Crosspath / first visit, 2 the first zones and their clears (L6-13), 3 the L13 rack and the later
zones (L13-19), 4 the Capital and the postgame.

## The review (every piece)

Verdict: ok = inside the budget; **changed** = see the change table. Lifts are points of win rate alone vs bare (6-8 games per Path: +-8).

| Piece | Slot | Rarity | Tier | Points | Lift L5 / L12 | Verdict |
|---|---|---|---:|---:|---|---|
| Starter Blade (armory quest) | W | C | 1 | 0.5 | +0 / - | ok |
| Extra Pocket | R | C | 1 | 0.5 | +0 (Oct 18) | ok, cheap |
| Traveler's Boots | B | C | 1 | 1 | - | ok |
| Cardboard Cuirass | A | C | 1 | 1 | - | ok |
| Saucepan Helmet | H | C | 1 | 0.9 | - | ok |
| Lucky Sock (chests) | R | C | 1 | 0.8 | - | ok (starting HP: no effect in dungeons) |
| A Very Pointy Stick (S-TOWN) | W | C | 1 | 0.5 | - | ok |
| Participation Trophy (quest) | R | C | 1 | 1 | - | ok |
| Flip-Flops of Fortitude | B | C | 2 | 1 | - | ok |
| **Wicked Dagger** | W | U | 1 | 3 (any-colour +1 attack) | +3 / +8 | **changed**: Colorless units only (1.5); the any-colour +1 moved to the Blade of Earned Reputation |
| **Solid Plate** | A | U | 1 | 3 (any-colour +1 defense) | +6 / +0 | **changed**: Colorless units only (1.5) |
| X-Ray Goggles | H | U | 1 | 1 | - | ok (information; a human piece) |
| **Gotta-Go Galoshes** (quest, L6) | B | E | 2 | 1 (walking) | +0 | **changed**: Common - an Epic convenience piece took the one Epic slot until L13 |
| Kettlebell Locket / Red Tape Dispenser / Doggy Bag / Dumpster Diving Gloves (quests) | R/R/A/W | U | 2 | 1.5 | - | ok |
| Dog-Eared Bookmark | R | U | 2 | 1.5 | - | ok |
| Protein Shaker Bandolier / Notarized Seal / Trash Panda Tiara | A/R/H | U | 2-3 | 2.5 / 2 / 2.5 | Oct 18: +12 / +25 / +25 on their Path | ok (one Path) |
| Paper-Plane Cape / Mystery-Stain Bib / Side-Hustle Headband | A/A/H | U | 2-4 | 2 / 2.5 / 1.5 | - | ok |
| Velvet Rope | R | U | 3 | 0.5 (+0/+3, Wallflower) | Oct 18: +25 Gourmand | ok (measured) |
| Courier Lanyard (D.N.A. puzzle) | R | U | 2 | 1.5 | - | ok |
| **Gainsmith's Lifting Belt** (Gainlands puzzle, L5) | A | E | 2 | 4.5 (any-colour +1 defense at L5) | +6 / +4 | **changed**: Beefcake units +0/+1, max HP +3 (3); Uncommon |
| Head Chef's Ladle / Head Chef's Toque / Compost Boots | W/H/B | U | 3 | 1.5 / 1.5 / 2.5 | - | ok |
| **Spotter's Barbell** (Gainlands quest, L5) | W | E | 2 | 2.5 but a clock | **+17** / +13 | **changed**: Beefcake units only |
| Compliance Clipboard (D.N.A. quest) | R | E | 2 | 2.5, a clock | Oct 18: +16 | ok |
| **Glass Jaw Gauntlets** (D-HOG, L9) | W | E | 2 | 5 - 1.2 | +8 / +17 | **changed**: the drawback is max HP -3 (works in dungeons) |
| Overdue Library Book (D-HFA) | R | E | 2 | 5 - 2 | Oct 18: +25 | ok |
| Elastic Waistband (D-TTK) | A | E | 3 | 4.5 - 1.5 | Oct 18: +22 | ok |
| Flamethrower (rack) | W | E | 3 | 4 | Oct 18: +0 | ok (an anti-token piece) |
| Big Brain Beret (rack) | H | E | 3 | 3 - 2.5 - 1 | Oct 18: +31 | ok (the AI shrugs at one card a turn; a human does not) |
| Cheater's Dice / Hover Boots / Thorned Loincloth (rack) | R/B/A | U | 3 | 1.5 / 1 / 1 | Oct 18: -13 / -13 / -6 (before their fixes) | ok as sidegrades |
| **Blade of Earned Reputation** (rack, new) | W | E | 3 | 3 | measured after | **new**: the old Dagger's any-colour +1 attack, at L13 for 450 |
| Grandma's Rolling Pin | W | E | 3 | measured +38 | | ok |
| **Sucker Punch Mitts** | W | E | 3 | 3 - 3 = 0 | +0 | **changed**: Uncommon, max HP -3 instead of -1 defense to everything |
| Seed Satchel (Dump puzzle) | R | E | 3 | 4 | - | ok |
| Iron Knuckles / Pantry Apron / Bin Lid / Clerk's Stamp (Capital quests) | W/A/H/R | U/E/U/U | 4 | 1.5 / 3 / 1.5 / 1.5 | - | ok |
| **Champion's Laurels** (arena) | H | E | 2 | 2.5 | +8 | **changed**: Uncommon |
| Crowd-Pleaser's Cape / Bloodsand Boots (arena) | A/B | U | 2-4 | 1.5 / 2 | - | ok |
| **Gladiator's Net** (arena) | W | U | 3 | 3.5 | **+21** | **changed**: Epic |
| **Quota's Stopwatch / Colonel's Ladle / Plume's Quill / Clipwell's Shears** (lieutenants) | R/W/R/W | E | 4 | 1.5 / 1.5 / 1.75 / 2 | +0 / -8 / -4 / -4 | **changed**: Epic-strength (first-turn draw + max hand +2; max HP +3; 2 Red Tape + a Contract; 2 damage to each attacker) |
| **Crown of Mild Hubris** (S-CAP) | H | L | 4 | 0.5 | +4 | **changed**: + your units +1 attack (3.5; +1/+1 pushed Primm's phases to 92-100 %) |
| **Four-Seal Signet** (Vault) | R | L | 4 | 3.5 | +13 | **changed**: max HP +5, first-turn draw (5.5) |
| **Siphon's Lens** (Lab) | R | E | 4 | 2 | +4 | **changed**: draw an extra card every turn (4) |
| **Phial of First Water** (Old Well) | R | L | 3 | 4 | +4 | **changed**: + max HP +3 (5.5) |

Items (once per battle, 1 / 2 / 3 slots): every item is 0.5-1.5 points and the encounters are tuned without them. Oct 18 measured the
Reckless Tonic at +19 alone (6 HP in one gulp at 16 max HP): **changed** to 5 HP. The rest (Draught 3 HP x3, Salve 4 HP x3, Scroll draw 2,
Firebrand 2 damage, Stone +2/+2, Chains, Powder, Dust, the four resource pouches, the Summoning Charm, the Ward Sigil) measured +0..+8.
The Hearty Pot Pie (6 HP, a quest and chest item, never sold) is left as the one big heal.

## Caps and the track

- Equip caps (`level_track.json`): Common 5; Uncommon 2, 3 at L10, 5 at L16; Epic 1 at L5, 2 at L13, 3 at L19, 5 at L25; Legendary 1 at
  L22, 2 at L28. With the review: the Epics a player can hold by stage are the Barbell (L5-6, quest), the Gauntlets (L9), the Clipboard
  (L10), then the rack and the Book at L13 - one Epic slot until 13 is a real choice, two from 13, three from 19. The Uncommon cap of 2
  until L10 bites (Dagger / Plate / Goggles / Locket / Bandolier / Bookmark / Lanyard / Cape) - also a choice. Unchanged.
- The armory quest (L5) pays the Starter Blade (Common) and opens every slot; the level track opens the advanced rack at 13. Unchanged.
- The level-up track's equipment-related grants (L5 "The armory opens", L13 "Bertram's advanced rack") still land where the pieces are.

## Slot progression (upgrades and sidegrades per zone)

| Slot | Crosspath (L5) | Gainlands (L5-9) | D.N.A. (L9-13) | Buffet (L12-16) | Dump (L15-19) | Capital / postgame |
|---|---|---|---|---|---|---|
| Weapon | Starter Blade (C); Wicked Dagger (U, Colorless) | Pointy Stick (C, Vault); Spotter's Barbell (E, Beefcake clock); Glass Jaw Gauntlets (E, +2 attack / -3 HP) | Dumpster Gloves (U, Dump quest later); Blade of Earned Reputation (E, rack, +1 attack); Flamethrower (E, rack, anti-token) | Grandma's Rolling Pin (E, Gourmand) ; Head Chef's Ladle (U, heal) | Sucker Punch Mitts (U); Gladiator's Net (E, arena 3) | Iron Knuckles (U); Colonel's Ladle (E); Clipwell's Shears (E) |
| Helm | Saucepan Helmet (C); X-Ray Goggles (U) | Champion's Laurels (U, arena 1) | Big Brain Beret (E, rack) | Head Chef's Toque (U) | Trash Panda Tiara (U, Refusemancer) | Crown of Mild Hubris (L); Bin Lid (U); Side-Hustle Headband (U) |
| Armor | Cardboard Cuirass (C); Solid Plate (U, Colorless) | Gainsmith's Lifting Belt (U, Beefcake); Protein Shaker Bandolier (U, Beefcake) | Paper-Plane Cape (U, Necrocrat Flying); Doggy Bag (U); Thorned Loincloth (U, rack) | Elastic Waistband (E, +1/+1 / 2 plays); Crowd-Pleaser's Cape (U, arena 2) | Mystery-Stain Bib (U, Refusemancer Toxic) | Pantry Apron (E) |
| Boots | Traveler's Boots (C) | Flip-Flops (C); Gotta-Go Galoshes (C, walking) | Hover Boots (U, rack) | - | Compost Boots (U) | Bloodsand Boots (U, the Marshal) |
| Relic | Extra Pocket (C); Participation Trophy (C); Lucky Sock (C) | Kettlebell Locket (U) | Red Tape Dispenser (U); Notarized Seal (U, Necrocrat); Dog-Eared Bookmark (U); Courier Lanyard (U); Compliance Clipboard (E); Cheater's Dice (U, rack); Overdue Library Book (E) | Velvet Rope (U, Gourmand) | Seed Satchel (E); Phial of First Water (L, secret) | Clerk's Stamp (U); Quota's Stopwatch (E); Plume's Quill (E); Four-Seal Signet (L); Siphon's Lens (E) |

Every slot has at least one upgrade and one sidegrade per zone from the Gainlands on (the Boots are the thin slot: the Buffet adds none;
inbox). Path identity: each Path has one buff piece (Bandolier / Seal / Rolling Pin / Tiara), one keyword piece (Headband / Cape / Rope /
Bib) and one resource piece (Locket / Dispenser / Doggy Bag / Gloves), plus the Capital's resource pieces.
