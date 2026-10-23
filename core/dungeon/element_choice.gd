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
	## Overnight Oct 22, Part 3: the one-line game plan on the tile (the identity and playstyle show on hover/focus or with More).
	var plan: String = ""
	## A few representative cards of this element, shown on the tile - not necessarily owned yet.
	var sample_cards: Array[CardData] = []


## affinity -> {identity, playstyle, a few representative card ids}. One entry per
## Affinity.colored_types() color.
const RECIPES: Array[Dictionary] = [
	{
		"affinity": Affinity.Type.BEEFCAKE,
		"plan": "Hit hard and early. Save up Iron, then spend it all on one big swing.",
		"identity": "Beefcake is aggressive and chaotic: Hustle, big strong units, raw stat boosts, Tools, tempo and direct damage. Burst now, pay later.",
		"playstyle": "Race to deal damage before the table settles. Make Iron, then spend it all on the turn you swing: +1/+1 each until end of turn.",
		"sample_card_ids": ["B-05", "B-09", "B-21"],
	},
	{
		"affinity": Affinity.Type.GOURMAND,
		"plan": "Hold the line with sturdy chefs and cook Ingredients into huge Golems.",
		"identity": "Gourmand is refined and controlling: chefs and Wonders that turn Ingredients into big Golem tokens, recipes, healing, bounce and Plating.",
		"playstyle": "Control the pace, stack Ingredients behind sturdy chefs, cook them into Golems, and win the long game.",
		"sample_card_ids": ["G-01", "G-12", "G-08"],
	},
	{
		"affinity": Affinity.Type.REFUSEMANCER,
		"plan": "Make Garbage, eat it for power, and bring your best cards back.",
		"identity": "Refusemancer is resilient and recycling: Garbage-eating units, ramp into big units, the Refuse Pile as a resource, scrappy rats, and Tool and Wonder destruction.",
		"playstyle": "Make Garbage, eat it for damage and pumps, bring your best cards back from the Refuse Pile, and ramp into huge units.",
		"sample_card_ids": ["R-06", "R-08", "R-22"],
	},
	{
		"affinity": Affinity.Type.NECROCRAT,
		"plan": "Shrink their blockers with Red Tape, then outlast them.",
		"identity": "Necrocrat is orderly and value-grinding: small tokens, reanimation, drain, delayed but inevitable effects, taxes and fees, Red Tape and Contracts.",
		"playstyle": "Make Red Tape with every Clerk and Intern, shrink their blockers with it, and turn the rest into bodies and cards.",
		"sample_card_ids": ["N-02", "N-04", "N-15"],
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
		offer.plan = str(recipe.get("plan", ""))
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
