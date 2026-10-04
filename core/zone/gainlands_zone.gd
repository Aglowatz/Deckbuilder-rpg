class_name GainlandsZone
extends RefCounted
## Constants and the `ZoneDef` of the Gainlands: the big, bright Beefcake zone that the town's
## Beefcake Path leads to. The Beefcakes are huge, muscular people responsible for energy (pushing
## mills, running giant hamster wheels) and transportation (throwing people across distances,
## physically ripping open portals). All text lives in `data/story/gainlands_story.tres`.

const ID: String = "beefcake"
const DISPLAY_NAME: String = "The Gainlands"
const FULL_NAME: String = "The Gainlands (Beefcake Country)"
const HUB_NAME: String = "The Swole Station"

const NPC_BRENDA: String = "Coach Brenda"
const NPC_GUS: String = "Foreman Gus"
const NPC_TONY: String = "Tiny Tony"

const QUEST_POWER: String = "gain_power"
const QUEST_SPOT_ME: String = "gain_spot_me"
const QUEST_LANES: String = "gain_lanes"

## Counters / flags the zone sets (quest objectives and travel locks read these as Conditions).
const COUNTER_CHESTS: String = "gain_chests_opened"
const COUNTER_ENEMIES: String = "gain_enemies_defeated"
const COUNTER_SHAKES: String = "gain_shakes_bought"
const COUNTER_FLEXES: String = "gain_flexes"
const FLAG_QUIZ_DONE: StringName = &"gain_quiz_done"
const FLAG_QUIZ_PASSED: StringName = &"gain_quiz_passed"
const FLAG_PUZZLE_SOLVED: StringName = &"gain_puzzle_solved"
const FLAG_MINI_CLEARED: StringName = &"gain_mini_dungeon_cleared"
const FLAG_REPS_FIRST: StringName = &"gain_reps_first_clear"
const FLAG_WHEEL_POWERED: StringName = &"gain_wheel_powered"
const FLAG_SPOTTED: StringName = &"gain_spotted_gary"

## Falling off an island: respawn at the last safe spot and lose this much zone life.
const FALL_DAMAGE: int = 1

## Rewards of the hidden chests: id -> {gold, item, card, equipment}. Documented in
## docs/design/secrets.md - keep both in sync.
const CHEST_REWARDS: Dictionary = {
	"chest_ground_0": {"gold": 40, "item": "", "card": ""},
	"chest_ground_1": {"gold": 20, "item": "healing_salve", "card": ""},
	"chest_ground_2": {"gold": 0, "item": "", "card": "wheel_runner"},
	"chest_pec": {"gold": 60, "item": "scroll_of_insight", "card": ""},
	"chest_delt": {"gold": 0, "item": "", "card": "max_rep"},
	"chest_glute": {"gold": 90, "item": "healing_draught", "card": ""},
	"chest_calf": {"gold": 50, "item": "vitality_charm", "card": "cheat_day"},
}


static func build_def() -> ZoneDef:
	var def: ZoneDef = ZoneDef.new()
	def.id = ID
	def.display_name = DISPLAY_NAME
	def.full_name = FULL_NAME
	def.music = &"gainlands"
	def.scene_path = "res://scenes/gainlands_zone.tscn"
	def.story_path = "res://data/story/gainlands_story.tres"
	def.fee = 20
	def.fee_label = "Protein tab"
	def.wake_speaker = "Coach Brenda"
	def.flag_quiz_done = FLAG_QUIZ_DONE
	def.flag_quiz_passed = FLAG_QUIZ_PASSED
	def.flag_puzzle_solved = FLAG_PUZZLE_SOLVED
	def.flag_mini_cleared = FLAG_MINI_CLEARED
	def.flag_minigame_first = FLAG_REPS_FIRST
	def.flag_met_prefix = "gain"
	def.counter_chests = COUNTER_CHESTS
	def.counter_enemies = COUNTER_ENEMIES
	def.secret_prefix = "gain_"
	def.chest_rewards = CHEST_REWARDS
	def.vendor_ids = ZoneCards.GAINLANDS_VENDOR_IDS
	def.vendor_name = "Tiny Tony's"
	def.vendor_title = "Tiny Tony's Protein & Pasteboard - Beefcake Issue"
	def.puzzle_kind = "wheels"
	def.puzzle_equipment_id = "swole_belt"
	def.minigame_kind = "reps"
	def.quest_npc_names = [NPC_BRENDA, NPC_GUS, NPC_TONY]
	def.mini = _mini_def()
	def.npcs = [
		{"id": "brenda", "model": "Barbarian", "anchor": "brenda", "yaw": 0.0, "tint": Color(1.0, 0.75, 0.85), "scale": 1.5},
		{"id": "gus", "model": "Rogue_Hooded", "anchor": "gus", "yaw": 90.0, "tint": Color(1.0, 0.9, 0.6), "scale": 1.15},
		{"id": "tony", "model": "Barbarian", "anchor": "tony", "yaw": 200.0, "tint": Color(0.8, 0.9, 1.0), "scale": 1.9},
		{"id": "quiz", "model": "Mage", "anchor": "quiz", "yaw": 90.0, "tint": Color(0.85, 0.95, 1.0), "scale": 1.1},
		{"id": "minigame", "model": "Rogue", "anchor": "minigame", "yaw": 180.0, "tint": Color(1.0, 0.45, 0.85), "scale": 1.1},
		{"id": "gary", "model": "Barbarian", "anchor": "spot_me", "yaw": 200.0, "tint": Color(0.9, 1.0, 0.8), "scale": 1.4, "anim": "Lie_Idle"},
	]
	def.spots = [
		_spot("brenda", "Coach Brenda, Head Spotter", "brenda", Vector3(0, 0, 1.0), 1.7, "Talk", "quest_npc", {"npc": "brenda", "npc_name": NPC_BRENDA, "speaker": "Coach Brenda"}),
		_spot("gus", "Foreman Gus, Wheel Wrangler", "gus", Vector3(0.9, 0, 0), 1.6, "Talk", "quest_npc", {"npc": "gus", "npc_name": NPC_GUS, "speaker": "Foreman Gus"}),
		_spot("tony", "Tiny Tony's Protein & Pasteboard", "tony", Vector3(-0.8, 0, 0.5), 1.8, "Talk", "vendor_npc", {"npc": "tony", "npc_name": NPC_TONY, "speaker": "Tiny Tony"}),
		_spot("heal", "Cooldown Hot Tub", "heal", Vector3(0, 0, 1.6), 1.9, "Soak in the tub (full heal)", "heal"),
		_spot("exit", "The Beefcake Path", "exit", Vector3(0, 0, -0.8), 1.8, "Walk back down to town (full heal)", "exit"),
		_spot("mini_dungeon", "The Iron Cavern", "mini_dungeon", Vector3(0, 0, 0.8), 1.7, "Enter the Iron Cavern: three sets", "mini_dungeon"),
		_spot("main_dungeon", "Closed for Leg Day", "main_dungeon", Vector3(0, 0, 0.6), 2.0, "Try the gate", "main_dungeon"),
		_spot("puzzle", "Power Grid Control Panel", "puzzle", Vector3.ZERO, 1.8, "Route the power (puzzle)", "puzzle"),
		_spot("quiz", "Professor Quad, Beefcake Scholar", "quiz", Vector3(0.9, 0, 0), 1.7, "Talk", "quiz", {"npc": "quiz", "speaker": "Professor Quad"}),
		_spot("minigame", "Jazzy Jules, 3 AM Fitness Host", "minigame", Vector3(0, 0, 1.0), 1.8, "Talk", "minigame", {"npc": "minigame", "speaker": "Jazzy Jules"}),
		_spot("protein_stand", "Protein Shake Stand", "protein_stand", Vector3(0, 0, 1.2), 1.7, "Buy a mystery shake (10 gold)", "zone"),
		_spot("flex_mirror", "Flex Mirror", "flex_mirror", Vector3(0.9, 0, 0), 1.5, "Flex at the mirror", "zone"),
		_spot("flex_mirror_pec", "Flex Mirror (Pec Perch)", "flex_mirror_pec", Vector3(0.9, 0, 0), 1.5, "Flex at the mirror", "zone"),
		_spot("spot_me", "Gary, Currently Under a Barbell", "spot_me", Vector3(0.9, 0, 0), 1.7, "Talk", "zone", {"npc": "gary"}),
		_spot("run_wheel", "Colossal Hamster Wheel", "run_wheel", Vector3.ZERO, 1.8, "Run the wheel", "zone"),
	]
	def.poi_kinds = {
		"brenda": MapPoi.Kind.QUEST_GIVER, "gus": MapPoi.Kind.QUEST_GIVER, "tony": MapPoi.Kind.VENDOR,
		"heal": MapPoi.Kind.HEAL, "exit": MapPoi.Kind.EXIT, "mini_dungeon": MapPoi.Kind.MINI_DUNGEON,
		"main_dungeon": MapPoi.Kind.DUNGEON, "puzzle": MapPoi.Kind.PUZZLE, "quiz": MapPoi.Kind.QUIZ,
		"minigame": MapPoi.Kind.MINIGAME, "protein_stand": MapPoi.Kind.INTERACTABLE,
		"flex_mirror": MapPoi.Kind.INTERACTABLE, "flex_mirror_pec": MapPoi.Kind.INTERACTABLE,
		"spot_me": MapPoi.Kind.INTERACTABLE, "run_wheel": MapPoi.Kind.INTERACTABLE,
	}
	# The thrower / portal-ripper Beefcakes: one NPC and one spot each (handled by GainlandsScene).
	for point: GainlandsTravel.Point in GainlandsTravel.points():
		def.npcs.append({"id": point.id, "model": "Barbarian", "anchor": point.anchor, "yaw": 180.0, "tint": point.tint, "scale": 1.7})
		var verb: String = "Get thrown" if point.kind == "throw" else "Step through"
		def.spots.append(_spot("travel_" + point.id, point.title, point.anchor, Vector3(0, 0, 1.1), 1.9, verb, "zone", {"npc": point.id, "travel": point.id}))
	return def


static func _spot(id: String, title: String, anchor: String, offset: Vector3, radius: float, prompt: String, kind: String, extra: Dictionary = {}) -> Dictionary:
	var entry: Dictionary = {"id": id, "title": title, "anchor": anchor, "offset": offset, "radius": radius, "prompt": prompt, "kind": kind}
	entry.merge(extra)
	return entry


static func _mini_def() -> ZoneDef.MiniDef:
	var mini: ZoneDef.MiniDef = ZoneDef.MiniDef.new()
	mini.dungeon_name = "The Iron Cavern: Three Sets"
	mini.start_title = "Chalk Up"
	mini.start_blurb = "A cave that smells of rubber mats and ambition. Somebody has left a towel on every rock."
	mini.reward_card_id = "iron_titan"
	mini.battles = [
		_battle("Set 1: The Warm-Up", "Light weight, heavy attitude. Stretch first.", "Warm-Up Whelp", 12, "Balanced", false,
			{"infrastructure:A": 15, "gym_rat": 4, "wheel_runner": 3, "mill_hand": 3, "cheat_day": 1}),
		_battle("Set 2: Working Weight", "A spotter who has seen things. Mostly your elbows.", "Rogue Spotter", 14, "Defensive", false,
			{"infrastructure:A": 15, "protein_golem": 3, "mill_hand": 3, "pump_chaser": 2, "flex_off": 2, "pre_workout": 1}),
		_battle("Set 3: One-Rep Max", "The Titan of the Rack. It has never once skipped leg day.", "Titan of the Rack", 18, "Aggressive", true,
			{"infrastructure:A": 16, "max_rep": 2, "courtesy_chucker": 3, "pump_chaser": 3, "leg_day": 2, "flex_off": 2}),
	]
	return mini


static func _battle(title: String, blurb: String, enemy: String, life: int, ai: String, elite: bool, recipe: Dictionary) -> ZoneDef.MiniBattle:
	var battle: ZoneDef.MiniBattle = ZoneDef.MiniBattle.new()
	battle.title = title
	battle.blurb = blurb
	battle.enemy = enemy
	battle.life = life
	battle.ai_name = ai
	battle.elite = elite
	battle.recipe = recipe
	return battle
