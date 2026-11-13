class_name CapitalCrease
extends RefCounted
## Fable Nov 12c (A8): the Crease is a cavern. It was an open brick yard under the Capital's sky: the castle backdrop and the wasteland's
## hills showed over its walls and six black brick doorways stood loose on the floor. This builds the shell that makes it read as entirely
## underground and enclosed, with no new art (the painted `mat_rock` texture, the kit's crystals):
##
## - rock walls on every side the camera can see (north, west, east), lumpy and leaning in as they rise; the west and east walls and the
##   floor run on south well past the walkable hall, because the camera trails 15 m south of the hero;
## - a low rock ceiling over all of it, so no sky and no backdrop can show from any camera;
## - stalactites (long ones along the north wall and the sides, short ones elsewhere, none low enough to cross the camera's line), a few
##   of them dripping, and stalagmites along the walls' feet and in a row along the hall's south edge (the boundary the hero stops at);
## - puddles on the damp stone floor;
## - warm lantern pools (lanterns hung on chains) and a few cool crystal glows.
##
## Everything here is scenery: nothing is walkable-relevant (the layout's cells and props are unchanged) and nothing fades for the camera.

const M = preload("res://world/capital/capital_materials.gd")
const K = preload("res://world/capital/capital_kit.gd")
## The walkable hall (x 4..41, z 134..155) and the shell round it.
const HALL: Rect2 = Rect2(4.0, 134.0, 37.0, 21.0)
const CEILING_Y: float = 7.6
const WALL_TOP: float = 9.4
## How far south of the hall the cavern runs on (the camera stands up to 16 m south of the hero).
const SOUTH_REACH: float = 28.0
## The shell's faces: the north wall's foot, the side walls' feet.
const NORTH_Z: float = 133.25
const WEST_X: float = 3.55
const EAST_X: float = 41.45
const ROCK_TEXTURE: String = "mat_rock"
const ROCK_FLAT: Color = Color(0.2, 0.19, 0.25)
const ROCK_TINT: Color = Color(0.6, 0.58, 0.72)
## Lanterns on chains: [x, z, height] - over the stalls, the heal corner and Wren's table. Only along the north side: a lantern hanging
## in the middle of the hall dangles in front of the camera.
const LANTERNS: Array[Vector3] = [
	Vector3(31.0, 138.6, 3.7), Vector3(36.6, 138.4, 3.6), Vector3(22.0, 137.4, 3.8), Vector3(13.4, 138.0, 3.6), Vector3(7.2, 136.2, 3.5),
]
## Lanterns on brackets on the side walls: [x, z, height].
const WALL_LANTERNS: Array[Vector3] = [
	Vector3(4.25, 142.0, 2.7), Vector3(4.25, 151.5, 2.7), Vector3(40.75, 141.5, 2.7), Vector3(40.75, 152.0, 2.7),
]
## Crystal growths with a cool glow: [x, z, height, cyan (1) or violet (0)].
const CRYSTALS: Array[Vector4] = [
	Vector4(5.0, 151.6, 1.9, 1.0), Vector4(40.0, 136.0, 2.2, 0.0), Vector4(18.2, 134.7, 1.6, 0.0), Vector4(40.1, 153.2, 1.7, 1.0), Vector4(5.2, 137.4, 1.4, 1.0),
]
const WARM: Color = Color("ffb45a")
const VIOLET: Color = Color("9b59d0")
const CYAN: Color = Color("6fd8ff")
## Puddles: [x, z, radius].
const PUDDLES: Array[Vector3] = [
	Vector3(9.0, 149.6, 1.3), Vector3(17.5, 145.6, 1.0), Vector3(24.5, 141.6, 0.8), Vector3(33.8, 146.2, 1.2), Vector3(12.6, 152.6, 0.9),
	Vector3(29.0, 152.4, 1.1), Vector3(38.2, 143.6, 0.8), Vector3(6.4, 141.4, 0.9), Vector3(20.6, 150.2, 0.7), Vector3(26.4, 136.6, 0.7),
]
## Stalactites that drip: [x, z] (each hangs over a puddle).
const DRIPS: Array[Vector2] = [Vector2(9.0, 149.6), Vector2(24.5, 141.6), Vector2(33.8, 146.2), Vector2(6.4, 141.4), Vector2(29.0, 152.4)]

var root: Node3D
var lights: Array[OmniLight3D] = []
var stalactites: int = 0
var stalagmites: int = 0
## The lowest point of any stalactite over the camera's corridor (tests: it stays over the lens).
var lowest_tip: float = INF


static func rock_material() -> Material:
	var painted: Material = PaintedTriplanar.material(ROCK_TEXTURE, 3.4, ROCK_FLAT, 0.25, ROCK_TINT)
	return painted if painted != null else M.flat(ROCK_FLAT)


static func build(parent: Node3D, low_end: bool = false) -> CapitalCrease:
	var crease: CapitalCrease = CapitalCrease.new()
	crease.root = Node3D.new()
	crease.root.name = "CreaseCavern"
	crease.root.set_meta(&"no_wind", true)
	parent.add_child(crease.root)
	var rock: Material = rock_material()
	var south: float = HALL.end.y + SOUTH_REACH
	var north: float = NORTH_Z - 2.0
	# the walls lean in as they rise (an overhang), so they meet the ceiling in a curve, not a corner
	var lean: Callable = func(_u: float, v: float) -> float: return 0.15 + 2.2 * v * v
	# the side walls stand straight to over head height and only curl in under the ceiling: the camera rides 2 m from them in the corners
	var side_lean: Callable = func(_u: float, v: float) -> float: return 5.0 * maxf(0.0, v - 0.68) * maxf(0.0, v - 0.68) * 4.0
	crease._sheet("WallNorth", rock, Vector3(WEST_X - 8.0, -0.6, NORTH_Z), Vector3(EAST_X - WEST_X + 16.0, 0, 0), Vector3(0, WALL_TOP + 0.6, 0), Vector3(0, 0, 1), 44, 12, 0.55, 11, lean)
	crease._sheet("WallWest", rock, Vector3(WEST_X, -0.6, south), Vector3(0, 0, north - south), Vector3(0, WALL_TOP + 0.6, 0), Vector3(1, 0, 0), 40, 12, 0.32, 23, side_lean)
	crease._sheet("WallEast", rock, Vector3(EAST_X, -0.6, north), Vector3(0, 0, south - north), Vector3(0, WALL_TOP + 0.6, 0), Vector3(-1, 0, 0), 40, 12, 0.32, 37, side_lean)
	crease._sheet("Ceiling", rock, Vector3(WEST_X - 8.0, CEILING_Y, north), Vector3(EAST_X - WEST_X + 16.0, 0, 0), Vector3(0, 0, south - north), Vector3(0, -1, 0), 34, 34, 0.7, 53, Callable())
	# the cavern's floor beyond the hall's south edge: bare rock a hand lower than the cobbles, running on under the camera
	var floor_rock: Material = PaintedTriplanar.material(ROCK_TEXTURE, 4.2, ROCK_FLAT, 0.25, Color(0.42, 0.4, 0.52))
	crease._sheet("FloorSouth", floor_rock if floor_rock != null else M.flat(ROCK_FLAT.darkened(0.3)), Vector3(WEST_X - 1.0, -0.015, HALL.end.y - 0.05), Vector3(EAST_X - WEST_X + 2.0, 0, 0), Vector3(0, 0, SOUTH_REACH + 0.05), Vector3(0, 1, 0), 24, 14, 0.05, 71, Callable())
	crease._spikes(rock, low_end)
	crease._puddles()
	if not low_end:
		crease._drips()
	crease._lanterns()
	crease._crystals()
	for node: Node in crease.root.find_children("*", "GeometryInstance3D", true, false):
		node.set_meta(&"no_occlusion_fade", true)
		node.set_meta(&"no_range_cull", true)
		node.set_meta(PaintedClasses.META_NO_PAINT, true)
	return crease


## A lumpy rock face: a `cols` x `rows` grid from `origin` along `u` and `v`, each vertex pushed out along `normal` by a seeded noise (up to
## `bulge` metres) plus `profile(u01, v01)`; smooth-shaded. The face shows toward `normal`.
func _sheet(piece_name: String, material: Material, origin: Vector3, u: Vector3, v: Vector3, normal: Vector3, cols: int, rows: int, bulge: float, seed_value: int, profile: Callable) -> MeshInstance3D:
	var noise: FastNoiseLite = FastNoiseLite.new()
	noise.seed = seed_value
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 0.16
	noise.fractal_octaves = 3
	var points: PackedVector3Array = PackedVector3Array()
	for row: int in range(rows + 1):
		for col: int in range(cols + 1):
			var fu: float = float(col) / float(cols)
			var fv: float = float(row) / float(rows)
			var base: Vector3 = origin + u * fu + v * fv
			var push: float = (noise.get_noise_3d(base.x, base.y * 1.4, base.z) * 0.5 + 0.5) * bulge
			if profile.is_valid():
				push += float(profile.call(fu, fv))
			points.append(base + normal * push)
	var tool: SurfaceTool = SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	tool.set_smooth_group(0)
	for point: Vector3 in points:
		tool.set_normal(normal)
		tool.add_vertex(point)
	# the winding that shows toward `normal`
	var flip: bool = (u.cross(v)).dot(normal) > 0.0
	for row: int in range(rows):
		for col: int in range(cols):
			var a: int = row * (cols + 1) + col
			var b: int = a + 1
			var c: int = a + cols + 1
			var d: int = c + 1
			for index: int in ([a, c, b, b, c, d] if flip else [a, b, c, b, d, c]):
				tool.add_index(index)
	tool.generate_normals()
	var body: MeshInstance3D = MeshInstance3D.new()
	body.name = piece_name
	body.mesh = tool.commit()
	body.material_override = material
	body.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# a single skin, drawn from its front only: a camera above the ceiling (the Raised city camera, the Overview angle) looks through it
	body.set_meta(&"one_sided", true)
	root.add_child(body)
	return body


## The shell is only there while the hero is in the Crease. The hideout lies 12 m south of the outskirts' south edge, so the camera that
## trails a hero standing there (Kestrel's spot, the camp) would otherwise sit behind the cavern's north wall.
func set_shown(shown: bool) -> void:
	if root != null and root.visible != shown:
		root.visible = shown


## Is (x, z) over the camera's corridor - anywhere the lens can stand or look across: the hall and the strip south of it?
static func in_camera_corridor(x: float, z: float) -> bool:
	return x > HALL.position.x + 1.5 and x < HALL.end.x - 1.5 and z > HALL.position.y + 5.0


## Stalactites under the ceiling and stalagmites at the walls' feet and along the hall's south edge, in one mesh.
func _spikes(material: Material, low_end: bool) -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 4141
	var tool: SurfaceTool = SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	tool.set_smooth_group(0)
	var south: float = HALL.end.y + SOUTH_REACH
	var wanted: int = 46 if low_end else 96
	var tries: int = 0
	while stalactites < wanted and tries < wanted * 6:
		tries += 1
		var x: float = rng.randf_range(WEST_X - 1.0, EAST_X + 1.0)
		var z: float = rng.randf_range(NORTH_Z + 0.4, south - 2.0)
		var corridor: bool = in_camera_corridor(x, z)
		# long ones hang along the north wall and the side walls; over the corridor they stay short, clear of the lens
		var length: float = rng.randf_range(0.35, 0.9) if corridor else rng.randf_range(1.1, 2.7)
		var tip: float = CEILING_Y + 0.25 - length
		_cone(tool, Vector3(x, CEILING_Y + 0.35, z), Vector3(x + rng.randf_range(-0.12, 0.12), tip, z + rng.randf_range(-0.12, 0.12)), length * rng.randf_range(0.16, 0.26) + 0.08, 7)
		stalactites += 1
		if corridor:
			lowest_tip = minf(lowest_tip, tip)
	for drip: Vector2 in DRIPS:
		# the dripping ones: a longer spike straight over its puddle (still above the lens)
		_cone(tool, Vector3(drip.x, CEILING_Y + 0.35, drip.y), Vector3(drip.x, CEILING_Y - 1.0, drip.y), 0.26, 7)
		lowest_tip = minf(lowest_tip, CEILING_Y - 1.0)
		stalactites += 1
	# stalagmites: the walls' feet (never where a chest, a sign or a door spot stands) ...
	for index: int in range(18 if low_end else 34):
		var side: int = index % 3
		var height: float = rng.randf_range(0.5, 1.7)
		var pos: Vector3 = Vector3.ZERO
		if side == 0:
			pos = Vector3(rng.randf_range(HALL.position.x + 2.0, HALL.end.x - 2.0), 0.0, NORTH_Z + rng.randf_range(0.5, 0.95))
			if absf(pos.x - 22.0) < 3.2 or absf(pos.x - 12.0) < 1.6 or absf(pos.x - 31.0) < 2.2:
				continue  # the banner, the rules sign, Fig's sign
		elif side == 1:
			pos = Vector3(WEST_X + rng.randf_range(0.45, 0.8), 0.0, rng.randf_range(HALL.position.y + 2.5, HALL.end.y + 12.0))
			if absf(pos.z - 146.0) < 2.4:
				continue  # the ladder
		else:
			pos = Vector3(EAST_X - rng.randf_range(0.45, 0.8), 0.0, rng.randf_range(HALL.position.y + 2.5, HALL.end.y + 12.0))
			if absf(pos.z - 148.0) < 2.6:
				continue  # the tunnel's mouth
		_cone(tool, pos + Vector3(0, -0.1, 0), pos + Vector3(rng.randf_range(-0.1, 0.1), height, rng.randf_range(-0.1, 0.1)), height * 0.22 + 0.12, 7)
		stalagmites += 1
	# ... and a low broken row along the hall's south edge: the boundary the hero stops at, never tall enough to hide the hero's feet
	var x: float = HALL.position.x + 0.4
	while x < HALL.end.x:
		var height: float = rng.randf_range(0.22, 0.62)
		var z: float = HALL.end.y + rng.randf_range(0.35, 1.3)
		_cone(tool, Vector3(x, -0.12, z), Vector3(x + rng.randf_range(-0.08, 0.08), height, z), height * 0.45 + 0.14, 6)
		stalagmites += 1
		x += rng.randf_range(0.7, 1.5)
	tool.generate_normals()
	var body: MeshInstance3D = MeshInstance3D.new()
	body.name = "Spikes"
	body.mesh = tool.commit()
	body.material_override = material
	body.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(body)


## A cone from a round base at `base` to a point at `tip`.
static func _cone(tool: SurfaceTool, base: Vector3, tip: Vector3, radius: float, segments: int) -> void:
	var axis: Vector3 = (tip - base).normalized()
	var side: Vector3 = axis.cross(Vector3(1, 0, 0) if absf(axis.x) < 0.9 else Vector3(0, 0, 1)).normalized()
	var other: Vector3 = axis.cross(side).normalized()
	for index: int in range(segments):
		var a0: float = TAU * float(index) / float(segments)
		var a1: float = TAU * float(index + 1) / float(segments)
		var p0: Vector3 = base + (side * cos(a0) + other * sin(a0)) * radius
		var p1: Vector3 = base + (side * cos(a1) + other * sin(a1)) * radius
		var normal: Vector3 = (p1 - p0).cross(tip - p0).normalized()
		var outward: Vector3 = ((p0 + p1) * 0.5 - base).normalized()
		var order: Array[Vector3] = [p0, p1, tip]
		if normal.dot(outward) <= 0.0:
			order = [p1, p0, tip]
		for point: Vector3 in order:
			tool.set_normal(outward)
			tool.add_vertex(point)


## Still water on the stone: dark, glossy, a little see-through; irregular outlines.
func _puddles() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 5252
	var tool: SurfaceTool = SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	for index: int in range(PUDDLES.size()):
		var puddle: Vector3 = PUDDLES[index]
		var center: Vector3 = Vector3(puddle.x, 0.035 + 0.001 * float(index), puddle.y)
		var ring: Array[Vector3] = []
		for step: int in range(14):
			var angle: float = TAU * float(step) / 14.0
			var reach: float = puddle.z * rng.randf_range(0.62, 1.0)
			ring.append(center + Vector3(cos(angle) * reach * 1.25, 0.0, sin(angle) * reach * 0.8))
		for step: int in range(14):
			for point: Vector3 in [center, ring[(step + 1) % 14], ring[step]]:
				tool.set_normal(Vector3.UP)
				tool.add_vertex(point)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(0.1, 0.13, 0.22, 0.62)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.metallic = 0.55
	material.roughness = 0.06
	material.emission_enabled = true
	material.emission = Color(0.1, 0.14, 0.26)
	material.emission_energy_multiplier = 0.35
	var body: MeshInstance3D = MeshInstance3D.new()
	body.name = "Puddles"
	body.mesh = tool.commit()
	body.material_override = material
	body.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	body.set_meta(StyleToon.META_NO_TOON, true)
	root.add_child(body)


## A drop now and then from the dripping stalactites into the puddle under each.
func _drips() -> void:
	var drop: SphereMesh = SphereMesh.new()
	drop.radius = 0.035
	drop.height = 0.12
	drop.radial_segments = 6
	drop.rings = 3
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(0.72, 0.86, 1.0, 0.9)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	drop.material = material
	for index: int in range(DRIPS.size()):
		var drip: Vector2 = DRIPS[index]
		var particles: CPUParticles3D = CPUParticles3D.new()
		particles.name = "Drip%d" % index
		particles.mesh = drop
		particles.amount = 1
		particles.lifetime = 1.15
		particles.preprocess = float(index) * 0.37
		particles.explosiveness = 0.0
		particles.randomness = 0.6
		particles.direction = Vector3.DOWN
		particles.spread = 0.0
		particles.initial_velocity_min = 0.0
		particles.initial_velocity_max = 0.2
		particles.gravity = Vector3(0, -9.2, 0)
		particles.position = Vector3(drip.x, CEILING_Y - 1.05, drip.y)
		particles.visibility_aabb = AABB(Vector3(-0.5, -CEILING_Y, -0.5), Vector3(1.0, CEILING_Y + 0.5, 1.0))
		particles.set_meta(StyleToon.META_NO_TOON, true)
		root.add_child(particles)


## Fable Nov 12d (critic 3): the lantern glass was a plain box glowing at 2.2, which bloomed into a flat cream rectangle hanging in the
## air. It is a small tapered six-sided glass in a deeper amber now, dim enough to keep its colour, between a dark cap and foot.
const LANTERN_GLASS: Color = Color("f08a2c")


func _lantern_glass() -> CylinderMesh:
	var glass: CylinderMesh = CylinderMesh.new()
	glass.top_radius = 0.07
	glass.bottom_radius = 0.11
	glass.height = 0.28
	glass.radial_segments = 6
	glass.rings = 1
	return glass


## A lantern on a chain from the ceiling with its warm pool on the floor.
func _lanterns() -> void:
	var holder: Node3D = Node3D.new()
	holder.name = "Lanterns"
	root.add_child(holder)
	for spot: Vector3 in LANTERNS:
		var at: Vector3 = Vector3(spot.x, spot.z, spot.y)
		var chain: MeshInstance3D = MeshInstance3D.new()
		var link: BoxMesh = BoxMesh.new()
		link.size = Vector3(0.03, CEILING_Y - at.y, 0.03)
		chain.mesh = link
		chain.material_override = M.flat(Color(0.12, 0.1, 0.1))
		chain.position = Vector3(at.x, (CEILING_Y + at.y) * 0.5 + 0.15, at.z)
		holder.add_child(chain)
		var cage: MeshInstance3D = MeshInstance3D.new()
		var cage_mesh: BoxMesh = BoxMesh.new()
		cage_mesh.size = Vector3(0.3, 0.06, 0.3)
		cage.mesh = cage_mesh
		cage.material_override = M.flat(Color(0.16, 0.13, 0.1))
		cage.position = at + Vector3(0, 0.22, 0)
		holder.add_child(cage)
		var glass: MeshInstance3D = MeshInstance3D.new()
		glass.mesh = _lantern_glass()
		glass.material_override = M.glow(LANTERN_GLASS, 1.25)
		glass.position = at
		var foot: MeshInstance3D = MeshInstance3D.new()
		foot.mesh = cage_mesh
		foot.material_override = cage.material_override
		foot.position = at + Vector3(0, -0.17, 0)
		foot.scale = Vector3(0.7, 1.0, 0.7)
		holder.add_child(foot)
		glass.set_meta(StyleToon.META_NO_TOON, true)
		holder.add_child(glass)
		_light(at + Vector3(0, -0.1, 0.25), WARM, 1.3, 8.0)
		GroundDecals.glow(root, Vector3(at.x, 0.045, at.z), 2.8, WARM, 0.28)
	for spot: Vector3 in WALL_LANTERNS:
		var on_wall: Vector3 = Vector3(spot.x, spot.z, spot.y)
		var inward: float = 1.0 if spot.x < 20.0 else -1.0
		var bracket: MeshInstance3D = MeshInstance3D.new()
		var arm: BoxMesh = BoxMesh.new()
		arm.size = Vector3(0.5, 0.05, 0.05)
		bracket.mesh = arm
		bracket.material_override = M.flat(Color(0.14, 0.11, 0.1))
		bracket.position = on_wall + Vector3(-inward * 0.1, 0.25, 0.0)
		holder.add_child(bracket)
		var lamp: MeshInstance3D = MeshInstance3D.new()
		lamp.mesh = _lantern_glass()
		lamp.material_override = M.glow(LANTERN_GLASS, 1.25)
		lamp.position = on_wall + Vector3(inward * 0.12, 0.0, 0.0)
		lamp.set_meta(StyleToon.META_NO_TOON, true)
		holder.add_child(lamp)
		_light(on_wall + Vector3(inward * 0.5, 0.0, 0.0), WARM, 1.2, 7.5)
		GroundDecals.glow(root, Vector3(on_wall.x + inward * 1.0, 0.045, on_wall.z), 2.4, WARM, 0.26)


## Crystals growing out of the rock at the walls' feet, each with a cool glow.
func _crystals() -> void:
	var holder: Node3D = Node3D.new()
	holder.name = "Crystals"
	root.add_child(holder)
	for crystal: Vector4 in CRYSTALS:
		var color: Color = CYAN if crystal.w > 0.5 else VIOLET
		K.tree_card(holder, "CAP-PLANT-CRYSTAL", Vector3(crystal.x, -0.05, crystal.y), crystal.z)
		K.tree_card(holder, "CAP-PLANT-CRYSTAL", Vector3(crystal.x + 0.7, -0.05, crystal.y + 0.3), crystal.z * 0.55)
		_light(Vector3(crystal.x, crystal.z * 0.6, crystal.y + 0.5), color, 1.0, 5.5)
		GroundDecals.glow(root, Vector3(crystal.x, 0.05, crystal.y + 0.4), 2.0, color, 0.22)


func _light(at: Vector3, color: Color, energy: float, reach: float) -> void:
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = color
	light.light_energy = energy
	light.omni_range = reach
	light.omni_attenuation = 1.3
	light.shadow_enabled = false
	light.position = at
	root.add_child(light)
	lights.append(light)
