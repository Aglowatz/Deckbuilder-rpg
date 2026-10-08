class_name TownSquare
extends RefCounted
## The visual slice (Brief 12, Part C), now laid out by `TownLayout`: the town's central plaza and its streets (`TownStreets`: paving, the royal-crest
## fountain, signposts, lamps), moss patches, sparse wind-swaying grass with a handful of flowers, clutter round the shop fronts and chimney smoke.
## Nothing is placed on the streets or on the walking lanes between buildings (docs/art/style_guide.md: walkable lanes stay at least 2 m wide).
## Deterministic (seeded), scaled by graphics quality.

const WARM_LIGHT: Color = Color("ffb45a")

var root: Node3D
var town: TownBuilder
var center: Vector3 = Vector3.ZERO
var plaza_radius: float = TownLayout.PLAZA_RADIUS
var meadow_radius: float = 30.0
var lights: Array[OmniLight3D] = []
## The roads, plaza and fountain (`TownStreets`).
var streets: TownStreets
## Where every meadow tuft/flower stands (also readable headless, where MultiMesh buffers are not).
var meadow_points: Array[Vector3] = []
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _lane_points: Array[Vector3] = []
var _quality: int = GraphicsQuality.Level.MEDIUM


static func build(parent: Node3D, builder: TownBuilder, quality: int) -> TownSquare:
	var square: TownSquare = TownSquare.new()
	square.root = Node3D.new()
	square.root.name = "TownSquare"
	parent.add_child(square.root)
	square.town = builder
	square._quality = quality
	square._rng.seed = 4242
	square.center = TownLayout.PLAZA
	square.streets = TownStreets.build(square.root, builder)
	square.lights.append_array(square.streets.lights)
	square._ground()
	square._skirts()
	square._meadow()
	square._landmarks()
	return square


func _anchor(key: String) -> Vector3:
	return town.anchors.get(key, center) as Vector3


func _put(folder: String, model: String, pos: Vector3, yaw: float = 0.0, scale_value: float = 1.0, solid: float = 0.0) -> Node3D:
	var node: Node3D = ModelKit.kit_model(folder, model)
	ModelKit.place(root, node, pos, yaw, scale_value)
	if solid > 0.0:
		town.obstacles.append(Vector3(pos.x, pos.z, solid))
	return node


func _hex_prop(model: String, pos: Vector3, yaw: float = 0.0, scale_value: float = 1.0, solid: float = 0.0) -> Node3D:
	var node: Node3D = ModelKit.prop(model)
	ModelKit.place(root, node, pos, yaw, scale_value)
	if solid > 0.0:
		town.obstacles.append(Vector3(pos.x, pos.z, solid))
	return node


# ---- ground: moss patches round the paved streets ---------------------------------------------------------------------------------------


func _ground() -> void:
	_lane_points = TownLayout.road_points(1.5)
	var grass_dark: ShaderMaterial = GroundDecals.material(GroundDecals.Pattern.MOSS, Color("4f9a58"), Color("3c8466"), Color.BLACK, GroundDecals.Shape.DISC, 1.0, 0.7, 4.0)
	var grass_light: ShaderMaterial = GroundDecals.material(GroundDecals.Pattern.MOSS, Color("86c066"), Color("6fae62"), Color.BLACK, GroundDecals.Shape.DISC, 1.0, 0.7, 5.0)
	var moss: ShaderMaterial = GroundDecals.material(GroundDecals.Pattern.MOSS, Color("5f9a4a"), Color("7aa850"), Color.BLACK, GroundDecals.Shape.DISC, 1.0, 0.6, 6.0)
	for i: int in range(40):
		var angle: float = _rng.randf() * TAU
		var distance: float = _rng.randf_range(plaza_radius + 3.0, meadow_radius + 6.0)
		var pos: Vector3 = center + Vector3(cos(angle) * distance, 0.0, sin(angle) * distance)
		if not town.is_floor_at(pos) or TownLayout.is_paved(pos, 1.5):
			continue
		var mat: ShaderMaterial = [grass_dark, grass_light, moss][i % 3]
		GroundDecals.disc(root, pos, _rng.randf_range(1.6, 3.8), mat, _rng.randf_range(0.6, 1.0), _rng.randf() * 180.0, 0.0004 * float(i % 6))


# ---- the meadow: sparse wind-swaying grass and just a few flowers (MultiMesh) -----------------------------------------------------


func _meadow() -> void:
	var groups: Array[Dictionary] = [
		{"model": "grass_leafs", "count": 1400, "scale": Vector2(1.4, 2.4)},
		{"model": "plant_flatShort", "count": 260, "scale": Vector2(1.3, 2.0)},
		{"model": "plant_bush", "count": 36, "scale": Vector2(1.2, 1.8)},
		{"model": "flower_redA", "count": 8, "scale": Vector2(1.2, 1.7)},
		{"model": "flower_yellowA", "count": 8, "scale": Vector2(1.2, 1.7)},
		{"model": "flower_purpleA", "count": 6, "scale": Vector2(1.2, 1.7)},
	]
	var density: float = GraphicsQuality.foliage_density(_quality)
	for group: Dictionary in groups:
		var mesh: Mesh = ModelKit.kit_mesh(ModelKit.KENNEY_NATURE, str(group["model"]))
		if mesh == null:
			continue
		var is_grass: bool = StyleGrass.replaces(str(group["model"]))
		var target: int = int(float(group["count"]) * density * (2.0 if is_grass else 1.0))
		var transforms: Array[Transform3D] = []
		var tries: int = 0
		while transforms.size() < target and tries < target * 8:
			tries += 1
			var angle: float = _rng.randf() * TAU
			var distance: float = sqrt(_rng.randf()) * meadow_radius
			var pos: Vector3 = center + Vector3(cos(angle) * distance, 0.0, sin(angle) * distance * 0.9)
			if not _meadow_ok(pos, str(group["model"]) in ["grass_leafs", "plant_flatShort"]):
				continue
			var scale_range: Vector2 = group["scale"] as Vector2
			var s: float = _rng.randf_range(scale_range.x, scale_range.y)
			transforms.append(Transform3D(Basis(Vector3.UP, _rng.randf() * TAU).scaled(Vector3.ONE * s), pos))
			meadow_points.append(pos)
		if is_grass:
			var grass: Array[Color] = StyleGrass.colors_for([Color("6fae62")])
			root.add_child(StyleGrass.multimesh_instance(transforms, grass[0], grass[1]))
			continue
		_multimesh(mesh, transforms)


func _meadow_ok(pos: Vector3, lane_ok: bool = false) -> bool:
	if not town.is_floor_at(pos):
		return false
	if TownLayout.is_paved(pos, 0.35):  # the streets and the plaza stay clear of grass
		return false
	if Vector2(pos.x - center.x, pos.z - center.z).length() < TownLayout.FOUNTAIN_RADIUS + 0.2:
		return false
	if not lane_ok:
		for point: Vector3 in _lane_points:
			if Vector2(pos.x - point.x, pos.z - point.z).length() < 0.9:
				return false
	for obstacle: Vector3 in town.obstacles:
		if Vector2(pos.x - obstacle.x, pos.z - obstacle.y).length() < obstacle.z + 0.2:
			return false
	for key: String in ["market", "deck", "well", "gate", "spawn", "npc_market", "npc_well", "npc_gate", "rift_station", "tailor", "npc_tailor"]:
		if Vector2(pos.x - _anchor(key).x, pos.z - _anchor(key).z).length() < 1.2:
			return false
	return true


func _multimesh(mesh: Mesh, transforms: Array[Transform3D]) -> void:
	if transforms.is_empty():
		return
	var multimesh: MultiMesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = mesh
	multimesh.instance_count = transforms.size()
	for i: int in range(transforms.size()):
		multimesh.set_instance_transform(i, transforms[i])
	var instance: MultiMeshInstance3D = MultiMeshInstance3D.new()
	instance.multimesh = multimesh
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var toon: ShaderMaterial = StyleToon.toon_for(mesh.surface_get_material(0), 1.0)
	if toon != null:
		instance.material_override = toon
	instance.set_meta(StyleToon.META_NO_TOON, true)
	root.add_child(instance)


# ---- building skirts: clustered clutter around the shops and along the lanes ------------------------------------------------------


## Crates, barrels, sacks and buckets in clusters of three around every building and the market, never on a lane or inside an obstacle (ScatterTool keep-outs).
func _skirts() -> void:
	var scatter: ScatterTool = ScatterTool.new()
	scatter.seed_value = 4243
	scatter.bounds = Rect2(center.x - 34.0, center.z - 22.0, 68.0, 84.0)
	scatter.is_floor = func(pos: Vector3) -> bool: return town.is_floor_at(pos)
	for point: Vector3 in _lane_points:
		scatter.keep_out_circles.append(Vector3(point.x, point.z, 2.7))
	for obstacle: Vector3 in town.obstacles:
		scatter.keep_out_circles.append(Vector3(obstacle.x, obstacle.y, obstacle.z + 0.3))
	scatter.keep_out_circles.append(Vector3(center.x, center.z, TownLayout.PLAZA_RADIUS + 0.5))
	for key: String in ["npc_market", "npc_well", "npc_gate", "npc_tailor", "rift_station", "spawn"]:
		scatter.keep_out_circles.append(Vector3(_anchor(key).x, _anchor(key).z, 1.5))
	var skirt_points: Array[Vector3] = []
	for key: String in ["market", "deck", "tailor", "alchemist", "item_vendor", "equipment_vendor", "pack_vendor", "gate"]:
		if town.anchors.has(key):
			skirt_points.append(_anchor(key))
	var props: String = "decoration/props"
	var entries: Array[ScatterTool.Entry] = [
		ScatterTool.Entry.make(props, "crate_A_big", 1.0, 0.9, 1.1),
		ScatterTool.Entry.make(props, "crate_B_small", 1.2, 0.9, 1.2),
		ScatterTool.Entry.make(props, "barrel", 1.4, 0.9, 1.1),
		ScatterTool.Entry.make(props, "sack", 1.2, 0.9, 1.2),
		ScatterTool.Entry.make(props, "bucket_water", 0.8, 0.9, 1.1),
		ScatterTool.Entry.make(props, "wheelbarrow", 0.3, 0.9, 1.0),
	]
	var count: int = [8, 14, 33][clampi(_quality, 0, 2)]
	for placement: ScatterTool.Placement in scatter.scatter("town_skirts", entries, count, 3, 0.9, 0.0, skirt_points, 2.8, 0.85):
		var node: Node3D = ModelKit.hex_model(placement.folder, placement.model)
		ModelKit.place(root, node, placement.position, rad_to_deg(placement.yaw), placement.scale * 1.6)
		town.obstacles.append(Vector3(placement.position.x, placement.position.z, 0.35 * placement.scale * 1.6))


# ---- landmarks: chimney smoke and a beacon over the Rift Express ------------------------------------------------------------------


func _landmarks() -> void:
	var smoke: Color = Color(1.0, 0.9, 0.82, 0.5)
	for key: String in ["tailor", "alchemist", "market", "item_vendor"]:
		if not town.anchors.has(key):
			continue
		var roof: Vector3 = _anchor(key) + Vector3(0.45, 2.3, -1.25)
		StyleAmbience.chimney_smoke(root, roof, smoke, [4, 6, 8][clampi(_quality, 0, 2)])

