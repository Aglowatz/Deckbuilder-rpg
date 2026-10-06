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
	## Brief 14: activate a scripted ability (`card_uid` = the permanent, `effect_index` = ability index, `targets`, `x`, `picks`).
	ACTIVATE_ABILITY,
	## Brief 14: pay 1 energy and use an Iron, Red Tape or Contract on a target unit (`effect_index` = ResourceKind).
	USE_RESOURCE,
}

var type: Type = Type.PASS
var player: int = 0
var card_uid: int = 0
var target: int = 0
## Brief 14: every chosen target in declaration order (`target` mirrors the first); `picks` choose the cards destroyed
## or used for additional costs; `x` is the X of "use X Ingredients".
var targets: Array[int] = []
var picks: Array[int] = []
var x: int = 0
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
	if target_ref != 0:
		action.targets = [target_ref]
	return action


static func activate(acting_player: int, uid: int, index: int, target_ref: int = 0) -> GameAction:
	var action: GameAction = make(Type.ACTIVATE, acting_player)
	action.card_uid = uid
	action.effect_index = index
	action.target = target_ref
	return action


## Brief 14: activate a scripted ability of a permanent.
static func activate_ability(acting_player: int, uid: int, ability_index: int, chosen: Array[int] = [], x_value: int = 0) -> GameAction:
	var action: GameAction = make(Type.ACTIVATE_ABILITY, acting_player)
	action.card_uid = uid
	action.effect_index = ability_index
	action.targets = chosen.duplicate()
	action.target = chosen[0] if not chosen.is_empty() else 0
	action.x = x_value
	return action


## Brief 14: use a resource ability on `target_uid` (a unit).
static func use_resource(acting_player: int, kind: ResourceKind.Kind, target_uid: int) -> GameAction:
	var action: GameAction = make(Type.USE_RESOURCE, acting_player)
	action.effect_index = int(kind)
	action.target = target_uid
	return action


func describe() -> String:
	return "%s p=%d card=%d target=%d uids=%s blocks=%s" % [
		Type.keys()[type], player, card_uid, target, str(uids), str(blocks),
	]
