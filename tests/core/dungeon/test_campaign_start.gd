extends GutTest

var _content: ContentSet


func before_all() -> void:
	_content = ContentLibrary.load_all()


func test_each_starting_deck_is_a_legal_45_card_path_deck() -> void:
	for color: Affinity.Type in Affinity.colored_types():
		var deck: Deck = CampaignStart.starter_deck(_content, color)
		assert_eq(deck.size(), 45, "19 infrastructure + 26 cards of the Path (Rebalance Part D)")
		assert_eq(deck.infrastructure_count(), 19)
		assert_eq(deck.colors(), [color] as Array[Affinity.Type], "only the chosen Path appears")
		for card: CardData in deck.cards:
			assert_true(card.is_infrastructure() or card.color == color, card.id)
		assert_true(DeckValidator.is_valid(deck, PlayerProfile.new()), "legal under the plain rules from turn one")
		var modifiers: ModifierSet = ModifierSet.new()
		modifiers.add_source(TrialOfTheHollow.deck_size_waiver())
		assert_true(DeckValidator.is_valid(deck, PlayerProfile.new(), modifiers), "and with the legacy waiver")


func test_neutral_is_not_a_valid_starting_choice() -> void:
	assert_false(CampaignStart.is_valid_choice(Affinity.Type.NEUTRAL))
	assert_null(CampaignStart.new_profile(_content, Affinity.Type.NEUTRAL))
	assert_eq(CampaignStart.starter_deck(_content, Affinity.Type.NEUTRAL).size(), 0)


func test_new_profile_owns_the_colorless_starter_cards_and_the_path_package() -> void:
	var profile: PlayerProfile = CampaignStart.new_profile(_content, Affinity.Type.REFUSEMANCER)
	assert_eq(profile.primary_affinity, Affinity.Type.REFUSEMANCER)
	assert_false(profile.intro_dungeon_cleared)
	assert_eq(profile.owned_cards.size(), CampaignStart.SPELL_COUNT)
	for card: CardData in profile.owned_cards:
		assert_eq(card.color, Affinity.Type.REFUSEMANCER, card.id)
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
	assert_eq(loaded.owned_cards.size(), CampaignStart.SPELL_COUNT)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


## Rebalance Part D: every Path's starting deck is mostly Commons, a few Uncommon kinds, no Epics or Legendaries, at most 3 copies
## of a card (2 of an Uncommon, the level-1 cap), and it both makes and spends its Resource.
func test_each_starting_deck_is_mostly_commons_within_the_copy_caps_and_teaches_its_resource() -> void:
	var spends: Dictionary = {
		Affinity.Type.BEEFCAKE: "iron", Affinity.Type.NECROCRAT: "redtape", Affinity.Type.GOURMAND: "ingredient", Affinity.Type.REFUSEMANCER: "garbage",
	}
	for color: Affinity.Type in Affinity.colored_types():
		var spells: Array[CardData] = CampaignStart.starter_spells(_content, color)
		assert_eq(spells.size(), CampaignStart.SPELL_COUNT, "26 cards for %s" % Affinity.display_name(color))
		var copies: Dictionary = {}
		var commons: int = 0
		var uncommon_kinds: Dictionary = {}
		var makes: bool = false
		var uses: bool = false
		var word: String = str(spends[color])
		for card: CardData in spells:
			assert_true(card.is_on_path(color), card.id)
			assert_true(card.rarity == CardEnums.Rarity.COMMON or card.rarity == CardEnums.Rarity.UNCOMMON, "%s is not Common/Uncommon" % card.id)
			if card.rarity == CardEnums.Rarity.COMMON:
				commons += 1
			else:
				uncommon_kinds[card.id] = true
			copies[card.id] = int(copies.get(card.id, 0)) + 1
			if card.script_text.contains("create(%s" % word):
				makes = true
			if card.script_text.contains("use(%s" % word) or card.script_text.contains("resource_used:mine:%s" % word) or (word == "garbage" and card.script_text.contains("eat")):
				uses = true
		assert_true(commons >= 20, "%s: mostly commons (%d)" % [Affinity.display_name(color), commons])
		assert_true(uncommon_kinds.size() >= 1 and uncommon_kinds.size() <= 3, "%s: a couple of uncommon kinds (%d)" % [Affinity.display_name(color), uncommon_kinds.size()])
		assert_true(makes and uses, "%s makes and spends its Resource" % Affinity.display_name(color))
		for id: String in copies.keys():
			var card: CardData = _content.card(id)
			assert_true(int(copies[id]) <= CopyCaps.for_card(card, 1), "%s x%d within the level-1 cap" % [id, int(copies[id])])
		var profile: PlayerProfile = CampaignStart.new_profile(_content, color)
		assert_true(DeckValidator.is_valid(CampaignStart.starter_deck(_content, color), profile, null, true), "buildable from the new collection")


## The Forgotten Cave has no Beefcake or Necrocrat infrastructure, cards or resources on the enemy side.
func test_the_forgotten_cave_enemy_decks_avoid_beefcake_and_necrocrat() -> void:
	for enemy: String in ["Cave Scavenger", "Hollow Stalker", "Hollow Warden"]:
		for id: String in TrialOfTheHollow.enemy_recipe(enemy).keys():
			assert_false(id.begins_with("B-") or id.begins_with("N-") or id == "BAS-B" or id == "BAS-N", "%s uses %s" % [enemy, id])
