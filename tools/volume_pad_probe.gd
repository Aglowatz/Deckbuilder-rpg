extends SceneTree
## Fixes Oct 26, Part 3: the volume sliders by controller only (tools/pad_driver.gd events): Start opens the pause menu in Crosspath, the D-pad
## walks to Settings > Audio, then left / right on each slider. Lines "volume_pad: ...". Restores the saved values at the end.
##   Godot --path . -s res://tools/volume_pad_probe.gd

const SLIDERS: Array[String] = ["MasterSlider", "MusicSlider", "SfxSlider"]
const KEYS: Array[String] = ["master_volume", "music_volume", "sfx_volume", "ui_volume", "ambience_volume", "voice_volume"]

var _pad: RefCounted
var _saved: Dictionary = {}
var _started: bool = false


func _process(_delta: float) -> bool:
	if not _started:
		_started = true
		_run.call_deferred()
	return false


func _focus_owner() -> Control:
	return root.gui_get_focus_owner()


func _log(label: String) -> void:
	var settings: Node = root.get_node("Settings")
	var values: PackedStringArray = []
	for key: String in KEYS:
		values.append("%s=%.2f" % [key.trim_suffix("_volume"), float(settings.get(key))])
	var owner_now: Control = _focus_owner()
	print("volume_pad: [%s] %s Master=%.1fdB Music=%.1fdB SFX=%.1fdB focus=%s" % [label, " ".join(values),
		AudioServer.get_bus_volume_db(0), AudioServer.get_bus_volume_db(AudioServer.get_bus_index(&"Music")),
		AudioServer.get_bus_volume_db(AudioServer.get_bus_index(&"SFX")), str(owner_now.name) if owner_now != null else "-"])


func _run() -> void:
	var settings: Node = root.get_node("Settings")
	for key: String in KEYS:
		_saved[key] = settings.get(key)
	_pad = (load("res://tools/pad_driver.gd") as GDScript).new(self)
	change_scene_to_file("res://scenes/town.tscn")
	await _pad.call("seconds", 6.0)
	_log("town up")
	await _pad.call("tap", JOY_BUTTON_START)
	await _pad.call("seconds", 1.0)
	var ok: bool = await _pad.call("press_button", "Settings")
	print("volume_pad: pressed Settings = %s" % str(ok))
	await _pad.call("seconds", 1.0)
	ok = await _pad.call("focus_to", func(c: Control) -> bool: return c.name == "TabAudio")
	if ok:
		await _pad.call("tap", JOY_BUTTON_A)
	print("volume_pad: Audio tab = %s" % str(ok))
	await _pad.call("seconds", 1.0)
	for slider_name: String in SLIDERS:
		ok = await _pad.call("focus_to", func(c: Control) -> bool: return c.name == slider_name)
		_log("focused %s (%s)" % [slider_name, str(ok)])
		await _pad.call("tap", JOY_BUTTON_DPAD_LEFT, 4)
		await _pad.call("seconds", 0.4)
		_log("%s after D-pad left x4" % slider_name)
		await _pad.call("tap", JOY_BUTTON_DPAD_RIGHT, 2)
		await _pad.call("seconds", 0.4)
		_log("%s after D-pad right x2" % slider_name)
		await _pad.call("axis", JOY_AXIS_LEFT_X, -1.0)
		await _pad.call("seconds", 0.6)
		await _pad.call("axis", JOY_AXIS_LEFT_X, 0.0)
		await _pad.call("seconds", 0.3)
		_log("%s after the stick held left 0.6 s" % slider_name)
		await _pad.call("button", JOY_BUTTON_DPAD_RIGHT, true)
		await _pad.call("seconds", 1.0)
		await _pad.call("button", JOY_BUTTON_DPAD_RIGHT, false)
		await _pad.call("seconds", 0.3)
		_log("%s after the D-pad held right 1 s" % slider_name)
	for key: String in KEYS:
		settings.set(key, _saved[key])
	settings.call("apply_audio")
	settings.call("save_settings")
	_log("restored")
	quit(0)
