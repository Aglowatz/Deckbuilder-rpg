class_name CampaignStart
extends RefCounted
## The start of a new campaign (Part C): the player picks their element BEFORE the tutorial
## dungeon, in the starting area (`ElementChoiceScreen`). `new_profile`/`starter_deck` then build
## the 42-card starter - 23 colorless spells + 19 basic infrastructure of the chosen element - the player
## carries into the Trial of the Hollow. It is short of the normal 45-card minimum on purpose
## (`TrialOfTheHollow.deck_size_waiver()`); the 3 tutorial reward picks (one on-element card per
## battle) bring it up to a real, legal 45-card deck by the time the player reaches town.
## See docs/design/starting_deck_and_affinity.md for the story framing.

const STARTER_DECK_NAME: String = "Wanderer's Pack"


static func is_valid_choice(color: Affinity.Type) -> bool:
	return color != Affinity.Type.NEUTRAL


## The neutral spells of the starter template (basic infrastructure are not part of the collection).
static func starter_spells(content: ContentSet) -> Array[CardData]:
	var spells: Array[CardData] = []
	var template: Deck = content.deck(STARTER_DECK_NAME)
	if template == null:
		return spells
	for card: CardData in template.cards:
		if not card.is_infrastructure():
			spells.append(card)
	return spells


## The real starter deck (Part C): the 23 neutral spells plus 19 basic infrastructure of `primary`. 42
## cards - short of the 45 minimum until the tutorial reward picks fill it out.
static func starter_deck(content: ContentSet, primary: Affinity.Type) -> Deck:
	var deck: Deck = Deck.new()
	deck.deck_name = STARTER_DECK_NAME
	var template: Deck = content.deck(STARTER_DECK_NAME)
	if template == null or not is_valid_choice(primary):
		return deck
	var infra: CardData = content.infrastructure[int(primary)] as CardData
	for card: CardData in template.cards:
		deck.cards.append(infra if card.is_infrastructure() else card)
	return deck


## A fresh profile: starting stats, the neutral spells as the collection, the chosen color
## recorded. Returns null for an invalid color choice (Neutral).
static func new_profile(content: ContentSet, primary: Affinity.Type) -> PlayerProfile:
	if not is_valid_choice(primary):
		return null
	var profile: PlayerProfile = PlayerProfile.new()
	profile.primary_affinity = primary
	profile.owned_cards = starter_spells(content)
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

