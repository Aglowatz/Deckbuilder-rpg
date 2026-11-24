class_name DraftRivals
extends RefCounted
## Draft mode, Phase 1: the rival drafters. A rival is somebody the player already knows (an existing NPC's name and portrait)
## who drafts with the same system (`DraftEngine`'s offers, from the same Paths) and picks by a personality: aggressive (cheap
## hitters), controlling (spells, traps and big blockers) or swarming (the cheapest units and token makers). When the draft went
## badly the deck is fixed up ("fudged") so the fight stays a fight: enough units, not too many dear cards. Rivals carry no
## items, but they draft equipment like the player (five picks, one per slot, the rarest of each three): a player in five
## drafted pieces against a bare rival won nine fights in ten. Their HP is the player's base HP plus the rules' `hp_bonus`.

const AGGRESSIVE: String = "aggressive"
const CONTROLLING: String = "controlling"
const SWARMING: String = "swarming"
const PERSONALITIES: Array[String] = [AGGRESSIVE, CONTROLLING, SWARMING]
## The AI profile that plays each personality's deck.
const AI_NAMES: Dictionary = {AGGRESSIVE: "Aggressive", CONTROLLING: "Defensive", SWARMING: "Balanced"}
const TITLES: Dictionary = {AGGRESSIVE: "drafts cheap hitters and goes for your face", CONTROLLING: "drafts answers and big blockers, and waits", SWARMING: "drafts the cheapest units there are, and a lot of them"}

## Who sits down against you in each zone's draft, in fight order: [NPC id, name, personality].
const ZONE_RIVALS: Dictionary = {
	"beefcake": [["NPC-ROLLO", "Rollo Spokes", SWARMING], ["NPC-THUNDERABS", "Chet Thunderabs", AGGRESSIVE], ["NPC-PUMP", "Professor Pump", CONTROLLING]],
	"gourmand": [["NPC-MARLO", "Chef Marlo", SWARMING], ["NPC-FLAMBE", "Chef Flambe Fontaine", AGGRESSIVE], ["NPC-PATE", "Professor Pate", CONTROLLING]],
	"necrocrat": [["NPC-PELL", "Widow Pell", SWARMING], ["NPC-KYLE", "Kyle (Deceased Since '09)", AGGRESSIVE], ["NPC-ECTOMUND", "Director Ectomund", CONTROLLING]],
	"refusemancer": [["NPC-FERN", "Old Fern", SWARMING], ["NPC-RHONDA", "Recycle Rhonda", AGGRESSIVE], ["NPC-THISTLEWICK", "Druid Thistlewick", CONTROLLING]],
}
## The open draft's rivals (any Paths): the travelling folk.
const OPEN_RIVALS: Array = [["NPC-DEX", "Dex Shufflewick", SWARMING], ["V-FIGSLY", "Fig Sly", AGGRESSIVE], ["V-SABLE", "Sable", CONTROLLING]]
## Fable big pass Nov 23: the Shuffled Halls. Trey Pickett holds the Auction Ring, Dex Shufflewick the Roulette Pit, and Octavia
## Eightfold is the boss at the Big Wheel (room numbers of data/dungeons/postgame_dungeons.json, D-SHUFFLE).
const TREY: Array = ["NPC-TREY", "Trey Pickett", AGGRESSIVE]
const OCTAVIA: Array = ["NPC-OCTAVIA", "Octavia Eightfold", CONTROLLING]
const HALLS_CHAMPIONS: Dictionary = {8: TREY, 14: ["NPC-DEX", "Dex Shufflewick", SWARMING]}
const HALLS_BOSS_ROOM: int = 19
const HALLS_FIGHT_ROOMS: Array[int] = [2, 3, 5, 7, 10, 12, 15]
const TREY_CARD: String = "C-40"
const OCTAVIA_CARD: String = "P4-04"
## Octavia's rule as the boss: the house deals her one more card each turn.
const HOUSE_RULE_NAME: String = "The House Deals"
const HOUSE_RULE_TEXT: String = "Octavia Eightfold draws an extra card each turn. The house always deals, darling."


static func roster(challenge_id: String) -> Array:
	var zone_id: String = DraftChallenges.zone_of(challenge_id)
	return ZONE_RIVALS.get(zone_id, OPEN_RIVALS) as Array


## Everybody who can sit down as a rival: the travelling folk, then every zone's three.
static func everyone() -> Array:
	var all: Array = OPEN_RIVALS.duplicate()
	for zone_id: String in DraftChallenges.ZONES:
		all.append_array(ZONE_RIVALS[zone_id] as Array)
	return all


## The NPC portrait id of a rival by the name on its battle plate ("" when the name is nobody's).
static func portrait_id(enemy_name: String) -> String:
	var all: Array = everyone()
	all.append(TREY)
	all.append(OCTAVIA)
	for row: Variant in all:
		if str((row as Array)[1]) == enemy_name:
			return str((row as Array)[0])
	return ""


## The three rivals of a draft, each with a drafted and fixed-up deck: {"name", "npc_id", "personality", "ai", "hp", "title", "recipe"}.
static func build_all(content: ContentSet, state: DraftState) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var rows: Array = roster(state.challenge_id)
	for i: int in range(DraftRules.number("fights", 3)):
		var row: Array = rows[i % rows.size()] as Array
		result.append(build(content, state, str(row[0]), str(row[1]), str(row[2]), i))
	return result


static func build(content: ContentSet, state: DraftState, npc_id: String, rival_name: String, personality: String, index: int, hp_bonus: int = 0, paths: Array[int] = [], gear_cap: int = -1) -> Dictionary:
	var own_paths: Array[int] = paths if not paths.is_empty() else rival_paths(state, index)
	var cap: int = gear_cap if gear_cap >= 0 else DraftRules.rival_equipment_cap(DraftArena.kind_of(state.challenge_id))
	var drafted: DraftState = draft(content, state, personality, index, own_paths, cap)
	var kind_bonus: int = int(DraftRules.section("high").get("hp_bonus", 0)) if DraftArena.kind_of(state.challenge_id) == DraftArena.KIND_HIGH else 0
	var hp: int = ProgressionTable.row(clampi(state.level, 1, ProgressionTable.MAX_LEVEL)).max_hp + int(DraftRules.rivals().get("hp_bonus", 0)) + kind_bonus + hp_bonus
	return {"name": rival_name, "npc_id": npc_id, "personality": personality, "ai": str(AI_NAMES.get(personality, "Balanced")), "hp": hp,
		"title": str(TITLES.get(personality, "")), "recipe": recipe(content, drafted), "equipment": drafted.equipment.duplicate(), "paths": own_paths.duplicate()}


## The Paths a rival drafts (the owner, Nov 23): random ones, as many as the player's draft has, from all four (any Path, the
## player's own included). With `random_paths` off in the rules the rival drafts the player's Paths, as in Phase 1.
static func rival_paths(state: DraftState, index: int) -> Array[int]:
	if not bool(DraftRules.rivals().get("random_paths", true)):
		return state.paths.duplicate()
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = hash([state.seed, "rival-paths", index])
	var pool: Array[int] = DraftArena.PATHS.duplicate()
	var chosen: Array[int] = []
	var count: int = clampi(state.paths.size(), 1, pool.size())
	while chosen.size() < count and not pool.is_empty():
		var at: int = rng.randi() % pool.size()
		chosen.append(pool[at])
		pool.remove_at(at)
	chosen.sort()
	return chosen


## The rivals of the Shuffled Halls, each with its room: seven drafters at the tables (a different face in every room), Trey Pickett
## and Dex Shufflewick as the champions, and Octavia Eightfold at the end. {"room": n, "champion": bool, "boss": bool} on top of
## the usual fields.
static func build_halls(content: ContentSet, state: DraftState) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var numbers: Dictionary = {}
	if DraftRules.dungeon().get("halls", {}) is Dictionary:
		numbers = DraftRules.dungeon().get("halls", {}) as Dictionary
	var faces: Array = everyone()
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = hash([state.seed, "halls"])
	var index: int = 10
	for room: int in HALLS_FIGHT_ROOMS:
		var face: Array = ["NPC-DEX", "A Drafter", SWARMING]
		for guard: int in range(40):
			face = faces[rng.randi() % faces.size()] as Array
			if str(face[1]) != "Dex Shufflewick" and not _has_name(result, str(face[1])):
				break
		var rival: Dictionary = build(content, state, str(face[0]), str(face[1]), str(face[2]), index, int(numbers.get("fight_hp_bonus", 0)))
		rival["room"] = room
		result.append(rival)
		index += 1
	for room: Variant in HALLS_CHAMPIONS.keys():
		var row: Array = HALLS_CHAMPIONS[room] as Array
		var champion: Dictionary = build(content, state, str(row[0]), str(row[1]), str(row[2]), index, int(numbers.get("champion_hp_bonus", 4)), [] as Array[int], int(EquipmentData.Rarity.RARE))
		champion["room"] = int(room)
		champion["champion"] = true
		if str(row[1]) == str(TREY[1]):
			champion["recipe"] = _with_card(content, champion["recipe"] as Dictionary, TREY_CARD, 2)
		result.append(champion)
		index += 1
	# Octavia deals from two Paths at once whatever the player drafted (she is the house), with the whole equipment pool
	var octavia_state: DraftState = _probe_for_boss(state)
	var boss: Dictionary = build(content, octavia_state, str(OCTAVIA[0]), str(OCTAVIA[1]), str(OCTAVIA[2]), index, int(numbers.get("boss_hp_bonus", 10)), [] as Array[int], int(EquipmentData.Rarity.LEGENDARY))
	boss["room"] = HALLS_BOSS_ROOM
	boss["boss"] = true
	result.append(boss)
	return result


static func _has_name(rivals: Array[Dictionary], rival_name: String) -> bool:
	for rival: Dictionary in rivals:
		if str(rival.get("name", "")) == rival_name:
			return true
	return false


## The draft Octavia drafts from: the player's seed and level, two Paths, two-Path cards allowed.
static func _probe_for_boss(state: DraftState) -> DraftState:
	var probe: DraftState = DraftState.new()
	probe.challenge_id = state.challenge_id
	probe.seed = state.seed
	probe.level = state.level
	probe.paths = [DraftArena.PATHS[0], DraftArena.PATHS[1]] as Array[int]  # only the count matters: `rival_paths` picks the pair
	probe.two_path_ok = true
	probe.multi_path_ok = false
	return probe


## `recipe` with `copies` of `card_id` in place of its dearest other cards (a champion's own card).
static func _with_card(content: ContentSet, recipe: Dictionary, card_id: String, copies: int) -> Dictionary:
	if content.card(card_id) == null:
		return recipe
	var result: Dictionary = recipe.duplicate()
	for i: int in range(copies):
		var out: String = ""
		var out_cost: int = -1
		for id: Variant in result.keys():
			var card: CardData = content.card(str(id))
			if card == null or card.is_infrastructure() or str(id) == card_id:
				continue
			if card.energy_value() > out_cost:
				out_cost = card.energy_value()
				out = str(id)
		if out.is_empty():
			break
		result[out] = int(result[out]) - 1
		if int(result[out]) <= 0:
			result.erase(out)
		result[card_id] = int(result.get(card_id, 0)) + 1
	return result


## The rival of a room of the Shuffled Halls ({} when the room has none).
static func for_room(state: DraftState, room: int) -> Dictionary:
	for rival: Dictionary in state.rivals:
		if int(rival.get("room", -1)) == room:
			return rival
	return {}


## A rival's whole draft: the same offers as a player's (its own seed), each pick by the personality's taste, then the fix-up.
## `paths`: the Paths it drafts; `gear_cap`: the rarest piece of equipment it may be offered.
static func draft(content: ContentSet, state: DraftState, personality: String, index: int, paths: Array[int] = [], gear_cap: int = 99) -> DraftState:
	var rival: DraftState = DraftState.new()
	rival.challenge_id = state.challenge_id
	rival.paths = paths.duplicate() if not paths.is_empty() else state.paths.duplicate()
	rival.level = state.level
	rival.two_path_ok = state.two_path_ok and rival.paths.size() >= 2
	rival.multi_path_ok = state.multi_path_ok and rival.paths.size() >= 3
	rival.seed = maxi(1, hash([state.seed, "rival", index, personality]))
	for pick: int in range(1, DraftRules.card_picks() + 1):
		rival.step = pick  # only cards: the step is the pick
		var high: bool = DraftRules.high_rarity_every() > 0 and pick % DraftRules.high_rarity_every() == 0
		var options: Array[String] = DraftEngine.card_offer(content, rival, high)
		if options.is_empty():
			break
		rival.cards.append(best_option(content, rival, options, personality))
	if bool(DraftRules.rivals().get("draft_equipment", true)):
		for gear_pick: int in range(DraftRules.int_list("equipment_picks_after").size()):
			rival.step = 100 + gear_pick
			var slot: int = DraftEngine._next_slot(content, rival)
			var best_id: String = ""
			var best_rarity: int = -1
			var offered: Array[String] = DraftEngine.equipment_offer(content, rival, slot, gear_cap)
			for id: String in offered:
				var piece: EquipmentData = content.equipment_piece(id)
				if piece != null and int(piece.rarity) > best_rarity:
					best_rarity = int(piece.rarity)
					best_id = id
				if not rival.offered_equipment.has(id):
					rival.offered_equipment.append(id)
			if not best_id.is_empty():
				rival.equipment.append(best_id)
	rival.phase = DraftState.PHASE_DECK
	DraftEngine.auto_deck(content, rival)
	fudge(content, rival)
	rival.basics = DraftEngine.default_basics(content, rival)
	return rival


static func best_option(content: ContentSet, rival: DraftState, options: Array[String], personality: String) -> String:
	var picked: Array[CardData] = DraftEngine.picked_cards(content, rival)
	var best: String = options[0]
	var best_score: float = -1000.0
	for id: String in options:
		var card: CardData = content.card(id)
		if card == null:
			continue
		var value: float = taste(card, personality) + 2.0 * DraftEngine.fit(card, picked, rival.paths) + 0.4 * float(int(card.rarity))
		if value > best_score:
			best_score = value
			best = id
	return best


## How much a personality likes a card on its own (the fit to the deck so far is added by `best_option`).
static func taste(card: CardData, personality: String) -> float:
	var cost: int = card.energy_value()
	var makes_tokens: bool = card.rules_text.to_lower().contains("create")
	match personality:
		AGGRESSIVE:
			if card.is_unit():
				return 1.5 + 0.5 * float(card.attack) - 0.45 * float(cost)
			return 0.6 - 0.25 * float(cost)
		CONTROLLING:
			if card.is_unit():
				return 0.6 + 0.35 * float(card.defense) - 0.15 * float(cost)
			return 1.4 - 0.1 * float(cost)
		_:
			if card.is_unit():
				return 2.2 - 0.6 * float(cost) + (0.8 if makes_tokens else 0.0)
			return (1.2 if makes_tokens else 0.2) - 0.2 * float(cost)


## The fix-up of a drafted deck: at least `fudge_min_units` units among the 20 and at most `fudge_max_cost_share` of them at
## cost 5 or more. First the bench is used (a benched unit for a spell, a benched cheap card for a dear one); if the 25 cannot
## do it, the worst card is swapped for a common, on-curve unit of the draft's Paths. Returns how many cards were swapped in.
static func fudge(content: ContentSet, rival: DraftState) -> int:
	var min_units: int = int(DraftRules.rivals().get("fudge_min_units", 9))
	var max_dear: int = int(floor(float(DraftRules.deck_cards()) * float(DraftRules.rivals().get("fudge_max_cost_share", 0.25))))
	var swapped: int = 0
	for guard: int in range(40):
		var units: int = 0
		var dear: int = 0
		var deck_indices: Array[int] = []
		for i: int in range(rival.cards.size()):
			if rival.bench.has(i):
				continue
			deck_indices.append(i)
			var card: CardData = content.card(rival.cards[i])
			units += 1 if card.is_unit() else 0
			dear += 1 if card.energy_value() >= 5 else 0
		var need_unit: bool = units < min_units
		var too_dear: bool = dear > max_dear
		if not need_unit and not too_dear:
			break
		# the card to take out: a dear one when there are too many, else the dearest non-unit
		var out: int = -1
		var out_cost: int = -1
		for i: int in deck_indices:
			var card: CardData = content.card(rival.cards[i])
			var candidate: bool = (too_dear and card.energy_value() >= 5) or (not too_dear and not card.is_unit())
			if candidate and card.energy_value() > out_cost:
				out = i
				out_cost = card.energy_value()
		if out < 0:
			break
		# a card to put in from the bench
		var into: int = -1
		for i: int in rival.bench:
			var card: CardData = content.card(rival.cards[i])
			if card.energy_value() < 5 and (card.is_unit() or not need_unit):
				into = i
				break
		if into >= 0:
			rival.bench.erase(into)
			rival.bench.append(out)
			rival.bench.sort()
			continue
		var filler: CardData = _filler(content, rival, guard)
		if filler == null:
			break
		rival.cards[out] = filler.id
		swapped += 1
	return swapped


## A common or uncommon unit of the draft's Paths at cost 1 to 3, a different one each time.
static func _filler(content: ContentSet, rival: DraftState, turn: int) -> CardData:
	var pool: Array[CardData] = []
	for card: CardData in DraftEngine.card_pool(content, rival):
		if card.is_unit() and card.energy_value() >= 1 and card.energy_value() <= 3 and int(card.rarity) <= int(CardEnums.Rarity.UNCOMMON) and not CardAvailability.is_reward_locked(card):
			pool.append(card)
	if pool.is_empty():
		return null
	return pool[(hash([rival.seed, "filler", turn]) & 0x7fffffff) % pool.size()]


## The pieces a rival wears, as rule sources for its seat.
static func equipment_sources(content: ContentSet, rival: Dictionary) -> Array[ModifierSource]:
	var result: Array[ModifierSource] = []
	for id: Variant in rival.get("equipment", []) as Array:
		var piece: EquipmentData = content.equipment_piece(str(id))
		if piece != null:
			result.append(piece)
	return result


## The 35-card deck of a drafted rival as a recipe ("Card ID -> copies").
static func recipe(content: ContentSet, rival: DraftState) -> Dictionary:
	var result: Dictionary = {}
	for card: CardData in DraftEngine.build_deck(content, rival).cards:
		result[card.id] = int(result.get(card.id, 0)) + 1
	return result
