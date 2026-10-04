class_name ZoneDecks
extends RefCounted
## Builds enemy Decks from "card id (or infrastructure:<A|B|C|D>) -> copies" recipes, for zone enemies and
## the mini dungeon (same convention as CorruptedNpcs / TrialOfTheHollow).


static func from_recipe(content: ContentSet, deck_name: String, recipe: Dictionary) -> Deck:
	var deck: Deck = Deck.new()
	deck.deck_name = deck_name
	for key: Variant in recipe.keys():
		var id: String = str(key)
		var card: CardData = null
		if id.begins_with("infrastructure:"):
			var color: Affinity.Type = ["", "A", "B", "C", "D"].find(id.substr(15)) as Affinity.Type
			card = content.infrastructure[int(color)] as CardData
		else:
			card = content.card(id)
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
