class_name PlayerState
extends RefCounted
## One player's zones and numbers. The top of the deck is the END of the array.

var index: int = 0
var player_name: String = ""
var hp: int = 0
var max_hp: int = 0
var max_hand_size: int = 10
var opening_hand_size: int = 5
var max_traps: int = GameState.MAX_TRAPS
var modifiers: ModifierSet = ModifierSet.new()
## infrastructure count / deck size, fixed at deck construction (used by the hand smoother).
var deck_infrastructure_ratio: float = 0.0
var deck: Array[CardInstance] = []
var hand: Array[CardInstance] = []
## Units and wonders.
var field: Array[CardInstance] = []
var infrastructure: Array[CardInstance] = []
var refuse_pile: Array[CardInstance] = []
## Face-down traps.
var traps: Array[CardInstance] = []
var infrastructure_played: int = 0
var mulligan_used: bool = false
## Set when the player must lose (deck-out); resolved with HP checks.
var lost: bool = false
## New brief, Part B: whether this player has begun their first turn yet (FIRST_TURN_EXTRA_DRAW).
var has_taken_first_turn: bool = false
## New brief, Part B: non-infrastructure cards play so far this turn, and the cap (MAX_NON_INFRASTRUCTURE_CASTS_PER_TURN;
## -1 = unlimited), reset/computed alongside max_hand_size etc.
var non_infrastructure_plays_this_turn: int = 0
var non_infrastructure_play_cap: int = -1
## New brief, Part F: how many SCRIPTED_ESCALATING_SUMMON activations this player has had this
## duel - selects which stage (capped at the last) the next one summons.
var scripted_summon_count: int = 0
## Brief 14: Resources (Iron, Red Tape, Contract, Ingredient, Garbage) are token permanents in their own zone.
var resources: Array[CardInstance] = []
## Brief 14: floating energy (from "add (R)" abilities): each entry is an Affinity.Type, or POOL_ANY for "one energy of any
## Path". It is spent before infrastructure and empties at the end of the turn.
var pool: Array[int] = []
## Cards played so far this turn (any type), for "for each other card they've played this turn".
var cards_played_this_turn: int = 0


const POOL_ANY: int = -1


static func find_in(zone: Array[CardInstance], uid: int) -> CardInstance:
	for card: CardInstance in zone:
		if card.uid == uid:
			return card
	return null


func find_hand(uid: int) -> CardInstance:
	return find_in(hand, uid)


func find_field(uid: int) -> CardInstance:
	return find_in(field, uid)


func find_infrastructure(uid: int) -> CardInstance:
	return find_in(infrastructure, uid)


func find_trap(uid: int) -> CardInstance:
	return find_in(traps, uid)


func find_resource(uid: int) -> CardInstance:
	return find_in(resources, uid)


## How many resources of `kind` this player controls.
func count_resource(kind: ResourceKind.Kind) -> int:
	var total: int = 0
	for resource: CardInstance in resources:
		if resource.data.resource_kind == int(kind):
			total += 1
	return total


func wonders() -> Array[CardInstance]:
	var result: Array[CardInstance] = []
	for card: CardInstance in field:
		if card.data.is_wonder():
			result.append(card)
	return result


func tools() -> Array[CardInstance]:
	var result: Array[CardInstance] = []
	for card: CardInstance in field:
		if card.data.is_tool():
			result.append(card)
	return result


func units() -> Array[CardInstance]:
	var result: Array[CardInstance] = []
	for card: CardInstance in field:
		if card.data.is_unit():
			result.append(card)
	return result


func ready_infrastructure() -> Array[CardInstance]:
	var result: Array[CardInstance] = []
	for infra: CardInstance in infrastructure:
		if not infra.exhausted:
			result.append(infra)
	return result


## `deep_deck` copies deck cards; otherwise the clone shares the (unmodified) deck
## instances, which is enough for one-step look-ahead. `keep_traps` = false hides set traps.
func clone(deep_deck: bool = true, keep_traps: bool = true) -> PlayerState:
	var copy: PlayerState = PlayerState.new()
	copy.index = index
	copy.player_name = player_name
	copy.hp = hp
	copy.max_hp = max_hp
	copy.max_hand_size = max_hand_size
	copy.opening_hand_size = opening_hand_size
	copy.max_traps = max_traps
	copy.modifiers = modifiers
	copy.deck_infrastructure_ratio = deck_infrastructure_ratio
	copy.infrastructure_played = infrastructure_played
	copy.mulligan_used = mulligan_used
	copy.lost = lost
	copy.has_taken_first_turn = has_taken_first_turn
	copy.non_infrastructure_plays_this_turn = non_infrastructure_plays_this_turn
	copy.non_infrastructure_play_cap = non_infrastructure_play_cap
	copy.scripted_summon_count = scripted_summon_count
	copy.pool = pool.duplicate()
	copy.cards_played_this_turn = cards_played_this_turn
	copy.resources = _clone_zone(resources)
	if deep_deck:
		copy.deck = _clone_zone(deck)
	else:
		copy.deck = deck.duplicate()
	copy.hand = _clone_zone(hand)
	copy.field = _clone_zone(field)
	copy.infrastructure = _clone_zone(infrastructure)
	copy.refuse_pile = refuse_pile.duplicate()
	if keep_traps:
		copy.traps = _clone_zone(traps)
	return copy


static func _clone_zone(zone: Array[CardInstance]) -> Array[CardInstance]:
	var result: Array[CardInstance] = []
	for card: CardInstance in zone:
		result.append(card.clone())
	return result
