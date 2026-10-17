extends CanvasLayer
## Scene switching with a fade to black, plus the global pause menu.

const FADE_TIME: float = 0.3

var busy: bool = false
## Scenes that may be paused set this true in _ready and false when they leave.
var pause_allowed: bool = false

var _fade: ColorRect
var _pause_menu: PauseMenu
## The area scene the player is in (`Areas` key; "" on the title): loading screens and zone title cards show when the destination is a different area.
var current_area: String = ""
## The area before the current one (the title counts as ""): a scene shows its zone title card when this differs from its own area.
var previous_area: String = ""
## Loading screens (LOAD-*) on entering an area; tools and tests can switch them off.
var show_loading_screens: bool = true

## Emitted when a scene change has finished (the fade or loading screen is gone), so something that belongs to the new scene can start.
signal revealed


func _ready() -> void:
	layer = 100
	UiSkin.apply()
	process_mode = Node.PROCESS_MODE_ALWAYS
	_fade = ColorRect.new()
	_fade.color = Color(0.03, 0.02, 0.05, 1.0)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade.modulate.a = 0.0
	add_child(_fade)
	_pause_menu = PauseMenu.new()
	_pause_menu.layer = 90
	get_tree().root.add_child.call_deferred(_pause_menu)


func _unhandled_input(event: InputEvent) -> void:
	var key: InputEventKey = event as InputEventKey
	if key != null and key.pressed and not key.echo and key.keycode == KEY_F8:
		open_feedback()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed(&"pause") and pause_allowed and not busy:
		_pause_menu.toggle()
		get_viewport().set_input_as_handled()


## Fades out, loads `path`, fades back in.
func change_scene(path: String, fade_time: float = FADE_TIME) -> void:
	if busy:
		return
	busy = true
	_close_pause()
	_fade.mouse_filter = Control.MOUSE_FILTER_STOP
	var area: String = Areas.key_for_scene(path)
	var screen: LoadingScreen = null
	if show_loading_screens and not area.is_empty() and area != current_area and DisplayServer.get_name() != "headless":
		screen = LoadingScreen.make(area, Session.dungeon_key)
	# Sound pass: a gust carries the hero into another area; the old place's ambience fades with the picture (the new scene sets its own).
	if not area.is_empty() and area != current_area and not current_area.is_empty():
		Audio.sfx(&"zone_transition")
	Audio.set_ambience("none", fade_time + 0.3)
	var out: Tween = create_tween()
	out.tween_property(_fade, "modulate:a", 1.0, fade_time)
	await out.finished
	pause_allowed = false
	var shown_at: int = Time.get_ticks_msec()
	if screen != null:
		screen.modulate.a = 0.0
		add_child(screen)
		var appear: Tween = create_tween().set_parallel(true)
		appear.tween_property(screen, "modulate:a", 1.0, LoadingScreen.FADE_IN)
		appear.tween_method(screen.set_progress, 0.0, 0.7, LoadingScreen.MIN_SECONDS)
		await get_tree().process_frame
		await get_tree().process_frame
		await get_tree().process_frame
	var error: Error = get_tree().change_scene_to_file(path)
	if error != OK:
		push_error("SceneManager: cannot load %s" % path)
	if path == "res://scenes/title.tscn":
		previous_area = ""
		current_area = ""
	elif not area.is_empty():
		previous_area = current_area
		current_area = area
	await get_tree().process_frame
	await get_tree().process_frame
	if screen != null:
		screen.set_progress(1.0)
		# The loading screen stays a moment even when the scene was quick, so it never flashes.
		var remaining: float = LoadingScreen.MIN_SECONDS - float(Time.get_ticks_msec() - shown_at) / 1000.0
		if remaining > 0.0:
			await get_tree().create_timer(remaining).timeout
		_fade.modulate.a = 0.0
		var vanish: Tween = create_tween()
		vanish.tween_property(screen, "modulate:a", 0.0, LoadingScreen.FADE_OUT)
		await vanish.finished
		screen.queue_free()
	else:
		var back: Tween = create_tween()
		back.tween_property(_fade, "modulate:a", 0.0, fade_time)
		await back.finished
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	busy = false
	revealed.emit()


## The playtest feedback form (F8, or the pause menu button).
func open_feedback() -> void:
	FeedbackForm.open(self)


func _close_pause() -> void:
	if _pause_menu != null and _pause_menu.visible:
		_pause_menu.toggle()


func quit_game() -> void:
	Settings.save_settings()
	get_tree().quit()


func go_to_title() -> void:
	change_scene("res://scenes/title.tscn")


func go_to_town() -> void:
	change_scene("res://scenes/town.tscn")


func go_to_start_area() -> void:
	change_scene("res://scenes/starting_area.tscn")
