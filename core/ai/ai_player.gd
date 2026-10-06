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
## What a held resource is worth in position-score points (spending one must gain more than this).
const RESOURCE_VALUE: float = 0.3
## What a set Trap is worth (it will stop or punish something later, so more than a plain permanent).
const TRAP_VALUE: float = 3.0
## Garbage/Ingredients are fuel: worth much more to a player holding cards that spend them.
const FUEL_VALUE: float = 2.0
var _fuel_cache: Dictionary = {}

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
	if state.pending_toss > 0:
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
	score += personality.hp_weight * _hp_value(mine.hp)
	score -= personality.enemy_hp_weight * _hp_value(foe.hp)
	score += personality.board_weight * _board_value(state, mine)
	score -= personality.enemy_board_weight * _board_value(state, foe)
	score += personality.hand_weight * (_hand_value(mine) - _hand_value(foe))
	score += personality.energy_weight * float(mine.infrastructure.size())
	score += RESOURCE_VALUE * (_resource_value(mine) - _resource_value(foe))
	score -= personality.threat_weight * _threat(state, mine, foe)
	return score


## HP matters more the lower it gets.
func _hp_value(hp: int) -> float:
	return float(hp) - maxf(0.0, 6.0 - float(hp)) * 0.5


func _board_value(state: GameState, player: PlayerState) -> float:
	var total: float = 0.0
	for card: CardInstance in player.field:
		if card.data.is_unit():
			total += float(EffectResolver.unit_value(state, card)) * BOARD_UNIT
		else:
			total += 2.0
	total += TRAP_VALUE * float(player.traps.size())
	return total


## Resources are worth holding: a few points for the ones that do something on their own, fewer for the ones cards spend.
func _resource_value(player: PlayerState) -> float:
	var total: float = 0.0
	for resource: CardInstance in player.resources:
		var kind: ResourceKind.Kind = resource.data.resource_kind as ResourceKind.Kind
		if ResourceKind.has_use_ability(kind):
			total += 1.0
		elif _spends(player, kind):
			total += FUEL_VALUE
		else:
			total += 0.6
	return total


## Whether a card in this player's hand or on their table spends `kind` (Eat Garbage, Use an Ingredient...).
func _spends(player: PlayerState, kind: ResourceKind.Kind) -> bool:
	for pile: Array[CardInstance] in [player.hand, player.field, player.infrastructure]:
		for card: CardInstance in pile:
			var key: String = "%s:%d" % [card.data.id, int(kind)]
			if not _fuel_cache.has(key):
				var word: String = ResourceKind.script_word(kind)
				_fuel_cache[key] = card.data.script_text.contains(word) or (kind == ResourceKind.Kind.GARBAGE and card.data.script_text.contains("eat"))
			if bool(_fuel_cache[key]):
				return true
	return false


func _hand_value(player: PlayerState) -> float:
	var total: float = 0.0
	for card: CardInstance in player.hand:
		total += 0.4 if card.data.is_infrastructure() else 1.0
	return total


## Damage the opponent could deal next turn after my ready units block their strongest
## attackers, plus a big penalty if that is lethal.
func _threat(state: GameState, mine: PlayerState, foe: PlayerState) -> float:
	var blockers: int = 0
	for card: CardInstance in mine.units():
		if not card.exhausted:
			blockers += 1
	var powers: Array[int] = []
	for card: CardInstance in foe.units():
		# A unit that is exhausted and set not to refresh (Contract, Overexert) cannot attack next turn.
		if not card.has_keyword(CardEnums.Keyword.WALLFLOWER) and not (card.exhausted and card.skip_refresh > 0):
			powers.append(state.get_attack(card))
	powers.sort()
	powers.reverse()
	var remaining: int = 0
	for i: int in range(powers.size()):
		if i >= blockers:
			remaining += powers[i]
	return float(remaining) + (LETHAL_THREAT if remaining >= mine.hp else 0.0)


# --------------------------------------------------------------------------------------
# Mulligan and discards
# --------------------------------------------------------------------------------------


func _choose_mulligan(state: GameState, who: int) -> GameAction:
	var player: PlayerState = state.players[who]
	var infrastructure: int = HandSmoother.count_infrastructure(player.hand)
	var size: int = player.hand.size()
	var bad_hand: bool = infrastructure < 2 or infrastructure > size - 2
	if bad_hand and not player.mulligan_used and state.options.free_mulligan:
		return GameAction.make(GameAction.Type.MULLIGAN, who)
	return GameAction.make(GameAction.Type.KEEP_HAND, who)


func _choose_discard(state: GameState, who: int) -> GameAction:
	var player: PlayerState = state.players[who]
	var ranked: Array[CardInstance] = player.hand.duplicate()
	var infrastructure_out: int = player.infrastructure.size()
	ranked.sort_custom(func(a: CardInstance, b: CardInstance) -> bool:
		return _keep_value(a, infrastructure_out) < _keep_value(b, infrastructure_out)
	)
	var action: GameAction = GameAction.make(GameAction.Type.TOSS, who)
	for i: int in range(state.pending_toss):
		action.uids.append(ranked[i].uid)
	return action


func _keep_value(card: CardInstance, infrastructure_out: int) -> float:
	if card.data.is_infrastructure():
		return 4.0 if infrastructure_out < 5 else 0.5
	return float(card.data.energy_value()) + 1.5


# --------------------------------------------------------------------------------------
# Main phases
# --------------------------------------------------------------------------------------


func _choose_main_action(state: GameState, who: int) -> GameAction:
	var actions: Array[GameAction] = state.legal_actions()
	var infrastructure_actions: Array[GameAction] = []
	for action: GameAction in actions:
		if action.type == GameAction.Type.PLAY_INFRASTRUCTURE:
			infrastructure_actions.append(action)
	if not infrastructure_actions.is_empty():
		return _best_infrastructure(state, who, infrastructure_actions)
	var baseline: float = evaluate(state, who)
	var best: GameAction = GameAction.pass_phase(who)
	var best_gain: float = EPSILON
	for action: GameAction in actions:
		if action.type != GameAction.Type.PLAY and action.type != GameAction.Type.ACTIVATE and action.type != GameAction.Type.USE_RESOURCE and action.type != GameAction.Type.ACTIVATE_ABILITY:
			continue
		var trial: GameState = state.clone(false, 1 - who)
		if not trial.apply_action(action):
			continue
		var gain: float = evaluate(trial, who) - baseline
		if action.type == GameAction.Type.ACTIVATE_ABILITY and _only_adds_energy(state, action):
			# Floating energy is worth what it lets you play next.
			gain = _best_follow_up(trial, who)
		if gain > best_gain:
			best_gain = gain
			best = action
	return best


## True for an ability whose whole effect is "add energy" (Mulch Mole, Bird of Paradump, Four-Path Compass...).
func _only_adds_energy(state: GameState, action: GameAction) -> bool:
	var card: CardInstance = state.find_card(action.card_uid)
	if card == null or action.effect_index >= card.data.abilities().size():
		return false
	var ability: CardAbility = card.data.abilities()[action.effect_index]
	if ability.effects.is_empty():
		return false
	for fx: CardAbility.Fx in ability.effects:
		if fx.name != "add":
			return false
	return true


## The best gain a single card play gives from this position (used to value floating energy).
func _best_follow_up(trial: GameState, who: int) -> float:
	var baseline: float = evaluate(trial, who)
	var best: float = 0.0
	for action: GameAction in trial.legal_actions():
		if action.type != GameAction.Type.PLAY:
			continue
		var next: GameState = trial.clone(false, 1 - who)
		if next.apply_action(action):
			best = maxf(best, evaluate(next, who) - baseline)
	return best


## Plays the infrastructure type the hand needs most (pips in hand vs infrastructure already out).
func _best_infrastructure(state: GameState, who: int, infrastructure_actions: Array[GameAction]) -> GameAction:
	var player: PlayerState = state.players[who]
	var need: Dictionary = {}
	for card: CardInstance in player.hand:
		for pip: Affinity.Type in card.data.colored_pips:
			need[pip] = float(need.get(pip, 0.0)) + 1.0
	var have: Dictionary = {}
	for infra: CardInstance in player.infrastructure:
		for path: Affinity.Type in infra.data.produced_paths():
			have[path] = int(have.get(path, 0)) + 1
	var best: GameAction = infrastructure_actions[0]
	var best_score: float = -INF
	for action: GameAction in infrastructure_actions:
		var data: CardData = state.find_card(action.card_uid).data
		var score: float = 0.0
		for path: Affinity.Type in data.produced_paths():
			score += float(need.get(path, 0.0)) / float(1 + int(have.get(path, 0)))
		# A flexible infrastructure is worth a little more than a plain one of the same need; basics keep the resource flowing.
		score += 0.05 * float(data.produced_paths().size()) + (0.02 if data.is_basic else 0.0)
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
	for card: CardInstance in state.players[1 - who].units():
		if not card.exhausted:
			strongest_foe = maxi(strongest_foe, state.get_attack(card))
	var safe: Array[int] = []
	for card: CardInstance in available:
		if state.get_defense(card) > strongest_foe or card.has_keyword(CardEnums.Keyword.FLYING):
			safe.append(card.uid)
	options.append(safe)
	var by_power: Array[CardInstance] = available.duplicate()
	by_power.sort_custom(func(a: CardInstance, b: CardInstance) -> bool: return state.get_attack(a) > state.get_attack(b))
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
	candidates.append_array(_enumerate_blocks(state, attackers, blockers))
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
	ordered.sort_custom(func(a: CardInstance, b: CardInstance) -> bool: return state.get_attack(a) > state.get_attack(b))
	for attacker: CardInstance in ordered:
		var best: CardInstance = null
		var best_rank: int = -1
		for blocker: CardInstance in blockers:
			if used.has(blocker.uid) or not CombatResolver.can_block(state, attacker, blocker):
				continue
			var kills: bool = state.get_attack(blocker) >= state.get_defense(attacker) - attacker.damage
			var survives: bool = state.get_defense(blocker) - blocker.damage > state.get_attack(attacker)
			var rank: int = -1
			if kills and survives:
				rank = 2
			elif kills and EffectResolver.unit_value(state, attacker) >= EffectResolver.unit_value(state, blocker):
				rank = 1
			if rank > best_rank or (rank == best_rank and rank >= 0 and EffectResolver.unit_value(state, blocker) < EffectResolver.unit_value(state, best)):
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
	unblocked.sort_custom(func(a: CardInstance, b: CardInstance) -> bool: return state.get_attack(a) > state.get_attack(b))
	var incoming: int = 0
	for attacker: CardInstance in unblocked:
		incoming += state.get_attack(attacker)
	var free_blockers: Array[CardInstance] = []
	for blocker: CardInstance in blockers:
		if not used.has(blocker.uid):
			free_blockers.append(blocker)
	free_blockers.sort_custom(func(a: CardInstance, b: CardInstance) -> bool: return EffectResolver.unit_value(state, a) < EffectResolver.unit_value(state, b))
	for attacker: CardInstance in unblocked:
		if incoming < state.players[who].hp:
			break
		for blocker: CardInstance in free_blockers:
			if CombatResolver.can_block(state, attacker, blocker):
				assignment[attacker.uid] = blocker.uid
				free_blockers.erase(blocker)
				incoming -= state.get_attack(attacker)
				break
	return assignment


## Every legal assignment when the search space is tiny.
func _enumerate_blocks(state: GameState, attackers: Array[CardInstance], blockers: Array[CardInstance]) -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	var combos: int = 1
	for i: int in range(attackers.size()):
		combos *= blockers.size() + 1
		if combos > MAX_BLOCK_ENUMERATION:
			return results
	_enumerate_from(state, 0, attackers, blockers, {}, [] as Array[int], results)
	return results


func _enumerate_from(
	state: GameState,
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
	_enumerate_from(state, index + 1, attackers, blockers, current, used, results)
	for blocker: CardInstance in blockers:
		if used.has(blocker.uid) or not CombatResolver.can_block(state, attacker, blocker):
			continue
		current[attacker.uid] = blocker.uid
		used.append(blocker.uid)
		_enumerate_from(state, index + 1, attackers, blockers, current, used, results)
		used.erase(blocker.uid)
		current.erase(attacker.uid)
