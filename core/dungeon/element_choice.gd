class_name ElementChoice
extends RefCounted
## The element (affinity) choice offered in the starting area, before the tutorial dungeon (Part
## C - see docs/design/starting_deck_and_affinity.md). Purely flavor/identity data for
## `ElementChoiceScreen`; the actual starter deck is built by `CampaignStart`.

class Offer:
	extends RefCounted
	var affinity: Affinity.Type = Affinity.Type.NEUTRAL
	var identity: String = ""
	var playstyle: String = ""
	## A few representative cards of this element, shown on the tile - not necessarily owned yet.
	var sample_cards: Array[CardData] = []


## affinity -> {identity, playstyle, a few representative card ids}. One entry per
## Affinity.colored_types() color.
const RECIPES: Array[Dictionary] = [
	{
		"affinity": Affinity.Type.BEEFCAKE,
		"identity": "Beefcake is aggressive and chaotic: Hustle, big strong units, raw stat boosts, Tools, tempo and direct damage. Burst now, pay later.",
		"playstyle": "Race to deal damage before the table settles. Pump your units with Iron and strike first.",
		"sample_card_ids": ["B-01", "B-14", "B-03"],
	},
	{
		"affinity": Affinity.Type.GOURMAND,
		"identity": "Gourmand is refined and controlling: chefs and Wonders that turn Ingredients into big Golem tokens, recipes, healing, bounce and Plating.",
		"playstyle": "Control the pace, cook Golems from Ingredients, and win the long game.",
		"sample_card_ids": ["G-01", "G-08", "G-21"],
	},
	{
		"affinity": Affinity.Type.REFUSEMANCER,
		"identity": "Refusemancer is resilient and recycling: Garbage-eating units, ramp into big units, the Refuse Pile as a resource, scrappy rats, and Tool and Wonder destruction.",
		"playstyle": "Eat Garbage, recycle your Refuse Pile and ramp into huge units.",
		"sample_card_ids": ["R-06", "R-19", "R-02"],
	},
	{
		"affinity": Affinity.Type.NECROCRAT,
		"identity": "Necrocrat is orderly and value-grinding: small tokens, reanimation, drain, delayed but inevitable effects, taxes and fees, Red Tape and Contracts.",
		"playstyle": "Go wide, grind with Red Tape and Contracts, and bring your units back.",
		"sample_card_ids": ["N-02", "N-15", "N-09"],
	},
]


## Every offer, in `Affinity.colored_types()` order, with the cards resolved from `content`.
static func offers(content: ContentSet) -> Array[Offer]:
	var result: Array[Offer] = []
	for recipe: Dictionary in RECIPES:
		var offer: Offer = Offer.new()
		offer.affinity = recipe["affinity"] as Affinity.Type
		offer.identity = str(recipe["identity"])
		offer.playstyle = str(recipe["playstyle"])
		for id: Variant in recipe["sample_card_ids"] as Array:
			var card: CardData = content.card(str(id))
			if card != null:
				offer.sample_cards.append(card)
		result.append(offer)
	return result


static func offer_for(content: ContentSet, affinity: Affinity.Type) -> Offer:
	for offer: Offer in offers(content):
		if offer.affinity == affinity:
			return offer
	return null
