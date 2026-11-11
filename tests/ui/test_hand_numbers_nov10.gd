extends GutTest
## Fable pass Nov 10, Part 3 (a display fix, no layout change): a card in hand shows its numbers as the rules would apply them now - Primm's
## "every unit is a 3/3", a cost reducer, a zone rule - in green when better and red when worse, and the HUD preview says the printed values.


func _game() -> GameState:
	var game: GameState = GameState.new()
	for _index: int in range(2):
		var setup: PlayerSetup = PlayerSetup.new()
		setup.deck = GameFactory.make_deck()
		game.add_player(setup)
	return game


func _unit(game: GameState) -> CardInstance:
	var content: ContentSet = ContentLibrary.load_all()
	var data: CardData = null
	for id: Variant in content.cards.keys():
		var candidate: CardData = content.cards[id] as CardData
		if candidate != null and candidate.is_unit() and candidate.attack >= 4 and candidate.generic_cost >= 2 and not candidate.is_token:
			data = candidate
			break
	assert_not_null(data, "a unit with attack 4+ and generic cost 2+")
	var card: CardInstance = CardInstance.new()
	card.data = data
	card.uid = 4242
	card.owner = 0
	game.players[0].hand.append(card)
	return card


func test_a_standardized_unit_shows_three_three_in_hand_in_red_and_green() -> void:
	var game: GameState = _game()
	var card: CardInstance = _unit(game)
	game.players[1].modifiers.add(CardBuilder.modifier(Modifier.Kind.STANDARDIZE_UNITS, 3, Modifier.ANY_COLOR, 3))
	var view: CardView = CardView.create(card.data, CardView.Mode.FULL)
	add_child_autofree(view)
	view.apply_instance(card, game)
	assert_eq(view._attack_label.text.split("/")[0], "3", "the attack the rule gives it")
	var defense_text: String = view._defense_label.text if view._defense_label != null else view._attack_label.text.split("/")[1]
	assert_eq(defense_text, "3")
	var attack_colour: Color = view._attack_label.get_theme_color("font_color")
	assert_eq(attack_colour, Color("ff8080"), "attack below the print reads red (printed %d)" % card.data.attack)
	var now: String = BattleHud.now_line(card, game)
	assert_string_contains(now, "3/3 (printed %d/%d)" % [card.data.attack, card.data.defense])


func test_a_cost_reducer_shows_the_lower_cost_in_green() -> void:
	var game: GameState = _game()
	var card: CardInstance = _unit(game)
	var view: CardView = CardView.create(card.data, CardView.Mode.FULL)
	add_child_autofree(view)
	view.apply_instance(card, game)
	assert_eq(view.current_cost, card.data.energy_value(), "no change: the printed cost")
	assert_true(BattleHud.now_line(card, game).is_empty(), "nothing to say while the numbers match the print")
	game.players[0].modifiers.add(CardBuilder.modifier(Modifier.Kind.COST_CHANGE, -1))
	view.apply_instance(card, game)
	assert_eq(view.current_cost, card.data.energy_value() - 1, "one cheaper")
	if view._cost_label != null:
		assert_eq(view._cost_label.text, str(card.data.energy_value() - 1))
		assert_eq(view._cost_label.get_theme_color("font_color"), Color("9be49f"), "cheaper reads green")
	else:
		assert_eq(view._pip_row.generic_override, card.data.generic_cost - 1)
		assert_eq(view._pip_row.number_color, Color("9be49f"))
	assert_string_contains(BattleHud.now_line(card, game), "costs %d (printed %d)" % [card.data.energy_value() - 1, card.data.energy_value()])
	# dearer reads red
	game.players[0].modifiers.add(CardBuilder.modifier(Modifier.Kind.COST_CHANGE, 3))
	view.apply_instance(card, game)
	assert_eq(view.current_cost, card.data.energy_value() + 2)
	if view._cost_label != null:
		assert_eq(view._cost_label.get_theme_color("font_color"), Color("ff8080"))


func test_a_zone_rule_pump_shows_in_hand_in_green() -> void:
	var game: GameState = _game()
	var card: CardInstance = _unit(game)
	game.players[0].modifiers.add(CardBuilder.modifier(Modifier.Kind.STAT_CHANGE, 1, Modifier.ANY_COLOR, 1))
	var view: CardView = CardView.create(card.data, CardView.Mode.FULL)
	add_child_autofree(view)
	view.apply_instance(card, game)
	assert_eq(view._attack_label.text.split("/")[0], str(card.data.attack + 1))
	assert_eq(view._attack_label.get_theme_color("font_color"), Color("9be49f"), "better reads green")
	# the hovered hand card is rebuilt whole and keeps the live numbers (set_mode re-applies the last instance)
	view.set_mode(CardView.Mode.COMPACT)
	view.set_mode(CardView.Mode.FULL)
	assert_eq(view._attack_label.text.split("/")[0], str(card.data.attack + 1), "the rebuilt face keeps the live attack")
	assert_eq(view.current_cost, card.data.energy_value(), "and the live cost")
