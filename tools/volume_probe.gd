extends SceneTree
## Fixes Oct 26, Part 3: does each volume slider change what is heard? Run windowed (real audio output):
##   Godot --path . -s res://tools/volume_probe.gd -- [--scene=res://scenes/town.tscn]
## Logs the saved audio values and every bus's volume_db / mute / ducks at startup, after the scene loads, after the Settings panel opens and after
## each slider moves; while music, ambience, UI ticks, battle hits and dialogue blips play, it reads every bus's peak level (dB) for a second with
## the slider at 0 and at its saved value. Lines "volume_probe: ..." (docs/audio/volume_fix_oct26.md).

const BUSES: Array[String] = ["Master", "Music", "SFX", "World", "Battle", "UI", "Ambience", "Voice"]
const SLIDERS: Array[String] = ["MasterSlider", "MusicSlider", "SfxSlider", "UiSlider", "AmbienceSlider", "VoiceSlider"]

var _args: Dictionary = {}
var _step: int = 0
var _wait: float = 0.0
var _panel: Control
var _jobs: Array[Dictionary] = []
var _peaks: Dictionary = {}
var _sound_timer: float = 0.0


func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--"):
			var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
			_args[parts[0]] = parts[1] if parts.size() > 1 else "true"


func _settings() -> Node:
	return root.get_node("Settings")


func _audio() -> Node:
	return root.get_node("Audio")


func _log_state(label: String) -> void:
	var s: Node = _settings()
	print("volume_probe: [%s] saved master=%.2f music=%.2f sfx=%.2f ui=%.2f ambience=%.2f voice=%.2f mute_unfocused=%s focused=%s" % [label,
		float(s.get("master_volume")), float(s.get("music_volume")), float(s.get("sfx_volume")), float(s.get("ui_volume")),
		float(s.get("ambience_volume")), float(s.get("voice_volume")), str(s.get("mute_unfocused")), str(s.get("_focused"))])
	var parts: PackedStringArray = []
	for bus_name: String in BUSES:
		var index: int = AudioServer.get_bus_index(bus_name)
		if index < 0:
			parts.append("%s=MISSING" % bus_name)
			continue
		var amp: String = ""
		for e: int in range(AudioServer.get_bus_effect_count(index)):
			var effect: AudioEffect = AudioServer.get_bus_effect(index, e)
			if effect is AudioEffectAmplify:
				amp = " duck=%.1f" % (effect as AudioEffectAmplify).volume_db
			if not AudioServer.is_bus_effect_enabled(index, e):
				amp += " effect%d_off" % e
		parts.append("%s=%.1fdB%s%s%s>%s" % [bus_name, AudioServer.get_bus_volume_db(index), " MUTED" if AudioServer.is_bus_mute(index) else "",
			" BYPASS" if AudioServer.is_bus_bypassing_effects(index) else "", amp, str(AudioServer.get_bus_send(index))])
	print("volume_probe: [%s] buses %s" % [label, " ".join(parts)])
	print("volume_probe: [%s] device=%s devices=%s mix_rate=%d" % [label, AudioServer.output_device, str(AudioServer.get_output_device_list()), AudioServer.get_mix_rate()])


func _log_players(label: String) -> void:
	var by_bus: Dictionary = {}
	for node: Node in root.find_children("*", "", true, false):
		if node is AudioStreamPlayer or node is AudioStreamPlayer2D or node is AudioStreamPlayer3D:
			var playing: bool = bool(node.get("playing"))
			if not playing:
				continue
			var bus: String = str(node.get("bus"))
			if AudioServer.get_bus_index(bus) < 0:
				bus += "(MISSING->Master)"
			by_bus[bus] = int(by_bus.get(bus, 0)) + 1
			if node.get("stream_paused"):
				print("volume_probe: [%s] PAUSED stream %s" % [label, str(node.get_path())])
	print("volume_probe: [%s] playing players by bus %s" % [label, str(by_bus)])


func _process(delta: float) -> bool:
	_play_test_sounds(delta)
	_sample_peaks()
	match _step:
		0:
			_log_state("startup")
			var scene: Node = (load(str(_args.get("scene", "res://scenes/town.tscn"))) as PackedScene).instantiate()
			root.add_child(scene)
			_step = 1
			_wait = 6.0
		1:
			_wait -= delta
			if _wait > 0.0:
				return false
			_log_state("scene loaded")
			_log_players("scene loaded")
			_panel = (load("res://ui/screens/settings_panel.gd") as GDScript).new() as Control
			_panel.set("autosave", false)
			var layer: CanvasLayer = CanvasLayer.new()
			layer.layer = 50
			root.add_child(layer)
			layer.add_child(_panel)
			_panel.call("show_page", 4)
			for slider_name: String in SLIDERS:
				_jobs.append({"slider": slider_name, "value": 0.0})
				_jobs.append({"slider": slider_name, "value": -1.0})
			_step = 2
			_wait = 1.0
		2:
			_wait -= delta
			if _wait > 0.0:
				return false
			if _peaks.has("job"):
				_report(_peaks["job"] as Dictionary)
			if _jobs.is_empty():
				_log_state("end")
				_log_players("end")
				quit(0)
				return true
			var job: Dictionary = _jobs.pop_front()
			var slider: HSlider = _panel.find_child(str(job["slider"]), true, false) as HSlider
			if slider == null:
				print("volume_probe: slider %s not found" % str(job["slider"]))
				return false
			if float(job["value"]) < 0.0:
				job["value"] = float(job.get("saved", 0.8))
			else:
				job["saved"] = slider.value
				_jobs[0]["saved"] = slider.value if not _jobs.is_empty() else 0.8
			slider.value = float(job["value"])
			_log_state("after %s -> %.2f" % [str(job["slider"]), float(job["value"])])
			_peaks = {"job": job}
			_wait = 1.6
	return false


## Something on every bus, all the time: UI ticks, a battle hit, a dialogue blip, footsteps on World (the scene's music and ambience run themselves).
func _play_test_sounds(delta: float) -> void:
	if _step < 1:
		return
	_sound_timer -= delta
	if _sound_timer > 0.0:
		return
	_sound_timer = 0.25
	var audio: Node = _audio()
	audio.call("sfx", &"ui_tick")
	audio.call("play", &"dialogue", {})
	audio.call("play", &"card_play", {})


func _sample_peaks() -> void:
	if not _peaks.has("job") or _wait > 1.0:
		return
	for bus_name: String in BUSES:
		var index: int = AudioServer.get_bus_index(bus_name)
		if index < 0:
			continue
		var peak: float = maxf(AudioServer.get_bus_peak_volume_left_db(index, 0), AudioServer.get_bus_peak_volume_right_db(index, 0))
		_peaks[bus_name] = maxf(float(_peaks.get(bus_name, -200.0)), peak)


func _report(job: Dictionary) -> void:
	var parts: PackedStringArray = []
	for bus_name: String in BUSES:
		parts.append("%s=%.1f" % [bus_name, float(_peaks.get(bus_name, -200.0))])
	print("volume_probe: PEAKS with %s at %.2f: %s" % [str(job["slider"]), float(job["value"]), " ".join(parts)])
