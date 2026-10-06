extends GutTest

var _content: ContentSet
var _defined: ContentSet


func before_all() -> void:
	_content = ContentLibrary.load_all()
	_defined = ContentDefinitions.build()



# ---- The generated .tres content -----------------------------------------------------


func test_the_designed_set_is_loaded() -> void:
	var total: int = _content.cards.size() + _content.multipath_cards.size() + _content.infrastructure.size()
	assert_eq(total, 312, "every card of the sheet is in the content set")
	assert_eq(_content.tokens.size(), 27, "26 sheet/guidance tokens + the junk card")
	assert_eq(_content.infrastructure.size(), 4, "one basic Infrastructure per Path")
	for color: Affinity.Type in Affinity.colored_types():
		var infra: CardData = _content.infrastructure[int(color)]
		assert_true(infra.is_infrastructure())
		assert_true(infra.is_basic)
	assert_true(_content.card("T-16").is_token)
	assert_not_null(_content.card("C-01"))
	assert_null(_content.card("NOPE-01"))


func test_saved_files_match_the_code_definitions() -> void:
	assert_eq(_content.cards.size(), _defined.cards.size())
	assert_eq(_content.multipath_cards.size(), _defined.multipath_cards.size())
	for id: Variant in _defined.cards.keys():
		assert_true(_content.cards.has(id), "missing .tres for %s (run tools/import_cards.sh --write)" % id)
		var defined: CardData = _defined.cards[id]
		var saved: CardData = _content.cards[id]
		assert_eq(saved.display_name, defined.display_name)
		assert_eq(saved.generic_cost, defined.generic_cost)
		assert_eq(saved.colored_pips, defined.colored_pips)
		assert_eq(saved.attack, defined.attack)
		assert_eq(saved.defense, defined.defense)
		assert_eq(saved.script_text, defined.script_text)
	assert_eq(_content.decks.size(), _defined.decks.size())
	assert_eq(_content.challenges.size(), 6)
	assert_eq(_content.personalities.size(), 5)


func test_every_card_is_well_formed() -> void:
	for card: CardData in _content.all_collectible():
		assert_ne(card.display_name, "", card.id)
		if not card.script_text.is_empty():
			assert_ne(card.rules_text, "", "%s needs rules text" % card.id)
		if card.is_unit():
			assert_gt(card.defense, 0, card.id)


func test_every_color_has_cards_and_identity_keywords() -> void:
	var has: Callable = func(color: Affinity.Type, keyword: CardEnums.Keyword) -> bool:
		for card: CardData in _content.cards.values():
			if card.paths().size() == 1 and card.paths().has(color) and card.has_keyword(keyword):
				return true
		return false
	assert_true(has.call(Affinity.Type.BEEFCAKE, CardEnums.Keyword.HUSTLE))
	assert_true(has.call(Affinity.Type.REFUSEMANCER, CardEnums.Keyword.BULLDOZE))


func test_deck_recipes_are_legal_sizes() -> void:
	assert_eq(_content.decks.size(), 5)
	for deck: Deck in _content.decks:
		if deck.deck_name == CampaignStart.STARTER_DECK_NAME:
			assert_eq(deck.size(), 42, "19 Infrastructure + 23 Colorless - short of 45 on purpose")
			continue
		assert_eq(deck.size(), 45, deck.deck_name)
		assert_eq(deck.infrastructure_count(), 17, deck.deck_name)


func test_decks_only_use_cards_from_the_library() -> void:
	for deck: Deck in _content.decks:
		for card: CardData in deck.cards:
			assert_not_null(_content.card(card.id), "%s: unknown card %s" % [deck.deck_name, card.id])


func test_starter_deck_has_only_colorless_spells() -> void:
	var starter: Deck = _content.deck(CampaignStart.STARTER_DECK_NAME)
	assert_not_null(starter)
	assert_eq(starter.infrastructure_count(), 19)
	for card: CardData in starter.cards:
		if not card.is_infrastructure():
			assert_eq(card.paths().size(), 0, "%s must be Colorless" % card.id)


func test_challenge_files_resolve_against_a_real_deck() -> void:
	var run: DungeonRun = DungeonRun.enter(PlayerProfile.new(), _content.decks[0])
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 5
	for challenge: ChallengeData in _content.challenges:
		var result: ChallengeResult = ChallengeResolver.resolve(challenge, run, rng)
		assert_eq(result.challenge_id, challenge.id)
		run.heal(99)
	assert_false(run.failed)
