class_name VendorStocks
extends RefCounted
## UI + economy fixes Oct 22, Part 5: what the card vendors sell (docs/design/vendors.md).
##
## - Sable (Crosspath) sells a SAMPLE: about ten cards, mostly Colorless Commons, a Colorless Uncommon and one Common of each Path as a
##   taste. It grows a little with progress (a second Colorless Uncommon and one Path Uncommon at level 5 or one zone freed; two
##   Colorless Epics at each "rarer cards at Sable's stall" level of the level track, 17 and 27) and rotates whenever the player levels up
##   or frees a zone. Never a Path Epic or a Legendary: the place to buy a Path's cards is that Path's zone.
## - Each Path zone's vendor sells that Path: every Common and the zone's two curated Uncommons from the first visit; the other
##   Uncommons and the Epics once the zone's boss is beaten (the zone is freed); a Legendary only in the postgame. Unique rewards
##   (not_in_packs cards, signature cards, dungeon and side-dungeon prizes, the Black Market's own cards) are never on a zone shelf.
## Pure data: the result is a `VendorData` whose locked entries show as "???" teasers on the shelf.

const SABLE_COLORLESS_COMMONS: int = 5
const SABLE_GROWTH_LEVEL: int = 5
const SABLE_GROWTH_ZONES: int = 1
## A zone shelf's Uncommons on the first visit.
const OPENING_UNCOMMONS: int = 2
## Colorless Epics added at each rare-stock level.
const SABLE_RARE_BATCH: int = 2


## Sable's sample for `state`, behind `gate` (the Forgotten Cave cleared). Deterministic for a given level and zone count, so the
## shelf only changes (rotates) when the player levels up or frees a zone.
static func sable_sample(content: ContentSet, state: UnlockState, gate: Condition, rare_levels: Array[int] = ProgressionTable.BONUS_VENDOR_UNLOCK_LEVELS) -> VendorData:
	var data: VendorData = VendorData.new()
	data.vendor_name = "Sable's Card Stall"
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = hash("sable-%d-%d" % [state.player_level, state.zones_completed])
	var grown: Condition = Condition.all_of([gate, Condition.any_of([Condition.player_level(SABLE_GROWTH_LEVEL), Condition.zones_completed(SABLE_GROWTH_ZONES)] as Array[Condition])] as Array[Condition])
	var commons: Array[String] = _pick(_pool(content, [], CardEnums.Rarity.COMMON), SABLE_COLORLESS_COMMONS, rng)
	var uncommons: Array[String] = _pick(_pool(content, [], CardEnums.Rarity.UNCOMMON), 2, rng)
	for id: String in commons:
		data.add(id, gate)
	if not uncommons.is_empty():
		data.add(uncommons[0], gate)
	if uncommons.size() > 1:
		data.add(uncommons[1], grown)
	for path: Affinity.Type in Affinity.colored_types():
		for id: String in _pick(_pool(content, [path], CardEnums.Rarity.COMMON), 1, rng):
			data.add(id, gate)
	# The growth step's Path Uncommon: one Path's, which Path turning with the rotation.
	var paths: Array[Affinity.Type] = Affinity.colored_types()
	var taste_path: Affinity.Type = paths[rng.randi_range(0, paths.size() - 1)]
	for id: String in _pick(_pool(content, [taste_path], CardEnums.Rarity.UNCOMMON), 1, rng):
		data.add(id, grown)
	# The level track's "rarer cards at Sable's stall": a fixed batch of Colorless Epics per rare-stock level (they do not rotate).
	var rare_rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rare_rng.seed = hash("sable-rare")
	var epics: Array[String] = _pick(_pool(content, [], CardEnums.Rarity.EPIC), SABLE_RARE_BATCH * rare_levels.size(), rare_rng)
	for index: int in range(epics.size()):
		var at: int = rare_levels[mini(index / SABLE_RARE_BATCH, rare_levels.size() - 1)]
		data.add(epics[index], Condition.all_of([gate, Condition.player_level(at)] as Array[Condition]))
	return data


## A Path zone's shelf: `curated` (the zone's own list) supplies the opening Uncommons; `zone_id` names the freed flag.
static func zone_shelf(content: ContentSet, path: Affinity.Type, zone_id: String, curated: Array[String], vendor_name: String) -> VendorData:
	var data: VendorData = VendorData.new()
	data.vendor_name = vendor_name
	var freed: Condition = Condition.flag(str(ZoneCompletion.flag_name(zone_id)))
	var late: Condition = Condition.postgame()
	for id: String in _pool(content, [path], CardEnums.Rarity.COMMON):
		data.add(id)
	var opening_uncommons: Array[String] = []
	for id: String in curated:
		var card: CardData = content.card(id)
		if card != null and card.rarity == CardEnums.Rarity.UNCOMMON and sellable(card):
			opening_uncommons.append(id)
	# A curated list with fewer than two Uncommons (the Gainlands has one) is topped up with the Path's next Uncommons by id.
	for id: String in _pool(content, [path], CardEnums.Rarity.UNCOMMON):
		if opening_uncommons.size() >= OPENING_UNCOMMONS:
			break
		if not opening_uncommons.has(id):
			opening_uncommons.append(id)
	opening_uncommons = opening_uncommons.slice(0, OPENING_UNCOMMONS)
	for id: String in _pool(content, [path], CardEnums.Rarity.UNCOMMON):
		data.add(id, null if opening_uncommons.has(id) else freed)
	for id: String in _pool(content, [path], CardEnums.Rarity.EPIC):
		data.add(id, freed)
	for id: String in _pool(content, [path], CardEnums.Rarity.LEGENDARY):
		data.add(id, late)
	return data


## Cards a vendor may sell at all: not a token, not Infrastructure, not a unique prize.
static func sellable(card: CardData) -> bool:
	if card == null or card.is_token or card.is_infrastructure() or card.not_in_packs or card.is_signature:
		return false
	if ZoneCards.MAIN_DUNGEON_REWARD_IDS.has(card.id) or CapitalContent.BLACK_MARKET_CARD_IDS.has(card.id):
		return false
	return not [ZoneCards.MINI_DUNGEON_REWARD_ID, ZoneCards.GAINLANDS_MINI_REWARD_ID, ZoneCards.BUFFET_MINI_REWARD_ID, ZoneCards.HEAP_MINI_REWARD_ID].has(card.id)


## The sellable cards of exactly `paths` (empty = Colorless) and `rarity`, by id.
static func _pool(content: ContentSet, paths: Array, rarity: CardEnums.Rarity) -> Array[String]:
	var result: Array[String] = []
	for id: Variant in content.cards.keys():
		var card: CardData = content.cards[id] as CardData
		if card.rarity != rarity or not sellable(card):
			continue
		var card_paths: Array[Affinity.Type] = card.paths()
		if card_paths.size() != paths.size():
			continue
		if paths.size() == 1 and card_paths[0] != paths[0]:
			continue
		result.append(card.id)
	result.sort()
	return result


static func _pick(pool: Array[String], count: int, rng: RandomNumberGenerator) -> Array[String]:
	var copy: Array[String] = pool.duplicate()
	var result: Array[String] = []
	while result.size() < count and not copy.is_empty():
		result.append(copy.pop_at(rng.randi_range(0, copy.size() - 1)))
	return result
