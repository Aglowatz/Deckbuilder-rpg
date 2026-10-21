extends GutTest
## Overnight Oct 20 (playtest stability, v0.4.3): the iGPU default preset, the crash-safe start (BootGuard), the SceneManager transition
## watchdog, Esc during a transition, Continue from a save stuck before Maren's welcome, the game log's heartbeat.

const BOOT_PATH: String = "user://test_boot_state.cfg"

var _boot_path_before: String = ""
var _boot_active_before: bool = true


func before_each() -> void:
	_boot_path_before = BootGuard.path
	_boot_active_before = BootGuard.active
	BootGuard.path = BOOT_PATH
	BootGuard.active = true
	DirAccess.remove_absolute(ProjectSettings.globalize_path(BOOT_PATH))


func after_each() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(BOOT_PATH))
	BootGuard.path = _boot_path_before
	BootGuard.active = _boot_active_before
	SceneManager.busy = false
	SceneManager.phase = ""
	Session.cave_exit_pending = false
	Session.new_game()  # the next test file starts with no hero (ensure_game keeps an existing one)


# ---- GPU kind and the default preset -------------------------------------------------------------------------------------------------


func test_testers_intel_gpus_are_integrated_even_when_d3d12_says_discrete() -> void:
	var discrete: int = RenderingDevice.DEVICE_TYPE_DISCRETE_GPU
	assert_eq(GpuInfo.classify("Intel(R) Arc(TM) 130V GPU (8GB)", "Intel", discrete), GpuInfo.Kind.INTEGRATED, "tester 1 (Lunar Lake)")
	assert_eq(GpuInfo.classify("Intel(R) Iris(R) Xe Graphics", "Intel", discrete), GpuInfo.Kind.INTEGRATED, "tester 2")
	assert_eq(GpuInfo.classify("AMD Radeon(TM) Graphics", "AMD", discrete), GpuInfo.Kind.INTEGRATED, "the dev PC's iGPU, which D3D12 reports as discrete")
	assert_eq(GpuInfo.classify("Intel(R) UHD Graphics 620", "Intel", discrete), GpuInfo.Kind.INTEGRATED_LOW, "an older Intel iGPU")
	assert_eq(GpuInfo.classify("AMD Radeon 780M Graphics", "AMD", discrete), GpuInfo.Kind.INTEGRATED, "an APU by model")


func test_real_cards_stay_discrete() -> void:
	var discrete: int = RenderingDevice.DEVICE_TYPE_DISCRETE_GPU
	assert_eq(GpuInfo.classify("Intel(R) Arc(TM) A770 Graphics", "Intel", discrete), GpuInfo.Kind.DISCRETE)
	assert_eq(GpuInfo.classify("Intel(R) Arc(TM) B580 Graphics", "Intel", discrete), GpuInfo.Kind.DISCRETE)
	assert_eq(GpuInfo.classify("AMD Radeon RX 6600", "AMD", discrete), GpuInfo.Kind.DISCRETE)
	assert_eq(GpuInfo.classify("NVIDIA GeForce RTX 3060", "NVIDIA", discrete), GpuInfo.Kind.DISCRETE)
	assert_eq(GpuInfo.classify("Microsoft Basic Render Driver", "Microsoft", discrete), GpuInfo.Kind.CPU)


func test_integrated_gpus_never_start_on_high() -> void:
	assert_eq(GpuInfo.recommended_level(GpuInfo.Kind.INTEGRATED), GraphicsQuality.Level.MEDIUM)
	assert_eq(GpuInfo.recommended_level(GpuInfo.Kind.INTEGRATED_LOW), GraphicsQuality.Level.LOW)
	assert_eq(GpuInfo.recommended_level(GpuInfo.Kind.CPU), GraphicsQuality.Level.LOW)
	assert_eq(GpuInfo.recommended_level(GpuInfo.Kind.UNKNOWN), GraphicsQuality.Level.MEDIUM)
	assert_eq(GpuInfo.recommended_level(GpuInfo.Kind.DISCRETE), GraphicsQuality.Level.HIGH)


func test_old_settings_with_high_on_an_igpu_drop_to_medium_once() -> void:
	var high: int = GraphicsQuality.Level.HIGH
	assert_eq(Settings.migrated_quality(high, 1, GpuInfo.Kind.INTEGRATED), GraphicsQuality.Level.MEDIUM, "v0.4.0's misreported High")
	assert_eq(Settings.migrated_quality(high, Settings.SETTINGS_VERSION, GpuInfo.Kind.INTEGRATED), high, "chosen again in v0.4.3: kept")
	assert_eq(Settings.migrated_quality(high, 1, GpuInfo.Kind.DISCRETE), high, "a real card keeps High")
	assert_eq(Settings.migrated_quality(GraphicsQuality.Level.LOW, 1, GpuInfo.Kind.INTEGRATED), GraphicsQuality.Level.LOW, "a lower choice is kept")


func test_intel_igpus_keep_the_heavy_high_passes_off() -> void:
	var discrete: int = RenderingDevice.DEVICE_TYPE_DISCRETE_GPU
	assert_true(GpuInfo.is_intel_integrated("Intel(R) Iris(R) Xe Graphics", "Intel", discrete))
	assert_false(GpuInfo.is_intel_integrated("Intel(R) Arc(TM) A770 Graphics", "Intel", discrete), "a discrete Arc card")
	assert_false(GpuInfo.is_intel_integrated("AMD Radeon(TM) Graphics", "AMD", discrete))
	var before: bool = GraphicsQuality.heavy_passes_allowed
	GraphicsQuality.heavy_passes_allowed = false
	var high: int = GraphicsQuality.Level.HIGH
	assert_false(GraphicsQuality.volumetric_fog(high))
	assert_false(GraphicsQuality.ssao(high))
	assert_eq(GraphicsQuality.msaa(high), Viewport.MSAA_DISABLED)
	assert_true(GraphicsQuality.fxaa(high), "FXAA instead of MSAA")
	GraphicsQuality.heavy_passes_allowed = true
	assert_true(GraphicsQuality.volumetric_fog(high))
	assert_false(GraphicsQuality.fxaa(high))
	GraphicsQuality.heavy_passes_allowed = before


func test_safe_mode_settings_are_the_lightest() -> void:
	var before: Array = [Settings.graphics_quality, Settings.fog_quality, Settings.bloom, Settings.depth_of_field]
	Settings.apply_safe_mode()
	assert_eq(Settings.graphics_quality, GraphicsQuality.Level.LOW)
	assert_eq(Settings.fog_quality, 0)
	assert_false(Settings.bloom)
	assert_false(Settings.depth_of_field)
	assert_false(GraphicsQuality.volumetric_fog(Settings.graphics_quality))
	assert_false(GraphicsQuality.ssao(Settings.graphics_quality))
	assert_eq(GraphicsQuality.msaa(Settings.graphics_quality), Viewport.MSAA_DISABLED)
	Settings.graphics_quality = int(before[0])
	Settings.fog_quality = int(before[1])
	Settings.bloom = bool(before[2])
	Settings.depth_of_field = bool(before[3])


# ---- Crash-safe start ----------------------------------------------------------------------------------------------------------------


func test_a_clean_run_starts_normally() -> void:
	var first: Dictionary = BootGuard.begin_launch(PackedStringArray())
	assert_eq(str(first["safe_mode_reason"]), "", "first launch")
	BootGuard.set_stage("title")
	BootGuard.set_stage("loading town")
	BootGuard.set_stage("playing town")
	BootGuard.set_stage("exit")
	var second: Dictionary = BootGuard.begin_launch(PackedStringArray())
	assert_eq(str(second["previous_stage"]), "exit")
	assert_eq(str(second["safe_mode_reason"]), "", "a clean exit")


func test_a_crash_while_loading_or_starting_means_safe_mode_next() -> void:
	BootGuard.begin_launch(PackedStringArray())
	BootGuard.set_stage("title")
	BootGuard.set_stage("loading starting_area")  # tester 2: the crash before the intro
	var next: Dictionary = BootGuard.begin_launch(PackedStringArray())
	assert_ne(str(next["safe_mode_reason"]), "", "Safe Mode after a crash during a load")
	assert_eq(int(next["bad_in_a_row"]), 1)
	assert_eq(str(next["other_driver"]), "", "one bad launch keeps the driver")
	var again: Dictionary = BootGuard.begin_launch(PackedStringArray())  # died while "starting" (before the title)
	assert_ne(str(again["safe_mode_reason"]), "")
	assert_eq(int(again["bad_in_a_row"]), 2)
	assert_true(["vulkan", "d3d12"].has(str(again["other_driver"])) or RenderingServer.get_current_rendering_driver_name().is_empty(),
		"two in a row try the other driver")


func test_a_stall_counts_as_a_bad_end_and_resuming_clears_it() -> void:
	BootGuard.begin_launch(PackedStringArray())
	BootGuard.set_stage("playing town")
	BootGuard.set_stage("stalled (load: town)")
	assert_true(BootGuard.is_bad_end(BootGuard.stage()))
	BootGuard.restore_stage()
	assert_eq(BootGuard.stage(), "playing town", "the main thread came back")
	BootGuard.set_stage("stalled (gpu: screenshot readback)")
	var next: Dictionary = BootGuard.begin_launch(PackedStringArray())
	assert_ne(str(next["safe_mode_reason"]), "", "a launch that ended stalled (the tester closed a frozen game)")


func test_the_safe_mode_launcher_argument() -> void:
	var launch: Dictionary = BootGuard.begin_launch(PackedStringArray([BootGuard.SAFE_MODE_ARG]))
	assert_string_contains(str(launch["safe_mode_reason"]), "Safe Mode launcher")


func test_playing_resets_the_bad_count() -> void:
	BootGuard.begin_launch(PackedStringArray())
	var bad: Dictionary = BootGuard.begin_launch(PackedStringArray())
	assert_eq(int(bad["bad_in_a_row"]), 1)
	BootGuard.set_stage("playing town")
	BootGuard.set_stage("loading battle")
	var next: Dictionary = BootGuard.begin_launch(PackedStringArray())
	assert_eq(int(next["bad_in_a_row"]), 1, "counted from the last playable moment")


# ---- SceneManager watchdog and Esc ---------------------------------------------------------------------------------------------------


func test_a_transition_without_progress_is_ended_by_the_watchdog() -> void:
	var trips: int = SceneManager.watchdog_trips
	watch_signals(SceneManager)
	SceneManager.busy = true
	SceneManager._busy_since_usec = Time.get_ticks_usec()
	LoadTiming._last_usec = -(1 << 62)  # no load step counts as progress (the engine may have run under 31 s)
	SceneManager._target = "stuck_test"
	SceneManager._set_phase("settle")
	SceneManager._progress_usec = Time.get_ticks_usec() - int((SceneManager.STUCK_SECONDS + 1.0) * 1000000.0)
	SceneManager._watch_transition()
	assert_false(SceneManager.busy, "no longer busy")
	assert_eq(SceneManager.watchdog_trips, trips + 1)
	assert_signal_emitted(SceneManager, "revealed", "whatever waited for the reveal still runs")
	assert_eq(SceneManager._fade.mouse_filter, Control.MOUSE_FILTER_IGNORE, "the cover no longer eats input")
	assert_almost_eq(SceneManager._fade.modulate.a, 0.0, 0.001, "the cover is gone")


func test_a_building_scene_gets_longer_but_not_for_ever() -> void:
	SceneManager.busy = true
	SceneManager._busy_since_usec = Time.get_ticks_usec()
	LoadTiming._last_usec = -(1 << 62)  # no load step counts as progress (the engine may have run under 31 s)
	SceneManager._target = "slow_build_test"
	SceneManager._set_phase("build")
	SceneManager._progress_usec = Time.get_ticks_usec() - int((SceneManager.STUCK_SECONDS + 1.0) * 1000000.0)
	SceneManager._watch_transition()
	assert_true(SceneManager.busy, "a build may go quiet for longer than a fade")
	SceneManager._progress_usec = Time.get_ticks_usec() - int((SceneManager.BUILD_STUCK_SECONDS + 1.0) * 1000000.0)
	SceneManager._watch_transition()
	assert_false(SceneManager.busy, "but not past BUILD_STUCK_SECONDS")


func test_an_old_transition_stops_after_a_forced_reveal() -> void:
	var before: int = SceneManager._transition_id
	SceneManager.busy = true
	SceneManager._target = "id_test"
	SceneManager.force_reveal("test")
	assert_gt(SceneManager._transition_id, before, "the running coroutine sees a newer id and returns")


func test_esc_during_a_transition_opens_the_pause_menu_at_the_reveal() -> void:
	var allowed: bool = SceneManager.pause_allowed
	SceneManager.busy = true
	SceneManager._target = "esc_test"
	var esc: InputEventAction = InputEventAction.new()
	esc.action = &"pause"
	esc.pressed = true
	SceneManager._input(esc)
	assert_true(SceneManager._pause_wanted, "remembered, not dropped")
	SceneManager.pause_allowed = true
	SceneManager._end_transition()
	await get_tree().process_frame
	assert_true(SceneManager._pause_menu.visible, "the pause menu opens once the cover is gone")
	SceneManager._pause_menu.toggle()
	assert_false(get_tree().paused)
	SceneManager.pause_allowed = allowed


# ---- Continue from a save stuck before the welcome ------------------------------------------------------------------------------------


func test_continue_from_a_save_stuck_before_marens_welcome_plays_it_again() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.choose_starting_path(Affinity.Type.BEEFCAKE)
	Session.complete_trial()
	assert_true(Session.welcome_unfinished(), "cave cleared, welcome not finished (the v0.4.0 freeze left saves like this)")
	Session.pending_resume_scene = "town"
	SceneManager.busy = true  # the scene change itself is ignored while busy: only the decision is tested
	Session.resume_loaded_game()
	assert_true(Session.cave_exit_pending, "the arrival plays again in town")
	Session.set_flag(StringName(QuestDefinitions.LEGACY_FLAG))
	assert_true(Session.welcome_unfinished(), "v0.4.0 saves load with the legacy flag and still count")
	Session.set_flag(&"maren_met")
	assert_false(Session.welcome_unfinished(), "once she has spoken, never again")


func test_a_town_whose_build_never_finished_recovers() -> void:
	Session.save_enabled = false
	Session.ensure_game()
	var town: TownScene = (load("res://scenes/town.tscn") as PackedScene).instantiate() as TownScene
	add_child_autofree(town)
	await get_tree().process_frame
	town.set_process(false)
	town.set_process_unhandled_input(false)
	town._built = false
	town.recover_after_timeout()
	assert_true(town._built)
	assert_true(town.is_processing(), "the lock watchdog and the arrival start run again")
	assert_true(town.is_processing_unhandled_input())


# ---- The game log ---------------------------------------------------------------------------------------------------------------------


func test_heartbeat_names_scene_transition_lock_and_modals() -> void:
	GameLog.modal_opened("TestScreen")
	var line: String = GameLog.heartbeat_text(60.0)
	assert_string_contains(line, "scene=")
	assert_string_contains(line, "busy=")
	assert_string_contains(line, "modals=[")
	assert_string_contains(line, "TestScreen")
	assert_string_contains(line, "fps=60")
	GameLog.modal_closed("TestScreen")
	assert_false(GameLog.open_modals.has("TestScreen"))


func test_settings_summary_names_the_preset() -> void:
	assert_string_contains(Settings.summary(), "quality %s" % GraphicsQuality.display_name(Settings.graphics_quality))


func test_settle_waits_out_shader_spikes_but_not_a_steadily_slow_machine() -> void:
	assert_true(SceneManager.settle_frame_quick(16.0, 16.0), "a quick frame")
	assert_false(SceneManager.settle_frame_quick(900.0, 16.0), "a pipeline-compile spike")
	assert_true(SceneManager.settle_frame_quick(75.0, 62.0), "a slow iGPU's ordinary frame (steady)")
	assert_false(SceneManager.settle_frame_quick(400.0, 62.0), "a spike on the slow iGPU")


func test_leaving_an_area_releases_its_world_art_caches() -> void:
	ModelKit._cache["res://test/never_loaded.tscn"] = null
	MapArt._textures["test"] = null
	var dropped: int = AreaCaches.release()
	assert_gt(dropped, 1, "entries were dropped")
	assert_true(ModelKit._cache.is_empty())
	assert_true(MapArt._textures.is_empty())


func test_a_pumped_long_frame_releases_held_actions() -> void:
	KeepAlive.frame_start_usec = 0
	KeepAlive.tick()
	assert_eq(KeepAlive.after_frame(), 0, "an ordinary frame never pumps or releases")
	Input.action_press(&"move_up")
	KeepAlive._pumped = true  # as if a long build frame had pumped (and dropped the key-up)
	assert_gt(KeepAlive.after_frame(), 0)
	assert_false(Input.is_action_pressed(&"move_up"), "the hero does not walk on with no key down")
