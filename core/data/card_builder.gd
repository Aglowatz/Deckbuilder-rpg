class_name CardBuilder
extends RefCounted
## Convenience constructors for CardData/EffectData. Used by the content generator and tests
## so card definitions stay short and typed.


static func land(color: Affinity.Type, basic: bool = true) -> CardData:
	var card: CardData = CardData.new()
	card.id = "land_%s" % Affinity.display_name(color).to_lower().replace(" ", "_")
	card.display_name = "%s Land" % Affinity.display_name(color)
	card.type = CardEnums.CardType.LAND
	card.color = color
	card.is_basic = basic
	card.toughness = 0
	return card


static func creature(
	id: String,
	display_name: String,
	color: Affinity.Type,
	generic: int,
	pips: Array[Affinity.Type],
	power: int,
	toughness: int,
	keywords: Array[CardEnums.Keyword] = [],
) -> CardData:
	var card: CardData = _base(id, display_name, CardEnums.CardType.CREATURE, color, generic, pips)
	card.power = power
	card.toughness = toughness
	card.keywords = keywords.duplicate()
	return card


static func spell(
	id: String,
	display_name: String,
	color: Affinity.Type,
	generic: int,
	pips: Array[Affinity.Type],
) -> CardData:
	return _base(id, display_name, CardEnums.CardType.SPELL, color, generic, pips)


static func trap(
	id: String,
	display_name: String,
	color: Affinity.Type,
	generic: int,
	pips: Array[Affinity.Type],
) -> CardData:
	return _base(id, display_name, CardEnums.CardType.TRAP, color, generic, pips)


static func artifact(
	id: String,
	display_name: String,
	color: Affinity.Type,
	generic: int,
	pips: Array[Affinity.Type],
) -> CardData:
	return _base(id, display_name, CardEnums.CardType.ARTIFACT, color, generic, pips)


static func token(id: String, display_name: String, power: int, toughness: int, keywords: Array[CardEnums.Keyword] = []) -> CardData:
	var card: CardData = creature(id, display_name, Affinity.Type.NEUTRAL, 0, [], power, toughness, keywords)
	card.is_token = true
	return card


static func effect(
	trigger: CardEnums.Trigger,
	target: CardEnums.TargetKind,
	op: CardEnums.EffectOp,
	amount: int = 0,
	amount2: int = 0,
	duration: CardEnums.Duration = CardEnums.Duration.PERMANENT,
) -> EffectData:
	var data: EffectData = EffectData.new()
	data.trigger = trigger
	data.target = target
	data.op = op
	data.amount = amount
	data.amount2 = amount2
	data.duration = duration
	return data


## Adds an effect to a card and returns the card for chaining.
static func with_effect(card: CardData, effect_data: EffectData) -> CardData:
	card.effects.append(effect_data)
	return card


static func modifier(kind: Modifier.Kind, value: int, color: int = Modifier.ANY_COLOR, value2: int = 0) -> Modifier:
	var mod: Modifier = Modifier.new()
	mod.kind = kind
	mod.value = value
	mod.color = color
	mod.value2 = value2
	return mod


static func modifier_source(
	source_name: String,
	kind: ModifierSource.SourceKind,
	mods: Array[Modifier],
) -> ModifierSource:
	var source: ModifierSource = ModifierSource.new()
	source.source_name = source_name
	source.source_kind = kind
	source.modifiers = mods.duplicate()
	return source


static func _base(
	id: String,
	display_name: String,
	type: CardEnums.CardType,
	color: Affinity.Type,
	generic: int,
	pips: Array[Affinity.Type],
) -> CardData:
	var card: CardData = CardData.new()
	card.id = id
	card.display_name = display_name
	card.type = type
	card.color = color
	card.generic_cost = generic
	card.colored_pips = pips.duplicate()
	card.toughness = 0
	return card
