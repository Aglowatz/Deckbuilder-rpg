class_name AbilityContext
extends RefCounted
## Everything an ability needs while it resolves: who controls it, what triggered it, the chosen targets, script variables.

var state: GameState
var ability: CardAbility
## The card the ability belongs to (a unit, tool, wonder, trap, spell being played...). May be null.
var source: CardInstance
var controller: int = 0
## The card that caused a trigger ("trig"): the unit that died / entered / attacked...; may sit in a Refuse Pile.
var trigger: CardInstance
## The unit a Tool is attached to ("host").
var host: CardInstance
## Chosen targets by declaration name -> Array[int] refs (card uids, or Targets.player refs).
var targets: Dictionary = {}
## Script variables (`$n`, `$last`, `$used`...).
var vars: Dictionary = {}
## The X chosen for "use X Ingredients".
var x: int = 0
## Cards destroyed as costs ("$paid").
var paid: Array[CardInstance] = []
## Whether the last executed effect did something (for `ifdid`).
var last_ok: bool = true
var data: Dictionary = {}
var depth: int = 0


static func make(game: GameState, ability_: CardAbility, source_: CardInstance, controller_: int) -> AbilityContext:
	var ctx: AbilityContext = AbilityContext.new()
	ctx.state = game
	ctx.ability = ability_
	ctx.source = source_
	ctx.controller = controller_
	return ctx


func source_uid() -> int:
	return source.uid if source != null else 0


## A copy that keeps the same references (used by delayed effects).
func snapshot() -> AbilityContext:
	var copy: AbilityContext = AbilityContext.new()
	copy.state = state
	copy.ability = ability
	copy.source = source
	copy.controller = controller
	copy.trigger = trigger
	copy.host = host
	copy.targets = targets.duplicate(true)
	copy.vars = vars.duplicate()
	copy.x = x
	copy.paid = paid.duplicate()
	copy.data = data.duplicate()
	return copy


## Points the context's card references at `game`'s own instances (found by uid). Needed when a delayed effect was copied
## along with a cloned GameState (AI look-ahead): the stored cards belong to the original game.
func rebind(game: GameState) -> void:
	state = game
	if source != null:
		source = game.find_card(source.uid)
	if trigger != null:
		var found_trigger: CardInstance = game.find_card(trigger.uid)
		if found_trigger != null:
			trigger = found_trigger
	if host != null:
		host = game.find_card(host.uid)
	var fresh_paid: Array[CardInstance] = []
	for card: CardInstance in paid:
		var found: CardInstance = game.find_card(card.uid)
		fresh_paid.append(found if found != null else card)
	paid = fresh_paid
