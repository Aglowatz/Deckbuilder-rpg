class_name Alchemy
extends RefCounted
## Brief 9, Part F: the Alchemist's crafting rules. Once the player has at least `MIN_ESSENCE_PER_PATH` essence
## of two different Paths, they may trade that much essence of each of the two Paths plus `GOLD_COST` gold for ONE random
## dual-Path card of those two Paths (the designed card set has 16 per pair). Postgame (Oct 31), the cauldron takes three:
## `MIN_ESSENCE_PER_PATH` of each of three Paths plus `TRI_GOLD_COST` gold for ONE random tri-Path card of exactly those three (8 per trio).
## Fix pass Nov 4 (B), Part 4.2: a brew spends only what it needs (it took ALL the essence: 18 for a 6-essence craft left 0, now 12), the
## gold is 100, and each Path holds at most ESSENCE_CAP_PER_PATH (3 crafts' worth); the odds are the base odds.

const MIN_ESSENCE_PER_PATH: int = 6
const GOLD_COST: int = Economy.ALCHEMY_GOLD  # Fix pass Nov 4 (B): 100 (was 150, Overnight Oct 29)
## The most essence one Path can hold: three crafts' worth (Fix pass Nov 4 (B)); more is lost.
const ESSENCE_CAP_PER_PATH: int = MIN_ESSENCE_PER_PATH * 3
## Odds (weights) for Common, Uncommon, Epic, Legendary at the minimum trade (the dual-Path cards are Uncommon, Epic and Legendary).
const BASE_WEIGHTS: Array[int] = [8, 6, 3, 1]
## Every this-many essence beyond the two minimums shifts one weight point from Common to Epic and
## one from Uncommon to Legendary.
const BONUS_STEP: int = 10
## The postgame tri-Path brew costs twice the dual-Path gold.
const TRI_GOLD_COST: int = GOLD_COST * 2


class Result:
	extends RefCounted
	var ok: bool = false
	var reason: String = ""
	var card: CardData
	var paths: Array[Affinity.Type] = []
	var essence_spent: Dictionary = {}
	var gold_spent: int = 0


## Paths with enough essence to take part in a craft.
static func eligible_paths(profile: PlayerProfile) -> Array[Affinity.Type]:
	var result: Array[Affinity.Type] = []
	for path: Affinity.Type in Affinity.colored_types():
		if profile.essence_of(path) >= MIN_ESSENCE_PER_PATH:
			result.append(path)
	return result


## True when at least two Paths have enough essence (the player can craft at all).
static func can_craft_something(profile: PlayerProfile) -> bool:
	return eligible_paths(profile).size() >= 2


static func can_craft(profile: PlayerProfile, gold: int, first: Affinity.Type, second: Affinity.Type) -> bool:
	return problem(profile, gold, first, second).is_empty()


## Why this trade cannot be made (empty = it can).
static func problem(profile: PlayerProfile, gold: int, first: Affinity.Type, second: Affinity.Type) -> String:
	if first == second or first == Affinity.Type.NEUTRAL or second == Affinity.Type.NEUTRAL:
		return "Pick two different Paths."
	if profile.essence_of(first) < MIN_ESSENCE_PER_PATH:
		return "Not enough %s essence (%d needed)." % [Affinity.display_name(first), MIN_ESSENCE_PER_PATH]
	if profile.essence_of(second) < MIN_ESSENCE_PER_PATH:
		return "Not enough %s essence (%d needed)." % [Affinity.display_name(second), MIN_ESSENCE_PER_PATH]
	if gold < GOLD_COST:
		return "You need %d gold." % GOLD_COST
	return ""


## The cards of exactly this pair of Paths, rarest last (Brief 14: the designed set has 16 per pair).
## Cards Oct 27: `earned` (card id -> true) gates REWARD-LOCKED cards; an ENEMY-ONLY card (Chancellor Clench) is never crafted.
static func possible_cards(content: ContentSet, first: Affinity.Type, second: Affinity.Type, earned: Dictionary = {}) -> Array[CardData]:
	var result: Array[CardData] = []
	for card: Variant in content.multipath_cards.values():
		var data: CardData = card as CardData
		if data.paths().size() == 2 and data.paths().has(first) and data.paths().has(second) and CardAvailability.allowed(data, earned):
			result.append(data)
	result.sort_custom(func(a: CardData, b: CardData) -> bool: return int(a.rarity) < int(b.rarity))
	return result


## Rarity weights (Common..Legendary) for a trade of `essence_total` essence from `path_count` Paths.
static func weights_for(essence_total: int, path_count: int = 2) -> Array[int]:
	var weights: Array[int] = BASE_WEIGHTS.duplicate()
	var bonus: int = maxi(0, (essence_total - path_count * MIN_ESSENCE_PER_PATH) / BONUS_STEP)
	for step: int in range(bonus):
		weights[0] = maxi(1, weights[0] - 1)
		weights[2] += 1
		weights[1] = maxi(1, weights[1] - 1)
		weights[3] += 1
	return weights


## Spends MIN_ESSENCE_PER_PATH essence of `first` and of `second` (the caller pays the gold) and picks the card; the rest stays.
## Nothing is spent unless the craft succeeds.
static func craft(content: ContentSet, profile: PlayerProfile, gold: int, first: Affinity.Type, second: Affinity.Type, rng: RandomNumberGenerator) -> Result:
	var result: Result = Result.new()
	var why_not: String = problem(profile, gold, first, second)
	if not why_not.is_empty():
		result.reason = why_not
		return result
	var earned: Dictionary = {}
	for owned: CardData in profile.owned_cards:
		earned[owned.id] = true
	var pool: Array[CardData] = possible_cards(content, first, second, earned)
	if pool.is_empty():
		result.reason = "These Paths have no dual-Path cards yet."
		return result
	var spent_first: int = MIN_ESSENCE_PER_PATH
	var spent_second: int = MIN_ESSENCE_PER_PATH
	var weights: Array[int] = weights_for(spent_first + spent_second)
	var total: int = 0
	for card: CardData in pool:
		total += weights[int(card.rarity)]
	var roll: int = rng.randi() % maxi(1, total)
	var chosen: CardData = pool[pool.size() - 1]
	for card: CardData in pool:
		roll -= weights[int(card.rarity)]
		if roll < 0:
			chosen = card
			break
	profile.set_essence(first, profile.essence_of(first) - spent_first)
	profile.set_essence(second, profile.essence_of(second) - spent_second)
	result.ok = true
	result.card = chosen
	result.paths = [first, second] as Array[Affinity.Type]
	result.essence_spent = {first: spent_first, second: spent_second}
	result.gold_spent = GOLD_COST
	return result


# ---- Postgame: tri-Path crafting ---------------------------------------------------------------


## Once the main boss is beaten (`PlayerProfile.postgame_unlocked`) the Alchemist's cauldron takes three Paths.
static func tri_path_unlocked(profile: PlayerProfile) -> bool:
	return profile.postgame_unlocked


static func max_craft_paths(profile: PlayerProfile) -> int:
	return 3 if tri_path_unlocked(profile) else 2


## The three-Path (or, with four, the four-Path) cards of exactly these Paths, rarest last.
static func tri_path_cards(content: ContentSet, paths: Array[Affinity.Type]) -> Array[CardData]:
	var result: Array[CardData] = []
	for card: Variant in content.multipath_cards.values():
		var data: CardData = card as CardData
		if data.paths().size() == paths.size() and paths.size() >= 3:
			var fits: bool = true
			for path: Affinity.Type in paths:
				fits = fits and data.paths().has(path)
			if fits:
				result.append(data)
	result.sort_custom(func(a: CardData, b: CardData) -> bool: return int(a.rarity) < int(b.rarity))
	return result


## The tri-Path cards a brew of exactly these three Paths can produce (availability as for dual crafting), rarest last.
static func tri_path_pool(content: ContentSet, paths: Array[Affinity.Type], earned: Dictionary = {}) -> Array[CardData]:
	var result: Array[CardData] = []
	for card: CardData in tri_path_cards(content, paths):
		if CardAvailability.allowed(card, earned):
			result.append(card)
	return result


## Why this three-Path brew cannot be made (empty = it can).
static func tri_problem(profile: PlayerProfile, gold: int, paths: Array[Affinity.Type]) -> String:
	if not tri_path_unlocked(profile):
		return "The cauldron only takes two Paths for now."
	var distinct: Dictionary = {}
	for path: Affinity.Type in paths:
		if path != Affinity.Type.NEUTRAL:
			distinct[path] = true
	if paths.size() != 3 or distinct.size() != 3:
		return "Pick three different Paths."
	for path: Affinity.Type in paths:
		if profile.essence_of(path) < MIN_ESSENCE_PER_PATH:
			return "Not enough %s essence (%d needed)." % [Affinity.display_name(path), MIN_ESSENCE_PER_PATH]
	if gold < TRI_GOLD_COST:
		return "You need %d gold." % TRI_GOLD_COST
	return ""


## Spends MIN_ESSENCE_PER_PATH of each of the three Paths (the caller pays the gold) and picks a tri-Path card, like `craft` does for two.
static func craft_tri(content: ContentSet, profile: PlayerProfile, gold: int, paths: Array[Affinity.Type], rng: RandomNumberGenerator) -> Result:
	var result: Result = Result.new()
	var why_not: String = tri_problem(profile, gold, paths)
	if not why_not.is_empty():
		result.reason = why_not
		return result
	var earned: Dictionary = {}
	for owned: CardData in profile.owned_cards:
		earned[owned.id] = true
	var pool: Array[CardData] = tri_path_pool(content, paths, earned)
	if pool.is_empty():
		result.reason = "These Paths have no tri-Path cards yet."
		return result
	var weights: Array[int] = weights_for(MIN_ESSENCE_PER_PATH * 3, 3)
	var total: int = 0
	for card: CardData in pool:
		total += weights[int(card.rarity)]
	var roll: int = rng.randi() % maxi(1, total)
	var chosen: CardData = pool[pool.size() - 1]
	for card: CardData in pool:
		roll -= weights[int(card.rarity)]
		if roll < 0:
			chosen = card
			break
	for path: Affinity.Type in paths:
		result.essence_spent[path] = MIN_ESSENCE_PER_PATH
		profile.set_essence(path, profile.essence_of(path) - MIN_ESSENCE_PER_PATH)
	result.ok = true
	result.card = chosen
	result.paths = paths.duplicate()
	result.gold_spent = TRI_GOLD_COST
	return result
