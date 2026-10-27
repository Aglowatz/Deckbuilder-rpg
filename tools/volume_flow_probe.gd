extends SceneTree
## Fixes Oct 26, Part 3: the volume sliders driven the way a player does - real mouse presses and drags pushed through the window - from the title
## screen's Settings and from the in-game pause menu (Esc in Crosspath). Logs Settings' values and every bus after each drag.
##   Godot --path . -s res://tools/volume_flow_probe.gd -- [--from=title|pause]
## Lines "volume_flow: ...". Restores the saved audio values at the end (the panel saves as it goes).

const SLIDERS: Array[String] = ["MasterSlider", "MusicSlider", "SfxSlider", "UiSlider", "AmbienceSlider", "VoiceSlider"]
const KEYS: Array[String] = ["master_volume", "music_volume", "sfx_volume", "ui_volume", "ambience_volume", "voice_volume"]

var _args: Dictionary = {}
var _t: float = 0.0
var _steps: Array[Callable] = []
var _saved: Dictionary = {}
var _slider_index: int = 0


func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--"):
			var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
			_args[parts[0]] = parts[1] if parts.size() > 1 else "true"


func _process(delta: float) -> bool:
	if _steps.is_empty() and _t == 0.0:
		var settings: Node = root.get_node("Settings")
		for key: String in KEYS:
			_saved[key] = settings.get(key)
		_log("startup")
		var from_pause: bool = str(_args.get("from", "title")) == "pause"
		change_scene_to_file("res://scenes/town.tscn" if from_pause else "res://scenes/title.tscn")
		_queue(6.0, func() -> void: _log("scene up"))
		if from_pause:
			_queue(0.5, func() -> void: _key(KEY_ESCAPE))
			_queue(1.5, func() -> void: _click_text("Settings"))
		else:
			_queue(0.5, func() -> void: _click_text("Settings"))
		_queue(1.5, func() -> void: _click_name("TabAudio"))
		for i: int in range(SLIDERS.size()):
			_queue(1.0, func() -> void: _drag(SLIDERS[i], 0.1))
			_queue(0.6, func() -> void: _log("after dragging %s to 10%%" % SLIDERS[i]))
			_queue(0.3, func() -> void: _drag(SLIDERS[i], 0.9))
			_queue(0.6, func() -> void: _log("after dragging %s to 90%%" % SLIDERS[i]))
		_queue(0.5, func() -> void: _restore())
		_queue(0.5, func() -> void: quit(0))
		_t = 0.001
		return false
	_t -= delta
	if _t <= 0.0 and not _steps.is_empty():
		var step: Callable = _steps.pop_front()
		_t = float(step.get_bound_arguments_count())  # unused
		step.call()
		_t = float(_delays.pop_front())
	return false


var _delays: Array[float] = []


func _queue(delay: float, step: Callable) -> void:
	_steps.append(step)
	_delays.append(delay)


func _log(label: String) -> void:
	var settings: Node = root.get_node("Settings")
	var values: PackedStringArray = []
	for key: String in KEYS:
		values.append("%s=%.2f" % [key.trim_suffix("_volume"), float(settings.get(key))])
	var buses: PackedStringArray = []
	for index: int in range(AudioServer.bus_count):
		buses.append("%s=%.1f%s" % [AudioServer.get_bus_name(index), AudioServer.get_bus_volume_db(index), "M" if AudioServer.is_bus_mute(index) else ""])
	print("volume_flow: [%s] %s | %s | paused=%s" % [label, " ".join(values), " ".join(buses), str(paused)])


func _find(predicate: Callable) -> Control:
	for node: Node in root.find_children("*", "Control", true, false):
		var control: Control = node as Control
		if control.is_visible_in_tree() and not control.is_queued_for_deletion() and predicate.call(control):
			return control
	return null


func _click_text(text: String) -> void:
	var button: Control = _find(func(c: Control) -> bool: return c is BaseButton and c.get("text") != null and str(c.get("text")).strip_edges() == text)
	if button == null:
		print("volume_flow: no button '%s'" % text)
		return
	_click_at(button.get_global_rect().get_center())
	print("volume_flow: clicked '%s'" % text)


func _click_name(node_name: String) -> void:
	var control: Control = _find(func(c: Control) -> bool: return c.name == node_name)
	if control == null:
		print("volume_flow: no control %s" % node_name)
		return
	_click_at(control.get_global_rect().get_center())


func _click_at(pos: Vector2) -> void:
	for pressed: bool in [true, false]:
		var event: InputEventMouseButton = InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.position = pos
		event.global_position = pos
		root.push_input(event, true)


func _key(code: Key) -> void:
	for pressed: bool in [true, false]:
		var event: InputEventKey = InputEventKey.new()
		event.keycode = code
		event.physical_keycode = code
		event.pressed = pressed
		Input.parse_input_event(event)


## Presses on the slider's grabber, moves to `fraction` of its width and lets go - a player's drag.
func _drag(slider_name: String, fraction: float) -> void:
	var slider: HSlider = _find(func(c: Control) -> bool: return c.name == slider_name) as HSlider
	if slider == null:
		print("volume_flow: no slider %s" % slider_name)
		return
	var rect: Rect2 = slider.get_global_rect()
	var ratio: float = float((slider.value - slider.min_value) / (slider.max_value - slider.min_value))
	var start: Vector2 = Vector2(rect.position.x + rect.size.x * ratio, rect.get_center().y)
	var end: Vector2 = Vector2(rect.position.x + rect.size.x * fraction, rect.get_center().y)
	var down: InputEventMouseButton = InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.pressed = true
	down.position = start
	down.global_position = start
	root.push_input(down, true)
	for k: int in range(1, 9):
		var motion: InputEventMouseMotion = InputEventMouseMotion.new()
		motion.position = start.lerp(end, float(k) / 8.0)
		motion.global_position = motion.position
		motion.button_mask = MOUSE_BUTTON_MASK_LEFT
		motion.relative = (end - start) / 8.0
		root.push_input(motion, true)
	var up: InputEventMouseButton = InputEventMouseButton.new()
	up.button_index = MOUSE_BUTTON_LEFT
	up.pressed = false
	up.position = end
	up.global_position = end
	root.push_input(up, true)
	print("volume_flow: dragged %s %.2f -> value %.2f" % [slider_name, ratio, slider.value])


func _restore() -> void:
	var settings: Node = root.get_node("Settings")
	for key: String in KEYS:
		settings.set(key, _saved[key])
	settings.call("apply_audio")
	settings.call("save_settings")
	_log("restored")
