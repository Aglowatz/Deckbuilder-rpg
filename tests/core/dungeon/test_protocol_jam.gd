extends GutTest
## Oct 21: Siphon's Boss Protocols and Elowen's Inside Knowledge / Sabotage (ProtocolJam), the parking of modifiers (ModifierSet.park) and the
## two new modifier kinds (FIRST_CARD_COST_CHANGE, START_OF_TURN_RESOURCES).

var _context: BattleContext


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.NECROCRAT)
	DungeonCatalog.reset()
	MainDungeons.reset()
	Session.profile.intro_dungeon_cleared = true
	Session.dungeon_key = PathologyLab.DUNGEON_ID
	Session.dungeon_map = MainDungeons.build_map(PathologyLab.DUNGEON_ID)
	Session.mini_active = true
	Session.town_side_active = true
	Session.run = DungeonRun.enter(Session.profile, Session.deck, [PathologyLab.rescuer_boon()] as Array[ModifierSource])
	_context = Session.make_dungeon_battle(Session.dungeon_map.boss())


func after_each() -> void:
	Session.mini_active = false
	Session.town_side_active = false


func _labels(set: ModifierSet) -> Array[String]:
	var result: Array[String] = []
	for modifier: Modifier in set.modifiers:
		if not result.has(modifier.label):
			result.append(modifier.label)
	return result


func test_parking_takes_a_labelled_rule_out_and_puts_it_back() -> void:
	var set: ModifierSet = ModifierSet.new()
	var a: Modifier = CardBuilder.modifier(Modifier.Kind.STAT_CHANGE, 2, Modifier.ANY_COLOR, 2)
	a.label = "Augmentation"
	var b: Modifier = CardBuilder.modifier(Modifier.Kind.EXTRA_DRAWS, 1)
	b.label = "Other"
	set.add(a)
	set.add(b)
	assert_eq(set.park("Augmentation"), 1)
	assert_eq(set.stat_bonus(Affinity.Type.NEUTRAL), Vector2i.ZERO, "a parked rule does nothing")
	assert_eq(set.sum(Modifier.Kind.EXTRA_DRAWS), 1)
	set.unpark_all()
	assert_eq(set.stat_bonus(Affinity.Type.NEUTRAL), Vector2i(2, 2))
	assert_true(set.parked.is_empty())


func test_the_four_protocols_are_on_the_right_seats() -> void:
	var game: GameState = _context.game
	var enemy: Array[String] = _labels(game.players[1].modifiers)
	enemy.append_array(_labels_parked(game.players[1].modifiers))
	for label: String in ["Augmentation", "Replication", "Extraction"]:
		assert_true(enemy.has(label), "%s is Siphon's" % label)
	var player: Array[String] = _labels(game.players[0].modifiers)
	player.append_array(_labels_parked(game.players[0].modifiers))
	assert_true(player.has("Containment"), "Containment sits on your seat")


func _labels_parked(set: ModifierSet) -> Array[String]:
	var result: Array[String] = []
	for modifier: Modifier in set.parked:
		result.append(modifier.label)
	return result


func test_elowen_jams_one_protocol_on_your_turn_and_you_can_switch_it() -> void:
	var game: GameState = _context.game
	# Start of the player's own turn: Elowen picks (or the jam carries from the first turn).
	ProtocolJam.on_turn_start(game, 0)
	assert_false(game.jammed_label.is_empty(), "something is jammed")
	assert_eq(game.jam_player, 0)
	game.active = 0
	assert_true(ProtocolJam.request(game, 0, "Containment") or game.jammed_label == "Containment")
	assert_eq(game.jammed_label, "Containment")
	var card: CardData = Session.card_by_id("N-02")
	var cheap: int = game.generic_cost_for(0, card)
	assert_true(ProtocolJam.request(game, 0, "Augmentation"))
	assert_eq(game.generic_cost_for(0, card), cheap + 1, "Containment is back: your first card each turn costs 1 more")
	assert_eq(_labels_parked(game.players[1].modifiers).count("Augmentation"), 1, "Augmentation is off")
	# The jam ends at the start of your next turn and a new one is chosen.
	game.jam_request = ""
	ProtocolJam.on_turn_start(game, 0)
	assert_eq(game.jam_player, 0)


func test_the_pick_follows_the_board() -> void:
	var game: GameState = _context.game
	var options: Array[String] = ["Augmentation", "Replication", "Extraction", "Containment"]
	assert_eq(ProtocolJam.pick(game, 0, options), "Replication", "an empty board: stop the next Failed Experiment")
	for i: int in range(2):
		game.create_token(1, TokenRegistry.data("T-25"))
	assert_eq(ProtocolJam.pick(game, 0, options), "Augmentation", "two of his units out: take away their +2/+2")


func test_sabotage_failed_experiments_enter_exhausted_against_elowen() -> void:
	var game: GameState = _context.game
	var token: CardInstance = game.create_token(1, TokenRegistry.data(ProtocolJam.EXPERIMENT_TOKEN_ID))
	assert_true(token.exhausted, "Sabotage")
	var own: CardInstance = game.create_token(0, TokenRegistry.data(ProtocolJam.EXPERIMENT_TOKEN_ID))
	assert_false(own.exhausted, "only the opponent's")


func test_a_lookahead_copy_never_parks_the_real_game() -> void:
	var game: GameState = _context.game
	ProtocolJam._release(game)
	var before: int = game.players[1].modifiers.modifiers.size()
	var copy: GameState = game.clone()
	ProtocolJam.on_turn_start(copy, 0)
	assert_false(copy.jammed_label.is_empty())
	assert_eq(game.players[1].modifiers.modifiers.size(), before, "the real modifier set is untouched")
	assert_true(game.jammed_label.is_empty())


func test_extraction_drains_a_life_at_the_start_of_his_turn() -> void:
	var game: GameState = _context.game
	ProtocolJam._release(game)
	game.script_runs.clear()  # Oct 23: at 10 HP his scripted drain (EncounterScripts) would fire too; this test is about the Protocol alone
	game.players[1].hp = 10
	var yours: int = game.players[0].hp
	game._fire_start_of_turn_effects(1)
	assert_eq(game.players[0].hp, yours - 1, "you lose 1 life")
	assert_eq(game.players[1].hp, 11, "he gains 1")
	assert_eq(game.players[0].modifiers.sum(Modifier.Kind.START_OF_TURN_RESOURCES) + game.players[1].modifiers.sum(Modifier.Kind.START_OF_TURN_RESOURCES), 0, "no Resources since the Oct 21 tuning")


func test_start_of_turn_resources_are_created() -> void:
	var game: GameState = _context.game
	var modifier: Modifier = CardBuilder.modifier(Modifier.Kind.START_OF_TURN_RESOURCES, 1, Modifier.ANY_COLOR, ResourceKind.Kind.IRON)
	game.players[1].modifiers.add(modifier)
	var before: int = game.players[1].count_resource(ResourceKind.Kind.IRON)
	game._fire_start_of_turn_effects(1)
	assert_eq(game.players[1].count_resource(ResourceKind.Kind.IRON), before + 1)
