class_name CardData
extends Resource
## Static definition of a card. Stored as .tres in data/cards/.

@export var id: String = ""
@export var display_name: String = ""
@export var type: CardEnums.CardType = CardEnums.CardType.CREATURE
## For infrastructure: the Path energy type produced. For others: the card's color identity.
@export var color: Affinity.Type = Affinity.Type.NEUTRAL
## Generic Path energy (payable by any infrastructure).
@export var generic_cost: int = 0
## One entry per colored pip; each must be paid by an infrastructure of that type.
@export var colored_pips: Array[Affinity.Type] = []
@export var power: int = 0
@export var toughness: int = 1
@export var keywords: Array[CardEnums.Keyword] = []
@export_multiline var rules_text: String = ""
@export var effects: Array[EffectData] = []
@export var rarity: CardEnums.Rarity = CardEnums.Rarity.COMMON
@export_multiline var flavor_text: String = ""
## Basic infrastructure are exempt from the copy limit.
@export var is_basic: bool = false
## Tokens are created by effects and cease to exist outside the battlefield.
@export var is_token: bool = false


func energy_value() -> int:
	return generic_cost + colored_pips.size()


func is_infrastructure() -> bool:
	return type == CardEnums.CardType.INFRASTRUCTURE


func is_creature() -> bool:
	return type == CardEnums.CardType.CREATURE


## Creatures and artifacts stay on the battlefield after being cast.
func is_permanent() -> bool:
	return type == CardEnums.CardType.CREATURE or type == CardEnums.CardType.ARTIFACT


func has_keyword(keyword: CardEnums.Keyword) -> bool:
	return keywords.has(keyword)


func effects_for(trigger: CardEnums.Trigger) -> Array[EffectData]:
	var result: Array[EffectData] = []
	for effect: EffectData in effects:
		if effect.trigger == trigger:
			result.append(effect)
	return result


func has_trigger(trigger: CardEnums.Trigger) -> bool:
	for effect: EffectData in effects:
		if effect.trigger == trigger:
			return true
	return false


## Infrastructure (and basic cards) are exempt from the 4-copy limit and never need to be owned.
func is_unlimited() -> bool:
	return is_basic or is_infrastructure()
