class_name BuffetShore
extends RefCounted
## Fable Nov 16b (Part 5): the Endless Buffet's edges. The table stood on a stepped slab over a flat brown plane; only the south side
## had gravy, 2.2 m below the ground.
##  - The gravy now lies all round the table at the river's own level, a hand's breadth under the painted ground, on the shared water
##    shader (its depth foam draws the shore line on Medium and High, its noise foam on Low).
##  - Where it meets the table the ground runs under it as a short wet shore, with gravy pebbles and crumbs along the water line. No
##    slab side, step or blank band shows.
##  - East of the table the land goes on as a food forest: broccoli and cauliflower trees in layers to the horizon, leeks and herbs at
##    their feet, cake stands, cloches and stock pots as boulders, the gravy river running on through it. It is outside the table, so
##    nobody walks there (`BuffetLayout.edge_distance`).
##  - It lives: steam drifts up between the trees, a few butterflies and birds, the leaves sway (the card shader), warm light lies in
##    patches on the forest floor. The Low preset builds none of that.

## The gravy all round: just under the river's own surface, so the two read as one sheet.
const WATER_Y: float = BuffetLayout.SOUP_LEVEL - 0.03
## How far the gravy reaches from the table (metres): past the far backdrop.
const SEA_REACH: float = 260.0
## The shore under the water line: [metres out from the table's edge, height]. The first ring is the table's own edge.
## Fable Nov 16c (Part 4.3): the shore ended 6 m out and 1.9 m down, shallower than the gravy is clear (`depth_range` 2.2): its far edge
## showed through as a faint dark line all round the table, the outline of "where the ground would be". Two more rings carry it down to
## 6 m under the gravy, 15 m out, where nothing shows.
const SHORE_RINGS: Array[Vector2] = [Vector2(0.0, 0.0), Vector2(0.6, WATER_Y + 0.07), Vector2(1.5, WATER_Y - 0.12), Vector2(3.2, WATER_Y - 0.7), Vector2(6.0, WATER_Y - 1.9), Vector2(9.5, WATER_Y - 3.6), Vector2(15.0, WATER_Y - 6.0)]
const SHORE_STEP: float = 1.6
## The forest's land east of the table: from here east, between these z, to this x.
const LAND_WEST: float = 98.0
## Along the table's straight east side the land starts this far west: a hand's breadth under the table's edge.
const LAND_UNDER: float = 95.4
const LAND_EAST: float = 236.0
const LAND_NORTH: float = -72.0
const LAND_SOUTH: float = 116.0
## The gravy river runs on east through the forest: the land leaves this much free either side of its middle.
const CHANNEL_HALF: float = BuffetLayout.RIVER_HALF_WIDTH + 1.4
## How far the land's own bank runs out under the gravy.
const LAND_BANK: float = 3.6
## Forest layers by distance from the table's edge (metres): [from, to, spacing, smallest scale, largest scale].
const LAYERS: Array[Array] = [[0.7, 4.0, 1.75, 0.8, 1.15], [4.0, 22.0, 2.5, 1.0, 1.5], [22.0, 62.0, 3.9, 1.3, 1.85], [62.0, 150.0, 6.4, 1.7, 2.3]]
## Trees nearer the table than this cast shadows.
const SHADOW_RANGE: float = 9.0
const TREE_KINDS: Array[String] = ["buff_broccoli", "buff_cauli", "buff_broccoli", "buff_broccoli", "buff_cauli"]
const BOULDER_KINDS: Array[String] = ["buff_cakestand", "buff_cloche", "buff_pot", "buff_cakestand"]
const STEAM_SPOTS: int = 8
const LIGHT_PATCHES: int = 14

## What was built, for the tests: tree positions, the land polygons, and the life node (null on Low).
var trees: Array[Vector3] = []
var lands: Array[PackedVector2Array] = []
var life: BuffetForestLife

var _builder: BuffetBuilder
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _land_y: float = 0.0


static func build(builder: BuffetBuilder) -> BuffetShore:
	var shore: BuffetShore = BuffetShore.new()
	shore._builder = builder
	shore._rng.seed = 16112
	shore.lands = land_polygons()
	shore._land_y = shore._east_edge_height() - 0.03
	shore._build_sea()
	shore._build_shore()
	shore._build_shore_props()
	shore._build_land()
	shore._build_forest()
	if alive():
		shore.life = BuffetForestLife.build(builder.root, shore)
	return shore


## Steam, butterflies, birds and light patches are built on Medium and High only.
static func alive() -> bool:
	return Settings.graphics_quality > GraphicsQuality.Level.LOW


## The two pieces of forest land, north and south of the river's channel (x, z).
static func land_polygons() -> Array[PackedVector2Array]:
	var north: PackedVector2Array = PackedVector2Array()
	var south: PackedVector2Array = PackedVector2Array()
	# the north piece: its west coast (north of the table) from the far north down to the table's corner, a wavering line
	var z: float = LAND_NORTH
	while z < 0.0:
		north.append(Vector2(coast_x(z), z))
		z += 6.0
	north.append(Vector2(LAND_WEST, 2.0))
	north.append(Vector2(LAND_UNDER, 14.0))  # (just under the table's east edge, below its north-east corner)
	var x: float = LAND_UNDER
	while x <= LAND_EAST + 0.01:
		north.append(Vector2(x, BuffetLayout.river_z(x) - CHANNEL_HALF))
		x += 6.0
	north.append(Vector2(LAND_EAST, LAND_NORTH))
	# the south piece: the river's bank, the far east, its south coast, and its west coast (south of the table) back up to the corner
	x = LAND_UNDER
	while x <= LAND_EAST + 0.01:
		south.append(Vector2(x, BuffetLayout.river_z(x) + CHANNEL_HALF))
		x += 6.0
	x = LAND_EAST
	while x > LAND_WEST + 6.0:
		south.append(Vector2(x, LAND_SOUTH + 3.0 * sin(x * 0.19)))
		x -= 6.0
	z = LAND_SOUTH
	while z > 80.0:
		south.append(Vector2(coast_x(z), z))
		z -= 6.0
	south.append(Vector2(LAND_WEST, 78.0))
	south.append(Vector2(LAND_UNDER, 66.0))  # (just under the table's east edge, above its south-east corner)
	return [north, south]


## The forest's west coast where it faces open gravy (north and south of the table): a wavering line, not a ruler's.
static func coast_x(z: float) -> float:
	return LAND_WEST + 2.6 + 2.4 * sin(z * 0.23) + 1.1 * sin(z * 0.61 + 1.0)


## True when (x, z) is on the forest's land.
static func on_land(x: float, z: float) -> bool:
	for polygon: PackedVector2Array in land_polygons():
		if Geometry2D.is_point_in_polygon(Vector2(x, z), polygon):
			return true
	return false


func _on_land(x: float, z: float) -> bool:
	for polygon: PackedVector2Array in lands:
		if Geometry2D.is_point_in_polygon(Vector2(x, z), polygon):
			return true
	return false


## The usual height of the ground along the table's east edge (the middle value; the river's bed left out): the forest floor lies a
## finger under it, so the table's edge is no kerb.
func _east_edge_height() -> float:
	var heights: Array[float] = []
	var z: float = 18.0
	while z <= 62.0:
		if absf(z - BuffetLayout.river_z(95.0)) > BuffetLayout.RIVER_HALF_WIDTH + 2.5:
			heights.append(_builder.layout.ground_height(95.7, z))
		z += 1.0
	heights.sort()
	return maxf(heights[heights.size() / 2] if not heights.is_empty() else 0.0, WATER_Y + 0.12)


## The table's outline, every SHORE_STEP metres: [point, the direction out of the table].
func _edge_points() -> Array[Array]:
	var outline: PackedVector2Array = _builder._outline(-0.02)
	var centre: Vector2 = (BuffetLayout.MIN_CORNER + BuffetLayout.MAX_CORNER) * 0.5
	var points: Array[Vector2] = []
	for index: int in range(outline.size()):
		var a: Vector2 = outline[index]
		var b: Vector2 = outline[(index + 1) % outline.size()]
		var pieces: int = maxi(1, int(ceil(a.distance_to(b) / SHORE_STEP)))
		for piece: int in range(pieces):
			points.append(a.lerp(b, float(piece) / float(pieces)))
	var result: Array[Array] = []
	for index: int in range(points.size()):
		var before: Vector2 = points[(index - 1 + points.size()) % points.size()]
		var after: Vector2 = points[(index + 1) % points.size()]
		var out: Vector2 = (after - before).normalized().orthogonal()
		if out.dot(points[index] - centre) < 0.0:
			out = -out
		result.append([points[index], out])
	return result


## `own_normals`: the surface carries its own normals (the shore and the bed: every normal straight up).
func _instance(surface: SurfaceTool, node_name: String, material: Material, own_normals: bool = false) -> MeshInstance3D:
	if not own_normals:
		surface.generate_normals()
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = surface.commit()
	instance.material_override = material
	instance.name = node_name
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.set_meta(&"no_range_cull", true)
	instance.set_meta(&"no_occlusion_fade", true)
	_builder.root.add_child(instance)
	return instance


## The gravy: a ring from just inside the table's edge out to SEA_REACH, all round.
func _build_sea() -> void:
	var edge: Array[Array] = _edge_points()
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for index: int in range(edge.size()):
		var here: Array = edge[index]
		var next: Array = edge[(index + 1) % edge.size()]
		var a: Vector2 = (here[0] as Vector2) - (here[1] as Vector2) * 0.9
		var b: Vector2 = (next[0] as Vector2) - (next[1] as Vector2) * 0.9
		var a_far: Vector2 = (here[0] as Vector2) + (here[1] as Vector2) * SEA_REACH
		var b_far: Vector2 = (next[0] as Vector2) + (next[1] as Vector2) * SEA_REACH
		for corner: Vector2 in [a, a_far, b, b, a_far, b_far]:
			surface.set_normal(Vector3.UP)
			surface.set_uv(corner * 0.1)
			surface.add_vertex(Vector3(corner.x, WATER_Y, corner.y))
	var sea: MeshInstance3D = MeshInstance3D.new()
	sea.mesh = surface.commit()
	# The open gravy has no bed under it: its deep colour is the gravy's own warm brown (the shared material's deep brown read as violet).
	var gravy: ShaderMaterial = BuffetMaterials.gravy_water().duplicate() as ShaderMaterial
	gravy.set_shader_parameter("shallow_color", Color(0.6, 0.33, 0.13))
	gravy.set_shader_parameter("deep_color", Color(0.45, 0.23, 0.09))
	sea.material_override = gravy
	sea.name = "GravySea"
	sea.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	sea.set_meta(StyleToon.META_NO_TOON, true)
	sea.set_meta(&"no_range_cull", true)
	sea.set_meta(&"no_occlusion_fade", true)
	sea.set_meta(PaintedClasses.META_NO_PAINT, true)
	_builder.root.add_child(sea)


## The shore: the table's ground carried down under the gravy all round (not where the forest's land takes over).
func _build_shore() -> void:
	var edge: Array[Array] = _edge_points()
	var mash: Color = _builder._terrain_color(Vector3(50.0, 0.0, 73.0))
	var wet: Color = BuffetMaterials.GRAVY.lightened(0.1)
	var rows: Array = []
	for entry: Array in edge:
		var at: Vector2 = entry[0] as Vector2
		var out: Vector2 = entry[1] as Vector2
		var inside: Vector2 = at - out * 0.5
		var top: float = _builder.layout.ground_height(inside.x, inside.y)
		var row: Array[Vector3] = []
		for ring: Vector2 in SHORE_RINGS:
			var wobble: float = 1.0 + 0.3 * (_builder._noise(at.x * 0.31 + ring.x, at.y * 0.27) - 0.5)
			var p: Vector2 = at + out * ring.x * wobble
			row.append(Vector3(p.x, top if ring.x <= 0.0 else minf(top, ring.y), p.y))
		rows.append([row, _on_land(at.x + out.x * 1.2, at.y + out.y * 1.2)])
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for index: int in range(rows.size()):
		var here: Array = rows[index] as Array
		var next: Array = rows[(index + 1) % rows.size()] as Array
		if bool(here[1]) and bool(next[1]):
			continue
		var a: Array[Vector3] = here[0] as Array[Vector3]
		var b: Array[Vector3] = next[0] as Array[Vector3]
		for ring: int in range(SHORE_RINGS.size() - 1):
			var dry: Color = mash.lerp(wet, 0.25 + 0.6 * float(ring) / float(SHORE_RINGS.size() - 1))
			var deep: Color = mash.lerp(wet, 0.25 + 0.6 * float(ring + 1) / float(SHORE_RINGS.size() - 1))
			for corner: Array in [[a[ring], dry], [b[ring], dry], [a[ring + 1], deep], [b[ring], dry], [b[ring + 1], deep], [a[ring + 1], deep]]:
				# every normal straight up: the rings' creases (each ring has its own colour, so generated normals broke along every
				# ring) were lines for the outline pass, drawn through the gravy
				surface.set_normal(Vector3.UP)
				surface.set_color(corner[1] as Color)
				surface.add_vertex(corner[0] as Vector3)
	_instance(surface, "Shore", BuffetMaterials.terrain(), true)
	# Fable Nov 16c (Part 4.3): the bed. The shore's far edge ended on nothing, and the world's outline pass drew that edge through the
	# gravy as a faint dark line all round the table. One flat bed at the last ring's depth, in the last ring's colour, takes the edge
	# away: the shore runs into it.
	var bed_y: float = SHORE_RINGS[SHORE_RINGS.size() - 1].y
	var bed_color: Color = mash.lerp(wet, 0.85)
	var centre: Vector2 = (BuffetLayout.MIN_CORNER + BuffetLayout.MAX_CORNER) * 0.5
	var reach: float = SEA_REACH + 60.0
	var bed: SurfaceTool = SurfaceTool.new()
	bed.begin(Mesh.PRIMITIVE_TRIANGLES)
	for corner: Vector2 in [Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]:
		bed.set_normal(Vector3.UP)
		bed.set_color(bed_color)
		bed.add_vertex(Vector3(centre.x + corner.x * reach, bed_y, centre.y + corner.y * reach))
	_instance(bed, "SeaBed", BuffetMaterials.terrain(), true)


## Gravy pebbles and crumbs along the water line, all round the table (not on the forest's side).
func _build_shore_props() -> void:
	var pebbles: Array[Transform3D] = []
	var crumbs: Array[Transform3D] = []
	for entry: Array in _edge_points():
		var at: Vector2 = entry[0] as Vector2
		var out: Vector2 = entry[1] as Vector2
		if _on_land(at.x + out.x * 1.2, at.y + out.y * 1.2) or BuffetLayout.on_bridge(at.x, at.y - 0.5) or absf(at.x - BuffetLayout.BRIDGE_X) < BuffetLayout.BRIDGE_HALF_WIDTH + 1.2 and at.y > 70.0:
			continue
		if _rng.randf() < 0.55:
			var reach: float = _rng.randf_range(0.35, 1.5)
			var size: float = _rng.randf_range(0.16, 0.42)
			var p: Vector2 = at + out * reach + out.orthogonal() * _rng.randf_range(-0.6, 0.6)
			pebbles.append(Transform3D(Basis(Vector3.UP, _rng.randf() * TAU).scaled(Vector3(size, size * 0.55, size * _rng.randf_range(0.7, 1.2))), Vector3(p.x, WATER_Y + 0.02 - reach * 0.05, p.y)))
		if _rng.randf() < 0.45:
			var size: float = _rng.randf_range(0.08, 0.2)
			var p: Vector2 = at + out * _rng.randf_range(-0.5, 0.5) + out.orthogonal() * _rng.randf_range(-0.7, 0.7)
			var ground: float = _builder.layout.ground_height(p.x, p.y) if BuffetLayout.edge_distance(p.x, p.y) > 0.0 else WATER_Y + 0.06
			crumbs.append(Transform3D(Basis(Vector3(0.3, 1.0, 0.2).normalized(), _rng.randf() * TAU).scaled(Vector3(size, size * 0.7, size)), Vector3(p.x, ground + size * 0.3, p.y)))
	var pebble: SphereMesh = SphereMesh.new()
	pebble.radius = 0.5
	pebble.height = 1.0
	pebble.radial_segments = 8
	pebble.rings = 4
	pebble.surface_set_material(0, BuffetMaterials.flat(BuffetMaterials.GRAVY.darkened(0.35), 0.3))
	_batch("ShorePebbles", pebble, pebbles)
	var crumb: BoxMesh = BoxMesh.new()
	crumb.size = Vector3.ONE
	crumb.surface_set_material(0, BuffetMaterials.flat(Color(0.86, 0.68, 0.36), 0.9))
	_batch("ShoreCrumbs", crumb, crumbs)


func _batch(node_name: String, mesh: Mesh, transforms: Array[Transform3D]) -> void:
	if transforms.is_empty():
		return
	var multimesh: MultiMesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = mesh
	multimesh.instance_count = transforms.size()
	for index: int in range(transforms.size()):
		multimesh.set_instance_transform(index, transforms[index])
	var field: MultiMeshInstance3D = MultiMeshInstance3D.new()
	field.multimesh = multimesh
	field.name = node_name
	field.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	field.set_meta(&"no_range_cull", true)
	field.set_meta(&"no_occlusion_fade", true)
	field.set_meta(PaintedClasses.META_NO_PAINT, true)
	_builder.root.add_child(field)


## The forest floor's painted crumb soil (the Buffet's own ground texture), tiled in world space.
static func soil_material(wet: bool = false) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.resource_name = "buff_crumbsoil_wet" if wet else "buff_crumbsoil"
	material.albedo_texture = PaintedLibrary.albedo("buff_crumbsoil")
	material.albedo_color = Color(0.5, 0.42, 0.36) if wet else Color(0.82, 0.8, 0.72)
	material.roughness = 0.55 if wet else 1.0
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material


## The land: two flat pieces of crumb soil just under the table's edge, each with a wet bank running out under the gravy.
func _build_land() -> void:
	var top: SurfaceTool = SurfaceTool.new()
	top.begin(Mesh.PRIMITIVE_TRIANGLES)
	var bank: SurfaceTool = SurfaceTool.new()
	bank.begin(Mesh.PRIMITIVE_TRIANGLES)
	for polygon: PackedVector2Array in lands:
		var indices: PackedInt32Array = Geometry2D.triangulate_polygon(polygon)
		# Godot's triangles may wind either way: turn each so it faces up.
		for triangle: int in range(0, indices.size(), 3):
			var a: Vector2 = polygon[indices[triangle]]
			var b: Vector2 = polygon[indices[triangle + 1]]
			var c: Vector2 = polygon[indices[triangle + 2]]
			var ordered: Array[Vector2] = [a, b, c]
			if (b - a).cross(c - a) < 0.0:
				ordered = [a, c, b]
			for corner: Vector2 in ordered:
				top.set_normal(Vector3.UP)
				top.set_uv(corner * 0.22)
				top.add_vertex(Vector3(corner.x, _land_y, corner.y))
		var clockwise: bool = Geometry2D.is_polygon_clockwise(polygon)
		for index: int in range(polygon.size()):
			var a: Vector2 = polygon[index]
			var b: Vector2 = polygon[(index + 1) % polygon.size()]
			if BuffetLayout.edge_distance((a.x + b.x) * 0.5, (a.y + b.y) * 0.5) > -0.3:
				continue  # (an edge under the table has no bank)
			var out: Vector2 = (b - a).normalized().orthogonal() * (1.0 if clockwise else -1.0)
			# (a polygon's outward side: checked against its own inside)
			if Geometry2D.is_point_in_polygon((a + b) * 0.5 + out * 0.3, polygon):
				out = -out
			var a_low: Vector2 = a + out * LAND_BANK
			var b_low: Vector2 = b + out * LAND_BANK
			var quad: Array[Vector3] = [Vector3(a.x, _land_y, a.y), Vector3(b.x, _land_y, b.y), Vector3(a_low.x, WATER_Y - 1.3, a_low.y), Vector3(b_low.x, WATER_Y - 1.3, b_low.y)]
			var normal: Vector3 = (quad[1] - quad[0]).cross(quad[2] - quad[0])
			var order: Array[int] = [0, 2, 1, 1, 2, 3]
			if normal.y < 0.0:
				order = [0, 1, 2, 1, 3, 2]
			for corner: int in order:
				bank.set_uv(Vector2(quad[corner].x, quad[corner].z) * 0.22)
				bank.add_vertex(quad[corner])
	var floor_node: MeshInstance3D = MeshInstance3D.new()
	floor_node.mesh = top.commit()
	floor_node.material_override = soil_material()
	floor_node.name = "ForestFloor"
	floor_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	floor_node.set_meta(&"no_range_cull", true)
	floor_node.set_meta(&"no_occlusion_fade", true)
	_builder.root.add_child(floor_node)
	_instance(bank, "ForestBank", soil_material(true))


## How far (x, z) is from the table's edge (0 on it, growing outward).
static func from_table(x: float, z: float) -> float:
	return maxf(0.0, -BuffetLayout.edge_distance(x, z))


## The forest: trees in layers by distance from the table, leeks and herbs at the front, boulders of the kit between them.
func _build_forest() -> void:
	var fields: Dictionary = {}
	var bounds: Rect2 = Rect2(LAND_UNDER, LAND_NORTH - 4.0, LAND_EAST - LAND_UNDER, LAND_SOUTH - LAND_NORTH + 8.0)
	for layer: Array in LAYERS:
		var spacing: float = float(layer[2])
		var z: float = bounds.position.y + _rng.randf() * spacing
		var row: int = 0
		while z < bounds.end.y:
			var x: float = bounds.position.x + (spacing * 0.5 if row % 2 == 1 else 0.0)
			while x < bounds.end.x:
				var px: float = x + _rng.randf_range(-0.42, 0.42) * spacing
				var pz: float = z + _rng.randf_range(-0.42, 0.42) * spacing
				x += spacing
				var away: float = from_table(px, pz)
				if away < float(layer[0]) or away >= float(layer[1]) or not _stands_on_land(px, pz, 1.1):
					continue
				var kind: String = TREE_KINDS[_rng.randi() % TREE_KINDS.size()]
				var scale_value: float = _rng.randf_range(float(layer[3]), float(layer[4]))
				var key: String = "%s|%s" % [kind, "near" if away < SHADOW_RANGE else "far"]
				if not fields.has(key):
					fields[key] = [] as Array[Dictionary]
				var at: Vector3 = Vector3(px, _land_y - 0.05, pz)
				(fields[key] as Array[Dictionary]).append({"pos": at, "scale": scale_value})
				trees.append(at)
			z += spacing * 0.87
			row += 1
	for key: String in fields.keys():
		var parts: PackedStringArray = key.split("|")
		var field: MultiMeshInstance3D = KitFoliage.tree_field(_builder.root, parts[0], fields[key] as Array[Dictionary], parts[1] == "near")
		if field != null:
			field.name = "Forest_%s_%s" % [parts[0], parts[1]]
			field.set_meta(&"no_range_cull", true)
	# The hem: leeks and herbs in clumps along the forest's near edge, and between the first trunks.
	var plants: Dictionary = {"buff_herb": [] as Array[Dictionary], "buff_leek": [] as Array[Dictionary]}
	for clump: int in range(150):
		var cx: float = _rng.randf_range(96.0, 112.0)
		var cz: float = _rng.randf_range(LAND_NORTH * 0.3, LAND_SOUTH * 0.92)
		var away: float = from_table(cx, cz)
		if away < 0.5 or away > 12.0 or not _stands_on_land(cx, cz, 0.7):
			continue
		var kind: String = "buff_leek" if _rng.randf() < 0.45 else "buff_herb"
		for _plant: int in range(_rng.randi_range(2, 5)):
			var px: float = cx + _rng.randf_range(-0.8, 0.8)
			var pz: float = cz + _rng.randf_range(-0.8, 0.8)
			if _stands_on_land(px, pz, 0.4):
				(plants[kind] as Array[Dictionary]).append({"pos": Vector3(px, _land_y - 0.02, pz), "scale": _rng.randf_range(0.8, 1.5)})
	for kind: String in plants.keys():
		var field: MultiMeshInstance3D = KitFoliage.tree_field(_builder.root, kind, plants[kind] as Array[Dictionary], false)
		if field != null:
			field.name = "Forest_%s" % kind
			field.set_meta(&"no_range_cull", true)
	# Boulders: cake stands, cloches and stock pots of the kit, large, standing still.
	var boulders: Dictionary = {}
	for index: int in range(70):
		var px: float = _rng.randf_range(96.5, 150.0)
		var pz: float = _rng.randf_range(LAND_NORTH * 0.5, LAND_SOUTH * 0.95)
		var away: float = from_table(px, pz)
		if away < 0.9 or away > 46.0 or not _stands_on_land(px, pz, 1.0):
			continue
		var kind: String = BOULDER_KINDS[index % BOULDER_KINDS.size()]
		if not boulders.has(kind):
			boulders[kind] = [] as Array[Dictionary]
		(boulders[kind] as Array[Dictionary]).append({"pos": Vector3(px, _land_y - 0.03, pz), "scale": _rng.randf_range(1.5, 2.2) * (1.0 + away / 40.0)})
	for kind: String in boulders.keys():
		_still_field(kind, boulders[kind] as Array[Dictionary])


## On the forest's land and at least `margin` metres from its banks and from the river's channel.
func _stands_on_land(x: float, z: float, margin: float) -> bool:
	if not _on_land(x, z):
		return false
	if absf(z - BuffetLayout.river_z(x)) < CHANNEL_HALF + margin:
		return false
	return _on_land(x - margin, z) and _on_land(x + margin, z) and _on_land(x, z - margin) and _on_land(x, z + margin)


## Cards that do not sway (props of the kit), one MultiMesh per kind.
func _still_field(kind: String, entries: Array[Dictionary]) -> void:
	if entries.is_empty() or not TreeCards.KINDS.has(kind):
		return
	var data: Dictionary = TreeCards.KINDS[kind] as Dictionary
	var size: Vector2 = data["size"] as Vector2
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2.ONE
	quad.center_offset = Vector3(0.0, 0.5, 0.0)
	var multimesh: MultiMesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = quad
	multimesh.instance_count = entries.size()
	for index: int in range(entries.size()):
		var s: float = float(entries[index]["scale"])
		multimesh.set_instance_transform(index, Transform3D(Basis.from_scale(Vector3(size.x * s, size.y * s, 1.0)), entries[index]["pos"] as Vector3))
	var instance: MultiMeshInstance3D = MultiMeshInstance3D.new()
	instance.name = "ForestBoulders_%s" % kind
	instance.multimesh = multimesh
	instance.material_override = KitFoliage.card_material(str(data["id"]), true)
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.extra_cull_margin = 8.0
	instance.set_meta(StyleToon.META_NO_TOON, true)
	instance.set_meta(PaintedClasses.META_NO_PAINT, true)
	instance.set_meta(&"no_occlusion_fade", true)
	instance.set_meta(&"no_range_cull", true)
	instance.set_meta("points", entries)
	_builder.root.add_child(instance)


func land_y() -> float:
	return _land_y
