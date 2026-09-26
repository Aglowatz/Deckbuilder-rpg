# Combat & Deck Rules (Locked Decisions)

Source of truth for game rules. `core/` implements this document; if code and this file
disagree, this file wins (or is deliberately updated first).

## Resources

- Land cards come in 4 types, placeholder names **Affinity A–D**. They are defined in a
  single enum (e.g. `Affinity`) so they can be renamed in one place later.
- A deck may use at most **2** land/color types in the main campaign. The flag
  `postgame_unlocked` raises this limit to **4**.
- **Neutral** cards cost generic mana and fit any deck.

## Turn Structure

Start (untap, draw; the first player skips their first draw) → Main 1 → Combat → Main 2 → End.

- One land may be played per turn.
- Creatures have summoning sickness.
- Damage on creatures clears at end of turn.

## Combat

1. The attacker declares attackers.
2. The defender assigns at most one blocker per attacker.
3. Unblocked damage hits the player.

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

When enabled, drawing the opening hand generates **2 candidate hands** and keeps the one
whose land count is closest to the deck's land ratio (land count ÷ deck size × hand size).

## Mulligan

Each player gets **one free mulligan**.
