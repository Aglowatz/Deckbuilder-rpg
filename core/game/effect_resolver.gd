class_name EffectResolver
extends RefCounted
## Data-driven effect resolution: finds the targets of an EffectData and applies its operation.
## There is no stack or priority; effects resolve immediately, in order.

## Nested trigger chains deeper than this are cut off (guards against infinite loops).
const MAX_TRIGGER_DEPTH: int = 12


## Fires every effect on `card` with the given trigger.
static func fire(state: GameState, card: CardInstance, trigger: CardEnums.Trigger, trigger_uid: int, chosen: int) -> void:
	if state.is_over() or state.trigger_depth >= MAX_TRIGGER_DEPTH:
		return
	var effects: Array[EffectData] = card.data.effects_for(trigger)
	if effects.is_empty():
		return
	state.trigger_depth += 1
	state.emit_event(GameEvent.Type.EFFECT_TRIGGERED, card.owner, card.uid, trigger_uid, int(trigger))
	for effect: EffectData in effects:
		resolve(state, effect, EffectContext.make(card.uid, card.owner, trigger_uid, chosen))
	state.trigger_depth -= 1


## Fires `trigger` on all of a player's set traps. Each triggered trap is used up.
static func fire_traps(state: GameState, owner_index: int, trigger: CardEnums.Trigger, trigger_uid: int) -> void:
	var owner: PlayerState = state.players[owner_index]
	for trap: CardInstance in owner.traps.duplicate():
		if state.is_over():
			return
		if not trap.data.has_trigger(trigger) or not owner.traps.has(trap):
			continue
		owner.traps.erase(trap)
		trap.face_down = false
		state.emit_event(GameEvent.Type.TRAP_TRIGGERED, owner_index, trap.uid, trigger_uid, int(trigger))
		for effect: EffectData in trap.data.effects_for(trigger):
			resolve(state, effect, EffectContext.make(trap.uid, owner_index, trigger_uid, 0))
		trap.reset()
		owner.graveyard.append(trap)


static func resolve(state: GameState, effect: EffectData, ctx: EffectContext) -> void:
	if state.is_over():
		return
	for target_ref: int in resolve_targets(state, effect, ctx):
		if state.is_over():
			return
		_apply(state, effect, ctx, target_ref)
	if state.defer_state_checks == 0:
		state.check_state()


# --------------------------------------------------------------------------------------
# Targeting
# --------------------------------------------------------------------------------------


static func resolve_targets(state: GameState, effect: EffectData, ctx: EffectContext) -> Array[int]:
	var result: Array[int] = []
	var me: int = ctx.controller
	var foe: int = 1 - me
	match effect.target:
		CardEnums.TargetKind.SELF:
			if ctx.source_uid > 0 and state.find_permanent(ctx.source_uid) != null:
				result.append(ctx.source_uid)
		CardEnums.TargetKind.CONTROLLER:
			result.append(Targets.player(me))
		CardEnums.TargetKind.OPPONENT:
			result.append(Targets.player(foe))
		CardEnums.TargetKind.TRIGGERING_CARD:
			if ctx.trigger_uid > 0 and state.find_permanent(ctx.trigger_uid) != null:
				result.append(ctx.trigger_uid)
		CardEnums.TargetKind.CHOSEN_CREATURE_ANY, CardEnums.TargetKind.CHOSEN_CREATURE_ENEMY, \
		CardEnums.TargetKind.CHOSEN_CREATURE_ALLY, CardEnums.TargetKind.CHOSEN_PLAYER:
			var legal: Array[int] = legal_targets(state, me, effect)
			if ctx.chosen != 0 and _ref_matches_kind(effect.target, ctx.chosen):
				# The picked target may have died since being chosen: the effect then fizzles.
				if legal.has(ctx.chosen):
					result.append(ctx.chosen)
			else:
				var picked: int = auto_pick(state, effect, me, legal)
				if picked != 0:
					result.append(picked)
		CardEnums.TargetKind.ALL_CREATURES:
			for card: CardInstance in state.all_creatures():
				result.append(card.uid)
		CardEnums.TargetKind.ALL_ENEMY_CREATURES:
			for card: CardInstance in state.players[foe].creatures():
				result.append(card.uid)
		CardEnums.TargetKind.ALL_ALLY_CREATURES:
			for card: CardInstance in state.players[me].creatures():
				result.append(card.uid)
		CardEnums.TargetKind.ALL_PLAYERS:
			result.append(Targets.player(0))
			result.append(Targets.player(1))
		CardEnums.TargetKind.ALL_ATTACKERS:
			for uid: int in state.attackers:
				result.append(uid)
		CardEnums.TargetKind.RANDOM_CREATURE, CardEnums.TargetKind.RANDOM_ENEMY_CREATURE, \
		CardEnums.TargetKind.RANDOM_ALLY_CREATURE:
			var pool: Array[CardInstance] = []
			if effect.target == CardEnums.TargetKind.RANDOM_CREATURE:
				pool = state.all_creatures()
			elif effect.target == CardEnums.TargetKind.RANDOM_ENEMY_CREATURE:
				pool = state.players[foe].creatures()
			else:
				pool = state.players[me].creatures()
			if not pool.is_empty():
				result.append((RngUtil.pick(pool, state.rng) as CardInstance).uid)
	return result


## Targets (Targets refs) the acting player may choose for a chosen-target effect.
static func legal_targets(state: GameState, controller: int, effect: EffectData) -> Array[int]:
	var result: Array[int] = []
	match effect.target:
		CardEnums.TargetKind.CHOSEN_CREATURE_ANY:
			for card: CardInstance in state.all_creatures():
				result.append(card.uid)
		CardEnums.TargetKind.CHOSEN_CREATURE_ENEMY:
			for card: CardInstance in state.players[1 - controller].creatures():
				result.append(card.uid)
		CardEnums.TargetKind.CHOSEN_CREATURE_ALLY:
			for card: CardInstance in state.players[controller].creatures():
				result.append(card.uid)
		CardEnums.TargetKind.CHOSEN_PLAYER:
			result.append(Targets.player(controller))
			result.append(Targets.player(1 - controller))
	return result


static func _ref_matches_kind(kind: CardEnums.TargetKind, ref: int) -> bool:
	if kind == CardEnums.TargetKind.CHOSEN_PLAYER:
		return Targets.is_player(ref)
	return ref > 0


## Engine-side targeting for effects that fire without a player choice (triggers): harmful
## effects go for the strongest enemy, helpful ones for the strongest ally.
static func auto_pick(state: GameState, effect: EffectData, controller: int, legal: Array[int]) -> int:
	if legal.is_empty():
		return 0
	var harmful: bool = is_harmful(effect)
	var best_ref: int = 0
	var best_score: int = -1
	for ref: int in legal:
		var owner_index: int
		var value: int
		if Targets.is_player(ref):
			owner_index = Targets.player_index(ref)
			value = 3
		else:
			var card: CardInstance = state.find_permanent(ref)
			if card == null:
				continue
			owner_index = card.owner
			value = creature_value(state, card)
		var on_right_side: bool = (owner_index != controller) == harmful
		var score: int = value + (10000 if on_right_side else 0)
		if score > best_score:
			best_score = score
			best_ref = ref
	return best_ref


static func is_harmful(effect: EffectData) -> bool:
	match effect.op:
		CardEnums.EffectOp.DEAL_DAMAGE, CardEnums.EffectOp.DESTROY, CardEnums.EffectOp.LOSE_LIFE, \
		CardEnums.EffectOp.DISCARD, CardEnums.EffectOp.MILL, CardEnums.EffectOp.RETURN_TO_HAND:
			return true
		CardEnums.EffectOp.BUFF:
			return effect.amount + effect.amount2 < 0
	return false


## Rough worth of a creature (used for auto-targeting and by the AI).
static func creature_value(state: GameState, card: CardInstance) -> int:
	return state.get_power(card) * 2 + state.get_toughness(card) + card.data.keywords.size() * 2


# --------------------------------------------------------------------------------------
# Operations
# --------------------------------------------------------------------------------------


static func _apply(state: GameState, effect: EffectData, ctx: EffectContext, target_ref: int) -> void:
	var is_player: bool = Targets.is_player(target_ref)
	var player_index: int = Targets.player_index(target_ref) if is_player else -1
	var card: CardInstance = null if is_player else state.find_permanent(target_ref)
	if not is_player and (card == null or not card.data.is_creature()):
		return
	match effect.op:
		CardEnums.EffectOp.DEAL_DAMAGE:
			if is_player:
				state.deal_damage_to_player(ctx.source_uid, player_index, effect.amount)
			else:
				state.deal_damage_to_creature(ctx.source_uid, card, effect.amount)
		CardEnums.EffectOp.HEAL:
			if is_player:
				state.gain_life(player_index, effect.amount)
			else:
				var healed: int = mini(card.damage, effect.amount)
				if healed > 0:
					card.damage -= healed
					state.emit_event(GameEvent.Type.DAMAGE_HEALED, card.owner, card.uid, 0, healed, card.damage)
		CardEnums.EffectOp.DRAW:
			if is_player:
				state.draw_cards(player_index, effect.amount)
		CardEnums.EffectOp.DISCARD:
			if is_player:
				var hand: Array[CardInstance] = state.players[player_index].hand
				for i: int in range(effect.amount):
					if hand.is_empty():
						break
					state.discard_card(player_index, RngUtil.pick(hand, state.rng) as CardInstance)
		CardEnums.EffectOp.DESTROY:
			if not is_player:
				state.kill_creature(card)
		CardEnums.EffectOp.BUFF:
			if not is_player:
				if effect.duration == CardEnums.Duration.PERMANENT:
					card.power_bonus += effect.amount
					card.toughness_bonus += effect.amount2
				else:
					card.temp_power += effect.amount
					card.temp_toughness += effect.amount2
				state.emit_event(GameEvent.Type.STATS_CHANGED, card.owner, card.uid, 0, effect.amount, effect.amount2)
		CardEnums.EffectOp.SUMMON_TOKEN:
			if is_player and effect.token != null:
				for i: int in range(maxi(1, effect.amount)):
					state.create_token(player_index, effect.token)
		CardEnums.EffectOp.RETURN_TO_HAND:
			if not is_player:
				state.return_to_hand(card)
		CardEnums.EffectOp.MILL:
			if is_player:
				state.mill_cards(player_index, effect.amount)
		CardEnums.EffectOp.GAIN_LIFE:
			if is_player:
				state.gain_life(player_index, effect.amount)
		CardEnums.EffectOp.LOSE_LIFE:
			if is_player:
				state.lose_life(player_index, effect.amount)
		CardEnums.EffectOp.GRANT_KEYWORD:
			if not is_player:
				var keyword: CardEnums.Keyword = effect.keyword
				if not card.has_keyword(keyword):
					if effect.duration == CardEnums.Duration.PERMANENT:
						card.granted_keywords.append(keyword)
					else:
						card.temp_keywords.append(keyword)
					state.emit_event(GameEvent.Type.KEYWORD_GRANTED, card.owner, card.uid, 0, int(keyword))
