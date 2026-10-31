class_name DeckInsights
extends RefCounted
## Overnight Oct 30-31, Part 7 (a smarter Deck Station): pure reads of a deck and a collection - the cost curve, the Path mix, the card-type
## counts, "works well with" hints read from the cards' rules (the Resource a card makes and the one another spends, the Refuse Pile, tokens,
## shared keywords) and a suggested deck for one or two Paths built from what the player owns, within the copy caps. No scene, no UI.

## The curve's buckets: cost 0, 1, ... 6 and "7+" (Infrastructure is not on the curve).
const CURVE_BUCKETS: int = 8
## The suggested deck's spells by cost (0-1, 2, 3, 4, 5+), for its non-Infrastructure part of 26 (a 45-card deck with 19 Infrastructure,
## as the starters); scaled when the deck is bigger.
const CURVE_TARGET: Array[int] = [4, 7, 6, 5, 4]
const INFRA_SHARE: float = 19.0 / 45.0
## Rarity weight when two cards compete for a slot.
const RARITY_SCORE: Array[float] = [1.0, 2.0, 3.2, 4.5]
## The Resource words a card's rules can name (ResourceKind.Kind order).
const RESOURCE_WORDS: Array[String] = ["iron", "red tape", "contract", "ingredient", "garbage"]
const MAKE_WORDS: Array[String] = ["create", "gain", "make", "add "]
const USE_WORDS: Array[String] = ["spend", "remove", "pay", "for each", "sacrifice", "discard", "use "]


## Cards per cost bucket (0..6, 7+), Infrastructure left out.
static func cost_curve(cards: Array[CardData]) -> Array[int]:
	var curve: Array[int] = []
	curve.resize(CURVE_BUCKETS)
	curve.fill(0)
	for card: CardData in cards:
		if card == null or card.is_infrastructure():
			continue
		curve[mini(card.energy_value(), CURVE_BUCKETS - 1)] += 1
	return curve


## Path -> number of cards on it (a dual card counts for both; Infrastructure counts for its own Path; Colorless is NEUTRAL).
static func path_mix(cards: Array[CardData]) -> Dictionary:
	var mix: Dictionary = {}
	for card: CardData in cards:
		if card == null:
			continue
		var paths: Array[Affinity.Type] = card.paths()
		if paths.is_empty():
			paths = [card.color] as Array[Affinity.Type]
		for path: Affinity.Type in paths:
			mix[int(path)] = int(mix.get(int(path), 0)) + 1
	return mix


## Card type -> count, plus "infrastructure" for the basics (CardEnums.CardType values as keys).
static func type_counts(cards: Array[CardData]) -> Dictionary:
	var counts: Dictionary = {}
	for card: CardData in cards:
		if card == null:
			continue
		var key: Variant = "infrastructure" if card.is_infrastructure() else int(card.type)
		counts[key] = int(counts.get(key, 0)) + 1
	return counts


## The themes a card's rules touch: "make:<resource>", "use:<resource>", "refuse", "token", "kw:<keyword>", "tool", "unit".
static func themes(card: CardData) -> Array[String]:
	var result: Array[String] = []
	if card == null or card.is_infrastructure():
		return result
	var text: String = card.rules_text.to_lower()
	for index: int in range(RESOURCE_WORDS.size()):
		var word: String = RESOURCE_WORDS[index]
		var at: int = text.find(word)
		if at < 0:
			continue
		var before: String = text.substr(maxi(0, at - 28), mini(at, 28))
		var made: bool = card.resource_kind == index
		var used: bool = false
		for verb: String in MAKE_WORDS:
			made = made or before.contains(verb)
		for verb: String in USE_WORDS:
			used = used or before.contains(verb)
		if not made and not used:
			used = true  # "costs 2 Iron", "if you have Garbage": it wants the Resource
		if made:
			result.append("make:%s" % word)
		if used:
			result.append("use:%s" % word)
	if text.contains("refuse pile"):
		result.append("refuse")
	if text.contains("token"):
		result.append("token")
	for keyword: CardEnums.Keyword in card.keywords:
		result.append("kw:%d" % int(keyword))
	result.append("tool" if card.is_tool() else ("unit" if card.is_unit() else "spell"))
	return result


## How well `other` goes with `card`, and why ("" when it does not): {"score": float, "why": String}.
static func pair(card: CardData, other: CardData) -> Dictionary:
	if card == null or other == null or card.id == other.id or other.is_infrastructure() or card.is_infrastructure():
		return {"score": 0.0, "why": ""}
	var mine: Array[String] = themes(card)
	var theirs: Array[String] = themes(other)
	var score: float = 0.0
	var why: String = ""
	for index: int in range(RESOURCE_WORDS.size()):
		var word: String = RESOURCE_WORDS[index]
		if mine.has("make:%s" % word) and theirs.has("use:%s" % word):
			score += 3.0
			why = "uses the %s this makes" % word.capitalize()
		elif mine.has("use:%s" % word) and theirs.has("make:%s" % word):
			score += 3.0
			why = "makes the %s this needs" % word.capitalize()
	if mine.has("refuse") and theirs.has("refuse"):
		score += 1.5
		if why == "":
			why = "also works the Refuse Pile"
	if mine.has("token") and theirs.has("token"):
		score += 1.0
		if why == "":
			why = "also plays with tokens"
	if (mine.has("tool") and theirs.has("unit")) or (mine.has("unit") and theirs.has("tool")):
		score += 0.5
		if why == "":
			why = "a Tool for your units" if theirs.has("tool") else "a unit to carry this Tool"
	for theme: String in mine:
		if theme.begins_with("kw:") and theirs.has(theme):
			score += 0.5
			if why == "":
				why = "shares a keyword"
	# Same Path (or Colorless) only: a partner the deck can actually run.
	if not _shares_path(card, other):
		score *= 0.4
	return {"score": score, "why": why}


static func _shares_path(a: CardData, b: CardData) -> bool:
	if a.color == Affinity.Type.NEUTRAL or b.color == Affinity.Type.NEUTRAL:
		return true
	for path: Affinity.Type in a.paths():
		if b.is_on_path(path):
			return true
	return a.color == b.color


## Up to `limit` cards of `pool` that go well with `card`, best first: [{"card": CardData, "why": String}]. Only real reasons (score 1+).
static func works_well_with(card: CardData, pool: Array[CardData], limit: int = 3) -> Array[Dictionary]:
	var scored: Array[Dictionary] = []
	var seen: Dictionary = {}
	for other: CardData in pool:
		if other == null or seen.has(other.id):
			continue
		seen[other.id] = true
		var fit: Dictionary = pair(card, other)
		if float(fit["score"]) >= 1.0:
			scored.append({"card": other, "why": str(fit["why"]), "score": float(fit["score"])})
	scored.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if float(a["score"]) != float(b["score"]):
			return float(a["score"]) > float(b["score"])
		return (a["card"] as CardData).display_name < (b["card"] as CardData).display_name)
	return scored.slice(0, limit)


## A sensible deck for `paths` (1 or 2) from `owned` (every copy the player owns, duplicates included), at `level`'s copy caps and at least
## `min_size` cards: the best spells by rarity and fit filling a cost curve (CURVE_TARGET), units first, then Infrastructure split by the
## spells' Paths up to the size. `infrastructure` holds one basic per colored Path (Affinity.colored_types order or keyed by Path).
static func suggest(owned: Array[CardData], paths: Array[Affinity.Type], level: int, infrastructure: Array[CardData], min_size: int) -> Deck:
	var deck: Deck = Deck.new()
	deck.deck_name = "Suggested"
	var size: int = maxi(min_size, 1)
	var infra_count: int = int(round(float(size) * INFRA_SHARE))
	var spell_slots: int = size - infra_count
	# Copies available per card: owned, within the cap, on the chosen Paths (or Colorless).
	var available: Dictionary = {}
	var by_id: Dictionary = {}
	for card: CardData in owned:
		if card == null or card.is_infrastructure() or card.is_token or card.is_basic:
			continue
		if not _fits_paths(card, paths):
			continue
		by_id[card.id] = card
		available[card.id] = mini(int(available.get(card.id, 0)) + 1, CopyCaps.for_card(card, level))
	var pool: Array[CardData] = []
	for id: Variant in by_id.keys():
		pool.append(by_id[id] as CardData)
	pool.sort_custom(func(a: CardData, b: CardData) -> bool:
		var sa: float = _score(a, paths)
		var sb: float = _score(b, paths)
		if sa != sb:
			return sa > sb
		return a.id < b.id)
	var targets: Array[int] = []
	var total_target: int = 0
	for want: int in CURVE_TARGET:
		total_target += want
	for want: int in CURVE_TARGET:
		targets.append(int(round(float(want) * float(spell_slots) / float(total_target))))
	var taken: Dictionary = {}
	var picked: Array[CardData] = []
	# Pass 1: the curve, best first in each bucket.
	for card: CardData in pool:
		var bucket: int = _bucket(card)
		while int(taken.get(card.id, 0)) < int(available[card.id]) and targets[bucket] > 0 and picked.size() < spell_slots:
			picked.append(card)
			taken[card.id] = int(taken.get(card.id, 0)) + 1
			targets[bucket] -= 1
	# Pass 2: whatever is left, best first, until the spell slots are full.
	for card: CardData in pool:
		while int(taken.get(card.id, 0)) < int(available[card.id]) and picked.size() < spell_slots:
			picked.append(card)
			taken[card.id] = int(taken.get(card.id, 0)) + 1
	deck.cards.append_array(picked)
	# Infrastructure: split by the spells' Path pips (at least a few of each chosen colored Path).
	var weights: Dictionary = {}
	for path: Affinity.Type in paths:
		if path != Affinity.Type.NEUTRAL:
			weights[int(path)] = 1.0
	for card: CardData in picked:
		for pip: Affinity.Type in card.colored_pips:
			if weights.has(int(pip)):
				weights[int(pip)] = float(weights[int(pip)]) + 1.0
	var weight_total: float = 0.0
	for key: Variant in weights.keys():
		weight_total += float(weights[key])
	var infra_left: int = size - deck.cards.size()
	var keys: Array = weights.keys()
	keys.sort()
	for index: int in range(keys.size()):
		var basic: CardData = _basic_for(infrastructure, int(keys[index]) as Affinity.Type)
		if basic == null:
			continue
		var share: int = infra_left if index == keys.size() - 1 else int(round(float(infra_left) * float(weights[keys[index]]) / maxf(weight_total, 1.0)))
		if index == keys.size() - 1:
			share = size - deck.cards.size()
		for _copy: int in range(maxi(0, share)):
			deck.cards.append(basic)
	return deck


static func _fits_paths(card: CardData, paths: Array[Affinity.Type]) -> bool:
	if card.color == Affinity.Type.NEUTRAL and card.paths().size() <= 1:
		return true
	for path: Affinity.Type in card.paths():
		if not paths.has(path) and path != Affinity.Type.NEUTRAL:
			return false
	return paths.has(card.color) or card.is_multipath()


static func _bucket(card: CardData) -> int:
	return clampi(card.energy_value() - 1, 0, CURVE_TARGET.size() - 1)


static func _score(card: CardData, paths: Array[Affinity.Type]) -> float:
	var score: float = RARITY_SCORE[clampi(int(card.rarity), 0, RARITY_SCORE.size() - 1)]
	if card.is_unit():
		score += 0.8  # a deck needs bodies on the board
	if card.color != Affinity.Type.NEUTRAL and paths.has(card.color):
		score += 0.5  # the Path's own cards before Colorless filler
	return score


static func _basic_for(infrastructure: Array[CardData], path: Affinity.Type) -> CardData:
	for basic: CardData in infrastructure:
		if basic != null and basic.color == path:
			return basic
	return null
