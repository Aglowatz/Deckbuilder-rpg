class_name BoonText
extends RefCounted
## Fixes Oct 27, Part 4: what a run's boon or curse really does, in words, from its own numbers (the badges said "A boon: it fights on your side." for
## every boon whose modifiers carry no label - the dungeon list's event boons, all of them). A curse is a boon whose numbers are all negative or zero
## with at least one below zero (data/dungeons/dungeon_content.json: curse:Name|max_hp=-1). Read by RuleBadges and the dungeon screens.

const DURATION: String = "for the rest of this run"

## Boons that change no number but something else in the run (their effect lives in the dungeon's own code).
const MARKERS: Dictionary = {
	PathologyLab.BOON_NAME: "Elowen Vey fights beside you in the Siphon fight",
	HouseOfGainsDungeon.BOON_NAME: "Grandmaster Flex fights beside you in the boss fight",
	RotheartDungeon.SEVERED_BOON_NAME: "the Rotheart starts her fight with %d less HP" % RotheartDungeon.SEVERED_HP_LOSS,
}


## True for a curse (numbers that only take away).
static func is_curse(source: ModifierSource) -> bool:
	var any_negative: bool = false
	for modifier: Modifier in source.modifiers:
		for number: int in _numbers(modifier):
			if number > 0:
				return false
			if number < 0:
				any_negative = true
	return any_negative


## "Boon" or "Curse".
static func kind_word(source: ModifierSource) -> String:
	return "Curse" if is_curse(source) else "Boon"


## The full sentence(s): "Your units get +1 attack for the rest of this run." Never empty.
static func describe(source: ModifierSource) -> String:
	var parts: PackedStringArray = []
	for modifier: Modifier in source.modifiers:
		var part: String = modifier_text(modifier)
		if not part.is_empty():
			parts.append(part)
	var sentences: PackedStringArray = []
	if not parts.is_empty():
		sentences.append(_capital(_join(parts)) + " " + DURATION + ".")
	if MARKERS.has(source.source_name):
		sentences.append(_capital(str(MARKERS[source.source_name])) + ".")
	if sentences.is_empty():
		return "A mark of what you did in this run: it changes no numbers."
	return " ".join(sentences)


## The effect in a few words, for a choice button ("your units get +1 attack", "-1 max HP"); never empty.
static func short(source: ModifierSource) -> String:
	var parts: PackedStringArray = []
	for modifier: Modifier in source.modifiers:
		var part: String = modifier_text(modifier)
		if not part.is_empty():
			parts.append(part)
	if MARKERS.has(source.source_name):
		parts.append(str(MARKERS[source.source_name]))
	return _join(parts) if not parts.is_empty() else "no numbers change"


static func _capital(text: String) -> String:
	return text.substr(0, 1).to_upper() + text.substr(1)


## One modifier in words, lower case, no full stop ("your units get +1 attack"); "" for one that changes nothing.
static func modifier_text(modifier: Modifier) -> String:
	var units: String = "your units" if modifier.color == Modifier.ANY_COLOR else "your %s units" % Affinity.display_name(modifier.color as Affinity.Type)
	match modifier.kind:
		Modifier.Kind.MAX_HP:
			return "" if modifier.value == 0 else "%s max HP" % _signed(modifier.value)
		Modifier.Kind.STARTING_HP:
			return "" if modifier.value == 0 else "%s HP at the start of each fight" % _signed(modifier.value)
		Modifier.Kind.STAT_CHANGE:
			var stats: PackedStringArray = []
			if modifier.value != 0:
				stats.append("%s attack" % _signed(modifier.value))
			if modifier.value2 != 0:
				stats.append("%s defense" % _signed(modifier.value2))
			if stats.is_empty():
				return ""
			return "%s get %s" % [units, " and ".join(stats)]
		Modifier.Kind.HP_GAIN_BONUS:
			return "" if modifier.value == 0 else "%s HP every time you heal" % _signed(modifier.value)
		Modifier.Kind.COST_CHANGE:
			var cards: String = "your cards" if modifier.color == Modifier.ANY_COLOR else "your %s cards" % Affinity.display_name(modifier.color as Affinity.Type)
			return "" if modifier.value == 0 else "%s cost %d %s" % [cards, absi(modifier.value), "less" if modifier.value < 0 else "more"]
	return modifier.label.strip_edges().trim_suffix(".")


static func _numbers(modifier: Modifier) -> Array[int]:
	match modifier.kind:
		Modifier.Kind.STAT_CHANGE:
			return [modifier.value, modifier.value2] as Array[int]
		Modifier.Kind.COST_CHANGE:
			return [-modifier.value] as Array[int]  # a lower cost helps
		Modifier.Kind.MAX_HP, Modifier.Kind.STARTING_HP, Modifier.Kind.HP_GAIN_BONUS:
			return [modifier.value] as Array[int]
	return [] as Array[int]


static func _signed(value: int) -> String:
	return "+%d" % value if value > 0 else str(value)


## "a", "a and b", "a, b and c".
static func _join(parts: PackedStringArray) -> String:
	if parts.size() == 1:
		return parts[0]
	return ", ".join(parts.slice(0, parts.size() - 1)) + " and " + parts[parts.size() - 1]
