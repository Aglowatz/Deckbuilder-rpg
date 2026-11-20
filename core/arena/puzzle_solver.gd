class_name PuzzleSolver
extends RefCounted
## Fable Nov 20 (Part 7): the Arena puzzle solver. A full search over the player's legal plays for the puzzle's turn on the real engine
## (`GameState.legal_actions` / `apply_action` on clones): every card play with every target, every ability, every resource use,
## every set of attackers, and then every way the opponent can block - a line only counts as winning when it wins against EVERY
## block. It answers: can the puzzle be won, which lines win, and does a given start (a naive line) still lead to a win.
##
## A "line" is what the player does, in order: actions before combat, the attackers, actions after combat. Two lines that use the same
## cards on the same targets in another order are the same SOLUTION (`solution_key`), and a solution that only adds a harmless extra
## play to another one is not counted (`minimal_solutions`): that is the number a designer cares about ("exactly one intended line").
##
## Pure rules code: no scene tree. Used by tests/core/arena/test_arena_puzzles_nov20.gd and tools/arena_puzzle_report.gd.

## Stops the search (the result is then marked `complete = false`).
const MAX_STATES: int = 400000
const MAX_LINES: int = 4000

var states_seen: int = 0
var complete: bool = true
var _memo: Dictionary = {}
var _hero: int = 0


class Result:
	extends RefCounted
	var solvable: bool = false
	var complete: bool = true
	var states: int = 0
	## Every winning line found, each a list of steps in words (capped at MAX_LINES).
	var lines: Array[PackedStringArray] = []
	## solution key -> one line that plays it (the same plays in any order).
	var solutions: Dictionary = {}
	## The solutions no other solution is a part of.
	var minimal: Array[String] = []

	func minimal_lines() -> Array[PackedStringArray]:
		var result: Array[PackedStringArray] = []
		for key: String in minimal:
			result.append(solutions[key] as PackedStringArray)
		return result


## Solves `game` as it stands (the player to move is the hero; the puzzle is won when the opponent is at 0 HP before the hero's turn ends).
func solve(game: GameState, hero: int = 0) -> Result:
	_hero = hero
	_memo.clear()
	states_seen = 0
	complete = true
	game.events.clear()  # the log of what happened is not part of a position, and every clone would copy it
	var result: Result = Result.new()
	result.solvable = _wins(game)
	if result.solvable:
		var steps: PackedStringArray = []
		_collect(game, steps, result)
		result.minimal = _minimal(result.solutions.keys())
	result.complete = complete
	result.states = states_seen
	return result


## True when the hero still has a forced win from `game` (after some plays were already made).
func can_win(game: GameState, hero: int = 0) -> bool:
	_hero = hero
	game.events.clear()
	return _wins(game)


# ---- The search ---------------------------------------------------------------------------------------------------------------------


func _over(state: GameState) -> int:
	# 1 = the hero won, -1 = lost (or the turn ended), 0 = still playing the hero's turn
	if state.players[1 - _hero].hp <= 0 or (state.is_over() and state.winner == _hero):
		return 1
	if state.is_over() or state.players[_hero].hp <= 0:
		return -1
	if state.active != _hero:
		return -1
	return 0


func _wins(state: GameState) -> bool:
	var over: int = _over(state)
	if over != 0:
		return over > 0
	var key: String = signature(state)
	if _memo.has(key):
		return bool(_memo[key])
	states_seen += 1
	if states_seen > MAX_STATES:
		complete = false
		return false
	var who: int = state.awaiting_player()
	var found: bool
	if who == _hero:
		found = false
		for action: GameAction in hero_actions(state):
			var next: GameState = state.clone(false)
			if not next.apply_action(action):
				continue
			if _wins(next):
				found = true
				break
	else:
		# the opponent answers (blocks, a choice a card gives them): the line must win against every answer
		found = true
		var answers: Array[GameAction] = foe_actions(state)
		if answers.is_empty():
			found = false
		for action: GameAction in answers:
			var next: GameState = state.clone(false)
			if not next.apply_action(action):
				continue
			if not _wins(next):
				found = false
				break
	_memo[key] = found
	return found


## Every move the hero has here: the engine's legal actions, with every set of attackers (the engine lists only "one" and "all").
func hero_actions(state: GameState) -> Array[GameAction]:
	var result: Array[GameAction] = []
	if state.phase == GameState.Phase.COMBAT and state.combat_step == GameState.CombatStep.DECLARE_ATTACKERS and state.choice_requests.is_empty() and state.peek_requests.is_empty() and state.pending_toss == 0:
		var available: Array[CardInstance] = state.possible_attackers(_hero)
		var total: int = 1 << available.size()
		# the biggest attacks first: they are the likeliest to win, so a solvable puzzle is recognised quickly
		for mask: int in range(total - 1, -1, -1):
			var attack: GameAction = GameAction.make(GameAction.Type.DECLARE_ATTACKERS, _hero)
			for index: int in range(available.size()):
				if mask & (1 << index):
					attack.uids.append(available[index].uid)
			result.append(attack)
		return result
	for action: GameAction in state.legal_actions():
		# energy is paid automatically: tapping an infrastructure by hand first only multiplies the positions
		if (action.type == GameAction.Type.ACTIVATE or action.type == GameAction.Type.ACTIVATE_ABILITY) and PlayerState.find_in(state.players[_hero].infrastructure, action.card_uid) != null:
			continue
		result.append_array(_with_cost_picks(state, action))
	return result


## A play or an ability whose cost lets the player choose ("destroy a unit you control", "use a token"): one action per choice. The
## engine's own list takes the automatic pick only; at the table the player chooses, so every choice is a line of its own.
func _with_cost_picks(state: GameState, action: GameAction) -> Array[GameAction]:
	var costs: Array[CardAbility.Cost] = []
	var ctx: AbilityContext = null
	if action.type == GameAction.Type.PLAY:
		var card: CardInstance = PlayerState.find_in(state.players[_hero].hand, action.card_uid)
		if card != null:
			costs = state.play_costs_of(card.data)
			ctx = state.play_context(_hero, card)
	elif action.type == GameAction.Type.ACTIVATE_ABILITY:
		var holder: CardInstance = state.find_card(action.card_uid)
		if holder != null and action.effect_index < holder.data.abilities().size():
			var ability: CardAbility = holder.data.abilities()[action.effect_index]
			costs = ability.costs
			ctx = state.activation_context(_hero, holder, ability)
	var variants: Array[Array] = [[] as Array[int]]
	var any_choice: bool = false
	for cost: CardAbility.Cost in costs:
		var options: Array[int] = []
		if cost.kind == "destroy":
			for option: CardInstance in AbilityRunner.destroy_cost_options(ctx, cost):
				options.append(option.uid)
		elif cost.kind == "use_token":
			for option: CardInstance in AbilityRunner.token_cost_options(ctx):
				if not option.data.is_resource() and not option.data.is_table_token():
					options.append(option.uid)
		if options.is_empty() or (options.size() <= cost.count and cost.kind == "destroy"):
			continue
		any_choice = true
		var grown: Array[Array] = []
		var seen: Dictionary = {}
		for combo: Array[int] in _combinations(options, maxi(cost.count, 1)):
			# two copies of one card are one choice
			var names: PackedStringArray = []
			for uid: int in combo:
				names.append(_card_signature(state, state.find_card(uid)))
			names.sort()
			if seen.has(",".join(names)):
				continue
			seen[",".join(names)] = true
			for base: Array in variants:
				var merged: Array[int] = []
				merged.append_array(base)
				merged.append_array(combo)
				grown.append(merged)
		variants = grown
	if not any_choice:
		return [action] as Array[GameAction]
	var result: Array[GameAction] = []
	for picks: Array in variants:
		var copy: GameAction = GameAction.make(action.type, action.player)
		copy.card_uid = action.card_uid
		copy.target = action.target
		copy.targets = action.targets.duplicate()
		copy.x = action.x
		copy.effect_index = action.effect_index
		copy.uids = action.uids.duplicate()
		var typed: Array[int] = []
		typed.append_array(picks)
		copy.picks = typed
		result.append(copy)
	return result


static func _combinations(options: Array[int], count: int) -> Array[Array]:
	var result: Array[Array] = []
	var current: Array[int] = []
	_combine(options, count, 0, current, result)
	return result


static func _combine(options: Array[int], count: int, start: int, current: Array[int], result: Array[Array]) -> void:
	if current.size() == count:
		result.append(current.duplicate())
		return
	for index: int in range(start, options.size()):
		current.append(options[index])
		_combine(options, count, index + 1, current, result)
		current.pop_back()


## Every answer the opponent has: with attackers declared, every way to assign blockers (none included).
func foe_actions(state: GameState) -> Array[GameAction]:
	var foe: int = 1 - _hero
	if state.phase == GameState.Phase.COMBAT and state.combat_step == GameState.CombatStep.DECLARE_BLOCKERS and state.choice_requests.is_empty():
		var result: Array[GameAction] = []
		var blockers: Array[CardInstance] = state.possible_blockers(foe)
		var assignments: Array[Dictionary] = []
		_assign(state, 0, blockers, {}, assignments)
		for blocks: Dictionary in assignments:
			var action: GameAction = GameAction.make(GameAction.Type.DECLARE_BLOCKERS, foe)
			action.blocks = blocks
			result.append(action)
		return result
	return state.legal_actions()


func _assign(state: GameState, index: int, blockers: Array[CardInstance], current: Dictionary, out: Array[Dictionary]) -> void:
	if index >= blockers.size():
		out.append(current.duplicate())
		return
	# this blocker stays back
	_assign(state, index + 1, blockers, current, out)
	for attacker_uid: int in state.attackers:
		if current.has(attacker_uid):
			continue
		var attacker: CardInstance = state.find_permanent(attacker_uid)
		if attacker == null or not CombatResolver.can_block(state, attacker, blockers[index]):
			continue
		current[attacker_uid] = blockers[index].uid
		_assign(state, index + 1, blockers, current, out)
		current.erase(attacker_uid)


# ---- Winning lines ------------------------------------------------------------------------------------------------------------------


func _collect(state: GameState, steps: PackedStringArray, result: Result) -> void:
	if result.lines.size() >= MAX_LINES:
		complete = false
		return
	var over: int = _over(state)
	if over > 0:
		result.lines.append(steps.duplicate())
		var key: String = solution_key(steps)
		if not result.solutions.has(key):
			result.solutions[key] = steps.duplicate()
		return
	if over < 0:
		return
	var who: int = state.awaiting_player()
	if who == _hero:
		for action: GameAction in hero_actions(state):
			var next: GameState = state.clone(false)
			if not next.apply_action(action):
				continue
			if not _wins(next):
				continue
			var word: String = describe(state, action)
			# a pass that changes nothing in the story of the line (to combat, or past it) is not a step
			if not word.is_empty():
				steps.append(word)
			_collect(next, steps, result)
			if not word.is_empty():
				steps.remove_at(steps.size() - 1)
	else:
		# the line is the hero's; follow the opponent's toughest answer that still loses (any answer: they all lose from here)
		for action: GameAction in foe_actions(state):
			var next: GameState = state.clone(false)
			if next.apply_action(action):
				_collect(next, steps, result)
				return


## The plays of a line without their order inside each main phase: "before combat: a + b | attack: x + y | after: c".
static func solution_key(steps: PackedStringArray) -> String:
	var before: PackedStringArray = []
	var after: PackedStringArray = []
	var attack: String = ""
	for step: String in steps:
		if step.begins_with("Attack with ") or step == "No attack":
			attack = step
		elif attack.is_empty():
			before.append(step)
		else:
			after.append(step)
	before.sort()
	after.sort()
	return "%s | %s | %s" % [" + ".join(before), attack, " + ".join(after)]


## The plays of a solution as a set of words (for "is this solution part of that one").
static func _parts(key: String) -> Dictionary:
	var parts: Dictionary = {}
	var sections: PackedStringArray = key.split(" | ")
	for section_index: int in range(sections.size()):
		if section_index == 1:
			continue  # the attackers are judged by the plays that made them possible
		for word: String in sections[section_index].split(" + ", false):
			parts[word] = int(parts.get(word, 0)) + 1
	return parts


## The solutions that no other solution is contained in (a line that adds a spare play to a winning line is the same solution).
## Where a play happens (before or after combat) and who attacks do not make a new solution either.
static func _minimal(keys: Array) -> Array[String]:
	var sets: Array[Dictionary] = []
	for key: Variant in keys:
		sets.append(_parts(str(key)))
	var result: Array[String] = []
	var kept: Array[Dictionary] = []
	for index: int in range(keys.size()):
		var mine: Dictionary = sets[index]
		var is_minimal: bool = true
		for other_index: int in range(keys.size()):
			if other_index == index:
				continue
			var other: Dictionary = sets[other_index]
			if _contains(mine, other) and (other.size() < mine.size() or _total(other) < _total(mine)):
				is_minimal = false
				break
		if not is_minimal:
			continue
		var duplicate: bool = false
		for seen: Dictionary in kept:
			if _contains(mine, seen) and _contains(seen, mine):
				duplicate = true
		if not duplicate:
			kept.append(mine)
			result.append(str(keys[index]))
	return result


static func _contains(big: Dictionary, small: Dictionary) -> bool:
	for word: Variant in small.keys():
		if int(big.get(word, 0)) < int(small[word]):
			return false
	return true


static func _total(parts: Dictionary) -> int:
	var total: int = 0
	for count: Variant in parts.values():
		total += int(count)
	return total


# ---- Words and signatures -----------------------------------------------------------------------------------------------------------


static func _name_of(state: GameState, ref: int) -> String:
	if ref == 0:
		return ""
	var card: CardInstance = state.find_card(ref) if state.has_method("find_card") else state.find_permanent(ref)
	if card != null:
		return ("their " if card.owner != state.active else "") + card.data.display_name
	# a player reference
	if ref < 0:
		return "the opponent" if (-ref - 1) != state.active else "yourself"
	return "#%d" % ref


static func _picks_words(state: GameState, action: GameAction) -> String:
	if action.picks.is_empty():
		return ""
	var names: PackedStringArray = []
	for uid: int in action.picks:
		names.append(_name_of(state, uid))
	names.sort()
	# five Rat tokens read as "5 Rat": the same names are counted
	var counted: Dictionary = {}
	for name: String in names:
		counted[name] = int(counted.get(name, 0)) + 1
	var words: PackedStringArray = []
	for name: Variant in counted.keys():
		words.append(str(name) if int(counted[name]) == 1 else "%d x %s" % [int(counted[name]), str(name)])
	return " (paying with %s)" % ", ".join(words)


## One action in words ("Play Vigor Mortis on Beefy Bouncer"); "" for a pass.
func describe(state: GameState, action: GameAction) -> String:
	match action.type:
		GameAction.Type.PASS:
			return ""
		GameAction.Type.PLAY_INFRASTRUCTURE:
			return "Play %s" % _name_of(state, action.card_uid)
		GameAction.Type.PLAY:
			var targets: PackedStringArray = []
			for ref: int in (action.targets if not action.targets.is_empty() else ([action.target] as Array[int])):
				var word: String = _name_of(state, ref)
				if not word.is_empty():
					targets.append(word)
			return "Play %s%s%s" % [_name_of(state, action.card_uid), "" if targets.is_empty() else " on " + ", ".join(targets), _picks_words(state, action)]
		GameAction.Type.ACTIVATE, GameAction.Type.ACTIVATE_ABILITY:
			var chosen: PackedStringArray = []
			for ref: int in (action.targets if not action.targets.is_empty() else ([action.target] as Array[int])):
				var word: String = _name_of(state, ref)
				if not word.is_empty():
					chosen.append(word)
			# a card with several abilities says which ("Use Millstone Pusher (2nd ability)")
			var which: String = ""
			var holder: CardInstance = state.find_card(action.card_uid)
			if action.type == GameAction.Type.ACTIVATE_ABILITY and holder != null:
				var activated: int = 0
				var position: int = 0
				for index: int in range(holder.data.abilities().size()):
					if holder.data.abilities()[index].is_activated():
						activated += 1
						if index == action.effect_index:
							position = activated
				if activated > 1:
					which = " (%s ability)" % ["1st", "2nd", "3rd", "4th"][clampi(position - 1, 0, 3)]
			return "Use %s%s%s%s" % [_name_of(state, action.card_uid), which, "" if chosen.is_empty() else " on " + ", ".join(chosen), _picks_words(state, action)]
		GameAction.Type.USE_RESOURCE:
			return "Use %s on %s" % [ResourceKind.display_name(action.effect_index as ResourceKind.Kind), _name_of(state, action.target)]
		GameAction.Type.DECLARE_ATTACKERS:
			if action.uids.is_empty():
				return "No attack"
			var names: PackedStringArray = []
			for uid: int in action.uids:
				names.append(_name_of(state, uid))
			names.sort()
			return "Attack with " + ", ".join(names)
		GameAction.Type.CHOOSE:
			return "Choose %s" % _name_of(state, action.target)
	return GameAction.Type.keys()[action.type]


## Everything about a position that matters for what can still happen this turn (two positions with one signature play out alike).
static func signature(state: GameState) -> String:
	var parts: PackedStringArray = [str(state.phase), str(state.combat_step), str(state.active), str(state.pending_toss), str(state.choice_requests.size())]
	var attackers: Array[int] = state.attackers.duplicate()
	attackers.sort()
	parts.append(str(attackers))
	for player: PlayerState in state.players:
		parts.append("hp%d s%d p%s plays%d/%d inf%d" % [player.hp, player.shield, str(player.pool), player.cards_played_this_turn, player.spells_played_this_turn, player.infrastructure_played])
		for zone: Array in [player.hand, player.field, player.infrastructure, player.resources, player.tokens, player.traps, player.refuse_pile]:
			var cards: PackedStringArray = []
			for card: CardInstance in zone as Array[CardInstance]:
				cards.append(_card_signature(state, card))
			cards.sort()
			parts.append("[" + ",".join(cards) + "]")
	parts.append(str(state.delayed.size()))
	return "/".join(parts)


static func _card_signature(state: GameState, card: CardInstance) -> String:
	var keywords: Array[int] = []
	for keyword: CardEnums.Keyword in card.granted_keywords:
		keywords.append(int(keyword))
	for keyword: CardEnums.Keyword in card.temp_keywords:
		keywords.append(100 + int(keyword))
	keywords.sort()
	var host: String = ""
	if card.attached_to != 0:
		var attached: CardInstance = state.find_permanent(card.attached_to)
		host = attached.data.id if attached != null else "?"
	var used: Array[int] = card.used_abilities.duplicate()
	used.sort()
	return "%s:%d:%d:%d%d%d:%d,%d,%d,%d:%d:%s:%s:%s:%d%d:%d,%d:%s" % [card.data.id, card.owner, card.damage, int(card.exhausted), int(card.just_arrived), int(card.activated_this_turn),
		card.attack_bonus, card.defense_bonus, card.temp_attack, card.temp_defense, card.buffs, str(keywords), host, str(used), int(card.cannot_block), int(card.temp_cannot_block),
		card.set_attack, card.set_defense, str(card.lingering.size())]
