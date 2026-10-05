class_name TownSquare
extends RefCounted
## The visual slice (Brief 12, Part C): the main town's central square dressed to docs/art/style_guide.md: a cobbled plaza with dirt paths and moss
## patches, market stalls with goods, lantern posts with warm light pools, bunting, benches, flower beds, clutter clusters at every building, and a
## wind-swaying meadow of grass tufts and flowers (MultiMesh). Everything is deterministic (seeded) and scaled by the graphics quality.

const CENTER: Vector3 = Vector3(8.0, 0.0, 8.0)
const PLAZA_RADIUS: float = 3.5
const MEADOW_RADIUS: float = 9.5

const WARM_LIGHT: Color = Color("ffb45a")

var root: Node3D
var town: TownBuilder
var lights: Array[OmniLight3D] = []
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _lane_points: Array[Vector3] = []
## Where every meadow tuft/flower stands (also readable headless, where MultiMesh buffers are not).
var meadow_points: Array[Vector3] = []
var _quality: int = GraphicsQuality.Level.MEDIUM
var _prop_index: int = 0


static func build(parent: Node3D, builder: TownBuilder, quality: int) -> TownSquare:
	var square: TownSquare = TownSquare.new()
	square.root = Node3D.new()
	square.root.name = "TownSquare"
	parent.add_child(square.root)
	square.town = builder
	square._quality = quality
	square._rng.seed = 4242
	square._ground()
	square._lanterns()
	square._market()
	square._plaza_furniture()
	square._building_skirts()
	square._gardens()
	square._meadow()
	square._bunting()
	return square


# ---- helpers ---------------------------------------------------------------------------------------------------------------------


func _anchor(key: String) -> Vector3:
	return town.anchors.get(key, CENTER) as Vector3


## Places a model from an extra kit; `solid` > 0 also adds a walk obstacle of that radius.
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


func _keep(chance: float = 1.0) -> bool:
	_prop_index += 1
	return GraphicsQuality.keep_item(_quality, _prop_index) or chance >= 1.0


# ---- ground: plaza, paths, patches -------------------------------------------------------------------------------------------------


func _ground() -> void:
	var cobble: ShaderMaterial = GroundDecals.material(GroundDecals.Pattern.COBBLE, Color("e0c294"), Color("b8a0a8"), Color("584258"), GroundDecals.Shape.DISC, 2.6, 0.35, 1.0)
	GroundDecals.disc(root, CENTER, PLAZA_RADIUS, cobble, 0.92, 0.0)
	var cobble_small: ShaderMaterial = GroundDecals.material(GroundDecals.Pattern.COBBLE, Color("d8b88c"), Color("b0989e"), Color("584258"), GroundDecals.Shape.DISC, 2.6, 0.45, 2.0)
	GroundDecals.disc(root, _anchor("market") + Vector3(0.2, 0.0, 0.1), 1.9, cobble_small, 0.8, 10.0, 0.002)
	GroundDecals.disc(root, _anchor("deck") + Vector3(0.0, 0.0, 0.2), 1.7, cobble_small, 0.8, -10.0, 0.002)
	GroundDecals.disc(root, _anchor("rift_station") + Vector3(0.0, 0.0, 0.0), 2.2, cobble_small, 0.9, 0.0, 0.002)
	var dirt: ShaderMaterial = GroundDecals.material(GroundDecals.Pattern.DIRT, Color("a78460"), Color("8f6e50"), Color("62483a"), GroundDecals.Shape.RIBBON, 1.0, 0.6, 3.0)
	var hub: Vector3 = CENTER + Vector3(0.0, 0.0, 1.0)
	var spawn: Vector3 = _anchor("spawn")
	var routes: Array[Array] = [
		[hub, _anchor("market") + Vector3(0.2, 0.0, 0.4), _anchor("market") + Vector3(-1.2, 0.0, 1.6), Vector3(2.4, 0.0, 8.0)],
		[hub, _anchor("deck") + Vector3(0.0, 0.0, 0.9), _anchor("deck") + Vector3(3.0, 0.0, 1.8), Vector3(18.0, 0.0, 7.6)],
		[hub, spawn + Vector3(0.0, 0.0, 1.0), spawn + Vector3(-1.0, 0.0, 2.6), _anchor("pack_vendor")],
		[hub, spawn + Vector3(1.5, 0.0, 1.4), _anchor("rift_station") + Vector3(-0.4, 0.0, -0.6)],
		[CENTER + Vector3(0.0, 0.0, -2.8), _anchor("well") + Vector3(0.0, 0.0, -0.9), Vector3(8.0, 0.0, 4.6), Vector3(8.0, 0.0, 2.4)],
	]
	for route: Array in routes:
		var points: Array[Vector3] = _smooth(route)
		for piece: Array[Vector3] in _land_runs(points):
			GroundDecals.ribbon(root, piece, 1.15, dirt, 0.004)
		_lane_points.append_array(points)
	var grass_dark: ShaderMaterial = GroundDecals.material(GroundDecals.Pattern.MOSS, Color("4f9a58"), Color("3c8466"), Color.BLACK, GroundDecals.Shape.DISC, 1.0, 0.7, 4.0)
	var grass_light: ShaderMaterial = GroundDecals.material(GroundDecals.Pattern.MOSS, Color("86c066"), Color("6fae62"), Color.BLACK, GroundDecals.Shape.DISC, 1.0, 0.7, 5.0)
	var moss: ShaderMaterial = GroundDecals.material(GroundDecals.Pattern.MOSS, Color("5f9a4a"), Color("7aa850"), Color.BLACK, GroundDecals.Shape.DISC, 1.0, 0.6, 6.0)
	for i: int in range(22):
		var angle: float = _rng.randf() * TAU
		var distance: float = _rng.randf_range(PLAZA_RADIUS + 0.8, MEADOW_RADIUS)
		var pos: Vector3 = CENTER + Vector3(cos(angle) * distance, 0.0, sin(angle) * distance)
		if not town.is_floor_at(pos):
			continue
		var mat: ShaderMaterial = [grass_dark, grass_light, moss][i % 3]
		GroundDecals.disc(root, pos, _rng.randf_range(1.0, 2.3), mat, _rng.randf_range(0.6, 1.0), _rng.randf() * 180.0, 0.001 * float(i))
	# moss and a darker rim where the plaza meets the grass
	var rim: ShaderMaterial = GroundDecals.material(GroundDecals.Pattern.MOSS, Color("6f9a52"), Color("587f4a"), Color.BLACK, GroundDecals.Shape.DISC, 1.0, 0.3, 7.0)
	for i: int in range(9):
		var angle: float = TAU * float(i) / 9.0 + 0.3
		GroundDecals.disc(root, CENTER + Vector3(cos(angle), 0.0, sin(angle)) * (PLAZA_RADIUS - 0.2), _rng.randf_range(0.5, 0.9), rim, 1.0, _rng.randf() * 90.0, 0.03)


func _smooth(points: Array) -> Array[Vector3]:
	var result: Array[Vector3] = []
	for i: int in range(points.size() - 1):
		var a: Vector3 = points[i] as Vector3
		var b: Vector3 = points[i + 1] as Vector3
		var steps: int = maxi(2, int(a.distance_to(b) / 0.8))
		for step: int in range(steps):
			var t: float = float(step) / float(steps)
			var wobble: float = sin((t + float(i)) * 3.1) * 0.12
			var along: Vector3 = (b - a).normalized()
			result.append(a.lerp(b, t) + Vector3(-along.z, 0.0, along.x) * wobble)
	result.append(points[points.size() - 1] as Vector3)
	return result


# ---- lantern posts and light pools -------------------------------------------------------------------------------------------------


func _lanterns() -> void:
	var spots: Array[Vector3] = []
	for i: int in range(7):
		var angle: float = TAU * (float(i) + 0.5) / 7.0
		spots.append(CENTER + Vector3(cos(angle) * (PLAZA_RADIUS + 0.2), 0.0, sin(angle) * (PLAZA_RADIUS * 0.9 + 0.2)))
	spots.append(_anchor("market") + Vector3(1.5, 0.0, 0.6))
	spots.append(_anchor("deck") + Vector3(-1.5, 0.0, 0.7))
	spots.append(_anchor("spawn") + Vector3(2.2, 0.0, 0.6))
	spots.append(_anchor("npc_pack_vendor") + Vector3(-1.2, 0.0, 0.4))
	for pos: Vector3 in spots:
		if not town.is_floor_at(pos):
			continue
		_lamp_post(pos)
		town.obstacles.append(Vector3(pos.x, pos.z, 0.18))
		GroundDecals.glow(root, pos, 2.0, WARM_LIGHT, 0.12)
		var light: OmniLight3D = OmniLight3D.new()
		light.position = pos + Vector3(0.0, 1.45, 0.0)
		light.light_color = WARM_LIGHT
		light.light_energy = 1.6
		light.omni_range = 5.0
		light.omni_attenuation = 1.3
		light.shadow_enabled = false
		root.add_child(light)
		lights.append(light)
		# warm glass on the lantern: a small emissive bulb
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


# ---- market ------------------------------------------------------------------------------------------------------------------


func _market() -> void:
	var m: Vector3 = _anchor("market")
	# two stalls flanking the market building, awnings from the tents, goods on the tables
	_stall(m + Vector3(-1.9, 0.0, 0.9), 0.0, ["bread", "loaf", "cheese"])
	_stall(m + Vector3(2.0, 0.0, 1.0), 0.0, ["cabbage", "carrot", "broccoli"])
	# loose goods: sacks, crates, barrels, baskets of produce
	for offset: Vector3 in [Vector3(-0.7, 0.0, -0.9), Vector3(0.8, 0.0, -1.0), Vector3(1.4, 0.0, -0.5)]:
		_put(ModelKit.KENNEY_SURVIVAL, ["box-large", "barrel", "box"][_rng.randi() % 3], m + offset, _rng.randf() * 360.0, 1.5, 0.2)
	_put(ModelKit.KENNEY_SURVIVAL, "bottle-large", m + Vector3(-1.1, 0.0, -0.7), 20.0, 1.6)
	_hex_prop("sack", m + Vector3(-1.3, 0.0, -0.3), 30.0, 1.3)
	_hex_prop("sack", m + Vector3(-1.45, 0.0, -0.05), 80.0, 1.2)
	_hex_prop("crate_B_small", m + Vector3(1.9, 0.0, -0.1), 15.0, 1.1, 0.2)
	_put(ModelKit.KENNEY_NATURE, "sign", m + Vector3(0.0, 0.0, 1.55), 180.0, 2.4)
	_put(ModelKit.KENNEY_SURVIVAL, "signpost", CENTER + Vector3(-3.7, 0.0, 0.2), 70.0, 2.6, 0.15)


func _stall(pos: Vector3, yaw: float, goods: Array[String]) -> void:
	if not town.is_floor_at(pos):
		return
	var tent: Node3D = _put(ModelKit.KENNEY_NATURE, "tent_detailedOpen", pos, yaw, 1.6, 0.5)
	tent.set_meta("stall", true)
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


# ---- the plaza itself: well garden, benches, trees -----------------------------------------------------------------------------------


func _plaza_furniture() -> void:
	var well: Vector3 = _anchor("well")
	# a ring of flowers around the well
	for i: int in range(18):
		var angle: float = TAU * float(i) / 18.0
		var pos: Vector3 = well + Vector3(cos(angle) * 1.55, 0.0, sin(angle) * 1.2 - 0.9)
		if i % 6 == 3:
			continue
		var flower: String = ["flower_redA", "flower_yellowB", "flower_purpleA", "flower_redC", "flower_yellowC", "flower_purpleC"][i % 6]
		_put(ModelKit.KENNEY_NATURE, flower, pos, _rng.randf() * 360.0, 1.9)
	GroundDecals.disc(root, well + Vector3(0.0, 0.0, -0.9), 1.9, GroundDecals.material(GroundDecals.Pattern.SOIL, Color("6a4a3a"), Color("5a3c34"), Color.BLACK, GroundDecals.Shape.DISC, 1.0, 0.5, 8.0), 0.85, 0.0, 0.01)
	# benches facing the well
	_put(ModelKit.HALLOWEEN, "bench", CENTER + Vector3(-2.7, 0.0, -0.4), 90.0, 0.5, 0.4)
	_put(ModelKit.HALLOWEEN, "bench", CENTER + Vector3(2.7, 0.0, -0.6), -90.0, 0.5, 0.4)
	# barrels and crates in a corner by the church, a wheelbarrow of produce
	var church: Vector3 = CENTER + Vector3(-1.6, 0.0, 1.4)
	_put(ModelKit.KENNEY_SURVIVAL, "barrel", church, 10.0, 1.5, 0.2)
	_put(ModelKit.KENNEY_SURVIVAL, "barrel-open", church + Vector3(0.35, 0.0, 0.3), 90.0, 1.5, 0.2)
	_put(ModelKit.KENNEY_SURVIVAL, "box-large", church + Vector3(-0.3, 0.0, 0.5), 25.0, 1.4, 0.2)
	_put(ModelKit.KENNEY_NATURE, "log_stack", CENTER + Vector3(3.9, 0.0, 2.4), 80.0, 2.2, 0.35)
	_put(ModelKit.KENNEY_NATURE, "stump_roundDetailed", CENTER + Vector3(3.6, 0.0, 3.1), 0.0, 2.2, 0.25)
	_put(ModelKit.KENNEY_NATURE, "mushroom_redGroup", CENTER + Vector3(3.5, 0.0, 3.1) + Vector3(0.35, 0.0, 0.1), 0.0, 2.0)
	# a little campfire pit with logs to sit on (warm light, a flicker of emissive)
	var camp: Vector3 = CENTER + Vector3(-4.2, 0.0, 3.0)
	if town.is_floor_at(camp):
		_put(ModelKit.KENNEY_NATURE, "campfire_stones", camp, 0.0, 2.2, 0.3)
		_put(ModelKit.KENNEY_NATURE, "log", camp + Vector3(0.8, 0.0, 0.1), 80.0, 2.2)
		_put(ModelKit.KENNEY_NATURE, "log", camp + Vector3(-0.7, 0.0, 0.3), 100.0, 2.2)
		GroundDecals.glow(root, camp, 2.0, Color("ff8a3a"), 0.3)
		var fire: OmniLight3D = OmniLight3D.new()
		fire.position = camp + Vector3(0.0, 0.5, 0.0)
		fire.light_color = Color("ff9a4a")
		fire.light_energy = 1.8
		fire.omni_range = 4.5
		root.add_child(fire)
		lights.append(fire)


# ---- skirts: every building gets something at its feet ------------------------------------------------------------------------------


func _building_skirts() -> void:
	var skirts: Array[Dictionary] = [
		{"key": "deck", "items": ["barrel", "crate", "pot", "bench"]},
		{"key": "market", "items": ["pot", "crate"]},
		{"key": "gate", "items": ["pot", "barrel"]},
		{"key": "spawn", "items": ["pot", "crate"]},
	]
	for entry: Dictionary in skirts:
		var base: Vector3 = _anchor(str(entry["key"]))
		var slot: int = 0
		for item: String in entry["items"]:
			var side: float = -1.0 if slot % 2 == 0 else 1.0
			var pos: Vector3 = base + Vector3(side * (1.35 + 0.25 * float(slot / 2)), 0.0, -0.2 - 0.3 * float(slot / 2))
			slot += 1
			if not town.is_floor_at(pos):
				continue
			match item:
				"barrel":
					_put(ModelKit.KENNEY_SURVIVAL, "barrel", pos, _rng.randf() * 360.0, 1.5, 0.2)
				"crate":
					_put(ModelKit.KENNEY_SURVIVAL, "box-large", pos, _rng.randf() * 90.0, 1.4, 0.2)
				"pot":
					_put(ModelKit.KENNEY_NATURE, "pot_large", pos, 0.0, 1.3, 0.2)
					_put(ModelKit.KENNEY_NATURE, ["flower_redA", "flower_yellowA", "flower_purpleB", "plant_bushSmall"][slot % 4], pos + Vector3(0.0, 0.18, 0.0), 0.0, 1.5)
				"bench":
					_put(ModelKit.HALLOWEEN, "bench", pos + Vector3(0.0, 0.0, 0.3), 0.0, 0.5, 0.4)


# ---- gardens: crop rows, fences ------------------------------------------------------------------------------------------------------


func _gardens() -> void:
	var plot: Vector3 = Vector3(7.0, 0.0, 5.0)
	if town.is_floor_at(plot):
		for row: int in range(3):
			for col: int in range(4):
				var pos: Vector3 = plot + Vector3(float(col) * 0.38 - 0.55, 0.0, float(row) * 0.34 - 0.3)
				if col == 0 and row == 0:
					continue
				_put(ModelKit.KENNEY_NATURE, ["crop_carrot", "crop_turnip", "crop_pumpkin", "crop_melon"][(col + row) % 4], pos, _rng.randf() * 360.0, 1.7)
	# low fences closing the plaza's north edge with a gap for the path
	for i: int in range(5):
		var pos: Vector3 = Vector3(5.6 + float(i) * 0.92, 0.0, 4.3)
		if absf(pos.x - 8.0) < 0.9 or not town.is_floor_at(pos):
			continue
		_put(ModelKit.KENNEY_NATURE, "fence_simple", pos, 0.0, 1.0)


# ---- the meadow: wind-swaying grass tufts and flowers (MultiMesh) ----------------------------------------------------------------------


func _meadow() -> void:
	var groups: Array[Dictionary] = [
		{"model": "grass_leafs", "count": 520, "scale": Vector2(1.4, 2.4)},
		{"model": "plant_flatShort", "count": 130, "scale": Vector2(1.3, 2.0)},
		{"model": "plant_bush", "count": 40, "scale": Vector2(1.2, 1.8)},
		{"model": "flower_redA", "count": 110, "scale": Vector2(1.2, 1.7)},
		{"model": "flower_yellowA", "count": 120, "scale": Vector2(1.2, 1.7)},
		{"model": "flower_purpleA", "count": 100, "scale": Vector2(1.2, 1.7)},
		{"model": "flower_yellowC", "count": 60, "scale": Vector2(1.2, 1.7)},
		{"model": "mushroom_redGroup", "count": 14, "scale": Vector2(1.2, 1.7)},
	]
	var density: float = GraphicsQuality.foliage_density(_quality)
	for group: Dictionary in groups:
		var mesh: Mesh = ModelKit.kit_mesh(ModelKit.KENNEY_NATURE, str(group["model"]))
		if mesh == null:
			continue
		var target: int = int(float(group["count"]) * density)
		var transforms: Array[Transform3D] = []
		var tries: int = 0
		while transforms.size() < target and tries < target * 8:
			tries += 1
			var angle: float = _rng.randf() * TAU
			var distance: float = sqrt(_rng.randf()) * MEADOW_RADIUS
			var pos: Vector3 = CENTER + Vector3(cos(angle) * distance, 0.0, sin(angle) * distance * 0.9)
			if not _meadow_ok(pos):
				continue
			var scale_range: Vector2 = group["scale"] as Vector2
			var s: float = _rng.randf_range(scale_range.x, scale_range.y)
			var xform: Transform3D = Transform3D(Basis(Vector3.UP, _rng.randf() * TAU).scaled(Vector3.ONE * s), pos)
			transforms.append(xform)
			meadow_points.append(pos)
		_multimesh(mesh, transforms)


func _meadow_ok(pos: Vector3) -> bool:
	if not town.is_floor_at(pos):
		return false
	if Vector2(pos.x - CENTER.x, pos.z - CENTER.z).length() < PLAZA_RADIUS * 0.95:
		return false
	for point: Vector3 in _lane_points:
		if Vector2(pos.x - point.x, pos.z - point.z).length() < 0.62:
			return false
	for obstacle: Vector3 in town.obstacles:
		if Vector2(pos.x - obstacle.x, pos.z - obstacle.y).length() < obstacle.z + 0.15:
			return false
	for key: String in ["market", "deck", "well", "gate", "spawn", "npc_market", "npc_well", "npc_gate", "rift_station"]:
		if Vector2(pos.x - _anchor(key).x, pos.z - _anchor(key).z).length() < 0.9:
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


# ---- bunting between lantern posts -----------------------------------------------------------------------------------------------------


func _bunting() -> void:
	var posts: Array[Vector3] = []
	for i: int in range(7):
		var angle: float = TAU * (float(i) + 0.5) / 7.0
		posts.append(CENTER + Vector3(cos(angle) * (PLAZA_RADIUS + 0.2), 0.0, sin(angle) * (PLAZA_RADIUS * 0.9 + 0.2)))
	var colors: Array[Color] = [Color("e8473c"), Color("f3c13a"), Color("3d9be0"), Color("f08ab0"), Color("5cc07a")]
	var vertices: PackedVector3Array = PackedVector3Array()
	var vertex_colors: PackedColorArray = PackedColorArray()
	var normals: PackedVector3Array = PackedVector3Array()
	for i: int in range(posts.size() - 1):
		var a: Vector3 = posts[i] + Vector3(0.0, 1.3, 0.0)
		var b: Vector3 = posts[i + 1] + Vector3(0.0, 1.3, 0.0)
		if not town.is_floor_at(posts[i]) or not town.is_floor_at(posts[i + 1]):
			continue
		var flags: int = 7
		for k: int in range(flags):
			var t: float = (float(k) + 0.5) / float(flags)
			var p: Vector3 = a.lerp(b, t) + Vector3(0.0, -sin(t * PI) * 0.28, 0.0)
			var along: Vector3 = (b - a).normalized()
			var half: Vector3 = along * 0.1
			var color: Color = colors[(i + k) % colors.size()]
			vertices.append(p - half)
			vertices.append(p + half)
			vertices.append(p + Vector3(0.0, -0.22, 0.0))
			for v: int in range(3):
				vertex_colors.append(color)
				normals.append(Vector3(along.z, 0.0, -along.x))
	if vertices.is_empty():
		return
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_COLOR] = vertex_colors
	arrays[Mesh.ARRAY_NORMAL] = normals
	var mesh: ArrayMesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh.surface_set_material(0, material)
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = mesh
	instance.name = "Bunting"
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(instance)


## An iron lamp post: a thin pole, a cap, a KayKit lantern on top, and a warm bulb (the glow and the light are added by the caller).
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
