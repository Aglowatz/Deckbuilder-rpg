extends GutTest
## Nov 26 day (Part B): with the Extra Pocket worn, each item can be used twice per fight - two uses of the same item whether the
## player owns one copy or more, in drafts and in the main game. The first use of a fight spends one copy, the second is free; a
## last copy stays in its slot until its second use or the end of the fight. The item button shows the uses left ("2", then "1").

const ITEM: String = "healing_salve"


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func _to_main(game: GameState) -> void:
	var guard: int = 0
	while game.stage == GameState.Stage.MULLIGAN and guard < 4:
		game.keep_hand(game.awaiting_player())
		guard += 1
	guard = 0
	while not (game.active == 0 and game.in_main_phase()) and guard < 40 and not game.is_over():
		game.advance_phase()
		guard += 1


func _main_game(copies: int, pocket: bool) -> GameState:
	var profile: PlayerProfile = Session.profile
	profile.owned_items.clear()
	profile.item_uses_remaining.clear()
	profile.equipped_item_ids.clear()
	profile.equipment.clear()
	if pocket:
		profile.equipment.append(Session.content.equipment_piece("extra_pocket"))
	var item: ItemData = Session.content.item(ITEM)
	Session.add_item(item, copies)
	assert_true(profile.equip_item_id(item))
	var game: GameState = GameState.new()
	game.options.rng_seed = 4
	game.options.free_mulligan = false
	game.add_player(PlayerSetup.create(Session.deck, profile, [] as Array[ModifierSource], "Player"))
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), null, [] as Array[ModifierSource], "Foe"))
	game.start()
	_to_main(game)
	return game


func test_main_game_one_copy_with_the_pocket_is_used_twice() -> void:
	var game: GameState = _main_game(1, true)
	var item: ItemData = Session.content.item(ITEM)
	assert_eq(game.players[0].item_uses_per_battle, 2)
	var bar: ItemBar = ItemBar.new()
	bar.game = game
	bar._profile = Session.profile
	assert_eq(bar.badge_text(item), "2", "the button shows two uses")
	assert_true(Session.use_equipped_item(game, 0, item), "first use")
	assert_eq(bar.badge_text(item), "1", "then one")
	assert_true(Session.profile.is_item_equipped(item), "the last copy stays in its slot for the second use")
	assert_true(game.can_use_item(0, item))
	assert_true(Session.use_equipped_item(game, 0, item), "second use of the same single copy")
	assert_false(game.can_use_item(0, item), "no third use")
	assert_false(Session.profile.owns_item(item), "the copy is spent once both uses are made")
	assert_eq(Session.profile.spent_item_in_slot(0), ITEM, "its slot shows it used")
	bar.free()


func test_main_game_one_use_then_the_fight_ends_spends_the_copy() -> void:
	var game: GameState = _main_game(1, true)
	var item: ItemData = Session.content.item(ITEM)
	assert_true(Session.use_equipped_item(game, 0, item))
	assert_true(Session.profile.owns_item(item), "held for a second use")
	Session.end_item_battle()
	assert_false(Session.profile.owns_item(item), "the fight is over: the spent copy goes")
	assert_false(Session.profile.is_item_held(item))


func test_main_game_two_copies_with_the_pocket_spend_one_per_fight() -> void:
	var game: GameState = _main_game(2, true)
	var item: ItemData = Session.content.item(ITEM)
	assert_true(Session.use_equipped_item(game, 0, item))
	assert_true(Session.use_equipped_item(game, 0, item))
	assert_false(game.can_use_item(0, item))
	assert_eq(Session.profile.item_uses_left(item), 1, "the second use was the Pocket's: one copy left for the next fight")
	Session.end_item_battle()
	assert_true(Session.profile.owns_item(item))


func test_main_game_without_the_pocket_is_once_and_spends_a_copy() -> void:
	var game: GameState = _main_game(2, false)
	var item: ItemData = Session.content.item(ITEM)
	var bar: ItemBar = ItemBar.new()
	bar.game = game
	bar._profile = Session.profile
	assert_eq(bar.badge_text(item), "x2", "the copies, as before")
	assert_true(Session.use_equipped_item(game, 0, item))
	assert_false(game.can_use_item(0, item), "once per fight")
	assert_eq(Session.profile.item_uses_left(item), 1)
	bar.free()


func test_a_last_copy_saved_mid_fight_loads_as_spent() -> void:
	var game: GameState = _main_game(1, true)
	var item: ItemData = Session.content.item(ITEM)
	assert_true(Session.use_equipped_item(game, 0, item))
	var data: Dictionary = Session.to_dict()
	Session.from_dict(data)
	assert_false(Session.profile.owns_item(item), "no item with 0 charges comes back from a save")


func test_draft_fight_one_copy_with_the_pocket_is_used_twice() -> void:
	var state: DraftState = DraftEngine.start(Session.content, "zone:beefcake", [int(Affinity.Type.BEEFCAKE)], 12, 11, false, false)
	var guard: int = 0
	while state.phase == DraftState.PHASE_PICK and guard < 100:
		DraftEngine.pick(Session.content, state, 0)
		guard += 1
	DraftRun.begin(Session.content, state)
	state.equipment = ["extra_pocket"] as Array[String]
	state.items = [ITEM] as Array[String]
	var stand_in: PlayerProfile = DraftRun.player_profile(Session.content, state)
	var real: PlayerProfile = Session.profile
	Session.profile = stand_in
	var item: ItemData = stand_in.owned_items[0]
	assert_eq(stand_in.item_uses_left(item), 1, "a draft gives one copy of each item")
	var game: GameState = DraftRun.build_game(Session.content, state, stand_in, DraftRun.next_rival(state), 5)
	_to_main(game)
	assert_eq(game.players[0].item_uses_per_battle, 2, "the drafted Extra Pocket is worn")
	assert_true(game.active == 0 and game.in_main_phase(), "in the player's main phase (turn %d, active %d, over %s)" % [game.turn, game.active, game.is_over()])
	assert_true(stand_in.is_item_equipped(item), "equipped")
	assert_true(game.can_use_item(0, item), "usable")
	assert_true(Session.use_equipped_item(game, 0, item), "first use")
	assert_true(game.can_use_item(0, item), "the one copy can be used again")
	assert_true(Session.use_equipped_item(game, 0, item), "second use in the draft fight")
	assert_false(game.can_use_item(0, item))
	assert_false(stand_in.owns_item(item))
	Session.profile = real


func test_the_text_says_so() -> void:
	var pocket: EquipmentData = Session.content.equipment_piece("extra_pocket")
	assert_string_contains(pocket.description, "twice per duel")  # Nov 26 night: "duel", as on every piece
	assert_string_contains(pocket.description, "second is free")
	assert_string_contains(BattleScreen.why_item_spent(2), "twice")
	assert_eq(BattleScreen.why_item_spent(1), "Each item works once per battle")
