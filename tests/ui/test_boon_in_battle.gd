extends GutTest
## Fixes Oct 27, Part 4: in a real battle screen of a run that took Cut the Line, a unit of yours shows its attack 1 higher (green), the enemy's does
## not, and the run's badge row explains the boon in words.

var _screen: BattleScreen


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.NECROCRAT)


func after_each() -> void:
	Session.pending_battle = null
	Session.save_enabled = true


func _until(condition: Callable, limit: float) -> bool:
	var waited: float = 0.0
	while waited < limit:
		if bool(condition.call()):
			return true
		await get_tree().process_frame
		waited += get_process_delta_time()
	return bool(condition.call())


func test_cut_the_line_shows_on_your_units_attack_and_in_the_badges() -> void:
	var run: DungeonRun = DungeonRun.enter(Session.profile, Session.deck)
	run.add_dungeon_source(DungeonBuilder.boon_from("Cut the Line|atk=1"))
	var context: BattleContext = BattleContext.new()
	context.game = run.start_encounter(PlayerSetup.create(GameFactory.make_deck()))
	context.ai = AIPlayer.new(AIPersonality.balanced())
	context.enemy_name = "Boon Check"
	context.practice = true
	context.rule_badges = RuleBadges.for_boons(run.dungeon_sources)
	Session.pending_battle = context
	_screen = (load("res://scenes/battle.tscn") as PackedScene).instantiate() as BattleScreen
	_screen.screenshot_prepare({"no_tutorial": "true", "no_intro": "true", "fast": "true"})
	add_child_autofree(_screen)
	await _until(func() -> bool: return _screen.mode == BattleScreen.Mode.MULLIGAN, 8.0)
	_screen._mulligan_choice(true)
	await _until(func() -> bool: return _screen.mode == BattleScreen.Mode.MAIN and not _screen.busy, 10.0)
	var game: GameState = _screen.game
	var mine: CardInstance = game.create_token(0, CardBuilder.token("boon_probe", "Probe", 2, 3))
	var theirs: CardInstance = game.create_token(1, CardBuilder.token("boon_probe_foe", "Foe Probe", 2, 3))
	_screen._play_new_events()  # the screen plays new game events after an action of its own
	await _until(func() -> bool: return _screen.board.view_for(mine.uid) != null and not _screen.busy, 5.0)
	_screen.board.refresh_all()
	await get_tree().process_frame
	assert_eq(game.get_attack(mine), 3, "2 + the boon's 1")
	assert_eq(game.get_attack(theirs), 2, "the boon is yours only")
	var view: CardView = _screen.board.view_for(mine.uid)
	assert_not_null(view, "the unit is on the board")
	if view != null:
		assert_eq(view._attack_label.text, "3/3", "the board shows the boosted attack (a 2/3 unit reads 3/3)")
	var texts: PackedStringArray = []
	for badge: RuleBadges.Badge in context.rule_badges:
		texts.append(badge.tooltip())
	assert_true("\n".join(texts).contains("Your units get +1 attack for the rest of this run."), "\n".join(texts))
