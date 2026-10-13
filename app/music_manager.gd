class_name MusicManager
extends Node
## Music playback (docs/audio/music_integration.md): equal-power crossfades between area tracks, a stack so story/battle/shop cues override the
## area track and then hand back to it (resuming where it left off), stings that play over the music with the music ducked, and a dialogue duck.
## Owned by the `Audio` autoload (`AudioManager`); scenes call `Audio.play_music` (the area track), `Audio.push_music` / `pop_music` (overrides)
## and `Audio.sting`. Tracks are registry IDs (`AudioRegistry`); a name that is not in the registry falls back to the synthesized `MusicSynth`
## tracks, so nothing is ever silent. Headless runs play no audio but keep the whole state (tests read `current_id()`).

const SILENT_DB: float = -80.0
const DEFAULT_FADE: float = 1.5
const STING_DUCK_DB: float = -9.0
const STING_DUCK_STORY_DB: float = -13.0
const DIALOGUE_DUCK_DB: float = -4.5
const DUCK_ATTACK_DB_PER_SEC: float = 60.0
const DUCK_RELEASE_DB_PER_SEC: float = 14.0
const STING_VOICES: int = 3
const STING_REPEAT_GUARD_MSEC: int = 250
const LOG_LIMIT: int = 400

## One playing stream with its own fade. `gain` runs 0..1 toward `target`; the audible level is equal-power (sin) so a crossfade keeps its loudness.
class Voice:
	extends RefCounted
	var player: AudioStreamPlayer
	var id: String = ""
	var gain: float = 0.0
	var target: float = 0.0
	var rate: float = 1.0
	var base_db: float = 0.0
	var one_shot: bool = false
	var story: bool = false
	var finished: bool = false


var _voices: Array[Voice] = []
var _sting_players: Array[AudioStreamPlayer] = []
var _headless: bool = false
var _base: String = ""
var _base_fade: float = DEFAULT_FADE
## Overrides, topmost last: {token, id, fade, auto_pop}.
var _overlays: Array[Dictionary] = []
var _next_token: int = 1
var _current: String = ""
var _positions: Dictionary = {}
var _duck_current: float = 0.0
var _duck_sources: Dictionary = {}
var _sting_serial: int = 0
var _last_sting_msec: Dictionary = {}
var _log: Array[String] = []
var _print_log: bool = false
var _last_sting: String = ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_headless = DisplayServer.get_name() == "headless"
	_print_log = OS.get_environment("MUSIC_LOG") == "1"
	if _headless:
		return
	for i: int in range(STING_VOICES):
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.bus = Settings.BUS_MUSIC
		add_child(player)
		_sting_players.append(player)


# ---- Requests ---------------------------------------------------------------------------------


## The area track: what plays when no override is up. Asking for the track that is already playing does nothing (no restart).
func set_base(id: String, fade: float = DEFAULT_FADE) -> void:
	if id == _base:
		return
	_note("base %s -> %s (fade %.1f)" % [_base if not _base.is_empty() else "-", id if not id.is_empty() else "-", fade])
	_base = id
	_base_fade = fade
	if _overlays.is_empty():
		_retarget(fade)


## Puts an override on top (a battle, a shop, a story cue): the current track is suspended at its position and resumes when this is popped.
## A one-shot cue pops itself when it ends (`auto_pop`), handing back to what was under it. Returns a token for `pop`.
func push(id: String, fade: float = 0.8, auto_pop: bool = true) -> int:
	if not _overlays.is_empty() and str(_overlays.back()["id"]) == id:
		return int(_overlays.back()["token"])
	var token: int = _next_token
	_next_token += 1
	_note("push %s (token %d, fade %.1f)" % [id, token, fade])
	_overlays.append({"token": token, "id": id, "fade": fade, "auto_pop": auto_pop})
	_retarget(fade)
	return token


## Removes the override of `token` (and nothing else). Token 0 pops the topmost one.
func pop(token: int = 0, fade: float = 1.2) -> void:
	for index: int in range(_overlays.size() - 1, -1, -1):
		if token == 0 or int(_overlays[index]["token"]) == token:
			_note("pop %s (token %d, fade %.1f)" % [str(_overlays[index]["id"]), int(_overlays[index]["token"]), fade])
			var was_top: bool = index == _overlays.size() - 1
			_overlays.remove_at(index)
			if was_top:
				_retarget(fade)
			return


## Drops every override (a new game, the title screen, a loaded save).
func clear_overlays(fade: float = 0.8) -> void:
	if _overlays.is_empty():
		return
	_note("clear overlays (%d)" % _overlays.size())
	_overlays.clear()
	_retarget(fade)


## Plays a sting over the music and ducks the music while it rings. `id` is a registry ID (STG-...); returns false when it has no file.
func sting(id: String, extra_db: float = 0.0) -> bool:
	var found: AudioRegistry.Entry = AudioRegistry.entry(id)
	if found == null:
		return false
	var now: int = Time.get_ticks_msec()
	if now - int(_last_sting_msec.get(id, -10000)) < STING_REPEAT_GUARD_MSEC:
		return true
	_last_sting_msec[id] = now
	_last_sting = id
	_note("sting %s" % id)
	var length: float = maxf(found.duration, 0.5)
	if _headless:
		return true
	var stream: AudioStream = AudioRegistry.stream(id)
	if stream == null:
		return false
	length = maxf(stream.get_length(), 0.5)
	for player: AudioStreamPlayer in _sting_players:
		if not player.playing:
			player.stream = stream
			player.volume_db = found.volume_db + extra_db
			player.play()
			break
	_sting_serial += 1
	var source: String = "sting%d" % _sting_serial
	var story: bool = false
	for voice: Voice in _voices:
		if voice.target > 0.0 and voice.story:
			story = true
	_duck_sources[source] = STING_DUCK_STORY_DB if story else STING_DUCK_DB
	get_tree().create_timer(length + 0.2, true, false, true).timeout.connect(func() -> void: _duck_sources.erase(source))
	return true


## Dialogue is on screen (`owner` is any unique key, e.g. the dialogue box's instance id): the music sits a little lower.
func set_dialogue_duck(owner: int, active: bool) -> void:
	var key: String = "dialogue%d" % owner
	if active:
		_duck_sources[key] = DIALOGUE_DUCK_DB
	else:
		_duck_sources.erase(key)


# ---- State (tests, tools) ---------------------------------------------------------------------


func current_id() -> String:
	return _current


func base_id() -> String:
	return _base


func overlay_ids() -> Array[String]:
	var result: Array[String] = []
	for entry: Dictionary in _overlays:
		result.append(str(entry["id"]))
	return result


func last_sting() -> String:
	return _last_sting


func duck_db() -> float:
	return _duck_current


func event_log() -> Array[String]:
	return _log


# ---- Engine -----------------------------------------------------------------------------------


func _note(text: String) -> void:
	_log.append("%d %s" % [Time.get_ticks_msec(), text])
	if _log.size() > LOG_LIMIT:
		_log.pop_front()
	if _print_log:
		print("[music] %s" % text)


## The ID that should be audible now: the topmost override, else the area track.
func _wanted() -> String:
	if not _overlays.is_empty():
		return str(_overlays.back()["id"])
	return _base


func _retarget(fade: float) -> void:
	var wanted: String = _wanted()
	if wanted == _current:
		return
	_apply(wanted, fade)


func _apply(wanted: String, fade: float) -> void:
	if wanted.is_empty():
		_note("silence")
		_current = ""
		_fade_out_all(fade)
		return
	if _headless:
		_current = wanted
		return
	var actual: String = wanted if AudioRegistry.is_playable(wanted) else MusicDirector.fallback_id(wanted)
	var stream: AudioStream = AudioRegistry.stream(actual) if AudioRegistry.is_playable(actual) else _synth_for(wanted)
	if stream == null:
		# Synth tracks render on a thread at startup: `_process` retries until the stream exists.
		return
	var resume_at: float = 0.0
	if _positions.has(wanted):
		resume_at = float(_positions[wanted])
		_positions.erase(wanted)
	_fade_out_all(fade)
	var voice: Voice = Voice.new()
	voice.player = AudioStreamPlayer.new()
	voice.player.bus = Settings.BUS_MUSIC
	voice.player.stream = stream
	voice.player.volume_db = SILENT_DB
	add_child(voice.player)
	voice.id = wanted
	var found: AudioRegistry.Entry = AudioRegistry.entry(actual) if AudioRegistry.is_playable(actual) else null
	voice.base_db = found.volume_db if found != null else MusicSynth.LEGACY_DB
	voice.one_shot = found != null and not found.loop
	voice.story = found != null and (found.kind == AudioRegistry.Kind.STORY or found.kind == AudioRegistry.Kind.MOTIF)
	voice.gain = 0.0 if fade > 0.0 else 1.0
	voice.target = 1.0
	voice.rate = 1.0 / maxf(fade, 0.01)
	_voices.append(voice)
	voice.player.play(resume_at if resume_at < maxf(stream.get_length() - 1.0, 0.0) else 0.0)
	_current = wanted
	_note("play %s%s%s" % [wanted, (" (fallback %s)" % actual) if actual != wanted else "", (" from %.1fs" % resume_at) if resume_at > 0.0 else ""])


## A name the registry has no file for: a synthesized track of that name, else the plain synthesized map track (never silence).
func _synth_for(id: String) -> AudioStream:
	var stream: AudioStream = MusicSynth.track(StringName(id))
	if stream == null and not MusicSynth.TRACKS.has(StringName(id)):
		stream = MusicSynth.track(&"map")
	return stream


## Fades every sounding voice out; the ones whose ID is still in the stack (an area track under a battle) remember where they were.
func _fade_out_all(fade: float) -> void:
	for voice: Voice in _voices:
		if voice.target <= 0.0:
			continue
		if _in_stack(voice.id) and not voice.one_shot:
			_positions[voice.id] = _position_of(voice)
		voice.target = 0.0
		voice.rate = 1.0 / maxf(fade, 0.01)


func _in_stack(id: String) -> bool:
	if id == _base:
		return true
	for entry: Dictionary in _overlays:
		if str(entry["id"]) == id:
			return true
	return false


func _position_of(voice: Voice) -> float:
	if voice.player == null or not voice.player.playing:
		return 0.0
	var position: float = voice.player.get_playback_position() + AudioServer.get_time_since_last_mix()
	var length: float = voice.player.stream.get_length() if voice.player.stream != null else 0.0
	if length > 0.0:
		position = fmod(position, length)
	return position


func _process(delta: float) -> void:
	if _headless:
		return
	if _wanted() != _current:
		_retarget(_base_fade)
	# Ducking: fast attack, slow release, one combined amount.
	var duck_target: float = 0.0
	for source: Variant in _duck_sources.keys():
		duck_target += float(_duck_sources[source])
	duck_target = maxf(duck_target, -16.0)
	if duck_target < _duck_current:
		_duck_current = maxf(duck_target, _duck_current - DUCK_ATTACK_DB_PER_SEC * delta)
	else:
		_duck_current = minf(duck_target, _duck_current + DUCK_RELEASE_DB_PER_SEC * delta)
	var finished_voices: Array[Voice] = []
	for voice: Voice in _voices:
		voice.gain = move_toward(voice.gain, voice.target, voice.rate * delta)
		var amplitude: float = sin(voice.gain * PI * 0.5)
		voice.player.volume_db = voice.base_db + _duck_current + linear_to_db(maxf(amplitude, 0.0001))
		if voice.target <= 0.0 and voice.gain <= 0.0:
			finished_voices.append(voice)
		elif voice.one_shot and not voice.finished and voice.target > 0.0 and not voice.player.playing and voice.gain > 0.0:
			voice.finished = true
			_one_shot_ended(voice)
	for voice: Voice in finished_voices:
		_voices.erase(voice)
		voice.player.stop()
		voice.player.queue_free()


## A one-shot cue ran out: a story cue on the stack hands back to what was under it (gracefully, over a fade); a base one-shot just ends.
func _one_shot_ended(voice: Voice) -> void:
	_note("ended %s" % voice.id)
	if not _overlays.is_empty():
		var top: Dictionary = _overlays.back() as Dictionary
		if str(top["id"]) == voice.id and bool(top["auto_pop"]):
			pop(int(top["token"]), 1.5)
			return
	_positions.erase(voice.id)
