class_name SfxVariantPicker
extends RefCounted
## Picks which variant of a sound set plays next (docs/audio/sound_direction.md, "Variation"): random, but never the same file twice in a row, and the
## small random pitch and volume offsets that keep a frequent sound from sounding mechanical. Pure: the RNG can be seeded for tests.

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _last: Dictionary = {}


func _init(seed_value: int = -1) -> void:
	if seed_value >= 0:
		rng.seed = seed_value
	else:
		rng.randomize()


## The index (0..count-1) to play for `key`; never the one played last time for that key when there is a choice.
func pick(key: String, count: int) -> int:
	if count <= 1:
		_last[key] = 0
		return 0
	var last: int = int(_last.get(key, -1))
	var index: int = rng.randi_range(0, count - 1 if last < 0 else count - 2)
	if last >= 0 and index >= last:
		index += 1
	_last[key] = index
	return index


## A pitch scale around 1.0, +- `jitter` (0.04 = 4 %).
func pitch(jitter: float) -> float:
	return 1.0 + rng.randf_range(-absf(jitter), absf(jitter))


## A volume offset in dB, +- `jitter_db`.
func volume(jitter_db: float) -> float:
	return rng.randf_range(-absf(jitter_db), absf(jitter_db))


## Seconds until the next ambience one-shot, uniformly within [low, high].
func interval(low: float, high: float) -> float:
	return rng.randf_range(minf(low, high), maxf(low, high))


func last_index(key: String) -> int:
	return int(_last.get(key, -1))
