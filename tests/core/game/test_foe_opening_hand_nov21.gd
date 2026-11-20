extends GutTest
## Fable Nov 21 (Part 2.6): every AI opening hand holds at least two Infrastructure (the same hidden, seeded soft mulligan the player's
## hand has had since Nov 7), after the draw and after the AI's own mulligan. The exceptions: the tutorial fights of the Forgotten Cave.
## Captain Spotless (who got stuck with none) and every Arena battle are checked over many seeds.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	CardSet.load_all()


func _infra(hand: Array[CardInstance]) -> int:
	return HandSmoother.count_infrastructure(hand)


## A game whose foe (seat 1) plays a deck with only `infrastructure` Infrastructure in 45 cards, so thin hands are common.
func _thin_game(seed_value: int, infrastructure: int, foe_floor: int = -1) -> GameState:
	var options: GameOptions = GameOptions.new()
	options.rng_seed = seed_value
	options.first_player = 0
	if foe_floor >= 0:
		options.foe_opening_infrastructure_floor = foe_floor
	var game: GameState = GameState.new(options)
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), null, [] as Array[ModifierSource], "You"))
	game.add_player(PlayerSetup.create(GameFactory.make_deck(null, infrastructure), null, [] as Array[ModifierSource], "Foe"))
	game.start()
	return game


func test_the_default_is_two_for_the_foe() -> void:
	assert_eq(GameOptions.new().foe_opening_infrastructure_floor, 2)
	assert_eq(GameOptions.new().clone().foe_opening_infrastructure_floor, 2, "kept by a copy")


func test_every_foe_opening_hand_has_at_least_two_infrastructure() -> void:
	var lowest: int = 99
	for seed_value: int in range(1, 201):
		var game: GameState = _thin_game(seed_value, 9)
		lowest = mini(lowest, _infra(game.players[1].hand))
		assert_eq(game.players[1].hand.size(), game.players[1].opening_hand_size, "a full hand, seed %d" % seed_value)
	assert_gte(lowest, 2, "never fewer than two, over 200 seeds of a deck with 9 Infrastructure in 45")


func test_without_the_floor_thin_hands_do_happen() -> void:
	var thin: int = 0
	for seed_value: int in range(1, 201):
		if _infra(_thin_game(seed_value, 9, 0).players[1].hand) < 2:
			thin += 1
	assert_gt(thin, 0, "the same decks and seeds with the floor off: the rule is what makes the difference")


func test_the_floor_holds_after_the_foes_mulligan() -> void:
	for seed_value: int in range(1, 61):
		var game: GameState = _thin_game(seed_value, 9)
		assert_true(game.keep_hand(0))
		assert_true(game.mulligan(1), "the foe takes its free mulligan")
		assert_gte(_infra(game.players[1].hand), 2, "seed %d: the redrawn hand too" % seed_value)


func test_it_is_seeded_the_same_seed_deals_the_same_hand() -> void:
	for seed_value: int in [3, 17, 44, 91]:
		var first: Array[String] = []
		var second: Array[String] = []
		for card: CardInstance in _thin_game(seed_value, 9).players[1].hand:
			first.append(card.data.id)
		for card: CardInstance in _thin_game(seed_value, 9).players[1].hand:
			second.append(card.data.id)
		assert_eq(first, second, "seed %d" % seed_value)


func test_the_deck_keeps_its_size_and_cards() -> void:
	var game: GameState = _thin_game(7, 9)
	assert_eq(game.players[1].hand.size() + game.players[1].deck.size(), 45, "cards are swapped, never added")


# ---- the exceptions ---------------------------------------------------------------------------------------------------------------------


func test_the_forgotten_caves_fights_are_exempt() -> void:
	var options: GameOptions = GameOptions.new()
	FirstDuel.apply_flood_guard(options)
	assert_eq(options.foe_opening_infrastructure_floor, 0, "every Forgotten Cave fight sets the flood guard, which switches the foe's floor off")
	var practice: BattleContext = Session.make_practice_battle()
	assert_eq(practice.game.options.foe_opening_infrastructure_floor, 0, "a cave foe met as a practice duel")
	var source: String = FileAccess.get_file_as_string("res://app/game_session.gd")
	var cave: int = source.find("enemy = TrialOfTheHollow.enemy_setup(content, node)")
	assert_gt(cave, 0)
	assert_string_contains(source.substr(cave, 200), "FirstDuel.apply_flood_guard(options)", "the cave's own dungeon fights")


func test_the_sim_exempts_the_tutorial_group_as_the_game_does() -> void:
	var source: String = FileAccess.get_file_as_string("res://core/sim/balance_sim.gd")
	assert_string_contains(source, "if encounter.group == \"tutorial\":\n\t\toptions.foe_opening_infrastructure_floor = 0")
	var tutorial: int = 0
	for spec: EncounterSpec in EncounterCatalog.all(Session.content):
		if spec.group == "tutorial":
			tutorial += 1
	assert_gt(tutorial, 0, "the cave's encounters are the tutorial group")


# ---- Captain Spotless and the Arena -----------------------------------------------------------------------------------------------------


func _foe_hands(spec_id: String, games: int) -> Array[int]:
	var counts: Array[int] = []
	for index: int in range(games):
		var context: BattleContext = DevActions.make_encounter_battle(spec_id)
		if context == null:
			return counts
		counts.append(_infra(context.game.players[1].hand))
	return counts


func test_captain_spotless_always_opens_with_two_infrastructure() -> void:
	var found: Array[EncounterSpec] = DevActions.find_encounters("spotless", 5)
	assert_false(found.is_empty(), "Captain Spotless is an encounter")
	if found.is_empty():
		return
	var counts: Array[int] = _foe_hands(found[0].id, 80)
	assert_eq(counts.size(), 80)
	assert_gte(int(counts.min()), 2, "%s over 80 fights: %s" % [found[0].enemy_name, str(counts)])


func test_every_arena_battle_opens_with_two_infrastructure() -> void:
	var checked: int = 0
	for bout: ArenaEncounter in ArenaDefs.all():
		if bout.is_puzzle():
			continue
		checked += 1
		var lowest: int = 99
		for index: int in range(25):
			var context: BattleContext = Session.make_arena_battle(bout.id)
			lowest = mini(lowest, _infra(context.game.players[1].hand))
		assert_gte(lowest, 2, "%s (%s) over 25 fights" % [bout.enemy_name, bout.id])
	assert_gt(checked, 3, "the Arena's battles")


func test_a_normal_fight_has_the_floor_on() -> void:
	var context: BattleContext = DevActions.make_encounter_battle("town:roamer:hound")
	assert_not_null(context)
	assert_eq(context.game.options.foe_opening_infrastructure_floor, 2)
