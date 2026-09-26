class_name RngUtil
extends RefCounted
## Seeded helpers (Array.shuffle() uses the global RNG, which would break determinism).


static func shuffle(items: Array, rng: RandomNumberGenerator) -> void:
	for i: int in range(items.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var tmp: Variant = items[i]
		items[i] = items[j]
		items[j] = tmp


static func pick(items: Array, rng: RandomNumberGenerator) -> Variant:
	return items[rng.randi_range(0, items.size() - 1)]
