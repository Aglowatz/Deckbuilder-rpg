class_name FirstDuel
extends RefCounted
## Fable pass Nov 1 (Part 6, the first hour): the very first duel (the Scavenger's Den) deals a TEACHING HAND instead of a random one, so
## the tutorial's steps are always on the table: two basic Infrastructure (one per turn: energy and the Path's Resource), the two cheapest
## units of the starter (something to play on turn 1 and 2, something to attack and block with) and the cheapest other card (a trick).
## The rule reads the deck, so every Path's starter gets its own hand and a later starter change needs no edit here. The free mulligan
## stays (it deals a normal hand). `GameOptions.scripted_opening_hand` carries the ids; `GameState._deal_opening_hand` pulls them.

const BASICS: int = 2
const UNITS: int = 2
const OTHERS: int = 1


## The card ids of the teaching hand for `cards` (a deck's list), `hand_size` long; the leftover slots take more cheap units, then basics.
static func opening_hand_ids(cards: Array[CardData], hand_size: int = 5) -> Array[String]:
	var basics: Array[CardData] = []
	var units: Array[CardData] = []
	var others: Array[CardData] = []
	for card: CardData in cards:
		if card == null:
			continue
		if card.is_infrastructure():
			basics.append(card)
		elif card.is_unit():
			units.append(card)
		else:
			others.append(card)
	units.sort_custom(_cheaper)
	others.sort_custom(_cheaper)
	var ids: Array[String] = []
	_take(ids, basics, BASICS, hand_size)
	_take(ids, units, UNITS, hand_size)
	_take(ids, others, OTHERS, hand_size)
	# Fill: more cheap units first (something to do), then basics.
	_take(ids, units, hand_size, hand_size)
	_take(ids, basics, hand_size, hand_size)
	return ids


## The same from a `Deck`.
static func opening_hand_for_deck(deck: Deck, hand_size: int = 5) -> Array[String]:
	return opening_hand_ids(deck.cards if deck != null else ([] as Array[CardData]), hand_size)


## Sets the teaching hand on `options` for the hero (seat 0).
static func apply(options: GameOptions, deck: Deck, hand_size: int = 5) -> void:
	options.scripted_opening_hand = opening_hand_for_deck(deck, hand_size)
	options.scripted_hand_player = 0


static func _cheaper(a: CardData, b: CardData) -> bool:
	if a.generic_cost != b.generic_cost:
		return a.generic_cost < b.generic_cost
	return a.id < b.id


## Appends up to `count` ids from `pool` (each card once: the pool is consumed) while `ids` stays under `limit`.
static func _take(ids: Array[String], pool: Array[CardData], count: int, limit: int) -> void:
	var taken: int = 0
	while taken < count and ids.size() < limit and not pool.is_empty():
		ids.append((pool.pop_front() as CardData).id)
		taken += 1
