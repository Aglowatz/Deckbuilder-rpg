class_name CampaignStart
extends RefCounted
## The start of a new campaign (Part C): the player picks their element BEFORE the tutorial
## dungeon, in the starting area (`ElementChoiceScreen`). `new_profile`/`starter_deck` then build
## the 42-card starter - 23 colorless spells + 19 basic lands of the chosen element - the player
## carries into the Trial of the Hollow. It is short of the normal 45-card minimum on purpose
## (`TrialOfTheHollow.deck_size_waiver()`); the 3 tutorial reward picks (one on-element card per
## battle) bring it up to a real, legal 45-card deck by the time the player reaches town.
## See docs/design/starting_deck_and_affinity.md for the story framing.

const STARTER_DECK_NAME: String = "Wanderer's Pack"


static func is_valid_choice(color: Affinity.Type) -> bool:
	return color != Affinity.Type.NEUTRAL


## The neutral spells of the starter template (basic lands are not part of the collection).
static func starter_spells(content: ContentSet) -> Array[CardData]:
	var spells: Array[CardData] = []
	var template: Deck = content.deck(STARTER_DECK_NAME)
	if template == null:
		return spells
	for card: CardData in template.cards:
		if not card.is_land():
			spells.append(card)
	return spells


## The real starter deck (Part C): the 23 neutral spells plus 19 basic lands of `primary`. 42
## cards - short of the 45 minimum until the tutorial reward picks fill it out.
static func starter_deck(content: ContentSet, primary: Affinity.Type) -> Deck:
	var deck: Deck = Deck.new()
	deck.deck_name = STARTER_DECK_NAME
	var template: Deck = content.deck(STARTER_DECK_NAME)
	if template == null or not is_valid_choice(primary):
		return deck
	var land: CardData = content.lands[int(primary)] as CardData
	for card: CardData in template.cards:
		deck.cards.append(land if card.is_land() else card)
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

