class_name AIPlayer
extends RefCounted
## The battle AI (Battle AI upgrade, Oct 23). One `choose_action` per decision, as before, but behind it:
## - `AITurnPlanner`: each main phase is planned once as a sequence of plays, abilities and resource uses (beam search on clones, scored
##   by `AIEvaluator` with the attack the position allows), cached and handed out one action at a time; a cached action that is no
##   longer legal (a trap changed the board) triggers a replan.
## - `AICombat`: attacks and blocks played out on clones against a competent model of the opponent's blocks, scored with the
##   evaluator's crack-back threat, lethal detection for both sides and race clock.
## - `AISanity`: the plays a human would never make are removed before any search.
## - `AISearchBudget`: node caps per skill level (deterministic for a seed) plus a wall-clock safety net in the live game.
## The AI never peeks at hidden information: the opponent's traps are removed from every clone. Behaviour is tuned by an
## `AIPersonality` (weights, skill, Path profile, boss signature); `use_resources` = false is the balance sim's "never use Iron / Red
## Tape / Contracts" switch. Mulligans and discards are simple rules.

const WIN_SCORE: float = AIEvaluator.WIN_SCORE
const BOARD_UNIT: float = AIEvaluator.BOARD_UNIT
const LETHAL_THREAT: float = AIEvaluator.LETHAL_THREAT
const TRAP_VALUE: float = AIEvaluator.TRAP_VALUE
const FUEL_VALUE: float = AIEvaluator.FUEL_VALUE

## Search sizes per skill level (AIPersonality.skill): beam width, plan depth, nodes per decision, block enumeration cap, attack
## candidates tried.
const SKILL_SETTINGS: Dictionary = {
	0: {"beam": 2, "depth": 2, "nodes": 60, "block_enum": 12, "attack_candidates": 8},
	1: {"beam": 3, "depth": 3, "nodes": 150, "block_enum": 40, "attack_candidates": 14},
	2: {"beam": 4, "depth": 4, "nodes": 280, "block_enum": 80, "attack_candidates": 20},
}

var personality: AIPersonality
## Rebalance (Oct 18): false = never uses Iron, Red Tape or Contracts (the balance sim measures what a resource is worth).
var use_resources: bool = true:
	set(value):
		use_resources = value
		if _planner != null:
			_planner.use_resources = value
## True = no wall-clock deadline (sim and tests: identical games for a seed on any machine).
var deterministic: bool = false
## The last decision's think time in milliseconds and the longest so far (for the timing report).
var last_think_ms: float = 0.0
var max_think_ms: float = 0.0

var _evaluator: AIEvaluator
var _planner: AITurnPlanner
var _combat: AICombat
var _plan: Array[GameAction] = []
var _plan_key: String = ""
var _replanned_key: String = ""


func _init(ai_personality: AIPersonality = null) -> void:
	personality = ai_personality if ai_personality != null else AIPersonality.balanced()
	_evaluator = AIEvaluator.new(personality)
	_planner = AITurnPlanner.new(_evaluator)
	_planner.use_resources = use_resources
	_combat = AICombat.new(_evaluator)


## Picks the next action for whoever the game is waiting on (`state.awaiting_player()`).
func choose_action(state: GameState) -> GameAction:
	var started: int = Time.get_ticks_usec()
	var action: GameAction = _choose(state)
	last_think_ms = float(Time.get_ticks_usec() - started) / 1000.0
	max_think_ms = maxf(max_think_ms, last_think_ms)
	return action


func _choose(state: GameState) -> GameAction:
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


## Position score from `me`'s point of view (higher is better).
func evaluate(state: GameState, me: int) -> float:
	return _evaluator.evaluate(state, me)


func evaluator() -> AIEvaluator:
	return _evaluator


func _settings() -> Dictionary:
	return SKILL_SETTINGS[clampi(personality.skill, 0, 2)] as Dictionary


func _budget(share: float = 1.0) -> AISearchBudget:
	var settings: Dictionary = _settings()
	var time_ms: int = 0 if deterministic else int(float(personality.time_budget_ms) * share)
	return AISearchBudget.make(int(float(int(settings["nodes"])) * share), time_ms)


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
# Main phases: the cached turn plan
# --------------------------------------------------------------------------------------


func _choose_main_action(state: GameState, who: int) -> GameAction:
	var actions: Array[GameAction] = state.legal_actions()
	var infrastructure_actions: Array[GameAction] = []
	for action: GameAction in actions:
		if action.type == GameAction.Type.PLAY_INFRASTRUCTURE:
			infrastructure_actions.append(action)
	if not infrastructure_actions.is_empty():
		return _best_infrastructure(state, who, infrastructure_actions)
	var key: String = "%d:%d:%d:%d" % [state.get_instance_id(), state.turn, int(state.phase), who]
	if _plan_key != key:
		_plan_key = key
		_replanned_key = ""
		_plan = _make_plan(state, who)
	while not _plan.is_empty():
		var next: GameAction = _plan.pop_front()
		if _still_legal(state, next):
			return next
		# The board changed under the plan (a trap sprang, an item was used): plan again, once per phase.
		if _replanned_key == key:
			_plan.clear()
			break
		_replanned_key = key
		_plan = _make_plan(state, who)
	return GameAction.pass_phase(who)


func _make_plan(state: GameState, who: int) -> Array[GameAction]:
	var settings: Dictionary = _settings()
	return _planner.plan(state, who, _budget(), int(settings["beam"]), int(settings["depth"]))


## Whether a planned action can still be applied to the real game.
func _still_legal(state: GameState, action: GameAction) -> bool:
	if action.player != state.awaiting_player():
		return false
	match action.type:
		GameAction.Type.PLAY:
			return state.can_play_card(action.player, action.card_uid, action.targets, action.picks)
		GameAction.Type.PLAY_INFRASTRUCTURE:
			return state.can_play_infrastructure(action.player, action.card_uid)
		GameAction.Type.ACTIVATE_ABILITY:
			return state.can_activate_ability(action.player, action.card_uid, action.effect_index, action.targets, action.x, action.picks)
		GameAction.Type.ACTIVATE:
			return state.can_activate(action.player, action.card_uid, action.effect_index)
		GameAction.Type.USE_RESOURCE:
			return state.can_use_resource(action.player, action.effect_index as ResourceKind.Kind, action.target)
	return false


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
# Combat
# --------------------------------------------------------------------------------------


func _choose_attack(state: GameState, who: int) -> GameAction:
	var settings: Dictionary = _settings()
	var uids: Array[int] = _combat.choose_attackers(state, who, _budget(0.6), int(settings["attack_candidates"]))
	if uids.is_empty():
		return GameAction.pass_phase(who)
	var action: GameAction = GameAction.make(GameAction.Type.DECLARE_ATTACKERS, who)
	action.uids = uids
	return action


func _choose_block_action(state: GameState, who: int) -> GameAction:
	var blocks: Dictionary = choose_blocks(state, who)
	if blocks.is_empty():
		return GameAction.pass_phase(who)
	var action: GameAction = GameAction.make(GameAction.Type.DECLARE_BLOCKERS, who)
	action.blocks = blocks
	return action


## Best assignment (attacker uid -> blocker uid) for defender `who`, chosen by look-ahead.
func choose_blocks(state: GameState, who: int) -> Dictionary:
	var settings: Dictionary = _settings()
	return _combat.choose_blocks(state, who, _budget(0.6), int(settings["block_enum"]))
