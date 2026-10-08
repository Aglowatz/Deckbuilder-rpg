class_name CampaignStart
extends RefCounted
## The start of a new campaign (Part C): the player picks their element BEFORE the tutorial
## dungeon, in the starting area (`ElementChoiceScreen`). `new_profile`/`starter_deck` then build
## the 42-card starter - 23 colorless spells + 19 basic infrastructure of the chosen element - the player
## carries into the Forgotten Cave. It is short of the normal 45-card minimum on purpose
## (`TrialOfTheHollow.deck_size_waiver()`); the 3 tutorial reward picks (one on-element card per
## battle) bring it up to a real, legal 45-card deck by the time the player reaches town.
## See docs/design/starting_deck_and_affinity.md for the story framing.

const STARTER_DECK_NAME: String = "Wanderer's Pack"

## Story v2 (Part C): the colorless template has 23 spells; 8 of them (card id -> copies cut) make room for the chosen Path's own 8-card package, so the
## 42-card starter now leans on that Path's Resource (cards that create it and cards that spend it). Only existing designed cards, every one a
## Common and at most 3 copies of a card, so the deck stays legal. The final lists are recorded in docs/design/starting_deck_and_affinity.md.
const NEUTRAL_CUTS: Dictionary = {"C-01": 2, "C-04": 1, "C-05": 1, "C-10": 1, "C-12": 1, "C-16": 1, "C-19": 1}
const PATH_PACKAGES: Dictionary = {
	Affinity.Type.BEEFCAKE: {"B-05": 2, "B-01": 2, "B-09": 1, "B-04": 1, "B-03": 1, "B-14": 1},
	Affinity.Type.GOURMAND: {"G-01": 2, "G-02": 2, "G-15": 1, "G-09": 1, "G-12": 1, "G-10": 1},
	Affinity.Type.REFUSEMANCER: {"R-06": 2, "R-08": 2, "R-02": 1, "R-10": 1, "R-05": 1, "R-19": 1},
	Affinity.Type.NECROCRAT: {"N-01": 2, "N-02": 2, "N-04": 1, "N-09": 1, "N-05": 1, "N-15": 1},
}


static func is_valid_choice(color: Affinity.Type) -> bool:
	return color != Affinity.Type.NEUTRAL


## The starter spells: the colorless template minus `NEUTRAL_CUTS`, plus the chosen Path's package (`PATH_PACKAGES`); infrastructure are not part of the collection.
static func starter_spells(content: ContentSet, primary: Affinity.Type = Affinity.Type.NEUTRAL) -> Array[CardData]:
	var spells: Array[CardData] = []
	var template: Deck = content.deck(STARTER_DECK_NAME)
	if template == null:
		return spells
	var cuts: Dictionary = NEUTRAL_CUTS.duplicate()
	if not PATH_PACKAGES.has(primary):
		cuts = {}
	for card: CardData in template.cards:
		if card.is_infrastructure():
			continue
		if int(cuts.get(card.id, 0)) > 0:
			cuts[card.id] = int(cuts[card.id]) - 1
			continue
		spells.append(card)
	spells.append_array(path_package(content, primary))
	return spells


## The chosen Path's 8 starter cards (empty for Neutral).
static func path_package(content: ContentSet, primary: Affinity.Type) -> Array[CardData]:
	var cards: Array[CardData] = []
	if not PATH_PACKAGES.has(primary):
		return cards
	var recipe: Dictionary = PATH_PACKAGES[primary] as Dictionary
	var ids: Array = recipe.keys()
	ids.sort()
	for id: Variant in ids:
		var card: CardData = content.card(str(id))
		for copy: int in range(int(recipe[id])):
			if card != null:
				cards.append(card)
	return cards


## The real starter deck (Part C): the neutral spells and the Path's package plus 19 basic infrastructure of `primary`. 42
## cards - short of the 45 minimum until the tutorial reward picks fill it out.
static func starter_deck(content: ContentSet, primary: Affinity.Type) -> Deck:
	var deck: Deck = Deck.new()
	deck.deck_name = STARTER_DECK_NAME
	var template: Deck = content.deck(STARTER_DECK_NAME)
	if template == null or not is_valid_choice(primary):
		return deck
	var infra: CardData = content.infrastructure[int(primary)] as CardData
	for i: int in range(template.infrastructure_count()):
		deck.cards.append(infra)
	deck.cards.append_array(starter_spells(content, primary))
	return deck


## A fresh profile: starting stats, the starter spells (colorless plus the Path's package) as the collection, the chosen color
## recorded. Returns null for an invalid color choice (Neutral).
static func new_profile(content: ContentSet, primary: Affinity.Type) -> PlayerProfile:
	if not is_valid_choice(primary):
		return null
	var profile: PlayerProfile = PlayerProfile.new()
	profile.primary_affinity = primary
	profile.owned_cards = starter_spells(content, primary)
	return profile


## New brief (third), Part D: the secret tunnel skip grants 3 *random* on-element cards (unlike
## the normal tutorial's 3 curated reward picks, or `ElementChoice`'s fixed sample cards) - the
## same 45-card-legal shape the real tutorial reward picks would leave the starter deck in, just
## reached a different way. Non-infrastructure, `color`-affinity cards only; fewer than `count` exist for no
## element in the current content (8/8/7/7), but this stays correct if that ever changes.
static func random_element_cards(content: ContentSet, color: Affinity.Type, count: int, rng: RandomNumberGenerator) -> Array[CardData]:
	var pool: Array[CardData] = []
	for card: CardData in content.cards.values():
		if card.paths().size() == 1 and card.is_on_path(color) and not card.is_infrastructure():
			pool.append(card)
	RngUtil.shuffle(pool, rng)
	var result: Array[CardData] = []
	for i: int in range(mini(count, pool.size())):
		result.append(pool[i])
	return result

