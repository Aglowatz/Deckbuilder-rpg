extends CardTestBase
## Nov 18 day, Part 2: the battle screen. (1) No banner when the computer acts (the log keeps the record). (2) Stacks of identical tokens
## fan upward inside their lane so a strip of every card underneath shows (name bar and a little art), with the "x2" badge kept. (3) Every
## unit and token on the field uses the full-art field look - a hand card played while hovered used to land in the detail look.


func _board(game: GameState) -> BattleBoard:
	var fx: BattleFX = BattleFX.new()
	add_child_autofree(fx)
	var board: BattleBoard = BattleBoard.new()
	add_child_autofree(board)
	board.setup(game, fx)
	board.speed = 50.0
	board.sync_state(false)
	return board


func test_the_ai_turn_shows_no_action_banner() -> void:
	var source: String = FileAccess.get_file_as_string("res://ui/battle/battle_screen.gd")
	var ai_step: String = source.get_slice("func _ai_step()", 1).get_slice("\nfunc ", 0)
	assert_false(ai_step.contains("hud.announce(line"), "the AI's move is not announced in the middle of the board")
	assert_false(ai_step.contains("_describe_ai_action"), "no action line is built for a banner")


func test_the_log_still_records_the_ai_play() -> void:
	var game: GameState = _game()
	var log_view: BattleLog = BattleLog.new()
	add_child_autofree(log_view)
	log_view.setup(game, "Cave Scavenger", {})
	var card: CardInstance = GameFactory.add_to_hand(game, 1, CardSet.card("C-04"))
	var event: GameEvent = GameEvent.new()
	event.type = GameEvent.Type.CARD_PLAYED
	event.player = 1
	event.card = card.uid
	assert_string_contains(log_view.describe(event), "Cave Scavenger played [b]Courier Pigeon[/b]")


func test_a_token_stack_fans_so_each_card_underneath_shows_its_name_bar() -> void:
	var game: GameState = _game()
	var temps: Array[CardInstance] = []
	for i: int in range(3):
		var temp: CardInstance = game.create_instance(TokenRegistry.data("T-05"), 0)
		game.players[0].field.append(temp)
		temps.append(temp)
	var board: BattleBoard = _board(game)
	board.layout(false)
	var stacks: Array[Dictionary] = board.field_stacks_of(0)
	assert_eq(stacks.size(), 1, "one stack")
	var uids: Array = stacks[0]["uids"] as Array
	var tops: Array[float] = []
	for uid: Variant in uids:
		var view: CardView = board.view_for(int(uid))
		tops.append(view.position.y + CardView.SIZE.y * 0.5 - CardView.SIZE.y * 0.5 * view.scale.y)
	var peek: float = tops[1] - tops[0]
	var scale: float = board.view_for(int(uids[0])).scale.y
	assert_gte(peek, CardView.SIZE.y * scale * 0.18, "a strip of the card underneath shows (name bar and a little art), not 6 px")
	var badge: Label = board.get_node_or_null("FieldStack0_0") as Label
	assert_not_null(badge)
	assert_true(badge.visible)
	assert_eq(badge.text, "x3")


func test_a_fanned_stack_stays_inside_its_lane() -> void:
	for size: int in [2, 3, 5]:
		var spread: Dictionary = BattleBoard.stack_spread(size, BattleBoard.SCALE_BF)
		var lane_half: float = CardView.SIZE.y * BattleBoard.SCALE_BF * 0.5
		var first: Vector2 = BattleBoard.stack_offset(size, 0, BattleBoard.SCALE_BF)
		var last: Vector2 = BattleBoard.stack_offset(size, size - 1, BattleBoard.SCALE_BF)
		var half: float = CardView.SIZE.y * float(spread["scale"]) * 0.5
		assert_almost_eq(first.y - half, -lane_half, 0.5, "top edge on the lane's top (%d cards)" % size)
		assert_almost_eq(last.y + half, lane_half, 0.5, "front card's bottom on the lane's bottom (%d cards)" % size)
	assert_eq(BattleBoard.stack_offset(1, 0, BattleBoard.SCALE_BF), Vector2.ZERO, "a lone card is unchanged")


func test_a_card_played_while_hovered_lands_in_the_field_look() -> void:
	var game: GameState = _game()
	_energy(game, 0, 3)
	var pigeon: CardInstance = GameFactory.add_to_hand(game, 0, CardSet.card("C-04"))
	var board: BattleBoard = _board(game)
	var view: CardView = board.view_for(pigeon.uid)
	board._on_hover(view)
	assert_eq(view.mode, CardView.Mode.FULL, "hovered in the hand: shown whole")
	assert_true(game.play_card(0, pigeon.uid))
	board.sync_state(false)
	assert_eq(board.view_for(pigeon.uid).mode, CardView.Mode.COMPACT, "on the field: the full-art field look")
	assert_eq(board.hover_uid, 0)


func test_every_field_card_uses_the_field_look() -> void:
	var game: GameState = _game()
	var a: CardInstance = GameFactory.add_to_field(game, 0, CardSet.card("C-04"))
	var b: CardInstance = GameFactory.add_to_field(game, 0, CardSet.card("C-04"))
	var board: BattleBoard = _board(game)
	board.view_for(b.uid).set_mode(CardView.Mode.FULL)
	board.sync_state(false)
	assert_eq(board.view_for(a.uid).mode, CardView.Mode.COMPACT)
	assert_eq(board.view_for(b.uid).mode, CardView.Mode.COMPACT, "a field card left in the detail look is put back")
