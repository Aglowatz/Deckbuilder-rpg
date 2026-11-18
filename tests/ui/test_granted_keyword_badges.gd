extends CardTestBase
## Nov 18 day, Part 1.2: a keyword a unit gets from a Tool, spell, aura or rule shows on its field card as a printed keyword does (a chip /
## badge, ringed green-gold), its hover and the battle preview say where it came from, and it goes away when the effect ends.


func _board(game: GameState) -> BattleBoard:
	var fx: BattleFX = BattleFX.new()
	add_child_autofree(fx)
	var board: BattleBoard = BattleBoard.new()
	add_child_autofree(board)
	board.setup(game, fx)
	board.speed = 50.0
	board.sync_state(false)
	return board


func _granted_names(view: CardView) -> Array[String]:
	var names: Array[String] = []
	for entry: Dictionary in view.granted_keywords():
		names.append(KeywordInfo.keyword_name(entry["keyword"] as CardEnums.Keyword))
	return names


func test_the_pen_shows_toxic_on_the_unit_and_says_where_it_came_from() -> void:
	var game: GameState = _game()
	_energy(game, 0, 6)
	var unit: CardInstance = _unit(game, 0, 2, 2)
	var board: BattleBoard = _board(game)
	assert_eq(_granted_names(board.view_for(unit.uid)).size(), 0, "nothing granted yet")
	var pen: CardInstance = _field(game, 0, "N-08")
	assert_true(game.attach_tool(pen, unit))
	assert_true(game.unit_has_keyword(unit, CardEnums.Keyword.TOXIC), "the pen gives Toxic")
	board.sync_state(false)
	var view: CardView = board.view_for(unit.uid)
	assert_eq(_granted_names(view), ["Toxic"] as Array[String])
	assert_eq(CardView.granted_title(view.granted_keywords()[0]), "Toxic (from Corporate-Approved Pen)")
	assert_true(view.get_node_or_null("GrantedChip_Toxic") != null, "a Toxic chip on the field card")
	var entries: Array[Array] = StatusInfo.entries(game, unit)
	var titles: Array[String] = []
	for entry: Array in entries:
		titles.append(str(entry[0]))
	assert_has(titles, "Toxic (from Corporate-Approved Pen)", "the hover preview says where it came from")


func test_the_badge_goes_when_the_tool_goes() -> void:
	var game: GameState = _game()
	var unit: CardInstance = _unit(game, 0, 2, 2)
	var pen: CardInstance = _field(game, 0, "N-08")
	game.attach_tool(pen, unit)
	var board: BattleBoard = _board(game)
	assert_eq(_granted_names(board.view_for(unit.uid)), ["Toxic"] as Array[String])
	game.destroy_card(pen)
	board.sync_state(false)
	var view: CardView = board.view_for(unit.uid)
	assert_eq(_granted_names(view).size(), 0, "badge gone with the Tool")
	assert_null(view.get_node_or_null("GrantedChip_Toxic"))


func test_a_spell_keyword_until_end_of_turn_shows_and_goes() -> void:
	var game: GameState = _game()
	var unit: CardInstance = _unit(game, 0, 2, 2)
	game.grant_keyword(unit, CardEnums.Keyword.FLYING, true, "Test Spell")
	var board: BattleBoard = _board(game)
	var view: CardView = board.view_for(unit.uid)
	assert_eq(_granted_names(view), ["Flying"] as Array[String])
	assert_eq(CardView.granted_title(view.granted_keywords()[0]), "Flying (from Test Spell, this turn)")
	_until_turn_of(game, 1)
	board.sync_state(false)
	assert_eq(_granted_names(board.view_for(unit.uid)).size(), 0, "gone at the end of the turn")


func test_an_aura_keyword_shows_with_its_source() -> void:
	var game: GameState = _game()
	var rat: CardInstance = game.create_instance(TokenRegistry.data("T-02"), 0)
	game.players[0].field.append(rat)
	_field(game, 0, "NR-16")
	var sources: Array[Dictionary] = game.granted_keywords_of(rat)
	assert_eq(sources.size(), 1, "Necro Rat gives Rat tokens Toxic")
	assert_eq(sources[0]["keyword"], CardEnums.Keyword.TOXIC)
	assert_eq(str(sources[0]["source"]), "Necro Rat, Chairman of the Sewer Board")


func test_printed_keywords_are_not_shown_twice() -> void:
	var game: GameState = _game()
	var unit: CardInstance = _unit(game, 0, 2, 2, [CardEnums.Keyword.TOXIC] as Array[CardEnums.Keyword])
	var pen: CardInstance = _field(game, 0, "N-08")
	game.attach_tool(pen, unit)
	assert_eq(game.granted_keywords_of(unit).size(), 0, "Toxic is printed: no granted badge")
