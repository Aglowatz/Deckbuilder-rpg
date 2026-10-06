class_name TownSquare
extends RefCounted
## The visual slice (Brief 12, Part C), calmed down in Brief 12b: the main town's central square dressed to docs/art/style_guide.md, but airy. A grassy square around the
## well, dirt paths to the vendors, moss patches, a few lamp posts with warm pools, two market stalls, benches and sparse wind-swaying grass with only a handful of flowers.
## Nothing is placed on the walking lanes between buildings (docs/art/style_guide.md: walkable lanes stay at least 2 m wide). Deterministic (seeded), scaled by graphics quality.

const WARM_LIGHT: Color = Color("ffb45a")

var root: Node3D
var town: TownBuilder
var center: Vector3 = Vector3.ZERO
var plaza_radius: float = 4.6
var meadow_radius: float = 17.0
var lights: Array[OmniLight3D] = []
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
	square.center = (builder.anchors["well"] as Vector3) + Vector3(0.0, 0.0, 0.4)
	square._ground()
	square._lanterns()
	square._market()
	square._plaza_furniture()
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


# ---- ground: plaza, paths, patches -------------------------------------------------------------------------------------------------


func _ground() -> void:
	var dirt: ShaderMaterial = GroundDecals.material(GroundDecals.Pattern.DIRT, Color("b79a64"), Color("9c8157"), Color("6e5a3c"), GroundDecals.Shape.RIBBON, 1.0, 0.3, 3.0)
	var edge: ShaderMaterial = GroundDecals.material(GroundDecals.Pattern.MOSS, Color("9a8a4c"), Color("b09a5a"), Color.BLACK, GroundDecals.Shape.RIBBON, 1.0, 0.5, 7.0)
	for key: String in ["market", "deck", "tailor", "spawn", "rift_station", "gate", "item_vendor", "pack_vendor", "equipment_vendor"]:
		var points: Array[Vector3] = _smooth([center, _anchor(key) + Vector3(0.0, 0.0, 0.2)])
		for piece: Array in _land_runs(points):
			var typed: Array[Vector3] = []
			typed.assign(piece)
			GroundDecals.ribbon(root, typed, 1.55, edge, 0.002)
			GroundDecals.ribbon(root, typed, 1.25, dirt, 0.004)
		_lane_points.append_array(points)
	var grass_dark: ShaderMaterial = GroundDecals.material(GroundDecals.Pattern.MOSS, Color("4f9a58"), Color("3c8466"), Color.BLACK, GroundDecals.Shape.DISC, 1.0, 0.7, 4.0)
	var grass_light: ShaderMaterial = GroundDecals.material(GroundDecals.Pattern.MOSS, Color("86c066"), Color("6fae62"), Color.BLACK, GroundDecals.Shape.DISC, 1.0, 0.7, 5.0)
	var moss: ShaderMaterial = GroundDecals.material(GroundDecals.Pattern.MOSS, Color("5f9a4a"), Color("7aa850"), Color.BLACK, GroundDecals.Shape.DISC, 1.0, 0.6, 6.0)
	for i: int in range(44):
		var angle: float = _rng.randf() * TAU
		var distance: float = _rng.randf_range(plaza_radius + 1.5, meadow_radius + 6.0)
		var pos: Vector3 = center + Vector3(cos(angle) * distance, 0.0, sin(angle) * distance)
		if not town.is_floor_at(pos):
			continue
		var mat: ShaderMaterial = [grass_dark, grass_light, moss][i % 3]
		GroundDecals.disc(root, pos, _rng.randf_range(1.6, 3.8), mat, _rng.randf_range(0.6, 1.0), _rng.randf() * 180.0, 0.0004 * float(i % 6))


func _smooth(points: Array) -> Array[Vector3]:
	var result: Array[Vector3] = []
	for i: int in range(points.size() - 1):
		var a: Vector3 = points[i] as Vector3
		var b: Vector3 = points[i + 1] as Vector3
		var steps: int = maxi(2, int(a.distance_to(b) / 0.8))
		for step: int in range(steps):
			var t: float = float(step) / float(steps)
			var wobble: float = sin((t + float(i)) * 3.1) * 0.3 + sin(t * 9.0 + float(i) * 2.0) * 0.08
			var along: Vector3 = (b - a).normalized()
			result.append(a.lerp(b, t) + Vector3(-along.z, 0.0, along.x) * wobble)
	result.append(points[points.size() - 1] as Vector3)
	return result


## Splits a polyline into runs that stay on land (a path never paints the water).
func _land_runs(points: Array[Vector3]) -> Array[Array]:
	var runs: Array[Array] = []
	var current: Array[Vector3] = []
	for point: Vector3 in points:
		if town.is_floor_at(point):
			current.append(point)
		else:
			if current.size() >= 2:
				runs.append(current)
			current = []
	if current.size() >= 2:
		runs.append(current)
	return runs


# ---- lantern posts and light pools -------------------------------------------------------------------------------------------------


func _lanterns() -> void:
	var spots: Array[Vector3] = []
	for i: int in range(5):
		var angle: float = TAU * (float(i) + 0.5) / 5.0
		spots.append(center + Vector3(cos(angle) * (plaza_radius + 0.4), 0.0, sin(angle) * (plaza_radius * 0.9 + 0.4)))
	spots.append(_anchor("market") + Vector3(2.3, 0.0, 1.0))
	spots.append(_anchor("deck") + Vector3(-2.3, 0.0, 1.0))
	spots.append(_anchor("tailor") + Vector3(2.4, 0.0, 1.0))
	spots.append(_anchor("spawn") + Vector3(3.0, 0.0, 0.8))
	for pos: Vector3 in spots:
		if not town.is_floor_at(pos):
			continue
		_lamp_post(pos)
		town.obstacles.append(Vector3(pos.x, pos.z, 0.18))
		GroundDecals.glow(root, pos, 2.8, WARM_LIGHT, 0.22)
		var light: OmniLight3D = OmniLight3D.new()
		light.position = pos + Vector3(0.0, 1.45, 0.0)
		light.light_color = WARM_LIGHT
		light.light_energy = 2.2
		light.omni_range = 6.0
		light.omni_attenuation = 1.3
		root.add_child(light)
		lights.append(light)
		var bulb: MeshInstance3D = MeshInstance3D.new()
		var sphere: SphereMesh = SphereMesh.new()
		sphere.radius = 0.09
		sphere.height = 0.18
		bulb.mesh = sphere
		var glow_material: StandardMaterial3D = StandardMaterial3D.new()
		glow_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		glow_material.albedo_color = Color(1.0, 0.82, 0.45)
		bulb.material_override = glow_material
		bulb.position = pos + Vector3(0.0, 1.27, 0.0)
		bulb.set_meta(StyleToon.META_NO_TOON, true)
		root.add_child(bulb)


## An iron lamp post: a thin pole, a foot, a KayKit lantern on top.
func _lamp_post(pos: Vector3) -> void:
	var iron: StandardMaterial3D = StandardMaterial3D.new()
	iron.albedo_color = Color("3a3046")
	var pole: MeshInstance3D = MeshInstance3D.new()
	var cylinder: CylinderMesh = CylinderMesh.new()
	cylinder.top_radius = 0.035
	cylinder.bottom_radius = 0.06
	cylinder.height = 1.15
	pole.mesh = cylinder
	pole.material_override = iron
	pole.position = pos + Vector3(0.0, 0.575, 0.0)
	root.add_child(pole)
	var foot: MeshInstance3D = MeshInstance3D.new()
	var foot_mesh: CylinderMesh = CylinderMesh.new()
	foot_mesh.top_radius = 0.09
	foot_mesh.bottom_radius = 0.12
	foot_mesh.height = 0.12
	foot.mesh = foot_mesh
	foot.material_override = iron
	foot.position = pos + Vector3(0.0, 0.06, 0.0)
	root.add_child(foot)
	_put(ModelKit.HALLOWEEN, "lantern_standing", pos + Vector3(0.0, 1.12, 0.0), _rng.randf() * 360.0, 0.42)


# ---- market (kept light: two stalls, a few goods) ----------------------------------------------------------------------------------------


func _market() -> void:
	var m: Vector3 = _anchor("market")
	_stall(m + Vector3(-2.6, 0.0, 1.2), 0.0, ["bread", "loaf", "cheese"])
	_stall(m + Vector3(2.7, 0.0, 1.3), 0.0, ["cabbage", "carrot", "broccoli"])
	_put(ModelKit.KENNEY_SURVIVAL, "barrel", m + Vector3(-1.4, 0.0, -1.4), 20.0, 1.5, 0.2)
	_put(ModelKit.KENNEY_SURVIVAL, "box-large", m + Vector3(1.5, 0.0, -1.4), 35.0, 1.4, 0.2)
	_hex_prop("sack", m + Vector3(-1.9, 0.0, -1.0), 30.0, 1.3)


func _stall(pos: Vector3, yaw: float, goods: Array[String]) -> void:
	if not town.is_floor_at(pos):
		return
	_put(ModelKit.KENNEY_NATURE, "tent_detailedOpen", pos, yaw, 1.6, 0.5)
	var forward: Vector3 = Vector3(sin(deg_to_rad(yaw)), 0.0, cos(deg_to_rad(yaw)))
	var table_pos: Vector3 = pos + forward * 0.55
	var table: Node3D = _hex_prop("crate_long_A", table_pos, yaw, 2.1)
	ModelKit.tint(table, Color(0.78, 0.6, 0.5))
	var right: Vector3 = Vector3(forward.z, 0.0, -forward.x)
	var index: int = 0
	for good: String in goods:
		var spot: Vector3 = table_pos + right * (float(index) - 1.0) * 0.38 + Vector3(0.0, 0.42, 0.0)
		_put(ModelKit.KENNEY_FOOD, good, spot, _rng.randf() * 360.0, 0.6)
		index += 1


# ---- the plaza itself ---------------------------------------------------------------------------------------------------------------------


func _plaza_furniture() -> void:
	var well: Vector3 = _anchor("well")
	# a single short arc of flowers behind the well (the rest of the plaza stays open)
	for i: int in range(6):
		var angle: float = PI + PI * float(i) / 5.0
		var pos: Vector3 = well + Vector3(cos(angle) * 1.8, 0.0, sin(angle) * 1.3 - 1.0)
		_put(ModelKit.KENNEY_NATURE, ["flower_redA", "flower_yellowB", "flower_purpleA"][i % 3], pos, _rng.randf() * 360.0, 1.7)
	_put(ModelKit.HALLOWEEN, "bench", center + Vector3(-plaza_radius + 0.6, 0.0, 1.4), 90.0, 0.5, 0.4)
	_put(ModelKit.HALLOWEEN, "bench", center + Vector3(plaza_radius - 0.6, 0.0, 1.0), -90.0, 0.5, 0.4)


# ---- the meadow: sparse wind-swaying grass and just a few flowers (MultiMesh) -----------------------------------------------------


func _meadow() -> void:
	var groups: Array[Dictionary] = [
		{"model": "grass_leafs", "count": 650, "scale": Vector2(1.4, 2.4)},
		{"model": "plant_flatShort", "count": 130, "scale": Vector2(1.3, 2.0)},
		{"model": "plant_bush", "count": 20, "scale": Vector2(1.2, 1.8)},
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
			if not _meadow_ok(pos):
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


func _meadow_ok(pos: Vector3) -> bool:
	if not town.is_floor_at(pos):
		return false
	if Vector2(pos.x - center.x, pos.z - center.z).length() < 1.6:  # only the well itself
		return false
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
	scatter.bounds = Rect2(center.x - 30.0, center.z - 30.0, 60.0, 60.0)
	scatter.is_floor = func(pos: Vector3) -> bool: return town.is_floor_at(pos)
	for point: Vector3 in _lane_points:
		scatter.keep_out_circles.append(Vector3(point.x, point.z, 1.0))
	for obstacle: Vector3 in town.obstacles:
		scatter.keep_out_circles.append(Vector3(obstacle.x, obstacle.y, obstacle.z + 0.3))
	scatter.keep_out_circles.append(Vector3(center.x, center.z, 2.4))
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
	var count: int = [10, 21, 33][clampi(_quality, 0, 2)]
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
	if town.anchors.has("rift_station"):
		_beacon(_anchor("rift_station") + Vector3(0.0, 0.0, 0.0), Color(0.55, 0.95, 1.0))


## A faint additive light pillar so a destination reads from across the map (soft at the top, no hard edge).
func _beacon(pos: Vector3, color: Color) -> void:
	var cylinder: CylinderMesh = CylinderMesh.new()
	cylinder.top_radius = 0.2
	cylinder.bottom_radius = 0.6
	cylinder.height = 7.0
	cylinder.radial_segments = 16
	cylinder.rings = 1
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	material.cull_mode = BaseMaterial3D.CULL_BACK
	material.albedo_color = Color(color.r, color.g, color.b, 0.22)
	material.vertex_color_use_as_albedo = false
	material.no_depth_test = false
	var pillar: MeshInstance3D = MeshInstance3D.new()
	pillar.mesh = cylinder
	pillar.material_override = material
	pillar.position = pos + Vector3(0.0, cylinder.height * 0.5, 0.0)
	pillar.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	pillar.set_meta(StyleToon.META_NO_TOON, true)
	root.add_child(pillar)
