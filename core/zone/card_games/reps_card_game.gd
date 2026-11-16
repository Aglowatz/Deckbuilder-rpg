class_name RepsCardGame
extends RefCounted
## Fable Nov 16b (Part 2): the Gainlands' card minigame, "Reps" - higher or lower. One unit card lies face up; guess whether the next
## card's POWER is higher or lower (a tie counts as right either way). Eight right in a row wins the set; a miss drops the streak back
## to nothing, and the fourth miss ends the set (three are allowed). Replaces the Rep Counter at Chet Thunderabs' studio; the rewards
## are the Rep Counter's (`RepGame.apply_result`). Pure rules: `RepsCardScreen` is the bench.
##
## The deal is friendly, not blind: after a low card the next one is more often higher, after a high card more often lower, and middling
## cards come up less often, so "guess away from the edge" wins a first set about four times in five (tests/core/zone/test_card_games.gd).

const STREAK_TO_WIN: int = 8
const MISSES_ALLOWED: int = 3
## How many cards one set can need at most: four runs of seven and their misses, then eight.
const DECK_SIZE: int = 44
## How much less often a card on the "wrong" side of the natural guess is dealt.
const AGAINST_WEIGHT: float = 0.22

## The whole set, dealt up front: `deck[position]` is face up, `deck[position + 1]` is the card being guessed.
var deck: Array[CardData] = []
var position: int = 0
var streak: int = 0
var best_streak: int = 0
var misses: int = 0
## One entry per guess: true = right.
var guesses: Array[bool] = []


## Deals a set from `units` (at least four cards with at least two different powers) with `rng`.
static func deal(units: Array[CardData], rng: RandomNumberGenerator) -> RepsCardGame:
	var game: RepsCardGame = RepsCardGame.new()
	if units.is_empty():
		return game
	var low: int = units[0].attack
	var high: int = units[0].attack
	for card: CardData in units:
		low = mini(low, card.attack)
		high = maxi(high, card.attack)
	var middle: float = float(low + high) * 0.5
	var spread: float = maxf(1.0, float(high - low))
	# The first card is one of the clearer ones (not in the middle of the range).
	var current: CardData = _pick(units, null, middle, spread, 0.0, rng)
	game.deck.append(current)
	while game.deck.size() < DECK_SIZE:
		var lean: float = 0.0
		if float(current.attack) < middle:
			lean = 1.0
		elif float(current.attack) > middle:
			lean = -1.0
		current = _pick(units, current, middle, spread, lean, rng)
		game.deck.append(current)
	return game


## One weighted draw: never the card that is face up; cards far from the middle count more; with a `lean` (+1 after a low card, -1 after
## a high one) the cards that would make the natural guess wrong count AGAINST_WEIGHT.
static func _pick(units: Array[CardData], current: CardData, middle: float, spread: float, lean: float, rng: RandomNumberGenerator) -> CardData:
	var weights: Array[float] = []
	var total: float = 0.0
	for card: CardData in units:
		var weight: float = 0.0
		if card != current:
			weight = 0.45 + absf(float(card.attack) - middle) / spread
			if current != null and lean > 0.0 and card.attack < current.attack:
				weight *= AGAINST_WEIGHT
			elif current != null and lean < 0.0 and card.attack > current.attack:
				weight *= AGAINST_WEIGHT
		weights.append(weight)
		total += weight
	var roll: float = rng.randf() * total
	for index: int in range(units.size()):
		roll -= weights[index]
		if roll <= 0.0 and weights[index] > 0.0:
			return units[index]
	return units[units.size() - 1] if units[units.size() - 1] != current else units[0]


## The card lying face up.
func current() -> CardData:
	return deck[position] if position < deck.size() else null


## The face-down card the next guess is about.
func upcoming() -> CardData:
	return deck[position + 1] if position + 1 < deck.size() else null


func is_won() -> bool:
	return streak >= STREAK_TO_WIN


func is_lost() -> bool:
	return misses > MISSES_ALLOWED or (not is_won() and upcoming() == null)


func is_over() -> bool:
	return is_won() or is_lost()


## Would "higher" (or "lower") be right for the two cards on the table? A tie is right either way.
func would_be_right(higher: bool) -> bool:
	var shown: CardData = current()
	var next: CardData = upcoming()
	if shown == null or next == null:
		return false
	if next.attack == shown.attack:
		return true
	return (next.attack > shown.attack) == higher


## A guess. Returns true when it was right. The guessed card becomes the face-up card either way.
func guess(higher: bool) -> bool:
	if is_over():
		return false
	var right: bool = would_be_right(higher)
	guesses.append(right)
	position += 1
	if right:
		streak += 1
		best_streak = maxi(best_streak, streak)
	else:
		streak = 0
		misses += 1
	return right


func stars() -> int:
	return CardGamePool.stars_for(is_won(), misses)


## The guess a newcomer makes with nothing but the card in front of them and the range printed on the bench: away from the nearer edge.
func natural_guess(low: int, high: int) -> bool:
	return float(current().attack) <= float(low + high) * 0.5
