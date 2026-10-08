class_name TownStreets
extends RefCounted
## Dresses `TownLayout`: the paved roads and the plaza, the fountain with the royal crest (the four Path symbols in a ring), the notice board,
## signposts at the junctions, street lamps at even spacing, benches and a pair of market stalls on the plaza's edge. Everything is built from
## simple meshes and the town's own model kit; solid pieces register as obstacles on the `TownBuilder`.

const WARM_LIGHT: Color = Color("ffb45a")
const PAVING_LIGHT: Color = Color("e6d5ad")
const PAVING_DARK: Color = Color("c9b186")
const KERB: Color = Color("9d8a66")
## Only this many lamps carry a real light (the rest glow); the style rig keeps the nearest few lit.
const LAMPS_WITH_LIGHT: int = 10

var root: Node3D
var town: TownBuilder
var lights: Array[OmniLight3D] = []
var lamp_points: Array[Vector3] = []
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


static func build(parent: Node3D, builder: TownBuilder) -> TownStreets:
	var streets: TownStreets = TownStreets.new()
	streets.root = Node3D.new()
	streets.root.name = "TownStreets"
	parent.add_child(streets.root)
	streets.town = builder
	streets._rng.seed = 909
	streets._roads()
	streets._plaza()
	streets._fountain()
	streets._crest()
	streets._notice_board()
	streets._signposts()
	streets._lamps()
	streets._plaza_furniture()
	return streets


# ---- the paving ---------------------------------------------------------------------------------------------------------------------


func _roads() -> void:
	var paving: ShaderMaterial = GroundDecals.material(GroundDecals.Pattern.COBBLE, PAVING_LIGHT, PAVING_DARK, KERB, GroundDecals.Shape.RIBBON, 1.3, 0.08, 3.0)
	var kerb: ShaderMaterial = GroundDecals.material(GroundDecals.Pattern.DIRT, KERB, Color("b39d76"), Color.BLACK, GroundDecals.Shape.RIBBON, 1.6, 0.2, 4.0)
	var all_roads: Dictionary = TownLayout.roads()
	var index: int = 0
	for id: String in all_roads.keys():
		var points: Array[Vector3] = TownLayout.sample(all_roads[id] as Array, 0.9)
		var land: Array[Vector3] = []
		for point: Vector3 in points:
			if town.is_floor_at(point):
				land.append(point)
		if land.size() < 2:
			continue
		GroundDecals.ribbon(root, land, TownLayout.ROAD_WIDTH + 0.6, kerb, 0.001)
		GroundDecals.ribbon(root, land, TownLayout.ROAD_WIDTH, paving, 0.004 + 0.0005 * float(index))
		index += 1


func _plaza() -> void:
	var kerb: ShaderMaterial = GroundDecals.material(GroundDecals.Pattern.DIRT, KERB, Color("b39d76"), Color.BLACK, GroundDecals.Shape.DISC, 1.6, 0.2, 4.0)
	var paving: ShaderMaterial = GroundDecals.material(GroundDecals.Pattern.COBBLE, PAVING_LIGHT, PAVING_DARK, KERB, GroundDecals.Shape.DISC, 1.3, 0.06, 5.0)
	var inner: ShaderMaterial = GroundDecals.material(GroundDecals.Pattern.COBBLE, Color("f0e4c4"), Color("d8c79c"), KERB, GroundDecals.Shape.DISC, 1.0, 0.05, 6.0)
	GroundDecals.disc(root, TownLayout.PLAZA, TownLayout.PLAZA_RADIUS + 0.4, kerb, 1.0, 0.0, 0.0015)
	GroundDecals.disc(root, TownLayout.PLAZA, TownLayout.PLAZA_RADIUS, paving, 1.0, 0.0, 0.0045)
	GroundDecals.disc(root, TownLayout.PLAZA, TownLayout.CREST_RING_RADIUS + 1.0, inner, 1.0, 0.0, 0.0055)


# ---- the fountain and the royal crest ------------------------------------------------------------------------------------------------


func _fountain() -> void:
	var center: Vector3 = TownLayout.PLAZA
	var stone: StandardMaterial3D = _material(Color("d8cdb4"), 0.85)
	var dark: StandardMaterial3D = _material(Color("9d917a"), 0.9)
	var water: StandardMaterial3D = _material(Color("6fd0ea"), 0.15)
	water.emission_enabled = true
	water.emission = Color("4fb8dc")
	water.emission_energy_multiplier = 0.5
	# basin: a ring of stone blocks, water inside, a pedestal and two bowls
	_cylinder(TownLayout.FOUNTAIN_RADIUS, 0.5, stone, center + Vector3(0, 0.25, 0))
	_cylinder(TownLayout.FOUNTAIN_RADIUS - 0.22, 0.04, water, center + Vector3(0, 0.51, 0))
	_cylinder(0.32, 1.5, dark, center + Vector3(0, 1.0, 0))
	_cylinder(0.85, 0.18, stone, center + Vector3(0, 1.45, 0))
	_cylinder(0.72, 0.03, water, center + Vector3(0, 1.55, 0))
	_cylinder(0.14, 0.9, dark, center + Vector3(0, 2.0, 0))
	_cylinder(0.45, 0.12, stone, center + Vector3(0, 2.4, 0))
	var jet: CPUParticles3D = CPUParticles3D.new()
	jet.position = center + Vector3(0, 2.5, 0)
	jet.amount = 24
	jet.lifetime = 1.2
	jet.direction = Vector3.UP
	jet.spread = 18.0
	jet.initial_velocity_min = 0.9
	jet.initial_velocity_max = 1.5
	jet.gravity = Vector3(0, -3.0, 0)
	var drop: SphereMesh = SphereMesh.new()
	drop.radius = 0.03
	drop.height = 0.06
	var drop_material: StandardMaterial3D = StandardMaterial3D.new()
	drop_material.albedo_color = Color("c9f1ff")
	drop_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	drop.material = drop_material
	jet.mesh = drop
	root.add_child(jet)
	town.obstacles.append(Vector3(center.x, center.z, TownLayout.FOUNTAIN_RADIUS + 0.1))
	town.anchors["fountain"] = center


## The royal crest: four plinths in a ring round the fountain, each topped by its Path's symbol in the Path's colour, with a gold ring inlaid in the paving.
func _crest() -> void:
	var center: Vector3 = TownLayout.PLAZA
	var gold: ShaderMaterial = GroundDecals.material(GroundDecals.Pattern.CHALK, Color("e8c872"), Color("f6dc92"), Color.BLACK, GroundDecals.Shape.RIBBON, 1.0, 0.1, 7.0)
	var ring: Array[Vector3] = []
	for step: int in range(41):
		var angle: float = TAU * float(step) / 40.0
		ring.append(center + Vector3(cos(angle), 0.0, sin(angle)) * TownLayout.CREST_RING_RADIUS)
	GroundDecals.ribbon(root, ring, 0.28, gold, 0.007)
	var stone: StandardMaterial3D = _material(Color("cbbf9f"), 0.85)
	for index: int in range(EndingDefs.PATH_ICONS.size()):
		var spec: Dictionary = EndingDefs.PATH_ICONS[index]
		var angle: float = TAU * float(index) / 4.0 + PI / 4.0
		var pos: Vector3 = center + Vector3(cos(angle), 0.0, sin(angle)) * TownLayout.CREST_RING_RADIUS
		_cylinder(0.34, 0.5, stone, pos + Vector3(0, 0.25, 0))
		_cylinder(0.42, 0.1, stone, pos + Vector3(0, 0.55, 0))
		var tint: Color = Color(str(spec["color"]))
		var glow: StandardMaterial3D = _material(tint, 0.3)
		glow.emission_enabled = true
		glow.emission = tint
		glow.emission_energy_multiplier = 0.8
		var gem: MeshInstance3D = MeshInstance3D.new()
		var sphere: SphereMesh = SphereMesh.new()
		sphere.radius = 0.17
		sphere.height = 0.34
		gem.mesh = sphere
		gem.material_override = glow
		gem.position = pos + Vector3(0, 0.78, 0)
		root.add_child(gem)
		var icon: MeshInstance3D = MeshInstance3D.new()
		var quad: QuadMesh = QuadMesh.new()
		quad.size = Vector2(0.9, 0.9)
		icon.mesh = quad
		var icon_material: ShaderMaterial = ShaderMaterial.new()
		icon_material.shader = load("res://assets/shaders/icon_mask_3d.gdshader") as Shader
		icon_material.set_shader_parameter("icon_texture", CardIcons.named(str(spec["icon"])))
		icon_material.set_shader_parameter("tint", tint)
		icon.material_override = icon_material
		icon.position = pos + Vector3(0, 1.35, 0)
		root.add_child(icon)
		town.obstacles.append(Vector3(pos.x, pos.z, 0.4))


# ---- notice board, signposts, lamps --------------------------------------------------------------------------------------------------


func _notice_board() -> void:
	var pos: Vector3 = TownLayout.NOTICE_BOARD
	var toward: Vector3 = TownLayout.PLAZA - pos
	var yaw: float = rad_to_deg(atan2(toward.x, toward.z))
	var holder: Node3D = Node3D.new()
	holder.position = pos
	holder.rotation_degrees.y = yaw
	root.add_child(holder)
	var wood: StandardMaterial3D = _material(Color("6b4a2c"), 0.9)
	var paper: StandardMaterial3D = _material(Color("f2e8c8"), 1.0)
	for side: float in [-0.62, 0.62]:
		holder.add_child(_box(Vector3(0.12, 1.9, 0.12), wood, Vector3(side, 0.95, 0)))
	holder.add_child(_box(Vector3(1.5, 1.0, 0.09), wood, Vector3(0, 1.35, 0)))
	holder.add_child(_box(Vector3(1.6, 0.14, 0.2), wood, Vector3(0, 1.95, 0)))
	for index: int in range(5):
		var note: MeshInstance3D = _box(Vector3(0.26, 0.32, 0.02), paper, Vector3(-0.5 + 0.25 * float(index), 1.4 + 0.12 * float((index * 3) % 3 - 1), 0.06))
		note.rotation_degrees.z = float(index * 7 % 11) - 5.0
		holder.add_child(note)
	var title: Label3D = _label("NOTICES", Vector3(0, 2.2, 0.12), Color("ffe6a8"), 0.0052)
	holder.add_child(title)
	town.obstacles.append(Vector3(pos.x, pos.z, 0.75))
	town.anchors["notice_board"] = pos + toward.normalized() * 1.2


func _signposts() -> void:
	var wood: StandardMaterial3D = _material(Color("7a5632"), 0.9)
	var plank: StandardMaterial3D = _material(Color("c8a46a"), 0.85)
	for sign_data: Dictionary in TownLayout.signposts():
		var pos: Vector3 = sign_data["pos"] as Vector3
		_cylinder(0.07, 2.6, wood, pos + Vector3(0, 1.3, 0))
		var boards: Array = sign_data["boards"] as Array
		for index: int in range(boards.size()):
			var board: Dictionary = boards[index] as Dictionary
			var height: float = 2.25 - 0.5 * float(index)
			var text: String = "%s %s" % [TownLayout.arrow_for(str(board["dir"])), str(board["text"])]
			var width: float = 0.9 + 0.09 * float(text.length())
			var pole_side: float = -1.0 if str(board["dir"]).contains("W") else 1.0
			var offset_x: float = pole_side * width * 0.5
			root.add_child(_box(Vector3(width, 0.36, 0.06), plank, pos + Vector3(offset_x * 0.3, height, 0.0)))
			var label: Label3D = _label(text, pos + Vector3(offset_x * 0.3, height, 0.05), Color("2f1f12"), 0.0042)
			label.outline_size = 0
			root.add_child(label)
		town.obstacles.append(Vector3(pos.x, pos.z, 0.2))


func _lamps() -> void:
	var points: Array[Vector3] = TownLayout.lamps()
	var count: int = 0
	for pos: Vector3 in points:
		if not town.is_floor_at(pos):
			continue
		_lamp_post(pos)
		lamp_points.append(pos)
		town.obstacles.append(Vector3(pos.x, pos.z, 0.18))
		GroundDecals.glow(root, pos, 2.6, WARM_LIGHT, 0.2)
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
		if count < LAMPS_WITH_LIGHT:
			var light: OmniLight3D = OmniLight3D.new()
			light.position = pos + Vector3(0.0, 1.45, 0.0)
			light.light_color = WARM_LIGHT
			light.light_energy = 2.2
			light.omni_range = 6.0
			light.omni_attenuation = 1.3
			root.add_child(light)
			lights.append(light)
		count += 1


## An iron lamp post: a thin pole, a foot, a KayKit lantern on top.
func _lamp_post(pos: Vector3) -> void:
	var iron: StandardMaterial3D = _material(Color("3a3046"), 0.6)
	var pole: MeshInstance3D = _cylinder(0.035, 1.15, iron, pos + Vector3(0.0, 0.575, 0.0))
	pole.mesh.set("bottom_radius", 0.06)
	_cylinder(0.1, 0.12, iron, pos + Vector3(0.0, 0.06, 0.0))
	var lantern: Node3D = ModelKit.kit_model(ModelKit.HALLOWEEN, "lantern_standing")
	ModelKit.place(root, lantern, pos + Vector3(0.0, 1.12, 0.0), _rng.randf() * 360.0, 0.42)


# ---- benches, planters and market stalls round the plaza -----------------------------------------------------------------------------


func _plaza_furniture() -> void:
	var center: Vector3 = TownLayout.PLAZA
	# Four benches on the diagonals, facing the fountain; flower planters between the road mouths.
	for index: int in range(4):
		var angle: float = TAU * float(index) / 4.0 + PI / 4.0 + PI / 8.0 * 0.0
		var pos: Vector3 = center + Vector3(cos(angle), 0.0, sin(angle)) * (TownLayout.PLAZA_RADIUS - 1.0)
		if Vector2(pos.x - TownLayout.NOTICE_BOARD.x, pos.z - TownLayout.NOTICE_BOARD.z).length() < 2.4 or Vector2(pos.x - TownLayout.SPAWN.x, pos.z - TownLayout.SPAWN.z).length() < 2.2:
			continue
		var toward: Vector3 = center - pos
		var node: Node3D = ModelKit.kit_model(ModelKit.HALLOWEEN, "bench")
		ModelKit.place(root, node, pos, rad_to_deg(atan2(toward.x, toward.z)), 0.5)
		town.obstacles.append(Vector3(pos.x, pos.z, 0.4))
	for index: int in range(4):
		var angle: float = TAU * float(index) / 4.0
		var pos: Vector3 = center + Vector3(cos(angle), 0.0, sin(angle)) * (TownLayout.PLAZA_RADIUS - 0.2)
		if TownLayout.distance_to_roads(pos) < TownLayout.ROAD_WIDTH * 0.5 + 0.6:
			continue
		for flower: int in range(5):
			var spot: Vector3 = pos + Vector3(_rng.randf_range(-0.5, 0.5), 0.0, _rng.randf_range(-0.5, 0.5))
			var model: Node3D = ModelKit.kit_model(ModelKit.KENNEY_NATURE, ["flower_redA", "flower_yellowB", "flower_purpleA"][flower % 3])
			ModelKit.place(root, model, spot, _rng.randf() * 360.0, 1.7)
	# Two market stalls at the plaza's edge, either side of the south road.
	for side: float in [-1.0, 1.0]:
		var pos: Vector3 = center + Vector3(side * 7.0, 0.0, 6.6)
		if not town.is_floor_at(pos):
			continue
		var goods: Array[String] = ["cabbage", "carrot", "broccoli"]
		if side < 0.0:
			goods = ["bread", "loaf", "cheese"]
		_stall(pos, 0.0, goods)


func _stall(pos: Vector3, yaw: float, goods: Array[String]) -> void:
	var tent: Node3D = ModelKit.kit_model(ModelKit.KENNEY_NATURE, "tent_detailedOpen")
	ModelKit.place(root, tent, pos, yaw, 1.6)
	town.obstacles.append(Vector3(pos.x, pos.z, 0.6))
	var forward: Vector3 = Vector3(sin(deg_to_rad(yaw)), 0.0, cos(deg_to_rad(yaw)))
	var table_pos: Vector3 = pos + forward * 0.55
	var table: Node3D = ModelKit.place(root, ModelKit.prop("crate_long_A"), table_pos, yaw, 2.1)
	ModelKit.tint(table, Color(0.78, 0.6, 0.5))
	var right: Vector3 = Vector3(forward.z, 0.0, -forward.x)
	var index: int = 0
	for good: String in goods:
		var spot: Vector3 = table_pos + right * (float(index) - 1.0) * 0.38 + Vector3(0.0, 0.42, 0.0)
		ModelKit.place(root, ModelKit.kit_model(ModelKit.KENNEY_FOOD, good), spot, _rng.randf() * 360.0, 0.6)
		index += 1


# ---- small mesh helpers ---------------------------------------------------------------------------------------------------------------


func _material(color: Color, rough: float) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = rough
	return material


func _box(size: Vector3, material: Material, pos: Vector3) -> MeshInstance3D:
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	instance.position = pos
	return instance


func _cylinder(radius: float, height: float, material: Material, pos: Vector3) -> MeshInstance3D:
	var mesh: CylinderMesh = CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	instance.position = pos
	root.add_child(instance)
	return instance


func _label(text: String, pos: Vector3, color: Color, pixel_size: float) -> Label3D:
	var label: Label3D = Label3D.new()
	label.text = text
	label.font = StyleLabel.title_font()
	label.font_size = 48
	label.pixel_size = pixel_size
	label.modulate = color
	label.outline_size = 8
	label.outline_modulate = Color(0.05, 0.04, 0.03, 0.9)
	label.position = pos
	label.double_sided = false
	return label
