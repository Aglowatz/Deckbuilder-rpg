extends GutTest

var _content: ContentSet


func before_all() -> void:
	_content = ContentLibrary.load_all()


func test_starter_deck_is_neutral_spells_plus_chosen_color_lands() -> void:
	for color: Affinity.Type in Affinity.colored_types():
		var deck: Deck = CampaignStart.starter_deck(_content, color)
		assert_eq(deck.size(), 45)
		assert_eq(deck.land_count(), 17)
		assert_eq(deck.colors(), [color] as Array[Affinity.Type], "only the chosen color appears")
		for card: CardData in deck.cards:
			assert_true(card.is_land() or card.color == Affinity.Type.NEUTRAL, card.id)
		assert_true(DeckValidator.is_valid(deck, PlayerProfile.new()))


func test_neutral_is_not_a_valid_starting_choice() -> void:
	assert_false(CampaignStart.is_valid_choice(Affinity.Type.NEUTRAL))
	assert_null(CampaignStart.new_profile(_content, Affinity.Type.NEUTRAL))
	assert_eq(CampaignStart.starter_deck(_content, Affinity.Type.NEUTRAL).size(), 0)


func test_new_profile_owns_only_the_neutral_starter_cards() -> void:
	var profile: PlayerProfile = CampaignStart.new_profile(_content, Affinity.Type.C)
	assert_eq(profile.primary_affinity, Affinity.Type.C)
	assert_false(profile.intro_dungeon_cleared)
	assert_eq(profile.owned_cards.size(), 28)
	for card: CardData in profile.owned_cards:
		assert_eq(card.color, Affinity.Type.NEUTRAL)
	assert_eq(profile.base_max_life(), 10)
	assert_eq(profile.base_opening_hand(), 5)
	var deck: Deck = CampaignStart.starter_deck(_content, Affinity.Type.C)
	assert_true(DeckValidator.is_valid(deck, profile, null, true), "the starter deck is buildable from the collection")


func test_intro_dungeon_grants_five_cards_of_the_chosen_color_once() -> void:
	for color: Affinity.Type in Affinity.colored_types():
		var profile: PlayerProfile = CampaignStart.new_profile(_content, color)
		var granted: Array[CardData] = CampaignStart.complete_intro_dungeon(profile, _content)
		assert_eq(granted.size(), 5, Affinity.display_name(color))
		var seen: Dictionary = {}
		for card: CardData in granted:
			assert_eq(card.color, color)
			seen[card.id] = true
		assert_eq(seen.size(), 5, "five different cards")
		assert_eq(profile.owned_cards.size(), 33)
		assert_true(profile.intro_dungeon_cleared)
		assert_eq(CampaignStart.complete_intro_dungeon(profile, _content).size(), 0, "only granted once")
		assert_eq(profile.owned_cards.size(), 33)


func test_reward_requires_a_chosen_color() -> void:
	var profile: PlayerProfile = PlayerProfile.new()
	assert_eq(CampaignStart.complete_intro_dungeon(profile, _content).size(), 0)
	assert_false(profile.intro_dungeon_cleared)


func test_player_can_build_a_two_color_deck_from_starter_plus_reward() -> void:
	var profile: PlayerProfile = CampaignStart.new_profile(_content, Affinity.Type.A)
	CampaignStart.complete_intro_dungeon(profile, _content)
	var deck: Deck = CampaignStart.starter_deck(_content, Affinity.Type.A)
	# Swap five neutral spells for the five attuned cards.
	var swapped: int = 0
	for i: int in range(deck.cards.size()):
		if swapped < 5 and not deck.cards[i].is_land():
			deck.cards[i] = CampaignStart.attunement_cards(_content, Affinity.Type.A)[swapped]
			swapped += 1
	assert_true(DeckValidator.is_valid(deck, profile, null, true))


func test_no_sample_pair_deck_is_given_to_the_player() -> void:
	var profile: PlayerProfile = CampaignStart.new_profile(_content, Affinity.Type.B)
	var ember: Deck = _content.deck("Ember & Tide")
	assert_false(DeckValidator.is_valid(ember, profile, null, true), "pair decks must be built by the player")


func test_profile_choice_survives_tres() -> void:
	var profile: PlayerProfile = CampaignStart.new_profile(_content, Affinity.Type.D)
	var path: String = "user://test_profile.tres"
	assert_eq(ResourceSaver.save(profile, path), OK)
	var loaded: PlayerProfile = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) as PlayerProfile
	assert_eq(loaded.primary_affinity, Affinity.Type.D)
	assert_eq(loaded.owned_cards.size(), 28)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
