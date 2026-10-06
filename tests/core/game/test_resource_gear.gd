extends CardTestBase
## Brief 14 follow-up: equipment and items that work on Resources, and Resources shown as tokens on the battlefield.

func _equipped(piece_id: String) -> GameState:
	CardSet.load_all()
	var piece: EquipmentData = ProgressionContent.zone_equipment()[piece_id] as EquipmentData
	var profile: PlayerProfile = PlayerProfile.new()
	var setup: PlayerSetup = PlayerSetup.create(GameFactory.make_deck(), profile, [piece] as Array[ModifierSource], "Player")
	var game: GameState = GameState.new()
	game.options.rng_seed = 5
	game.options.free_mulligan = false
	game.add_player(setup)
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), null, [] as Array[ModifierSource], "Foe"))
	game.start()
	return game


func test_iron_knuckles_start_the_duel_with_two_iron() -> void:
	var game: GameState = _equipped("iron_knuckles")
	assert_eq(_count(game, 0, KIND.IRON), 2)
	assert_eq(_count(game, 1, KIND.IRON), 0)


func test_the_pantry_apron_starts_with_ingredients_and_adds_one_to_every_batch() -> void:
	var game: GameState = _equipped("pantry_apron")
	assert_eq(_count(game, 0, KIND.INGREDIENT), 3, "2 created + 1 extra")
	_give(game, 0, KIND.INGREDIENT, 1)
	assert_eq(_count(game, 0, KIND.INGREDIENT), 5, "1 created + 1 extra")


func test_the_bin_lid_adds_a_garbage_and_the_stamp_starts_with_tape_and_a_contract() -> void:
	var game: GameState = _equipped("bin_lid")
	_give(game, 0, KIND.GARBAGE, 2)
	assert_eq(_count(game, 0, KIND.GARBAGE), 3)
	var clerk: GameState = _equipped("clerks_stamp")
	assert_eq(_count(clerk, 0, KIND.RED_TAPE), 1)
	assert_eq(_count(clerk, 0, KIND.CONTRACT), 1)


func test_resource_items_create_resources() -> void:
	CardSet.load_all()
	var items: Dictionary = ProgressionContent.items({})
	for pair: Array in [["iron_ration", KIND.IRON, 2], ["spice_pouch", KIND.INGREDIENT, 2], ["bag_of_rubbish", KIND.GARBAGE, 3], ["blank_form", KIND.RED_TAPE, 2]]:
		var item: ItemData = items[pair[0]] as ItemData
		assert_not_null(item, str(pair[0]))
		var game: GameState = _game()
		EffectResolver.resolve(game, item.effect, EffectContext.make(0, 0, 0))
		assert_eq(_count(game, 0, pair[1] as ResourceKind.Kind), int(pair[2]), str(pair[0]))


func test_resources_are_tokens_on_the_board_not_a_counter() -> void:
	CardSet.load_all()
	var game: GameState = _game()
	_give(game, 0, KIND.IRON, 2)
	_give(game, 1, KIND.GARBAGE, 1)
	var board: BattleBoard = BattleBoard.new()
	add_child_autofree(board)
	board.setup(game, BattleFX.new())
	board.sync_state(false)
	var mine: int = 0
	var theirs: int = 0
	for uid: int in board.views.keys():
		if int(board.zones[uid]) == BattleBoard.Zone.RESOURCES:
			var view: CardView = board.view_for(uid)
			assert_eq(view.mode, CardView.Mode.COIN)
			if int(view.get_meta("owner")) == 0:
				mine += 1
			else:
				theirs += 1
	assert_eq(mine, 2, "one coin per Iron")
	assert_eq(theirs, 1)
