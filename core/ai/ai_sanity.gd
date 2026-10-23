class_name AISanity
extends RefCounted
## Battle AI upgrade (Oct 23): cheap "a human would never" filters on the candidate actions before any search looks at them.
## They remove the plays the audit saw most often: harmful effects aimed at the AI's own units (Portal Ripper on its own Militia),
## helpful ones aimed at the foe, Iron outside Main 1 or on a unit that cannot attack, Red Tape / Contracts on units too small to
## matter (and never on friends), Tools re-attached to the unit they already sit on, and more than the three best targets per
## resource trick. Everything left is legal and plausible; the planner decides what is good.

const RESOURCE_TARGETS: int = 3


## The actions worth searching from `actions` (a `legal_actions()` list) for `me`.
static func filter(state: GameState, me: int, actions: Array[GameAction], use_resources: bool) -> Array[GameAction]:
	var kept: Array[GameAction] = []
	var resource_picks: Dictionary = {}
	var side_info: Dictionary = _side_availability(state, actions)
	var attackers_now: Array[CardInstance] = state.possible_attackers(me) if state.in_main_phase() and state.active == me else ([] as Array[CardInstance])
	for action: GameAction in actions:
		match action.type:
			GameAction.Type.PLAY, GameAction.Type.ACTIVATE_ABILITY:
				if not _side_ok(state, me, action, side_info):
					continue
				if action.type == GameAction.Type.ACTIVATE_ABILITY and _reattaches_same_unit(state, action):
					continue
				kept.append(action)
			GameAction.Type.USE_RESOURCE:
				if not use_resources:
					continue
				var rank: float = resource_use_rank(state, me, action, attackers_now)
				if rank <= 0.0:
					continue
				var kind: int = action.effect_index
				var list: Array = resource_picks.get(kind, []) as Array
				list.append({"action": action, "rank": rank})
				resource_picks[kind] = list
			GameAction.Type.ACTIVATE, GameAction.Type.PLAY_INFRASTRUCTURE:
				kept.append(action)
			_:
				pass
	for kind: Variant in resource_picks.keys():
		var list: Array = resource_picks[kind] as Array
		list.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return float(a["rank"]) > float(b["rank"]))
		for i: int in range(mini(RESOURCE_TARGETS, list.size())):
			kept.append((list[i] as Dictionary)["action"] as GameAction)
	return kept


## Whether a unit should ever be declared as an attacker: it must hit for something, or have an "attacks" ability.
static func worth_attacking_with(state: GameState, card: CardInstance) -> bool:
	if state.get_attack(card) > 0:
		return true
	for ability: CardAbility in card.data.abilities():
		if ability.kind == CardAbility.Kind.ATTACK:
			return true
	return false


## How sensible a resource use is (0 = never). Iron: Main 1, on my own unit that can attack this turn, ranked by its attack. Red Tape
## (-2/-0 until my next turn): on a foe unit with at least 2 attack that can block this turn (Main 1) or attack next turn; the
## biggest first. Contract (exhaust, no refresh): on a foe unit that could block now or attack next turn; the biggest first.
static func resource_use_rank(state: GameState, me: int, action: GameAction, attackers_now: Array[CardInstance]) -> float:
	var kind: ResourceKind.Kind = action.effect_index as ResourceKind.Kind
	if not state.in_main_phase():
		return 0.0
	var target: CardInstance = state.find_permanent(action.target)
	if target == null or not target.data.is_unit():
		return 0.0
	var attack: int = state.get_attack(target)
	match kind:
		ResourceKind.Kind.IRON:
			if target.owner != me or state.phase != GameState.Phase.MAIN1:
				return 0.0
			if not attackers_now.has(target):
				return 0.0
			return 1.0 + float(attack) + (1.0 if state.unit_has_keyword(target, CardEnums.Keyword.FLYING) or state.unit_has_keyword(target, CardEnums.Keyword.ELUSIVE) else 0.0)
		ResourceKind.Kind.RED_TAPE:
			if target.owner == me or attack < 2:
				return 0.0
			var can_block_now: bool = state.phase == GameState.Phase.MAIN1 and not target.exhausted and not attackers_now.is_empty()
			var attacks_next_turn: bool = not state.unit_has_keyword(target, CardEnums.Keyword.WALLFLOWER) and not (target.exhausted and target.skip_refresh > 0)
			if not can_block_now and not attacks_next_turn:
				return 0.0
			return float(attack) + (0.5 if can_block_now else 0.0)
		ResourceKind.Kind.CONTRACT:
			if target.owner == me:
				return 0.0
			if target.exhausted and target.skip_refresh > 0:
				return 0.0
			var blocks_now: bool = state.phase == GameState.Phase.MAIN1 and not target.exhausted and not attackers_now.is_empty()
			var attacks_later: bool = not state.unit_has_keyword(target, CardEnums.Keyword.WALLFLOWER) and attack > 0
			if not blocks_now and not attacks_later:
				return 0.0
			return float(attack) + float(state.get_defense(target)) * 0.5 + (0.5 if blocks_now else 0.0)
	return 0.0


# ---- Target sides -------------------------------------------------------------------------------------------------------------------


## For every (card, ability) group among the actions: per declaration index, whether a target on the foe's side / on my side is on offer.
static func _side_availability(state: GameState, actions: Array[GameAction]) -> Dictionary:
	var info: Dictionary = {}
	for action: GameAction in actions:
		if action.type != GameAction.Type.PLAY and action.type != GameAction.Type.ACTIVATE_ABILITY:
			continue
		var ability: CardAbility = _ability_of(state, action)
		if ability == null or ability.targets.is_empty() or action.targets.is_empty():
			continue
		var key: String = _group_key(action)
		var entry: Dictionary = info.get(key, {}) as Dictionary
		var refs: Array[Array] = _targets_by_declaration(ability, action.targets)
		for index: int in range(refs.size()):
			for ref: int in refs[index]:
				var side: String = _side_of(state, action.player, ref)
				if side.is_empty():
					continue
				var sides: Dictionary = entry.get(index, {}) as Dictionary
				sides[side] = true
				entry[index] = sides
		info[key] = entry
	return info


## False when the action aims a harmful effect at my own card (or a helpful one at the foe's) while the other side is available.
static func _side_ok(state: GameState, me: int, action: GameAction, side_info: Dictionary) -> bool:
	var ability: CardAbility = _ability_of(state, action)
	if ability == null or ability.targets.is_empty() or action.targets.is_empty():
		return true
	var entry: Dictionary = side_info.get(_group_key(action), {}) as Dictionary
	var refs: Array[Array] = _targets_by_declaration(ability, action.targets)
	for index: int in range(mini(refs.size(), ability.targets.size())):
		var decl: CardAbility.TargetDecl = ability.targets[index]
		if decl.spec != null and not decl.spec.side.is_empty():
			continue  # the card itself says which side; a cost like "destroy a unit you control" is deliberate
		var polarity: int = TargetResolver.polarity(ability, decl.name)
		if polarity == 0:
			continue
		var sides: Dictionary = entry.get(index, {}) as Dictionary
		for ref: int in refs[index]:
			var side: String = _side_of(state, me, ref)
			if side.is_empty():
				continue
			var wanted: String = "opp" if polarity < 0 else "mine"
			if side != wanted and sides.has(wanted):
				return false
	return true


static func _targets_by_declaration(ability: CardAbility, flat: Array[int]) -> Array[Array]:
	var result: Array[Array] = []
	var cursor: int = 0
	for index: int in range(ability.targets.size()):
		var decl: CardAbility.TargetDecl = ability.targets[index]
		var refs: Array[int] = []
		if decl.max_count > 1:
			refs = flat.slice(cursor)
			cursor = flat.size()
		elif cursor < flat.size():
			refs.append(flat[cursor])
			cursor += 1
		result.append(refs)
	return result


static func _side_of(state: GameState, me: int, ref: int) -> String:
	if ref == 0:
		return ""
	if Targets.is_player(ref):
		return "mine" if Targets.player_index(ref) == me else "opp"
	var card: CardInstance = state.find_card(ref)
	if card == null:
		return ""
	return "mine" if card.owner == me else "opp"


static func _ability_of(state: GameState, action: GameAction) -> CardAbility:
	var card: CardInstance = state.find_card(action.card_uid)
	if card == null:
		return null
	if action.type == GameAction.Type.PLAY:
		return state.play_ability_of(card.data)
	var abilities: Array[CardAbility] = card.data.abilities()
	if action.effect_index < 0 or action.effect_index >= abilities.size():
		return null
	return abilities[action.effect_index]


static func _group_key(action: GameAction) -> String:
	return "%d:%d:%d" % [int(action.type), action.card_uid, action.effect_index]


## A Tool's attach aimed at the unit it is already attached to does nothing but spend the Tool's exhaust.
static func _reattaches_same_unit(state: GameState, action: GameAction) -> bool:
	var card: CardInstance = state.find_card(action.card_uid)
	if card == null or not card.data.is_tool() or action.target == 0:
		return false
	var abilities: Array[CardAbility] = card.data.abilities()
	if action.effect_index >= abilities.size() or abilities[action.effect_index].kind != CardAbility.Kind.ATTACH:
		return false
	return card.attached_to == action.target
