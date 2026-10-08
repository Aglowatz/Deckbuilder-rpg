# Essence, the Alchemist and multi-Path cards (brief 9, Part F)

Source: `docs/design/story_source.md` ("Alchemist and crafting cards"). Code: `core/data/essence.gd`,
`core/data/alchemy.gd`, `core/data/multipath_content.gd`, `ui/town/alchemist_screen.gd`, `app/toast_layer.gd`.

## Essence

A player may own at most **4 copies of a card** (`DeckValidator.MAX_COPIES`; infrastructure is unlimited). Whenever a
card is gained from ANY source (`Session.add_cards`: rewards, vendors, chests, quests, dungeon treasure, crafting) and
the player already owns 4, the extra copy is **not kept**. It converts automatically:

| Extra copy of... | Becomes |
|---|---|
| a Path card | **Path essence** of that Path: Common 1, Uncommon 2, Epic 4, Legendary 8 (`Essence.VALUE_BY_RARITY`) |
| a multi-Path card | the same value split between its two Paths (half each, first Path rounded up) |
| a **neutral** card | **gold** instead (no Path to belong to): Common 15, Uncommon 30, Epic 60, Legendary 120 (logged as M11) |
| infrastructure | nothing: it is unlimited |

Every conversion fires `EventBus.essence_converted(message, essence, gold)`; the global `ToastLayer` (a CanvasLayer
above every scene) shows it ("Extra copy of Firebolt converted into 2 Beefcake essence."), so it appears in town, zones,
dungeons, the rewards screen and battles. Essence totals are shown on the **Character screen** ("Path essence: Beefcake 12,
...") and in the **Alchemist UI**. `PlayerProfile.essence` is saved (`"essence"` in the save).

## The Alchemist (Auntie Alembic)

A crafting vendor in Crosspath, **locked until 2 zones are completed** (`ZoneCompletion.ALCHEMIST_UNLOCK_COUNT`):
the building is visible, shuttered ("CLOSED (until two zones are free)") and the door gives a hint. When the player has
at least **10 essence (`Alchemy.MIN_ESSENCE_PER_PATH`) of two different Paths** they may trade **ALL of their essence of
those two Paths + 100 gold** for **one random dual-Path card** of those two Paths (4 cards per pair, one of each
rarity). The more essence traded beyond the minimum, the better the odds of Epic and Legendary
(`Alchemy.weights_for`). The UI lists the four possible cards with their odds, then plays a brewing animation (a shaking
cauldron, motes of both Path colors spiralling in, a flash) before the card rises out of the pot. The craft button is disabled
(with the reason) until the trade is possible.

**Postgame hook:** `Alchemy.tri_path_unlocked(profile)` is `PlayerProfile.postgame_unlocked` (set by beating the main
story's final boss, not implemented yet) and `Alchemy.max_craft_paths` returns 3 then; `Alchemy.tri_path_cards` returns nothing
because no tri-/quad-Path cards exist yet.

## Multi-Path (dual-Path) cards

24 cards: **4 for each of the 6 Path pairs** (a Common unit, an Uncommon spell, an Epic and a Legendary unit
per pair), defined in `MultipathContent`, saved in `data/cards/multipath/`. They are only obtainable by crafting (never in
vendors, rewards or the general Codex list).

- **Data**: `CardData.color2` (the second Path; `is_multipath()`, `paths()`, `is_on_path()`).
- **Cost**: pips of BOTH Paths (plus generic), so the card needs energy from both: `PathEnergy` already pays each pip
  from an infrastructure of that exact Path (tested), the AI plays the infrastructure its hand needs and plays the card once both
  are out (tested).
- **Deck rules**: a dual card counts as **both** Paths for the 2-Path deck limit (4 after the postgame flag): `Deck.colors()`,
  `DeckValidator`, and the deck builder (`DeckEditor.why_not_add`: "needs both of its Paths..."). The 4-copy limit applies.
- **Modifiers**: zone effects and equipment aimed at either Path affect it (`Modifier.matches_card`): a Beefcake/Necrocrat
  unit in the Gainlands gets Pump It Up AND enters exhausted from Processing Time.
- **Frame visuals** (`CardView`): a second inner border in the other Path's color, a two-color name bar, a two-color art
  gradient, two Path gems in the art's corner, "Beefcake + Necrocrat - Unit" on the type line, both pip colors in the cost row,
  and long names wrap to two lines.
- The card filter bar (by Path) lists a dual card under both of its Paths.

Tests: `tests/core/data/test_essence_alchemy.gd`.
