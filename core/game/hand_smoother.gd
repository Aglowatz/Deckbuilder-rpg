class_name HandSmoother
extends RefCounted
## Opening-hand selection. Draws `hand_size` cards from a shuffled library; with the smoother
## on, two candidate hands are generated and the one whose land count is closest to
## `land_ratio * hand_size` is kept (ties keep the first candidate).


## Removes `hand_size` cards from `library` (top = end) and returns them as the hand.
## The library is left shuffled.
static func draw_opening_hand(
	library: Array[CardInstance],
	hand_size: int,
	land_ratio: float,
	smoother: bool,
	rng: RandomNumberGenerator,
) -> Array[CardInstance]:
	var count: int = mini(hand_size, library.size())
	RngUtil.shuffle(library, rng)
	var hand: Array[CardInstance] = _top(library, count)
	if smoother:
		var first: Array[CardInstance] = hand
		RngUtil.shuffle(library, rng)
		var second: Array[CardInstance] = _top(library, count)
		hand = pick_closest(first, second, land_ratio * float(count))
	for card: CardInstance in hand:
		library.erase(card)
	RngUtil.shuffle(library, rng)
	return hand


## Returns whichever hand's land count is closer to `target_lands` (ties -> `first`).
static func pick_closest(
	first: Array[CardInstance],
	second: Array[CardInstance],
	target_lands: float,
) -> Array[CardInstance]:
	var first_gap: float = absf(float(count_lands(first)) - target_lands)
	var second_gap: float = absf(float(count_lands(second)) - target_lands)
	return second if second_gap < first_gap else first


static func count_lands(cards: Array[CardInstance]) -> int:
	var lands: int = 0
	for card: CardInstance in cards:
		if card.data.is_land():
			lands += 1
	return lands


static func _top(library: Array[CardInstance], count: int) -> Array[CardInstance]:
	var result: Array[CardInstance] = []
	for i: int in range(library.size() - count, library.size()):
		result.append(library[i])
	return result
