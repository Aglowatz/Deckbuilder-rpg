extends GutTest
## v0.4.2 hotfix: the arrival in Crosspath out of the Forgotten Cave. Everything it shows runs as one queue (reward box -> level-ups -> the Path
## warning -> Maren's welcome), one modal at a time, and the hero is always freed at the end - or by the lock watchdog when a step never closes.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.choose_starting_path(Affinity.Type.BEEFCAKE)
	Session.complete_trial()


func after_each() -> void:
	Session.cave_exit_pending = false
	Session.pending_level_ups.clear()
	Session.pending_popups.clear()
	Session.pending_storeroom_result = {}


func _town() -> TownScene:
	var scene: TownScene = (load("res://scenes/town.tscn") as PackedScene).instantiate() as TownScene
	add_child_autofree(scene)
	return scene


func _frames(count: int) -> void:
	for _frame: int in range(count):
		await get_tree().process_frame


## Presses the open conversation to its end (the typewriter first, then each line).
func _press_through(town: TownScene) -> void:
	var guard: int = 0
	while town.dialogue.active and guard < 80:
		guard += 1
		town.dialogue.press()
	await _frames(2)


func _overlay_kind(town: TownScene) -> String:
	if town._overlay == null or not is_instance_valid(town._overlay):
		return ""
	return str((town._overlay.get_script() as Script).get_global_name())


func test_a_level_up_a_quest_box_and_the_path_warning_show_one_at_a_time_then_the_welcome_and_the_hero_is_freed() -> void:
	var summary: RewardSummary = RewardSummary.new()
	summary.title = "Quest Complete"
	summary.gold = 10
	Session.pending_popups.append(summary)
	Session.pending_level_ups.append_array(Session.add_xp(600))
	assert_gt(Session.pending_level_ups.size(), 0, "level-ups are waiting")
	Session.new_saved_deck("Two Paths", ["BAS-B", "BAS-B", "BAS-N", "BAS-N"] as Array[String])
	# A fight's leftover result conversation (it opened under the arrival's screens once): it waits for the end of the queue.
	Session.pending_storeroom_result = {"won": false}
	Session.cave_exit_pending = true
	var town: TownScene = _town()
	assert_true(town._locked, "the hero is held from the first frame")
	await _frames(3)
	assert_true(town.arrival_active, "the arrival queue runs")
	# 1. The level-ups alone (overnight Oct 20: level-ups first).
	assert_eq(_overlay_kind(town), "LevelUpScreen", "the level-ups come first")
	assert_false(town.dialogue.active, "no welcome under the level-ups")
	assert_eq(Session.pending_level_ups.size(), 0, "the level-ups were taken by the queue (not shown twice)")
	var level_up: LevelUpScreen = town._overlay as LevelUpScreen
	level_up._age = LevelUpScreen.GUARD_TIME  # past the screen's own guard against a click carried over
	level_up.skip_all()
	await _frames(3)
	assert_true(town._locked, "the hero stays put between steps")
	# 2. The quest box alone (no dialogue under it).
	assert_eq(_overlay_kind(town), "RewardPopup", "then the reward box")
	assert_false(town.dialogue.active, "no welcome under the reward box")
	(town._overlay as RewardPopup)._on_confirmed()
	await _frames(3)
	# 3. The Path warning toast, then Maren's welcome in its three parts.
	assert_true(town.dialogue.active and town.dialogue.npc_id == "NPC-ELDER", "Maren's welcome opens after the screens")
	await _press_through(town)
	assert_true(town.dialogue.active, "the Wanderer answers")
	await _press_through(town)
	assert_true(town.dialogue.active and town.dialogue.npc_id == "NPC-ELDER", "Maren closes")
	assert_true(town._locked, "still held during the welcome")
	await _press_through(town)
	await _frames(2)
	assert_eq(town.arrival_log, ["level_ups", "rewards", "path_warning", "welcome_maren", "welcome_wanderer", "welcome_maren_end"] as Array[String], "every step, in order")
	assert_false(town.arrival_active, "the queue is done")
	assert_false(town._locked, "the hero is free")
	assert_true(Session.flag(&"maren_met"), "maren_met is set")
	await _frames(2)
	assert_true(town.dialogue.active, "the waiting result conversation opens after the arrival")
	await _press_through(town)
	await _frames(2)
	assert_true(town.player.input_enabled, "the hero takes input")
	assert_eq(town.lock_watchdog_trips, 0, "the watchdog never had to step in")


func test_hotkeys_and_popups_wait_while_the_arrival_is_pending() -> void:
	Session.pending_level_ups.append_array(Session.add_xp(600))
	Session.cave_exit_pending = true
	var town: TownScene = _town()
	SceneManager.busy = true  # the fade is still up: the queue waits for the reveal
	await _frames(3)
	assert_true(town.arrival_pending and not town.arrival_active, "still waiting for the fade-in")
	assert_null(town._overlay, "no level-up screen opens behind the fade")
	assert_false(town.player.input_enabled, "the hero is held")
	SceneManager.busy = false
	await _frames(3)
	assert_true(town.arrival_active, "the queue starts once the scene manager is idle, even without the revealed signal")
	assert_eq(_overlay_kind(town), "LevelUpScreen")


func test_the_watchdog_frees_a_hero_locked_with_nothing_open() -> void:
	var town: TownScene = _town()
	await _frames(2)
	town._locked = true
	town._watch_lock(TownScene.LOCK_WATCHDOG_SECONDS - 0.5)
	assert_true(town._locked, "not before the watchdog time")
	town._watch_lock(1.0)
	assert_false(town._locked, "freed after the watchdog time")
	assert_eq(town.lock_watchdog_trips, 1)
	assert_push_warning("locked for")


func test_the_watchdog_leaves_an_open_conversation_alone() -> void:
	var town: TownScene = _town()
	await _frames(2)
	town._locked = true
	town.dialogue.start("Elder Maren", ["Take your time."] as Array[String], "NPC-ELDER")
	town._watch_lock(TownScene.LOCK_WATCHDOG_SECONDS * 3.0)
	assert_true(town._locked, "a conversation on screen is a reason to be held")
	assert_eq(town.lock_watchdog_trips, 0)


func test_the_watchdog_ends_an_arrival_whose_step_vanished() -> void:
	Session.cave_exit_pending = true
	var town: TownScene = _town()
	await _frames(3)
	assert_true(town.arrival_active and town.dialogue.active, "the welcome is up")
	# The conversation disappears without reporting back (the old freeze's shape).
	town.dialogue.active = false
	town._watch_lock(TownScene.LOCK_WATCHDOG_SECONDS + 0.5)
	assert_false(town._locked, "the hero is free")
	assert_false(town.arrival_active, "the queue is closed")
	assert_true(Session.flag(&"maren_met"), "maren_met is set, so Maren's door greeting follows")
	assert_push_warning("locked for")


func test_a_second_conversation_replacing_the_welcome_still_moves_the_queue_on() -> void:
	Session.cave_exit_pending = true
	var town: TownScene = _town()
	await _frames(3)
	assert_eq(town.arrival_log, ["welcome_maren"] as Array[String])
	town.dialogue.start("Sable", ["Psst."] as Array[String])
	await _frames(3)
	assert_eq(town.arrival_log, ["welcome_maren", "welcome_wanderer"] as Array[String], "the interrupted step counts as closed")
	await _press_through(town)
	await _press_through(town)
	await _frames(2)
	assert_false(town._locked, "the hero is free at the end")


func test_continue_from_a_save_made_inside_the_cave_then_the_arrival() -> void:
	Session.new_game()
	Session.choose_starting_path(Affinity.Type.NECROCRAT)
	Session.dungeon_map = TrialOfTheHollow.build_map()
	Session.run = DungeonRun.enter(Session.profile, Session.deck, [] as Array[ModifierSource])
	var saved: Dictionary = Session.to_dict()
	Session.new_game()
	assert_true(Session.from_dict(saved), "the cave save loads")
	assert_false(Session.flag(&"trial_cleared"), "the cave is not cleared yet (Continue resumes in the forest, back through the gate)")
	assert_eq(Session.profile.primary_affinity, Affinity.Type.NECROCRAT, "the Path is kept")
	Session.dungeon_map = TrialOfTheHollow.build_map()
	Session.run = DungeonRun.enter(Session.profile, Session.deck, [] as Array[ModifierSource])
	Session.complete_trial()
	Session.cave_exit_pending = true
	var town: TownScene = _town()
	await _frames(3)
	assert_true(town.arrival_active and town.dialogue.active, "the welcome opens after a Continue too")
	for _part: int in range(3):
		await _press_through(town)
	await _frames(2)
	assert_false(town._locked, "the hero is free")
	assert_eq(town.lock_watchdog_trips, 0)


func test_a_warm_up_screen_that_dies_mid_build_does_not_leave_the_game_deaf() -> void:
	var warmup: UiArtWarmup = UiArtWarmup.make()
	add_child_autofree(warmup)
	await _frames(1)
	# The state a failed screen build leaves behind: input off, the warmup never stepping on.
	get_viewport().gui_disable_input = true
	warmup._input_off = true
	warmup._last_step_frame = Engine.get_process_frames()
	await _frames(UiArtWarmup.STALL_FRAMES + 3)
	assert_false(get_viewport().gui_disable_input, "input is back on")
	assert_true(warmup.screens_done(), "and the loading screen stops waiting for it")
	assert_push_warning("never finished")
