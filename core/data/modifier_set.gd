class_name ModifierSet
extends RefCounted
## Aggregated modifiers affecting one player. The single query surface for the rules engine.

var modifiers: Array[Modifier] = []


func add(modifier: Modifier) -> void:
	modifiers.append(modifier)


func add_source(source: ModifierSource) -> void:
	for modifier: Modifier in source.modifiers:
		modifiers.append(modifier)


func add_sources(sources: Array[ModifierSource]) -> void:
	for source: ModifierSource in sources:
		add_source(source)


## Sum of `value` over all modifiers of `kind`.
func sum(kind: Modifier.Kind) -> int:
	var total: int = 0
	for modifier: Modifier in modifiers:
		if modifier.kind == kind:
			total += modifier.value
	return total


## Sum of `value` over modifiers of `kind` that match `card_color`.
func sum_for_color(kind: Modifier.Kind, card_color: Affinity.Type) -> int:
	var total: int = 0
	for modifier: Modifier in modifiers:
		if modifier.kind == kind and modifier.matches_color(card_color):
			total += modifier.value
	return total


## Combined (power, toughness) bonus for a creature of the given color.
func stat_bonus(card_color: Affinity.Type) -> Vector2i:
	var bonus: Vector2i = Vector2i.ZERO
	for modifier: Modifier in modifiers:
		if modifier.kind == Modifier.Kind.STAT_CHANGE and modifier.matches_color(card_color):
			bonus += Vector2i(modifier.value, modifier.value2)
	return bonus


func effects_of(kind: Modifier.Kind) -> Array[EffectData]:
	var result: Array[EffectData] = []
	for modifier: Modifier in modifiers:
		if modifier.kind == kind and modifier.effect != null:
			result.append(modifier.effect)
	return result


func is_empty() -> bool:
	return modifiers.is_empty()


func clone() -> ModifierSet:
	var copy: ModifierSet = ModifierSet.new()
	copy.modifiers = modifiers.duplicate()
	return copy
