class_name GameState
extends RefCounted
## Complete state and rules for one two-player duel. Pure logic: no Nodes, no scene tree.
## Every state change is appended to `events` (and emitted) so a UI can animate from it.
## See docs/design/combat_rules.md for the rules this implements.

signal event_emitted(event: GameEvent)

enum Phase { START, MAIN1, COMBAT, MAIN2, END }
enum Stage { SETUP, MULLIGAN, PLAYING, OVER }
enum CombatStep { NONE, DECLARE_ATTACKERS, DECLARE_BLOCKERS }

const INFRASTRUCTURE_DROPS_PER_TURN: int = 1
## Base face-down traps one player may have set at a time, before Modifier.Kind.MAX_TRAPS
## (dungeon rules, equipment...) - see PlayerState.max_traps, set once in add_player().
const MAX_TRAPS: int = 3
## At most this many target combinations are offered per card or ability in legal_actions().
const MAX_TARGET_COMBOS: int = 30

## Every event name a `when(...)` or `trap(...)` ability may listen to (the importer reports anything else as unsupported).
const EVENT_NAMES: Array[String] = [
	"unit_enters", "unit_dies", "destroyed", "attacks", "blocks", "plays", "infra_enters", "creates_token", "token_created",
	"resource_created", "resource_used", "eat", "hp_drops", "attached_attacks", "attached_dies", "attached_dmg_opp",
	"attached_combat_dmg_unit",
]

var options: GameOptions
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var players: Array[PlayerState] = []
var events: Array[GameEvent] = []
var stage: Stage = Stage.SETUP
var phase: Phase = Phase.START
var combat_step: CombatStep = CombatStep.NONE
## Total turns taken so far (both players); the first turn is 1.
var turn: int = 0
var active: int = 0
var first_player: int = 0
## Winning player index, or -1 while undecided / drawn.
var winner: int = -1
var is_draw: bool = false
## Cards the active player must discard before their turn ends (hand size limit).
var pending_toss: int = 0
## Current combat: attacker uids, attacker -> blocker, and the attackers that were blocked (even if the blocker later died).
var attackers: Array[int] = []
var blocks: Dictionary = {}
var blocked_attackers: Dictionary = {}

var _next_uid: int = 1
var _next_sequence: int = 0
var _mulligan_done: Array[bool] = [false, false]
## Nesting level of effect triggers (loop guard) and a counter that postpones state-based
## checks while simultaneous damage is being applied.
var trigger_depth: int = 0
var defer_state_checks: int = 0
## Brief 14: units that just died while their death triggers resolve (so `trig` selectors can still find them).
var limbo: Array[CardInstance] = []
## Delayed effects (Processing X, "at the start of your next turn"): {ctx, block, turns_left, player}.
var delayed: Array[Dictionary] = []
## Temporarily borrowed permanents: {uid, back_to, until_turn}.
var borrowed: Array[Dictionary] = []


func _init(game_options: GameOptions = null) -> void:
	options = game_options if game_options != null else GameOptions.new()


# --------------------------------------------------------------------------------------
# Setup
# --------------------------------------------------------------------------------------


func add_player(setup: PlayerSetup) -> PlayerState:
	var profile: PlayerProfile = setup.profile if setup.profile != null else PlayerProfile.new()
	var player: PlayerState = PlayerState.new()
	player.index = players.size()
	player.player_name = setup.player_name
	player.modifiers = setup.modifiers.clone()
	var mods: ModifierSet = player.modifiers
	player.max_hp = maxi(1, profile.base_max_hp() + mods.sum(Modifier.Kind.MAX_HP))
	if setup.starting_hp >= 0:
		player.hp = setup.starting_hp
	else:
		player.hp = maxi(1, player.max_hp + mods.sum(Modifier.Kind.STARTING_HP))
	player.max_hand_size = maxi(1, profile.base_max_hand_size() + mods.sum(Modifier.Kind.MAX_HAND_SIZE))
	player.opening_hand_size = maxi(1, profile.base_opening_hand() + mods.sum(Modifier.Kind.OPENING_HAND_SIZE))
	player.max_traps = maxi(0, MAX_TRAPS + mods.sum(Modifier.Kind.MAX_TRAPS))
	player.non_infrastructure_play_cap = mods.cap(Modifier.Kind.MAX_NON_INFRASTRUCTURE_PLAYS_PER_TURN)
	for data: CardData in setup.deck.cards:
		player.deck.append(create_instance(data, player.index))
	# Brief 10: junk cards shuffled into the deck (the Capital's Clutter debuff).
	for modifier: Modifier in mods.modifiers:
		if modifier.kind == Modifier.Kind.SHUFFLE_JUNK_INTO_DECK and not modifier.tokens.is_empty():
			for junk_index: int in range(maxi(modifier.value, 0)):
				player.deck.append(create_instance(modifier.tokens[0], player.index))
	if setup.deck.size() > 0:
		player.deck_infrastructure_ratio = float(setup.deck.infrastructure_count()) / float(setup.deck.size())
	players.append(player)
	return player


## Shuffles, deals opening hands and enters the mulligan stage. Call after adding both players.
func start() -> void:
	assert(players.size() == 2, "GameState needs exactly two players")
	if options.rng_seed != 0:
		rng.seed = options.rng_seed
	else:
		rng.randomize()
	first_player = options.first_player if options.first_player >= 0 else _pick_first_player()
	active = first_player
	for player: PlayerState in players:
		RngUtil.shuffle(player.deck, rng)
	emit_event(GameEvent.Type.GAME_STARTED, first_player)
	for player: PlayerState in players:
		_deal_opening_hand(player)
	stage = Stage.MULLIGAN
	if not options.free_mulligan:
		_mulligan_done = [true, true]
		_begin_playing()


## New brief, Part B: ALWAYS_FIRST (e.g. Cheater's Dice) picks the first player instead of the
## normal coin flip. If both players somehow have it, falls back to the coin flip - see
## docs/design/open_questions.md D92.
func _pick_first_player() -> int:
	var p0_always_first: bool = players[0].modifiers.has(Modifier.Kind.ALWAYS_FIRST)
	var p1_always_first: bool = players[1].modifiers.has(Modifier.Kind.ALWAYS_FIRST)
	if p0_always_first and not p1_always_first:
		return 0
	if p1_always_first and not p0_always_first:
		return 1
	return rng.randi_range(0, 1)


func _deal_opening_hand(player: PlayerState) -> void:
	var hand: Array[CardInstance] = HandSmoother.draw_opening_hand(
		player.deck, player.opening_hand_size, player.deck_infrastructure_ratio, options.hand_smoother, rng, options.smoother_tolerance
	)
	for card: CardInstance in hand:
		player.hand.append(card)
		emit_event(GameEvent.Type.CARD_DRAWN, player.index, card.uid, 0, 1, player.hand.size(), "opening")
	if options.hand_smoother:
		emit_event(GameEvent.Type.HAND_SMOOTHED, player.index, 0, 0, HandSmoother.count_infrastructure(hand))


## Takes the one free mulligan: hand is shuffled back and the same number of cards drawn.
func mulligan(player_index: int) -> bool:
	if stage != Stage.MULLIGAN or awaiting_player() != player_index:
		return false
	var player: PlayerState = players[player_index]
	if player.mulligan_used or not options.free_mulligan:
		return false
	player.mulligan_used = true
	for card: CardInstance in player.hand:
		player.deck.append(card)
	player.hand.clear()
	emit_event(GameEvent.Type.MULLIGAN_TAKEN, player_index)
	_deal_opening_hand(player)
	_mulligan_done[player_index] = true
	_try_begin_playing()
	return true


func keep_hand(player_index: int) -> bool:
	if stage != Stage.MULLIGAN or awaiting_player() != player_index:
		return false
	emit_event(GameEvent.Type.HAND_KEPT, player_index)
	_mulligan_done[player_index] = true
	_try_begin_playing()
	return true


func _try_begin_playing() -> void:
	if _mulligan_done[0] and _mulligan_done[1]:
		_begin_playing()


func _begin_playing() -> void:
	stage = Stage.PLAYING
	# Part G: START_OF_DUEL_EFFECT (e.g. the Champion's Laurels), after the mulligans and before turn 1.
	for index: int in range(players.size()):
		_fire_modifier_effects(index, Modifier.Kind.START_OF_DUEL_EFFECT)
		for modifier: Modifier in players[index].modifiers.modifiers:
			if modifier.kind == Modifier.Kind.STARTING_RESOURCES and modifier.value > 0:
				ResourceRules.create(self, index, modifier.value2 as ResourceKind.Kind, modifier.value)
	_begin_turn()


# --------------------------------------------------------------------------------------
# Queries
# --------------------------------------------------------------------------------------


func is_over() -> bool:
	return stage == Stage.OVER


## Whose decision the game is waiting on (-1 when over / not started).
func awaiting_player() -> int:
	match stage:
		Stage.MULLIGAN:
			var order: Array[int] = [first_player, 1 - first_player]
			for index: int in order:
				if not _mulligan_done[index]:
					return index
			return -1
		Stage.PLAYING:
			if pending_toss > 0:
				return active
			if phase == Phase.COMBAT and combat_step == CombatStep.DECLARE_BLOCKERS:
				return 1 - active
			return active
	return -1


static func opponent_of(player_index: int) -> int:
	return 1 - player_index


func find_card(uid: int) -> CardInstance:
	for dying: CardInstance in limbo:
		if dying.uid == uid:
			return dying
	for player: PlayerState in players:
		for zone: Array[CardInstance] in [player.field, player.infrastructure, player.hand, player.traps, player.refuse_pile, player.resources]:
			var card: CardInstance = PlayerState.find_in(zone, uid)
			if card != null:
				return card
	return null


## Finds a unit/wonder currently on a field.
func find_permanent(uid: int) -> CardInstance:
	for player: PlayerState in players:
		var card: CardInstance = player.find_field(uid)
		if card != null:
			return card
	return null


func all_units() -> Array[CardInstance]:
	var result: Array[CardInstance] = []
	for player: PlayerState in players:
		result.append_array(player.units())
	return result


func get_attack(card: CardInstance) -> int:
	if not card.data.is_unit():
		return 0
	var bonus: Vector2i = players[card.owner].modifiers.stat_bonus_for(card.data) + StaticEffects.stat_bonus(self, card)
	var base: int = card.set_attack if card.set_attack >= 0 else _base_stats(card).x
	return maxi(0, base + card.attack_bonus + card.temp_attack + bonus.x)


func get_defense(card: CardInstance) -> int:
	if not card.data.is_unit():
		return 0
	var zone_bonus: Vector2i = players[card.owner].modifiers.stat_bonus_for(card.data)
	var bonus: Vector2i = zone_bonus + StaticEffects.stat_bonus(self, card)
	var base: int = card.set_defense if card.set_defense >= 0 else _base_stats(card).y
	var total: int = base + card.defense_bonus + card.temp_defense + bonus.y
	# A negative zone effect (a debuff) never kills a unit outright by itself: it leaves at least 1.
	if zone_bonus.y < 0 and base >= 1:
		total = maxi(total, 1)
	return total


## Whether a unit has `keyword` right now: printed, granted, until-end-of-turn, or from an aura or attached Tool.
func unit_has_keyword(card: CardInstance, keyword: CardEnums.Keyword) -> bool:
	return card.has_keyword(keyword) or StaticEffects.has_extra_keyword(self, card, keyword)


## A unit's base (attack, defense): its card's, unless a STANDARDIZE_UNITS rule is in force for
## the duel (Primm's Standardization), which gives every unit the same stats.
func _base_stats(card: CardInstance) -> Vector2i:
	for player: PlayerState in players:
		for modifier: Modifier in player.modifiers.modifiers:
			if modifier.kind == Modifier.Kind.STANDARDIZE_UNITS:
				return Vector2i(modifier.value, modifier.value2)
	return Vector2i(card.data.attack, card.data.defense)


## Generic cost after cost-change modifiers (never below 0).
func generic_cost_for(player_index: int, data: CardData, card: CardInstance = null) -> int:
	var change: int = players[player_index].modifiers.sum_for_card(Modifier.Kind.COST_CHANGE, data)
	change += StaticEffects.cost_increase(self, player_index, data)
	var base: int = data.generic_cost
	if card != null:
		var override: Dictionary = StaticEffects.cost_override(self, player_index, card)
		if not override.is_empty():
			base = int(override["generic"])
	return maxi(0, base + change)


## The colored pips of a card's cost right now (a cost override such as the Big Unit's replaces them).
func pips_for(player_index: int, data: CardData, card: CardInstance = null) -> Array[Affinity.Type]:
	if card != null:
		var override: Dictionary = StaticEffects.cost_override(self, player_index, card)
		if not override.is_empty():
			return override["pips"] as Array[Affinity.Type]
	return data.colored_pips


func in_main_phase() -> bool:
	return stage == Stage.PLAYING and (phase == Phase.MAIN1 or phase == Phase.MAIN2) and pending_toss == 0


# --------------------------------------------------------------------------------------
# Playing cards
# --------------------------------------------------------------------------------------


func can_play_infrastructure(player_index: int, uid: int) -> bool:
	if not in_main_phase() or player_index != active:
		return false
	var player: PlayerState = players[player_index]
	if player.infrastructure_played >= StaticEffects.infrastructure_drops(self, player_index):
		return false
	var card: CardInstance = player.find_hand(uid)
	return card != null and card.data.is_infrastructure()


func play_infrastructure(player_index: int, uid: int) -> bool:
	if not can_play_infrastructure(player_index, uid):
		return false
	var player: PlayerState = players[player_index]
	var card: CardInstance = player.find_hand(uid)
	player.hand.erase(card)
	player.infrastructure.append(card)
	card.exhausted = false
	player.infrastructure_played += 1
	player.cards_played_this_turn += 1
	emit_event(GameEvent.Type.INFRASTRUCTURE_PLAYED, player_index, uid, 0, 1, player.infrastructure.size())
	_infrastructure_entered(card)
	fire_game_event("plays", {"card": card, "player": player_index})
	check_state()
	return true


## The additional play costs of a card ("As an additional cost to play this, ...").
func play_costs_of(data: CardData) -> Array[CardAbility.Cost]:
	var result: Array[CardAbility.Cost] = []
	for ability: CardAbility in data.abilities():
		if ability.kind == CardAbility.Kind.PLAY_COST:
			result.append_array(ability.costs)
	return result


## The ability whose declared targets the player chooses when playing the card: a Spell's PLAY ability, or the ENTER ability of
## a permanent (the first that declares targets). Null when the card needs no chosen target.
func play_ability_of(data: CardData) -> CardAbility:
	var wanted: CardAbility.Kind = CardAbility.Kind.PLAY if data.type == CardEnums.CardType.SPELL else CardAbility.Kind.ENTER
	for ability: CardAbility in data.abilities():
		if ability.kind == wanted and not ability.targets.is_empty():
			return ability
	return null


## A context for evaluating a card's play targets and costs while it is still in hand.
func play_context(player_index: int, card: CardInstance, ability: CardAbility = null) -> AbilityContext:
	return AbilityContext.make(self, ability, card, player_index)


## The legal choices for target declaration `decl_index` of the card's play ability (empty when it has none).
func legal_play_targets(player_index: int, uid: int, decl_index: int) -> Array[int]:
	var card: CardInstance = players[player_index].find_hand(uid)
	if card == null:
		return [] as Array[int]
	var ability: CardAbility = play_ability_of(card.data)
	if ability == null or decl_index >= ability.targets.size():
		return [] as Array[int]
	return TargetResolver.legal_targets(ability.targets[decl_index], play_context(player_index, card, ability))


## True when a Spell/permanent with declared targets has what it needs: every single-target declaration has a legal choice
## (a Spell cannot be played without one; a permanent's enter ability just fizzles).
func _play_targets_available(player_index: int, card: CardInstance) -> bool:
	if card.data.type != CardEnums.CardType.SPELL:
		return true
	var ability: CardAbility = play_ability_of(card.data)
	if ability == null:
		return true
	var ctx: AbilityContext = play_context(player_index, card, ability)
	for decl: CardAbility.TargetDecl in ability.targets:
		if decl.max_count == 1 and TargetResolver.legal_targets(decl, ctx).is_empty():
			return false
	return true


func can_play_card(player_index: int, uid: int, targets: Array[int] = [] as Array[int], picks: Array[int] = [] as Array[int]) -> bool:
	if not in_main_phase() or player_index != active:
		return false
	var player: PlayerState = players[player_index]
	var card: CardInstance = player.find_hand(uid)
	if card == null or card.data.is_infrastructure():
		return false
	if card.data.is_unit() and player.modifiers.has(Modifier.Kind.NO_UNIT_PLAYS):
		return false
	if player.non_infrastructure_play_cap >= 0 and player.non_infrastructure_plays_this_turn >= player.non_infrastructure_play_cap:
		return false
	if card.data.type == CardEnums.CardType.TRAP and player.traps.size() >= player.max_traps:
		return false
	var extra: Array[CardAbility.Cost] = play_costs_of(card.data)
	var energy: Dictionary = AbilityRunner.energy_cost(extra)
	var generic: int = generic_cost_for(player_index, card.data, card) + int(energy["generic"])
	var pips: Array[Affinity.Type] = pips_for(player_index, card.data, card).duplicate()
	pips.append_array(energy["pips"] as Array[Affinity.Type])
	if not can_pay_energy(player_index, generic, pips):
		return false
	if not extra.is_empty() and not AbilityRunner.can_pay_costs(play_context(player_index, card), extra, picks):
		return false
	if not _play_targets_available(player_index, card):
		return false
	# Legacy (EffectData) spells that need a chosen target cannot be played without a legal one.
	var target_effect: EffectData = _primary_target_effect(card.data)
	if target_effect != null and card.data.type == CardEnums.CardType.SPELL:
		return not legal_targets(player_index, target_effect, uid).is_empty()
	return true


## Plays a card from hand. `target` is the first chosen target (a Targets ref); `extra_targets` are the rest, in declaration
## order (the last declaration may take several). `picks` choose the cards destroyed or used for additional costs, `x` the X of
## "use X Ingredients". `activate_uids` optionally names the exact infrastructure to exhaust; otherwise energy is paid automatically.
func play_card(
	player_index: int,
	uid: int,
	target: int = 0,
	activate_uids: Array[int] = [] as Array[int],
	extra_targets: Array[int] = [] as Array[int],
	picks: Array[int] = [] as Array[int],
) -> bool:
	var chosen_targets: Array[int] = []
	if target != 0:
		chosen_targets.append(target)
	chosen_targets.append_array(extra_targets)
	if not can_play_card(player_index, uid, chosen_targets, picks):
		return false
	var player: PlayerState = players[player_index]
	var card: CardInstance = player.find_hand(uid)
	var ability: CardAbility = play_ability_of(card.data)
	if not _targets_are_legal(player_index, card, ability, chosen_targets):
		return false
	var chosen: int = target
	var target_effect: EffectData = _primary_target_effect(card.data)
	if target_effect != null:
		if target != 0 and not legal_targets(player_index, target_effect, uid).has(target):
			return false
	elif ability == null:
		chosen = 0
	var extra: Array[CardAbility.Cost] = play_costs_of(card.data)
	var energy: Dictionary = AbilityRunner.energy_cost(extra)
	var generic: int = generic_cost_for(player_index, card.data, card) + int(energy["generic"])
	var pips: Array[Affinity.Type] = pips_for(player_index, card.data, card).duplicate()
	pips.append_array(energy["pips"] as Array[Affinity.Type])
	if not _pay(player_index, generic, pips, activate_uids, uid):
		return false
	var seed_ctx: AbilityContext = play_context(player_index, card, ability)
	if not extra.is_empty():
		AbilityRunner.pay_costs(seed_ctx, extra, picks)
	player.hand.erase(card)
	player.non_infrastructure_plays_this_turn += 1
	player.cards_played_this_turn += 1
	emit_event(GameEvent.Type.CARD_PLAYED, player_index, uid, chosen, card.data.energy_value())
	match card.data.type:
		CardEnums.CardType.UNIT, CardEnums.CardType.WONDER, CardEnums.CardType.TOOL:
			_enter_field(card, chosen, true, chosen_targets, seed_ctx)
			fire_game_event("plays", {"card": card, "player": player_index})
		CardEnums.CardType.SPELL:
			fire_traps(1 - player_index, CardEnums.Trigger.TRAP_OPPONENT_SPELL, uid)
			fire_game_event("plays", {"card": card, "player": player_index})
			if not is_over():
				fire_trigger(card, CardEnums.Trigger.ON_ENTER, 0, chosen)
				_resolve_card_abilities(card, CardAbility.Kind.PLAY, seed_ctx, null, chosen_targets)
			_send_to_refuse_pile(card)
		CardEnums.CardType.TRAP:
			card.face_down = true
			player.traps.append(card)
			emit_event(GameEvent.Type.TRAP_SET, player_index, uid, 0, 0, player.traps.size())
			fire_game_event("plays", {"card": card, "player": player_index})
	check_state()
	return true


## Every given target must be a legal choice for its declaration (declarations take targets in order; a multi-target one takes the rest).
func _targets_are_legal(player_index: int, card: CardInstance, ability: CardAbility, chosen: Array[int]) -> bool:
	if ability == null:
		return chosen.is_empty() or _primary_target_effect(card.data) != null
	var ctx: AbilityContext = play_context(player_index, card, ability)
	var position: int = 0
	for decl: CardAbility.TargetDecl in ability.targets:
		var legal: Array[int] = TargetResolver.legal_targets(decl, ctx)
		var take: int = 1 if decl.max_count == 1 else decl.max_count
		var taken: int = 0
		while taken < take and position < chosen.size():
			if not legal.has(chosen[position]):
				return false
			taken += 1
			position += 1
	return position == chosen.size()


## New brief, Part F: whether `item` could be used right now by `player_index` (their own main
## phase, and a legal target if its effect needs one - the same rule spells follow). Items are
## equipped gear, not cards - no energy cost, no hand/field involvement, so this sits beside
## can_play_card/play_card rather than going through the PLAY GameAction.
func can_use_item(player_index: int, item: ItemData) -> bool:
	if item == null or item.effect == null or not in_main_phase() or player_index != active:
		return false
	if item.effect.needs_chosen_target():
		return not legal_targets(player_index, item.effect, 0).is_empty()
	return true


## Resolves an equipped item's effect against the live duel. `target` is a Targets ref, required
## only when the effect needs a chosen target. Does not touch PlayerProfile/inventory bookkeeping
## (which uses/charges are spent) - that is Session's job, once this returns true; see
## app/game_session.gd `use_equipped_item`.
func use_item(player_index: int, item: ItemData, target: int = 0) -> bool:
	if not can_use_item(player_index, item):
		return false
	if item.effect.needs_chosen_target() and not legal_targets(player_index, item.effect, 0).has(target):
		return false
	EffectResolver.resolve(self, item.effect, EffectContext.make(0, player_index, 0, target))
	check_state()
	return true


## True when `player_index` could pay `generic` + `pips` right now (floating energy plus ready infrastructure).
func can_pay_energy(player_index: int, generic: int, pips: Array[Affinity.Type]) -> bool:
	var player: PlayerState = players[player_index]
	return PathEnergy.can_pay(player.ready_infrastructure(), generic, pips, player.pool)


func _pay(player_index: int, generic: int, pips: Array[Affinity.Type], activate_uids: Array[int], for_uid: int) -> bool:
	return pay_energy(player_index, generic, pips, activate_uids, for_uid)


## Pays energy: floating energy first (unless exact infrastructure were named), then ready infrastructure.
func pay_energy(player_index: int, generic: int, pips: Array[Affinity.Type], activate_uids: Array[int], for_uid: int) -> bool:
	var player: PlayerState = players[player_index]
	var to_activate: Array[CardInstance] = []
	var pool_spent: Array[int] = []
	if activate_uids.is_empty():
		if generic > 0 or not pips.is_empty():
			var solution: Dictionary = PathEnergy.solve(player.ready_infrastructure(), generic, pips, player.pool)
			if solution.is_empty():
				return false
			to_activate.append_array(solution["infra"] as Array[CardInstance])
			pool_spent.append_array(solution["pool"] as Array[int])
	else:
		for infrastructure_uid: int in activate_uids:
			var infra: CardInstance = player.find_infrastructure(infrastructure_uid)
			if infra == null or infra.exhausted or to_activate.has(infra):
				return false
			to_activate.append(infra)
		if not PathEnergy.exact_payment_ok(to_activate, generic, pips):
			return false
	for entry: int in pool_spent:
		player.pool.erase(entry)
	for infra: CardInstance in to_activate:
		infra.exhausted = true
		emit_event(GameEvent.Type.ENERGY_SPENT, player_index, infra.uid, for_uid, 1, int(infra.data.color))
	if not pool_spent.is_empty():
		emit_event(GameEvent.Type.ENERGY_SPENT, player_index, 0, for_uid, pool_spent.size(), -1)
	return true


## First ON_ENTER effect that needs a player-chosen target.
func _primary_target_effect(data: CardData) -> EffectData:
	for effect: EffectData in data.effects:
		if effect.trigger == CardEnums.Trigger.ON_ENTER and effect.needs_chosen_target():
			return effect
	return null


## Legal chosen targets (Targets refs) for an effect controlled by `controller`.
func legal_targets(controller: int, effect: EffectData, _source_uid: int) -> Array[int]:
	return EffectResolver.legal_targets(self, controller, effect)


## Puts a permanent onto the field under its owner's control and runs everything that happens when it enters.
## `targets` are the targets chosen for its enter ability; `seed_ctx` carries what was paid for it.
func _enter_field(card: CardInstance, chosen: int, played_from_hand: bool, targets: Array[int] = [] as Array[int], seed_ctx: AbilityContext = null) -> void:
	var player: PlayerState = players[card.owner]
	player.field.append(card)
	card.summoning_sick = true
	card.exhausted = false
	card.damage = 0
	card.entered_turn = turn
	if card.data.is_unit():
		_apply_static_equipment_grants(card, player)
		if StaticEffects.enters_exhausted(self, card.owner):
			card.exhausted = true
	emit_event(GameEvent.Type.PERMANENT_ENTERED, card.owner, card.uid, 0, 0, player.field.size())
	var entry_data: Dictionary = {"card": card, "player": card.owner, "hustle": card.has_keyword(CardEnums.Keyword.HUSTLE)}
	if played_from_hand and card.data.is_unit():
		fire_traps(1 - card.owner, CardEnums.Trigger.TRAP_OPPONENT_UNIT, card.uid)
	if card.data.is_unit() and not is_over():
		fire_game_event("unit_enters", entry_data)
	if not is_over() and player.find_field(card.uid) != null:
		fire_trigger(card, CardEnums.Trigger.ON_ENTER, 0, chosen)
		_resolve_card_abilities(card, CardAbility.Kind.ENTER, seed_ctx, null, targets)
	if card.data.is_unit() and not is_over():
		_fire_modifier_effects(card.owner, Modifier.Kind.ON_UNIT_ENTER_EFFECT)
	if card.data.is_unit() and not is_over():
		_fire_modifier_effects(1 - card.owner, Modifier.Kind.ON_ENEMY_UNIT_ENTER_EFFECT, card.uid)


## New brief, Part B: applies the controller's GRANT_KEYWORD_TO_CREATURES/CANNOT_BLOCK equipment
## modifiers (e.g. Hover Boots) once, when a unit enters the field. Equipment doesn't
## change mid-duel, so this never needs to be recomputed afterwards.
func _apply_static_equipment_grants(card: CardInstance, player: PlayerState) -> void:
	for keyword: CardEnums.Keyword in player.modifiers.keyword_grants_for(Modifier.Kind.GRANT_KEYWORD_TO_UNITS, card.data):
		if not card.granted_keywords.has(keyword):
			card.granted_keywords.append(keyword)
	if player.modifiers.has(Modifier.Kind.CANNOT_BLOCK):
		card.cannot_block = true
	if player.modifiers.sum_for_card(Modifier.Kind.ENTER_EXHAUSTED, card.data) > 0:
		card.exhausted = true


## Resolves all of a card's abilities of one kind (enter, die, play, attack...). `seed_ctx` (what was paid, X...) is copied into
## each; `targets` are the player's chosen targets for the first ability that declares any, the rest are picked automatically.
func _resolve_card_abilities(
	card: CardInstance,
	kind: CardAbility.Kind,
	seed_ctx: AbilityContext = null,
	trigger: CardInstance = null,
	targets: Array[int] = [] as Array[int],
	data: Dictionary = {},
) -> void:
	var chosen_used: bool = false
	for ability: CardAbility in card.data.abilities():
		if ability.kind != kind:
			continue
		if is_over():
			return
		var ctx: AbilityContext = AbilityContext.make(self, ability, card, card.owner)
		if seed_ctx != null:
			ctx.vars = seed_ctx.vars.duplicate()
			ctx.paid = seed_ctx.paid.duplicate()
			ctx.x = seed_ctx.x
		ctx.trigger = trigger
		ctx.data = data
		if trigger != null and kind == CardAbility.Kind.DIE:
			ctx.trigger = card
		_bind_host(ctx, card, trigger)
		if not chosen_used and not ability.targets.is_empty() and not targets.is_empty():
			bind_targets(ctx, ability, targets)
			chosen_used = true
		TargetResolver.auto_targets(ctx)
		emit_event(GameEvent.Type.EFFECT_TRIGGERED, card.owner, card.uid, trigger.uid if trigger != null else 0, int(kind))
		AbilityRunner.resolve(ctx)


## For Tools: the unit they are attached to (or the unit named by an attached-unit event).
func _bind_host(ctx: AbilityContext, card: CardInstance, trigger: CardInstance) -> void:
	if card.attached_to != 0:
		ctx.host = find_permanent(card.attached_to)
	if ctx.host == null and trigger != null and card.data.is_tool():
		ctx.host = trigger


## Assigns a flat list of chosen target refs to an ability's declarations in order (a multi-target declaration takes the rest).
func bind_targets(ctx: AbilityContext, ability: CardAbility, refs: Array[int]) -> void:
	var position: int = 0
	for decl: CardAbility.TargetDecl in ability.targets:
		var bound: Array[int] = []
		var take: int = 1 if decl.max_count == 1 else decl.max_count
		while bound.size() < take and position < refs.size():
			bound.append(refs[position])
			position += 1
		ctx.targets[decl.name] = bound


## Spells, discards and Traps that have resolved: the card goes to its owner's Refuse Pile (tokens simply vanish).
func _send_to_refuse_pile(card: CardInstance) -> void:
	var was_token: bool = card.is_token()
	card.reset()
	if not was_token:
		players[card.real_owner].refuse_pile.append(card)



# --------------------------------------------------------------------------------------
# Turn structure
# --------------------------------------------------------------------------------------


func _begin_turn() -> void:
	if turn >= options.turn_limit:
		_end_game(-1, true)
		return
	turn += 1
	phase = Phase.START
	combat_step = CombatStep.NONE
	pending_toss = 0
	var player: PlayerState = players[active]
	player.infrastructure_played = 0
	player.non_infrastructure_plays_this_turn = 0
	player.cards_played_this_turn = 0
	for infra: CardInstance in player.infrastructure:
		_refresh(infra)
	for card: CardInstance in player.field:
		_refresh(card)
		card.summoning_sick = false
		card.activated_this_turn = false
		card.used_abilities.clear()
		card.targeted_this_turn.clear()
	emit_event(GameEvent.Type.TURN_STARTED, active, 0, 0, turn)
	_resolve_delayed(active)
	if is_over():
		return
	# New brief, Part B: FIRST_TURN_EXTRA_DRAW (e.g. Traveler's Boots) applies once, on a player's
	# own first turn - including the game's very first turn, which otherwise draws 0 (the first
	# player skips their first draw).
	var is_players_first_turn: bool = not player.has_taken_first_turn
	player.has_taken_first_turn = true
	var draws: int = 0
	if turn > 1:
		draws += 1 + maxi(0, player.modifiers.sum(Modifier.Kind.EXTRA_DRAWS))
	if is_players_first_turn:
		draws += maxi(0, player.modifiers.sum(Modifier.Kind.FIRST_TURN_EXTRA_DRAW))
	if draws > 0:
		draw_cards(active, draws)
	if is_over():
		return
	_fire_turn_triggers(active, CardEnums.Trigger.START_OF_TURN)
	if is_over():
		return
	_fire_kind_abilities(active, CardAbility.Kind.START_OF_TURN)
	if is_over():
		return
	_fire_start_of_turn_effects(active)
	if is_over():
		return
	_fire_scripted_summons(active)
	if is_over():
		return
	_set_phase(Phase.MAIN1)


func _set_phase(new_phase: Phase) -> void:
	phase = new_phase
	emit_event(GameEvent.Type.PHASE_CHANGED, active, 0, 0, int(new_phase))


## Resolves one kind of scripted ability (start of turn, beginning of combat, end of turn) on every permanent a player controls.
func _fire_kind_abilities(player_index: int, kind: CardAbility.Kind) -> void:
	for card: CardInstance in players[player_index].field.duplicate():
		if is_over():
			return
		if players[player_index].find_field(card.uid) == null:
			continue
		_resolve_card_abilities(card, kind)
	check_state()


## Processing X and "at the start of your next turn" effects: each of the owner's turn starts counts one down.
func _resolve_delayed(player_index: int) -> void:
	var due: Array[Dictionary] = []
	var waiting: Array[Dictionary] = []
	for entry: Dictionary in delayed:
		if int(entry["player"]) == player_index:
			entry["turns_left"] = int(entry["turns_left"]) - 1
			if int(entry["turns_left"]) <= 0:
				due.append(entry)
				continue
		waiting.append(entry)
	delayed = waiting
	for entry: Dictionary in due:
		if is_over():
			return
		var ctx: AbilityContext = entry["ctx"] as AbilityContext
		ctx.rebind(self)
		emit_event(GameEvent.Type.PROCESSING_RESOLVED, player_index, ctx.source_uid())
		AbilityRunner.run_block(ctx, entry["block"] as CardAbility.FxBlock)
	check_state()


## Queues effects to resolve at the start of the controller's turn, `turns` of their turns from now.
func schedule_delayed(ctx: AbilityContext, block: CardAbility.FxBlock, turns: int) -> void:
	delayed.append({"ctx": ctx, "block": block, "turns_left": maxi(1, turns), "player": ctx.controller})
	emit_event(GameEvent.Type.PROCESSING_STARTED, ctx.controller, ctx.source_uid(), 0, turns)


## Permanents taken "until end of turn" go back to their owner.
func _return_borrowed() -> void:
	var still: Array[Dictionary] = []
	for entry: Dictionary in borrowed:
		if int(entry["until_turn"]) <= turn:
			var card: CardInstance = find_card(int(entry["uid"]))
			if card != null:
				steal_card(card, int(entry["back_to"]), false)
		else:
			still.append(entry)
	borrowed = still


## Moves to the next phase (or, in combat, declares no attackers / no blockers).
func advance_phase() -> bool:
	if stage != Stage.PLAYING or pending_toss > 0:
		return false
	match phase:
		Phase.MAIN1:
			_enter_combat()
			return true
		Phase.COMBAT:
			return _pass_in_combat()
		Phase.MAIN2:
			_end_phase()
			return true
	return false


func _enter_combat() -> void:
	_set_phase(Phase.COMBAT)
	combat_step = CombatStep.DECLARE_ATTACKERS
	attackers.clear()
	blocks.clear()
	blocked_attackers.clear()
	_fire_start_of_combat(active)
	_fire_kind_abilities(active, CardAbility.Kind.BEGINNING_OF_COMBAT)


## Passing in combat = declaring no attackers (attacker's turn) or no blockers (defender's).
func _pass_in_combat() -> bool:
	if combat_step == CombatStep.DECLARE_ATTACKERS:
		return declare_attackers([] as Array[int])
	if combat_step == CombatStep.DECLARE_BLOCKERS:
		return declare_blockers({})
	return false


## Attacking player declares attackers (they always attack the opposing player).
func declare_attackers(uids: Array[int]) -> bool:
	return CombatResolver.declare_attackers(self, uids)


## Defending player assigns blockers: attacker uid -> blocker uid. Damage resolves right after.
func declare_blockers(assignment: Dictionary) -> bool:
	return CombatResolver.declare_blockers(self, assignment)


func possible_attackers(player_index: int) -> Array[CardInstance]:
	return CombatResolver.possible_attackers(self, player_index)


func possible_blockers(player_index: int) -> Array[CardInstance]:
	return CombatResolver.possible_blockers(self, player_index)


## Ends combat: clears combat bookkeeping and moves to Main 2.
func finish_combat() -> void:
	attackers.clear()
	blocks.clear()
	blocked_attackers.clear()
	combat_step = CombatStep.NONE
	_set_phase(Phase.MAIN2)


func _end_phase() -> void:
	_set_phase(Phase.END)
	_fire_turn_triggers(active, CardEnums.Trigger.END_OF_TURN)
	_fire_kind_abilities(active, CardAbility.Kind.END_OF_TURN)
	_return_borrowed()
	_fire_modifier_effects(active, Modifier.Kind.END_OF_TURN_EFFECT)
	if is_over():
		return
	for player: PlayerState in players:
		for card: CardInstance in player.field:
			var had_damage: int = card.damage
			card.clear_end_of_turn()
			if had_damage > 0:
				emit_event(GameEvent.Type.DAMAGE_CLEARED, player.index, card.uid, 0, had_damage)
	for player: PlayerState in players:
		player.pool.clear()
	var excess: int = players[active].hand.size() - players[active].max_hand_size
	if excess > 0:
		pending_toss = excess
		return
	_finish_turn()


## Discards down to the hand size limit at the end of the turn.
func toss_for_hand_size(player_index: int, uids: Array[int]) -> bool:
	if stage != Stage.PLAYING or pending_toss <= 0 or player_index != active:
		return false
	if uids.size() != pending_toss:
		return false
	var player: PlayerState = players[player_index]
	var chosen: Array[CardInstance] = []
	for uid: int in uids:
		var card: CardInstance = player.find_hand(uid)
		if card == null or chosen.has(card):
			return false
		chosen.append(card)
	for card: CardInstance in chosen:
		toss_card(player_index, card)
	pending_toss = 0
	_finish_turn()
	return true


func _finish_turn() -> void:
	active = 1 - active
	_begin_turn()


# --------------------------------------------------------------------------------------
# Zone and HP primitives (also used by the effect system)
# --------------------------------------------------------------------------------------


func draw_cards(player_index: int, count: int) -> void:
	var player: PlayerState = players[player_index]
	for i: int in range(count):
		if is_over():
			return
		if player.deck.is_empty():
			# Drawing from an empty deck loses the game.
			player.lost = true
			emit_event(GameEvent.Type.PLAYER_LOST, player_index, 0, 0, 0, 0, "deck_out")
			check_state()
			return
		var card: CardInstance = player.deck.pop_back()
		# A Clause token springs when it is drawn: it never reaches the hand.
		if card.data.type == CardEnums.CardType.TOKEN and _has_ability_kind(card.data, CardAbility.Kind.DRAWN):
			card.owner = player_index
			limbo.append(card)
			emit_event(GameEvent.Type.CARD_DRAWN, player_index, card.uid, 0, 1, player.hand.size(), "clause")
			_resolve_card_abilities(card, CardAbility.Kind.DRAWN)
			limbo.erase(card)
			continue
		player.hand.append(card)
		emit_event(GameEvent.Type.CARD_DRAWN, player_index, card.uid, 0, 1, player.hand.size())


func _has_ability_kind(data: CardData, kind: CardAbility.Kind) -> bool:
	for ability: CardAbility in data.abilities():
		if ability.kind == kind:
			return true
	return false


func toss_card(player_index: int, card: CardInstance) -> void:
	var player: PlayerState = players[player_index]
	if not player.hand.has(card):
		return
	player.hand.erase(card)
	player.refuse_pile.append(card)
	emit_event(GameEvent.Type.CARD_TOSSED, player_index, card.uid)


func bury_cards(player_index: int, count: int) -> void:
	bury_deck(player_index, count)


## Bury X: the top X cards of a deck go to their owner's Refuse Pile. Returns the cards buried.
func bury_deck(player_index: int, count: int) -> Array[CardInstance]:
	var player: PlayerState = players[player_index]
	var buried: Array[CardInstance] = []
	for i: int in range(count):
		if player.deck.is_empty():
			break
		var card: CardInstance = player.deck.pop_back()
		if not card.is_token():
			players[card.real_owner].refuse_pile.append(card)
		buried.append(card)
		emit_event(GameEvent.Type.CARD_BURIED, player_index, card.uid, 0, 1, player.deck.size())
	return buried


## Peek X: look at the top X cards of your deck and put any on the bottom in any order. The engine keeps the cards worth
## drawing on top (best last = drawn first) and sends the ones that are not useful right now to the bottom.
func peek_deck(player_index: int, count: int) -> void:
	var player: PlayerState = players[player_index]
	var take: int = mini(count, player.deck.size())
	if take <= 0:
		return
	var looked: Array[CardInstance] = []
	for i: int in range(take):
		looked.append(player.deck.pop_back())
	var infra_out: int = player.infrastructure.size()
	var keep: Array[CardInstance] = []
	var bottom: Array[CardInstance] = []
	for card: CardInstance in looked:
		if _peek_value(card, infra_out) < 1.2:
			bottom.append(card)
		else:
			keep.append(card)
	keep.sort_custom(func(a: CardInstance, b: CardInstance) -> bool: return _peek_value(a, infra_out) < _peek_value(b, infra_out))
	for i: int in range(bottom.size()):
		player.deck.insert(0, bottom[i])
	for card: CardInstance in keep:
		player.deck.append(card)
	emit_event(GameEvent.Type.PEEKED, player_index, 0, 0, take, bottom.size())


func _peek_value(card: CardInstance, infra_out: int) -> float:
	if card.data.is_infrastructure():
		return 4.0 if infra_out < 5 else 0.5
	return float(card.data.energy_value()) + 1.5


## Raises HP, never above max HP (a higher starting HP is left alone).
func gain_hp(player_index: int, amount: int) -> void:
	if amount <= 0 or is_over():
		return
	var player: PlayerState = players[player_index]
	amount += maxi(0, player.modifiers.sum(Modifier.Kind.HP_GAIN_BONUS))
	var new_hp: int = maxi(player.hp, mini(player.hp + amount, player.max_hp))
	var delta: int = new_hp - player.hp
	if delta > 0:
		player.hp = new_hp
		emit_event(GameEvent.Type.HP_CHANGED, player_index, 0, 0, delta, new_hp)


## HP loss that is not damage (no Nourish, no damage triggers).
func lose_hp(player_index: int, amount: int) -> void:
	if amount <= 0 or is_over():
		return
	var player: PlayerState = players[player_index]
	player.hp -= amount
	emit_event(GameEvent.Type.HP_CHANGED, player_index, 0, 0, -amount, player.hp)
	fire_game_event("hp_drops", {"player": player_index, "hp": player.hp})


## Damage to a player. Returns the damage dealt.
func deal_damage_to_player(source_uid: int, player_index: int, amount: int) -> int:
	if amount <= 0 or is_over():
		return 0
	var player: PlayerState = players[player_index]
	player.hp -= amount
	emit_event(GameEvent.Type.DAMAGE_DEALT, player_index, source_uid, Targets.player(player_index), amount, player.hp)
	emit_event(GameEvent.Type.HP_CHANGED, player_index, 0, 0, -amount, player.hp)
	_apply_nourish(source_uid, amount)
	fire_traps(player_index, CardEnums.Trigger.TRAP_PLAYER_DAMAGED, source_uid)
	if not is_over():
		_fire_modifier_effects(player_index, Modifier.Kind.ON_PLAYER_DAMAGED_EFFECT)
	if not is_over():
		fire_game_event("hp_drops", {"player": player_index, "hp": player.hp})
	var source: CardInstance = find_permanent(source_uid) if source_uid > 0 else null
	if source != null and source.data.is_unit() and source.owner != player_index and not is_over():
		fire_attached_event(source, "attached_dmg_opp", {"card": source, "player": source.owner})
	return amount


## Damage to a unit. Returns the damage dealt. Lethal damage is resolved by check_state().
func deal_damage_to_unit(source_uid: int, target: CardInstance, amount: int) -> int:
	if amount <= 0 or is_over() or not target.data.is_unit():
		return 0
	if players[target.owner].find_field(target.uid) == null:
		return 0
	if turn < target.protected_until_turn:
		return 0
	target.damage += amount
	emit_event(GameEvent.Type.DAMAGE_DEALT, target.owner, source_uid, target.uid, amount, target.damage)
	_apply_nourish(source_uid, amount)
	var source: CardInstance = find_permanent(source_uid) if source_uid > 0 else null
	if source != null and source.data.is_unit() and unit_has_keyword(source, CardEnums.Keyword.TOXIC):
		target.toxic_hit = true
	fire_trigger(target, CardEnums.Trigger.ON_DAMAGE_TAKEN, source_uid, 0)
	return amount


func _apply_nourish(source_uid: int, amount: int) -> void:
	if source_uid <= 0:
		return
	var source: CardInstance = find_permanent(source_uid)
	if source != null and source.data.is_unit() and unit_has_keyword(source, CardEnums.Keyword.NOURISH):
		gain_hp(source.owner, amount)


## Removes a unit from the field (death), then fires its death triggers. The unit is in the Refuse Pile (tokens: nowhere) while
## "when this dies" and "whenever a unit dies" abilities resolve, so cards can bring it back; its stats are what they were.
func destroy_unit(card: CardInstance) -> void:
	var player: PlayerState = players[card.owner]
	if player.find_field(card.uid) == null:
		return
	var controller: int = card.owner
	player.field.erase(card)
	_clear_combat_refs(card.uid)
	limbo.append(card)
	emit_event(GameEvent.Type.UNIT_DIED, controller, card.uid)
	var attached: Array[CardInstance] = attached_tools(card)
	fire_attached_event(card, "attached_dies", {"card": card, "player": controller}, attached)
	for tool_card: CardInstance in attached:
		tool_card.attached_to = 0
	# Death triggers use the card as it was; reset only after they resolve.
	fire_trigger(card, CardEnums.Trigger.ON_DEATH, 0, 0)
	if not card.is_token():
		players[card.real_owner].refuse_pile.append(card)
	_resolve_card_abilities(card, CardAbility.Kind.DIE, null, card)
	fire_game_event("unit_dies", {"card": card, "player": controller})
	fire_game_event("destroyed", {"card": card, "player": controller})
	if card.data.is_unit() and not is_over():
		_fire_modifier_effects(controller, Modifier.Kind.ON_ALLY_DEATH_EFFECT)
	limbo.erase(card)
	if players[card.real_owner].refuse_pile.has(card):
		card.reset()
		_maybe_return_from_refuse_pile(card)


## Brief 10 (Restless Dead): a dead unit may climb out of the Refuse Pile again (GRAVEYARD_RETURN_CHANCE percent).
func _maybe_return_from_refuse_pile(card: CardInstance) -> void:
	if is_over() or card.data.is_token or not card.data.is_unit():
		return
	var chance: int = players[card.owner].modifiers.sum(Modifier.Kind.GRAVEYARD_RETURN_CHANCE)
	if chance <= 0 or rng.randi_range(1, 100) > chance:
		return
	var owner_state: PlayerState = players[card.owner]
	if not owner_state.refuse_pile.has(card):
		return
	owner_state.refuse_pile.erase(card)
	_enter_field(card, 0, false)


func _clear_combat_refs(uid: int) -> void:
	attackers.erase(uid)
	blocked_attackers.erase(uid)
	blocks.erase(uid)
	for attacker_uid: Variant in blocks.keys():
		if int(blocks[attacker_uid]) == uid:
			blocks.erase(attacker_uid)


## State-based checks: dead units leave play, players at 0 HP (or who tried to draw from
## an empty deck) lose. Repeats until stable. A unit with 0 defense dies even if it is Unbreakable; Unbreakable units survive
## lethal damage and Toxic.
func check_state() -> void:
	for pass_index: int in range(50):
		if is_over():
			return
		var dying: Array[CardInstance] = []
		for player: PlayerState in players:
			for card: CardInstance in player.field:
				if not card.data.is_unit():
					continue
				var defense: int = get_defense(card)
				if defense <= 0:
					dying.append(card)
				elif card.damage >= defense or card.toxic_hit:
					if not unit_has_keyword(card, CardEnums.Keyword.UNBREAKABLE):
						dying.append(card)
		if dying.is_empty():
			break
		for card: CardInstance in dying:
			destroy_unit(card)
	_resolve_losses()



func _resolve_losses() -> void:
	if is_over():
		return
	var losers: Array[int] = []
	for player: PlayerState in players:
		if player.lost or player.hp <= 0:
			losers.append(player.index)
	if losers.is_empty():
		return
	for loser: int in losers:
		emit_event(GameEvent.Type.PLAYER_LOST, loser, 0, 0, 0, players[loser].hp, "hp" if not players[loser].lost else "deck_out")
	if losers.size() == 2:
		_end_game(-1, true)
	else:
		_end_game(1 - losers[0], false)


func _end_game(winning_player: int, drawn: bool) -> void:
	stage = Stage.OVER
	winner = winning_player
	is_draw = drawn
	emit_event(GameEvent.Type.GAME_OVER, winning_player, 0, 0, turn, 0, "draw" if drawn else "win")


# --------------------------------------------------------------------------------------
# Effects, triggers, traps and activated abilities
# --------------------------------------------------------------------------------------


## Fires a card's effects for `trigger`.
func fire_trigger(card: CardInstance, trigger: CardEnums.Trigger, trigger_uid: int, chosen: int) -> void:
	EffectResolver.fire(self, card, trigger, trigger_uid, chosen)


## Fires `trigger` on all of `owner_index`'s set traps.
func fire_traps(owner_index: int, trigger: CardEnums.Trigger, trigger_uid: int) -> void:
	EffectResolver.fire_traps(self, owner_index, trigger, trigger_uid)


## Fires START_OF_TURN / END_OF_TURN for a player's permanents.
func _fire_turn_triggers(player_index: int, trigger: CardEnums.Trigger) -> void:
	for card: CardInstance in players[player_index].field.duplicate():
		if is_over():
			return
		if players[player_index].find_field(card.uid) != null:
			fire_trigger(card, trigger, 0, 0)
	check_state()


## Fires the active player's START_OF_COMBAT_EFFECT modifiers (equipment, items, zones...).
func _fire_start_of_combat(player_index: int) -> void:
	for effect: EffectData in players[player_index].modifiers.effects_of(Modifier.Kind.START_OF_COMBAT_EFFECT):
		if is_over():
			return
		EffectResolver.resolve(self, effect, EffectContext.make(0, player_index))
	check_state()


## New brief, Part B: fires the active player's START_OF_TURN_EFFECT modifiers (e.g. Flamethrower)
## - equipment equivalent of _fire_start_of_combat, but for the whole turn.
func _fire_start_of_turn_effects(player_index: int) -> void:
	for effect: EffectData in players[player_index].modifiers.effects_of(Modifier.Kind.START_OF_TURN_EFFECT):
		if is_over():
			return
		EffectResolver.resolve(self, effect, EffectContext.make(0, player_index))
	check_state()


## New brief, Part F: fires the active player's SCRIPTED_ESCALATING_SUMMON modifiers - a reusable
## scripted-encounter rule (the Graveyard boss, and any future boss that reuses it). Each
## activation summons the next stage in that modifier's `tokens` (capped at the last once past
## the end, so the escalation never runs out), tracked per-player via `scripted_summon_count`
## since a player could in principle have more than one such source.
func _fire_scripted_summons(player_index: int) -> void:
	var player: PlayerState = players[player_index]
	for modifier: Modifier in player.modifiers.modifiers:
		if modifier.kind != Modifier.Kind.SCRIPTED_ESCALATING_SUMMON or modifier.tokens.is_empty():
			continue
		if is_over():
			return
		var stage: int = mini(player.scripted_summon_count, modifier.tokens.size() - 1)
		create_token(player_index, modifier.tokens[stage])
		player.scripted_summon_count += 1
	check_state()


## New brief, Part B: fires the defender's RETALIATE_ON_ATTACK modifiers (e.g. Thorned Loincloth)
## against every declared attacker, regardless of whether they end up blocked. Public (not
## prefixed like the turn/combat helpers above) because it's called from CombatResolver, not
## from within GameState itself - same as `fire_traps`/`fire_trigger`.
func fire_retaliation(defender_index: int) -> void:
	for effect: EffectData in players[defender_index].modifiers.effects_of(Modifier.Kind.RETALIATE_ON_ATTACK):
		if is_over():
			return
		EffectResolver.resolve(self, effect, EffectContext.make(0, defender_index))
	check_state()


func can_activate(player_index: int, uid: int, effect_index: int) -> bool:
	if not in_main_phase() or player_index != active:
		return false
	var player: PlayerState = players[player_index]
	var card: CardInstance = player.find_field(uid)
	if card == null or card.activated_this_turn:
		return false
	if effect_index < 0 or effect_index >= card.data.effects.size():
		return false
	var effect: EffectData = card.data.effects[effect_index]
	if effect.trigger != CardEnums.Trigger.ACTIVATED:
		return false
	if not PathEnergy.can_pay(player.ready_infrastructure(), effect.activation_cost, [] as Array[Affinity.Type]):
		return false
	if effect.needs_chosen_target():
		return not legal_targets(player_index, effect, uid).is_empty()
	return true


## Uses an ACTIVATED effect: pays its generic cost, once per turn per permanent.
func activate(player_index: int, uid: int, effect_index: int, target: int = 0) -> bool:
	if not can_activate(player_index, uid, effect_index):
		return false
	var card: CardInstance = players[player_index].find_field(uid)
	var effect: EffectData = card.data.effects[effect_index]
	if effect.needs_chosen_target() and target != 0 and not legal_targets(player_index, effect, uid).has(target):
		return false
	if not _pay(player_index, effect.activation_cost, [] as Array[Affinity.Type], [] as Array[int], uid):
		return false
	card.activated_this_turn = true
	emit_event(GameEvent.Type.ABILITY_ACTIVATED, player_index, uid, target, effect_index)
	EffectResolver.resolve(self, effect, EffectContext.make(uid, player_index, 0, target))
	check_state()
	return true


# --------------------------------------------------------------------------------------
# Brief 14: refresh, exhaust, stats, targeting and resources
# --------------------------------------------------------------------------------------


## Refreshes (untaps) a card at the start of its controller's turn, unless it is set not to refresh this turn
## (Contract, Overexert, Food Coma...): that consumes one `skip_refresh`.
func _refresh(card: CardInstance) -> void:
	if card.skip_refresh > 0:
		card.skip_refresh -= 1
		return
	card.exhausted = false


## Exhausts a unit. With `no_refresh` it also doesn't refresh during its controller's next turn.
func exhaust_unit(card: CardInstance, no_refresh: bool = false) -> void:
	card.exhausted = true
	if no_refresh:
		card.skip_refresh += 1
	emit_event(GameEvent.Type.UNIT_EXHAUSTED, card.owner, card.uid, 0, 1 if no_refresh else 0)


## Permanent (default) or until-end-of-turn stat change on a unit.
func change_stats(card: CardInstance, attack_delta: int, defense_delta: int, until_end_of_turn: bool) -> void:
	if until_end_of_turn:
		card.temp_attack += attack_delta
		card.temp_defense += defense_delta
	else:
		card.attack_bonus += attack_delta
		card.defense_bonus += defense_delta
	emit_event(GameEvent.Type.STATS_CHANGED, card.owner, card.uid, 0, attack_delta, defense_delta)


## Whether `by_player` may target `card` with their own cards, abilities or resources. Untouchable units cannot be targeted by
## the opponent; a unit protected until a later turn (Working in Your Own Casket) cannot be targeted by anyone.
func can_be_targeted_by(card: CardInstance, by_player: int) -> bool:
	if turn < card.protected_until_turn:
		return false
	return not (card.owner != by_player and card.has_keyword(CardEnums.Keyword.UNTOUCHABLE))


## Infrastructure that just entered the field: its own "when this Infrastructure enters" abilities run (a basic Infrastructure
## creates its Path's resource; special and dual-Path infrastructure never do).
func _infrastructure_entered(card: CardInstance) -> void:
	card.entered_turn = turn
	_resolve_card_abilities(card, CardAbility.Kind.ENTER)
	fire_game_event("infra_enters", {"card": card, "player": card.owner})


# ---- Triggered abilities ("whenever ...") and Traps ---------------------------------------------------------


## Dispatches a game event ("unit_enters", "unit_dies", "attacks", "plays", "resource_created", ...) to every permanent on the field
## with a matching `when(...)` ability and every set Trap with a matching `trap(...)` condition. A sprung Trap is spent.
func fire_game_event(event_name: String, data: Dictionary = {}) -> void:
	if is_over() or trigger_depth >= AbilityRunner.MAX_DEPTH:
		return
	var fired: Array[Array] = []
	for player: PlayerState in players:
		for card: CardInstance in player.field:
			if card.data.listens_to(event_name):
				for ability: CardAbility in card.data.abilities():
					if ability.kind == CardAbility.Kind.WHEN and ability.event == event_name:
						fired.append([card, ability])
		for trap_card: CardInstance in player.traps:
			if trap_card.data.listens_to(event_name):
				for ability: CardAbility in trap_card.data.abilities():
					if ability.kind == CardAbility.Kind.TRAP and ability.event == event_name:
						fired.append([trap_card, ability])
	# Filters are judged against the event as it happened (before any of these abilities changes the board).
	var matched: Array[Array] = []
	for entry: Array in fired:
		var holder: CardInstance = entry[0] as CardInstance
		if EventFilter.matches(self, (entry[1] as CardAbility).event_filters, holder, holder.owner, data):
			matched.append(entry)
	for entry: Array in matched:
		if is_over():
			return
		_resolve_event_ability(entry[0] as CardInstance, entry[1] as CardAbility, data)


func _resolve_event_ability(card: CardInstance, ability: CardAbility, data: Dictionary) -> void:
	var is_trap: bool = ability.kind == CardAbility.Kind.TRAP
	var player: PlayerState = players[card.owner]
	if is_trap:
		if not player.traps.has(card):
			return
	elif player.find_field(card.uid) == null:
		return
	var ctx: AbilityContext = AbilityContext.make(self, ability, card, card.owner)
	ctx.trigger = data.get("card") as CardInstance
	ctx.data = data
	_bind_host(ctx, card, ctx.trigger)
	if not AbilityRunner.condition_holds_for(ability, ctx):
		return
	TargetResolver.auto_targets(ctx)
	if is_trap:
		player.traps.erase(card)
		card.face_down = false
		emit_event(GameEvent.Type.TRAP_TRIGGERED, card.owner, card.uid, ctx.trigger.uid if ctx.trigger != null else 0)
		AbilityRunner.resolve(ctx)
		_send_to_refuse_pile(card)
	else:
		emit_event(GameEvent.Type.EFFECT_TRIGGERED, card.owner, card.uid, ctx.trigger.uid if ctx.trigger != null else 0, int(ability.kind))
		AbilityRunner.resolve(ctx)


## The Tools attached to a unit.
func attached_tools(unit: CardInstance) -> Array[CardInstance]:
	var result: Array[CardInstance] = []
	for player: PlayerState in players:
		for card: CardInstance in player.field:
			if card.data.is_tool() and card.attached_to == unit.uid and unit.uid != 0:
				result.append(card)
	return result


## Fires an "attached unit ..." event (`attached_attacks`, `attached_dies`, `attached_dmg_opp`, `attached_combat_dmg_unit`) on the
## Tools attached to `unit`. `tools` can be given when the unit is already detaching (it just died).
func fire_attached_event(unit: CardInstance, event_name: String, data: Dictionary, tools: Array[CardInstance] = [] as Array[CardInstance]) -> void:
	var holders: Array[CardInstance] = tools if not tools.is_empty() else attached_tools(unit)
	for tool_card: CardInstance in holders:
		if is_over():
			return
		for ability: CardAbility in tool_card.data.abilities():
			if ability.kind != CardAbility.Kind.WHEN or ability.event != event_name:
				continue
			var ctx: AbilityContext = AbilityContext.make(self, ability, tool_card, tool_card.owner)
			ctx.trigger = unit
			ctx.host = unit
			ctx.data = data
			if not AbilityRunner.condition_holds_for(ability, ctx):
				continue
			TargetResolver.auto_targets(ctx)
			AbilityRunner.resolve(ctx)


func resource_count(player_index: int, kind: ResourceKind.Kind) -> int:
	return players[player_index].count_resource(kind)


func can_use_resource(player_index: int, kind: ResourceKind.Kind, target_uid: int) -> bool:
	return ResourceRules.can_use_ability(self, player_index, kind, target_uid)


func use_resource(player_index: int, kind: ResourceKind.Kind, target_uid: int) -> bool:
	return ResourceRules.use_ability(self, player_index, kind, target_uid)


# ---- Scripted activated abilities ---------------------------------------------------------------------------------


## The context an activated ability of `card` would resolve in (for listing its legal targets and costs in the UI).
func activation_context(player_index: int, card: CardInstance, ability: CardAbility) -> AbilityContext:
	var ctx: AbilityContext = AbilityContext.make(self, ability, card, player_index)
	_bind_host(ctx, card, null)
	return ctx


func _activatable(player_index: int, uid: int) -> CardInstance:
	var player: PlayerState = players[player_index]
	var card: CardInstance = player.find_field(uid)
	if card == null:
		card = player.find_infrastructure(uid)
	if card == null:
		card = player.find_resource(uid)
	return card


func can_activate_ability(player_index: int, uid: int, ability_index: int, targets: Array[int] = [] as Array[int], x: int = 0, picks: Array[int] = [] as Array[int]) -> bool:
	if not in_main_phase() or player_index != active:
		return false
	var card: CardInstance = _activatable(player_index, uid)
	if card == null or card.owner != player_index:
		return false
	var abilities: Array[CardAbility] = card.data.abilities()
	if ability_index < 0 or ability_index >= abilities.size():
		return false
	var ability: CardAbility = abilities[ability_index]
	if not ability.is_activated():
		return false
	if ability.once and card.used_abilities.has(ability_index):
		return false
	var ctx: AbilityContext = AbilityContext.make(self, ability, card, player_index)
	ctx.x = x
	_bind_host(ctx, card, null)
	for decl: CardAbility.TargetDecl in ability.targets:
		if decl.max_count == 1 and TargetResolver.legal_targets(decl, ctx).is_empty():
			return false
	if not targets.is_empty() and not _targets_are_legal(player_index, card, ability, targets):
		return false
	for cost: CardAbility.Cost in ability.costs:
		if cost.x_count and x < 1:
			return false
	return AbilityRunner.can_pay_costs(ctx, ability.costs, picks)


## Activates an ability of a permanent: pays its costs, then resolves it (your turn only).
func activate_ability(player_index: int, uid: int, ability_index: int, targets: Array[int] = [] as Array[int], x: int = 0, picks: Array[int] = [] as Array[int]) -> bool:
	if not can_activate_ability(player_index, uid, ability_index, targets, x, picks):
		return false
	var card: CardInstance = _activatable(player_index, uid)
	var ability: CardAbility = card.data.abilities()[ability_index]
	var ctx: AbilityContext = AbilityContext.make(self, ability, card, player_index)
	ctx.x = x
	_bind_host(ctx, card, null)
	if not targets.is_empty():
		bind_targets(ctx, ability, targets)
	TargetResolver.auto_targets(ctx)
	if not AbilityRunner.pay_costs(ctx, ability.costs, picks):
		return false
	if ability.once:
		card.used_abilities.append(ability_index)
	for ref: int in AbilityRunner.refs_of_all_targets(ctx):
		if ref > 0:
			card.targeted_this_turn.append(ref)
	emit_event(GameEvent.Type.ABILITY_ACTIVATED, player_index, uid, targets[0] if not targets.is_empty() else 0, ability_index)
	AbilityRunner.resolve(ctx)
	check_state()
	return true


# ---- Cards changing zones and controllers -----------------------------------------------------------------------


func create_token(player_index: int, data: CardData, as_copy: bool = false) -> CardInstance:
	var token: CardInstance = create_instance(data, player_index)
	token.token_override = as_copy
	emit_event(GameEvent.Type.TOKEN_CREATED, player_index, token.uid)
	_enter_field(token, 0, false)
	fire_game_event("token_created", {"card": token, "player": player_index})
	fire_game_event("creates_token", {"card": token, "player": player_index})
	return token


## Whether the card is on a field (or among a player's infrastructure).
func field_contains(card: CardInstance) -> bool:
	var player: PlayerState = players[card.owner]
	return player.field.has(card) or player.infrastructure.has(card)


## A rough worth of a card, for choosing the best or cheapest of several.
func card_worth(card: CardInstance) -> int:
	if card.data.is_unit():
		var value: int = get_attack(card) * 2 + get_defense(card) + card.data.keywords.size() * 2 + card.buffs
		return value if players[card.owner].field.has(card) else card.data.energy_value() * 2 + card.data.attack + card.data.defense
	if card.data.is_resource():
		return 1 if card.data.resource_kind >= int(ResourceKind.Kind.INGREDIENT) else 2
	return card.data.energy_value() * 2 + 2


func _remove_from_zones(card: CardInstance) -> void:
	for player: PlayerState in players:
		for zone: Array[CardInstance] in [player.field, player.infrastructure, player.hand, player.refuse_pile, player.deck, player.traps, player.resources]:
			if zone.has(card):
				zone.erase(card)
	_clear_combat_refs(card.uid)


## Detaches every Tool attached to a unit that is leaving the field.
func _detach_all(unit: CardInstance) -> void:
	for tool_card: CardInstance in attached_tools(unit):
		tool_card.attached_to = 0


## Send back: a permanent on the field returns to its owner's hand (tokens vanish).
func send_back(card: CardInstance) -> bool:
	var player: PlayerState = players[card.owner]
	if not (player.field.has(card) or player.infrastructure.has(card)):
		return false
	_remove_from_zones(card)
	if card.data.is_unit():
		_detach_all(card)
	var was_token: bool = card.is_token()
	var home: int = card.real_owner
	card.reset()
	if was_token:
		return true
	players[home].hand.append(card)
	emit_event(GameEvent.Type.CARD_SENT_BACK, home, card.uid)
	return true


## Regrow: a card in a Refuse Pile returns to its owner's hand.
func return_from_refuse_to_hand(card: CardInstance) -> bool:
	for player: PlayerState in players:
		if player.refuse_pile.has(card):
			player.refuse_pile.erase(card)
			card.reset()
			players[card.real_owner].hand.append(card)
			emit_event(GameEvent.Type.CARD_TO_HAND, card.real_owner, card.uid)
			return true
	return false


## Reinstate: a unit in any Refuse Pile enters the field under `control_player`'s control.
func reinstate_card(card: CardInstance, control_player: int) -> bool:
	if not card.data.is_unit():
		return false
	for player: PlayerState in players:
		if player.refuse_pile.has(card):
			player.refuse_pile.erase(card)
			card.reset()
			card.owner = control_player
			emit_event(GameEvent.Type.UNIT_REINSTATED, control_player, card.uid, 0, 0, player.index)
			_enter_field(card, 0, false)
			return true
	return false


## Gain control of a permanent, resource or infrastructure. `temporary` returns it at the end of this turn.
func steal_card(card: CardInstance, to_player: int, temporary: bool) -> bool:
	if card.owner == to_player and not temporary:
		return false
	var from_player: int = card.owner
	if from_player == to_player:
		return false
	var source: PlayerState = players[from_player]
	var target: PlayerState = players[to_player]
	if source.field.has(card):
		source.field.erase(card)
		_clear_combat_refs(card.uid)
		if card.data.is_unit():
			_detach_all(card)
		card.owner = to_player
		card.summoning_sick = true
		target.field.append(card)
	elif source.infrastructure.has(card):
		source.infrastructure.erase(card)
		card.owner = to_player
		target.infrastructure.append(card)
	elif source.resources.has(card):
		source.resources.erase(card)
		card.owner = to_player
		target.resources.append(card)
	else:
		return false
	emit_event(GameEvent.Type.CONTROL_CHANGED, to_player, card.uid, from_player)
	if temporary:
		borrowed.append({"uid": card.uid, "back_to": from_player, "until_turn": turn})
	return true


## Plate: a unit becomes a 1/1 Snack token with no abilities.
func plate_card(card: CardInstance) -> bool:
	if not card.data.is_unit() or players[card.owner].find_field(card.uid) == null:
		return false
	var snack: CardData = TokenRegistry.data("T-09")
	if snack == null:
		return false
	card.data = snack
	card.token_override = true
	card.attack_bonus = 0
	card.defense_bonus = 0
	card.temp_attack = 0
	card.temp_defense = 0
	card.set_attack = -1
	card.set_defense = -1
	card.buffs = 0
	card.damage = 0
	card.granted_keywords.clear()
	card.temp_keywords.clear()
	card.cannot_block = false
	emit_event(GameEvent.Type.UNIT_PLATED, card.owner, card.uid)
	return true


## Brawl: two units deal damage equal to their attack to each other.
func brawl(first: CardInstance, second: CardInstance) -> bool:
	if first == second or not first.data.is_unit() or not second.data.is_unit():
		return false
	if not field_contains(first) or not field_contains(second):
		return false
	var first_attack: int = get_attack(first)
	var second_attack: int = get_attack(second)
	emit_event(GameEvent.Type.BRAWL, first.owner, first.uid, second.uid)
	defer_state_checks += 1
	deal_damage_to_unit(first.uid, second, first_attack)
	deal_damage_to_unit(second.uid, first, second_attack)
	defer_state_checks -= 1
	if defer_state_checks == 0:
		check_state()
	return true


## A token copy of a unit, under `controller`'s control.
func copy_unit_as_token(card: CardInstance, controller: int) -> CardInstance:
	if not card.data.is_unit():
		return null
	var copy: CardInstance = create_token(controller, card.data, true)
	emit_event(GameEvent.Type.UNIT_COPIED, controller, copy.uid, card.uid)
	return copy


## "Create a copy of each token you control" (unit tokens and resources).
func copy_each_token(player_index: int) -> bool:
	var made: bool = false
	for card: CardInstance in players[player_index].units():
		if card.is_token():
			made = copy_unit_as_token(card, player_index) != null or made
	var kinds: Dictionary = {}
	for resource: CardInstance in players[player_index].resources:
		kinds[resource.data.resource_kind] = int(kinds.get(resource.data.resource_kind, 0)) + 1
	for kind: Variant in kinds.keys():
		ResourceRules.create(self, player_index, int(kind) as ResourceKind.Kind, int(kinds[kind]))
		made = true
	return made


## "Choose a token you control; each other token you control becomes a copy of it" (the engine picks its best unit token).
func tokens_become_copy_of_best(player_index: int) -> bool:
	var best: CardInstance = null
	for card: CardInstance in players[player_index].units():
		if card.is_token() and (best == null or card_worth(card) > card_worth(best)):
			best = card
	if best == null:
		return false
	var changed: bool = false
	for card: CardInstance in players[player_index].units():
		if card != best and card.is_token():
			card.data = best.data
			changed = true
	return changed


## Buff: +1/+1 permanently, `amount` times.
func buff_unit(card: CardInstance, amount: int) -> bool:
	if not card.data.is_unit() or amount == 0:
		return false
	card.attack_bonus += amount
	card.defense_bonus += amount
	card.buffs += amount
	emit_event(GameEvent.Type.STATS_CHANGED, card.owner, card.uid, 0, amount, amount)
	return true


func grant_keyword(card: CardInstance, keyword: CardEnums.Keyword, until_end_of_turn: bool) -> void:
	if card.has_keyword(keyword):
		return
	if until_end_of_turn:
		card.temp_keywords.append(keyword)
	else:
		card.granted_keywords.append(keyword)
	emit_event(GameEvent.Type.KEYWORD_GRANTED, card.owner, card.uid, 0, int(keyword))


## Attaches a Tool to a unit (moving it if it was attached elsewhere).
func attach_tool(tool_card: CardInstance, unit: CardInstance) -> bool:
	if not tool_card.data.is_tool() or not unit.data.is_unit() or players[unit.owner].find_field(unit.uid) == null:
		return false
	tool_card.attached_to = unit.uid
	emit_event(GameEvent.Type.UNIT_ATTACHED, tool_card.owner, tool_card.uid, unit.uid)
	return true


## Destroys a permanent: units die (unless Unbreakable), tools and wonders and infrastructure go to the Refuse Pile, a resource is removed.
func destroy_card(card: CardInstance) -> bool:
	if card.data.is_resource():
		return ResourceRules.remove(self, card, false)
	if card.data.is_unit():
		if players[card.owner].find_field(card.uid) == null:
			return false
		if unit_has_keyword(card, CardEnums.Keyword.UNBREAKABLE):
			return false
		destroy_unit(card)
		return true
	return destroy_permanent(card)


## A Tool, Wonder or Infrastructure is destroyed.
func destroy_permanent(card: CardInstance) -> bool:
	var player: PlayerState = players[card.owner]
	var in_field: bool = player.field.has(card)
	var in_infra: bool = player.infrastructure.has(card)
	if not in_field and not in_infra:
		return false
	var controller: int = card.owner
	_remove_from_zones(card)
	limbo.append(card)
	var was_token: bool = card.is_token()
	for other: CardInstance in player.field:
		if other.data.is_tool() and other.attached_to == card.uid:
			other.attached_to = 0
	if not was_token:
		players[card.real_owner].refuse_pile.append(card)
	fire_game_event("destroyed", {"card": card, "player": controller})
	limbo.erase(card)
	if players[card.real_owner].refuse_pile.has(card):
		card.reset()
	return true


## Shred: the card is removed from the game for good (from the field, a Refuse Pile, a hand, a deck...). No death triggers.
func shred_card(card: CardInstance) -> bool:
	if card.data.is_resource():
		return ResourceRules.remove(self, card, true)
	var found: bool = false
	for player: PlayerState in players:
		for zone: Array[CardInstance] in [player.field, player.infrastructure, player.hand, player.refuse_pile, player.deck, player.traps]:
			if zone.has(card):
				found = true
	if not found and not limbo.has(card):
		return false
	if card.data.is_unit():
		_detach_all(card)
	_remove_from_zones(card)
	emit_event(GameEvent.Type.CARD_SHREDDED, card.real_owner, card.uid)
	return true


# ---- Decks ------------------------------------------------------------------------------------------------------------


## Searches your deck for up to `count` cards of a type ("infra", "wonder", "unit"...) and puts them onto the field or into
## your hand; the deck is shuffled afterwards. The engine takes the Paths it needs most.
func search_deck(player_index: int, type_word: String, count: int, destination: String) -> bool:
	var player: PlayerState = players[player_index]
	var matches: Array[CardInstance] = []
	for card: CardInstance in player.deck:
		match type_word:
			"infra":
				if card.data.is_infrastructure():
					matches.append(card)
			"wonder":
				if card.data.is_wonder():
					matches.append(card)
			"tool":
				if card.data.is_tool():
					matches.append(card)
			"unit":
				if card.data.is_unit():
					matches.append(card)
	var need: Dictionary = {}
	for card: CardInstance in player.hand:
		for pip: Affinity.Type in card.data.colored_pips:
			need[int(pip)] = float(need.get(int(pip), 0.0)) + 1.0
	var have: Dictionary = {}
	for infra: CardInstance in player.infrastructure:
		for path: Affinity.Type in infra.data.produced_paths():
			have[int(path)] = int(have.get(int(path), 0)) + 1
	matches.sort_custom(func(a: CardInstance, b: CardInstance) -> bool:
		return _search_score(a, need, have) > _search_score(b, need, have)
	)
	var found: bool = false
	for card: CardInstance in matches:
		if count <= 0:
			break
		player.deck.erase(card)
		count -= 1
		found = true
		if destination == "hand":
			player.hand.append(card)
		else:
			put_onto_field(card, player_index, false)
	RngUtil.shuffle(player.deck, rng)
	return found


func _search_score(card: CardInstance, need: Dictionary, have: Dictionary) -> float:
	var score: float = 0.0
	for path: Affinity.Type in card.data.produced_paths():
		score += float(need.get(int(path), 0.0)) / float(1 + int(have.get(int(path), 0)))
	return score + (0.1 if card.data.produced_paths().size() > 1 else 0.0)


## Puts a card from a deck, hand or Refuse Pile onto the field (a Wonder, Tool, Unit) or among the infrastructure.
func put_onto_field(card: CardInstance, controller: int, remove_from_zones: bool = true) -> bool:
	if remove_from_zones:
		var found: bool = false
		for player: PlayerState in players:
			for zone: Array[CardInstance] in [player.hand, player.deck, player.refuse_pile]:
				if zone.has(card):
					found = true
		if not found:
			return false
		_remove_from_zones(card)
	card.reset()
	card.owner = controller
	if card.data.is_infrastructure():
		card.exhausted = false
		players[controller].infrastructure.append(card)
		emit_event(GameEvent.Type.INFRASTRUCTURE_ENTERED, controller, card.uid)
		_infrastructure_entered(card)
	else:
		_enter_field(card, 0, false)
	return true


## Shuffles `count` copies of a token (a Clause) into a player's deck; `creator` is who benefits when it is drawn.
func shuffle_tokens_into_deck(player_index: int, data: CardData, count: int, creator: int) -> void:
	var player: PlayerState = players[player_index]
	for i: int in range(count):
		var token: CardInstance = create_instance(data, player_index)
		token.creator = creator
		player.deck.insert(rng.randi_range(0, player.deck.size()), token)


func shuffle_refuse_pile_into_deck(player_index: int) -> void:
	var player: PlayerState = players[player_index]
	for card: CardInstance in player.refuse_pile:
		player.deck.append(card)
	player.refuse_pile.clear()
	RngUtil.shuffle(player.deck, rng)



# --------------------------------------------------------------------------------------
# Actions
# --------------------------------------------------------------------------------------


## The actions the awaiting player can take that do not need a combat assignment.
## Combat declarations are built by the AI/UI from possible_attackers()/possible_blockers().
func legal_actions() -> Array[GameAction]:
	var result: Array[GameAction] = []
	var who: int = awaiting_player()
	if who < 0:
		return result
	if stage == Stage.MULLIGAN:
		result.append(GameAction.make(GameAction.Type.KEEP_HAND, who))
		if not players[who].mulligan_used and options.free_mulligan:
			result.append(GameAction.make(GameAction.Type.MULLIGAN, who))
		return result
	var player: PlayerState = players[who]
	if pending_toss > 0:
		for combo: Array[int] in _discard_combinations(player.hand, pending_toss, 40):
			var discard: GameAction = GameAction.make(GameAction.Type.TOSS, who)
			discard.uids = combo
			result.append(discard)
		return result
	result.append(GameAction.pass_phase(who))
	if phase == Phase.COMBAT:
		result.append_array(_combat_actions(who))
		return result
	if not in_main_phase():
		return result
	var seen: Dictionary = {}
	for card: CardInstance in player.hand:
		if card.data.is_infrastructure():
			if can_play_infrastructure(who, card.uid) and not seen.has(card.data.id):
				seen[card.data.id] = true
				result.append(GameAction.play_infrastructure(who, card.uid))
			continue
		if not can_play_card(who, card.uid):
			continue
		for combo: Array[int] in _play_target_combos(who, card):
			var key: String = "%s|%s" % [card.data.id, str(combo)]
			if seen.has(key):
				continue
			seen[key] = true
			var play: GameAction = GameAction.play_card(who, card.uid, combo[0] if not combo.is_empty() else 0)
			play.targets = combo
			result.append(play)
	result.append_array(_activation_actions(who))
	result.append_array(_ability_actions(who))
	result.append_array(_resource_actions(who))
	return result


## Every sensible way to choose the targets of playing `card` (one combination per list; at most MAX_TARGET_COMBOS).
func _play_target_combos(who: int, card: CardInstance) -> Array[Array]:
	var combos: Array[Array] = [[] as Array[int]]
	var ability: CardAbility = play_ability_of(card.data)
	if ability == null:
		var target_effect: EffectData = _primary_target_effect(card.data)
		if target_effect != null:
			var legacy: Array[int] = legal_targets(who, target_effect, card.uid)
			if not legacy.is_empty():
				combos.clear()
				for target: int in legacy:
					combos.append([target] as Array[int])
		return combos
	var ctx: AbilityContext = play_context(who, card, ability)
	for decl: CardAbility.TargetDecl in ability.targets:
		var choices: Array[Array] = []
		if decl.max_count > 1:
			choices.append(TargetResolver.auto_pick(decl.spec, ctx, ability, decl.name, decl.max_count))
		else:
			for ref: int in TargetResolver.legal_targets(decl, ctx):
				choices.append([ref] as Array[int])
			if choices.is_empty():
				choices.append([] as Array[int])
		var grown: Array[Array] = []
		for base: Array in combos:
			for choice: Array in choices:
				var merged: Array[int] = []
				merged.append_array(base)
				merged.append_array(choice)
				grown.append(merged)
				if grown.size() >= MAX_TARGET_COMBOS:
					break
			if grown.size() >= MAX_TARGET_COMBOS:
				break
		combos = grown
	return combos


## One ACTIVATE_ABILITY action per usable activated ability and sensible target / X combination.
func _ability_actions(player_index: int) -> Array[GameAction]:
	var result: Array[GameAction] = []
	var holders: Array[CardInstance] = []
	holders.append_array(players[player_index].field)
	holders.append_array(players[player_index].infrastructure)
	var seen: Dictionary = {}
	for card: CardInstance in holders:
		var abilities: Array[CardAbility] = card.data.abilities()
		for index: int in range(abilities.size()):
			var ability: CardAbility = abilities[index]
			if not ability.is_activated():
				continue
			var x_values: Array[int] = [0]
			var uses_x: bool = false
			for cost: CardAbility.Cost in ability.costs:
				if cost.x_count:
					uses_x = true
			if uses_x:
				x_values = _x_options(player_index, ability)
			var ctx: AbilityContext = AbilityContext.make(self, ability, card, player_index)
			_bind_host(ctx, card, null)
			var combos: Array[Array] = [[] as Array[int]]
			for decl: CardAbility.TargetDecl in ability.targets:
				var choices: Array[Array] = []
				if decl.max_count > 1:
					choices.append(TargetResolver.auto_pick(decl.spec, ctx, ability, decl.name, decl.max_count))
				else:
					for ref: int in TargetResolver.legal_targets(decl, ctx):
						choices.append([ref] as Array[int])
				if choices.is_empty():
					choices.append([] as Array[int])
				var grown: Array[Array] = []
				for base: Array in combos:
					for choice: Array in choices:
						var merged: Array[int] = []
						merged.append_array(base)
						merged.append_array(choice)
						grown.append(merged)
				combos = grown
				if combos.size() > MAX_TARGET_COMBOS:
					combos = combos.slice(0, MAX_TARGET_COMBOS)
			for combo: Array in combos:
				for x: int in x_values:
					var typed: Array[int] = []
					typed.append_array(combo)
					if not can_activate_ability(player_index, card.uid, index, typed, x):
						continue
					var key: String = "%s|%d|%s|%d" % [card.data.id, index, str(typed), x]
					if seen.has(key) and card.data.is_resource():
						continue
					seen[key] = true
					result.append(GameAction.activate_ability(player_index, card.uid, index, typed, x))
	return result


## The X values worth offering for an "use X Ingredients" ability: 1 and the most the player can afford.
func _x_options(player_index: int, ability: CardAbility) -> Array[int]:
	var most: int = 0
	for cost: CardAbility.Cost in ability.costs:
		if cost.x_count and not cost.resource_kinds.is_empty():
			most = maxi(most, players[player_index].count_resource(cost.resource_kinds[0]))
	var result: Array[int] = []
	if most >= 1:
		result.append(1)
	if most > 1:
		result.append(most)
	return result


## Representative combat declarations: all attackers, each attacker alone; each single block.
## (Richer combinations are built by the AI from possible_attackers()/possible_blockers().)
func _combat_actions(player_index: int) -> Array[GameAction]:
	var result: Array[GameAction] = []
	if combat_step == CombatStep.DECLARE_ATTACKERS:
		var available: Array[CardInstance] = possible_attackers(player_index)
		if available.is_empty():
			return result
		var all_action: GameAction = GameAction.make(GameAction.Type.DECLARE_ATTACKERS, player_index)
		for card: CardInstance in available:
			all_action.uids.append(card.uid)
			var single: GameAction = GameAction.make(GameAction.Type.DECLARE_ATTACKERS, player_index)
			single.uids.append(card.uid)
			if available.size() > 1:
				result.append(single)
		result.append(all_action)
	elif combat_step == CombatStep.DECLARE_BLOCKERS:
		for attacker_uid: int in attackers:
			var attacker: CardInstance = find_permanent(attacker_uid)
			if attacker == null:
				continue
			for blocker: CardInstance in possible_blockers(player_index):
				if CombatResolver.can_block(self, attacker, blocker):
					var block: GameAction = GameAction.make(GameAction.Type.DECLARE_BLOCKERS, player_index)
					block.blocks[attacker_uid] = blocker.uid
					result.append(block)
	return result


## One USE_RESOURCE action per (kind, target unit) the player can currently afford.
func _resource_actions(player_index: int) -> Array[GameAction]:
	var result: Array[GameAction] = []
	for kind: ResourceKind.Kind in ResourceKind.all():
		if not ResourceKind.has_use_ability(kind) or players[player_index].count_resource(kind) < 1:
			continue
		for target_uid: int in ResourceRules.use_targets(self, player_index, kind):
			if ResourceRules.can_use_ability(self, player_index, kind, target_uid):
				result.append(GameAction.use_resource(player_index, kind, target_uid))
	return result


func _activation_actions(player_index: int) -> Array[GameAction]:
	var result: Array[GameAction] = []
	for card: CardInstance in players[player_index].field:
		for index: int in range(card.data.effects.size()):
			if not can_activate(player_index, card.uid, index):
				continue
			var effect: EffectData = card.data.effects[index]
			if effect.needs_chosen_target():
				for target: int in legal_targets(player_index, effect, card.uid):
					result.append(GameAction.activate(player_index, card.uid, index, target))
			else:
				result.append(GameAction.activate(player_index, card.uid, index))
	return result


func apply_action(action: GameAction) -> bool:
	match action.type:
		GameAction.Type.PASS:
			return action.player == awaiting_player() and advance_phase()
		GameAction.Type.PLAY_INFRASTRUCTURE:
			return play_infrastructure(action.player, action.card_uid)
		GameAction.Type.PLAY:
			return play_card(action.player, action.card_uid, action.target, [] as Array[int], action.targets.slice(1) if action.targets.size() > 1 else ([] as Array[int]), action.picks)
		GameAction.Type.ACTIVATE:
			return activate(action.player, action.card_uid, action.effect_index, action.target)
		GameAction.Type.ACTIVATE_ABILITY:
			return activate_ability(action.player, action.card_uid, action.effect_index, action.targets, action.x, action.picks)
		GameAction.Type.USE_RESOURCE:
			return use_resource(action.player, action.effect_index as ResourceKind.Kind, action.target)
		GameAction.Type.DECLARE_ATTACKERS:
			return action.player == awaiting_player() and declare_attackers(action.uids)
		GameAction.Type.DECLARE_BLOCKERS:
			return action.player == awaiting_player() and declare_blockers(action.blocks)
		GameAction.Type.TOSS:
			return toss_for_hand_size(action.player, action.uids)
		GameAction.Type.MULLIGAN:
			return mulligan(action.player)
		GameAction.Type.KEEP_HAND:
			return keep_hand(action.player)
	return false


static func _discard_combinations(hand: Array[CardInstance], count: int, cap: int) -> Array[Array]:
	var result: Array[Array] = []
	var current: Array[int] = []
	_collect_combinations(hand, count, 0, current, result, cap)
	return result


static func _collect_combinations(
	hand: Array[CardInstance],
	count: int,
	start: int,
	current: Array[int],
	result: Array[Array],
	cap: int,
) -> void:
	if result.size() >= cap:
		return
	if current.size() == count:
		result.append(current.duplicate())
		return
	for i: int in range(start, hand.size()):
		current.append(hand[i].uid)
		_collect_combinations(hand, count, i + 1, current, result, cap)
		current.pop_back()


# --------------------------------------------------------------------------------------
# Cloning and events
# --------------------------------------------------------------------------------------


## Deep copy for look-ahead. `deep_library` = false shares (read-only) deck cards.
## `hide_traps_of` removes that player's set traps so the AI cannot "see" them.
func clone(deep_deck: bool = true, hide_traps_of: int = -1) -> GameState:
	var copy: GameState = GameState.new(options.clone())
	copy.options.record_events = false
	copy.rng.seed = rng.seed
	copy.rng.state = rng.state
	for player: PlayerState in players:
		copy.players.append(player.clone(deep_deck, player.index != hide_traps_of))
	copy.stage = stage
	copy.phase = phase
	copy.combat_step = combat_step
	copy.turn = turn
	copy.active = active
	copy.first_player = first_player
	copy.winner = winner
	copy.is_draw = is_draw
	copy.pending_toss = pending_toss
	copy.attackers = attackers.duplicate()
	copy.blocks = blocks.duplicate()
	copy.blocked_attackers = blocked_attackers.duplicate()
	copy._next_uid = _next_uid
	copy._mulligan_done = _mulligan_done.duplicate()
	for entry: Dictionary in delayed:
		var copied: Dictionary = entry.duplicate()
		copied["ctx"] = (entry["ctx"] as AbilityContext).snapshot()
		copy.delayed.append(copied)
	for entry: Dictionary in borrowed:
		copy.borrowed.append(entry.duplicate())
	return copy


func create_instance(data: CardData, owner_index: int) -> CardInstance:
	var card: CardInstance = CardInstance.new()
	card.uid = _next_uid
	_next_uid += 1
	card.data = data
	card.owner = owner_index
	card.real_owner = owner_index
	return card


func emit_event(
	type: GameEvent.Type,
	player_index: int = -1,
	card_uid: int = 0,
	other: int = 0,
	amount: int = 0,
	value: int = 0,
	detail: String = "",
) -> void:
	if not options.record_events:
		return
	var event: GameEvent = GameEvent.new()
	event.sequence = _next_sequence
	_next_sequence += 1
	event.type = type
	event.player = player_index
	event.card = card_uid
	event.other = other
	event.amount = amount
	event.value = value
	event.detail = detail
	events.append(event)
	event_emitted.emit(event)


## Brief 8, Part C: resolves every effect of a modifier `kind` that `player_index` has (END_OF_TURN_EFFECT,
## ON_CREATURE_ENTER_EFFECT, ON_ALLY_DEATH_EFFECT), each as an effect controlled by that player.
func _fire_modifier_effects(player_index: int, kind: Modifier.Kind, trigger_uid: int = 0) -> void:
	for effect: EffectData in players[player_index].modifiers.effects_of(kind):
		if is_over():
			return
		EffectResolver.resolve(self, effect, EffectContext.make(0, player_index, trigger_uid))
