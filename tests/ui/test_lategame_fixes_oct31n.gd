extends GutTest
## Overnight Oct 31 - Nov 1, Part 6: the late-game critic's fix-now items (docs/review/fresh_eyes_lategame_oct31n_triage.md).


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func test_a_cutscene_keeps_running_and_blocks_the_pause_menu_while_up() -> void:
	SceneManager.pause_allowed = true
	var first: CutsceneScreen = CutsceneScreen.make("primm_intro")
	add_child(first)
	await wait_frames(1)
	assert_eq(first.process_mode, Node.PROCESS_MODE_ALWAYS, "a stray pause cannot freeze the scene")
	assert_false(SceneManager.pause_allowed, "Esc belongs to the scene, not the pause menu")
	var second: CutsceneScreen = CutsceneScreen.make("primm_intro")
	add_child(second)
	await wait_frames(1)
	first.queue_free()
	await wait_frames(2)
	assert_false(SceneManager.pause_allowed, "still blocked while the next scene is up")
	second.queue_free()
	await wait_frames(2)
	assert_true(SceneManager.pause_allowed, "the map's pause comes back after the last scene")


func test_the_capital_battle_panel_reads_the_real_services() -> void:
	var source: String = FileAccess.get_file_as_string("res://ui/battle/battle_screen.gd")
	assert_true(source.contains("hud.set_capital_panels(Session.flags, context.rules_text)"), "not {} (that read as every service broken)")
	var all_freed: Dictionary = {}
	for zone_id: String in [GainlandsZone.ID, DnaZone.ID, BuffetZone.ID, HeapZone.ID]:
		all_freed[str(ZoneCompletion.flag_name(zone_id))] = true
	assert_eq(CapitalDebuffs.active(all_freed).size(), 0, "four freed zones: nothing broken")


func test_the_defeat_line_only_mentions_a_dungeon_inside_one() -> void:
	var source: String = FileAccess.get_file_as_string("res://ui/battle/battle_screen.gd")
	assert_true(source.contains("\"You are carried out of the dungeon.\" if Session.run != null else"))
