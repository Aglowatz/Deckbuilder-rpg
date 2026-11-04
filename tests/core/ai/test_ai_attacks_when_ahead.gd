extends GutTest
## Fix pass Nov 4 (Part 1.5): "the AI attacks when it is ahead". Boards where attacking is clearly right - lethal on an empty or
## exhausted table, a big lead the player cannot answer - played by Colonel Casserole's AI (Balanced, Elite) and by every boss-level
## foe signature (fortress, all_in, paperwork, patience, trickster), under the Endless Buffet's zone rules where they apply. Regression guard for a held-back attack.

const BOSSES: Array[String] = ["Colonel Casserole", "Colonel Cornelius Crumb, Director of Culinary Defense", "Baron Quadzilla", "Mortimer Grimsby, CE-No", "The Restless Dead", "Shiro Swindle"]


func _foe_ai(enemy_name: String) -> AIPlayer:
	var ai: AIPlayer = AIPlayer.for_foe(AIPersonality.balanced(), AIPlayer.Skill.ELITE, enemy_name)
	ai.deterministic = true
	return ai


## A game on the foe's (seat 1) main phase with empty hands and the Buffet's rules on both seats.
func _board(player_hp: int, foe_hp: int) -> GameState:
	CardSet.load_all()
	var game: GameState = GameFactory.blank_game(11)
	while game.active != 1:
		GameFactory.pass_turn(game)
	for player: PlayerState in game.players:
		player.hand.clear()
		player.modifiers.add_source(ZoneEffects.source_for(BuffetZone.ID))
	game.players[0].hp = player_hp
	game.players[1].hp = foe_hp
	GameFactory.add_infrastructure_cards(game, 1, 4, Affinity.Type.GOURMAND)
	return game


func _unit(game: GameState, owner: int, attack: int, defense: int, exhausted: bool = false) -> CardInstance:
	var card: CardInstance = GameFactory.add_to_field(game, owner, GameFactory.vanilla(attack, defense, 2, Affinity.Type.GOURMAND))
	card.exhausted = exhausted
	return card


## Lets the foe's AI play its turn up to the attack; returns the attacker uids it declared (empty = no attack).
func _declared(game: GameState, ai: AIPlayer) -> Array[int]:
	var guard: int = 0
	while game.active == 1 and not game.is_over() and guard < 30:
		guard += 1
		var action: GameAction = ai.choose_action(game)
		if action.type == GameAction.Type.DECLARE_ATTACKERS:
			return action.uids
		if game.phase == GameState.Phase.COMBAT and game.combat_step == GameState.CombatStep.DECLARE_ATTACKERS and game.awaiting_player() == 1:
			return [] as Array[int]
		if not game.apply_action(action):
			game.apply_action(GameAction.pass_phase(1))
	return [] as Array[int]


func _power(game: GameState, uids: Array[int]) -> int:
	var total: int = 0
	for uid: int in uids:
		total += game.get_attack(game.find_permanent(uid))
	return total


func test_lethal_on_an_empty_table_is_taken() -> void:
	for boss: String in BOSSES:
		var game: GameState = _board(5, 12)
		_unit(game, 1, 3, 3)
		_unit(game, 1, 3, 3)
		assert_gte(_power(game, _declared(game, _foe_ai(boss))), 5, "%s swings for lethal" % boss)


func test_lethal_through_exhausted_blockers_is_taken() -> void:
	for boss: String in BOSSES:
		var game: GameState = _board(6, 4)
		_unit(game, 1, 4, 2)
		_unit(game, 1, 2, 2)
		_unit(game, 0, 5, 5, true)  # the player's big unit attacked last turn: it can't block
		_unit(game, 0, 3, 3, true)
		assert_gte(_power(game, _declared(game, _foe_ai(boss))), 6, "%s does not hold back at 4 HP when the swing wins" % boss)


func test_lethal_past_one_small_blocker_is_taken() -> void:
	for boss: String in BOSSES:
		var game: GameState = _board(5, 10)
		_unit(game, 1, 3, 4)
		_unit(game, 1, 3, 4)
		_unit(game, 1, 3, 4)
		_unit(game, 0, 1, 1)
		var sent: Array[int] = _declared(game, _foe_ai(boss))
		assert_eq(sent.size(), 3, "%s: three 3/4s against one 1/1 and 5 HP - everyone attacks (a chump still lets 6 through)" % boss)


func test_a_big_lead_presses_the_attack() -> void:
	for boss: String in BOSSES:
		var game: GameState = _board(8, 15)
		_unit(game, 1, 4, 5)
		_unit(game, 1, 3, 4)
		_unit(game, 0, 1, 2, true)
		var sent: Array[int] = _declared(game, _foe_ai(boss))
		assert_eq(sent.size(), 2, "%s: no ready blocker, no real crack-back - both attack" % boss)


func test_the_starting_weenie_does_not_scare_the_colonel_off_attacking() -> void:
	# The Colonel's own token with Fresh Stitches must not stop the units that CAN attack.
	var game: GameState = _board(4, 12)
	var weenie: CardInstance = game.create_token(1, TokenRegistry.data("T-03"))
	assert_true(weenie.fresh_stitches)
	_unit(game, 1, 4, 3)
	var sent: Array[int] = _declared(game, _foe_ai("Colonel Casserole"))
	assert_false(sent.has(weenie.uid), "a unit with Fresh Stitches is never declared")
	assert_gte(_power(game, sent), 4, "the ready 4/3 swings for lethal")


func test_a_clock_starved_search_still_weighs_a_real_attack() -> void:
	# The live game's attack search has a wall-clock budget. Out of time from the start, the old search scored only "no attack" and held back.
	var game: GameState = _board(5, 12)
	var big: CardInstance = _unit(game, 1, 4, 5)
	var mid: CardInstance = _unit(game, 1, 3, 4)
	_unit(game, 0, 2, 2)
	var ai: AIPlayer = _foe_ai("Colonel Casserole")
	while game.combat_step != GameState.CombatStep.DECLARE_ATTACKERS:
		game.advance_phase()
	var spent: AISearchBudget = AISearchBudget.make(280, 0)
	spent.deadline_usec = 1  # long past
	var sent: Array[int] = ai._combat.choose_attackers(game, 1, spent, 20)
	assert_gte(ai._combat.last_ranked.size(), 3, "several candidates were scored")
	assert_true(sent.has(big.uid) or sent.has(mid.uid), "the Colonel attacks even when the clock runs out at once")
