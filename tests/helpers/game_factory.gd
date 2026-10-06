class_name GameFactory
extends RefCounted
## Test helpers for building games and putting cards exactly where a test needs them.

const A: Affinity.Type = Affinity.Type.BEEFCAKE
const B: Affinity.Type = Affinity.Type.GOURMAND
const NO_PIPS: Array[Affinity.Type] = []


static func infra(color: Affinity.Type = Affinity.Type.BEEFCAKE) -> CardData:
	return CardBuilder.infra(color)


static func vanilla(attack: int, defense: int, cost: int = 1, color: Affinity.Type = Affinity.Type.BEEFCAKE, keywords: Array[CardEnums.Keyword] = []) -> CardData:
	var id: String = "vanilla_%d_%d_%d" % [attack, defense, cost]
	return CardBuilder.unit(id, id, color, cost, NO_PIPS, attack, defense, keywords)


## A legal-size deck: `infrastructure` basic infrastructure of `color` plus copies of `spell` (or a filler
## unit) up to `size` cards.
static func make_deck(spell: CardData = null, infrastructure: int = 20, size: int = 45, color: Affinity.Type = Affinity.Type.BEEFCAKE) -> Deck:
	var deck: Deck = Deck.new()
	var infrastructure_card: CardData = infra(color)
	var filler: CardData = spell if spell != null else vanilla(1, 1, 1, color)
	for i: int in range(infrastructure):
		deck.cards.append(infrastructure_card)
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


## A game with empty hands/infrastructure so a test controls every card.
static func blank_game(seed_value: int = 1) -> GameState:
	var game: GameState = new_game(seed_value)
	for player: PlayerState in game.players:
		player.hand.clear()
	return game


static func add_to_hand(game: GameState, player_index: int, data: CardData) -> CardInstance:
	var card: CardInstance = game.create_instance(data, player_index)
	game.players[player_index].hand.append(card)
	return card


static func add_infrastructure(game: GameState, player_index: int, data: CardData = null) -> CardInstance:
	var card: CardInstance = game.create_instance(data if data != null else infra(), player_index)
	game.players[player_index].infrastructure.append(card)
	return card


static func add_infrastructure_cards(game: GameState, player_index: int, count: int, color: Affinity.Type = Affinity.Type.BEEFCAKE) -> void:
	for i: int in range(count):
		add_infrastructure(game, player_index, infra(color))


## Puts a permanent straight onto the field, ready to attack unless `ready` is false.
static func add_to_field(game: GameState, player_index: int, data: CardData, ready: bool = true) -> CardInstance:
	var card: CardInstance = game.create_instance(data, player_index)
	game.players[player_index].field.append(card)
	card.summoning_sick = not ready
	return card


## Passes phases until the given player's next turn starts (or the game ends).
static func pass_turn(game: GameState) -> void:
	var start_turn: int = game.turn
	var guard: int = 0
	while game.turn == start_turn and not game.is_over() and guard < 20:
		guard += 1
		if game.pending_toss > 0:
			var uids: Array[int] = []
			var hand: Array[CardInstance] = game.players[game.active].hand
			for i: int in range(game.pending_toss):
				uids.append(hand[i].uid)
			game.toss_for_hand_size(game.active, uids)
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
