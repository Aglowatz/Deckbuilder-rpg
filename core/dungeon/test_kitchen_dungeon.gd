class_name TestKitchenDungeon
extends RefCounted
## THE TEST KITCHEN (Gourmands): an experimental kitchen, food laboratory and ridiculous weapons-
## development centre. Increasingly dangerous prototypes, corrupted ingredients, experimental food
## constructs, enormous unfinished war machines; the boss is the doppelganger leader (the False Aurelio)
## and there is a reveal moment (cutscene "reveal"). 12 nodes, three branch points that rejoin.
## Text: data/story/gourmand_story.tres (`dungeon.tk_*`, `event.tk_*`, `cutscene.reveal.*`).

const ZONE_ID: String = "gourmand"
const REWARD_CARD_ID: String = "aurelio_the_true"


static func build_def() -> MainDungeonDef:
	var def: MainDungeonDef = MainDungeonDef.new()
	def.zone_id = ZONE_ID
	def.dungeon_name = "The Test Kitchen"
	def.backdrop = "kitchen"
	def.reward_card_id = REWARD_CARD_ID
	def.reward_gold = 220
	def.reward_xp = 160
	var B: String = "infrastructure:B"
	def.add_foe("Corrupted Sous-Chef", 12, "Balanced", {B: 16, "breadstick_sentry": 4, "gravy_courier": 3, "soup_of_the_day": 2, "sellsword": 2}, "delapouite/chef-toque")
	def.add_foe("Cold Storage Prototype", 13, "Defensive", {B: 16, "gelatin_sentinel": 4, "sneeze_guard": 3, "meatloaf_golem": 2, "food_fight": 1}, "delapouite/ice-golem")
	def.add_foe("Experimental Food Construct", 18, "Aggressive", {B: 15, "meatloaf_golem": 4, "runaway_meatball": 3, "food_fight": 3, "souffle_sprite": 2, "tasting_menu": 1}, "delapouite/gingerbread-man")
	def.add_foe("Special Sauce Vat Warden", 16, "Balanced", {B: 16, "gelatin_sentinel": 3, "sous_assist": 3, "gravy_courier": 3, "soup_of_the_day": 3, "cheese_wheel_golem": 1}, "lorc/bubbling-flask")
	def.add_foe("Mk. IX Prototype", 22, "Aggressive", {B: 15, "meatloaf_golem": 4, "cheese_wheel_golem": 3, "runaway_meatball": 3, "food_fight": 3, "souffle_sprite": 3}, "delapouite/pirate-cannon")
	def.add_foe("The False Aurelio", 28, "Balanced", {B: 16, "meatloaf_golem": 4, "cheese_wheel_golem": 3, "gelatin_sentinel": 3, "souffle_sprite": 3, "food_fight": 3, "tasting_menu": 2, "sous_assist": 2}, "delapouite/chef-toque")
	var panel: ChallengeData = MainDungeonDef.make_challenge("tk_taste_panel", "The Taste Panel", "", ChallengeData.Kind.TOP_N_TYPE_COUNT, 4, 2)
	panel.card_type = CardEnums.CardType.CREATURE
	panel.on_success = [_boon_outcome("Palate of the Panel", CardBuilder.modifier(Modifier.Kind.MAX_LIFE, 3), "Gain +3 max life for the dungeon.")] as Array[ChallengeOutcome]
	panel.on_failure = [MainDungeonDef.outcome(ChallengeOutcome.Kind.LOSE_LIFE, 2, "Lose 2 life.")] as Array[ChallengeOutcome]
	def.add_challenge(panel)
	# The cannon bay (node 6): three ways to deal with the unfinished war machine.
	var cannon: DungeonEvent = DungeonEvent.make("tk_cannon_bay")
	cannon.choice([DungeonEvent.gold(45)] as Array[DungeonEvent.Outcome])
	cannon.choice([DungeonEvent.boon(MainDungeonDef.boon_source("Jammed Cannon", [CardBuilder.modifier(Modifier.Kind.STAT_CHANGE, 0, Modifier.ANY_COLOR, 1)] as Array[Modifier]))] as Array[DungeonEvent.Outcome])
	cannon.choice([DungeonEvent.heal(5), DungeonEvent.damage(1)] as Array[DungeonEvent.Outcome])
	def.add_event(cannon)
	# The whistleblower (node 10): a trapped sous-chef.
	var chef: DungeonEvent = DungeonEvent.make("tk_whistleblower")
	chef.choice([DungeonEvent.boon(MainDungeonDef.boon_source("The Real Recipe", [CardBuilder.modifier(Modifier.Kind.STAT_CHANGE, 1, Modifier.ANY_COLOR, 0)] as Array[Modifier]))] as Array[DungeonEvent.Outcome])
	chef.choice([DungeonEvent.heal(6)] as Array[DungeonEvent.Outcome])
	chef.choice([DungeonEvent.gold(70), DungeonEvent.damage(2)] as Array[DungeonEvent.Outcome])
	def.add_event(chef)
	return def


static func build_map(def: MainDungeonDef) -> DungeonMap:
	var map: DungeonMap = DungeonMap.new()
	map.dungeon_name = def.dungeon_name
	var start: DungeonMap.MapNode = def.node(map, DungeonMap.Kind.START, "tk_dock", Vector2(0.07, 0.5))
	var intake: DungeonMap.MapNode = def.battle(map, DungeonMap.Kind.BATTLE, "tk_intake", Vector2(0.18, 0.5), "Corrupted Sous-Chef")
	var panel: DungeonMap.MapNode = def.challenge_node(map, "tk_panel", Vector2(0.29, 0.27), "tk_taste_panel")
	var cold: DungeonMap.MapNode = def.battle(map, DungeonMap.Kind.BATTLE, "tk_cold", Vector2(0.29, 0.73), "Cold Storage Prototype")
	var canteen: DungeonMap.MapNode = def.shrine_node(map, "tk_canteen", Vector2(0.4, 0.5), 6)
	var construct: DungeonMap.MapNode = def.battle(map, DungeonMap.Kind.ELITE, "tk_construct", Vector2(0.51, 0.27), "Experimental Food Construct")
	var cannon: DungeonMap.MapNode = def.event_node(map, "tk_cannon", Vector2(0.51, 0.73), "tk_cannon_bay")
	var armory: DungeonMap.MapNode = def.treasure_node(map, "tk_armory", Vector2(0.62, 0.5), {"gold": 80, "xp": 40, "item": "healing_draught"})
	var vats: DungeonMap.MapNode = def.battle(map, DungeonMap.Kind.BATTLE, "tk_vats", Vector2(0.72, 0.5), "Special Sauce Vat Warden")
	var mk9: DungeonMap.MapNode = def.battle(map, DungeonMap.Kind.ELITE, "tk_mk9", Vector2(0.83, 0.28), "Mk. IX Prototype")
	var whistle: DungeonMap.MapNode = def.event_node(map, "tk_whistle", Vector2(0.83, 0.72), "tk_whistleblower")
	var boss: DungeonMap.MapNode = def.battle(map, DungeonMap.Kind.BOSS, "tk_boss", Vector2(0.94, 0.5), "The False Aurelio")
	boss.scene = "reveal"
	def.link(map, [start.id], intake.id)
	def.link(map, [intake.id], panel.id)
	def.link(map, [intake.id], cold.id)
	def.link(map, [panel.id, cold.id], canteen.id)
	def.link(map, [canteen.id], construct.id)
	def.link(map, [canteen.id], cannon.id)
	def.link(map, [construct.id, cannon.id], armory.id)
	def.link(map, [armory.id], vats.id)
	def.link(map, [vats.id], mk9.id)
	def.link(map, [vats.id], whistle.id)
	def.link(map, [mk9.id, whistle.id], boss.id)
	return map


static func _boon_outcome(name: String, modifier: Modifier, text: String) -> ChallengeOutcome:
	var made: ChallengeOutcome = MainDungeonDef.outcome(ChallengeOutcome.Kind.GAIN_BOON, 0, text)
	made.boon = MainDungeonDef.boon_source(name, [modifier] as Array[Modifier])
	return made
