class_name DraftEngine
extends RefCounted
## Draft mode, Phase 1 (docs/design/draft_mode.md): the rules of a draft. Pure and deterministic: an offer depends only on the
## draft's seed, the step and how often the step was rerolled, so a saved draft resumes on the same three options.
##   start -> 25 card picks (one of three; every 5th from the top two rarities), 5 equipment picks (each a different random slot,
##   three pieces) after picks 4, 9, 14, 19 and 23, 2 item picks after picks 7 and 17, one reroll for any offer -> the deck:
##   20 of the 25 plus 15 basic Infrastructure split across the drafted Paths -> the run (`DraftRun`).
## The numbers are DraftRules' (data/draft/draft_rules.json).

const KIND_CARD: String = "card"
const KIND_EQUIPMENT: String = "equipment"
const KIND_ITEM: String = "item"
## The buckets of the cost curve: 0, 1, 2, 3, 4, 5, 6 and more.
const CURVE_BUCKETS: int = 7
## The share of the 20 a deck wants in each cost bucket (a guide for the "fit" of an offer and for the rivals' picks).
const IDEAL_CURVE: Array[float] = [0.02, 0.16, 0.26, 0.24, 0.16, 0.10, 0.06]


## The steps of a draft in order: {"kind": "card" | "equipment" | "item", "pick": n} (n counts within its kind, from 1).
static func schedule() -> Array[Dictionary]:
	var steps: Array[Dictionary] = []
	var gear_after: Array[int] = DraftRules.int_list("equipment_picks_after")
	var items_after: Array[int] = DraftRules.int_list("item_picks_after")
	var gear: int = 0
	var items: int = 0
	for pick: int in range(1, DraftRules.card_picks() + 1):
		steps.append({"kind": KIND_CARD, "pick": pick})
		if gear_after.has(pick):
			gear += 1
			steps.append({"kind": KIND_EQUIPMENT, "pick": gear})
		if items_after.has(pick):
			items += 1
			steps.append({"kind": KIND_ITEM, "pick": items})
	return steps


## A new draft with its first offer on the table. `paths` are Affinity.Type values (NEUTRAL is never one of them).
static func start(content: ContentSet, challenge_id: String, paths: Array[int], level: int, seed_value: int, two_path_ok: bool = false, multi_path_ok: bool = false) -> DraftState:
	var state: DraftState = DraftState.new()
	state.challenge_id = challenge_id
	state.paths = paths.duplicate()
	state.paths.sort()
	state.level = maxi(1, level)
	state.seed = maxi(1, seed_value)
	state.two_path_ok = two_path_ok
	state.multi_path_ok = multi_path_ok
	state.rerolls_left = DraftRules.rerolls()
	state.phase = DraftState.PHASE_PICK
	make_offer(content, state)
	return state


# ---- The pools --------------------------------------------------------------------------------------------------------------------


## True when `card` may be offered in a draft of these Paths: a collectible card that is not a foe's own, every one of its Paths
## among the chosen ones (Pathless cards always), two-Path cards only once all four zones are freed, three- and four-Path cards
## only after Primm (the same lock as everywhere else).
static func card_allowed(card: CardData, paths: Array[int], two_path_ok: bool, multi_path_ok: bool) -> bool:
	if card == null or card.is_token or card.is_unlimited() or CardAvailability.is_enemy_only(card):
		return false
	if DraftRules.banned("banned_cards").has(card.id):
		return false
	var own: Array[Affinity.Type] = card.paths()
	for path: Affinity.Type in own:
		if not paths.has(int(path)):
			return false
	if own.size() >= MultiPathLock.MIN_PATHS:
		return multi_path_ok
	if own.size() == 2:
		return two_path_ok
	return true


static func card_pool(content: ContentSet, state: DraftState) -> Array[CardData]:
	var pool: Array[CardData] = []
	for card: CardData in content.all_collectible():
		if card_allowed(card, state.paths, state.two_path_ok, state.multi_path_ok):
			pool.append(card)
	pool.sort_custom(func(a: CardData, b: CardData) -> bool: return a.id < b.id)
	return pool


## Every piece of equipment in the game minus the ban list, by slot.
static func equipment_pool(content: ContentSet, slot: int = -1) -> Array[EquipmentData]:
	var banned: Dictionary = DraftRules.banned("banned_equipment")
	var pool: Array[EquipmentData] = []
	for piece: EquipmentData in GearCatalog.all_pieces(content):
		if piece == null or banned.has(piece.id) or (slot >= 0 and int(piece.slot) != slot):
			continue
		pool.append(piece)
	pool.sort_custom(func(a: EquipmentData, b: EquipmentData) -> bool: return a.id < b.id)
	return pool


static func item_pool(content: ContentSet) -> Array[ItemData]:
	var banned: Dictionary = DraftRules.banned("banned_items")
	var ids: Array = content.items.keys()
	ids.sort()
	var pool: Array[ItemData] = []
	for id: Variant in ids:
		var item: ItemData = content.item(str(id))
		if item != null and not banned.has(item.id):
			pool.append(item)
	return pool


# ---- Offers -----------------------------------------------------------------------------------------------------------------------


static func _rng(state: DraftState, salt: int = 0) -> RandomNumberGenerator:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = hash([state.seed, state.step, state.rerolled, salt])
	return rng


## Puts the offer of the current step on the table (or moves on to the deck when the steps are done).
static func make_offer(content: ContentSet, state: DraftState) -> void:
	var steps: Array[Dictionary] = schedule()
	if state.step >= steps.size():
		state.offer = {}
		state.phase = DraftState.PHASE_DECK
		auto_deck(content, state)
		return
	var step: Dictionary = steps[state.step]
	match str(step["kind"]):
		KIND_CARD:
			var high: bool = DraftRules.high_rarity_every() > 0 and int(step["pick"]) % DraftRules.high_rarity_every() == 0
			state.offer = {"kind": KIND_CARD, "pick": int(step["pick"]), "high": high, "options": card_offer(content, state, high)}
		KIND_EQUIPMENT:
			var slot: int = _next_slot(content, state)
			state.offer = {"kind": KIND_EQUIPMENT, "pick": int(step["pick"]), "slot": slot, "options": equipment_offer(content, state, slot)}
		_:
			state.offer = {"kind": KIND_ITEM, "pick": int(step["pick"]), "options": item_offer(content, state)}
	if (state.offer["options"] as Array).is_empty():
		# nothing to offer (a pool emptied by the ban list): the step is skipped
		state.step += 1
		state.rerolled = 0
		make_offer(content, state)


## Three different cards. Each slot first draws a rarity by its weight, then a card of that rarity by its fit to the picks so
## far; a high-rarity pick draws from the top two rarities. Never three duds: when no option is a unit or a cheap card, the last
## one is replaced by a fitting unit.
static func card_offer(content: ContentSet, state: DraftState, high: bool) -> Array[String]:
	var rng: RandomNumberGenerator = _rng(state)
	var pool: Array[CardData] = card_pool(content, state)
	var picked: Array[CardData] = picked_cards(content, state)
	var chosen: Array[CardData] = []
	for i: int in range(DraftRules.options()):
		var card: CardData = _draw_card(pool, chosen, picked, state, high, rng)
		if card != null:
			chosen.append(card)
	if not chosen.is_empty() and not _has_playable(chosen):
		var units: Array[CardData] = []
		for card: CardData in pool:
			if card.is_unit() and card.energy_value() <= 4 and not chosen.has(card) and (not high or int(card.rarity) >= int(CardEnums.Rarity.EPIC)):
				units.append(card)
		var better: CardData = _weighted_by_fit(units, picked, state, rng)
		if better != null:
			chosen[chosen.size() - 1] = better
	var ids: Array[String] = []
	for card: CardData in chosen:
		ids.append(card.id)
	return ids


static func _has_playable(cards: Array[CardData]) -> bool:
	for card: CardData in cards:
		if card.is_unit() or card.energy_value() <= 3:
			return true
	return false


static func _draw_card(pool: Array[CardData], taken: Array[CardData], picked: Array[CardData], state: DraftState, high: bool, rng: RandomNumberGenerator) -> CardData:
	# the rarities that still have a card to give, with their weights
	var by_rarity: Dictionary = {}
	for card: CardData in pool:
		if taken.has(card):
			continue
		if not by_rarity.has(int(card.rarity)):
			by_rarity[int(card.rarity)] = [] as Array[CardData]
		(by_rarity[int(card.rarity)] as Array[CardData]).append(card)
	if by_rarity.is_empty():
		return null
	var rarities: Array = by_rarity.keys()
	rarities.sort()
	var total: float = 0.0
	for rarity: Variant in rarities:
		total += DraftRules.card_weight(int(rarity) as CardEnums.Rarity, high)
	var rarity_pick: int = int(rarities[rarities.size() - 1])  # no weighted rarity has a card left: the best there is
	if total > 0.0:
		var roll: float = rng.randf() * total
		for rarity: Variant in rarities:
			roll -= DraftRules.card_weight(int(rarity) as CardEnums.Rarity, high)
			if roll <= 0.0:
				rarity_pick = int(rarity)
				break
	return _weighted_by_fit(by_rarity[rarity_pick] as Array[CardData], picked, state, rng)


static func _weighted_by_fit(cards: Array[CardData], picked: Array[CardData], state: DraftState, rng: RandomNumberGenerator) -> CardData:
	if cards.is_empty():
		return null
	var weights: Array[float] = []
	var total: float = 0.0
	for card: CardData in cards:
		var weight: float = 1.0 + DraftRules.fit_weight() * fit(card, picked, state.paths)
		weights.append(weight)
		total += weight
	var roll: float = rng.randf() * total
	for i: int in range(cards.size()):
		roll -= weights[i]
		if roll <= 0.0:
			return cards[i]
	return cards[cards.size() - 1]


## How well `card` fits what is already taken, 0 to 1: half from its Path's share of the picks so far (a Pathless card fits any
## deck a little), half from the cost curve (a bucket the deck is short of) and from units while the deck has few.
static func fit(card: CardData, picked: Array[CardData], paths: Array[int]) -> float:
	if picked.is_empty():
		return 0.5
	var own: Array[Affinity.Type] = card.paths()
	var path_fit: float = 0.5
	if not own.is_empty() and paths.size() > 1:
		var on_path: int = 0
		for other: CardData in picked:
			for path: Affinity.Type in own:
				if other.is_on_path(path):
					on_path += 1
					break
		path_fit = float(on_path) / float(picked.size())
	elif not own.is_empty():
		path_fit = 0.7
	var counts: Array[int] = curve_of(picked)
	var bucket: int = mini(card.energy_value(), CURVE_BUCKETS - 1)
	var have: float = float(counts[bucket]) / float(picked.size())
	var curve_fit: float = clampf(0.5 + (IDEAL_CURVE[bucket] - have) * 2.5, 0.0, 1.0)
	var units: int = 0
	for other: CardData in picked:
		if other.is_unit():
			units += 1
	if card.is_unit() and float(units) / float(picked.size()) < 0.5:
		curve_fit = minf(1.0, curve_fit + 0.3)
	return clampf(path_fit * 0.5 + curve_fit * 0.5, 0.0, 1.0)


## The slot of the next equipment pick: each of the five picks is a different slot, in an order the seed decides.
static func _next_slot(content: ContentSet, state: DraftState) -> int:
	var used: Dictionary = {}
	for id: String in state.equipment:
		var piece: EquipmentData = content.equipment_piece(id)
		if piece != null:
			used[int(piece.slot)] = true
	var free: Array[int] = []
	for slot: int in range(EquipmentData.Slot.size()):
		if not used.has(slot) and equipment_pool(content, slot).size() > 0:
			free.append(slot)
	if free.is_empty():
		for slot: int in range(EquipmentData.Slot.size()):
			free.append(slot)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = hash([state.seed, state.step, 77])  # not the reroll count: a reroll keeps the slot and changes the pieces
	return free[rng.randi() % free.size()]


## Three different pieces of `slot`, weighted by rarity.
static func equipment_offer(content: ContentSet, state: DraftState, slot: int) -> Array[String]:
	var rng: RandomNumberGenerator = _rng(state, 1)
	var pool: Array[EquipmentData] = equipment_pool(content, slot)
	var ids: Array[String] = []
	while ids.size() < DraftRules.options() and not pool.is_empty():
		var total: float = 0.0
		for piece: EquipmentData in pool:
			total += DraftRules.equipment_weight(piece.rarity)
		var roll: float = rng.randf() * total
		var index: int = pool.size() - 1
		for i: int in range(pool.size()):
			roll -= DraftRules.equipment_weight(pool[i].rarity)
			if roll <= 0.0:
				index = i
				break
		ids.append(pool[index].id)
		pool.remove_at(index)
	return ids


## Three different items the draft does not hold yet.
static func item_offer(content: ContentSet, state: DraftState) -> Array[String]:
	var rng: RandomNumberGenerator = _rng(state, 2)
	var pool: Array[ItemData] = []
	for item: ItemData in item_pool(content):
		if not state.items.has(item.id):
			pool.append(item)
	var ids: Array[String] = []
	while ids.size() < DraftRules.options() and not pool.is_empty():
		var index: int = rng.randi() % pool.size()
		ids.append(pool[index].id)
		pool.remove_at(index)
	return ids


# ---- Picking ----------------------------------------------------------------------------------------------------------------------


## Takes option `index` of the offer on the table and puts the next offer down. False when there is no such option.
static func pick(content: ContentSet, state: DraftState, index: int) -> bool:
	if state.phase != DraftState.PHASE_PICK or state.offer.is_empty():
		return false
	var options: Array = state.offer.get("options", []) as Array
	if index < 0 or index >= options.size():
		return false
	var id: String = str(options[index])
	match str(state.offer.get("kind", "")):
		KIND_CARD:
			state.cards.append(id)
		KIND_EQUIPMENT:
			state.equipment.append(id)
		_:
			state.items.append(id)
	state.step += 1
	state.rerolled = 0
	make_offer(content, state)
	return true


## Spends the reroll on the offer on the table: three new options of the same kind (the same slot for equipment).
static func reroll(content: ContentSet, state: DraftState) -> bool:
	if state.phase != DraftState.PHASE_PICK or state.rerolls_left <= 0 or state.offer.is_empty():
		return false
	state.rerolls_left -= 1
	state.rerolled += 1
	make_offer(content, state)
	return true


static func picked_cards(content: ContentSet, state: DraftState) -> Array[CardData]:
	var result: Array[CardData] = []
	for id: String in state.cards:
		var card: CardData = content.card(id)
		if card != null:
			result.append(card)
	return result


static func card_picks_done(state: DraftState) -> int:
	return state.cards.size()


# ---- The curve and the Paths (the pick screen shows both) -------------------------------------------------------------------------


static func curve_of(cards: Array[CardData]) -> Array[int]:
	var counts: Array[int] = []
	counts.resize(CURVE_BUCKETS)
	counts.fill(0)
	for card: CardData in cards:
		counts[mini(card.energy_value(), CURVE_BUCKETS - 1)] += 1
	return counts


## Cards per Path among `cards` (Affinity.Type value -> count; NEUTRAL counts the Pathless ones; a two-Path card counts for both).
static func path_split(cards: Array[CardData]) -> Dictionary:
	var split: Dictionary = {}
	for card: CardData in cards:
		var own: Array[Affinity.Type] = card.paths()
		if own.is_empty():
			split[int(Affinity.Type.NEUTRAL)] = int(split.get(int(Affinity.Type.NEUTRAL), 0)) + 1
		for path: Affinity.Type in own:
			split[int(path)] = int(split.get(int(path), 0)) + 1
	return split


# ---- The deck: 20 of the 25 and 15 basic Infrastructure ---------------------------------------------------------------------------


## The default deck: the five weakest fits are benched and the basics are split by the deck's Path pips.
static func auto_deck(content: ContentSet, state: DraftState) -> void:
	state.bench = default_bench(content, state)
	state.basics = default_basics(content, state)


## The indices of the cards left out by default: the worst fits to the rest (off-Path, a crowded cost), dearest first on a tie.
static func default_bench(content: ContentSet, state: DraftState) -> Array[int]:
	var cards: Array[CardData] = picked_cards(content, state)
	var spare: int = maxi(0, cards.size() - DraftRules.deck_cards())
	var order: Array[int] = []
	for i: int in range(cards.size()):
		order.append(i)
	var scores: Dictionary = {}
	for i: int in order:
		scores[i] = fit(cards[i], cards, state.paths) + (0.15 if cards[i].is_unit() else 0.0) + 0.1 * float(int(cards[i].rarity)) - 0.02 * float(cards[i].energy_value())
	order.sort_custom(func(a: int, b: int) -> bool: return float(scores[a]) < float(scores[b]) if not is_equal_approx(float(scores[a]), float(scores[b])) else a > b)
	var bench: Array[int] = []
	for i: int in range(spare):
		bench.append(order[i])
	bench.sort()
	return bench


## The cards of the deck (the picks minus the bench), in pick order.
static func deck_cards(content: ContentSet, state: DraftState) -> Array[CardData]:
	var result: Array[CardData] = []
	for i: int in range(state.cards.size()):
		if state.bench.has(i):
			continue
		var card: CardData = content.card(state.cards[i])
		if card != null:
			result.append(card)
	return result


## Moves card `index` between the deck and the bench. A card comes off the bench only while the deck has room, and goes onto it
## at any time (the deck must end at exactly 20: `deck_ready`).
static func toggle_bench(state: DraftState, index: int) -> bool:
	if index < 0 or index >= state.cards.size():
		return false
	if state.bench.has(index):
		if state.cards.size() - state.bench.size() >= DraftRules.deck_cards():
			return false
		state.bench.erase(index)
	else:
		state.bench.append(index)
		state.bench.sort()
	return true


static func deck_ready(state: DraftState) -> bool:
	var basics: int = 0
	for value: Variant in state.basics.values():
		basics += int(value)
	return state.cards.size() - state.bench.size() == mini(DraftRules.deck_cards(), state.cards.size()) and basics == DraftRules.deck_basics()


## The 15 basics split across the drafted Paths in proportion to the deck's coloured pips (every drafted Path with a card gets
## at least one; a deck of Pathless cards only splits them evenly).
static func default_basics(content: ContentSet, state: DraftState) -> Dictionary:
	var pips: Dictionary = {}
	for card: CardData in deck_cards(content, state):
		for pip: Affinity.Type in card.colored_pips:
			if state.paths.has(int(pip)):
				pips[int(pip)] = int(pips.get(int(pip), 0)) + 1
	var total: int = DraftRules.deck_basics()
	var split: Dictionary = {}
	for path: int in state.paths:
		split[path] = 0
	if state.paths.is_empty():
		return split
	var pip_total: int = 0
	for value: Variant in pips.values():
		pip_total += int(value)
	if pip_total == 0:
		for i: int in range(total):
			split[state.paths[i % state.paths.size()]] = int(split[state.paths[i % state.paths.size()]]) + 1
		return split
	var given: int = 0
	for path: int in state.paths:
		var share: int = int(floor(float(total) * float(int(pips.get(path, 0))) / float(pip_total)))
		if int(pips.get(path, 0)) > 0:
			share = maxi(1, share)
		split[path] = share
		given += share
	# hand out (or take back) the rounding to the Path with the most pips
	var order: Array[int] = state.paths.duplicate()
	order.sort_custom(func(a: int, b: int) -> bool: return int(pips.get(a, 0)) > int(pips.get(b, 0)))
	var at: int = 0
	while given != total:
		var path: int = order[at % order.size()]
		if given < total:
			split[path] = int(split[path]) + 1
			given += 1
		elif int(split[path]) > 1 or (int(split[path]) > 0 and int(pips.get(path, 0)) == 0):
			split[path] = int(split[path]) - 1
			given -= 1
		at += 1
		if at > 200:
			break
	return split


## Moves one basic from Path `from` to Path `to` (the player's own split). False when `from` has none.
static func move_basic(state: DraftState, from: int, to: int) -> bool:
	if from == to or not state.paths.has(from) or not state.paths.has(to) or int(state.basics.get(from, 0)) <= 0:
		return false
	state.basics[from] = int(state.basics.get(from, 0)) - 1
	state.basics[to] = int(state.basics.get(to, 0)) + 1
	return true


## The 35-card deck the run is played with.
static func build_deck(content: ContentSet, state: DraftState, deck_name: String = "Draft deck") -> Deck:
	var deck: Deck = Deck.new()
	deck.deck_name = deck_name
	deck.cards.append_array(deck_cards(content, state))
	for path: int in state.paths:
		var basic: CardData = content.infrastructure.get(path) as CardData
		if basic == null:
			continue
		for i: int in range(int(state.basics.get(path, 0))):
			deck.cards.append(basic)
	return deck


## Leaves the deck builder for the run (the deck must be ready).
static func lock_deck(state: DraftState) -> bool:
	if state.phase != DraftState.PHASE_DECK or not deck_ready(state):
		return false
	state.phase = DraftState.PHASE_RUN
	return true
