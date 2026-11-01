extends GutTest
## Fable pass Nov 1, Part 6: the first duel deals a teaching hand (FirstDuel) - two basics, the two cheapest units, one trick - for every
## Path's starter, GameState pulls it from the deck, and the Scavenger's deck has no 2/2 to wall a new player's 2/1s.


func test_every_starter_gets_two_basics_two_cheap_units_and_a_trick() -> void:
	var content: ContentSet = Session.content
	for path: Affinity.Type in Affinity.colored_types():
		var deck: Deck = CampaignStart.starter_deck(content, path)
		var ids: Array[String] = FirstDuel.opening_hand_for_deck(deck)
		assert_eq(ids.size(), 5, "%s: a full hand" % Affinity.display_name(path))
		var basics: int = 0
		var units: int = 0
		var others: int = 0
		var max_unit_cost: int = 0
		for id: String in ids:
			var card: CardData = content.card(id)
			assert_not_null(card, id)
			if card.is_infrastructure():
				basics += 1
			elif card.is_unit():
				units += 1
				max_unit_cost = maxi(max_unit_cost, card.generic_cost)
			else:
				others += 1
		assert_eq(basics, FirstDuel.BASICS, "%s: two Infrastructure" % Affinity.display_name(path))
		assert_eq(units, FirstDuel.UNITS, "%s: two units" % Affinity.display_name(path))
		assert_eq(others, FirstDuel.OTHERS, "%s: one trick" % Affinity.display_name(path))
		assert_lte(max_unit_cost, 2, "%s: the units are cheap (max cost %d)" % [Affinity.display_name(path), max_unit_cost])


func test_the_game_deals_the_scripted_hand_to_the_hero_only() -> void:
	var content: ContentSet = Session.content
	var deck: Deck = CampaignStart.starter_deck(content, Affinity.Type.BEEFCAKE)
	var options: GameOptions = GameOptions.new()
	options.rng_seed = 42
	options.first_player = 0
	FirstDuel.apply(options, deck)
	var game: GameState = GameState.new(options)
	game.add_player(PlayerSetup.create(deck, null, [] as Array[ModifierSource], "Hero"))
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), null, [] as Array[ModifierSource], "Foe"))
	game.start()
	var dealt: Array[String] = []
	for card: CardInstance in game.players[0].hand:
		dealt.append(card.data.id)
	assert_eq(dealt, options.scripted_opening_hand, "the hero's hand is the teaching hand, in order")
	assert_eq(game.players[0].deck.size() + game.players[0].hand.size(), deck.cards.size(), "nothing duplicated or lost")
	assert_eq(game.players[1].hand.size(), game.players[1].opening_hand_size, "the foe draws as usual")
	# The free mulligan deals a normal hand.
	assert_true(game.mulligan(0))
	assert_eq(game.players[0].hand.size(), 5)


func test_the_scavenger_has_no_village_militia() -> void:
	var recipe: Dictionary = TrialOfTheHollow.enemy_recipe("Cave Scavenger")
	assert_false(recipe.has("C-02"), "no 2/2 wall in the first duel")
	assert_true(recipe.has("C-01") and recipe.has("C-04"))
	var map: DungeonMap = TrialOfTheHollow.build_map()
	var first: DungeonMap.MapNode = map.node(1)
	assert_true(first.tutorial)
	assert_eq(first.enemy_hp, 3)
	var spec_found: bool = false
	for spec: EncounterSpec in EncounterCatalog.tutorial():
		if spec.enemy_name == "Cave Scavenger":
			spec_found = true
			assert_true(spec.scripted_hand, "the sim plays the teaching hand too")
	assert_true(spec_found)
