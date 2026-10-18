extends GutTest
## Rebalance Part E: one-sided encounter rules (EncounterModifiers) - the data loads cleanly, every kind becomes a working
## modifier on the right seat, the timed summon fires on schedule, the enemy setups carry the rules and the sim's catalog sees them.

var content: ContentSet


func before_all() -> void:
	content = ContentLibrary.load_all()


func before_each() -> void:
	EncounterModifiers.reset()


func test_the_data_loads_with_no_problems_and_every_rule_is_described() -> void:
	assert_gt(EncounterModifiers.keys().size(), 10, "a good number of encounters carry rules")
	assert_eq(EncounterModifiers.problems(), [] as Array[String], "no unknown kinds, tokens or keywords")
	for key: String in EncounterModifiers.keys():
		for rule: EncounterModifiers.Rule in EncounterModifiers.rules(key):
			assert_false(rule.name.is_empty(), "%s: a rule has a name" % key)
			assert_false(rule.text.is_empty(), "%s: %s has a text" % [key, rule.name])
			assert_false(rule.modifiers.is_empty(), "%s: %s has modifiers" % [key, rule.name])
			assert_true(rule.tooltip().contains("Applies to"), "the tooltip says which side")


func test_rules_land_on_the_right_seat_only() -> void:
	var enemy_rule: EncounterModifiers.Rule = EncounterModifiers.build_rule({"name": "Big", "text": "+1/+1", "kind": "stat", "atk": 1, "def": 1})
	var player_rule: EncounterModifiers.Rule = EncounterModifiers.build_rule({"name": "Slow", "text": "exhausted", "kind": "enter_exhausted", "side": "player"})
	var game: GameState = GameFactory.new_game(3)
	game.players[1].modifiers.add_source(_source([enemy_rule]))
	game.players[0].modifiers.add_source(_source([player_rule]))
	var mine: CardInstance = GameFactory.add_to_field(game, 0, GameFactory.vanilla(2, 2))
	var theirs: CardInstance = GameFactory.add_to_field(game, 1, GameFactory.vanilla(2, 2))
	assert_eq(game.get_attack(mine), 2, "the enemy's buff is not mine")
	assert_eq(game.get_attack(theirs), 3, "the enemy's units get +1 attack")
	assert_eq(game.get_defense(theirs), 3)
	var card: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.vanilla(1, 1, 1))
	GameFactory.add_infrastructure_cards(game, 0, 1)
	assert_true(game.play_card(0, card.uid))
	assert_true(card.exhausted, "the player-side rule applies to the player's units")


func test_starting_tokens_and_resources_appear_at_the_start_of_the_duel() -> void:
	var tokens: EncounterModifiers.Rule = EncounterModifiers.build_rule({"name": "Guard", "text": "two Militia", "kind": "starting_tokens", "token": "T-16", "count": 2})
	var iron: EncounterModifiers.Rule = EncounterModifiers.build_rule({"name": "Iron", "text": "3 Iron", "kind": "starting_resources", "resource": "iron", "count": 3})
	assert_not_null(tokens)
	assert_not_null(iron)
	var game: GameState = GameState.new(GameOptions.new())
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), null, [] as Array[ModifierSource], "P0"))
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), null, [_source([tokens, iron])] as Array[ModifierSource], "P1"))
	game.start()
	while game.stage == GameState.Stage.MULLIGAN:
		game.keep_hand(game.awaiting_player())
	assert_eq(game.players[1].units().size(), 2, "two Militia on the enemy's field")
	assert_eq(game.players[0].units().size(), 0)
	assert_eq(game.resource_count(1, ResourceKind.Kind.IRON), 3)


func test_a_timed_summon_fires_every_nth_own_turn() -> void:
	var rule: EncounterModifiers.Rule = EncounterModifiers.build_rule({"name": "Reinforcements", "text": "every 2nd turn", "kind": "timed_summon", "token": "T-21", "every": 2})
	var game: GameState = GameFactory.new_game(5)
	game.players[1].modifiers.add_source(_source([rule]))
	assert_eq(game.players[1].units().size(), 0)
	GameFactory.pass_turn(game)  # P1's first turn
	assert_eq(game.players[1].turns_taken, 1)
	assert_eq(game.players[1].units().size(), 0, "not on its first turn")
	GameFactory.pass_turn(game)  # P0
	GameFactory.pass_turn(game)  # P1's second turn
	assert_eq(game.players[1].turns_taken, 2)
	assert_eq(game.players[1].units().size(), 1, "a Patchwork Body on its second turn")
	assert_eq(game.players[1].units()[0].data.id, "T-21")
	GameFactory.pass_turn(game)
	GameFactory.pass_turn(game)  # P1's third turn
	assert_eq(game.players[1].units().size(), 1, "nothing on the third")
	GameFactory.pass_turn(game)
	GameFactory.pass_turn(game)  # fourth
	assert_eq(game.players[1].units().size(), 2, "another on the fourth")
	assert_eq(game.players[0].units().size(), 0, "never for the player")


func test_dungeon_and_zone_enemy_setups_carry_their_rules() -> void:
	var key: String = "beefcake"
	var map: DungeonMap = MainDungeons.build_map(key)
	var boss: DungeonMap.MapNode = null
	for node: DungeonMap.MapNode in map.nodes:
		if node.kind == DungeonMap.Kind.BOSS:
			boss = node
	assert_not_null(boss)
	assert_true(EncounterModifiers.has_rules(boss.enemy_name), "Clench has rules")
	var setup: PlayerSetup = MainDungeons.enemy_setup(content, boss, key)
	assert_true(setup.modifiers.has(Modifier.Kind.STARTING_RESOURCES), "the boss seat starts with Iron")
	assert_true(setup.modifiers.has(Modifier.Kind.TIMED_SUMMON), "and reinforcements")
	var spotless: PlayerSetup = ZoneEnemies.enemy_setup(content, "final", "spotless")
	assert_true(spotless.modifiers.has(Modifier.Kind.STAT_CHANGE), "a zone gate fight carries its rule")
	var brute: PlayerSetup = ZoneEnemies.enemy_setup(content, "beefcake", "brute")
	assert_false(brute.modifiers.has(Modifier.Kind.STAT_CHANGE), "a plain roamer has none")


func test_the_sim_catalog_sees_the_same_rules() -> void:
	var spec: EncounterSpec = EncounterCatalog.find(content, "zone:final:spotless")
	assert_not_null(spec)
	assert_eq(spec.enemy_sources.size(), 1, "the catalog carries the enemy-side source")
	var clench: EncounterSpec = null
	for candidate: EncounterSpec in EncounterCatalog.all(content):
		if candidate.enemy_name == "Chancellor Clench, Iron Regent":
			clench = candidate
	assert_not_null(clench)
	var seat: PlayerSetup = clench.build_enemy(content, null)
	assert_true(seat.modifiers.has(Modifier.Kind.TIMED_SUMMON))


func test_unknown_kinds_are_reported_not_crashed() -> void:
	assert_null(EncounterModifiers.build_rule({"name": "X", "text": "x", "kind": "nope"}, "test"))
	assert_true(EncounterModifiers.problems().size() >= 1)


func _source(rules: Array[EncounterModifiers.Rule]) -> ModifierSource:
	var made: ModifierSource = ModifierSource.new()
	made.source_name = "test rules"
	made.source_kind = ModifierSource.SourceKind.DUNGEON
	for rule: EncounterModifiers.Rule in rules:
		made.modifiers.append_array(rule.modifiers)
	return made
