class_name CardAvailability
extends RefCounted
## Cards Oct 27, Part 2: who can get which card. Every card carries an availability (`CardData.availability`, from
## `data/source/card_overrides.csv`, column `availability`; the design table is `docs/design/card_availability.md`):
##
## - GENERAL: packs, shops, reward picks, the Alchemist - anywhere cards are generated.
## - REWARD_LOCKED: never generated until the player has earned one from its named source (a dungeon's first clear, a boss's card
##   pick, a quest, a hidden chest: `CardData.availability_source` is the hint the Collection Book shows). Once earned (one copy owned,
##   or the id in the save's `earned_cards`), it may turn up in packs, shops and picks at its rarity like any other card.
## - ENEMY_ONLY: a named foe's personal card. Only that encounter's deck uses it; never in packs, shops, rewards, the Alchemist or the
##   player's pool. The Collection Book lists these under "Seen in battle", outside the 100%. A player who already owned one before this
##   rule (an old save) keeps it, marked grandfathered (`Session.grandfathered_cards`), and the Dev Menu's override can still add one.
##
## Generic enemy decks (`EnemyDecks.ARCHETYPES`) hold no ENEMY_ONLY card; a named encounter adds its own as `extra` cards, and
## `ZoneDecks.from_recipe` drops any ENEMY_ONLY card a recipe did not declare as a signature.

enum Kind { GENERAL, REWARD_LOCKED, ENEMY_ONLY }

const LABELS: Dictionary = {Kind.GENERAL: "GENERAL", Kind.REWARD_LOCKED: "REWARD-LOCKED", Kind.ENEMY_ONLY: "ENEMY-ONLY"}


static func parse(text: String) -> Kind:
	var cleaned: String = text.strip_edges().to_upper().replace("_", "-")
	if cleaned == "REWARD-LOCKED" or cleaned == "REWARD" or cleaned == "LOCKED":
		return Kind.REWARD_LOCKED
	if cleaned == "ENEMY-ONLY" or cleaned == "ENEMY":
		return Kind.ENEMY_ONLY
	return Kind.GENERAL


static func label(kind: Kind) -> String:
	return str(LABELS.get(kind, "GENERAL"))


static func kind_of(card: CardData) -> Kind:
	if card == null:
		return Kind.GENERAL
	return clampi(card.availability, 0, Kind.size() - 1) as Kind


static func is_enemy_only(card: CardData) -> bool:
	return kind_of(card) == Kind.ENEMY_ONLY


static func is_reward_locked(card: CardData) -> bool:
	return kind_of(card) == Kind.REWARD_LOCKED


## Whether a generator (packs, shelves, picks, the Alchemist...) may produce `card` for a player who has earned the cards in `earned`
## (card id -> anything truthy; `Session.earned_cards_map()` builds it from the collection and the save). ENEMY_ONLY: never.
static func allowed(card: CardData, earned: Dictionary = {}) -> bool:
	match kind_of(card):
		Kind.ENEMY_ONLY:
			return false
		Kind.REWARD_LOCKED:
			return earned.has(card.id)
	return true


## The Collection Book's hint for a locked card the player has not earned ("Earned in the Hall of Final Approvals").
static func hint(card: CardData) -> String:
	if card == null or card.availability_source.strip_edges().is_empty():
		match kind_of(card):
			Kind.REWARD_LOCKED:
				return "Earned from a specific source"
			Kind.ENEMY_ONLY:
				return "An enemy's own card"
		return ""
	return card.availability_source.strip_edges()


## Whether the enemy named `deck_name` may run an ENEMY_ONLY card: its `availability_source` lists the owners ("|"-separated; a
## name matches when the deck's name is, starts with or contains it, so "Primm" covers every phase of Primm).
static func owner_allows(card: CardData, deck_name: String) -> bool:
	if card == null or not is_enemy_only(card):
		return true
	for owner: String in card.availability_source.split("|"):
		var name: String = owner.strip_edges()
		if not name.is_empty() and (deck_name == name or deck_name.begins_with(name) or deck_name.contains(name)):
			return true
	return false


## Every id in `ids` that is ENEMY_ONLY (for the deck builders' warnings and the tests).
static func enemy_only_ids(content: ContentSet, ids: Array) -> Array[String]:
	var result: Array[String] = []
	for id: Variant in ids:
		var card: CardData = content.card(str(id))
		if card != null and is_enemy_only(card):
			result.append(str(id))
	return result
