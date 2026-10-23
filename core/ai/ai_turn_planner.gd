class_name AITurnPlanner
extends RefCounted
## Battle AI upgrade (Oct 23): plans a whole main phase as a sequence of actions instead of one greedy action at a time. A beam
## search over the sanity-filtered legal actions: every candidate is applied to a clone, the resulting position is scored by
## `AIEvaluator.evaluate` (in Main 1 with the attack the position allows this turn, so Iron before an attack, a removal spell that
## clears the blocker, or a Hustle unit are seen for what they enable), the best `beam` positions are expanded again up to `depth`
## actions, and the best position found anywhere wins - a shorter sequence beats a longer one of equal value. Energy-only abilities
## ("Exhaust: add (R)") are carried along so the play they pay for is found at the next depth. A sequence that wins the game on a
## clone is returned at once. The search stops when the budget is spent and returns its best so far.

var evaluator: AIEvaluator
var use_resources: bool = true


class PlanNode:
	extends RefCounted
	var state: GameState
	var sequence: Array[GameAction] = []
	var score: float = 0.0
	var energy_only: bool = false


func _init(ai_evaluator: AIEvaluator) -> void:
	evaluator = ai_evaluator


## The action sequence for `me`'s current main phase (empty = just pass).
func plan(state: GameState, me: int, budget: AISearchBudget, beam: int, depth: int) -> Array[GameAction]:
	var root: PlanNode = PlanNode.new()
	root.state = state
	root.score = _score(state, me)
	var best: PlanNode = root
	var frontier: Array[PlanNode] = [root]
	for level: int in range(depth):
		var next: Array[PlanNode] = []
		var carried: Array[PlanNode] = []
		for node: PlanNode in frontier:
			var actions: Array[GameAction] = AISanity.filter(node.state, me, node.state.legal_actions(), use_resources)
			for action: GameAction in actions:
				if action.type == GameAction.Type.PLAY_INFRASTRUCTURE:
					continue  # played before planning (AIPlayer), one per turn
				if not budget.tick():
					return _finish(best, frontier, next)
				var trial: GameState = node.state.clone(false, 1 - me)
				if not trial.apply_action(action):
					continue
				var child: PlanNode = PlanNode.new()
				child.state = trial
				child.sequence = node.sequence.duplicate()
				child.sequence.append(action)
				if trial.is_over():
					if trial.winner == me:
						return child.sequence
					continue
				child.score = _score(trial, me)
				child.energy_only = _only_adds_energy(node.state, action)
				if child.energy_only:
					if carried.size() < 2:
						carried.append(child)
					continue
				next.append(child)
				if child.score > best.score + 0.0001:
					best = child
		if next.is_empty() and carried.is_empty():
			break
		next.sort_custom(func(a: PlanNode, b: PlanNode) -> bool: return a.score > b.score)
		frontier = next.slice(0, mini(beam, next.size()))
		frontier.append_array(carried)
	return best.sequence


func _finish(best: PlanNode, frontier: Array[PlanNode], next: Array[PlanNode]) -> Array[GameAction]:
	var top: PlanNode = best
	for node: PlanNode in frontier + next:
		if not node.energy_only and node.score > top.score + 0.0001:
			top = node
	return top.sequence


func _score(state: GameState, me: int) -> float:
	return evaluator.evaluate(state, me, state.phase == GameState.Phase.MAIN1)


## True for an ability whose whole effect is "add energy" (Mulch Mole, Bird of Paradump, Four-Path Compass...).
static func _only_adds_energy(state: GameState, action: GameAction) -> bool:
	if action.type != GameAction.Type.ACTIVATE_ABILITY:
		return false
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
