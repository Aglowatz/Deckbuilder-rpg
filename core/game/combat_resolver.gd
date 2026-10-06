class_name CombatResolver
extends RefCounted
## Combat rules: declare attackers, one blocker per attacker, damage (Sucker Punch then
## regular), keyword handling. Operates on a GameState; owns no state of its own.


static func possible_attackers(state: GameState, player_index: int) -> Array[CardInstance]:
	var result: Array[CardInstance] = []
	for card: CardInstance in state.players[player_index].units():
		if _can_attack(card):
			result.append(card)
	return result


static func _can_attack(card: CardInstance) -> bool:
	if card.exhausted or card.has_keyword(CardEnums.Keyword.WALLFLOWER):
		return false
	return not card.summoning_sick or card.has_keyword(CardEnums.Keyword.HUSTLE)


static func possible_blockers(state: GameState, defender_index: int) -> Array[CardInstance]:
	var result: Array[CardInstance] = []
	for card: CardInstance in state.players[defender_index].units():
		if not card.exhausted and not card.cannot_block:
			result.append(card)
	return result


## Flying attackers can only be blocked by Flying or Reach units. New brief, Part B: a
## unit whose controller's equipment forbids blocking (e.g. Hover Boots) can never block.
static func can_block(attacker: CardInstance, blocker: CardInstance) -> bool:
	if blocker.exhausted or not blocker.data.is_unit() or blocker.cannot_block:
		return false
	if attacker.has_keyword(CardEnums.Keyword.FLYING):
		return blocker.has_keyword(CardEnums.Keyword.FLYING) or blocker.has_keyword(CardEnums.Keyword.SWAT)
	return true


## Attackers always attack the opposing player (there is no Guard).
static func declare_attackers(state: GameState, uids: Array[int]) -> bool:
	if not _in_step(state, GameState.CombatStep.DECLARE_ATTACKERS):
		return false
	var defender: int = 1 - state.active
	var allowed: Array[CardInstance] = possible_attackers(state, state.active)
	var chosen: Array[CardInstance] = []
	for uid: int in uids:
		var card: CardInstance = PlayerState.find_in(allowed, uid)
		if card == null or chosen.has(card):
			return false
		chosen.append(card)
	if chosen.is_empty():
		state.finish_combat()
		return true

	for card: CardInstance in chosen:
		if not card.has_keyword(CardEnums.Keyword.OVERTIME):
			card.exhausted = true
		state.attackers.append(card.uid)
		var target_ref: int = Targets.player(defender)
		state.emit_event(GameEvent.Type.ATTACKERS_DECLARED, state.active, card.uid, target_ref, chosen.size())
	for card: CardInstance in chosen:
		if state.attackers.has(card.uid):
			state.fire_trigger(card, CardEnums.Trigger.ON_ATTACK, 0, 0)
	if not state.is_over():
		state.fire_traps(defender, CardEnums.Trigger.TRAP_OPPONENT_ATTACKS, _strongest(state, chosen))
	if not state.is_over():
		state.fire_retaliation(defender)
	if not state.is_over():
		state._fire_modifier_effects(state.active, Modifier.Kind.ON_ATTACK_DECLARED_EFFECT)
	state.check_state()
	if state.is_over():
		return true
	if state.attackers.is_empty():
		state.finish_combat()
	else:
		state.combat_step = GameState.CombatStep.DECLARE_BLOCKERS
	return true


## `assignment` maps attacker uid -> blocker uid. Each blocker blocks at most one attacker.
static func declare_blockers(state: GameState, assignment: Dictionary) -> bool:
	if not _in_step(state, GameState.CombatStep.DECLARE_BLOCKERS):
		return false
	var defender: int = 1 - state.active
	var used: Array[int] = []
	for key: Variant in assignment.keys():
		var attacker_uid: int = int(key)
		var blocker_uid: int = int(assignment[key])
		if not state.attackers.has(attacker_uid) or used.has(blocker_uid):
			return false
		var attacker: CardInstance = state.find_permanent(attacker_uid)
		var blocker: CardInstance = state.players[defender].find_field(blocker_uid)
		if attacker == null or blocker == null or not can_block(attacker, blocker):
			return false
		used.append(blocker_uid)

	for key: Variant in assignment.keys():
		var attacker_uid: int = int(key)
		var blocker_uid: int = int(assignment[key])
		state.blocks[attacker_uid] = blocker_uid
		state.blocked_attackers[attacker_uid] = true
		state.emit_event(GameEvent.Type.BLOCKER_ASSIGNED, defender, blocker_uid, attacker_uid)
	for key: Variant in assignment.keys():
		var blocker: CardInstance = state.find_permanent(int(assignment[key]))
		if blocker != null:
			state.fire_trigger(blocker, CardEnums.Trigger.ON_BLOCK, int(key), 0)
	state.check_state()
	if state.is_over():
		return true
	resolve_damage(state)
	if not state.is_over():
		state.finish_combat()
	return true


## First-strike damage step (if anyone has Sucker Punch), then the regular damage step.
static func resolve_damage(state: GameState) -> void:
	if _any_first_strike(state):
		_damage_step(state, true)
		state.check_state()
		if state.is_over():
			return
	_damage_step(state, false)
	state.check_state()


static func _damage_step(state: GameState, first_strike_step: bool) -> void:
	var plan: Array[Dictionary] = []
	var defender: int = 1 - state.active
	for attacker_uid: int in state.attackers.duplicate():
		var attacker: CardInstance = state.find_permanent(attacker_uid)
		if attacker == null:
			continue
		var blocker: CardInstance = null
		if state.blocks.has(attacker_uid):
			blocker = state.find_permanent(int(state.blocks[attacker_uid]))
		if _deals_damage_now(attacker, first_strike_step):
			var attack: int = state.get_attack(attacker)
			var attacked: int = Targets.player(defender)
			if attack > 0:
				if blocker != null:
					var to_blocker: int = attack
					var excess: int = 0
					if attacker.has_keyword(CardEnums.Keyword.BULLDOZE):
						var lethal: int = maxi(0, state.get_defense(blocker) - blocker.damage)
						to_blocker = mini(attack, lethal)
						excess = attack - to_blocker
					plan.append(_entry(attacker.uid, blocker.uid, to_blocker))
					plan.append(_entry(attacker.uid, attacked, excess))
				elif state.blocked_attackers.has(attacker_uid):
					if attacker.has_keyword(CardEnums.Keyword.BULLDOZE):
						plan.append(_entry(attacker.uid, attacked, attack))
				else:
					plan.append(_entry(attacker.uid, attacked, attack))
		if blocker != null and _deals_damage_now(blocker, first_strike_step):
			plan.append(_entry(blocker.uid, attacker.uid, state.get_attack(blocker)))
	# Damage is simultaneous: postpone deaths until every hit in this step has landed.
	state.defer_state_checks += 1
	for entry: Dictionary in plan:
		if state.is_over():
			break
		_apply_damage(state, int(entry["source"]), int(entry["target"]), int(entry["amount"]))
	state.defer_state_checks -= 1


static func _entry(source_uid: int, target_ref: int, amount: int) -> Dictionary:
	return {"source": source_uid, "target": target_ref, "amount": amount}


static func _apply_damage(state: GameState, source_uid: int, target_ref: int, amount: int) -> void:
	if amount <= 0:
		return
	if Targets.is_player(target_ref):
		state.deal_damage_to_player(source_uid, Targets.player_index(target_ref), amount)
	else:
		var target: CardInstance = state.find_permanent(target_ref)
		if target != null:
			state.deal_damage_to_unit(source_uid, target, amount)


## First strikers deal damage in the first step only; everyone else in the regular step.
static func _deals_damage_now(card: CardInstance, first_strike_step: bool) -> bool:
	return card.has_keyword(CardEnums.Keyword.SUCKER_PUNCH) == first_strike_step


static func _any_first_strike(state: GameState) -> bool:
	for attacker_uid: int in state.attackers:
		var attacker: CardInstance = state.find_permanent(attacker_uid)
		if attacker != null and attacker.has_keyword(CardEnums.Keyword.SUCKER_PUNCH):
			return true
		if state.blocks.has(attacker_uid):
			var blocker: CardInstance = state.find_permanent(int(state.blocks[attacker_uid]))
			if blocker != null and blocker.has_keyword(CardEnums.Keyword.SUCKER_PUNCH):
				return true
	return false


static func _strongest(state: GameState, cards: Array[CardInstance]) -> int:
	var best: CardInstance = cards[0]
	for card: CardInstance in cards:
		if state.get_attack(card) > state.get_attack(best):
			best = card
	return best.uid


static func _in_step(state: GameState, step: GameState.CombatStep) -> bool:
	return (
		state.stage == GameState.Stage.PLAYING
		and state.phase == GameState.Phase.COMBAT
		and state.combat_step == step
		and state.pending_toss == 0
	)
