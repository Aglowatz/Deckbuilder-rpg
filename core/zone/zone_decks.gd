class_name ZoneDecks
extends RefCounted
## Builds enemy Decks from "Card ID -> copies" recipes (basic Infrastructure are BAS-B, BAS-N, BAS-G, BAS-R), for zone enemies and
## the mini dungeon (same convention as CorruptedNpcs / TrialOfTheHollow).


## Cards Oct 27, Part 2: an ENEMY-ONLY card (a named foe's personal card, `CardAvailability`) stays in a recipe only when `deck_name` (the
## enemy's name at every call site) is one of its owners (`CardData.availability_source`, "|"-separated) - so a generic archetype can
## never leak one, while Mortimer, Betty Bones, Clench and Primm keep theirs.
static func from_recipe(content: ContentSet, deck_name: String, recipe: Dictionary) -> Deck:
	var deck: Deck = Deck.new()
	deck.deck_name = deck_name
	for key: Variant in recipe.keys():
		var id: String = str(key)
		var card: CardData = content.card(id)
		if card == null:
			push_warning("ZoneDecks: unknown card %s" % id)
			continue
		if CardAvailability.is_enemy_only(card) and not CardAvailability.owner_allows(card, deck_name):
			push_warning("ZoneDecks: %s is enemy-only and %s is not its owner; dropped" % [id, deck_name])
			continue
		for i: int in range(int(recipe[key])):
			deck.cards.append(card)
	return deck


static func personality(content: ContentSet, ai_name: String) -> AIPersonality:
	for candidate: AIPersonality in content.personalities:
		if candidate.personality_name == ai_name:
			return candidate
	return AIPersonality.balanced()
