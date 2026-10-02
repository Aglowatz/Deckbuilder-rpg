class_name DnaBuilder
extends ZoneMap
## Turns a `DnaLayout` into the D.N.A.'s 3D world and answers walkability queries.
##
## Performance design (the zone is ~3x the town):
##  - The map is split into CHUNK x CHUNK cell chunks. Floors are one merged mesh per chunk and floor
##    kind, walls and cabinets one MultiMesh per chunk, and every prop model is batched into one
##    MultiMesh per (chunk, model part) - a whole cubicle farm is a handful of draw calls.
##  - `update_visibility()` hides chunks beyond VIEW_RADIUS of the player each frame (on top of
##    Godot's own frustum culling); the fog hides the cut-off.
##  - Real lights are pooled in `DnaScene` (a few OmniLights that hop between nearby fixtures)
##    instead of one per fixture.

const CHUNK: int = 10
const VIEW_RADIUS: float = 30.0
const WALL_HEIGHT: float = 1.25
const CABINET_HEIGHT: float = 1.15

const KENNEY_FURNITURE: String = "res://assets/kenney-furniture-kit/models/"
const KENNEY_GRAVEYARD: String = "res://assets/kenney-graveyard-kit/models/"
const KAYKIT_HALLOWEEN: String = "res://assets/KayKit-Halloween-Bits-1.0/gltf/"

var layout: DnaLayout = DnaLayout.new()
var root: Node3D
## chunk (Vector2i) -> Node3D
var chunks: Dictionary = {}
## Circular obstacles bucketed by 2x2 cell: Vector2i -> Array[Vector3(x, z, radius)].
var _buckets: Dictionary = {}
## Set by the scene: a cell that is temporarily blocked (e.g. a sealed door) -> true.
var blocked_cells: Dictionary = {}

static var _scene_cache: Dictionary = {}
static var _part_cache: Dictionary = {}

var _batches: Dictionary = {}
var _floor_quads: Dictionary = {}
var _wall_transforms: Dictionary = {}
var _cabinet_transforms: Dictionary = {}
var _light_transforms: Dictionary = {}
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func build(parent: Node3D) -> void:
	_rng.seed = 88
	layout.build()
	root = Node3D.new()
	root.name = "DnaZone"
	parent.add_child(root)
	_collect_cells()
	_collect_props()
	_collect_lights()
	_collect_partitions()
	_flush()
	_build_signs()
	_build_set_pieces()
	_index_obstacles()


func cell_center(cx: int, cz: int) -> Vector3:
	return DnaLayout.cell_center(cx, cz)


func anchor(name: String) -> Vector3:
	return layout.anchors.get(name, Vector3.ZERO) as Vector3


func has_anchor(name: String) -> bool:
	return layout.anchors.has(name)


func chest_positions() -> Dictionary:
	return layout.chests


func enemy_spawns() -> Array[Dictionary]:
	return layout.enemy_spawns


func area_at(pos: Vector3) -> Array[String]:
	var room: DnaLayout.Room = layout.room_at(pos)
	if room == null:
		return [] as Array[String]
	return [room.id, room.title] as Array[String]


func is_floor_at(pos: Vector3) -> bool:
	var cell: Vector2i = DnaLayout.world_to_cell(pos)
	return layout.is_floor(cell.x, cell.y)


func map_bounds() -> Rect2:
	return Rect2(0.0, 0.0, float(DnaLayout.W), float(DnaLayout.H))


# ---- Chunks ----------------------------------------------------------------------------------


func _chunk_key(pos: Vector3) -> Vector2i:
	return Vector2i(int(floorf(pos.x / float(CHUNK))), int(floorf(pos.z / float(CHUNK))))


func chunk_node(key: Vector2i) -> Node3D:
	if not chunks.has(key):
		var node: Node3D = Node3D.new()
		node.name = "Chunk_%d_%d" % [key.x, key.y]
		root.add_child(node)
		chunks[key] = node
	return chunks[key] as Node3D


func chunk_for(pos: Vector3) -> Node3D:
	return chunk_node(_chunk_key(pos))


## Shows only the chunks near `focus` (a cheap distance test per chunk, run every frame).
func update_visibility(focus: Vector3) -> void:
	for key: Vector2i in chunks.keys():
		var center: Vector3 = Vector3((float(key.x) + 0.5) * float(CHUNK), 0.0, (float(key.y) + 0.5) * float(CHUNK))
		var near: bool = Vector2(center.x - focus.x, center.z - focus.z).length() < VIEW_RADIUS + float(CHUNK) * 0.7
		var node: Node3D = chunks[key] as Node3D
		if node.visible != near:
			node.visible = near


# ---- Cells: floors, walls, cabinets ---------------------------------------------------------


func _collect_cells() -> void:
	for cz: int in range(DnaLayout.H):
		for cx: int in range(DnaLayout.W):
			var cell: DnaLayout.Cell = layout.cell_at(cx, cz)
			if cell == DnaLayout.Cell.VOID:
				continue
			var center: Vector3 = cell_center(cx, cz)
			var key: Vector2i = _chunk_key(center)
			if cell == DnaLayout.Cell.WALL:
				var list: Array = _wall_transforms.get(key, []) as Array
				var xform: Transform3D = Transform3D(Basis.from_scale(Vector3(1.0, WALL_HEIGHT, 1.0)), center + Vector3(0, WALL_HEIGHT * 0.5, 0))
				list.append(xform)
				_wall_transforms[key] = list
				continue
			var floor_kind: DnaLayout.Floor = layout.floor_at(cx, cz)
			if floor_kind == DnaLayout.Floor.NONE:
				floor_kind = DnaLayout.Floor.CONCRETE
			var quads: Dictionary = _floor_quads.get(key, {}) as Dictionary
			var cell_list: Array = quads.get(floor_kind, []) as Array
			cell_list.append(Vector2i(cx, cz))
			quads[floor_kind] = cell_list
			_floor_quads[key] = quads
			if cell == DnaLayout.Cell.SOLID:
				var cab_list: Array = _cabinet_transforms.get(key, []) as Array
				cab_list.append(Transform3D(Basis.from_scale(Vector3(0.98, CABINET_HEIGHT, 0.98)), center + Vector3(0, CABINET_HEIGHT * 0.5, 0)))
				_cabinet_transforms[key] = cab_list


# ---- Props (batched) -------------------------------------------------------------------------


static func model_path(model: String) -> String:
	for base: String in [KENNEY_FURNITURE, KENNEY_GRAVEYARD]:
		if ResourceLoader.exists(base + model + ".glb"):
			return base + model + ".glb"
	if ResourceLoader.exists(KAYKIT_HALLOWEEN + model + ".gltf"):
		return KAYKIT_HALLOWEEN + model + ".gltf"
	return ""


static func model_scene(model: String) -> PackedScene:
	if not _scene_cache.has(model):
		var path: String = model_path(model)
		_scene_cache[model] = load(path) as PackedScene if not path.is_empty() else null
		if path.is_empty():
			push_warning("DnaBuilder: missing model %s" % model)
	return _scene_cache[model] as PackedScene


## The graded mesh parts of a model: [{mesh, xform}] relative to the model's root.
static func model_parts(model: String) -> Array:
	if _part_cache.has(model):
		return _part_cache[model] as Array
	var parts: Array = []
	var packed: PackedScene = model_scene(model)
	if packed != null:
		var node: Node3D = packed.instantiate() as Node3D
		for child: Node in node.find_children("*", "MeshInstance3D", true, false):
			var mesh_instance: MeshInstance3D = child as MeshInstance3D
			if mesh_instance.mesh == null:
				continue
			var xform: Transform3D = Transform3D.IDENTITY
			var walker: Node = mesh_instance
			while walker != node and walker != null:
				if walker is Node3D:
					xform = (walker as Node3D).transform * xform
				walker = walker.get_parent()
			parts.append({"mesh": DnaMaterials.graded_mesh(mesh_instance.mesh), "xform": xform})
		node.free()
	_part_cache[model] = parts
	return parts


func _collect_props() -> void:
	for prop: DnaLayout.Prop in layout.props:
		if prop.model.is_empty():
			continue
		var parts: Array = model_parts(prop.model)
		var basis: Basis = Basis(Vector3.UP, deg_to_rad(prop.yaw)) * Basis.from_scale(Vector3.ONE * prop.model_scale)
		var base: Transform3D = Transform3D(basis, prop.pos)
		var key: Vector2i = _chunk_key(prop.pos)
		for index: int in range(parts.size()):
			var part: Dictionary = parts[index] as Dictionary
			var batch_key: String = "%d,%d|%s|%d" % [key.x, key.y, prop.model, index]
			if not _batches.has(batch_key):
				_batches[batch_key] = {"chunk": key, "mesh": part["mesh"], "list": []}
			((_batches[batch_key] as Dictionary)["list"] as Array).append(base * (part["xform"] as Transform3D))


var _partition_transforms: Dictionary = {}


## Cubicle partition panels: thin fabric boxes along each partition segment.
func _collect_partitions() -> void:
	for seg: Vector4 in layout.partitions:
		var a: Vector3 = Vector3(seg.x, 0.0, seg.y)
		var b: Vector3 = Vector3(seg.z, 0.0, seg.w)
		var mid: Vector3 = (a + b) * 0.5
		var length: float = a.distance_to(b)
		var angle: float = atan2(b.z - a.z, b.x - a.x)
		var basis: Basis = Basis(Vector3.UP, -angle) * Basis.from_scale(Vector3(length, 0.78, 0.09))
		var key: Vector2i = _chunk_key(mid)
		var list: Array = _partition_transforms.get(key, []) as Array
		list.append(Transform3D(basis, mid + Vector3(0, 0.39, 0)))
		_partition_transforms[key] = list


func _collect_lights() -> void:
	for spot: DnaLayout.LightSpot in layout.lights:
		var key: Vector2i = _chunk_key(spot.pos)
		var index_key: String = "%d,%d|%d|%s" % [key.x, key.y, spot.group, spot.color.to_html()]
		if not _light_transforms.has(index_key):
			_light_transforms[index_key] = {"chunk": key, "group": spot.group, "color": spot.color, "list": []}
		var xform: Transform3D = Transform3D(Basis.IDENTITY, spot.pos)
		((_light_transforms[index_key] as Dictionary)["list"] as Array).append(xform)


func _flush() -> void:
	# Floors: one merged mesh per chunk, one surface per floor kind.
	for key: Vector2i in _floor_quads.keys():
		var mesh: ArrayMesh = ArrayMesh.new()
		var by_kind: Dictionary = _floor_quads[key] as Dictionary
		for kind: Variant in by_kind.keys():
			var tool: SurfaceTool = SurfaceTool.new()
			tool.begin(Mesh.PRIMITIVE_TRIANGLES)
			tool.set_normal(Vector3.UP)
			for cell: Variant in (by_kind[kind] as Array):
				var c: Vector2i = cell as Vector2i
				var x0: float = float(c.x)
				var z0: float = float(c.y)
				for corner: Vector2 in [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 0), Vector2(1, 1), Vector2(0, 1)]:
					tool.add_vertex(Vector3(x0 + corner.x, 0.0, z0 + corner.y))
			var surface_mesh: ArrayMesh = tool.commit()
			mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_mesh.surface_get_arrays(0))
			mesh.surface_set_material(mesh.get_surface_count() - 1, DnaMaterials.floor_material(kind as DnaLayout.Floor))
		var instance: MeshInstance3D = MeshInstance3D.new()
		instance.mesh = mesh
		instance.name = "Floor"
		chunk_node(key).add_child(instance)
	for key: Vector2i in _wall_transforms.keys():
		_add_multimesh(key, _box_mesh(), DnaMaterials.wall_material(), _wall_transforms[key] as Array, "Walls", false)
	for key: Vector2i in _cabinet_transforms.keys():
		_add_multimesh(key, _box_mesh(), DnaMaterials.cabinet_material(), _cabinet_transforms[key] as Array, "Cabinets", true)
	for key: Vector2i in _partition_transforms.keys():
		_add_multimesh(key, _box_mesh(), _partition_material(), _partition_transforms[key] as Array, "Partitions", true)
	for batch_key: String in _batches.keys():
		var batch: Dictionary = _batches[batch_key] as Dictionary
		_add_multimesh(batch["chunk"] as Vector2i, batch["mesh"] as Mesh, null, batch["list"] as Array, "Props", true)
	for entry: Variant in _light_transforms.values():
		var data: Dictionary = entry as Dictionary
		var tube: BoxMesh = BoxMesh.new()
		tube.size = Vector3(0.9, 0.05, 0.16)
		_add_multimesh(data["chunk"] as Vector2i, tube, DnaMaterials.glow_material(int(data["group"]), data["color"] as Color), data["list"] as Array, "Tubes", false)


static var _unit_box: BoxMesh
static var _partition_mat: StandardMaterial3D


static func _partition_material() -> StandardMaterial3D:
	if _partition_mat == null:
		_partition_mat = StandardMaterial3D.new()
		_partition_mat.albedo_color = Color(0.42, 0.56, 0.5)
		_partition_mat.roughness = 1.0
	return _partition_mat




static func _box_mesh() -> BoxMesh:
	if _unit_box == null:
		_unit_box = BoxMesh.new()
		_unit_box.size = Vector3.ONE
	return _unit_box


func _add_multimesh(key: Vector2i, mesh: Mesh, material: Material, transforms: Array, label: String, cast_shadow: bool) -> void:
	var multi: MultiMesh = MultiMesh.new()
	multi.transform_format = MultiMesh.TRANSFORM_3D
	multi.mesh = mesh
	multi.instance_count = transforms.size()
	for index: int in range(transforms.size()):
		multi.set_instance_transform(index, transforms[index] as Transform3D)
	var instance: MultiMeshInstance3D = MultiMeshInstance3D.new()
	instance.multimesh = multi
	instance.name = label
	if material != null:
		instance.material_override = material
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if cast_shadow else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	chunk_node(key).add_child(instance)


# ---- Signs ---------------------------------------------------------------------------------


func _build_signs() -> void:
	var story: ZoneStoryText = ZoneStoryText.shared()
	for sign_spec: DnaLayout.Sign in layout.signs:
		var holder: Node3D = Node3D.new()
		holder.position = sign_spec.pos
		holder.rotation_degrees.y = sign_spec.yaw
		chunk_for(sign_spec.pos).add_child(holder)
		var lines: Array[String] = story.get_lines(sign_spec.key)
		var panel_size: Vector2 = Vector2(1.5, 0.28 + 0.2 * float(lines.size())) * sign_spec.size
		var board: MeshInstance3D = MeshInstance3D.new()
		var quad: BoxMesh = BoxMesh.new()
		quad.size = Vector3(panel_size.x, panel_size.y, 0.04)
		board.mesh = quad
		var board_material: StandardMaterial3D = StandardMaterial3D.new()
		match sign_spec.style:
			"poster":
				board_material.albedo_color = Color(0.82, 0.8, 0.66)
			"memo":
				board_material.albedo_color = Color(0.9, 0.88, 0.5)
				board.scale = Vector3(0.7, 0.7, 1.0)
			_:
				board_material.albedo_color = Color(0.1, 0.16, 0.15)
		board.material_override = board_material
		holder.add_child(board)
		var label: Label3D = Label3D.new()
		label.text = "\n".join(lines)
		label.font = UIStyle.font_title() if sign_spec.style == "sign" else UIStyle.font_body()
		label.font_size = 36
		label.pixel_size = 0.0036 * sign_spec.size * (0.7 if sign_spec.style == "memo" else 1.0)
		label.outline_size = 0
		label.modulate = Color(0.75, 1.0, 0.85) if sign_spec.style == "sign" else Color(0.14, 0.12, 0.1)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.width = panel_size.x / label.pixel_size * 0.92
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.position = Vector3(0, 0, 0.03)
		holder.add_child(label)


# ---- Set pieces (doors, elevators, time clock...) --------------------------------------------


func _box(parent: Node3D, size: Vector3, pos: Vector3, color: Color, emissive: float = 0.0) -> MeshInstance3D:
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.7
	if emissive > 0.0:
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = emissive
	mesh_instance.material_override = material
	mesh_instance.position = pos
	parent.add_child(mesh_instance)
	return mesh_instance


func _build_set_pieces() -> void:
	# Elevators: a steel frame, two door leaves and an indicator lamp each.
	for key: String in ["elevator_1", "elevator_2", "mini_dungeon", "elevator_4"]:
		var pos: Vector3 = anchor(key)
		var piece: Node3D = Node3D.new()
		piece.position = Vector3(pos.x, 0.0, pos.z - 0.9)
		chunk_for(pos).add_child(piece)
		var live: bool = key == "mini_dungeon"
		_box(piece, Vector3(1.9, 1.6, 0.18), Vector3(0, 0.8, 0.0), Color(0.18, 0.22, 0.22))
		_box(piece, Vector3(0.78, 1.35, 0.1), Vector3(-0.41, 0.7, 0.1), Color(0.55, 0.62, 0.6))
		_box(piece, Vector3(0.78, 1.35, 0.1), Vector3(0.41, 0.7, 0.1), Color(0.5, 0.57, 0.55))
		_box(piece, Vector3(0.3, 0.1, 0.06), Vector3(0, 1.5, 0.12), Color(1.0, 0.55, 0.2) if live else Color(0.4, 0.5, 0.45), 2.0 if live else 0.2)
	# The main dungeon's locked door on the executive floor: big double doors, taped shut.
	var door_pos: Vector3 = anchor("main_dungeon")
	var door: Node3D = Node3D.new()
	door.position = Vector3(door_pos.x, 0.0, door_pos.z - 0.9)
	chunk_for(door_pos).add_child(door)
	_box(door, Vector3(3.0, 1.45, 0.2), Vector3(0, 0.72, 0.0), Color(0.2, 0.08, 0.08))
	_box(door, Vector3(1.3, 1.25, 0.12), Vector3(-0.68, 0.65, 0.12), Color(0.34, 0.12, 0.1))
	_box(door, Vector3(1.3, 1.25, 0.12), Vector3(0.68, 0.65, 0.12), Color(0.3, 0.11, 0.09))
	var tape_a: MeshInstance3D = _box(door, Vector3(3.2, 0.1, 0.06), Vector3(0, 0.95, 0.2), Color(1.0, 0.8, 0.1), 0.5)
	tape_a.rotation_degrees.z = 12.0
	var tape_b: MeshInstance3D = _box(door, Vector3(3.2, 0.1, 0.06), Vector3(0, 0.6, 0.2), Color(1.0, 0.8, 0.1), 0.5)
	tape_b.rotation_degrees.z = -10.0
	# The surface elevator (zone exit) on the lobby's south wall.
	var exit_pos: Vector3 = anchor("exit_door")
	var exit_piece: Node3D = Node3D.new()
	exit_piece.position = exit_pos + Vector3(0, 0, 0.0)
	chunk_for(exit_pos).add_child(exit_piece)
	_box(exit_piece, Vector3(1.9, 1.6, 0.18), Vector3(0, 0.8, -0.1), Color(0.18, 0.22, 0.22))
	_box(exit_piece, Vector3(0.78, 1.35, 0.1), Vector3(-0.41, 0.7, -0.22), Color(0.6, 0.65, 0.5))
	_box(exit_piece, Vector3(0.78, 1.35, 0.1), Vector3(0.41, 0.7, -0.22), Color(0.55, 0.6, 0.46))
	_box(exit_piece, Vector3(0.3, 0.1, 0.06), Vector3(0, 1.5, -0.24), Color(0.9, 0.95, 0.5), 2.0)
	# Time clock: a grey box with a glowing face on the breakroom's west wall.
	var clock_pos: Vector3 = anchor("time_clock")
	var clock: Node3D = Node3D.new()
	clock.position = Vector3(clock_pos.x - 0.35, 0.0, clock_pos.z)
	chunk_for(clock_pos).add_child(clock)
	_box(clock, Vector3(0.22, 0.55, 0.4), Vector3(0, 0.95, 0), Color(0.3, 0.33, 0.33))
	_box(clock, Vector3(0.05, 0.3, 0.28), Vector3(0.12, 1.02, 0), Color(0.9, 1.0, 0.7), 1.6)
	_box(clock, Vector3(0.1, 0.06, 0.34), Vector3(0.06, 0.78, 0), Color(0.1, 0.1, 0.1))
	# Suggestion box: a locked wooden box with a slot.
	var box_pos: Vector3 = anchor("suggestion")
	var suggestion: Node3D = Node3D.new()
	suggestion.position = Vector3(box_pos.x, 0.0, box_pos.z)
	chunk_for(box_pos).add_child(suggestion)
	_box(suggestion, Vector3(0.45, 0.7, 0.4), Vector3(0, 0.35, 0), Color(0.45, 0.3, 0.2))
	_box(suggestion, Vector3(0.3, 0.04, 0.03), Vector3(0, 0.66, 0.21), Color(0.05, 0.03, 0.03))
	# Printer: a grey body, a green status light and a paper tray (the haunted printer).
	var printer_pos: Vector3 = anchor("printer")
	var printer: Node3D = Node3D.new()
	printer.position = Vector3(printer_pos.x, 0.0, printer_pos.z)
	chunk_for(printer_pos).add_child(printer)
	_box(printer, Vector3(0.7, 0.55, 0.55), Vector3(0, 0.28, 0), Color(0.36, 0.4, 0.4))
	_box(printer, Vector3(0.6, 0.06, 0.45), Vector3(0, 0.58, 0), Color(0.5, 0.54, 0.52))
	_box(printer, Vector3(0.06, 0.06, 0.06), Vector3(0.25, 0.5, 0.29), Color(0.4, 1.0, 0.5), 3.0)
	# Pneumatic tubes in the mail room: pipes along the north wall with capsules racing through.
	_build_tube_network()
	# Hidden chests (the same 1/4-scale gold chest as the town's secrets).
	_build_chests()


func _build_tube_network() -> void:
	var parent: Node3D = chunk_for(anchor("mail_center"))
	var pipe_material: StandardMaterial3D = StandardMaterial3D.new()
	pipe_material.albedo_color = Color(0.55, 0.5, 0.35)
	pipe_material.metallic = 0.4
	pipe_material.roughness = 0.5
	var capsule_material: StandardMaterial3D = StandardMaterial3D.new()
	capsule_material.albedo_color = Color(0.7, 1.0, 0.9)
	capsule_material.emission_enabled = true
	capsule_material.emission = Color(0.4, 1.0, 0.8)
	capsule_material.emission_energy_multiplier = 2.5
	var runs: Array[Array] = [
		[Vector3(37.0, 1.3, 28.7), Vector3(53.0, 1.3, 28.7)],
		[Vector3(37.0, 1.55, 28.7), Vector3(53.0, 1.55, 28.7)],
		[Vector3(37.0, 1.3, 28.7), Vector3(37.0, 1.3, 40.5)],
		[Vector3(53.0, 1.55, 28.7), Vector3(53.0, 1.55, 40.5)],
	]
	for run_points: Array in runs:
		var a: Vector3 = run_points[0] as Vector3
		var b: Vector3 = run_points[1] as Vector3
		var pipe: MeshInstance3D = MeshInstance3D.new()
		var cylinder: CylinderMesh = CylinderMesh.new()
		cylinder.top_radius = 0.07
		cylinder.bottom_radius = 0.07
		cylinder.height = a.distance_to(b)
		cylinder.radial_segments = 8
		pipe.mesh = cylinder
		pipe.material_override = pipe_material
		pipe.position = (a + b) * 0.5
		var direction: Vector3 = (b - a).normalized()
		pipe.transform.basis = Basis(Quaternion(Vector3.UP, direction))
		parent.add_child(pipe)
		var capsule: MeshInstance3D = MeshInstance3D.new()
		var capsule_mesh: CapsuleMesh = CapsuleMesh.new()
		capsule_mesh.radius = 0.06
		capsule_mesh.height = 0.2
		capsule.mesh = capsule_mesh
		capsule.material_override = capsule_material
		capsule.position = a
		capsule.transform.basis = Basis(Quaternion(Vector3.UP, direction))
		parent.add_child(capsule)
		var travel: Tween = capsule.create_tween().set_loops()
		travel.tween_property(capsule, "position", b, 2.0 + _rng.randf() * 2.0).from(a)
		travel.tween_interval(0.5 + _rng.randf())



func _build_chests() -> void:
	for id: String in layout.chests.keys():
		var pos: Vector3 = layout.chests[id] as Vector3
		var chest: Node3D = ModelKit.dungeon_prop("chest_gold")
		DnaMaterials.grade_node(chest, 0.6)
		chunk_for(pos).add_child(chest)
		chest.position = pos
		chest.rotation_degrees.y = _rng.randf() * 360.0
		chest.scale = Vector3.ONE * 0.225
		chest_nodes[id] = chest
		var obstacle: Vector3 = Vector3(pos.x, pos.z, 0.18)
		_add_obstacle(obstacle)


# ---- Collision -----------------------------------------------------------------------------


func _bucket_key(x: float, z: float) -> Vector2i:
	return Vector2i(int(floorf(x / 2.0)), int(floorf(z / 2.0)))


func _add_obstacle(obstacle: Vector3) -> void:
	var key: Vector2i = _bucket_key(obstacle.x, obstacle.y)
	var list: Array = _buckets.get(key, []) as Array
	list.append(obstacle)
	_buckets[key] = list


func _index_obstacles() -> void:
	for prop: DnaLayout.Prop in layout.props:
		if prop.radius > 0.0:
			_add_obstacle(Vector3(prop.pos.x, prop.pos.z, prop.radius))


## Adds a runtime blocker (an NPC standing somewhere).
func add_blocker(pos: Vector3, radius: float) -> void:
	_add_obstacle(Vector3(pos.x, pos.z, radius))


func is_walkable(pos: Vector3, body_radius: float = 0.22) -> bool:
	var r: float = body_radius * 0.75
	for offset: Vector2 in [Vector2(r, r), Vector2(-r, r), Vector2(r, -r), Vector2(-r, -r)]:
		var cell: Vector2i = DnaLayout.world_to_cell(Vector3(pos.x + offset.x, 0.0, pos.z + offset.y))
		if not layout.is_floor(cell.x, cell.y) or blocked_cells.has(cell):
			return false
	var key: Vector2i = _bucket_key(pos.x, pos.z)
	for dz: int in range(-1, 2):
		for dx: int in range(-1, 2):
			var list: Variant = _buckets.get(key + Vector2i(dx, dz))
			if list == null:
				continue
			for obstacle: Vector3 in (list as Array):
				var ox: float = pos.x - obstacle.x
				var oz: float = pos.z - obstacle.y
				var reach: float = obstacle.z + body_radius
				if ox * ox + oz * oz < reach * reach:
					return false
	return true


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


## True when the straight line between two points crosses only walkable cells (enemy sight).
func has_line_of_sight(a: Vector3, b: Vector3) -> bool:
	var steps: int = maxi(1, int(a.distance_to(b) / 0.5))
	for i: int in range(steps + 1):
		var point: Vector3 = a.lerp(b, float(i) / float(steps))
		var cell: Vector2i = DnaLayout.world_to_cell(point)
		if not layout.is_floor(cell.x, cell.y):
			return false
		if _hits_obstacle(point, 0.12):
			return false
	return true
