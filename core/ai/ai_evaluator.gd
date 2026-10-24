class_name AIEvaluator
extends RefCounted
## Battle AI upgrade (Oct 23): the position evaluation the planner, the attack chooser and the block chooser share. Static (no
## clones): HP on a concave curve (the first points matter less, the last few double), board value from base stats + keywords +
## abilities + "a body is a card" (temporary pumps do not count - they only matter through this turn's attack), hand, development,
## resources valued by what the player can spend them on, set traps by how likely their condition is, plus a fast combat model: the
## damage each side can push through the other's blockers (`attack_estimate`), which gives the threat of the opponent's next attack
## (and whether it is lethal) and a race clock for both sides. Encounter rules are read from the players' modifiers: timed and
## escalating summons add to the foe's future push, start-of-turn damage to its clock, Rot makes 1-defense units worthless.
## Everything is weighted by an `AIPersonality`. Per-unit facts (attack, defense, keywords, worth) are cached for the duration of one
## `evaluate` call, which is what keeps a boss-level search under the time box on a full board.

const WIN_SCORE: float = 100000.0
const BOARD_UNIT: float = 0.5
const LETHAL_THREAT: float = 20.0
const NEAR_LETHAL_THREAT: float = 6.0
const TRAP_VALUE: float = 3.0
## Held fuel (Ingredients, Garbage) with a spender in reach / without one. Kept below what one use typically gains, or the AI hoards
## (the audit's Possum Prowler sat on seven Garbage).
const FUEL_VALUE: float = 0.8
const IDLE_FUEL_VALUE: float = 0.25
## A unit on the table is also a card spent: part of its worth beyond its stats.
const BODY_VALUE: float = 1.0
## A possible lethal attack this turn (estimated, not yet confirmed on a clone).
const LETHAL_NOW_BONUS: float = 60.0

var personality: AIPersonality
var _fuel_cache: Dictionary = {}
## uid -> Fighter, valid during one evaluate() call (cleared before and after).
var _fighters: Dictionary = {}
var _caching: bool = false


## Everything the combat model needs to know about one unit, computed once per evaluation.
class Fighter:
	extends RefCounted
	var card: CardInstance
	var attack: int = 0
	var defense_left: int = 1
	## Full defense next turn (damage cleared, this turn's pumps gone).
	var defense_later: int = 1
	var value: float = 0.0
	var flying: bool = false
	var swat: bool = false
	var elusive: bool = false
	var bulldoze: bool = false
	var toxic: bool = false
	var unbreakable: bool = false
	var wallflower: bool = false
	## Could block right now (ready, allowed to block).
	var blocks_now: bool = false
	## Could block on a later turn (allowed to block at all).
	var blocks_later: bool = false
	## Attack after the lingering shrinks made by `expiring` end (expiring = player index), cached on demand.
	var attack_after: Dictionary = {}


func _init(ai_personality: AIPersonality) -> void:
	personality = ai_personality


## Position score from `me`'s point of view (higher is better). `attack_now` adds the value of the attack `me` can still make this
## turn (used in Main 1, before combat): the damage it pushes, the trades it forces, and a big bonus when it looks lethal.
func evaluate(state: GameState, me: int, attack_now: bool = false) -> float:
	if state.is_over():
		if state.is_draw:
			return 0.0
		return WIN_SCORE if state.winner == me else -WIN_SCORE
	_fighters.clear()
	_caching = true
	var score: float = _evaluate(state, me, attack_now)
	_caching = false
	_fighters.clear()
	return score


func _evaluate(state: GameState, me: int, attack_now: bool) -> float:
	var mine: PlayerState = state.players[me]
	var foe: PlayerState = state.players[1 - me]
	var score: float = 0.0
	score += personality.hp_weight * hp_value(mine.hp)
	score -= personality.enemy_hp_weight * hp_value(foe.hp)
	score += personality.board_weight * board_value(state, mine)
	score -= personality.enemy_board_weight * board_value(state, foe, personality.artifact_weight)
	score += personality.hand_weight * (hand_value(mine) - hand_value(foe))
	score += personality.energy_weight * float(mine.infrastructure.size())
	score += resource_value(state, mine) - resource_value(state, foe)
	# The opponent's next attack against the blockers I will have then.
	var incoming: Dictionary = threat(state, me)
	var face: int = int(incoming["face"])
	score -= personality.threat_weight * float(face)
	if face >= mine.hp:
		score -= LETHAL_THREAT
	elif face >= mine.hp - 2:
		score -= NEAR_LETHAL_THREAT
	# The race: how many of my attacks until the foe is dead, against how many of theirs until I am - on the sustained push (before
	# emergency chump blocks), and the nearer a clock the more it weighs.
	var my_push: int = int(push_estimate(state, me, false)["raw_face"])
	var their_push: int = int(incoming["raw_face"]) + start_of_turn_damage(state, foe.index)
	var my_clock: float = clocks(foe.hp, my_push)
	var their_clock: float = clocks(mine.hp, their_push)
	score += personality.race_weight * (pressure(my_clock) - pressure(their_clock))
	if attack_now:
		var now: Dictionary = push_estimate(state, me, true)
		var now_face: int = int(now["face"])
		if now_face >= foe.hp:
			score += LETHAL_NOW_BONUS
		score += personality.enemy_hp_weight * (hp_value(foe.hp) - hp_value(foe.hp - now_face)) * 0.8
		score += personality.enemy_board_weight * float(now["their_loss"]) - personality.board_weight * float(now["my_loss"])
	return score


## The evaluation's terms as text (tools/ai_probe.gd).
func explain(state: GameState, me: int) -> String:
	if state.is_over():
		return "over: winner %d" % state.winner
	_fighters.clear()
	_caching = true
	var mine: PlayerState = state.players[me]
	var foe: PlayerState = state.players[1 - me]
	var incoming: Dictionary = threat(state, me)
	var my_push: Dictionary = push_estimate(state, me, false)
	var now: Dictionary = push_estimate(state, me, true)
	var text: String = "hp %.1f/%.1f board %.1f/%.1f hand %.1f/%.1f infra %d res %.1f/%.1f threat %s push %s now %s" % [
		hp_value(mine.hp), hp_value(foe.hp), board_value(state, mine), board_value(state, foe), hand_value(mine), hand_value(foe),
		mine.infrastructure.size(), resource_value(state, mine), resource_value(state, foe), str(incoming), str(my_push), str(now)]
	_caching = false
	_fighters.clear()
	return text


## HP on a concave curve: points above 10 are worth half, 7-10 three quarters, the last six 1.75 each (losing them is a disaster).
static func hp_value(hp: int) -> float:
	var value: float = 0.0
	var left: int = hp
	if left > 10:
		value += 0.5 * float(left - 10)
		left = 10
	if left > 6:
		value += 0.75 * float(left - 6)
		left = 6
	value += 1.75 * float(left)
	return value


## Turns of attacking needed to deal `hp` at `push` per turn (a 0 push never gets there).
static func clocks(hp: int, push: int) -> float:
	if hp <= 0:
		return 0.0
	if push <= 0:
		return 6.0
	return minf(6.0, ceilf(float(hp) / float(push)))


## How much a clock of `turns` weighs: a kill next turn is worth four times one four turns away.
static func pressure(turns: float) -> float:
	return 2.0 / maxf(1.0, turns)


# ---- Per-unit facts ------------------------------------------------------------------------------------------------------------------


func fighter(state: GameState, card: CardInstance) -> Fighter:
	if _caching and _fighters.has(card.uid):
		return _fighters[card.uid] as Fighter
	var made: Fighter = Fighter.new()
	made.card = card
	made.attack = state.get_attack(card)
	made.defense_left = state.get_defense(card) - card.damage
	made.defense_later = maxi(1, state.get_defense(card) - card.temp_defense)
	var keywords: Array[CardEnums.Keyword] = state.keywords_of(card)
	made.flying = keywords.has(CardEnums.Keyword.FLYING)
	made.swat = keywords.has(CardEnums.Keyword.SWAT)
	made.elusive = keywords.has(CardEnums.Keyword.ELUSIVE)
	made.bulldoze = keywords.has(CardEnums.Keyword.BULLDOZE)
	made.toxic = keywords.has(CardEnums.Keyword.TOXIC)
	made.unbreakable = keywords.has(CardEnums.Keyword.UNBREAKABLE)
	made.wallflower = keywords.has(CardEnums.Keyword.WALLFLOWER)
	made.blocks_later = not card.cannot_block and not StaticEffects.card_flag(state, card, "cant_block")
	made.blocks_now = made.blocks_later and not card.exhausted and not card.temp_cannot_block
	made.value = _unit_value(state, card, keywords, made.attack, made.defense_left)
	if _caching:
		_fighters[card.uid] = made
	return made


func _attack_after(state: GameState, f: Fighter, expiring_for: int) -> int:
	if expiring_for < 0:
		return f.attack
	if not f.attack_after.has(expiring_for):
		f.attack_after[expiring_for] = state.get_attack(f.card, expiring_for)
	return int(f.attack_after[expiring_for])


## A unit's worth: base stats (lingering Red Tape counts, this turn's pumps do not), keywords, abilities, a body; nothing under Rot at
## 1 defense.
func unit_value(state: GameState, card: CardInstance) -> float:
	return fighter(state, card).value


func _unit_value(state: GameState, card: CardInstance, keywords: Array[CardEnums.Keyword], attack_now: int, defense_now: int) -> float:
	var attack: int = maxi(0, attack_now - card.temp_attack)
	var defense: int = maxi(1, defense_now + card.damage - card.temp_defense)
	var wallflower: bool = keywords.has(CardEnums.Keyword.WALLFLOWER)
	var value: float = (0.0 if wallflower else 2.0 * float(attack) * personality.attack_value) + float(defense) * personality.defense_value
	for keyword: CardEnums.Keyword in keywords:
		value += _keyword_value(keyword, attack)
	for ability: CardAbility in card.data.abilities():
		match ability.kind:
			CardAbility.Kind.ACT:
				value += 1.5
			CardAbility.Kind.DIE, CardAbility.Kind.WHEN, CardAbility.Kind.ATTACK, CardAbility.Kind.BLOCK, CardAbility.Kind.START_OF_TURN, CardAbility.Kind.END_OF_TURN, CardAbility.Kind.AURA, CardAbility.Kind.STATIC:
				value += 1.0
	if card.cannot_block or card.temp_cannot_block:
		value -= 1.0
	value = value * BOARD_UNIT + BODY_VALUE
	if state.rule_active(Modifier.Kind.ROT) and defense <= 1:
		value *= 0.1
	return value


static func _keyword_value(keyword: CardEnums.Keyword, attack: int) -> float:
	match keyword:
		CardEnums.Keyword.FLYING:
			return 2.0 if attack > 0 else 0.5
		CardEnums.Keyword.ELUSIVE:
			return 3.0 if attack > 0 else 0.5
		CardEnums.Keyword.HUSTLE:
			return 1.0
		CardEnums.Keyword.BULLDOZE:
			return 1.0
		CardEnums.Keyword.SUCKER_PUNCH:
			return 1.5
		CardEnums.Keyword.ONE_TWO_PUNCH:
			return 3.0
		CardEnums.Keyword.TOXIC:
			return 2.0
		CardEnums.Keyword.NOURISH:
			return 1.5
		CardEnums.Keyword.OVERTIME:
			return 1.5
		CardEnums.Keyword.UNBREAKABLE:
			return 3.0
		CardEnums.Keyword.UNTOUCHABLE:
			return 1.0
		CardEnums.Keyword.SWAT:
			return 0.5
	return 0.0


# ---- Board, hand, resources ----------------------------------------------------------------------------------------------------------


## `artifact_scale` multiplies the worth of Tools and Wonders (the foe's, for a Refusemancer).
func board_value(state: GameState, player: PlayerState, artifact_scale: float = 1.0) -> float:
	var total: float = 0.0
	var units: int = 0
	for card: CardInstance in player.field:
		if card.data.is_unit():
			total += unit_value(state, card)
			units += 1
		elif card.data.is_tool():
			total += (2.0 if card.attached_to != 0 else 1.5) * artifact_scale
		else:
			total += (2.5 + 0.8 * float(_activated_abilities(card))) * artifact_scale
	# Going wide is worth a little on its own (more blocks, more attackers, token payoffs).
	total += personality.width_weight * float(maxi(0, units - 1))
	for trap: CardInstance in player.traps:
		total += TRAP_VALUE * trap_likelihood(state, player.index, trap)
	return total


static func _activated_abilities(card: CardInstance) -> int:
	var count: int = 0
	for ability: CardAbility in card.data.abilities():
		if ability.is_activated():
			count += 1
	return count


func hand_value(player: PlayerState) -> float:
	var total: float = 0.0
	for card: CardInstance in player.hand:
		total += 0.4 if card.data.is_infrastructure() else 1.0
	return minf(total, 7.0)


## Resources: Iron / Red Tape / Contracts are worth holding a little (they are combat tricks); Ingredients and Garbage are fuel, worth
## more to a player with a spender on the table or in hand.
func resource_value(state: GameState, player: PlayerState) -> float:
	var total: float = 0.0
	for resource: CardInstance in player.resources + player.tokens:
		var kind: ResourceKind.Kind = resource.data.resource_kind as ResourceKind.Kind
		match kind:
			ResourceKind.Kind.IRON:
				total += personality.iron_hold_value
			ResourceKind.Kind.RED_TAPE:
				total += personality.red_tape_hold_value
			ResourceKind.Kind.CONTRACT:
				total += 1.0
			_:
				total += FUEL_VALUE * personality.fuel_value if spends(state, player, kind) else IDLE_FUEL_VALUE
	return total


## Whether a card in this player's hand or on their table spends `kind` (Eat Garbage, Use an Ingredient...).
func spends(_state: GameState, player: PlayerState, kind: ResourceKind.Kind) -> bool:
	for pile: Array[CardInstance] in [player.field, player.hand, player.infrastructure]:
		for card: CardInstance in pile:
			var key: String = "%s:%d" % [card.data.id, int(kind)]
			if not _fuel_cache.has(key):
				var word: String = ResourceKind.script_word(kind)
				_fuel_cache[key] = card.data.script_text.contains(word) or (kind == ResourceKind.Kind.GARBAGE and card.data.script_text.contains("eat"))
			if bool(_fuel_cache[key]):
				return true
	return false


## How likely a set Trap's condition is to come up soon, from the board (0.2 - 1.0).
func trap_likelihood(state: GameState, owner: int, trap: CardInstance) -> float:
	var foe: PlayerState = state.players[1 - owner]
	var mine: PlayerState = state.players[owner]
	var event: String = ""
	var filters: Array[String] = []
	for ability: CardAbility in trap.data.abilities():
		if ability.kind == CardAbility.Kind.TRAP:
			event = ability.event
			filters = ability.event_filters
			break
	match event:
		"attacks", "attacked":
			var attackers: int = 0
			for unit: CardInstance in foe.units():
				var f: Fighter = fighter(state, unit)
				if not f.wallflower and f.attack > 0 and (not filters.has("atk<=3") or f.attack <= 3):
					attackers += 1
			return 1.0 if attackers > 0 else 0.5
		"unit_enters":
			if filters.has("mine"):
				return 0.8 if mine.hand.size() > 0 else 0.3
			return 0.9 if foe.hand.size() > 0 else 0.3
		"plays":
			if filters.has("tool|wonder") or filters.has("wonder") or filters.has("tool"):
				return 0.35
			if filters.has("cost>=4"):
				return 0.5 if foe.infrastructure.size() >= 3 else 0.25
			return 0.8
		"hp_drops":
			return 0.9 if mine.hp <= 8 else 0.4
		"unit_dies", "token_dies":
			if filters.has("opp"):
				return 0.6 if not foe.units().is_empty() else 0.3
			return 0.7 if not mine.units().is_empty() else 0.2
		"infra_enters":
			return 0.9
		"creates_token", "token_created", "resource_created":
			return 0.5
	return 0.5


# ---- Combat model ------------------------------------------------------------------------------------------------------------------


## What the opponent can push through next turn: {"face": damage to `me`, "my_loss": value of my blockers that would die,
## "their_loss": value of their attackers that would die}. Their attackers = every unit that will be ready on their turn; my blockers
## = my units that are ready now (attackers I exhausted this turn stay exhausted).
func threat(state: GameState, me: int) -> Dictionary:
	var foe: PlayerState = state.players[1 - me]
	var attackers: Array[Fighter] = []
	for card: CardInstance in foe.units():
		var f: Fighter = fighter(state, card)
		if f.wallflower or (card.exhausted and card.skip_refresh > 0):
			continue
		attackers.append(f)
	var blockers: Array[Fighter] = []
	for card: CardInstance in state.players[me].units():
		var f: Fighter = fighter(state, card)
		if f.blocks_now:
			blockers.append(f)
	var result: Dictionary = _estimate(state, attackers, blockers, foe.index, state.players[me].hp, true)
	var summons: int = future_summon_push(state, foe.index)
	result["face"] = int(result["face"]) + summons
	result["raw_face"] = int(result["raw_face"]) + summons
	return result


## What `me` can push through: this turn (`now`: units that can attack now, against the foe's ready blockers) or on a later turn
## (every non-Wallflower unit against every foe unit that may block).
func push_estimate(state: GameState, me: int, now: bool) -> Dictionary:
	var mine: PlayerState = state.players[me]
	var foe: PlayerState = state.players[1 - me]
	var attackers: Array[Fighter] = []
	if now:
		var can_declare: bool = state.phase == GameState.Phase.MAIN1 or (state.phase == GameState.Phase.COMBAT and state.combat_step == GameState.CombatStep.DECLARE_ATTACKERS)
		if can_declare and state.active == me:
			for card: CardInstance in state.possible_attackers(me):
				attackers.append(fighter(state, card))
	else:
		for card: CardInstance in mine.units():
			var f: Fighter = fighter(state, card)
			if not f.wallflower and not (card.exhausted and card.skip_refresh > 0):
				attackers.append(f)
	var blockers: Array[Fighter] = []
	for card: CardInstance in foe.units():
		var f: Fighter = fighter(state, card)
		if (f.blocks_now if now else f.blocks_later):
			blockers.append(f)
	return _estimate(state, attackers, blockers, -1, foe.hp, not now)


## The same model on raw cards (for callers outside an evaluation).
func attack_estimate(state: GameState, _attacker_index: int, attackers: Array[CardInstance], blockers: Array[CardInstance], expiring_for: int, defender_hp: int) -> Dictionary:
	var a: Array[Fighter] = []
	for card: CardInstance in attackers:
		a.append(fighter(state, card))
	var b: Array[Fighter] = []
	for card: CardInstance in blockers:
		b.append(fighter(state, card))
	return _estimate(state, a, b, expiring_for, defender_hp, false)


## Fast combat model: the attacker picks its package by marginal value - start with everyone, drop the unit whose presence costs the
## most, until every attacker pulls its weight - against the defender's greedy blocks (block when it kills the attacker and survives,
## trade when the attacker is worth at least as much, chump the biggest attackers only to stay alive). A package that is lethal with
## everyone counts in full whatever it costs; otherwise an attack that loses more than it gains is not made (all zero). `later` reads
## the units as they will be next turn (this turn's pumps and damage gone); `expiring_for` >= 0 drops the lingering shrinks that end
## at the start of that player's turn. Returns {"face" (after emergency chumps), "raw_face" (before them), "my_loss", "their_loss"}
## from the attacker's side.
func _estimate(state: GameState, attackers: Array[Fighter], blockers: Array[Fighter], expiring_for: int, defender_hp: int, later: bool) -> Dictionary:
	var ordered: Array[Fighter] = []
	for f: Fighter in attackers:
		if _atk(state, f, expiring_for, later) > 0:
			ordered.append(f)
	if ordered.is_empty():
		return _zero()
	ordered.sort_custom(func(a: Fighter, b: Fighter) -> bool: return _atk(state, a, expiring_for, later) > _atk(state, b, expiring_for, later))
	var everyone: Dictionary = _simulate_package(state, ordered, blockers, expiring_for, defender_hp, later)
	if int(everyone["face"]) >= defender_hp:
		return everyone
	var package: Array[Fighter] = ordered.duplicate()
	var current: Dictionary = everyone
	for _round: int in range(ordered.size()):
		if package.size() <= 1:
			break
		var base_score: float = _package_score(current)
		var worst: Fighter = null
		var worst_gain: float = -0.0001
		var worst_result: Dictionary = {}
		for f: Fighter in package:
			var rest: Array[Fighter] = package.duplicate()
			rest.erase(f)
			var without: Dictionary = _simulate_package(state, rest, blockers, expiring_for, defender_hp, later)
			var gain: float = base_score - _package_score(without)
			if gain < worst_gain:
				worst_gain = gain
				worst = f
				worst_result = without
		if worst == null:
			break
		package.erase(worst)
		current = worst_result
	if _package_score(current) < 0.0:
		return _zero()
	return current


static func _zero() -> Dictionary:
	return {"face": 0, "raw_face": 0, "my_loss": 0.0, "their_loss": 0.0}


## `raw_face` is the damage before the defender's emergency chump blocks (the sustained push); `face` is after them.
static func _package_score(estimate: Dictionary) -> float:
	return float(int(estimate["raw_face"])) + float(estimate["their_loss"]) - float(estimate["my_loss"])


## Whether `blocker` may block `attacker` (Flying needs Flying or Swat, Elusive cannot be blocked).
static func can_block(attacker: Fighter, blocker: Fighter) -> bool:
	if attacker.elusive:
		return false
	if attacker.flying:
		return blocker.flying or blocker.swat
	return true


## Whether `source` dealing `amount` kills `target` right now (Toxic kills on any damage, Unbreakable never dies to damage).
static func kills(source: Fighter, target: Fighter, amount: int) -> bool:
	return _kills(source.toxic, target.unbreakable, amount, target.defense_left)


static func _kills(source_toxic: bool, target_unbreakable: bool, amount: int, target_defense: int) -> bool:
	if amount <= 0 or target_unbreakable:
		return false
	return source_toxic or amount >= target_defense


func _atk(state: GameState, f: Fighter, expiring_for: int, later: bool) -> int:
	var attack: int = _attack_after(state, f, expiring_for)
	return maxi(0, attack - f.card.temp_attack) if later else attack


static func _def(f: Fighter, later: bool) -> int:
	return f.defense_later if later else f.defense_left


func _simulate_package(state: GameState, ordered: Array[Fighter], blockers: Array[Fighter], expiring_for: int, defender_hp: int, later: bool) -> Dictionary:
	var free: Array[Fighter] = blockers.duplicate()
	var face: int = 0
	var my_loss: float = 0.0
	var their_loss: float = 0.0
	var unblocked: Array[Fighter] = []
	for attacker: Fighter in ordered:
		var attack: int = _atk(state, attacker, expiring_for, later)
		var attacker_defense: int = _def(attacker, later)
		var best: Fighter = null
		var best_rank: int = 0
		for blocker: Fighter in free:
			if not can_block(attacker, blocker):
				continue
			var it_kills: bool = _kills(blocker.toxic, attacker.unbreakable, _atk(state, blocker, expiring_for, later), attacker_defense)
			var it_survives: bool = not _kills(attacker.toxic, blocker.unbreakable, attack, _def(blocker, later))
			var rank: int = 0
			if it_kills and it_survives:
				rank = 3
			elif it_kills and attacker.value >= blocker.value:
				rank = 2
			elif it_survives:
				rank = 1
			if rank > best_rank:
				best_rank = rank
				best = blocker
		if best == null:
			face += attack
			unblocked.append(attacker)
			continue
		free.erase(best)
		if best_rank >= 2:
			my_loss += attacker.value
		if best_rank == 2:
			their_loss += best.value
		if attacker.bulldoze:
			face += maxi(0, attack - _def(best, later))
	var raw_face: int = face
	# Chump blocks only when the face damage would be lethal.
	if face >= defender_hp and not free.is_empty():
		for attacker: Fighter in unblocked:
			if face < defender_hp or free.is_empty():
				break
			for blocker: Fighter in free:
				if can_block(attacker, blocker):
					free.erase(blocker)
					var attack: int = _atk(state, attacker, expiring_for, later)
					face -= attack
					if attacker.bulldoze:
						face += maxi(0, attack - _def(blocker, later))
					their_loss += blocker.value
					break
	return {"face": face, "raw_face": raw_face, "my_loss": my_loss, "their_loss": their_loss}


## Damage the encounter rules deal to `player`'s opponent at the start of `player`'s turns (Shrapnel), as part of their clock.
static func start_of_turn_damage(state: GameState, player: int) -> int:
	var total: int = 0
	for effect: EffectData in state.players[player].modifiers.effects_of(Modifier.Kind.START_OF_TURN_EFFECT):
		if effect.op == CardEnums.EffectOp.DEAL_DAMAGE and effect.target == CardEnums.TargetKind.OPPONENT:
			total += effect.amount
	return total


## Attack the encounter rules will hand `player` soon: a timed summon due next turn counts in full, a later one by half; an escalating
## summon (the Graveyard) always adds the next stage.
static func future_summon_push(state: GameState, player: int) -> int:
	var total: float = 0.0
	var who: PlayerState = state.players[player]
	for modifier: Modifier in who.modifiers.modifiers:
		if modifier.kind == Modifier.Kind.TIMED_SUMMON and not modifier.tokens.is_empty() and modifier.value > 0:
			var next_turn: int = who.turns_taken + 1
			var due_next: bool = next_turn % modifier.value == 0
			var attack: float = float(modifier.tokens[0].attack * maxi(1, modifier.value2))
			total += attack if due_next else attack * 0.5
		elif modifier.kind == Modifier.Kind.SCRIPTED_ESCALATING_SUMMON and not modifier.tokens.is_empty():
			var stage: int = mini(who.scripted_summon_count, modifier.tokens.size() - 1)
			total += float(modifier.tokens[stage].attack) * 0.5
	return int(total)
