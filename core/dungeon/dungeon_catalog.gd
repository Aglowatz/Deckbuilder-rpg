class_name DungeonCatalog
extends RefCounted
## The designer's dungeon list as game data: `data/source/dungeon_list.csv.csv` is imported by `tools/import_dungeons` into `data/dungeons/dungeons.json`
## (IDs, names, story, boss, buffs, rewards, quest hooks, map and battleboard IDs and every node with its type, links and CSV position).
## `data/dungeons/map_layout.json` holds the FITTED node coordinates (normalized 0..1 on the map image, see docs/art/art_pipeline.md "Dungeon maps"); a node
## with no entry there uses the CSV percentage. `data/dungeons/dungeon_content.json` is the hand-written node content (foes, events, loot, challenges, text).
## `DungeonBuilder` turns a `Blueprint` into the playable `DungeonMap` and `MainDungeonDef`.

const PATH: String = "res://data/dungeons/dungeons.json"
const LAYOUT_PATH: String = "res://data/dungeons/map_layout.json"
const CONTENT_PATH: String = "res://data/dungeons/dungeon_content.json"
const TUTORIAL_ID: String = "D-TUT"
const TYPE_MAIN: String = "Main Dungeon"
const TYPE_FINAL: String = "Final Dungeon"
const TYPE_SIDE: String = "Side Dungeon"
const TYPE_TUTORIAL: String = "Tutorial"


class BlueprintNode:
	extends RefCounted
	## The number in the CSV (1-based); the map node's id is number - 1.
	var number: int = 0
	var node_name: String = ""
	## start, battle, elite, boss, treasure, event, challenge, heal, rescue.
	var type: String = "battle"
	var note: String = ""
	var csv_position: Vector2 = Vector2.ZERO
	var position: Vector2 = Vector2.ZERO
	var next: Array[int] = []
	var side: bool = false
	## For a dead end of D-PC's side branches: the main-path node (number) the party returns to; 0 = none.
	var return_to: int = 0


class Blueprint:
	extends RefCounted
	var id: String = ""
	var dungeon_name: String = ""
	var type: String = ""
	var zone_id: String = ""
	var zone_text: String = ""
	var theme: String = ""
	var story: String = ""
	var boss: String = ""
	var buffs: String = ""
	var reward_first: String = ""
	var reward_repeat: String = ""
	var hook: String = ""
	var map_id: String = ""
	var battleboard_id: String = ""
	var nodes: Array[BlueprintNode] = []

	func node(number: int) -> BlueprintNode:
		for candidate: BlueprintNode in nodes:
			if candidate.number == number:
				return candidate
		return null

	func is_side() -> bool:
		return type == TYPE_SIDE

	## The unique card of the first-victory reward text ("... (B-30)"), "" when none.
	func reward_card_id() -> String:
		var regex: RegEx = RegEx.new()
		regex.compile(r"\(([A-Z0-9]+-\d+)(?:,[^)]*)?\)")
		var found: RegExMatch = regex.search(reward_first)
		return found.get_string(1) if found != null else ""

	## The pack id of the repeat-clear reward text ("Small gold and a Beefcake Path Pack" -> path_beefcake); "" when it names none.
	func repeat_pack_id() -> String:
		var lower: String = reward_repeat.to_lower()
		for path_name: String in ["beefcake", "gourmand", "necrocrat", "refusemancer"]:
			if lower.contains(path_name):
				return "path_%s" % path_name
		if lower.contains("prismatic"):
			return "prismatic"
		if lower.contains("general"):
			return "general_1"
		return ""

	## Short boss label: the part of the Boss column before the first bracket ("Chancellor Clench, Iron Regent").
	func boss_name() -> String:
		var cut: int = boss.find(" (")
		return (boss.substr(0, cut) if cut > 0 else boss).strip_edges()


static var _blueprints: Array[Blueprint] = []
static var _layout: Dictionary = {}
static var _content: Dictionary = {}
static var _text: Dictionary = {}
static var _loaded: bool = false


static func reset() -> void:
	_loaded = false
	_blueprints = []
	_layout = {}
	_content = {}
	_text = {}


static func _load() -> void:
	if _loaded:
		return
	_loaded = true
	_blueprints = []
	_layout = _read(LAYOUT_PATH) as Dictionary if _read(LAYOUT_PATH) is Dictionary else {}
	_content = _read(CONTENT_PATH) as Dictionary if _read(CONTENT_PATH) is Dictionary else {}
	var rows: Variant = _read(PATH)
	if rows is Array:
		for row: Variant in rows as Array:
			if row is Dictionary:
				_blueprints.append(_parse(row as Dictionary))
	var text: Variant = _content.get("text", {})
	_text = (text as Dictionary).duplicate() if text is Dictionary else {}


static func _read(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		return null
	return JSON.parse_string(FileAccess.get_file_as_string(path))


static func _parse(row: Dictionary) -> Blueprint:
	var blueprint: Blueprint = Blueprint.new()
	blueprint.id = str(row.get("id", ""))
	blueprint.dungeon_name = str(row.get("name", ""))
	blueprint.type = str(row.get("type", ""))
	blueprint.zone_id = str(row.get("zone", ""))
	blueprint.zone_text = str(row.get("zone_text", ""))
	blueprint.theme = str(row.get("theme", ""))
	blueprint.story = str(row.get("story", ""))
	blueprint.boss = str(row.get("boss", ""))
	blueprint.buffs = str(row.get("buffs", ""))
	blueprint.reward_first = str(row.get("reward_first", ""))
	blueprint.reward_repeat = str(row.get("reward_repeat", ""))
	blueprint.hook = str(row.get("hook", ""))
	blueprint.map_id = str(row.get("map_id", ""))
	blueprint.battleboard_id = str(row.get("battleboard_id", ""))
	var fitted: Dictionary = _layout.get(blueprint.id, {}) as Dictionary
	for entry: Variant in row.get("nodes", []) as Array:
		var data: Dictionary = entry as Dictionary
		var node: BlueprintNode = BlueprintNode.new()
		node.number = int(data.get("n", 0))
		node.node_name = str(data.get("name", ""))
		node.type = str(data.get("type", "battle"))
		node.note = str(data.get("note", ""))
		node.csv_position = Vector2(float(data.get("x", 0)) / 100.0, float(data.get("y", 0)) / 100.0)
		node.position = node.csv_position
		var placed: Variant = fitted.get(str(node.number))
		if placed is Array and (placed as Array).size() >= 2:
			node.position = Vector2(float((placed as Array)[0]), float((placed as Array)[1]))
		for target: Variant in data.get("next", []) as Array:
			node.next.append(int(target))
		node.side = bool(data.get("side", false))
		node.return_to = int(data.get("return_to", 0))
		blueprint.nodes.append(node)
	return blueprint


static func all() -> Array[Blueprint]:
	_load()
	return _blueprints


static func ids() -> Array[String]:
	var result: Array[String] = []
	for blueprint: Blueprint in all():
		result.append(blueprint.id)
	return result


static func find(dungeon_id: String) -> Blueprint:
	for blueprint: Blueprint in all():
		if blueprint.id == dungeon_id:
			return blueprint
	return null


## The zone's main (or final) dungeon blueprint: "beefcake" -> D-HOG, "final" -> D-PC; null for a zone with none.
static func main_for_zone(zone_id: String) -> Blueprint:
	for blueprint: Blueprint in all():
		if blueprint.zone_id == zone_id and (blueprint.type == TYPE_MAIN or blueprint.type == TYPE_FINAL):
			return blueprint
	return null


## The zone's side dungeon blueprint: "beefcake" -> S-BEEF, "final" -> S-CAP, "town" -> S-TOWN.
static func side_for_zone(zone_id: String) -> Blueprint:
	for blueprint: Blueprint in all():
		if blueprint.zone_id == zone_id and blueprint.type == TYPE_SIDE:
			return blueprint
	return null


## The saved coordinates of `dungeon_id`'s nodes (number -> [x, y]) as the file has them (empty when the dungeon has none yet).
static func fitted_layout(dungeon_id: String) -> Dictionary:
	_load()
	return (_layout.get(dungeon_id, {}) as Dictionary).duplicate()


## The hand-written content block of one dungeon (`dungeon_content.json`): {} when it has none.
static func content_for(dungeon_id: String) -> Dictionary:
	_load()
	var block: Variant = (_content.get("dungeons", {}) as Dictionary).get(dungeon_id, {})
	return block as Dictionary if block is Dictionary else {}


## Text lines the builder and the content file add under story keys ("dg.D-HOG.5.title"); `ZoneStoryText.get_lines` asks here first.
static func has_text(key: String) -> bool:
	_load()
	return _text.has(key)


static func text_lines(key: String) -> Array[String]:
	_load()
	var result: Array[String] = []
	var raw: Variant = _text.get(key)
	if raw is Array:
		for entry: Variant in raw as Array:
			result.append(str(entry))
	elif raw != null:
		result.append(str(raw))
	return result


static func set_text(key: String, lines: Array) -> void:
	_load()
	_text[key] = lines


## The quest hook of the dungeon that `npc_id` (an NPC ID of the NPC list) speaks, as [{dungeon, text}]; used for the hint dialogue of the main dungeons.
static func hooks_for_npc(npc_id: String) -> Array[Dictionary]:
	_load()
	var result: Array[Dictionary] = []
	var hooks: Dictionary = _content.get("hook_speakers", {}) as Dictionary
	for dungeon_id: Variant in hooks.keys():
		if str(hooks[dungeon_id]) == npc_id:
			var blueprint: Blueprint = find(str(dungeon_id))
			if blueprint != null:
				result.append({"dungeon": blueprint.id, "text": blueprint.hook})
	return result


## The flag a side dungeon's quest sets when it is done: the dungeon's entrance only opens once it is set.
static func side_unlock_flag(dungeon_id: String) -> StringName:
	return StringName("side_unlocked_%s" % dungeon_id.to_lower().replace("-", "_"))


## How the paths between nodes are drawn over this dungeon's painted map: "full", "subtle" (default), "highlight" or "none" (`map_layout.json`, key "paths").
static func path_style(dungeon_id: String) -> String:
	_load()
	var styles: Variant = _layout.get("paths", {})
	return str((styles as Dictionary).get(dungeon_id, "subtle")) if styles is Dictionary else "subtle"
