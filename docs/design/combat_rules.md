# Combat & Deck Rules (Locked Decisions)

Source of truth for game rules. `core/` implements this document; if code and this file
disagree, this file wins (or is deliberately updated first).

## Resources

- Land cards come in 4 types, placeholder names **Affinity A–D**. They are defined in a
  single enum (e.g. `Affinity`) so they can be renamed in one place later.
- A deck may use at most **2** land/color types in the main campaign. The flag
  `postgame_unlocked` raises this limit to **4**.
- **Neutral** cards cost generic mana and fit any deck. There is no neutral land.
- The player starts with the neutral starter deck only, using basic lands of a chosen primary
  color; see `docs/design/starting_deck_and_affinity.md`.

## Turn Structure

Start (untap, draw; the first player skips their first draw) → Main 1 → Combat → Main 2 → End.

- One land may be played per turn.
- Creatures have summoning sickness.
- Damage on creatures clears at end of turn.

## Combat

1. The attacker declares attackers.
2. The defender assigns at most one blocker per attacker.
3. Unblocked damage hits the player.

- Attacking creatures tap and stay tapped until their controller's next untap, so they cannot
  block on the opponent's turn. **Vigilance** creatures do not tap when attacking.
- Each blocker blocks at most one attacker.
- **Guard**: while a defender controls a Guard creature, every attacker must attack a Guard creature
  instead of the player (unblocked damage lands on that Guard creature).

## No Interaction Windows

- No instants, no stack, no priority.
- Traps are set face-down on your turn and trigger automatically when their condition is met.

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

## Deck Construction

- Minimum **45** cards.
- Maximum **3** copies of any card (basic lands are exempt).

## Dungeons

- Life carries over between encounters within a dungeon.
- The player is fully healed on entering a dungeon.

## Opening Hand: Hand Smoother (option)

When enabled (the default), the opening hand is drawn normally. If its land count is **more than
1 land away** from the deck's land ratio (land count ÷ deck size × hand size), a second candidate
hand is generated and the one closer to that target is kept. The tolerance
(`GameOptions.smoother_tolerance`, default 1) is deliberately gentle: the smoother rescues
floods and screws but does not make every hand ideal.

## Mulligan

Each player gets **one free mulligan**.
