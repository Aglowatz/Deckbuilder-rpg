class_name ArenaDefs
extends RefCounted
## The eight encounters of the Grand Clashatorium in three tiers (Bronze, Silver and Gold Sand), mixing challenging battles
## and puzzle battles. Placeholder decks and numbers (balance is out of scope). Text: story file `arena.<id>.*`.
##
## | Tier | Fight | Kind | Prize (first clear) |
## | 1 | Warm-Up Brawl | battle, your deck | gold, essence |
## | 1 | Lethal Lunch | puzzle: win this turn | gold, essence |
## | 1 | The Neutral Mile | battle, restricted deck | gold, a Healing Draught |
## | 2 | Hold the Line | puzzle: survive 3 turns | Champion's Laurels |
## | 2 | Spells Only, Please | battle, no unit plays, restricted deck | Crowd-Pleaser's Cape |
## | 2 | The Four Fists | battle, your deck | gold, essence of every Path |
## | 3 | Zero to Hero | puzzle: win this turn (harder) | Gladiator's Net |
## | 3 | The Marshal | battle, your deck | Bloodsand Boots, gold, essence |

const TIER_NAMES: Array[String] = ["Bronze Sand", "Silver Sand", "Gold Sand"]

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
	var warmup: ArenaEncounter = _battle("arena_warmup", 1, "Gladiator Rookie", 14, "Aggressive", EnemyDecks.trimmed("beefcake_rush", 28, 16))
	warmup.reward = {"gold": 90, "xp": 40, "essence": {"primary": 5}}
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
	lunch.reward = {"gold": 120, "xp": 40, "essence": {"primary": 4}}
	list.append(lunch)
	var mile: ArenaEncounter = _battle("arena_neutral_mile", 1, "Sandbag Sentinel", 16, "Defensive", EnemyDecks.trimmed("colorless_regime", 30, 16))
	mile.player_recipe = {
		"BAS-B": 15, "C-01": 3, "C-02": 3, "C-03": 3, "C-04": 3, "C-06": 2, "C-07": 2, "C-08": 2, "C-13": 2, "C-14": 2, "C-12": 2, "C-16": 1,
	}
	mile.reward = {"gold": 100, "xp": 40, "item": "healing_draught"}
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
	line.reward = {"equipment": "champions_laurels", "gold": 150, "xp": 80}
	list.append(line)
	var spells: ArenaEncounter = _battle("arena_spells_only", 2, "Cardboard Colossus", 8, "Passive", EnemyDecks.trimmed("colorless_regime", 28, 16))
	spells.player_recipe = {"BAS-B": 9, "BAS-G": 8, "B-03": 6, "B-21": 4, "G-21": 4, "G-25": 3, "C-14": 4, "C-15": 2, "G-20": 3, "B-27": 2}
	var no_units: Modifier = Modifier.new()
	no_units.kind = Modifier.Kind.NO_UNIT_PLAYS
	no_units.label = "No unit plays"
	spells.player_rules = [no_units] as Array[Modifier]
	spells.reward = {"equipment": "crowd_pleasers_cape", "gold": 150, "xp": 80}
	list.append(spells)
	var fists: ArenaEncounter = _battle("arena_four_fists", 2, "Champion of the Four Fists", 22, "Balanced", EnemyDecks.recipe("four_paths", 17))
	fists.reward = {"gold": 250, "xp": 100, "essence": {"B": 4, "G": 4, "R": 4, "N": 4}}
	list.append(fists)
	# ---- Tier 3: Gold Sand --------------------------------------------------------------------------
	# Zero to Hero: both blockers must die first (Dropped Weights, Kettlebell), then 4 + 5 + 2 = 11 damage.
	var hero: ArenaEncounter = _puzzle("arena_zero_to_hero", 3, ArenaEncounter.Goal.WIN_THIS_TURN, 0, 0)
	hero.enemy_name = "The Wall of Fame"
	hero.enemy_hp = 11
	hero.enemy_recipe = {"BAS-B": 20, "C-02": 3, "C-06": 3}
	hero.player_recipe = {"BAS-B": 20, "B-03": 3, "B-15": 3}
	hero.player_hp = 8
	hero.preset = {
		"player": {"hp": 8, "infrastructure": {"B": 5}, "field": {"B-12": 1, "B-11": 1, "B-01": 1}, "hand": {"B-03": 1, "B-15": 1, "B-17": 1, "B-20": 1}},
		"enemy": {"hp": 11, "infrastructure": {"B": 2}, "field": {"C-02": 1, "C-06": 1}, "hand": {}},
	}
	hero.reward = {"equipment": "gladiators_net", "gold": 200, "xp": 120}
	list.append(hero)
	var marshal: ArenaEncounter = _battle("arena_marshal", 3, "Marshal Vesna Tuskmore", 30, "Aggressive", EnemyDecks.with_cards(EnemyDecks.recipe("beefcake_rush", 16), {"B-13": 3, "B-28": 2, "B-11": 3}))
	marshal.reward = {"equipment": "bloodsand_boots", "gold": 500, "xp": 250, "essence": {"primary": 10}}
	list.append(marshal)
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
