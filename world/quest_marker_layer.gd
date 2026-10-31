class_name QuestMarkerLayer
extends Node3D
## Overnight Oct 16: the quest markers of a walkable scene (town, zones, the Capital). Reads `QuestMarkers` (pure rules) and shows:
## - a small golden "!" / "?" icon over every quest giver / turn-in NPC of this area,
## - ONE objective marker for the tracked quest: a slow-bobbing golden chevron above its target, with a soft ring on the ground,
## - an edge-of-screen pointer toward that target while it is off-screen (`QuestEdgePointer`, on the scene's HUD layer).
## Markers float above heads and stay small, so they never cover a character. Refreshes on `EventBus.quest_changed` and every second.
## Overnight Oct 30-31, Part 2 (goal pointer everywhere): up to TWO goals (`QuestMarkers.goal_targets`): the tracked quest's step and the
## other kind's (main line / side quest), gold for a main line, blue for a side quest, each with its chevron, ground ring, edge arrow and map
## dot; a turn-in NPC keeps its "?" and gets the arrow and the dot only. Settings > Display > Goal pointer hides all of it (the marks stay).

const REFRESH: float = 1.0
## Metres above the spot's marker point (a head, a door top) the icons float.
const LIFT: float = 0.55
const GOLD: Color = Color("ffd25a")
## A side quest's goal (main lines are GOLD).
const SIDE_BLUE: Color = Color("8fd3ff")

var area: String = ""
var camera: Camera3D
## spot id -> {"pos": Vector3 ground point, "top": float height of the head / object above it}; {} when the spot is not in this scene.
var resolve: Callable
var pointer: QuestEdgePointer
## The second goal's arrow (the other kind's quest).
var side_pointer: QuestEdgePointer
var _marks: Dictionary = {}
var _mark_nodes: Dictionary = {}
var _objective: Node3D
var _objective_ring: MeshInstance3D
var _objective_key: String = ""
var _fixed: Dictionary = {}
## The second goal's chevron and ring, and both goals as drawn: [{"pos": ground Vector3, "main": bool, "label": String}].
var _second: Node3D
var _second_ring: MeshInstance3D
var _goals: Array[Dictionary] = []
var _goal_on: bool = true
## Overnight Oct 30-31, Part 8: the first goal last drawn ("" none), so a NEW goal (a step done, a new quest tracked) is heard once.
var _last_goal_key: String = ""
var _timer: float = 0.0
var _time: float = 0.0


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
	return layer


func _ready() -> void:
	set_meta(StyleToon.META_NO_TOON, true)
	EventBus.quest_changed.connect(refresh)
	refresh.call_deferred()


func _process(delta: float) -> void:
	_time += delta
	_timer -= delta
	if _timer <= 0.0 or _goal_on != Settings.goal_pointer:
		_timer = REFRESH
		refresh()
	var bob: float = sin(_time * 2.4) * 0.07
	for node: Variant in _mark_nodes.values():
		var sprite: Sprite3D = node as Sprite3D
		sprite.position.y = float(sprite.get_meta(&"base_y")) + bob
	for pair: Array in [[_objective, _objective_ring], [_second, _second_ring]]:
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
		var shown: Dictionary = _fixed if _goal_on else {}
		_goals.clear()
		if _goal_on:
			_goals.append({"pos": _fixed["pos"] as Vector3, "main": true, "label": ""})
		_set_objective(shown, "fixed|objective")
		_point(pointer, shown)
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
	var places: Array[Dictionary] = []
	var keys: Array[String] = []
	var targets: Array[Dictionary] = []
	if _goal_on:
		targets = QuestMarkers.goal_targets(area, Session.quest_log, state)
	for target: Dictionary in targets:
		var where: Dictionary = resolve.call(str(target["spot"])) as Dictionary
		if where.is_empty():
			continue
		var place: Dictionary = where.duplicate()
		place["main"] = bool(target.get("main", true))
		# A spot that already wears a "!" / "?" gets no chevron (the arrow and the map dot still lead there).
		place["chevron"] = not _marks.has(str(target["spot"]))
		places.append(place)
		keys.append("%s|%s" % [target["quest"], target["spot"]])
		var quest: QuestData = QuestCatalog.find(str(target["quest"]))
		_goals.append({"pos": where["pos"] as Vector3, "main": bool(place["main"]), "label": quest.title if quest != null else ""})
	var first: Dictionary = places[0] if places.size() > 0 else {}
	var second: Dictionary = places[1] if places.size() > 1 else {}
	_set_objective(first if bool(first.get("chevron", false)) else {}, keys[0] if not keys.is_empty() else "")
	if not first.is_empty():
		_tint(_objective, _objective_ring, bool(first["main"]))
	_set_second(second if bool(second.get("chevron", false)) else {})
	_point(pointer, first)
	_point(side_pointer, second)
	var goal_key: String = keys[0] if not keys.is_empty() else ""
	if goal_key != _last_goal_key and goal_key != "" and _last_goal_key != "":
		Audio.sfx(&"goal_update")
	_last_goal_key = goal_key
	Hitch.stop("quest_markers")


## Aims an edge arrow at a goal ({} hides it), in the goal's colour.
func _point(arrow: QuestEdgePointer, where: Dictionary) -> void:
	if arrow == null:
		return
	arrow.target_valid = not where.is_empty()
	if where.is_empty():
		return
	arrow.target = where["pos"] as Vector3 + Vector3(0, float(where.get("top", 2.0)), 0)
	arrow.color = GOLD if bool(where.get("main", true)) else SIDE_BLUE


## The goals drawn now (the map and the tests read them): [{"pos": Vector3, "main": bool, "label": String}].
func goals() -> Array[Dictionary]:
	return _goals


## The world position of the current objective marker (Vector3.INF with none) - tests and the playthrough bot read it.
func objective_position() -> Vector3:
	return _objective.global_position if _objective != null and _objective.visible else Vector3.INF


func marks() -> Dictionary:
	return _marks


## True when `spot_id` carries a quest mark (a quest to give or to turn in) or is the tracked objective right now (NpcLabels keeps its name up).
func is_marked(spot_id: String) -> bool:
	if _marks.has(spot_id):
		return true
	return not _objective_key.is_empty() and _objective_key.ends_with("|%s" % spot_id) and _objective != null and _objective.visible


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


func _set_objective(where: Dictionary, key: String) -> void:
	if where.is_empty():
		if _objective != null:
			_objective.visible = false
			_objective_ring.visible = false
		_objective_key = ""
		return
	if _objective == null:
		var built: Array = _build_goal("ObjectiveMarker")
		_objective = built[0] as Node3D
		_objective_ring = built[1] as MeshInstance3D
	_place_goal(_objective, _objective_ring, where)
	_objective_key = key


func _set_second(where: Dictionary) -> void:
	if where.is_empty():
		if _second != null:
			_second.visible = false
			_second_ring.visible = false
		return
	if _second == null:
		var built: Array = _build_goal("SideObjectiveMarker")
		_second = built[0] as Node3D
		_second_ring = built[1] as MeshInstance3D
	_tint(_second, _second_ring, bool(where.get("main", false)))
	_place_goal(_second, _second_ring, where)


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
static func resolve_in(spot_list: Array, spot_id: String) -> Dictionary:
	for spot: Variant in spot_list:
		var item: Object = spot as Object
		if item == null or str(item.get("id")) != spot_id:
			continue
		var pos: Vector3 = item.get("position") as Vector3
		var marker: Node3D = item.get("marker") as Node3D
		var top: float = (marker.position.y - pos.y) if marker != null else 2.0
		return {"pos": pos, "top": clampf(top, 1.2, 6.0)}
	return {}


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
		pois.append(objective)
