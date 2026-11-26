class_name BoonText
extends RefCounted
## Fixes Oct 27, Part 4: what a run's boon or curse really does, in words, from its own numbers (the badges said "A boon: it fights on your side." for
## every boon whose modifiers carry no label - the dungeon list's event boons, all of them). A curse is a boon whose numbers are all negative or zero
## with at least one below zero (data/dungeons/dungeon_content.json: curse:Name|max_hp=-1). Read by RuleBadges and the dungeon screens.

const DURATION: String = "for the rest of this run"

## Boons that change no number but something else in the run (their effect lives in the dungeon's own code).
const MARKERS: Dictionary = {
	PathologyLab.BOON_NAME: "Elowen Vey fights beside you in the Siphon fight",
	HouseOfGainsDungeon.BOON_NAME: "Grandmaster Flex fights beside you in the final battle",
	RotheartDungeon.SEVERED_BOON_NAME: "the Rotheart starts her fight with %d less HP" % RotheartDungeon.SEVERED_HP_LOSS,
}


## The words of a marker boon ("" for any other): the dungeons' own, and the castle's allies (Fable Nov 21 castle).
static func _marker(source_name: String) -> String:
	if MARKERS.has(source_name):
		return str(MARKERS[source_name])
	return CastleAllies.marker_text(source_name)


## True for a curse (numbers that only take away).
static func is_curse(source: ModifierSource) -> bool:
	if source.for_enemy:
		return true  # Overnight Nov 19: anything that strengthens the enemy is a drawback
	for modifier: Modifier in source.modifiers:
		if modifier.kind == Modifier.Kind.ENTER_EXHAUSTED or modifier.kind == Modifier.Kind.FIRST_UNIT_ENTER_EXHAUSTED:
			return true
		# Fable Nov 21 (Part 4.3): the new drawbacks
		if modifier.kind == Modifier.Kind.FIRST_DRAW_PENALTY or modifier.kind == Modifier.Kind.FIRST_INFRASTRUCTURE_ENTER_EXHAUSTED:
			return true
		if modifier.kind == Modifier.Kind.FIRST_CARD_COST_CHANGE and modifier.value > 0:
			return true
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
		var part: String = modifier_text(modifier, source.for_enemy)
		if not part.is_empty():
			parts.append(part)
	var sentences: PackedStringArray = []
	if not parts.is_empty():
		sentences.append(_capital(_join(parts)) + " " + duration(source) + ".")
	if not _marker(source.source_name).is_empty():
		sentences.append(_capital(_marker(source.source_name)) + ".")
	if sentences.is_empty():
		return "A mark of what you did in this run: it changes no numbers."
	return " ".join(sentences)


## The effect in a few words, for a choice button ("your units get +1 attack", "-1 max HP"); never empty.
static func short(source: ModifierSource) -> String:
	var parts: PackedStringArray = []
	for modifier: Modifier in source.modifiers:
		var part: String = modifier_text(modifier, source.for_enemy)
		if not part.is_empty():
			parts.append(part)
	if not _marker(source.source_name).is_empty():
		parts.append(_marker(source.source_name))
	if parts.is_empty():
		return "no numbers change"
	return _join(parts) + (" in the next fight" if source.fights_left == 1 else (" for the rest of the dungeon" if source.fights_left == 0 and _marker(source.source_name).is_empty() else ""))


## Overnight Nov 19 (Part 5): how long it lasts.
static func duration(source: ModifierSource) -> String:
	if source.fights_left == 1:
		return "in the next fight"
	if source.fights_left > 1:
		return "for the next %d fights" % source.fights_left
	return DURATION


static func _capital(text: String) -> String:
	return text.substr(0, 1).to_upper() + text.substr(1)


## One modifier in words, lower case, no full stop ("your units get +1 attack"); "" for one that changes nothing.
static func modifier_text(modifier: Modifier, enemy: bool = false) -> String:
	var units: String = "your units" if modifier.color == Modifier.ANY_COLOR else "your %s units" % Affinity.display_name(modifier.color as Affinity.Type)
	if enemy:
		units = "the enemy's units"
		if modifier.kind == Modifier.Kind.MAX_HP:
			return "" if modifier.value == 0 else "the enemy starts with %s HP" % _signed(modifier.value)
	# Fable Nov 19 (Part 5.2): a seat that starts the fight with units on the field
	if modifier.kind == Modifier.Kind.STARTING_UNITS:
		if modifier.value <= 0 or modifier.tokens.is_empty() or modifier.tokens[0] == null:
			return ""
		var unit: CardData = modifier.tokens[0]
		var what: String = "%s %s (%d/%d)" % ["a" if modifier.value == 1 else str(modifier.value), unit.display_name, unit.attack, unit.defense]
		return ("the enemy starts with %s on the field" if enemy else "you start with %s on the field") % what
	match modifier.kind:
		Modifier.Kind.ALWAYS_FIRST:
			return "the enemy takes the first turn" if enemy else "you take the first turn"
		Modifier.Kind.OPENING_HAND_SIZE:
			if enemy:
				return "" if modifier.value == 0 else "the enemy starts with %s card%s in hand" % [_signed(modifier.value), "" if absi(modifier.value) == 1 else "s"]
			return "" if modifier.value == 0 else "%s card%s in your opening hand" % [_signed(modifier.value), "" if absi(modifier.value) == 1 else "s"]
		# Fable Nov 21 (Part 4.3): the new drawbacks, in the words the choice buttons show
		Modifier.Kind.FIRST_UNIT_STAT_CHANGE:
			var first_stats: PackedStringArray = []
			if modifier.value != 0:
				first_stats.append("%s attack" % _signed(modifier.value))
			if modifier.value2 != 0:
				first_stats.append("%s defense" % _signed(modifier.value2))
			if first_stats.is_empty():
				return ""
			if modifier.value == modifier.value2:
				first_stats = PackedStringArray(["%s/%s" % [_signed(modifier.value), _signed(modifier.value2)]])
			return "%s gets %s" % ["the enemy's first unit" if enemy else "the first unit you play", " and ".join(first_stats)]
		Modifier.Kind.FIRST_DRAW_PENALTY:
			return "" if modifier.value <= 0 else ("you skip your first card draw" if modifier.value == 1 else "you draw %d cards fewer on your first draws" % modifier.value)
		Modifier.Kind.FIRST_CARD_COST_CHANGE:
			return "" if modifier.value == 0 else "the first card you play each turn costs %d %s" % [absi(modifier.value), "more" if modifier.value > 0 else "less"]
		Modifier.Kind.FIRST_INFRASTRUCTURE_ENTER_EXHAUSTED:
			return "your first Infrastructure enters exhausted"
		Modifier.Kind.ENTER_EXHAUSTED:
			return "your units enter exhausted"
		Modifier.Kind.FIRST_UNIT_ENTER_EXHAUSTED:
			return "your first unit enters exhausted"
		Modifier.Kind.STARTING_RESOURCES:
			var resource_name: String = {int(ResourceKind.Kind.IRON): "Iron", int(ResourceKind.Kind.RED_TAPE): "Red Tape", int(ResourceKind.Kind.INGREDIENT): "Ingredient", int(ResourceKind.Kind.GARBAGE): "Garbage"}.get(modifier.value2, "extra resources")
			return ("the enemy starts with %d %s" if enemy else "start with %d %s") % [modifier.value, resource_name]
		# Nov 25 night (Parts D, E and G): the new boons and curses in words
		Modifier.Kind.EXTRA_DRAWS:
			return "" if modifier.value == 0 else ("the enemy draws %d extra card%s each turn" if enemy else "draw %d extra card%s each turn") % [modifier.value, "" if modifier.value == 1 else "s"]
		Modifier.Kind.STARTING_INFRASTRUCTURE:
			return ("the enemy starts with %d Infrastructure in play" if enemy else "start with %d Infrastructure in play") % modifier.value
		Modifier.Kind.BANNED_CARD_TYPE:
			return "you may not play %ss" % str(CardEnums.CardType.keys()[clampi(modifier.value, 0, CardEnums.CardType.size() - 1)]).to_lower()
		Modifier.Kind.MAX_NON_INFRASTRUCTURE_PLAYS_PER_TURN:
			return "you may play only %d card%s a turn (Infrastructure aside)" % [modifier.value, "" if modifier.value == 1 else "s"]
		Modifier.Kind.COPY_FIRST_TRAP:
			return "the first Trap you set each turn is set twice"
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
		Modifier.Kind.FIRST_UNIT_STAT_CHANGE:
			return [modifier.value, modifier.value2] as Array[int]
		Modifier.Kind.MAX_HP, Modifier.Kind.STARTING_HP, Modifier.Kind.HP_GAIN_BONUS, Modifier.Kind.OPENING_HAND_SIZE, Modifier.Kind.STARTING_RESOURCES, Modifier.Kind.EXTRA_DRAWS, Modifier.Kind.STARTING_INFRASTRUCTURE:
			return [modifier.value] as Array[int]
		Modifier.Kind.BANNED_CARD_TYPE, Modifier.Kind.MAX_NON_INFRASTRUCTURE_PLAYS_PER_TURN:
			return [-1] as Array[int]  # a restriction: always a curse
		Modifier.Kind.COPY_FIRST_TRAP:
			return [1] as Array[int]
	return [] as Array[int]


static func _signed(value: int) -> String:
	return "+%d" % value if value > 0 else str(value)


## "a", "a and b", "a, b and c".
static func _join(parts: PackedStringArray) -> String:
	if parts.size() == 1:
		return parts[0]
	return ", ".join(parts.slice(0, parts.size() - 1)) + " and " + parts[parts.size() - 1]
