class_name CardInstance
extends RefCounted
## A concrete card in a game: static CardData plus mutable per-game state.

var uid: int = 0
var data: CardData
var owner: int = 0
var damage: int = 0
var exhausted: bool = false
var summoning_sick: bool = false
var face_down: bool = false
var activated_this_turn: bool = false
## Permanent stat changes.
var power_bonus: int = 0
var toughness_bonus: int = 0
## Until-end-of-turn stat changes.
var temp_power: int = 0
var temp_toughness: int = 0
var granted_keywords: Array[CardEnums.Keyword] = []
var temp_keywords: Array[CardEnums.Keyword] = []
## New brief, Part B: set once on entering the battlefield if the controller's equipment grants
## it (e.g. Hover Boots) - this creature can never be declared as a blocker.
var cannot_block: bool = false


func has_keyword(keyword: CardEnums.Keyword) -> bool:
	return (
		data.keywords.has(keyword)
		or granted_keywords.has(keyword)
		or temp_keywords.has(keyword)
	)


## Clears all per-game state (used when a card leaves the battlefield).
func reset() -> void:
	damage = 0
	exhausted = false
	summoning_sick = false
	face_down = false
	activated_this_turn = false
	power_bonus = 0
	toughness_bonus = 0
	temp_power = 0
	temp_toughness = 0
	granted_keywords.clear()
	temp_keywords.clear()
	cannot_block = false


func clear_end_of_turn() -> void:
	damage = 0
	temp_power = 0
	temp_toughness = 0
	temp_keywords.clear()


func clone() -> CardInstance:
	var copy: CardInstance = CardInstance.new()
	copy.uid = uid
	copy.data = data
	copy.owner = owner
	copy.damage = damage
	copy.exhausted = exhausted
	copy.summoning_sick = summoning_sick
	copy.face_down = face_down
	copy.activated_this_turn = activated_this_turn
	copy.power_bonus = power_bonus
	copy.toughness_bonus = toughness_bonus
	copy.temp_power = temp_power
	copy.temp_toughness = temp_toughness
	copy.granted_keywords = granted_keywords.duplicate()
	copy.temp_keywords = temp_keywords.duplicate()
	copy.cannot_block = cannot_block
	return copy
