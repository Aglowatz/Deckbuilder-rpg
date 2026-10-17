class_name AmbientEmitter
extends AudioStreamPlayer3D
## A landmark's own looping sound placed in the world (docs/audio/sound_direction.md, "Places"): the hamster wheel, the Rotheart's pulse, a fountain, the
## castle's rift hum. Plays a looped variant of a bank set on the Ambience bus with distance falloff; `make` builds one ready to add to a scene.

## The bank set it loops (e.g. "spot/fountain").
var sound_set: String = ""
## Its level at the source, in dB.
var level_db: float = 0.0


static func make(sound: String, position_3d: Vector3, reach: float = 18.0, db: float = 0.0) -> AmbientEmitter:
	var emitter: AmbientEmitter = AmbientEmitter.new()
	emitter.name = "Emitter_" + sound.get_file()
	emitter.sound_set = sound
	emitter.level_db = db
	emitter.position = position_3d
	emitter.max_distance = reach
	emitter.unit_size = maxf(reach * 0.15, 1.0)
	return emitter


func _ready() -> void:
	bus = Settings.BUS_AMBIENCE
	attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
	attenuation_filter_db = -14.0
	attenuation_filter_cutoff_hz = 6000.0
	panning_strength = 0.8
	volume_db = level_db
	if DisplayServer.get_name() == "headless":
		return
	var files: Array = Audio.bank.files(sound_set)
	if files.is_empty():
		Audio.note_missing("emitter:" + sound_set)
		return
	stream = Audio.load_stream(str(files[Audio.picker.pick(sound_set, files.size())]), true)
	if stream != null:
		play(Audio.picker.interval(0.0, maxf(stream.get_length() - 0.5, 0.0)))
