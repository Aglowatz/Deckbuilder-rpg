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
## The open draft's rivals of Nov 23 (kept for the saves of that build: `portrait_id`).
const OPEN_RIVALS: Array = [["NPC-DEX", "Dex Shufflewick", SWARMING], ["V-FIGSLY", "Fig Sly", AGGRESSIVE], ["V-SABLE", "Sable", CONTROLLING]]
## Fable Nov 24 (Part 3): who can sit down against you at the Shuffle House's tables (Classic, High Rollers, the Draft of the
## Day): a wide cast from all over the kingdom - the shopkeepers and townsfolk of Crosspath and the friendly folk of the four
## zones (no boss, no story spoiler). Three different ones are dealt in for each draft, by the draft's seed. [NPC id, name,
## personality]: the name is the NPC's own, so the battle plate and the next-opponent screen find the portrait.
const ARENA_ROSTER: Array = [
	["NPC-DEX", "Dex Shufflewick", SWARMING], ["V-FIGSLY", "Fig Sly", AGGRESSIVE], ["V-SABLE", "Sable", CONTROLLING],
	["V-TONIC", "Tilly Tonic", SWARMING], ["V-BEETSWORTH", "Bertram Beetsworth", AGGRESSIVE], ["V-THREADWELL", "Pip Threadwell", SWARMING],
	["V-FENWICK", "Foil Fenwick", CONTROLLING], ["V-ALEMBIC", "Auntie Alembic", CONTROLLING], ["NPC-BELLOWS", "Announcer Grand Bellows", AGGRESSIVE],
	["NPC-HOB", "Old Hob the Gravedigger", CONTROLLING], ["NPC-GATEKEEPER", "Gatekeeper Brannoch", AGGRESSIVE], ["NPC-VILLAGER", "Brindle the Baker", SWARMING],
	["NPC-ISLA", "Isla Brannoch", SWARMING], ["NPC-KESTREL", "Kestrel", AGGRESSIVE],
	["V-BENCHLEY", "Coach Brutus Benchley", AGGRESSIVE], ["NPC-HURL", "Big Hurl", AGGRESSIVE], ["NPC-RIP", "Rip Tearson", AGGRESSIVE],
	["NPC-PUMP", "Professor Pump", CONTROLLING], ["NPC-THUNDERABS", "Chet Thunderabs", AGGRESSIVE], ["NPC-MOUNTAIN", "Old Man Mountain", CONTROLLING], ["NPC-ROLLO", "Rollo Spokes", SWARMING],
	["V-LEDGERBONE", "Clerk Ledgerbone", CONTROLLING], ["NPC-ECTOMUND", "Director Ectomund", CONTROLLING], ["NPC-KYLE", "Kyle (Deceased Since '09)", AGGRESSIVE],
	["NPC-GERALD", "Gerald, Number 4,000,212", SWARMING], ["NPC-PELL", "Widow Pell", SWARMING],
	["V-MIREPOIX", "Madame Mirepoix", CONTROLLING], ["NPC-PATE", "Professor Pate", CONTROLLING], ["NPC-FLAMBE", "Chef Flambe Fontaine", AGGRESSIVE],
	["NPC-BASIL", "Basil", SWARMING], ["NPC-MARLO", "Chef Marlo", SWARMING],
	["V-GRISTLE", "Granny Gristle", CONTROLLING], ["NPC-THISTLEWICK", "Druid Thistlewick", CONTROLLING], ["NPC-RHONDA", "Recycle Rhonda", AGGRESSIVE],
	["NPC-BRAMBLE", "Brother Bramble", SWARMING], ["NPC-FERN", "Old Fern", SWARMING],
]
## The Shuffled Halls' house faces (their fights are hand-made since Nov 24: data/dungeons/dungeon_content.json, D-SHUFFLE).
const TREY: Array = ["NPC-TREY", "Trey Pickett", AGGRESSIVE]
const OCTAVIA: Array = ["NPC-OCTAVIA", "Octavia Eightfold", CONTROLLING]
const TREY_CARD: String = "C-40"
const OCTAVIA_CARD: String = "P4-04"
## Octavia's rule as the boss: the house deals her one more card each turn.
const HOUSE_RULE_NAME: String = "The House Deals"
const HOUSE_RULE_TEXT: String = "Octavia Eightfold draws an extra card each turn. The house always deals, darling."


## The faces a challenge draws its rivals from: a zone draft's own three, in order; the whole arena cast for the Shuffle House.
static func roster(challenge_id: String) -> Array:
	var zone_id: String = DraftChallenges.zone_of(challenge_id)
	return ZONE_RIVALS.get(zone_id, ARENA_ROSTER) as Array


## The ones who sit down for this draft. A zone draft: its three, in order. The Shuffle House: `count` different faces of the
## arena cast, dealt by the draft's seed (so they are saved with the run, and a new draft meets new people).
static func faces_for(state: DraftState, count: int) -> Array:
	var rows: Array = roster(state.challenge_id)
	var result: Array = []
	if DraftChallenges.is_zone(state.challenge_id):
		for i: int in range(count):
			result.append(rows[i % rows.size()])
		return result
	var pool: Array = rows.duplicate()
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = hash([state.seed, "faces"])
	while result.size() < count and not pool.is_empty():
		var at: int = rng.randi() % pool.size()
		result.append(pool[at])
		pool.remove_at(at)
	return result


## Everybody who can sit down as a rival: the arena cast (every zone's three are in it).
static func everyone() -> Array:
	var all: Array = ARENA_ROSTER.duplicate()
	for zone_id: String in DraftChallenges.ZONES:
		for row: Variant in ZONE_RIVALS[zone_id] as Array:
			if not all.has(row):
				all.append(row)
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
	var faces: Array = faces_for(state, DraftRules.number("fights", 3))
	for i: int in range(faces.size()):
		var row: Array = faces[i] as Array
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


## The Paths a rival drafts: random ones from all four (any Path, the player's own included). In a zone draft as many as the
## player's draft has (one). At the Shuffle House (Fable Nov 24: "their Paths and decks are random and changing, never decided by
## the player's choices") the NUMBER is random too, within what the story has opened (`path_count`), whatever the player chose.
## With `random_paths` off in the rules the rival drafts the player's Paths, as in Phase 1.
static func rival_paths(state: DraftState, index: int) -> Array[int]:
	if not bool(DraftRules.rivals().get("random_paths", true)):
		return state.paths.duplicate()
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = hash([state.seed, "rival-paths", index])
	var pool: Array[int] = DraftArena.PATHS.duplicate()
	var chosen: Array[int] = []
	var count: int = clampi(path_count(state, rng), 1, pool.size())
	while chosen.size() < count and not pool.is_empty():
		var at: int = rng.randi() % pool.size()
		chosen.append(pool[at])
		pool.remove_at(at)
	chosen.sort()
	return chosen


## How many Paths a rival drafts. A zone draft, and a save from before Nov 24 (no `max_paths`): as many as the player's. The
## Shuffle House's tables: by the rules' weights for what the story allows ("path_count_weights": one Path only before a zone
## is freed; one or two after; one to three after Primm - a four-Path rival deck stumbles over its own Infrastructure).
static func path_count(state: DraftState, rng: RandomNumberGenerator) -> int:
	if DraftChallenges.is_zone(state.challenge_id) or state.max_paths <= 0:
		return state.paths.size()
	var table: Variant = DraftRules.rivals().get("path_count_weights", {})
	var weights: Array = []
	if table is Dictionary and (table as Dictionary).get(str(state.max_paths)) is Array:
		weights = (table as Dictionary)[str(state.max_paths)] as Array
	if weights.is_empty():
		return mini(state.max_paths, 2)
	var total: float = 0.0
	for weight: Variant in weights:
		total += float(weight)
	var roll: float = rng.randf() * total
	for i: int in range(weights.size()):
		roll -= float(weights[i])
		if roll <= 0.0:
			return i + 1
	return weights.size()


## The rival of a room of a draft dungeon in a save from before Nov 24 ({} otherwise: the Halls' fights are the dungeon's own now).
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
	# two-Path cards once a zone is freed, three- and four-Path cards after Primm: by the story (`max_paths`), not by how many
	# Paths the player happened to choose (a save from before Nov 24 has no `max_paths`: the player's own locks then)
	rival.two_path_ok = (state.max_paths >= 2 if state.max_paths > 0 else state.two_path_ok) and rival.paths.size() >= 2
	rival.multi_path_ok = (state.max_paths >= 4 if state.max_paths > 0 else state.multi_path_ok) and rival.paths.size() >= 3
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


## How well a rival plays: its own level in the Shuffled Halls ("skill": the table drafters play at normal level there, the
## champions at elite, Octavia at boss), else the rules' level for every table rival.
static func skill_of(rival: Dictionary) -> AIPlayer.Skill:
	match str(rival.get("skill", "")):
		"normal":
			return AIPlayer.Skill.NORMAL
		"elite":
			return AIPlayer.Skill.ELITE
		"boss":
			return AIPlayer.Skill.BOSS
	return AIPlayer.Skill.BOSS if bool(rival.get("boss", false)) else DraftRun.skill()
