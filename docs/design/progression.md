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
- **Deck copy limits by rarity**: Common/Uncommon start at 3, Epic at 2, Legendary at
  1; each increases gradually until every rarity allows **4 copies**.
- Every level grants something: a real stat/slot/limit increase, an equipment choice,
  or (when none of those land) gold, a card choice, or a vendor-stock unlock.

| Level | XP to reach | Life | Hand | Items | Common | Uncommon | Epic | Legendary | Grants |
|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| 1 | 0 | 10 | 5 | 1 | 3 | 3 | 2 | 1 | Starting stats. |
| 2 | 30 | 11 | 5 | 1 | 3 | 3 | 2 | 1 | +1 starting life (11). |
| 3 | 90 | 11 | 5 | 1 | 3 | 3 | 2 | 1 | +65 gold. |
| 4 | 180 | 12 | 5 | 1 | 3 | 3 | 2 | 1 | +1 starting life (12). |
| 5 | 300 | 12 | 5 | 1 | 3 | 3 | 2 | 1 | Choose an equipment slot to unlock. |
| 6 | 450 | 13 | 5 | 1 | 4 | 3 | 2 | 1 | +1 starting life (13). Common deck copy limit +1 (4). |
| 7 | 630 | 13 | 5 | 1 | 4 | 3 | 2 | 1 | Choose 1 of 3 cards to add to your collection. |
| 8 | 840 | 14 | 6 | 1 | 4 | 3 | 2 | 1 | +1 starting life (14). Opening hand size +1 (6). |
| 9 | 1080 | 14 | 6 | 1 | 4 | 3 | 2 | 1 | Unlocks a small batch of rarer cards at the vendor. |
| 10 | 1350 | 15 | 6 | 2 | 4 | 3 | 2 | 1 | +1 starting life (15). +1 item slot (2). Choose an equipment slot to unlock. |
| 11 | 1650 | 15 | 6 | 2 | 4 | 4 | 2 | 1 | Uncommon deck copy limit +1 (4). |
| 12 | 1980 | 16 | 6 | 2 | 4 | 4 | 2 | 1 | +1 starting life (16). |
| 13 | 2340 | 16 | 6 | 2 | 4 | 4 | 2 | 1 | Choose 1 of 3 cards to add to your collection. |
| 14 | 2730 | 17 | 6 | 2 | 4 | 4 | 3 | 1 | +1 starting life (17). Epic deck copy limit +1 (3). |
| 15 | 3150 | 17 | 6 | 2 | 4 | 4 | 3 | 1 | Choose an equipment slot to unlock. |
| 16 | 3600 | 18 | 7 | 2 | 4 | 4 | 3 | 1 | +1 starting life (18). Opening hand size +1 (7). |
| 17 | 4080 | 18 | 7 | 2 | 4 | 4 | 3 | 2 | Legendary deck copy limit +1 (2). |
| 18 | 4590 | 19 | 7 | 2 | 4 | 4 | 3 | 2 | +1 starting life (19). |
| 19 | 5130 | 19 | 7 | 2 | 4 | 4 | 3 | 2 | +145 gold. |
| 20 | 5700 | 20 | 7 | 3 | 4 | 4 | 3 | 2 | +1 starting life (20). +1 item slot (3). Choose an equipment slot to unlock. |
| 21 | 5780 | 20 | 7 | 3 | 4 | 4 | 4 | 2 | Epic deck copy limit +1 (4). |
| 22 | 5940 | 21 | 7 | 3 | 4 | 4 | 4 | 2 | +1 starting life (21). |
| 23 | 6180 | 21 | 7 | 3 | 4 | 4 | 4 | 2 | Unlocks a small batch of rarer cards at the vendor. |
| 24 | 6500 | 22 | 8 | 3 | 4 | 4 | 4 | 3 | +1 starting life (22). Opening hand size +1 (8). Legendary deck copy limit +1 (3). |
| 25 | 6900 | 22 | 8 | 3 | 4 | 4 | 4 | 3 | Choose an equipment slot to unlock. |
| 26 | 7380 | 23 | 8 | 3 | 4 | 4 | 4 | 3 | +1 starting life (23). |
| 27 | 7940 | 23 | 8 | 3 | 4 | 4 | 4 | 3 | +185 gold. |
| 28 | 8580 | 24 | 8 | 3 | 4 | 4 | 4 | 4 | +1 starting life (24). Legendary deck copy limit +1 (4). |
| 29 | 9300 | 24 | 8 | 3 | 4 | 4 | 4 | 4 | Choose 1 of 3 cards to add to your collection. |
| 30 | 10100 | 25 | 8 | 4 | 4 | 4 | 4 | 4 | +1 starting life (25). +1 item slot (4). |

## Equipment and items (placeholders)

Built on the existing Modifier pipeline: `EquipmentData` (slot + Modifiers, IS a
`ModifierSource`) and `ItemData` (limited `uses` + one `EffectData`, resolved outside a
duel by `ItemUseResolver` - see docs/design/open_questions.md for why). Five equipment
pieces and three items prove equip/unequip/use work end to end:

| Slot | Piece | Effect |
|---|---|---|
| Helm | Scavenger's Helm | A dented helm that still turns a blade. Sharpens focus: one more card in your opening hand. |
| Weapon | Worn Blade | Notched from use, never from failure. Your creatures hit a little harder. |
| Armor | Padded Vest | Thick enough to matter, light enough to forget you're wearing it. +3 max life. |
| Boots | Quick Boots | Light feet, faster starts. One more card in your opening hand. |
| Relic | Minor Relic | A shard of something older than the Hollow. Your spells cost a little less. |

| Item | Uses | Effect |
|---|---:|---|
| Healing Draught | 3 | A common camp remedy. |
| Reckless Tonic | 1 | One big gulp - use it wisely, there is only one. |
| Vitality Charm | 2 | A small, steady comfort. |
