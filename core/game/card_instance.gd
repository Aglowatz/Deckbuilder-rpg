class_name CardInstance
extends RefCounted
## A concrete card in a game: static CardData plus mutable per-game state.

var uid: int = 0
var data: CardData
## The player who CONTROLS this card (the player whose zones it sits in). Changes when control is gained.
var owner: int = 0
## The player who owns the physical card: where it goes when it dies, is sent back or is shredded.
var real_owner: int = 0
var damage: int = 0
var exhausted: bool = false
var summoning_sick: bool = false
var face_down: bool = false
var activated_this_turn: bool = false
## Permanent stat changes (buffs, Iron, Red Tape, "gets +1 attack permanently"...).
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
## Brief 14: how many buffs (permanent +1/+1) this unit has received.
var buffs: int = 0
## Brief 14: the unit this Tool is attached to (0 = not attached).
var attached_to: int = 0
## Brief 14: how many of its controller's upcoming turns this card does NOT refresh (Contract, Overexert, Food Coma...).
var skip_refresh: int = 0
## Brief 14: a card created as, or turned into, a token (Plate, token copies): it never goes to a Refuse Pile.
var token_override: bool = false
## Brief 14: base stat overrides ("its defense becomes 1"); -1 = none.
var set_defense: int = -1
var set_attack: int = -1
## Brief 14: cannot be targeted / damaged until the START of this turn number (turn counter value).
var protected_until_turn: int = 0
## Brief 14: "can't block this turn" (until end of turn).
var temp_cannot_block: bool = false
## Brief 14: abilities (by index) already used this turn ("Do this only once per turn").
var used_abilities: Array[int] = []
## Brief 14: uids this card's abilities targeted this turn ("each unit can be targeted only once per turn").
var targeted_this_turn: Array[int] = []
## Brief 14: the turn this card entered the field.
var entered_turn: int = 0
## Brief 14: for a Clause token in a deck, the player who created it.
var creator: int = -1
## Brief 14: Toxic damage was dealt to this unit (it is destroyed at the next check unless Unbreakable).
var toxic_hit: bool = false


func has_keyword(keyword: CardEnums.Keyword) -> bool:
	return (
		data.keywords.has(keyword)
		or granted_keywords.has(keyword)
		or temp_keywords.has(keyword)
	)


func is_token() -> bool:
	return data.is_token or token_override


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
	buffs = 0
	attached_to = 0
	skip_refresh = 0
	token_override = false
	set_defense = -1
	set_attack = -1
	protected_until_turn = 0
	temp_cannot_block = false
	used_abilities.clear()
	targeted_this_turn.clear()
	entered_turn = 0
	creator = -1
	toxic_hit = false
	owner = real_owner


func clear_end_of_turn() -> void:
	damage = 0
	temp_attack = 0
	temp_defense = 0
	temp_keywords.clear()
	temp_cannot_block = false
	toxic_hit = false


func clone() -> CardInstance:
	var copy: CardInstance = CardInstance.new()
	copy.uid = uid
	copy.data = data
	copy.owner = owner
	copy.real_owner = real_owner
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
	copy.buffs = buffs
	copy.attached_to = attached_to
	copy.skip_refresh = skip_refresh
	copy.token_override = token_override
	copy.set_defense = set_defense
	copy.set_attack = set_attack
	copy.protected_until_turn = protected_until_turn
	copy.temp_cannot_block = temp_cannot_block
	copy.used_abilities = used_abilities.duplicate()
	copy.targeted_this_turn = targeted_this_turn.duplicate()
	copy.entered_turn = entered_turn
	copy.creator = creator
	copy.toxic_hit = toxic_hit
	return copy
