extends GutTest
## Oct 19: tokens on the board as cards. The token tray (and its "Tokens (none yet)" caption) is gone; a player's non-unit tokens
## (Contracts) lie as small cards, one stack per token type with an "x3" badge; using one removes its card. Resources keep their tray.

const KIND := ResourceKind.Kind


func _game() -> GameState:
	CardSet.load_all()
	return GameFactory.blank_game()


func _board(game: GameState) -> BattleBoard:
	var fx: BattleFX = BattleFX.new()
	add_child_autofree(fx)
	var board: BattleBoard = BattleBoard.new()
	add_child_autofree(board)
	board.setup(game, fx)
	board.speed = 50.0
	board.sync_state(false)
	return board


func _token_views(board: BattleBoard, owner_index: int) -> Array[CardView]:
	var result: Array[CardView] = []
	for uid: int in board._cards_in(owner_index, BattleBoard.Zone.TOKENS):
		result.append(board.view_for(uid))
	return result


func test_no_token_tray_or_caption_any_more() -> void:
	var board: BattleBoard = _board(_game())
	board.layout(false)
	for name: String in ["TokenTray0", "TokenTray1", "TokenBadge0", "TokenBadge1"]:
		assert_null(board.get_node_or_null(name), "%s is gone" % name)


func test_a_created_contract_appears_as_a_card() -> void:
	var game: GameState = _game()
	ResourceRules.create(game, 0, KIND.CONTRACT, 1)
	var board: BattleBoard = _board(game)
	var views: Array[CardView] = _token_views(board, 0)
	assert_eq(views.size(), 1)
	assert_eq(views[0].mode, CardView.Mode.FULL, "a token card, not a coin")
	assert_true(views[0].data.is_token)
	assert_gt(views[0].position.y + CardView.SIZE.y * 0.5, 540.0, "on the player's half (card centre)")


func test_copies_stack_with_a_count_badge() -> void:
	var game: GameState = _game()
	ResourceRules.create(game, 0, KIND.CONTRACT, 3)
	ResourceRules.create(game, 1, KIND.CONTRACT, 1)
	var board: BattleBoard = _board(game)
	board.layout(false)
	var views: Array[CardView] = _token_views(board, 0)
	assert_eq(views.size(), 3)
	assert_lt(views[0].position.distance_to(views[2].position), 20.0, "one stack, slightly offset")
	var badge: Label = board.get_node_or_null("TokenCount0_0") as Label
	assert_not_null(badge)
	assert_true(badge.visible)
	assert_eq(badge.text, "x3")
	var enemy_badge: Label = board.get_node_or_null("TokenCount1_0") as Label
	assert_true(enemy_badge == null or not enemy_badge.visible, "a single token needs no badge")
	assert_lt(_token_views(board, 1)[0].position.y, 540.0, "the enemy's tokens sit on the enemy half")


func test_using_a_token_removes_its_card_and_updates_the_badge() -> void:
	var game: GameState = _game()
	ResourceRules.create(game, 0, KIND.CONTRACT, 2)
	var board: BattleBoard = _board(game)
	var gone: CardInstance = game.players[0].tokens[0]
	game.players[0].tokens.erase(gone)
	board.sync_state(true)
	assert_null(board.view_for(gone.uid), "the used token's card leaves the board")
	assert_eq(_token_views(board, 0).size(), 1)
	assert_false((board.get_node("TokenCount0_0") as Label).visible, "one left: no badge")


func test_resources_keep_their_coins_in_the_tray() -> void:
	var game: GameState = _game()
	ResourceRules.create(game, 0, KIND.IRON, 2)
	var board: BattleBoard = _board(game)
	for uid: int in board._cards_in(0, BattleBoard.Zone.RESOURCES):
		assert_eq(board.view_for(uid).mode, CardView.Mode.COIN)
	assert_eq(board._cards_in(0, BattleBoard.Zone.RESOURCES).size(), 2)
