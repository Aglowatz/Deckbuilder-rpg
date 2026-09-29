class_name ProgressionTable
extends RefCounted
## The full level 1-30 table (Part E): one place that computes every level's stats and what it
## grants, so `PlayerProfile` levels always read from the same source of truth as the printed
## table in docs/design/progression.md (regenerate it with tools/generate_progression_doc.gd
## after changing anything here).

const MAX_LEVEL: int = 30
## Levels that hand out an equipment slot choice (Part E: one per level, 5 slots total).
const EQUIPMENT_CHOICE_LEVELS: Array[int] = [5, 10, 15, 20, 25]
## Levels where a rarity's max deck copies increases by 1, in the order the brief lists rarities
## (Common/Uncommon start at 3, Epic at 2, Legendary at 1 - all reach 4 by level 28, well before
## the postgame levels 21-30 begin at 21, except Legendary's last step, deliberately the latest
## since it is the rarest tier - see docs/design/open_questions.md).
const COPY_LIMIT_STEPS: Dictionary = {
	6: CardEnums.Rarity.COMMON,
	11: CardEnums.Rarity.UNCOMMON,
	14: CardEnums.Rarity.EPIC,
	17: CardEnums.Rarity.LEGENDARY,
	21: CardEnums.Rarity.EPIC,
	24: CardEnums.Rarity.LEGENDARY,
	28: CardEnums.Rarity.LEGENDARY,
}
const STARTING_COPY_LIMITS: Dictionary = {
	CardEnums.Rarity.COMMON: 3, CardEnums.Rarity.UNCOMMON: 3,
	CardEnums.Rarity.EPIC: 2, CardEnums.Rarity.LEGENDARY: 1,
}
## Opening hand size increases at these levels (5 -> 8 over 3 steps).
const HAND_SIZE_LEVELS: Array[int] = [8, 16, 24]
## Item slots increase at these levels (1 -> 4 over 3 steps).
const ITEM_SLOT_LEVELS: Array[int] = [10, 20, 30]
## New brief, Part D: two one-time level-up rewards, each layered on top of that level's other
## gains (not filler). Level 10 already grants an equipment-slot choice (EQUIPMENT_CHOICE_LEVELS)
## - "around when the player has 1-2 equipment slots" per the brief, since level 5 grants the
## first slot. Level 6 reuses the item vendor's own former "late tier" threshold (D75).
const EQUIPMENT_VENDOR_UNLOCK_LEVEL: int = 10
const ITEM_VENDOR_ADVANCED_UNLOCK_LEVEL: int = 6
## New brief, Part D: a permanent vendor-discount filler reward, replacing the removed random
## card-choice filler (see LevelData.reward_vendor_discount_percent).
const FILLER_DISCOUNT_PERCENT: int = 10


static func build() -> Array[LevelData]:
	var rows: Array[LevelData] = []
	var copy_limits: Dictionary = STARTING_COPY_LIMITS.duplicate()
	for level: int in range(1, MAX_LEVEL + 1):
		var row: LevelData = LevelData.new()
		row.level = level
		row.xp_to_reach = xp_to_reach(level)
		row.max_life = PlayerProfile.START_MAX_LIFE + int(level / 2)
		row.opening_hand_size = PlayerProfile.MIN_OPENING_HAND + _steps_reached(level, HAND_SIZE_LEVELS)
		row.item_slots = 1 + _steps_reached(level, ITEM_SLOT_LEVELS)
		if COPY_LIMIT_STEPS.has(level):
			var rarity: CardEnums.Rarity = COPY_LIMIT_STEPS[level] as CardEnums.Rarity
			copy_limits[rarity] = int(copy_limits[rarity]) + 1
		row.copy_limits = copy_limits.duplicate()
		row.equipment_choice = EQUIPMENT_CHOICE_LEVELS.has(level)
		row.reward_equipment_vendor_unlock = level == EQUIPMENT_VENDOR_UNLOCK_LEVEL
		row.reward_item_vendor_advanced_unlock = level == ITEM_VENDOR_ADVANCED_UNLOCK_LEVEL
		rows.append(row)
	_fill_summaries_and_fallback_rewards(rows)
	return rows


## Which milestone list entries `level` has already passed (0 at/under the first entry).
static func _steps_reached(level: int, milestones: Array[int]) -> int:
	var steps: int = 0
	for milestone: int in milestones:
		if level >= milestone:
			steps += 1
	return steps


## Cumulative XP needed to reach `level`. Two segments: a gentler climb through the main story
## (levels 1-20, tuned so a player finishing it lands around there) and a steeper postgame grind
## (21-30) - see docs/design/open_questions.md for the reasoning, since no exact campaign length
## was given to calibrate against.
static func xp_to_reach(level: int) -> int:
	if level <= 1:
		return 0
	var capped: int = mini(level, 20)
	var total: int = 15 * capped * (capped - 1)
	if level > 20:
		total += 40 * (level - 20) * (level - 19)
	return total


## The level for a total XP amount, clamped to [1, MAX_LEVEL].
static func level_for_xp(total_xp: int) -> int:
	var level: int = 1
	for candidate: int in range(2, MAX_LEVEL + 1):
		if total_xp >= xp_to_reach(candidate):
			level = candidate
		else:
			break
	return level


static func row(level: int) -> LevelData:
	for candidate: LevelData in build():
		if candidate.level == level:
			return candidate
	return null


## Fills `summary` for every row and, for a level that would otherwise grant nothing new,
## assigns a small filler reward (Part E: "something must happen at every level up") - gold, a
## permanent vendor discount and a rarer-stock vendor unlock rotate (New brief, Part D: random
## card-choice rewards were removed from this rotation entirely). Levels
## EQUIPMENT_VENDOR_UNLOCK_LEVEL/ITEM_VENDOR_ADVANCED_UNLOCK_LEVEL get an extra, non-filler note
## on top of whatever else they already grant.
static func _fill_summaries_and_fallback_rewards(rows: Array[LevelData]) -> void:
	var filler_count: int = 0
	for i: int in range(rows.size()):
		var current: LevelData = rows[i]
		var previous: LevelData = rows[i - 1] if i > 0 else null
		var notes: Array[String] = []
		if previous == null:
			notes.append("Starting stats.")
		else:
			if current.max_life > previous.max_life:
				notes.append("+1 starting life (%d)." % current.max_life)
			if current.opening_hand_size > previous.opening_hand_size:
				notes.append("Opening hand size +1 (%d)." % current.opening_hand_size)
			if current.item_slots > previous.item_slots:
				notes.append("+1 item slot (%d)." % current.item_slots)
			for rarity: Variant in current.copy_limits.keys():
				if int(current.copy_limits[rarity]) > int(previous.copy_limits.get(rarity, 0)):
					notes.append("%s deck copy limit +1 (%d)." % [CardEnums.Rarity.keys()[int(rarity)].capitalize(), int(current.copy_limits[rarity])])
			if current.equipment_choice:
				notes.append("Choose an equipment slot to unlock.")
			if current.reward_equipment_vendor_unlock:
				notes.append("Unlocks the advanced equipment at the equipment vendor.")
			if current.reward_item_vendor_advanced_unlock:
				notes.append("Unlocks the second half of the item vendor's stock.")
		if notes.is_empty() and i > 0:
			filler_count += 1
			match filler_count % 3:
				0:
					current.reward_vendor_unlock = "Sable's rare stock"
					notes.append("Unlocks a small batch of rarer cards at the vendor.")
				2:
					current.reward_vendor_discount_percent = FILLER_DISCOUNT_PERCENT
					notes.append("Permanent vendor discount +%d%%." % FILLER_DISCOUNT_PERCENT)
				_:
					current.reward_gold = 50 + current.level * 5
					notes.append("+%d gold." % current.reward_gold)
		current.summary = " ".join(notes) if not notes.is_empty() else "Starting stats."
