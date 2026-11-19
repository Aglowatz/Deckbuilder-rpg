class_name ArenaDefs
extends RefCounted
## The eight encounters of the Grand Clashatorium in three tiers (Bronze, Silver and Gold Sand), mixing challenging battles
## and puzzle battles. Placeholder decks and numbers (balance is out of scope). Text: story file `arena.<id>.*`.
##
## | Tier | Fight | Kind | Prize (first clear) |
## | 1 | Warm-Up Brawl | battle, your deck | gold, essence |
## | 1 | Lethal Lunch | puzzle: win this turn | gold, essence |
## | 1 | The Neutral Mile | battle, restricted deck | gold, an Energy Draught |
## | 2 | Hold the Line | puzzle: survive 3 turns | Champion's Laurels |
## | 2 | Spells Only, Please | battle, no unit plays, restricted deck | Crowd-Pleaser's Cape |
## | 2 | The Four Fists | battle, your deck | gold, essence of every Path |
## | 3 | Zero to Hero | puzzle: win this turn (harder) | Gladiator's Net |
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
	var warmup: ArenaEncounter = _battle("arena_warmup", 1, "Gladiator Rookie", 14, "Aggressive", EnemyDecks.trimmed("beefcake_rush", 28, 18))
	warmup.reward = {"gold": 90, "xp": 40, "pack": "primary"}
	list.append(warmup)
	# Lethal Lunch: 10 damage this turn through one blocker. Flex on 'Em (4 with a 5-attack unit) + Dropped Weights (2) + the attackers.
	var lunch: ArenaEncounter = _puzzle("arena_lethal_lunch", 1, ArenaEncounter.Goal.WIN_THIS_TURN, 0, 0)
	lunch.enemy_name = "Lunch Rush"
	lunch.enemy_hp = 10
	lunch.enemy_recipe = {"BAS-B": 20, "C-02": 3}
	lunch.player_recipe = {"BAS-B": 20, "B-03": 3}
	lunch.player_hp = 10
	lunch.preset = {
		"player": {"hp": 10, "infrastructure": {"B": 4}, "field": {"B-11": 1, "B-12": 1}, "hand": {"B-21": 1, "B-03": 1}},
		"enemy": {"hp": 10, "infrastructure": {"B": 2}, "field": {"C-02": 1}, "hand": {}},
	}
	lunch.reward = {"gold": 120, "xp": 40, "pack": "general_1"}
	list.append(lunch)
	var mile: ArenaEncounter = _battle("arena_neutral_mile", 1, "Sandbag Sentinel", 13, "Defensive", EnemyDecks.trimmed("colorless_regime", 30, 16))
	mile.player_recipe = {
		"BAS-B": 15, "C-01": 3, "C-02": 3, "C-03": 3, "C-04": 3, "C-06": 2, "C-07": 2, "C-08": 2, "C-13": 2, "C-14": 2, "C-12": 2, "C-16": 1,
	}
	mile.reward = {"gold": 100, "xp": 40, "pack": "general_1", "item": "energy_draught"}
	list.append(mile)
	# ---- Tier 2: Silver Sand ------------------------------------------------------------------------
	var line: ArenaEncounter = _puzzle("arena_hold_the_line", 2, ArenaEncounter.Goal.SURVIVE_TURNS, 3, 1)
	line.enemy_name = "Stampeding Squad"
	line.enemy_hp = 25
	line.enemy_recipe = {"BAS-B": 24, "C-02": 2}
	line.player_recipe = {"BAS-G": 20, "G-04": 3, "C-05": 3, "G-06": 3, "G-17": 2, "C-19": 2}
	line.player_hp = 9
	line.preset = {
		"player": {"hp": 9, "infrastructure": {"G": 5}, "field": {}, "hand": {"G-04": 1, "C-05": 1, "G-06": 1, "G-17": 1, "C-19": 1}},
		"enemy": {"hp": 25, "infrastructure": {"B": 4}, "field": {"C-02": 2}, "hand": {}},
	}
	line.reward = {"gold": 150, "xp": 80, "pack": "general_2"}
	list.append(line)
	# Rebalance (Oct 18): the Colossus runs on Gourmand basics, so it has no Iron to burst with (temporary Iron made its one big hit
	# too big for a deck that cannot block).
	var spells: ArenaEncounter = _battle("arena_spells_only", 2, "Cardboard Colossus", 6, "Passive", EnemyDecks.mixed("colorless_regime", 28, [Affinity.Type.GOURMAND] as Array[Affinity.Type], 16))
	spells.player_recipe = {"BAS-B": 9, "BAS-G": 8, "B-03": 4, "B-21": 6, "G-21": 4, "G-25": 3, "C-14": 4, "C-15": 2, "G-20": 3, "B-27": 2}
	var no_units: Modifier = Modifier.new()
	no_units.kind = Modifier.Kind.NO_UNIT_PLAYS
	no_units.label = "No unit plays"
	spells.player_rules = [no_units] as Array[Modifier]
	spells.reward = {"gold": 150, "xp": 80, "pack": "general_2", "essence": {"primary": 3}}
	list.append(spells)
	var fists: ArenaEncounter = _battle("arena_four_fists", 2, "Champion of the Four Fists", 33, "Balanced", EnemyDecks.recipe("four_paths", 17))  # Rebalance Part E: 22 -> 28 HP
	fists.reward = {"gold": 250, "xp": 100, "pack": "primary", "essence": {"B": 4, "G": 4, "R": 4, "N": 4}}
	list.append(fists)
	# ---- Tier 3: Gold Sand --------------------------------------------------------------------------
	# Zero to Hero: both blockers must die first (Dropped Weights, Kettlebell), then 4 + 5 + 2 = 11 damage.
	var hero: ArenaEncounter = _puzzle("arena_zero_to_hero", 3, ArenaEncounter.Goal.WIN_THIS_TURN, 0, 0)
	hero.enemy_name = "The Wall of Fame"
	hero.enemy_hp = 10  # Rebalance: Gym Bro is a 1/1 now, so the three attackers deal exactly 10 once both blockers are gone
	hero.enemy_recipe = {"BAS-B": 20, "C-02": 3, "C-06": 3}
	hero.player_recipe = {"BAS-B": 20, "B-03": 3, "B-15": 3}
	hero.player_hp = 8
	hero.preset = {
		"player": {"hp": 8, "infrastructure": {"B": 5}, "field": {"B-12": 1, "B-11": 1, "B-01": 1}, "hand": {"B-03": 1, "B-15": 1, "B-17": 1, "B-20": 1}},
		"enemy": {"hp": 10, "infrastructure": {"B": 2}, "field": {"C-02": 1, "C-06": 1}, "hand": {}},
	}
	hero.reward = {"gold": 200, "xp": 120, "pack": "general_2", "item": "energy_draught"}
	list.append(hero)
	var marshal: ArenaEncounter = _battle("arena_marshal", 3, "Announcer Grand Bellows", 46, "Aggressive", EnemyDecks.with_cards(EnemyDecks.recipe("beefcake_rush", 16), {"B-13": 3, "B-28": 2, "B-11": 3, "B-29": 1, "B-30": 1}))  # Rebalance Part E: 30 -> 38 HP, two Epics
	marshal.reward = {"gold": 500, "xp": 250, "pack": "primary", "essence": {"primary": 6}}
	list.append(marshal)
	# ---- Tier 4: Diamond Sand (Overnight Nov 19) ---------------------------------------------------------
	# The Final Bell: three blockers and exactly enough. Desk Flip (2) kills the Militia, Dropped Weights (1) the Brawler, the Kettlebell (1)
	# the Archer (1/3: only its 3 damage will do), Dry Scoop (1) makes the Gym Bro a 2: 4 + 5 + 2 = 11 = the Wall's HP, all five energy.
	var bell: ArenaEncounter = _puzzle("arena_final_bell", 4, ArenaEncounter.Goal.WIN_THIS_TURN, 0, 0)
	bell.enemy_name = "The Wall of Fame"
	bell.enemy_hp = 11
	bell.enemy_recipe = {"BAS-B": 20, "C-02": 3, "C-06": 3, "C-03": 3}
	bell.player_recipe = {"BAS-B": 20, "B-36": 3, "B-03": 3, "B-15": 3, "B-20": 3}
	bell.player_hp = 8
	bell.preset = {
		"player": {"hp": 8, "infrastructure": {"B": 5}, "field": {"B-12": 1, "B-11": 1, "B-01": 1}, "hand": {"B-36": 1, "B-03": 1, "B-15": 1, "B-20": 1}},
		"enemy": {"hp": 11, "infrastructure": {"B": 2}, "field": {"C-02": 1, "C-06": 1, "C-03": 1}, "hand": {}},
	}
	bell.reward = {"gold": 300, "xp": 150, "pack": "general_2", "essence": {"primary": 6}}
	list.append(bell)
	# The Four Fists, Unbound: the Silver champion again, every Path at once and harder than the Marshal (more HP, more Epics).
	var unbound: ArenaEncounter = _battle("arena_four_fists_unbound", 4, "Champion of the Four Fists", 54, "Aggressive", EnemyDecks.with_cards(EnemyDecks.recipe("four_paths", 17), {"B-13": 2, "B-28": 2, "N-03": 2, "B-30": 1}))
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
