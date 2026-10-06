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
var attack_bonus: int = 0
var defense_bonus: int = 0
## Until-end-of-turn stat changes.
var temp_attack: int = 0
var temp_defense: int = 0
var granted_keywords: Array[CardEnums.Keyword] = []
var temp_keywords: Array[CardEnums.Keyword] = []
## New brief, Part B: set once on entering the field if the controller's equipment grants
## it (e.g. Hover Boots) - this unit can never be declared as a blocker.
var cannot_block: bool = false


func has_keyword(keyword: CardEnums.Keyword) -> bool:
	return (
		data.keywords.has(keyword)
		or granted_keywords.has(keyword)
		or temp_keywords.has(keyword)
	)


## Clears all per-game state (used when a card leaves the field).
func reset() -> void:
	damage = 0
	exhausted = false
	summoning_sick = false
	face_down = false
	activated_this_turn = false
	attack_bonus = 0
	defense_bonus = 0
	temp_attack = 0
	temp_defense = 0
	granted_keywords.clear()
	temp_keywords.clear()
	cannot_block = false


func clear_end_of_turn() -> void:
	damage = 0
	temp_attack = 0
	temp_defense = 0
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
	copy.attack_bonus = attack_bonus
	copy.defense_bonus = defense_bonus
	copy.temp_attack = temp_attack
	copy.temp_defense = temp_defense
	copy.granted_keywords = granted_keywords.duplicate()
	copy.temp_keywords = temp_keywords.duplicate()
	copy.cannot_block = cannot_block
	return copy
