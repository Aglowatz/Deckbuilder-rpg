class_name DeckValidator
extends RefCounted
## Deck construction rules: at least 45 cards (MIN_DECK_SIZE modifiers can lower this, e.g. the
## tutorial dungeon's starter-deck waiver), at most 3 copies of a card (basic lands exempt), at
## most 2 land/color types (4 once postgame_unlocked; MAX_DECK_COLORS modifiers add more).

const MIN_DECK_SIZE: int = 45
const MAX_COPIES: int = 3
const BASE_MAX_COLORS: int = 2
const POSTGAME_MAX_COLORS: int = 4

enum Problem { TOO_FEW_CARDS, TOO_MANY_COPIES, TOO_MANY_COLORS, NOT_OWNED }


class Issue:
	extends RefCounted
	var problem: Problem = Problem.TOO_FEW_CARDS
	var card_id: String = ""
	var message: String = ""


## How many land/color types a deck may use.
static func max_colors(profile: PlayerProfile, modifiers: ModifierSet = null) -> int:
	var limit: int = POSTGAME_MAX_COLORS if profile.postgame_unlocked else BASE_MAX_COLORS
	if modifiers != null:
		limit += modifiers.sum(Modifier.Kind.MAX_DECK_COLORS)
	return clampi(limit, 1, Affinity.colored_types().size())


## The minimum legal deck size, lowered by any MIN_DECK_SIZE modifiers (e.g. the tutorial
## dungeon's starter-deck waiver). Never below 1.
static func min_deck_size(modifiers: ModifierSet = null) -> int:
	var size: int = MIN_DECK_SIZE
	if modifiers != null:
		size += modifiers.sum(Modifier.Kind.MIN_DECK_SIZE)
	return maxi(1, size)


## Returns every rule the deck breaks (empty = legal). With `check_ownership`, the deck may not
## contain more copies of a card than the profile owns (basic lands are always available).
static func validate(
	deck: Deck,
	profile: PlayerProfile,
	modifiers: ModifierSet = null,
	check_ownership: bool = false,
) -> Array[Issue]:
	var issues: Array[Issue] = []
	var min_size: int = min_deck_size(modifiers)
	if deck.size() < min_size:
		issues.append(_issue(Problem.TOO_FEW_CARDS, "", "Deck has %d cards; minimum is %d." % [deck.size(), min_size]))
	var counts: Dictionary = deck.copy_counts()
	var basics: Dictionary = {}
	for card: CardData in deck.cards:
		basics[card.id] = card.is_basic
	for card_id: Variant in counts.keys():
		var id: String = str(card_id)
		if bool(basics[id]):
			continue
		if int(counts[id]) > MAX_COPIES:
			issues.append(_issue(Problem.TOO_MANY_COPIES, id, "%d copies of %s; maximum is %d." % [int(counts[id]), id, MAX_COPIES]))
	var colors: int = deck.colors().size()
	var limit: int = max_colors(profile, modifiers)
	if colors > limit:
		issues.append(_issue(Problem.TOO_MANY_COLORS, "", "Deck uses %d land types; limit is %d." % [colors, limit]))
	if check_ownership:
		var owned: Dictionary = {}
		for card: CardData in profile.owned_cards:
			owned[card.id] = int(owned.get(card.id, 0)) + 1
		for card_id: Variant in counts.keys():
			var id: String = str(card_id)
			if bool(basics[id]):
				continue
			if int(counts[id]) > int(owned.get(id, 0)):
				issues.append(_issue(Problem.NOT_OWNED, id, "Deck has %d of %s but only %d are owned." % [int(counts[id]), id, int(owned.get(id, 0))]))
	return issues


static func is_valid(
	deck: Deck,
	profile: PlayerProfile,
	modifiers: ModifierSet = null,
	check_ownership: bool = false,
) -> bool:
	return validate(deck, profile, modifiers, check_ownership).is_empty()


static func has_problem(issues: Array[Issue], problem: Problem) -> bool:
	for issue: Issue in issues:
		if issue.problem == problem:
			return true
	return false


static func _issue(problem: Problem, card_id: String, message: String) -> Issue:
	var issue: Issue = Issue.new()
	issue.problem = problem
	issue.card_id = card_id
	issue.message = message
	return issue
