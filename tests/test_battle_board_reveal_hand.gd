extends GutTest
## New brief, Part B: X-Ray Goggles (Modifier.Kind.REVEAL_OPPONENT_HAND) reveals the opponent's
## hand to the human in the UI - but never a set trap, whatever equipment either side has. See
## BattleBoard._is_hidden and docs/design/open_questions.md D91/D92.

func _game_with_goggles(has_goggles: bool) -> GameState:
	var options: GameOptions = GameOptions.new()
	options.rng_seed = 1
	var game: GameState = GameState.new(options)
	var mods: Array[Modifier] = []
	if has_goggles:
		mods.append(CardBuilder.modifier(Modifier.Kind.REVEAL_OPPONENT_HAND, 1))
	var source: ModifierSource = CardBuilder.modifier_source("Test Gear", ModifierSource.SourceKind.EQUIPMENT, mods)
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), null, [source] as Array[ModifierSource], "P0"))
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), null, [] as Array[ModifierSource], "P1"))
	game.start()
	while game.stage == GameState.Stage.MULLIGAN:
		game.keep_hand(game.awaiting_player())
	for player: PlayerState in game.players:
		player.hand.clear()
	return game


func _new_board(game: GameState) -> BattleBoard:
	var fx: BattleFX = BattleFX.new()
	add_child_autofree(fx)
	var board: BattleBoard = BattleBoard.new()
	add_child_autofree(board)
	board.setup(game, fx)
	return board


func test_opponent_hand_is_hidden_by_default() -> void:
	var game: GameState = _game_with_goggles(false)
	var card: CardInstance = GameFactory.add_to_hand(game, 1, GameFactory.vanilla(1, 1))
	var board: BattleBoard = _new_board(game)
	var view: CardView = board.ensure_view(card.uid, BattleBoard.Zone.HAND, 1)
	assert_eq(view.mode, CardView.Mode.BACK)


func test_xray_goggles_reveals_the_opponents_hand() -> void:
	var game: GameState = _game_with_goggles(true)
	var card: CardInstance = GameFactory.add_to_hand(game, 1, GameFactory.vanilla(1, 1))
	var board: BattleBoard = _new_board(game)
	var view: CardView = board.ensure_view(card.uid, BattleBoard.Zone.HAND, 1)
	assert_ne(view.mode, CardView.Mode.BACK, "X-Ray Goggles reveals the opponent's hand")


func test_xray_goggles_never_reveals_a_set_trap() -> void:
	var game: GameState = _game_with_goggles(true)
	var trap: CardInstance = GameFactory.add_to_hand(game, 1, GameFactory.vanilla(1, 1))
	var board: BattleBoard = _new_board(game)
	var view: CardView = board.ensure_view(trap.uid, BattleBoard.Zone.TRAPS, 1)
	assert_eq(view.mode, CardView.Mode.BACK, "a set trap stays hidden no matter what equipment either side has")


func test_the_humans_own_hand_is_never_hidden_regardless() -> void:
	var game: GameState = _game_with_goggles(false)
	var card: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.vanilla(1, 1))
	var board: BattleBoard = _new_board(game)
	var view: CardView = board.ensure_view(card.uid, BattleBoard.Zone.HAND, 0)
	assert_ne(view.mode, CardView.Mode.BACK)
