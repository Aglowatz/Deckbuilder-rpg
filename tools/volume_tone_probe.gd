extends SceneTree
## Fixes Oct 26, Part 3: what the listener hears per slider position. A steady 440 Hz tone (-12 dBFS) plays on one bus with nothing else running;
## the probe reads the Master bus's output peak with the bus's own slider (and Master) at 100 / 80 / 50 / 25 / 10 / 5 %.
##   Godot --path . -s res://tools/volume_tone_probe.gd -- [--buses=Music,SFX,UI,Ambience,Voice,Battle,World]
## Lines "volume_tone: <bus> <slider> <value> master_out=<dB>".

const SLIDER_FOR: Dictionary = {"Music": "music_volume", "SFX": "sfx_volume", "UI": "ui_volume", "Ambience": "ambience_volume", "Voice": "voice_volume",
	"Battle": "sfx_volume", "World": "sfx_volume"}
const VALUES: Array[float] = [1.0, 0.8, 0.5, 0.25, 0.1, 0.05]

var _args: Dictionary = {}
var _player: AudioStreamPlayer
var _playback: AudioStreamGeneratorPlayback
var _phase: float = 0.0
var _jobs: Array[Dictionary] = []
var _job: Dictionary = {}
var _wait: float = 0.0
var _peak: float = -200.0
var _started: bool = false


func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--"):
			var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
			_args[parts[0]] = parts[1] if parts.size() > 1 else "true"


func _process(delta: float) -> bool:
	if not _started:
		_started = true
		_player = AudioStreamPlayer.new()
		var gen: AudioStreamGenerator = AudioStreamGenerator.new()
		gen.mix_rate = 48000.0
		gen.buffer_length = 0.2
		_player.stream = gen
		root.add_child(_player)
		_player.play()
		_playback = _player.get_stream_playback() as AudioStreamGeneratorPlayback
		for bus: String in str(_args.get("buses", "Music,SFX,UI,Ambience,Voice,Battle,World")).split(",", false):
			for slider: String in [str(SLIDER_FOR[bus]), "master_volume"]:
				for value: float in VALUES:
					_jobs.append({"bus": bus, "slider": slider, "value": value})
		return false
	_fill()
	if _job.is_empty():
		if _jobs.is_empty():
			quit(0)
			return true
		_job = _jobs.pop_front()
		var settings: Node = root.get_node("Settings")
		settings.call("reset_audio_defaults") if settings.has_method("reset_audio_defaults") else null
		for key: String in ["master_volume", "music_volume", "sfx_volume", "ui_volume", "ambience_volume", "voice_volume"]:
			settings.set(key, 1.0)
		settings.set(str(_job["slider"]), float(_job["value"]))
		settings.call("apply_audio")
		_player.bus = StringName(str(_job["bus"]))
		_wait = 0.7
		_peak = -200.0
		return false
	_wait -= delta
	if _wait < 0.4:
		var master: int = AudioServer.get_bus_index(&"Master")
		_peak = maxf(_peak, maxf(AudioServer.get_bus_peak_volume_left_db(master, 0), AudioServer.get_bus_peak_volume_right_db(master, 0)))
	if _wait <= 0.0:
		print("volume_tone: %s %s %.2f master_out=%.1f" % [str(_job["bus"]), str(_job["slider"]), float(_job["value"]), _peak])
		_job = {}
	return false


func _fill() -> void:
	var frames: int = _playback.get_frames_available()
	for i: int in range(frames):
		var s: float = sin(_phase) * 0.25
		_playback.push_frame(Vector2(s, s))
		_phase = fmod(_phase + TAU * 440.0 / 48000.0, TAU)
