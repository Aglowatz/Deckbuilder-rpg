class_name PathEnergy
extends RefCounted
## energy payment. Every infrastructure activates for exactly one energy of its own type; NEUTRAL infrastructure make
## colorless energy that only pays generic costs.


## Fills `out` with infrastructure to activate (from `infrastructure`, which must be ready) and returns true when
## the cost can be paid. Colored pips need an infrastructure of that exact type; generic is paid by
## Neutral infrastructure first, then from the type the player has the most of.
static func plan(
	infrastructure: Array[CardInstance],
	generic: int,
	pips: Array[Affinity.Type],
	out: Array[CardInstance],
) -> bool:
	out.clear()
	var remaining: Array[CardInstance] = infrastructure.duplicate()
	for pip: Affinity.Type in pips:
		var found: CardInstance = null
		for infra: CardInstance in remaining:
			if infra.data.color == pip:
				found = infra
				break
		if found == null:
			return false
		remaining.erase(found)
		out.append(found)
	if remaining.size() < generic:
		return false
	for i: int in range(generic):
		var best: CardInstance = _best_generic_infrastructure(remaining)
		remaining.erase(best)
		out.append(best)
	return true


static func can_pay(infrastructure: Array[CardInstance], generic: int, pips: Array[Affinity.Type]) -> bool:
	var scratch: Array[CardInstance] = []
	return plan(infrastructure, generic, pips, scratch)


## True when exactly the given infrastructure pay the cost (used for explicit payment).
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
		for infra: CardInstance in remaining:
			if infra.data.color == pip:
				found = infra
				break
		if found == null:
			return false
		remaining.erase(found)
	return true


static func _best_generic_infrastructure(remaining: Array[CardInstance]) -> CardInstance:
	var counts: Dictionary = {}
	for infra: CardInstance in remaining:
		counts[infra.data.color] = int(counts.get(infra.data.color, 0)) + 1
	var best: CardInstance = remaining[0]
	var best_key: int = -1
	for infra: CardInstance in remaining:
		# Neutral infrastructure are spent first; otherwise prefer the most plentiful type.
		var key: int = 1000 if infra.data.color == Affinity.Type.NEUTRAL else int(counts[infra.data.color])
		if key > best_key:
			best_key = key
			best = infra
	return best
