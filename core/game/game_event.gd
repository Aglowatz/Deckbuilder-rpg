class_name GameEvent
extends RefCounted
## One typed entry in the game's event log. The future UI animates purely from these.
## `card` is a card uid, `other` is a card uid or a Targets ref, `amount` is a delta or
## count, `value` is a resulting total (e.g. new HP).

enum Type {
	GAME_STARTED,
	HAND_SMOOTHED,
	MULLIGAN_TAKEN,
	HAND_KEPT,
	TURN_STARTED,
	PHASE_CHANGED,
	CARD_DRAWN,
	CARD_TOSSED,
	CARD_BURIED,
	INFRASTRUCTURE_PLAYED,
	ENERGY_SPENT,
	CARD_PLAYED,
	PERMANENT_ENTERED,
	TRAP_SET,
	TRAP_TRIGGERED,
	ABILITY_ACTIVATED,
	EFFECT_TRIGGERED,
	ATTACKERS_DECLARED,
	BLOCKER_ASSIGNED,
	DAMAGE_DEALT,
	HP_CHANGED,
	UNIT_DIED,
	CARD_SENT_BACK,
	TOKEN_CREATED,
	STATS_CHANGED,
	KEYWORD_GRANTED,
	DAMAGE_HEALED,
	DAMAGE_CLEARED,
	PLAYER_LOST,
	GAME_OVER,
	## Brief 14. `card` = the resource card uid, `amount` = how many were created, `value` = the ResourceKind.
	RESOURCE_CREATED,
	RESOURCE_USED,
	RESOURCE_REMOVED,
	ENERGY_ADDED,
	GARBAGE_EATEN,
	UNIT_ATTACHED,
	CARD_SHREDDED,
	CONTROL_CHANGED,
	UNIT_PLATED,
	PROCESSING_STARTED,
	PROCESSING_RESOLVED,
	COIN_FLIPPED,
	CARD_BURIED_FROM_DECK,
	UNIT_REINSTATED,
	BRAWL,
	PEEKED,
	UNIT_EXHAUSTED,
	UNIT_COPIED,
	CARD_TO_HAND,
	INFRASTRUCTURE_ENTERED,
}

var sequence: int = 0
var type: Type = Type.GAME_STARTED
var player: int = -1
var card: int = 0
var other: int = 0
var amount: int = 0
var value: int = 0
var detail: String = ""


func describe() -> String:
	return "#%d %s p=%d card=%d other=%d amount=%d value=%d %s" % [
		sequence, Type.keys()[type], player, card, other, amount, value, detail,
	]
