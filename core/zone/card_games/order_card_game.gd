class_name OrderCardGame
extends RefCounted
## Fable Nov 16b (Part 2): the Endless Buffet's card minigame, "Order Up" - exact-cost orders. A ticket shows a total (say 7); six cards
## lie face up on the pass. Pick cards whose COSTS add up to exactly the ticket and ring the bell. Three tickets make a shift. The row
## may be swapped for a fresh one twice; an order rung up with the wrong total is sent back, and the third one sent back ends the shift.
## Every row holds at least one right answer. Replaces the old ingredient-stacking "Order Up!" at Chef Turbo's pass; the rewards are that
## game's (`OrderGame.apply_result`). Pure rules: `OrderCardScreen` is the pass.

const TICKETS: int = 3
const ROW_SIZE: int = 6
const SWAPS: int = 2
const SENT_BACK_LIMIT: int = 3
## How many cards the answer a row is built round uses, per ticket.
const ANSWER_SIZES: Array[int] = [2, 2, 3]

var pool: Array[CardData] = []
var rng: RandomNumberGenerator
var row: Array[CardData] = []
var target: int = 0
var ticket: int = 0
var swaps_left: int = SWAPS
var sent_back: int = 0
## Indices into `row` that are on the plate.
var picked: Array[int] = []
## One entry per served ticket: its total.
var served: Array[int] = []


## Starts a shift from `cards` (their costs are what counts; cost-0 cards are left out) with `rng`.
static func deal(cards: Array[CardData], random: RandomNumberGenerator) -> OrderCardGame:
	var game: OrderCardGame = OrderCardGame.new()
	game.rng = random
	for card: CardData in cards:
		if card.energy_value() >= 1:
			game.pool.append(card)
	game._new_ticket()
	return game


func _new_ticket() -> void:
	picked.clear()
	var answer: Array[CardData] = _draw_distinct(ANSWER_SIZES[mini(ticket, ANSWER_SIZES.size() - 1)], [])
	target = 0
	for card: CardData in answer:
		target += card.energy_value()
	_fill_row(answer)


## A fresh row for the same ticket (it holds a right answer too). False when no swap is left.
func swap_row() -> bool:
	if swaps_left <= 0 or is_over():
		return false
	swaps_left -= 1
	picked.clear()
	_fill_row(_answer_for(target))
	return true


## The row: the answer's cards and random others, shuffled.
func _fill_row(answer: Array[CardData]) -> void:
	var cards: Array[CardData] = answer.duplicate()
	cards.append_array(_draw_distinct(ROW_SIZE - cards.size(), cards))
	# Fisher-Yates with the game's own generator (Array.shuffle uses the global one).
	for index: int in range(cards.size() - 1, 0, -1):
		var other: int = rng.randi_range(0, index)
		var held: CardData = cards[index]
		cards[index] = cards[other]
		cards[other] = held
	row = cards


func _draw_distinct(count: int, without: Array[CardData]) -> Array[CardData]:
	var result: Array[CardData] = []
	var guard: int = 0
	while result.size() < count and guard < 500 and not pool.is_empty():
		guard += 1
		var card: CardData = pool[rng.randi_range(0, pool.size() - 1)]
		if not result.has(card) and not without.has(card):
			result.append(card)
	return result


## Two or three different cards of the pool whose costs add up to `total` (one is always there: the ticket was made from such a set).
func _answer_for(total: int) -> Array[CardData]:
	var found: Array[Array] = []
	for first: int in range(pool.size()):
		for second: int in range(first + 1, pool.size()):
			var pair: int = pool[first].energy_value() + pool[second].energy_value()
			if pair == total:
				found.append([pool[first], pool[second]])
			elif pair < total:
				for third: int in range(second + 1, pool.size()):
					if pair + pool[third].energy_value() == total:
						found.append([pool[first], pool[second], pool[third]])
	var result: Array[CardData] = []
	if found.is_empty():
		return result
	for card: Variant in found[rng.randi_range(0, found.size() - 1)]:
		result.append(card as CardData)
	return result


func is_won() -> bool:
	return ticket >= TICKETS


func is_lost() -> bool:
	return sent_back >= SENT_BACK_LIMIT


func is_over() -> bool:
	return is_won() or is_lost()


## Puts row card `index` on the plate, or takes it off again.
func toggle(index: int) -> void:
	if is_over() or index < 0 or index >= row.size():
		return
	if picked.has(index):
		picked.erase(index)
	else:
		picked.append(index)


## The costs on the plate, added up.
func total() -> int:
	var sum: int = 0
	for index: int in picked:
		sum += row[index].energy_value()
	return sum


## Rings the bell. True when the plate's total is the ticket's: the next ticket comes up (or the shift is won). False: sent back.
func serve() -> bool:
	if is_over() or picked.is_empty():
		return false
	if total() != target:
		sent_back += 1
		picked.clear()
		return false
	served.append(target)
	ticket += 1
	picked.clear()
	if not is_won():
		_new_ticket()
	return true


## Row indices that make the ticket's total (the smallest set), for the tests and the "show me" of a lost shift; [] when there is none.
func solution() -> Array[int]:
	var best: Array[int] = []
	for mask: int in range(1, 1 << row.size()):
		var sum: int = 0
		var indices: Array[int] = []
		for index: int in range(row.size()):
			if mask & (1 << index):
				sum += row[index].energy_value()
				indices.append(index)
		if sum == target and (best.is_empty() or indices.size() < best.size()):
			best = indices
	return best


func stars() -> int:
	return CardGamePool.stars_for(is_won(), sent_back + (SWAPS - swaps_left))
