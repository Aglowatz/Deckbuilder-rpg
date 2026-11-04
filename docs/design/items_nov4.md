# Items - single-use charges, four slots, prices (Overnight Nov 3-4, Parts A7 + B1-B4)

## Rules

- **Single-use charges.** Every consumable is one use (`ItemData.uses = 1`). Buying one adds one charge (`Session.add_item(item, 1)`); a
  chest / quest / arena reward also adds one charge. Using an item in battle spends one charge for good (`PlayerProfile.spend_item_charge`);
  at 0 charges the item leaves the inventory and its slot empties. Owning more charges than are equipped is fine: the Character page's
  inventory shows every item with its charge count. Each equipped item still works once per battle.
- **Four positional slots** (`PlayerProfile.equipped_item_ids[i]` = slot i+1, "" = empty): slots 1-2 from the start, slot 3 at level 6,
  slot 4 at level 12 (`data/progression/level_track.json` `stats.item_slots_start = 2`, `stats.item_slots = [6, 12]`). Locked slots read
  "Level N unlock" on the Character page. Before: 1 slot, +1 at levels 10, 20, 30.
- **Save migration** (`PlayerProfile.normalize_item_slots`, on load and on every level applied): unknown / unowned / doubled entries drop;
  every equipped item that fits stays; an item in a slot that is locked now moves into a free unlocked slot. Old saves keep their charges
  (a 3-use Salve bought before tonight is 3 charges). The old `healing_draught` id maps to `energy_draught` (`ContentSet.ITEM_RENAMES`).
- **Energy Draught** (was the Healing Draught, same bottle art via `IconArt.ITEM_ART_ALIASES`): "Choose a Path in your deck: gain 1 energy
  of that Path this turn." `CardEnums.EffectOp.ADD_ENERGY`; the battle screen asks which Path (only the Paths of the deck you brought,
  `GameState.item_path_choices`; one Path = no question) and adds one floating energy of it (`PlayerState.pool`, empties at end of turn).
  It heals nothing, is not food (the Capital's Famine does not block it) and cannot be used outside a battle.

## Prices (one charge each)

| Item | Effect | Shelf | Before (for 1-3 uses) | Now (per charge) |
|---|---|---|---:|---:|
| Reckless Tonic | heal 5, 1 in 4 backfires | regular | 30 (1 use) | **50** |
| Vitality Charm | heal 2 | regular | 30 (2 uses) | **50** |
| Power Wraps | a unit +0/+2 for the battle | regular | 30 (3 uses) | **60** |
| Healing Salve | heal 4 | regular | 60 (3 uses) | **70** |
| Scroll of Insight | draw 1 | regular | 45 (2 uses) | **80** |
| Sharpening Stone | a unit +2/+2 this turn | regular | 45 (3 uses) | **80** |
| Energy Draught | +1 energy of a deck Path this turn | regular | 45 (Healing Draught, 3 uses) | **100** |
| Firebrand Charm | 2 damage to an enemy unit | regular | 45 (2 uses) | **100** |
| Binding Chains | return an enemy unit to hand | high shelf (L17) | 90 (2 uses) | **150** |
| Silence Powder | opponent tosses 2 random cards | high shelf (L17) | 60 (2 uses) | **150** |
| Grave Dust | opponent buries 6 | high shelf (L17) | 45 (2 uses) | **150** |
| Summoning Charm | three 1/1 Militia | high shelf (L17) | 90 (1 use) | **150** |
| Ward Sigil | a unit gains Untouchable this turn | high shelf (L17) | 60 (2 uses) | **150** |

The spread on the regular shelf follows the Nov 2 sim (docs/design/items_nov2.md: Draw 1 and the Stone and the Firebrand are the strongest
regular items; the heals and the Wraps the weakest). Source of truth: `Economy.ITEM_PRICES` (core/data/economy.gd); the shop reads it
(`ItemVendorScreen.default_stock`). The Secret Dealer's black-market list keeps its own prices (Energy Draught 40 -> 90 there).
