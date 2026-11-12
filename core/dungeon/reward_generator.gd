class_name RewardGenerator
extends RefCounted
## Builds the card choices offered after a victory: a weighted random pick that favours the
## player's chosen color and neutral cards, prefers commons, and never repeats a card.

const RARITY_WEIGHTS: Array[float] = [6.0, 3.0, 1.0, 0.25]
const BOSS_RARITY_WEIGHTS: Array[float] = [2.0, 4.0, 3.0, 0.5]


## Cards Oct 27: `earned` (card id -> true) gates REWARD-LOCKED cards; ENEMY-ONLY cards are never offered (`CardAvailability`).
static func card_choices(
	content: ContentSet,
	profile: PlayerProfile,
	rng: RandomNumberGenerator,
	count: int = 3,
	boss: bool = false,
	earned: Dictionary = {},
) -> Array[CardData]:
	var pool: Array[CardData] = []
	var weights: Array[float] = []
	var table: Array[float] = BOSS_RARITY_WEIGHTS if boss else RARITY_WEIGHTS
	var ids: Array = content.cards.keys()
	ids.sort()
	for id: Variant in ids:
		var card: CardData = content.cards[id] as CardData
		if card.is_infrastructure() or not CardAvailability.allowed(card, earned):
			continue
		var weight: float = table[int(card.rarity)]
		if card.is_on_path(profile.primary_affinity):
			weight *= 3.0
		elif card.paths().is_empty():
			weight *= 2.0
		pool.append(card)
		weights.append(weight)
	return _weighted_pick(pool, weights, rng, count)


## Fable Nov 12c (A10b, inbox "Fable Nov 12" item 11): a pick with a rarity floor. When none of `cards` is `floor` or better (and not a
## Legendary-only miracle is asked for), the LAST card is replaced by one drawn from the cards of that rarity or better - the same pool,
## weights and Path leaning as `card_choices`, never a card already in the pick. Returns the same array (changed in place).
static func with_rarity_floor(
	cards: Array[CardData],
	content: ContentSet,
	profile: PlayerProfile,
	rng: RandomNumberGenerator,
	floor: CardEnums.Rarity = CardEnums.Rarity.UNCOMMON,
	boss: bool = false,
	earned: Dictionary = {},
) -> Array[CardData]:
	if cards.is_empty() or has_rarity(cards, floor):
		return cards
	var pool: Array[CardData] = []
	var weights: Array[float] = []
	var table: Array[float] = BOSS_RARITY_WEIGHTS if boss else RARITY_WEIGHTS
	var ids: Array = content.cards.keys()
	ids.sort()
	for id: Variant in ids:
		var card: CardData = content.cards[id] as CardData
		if card.is_infrastructure() or int(card.rarity) < int(floor) or cards.has(card) or not CardAvailability.allowed(card, earned):
			continue
		var weight: float = table[int(card.rarity)]
		if card.is_on_path(profile.primary_affinity):
			weight *= 3.0
		elif card.paths().is_empty():
			weight *= 2.0
		pool.append(card)
		weights.append(weight)
	var better: Array[CardData] = _weighted_pick(pool, weights, rng, 1)
	if not better.is_empty():
		cards[cards.size() - 1] = better[0]
	return cards


static func has_rarity(cards: Array[CardData], floor: CardEnums.Rarity) -> bool:
	for card: CardData in cards:
		if card != null and int(card.rarity) >= int(floor):
			return true
	return false


## The tutorial dungeon's reward pick (Part C): strictly `color`'s own cards, never neutral or
## another color, so the only on-element cards the player ends the trial with are the ones picked
## here. Still rarity-weighted the same way as `card_choices`.
static func card_choices_for_color(
	content: ContentSet,
	color: Affinity.Type,
	rng: RandomNumberGenerator,
	count: int = 3,
	boss: bool = false,
	earned: Dictionary = {},
) -> Array[CardData]:
	var pool: Array[CardData] = []
	var weights: Array[float] = []
	var table: Array[float] = BOSS_RARITY_WEIGHTS if boss else RARITY_WEIGHTS
	var ids: Array = content.cards.keys()
	ids.sort()
	for id: Variant in ids:
		var card: CardData = content.cards[id] as CardData
		if not card.is_on_path(color) or card.is_infrastructure() or not CardAvailability.allowed(card, earned):
			continue
		pool.append(card)
		weights.append(table[int(card.rarity)])
	return _weighted_pick(pool, weights, rng, count)


static func _weighted_pick(pool: Array[CardData], weights: Array[float], rng: RandomNumberGenerator, count: int) -> Array[CardData]:
	var chosen: Array[CardData] = []
	while chosen.size() < count and not pool.is_empty():
		var total: float = 0.0
		for weight: float in weights:
			total += weight
		var roll: float = rng.randf() * total
		var pick: int = 0
		for index: int in range(pool.size()):
			roll -= weights[index]
			if roll <= 0.0:
				pick = index
				break
		chosen.append(pool[pick])
		pool.remove_at(pick)
		weights.remove_at(pick)
	return chosen
