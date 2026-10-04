# Player Progression (Part E)

Levels 1-30. Generated from `core/data/progression_table.gd` by `tools/
generate_progression_doc.gd` - edit the table, not this file, then regenerate.

- **XP**: every encounter grants XP scaled by difficulty (`EncounterRewards`):
  Tutorial 15, Normal 30, Elite 60, Boss 120. The curve below is tuned so finishing
  the main story lands around **level 20**; levels 21-30 are postgame.
- **Starting life**: 10 at level 1, +1 on every even level, reaching **25 at level 30**
  (before equipment/item modifiers).
- **Opening hand size**: 5 at level 1, gradually up to **8** at level 24+.
- **Item slots**: 1 at level 1, gradually up to **4** at level 30.
- **Equipment slots** (Helm/Weapon/Armor/Boots/Relic): 0 at level 1; one is chosen
  and unlocked at levels 5, 10, 15, 20 and 25 - all five are unlocked by level 25.
- **Deck copy limit**: 4 copies of every non-infrastructure card at every level; infrastructure is unlimited.
  (The old rarity-based limits were removed - the levels that raised them now grant gold, vendor
  discounts, a bigger max hand size and a vendor-stock unlock instead.)
- **Max hand size**: 10, +1 at levels 14 and 28.
- Every level grants something: a real stat/slot/limit increase, an equipment choice,
  a vendor unlock/discount, or gold - New brief, Part D removed random card-choice
  level rewards entirely.

| Level | XP to reach | Life | Hand | Max hand | Items | Grants |
|---:|---:|---:|---:|---:|---:|---|
| 1 | 0 | 10 | 5 | 10 | 1 | Starting stats. |
| 2 | 30 | 11 | 5 | 10 | 1 | +1 starting life (11). |
| 3 | 90 | 11 | 5 | 10 | 1 | +65 gold. |
| 4 | 180 | 12 | 5 | 10 | 1 | +1 starting life (12). |
| 5 | 300 | 12 | 5 | 10 | 1 | Choose an equipment slot to unlock. |
| 6 | 450 | 13 | 5 | 10 | 1 | +1 starting life (13). +120 gold. Unlocks the second half of the item vendor's stock. |
| 7 | 630 | 13 | 5 | 10 | 1 | Permanent vendor discount +10%. |
| 8 | 840 | 14 | 6 | 10 | 1 | +1 starting life (14). Opening hand size +1 (6). |
| 9 | 1080 | 14 | 6 | 10 | 1 | Unlocks a small batch of rarer cards at the vendor. |
| 10 | 1350 | 15 | 6 | 10 | 2 | +1 starting life (15). +1 item slot (2). Choose an equipment slot to unlock. Unlocks the advanced equipment at the equipment vendor. |
| 11 | 1650 | 15 | 6 | 10 | 2 | Permanent vendor discount +10%. |
| 12 | 1980 | 16 | 6 | 10 | 2 | +1 starting life (16). |
| 13 | 2340 | 16 | 6 | 10 | 2 | +115 gold. |
| 14 | 2730 | 17 | 6 | 11 | 2 | +1 starting life (17). Max hand size +1 (11). |
| 15 | 3150 | 17 | 6 | 11 | 2 | Choose an equipment slot to unlock. |
| 16 | 3600 | 18 | 7 | 11 | 2 | +1 starting life (18). Opening hand size +1 (7). |
| 17 | 4080 | 18 | 7 | 11 | 2 | Unlocks a small batch of rarer cards at the vendor. |
| 18 | 4590 | 19 | 7 | 11 | 2 | +1 starting life (19). |
| 19 | 5130 | 19 | 7 | 11 | 2 | Permanent vendor discount +10%. |
| 20 | 5700 | 20 | 7 | 11 | 3 | +1 starting life (20). +1 item slot (3). Choose an equipment slot to unlock. |
| 21 | 5780 | 20 | 7 | 11 | 3 | +200 gold. |
| 22 | 5940 | 21 | 7 | 11 | 3 | +1 starting life (21). |
| 23 | 6180 | 21 | 7 | 11 | 3 | Unlocks a small batch of rarer cards at the vendor. |
| 24 | 6500 | 22 | 8 | 11 | 3 | +1 starting life (22). Opening hand size +1 (8). Permanent vendor discount +10%. |
| 25 | 6900 | 22 | 8 | 11 | 3 | Choose an equipment slot to unlock. |
| 26 | 7380 | 23 | 8 | 11 | 3 | +1 starting life (23). |
| 27 | 7940 | 23 | 8 | 11 | 3 | +185 gold. |
| 28 | 8580 | 24 | 8 | 12 | 3 | +1 starting life (24). Max hand size +1 (12). |
| 29 | 9300 | 24 | 8 | 12 | 3 | Permanent vendor discount +10%. |
| 30 | 10100 | 25 | 8 | 12 | 4 | +1 starting life (25). +1 item slot (4). |

## Level-up rewards (New brief, Part D)

Random card-choice level rewards were removed entirely - every level now grants only
real stat/slot/limit increases, an equipment-slot choice, gold, a permanent vendor
discount, or a vendor-stock unlock (see `PlayerProfile.vendor_discount_percent`/
`Session.effective_price()` - the discount actually reduces what every vendor charges,
not just what it displays). Two specific one-time unlocks, chosen to land "around when
the player has 1-2 equipment slots": level 10 unlocks the equipment vendor's 5 advanced
pieces (right alongside that level's own equipment-slot choice); level 6 unlocks the item
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
| Weapon | Basic | Wicked Dagger | A blade with a reputation it didn't earn honestly. Your creatures get +1 power. |
| Weapon | Advanced | Flamethrower | Alchemist's fire in a backpack tank. At the start of your turn, deal 1 damage to each opposing creature. |
| Relic | Basic | Extra Pocket | Sewn in where no one thinks to look. Max hand size +1. |
| Relic | Advanced | Cheater's Dice | They only ever land the way you need them to. You always go first, but your opening hand is 1 card smaller. |
| Boots | Basic | Traveler's Boots | Worn thin by roads longer than this one. Draw an extra card at the start of your first turn. |
| Boots | Advanced | Hover Boots | A finger's width of clearance, always. Your creatures have Flying but cannot block. |
| Armor | Basic | Solid Plate | Unglamorous, unyielding. Your creatures get +1 toughness. |
| Armor | Advanced | Thorned Loincloth | Nobody enjoys being the one who has to remove this from a corpse. Max life -5; whenever an enemy creature attacks you, it takes 1 damage. |
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
