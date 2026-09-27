extends GutTest

var content: ContentSet
var profile: PlayerProfile
var editor: DeckEditor
var waiver: ModifierSet


func before_each() -> void:
	content = ContentLibrary.load_all()
	profile = CampaignStart.new_profile(content, Affinity.Type.A)
	var lands: Array[CardData] = []
	for land: Variant in content.lands.values():
		lands.append(land as CardData)
	waiver = ModifierSet.new()
	waiver.add_source(TrialOfTheHollow.deck_size_waiver())
	# The 42-card starter is the realistic in-dungeon case (Part C), so the fixture edits it with
	# the tutorial's size waiver applied, same as DungeonDeckbuilderScreen would.
	editor = DeckEditor.from(profile, CampaignStart.starter_deck(content, Affinity.Type.A), lands, waiver)


func test_starter_deck_is_valid_with_the_tutorial_waiver() -> void:
	assert_true(editor.is_valid(), str(editor.issues().size()))


func test_starter_deck_is_not_valid_without_the_waiver() -> void:
	var plain: DeckEditor = DeckEditor.from(profile, CampaignStart.starter_deck(content, Affinity.Type.A), editor.lands)
	assert_false(plain.is_valid(), "42 cards is below the plain 45-card minimum")
	assert_true(DeckValidator.has_problem(plain.issues(), DeckValidator.Problem.TOO_FEW_CARDS))


func test_cannot_add_more_than_owned_or_three_copies() -> void:
	var scout: CardData = content.card("apprentice_blade")
	assert_eq(editor.why_not_add(scout), "A deck holds at most 3 copies of a card.")
	profile.owned_cards.append(scout)
	assert_ne(editor.why_not_add(scout), "")


func test_cannot_add_unowned_cards() -> void:
	assert_eq(editor.why_not_add(content.card("firebolt")), "You do not own another copy.")


func test_third_color_is_refused() -> void:
	profile.owned_cards.append(content.card("frost_sentry"))
	profile.owned_cards.append(content.card("mossback_bear"))
	assert_true(editor.add(content.card("frost_sentry")), "second color is fine")
	assert_ne(editor.why_not_add(content.card("mossback_bear")), "", "third color is refused")


func test_remove_and_size_rules() -> void:
	assert_true(editor.remove(content.card("cave_bat")))
	assert_false(editor.is_valid(), "41 cards is below the minimum, waiver included")
	assert_true(DeckValidator.has_problem(editor.issues(), DeckValidator.Problem.TOO_FEW_CARDS))


func test_autofill_lands_reaches_the_modifier_adjusted_minimum() -> void:
	editor.remove(content.card("cave_bat"))
	editor.remove(content.card("sellsword"))
	var added: int = editor.autofill_lands()
	assert_eq(added, 2, "tops up to the waived minimum (42), not the plain one")
	assert_true(editor.is_valid())


func test_autofill_lands_reaches_the_plain_minimum_without_a_waiver() -> void:
	var plain: DeckEditor = DeckEditor.from(profile, CampaignStart.starter_deck(content, Affinity.Type.A), editor.lands)
	plain.remove(content.card("cave_bat"))
	plain.remove(content.card("sellsword"))
	var added: int = plain.autofill_lands()
	assert_eq(added, 5, "40 cards up to the plain 45-card minimum")
	assert_true(plain.is_valid())


func test_basic_lands_are_unlimited() -> void:
	var land: CardData = content.lands[int(Affinity.Type.A)] as CardData
	for i: int in range(5):
		assert_true(editor.add(land))
