extends GutTest
## Nov 25 night (Part C): postgame and draft opponents hold at least 8 cards when their first turn begins, in a
## sensible mix of Infrastructure and plays, and the game wires it in for postgame dungeons, dungeon drafts, table drafts and the vault.

const HANDS = preload("res://core/game/opponent_hands.gd")


func _content() -> ContentSet:
	return Session.content if Session.content != null else ContentLibrary.load_all()


## The foe's hand when its first turn begins: it goes first, so nothing is drawn or played before (the opening hand after every
## start-of-duel effect); a hand that should be bigger than the deck allows is reported.
func _first_turn_hand(enemy: PlayerSetup, seed_value: int) -> Array[CardInstance]:
	var options: GameOptions = GameOptions.new()
	options.rng_seed = seed_value
	options.first_player = 1
	options.free_mulligan = false
	HANDS.apply_options(options)
	var game: GameState = GameState.new(options)
	game.add_player(PlayerSetup.create(enemy.deck, null, [] as Array[ModifierSource], "You"))
	game.add_player(enemy)
	game.start()
	return game.players[1].hand


func _postgame_keys() -> Array[String]:
	var keys: Array[String] = []
	for blueprint: DungeonCatalog.Blueprint in DungeonCatalog.all():
		if HANDS.is_postgame_dungeon(blueprint.id) and MainDungeons.has_def(blueprint.id):
			keys.append(blueprint.id)
	return keys


func test_the_postgame_dungeons_are_the_owners() -> void:
	var keys: Array[String] = _postgame_keys()
	for key: String in ["D-LAB", "S-GALLERY", "S-BEEF"]:
		assert_true(keys.has(key), "%s counts as postgame" % key)
	assert_false(HANDS.is_postgame_dungeon("D-HOG"), "a zone's main dungeon does not")


func test_every_postgame_foe_opens_with_a_full_hand_of_a_sensible_mix() -> void:
	var content: ContentSet = _content()
	var checked: int = 0
	for key: String in _postgame_keys():
		var map: DungeonMap = MainDungeons.build_map(key)
		for node: DungeonMap.MapNode in map.nodes:
			if not DungeonMap.is_battle_kind(node.kind) or node.enemy_name.is_empty():
				continue
			var boss: bool = node.kind == DungeonMap.Kind.BOSS
			for seed_value: int in [11, 12, 13]:
				var setup: PlayerSetup = MainDungeons.enemy_setup(content, node, key)
				var rules: ModifierSource = DungeonRules.enemy_source(key, node.number)
				if rules != null:
					setup.modifiers.add_source(rules)
				HANDS.apply(setup, boss)
				var hand: Array[CardInstance] = _first_turn_hand(setup, seed_value)
				var where: String = "%s %s (node %d, seed %d)" % [key, node.enemy_name, node.number, seed_value]
				assert_gte(hand.size(), HANDS.opening_size(boss), "%s holds %d" % [where, hand.size()])
				var infra: int = HandSmoother.count_infrastructure(hand)
				assert_gte(infra, mini(HANDS.INFRA_FLOOR, setup.deck.infrastructure_count()), "%s has Infrastructure to play" % where)
				assert_gte(hand.size() - infra, HANDS.PLAY_FLOOR, "%s has things to do" % where)
			checked += 1
	assert_gt(checked, 15, "postgame foes checked: %d" % checked)


func test_mount_swolympus_and_the_lab_no_longer_start_on_five() -> void:
	var content: ContentSet = _content()
	for key: String in ["S-BEEF", "D-LAB"]:
		var map: DungeonMap = MainDungeons.build_map(key)
		var plain: PlayerSetup = MainDungeons.enemy_setup(content, map.boss(), key)
		assert_eq(plain.profile.base_opening_hand(), 5, "%s's boss alone would start on 5" % key)
		HANDS.apply(plain, true)
		assert_gte(_first_turn_hand(plain, 3).size(), HANDS.opening_size(true), "%s's boss opens with a full hand" % key)
		for node: DungeonMap.MapNode in map.nodes:
			if DungeonMap.is_battle_kind(node.kind) and node.kind != DungeonMap.Kind.BOSS and not node.enemy_name.is_empty():
				var foe: PlayerSetup = MainDungeons.enemy_setup(content, node, key)
				HANDS.apply(foe, false)
				assert_gte(_first_turn_hand(foe, 4).size(), 8, "%s: %s" % [key, node.enemy_name])


func test_every_draft_rival_opens_with_a_full_hand() -> void:
	var content: ContentSet = _content()
	var checked: int = 0
	for challenge: String in ["open", "high"]:
		var state: DraftState = DraftEngine.start(content, challenge, [int(Affinity.Type.BEEFCAKE), int(Affinity.Type.GOURMAND)] as Array[int], 14, 4242, true, false)
		DraftEngine.auto_deck(content, state)
		for rival: Dictionary in DraftRivals.build_all(content, state):
			var setup: PlayerSetup = DraftRun.enemy_setup(content, rival)
			var boss: bool = bool(rival.get("boss", false))
			# a rival whose own drafted gear spends a card as its turn begins (a start-of-turn effect) held the full hand when the turn began
			var spends: int = 1 if setup.modifiers.has(Modifier.Kind.START_OF_TURN_EFFECT) else 0
			var hand: Array[CardInstance] = _first_turn_hand(setup, 77)
			assert_gte(hand.size(), HANDS.opening_size(boss) - spends, "%s at the %s table holds %d" % [str(rival.get("name", "?")), challenge, hand.size()])
			checked += 1
	assert_gte(checked, 4, "rivals checked: %d" % checked)


func test_the_game_applies_it_where_the_owner_asked() -> void:
	var session: String = FileAccess.get_file_as_string("res://app/game_session.gd")
	assert_true(session.contains("OPPONENT_HANDS.apply(enemy, node.kind == DungeonMap.Kind.BOSS)"), "postgame dungeons and dungeon drafts")
	assert_true(session.contains("OPPONENT_HANDS.apply(warden, true)"), "the vault's Warden")
	var run: String = FileAccess.get_file_as_string("res://core/draft/draft_run.gd")
	assert_true(run.contains("OPPONENT_HANDS.apply(setup"), "table drafts")
	assert_true(run.contains("OPPONENT_HANDS.apply_options(options)"))


func test_a_flooded_hand_swaps_infrastructure_for_plays() -> void:
	var game: GameState = GameState.new()
	var hand: Array[CardInstance] = []
	var deck: Array[CardInstance] = []
	var basic: CardData = GameFactory.infra(Affinity.Type.BEEFCAKE)
	for index: int in range(8):
		hand.append(game.create_instance(basic, 1))
	for index: int in range(10):
		deck.append(game.create_instance(GameFactory.vanilla(2, 2), 1))
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 5
	assert_eq(HandSmoother.ensure_plays(hand, deck, 4, rng), 4)
	assert_eq(HandSmoother.count_infrastructure(hand), 4)
	assert_eq(hand.size(), 8)


func test_a_foe_going_second_is_dealt_seven_and_holds_eight_after_its_draw() -> void:
	var content: ContentSet = _content()
	var map: DungeonMap = MainDungeons.build_map("S-BEEF")
	var setup: PlayerSetup = MainDungeons.enemy_setup(content, map.boss(), "S-BEEF")
	HANDS.apply(setup, true)
	var options: GameOptions = GameOptions.new()
	options.rng_seed = 9
	options.first_player = 0
	options.free_mulligan = false
	HANDS.apply_options(options)
	var game: GameState = GameState.new(options)
	game.add_player(PlayerSetup.create(setup.deck, null, [] as Array[ModifierSource], "You"))
	game.add_player(setup)
	game.start()
	var extra: int = maxi(0, game.players[1].modifiers.sum(Modifier.Kind.EXTRA_DRAWS))
	assert_eq(game.players[1].hand.size(), HANDS.MIN_HAND - 1 - extra, "dealt one short: its turn begins with a draw")
	GameFactory.pass_turn(game)
	assert_gte(game.players[1].hand.size(), HANDS.MIN_HAND, "8 when its first turn begins")
