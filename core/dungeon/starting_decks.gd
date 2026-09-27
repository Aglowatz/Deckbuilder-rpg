class_name StartingDecks
extends RefCounted
## The starting-deck choice offered right after the tutorial dungeon (see
## docs/design/starting_deck_and_affinity.md): one deck per affinity, built from the existing
## balanced two-color sample decks (`ContentDefinitions.deck_recipes()`), each framed as that
## affinity's identity. The player owns every card in the deck they pick, so it is playable and
## legal immediately - there is no separate "attunement reward" any more (superseded, see
## docs/design/open_questions.md D30).

class Offer:
	extends RefCounted
	var affinity: Affinity.Type = Affinity.Type.NEUTRAL
	var deck_name: String = ""
	var identity: String = ""
	var playstyle: String = ""
	var key_cards: Array[CardData] = []


## affinity -> {deck_name (must match a ContentDefinitions.deck_recipes() entry), identity,
## playstyle, key card ids to preview}. One entry per Affinity.colored_types() color.
const RECIPES: Array[Dictionary] = [
	{
		"affinity": Affinity.Type.A, "deck_name": "Ember & Tide",
		"identity": "Ember burns fast: haste, burn spells and aggressive bodies that punish a slow start.",
		"playstyle": "Race to deal damage before the table settles. Strike first, strike often.",
		"key_card_ids": ["ember_imp", "blazing_charger", "firebolt"],
	},
	{
		"affinity": Affinity.Type.B, "deck_name": "Tide & Root",
		"identity": "Tide answers: bounce, card draw and defenders that buy time to out-think the opponent.",
		"playstyle": "Control the pace, see more cards than they do, win the long game.",
		"key_card_ids": ["deep_insight", "frost_sentry", "recall"],
	},
	{
		"affinity": Affinity.Type.C, "deck_name": "Root & Grave",
		"identity": "Root grows: big, sturdy creatures and life gain that outlast anything thrown at them.",
		"playstyle": "Stabilize behind tough bodies, then close it out with size.",
		"key_card_ids": ["ancient_treant", "mossback_bear", "growth"],
	},
	{
		"affinity": Affinity.Type.D, "deck_name": "Grave & Ember",
		"identity": "Grave trades: sacrifice, death triggers and drain effects that turn losses into value.",
		"playstyle": "Grind through exchanges; every creature that dies is doing you a favor.",
		"key_card_ids": ["bloodthirst_wolf", "necromancer", "soul_drain"],
	},
]


## Every offer, in `Affinity.colored_types()` order, with the cards resolved from `content`.
static func offers(content: ContentSet) -> Array[Offer]:
	var result: Array[Offer] = []
	for recipe: Dictionary in RECIPES:
		var offer: Offer = Offer.new()
		offer.affinity = recipe["affinity"] as Affinity.Type
		offer.deck_name = str(recipe["deck_name"])
		offer.identity = str(recipe["identity"])
		offer.playstyle = str(recipe["playstyle"])
		for id: Variant in recipe["key_card_ids"] as Array:
			var card: CardData = content.card(str(id))
			if card != null:
				offer.key_cards.append(card)
		result.append(offer)
	return result


static func offer_for(content: ContentSet, affinity: Affinity.Type) -> Offer:
	for offer: Offer in offers(content):
		if offer.affinity == affinity:
			return offer
	return null


## A fresh copy of the chosen affinity's starting deck (safe to hand to the player - editing it
## never touches the shared content library deck).
static func deck_for(content: ContentSet, affinity: Affinity.Type) -> Deck:
	var offer: Offer = offer_for(content, affinity)
	if offer == null:
		return null
	var template: Deck = content.deck(offer.deck_name)
	if template == null:
		return null
	var deck: Deck = Deck.new()
	deck.deck_name = template.deck_name
	deck.cards = template.cards.duplicate()
	return deck
