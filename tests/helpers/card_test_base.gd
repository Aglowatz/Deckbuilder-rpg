class_name CardTestBase
extends GutTest
## Shared helpers for tests of the designed card set (`CardSet`): build games, put cards where a test needs them, play them.

const KIND := ResourceKind.Kind

var _seed: int = 1


func _game() -> GameState:
	CardSet.load_all()
	_seed += 1
	var game: GameState = GameFactory.blank_game(_seed)
	return game


## Plenty of energy of every Path for `player_index` (basic infrastructure put straight onto the field: no resources created).
func _energy(game: GameState, player_index: int = 0, each: int = 3) -> void:
	for path: Affinity.Type in Affinity.colored_types():
		GameFactory.add_infrastructure_cards(game, player_index, each, path)


func _field(game: GameState, owner: int, id: String) -> CardInstance:
	return GameFactory.add_to_field(game, owner, CardSet.card(id))


func _unit(game: GameState, owner: int, attack: int, defense: int, keywords: Array[CardEnums.Keyword] = []) -> CardInstance:
	return GameFactory.add_to_field(game, owner, GameFactory.vanilla(attack, defense, 1, Affinity.Type.BEEFCAKE, keywords))


func _give(game: GameState, owner: int, kind: ResourceKind.Kind, count: int = 1) -> void:
	ResourceRules.create(game, owner, kind, count)


## Puts a card in the player's hand and plays it with the given targets.
func _play(game: GameState, id: String, targets: Array[int] = [] as Array[int], player_index: int = 0) -> CardInstance:
	var card: CardInstance = GameFactory.add_to_hand(game, player_index, CardSet.card(id))
	var first: int = targets[0] if not targets.is_empty() else 0
	var rest: Array[int] = targets.slice(1) if targets.size() > 1 else ([] as Array[int])
	assert_true(game.play_card(player_index, card.uid, first, [] as Array[int], rest), "playing %s" % id)
	return card


func _activate(game: GameState, card: CardInstance, ability_index: int = 0, targets: Array[int] = [] as Array[int], x: int = 0) -> bool:
	return game.activate_ability(card.owner, card.uid, ability_index, targets, x)


func _count(game: GameState, owner: int, kind: ResourceKind.Kind) -> int:
	return game.players[owner].count_resource(kind)


func _on_field(game: GameState, owner: int, id: String) -> Array[CardInstance]:
	var result: Array[CardInstance] = []
	for card: CardInstance in game.players[owner].field:
		if card.data.id == id:
			result.append(card)
	return result


func _refuse_ids(game: GameState, owner: int) -> Array[String]:
	var ids: Array[String] = []
	for card: CardInstance in game.players[owner].refuse_pile:
		ids.append(card.data.id)
	return ids


## Adds a card straight to a Refuse Pile.
func _bury(game: GameState, owner: int, id: String) -> CardInstance:
	var card: CardInstance = game.create_instance(CardSet.card(id), owner)
	game.players[owner].refuse_pile.append(card)
	return card


## Passes at least one turn, then more until it is `player_index`'s turn again (the AI-free way to make time pass).
func _until_turn_of(game: GameState, player_index: int) -> void:
	var guard: int = 0
	GameFactory.pass_turn(game)
	while game.active != player_index and not game.is_over() and guard < 8:
		guard += 1
		GameFactory.pass_turn(game)
