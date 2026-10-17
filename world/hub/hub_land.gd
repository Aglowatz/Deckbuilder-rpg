class_name HubLand
extends Node3D
## Overnight Oct 16, Block 3: the hub world outside the town square as ONE country instead of an island in a sea. Built by `WorldScenery` for the
## town (land mode), visual only - walkability stays the town's own (`TownBuilder`), so every NPC, chest and passage keeps working.
##  - The sea is gone: painted land runs to the horizon (`hub_ground.gdshader`), with large soft patches of darker woods and dry meadow. The
##    town keeps its own lake (the enclosed water cells of the town map), and two more lakes sit where the land dips.
##  - Each zone passage continues as a road into the distance, with its own character: a winding forest path under tall trees (the Verdant Dump,
##    west), a cracked roadway with dead street lamps (the D.N.A., south-west), a sunny meadow road ending at the gorge (the Gainlands, south),
##    an orchard lane between fruit trees (the Endless Buffet, east) and a long straight imperial road between ridges (the Capital, north).
##  - A belt of trees and shrubs rings the town's walkable edge, hiding the old hex rim and giving the invisible edge a reason.
## Obstacles at the roads' ends (bridge, barrier, pantry door, thorn wall) are `HubObstacles`; the Capital on the horizon is the scenery's landmark,
## moved onto the imperial road's axis.

const GROUND_SHADER: String = "res://world/hub/hub_ground.gdshader"
const ROAD_SHADER: String = "res://world/hub/hub_road.gdshader"
const GROUND_Y: float = -0.03
const GROUND_RADIUS: float = 430.0
## The mask texture's world rectangle (x, z, width, depth) and its size in pixels.
const MASK_RECT: Rect2 = Rect2(-215.0, -230.0, 480.0, 480.0)
const MASK_SIZE: int = 320
const ROAD_LENGTH: float = 160.0
## Zone id -> road style: texture, width (m), wobble amplitude (m) and wavelength (m).
const ROADS: Dictionary = {
	"refusemancer": {"tex": "res://assets/art/textures/start_dirtpath_albedo.webp", "width": 2.6, "wobble": 5.5, "wave": 34.0, "tint": Color(0.86, 0.9, 0.78)},
	"necrocrat": {"tex": "res://assets/art/textures/cap_crackedroad_albedo.webp", "width": 3.4, "wobble": 0.8, "wave": 60.0, "tint": Color(0.78, 0.78, 0.82)},
	"beefcake": {"tex": "res://assets/art/textures/start_dirtpath_albedo.webp", "width": 3.0, "wobble": 2.2, "wave": 48.0, "tint": Color(1.05, 1.0, 0.86)},
	"gourmand": {"tex": "res://assets/art/textures/town_soil_albedo.webp", "width": 2.8, "wobble": 1.6, "wave": 40.0, "tint": Color(1.05, 0.95, 0.85)},
	"final": {"tex": "res://assets/art/textures/town_stone_albedo.webp", "width": 4.2, "wobble": 0.0, "wave": 100.0, "tint": Color(1.08, 1.05, 0.98)},
}
## Where the Gainlands gorge crosses the meadow road (metres past the passage mouth) and its size.
const GORGE_FROM: float = 3.0
const GORGE_WIDTH: float = 7.2
const GORGE_LENGTH: float = 90.0
const GORGE_DEPTH: float = 9.0

var town: TownBuilder
var ground_material: ShaderMaterial
## Zone id -> {"mouth": Vector3, "out": Vector3, "right": Vector3, "points": PackedVector3Array (the road's centre line)}.
var roads: Dictionary = {}
## Lakes as [centre Vector3, radius float].
var lakes: Array[Array] = []
## The town lake: the centres of its water cells (drawn as overlapping discs that follow the town map).
var town_water: Array[Vector3] = []
const TOWN_WATER_RADIUS: float = 2.7
var tree_count: int = 0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _trees: Dictionary = {}
## Ground the outskirts buildings and the dock stand on: no tree is planted within KEEP_CLEAR of them.
var _kept_clear: Array[Vector3] = []
const KEEP_CLEAR: float = 6.5


static func build(parent: Node3D, town_builder: TownBuilder, water: Material) -> HubLand:
	var land: HubLand = HubLand.new()
	land.name = "HubLand"
	land.town = town_builder
	parent.add_child(land)
	land._rng.seed = 1016
	land._plan_roads()
	land._plan_lakes()
	land._build_ground()
	land._build_lakes(water)
	land._build_gorge()
	for zone_id: Variant in land.roads.keys():
		land._build_road(str(zone_id))
	land._dress_roads()
	land._outskirts()
	land._tree_belt()
	land._flush_trees()
	print("hub_land: %d roads, %d lakes (+ %d town lake cells), %d trees" % [land.roads.size(), land.lakes.size(), land.town_water.size(), land.tree_count])
	return land


# ---- Plans -----------------------------------------------------------------------------------------------------------------------------------


func _plan_roads() -> void:
	for zone_id: Variant in TownBuilder.PORTAL_OUT.keys():
		var id: String = str(zone_id)
		var mouth: Vector3 = town.anchors.get("portal_%s_mouth" % id, Vector3.ZERO) as Vector3
		var out: Vector3 = TownBuilder.PORTAL_OUT[id] as Vector3
		var right: Vector3 = Vector3(-out.z, 0.0, out.x)
		var style: Dictionary = ROADS.get(id, ROADS["beefcake"]) as Dictionary
		var points: PackedVector3Array = []
		var steps: int = 64
		for i: int in range(steps + 1):
			var along: float = ROAD_LENGTH * float(i) / float(steps)
			# The wobble eases in, so every road leaves its passage straight.
			var ease_in: float = smoothstep(0.0, 18.0, along)
			var side: float = sin(along / float(style["wave"]) * TAU) * float(style["wobble"]) * ease_in
			points.append(mouth + out * along + right * side)
		roads[id] = {"mouth": mouth, "out": out, "right": right, "points": points}


## The town's own lake: the water cells of the town map that the outer sea never reaches (a flood fill from the map's border), as one lake per
## cluster; plus two lakes out in the country, clear of every road.
func _plan_lakes() -> void:
	var rows: int = TownBuilder.MAP.size()
	var cols: int = TownBuilder.MAP[0].length()
	var water: Dictionary = {}
	for row: int in range(rows):
		for col: int in range(cols):
			if TownBuilder.MAP[row][col] == ".":
				water[Vector2i(col, row)] = true
	var outside: Dictionary = {}
	var queue: Array[Vector2i] = []
	for cell: Variant in water.keys():
		var c: Vector2i = cell as Vector2i
		if c.x == 0 or c.y == 0 or c.x == cols - 1 or c.y == rows - 1:
			outside[c] = true
			queue.append(c)
	while not queue.is_empty():
		var c: Vector2i = queue.pop_back()
		for d: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 1), Vector2i(-1, -1), Vector2i(1, -1), Vector2i(-1, 1)]:
			var n: Vector2i = c + d
			if water.has(n) and not outside.has(n):
				outside[n] = true
				queue.append(n)
	var enclosed: Array[Vector3] = []
	for cell: Variant in water.keys():
		if not outside.has(cell):
			var c: Vector2i = cell as Vector2i
			enclosed.append(town.cell_center(c.x - TownBuilder.COL_OFFSET, c.y - TownBuilder.ROW_OFFSET))
	# The town lake: the south-east bay of the town map (round the giant chest's peninsula), carried a few cells further out so it reads as a lake
	# beside the town rather than a puddle; plus the small ponds inside the town.
	for row: int in range(11, rows + 2):
		for col: int in range(18, cols + 4):
			var inside_map: bool = row < rows and col < cols
			if (inside_map and TownBuilder.MAP[row][col] == ".") or (not inside_map and row >= 12 and row <= 17):
				enclosed.append(town.cell_center(col - TownBuilder.COL_OFFSET, row - TownBuilder.ROW_OFFSET))
	town_water = enclosed
	var bounds: Rect2 = town.map_bounds()
	var centre: Vector3 = Vector3(bounds.get_center().x, 0.0, bounds.get_center().y)
	for candidate: Vector3 in [centre + Vector3(68.0, 0.0, -52.0), centre + Vector3(-74.0, 0.0, 58.0), centre + Vector3(80.0, 0.0, 70.0)]:
		if _distance_to_roads(candidate) > 26.0 and lakes.size() < 3:
			lakes.append([candidate, 15.0 + _rng.randf() * 6.0])


func _distance_to_roads(p: Vector3) -> float:
	var best: float = 1.0e9
	for road: Variant in roads.values():
		for point: Vector3 in (road as Dictionary)["points"] as PackedVector3Array:
			best = minf(best, Vector2(p.x - point.x, p.z - point.z).length())
	return best


func _near_lake(p: Vector3, margin: float) -> bool:
	for cell: Vector3 in town_water:
		if Vector2(p.x - cell.x, p.z - cell.z).length() < TOWN_WATER_RADIUS + margin:
			return true
	for lake: Array in lakes:
		var c: Vector3 = lake[0] as Vector3
		if Vector2(p.x - c.x, p.z - c.z).length() < float(lake[1]) + margin:
			return true
	return false


## True inside the Gainlands gorge (plus `margin` metres round it).
func in_gorge(p: Vector3, margin: float = 0.0) -> bool:
	if not roads.has("beefcake"):
		return false
	var road: Dictionary = roads["beefcake"] as Dictionary
	var c: Vector3 = (road["mouth"] as Vector3) + (road["out"] as Vector3) * (GORGE_FROM + GORGE_WIDTH * 0.5)
	var offset: Vector3 = p - c
	var along: float = absf(offset.dot(road["out"] as Vector3))
	var across: float = absf(offset.dot(road["right"] as Vector3))
	return along < GORGE_WIDTH * 0.5 + margin and across < GORGE_LENGTH * 0.5 + margin


# ---- Ground ----------------------------------------------------------------------------------------------------------------------------------


func _build_ground() -> void:
	var image: Image = Image.create(MASK_SIZE, MASK_SIZE, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	var noise: FastNoiseLite = FastNoiseLite.new()
	noise.seed = 77
	noise.frequency = 0.012
	for y: int in range(MASK_SIZE):
		for x: int in range(MASK_SIZE):
			var world: Vector2 = _mask_to_world(x, y)
			var n: float = noise.get_noise_2d(world.x, world.y)
			var woods: float = clampf((n - 0.05) * 3.0, 0.0, 0.8)
			var dry: float = clampf((-n - 0.25) * 2.5, 0.0, 0.6)
			image.set_pixel(x, y, Color(woods, dry, 0.0, 0.0))
	# The forest path runs under trees, the meadow road through dry grass, the imperial road between bare ridges.
	_paint_along("refusemancer", 18.0, Color(0.85, 0.0, 0.0), image)
	_paint_along("beefcake", 22.0, Color(0.0, 0.55, 0.0), image)
	_paint_along("necrocrat", 9.0, Color(0.0, 0.0, 0.0, 0.6), image)
	for lake: Array in lakes:
		_paint_disc(image, lake[0] as Vector3, float(lake[1]) + 3.5, Color(0, 0, 0.55))
	var mask: ImageTexture = ImageTexture.create_from_image(image)
	ground_material = ShaderMaterial.new()
	ground_material.shader = load(GROUND_SHADER) as Shader
	ground_material.set_shader_parameter("grass_tex", load("res://assets/art/textures/town_grass_albedo.webp"))
	ground_material.set_shader_parameter("dirt_tex", load("res://assets/art/textures/town_sand_albedo.webp"))
	ground_material.set_shader_parameter("mask_tex", mask)
	ground_material.set_shader_parameter("mask_rect", Vector4(MASK_RECT.position.x, MASK_RECT.position.y, MASK_RECT.size.x, MASK_RECT.size.y))
	if roads.has("beefcake"):
		var road: Dictionary = roads["beefcake"] as Dictionary
		ground_material.set_shader_parameter("gorge_center", (road["mouth"] as Vector3) + (road["out"] as Vector3) * (GORGE_FROM + GORGE_WIDTH * 0.5))
		ground_material.set_shader_parameter("gorge_along", road["out"] as Vector3)
		ground_material.set_shader_parameter("gorge_size", Vector2(GORGE_WIDTH * 0.5, GORGE_LENGTH * 0.5))
	var disc: MeshInstance3D = MeshInstance3D.new()
	disc.name = "HubGround"
	disc.set_meta(&"look_role", &"shore")
	disc.mesh = _disc_mesh(GROUND_RADIUS, 96, 24)
	disc.material_override = ground_material
	disc.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	disc.extra_cull_margin = 400.0
	disc.set_meta(StyleToon.META_NO_TOON, true)
	disc.set_meta(&"no_occlusion_fade", true)
	disc.set_meta(&"no_range_cull", true)
	var bounds: Rect2 = town.map_bounds()
	disc.position = Vector3(bounds.get_center().x, GROUND_Y, bounds.get_center().y)
	add_child(disc)


func _mask_to_world(x: int, y: int) -> Vector2:
	return MASK_RECT.position + Vector2((float(x) + 0.5) / MASK_SIZE * MASK_RECT.size.x, (float(y) + 0.5) / MASK_SIZE * MASK_RECT.size.y)


func _world_to_mask(p: Vector3) -> Vector2:
	return Vector2((p.x - MASK_RECT.position.x) / MASK_RECT.size.x * MASK_SIZE, (p.z - MASK_RECT.position.y) / MASK_RECT.size.y * MASK_SIZE)


func _paint_disc(image: Image, centre: Vector3, radius: float, color: Color) -> void:
	var c: Vector2 = _world_to_mask(centre)
	var r: float = radius / MASK_RECT.size.x * MASK_SIZE
	for y: int in range(maxi(0, int(c.y - r - 2)), mini(MASK_SIZE, int(c.y + r + 3))):
		for x: int in range(maxi(0, int(c.x - r - 2)), mini(MASK_SIZE, int(c.x + r + 3))):
			var t: float = clampf(1.0 - (Vector2(x, y).distance_to(c) - r * 0.6) / (r * 0.4), 0.0, 1.0)
			if t <= 0.0:
				continue
			var old: Color = image.get_pixel(x, y)
			image.set_pixel(x, y, Color(maxf(old.r, color.r * t), maxf(old.g, color.g * t), maxf(old.b, color.b * t), maxf(old.a, color.a * t)))


func _paint_along(zone_id: String, radius: float, color: Color, image: Image) -> void:
	if not roads.has(zone_id):
		return
	var points: PackedVector3Array = (roads[zone_id] as Dictionary)["points"] as PackedVector3Array
	for i: int in range(0, points.size(), 2):
		_paint_disc(image, points[i], radius, color)


## A flat disc of concentric rings (fine near the middle, where the camera looks) - UV is world-free, the shader works in world space.
func _disc_mesh(radius: float, segments: int, rings: int) -> ArrayMesh:
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_normal(Vector3.UP)
	var radii: Array[float] = [0.0]
	for i: int in range(1, rings + 1):
		var t: float = float(i) / float(rings)
		radii.append(radius * t * t)
	for r: int in range(rings):
		for s: int in range(segments):
			var a0: float = float(s) / float(segments) * TAU
			var a1: float = float(s + 1) / float(segments) * TAU
			var p00: Vector3 = Vector3(cos(a0) * radii[r], 0.0, sin(a0) * radii[r])
			var p01: Vector3 = Vector3(cos(a1) * radii[r], 0.0, sin(a1) * radii[r])
			var p10: Vector3 = Vector3(cos(a0) * radii[r + 1], 0.0, sin(a0) * radii[r + 1])
			var p11: Vector3 = Vector3(cos(a1) * radii[r + 1], 0.0, sin(a1) * radii[r + 1])
			for p: Vector3 in [p00, p10, p11, p00, p11, p01]:
				surface.add_vertex(p)
	return surface.commit()


# ---- Lakes -----------------------------------------------------------------------------------------------------------------------------------


func _build_lakes(water: Material) -> void:
	if not town_water.is_empty():
		var town_surface: SurfaceTool = SurfaceTool.new()
		town_surface.begin(Mesh.PRIMITIVE_TRIANGLES)
		town_surface.set_normal(Vector3.UP)
		for cell: Vector3 in town_water:
			for s: int in range(16):
				var a0: float = float(s) / 16.0 * TAU
				var a1: float = float(s + 1) / 16.0 * TAU
				town_surface.add_vertex(Vector3(cell.x, 0.0, cell.z))
				town_surface.add_vertex(Vector3(cell.x + cos(a0) * TOWN_WATER_RADIUS, 0.0, cell.z + sin(a0) * TOWN_WATER_RADIUS))
				town_surface.add_vertex(Vector3(cell.x + cos(a1) * TOWN_WATER_RADIUS, 0.0, cell.z + sin(a1) * TOWN_WATER_RADIUS))
		var town_lake: MeshInstance3D = MeshInstance3D.new()
		town_lake.name = "TownLake"
		town_lake.set_meta(&"look_role", &"water")
		town_lake.mesh = town_surface.commit()
		town_lake.material_override = water
		town_lake.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		town_lake.position = Vector3(0.0, GROUND_Y + 0.01, 0.0)
		town_lake.set_meta(StyleToon.META_NO_TOON, true)
		town_lake.set_meta(&"no_occlusion_fade", true)
		town_lake.set_meta(&"no_range_cull", true)
		add_child(town_lake)
	for index: int in range(lakes.size()):
		var lake: Array = lakes[index]
		var centre: Vector3 = lake[0] as Vector3
		var radius: float = float(lake[1])
		var surface: SurfaceTool = SurfaceTool.new()
		surface.begin(Mesh.PRIMITIVE_TRIANGLES)
		surface.set_normal(Vector3.UP)
		var segments: int = 40
		var edge: Array[Vector3] = []
		for s: int in range(segments):
			var a: float = float(s) / float(segments) * TAU
			var wobble: float = 1.0 + 0.12 * sin(a * 3.0 + float(index)) + 0.07 * sin(a * 5.0 + 1.7 * float(index))
			edge.append(Vector3(cos(a) * radius * wobble, 0.0, sin(a) * radius * wobble))
		for s: int in range(segments):
			surface.add_vertex(Vector3.ZERO)
			surface.add_vertex(edge[s])
			surface.add_vertex(edge[(s + 1) % segments])
		var instance: MeshInstance3D = MeshInstance3D.new()
		instance.name = "Lake%d" % index
		instance.set_meta(&"look_role", &"water")
		instance.mesh = surface.commit()
		instance.material_override = water
		instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		instance.position = Vector3(centre.x, GROUND_Y + 0.012, centre.z)
		instance.set_meta(StyleToon.META_NO_TOON, true)
		instance.set_meta(&"no_occlusion_fade", true)
		add_child(instance)
		# Reeds and a few rocks round the far lakes (the town lake keeps its own shore).
		if index > 0:
			for s: int in range(0, segments, 3):
				var at: Vector3 = centre + edge[s] * 1.06
				_add_tree("dump_reed" if s % 2 == 0 else "birch", at, 0.8 + _rng.randf() * 0.4)


# ---- The Gainlands gorge ---------------------------------------------------------------------------------------------------------------------


## A cleft across the meadow road just past its passage: rock walls going down into shadow, a dark floor, rocks along both lips. The ground shader
## cuts the same rectangle out of the land; the bridge over it is `HubObstacles`.
func _build_gorge() -> void:
	if not roads.has("beefcake"):
		return
	var road: Dictionary = roads["beefcake"] as Dictionary
	var out: Vector3 = road["out"] as Vector3
	var right: Vector3 = road["right"] as Vector3
	var c: Vector3 = (road["mouth"] as Vector3) + out * (GORGE_FROM + GORGE_WIDTH * 0.5)
	var rock: StandardMaterial3D = StandardMaterial3D.new()
	rock.albedo_texture = load("res://assets/art/textures/mat_rock_albedo.webp") as Texture2D
	rock.uv1_scale = Vector3(GORGE_LENGTH / 3.5, GORGE_DEPTH / 3.5, 1.0)
	rock.albedo_color = Color(0.78, 0.72, 0.66)
	rock.cull_mode = BaseMaterial3D.CULL_DISABLED
	var root: Node3D = Node3D.new()
	root.name = "Gorge"
	add_child(root)
	for side: float in [-1.0, 1.0]:
		var wall: MeshInstance3D = MeshInstance3D.new()
		var quad: QuadMesh = QuadMesh.new()
		quad.size = Vector2(GORGE_LENGTH, GORGE_DEPTH)
		wall.mesh = quad
		wall.material_override = rock
		var basis: Basis = Basis(right, Vector3.UP, out * side)
		wall.transform = Transform3D(basis, c + out * side * GORGE_WIDTH * 0.5 + Vector3(0.0, GROUND_Y - GORGE_DEPTH * 0.5, 0.0))
		wall.set_meta(&"no_occlusion_fade", true)
		root.add_child(wall)
		# Shadow deepening down the wall: a gradient from clear at the lip to near black at the bottom, just in front of the rock.
		var shade: MeshInstance3D = MeshInstance3D.new()
		shade.mesh = quad
		var gradient: GradientTexture2D = GradientTexture2D.new()
		gradient.gradient = Gradient.new()
		gradient.gradient.set_color(0, Color(0.05, 0.05, 0.08, 0.0))
		gradient.gradient.set_color(1, Color(0.04, 0.04, 0.07, 0.92))
		gradient.fill_from = Vector2(0.5, 0.0)
		gradient.fill_to = Vector2(0.5, 1.0)
		var shade_material: StandardMaterial3D = StandardMaterial3D.new()
		shade_material.albedo_texture = gradient
		shade_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		shade_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		shade_material.cull_mode = BaseMaterial3D.CULL_DISABLED
		shade.material_override = shade_material
		shade.transform = Transform3D(basis, c + out * side * (GORGE_WIDTH * 0.5 - 0.04) + Vector3(0.0, GROUND_Y - GORGE_DEPTH * 0.5, 0.0))
		shade.set_meta(&"no_occlusion_fade", true)
		root.add_child(shade)
	var floor_mesh: MeshInstance3D = MeshInstance3D.new()
	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(GORGE_WIDTH, GORGE_LENGTH)
	floor_mesh.mesh = plane
	var dark: StandardMaterial3D = StandardMaterial3D.new()
	dark.albedo_color = Color(0.12, 0.13, 0.16)
	floor_mesh.material_override = dark
	floor_mesh.transform = Transform3D(Basis(out, Vector3.UP, right), c + Vector3(0.0, GROUND_Y - GORGE_DEPTH + 0.5, 0.0))
	root.add_child(floor_mesh)
	# A thin mist down in the cleft and rocks along both lips (they hide the straight edges).
	for side: float in [-1.0, 1.0]:
		var along: float = -GORGE_LENGTH * 0.5
		while along < GORGE_LENGTH * 0.5:
			if absf(along) > 2.6:
				var pos: Vector3 = c + out * side * (GORGE_WIDTH * 0.5 + 0.4) + right * along
				var model: Node3D = ModelKit.nature("rock_single_%s" % ["A", "B", "C", "D", "E"][_rng.randi() % 5])
				ModelKit.place(root, model, pos, _rng.randf() * 360.0, 1.6 + _rng.randf() * 1.2)
			along += 3.2 + _rng.randf() * 2.4


# ---- Roads -----------------------------------------------------------------------------------------------------------------------------------


func _build_road(zone_id: String) -> void:
	var road: Dictionary = roads[zone_id] as Dictionary
	var style: Dictionary = ROADS.get(zone_id, ROADS["beefcake"]) as Dictionary
	var points: PackedVector3Array = road["points"] as PackedVector3Array
	var width: float = float(style["width"])
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_normal(Vector3.UP)
	var distance: float = 0.0
	for i: int in range(points.size() - 1):
		var a: Vector3 = points[i]
		var b: Vector3 = points[i + 1]
		var dir: Vector3 = (b - a).normalized()
		var side: Vector3 = Vector3(-dir.z, 0.0, dir.x) * width * 0.5
		var next_distance: float = distance + a.distance_to(b)
		if zone_id == "beefcake" and in_gorge((a + b) * 0.5, 0.2):
			distance = next_distance
			continue
		var quad: Array = [[a - side, Vector2(0.0, distance)], [a + side, Vector2(1.0, distance)], [b + side, Vector2(1.0, next_distance)], [b - side, Vector2(0.0, next_distance)]]
		for k: int in [0, 1, 2, 0, 2, 3]:
			var entry: Array = quad[k] as Array
			surface.set_uv(entry[1] as Vector2)
			var v: Vector3 = entry[0] as Vector3
			surface.add_vertex(Vector3(v.x, GROUND_Y + 0.02, v.z))
		distance = next_distance
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = load(ROAD_SHADER) as Shader
	material.set_shader_parameter("road_tex", load(str(style["tex"])))
	material.set_shader_parameter("tint", style["tint"] as Color)
	material.set_shader_parameter("width", width)
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.name = "Road_%s" % zone_id
	instance.mesh = surface.commit()
	instance.material_override = material
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.set_meta(StyleToon.META_NO_TOON, true)
	instance.set_meta(&"no_occlusion_fade", true)
	instance.set_meta(&"no_range_cull", true)
	add_child(instance)


## The character of each road: what stands along it, from just past its passage to the horizon.
func _dress_roads() -> void:
	for zone_id: Variant in roads.keys():
		var id: String = str(zone_id)
		var road: Dictionary = roads[id] as Dictionary
		var points: PackedVector3Array = road["points"] as PackedVector3Array
		var width: float = float((ROADS.get(id, ROADS["beefcake"]) as Dictionary)["width"])
		var along: float = 4.0
		var step: float = ROAD_LENGTH / float(points.size() - 1)
		while along < ROAD_LENGTH - 4.0:
			var index: int = clampi(int(along / step), 0, points.size() - 2)
			var at: Vector3 = points[index]
			var dir: Vector3 = (points[index + 1] - at).normalized()
			var side: Vector3 = Vector3(-dir.z, 0.0, dir.x)
			match id:
				"refusemancer":
					# Tall trees close on both sides, a canopy the path winds under; vine oaks deeper in.
					for s: float in [-1.0, 1.0]:
						_add_tree("pine" if _rng.randf() < 0.55 else "oak", at + side * s * (width * 0.5 + 1.6 + _rng.randf() * 2.4), 1.15 + _rng.randf() * 0.45)
						_add_tree("dump_oak" if along > 60.0 else "pine", at + side * s * (width * 0.5 + 5.5 + _rng.randf() * 6.0), 1.2 + _rng.randf() * 0.5)
					along += 3.2 + _rng.randf() * 1.6
				"necrocrat":
					# Dead street lamps in a sad row, dead trees, nothing green near the asphalt.
					var lamp_side: float = 1.0 if int(along / 9.0) % 2 == 0 else -1.0
					_add_tree("dna_lamp", at + side * lamp_side * (width * 0.5 + 0.7), 1.1)
					_add_tree("dna_topiary", at + side * -lamp_side * (width * 0.5 + 2.0 + _rng.randf() * 3.0), 1.6 + _rng.randf() * 0.6)
					if _rng.randf() < 0.5:
						_add_tree("birch", at + side * lamp_side * (width * 0.5 + 6.0 + _rng.randf() * 6.0), 0.9)
					along += 9.0
				"beefcake":
					# Open sunny meadow: sunflowers and hay along the verge, a lone oak now and then.
					if along > GORGE_FROM + GORGE_WIDTH + 4.0:
						for s: float in [-1.0, 1.0]:
							if _rng.randf() < 0.7:
								_add_tree("sunflower", at + side * s * (width * 0.5 + 0.8 + _rng.randf() * 1.2), 1.0)
						if _rng.randf() < 0.25:
							_add_tree("hay", at + side * (1.0 if _rng.randf() < 0.5 else -1.0) * (width * 0.5 + 4.0 + _rng.randf() * 4.0), 1.0)
						if _rng.randf() < 0.18:
							_add_tree("oak", at + side * (1.0 if _rng.randf() < 0.5 else -1.0) * (width * 0.5 + 9.0 + _rng.randf() * 8.0), 1.2)
					along += 4.5
				"gourmand":
					# An orchard lane: fruit trees in neat rows on both sides.
					for s: float in [-1.0, 1.0]:
						_add_tree("fruit", at + side * s * (width * 0.5 + 1.9), 1.05 + _rng.randf() * 0.15)
						_add_tree("fruit", at + side * s * (width * 0.5 + 6.2), 1.0 + _rng.randf() * 0.2)
						if _rng.randf() < 0.4:
							_add_tree("fruit", at + side * s * (width * 0.5 + 10.5), 1.0)
					along += 4.6
				_:
					# The imperial road: straight, wide, lined with dark pines, between ridges (built below).
					for s: float in [-1.0, 1.0]:
						_add_tree("pine", at + side * s * (width * 0.5 + 2.2), 1.2)
					along += 7.0
	_capital_ridges()


## Dense forest walls on both sides of the imperial road (thickening the further it goes): the road is the only way to the Capital.
func _capital_ridges() -> void:
	if not roads.has("final"):
		return
	var road: Dictionary = roads["final"] as Dictionary
	var out: Vector3 = road["out"] as Vector3
	var right: Vector3 = road["right"] as Vector3
	var mouth: Vector3 = road["mouth"] as Vector3
	var root: Node3D = Node3D.new()
	root.name = "CapitalRidges"
	add_child(root)
	var along: float = 16.0
	while along < ROAD_LENGTH:
		for s: float in [-1.0, 1.0]:
			var offset: float = 13.0 + _rng.randf() * 5.0 + along * 0.04
			var pos: Vector3 = mouth + out * along + right * s * offset
			# A dense, dark forest wall (too thick to walk through), with boulders at its foot.
			for i: int in range(6):
				_add_tree("pine", pos - right * s * (5.0 - float(i) * 1.6 + _rng.randf() * 1.2) + out * _rng.randf_range(-5.0, 5.0), 1.3 + _rng.randf() * 0.6)
			if _rng.randf() < 0.5:
				var boulder: Node3D = ModelKit.nature("rock_single_%s" % ["A", "B", "C", "D", "E"][_rng.randi() % 5])
				ModelKit.place(root, boulder, Vector3(pos.x, GROUND_Y, pos.z) - right * s * 6.5, _rng.randf() * 360.0, 1.8 + _rng.randf())
		along += 11.0 + _rng.randf() * 3.0
	for child: Node in root.get_children():
		(child as Node3D).set_meta(&"no_occlusion_fade", true)


# ---- The tree belt round the town and the country beyond ---------------------------------------------------------------------------------------


## A belt of trees just outside the town's walkable edge (it hides the old hex rim and explains where the hero cannot go), thinning out into
## groves across the country; never on a road, a lake or the gorge.
func _tree_belt() -> void:
	var bounds: Rect2 = town.map_bounds()
	var middle: Vector3 = Vector3(bounds.get_center().x, 0.0, bounds.get_center().y)
	var reach: float = bounds.size.length() * 0.5
	var attempts: int = 2600
	for i: int in range(attempts):
		var angle: float = _rng.randf() * TAU
		var distance: float = lerpf(reach * 0.35, 135.0, pow(_rng.randf(), 1.6))
		var p: Vector3 = middle + Vector3(cos(angle), 0.0, sin(angle)) * distance
		if town.is_floor_at(p) or _near_floor(p, 1.4):
			continue
		var edge: float = _floor_distance(p, 9.0)
		var keep: float = 0.85 if edge < 9.0 else 0.18
		if _rng.randf() > keep:
			continue
		if _distance_to_roads(p) < 5.5 or _near_lake(p, 2.5) or in_gorge(p, 3.0):
			continue
		if blocks_view(p):
			continue
		var kind: String = ["oak", "pine", "birch", "oak", "fruit"][_rng.randi() % 5]
		_add_tree(kind, p, 0.95 + _rng.randf() * 0.55)


## True when a tall card at `p` would stand between the camera (which looks north, from the south) and the town or the first stretch of a
## road: the ground just north of it is walkable town, or a road's first 24 m runs close by on its north side.
func blocks_view(p: Vector3) -> bool:
	for d: float in [2.0, 4.5, 7.0, 9.5, 12.0]:
		for dx: float in [-2.5, 0.0, 2.5]:
			if town.is_floor_at(p + Vector3(dx, 0.0, -d)):
				return true
	for road: Variant in roads.values():
		var points: PackedVector3Array = (road as Dictionary)["points"] as PackedVector3Array
		for i: int in range(mini(points.size(), 11)):
			var q: Vector3 = points[i]
			var dz: float = p.z - q.z
			if dz > 0.5 and dz < 12.0 and absf(p.x - q.x) < 3.5:
				return true
	return false


func _near_floor(p: Vector3, radius: float) -> bool:
	for index: int in range(6):
		var angle: float = TAU * float(index) / 6.0
		if town.is_floor_at(p + Vector3(cos(angle), 0.0, sin(angle)) * radius):
			return true
	return false


## Roughly how far `p` is from the walkable town (capped at `cap`).
func _floor_distance(p: Vector3, cap: float) -> float:
	var r: float = 2.0
	while r < cap:
		if _near_floor(p, r):
			return r
		r += 2.5
	return cap


func _add_tree(kind: String, pos: Vector3, scale_value: float) -> void:
	if not TreeCards.KINDS.has(kind):
		return
	if kind != "sunflower" and kind != "dump_reed" and blocks_view(pos):
		return
	if not _trees.has(kind):
		_trees[kind] = [] as Array[Dictionary]
	(_trees[kind] as Array[Dictionary]).append({"pos": Vector3(pos.x, GROUND_Y, pos.z), "scale": scale_value})
	tree_count += 1


func _flush_trees() -> void:
	for kind: Variant in _trees.keys():
		var entries: Array[Dictionary] = _trees[kind] as Array[Dictionary]
		if not _kept_clear.is_empty():
			var kept: Array[Dictionary] = []
			for entry: Dictionary in entries:
				var p: Vector3 = entry["pos"] as Vector3
				var clear: bool = true
				for spot: Vector3 in _kept_clear:
					if Vector2(p.x - spot.x, p.z - spot.z).length() < KEEP_CLEAR:
						clear = false
						break
				if clear:
					kept.append(entry)
			entries = kept
		var field: MultiMeshInstance3D = KitFoliage.tree_field(self, str(kind), entries, false)
		if field != null:
			field.set_meta(&"no_range_cull", true)
			field.extra_cull_margin = 200.0
	_trees.clear()


# ---- The outskirts: a few kit buildings along the roads, and a dock on the town lake (Block 3g) ------------------------------------------------


## Zone id -> [preset, metres down the road, metres to its side (+ = the road's right), scale]: farm buildings by the meadow road, a cottage and a
## bakery on the orchard lane, a woodcutter's cottage by the forest path, a dead office block far down the cracked road. Never on the camera's
## side of a road's first stretch.
const OUTSKIRTS: Dictionary = {
	"beefcake": [["gain_mill_house", 24.0, 13.0, 1.0], ["gain_shed", 34.0, -12.0, 1.0]],
	"gourmand": [["buffet_cottage", 21.0, -10.0, 1.0], ["buffet_bakery", 42.0, -12.0, 1.0]],
	"refusemancer": [["cottage", 26.0, 10.0, 0.95]],
	"necrocrat": [["dna_office_block", 48.0, 15.0, 1.0]],
}


func _outskirts() -> void:
	var root: Node3D = Node3D.new()
	root.name = "Outskirts"
	add_child(root)
	for zone_id: Variant in OUTSKIRTS.keys():
		if not roads.has(str(zone_id)):
			continue
		var road: Dictionary = roads[str(zone_id)] as Dictionary
		var points: PackedVector3Array = road["points"] as PackedVector3Array
		var step: float = ROAD_LENGTH / float(points.size() - 1)
		for spec: Variant in OUTSKIRTS[zone_id] as Array:
			var entry: Array = spec as Array
			var along: float = float(entry[1])
			var on_road: Vector3 = points[clampi(int(along / step), 0, points.size() - 1)]
			var pos: Vector3 = on_road + (road["right"] as Vector3) * float(entry[2])
			if blocks_view(pos) or _near_lake(pos, 4.0) or in_gorge(pos, 4.0):
				continue
			var building: Node3D = BuildingPresets.build(str(entry[0]))
			if building == null:
				continue
			building.name = "Outskirt_%s" % str(entry[0])
			root.add_child(building)
			building.position = Vector3(pos.x, GROUND_Y, pos.z)
			var facing: Vector3 = (on_road - pos).normalized()
			building.rotation.y = atan2(facing.x, facing.z)
			building.scale = Vector3.ONE * float(entry[3])
			building.set_meta(&"no_occlusion_fade", true)
			_kept_clear.append(pos)
	_dock(root)


## A short wooden dock reaching into the town lake from its north shore, with a moored rowing boat's worth of posts (visual only).
func _dock(root: Node3D) -> void:
	if town_water.is_empty():
		return
	var best: Vector3 = Vector3.INF
	for cell: Vector3 in town_water:
		var shore: Vector3 = cell + Vector3(0.0, 0.0, -2.6)
		if town.is_floor_at(shore) and not town.is_floor_at(cell) and (best == Vector3.INF or cell.x > best.x):
			best = cell
	if best == Vector3.INF:
		return
	var wood: StandardMaterial3D = StandardMaterial3D.new()
	wood.albedo_texture = load("res://assets/art/textures/mat_woodplanks_albedo.webp") as Texture2D
	wood.albedo_color = Color(0.86, 0.72, 0.56)
	wood.uv1_triplanar = true
	var dock: Node3D = Node3D.new()
	dock.name = "LakeDock"
	dock.position = Vector3(best.x, 0.0, best.z - 1.6)
	_kept_clear.append(dock.position)
	root.add_child(dock)
	for i: int in range(7):
		var plank: MeshInstance3D = MeshInstance3D.new()
		var box: BoxMesh = BoxMesh.new()
		box.size = Vector3(1.5, 0.08, 0.5)
		plank.mesh = box
		plank.material_override = wood
		plank.position = Vector3(_rng.randf_range(-0.04, 0.04), 0.06, float(i) * 0.56)
		dock.add_child(plank)
	for z: float in [0.0, 1.7, 3.4]:
		for x: float in [-0.7, 0.7]:
			var post: MeshInstance3D = MeshInstance3D.new()
			var cylinder: CylinderMesh = CylinderMesh.new()
			cylinder.top_radius = 0.07
			cylinder.bottom_radius = 0.08
			cylinder.height = 0.9
			post.mesh = cylinder
			post.material_override = wood
			post.position = Vector3(x, -0.1, z)
			dock.add_child(post)
