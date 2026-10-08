class_name DeckValidator
extends RefCounted
## Deck construction rules: at least 45 cards (MIN_DECK_SIZE modifiers can lower this, e.g. the
## tutorial dungeon's starter-deck waiver), at most 4 copies of any non-infrastructure card at every level
## (infrastructure is unlimited), at most 2
## infrastructure/color types: ONE until the first zone is freed, TWO after that, FOUR once postgame_unlocked (Primm beaten and the throne taken);
## MAX_DECK_COLORS modifiers add more. Story v2: the Wanderer is too weak to carry more at first (see `path_limit_hint`).

const MIN_DECK_SIZE: int = 45
const MAX_COPIES: int = 4
const START_MAX_COLORS: int = 1
const BASE_MAX_COLORS: int = 2
const POSTGAME_MAX_COLORS: int = 4

enum Problem { TOO_FEW_CARDS, TOO_MANY_COPIES, TOO_MANY_COLORS, NOT_OWNED }


class Issue:
	extends RefCounted
	var problem: Problem = Problem.TOO_FEW_CARDS
	var card_id: String = ""
	var message: String = ""


## The Path limit before modifiers: 1 at the start, 2 once a zone is freed, 4 in the postgame.
static func base_max_colors(profile: PlayerProfile) -> int:
	if profile.postgame_unlocked:
		return POSTGAME_MAX_COLORS
	if profile.zones_freed >= 1:
		return BASE_MAX_COLORS
	return START_MAX_COLORS


## The themed line that explains the current Path limit (shown by the deck builder and in the validator's message).
static func path_limit_hint(profile: PlayerProfile, modifiers: ModifierSet = null) -> String:
	var limit: int = max_colors(profile, modifiers)
	if limit <= 1:
		return "You're still too weak to walk more than one Path. Free your first zone to walk a second."
	if limit == 2 and not profile.postgame_unlocked:
		return "Two Paths are all you can carry for now. Only the Pathwork Throne will let you walk more."
	return "A deck may use only %d Paths." % limit


## How many infrastructure/color types a deck may use.
static func max_colors(profile: PlayerProfile, modifiers: ModifierSet = null) -> int:
	var limit: int = base_max_colors(profile)
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
## contain more copies of a card than the profile owns (basic infrastructure are always available).
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
		basics[card.id] = card.is_unlimited()
	for card_id: Variant in counts.keys():
		var id: String = str(card_id)
		if bool(basics[id]):
			continue
		var limit: int = MAX_COPIES
		if int(counts[id]) > limit:
			issues.append(_issue(Problem.TOO_MANY_COPIES, id, "%d copies of %s; maximum is %d." % [int(counts[id]), id, limit]))
	var colors: int = deck.colors().size()
	var limit: int = max_colors(profile, modifiers)
	if colors > limit:
		issues.append(_issue(Problem.TOO_MANY_COLORS, "", "Deck uses %d Paths; limit is %d. %s" % [colors, limit, path_limit_hint(profile, modifiers)]))
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
