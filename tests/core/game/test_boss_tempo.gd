extends GutTest
## Fable pass Nov 1, Part 2 (boss tempo): the setup window (a boss's units do not attack during its first N turns, `BossTempo` /
## `Modifier.Kind.SETUP_TURNS`), every boss carrying one by data, and Compostella's Wild Growth capped at 3 buffs per unit.


func before_each() -> void:
	EncounterModifiers.reset()


func after_all() -> void:
	EncounterModifiers.reset()


func _token(attack: int, defense: int, id_suffix: String) -> CardData:
	return CardBuilder.token("stage_%s" % id_suffix, "Stage %s" % id_suffix, attack, defense)


func _escalating(stages: Array[CardData]) -> Modifier:
	var modifier: Modifier = Modifier.new()
	modifier.kind = Modifier.Kind.SCRIPTED_ESCALATING_SUMMON
	modifier.tokens = stages
	return modifier


## P0 (the player) vs P1 (the boss) with `p1_mods` on the boss's seat; P0 goes first.
func _game(p1_mods: Array[Modifier], p0_mods: Array[Modifier] = []) -> GameState:
	var options: GameOptions = GameOptions.new()
	options.rng_seed = 1
	options.first_player = 0
	var game: GameState = GameState.new(options)
	var hero_sources: Array[ModifierSource] = []
	if not p0_mods.is_empty():
		hero_sources.append(CardBuilder.modifier_source("Hero rules", ModifierSource.SourceKind.DUNGEON, p0_mods))
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), null, hero_sources, "P0"))
	var source: ModifierSource = CardBuilder.modifier_source("Boss rules", ModifierSource.SourceKind.DUNGEON, p1_mods)
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), null, [source] as Array[ModifierSource], "P1"))
	game.start()
	while game.stage == GameState.Stage.MULLIGAN:
		game.keep_hand(game.awaiting_player())
	return game


func test_a_boss_in_its_setup_window_has_no_attackers_then_attacks() -> void:
	var stage0: CardData = _token(2, 2, "0")
	var mods: Array[Modifier] = [CardBuilder.modifier(Modifier.Kind.SETUP_TURNS, 2), _escalating([stage0, stage0, stage0] as Array[CardData])]
	var game: GameState = _game(mods)
	assert_eq(game.setup_turns_left(1), 3, "before its first turn: 2 turns to come, counted from turn 1")
	assert_eq(game.setup_turns_left(0), 0, "the hero has no window")
	GameFactory.pass_turn(game)  # the boss's turn 1: a token arrives (Just Arrived anyway)
	assert_eq(game.active, 1)
	assert_eq(game.setup_turns_left(1), 2)
	assert_true(game.possible_attackers(1).is_empty())
	GameFactory.pass_turn(game)  # the hero
	GameFactory.pass_turn(game)  # the boss's turn 2: the first token is ready, but the window holds it
	assert_eq(game.active, 1)
	assert_eq(game.setup_turns_left(1), 1)
	assert_eq(game.players[1].field.size(), 2)
	assert_true(game.possible_attackers(1).is_empty(), "turn 2 of 2: still setting up")
	GameFactory.pass_turn(game)  # the hero
	GameFactory.pass_turn(game)  # the boss's turn 3: free
	assert_eq(game.active, 1)
	assert_eq(game.setup_turns_left(1), 0)
	assert_eq(game.possible_attackers(1).size(), 2, "the two ready tokens attack from turn 3")


func test_without_the_modifier_nothing_changes() -> void:
	var stage0: CardData = _token(2, 2, "0")
	var game: GameState = _game([_escalating([stage0, stage0] as Array[CardData])])
	GameFactory.pass_turn(game)
	GameFactory.pass_turn(game)
	GameFactory.pass_turn(game)
	assert_eq(game.active, 1)
	assert_eq(game.possible_attackers(1).size(), 1)


func test_the_setup_rule_is_data_and_idempotent() -> void:
	assert_eq(EncounterModifiers.setup_turns("Test Boss Nov 1"), 0)
	EncounterModifiers.ensure_setup_rule("Test Boss Nov 1", 2)
	EncounterModifiers.ensure_setup_rule("Test Boss Nov 1", 5)
	assert_eq(EncounterModifiers.setup_turns("Test Boss Nov 1"), 2, "the first call wins")
	var names: PackedStringArray = []
	for rule: EncounterModifiers.Rule in EncounterModifiers.rules("Test Boss Nov 1"):
		names.append(rule.name)
	assert_eq(names, PackedStringArray([BossTempo.RULE_NAME]), "one Setting Up badge")
	assert_true(EncounterModifiers.enemy_source("Test Boss Nov 1").modifiers[0].kind == Modifier.Kind.SETUP_TURNS)
	EncounterModifiers.ensure_setup_rule("No Window Boss", 0)
	assert_eq(EncounterModifiers.setup_turns("No Window Boss"), 0, "0 turns adds nothing")
	assert_true(BossTempo.rule_text(2).contains("first 2 turns"))
	assert_eq(BossTempo.turns_of({}), BossTempo.DEFAULT_SETUP_TURNS)
	assert_eq(BossTempo.turns_of({"setup_turns": 0}), 0)
	assert_eq(BossTempo.turns_of({"setup_turns": 3}), 3)


func test_every_dungeon_boss_and_primms_phases_open_with_a_setup_window() -> void:
	var content: ContentSet = ContentLibrary.load_all()
	var checked: int = 0
	for blueprint: DungeonCatalog.Blueprint in DungeonCatalog.all():
		if blueprint.type == DungeonCatalog.TYPE_TUTORIAL:
			continue
		var key: String = blueprint.id if (blueprint.is_side() or blueprint.is_postgame()) else blueprint.zone_id
		if not MainDungeons.has_def(key):
			continue
		var map: DungeonMap = MainDungeons.build_map(key)
		if map == null or map.boss() == null:
			continue
		var boss_name: String = map.boss().enemy_name
		if boss_name == PrimmBoss.BOSS_FOE:
			continue
		assert_gt(EncounterModifiers.setup_turns(boss_name), 0, "%s (%s) opens with a setup window" % [boss_name, blueprint.id])
		var setup: PlayerSetup = MainDungeons.enemy_setup(content, map.boss(), key)
		assert_true(setup.modifiers.has(Modifier.Kind.SETUP_TURNS), "%s's seat carries the modifier" % boss_name)
		checked += 1
	assert_gt(checked, 8, "main and side bosses checked: %d" % checked)
	for index: int in range(PrimmBoss.PHASES):
		PrimmBoss.phase(index)
		assert_eq(EncounterModifiers.setup_turns(PrimmBoss.rules_key(index)), PrimmBoss.SETUP_TURNS, "Primm phase %d" % index)


func test_wild_growth_stops_at_three_buffs_per_unit() -> void:
	var stage0: CardData = _token(1, 1, "0")
	var growth: Array[Modifier] = [CardBuilder.modifier(Modifier.Kind.OVERGROWTH, 1), _escalating([stage0, stage0, stage0, stage0, stage0, stage0] as Array[CardData])]
	var game: GameState = _game(growth)
	GameFactory.pass_turn(game)  # boss turn 1: token A enters (after the growth step)
	var first: CardInstance = game.players[1].field[0]
	for _step: int in range(10):
		GameFactory.pass_turn(game)
	assert_eq(first.overgrowth_stacks, GameState.OVERGROWTH_CAP)
	assert_eq(game.get_attack(first), 1 + GameState.OVERGROWTH_CAP, "a 1/1 stops at 4/4")
	assert_eq(game.get_defense(first), 1 + GameState.OVERGROWTH_CAP)
	assert_true(str((DungeonRules.rules("refusemancer")[0] as Dictionary).get("text", "")).contains("up to 3"), "the Rotheart rule says so")
