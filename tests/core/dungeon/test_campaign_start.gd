extends GutTest

var _content: ContentSet


func before_all() -> void:
	_content = ContentLibrary.load_all()


func test_starter_deck_is_neutral_spells_plus_chosen_color_lands() -> void:
	for color: Affinity.Type in Affinity.colored_types():
		var deck: Deck = CampaignStart.starter_deck(_content, color)
		assert_eq(deck.size(), 42, "23 neutral spells + 19 lands, short of 45 on purpose")
		assert_eq(deck.land_count(), 19)
		assert_eq(deck.colors(), [color] as Array[Affinity.Type], "only the chosen color appears")
		for card: CardData in deck.cards:
			assert_true(card.is_land() or card.color == Affinity.Type.NEUTRAL, card.id)
		# Not legal under the plain rules (too few cards)...
		assert_false(DeckValidator.is_valid(deck, PlayerProfile.new()))
		# ...but legal with the tutorial dungeon's size waiver applied.
		var modifiers: ModifierSet = ModifierSet.new()
		modifiers.add_source(TrialOfTheHollow.deck_size_waiver())
		assert_true(DeckValidator.is_valid(deck, PlayerProfile.new(), modifiers))


func test_neutral_is_not_a_valid_starting_choice() -> void:
	assert_false(CampaignStart.is_valid_choice(Affinity.Type.NEUTRAL))
	assert_null(CampaignStart.new_profile(_content, Affinity.Type.NEUTRAL))
	assert_eq(CampaignStart.starter_deck(_content, Affinity.Type.NEUTRAL).size(), 0)


func test_new_profile_owns_only_the_neutral_starter_cards() -> void:
	var profile: PlayerProfile = CampaignStart.new_profile(_content, Affinity.Type.C)
	assert_eq(profile.primary_affinity, Affinity.Type.C)
	assert_false(profile.intro_dungeon_cleared)
	assert_eq(profile.owned_cards.size(), 23)
	for card: CardData in profile.owned_cards:
		assert_eq(card.color, Affinity.Type.NEUTRAL)
	assert_eq(profile.base_max_life(), 10)
	assert_eq(profile.base_opening_hand(), 5)
	var deck: Deck = CampaignStart.starter_deck(_content, Affinity.Type.C)
	var modifiers: ModifierSet = ModifierSet.new()
	modifiers.add_source(TrialOfTheHollow.deck_size_waiver())
	assert_true(DeckValidator.is_valid(deck, profile, modifiers, true), "the starter deck is buildable from the collection")


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
	assert_eq(loaded.owned_cards.size(), 23)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
