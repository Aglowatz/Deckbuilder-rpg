class_name ZoneDecks
extends RefCounted
## Builds enemy Decks from "Card ID -> copies" recipes (basic Infrastructure are BAS-B, BAS-N, BAS-G, BAS-R), for zone enemies and
## the mini dungeon (same convention as CorruptedNpcs / TrialOfTheHollow).


static func from_recipe(content: ContentSet, deck_name: String, recipe: Dictionary) -> Deck:
	var deck: Deck = Deck.new()
	deck.deck_name = deck_name
	for key: Variant in recipe.keys():
		var id: String = str(key)
		var card: CardData = content.card(id)
		if card == null:
			push_warning("ZoneDecks: unknown card %s" % id)
			continue
		for i: int in range(int(recipe[key])):
			deck.cards.append(card)
	return deck


static func personality(content: ContentSet, ai_name: String) -> AIPersonality:
	for candidate: AIPersonality in content.personalities:
		if candidate.personality_name == ai_name:
			return candidate
	return AIPersonality.balanced()
