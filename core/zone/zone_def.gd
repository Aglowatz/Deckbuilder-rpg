class_name ZoneDef
extends RefCounted
## Everything that makes one zone THIS zone, as data: ids, flags, hub NPCs and interact spots,
## vendor stock, the mini dungeon, chest rewards, which puzzle/minigame it uses. The shared zone
## framework (`ZoneScene`, `ZoneRun`, `Session` zone API, quiz/minigame/puzzle rules) reads a ZoneDef
## and never hardcodes a zone. A new zone = a ZoneDef + a map (`ZoneMap`) + a story file.
## Dialogue/sign text is NOT here: it lives in the zone's story file (`story_path`).

## One battle of a zone's mini dungeon (3 in a row, no healing in between).
class MiniBattle:
	extends RefCounted
	var title: String = ""
	var blurb: String = ""
	var enemy: String = ""
	var hp: int = 12
	var ai_name: String = "Balanced"
	var elite: bool = false
	var recipe: Dictionary = {}


class MiniDef:
	extends RefCounted
	var dungeon_id: String = ""
	var dungeon_name: String = ""
	var start_title: String = "Landing"
	var start_blurb: String = ""
	var reward_card_id: String = ""
	var battles: Array[MiniBattle] = []

	func recipe_for(enemy_name: String) -> Dictionary:
		for battle: MiniBattle in battles:
			if battle.enemy == enemy_name:
				return battle.recipe
		return {}


var id: String = ""
var display_name: String = ""
var full_name: String = ""
var music: StringName = &"map"
var scene_path: String = ""
var story_path: String = ""
## Gold taken when the player is carried back to the hub at 0 HP, and what the fee is called.
var fee: int = 15
var fee_label: String = "Paperwork fee"
## Who speaks the wake-up dialogue (story key `fx.wake`).
var wake_speaker: String = ""
## Flags / counters this zone sets (quest objectives read them as Conditions).
var flag_quiz_done: StringName = &""
var flag_quiz_passed: StringName = &""
var flag_puzzle_solved: StringName = &""
var flag_mini_cleared: StringName = &""
var flag_minigame_first: StringName = &""
var flag_met_prefix: String = ""
var counter_chests: String = ""
## Counter bumped for every roaming enemy beaten (quests read it).
var counter_enemies: String = "zone_enemies_defeated"
## Prefix of the secret ids of this zone's hidden chests (`<prefix><chest id>`).
var secret_prefix: String = ""
## Hidden chest rewards: id -> {gold, item, card, equipment}. Keep docs/design/secrets.md in sync.
var chest_rewards: Dictionary = {}
var vendor_ids: Array[String] = []
var vendor_name: String = "Vendor"
var vendor_title: String = "Vendor"
var mini: MiniDef
## Which puzzle and minigame screens this zone uses ("tube"/"wheels", "match"/"reps").
var puzzle_kind: String = ""
var puzzle_equipment_id: String = ""
var minigame_kind: String = ""
## Hub/world NPCs: [{id, model, anchor, yaw, tint}] - characters standing at map anchors.
var npcs: Array[Dictionary] = []
## Interact spots: [{id, title, anchor, offset, radius, prompt, kind, npc?, npc_name?, speaker?}].
## `kind` picks a generic handler in `ZoneScene` ("quest_npc", "vendor_npc", "heal", "exit",
## "mini_dungeon", "main_dungeon", "puzzle", "quiz", "minigame") - anything else goes to the
## zone scene's own `_interact_zone` (interactables, travel points...).
var spots: Array[Dictionary] = []
## Map points of interest for the minimap: spot id -> `MapPoi.Kind` (spots not listed are not shown).
var poi_kinds: Dictionary = {}
var quest_npc_names: Array[String] = []

## ---- Part D: the ruler and the zone's completed state ---------------------------------------
## Who oppresses the zone (statue/banner text) and the colors of their rule: the banners/statue tint and
## the gloom the zone's lighting is pulled toward until it is freed (`ZoneCompletionLook`).
var ruler_name: String = ""
var ruler_tint: Color = Color(0.55, 0.1, 0.1)
var gloom_tint: Color = Color(0.5, 0.5, 0.55)
## The hub anchor the ruler's props and the freed NPCs are placed around, and their offsets from it.
var hub_anchor: String = "hub"
var statue_offset: Vector3 = Vector3(-9.0, 0.0, 3.0)
var banner_offsets: Array[Vector3] = [Vector3(-6.0, 0.0, -3.0), Vector3(7.0, 0.0, -3.0)]
## NPCs who appear only once the zone is freed: [{id, model, offset, yaw, tint, scale, name, speaker}]. Their
## dialogue is the story key `freed_npc.<id>`.
var freed_npcs: Array[Dictionary] = []


func flag_met(npc_id: String) -> StringName:
	return StringName("%s_met_%s" % [flag_met_prefix, npc_id])


func spot_def(spot_id: String) -> Dictionary:
	for entry: Dictionary in spots:
		if str(entry["id"]) == spot_id:
			return entry
	return {}
