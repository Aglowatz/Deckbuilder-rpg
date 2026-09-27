class_name CampaignStart
extends RefCounted
## The start of a new campaign: `starter_deck`/`starter_spells`/`new_profile` build the fixed
## neutral deck the player is given for the tutorial dungeon (the Trial of the Hollow), before
## they have chosen anything. What happens after the tutorial - picking a real starting deck -
## is `StartingDecks` / `Session.choose_starting_deck`.
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


## A neutral-spells-plus-one-color deck. No longer used for the real starting choice (see
## `StartingDecks`), but kept as a lightweight profile/deck pair for tests and tools.
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

