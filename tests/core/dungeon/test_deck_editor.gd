extends GutTest

var content: ContentSet
var profile: PlayerProfile
var editor: DeckEditor
var waiver: ModifierSet


func before_each() -> void:
	content = ContentLibrary.load_all()
	profile = CampaignStart.new_profile(content, Affinity.Type.A)
	var infrastructure: Array[CardData] = []
	for infra: Variant in content.infrastructure.values():
		infrastructure.append(infra as CardData)
	waiver = ModifierSet.new()
	waiver.add_source(TrialOfTheHollow.deck_size_waiver())
	# The 42-card starter is the realistic in-dungeon case (Part C), so the fixture edits it with
	# the tutorial's size waiver applied, same as DungeonDeckbuilderScreen would.
	editor = DeckEditor.from(profile, CampaignStart.starter_deck(content, Affinity.Type.A), infrastructure, waiver)


func test_starter_deck_is_valid_with_the_tutorial_waiver() -> void:
	assert_true(editor.is_valid(), str(editor.issues().size()))


func test_starter_deck_is_not_valid_without_the_waiver() -> void:
	var plain: DeckEditor = DeckEditor.from(profile, CampaignStart.starter_deck(content, Affinity.Type.A), editor.infrastructure)
	assert_false(plain.is_valid(), "42 cards is below the plain 45-card minimum")
	assert_true(DeckValidator.has_problem(plain.issues(), DeckValidator.Problem.TOO_FEW_CARDS))


func test_cannot_add_more_than_owned_or_four_copies() -> void:
	var scout: CardData = content.card("apprentice_blade")
	assert_ne(editor.why_not_add(scout), "", "starts unowned or at the owned limit")
	for i: int in range(6):
		profile.owned_cards.append(scout)
	while editor.count(scout) < 4:
		assert_true(editor.add(scout))
	assert_eq(editor.why_not_add(scout), "A deck holds at most 4 copies of any card (infrastructure is unlimited).")
	assert_false(editor.add(scout), "a fifth copy is refused even though it is owned")


func test_cannot_add_unowned_cards() -> void:
	assert_eq(editor.why_not_add(content.card("firebolt")), "You do not own another copy.")


func test_third_color_is_refused() -> void:
	profile.owned_cards.append(content.card("frost_sentry"))
	profile.owned_cards.append(content.card("mossback_bear"))
	assert_true(editor.add(content.card("frost_sentry")), "second color is fine")
	assert_ne(editor.why_not_add(content.card("mossback_bear")), "", "third color is refused")


## Part F: the deck builder's own gate (DeckEditor.why_not_add), not just DeckValidator directly,
## must also read the flag - confirming the whole chain (engine + deck builder) is tied to it.
func test_third_color_allowed_after_postgame_unlocked() -> void:
	profile.owned_cards.append(content.card("frost_sentry"))
	profile.owned_cards.append(content.card("mossback_bear"))
	assert_true(editor.add(content.card("frost_sentry")), "2nd color is fine")
	assert_ne(editor.why_not_add(content.card("mossback_bear")), "", "a 3rd color is refused before postgame")
	profile.postgame_unlocked = true
	assert_eq(editor.why_not_add(content.card("mossback_bear")), "", "postgame_unlocked lets the deck builder allow a 3rd color too")
	assert_true(editor.add(content.card("mossback_bear")))
	assert_eq(editor.deck.colors().size(), 3)


func test_remove_and_size_rules() -> void:
	assert_true(editor.remove(content.card("cave_bat")))
	assert_false(editor.is_valid(), "41 cards is below the minimum, waiver included")
	assert_true(DeckValidator.has_problem(editor.issues(), DeckValidator.Problem.TOO_FEW_CARDS))


func test_autofill_infrastructure_reaches_the_modifier_adjusted_minimum() -> void:
	editor.remove(content.card("cave_bat"))
	editor.remove(content.card("sellsword"))
	var added: int = editor.autofill_infrastructure()
	assert_eq(added, 2, "tops up to the waived minimum (42), not the plain one")
	assert_true(editor.is_valid())


func test_autofill_infrastructure_reaches_the_plain_minimum_without_a_waiver() -> void:
	var plain: DeckEditor = DeckEditor.from(profile, CampaignStart.starter_deck(content, Affinity.Type.A), editor.infrastructure)
	plain.remove(content.card("cave_bat"))
	plain.remove(content.card("sellsword"))
	var added: int = plain.autofill_infrastructure()
	assert_eq(added, 5, "40 cards up to the plain 45-card minimum")
	assert_true(plain.is_valid())


func test_basic_infrastructure_are_unlimited() -> void:
	var infra: CardData = content.infrastructure[int(Affinity.Type.A)] as CardData
	for i: int in range(5):
		assert_true(editor.add(infra))
