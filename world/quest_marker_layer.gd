class_name QuestMarkerLayer
extends Node3D
## Overnight Oct 16: the quest markers of a walkable scene (town, zones, the Capital). Reads `QuestMarkers` (pure rules) and shows:
## - a small golden "!" / "?" icon over every quest giver / turn-in NPC of this area,
## - a goal marker for each part of the tracked quest's step: a slow-bobbing golden chevron above its target, with a soft ring on the ground,
## - an edge-of-screen pointer toward the nearest of them while it is off-screen (`QuestEdgePointer`, on the scene's HUD layer).
## Markers float above heads and stay small, so they never cover a character. Refreshes on `EventBus.quest_changed` and every second.
## Overnight Oct 30-31, Part 2 (goal pointer everywhere): two kinds of goals (`QuestMarkers.goal_targets`): the tracked quest's step and the
## other kind's (main line / side quest), gold for a main line, blue for a side quest, each with chevrons, ground rings, an edge arrow and map
## dots; a turn-in NPC keeps its "?" and gets the arrow and the dot only. Settings > Display > Goal pointer hides all of it (the marks stay).
## Fable pass Nov 10, Part 1.1: every part of a step is marked (the salt AND the truffle AND Old Meatloaf), a spot may resolve to MANY places
## (every roaming enemy, every stash still shut) and the map dots cover the current step of EVERY active quest (`QuestMarkers.all_targets`).
## The scene's resolver answers {"pos", "top", "title"} for one place, or adds "many": [{"pos", "top", "title"}...] for a group (and "live": true
## when the places move, so the chevrons follow them every frame).

const REFRESH: float = 1.0
## Metres above the spot's marker point (a head, a door top) the icons float.
const LIFT: float = 0.55
const GOLD: Color = Color("ffd25a")
## A side quest's goal (main lines are GOLD).
const SIDE_BLUE: Color = Color("8fd3ff")
## At most this many chevrons stand in the world at once (the map still shows every goal).
const MAX_CHEVRONS: int = 10

var area: String = ""
var camera: Camera3D
## spot id -> {"pos": Vector3 ground point, "top": float height of the head / object above it}; {} when the spot is not in this scene.
var resolve: Callable
var pointer: QuestEdgePointer
## The second goal's arrow (the other kind's quest).
var side_pointer: QuestEdgePointer
## Fix pass Nov 7 (item 7): the white arrow toward the map's "Where to?" pick (`Session.where_to_target`).
var where_pointer: QuestEdgePointer
const WHERE_WHITE: Color = Color("f4f0e6")
## The pick is reached (and the arrow cleared) within this many metres.
const WHERE_ARRIVED: float = 3.0
var _marks: Dictionary = {}
var _mark_nodes: Dictionary = {}
## The chevron holders and rings built so far ([Node3D, MeshInstance3D] each); the first is the tracked quest's first goal.
var _chevrons: Array[Array] = []
## The places drawn with a chevron right now: [{"pos", "top", "main", "spot", "live"}].
var _places: Array[Dictionary] = []
var _objective_key: String = ""
var _fixed: Dictionary = {}
## Every goal on this map (the map, the minimap and the tests read them): [{"pos": ground Vector3, "main": bool, "label": String, "tracked": bool, "quest": id}].
var _goals: Array[Dictionary] = []
var _goal_on: bool = true
## Overnight Oct 30-31, Part 8: the first goal last drawn ("" none), so a NEW goal (a step done, a new quest tracked) is heard once.
var _last_goal_key: String = ""
var _timer: float = 0.0
var _time: float = 0.0
## The two arrows' targets as spot groups: the tracked kind's places and the other kind's, so the arrow follows the nearest each frame.
var _arrow_places: Array[Array] = [[], []]
var _hero: Node3D


## Builds the layer under `parent`; `hud_layer` (a Control on the HUD's canvas) carries the edge pointers.
static func install(parent: Node, area_id: String, cam: Camera3D, resolver: Callable, hud_layer: Control) -> QuestMarkerLayer:
	var layer: QuestMarkerLayer = QuestMarkerLayer.new()
	layer.name = "QuestMarkers"
	layer.area = area_id
	layer.camera = cam
	layer.resolve = resolver
	parent.add_child(layer)
	if hud_layer != null:
		layer.pointer = QuestEdgePointer.new()
		layer.pointer.camera = cam
		hud_layer.add_child(layer.pointer)
		layer.side_pointer = QuestEdgePointer.new()
		layer.side_pointer.camera = cam
		layer.side_pointer.color = SIDE_BLUE
		hud_layer.add_child(layer.side_pointer)
		layer.side_pointer.name = "SideGoalPointer"
		layer.where_pointer = QuestEdgePointer.new()
		layer.where_pointer.camera = cam
		layer.where_pointer.color = WHERE_WHITE
		layer.where_pointer.show_label = true
		hud_layer.add_child(layer.where_pointer)
		layer.where_pointer.name = "WhereToPointer"
	return layer


func _exit_tree() -> void:
	OcclusionFader.focus_points = [] as Array[Vector3]


func _ready() -> void:
	set_meta(StyleToon.META_NO_TOON, true)
	EventBus.quest_changed.connect(refresh)
	refresh.call_deferred()


func _process(delta: float) -> void:
	_time += delta
	_update_where_to()
	# Fix pass Nov 7 (item 2): a house in front of the tracked goal's door dissolves when the hero is near it (`OcclusionFader.focus_points`).
	var focus: Array[Vector3] = []
	for pair: Array in _chevrons:
		var node: Node3D = pair[0] as Node3D
		if node != null and node.visible:
			focus.append(Vector3(node.global_position.x, 0.0, node.global_position.z))
	OcclusionFader.focus_points = focus
	_timer -= delta
	if _timer <= 0.0 or _goal_on != Settings.goal_pointer:
		_timer = REFRESH
		refresh()
	else:
		_follow_live()
	var bob: float = sin(_time * 2.4) * 0.07
	for node: Variant in _mark_nodes.values():
		var sprite: Sprite3D = node as Sprite3D
		sprite.position.y = float(sprite.get_meta(&"base_y")) + bob
	for pair: Array in _chevrons:
		var chevron: Node3D = pair[0] as Node3D
		var ring: MeshInstance3D = pair[1] as MeshInstance3D
		if chevron == null or not chevron.visible:
			continue
		chevron.position.y = float(chevron.get_meta(&"base_y")) + sin(_time * 2.0) * 0.1
		chevron.rotation.y += delta * 1.4
		if ring != null:
			var pulse: float = 0.5 + 0.5 * sin(_time * 2.6)
			ring.scale = Vector3.ONE * (0.85 + 0.25 * pulse)
			(ring.material_override as StandardMaterial3D).albedo_color.a = 0.25 + 0.3 * (1.0 - pulse)


## The hero of the current scene (for "nearest" choices), or null.
func _hero_node() -> Node3D:
	if _hero != null and is_instance_valid(_hero):
		return _hero
	var scene: Node = get_tree().current_scene if is_inside_tree() else null
	_hero = scene.get("player") as Node3D if scene != null else null
	return _hero


## Fix pass Nov 7 (item 7): points the white arrow at the "Where to?" pick of this area; clears the pick once the hero is there.
func _update_where_to() -> void:
	if where_pointer == null:
		return
	var pick: Dictionary = Session.where_to_target
	var valid: bool = not pick.is_empty() and str(pick.get("area", "")) == area
	if valid:
		var target: Vector3 = pick["pos"] as Vector3
		var hero: Node3D = _hero_node()
		if hero != null and Vector2(hero.position.x - target.x, hero.position.z - target.z).length() < WHERE_ARRIVED:
			Session.where_to_target = {}
			valid = false
		else:
			where_pointer.target = target + Vector3(0.0, 1.0, 0.0)
			where_pointer.label = str(pick.get("label", ""))
	where_pointer.target_valid = valid


## Fresh eyes Oct 30: a fixed objective that is not a quest (the forest's cave gate before any quest exists): the chevron, the ring and
## the edge pointer point at `where` ({"pos": Vector3, "top": float}) until it is cleared with {}.
func set_fixed_objective(where: Dictionary) -> void:
	_fixed = where.duplicate()
	refresh()


func refresh() -> void:
	if not is_inside_tree() or Session.profile == null:
		return
	_goal_on = Settings.goal_pointer
	if not _fixed.is_empty():
		var shown: Dictionary = _fixed.duplicate() if _goal_on else {}
		_goals.clear()
		_places.clear()
		if _goal_on:
			shown["main"] = true
			shown["chevron"] = true
			_places.append(shown)
			_goals.append({"pos": _fixed["pos"] as Vector3, "main": true, "label": "", "tracked": true, "quest": ""})
		_draw_chevrons()
		_objective_key = "fixed|objective" if _goal_on else ""
		_arrow_places = [[shown] if _goal_on else [], []]
		_aim_arrows()
		return
	Hitch.start("quest_markers")
	var state: UnlockState = Session.unlock_state()
	_marks = QuestMarkers.giver_marks(area, Session.quest_log, QuestCatalog.all(), state)
	for spot_id: Variant in _mark_nodes.keys():
		if not _marks.has(spot_id) or str((_mark_nodes[spot_id] as Node).get_meta(&"mark")) != str(_marks[spot_id]):
			(_mark_nodes[spot_id] as Node).queue_free()
			_mark_nodes.erase(spot_id)
	for spot_id: Variant in _marks.keys():
		if _mark_nodes.has(spot_id):
			continue
		var where: Dictionary = resolve.call(str(spot_id)) as Dictionary
		if where.is_empty():
			continue
		_mark_nodes[spot_id] = _make_mark(str(_marks[spot_id]), where)
	_goals.clear()
	_places.clear()
	_arrow_places = [[], []]
	var keys: Array[String] = []
	if _goal_on:
		# The world: the tracked quest's step (every part) and the other kind's, chevrons and arrows.
		var targets: Array[Dictionary] = QuestMarkers.goal_targets(area, Session.quest_log, state)
		var first_main: int = -1
		for target: Dictionary in targets:
			var main: bool = bool(target.get("main", true))
			if first_main == -1:
				first_main = 1 if main else 0
			var arrow_slot: int = 0 if (1 if main else 0) == first_main else 1
			for place: Dictionary in _expand(str(target["spot"])):
				place["main"] = main
				# A spot that already wears a "!" / "?" gets no chevron (the arrow and the map dot still lead there).
				place["chevron"] = not _marks.has(str(target["spot"]))
				place["spot"] = str(target["spot"])
				_places.append(place)
				(_arrow_places[arrow_slot] as Array).append(place)
				if keys.is_empty() or arrow_slot == 0:
					keys.append("%s|%s" % [target["quest"], target["spot"]])
		# The map: every active quest's step.
		for target: Dictionary in QuestMarkers.all_targets(area, Session.quest_log, state):
			var label: String = str(target.get("title", ""))
			var part: String = str(target.get("label", ""))
			if part != "":
				label = "%s: %s" % [label, part]
			for place: Dictionary in _expand(str(target["spot"])):
				var title: String = str(place.get("title", ""))
				if part == "" and title != "" and not bool(target.get("via", false)):
					label = "%s: %s" % [str(target.get("title", "")), title]
				_goals.append({"pos": place["pos"] as Vector3, "main": bool(target.get("main", true)), "label": label, "tracked": bool(target.get("tracked", false)), "quest": str(target["quest"])})
	_draw_chevrons()
	_objective_key = keys[0] if not keys.is_empty() else ""
	_aim_arrows()
	var goal_key: String = _objective_key
	if goal_key != _last_goal_key and goal_key != "" and _last_goal_key != "":
		Audio.sfx(&"goal_update")
	_last_goal_key = goal_key
	Hitch.stop("quest_markers")


## A spot id as the places it stands for: the resolver's one place, or each of its "many".
func _expand(spot_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var where: Dictionary = resolve.call(spot_id) as Dictionary
	if where.is_empty():
		return result
	if where.has("many"):
		for entry: Variant in where["many"] as Array:
			var place: Dictionary = (entry as Dictionary).duplicate()
			place["live"] = bool(where.get("live", false))
			place["group"] = spot_id
			result.append(place)
		return result
	var one: Dictionary = where.duplicate()
	one.erase("many")
	result.append(one)
	return result


## Puts a chevron and ring on every place that wants one (nearest to the hero first when there are more than MAX_CHEVRONS).
func _draw_chevrons() -> void:
	var wanted: Array[Dictionary] = []
	for place: Dictionary in _places:
		if bool(place.get("chevron", true)):
			wanted.append(place)
	if wanted.size() > MAX_CHEVRONS:
		var hero: Node3D = _hero_node()
		if hero != null:
			var from: Vector3 = hero.global_position
			wanted.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return (a["pos"] as Vector3).distance_squared_to(from) < (b["pos"] as Vector3).distance_squared_to(from))
		wanted.resize(MAX_CHEVRONS)
	for index: int in range(wanted.size()):
		if index >= _chevrons.size():
			_chevrons.append(_build_goal("ObjectiveMarker" if index == 0 else ("SideObjectiveMarker" if index == 1 else "ObjectiveMarker%d" % index)))
		var pair: Array = _chevrons[index]
		_tint(pair[0] as Node3D, pair[1] as MeshInstance3D, bool(wanted[index].get("main", true)))
		_place_goal(pair[0] as Node3D, pair[1] as MeshInstance3D, wanted[index])
		(pair[0] as Node3D).set_meta(&"place", wanted[index])
	for index: int in range(wanted.size(), _chevrons.size()):
		(_chevrons[index][0] as Node3D).visible = false
		(_chevrons[index][1] as MeshInstance3D).visible = false


## Live places (roaming enemies) move: between refreshes the chevrons and the arrows follow them.
func _follow_live() -> void:
	var any_live: bool = false
	for place: Dictionary in _places:
		if bool(place.get("live", false)):
			any_live = true
			break
	if not any_live:
		return
	var fresh: Dictionary = {}
	for place: Dictionary in _places:
		if not bool(place.get("live", false)):
			continue
		var group: String = str(place.get("group", ""))
		if not fresh.has(group):
			fresh[group] = _expand(group)
		var moved: Array[Dictionary] = fresh[group] as Array[Dictionary]
		var key: Variant = place.get("key")
		for candidate: Dictionary in moved:
			if candidate.get("key") == key:
				place["pos"] = candidate["pos"]
				break
	for pair: Array in _chevrons:
		var chevron: Node3D = pair[0] as Node3D
		if chevron.visible and chevron.has_meta(&"place"):
			var place: Dictionary = chevron.get_meta(&"place") as Dictionary
			if bool(place.get("live", false)):
				_place_goal(chevron, pair[1] as MeshInstance3D, place)
	_aim_arrows()


## Aims the two edge arrows at the nearest place of their kind ({} hides one), in the goal's colour.
func _aim_arrows() -> void:
	var hero: Node3D = _hero_node()
	var from: Vector3 = hero.global_position if hero != null else Vector3.ZERO
	for slot: int in range(2):
		var arrow: QuestEdgePointer = pointer if slot == 0 else side_pointer
		if arrow == null:
			continue
		var best: Dictionary = {}
		var best_distance: float = INF
		for place: Dictionary in _arrow_places[slot] as Array:
			var distance: float = (place["pos"] as Vector3).distance_squared_to(from)
			if distance < best_distance:
				best_distance = distance
				best = place
		_point(arrow, best)


func _point(arrow: QuestEdgePointer, where: Dictionary) -> void:
	if arrow == null:
		return
	arrow.target_valid = not where.is_empty()
	if where.is_empty():
		return
	arrow.target = where["pos"] as Vector3 + Vector3(0, float(where.get("top", 2.0)), 0)
	arrow.color = GOLD if bool(where.get("main", true)) else SIDE_BLUE


## The goals drawn now (the map and the tests read them): [{"pos": Vector3, "main": bool, "label": String, "tracked": bool, "quest": id}].
func goals() -> Array[Dictionary]:
	return _goals


## The world position of the current objective marker (Vector3.INF with none) - tests and the playthrough bot read it.
func objective_position() -> Vector3:
	if _chevrons.is_empty():
		return Vector3.INF
	var first: Node3D = _chevrons[0][0] as Node3D
	return first.global_position if first != null and first.visible else Vector3.INF


## Every chevron standing in the world right now (ground points).
func chevron_positions() -> Array[Vector3]:
	var result: Array[Vector3] = []
	for pair: Array in _chevrons:
		var ring: MeshInstance3D = pair[1] as MeshInstance3D
		if ring != null and ring.visible:
			result.append(ring.position)
	return result


func marks() -> Dictionary:
	return _marks


## True when `spot_id` carries a quest mark (a quest to give or to turn in) or is one of the goals right now (NpcLabels keeps its name up).
func is_marked(spot_id: String) -> bool:
	if _marks.has(spot_id):
		return true
	for place: Dictionary in _places:
		if str(place.get("spot", "")) == spot_id or str(place.get("group", "")) == spot_id:
			return true
	return false


func _make_mark(mark: String, where: Dictionary) -> Sprite3D:
	var sprite: Sprite3D = Sprite3D.new()
	sprite.name = "QuestMark"
	var icon_id: String = "ICON-MAP-TURNIN" if mark == QuestMarkers.MARK_TURN_IN else "ICON-MAP-QUEST"
	sprite.texture = IconArt.texture(icon_id, 128.0)
	sprite.pixel_size = 0.55 / maxf(1.0, float(sprite.texture.get_width())) if sprite.texture != null else 0.004
	sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sprite.no_depth_test = true
	sprite.shaded = false
	sprite.render_priority = 4
	sprite.set_meta(&"mark", mark)
	sprite.set_meta(StyleToon.META_NO_TOON, true)
	var base: Vector3 = where["pos"] as Vector3 + Vector3(0, float(where.get("top", 2.0)) + LIFT, 0)
	sprite.position = base
	sprite.set_meta(&"base_y", base.y)
	add_child(sprite)
	return sprite


func _place_goal(chevron: Node3D, ring: MeshInstance3D, where: Dictionary) -> void:
	var base: Vector3 = where["pos"] as Vector3 + Vector3(0, float(where.get("top", 2.0)) + LIFT + 0.25, 0)
	chevron.position = base
	chevron.set_meta(&"base_y", base.y)
	chevron.visible = true
	ring.position = (where["pos"] as Vector3) + Vector3(0, 0.06, 0)
	ring.visible = true


## Colours a goal's chevron and ring: gold for a main line, blue for a side quest.
func _tint(chevron: Node3D, ring: MeshInstance3D, main: bool) -> void:
	if chevron == null:
		return
	var color: Color = GOLD if main else SIDE_BLUE
	for child: Node in chevron.get_children():
		var mesh: MeshInstance3D = child as MeshInstance3D
		if mesh != null and mesh.material_override is StandardMaterial3D:
			(mesh.material_override as StandardMaterial3D).albedo_color = color
			(mesh.material_override as StandardMaterial3D).emission = color
	if ring != null and ring.material_override is StandardMaterial3D:
		var ring_material: StandardMaterial3D = ring.material_override as StandardMaterial3D
		ring_material.albedo_color = Color(color, ring_material.albedo_color.a)


## A goal's chevron (spinning, bobbing) and its ground ring: [Node3D, MeshInstance3D].
func _build_goal(node_name: String) -> Array:
	var holder: Node3D = Node3D.new()
	holder.name = node_name
	add_child(holder)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = GOLD
	material.emission_enabled = true
	material.emission = GOLD
	material.emission_energy_multiplier = 1.4
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.no_depth_test = true
	material.render_priority = 4
	var chevron: MeshInstance3D = MeshInstance3D.new()
	chevron.name = "Chevron"
	var cone: CylinderMesh = CylinderMesh.new()
	cone.top_radius = 0.32
	cone.bottom_radius = 0.0
	cone.height = 0.55
	cone.radial_segments = 4
	cone.rings = 1
	chevron.mesh = cone
	chevron.material_override = material
	chevron.set_meta(StyleToon.META_NO_TOON, true)
	chevron.set_meta(&"no_occlusion_fade", true)
	holder.add_child(chevron)
	var ring_node: MeshInstance3D = MeshInstance3D.new()
	ring_node.name = node_name + "Ring"
	var ring: TorusMesh = TorusMesh.new()
	ring.inner_radius = 0.9
	ring.outer_radius = 1.04
	ring.rings = 24
	ring.ring_segments = 4
	ring_node.mesh = ring
	var ring_material: StandardMaterial3D = StandardMaterial3D.new()
	ring_material.albedo_color = Color(GOLD, 0.45)
	ring_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ring_node.material_override = ring_material
	ring_node.scale = Vector3(1, 0.2, 1)
	ring_node.set_meta(StyleToon.META_NO_TOON, true)
	ring_node.set_meta(&"no_occlusion_fade", true)
	add_child(ring_node)
	return [holder, ring_node]


## The usual resolver: finds a spot by id in a scene's spot list (town `Spot`s or `ZoneSpot`s: anything with id, position and marker).
const DOOR_MARKER_TOP: float = 1.5


static func resolve_in(spot_list: Array, spot_id: String) -> Dictionary:
	for spot: Variant in spot_list:
		var item: Object = spot as Object
		if item == null or str(item.get("id")) != spot_id:
			continue
		var pos: Vector3 = item.get("position") as Vector3
		var marker: Node3D = item.get("marker") as Node3D
		var top: float = (marker.position.y - pos.y) if marker != null else 2.0
		# Fix pass Nov 7 (item 2, C1b F4): a door's goal marker hangs at the door (it floated up on the roof and hid behind it); a person's
		# stays over their head.
		var person: bool = bool(item.get("is_npc")) if "is_npc" in item else (spot_id in TownScene.NPC_SPOT_IDS or spot_id.begins_with("npc_"))
		if not person:
			top = minf(top, DOOR_MARKER_TOP)
		return {"pos": pos, "top": clampf(top, 1.2, 6.0), "title": str(item.get("title")) if "title" in item else ""}
	return {}


## A group answer for a resolver: `places` are [{"pos", "top", "title", "key"}...]; {} when the group is empty.
static func group(places: Array[Dictionary], live: bool = false) -> Dictionary:
	if places.is_empty():
		return {}
	var first: Dictionary = places[0]
	return {"pos": first["pos"], "top": first.get("top", 1.6), "title": first.get("title", ""), "many": places, "live": live}


## Adds this area's quest marks to a scene's map points: "!" / "?" badges on the giver's point (a new quest-giver point when the map has
## none there) and a dot for each goal (drawn even under the fog of war, gold for a main line, blue for a side quest). Called at the end
## of each scene's `_collect_pois`.
func add_map_pois(pois: Array[MapPoi]) -> void:
	for spot_id: Variant in _marks.keys():
		var where: Dictionary = resolve.call(str(spot_id)) as Dictionary
		if where.is_empty():
			continue
		var pos: Vector3 = where["pos"] as Vector3
		var found: MapPoi = null
		for poi: MapPoi in pois:
			if Vector2(poi.pos.x - pos.x, poi.pos.z - pos.z).length() < 0.8:
				found = poi
				break
		if found == null:
			found = MapPoi.make(MapPoi.Kind.QUEST_GIVER, pos, "")
			pois.append(found)
		found.quest_marker = true
		found.turn_in = str(_marks[spot_id]) == QuestMarkers.MARK_TURN_IN
	for goal: Dictionary in _goals:
		var label: String = str(goal.get("label", ""))
		var objective: MapPoi = MapPoi.make(MapPoi.Kind.INTERACTABLE, goal["pos"] as Vector3, label if label != "" else "Quest objective")
		objective.objective = true
		objective.side_goal = not bool(goal.get("main", true))
		objective.tracked_goal = bool(goal.get("tracked", false))
		pois.append(objective)
