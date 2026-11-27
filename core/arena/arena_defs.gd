class_name ArenaDefs
extends RefCounted
## The eight encounters of the Grand Clashatorium in three tiers (Bronze, Silver and Gold Sand), mixing challenging battles
## and puzzle battles. Placeholder decks and numbers (balance is out of scope). Text: story file `arena.<id>.*`.
##
## | Tier | Fight | Kind | Prize (first clear) |
## | 1 | Warm-Up Brawl | battle, your deck | gold, essence |
## | 1 | Back from the Dead, Back to the Gym (arena_lethal_lunch) | puzzle: win this turn, Necrocrat + Beefcake | gold, a pack |
## | 1 | The Neutral Mile | battle, restricted deck | gold, an Energy Draught |
## | 2 | Mise en Place (arena_hold_the_line) | puzzle: win this turn, Gourmand + Beefcake | gold, a pack |
## | 2 | Spells Only, Please | battle, no unit plays, restricted deck | Crowd-Pleaser's Cape |
## | 2 | The Four Fists | battle, your deck | gold, essence of every Path |
## | 3 | The Chairman Needs a Quorum (arena_zero_to_hero) | puzzle: win this turn, Refusemancer + Necrocrat | gold, a pack, an Energy Draught |
## | 3 | The Marshal | battle, your deck | Bloodsand Boots, gold, essence |

## Overnight Nov 19 (Part 6): four tiers, opened in order - a tier opens once every bout of the one before it is beaten. Every win pays gold,
## XP and a pack; each tier, once complete, pays its equipment prize (`TIER_PRIZES`). Gold and Diamond have one puzzle and one battle each.
const TIER_NAMES: Array[String] = ["Bronze Sand", "Silver Sand", "Gold Sand", "Diamond Sand"]
const TIER_COUNT: int = 4
## Tier -> its prize, paid once when every bout of the tier is beaten.
const TIER_PRIZES: Dictionary = {
	1: {"equipment": "champions_laurels"},
	2: {"equipment": "crowd_pleasers_cape"},
	3: {"equipment": "gladiators_net"},
	4: {"equipment": "bloodsand_boots", "card": "C-36"},
}


static func tier_flag(tier: int) -> StringName:
	return StringName("arena_tier_%d_cleared" % tier)


## A tier is open when it is the first, or when every bout of the tier before it has been beaten.
static func tier_open(tier: int, flags: Dictionary) -> bool:
	if tier <= 1:
		return true
	return tier_complete(tier - 1, flags)


static func tier_complete(tier: int, flags: Dictionary) -> bool:
	var bouts: Array[ArenaEncounter] = in_tier(tier)
	if bouts.is_empty():
		return false
	for encounter: ArenaEncounter in bouts:
		if not bool(flags.get(str(flag_name(encounter.id)), false)):
			return false
	return true


## The tier the player is working on now (the lowest one not complete; TIER_COUNT + 1 once all are).
static func current_tier(flags: Dictionary) -> int:
	for tier: int in range(1, TIER_COUNT + 1):
		if not tier_complete(tier, flags):
			return tier
	return TIER_COUNT + 1

static var _all: Array[ArenaEncounter] = []


static func all() -> Array[ArenaEncounter]:
	if _all.is_empty():
		_all = _build()
	return _all


static func find(encounter_id: String) -> ArenaEncounter:
	for encounter: ArenaEncounter in all():
		if encounter.id == encounter_id:
			return encounter
	# Nov 26 night (Part A2): Octavia's deck-building puzzles ride the arena's battle pipeline; they are not in `all()` (the tiers, the
	# Clashatorium's screen and its clear count never see them)
	if DeckPuzzles.is_puzzle_id(encounter_id):
		return DeckPuzzles.find(encounter_id)
	return null


static func in_tier(tier: int) -> Array[ArenaEncounter]:
	var result: Array[ArenaEncounter] = []
	for encounter: ArenaEncounter in all():
		if encounter.tier == tier:
			result.append(encounter)
	return result


static func flag_name(encounter_id: String) -> StringName:
	return StringName("arena_cleared_%s" % encounter_id)


static func _build() -> Array[ArenaEncounter]:
	var list: Array[ArenaEncounter] = []
	# ---- Tier 1: Bronze Sand -------------------------------------------------------------------------
	var warmup: ArenaEncounter = _battle("arena_warmup", 1, "Gladiator Rookie", 20, "Aggressive", EnemyDecks.trimmed("beefcake_rush", 28, 18))  # Fable Nov 21 castle (Part 9.1): 14 -> 20 HP, Elite skill, "Home Crowd" +1/+1 (balance report, row 1)
	warmup.reward = {"gold": 90, "xp": 40, "pack": "primary"}
	list.append(warmup)
	list.append(_data_puzzle("arena_lethal_lunch", 1, {"gold": 120, "xp": 40, "pack": "general_1"}))
	var mile: ArenaEncounter = _battle("arena_neutral_mile", 1, "Sandbag Sentinel", 20, "Defensive", EnemyDecks.trimmed("colorless_regime", 30, 16))  # Fable Nov 21 castle: 13 -> 20 HP, Elite skill, "Packed Sand" +0/+2 (row 2)
	mile.player_recipe = {
		"BAS-B": 15, "C-01": 3, "C-02": 3, "C-03": 3, "C-04": 3, "C-06": 2, "C-07": 2, "C-08": 2, "C-13": 2, "C-14": 2, "C-12": 2, "C-16": 1,
	}
	mile.reward = {"gold": 100, "xp": 40, "pack": "general_1", "item": "energy_draught"}
	list.append(mile)
	# ---- Tier 2: Silver Sand ------------------------------------------------------------------------
	list.append(_data_puzzle("arena_hold_the_line", 2, {"gold": 150, "xp": 80, "pack": "general_2"}))
	# Rebalance (Oct 18): the Colossus runs on Gourmand basics, so it has no Iron to burst with (temporary Iron made its one big hit
	# too big for a deck that cannot block).
	var spells: ArenaEncounter = _battle("arena_spells_only", 2, "Cardboard Colossus", 10, "Passive", EnemyDecks.mixed("colorless_regime", 28, [Affinity.Type.GOURMAND] as Array[Affinity.Type], 16))
	spells.player_recipe = {"BAS-B": 9, "BAS-G": 8, "B-03": 4, "B-21": 6, "G-21": 4, "G-25": 3, "C-14": 4, "C-15": 2, "G-20": 3, "B-27": 2}
	var no_units: Modifier = Modifier.new()
	no_units.kind = Modifier.Kind.NO_UNIT_PLAYS
	no_units.label = "No unit plays"
	spells.player_rules = [no_units] as Array[Modifier]
	spells.reward = {"gold": 150, "xp": 80, "pack": "general_2", "essence": {"primary": 3}}
	list.append(spells)
	var fists: ArenaEncounter = _battle("arena_four_fists", 2, "Champion of the Four Fists", 40, "Balanced", EnemyDecks.with_cards(EnemyDecks.recipe("four_paths", 17), {"INF-11": 3}))  # Fable Nov 21 castle: 33 -> 40 HP, 3 Old Kingdom Crossroads, "Four Fists" +2/+2 in all (row 4)
	fists.reward = {"gold": 250, "xp": 100, "pack": "primary", "essence": {"B": 4, "G": 4, "R": 4, "N": 4}}
	list.append(fists)
	# ---- Tier 3: Gold Sand --------------------------------------------------------------------------
	list.append(_data_puzzle("arena_zero_to_hero", 3, {"gold": 200, "xp": 120, "pack": "general_2", "item": "energy_draught"}))
	var marshal: ArenaEncounter = _battle("arena_marshal", 3, "Announcer Grand Bellows", 64, "Aggressive", EnemyDecks.with_cards(EnemyDecks.recipe("beefcake_rush", 16), {"B-13": 3, "B-28": 2, "B-11": 3, "B-29": 1, "B-30": 1}))  # Rebalance Part E: 30 -> 38 HP, two Epics
	marshal.reward = {"gold": 500, "xp": 250, "pack": "primary", "essence": {"primary": 6}}
	list.append(marshal)
	# ---- Tier 4: Diamond Sand (Overnight Nov 19) ---------------------------------------------------------
	list.append(_data_puzzle("arena_final_bell", 4, {"gold": 300, "xp": 150, "pack": "general_2", "essence": {"primary": 6}}))
	# The Four Fists, Unbound: the Silver champion again, every Path at once and harder than the Marshal (more HP, more Epics).
	var unbound: ArenaEncounter = _battle("arena_four_fists_unbound", 4, "Champion of the Four Fists", 80, "Aggressive", EnemyDecks.with_cards(EnemyDecks.recipe("four_paths", 17), {"B-13": 2, "B-28": 2, "N-03": 2, "B-30": 1, "INF-11": 3}))  # Fable Nov 21 castle: 54 -> 80 HP, 3 Crossroads, one more opening card, "Unbound" +4/+4 (row 6)
	unbound.reward = {"gold": 600, "xp": 300, "pack": "primary", "essence": {"primary": 6}}
	list.append(unbound)
	return list



static func _battle(id: String, tier: int, enemy: String, hp: int, ai: String, recipe: Dictionary) -> ArenaEncounter:
	var encounter: ArenaEncounter = ArenaEncounter.new()
	encounter.id = id
	encounter.tier = tier
	encounter.kind = ArenaEncounter.Kind.BATTLE
	encounter.enemy_name = enemy
	encounter.enemy_hp = hp
	encounter.enemy_ai = ai
	encounter.enemy_recipe = recipe
	return encounter


## Fable Nov 20 (Part 7): the puzzles are data (data/arena/arena_puzzles.json): the board, the hand, the words and the design notes
## the solver checks. Their ids, tiers and prizes stay here (a save's cleared flags and the tiers' rewards do not move).
const PUZZLE_FILE: String = "res://data/arena/arena_puzzles.json"

static var _puzzle_data: Dictionary = {}


static func puzzle_data() -> Dictionary:
	if _puzzle_data.is_empty():
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(PUZZLE_FILE))
		if parsed is Dictionary:
			_puzzle_data = (parsed as Dictionary).get("puzzles", {}) as Dictionary
	return _puzzle_data


static func _data_puzzle(id: String, tier: int, reward: Dictionary) -> ArenaEncounter:
	var encounter: ArenaEncounter = puzzle_from(id, tier, puzzle_data().get(id, {}) as Dictionary)
	encounter.reward = reward
	return encounter


## Builds a "win this turn" puzzle from its data row (also used by tools/arena_puzzle_lab.gd on a draft file).
static func puzzle_from(id: String, tier: int, row: Dictionary) -> ArenaEncounter:
	var encounter: ArenaEncounter = _puzzle(id, tier, ArenaEncounter.Goal.WIN_THIS_TURN, 0, 0)
	encounter.enemy_name = str(row.get("enemy_name", "The Sand"))
	encounter.preset = (row.get("preset", {}) as Dictionary).duplicate(true)
	var enemy_side: Dictionary = encounter.preset.get("enemy", {}) as Dictionary
	var player_side: Dictionary = encounter.preset.get("player", {}) as Dictionary
	encounter.enemy_hp = int(enemy_side.get("hp", 10))
	encounter.player_hp = int(player_side.get("hp", 10))
	# the decks behind the preset: basics only, so nothing unknown can be drawn into a puzzle
	encounter.enemy_recipe = {"BAS-%s" % str(row.get("enemy_basics", "B")): 30}
	encounter.player_recipe = {"BAS-%s" % str(row.get("player_basics", "B")): 30}
	encounter.title_text = str(row.get("title", ""))
	encounter.brief = str(row.get("brief", ""))
	encounter.rules_text = str(row.get("rules", "PUZZLE: win THIS turn. Everything you need is on the table. If the turn ends and your opponent still stands, you lose."))
	encounter.lesson = str(row.get("lesson", ""))
	encounter.synergy = str(row.get("synergy", ""))
	for path: Variant in row.get("paths", []) as Array:
		encounter.paths.append(str(path))
	for step: Variant in row.get("solution", []) as Array:
		encounter.solution.append(str(step))
	for decoy: Variant in row.get("decoys", []) as Array:
		encounter.decoys.append(decoy as Dictionary)
	for line: Variant in row.get("naive", []) as Array:
		encounter.naive_lines.append(line as Dictionary)
	return encounter


static func _puzzle(id: String, tier: int, goal: ArenaEncounter.Goal, turns: int, first_player: int) -> ArenaEncounter:
	var encounter: ArenaEncounter = ArenaEncounter.new()
	encounter.id = id
	encounter.tier = tier
	encounter.kind = ArenaEncounter.Kind.PUZZLE
	encounter.goal = goal
	encounter.turns = turns
	encounter.first_player = first_player
	encounter.enemy_ai = "Aggressive"
	return encounter
