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
	for player: PlayerState in players:
		for zone: Array[CardInstance] in [player.field, player.infrastructure, player.hand, player.traps, player.refuse_pile]:
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
	var bonus: Vector2i = players[card.owner].modifiers.stat_bonus_for(card.data)
	return maxi(0, _base_stats(card).x + card.attack_bonus + card.temp_attack + bonus.x)


func get_defense(card: CardInstance) -> int:
	if not card.data.is_unit():
		return 0
	var bonus: Vector2i = players[card.owner].modifiers.stat_bonus_for(card.data)
	var total: int = _base_stats(card).y + card.defense_bonus + card.temp_defense + bonus.y
	# A negative zone effect (a debuff) never kills a unit outright by itself: it leaves at least 1.
	if bonus.y < 0 and _base_stats(card).y >= 1:
		total = maxi(total, 1)
	return total


## A unit's base (attack, defense): its card's, unless a STANDARDIZE_UNITS rule is in force for
## the duel (Primm's Standardization), which gives every unit the same stats.
func _base_stats(card: CardInstance) -> Vector2i:
	for player: PlayerState in players:
		for modifier: Modifier in player.modifiers.modifiers:
			if modifier.kind == Modifier.Kind.STANDARDIZE_UNITS:
				return Vector2i(modifier.value, modifier.value2)
	return Vector2i(card.data.attack, card.data.defense)


## Generic cost after cost-change modifiers (never below 0).
func generic_cost_for(player_index: int, data: CardData) -> int:
	var change: int = players[player_index].modifiers.sum_for_card(Modifier.Kind.COST_CHANGE, data)
	return maxi(0, data.generic_cost + change)


func in_main_phase() -> bool:
	return stage == Stage.PLAYING and (phase == Phase.MAIN1 or phase == Phase.MAIN2) and pending_toss == 0


# --------------------------------------------------------------------------------------
# Playing cards
# --------------------------------------------------------------------------------------


func can_play_infrastructure(player_index: int, uid: int) -> bool:
	if not in_main_phase() or player_index != active:
		return false
	var player: PlayerState = players[player_index]
	if player.infrastructure_played >= INFRASTRUCTURE_DROPS_PER_TURN:
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
	emit_event(GameEvent.Type.INFRASTRUCTURE_PLAYED, player_index, uid, 0, 1, player.infrastructure.size())
	return true


func can_play_card(player_index: int, uid: int) -> bool:
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
	if not PathEnergy.can_pay(player.ready_infrastructure(), generic_cost_for(player_index, card.data), card.data.colored_pips):
		return false
	# Spells that need a chosen target cannot be play without a legal one.
	var target_effect: EffectData = _primary_target_effect(card.data)
	if target_effect != null and card.data.type == CardEnums.CardType.SPELL:
		return not legal_targets(player_index, target_effect, uid).is_empty()
	return true


## Plays a card from hand. `target` is a Targets ref for cards with a chosen-target effect.
## `activate_uids` optionally names the exact infrastructure to activate; otherwise energy is paid automatically.
func play_card(player_index: int, uid: int, target: int = 0, activate_uids: Array[int] = []) -> bool:
	if not can_play_card(player_index, uid):
		return false
	var player: PlayerState = players[player_index]
	var card: CardInstance = player.find_hand(uid)
	var chosen: int = target
	var target_effect: EffectData = _primary_target_effect(card.data)
	if target_effect != null:
		if target != 0 and not legal_targets(player_index, target_effect, uid).has(target):
			return false
	else:
		chosen = 0
	if not _pay(player_index, generic_cost_for(player_index, card.data), card.data.colored_pips, activate_uids, uid):
		return false
	player.hand.erase(card)
	player.non_infrastructure_plays_this_turn += 1
	emit_event(GameEvent.Type.CARD_PLAYED, player_index, uid, chosen, card.data.energy_value())
	match card.data.type:
		CardEnums.CardType.UNIT, CardEnums.CardType.WONDER:
			_enter_field(card, chosen, true)
		CardEnums.CardType.SPELL:
			fire_traps(1 - player_index, CardEnums.Trigger.TRAP_OPPONENT_SPELL, uid)
			if not is_over():
				fire_trigger(card, CardEnums.Trigger.ON_ENTER, 0, chosen)
			_send_to_refuse_pile(card)
		CardEnums.CardType.TRAP:
			card.face_down = true
			player.traps.append(card)
			emit_event(GameEvent.Type.TRAP_SET, player_index, uid, 0, 0, player.traps.size())
	check_state()
	return true


## New brief, Part F: whether `item` could be used right now by `player_index` (their own main
## phase, and a legal target if its effect needs one - the same rule spells follow). Items are
## equipped gear, not cards - no energy cost, no hand/field involvement, so this sits beside
## can_cast/play rather than going through the CAST GameAction.
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


func _pay(player_index: int, generic: int, pips: Array[Affinity.Type], activate_uids: Array[int], for_uid: int) -> bool:
	var player: PlayerState = players[player_index]
	var to_activate: Array[CardInstance] = []
	if activate_uids.is_empty():
		if not PathEnergy.plan(player.ready_infrastructure(), generic, pips, to_activate):
			return false
	else:
		for infrastructure_uid: int in activate_uids:
			var infra: CardInstance = player.find_infrastructure(infrastructure_uid)
			if infra == null or infra.exhausted or to_activate.has(infra):
				return false
			to_activate.append(infra)
		if not PathEnergy.exact_payment_ok(to_activate, generic, pips):
			return false
	for infra: CardInstance in to_activate:
		infra.exhausted = true
		emit_event(GameEvent.Type.ENERGY_SPENT, player_index, infra.uid, for_uid, 1, int(infra.data.color))
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


func _enter_field(card: CardInstance, chosen: int, played_from_hand: bool) -> void:
	var player: PlayerState = players[card.owner]
	player.field.append(card)
	card.summoning_sick = true
	card.exhausted = false
	card.damage = 0
	if card.data.is_unit():
		_apply_static_equipment_grants(card, player)
	emit_event(GameEvent.Type.PERMANENT_ENTERED, card.owner, card.uid, 0, 0, player.field.size())
	if played_from_hand and card.data.is_unit():
		fire_traps(1 - card.owner, CardEnums.Trigger.TRAP_OPPONENT_UNIT, card.uid)
	if not is_over() and player.find_field(card.uid) != null:
		fire_trigger(card, CardEnums.Trigger.ON_ENTER, 0, chosen)
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


func _send_to_refuse_pile(card: CardInstance) -> void:
	card.reset()
	if not card.data.is_token:
		players[card.owner].refuse_pile.append(card)


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
	for infra: CardInstance in player.infrastructure:
		infra.exhausted = false
	for card: CardInstance in player.field:
		card.exhausted = false
		card.summoning_sick = false
		card.activated_this_turn = false
	emit_event(GameEvent.Type.TURN_STARTED, active, 0, 0, turn)
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
	_fire_modifier_effects(active, Modifier.Kind.END_OF_TURN_EFFECT)
	if is_over():
		return
	for player: PlayerState in players:
		for card: CardInstance in player.field:
			var had_damage: int = card.damage
			card.clear_end_of_turn()
			if had_damage > 0:
				emit_event(GameEvent.Type.DAMAGE_CLEARED, player.index, card.uid, 0, had_damage)
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
		player.hand.append(card)
		emit_event(GameEvent.Type.CARD_DRAWN, player_index, card.uid, 0, 1, player.hand.size())


func toss_card(player_index: int, card: CardInstance) -> void:
	var player: PlayerState = players[player_index]
	if not player.hand.has(card):
		return
	player.hand.erase(card)
	player.refuse_pile.append(card)
	emit_event(GameEvent.Type.CARD_TOSSED, player_index, card.uid)


func bury_cards(player_index: int, count: int) -> void:
	var player: PlayerState = players[player_index]
	for i: int in range(count):
		if player.deck.is_empty():
			return
		var card: CardInstance = player.deck.pop_back()
		player.refuse_pile.append(card)
		emit_event(GameEvent.Type.CARD_BURIED, player_index, card.uid, 0, 1, player.deck.size())


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


## HP loss that is not damage (no lifesteal, no damage triggers).
func lose_hp(player_index: int, amount: int) -> void:
	if amount <= 0 or is_over():
		return
	var player: PlayerState = players[player_index]
	player.hp -= amount
	emit_event(GameEvent.Type.HP_CHANGED, player_index, 0, 0, -amount, player.hp)


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
	return amount


## Damage to a unit. Returns the damage dealt. Lethal damage is resolved by check_state().
func deal_damage_to_unit(source_uid: int, target: CardInstance, amount: int) -> int:
	if amount <= 0 or is_over() or not target.data.is_unit():
		return 0
	if players[target.owner].find_field(target.uid) == null:
		return 0
	target.damage += amount
	emit_event(GameEvent.Type.DAMAGE_DEALT, target.owner, source_uid, target.uid, amount, target.damage)
	_apply_nourish(source_uid, amount)
	fire_trigger(target, CardEnums.Trigger.ON_DAMAGE_TAKEN, source_uid, 0)
	return amount


func _apply_nourish(source_uid: int, amount: int) -> void:
	if source_uid <= 0:
		return
	var source: CardInstance = find_permanent(source_uid)
	if source != null and source.has_keyword(CardEnums.Keyword.NOURISH):
		gain_hp(source.owner, amount)


## Removes a unit from the field (death), then fires its death triggers.
func destroy_unit(card: CardInstance) -> void:
	var player: PlayerState = players[card.owner]
	if player.find_field(card.uid) == null:
		return
	player.field.erase(card)
	_clear_combat_refs(card.uid)
	emit_event(GameEvent.Type.UNIT_DIED, card.owner, card.uid)
	# Death triggers use the card as it was; reset only after they resolve.
	fire_trigger(card, CardEnums.Trigger.ON_DEATH, 0, 0)
	if card.data.is_unit() and not is_over():
		_fire_modifier_effects(card.owner, Modifier.Kind.ON_ALLY_DEATH_EFFECT)
	_send_to_refuse_pile(card)
	_maybe_return_from_refuse_pile(card)


## Brief 10 (Restless Dead): a dead unit may climb out of the graveyard again (GRAVEYARD_RETURN_CHANCE percent).
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
## an empty deck) lose. Repeats until stable.
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
				if defense <= 0 or card.damage >= defense:
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


func create_token(player_index: int, data: CardData) -> CardInstance:
	var token: CardInstance = create_instance(data, player_index)
	emit_event(GameEvent.Type.TOKEN_CREATED, player_index, token.uid)
	_enter_field(token, 0, false)
	return token


## Bounces a permanent to its owner's hand (tokens simply vanish).
func send_back(card: CardInstance) -> void:
	var player: PlayerState = players[card.owner]
	if player.find_field(card.uid) == null:
		return
	player.field.erase(card)
	_clear_combat_refs(card.uid)
	card.reset()
	if card.data.is_token:
		return
	player.hand.append(card)
	emit_event(GameEvent.Type.CARD_SENT_BACK, card.owner, card.uid)


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
		var target_effect: EffectData = _primary_target_effect(card.data)
		var targets: Array[int] = [0]
		if target_effect != null:
			targets = legal_targets(who, target_effect, card.uid)
			if targets.is_empty():
				targets = [0]
		for target: int in targets:
			var key: String = "%s|%d" % [card.data.id, target]
			if seen.has(key):
				continue
			seen[key] = true
			result.append(GameAction.play_card(who, card.uid, target))
	result.append_array(_activation_actions(who))
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
				if CombatResolver.can_block(attacker, blocker):
					var block: GameAction = GameAction.make(GameAction.Type.DECLARE_BLOCKERS, player_index)
					block.blocks[attacker_uid] = blocker.uid
					result.append(block)
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
			return play_card(action.player, action.card_uid, action.target)
		GameAction.Type.ACTIVATE:
			return activate(action.player, action.card_uid, action.effect_index, action.target)
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
	return copy


func create_instance(data: CardData, owner_index: int) -> CardInstance:
	var card: CardInstance = CardInstance.new()
	card.uid = _next_uid
	_next_uid += 1
	card.data = data
	card.owner = owner_index
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
