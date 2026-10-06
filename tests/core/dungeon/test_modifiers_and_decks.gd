extends GutTest

const NO_PIPS: Array[Affinity.Type] = []


func _source(name: String, kind: ModifierSource.SourceKind, mods: Array[Modifier]) -> ModifierSource:
	return CardBuilder.modifier_source(name, kind, mods)


func _card(id: String, color: Affinity.Type) -> CardData:
	return CardBuilder.unit(id, id, color, 1, NO_PIPS, 1, 1)


## A deck of `distinct` different cards x `copies` each, in one color per card given.
func _deck(entries: Array[CardData], copies: int) -> Deck:
	var deck: Deck = Deck.new()
	for card: CardData in entries:
		for i: int in range(copies):
			deck.cards.append(card)
	return deck


func _legal_deck(colors: Array[Affinity.Type]) -> Deck:
	var deck: Deck = Deck.new()
	for color: Affinity.Type in colors:
		for i: int in range(8):
			deck.cards.append(CardBuilder.infra(color))
	var n: int = 0
	while deck.cards.size() < 45:
		var color: Affinity.Type = colors[n % colors.size()]
		var card: CardData = _card("c%d" % (n / 3), color)
		deck.cards.append(card)
		n += 1
	return deck


# ---- Pipeline: equipment, items, zones and dungeon all feed the same engine ----------


func test_every_source_kind_flows_through_one_pipeline() -> void:
	var profile: PlayerProfile = PlayerProfile.new()
	profile.equipment = [_source("Ring", ModifierSource.SourceKind.EQUIPMENT, [CardBuilder.modifier(Modifier.Kind.MAX_HP, 2)] as Array[Modifier])] as Array[ModifierSource]
	profile.items = [_source("Charm", ModifierSource.SourceKind.ITEM, [CardBuilder.modifier(Modifier.Kind.MAX_HAND_SIZE, 1)] as Array[Modifier])] as Array[ModifierSource]
	var zone: ModifierSource = _source("Swamp", ModifierSource.SourceKind.ZONE, [CardBuilder.modifier(Modifier.Kind.COST_CHANGE, -1, Affinity.Type.BEEFCAKE)] as Array[Modifier])
	var dungeon: ModifierSource = _source("Crypt", ModifierSource.SourceKind.DUNGEON, [CardBuilder.modifier(Modifier.Kind.EXTRA_DRAWS, 1)] as Array[Modifier])
	var mods: ModifierSet = ModifierPipeline.build(profile, zone, [dungeon] as Array[ModifierSource])
	assert_eq(mods.sum(Modifier.Kind.MAX_HP), 2)
	assert_eq(mods.sum(Modifier.Kind.MAX_HAND_SIZE), 1)
	assert_eq(mods.sum_for_color(Modifier.Kind.COST_CHANGE, Affinity.Type.BEEFCAKE), -1)
	assert_eq(mods.sum(Modifier.Kind.EXTRA_DRAWS), 1)
	var setup: PlayerSetup = PlayerSetup.new()
	setup.deck = GameFactory.make_deck()
	setup.profile = profile
	setup.modifiers = mods
	var game: GameState = GameState.new()
	game.options.rng_seed = 4
	game.add_player(setup)
	game.add_player(PlayerSetup.create(GameFactory.make_deck()))
	assert_eq(game.players[0].max_hp, 12)
	assert_eq(game.players[0].max_hand_size, 11)


func test_max_traps_modifier_raises_the_trap_cap() -> void:
	var dungeon: ModifierSource = _source("Warded Hollow", ModifierSource.SourceKind.DUNGEON, [CardBuilder.modifier(Modifier.Kind.MAX_TRAPS, 2)] as Array[Modifier])
	var mods: ModifierSet = ModifierPipeline.build(PlayerProfile.new(), null, [dungeon] as Array[ModifierSource])
	var setup: PlayerSetup = PlayerSetup.new()
	setup.deck = GameFactory.make_deck()
	setup.modifiers = mods
	var game: GameState = GameState.new()
	game.add_player(setup)
	game.add_player(PlayerSetup.create(GameFactory.make_deck()))
	assert_eq(game.players[0].max_traps, GameState.MAX_TRAPS + 2)
	assert_eq(game.players[1].max_traps, GameState.MAX_TRAPS, "unaffected player keeps the base cap")


func test_enemy_pipeline_uses_zone_and_enemy_sources() -> void:
	var zone: ModifierSource = _source("Lava", ModifierSource.SourceKind.ZONE, [CardBuilder.modifier(Modifier.Kind.STAT_CHANGE, 1, Modifier.ANY_COLOR, 1)] as Array[Modifier])
	var mods: ModifierSet = ModifierPipeline.build_for_enemy([] as Array[ModifierSource], zone)
	assert_eq(mods.stat_bonus(Affinity.Type.GOURMAND), Vector2i(1, 1))
	var setup: PlayerSetup = PlayerSetup.create(GameFactory.make_deck())
	setup.modifiers = mods
	var game: GameState = GameState.new()
	game.add_player(PlayerSetup.create(GameFactory.make_deck()))
	game.add_player(setup)
	var unit: CardInstance = GameFactory.add_to_field(game, 1, GameFactory.vanilla(2, 2, 1, Affinity.Type.GOURMAND))
	assert_eq(game.get_attack(unit), 3)
	assert_eq(game.get_defense(unit), 3)


func test_start_of_combat_effect_fires_for_the_active_player() -> void:
	var game: GameState = GameFactory.blank_game()
	var burn: Modifier = CardBuilder.modifier(Modifier.Kind.START_OF_COMBAT_EFFECT, 0)
	burn.effect = CardBuilder.effect(CardEnums.Trigger.START_OF_TURN, CardEnums.TargetKind.OPPONENT, CardEnums.EffectOp.DEAL_DAMAGE, 1)
	game.players[0].modifiers.add(burn)
	game.advance_phase()
	assert_eq(game.players[1].hp, 9)
	assert_eq(game.players[0].hp, 10)
	GameFactory.pass_turn(game)
	game.advance_phase()
	assert_eq(game.players[1].hp, 9, "P1's own combat does not trigger P0's modifier")
	assert_eq(game.players[0].hp, 10)


func test_start_of_combat_buff_helps_attackers() -> void:
	var game: GameState = GameFactory.blank_game()
	var rally: Modifier = CardBuilder.modifier(Modifier.Kind.START_OF_COMBAT_EFFECT, 0)
	rally.effect = CardBuilder.effect(CardEnums.Trigger.START_OF_TURN, CardEnums.TargetKind.ALL_ALLY_UNITS, CardEnums.EffectOp.BUFF, 2, 0, CardEnums.Duration.END_OF_TURN)
	game.players[0].modifiers.add(rally)
	var attacker: CardInstance = GameFactory.add_to_field(game, 0, GameFactory.vanilla(1, 1))
	game.advance_phase()
	game.declare_attackers([attacker.uid] as Array[int])
	game.declare_blockers({})
	assert_eq(game.players[1].hp, 7)


func test_start_of_combat_effect_can_end_the_game() -> void:
	var game: GameState = GameFactory.blank_game()
	game.players[1].hp = 1
	var burn: Modifier = CardBuilder.modifier(Modifier.Kind.START_OF_COMBAT_EFFECT, 0)
	burn.effect = CardBuilder.effect(CardEnums.Trigger.START_OF_TURN, CardEnums.TargetKind.OPPONENT, CardEnums.EffectOp.DEAL_DAMAGE, 1)
	game.players[0].modifiers.add(burn)
	game.advance_phase()
	assert_true(game.is_over())
	assert_eq(game.winner, 0)


# ---- Deck validation ---------------------------------------------------------------


func test_legal_two_color_deck_passes() -> void:
	var deck: Deck = _legal_deck([Affinity.Type.BEEFCAKE, Affinity.Type.GOURMAND] as Array[Affinity.Type])
	assert_eq(deck.size(), 45)
	assert_true(DeckValidator.is_valid(deck, PlayerProfile.new()))


func test_deck_with_too_few_cards_fails() -> void:
	var deck: Deck = _legal_deck([Affinity.Type.BEEFCAKE] as Array[Affinity.Type])
	deck.cards.pop_back()
	var issues: Array[DeckValidator.Issue] = DeckValidator.validate(deck, PlayerProfile.new())
	assert_true(DeckValidator.has_problem(issues, DeckValidator.Problem.TOO_FEW_CARDS))


func test_more_than_four_copies_fails_but_basic_infrastructure_are_exempt() -> void:
	var deck: Deck = _legal_deck([Affinity.Type.BEEFCAKE] as Array[Affinity.Type])
	assert_true(deck.count_of("infrastructure_beefcake") > 3, "test deck has many basic infrastructure")
	assert_true(DeckValidator.is_valid(deck, PlayerProfile.new()), "basic infrastructure do not count against the limit")
	var dupe: CardData = _card("dupe", Affinity.Type.BEEFCAKE)
	for i: int in range(5):
		deck.cards.append(dupe)
	var issues: Array[DeckValidator.Issue] = DeckValidator.validate(deck, PlayerProfile.new())
	assert_true(DeckValidator.has_problem(issues, DeckValidator.Problem.TOO_MANY_COPIES))
	assert_eq(issues[0].card_id, "dupe")
	deck.cards.pop_back()
	assert_true(DeckValidator.is_valid(deck, PlayerProfile.new()), "exactly four copies is fine")


func test_color_limit_is_two_until_postgame_then_four() -> void:
	var profile: PlayerProfile = PlayerProfile.new()
	var three: Deck = _legal_deck([Affinity.Type.BEEFCAKE, Affinity.Type.GOURMAND, Affinity.Type.REFUSEMANCER] as Array[Affinity.Type])
	var four: Deck = _legal_deck([Affinity.Type.BEEFCAKE, Affinity.Type.GOURMAND, Affinity.Type.REFUSEMANCER, Affinity.Type.NECROCRAT] as Array[Affinity.Type])
	assert_eq(DeckValidator.max_colors(profile), 2)
	assert_true(DeckValidator.has_problem(DeckValidator.validate(three, profile), DeckValidator.Problem.TOO_MANY_COLORS))
	profile.postgame_unlocked = true
	assert_eq(DeckValidator.max_colors(profile), 4)
	assert_true(DeckValidator.is_valid(three, profile))
	assert_true(DeckValidator.is_valid(four, profile))


func test_neutral_cards_do_not_count_as_a_color() -> void:
	var deck: Deck = _legal_deck([Affinity.Type.BEEFCAKE, Affinity.Type.GOURMAND] as Array[Affinity.Type])
	for i: int in range(3):
		deck.cards.append(_card("neutral_card", Affinity.Type.NEUTRAL))
	assert_true(DeckValidator.is_valid(deck, PlayerProfile.new()))


func test_max_colors_modifier_raises_the_limit() -> void:
	var profile: PlayerProfile = PlayerProfile.new()
	var mods: ModifierSet = ModifierSet.new()
	mods.add(CardBuilder.modifier(Modifier.Kind.MAX_DECK_COLORS, 1))
	assert_eq(DeckValidator.max_colors(profile, mods), 3)
	var three: Deck = _legal_deck([Affinity.Type.BEEFCAKE, Affinity.Type.GOURMAND, Affinity.Type.REFUSEMANCER] as Array[Affinity.Type])
	assert_true(DeckValidator.is_valid(three, profile, mods))
	mods.add(CardBuilder.modifier(Modifier.Kind.MAX_DECK_COLORS, 10))
	assert_eq(DeckValidator.max_colors(profile, mods), 4, "never more than the four real types")


func test_min_deck_size_modifier_lowers_the_minimum() -> void:
	var deck: Deck = _legal_deck([Affinity.Type.BEEFCAKE] as Array[Affinity.Type])
	for i: int in range(5):
		deck.cards.pop_back()
	assert_eq(deck.size(), 40)
	assert_true(DeckValidator.has_problem(DeckValidator.validate(deck, PlayerProfile.new()), DeckValidator.Problem.TOO_FEW_CARDS))
	var mods: ModifierSet = ModifierSet.new()
	mods.add(CardBuilder.modifier(Modifier.Kind.MIN_DECK_SIZE, -5))
	assert_eq(DeckValidator.min_deck_size(mods), 40)
	assert_true(DeckValidator.is_valid(deck, PlayerProfile.new(), mods))


func test_min_deck_size_never_goes_below_one() -> void:
	var mods: ModifierSet = ModifierSet.new()
	mods.add(CardBuilder.modifier(Modifier.Kind.MIN_DECK_SIZE, -1000))
	assert_eq(DeckValidator.min_deck_size(mods), 1)


func test_ownership_check() -> void:
	var profile: PlayerProfile = PlayerProfile.new()
	var deck: Deck = _legal_deck([Affinity.Type.BEEFCAKE] as Array[Affinity.Type])
	assert_true(DeckValidator.is_valid(deck, profile), "ownership is not checked by default")
	assert_true(DeckValidator.has_problem(DeckValidator.validate(deck, profile, null, true), DeckValidator.Problem.NOT_OWNED))
	for card: CardData in deck.cards:
		if not card.is_basic:
			profile.owned_cards.append(card)
	assert_true(DeckValidator.is_valid(deck, profile, null, true))


# ---- Dungeon run -------------------------------------------------------------------


func _run() -> DungeonRun:
	return DungeonRun.enter(PlayerProfile.new(), GameFactory.make_deck())


func _enemy() -> PlayerSetup:
	return PlayerSetup.create(GameFactory.make_deck(), null, [] as Array[ModifierSource], "Enemy")


func test_entering_a_dungeon_fully_heals() -> void:
	var run: DungeonRun = _run()
	assert_eq(run.hp, 10)
	run.lose_hp(6)
	assert_eq(run.hp, 4)
	var again: DungeonRun = DungeonRun.enter(run.profile, run.base_deck)
	assert_eq(again.hp, 10, "entering a dungeon heals to full")


func test_max_hp_includes_dungeon_modifiers() -> void:
	var boon: ModifierSource = _source("Blessing", ModifierSource.SourceKind.DUNGEON, [CardBuilder.modifier(Modifier.Kind.MAX_HP, 5)] as Array[Modifier])
	var run: DungeonRun = DungeonRun.enter(PlayerProfile.new(), GameFactory.make_deck(), [boon] as Array[ModifierSource])
	assert_eq(run.max_hp(), 15)
	assert_eq(run.hp, 15)


func test_hp_carries_between_encounters() -> void:
	var run: DungeonRun = _run()
	var game: GameState = run.start_encounter(_enemy())
	assert_eq(game.players[0].hp, 10)
	game.deal_damage_to_player(0, 0, 4)
	game.players[1].hp = 0
	game.check_state()
	assert_eq(game.winner, 0)
	run.finish_encounter(game)
	assert_eq(run.hp, 6)
	assert_eq(run.encounters_won, 1)
	assert_false(run.failed)
	var second: GameState = run.start_encounter(_enemy())
	assert_eq(second.players[0].hp, 6, "second encounter starts with the carried-over HP")
	assert_eq(second.players[0].max_hp, 10)


func test_healing_between_encounters_is_capped() -> void:
	var run: DungeonRun = _run()
	run.lose_hp(7)
	run.heal(4)
	assert_eq(run.hp, 7)
	run.heal(100)
	assert_eq(run.hp, 10)


func test_losing_an_encounter_or_all_hp_fails_the_run() -> void:
	var run: DungeonRun = _run()
	var game: GameState = run.start_encounter(_enemy())
	game.players[0].hp = 0
	game.check_state()
	run.finish_encounter(game)
	assert_true(run.failed)
	assert_true(run.is_over())


## A drawn encounter (both players hit 0 at once, or the turn limit) is not a win, so it fails
## the run - same as an outright loss.
func test_a_drawn_encounter_also_fails_the_run() -> void:
	var run: DungeonRun = _run()
	var game: GameState = run.start_encounter(_enemy())
	game.players[0].hp = 0
	game.players[1].hp = 0
	game.check_state()
	assert_true(game.is_draw)
	assert_eq(game.winner, -1)
	run.finish_encounter(game)
	assert_true(run.failed, "a draw is not a win, so the run fails")
	assert_true(run.is_over())
	var run2: DungeonRun = _run()
	run2.lose_hp(99)
	assert_true(run2.failed)
	assert_eq(run2.hp, 0)


func test_max_hp_boon_also_heals_by_the_same_amount() -> void:
	var run: DungeonRun = _run()
	run.lose_hp(3)
	run.add_dungeon_source(_source("Vigor", ModifierSource.SourceKind.BOON, [CardBuilder.modifier(Modifier.Kind.MAX_HP, 2)] as Array[Modifier]))
	assert_eq(run.max_hp(), 12)
	assert_eq(run.hp, 9)


func test_dungeon_modifiers_apply_in_the_duel() -> void:
	var boon: ModifierSource = _source("Fleet", ModifierSource.SourceKind.BOON, [CardBuilder.modifier(Modifier.Kind.EXTRA_DRAWS, 1)] as Array[Modifier])
	var run: DungeonRun = _run()
	run.add_dungeon_source(boon)
	var game: GameState = run.start_encounter(_enemy())
	assert_eq(game.players[0].modifiers.sum(Modifier.Kind.EXTRA_DRAWS), 1)


func test_zone_modifier_applies_only_for_that_encounter() -> void:
	var run: DungeonRun = _run()
	var zone: ModifierSource = _source("Bog", ModifierSource.SourceKind.ZONE, [CardBuilder.modifier(Modifier.Kind.MAX_HAND_SIZE, -3)] as Array[Modifier])
	assert_eq(run.start_encounter(_enemy(), zone).players[0].max_hand_size, 7)
	assert_eq(run.start_encounter(_enemy()).players[0].max_hand_size, 10)


func test_lost_and_gained_cards_change_the_deck_for_the_dungeon_only() -> void:
	var run: DungeonRun = _run()
	var base_size: int = run.base_deck.size()
	var victim: CardData = run.base_deck.cards[run.base_deck.cards.size() - 1]
	assert_true(run.lose_card(victim))
	assert_eq(run.current_deck().size(), base_size - 1)
	assert_eq(run.base_deck.size(), base_size, "base deck is untouched")
	var reward: CardData = _card("reward", Affinity.Type.BEEFCAKE)
	run.gain_card(reward)
	assert_eq(run.current_deck().size(), base_size)
	assert_eq(run.current_deck().count_of("reward"), 1)
	assert_false(run.lose_card(_card("not_in_deck", Affinity.Type.BEEFCAKE)))
	var game: GameState = run.start_encounter(_enemy())
	var total: int = game.players[0].deck.size() + game.players[0].hand.size()
	assert_eq(total, base_size)
