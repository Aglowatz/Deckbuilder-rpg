extends GutTest
## Fix pass Nov 4, Part 1: Fresh Stitches (the rename, and boss units that start on the table), the Endless Buffet's Well Fed (+0/+1,
## exactly once per Gourmand unit in every Buffet fight, on both seats - it is a zone-wide rule) and the blockers that step aside from the
## "defeated" flag.

const OLD_NAME: String = "summoning" + " sick"  # split so this file is not itself a hit


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.GOURMAND)


# ---- Fresh Stitches ----------------------------------------------------------------------------------------------


func test_the_old_name_is_gone_from_player_facing_text() -> void:
	for path: String in ["res://ui/card/keyword_info.gd", "res://ui/screens/glossary_panel.gd", "res://ui/battle/battle_hud.gd", "res://data/loading/loading_tips.txt"]:
		var text: String = FileAccess.get_file_as_string(path).to_lower()
		assert_false(text.contains(OLD_NAME), "%s still says the old name" % path)
	assert_true(KeywordInfo.GLOSSARY.has("Fresh Stitches"))
	assert_eq(KeywordInfo.FRESH_STITCHES_REMINDER, "Fresh Stitches: can't attack the turn it enters play.")


func _casserole_game(first_player: int) -> GameState:
	CardSet.load_all()
	var options: GameOptions = GameOptions.new()
	options.rng_seed = 7
	options.first_player = first_player
	var game: GameState = GameState.new(options)
	var zone: ModifierSource = ZoneEffects.source_for(BuffetZone.ID)
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), null, [zone] as Array[ModifierSource], "You"))
	var enemy: PlayerSetup = ZoneEnemies.enemy_setup(Session.content, BuffetZone.ID, "casserole")
	enemy.modifiers.add_source(zone)
	game.add_player(enemy)
	game.start()
	while game.stage == GameState.Stage.MULLIGAN:
		game.keep_hand(game.awaiting_player())
	return game


func _enemy_units(game: GameState) -> Array[CardInstance]:
	var units: Array[CardInstance] = []
	for card: CardInstance in game.players[1].field:
		if card.data.is_unit():
			units.append(card)
	return units


func test_the_colonels_starting_weenie_has_fresh_stitches_on_his_first_turn() -> void:
	for first: int in [0, 1]:
		var game: GameState = _casserole_game(first)
		if game.active == 0:
			GameFactory.pass_turn(game)
		assert_eq(game.active, 1)
		assert_eq(game.players[1].turns_taken, 1, "the Colonel's first turn (he went %s)" % ("first" if first == 1 else "second"))
		var units: Array[CardInstance] = _enemy_units(game)
		assert_eq(units.size(), 1, "the Sashimi Weenie starts on the table")
		assert_true(units[0].fresh_stitches, "Fresh Stitches on his first turn, as if just played")
		assert_true(game.possible_attackers(1).is_empty(), "it can't attack yet")
		GameFactory.pass_turn(game)
		GameFactory.pass_turn(game)
		assert_eq(game.active, 1)
		assert_false(_enemy_units(game)[0].fresh_stitches, "ready on his second turn")


func test_every_encounter_with_preplaced_units_gives_them_fresh_stitches() -> void:
	# The starting_tokens rules in data/encounters/modifiers.json: build each foe's seat and start a duel.
	var keys: Array[String] = ["Trophy Hall Honor Guard", "The Doppelganger", "Royal Staircase Guard", "zone:gourmand:casserole", "Primm (standardization)"]
	for key: String in keys:
		var options: GameOptions = GameOptions.new()
		options.rng_seed = 3
		options.first_player = 0
		var game: GameState = GameState.new(options)
		game.add_player(PlayerSetup.create(GameFactory.make_deck(), null, [] as Array[ModifierSource], "You"))
		var enemy: PlayerSetup = PlayerSetup.create(GameFactory.make_deck(), null, [] as Array[ModifierSource], key)
		EncounterModifiers.apply_to_enemy(enemy, key)
		game.add_player(enemy)
		game.start()
		while game.stage == GameState.Stage.MULLIGAN:
			game.keep_hand(game.awaiting_player())
		GameFactory.pass_turn(game)
		assert_eq(game.active, 1, key)
		assert_false(_enemy_units(game).is_empty(), "%s starts with units" % key)
		for unit: CardInstance in _enemy_units(game):
			assert_true(unit.fresh_stitches, "%s: %s has Fresh Stitches on the foe's first turn" % [key, unit.data.display_name])


func test_arena_preset_enemy_units_have_fresh_stitches_and_yours_are_ready() -> void:
	var game: GameState = GameFactory.blank_game(5)
	var content: ContentSet = Session.content
	ArenaScenario.apply_preset(game, content, {"player": {"field": {"B-11": 1}}, "enemy": {"field": {"C-02": 1}}})
	assert_false(game.players[0].field[0].fresh_stitches, "your preset unit is ready")
	assert_true(game.players[1].field[0].fresh_stitches)
	assert_true(game.players[1].field[0].placed_before_duel)


func test_a_dungeon_ally_made_ready_stays_ready() -> void:
	var game: GameState = _casserole_game(0)
	var ally: CardInstance = game.create_token(0, TokenRegistry.data("T-03"))
	ally.fresh_stitches = false
	game.mark_placed_before_duel()
	assert_false(ally.placed_before_duel, "a unit made ready on purpose is left alone")


# ---- Well Fed ---------------------------------------------------------------------------------------------------


func _well_fed_count(modifiers: ModifierSet) -> int:
	var count: int = 0
	for modifier: Modifier in modifiers.modifiers:
		if modifier.label == "Well Fed":
			count += 1
	return count


func test_well_fed_is_plus_0_plus_1_and_says_so() -> void:
	var effect: ZoneEffects.Effect = ZoneEffects.for_zone(BuffetZone.ID)
	assert_eq(effect.buff.value, 0)
	assert_eq(effect.buff.value2, 1)
	assert_eq(effect.buff_mechanic(), "Gourmand units get +1 defense.")
	assert_true(effect.tooltip().contains("+1 defense"))
	assert_false(effect.tooltip().contains("+1 attack"))


func test_the_colonels_units_get_well_fed_once_and_nothing_else() -> void:
	var game: GameState = _casserole_game(0)
	for index: int in [0, 1]:
		assert_eq(_well_fed_count(game.players[index].modifiers), 1, "seat %d has Well Fed once" % index)
		var gourmand: CardData = GameFactory.vanilla(2, 2, 1, Affinity.Type.GOURMAND)
		assert_eq(game.players[index].modifiers.stat_bonus_for(gourmand), Vector2i(0, 1), "seat %d: a Gourmand unit gets +0/+1 in total" % index)
	var weenie: CardInstance = _enemy_units(game)[0]
	assert_eq(game.get_attack(weenie), weenie.data.attack, "the Weenie's attack is printed")
	assert_eq(game.get_defense(weenie), weenie.data.defense + 1, "and +1 defense from Well Fed")


func test_the_real_casserole_battle_applies_well_fed_once_per_side() -> void:
	Session.begin_zone_visit(BuffetZone.ID)
	var context: BattleContext = Session.make_zone_battle("casserole", BuffetGates.INSTANCE_BATTLE)
	for index: int in [0, 1]:
		assert_eq(_well_fed_count(context.game.players[index].modifiers), 1, "seat %d" % index)
	Session.zone_run = null


func test_every_buffet_fight_applies_well_fed_exactly_once_on_each_seat() -> void:
	var checked: int = 0
	for spec: EncounterSpec in EncounterCatalog.all(Session.content):
		if spec.zone_id != BuffetZone.ID:
			continue
		var shared: ModifierSource = spec.shared_source()
		var sources: Array[ModifierSource] = []
		if shared != null:
			sources.append(shared)
		var player: PlayerSetup = PlayerSetup.create(GameFactory.make_deck(), null, sources, "You")
		var enemy: PlayerSetup = spec.build_enemy(Session.content, GameFactory.make_deck())
		if shared != null:
			enemy.modifiers.add_source(shared)
		assert_eq(_well_fed_count(player.modifiers), 1, "%s: your seat" % spec.id)
		assert_eq(_well_fed_count(enemy.modifiers), 1, "%s: the foe's seat" % spec.id)
		checked += 1
	assert_gt(checked, 4, "the Buffet's roamers, the Colonel and the Test Kitchen's nodes were checked")


# ---- Blockers step aside from the flag ------------------------------------------------------------------------------


func test_beating_the_colonel_sets_the_gate_flag_at_once() -> void:
	Session.begin_zone_visit(BuffetZone.ID)
	var context: BattleContext = Session.make_zone_battle("casserole", BuffetGates.INSTANCE_BATTLE)
	context.game._end_game(0, false)  # the dev win ends the duel this same way
	context.won = true
	var seen: Array[StringName] = []
	var listener: Callable = func(name: StringName) -> void: seen.append(name)
	EventBus.flag_set.connect(listener)
	Session.resolve_zone_battle(context)
	EventBus.flag_set.disconnect(listener)
	assert_true(Session.flag(BuffetZone.FLAG_GATE_BATTLE), "the gate's flag is set by the win itself")
	assert_true(seen.has(BuffetZone.FLAG_GATE_BATTLE), "and announced, so a shown scene moves the golem")
	Session.zone_run = null


func test_every_blocker_flag_is_known() -> void:
	assert_eq(BossBlockers.flag_for(BuffetZone.ID, BuffetGates.INSTANCE_BATTLE), BuffetZone.FLAG_GATE_BATTLE)
	assert_eq(BossBlockers.flag_for(CapitalZone.ID, CapitalEnemies.SPOTLESS), CapitalZone.FLAG_GATE_OPEN)
	assert_eq(BossBlockers.flag_for(BuffetZone.ID, "loaf_1"), &"")
	for path: String in ["res://world/buffet/buffet_scene.gd", "res://world/capital/capital_scene.gd"]:
		assert_true(FileAccess.get_file_as_string(path).contains("func sync_world_flags"), "%s moves its blocker from the flag" % path)
	assert_true(FileAccess.get_file_as_string("res://world/zone/zone_scene.gd").contains("sync_world_flags()"), "the parked-scene return syncs flags")
