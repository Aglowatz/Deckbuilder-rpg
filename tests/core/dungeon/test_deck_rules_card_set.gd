extends CardTestBase
## Brief 14: the deck rules with the designed card set: up to 4 copies of each non-Infrastructure card, unlimited Infrastructure,
## 2 Paths in the main game (a card counts as each of its Paths, including 3- and 4-Path cards), all Paths after the postgame.


func _deck(ids: Array[String], counts: Array[int]) -> Deck:
	CardSet.load_all()
	var deck: Deck = Deck.new()
	for index: int in range(ids.size()):
		for copy: int in range(counts[index]):
			deck.cards.append(CardSet.card(ids[index]))
	return deck


## Fills a deck up to `size` with distinct Colorless cards (4 copies each), so the only rule under test is the one in the test.
func _fill(deck: Deck, size: int) -> Deck:
	var fillers: Array[String] = ["C-01", "C-02", "C-03", "C-04", "C-05", "C-06", "C-07", "C-08", "C-09", "C-13", "C-14", "C-15", "C-16"]
	var index: int = 0
	while deck.cards.size() < size and index < fillers.size() * 4:
		deck.cards.append(CardSet.card(fillers[index / 4]))
		index += 1
	return deck


func _profile(postgame: bool = false) -> PlayerProfile:
	var profile: PlayerProfile = PlayerProfile.new()
	profile.postgame_unlocked = postgame
	profile.zones_freed = 1  # the second Path is open once a zone is freed
	return profile


func test_four_copies_of_a_card_are_fine_and_a_fifth_is_not() -> void:
	var legal: Deck = _fill(_deck(["BAS-B", "B-01"] as Array[String], [19, 4] as Array[int]), 45)
	assert_true(DeckValidator.is_valid(legal, _profile()), "4 copies and 45 cards")
	var illegal: Deck = _fill(_deck(["BAS-B", "B-01"] as Array[String], [19, 5] as Array[int]), 45)
	assert_true(DeckValidator.has_problem(DeckValidator.validate(illegal, _profile()), DeckValidator.Problem.TOO_MANY_COPIES))


func test_infrastructure_is_unlimited_including_special_and_dual_ones() -> void:
	var deck: Deck = _fill(_deck(["BAS-B", "INF-01", "INF-08", "B-01"] as Array[String], [10, 6, 6, 4] as Array[int]), 45)
	var issues: Array[DeckValidator.Issue] = DeckValidator.validate(deck, _profile())
	assert_false(DeckValidator.has_problem(issues, DeckValidator.Problem.TOO_MANY_COPIES), "6 copies of one Infrastructure are fine")


func test_a_deck_may_use_two_paths_until_the_postgame() -> void:
	var two: Deck = _fill(_deck(["BAS-B", "BAS-G", "B-01", "G-01"] as Array[String], [10, 9, 4, 4] as Array[int]), 45)
	assert_true(DeckValidator.is_valid(two, _profile()))
	var three: Deck = _fill(_deck(["BAS-B", "BAS-G", "BAS-R", "B-01"] as Array[String], [7, 6, 6, 4] as Array[int]), 45)
	assert_true(DeckValidator.has_problem(DeckValidator.validate(three, _profile()), DeckValidator.Problem.TOO_MANY_COLORS))
	assert_true(DeckValidator.is_valid(three, _profile(true)), "all Paths after the postgame")


func test_a_multi_path_card_counts_as_each_of_its_paths() -> void:
	var dual: Deck = _fill(_deck(["BAS-B", "GB-01"] as Array[String], [19, 4] as Array[int]), 45)
	assert_eq(dual.colors().size(), 2, "Gourmand/Beefcake uses both Paths")
	var plus_one: Deck = _fill(_deck(["BAS-R", "GB-01"] as Array[String], [19, 4] as Array[int]), 45)
	assert_eq(plus_one.colors().size(), 3, "a Refusemancer basic plus a Gourmand/Beefcake card is three Paths")
	assert_true(DeckValidator.has_problem(DeckValidator.validate(plus_one, _profile()), DeckValidator.Problem.TOO_MANY_COLORS))
	var triple: Deck = _fill(_deck(["BAS-B", "GRB-01"] as Array[String], [19, 4] as Array[int]), 45)
	assert_eq(triple.colors().size(), 3, "a three-Path card is three Paths")
	var quad: Deck = _fill(_deck(["BAS-B", "P4-01"] as Array[String], [19, 4] as Array[int]), 45)
	assert_eq(quad.colors().size(), 4)
	assert_true(DeckValidator.is_valid(quad, _profile(true)))


func test_colorless_cards_use_no_path() -> void:
	var deck: Deck = _fill(_deck(["BAS-N"] as Array[String], [19] as Array[int]), 45)
	assert_eq(deck.colors().size(), 1)
