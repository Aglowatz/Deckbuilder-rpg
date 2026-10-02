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
		"affinity": Affinity.Type.A,
		"identity": "Beefcake hits hard and fast: haste, power spells and huge aggressive bodies that punish a slow start.",
		"playstyle": "Race to deal damage before the table settles. Strike first, strike often.",
		"sample_card_ids": ["beefcake_imp", "blazing_charger", "firebolt"],
	},
	{
		"affinity": Affinity.Type.B,
		"identity": "Gourmand answers: bounce, card draw and food-golem defenders that buy time while you out-cook the opponent.",
		"playstyle": "Control the pace, see more cards than they do, win the long game.",
		"sample_card_ids": ["deep_insight", "frost_sentry", "recall"],
	},
	{
		"affinity": Affinity.Type.C,
		"identity": "Root grows: big, sturdy creatures and life gain that outlast anything thrown at them.",
		"playstyle": "Stabilize behind tough bodies, then close it out with size.",
		"sample_card_ids": ["ancient_treant", "mossback_bear", "growth"],
	},
	{
		"affinity": Affinity.Type.D,
		"identity": "Necrocrat trades: sacrifice, death triggers and drain effects that turn losses into value.",
		"playstyle": "Grind through exchanges; every creature that dies is doing you a favor.",
		"sample_card_ids": ["bloodthirst_wolf", "necromancer", "soul_drain"],
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
