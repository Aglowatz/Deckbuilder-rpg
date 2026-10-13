class_name PropKit
extends RefCounted
## The prop kit (vertical slice, Part B): small, well-proportioned props built in code from `KitMesh` with material slots from the Environment Kit (ENV-PROP-*). Silhouettes are
## smoothed (lathed barrels and pots with 14+ sides, bevelled boxes) so nothing reads as a raw primitive. Every prop is one MeshInstance3D under a Node3D that carries
## meta: "radius" (a circle for the town's obstacle list; 0 = walk-through), "lights" (warm point lights for `KitLights.attach`) and "triangles".
##
## Scale: the hero is 1.25 m. A barrel is about 1.1 m (reaches the hero's chest), a crate 0.9 m, a lamp post 4.2 m, a bench seat 0.55 m, a fence 1.0 m.

const NAMES: Array[String] = [
	"barrel", "crate", "crate_small", "sack", "flowerpot", "planter", "bench", "well", "lantern_post", "banner_post", "stall", "cart", "fence_picket", "fence_rail", "hedge",
	"stone_wall", "signpost", "notice_board", "hanging_lantern", "bush",
]
const LANTERN: Color = Color("ffb45a")


## Builds the prop `prop_name` (one of NAMES); `length` is used by the fences, hedges, walls and planters; `seed_value` varies colours slightly.
static func make(prop_name: String, length: float = 3.2, seed_value: int = 0) -> Node3D:
	match prop_name:
		"barrel":
			return barrel(seed_value)
		"crate":
			return crate(1.0, seed_value)
		"crate_small":
			return crate(0.66, seed_value)
		"sack":
			return sack(seed_value)
		"flowerpot":
			return flowerpot(seed_value)
		"planter":
			return planter(length if length < 3.0 else 1.6, seed_value)
		"bench":
			return bench()
		"well":
			return well()
		"lantern_post":
			return lantern_post()
		"banner_post":
			return lantern_post(true)
		"stall":
			return stall(seed_value)
		"cart":
			return cart(seed_value)
		"fence_picket":
			return fence(length, true)
		"fence_rail":
			return fence(length, false)
		"hedge":
			return hedge(length)
		"stone_wall":
			return stone_wall(length)
		"signpost":
			return signpost()
		"notice_board":
			return notice_board()
		"hanging_lantern":
			return hanging_lantern()
		"bush":
			return bush(seed_value)
	return null


static func _finish(mesh: KitMesh, node_name: String, radius: float, lights: Array[Dictionary] = []) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = node_name
	var body: MeshInstance3D = mesh.instance("Body")
	body.set_meta(PaintedClasses.META_NO_PAINT, true)
	# Small props (under 2 m) never hide the hero and are not worth a per-frame look by the occlusion fader; the tall ones (lamp posts, stalls, boards) still dissolve.
	if body.mesh.get_aabb().size.y < 2.0:
		body.set_meta("no_occlusion_fade", true)
		body.set_meta("kit_static", true)
	else:
		body.set_meta("occlusion_near", 1.2)
	root.add_child(body)
	root.set_meta("radius", radius)
	root.set_meta("lights", lights)
	root.set_meta("triangles", mesh.triangle_count())
	return root


static func _rng(seed_value: int) -> RandomNumberGenerator:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 9100 + seed_value
	return rng


const SOIL: Color = Color("503824")
const LEAF: Color = Color("4f8f3c")
const BLOOM_COLORS: Array[Color] = [Color("e0483a"), Color("f0c03a"), Color("e87aa8"), Color("f4efe0"), Color("9a6ad8")]


# ---- barrel, crate, sack, pots -----------------------------------------------------------------------------------------------------------


static func barrel(seed_value: int = 0) -> Node3D:
	var mesh: KitMesh = KitMesh.new()
	mesh.set_material("wood", EnvKit.fitted("ENV-PROP-BARREL", Color(1.0 - 0.04 * float(seed_value % 3), 1.0, 1.0)))
	mesh.set_material("iron", EnvKit.flat(Color("3b3530"), "iron"))
	var profile: Array[Vector2] = [Vector2(0.34, 0.0), Vector2(0.4, 0.1), Vector2(0.46, 0.38), Vector2(0.48, 0.55), Vector2(0.46, 0.72), Vector2(0.4, 1.0), Vector2(0.37, 1.1), Vector2(0.33, 1.1), Vector2(0.0, 1.07)]
	mesh.lathe("wood", Vector3.ZERO, profile, 16, 0.7, false, true, Color.WHITE, EnvKit.has_art("ENV-PROP-BARREL"))
	for hoop: float in ([] if EnvKit.has_art("ENV-PROP-BARREL") else [0.16, 0.38, 0.72, 0.94]):
		var r: float = 0.4 + 0.08 * sin(clampf(hoop, 0.0, 1.0) * PI) + 0.012
		var band: Array[Vector2] = [Vector2(r, hoop - 0.03), Vector2(r + 0.025, hoop - 0.025), Vector2(r + 0.025, hoop + 0.025), Vector2(r, hoop + 0.03)]
		mesh.lathe("iron", Vector3.ZERO, band, 16, 1.0, false, false)
	return _finish(mesh, "Barrel", 0.45)


static func crate(size: float = 1.0, seed_value: int = 0) -> Node3D:
	var mesh: KitMesh = KitMesh.new()
	mesh.set_material("wood", EnvKit.fitted("ENV-PROP-CRATE", Color(1.0 - 0.05 * float(seed_value % 3), 1.0, 1.0)))
	mesh.set_material("trim", EnvKit.material("ENV-BEAM"))
	var s: float = 0.9 * size
	var painted_crate: bool = EnvKit.has_art("ENV-PROP-CRATE")
	mesh.box("wood", Vector3(0, s * 0.5, 0), Vector3(s, s, s), Basis.IDENTITY, 0.045 * size, 0.7, painted_crate)
	if painted_crate:
		return _finish(mesh, "Crate", s * 0.6)
	var edge: float = 0.1 * size
	for sx: float in [-1.0, 1.0]:
		for sz: float in [-1.0, 1.0]:
			mesh.box("trim", Vector3(sx * (s * 0.5 - edge * 0.4), s * 0.5, sz * (s * 0.5 - edge * 0.4)), Vector3(edge, s + 0.02, edge), Basis.IDENTITY, 0.02)
	for y: float in [0.22, 0.78]:
		for side: float in [-1.0, 1.0]:
			mesh.box("trim", Vector3(0, s * y, side * (s * 0.5 + 0.005)), Vector3(s, edge * 0.8, 0.03), Basis.IDENTITY, 0.01)
			mesh.box("trim", Vector3(side * (s * 0.5 + 0.005), s * y, 0), Vector3(0.03, edge * 0.8, s), Basis.IDENTITY, 0.01)
	return _finish(mesh, "Crate", s * 0.6)


static func sack(seed_value: int = 0) -> Node3D:
	var mesh: KitMesh = KitMesh.new()
	var tints: Array[Color] = [Color(1, 1, 1), Color(0.92, 0.88, 0.8), Color(1.0, 0.94, 0.86)]
	mesh.set_material("cloth", EnvKit.material("ENV-PROP-SACK", false, tints[seed_value % 3]))
	mesh.set_material("rope", EnvKit.flat(Color("6b5030"), "rope"))
	var profile: Array[Vector2] = [Vector2(0.0, 0.0), Vector2(0.28, 0.03), Vector2(0.4, 0.18), Vector2(0.42, 0.34), Vector2(0.34, 0.52), Vector2(0.18, 0.66), Vector2(0.1, 0.74), Vector2(0.15, 0.82), Vector2(0.22, 0.9), Vector2(0.1, 0.88), Vector2(0.0, 0.85)]
	mesh.lathe("cloth", Vector3.ZERO, profile, 12, 0.72)
	var tie: Array[Vector2] = [Vector2(0.105, 0.7), Vector2(0.125, 0.71), Vector2(0.125, 0.76), Vector2(0.105, 0.77)]
	mesh.lathe("rope", Vector3.ZERO, tie, 10, 1.0, false, false)
	var node: Node3D = _finish(mesh, "Sack", 0.4)
	node.rotation_degrees.y = float(seed_value * 47 % 360)
	return node


static func flowerpot(seed_value: int = 0) -> Node3D:
	var mesh: KitMesh = KitMesh.new()
	mesh.set_material("pot", EnvKit.material("ENV-PROP-FLOWERPOTS"))
	# one white slot, coloured per vertex: soil, leaves and every bloom are one draw call
	mesh.set_material("plant", EnvKit.flat(Color.WHITE, "plant"))
	var rng: RandomNumberGenerator = _rng(seed_value)
	var profile: Array[Vector2] = [Vector2(0.0, 0.0), Vector2(0.14, 0.0), Vector2(0.17, 0.04), Vector2(0.27, 0.36), Vector2(0.3, 0.4), Vector2(0.3, 0.47), Vector2(0.25, 0.47)]
	mesh.lathe("pot", Vector3.ZERO, profile, 14, 0.75)
	mesh.lathe("plant", Vector3.ZERO, [Vector2(0.25, 0.43), Vector2(0.25, 0.44)], 12, 1.0, false, true, SOIL)
	mesh.blob("plant", Vector3(0, 0.5, 0), Vector3(0.34, 0.22, 0.34), 4, 10, 1.0, LEAF)
	for index: int in range(7):
		var a: float = rng.randf() * TAU
		var r: float = rng.randf_range(0.0, 0.22)
		mesh.blob("plant", Vector3(cos(a) * r, 0.62 + rng.randf() * 0.16, sin(a) * r), Vector3(0.1, 0.09, 0.1), 4, 9, 1.0, BLOOM_COLORS[rng.randi() % BLOOM_COLORS.size()])
	return _finish(mesh, "Pot", 0.0)


## A long planter box brimming with flowers.
static func planter(length: float = 1.6, seed_value: int = 0) -> Node3D:
	var mesh: KitMesh = KitMesh.new()
	mesh.set_material("wood", EnvKit.material("ENV-PROP-FENCE"))
	mesh.set_material("plant", EnvKit.flat(Color.WHITE, "plant"))
	var rng: RandomNumberGenerator = _rng(seed_value + 40)
	mesh.box("wood", Vector3(0, 0.22, 0), Vector3(length, 0.44, 0.6), Basis.IDENTITY, 0.04, 0.7)
	var count: int = maxi(3, int(length / 0.34))
	for index: int in range(count):
		var x: float = -length * 0.5 + 0.2 + (length - 0.4) * float(index) / float(maxi(count - 1, 1))
		mesh.blob("plant", Vector3(x, 0.52, rng.randf_range(-0.1, 0.1)), Vector3(0.24, 0.2, 0.24), 4, 9, 1.0, LEAF)
		mesh.blob("plant", Vector3(x + rng.randf_range(-0.05, 0.05), 0.66, rng.randf_range(-0.12, 0.12)), Vector3(0.16, 0.13, 0.16), 4, 9, 1.0, BLOOM_COLORS[rng.randi() % BLOOM_COLORS.size()])
	return _finish(mesh, "Trough", 0.0)


# ---- bench, well, lanterns, signs -----------------------------------------------------------------------------------------------------


static func bench() -> Node3D:
	var mesh: KitMesh = KitMesh.new()
	mesh.set_material("wood", EnvKit.material("ENV-PROP-FENCE", false, Color(0.95, 0.9, 0.85)))
	mesh.box("wood", Vector3(0, 0.52, 0), Vector3(1.9, 0.1, 0.55), Basis.IDENTITY, 0.03)
	mesh.box("wood", Vector3(0, 0.95, -0.27), Vector3(1.9, 0.42, 0.07), Basis.IDENTITY, 0.025)
	for side: float in [-0.8, 0.8]:
		mesh.box("wood", Vector3(side, 0.26, 0), Vector3(0.1, 0.52, 0.5), Basis.IDENTITY, 0.025, 0.75)
		mesh.box("wood", Vector3(side, 0.78, -0.26), Vector3(0.1, 0.9, 0.08), Basis.IDENTITY, 0.025)
	return _finish(mesh, "Bench", 0.0)


## The village well after the concept (ENV-PROP-WELL): a fat round fieldstone curb with a mossy lip, two timber posts, a crank on one side, a small red-tiled gable with an
## overhang and a bucket on the rope. Textured with the kit surfaces (foundation stone, plank, red tile); the concept image itself is only the reference.
static func well() -> Node3D:
	var mesh: KitMesh = KitMesh.new()
	mesh.set_material("stone", EnvKit.material("ENV-WALL-FOUNDATION"))
	mesh.set_material("wood", EnvKit.material("ENV-WALL-PLANK", false, Color(0.92, 0.86, 0.8)))
	mesh.set_material("beam", EnvKit.material("ENV-BEAM"))
	mesh.set_material("roof", EnvKit.material("ENV-ROOF-TILE-RED"))
	mesh.set_material("water", EnvKit.glow(Color("5fb8dc"), 0.5))
	mesh.set_material("rope", EnvKit.flat(Color("6b5030"), "rope"))
	mesh.set_material("iron", EnvKit.flat(Color("3b3530"), "iron"))
	mesh.set_material("moss", EnvKit.flat(Color("5f8f3c"), "moss"))
	# the curb: a belly that swells below a thick flat lip
	var ring: Array[Vector2] = [Vector2(1.08, 0.0), Vector2(1.18, 0.1), Vector2(1.2, 0.55), Vector2(1.14, 0.88), Vector2(1.24, 0.94), Vector2(1.24, 1.06), Vector2(0.82, 1.06), Vector2(0.82, 0.4)]
	mesh.lathe("stone", Vector3.ZERO, ring, 20, 0.7, false, false)
	mesh.lathe("water", Vector3(0, 0.62, 0), [Vector2(0.8, 0.0), Vector2(0.8, 0.01)], 14, 1.0, false, true)
	mesh.blob("moss", Vector3(0.7, 0.16, 1.05), Vector3(0.34, 0.12, 0.2), 3, 8)
	mesh.blob("moss", Vector3(-0.95, 0.12, -0.6), Vector3(0.3, 0.1, 0.22), 3, 8)
	# posts, cross beam, roof
	for side: float in [-1.0, 1.0]:
		mesh.box("beam", Vector3(side * 0.98, 1.8, 0), Vector3(0.2, 1.6, 0.2), Basis.IDENTITY, 0.03)
		mesh.box("beam", Vector3(side * 0.98, 1.16, 0), Vector3(0.34, 0.14, 0.34), Basis.IDENTITY, 0.02)
	mesh.box("beam", Vector3(0, 2.5, 0), Vector3(2.4, 0.22, 0.24), Basis.IDENTITY, 0.04)
	mesh.tube("wood", Vector3(-0.3, 2.05, 0), Vector3(0.3, 2.05, 0), 0.1, 8)
	# crank
	mesh.tube("iron", Vector3(0.3, 2.05, 0), Vector3(1.28, 2.05, 0), 0.04, 6, true)
	mesh.tube("iron", Vector3(1.28, 2.05, 0), Vector3(1.28, 1.6, 0), 0.04, 6, true)
	mesh.box("wood", Vector3(1.28, 1.52, 0), Vector3(0.1, 0.16, 0.1), Basis.IDENTITY, 0.02)
	var roof_y: float = 2.62
	var half_depth: float = 1.15
	var half_width: float = 1.55
	var peak: float = 3.55
	for side: float in [-1.0, 1.0]:
		mesh.quad("roof", [Vector3(-half_width, roof_y, side * half_depth), Vector3(half_width, roof_y, side * half_depth), Vector3(half_width - 0.1, peak, 0), Vector3(-half_width + 0.1, peak, 0)], Vector3(0, 0.75, side * 0.7))
		mesh.box("beam", Vector3(0, roof_y - 0.04, side * half_depth), Vector3(half_width * 2.0 + 0.06, 0.12, 0.1), Basis.IDENTITY, 0.02)
	for end: float in [-1.0, 1.0]:
		mesh.tri("wood", [Vector3(end * (half_width - 0.2), roof_y, half_depth - 0.2), Vector3(end * (half_width - 0.2), roof_y, -half_depth + 0.2), Vector3(end * (half_width - 0.2), peak - 0.15, 0)], Vector3(end, 0, 0))
	mesh.box("beam", Vector3(0, peak + 0.04, 0), Vector3(half_width * 2.0, 0.14, 0.18), Basis.IDENTITY, 0.03)
	# rope and bucket
	mesh.tube("rope", Vector3(0, 2.05, 0.0), Vector3(0, 1.45, 0.0), 0.02, 4, false)
	mesh.lathe("wood", Vector3(0, 1.1, 0), [Vector2(0.17, 0.0), Vector2(0.22, 0.04), Vector2(0.24, 0.32), Vector2(0.2, 0.32)], 10, 1.0, true, false)
	return _finish(mesh, "Well", 1.3)


## A tall post with a hanging lantern (a real warm light) and, optionally, a banner on a cross arm like the paint-over's.
static func lantern_post(with_banner: bool = false) -> Node3D:
	var mesh: KitMesh = KitMesh.new()
	mesh.set_material("wood", EnvKit.material("ENV-BEAM", false, Color(0.9, 0.82, 0.74)))
	mesh.set_material("iron", EnvKit.flat(Color("3a332e"), "iron"))
	mesh.set_material("glass", EnvKit.glow(LANTERN, 2.0))
	mesh.set_material("banner", EnvKit.flat(Color("c4503c"), "banner_red"))
	mesh.set_material("banner_trim", EnvKit.flat(Color("e8b53a"), "banner_gold"))
	mesh.lathe("wood", Vector3.ZERO, [Vector2(0.24, 0.0), Vector2(0.24, 0.5), Vector2(0.14, 0.62), Vector2(0.12, 1.0)], 10, 0.7, true, false)
	mesh.tube("wood", Vector3(0, 0.95, 0), Vector3(0, 4.1, 0), 0.1, 8, true)
	mesh.box("wood", Vector3(0.38, 4.0, 0), Vector3(0.9, 0.12, 0.12), Basis.IDENTITY, 0.02)
	mesh.tube("wood", Vector3(0.08, 3.55, 0), Vector3(0.62, 3.98, 0), 0.05, 6, false)
	var lamp: Vector3 = Vector3(0.7, 3.5, 0)
	mesh.tube("iron", Vector3(0.7, 3.98, 0), lamp + Vector3(0, 0.45, 0), 0.025, 4, false)
	mesh.box("iron", lamp + Vector3(0, 0.42, 0), Vector3(0.42, 0.08, 0.42), Basis.IDENTITY, 0.03)
	mesh.box("glass", lamp, Vector3(0.3, 0.6, 0.3), Basis.IDENTITY, 0.05)
	for sx: float in [-1.0, 1.0]:
		for sz: float in [-1.0, 1.0]:
			mesh.box("iron", lamp + Vector3(sx * 0.16, 0.0, sz * 0.16), Vector3(0.04, 0.64, 0.04), Basis.IDENTITY, 0.0)
	mesh.box("iron", lamp + Vector3(0, -0.34, 0), Vector3(0.34, 0.07, 0.34), Basis.IDENTITY, 0.02)
	if with_banner:
		mesh.box("wood", Vector3(0, 3.2, 0.0), Vector3(0.1, 0.1, 1.0), Basis.IDENTITY, 0.015)
		for face: float in [-1.0, 1.0]:
			var x: float = 0.03 * face
			mesh.quad("banner", [Vector3(x, 3.15, -0.38), Vector3(x, 3.15, 0.38), Vector3(x, 1.9, 0.34), Vector3(x, 1.9, -0.34)], Vector3(face, 0, 0))
			mesh.tri("banner", [Vector3(x, 1.9, -0.34), Vector3(x, 1.9, 0.34), Vector3(x, 1.55, 0.0)], Vector3(face, 0, 0))
			mesh.quad("banner_trim", [Vector3(x * 1.4, 2.75, -0.2), Vector3(x * 1.4, 2.75, 0.2), Vector3(x * 1.4, 2.35, 0.18), Vector3(x * 1.4, 2.35, -0.18)], Vector3(face, 0, 0))
	var lights: Array[Dictionary] = [{"pos": lamp + Vector3(0, -0.1, 0), "color": LANTERN, "range": 7.5, "energy": 2.2, "kind": "lantern"}]
	var node: Node3D = _finish(mesh, "LanternPost", 0.26, lights)
	node.set_meta("glow_point", lamp)
	return node


static func hanging_lantern() -> Node3D:
	var mesh: KitMesh = KitMesh.new()
	mesh.set_material("iron", EnvKit.flat(Color("3a332e"), "iron"))
	mesh.set_material("glass", EnvKit.glow(LANTERN, 2.0))
	mesh.box("iron", Vector3(0, 0.3, 0), Vector3(0.36, 0.07, 0.36), Basis.IDENTITY, 0.03)
	mesh.box("glass", Vector3(0, 0.0, 0), Vector3(0.26, 0.5, 0.26), Basis.IDENTITY, 0.04)
	mesh.box("iron", Vector3(0, -0.29, 0), Vector3(0.3, 0.06, 0.3), Basis.IDENTITY, 0.02)
	mesh.tube("iron", Vector3(0, 0.33, 0), Vector3(0, 0.7, 0), 0.015, 4, false)
	var lights: Array[Dictionary] = [{"pos": Vector3(0, 0, 0), "color": LANTERN, "range": 5.0, "energy": 1.4, "kind": "lantern"}]
	return _finish(mesh, "HangingLantern", 0.0, lights)


## A signpost whose boards carry the Path crest and an arrow tip (no text): `directions` are the yaw angles (degrees, 0 = +z, 90 = +x) the boards point to.
static func signpost(directions: Array[float] = [90.0, -60.0]) -> Node3D:
	var mesh: KitMesh = KitMesh.new()
	if EnvKit.has_art("ENV-SIGNPOST"):
		# the painted signpost (Path symbols on arrow boards, no text) as two crossed cards, post base on the origin
		mesh.set_material("card", EnvKit.material("ENV-SIGNPOST", true))
		var post_h: float = 2.5
		var post_w: float = post_h * EnvKit.aspect("ENV-SIGNPOST")
		var shift: float = (0.5 - EnvKit.pivot("ENV-SIGNPOST").x) * post_w
		mesh.quad("card", [Vector3(shift - post_w * 0.5, 0, 0), Vector3(shift + post_w * 0.5, 0, 0), Vector3(shift + post_w * 0.5, post_h, 0), Vector3(shift - post_w * 0.5, post_h, 0)], Vector3(0, 0, 1), [], [Vector2(0, 1), Vector2(1, 1), Vector2(1, 0), Vector2(0, 0)])
		mesh.quad("card", [Vector3(0, 0, shift - post_w * 0.5), Vector3(0, 0, shift + post_w * 0.5), Vector3(0, post_h, shift + post_w * 0.5), Vector3(0, post_h, shift - post_w * 0.5)], Vector3(1, 0, 0), [], [Vector2(0, 1), Vector2(1, 1), Vector2(1, 0), Vector2(0, 0)])
		return _finish(mesh, "Signpost", 0.2)
	mesh.set_material("wood", EnvKit.material("ENV-BEAM", false, Color(0.92, 0.84, 0.76)))
	mesh.set_material("board", EnvKit.material("ENV-WALL-PLANK", false, Color(1.0, 0.92, 0.8)))
	mesh.set_material("icon", EnvKit.material("ENV-SIGNPOST", true))
	mesh.tube("wood", Vector3(0, 0, 0), Vector3(0, 3.0, 0), 0.1, 8, true)
	mesh.lathe("wood", Vector3.ZERO, [Vector2(0.22, 0.0), Vector2(0.2, 0.25), Vector2(0.12, 0.3)], 10, 0.7, true, false)
	var y: float = 2.65
	for index: int in range(directions.size()):
		var angle: float = deg_to_rad(directions[index])
		var dir: Vector3 = Vector3(sin(angle), 0, cos(angle))
		var n: Vector3 = dir.cross(Vector3.UP)
		var board_y: float = y - 0.55 * float(index)
		mesh.box("board", Vector3(0, board_y, 0) + dir * 0.65, Vector3(1.3, 0.38, 0.07), Basis(dir, Vector3.UP, n), 0.02)
		var tip: Vector3 = Vector3(0, board_y, 0) + dir * 1.3
		mesh.tri("board", [tip + Vector3(0, 0.19, 0), tip + Vector3(0, -0.19, 0), tip + dir * 0.3], n)
		mesh.tri("board", [tip + Vector3(0, 0.19, 0), tip + Vector3(0, -0.19, 0), tip + dir * 0.3], -n)
		var crest_center: Vector3 = Vector3(0, board_y, 0) + dir * 0.5
		var half: float = 0.2
		for face: float in [-1.0, 1.0]:
			var out: Vector3 = n * face * 0.045
			mesh.quad("icon", [crest_center - dir * half - Vector3(0, half, 0) + out, crest_center + dir * half - Vector3(0, half, 0) + out, crest_center + dir * half + Vector3(0, half, 0) + out, crest_center - dir * half + Vector3(0, half, 0) + out], n * face, [], [Vector2(0, 1), Vector2(1, 1), Vector2(1, 0), Vector2(0, 0)])
	return _finish(mesh, "Signpost", 0.2)


## The notice board (opens the quest log): two posts, a roofed board, pinned papers; no lettering.
static func notice_board() -> Node3D:
	var mesh: KitMesh = KitMesh.new()
	mesh.set_material("wood", EnvKit.material("ENV-BEAM", false, Color(0.92, 0.84, 0.76)))
	mesh.set_material("board", EnvKit.material("ENV-WALL-PLANK"))
	mesh.set_material("paper", EnvKit.flat(Color("f2e8c8"), "paper"))
	mesh.set_material("paper_b", EnvKit.flat(Color("e8d0a0"), "paper_b"))
	mesh.set_material("roof", EnvKit.material("ENV-ROOF-TILE-RED"))
	for side: float in [-1.0, 1.0]:
		mesh.box("wood", Vector3(side * 1.05, 1.5, 0), Vector3(0.2, 3.0, 0.2), Basis.IDENTITY, 0.04)
	mesh.box("board", Vector3(0, 1.85, 0.04), Vector3(2.0, 1.5, 0.12), Basis.IDENTITY, 0.03)
	mesh.box("wood", Vector3(0, 2.8, 0), Vector3(2.5, 0.2, 0.4), Basis.IDENTITY, 0.04)
	mesh.quad("roof", [Vector3(-1.4, 2.78, 0.55), Vector3(1.4, 2.78, 0.55), Vector3(1.4, 3.3, 0.0), Vector3(-1.4, 3.3, 0.0)], Vector3(0, 0.6, 0.8))
	mesh.quad("roof", [Vector3(-1.4, 2.78, -0.55), Vector3(1.4, 2.78, -0.55), Vector3(1.4, 3.3, 0.0), Vector3(-1.4, 3.3, 0.0)], Vector3(0, 0.6, -0.8))
	for index: int in range(6):
		var x: float = -0.75 + 0.3 * float(index)
		var y: float = 1.8 + 0.28 * float((index * 3) % 3 - 1)
		mesh.quad("paper" if index % 2 == 0 else "paper_b", [Vector3(x - 0.12, y - 0.17, 0.11), Vector3(x + 0.12, y - 0.15, 0.11), Vector3(x + 0.12, y + 0.17, 0.11), Vector3(x - 0.12, y + 0.16, 0.11)], Vector3(0, 0, 1))
	return _finish(mesh, "NoticeBoard", 1.1)


# ---- fences, hedges, low walls, bushes ---------------------------------------------------------------------------------------------------------


## A fence run along +x of `length` metres: posts about every 1.4 m, two rails and (picket) pointed pickets.
static func fence(length: float, picket: bool) -> Node3D:
	var mesh: KitMesh = KitMesh.new()
	var id: String = "ENV-PROP-FENCE" if picket else "ENV-PROP-FENCE-RAIL"
	if EnvKit.has_art(id):
		# painted fence cards (posts, rails and pickets are in the art), side by side along the run
		mesh.set_material("card", EnvKit.material(id, true))
		var card_h: float = 1.15
		var natural: float = card_h * EnvKit.aspect(id)
		var count: int = maxi(1, int(round(length / natural)))
		var card_w: float = length / float(count)
		for index: int in range(count):
			var x0: float = -length * 0.5 + card_w * float(index)
			mesh.quad("card", [Vector3(x0, 0.0, 0.0), Vector3(x0 + card_w, 0.0, 0.0), Vector3(x0 + card_w, card_h, 0.0), Vector3(x0, card_h, 0.0)], Vector3(0, 0, 1), [], [Vector2(0, 1), Vector2(1, 1), Vector2(1, 0), Vector2(0, 0)])
		return _finish(mesh, "Fence", 0.0)
	mesh.set_material("wood", EnvKit.material(id))
	mesh.set_material("post", EnvKit.material(id, false, Color(0.82, 0.78, 0.74)))
	var posts: int = maxi(2, int(round(length / 1.4)) + 1)
	for index: int in range(posts):
		var x: float = -length * 0.5 + length * float(index) / float(posts - 1)
		mesh.box("post", Vector3(x, 0.55, 0), Vector3(0.16, 1.1, 0.16), Basis.IDENTITY, 0.035, 0.8)
		mesh.box("post", Vector3(x, 1.13, 0), Vector3(0.2, 0.06, 0.2), Basis.IDENTITY, 0.02)
	if picket:
		for rail: float in [0.35, 0.8]:
			mesh.box("wood", Vector3(0, rail, -0.07), Vector3(length, 0.1, 0.06), Basis.IDENTITY, 0.015)
		var count: int = int(length / 0.22)
		for index: int in range(count):
			var x: float = -length * 0.5 + 0.11 + 0.22 * float(index)
			var h: float = 0.82 + 0.03 * float(index % 3)
			mesh.box("wood", Vector3(x, h * 0.5 + 0.05, 0.0), Vector3(0.13, h, 0.05), Basis.IDENTITY, 0.0, 0.85)
			mesh.tri("wood", [Vector3(x - 0.065, h + 0.05, 0.025), Vector3(x + 0.065, h + 0.05, 0.025), Vector3(x, h + 0.17, 0.025)], Vector3(0, 0, 1))
			mesh.tri("wood", [Vector3(x - 0.065, h + 0.05, -0.025), Vector3(x + 0.065, h + 0.05, -0.025), Vector3(x, h + 0.17, -0.025)], Vector3(0, 0, -1))
	else:
		for rail: float in [0.45, 0.85]:
			mesh.tube("wood", Vector3(-length * 0.5, rail, 0.0), Vector3(length * 0.5, rail, 0.0), 0.06, 7, true)
	return _finish(mesh, "Fence", 0.0)


static func hedge(length: float) -> Node3D:
	var mesh: KitMesh = KitMesh.new()
	mesh.set_material("leaf", EnvKit.material("ENV-HEDGE"))
	mesh.box("leaf", Vector3(0, 0.45, 0), Vector3(length, 0.9, 0.9), Basis.IDENTITY, 0.28, 0.65)
	var lumps: int = maxi(2, int(length / 0.9))
	for index: int in range(lumps):
		var x: float = -length * 0.5 + length * (float(index) + 0.5) / float(lumps)
		mesh.blob("leaf", Vector3(x, 0.85, 0), Vector3(0.62, 0.3, 0.62), 3, 8)
	return _finish(mesh, "Hedge", 0.0)


static func stone_wall(length: float) -> Node3D:
	var mesh: KitMesh = KitMesh.new()
	mesh.set_material("stone", EnvKit.material("ENV-WALL-FOUNDATION"))
	mesh.box("stone", Vector3(0, 0.3, 0), Vector3(length, 0.6, 0.55), Basis.IDENTITY, 0.1, 0.7)
	mesh.box("stone", Vector3(0, 0.64, 0), Vector3(length + 0.1, 0.1, 0.68), Basis.IDENTITY, 0.04)
	return _finish(mesh, "StoneWall", 0.0)


static func bush(seed_value: int = 0) -> Node3D:
	var mesh: KitMesh = KitMesh.new()
	mesh.set_material("leaf", EnvKit.material("ENV-HEDGE", false, Color(0.9, 1.0, 0.85)))
	var rng: RandomNumberGenerator = _rng(seed_value + 7)
	for index: int in range(5):
		var a: float = rng.randf() * TAU
		var r: float = rng.randf_range(0.0, 0.4)
		mesh.blob("leaf", Vector3(cos(a) * r, 0.4 + rng.randf() * 0.2, sin(a) * r), Vector3(0.5, 0.42, 0.5) * rng.randf_range(0.8, 1.15), 4, 8, 0.7)
	return _finish(mesh, "Bush", 0.0)


# ---- market stall and merchant cart -----------------------------------------------------------------------------------------------------


## Painted awning geometry: a cut-out strip of ENV-AWNING-01/02 mapped over the sloped top (the flat striped part of the art) and a hanging valance (the scalloped part).
static func _awning_cloth(mesh: KitMesh, slot: String, left: float, right: float, front: Vector3, back: Vector3, drop: float) -> void:
	var out: Vector3 = back - front
	var normal: Vector3 = Vector3(0, out.z, -out.y).normalized()
	if normal.y < 0.0:
		normal = -normal
	mesh.quad(slot, [Vector3(left, front.y, front.z), Vector3(right, front.y, front.z), Vector3(right, back.y, back.z), Vector3(left, back.y, back.z)], normal, [Color(0.88, 0.88, 0.88), Color(0.88, 0.88, 0.88), Color.WHITE, Color.WHITE], [Vector2(0, 0.28), Vector2(1, 0.28), Vector2(1, 0.5), Vector2(0, 0.5)])
	mesh.quad(slot, [Vector3(left, front.y, front.z + 0.03), Vector3(right, front.y, front.z + 0.03), Vector3(right, front.y - drop, front.z + 0.05), Vector3(left, front.y - drop, front.z + 0.05)], Vector3(0, 0.1, 1), [], [Vector2(0, 0.5), Vector2(1, 0.5), Vector2(1, 1.0), Vector2(0, 1.0)])


## The market stall after the concept (ENV-PROP-STALL): plank counter with crates of produce in front, four timber posts, a striped scalloped awning, a hanging lantern and a
## sack beside it. Awning art when it exists (otherwise the placeholder stripes), planks / beams / crate / sack kit surfaces.
static func stall(seed_value: int = 0) -> Node3D:
	var mesh: KitMesh = KitMesh.new()
	var awning: String = "ENV-AWNING-01" if seed_value % 2 == 0 else "ENV-AWNING-02"
	mesh.set_material("wood", EnvKit.material("ENV-WALL-PLANK"))
	mesh.set_material("beam", EnvKit.material("ENV-BEAM"))
	mesh.set_material("canvas", EnvKit.material(awning, EnvKit.has_art(awning)))
	mesh.set_material("sack", EnvKit.material("ENV-PROP-SACK"))
	mesh.set_material("crate", EnvKit.fitted("ENV-PROP-CRATE"))
	mesh.set_material("iron", EnvKit.flat(Color("3b3530"), "iron"))
	mesh.set_material("glass", EnvKit.glow(LANTERN, 2.0))
	var goods: Array[Color] = [Color("d9503a"), Color("e8b53a"), Color("7ab648"), Color("e87aa8")]
	mesh.set_material("goods", EnvKit.flat(Color.WHITE, "goods"))
	var half_w: float = 1.5
	for sx: float in [-1.0, 1.0]:
		mesh.box("beam", Vector3(sx * half_w, 1.5, 0.95), Vector3(0.16, 3.0, 0.16), Basis.IDENTITY, 0.03)
		mesh.box("beam", Vector3(sx * half_w, 1.7, -0.95), Vector3(0.16, 3.4, 0.16), Basis.IDENTITY, 0.03)
	mesh.box("wood", Vector3(0, 0.55, 0.7), Vector3(3.0, 0.9, 0.9), Basis.IDENTITY, 0.05, 0.7)
	mesh.box("beam", Vector3(0, 1.02, 0.7), Vector3(3.2, 0.1, 1.1), Basis.IDENTITY, 0.03)
	mesh.box("wood", Vector3(0, 0.6, -0.95), Vector3(3.0, 1.2, 0.1), Basis.IDENTITY, 0.03, 0.8)
	var front_y: float = 3.0
	var back_y: float = 3.5
	var front_z: float = 1.4
	var back_z: float = -1.15
	var edge: float = half_w + 0.25
	if EnvKit.has_art(awning):
		_awning_cloth(mesh, "canvas", -edge, edge, Vector3(0, front_y, front_z), Vector3(0, back_y, back_z), 0.5)
	else:
		mesh.quad("canvas", [Vector3(-edge, front_y, front_z), Vector3(edge, front_y, front_z), Vector3(edge, back_y, back_z), Vector3(-edge, back_y, back_z)], Vector3(0, 0.9, 0.3), [Color(0.85, 0.85, 0.85), Color(0.85, 0.85, 0.85), Color.WHITE, Color.WHITE], [Vector2(-1.75, 0), Vector2(1.75, 0), Vector2(1.75, 2.8), Vector2(-1.75, 2.8)])
		var scallops: int = 8
		for index: int in range(scallops):
			var x0: float = -edge + edge * 2.0 * float(index) / float(scallops)
			var x1: float = -edge + edge * 2.0 * float(index + 1) / float(scallops)
			var xm: float = (x0 + x1) * 0.5
			mesh.quad("canvas", [Vector3(x0, front_y, front_z), Vector3(x1, front_y, front_z), Vector3(x1, front_y - 0.18, front_z + 0.02), Vector3(x0, front_y - 0.18, front_z + 0.02)], Vector3(0, 0, 1), [], [Vector2(x0, 0), Vector2(x1, 0), Vector2(x1, 0.18), Vector2(x0, 0.18)])
			mesh.tri("canvas", [Vector3(x0, front_y - 0.18, front_z + 0.02), Vector3(x1, front_y - 0.18, front_z + 0.02), Vector3(xm, front_y - 0.42, front_z + 0.03)], Vector3(0, 0, 1), [], [Vector2(x0, 0.18), Vector2(x1, 0.18), Vector2(xm, 0.42)])
	var cloth: bool = seed_value % 2 == 1 and EnvKit.has_art("ENV-PROP-CLOTHGOODS")
	if cloth:
		mesh.set_material("cloth_card", EnvKit.material("ENV-PROP-CLOTHGOODS", true))
		var cloth_w: float = 1.7
		var cloth_h: float = cloth_w / EnvKit.aspect("ENV-PROP-CLOTHGOODS")
		mesh.quad("cloth_card", [Vector3(-cloth_w * 0.5, 1.07, 0.9), Vector3(cloth_w * 0.5, 1.07, 0.9), Vector3(cloth_w * 0.5, 1.07 + cloth_h, 0.9), Vector3(-cloth_w * 0.5, 1.07 + cloth_h, 0.9)], Vector3(0, 0, 1), [], [Vector2(0, 1), Vector2(1, 1), Vector2(1, 0), Vector2(0, 0)])
	var rng: RandomNumberGenerator = _rng(seed_value + 70)
	for index: int in range(4):
		if cloth and (index == 1 or index == 2):
			continue
		var x: float = -1.05 + 0.7 * float(index)
		mesh.box("crate", Vector3(x, 1.2, 0.72), Vector3(0.56, 0.22, 0.6), Basis.IDENTITY, 0.03, 1.0, true)
		for fruit: int in range(5):
			mesh.blob("goods", Vector3(x + rng.randf_range(-0.18, 0.18), 1.38 + rng.randf() * 0.08, 0.72 + rng.randf_range(-0.18, 0.18)), Vector3(0.11, 0.1, 0.11), 4, 9, 1.0, goods[(index + seed_value) % goods.size()])
	for index: int in range(2):
		mesh.box("sack", Vector3(half_w + 0.65 + 0.2 * float(index), 0.36, 0.45 - 0.4 * float(index)), Vector3(0.64, 0.7, 0.55), Basis(Vector3.UP, 0.3 * float(index)), 0.2, 0.75)
	mesh.box("iron", Vector3(0.0, 2.75, 1.15), Vector3(0.22, 0.34, 0.22), Basis.IDENTITY, 0.04)
	mesh.box("glass", Vector3(0.0, 2.55, 1.15), Vector3(0.18, 0.26, 0.18), Basis.IDENTITY, 0.03)
	var lights: Array[Dictionary] = [{"pos": Vector3(0.0, 2.55, 1.2), "color": LANTERN, "range": 5.5, "energy": 1.2, "kind": "lantern"}]
	return _finish(mesh, "Stall", 1.6, lights)


## The merchant cart after the concept (ENV-PROP-CART): a plank bed with raised sides, a big spoked wheel each side, a cream canvas hood over ribs at the back half, sacks and
## a crate in the open front, two shafts. Textured with the kit surfaces (plank, canvas, sack, crate). The handles point +x; 2.6 x 1.6 m.
static func cart(seed_value: int = 0) -> Node3D:
	var mesh: KitMesh = KitMesh.new()
	mesh.set_material("wood", EnvKit.material("ENV-WALL-PLANK", false, Color(0.9, 0.84, 0.78)))
	mesh.set_material("beam", EnvKit.material("ENV-BEAM"))
	mesh.set_material("canvas", EnvKit.material("ENV-PROP-CANVAS"))
	mesh.set_material("sack", EnvKit.material("ENV-PROP-SACK"))
	mesh.set_material("crate", EnvKit.fitted("ENV-PROP-CRATE"))
	mesh.set_material("iron", EnvKit.flat(Color("3b3530"), "iron"))
	mesh.box("wood", Vector3(0, 0.85, 0), Vector3(1.9, 0.18, 1.2), Basis.IDENTITY, 0.03)
	for side: float in [-1.0, 1.0]:
		mesh.box("wood", Vector3(0, 1.2, side * 0.62), Vector3(1.9, 0.62, 0.1), Basis.IDENTITY, 0.03, 0.8)
		mesh.box("wood", Vector3(side * 0.95, 1.2, 0), Vector3(0.1, 0.62, 1.2), Basis.IDENTITY, 0.03, 0.8)
		var wheel_z: float = side * 0.78
		var segs: int = 18
		for step: int in range(segs):
			var a0: float = TAU * float(step) / float(segs)
			var a1: float = TAU * float(step + 1) / float(segs)
			var p0: Vector3 = Vector3(cos(a0) * 0.6, 0.66 + sin(a0) * 0.6, wheel_z)
			var p1: Vector3 = Vector3(cos(a1) * 0.6, 0.66 + sin(a1) * 0.6, wheel_z)
			mesh.tube("beam", p0, p1, 0.08, 6, false)
			if step % 3 == 0:
				mesh.tube("beam", Vector3(0, 0.66, wheel_z), p0, 0.04, 5, false)
		mesh.tube("iron", Vector3(0, 0.66, side * 0.6), Vector3(0, 0.66, side * 0.86), 0.1, 8, true)
	mesh.tube("beam", Vector3(0.9, 1.0, 0.45), Vector3(2.0, 0.7, 0.4), 0.05, 6, true)
	mesh.tube("beam", Vector3(0.9, 1.0, -0.45), Vector3(2.0, 0.7, -0.4), 0.05, 6, true)
	var arcs: int = 8
	for step: int in range(arcs):
		var a0: float = PI * float(step) / float(arcs)
		var a1: float = PI * float(step + 1) / float(arcs)
		var p0: Vector3 = Vector3(0, 1.5 + sin(a0) * 0.75, cos(a0) * 0.62)
		var p1: Vector3 = Vector3(0, 1.5 + sin(a1) * 0.75, cos(a1) * 0.62)
		mesh.quad("canvas", [p0 + Vector3(-0.9, 0, 0), p1 + Vector3(-0.9, 0, 0), p1 + Vector3(0.1, 0, 0), p0 + Vector3(0.1, 0, 0)], (p0 + p1) * 0.5 - Vector3(0, 1.5, 0))
	for rib: float in [-0.9, -0.4, 0.1]:
		for step: int in range(arcs):
			var a0: float = PI * float(step) / float(arcs)
			var a1: float = PI * float(step + 1) / float(arcs)
			mesh.tube("beam", Vector3(rib, 1.5 + sin(a0) * 0.77, cos(a0) * 0.64), Vector3(rib, 1.5 + sin(a1) * 0.77, cos(a1) * 0.64), 0.035, 5, false)
	mesh.box("crate", Vector3(0.58, 1.34, 0.22), Vector3(0.5, 0.5, 0.5), Basis(Vector3.UP, 0.2), 0.03, 1.0, true)
	for index: int in range(2):
		mesh.box("sack", Vector3(0.52 + 0.1 * float(index), 1.35, -0.28 - 0.26 * float(index)), Vector3(0.5, 0.55, 0.4), Basis(Vector3.UP, 0.4 * float(index)), 0.17, 0.75)
	var node: Node3D = _finish(mesh, "Cart", 1.2)
	node.rotation_degrees.y = float(seed_value * 31 % 40) - 20.0
	return node
