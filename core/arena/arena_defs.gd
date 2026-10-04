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
## | 2 | Spells Only, Please | battle, no creature casts, restricted deck | Crowd-Pleaser's Cape |
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
	var A: String = "infrastructure:A"
	var B: String = "infrastructure:B"
	var C: String = "infrastructure:C"
	var D: String = "infrastructure:D"
	var list: Array[ArenaEncounter] = []
	# ---- Tier 1: Bronze Sand -------------------------------------------------------------------------
	var warmup: ArenaEncounter = _battle("arena_warmup", 1, "Gladiator Rookie", 14, "Aggressive", {A: 16, "beefcake_imp": 3, "blade_dancer": 3, "raider": 2, "sellsword": 3, "apprentice_blade": 3, "firebolt": 1})
	warmup.reward = {"gold": 90, "xp": 40, "essence": {"primary": 5}}
	list.append(warmup)
	var lunch: ArenaEncounter = _puzzle("arena_lethal_lunch", 1, ArenaEncounter.Goal.WIN_THIS_TURN, 0, 0)
	lunch.enemy_name = "Lunch Rush"
	lunch.enemy_life = 10
	lunch.enemy_recipe = {A: 20, "sellsword": 3}
	lunch.player_recipe = {A: 20, "firebolt": 3}
	lunch.player_life = 10
	lunch.preset = {
		"player": {"life": 10, "infrastructure": {"A": 4}, "battlefield": {"beefcake_imp": 1, "raider": 1}, "hand": {"warcry": 1, "flame_burst": 1, "firebolt": 1}},
		"enemy": {"life": 10, "infrastructure": {"A": 2}, "battlefield": {"sellsword": 1}, "hand": {}},
	}
	lunch.reward = {"gold": 120, "xp": 40, "essence": {"primary": 4}}
	list.append(lunch)
	var mile: ArenaEncounter = _battle("arena_neutral_mile", 1, "Sandbag Sentinel", 16, "Defensive", {A: 16, "stone_sentinel": 3, "ironclad": 2, "field_medic": 3, "sellsword": 3, "apprentice_blade": 3, "healing_idol": 2})
	mile.player_recipe = {A: 15, "apprentice_blade": 3, "scrappy_recruit": 3, "sellsword": 3, "cave_bat": 3, "stone_sentinel": 2, "field_medic": 2, "ironclad": 2, "merchant": 2, "rusty_curse": 2, "supply_cache": 2}
	mile.reward = {"gold": 100, "xp": 40, "item": "healing_draught"}
	list.append(mile)
	# ---- Tier 2: Silver Sand ------------------------------------------------------------------------
	var line: ArenaEncounter = _puzzle("arena_hold_the_line", 2, ArenaEncounter.Goal.SURVIVE_TURNS, 3, 1)
	line.enemy_name = "Stampeding Squad"
	line.enemy_life = 25
	line.enemy_recipe = {A: 24, "sellsword": 2}
	line.player_recipe = {A: 20, "stone_sentinel": 3, "field_medic": 3, "pitfall": 2, "ironclad": 2, "healing_idol": 2}
	line.player_life = 9
	line.preset = {
		"player": {"life": 9, "infrastructure": {"A": 5}, "battlefield": {}, "hand": {"stone_sentinel": 1, "field_medic": 1, "ironclad": 1, "pitfall": 1, "healing_idol": 1}},
		"enemy": {"life": 25, "infrastructure": {"A": 4}, "battlefield": {"sellsword": 2}, "hand": {}},
	}
	line.reward = {"equipment": "champions_laurels", "gold": 150, "xp": 80}
	list.append(line)
	var spells: ArenaEncounter = _battle("arena_spells_only", 2, "Cardboard Colossus", 12, "Balanced", {A: 16, "sellsword": 4, "stone_sentinel": 2, "apprentice_blade": 3, "scrappy_recruit": 3, "cave_bat": 2})
	spells.player_recipe = {A: 9, B: 8, "flame_burst": 4, "firebolt": 3, "deep_insight": 3, "dissolve": 3, "rusty_curse": 3, "supply_cache": 3, "recall": 2}
	var no_creatures: Modifier = Modifier.new()
	no_creatures.kind = Modifier.Kind.NO_CREATURE_CASTS
	no_creatures.label = "No creature casts"
	spells.player_rules = [no_creatures] as Array[Modifier]
	spells.reward = {"equipment": "crowd_pleasers_cape", "gold": 150, "xp": 80}
	list.append(spells)
	var fists: ArenaEncounter = _battle("arena_four_fists", 2, "Champion of the Four Fists", 22, "Balanced", {A: 5, B: 4, C: 4, D: 4, "raider": 2, "sage": 2, "stag_warden": 2, "bone_servant": 2, "firebolt": 2, "dissolve": 2, "growth": 2, "soul_drain": 2, "sellsword": 2, "ironclad": 1})
	fists.reward = {"gold": 250, "xp": 100, "essence": {"A": 4, "B": 4, "C": 4, "D": 4}}
	list.append(fists)
	# ---- Tier 3: Gold Sand --------------------------------------------------------------------------
	var hero: ArenaEncounter = _puzzle("arena_zero_to_hero", 3, ArenaEncounter.Goal.WIN_THIS_TURN, 0, 0)
	hero.enemy_name = "The Wall of Fame"
	hero.enemy_life = 11
	hero.enemy_recipe = {A: 20, "sellsword": 3, "cave_bat": 3}
	hero.player_recipe = {A: 20, "firebolt": 3, "rusty_curse": 3}
	hero.player_life = 8
	hero.preset = {
		"player": {"life": 8, "infrastructure": {"A": 5}, "battlefield": {"raider": 1, "blade_dancer": 1, "beefcake_imp": 1}, "hand": {"warcry": 1, "flame_burst": 1, "firebolt": 1, "rusty_curse": 1}},
		"enemy": {"life": 11, "infrastructure": {"A": 2}, "battlefield": {"sellsword": 1, "cave_bat": 1}, "hand": {}},
	}
	hero.reward = {"equipment": "gladiators_net", "gold": 200, "xp": 120}
	list.append(hero)
	var marshal: ArenaEncounter = _battle("arena_marshal", 3, "Marshal Vesna Tuskmore", 30, "Aggressive", {A: 16, "blazing_charger": 3, "raider": 3, "blade_dancer": 3, "beefcake_imp": 3, "flame_burst": 3, "warcry": 2, "firebolt": 3, "scorching_ward": 2, "ironclad": 2})
	marshal.reward = {"equipment": "bloodsand_boots", "gold": 500, "xp": 250, "essence": {"primary": 10}}
	list.append(marshal)
	return list


static func _battle(id: String, tier: int, enemy: String, life: int, ai: String, recipe: Dictionary) -> ArenaEncounter:
	var encounter: ArenaEncounter = ArenaEncounter.new()
	encounter.id = id
	encounter.tier = tier
	encounter.kind = ArenaEncounter.Kind.BATTLE
	encounter.enemy_name = enemy
	encounter.enemy_life = life
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
