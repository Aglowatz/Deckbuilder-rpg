class_name RewardPicks
extends RefCounted
## Overnight Oct 23, Part 4: the "choose 1 card from 3" after an elite or boss win, themed to the fight. Cards of the encounter's Paths
## weigh most (a two-Path foe can offer its two-Path cards: the synergy the player just saw), then the player's own Path, then
## Colorless; rarities follow the player's progress (no Epics before level 8 except from bosses, never a Legendary - those stay the
## bosses' guaranteed prizes); cards the player already owns at their copy cap are left out while there are others to offer (an extra
## copy still converts to essence as usual). A re-fought, already-cleared encounter offers a smaller pick: two cards, mostly Commons.

const COUNT: int = 3
const REPEAT_COUNT: int = 2
## Rarity weights [Common, Uncommon, Epic, Legendary] per kind of win.
const ELITE_WEIGHTS: Array[float] = [5.0, 3.0, 0.6, 0.0]
const BOSS_WEIGHTS: Array[float] = [2.0, 4.0, 2.0, 0.0]
const REPEAT_WEIGHTS: Array[float] = [8.0, 2.0, 0.0, 0.0]
## Levels below which Epics are not offered by elites.
const EPIC_LEVEL: int = 8

const ENCOUNTER_PATH_WEIGHT: float = 3.0
const OWN_PATH_WEIGHT: float = 2.0
const COLORLESS_WEIGHT: float = 1.0
const OTHER_WEIGHT: float = 0.25


## The Paths of an enemy deck: every Path with at least `min_share` of its non-infrastructure cards.
static func deck_paths(deck: Deck, min_share: float = 0.2) -> Array[Affinity.Type]:
	var result: Array[Affinity.Type] = []
	if deck == null:
		return result
	var counts: Dictionary = {}
	var total: int = 0
	for card: CardData in deck.cards:
		if card.is_infrastructure():
			continue
		total += 1
		for path: Affinity.Type in card.paths():
			counts[path] = int(counts.get(path, 0)) + 1
	for path: Variant in counts.keys():
		if total > 0 and float(int(counts[path])) / float(total) >= min_share:
			result.append(path as Affinity.Type)
	result.sort()
	return result


## The offer. `owned` maps card id -> copies owned; `caps` card id -> copy cap (missing = no cap known).
static func choose(
	content: ContentSet, rng: RandomNumberGenerator, encounter_paths: Array[Affinity.Type], own_path: Affinity.Type, level: int,
	boss: bool, repeat: bool, owned: Dictionary = {}, caps: Dictionary = {}, only_path: int = -1,
) -> Array[CardData]:
	var table: Array[float] = REPEAT_WEIGHTS if repeat else (BOSS_WEIGHTS if boss else ELITE_WEIGHTS)
	var pool: Array[CardData] = []
	var weights: Array[float] = []
	var capped: Array[CardData] = []
	var capped_weights: Array[float] = []
	for card: CardData in _candidates(content):
		if only_path >= 0 and not is_pure_path(card, only_path as Affinity.Type):
			continue
		var rarity_weight: float = table[int(card.rarity)]
		if card.rarity == CardEnums.Rarity.EPIC and not boss and level < EPIC_LEVEL:
			rarity_weight = 0.0
		if rarity_weight <= 0.0:
			continue
		var weight: float = rarity_weight * path_weight(card, encounter_paths, own_path)
		if weight <= 0.0:
			continue
		if caps.has(card.id) and int(owned.get(card.id, 0)) >= int(caps[card.id]):
			capped.append(card)
			capped_weights.append(weight)
			continue
		pool.append(card)
		weights.append(weight)
	var count: int = REPEAT_COUNT if repeat else COUNT
	var chosen: Array[CardData] = _weighted_pick(pool, weights, rng, count)
	if chosen.size() < count:
		chosen.append_array(_weighted_pick(capped, capped_weights, rng, count - chosen.size()))
	if chosen.size() < count:
		chosen.append_array(_fallback(content, rng, count - chosen.size(), chosen, only_path, owned, caps))
	return chosen


## Fixes Oct 27, Part 1: a short pool never makes a short (or empty) pick. Fills up from that Path's other rarities (a gatekeeper's Path,
## else any card the table left out), then Colorless; cards below their copy cap first. Never a Legendary.
static func _fallback(
	content: ContentSet, rng: RandomNumberGenerator, count: int, taken: Array[CardData], only_path: int, owned: Dictionary, caps: Dictionary,
) -> Array[CardData]:
	var result: Array[CardData] = []
	for stage: int in range(2):
		var open: Array[CardData] = []
		var full: Array[CardData] = []
		for card: CardData in _candidates(content):
			if taken.has(card) or result.has(card):
				continue
			var fits: bool = card.paths().is_empty() if stage == 1 else (only_path < 0 or is_pure_path(card, only_path as Affinity.Type))
			if not fits:
				continue
			if caps.has(card.id) and int(owned.get(card.id, 0)) >= int(caps[card.id]):
				full.append(card)
			else:
				open.append(card)
		for pool: Array[CardData] in [open, full]:
			var weights: Array[float] = []
			for card: CardData in pool:
				weights.append(1.0)
			result.append_array(_weighted_pick(pool, weights, rng, count - result.size()))
			if result.size() >= count:
				return result
	return result


## How much a card fits this fight: on the encounter's Paths most (a two-Path card needs all its Paths among the encounter's and the
## player's), then the player's own Path, then Colorless, then anything else a little.
static func path_weight(card: CardData, encounter_paths: Array[Affinity.Type], own_path: Affinity.Type) -> float:
	var paths: Array[Affinity.Type] = card.paths()
	if paths.is_empty():
		return COLORLESS_WEIGHT
	if paths.size() > 1:
		for path: Affinity.Type in paths:
			if not encounter_paths.has(path) and path != own_path:
				return 0.0
		return ENCOUNTER_PATH_WEIGHT * (1.5 if encounter_paths.size() > 1 else 1.0)
	var weight: float = 0.0
	if encounter_paths.has(paths[0]):
		weight += ENCOUNTER_PATH_WEIGHT
	if paths[0] == own_path:
		weight += OWN_PATH_WEIGHT
	return weight if weight > 0.0 else OTHER_WEIGHT


## Fixes Oct 25, Part 1: a card of exactly this one Path (no Colorless, no two-Path cards) - what a zone gatekeeper's pick offers.
static func is_pure_path(card: CardData, path: Affinity.Type) -> bool:
	var paths: Array[Affinity.Type] = card.paths()
	return paths.size() == 1 and paths[0] == path


static func _candidates(content: ContentSet) -> Array[CardData]:
	var result: Array[CardData] = []
	for source: Dictionary in [content.cards, content.multipath_cards]:
		var ids: Array = source.keys()
		ids.sort()
		for id: Variant in ids:
			var card: CardData = source[id] as CardData
			if card.is_infrastructure() or card.is_token or card.rarity == CardEnums.Rarity.LEGENDARY:
				continue
			result.append(card)
	return result


static func _weighted_pick(pool: Array[CardData], weights: Array[float], rng: RandomNumberGenerator, count: int) -> Array[CardData]:
	var chosen: Array[CardData] = []
	var left: Array[CardData] = pool.duplicate()
	var left_weights: Array[float] = weights.duplicate()
	while chosen.size() < count and not left.is_empty():
		var total: float = 0.0
		for weight: float in left_weights:
			total += weight
		var roll: float = rng.randf() * total
		var pick: int = left.size() - 1
		for index: int in range(left.size()):
			roll -= left_weights[index]
			if roll <= 0.0:
				pick = index
				break
		chosen.append(left[pick])
		left.remove_at(pick)
		left_weights.remove_at(pick)
	return chosen
