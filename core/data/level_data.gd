class_name LevelData
extends Resource
## One row of the level table (Part E) - absolute values at this level, not deltas, so any
## screen can just read `LevelData` for the player's current level. `ProgressionTable.build()` is
## the one place that computes the whole table; see docs/design/progression.md for the printed
## version of it.

@export var level: int = 1
## Cumulative XP needed to be at this level (0 for level 1).
@export var xp_to_reach: int = 0
@export var max_life: int = 10
@export var opening_hand_size: int = 5
@export var item_slots: int = 1
## Maximum hand size at this level (10, +1 at levels 14 and 28 - replaces the old rarity copy-limit rewards).
@export var max_hand_size: int = 10
## True on levels 5/10/15/20/25: an equipment slot choice screen is shown.
@export var equipment_choice: bool = false
## Filler reward for a level that would otherwise grant nothing new (Part E: "something must
## happen at every level up"). At most one of these three is set. New brief, Part D: random
## card-choice rewards were removed entirely (`reward_card_choice` used to be the third option
## here) - `reward_vendor_discount_percent` replaces it with a permanent, meaningful non-card
## reward instead.
@export var reward_gold: int = 0
@export var reward_vendor_discount_percent: int = 0
@export var reward_vendor_unlock: String = ""
## New brief, Part D: two specific, one-time level rewards (not filler - layered on top of
## whatever else that level already grants) - see ProgressionTable.EQUIPMENT_VENDOR_UNLOCK_LEVEL/
## ITEM_VENDOR_ADVANCED_UNLOCK_LEVEL.
@export var reward_equipment_vendor_unlock: bool = false
@export var reward_item_vendor_advanced_unlock: bool = false
## One-line human-readable summary of everything this level grants (level-up screen + the doc
## table share this exact text).
@export var summary: String = ""
