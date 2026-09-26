class_name Mana
extends RefCounted
## Mana payment. Every land taps for exactly one mana of its own type; NEUTRAL lands make
## colorless mana that only pays generic costs.


## Fills `out` with lands to tap (from `lands`, which must be untapped) and returns true when
## the cost can be paid. Colored pips need a land of that exact type; generic is paid by
## Neutral lands first, then from the type the player has the most of.
static func plan(
	lands: Array[CardInstance],
	generic: int,
	pips: Array[Affinity.Type],
	out: Array[CardInstance],
) -> bool:
	out.clear()
	var remaining: Array[CardInstance] = lands.duplicate()
	for pip: Affinity.Type in pips:
		var found: CardInstance = null
		for land: CardInstance in remaining:
			if land.data.color == pip:
				found = land
				break
		if found == null:
			return false
		remaining.erase(found)
		out.append(found)
	if remaining.size() < generic:
		return false
	for i: int in range(generic):
		var best: CardInstance = _best_generic_land(remaining)
		remaining.erase(best)
		out.append(best)
	return true


static func can_pay(lands: Array[CardInstance], generic: int, pips: Array[Affinity.Type]) -> bool:
	var scratch: Array[CardInstance] = []
	return plan(lands, generic, pips, scratch)


## True when exactly the given lands pay the cost (used for explicit payment).
static func exact_payment_ok(
	chosen: Array[CardInstance],
	generic: int,
	pips: Array[Affinity.Type],
) -> bool:
	if chosen.size() != generic + pips.size():
		return false
	var remaining: Array[CardInstance] = chosen.duplicate()
	for pip: Affinity.Type in pips:
		var found: CardInstance = null
		for land: CardInstance in remaining:
			if land.data.color == pip:
				found = land
				break
		if found == null:
			return false
		remaining.erase(found)
	return true


static func _best_generic_land(remaining: Array[CardInstance]) -> CardInstance:
	var counts: Dictionary = {}
	for land: CardInstance in remaining:
		counts[land.data.color] = int(counts.get(land.data.color, 0)) + 1
	var best: CardInstance = remaining[0]
	var best_key: int = -1
	for land: CardInstance in remaining:
		# Neutral lands are spent first; otherwise prefer the most plentiful type.
		var key: int = 1000 if land.data.color == Affinity.Type.NEUTRAL else int(counts[land.data.color])
		if key > best_key:
			best_key = key
			best = land
	return best
