extends GutTest
## New brief, Part F: SCRIPTED_ESCALATING_SUMMON - a reusable scripted-encounter rule ("at the
## start of each of the opponent's turns, summon an increasingly powerful creature"), built as a
## generic Modifier hook (not hardcoded to the Graveyard boss) so any future scripted boss can
## reuse it by attaching its own token stages. See docs/design/open_questions.md.

const NO_PIPS: Array[Affinity.Type] = []


func _token(power: int, toughness: int, id_suffix: String) -> CardData:
	return CardBuilder.token("stage_%s" % id_suffix, "Stage %s" % id_suffix, power, toughness)


func _escalating_modifier(stages: Array[CardData]) -> Modifier:
	var modifier: Modifier = Modifier.new()
	modifier.kind = Modifier.Kind.SCRIPTED_ESCALATING_SUMMON
	modifier.tokens = stages
	return modifier


func _game(p1_mods: Array[Modifier]) -> GameState:
	var options: GameOptions = GameOptions.new()
	options.rng_seed = 1
	var game: GameState = GameState.new(options)
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), null, [] as Array[ModifierSource], "P0"))
	var source: ModifierSource = CardBuilder.modifier_source("Scripted Boss", ModifierSource.SourceKind.DUNGEON, p1_mods)
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), null, [source] as Array[ModifierSource], "P1"))
	game.start()
	while game.stage == GameState.Stage.MULLIGAN:
		game.keep_hand(game.awaiting_player())
	return game


func test_summons_the_first_stage_on_the_first_turn_it_controls() -> void:
	var stage0: CardData = _token(1, 1, "0")
	var stage1: CardData = _token(2, 2, "1")
	var game: GameState = _game([_escalating_modifier([stage0, stage1] as Array[CardData])])
	GameFactory.pass_turn(game) # P1's first turn begins
	assert_eq(game.active, 1)
	assert_eq(game.players[1].battlefield.size(), 1)
	var summoned: CardInstance = game.players[1].battlefield[0]
	assert_eq(summoned.data, stage0)
	assert_eq(game.get_power(summoned), 1)
	assert_eq(game.get_toughness(summoned), 1)


func test_escalates_a_new_stage_each_of_its_own_turns() -> void:
	var stage0: CardData = _token(1, 1, "0")
	var stage1: CardData = _token(2, 2, "1")
	var stage2: CardData = _token(3, 3, "2")
	var game: GameState = _game([_escalating_modifier([stage0, stage1, stage2] as Array[CardData])])
	GameFactory.pass_turn(game) # P1 turn 1 of theirs: stage0
	GameFactory.pass_turn(game) # P0's turn
	GameFactory.pass_turn(game) # P1 turn 2 of theirs: stage1
	assert_eq(game.active, 1)
	var battlefield: Array[CardInstance] = game.players[1].battlefield
	assert_eq(battlefield.size(), 2)
	assert_eq(battlefield[0].data, stage0)
	assert_eq(battlefield[1].data, stage1)


func test_caps_at_the_last_stage_once_past_the_authored_ones() -> void:
	var stage0: CardData = _token(1, 1, "0")
	var stage1: CardData = _token(9, 9, "1")
	var game: GameState = _game([_escalating_modifier([stage0, stage1] as Array[CardData])])
	for i: int in range(5):
		GameFactory.pass_turn(game) # alternates P1/P0/P1/P0/P1
	assert_eq(game.active, 1)
	var battlefield: Array[CardInstance] = game.players[1].battlefield
	# 5 pass_turns from P1's first turn crosses P1's turn 1, 2 and 3 of their own (turns infrastructure on
	# P1 at i=0,2,4) - stage0 once, then stage1 (the cap) for every activation after.
	assert_eq(battlefield.size(), 3)
	assert_eq(battlefield[0].data, stage0)
	assert_eq(battlefield[1].data, stage1)
	assert_eq(battlefield[2].data, stage1, "stays capped at the strongest stage, never runs out")


func test_does_not_fire_on_the_other_players_turn() -> void:
	var stage0: CardData = _token(1, 1, "0")
	var game: GameState = _game([_escalating_modifier([stage0] as Array[CardData])])
	assert_eq(game.active, 0)
	assert_true(game.players[1].battlefield.is_empty(), "P1's own summon should not fire on P0's turn")
