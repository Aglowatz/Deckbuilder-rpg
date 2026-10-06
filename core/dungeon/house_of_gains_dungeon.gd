class_name HouseOfGainsDungeon
extends RefCounted
## THE HOUSE OF GAINS (Beefcakes): the regime's stronghold. A major section is the IRON-LESS PRISON:
## the player descends, rescues the original leader (Heartlift: emaciated and decrepit), who then joins as a
## dungeon-wide boon for the rest of the run, and continues through the House. At the final
## confrontation a short scene (cutscene "flex"): he throws off his outer clothing, still incredibly
## muscular, and explains that true strength comes from the heart and the mind. Boss: Commander Gristle.
## 13 nodes, two branch points that rejoin.
## Text: data/story/gainlands_story.tres (`dungeon.hg_*`, `event.hg_*`, `cutscene.rescue.*`, `cutscene.flex.*`).

const ZONE_ID: String = "beefcake"
const REWARD_CARD_ID: String = "heartlift_the_unbroken"
const RESCUE_NODE_KEY: String = "hg_rescue"


## Heartlift's dungeon-wide boon: strength of heart and mind (+1/+1 to all your units, +3 max HP).
static func heartlift_boon() -> ModifierSource:
	return MainDungeonDef.boon_source("Heartlift Fights Beside You", [
		CardBuilder.modifier(Modifier.Kind.STAT_CHANGE, 1, Modifier.ANY_COLOR, 1),
		CardBuilder.modifier(Modifier.Kind.MAX_HP, 3),
	] as Array[Modifier])


static func build_def() -> MainDungeonDef:
	var def: MainDungeonDef = MainDungeonDef.new()
	def.zone_id = ZONE_ID
	def.dungeon_name = "The House of Gains"
	def.backdrop = "house"
	def.reward_card_id = REWARD_CARD_ID
	def.reward_gold = 220
	def.reward_xp = 160
	def.boon = heartlift_boon()
	var A: String = "infrastructure:A"
	def.add_foe("Regime Enforcer", 12, "Aggressive", {A: 16, "gym_rat": 4, "pump_chaser": 3, "courtesy_chucker": 2, "sellsword": 2}, "delapouite/viking-head")
	def.add_foe("Cell Block Brawler", 14, "Aggressive", {A: 16, "gym_rat": 4, "mill_hand": 3, "cheat_day": 2, "pre_workout": 2}, "lorc/muscle-up")
	def.add_foe("The Iron-less Warden", 18, "Defensive", {A: 15, "protein_golem": 4, "wheel_runner": 3, "leg_day": 3, "flex_off": 2, "max_rep": 1}, "lorc/imprisoned")
	def.add_foe("Barracks Drill Sergeant", 16, "Aggressive", {A: 16, "pump_chaser": 4, "gym_rat": 3, "wheel_runner": 3, "flex_off": 3, "pre_workout": 1}, "delapouite/weight-lifting-up")
	def.add_foe("Honor Guard Captain", 22, "Aggressive", {A: 15, "protein_golem": 4, "max_rep": 3, "leg_day": 3, "flex_off": 3, "cheat_day": 3}, "delapouite/strong-man")
	def.add_foe("Commander Gristle", 28, "Aggressive", {A: 16, "protein_golem": 4, "max_rep": 4, "leg_day": 3, "flex_off": 3, "cheat_day": 3, "pre_workout": 2, "courtesy_chucker": 2}, "delapouite/viking-head")
	# The Calisthenics Check (node 4): the prison has no iron, so it tests bodies, not weights.
	var check: ChallengeData = MainDungeonDef.make_challenge("hg_calisthenics", "The Calisthenics Check", "", ChallengeData.Kind.FIRST_UNIT_ATTACK, 0, 3)
	var might: ChallengeOutcome = MainDungeonDef.outcome(ChallengeOutcome.Kind.GAIN_BOON, 0, "Gain +2 max HP for the dungeon.")
	might.boon = MainDungeonDef.boon_source("Prison Push-ups", [CardBuilder.modifier(Modifier.Kind.MAX_HP, 2)] as Array[Modifier])
	check.on_success = [might] as Array[ChallengeOutcome]
	check.on_failure = [MainDungeonDef.outcome(ChallengeOutcome.Kind.LOSE_HP, 3, "Lose 3 HP.")] as Array[ChallengeOutcome]
	def.add_challenge(check)
	# The Descent (node 2).
	var descent: DungeonEvent = DungeonEvent.make("hg_descent")
	descent.choice([DungeonEvent.nothing()] as Array[DungeonEvent.Outcome])
	descent.choice([DungeonEvent.gold(40), DungeonEvent.damage(2)] as Array[DungeonEvent.Outcome])
	descent.choice([DungeonEvent.heal(3)] as Array[DungeonEvent.Outcome])
	def.add_event(descent)
	# The Rescue (node 6): the leader joins - the BOON outcome IS the rescue.
	var rescue: DungeonEvent = DungeonEvent.make("hg_rescue")
	rescue.choice([DungeonEvent.boon(def.boon)] as Array[DungeonEvent.Outcome])
	def.add_event(rescue)
	# The Trophy Hall (node 11).
	var trophies: DungeonEvent = DungeonEvent.make("hg_trophy_hall")
	trophies.choice([DungeonEvent.gold(60)] as Array[DungeonEvent.Outcome])
	trophies.choice([DungeonEvent.heal(4)] as Array[DungeonEvent.Outcome])
	trophies.choice([DungeonEvent.nothing()] as Array[DungeonEvent.Outcome])
	def.add_event(trophies)
	return def


static func build_map(def: MainDungeonDef) -> DungeonMap:
	var map: DungeonMap = DungeonMap.new()
	map.dungeon_name = def.dungeon_name
	var start: DungeonMap.MapNode = def.node(map, DungeonMap.Kind.START, "hg_gates", Vector2(0.06, 0.5))
	var check_point: DungeonMap.MapNode = def.battle(map, DungeonMap.Kind.BATTLE, "hg_checkpoint", Vector2(0.15, 0.5), "Regime Enforcer")
	var descent: DungeonMap.MapNode = def.event_node(map, "hg_descent", Vector2(0.24, 0.5), "hg_descent", "prison")
	var cells: DungeonMap.MapNode = def.battle(map, DungeonMap.Kind.BATTLE, "hg_cells", Vector2(0.34, 0.27), "Cell Block Brawler", "prison")
	var calisthenics: DungeonMap.MapNode = def.challenge_node(map, "hg_calisthenics", Vector2(0.34, 0.73), "hg_calisthenics", "prison")
	var warden: DungeonMap.MapNode = def.battle(map, DungeonMap.Kind.ELITE, "hg_warden", Vector2(0.44, 0.5), "The Iron-less Warden", "prison")
	var rescue: DungeonMap.MapNode = def.event_node(map, "hg_rescue", Vector2(0.53, 0.5), "hg_rescue", "prison", "rescue")
	var stretch: DungeonMap.MapNode = def.shrine_node(map, "hg_stretch", Vector2(0.62, 0.5), 6)
	var barracks: DungeonMap.MapNode = def.battle(map, DungeonMap.Kind.BATTLE, "hg_barracks", Vector2(0.71, 0.27), "Barracks Drill Sergeant")
	var locker: DungeonMap.MapNode = def.treasure_node(map, "hg_locker", Vector2(0.71, 0.73), {"gold": 90, "xp": 40, "item": "sharpening_stone"})
	var guard: DungeonMap.MapNode = def.battle(map, DungeonMap.Kind.ELITE, "hg_guard", Vector2(0.8, 0.5), "Honor Guard Captain")
	var trophy: DungeonMap.MapNode = def.event_node(map, "hg_trophy", Vector2(0.88, 0.5), "hg_trophy_hall")
	var boss: DungeonMap.MapNode = def.battle(map, DungeonMap.Kind.BOSS, "hg_boss", Vector2(0.95, 0.5), "Commander Gristle")
	boss.scene = "flex"
	def.link(map, [start.id], check_point.id)
	def.link(map, [check_point.id], descent.id)
	def.link(map, [descent.id], cells.id)
	def.link(map, [descent.id], calisthenics.id)
	def.link(map, [cells.id, calisthenics.id], warden.id)
	def.link(map, [warden.id], rescue.id)
	def.link(map, [rescue.id], stretch.id)
	def.link(map, [stretch.id], barracks.id)
	def.link(map, [stretch.id], locker.id)
	def.link(map, [barracks.id, locker.id], guard.id)
	def.link(map, [guard.id], trophy.id)
	def.link(map, [trophy.id], boss.id)
	return map
