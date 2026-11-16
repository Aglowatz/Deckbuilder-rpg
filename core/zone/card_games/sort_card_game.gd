class_name SortCardGame
extends RefCounted
## Fable Nov 16b (Part 2): the Verdant Dump's card minigame, "Sort It Out" - conveyor sorting. Twenty cards ride a slow belt, one after
## another; send the front card into the bin of its TYPE (Unit, Spell, Infrastructure, Other) before it falls off the end. Sixteen
## right wins. The belt speeds up gently. A fifth card lost (wrong bin or off the end) stops the belt: sixteen can no longer be
## reached. Replaces the junk-sorting "Sort It Out!" on the fair stage; the rewards are that game's (`SortGame.apply_result`). Pure rules
## (no clock of its own): `SortCardScreen` feeds in the time.

const CARDS: int = 20
const TO_WIN: int = 16
const BIN_COUNT: int = 4
## Card i appears at FIRST + i * GAP - i * i * SQUEEZE seconds and reaches the end TRAVEL - i * SHRINK seconds later.
const FIRST: float = 0.8
const GAP: float = 3.0
const SQUEEZE: float = 0.035
const TRAVEL: float = 9.0
const SHRINK: float = 0.12
## How many of the twenty are of each kind (Unit, Spell, Infrastructure, Other): every bin gets used.
const KIND_COUNTS: Array[int] = [8, 5, 3, 4]

enum Result { IGNORED, CORRECT, WRONG }

var cards: Array[CardData] = []
## Per card: 1 = right bin, 0 = wrong bin, -1 = fell off the end. Filled in order.
var outcomes: Array[int] = []
var next_card: int = 0


## Deals the belt: KIND_COUNTS cards of each kind from `pool` and `infrastructure`, shuffled with `rng` (never three of a kind in a row
## at the start, so the first cards show more than one bin).
static func deal(pool: Array[CardData], infrastructure: Array[CardData], rng: RandomNumberGenerator) -> SortCardGame:
	var game: SortCardGame = SortCardGame.new()
	var by_kind: Array[Array] = [[], [], [], []]
	for card: CardData in pool:
		by_kind[CardGamePool.kind_of(card)].append(card)
	for card: CardData in infrastructure:
		by_kind[CardGamePool.Kind.INFRASTRUCTURE].append(card)
	for kind: int in range(BIN_COUNT):
		var source: Array = by_kind[kind]
		if source.is_empty():
			continue
		var start: int = rng.randi_range(0, source.size() - 1)
		for step: int in range(KIND_COUNTS[kind]):
			game.cards.append(source[(start + step * 7) % source.size()] as CardData)
	# Top up from the units when a kind has no cards at all.
	var units: Array = by_kind[CardGamePool.Kind.UNIT]
	while game.cards.size() < CARDS and not units.is_empty():
		game.cards.append(units[rng.randi_range(0, units.size() - 1)] as CardData)
	for index: int in range(game.cards.size() - 1, 0, -1):
		var other: int = rng.randi_range(0, index)
		var held: CardData = game.cards[index]
		game.cards[index] = game.cards[other]
		game.cards[other] = held
	return game


static func spawn_time(card: int) -> float:
	return FIRST + float(card) * GAP - float(card * card) * SQUEEZE


static func end_time(card: int) -> float:
	return spawn_time(card) + TRAVEL - float(card) * SHRINK


## Where along the belt a card is at `time` (0 = just appeared, 1 = at the end), clamped.
static func progress(card: int, time: float) -> float:
	return clampf((time - spawn_time(card)) / (end_time(card) - spawn_time(card)), 0.0, 1.0)


func bin_of(card: int) -> int:
	return int(CardGamePool.kind_of(cards[card]))


func lost_count() -> int:
	return outcomes.size() - correct_count()


func correct_count() -> int:
	var count: int = 0
	for outcome: int in outcomes:
		if outcome == 1:
			count += 1
	return count


func is_won() -> bool:
	return correct_count() >= TO_WIN and is_finished()


## Sixteen can no longer be reached.
func is_lost() -> bool:
	return lost_count() > cards.size() - TO_WIN


func is_finished() -> bool:
	return next_card >= cards.size() or is_lost()


## True when the front card has appeared on the belt by `time`.
func front_visible(time: float) -> bool:
	return not is_finished() and time >= spawn_time(next_card)


## A press of bin `bin` at `time`: judged against the front card (presses before it appears are ignored).
func press(bin: int, time: float) -> Result:
	if not front_visible(time):
		return Result.IGNORED
	var correct: bool = bin == bin_of(next_card)
	outcomes.append(1 if correct else 0)
	next_card += 1
	return Result.CORRECT if correct else Result.WRONG


## Call as the clock advances: a card that reached the end unsorted is lost. Returns how many fell this call.
func advance(time: float) -> int:
	var lost: int = 0
	while not is_finished() and time > end_time(next_card):
		outcomes.append(-1)
		next_card += 1
		lost += 1
	return lost


func stars() -> int:
	return CardGamePool.stars_for(is_won(), lost_count())
