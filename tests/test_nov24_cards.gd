extends CardTestBase
## Fable Nov 24 (Part 5): the owner's card changes.
##   Signal Reader shows the ACTUAL cards of the opponent's hand, enlarged over the middle of the screen, closed with a click.
##   Plate It, Staff Appreciation Dinner and Dinner Is Served each cost 1 less. Idiot Sandwich can Plate any unit.


func _card(id: String) -> CardData:
	var card: CardData = CardSet.card(id)
	assert_not_null(card, id)
	return card


func _sheet_row(id: String) -> PackedStringArray:
	var file: FileAccess = FileAccess.open("res://data/source/card_list.csv", FileAccess.READ)
	assert_not_null(file)
	while file != null and not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		if row.size() > 14 and row[14] == id:
			return row
	return PackedStringArray()


# ---- the three cheaper cards ------------------------------------------------------------------------------------------------------


func test_plate_it_costs_one_less() -> void:
	assert_eq(_card("G-20").display_name, "Plate It")
	assert_eq(_card("G-20").energy_value(), 3, "2 and a Gourmand energy (it was 3 and a Gourmand)")
	assert_eq(_sheet_row("G-20")[3], "2(G)", "the card sheet says so")
	# it still Plates any unit
	var game: GameState = _game()
	_energy(game)
	var target: CardInstance = _field(game, 1, "N-28")
	_play(game, "G-20", [target.uid] as Array[int])
	assert_eq(target.data.id, "T-09", "the Lich is a Snack")


func test_staff_appreciation_dinner_costs_one_less() -> void:
	assert_eq(_card("GN-08").display_name, "Staff Appreciation Dinner")
	assert_eq(_card("GN-08").energy_value(), 3, "1, a Gourmand and a Necrocrat energy (it was 2 and both)")
	assert_eq(_sheet_row("GN-08")[3], "1(G)(N)")
	# and still gives your tokens +1/+0
	var game: GameState = _game()
	_field(game, 0, "GN-08")
	var token: CardInstance = game.create_token(0, TokenRegistry.data("T-10"))
	assert_eq(game.get_attack(token), 2, "a 1/1 Zombie Temp hits for 2 under the Dinner")
	assert_eq(game.get_defense(token), 1)


func test_dinner_is_served_costs_one_less() -> void:
	assert_eq(_card("G-16").display_name, "Dinner Is Served")
	assert_eq(_card("G-16").energy_value(), 2, "1 and a Gourmand energy (it was 2 and a Gourmand)")
	assert_eq(_sheet_row("G-16")[3], "1(G)")
	assert_string_contains(_card("G-16").rules_text, "attack 3 or less", "its own limit stays: the owner changed its cost only")


# ---- Idiot Sandwich ---------------------------------------------------------------------------------------------------------------


func test_idiot_sandwich_plates_any_unit() -> void:
	var sandwich: CardData = _card("GB-11")
	assert_eq(sandwich.display_name, "Idiot Sandwich")
	assert_eq(sandwich.rules_text, "Plate target unit. Deal 2 damage to its controller.")
	assert_false(sandwich.rules_text.contains("or less"), "no limit in the text")
	assert_false(sandwich.script_text.contains("atk<="), "and none in the script")
	assert_eq(_sheet_row("GB-11")[5], "Plate target unit. Deal 2 damage to its controller.")
	assert_eq(sandwich.energy_value(), 4, "its cost is unchanged")
	# a 7/7 with buffs on it: far over the old limit of attack 4
	var game: GameState = _game()
	_energy(game)
	var giant: CardInstance = _unit(game, 1, 7, 7, [CardEnums.Keyword.BULLDOZE] as Array[CardEnums.Keyword])
	game.buff_unit(giant, 2)
	assert_gt(game.get_attack(giant), 4)
	var hp: int = game.players[1].hp
	_play(game, "GB-11", [giant.uid] as Array[int])
	assert_eq(giant.data.id, "T-09", "the giant is a Snack")
	assert_eq(game.get_attack(giant), 1)
	assert_eq(game.get_defense(giant), 1)
	assert_false(game.unit_has_keyword(giant, CardEnums.Keyword.BULLDOZE))
	assert_eq(game.players[1].hp, hp - 2, "and its controller takes 2")
	# a small unit still works, and your own unit can be the target (its controller is you)
	var game2: GameState = _game()
	_energy(game2)
	var own: CardInstance = _unit(game2, 0, 2, 2)
	var own_hp: int = game2.players[0].hp
	_play(game2, "GB-11", [own.uid] as Array[int])
	assert_eq(own.data.id, "T-09")
	assert_eq(game2.players[0].hp, own_hp - 2)


func test_the_glossary_says_what_plate_takes() -> void:
	assert_string_contains(str(KeywordInfo.GLOSSARY["Plate"]), "any unit")
	assert_true(KeywordInfo.GLOSSARY.has("Look at a hand"), "the glossary explains Signal Reader's look")
	assert_string_contains(str(KeywordInfo.GLOSSARY["Look at a hand"]), "as cards")


# ---- Signal Reader ----------------------------------------------------------------------------------------------------------------


func test_signal_reader_hands_over_the_actual_cards() -> void:
	var game: GameState = _game()
	_energy(game)
	game.players[1].hand.clear()
	for id: String in ["C-37", "B-38", "N-29"]:
		GameFactory.add_to_hand(game, 1, _card(id))
	_play(game, "C-39")
	var ids: Array[String] = []
	for card: CardData in game.last_revealed_hand:
		ids.append(card.id)
	assert_eq(ids, ["C-37", "B-38", "N-29"] as Array[String], "the cards of the hand, in hand order")
	assert_eq(game.players[1].hand.size(), 3, "nothing moves")
	var seen: GameEvent = null
	for event: GameEvent in game.events:
		if event.type == GameEvent.Type.HAND_REVEALED:
			seen = event
	assert_not_null(seen)
	assert_eq(seen.amount, 3)
	assert_string_contains(seen.detail, "Mass Layoffs", "the battle log still gets the names")


func test_the_revealed_hand_is_shown_as_enlarged_cards_and_closes_on_a_click() -> void:
	var shown: Array[CardData] = [_card("C-37"), _card("B-38"), _card("N-29")]
	var panel: HandRevealPanel = HandRevealPanel.make(shown, "Fig Sly")
	add_child_autofree(panel)
	await get_tree().process_frame
	await get_tree().process_frame
	assert_eq((panel.find_child("Title", true, false) as Label).text, "Fig Sly's hand (3 cards)")
	var screen: Rect2 = Rect2(Vector2.ZERO, panel.get_viewport_rect().size)
	var centre_x: float = 0.0
	for index: int in range(3):
		var holder: Control = panel.find_child("Card%d" % index, true, false) as Control
		assert_not_null(holder, "card %d is shown as a card" % index)
		assert_eq(str(holder.get_meta(&"card_id")), shown[index].id)
		assert_gte(holder.size.y, CardView.SIZE.y * 0.85, "enlarged: nearly the full card")
		assert_true(screen.encloses(holder.get_global_rect()), "whole on the screen")
		assert_true(holder.get_child(0) is Control, "a real card view, not a name")
		centre_x += holder.get_global_rect().get_center().x / 3.0
	assert_almost_eq(centre_x, screen.size.x * 0.5, 40.0, "over the middle of the screen")
	assert_null(panel.find_child("Empty", true, false))
	# a click closes it (after the short guard, so the click that played the card does not)
	var closed: Array[bool] = [false]
	panel.closed.connect(func() -> void: closed[0] = true)
	var click: InputEventMouseButton = InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	panel._age = 0.0
	panel._gui_input(click)
	assert_false(closed[0], "not in the first instant")
	panel._age = 1.0
	panel._gui_input(click)
	assert_true(closed[0], "a click closes it")
	# a large hand is drawn smaller and still fits; an empty one says so
	assert_almost_eq(HandRevealPanel.scale_for(6, 1920.0), HandRevealPanel.CARD_SCALE, 0.001, "six in a row still fit at full size at 16:9")
	assert_lt(HandRevealPanel.scale_for(6, 1570.0), HandRevealPanel.CARD_SCALE, "in a narrower window six in a row are drawn smaller")
	assert_gte(HandRevealPanel.scale_for(14, 1280.0), HandRevealPanel.CARD_SCALE_MIN)
	for count: int in [1, 4, 6, 7, 10]:
		var per_row: int = count if count <= 6 else int(ceil(float(count) / 2.0))
		var used: float = float(per_row) * CardView.SIZE.x * HandRevealPanel.scale_for(count, 1570.0) + float(HandRevealPanel.GAP * (per_row - 1))
		assert_lte(used, 1570.0, "%d cards fit the owner's narrower window" % count)
	var empty: HandRevealPanel = HandRevealPanel.make([] as Array[CardData], "Fig Sly")
	add_child_autofree(empty)
	await get_tree().process_frame
	assert_not_null(empty.find_child("Empty", true, false))
	assert_eq(empty.title_text(), "Fig Sly's hand is empty")


func test_the_battle_screen_opens_the_pop_up_and_the_next_action_closes_it() -> void:
	# the screen's own hooks, without a whole battle: the layer goes up over everything, and goes away again
	var screen: BattleScreen = BattleScreen.new()
	screen.context = BattleContext.new()
	screen.context.enemy_name = "Fig Sly"
	screen._show_hand_reveal([_card("C-37"), _card("B-38")] as Array[CardData])
	assert_not_null(screen.hand_reveal)
	assert_eq(screen._reveal_layer.layer, BattleHud.MODAL_LAYER, "above the board, the hand and the banners")
	assert_eq(screen.hand_reveal.cards.size(), 2)
	assert_eq(screen.hand_reveal.owner_name, "Fig Sly")
	screen.hand_reveal.close()
	assert_null(screen.hand_reveal, "closing it takes the layer away")
	screen._show_hand_reveal([_card("C-37")] as Array[CardData])
	screen._close_hand_reveal()
	assert_null(screen._reveal_layer)
	screen.free()
