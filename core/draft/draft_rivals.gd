class_name DraftRivals
extends RefCounted
## Draft mode, Phase 1: the rival drafters. A rival is somebody the player already knows (an existing NPC's name and portrait)
## who drafts with the same system (`DraftEngine`'s offers, from the same Paths) and picks by a personality: aggressive (cheap
## hitters), controlling (spells, traps and big blockers) or swarming (the cheapest units and token makers). When the draft went
## badly the deck is fixed up ("fudged") so the fight stays a fight: enough units, not too many dear cards. Rivals wear no
## equipment and carry no items; their HP is the player's base HP plus the rules' `hp_bonus`.

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


static func roster(challenge_id: String) -> Array:
	var zone_id: String = DraftChallenges.zone_of(challenge_id)
	return ZONE_RIVALS.get(zone_id, OPEN_RIVALS) as Array


## The NPC portrait id of a rival by the name on its battle plate ("" when the name is nobody's).
static func portrait_id(enemy_name: String) -> String:
	var all: Array = OPEN_RIVALS.duplicate()
	for zone_id: Variant in ZONE_RIVALS.keys():
		all.append_array(ZONE_RIVALS[zone_id] as Array)
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


static func build(content: ContentSet, state: DraftState, npc_id: String, rival_name: String, personality: String, index: int) -> Dictionary:
	var drafted: DraftState = draft(content, state, personality, index)
	var hp: int = ProgressionTable.row(clampi(state.level, 1, ProgressionTable.MAX_LEVEL)).max_hp + int(DraftRules.rivals().get("hp_bonus", 0))
	return {"name": rival_name, "npc_id": npc_id, "personality": personality, "ai": str(AI_NAMES.get(personality, "Balanced")), "hp": hp,
		"title": str(TITLES.get(personality, "")), "recipe": recipe(content, drafted)}


## A rival's whole draft: the same offers as a player's (its own seed), each pick by the personality's taste, then the fix-up.
static func draft(content: ContentSet, state: DraftState, personality: String, index: int) -> DraftState:
	var rival: DraftState = DraftState.new()
	rival.challenge_id = state.challenge_id
	rival.paths = state.paths.duplicate()
	rival.level = state.level
	rival.two_path_ok = state.two_path_ok
	rival.multi_path_ok = state.multi_path_ok
	rival.seed = maxi(1, hash([state.seed, "rival", index, personality]))
	for pick: int in range(1, DraftRules.card_picks() + 1):
		rival.step = pick  # only cards: the step is the pick
		var high: bool = DraftRules.high_rarity_every() > 0 and pick % DraftRules.high_rarity_every() == 0
		var options: Array[String] = DraftEngine.card_offer(content, rival, high)
		if options.is_empty():
			break
		rival.cards.append(best_option(content, rival, options, personality))
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


## The 35-card deck of a drafted rival as a recipe ("Card ID -> copies").
static func recipe(content: ContentSet, rival: DraftState) -> Dictionary:
	var result: Dictionary = {}
	for card: CardData in DraftEngine.build_deck(content, rival).cards:
		result[card.id] = int(result.get(card.id, 0)) + 1
	return result
