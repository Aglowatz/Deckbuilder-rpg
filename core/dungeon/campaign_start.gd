class_name CampaignStart
extends RefCounted
## The start of a new campaign: the player picks their Path in the forest (the Rescuer's conversation, `ElementChoiceScreen`) and
## `new_profile` / `starter_deck` hand them that Path's own **45-card starting deck** (Rebalance Part D, Oct 18): 19 basic
## Infrastructure of the Path plus 26 cards that teach its Resource and core mechanic - mostly Commons, a couple of Uncommon kinds,
## no Epics or Legendaries, never more than 3 copies of a card (`docs/design/starting_decks.md` has the lists and the game plans).
## It is a legal deck from the first turn; the 3 tutorial reward picks (one on-Path card per battle) grow it to 48 by the time the
## player reaches town. The old 42-card colorless starter (`STARTER_DECK_NAME`, still in `data/decks/`) is only a sim benchmark now.

const STARTER_DECK_NAME: String = "Wanderer's Pack"
const INFRASTRUCTURE_COUNT: int = 19
const SPELL_COUNT: int = 26

## Path -> {Card ID: copies}: the 26 non-Infrastructure cards of each starting deck.
const STARTING_DECKS: Dictionary = {
	# Beefcake - Iron burst turns: make Iron (Hamster Wheel Runner, Overclocked Mill Worker), spend it the turn you swing
	# (Personal Trainer grows, Flex on 'Em finishes), Hustle bodies and cheap removal keep the pressure up; a trap and a
	# Shot Putter so the deck can also hold a turn.
	Affinity.Type.BEEFCAKE: {
		"B-05": 3, "B-01": 2, "B-07": 1, "B-04": 2, "B-09": 2, "B-08": 2, "B-12": 2, "B-11": 1, "B-10": 1,
		"B-03": 2, "B-21": 2, "B-20": 1, "B-14": 1, "B-19": 1, "B-24": 2, "B-26": 1,
	},
	# Necrocrat - Red Tape and small tokens: Clerks and Interns make Red Tape, Body-builder and Middle Management turn it into
	# bodies, Requisition Form turns it into cards, Pink Slip and the Ghoul clear the way, the Waiting Room and Invisible Ink
	# slow Hustle swarms down, Notary Wraiths drain.
	Affinity.Type.NECROCRAT: {
		"N-01": 3, "N-02": 3, "N-04": 2, "N-06": 3, "N-09": 1, "N-15": 2, "N-16": 1, "N-18": 2, "N-20": 1,
		"N-07": 2, "N-03": 1, "N-13": 1, "N-12": 1, "N-23": 2, "N-26": 1,
	},
	# Gourmand - Ingredients into Golems: Line Cooks, Porters and the Herb Garden make Ingredients; the Mold, the Artificer and
	# the Apprentice cook them into Golems and Weenies; Sentries, Volunteers, En Garde-Mangers and Dinner Is Served hold the line.
	Affinity.Type.GOURMAND: {
		"G-01": 3, "G-09": 2, "G-02": 1, "G-15": 2, "G-12": 2, "G-08": 2, "G-03": 1, "G-06": 2, "G-04": 2, "G-07": 2,
		"G-16": 1, "G-05": 1, "G-20": 1, "G-25": 2, "G-23": 2,
	},
	# Refusemancer - Garbage effects and recursion: Rats, Divers and the Compost Bin make Garbage; the Possum, the Vomitor and the
	# Raised Bed eat it; Second-Hand Life brings a unit back; traps (Spring Trap, Garbage Pit) punish attackers and new units;
	# the Ox ramps into the Tortoise.
	Affinity.Type.REFUSEMANCER: {
		"R-06": 3, "R-08": 3, "R-02": 2, "R-10": 1, "R-05": 2, "R-19": 2, "R-01": 1, "R-03": 1, "R-09": 1, "R-07": 1, "R-11": 1,
		"R-14": 2, "R-22": 2, "R-24": 1, "R-12": 1, "R-04": 1, "R-17": 1,
	},
}

## One line per Path for the choice screen and the docs: what the deck wants to do.
const GAME_PLANS: Dictionary = {
	Affinity.Type.BEEFCAKE: "Make Iron, then spend it all on the turn you attack: every Iron is +1/+1 until end of turn, so one big swing wins the race.",
	Affinity.Type.NECROCRAT: "Make Red Tape with every Clerk and Intern, shrink their blocker with it, and turn the rest into 2/2 bodies and extra cards.",
	Affinity.Type.GOURMAND: "Stack Ingredients behind sturdy chefs, then cook them into Golems that are bigger than anything the enemy paid for.",
	Affinity.Type.REFUSEMANCER: "Make Garbage, eat it for damage and pumps, and bring your best cards back from the Refuse Pile. Nothing is wasted.",
}


static func is_valid_choice(color: Affinity.Type) -> bool:
	return STARTING_DECKS.has(color)


## The 26 non-Infrastructure cards of `primary`'s starting deck (empty for Neutral). These are the new profile's collection.
static func starter_spells(content: ContentSet, primary: Affinity.Type = Affinity.Type.NEUTRAL) -> Array[CardData]:
	var spells: Array[CardData] = []
	if not STARTING_DECKS.has(primary):
		return spells
	var recipe: Dictionary = STARTING_DECKS[primary] as Dictionary
	var ids: Array = recipe.keys()
	ids.sort()
	for id: Variant in ids:
		var card: CardData = content.card(str(id))
		if card == null:
			push_warning("CampaignStart: unknown starter card %s" % str(id))
			continue
		for copy: int in range(int(recipe[id])):
			spells.append(card)
	return spells


## Kept for callers that still ask for "the Path's package": the whole 26-card spell list.
static func path_package(content: ContentSet, primary: Affinity.Type) -> Array[CardData]:
	return starter_spells(content, primary)


## The real starting deck: 19 basic Infrastructure of `primary` plus its 26 cards = 45, legal from turn one.
static func starter_deck(content: ContentSet, primary: Affinity.Type) -> Deck:
	var deck: Deck = Deck.new()
	deck.deck_name = STARTER_DECK_NAME
	if not is_valid_choice(primary):
		return deck
	var infra: CardData = content.infrastructure[int(primary)] as CardData
	for i: int in range(INFRASTRUCTURE_COUNT):
		deck.cards.append(infra)
	deck.cards.append_array(starter_spells(content, primary))
	return deck


static func game_plan(primary: Affinity.Type) -> String:
	return str(GAME_PLANS.get(primary, ""))


## A fresh profile: starting stats, the starting deck's 26 cards as the collection, the chosen Path recorded. Null for Neutral.
static func new_profile(content: ContentSet, primary: Affinity.Type) -> PlayerProfile:
	if not is_valid_choice(primary):
		return null
	var profile: PlayerProfile = PlayerProfile.new()
	profile.primary_affinity = primary
	profile.owned_cards = starter_spells(content, primary)
	return profile


## New brief (third), Part D: the secret tunnel skip grants 3 *random* on-element cards (unlike
## the normal tutorial's 3 curated reward picks, or `ElementChoice`'s fixed sample cards) - the
## same 48-card shape the real tutorial reward picks would leave the starting deck in, just
## reached a different way. Non-infrastructure, `color`-affinity cards only, never one already in the starting deck.
static func random_element_cards(content: ContentSet, color: Affinity.Type, count: int, rng: RandomNumberGenerator) -> Array[CardData]:
	var pool: Array[CardData] = []
	var in_deck: Dictionary = STARTING_DECKS.get(color, {}) as Dictionary
	for card: CardData in content.cards.values():
		if card.paths().size() == 1 and card.is_on_path(color) and not card.is_infrastructure() and not in_deck.has(card.id):
			pool.append(card)
	RngUtil.shuffle(pool, rng)
	var result: Array[CardData] = []
	for i: int in range(mini(count, pool.size())):
		result.append(pool[i])
	return result
