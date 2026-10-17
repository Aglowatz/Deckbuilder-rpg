class_name AmbienceManager
extends Node
## Plays the place's ambience (`AmbienceProfiles`): its looping beds on the Ambience bus (crossfaded when the place changes; a bed two places share keeps
## playing) and its randomised one-shots, each placed in the world around the listener so birds and far-off stamps come from somewhere. Parameters
## (`set_param`, e.g. the Verdant Dump's "corruption" near the Rotheart) fade the beds and thin the one-shots that name them. Owned by `Audio`.

const DEFAULT_FADE: float = 2.0
const SILENT_DB: float = -60.0

var current: String = ""
var _profile: Dictionary = {}
var _params: Dictionary = {}
## set name -> {player, target, level, fade, dying}
var _beds: Dictionary = {}
## one-shot index -> seconds until it fires
var _timers: Array[float] = []
var _picker: SfxVariantPicker = SfxVariantPicker.new()
var _log: Array[String] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


## Switches to a profile (an `AmbienceProfiles` name; "" or "none" = silence) over `fade` seconds and applies its acoustics to the World bus.
func set_area(profile_name: String, fade: float = DEFAULT_FADE) -> void:
	var key: String = profile_name if AmbienceProfiles.has(profile_name) else "none"
	if key == current:
		return
	current = key
	_profile = AmbienceProfiles.resolved(key)
	_note("area %s" % key)
	AudioMix.apply_acoustics(str(_profile.get("acoustic", "dry")))
	var wanted: Dictionary = {}
	for entry: Variant in _profile.get("beds", []) as Array:
		var bed: Dictionary = entry as Dictionary
		wanted[str(bed["set"])] = bed
	for set_name: Variant in _beds.keys():
		if not wanted.has(set_name):
			var state: Dictionary = _beds[set_name] as Dictionary
			state["target"] = SILENT_DB
			state["fade"] = maxf(fade, 0.05)
			state["dying"] = true
	for set_name: String in wanted.keys():
		_start_bed(set_name, wanted[set_name] as Dictionary, fade)
	_timers.clear()
	for entry: Variant in _profile.get("oneshots", []) as Array:
		var shot: Dictionary = entry as Dictionary
		var every: Array = shot.get("every", [8.0, 16.0]) as Array
		_timers.append(_picker.interval(float(every[0]) * 0.3, float(every[1]) * 0.6))


## Fades everything out (a battle, the title).
func stop(fade: float = 1.0) -> void:
	set_area("none", fade)


## A 0..1 parameter that beds and one-shots can follow (`param` in their profile entry).
func set_param(param_name: String, value: float) -> void:
	_params[param_name] = clampf(value, 0.0, 1.0)
	for entry: Variant in _profile.get("beds", []) as Array:
		var bed: Dictionary = entry as Dictionary
		var set_name: String = str(bed["set"])
		if bed.has("param") and _beds.has(set_name):
			var state: Dictionary = _beds[set_name] as Dictionary
			state["target"] = _bed_db(bed)
			state["fade"] = 1.0


func param(param_name: String) -> float:
	return float(_params.get(param_name, 0.0))


func bed_sets() -> Array[String]:
	var result: Array[String] = []
	for set_name: Variant in _beds.keys():
		if not bool((_beds[set_name] as Dictionary).get("dying", false)):
			result.append(str(set_name))
	result.sort()
	return result


func event_log() -> Array[String]:
	return _log.duplicate()


func _bed_db(bed: Dictionary) -> float:
	var db: float = float(bed.get("db", 0.0))
	if bed.has("param"):
		var amount: float = param(str(bed["param"]))
		if amount <= 0.001:
			return SILENT_DB
		db += linear_to_db(amount)
	return db


func _start_bed(set_name: String, bed: Dictionary, fade: float) -> void:
	if _beds.has(set_name):
		var existing: Dictionary = _beds[set_name] as Dictionary
		existing["target"] = _bed_db(bed)
		existing["fade"] = maxf(fade, 0.05)
		existing["dying"] = false
		return
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.bus = Settings.BUS_AMBIENCE
	player.volume_db = SILENT_DB
	add_child(player)
	_beds[set_name] = {"player": player, "target": _bed_db(bed), "level": SILENT_DB, "fade": maxf(fade, 0.05), "dying": false}
	if DisplayServer.get_name() == "headless":
		return
	var files: Array = Audio.bank.files(set_name)
	if files.is_empty():
		Audio.note_missing("ambience:" + set_name)
		return
	var stream: AudioStream = Audio.load_stream(str(files[_picker.pick(set_name, files.size())]), true)
	if stream == null:
		return
	player.stream = stream
	# A random start point, so two visits never begin on the same bird.
	player.play(_picker.interval(0.0, maxf(stream.get_length() - 1.0, 0.0)))


func _process(delta: float) -> void:
	_advance_beds(delta)
	if DisplayServer.get_name() == "headless":
		return
	var shots: Array = _profile.get("oneshots", []) as Array
	for index: int in range(mini(_timers.size(), shots.size())):
		_timers[index] -= delta
		if _timers[index] > 0.0:
			continue
		var shot: Dictionary = shots[index] as Dictionary
		var every: Array = shot.get("every", [8.0, 16.0]) as Array
		_timers[index] = _picker.interval(float(every[0]), float(every[1]))
		if shot.has("param") and _picker.rng.randf() > param(str(shot["param"])):
			continue
		_fire(shot)


func _advance_beds(delta: float) -> void:
	for set_name: Variant in _beds.keys():
		var state: Dictionary = _beds[set_name] as Dictionary
		var level: float = float(state["level"])
		var target: float = float(state["target"])
		# Fades move in dB at a rate that covers the 60 dB range in the fade time (an equal-loudness-ish ramp).
		var step: float = 60.0 * delta / maxf(float(state["fade"]), 0.05)
		level = minf(target, level + step) if level < target else maxf(target, level - step)
		state["level"] = level
		var player: AudioStreamPlayer = state["player"] as AudioStreamPlayer
		player.volume_db = level
		if bool(state["dying"]) and level <= SILENT_DB + 0.01:
			player.queue_free()
			_beds.erase(set_name)


func _fire(shot: Dictionary) -> void:
	var dist: Array = shot.get("dist", [8.0, 20.0]) as Array
	var up: Array = shot.get("up", [0.5, 2.0]) as Array
	var angle: float = _picker.rng.randf_range(0.0, TAU)
	var distance: float = _picker.interval(float(dist[0]), float(dist[1]))
	var offset: Vector3 = Vector3(cos(angle) * distance, _picker.interval(float(up[0]), float(up[1])), sin(angle) * distance)
	var set_name: String = str(shot["set"])
	_note("shot %s" % set_name)
	Audio.play_set(set_name, {"bus": Settings.BUS_AMBIENCE, "volume": float(shot.get("db", -10.0)), "position": Audio.listener_position() + offset,
		"range": distance * 2.5, "priority": 10, "pitch": 0.05})


func _note(text: String) -> void:
	_log.append(text)
	if _log.size() > 120:
		_log.remove_at(0)
