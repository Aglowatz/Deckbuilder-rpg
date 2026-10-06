class_name AbilityOps
extends RefCounted
## The effect vocabulary of card scripts (docs/card_pipeline.md lists every op). `execute` runs one effect call and returns
## whether it did something (for `ifdid`). Operations never touch the UI; they call the rules primitives on GameState.

const PERMANENT: String = "perm"

## Every effect op a card script may use (the importer reports anything else as an unsupported mechanic). Keep in sync with `execute`.
const OP_NAMES: Array[String] = [
	"damage", "damage_divided", "destroy", "destroy_self", "shred", "send_back", "to_hand", "regrow", "edict", "plate", "brawl", "brawl_each",
	"reinstate", "reinstate_all", "reinstate_up_to", "reinstate_diff_paths", "reinstate_destroyed", "steal", "steal_all", "create", "create_x",
	"copy_token", "copy_all_tokens", "morph_tokens", "shuffle_into", "shuffle_refuse_into_deck", "pump", "pump_kill", "buff", "kw_grant",
	"set_def", "set_atk", "cant_block", "protect", "exhaust", "no_refresh", "attach", "add", "gain", "lose", "draw", "peek", "bury", "search",
	"put_field", "use", "use_any", "set", "if", "may", "ifdid", "flip", "choose", "processing", "delay_start_next_turn",
	"stat", "kw", "flag", "selfstat", "cost_set", "cost_plus",
]


static func execute(fx: CardAbility.Fx, ctx: AbilityContext) -> bool:
	var state: GameState = ctx.state
	match fx.name:
		# ---- Damage and removal ---------------------------------------------------------------
		"damage":
			return _damage(fx, ctx)
		"damage_divided":
			return _damage_divided(fx, ctx)
		"destroy":
			return _destroy(fx, ctx)
		"destroy_self":
			if ctx.source == null:
				return false
			return state.destroy_card(ctx.source)
		"shred":
			var shredded: bool = false
			for card: CardInstance in _cards(fx.args[0], ctx):
				shredded = state.shred_card(card) or shredded
			return shredded
		"send_back":
			var sent: bool = false
			for card: CardInstance in _cards(fx.args[0], ctx):
				sent = state.send_back(card) or sent
			return sent
		"to_hand", "regrow":
			var returned: bool = false
			for card: CardInstance in _cards(fx.args[0], ctx):
				returned = state.return_from_refuse_to_hand(card) or returned
			return returned
		"edict":
			return _edict(fx, ctx)
		"plate":
			var plated: bool = false
			for card: CardInstance in _cards(fx.args[0], ctx):
				plated = state.plate_card(card) or plated
			return plated
		"brawl":
			var first: Array[CardInstance] = _cards(fx.args[0], ctx)
			var second: Array[CardInstance] = _cards(fx.args[1], ctx)
			if first.is_empty() or second.is_empty():
				return false
			return state.brawl(first[0], second[0])
		"brawl_each":
			return _brawl_each(fx, ctx)
		# ---- Reinstating and control ----------------------------------------------------------
		"reinstate":
			return _reinstate(fx, ctx)
		"reinstate_all":
			var everyone: Array[CardInstance] = _cards_from_spec(fx.args[0], ctx)
			return _reinstate_cards(everyone, ctx.controller, ctx)
		"reinstate_up_to":
			var limit: int = AbilityRunner.eval_int(fx.args[0], ctx)
			var pool: Array[CardInstance] = _cards_from_spec(fx.args[1], ctx)
			pool.sort_custom(func(a: CardInstance, b: CardInstance) -> bool: return state.card_worth(a) > state.card_worth(b))
			return _reinstate_cards(pool.slice(0, limit), ctx.controller, ctx)
		"reinstate_diff_paths":
			return _reinstate_diff_paths(fx, ctx)
		"reinstate_destroyed":
			var max_cost: int = AbilityRunner.eval_int(fx.args[0], ctx)
			var chosen: Array[CardInstance] = []
			for item: Variant in ctx.vars.get("destroyed_cards", []) as Array:
				var card: CardInstance = item as CardInstance
				if card != null and card.real_owner == ctx.controller and card.data.energy_value() <= max_cost and not card.is_token():
					chosen.append(card)
			return _reinstate_cards(chosen, ctx.controller, ctx)
		"steal":
			var stolen: bool = false
			var temporary: bool = fx.args.size() > 1 and str(fx.args[1]) != PERMANENT
			for card: CardInstance in _cards(fx.args[0], ctx):
				stolen = state.steal_card(card, ctx.controller, temporary) or stolen
			return stolen
		"steal_all":
			var took: bool = false
			for card: CardInstance in _cards_from_spec(fx.args[0], ctx):
				took = state.steal_card(card, ctx.controller, false) or took
			return took
		# ---- Tokens and copies ----------------------------------------------------------------
		"create":
			return _create(fx, ctx)
		"create_x":
			return _create_x(fx, ctx)
		"copy_token":
			var made: Array[int] = []
			for card: CardInstance in _cards(fx.args[0], ctx):
				var copy: CardInstance = state.copy_unit_as_token(card, ctx.controller)
				if copy != null:
					made.append(copy.uid)
			ctx.vars["last"] = made
			return not made.is_empty()
		"copy_all_tokens":
			return state.copy_each_token(ctx.controller)
		"morph_tokens":
			return state.tokens_become_copy_of_best(ctx.controller)
		"shuffle_into":
			var players: Array[int] = _player_indexes(AbilityRunner.refs(fx.args[0], ctx), state)
			var token: CardData = TokenRegistry.data(str(fx.args[1]))
			if players.is_empty() or token == null:
				return false
			state.shuffle_tokens_into_deck(players[0], token, AbilityRunner.eval_int(fx.args[2], ctx), ctx.controller)
			return true
		"shuffle_refuse_into_deck":
			for index: int in _player_indexes(AbilityRunner.refs(fx.args[0], ctx), state):
				state.shuffle_refuse_pile_into_deck(index)
			return true
		# ---- Stats and keywords ---------------------------------------------------------------
		"pump":
			var pumped: bool = false
			var attack_delta: int = AbilityRunner.eval_int(fx.args[1], ctx)
			var defense_delta: int = AbilityRunner.eval_int(fx.args[2], ctx)
			var until_eot: bool = not (fx.args.size() > 3 and str(fx.args[3]) == PERMANENT)
			for card: CardInstance in _cards(fx.args[0], ctx):
				state.change_stats(card, attack_delta, defense_delta, until_eot)
				pumped = true
			return pumped
		"pump_kill":
			var targets_hit: Array[CardInstance] = _cards(fx.args[0], ctx)
			for card: CardInstance in targets_hit:
				state.change_stats(card, AbilityRunner.eval_int(fx.args[1], ctx), AbilityRunner.eval_int(fx.args[2], ctx), true)
			var before: int = 0
			for card: CardInstance in targets_hit:
				if state.field_contains(card):
					before += 1
			state.check_state()
			var after: int = 0
			for card: CardInstance in targets_hit:
				if state.field_contains(card):
					after += 1
			ctx.vars["died"] = before - after
			return before > after
		"buff":
			var buffed: bool = false
			var amount: int = AbilityRunner.eval_int(fx.args[1], ctx)
			for card: CardInstance in _cards(fx.args[0], ctx):
				buffed = state.buff_unit(card, amount) or buffed
			return buffed
		"kw_grant":
			var granted: bool = false
			var keyword: int = ScriptParser.keyword_from_word(str(fx.args[1]))
			if keyword < 0:
				return false
			var temporary_keyword: bool = not (fx.args.size() > 2 and str(fx.args[2]) == PERMANENT)
			for card: CardInstance in _cards(fx.args[0], ctx):
				state.grant_keyword(card, keyword as CardEnums.Keyword, temporary_keyword)
				granted = true
			return granted
		"set_def", "set_atk":
			var set_any: bool = false
			for card: CardInstance in _cards(fx.args[0], ctx):
				if fx.name == "set_def":
					card.set_defense = AbilityRunner.eval_int(fx.args[1], ctx)
				else:
					card.set_attack = AbilityRunner.eval_int(fx.args[1], ctx)
				set_any = true
			return set_any
		"cant_block":
			var blocked_any: bool = false
			for card: CardInstance in _cards(fx.args[0], ctx):
				card.temp_cannot_block = true
				blocked_any = true
			return blocked_any
		"protect":
			var protected_any: bool = false
			for card: CardInstance in _cards(fx.args[0], ctx):
				card.protected_until_turn = state.turn + 2
				protected_any = true
			return protected_any
		"exhaust":
			var exhausted_any: bool = false
			for card: CardInstance in _cards(fx.args[0], ctx):
				state.exhaust_unit(card, false)
				exhausted_any = true
			return exhausted_any
		"no_refresh":
			var held_any: bool = false
			for card: CardInstance in _cards(fx.args[0], ctx):
				card.skip_refresh += 1
				held_any = true
			return held_any
		"attach":
			var unit_cards: Array[CardInstance] = _cards(fx.args[0], ctx)
			if ctx.source == null or unit_cards.is_empty():
				return false
			return state.attach_tool(ctx.source, unit_cards[0])
		# ---- Players, energy, cards -----------------------------------------------------------
		"add":
			return _add_energy(fx, ctx)
		"gain":
			var gained: bool = false
			var gain_amount: int = AbilityRunner.eval_int(fx.args[1], ctx)
			for index: int in _player_indexes(AbilityRunner.refs(fx.args[0], ctx), state):
				state.gain_hp(index, gain_amount)
				gained = true
			return gained and gain_amount > 0
		"lose":
			var lost: bool = false
			var lose_amount: int = AbilityRunner.eval_int(fx.args[1], ctx)
			for index: int in _player_indexes(AbilityRunner.refs(fx.args[0], ctx), state):
				state.lose_hp(index, lose_amount)
				lost = true
			return lost and lose_amount > 0
		"draw":
			var count: int = AbilityRunner.eval_int(fx.args[0], ctx)
			var drawers: Array[int] = [ctx.controller]
			if fx.args.size() > 1:
				drawers = _player_indexes(AbilityRunner.refs(fx.args[1], ctx), state)
			for index: int in drawers:
				state.draw_cards(index, count)
			return count > 0
		"peek":
			state.peek_deck(ctx.controller, AbilityRunner.eval_int(fx.args[0], ctx))
			return true
		"bury":
			var buried: Array[CardInstance] = []
			for index: int in _player_indexes(AbilityRunner.refs(fx.args[0], ctx), state):
				buried.append_array(state.bury_deck(index, AbilityRunner.eval_int(fx.args[1], ctx)))
			var unit_cards_buried: int = 0
			for card: CardInstance in buried:
				if card.data.is_unit() and not card.is_token():
					unit_cards_buried += 1
			ctx.vars["buried_units"] = unit_cards_buried
			return not buried.is_empty()
		"search":
			return state.search_deck(ctx.controller, str(fx.args[0]), AbilityRunner.eval_int(fx.args[1], ctx), str(fx.args[2]) if fx.args.size() > 2 else "field")
		"put_field":
			var put: bool = false
			for card: CardInstance in _cards(fx.args[0], ctx):
				put = state.put_onto_field(card, ctx.controller) or put
			return put
		# ---- Resources ------------------------------------------------------------------------
		"use":
			var kind: int = ResourceKind.from_word(str(fx.args[0]))
			if kind == ResourceKind.NONE:
				return false
			return ResourceRules.use(state, ctx.controller, kind as ResourceKind.Kind, AbilityRunner.eval_int(fx.args[1], ctx) if fx.args.size() > 1 else 1)
		"use_any":
			var any_kind: int = ResourceKind.from_word(str(fx.args[0]))
			if any_kind == ResourceKind.NONE:
				return false
			var available: int = state.players[ctx.controller].count_resource(any_kind as ResourceKind.Kind)
			ctx.vars["used"] = available
			if available <= 0:
				return false
			return ResourceRules.use(state, ctx.controller, any_kind as ResourceKind.Kind, available)
		# ---- Control flow ---------------------------------------------------------------------
		"set":
			ctx.vars[str(fx.args[0])] = AbilityRunner.evaluate(fx.args[1], ctx)
			return true
		"if":
			var holds: bool = AbilityRunner.truthy(AbilityRunner.evaluate(fx.args[0], ctx))
			var branch: Variant = fx.args[1] if holds else (fx.args[2] if fx.args.size() > 2 else null)
			if branch is CardAbility.FxBlock:
				AbilityRunner.run_block(ctx, branch as CardAbility.FxBlock)
				return ctx.last_ok
			return false
		"may":
			var body: CardAbility.FxBlock = fx.args[0] as CardAbility.FxBlock
			if body == null:
				return false
			if not _decide(body, ctx):
				return false
			AbilityRunner.run_block(ctx, body)
			return ctx.last_ok
		"ifdid":
			if not ctx.last_ok:
				return false
			var follow: CardAbility.FxBlock = fx.args[0] as CardAbility.FxBlock
			if follow == null:
				return false
			AbilityRunner.run_block(ctx, follow)
			return ctx.last_ok
		"flip":
			var heads: bool = state.rng.randi_range(0, 1) == 1
			state.emit_event(GameEvent.Type.COIN_FLIPPED, ctx.controller, ctx.source_uid(), 0, 1 if heads else 0)
			var chosen_branch: CardAbility.FxBlock = fx.args[0] as CardAbility.FxBlock if heads else fx.args[1] as CardAbility.FxBlock
			if chosen_branch != null:
				AbilityRunner.run_block(ctx, chosen_branch)
			return true
		"choose":
			return _choose(fx, ctx)
		"processing":
			var turns: int = AbilityRunner.eval_int(fx.args[0], ctx)
			state.schedule_delayed(ctx.snapshot(), fx.args[1] as CardAbility.FxBlock, turns)
			return true
		"delay_start_next_turn":
			state.schedule_delayed(ctx.snapshot(), fx.args[0] as CardAbility.FxBlock, 1)
			return true
		# Static vocabulary: read by StaticEffects, nothing to do when resolving.
		"stat", "kw", "flag", "selfstat", "cost_set", "cost_plus":
			return true
	push_warning("AbilityOps: unknown op '%s' (%s)" % [fx.name, fx.text])
	return false


# ---- Selection helpers ------------------------------------------------------------------------------


static func _cards(arg: Variant, ctx: AbilityContext) -> Array[CardInstance]:
	var result: Array[CardInstance] = []
	for ref: int in AbilityRunner.refs(arg, ctx):
		if Targets.is_player(ref):
			continue
		var card: CardInstance = ctx.state.find_card(ref)
		if card != null:
			result.append(card)
	return result


static func _cards_from_spec(arg: Variant, ctx: AbilityContext) -> Array[CardInstance]:
	var result: Array[CardInstance] = []
	if arg is String:
		for ref: int in TargetResolver.candidates(TargetSpec.parse(arg as String), ctx, false):
			var card: CardInstance = ctx.state.find_card(ref)
			if card != null:
				result.append(card)
		return result
	return _cards(arg, ctx)


static func _player_indexes(selection: Array[int], state: GameState) -> Array[int]:
	var result: Array[int] = []
	for ref: int in selection:
		var index: int = -1
		if Targets.is_player(ref):
			index = Targets.player_index(ref)
		else:
			var card: CardInstance = state.find_card(ref)
			if card != null:
				index = card.owner
		if index >= 0 and not result.has(index):
			result.append(index)
	return result


# ---- Individual operations ------------------------------------------------------------------------


static func _damage(fx: CardAbility.Fx, ctx: AbilityContext) -> bool:
	var state: GameState = ctx.state
	var amount: int = AbilityRunner.eval_int(fx.args[1], ctx)
	if amount <= 0:
		return false
	var source_uid: int = ctx.source_uid()
	if fx.args.size() > 2:
		var source_refs: Array[int] = AbilityRunner.refs(fx.args[2], ctx)
		if not source_refs.is_empty():
			source_uid = source_refs[0]
	var dealt: bool = false
	for ref: int in AbilityRunner.refs(fx.args[0], ctx):
		if Targets.is_player(ref):
			dealt = state.deal_damage_to_player(source_uid, Targets.player_index(ref), amount) > 0 or dealt
		else:
			var card: CardInstance = state.find_permanent(ref)
			if card != null and card.data.is_unit():
				dealt = state.deal_damage_to_unit(source_uid, card, amount) > 0 or dealt
	return dealt


## "Deal N damage divided as you choose among any number of target units": spread one point at a time, always to the
## unit it hurts most (a point that finishes a unit first), cycling through the chosen targets.
static func _damage_divided(fx: CardAbility.Fx, ctx: AbilityContext) -> bool:
	var state: GameState = ctx.state
	var total: int = AbilityRunner.eval_int(fx.args[1], ctx)
	var units: Array[CardInstance] = []
	for card: CardInstance in _cards(fx.args[0], ctx):
		if card.data.is_unit() and state.field_contains(card):
			units.append(card)
	if units.is_empty():
		return false
	var assigned: Dictionary = {}
	for point: int in range(total):
		var best: CardInstance = null
		var best_score: float = -INF
		for card: CardInstance in units:
			var remaining: int = state.get_defense(card) - card.damage - int(assigned.get(card.uid, 0))
			var score: float = 100.0 if remaining == 1 else 50.0 - float(remaining) - float(int(assigned.get(card.uid, 0)))
			if remaining <= 0:
				score = -500.0 + float(remaining)
			if card.owner == ctx.controller:
				score -= 1000.0
			if score > best_score:
				best_score = score
				best = card
		assigned[best.uid] = int(assigned.get(best.uid, 0)) + 1
	var any: bool = false
	for card: CardInstance in units:
		var amount: int = int(assigned.get(card.uid, 0))
		if amount > 0:
			any = state.deal_damage_to_unit(ctx.source_uid(), card, amount) > 0 or any
	return any


static func _destroy(fx: CardAbility.Fx, ctx: AbilityContext) -> bool:
	var state: GameState = ctx.state
	var destroyed: Array[CardInstance] = []
	for card: CardInstance in _cards(fx.args[0], ctx):
		if state.destroy_card(card):
			destroyed.append(card)
	var as_array: Array = []
	for card: CardInstance in destroyed:
		as_array.append(card)
	ctx.vars["destroyed_cards"] = as_array
	ctx.vars["destroyed"] = as_array.size()
	return not destroyed.is_empty()


static func _edict(fx: CardAbility.Fx, ctx: AbilityContext) -> bool:
	var state: GameState = ctx.state
	var victims: Array[int] = _player_indexes(AbilityRunner.refs(fx.args[0], ctx), state)
	var did: bool = false
	for index: int in victims:
		var worst: CardInstance = null
		for unit: CardInstance in state.players[index].units():
			if state.unit_has_keyword(unit, CardEnums.Keyword.UNBREAKABLE):
				continue
			if worst == null or state.card_worth(unit) < state.card_worth(worst):
				worst = unit
		if worst != null:
			did = state.destroy_card(worst) or did
	return did


static func _brawl_each(fx: CardAbility.Fx, ctx: AbilityContext) -> bool:
	var state: GameState = ctx.state
	var mine: Array[CardInstance] = _cards_from_spec(fx.args[0], ctx)
	var theirs: Array[CardInstance] = _cards_from_spec(fx.args[1], ctx)
	mine.sort_custom(func(a: CardInstance, b: CardInstance) -> bool: return state.get_attack(a) > state.get_attack(b))
	var did: bool = false
	for unit: CardInstance in mine:
		if theirs.is_empty() or not state.field_contains(unit):
			continue
		var best: CardInstance = null
		var best_score: float = -INF
		for foe: CardInstance in theirs:
			var kills: bool = state.get_attack(unit) >= state.get_defense(foe) - foe.damage
			var survives: bool = state.get_attack(foe) < state.get_defense(unit) - unit.damage
			var score: float = float(state.card_worth(foe)) + (50.0 if kills else 0.0) + (50.0 if survives else 0.0)
			if score > best_score:
				best_score = score
				best = foe
		theirs.erase(best)
		did = state.brawl(unit, best) or did
	return did


static func _reinstate(fx: CardAbility.Fx, ctx: AbilityContext) -> bool:
	var control: int = ctx.controller
	if fx.args.size() > 1:
		var who: Array[int] = _player_indexes(AbilityRunner.refs(fx.args[1], ctx), ctx.state)
		if not who.is_empty():
			control = who[0]
	return _reinstate_cards(_cards(fx.args[0], ctx), control, ctx)


static func _reinstate_cards(cards: Array[CardInstance], control: int, ctx: AbilityContext) -> bool:
	var made: Array[int] = []
	for card: CardInstance in cards:
		if ctx.state.reinstate_card(card, control):
			made.append(card.uid)
	ctx.vars["last"] = made
	return not made.is_empty()


static func _reinstate_diff_paths(fx: CardAbility.Fx, ctx: AbilityContext) -> bool:
	var state: GameState = ctx.state
	var limit: int = AbilityRunner.eval_int(fx.args[0], ctx)
	var pool: Array[CardInstance] = []
	for card: CardInstance in state.players[ctx.controller].refuse_pile:
		if card.data.is_unit() and not card.is_token():
			pool.append(card)
	pool.sort_custom(func(a: CardInstance, b: CardInstance) -> bool: return state.card_worth(a) > state.card_worth(b))
	var chosen: Array[CardInstance] = []
	var used_paths: Array[int] = []
	for path: Affinity.Type in Affinity.colored_types():
		if chosen.size() >= limit:
			break
		for card: CardInstance in pool:
			if not chosen.has(card) and card.data.is_on_path(path) and not used_paths.has(int(path)):
				chosen.append(card)
				used_paths.append(int(path))
				break
	return _reinstate_cards(chosen, ctx.controller, ctx)


static func _create(fx: CardAbility.Fx, ctx: AbilityContext) -> bool:
	var state: GameState = ctx.state
	var what: String = str(fx.args[0])
	var count: int = AbilityRunner.eval_int(fx.args[1], ctx) if fx.args.size() > 1 else 1
	var beneficiary: int = ctx.controller
	if fx.args.size() > 2:
		var who: Array[int] = _player_indexes(AbilityRunner.refs(fx.args[2], ctx), state)
		if not who.is_empty():
			beneficiary = who[0]
	if count <= 0:
		return false
	var made: Array[int] = []
	var kind: int = ResourceKind.from_word(what)
	if kind != ResourceKind.NONE:
		for card: CardInstance in ResourceRules.create(state, beneficiary, kind as ResourceKind.Kind, count, ctx.source_uid()):
			made.append(card.uid)
	else:
		var token: CardData = TokenRegistry.data(what)
		if token == null:
			push_warning("create(): unknown token '%s'" % what)
			return false
		if token.is_resource() or token.is_table_token():
			for card: CardInstance in ResourceRules.create(state, beneficiary, token.resource_kind as ResourceKind.Kind, count, ctx.source_uid()):
				made.append(card.uid)
		else:
			for i: int in range(count):
				var token_card: CardInstance = state.create_token(beneficiary, token)
				made.append(token_card.uid)
	ctx.vars["last"] = made
	return not made.is_empty()


static func _create_x(fx: CardAbility.Fx, ctx: AbilityContext) -> bool:
	var token: CardData = TokenRegistry.data(str(fx.args[0]))
	var size: int = AbilityRunner.eval_int(fx.args[1], ctx)
	if token == null or size <= 0:
		return false
	var sized: CardData = token.duplicate() as CardData
	sized.attack = size
	sized.defense = size
	sized.display_name = "%s (%d/%d)" % [token.display_name, size, size]
	var made: CardInstance = ctx.state.create_token(ctx.controller, sized)
	ctx.vars["last"] = [made.uid]
	return true


static func _add_energy(fx: CardAbility.Fx, ctx: AbilityContext) -> bool:
	var player: PlayerState = ctx.state.players[ctx.controller]
	var added: int = 0
	for arg: Variant in fx.args:
		var word: String = str(arg)
		if word == "any":
			player.pool.append(PlayerState.POOL_ANY)
		else:
			var path: Affinity.Type = Affinity.from_symbol(word)
			if path == Affinity.Type.NEUTRAL:
				continue
			player.pool.append(int(path))
		added += 1
	if added > 0:
		ctx.state.emit_event(GameEvent.Type.ENERGY_ADDED, ctx.controller, ctx.source_uid(), 0, added)
	return added > 0


## "You may ...": the engine takes the option unless it would hurt its controller (destroying its own permanent).
static func _decide(block: CardAbility.FxBlock, ctx: AbilityContext) -> bool:
	if block.effects.is_empty():
		return false
	var first: CardAbility.Fx = block.effects[0]
	if first.name == "destroy" and not first.args.is_empty():
		for card: CardInstance in _cards(first.args[0], ctx):
			if card.owner == ctx.controller:
				return false
		return not _cards(first.args[0], ctx).is_empty()
	if first.name == "use" and fx_uses_unaffordable(first, ctx):
		return false
	return true


static func fx_uses_unaffordable(fx: CardAbility.Fx, ctx: AbilityContext) -> bool:
	var kind: int = ResourceKind.from_word(str(fx.args[0]))
	if kind == ResourceKind.NONE:
		return true
	var count: int = AbilityRunner.eval_int(fx.args[1], ctx) if fx.args.size() > 1 else 1
	return ctx.state.players[ctx.controller].count_resource(kind as ResourceKind.Kind) < count


## "Choose one": the engine takes the branch that creates the resource its controller has the fewest of; otherwise the first.
static func _choose(fx: CardAbility.Fx, ctx: AbilityContext) -> bool:
	var best: CardAbility.FxBlock = null
	var best_have: int = 1 << 30
	for arg: Variant in fx.args:
		var block: CardAbility.FxBlock = arg as CardAbility.FxBlock
		if block == null or block.effects.is_empty():
			continue
		var have: int = 0
		var branch_fx: CardAbility.Fx = block.effects[0]
		if branch_fx.name == "create" and not branch_fx.args.is_empty():
			var kind: int = ResourceKind.from_word(str(branch_fx.args[0]))
			if kind != ResourceKind.NONE:
				have = ctx.state.players[ctx.controller].count_resource(kind as ResourceKind.Kind)
		if best == null or have < best_have:
			best = block
			best_have = have
	if best == null:
		return false
	AbilityRunner.run_block(ctx, best)
	return ctx.last_ok
