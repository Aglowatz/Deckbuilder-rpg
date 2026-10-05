class_name MusicSynth
extends RefCounted
## Procedurally generated music loops (original: no third-party audio). Each track is a short
## chord progression rendered from simple synth voices (pads, plucks, bass, soft percussion,
## wind and birds for the town) into a looping AudioStreamWAV. Rendering takes a moment, so
## `warm_up()` renders every track on a background thread at startup.

const RATE: int = 22050

## name -> {bpm, root (midi), progression [[semitone offset, minor?] per bar], layers}
const TRACKS: Dictionary = {
	&"title": {"bpm": 68, "root": 57, "prog": [[0, true], [-4, false], [3, false], [-2, false]], "pad": 0.5, "arp": 0.35, "bass": 0.35, "drums": 0.0, "bell": 0.25, "wind": 0.0},
	&"town": {"bpm": 96, "root": 60, "prog": [[0, false], [7, false], [9, true], [5, false]], "pad": 0.35, "arp": 0.3, "bass": 0.3, "drums": 0.0, "bell": 0.0, "wind": 0.45},
	&"battle": {"bpm": 132, "root": 50, "prog": [[0, true], [-4, false], [3, false], [-2, false]], "pad": 0.3, "arp": 0.32, "bass": 0.45, "drums": 0.55, "bell": 0.0, "wind": 0.0},
	&"map": {"bpm": 58, "root": 52, "prog": [[0, true], [-5, false], [-2, true], [-7, false]], "pad": 0.55, "arp": 0.16, "bass": 0.3, "drums": 0.0, "bell": 0.3, "wind": 0.15},
	## Brief 5: the D.N.A. - a dissonant minor drone with a mains-hum layer and flickering-tube crackle.
	&"dna": {"bpm": 50, "root": 45, "prog": [[0, true], [1, true], [-2, false], [-1, true]], "pad": 0.55, "arp": 0.0, "bass": 0.22, "drums": 0.0, "bell": 0.32, "wind": 0.12, "hum": 0.5},
	## Brief 6: the Gainlands - bright major, pumping bass, light percussion, wind and birds.
	&"gainlands": {"bpm": 112, "root": 62, "prog": [[0, false], [5, false], [7, false], [5, false]], "pad": 0.3, "arp": 0.38, "bass": 0.4, "drums": 0.32, "bell": 0.15, "wind": 0.5},
	## Brief 7: the Endless Buffet - a swinging, sunny major progression with plucky bells and a light shuffle.
	&"buffet": {"bpm": 104, "root": 60, "prog": [[0, false], [9, true], [5, false], [7, false]], "pad": 0.28, "arp": 0.42, "bass": 0.4, "drums": 0.3, "bell": 0.35, "wind": 0.0},
	## Brief 8: the Verdant Dump - a warm, folky major progression with plucks, light shuffle, wind and birds.
	&"heap": {"bpm": 92, "root": 57, "prog": [[0, false], [5, false], [9, true], [7, false]], "pad": 0.3, "arp": 0.4, "bass": 0.34, "drums": 0.18, "bell": 0.28, "wind": 0.4},
	## Brief 10: the Capital - eerily cheerful: a bright major progression with a sour minor-iv turn, bells and a faint mains hum.
	&"capital": {"bpm": 84, "root": 60, "prog": [[0, false], [5, true], [0, false], [7, false]], "pad": 0.3, "arp": 0.3, "bass": 0.22, "drums": 0.0, "bell": 0.5, "wind": 0.1, "hum": 0.25},
	## Primm's Castle - a slow, grand minor drone with echoing bells.
	&"castle": {"bpm": 62, "root": 48, "prog": [[0, true], [-2, false], [-4, true], [-5, false]], "pad": 0.55, "arp": 0.18, "bass": 0.32, "drums": 0.0, "bell": 0.35, "wind": 0.05},
	## The Primm boss duel - hard, driving, a little too tidy.
	&"primm": {"bpm": 138, "root": 45, "prog": [[0, true], [1, true], [-4, false], [-1, true]], "pad": 0.35, "arp": 0.4, "bass": 0.5, "drums": 0.6, "bell": 0.2, "wind": 0.0},
	## The ending - warm and open, the Paths in harmony.
	&"ending": {"bpm": 72, "root": 60, "prog": [[0, false], [7, false], [9, true], [5, false]], "pad": 0.45, "arp": 0.35, "bass": 0.28, "drums": 0.0, "bell": 0.4, "wind": 0.15},
}

static var _cache: Dictionary = {}
static var _mutex: Mutex = Mutex.new()
static var _thread: Thread
static var _cancel: bool = false


static func warm_up() -> void:
	if _thread != null:
		return
	_thread = Thread.new()
	_thread.start(_render_all)


static func _render_all() -> void:
	for name: StringName in TRACKS.keys():
		var stream: AudioStreamWAV = render(name)
		if stream == null:
			return
		_mutex.lock()
		_cache[name] = stream
		_mutex.unlock()


## Stops the background rendering (called when the game quits).
static func finish() -> void:
	_cancel = true
	if _thread != null and _thread.is_started():
		_thread.wait_to_finish()


## The rendered track, or null while the background thread has not finished it yet.
static func track(name: StringName) -> AudioStream:
	_mutex.lock()
	var found: Variant = _cache.get(name)
	_mutex.unlock()
	return found as AudioStream


static func midi_to_hz(note: float) -> float:
	return 440.0 * pow(2.0, (note - 69.0) / 12.0)


static func render(name: StringName) -> AudioStreamWAV:
	var config: Dictionary = TRACKS[name]
	var bpm: float = float(config["bpm"])
	var beat: float = 60.0 / bpm
	var bar: float = beat * 4.0
	var prog: Array = config["prog"] as Array
	var bars: int = prog.size() * 2
	var total: int = int(bar * float(bars) * float(RATE))
	var buffer: PackedFloat32Array = PackedFloat32Array()
	buffer.resize(total)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = hash(str(name))
	var root: int = int(config["root"])
	var scale_minor: Array[int] = [0, 2, 3, 5, 7, 8, 10]
	var scale_major: Array[int] = [0, 2, 4, 5, 7, 9, 11]
	for bar_index: int in range(bars):
		if _cancel:
			return null
		var chord: Array = prog[bar_index % prog.size()] as Array
		var chord_root: int = root + int(chord[0])
		var minor: bool = bool(chord[1])
		var third: int = 3 if minor else 4
		var notes: Array[int] = [chord_root, chord_root + third, chord_root + 7]
		var bar_start: float = bar * float(bar_index)
		if float(config["pad"]) > 0.0:
			for note: int in notes:
				_pad(buffer, bar_start, bar, midi_to_hz(float(note)), float(config["pad"]) * 0.33)
				_pad(buffer, bar_start, bar, midi_to_hz(float(note + 12)) * 1.003, float(config["pad"]) * 0.16)
		if float(config["bass"]) > 0.0:
			var steps: int = 8 if float(config["drums"]) > 0.0 else 4
			for step: int in range(steps):
				var when: float = bar_start + bar * float(step) / float(steps)
				var bass_note: int = chord_root - 12
				if step % 4 == 2:
					bass_note += 7
				_pluck(buffer, when, midi_to_hz(float(bass_note)), float(config["bass"]) * 0.6, 3.2, 0.0)
		if float(config["arp"]) > 0.0:
			var scale: Array[int] = scale_minor if minor else scale_major
			var per_bar: int = 8
			for step: int in range(per_bar):
				var when: float = bar_start + bar * float(step) / float(per_bar)
				var pool: Array[int] = [notes[0], notes[1], notes[2], notes[0] + 12, notes[1] + 12, notes[2] + 12]
				var pick: int = pool[(step * 3 + bar_index) % pool.size()] if step % 2 == 0 else pool[rng.randi() % pool.size()]
				if rng.randf() < 0.22:
					continue
				_pluck(buffer, when, midi_to_hz(float(pick + 12)), float(config["arp"]) * 0.5, 5.0, 0.35)
			if scale.is_empty():
				pass
		if float(config["bell"]) > 0.0 and bar_index % 2 == 0:
			var bell_note: int = notes[2] + 24 if rng.randf() < 0.5 else notes[1] + 24
			_pluck(buffer, bar_start + beat * 1.5, midi_to_hz(float(bell_note)), float(config["bell"]) * 0.5, 1.6, 0.9)
		if float(config["drums"]) > 0.0:
			for step: int in range(8):
				var when: float = bar_start + bar * float(step) / 8.0
				if step % 2 == 0:
					_kick(buffer, when, float(config["drums"]) * 0.8)
				else:
					_hat(buffer, when, float(config["drums"]) * 0.35, rng)
				if step == 4 or step == 12 % 8 and step == 4:
					_hat(buffer, when + bar / 16.0, float(config["drums"]) * 0.25, rng)
	if float(config.get("hum", 0.0)) > 0.0:
		_hum(buffer, float(config["hum"]), rng)
	if float(config["wind"]) > 0.0:
		_wind(buffer, float(config["wind"]), rng)
		if name == &"town" or name == &"gainlands" or name == &"heap":
			_birds(buffer, rng, total)
	return _to_stream(buffer)


static func _add(buffer: PackedFloat32Array, index: int, value: float) -> void:
	var count: int = buffer.size()
	buffer[index % count] += value


static func _pad(buffer: PackedFloat32Array, start: float, length: float, freq: float, volume: float) -> void:
	var first: int = int(start * float(RATE))
	var count: int = int(length * float(RATE))
	var attack: float = length * 0.35
	var release: float = length * 0.35
	for i: int in range(count):
		var t: float = float(i) / float(RATE)
		var env: float = minf(t / attack, 1.0) * minf((length - t) / release, 1.0)
		var phase: float = TAU * freq * t
		var sample: float = sin(phase) + 0.4 * sin(phase * 2.0) + 0.15 * sin(phase * 3.0)
		_add(buffer, first + i, sample * env * volume * 0.5)


static func _pluck(buffer: PackedFloat32Array, start: float, freq: float, volume: float, decay: float, shimmer: float) -> void:
	var first: int = int(start * float(RATE))
	var count: int = int(minf(2.2, 8.0 / decay) * float(RATE))
	for i: int in range(count):
		var t: float = float(i) / float(RATE)
		var env: float = exp(-t * decay) * minf(t / 0.004, 1.0)
		var phase: float = TAU * freq * t
		var sample: float = sin(phase) + 0.35 * sin(phase * 2.0) * exp(-t * decay * 1.5) + shimmer * 0.4 * sin(phase * 3.01)
		_add(buffer, first + i, sample * env * volume * 0.45)


static func _kick(buffer: PackedFloat32Array, start: float, volume: float) -> void:
	var first: int = int(start * float(RATE))
	var count: int = int(0.22 * float(RATE))
	var phase: float = 0.0
	for i: int in range(count):
		var t: float = float(i) / float(RATE)
		var freq: float = 45.0 + 110.0 * exp(-t * 28.0)
		phase += TAU * freq / float(RATE)
		_add(buffer, first + i, sin(phase) * exp(-t * 13.0) * volume * 0.7)


static func _hat(buffer: PackedFloat32Array, start: float, volume: float, rng: RandomNumberGenerator) -> void:
	var first: int = int(start * float(RATE))
	var count: int = int(0.045 * float(RATE))
	var last: float = 0.0
	for i: int in range(count):
		var t: float = float(i) / float(RATE)
		var noise: float = rng.randf_range(-1.0, 1.0)
		var high: float = noise - last
		last = noise
		_add(buffer, first + i, high * exp(-t * 90.0) * volume * 0.5)


static func _wind(buffer: PackedFloat32Array, volume: float, rng: RandomNumberGenerator) -> void:
	var count: int = buffer.size()
	var low: float = 0.0
	var low2: float = 0.0
	for i: int in range(count):
		var t: float = float(i) / float(RATE)
		low += 0.02 * (rng.randf_range(-1.0, 1.0) - low)
		low2 += 0.05 * (low - low2)
		# Two slow swells whose periods divide the loop length keep the seam clean.
		var swell: float = 0.55 + 0.45 * sin(TAU * t * (2.0 / (float(count) / float(RATE))))
		buffer[i] += low2 * 5.0 * swell * volume * 0.5


## Office ambience: a 100/200/300 Hz fluorescent hum (whole cycles per loop so the seam is clean) with
## a slow swell and short crackle bursts - the flickering tubes.
static func _hum(buffer: PackedFloat32Array, volume: float, rng: RandomNumberGenerator) -> void:
	var count: int = buffer.size()
	var seconds: float = float(count) / float(RATE)
	for i: int in range(count):
		var t: float = float(i) / float(RATE)
		var swell: float = 0.8 + 0.2 * sin(TAU * t * (3.0 / seconds))
		var tone: float = sin(TAU * 100.0 * t) * 0.5 + sin(TAU * 200.0 * t) * 0.25 + sin(TAU * 300.0 * t) * 0.12
		buffer[i] += tone * swell * volume * 0.07
	for burst: int in range(16):
		var start: int = rng.randi_range(0, count - RATE / 4)
		var length: int = rng.randi_range(RATE / 40, RATE / 12)
		var last: float = 0.0
		for i: int in range(length):
			var noise: float = rng.randf_range(-1.0, 1.0)
			var high: float = noise - last
			last = noise
			var env: float = exp(-float(i) / float(length) * 5.0)
			_add(buffer, start + i, high * env * volume * 0.09)


static func _birds(buffer: PackedFloat32Array, rng: RandomNumberGenerator, total: int) -> void:
	var chirps: int = 9
	for chirp: int in range(chirps):
		var start: int = rng.randi_range(0, total - RATE)
		var base: float = rng.randf_range(2400.0, 3600.0)
		var notes: int = rng.randi_range(2, 4)
		for note: int in range(notes):
			var length: int = int(0.09 * float(RATE))
			var offset: int = start + note * int(0.13 * float(RATE))
			var phase: float = 0.0
			for i: int in range(length):
				var t: float = float(i) / float(length)
				var freq: float = base * (1.0 + 0.35 * sin(t * PI)) * (1.0 + 0.08 * float(note))
				phase += TAU * freq / float(RATE)
				var env: float = sin(t * PI)
				_add(buffer, offset + i, sin(phase) * env * 0.05)


static func _to_stream(buffer: PackedFloat32Array) -> AudioStreamWAV:
	var peak: float = 0.0001
	for value: float in buffer:
		peak = maxf(peak, absf(value))
	var gain: float = 0.7 / peak
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(buffer.size() * 2)
	for i: int in range(buffer.size()):
		var sample: float = clampf(buffer[i] * gain, -1.0, 1.0)
		bytes.encode_s16(i * 2, int(sample * 32000.0))
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = RATE
	stream.stereo = false
	stream.data = bytes
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = buffer.size()
	return stream


# ---- Short synthesized sound effects (brief 7): sounds that no sample pack covers ------------------------

static var _sfx_cache: Dictionary = {}


## A short synthesized effect by name ("boing", "splash", "ding"), or null for an unknown name. Cached.
static func sfx_stream(sound: StringName) -> AudioStreamWAV:
	if _sfx_cache.has(sound):
		return _sfx_cache[sound] as AudioStreamWAV
	var buffer: PackedFloat32Array = PackedFloat32Array()
	match sound:
		&"boing":
			buffer = _render_boing()
		&"splash":
			buffer = _render_splash()
		&"ding":
			buffer = _render_ding()
		_:
			return null
	var stream: AudioStreamWAV = _to_stream(buffer)
	stream.loop_mode = AudioStreamWAV.LOOP_DISABLED
	_sfx_cache[sound] = stream
	return stream


## A springy "boing": a sine that sweeps up and wobbles while it decays.
static func _render_boing() -> PackedFloat32Array:
	var length: int = int(0.55 * float(RATE))
	var buffer: PackedFloat32Array = PackedFloat32Array()
	buffer.resize(length)
	var phase: float = 0.0
	for i: int in range(length):
		var t: float = float(i) / float(RATE)
		var freq: float = 150.0 + 420.0 * (1.0 - exp(-t * 7.0)) + 40.0 * sin(TAU * 14.0 * t)
		phase += TAU * freq / float(RATE)
		var env: float = exp(-t * 5.5) * minf(t * 220.0, 1.0)
		buffer[i] = (sin(phase) * 0.8 + sin(phase * 2.0) * 0.25) * env * 0.6
	return buffer


## A wet splash: low-passed noise with a quick bubbling sweep.
static func _render_splash() -> PackedFloat32Array:
	var length: int = int(0.7 * float(RATE))
	var buffer: PackedFloat32Array = PackedFloat32Array()
	buffer.resize(length)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 77
	var low: float = 0.0
	var phase: float = 0.0
	for i: int in range(length):
		var t: float = float(i) / float(RATE)
		low += 0.22 * (rng.randf_range(-1.0, 1.0) - low)
		var env: float = exp(-t * 6.0)
		var bubble_freq: float = 300.0 + 700.0 * fposmod(t * 9.0, 1.0)
		phase += TAU * bubble_freq / float(RATE)
		buffer[i] = (low * 1.4 + sin(phase) * 0.12 * exp(-t * 4.0)) * env * 0.7
	return buffer


## A diner service bell: bright metallic partials with a long ring.
static func _render_ding() -> PackedFloat32Array:
	var length: int = int(1.1 * float(RATE))
	var buffer: PackedFloat32Array = PackedFloat32Array()
	buffer.resize(length)
	for i: int in range(length):
		var t: float = float(i) / float(RATE)
		var env: float = exp(-t * 4.2)
		var tone: float = sin(TAU * 1568.0 * t) + 0.6 * sin(TAU * 2349.0 * t) + 0.35 * sin(TAU * 3136.0 * t) + 0.2 * sin(TAU * 4186.0 * t)
		buffer[i] = tone * env * 0.22
	return buffer
