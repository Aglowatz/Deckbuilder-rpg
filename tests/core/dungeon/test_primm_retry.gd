extends GutTest
## Fable Nov 12c (A9): a loss to Primm in any phase offers "Fight Primm again" (from the very start of Phase 1, full HP, the freed
## leaders' boons as on a normal arrival at his room, the castle's earlier rooms not replayed) or "Leave the castle".


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	for zone_id: String in Gatekeepers.IDS:
		Session.set_flag(ZoneCompletion.flag_name(zone_id))
	Session.zone_run = ZoneRun.enter(CapitalZone.ID, Session.profile, Session.deck)
	Session.dungeon_key = CapitalZone.ID
	Session.dungeon_map = MainDungeons.build_map(CapitalZone.ID)
	Session.run = DungeonRun.enter(Session.profile, Session.deck, Session.zone_run.run.dungeon_sources)
	Session.main_dungeon_active = true
	Session.boss_phase = 0
	Session.boss_phase_pending = false
	Session.boss_boons_given = false


func after_all() -> void:
	Session.new_game()


func _lost(phase: int) -> BattleContext:
	var context: BattleContext = BattleContext.new()
	context.boss_phase = phase
	context.won = false
	context.enemy_name = PrimmBoss.BOSS_FOE
	return context


func _boons() -> int:
	var count: int = 0
	for source: ModifierSource in Session.run.dungeon_sources:
		if source.source_kind == ModifierSource.SourceKind.BOON:
			count += 1
	return count


func test_only_a_lost_fight_against_him_can_be_retried() -> void:
	assert_true(Session.can_retry_primm(_lost(0)))
	assert_true(Session.can_retry_primm(_lost(1)))
	assert_true(Session.can_retry_primm(_lost(2)), "any phase")
	var won: BattleContext = _lost(2)
	won.won = true
	assert_false(Session.can_retry_primm(won), "a win is not retried")
	assert_false(Session.can_retry_primm(_lost(-1)), "another foe of the castle: the dungeon's normal rule")
	var practice: BattleContext = _lost(1)
	practice.practice = true
	assert_false(Session.can_retry_primm(practice))
	Session.main_dungeon_active = false
	assert_false(Session.can_retry_primm(_lost(1)), "not outside a castle run")


func test_fight_again_starts_phase_one_at_full_hp_with_the_leaders_boons() -> void:
	# a normal arrival at his room: the four freed leaders each lend a boon
	Session.begin_primm_fight()
	var boons: int = _boons()
	assert_gt(boons, 0, "the freed leaders lent their boons")
	var full: int = Session.run.max_hp()
	# two rooms of the castle were cleared on the way
	var cleared: Array[int] = []
	for step: int in range(2):
		var next: DungeonMap.MapNode = Session.dungeon_map.available()[0]
		Session.dungeon_map.complete(next.id)
		cleared.append(next.id)
	# ... and he wins in Phase 3
	Session.boss_phase = 2
	Session.run.hp = 0
	Session.run.failed = true
	assert_true(Session.prepare_primm_retry(_lost(2)))
	assert_eq(Session.boss_phase, 0, "the very beginning of Phase 1")
	assert_false(Session.boss_phase_pending)
	assert_false(Session.run.failed, "the run goes on")
	assert_eq(Session.run.hp, full, "full HP")
	assert_eq(Session.run.max_hp(), full, "the boons' max HP is neither lost nor doubled")
	assert_eq(_boons(), boons, "the leaders' boons as on a normal arrival: not given twice")
	for id: int in cleared:
		assert_true(Session.dungeon_map.is_cleared(id), "the castle's earlier rooms are not replayed")
	var again: BattleContext = Session.make_dungeon_battle(Session.dungeon_map.boss())
	assert_eq(again.boss_phase, 0, "the duel that starts is Phase 1")
	assert_eq(again.game.players[0].hp, full, "and the hero walks in with full HP")


func test_fight_again_gives_the_boons_if_the_run_never_had_them() -> void:
	# (a dev jump straight into a phase skips the leaders' scene)
	assert_eq(_boons(), 0)
	assert_true(Session.prepare_primm_retry(_lost(1)))
	assert_gt(_boons(), 0, "given now, once")
	var boons: int = _boons()
	assert_true(Session.prepare_primm_retry(_lost(0)))
	assert_eq(_boons(), boons, "a second retry does not stack them")
	assert_eq(Session.run.hp, Session.run.max_hp())


func test_nothing_happens_without_a_lost_fight() -> void:
	Session.boss_phase = 1
	var won: BattleContext = _lost(1)
	won.won = true
	assert_false(Session.prepare_primm_retry(won))
	assert_eq(Session.boss_phase, 1)


func test_the_defeat_screen_words() -> void:
	assert_eq(BattleScreen.primm_retry_label(), "Fight %s again" % Villain.display_name())
	assert_eq(BattleScreen.PRIMM_LEAVE_LABEL, "Leave the castle")
	var text: String = BattleScreen.primm_defeat_text()
	assert_string_contains(text, "the beginning of Phase 1")
	assert_string_contains(text, "your HP full")
	assert_string_contains(text, "boons")
	assert_string_contains(text, "earlier rooms are not replayed")
	assert_string_contains(text, "Leave the castle: you are carried out")
	var source: String = FileAccess.get_file_as_string("res://ui/battle/battle_screen.gd")
	assert_true(source.contains("again.pressed.connect(_retry_primm)"), "the first button fights again")
	assert_true(source.contains("leave.pressed.connect(_continue)"), "the second is the normal dungeon leave")
