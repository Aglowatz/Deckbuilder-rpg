class_name GameEvent
extends RefCounted
## One typed entry in the game's event log. The future UI animates purely from these.
## `card` is a card uid, `other` is a card uid or a Targets ref, `amount` is a delta or
## count, `value` is a resulting total (e.g. new life).

enum Type {
	GAME_STARTED,
	HAND_SMOOTHED,
	MULLIGAN_TAKEN,
	HAND_KEPT,
	TURN_STARTED,
	PHASE_CHANGED,
	CARD_DRAWN,
	CARD_DISCARDED,
	CARD_MILLED,
	INFRASTRUCTURE_PLAYED,
	ENERGY_SPENT,
	CARD_CAST,
	PERMANENT_ENTERED,
	TRAP_SET,
	TRAP_TRIGGERED,
	ABILITY_ACTIVATED,
	EFFECT_TRIGGERED,
	ATTACKERS_DECLARED,
	BLOCKER_ASSIGNED,
	DAMAGE_DEALT,
	LIFE_CHANGED,
	CREATURE_DIED,
	CARD_RETURNED_TO_HAND,
	TOKEN_CREATED,
	STATS_CHANGED,
	KEYWORD_GRANTED,
	DAMAGE_HEALED,
	DAMAGE_CLEARED,
	PLAYER_LOST,
	GAME_OVER,
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
