class_name HeapZone
extends RefCounted
## Constants and the `ZoneDef` of the Verdant Heap: the overgrown junkyard-farm zone that the town's Path of the
## Refusemancer leads to. The Refusemancers are druids responsible for waste removal and agriculture: they summon
## animals that eat the kingdom's garbage and turn it into fertilizer, and use magic to help crops grow. All text
## lives in `data/story/refusemancer_story.tres`. Pure data: nothing here touches `Session` (see `HeapInteractables`).

const ID: String = "refusemancer"
const DISPLAY_NAME: String = "The Verdant Heap"
const FULL_NAME: String = "The Verdant Heap (Refusemancer Country)"
const HUB_NAME: String = "The Compost Grange"

const NPC_MARIGOLD: String = "Druid Marigold"
const NPC_HOB: String = "Farmer Hob"
const NPC_WREN: String = "Wren Muckfoot"

const QUEST_HERD: String = "heap_herd"
const QUEST_FERT: String = "heap_fert"
const QUEST_DAM: String = "heap_dam"

## Counters / flags the zone sets (quest objectives and growth requirements read these as Conditions).
const COUNTER_CHESTS: String = "heap_chests_opened"
const COUNTER_ENEMIES: String = "heap_enemies_defeated"
const COUNTER_HERDED: String = "heap_herded"
const COUNTER_FERTILIZER: String = "heap_fertilizer_gathered"
const COUNTER_COMPOSTED: String = "heap_composted"
const COUNTER_HARVESTS: String = "heap_harvests"
const COUNTER_FEEDINGS: String = "heap_feedings"
const COUNTER_GROWN: String = "heap_things_grown"
const COUNTER_RIDES: String = "heap_rides"
const COUNTER_CHARGES: String = "heap_charges"
const COUNTER_SLIDES: String = "heap_slides"
const FLAG_QUIZ_DONE: StringName = &"heap_quiz_done"
const FLAG_QUIZ_PASSED: StringName = &"heap_quiz_passed"
const FLAG_PUZZLE_SOLVED: StringName = &"heap_puzzle_solved"
const FLAG_MINI_CLEARED: StringName = &"heap_mini_dungeon_cleared"
const FLAG_SORT_FIRST: StringName = &"heap_sort_first_clear"

## Falling into the compost pit or the recycling stream: respawn at the last safe spot and lose this much life.
const HAZARD_DAMAGE: int = 1

## Stock items scattered around the zone (id -> display name). Picking one up adds one to the stock
## (`stock_key`); each can be picked up once per visit. Beans grow bridges and beanstalks, fertilizer feeds the crop
## plots, junk goes in the compost bin and the animal trough.
const PICKUPS: Dictionary = {
	"bean_1": "Magic Bean",
	"bean_2": "Magic Bean",
	"bean_3": "Magic Bean",
	"fert_1": "Sack of Fertilizer",
	"fert_2": "Sack of Fertilizer",
	"fert_3": "Sack of Fertilizer",
	"junk_1": "Pile of Good Junk",
	"junk_2": "Pile of Good Junk",
	"junk_3": "Pile of Good Junk",
}

## Rewards of the hidden chests: id -> {gold, item, card, equipment}. Documented in docs/design/secrets.md - keep
## both in sync.
const CHEST_REWARDS: Dictionary = {
	"chest_fridge": {"gold": 40, "item": "", "card": ""},
	"chest_compost": {"gold": 25, "item": "healing_salve", "card": ""},
	"chest_peak_a": {"gold": 0, "item": "", "card": "recycle_bin"},
	"chest_hay": {"gold": 30, "item": "scroll_of_insight", "card": ""},
	"chest_log": {"gold": 60, "item": "healing_draught", "card": ""},
	"chest_peak_b": {"gold": 20, "item": "", "card": "moss_titan"},
	"chest_car": {"gold": 90, "item": "firebrand_charm", "card": ""},
	"chest_barn": {"gold": 50, "item": "vitality_charm", "card": ""},
}


static func stock_key(kind: String) -> String:
	return "heap_stock_" + kind


## "bean_2" -> "bean": pickups of one kind share a stock.
static func pickup_kind(pickup_id: String) -> String:
	return pickup_id.split("_")[0]


static func build_def() -> ZoneDef:
	var def: ZoneDef = ZoneDef.new()
	def.id = ID
	def.display_name = DISPLAY_NAME
	def.full_name = FULL_NAME
	def.music = &"heap"
	def.scene_path = "res://scenes/heap_zone.tscn"
	def.story_path = "res://data/story/refusemancer_story.tres"
	def.fee = 20
	def.fee_label = "Mucking-out fee"
	def.wake_speaker = "Farmer Hob"
	def.flag_quiz_done = FLAG_QUIZ_DONE
	def.flag_quiz_passed = FLAG_QUIZ_PASSED
	def.flag_puzzle_solved = FLAG_PUZZLE_SOLVED
	def.flag_mini_cleared = FLAG_MINI_CLEARED
	def.flag_minigame_first = FLAG_SORT_FIRST
	def.flag_met_prefix = "heap"
	def.counter_chests = COUNTER_CHESTS
	def.counter_enemies = COUNTER_ENEMIES
	def.secret_prefix = "heap_"
	def.chest_rewards = CHEST_REWARDS
	def.vendor_ids = ZoneCards.HEAP_VENDOR_IDS
	def.vendor_name = "Hob's Swap Shed"
	def.vendor_title = "Hob's Swap Shed - Refusemancer Issue"
	def.puzzle_kind = "growth"
	def.puzzle_equipment_id = "seed_satchel"
	def.minigame_kind = "sort"
	def.quest_npc_names = [NPC_MARIGOLD, NPC_HOB, NPC_WREN]
	def.mini = _mini_def()
	def.npcs = [
		{"id": "marigold", "model": "Mage", "anchor": "marigold", "yaw": 0.0, "tint": Color(0.75, 1.2, 0.75), "scale": 1.7, "hat": "wreath"},
		{"id": "hob", "model": "Barbarian", "anchor": "hob", "yaw": 200.0, "tint": Color(1.15, 0.95, 0.7), "scale": 1.55, "hat": "straw"},
		{"id": "wren", "model": "Rogue", "anchor": "wren", "yaw": 90.0, "tint": Color(0.85, 1.05, 0.8), "scale": 1.45, "hat": "cap"},
		{"id": "quiz", "model": "Mage", "anchor": "quiz", "yaw": 180.0, "tint": Color(1.1, 1.2, 0.8), "scale": 1.5, "hat": "wreath"},
		{"id": "minigame", "model": "Knight", "anchor": "minigame", "yaw": 180.0, "tint": Color(0.7, 0.85, 1.3), "scale": 1.6, "hat": "ribbon"},
		{"id": "sorrel", "model": "Mage", "anchor": "sorrel", "yaw": 180.0, "tint": Color(0.7, 1.1, 0.85), "scale": 1.55, "hat": "wreath"},
	]
	def.spots = [
		_spot("marigold", "Druid Marigold, Warden of the Stream", "marigold", Vector3(0, 0, 1.0), 1.8, "Talk", "quest_npc", {"npc": "marigold", "npc_name": NPC_MARIGOLD, "speaker": "Druid Marigold"}),
		_spot("hob", "Farmer Hob's Swap Shed", "hob", Vector3(-1.6, 0, 0.2), 1.9, "Talk", "vendor_npc", {"npc": "hob", "npc_name": NPC_HOB, "speaker": "Farmer Hob"}),
		_spot("wren", "Wren Muckfoot, Animal Handler", "wren", Vector3(0.9, 0, 0), 1.7, "Talk", "quest_npc", {"npc": "wren", "npc_name": NPC_WREN, "speaker": "Wren Muckfoot"}),
		_spot("heal", "The Harvest Meal", "heal", Vector3(0, 0, 1.6), 1.9, "Sit down to a fresh harvest meal (full heal)", "heal"),
		_spot("exit", "The Path of the Refusemancer", "exit", Vector3(0, 0, -0.8), 1.8, "Walk back down to town (full heal)", "exit"),
		_spot("mini_dungeon", "The Landfill Depths", "mini_dungeon", Vector3(0, 0, 1.6), 1.8, "Climb into the landfill: three levels", "mini_dungeon"),
		_spot("main_dungeon", "Closed for Composting", "main_dungeon", Vector3(0, 0, 1.4), 2.0, "Try the door", "main_dungeon"),
		_spot("puzzle", "The Seed Shrine", "puzzle", Vector3(0, 0, 1.4), 1.9, "Plant the seeds (puzzle)", "puzzle"),
		_spot("quiz", "Elder Fennel, Keeper of the Heap", "quiz", Vector3(0.9, 0, 0), 1.8, "Talk", "quiz", {"npc": "quiz", "speaker": "Elder Fennel"}),
		_spot("minigame", "Blue-Ribbon Bev Pettigrew, Fair Judge", "minigame", Vector3(0, 0, 1.2), 1.9, "Talk", "minigame", {"npc": "minigame", "speaker": "Blue-Ribbon Bev"}),
		_spot("compost_bin", "The Compost Bin", "compost_bin", Vector3(0, 0, 1.6), 1.8, "Compost some junk", "zone"),
		_spot("shrine", "The Druid Shrine", "shrine", Vector3(0, 0, 1.8), 1.9, "Kneel at the shrine", "zone"),
		_spot("trough", "The Feeding Trough", "trough", Vector3(0, 0, 1.4), 1.8, "Feed the animals", "zone"),
		_spot("stable_1", "Boris the Giant Boar (Stable)", "stable_1", Vector3(0, 0, 1.8), 1.9, "Mount the boar", "zone", {"stable": "boar"}),
		_spot("stable_2", "Gideon the Giant Goat (Stable)", "stable_2", Vector3(0, 0, 1.8), 1.9, "Mount the goat", "zone", {"stable": "goat"}),
	]
	def.poi_kinds = {
		"marigold": MapPoi.Kind.QUEST_GIVER, "hob": MapPoi.Kind.VENDOR, "wren": MapPoi.Kind.QUEST_GIVER,
		"heal": MapPoi.Kind.HEAL, "exit": MapPoi.Kind.EXIT, "mini_dungeon": MapPoi.Kind.MINI_DUNGEON,
		"main_dungeon": MapPoi.Kind.DUNGEON, "puzzle": MapPoi.Kind.PUZZLE, "quiz": MapPoi.Kind.QUIZ,
		"minigame": MapPoi.Kind.MINIGAME, "compost_bin": MapPoi.Kind.INTERACTABLE,
		"shrine": MapPoi.Kind.INTERACTABLE, "trough": MapPoi.Kind.INTERACTABLE,
		"stable_1": MapPoi.Kind.STABLE, "stable_2": MapPoi.Kind.STABLE,
	}
	# Things that grow (vine bridges, beanstalk ladders), crop plots, escaped animals, pickups.
	for growth: HeapGrowth.Growth in HeapGrowth.all():
		def.spots.append(_spot("grow_" + growth.id, growth.title, growth.anchor, Vector3(0, 0, 1.4), 1.9, "Grow it", "zone", {"grow": growth.id}))
		def.poi_kinds["grow_" + growth.id] = MapPoi.Kind.GROWTH
		if growth.kind == "ladder":
			def.spots.append(_spot("down_" + growth.id, "Beanstalk (climb down)", growth.id + "_top", Vector3(0, 0, 0.0), 1.5, "Climb down the beanstalk", "zone", {"climb_down": growth.id}))
	for plot: int in range(1, HeapGrowth.CROP_PLOTS + 1):
		def.spots.append(_spot("crop_%d" % plot, "Crop Plot %d" % plot, "crop_%d" % plot, Vector3(0, 0, 1.2), 1.5, "Plant a crop", "zone", {"crop": plot}))
	for animal: int in range(1, HeapGrowth.ESCAPED_ANIMALS + 1):
		def.spots.append(_spot("animal_%d" % animal, "An Escaped Animal", "animal_%d" % animal, Vector3(0, 0, 1.3), 1.6, "Shoo it back to the pen", "zone", {"animal": animal}))
	for pickup_id: String in PICKUPS.keys():
		def.spots.append(_spot("pickup_" + pickup_id, str(PICKUPS[pickup_id]), "pickup_" + pickup_id, Vector3.ZERO, 1.4, "Pick up the %s" % str(PICKUPS[pickup_id]), "zone", {"pickup": pickup_id}))
	return def


static func _spot(id: String, title: String, anchor: String, offset: Vector3, radius: float, prompt: String, kind: String, extra: Dictionary = {}) -> Dictionary:
	var entry: Dictionary = {"id": id, "title": title, "anchor": anchor, "offset": offset, "radius": radius, "prompt": prompt, "kind": kind}
	entry.merge(extra)
	return entry


static func _mini_def() -> ZoneDef.MiniDef:
	var mini: ZoneDef.MiniDef = ZoneDef.MiniDef.new()
	mini.dungeon_name = "The Landfill Depths: Three Levels"
	mini.start_title = "Top of the Pile"
	mini.start_blurb = "A rusted hatch in the heap, a ladder going down, and a sign that says 'Please do not dig deeper than the raccoons.' The raccoons are very deep."
	mini.reward_card_id = "heap_mother"
	mini.battles = [
		_battle("Level 1: The Top Layer", "Fresh garbage, still warm. It has strong feelings about being thrown away.", "Bin Bag Brute", 12, "Balanced", false,
			{"land:C": 15, "scrap_goat": 4, "tin_can_raccoon": 3, "sprout_surge": 2, "vine_snare": 1}),
		_battle("Level 2: The Compost Layer", "Warm, damp, and absolutely thriving. Something down here is composting very quickly.", "Compost Colossus", 14, "Defensive", false,
			{"land:C": 15, "compost_golem": 3, "dung_beetle": 3, "harvest_moon": 2, "fertilizer_burst": 2}),
		_battle("Level 3: The Forgotten Layer", "Things nobody has thrown away since before the kingdom had a name. They are old. They are cross.", "Landfill Leviathan", 18, "Aggressive", true,
			{"land:C": 16, "landfill_hog": 3, "moss_titan": 1, "dung_beetle": 3, "vine_snare": 3, "scrap_goat": 2}),
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
