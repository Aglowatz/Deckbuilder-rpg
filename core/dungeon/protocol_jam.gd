class_name ProtocolJam
extends RefCounted
## Dr. Siphon's Boss Protocols and Elowen's answer to them (Oct 21; the Dungeon List's D-LAB row and the Token List's T-24/T-25).
## The four Protocols are one-sided encounter rules on Siphon's fight (data/encounters/modifiers.json, keyed by his battle name):
## Augmentation (his units +2/+2), Replication (a Failed Experiment, T-25, at the start of each of his turns), Extraction (at the start of
## his turn he gains one Resource of each Path and you lose 1 life) and Containment (on your side: your first card each turn costs 2 more).
## Every modifier carries its Protocol's name as its label.
##
## Elowen Vey, Defector (T-24) stands on the player's field when she was rescued in that run. Inside Knowledge: at the start of her side's
## turn one Protocol is chosen and jammed (its modifiers are parked on both seats, `ModifierSet.park`) until her side's next turn. The
## player picks it in the battle HUD (`request`); otherwise she picks the one hurting most right now (`pick`). Sabotage: Failed
## Experiments her opponent creates enter exhausted.

const ALLY_TOKEN_ID: String = "T-24"
const EXPERIMENT_TOKEN_ID: String = "T-25"
const PROTOCOLS: Array[String] = ["Augmentation", "Replication", "Extraction", "Containment"]


## The Protocols in play in this game (on either seat, jammed or not), in `PROTOCOLS` order.
static func available(state: GameState) -> Array[String]:
	var result: Array[String] = []
	for label: String in PROTOCOLS:
		for player: PlayerState in state.players:
			if _labelled(player.modifiers.modifiers, label) or _labelled(player.modifiers.parked, label):
				if not result.has(label):
					result.append(label)
	return result


static func _labelled(modifiers: Array[Modifier], label: String) -> bool:
	for modifier: Modifier in modifiers:
		if modifier.label == label:
			return true
	return false


## True when `player_index` has Elowen on the field.
static func has_ally(state: GameState, player_index: int) -> bool:
	for card: CardInstance in state.players[player_index].field:
		if card.data.id == ALLY_TOKEN_ID:
			return true
	return false


static func on_turn_start(state: GameState, active: int) -> void:
	if state.jam_player == active:
		_release(state)
	if not has_ally(state, active):
		return
	var options: Array[String] = available(state)
	if options.is_empty():
		return
	var label: String = state.jam_request if options.has(state.jam_request) else pick(state, active, options)
	_jam(state, active, label)


## Switches the jam to `label` during the jamming side's own turn (the player's choice in the HUD). Returns true when it changed.
static func request(state: GameState, player_index: int, label: String) -> bool:
	state.jam_request = label
	if state.active != player_index or not has_ally(state, player_index) or not available(state).has(label) or state.jammed_label == label:
		return false
	_release(state)
	_jam(state, player_index, label)
	return true


static func _jam(state: GameState, player_index: int, label: String) -> void:
	for player: PlayerState in state.players:
		player.modifiers.park(label)
	state.jam_player = player_index
	state.jammed_label = label
	_stats_changed(state)


static func _release(state: GameState) -> void:
	for player: PlayerState in state.players:
		player.modifiers.unpark_all()
	state.jam_player = -1
	state.jammed_label = ""
	_stats_changed(state)


## A jam can change every unit's stats (Augmentation): the board redraws them.
static func _stats_changed(state: GameState) -> void:
	for card: CardInstance in state.all_units():
		state.emit_event(GameEvent.Type.STATS_CHANGED, card.owner, card.uid, 0, 0, 0)


## The Protocol hurting most right now: Augmentation once Siphon has two or more units out, Extraction when the player is low, else
## Replication (a fresh 3/3 every turn), then Containment.
static func pick(state: GameState, player_index: int, options: Array[String]) -> String:
	var foe: PlayerState = state.players[1 - player_index]
	var best: String = options[0]
	var best_score: int = -1
	for label: String in options:
		var score: int = 0
		match label:
			"Augmentation":
				score = 2 * foe.units().size()
			"Replication":
				score = 3
			"Extraction":
				score = 2 + (3 if state.players[player_index].hp <= 8 else 0)
			"Containment":
				score = 1
		if score > best_score:
			best = label
			best_score = score
	return best


## Sabotage: a Failed Experiment created for the side facing Elowen enters exhausted.
static func on_token_created(state: GameState, token: CardInstance) -> void:
	if token.data.id == EXPERIMENT_TOKEN_ID and has_ally(state, 1 - token.owner):
		token.exhausted = true
