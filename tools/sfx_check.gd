extends Node3D
## The sound check (docs/audio/sound_direction.md, Part E): plays every bank event and every ambience profile through the real mixer, windowed, and
## measures each one's peak on its own bus (before the SFX and Master limiters), so clipping, silent events and level outliers show up without
## listening. Then a burst of 24 battle sounds in half a second checks the voice limits and that the Master never passes its -1 dBFS ceiling.
## Run: bash tools/run_sfx_check.sh   (SFX_CHECK_ONLY=events|ambience|burst, SFX_CHECK_FILTER=<event prefix>). Writes _screenshots/sfx_check.tsv.

var _rows: Array[String] = []
var _clips: int = 0
var _silent: Array[String] = []


func _ready() -> void:
	var camera: Camera3D = Camera3D.new()
	camera.position = Vector3(0.0, 2.0, 6.0)
	add_child(camera)
	camera.make_current()
	_run.call_deferred()


func _run() -> void:
	var only: String = OS.get_environment("SFX_CHECK_ONLY")
	var prefix: String = OS.get_environment("SFX_CHECK_FILTER")
	await get_tree().create_timer(0.5).timeout
	_rows.append("kind\tname\tbus\tpeak_db\tlayers\tvariants")
	if only.is_empty() or only == "events":
		var names: Array = Audio.bank.events.keys()
		names.sort()
		for event_name: Variant in names:
			if not prefix.is_empty() and not str(event_name).begins_with(prefix):
				continue
			await _check_event(str(event_name))
	if only.is_empty() or only == "ambience":
		for profile_name: Variant in AmbienceProfiles.PROFILES.keys():
			await _check_ambience(str(profile_name))
		Audio.set_ambience("none", 0.1)
	if only.is_empty() or only == "burst":
		await _burst()
	var file: FileAccess = FileAccess.open("res://_screenshots/sfx_check.tsv", FileAccess.WRITE)
	if file != null:
		file.store_string("\n".join(_rows) + "\n")
	print("sfx_check: %d rows, %d over -1 dBFS on their bus, %d silent: %s" % [_rows.size() - 1, _clips, _silent.size(), ", ".join(_silent)])
	print("sfx_check: missing log %s" % str(Audio.missing_log))
	get_tree().quit(0 if _clips == 0 else 1)


func _check_event(event_name: String) -> void:
	var event: Dictionary = Audio.bank.event(event_name)
	var bus: String = str(event.get("bus", "Battle"))
	var spatial: bool = bool(event.get("spatial", false))
	var length: float = 0.0
	var variants: Array[String] = []
	for layer: Variant in event.get("layers", []) as Array:
		var files: Array = Audio.bank.files(str((layer as Dictionary)["set"]))
		variants.append(str(files.size()))
		for path: Variant in files:
			var stream: AudioStream = Audio.load_stream(str(path))
			if stream != null:
				length = maxf(length, stream.get_length() + float((layer as Dictionary)["delay"]))
	if spatial:
		Audio.sfx_at(StringName(event_name), Audio.listener_position() + Vector3(1.5, 0.0, -2.0))
	else:
		Audio.sfx(StringName(event_name))
	var watch_bus: String = "World" if spatial and bus != "Ambience" else bus
	var peak: float = await _peak_over(watch_bus, clampf(length + 0.1, 0.2, 2.5))
	if peak > -1.0:
		_clips += 1
		print("sfx_check: CLIP %s peaks %.1f dB on %s" % [event_name, peak, watch_bus])
	if peak < -60.0:
		_silent.append(event_name)
	_rows.append("event\t%s\t%s\t%.1f\t%d\t%s" % [event_name, watch_bus, peak, (event.get("layers", []) as Array).size(), "/".join(variants)])
	await get_tree().create_timer(0.08).timeout


func _check_ambience(profile_name: String) -> void:
	Audio.set_ambience(profile_name, 0.3)
	var peak: float = await _peak_over("Ambience", 7.0)
	if peak > -1.0:
		_clips += 1
	if peak < -60.0 and profile_name != "none":
		_silent.append("ambience:" + profile_name)
	_rows.append("ambience\t%s\tAmbience\t%.1f\t%d\t" % [profile_name, peak, Audio.ambience.bed_sets().size()])
	print("sfx_check: ambience %s peak %.1f dB, beds %s" % [profile_name, peak, str(Audio.ambience.bed_sets())])


func _burst() -> void:
	var names: Array[StringName] = [&"card_play", &"hit_light", &"hit_heavy", &"card_draw", &"hit_metal", &"card_discard"]
	var master_peak: float = -90.0
	for i: int in range(24):
		Audio.sfx(names[i % names.size()])
		await get_tree().create_timer(0.02).timeout
		master_peak = maxf(master_peak, maxf(AudioServer.get_bus_peak_volume_left_db(0, 0), AudioServer.get_bus_peak_volume_right_db(0, 0)))
	master_peak = maxf(master_peak, await _peak_over("Master", 1.2))
	_rows.append("burst\t24 battle sounds in 0.5 s\tMaster\t%.1f\t\t" % master_peak)
	print("sfx_check: burst master peak %.1f dB" % master_peak)
	if master_peak > -0.5:
		_clips += 1


func _peak_over(bus_name: String, seconds: float) -> float:
	var bus: int = AudioServer.get_bus_index(bus_name)
	var peak: float = -90.0
	var elapsed: float = 0.0
	while elapsed < seconds:
		await get_tree().process_frame
		elapsed += get_process_delta_time()
		peak = maxf(peak, maxf(AudioServer.get_bus_peak_volume_left_db(bus, 0), AudioServer.get_bus_peak_volume_right_db(bus, 0)))
	return peak
