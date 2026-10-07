class_name DnaZone
extends RefCounted
## Constants and the `ZoneDef` of the D.N.A. (Department of Necrotic Affairs): the Necrocrat zone that
## the town's Necrocrat entrance leads to. Text lives in ZoneStoryText, not here.

const ID: String = "necrocrat"
const DISPLAY_NAME: String = "The D.N.A."
const FULL_NAME: String = "Department of Necrotic Affairs"

const NPC_DOLORES: String = "Dolores"
const NPC_BARNABY: String = "Barnaby"
const NPC_PIP: String = "Pip"

## Counters / flags the zone sets (quest objectives read these as Conditions).
const COUNTER_PUNCHED_IN: String = "dna_punched_in"
const COUNTER_COFFEE: String = "dna_coffee_brewed"
const COUNTER_CHESTS: String = "dna_chests_opened"
const FLAG_QUIZ_DONE: StringName = &"dna_quiz_done"
const FLAG_PUZZLE_SOLVED: StringName = &"dna_puzzle_solved"
const FLAG_MINI_DUNGEON_CLEARED: StringName = &"dna_mini_dungeon_cleared"
const FLAG_MATCH_FIRST: StringName = &"dna_match_first_clear"
const FLAG_QUIZ_PASSED: StringName = &"dna_quiz_passed"

## Rewards of the hidden stashes: id -> {gold, item, card, equipment}. Documented in
## docs/design/secrets.md - keep both in sync.
const CHEST_REWARDS: Dictionary = {
	"chest_farm_a": {"gold": 35, "item": "", "card": ""},
	"chest_farm_b": {"gold": 0, "item": "healing_salve", "card": ""},
	"chest_maze_0": {"gold": 50, "item": "", "card": ""},
	"chest_maze_1": {"gold": 0, "item": "scroll_of_insight", "card": "N-02"},
	"chest_maze_2": {"gold": 25, "item": "firebrand_charm", "card": ""},
	"chest_records_0": {"gold": 60, "item": "", "card": ""},
	"chest_records_1": {"gold": 0, "item": "vitality_charm", "card": "N-01"},
	"chest_exec": {"gold": 80, "item": "healing_draught", "card": ""},
	# Polish round: the harder the chest is to reach, the better it pays (docs/design/secrets.md).
	"chest_maze_3": {"gold": 60, "pack": "gilded_necrocrat"},
	"chest_maze_4": {"gold": 40, "equipment": "thorned_loincloth"},
	"chest_maze_5": {"gold": 25, "pack": "path_necrocrat"},
	"chest_records_2": {"gold": 50, "card": "N-27"},
	"chest_exec_2": {"gold": 120, "item": "healing_draught"},
	"chest_farm_c": {"gold": 35, "item": "vitality_charm"},
}


static func build_def() -> ZoneDef:
	var def: ZoneDef = ZoneDef.new()
	def.id = ID
	def.display_name = DISPLAY_NAME
	def.full_name = FULL_NAME
	def.music = &"dna"
	def.scene_path = "res://scenes/dna_zone.tscn"
	def.story_path = "res://data/story/dna_story.tres"
	def.fee = 15
	def.fee_label = "Paperwork fee"
	def.wake_speaker = "Dolores (over the intercom)"
	def.flag_quiz_done = FLAG_QUIZ_DONE
	def.flag_quiz_passed = FLAG_QUIZ_PASSED
	def.flag_puzzle_solved = FLAG_PUZZLE_SOLVED
	def.flag_mini_cleared = FLAG_MINI_DUNGEON_CLEARED
	def.flag_minigame_first = FLAG_MATCH_FIRST
	def.flag_met_prefix = "dna"
	def.counter_chests = COUNTER_CHESTS
	def.counter_enemies = "zone_enemies_defeated"
	def.secret_prefix = "dna_"
	def.chest_rewards = CHEST_REWARDS
	def.vendor_ids = ZoneCards.VENDOR_IDS
	def.vendor_name = "Requisitions"
	def.vendor_title = "Requisitions - Necrocrat Issue"
	def.puzzle_kind = "tube"
	def.puzzle_equipment_id = "courier_lanyard"
	def.minigame_kind = "match"
	def.quest_npc_names = [NPC_DOLORES, NPC_BARNABY, NPC_PIP]
	def.ruler_name = "The Registrar"
	def.ruler_tint = Color("2f4f4f")
	def.gloom_tint = Color(0.45, 0.56, 0.54)
	def.hub_anchor = "lobby_center"
	def.freed_npcs = [
		{"id": "vellum", "model": "Mage", "offset": Vector3(0.0, 0.0, 4.0), "yaw": 180.0, "tint": Color(0.85, 0.9, 1.0), "scale": 1.15, "name": "Director Vellum", "speaker": "Director Vellum"},
	]
	def.mini = _mini_def()
	def.npcs = [
		{"id": "dolores", "model": "Mage", "anchor": "dolores", "yaw": 0.0, "tint": Color(0.85, 1.0, 0.95)},
		{"id": "barnaby", "model": "Rogue_Hooded", "anchor": "barnaby", "yaw": 90.0, "tint": Color(0.9, 1.0, 0.85)},
		{"id": "pip", "model": "Rogue", "anchor": "pip", "yaw": 180.0, "tint": Color(0.9, 0.95, 1.0)},
		{"id": "quiz", "model": "Mage", "anchor": "quiz", "yaw": 90.0, "tint": Color(0.75, 0.85, 1.0)},
		{"id": "matching", "model": "Barbarian", "anchor": "matching", "yaw": 135.0, "tint": Color(1.0, 0.85, 1.0)},
	]
	def.spots = [
		_spot("dolores", "Dolores, Front Desk", "dolores", Vector3(0, 0, 1.0), 1.7, "Talk", "quest_npc", {"npc": "dolores", "npc_name": NPC_DOLORES, "speaker": "Dolores"}),
		_spot("barnaby", "Barnaby, Barista", "barnaby", Vector3(0, 0, 0.6), 1.5, "Talk", "quest_npc", {"npc": "barnaby", "npc_name": NPC_BARNABY, "speaker": "Barnaby"}),
		_spot("pip", "Pip, Requisitions", "pip", Vector3(0, 0, -0.6), 1.5, "Talk", "vendor_npc", {"npc": "pip", "npc_name": NPC_PIP, "speaker": "Pip"}),
		_spot("heal", "Breakroom Couch", "heal", Vector3.ZERO, 1.5, "Rest on the couch (full heal)", "heal"),
		_spot("coffee", "Coffee Machine", "coffee", Vector3.ZERO, 1.3, "Pour a cup", "zone"),
		_spot("time_clock", "Time Clock", "time_clock", Vector3.ZERO, 1.3, "Punch in", "zone"),
		_spot("exit", "Elevator to Town", "exit", Vector3.ZERO, 1.6, "Ride up to town (full heal)", "exit"),
		_spot("printer", "Haunted Printer", "printer", Vector3(0.9, 0, 0), 1.4, "Print a card (40 gold)", "zone"),
		_spot("suggestion", "Suggestion Box", "suggestion", Vector3.ZERO, 1.3, "Drop in a suggestion", "zone"),
		_spot("mini_dungeon", "Sub-Basement 3", "mini_dungeon", Vector3.ZERO, 1.5, "Take the elevator to Quarterly Reviews", "mini_dungeon"),
		_spot("main_dungeon", "The Hall of Final Approvals", "main_dungeon", Vector3.ZERO, 1.7, "Take a number and enter the Hall of Final Approvals", "main_dungeon"),
		_spot("puzzle", "Soul Routing Terminal", "puzzle", Vector3.ZERO, 1.7, "Route the souls (puzzle)", "puzzle"),
		_spot("quiz", "Lethe, Compliance Examiner", "quiz", Vector3(0.9, 0, 0), 1.6, "Talk", "quiz", {"npc": "quiz", "speaker": "Lethe"}),
		_spot("matching", "Skylar, Last Employee of the Month", "matching", Vector3(0.0, 0, 0.9), 1.6, "Talk", "minigame", {"npc": "matching", "speaker": "Skylar"}),
	]
	def.poi_kinds = {
		"dolores": MapPoi.Kind.QUEST_GIVER, "barnaby": MapPoi.Kind.QUEST_GIVER, "pip": MapPoi.Kind.VENDOR,
		"heal": MapPoi.Kind.HEAL, "exit": MapPoi.Kind.EXIT, "mini_dungeon": MapPoi.Kind.MINI_DUNGEON,
		"main_dungeon": MapPoi.Kind.DUNGEON, "puzzle": MapPoi.Kind.PUZZLE, "quiz": MapPoi.Kind.QUIZ,
		"matching": MapPoi.Kind.MINIGAME,
	}
	return def


static func _spot(id: String, title: String, anchor: String, offset: Vector3, radius: float, prompt: String, kind: String, extra: Dictionary = {}) -> Dictionary:
	var entry: Dictionary = {"id": id, "title": title, "anchor": anchor, "offset": offset, "radius": radius, "prompt": prompt, "kind": kind}
	entry.merge(extra)
	return entry


static func _mini_def() -> ZoneDef.MiniDef:
	var mini: ZoneDef.MiniDef = ZoneDef.MiniDef.new()
	mini.dungeon_name = "Sub-Basement 3: Quarterly Reviews"
	mini.start_blurb = "The elevator doors open on a conference room. Nobody has been invited. Everybody is here."
	mini.reward_card_id = "N-29"
	mini.battles = [
		_battle("Meeting 1: Kickoff Sync", "A meeting that could have been a memo. The memo is also here.", "Kickoff Facilitator", 12, "Balanced", false,
			EnemyDecks.trimmed("necro_zombies", 27, 15)),
		_battle("Meeting 2: Budget Review", "Every line item is a soul. Every soul is over budget.", "Budget Reviewer", 14, "Defensive", false,
			EnemyDecks.trimmed("necro_control", 28, 15)),
		_battle("Meeting 3: Quarterly Review", "Your performance this quarter has been: deceased.", "The Quarterly Reviewer", 18, "Aggressive", true,
			EnemyDecks.with_cards(EnemyDecks.trimmed("necro_control", 31, 16), {"N-29": 1})),
	]
	return mini


static func _battle(title: String, blurb: String, enemy: String, hp: int, ai: String, elite: bool, recipe: Dictionary) -> ZoneDef.MiniBattle:
	var battle: ZoneDef.MiniBattle = ZoneDef.MiniBattle.new()
	battle.title = title
	battle.blurb = blurb
	battle.enemy = enemy
	battle.hp = hp
	battle.ai_name = ai
	battle.elite = elite
	battle.recipe = recipe
	return battle
