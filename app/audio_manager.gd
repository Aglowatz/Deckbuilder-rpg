extends Node
## Sound effects and music. Sound names live in AudioCatalog; music and stings are registry IDs (`AudioRegistry`, played by `MusicManager`),
## with the synthesized `MusicSynth` tracks as the fallback. Missing files are skipped silently so the game never crashes over audio.

## Effect names that are really musical stings: playing the effect plays the registry sting (ducking the music) when its file exists.
const STING_ALIASES: Dictionary = {
	&"victory": "STG-VICTORY",
	&"defeat": "STG-DEFEAT",
	&"level_up": "STG-LEVEL",
}

const POOL_SIZE: int = 12

var _catalog: Dictionary = AudioCatalog.sounds()
var _cache: Dictionary = {}
var _pool: Array[AudioStreamPlayer] = []
## The music: area track, override stack, stings and ducking (`MusicManager`).
var music: MusicManager
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _last_played: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_rng.randomize()
	for i: int in range(POOL_SIZE):
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.bus = Settings.BUS_SFX
		add_child(player)
		_pool.append(player)
	if DisplayServer.get_name() != "headless":
		MusicSynth.warm_up()
	music = MusicManager.new()
	music.name = "MusicManager"
	add_child(music)
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


## Plays a named sound effect. `pitch_jitter` randomizes pitch a little to avoid repetition.
func sfx(sound: StringName, volume_db: float = 0.0, pitch_jitter: float = 0.05) -> void:
	if STING_ALIASES.has(sound):
		if music.sting(str(STING_ALIASES[sound]), volume_db):
			return
	if DisplayServer.get_name() == "headless":
		return
	var stream: AudioStream = _stream_for(sound)
	if stream == null:
		return
	# Drop identical sounds fired in the same few milliseconds (e.g. many hover events).
	var now: int = Time.get_ticks_msec()
	if now - int(_last_played.get(sound, -1000)) < 40:
		return
	_last_played[sound] = now
	for player: AudioStreamPlayer in _pool:
		if not player.playing:
			player.stream = stream
			player.bus = Settings.BUS_UI if String(sound).begins_with("ui_") else Settings.BUS_SFX
			player.volume_db = volume_db
			player.pitch_scale = 1.0 + _rng.randf_range(-pitch_jitter, pitch_jitter)
			player.play()
			return


func _stream_for(sound: StringName) -> AudioStream:
	var options: Array = _catalog.get(sound, [])
	if options.is_empty():
		return MusicSynth.sfx_stream(sound)
	var path: String = str(options[_rng.randi() % options.size()])
	if _cache.has(path):
		return _cache[path] as AudioStream
	var stream: AudioStream = null
	if ResourceLoader.exists(path):
		stream = load(path) as AudioStream
	_cache[path] = stream
	return stream


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
	music.sting(str(id), extra_db)


func set_dialogue_duck(owner: int, active: bool) -> void:
	music.set_dialogue_duck(owner, active)


func _exit_tree() -> void:
	MusicSynth.finish()
