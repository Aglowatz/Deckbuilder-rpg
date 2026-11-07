extends GutTest
## Overnight Nov 4-5, Part 8 (docs/review/fresh_eyes_early_nov5.md): the fresh critic's quick fixes - a lost tutorial-cave fight is retried
## on the spot, the cave's 3-HP foes show a full bar, the battle counts rounds, the well's confirm key leaves, the shrine's rests.


func before_each() -> void:
	Session.new_game()
	Session.ensure_game()


func test_a_lost_cave_fight_sends_the_hero_back_to_the_forest() -> void:
	# Fix pass Nov 7 (owner decision D1): replaces the retry in place - a cave loss respawns in the forest clearing and the cave starts over.
	Session.set_flag(&"trial_cleared", false)  # a brand-new save, still in the intro trial
	Session.begin_trial()
	var gold_before: int = Session.gold
	var node: DungeonMap.MapNode = Session.dungeon_map.nodes[1]
	var context: BattleContext = Session.make_dungeon_battle(node)
	assert_false(Session.tutorial_retry_on_loss(), "no retry in place any more")
	context.game.players[0].hp = 0
	context.game.winner = 1
	context.won = false
	Session.complete_battle(context)
	assert_null(Session.run, "the cave starts over")
	assert_eq(Session.gold, gold_before, "losing costs nothing")


func test_a_loss_after_the_cave_still_ends_the_run() -> void:
	Session.set_flag(&"trial_cleared")
	Session.begin_trial()
	assert_false(Session.tutorial_retry_on_loss(), "only the intro trial")


func test_the_caves_three_hp_foes_have_a_full_bar() -> void:
	var map: DungeonMap = TrialOfTheHollow.build_map()
	for node: DungeonMap.MapNode in map.nodes:
		if node.enemy_hp <= 0:
			continue
		var game: GameState = GameState.new()
		var player: PlayerState = game.add_player(TrialOfTheHollow.enemy_setup(Session.content, node))
		assert_eq(player.hp, node.enemy_hp, node.enemy_name)
		assert_eq(player.max_hp, node.enemy_hp, "%s: the bar is full" % node.enemy_name)


func test_the_battle_counts_rounds() -> void:
	assert_eq(BattleHud.round_of(1), 1)
	assert_eq(BattleHud.round_of(2), 1)
	assert_eq(BattleHud.round_of(3), 2, "the player's second turn is Round 2")
	assert_eq(BattleHud.round_of(12), 6)
	assert_eq(BattleHud.round_of(0), 1)


func test_the_well_confirm_key_leaves_and_the_shrine_rests() -> void:
	var well: String = FileAccess.get_file_as_string("res://ui/dungeon/challenge_screen.gd")
	assert_true(well.contains("_leave_button if _leave_button != null and _leave_button.visible else _reveal_button"), "E leaves the well untested")
	var shrine: String = FileAccess.get_file_as_string("res://ui/dungeon/shrine_screen.gd")
	assert_true(shrine.contains("ConfirmKey.attach(panel, _button)"), "E / Space press Rest")
