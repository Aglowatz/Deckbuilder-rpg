class_name TownStreets
extends RefCounted
## Dresses `TownLayout`: the paved roads and the plaza, the fountain with the royal crest (the four Path symbols in a ring), the notice board,
## signposts at the junctions, street lamps at even spacing, benches and a pair of market stalls on the plaza's edge. Everything is built from
## simple meshes and the town's own model kit; solid pieces register as obstacles on the `TownBuilder`.

const WARM_LIGHT: Color = Color("ffb45a")
const PAVING_LIGHT: Color = Color("e6d5ad")
const PAVING_DARK: Color = Color("c9b186")
const KERB: Color = Color("a39b88")
## The mown grass strip along each street.
const MOWN_LIGHT: Color = Color("8fd262")
const MOWN_DARK: Color = Color("6fb84c")
## Only this many lamps carry a real light (the rest glow); the style rig keeps the nearest few lit.
const LAMPS_WITH_LIGHT: int = 8

var root: Node3D
var town: TownBuilder
var lights: Array[OmniLight3D] = []
var lamp_points: Array[Vector3] = []
## Part C: the PathTool paths, the plaza, and the clump entries along the path edges (TownSquare turns them into foliage).
var paths: Array[Node3D] = []
var plaza_node: Node3D
var edge_clumps: Array[Dictionary] = []
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


static func build(parent: Node3D, builder: TownBuilder) -> TownStreets:
	var streets: TownStreets = TownStreets.new()
	streets.root = Node3D.new()
	streets.root.name = "TownPaving"
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
	# Part C: every road is a PathTool path (cobble streets round the square, dirt tracks out to the zones) with a soft irregular edge into the grass, worn patches at bends
	# and natural clumps of grass and flowers along its edges, instead of the old evenly mown strips.
	var all_roads: Dictionary = TownLayout.roads()
	var kinds: Dictionary = TownLayout.road_kinds()
	var index: int = 0
	for id: String in all_roads.keys():
		var control: Array[Vector3] = []
		for point: Variant in all_roads[id] as Array:
			control.append(point as Vector3)
		var is_floor: Callable = func(p: Vector3) -> bool: return town.is_floor_at(p)
		var avoid: Callable = func(p: Vector3) -> bool:
			return TownLayout.distance_to_roads(p) < TownLayout.ROAD_WIDTH * 0.5 + 0.2 or Vector2(p.x - TownLayout.PLAZA.x, p.z - TownLayout.PLAZA.z).length() < TownLayout.PLAZA_RADIUS + 0.6
		var path: Node3D = PathTool.build(root, control, {
			"width": TownLayout.ROAD_WIDTH - 0.3 if str(kinds.get(id, "dirt")) == "cobble" else TownLayout.ROAD_WIDTH - 0.6,
			"kind": str(kinds.get(id, "dirt")), "seed": 11 + index, "is_floor": is_floor, "avoid": avoid, "clumps": 1.0,
		})
		paths.append(path)
		for entry: Variant in path.get_meta("clumps") as Array:
			edge_clumps.append(entry as Dictionary)
		index += 1


func _plaza() -> void:
	# The cobbled square (ENV-GROUND-COBBLE): one irregular-edged disc whose rim melts into the grass, replacing the old stack of flat discs.
	plaza_node = PathTool.plaza(root, TownLayout.PLAZA, TownLayout.PLAZA_RADIUS, {"seed": 5})


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
	var board: Node3D = PropKit.notice_board()
	root.add_child(board)
	board.position = pos
	board.rotation_degrees.y = rad_to_deg(atan2(toward.x, toward.z))
	town.add_ao_blob(pos, 0.9, 0.3)
	town.obstacles.append(Vector3(pos.x, pos.z, 1.1))
	town.anchors["notice_board"] = pos + toward.normalized() * 1.4


## Signposts at the junctions: a post with arrow boards that carry the Path crest, no lettering. What the old boards said is read in a popup when the hero uses the post
## (`signpost_lines`, shown by the scene).
var signpost_positions: Array[Vector3] = []
var signpost_lines: Array[Array] = []


func _signposts() -> void:
	var index: int = 0
	for sign_data: Dictionary in TownLayout.signposts():
		var pos: Vector3 = sign_data["pos"] as Vector3
		if not town.is_floor_at(pos):
			continue
		var directions: Array[float] = []
		var lines: Array[String] = []
		for board: Variant in sign_data["boards"] as Array:
			var board_data: Dictionary = board as Dictionary
			directions.append(TownLayout.yaw_for_direction(str(board_data["dir"])))
			lines.append("%s: %s" % [TownLayout.direction_name(str(board_data["dir"])), str(board_data["text"])])
		var post: Node3D = PropKit.signpost(directions)
		post.name = "Signpost"
		root.add_child(post)
		post.position = pos
		town.add_ao_blob(pos, 0.35, 0.3)
		town.obstacles.append(Vector3(pos.x, pos.z, 0.3))
		town.anchors["signpost_%d" % index] = pos + Vector3(0.0, 0.0, 1.2)
		signpost_positions.append(pos)
		signpost_lines.append(lines)
		index += 1


## Lamp positions as {"pos": Vector3, "yaw": degrees} (the arm points at the road).
var lamp_entries: Array[Dictionary] = []


## Lamp posts (4.2 m, a banner on every other one) along the roads and round the square. They are two MultiMeshes (banner / plain: ten draws for thirty posts), each post with
## a soft light pool; real lights only on the few nearest the spawn (the style rig keeps the nearest few lit).
func _lamps() -> void:
	var points: Array[Vector3] = TownLayout.lamps()
	var road_samples: Array[Vector3] = TownLayout.road_points(1.5)
	var transforms: Array = [[] as Array[Transform3D], [] as Array[Transform3D]]
	var count: int = 0
	for pos: Vector3 in points:
		if not town.is_floor_at(pos) or TownLayout.in_footprint(pos, 0.9):
			continue
		# the lamp that would stand right behind the hero at the spawn (between the lens and the hero: the posts are batched, so they cannot dissolve) is left out
		if absf(pos.x - TownLayout.SPAWN.x) < 1.4 and pos.z > TownLayout.PLAZA.z + 3.0 and pos.z < TownLayout.SPAWN.z + 9.0:
			continue
		# the arm points towards the road so the lantern hangs over the paving
		var road_side: Vector3 = Vector3.ZERO
		var nearest: float = 1.0e9
		for road_point: Vector3 in road_samples:
			var d: float = Vector2(road_point.x - pos.x, road_point.z - pos.z).length()
			if d < nearest:
				nearest = d
				road_side = road_point - pos
		var yaw: float = rad_to_deg(atan2(-road_side.z, road_side.x)) if nearest < 1.0e8 else 0.0
		(transforms[count % 2] as Array[Transform3D]).append(Transform3D(Basis(Vector3.UP, deg_to_rad(yaw)), pos))
		lamp_points.append(pos)
		lamp_entries.append({"pos": pos, "yaw": yaw})
		town.obstacles.append(Vector3(pos.x, pos.z, 0.26))
		town.add_ao_blob(pos, 0.3, 0.3)
		town.add_glow(Vector3(pos.x, 0.0, pos.z), 2.8, WARM_LIGHT, 0.16)
		count += 1
	for variant: int in range(2):
		var list: Array[Transform3D] = transforms[variant] as Array[Transform3D]
		if list.is_empty():
			continue
		var prop: Node3D = PropKit.make("banner_post" if variant == 0 else "lantern_post")
		var mesh: ArrayMesh = (prop.get_child(0) as MeshInstance3D).mesh as ArrayMesh
		# the MultiMesh is not converted by the style rig (it only walks MeshInstance3D), so the toon materials are put on the surfaces here
		for surface: int in range(mesh.get_surface_count()):
			var standard: StandardMaterial3D = mesh.surface_get_material(surface) as StandardMaterial3D
			var toon: ShaderMaterial = StyleToon.toon_for(standard, -1.0, false) if standard != null else null
			if toon != null:
				mesh.surface_set_material(surface, toon)
		var multimesh: MultiMesh = MultiMesh.new()
		multimesh.transform_format = MultiMesh.TRANSFORM_3D
		multimesh.mesh = mesh
		multimesh.instance_count = list.size()
		for index: int in range(list.size()):
			multimesh.set_instance_transform(index, list[index])
		var instance: MultiMeshInstance3D = MultiMeshInstance3D.new()
		instance.name = "LampPosts_%d" % variant
		instance.multimesh = multimesh
		instance.extra_cull_margin = 6.0
		instance.set_meta(StyleToon.META_NO_TOON, true)
		root.add_child(instance)
		prop.free()
	# Real lights only for the lamps nearest the spawn.
	var spawn: Vector3 = TownLayout.SPAWN
	lamp_entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return (a["pos"] as Vector3).distance_squared_to(spawn) < (b["pos"] as Vector3).distance_squared_to(spawn))
	for index: int in range(mini(LAMPS_WITH_LIGHT, lamp_entries.size())):
		var entry: Dictionary = lamp_entries[index]
		var light: OmniLight3D = OmniLight3D.new()
		light.light_color = WARM_LIGHT
		light.light_energy = 2.2
		light.omni_range = 7.5
		light.omni_attenuation = 1.3
		root.add_child(light)
		light.position = (entry["pos"] as Vector3) + Basis(Vector3.UP, deg_to_rad(float(entry["yaw"]))) * Vector3(0.7, 3.4, 0.0)
		lights.append(light)


# ---- benches, planters and the market set round the plaza ---------------------------------------------------------------------------


func _plaza_furniture() -> void:
	var center: Vector3 = TownLayout.PLAZA
	# Four benches on the diagonals, facing the fountain, a lantern post and flowers tucked in beside each.
	for index: int in range(4):
		var angle: float = TAU * float(index) / 4.0 + PI / 4.0
		var pos: Vector3 = center + Vector3(cos(angle), 0.0, sin(angle)) * (TownLayout.PLAZA_RADIUS - 0.9)
		if Vector2(pos.x - TownLayout.NOTICE_BOARD.x, pos.z - TownLayout.NOTICE_BOARD.z).length() < 2.6 or Vector2(pos.x - TownLayout.SPAWN.x, pos.z - TownLayout.SPAWN.z).length() < 2.4:
			continue
		if not town.is_floor_at(pos):
			continue
		var toward: Vector3 = center - pos
		var bench: Node3D = PropKit.bench()
		root.add_child(bench)
		bench.position = pos
		# the bench's open side is +z; turn it so that side faces the fountain
		bench.rotation_degrees.y = rad_to_deg(atan2(toward.x, toward.z)) + 180.0
		town.add_ao_blob(pos, 0.8, 0.28)
		town.obstacles.append(Vector3(pos.x, pos.z, 0.55))
	# A market stall with its barrels and sacks at the plaza's east rim, turned to face the fountain (a cart would sit in the camera's foreground).
	var market_pos: Vector3 = Vector3(34.6, 0.0, 15.4)
	if town.is_floor_at(market_pos):
		var toward_plaza: Vector3 = center - market_pos
		var stall_yaw: float = rad_to_deg(atan2(toward_plaza.x, toward_plaza.z))
		var stall: Node3D = PropKit.stall(1)
		root.add_child(stall)
		stall.position = market_pos
		stall.rotation_degrees.y = stall_yaw
		town.obstacles.append(Vector3(market_pos.x, market_pos.z, 1.6))
		town.add_ao_blob(market_pos, 1.5, 0.3)
		var pair: Node3D = PropClusters.make("barrel_pair", 2)
		TownKit.place_cluster(root, town, pair, market_pos + Basis(Vector3.UP, deg_to_rad(stall_yaw)) * Vector3(2.7, 0.0, -0.4), stall_yaw)


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
