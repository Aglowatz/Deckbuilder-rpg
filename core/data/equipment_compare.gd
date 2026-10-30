class_name EquipmentCompare
extends RefCounted
## Overnight Oct 16, Block 2: "what changes if I swap to this piece" - the numbers that can be compared (HP, starting HP, unit attack and
## defense, hand sizes, draws, cost, overworld speed, XP) as signed differences, plus the effects gained and lost as plain text. Used by the
## character screen's piece picker and every equipment shop's hover tooltip.

## Comparable modifier kinds -> label. STAT_CHANGE splits into attack and defense; colour-restricted modifiers are labelled with their Path.
const LABELS: Dictionary = {
	Modifier.Kind.MAX_HP: "Max HP", Modifier.Kind.STARTING_HP: "starting HP", Modifier.Kind.MAX_HAND_SIZE: "max hand size",
	Modifier.Kind.OPENING_HAND_SIZE: "opening hand", Modifier.Kind.EXTRA_DRAWS: "cards drawn each turn", Modifier.Kind.FIRST_TURN_EXTRA_DRAW: "first-turn draw",
	Modifier.Kind.OVERWORLD_SPEED_PERCENT: "% walking speed", Modifier.Kind.XP_BONUS_PERCENT: "% XP", Modifier.Kind.COST_CHANGE: "card cost",
}


## Signed totals of every comparable stat of a piece (null = nothing equipped): label -> value.
static func stats(piece: EquipmentData) -> Dictionary:
	var result: Dictionary = {}
	if piece == null:
		return result
	for modifier: Modifier in piece.modifiers:
		if modifier == null:
			continue
		var suffix: String = "" if modifier.color == Modifier.ANY_COLOR else " (%s)" % Affinity.display_name(modifier.color as Affinity.Type)
		if modifier.kind == Modifier.Kind.STAT_CHANGE:
			if modifier.value != 0:
				result["unit attack" + suffix] = int(result.get("unit attack" + suffix, 0)) + modifier.value
			if modifier.value2 != 0:
				result["unit defense" + suffix] = int(result.get("unit defense" + suffix, 0)) + modifier.value2
		elif LABELS.has(modifier.kind):
			var key: String = str(LABELS[modifier.kind]) + suffix
			result[key] = int(result.get(key, 0)) + modifier.value
	return result


## The differences of `piece` against `equipped` as lines: "+2 Max HP", "-1 unit attack". Card cost reads the other way round (less is better
## is still shown as the plain number change).
static func diff_lines(piece: EquipmentData, equipped: EquipmentData) -> PackedStringArray:
	var mine: Dictionary = stats(piece)
	var theirs: Dictionary = stats(equipped)
	var keys: Array = mine.keys()
	for key: Variant in theirs.keys():
		if not keys.has(key):
			keys.append(key)
	keys.sort()
	var lines: PackedStringArray = []
	for key: Variant in keys:
		var delta: int = int(mine.get(key, 0)) - int(theirs.get(key, 0))
		if delta == 0:
			continue
		var label: String = str(key)
		lines.append("%s%d%s%s" % ["+" if delta > 0 else "", delta, "" if label.begins_with("%") else " ", label])
	return lines


## The hover text of a piece in a shop or the picker: its name, rarity and slot, effect, drawback, flavour, where it comes from, and the
## comparison with what is equipped in its slot now.
static func tooltip(piece: EquipmentData, equipped: EquipmentData) -> String:
	var parts: PackedStringArray = []
	var heading: String = piece.source_name
	if piece.tier > 0:
		heading += "  (%s %s)" % [EquipmentData.RARITY_NAMES[int(piece.rarity)], EquipmentData.slot_name(piece.slot)]
	parts.append(heading)
	parts.append(piece.description)
	if piece.flavor_text != "":
		parts.append("\"%s\"" % piece.flavor_text)
	if piece.source != "":
		parts.append("Found: %s" % piece.source)
	if equipped == null:
		parts.append("\nNothing in this slot now.")
	elif equipped == piece:
		parts.append("\nEquipped.")
	else:
		var lines: PackedStringArray = diff_lines(piece, equipped)
		parts.append("\nCompared with %s:" % equipped.source_name)
		if lines.is_empty():
			parts.append("  no change in the numbers (different effects)")
		for line: String in lines:
			parts.append("  " + line)
		parts.append("  You'd lose: %s" % equipped.description)
	return "\n".join(parts)


## Overnight Oct 29, Phase 2: the one-word verdict a shop or picker shows next to a piece: "Upgrade" when every comparable number is at
## least as good and one is better (and nothing is lost), "Downgrade" the other way round, "Sidegrade" when numbers go both ways or the
## effects differ with no number change, "Empty slot" with nothing equipped, "Equipped" for the piece worn now.
const VERDICT_UPGRADE: String = "Upgrade"
const VERDICT_SIDEGRADE: String = "Sidegrade"
const VERDICT_DOWNGRADE: String = "Downgrade"
const VERDICT_EMPTY: String = "Empty slot"
const VERDICT_EQUIPPED: String = "Equipped"


static func verdict(piece: EquipmentData, equipped: EquipmentData) -> String:
	if piece == null:
		return ""
	if equipped == null:
		return VERDICT_EMPTY
	if equipped == piece or equipped.id == piece.id:
		return VERDICT_EQUIPPED
	var mine: Dictionary = stats(piece)
	var theirs: Dictionary = stats(equipped)
	var better: int = 0
	var worse: int = 0
	var keys: Array = mine.keys()
	for key: Variant in theirs.keys():
		if not keys.has(key):
			keys.append(key)
	for key: Variant in keys:
		var delta: int = int(mine.get(key, 0)) - int(theirs.get(key, 0))
		var label: String = str(key)
		if label.to_lower().contains("cost"):
			delta = -delta  # a cheaper card is the better number
		if delta > 0:
			better += 1
		elif delta < 0:
			worse += 1
	# An effect the other piece has and this one lacks (a keyword, a trigger) is a loss the numbers cannot see: never an outright upgrade.
	var mine_effects: int = _effect_count(piece)
	var theirs_effects: int = _effect_count(equipped)
	if better > 0 and worse == 0 and mine_effects >= theirs_effects:
		return VERDICT_UPGRADE
	if worse > 0 and better == 0 and mine_effects <= theirs_effects:
		return VERDICT_DOWNGRADE
	return VERDICT_SIDEGRADE


## How many of a piece's modifiers are effects the numbers cannot compare (keywords, triggers, rules).
static func _effect_count(piece: EquipmentData) -> int:
	var count: int = 0
	for modifier: Modifier in piece.modifiers:
		if modifier != null and not (LABELS.has(modifier.kind) or modifier.kind == Modifier.Kind.STAT_CHANGE):
			count += 1
	return count
