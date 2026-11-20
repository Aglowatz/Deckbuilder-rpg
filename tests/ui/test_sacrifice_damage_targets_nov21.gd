extends GutTest
## Fable Nov 21 (Part 2.1): cards that destroy one of your units to deal damage can be aimed at the opponent in the real battle screen,
## with the mouse (a click on the opponent's portrait) and with the controller (the cursor on the portrait, A). One test per card.

var _screen: BattleScreen


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Keybinds.reset_all()
	InputDevice.set_kind(InputDevice.Kind.KEYBOARD)
	_screen = (load("res://scenes/battle.tscn") as PackedScene).instantiate() as BattleScreen
	_screen.screenshot_prepare({"no_tutorial": "true", "no_intro": "true", "fast": "true"})
	add_child_autofree(_screen)
	await _until(func() -> bool: return _screen.mode == BattleScreen.Mode.MULLIGAN, 8.0)
	_screen._mulligan_choice(true)
	await _until(func() -> bool: return _screen.mode == BattleScreen.Mode.MAIN and not _screen.busy and PadFocus.top_root(get_tree()) == null, 10.0)
	await get_tree().process_frame


func after_each() -> void:
	InputDevice.set_kind(InputDevice.Kind.KEYBOARD)


func _until(condition: Callable, limit: float) -> bool:
	var waited: float = 0.0
	while waited < limit:
		if bool(condition.call()):
			return true
		await get_tree().process_frame
		waited += get_process_delta_time()
	return bool(condition.call())


## A 4/4 of the player's on the field, plenty of energy, `card_id` in hand, the opponent at 20 HP with one 2/2.
func _set_up(card_id: String) -> Dictionary:
	var game: GameState = _screen.game
	for path: Affinity.Type in Affinity.colored_types():
		GameFactory.add_infrastructure_cards(game, 0, 3, path)
	var mine: CardInstance = GameFactory.add_to_field(game, 0, GameFactory.vanilla(4, 4, 1, Affinity.Type.BEEFCAKE, [] as Array[CardEnums.Keyword]))
	mine.exhausted = false
	var theirs: CardInstance = GameFactory.add_to_field(game, 1, GameFactory.vanilla(2, 2, 1, Affinity.Type.BEEFCAKE, [] as Array[CardEnums.Keyword]))
	game.players[1].hp = 20
	var card: CardInstance = GameFactory.add_to_hand(game, 0, CardSet.card(card_id))
	_screen._refresh_ui()
	await get_tree().process_frame
	return {"mine": mine, "theirs": theirs, "card": card}


func _click_portrait(index: int) -> void:
	_screen._click_portrait_target(_screen.hud.portrait_center(index))


func _pad_pick_portrait(index: int) -> bool:
	_screen.pad.reset()
	for stop: Dictionary in _screen.pad.stops():
		if str(stop["kind"]) == "portrait" and int(stop["player"]) == index:
			_screen.pad._set_cursor(stop)
			_screen.pad.activate()
			return true
	return false


func _settled() -> void:
	await _until(func() -> bool: return _screen.mode == BattleScreen.Mode.MAIN and not _screen.busy, 6.0)


func test_dead_weight_can_be_aimed_at_the_opponent_with_the_mouse() -> void:
	var set_up: Dictionary = await _set_up("NB-04")
	_screen._try_play((set_up["card"] as CardInstance).uid)
	assert_eq(_screen.mode, BattleScreen.Mode.TARGETING, "Dead Weight asks for its target")
	assert_has(_screen._target_options, Targets.player(1), "the opponent is a legal target")
	assert_has(_screen._target_options, (set_up["theirs"] as CardInstance).uid, "and so is a unit")
	assert_does_not_have(_screen._target_options, (set_up["mine"] as CardInstance).uid, "but not the unit that is destroyed as the cost")
	assert_string_contains(str(_screen._chain_steps[_screen._chain_pos]["prompt"]), "a unit or the opponent")
	assert_string_contains(str(_screen._chain_steps[_screen._chain_pos]["prompt"]), "opponent's portrait")
	_click_portrait(1)
	await _settled()
	assert_eq(_screen.game.players[1].hp, 16, "the destroyed 4/4's attack hits the opponent")
	assert_false(_screen.game.players[0].field.has(set_up["mine"]), "the unit was the cost")


func test_dead_weight_can_be_aimed_at_the_opponent_with_the_controller() -> void:
	var set_up: Dictionary = await _set_up("NB-04")
	InputDevice.set_kind(InputDevice.Kind.PAD)
	_screen._try_play((set_up["card"] as CardInstance).uid)
	assert_true(_pad_pick_portrait(1), "the opponent's portrait is a stop while aiming")
	await _settled()
	assert_eq(_screen.game.players[1].hp, 16)


## The root cause of the owner's report: the target was asked for before the sacrifice, in the same words, so the unit the player
## clicked to sacrifice became the damage's target. The cost is chosen first now and says so.
func test_dead_weight_asks_for_the_sacrifice_first_then_the_target() -> void:
	var set_up: Dictionary = await _set_up("NB-04")
	var small: CardInstance = GameFactory.add_to_field(_screen.game, 0, GameFactory.vanilla(1, 1, 1, Affinity.Type.BEEFCAKE, [] as Array[CardEnums.Keyword]))
	_screen._refresh_ui()
	_screen._try_play((set_up["card"] as CardInstance).uid)
	assert_eq(str(_screen._chain_steps[0]["role"]), "pick", "first the cost")
	assert_string_contains(str(_screen._chain_steps[0]["prompt"]), "Choose the unit to destroy")
	assert_does_not_have(_screen._target_options, Targets.player(1), "nothing but your own units while choosing the sacrifice")
	assert_has(_screen._target_options, (set_up["mine"] as CardInstance).uid)
	_screen._finish_targeting((set_up["mine"] as CardInstance).uid)
	await get_tree().process_frame
	assert_eq(_screen.mode, BattleScreen.Mode.TARGETING, "then the target")
	assert_has(_screen._target_options, Targets.player(1), "the opponent")
	assert_has(_screen._target_options, small.uid, "your other unit is still a legal target")
	assert_does_not_have(_screen._target_options, (set_up["mine"] as CardInstance).uid, "the sacrificed one is not")
	_click_portrait(1)
	await _settled()
	assert_eq(_screen.game.players[1].hp, 16, "the chosen 4/4, not the cheaper 1/1")
	assert_true(_screen.game.players[0].field.has(small))


func test_yeet_can_be_aimed_at_the_opponent_with_the_mouse() -> void:
	var set_up: Dictionary = await _set_up("B-25")
	_screen._try_play((set_up["card"] as CardInstance).uid)
	assert_eq(_screen.mode, BattleScreen.Mode.TARGETING)
	assert_has(_screen._target_options, (set_up["mine"] as CardInstance).uid, "first the unit to throw")
	assert_string_contains(str(_screen._chain_steps[0]["prompt"]), "Choose one of your units")
	_screen._finish_targeting((set_up["mine"] as CardInstance).uid)
	await get_tree().process_frame
	assert_eq(_screen.mode, BattleScreen.Mode.TARGETING, "then what it is thrown at")
	assert_has(_screen._target_options, Targets.player(1), "the opponent is a legal target")
	_click_portrait(1)
	await _settled()
	assert_eq(_screen.game.players[1].hp, 16)
	assert_false(_screen.game.players[0].field.has(set_up["mine"]), "the thrown unit is destroyed")


func test_yeet_can_be_aimed_at_the_opponent_with_the_controller() -> void:
	var set_up: Dictionary = await _set_up("B-25")
	InputDevice.set_kind(InputDevice.Kind.PAD)
	_screen._try_play((set_up["card"] as CardInstance).uid)
	_screen._finish_targeting((set_up["mine"] as CardInstance).uid)
	await get_tree().process_frame
	assert_true(_pad_pick_portrait(1), "the opponent's portrait is a stop while aiming")
	await _settled()
	assert_eq(_screen.game.players[1].hp, 16)


## The click itself: a real left click at the opponent's portrait (the event's position, wherever the cursor is) finishes the aim.
func test_a_real_click_on_the_opponents_portrait_is_taken() -> void:
	var set_up: Dictionary = await _set_up("NB-04")
	_screen._try_play((set_up["card"] as CardInstance).uid)
	var click: InputEventMouseButton = InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	click.position = _screen.hud.portrait_center(1)
	click.global_position = click.position
	_screen._input(click)
	await _settled()
	assert_eq(_screen.game.players[1].hp, 16)


## Hammer Thrower (Overexert: its attack as damage to a unit or the opponent) goes through the same aiming.
func test_hammer_thrower_can_be_aimed_at_the_opponent() -> void:
	await _set_up("NB-04")
	var thrower: CardInstance = GameFactory.add_to_field(_screen.game, 0, CardSet.card("B-34"))
	thrower.exhausted = false
	_screen.board.sync_state(false)
	_screen._refresh_ui()
	var attack: int = _screen.game.get_attack(thrower)
	_screen._try_activate(thrower.uid)
	assert_eq(_screen.mode, BattleScreen.Mode.TARGETING)
	assert_has(_screen._target_options, Targets.player(1))
	_click_portrait(1)
	await _settled()
	assert_eq(_screen.game.players[1].hp, 20 - attack)
