class_name OpeningForestModels
extends RefCounted
## The Opening Forest's pieces (docs/art/opening_forest.md), built from `OpeningForestLayout`. Until the OF- kit arrives every piece is a STANDIN at storybook
## scale (hero 1.7 m) made of KitMesh primitives with the shared painted textures (`mat_rock`, `mat_bark`, `mat_leaves`) and the painted tree cards; the
## STANDIN ids are listed in `STANDINS` (and in the report). Solid rock, bark and camp pieces are merged into a few meshes by material; ferns are one
## swaying mesh; trees are painted cards in MultiMesh fields. Deterministic (seeded).

const ROCK_TEX: String = "res://assets/art/textures/mat_rock_albedo.webp"
const BARK_TEX: String = "res://assets/art/textures/mat_bark_albedo.webp"
const LEAF_TEX: String = "res://assets/art/textures/mat_leaves_albedo.webp"
const MOSS_TEX: String = "res://assets/art/textures/start_moss_albedo.webp"

## Every stand-in (id -> what it stands in for). The report turns these into art prompts.
const STANDINS: Dictionary = {
	"OF-HERO-CAVE-CLIFF": "the vine-draped cliff and the dark cave mouth",
	"OF-HERO-ANCIENT-TREE": "the giant ancient tree whose roots frame the cave mouth",
	"OF-PROP-BEDROLL": "the bedroll at the camp",
	"OF-PROP-PACK": "the travel pack at the head of the bedroll",
	"OF-PROP-LANTERN": "the lit lantern beside the bedroll",
	"OF-ROCK-BOULDER": "mossy boulders and rock ledges edging the clearing",
	"OF-PATH-FLAGSTONE": "scattered flagstones along the worn path",
	"OF-PLANT-FERN": "fern clumps and undergrowth",
	"OF-VINE-DRAPE": "hanging vines over the cliff and the roots",
	"OF-TREE-TRUNK": "the tall dark forest trunks framing the clearing",
}

## The cliff behind the cave: its foot line (x, z) from west to east and its height.
const CLIFF_LINE: Array[Vector2] = [Vector2(-9.0, -15.0), Vector2(-5.0, -13.6), Vector2(-1.0, -17.5), Vector2(3.5, -22.4), Vector2(8.0, -22.4), Vector2(12.8, -22.4), Vector2(18.5, -23.6), Vector2(24.0, -22.0)]
const CLIFF_HEIGHT: float = 9.5
const MOUTH_WIDTH: float = 3.4
const MOUTH_HEIGHT: float = 3.8

var layout: OpeningForestLayout
var root: Node3D
## Tall things that stand on or at the floor (x, z, radius), merged into the area's obstacles.
var obstacles: Array[Vector3] = []
## Where every boundary tree stands (layer -> Array[Vector2]); the tests read it.
var tree_points: Array[Vector2] = []
var boulder_points: Array[Vector3] = []
var fern_count: int = 0
var flagstone_count: int = 0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _solid: KitMesh = KitMesh.new()
var _ferns: KitMesh = KitMesh.new()
var _vines: KitMesh = KitMesh.new()
var _trees: Dictionary = {}


static func build(parent: Node3D, forest_layout: OpeningForestLayout) -> OpeningForestModels:
	var models: OpeningForestModels = OpeningForestModels.new()
	models.layout = forest_layout
	models._rng.seed = 1709
	models.root = Node3D.new()
	models.root.name = "OpeningForest"
	parent.add_child(models.root)
	models._materials()
	models._cliff()
	models._giant_tree()
	models._camp()
	models._rim_rocks()
	models._flagstones()
	models._undergrowth()
	models._trunks()
	models._tree_cards()
	models._flush()
	return models


# ---- materials --------------------------------------------------------------------------------------------------------------------------------


static func textured(path: String, tint: Color, scale_value: float = 0.5) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_texture = load(path) as Texture2D
	material.albedo_color = tint
	material.uv1_triplanar = true
	material.uv1_scale = Vector3.ONE * scale_value
	material.vertex_color_use_as_albedo = true
	material.roughness = 1.0
	material.set_meta(PaintedClasses.META_NO_PAINT, true)
	return material


func _materials() -> void:
	_solid.set_material("rock", textured(ROCK_TEX, Color(0.8, 0.86, 0.88), 0.42))
	_solid.set_material("moss", textured(MOSS_TEX, Color(0.62, 0.8, 0.5), 0.6))
	_solid.set_material("bark", textured(BARK_TEX, Color(0.58, 0.46, 0.38), 0.6))
	_solid.set_material("leaf", textured(LEAF_TEX, Color(0.3, 0.44, 0.38), 1.6))
	_solid.set_material("flat", EnvKit.flat(Color.WHITE, "opening_forest"))
	_solid.set_material("flagstone", textured(ROCK_TEX, Color(0.5, 0.52, 0.5), 1.1))
	var flats: Dictionary = {"cloth": Color("b8a67a"), "cloth_dark": Color("6e7a4a"), "leather": Color("7a4e2e"), "leather_dark": Color("4e321e"), "iron": Color("3a3a3e")}
	for slot: String in flats.keys():
		_solid.alias(slot, "flat", (flats[slot] as Color).srgb_to_linear())
	_solid.set_material("dark", _cave_dark())
	_ferns.set_material("fern", _double_sided(Color.WHITE))
	_vines.set_material("vine", _double_sided(Color.WHITE))


static func _double_sided(color: Color) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.vertex_color_use_as_albedo = true
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.roughness = 1.0
	material.set_meta(PaintedClasses.META_NO_PAINT, true)
	return material


## The cave's dark: unshaded vertex colours (near black at the core, deep teal-black at the rim), so no light ever greys it.
static func _cave_dark() -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.vertex_color_use_as_albedo = true
	material.set_meta(StyleToon.META_NO_TOON, true)
	material.set_meta(PaintedClasses.META_NO_PAINT, true)
	return material


# ---- shared shapes --------------------------------------------------------------------------------------------------------------------------


## A true ellipsoid (KitMesh.blob is circular in plan), `bottom` cuts it flat below that fraction (-1 whole).
static func ellipsoid(mesh: KitMesh, slot: String, center: Vector3, radii: Vector3, rings: int = 5, segments: int = 12, bottom: float = -1.0, tint: Color = Color.WHITE) -> void:
	var start: float = asin(clampf(bottom, -1.0, 1.0))
	for ring: int in range(rings):
		var a0: float = lerpf(start, PI * 0.5, float(ring) / float(rings))
		var a1: float = lerpf(start, PI * 0.5, float(ring + 1) / float(rings))
		var shade0: float = lerpf(0.72, 1.0, float(ring) / float(rings))
		var shade1: float = lerpf(0.72, 1.0, float(ring + 1) / float(rings))
		for seg: int in range(segments):
			var b0: float = TAU * float(seg) / float(segments)
			var b1: float = TAU * float(seg + 1) / float(segments)
			var corners: Array[Vector3] = []
			for pair: Vector2 in [Vector2(a0, b0), Vector2(a0, b1), Vector2(a1, b1), Vector2(a1, b0)]:
				corners.append(center + Vector3(cos(pair.x) * cos(pair.y) * radii.x, sin(pair.x) * radii.y, cos(pair.x) * sin(pair.y) * radii.z))
			var mid_a: float = (a0 + a1) * 0.5
			var mid_b: float = (b0 + b1) * 0.5
			var outward: Vector3 = Vector3(cos(mid_a) * cos(mid_b) / radii.x, sin(mid_a) / radii.y, cos(mid_a) * sin(mid_b) / radii.z).normalized()
			var c0: Color = Color(shade0, shade0, shade0) * tint
			var c1: Color = Color(shade1, shade1, shade1) * tint
			if ring == rings - 1:
				mesh.tri(slot, [corners[0], corners[1], corners[2]], outward, [c0, c0, c1])
			else:
				mesh.quad(slot, corners, outward, [c0, c0, c1, c1])


## A tapering limb through `points` (roots, branches): tubes with a blob at every joint so the bends read round.
static func limb(mesh: KitMesh, slot: String, points: Array[Vector3], r0: float, r1: float, segments: int = 8) -> void:
	var count: int = points.size()
	for index: int in range(count - 1):
		var t0: float = float(index) / float(count - 1)
		var t1: float = float(index + 1) / float(count - 1)
		mesh.tube(slot, points[index], points[index + 1], lerpf(r0, r1, (t0 + t1) * 0.5), segments, false)
		if index > 0:
			var joint: float = lerpf(r0, r1, t0) * 1.04
			mesh.blob(slot, points[index], Vector3(joint, joint, joint), 3, segments, 0.95)
	mesh.blob(slot, points[count - 1], Vector3(r1, r1, r1), 3, segments, 0.95)


## One hanging vine: a narrow strip `length` long tapering to a point, a little curl at the tip, leaf-green shading from top to tip.
func _vine(top: Vector3, length: float, width: float, facing: Vector3) -> void:
	var across: Vector3 = Vector3.UP.cross(facing).normalized() * width * 0.5
	var steps: int = 4
	var sway: float = _rng.randf_range(-0.25, 0.25)
	var tint: Color = ([Color("6a8a3a"), Color("4e6e30"), Color("8a9a48"), Color("40603a")][_rng.randi() % 4] as Color).srgb_to_linear()
	for step: int in range(steps):
		var t0: float = float(step) / float(steps)
		var t1: float = float(step + 1) / float(steps)
		var p0: Vector3 = top + Vector3(0, -length * t0, 0) + across.normalized() * sway * t0 * t0 + facing * 0.08 * t0
		var p1: Vector3 = top + Vector3(0, -length * t1, 0) + across.normalized() * sway * t1 * t1 + facing * 0.08 * t1
		var w0: float = 1.0 - t0 * 0.8
		var w1: float = 1.0 - t1 * 0.8
		var c0: Color = tint * lerpf(0.7, 1.05, t0)
		var c1: Color = tint * lerpf(0.7, 1.05, t1)
		_vines.quad("vine", [p0 - across * w0, p0 + across * w0, p1 + across * w1, p1 - across * w1], facing, [c0, c0, c1, c1])


## A mossy boulder about `size` metres across: two or three bevelled blocks, tilted and turned, half sunk, a soft moss cap on the biggest.
func boulder(pos: Vector3, size: float, moss: bool = true) -> void:
	var pieces: int = 2 + _rng.randi() % 2
	var top: float = 0.0
	for i: int in range(pieces):
		var s: float = size * (1.0 if i == 0 else _rng.randf_range(0.45, 0.7))
		var turn: Basis = Basis(Vector3.UP, _rng.randf() * TAU) * Basis(Vector3(1, 0, 0), _rng.randf_range(-0.2, 0.2)) * Basis(Vector3(0, 0, 1), _rng.randf_range(-0.2, 0.2))
		var offset: Vector3 = Vector3.ZERO if i == 0 else Vector3(_rng.randf_range(-0.55, 0.55), 0.0, _rng.randf_range(-0.55, 0.55)) * size
		var dims: Vector3 = Vector3(s * _rng.randf_range(1.0, 1.4), s * _rng.randf_range(0.6, 0.9), s * _rng.randf_range(0.85, 1.2))
		var centre: Vector3 = pos + offset + Vector3(0.0, dims.y * 0.3 - 0.05, 0.0)
		_solid.box("rock", centre, dims, turn, s * 0.24, 0.62)
		if i == 0:
			top = centre.y + dims.y * 0.5
			if moss:
				ellipsoid(_solid, "moss", Vector3(centre.x, top - dims.y * 0.12, centre.z), Vector3(dims.x * 0.42, dims.y * 0.22, dims.z * 0.4), 3, 9, 0.0)
	boulder_points.append(Vector3(pos.x, pos.z, size))


# ---- the cliff and the cave mouth (OF-HERO-CAVE-CLIFF, STANDIN) ------------------------------------------------------------------------------


## Rock slabs stacked along CLIFF_LINE (taller in the middle behind the cave, stepping down west to rock ledges behind the nook), mossy shelves, vines,
## and the cave mouth: an arched opening framed by jamb blocks and a lintel, a dark recess graded from black to deep teal at its rim.
func _cliff() -> void:
	var mouth: Vector3 = layout.mark("cave_mouth")
	for index: int in range(CLIFF_LINE.size() - 1):
		var a: Vector2 = CLIFF_LINE[index]
		var b: Vector2 = CLIFF_LINE[index + 1]
		var length: float = a.distance_to(b)
		var dir: Vector2 = (b - a) / length
		var along: float = 0.0
		while along < length:
			var p: Vector2 = a + dir * along
			var width: float = _rng.randf_range(2.2, 3.4)
			var mid_x: float = p.x
			# lower to the west (rock ledges behind the nook), full height behind the cave and the tree
			var height: float = CLIFF_HEIGHT * clampf(0.35 + (mid_x + 6.0) / 14.0, 0.35, 1.0) * _rng.randf_range(0.85, 1.12)
			if absf(mid_x - mouth.x) < MOUTH_WIDTH * 0.5 + 0.2:
				along += width * 0.8
				continue
			var yaw: float = atan2(-dir.y, dir.x) + _rng.randf_range(-0.12, 0.12)
			var basis: Basis = Basis(Vector3.UP, yaw) * Basis(Vector3(1, 0, 0), _rng.randf_range(-0.08, 0.04))
			var depth: float = _rng.randf_range(2.4, 3.6)
			var centre: Vector3 = Vector3(p.x, height * 0.5 - 0.2, p.y - depth * 0.4)
			_solid.box("rock", centre, Vector3(width, height, depth), basis, 0.45, 0.55)
			# a second, set-back block breaks the top line; a mossy shelf on the lower one
			_solid.box("rock", centre + Vector3(_rng.randf_range(-0.6, 0.6), height * 0.25, -depth * 0.6), Vector3(width * 0.9, height * _rng.randf_range(0.5, 0.75), depth), basis, 0.4, 0.8)
			ellipsoid(_solid, "moss", Vector3(p.x, height - 0.25, p.y - depth * 0.35), Vector3(width * 0.5, 0.35, depth * 0.45), 3, 9, 0.0)
			if _rng.randf() < 0.55:
				ellipsoid(_solid, "moss", Vector3(p.x + _rng.randf_range(-0.6, 0.6), height * _rng.randf_range(0.35, 0.6), p.y + depth * 0.12), Vector3(width * 0.35, 0.25, 0.5), 3, 8, 0.0)
			# vines down the face (the paint-over's curtains of them near the cave)
			var near_cave: float = clampf(1.0 - absf(p.x - mouth.x) / 12.0, 0.15, 1.0)
			var count: int = int(round(6.0 * near_cave)) + 1
			for v: int in range(count):
				var x: float = p.x + _rng.randf_range(-width * 0.5, width * 0.5)
				_vine(Vector3(x, height - _rng.randf_range(0.1, 0.8), p.y + 0.15), _rng.randf_range(1.6, height * 0.75), _rng.randf_range(0.22, 0.38), Vector3(0, 0, 1))
			along += width * 0.8
	_mouth(mouth)


func _mouth(mouth: Vector3) -> void:
	var half: float = MOUTH_WIDTH * 0.5
	var face_z: float = mouth.z + 0.2
	# jambs and the lintel: big blocks framing the opening
	for side: float in [-1.0, 1.0]:
		_solid.box("rock", Vector3(mouth.x + side * (half + 0.9), MOUTH_HEIGHT * 0.55, face_z - 0.9), Vector3(1.9, MOUTH_HEIGHT * 1.15, 2.6), Basis(Vector3.UP, side * 0.12), 0.4, 0.55)
	_solid.box("rock", Vector3(mouth.x, MOUTH_HEIGHT + 1.4, face_z - 1.0), Vector3(MOUTH_WIDTH + 3.0, 2.8, 3.0), Basis(Vector3(0, 0, 1), 0.05), 0.5, 0.8)
	_solid.box("rock", Vector3(mouth.x - 0.4, MOUTH_HEIGHT + 4.6, face_z - 1.6), Vector3(MOUTH_WIDTH + 4.0, 4.0, 3.0), Basis(Vector3.UP, 0.08), 0.5, 0.9)
	ellipsoid(_solid, "moss", Vector3(mouth.x, MOUTH_HEIGHT + 2.75, face_z - 0.6), Vector3(MOUTH_WIDTH * 0.7, 0.4, 1.2), 3, 10, 0.0)
	# the dark: an arched fan whose core is black and whose rim is a deep teal-black, set into the rock; a black box behind so no gap shows sky
	var core_color: Color = Color(0.0, 0.0, 0.0)
	var rim_color: Color = Color(0.03, 0.07, 0.08)
	var plane_z: float = face_z - 0.15
	var centre: Vector3 = Vector3(mouth.x, MOUTH_HEIGHT * 0.38, plane_z)
	var spring: float = MOUTH_HEIGHT - half
	var outline: Array[Vector3] = [Vector3(mouth.x - half, 0.0, plane_z), Vector3(mouth.x + half, 0.0, plane_z), Vector3(mouth.x + half, spring, plane_z)]
	var steps: int = 14
	for index: int in range(1, steps):
		var t: float = PI * float(index) / float(steps)
		outline.append(Vector3(mouth.x + cos(t) * half, spring + sin(t) * half, plane_z))
	outline.append(Vector3(mouth.x - half, spring, plane_z))
	for index: int in range(outline.size()):
		var a: Vector3 = outline[index]
		var b: Vector3 = outline[(index + 1) % outline.size()]
		_solid.tri("dark", [centre, a, b], Vector3(0, 0, 1), [core_color, rim_color, rim_color])
	_solid.box("dark", Vector3(mouth.x, MOUTH_HEIGHT * 0.5, face_z - 1.6), Vector3(MOUTH_WIDTH + 0.4, MOUTH_HEIGHT + 0.4, 2.6))
	# vines curtain the top of the opening
	for v: int in range(9):
		_vine(Vector3(mouth.x + lerpf(-half - 0.6, half + 0.6, float(v) / 8.0) + _rng.randf_range(-0.15, 0.15), MOUTH_HEIGHT + 0.4, face_z + 0.25), _rng.randf_range(0.8, 2.2), _rng.randf_range(0.2, 0.32), Vector3(0, 0, 1))


# ---- the giant ancient tree (OF-HERO-ANCIENT-TREE, STANDIN) --------------------------------------------------------------------------------------


## A broad flared trunk right of the cave, roots spilling over the rock; one great root arches over the cave mouth and down into the ground on its left,
## mossy and hung with vines; a dark heavy canopy of clumps that overhangs the cave so its underside frames the top of the view.
func _giant_tree() -> void:
	var base: Vector3 = layout.mark("giant_tree")
	var mouth: Vector3 = layout.mark("cave_mouth")
	var trunk: Array[Vector2] = [Vector2(3.0, -0.2), Vector2(2.4, 0.8), Vector2(1.75, 2.4), Vector2(1.45, 5.0), Vector2(1.3, 9.0), Vector2(1.1, 13.0), Vector2(0.8, 16.0)]
	_solid.lathe("bark", base, trunk, 16, 0.55, false, true)
	obstacles.append(Vector3(base.x, base.z, 2.6))
	# buttress roots round the foot, spreading toward the clearing and over the cliff rock
	for index: int in range(9):
		var angle: float = deg_to_rad(-20.0 + 40.0 * float(index)) + _rng.randf_range(-0.2, 0.2)
		var out: Vector3 = Vector3(cos(angle), 0.0, sin(angle))
		var reach: float = _rng.randf_range(3.6, 5.6)
		var points: Array[Vector3] = [base + out * 1.6 + Vector3(0, 1.6, 0), base + out * 2.8 + Vector3(0, 0.7, 0), base + out * (reach - 0.8) + Vector3(0, 0.2, 0), base + out * reach + Vector3(0, -0.15, 0)]
		var ok: bool = true
		for p: Vector3 in points:
			if layout.floor_sdf(Vector2(p.x, p.z)) < 0.35:
				ok = false
		if ok:
			limb(_solid, "bark", points, 0.62, 0.18, 8)
	# the great arch root over the cave mouth, and a second smaller one beside it
	var arch: Array[Vector3] = [base + Vector3(-1.6, 3.4, 0.6), Vector3(mouth.x + 2.6, MOUTH_HEIGHT + 1.6, mouth.z + 0.9), Vector3(mouth.x, MOUTH_HEIGHT + 1.15, mouth.z + 1.0), Vector3(mouth.x - 2.4, MOUTH_HEIGHT + 0.2, mouth.z + 0.9), Vector3(mouth.x - 3.2, 1.2, mouth.z + 0.7), Vector3(mouth.x - 3.5, -0.2, mouth.z + 0.3)]
	limb(_solid, "bark", arch, 0.7, 0.42, 10)
	var arch2: Array[Vector3] = [base + Vector3(-1.4, 2.0, 1.0), Vector3(mouth.x + 2.4, 2.4, mouth.z + 1.5), Vector3(mouth.x + 2.2, 0.6, mouth.z + 1.4), Vector3(mouth.x + 2.0, -0.2, mouth.z + 1.0)]
	limb(_solid, "bark", arch2, 0.48, 0.3, 8)
	for p: Vector3 in [arch[1], arch[2], arch[3], arch2[1]]:
		ellipsoid(_solid, "moss", p + Vector3(0, 0.5, 0), Vector3(0.7, 0.28, 0.55), 3, 8, 0.0)
	for v: int in range(14):
		var t: float = float(v) / 13.0
		var p: Vector3 = arch[1].lerp(arch[3], t)
		_vine(p + Vector3(0, -0.4, 0.45), _rng.randf_range(0.9, 2.6), _rng.randf_range(0.2, 0.34), Vector3(0, 0, 1))
	# limbs and a heavy canopy over the cave and the cliff
	var crown: Vector3 = base + Vector3(0, 13.0, 0)
	for index: int in range(6):
		var angle: float = deg_to_rad(110.0 + 34.0 * float(index)) + _rng.randf_range(-0.2, 0.2)
		var out: Vector3 = Vector3(cos(angle), 0.0, sin(angle) * 0.6)
		var tip: Vector3 = crown + out * _rng.randf_range(5.0, 8.5) + Vector3(0, _rng.randf_range(-1.0, 2.5), 0)
		limb(_solid, "bark", [base + Vector3(0, _rng.randf_range(8.0, 11.0), 0), crown.lerp(tip, 0.5) + Vector3(0, 0.8, 0), tip], 0.75, 0.28, 8)
		ellipsoid(_solid, "leaf", tip + Vector3(0, 0.8, 0), Vector3(3.4, 2.0, 2.8) * _rng.randf_range(0.8, 1.2), 4, 12, -0.6)
	for index: int in range(8):
		var c: Vector3 = crown + Vector3(_rng.randf_range(-9.0, 5.0), _rng.randf_range(0.0, 3.5), _rng.randf_range(-3.0, 2.0))
		ellipsoid(_solid, "leaf", c, Vector3(3.6, 2.2, 3.0) * _rng.randf_range(0.8, 1.25), 4, 12, -0.6)
		for v: int in range(3):
			_vine(c + Vector3(_rng.randf_range(-2.0, 2.0), -1.4, 1.5), _rng.randf_range(1.2, 3.2), 0.28, Vector3(0, 0, 1))


# ---- the camp (OF-PROP-BEDROLL / PACK / LANTERN, STANDIN) ---------------------------------------------------------------------------------------


func _camp() -> void:
	var bed: Vector3 = layout.mark("bedroll")
	var yaw: float = deg_to_rad(-12.0)
	var turn: Basis = Basis(Vector3.UP, yaw)
	# the bedroll: a flat padded roll laid out east-west, the blanket folded back, a rolled pillow at the head (west)
	_solid.box("cloth_dark", bed + Vector3(0, 0.05, 0), Vector3(1.9, 0.1, 0.82), turn, 0.05, 0.85)
	_solid.box("cloth", bed + turn * Vector3(0.35, 0.12, 0.0), Vector3(1.15, 0.08, 0.86), turn, 0.04, 0.9)
	_solid.box("cloth", bed + turn * Vector3(-0.12, 0.17, 0.0), Vector3(0.22, 0.12, 0.88), turn, 0.05, 0.9)
	_solid.tube("cloth_dark", bed + turn * Vector3(-0.85, 0.13, -0.36), bed + turn * Vector3(-0.85, 0.13, 0.36), 0.13, 10)
	# the pack: a leather body, a flap, a rolled blanket strapped on top, two straps
	var pack: Vector3 = layout.mark("pack")
	var pack_turn: Basis = Basis(Vector3.UP, deg_to_rad(28.0))
	# lying on its back, flap open toward the bedroll (stood upright it read as a small figure), the blanket roll on the ground beside it
	_solid.box("leather", pack + Vector3(0, 0.2, 0), Vector3(0.66, 0.4, 0.5), pack_turn, 0.1, 0.7)
	_solid.box("leather_dark", pack + pack_turn * Vector3(0.0, 0.36, 0.3), Vector3(0.6, 0.06, 0.3), pack_turn * Basis(Vector3(1, 0, 0), -0.5), 0.02)
	for side: float in [-0.18, 0.18]:
		_solid.box("leather_dark", pack + pack_turn * Vector3(side, 0.22, 0.0), Vector3(0.05, 0.43, 0.53), pack_turn, 0.0)
	_solid.tube("cloth", pack + pack_turn * Vector3(-0.4, 0.12, -0.42), pack + pack_turn * Vector3(0.4, 0.12, -0.42), 0.12, 10)
	# the lantern housing (its glass and its light are the scene's: OpeningForestLight)
	var lantern: Vector3 = layout.mark("lantern")
	_solid.box("iron", lantern + Vector3(0, 0.03, 0), Vector3(0.24, 0.06, 0.24), Basis.IDENTITY, 0.01)
	for corner: Vector2 in [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]:
		_solid.tube("iron", lantern + Vector3(corner.x * 0.09, 0.05, corner.y * 0.09), lantern + Vector3(corner.x * 0.09, 0.33, corner.y * 0.09), 0.012, 4)
	_solid.lathe("iron", lantern + Vector3(0, 0.32, 0), [Vector2(0.15, 0.0), Vector2(0.12, 0.05), Vector2(0.04, 0.13), Vector2(0.0, 0.15)], 8)
	_solid.tube("iron", lantern + Vector3(-0.05, 0.47, 0), lantern + Vector3(0.05, 0.47, 0), 0.012, 4)
	# firewood and a small ring of stones (unlit; the lantern is the light)
	for index: int in range(3):
		var log_turn: Basis = Basis(Vector3.UP, _rng.randf() * TAU)
		var c: Vector3 = pack + Vector3(-0.2 + 0.18 * float(index), 0.08 + 0.12 * float(index >> 1), 0.62)
		_solid.tube("bark", c + log_turn * Vector3(-0.38, 0, 0), c + log_turn * Vector3(0.38, 0, 0), 0.07, 6)


# ---- rocks at the rim (OF-ROCK-BOULDER, STANDIN) ---------------------------------------------------------------------------------------------------


## Mossy boulders in clusters along the edge of the clearing, the path and the nook (never on the path itself), the layout's rim blockers among them, and
## long low ledges at the front of the clearing like the paint-over's.
func _rim_rocks() -> void:
	for blocker: Vector3 in OpeningForestLayout.RIM_BLOCKERS:
		boulder(Vector3(blocker.x, 0.0, blocker.y), blocker.z * 1.5)
	var bounds: Rect2 = layout.bounds().grow(2.0)
	var candidates: Array[Vector2] = []
	var x: float = bounds.position.x
	while x < bounds.end.x:
		var z: float = bounds.position.y
		while z < bounds.end.y:
			candidates.append(Vector2(x + _rng.randf_range(-0.4, 0.4), z + _rng.randf_range(-0.4, 0.4)))
			z += 1.0
		x += 1.0
	_shuffle(candidates)
	var placed: Array[Vector2] = []
	for p: Vector2 in candidates:
		var d: float = layout.floor_sdf(p)
		if d < 0.55 or d > 1.8:
			continue
		# clusters: a slow wave decides where rocks gather
		if sin(p.x * 0.45 + 1.3) * cos(p.y * 0.38 - 0.7) < -0.1:
			continue
		var too_close: bool = false
		for q: Vector2 in placed:
			if q.distance_to(p) < _rng.randf_range(2.4, 4.2):
				too_close = true
				break
		if too_close:
			continue
		# fewer on the camera side: a full row there reads as a picket along the bottom of the screen
		if layout.camera_side(p, 5.0) and _rng.randf() < 0.5:
			continue
		placed.append(p)
		boulder(Vector3(p.x, 0.0, p.y), _rng.randf_range(0.9, 1.8))
	# ledges at the front: long low slabs, two or three overlapping
	for ledge: Vector3 in [Vector3(-5.6, 4.0, 0.3), Vector3(-1.2, 6.6, -0.1), Vector3(3.6, 6.4, 0.25), Vector3(7.4, 2.4, 0.9)]:
		var slab_count: int = 3
		for i: int in range(slab_count):
			var yaw: float = ledge.z + _rng.randf_range(-0.25, 0.25)
			var c: Vector3 = Vector3(ledge.x + float(i - 1) * 1.5 * cos(yaw), 0.18 + 0.08 * float(i % 2), ledge.y - float(i - 1) * 1.5 * sin(yaw) + _rng.randf_range(-0.3, 0.3))
			if layout.floor_sdf(Vector2(c.x, c.z)) < 0.9:
				continue
			_solid.box("rock", c, Vector3(_rng.randf_range(1.6, 2.4), _rng.randf_range(0.45, 0.7), _rng.randf_range(1.1, 1.6)), Basis(Vector3.UP, yaw) * Basis(Vector3(1, 0, 0), _rng.randf_range(-0.08, 0.08)), 0.18, 0.6)
			ellipsoid(_solid, "moss", c + Vector3(_rng.randf_range(-0.4, 0.4), 0.28, 0.0), Vector3(0.7, 0.14, 0.5), 3, 8, 0.0)
			boulder_points.append(Vector3(c.x, c.z, 1.6))


# ---- flagstones on the path (OF-PATH-FLAGSTONE, STANDIN) --------------------------------------------------------------------------------------------


## A few stretches of sunken flagstones along the middle of the path (the paint-over's), flush with the ground so they never trip the eye or the hero.
func _flagstones() -> void:
	var line: Array[Vector2] = OpeningForestLayout.PATH
	var stretches: Array[Vector2] = [Vector2(1.2, 2.1), Vector2(2.4, 3.1), Vector2(3.5, 4.4)]
	for stretch: Vector2 in stretches:
		var t: float = stretch.x
		while t < stretch.y:
			var index: int = int(t)
			var f: float = t - float(index)
			var a: Vector2 = line[index]
			var b: Vector2 = line[mini(index + 1, line.size() - 1)]
			var c: Vector2 = a.lerp(b, f)
			var dir: Vector2 = (b - a).normalized()
			var side: Vector2 = Vector2(-dir.y, dir.x)
			for k: int in range(2 + _rng.randi() % 2):
				var p: Vector2 = c + side * _rng.randf_range(-1.1, 1.1) + dir * _rng.randf_range(-0.3, 0.3)
				var size: Vector3 = Vector3(_rng.randf_range(0.55, 0.95), 0.1, _rng.randf_range(0.45, 0.75))
				var shade: float = _rng.randf_range(0.82, 1.05)
				_solid.box("flagstone", Vector3(p.x, -0.015, p.y), size, Basis(Vector3.UP, atan2(dir.x, dir.y) + _rng.randf_range(-0.4, 0.4)), 0.04, 0.7 * shade)
				flagstone_count += 1
			t += 0.11 + _rng.randf() * 0.05


# ---- ferns, bushes and undergrowth (OF-PLANT-FERN, STANDIN) -------------------------------------------------------------------------------------------


## One fern clump: fronds radiating out and arching down, each a tapering strip of leaflets in one of a few forest greens.
func fern(pos: Vector3, size: float) -> void:
	var fronds: int = 7 + _rng.randi() % 4
	var base_tint: Color = ([Color("2f5a34"), Color("3f6a38"), Color("26503a"), Color("4a7040")][_rng.randi() % 4] as Color).srgb_to_linear()
	for f: int in range(fronds):
		var angle: float = TAU * float(f) / float(fronds) + _rng.randf_range(-0.25, 0.25)
		var out: Vector3 = Vector3(cos(angle), 0.0, sin(angle))
		var length: float = size * _rng.randf_range(0.75, 1.1)
		var lift: float = _rng.randf_range(0.55, 0.9)
		var across: Vector3 = Vector3.UP.cross(out).normalized()
		var prev_l: Vector3 = pos
		var prev_r: Vector3 = pos
		var steps: int = 4
		for s: int in range(1, steps + 1):
			var t: float = float(s) / float(steps)
			var spine: Vector3 = pos + out * length * t + Vector3(0, size * lift * sin(t * PI * 0.8), 0)
			var w: float = size * 0.16 * sin(t * PI) + 0.01
			var l: Vector3 = spine - across * w
			var r: Vector3 = spine + across * w
			var c0: Color = base_tint * lerpf(0.6, 1.0, float(s - 1) / float(steps))
			var c1: Color = base_tint * lerpf(0.6, 1.0, t)
			_ferns.quad("fern", [prev_l, prev_r, r, l], Vector3.UP, [c0, c0, c1, c1])
			prev_l = l
			prev_r = r
	fern_count += 1


func _undergrowth() -> void:
	var bounds: Rect2 = layout.bounds().grow(4.0)
	var x: float = bounds.position.x
	while x < bounds.end.x:
		var z: float = bounds.position.y
		while z < bounds.end.y:
			var p: Vector2 = Vector2(x + _rng.randf_range(-0.5, 0.5), z + _rng.randf_range(-0.5, 0.5))
			var d: float = layout.floor_sdf(p)
			z += 0.9
			if d < -0.25 or d > 3.2:
				continue
			if layout.lab_open and p.distance_to(Vector2(OpeningForestLayout.LAB_POCKET.x, OpeningForestLayout.LAB_POCKET.y)) < OpeningForestLayout.LAB_POCKET.z + 0.4:
				continue
			# thinner right at the edge, thick just beyond it
			var keep: float = 0.35 if d < 0.4 else 0.8
			if _rng.randf() > keep:
				continue
			var size: float = _rng.randf_range(0.55, 1.05) if d < 0.6 else _rng.randf_range(0.8, 1.4)
			# between the camera and the floor the ferns and bushes stay low so the foreground frames the view instead of filling it
			var low: bool = layout.camera_side(p, 5.0)
			if low:
				size *= 0.6
			fern(Vector3(p.x, -0.03, p.y), size)
			if d > 0.9 and not low and _rng.randf() < 0.35:
				# a dark bush behind the fern
				var c: Vector3 = Vector3(p.x + _rng.randf_range(-0.4, 0.4), 0.0, p.y + _rng.randf_range(-0.4, 0.4))
				var s: float = _rng.randf_range(0.7, 1.3)
				ellipsoid(_solid, "leaf", c + Vector3(0, 0.35 * s, 0), Vector3(0.75, 0.6, 0.7) * s, 3, 9, -0.3)
		x += 0.9


# ---- trees (OF-TREE-TRUNK STANDIN, and the painted ENV/DUMP tree cards) ---------------------------------------------------------------------------------


## The tall dark trunks that frame the clearing and line the path (the paint-over's): straight bark columns rising out of the top of the frame with no
## crowns (heavy leaf clumps up there read as a black lid at Far zoom). Never on the camera side of the floor (they would fill the screen).
func _trunks() -> void:
	var spots: Array[Vector3] = [Vector3(-7.6, -3.0, 0.62), Vector3(-6.4, -6.2, 0.5), Vector3(-1.6, -11.6, 0.55), Vector3(4.2, -14.6, 0.6), Vector3(1.0, -16.2, 0.48),
		Vector3(7.6, -7.4, 0.55), Vector3(9.6, -10.4, 0.5), Vector3(13.6, -13.8, 0.58), Vector3(15.8, -16.4, 0.62), Vector3(-8.8, 0.6, 0.55), Vector3(8.8, -1.8, 0.5),
		Vector3(-8.6, -10.8, 0.6), Vector3(-3.8, -13.6, 0.5), Vector3(-9.6, -6.0, 0.55), Vector3(17.4, -12.0, 0.6), Vector3(12.4, -5.6, 0.5), Vector3(19.0, -18.0, 0.65)]
	for spot: Vector3 in spots:
		var p: Vector2 = Vector2(spot.x, spot.y)
		if layout.floor_sdf(p) < spot.z + 0.6 or layout.camera_side(p) or _near_cliff(p):
			continue
		var r: float = spot.z
		var height: float = _rng.randf_range(22.0, 28.0)
		var base: Vector3 = Vector3(spot.x, -0.1, spot.y)
		_solid.lathe("bark", base, [Vector2(r * 1.5, 0.0), Vector2(r * 1.15, 0.5), Vector2(r, 1.4), Vector2(r * 0.9, height * 0.5), Vector2(r * 0.7, height)], 10, 0.5, false, true)
		for k: int in range(3):
			var angle: float = _rng.randf() * TAU
			var root_end: Vector3 = base + Vector3(cos(angle), 0.0, sin(angle)) * r * _rng.randf_range(2.2, 3.0)
			if layout.floor_sdf(Vector2(root_end.x, root_end.z)) > 0.2:
				limb(_solid, "bark", [base + Vector3(cos(angle) * r * 0.6, 0.7, sin(angle) * r * 0.6), root_end + Vector3(0, -0.05, 0)], r * 0.45, r * 0.15, 6)
		obstacles.append(Vector3(spot.x, spot.y, r * 1.2))
		tree_points.append(p)


## Painted tree cards beyond the floor's edge in a band (pines and oaks, cooled by the mood), staggered so the forest reads deep; none on the camera side.
func _tree_cards() -> void:
	var bounds: Rect2 = layout.bounds().grow(14.0)
	var kinds: Array[String] = ["pine", "pine", "pine", "oak", "pine"]
	var x: float = bounds.position.x
	while x < bounds.end.x:
		var z: float = bounds.position.y
		while z < bounds.end.y:
			var p: Vector2 = Vector2(x + _rng.randf_range(-1.0, 1.0), z + _rng.randf_range(-1.0, 1.0))
			z += 2.3
			var d: float = layout.floor_sdf(p)
			if d < 1.4 or d > 13.0:
				continue
			if layout.camera_side(p, 12.0):
				continue
			if _near_cliff(p):
				continue
			var kind: String = kinds[_rng.randi() % kinds.size()]
			var scale_value: float = _rng.randf_range(1.05, 1.5) * (1.0 + clampf(d / 13.0, 0.0, 1.0) * 0.3)
			if not _trees.has(kind):
				_trees[kind] = [] as Array[Dictionary]
			(_trees[kind] as Array[Dictionary]).append({"pos": Vector3(p.x, -0.05, p.y), "scale": scale_value})
			tree_points.append(p)
		x += 2.3


## True when `p` is inside the cliff (behind its foot line) or the giant tree's trunk.
func _near_cliff(p: Vector2) -> bool:
	var tree: Vector3 = layout.mark("giant_tree")
	if p.distance_to(Vector2(tree.x, tree.z)) < 4.0:
		return true
	for index: int in range(CLIFF_LINE.size() - 1):
		var a: Vector2 = CLIFF_LINE[index]
		var b: Vector2 = CLIFF_LINE[index + 1]
		if p.x >= minf(a.x, b.x) and p.x <= maxf(a.x, b.x):
			var t: float = (p.x - a.x) / maxf(b.x - a.x, 0.001)
			var foot_z: float = lerpf(a.y, b.y, t)
			if p.y < foot_z + 1.0 and p.y > foot_z - 6.0:
				return true
	return false


func _shuffle(list: Array[Vector2]) -> void:
	for i: int in range(list.size() - 1, 0, -1):
		var j: int = _rng.randi() % (i + 1)
		var tmp: Vector2 = list[i]
		list[i] = list[j]
		list[j] = tmp


func _flush() -> void:
	var body: MeshInstance3D = _solid.instance("OpeningForestBody")
	body.set_meta(&"no_occlusion_fade", true)
	body.set_meta(&"no_range_cull", true)
	body.set_meta(&"no_wind", true)
	body.extra_cull_margin = 40.0
	root.add_child(body)
	var ferns: MeshInstance3D = _ferns.instance("FernFoliage")
	ferns.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	ferns.set_meta(&"no_occlusion_fade", true)
	ferns.set_meta(&"no_range_cull", true)
	ferns.extra_cull_margin = 20.0
	root.add_child(ferns)
	var vines: MeshInstance3D = _vines.instance("VineFoliage")
	vines.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	vines.set_meta(&"no_occlusion_fade", true)
	vines.set_meta(&"no_range_cull", true)
	# the wind sway grows with height: vines hanging from 9-15 m would stretch into blades
	vines.set_meta(&"no_wind", true)
	vines.extra_cull_margin = 20.0
	root.add_child(vines)
	for kind: Variant in _trees.keys():
		var field: MultiMeshInstance3D = KitFoliage.tree_field(root, str(kind), _trees[kind] as Array[Dictionary], false)
		if field != null:
			field.set_meta(&"no_range_cull", true)
			field.extra_cull_margin = 60.0
	_trees.clear()
