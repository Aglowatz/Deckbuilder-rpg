class_name StaticEffects
extends RefCounted
## Continuous ("static") effects of permanents on the field: stat auras, keyword grants, player-wide flags (Raccoon, Harvest
## Festival, Chancellor Clench...), cost changes. Computed on demand from the cards on the field, so there is no state to keep in sync.
##
## Script vocabulary read here (all inside `static`, `aura(...)`, `host` and `costmod` abilities):
##   stat(a, d)             +a/+d (numbers or values)        selfstat(a, d)   same, evaluated for the card itself
##   kw(word, ...)          grants keywords                  flag(name)       a named rule flag (see `player_flag`)
##   cost_set(generic, B..) this card costs exactly that     cost_plus(who, kind, amount)   cards `who` plays cost more


## True while a static value is being computed (conditions that read stats must not recurse).
static var _busy: bool = false

## The player-wide rule flags a script may set with `flag(name)`.
const FLAG_NAMES: Array[String] = [
	"free_eat", "double_ingredients", "global_double_resources", "iron_plus_2", "red_tape_minus_2", "opp_units_enter_exhausted",
	"extra_infra_drop", "cant_block",
]


# ---- Stats and keywords --------------------------------------------------------------------------


## (attack, defense) added to `card` by auras, attached Tools and its own formulas.
static func stat_bonus(state: GameState, card: CardInstance) -> Vector2i:
	if _busy:
		return Vector2i.ZERO
	var total: Vector2i = Vector2i.ZERO
	_busy = true
	for source: CardInstance in _sources(state):
		for ability: CardAbility in source.data.abilities():
			if not _applies(state, source, ability, card):
				continue
			var ctx: AbilityContext = _context(state, source, ability, card)
			if not AbilityRunner.condition_holds_for(ability, ctx):
				continue
			for fx: CardAbility.Fx in ability.effects:
				if fx.name == "stat" or fx.name == "selfstat":
					total += Vector2i(AbilityRunner.eval_int(fx.args[0], ctx), AbilityRunner.eval_int(fx.args[1], ctx))
	_busy = false
	return total


## Keywords `card` has from auras, attached Tools and its own static abilities.
static func extra_keywords(state: GameState, card: CardInstance) -> Array[CardEnums.Keyword]:
	var result: Array[CardEnums.Keyword] = []
	if _busy:
		return result
	_busy = true
	for source: CardInstance in _sources(state):
		for ability: CardAbility in source.data.abilities():
			if not _applies(state, source, ability, card):
				continue
			var has_kw: bool = false
			for fx: CardAbility.Fx in ability.effects:
				if fx.name == "kw":
					has_kw = true
			if not has_kw:
				continue
			var ctx: AbilityContext = _context(state, source, ability, card)
			if not AbilityRunner.condition_holds_for(ability, ctx):
				continue
			for fx: CardAbility.Fx in ability.effects:
				if fx.name != "kw":
					continue
				for arg: Variant in fx.args:
					var keyword: int = ScriptParser.keyword_from_word(str(arg))
					if keyword >= 0 and not result.has(keyword as CardEnums.Keyword):
						result.append(keyword as CardEnums.Keyword)
	_busy = false
	return result


static func has_extra_keyword(state: GameState, card: CardInstance, keyword: CardEnums.Keyword) -> bool:
	return extra_keywords(state, card).has(keyword)


## Whether `ability` of `source` currently applies to `card` as a stat/keyword effect.
static func _applies(state: GameState, source: CardInstance, ability: CardAbility, card: CardInstance) -> bool:
	match ability.kind:
		CardAbility.Kind.AURA:
			var ctx: AbilityContext = AbilityContext.make(state, ability, source, source.owner)
			return ability.aura_spec != null and TargetResolver.matches(ability.aura_spec, card, ctx)
		CardAbility.Kind.HOST:
			return source.attached_to == card.uid and card.uid != 0
		CardAbility.Kind.STATIC:
			return source == card
	return false


static func _context(state: GameState, source: CardInstance, ability: CardAbility, card: CardInstance) -> AbilityContext:
	var ctx: AbilityContext = AbilityContext.make(state, ability, source, source.owner)
	if ability.kind == CardAbility.Kind.HOST:
		ctx.host = card
	elif source.attached_to != 0:
		ctx.host = state.find_permanent(source.attached_to)
	return ctx


## Permanents on the field that have continuous abilities.
static func _sources(state: GameState) -> Array[CardInstance]:
	var result: Array[CardInstance] = []
	for player: PlayerState in state.players:
		for card: CardInstance in player.field:
			if card.data.has_static_abilities():
				result.append(card)
	return result


# ---- Flags --------------------------------------------------------------------------------------------


## True when a permanent `player_index` controls has a static ability with `flag(name)` whose condition holds. Flags named
## `global_...` count when ANY player controls such a permanent.
static func player_flag(state: GameState, player_index: int, flag: String) -> bool:
	return flag_count(state, player_index, flag) > 0


static func flag_count(state: GameState, player_index: int, flag: String) -> int:
	var total: int = 0
	var is_global: bool = flag.begins_with("global_")
	for source: CardInstance in _sources(state):
		if not is_global and source.owner != player_index:
			continue
		for ability: CardAbility in source.data.abilities():
			if ability.kind != CardAbility.Kind.STATIC:
				continue
			for fx: CardAbility.Fx in ability.effects:
				if fx.name == "flag" and not fx.args.is_empty() and str(fx.args[0]) == flag:
					var ctx: AbilityContext = AbilityContext.make(state, ability, source, source.owner)
					if AbilityRunner.condition_holds_for(ability, ctx):
						total += 1
	return total


## A flag on a specific card (`flag(cant_block)` on a unit).
static func card_flag(state: GameState, card: CardInstance, flag: String) -> bool:
	if not card.data.has_static_abilities():
		return false
	for ability: CardAbility in card.data.abilities():
		if ability.kind != CardAbility.Kind.STATIC:
			continue
		for fx: CardAbility.Fx in ability.effects:
			if fx.name == "flag" and not fx.args.is_empty() and str(fx.args[0]) == flag:
				return AbilityRunner.condition_holds_for(ability, AbilityContext.make(state, ability, card, card.owner))
	return false


## How many times over resources of `kind` created for `player_index` are multiplied (Infinite Pantry, Harvest Festival).
static func resource_multiplier(state: GameState, player_index: int, kind: ResourceKind.Kind) -> int:
	var result: int = 1
	if not ResourceKind.is_resource(kind):
		return 1
	if flag_count(state, player_index, "global_double_resources") > 0:
		result *= 2
	if kind == ResourceKind.Kind.INGREDIENT and flag_count(state, player_index, "double_ingredients") > 0:
		result *= 2
	return result


## Units entering under `player_index`'s control enter exhausted (the opponent's Waiting Room).
static func enters_exhausted(state: GameState, player_index: int) -> bool:
	return flag_count(state, 1 - player_index, "opp_units_enter_exhausted") > 0


## How many Infrastructure `player_index` may play each turn (the base is 1).
static func infrastructure_drops(state: GameState, player_index: int) -> int:
	return GameState.INFRASTRUCTURE_DROPS_PER_TURN + flag_count(state, player_index, "extra_infra_drop")


# ---- Costs ---------------------------------------------------------------------------------------------------


## The generic cost increase `player_index` pays for playing `data` because of the opponent's permanents.
static func cost_increase(state: GameState, player_index: int, data: CardData) -> int:
	var total: int = 0
	for source: CardInstance in _sources(state):
		for ability: CardAbility in source.data.abilities():
			if ability.kind != CardAbility.Kind.STATIC:
				continue
			for fx: CardAbility.Fx in ability.effects:
				if fx.name != "cost_plus":
					continue
				var who: String = str(fx.args[0])
				var applies_to_player: bool = (who == "opp" and source.owner != player_index) or (who == "me" and source.owner == player_index) or who == "any"
				if not applies_to_player or not _kind_matches(str(fx.args[1]), data):
					continue
				var ctx: AbilityContext = AbilityContext.make(state, ability, source, source.owner)
				if AbilityRunner.condition_holds_for(ability, ctx):
					ctx.vars["player"] = player_index
					total += AbilityRunner.eval_int(fx.args[2], ctx)
	return total


static func _kind_matches(word: String, data: CardData) -> bool:
	match word:
		"any":
			return true
		"spell":
			return data.type == CardEnums.CardType.SPELL
		"unit":
			return data.is_unit()
		"tool":
			return data.is_tool()
		"wonder":
			return data.is_wonder()
		"trap":
			return data.type == CardEnums.CardType.TRAP
	return false


## A card's own cost override while it is being played ("costs only (B)"): {"generic": int, "pips": Array[Affinity.Type]}, or {}.
static func cost_override(state: GameState, player_index: int, card: CardInstance) -> Dictionary:
	for ability: CardAbility in card.data.abilities():
		if ability.kind != CardAbility.Kind.COST_MOD:
			continue
		for fx: CardAbility.Fx in ability.effects:
			if fx.name != "cost_set":
				continue
			var ctx: AbilityContext = AbilityContext.make(state, ability, card, player_index)
			if not AbilityRunner.condition_holds_for(ability, ctx):
				continue
			var pips: Array[Affinity.Type] = []
			for i: int in range(1, fx.args.size()):
				var path: Affinity.Type = Affinity.from_symbol(str(fx.args[i]))
				if path != Affinity.Type.NEUTRAL:
					pips.append(path)
			return {"generic": AbilityRunner.eval_int(fx.args[0], ctx), "pips": pips}
	return {}
