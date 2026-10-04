class_name Alchemy
extends RefCounted
## Brief 9, Part F: the Alchemist's crafting rules. Once the player has at least `MIN_ESSENCE_PER_PATH` essence
## of two different Paths, they may trade ALL of their essence of those two Paths plus `GOLD_COST` gold for ONE random
## dual-Path card of those two Paths (there are 4 per pair, `MultipathContent`). The more essence traded
## beyond the minimum, the better the odds of the rarer cards. Tri-Path crafting is a postgame hook only
## (`tri_path_unlocked`, no tri-Path cards exist yet).

const MIN_ESSENCE_PER_PATH: int = 10
const GOLD_COST: int = 100
## Odds (weights) for Common, Uncommon, Epic, Legendary at the minimum trade.
const BASE_WEIGHTS: Array[int] = [8, 6, 3, 1]
## Every this-many essence beyond the two minimums shifts one weight point from Common to Epic and
## one from Uncommon to Legendary.
const BONUS_STEP: int = 10


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


## The four cards a pair of Paths can produce, rarest last.
static func possible_cards(content: ContentSet, first: Affinity.Type, second: Affinity.Type) -> Array[CardData]:
	var result: Array[CardData] = []
	for card_id: String in MultipathContent.ids_for(first, second, content.multipath_cards):
		result.append(content.multipath_cards[card_id] as CardData)
	result.sort_custom(func(a: CardData, b: CardData) -> bool: return int(a.rarity) < int(b.rarity))
	return result


## Rarity weights (Common..Legendary) for a trade of `essence_total` essence.
static func weights_for(essence_total: int) -> Array[int]:
	var weights: Array[int] = BASE_WEIGHTS.duplicate()
	var bonus: int = maxi(0, (essence_total - 2 * MIN_ESSENCE_PER_PATH) / BONUS_STEP)
	for step: int in range(bonus):
		weights[0] = maxi(1, weights[0] - 1)
		weights[2] += 1
		weights[1] = maxi(1, weights[1] - 1)
		weights[3] += 1
	return weights


## Spends ALL the essence of `first` and `second` (the caller pays the gold) and picks the card. The profile's
## essence is zeroed for those two Paths only when the craft succeeds.
static func craft(content: ContentSet, profile: PlayerProfile, gold: int, first: Affinity.Type, second: Affinity.Type, rng: RandomNumberGenerator) -> Result:
	var result: Result = Result.new()
	var why_not: String = problem(profile, gold, first, second)
	if not why_not.is_empty():
		result.reason = why_not
		return result
	var pool: Array[CardData] = possible_cards(content, first, second)
	if pool.is_empty():
		result.reason = "These Paths have no dual-Path cards yet."
		return result
	var spent_first: int = profile.essence_of(first)
	var spent_second: int = profile.essence_of(second)
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
	profile.set_essence(first, 0)
	profile.set_essence(second, 0)
	result.ok = true
	result.card = chosen
	result.paths = [first, second] as Array[Affinity.Type]
	result.essence_spent = {first: spent_first, second: spent_second}
	result.gold_spent = GOLD_COST
	return result


# ---- Postgame hook: tri-Path crafting ----------------------------------------------------------


## Once the main boss is beaten (`PlayerProfile.postgame_unlocked`) the Alchemist may offer tri-Path crafting.
## There are no tri-Path (or quad-Path) cards yet, so this only exposes the flag.
static func tri_path_unlocked(profile: PlayerProfile) -> bool:
	return profile.postgame_unlocked


static func max_craft_paths(profile: PlayerProfile) -> int:
	return 3 if tri_path_unlocked(profile) else 2


## Tri-Path recipes: none exist yet.
static func tri_path_cards(_content: ContentSet, _paths: Array[Affinity.Type]) -> Array[CardData]:
	return []
