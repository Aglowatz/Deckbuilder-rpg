class_name CardAbility
extends RefCounted
## One parsed ability of a card script (see docs/card_pipeline.md). A card is a list of these.
## Built by `ScriptParser`; interpreted by `AbilityRunner`; the static kinds are read by `StaticEffects`.

enum Kind {
	## "When this unit enters" (also Wonders, Tools, Infrastructure). Targets are chosen when the card is played.
	ENTER,
	## "When this dies."
	DIE,
	## A Spell's effect when played.
	PLAY,
	## An activated ability (your turn only), possibly with costs.
	ACT,
	## "Exhaust: attach to target unit you control" (a Tool); extra costs allowed.
	ATTACH,
	## Continuous effect on the source itself (flags, stat formulas).
	STATIC,
	## Continuous effect on every card matching `aura_spec` (relative to the source's controller).
	AURA,
	## Continuous effect on the unit this Tool is attached to.
	HOST,
	## At the start of your turn / end of your turn / beginning of combat on your turn.
	START_OF_TURN,
	END_OF_TURN,
	BEGINNING_OF_COMBAT,
	## "Whenever this unit attacks" / "Whenever this unit blocks".
	ATTACK,
	BLOCK,
	## "Whenever/When <event>" (from the field).
	WHEN,
	## A Trap's condition (set face-down).
	TRAP,
	## "As an additional cost to play this, ..."
	PLAY_COST,
	## A cost change: for a card in hand (`cost_set`) or an effect on cards the opponent plays (`cost_plus`).
	COST_MOD,
	## "When drawn" (Clause tokens).
	DRAWN,
}

## A target declaration: `t=unit.opp.atk<=3`. `max_count` > 1 means "any number up to N of target ...".
class TargetDecl:
	extends RefCounted
	var name: String = "t"
	var spec: TargetSpec
	var max_count: int = 1


## A cost: exhaust, overexert, pay, use, eat, destroy, destroy_self, use_token.
class Cost:
	extends RefCounted
	var kind: String = ""
	## exhaust/overexert/destroy_self: none. pay: generic (int) and pips (Array[Affinity.Type]).
	var generic: int = 0
	var pips: Array[Affinity.Type] = []
	## use: resource kinds (any one of them), eat: unused.
	var resource_kinds: Array[ResourceKind.Kind] = []
	## How many (use / eat / destroy). `x_count` means "X" (chosen when activating).
	var count: int = 1
	var x_count: bool = false
	## destroy: what may be destroyed.
	var spec: TargetSpec


## One effect call: `name(arg, arg, ...)`. Args are ints, words (String), nested `Fx`, or `FxBlock`.
class Fx:
	extends RefCounted
	var name: String = ""
	var args: Array = []
	var text: String = ""


## A `{ effect; effect }` argument (the branches of if/flip/choose, the body of may/processing).
class FxBlock:
	extends RefCounted
	var effects: Array[Fx] = []


var kind: Kind = Kind.ENTER
## WHEN / TRAP: the event name and its filters (`unit_dies:mine,other`).
var event: String = ""
var event_filters: Array[String] = []
var targets: Array[TargetDecl] = []
var costs: Array[Cost] = []
## An optional condition (`? count(garbage)==0`), a parsed Fx tree; null when always.
var condition: Fx = null
var condition_negated: bool = false
var effects: Array[Fx] = []
## "Do this only once per turn."
var once: bool = false
## AURA: which cards it applies to.
var aura_spec: TargetSpec
var index: int = 0
var source_text: String = ""


func is_activated() -> bool:
	return kind == Kind.ACT or kind == Kind.ATTACH


func is_static_kind() -> bool:
	return kind == Kind.STATIC or kind == Kind.AURA or kind == Kind.HOST or kind == Kind.COST_MOD


func has_cost(cost_kind: String) -> bool:
	for cost: Cost in costs:
		if cost.kind == cost_kind:
			return true
	return false


## True when this ability lists `exhaust` or `overexert` as a cost.
func taps_source() -> bool:
	return has_cost("exhaust") or has_cost("overexert")
