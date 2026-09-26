class_name PlayerState
extends RefCounted
## One player's zones and numbers. The top of the library is the END of the array.

var index: int = 0
var player_name: String = ""
var life: int = 0
var max_life: int = 0
var max_hand_size: int = 10
var opening_hand_size: int = 5
var modifiers: ModifierSet = ModifierSet.new()
## land count / deck size, fixed at deck construction (used by the hand smoother).
var deck_land_ratio: float = 0.0
var library: Array[CardInstance] = []
var hand: Array[CardInstance] = []
## Creatures and artifacts.
var battlefield: Array[CardInstance] = []
var lands: Array[CardInstance] = []
var graveyard: Array[CardInstance] = []
## Face-down traps.
var traps: Array[CardInstance] = []
var lands_played: int = 0
var mulligan_used: bool = false
## Set when the player must lose (deck-out); resolved with life checks.
var lost: bool = false


static func find_in(zone: Array[CardInstance], uid: int) -> CardInstance:
	for card: CardInstance in zone:
		if card.uid == uid:
			return card
	return null


func find_hand(uid: int) -> CardInstance:
	return find_in(hand, uid)


func find_battlefield(uid: int) -> CardInstance:
	return find_in(battlefield, uid)


func find_land(uid: int) -> CardInstance:
	return find_in(lands, uid)


func find_trap(uid: int) -> CardInstance:
	return find_in(traps, uid)


func creatures() -> Array[CardInstance]:
	var result: Array[CardInstance] = []
	for card: CardInstance in battlefield:
		if card.data.is_creature():
			result.append(card)
	return result


func untapped_lands() -> Array[CardInstance]:
	var result: Array[CardInstance] = []
	for land: CardInstance in lands:
		if not land.tapped:
			result.append(land)
	return result


## `deep_library` copies library cards; otherwise the clone shares the (unmodified) library
## instances, which is enough for one-step look-ahead. `keep_traps` = false hides set traps.
func clone(deep_library: bool = true, keep_traps: bool = true) -> PlayerState:
	var copy: PlayerState = PlayerState.new()
	copy.index = index
	copy.player_name = player_name
	copy.life = life
	copy.max_life = max_life
	copy.max_hand_size = max_hand_size
	copy.opening_hand_size = opening_hand_size
	copy.modifiers = modifiers
	copy.deck_land_ratio = deck_land_ratio
	copy.lands_played = lands_played
	copy.mulligan_used = mulligan_used
	copy.lost = lost
	if deep_library:
		copy.library = _clone_zone(library)
	else:
		copy.library = library.duplicate()
	copy.hand = _clone_zone(hand)
	copy.battlefield = _clone_zone(battlefield)
	copy.lands = _clone_zone(lands)
	copy.graveyard = graveyard.duplicate()
	if keep_traps:
		copy.traps = _clone_zone(traps)
	return copy


static func _clone_zone(zone: Array[CardInstance]) -> Array[CardInstance]:
	var result: Array[CardInstance] = []
	for card: CardInstance in zone:
		result.append(card.clone())
	return result
