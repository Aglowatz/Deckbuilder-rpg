# Items - Nov 3 (overnight Nov 2-3, Part 2: the designer's answers)

Everything else from docs/design/items_nov2.md stays (Scroll of Insight Draw 1 at 45, the high shelf at level 17).

## Field Bandage -> Power Wraps

Same effect (one of your units +0/+2 for the rest of the battle; three uses, one per battle), same price (30 gold, the weak band), same
icon (delapouite/hand-bandage). The id is now `power_wraps` everywhere (ProgressionContent, data/items/power_wraps.tres, the item vendor's
stock, the Capital's wreck chest and the chest-value table, CardIcons, item_sim, tests). **Old saves**: `ContentSet.ITEM_RENAMES`
(`field_bandage` -> `power_wraps`) - `ContentSet.item()` and the equipped-item ids read from a save go through `current_item_id`, so a save
holding the Field Bandage (owned, uses left, equipped) loads it as Power Wraps.

## Reckless Tonic - it may backfire

30 gold, one use: heals 5 HP, **or 1 in 4 times deals 1 damage to you instead**. The description says both outcomes and the odds:
"You heal 5 HP in one big gulp - but 1 in 4 times it backfires and deals 1 damage to you instead. One use."

- Data: `ItemData.backfire_chance` / `backfire_damage` (0 / 0 for every other item); `ProgressionContent.TONIC_BACKFIRE_CHANCE` 0.25.
- In a duel: `GameState.use_item` rolls the duel's seeded RNG; a backfire deals the damage to the user through `deal_damage_to_player`
  (the board's damage number), spends the use and sets `last_item_backfired`; the battle screen plays `hit_light` and toasts "The Reckless
  Tonic backfires! You take 1 damage instead."
- Between fights (the character screen): `ItemUseResolver.apply(item, run, roll)`; a backfire costs the run 1 HP, `last_backfired` drives the
  same toast (red) and sound.
- Odds by sim (`tools/item_sim.gd --filter=zone:beefcake --level=6 --games=24 --variants=tonic`, docs/design/sim/items_nov3_tonic.md):

| Variant | Win % | Lift | HP left on wins |
|---|---:|---:|---:|
| (no item) | 85.9 | - | 16.90 |
| Tonic, never backfires | 88.5 | +2.6 | 18.12 |
| Tonic, 1 in 6 | 89.1 | +3.1 | 18.58 |
| **Tonic, 1 in 4** | 88.5 | +2.6 | 18.42 |
| Tonic, 1 in 3 | 91.7 | +5.7 | 17.91 |
| Vitality Charm (2 HP x 2) | 90.1 | +4.2 | 18.01 |

  Every odds from 1 in 6 to 1 in 3 sits with the Vitality Charm inside the sim's noise (a 1-HP backfire rarely decides a fight); expected
  healing 3.5 HP against the charm's 4 over its two uses, so the default 1 in 4 keeps the two at the same value and the tonic reads as the
  gamble it is named for.
- Tests: tests/core/data/test_items_nov3.gd (seeded heal and backfire in a duel, both rolls outside one, the description's numbers, no
  other item backfires, the rename and the old-save alias).
