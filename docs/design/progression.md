# Player Progression (Part E)

Levels 1-30. Generated from `core/data/progression_table.gd` by `tools/
generate_progression_doc.gd` - edit the table, not this file, then regenerate.

- **XP**: every encounter grants XP scaled by difficulty (`EncounterRewards`):
  Tutorial 15, Normal 30, Elite 60, Boss 120. XP Pass Oct 30: the curve below is re-based on the XP the story really
  pays (`tools/economy_model.gd`, the level timeline): the expected player is about L5 at the Gainlands, L8 in the House of Gains,
  L14 at the Test Kitchen boss, L18-19 when the Dump is freed and **L22 at Primm**; 23-30 is a postgame climb (L25 for the expected
  player after the postgame, ~L28 for the thorough one, 30 for the completionist). Every level costs more than the last.
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
| 1 | 0 | 15 | 5 | 10 | 2 | Starting stats. |
| 2 | 50 | 16 | 5 | 10 | 2 | 60 gold. +1 starting HP (16). |
| 3 | 120 | 16 | 5 | 10 | 2 | Bowler Hat (cosmetic). 60 gold. |
| 4 | 200 | 17 | 5 | 10 | 2 | Beefcake Pack. +1 starting HP (17). |
| 5 | 300 | 17 | 5 | 10 | 2 | 120 gold. |
| 6 | 580 | 18 | 5 | 10 | 3 | +1 item slot (3). 85 gold. +1 starting HP (18). |
| 7 | 880 | 18 | 5 | 10 | 3 | Deck Station: 4 to 6 deck slots. General Pack. |
| 8 | 1220 | 19 | 6 | 10 | 3 | Opening hand size +1 (6). 130 gold. +1 starting HP (19). |
| 9 | 1600 | 19 | 6 | 10 | 3 | Uncommon cards: up to 3 copies. Beefcake Pack. |
| 10 | 2025 | 20 | 6 | 10 | 3 | Patchwork Cloak (cosmetic). 130 gold. +1 starting HP (20). |
| 11 | 2460 | 20 | 6 | 10 | 3 | Permanent vendor discount +10%. 130 gold. |
| 12 | 2905 | 21 | 6 | 10 | 4 | Epic cards: up to 2 copies. +1 item slot (4). Beefcake Pack. +1 starting HP (21). |
| 13 | 3360 | 21 | 6 | 10 | 4 | Unlocks Bertram's advanced equipment rack. 170 gold. |
| 14 | 3825 | 22 | 6 | 10 | 4 | Deck Station: 6 to 8 deck slots. General Pack, Tier II. +1 starting HP (22). |
| 15 | 4300 | 22 | 6 | 10 | 4 | Tricorn (cosmetic). 170 gold. |
| 16 | 4785 | 23 | 7 | 10 | 4 | Opening hand size +1 (7). Beefcake Pack. +1 starting HP (23). |
| 17 | 5280 | 23 | 7 | 10 | 4 | Unlocks a small batch of rarer cards at Sable's stall. Unlocks the second half of Tilly's stock. 215 gold. |
| 18 | 5785 | 24 | 7 | 10 | 4 | Legendary cards: up to 2 copies. Gilded Beefcake Pack. +1 starting HP (24). |
| 19 | 6300 | 24 | 7 | 10 | 4 | 215 gold. |
| 20 | 6825 | 25 | 7 | 10 | 4 | Beefcake Pack. 255 gold. +1 starting HP (25). |
| 21 | 7360 | 25 | 7 | 10 | 4 | Deck Station: 8 to 10 deck slots. Permanent vendor discount +10%. General Pack. |
| 22 | 7930 | 26 | 7 | 10 | 4 | Epic cards: up to 3 copies. Gilded Beefcake Pack. +1 starting HP (26). |
| 23 | 8535 | 26 | 7 | 10 | 4 | 130 gold. Beefcake Pack. |
| 24 | 9175 | 27 | 8 | 10 | 4 | Opening hand size +1 (8). General Pack, Tier II. +1 starting HP (27). |
| 25 | 9850 | 27 | 8 | 10 | 4 | Red Cape (cosmetic). 170 gold. |
| 26 | 10560 | 28 | 8 | 10 | 4 | 170 gold. Beefcake Pack. +1 starting HP (28). |
| 27 | 11305 | 28 | 8 | 10 | 4 | Unlocks a small batch of rarer cards at Sable's stall. Gilded Beefcake Pack. |
| 28 | 12085 | 29 | 8 | 10 | 4 | 215 gold. Beefcake Pack. +1 starting HP (29). |
| 29 | 12900 | 29 | 8 | 10 | 4 | 255 gold. Gilded Beefcake Pack. |
| 30 | 13750 | 30 | 8 | 10 | 4 | Legendary cards: up to 3 copies. Prismatic Pack. Wizard Hat (cosmetic). +1 starting HP (30). |

## Level-up rewards (New brief, Part D)

Random card-choice level rewards were removed entirely - every level now grants only
real stat/slot/limit increases, an equipment-slot choice, the deck box expansion, a permanent vendor
discount, or a vendor-stock unlock (see `PlayerProfile.vendor_discount_percent`/
`Session.effective_price()` - the discount actually reduces what every vendor charges,
not just what it displays). Two specific one-time unlocks: level 13 unlocks the equipment vendor's 5 advanced
pieces (moved from level 10 in Brief 16 so that no level carries four rewards while others carry none); level 17 unlocks the item
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

## Dungeon-clear XP bonus (Fable pass Nov 1, Part 3)

A dungeon's FIRST clear pays XP scaled with its tier (`DungeonClearBonus`): the tier is the level the progression model expects there
(`ProgressionModel.LEVELS`), and the bonus is a fraction of what the next level costs at that tier (`ProgressionTable.xp_step`), so it keeps
pace with the curve by itself. Main dungeons pay 0.5 of a level (D-HOG 190, D-HFA 225, D-TTK 240, D-ROT 255; was a flat 160) on top of the
pack config's flat 100 and the Gilded Pack; side dungeons pay 0.15 of a level (S-IRON 45 .. S-CAP 80, S-BEEF / S-PASTE 90; they paid no XP).
Primm's Castle keeps its 400. Per-fight XP is unchanged. Timeline (`docs/design/sim/economy_model.md`): the expected player arrives at the
Dump at 18 (model 17; was 17) and at the castle at 22 (model 21; was 21); the rusher is unchanged until the Capital (15); the thorough player
is +1 (the Dump at 20, the castle at 25). Fractions 0.6 / 0.35 over-levelled the expected player by two at the Dump and were dropped.
