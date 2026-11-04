extends CardTestBase
## Fix pass Nov 4 (Part 1.1): Peek waits for the player. The top N cards are shown, each goes Top or Bottom, the cards kept on top
## go back in the order chosen, and the rest of the ability ("then draw a card") runs after the choice. Every Peek card is covered.


func _peek_game() -> GameState:
	var game: GameState = _game()
	game.interactive_peek[0] = true
	_energy(game)
	return game


## Puts `ids` on top of player 0's deck: the first id ends up as the top card.
func _stack(game: GameState, ids: Array[String]) -> Array[CardInstance]:
	var cards: Array[CardInstance] = []
	for i: int in range(ids.size() - 1, -1, -1):
		var card: CardInstance = game.create_instance(CardSet.card(ids[i]), 0)
		game.players[0].deck.append(card)
		cards.push_front(card)
	return cards


func _top_ids(game: GameState, count: int) -> Array[String]:
	var deck: Array[CardInstance] = game.players[0].deck
	var ids: Array[String] = []
	for i: int in range(count):
		ids.append(deck[deck.size() - 1 - i].data.id)
	return ids


func _uids(cards: Array[CardInstance]) -> Array[int]:
	var uids: Array[int] = []
	for card: CardInstance in cards:
		uids.append(card.uid)
	return uids


func test_consult_the_cookbook_waits_then_draws_the_card_chosen_first() -> void:
	var game: GameState = _peek_game()
	var stack: Array[CardInstance] = _stack(game, ["G-01", "G-04", "B-11"])
	var hand: int = game.players[0].hand.size()
	_play(game, "G-21")
	assert_eq(game.peek_requests.size(), 1, "Peek 3 waits for the player")
	assert_eq(game.awaiting_player(), 0)
	assert_eq(game.players[0].hand.size(), hand, "the draw waits for the choice")
	assert_eq(_uids(game.peek_cards()), _uids(stack), "the top three, top card first")
	assert_false(game.apply_action(GameAction.pass_phase(0)), "nothing else happens while the Peek waits")
	# Keep the third card first, then the first; the second goes to the bottom.
	var top: Array[int] = [stack[2].uid, stack[0].uid]
	var bottom: Array[int] = [stack[1].uid]
	assert_true(game.apply_action(GameAction.peek(0, top, bottom)))
	assert_true(game.peek_requests.is_empty())
	assert_eq(game.players[0].hand.size(), hand + 1, "then draw a card")
	assert_eq(game.players[0].hand.back().uid, stack[2].uid, "the card picked first for the top is drawn")
	assert_eq(game.players[0].deck.back().uid, stack[0].uid, "the next top card is the second pick")
	assert_eq(game.players[0].deck[0].uid, stack[1].uid, "the Bottom card is under the deck")


func test_a_bad_answer_is_refused() -> void:
	var game: GameState = _peek_game()
	var stack: Array[CardInstance] = _stack(game, ["G-01", "G-04"])
	_play(game, "G-07")  # Sous Chef: enter => Peek 2, then draw
	assert_eq(game.peek_requests.size(), 1)
	assert_false(game.resolve_peek(0, [stack[0].uid] as Array[int], [] as Array[int]), "every shown card needs a place")
	assert_false(game.resolve_peek(0, [stack[0].uid, stack[0].uid] as Array[int], [] as Array[int]), "no card twice")
	assert_false(game.resolve_peek(1, [stack[0].uid] as Array[int], [stack[1].uid] as Array[int]), "only the peeking player answers")
	assert_true(game.resolve_peek(0, [] as Array[int], [stack[0].uid, stack[1].uid] as Array[int]), "both to the bottom is fine")
	assert_eq(game.players[0].deck[0].uid, stack[0].uid, "the first card sent down is the deepest")
	assert_eq(game.players[0].deck[1].uid, stack[1].uid)


func test_amuse_bouche_peek_1_keeps_the_ingredient_and_draws_after() -> void:
	var game: GameState = _peek_game()
	var stack: Array[CardInstance] = _stack(game, ["B-11", "G-01"])
	var hand: int = game.players[0].hand.size()
	_play(game, "G-34")
	assert_eq(_count(game, 0, KIND.INGREDIENT), 1, "the Ingredient comes before the Peek")
	assert_eq(game.peek_cards().size(), 1)
	assert_eq(game.peek_cards()[0].uid, stack[0].uid)
	assert_true(game.apply_action(GameAction.peek(0, [] as Array[int], [stack[0].uid] as Array[int])))
	assert_eq(game.players[0].hand.size(), hand + 1)
	assert_eq(game.players[0].hand.back().uid, stack[1].uid, "the bottomed card is skipped: the next one is drawn")


func test_every_peek_card_waits_for_the_player() -> void:
	# Courier Pigeon (enter), Banquet Hall (golem created), Spice Bazaar (activated), Cartographer's Table (start of turn).
	var game: GameState = _peek_game()
	_stack(game, ["G-01", "G-04", "B-11", "G-01", "G-04", "B-11"])
	_play(game, "C-04")
	assert_eq(game.peek_requests.size(), 1, "Courier Pigeon: Peek 1 on entering")
	var auto: Array = game.auto_peek_choice()
	assert_true(game.apply_action(GameAction.peek(0, auto[0], auto[1])))
	var bazaar: CardInstance = _field(game, 0, "INF-03")
	assert_true(_activate(game, bazaar, 1) or _activate(game, bazaar, 0), "Spice Bazaar's Peek 2 activates")
	assert_eq(game.peek_cards().size(), 2, "Spice Bazaar: Peek 2")
	auto = game.auto_peek_choice()
	assert_true(game.apply_action(GameAction.peek(0, auto[0], auto[1])))
	_field(game, 0, "C-28")
	_until_turn_of(game, 0)
	assert_eq(game.peek_requests.size(), 1, "Cartographer's Table: Peek 2 at the start of your turn")
	assert_eq(game.peek_cards().size(), 2)


func test_the_ai_and_look_ahead_copies_never_wait() -> void:
	var game: GameState = _game()
	_energy(game)
	_stack(game, ["G-01", "G-04", "B-11"])
	var hand: int = game.players[0].hand.size()
	_play(game, "G-21")
	assert_true(game.peek_requests.is_empty(), "without interactive_peek the engine sorts the cards itself")
	assert_eq(game.players[0].hand.size(), hand + 1)
	var interactive: GameState = _peek_game()
	assert_false(interactive.clone().interactive_peek[0], "a clone resolves Peeks automatically")


func test_a_peek_on_the_opponents_turn_resolves_by_itself() -> void:
	var game: GameState = _peek_game()
	_stack(game, ["G-01", "G-04"])
	game.active = 1
	assert_false(game.peek_deck(0, 2), "only the active player is asked")
	assert_true(game.peek_requests.is_empty())
