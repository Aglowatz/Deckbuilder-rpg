class_name BoundaryKit
extends RefCounted
## Crosspath pass, Part D: the visible reason for every edge of the hub's walkable ground (`TownBounds`). Each edge kind gets its own blocker just
## outside the line, so the hero is always stopped by something they can see:
##   forest       - three staggered rows of trees with bushes at their feet
##   thorns       - twisted thorn trees and brambles in front of dark pines (round the Verdant Dump's thorn wall)
##   ridge        - a rocky ridge of boulders with pines behind (either side of the imperial road)
##   orchard_wall - a tall stone wall with pillars and a coping, fruit trees peeking over it (the Endless Buffet's pantry door is set into it)
##   wall         - a waist-high field wall of fieldstone (beside the D.N.A. checkpoint and round the graveyard hollow)
##   fence        - a post-and-rail fence with a hedge behind
##   hedge        - a thick clipped hedge with a few trees behind (the south-west field)
##   gorge        - the drop itself (HubLand builds the gorge and its rocks)
##   water        - the lake's soft bank: reeds and stones in clumps
## The lake itself (natural shore, shallows, a waterfall into the gorge) and the dock are built here too. Everything is visual: walking is decided by
## `TownBounds`. Solid kit pieces are merged by material (KitBatch); trees and reeds are painted cards in MultiMesh fields.

const ROCK_TEX: String = "res://assets/art/textures/mat_rock_albedo.webp"
const SAND_TEX: String = "res://assets/art/textures/town_sand_albedo.webp"
const PLANK_TEX: String = "res://assets/art/textures/mat_woodplanks_albedo.webp"

var root: Node3D
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _trees: Dictionary = {}
var _mesh: KitMesh = KitMesh.new()
var _ground_y: float = -0.03


static func build(parent: Node3D, water: Material, ground_y: float = -0.03) -> BoundaryKit:
	var kit: BoundaryKit = BoundaryKit.new()
	kit._ground_y = ground_y
	kit.root = Node3D.new()
	kit.root.name = "TownBoundary"
	parent.add_child(kit.root)
	kit._rng.seed = 1717
	kit._mesh.set_material("stone", EnvKit.material("ENV-WALL-FOUNDATION"))
	kit._mesh.set_material("coping", EnvKit.material("ENV-WALL-FOUNDATION", false, Color(0.86, 0.84, 0.8)))
	kit._mesh.set_material("rock", _rock_material())
	kit._mesh.set_material("wood", EnvKit.material("ENV-PROP-FENCE-RAIL"))
	kit._mesh.set_material("beam", EnvKit.material("ENV-BEAM"))
	kit._mesh.set_material("leaf", EnvKit.material("ENV-HEDGE"))
	kit._mesh.set_material("plank", _plank_material())
	for edge: Dictionary in kit._edges():
		kit._edge(edge)
	kit._lake(water)
	kit._dock()
	var body: MeshInstance3D = kit._mesh.instance("BoundaryBody")
	body.set_meta(&"no_occlusion_fade", true)
	body.set_meta(&"no_range_cull", true)
	body.set_meta(&"no_wind", true)
	body.extra_cull_margin = 60.0
	kit.root.add_child(body)
	kit._flush_trees()
	return kit


func _edges() -> Array[Dictionary]:
	return TownBounds.edges()


func _edge(edge: Dictionary) -> void:
	var a: Vector2 = edge["a"] as Vector2
	var b: Vector2 = edge["b"] as Vector2
	var length: float = a.distance_to(b)
	if length < 0.01:
		return
	var dir2: Vector2 = (b - a) / length
	var dir: Vector3 = Vector3(dir2.x, 0.0, dir2.y)
	var out: Vector3 = Vector3(dir2.y, 0.0, -dir2.x)
	var start: Vector3 = Vector3(a.x, 0.0, a.y)
	match str(edge["kind"]):
		"forest":
			_forest(start, dir, out, length, ["pine", "oak", "pine", "birch", "oak"])
		"thorns":
			_thorns(start, dir, out, length)
		"ridge":
			_ridge(start, dir, out, length)
		"orchard_wall":
			_wall(start, dir, out, length, 2.5, 0.8, true)
			_forest(start + out * 2.5, dir, out, length, ["fruit", "fruit", "oak"], 3.4, 1)
		"wall":
			_wall(start, dir, out, length, 1.25, 0.6, false)
		"fence":
			_fence(start, dir, out, length)
		"hedge":
			_hedge(start, dir, out, length)
		"water":
			_shore(start, dir, out, length)


# ---- kinds -------------------------------------------------------------------------------------------------------------------------------


## Rows of trees beyond the edge: the first close (a canopy wall), the next ones staggered behind; bushes fill the feet of the first row.
func _forest(start: Vector3, dir: Vector3, out: Vector3, length: float, kinds: Array, spacing: float = 2.3, rows: int = 3) -> void:
	for row: int in range(rows):
		var along: float = _rng.randf() * spacing * 0.5
		while along <= length:
			var depth: float = 1.4 + float(row) * 2.6 + _rng.randf() * 1.4
			var pos: Vector3 = start + dir * along + out * depth
			_tree(str(kinds[_rng.randi() % kinds.size()]), pos, 1.0 + _rng.randf() * 0.45 + float(row) * 0.08)
			if row == 0 and _rng.randf() < 0.7:
				_bush(start + dir * (along + spacing * 0.5) + out * (0.9 + _rng.randf() * 0.4), 0.9 + _rng.randf() * 0.4)
			along += spacing * (0.8 + _rng.randf() * 0.4)


func _thorns(start: Vector3, dir: Vector3, out: Vector3, length: float) -> void:
	var along: float = 0.0
	while along <= length:
		_tree("dump_twisted", start + dir * along + out * (1.2 + _rng.randf() * 0.8), 0.9 + _rng.randf() * 0.35)
		# brambles: dark thorny lumps at the feet
		var foot: Vector3 = start + dir * (along + 1.0) + out * (0.9 + _rng.randf() * 0.3)
		_mesh.blob("leaf", Vector3(foot.x, _ground_y + 0.45, foot.z), Vector3(0.9, 0.7, 0.9) * (0.8 + _rng.randf() * 0.5), 4, 8, 0.55, Color(0.42, 0.5, 0.36))
		along += 2.0 + _rng.randf() * 0.6
	_forest(start + out * 2.6, dir, out, length, ["pine", "dump_oak", "pine"], 2.4, 2)


## A rocky ridge: big boulders shoulder to shoulder just outside the edge, a higher row behind, pines on and behind it.
func _ridge(start: Vector3, dir: Vector3, out: Vector3, length: float) -> void:
	var along: float = 0.0
	while along <= length + 0.5:
		var near: Vector3 = start + dir * along + out * (1.5 + _rng.randf() * 0.5)
		var radius: float = 1.5 + _rng.randf() * 0.7
		_mesh.blob("rock", Vector3(near.x, _ground_y + radius * 0.55, near.z), Vector3(radius, radius * (0.9 + _rng.randf() * 0.5), radius), 4, 9, 0.75)
		var far: Vector3 = start + dir * (along + 1.2) + out * (4.2 + _rng.randf() * 1.0)
		var tall: float = 2.0 + _rng.randf() * 0.8
		_mesh.blob("rock", Vector3(far.x, _ground_y + tall * 0.7, far.z), Vector3(tall, tall * 1.3, tall), 4, 9, 0.7)
		along += radius * 1.35
	_forest(start + out * 4.0, dir, out, length, ["pine", "pine", "oak"], 2.6, 2)


## A stone wall along the edge: `height` tall, `thick` deep, a coping on top and (tall walls) a pillar every 5 m.
func _wall(start: Vector3, dir: Vector3, out: Vector3, length: float, height: float, thick: float, pillars: bool) -> void:
	var basis: Basis = Basis(dir, Vector3.UP, dir.cross(Vector3.UP))
	var centre: Vector3 = start + dir * length * 0.5 + out * (thick * 0.5 + 0.15)
	_mesh.box("stone", Vector3(centre.x, _ground_y + height * 0.5, centre.z), Vector3(length + thick, height, thick), basis, 0.06, 0.72)
	_mesh.box("coping", Vector3(centre.x, _ground_y + height + 0.08, centre.z), Vector3(length + thick + 0.12, 0.18, thick + 0.2), basis, 0.04)
	if not pillars:
		return
	var count: int = maxi(1, int(round(length / 5.0)))
	for i: int in range(count + 1):
		var p: Vector3 = start + dir * (length * float(i) / float(count)) + out * (thick * 0.5 + 0.15)
		_mesh.box("stone", Vector3(p.x, _ground_y + (height + 0.4) * 0.5, p.z), Vector3(thick + 0.35, height + 0.4, thick + 0.35), basis, 0.06, 0.8)
		_mesh.box("coping", Vector3(p.x, _ground_y + height + 0.5, p.z), Vector3(thick + 0.55, 0.2, thick + 0.55), basis, 0.04)


## Post and two rails (1.25 m), a low hedge just behind it.
func _fence(start: Vector3, dir: Vector3, out: Vector3, length: float) -> void:
	var basis: Basis = Basis(dir, Vector3.UP, dir.cross(Vector3.UP))
	var count: int = maxi(1, int(ceil(length / 2.2)))
	for i: int in range(count + 1):
		var p: Vector3 = start + dir * (length * float(i) / float(count)) + out * 0.35
		_mesh.box("beam", Vector3(p.x, _ground_y + 0.65, p.z), Vector3(0.18, 1.3, 0.18), basis, 0.03)
	for rail_y: float in [0.55, 1.05]:
		var c: Vector3 = start + dir * length * 0.5 + out * 0.35
		_mesh.box("wood", Vector3(c.x, _ground_y + rail_y, c.z), Vector3(length, 0.12, 0.08), basis, 0.02)
	_hedge(start + out * 0.9, dir, out, length, 1.0)


## A clipped hedge (1.5 m, or `height`) with lumpy tops, and (tall hedges) a few trees behind.
func _hedge(start: Vector3, dir: Vector3, out: Vector3, length: float, height: float = 1.5) -> void:
	var basis: Basis = Basis(dir, Vector3.UP, dir.cross(Vector3.UP))
	var c: Vector3 = start + dir * length * 0.5 + out * 0.7
	_mesh.box("leaf", Vector3(c.x, _ground_y + height * 0.5, c.z), Vector3(length + 0.6, height, 1.1), basis, 0.3, 0.65)
	var lumps: int = maxi(2, int(length / 1.1))
	for i: int in range(lumps):
		var p: Vector3 = start + dir * (length * (float(i) + 0.5) / float(lumps)) + out * 0.7
		_mesh.blob("leaf", Vector3(p.x, _ground_y + height - 0.05, p.z), Vector3(0.7, 0.32, 0.7) * (0.85 + _rng.randf() * 0.3), 3, 8)
	if height >= 1.4:
		var along: float = 2.0
		while along < length:
			_tree(["oak", "fruit", "birch"][_rng.randi() % 3], start + dir * along + out * (3.0 + _rng.randf() * 2.0), 0.95 + _rng.randf() * 0.3)
			along += 6.0 + _rng.randf() * 4.0


## The lake's bank: reeds in clumps and a few stones, between the walkable edge and the water; gaps of open bank between the clumps.
func _shore(start: Vector3, dir: Vector3, out: Vector3, length: float) -> void:
	var along: float = _rng.randf() * 2.0
	while along <= length:
		if _rng.randf() < 0.62:
			var clump: Vector3 = start + dir * along + out * (0.9 + _rng.randf() * 0.7)
			for i: int in range(2 + _rng.randi() % 3):
				_tree("dump_reed", clump + dir * _rng.randf_range(-0.7, 0.7) + out * _rng.randf_range(-0.2, 0.5), 0.55 + _rng.randf() * 0.3)
		if _rng.randf() < 0.3:
			var stone: Vector3 = start + dir * (along + 0.8) + out * (0.6 + _rng.randf() * 0.6)
			var r: float = 0.35 + _rng.randf() * 0.3
			_mesh.blob("rock", Vector3(stone.x, _ground_y + r * 0.35, stone.z), Vector3(r, r * 0.7, r), 3, 7, 0.8)
		along += 2.2 + _rng.randf() * 2.2


# ---- the lake, its shallows and bank, the waterfall, the dock -------------------------------------------------------------------------------


func _lake(water: Material) -> void:
	var shape: PackedVector2Array = TownBounds.LAKE
	var indices: PackedInt32Array = Geometry2D.triangulate_polygon(shape)
	if indices.is_empty():
		return
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_normal(Vector3.UP)
	for index: int in indices:
		var p: Vector2 = shape[index]
		surface.set_uv(p / 8.0)
		surface.add_vertex(Vector3(p.x, _ground_y + 0.012, p.y))
	var lake: MeshInstance3D = MeshInstance3D.new()
	lake.name = "TownLake"
	lake.set_meta(&"look_role", &"water")
	lake.mesh = surface.commit()
	lake.material_override = water
	lake.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	lake.set_meta(StyleToon.META_NO_TOON, true)
	lake.set_meta(&"no_occlusion_fade", true)
	lake.set_meta(&"no_range_cull", true)
	root.add_child(lake)
	# The soft bank: a strip from just inside the water line out over the grass, sandy at the water and fading into the grass; and pale shallows
	# fading into the deep water. No hard edge anywhere.
	root.add_child(_ring(shape, -0.6, 2.4, _bank_material(), _ground_y + 0.016, "LakeBank"))
	root.add_child(_ring(shape, -2.6, 0.0, _shallows_material(), _ground_y + 0.02, "LakeShallows"))
	_waterfall(water)


## A strip along a closed shape from `inner` to `outer` metres off its edge (positive = outside), alpha 1 at the water line falling to 0 at the far side.
func _ring(shape: PackedVector2Array, inner: float, outer: float, material: Material, y: float, node_name: String) -> MeshInstance3D:
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_normal(Vector3.UP)
	var count: int = shape.size()
	var rows: Array = []
	for i: int in range(count):
		var prev: Vector2 = shape[(i - 1 + count) % count]
		var here: Vector2 = shape[i]
		var next: Vector2 = shape[(i + 1) % count]
		var n1: Vector2 = (here - prev).normalized().orthogonal()
		var n2: Vector2 = (next - here).normalized().orthogonal()
		var normal: Vector2 = (n1 + n2).normalized()
		# outward: away from the water
		if Geometry2D.is_point_in_polygon(here + normal * 0.3, shape):
			normal = -normal
		rows.append([here + normal * inner, here + normal * outer, here])
	var fade_inner: float = 1.0 if inner >= 0.0 or outer > 0.0 else 0.0
	for i: int in range(count):
		var r0: Array = rows[i] as Array
		var r1: Array = rows[(i + 1) % count] as Array
		var verts: Array = [[r0[0], fade_inner], [r0[1], 1.0 - fade_inner], [r1[1], 1.0 - fade_inner], [r1[0], fade_inner]]
		for k: int in [0, 1, 2, 0, 2, 3]:
			var entry: Array = verts[k] as Array
			var p: Vector2 = entry[0] as Vector2
			surface.set_color(Color(1, 1, 1, float(entry[1])))
			surface.set_uv(p / 3.0)
			surface.add_vertex(Vector3(p.x, y, p.y))
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = surface.commit()
	instance.material_override = material
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.set_meta(StyleToon.META_NO_TOON, true)
	instance.set_meta(&"no_occlusion_fade", true)
	instance.set_meta(&"no_range_cull", true)
	return instance


func _bank_material() -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_texture = load(SAND_TEX) as Texture2D
	material.albedo_color = Color(0.78, 0.72, 0.58)
	material.vertex_color_use_as_albedo = true
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.roughness = 1.0
	material.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
	return material


func _shallows_material() -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(0.62, 0.86, 0.84, 0.75)
	material.vertex_color_use_as_albedo = true
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
	return material


## Where the lake meets the gorge, the water pours over the lip.
func _waterfall(water: Material) -> void:
	var lip_z: float = HubLand.GORGE_FROM + 68.6
	var from_x: float = 61.8
	var to_x: float = 66.2
	var fall: MeshInstance3D = MeshInstance3D.new()
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2(to_x - from_x, HubLand.GORGE_DEPTH)
	fall.mesh = quad
	fall.material_override = water
	fall.name = "Waterfall"
	fall.position = Vector3((from_x + to_x) * 0.5, _ground_y - HubLand.GORGE_DEPTH * 0.5, lip_z + 0.05)
	fall.set_meta(StyleToon.META_NO_TOON, true)
	fall.set_meta(&"no_occlusion_fade", true)
	fall.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(fall)


## A plank dock on posts over the lake (walkable: `TownBounds.DOCK`), a mooring post and a coil of rope at its end.
func _dock() -> void:
	var r: Rect2 = TownBounds.DOCK
	var deck_y: float = 0.08
	var x: float = r.position.x - 0.6
	while x < r.end.x:
		_mesh.box("plank", Vector3(x + 0.27, deck_y, r.get_center().y), Vector3(0.52, 0.09, r.size.y + 0.1 + _rng.randf() * 0.08), Basis.IDENTITY, 0.015)
		x += 0.56
	for px: float in [r.position.x + 1.4, r.position.x + r.size.x * 0.55, r.end.x - 0.2]:
		for pz: float in [r.position.y - 0.05, r.end.y + 0.05]:
			_mesh.box("beam", Vector3(px, -0.25, pz), Vector3(0.2, 0.9 + _rng.randf() * 0.2, 0.2), Basis.IDENTITY, 0.03)
	_mesh.box("beam", Vector3(r.end.x - 0.2, 0.55, r.position.y - 0.05), Vector3(0.22, 0.9, 0.22), Basis.IDENTITY, 0.03)


# ---- helpers -----------------------------------------------------------------------------------------------------------------------------


func _tree(kind: String, pos: Vector3, scale_value: float) -> void:
	if not TreeCards.KINDS.has(kind):
		return
	if not _trees.has(kind):
		_trees[kind] = [] as Array[Dictionary]
	(_trees[kind] as Array[Dictionary]).append({"pos": Vector3(pos.x, _ground_y, pos.z), "scale": scale_value})


func _bush(pos: Vector3, size: float) -> void:
	for i: int in range(3):
		var a: float = _rng.randf() * TAU
		var o: Vector3 = Vector3(cos(a), 0.0, sin(a)) * _rng.randf_range(0.0, 0.35) * size
		_mesh.blob("leaf", Vector3(pos.x + o.x, _ground_y + 0.38 * size, pos.z + o.z), Vector3(0.5, 0.42, 0.5) * size * _rng.randf_range(0.85, 1.15), 3, 8, 0.7, Color(0.92, 1.0, 0.86))


func _flush_trees() -> void:
	for kind: Variant in _trees.keys():
		var field: MultiMeshInstance3D = KitFoliage.tree_field(root, str(kind), _trees[kind] as Array[Dictionary], false)
		if field != null:
			field.set_meta(&"no_range_cull", true)
			field.extra_cull_margin = 80.0
	_trees.clear()


static func _rock_material() -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_texture = load(ROCK_TEX) as Texture2D
	material.albedo_color = Color(0.86, 0.8, 0.74)
	material.uv1_triplanar = true
	material.uv1_scale = Vector3(0.35, 0.35, 0.35)
	material.vertex_color_use_as_albedo = true
	material.roughness = 1.0
	return material


static func _plank_material() -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_texture = load(PLANK_TEX) as Texture2D
	material.albedo_color = Color(0.86, 0.72, 0.56)
	material.uv1_triplanar = true
	material.vertex_color_use_as_albedo = true
	material.roughness = 1.0
	return material
