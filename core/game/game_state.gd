class_name GameState
extends RefCounted
## Complete state and rules for one two-player duel. Pure logic: no Nodes, no scene tree.
## Every state change is appended to `events` (and emitted) so a UI can animate from it.
## See docs/design/combat_rules.md for the rules this implements.

signal event_emitted(event: GameEvent)

enum Phase { START, MAIN1, COMBAT, MAIN2, END }
enum Stage { SETUP, MULLIGAN, PLAYING, OVER }
enum CombatStep { NONE, DECLARE_ATTACKERS, DECLARE_BLOCKERS }

const LAND_DROPS_PER_TURN: int = 1

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
var pending_discard: int = 0
## Current combat: attacker uids, attacker -> attacked Guard uid (absent = the player),
## attacker -> blocker, and the attackers that were blocked (even if the blocker later died).
var attackers: Array[int] = []
var attack_targets: Dictionary = {}
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
	player.max_life = maxi(1, profile.base_max_life() + mods.sum(Modifier.Kind.MAX_LIFE))
	if setup.starting_life >= 0:
		player.life = setup.starting_life
	else:
		player.life = maxi(1, player.max_life + mods.sum(Modifier.Kind.STARTING_LIFE))
	player.max_hand_size = maxi(1, profile.base_max_hand_size() + mods.sum(Modifier.Kind.MAX_HAND_SIZE))
	player.opening_hand_size = maxi(1, profile.base_opening_hand() + mods.sum(Modifier.Kind.OPENING_HAND_SIZE))
	for data: CardData in setup.deck.cards:
		player.library.append(create_instance(data, player.index))
	if setup.deck.size() > 0:
		player.deck_land_ratio = float(setup.deck.land_count()) / float(setup.deck.size())
	players.append(player)
	return player


## Shuffles, deals opening hands and enters the mulligan stage. Call after adding both players.
func start() -> void:
	assert(players.size() == 2, "GameState needs exactly two players")
	if options.rng_seed != 0:
		rng.seed = options.rng_seed
	else:
		rng.randomize()
	first_player = options.first_player if options.first_player >= 0 else rng.randi_range(0, 1)
	active = first_player
	for player: PlayerState in players:
		RngUtil.shuffle(player.library, rng)
	emit_event(GameEvent.Type.GAME_STARTED, first_player)
	for player: PlayerState in players:
		_deal_opening_hand(player)
	stage = Stage.MULLIGAN
	if not options.free_mulligan:
		_mulligan_done = [true, true]
		_begin_playing()


func _deal_opening_hand(player: PlayerState) -> void:
	var hand: Array[CardInstance] = HandSmoother.draw_opening_hand(
		player.library, player.opening_hand_size, player.deck_land_ratio, options.hand_smoother, rng, options.smoother_tolerance
	)
	for card: CardInstance in hand:
		player.hand.append(card)
		emit_event(GameEvent.Type.CARD_DRAWN, player.index, card.uid, 0, 1, player.hand.size(), "opening")
	if options.hand_smoother:
		emit_event(GameEvent.Type.HAND_SMOOTHED, player.index, 0, 0, HandSmoother.count_lands(hand))


## Takes the one free mulligan: hand is shuffled back and the same number of cards drawn.
func mulligan(player_index: int) -> bool:
	if stage != Stage.MULLIGAN or awaiting_player() != player_index:
		return false
	var player: PlayerState = players[player_index]
	if player.mulligan_used or not options.free_mulligan:
		return false
	player.mulligan_used = true
	for card: CardInstance in player.hand:
		player.library.append(card)
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
			if pending_discard > 0:
				return active
			if phase == Phase.COMBAT and combat_step == CombatStep.DECLARE_BLOCKERS:
				return 1 - active
			return active
	return -1


static func opponent_of(player_index: int) -> int:
	return 1 - player_index


func find_card(uid: int) -> CardInstance:
	for player: PlayerState in players:
		for zone: Array[CardInstance] in [player.battlefield, player.lands, player.hand, player.traps, player.graveyard]:
			var card: CardInstance = PlayerState.find_in(zone, uid)
			if card != null:
				return card
	return null


## Finds a creature/artifact currently on a battlefield.
func find_permanent(uid: int) -> CardInstance:
	for player: PlayerState in players:
		var card: CardInstance = player.find_battlefield(uid)
		if card != null:
			return card
	return null


func all_creatures() -> Array[CardInstance]:
	var result: Array[CardInstance] = []
	for player: PlayerState in players:
		result.append_array(player.creatures())
	return result


func get_power(card: CardInstance) -> int:
	if not card.data.is_creature():
		return 0
	var bonus: Vector2i = players[card.owner].modifiers.stat_bonus(card.data.color)
	return maxi(0, card.data.power + card.power_bonus + card.temp_power + bonus.x)


func get_toughness(card: CardInstance) -> int:
	if not card.data.is_creature():
		return 0
	var bonus: Vector2i = players[card.owner].modifiers.stat_bonus(card.data.color)
	return card.data.toughness + card.toughness_bonus + card.temp_toughness + bonus.y


## Generic cost after cost-change modifiers (never below 0).
func generic_cost_for(player_index: int, data: CardData) -> int:
	var change: int = players[player_index].modifiers.sum_for_color(Modifier.Kind.COST_CHANGE, data.color)
	return maxi(0, data.generic_cost + change)


func in_main_phase() -> bool:
	return stage == Stage.PLAYING and (phase == Phase.MAIN1 or phase == Phase.MAIN2) and pending_discard == 0


# --------------------------------------------------------------------------------------
# Playing cards
# --------------------------------------------------------------------------------------


func can_play_land(player_index: int, uid: int) -> bool:
	if not in_main_phase() or player_index != active:
		return false
	var player: PlayerState = players[player_index]
	if player.lands_played >= LAND_DROPS_PER_TURN:
		return false
	var card: CardInstance = player.find_hand(uid)
	return card != null and card.data.is_land()


func play_land(player_index: int, uid: int) -> bool:
	if not can_play_land(player_index, uid):
		return false
	var player: PlayerState = players[player_index]
	var card: CardInstance = player.find_hand(uid)
	player.hand.erase(card)
	player.lands.append(card)
	card.tapped = false
	player.lands_played += 1
	emit_event(GameEvent.Type.LAND_PLAYED, player_index, uid, 0, 1, player.lands.size())
	return true


func can_cast(player_index: int, uid: int) -> bool:
	if not in_main_phase() or player_index != active:
		return false
	var player: PlayerState = players[player_index]
	var card: CardInstance = player.find_hand(uid)
	if card == null or card.data.is_land():
		return false
	if not Mana.can_pay(player.untapped_lands(), generic_cost_for(player_index, card.data), card.data.colored_pips):
		return false
	# Spells that need a chosen target cannot be cast without a legal one.
	var target_effect: EffectData = _primary_target_effect(card.data)
	if target_effect != null and card.data.type == CardEnums.CardType.SPELL:
		return not legal_targets(player_index, target_effect, uid).is_empty()
	return true


## Casts a card from hand. `target` is a Targets ref for cards with a chosen-target effect.
## `tap_uids` optionally names the exact lands to tap; otherwise mana is paid automatically.
func cast(player_index: int, uid: int, target: int = 0, tap_uids: Array[int] = []) -> bool:
	if not can_cast(player_index, uid):
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
	if not _pay(player_index, generic_cost_for(player_index, card.data), card.data.colored_pips, tap_uids, uid):
		return false
	player.hand.erase(card)
	emit_event(GameEvent.Type.CARD_CAST, player_index, uid, chosen, card.data.mana_value())
	match card.data.type:
		CardEnums.CardType.CREATURE, CardEnums.CardType.ARTIFACT:
			_enter_battlefield(card, chosen, true)
		CardEnums.CardType.SPELL:
			fire_traps(1 - player_index, CardEnums.Trigger.TRAP_OPPONENT_SPELL, uid)
			if not is_over():
				fire_trigger(card, CardEnums.Trigger.ON_ENTER, 0, chosen)
			_send_to_graveyard(card)
		CardEnums.CardType.TRAP:
			card.face_down = true
			player.traps.append(card)
			emit_event(GameEvent.Type.TRAP_SET, player_index, uid, 0, 0, player.traps.size())
	check_state()
	return true


func _pay(player_index: int, generic: int, pips: Array[Affinity.Type], tap_uids: Array[int], for_uid: int) -> bool:
	var player: PlayerState = players[player_index]
	var to_tap: Array[CardInstance] = []
	if tap_uids.is_empty():
		if not Mana.plan(player.untapped_lands(), generic, pips, to_tap):
			return false
	else:
		for land_uid: int in tap_uids:
			var land: CardInstance = player.find_land(land_uid)
			if land == null or land.tapped or to_tap.has(land):
				return false
			to_tap.append(land)
		if not Mana.exact_payment_ok(to_tap, generic, pips):
			return false
	for land: CardInstance in to_tap:
		land.tapped = true
		emit_event(GameEvent.Type.MANA_SPENT, player_index, land.uid, for_uid, 1, int(land.data.color))
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


func _enter_battlefield(card: CardInstance, chosen: int, cast_from_hand: bool) -> void:
	var player: PlayerState = players[card.owner]
	player.battlefield.append(card)
	card.summoning_sick = true
	card.tapped = false
	card.damage = 0
	emit_event(GameEvent.Type.PERMANENT_ENTERED, card.owner, card.uid, 0, 0, player.battlefield.size())
	if cast_from_hand and card.data.is_creature():
		fire_traps(1 - card.owner, CardEnums.Trigger.TRAP_OPPONENT_CREATURE, card.uid)
	if not is_over() and player.find_battlefield(card.uid) != null:
		fire_trigger(card, CardEnums.Trigger.ON_ENTER, 0, chosen)


func _send_to_graveyard(card: CardInstance) -> void:
	card.reset()
	if not card.data.is_token:
		players[card.owner].graveyard.append(card)


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
	pending_discard = 0
	var player: PlayerState = players[active]
	player.lands_played = 0
	for land: CardInstance in player.lands:
		land.tapped = false
	for card: CardInstance in player.battlefield:
		card.tapped = false
		card.summoning_sick = false
		card.activated_this_turn = false
	emit_event(GameEvent.Type.TURN_STARTED, active, 0, 0, turn)
	# The first player skips their first draw.
	if turn > 1:
		draw_cards(active, 1 + maxi(0, player.modifiers.sum(Modifier.Kind.EXTRA_DRAWS)))
	if is_over():
		return
	_fire_turn_triggers(active, CardEnums.Trigger.START_OF_TURN)
	if is_over():
		return
	_set_phase(Phase.MAIN1)


func _set_phase(new_phase: Phase) -> void:
	phase = new_phase
	emit_event(GameEvent.Type.PHASE_CHANGED, active, 0, 0, int(new_phase))


## Moves to the next phase (or, in combat, declares no attackers / no blockers).
func advance_phase() -> bool:
	if stage != Stage.PLAYING or pending_discard > 0:
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
	attack_targets.clear()
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


## Attacking player declares attackers. `guard_targets` maps attacker uid -> Guard uid.
func declare_attackers(uids: Array[int], guard_targets: Dictionary = {}) -> bool:
	return CombatResolver.declare_attackers(self, uids, guard_targets)


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
	attack_targets.clear()
	blocks.clear()
	blocked_attackers.clear()
	combat_step = CombatStep.NONE
	_set_phase(Phase.MAIN2)


func _end_phase() -> void:
	_set_phase(Phase.END)
	_fire_turn_triggers(active, CardEnums.Trigger.END_OF_TURN)
	if is_over():
		return
	for player: PlayerState in players:
		for card: CardInstance in player.battlefield:
			var had_damage: int = card.damage
			card.clear_end_of_turn()
			if had_damage > 0:
				emit_event(GameEvent.Type.DAMAGE_CLEARED, player.index, card.uid, 0, had_damage)
	var excess: int = players[active].hand.size() - players[active].max_hand_size
	if excess > 0:
		pending_discard = excess
		return
	_finish_turn()


## Discards down to the hand size limit at the end of the turn.
func discard_for_hand_size(player_index: int, uids: Array[int]) -> bool:
	if stage != Stage.PLAYING or pending_discard <= 0 or player_index != active:
		return false
	if uids.size() != pending_discard:
		return false
	var player: PlayerState = players[player_index]
	var chosen: Array[CardInstance] = []
	for uid: int in uids:
		var card: CardInstance = player.find_hand(uid)
		if card == null or chosen.has(card):
			return false
		chosen.append(card)
	for card: CardInstance in chosen:
		discard_card(player_index, card)
	pending_discard = 0
	_finish_turn()
	return true


func _finish_turn() -> void:
	active = 1 - active
	_begin_turn()


# --------------------------------------------------------------------------------------
# Zone and life primitives (also used by the effect system)
# --------------------------------------------------------------------------------------


func draw_cards(player_index: int, count: int) -> void:
	var player: PlayerState = players[player_index]
	for i: int in range(count):
		if is_over():
			return
		if player.library.is_empty():
			# Drawing from an empty deck loses the game.
			player.lost = true
			emit_event(GameEvent.Type.PLAYER_LOST, player_index, 0, 0, 0, 0, "deck_out")
			check_state()
			return
		var card: CardInstance = player.library.pop_back()
		player.hand.append(card)
		emit_event(GameEvent.Type.CARD_DRAWN, player_index, card.uid, 0, 1, player.hand.size())


func discard_card(player_index: int, card: CardInstance) -> void:
	var player: PlayerState = players[player_index]
	if not player.hand.has(card):
		return
	player.hand.erase(card)
	player.graveyard.append(card)
	emit_event(GameEvent.Type.CARD_DISCARDED, player_index, card.uid)


func mill_cards(player_index: int, count: int) -> void:
	var player: PlayerState = players[player_index]
	for i: int in range(count):
		if player.library.is_empty():
			return
		var card: CardInstance = player.library.pop_back()
		player.graveyard.append(card)
		emit_event(GameEvent.Type.CARD_MILLED, player_index, card.uid, 0, 1, player.library.size())


## Raises life, never above max life (a higher starting life is left alone).
func gain_life(player_index: int, amount: int) -> void:
	if amount <= 0 or is_over():
		return
	var player: PlayerState = players[player_index]
	var new_life: int = maxi(player.life, mini(player.life + amount, player.max_life))
	var delta: int = new_life - player.life
	if delta > 0:
		player.life = new_life
		emit_event(GameEvent.Type.LIFE_CHANGED, player_index, 0, 0, delta, new_life)


## Life loss that is not damage (no lifesteal, no damage triggers).
func lose_life(player_index: int, amount: int) -> void:
	if amount <= 0 or is_over():
		return
	var player: PlayerState = players[player_index]
	player.life -= amount
	emit_event(GameEvent.Type.LIFE_CHANGED, player_index, 0, 0, -amount, player.life)


## Damage to a player. Returns the damage dealt.
func deal_damage_to_player(source_uid: int, player_index: int, amount: int) -> int:
	if amount <= 0 or is_over():
		return 0
	var player: PlayerState = players[player_index]
	player.life -= amount
	emit_event(GameEvent.Type.DAMAGE_DEALT, player_index, source_uid, Targets.player(player_index), amount, player.life)
	emit_event(GameEvent.Type.LIFE_CHANGED, player_index, 0, 0, -amount, player.life)
	_apply_lifesteal(source_uid, amount)
	fire_traps(player_index, CardEnums.Trigger.TRAP_PLAYER_DAMAGED, source_uid)
	return amount


## Damage to a creature. Returns the damage dealt. Lethal damage is resolved by check_state().
func deal_damage_to_creature(source_uid: int, target: CardInstance, amount: int) -> int:
	if amount <= 0 or is_over() or not target.data.is_creature():
		return 0
	if players[target.owner].find_battlefield(target.uid) == null:
		return 0
	target.damage += amount
	emit_event(GameEvent.Type.DAMAGE_DEALT, target.owner, source_uid, target.uid, amount, target.damage)
	_apply_lifesteal(source_uid, amount)
	fire_trigger(target, CardEnums.Trigger.ON_DAMAGE_TAKEN, source_uid, 0)
	return amount


func _apply_lifesteal(source_uid: int, amount: int) -> void:
	if source_uid <= 0:
		return
	var source: CardInstance = find_permanent(source_uid)
	if source != null and source.has_keyword(CardEnums.Keyword.LIFESTEAL):
		gain_life(source.owner, amount)


## Removes a creature from the battlefield (death), then fires its death triggers.
func kill_creature(card: CardInstance) -> void:
	var player: PlayerState = players[card.owner]
	if player.find_battlefield(card.uid) == null:
		return
	player.battlefield.erase(card)
	_clear_combat_refs(card.uid)
	emit_event(GameEvent.Type.CREATURE_DIED, card.owner, card.uid)
	# Death triggers use the card as it was; reset only after they resolve.
	fire_trigger(card, CardEnums.Trigger.ON_DEATH, 0, 0)
	_send_to_graveyard(card)


func _clear_combat_refs(uid: int) -> void:
	attackers.erase(uid)
	attack_targets.erase(uid)
	blocked_attackers.erase(uid)
	blocks.erase(uid)
	for attacker_uid: Variant in blocks.keys():
		if int(blocks[attacker_uid]) == uid:
			blocks.erase(attacker_uid)


## State-based checks: dead creatures leave play, players at 0 life (or who tried to draw from
## an empty deck) lose. Repeats until stable.
func check_state() -> void:
	for pass_index: int in range(50):
		if is_over():
			return
		var dying: Array[CardInstance] = []
		for player: PlayerState in players:
			for card: CardInstance in player.battlefield:
				if not card.data.is_creature():
					continue
				var toughness: int = get_toughness(card)
				if toughness <= 0 or card.damage >= toughness:
					dying.append(card)
		if dying.is_empty():
			break
		for card: CardInstance in dying:
			kill_creature(card)
	_resolve_losses()


func _resolve_losses() -> void:
	if is_over():
		return
	var losers: Array[int] = []
	for player: PlayerState in players:
		if player.lost or player.life <= 0:
			losers.append(player.index)
	if losers.is_empty():
		return
	for loser: int in losers:
		emit_event(GameEvent.Type.PLAYER_LOST, loser, 0, 0, 0, players[loser].life, "life" if not players[loser].lost else "deck_out")
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
	for card: CardInstance in players[player_index].battlefield.duplicate():
		if is_over():
			return
		if players[player_index].find_battlefield(card.uid) != null:
			fire_trigger(card, trigger, 0, 0)
	check_state()


## Fires the active player's START_OF_COMBAT_EFFECT modifiers (equipment, items, zones...).
func _fire_start_of_combat(player_index: int) -> void:
	for effect: EffectData in players[player_index].modifiers.effects_of(Modifier.Kind.START_OF_COMBAT_EFFECT):
		if is_over():
			return
		EffectResolver.resolve(self, effect, EffectContext.make(0, player_index))
	check_state()


func can_activate(player_index: int, uid: int, effect_index: int) -> bool:
	if not in_main_phase() or player_index != active:
		return false
	var player: PlayerState = players[player_index]
	var card: CardInstance = player.find_battlefield(uid)
	if card == null or card.activated_this_turn:
		return false
	if effect_index < 0 or effect_index >= card.data.effects.size():
		return false
	var effect: EffectData = card.data.effects[effect_index]
	if effect.trigger != CardEnums.Trigger.ACTIVATED:
		return false
	if not Mana.can_pay(player.untapped_lands(), effect.activation_cost, [] as Array[Affinity.Type]):
		return false
	if effect.needs_chosen_target():
		return not legal_targets(player_index, effect, uid).is_empty()
	return true


## Uses an ACTIVATED effect: pays its generic cost, once per turn per permanent.
func activate(player_index: int, uid: int, effect_index: int, target: int = 0) -> bool:
	if not can_activate(player_index, uid, effect_index):
		return false
	var card: CardInstance = players[player_index].find_battlefield(uid)
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
	_enter_battlefield(token, 0, false)
	return token


## Bounces a permanent to its owner's hand (tokens simply vanish).
func return_to_hand(card: CardInstance) -> void:
	var player: PlayerState = players[card.owner]
	if player.find_battlefield(card.uid) == null:
		return
	player.battlefield.erase(card)
	_clear_combat_refs(card.uid)
	card.reset()
	if card.data.is_token:
		return
	player.hand.append(card)
	emit_event(GameEvent.Type.CARD_RETURNED_TO_HAND, card.owner, card.uid)


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
	if pending_discard > 0:
		for combo: Array[int] in _discard_combinations(player.hand, pending_discard, 40):
			var discard: GameAction = GameAction.make(GameAction.Type.DISCARD, who)
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
		if card.data.is_land():
			if can_play_land(who, card.uid) and not seen.has(card.data.id):
				seen[card.data.id] = true
				result.append(GameAction.play_land(who, card.uid))
			continue
		if not can_cast(who, card.uid):
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
			result.append(GameAction.cast(who, card.uid, target))
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
	for card: CardInstance in players[player_index].battlefield:
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
		GameAction.Type.PLAY_LAND:
			return play_land(action.player, action.card_uid)
		GameAction.Type.CAST:
			return cast(action.player, action.card_uid, action.target)
		GameAction.Type.ACTIVATE:
			return activate(action.player, action.card_uid, action.effect_index, action.target)
		GameAction.Type.DECLARE_ATTACKERS:
			return action.player == awaiting_player() and declare_attackers(action.uids, action.attack_targets)
		GameAction.Type.DECLARE_BLOCKERS:
			return action.player == awaiting_player() and declare_blockers(action.blocks)
		GameAction.Type.DISCARD:
			return discard_for_hand_size(action.player, action.uids)
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


## Deep copy for look-ahead. `deep_library` = false shares (read-only) library cards.
## `hide_traps_of` removes that player's set traps so the AI cannot "see" them.
func clone(deep_library: bool = true, hide_traps_of: int = -1) -> GameState:
	var copy: GameState = GameState.new(options.clone())
	copy.options.record_events = false
	copy.rng.seed = rng.seed
	copy.rng.state = rng.state
	for player: PlayerState in players:
		copy.players.append(player.clone(deep_library, player.index != hide_traps_of))
	copy.stage = stage
	copy.phase = phase
	copy.combat_step = combat_step
	copy.turn = turn
	copy.active = active
	copy.first_player = first_player
	copy.winner = winner
	copy.is_draw = is_draw
	copy.pending_discard = pending_discard
	copy.attackers = attackers.duplicate()
	copy.attack_targets = attack_targets.duplicate()
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
