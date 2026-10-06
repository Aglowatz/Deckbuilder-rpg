class_name TargetResolver
extends RefCounted
## Turns a `TargetSpec` into the concrete cards/players it names for a given ability context, picks targets for abilities
## that fire without a player choice (the engine picks the best one), and counts.


## Every ref (card uid or `Targets.player`) the spec names. `for_targeting` also removes cards the controller may not
## target (Untouchable, protected); "all(...)" selections and counts are not targeting.
static func candidates(spec: TargetSpec, ctx: AbilityContext, for_targeting: bool) -> Array[int]:
	var state: GameState = ctx.state
	var result: Array[int] = []
	for zone: String in spec.zones:
		match zone:
			"unit":
				for card: CardInstance in state.all_units():
					_add_field_card(result, card, spec, ctx, for_targeting)
			"token":
				for card: CardInstance in state.all_units():
					if card.is_token():
						_add_field_card(result, card, spec, ctx, for_targeting)
				for player: PlayerState in state.players:
					for card: CardInstance in player.tokens:
						_add_field_card(result, card, spec, ctx, false)
			"tool":
				for player: PlayerState in state.players:
					for card: CardInstance in player.tools():
						_add_field_card(result, card, spec, ctx, for_targeting)
			"wonder":
				for player: PlayerState in state.players:
					for card: CardInstance in player.wonders():
						_add_field_card(result, card, spec, ctx, for_targeting)
			"infra":
				for player: PlayerState in state.players:
					for card: CardInstance in player.infrastructure:
						_add_field_card(result, card, spec, ctx, false)
			"resource":
				for player: PlayerState in state.players:
					for card: CardInstance in player.resources:
						_add_field_card(result, card, spec, ctx, false)
			"trap":
				for player: PlayerState in state.players:
					for card: CardInstance in player.traps:
						_add_field_card(result, card, spec, ctx, false)
			"any":
				for card: CardInstance in state.all_units():
					_add_field_card(result, card, spec, ctx, for_targeting)
				_add_players(result, spec, ctx, true)
			"player":
				_add_players(result, spec, ctx, true)
			"opp":
				result.append(Targets.player(1 - ctx.controller))
			"me":
				result.append(Targets.player(ctx.controller))
			"refuse":
				for player: PlayerState in state.players:
					if _pile_side_ok(spec, player.index, ctx):
						for card: CardInstance in player.refuse_pile:
							if _types_ok(spec, card) and _filters_ok(spec, card, ctx):
								result.append(card.uid)
			"deck":
				for player: PlayerState in state.players:
					if _pile_side_ok(spec, player.index, ctx, true):
						for card: CardInstance in player.deck:
							if _types_ok(spec, card) and _filters_ok(spec, card, ctx):
								result.append(card.uid)
			"hand":
				for player: PlayerState in state.players:
					if _pile_side_ok(spec, player.index, ctx, true):
						for card: CardInstance in player.hand:
							if _types_ok(spec, card) and _filters_ok(spec, card, ctx):
								result.append(card.uid)
	return result


static func _add_field_card(result: Array[int], card: CardInstance, spec: TargetSpec, ctx: AbilityContext, for_targeting: bool) -> void:
	if result.has(card.uid):
		return
	if spec.side == "mine" and card.owner != ctx.controller:
		return
	if spec.side == "opp" and card.owner == ctx.controller:
		return
	if for_targeting and not ctx.state.can_be_targeted_by(card, ctx.controller):
		return
	if not _filters_ok(spec, card, ctx):
		return
	result.append(card.uid)


static func _add_players(result: Array[int], spec: TargetSpec, ctx: AbilityContext, _both: bool) -> void:
	for index: int in range(2):
		if spec.side == "mine" and index != ctx.controller:
			continue
		if spec.side == "opp" and index == ctx.controller:
			continue
		result.append(Targets.player(index))


## Piles (Refuse Pile, deck, hand) default to the controller's own unless the spec says `opp` / is general for the Refuse Pile.
static func _pile_side_ok(spec: TargetSpec, pile_owner: int, ctx: AbilityContext, own_default: bool = false) -> bool:
	if spec.side == "mine":
		return pile_owner == ctx.controller
	if spec.side == "opp":
		return pile_owner != ctx.controller
	return pile_owner == ctx.controller if own_default else true


static func _types_ok(spec: TargetSpec, card: CardInstance) -> bool:
	if spec.types.is_empty() or spec.types.has("card"):
		return true
	for type_word: String in spec.types:
		match type_word:
			"unit":
				if card.data.is_unit():
					return true
			"tool":
				if card.data.is_tool():
					return true
			"wonder":
				if card.data.is_wonder():
					return true
			"infra":
				if card.data.is_infrastructure():
					return true
			"spell":
				if card.data.type == CardEnums.CardType.SPELL:
					return true
			"trap":
				if card.data.type == CardEnums.CardType.TRAP:
					return true
	return false


static func _filters_ok(spec: TargetSpec, card: CardInstance, ctx: AbilityContext) -> bool:
	var state: GameState = ctx.state
	for filter: Dictionary in spec.filters:
		if filter.has("flag"):
			var flag: String = str(filter["flag"])
			match flag:
				"other":
					if card == ctx.source:
						return false
				"tok":
					if not card.is_token():
						return false
				"nontok":
					if card.is_token():
						return false
				"golem":
					if not (card.is_token() and card.data.display_name.contains("Golem")):
						return false
				"exhausted":
					if not card.exhausted:
						return false
				"ready":
					if card.exhausted:
						return false
				"fresh":
					if ctx.source != null and ctx.source.targeted_this_turn.has(card.uid):
						return false
				"buffed":
					if card.buffs < 1:
						return false
				"multipath":
					if not card.data.is_multipath():
						return false
				"attacking":
					if not state.attackers.has(card.uid):
						return false
				"unattached":
					if card.attached_to != 0:
						return false
				"attached":
					if card.attached_to == 0:
						return false
				_:
					push_warning("TargetSpec: unknown filter flag '%s' in '%s'" % [flag, spec.raw])
			continue
		var key: String = str(filter["key"])
		var op: String = str(filter["op"])
		var value: Variant = filter["value"]
		match key:
			"atk", "def", "cost", "buffs":
				var left: int = 0
				match key:
					"atk":
						left = state.get_attack(card)
					"def":
						left = state.get_defense(card)
					"cost":
						left = card.data.energy_value()
					"buffs":
						left = card.buffs
				var right: int = int(value) if value is int else int(ctx.vars.get(str(value).substr(1), 0))
				if not TargetSpec.compare(left, op, right):
					return false
			"tokid":
				if not (card.is_token() and card.data.id == str(value)):
					return false
			"path":
				if not card.data.is_on_path(Affinity.from_symbol(str(value))):
					return false
			"kw":
				if not state.unit_has_keyword(card, ScriptParser.keyword_from_word(str(value)) as CardEnums.Keyword):
					return false
			"nokw":
				if state.unit_has_keyword(card, ScriptParser.keyword_from_word(str(value)) as CardEnums.Keyword):
					return false
			"kind":
				var kinds_ok: bool = false
				for word: String in str(value).split("|"):
					if card.data.resource_kind == ResourceKind.from_word(word):
						kinds_ok = true
				if not kinds_ok:
					return false
	return true


## Whether one card satisfies a spec (used for auras and filters), judged from the context's controller.
static func matches(spec: TargetSpec, candidate: CardInstance, ctx: AbilityContext) -> bool:
	var zone_ok: bool = false
	for zone: String in spec.zones:
		match zone:
			"unit":
				zone_ok = zone_ok or candidate.data.is_unit()
			"token":
				zone_ok = zone_ok or ((candidate.data.is_unit() and candidate.is_token()) or candidate.data.is_table_token())
			"tool":
				zone_ok = zone_ok or candidate.data.is_tool()
			"wonder":
				zone_ok = zone_ok or candidate.data.is_wonder()
			"infra":
				zone_ok = zone_ok or candidate.data.is_infrastructure()
			"resource":
				zone_ok = zone_ok or candidate.data.is_resource()
			"any":
				zone_ok = zone_ok or candidate.data.is_unit()
	if not zone_ok:
		return false
	if spec.side == "mine" and candidate.owner != ctx.controller:
		return false
	if spec.side == "opp" and candidate.owner == ctx.controller:
		return false
	return _filters_ok(spec, candidate, ctx)

# ---- Choosing -------------------------------------------------------------------------------------


## The refs a player may choose for a declared target (targeting rules apply).
static func legal_targets(decl: CardAbility.TargetDecl, ctx: AbilityContext) -> Array[int]:
	return candidates(decl.spec, ctx, true)


## +1 when the ability uses the named target to help its controller (buffs, reinstating), -1 when it hurts it
## (damage, destroy...), 0 when unknown.
static func polarity(ability: CardAbility, target_name: String) -> int:
	for fx: CardAbility.Fx in ability.effects:
		var found: int = _polarity_in(fx, target_name)
		if found != 0:
			return found
	return 0


static func _polarity_in(fx: CardAbility.Fx, target_name: String) -> int:
	var harmful: Array[String] = ["damage", "damage_divided", "destroy", "shred", "send_back", "plate", "exhaust", "no_refresh", "cant_block", "steal", "edict"]
	var helpful: Array[String] = ["buff", "kw_grant", "protect", "reinstate", "to_hand", "attach", "put_field", "regrow"]
	for i: int in range(fx.args.size()):
		var arg: Variant = fx.args[i]
		if arg is CardAbility.FxBlock:
			for inner: CardAbility.Fx in (arg as CardAbility.FxBlock).effects:
				var nested: int = _polarity_in(inner, target_name)
				if nested != 0:
					return nested
		elif arg is CardAbility.Fx:
			var inner_fx: CardAbility.Fx = arg as CardAbility.Fx
			var deep: int = _polarity_in(inner_fx, target_name)
			if deep != 0:
				return deep
		elif arg is String and arg == target_name:
			if fx.name == "pump":
				var attack_delta: int = int(fx.args[1]) if fx.args.size() > 1 and fx.args[1] is int else 0
				var defense_delta: int = int(fx.args[2]) if fx.args.size() > 2 and fx.args[2] is int else 0
				return -1 if attack_delta + defense_delta < 0 else 1
			if fx.name == "brawl":
				return 1 if i == 0 else -1
			if harmful.has(fx.name):
				return -1
			if helpful.has(fx.name):
				return 1
	return 0


## The engine's choice for an ability that has no player-chosen target: the most valuable enemy for harmful effects, the most
## valuable ally for helpful ones; cards in piles: the most valuable card. Returns [] when nothing sensible exists.
static func auto_pick(spec: TargetSpec, ctx: AbilityContext, ability: CardAbility, target_name: String = "", how_many: int = 1) -> Array[int]:
	var pool: Array[int] = candidates(spec, ctx, true)
	if pool.is_empty():
		return pool
	var polarity_value: int = polarity(ability, target_name) if not target_name.is_empty() else 0
	var state: GameState = ctx.state
	var scored: Array[Dictionary] = []
	for ref: int in pool:
		var score: float = 0.0
		if Targets.is_player(ref):
			var index: int = Targets.player_index(ref)
			score = 3.0
			if polarity_value == 0 and spec.side == "":
				polarity_value = -1
			if (index != ctx.controller) == (polarity_value < 0):
				score += 1000.0
		else:
			var card: CardInstance = state.find_card(ref)
			if card == null:
				continue
			score = state.card_worth(card)
			var on_field: bool = state.find_permanent(ref) != null or state.players[card.owner].resources.has(card) or state.players[card.owner].tokens.has(card) or state.players[card.owner].infrastructure.has(card)
			if on_field:
				var mine: bool = card.owner == ctx.controller
				var wants_enemy: bool = polarity_value <= 0
				if spec.side == "":
					if mine != wants_enemy:
						score += 1000.0
					elif mine and wants_enemy:
						score -= 1000.0
					elif not mine and not wants_enemy:
						score -= 1000.0
		scored.append({"ref": ref, "score": score})
	scored.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return float(a["score"]) > float(b["score"]))
	var picked: Array[int] = []
	for entry: Dictionary in scored:
		if picked.size() >= how_many:
			break
		# Never pick a target on the wrong side when the effect is clearly harmful or helpful.
		if float(entry["score"]) < -500.0:
			continue
		picked.append(int(entry["ref"]))
	return picked


## Fills `ctx.targets` for every declared target that has no chosen value yet.
static func auto_targets(ctx: AbilityContext) -> void:
	for decl: CardAbility.TargetDecl in ctx.ability.targets:
		if ctx.targets.has(decl.name) and not (ctx.targets[decl.name] as Array).is_empty():
			continue
		ctx.targets[decl.name] = auto_pick(decl.spec, ctx, ctx.ability, decl.name, decl.max_count)


static func count_arg(arg: Variant, ctx: AbilityContext) -> int:
	if arg is String:
		var word: String = arg as String
		var kind: int = ResourceKind.from_word(word)
		if kind != ResourceKind.NONE:
			return ctx.state.players[ctx.controller].count_resource(kind as ResourceKind.Kind)
		return candidates(TargetSpec.parse(word), ctx, false).size()
	return AbilityRunner.eval_int(arg, ctx)
