class_name AbilityRunner
extends RefCounted
## Runs card abilities: evaluates values and selectors, checks and pays costs, resolves effect lists. The individual effect
## operations live in `AbilityOps`; targeting rules in `TargetResolver`. Everything is data-driven from `CardAbility` objects,
## so a new card normally needs only a script, and a new mechanic needs one new op.

## Nested resolutions deeper than this are cut off (guards against infinite trigger loops).
const MAX_DEPTH: int = 14

## Names usable as values or selectors inside effects and conditions (the importer reports anything else as unsupported).
const VALUE_NAMES: Array[String] = [
	"atk", "def", "cost", "count", "mul", "plus", "sub", "min", "max", "ge", "gt", "le", "lt", "eq", "distinct_atk", "distinct_paths",
	"hp", "buffs", "exists", "none", "all", "rand", "pick", "top_atk", "ctl", "has_buff", "host_is", "cmp", "hand", "deck_size",
	"infra", "played",
]


# ---- Entry points ---------------------------------------------------------------------------


## Resolves an ability's effects (after costs were paid and targets chosen). Returns whether it ran.
static func resolve(ctx: AbilityContext) -> bool:
	var state: GameState = ctx.state
	if state.is_over() or state.trigger_depth >= MAX_DEPTH:
		return false
	if ctx.ability.condition != null and not _condition_holds(ctx):
		return false
	state.trigger_depth += 1
	state.defer_state_checks += 1
	run_effects(ctx, ctx.ability.effects)
	state.defer_state_checks -= 1
	state.trigger_depth -= 1
	if state.defer_state_checks == 0:
		state.check_state()
	return true


static func run_effects(ctx: AbilityContext, effects: Array[CardAbility.Fx]) -> void:
	for fx: CardAbility.Fx in effects:
		if ctx.state.is_over():
			return
		ctx.last_ok = AbilityOps.execute(fx, ctx)


static func run_block(ctx: AbilityContext, block: CardAbility.FxBlock) -> void:
	run_effects(ctx, block.effects)


static func _condition_holds(ctx: AbilityContext) -> bool:
	var holds: bool = truthy(evaluate(ctx.ability.condition, ctx))
	return holds != ctx.ability.condition_negated


static func condition_holds_for(ability: CardAbility, ctx: AbilityContext) -> bool:
	if ability.condition == null:
		return true
	var holds: bool = truthy(evaluate(ability.condition, ctx))
	return holds != ability.condition_negated


static func truthy(value: Variant) -> bool:
	if value is bool:
		return value as bool
	if value is int:
		return int(value) != 0
	if value is Array:
		return not (value as Array).is_empty()
	return value != null and str(value) != ""


# ---- Values and selectors ---------------------------------------------------------------------


## Evaluates a value argument: a number, a word, a `$var`, or a call (`atk(trig)`, `count(garbage)`, `all(unit.opp)`).
static func evaluate(arg: Variant, ctx: AbilityContext) -> Variant:
	if arg is int:
		return arg
	if arg is String:
		var word: String = arg as String
		if word == "X":
			return ctx.x
		if word.begins_with("$"):
			return ctx.vars.get(word.substr(1), 0)
		if word.is_valid_int():
			return int(word)
		return word
	if arg is CardAbility.Fx:
		return _call(arg as CardAbility.Fx, ctx)
	return arg


static func eval_int(arg: Variant, ctx: AbilityContext) -> int:
	var value: Variant = evaluate(arg, ctx)
	if value is int:
		return int(value)
	if value is bool:
		return 1 if value else 0
	if value is Array:
		return (value as Array).size()
	if value is String and (value as String).is_valid_int():
		return int(value)
	return 0


## Evaluates a selector to refs (card uids, or `Targets.player` refs).
static func refs(arg: Variant, ctx: AbilityContext) -> Array[int]:
	var result: Array[int] = []
	var value: Variant = arg
	if arg is String or arg is CardAbility.Fx:
		value = evaluate_selector(arg, ctx)
	if value is Array:
		for item: Variant in value as Array:
			if item is int:
				result.append(int(item))
			elif item is CardInstance:
				result.append((item as CardInstance).uid)
	elif value is int:
		result.append(int(value))
	elif value is CardInstance:
		result.append((value as CardInstance).uid)
	return result


static func evaluate_selector(arg: Variant, ctx: AbilityContext) -> Variant:
	if arg is String:
		var word: String = arg as String
		var state: GameState = ctx.state
		match word:
			"self":
				return [ctx.source.uid] if ctx.source != null else []
			"me":
				return [Targets.player(ctx.controller)]
			"opp":
				return [Targets.player(1 - ctx.controller)]
			"trig":
				return [ctx.trigger.uid] if ctx.trigger != null else []
			"trig_ctl":
				return [Targets.player(ctx.trigger.owner)] if ctx.trigger != null else []
			"host":
				return [ctx.host.uid] if ctx.host != null else []
			"last":
				return ctx.vars.get("last", [])
			"creator":
				return [Targets.player(ctx.source.creator)] if ctx.source != null and ctx.source.creator >= 0 else []
		if word.begins_with("$"):
			var stored: Variant = ctx.vars.get(word.substr(1), [])
			if stored is CardInstance:
				return [(stored as CardInstance).uid]
			return stored
		if ctx.targets.has(word):
			return ctx.targets[word]
		if word == "paid":
			var paid_refs: Array[int] = []
			for card: CardInstance in ctx.paid:
				paid_refs.append(card.uid)
			return paid_refs
		if state != null and word.begins_with("p") and word.length() == 2 and word[1].is_valid_int():
			return [Targets.player(int(word[1]))]
		return []
	if arg is CardAbility.Fx:
		return _call(arg as CardAbility.Fx, ctx)
	return arg


## Every target ref chosen so far (flattened), for bookkeeping such as "each unit can be targeted only once per turn".
static func refs_of_all_targets(ctx: AbilityContext) -> Array[int]:
	var result: Array[int] = []
	for key: Variant in ctx.targets.keys():
		for ref: Variant in ctx.targets[key] as Array:
			result.append(int(ref))
	return result

## The controller (a player ref) of each card in the selection.
static func controllers_of(selection: Array[int], state: GameState) -> Array[int]:
	var result: Array[int] = []
	for ref: int in selection:
		if Targets.is_player(ref):
			result.append(ref)
			continue
		var card: CardInstance = state.find_card(ref)
		if card != null:
			result.append(Targets.player(card.owner))
	return result


static func _call(fx: CardAbility.Fx, ctx: AbilityContext) -> Variant:
	var state: GameState = ctx.state
	match fx.name:
		"atk", "def", "cost", "buffs", "hp":
			var selection: Array[int] = refs(fx.args[0], ctx) if not fx.args.is_empty() else ([] as Array[int])
			if selection.is_empty():
				return 0
			if fx.name == "hp":
				var player_ref: int = selection[0]
				if Targets.is_player(player_ref):
					return state.players[Targets.player_index(player_ref)].hp
				return 0
			var card: CardInstance = state.find_card(selection[0])
			if card == null:
				return 0
			match fx.name:
				"atk":
					return state.get_attack(card)
				"def":
					return state.get_defense(card)
				"cost":
					return card.data.energy_value()
				"buffs":
					return card.buffs
		"count":
			return TargetResolver.count_arg(fx.args[0], ctx)
		"exists":
			return 1 if not TargetResolver.candidates(TargetSpec.parse(str(fx.args[0])), ctx, false).is_empty() else 0
		"none":
			return 1 if TargetResolver.candidates(TargetSpec.parse(str(fx.args[0])), ctx, false).is_empty() else 0
		"mul":
			return eval_int(fx.args[0], ctx) * eval_int(fx.args[1], ctx)
		"plus":
			return eval_int(fx.args[0], ctx) + eval_int(fx.args[1], ctx)
		"sub":
			return eval_int(fx.args[0], ctx) - eval_int(fx.args[1], ctx)
		"ge":
			return 1 if eval_int(fx.args[0], ctx) >= eval_int(fx.args[1], ctx) else 0
		"gt":
			return 1 if eval_int(fx.args[0], ctx) > eval_int(fx.args[1], ctx) else 0
		"le":
			return 1 if eval_int(fx.args[0], ctx) <= eval_int(fx.args[1], ctx) else 0
		"lt":
			return 1 if eval_int(fx.args[0], ctx) < eval_int(fx.args[1], ctx) else 0
		"eq":
			return 1 if eval_int(fx.args[0], ctx) == eval_int(fx.args[1], ctx) else 0
		"min":
			return mini(eval_int(fx.args[0], ctx), eval_int(fx.args[1], ctx))
		"max":
			return maxi(eval_int(fx.args[0], ctx), eval_int(fx.args[1], ctx))
		"distinct_atk":
			var values: Dictionary = {}
			for ref: int in TargetResolver.candidates(TargetSpec.parse(str(fx.args[0])), ctx, false):
				var unit: CardInstance = state.find_card(ref)
				if unit != null:
					values[state.get_attack(unit)] = true
			return values.size()
		"distinct_paths":
			var paths: Dictionary = {}
			for ref: int in TargetResolver.candidates(TargetSpec.parse(str(fx.args[0])), ctx, false):
				var infra: CardInstance = state.find_card(ref)
				if infra != null:
					for path: Affinity.Type in infra.data.paths():
						paths[int(path)] = true
			return paths.size()
		"has_buff":
			var buffed: Array[int] = refs(fx.args[0], ctx)
			if buffed.is_empty():
				return 0
			var buffed_card: CardInstance = state.find_card(buffed[0])
			return 1 if buffed_card != null and buffed_card.buffs > 0 else 0
		"host_is":
			if ctx.host == null:
				return 0
			var letter: Affinity.Type = Affinity.from_symbol(str(fx.args[0]))
			return 1 if ctx.host.data.is_on_path(letter) else 0
		"hand":
			return state.players[ctx.controller].hand.size()
		"deck_size":
			return state.players[ctx.controller].deck.size()
		"cmp":
			var left: int = eval_int(fx.args[0], ctx)
			var right: int = eval_int(fx.args[2], ctx)
			var op: String = str(fx.args[1])
			if op == "!=":
				return 1 if left != right else 0
			return 1 if TargetSpec.compare(left, op, right) else 0
		"all":
			var spec: TargetSpec = TargetSpec.parse(str(fx.args[0]))
			return TargetResolver.candidates(spec, ctx, false)
		"rand":
			var pool: Array[int] = TargetResolver.candidates(TargetSpec.parse(str(fx.args[0])), ctx, false)
			if pool.is_empty():
				return []
			return [pool[state.rng.randi_range(0, pool.size() - 1)]]
		"pick":
			return TargetResolver.auto_pick(TargetSpec.parse(str(fx.args[0])), ctx, ctx.ability)
		"top_atk":
			var strongest: CardInstance = null
			for ref: int in TargetResolver.candidates(TargetSpec.parse(str(fx.args[0])), ctx, false):
				var unit: CardInstance = state.find_card(ref)
				if unit != null and (strongest == null or state.get_attack(unit) > state.get_attack(strongest)):
					strongest = unit
			return [strongest.uid] if strongest != null else []
		"ctl":
			return controllers_of(refs(fx.args[0], ctx), state)
		"infra":
			return state.players[ctx.controller].infrastructure.size()
		"played":
			var who: int = int(ctx.vars.get("player", 1 - ctx.controller))
			# "for each OTHER card they have played this turn": the card being played counts as one of them.
			return maxi(0, state.players[who].cards_played_this_turn)
	return 0


# ---- Costs ----------------------------------------------------------------------------------------


## The total energy an ability's `pay(...)` costs add up to.
static func energy_cost(costs: Array[CardAbility.Cost]) -> Dictionary:
	var generic: int = 0
	var pips: Array[Affinity.Type] = []
	for cost: CardAbility.Cost in costs:
		if cost.kind == "pay":
			generic += cost.generic
			pips.append_array(cost.pips)
	return {"generic": generic, "pips": pips}

static func _taps(costs: Array[CardAbility.Cost]) -> bool:
	for cost: CardAbility.Cost in costs:
		if cost.kind == "exhaust" or cost.kind == "overexert":
			return true
	return false


## Whether every cost can be paid right now. `picks` names the cards chosen for "destroy a unit" / "use a token" costs
## (may be empty: the engine then chooses the cheapest legal ones).
static func can_pay_costs(ctx: AbilityContext, costs: Array[CardAbility.Cost], picks: Array[int]) -> bool:
	var state: GameState = ctx.state
	var player: PlayerState = state.players[ctx.controller]
	var energy: Dictionary = energy_cost(costs)
	if int(energy["generic"]) > 0 or not (energy["pips"] as Array).is_empty():
		# The permanent that exhausts as part of the cost cannot also pay the energy.
		var held: bool = false
		if ctx.source != null and not ctx.source.exhausted and _taps(costs):
			ctx.source.exhausted = true
			held = true
		var affordable: bool = state.can_pay_energy(ctx.controller, int(energy["generic"]), energy["pips"] as Array[Affinity.Type])
		if held:
			ctx.source.exhausted = false
		if not affordable:
			return false
	var needed: Dictionary = {}
	var destroyed: Array[CardInstance] = []
	for cost: CardAbility.Cost in costs:
		var count: int = ctx.x if cost.x_count else cost.count
		match cost.kind:
			"exhaust", "overexert":
				if ctx.source == null or ctx.source.exhausted:
					return false
				if ctx.source.data.is_unit() and ctx.source.summoning_sick and not state.unit_has_keyword(ctx.source, CardEnums.Keyword.HUSTLE):
					return false
			"destroy_self":
				if ctx.source == null:
					return false
			"use":
				if cost.x_count and ctx.x < 1:
					return false
				if cost.resource_kinds.size() == 1:
					needed[int(cost.resource_kinds[0])] = int(needed.get(int(cost.resource_kinds[0]), 0)) + count
				else:
					var have: int = 0
					for kind: ResourceKind.Kind in cost.resource_kinds:
						have += player.count_resource(kind)
					if have < count:
						return false
			"use_token":
				if token_cost_options(ctx).size() < count:
					return false
			"eat":
				if not ResourceRules.can_eat(state, ctx.controller, count):
					return false
			"destroy":
				var options: Array[CardInstance] = destroy_cost_options(ctx, cost)
				for card: CardInstance in destroyed:
					options.erase(card)
				if options.size() < count:
					return false
				var chosen: Array[CardInstance] = _picked_or_cheapest(state, options, picks, count)
				if chosen.size() < count:
					return false
				destroyed.append_array(chosen)
	for kind_key: Variant in needed.keys():
		if player.count_resource(int(kind_key) as ResourceKind.Kind) < int(needed[kind_key]):
			return false
	return true


## Pays the costs (call `can_pay_costs` first). Fills `ctx.paid` with cards destroyed as costs.
static func pay_costs(ctx: AbilityContext, costs: Array[CardAbility.Cost], picks: Array[int]) -> bool:
	var state: GameState = ctx.state
	# Exhaust first, so the source cannot pay its own energy cost.
	for cost: CardAbility.Cost in costs:
		if cost.kind == "exhaust" and ctx.source != null:
			ctx.source.exhausted = true
			state.emit_event(GameEvent.Type.UNIT_EXHAUSTED, ctx.controller, ctx.source.uid, 0, 0)
		elif cost.kind == "overexert" and ctx.source != null:
			state.exhaust_unit(ctx.source, true)
	var energy: Dictionary = energy_cost(costs)
	if int(energy["generic"]) > 0 or not (energy["pips"] as Array).is_empty():
		if not state.pay_energy(ctx.controller, int(energy["generic"]), energy["pips"] as Array[Affinity.Type], [] as Array[int], ctx.source_uid()):
			return false
	for cost: CardAbility.Cost in costs:
		var count: int = ctx.x if cost.x_count else cost.count
		match cost.kind:
			"use":
				if cost.resource_kinds.size() == 1:
					ResourceRules.use(state, ctx.controller, cost.resource_kinds[0], count)
				else:
					ResourceRules.use_any_of(state, ctx.controller, cost.resource_kinds, count)
			"use_token":
				for card: CardInstance in _picked_or_cheapest(state, token_cost_options(ctx), picks, count):
					if card.data.is_resource():
						ResourceRules.use(state, card.owner, card.data.resource_kind as ResourceKind.Kind, 1)
					else:
						state.destroy_unit(card)
			"eat":
				ResourceRules.eat(state, ctx.controller, count)
			"destroy":
				var options: Array[CardInstance] = destroy_cost_options(ctx, cost)
				for card: CardInstance in _picked_or_cheapest(state, options, picks, count):
					ctx.paid.append(card)
					ctx.vars["paid_cost"] = card.data.energy_value()
					ctx.vars["paid_def"] = state.get_defense(card)
					ctx.vars["paid_atk"] = state.get_attack(card)
					state.destroy_unit(card)
	for cost: CardAbility.Cost in costs:
		if cost.kind == "destroy_self" and ctx.source != null:
			state.destroy_permanent(ctx.source)
	return true


## Cards that could be destroyed to pay a `destroy(spec, n)` cost (never the source itself unless allowed by the spec).
static func destroy_cost_options(ctx: AbilityContext, cost: CardAbility.Cost) -> Array[CardInstance]:
	var result: Array[CardInstance] = []
	if cost.spec == null:
		return result
	for ref: int in TargetResolver.candidates(cost.spec, ctx, false):
		var card: CardInstance = ctx.state.find_card(ref)
		if card != null and card.owner == ctx.controller:
			result.append(card)
	return result


static func token_cost_options(ctx: AbilityContext) -> Array[CardInstance]:
	var result: Array[CardInstance] = []
	var player: PlayerState = ctx.state.players[ctx.controller]
	for card: CardInstance in player.resources:
		result.append(card)
	for card: CardInstance in player.units():
		if card.is_token():
			result.append(card)
	return result


## `picks` first (those that are in `options`), then the cheapest remaining options, up to `count`.
static func _picked_or_cheapest(state: GameState, options: Array[CardInstance], picks: Array[int], count: int) -> Array[CardInstance]:
	var chosen: Array[CardInstance] = []
	for uid: int in picks:
		for card: CardInstance in options:
			if card.uid == uid and not chosen.has(card) and chosen.size() < count:
				chosen.append(card)
	var rest: Array[CardInstance] = []
	for card: CardInstance in options:
		if not chosen.has(card):
			rest.append(card)
	rest.sort_custom(func(a: CardInstance, b: CardInstance) -> bool: return state.card_worth(a) < state.card_worth(b))
	for card: CardInstance in rest:
		if chosen.size() >= count:
			break
		chosen.append(card)
	return chosen
