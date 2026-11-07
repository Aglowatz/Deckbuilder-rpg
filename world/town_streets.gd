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
	if builder.hub_land:
		streets._lane()
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
			"width": TownLayout.road_width(id) - (0.3 if str(kinds.get(id, "dirt")) == "cobble" else 0.6),
			"kind": str(kinds.get(id, "dirt")), "seed": 11 + index, "is_floor": is_floor, "avoid": avoid, "clumps": 1.0,
		})
		paths.append(path)
		for entry: Variant in path.get_meta("clumps") as Array:
			edge_clumps.append(entry as Dictionary)
		index += 1


## Crosspath pass, Part D: the worn lane that loops round the outside of the town (TownBounds.LOOP): round the back of the north row, down the east side
## past the orchard wall, along the lakeshore and the dock, across the meadows south of the fields and up the west side through the woods.
func _lane() -> void:
	var is_floor: Callable = func(p: Vector3) -> bool: return town.is_floor_at(p)
	var avoid: Callable = func(p: Vector3) -> bool: return TownLayout.is_paved(p, 0.2)
	var path: Node3D = PathTool.build(root, TownBounds.lane_points(), {
		"width": TownBounds.LANE_WIDTH - 0.4, "kind": "dirt", "seed": 61, "is_floor": is_floor, "avoid": avoid, "clumps": 0.7,
	})
	path.name = "LoopLane"
	paths.append(path)
	for entry: Variant in path.get_meta("clumps") as Array:
		edge_clumps.append(entry as Dictionary)


func _plaza() -> void:
	# The cobbled square (ENV-GROUND-COBBLE): one irregular-edged disc whose rim melts into the grass, replacing the old stack of flat discs.
	plaza_node = PathTool.plaza(root, TownLayout.PLAZA, TownLayout.PLAZA_RADIUS, {"seed": 5})


const FOUNTAIN_ART: String = "TOWN-HERO-FOUNTAIN"
## Fable pass Nov 1: the fountain is the square's landmark - a quarter bigger (5.8 -> 7.1 m; its blocker TownLayout.FOUNTAIN_RADIUS 2.6 -> 3.2), and it never
## fades or ghosts when the hero walks behind it (no card ghost, no occlusion fade); the hero shows through it as a silhouette instead (TownScene).
const FOUNTAIN_ART_HEIGHT: float = 4.6  # Nov 2 pass: the solid fountain's height (the silhouette test, TownScene)
const FOUNTAIN_ART_FORWARD: float = 0.0  # Nov 2 pass: solid geometry stands on the centre (the painted card stood 1.6 m forward)


# ---- the fountain and the royal crest ------------------------------------------------------------------------------------------------


## Nov 2 pass, Part 6: the fountain is solid geometry that matches the painted design (TOWN-HERO-FOUNTAIN): a round sandstone basin of
## two courses, four square pillars on the rim with a framed Path symbol each, a coloured spout from every pillar into the pool, a stepped
## central column with a round medallion and a flat cap, ivy on the stones; the water (the pool and the four streams) is one animated
## material (assets/shaders/fountain_water.gdshader). Nothing here fades, billboards or turns with the camera (the painted card did all three
## as the hero walked round it). Same blocker radius, same anchor, same silhouette test (TownScene) as before.
const FOUNTAIN_HEIGHT: float = 4.6
const FOUNTAIN_PILLAR_ANGLES: Array[float] = [PI * 0.25, PI * 0.75, PI * 1.25, PI * 1.75]
## The four pillars, clockwise from the front-left as the painting has them: the Path's icon (EndingDefs.PATH_ICONS: Beefcake, Gourmand,
## Refusemancer, Necrocrat) and the colour of its water.
const FOUNTAIN_PATH_ORDER: Array[int] = [0, 1, 3, 2]


func _fountain() -> void:
	var center: Vector3 = TownLayout.PLAZA
	var radius: float = TownLayout.FOUNTAIN_RADIUS
	var stone: KitMesh = KitMesh.new()
	# pale warm sandstone as flat colour under the toon bands (the kit's foundation texture is a fine rubble that read as a heap of rocks);
	# the block courses are thin dark seams round the basin and the column
	stone.set_material("stone", EnvKit.flat(Color("e9d9ae"), "fountain_stone"))
	stone.set_material("stone_dark", EnvKit.flat(Color("cdb98a"), "fountain_stone_dark"))
	stone.set_material("seam", EnvKit.flat(Color("8c7a56"), "fountain_seam"))
	stone.set_material("gold", EnvKit.flat(Color("e2b654"), "fountain_gold"))
	stone.set_material("ivy", EnvKit.material("DEC-IVY", true))
	# the basin: a lower course a step wider, the upper course with a rounded lip, the inner wall down to the water
	stone.lathe("stone_dark", Vector3.ZERO, [Vector2(radius + 0.42, 0.0), Vector2(radius + 0.44, 0.3), Vector2(radius + 0.36, 0.72), Vector2(radius + 0.08, 0.72)], 24, 0.9, false, false)
	stone.lathe("stone", Vector3(0, 0.72, 0), [Vector2(radius + 0.1, 0.0), Vector2(radius + 0.12, 0.42), Vector2(radius + 0.24, 0.62), Vector2(radius + 0.24, 0.78), Vector2(radius + 0.1, 0.84), Vector2(radius - 0.36, 0.84), Vector2(radius - 0.36, 0.1)], 24, 0.95, false, false)
	for seam_y: float in [0.34, 0.72, 1.14]:
		stone.lathe("seam", Vector3(0, seam_y, 0), [Vector2(radius + (0.45 if seam_y < 0.72 else 0.26), 0.0), Vector2(radius + (0.45 if seam_y < 0.72 else 0.26), 0.05)], 24, 1.0, false, false)
	for seam_a: int in range(12):
		var sa: float = TAU * float(seam_a) / 12.0 + 0.13
		stone.box("seam", Vector3(cos(sa), 0.0, sin(sa)) * (radius + 0.44) + Vector3(0, 0.36, 0), Vector3(0.05, 0.7, 0.05), Basis(Vector3.UP, -sa))
		stone.box("seam", Vector3(cos(sa + 0.26), 0.0, sin(sa + 0.26)) * (radius + 0.26) + Vector3(0, 1.14, 0), Vector3(0.05, 0.8, 0.05), Basis(Vector3.UP, -(sa + 0.26)))
	# the central column: a base drum in the water, the shaft, a collar, the flat cap
	stone.lathe("stone", Vector3(0, 0.75, 0), [Vector2(1.15, 0.0), Vector2(1.15, 0.8), Vector2(0.98, 0.86), Vector2(0.72, 0.86), Vector2(0.72, 2.6), Vector2(0.9, 2.66), Vector2(0.9, 3.0), Vector2(0.72, 3.05), Vector2(0.72, 3.35), Vector2(1.18, 3.42), Vector2(1.18, 3.85), Vector2(0.0, 3.85)], 20, 0.95, false, true)
	for seam_y: float in [1.9, 2.45, 3.0]:
		stone.lathe("seam", Vector3(0, seam_y, 0), [Vector2(0.735, 0.0), Vector2(0.735, 0.04)], 20, 1.0, false, false)
	# the medallion on the column's front: a ring of stone studs round a small gold boss
	for index: int in range(12):
		var a: float = TAU * float(index) / 12.0
		stone.box("stone_dark", Vector3(cos(a) * 0.4, 2.5 + sin(a) * 0.4, 0.76), Vector3(0.14, 0.14, 0.08))
	stone.box("gold", Vector3(0, 2.5, 0.76), Vector3(0.3, 0.3, 0.06))
	# ivy on the basin wall and the pillars (the kit's ivy decal on quads standing just off the stone)
	for a: float in [0.15, 1.35, 2.9, 4.25, 5.5]:
		var dir: Vector3 = Vector3(cos(a), 0.0, sin(a))
		var tangent: Vector3 = Vector3(-dir.z, 0.0, dir.x)
		var foot: Vector3 = dir * (radius + 0.43)
		var w: float = 1.5
		stone.quad("ivy", [foot - tangent * w * 0.5, foot + tangent * w * 0.5, foot + tangent * w * 0.5 + Vector3(0, 1.55, 0), foot - tangent * w * 0.5 + Vector3(0, 1.55, 0)], dir, [], [Vector2(0, 1), Vector2(1, 1), Vector2(1, 0), Vector2(0, 0)])
	var water: KitMesh = KitMesh.new()
	var water_material: ShaderMaterial = ShaderMaterial.new()
	water_material.shader = load("res://assets/shaders/fountain_water.gdshader") as Shader
	water_material.set_shader_parameter("foam", 0.28)
	water_material.set_shader_parameter("glow", 0.22)
	water.set_material("pool", water_material)
	var stream_material: ShaderMaterial = water_material.duplicate() as ShaderMaterial
	stream_material.set_shader_parameter("use_uv", true)
	stream_material.set_shader_parameter("alpha", 0.97)
	stream_material.set_shader_parameter("glow", 0.45)
	stream_material.set_shader_parameter("foam", 0.35)
	water.set_material("stream", stream_material)
	# the four pillars on the rim, their framed symbols facing out, their spouts facing in
	var path_colors: Array[Color] = []
	for index: int in range(4):
		var spec: Dictionary = EndingDefs.PATH_ICONS[FOUNTAIN_PATH_ORDER[index]]
		var tint: Color = Color(str(spec["color"]))
		path_colors.append(tint)
		var a: float = FOUNTAIN_PILLAR_ANGLES[index]
		var dir: Vector3 = Vector3(cos(a), 0.0, sin(a))
		var basis: Basis = Basis(Vector3.UP, -a)
		var foot: Vector3 = dir * (radius - 0.06)
		stone.box("stone_dark", foot + Vector3(0, 1.56 + 0.22, 0), Vector3(1.3, 0.44, 1.3), basis, 0.02, 0.95)
		stone.box("stone", foot + Vector3(0, 2.0 + 0.95, 0), Vector3(1.1, 1.9, 1.1), basis, 0.03, 1.0)
		stone.box("stone", foot + Vector3(0, 3.9 + 0.14, 0), Vector3(1.34, 0.28, 1.34), basis, 0.03, 1.0)
		stone.box("stone_dark", foot + Vector3(0, 4.04 + 0.12, 0), Vector3(1.04, 0.24, 1.04), basis, 0.02, 1.0)
		# the framed symbol on the outward face
		var face: Vector3 = foot + dir * 0.56 + Vector3(0, 2.95, 0)
		stone.box("gold", face + dir * 0.02, Vector3(0.05, 0.96, 0.82), basis)  # local X runs along dir: the thin side faces out
		stone.box("stone_dark", face + dir * 0.045, Vector3(0.02, 0.82, 0.68), basis)
		var icon: MeshInstance3D = MeshInstance3D.new()
		var quad: QuadMesh = QuadMesh.new()
		quad.size = Vector2(0.58, 0.58)
		icon.mesh = quad
		var icon_material: ShaderMaterial = ShaderMaterial.new()
		icon_material.shader = load("res://assets/shaders/icon_mask_3d.gdshader") as Shader
		icon_material.set_shader_parameter("icon_texture", CardIcons.named(str(spec["icon"])))
		icon_material.set_shader_parameter("tint", tint)
		icon.material_override = icon_material
		icon.set_meta(StyleToon.META_NO_TOON, true)
		icon.set_meta("no_occlusion_fade", true)
		icon.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		icon.position = center + face + dir * 0.07
		icon.rotation.y = atan2(dir.x, dir.z)
		root.add_child(icon)
		# the spout: a stone mouth on the inward face, the stream arcing down into the pool
		var mouth: Vector3 = foot - dir * 0.56 + Vector3(0, 3.0, 0)
		stone.box("stone_dark", mouth - dir * 0.04, Vector3(0.16, 0.36, 0.42), basis)
		_fountain_stream(water, mouth - dir * 0.1, dir, radius, tint)
		# ivy climbing the pillar's outer corner
		var side: Vector3 = Vector3(-dir.z, 0.0, dir.x)
		var ivy_foot: Vector3 = foot + dir * 0.57 + side * 0.36 + Vector3(0, 1.56, 0)
		stone.quad("ivy", [ivy_foot - side * 0.5, ivy_foot + side * 0.5, ivy_foot + side * 0.5 + Vector3(0, 1.9, 0), ivy_foot - side * 0.5 + Vector3(0, 1.9, 0)], dir, [], [Vector2(0, 1), Vector2(1, 1), Vector2(1, 0), Vector2(0, 0)])
	# the pool: a fan of triangles at the water line, each spout's colour bleeding into the blue round its landing
	var pool_r: float = radius - 0.38
	var blue: Color = Color(0.62, 0.86, 1.0)
	var pool_segments: int = 40
	for index: int in range(pool_segments):
		var a0: float = TAU * float(index) / float(pool_segments)
		var a1: float = TAU * float(index + 1) / float(pool_segments)
		var p0: Vector3 = Vector3(cos(a0), 0.0, sin(a0)) * pool_r + Vector3(0, 1.3, 0)
		var p1: Vector3 = Vector3(cos(a1), 0.0, sin(a1)) * pool_r + Vector3(0, 1.3, 0)
		water.tri("pool", [Vector3(0, 1.3, 0), p1, p0], Vector3.UP, [blue, _pool_colour(a1, blue, path_colors), _pool_colour(a0, blue, path_colors)])
	var stone_node: MeshInstance3D = stone.instance("FountainStone")
	stone_node.position = center
	stone_node.set_meta(&"no_wind", true)
	stone_node.set_meta("no_occlusion_fade", true)
	root.add_child(stone_node)
	var water_node: MeshInstance3D = water.instance("FountainWater")
	water_node.position = center
	water_node.set_meta(&"no_wind", true)
	water_node.set_meta("no_occlusion_fade", true)
	water_node.set_meta(StyleToon.META_NO_TOON, true)
	water_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(water_node)
	# a few drops where each stream lands
	for index: int in range(4):
		var a: float = FOUNTAIN_PILLAR_ANGLES[index]
		var splash: CPUParticles3D = CPUParticles3D.new()
		splash.position = center + Vector3(cos(a), 0.0, sin(a)) * 1.55 + Vector3(0, 1.32, 0)
		splash.amount = 10
		splash.lifetime = 0.7
		splash.direction = Vector3.UP
		splash.spread = 50.0
		splash.initial_velocity_min = 0.6
		splash.initial_velocity_max = 1.3
		splash.gravity = Vector3(0, -4.0, 0)
		var drop: SphereMesh = SphereMesh.new()
		drop.radius = 0.025
		drop.height = 0.05
		var drop_material: StandardMaterial3D = StandardMaterial3D.new()
		drop_material.albedo_color = path_colors[index].lerp(Color.WHITE, 0.55)
		drop_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		drop.material = drop_material
		splash.mesh = drop
		splash.set_meta("no_occlusion_fade", true)
		root.add_child(splash)
	town.obstacles.append(Vector3(center.x, center.z, TownLayout.FOUNTAIN_RADIUS + 0.1))
	town.anchors["fountain"] = center


## The pool's colour at angle `a`: the blue, warmed towards each spout's colour near where that spout lands.
static func _pool_colour(a: float, blue: Color, path_colors: Array[Color]) -> Color:
	var colour: Color = blue
	for index: int in range(4):
		var weight: float = pow(maxf(cos(a - FOUNTAIN_PILLAR_ANGLES[index]), 0.0), 3.0)
		colour = colour.lerp(path_colors[index].lerp(Color.WHITE, 0.25), weight * 0.85)
	return colour


## One spout's stream: a ribbon of quads from the mouth, arcing inward and down to the pool (UV v runs down the stream for the flow).
static func _fountain_stream(mesh: KitMesh, from: Vector3, dir: Vector3, radius: float, tint: Color) -> void:
	var inward: Vector3 = -dir
	var landing: Vector3 = inward * (radius - 1.65)
	landing.y = 1.3
	var points: Array[Vector3] = []
	var steps: int = 8
	for step: int in range(steps + 1):
		var t: float = float(step) / float(steps)
		var flat: Vector3 = from.lerp(Vector3(landing.x, from.y, landing.z), t)
		var y: float = from.y + 0.12 * sin(t * PI) - (from.y - landing.y) * t * t
		points.append(Vector3(flat.x, y, flat.z))
	var across: Vector3 = Vector3(-dir.z, 0.0, dir.x) * 0.15
	var colour: Color = tint.lerp(Color.WHITE, 0.2)
	for step: int in range(steps):
		var v0: float = float(step) / float(steps)
		var v1: float = float(step + 1) / float(steps)
		var w0: float = 1.0 + 0.5 * v0
		var w1: float = 1.0 + 0.5 * v1
		mesh.quad("stream", [points[step] - across * w0, points[step + 1] - across * w1, points[step + 1] + across * w1, points[step] + across * w0], inward + Vector3.UP, [colour, colour, colour, colour], [Vector2(0, v0), Vector2(0, v1), Vector2(1, v1), Vector2(1, v0)])


## The royal crest: four plinths in a ring round the fountain, each topped by its Path's symbol in the Path's colour, with a gold ring inlaid in the paving.
func _crest() -> void:
	var center: Vector3 = TownLayout.PLAZA
	var gold: ShaderMaterial = GroundDecals.material(GroundDecals.Pattern.CHALK, Color("e8c872"), Color("f6dc92"), Color.BLACK, GroundDecals.Shape.RIBBON, 1.0, 0.1, 7.0)
	var ring: Array[Vector3] = []
	for step: int in range(41):
		var angle: float = TAU * float(step) / 40.0
		ring.append(center + Vector3(cos(angle), 0.0, sin(angle)) * TownLayout.CREST_RING_RADIUS)
	GroundDecals.ribbon(root, ring, 0.28, gold, 0.007)
	var plinth: KitMesh = KitMesh.new()
	plinth.set_material("stone", EnvKit.material("ENV-WALL-FOUNDATION", false, Color(0.95, 0.92, 0.84)))
	for index: int in range(EndingDefs.PATH_ICONS.size()):
		var spec: Dictionary = EndingDefs.PATH_ICONS[index]
		var angle: float = TAU * float(index) / 4.0 + PI / 4.0
		var pos: Vector3 = center + Vector3(cos(angle), 0.0, sin(angle)) * TownLayout.CREST_RING_RADIUS
		# a kit-stone plinth: a square foot, a turned shaft and a cap (Crosspath pass, Part C)
		var local: Vector3 = pos - center
		plinth.box("stone", local + Vector3(0, 0.08, 0), Vector3(0.8, 0.16, 0.8), Basis(Vector3.UP, angle), 0.03, 0.75)
		plinth.lathe("stone", local + Vector3(0, 0.16, 0), [Vector2(0.32, 0.0), Vector2(0.26, 0.1), Vector2(0.24, 0.42), Vector2(0.4, 0.5), Vector2(0.4, 0.58)], 12, 0.85, false, true)
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
		town.obstacles.append(Vector3(pos.x, pos.z, 0.32))  # Fix pass Nov 7 (item 2): the plinth's foot, not a wide circle (was 0.4)
	var plinths: MeshInstance3D = plinth.instance("CrestPlinths")
	plinths.position = center
	root.add_child(plinths)


# ---- notice board, signposts, lamps --------------------------------------------------------------------------------------------------


func _notice_board() -> void:
	var pos: Vector3 = TownLayout.NOTICE_BOARD
	var toward: Vector3 = TownLayout.PLAZA - pos
	var board: Node3D = PropKit.notice_board()
	root.add_child(board)
	board.position = pos
	board.rotation_degrees.y = rad_to_deg(atan2(toward.x, toward.z))
	town.add_ao_blob(pos, 0.9, 0.3)
	town.obstacles.append(Vector3(pos.x, pos.z, 0.6))  # Fix pass Nov 7 (item 2): the board's posts (was a 1.1 m circle)
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
		town.obstacles.append(Vector3(pos.x, pos.z, 0.15))  # Fix pass Nov 7 (item 2): the post itself (was 0.3)
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
		town.obstacles.append(Vector3(pos.x, pos.z, 0.12))  # Fix pass Nov 7 (item 2): the lamp post itself (was 0.26)
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
		town.obstacles.append(Vector3(pos.x, pos.z, 0.42))  # Fix pass Nov 7 (item 2): the bench's seat (was 0.55)
	# Crosspath pass, Part C: the old decorative market stall on the east rim is gone: the six shops round the square are the market.


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
