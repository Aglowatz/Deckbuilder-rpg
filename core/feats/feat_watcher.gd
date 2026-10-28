class_name FeatWatcher
extends RefCounted
## Overnight Oct 27-28, Part 3: watches one live battle's events (`GameState.event_emitted`, which the battle UI already observes) and keeps
## the "fun card moment" highs for the player's side: the biggest attack one of their units reached, the most Golems they controlled at once,
## the most Red Tape held at once, the most garbage eaten in one of their turns, the most enemy units destroyed by one card they played.
## Reads the rules engine, never changes it. `moments()` is what `FeatTracker.on_battle` scores.

const PLAYER: int = 0

var _game: GameState
var _moments: Dictionary = {"max_attack": 0, "max_golems": 0, "max_red_tape": 0, "max_garbage_turn": 0, "max_destroyed_by_card": 0}
var _garbage_this_turn: int = 0
var _card_live: bool = false
var _deaths_since_card: int = 0


func attach(game: GameState) -> void:
	detach()
	_game = game
	if _game != null and not _game.event_emitted.is_connected(_on_event):
		_game.event_emitted.connect(_on_event)


func detach() -> void:
	if _game != null and _game.event_emitted.is_connected(_on_event):
		_game.event_emitted.disconnect(_on_event)
	_game = null


func moments() -> Dictionary:
	return _moments.duplicate()


func _on_event(event: GameEvent) -> void:
	if _game == null or _game.players.size() <= PLAYER:
		return
	match event.type:
		GameEvent.Type.TURN_STARTED:
			_garbage_this_turn = 0
			_card_live = false
		GameEvent.Type.PHASE_CHANGED:
			_card_live = false
		GameEvent.Type.GARBAGE_EATEN:
			if event.player == PLAYER:
				_garbage_this_turn += 1
				_raise("max_garbage_turn", _garbage_this_turn)
		GameEvent.Type.CARD_PLAYED:
			if event.player == PLAYER:
				_card_live = true
				_deaths_since_card = 0
			else:
				_card_live = false
		GameEvent.Type.UNIT_DIED:
			if _card_live and event.player != PLAYER:
				_deaths_since_card += 1
				_raise("max_destroyed_by_card", _deaths_since_card)
	_scan_board()


## The board highs: a unit's attack, Golems and Red Tape under the player's control.
func _scan_board() -> void:
	var me: PlayerState = _game.players[PLAYER]
	var golems: int = 0
	for unit: CardInstance in me.units():
		_raise("max_attack", _game.get_attack(unit))
		if unit.data != null and unit.data.display_name.contains("Golem"):
			golems += 1
	_raise("max_golems", golems)
	var tape: int = 0
	for resource: CardInstance in me.resources:
		if resource.data != null and resource.data.resource_kind == ResourceKind.Kind.RED_TAPE:
			tape += 1
	_raise("max_red_tape", tape)


func _raise(key: String, value: int) -> void:
	if value > int(_moments.get(key, 0)):
		_moments[key] = value
