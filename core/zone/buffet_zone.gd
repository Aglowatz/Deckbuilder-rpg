class_name BuffetZone
extends RefCounted
## Constants and the `ZoneDef` of the Endless Buffet: the whimsical giant-food zone that the town's
## Path of the Gourmand leads to. The Gourmands are magical chefs who feed the kingdom and protect it
## with the food golems they cook. All text lives in `data/story/gourmand_story.tres`.

const ID: String = "gourmand"
const DISPLAY_NAME: String = "The Endless Buffet"
const FULL_NAME: String = "The Endless Buffet (Gourmand Country)"
const HUB_NAME: String = "The Grand Pantry"

const NPC_ODALYS: String = "Basil"
const NPC_TARRAGON: String = "Sous-Chef Tarragon"
const NPC_DOLCETTA: String = "Madame Mirepoix"

const QUEST_PANTRY: String = "buf_pantry"
const QUEST_PIE: String = "buf_pie"
const QUEST_MEND: String = "buf_mend"

## Counters / flags the zone sets (quest objectives and gate locks read these as Conditions).
const COUNTER_CHESTS: String = "buf_chests_opened"
const COUNTER_ENEMIES: String = "buf_enemies_defeated"
const COUNTER_GATHERED: String = "buf_gathered"
const COUNTER_BAKED: String = "buf_baked"
const COUNTER_TASTES: String = "buf_tastes"
const COUNTER_COOKIES: String = "buf_cookies"
const COUNTER_BOUNCES: String = "buf_bounces"
const COUNTER_RIDES: String = "buf_rides"
const FLAG_QUIZ_DONE: StringName = &"buf_quiz_done"
const FLAG_QUIZ_PASSED: StringName = &"buf_quiz_passed"
const FLAG_PUZZLE_SOLVED: StringName = &"buf_puzzle_solved"
const FLAG_MINI_CLEARED: StringName = &"buf_mini_dungeon_cleared"
const FLAG_ORDER_FIRST: StringName = &"buf_order_first_clear"
const FLAG_MENDED: StringName = &"buf_golem_mended"
const FLAG_GATE_INGREDIENT: StringName = &"buf_gate_ingredient_open"
const FLAG_GATE_QUEST: StringName = &"buf_gate_quest_open"
const FLAG_GATE_BATTLE: StringName = &"buf_gate_battle_open"

## Falling into the soup: respawn at the last safe spot and lose this much zone HP.
const SOUP_DAMAGE: int = 1

## The six ingredients scattered around the zone (id -> display name). Picking one up adds one to the
## stock (`stock_key`) and to the lifetime `COUNTER_GATHERED`; the oven, the broken golem and one gate
## consume stock. Each can be picked up once per visit.
const INGREDIENTS: Dictionary = {
	"saffron": "Saffron Threads",
	"truffle": "Black Truffle",
	"sea_salt": "Sea Salt Crystals",
	"basil": "Giant Basil Leaf",
	"hot_pepper": "Ghost Pepper",
	"honey": "Jar of Wild Honey",
}
## What the oven needs to bake a Hearty Pot Pie.
const OVEN_RECIPE: Array[String] = ["honey", "basil", "hot_pepper"]
## What mending the broken golem needs.
const MEND_RECIPE: Array[String] = ["sea_salt", "truffle"]
const PIE_ITEM_ID: String = "hearty_pie"

## Rewards of the hidden chests: id -> {gold, item, card, equipment}. Documented in
## docs/design/secrets.md - keep both in sync.
const CHEST_REWARDS: Dictionary = {
	"chest_loaf": {"gold": 40, "item": "", "card": ""},
	"chest_butte": {"gold": 20, "item": "healing_salve", "card": ""},
	"chest_candy": {"gold": 0, "item": "", "card": "G-21"},
	"chest_salt": {"gold": 30, "item": "scroll_of_insight", "card": ""},
	"chest_cheddar": {"gold": 20, "item": "", "card": "G-28"},
	"chest_wheel": {"gold": 60, "item": "healing_draught", "card": ""},
	"chest_pancake": {"gold": 50, "item": "vitality_charm", "card": ""},
	"chest_cake": {"gold": 90, "item": "firebrand_charm", "card": ""},
	# Polish round: the harder the chest is to reach, the better it pays (docs/design/secrets.md).
	"chest_pancake_2": {"gold": 70, "pack": "gilded_gourmand"},
	"chest_cheddar_2": {"gold": 40, "card": "G-28"},
	"chest_meadow_ne": {"gold": 90, "item": "hearty_pie"},
	"chest_cliffs_w": {"gold": 30, "pack": "path_gourmand"},
	"chest_crust": {"gold": 60, "cosmetic": "hat_chef"},
	"chest_edge_sw": {"gold": 45, "item": "scroll_of_insight"},
}


static func stock_key(ingredient_id: String) -> String:
	return "buf_stock_" + ingredient_id




static func build_def() -> ZoneDef:
	var def: ZoneDef = ZoneDef.new()
	def.id = ID
	def.display_name = DISPLAY_NAME
	def.full_name = FULL_NAME
	def.music = &"buffet"
	def.scene_path = "res://scenes/buffet_zone.tscn"
	def.story_path = "res://data/story/gourmand_story.tres"
	def.fee = 20
	def.fee_label = "Dish duty fee"
	def.wake_speaker = "Basil"
	def.flag_quiz_done = FLAG_QUIZ_DONE
	def.flag_quiz_passed = FLAG_QUIZ_PASSED
	def.flag_puzzle_solved = FLAG_PUZZLE_SOLVED
	def.flag_mini_cleared = FLAG_MINI_CLEARED
	def.flag_minigame_first = FLAG_ORDER_FIRST
	def.flag_met_prefix = "buf"
	def.counter_chests = COUNTER_CHESTS
	def.counter_enemies = COUNTER_ENEMIES
	def.secret_prefix = "buf_"
	def.chest_rewards = CHEST_REWARDS
	def.vendor_ids = ZoneCards.BUFFET_VENDOR_IDS
	def.vendor_name = "Dolcetta's"
	def.vendor_title = "Dolcetta's Dessert & Deckery - Gourmand Issue"
	def.puzzle_kind = "recipe"
	def.puzzle_equipment_id = "head_chef_ladle"
	def.minigame_kind = "order"
	def.quest_npc_names = [NPC_ODALYS, NPC_TARRAGON, NPC_DOLCETTA]
	def.ruler_name = "The Grand Chef"
	def.ruler_tint = Color("5f7a1c")
	def.gloom_tint = Color(0.62, 0.68, 0.38)
	def.freed_npcs = [
		{"id": "aurelio", "npc_id": "NPC-ESCOFFINA", "model": "Knight", "offset": Vector3(0.0, 0.0, 7.0), "yaw": 180.0, "tint": Color(1.0, 0.95, 0.9), "scale": 1.2, "name": "Grand Chef Escoffina", "speaker": "Grand Chef Escoffina"},
	]
	def.mini = _mini_def()
	def.npcs = [
		{"id": "odalys", "npc_id": "NPC-BASIL", "model": "Knight", "anchor": "odalys", "yaw": 0.0, "tint": Color(1.25, 1.15, 1.05), "scale": 1.7, "hat": "tall"},
		{"id": "tarragon", "model": "Rogue_Hooded", "anchor": "tarragon", "yaw": 90.0, "tint": Color(0.85, 1.2, 0.8), "scale": 1.45, "hat": "short"},
		{"id": "dolcetta", "npc_id": "V-MIREPOIX", "model": "Mage", "anchor": "dolcetta", "yaw": 200.0, "tint": Color(1.3, 0.85, 1.0), "scale": 1.5, "hat": "pastry"},
		{"id": "quiz", "npc_id": "NPC-PATE", "model": "Mage", "anchor": "quiz", "yaw": 90.0, "tint": Color(1.25, 1.1, 0.8), "scale": 1.5, "hat": "scholar"},
		{"id": "minigame", "npc_id": "NPC-FLAMBE", "model": "Barbarian", "anchor": "minigame", "yaw": 180.0, "tint": Color(1.4, 0.75, 0.55), "scale": 1.7, "hat": "tall"},
	]
	def.spots = [
		_spot("odalys", "Basil, Keeper of the Grand Pantry", "odalys", Vector3(0, 0, 1.0), 1.8, "Talk", "quest_npc", {"npc": "odalys", "npc_id": "NPC-BASIL", "npc_name": NPC_ODALYS, "speaker": "Basil"}),
		_spot("tarragon", "Sous-Chef Tarragon, Fetcher of Things", "tarragon", Vector3(0.9, 0, 0), 1.7, "Talk", "quest_npc", {"npc": "tarragon", "npc_name": NPC_TARRAGON, "speaker": "Sous-Chef Tarragon"}),
		_spot("dolcetta", "Dolcetta's Dessert & Deckery", "dolcetta", Vector3(-1.6, 0, 0.2), 1.9, "Talk", "vendor_npc", {"npc": "dolcetta", "npc_id": "V-MIREPOIX", "npc_name": NPC_DOLCETTA, "speaker": "Madame Mirepoix"}),
		_spot("heal", "The Hearty Meal", "heal", Vector3(0, 0, 1.6), 1.9, "Sit down for a hearty meal (full heal)", "heal"),
		_spot("exit", "The Path of the Gourmand", "exit", Vector3(0, 0, -0.8), 1.8, "Walk back down to town (full heal)", "exit"),
		_spot("mini_dungeon", "The Walk-In Freezer", "mini_dungeon", Vector3(0, 0, 1.6), 1.8, "Open the freezer door: three courses", "mini_dungeon"),
		_spot("main_dungeon", "The Test Kitchen", "main_dungeon", Vector3(0, 0, 1.4), 2.0, "Enter the Test Kitchen", "main_dungeon"),
		_spot("puzzle", "The Mystery Stew Pot", "puzzle", Vector3(0, 0, 1.2), 1.9, "Work out the recipe (puzzle)", "puzzle"),
		_spot("quiz", "Professor Pate, Keeper of the Cookbook", "quiz", Vector3(0.9, 0, 0), 1.8, "Talk", "quiz", {"npc": "quiz", "npc_id": "NPC-PATE", "speaker": "Professor Pate"}),
		_spot("minigame", "Chef Flambe Fontaine, Host of Dinner in a Dash", "minigame", Vector3(0, 0, 1.2), 1.9, "Talk", "minigame", {"npc": "minigame", "npc_id": "NPC-FLAMBE", "speaker": "Chef Flambe Fontaine"}),
		_spot("oven", "The Grand Oven", "oven", Vector3(0, 0, 1.6), 1.9, "Bake a Hearty Pot Pie", "zone"),
		_spot("taste_test", "Taste-Test Station", "taste_test", Vector3(0, 0, 1.4), 1.8, "Take the blind taste test (8 gold)", "zone"),
		_spot("soup_fountain", "The Soup Fountain", "soup_fountain", Vector3(0, 0, 2.4), 2.2, "Ladle some soup", "zone"),
		_spot("fortune_cookie", "Fortune Cookie Dispenser", "fortune_cookie", Vector3(0, 0, 1.2), 1.8, "Crack a fortune cookie (5 gold)", "zone"),
		_spot("old_meatloaf", "Old Meatloaf (Out of Order)", "old_meatloaf", Vector3(0.0, 0, 1.6), 1.9, "Look him over", "zone"),
	]
	def.poi_kinds = {
		"odalys": MapPoi.Kind.QUEST_GIVER, "tarragon": MapPoi.Kind.QUEST_GIVER, "dolcetta": MapPoi.Kind.VENDOR,
		"heal": MapPoi.Kind.HEAL, "exit": MapPoi.Kind.EXIT, "mini_dungeon": MapPoi.Kind.MINI_DUNGEON,
		"main_dungeon": MapPoi.Kind.DUNGEON, "puzzle": MapPoi.Kind.PUZZLE, "quiz": MapPoi.Kind.QUIZ,
		"minigame": MapPoi.Kind.MINIGAME, "oven": MapPoi.Kind.INTERACTABLE, "taste_test": MapPoi.Kind.INTERACTABLE,
		"soup_fountain": MapPoi.Kind.INTERACTABLE, "fortune_cookie": MapPoi.Kind.INTERACTABLE,
		"old_meatloaf": MapPoi.Kind.INTERACTABLE,
	}
	# The golem gate guardians and the ingredient pickups: one spot each (handled by BuffetScene).
	for gate: BuffetGates.Gate in BuffetGates.gates():
		def.spots.append(_spot("gate_" + gate.id, gate.title, gate.anchor, Vector3(0, 0, 1.6), 2.0, "Speak to the golem", "zone", {"gate": gate.id}))
		def.poi_kinds["gate_" + gate.id] = MapPoi.Kind.GATE
	for ingredient_id: String in INGREDIENTS.keys():
		def.spots.append(_spot("pickup_" + ingredient_id, str(INGREDIENTS[ingredient_id]), "pickup_" + ingredient_id, Vector3.ZERO, 1.4, "Pick up the %s" % str(INGREDIENTS[ingredient_id]), "zone", {"pickup": ingredient_id}))
	return def


static func _spot(id: String, title: String, anchor: String, offset: Vector3, radius: float, prompt: String, kind: String, extra: Dictionary = {}) -> Dictionary:
	var entry: Dictionary = {"id": id, "title": title, "anchor": anchor, "offset": offset, "radius": radius, "prompt": prompt, "kind": kind}
	entry.merge(extra)
	return entry


## The zone's side dungeon (S-BEEF, S-NECRO...): everything comes from the dungeon list through `MiniDungeon.def_for`.
static func _mini_def() -> ZoneDef.MiniDef:
	return MiniDungeon.def_for(ID)
