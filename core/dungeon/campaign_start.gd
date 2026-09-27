class_name CampaignStart
extends RefCounted
## The start of a new campaign. The player begins with the neutral starter deck only. Their
## chosen primary color decides which basic lands they channel mana through; after the intro
## dungeon the Wellspring of that color attunes them and grants five cards of that color.
## Other decks (including the sample pair decks) are for the player to discover and build.
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


## The starting deck: the neutral spells plus basic lands of the chosen color.
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


## The five reward cards for a color (one copy each).
static func attunement_cards(content: ContentSet, primary: Affinity.Type) -> Array[CardData]:
	var cards: Array[CardData] = []
	var ids: Array = ContentDefinitions.attunement_rewards().get(primary, [])
	for id: Variant in ids:
		var card: CardData = content.card(str(id))
		if card != null:
			cards.append(card)
	return cards


## Grants the attunement reward once, when the intro dungeon is cleared. Returns the granted
## cards (empty if already granted or no color was chosen).
static func complete_intro_dungeon(profile: PlayerProfile, content: ContentSet) -> Array[CardData]:
	var granted: Array[CardData] = []
	if profile.intro_dungeon_cleared or not is_valid_choice(profile.primary_affinity):
		return granted
	granted = attunement_cards(content, profile.primary_affinity)
	profile.owned_cards.append_array(granted)
	profile.intro_dungeon_cleared = true
	return granted
