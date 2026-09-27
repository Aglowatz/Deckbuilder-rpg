class_name RewardGenerator
extends RefCounted
## Builds the card choices offered after a victory: a weighted random pick that favours the
## player's chosen color and neutral cards, prefers commons, and never repeats a card.

const RARITY_WEIGHTS: Array[float] = [6.0, 3.0, 1.0, 0.25]
const BOSS_RARITY_WEIGHTS: Array[float] = [2.0, 4.0, 3.0, 0.5]


static func card_choices(
	content: ContentSet,
	profile: PlayerProfile,
	rng: RandomNumberGenerator,
	count: int = 3,
	boss: bool = false,
) -> Array[CardData]:
	var pool: Array[CardData] = []
	var weights: Array[float] = []
	var table: Array[float] = BOSS_RARITY_WEIGHTS if boss else RARITY_WEIGHTS
	var ids: Array = content.cards.keys()
	ids.sort()
	for id: Variant in ids:
		var card: CardData = content.cards[id] as CardData
		var weight: float = table[int(card.rarity)]
		if card.color == profile.primary_affinity:
			weight *= 3.0
		elif card.color == Affinity.Type.NEUTRAL:
			weight *= 2.0
		pool.append(card)
		weights.append(weight)
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
