class_name EquipCaps
extends RefCounted
## Overnight Oct 17, Part 5: how many pieces of each equipment rarity may be worn at once. Scaled to the five slots: Commons are
## never limited, rarer pieces start capped and level-ups raise the caps (the first Epic at level 5, the first Legendary at 22).
## The table lives in `data/progression/level_track.json` (section "equip_caps"). Pure rules: no scene tree.

const SLOTS: int = 5
const _FALLBACK_START: Array[int] = [5, 2, 0, 0]


static func start_cap(rarity: int) -> int:
	var start: Dictionary = LevelTrack.section("equip_caps").get("start", {}) as Dictionary
	return int(start.get(LevelTrack.rarity_key(rarity as CardEnums.Rarity), _FALLBACK_START[clampi(rarity, 0, 3)]))


static func raises() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry: Variant in LevelTrack.section("equip_caps").get("raises", []) as Array:
		var row: Dictionary = entry as Dictionary
		var rarity: int = LevelTrack.rarity_from_key(str(row.get("rarity", "")))
		if rarity >= 0:
			result.append({"level": int(row.get("level", 1)), "rarity": rarity, "cap": mini(SLOTS, int(row.get("cap", 0)))})
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a["level"]) < int(b["level"]))
	return result


## How many pieces of `rarity` may be worn at `level`.
static func cap_for(rarity: int, level: int) -> int:
	var cap: int = start_cap(rarity)
	for row: Dictionary in raises():
		if int(row["rarity"]) == rarity and level >= int(row["level"]):
			cap = maxi(cap, int(row["cap"]))
	return mini(cap, SLOTS)


static func next_raise(rarity: int, level: int) -> Dictionary:
	var current: int = cap_for(rarity, level)
	for row: Dictionary in raises():
		if int(row["rarity"]) == rarity and int(row["level"]) > level and int(row["cap"]) > current:
			return {"level": int(row["level"]), "cap": int(row["cap"])}
	return {}


static func raises_at(level: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for row: Dictionary in raises():
		if int(row["level"]) == level:
			result.append({"rarity": int(row["rarity"]), "cap": int(row["cap"])})
	return result


## How many equipped pieces have `rarity`, leaving out whatever sits in `except_slot` (-1 = count all).
static func worn(equipped: Array[ModifierSource], rarity: int, except_slot: int = -1) -> int:
	var count: int = 0
	for source: ModifierSource in equipped:
		var piece: EquipmentData = source as EquipmentData
		if piece != null and int(piece.rarity) == rarity and int(piece.slot) != except_slot:
			count += 1
	return count


## Empty when `piece` may be worn (replacing whatever is in its slot); otherwise the reason, e.g. "You can wear 1 Epic piece at
## level 5 (2 at level 13). Take one off first."
static func why_not(equipped: Array[ModifierSource], piece: EquipmentData, level: int) -> String:
	if piece == null:
		return "Nothing to equip."
	var rarity: int = int(piece.rarity)
	var cap: int = cap_for(rarity, level)
	if worn(equipped, rarity, int(piece.slot)) < cap:
		return ""
	var name: String = EquipmentRarity.display_name(rarity)
	var text: String = ""
	if cap <= 0:
		text = "%s gear cannot be worn yet" % name
	else:
		text = "You can wear %d %s piece%s at your level" % [cap, name, "" if cap == 1 else "s"]
	var next: Dictionary = next_raise(rarity, level)
	if not next.is_empty():
		text += " (%d from level %d)" % [int(next["cap"]), int(next["level"])]
	text += "."
	if cap > 0:
		text += " Take one off first."
	return text


## The equipped pieces over their caps at `level` (the later ones in the list), for the save migration.
static func over_cap(equipped: Array[ModifierSource], level: int) -> Array[EquipmentData]:
	var result: Array[EquipmentData] = []
	var seen: Dictionary = {}
	for source: ModifierSource in equipped:
		var piece: EquipmentData = source as EquipmentData
		if piece == null:
			continue
		var rarity: int = int(piece.rarity)
		seen[rarity] = int(seen.get(rarity, 0)) + 1
		if int(seen[rarity]) > cap_for(rarity, level):
			result.append(piece)
	return result
