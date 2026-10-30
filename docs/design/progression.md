# Player Progression (Part E)

Levels 1-30. Generated from `core/data/progression_table.gd` by `tools/
generate_progression_doc.gd` - edit the table, not this file, then regenerate.

- **XP**: every encounter grants XP scaled by difficulty (`EncounterRewards`):
  Tutorial 15, Normal 30, Elite 60, Boss 120. The curve below is tuned so finishing
  the main story lands around **level 20**; levels 21-30 are postgame.
- **Starting HP**: 10 at level 1, +1 on every even level, reaching **25 at level 30**
  (before equipment/item modifiers).
- **Opening hand size**: 5 at level 1, gradually up to **8** at level 24+.
- **Item slots**: 1 at level 1, gradually up to **4** at level 30.
- **Equipment slots** (Helm/Weapon/Armor/Boots/Relic): 0 at level 1; one is chosen
  and unlocked at levels 5, 10, 15, 20 and 25 - all five are unlocked by level 25.
- **Deck copy limit**: 4 copies of every non-infrastructure card at every level; infrastructure is unlimited.
  (The old rarity-based limits were removed - the levels that raised them now grant vendor
  discounts, a bigger max hand size, vendor-stock unlocks and the deck box expansion instead.)
- **Max hand size**: 10, +1 at levels 14 and 28.
- Every level grants something: a real stat/slot/limit increase, an equipment choice,
  a vendor unlock/discount or the deck box expansion. **Gold is never a level-up reward** (Brief 16);
  random card-choice level rewards were removed in an earlier brief.
- **Deck box**: 5 saved-deck slots from the start, **10 from level 7** ("Deck box expansion: 5 to 10 deck slots").

| Level | XP to reach | HP | Hand | Max hand | Items | Grants |
|---:|---:|---:|---:|---:|---:|---|
| 1 | 0 | 10 | 5 | 10 | 1 | Starting stats. |
| 2 | 30 | 11 | 5 | 10 | 1 | 60 gold. +1 starting HP (11). |
| 3 | 90 | 11 | 5 | 10 | 1 | Bowler Hat (cosmetic). 60 gold. |
| 4 | 180 | 12 | 5 | 10 | 1 | Beefcake Pack. +1 starting HP (12). |
| 5 | 300 | 12 | 5 | 10 | 1 | Wear up to 1 Epic piece of equipment. 120 gold. |
| 6 | 450 | 13 | 5 | 10 | 1 | Unlocks the second half of Tilly's stock. 100 gold. +1 starting HP (13). |
| 7 | 630 | 13 | 5 | 10 | 1 | Deck Station: 4 to 6 deck slots. General Pack. |
| 8 | 840 | 14 | 6 | 10 | 1 | Opening hand size +1 (6). 150 gold. +1 starting HP (14). |
| 9 | 1080 | 14 | 6 | 10 | 1 | Uncommon cards: up to 3 copies. Beefcake Pack. |
| 10 | 1350 | 15 | 6 | 10 | 2 | Wear up to 3 Uncommon pieces of equipment. +1 item slot (2). Patchwork Cloak (cosmetic). 150 gold. +1 starting HP (15). |
| 11 | 1650 | 15 | 6 | 10 | 2 | Permanent vendor discount +10%. 150 gold. |
| 12 | 1980 | 16 | 6 | 10 | 2 | Epic cards: up to 2 copies. Beefcake Pack. +1 starting HP (16). |
| 13 | 2340 | 16 | 6 | 10 | 2 | Wear up to 2 Epic pieces of equipment. Unlocks Bertram's advanced equipment rack. 200 gold. |
| 14 | 2730 | 17 | 6 | 11 | 2 | Deck Station: 6 to 8 deck slots. Max hand size +1 (11). General Pack, Tier II. +1 starting HP (17). |
| 15 | 3150 | 17 | 6 | 11 | 2 | Tricorn (cosmetic). 200 gold. |
| 16 | 3600 | 18 | 7 | 11 | 2 | Wear up to 5 Uncommon pieces of equipment. Opening hand size +1 (7). Beefcake Pack. +1 starting HP (18). |
| 17 | 4080 | 18 | 7 | 11 | 2 | Unlocks a small batch of rarer cards at Sable's stall. 250 gold. |
| 18 | 4590 | 19 | 7 | 11 | 2 | Legendary cards: up to 2 copies. Gilded Beefcake Pack. +1 starting HP (19). |
| 19 | 5130 | 19 | 7 | 11 | 2 | Wear up to 3 Epic pieces of equipment. 250 gold. |
| 20 | 5700 | 20 | 7 | 11 | 3 | +1 item slot (3). Beefcake Pack. 300 gold. +1 starting HP (20). |
| 21 | 5754 | 20 | 7 | 11 | 3 | Deck Station: 8 to 10 deck slots. Permanent vendor discount +10%. General Pack. |
| 22 | 5862 | 21 | 7 | 11 | 3 | Epic cards: up to 3 copies. Wear up to 1 Legendary piece of equipment. Gilded Beefcake Pack. +1 starting HP (21). |
| 23 | 6024 | 21 | 7 | 11 | 3 | 150 gold. Beefcake Pack. |
| 24 | 6240 | 22 | 8 | 11 | 3 | Opening hand size +1 (8). General Pack, Tier II. +1 starting HP (22). |
| 25 | 6510 | 22 | 8 | 11 | 3 | Wear up to 5 Epic pieces of equipment. Red Cape (cosmetic). 200 gold. |
| 26 | 6834 | 23 | 8 | 11 | 3 | 200 gold. Beefcake Pack. +1 starting HP (23). |
| 27 | 7212 | 23 | 8 | 11 | 3 | Unlocks a small batch of rarer cards at Sable's stall. Gilded Beefcake Pack. |
| 28 | 7644 | 24 | 8 | 12 | 3 | Wear up to 2 Legendary pieces of equipment. Max hand size +1 (12). 250 gold. +1 starting HP (24). |
| 29 | 8130 | 24 | 8 | 12 | 3 | 300 gold. Gilded Beefcake Pack. |
| 30 | 8670 | 25 | 8 | 12 | 4 | Legendary cards: up to 3 copies. +1 item slot (4). Prismatic Pack. Wizard Hat (cosmetic). +1 starting HP (25). |

## Level-up rewards (New brief, Part D)

Random card-choice level rewards were removed entirely - every level now grants only
real stat/slot/limit increases, an equipment-slot choice, the deck box expansion, a permanent vendor
discount, or a vendor-stock unlock (see `PlayerProfile.vendor_discount_percent`/
`Session.effective_price()` - the discount actually reduces what every vendor charges,
not just what it displays). Two specific one-time unlocks: level 13 unlocks the equipment vendor's 5 advanced
pieces (moved from level 10 in Brief 16 so that no level carries four rewards while others carry none); level 6 unlocks the item
vendor's second (advanced) half. Both are plain `Condition.player_level(...)` checks read
live against the profile - no flag to set, no save-data migration. The level-up popup
announces every reward explicitly (`LevelUpScreen._bonuses_for`).

## Equipment (New brief, Part B)

Built on the existing Modifier pipeline: `EquipmentData` (slot + Modifiers, IS a
`ModifierSource`) - see `core/data/modifier.gd` for every Modifier.Kind this brief added
(START_OF_TURN_EFFECT, ALWAYS_FIRST, FIRST_TURN_EXTRA_DRAW, GRANT_KEYWORD_TO_CREATURES,
CANNOT_BLOCK, MAX_NON_LAND_CASTS_PER_TURN, REVEAL_OPPONENT_HAND, RETALIATE_ON_ATTACK) and
`tests/core/game/test_equipment_modifiers.gd` for their engine coverage. 10 real pieces
replace the original 5 placeholders - one "basic" (tier 1, at the equipment vendor from the
start) and one "advanced" (tier 2, locked behind a level-up reward, see the table above and
`EquipmentData.advanced`) per slot:

| Slot | Tier | Piece | Effect |
|---|---|---|---|
| Weapon | Basic | Wicked Dagger | A blade with a reputation it didn't earn honestly. Your Colorless units get +1 attack. |
| Weapon | Advanced | Flamethrower | Alchemist's fire in a backpack tank. At the start of your turn, deal 1 damage to each opposing unit. |
| Relic | Basic | Extra Pocket | Sewn in where no one thinks to look. Max hand size +1. |
| Relic | Advanced | Cheater's Dice | They only ever land the way you need them to. You always go first, but your opening hand is 1 card smaller. |
| Boots | Basic | Traveler's Boots | Worn thin by roads longer than this one. Draw an extra card at the start of your first turn. |
| Boots | Advanced | Hover Boots | A finger's width of clearance, always. Your units have Flying but cannot block. |
| Armor | Basic | Solid Plate | Unglamorous, unyielding. Your Colorless units get +1 defense. |
| Armor | Advanced | Thorned Loincloth | Nobody enjoys being the one who has to remove this from a corpse. Max HP -5; whenever an enemy unit attacks you, it takes 1 damage. |
| Helm | Basic | X-Ray Goggles | Everything looks the same underneath. The opponent's hand is revealed to you - never a set trap. |
| Helm | Advanced | Big Brain Beret | It itches, but it's undeniably working. Draw an extra card each turn, but you can play only one non-infrastructure card per turn. |

Prices live on the (Part C) equipment vendor's stock entries, not on `EquipmentData` itself -
same pattern as items (`ItemVendorEntry`, D75) rather than duplicating economy data onto the
content resource.

## Items (placeholders)

`ItemData` (limited `uses` + one `EffectData`, resolved outside a duel by `ItemUseResolver` -
see docs/design/open_questions.md for why). Three items prove equip/use work end to end (10
more consumables were added in the third brief's Part F, see `docs/progress.md`):

| Item | Uses | Effect |
|---|---:|---|
| Healing Draught | 3 | A common camp remedy. |
| Reckless Tonic | 1 | One big gulp - use it wisely, there is only one. |
| Vitality Charm | 2 | A small, steady comfort. |
