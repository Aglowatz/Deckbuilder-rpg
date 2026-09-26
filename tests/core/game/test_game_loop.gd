extends GutTest


# ---- Setup -------------------------------------------------------------------------


func test_new_game_deals_opening_hands_and_full_life() -> void:
	var game: GameState = GameFactory.new_game()
	assert_eq(game.stage, GameState.Stage.PLAYING)
	assert_eq(game.players[0].life, 10)
	assert_eq(game.players[1].life, 10)
	assert_eq(game.players[0].hand.size(), 5)
	assert_eq(game.players[1].hand.size(), 5)
	assert_eq(game.players[0].library.size(), 40)
	assert_eq(game.turn, 1)
	assert_eq(game.active, 0)
	assert_eq(game.phase, GameState.Phase.MAIN1)


func test_first_player_skips_first_draw_second_player_draws() -> void:
	var game: GameState = GameFactory.new_game()
	assert_eq(game.players[0].hand.size(), 5, "first player does not draw on turn 1")
	GameFactory.pass_turn(game)
	assert_eq(game.active, 1)
	assert_eq(game.players[1].hand.size(), 6, "second player draws on their first turn")
	GameFactory.pass_turn(game)
	assert_eq(game.players[0].hand.size(), 6)


func test_same_seed_gives_same_opening_hands() -> void:
	var a: GameState = GameFactory.new_game(42)
	var b: GameState = GameFactory.new_game(42)
	var uids_a: Array[int] = []
	var uids_b: Array[int] = []
	for card: CardInstance in a.players[0].hand:
		uids_a.append(card.uid)
	for card: CardInstance in b.players[0].hand:
		uids_b.append(card.uid)
	assert_eq(uids_a, uids_b)


func test_first_player_option_and_random() -> void:
	var opts: GameOptions = GameOptions.new()
	opts.first_player = 1
	var game: GameState = GameFactory.new_game(1, null, null, opts)
	assert_eq(game.active, 1)
	var seen: Dictionary = {}
	for seed_value: int in range(1, 30):
		var random_opts: GameOptions = GameOptions.new()
		random_opts.first_player = -1
		seen[GameFactory.new_game(seed_value, null, null, random_opts).active] = true
	assert_eq(seen.size(), 2, "random first player picks both seats over many seeds")


func test_opening_hand_uses_profile_and_modifiers() -> void:
	var profile: PlayerProfile = PlayerProfile.new()
	profile.opening_hand_size = 7
	profile.max_life = 25
	var boost: ModifierSource = CardBuilder.modifier_source(
		"Ring", ModifierSource.SourceKind.EQUIPMENT,
		[
			CardBuilder.modifier(Modifier.Kind.OPENING_HAND_SIZE, 1),
			CardBuilder.modifier(Modifier.Kind.MAX_LIFE, 3),
			CardBuilder.modifier(Modifier.Kind.MAX_HAND_SIZE, 2),
		] as Array[Modifier],
	)
	var game: GameState = GameState.new()
	game.options.rng_seed = 3
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), profile, [boost] as Array[ModifierSource]))
	game.add_player(PlayerSetup.create(GameFactory.make_deck()))
	game.start()
	assert_eq(game.players[0].hand.size(), 8)
	assert_eq(game.players[0].max_life, 28)
	assert_eq(game.players[0].life, 28)
	assert_eq(game.players[0].max_hand_size, 12)
	assert_eq(game.players[1].hand.size(), 5)


func test_starting_life_override_and_modifier() -> void:
	var game: GameState = GameState.new()
	var setup: PlayerSetup = PlayerSetup.create(GameFactory.make_deck())
	setup.starting_life = 4
	game.add_player(setup)
	var second: PlayerSetup = PlayerSetup.create(GameFactory.make_deck())
	second.modifiers.add(CardBuilder.modifier(Modifier.Kind.STARTING_LIFE, 2))
	game.add_player(second)
	assert_eq(game.players[0].life, 4)
	assert_eq(game.players[1].life, 12)
	assert_eq(game.players[1].max_life, 10)


# ---- Events ------------------------------------------------------------------------


func test_events_are_logged_in_order_and_signalled() -> void:
	var game: GameState = GameState.new()
	game.options.rng_seed = 5
	watch_signals(game)
	game.add_player(PlayerSetup.create(GameFactory.make_deck()))
	game.add_player(PlayerSetup.create(GameFactory.make_deck()))
	game.start()
	game.keep_hand(0)
	game.keep_hand(1)
	assert_signal_emitted(game, "event_emitted")
	assert_eq(game.events[0].type, GameEvent.Type.GAME_STARTED)
	var seq: int = -1
	for event: GameEvent in game.events:
		assert_gt(event.sequence, seq)
		seq = event.sequence
	assert_gt(GameFactory.count_events(game, GameEvent.Type.CARD_DRAWN), 9)
	assert_eq(GameFactory.count_events(game, GameEvent.Type.TURN_STARTED), 1)
	assert_eq(GameFactory.count_events(game, GameEvent.Type.HAND_KEPT), 2)
	assert_eq(GameFactory.count_events(game, GameEvent.Type.HAND_SMOOTHED), 2)


func test_events_can_be_disabled() -> void:
	var opts: GameOptions = GameOptions.new()
	opts.record_events = false
	var game: GameState = GameFactory.new_game(1, null, null, opts)
	assert_eq(game.events.size(), 0)


# ---- Mulligan ----------------------------------------------------------------------


func test_one_free_mulligan_per_player() -> void:
	var game: GameState = GameState.new()
	game.options.rng_seed = 9
	game.add_player(PlayerSetup.create(GameFactory.make_deck()))
	game.add_player(PlayerSetup.create(GameFactory.make_deck()))
	game.start()
	assert_eq(game.stage, GameState.Stage.MULLIGAN)
	assert_eq(game.awaiting_player(), 0)
	assert_false(game.mulligan(1), "not their turn to decide yet")
	assert_true(game.mulligan(0))
	assert_eq(game.players[0].hand.size(), 5, "free mulligan: same number of cards")
	assert_eq(game.players[0].library.size(), 40)
	assert_false(game.mulligan(0), "only one mulligan")
	assert_eq(game.awaiting_player(), 1)
	assert_true(game.keep_hand(1))
	assert_eq(game.stage, GameState.Stage.PLAYING)
	assert_eq(GameFactory.count_events(game, GameEvent.Type.MULLIGAN_TAKEN), 1)


func test_free_mulligan_can_be_disabled() -> void:
	var opts: GameOptions = GameOptions.new()
	opts.free_mulligan = false
	var game: GameState = GameFactory.new_game(1, null, null, opts)
	assert_eq(game.stage, GameState.Stage.PLAYING)
	assert_false(game.mulligan(0))


func test_mulligan_legal_actions() -> void:
	var game: GameState = GameState.new()
	game.options.rng_seed = 2
	game.add_player(PlayerSetup.create(GameFactory.make_deck()))
	game.add_player(PlayerSetup.create(GameFactory.make_deck()))
	game.start()
	var types: Array[GameAction.Type] = []
	for action: GameAction in game.legal_actions():
		types.append(action.type)
	assert_true(types.has(GameAction.Type.KEEP_HAND))
	assert_true(types.has(GameAction.Type.MULLIGAN))


# ---- Hand smoother -----------------------------------------------------------------


func test_smoother_pick_closest_prefers_nearer_land_count() -> void:
	var game: GameState = GameFactory.blank_game()
	var lands: Array[CardInstance] = []
	var spells: Array[CardInstance] = []
	for i: int in range(7):
		lands.append(game.create_instance(GameFactory.land(), 0))
		spells.append(game.create_instance(GameFactory.vanilla(1, 1), 0))
	var hand_a: Array[CardInstance] = [lands[0], lands[1], lands[2], lands[3], lands[4], lands[5], lands[6]]
	var hand_b: Array[CardInstance] = [lands[0], lands[1], lands[2], spells[3], spells[4], spells[5], spells[6]]
	assert_eq(HandSmoother.pick_closest(hand_a, hand_b, 3.0), hand_b)
	assert_eq(HandSmoother.pick_closest(hand_a, hand_b, 6.0), hand_a)
	assert_eq(HandSmoother.pick_closest(hand_a, hand_b, 5.0), hand_a, "ties keep the first hand")


func test_smoother_reduces_land_count_error_on_average() -> void:
	var total_smoothed: float = 0.0
	var total_plain: float = 0.0
	var deck: Deck = GameFactory.make_deck(null, 18, 45)
	var ratio: float = 18.0 / 45.0
	for seed_value: int in range(1, 201):
		total_smoothed += _land_error(deck, ratio, true, seed_value)
		total_plain += _land_error(deck, ratio, false, seed_value)
	assert_lt(total_smoothed, total_plain, "smoothed hands are closer to the deck's land ratio")


func _land_error(deck: Deck, ratio: float, smoother: bool, seed_value: int) -> float:
	var game: GameState = GameState.new()
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_value
	var library: Array[CardInstance] = []
	for data: CardData in deck.cards:
		library.append(game.create_instance(data, 0))
	var hand: Array[CardInstance] = HandSmoother.draw_opening_hand(library, 7, ratio, smoother, rng)
	assert_eq(hand.size(), 7)
	assert_eq(library.size(), 38)
	return absf(float(HandSmoother.count_lands(hand)) - ratio * 7.0)


func test_smoother_can_be_turned_off() -> void:
	var opts: GameOptions = GameOptions.new()
	opts.hand_smoother = false
	var game: GameState = GameFactory.new_game(1, null, null, opts)
	assert_eq(GameFactory.count_events(game, GameEvent.Type.HAND_SMOOTHED), 0)


# ---- Lands and mana ----------------------------------------------------------------


func test_one_land_per_turn() -> void:
	var game: GameState = GameFactory.blank_game()
	var first: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.land())
	var second: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.land())
	assert_true(game.play_land(0, first.uid))
	assert_false(game.play_land(0, second.uid), "second land in the same turn is rejected")
	assert_eq(game.players[0].lands.size(), 1)
	assert_eq(GameFactory.count_events(game, GameEvent.Type.LAND_PLAYED), 1)


func test_land_only_in_main_phase_and_on_own_turn() -> void:
	var game: GameState = GameFactory.blank_game()
	var mine: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.land())
	var theirs: CardInstance = GameFactory.add_to_hand(game, 1, GameFactory.land())
	assert_false(game.play_land(1, theirs.uid), "not their turn")
	game.advance_phase()
	assert_eq(game.phase, GameState.Phase.COMBAT)
	assert_false(game.play_land(0, mine.uid), "not in combat")
	game.advance_phase()
	assert_eq(game.phase, GameState.Phase.MAIN2)
	assert_true(game.play_land(0, mine.uid), "main 2 is fine")


func test_land_limit_resets_each_turn() -> void:
	var game: GameState = GameFactory.blank_game()
	GameFactory.add_to_hand(game, 0, GameFactory.land())
	var land_two: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.land())
	game.play_land(0, game.players[0].hand[0].uid)
	GameFactory.pass_turn(game)
	GameFactory.pass_turn(game)
	assert_true(game.play_land(0, land_two.uid))


func test_lands_untap_at_start_of_turn() -> void:
	var game: GameState = GameFactory.blank_game()
	var land_card: CardInstance = GameFactory.add_land(game, 0)
	land_card.tapped = true
	GameFactory.pass_turn(game)
	GameFactory.pass_turn(game)
	assert_false(land_card.tapped)


func test_cast_creature_pays_generic_mana_and_enters_summoning_sick() -> void:
	var game: GameState = GameFactory.blank_game()
	GameFactory.add_lands(game, 0, 3)
	var bear: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.vanilla(2, 2, 2))
	assert_true(game.cast(0, bear.uid))
	assert_eq(game.players[0].untapped_lands().size(), 1)
	assert_eq(game.players[0].battlefield.size(), 1)
	assert_true(bear.summoning_sick)
	assert_eq(game.players[0].hand.size(), 0)


func test_cannot_cast_without_enough_mana() -> void:
	var game: GameState = GameFactory.blank_game()
	GameFactory.add_lands(game, 0, 1)
	var big: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.vanilla(5, 5, 3))
	assert_false(game.can_cast(0, big.uid))
	assert_false(game.cast(0, big.uid))
	assert_eq(game.players[0].hand.size(), 1)
	assert_eq(game.players[0].untapped_lands().size(), 1, "failed cast taps nothing")


func test_colored_pips_require_matching_lands() -> void:
	var game: GameState = GameFactory.blank_game()
	GameFactory.add_lands(game, 0, 3, Affinity.Type.A)
	var pips: Array[Affinity.Type] = [Affinity.Type.B]
	var b_card: CardInstance = GameFactory.add_to_hand(game, 0, CardBuilder.creature("b1", "B1", Affinity.Type.B, 1, pips, 2, 2))
	assert_false(game.can_cast(0, b_card.uid), "no B land")
	GameFactory.add_land(game, 0, GameFactory.land(Affinity.Type.B))
	assert_true(game.cast(0, b_card.uid))
	assert_eq(game.players[0].untapped_lands().size(), 2)


func test_generic_payment_spends_the_most_plentiful_color_first() -> void:
	var lands: Array[CardInstance] = []
	var game: GameState = GameFactory.blank_game()
	for color: Affinity.Type in [Affinity.Type.A, Affinity.Type.A, Affinity.Type.A, Affinity.Type.B]:
		lands.append(GameFactory.add_land(game, 0, GameFactory.land(color)))
	var out: Array[CardInstance] = []
	assert_true(Mana.plan(lands, 2, [] as Array[Affinity.Type], out))
	assert_eq(out.size(), 2)
	for land_card: CardInstance in out:
		assert_eq(land_card.data.color, Affinity.Type.A, "keeps the lone B land untapped")


func test_neutral_land_pays_generic_only_and_is_spent_first() -> void:
	var game: GameState = GameFactory.blank_game()
	var neutral: CardInstance = GameFactory.add_land(game, 0, CardBuilder.land(Affinity.Type.NEUTRAL))
	var colored: CardInstance = GameFactory.add_land(game, 0, GameFactory.land(Affinity.Type.A))
	var out: Array[CardInstance] = []
	assert_true(Mana.plan([neutral, colored] as Array[CardInstance], 1, [] as Array[Affinity.Type], out))
	assert_eq(out[0], neutral)
	assert_false(Mana.can_pay([neutral] as Array[CardInstance], 0, [Affinity.Type.A] as Array[Affinity.Type]))


func test_explicit_tap_choice_is_respected_and_validated() -> void:
	var game: GameState = GameFactory.blank_game()
	var a1: CardInstance = GameFactory.add_land(game, 0, GameFactory.land(Affinity.Type.A))
	var b1: CardInstance = GameFactory.add_land(game, 0, GameFactory.land(Affinity.Type.B))
	var card: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.vanilla(1, 1, 1))
	assert_false(game.cast(0, card.uid, 0, [a1.uid, b1.uid] as Array[int]), "pays too much")
	assert_false(a1.tapped)
	assert_true(game.cast(0, card.uid, 0, [b1.uid] as Array[int]))
	assert_true(b1.tapped)
	assert_false(a1.tapped)


func test_cost_change_modifier_by_color() -> void:
	var game: GameState = GameFactory.blank_game()
	game.players[0].modifiers.add(CardBuilder.modifier(Modifier.Kind.COST_CHANGE, -1, Affinity.Type.A))
	GameFactory.add_lands(game, 0, 1)
	var cheap: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.vanilla(2, 2, 2, Affinity.Type.A))
	var b_card: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.vanilla(2, 2, 1, Affinity.Type.B))
	assert_eq(game.generic_cost_for(0, cheap.data), 1)
	assert_eq(game.generic_cost_for(0, b_card.data), 1)
	game.players[0].modifiers.add(CardBuilder.modifier(Modifier.Kind.COST_CHANGE, -5, Affinity.Type.A))
	assert_eq(game.generic_cost_for(0, cheap.data), 0, "never below zero")
	assert_true(game.cast(0, cheap.uid))


func test_cast_emits_events() -> void:
	var game: GameState = GameFactory.blank_game()
	GameFactory.add_lands(game, 0, 1)
	var card: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.vanilla(1, 1, 1))
	game.cast(0, card.uid)
	assert_eq(GameFactory.count_events(game, GameEvent.Type.MANA_SPENT), 1)
	assert_eq(GameFactory.count_events(game, GameEvent.Type.CARD_CAST), 1)
	assert_eq(GameFactory.count_events(game, GameEvent.Type.PERMANENT_ENTERED), 1)


func test_creatures_lose_summoning_sickness_next_own_turn() -> void:
	var game: GameState = GameFactory.blank_game()
	GameFactory.add_lands(game, 0, 1)
	var card: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.vanilla(1, 1, 1))
	game.cast(0, card.uid)
	assert_true(card.summoning_sick)
	GameFactory.pass_turn(game)
	assert_true(card.summoning_sick, "still sick during the opponent's turn")
	GameFactory.pass_turn(game)
	assert_false(card.summoning_sick)


func test_spell_goes_to_graveyard_and_trap_is_set_face_down() -> void:
	var game: GameState = GameFactory.blank_game()
	GameFactory.add_lands(game, 0, 3)
	var spell: CardInstance = GameFactory.add_to_hand(game, 0, CardBuilder.spell("s", "S", Affinity.Type.A, 1, [] as Array[Affinity.Type]))
	var trap: CardInstance = GameFactory.add_to_hand(game, 0, CardBuilder.trap("t", "T", Affinity.Type.A, 1, [] as Array[Affinity.Type]))
	assert_true(game.cast(0, spell.uid))
	assert_true(game.cast(0, trap.uid))
	assert_eq(game.players[0].graveyard.size(), 1)
	assert_eq(game.players[0].traps.size(), 1)
	assert_true(trap.face_down)
	assert_eq(GameFactory.count_events(game, GameEvent.Type.TRAP_SET), 1)


# ---- Drawing, deck-out, win/loss ---------------------------------------------------


func test_drawing_from_empty_library_loses() -> void:
	var game: GameState = GameFactory.blank_game()
	game.players[1].library.clear()
	GameFactory.pass_turn(game)
	assert_true(game.is_over())
	assert_eq(game.winner, 0)
	assert_false(game.is_draw)
	assert_eq(GameFactory.count_events(game, GameEvent.Type.GAME_OVER), 1)


func test_opponent_at_zero_life_loses() -> void:
	var game: GameState = GameFactory.blank_game()
	game.deal_damage_to_player(0, 1, 10)
	game.check_state()
	assert_true(game.is_over())
	assert_eq(game.winner, 0)


func test_both_players_at_zero_is_a_draw() -> void:
	var game: GameState = GameFactory.blank_game()
	game.players[0].life = 0
	game.players[1].life = -2
	game.check_state()
	assert_true(game.is_over())
	assert_true(game.is_draw)
	assert_eq(game.winner, -1)


func test_no_actions_after_game_over() -> void:
	var game: GameState = GameFactory.blank_game()
	var land_card: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.land())
	game.players[1].life = 0
	game.check_state()
	assert_false(game.play_land(0, land_card.uid))
	assert_false(game.advance_phase())
	assert_eq(game.awaiting_player(), -1)


func test_turn_limit_ends_in_a_draw() -> void:
	var opts: GameOptions = GameOptions.new()
	opts.turn_limit = 4
	var game: GameState = GameFactory.new_game(1, null, null, opts)
	for i: int in range(6):
		GameFactory.pass_turn(game)
	assert_true(game.is_over())
	assert_true(game.is_draw)
	assert_eq(game.turn, 4)


func test_extra_draws_modifier() -> void:
	var game: GameState = GameFactory.blank_game()
	game.players[1].modifiers.add(CardBuilder.modifier(Modifier.Kind.EXTRA_DRAWS, 2))
	GameFactory.pass_turn(game)
	assert_eq(game.players[1].hand.size(), 3, "1 normal + 2 extra")


# ---- Hand size and end of turn -----------------------------------------------------


func test_must_discard_down_to_max_hand_size() -> void:
	var game: GameState = GameFactory.blank_game()
	for i: int in range(12):
		GameFactory.add_to_hand(game, 0, GameFactory.vanilla(1, 1, 1))
	game.advance_phase()
	game.advance_phase()
	game.advance_phase()
	assert_eq(game.phase, GameState.Phase.END)
	assert_eq(game.pending_discard, 2)
	assert_eq(game.awaiting_player(), 0)
	assert_false(game.advance_phase(), "cannot pass while a discard is owed")
	var uids: Array[int] = [game.players[0].hand[0].uid]
	assert_false(game.discard_for_hand_size(0, uids), "wrong number of cards")
	uids.append(game.players[0].hand[1].uid)
	assert_true(game.discard_for_hand_size(0, uids))
	assert_eq(game.players[0].hand.size(), 10)
	assert_eq(game.players[0].graveyard.size(), 2)
	assert_eq(game.active, 1, "turn passed to the opponent")


func test_max_hand_size_modifier() -> void:
	var game: GameState = GameFactory.blank_game()
	game.players[0].max_hand_size = 12
	for i: int in range(12):
		GameFactory.add_to_hand(game, 0, GameFactory.vanilla(1, 1, 1))
	GameFactory.pass_turn(game)
	assert_eq(game.pending_discard, 0)
	assert_eq(game.active, 1)


func test_damage_and_temp_effects_clear_at_end_of_turn() -> void:
	var game: GameState = GameFactory.blank_game()
	var wall: CardInstance = GameFactory.add_to_battlefield(game, 1, GameFactory.vanilla(1, 4, 1))
	game.deal_damage_to_creature(0, wall, 3)
	wall.temp_power = 2
	assert_eq(wall.damage, 3)
	GameFactory.pass_turn(game)
	assert_eq(wall.damage, 0)
	assert_eq(wall.temp_power, 0)
	assert_eq(GameFactory.count_events(game, GameEvent.Type.DAMAGE_CLEARED), 1)


func test_lethal_damage_kills_creature_and_moves_it_to_graveyard() -> void:
	var game: GameState = GameFactory.blank_game()
	var bear: CardInstance = GameFactory.add_to_battlefield(game, 1, GameFactory.vanilla(2, 2, 2))
	game.deal_damage_to_creature(0, bear, 2)
	game.check_state()
	assert_eq(game.players[1].battlefield.size(), 0)
	assert_eq(game.players[1].graveyard.size(), 1)
	assert_eq(GameFactory.count_events(game, GameEvent.Type.CREATURE_DIED), 1)


func test_stat_modifiers_apply_to_matching_color() -> void:
	var game: GameState = GameFactory.blank_game()
	game.players[0].modifiers.add(CardBuilder.modifier(Modifier.Kind.STAT_CHANGE, 1, Affinity.Type.A, 2))
	var a_card: CardInstance = GameFactory.add_to_battlefield(game, 0, GameFactory.vanilla(2, 2, 1, Affinity.Type.A))
	var b_card: CardInstance = GameFactory.add_to_battlefield(game, 0, GameFactory.vanilla(2, 2, 1, Affinity.Type.B))
	assert_eq(game.get_power(a_card), 3)
	assert_eq(game.get_toughness(a_card), 4)
	assert_eq(game.get_power(b_card), 2)


func test_gain_life_is_capped_but_starting_life_above_max_is_kept() -> void:
	var game: GameState = GameFactory.blank_game()
	game.players[0].life = 8
	game.gain_life(0, 5)
	assert_eq(game.players[0].life, 10)
	game.players[0].life = 12
	game.gain_life(0, 5)
	assert_eq(game.players[0].life, 12)


# ---- Actions and cloning -----------------------------------------------------------


func test_legal_actions_include_pass_land_and_castable_cards() -> void:
	var game: GameState = GameFactory.blank_game()
	GameFactory.add_lands(game, 0, 2)
	GameFactory.add_to_hand(game, 0, GameFactory.land())
	GameFactory.add_to_hand(game, 0, GameFactory.land())
	GameFactory.add_to_hand(game, 0, GameFactory.vanilla(1, 1, 1))
	GameFactory.add_to_hand(game, 0, GameFactory.vanilla(9, 9, 9))
	var types: Array[GameAction.Type] = []
	for action: GameAction in game.legal_actions():
		types.append(action.type)
	assert_eq(types.count(GameAction.Type.PASS), 1)
	assert_eq(types.count(GameAction.Type.PLAY_LAND), 1, "duplicate lands collapse")
	assert_eq(types.count(GameAction.Type.CAST), 1, "only the affordable creature")


func test_apply_action_routes_to_rules() -> void:
	var game: GameState = GameFactory.blank_game()
	var land_card: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.land())
	assert_true(game.apply_action(GameAction.play_land(0, land_card.uid)))
	assert_true(game.apply_action(GameAction.pass_phase(0)))
	assert_eq(game.phase, GameState.Phase.COMBAT)
	assert_false(game.apply_action(GameAction.pass_phase(1)), "only the awaited player may act")


func test_clone_is_independent_and_keeps_uids() -> void:
	var game: GameState = GameFactory.blank_game()
	GameFactory.add_lands(game, 0, 2)
	var card: CardInstance = GameFactory.add_to_hand(game, 0, GameFactory.vanilla(1, 1, 1))
	var copy: GameState = game.clone()
	assert_true(copy.cast(0, card.uid))
	assert_eq(copy.players[0].battlefield.size(), 1)
	assert_eq(game.players[0].battlefield.size(), 0)
	assert_eq(game.players[0].untapped_lands().size(), 2)
	assert_eq(copy.events.size(), 0, "clones do not record events")
	assert_eq(copy.rng.state, game.rng.state)


func test_clone_can_hide_traps() -> void:
	var game: GameState = GameFactory.blank_game()
	var trap: CardData = CardBuilder.trap("t", "T", Affinity.Type.A, 0, [] as Array[Affinity.Type])
	game.players[1].traps.append(game.create_instance(trap, 1))
	assert_eq(game.clone().players[1].traps.size(), 1)
	assert_eq(game.clone(true, 1).players[1].traps.size(), 0)
	assert_eq(game.clone(true, 1).players[0].traps.size(), 0)
