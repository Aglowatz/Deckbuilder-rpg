extends CardTestBase
## Battle AI upgrade, Part 3: Path personalities (blended from the deck) and boss signatures; Part 4: skill levels and mistakes.


func _deck_of(ids: Array[String], copies: int = 4) -> Deck:
	var deck: Deck = Deck.new()
	for i: int in range(19):
		deck.cards.append(CardSet.card("BAS-B"))
	for id: String in ids:
		for i: int in range(copies):
			deck.cards.append(CardSet.card(id))
	return deck


func _game_with_decks(a: Array[String], b: Array[String]) -> GameState:
	CardSet.load_all()
	var options: GameOptions = GameOptions.new()
	options.rng_seed = 11
	var game: GameState = GameState.new(options)
	game.add_player(PlayerSetup.create(_deck_of(a), null, [], "A"))
	game.add_player(PlayerSetup.create(_deck_of(b), null, [], "B"))
	game.start()
	return game


func test_path_mix_reads_the_deck() -> void:
	var game: GameState = _game_with_decks(["B-01", "B-05", "B-06"], ["N-01", "N-02", "G-01", "G-06"])
	var beef: Dictionary = AIProfiles.path_mix(game, 0)
	assert_almost_eq(float(beef.get(Affinity.Type.BEEFCAKE, 0.0)), 1.0, 0.001, "a mono-Beefcake deck")
	var mixed: Dictionary = AIProfiles.path_mix(game, 1)
	assert_almost_eq(float(mixed.get(Affinity.Type.NECROCRAT, 0.0)), 0.5, 0.001)
	assert_almost_eq(float(mixed.get(Affinity.Type.GOURMAND, 0.0)), 0.5, 0.001)


func test_blend_moves_the_weights_toward_the_path() -> void:
	var base: AIPersonality = AIPersonality.balanced()
	var beef: AIPersonality = AIProfiles.blend(base, {Affinity.Type.BEEFCAKE: 1.0})
	assert_gt(beef.attack_bias, base.attack_bias, "Beefcake presses")
	assert_lt(beef.iron_hold_value, base.iron_hold_value, "Beefcake spends Iron")
	var gour: AIPersonality = AIProfiles.blend(base, {Affinity.Type.GOURMAND: 1.0})
	assert_gt(gour.hp_weight, base.hp_weight, "Gourmand guards its HP")
	assert_gt(gour.defense_value, base.defense_value)
	var half: AIPersonality = AIProfiles.blend(base, {Affinity.Type.GOURMAND: 0.5, Affinity.Type.NECROCRAT: 0.5})
	assert_almost_eq(half.hp_weight, base.hp_weight + 0.15, 0.001, "a two-Path deck blends half of each")
	assert_eq(base.attack_bias, 0.0, "the shared resource is never changed")


func test_the_ai_adopts_its_decks_profile_on_the_first_decision() -> void:
	var game: GameState = _game_with_decks(["B-01", "B-05", "B-06"], ["G-01", "G-06", "G-04"])
	var beef: AIPlayer = AIPlayer.new(AIPersonality.balanced())
	var gour: AIPlayer = AIPlayer.new(AIPersonality.balanced())
	beef.choose_action(game)
	assert_gt(beef.evaluator().personality.attack_bias, 0.3, "Beefcake seat")
	while game.awaiting_player() == 0 and not game.is_over():
		game.apply_action(beef.choose_action(game))
	gour.choose_action(game)
	assert_gt(gour.evaluator().personality.hp_weight, 1.2, "Gourmand seat")


func test_signature_patience_holds_attacks_until_three_units() -> void:
	var game: GameState = _game()
	_energy(game)
	_energy(game, 1)
	_unit(game, 0, 3, 3)
	_unit(game, 1, 1, 1)
	var personality: AIPersonality = AIPersonality.balanced()
	personality.signature = "patience"
	personality.path_profile = "none"
	var ai: AIPlayer = AIPlayer.new(personality)
	ai.deterministic = true
	game.advance_phase()
	assert_eq(ai.choose_action(game).type, GameAction.Type.PASS, "one unit: it waits")
	_unit(game, 0, 2, 2)
	_unit(game, 0, 2, 2)
	var again: AIPlayer = AIPlayer.new(personality)
	again.deterministic = true
	assert_eq(again.choose_action(game).type, GameAction.Type.DECLARE_ATTACKERS, "three units: it comes")


func test_skill_levels_search_differently_but_all_play_legally() -> void:
	for skill: int in range(3):
		var game: GameState = _game()
		_energy(game, 0, 4)
		_energy(game, 1, 3)
		for id: String in ["N-02", "N-15", "C-02", "B-05", "G-13", "R-06", "C-11"]:
			GameFactory.add_to_hand(game, 0, CardSet.card(id))
		_unit(game, 1, 2, 2)
		var personality: AIPersonality = AIPersonality.balanced()
		personality.skill = skill
		var ai: AIPlayer = AIPlayer.new(personality)
		ai.deterministic = true
		var steps: int = 0
		while game.active == 0 and not game.is_over() and steps < 40:
			steps += 1
			assert_true(game.apply_action(ai.choose_action(game)), "skill %d plays legally" % skill)


func test_normal_skill_makes_occasional_mistakes_and_elite_does_not() -> void:
	# The same open attack, many seeds: a Normal AI sometimes holds back, an Elite never does.
	var holds: Dictionary = {0: 0, 1: 0}
	for skill: int in [0, 1]:
		for seed_value: int in range(40):
			var game: GameState = GameFactory.blank_game(seed_value + 1)
			GameFactory.add_infrastructure_cards(game, 0, 3)
			GameFactory.add_to_field(game, 0, GameFactory.vanilla(3, 3))
			game.advance_phase()
			var personality: AIPersonality = AIPersonality.balanced()
			personality.skill = skill
			personality.mistake_rate = 0.25 if skill == 0 else 0.0
			var ai: AIPlayer = AIPlayer.new(personality)
			ai.deterministic = true
			if ai.choose_action(game).type == GameAction.Type.PASS:
				holds[skill] = int(holds[skill]) + 1
	assert_eq(int(holds[1]), 0, "Elite always takes the free attack")
	assert_gt(int(holds[0]), 2, "Normal misses it now and then (%d of 40)" % int(holds[0]))
	assert_lt(int(holds[0]), 25, "but not most of the time")


func test_mistakes_never_skip_lethal_or_a_lethal_saving_block() -> void:
	for seed_value: int in range(30):
		var game: GameState = GameFactory.blank_game(seed_value + 100)
		GameFactory.add_infrastructure_cards(game, 0, 3)
		game.players[1].hp = 3
		GameFactory.add_to_field(game, 0, GameFactory.vanilla(3, 3))
		game.advance_phase()
		var personality: AIPersonality = AIPersonality.balanced()
		personality.skill = 0
		personality.mistake_rate = 0.5
		var ai: AIPlayer = AIPlayer.new(personality)
		ai.deterministic = true
		assert_eq(ai.choose_action(game).type, GameAction.Type.DECLARE_ATTACKERS, "lethal is never missed (seed %d)" % seed_value)
	for seed_value: int in range(30):
		var game: GameState = GameFactory.blank_game(seed_value + 200)
		GameFactory.add_infrastructure_cards(game, 0, 3)
		game.players[1].hp = 4
		var attacker: CardInstance = GameFactory.add_to_field(game, 0, GameFactory.vanilla(5, 5))
		GameFactory.add_to_field(game, 1, GameFactory.vanilla(1, 1))
		game.advance_phase()
		game.declare_attackers([attacker.uid] as Array[int])
		var personality: AIPersonality = AIPersonality.balanced()
		personality.skill = 0
		personality.careless_blocks = 0.5
		var ai: AIPlayer = AIPlayer.new(personality)
		ai.deterministic = true
		assert_eq(ai.choose_action(game).type, GameAction.Type.DECLARE_BLOCKERS, "a block that saves the game is never forgotten (seed %d)" % seed_value)


func test_for_foe_sets_skill_and_signature() -> void:
	var normal: AIPlayer = AIPlayer.for_foe(AIPersonality.balanced(), AIPlayer.Skill.NORMAL, "Flexing Brute")
	assert_eq(normal.personality.skill, 0)
	assert_gt(normal.personality.mistake_rate, 0.0)
	var boss: AIPlayer = AIPlayer.for_foe(AIPersonality.balanced(), AIPlayer.Skill.BOSS, NinjaBoss.DISPLAY_NAME)
	assert_eq(boss.personality.skill, 2)
	assert_eq(boss.personality.signature, "trickster")
	assert_eq(boss.personality.mistake_rate, 0.0)
	# Part 5: the first boss is an exception - it plays at Normal skill (AIPlayer.SKILL_OVERRIDES) and keeps its signature.
	var first: AIPlayer = AIPlayer.for_foe(AIPersonality.balanced(), AIPlayer.Skill.BOSS, GraveyardBoss.DISPLAY_NAME)
	assert_eq(first.personality.skill, 0)
	assert_eq(first.personality.signature, "patience")
	assert_gt(first.personality.careless_blocks, 0.0)
