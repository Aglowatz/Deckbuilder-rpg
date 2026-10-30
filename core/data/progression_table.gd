class_name ProgressionTable
extends RefCounted
## The full level 1-30 table: one place that computes every level's stats and what it grants, so `PlayerProfile` levels always
## read from the same source of truth as the printed tables (docs/design/progression.md, docs/design/level_rewards.md).
## Overnight Oct 17, Part 6: every reward level lives in the reward track (`data/progression/level_track.json`, `LevelTrack`): the
## stat steps, the shop unlocks, the copy and equipment cap raises, the deck slots and each level's gold, packs and cosmetics.
## Every level grants something; key levels are marked big. The constants below mirror the track for code that needs a
## compile-time value; tests check they agree.

const MAX_LEVEL: int = 30
## Overnight Oct 17, Part 5: no more slot choices - the level-5 armory quest ("Some Assembly Required") unlocks all five slots at once.
const EQUIPMENT_CHOICE_LEVELS: Array[int] = []
## The level the early-game chain (Meet the Merchants, Make It Yours, the store room) brings a new hero to by the time Maren sends them to
## the armory (Oct 20, Part 4); the armory quest itself no longer depends on it.
const ARMORY_LEVEL: int = 5
const BONUS_DISCOUNT_LEVELS: Array[int] = [11, 21]
const MAX_HAND_LEVELS: Array[int] = [14, 28]
const BONUS_VENDOR_UNLOCK_LEVELS: Array[int] = [17, 27]
const BONUS_VENDOR_UNLOCK_NAME: String = "Sable's rare stock"
## Opening hand size increases at these levels (5 -> 8 over 3 steps).
const HAND_SIZE_LEVELS: Array[int] = [8, 16, 24]
## Item slots increase at these levels (1 -> 4 over 3 steps).
const ITEM_SLOT_LEVELS: Array[int] = [10, 20, 30]
const EQUIPMENT_VENDOR_UNLOCK_LEVEL: int = 13
const ITEM_VENDOR_ADVANCED_UNLOCK_LEVEL: int = 6
const FILLER_DISCOUNT_PERCENT: int = 10
## Overnight Oct 17, Part 4: the Deck Station has 10 slots; 4 are open at the start and 2 more open at levels 7, 14 and 21
## (`DeckSlots`). DECK_BOX_EXPANSION_LEVEL is the first of those levels.
const DECK_BOX_EXPANSION_LEVEL: int = 7
const BASE_DECK_SLOTS: int = DeckSlots.START_SLOTS
const EXPANDED_DECK_SLOTS: int = DeckSlots.SLOT_COUNT

## XP Pass Oct 30: the curve is re-based on the XP the story timeline really pays (`tools/economy_model.gd`, "Level timeline"), so
## the expected player is about L5 at the Gainlands, L8 in the House of Gains, L14 at the Test Kitchen boss, L18-19 when the Dump
## is freed and L21-22 in Primm's Castle (`ProgressionModel`, docs/design/progression.md). Every level costs more than the last.
## The XP from level L - 1 to L for L = 2..9 (the opening hours: L5 lands on the store room ghosts' hand-in).
const EARLY_STEPS: Array[int] = [50, 70, 80, 100, 280, 300, 340, 380]
## Levels 10-20 cost MAIN_STEP_BASE + MAIN_STEP_PER_LEVEL x L each (425 at L10 .. 525 at L20).
const MAIN_STEP_BASE: int = 325
const MAIN_STEP_PER_LEVEL: int = 10
## Levels 21-30 (the postgame climb) cost POSTGAME_STEP_BASE + POSTGAME_STEP x (L - 20) each (535 at L21 .. 850 at L30;
## was a 27 x (L - 20)(L - 19) surcharge on the old curve, which made 21-30 together cheaper than 17-20).
const POSTGAME_STEP_BASE: int = 500
const POSTGAME_STEP: int = 35

static var _cache: Array[LevelData] = []


static func build() -> Array[LevelData]:
	if not _cache.is_empty():
		return _cache.duplicate()
	var stats: Dictionary = LevelTrack.section("stats")
	var vendor: Dictionary = LevelTrack.section("vendor")
	var hand_levels: Array[int] = _ints(stats.get("opening_hand", HAND_SIZE_LEVELS))
	var item_levels: Array[int] = _ints(stats.get("item_slots", ITEM_SLOT_LEVELS))
	var max_hand_levels: Array[int] = _ints(stats.get("max_hand", MAX_HAND_LEVELS))
	var hp_every: int = maxi(1, int(stats.get("hp_every", 2)))
	var discount_levels: Array[int] = _ints(vendor.get("discount_levels", BONUS_DISCOUNT_LEVELS))
	var discount_percent: int = int(vendor.get("discount_percent", FILLER_DISCOUNT_PERCENT))
	var rare_levels: Array[int] = _ints(vendor.get("rare_stock_levels", BONUS_VENDOR_UNLOCK_LEVELS))
	var rows: Array[LevelData] = []
	for level: int in range(1, MAX_LEVEL + 1):
		var row: LevelData = LevelData.new()
		row.level = level
		row.xp_to_reach = xp_to_reach(level)
		row.max_hp = PlayerProfile.START_MAX_HP + int(level / hp_every)
		row.opening_hand_size = PlayerProfile.MIN_OPENING_HAND + _steps_reached(level, hand_levels)
		row.item_slots = 1 + _steps_reached(level, item_levels)
		row.max_hand_size = PlayerProfile.DEFAULT_MAX_HAND_SIZE + _steps_reached(level, max_hand_levels)
		row.deck_slots = DeckSlots.unlocked_at(level)
		row.reward_deck_expansion = DeckSlots.UNLOCK_LEVELS.has(level)
		row.reward_vendor_discount_percent = discount_percent if discount_levels.has(level) else 0
		row.reward_vendor_unlock = BONUS_VENDOR_UNLOCK_NAME if rare_levels.has(level) else ""
		row.equipment_choice = false
		row.reward_equipment_vendor_unlock = level == int(vendor.get("equipment_advanced", EQUIPMENT_VENDOR_UNLOCK_LEVEL))
		row.reward_item_vendor_advanced_unlock = level == int(vendor.get("item_advanced", ITEM_VENDOR_ADVANCED_UNLOCK_LEVEL))
		row.armory = false  # Oct 20, Part 4: the armory quest comes from Elder Maren after the store room, not from a level
		var entry: Dictionary = LevelTrack.level_entry(level)
		row.big = bool(entry.get("big", false))
		row.headline = str(entry.get("headline", ""))
		for grant: Variant in entry.get("grants", []) as Array:
			row.grants.append((grant as Dictionary).duplicate())
		row.copy_cap_raises = CopyCaps.raises_at(level)
		row.equip_cap_raises = EquipCaps.raises_at(level)
		rows.append(row)
	_fill_summaries(rows)
	_cache = rows
	return rows.duplicate()


## Forgets the built table (tests, and after the track file changes).
static func reload() -> void:
	_cache = []
	LevelTrack.reload()


static func _ints(raw: Variant) -> Array[int]:
	var result: Array[int] = []
	for value: Variant in raw as Array:
		result.append(int(value))
	return result


## Which milestone list entries `level` has already passed (0 at/under the first entry).
static func _steps_reached(level: int, milestones: Array[int]) -> int:
	var steps: int = 0
	for milestone: int in milestones:
		if level >= milestone:
			steps += 1
	return steps


## Cumulative XP needed to reach `level`: the sum of the steps up to it (XP Pass Oct 30). The main game ends at about L22 for the
## expected player, L25 after the postgame; the thorough player reaches about L28 and level 30 (13,750 XP) is the completionist's.
## Old saves keep their level when it is above what their XP would give now (`Session.add_xp` never lowers a level).
static func xp_to_reach(level: int) -> int:
	var total: int = 0
	for target: int in range(2, mini(level, MAX_LEVEL) + 1):
		total += xp_step(target)
	return total


## The XP from level `level` - 1 to `level`.
static func xp_step(level: int) -> int:
	if level <= 1:
		return 0
	if level - 2 < EARLY_STEPS.size():
		return EARLY_STEPS[level - 2]
	if level <= 20:
		return MAIN_STEP_BASE + MAIN_STEP_PER_LEVEL * level
	return POSTGAME_STEP_BASE + POSTGAME_STEP * (level - 20)


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
	var rows: Array[LevelData] = build()
	if level >= 1 and level <= rows.size():
		return rows[level - 1]
	return null


## A grant as player-facing text ("120 gold", "a Beefcake Path Pack", "Bowler Hat").
static func grant_text(grant: Dictionary, primary: Affinity.Type = Affinity.Type.NEUTRAL) -> String:
	match str(grant.get("kind", "")):
		"gold":
			return "%d gold" % int(grant.get("amount", 0))
		"pack":
			var pack: PackData = PackCatalog.find(pack_id(grant, primary))
			var count: int = int(grant.get("count", 1))
			var title: String = pack.display_name if pack != null else "a card pack"
			return title if count == 1 else "%dx %s" % [count, title]
		"cosmetic":
			var item: CosmeticData = CosmeticCatalog.find(str(grant.get("id", "")))
			return "%s (cosmetic)" % item.display_name if item != null else "a cosmetic"
	return ""


## The pack id a pack grant names: "path" / "gilded" are the player's own Path (Beefcake when there is none yet).
static func pack_id(grant: Dictionary, primary: Affinity.Type) -> String:
	var raw: String = str(grant.get("pack", ""))
	var path: Affinity.Type = primary if primary != Affinity.Type.NEUTRAL else Affinity.Type.BEEFCAKE
	if raw == "path":
		var pack: PackData = PackCatalog.path_pack(path)
		return pack.id if pack != null else ""
	if raw == "gilded":
		var gilded: PackData = PackCatalog.gilded_pack(path)
		return gilded.id if gilded != null else ""
	return raw


## Every reward of one level as player-facing lines, the big unlock first (the level-up screen and the docs table).
static func reward_lines(current: LevelData, previous: LevelData, primary: Affinity.Type = Affinity.Type.NEUTRAL) -> Array[String]:
	var lines: Array[String] = []
	if current.reward_deck_expansion and previous != null:
		lines.append("Deck Station: %d to %d deck slots." % [previous.deck_slots, current.deck_slots])
	for raise: Dictionary in current.copy_cap_raises:
		lines.append("%s cards: up to %d copies." % [CopyCaps.rarity_name(int(raise["rarity"]) as CardEnums.Rarity), int(raise["cap"])])
	for raise: Dictionary in current.equip_cap_raises:
		var count: int = int(raise["cap"])
		lines.append("Wear up to %d %s piece%s of equipment." % [count, EquipmentRarity.display_name(int(raise["rarity"])), "" if count == 1 else "s"])
	if previous != null:
		if current.item_slots > previous.item_slots:
			lines.append("+1 item slot (%d)." % current.item_slots)
		if current.opening_hand_size > previous.opening_hand_size:
			lines.append("Opening hand size +1 (%d)." % current.opening_hand_size)
		if current.max_hand_size > previous.max_hand_size:
			lines.append("Max hand size +1 (%d)." % current.max_hand_size)
	if current.reward_vendor_discount_percent > 0:
		lines.append("Permanent vendor discount +%d%%." % current.reward_vendor_discount_percent)
	if not current.reward_vendor_unlock.is_empty():
		lines.append("Unlocks a small batch of rarer cards at Sable's stall.")
	if current.reward_equipment_vendor_unlock:
		lines.append("Unlocks Bertram's advanced equipment rack.")
	if current.reward_item_vendor_advanced_unlock:
		lines.append("Unlocks the second half of Tilly's stock.")
	for grant: Dictionary in current.grants:
		var text: String = grant_text(grant, primary)
		if not text.is_empty():
			lines.append(text[0].to_upper() + text.substr(1) + ".")
	if previous != null and current.max_hp > previous.max_hp:
		lines.append("+1 starting HP (%d)." % current.max_hp)
	return lines


static func _fill_summaries(rows: Array[LevelData]) -> void:
	for i: int in range(rows.size()):
		var current: LevelData = rows[i]
		var previous: LevelData = rows[i - 1] if i > 0 else null
		if previous == null:
			current.summary = "Starting stats."
			continue
		current.summary = " ".join(reward_lines(current, previous))
