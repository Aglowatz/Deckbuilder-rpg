extends GutTest
## Fix pass Nov 7, Part 4: losing costs nothing (owner decision D1), a dungeon run starts over (D2), and Primm's presentation (item 10):
## Standardization on the player's side, Mirrors never copying Infrastructure, Setting Up in rounds.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func after_each() -> void:
	Session.save_enabled = true


func test_waking_at_a_zone_hub_costs_nothing() -> void:
	var run: ZoneRun = Session.begin_zone_visit(GainlandsZone.ID)
	run.run.hp = 0
	var gold: int = Session.gold
	assert_eq(Session.zone_wake_at_hub("a test"), 0, "no fee")
	assert_eq(Session.gold, gold, "no gold taken")
	assert_eq(run.run.hp, run.run.max_hp(), "full HP")


func test_standardization_sets_the_base_on_both_sides_and_buffs_still_add() -> void:
	# Answer to C4c F6: the rule applies to the player's units too (base 3/3); the 7/4 and 6/4 the critic saw were 3/3 plus buffs
	# (boons, gear, Iron), as the rule text says.
	var game: GameState = GameFactory.new_game(4)
	game.players[1].modifiers.modifiers.append(CardBuilder.modifier(Modifier.Kind.STANDARDIZE_UNITS, 3, Modifier.ANY_COLOR, 3))
	var big: CardInstance = game.create_instance(GameFactory.vanilla(7, 4), 0)
	assert_eq(game.get_attack(big), 3, "the player's printed 7/4 becomes 3")
	assert_eq(game.get_defense(big), 3)
	big.attack_bonus = 4
	big.defense_bonus = 1
	assert_eq(game.get_attack(big), 7, "a +4/+1 buff on top reads 7/4")
	assert_eq(game.get_defense(big), 4)


func test_standardization_through_primms_real_seat() -> void:
	var enemy: PlayerSetup = PrimmBoss.enemy_setup(Session.content, 0, Session.deck)
	var opts: GameOptions = GameOptions.new()
	opts.rng_seed = 9
	var game: GameState = GameState.new(opts)
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), null, [], "P0"))
	game.add_player(enemy)
	game.start()
	var big: CardInstance = game.create_instance(GameFactory.vanilla(6, 4), 0)
	assert_eq(game.get_attack(big), PrimmBoss.STANDARD_ATTACK, "the player's unit is standardized through the real seat")
	assert_eq(game.get_defense(big), PrimmBoss.STANDARD_DEFENSE)
