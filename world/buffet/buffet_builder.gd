class_name BuffetBuilder
extends ZoneMap
## Turns a `BuffetLayout` into the Endless Buffet's 3D world and answers walkability queries: the rolling
## faceted mashed-potato table with its layer-cake rim, the glossy gravy river and ponds, the mesas, the jelly
## bounce pads, crouton rafts and the rotating lazy susan, the golem gates, Kenney Food Kit / KayKit
## Restaurant Bits dressing, signs and the hidden chests. `animate()` moves everything that moves.

const M = preload("res://world/buffet/buffet_materials.gd")
const P = preload("res://world/buffet/buffet_props.gd")
const MOBS = preload("res://world/buffet/buffet_mobs.gd")

var layout: BuffetLayout = BuffetLayout.new()
var root: Node3D
var story: ZoneStoryText
## The platform clock (seconds); the layout's raft positions are functions of it.
var time: float = 0.0
## Per-frame movement of the platforms (the scene carries a rider along): raft id -> Vector2 delta (xz).
var raft_delta: Dictionary = {}
## How far the lazy susan turned this frame (radians).
var susan_delta: float = 0.0
var susan_angle: float = 0.0
var pad_nodes: Dictionary = {}
var raft_nodes: Dictionary = {}
var gate_nodes: Dictionary = {}
var susan_nodes: Array[Node3D] = []

var _buckets: Dictionary = {}
var _gate_blockers: Dictionary = {}
var _open_gates: Dictionary = {}
var _soup_materials: Array[StandardMaterial3D] = []
var _fountain_streams: Array[Node3D] = []
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func build(parent: Node3D) -> void:
	_rng.seed = 91
	layout.build()
	story = ZoneStoryText.for_zone(BuffetZone.ID)
	root = Node3D.new()
	root.name = "Buffet"
	parent.add_child(root)
	_build_table_rim()
	_build_terrain()
	_build_soup()
	_build_tablecloth()
	_build_platforms()
	_build_pads()
	_build_props()
	_build_gates()
	_build_signs()
	_build_chests()
	_index_obstacles()


# ---- Queries (the ZoneMap interface) ------------------------------------------------------------


func anchor(anchor_name: String) -> Vector3:
	var base: Vector3 = layout.anchors.get(anchor_name, Vector3.ZERO) as Vector3
	return Vector3(base.x, layout.ground_height(base.x, base.z), base.z)


func has_anchor(anchor_name: String) -> bool:
	return layout.anchors.has(anchor_name)


func chest_positions() -> Dictionary:
	var result: Dictionary = {}
	for id: Variant in layout.chests.keys():
		var base: Vector3 = layout.chests[id] as Vector3
		result[str(id)] = Vector3(base.x, layout.ground_height(base.x, base.z), base.z)
	return result


func enemy_spawns() -> Array[Dictionary]:
	return layout.enemy_spawns


func area_at(pos: Vector3) -> Array[String]:
	var area: BuffetLayout.Area = layout.area_at(pos.x, pos.z)
	if area == null:
		return [] as Array[String]
	return [area.id, area.title] as Array[String]


func is_floor_at(pos: Vector3) -> bool:
	var surface: BuffetLayout.Surface = layout.surface_at(pos.x, pos.z)
	return surface == BuffetLayout.Surface.GROUND or surface == BuffetLayout.Surface.MESA


func map_bounds() -> Rect2:
	return Rect2(BuffetLayout.MIN_CORNER - Vector2(2, 2), BuffetLayout.MAX_CORNER - BuffetLayout.MIN_CORNER + Vector2(4, 4))


## The surface a rider stands on: a raft or the lazy susan, if (x, z) is on one right now.
func platform_under(pos: Vector3, margin: float = 0.0) -> Dictionary:
	var raft: BuffetLayout.Raft = layout.raft_under(pos.x, pos.z, time, margin)
	if raft != null:
		return {"kind": "raft", "id": raft.id}
	var susan: BuffetLayout.Susan = layout.susan_under(pos.x, pos.z, margin)
	if susan != null:
		return {"kind": "susan", "id": susan.id}
	return {}


func height_at(pos: Vector3) -> float:
	if layout.surface_at(pos.x, pos.z) == BuffetLayout.Surface.SOUP and not platform_under(pos).is_empty():
		return 0.0
	return layout.ground_height(pos.x, pos.z)


## True when (x, z) is in the soup with nothing to stand on: the player falls in.
func is_in_soup(pos: Vector3) -> bool:
	return layout.surface_at(pos.x, pos.z) == BuffetLayout.Surface.SOUP and platform_under(pos, -0.05).is_empty()


func add_blocker(pos: Vector3, radius: float) -> void:
	_add_obstacle(Vector3(pos.x, pos.z, radius))


## The player may wade into the soup (and fall in); never off the table or up a cliff.
func is_walkable(pos: Vector3, body_radius: float = 0.22) -> bool:
	var surface: BuffetLayout.Surface = layout.surface_at(pos.x, pos.z)
	if surface == BuffetLayout.Surface.VOID or surface == BuffetLayout.Surface.CLIFF:
		return false
	if BuffetLayout.edge_distance(pos.x, pos.z) < 0.35:
		return false
	return not _hits_obstacle(pos, body_radius) and not _hits_gate(pos, body_radius)


## Enemies stay on dry ground and mesa tops: never in the soup, never on a cliff.
func is_enemy_walkable(pos: Vector3, body_radius: float = 0.25) -> bool:
	var surface: BuffetLayout.Surface = layout.surface_at(pos.x, pos.z)
	if surface != BuffetLayout.Surface.GROUND and surface != BuffetLayout.Surface.MESA:
		return false
	if BuffetLayout.edge_distance(pos.x, pos.z) < 0.6 or layout.soup_depth(pos.x, pos.z) > -0.9:
		return false
	return not _hits_obstacle(pos, body_radius) and not _hits_gate(pos, body_radius)


func has_line_of_sight(a: Vector3, b: Vector3) -> bool:
	var steps: int = maxi(1, int(a.distance_to(b) / 0.6))
	for i: int in range(steps + 1):
		var point: Vector3 = a.lerp(b, float(i) / float(steps))
		var surface: BuffetLayout.Surface = layout.surface_at(point.x, point.z)
		if surface == BuffetLayout.Surface.VOID or surface == BuffetLayout.Surface.CLIFF or surface == BuffetLayout.Surface.SOUP:
			return false
		if _hits_obstacle(point, 0.1) or _hits_gate(point, 0.1):
			return false
	return true


## Opens a golem gate for movement purposes (the blocker goes away).
func open_gate(gate_id: String) -> void:
	_open_gates[gate_id] = true


func is_gate_open(gate_id: String) -> bool:
	return _open_gates.has(gate_id)


func _bucket_key(x: float, z: float) -> Vector2i:
	return Vector2i(int(floorf(x / 4.0)), int(floorf(z / 4.0)))


func _add_obstacle(obstacle: Vector3) -> void:
	var key: Vector2i = _bucket_key(obstacle.x, obstacle.y)
	var list: Array = _buckets.get(key, []) as Array
	list.append(obstacle)
	_buckets[key] = list


func _hits_obstacle(pos: Vector3, radius: float) -> bool:
	var key: Vector2i = _bucket_key(pos.x, pos.z)
	for dz: int in range(-1, 2):
		for dx: int in range(-1, 2):
			var list: Variant = _buckets.get(key + Vector2i(dx, dz))
			if list == null:
				continue
			for obstacle: Vector3 in (list as Array):
				var ox: float = pos.x - obstacle.x
				var oz: float = pos.z - obstacle.y
				var reach: float = obstacle.z + radius
				if ox * ox + oz * oz < reach * reach:
					return true
	return false


func _hits_gate(pos: Vector3, radius: float) -> bool:
	for id: Variant in _gate_blockers.keys():
		if _open_gates.has(id):
			continue
		var blocker: Vector3 = _gate_blockers[id] as Vector3
		var reach: float = BuffetLayout.GATE_BLOCKER_RADIUS + radius
		if Vector2(pos.x - blocker.x, pos.z - blocker.z).length_squared() < reach * reach:
			return true
	return false


func _index_obstacles() -> void:
	for obstacle: Vector3 in layout.obstacles:
		_add_obstacle(obstacle)
	for id: String in layout.gate_positions.keys():
		var gate_pos: Vector3 = layout.gate_positions[id] as Vector3
		_gate_blockers[id] = gate_pos


# ---- Terrain ----------------------------------------------------------------------------------------


static func _noise(x: float, z: float) -> float:
	return fposmod(sin(x * 12.9898 + z * 78.233) * 43758.5453, 1.0)


func _tri(surface: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, color: Color) -> void:
	for vertex: Vector3 in [a, b, c]:
		surface.set_color(color)
		surface.add_vertex(vertex)


func _vertex(x: float, z: float) -> Vector3:
	var edge: float = BuffetLayout.edge_distance(x, z)
	if edge < 0.0:
		# Outside the table: collapse the vertex onto the outline (a couple of Newton steps along the distance gradient) at the rim height, so the terrain ends in a clean
		# curve instead of a sawtooth of grid triangles dropping away; the table rim below hangs from this edge.
		var snapped: Vector2 = Vector2(x, z)
		for i: int in range(3):
			var here: float = BuffetLayout.edge_distance(snapped.x, snapped.y)
			var gradient: Vector2 = Vector2(
				BuffetLayout.edge_distance(snapped.x + 0.01, snapped.y) - BuffetLayout.edge_distance(snapped.x - 0.01, snapped.y),
				BuffetLayout.edge_distance(snapped.x, snapped.y + 0.01) - BuffetLayout.edge_distance(snapped.x, snapped.y - 0.01)).normalized()
			snapped += gradient * (0.02 - here)
		return Vector3(snapped.x, layout.ground_height(snapped.x, snapped.y), snapped.y)
	return Vector3(x, layout.ground_height(x, z), z)


## The painted colour of a terrain triangle: region tints on top, banded sides on cliffs, cake rim at the edge.
func _terrain_color(centroid: Vector3) -> Color:
	var x: float = centroid.x
	var z: float = centroid.z
	var jitter: float = (_noise(x * 0.7, z * 0.7) - 0.5) * 0.02
	var edge: float = BuffetLayout.edge_distance(x, z)
	if edge < 0.0:
		return M.CHEESE.darkened(clampf(absf(centroid.y) / 8.0, 0.0, 0.3))
	var surface: BuffetLayout.Surface = layout.surface_at(x, z)
	if surface == BuffetLayout.Surface.CLIFF:
		for mesa: BuffetLayout.Mesa in layout.mesas:
			if Vector2(x - mesa.center.x, z - mesa.center.y).length() <= mesa.radius + BuffetLayout.CLIFF_WIDTH + 0.1:
				var stripe: int = int(floorf(centroid.y / 0.55)) % 2
				match mesa.style:
					"pancake":
						return (M.PANCAKE if stripe == 0 else M.PANCAKE_DARK).lightened(jitter)
					"cheese":
						return (M.CHEESE if stripe == 0 else M.CHEESE_DARK).lightened(jitter)
					_:
						return (M.BUTTER if stripe == 0 else M.BUTTER.darkened(0.12)).lightened(jitter)
	if surface == BuffetLayout.Surface.MESA:
		for mesa: BuffetLayout.Mesa in layout.mesas:
			if Vector2(x - mesa.center.x, z - mesa.center.y).length() <= mesa.radius:
				match mesa.style:
					"pancake":
						return M.PANCAKE.lightened(0.08 + jitter)
					"cheese":
						return M.CHEESE.lightened(0.05 + jitter)
					_:
						return M.BUTTER.lightened(0.05 + jitter)
	var depth: float = layout.soup_depth(x, z)
	if depth > -0.4:
		return M.GRAVY_DEEP.lerp(M.GRAVY, 0.3).lightened(jitter)
	var color: Color = M.CREAM.lerp(M.CREAM_SHADE, clampf((centroid.y + 1.2) / -2.0, 0.0, 1.0) * 0.5).lightened(jitter)
	# A gravy stain along the banks.
	if depth > -2.0:
		color = color.lerp(M.CREAM_SHADE.darkened(0.12), smoothstep(-2.0, -0.4, depth) * 0.7)
	var area: BuffetLayout.Area = layout.area_at(x, z)
	if area != null:
		match area.id:
			"forest":
				color = color.lerp(M.LETTUCE.lightened(0.05), 0.6)
			"candy":
				var checker: bool = _checker(x, z, 2.5)
				color = color.lerp(M.PINK if checker else M.MINT, 0.65)
			"hub":
				var tile: bool = _checker(x, z, 2.5)
				color = Color(0.96, 0.9, 0.78) if tile else Color(0.82, 0.42, 0.3)
			"cheddar", "cheddar_top":
				color = color.lerp(M.CHEESE, 0.55)
			"cake":
				var frosting: bool = _checker(x, z, 3.75)
				color = color.lerp(M.PINK if frosting else M.VANILLA, 0.55)
			"pancake", "pancake_top":
				color = color.lerp(M.PANCAKE, 0.5)
			"salt":
				color = color.lerp(Color(1, 1, 1), 0.6)
	var hub_distance: float = Vector2(x - 50.0, z - 64.0).length()
	if hub_distance < 12.5 and (area == null or area.id != "hub"):
		var tile2: bool = _checker(x, z, 2.5)
		color = color.lerp(Color(0.96, 0.9, 0.78) if tile2 else Color(0.82, 0.42, 0.3), 1.0 - smoothstep(9.0, 12.5, hub_distance))
	var path: float = layout.path_weight(x, z)
	if path > 0.0 and surface == BuffetLayout.Surface.GROUND:
		color = color.lerp(M.TOAST.lightened(0.15 + jitter), path * 0.8)
	return color


func _build_terrain() -> void:
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_smooth_group(-1)
	var step: float = BuffetLayout.TERRAIN_STEP
	var x0: float = BuffetLayout.MIN_CORNER.x - 2.0 * step
	var z0: float = BuffetLayout.MIN_CORNER.y - 2.0 * step
	var cols: int = int(ceilf((BuffetLayout.MAX_CORNER.x - BuffetLayout.MIN_CORNER.x) / step)) + 4
	var rows: int = int(ceilf((BuffetLayout.MAX_CORNER.y - BuffetLayout.MIN_CORNER.y) / step)) + 4
	for row: int in range(rows):
		for col: int in range(cols):
			var x: float = x0 + float(col) * step
			var z: float = z0 + float(row) * step
			var p00: Vector3 = _vertex(x, z)
			var p10: Vector3 = _vertex(x + step, z)
			var p01: Vector3 = _vertex(x, z + step)
			var p11: Vector3 = _vertex(x + step, z + step)
			var c1: Vector3 = (p00 + p10 + p11) / 3.0
			var c2: Vector3 = (p00 + p11 + p01) / 3.0
			_tri(surface, p00, p10, p11, _terrain_color(c1))
			_tri(surface, p00, p11, p01, _terrain_color(c2))
	surface.generate_normals()
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = surface.commit()
	instance.material_override = M.terrain()
	instance.name = "Table"
	root.add_child(instance)


## The rim of the table: a stack of rounded-rectangle layers (cheese, frosting, sponge) hanging below the edge,
## tapering inwards, so the zone reads as a giant layer cake on a giant table.
func _build_table_rim() -> void:
	var layers: Array[Dictionary] = [
		{"top": -0.6, "bottom": -3.0, "inset": -0.3, "color": M.CHEESE},
		{"top": -3.0, "bottom": -4.4, "inset": 0.2, "color": M.PINK},
		{"top": -4.4, "bottom": -7.6, "inset": 0.8, "color": M.CHOCOLATE},
		{"top": -7.6, "bottom": -9.0, "inset": 1.6, "color": M.VANILLA},
		{"top": -9.0, "bottom": -13.0, "inset": 2.8, "color": M.PANCAKE_DARK},
		{"top": -13.0, "bottom": -18.0, "inset": 5.0, "color": M.CHEESE_DARK},
	]
	for layer: Dictionary in layers:
		var outline: PackedVector2Array = _outline(float(layer["inset"]))
		var surface: SurfaceTool = SurfaceTool.new()
		surface.begin(Mesh.PRIMITIVE_TRIANGLES)
		surface.set_smooth_group(-1)
		var color: Color = layer["color"] as Color
		for index: int in range(outline.size()):
			var a: Vector2 = outline[index]
			var b: Vector2 = outline[(index + 1) % outline.size()]
			var shade: Color = color.lightened((_noise(a.x, a.y) - 0.5) * 0.1)
			var top: float = float(layer["top"])
			var bottom: float = float(layer["bottom"])
			_tri(surface, Vector3(a.x, top, a.y), Vector3(b.x, top, b.y), Vector3(a.x, bottom, a.y), shade)
			_tri(surface, Vector3(b.x, top, b.y), Vector3(b.x, bottom, b.y), Vector3(a.x, bottom, a.y), shade.darkened(0.04))
		surface.generate_normals()
		var instance: MeshInstance3D = MeshInstance3D.new()
		instance.mesh = surface.commit()
		instance.material_override = M.terrain()
		instance.name = "RimLayer"
		root.add_child(instance)


func _outline(inset: float) -> PackedVector2Array:
	var points: PackedVector2Array = PackedVector2Array()
	var low: Vector2 = BuffetLayout.MIN_CORNER + Vector2(inset, inset)
	var high: Vector2 = BuffetLayout.MAX_CORNER - Vector2(inset, inset)
	var radius: float = maxf(BuffetLayout.CORNER_RADIUS - inset, 1.0)
	var corners: Array[Vector2] = [Vector2(high.x - radius, low.y + radius), Vector2(high.x - radius, high.y - radius), Vector2(low.x + radius, high.y - radius), Vector2(low.x + radius, low.y + radius)]
	var arc_steps: int = 8
	for corner_index: int in range(4):
		var start: float = -PI * 0.5 + float(corner_index) * PI * 0.5
		for step: int in range(arc_steps + 1):
			var angle: float = start + PI * 0.5 * float(step) / float(arc_steps)
			points.append(corners[corner_index] + Vector2(cos(angle), sin(angle)) * radius)
	return points


# ---- Soup -------------------------------------------------------------------------------------------


func _build_soup() -> void:
	var soup: StandardMaterial3D = M.soup()
	_soup_materials.append(soup)
	# The river as a long strip following the meander.
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_smooth_group(-1)
	var half: float = BuffetLayout.RIVER_HALF_WIDTH + 1.0
	var x: float = BuffetLayout.MIN_CORNER.x - 1.0
	var step: float = 1.5
	while x < BuffetLayout.MAX_CORNER.x + 1.0:
		var z_a: float = BuffetLayout.river_z(x)
		var z_b: float = BuffetLayout.river_z(x + step)
		var a0: Vector3 = Vector3(x, BuffetLayout.SOUP_LEVEL, z_a - half)
		var a1: Vector3 = Vector3(x, BuffetLayout.SOUP_LEVEL, z_a + half)
		var b0: Vector3 = Vector3(x + step, BuffetLayout.SOUP_LEVEL, z_b - half)
		var b1: Vector3 = Vector3(x + step, BuffetLayout.SOUP_LEVEL, z_b + half)
		_tri(surface, a0, b0, a1, Color(1, 1, 1))
		_tri(surface, b0, b1, a1, Color(1, 1, 1))
		x += step
	surface.generate_normals()
	var river: MeshInstance3D = MeshInstance3D.new()
	river.mesh = surface.commit()
	river.material_override = soup
	river.name = "GravyRiver"
	root.add_child(river)
	for pond: Vector3 in layout.ponds:
		var disc: CylinderMesh = CylinderMesh.new()
		disc.top_radius = pond.z + 0.9
		disc.bottom_radius = pond.z + 0.9
		disc.height = 0.04
		disc.radial_segments = 24
		var instance: MeshInstance3D = MeshInstance3D.new()
		instance.mesh = disc
		instance.material_override = soup
		instance.position = Vector3(pond.x, BuffetLayout.SOUP_LEVEL, pond.y)
		instance.name = "GravyPond"
		root.add_child(instance)
		P.steam(root, Vector3(pond.x, 0.3, pond.y), 6, pond.z * 0.5, 0.8)
	# Steam rising off the river here and there, and floating peas.
	var steam_x: float = 14.0
	while steam_x < 90.0:
		P.steam(root, Vector3(steam_x, 0.2, BuffetLayout.river_z(steam_x)), 5, 1.4, 0.9)
		steam_x += 17.0
	for index: int in range(26):
		var pea_x: float = 6.0 + float(index) * 3.5
		var pea_z: float = BuffetLayout.river_z(pea_x) + sin(float(index) * 1.7) * 2.2
		if layout.susan_under(pea_x, pea_z, 1.0) != null or layout.raft_under(pea_x, pea_z, 0.0, 3.0) != null or layout.raft_under(pea_x, pea_z, 5.5, 3.0) != null:
			continue
		var pea: MeshInstance3D = P.ball(root, 0.2, M.flat(Color(0.45, 0.78, 0.25)), Vector3(pea_x, BuffetLayout.SOUP_LEVEL + 0.05, pea_z), Vector3(1, 0.7, 1))
		pea.name = "Pea"


func _build_tablecloth() -> void:
	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(420.0, 420.0)
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = plane
	instance.material_override = M.tablecloth()
	instance.position = Vector3(50.0, -26.0, 40.0)
	instance.name = "Tablecloth"
	root.add_child(instance)


# ---- Platforms and pads ---------------------------------------------------------------------------


func _build_platforms() -> void:
	for raft: BuffetLayout.Raft in layout.rafts:
		var node: Node3D = P.raft()
		node.name = raft.id
		root.add_child(node)
		var pos: Vector2 = layout.raft_position(raft, 0.0)
		node.position = Vector3(pos.x, 0.0, pos.y)
		raft_nodes[raft.id] = node
		raft_delta[raft.id] = Vector2.ZERO
	for susan: BuffetLayout.Susan in layout.susans:
		var node: Node3D = P.susan(susan.radius)
		node.name = susan.id
		root.add_child(node)
		node.position = Vector3(susan.center.x, 0.0, susan.center.y)
		susan_nodes.append(node)


func _build_pads() -> void:
	for pad: BuffetLayout.Pad in layout.pads:
		var node: Node3D = P.jelly_pad(pad.color, pad.radius)
		node.name = pad.id
		root.add_child(node)
		node.position = Vector3(pad.pos.x, layout.ground_height(pad.pos.x, pad.pos.y), pad.pos.y)
		pad_nodes[pad.id] = node


# ---- Props ----------------------------------------------------------------------------------------------


func _ground(x: float, z: float) -> Vector3:
	return Vector3(x, layout.ground_height(x, z), z)


func _build_props() -> void:
	var transforms: Dictionary = {}
	for prop: BuffetLayout.Prop in layout.props:
		var pos: Vector3 = _ground(prop.pos.x, prop.pos.z)
		match prop.kind:
			"broccoli":
				_collect(transforms, "broccoli", prop, pos, 4.4)
			"cauliflower":
				_collect(transforms, "cauliflower", prop, pos, 3.8)
			"cabbage":
				_collect(transforms, "cabbage", prop, pos, 3.6)
			"cupcake":
				_collect(transforms, "cupcake", prop, pos, 3.4)
			"muffin":
				_collect(transforms, "muffin", prop, pos, 3.4)
			"cheese_block":
				_collect(transforms, "cheese", prop, pos, 2.0)
			_:
				_place_feature(prop, pos)
	for model: String in transforms.keys():
		_add_multimesh(model, transforms[model] as Array)


func _collect(transforms: Dictionary, model: String, prop: BuffetLayout.Prop, pos: Vector3, base_scale: float) -> void:
	var list: Array = transforms.get(model, []) as Array
	var basis: Basis = Basis(Vector3.UP, deg_to_rad(prop.yaw)).scaled(Vector3.ONE * prop.model_scale * base_scale)
	list.append(Transform3D(basis, pos))
	transforms[model] = list


## One shared mesh drawn many times (broccoli, cupcakes...): a MultiMesh per mesh of a Food Kit model.
func _add_multimesh(model: String, transforms: Array) -> void:
	if transforms.is_empty():
		return
	var source: Node3D = BuffetModels.food(model)
	for child: Node in source.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance: MeshInstance3D = child as MeshInstance3D
		var local: Transform3D = Transform3D.IDENTITY
		var walker: Node = mesh_instance
		while walker != source and walker != null:
			if walker is Node3D:
				local = (walker as Node3D).transform * local
			walker = walker.get_parent()
		var multimesh: MultiMesh = MultiMesh.new()
		multimesh.transform_format = MultiMesh.TRANSFORM_3D
		multimesh.mesh = mesh_instance.mesh
		multimesh.instance_count = transforms.size()
		for index: int in range(transforms.size()):
			multimesh.set_instance_transform(index, (transforms[index] as Transform3D) * local)
		var holder: MultiMeshInstance3D = MultiMeshInstance3D.new()
		holder.multimesh = multimesh
		holder.name = "MM_" + model
		var material: Material = mesh_instance.get_active_material(0)
		if material != null:
			holder.material_override = material
		root.add_child(holder)
	source.queue_free()


func _place_feature(prop: BuffetLayout.Prop, pos: Vector3) -> void:
	var node: Node3D = null
	match prop.kind:
		"cabinet":
			node = P.kitchen_row(prop.variant if prop.pos.x < 50.0 else prop.variant + 1)
		"fountain":
			node = P.soup_fountain()
			if node.has_node("Stream"):
				_fountain_streams.append(node.get_node("Stream") as Node3D)
		"table":
			node = P.hearty_table()
		"stall":
			node = P.vendor_stall()
		"oven":
			node = P.grand_oven()
		"arch":
			node = P.exit_arch(story)
		"dispenser":
			node = P.dispenser(story)
		"broken_golem":
			node = P.broken_golem(story)
		"hub_pot":
			node = P.hub_pot()
		"gazebo":
			node = P.bread_gazebo()
		"bread_hollow":
			node = P.bread_hollow()
		"stage":
			node = P.chef_stage(story)
		"taste_station":
			node = P.taste_station()
		"candy_jar":
			node = P.candy_jar()
		"shaker":
			node = P.shaker(prop.variant)
		"butter_pat":
			node = P.butter_pat()
		"layer_cake":
			node = P.layer_cake(prop.variant)
		"freezer":
			node = P.freezer(story)
		"kitchen_door":
			node = P.closed_kitchen(story)
		"cheese_wheel":
			node = P.cheese_wheel(prop.variant)
		"stew_pot":
			node = P.stew_pot(story)
		"pancake_stack":
			node = P.pancake_stack(prop.variant)
		"mill_pillar":
			node = P.mill_pillar()
			pos.y = 0.0
		"fence_fork":
			node = P.fence_fork(prop.variant)
		"divider":
			node = P.divider_post(prop.variant)
		"lollipop":
			node = P.lollipop(prop.variant)
		"sundae":
			node = BuffetModels.food("sundae")
			node.scale = Vector3.ONE * 5.0
		"fork":
			node = _standing_cutlery("utensil-fork", 7.0)
		"spoon":
			node = _standing_cutlery("utensil-spoon", 7.0)
		"knife":
			node = _standing_cutlery("utensil-knife", 6.5)
		"donut_arch":
			node = _donut_arch()
		_:
			return
	root.add_child(node)
	node.position = pos
	node.rotation_degrees.y = prop.yaw
	if node.scale == Vector3.ONE and prop.model_scale != 1.0 and prop.kind in ["layer_cake", "cheese_wheel", "sundae"]:
		node.scale = Vector3.ONE * prop.model_scale
	elif prop.kind == "cheese_wheel" or prop.kind == "layer_cake":
		node.scale = Vector3.ONE * prop.model_scale


func _standing_cutlery(model: String, model_scale: float) -> Node3D:
	var holder: Node3D = Node3D.new()
	var piece: Node3D = BuffetModels.food(model)
	holder.add_child(piece)
	piece.scale = Vector3.ONE * model_scale
	piece.rotation_degrees = Vector3(0, 0, 80)
	return holder


func _donut_arch() -> Node3D:
	var holder: Node3D = Node3D.new()
	var donut: Node3D = BuffetModels.food("donut-sprinkles")
	holder.add_child(donut)
	donut.scale = Vector3.ONE * 13.0
	donut.rotation_degrees = Vector3(90, 0, 0)
	donut.position = Vector3(0, 1.6, 0)
	return holder


# ---- Gates ----------------------------------------------------------------------------------------------


func _build_gates() -> void:
	for gate: BuffetGates.Gate in BuffetGates.gates():
		var pos: Vector3 = layout.gate_positions[gate.id] as Vector3
		var node: Node3D = MOBS.gate_golem(gate.id)
		node.name = "Gate_" + gate.id
		root.add_child(node)
		node.position = _ground(pos.x, pos.z)
		gate_nodes[gate.id] = node


## Where a gate's golem stands when the gate is open (beside the gap, behind the fence).
func gate_open_position(gate_id: String) -> Vector3:
	var pos: Vector3 = layout.gate_positions[gate_id] as Vector3
	return _ground(pos.x + 4.2, pos.z - 1.6)


# ---- Signs and chests -------------------------------------------------------------------------------------


func _build_signs() -> void:
	for sign: BuffetLayout.Sign in layout.signs:
		var lines: Array[String] = story.get_lines(sign.key)
		var longest: int = 0
		for line: String in lines:
			longest = maxi(longest, line.length())
		var width: float = clampf(float(longest) * 0.07 * sign.size + 0.7, 1.8, 3.8)
		var wrapped: int = 0
		for line: String in lines:
			wrapped += maxi(1, int(ceilf(float(line.length()) * 0.07 * sign.size / (width - 0.5))))
		var height: float = clampf(0.5 + 0.34 * float(wrapped) * sign.size, 0.9, 3.0)
		var node: Node3D = P.sign_post(width, height, sign.style)
		node.set_meta(PaintedClasses.META_NO_PAINT, true)  # signs stay plain so their text reads
		node.scale = Vector3.ONE * 0.6
		var pos: Vector3 = _ground(sign.pos.x, sign.pos.z)
		root.add_child(node)
		node.position = pos
		node.rotation_degrees.y = sign.yaw + 180.0
		var text_color: Color = Color(0.95, 0.95, 0.85) if sign.style == "menu" else Color(0.26, 0.12, 0.05)
		var text: Label3D = Label3D.new()
		text.text = "\n".join(lines)
		text.font = UIStyle.font_title()
		text.font_size = 40
		text.pixel_size = 0.0058 * sign.size
		text.modulate = text_color
		text.outline_size = 0
		text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		text.width = (width - 0.4) / text.pixel_size
		text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		text.double_sided = false
		var mid: float = 1.45 + height * 0.5
		if sign.style == "poster":
			mid = 1.4 + height * 0.5
		elif sign.style == "memo":
			mid = 1.1 + height * 0.5
		elif sign.style == "menu":
			mid = 1.3 + height * 0.5
		text.position = Vector3(0, mid, 0.1)
		node.add_child(text)


func _build_chests() -> void:
	var positions: Dictionary = chest_positions()
	for id: String in positions.keys():
		var pos: Vector3 = positions[id] as Vector3
		var chest: Node3D = ModelKit.dungeon_prop("chest_gold")
		root.add_child(chest)
		chest.position = pos
		chest.rotation_degrees.y = _rng.randf() * 360.0
		chest.scale = Vector3.ONE * 0.225
		chest_nodes[id] = chest


# ---- Animation -----------------------------------------------------------------------------------------


func animate(delta: float) -> void:
	time += delta
	for raft: BuffetLayout.Raft in layout.rafts:
		var node: Node3D = raft_nodes[raft.id] as Node3D
		var pos: Vector2 = layout.raft_position(raft, time)
		raft_delta[raft.id] = pos - Vector2(node.position.x, node.position.z)
		node.position = Vector3(pos.x, 0.02 + sin(time * 1.6 + raft.offset) * 0.03, pos.y)
		node.rotation.z = sin(time * 1.3 + raft.offset) * 0.02
	susan_delta = BuffetLayout.SUSAN_OMEGA * delta
	susan_angle += susan_delta
	for node: Node3D in susan_nodes:
		node.rotation.y = -susan_angle
	for key: String in pad_nodes.keys():
		var pad_node: Node3D = pad_nodes[key] as Node3D
		var dome: Node3D = pad_node.get_meta("dome") as Node3D
		var wobble: float = sin(time * 3.1 + pad_node.position.x)
		dome.scale = Vector3(1.0 - 0.035 * wobble, 1.0 + 0.07 * wobble, 1.0 - 0.035 * wobble)
	for material: StandardMaterial3D in _soup_materials:
		material.emission_energy_multiplier = 0.28 + 0.1 * sin(time * 1.4)
	for stream: Node3D in _fountain_streams:
		stream.scale.y = 1.0 + 0.15 * sin(time * 6.0)


## Checker pattern whose cell edges fall exactly on terrain grid lines (`size` must be a multiple of the grid step), so every triangle lies inside one cell and the boundaries are straight.
func _checker(x: float, z: float, size: float) -> bool:
	var origin_x: float = BuffetLayout.MIN_CORNER.x - 2.0 * BuffetLayout.TERRAIN_STEP
	var origin_z: float = BuffetLayout.MIN_CORNER.y - 2.0 * BuffetLayout.TERRAIN_STEP
	return (int(floorf((x - origin_x) / size)) + int(floorf((z - origin_z) / size))) % 2 == 0
