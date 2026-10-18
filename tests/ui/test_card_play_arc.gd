extends GutTest
## Overnight Oct 17 (Phase 2 cycle 8): a played card flies to the middle on a curve and still lands exactly on its spot, the right size.


func _game() -> GameState:
	var options: GameOptions = GameOptions.new()
	options.rng_seed = 1
	var game: GameState = GameState.new(options)
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), null, [] as Array[ModifierSource], "P0"))
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), null, [] as Array[ModifierSource], "P1"))
	game.start()
	while game.stage == GameState.Stage.MULLIGAN:
		game.keep_hand(game.awaiting_player())
	for player: PlayerState in game.players:
		player.hand.clear()
	return game


func test_the_card_curves_and_lands_on_its_spot() -> void:
	var game: GameState = _game()
	var card: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.vanilla(1, 1))
	var fx: BattleFX = BattleFX.new()
	add_child_autofree(fx)
	var board: BattleBoard = BattleBoard.new()
	add_child_autofree(board)
	board.setup(game, fx)
	var view: CardView = board.ensure_view(card.uid, BattleBoard.Zone.HAND, 0)
	board.layout(false)
	var start: Vector2 = view.position
	board.zones[card.uid] = BattleBoard.Zone.CENTER
	board.layout()
	board._arc_to_target(card.uid)
	var target: Dictionary = board._targets[card.uid] as Dictionary
	var end: Vector2 = (target["pos"] as Vector2) - CardView.SIZE * 0.5
	var straight_mid: Vector2 = (start + end) * 0.5
	await wait_seconds(0.18 / board.speed)
	assert_gt(view.position.distance_to(straight_mid), 15.0, "half way it is off the straight line")
	await wait_seconds(0.5 / board.speed)
	assert_almost_eq(view.position.x, end.x, 0.5)
	assert_almost_eq(view.position.y, end.y, 0.5)
	assert_almost_eq(view.scale.x, float(target["scale"]), 0.01)
	assert_almost_eq(view.rotation_degrees, float(target["rot"]), 0.5)


## Phase 2 cycle 19: damage numbers grow with the blow.
func test_damage_numbers_grow_with_the_blow() -> void:
	assert_eq(BattleBoard.damage_text_size(1), 44)
	assert_eq(BattleBoard.damage_text_size(3), 52)
	assert_eq(BattleBoard.damage_text_size(8), 72)
	assert_eq(BattleBoard.damage_text_size(20), 72, "capped")
	assert_eq(BattleBoard.damage_text_size(0), 44, "a zero still has a readable size")
