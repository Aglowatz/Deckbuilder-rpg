class_name AudioMix
extends RefCounted
## The mix (docs/audio/sound_direction.md, "Mix"): the bus tree, its effects, the ducks and the per-place acoustics.
##
## Master (hard limiter, -1 dBFS) > Music (duck amp), SFX (gentle compressor + limiter) > World (reverb), Battle (small room), UI; Ambience (duck amp), Voice.
## The player's sliders set Master, Music, SFX, UI, Ambience and Voice (`Settings.apply_audio`); World and Battle carry fixed trims (`TRIMS`).
## Ducks (`set_duck`) dip the music and the ambience under big battle moments and dialogue through their amplifiers, so they never fight the sliders.

## [bus, sends to], in creation order (a bus can only send to one created before it).
const LAYOUT: Array = [
	["Music", "Master"], ["SFX", "Master"], ["World", "SFX"], ["Battle", "SFX"], ["UI", "SFX"], ["Ambience", "Master"], ["Voice", "Master"],
]
## Fixed bus trims in dB for the buses without a slider.
const TRIMS: Dictionary = {"World": -1.0, "Battle": -1.5}
const DUCK_BUSES: Array[String] = ["Music", "Ambience"]


static func ensure_layout() -> void:
	for entry: Array in LAYOUT:
		var bus_name: StringName = StringName(str(entry[0]))
		var index: int = AudioServer.get_bus_index(bus_name)
		if index < 0:
			AudioServer.add_bus()
			index = AudioServer.bus_count - 1
			AudioServer.set_bus_name(index, bus_name)
		AudioServer.set_bus_send(index, StringName(str(entry[1])))
	for bus_name: String in TRIMS.keys():
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), float(TRIMS[bus_name]))
	# the leveller before the duck: after it, a ducked passage would fall into the compressed range and the duck would lose half its depth
	_music_leveller()
	for bus_name: String in DUCK_BUSES:
		_effect(bus_name, "AudioEffectAmplify")
	var compressor: AudioEffectCompressor = _effect("SFX", "AudioEffectCompressor") as AudioEffectCompressor
	compressor.threshold = -14.0
	compressor.ratio = 2.5
	compressor.attack_us = 2000.0
	compressor.release_ms = 180.0
	compressor.gain = 0.0
	var limiter: AudioEffectHardLimiter = _effect("SFX", "AudioEffectHardLimiter") as AudioEffectHardLimiter
	limiter.ceiling_db = -2.0
	limiter.release = 0.08
	_effect("World", "AudioEffectReverb")
	var battle_room: AudioEffectReverb = _effect("Battle", "AudioEffectReverb") as AudioEffectReverb
	_set_reverb(battle_room, AcousticProfiles.profile("battle"))
	apply_acoustics("dry")


## Overnight Oct 17 (Phase 2 cycle 10): a gentle leveller on the Music bus. 26 tracks have very wide dynamics (docs/audio/music_audit.md, LRA 15-19 LU)
## and their quiet passages vanished under battle sounds. Measured offline with the same settings (ffmpeg acompressor + ebur128): loudness unchanged
## within 0.3 LU, range arena battle 18.2 -> 12.8 LU, Crosspath freed 15.5 -> 8.7, the Throne 15.3 -> 7.9, credits 18.2 -> 11.4; flat tracks untouched.
## `MUSIC_LEVELLER = false` takes it out.
const MUSIC_LEVELLER: bool = true
const LEVELLER: Dictionary = {"threshold": -30.0, "ratio": 2.0, "attack_us": 30000.0, "release_ms": 500.0, "gain": 6.0}


static func _music_leveller() -> void:
	if not MUSIC_LEVELLER:
		return
	var leveller: AudioEffectCompressor = _effect("Music", "AudioEffectCompressor") as AudioEffectCompressor
	leveller.threshold = float(LEVELLER["threshold"])
	leveller.ratio = float(LEVELLER["ratio"])
	leveller.attack_us = float(LEVELLER["attack_us"])
	leveller.release_ms = float(LEVELLER["release_ms"])
	leveller.gain = float(LEVELLER["gain"])


## The World bus reverb takes a place's profile (`AcousticProfiles`).
static func apply_acoustics(profile_name: String) -> void:
	if AudioServer.get_bus_index(&"World") < 0:
		return
	_set_reverb(_effect("World", "AudioEffectReverb") as AudioEffectReverb, AcousticProfiles.profile(profile_name))


## Sets how far a ducked bus (Music, Ambience) dips right now, in dB (0 = not ducked).
static func set_duck(bus_name: String, db: float) -> void:
	if AudioServer.get_bus_index(bus_name) < 0:
		return
	var amp: AudioEffectAmplify = _effect(bus_name, "AudioEffectAmplify") as AudioEffectAmplify
	amp.volume_db = db


static func duck_of(bus_name: String) -> float:
	if AudioServer.get_bus_index(bus_name) < 0:
		return 0.0
	return (_effect(bus_name, "AudioEffectAmplify") as AudioEffectAmplify).volume_db


static func reverb_of(bus_name: String) -> AudioEffectReverb:
	return _effect(bus_name, "AudioEffectReverb") as AudioEffectReverb


static func _set_reverb(reverb: AudioEffectReverb, values: Dictionary) -> void:
	reverb.room_size = float(values.get("room", 0.3))
	reverb.damping = float(values.get("damping", 0.5))
	reverb.wet = float(values.get("wet", 0.0))
	reverb.dry = float(values.get("dry", 1.0))
	reverb.predelay_msec = float(values.get("predelay", 20.0))
	reverb.spread = float(values.get("spread", 1.0))
	reverb.hipass = float(values.get("hipass", 0.2))


## The bus's effect of that class, added when it is missing.
static func _effect(bus_name: String, class_id: String) -> AudioEffect:
	var bus: int = AudioServer.get_bus_index(bus_name)
	for index: int in range(AudioServer.get_bus_effect_count(bus)):
		var effect: AudioEffect = AudioServer.get_bus_effect(bus, index)
		if effect.get_class() == class_id:
			return effect
	var created: AudioEffect = ClassDB.instantiate(class_id) as AudioEffect
	AudioServer.add_bus_effect(bus, created)
	return created
