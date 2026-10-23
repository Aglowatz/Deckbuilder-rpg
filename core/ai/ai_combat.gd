class_name AICombat
extends RefCounted
## Battle AI upgrade (Oct 23): attack and block decisions. Every candidate declaration is played out on a clone (so every keyword,
## trigger and trap-less combat is exact), the opponent's reply is modelled with a competent blocking policy, and the result is scored
## by `AIEvaluator.evaluate` - whose threat and race terms are the look-ahead: the crack-back the opponent gets next turn, whether it
## is lethal, and who is ahead in the race. Lethal for either side is found exactly (a clone that ends the game scores WIN_SCORE).
## Candidate sets are wider than before (every "all but one", power prefixes, the evasive set, the units no blocker can profitably
## stop) and never contain zero-attack units; the number tried is capped by the search budget.

const WASTED_PUMP_PENALTY: float = 1.5
## Score taken off a block in which the blocker dies without killing the attacker, when no block would not have been lethal.
const CHUMP_RELUCTANCE: float = 1.0

## Prints every candidate and its score (tools/ai_probe.gd).
var debug: bool = false
## The last attack search's candidates, best first: {"uids": Array[int], "score": float, "wins": bool} (Part 4 mistakes read it).
var last_ranked: Array[Dictionary] = []
var evaluator: AIEvaluator
var personality: AIPersonality
## The competent policy used to predict the OPPONENT's blocks (a neutral evaluator, so an Aggressive AI does not assume the player
## blocks recklessly).
var _model: AIEvaluator


func _init(ai_evaluator: AIEvaluator) -> void:
	evaluator = ai_evaluator
	personality = ai_evaluator.personality
	_model = AIEvaluator.new(AIPersonality.balanced())


# ---- Attacking -------------------------------------------------------------------------------------------------------------------------


## The best set of attacker uids for `who` (empty = no attack). `hint` is a set the turn plan expected to attack with.
func choose_attackers(state: GameState, who: int, budget: AISearchBudget, max_candidates: int, hint: Array[int] = [] as Array[int]) -> Array[int]:
	var available: Array[CardInstance] = []
	for card: CardInstance in state.possible_attackers(who):
		if AISanity.worth_attacking_with(state, card):
			available.append(card)
	if available.is_empty():
		return [] as Array[int]
	var candidates: Array[Array] = attack_candidates(state, who, available, hint, max_candidates)
	var best: Array[int] = []
	var best_score: float = -INF
	last_ranked = []
	for candidate: Array[int] in candidates:
		if not budget.tick() and best_score > -INF:
			break
		var trial: GameState = state.clone(false, 1 - who)
		if candidate.is_empty():
			if not trial.apply_action(GameAction.pass_phase(who)):
				continue
		elif not trial.declare_attackers(candidate):
			continue
		if not trial.is_over() and trial.awaiting_player() == 1 - who and trial.combat_step == GameState.CombatStep.DECLARE_BLOCKERS:
			trial.declare_blockers(_model_blocks(trial, 1 - who, budget))
		if trial.is_over() and trial.winner == who:
			last_ranked.insert(0, {"uids": candidate, "score": AIEvaluator.WIN_SCORE, "wins": true})
			return candidate
		var score: float = evaluator.evaluate(trial, who) + personality.attack_bias * float(candidate.size())
		# A unit pumped this turn (Iron, a spell) that stays home wastes the pump.
		for card: CardInstance in available:
			if card.temp_attack > 0 and not candidate.has(card.uid):
				score -= WASTED_PUMP_PENALTY
		if debug:
			var names: PackedStringArray = []
			for uid: int in candidate:
				var card: CardInstance = state.find_card(uid)
				names.append(card.data.display_name if card != null else str(uid))
			var blocks: PackedStringArray = []
			for key: Variant in trial.blocks.keys():
				blocks.append("%d<-%d" % [int(key), int(trial.blocks[key])])
			var boards: PackedStringArray = []
			for player: PlayerState in trial.players:
				var units: PackedStringArray = []
				for unit: CardInstance in player.units():
					units.append("%s %d/%d%s" % [unit.data.display_name, trial.get_attack(unit), trial.get_defense(unit) - unit.damage, "x" if unit.exhausted else ""])
				boards.append(", ".join(units))
			print("  attack [%s] -> %.2f (hp %d/%d, blocks %s)\n     P%d: %s\n     P%d: %s\n     %s" % [", ".join(names), score, trial.players[who].hp, trial.players[1 - who].hp, ", ".join(blocks), who, boards[who], 1 - who, boards[1 - who], evaluator.explain(trial, who)])
		last_ranked.append({"uids": candidate, "score": score, "wins": false})
		if score > best_score + 0.0001:
			best_score = score
			best = candidate
	last_ranked.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return float(a["score"]) > float(b["score"]))
	return best


## Representative attacker sets: none, everyone, each alone, everyone but one, the evasive units, the "safe" units (no ready foe
## blocker can kill them), the units no blocker stops profitably, power prefixes, and the plan's hint. Deduplicated, capped.
func attack_candidates(state: GameState, who: int, available: Array[CardInstance], hint: Array[int], cap: int) -> Array[Array]:
	var options: Array[Array] = [[] as Array[int]]
	var everyone: Array[int] = []
	for card: CardInstance in available:
		everyone.append(card.uid)
	options.append(everyone)
	if not hint.is_empty():
		var hinted: Array[int] = []
		for uid: int in hint:
			if everyone.has(uid):
				hinted.append(uid)
		options.append(hinted)
	var foe: PlayerState = state.players[1 - who]
	var ready_blockers: Array[CardInstance] = state.possible_blockers(1 - who)
	var strongest_foe: int = 0
	var foe_can_block_flyers: bool = false
	for card: CardInstance in ready_blockers:
		strongest_foe = maxi(strongest_foe, state.get_attack(card))
		if state.unit_has_keyword(card, CardEnums.Keyword.FLYING) or state.unit_has_keyword(card, CardEnums.Keyword.SWAT):
			foe_can_block_flyers = true
	var safe: Array[int] = []
	var evasive: Array[int] = []
	var profitable: Array[int] = []
	for card: CardInstance in available:
		var flying: bool = state.unit_has_keyword(card, CardEnums.Keyword.FLYING)
		var elusive: bool = state.unit_has_keyword(card, CardEnums.Keyword.ELUSIVE)
		if elusive or (flying and not foe_can_block_flyers):
			evasive.append(card.uid)
			safe.append(card.uid)
			profitable.append(card.uid)
			continue
		if state.get_defense(card) - card.damage > strongest_foe or state.unit_has_keyword(card, CardEnums.Keyword.UNBREAKABLE):
			safe.append(card.uid)
		if _no_profitable_block(state, card, ready_blockers):
			profitable.append(card.uid)
	options.append(safe)
	options.append(evasive)
	options.append(profitable)
	var by_power: Array[CardInstance] = available.duplicate()
	by_power.sort_custom(func(a: CardInstance, b: CardInstance) -> bool: return state.get_attack(a) > state.get_attack(b))
	for count: int in range(1, by_power.size()):
		var prefix: Array[int] = []
		for i: int in range(count):
			prefix.append(by_power[i].uid)
		options.append(prefix)
	if available.size() <= 6:
		for card: CardInstance in available:
			options.append([card.uid] as Array[int])
	if available.size() >= 3 and available.size() <= 6:
		for card: CardInstance in available:
			var but_one: Array[int] = everyone.duplicate()
			but_one.erase(card.uid)
			options.append(but_one)
	# Lethal check first: if everyone's attack reaches the foe's HP, that candidate is tried early (it already is: second).
	var candidates: Array[Array] = []
	var seen: Dictionary = {}
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
		if candidates.size() >= cap:
			break
	return candidates


## True when no ready foe blocker can kill `card` without dying itself (or trade up).
func _no_profitable_block(state: GameState, card: CardInstance, blockers: Array[CardInstance]) -> bool:
	var me: AIEvaluator.Fighter = evaluator.fighter(state, card)
	for blocker: CardInstance in blockers:
		var it: AIEvaluator.Fighter = evaluator.fighter(state, blocker)
		if not AIEvaluator.can_block(me, it):
			continue
		var kills_me: bool = AIEvaluator.kills(it, me, it.attack)
		var i_kill_it: bool = AIEvaluator.kills(me, it, me.attack)
		if kills_me and (not i_kill_it or me.value >= it.value):
			return false
	return true


## The opponent's predicted blocks: the same block chooser, with the neutral evaluator and its own small budget (so modelling the
## reply never starves the attack search of candidates).
func _model_blocks(state: GameState, defender: int, budget: AISearchBudget) -> Dictionary:
	var modeller: AICombat = AICombat.new(_model)
	var own: AISearchBudget = AISearchBudget.new()
	own.max_nodes = 16
	own.deadline_usec = budget.deadline_usec
	return modeller.choose_blocks(state, defender, own, 12)


# ---- Blocking ----------------------------------------------------------------------------------------------------------------------------


## Best assignment (attacker uid -> blocker uid) for defender `who`.
func choose_blocks(state: GameState, who: int, budget: AISearchBudget, enumeration_cap: int) -> Dictionary:
	var attackers: Array[CardInstance] = []
	for uid: int in state.attackers:
		var card: CardInstance = state.find_permanent(uid)
		if card != null:
			attackers.append(card)
	var blockers: Array[CardInstance] = state.possible_blockers(who)
	if attackers.is_empty() or blockers.is_empty():
		return {}
	var candidates: Array[Dictionary] = [{}]
	var value: Dictionary = _value_blocks(state, attackers, blockers)
	candidates.append(value)
	candidates.append(_add_chump_blocks(state, who, attackers, blockers, value, true))
	candidates.append(_add_chump_blocks(state, who, attackers, blockers, {}, true))
	candidates.append(_add_chump_blocks(state, who, attackers, blockers, value, false))
	candidates.append(_add_chump_blocks(state, who, attackers, blockers, {}, false))
	if attackers.size() * blockers.size() <= 20:
		for attacker: CardInstance in attackers:
			for blocker: CardInstance in blockers:
				if CombatResolver.can_block(state, attacker, blocker):
					candidates.append({attacker.uid: blocker.uid})
	candidates.append_array(_enumerate_blocks(state, attackers, blockers, enumeration_cap))
	var best: Dictionary = {}
	var best_score: float = -INF
	var seen: Dictionary = {}
	var no_block_lethal: bool = false
	for candidate: Dictionary in candidates:
		var key: String = str(candidate)
		if seen.has(key):
			continue
		seen[key] = true
		if not budget.tick() and best_score > -INF:
			break
		var trial: GameState = state.clone(false, 1 - who)
		if not trial.declare_blockers(candidate):
			continue
		if candidate.is_empty() and trial.is_over() and trial.winner != who:
			no_block_lethal = true
		if trial.is_over() and trial.winner == who:
			return candidate
		var score: float = evaluator.evaluate(trial, who) + personality.block_bias * float(candidate.size())
		# A pure chump (the blocker dies, the attacker lives) is a card thrown away: a human needs a reason beyond a few HP.
		if not no_block_lethal:
			for attacker_uid: Variant in candidate.keys():
				if trial.find_permanent(int(candidate[attacker_uid])) == null and trial.find_permanent(int(attacker_uid)) != null:
					score -= CHUMP_RELUCTANCE
		if score > best_score + 0.0001:
			best_score = score
			best = candidate
	return best


## Blocks that kill the attacker and survive, or trade evenly / favourably (the cheapest blocker that does it).
func _value_blocks(state: GameState, attackers: Array[CardInstance], blockers: Array[CardInstance]) -> Dictionary:
	var assignment: Dictionary = {}
	var used: Array[int] = []
	var ordered: Array[CardInstance] = attackers.duplicate()
	ordered.sort_custom(func(a: CardInstance, b: CardInstance) -> bool: return state.get_attack(a) > state.get_attack(b))
	for attacker: CardInstance in ordered:
		var best: CardInstance = null
		var best_rank: int = -1
		var a: AIEvaluator.Fighter = evaluator.fighter(state, attacker)
		for blocker: CardInstance in blockers:
			if used.has(blocker.uid) or not CombatResolver.can_block(state, attacker, blocker):
				continue
			var b: AIEvaluator.Fighter = evaluator.fighter(state, blocker)
			var kills: bool = AIEvaluator.kills(b, a, b.attack)
			var survives: bool = not AIEvaluator.kills(a, b, a.attack)
			var rank: int = -1
			if kills and survives:
				rank = 2
			elif kills and a.value >= b.value:
				rank = 1
			if rank > best_rank or (rank == best_rank and rank >= 0 and b.value < evaluator.unit_value(state, best)):
				best_rank = rank
				best = blocker
		if best != null and best_rank >= 0:
			assignment[attacker.uid] = best.uid
			used.append(best.uid)
	return assignment


## Adds the cheapest free blockers onto the strongest unblocked attackers: until the damage is not lethal (`only_lethal`), or onto
## the single biggest attacker regardless (saving HP when behind).
func _add_chump_blocks(state: GameState, who: int, attackers: Array[CardInstance], blockers: Array[CardInstance], base: Dictionary, only_lethal: bool) -> Dictionary:
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
	free_blockers.sort_custom(func(a: CardInstance, b: CardInstance) -> bool: return evaluator.unit_value(state, a) < evaluator.unit_value(state, b))
	var placed: int = 0
	for attacker: CardInstance in unblocked:
		if only_lethal and incoming < state.players[who].hp:
			break
		if not only_lethal and placed >= 1:
			break
		for blocker: CardInstance in free_blockers:
			if CombatResolver.can_block(state, attacker, blocker):
				assignment[attacker.uid] = blocker.uid
				free_blockers.erase(blocker)
				incoming -= state.get_attack(attacker)
				placed += 1
				break
	return assignment


## Every legal assignment when the search space is small enough.
func _enumerate_blocks(state: GameState, attackers: Array[CardInstance], blockers: Array[CardInstance], cap: int) -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	var combos: int = 1
	for i: int in range(attackers.size()):
		combos *= blockers.size() + 1
		if combos > cap:
			return results
	_enumerate_from(state, 0, attackers, blockers, {}, [] as Array[int], results)
	return results


func _enumerate_from(state: GameState, index: int, attackers: Array[CardInstance], blockers: Array[CardInstance], current: Dictionary, used: Array[int], results: Array[Dictionary]) -> void:
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
