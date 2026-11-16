class_name FileCardGame
extends RefCounted
## Fable Nov 16b (Part 2): the D.N.A.'s card minigame, "File in Order" - filing. Seven cards lie face up in the wrong order. Put them
## in the cabinet in ascending COST (cards of the same cost: the lower POWER first) by swapping two at a time, in at most nine swaps.
## The stamp checks the order: the first check that finds cards out of place is free and shows which ones; a second such check, or a
## wrong order when the ninth swap is spent, is REJECTED. A right order is APPROVED. Replaces "Pneumatic Soul Routing" at the Mail Room's
## terminal, with its one-time reward (the zone's puzzle gear, granted by the zone scene on `solved`). Pure rules: `FileCardScreen` is the
## cabinet.

const CARDS: int = 7
const MAX_SWAPS: int = 9
const FREE_CHECKS: int = 1

## The cards as they lie now, left to right.
var cards: Array[CardData] = []
var swaps: int = 0
var checks: int = 0
var approved: bool = false
var rejected: bool = false


## A card's place in the order: its cost, then its power (a unit's attack; other cards have none).
static func key_of(card: CardData) -> int:
	return card.energy_value() * 100 + CardGamePool.power_of(card)


## Deals seven cards with seven different (cost, power) keys from `pool`, scattered so that at least four are out of place.
static func deal(pool: Array[CardData], rng: RandomNumberGenerator) -> FileCardGame:
	var game: FileCardGame = FileCardGame.new()
	var by_key: Dictionary = {}
	var order: Array[CardData] = pool.duplicate()
	for index: int in range(order.size() - 1, 0, -1):
		var other: int = rng.randi_range(0, index)
		var held: CardData = order[index]
		order[index] = order[other]
		order[other] = held
	# Different costs first (the order then reads off the cost alone), then other keys until there are seven.
	var costs: Dictionary = {}
	for card: CardData in order:
		if game.cards.size() < CARDS and not costs.has(card.energy_value()):
			costs[card.energy_value()] = true
			by_key[key_of(card)] = true
			game.cards.append(card)
	for card: CardData in order:
		if game.cards.size() < CARDS and not by_key.has(key_of(card)) and card.is_unit():
			by_key[key_of(card)] = true
			game.cards.append(card)
	for attempt: int in range(40):
		for index: int in range(game.cards.size() - 1, 0, -1):
			var other: int = rng.randi_range(0, index)
			var held: CardData = game.cards[index]
			game.cards[index] = game.cards[other]
			game.cards[other] = held
		if game.out_of_place().size() >= mini(4, game.cards.size()):
			break
	return game


## The cards in the order the cabinet wants.
func sorted_cards() -> Array[CardData]:
	var result: Array[CardData] = cards.duplicate()
	result.sort_custom(func(a: CardData, b: CardData) -> bool: return key_of(a) < key_of(b))
	return result


## The slots whose card does not belong there.
func out_of_place() -> Array[int]:
	var wanted: Array[CardData] = sorted_cards()
	var result: Array[int] = []
	for index: int in range(cards.size()):
		if key_of(cards[index]) != key_of(wanted[index]):
			result.append(index)
	return result


func in_order() -> bool:
	return out_of_place().is_empty()


func swaps_left() -> int:
	return MAX_SWAPS - swaps


func free_checks_left() -> int:
	return maxi(0, FREE_CHECKS - checks)


func is_over() -> bool:
	return approved or rejected


## Swaps the cards in slots `a` and `b`. False when it cannot be done (the same slot, no swap left, the file is closed).
func swap(a: int, b: int) -> bool:
	if is_over() or a == b or a < 0 or b < 0 or a >= cards.size() or b >= cards.size() or swaps >= MAX_SWAPS:
		return false
	var held: CardData = cards[a]
	cards[a] = cards[b]
	cards[b] = held
	swaps += 1
	return true


## The stamp. Returns the slots out of place: [] means APPROVED. A wrong order is forgiven while a free check is left and a swap can
## still be made; otherwise it is REJECTED.
func stamp() -> Array[int]:
	if is_over():
		return []
	var wrong: Array[int] = out_of_place()
	if wrong.is_empty():
		approved = true
		return wrong
	checks += 1
	if checks > FREE_CHECKS or swaps >= MAX_SWAPS:
		rejected = true
	return wrong


## The fewest swaps that put the cards in order from here (cards minus the cycles of the permutation).
func swaps_needed() -> int:
	var wanted: Array[CardData] = sorted_cards()
	var goes_to: Array[int] = []
	for card: CardData in cards:
		goes_to.append(wanted.find(card))
	var seen: Array[bool] = []
	seen.resize(cards.size())
	seen.fill(false)
	var cycles: int = 0
	for start: int in range(cards.size()):
		if seen[start]:
			continue
		cycles += 1
		var at: int = start
		while not seen[at]:
			seen[at] = true
			at = goes_to[at]
	return cards.size() - cycles


func stars() -> int:
	return CardGamePool.stars_for(approved, maxi(0, swaps - 6) + checks)
