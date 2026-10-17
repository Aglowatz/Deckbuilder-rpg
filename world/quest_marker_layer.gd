class_name QuestMarkerLayer
extends Node3D
## Overnight Oct 16: the quest markers of a walkable scene (town, zones, the Capital). Reads `QuestMarkers` (pure rules) and shows:
## - a small golden "!" / "?" icon over every quest giver / turn-in NPC of this area,
## - ONE objective marker for the tracked quest: a slow-bobbing golden chevron above its target, with a soft ring on the ground,
## - an edge-of-screen pointer toward that target while it is off-screen (`QuestEdgePointer`, on the scene's HUD layer).
## Markers float above heads and stay small, so they never cover a character. Refreshes on `EventBus.quest_changed` and every second.

const REFRESH: float = 1.0
## Metres above the spot's marker point (a head, a door top) the icons float.
const LIFT: float = 0.55
const GOLD: Color = Color("ffd25a")

var area: String = ""
var camera: Camera3D
## spot id -> {"pos": Vector3 ground point, "top": float height of the head / object above it}; {} when the spot is not in this scene.
var resolve: Callable
var pointer: QuestEdgePointer
var _marks: Dictionary = {}
var _mark_nodes: Dictionary = {}
var _objective: Node3D
var _objective_ring: MeshInstance3D
var _objective_key: String = ""
var _timer: float = 0.0
var _time: float = 0.0


## Builds the layer under `parent`; `hud_layer` (a Control on the HUD's canvas) carries the edge pointer.
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
	return layer


func _ready() -> void:
	set_meta(StyleToon.META_NO_TOON, true)
	EventBus.quest_changed.connect(refresh)
	refresh.call_deferred()


func _process(delta: float) -> void:
	_time += delta
	_timer -= delta
	if _timer <= 0.0:
		_timer = REFRESH
		refresh()
	var bob: float = sin(_time * 2.4) * 0.07
	for node: Variant in _mark_nodes.values():
		var sprite: Sprite3D = node as Sprite3D
		sprite.position.y = float(sprite.get_meta(&"base_y")) + bob
	if _objective != null and _objective.visible:
		_objective.position.y = float(_objective.get_meta(&"base_y")) + sin(_time * 2.0) * 0.1
		_objective.rotation.y += delta * 1.4
		if _objective_ring != null:
			var pulse: float = 0.5 + 0.5 * sin(_time * 2.6)
			_objective_ring.scale = Vector3.ONE * (0.85 + 0.25 * pulse)
			(_objective_ring.material_override as StandardMaterial3D).albedo_color.a = 0.25 + 0.3 * (1.0 - pulse)


func refresh() -> void:
	if not is_inside_tree() or Session.profile == null:
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
	var target: Dictionary = QuestMarkers.objective_target(area, Session.quest_log, state)
	var where_target: Dictionary = {} if target.is_empty() else resolve.call(str(target["spot"])) as Dictionary
	if where_target.is_empty() or _marks.has(str(target.get("spot", ""))):
		_set_objective({}, "")
		if pointer != null:
			pointer.target_valid = not where_target.is_empty()
			if not where_target.is_empty():
				pointer.target = where_target["pos"] as Vector3 + Vector3(0, float(where_target.get("top", 2.0)), 0)
		return
	_set_objective(where_target, "%s|%s" % [target["quest"], target["spot"]])
	Hitch.stop("quest_markers")
	if pointer != null:
		pointer.target_valid = true
		pointer.target = where_target["pos"] as Vector3 + Vector3(0, float(where_target.get("top", 2.0)), 0)


## The world position of the current objective marker (Vector3.INF with none) - tests and the playthrough bot read it.
func objective_position() -> Vector3:
	return _objective.global_position if _objective != null and _objective.visible else Vector3.INF


func marks() -> Dictionary:
	return _marks


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
		_build_objective()
	var base: Vector3 = where["pos"] as Vector3 + Vector3(0, float(where.get("top", 2.0)) + LIFT + 0.25, 0)
	_objective.position = base
	_objective.set_meta(&"base_y", base.y)
	_objective.visible = true
	_objective_ring.position = (where["pos"] as Vector3) + Vector3(0, 0.06, 0)
	_objective_ring.visible = true
	_objective_key = key


func _build_objective() -> void:
	_objective = Node3D.new()
	_objective.name = "ObjectiveMarker"
	add_child(_objective)
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
	_objective.add_child(chevron)
	_objective_ring = MeshInstance3D.new()
	_objective_ring.name = "ObjectiveRing"
	var ring: TorusMesh = TorusMesh.new()
	ring.inner_radius = 0.9
	ring.outer_radius = 1.04
	ring.rings = 24
	ring.ring_segments = 4
	_objective_ring.mesh = ring
	var ring_material: StandardMaterial3D = StandardMaterial3D.new()
	ring_material.albedo_color = Color(GOLD, 0.45)
	ring_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_objective_ring.material_override = ring_material
	_objective_ring.scale = Vector3(1, 0.2, 1)
	_objective_ring.set_meta(StyleToon.META_NO_TOON, true)
	_objective_ring.set_meta(&"no_occlusion_fade", true)
	add_child(_objective_ring)


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
## none there) and the objective point (drawn even under the fog of war). Called at the end of each scene's `_collect_pois`.
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
	if _objective != null and _objective.visible:
		var objective: MapPoi = MapPoi.make(MapPoi.Kind.INTERACTABLE, _objective_ring.position, "Quest objective")
		objective.objective = true
		pois.append(objective)
