extends Node
## Sound effects, ambience and music (docs/audio/sound_direction.md). Effects are bank events (`SfxBank`, data/audio/sfx_bank.json): each event plays
## its layers (transient, body, tail) from variant sets with random pitch and volume, never the same variant twice in a row, on its bus (World, Battle,
## UI, Voice), in 2D or placed in the world (3D, heard from the hero), under voice limits and priorities (`SfxVoicePolicy`). Big moments duck the music
## and ambience (`AudioMix`). Ambience is `AmbienceManager`; music and stings are `MusicManager` (registry IDs), with the synthesized `MusicSynth` tracks
## as the fallback. Names that are not bank events fall back to the old catalog (`AudioCatalog`) and then to `MusicSynth`; a missing file is skipped
## silently (and counted in `missing_log`) so the game never crashes over audio.

## Effect names that are really musical stings: playing the effect plays the registry sting (ducking the music) when its file exists.
const STING_ALIASES: Dictionary = {
	&"victory": "STG-VICTORY",
	&"defeat": "STG-DEFEAT",
	&"level_up": "STG-LEVEL",
}
## Layers that still play under a sting alias (the stings stay; these add body under them).
const STING_LAYERS: Dictionary = {
	&"victory": &"victory_layer",
	&"defeat": &"defeat_layer",
	&"level_up": &"level_up_layer",
}

const POOL_2D: int = 28
const POOL_3D: int = 20
const DEFAULT_RANGE: float = 28.0
const HISTORY_SIZE: int = 400

var bank: SfxBank
## The music: area track, override stack, stings and ducking (`MusicManager`).
var music: MusicManager
## The place's ambience beds and one-shots (`AmbienceManager`).
var ambience: AmbienceManager
var picker: SfxVariantPicker = SfxVariantPicker.new()
## Recently played events (name per entry), for tests, smokes and the verify pass.
var history: Array[String] = []
## Names asked for that have no sound, with how often (the verify pass lists them).
var missing_log: Dictionary = {}
## How often each name was asked for this run (the smokes print it).
var play_counts: Dictionary = {}
## Counts every sound request (effects and stings); `UiSounds` compares it across a button press to see whether the screen made its own sound.
var play_serial: int = 0
## The interface sounds every button, tab and slider gets (`UiSounds`).
var ui_sounds: UiSounds

var _catalog: Dictionary = AudioCatalog.sounds()
var _cache: Dictionary = {}
var _players_2d: Array[AudioStreamPlayer] = []
var _players_3d: Array[AudioStreamPlayer3D] = []
var _info_2d: Array[Dictionary] = []
var _info_3d: Array[Dictionary] = []
var _pending: Array[Dictionary] = []
var _last_played: Dictionary = {}
var _now: float = 0.0
## Duck sources: key -> {"db": dB, "until": seconds (or -1 while held), "ambience_only": bool}, for the Music and Ambience buses.
var _ducks: Dictionary = {}
var _duck_level: Dictionary = {"Music": 0.0, "Ambience": 0.0}
var _listener: AudioListener3D
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_rng.randomize()
	bank = SfxBank.load_from()
	for i: int in range(POOL_2D):
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.bus = Settings.BUS_SFX
		add_child(player)
		_players_2d.append(player)
		_info_2d.append({"busy": false, "event": "", "priority": 0, "started": 0.0})
	for i: int in range(POOL_3D):
		var player3d: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
		player3d.bus = Settings.BUS_WORLD
		player3d.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
		player3d.attenuation_filter_db = -10.0
		player3d.attenuation_filter_cutoff_hz = 7000.0
		player3d.panning_strength = 0.7
		add_child(player3d)
		_players_3d.append(player3d)
		_info_3d.append({"busy": false, "event": "", "priority": 0, "started": 0.0})
	_listener = AudioListener3D.new()
	_listener.name = "HeroListener"
	add_child(_listener)
	if DisplayServer.get_name() != "headless":
		MusicSynth.warm_up()
	music = MusicManager.new()
	music.name = "MusicManager"
	add_child(music)
	ambience = AmbienceManager.new()
	ambience.name = "AmbienceManager"
	add_child(ambience)
	ui_sounds = UiSounds.new()
	ui_sounds.name = "UiSounds"
	add_child(ui_sounds)
	_ensure_master_limiter()


## A safety limiter on the Master bus (-1 dBFS ceiling): the music is levelled to sit under the effects, but a sting, a loud effect and the music can still add up
## past full scale in a busy moment; the limiter keeps that from clipping. It does nothing to a normal mix.
func _ensure_master_limiter() -> void:
	for index: int in range(AudioServer.get_bus_effect_count(0)):
		if AudioServer.get_bus_effect(0, index) is AudioEffectHardLimiter:
			return
	var limiter: AudioEffectHardLimiter = AudioEffectHardLimiter.new()
	limiter.ceiling_db = -1.0
	limiter.pre_gain_db = 0.0
	limiter.release = 0.1
	AudioServer.add_bus_effect(0, limiter)


# ---- Effects --------------------------------------------------------------------------------------


## Plays a named sound effect (a bank event, or an old catalog name). `volume_db` is added to the event's level; `pitch_jitter` >= 0 overrides the
## event's random pitch range.
func sfx(sound: StringName, volume_db: float = 0.0, pitch_jitter: float = -1.0) -> void:
	play(sound, {"volume": volume_db, "pitch": pitch_jitter})


## Plays a world sound at a position (3D, heard from the hero, fading with distance).
func sfx_at(sound: StringName, position: Vector3, volume_db: float = 0.0) -> void:
	play(sound, {"volume": volume_db, "position": position})


## Plays an event. Options: `volume` (dB, added), `pitch` (random range override, >= 0), `pitch_scale` (a fixed multiplier, e.g. a speaker's voice),
## `position` (Vector3: plays in 3D), `speed` (layer delays shrink with it; battle events default to the battle speed).
func play(sound: StringName, opts: Dictionary = {}) -> void:
	play_serial += 1
	if STING_ALIASES.has(sound):
		if music.sting(str(STING_ALIASES[sound]), float(opts.get("volume", 0.0))):
			if STING_LAYERS.has(sound):
				play(STING_LAYERS[sound] as StringName, opts)
			return
	var event_name: String = str(sound)
	history.append(event_name)
	play_counts[event_name] = int(play_counts.get(event_name, 0)) + 1
	if history.size() > HISTORY_SIZE:
		history.remove_at(0)
	if not bank.has_event(event_name):
		_play_legacy(sound, float(opts.get("volume", 0.0)), float(opts.get("pitch", -1.0)))
		return
	var event: Dictionary = bank.event(event_name)
	var cooldown: float = float(event.get("cooldown", 0.04))
	# NPC footsteps keep their own cooldown, so a passer-by never swallows the hero's step.
	var cooldown_key: String = event_name + str(opts.get("cooldown_key", ""))
	if _now - float(_last_played.get(cooldown_key, -1000.0)) < cooldown:
		return
	_last_played[cooldown_key] = _now
	if float(event.get("duck", 0.0)) < 0.0:
		duck_moment(float(event["duck"]), 0.45)
	if DisplayServer.get_name() == "headless":
		return
	if not bank.is_playable(event_name):
		note_missing(event_name)
		return
	var bus: String = str(event.get("bus", "Battle"))
	var speed: float = float(opts.get("speed", _battle_speed() if bus == "Battle" else 1.0))
	var jitter: float = float(opts["pitch"]) if float(opts.get("pitch", -1.0)) >= 0.0 else float(event.get("pitch", 0.04))
	var base_pitch: float = picker.pitch(jitter) * float(opts.get("pitch_scale", 1.0))
	var base_volume: float = float(event.get("volume", 0.0)) + float(opts.get("volume", 0.0)) + picker.volume(float(event.get("vol_jitter", 2.0)))
	var spatial: bool = opts.has("position") or bool(event.get("spatial", false))
	var position: Vector3 = opts.get("position", listener_position()) as Vector3
	var layers: Array = event.get("layers", []) as Array
	for layer_index: int in range(layers.size()):
		var layer: Dictionary = layers[layer_index] as Dictionary
		# A layer with a chance plays only that often (a can clinking under some junk footsteps).
		if layer.has("chance") and picker.rng.randf() > float(layer["chance"]):
			continue
		# Each layer counts against the event's instance limit on its own (a three-layer sound is one instance, not three).
		var spec: Dictionary = {
			"event": "%s#%d" % [event_name, layer_index], "set": str(layer.get("set", "")), "bus": bus, "priority": int(opts.get("priority", event.get("priority", 50))),
			"max": int(event.get("max", 3)), "volume": base_volume + float(layer.get("gain", 0.0)),
			"pitch": base_pitch * float(layer.get("pitch", 1.0)) * picker.pitch(0.01), "spatial": spatial, "position": position,
			"range": float(opts.get("range", event.get("range", 0.0))),
		}
		var delay: float = float(layer.get("delay", 0.0)) / maxf(speed, 0.1)
		if delay <= 0.0:
			_start(spec)
		else:
			spec["at"] = _now + delay
			_pending.append(spec)


## Plays one variant of a set directly (ambience one-shots). Options: `bus`, `volume`, `position`, `range`, `priority`, `pitch`, `max`.
func play_set(set_name: String, opts: Dictionary = {}) -> void:
	if DisplayServer.get_name() == "headless":
		return
	var spec: Dictionary = {
		"event": "set:" + set_name, "set": set_name, "bus": str(opts.get("bus", Settings.BUS_SFX)), "priority": int(opts.get("priority", 20)),
		"max": int(opts.get("max", 3)), "volume": float(opts.get("volume", 0.0)) + picker.volume(1.5), "pitch": picker.pitch(float(opts.get("pitch", 0.04))),
		"spatial": opts.has("position"), "position": opts.get("position", Vector3.ZERO) as Vector3, "range": float(opts.get("range", 0.0)),
	}
	_start(spec)


func _start(spec: Dictionary) -> void:
	var files: Array = bank.files(str(spec["set"]))
	if files.is_empty():
		note_missing(str(spec["set"]))
		return
	var path: String = str(files[picker.pick(str(spec["set"]), files.size())])
	var stream: AudioStream = load_stream(path)
	if stream == null:
		return
	var spatial: bool = bool(spec["spatial"])
	var infos: Array[Dictionary] = _info_3d if spatial else _info_2d
	_refresh_busy(spatial)
	var index: int = SfxVoicePolicy.choose(infos, str(spec["event"]), int(spec["priority"]), int(spec["max"]))
	if index < 0:
		return
	infos[index] = {"busy": true, "event": str(spec["event"]), "priority": int(spec["priority"]), "started": _now}
	var bus: StringName = StringName(str(spec["bus"]))
	if spatial:
		var player3d: AudioStreamPlayer3D = _players_3d[index]
		player3d.stop()
		player3d.stream = stream
		player3d.bus = Settings.BUS_WORLD if bus == Settings.BUS_BATTLE or bus == Settings.BUS_SFX else bus
		var reach: float = float(spec["range"]) if float(spec["range"]) > 0.0 else DEFAULT_RANGE
		player3d.max_distance = reach
		player3d.unit_size = maxf(reach * 0.12, 1.0)
		player3d.volume_db = float(spec["volume"])
		player3d.pitch_scale = clampf(float(spec["pitch"]), 0.25, 4.0)
		player3d.global_position = spec["position"] as Vector3
		player3d.play()
	else:
		var player: AudioStreamPlayer = _players_2d[index]
		player.stop()
		player.stream = stream
		player.bus = bus
		player.volume_db = float(spec["volume"])
		player.pitch_scale = clampf(float(spec["pitch"]), 0.25, 4.0)
		player.play()


func _refresh_busy(spatial: bool) -> void:
	if spatial:
		for i: int in range(_players_3d.size()):
			if not _players_3d[i].playing:
				_info_3d[i]["busy"] = false
	else:
		for i: int in range(_players_2d.size()):
			if not _players_2d[i].playing:
				_info_2d[i]["busy"] = false


## Loads (and caches) a stream; `loop` makes an OGG / WAV loop seamlessly (the ambience beds and emitters).
func load_stream(path: String, loop: bool = false) -> AudioStream:
	var key: String = path + ("#loop" if loop else "")
	if _cache.has(key):
		return _cache[key] as AudioStream
	var stream: AudioStream = null
	if ResourceLoader.exists(path):
		stream = load(path) as AudioStream
		if loop and stream != null:
			stream = stream.duplicate() as AudioStream
			if stream is AudioStreamOggVorbis:
				(stream as AudioStreamOggVorbis).loop = true
			elif stream is AudioStreamWAV:
				var wav: AudioStreamWAV = stream as AudioStreamWAV
				wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
				wav.loop_begin = 0
				wav.loop_end = int(wav.get_length() * float(wav.mix_rate))
	_cache[key] = stream
	return stream


func _play_legacy(sound: StringName, volume_db: float, pitch_jitter: float) -> void:
	if DisplayServer.get_name() == "headless":
		return
	var stream: AudioStream = _legacy_stream(sound)
	if stream == null:
		note_missing(str(sound))
		return
	_refresh_busy(false)
	var index: int = SfxVoicePolicy.choose(_info_2d, str(sound), 40, 3)
	if index < 0:
		return
	_info_2d[index] = {"busy": true, "event": str(sound), "priority": 40, "started": _now}
	var jitter: float = pitch_jitter if pitch_jitter >= 0.0 else 0.05
	var player: AudioStreamPlayer = _players_2d[index]
	player.stop()
	player.stream = stream
	player.bus = Settings.BUS_UI if String(sound).begins_with("ui_") else Settings.BUS_BATTLE
	player.volume_db = volume_db
	player.pitch_scale = 1.0 + _rng.randf_range(-jitter, jitter)
	player.play()


func _legacy_stream(sound: StringName) -> AudioStream:
	var options: Array = _catalog.get(sound, [])
	if options.is_empty():
		return MusicSynth.sfx_stream(sound)
	return load_stream(str(options[_rng.randi() % options.size()]))


func note_missing(name_or_set: String) -> void:
	missing_log[name_or_set] = int(missing_log.get(name_or_set, 0)) + 1


func _battle_speed() -> float:
	return Settings.BATTLE_SPEEDS[clampi(Settings.battle_speed, 0, Settings.BATTLE_SPEEDS.size() - 1)]


# ---- Footsteps ------------------------------------------------------------------------------------


## The area the hero walks on (`TownPlayer.setup`): footsteps ask it which surface is under a foot. Weak, so a left scene is never kept alive.
var _ground: WeakRef = null
## How far an NPC's footsteps carry (metres from the hero); further ones are not played at all.
const NPC_STEP_RANGE: float = 11.0


func set_ground(area: WalkableArea) -> void:
	_ground = weakref(area) if area != null else null


## The surface under `position` (grass when there is no area).
func surface_at(position: Vector3) -> StringName:
	var area: WalkableArea = _ground.get_ref() as WalkableArea if _ground != null else null
	return area.surface_at(position) if area != null else &"grass"


## A footstep at `position` on the ground there: the hero's at full level, anyone else's quieter, shorter-reaching and lower in priority.
func footstep(position: Vector3, hero: bool) -> void:
	var event_name: String = "step_" + str(surface_at(position))
	if not bank.has_event(event_name):
		event_name = "step_grass"
	if hero:
		play(StringName(event_name), {"position": position})
		return
	if DisplayServer.get_name() != "headless" and listener_position().distance_to(position) > NPC_STEP_RANGE:
		return
	play(StringName(event_name), {"position": position, "volume": -9.0, "priority": 8, "range": NPC_STEP_RANGE, "cooldown_key": "#npc"})


# ---- Ducking, listener ----------------------------------------------------------------------------


## A short dip of the music and ambience under a big moment (a heavy hit, a trap springing, a death): `db` below, held `hold` seconds, then released.
func duck_moment(db: float, hold: float = 0.45) -> void:
	var deeper: float = db
	var existing: Dictionary = _ducks.get("moment", {}) as Dictionary
	if not existing.is_empty() and float(existing["until"]) > _now:
		deeper = minf(db, float(existing["db"]))
	_ducks["moment"] = {"db": deeper, "until": _now + hold}


## The music's own dialogue duck plus the ambience dipping under the line.
func set_dialogue_duck(owner: int, active: bool) -> void:
	music.set_dialogue_duck(owner, active)
	var key: String = "dialogue_%d" % owner
	if active:
		_ducks[key] = {"db": -5.0, "until": -1.0, "ambience_only": true}
	else:
		_ducks.erase(key)


func duck_level(bus_name: String) -> float:
	return float(_duck_level.get(bus_name, 0.0))


## Where world sounds are heard from: the hero when there is one (the camera's facing, so left is left on screen), else the camera.
func listener_position() -> Vector3:
	if _listener != null and _listener.is_inside_tree() and _listener.is_current():
		return _listener.global_position
	var camera: Camera3D = get_viewport().get_camera_3d() if is_inside_tree() else null
	return camera.global_position if camera != null else Vector3.ZERO


func _update_listener() -> void:
	var hero: Node3D = get_tree().get_first_node_in_group(&"audio_hero") as Node3D
	var camera: Camera3D = get_viewport().get_camera_3d()
	if hero == null or camera == null or not hero.is_inside_tree():
		if _listener.is_current():
			_listener.clear_current()
		return
	_listener.global_transform = Transform3D(camera.global_transform.basis.orthonormalized(), hero.global_position + Vector3(0.0, 1.4, 0.0))
	if not _listener.is_current():
		_listener.make_current()


func _process(delta: float) -> void:
	_now += delta
	if not _pending.is_empty():
		var due: Array[Dictionary] = []
		var keep: Array[Dictionary] = []
		for spec: Dictionary in _pending:
			if float(spec["at"]) <= _now:
				due.append(spec)
			else:
				keep.append(spec)
		_pending = keep
		for spec: Dictionary in due:
			_start(spec)
	advance_ducks(delta)
	if DisplayServer.get_name() != "headless":
		_update_listener()


## One step of the ducks (tests call it directly).
func advance_ducks(delta: float) -> void:
	var targets: Dictionary = {"Music": 0.0, "Ambience": 0.0}
	for key: Variant in _ducks.keys():
		var source: Dictionary = _ducks[key] as Dictionary
		if float(source["until"]) >= 0.0 and float(source["until"]) < _now:
			_ducks.erase(key)
			continue
		var db: float = float(source["db"])
		targets["Ambience"] = minf(float(targets["Ambience"]), db)
		if not bool(source.get("ambience_only", false)):
			targets["Music"] = minf(float(targets["Music"]), db)
	for bus_name: String in targets.keys():
		var level: float = float(_duck_level[bus_name])
		var target: float = float(targets[bus_name])
		# Fast attack (60 dB/s), gentle release (12 dB/s).
		level = maxf(target, level - 60.0 * delta) if target < level else minf(target, level + 12.0 * delta)
		_duck_level[bus_name] = level
		AudioMix.set_duck(bus_name, level)


# ---- Ambience -------------------------------------------------------------------------------------


## The place's ambience profile (`AmbienceProfiles`): "town", "dna", "capital_grave_broken", "none"...
func set_ambience(profile_name: String, fade: float = 2.0) -> void:
	ambience.set_area(profile_name, fade)


# ---- Music ----------------------------------------------------------------------------------------


## The area track (a registry ID such as MUS-TOWN, or a legacy synthesized name): crossfades to it, or keeps playing if it is already the area track.
## An override (battle, shop, story cue) on the stack keeps playing over it. Empty name = silence.
func play_music(track: StringName, fade: float = 1.5) -> void:
	music.set_base(str(track), fade)


## Puts a cue over the area track until `pop_music` (a battle, a vendor's theme, a story scene). Returns the token to pop. A one-shot cue hands back
## by itself when it ends.
func push_music(track: StringName, fade: float = 0.8, auto_pop: bool = true) -> int:
	return music.push(str(track), fade, auto_pop)


func pop_music(token: int = 0, fade: float = 1.2) -> void:
	music.pop(token, fade)


## A musical sting (STG-...) over the music, which ducks while it rings.
func sting(id: StringName, extra_db: float = 0.0) -> void:
	play_serial += 1
	music.sting(str(id), extra_db)


func _exit_tree() -> void:
	MusicSynth.finish()


## Overnight Oct 16 (Block 5b): starts background loads of every bed and one-shot file of the ambience `profiles` (a place's districts), so
## walking into a new district never stalls a frame on a 40-second bed. Returns how many loads it started.
func prewarm_ambience(profiles: Array[String]) -> int:
	var started: int = 0
	for profile_name: String in profiles:
		var profile: Dictionary = AmbienceProfiles.resolved(profile_name)
		var sets: Array = []
		for bed: Variant in profile.get("beds", []) as Array:
			sets.append(str((bed as Dictionary).get("set", "")))
		for shot: Variant in profile.get("oneshots", []) as Array:
			sets.append(str((shot as Dictionary).get("set", "")))
		for set_name: Variant in sets:
			for path: Variant in bank.files(str(set_name)):
				var file: String = str(path)
				if ResourceLoader.exists(file) and not ResourceLoader.has_cached(file) and ResourceLoader.load_threaded_request(file) == OK:
					started += 1
	return started
