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
		return CopyCaps.UNLIMITED
	var total: int = 0
	for candidate: CardData in profile.owned_cards:
		if candidate.id == card.id:
			total += 1
	return total


## How many copies of `card` the deck may hold at the player's level (`CopyCaps`; basic infrastructure: unlimited).
func cap(card: CardData) -> int:
	return CopyCaps.for_card(card, profile.level)


## "2/3": copies in the deck against the cap (empty for infrastructure).
func cap_text(card: CardData) -> String:
	return CopyCaps.ratio_text(count(card), card, profile.level)


## Fable Nov 21 (Part 3): the kinds of refusal. A Path refusal (the card's Path does not fit the deck, or the card is a sealed three- or
## four-Path card) is shown as a pop-up the player confirms; the others stay a short line.
const REFUSED_TOKEN: String = "token"
const REFUSED_COPIES: String = "copies"
const REFUSED_NOT_OWNED: String = "not_owned"
const REFUSED_LOCKED: String = "locked"
const REFUSED_PATHS: String = "paths"


static func needs_popup(kind: String) -> bool:
	return kind == REFUSED_LOCKED or kind == REFUSED_PATHS


## "" when `card` may be added, otherwise which rule refuses it (one of the REFUSED_ constants).
func why_not_kind(card: CardData) -> String:
	if card.is_token:
		return REFUSED_TOKEN
	if MultiPathLock.locked_for(card, profile):
		return REFUSED_LOCKED
	if not card.is_unlimited():
		if count(card) >= cap(card):
			return REFUSED_COPIES
		if count(card) >= owned(card):
			return REFUSED_NOT_OWNED
	var resulting: Array[Affinity.Type] = deck.colors()
	for path: Affinity.Type in card.paths():
		if not resulting.has(path):
			resulting.append(path)
	if resulting.size() > DeckValidator.max_colors(profile, modifiers) and resulting.size() > deck.colors().size():
		return REFUSED_PATHS
	return ""


## Empty string when `card` may be added, otherwise the reason it cannot.
func why_not_add(card: CardData) -> String:
	match why_not_kind(card):
		REFUSED_TOKEN:
			return "Tokens cannot be put in a deck."
		REFUSED_LOCKED:
			return MultiPathLock.reason(card)
		REFUSED_COPIES:
			return CopyCaps.reason(card, profile.level)
		REFUSED_NOT_OWNED:
			return "You do not own another copy."
		REFUSED_PATHS:
			var hint: String = DeckValidator.path_limit_hint(profile, modifiers)
			if card.is_multipath():
				return "%s needs %s. %s" % [card.display_name, "two Paths" if card.paths().size() == 2 else "%d Paths" % card.paths().size(), hint]
			return "%s is a %s card. %s" % [card.display_name, Affinity.display_name(card.color), hint]
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
