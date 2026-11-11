extends GutTest
## Fable pass Nov 10, Part 2: a TURN is both players' turns (the first player goes, then the second: Turn 1). The HUD, the log, the boss
## setup window, the result lines and the sims count these; the engine's half-turn counter is untouched, so every timing is the same
## moment as before. Card text no longer says a bare "until end of turn".


func test_turn_numbers_pair_the_half_turns() -> void:
	assert_eq(GameState.turn_number_of(0), 1)
	assert_eq(GameState.turn_number_of(1), 1, "the first player's first turn")
	assert_eq(GameState.turn_number_of(2), 1, "the second player's first turn is still Turn 1")
	assert_eq(GameState.turn_number_of(3), 2, "the first player's second turn opens Turn 2")
	assert_eq(GameState.turn_number_of(4), 2)
	assert_eq(GameState.turn_number_of(11), 6)
	assert_eq(BattleHud.round_of(3), GameState.turn_number_of(3), "the HUD's old helper counts the same turns")


func test_the_setup_window_counts_the_same_turns_as_the_panel() -> void:
	assert_eq(BossTempo.countdown_text(2), "Setting Up: 2 turns left")
	assert_eq(BossTempo.countdown_text(1), "Setting Up: 1 turn left")
	assert_eq(BossTempo.countdown_text(0), "")
	assert_string_contains(BossTempo.rule_text(2), "turns 1-2")
	assert_string_contains(BossTempo.rule_text(2), "from turn 3")
	assert_string_contains(BossTempo.rule_text(1), "from turn 2")
	assert_false(BossTempo.rule_text(2).contains("round"), "no rounds anywhere in the boss window text")


func test_the_countdown_never_disagrees_with_the_rule_text() -> void:
	# a boss with a 2-turn window (`turns_taken` counts the turn in progress): during its first turn the HUD says 2 left (this one and the
	# next), during its second 1 left, during its third nothing - it attacks from turn 3, as the panel says. Before its first turn the count
	# is clamped to the window (never 3 for a 2-turn window: late critic #5).
	var game: GameState = GameState.new()
	var me: PlayerState = game.add_player(_setup())
	var foe: PlayerState = game.add_player(_setup())
	foe.modifiers.add(CardBuilder.modifier(Modifier.Kind.SETUP_TURNS, 2))
	assert_not_null(me)
	foe.turns_taken = 0
	assert_eq(game.setup_turns_left(1), 2, "before its first turn: the whole window, never more")
	foe.turns_taken = 1
	assert_eq(game.setup_turns_left(1), 2, "turn 1: this turn and the next")
	foe.turns_taken = 2
	assert_eq(game.setup_turns_left(1), 1, "turn 2: the last quiet one")
	foe.turns_taken = 3
	assert_eq(game.setup_turns_left(1), 0, "its third turn (Turn 3) is the first that attacks: 'from turn 3'")


func test_the_shown_countdown_follows_the_turn_label_whoever_goes_first() -> void:
	# Nov 11 (late critic #4): with the hero first, the HUD said "2 turns left" on Turn 1 and Turn 2.
	var game: GameState = GameState.new()
	game.add_player(_setup())
	var foe: PlayerState = game.add_player(_setup())
	foe.modifiers.add(CardBuilder.modifier(Modifier.Kind.SETUP_TURNS, 2))
	assert_eq(game.setup_turns_left_shown(1, 1), 2, "Turn 1 (either half)")
	assert_eq(game.setup_turns_left_shown(1, 2), 2)
	assert_eq(game.setup_turns_left_shown(1, 3), 1, "Turn 2")
	assert_eq(game.setup_turns_left_shown(1, 4), 1)
	assert_eq(game.setup_turns_left_shown(1, 5), 0, "Turn 3: attacks start, as the rule says")
	assert_eq(game.setup_turns_left_shown(0, 1), 0, "the hero has no window")


func test_one_energy_count_for_every_message() -> void:
	var game: GameState = GameState.new()
	var me: PlayerState = game.add_player(_setup())
	game.add_player(_setup())
	assert_eq(game.energy_available(0), me.ready_infrastructure().size() + me.pool.size())


func test_no_card_says_a_bare_until_end_of_turn() -> void:
	var content: ContentSet = ContentLibrary.load_all()
	var bare: PackedStringArray = []
	var your: int = 0
	var enemy: int = 0
	for table: Dictionary in [content.cards, content.multipath_cards, content.zone_cards, content.tokens]:
		for id: Variant in table.keys():
			var card: CardData = table[id] as CardData
			if card == null:
				continue
			var text: String = card.rules_text
			if text.contains("until end of turn"):
				bare.append(str(id))
			if text.contains("until the end of your turn"):
				your += 1
			if text.contains("until the end of the enemy's turn"):
				enemy += 1
				assert_true(text.contains("opposing unit attacks"), "%s: the enemy's turn only for a trap that fires on it" % str(id))
	assert_eq(bare.size(), 0, "bare 'until end of turn' left on: " + ", ".join(bare))
	assert_gt(your, 20, "the pumps say whose turn they last until")
	assert_eq(enemy, 4, "the four attack traps")


func test_the_log_header_names_the_turn() -> void:
	var log: BattleLog = BattleLog.new()
	add_child_autofree(log)
	log.enemy_name = "Quota"
	var event: GameEvent = GameEvent.new()
	event.type = GameEvent.Type.TURN_STARTED
	event.player = 1
	event.value = 4
	var line: String = log.describe(event)
	assert_string_contains(line, "Turn 2")
	assert_string_contains(line, "Quota's turn")
	event.player = 0
	event.value = 5
	assert_string_contains(log.describe(event), "Turn 3: your turn")


static func _setup() -> PlayerSetup:
	var setup: PlayerSetup = PlayerSetup.new()
	setup.deck = GameFactory.make_deck()
	return setup
