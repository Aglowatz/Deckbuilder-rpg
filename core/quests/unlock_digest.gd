class_name UnlockDigest
extends RefCounted
## A snapshot of what the player has opened up so far (zone entrances, the Arena, the Alchemist, vendor stock by level, quests that can be
## started). Take one before a reward is paid and one after; `lines_since` turns the difference into the "what this opened up" lines of the
## quest-complete popup ("The Gainlands entrance is now open", "New stock at the Equipment Vendor", "The Alchemist is now available").

## zone id -> the name shown for its entrance.
var open_entrances: Dictionary = {}
var arena_open: bool = false
var alchemist_open: bool = false
var level: int = 1
## quest id -> title, for every quest that can be started right now.
var startable_quests: Dictionary = {}


static func capture(flags: Dictionary, player_level: int, startable: Dictionary = {}) -> UnlockDigest:
	var digest: UnlockDigest = UnlockDigest.new()
	digest.level = player_level
	digest.arena_open = ZoneCompletion.arena_unlocked(flags)
	digest.alchemist_open = ZoneCompletion.alchemist_unlocked(flags)
	digest.startable_quests = startable.duplicate()
	for info: ZonePortals.Info in ZonePortals.all():
		if info.id == ZonePortals.FINAL_ID:
			continue
		if bool(flags.get(str(CorruptedNpcs.unlock_flag(info.id)), false)):
			digest.open_entrances[info.id] = entrance_name(info)
	return digest


## "The Gainlands" for the Beefcake entrance, the zone's own name where it has one, the portal's name otherwise.
static func entrance_name(info: ZonePortals.Info) -> String:
	if ZoneDefs.has_def(info.id):
		var def: ZoneDef = ZoneDefs.get_def(info.id)
		if def != null and not def.display_name.is_empty():
			return def.display_name
	return info.display_name


## The lines for everything that is open now but was not in `before`.
func lines_since(before: UnlockDigest) -> Array[String]:
	var lines: Array[String] = []
	for zone_id: String in open_entrances.keys():
		if not before.open_entrances.has(zone_id):
			lines.append("The %s entrance is now open" % str(open_entrances[zone_id]).trim_prefix("The "))
	if arena_open and not before.arena_open:
		lines.append("The Grand Clashatorium (the Arena) is now open")
	if alchemist_open and not before.alchemist_open:
		lines.append("The Alchemist is now available")
	for next_level: int in range(before.level + 1, level + 1):
		lines.append_array(level_unlocks(next_level))
	for quest_id: String in startable_quests.keys():
		if not before.startable_quests.has(quest_id):
			lines.append("New quest available: %s" % str(startable_quests[quest_id]))
	return lines


## What reaching `reached_level` opens at the shops (the tailor's level-gated clothes included).
static func level_unlocks(reached_level: int) -> Array[String]:
	var lines: Array[String] = []
	var row: LevelData = ProgressionTable.row(reached_level)
	if row != null:
		if row.reward_equipment_vendor_unlock:
			lines.append("New stock at the Equipment Vendor")
		if row.reward_item_vendor_advanced_unlock:
			lines.append("New stock at the Item Vendor")
		if not row.reward_vendor_unlock.is_empty():
			lines.append("%s now at the vendor" % row.reward_vendor_unlock)
		if row.equipment_choice:
			lines.append("A new equipment slot to unlock")
	for item: CosmeticData in CosmeticCatalog.all():
		if item.unlock != null and item.unlock.kind == Condition.Kind.PLAYER_LEVEL and item.unlock.amount == reached_level and item.is_for_sale():
			lines.append("New at the tailor: %s" % item.display_name)
	return lines
