class_name PackRoller
extends RefCounted
## Rolls the cards of a pack. Pure `core/` logic: give it a seeded `RandomNumberGenerator` and the result is deterministic.
##
## Per slot: pick a rarity by the pack's weights (only rarities that actually have cards in the pool compete), then a random
## card of that rarity, avoiding a repeat inside the same pack while the pool allows it. Guarantees run afterwards and
## re-roll a slot when the pack does not yet satisfy them. `not_in_packs` cards are never in a pool.


## Every card a pack can contain, sorted by id (stable for seeded rolls).
static func pool(pack: PackData, content: ContentSet) -> Array[CardData]:
	var result: Array[CardData] = []
	for card: Variant in content.cards.values():
		if _fits(pack, card as CardData):
			result.append(card as CardData)
	if pack.include_multipath:
		for card: Variant in content.multipath_cards.values():
			if _fits(pack, card as CardData):
				result.append(card as CardData)
	result.sort_custom(func(a: CardData, b: CardData) -> bool: return a.id < b.id)
	return result


static func _fits(pack: PackData, card: CardData) -> bool:
	if card == null or card.not_in_packs or card.is_token or card.is_basic:
		return false
	if int(card.rarity) < int(pack.min_rarity) or int(card.rarity) > int(pack.max_rarity):
		return false
	if card.is_multipath():
		return pack.include_multipath
	if card.paths().is_empty():
		return pack.include_neutral
	return pack.pool_paths.is_empty() or pack.pool_paths.has(card.paths()[0])


## The cards of one opening. Empty if the pool is empty.
static func roll(pack: PackData, content: ContentSet, rng: RandomNumberGenerator) -> Array[CardData]:
	var cards: Array[CardData] = pool(pack, content)
	var picks: Array[CardData] = []
	if cards.is_empty():
		return picks
	for i: int in range(pack.card_count):
		picks.append(_pick(pack, cards, rng, picks))
	var multipath_pool: Array[CardData] = cards.filter(func(c: CardData) -> bool: return c.is_multipath())
	if pack.guarantee_multipath and not multipath_pool.is_empty() and not _any(picks, _is_multipath):
		var candidates: Array[CardData] = multipath_pool
		# With both guarantees and a single slot, the one card has to satisfy both.
		if pack.guarantee_epic_or_legendary and picks.size() < 2 and not _any(picks, _is_epic_plus):
			var strong: Array[CardData] = multipath_pool.filter(_is_epic_plus)
			if not strong.is_empty():
				candidates = strong
		var slot: int = _free_slot(picks, rng, pack.guarantee_epic_or_legendary)
		picks[slot] = _pick(pack, candidates, rng, picks)
	if pack.guarantee_epic_or_legendary and not _any(picks, _is_epic_plus):
		var strong_cards: Array[CardData] = cards.filter(_is_epic_plus)
		if not strong_cards.is_empty():
			var target: int = _slot_not_the_only_multipath(picks, rng, pack.guarantee_multipath)
			if pack.guarantee_multipath and _is_multipath(picks[target]) and not multipath_pool.is_empty():
				# A single card must be both: take a strong multi-Path card.
				var strong_multipath: Array[CardData] = multipath_pool.filter(_is_epic_plus)
				if not strong_multipath.is_empty():
					strong_cards = strong_multipath
			picks[target] = _pick(pack, strong_cards, rng, picks)
	return picks


## A random slot to re-roll for the multi-Path guarantee (preferring one that is not already the pack's Epic/Legendary).
static func _free_slot(picks: Array[CardData], rng: RandomNumberGenerator, keep_epic: bool) -> int:
	var slots: Array[int] = []
	for index: int in range(picks.size()):
		if not keep_epic or not _is_epic_plus(picks[index]):
			slots.append(index)
	if slots.is_empty():
		return rng.randi_range(0, picks.size() - 1)
	return slots[rng.randi_range(0, slots.size() - 1)]


## A random slot to re-roll for the Epic guarantee that does not destroy the pack's only multi-Path card (unless it is the only slot).
static func _slot_not_the_only_multipath(picks: Array[CardData], rng: RandomNumberGenerator, keep_multipath: bool) -> int:
	var multipath_count: int = picks.filter(_is_multipath).size()
	var slots: Array[int] = []
	for index: int in range(picks.size()):
		if not (keep_multipath and multipath_count == 1 and _is_multipath(picks[index])):
			slots.append(index)
	if slots.is_empty():
		return 0
	return slots[rng.randi_range(0, slots.size() - 1)]


static func _is_multipath(card: CardData) -> bool:
	return card.is_multipath()


static func _is_epic_plus(card: CardData) -> bool:
	return card.rarity == CardEnums.Rarity.EPIC or card.rarity == CardEnums.Rarity.LEGENDARY


static func _any(cards: Array[CardData], test: Callable) -> bool:
	for card: CardData in cards:
		if test.call(card):
			return true
	return false


## One card out of `candidates`: rarity by weight (among rarities present), then uniformly within the rarity.
static func _pick(pack: PackData, candidates: Array[CardData], rng: RandomNumberGenerator, already: Array[CardData]) -> CardData:
	var fresh: Array[CardData] = candidates.filter(func(c: CardData) -> bool: return not already.has(c))
	var source: Array[CardData] = fresh if not fresh.is_empty() else candidates
	var by_rarity: Dictionary = {}
	for card: CardData in source:
		if not by_rarity.has(int(card.rarity)):
			by_rarity[int(card.rarity)] = [] as Array[CardData]
		(by_rarity[int(card.rarity)] as Array[CardData]).append(card)
	var rarities: Array = by_rarity.keys()
	rarities.sort()
	var total: int = 0
	for rarity: Variant in rarities:
		total += pack.rarity_weight(int(rarity) as CardEnums.Rarity)
	var chosen: int = int(rarities[0])
	if total <= 0:
		chosen = int(rarities[rng.randi_range(0, rarities.size() - 1)])
	else:
		var roll_value: int = rng.randi_range(1, total)
		for rarity: Variant in rarities:
			roll_value -= pack.rarity_weight(int(rarity) as CardEnums.Rarity)
			if roll_value <= 0:
				chosen = int(rarity)
				break
	var group: Array = by_rarity[chosen] as Array
	return group[rng.randi_range(0, group.size() - 1)] as CardData
