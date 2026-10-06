extends GutTest
## Brief 14, Part D: every card and token of the designed set can be played and resolves without errors in a headless smoke
## test, and every token can be created. (Mechanic-by-mechanic rules tests are in test_card_mechanics.gd.)

const KIND := ResourceKind.Kind


## A busy board: both players have infrastructure of every Path, units (a token among them), resources, a Wonder and a Tool,
## and Refuse Piles and decks with things worth reinstating or searching for.
func _board() -> GameState:
	CardSet.load_all()
	var game: GameState = GameFactory.blank_game(11)
	for player_index: int in range(2):
		for path: Affinity.Type in Affinity.colored_types():
			GameFactory.add_infrastructure_cards(game, player_index, 2, path)
		GameFactory.add_infrastructure(game, player_index, CardSet.card("INF-11"))
		GameFactory.add_infrastructure(game, player_index, CardSet.card("INF-11"))
		for stats: Array in [[2, 2], [3, 3], [1, 1], [5, 5]]:
			GameFactory.add_to_field(game, player_index, GameFactory.vanilla(int(stats[0]), int(stats[1])))
		game.create_token(player_index, CardSet.card("T-02"))
		for kind: ResourceKind.Kind in ResourceKind.all():
			ResourceRules.create(game, player_index, kind, 3)
		for id: String in ["R-01", "N-01", "G-01", "B-05", "C-03"]:
			var dead: CardInstance = game.create_instance(CardSet.card(id), player_index)
			game.players[player_index].refuse_pile.append(dead)
		for id: String in ["G-15", "BAS-B", "INF-05", "C-19", "BAS-R"]:
			game.players[player_index].deck.append(game.create_instance(CardSet.card(id), player_index))
	GameFactory.add_to_field(game, 1, CardSet.card("C-19"))
	GameFactory.add_to_field(game, 1, CardSet.card("G-01"))
	GameFactory.add_to_field(game, 1, CardSet.card("C-12"))
	for i: int in range(3):
		game.players[0].hand.append(game.create_instance(GameFactory.vanilla(1, 1), 0))
	return game


func _play_from_hand(game: GameState, card: CardInstance) -> bool:
	if card.data.is_infrastructure():
		return game.play_infrastructure(card.owner, card.uid)
	for action: GameAction in game.legal_actions():
		if action.type == GameAction.Type.PLAY and action.card_uid == card.uid:
			return game.apply_action(action)
	return false


func _opponent_turn(game: GameState) -> void:
	# The opponent plays a unit, a Wonder, a Tool, an infrastructure and a token maker, then attacks with everything.
	GameFactory.pass_turn(game)
	if game.is_over() or game.active != 1:
		return
	for id: String in ["C-02", "C-21", "C-11", "BAS-B", "C-22"]:
		var held: CardInstance = GameFactory.add_to_hand(game, 1, CardSet.card(id))
		_play_from_hand(game, held)
	game.advance_phase()
	var attackers: Array[int] = []
	for unit: CardInstance in game.possible_attackers(1):
		attackers.append(unit.uid)
	if not attackers.is_empty():
		game.declare_attackers(attackers)
		if game.combat_step == GameState.CombatStep.DECLARE_BLOCKERS:
			game.declare_blockers({})
	GameFactory.pass_turn(game)


func test_every_card_can_be_played_and_resolves_without_errors() -> void:
	var unplayable: Array[String] = []
	for data: CardData in CardSet.all_cards():
		var game: GameState = _board()
		var card: CardInstance = GameFactory.add_to_hand(game, 0, data)
		if not _play_from_hand(game, card):
			unplayable.append("%s %s" % [data.id, data.display_name])
			continue
		# Use whatever abilities it gave the field, then let two turns pass (start/end of turn, combat, Processing, traps).
		var uses: int = 0
		for action: GameAction in game.legal_actions():
			if action.type == GameAction.Type.ACTIVATE_ABILITY and uses < 4:
				if game.apply_action(action):
					uses += 1
		game.check_state()
		_opponent_turn(game)
		GameFactory.pass_turn(game)
		assert_false(game.players[0].field.has(null), "%s left a null on the field" % data.id)
	assert_eq(unplayable, [] as Array[String], "cards that had no legal play on the busy board")


func test_every_token_can_be_created() -> void:
	var failed: Array[String] = []
	for data: CardData in CardSet.all_tokens():
		var game: GameState = _board()
		var before: int = game.players[0].field.size() + game.players[0].resources.size()
		if data.is_resource():
			ResourceRules.create(game, 0, data.resource_kind as ResourceKind.Kind, 1)
		elif data.type == CardEnums.CardType.TOKEN:
			game.shuffle_tokens_into_deck(0, data, 1, 1)
			game.players[0].deck.back().owner = 0
		else:
			var token: CardInstance = game.create_token(0, data)
			assert_true(token.is_token(), "%s is a token" % data.id)
			assert_true(game.players[0].field.has(token), "%s entered the field" % data.id)
			assert_eq(game.get_attack(token) + game.get_defense(token) > 0 or data.id == "T-08", true, "%s has stats" % data.id)
		var after: int = game.players[0].field.size() + game.players[0].resources.size()
		if data.type != CardEnums.CardType.TOKEN and after <= before:
			failed.append(data.id)
		game.check_state()
	assert_eq(failed, [] as Array[String], "tokens that did not appear")
