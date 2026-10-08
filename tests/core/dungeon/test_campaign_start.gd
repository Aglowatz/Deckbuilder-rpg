extends GutTest

var _content: ContentSet


func before_all() -> void:
	_content = ContentLibrary.load_all()


func test_starter_deck_is_neutral_spells_plus_chosen_color_infrastructure() -> void:
	for color: Affinity.Type in Affinity.colored_types():
		var deck: Deck = CampaignStart.starter_deck(_content, color)
		assert_eq(deck.size(), 42, "15 colorless spells + the Path's 8 package cards + 19 infrastructure, short of 45 on purpose")
		assert_eq(deck.infrastructure_count(), 19)
		assert_eq(deck.colors(), [color] as Array[Affinity.Type], "only the chosen color appears")
		for card: CardData in deck.cards:
			assert_true(card.is_infrastructure() or card.color == Affinity.Type.NEUTRAL or card.color == color, card.id)
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


func test_new_profile_owns_the_colorless_starter_cards_and_the_path_package() -> void:
	var profile: PlayerProfile = CampaignStart.new_profile(_content, Affinity.Type.REFUSEMANCER)
	assert_eq(profile.primary_affinity, Affinity.Type.REFUSEMANCER)
	assert_false(profile.intro_dungeon_cleared)
	assert_eq(profile.owned_cards.size(), 23)
	for card: CardData in profile.owned_cards:
		assert_true(card.color == Affinity.Type.NEUTRAL or card.color == Affinity.Type.REFUSEMANCER, card.id)
	assert_eq(profile.base_max_hp(), 10)
	assert_eq(profile.base_opening_hand(), 5)
	var deck: Deck = CampaignStart.starter_deck(_content, Affinity.Type.REFUSEMANCER)
	var modifiers: ModifierSet = ModifierSet.new()
	modifiers.add_source(TrialOfTheHollow.deck_size_waiver())
	assert_true(DeckValidator.is_valid(deck, profile, modifiers, true), "the starter deck is buildable from the collection")


func test_no_sample_pair_deck_is_given_to_the_player() -> void:
	var profile: PlayerProfile = CampaignStart.new_profile(_content, Affinity.Type.GOURMAND)
	var beefcake: Deck = _content.deck("Beefcake & Gourmand")
	assert_false(DeckValidator.is_valid(beefcake, profile, null, true), "pair decks must be built by the player")


## New brief (third), Part D: the secret tunnel skip's 3 random on-element cards - distinct,
## actually of that element, deterministic for a given seed.
func test_random_element_cards_are_distinct_and_on_element() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 42
	var picks: Array[CardData] = CampaignStart.random_element_cards(_content, Affinity.Type.BEEFCAKE, 3, rng)
	assert_eq(picks.size(), 3)
	var seen_ids: Dictionary = {}
	for card: CardData in picks:
		assert_eq(card.color, Affinity.Type.BEEFCAKE)
		assert_false(card.is_infrastructure())
		assert_false(seen_ids.has(card.id), "no duplicate picks")
		seen_ids[card.id] = true


func test_random_element_cards_same_seed_same_picks() -> void:
	var rng_a: RandomNumberGenerator = RandomNumberGenerator.new()
	rng_a.seed = 7
	var rng_b: RandomNumberGenerator = RandomNumberGenerator.new()
	rng_b.seed = 7
	var picks_a: Array[CardData] = CampaignStart.random_element_cards(_content, Affinity.Type.REFUSEMANCER, 3, rng_a)
	var picks_b: Array[CardData] = CampaignStart.random_element_cards(_content, Affinity.Type.REFUSEMANCER, 3, rng_b)
	for i: int in range(3):
		assert_eq(picks_a[i].id, picks_b[i].id)


func test_profile_choice_survives_tres() -> void:
	var profile: PlayerProfile = CampaignStart.new_profile(_content, Affinity.Type.NECROCRAT)
	var path: String = "user://test_profile.tres"
	assert_eq(ResourceSaver.save(profile, path), OK)
	var loaded: PlayerProfile = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) as PlayerProfile
	assert_eq(loaded.primary_affinity, Affinity.Type.NECROCRAT)
	assert_eq(loaded.owned_cards.size(), 23)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


## Story v2 Part C: every Path's starter leans on its own Resource, using only existing Common cards, at most 3 copies each.
func test_each_path_package_is_eight_commons_that_make_or_spend_the_resource() -> void:
	for color: Affinity.Type in Affinity.colored_types():
		var package: Array[CardData] = CampaignStart.path_package(_content, color)
		assert_eq(package.size(), 8, "8 package cards for %s" % str(color))
		var copies: Dictionary = {}
		for card: CardData in package:
			assert_true(card.is_on_path(color), card.id)
			assert_eq(card.rarity, CardEnums.Rarity.COMMON, card.id)
			copies[card.id] = int(copies.get(card.id, 0)) + 1
		for id: String in copies.keys():
			assert_true(int(copies[id]) <= 3, id)
		var deck: Deck = CampaignStart.starter_deck(_content, color)
		assert_eq(deck.size(), 42)
		var counts: Dictionary = {}
		for card: CardData in deck.cards:
			counts[card.id] = int(counts.get(card.id, 0)) + 1
		for id: String in counts.keys():
			if not (_content.card(id) as CardData).is_infrastructure():
				assert_true(int(counts[id]) <= 3, "%s x%d" % [id, int(counts[id])])


## The Forgotten Cave has no Beefcake or Necrocrat infrastructure, cards or resources on the enemy side.
func test_the_forgotten_cave_enemy_decks_avoid_beefcake_and_necrocrat() -> void:
	for enemy: String in ["Cave Scavenger", "Hollow Stalker", "Hollow Warden"]:
		for id: String in TrialOfTheHollow.enemy_recipe(enemy).keys():
			assert_false(id.begins_with("B-") or id.begins_with("N-") or id == "BAS-B" or id == "BAS-N", "%s uses %s" % [enemy, id])
