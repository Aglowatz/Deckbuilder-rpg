class_name PathEnergy
extends RefCounted
## Energy payment. Every infrastructure exhausts for exactly one energy of one of the Paths it produces (a basic or special
## one produces its own Path, a dual-Path one either of two, an any-Path one any Path). NEUTRAL infrastructure make colorless
## energy that only pays generic costs. Floating energy (the `pool`, from "add (R)" abilities) is spent first: an entry is an
## Affinity.Type, or PlayerState.POOL_ANY for "one energy of any Path".


## Solves a payment. Returns {"infra": Array[CardInstance], "pool": Array[int]} (the infrastructure to exhaust and the pool
## entries to spend), or an empty Dictionary when the cost cannot be paid.
static func solve(
	infrastructure: Array[CardInstance],
	generic: int,
	pips: Array[Affinity.Type],
	pool: Array[int] = [] as Array[int],
) -> Dictionary:
	var pool_left: Array[int] = pool.duplicate()
	var pool_used: Array[int] = []
	# 1) Pips from the pool: an exact match first, then a wildcard.
	var infra_pips: Array[Affinity.Type] = []
	for pip: Affinity.Type in pips:
		var index: int = pool_left.find(int(pip))
		if index < 0:
			index = pool_left.find(PlayerState.POOL_ANY)
		if index >= 0:
			pool_used.append(pool_left[index])
			pool_left.remove_at(index)
		else:
			infra_pips.append(pip)
	# 2) The remaining pips from infrastructure, by bipartite matching (least flexible infrastructure first).
	var candidates: Array[CardInstance] = infrastructure.duplicate()
	candidates.sort_custom(func(a: CardInstance, b: CardInstance) -> bool: return a.data.produced_paths().size() < b.data.produced_paths().size())
	var matched: Array[CardInstance] = []
	if not _match_pips(infra_pips, candidates, matched):
		return {}
	var free: Array[CardInstance] = []
	for infra: CardInstance in candidates:
		if not matched.has(infra):
			free.append(infra)
	# 3) Generic: the remaining pool first (it empties at end of turn), then infrastructure.
	var to_pay: int = generic
	while to_pay > 0 and not pool_left.is_empty():
		pool_used.append(pool_left.pop_back())
		to_pay -= 1
	var used_infra: Array[CardInstance] = matched.duplicate()
	if free.size() < to_pay:
		return {}
	for i: int in range(to_pay):
		var best: CardInstance = _best_generic_infrastructure(free)
		free.erase(best)
		used_infra.append(best)
	return {"infra": used_infra, "pool": pool_used}


## Fills `out` with infrastructure to exhaust (from `infrastructure`, which must be ready) and returns true when
## the cost can be paid (with the optional floating `pool`; spent pool entries are not part of `out`).
static func plan(
	infrastructure: Array[CardInstance],
	generic: int,
	pips: Array[Affinity.Type],
	out: Array[CardInstance],
	pool: Array[int] = [] as Array[int],
) -> bool:
	out.clear()
	if generic <= 0 and pips.is_empty():
		return true
	var solution: Dictionary = solve(infrastructure, generic, pips, pool)
	if solution.is_empty():
		return false
	out.append_array(solution["infra"] as Array[CardInstance])
	return true


static func can_pay(
	infrastructure: Array[CardInstance],
	generic: int,
	pips: Array[Affinity.Type],
	pool: Array[int] = [] as Array[int],
) -> bool:
	if generic <= 0 and pips.is_empty():
		return true
	return not solve(infrastructure, generic, pips, pool).is_empty()


## True when exactly the given infrastructure pay the cost (used for explicit payment).
static func exact_payment_ok(
	chosen: Array[CardInstance],
	generic: int,
	pips: Array[Affinity.Type],
) -> bool:
	if chosen.size() != generic + pips.size():
		return false
	var matched: Array[CardInstance] = []
	return _match_pips(pips, chosen, matched)


## Assigns each pip to a distinct infrastructure that can produce it (augmenting-path matching). Fills `matched`.
static func _match_pips(pips: Array[Affinity.Type], candidates: Array[CardInstance], matched: Array[CardInstance]) -> bool:
	var owner_of: Dictionary = {}
	for pip_index: int in range(pips.size()):
		var seen: Dictionary = {}
		if not _augment(pip_index, pips, candidates, owner_of, seen):
			return false
	for infra: Variant in owner_of.keys():
		matched.append(infra as CardInstance)
	return true


static func _augment(pip_index: int, pips: Array[Affinity.Type], candidates: Array[CardInstance], owner_of: Dictionary, seen: Dictionary) -> bool:
	for infra: CardInstance in candidates:
		if seen.has(infra) or not infra.data.produced_paths().has(pips[pip_index]):
			continue
		seen[infra] = true
		if not owner_of.has(infra) or _augment(int(owner_of[infra]), pips, candidates, owner_of, seen):
			owner_of[infra] = pip_index
			return true
	return false


static func _best_generic_infrastructure(remaining: Array[CardInstance]) -> CardInstance:
	var counts: Dictionary = {}
	for infra: CardInstance in remaining:
		counts[infra.data.color] = int(counts.get(infra.data.color, 0)) + 1
	var best: CardInstance = remaining[0]
	var best_key: int = -1
	for infra: CardInstance in remaining:
		# Neutral infrastructure are spent first; flexible (dual / any-Path) ones last; otherwise the most plentiful type.
		var key: int
		if infra.data.color == Affinity.Type.NEUTRAL and not infra.data.produces_any:
			key = 1000
		elif infra.data.produced_paths().size() > 1:
			key = 0
		else:
			key = 1 + int(counts[infra.data.color])
		if key > best_key:
			best_key = key
			best = infra
	return best
