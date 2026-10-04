# Combat & Deck Rules (Locked Decisions)

Source of truth for game rules. `core/` implements this document; if code and this file
disagree, this file wins (or is deliberately updated first).

## Resources

- **Infrastructure** replaces lands. Infrastructure cards come in 4 types, one per **Path** (Beefcake,
  Gourmand, Refusemancer, Necrocrat - placeholder enum names **Affinity A-D**, see `Affinity` /
  `UIStyle`). Players **activate** (never "tap") an infrastructure to gain **one Path energy of its
  Path**. Casting a card activates the infrastructure that pays for it (chosen automatically, or
  explicitly via `GameState.cast`'s `activate_uids`).
- **Path energy** (formerly "mana"): a card costs generic Path energy (payable by any infrastructure)
  plus one **pip** per colored energy, each of which needs an infrastructure of that exact Path.
  A **multi-Path (dual-Path) card** has pips of two Paths and needs energy from both (Part F).
- Terminology: land -> infrastructure, mana -> Path energy, tap/untap -> activate/ready. For **creatures**
  the old "tapped" state is called **exhausted** (attacking creatures are exhausted until their
  controller's next ready step; see `docs/design/open_questions.md` M2). The engine field is
  `CardInstance.exhausted` for both.
- A deck may use at most **2** Paths in the main campaign (a multi-Path card counts as BOTH of its Paths).
  The flag `postgame_unlocked` raises this limit to **4**.
- **Neutral** cards cost generic Path energy and fit any deck. There is no neutral infrastructure.
- The player starts with the neutral starter deck only, using basic infrastructure of a chosen
  primary Path; see `docs/design/starting_deck_and_affinity.md`.

## Turn Structure

Start (ready, draw; the first player skips their first draw) → Main 1 → Combat → Main 2 → End.

- One infrastructure may be played per turn.
- Creatures have summoning sickness.
- Damage on creatures clears at end of turn.

## Combat

1. The attacker declares attackers.
2. The defender assigns at most one blocker per attacker.
3. Unblocked damage hits the player.

- Attacking creatures become **exhausted** and stay exhausted until their controller's next ready step,
  so they cannot block on the opponent's turn. **Vigilance** creatures do not exhaust when attacking.
- Each blocker blocks at most one attacker.
- **Guard**: while a defender controls a READY Guard creature, every attacker must attack a
  Guard creature instead of the player (unblocked damage lands on that Guard creature). An exhausted
  Guard creature does not force attacks — attackers may go past it at the player or at other
  legal targets as normal.

## No Interaction Windows

- No instants, no stack, no priority.
- Traps are set face-down on your turn and trigger automatically when their condition is met.
- A player may have at most **3** traps set at a time (a fourth cannot be cast until one has
  sprung). This cap is a base stat like max hand size, not a hard limit: dungeon rules, equipment
  or the final dungeon can raise it (`Modifier.Kind.MAX_TRAPS`).

## Win / Lose

- A player loses when their life reaches 0.
- A player also loses when they must draw from an empty deck.

## Player Stats (PlayerProfile)

Stats come from a `PlayerProfile` resource, never hardcoded.

| Stat | Value |
|------|-------|
| Max life | 10 at start, 25 at endgame |
| Opening hand | 5 to 8 cards |
| Max hand size | 10 |

Modifiers from equipment, items, and zones apply on top of the profile values.

## Progression (Part E)

Life, opening hand size, max hand size, item slots and equipment slot unlocks all advance with
the player's level (1-30), not fixed values - see `docs/design/progression.md` for the full,
generated level-by-level table and `core/data/progression_table.gd` for the source of truth. Every
encounter grants XP and gold scaled by `DungeonMap.Difficulty` (`EncounterRewards`).

## Deck Construction

- Minimum **45** cards, adjustable by `Modifier.Kind.MIN_DECK_SIZE` (e.g. the tutorial dungeon's
  starter-deck waiver - see "Starting deck" below).
- Maximum **4 copies of every non-infrastructure card, at every level** (rarity no longer matters).
  **Infrastructure is unlimited.** Copies beyond 4 owned convert into Path essence (Part F, see
  "Essence" below). The old rarity-based copy limits and the level-ups that raised them were
  removed; those levels grant other rewards (see `docs/design/progression.md`).

## Starting deck (Part C)

A new campaign's starter deck is **42 cards**: 23 colorless (neutral) non-infrastructure cards + 19 basic
infrastructure of the player's chosen Path - short of the normal 45-card minimum. A `MIN_DECK_SIZE`
modifier waives the minimum down to 42 for the whole tutorial dungeon only
(`TrialOfTheHollow.deck_size_waiver()`); the 3 tutorial reward picks (one per battle, restricted to
the player's own element on this first clear) bring the deck up to a real 45 cards by the time the
dungeon is cleared, at which point the waiver no longer applies. See
`docs/design/starting_deck_and_affinity.md` for the full flow.

## Rarity

Exactly four tiers, in ascending order: **Common, Uncommon, Epic, Legendary**
(`CardEnums.Rarity`). Rarity drives vendor pricing (`CardPricing`), the vendor's graduated
unlock thresholds (`VendorData.graduated`), reward-choice weighting (`RewardGenerator`, rarer
cards appear less often except the boss's table, which skews rarer) and the card frame's rarity
gem color/shape (`CardView.Gem` - a plain circle, diamond, hexagon and four-point sparkle,
respectively, so the tier reads even without the color).

## Dungeons

- Life carries over between encounters within a dungeon.
- The player is fully healed on entering a dungeon.

## Opening Hand: Hand Smoother (option)

When enabled (the default), the opening hand is drawn normally. If its infrastructure count is **more than
1 away** from the deck's infrastructure ratio (infrastructure count ÷ deck size × hand size), a second candidate
hand is generated and the one closer to that target is kept. The tolerance
(`GameOptions.smoother_tolerance`, default 1) is deliberately gentle: the smoother rescues
floods and screws but does not make every hand ideal.

## Mulligan

Each player gets **one free mulligan**.
