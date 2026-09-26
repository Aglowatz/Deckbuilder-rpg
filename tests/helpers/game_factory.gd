class_name GameFactory
extends RefCounted
## Test helpers for building games and putting cards exactly where a test needs them.

const A: Affinity.Type = Affinity.Type.A
const B: Affinity.Type = Affinity.Type.B
const NO_PIPS: Array[Affinity.Type] = []


static func land(color: Affinity.Type = Affinity.Type.A) -> CardData:
	return CardBuilder.land(color)


static func vanilla(power: int, toughness: int, cost: int = 1, color: Affinity.Type = Affinity.Type.A, keywords: Array[CardEnums.Keyword] = []) -> CardData:
	var id: String = "vanilla_%d_%d_%d" % [power, toughness, cost]
	return CardBuilder.creature(id, id, color, cost, NO_PIPS, power, toughness, keywords)


## A legal-size deck: `lands` basic lands of `color` plus copies of `spell` (or a filler
## creature) up to `size` cards.
static func make_deck(spell: CardData = null, lands: int = 20, size: int = 45, color: Affinity.Type = Affinity.Type.A) -> Deck:
	var deck: Deck = Deck.new()
	var land_card: CardData = land(color)
	var filler: CardData = spell if spell != null else vanilla(1, 1, 1, color)
	for i: int in range(lands):
		deck.cards.append(land_card)
	while deck.cards.size() < size:
		deck.cards.append(filler)
	return deck


## Fully started game with both hands kept; player 0 is on turn 1, MAIN1.
static func new_game(seed_value: int = 1, deck_a: Deck = null, deck_b: Deck = null, options: GameOptions = null) -> GameState:
	var opts: GameOptions = options if options != null else GameOptions.new()
	if opts.rng_seed == 0:
		opts.rng_seed = seed_value
	var game: GameState = GameState.new(opts)
	game.add_player(PlayerSetup.create(deck_a if deck_a != null else make_deck(), null, [], "P0"))
	game.add_player(PlayerSetup.create(deck_b if deck_b != null else make_deck(), null, [], "P1"))
	game.start()
	while game.stage == GameState.Stage.MULLIGAN:
		game.keep_hand(game.awaiting_player())
	return game


## A game with empty hands/lands so a test controls every card.
static func blank_game(seed_value: int = 1) -> GameState:
	var game: GameState = new_game(seed_value)
	for player: PlayerState in game.players:
		player.hand.clear()
	return game


static func add_to_hand(game: GameState, player_index: int, data: CardData) -> CardInstance:
	var card: CardInstance = game.create_instance(data, player_index)
	game.players[player_index].hand.append(card)
	return card


static func add_land(game: GameState, player_index: int, data: CardData = null) -> CardInstance:
	var card: CardInstance = game.create_instance(data if data != null else land(), player_index)
	game.players[player_index].lands.append(card)
	return card


static func add_lands(game: GameState, player_index: int, count: int, color: Affinity.Type = Affinity.Type.A) -> void:
	for i: int in range(count):
		add_land(game, player_index, land(color))


## Puts a permanent straight onto the battlefield, ready to attack unless `ready` is false.
static func add_to_battlefield(game: GameState, player_index: int, data: CardData, ready: bool = true) -> CardInstance:
	var card: CardInstance = game.create_instance(data, player_index)
	game.players[player_index].battlefield.append(card)
	card.summoning_sick = not ready
	return card


## Passes phases until the given player's next turn starts (or the game ends).
static func pass_turn(game: GameState) -> void:
	var start_turn: int = game.turn
	var guard: int = 0
	while game.turn == start_turn and not game.is_over() and guard < 20:
		guard += 1
		if game.pending_discard > 0:
			var uids: Array[int] = []
			var hand: Array[CardInstance] = game.players[game.active].hand
			for i: int in range(game.pending_discard):
				uids.append(hand[i].uid)
			game.discard_for_hand_size(game.active, uids)
		else:
			game.advance_phase()


static func event_types(game: GameState) -> Array[GameEvent.Type]:
	var result: Array[GameEvent.Type] = []
	for event: GameEvent in game.events:
		result.append(event.type)
	return result


static func count_events(game: GameState, type: GameEvent.Type) -> int:
	var count: int = 0
	for event: GameEvent in game.events:
		if event.type == type:
			count += 1
	return count
