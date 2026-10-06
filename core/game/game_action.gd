class_name GameAction
extends RefCounted
## A single decision a player can make. Produced by GameState.legal_actions() and consumed
## by GameState.apply_action(); the AI and the future UI both speak this vocabulary.

enum Type {
	PASS,
	PLAY_INFRASTRUCTURE,
	PLAY,
	ACTIVATE,
	DECLARE_ATTACKERS,
	DECLARE_BLOCKERS,
	TOSS,
	MULLIGAN,
	KEEP_HAND,
}

var type: Type = Type.PASS
var player: int = 0
var card_uid: int = 0
var target: int = 0
var effect_index: int = 0
## Attacker uids (DECLARE_ATTACKERS) or discarded card uids (DISCARD).
var uids: Array[int] = []
## attacker uid -> blocker uid (DECLARE_BLOCKERS).
var blocks: Dictionary = {}


static func make(action_type: Type, acting_player: int) -> GameAction:
	var action: GameAction = GameAction.new()
	action.type = action_type
	action.player = acting_player
	return action


static func pass_phase(acting_player: int) -> GameAction:
	return make(Type.PASS, acting_player)


static func play_infrastructure(acting_player: int, uid: int) -> GameAction:
	var action: GameAction = make(Type.PLAY_INFRASTRUCTURE, acting_player)
	action.card_uid = uid
	return action


static func play_card(acting_player: int, uid: int, target_ref: int = 0) -> GameAction:
	var action: GameAction = make(Type.PLAY, acting_player)
	action.card_uid = uid
	action.target = target_ref
	return action


static func activate(acting_player: int, uid: int, index: int, target_ref: int = 0) -> GameAction:
	var action: GameAction = make(Type.ACTIVATE, acting_player)
	action.card_uid = uid
	action.effect_index = index
	action.target = target_ref
	return action


func describe() -> String:
	return "%s p=%d card=%d target=%d uids=%s blocks=%s" % [
		Type.keys()[type], player, card_uid, target, str(uids), str(blocks),
	]
