class_name AIPlayer
extends RefCounted
## Heuristic AI. For every decision it clones the game state, applies each candidate action
## to the clone and scores the resulting position one step ahead (for attacks, including the
## opponent's best blocking reply). Behaviour is tuned by an AIPersonality resource.
## The AI never peeks at hidden information: opponent traps are removed from its clones.

const WIN_SCORE: float = 100000.0
const BOARD_UNIT: float = 0.5
const LETHAL_THREAT: float = 20.0
const EPSILON: float = 0.05
const MAX_BLOCK_ENUMERATION: int = 12

var personality: AIPersonality


func _init(ai_personality: AIPersonality = null) -> void:
	personality = ai_personality if ai_personality != null else AIPersonality.balanced()


## Picks the next action for whoever the game is waiting on (`state.awaiting_player()`).
func choose_action(state: GameState) -> GameAction:
	var who: int = state.awaiting_player()
	if who < 0:
		return GameAction.pass_phase(0)
	if state.stage == GameState.Stage.MULLIGAN:
		return _choose_mulligan(state, who)
	if state.pending_discard > 0:
		return _choose_discard(state, who)
	if state.phase == GameState.Phase.COMBAT:
		if state.combat_step == GameState.CombatStep.DECLARE_ATTACKERS:
			return _choose_attack(state, who)
		return _choose_block_action(state, who)
	return _choose_main_action(state, who)


# --------------------------------------------------------------------------------------
# Evaluation
# --------------------------------------------------------------------------------------


## Position score from `me`'s point of view (higher is better).
func evaluate(state: GameState, me: int) -> float:
	if state.is_over():
		if state.is_draw:
			return 0.0
		return WIN_SCORE if state.winner == me else -WIN_SCORE
	var mine: PlayerState = state.players[me]
	var foe: PlayerState = state.players[1 - me]
	var score: float = 0.0
	score += personality.life_weight * _life_value(mine.life)
	score -= personality.enemy_life_weight * _life_value(foe.life)
	score += personality.board_weight * _board_value(state, mine)
	score -= personality.enemy_board_weight * _board_value(state, foe)
	score += personality.hand_weight * (_hand_value(mine) - _hand_value(foe))
	score += personality.mana_weight * float(mine.lands.size())
	score -= personality.threat_weight * _threat(state, mine, foe)
	return score


## Life matters more the lower it gets.
func _life_value(life: int) -> float:
	return float(life) - maxf(0.0, 6.0 - float(life)) * 0.5


func _board_value(state: GameState, player: PlayerState) -> float:
	var total: float = 0.0
	for card: CardInstance in player.battlefield:
		if card.data.is_creature():
			total += float(EffectResolver.creature_value(state, card)) * BOARD_UNIT
		else:
			total += 2.0
	total += 2.0 * float(player.traps.size())
	return total


func _hand_value(player: PlayerState) -> float:
	var total: float = 0.0
	for card: CardInstance in player.hand:
		total += 0.4 if card.data.is_land() else 1.0
	return total


## Damage the opponent could deal next turn after my untapped creatures block their strongest
## attackers, plus a big penalty if that is lethal.
func _threat(state: GameState, mine: PlayerState, foe: PlayerState) -> float:
	var blockers: int = 0
	for card: CardInstance in mine.creatures():
		if not card.tapped:
			blockers += 1
	var powers: Array[int] = []
	for card: CardInstance in foe.creatures():
		if not card.has_keyword(CardEnums.Keyword.DEFENDER):
			powers.append(state.get_power(card))
	powers.sort()
	powers.reverse()
	var remaining: int = 0
	for i: int in range(powers.size()):
		if i >= blockers:
			remaining += powers[i]
	return float(remaining) + (LETHAL_THREAT if remaining >= mine.life else 0.0)


# --------------------------------------------------------------------------------------
# Mulligan and discards
# --------------------------------------------------------------------------------------


func _choose_mulligan(state: GameState, who: int) -> GameAction:
	var player: PlayerState = state.players[who]
	var lands: int = HandSmoother.count_lands(player.hand)
	var size: int = player.hand.size()
	var bad_hand: bool = lands < 2 or lands > size - 2
	if bad_hand and not player.mulligan_used and state.options.free_mulligan:
		return GameAction.make(GameAction.Type.MULLIGAN, who)
	return GameAction.make(GameAction.Type.KEEP_HAND, who)


func _choose_discard(state: GameState, who: int) -> GameAction:
	var player: PlayerState = state.players[who]
	var ranked: Array[CardInstance] = player.hand.duplicate()
	var lands_out: int = player.lands.size()
	ranked.sort_custom(func(a: CardInstance, b: CardInstance) -> bool:
		return _keep_value(a, lands_out) < _keep_value(b, lands_out)
	)
	var action: GameAction = GameAction.make(GameAction.Type.DISCARD, who)
	for i: int in range(state.pending_discard):
		action.uids.append(ranked[i].uid)
	return action


func _keep_value(card: CardInstance, lands_out: int) -> float:
	if card.data.is_land():
		return 4.0 if lands_out < 5 else 0.5
	return float(card.data.mana_value()) + 1.5


# --------------------------------------------------------------------------------------
# Main phases
# --------------------------------------------------------------------------------------


func _choose_main_action(state: GameState, who: int) -> GameAction:
	var actions: Array[GameAction] = state.legal_actions()
	var land_actions: Array[GameAction] = []
	for action: GameAction in actions:
		if action.type == GameAction.Type.PLAY_LAND:
			land_actions.append(action)
	if not land_actions.is_empty():
		return _best_land(state, who, land_actions)
	var baseline: float = evaluate(state, who)
	var best: GameAction = GameAction.pass_phase(who)
	var best_gain: float = EPSILON
	for action: GameAction in actions:
		if action.type != GameAction.Type.CAST and action.type != GameAction.Type.ACTIVATE:
			continue
		var trial: GameState = state.clone(false, 1 - who)
		if not trial.apply_action(action):
			continue
		var gain: float = evaluate(trial, who) - baseline
		if gain > best_gain:
			best_gain = gain
			best = action
	return best


## Plays the land type the hand needs most (pips in hand vs lands already out).
func _best_land(state: GameState, who: int, land_actions: Array[GameAction]) -> GameAction:
	var player: PlayerState = state.players[who]
	var need: Dictionary = {}
	for card: CardInstance in player.hand:
		for pip: Affinity.Type in card.data.colored_pips:
			need[pip] = float(need.get(pip, 0.0)) + 1.0
	var have: Dictionary = {}
	for land: CardInstance in player.lands:
		have[land.data.color] = int(have.get(land.data.color, 0)) + 1
	var best: GameAction = land_actions[0]
	var best_score: float = -INF
	for action: GameAction in land_actions:
		var color: Affinity.Type = state.find_card(action.card_uid).data.color
		var score: float = float(need.get(color, 0.0)) / float(1 + int(have.get(color, 0)))
		if score > best_score:
			best_score = score
			best = action
	return best


# --------------------------------------------------------------------------------------
# Attacking
# --------------------------------------------------------------------------------------


func _choose_attack(state: GameState, who: int) -> GameAction:
	var available: Array[CardInstance] = state.possible_attackers(who)
	if available.is_empty():
		return GameAction.pass_phase(who)
	var best_uids: Array[int] = []
	var best_score: float = -INF
	for candidate: Array[int] in _attack_candidates(state, who, available):
		var trial: GameState = state.clone(false, 1 - who)
		if not trial.declare_attackers(candidate):
			continue
		if not trial.is_over() and trial.awaiting_player() == 1 - who and trial.combat_step == GameState.CombatStep.DECLARE_BLOCKERS:
			# Model the opponent's best reply.
			trial.declare_blockers(choose_blocks(trial, 1 - who))
		var score: float = evaluate(trial, who) + personality.attack_bias * float(candidate.size())
		if score > best_score:
			best_score = score
			best_uids = candidate
	if best_uids.is_empty():
		return GameAction.pass_phase(who)
	var action: GameAction = GameAction.make(GameAction.Type.DECLARE_ATTACKERS, who)
	action.uids = best_uids
	return action


func _attack_candidates(state: GameState, who: int, available: Array[CardInstance]) -> Array[Array]:
	var candidates: Array[Array] = []
	var seen: Dictionary = {}
	var options: Array[Array] = [[] as Array[int]]
	var everyone: Array[int] = []
	for card: CardInstance in available:
		everyone.append(card.uid)
	options.append(everyone)
	if available.size() <= 6:
		for uid: int in everyone:
			options.append([uid] as Array[int])
	# Attackers that no enemy blocker could kill without help ("safe" attackers).
	var strongest_foe: int = 0
	for card: CardInstance in state.players[1 - who].creatures():
		if not card.tapped:
			strongest_foe = maxi(strongest_foe, state.get_power(card))
	var safe: Array[int] = []
	for card: CardInstance in available:
		if state.get_toughness(card) > strongest_foe or card.has_keyword(CardEnums.Keyword.FLYING):
			safe.append(card.uid)
	options.append(safe)
	var by_power: Array[CardInstance] = available.duplicate()
	by_power.sort_custom(func(a: CardInstance, b: CardInstance) -> bool: return state.get_power(a) > state.get_power(b))
	var top: Array[int] = []
	for i: int in range(mini(2, by_power.size())):
		top.append(by_power[i].uid)
	options.append(top)
	for option: Array in options:
		var sorted_option: Array = option.duplicate()
		sorted_option.sort()
		var key: String = str(sorted_option)
		if seen.has(key):
			continue
		seen[key] = true
		var typed: Array[int] = []
		for uid: Variant in option:
			typed.append(int(uid))
		candidates.append(typed)
	return candidates


# --------------------------------------------------------------------------------------
# Blocking
# --------------------------------------------------------------------------------------


func _choose_block_action(state: GameState, who: int) -> GameAction:
	var blocks: Dictionary = choose_blocks(state, who)
	if blocks.is_empty():
		return GameAction.pass_phase(who)
	var action: GameAction = GameAction.make(GameAction.Type.DECLARE_BLOCKERS, who)
	action.blocks = blocks
	return action


## Best assignment (attacker uid -> blocker uid) for defender `who`, chosen by look-ahead.
func choose_blocks(state: GameState, who: int) -> Dictionary:
	var attackers: Array[CardInstance] = []
	for uid: int in state.attackers:
		var card: CardInstance = state.find_permanent(uid)
		if card != null:
			attackers.append(card)
	var blockers: Array[CardInstance] = state.possible_blockers(who)
	if attackers.is_empty() or blockers.is_empty():
		return {}
	var candidates: Array[Dictionary] = [{}]
	candidates.append(_value_blocks(state, attackers, blockers))
	candidates.append(_add_chump_blocks(state, who, attackers, blockers, _value_blocks(state, attackers, blockers)))
	candidates.append(_add_chump_blocks(state, who, attackers, blockers, {}))
	candidates.append_array(_enumerate_blocks(attackers, blockers))
	var best: Dictionary = {}
	var best_score: float = -INF
	var seen: Dictionary = {}
	for candidate: Dictionary in candidates:
		var key: String = str(candidate)
		if seen.has(key):
			continue
		seen[key] = true
		var trial: GameState = state.clone(false, 1 - who)
		if not trial.declare_blockers(candidate):
			continue
		var score: float = evaluate(trial, who) + personality.block_bias * float(candidate.size())
		if score > best_score:
			best_score = score
			best = candidate
	return best


## Blocks that kill the attacker (and survive), or trade evenly/favourably.
func _value_blocks(state: GameState, attackers: Array[CardInstance], blockers: Array[CardInstance]) -> Dictionary:
	var assignment: Dictionary = {}
	var used: Array[int] = []
	var ordered: Array[CardInstance] = attackers.duplicate()
	ordered.sort_custom(func(a: CardInstance, b: CardInstance) -> bool: return state.get_power(a) > state.get_power(b))
	for attacker: CardInstance in ordered:
		var best: CardInstance = null
		var best_rank: int = -1
		for blocker: CardInstance in blockers:
			if used.has(blocker.uid) or not CombatResolver.can_block(attacker, blocker):
				continue
			var kills: bool = state.get_power(blocker) >= state.get_toughness(attacker) - attacker.damage
			var survives: bool = state.get_toughness(blocker) - blocker.damage > state.get_power(attacker)
			var rank: int = -1
			if kills and survives:
				rank = 2
			elif kills and EffectResolver.creature_value(state, attacker) >= EffectResolver.creature_value(state, blocker):
				rank = 1
			if rank > best_rank or (rank == best_rank and rank >= 0 and EffectResolver.creature_value(state, blocker) < EffectResolver.creature_value(state, best)):
				best_rank = rank
				best = blocker
		if best != null and best_rank >= 0:
			assignment[attacker.uid] = best.uid
			used.append(best.uid)
	return assignment


## Adds the cheapest blockers onto the strongest attackers until the remaining damage is not lethal.
func _add_chump_blocks(
	state: GameState,
	who: int,
	attackers: Array[CardInstance],
	blockers: Array[CardInstance],
	base: Dictionary,
) -> Dictionary:
	var assignment: Dictionary = base.duplicate()
	var used: Array[int] = []
	for key: Variant in assignment.keys():
		used.append(int(assignment[key]))
	var unblocked: Array[CardInstance] = []
	for attacker: CardInstance in attackers:
		if not assignment.has(attacker.uid):
			unblocked.append(attacker)
	unblocked.sort_custom(func(a: CardInstance, b: CardInstance) -> bool: return state.get_power(a) > state.get_power(b))
	var incoming: int = 0
	for attacker: CardInstance in unblocked:
		incoming += state.get_power(attacker)
	var free_blockers: Array[CardInstance] = []
	for blocker: CardInstance in blockers:
		if not used.has(blocker.uid):
			free_blockers.append(blocker)
	free_blockers.sort_custom(func(a: CardInstance, b: CardInstance) -> bool: return EffectResolver.creature_value(state, a) < EffectResolver.creature_value(state, b))
	for attacker: CardInstance in unblocked:
		if incoming < state.players[who].life:
			break
		for blocker: CardInstance in free_blockers:
			if CombatResolver.can_block(attacker, blocker):
				assignment[attacker.uid] = blocker.uid
				free_blockers.erase(blocker)
				incoming -= state.get_power(attacker)
				break
	return assignment


## Every legal assignment when the search space is tiny.
func _enumerate_blocks(attackers: Array[CardInstance], blockers: Array[CardInstance]) -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	var combos: int = 1
	for i: int in range(attackers.size()):
		combos *= blockers.size() + 1
		if combos > MAX_BLOCK_ENUMERATION:
			return results
	_enumerate_from(0, attackers, blockers, {}, [] as Array[int], results)
	return results


func _enumerate_from(
	index: int,
	attackers: Array[CardInstance],
	blockers: Array[CardInstance],
	current: Dictionary,
	used: Array[int],
	results: Array[Dictionary],
) -> void:
	if index >= attackers.size():
		results.append(current.duplicate())
		return
	var attacker: CardInstance = attackers[index]
	_enumerate_from(index + 1, attackers, blockers, current, used, results)
	for blocker: CardInstance in blockers:
		if used.has(blocker.uid) or not CombatResolver.can_block(attacker, blocker):
			continue
		current[attacker.uid] = blocker.uid
		used.append(blocker.uid)
		_enumerate_from(index + 1, attackers, blockers, current, used, results)
		used.erase(blocker.uid)
		current.erase(attacker.uid)
