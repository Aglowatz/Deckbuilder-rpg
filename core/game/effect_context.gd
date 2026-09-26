class_name EffectContext
extends RefCounted
## Who/what an effect is resolving for.

## Card the effect belongs to (0 for modifier-sourced effects).
var source_uid: int = 0
## Player who controls the effect.
var controller: int = 0
## Card that caused the trigger (damage source, attacker, blocked attacker, cast creature...).
var trigger_uid: int = 0
## Target picked by the acting player at cast/activation time (Targets ref, 0 = none).
var chosen: int = 0


static func make(source: int, controlling_player: int, triggering_uid: int = 0, chosen_target: int = 0) -> EffectContext:
	var ctx: EffectContext = EffectContext.new()
	ctx.source_uid = source
	ctx.controller = controlling_player
	ctx.trigger_uid = triggering_uid
	ctx.chosen = chosen_target
	return ctx
