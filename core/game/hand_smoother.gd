class_name HandSmoother
extends RefCounted
## Opening-hand selection. Draws `hand_size` cards from a shuffled deck. With the smoother on,
## a second candidate hand is drawn only when the first one's infrastructure count is more than `tolerance`
## away from `infrastructure_ratio * hand_size`; the candidate closer to that target is kept (ties keep the
## first). A tolerance of 0 always compares two hands; the default game setting is deliberately
## gentle so the smoother rescues floods and screws without making every hand ideal.


## Removes `hand_size` cards from `deck` (top = end) and returns them as the hand.
## The deck is left shuffled.
static func draw_opening_hand(
	deck: Array[CardInstance],
	hand_size: int,
	infrastructure_ratio: float,
	smoother: bool,
	rng: RandomNumberGenerator,
	tolerance: float = 0.0,
) -> Array[CardInstance]:
	var count: int = mini(hand_size, deck.size())
	var target: float = infrastructure_ratio * float(count)
	RngUtil.shuffle(deck, rng)
	var hand: Array[CardInstance] = _top(deck, count)
	if smoother and absf(float(count_infrastructure(hand)) - target) > tolerance:
		var first: Array[CardInstance] = hand
		RngUtil.shuffle(deck, rng)
		var second: Array[CardInstance] = _top(deck, count)
		hand = pick_closest(first, second, target)
	for card: CardInstance in hand:
		deck.erase(card)
	RngUtil.shuffle(deck, rng)
	return hand


## Fix pass Nov 7 (D6): the hidden soft mulligan. While `hand` holds fewer than `floor` infrastructure cards and `deck` still has
## one, a random non-infrastructure card in the hand goes back into the deck in exchange for a random infrastructure card from it.
## The deck is reshuffled afterwards when anything was swapped. Returns the number of swaps.
static func ensure_infrastructure(
	hand: Array[CardInstance], deck: Array[CardInstance], floor: int, rng: RandomNumberGenerator
) -> int:
	var swaps: int = 0
	while count_infrastructure(hand) < mini(floor, hand.size()):
		var deck_infra: Array[int] = []
		for i: int in range(deck.size()):
			if deck[i].data != null and deck[i].data.is_infrastructure():
				deck_infra.append(i)
		var hand_other: Array[int] = []
		for i: int in range(hand.size()):
			if hand[i].data == null or not hand[i].data.is_infrastructure():
				hand_other.append(i)
		if deck_infra.is_empty() or hand_other.is_empty():
			break
		var di: int = deck_infra[rng.randi_range(0, deck_infra.size() - 1)]
		var hi: int = hand_other[rng.randi_range(0, hand_other.size() - 1)]
		var incoming: CardInstance = deck[di]
		deck[di] = hand[hi]
		hand[hi] = incoming
		swaps += 1
	if swaps > 0:
		RngUtil.shuffle(deck, rng)
	return swaps


## Returns whichever hand's infrastructure count is closer to `target_infrastructure` (ties -> `first`).
static func pick_closest(
	first: Array[CardInstance],
	second: Array[CardInstance],
	target_infrastructure: float,
) -> Array[CardInstance]:
	var first_gap: float = absf(float(count_infrastructure(first)) - target_infrastructure)
	var second_gap: float = absf(float(count_infrastructure(second)) - target_infrastructure)
	return second if second_gap < first_gap else first


static func count_infrastructure(cards: Array[CardInstance]) -> int:
	var infrastructure: int = 0
	for card: CardInstance in cards:
		if card.data.is_infrastructure():
			infrastructure += 1
	return infrastructure


static func _top(deck: Array[CardInstance], count: int) -> Array[CardInstance]:
	var result: Array[CardInstance] = []
	for i: int in range(deck.size() - count, deck.size()):
		result.append(deck[i])
	return result
