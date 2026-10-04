class_name DeckEditor
extends RefCounted
## The rules of editing a deck in the Deck Station: which cards may be added or removed and
## why not. Works on a private copy of the deck; nothing changes until the caller saves it.

var profile: PlayerProfile
var deck: Deck
var infrastructure: Array[CardData] = []
## Active modifiers (e.g. a dungeon's MIN_DECK_SIZE waiver or a MAX_DECK_COLORS boon). Null means
## "no adjustments" - the plain town rules.
var modifiers: ModifierSet


static func from(player_profile: PlayerProfile, source: Deck, basic_infrastructure: Array[CardData], active_modifiers: ModifierSet = null) -> DeckEditor:
	var editor: DeckEditor = DeckEditor.new()
	editor.profile = player_profile
	editor.deck = Deck.new()
	editor.deck.deck_name = source.deck_name
	editor.deck.cards = source.cards.duplicate()
	editor.infrastructure = basic_infrastructure
	editor.modifiers = active_modifiers
	return editor


func count(card: CardData) -> int:
	return deck.count_of(card.id)


func owned(card: CardData) -> int:
	if card.is_unlimited():
		return 9999
	var total: int = 0
	for candidate: CardData in profile.owned_cards:
		if candidate.id == card.id:
			total += 1
	return total


## Empty string when `card` may be added, otherwise the reason it cannot.
func why_not_add(card: CardData) -> String:
	if card.is_token:
		return "Tokens cannot be put in a deck."
	if not card.is_unlimited():
		var limit: int = DeckValidator.MAX_COPIES
		if count(card) >= limit:
			return "A deck holds at most %d copies of any card (infrastructure is unlimited)." % limit
		if count(card) >= owned(card):
			return "You do not own another copy."
	if card.color != Affinity.Type.NEUTRAL and not deck.colors().has(card.color):
		if deck.colors().size() >= DeckValidator.max_colors(profile, modifiers):
			return "A deck may use only %d colors." % DeckValidator.max_colors(profile, modifiers)
	return ""


func add(card: CardData) -> bool:
	if why_not_add(card) != "":
		return false
	deck.cards.append(card)
	return true


func remove(card: CardData) -> bool:
	var index: int = deck.cards.find(card)
	if index < 0:
		# Tolerate equal-id resources loaded separately.
		for position: int in range(deck.cards.size()):
			if deck.cards[position].id == card.id:
				index = position
				break
	if index < 0:
		return false
	deck.cards.remove_at(index)
	return true


func issues() -> Array[DeckValidator.Issue]:
	return DeckValidator.validate(deck, profile, modifiers, true)


func is_valid() -> bool:
	return issues().is_empty()


## Adds basic infrastructure until the deck reaches the minimum size, spread over the deck's colors
## (the profile's primary color when the deck has none). Returns how many were added.
func autofill_infrastructure() -> int:
	var colors: Array[Affinity.Type] = deck.colors()
	if colors.is_empty():
		colors.append(profile.primary_affinity)
	var candidates: Array[CardData] = []
	for infra: CardData in infrastructure:
		if colors.has(infra.color):
			candidates.append(infra)
	if candidates.is_empty():
		return 0
	var added: int = 0
	var turn: int = 0
	var target_size: int = DeckValidator.min_deck_size(modifiers)
	while deck.size() < target_size and added < 60:
		# Add to whichever color currently has the fewest infrastructure.
		var best: CardData = candidates[0]
		for infra: CardData in candidates:
			if count(infra) < count(best):
				best = infra
		deck.cards.append(best)
		added += 1
		turn += 1
	return added


func infrastructure_count() -> int:
	return deck.infrastructure_count()
