extends SceneTree
## Fixes Oct 26, Part 3: the output device switching while the game runs (what Windows does when a headset or a DualSense is plugged in):
## a tone plays on Music, the probe switches AudioServer.output_device to each listed device and back to Default and logs the bus volumes and
## the Master output peak each time. Lines "volume_device: ...".  Godot --path . -s res://tools/volume_device_probe.gd

var _player: AudioStreamPlayer
var _playback: AudioStreamGeneratorPlayback
var _phase: float = 0.0
var _devices: Array[String] = []
var _wait: float = 0.0
var _peak: float = -200.0
var _started: bool = false


func _process(delta: float) -> bool:
	if not _started:
		_started = true
		_player = AudioStreamPlayer.new()
		var gen: AudioStreamGenerator = AudioStreamGenerator.new()
		gen.mix_rate = 48000.0
		_player.stream = gen
		_player.bus = &"Music"
		root.add_child(_player)
		_player.play()
		_playback = _player.get_stream_playback() as AudioStreamGeneratorPlayback
		for device: String in AudioServer.get_output_device_list():
			_devices.append(device)
		_devices.append("Default")
		_wait = 1.0
		return false
	var frames: int = _playback.get_frames_available()
	for i: int in range(frames):
		var s: float = sin(_phase) * 0.25
		_playback.push_frame(Vector2(s, s))
		_phase = fmod(_phase + TAU * 440.0 / 48000.0, TAU)
	_peak = maxf(_peak, AudioServer.get_bus_peak_volume_left_db(0, 0))
	_wait -= delta
	if _wait > 0.0:
		return false
	print("volume_device: device=%s Master=%.1fdB Music=%.1fdB mute=%s master_out=%.1f" % [AudioServer.output_device, AudioServer.get_bus_volume_db(0),
		AudioServer.get_bus_volume_db(AudioServer.get_bus_index(&"Music")), str(AudioServer.is_bus_mute(0)), _peak])
	if _devices.is_empty():
		quit(0)
		return true
	AudioServer.output_device = _devices.pop_front()
	_peak = -200.0
	_wait = 1.2
	return false
