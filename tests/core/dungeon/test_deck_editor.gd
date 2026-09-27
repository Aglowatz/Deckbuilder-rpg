extends GutTest

var content: ContentSet
var profile: PlayerProfile
var editor: DeckEditor


func before_each() -> void:
	content = ContentLibrary.load_all()
	profile = CampaignStart.new_profile(content, Affinity.Type.A)
	var lands: Array[CardData] = []
	for land: Variant in content.lands.values():
		lands.append(land as CardData)
	editor = DeckEditor.from(profile, CampaignStart.starter_deck(content, Affinity.Type.A), lands)


func test_starter_deck_is_valid() -> void:
	assert_true(editor.is_valid(), str(editor.issues().size()))


func test_cannot_add_more_than_owned_or_three_copies() -> void:
	var cave_bat: CardData = content.card("cave_bat")
	assert_eq(editor.why_not_add(cave_bat), "A deck holds at most 3 copies of a card.")
	profile.owned_cards.append(cave_bat)
	assert_ne(editor.why_not_add(cave_bat), "")


func test_cannot_add_unowned_cards() -> void:
	assert_eq(editor.why_not_add(content.card("firebolt")), "You do not own another copy.")


func test_third_color_is_refused() -> void:
	profile.owned_cards.append(content.card("frost_sentry"))
	profile.owned_cards.append(content.card("mossback_bear"))
	assert_true(editor.add(content.card("frost_sentry")), "second color is fine")
	assert_ne(editor.why_not_add(content.card("mossback_bear")), "", "third color is refused")


func test_remove_and_size_rules() -> void:
	assert_true(editor.remove(content.card("cave_bat")))
	assert_false(editor.is_valid(), "44 cards is below the minimum")
	assert_true(DeckValidator.has_problem(editor.issues(), DeckValidator.Problem.TOO_FEW_CARDS))


func test_autofill_lands_reaches_minimum() -> void:
	editor.remove(content.card("cave_bat"))
	editor.remove(content.card("sellsword"))
	var added: int = editor.autofill_lands()
	assert_eq(added, 2)
	assert_true(editor.is_valid())


func test_basic_lands_are_unlimited() -> void:
	var land: CardData = content.lands[int(Affinity.Type.A)] as CardData
	for i: int in range(5):
		assert_true(editor.add(land))
