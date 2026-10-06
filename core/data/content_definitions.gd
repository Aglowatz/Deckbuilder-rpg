class_name ContentDefinitions
extends RefCounted
## The game's content set, assembled in code: the designed card set (imported from the sheets by `CardImporter`, scripts in
## data/scripts), plus the decks, challenges, AI personalities, equipment and items. `tools/generate_content.gd` writes the
## non-card parts out as .tres files (the cards and tokens are written by `tools/import_cards`); tests validate it.
## Numbers are placeholders (balance is out of scope).

const DECK_SIZE: int = 45
const STARTER_DECK_NAME: String = "Wanderer's Pack"


static func build() -> ContentSet:
	var content: ContentSet = ContentSet.new()
	for entry: CardImporter.Entry in CardImporter.build_all():
		content.index_card(entry.data)
		if entry.is_token:
			TokenRegistry.register(entry.data)
	content.decks = build_decks(content)
	content.challenges = ChallengeExamples.all(reward_pool(content))
	content.personalities = [AIPersonality.balanced(), AIPersonality.aggressive(), AIPersonality.defensive(), AIPersonality.passive(), AIPersonality.aggressive_dumb()] as Array[AIPersonality]
	content.zone_equipment = ProgressionContent.zone_equipment()
	content.equipment = ProgressionContent.equipment()
	content.items = ProgressionContent.items(content.tokens)
	return content


## Four colorless cards the story challenges (the Scholar's riddle, the toll keeper) may hand out.
static func reward_pool(content: ContentSet) -> Array[CardData]:
	var pool: Array[CardData] = []
	for id: String in ["C-20", "C-21", "C-22", "C-15"]:
		var card: CardData = content.card(id)
		if card != null:
			pool.append(card)
	return pool


# ---- Decks ---------------------------------------------------------------------------


## Each recipe: name, and "Card ID -> copies" (basic Infrastructure are the BAS-x ids).
static func deck_recipes() -> Array[Dictionary]:
	return [
		{"name": "Beefcake & Gourmand", "recipe": EnemyDecks.trimmed("gourmand_beefcake", 45, 17)},
		{"name": "Gourmand & Refusemancer", "recipe": EnemyDecks.trimmed("gourmand_refusemancer", 45, 17)},
		{"name": "Refusemancer & Necrocrat", "recipe": EnemyDecks.trimmed("necrocrat_refusemancer", 45, 17)},
		{"name": "Necrocrat & Beefcake", "recipe": EnemyDecks.trimmed("necrocrat_beefcake", 45, 17)},
		# The tutorial-dungeon starter template (docs/design/starting_deck_and_affinity.md): 19 Infrastructure + 23 Colorless
		# cards = 42 cards, NOT the normal 45-card minimum - the `TrialOfTheHollow` MIN_DECK_SIZE waiver covers the gap until
		# the 3 tutorial reward picks fill it back out. Its Infrastructure Path here (Beefcake) is irrelevant:
		# `CampaignStart.starter_deck` replaces every Infrastructure with the player's actually-chosen Path.
		{
			"name": STARTER_DECK_NAME,
			"recipe": {
				"BAS-B": 19, "C-01": 3, "C-02": 3, "C-03": 2, "C-04": 2, "C-05": 1, "C-06": 2, "C-07": 1, "C-08": 1, "C-10": 1,
				"C-11": 1, "C-12": 1, "C-13": 1, "C-14": 1, "C-16": 1, "C-17": 1, "C-19": 1,
			},
		},
	]


static func build_decks(content: ContentSet) -> Array[Deck]:
	var decks: Array[Deck] = []
	for definition: Dictionary in deck_recipes():
		var deck: Deck = Deck.new()
		deck.deck_name = str(definition["name"])
		var recipe: Dictionary = definition["recipe"] as Dictionary
		var ids: Array = recipe.keys()
		ids.sort()
		for id: Variant in ids:
			var card: CardData = content.card(str(id))
			assert(card != null, "deck %s uses unknown card %s" % [deck.deck_name, id])
			for i: int in range(int(recipe[id])):
				deck.cards.append(card)
		decks.append(deck)
	return decks
