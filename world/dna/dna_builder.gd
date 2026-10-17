class_name DnaBuilder
extends ZoneMap
## Turns a `DnaLayout` into the D.N.A.'s 3D world and answers walkability queries.
##
## Performance design (the zone is ~3x the town):
##  - The map is split into CHUNK x CHUNK cell chunks. Floors are one merged mesh per chunk and floor
##    kind, the balustrades one kit mesh per chunk, the cabinets and partitions one fading mesh per
##    chunk (`DnaFadeMesh`: every piece fades on its own when it stands between the camera and the
##    hero), every Kenney model part one MultiMesh per (chunk, part), every painted card id one
##    MultiMesh for the whole map (`KitFoliage.tree_field`, the cards fade themselves).
##  - `update_visibility()` hides chunks beyond VIEW_RADIUS of the player each frame (on top of
##    Godot's own frustum culling); the fog hides the cut-off. The Hall of Final Approvals, the gate
##    and the approach bridge hang off the root and never cull: the goal shows from the whole zone.
##  - Real lights are pooled in `DnaScene` (a few OmniLights that hop between nearby fixtures)
##    instead of one per fixture.
##
## D.N.A. slice (docs/art/dna_slice.md): the walls are knee-high stone balustrades with brass caps (WALL_HEIGHT), so no wall ever hides the hero; the cabinets
## are drawer stacks CABINET_HEIGHT tall and the cubicle partitions paneling PARTITION_HEIGHT tall, both fading per piece; the props are kit cards and
## `DnaProps` pieces; the entrance is a gate onto the approach causeway (no elevator); the Hall of Final Approvals (`DnaLandmarks`) stands beyond the north edge.

const CHUNK: int = 10
const VIEW_RADIUS: float = 30.0
## The balustrades: knee-high (the hero is 0.68 m), never between the camera and the hero's body.
const WALL_HEIGHT: float = 0.5
const CABINET_HEIGHT: float = 1.0
const PARTITION_HEIGHT: float = 0.6
## Painted card props of the layout (kit ids) -> the TreeCards kind that draws them as one MultiMesh field.
const CARD_KINDS: Dictionary = {
	"DNA-PROP-GHOSTLAMP": "dna_lamp", "DNA-PROP-DESK": "dna_desk", "DNA-PLANT-OFFICE": "dna_plant", "DNA-PLANT-LILY": "dna_lily", "DNA-TREE-DEAD": "dna_topiary",
	"DNA-PROP-PAPER": "dna_paper", "DNA-PROP-STAMP": "dna_stamp", "DNA-PROP-ROPE": "dna_rope",
	"DNA-SHEET-CABINETS-01": "dna_cabinet_1", "DNA-SHEET-CABINETS-02": "dna_cabinet_2", "DNA-SHEET-CABINETS-03": "dna_cabinet_3",
	"DNA-SHEET-CABINETS-04": "dna_cabinet_4", "DNA-SHEET-CABINETS-05": "dna_cabinet_5", "DNA-SHEET-CABINETS-06": "dna_cabinet_6",
}

const KENNEY_FURNITURE: String = "res://assets/kenney-furniture-kit/models/"
const KENNEY_GRAVEYARD: String = "res://assets/kenney-graveyard-kit/models/"
const KAYKIT_HALLOWEEN: String = "res://assets/KayKit-Halloween-Bits-1.0/gltf/"

var layout: DnaLayout = DnaLayout.new()
var root: Node3D
## chunk (Vector2i) -> Node3D
var chunks: Dictionary = {}
## The Hall of Final Approvals node (the main dungeon's building), null until built.
var hall: Node3D
## Circular obstacles bucketed by 2x2 cell: Vector2i -> Array[Vector3(x, z, radius)].
var _buckets: Dictionary = {}
## Set by the scene: a cell that is temporarily blocked (e.g. a sealed door) -> true.
var blocked_cells: Dictionary = {}

static var _scene_cache: Dictionary = {}
static var _part_cache: Dictionary = {}

var _batches: Dictionary = {}
var _floor_quads: Dictionary = {}
var _wall_cells: Dictionary = {}
var _cabinet_cells: Dictionary = {}
var _partition_segments: Dictionary = {}
var _card_entries: Dictionary = {}
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func build(parent: Node3D) -> void:
	_rng.seed = 88
	layout.build()
	root = Node3D.new()
	root.name = "DnaZone"
	parent.add_child(root)
	_collect_cells()
	_collect_props()
	_collect_partitions()
	_flush()
	_build_signs()
	_build_set_pieces()
	_build_hall()
	_build_entrance()
	_build_region_landmarks()
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


## Footsteps by the floor kind: carpet in the offices, marble in the executive halls, tile and linoleum in the queues, stone outside.
func surface_at(pos: Vector3) -> StringName:
	var cell: Vector2i = DnaLayout.world_to_cell(pos)
	match layout.floor_at(cell.x, cell.y):
		DnaLayout.Floor.CARPET:
			return &"carpet"
		DnaLayout.Floor.EXEC:
			return &"marble"
		DnaLayout.Floor.TILE, DnaLayout.Floor.LINO:
			return &"tile"
	return &"stone"


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


# ---- Cells: floors, balustrades, cabinets ----------------------------------------------------


func _collect_cells() -> void:
	for cz: int in range(DnaLayout.H):
		for cx: int in range(DnaLayout.W):
			var cell: DnaLayout.Cell = layout.cell_at(cx, cz)
			if cell == DnaLayout.Cell.VOID:
				continue
			var center: Vector3 = cell_center(cx, cz)
			var key: Vector2i = _chunk_key(center)
			if cell == DnaLayout.Cell.WALL:
				var list: Array = _wall_cells.get(key, []) as Array
				list.append(Vector2i(cx, cz))
				_wall_cells[key] = list
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
				var cab_list: Array = _cabinet_cells.get(key, []) as Array
				cab_list.append(Vector2i(cx, cz))
				_cabinet_cells[key] = cab_list


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
		match prop.kind:
			"card":
				var kind: String = str(CARD_KINDS.get(prop.model, ""))
				if kind == "" or not TreeCards.KINDS.has(kind):
					push_warning("DnaBuilder: no card kind for %s" % prop.model)
					continue
				var size: Vector2 = (TreeCards.KINDS[kind] as Dictionary)["size"] as Vector2
				var entries: Array = _card_entries.get(kind, []) as Array
				entries.append({"pos": prop.pos, "scale": prop.model_scale / maxf(size.y, 0.01)})
				_card_entries[kind] = entries
			"piece":
				var node: Node3D = DnaProps.piece(prop.model, prop.model_scale)
				if node == null:
					push_warning("DnaBuilder: no piece %s" % prop.model)
					continue
				chunk_for(prop.pos).add_child(node)
				node.position = prop.pos
				node.rotation_degrees.y = prop.yaw
			"model":
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


## Cubicle partition panels: knee-high paneling along each partition segment, fading per panel.
func _collect_partitions() -> void:
	for seg: Vector4 in layout.partitions:
		var mid: Vector3 = Vector3((seg.x + seg.z) * 0.5, 0.0, (seg.y + seg.w) * 0.5)
		var key: Vector2i = _chunk_key(mid)
		var list: Array = _partition_segments.get(key, []) as Array
		list.append(seg)
		_partition_segments[key] = list


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
		instance.set_meta(&"no_occlusion_fade", true)
		chunk_node(key).add_child(instance)
	for key: Vector2i in _wall_cells.keys():
		_build_balustrades(key, _wall_cells[key] as Array)
	var fade_keys: Dictionary = {}
	for key: Vector2i in _cabinet_cells.keys():
		fade_keys[key] = true
	for key: Vector2i in _partition_segments.keys():
		fade_keys[key] = true
	for key: Vector2i in fade_keys.keys():
		_build_fading(key, _cabinet_cells.get(key, []) as Array, _partition_segments.get(key, []) as Array)
	for batch_key: String in _batches.keys():
		var batch: Dictionary = _batches[batch_key] as Dictionary
		_add_multimesh(batch["chunk"] as Vector2i, batch["mesh"] as Mesh, null, batch["list"] as Array, "Props", true)
	for kind: String in _card_entries.keys():
		var entries: Array[Dictionary] = []
		entries.assign(_card_entries[kind] as Array)
		var field: MultiMeshInstance3D = KitFoliage.tree_field(root, kind, entries, true)
		if field != null:
			field.name = "Cards_%s" % kind
			# posts, desks and cabinets do not sway in the wind like plants
			if not bool((TreeCards.KINDS[kind] as Dictionary).get("plant", false)) and field.material_override is ShaderMaterial:
				var still: ShaderMaterial = (field.material_override as ShaderMaterial).duplicate() as ShaderMaterial
				still.set_shader_parameter("sway", 0.0)
				field.material_override = still


## A knee-high stone balustrade on every wall cell of a chunk: a gray block with a brass cap, a post with a brass finial on the corners and every fourth cell.
func _build_balustrades(key: Vector2i, wall_cells: Array) -> void:
	var mesh: KitMesh = KitMesh.new()
	mesh.set_material("grey", DnaLandmarks._surface("DNA-WALL-GREY", DnaLandmarks.GREY))
	mesh.set_material("grey_light", DnaLandmarks._surface("DNA-WALL-GREY", DnaLandmarks.GREY, Color(1.1, 1.1, 1.08)))
	mesh.set_material("brass", DnaLandmarks._surface("DNA-TRIM-BRASS", DnaLandmarks.BRASS))
	mesh.set_material("flat", EnvKit.flat(Color.WHITE, "dna_props"))
	mesh.alias("gold", "flat", DnaLandmarks.BRASS.srgb_to_linear())
	for cell: Variant in wall_cells:
		var c: Vector2i = cell as Vector2i
		var center: Vector3 = cell_center(c.x, c.y)
		mesh.box("grey", center + Vector3(0, WALL_HEIGHT * 0.5 - 0.1, 0), Vector3(1.0, WALL_HEIGHT + 0.2, 1.0), Basis.IDENTITY, 0.03, 0.82)
		mesh.box("brass", center + Vector3(0, WALL_HEIGHT + 0.015, 0), Vector3(1.02, 0.04, 1.02), Basis.IDENTITY, 0.0)
		var neighbours: int = 0
		for step: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			if layout.cell_at(c.x + step.x, c.y + step.y) == DnaLayout.Cell.WALL:
				neighbours += 1
		var corner: bool = neighbours != 2 or (layout.cell_at(c.x + 1, c.y) == DnaLayout.Cell.WALL) != (layout.cell_at(c.x - 1, c.y) == DnaLayout.Cell.WALL)
		if corner or (c.x + c.y) % 4 == 0:
			mesh.box("grey_light", center + Vector3(0, 0.42, 0), Vector3(0.56, 0.84, 0.56), Basis.IDENTITY, 0.03, 0.9)
			mesh.box("brass", center + Vector3(0, 0.86, 0), Vector3(0.62, 0.05, 0.62), Basis.IDENTITY, 0.0)
			mesh.blob("gold", center + Vector3(0, 0.98, 0), Vector3(0.1, 0.11, 0.1), 3, 6, 1.0)
	var instance: MeshInstance3D = mesh.instance("Parapets")
	instance.set_meta(PaintedClasses.META_NO_PAINT, true)
	instance.set_meta(&"no_occlusion_fade", true)  # knee-high: never between the camera and the hero's body
	chunk_node(key).add_child(instance)


## The fading pieces of a chunk: filing cabinets on every solid cell (a drawer stack with brass handles on the sides that face the aisles) and the cubicle
## partitions (paneling with a brass rail). Each piece fades on its own in the shader (DnaFadeMesh).
func _build_fading(key: Vector2i, cabinet_cells: Array, segments: Array) -> void:
	var mesh: DnaFadeMesh = DnaFadeMesh.new()
	mesh.set_slot("cabinet", "", Color("6b7572"))
	mesh.set_slot("cabinet_dark", "", Color("4e5856"))
	mesh.set_slot("brass", "DNA-TRIM-BRASS", Color.WHITE)
	mesh.set_slot("paneling", "TEX-DNA-PANELING", Color.WHITE)
	for cell: Variant in cabinet_cells:
		var c: Vector2i = cell as Vector2i
		var center: Vector3 = cell_center(c.x, c.y)
		var piece: Vector4 = Vector4(center.x, center.z, 0.5, CABINET_HEIGHT)
		mesh.box("cabinet", piece, center + Vector3(0, CABINET_HEIGHT * 0.5, 0), Vector3(0.96, CABINET_HEIGHT, 0.96), Color.WHITE, 0.78)
		mesh.box("cabinet_dark", piece, center + Vector3(0, CABINET_HEIGHT + 0.02, 0), Vector3(0.98, 0.04, 0.98))
		for step: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			if not layout.is_floor(c.x + step.x, c.y + step.y):
				continue
			var normal: Vector3 = Vector3(float(step.x), 0.0, float(step.y))
			for row: int in range(3):
				var y: float = CABINET_HEIGHT * (float(row) + 0.5) / 3.0
				var face: Vector3 = center + normal * 0.5 + Vector3(0, y, 0)
				mesh.box("cabinet_dark", piece, face + normal * 0.02, Vector3(0.7, 0.2, 0.04) if step.y != 0 else Vector3(0.04, 0.2, 0.7))
				mesh.box("brass", piece, face + normal * 0.05, Vector3(0.26, 0.04, 0.03) if step.y != 0 else Vector3(0.03, 0.04, 0.26))
				if (c.x * 7 + c.y * 3 + row) % 5 == 0:
					# a drawer left open with its papers
					mesh.box("cabinet", piece, face + normal * 0.24, Vector3(0.66, 0.16, 0.44) if step.y != 0 else Vector3(0.44, 0.16, 0.66))
					mesh.box("cabinet_dark", piece, face + normal * 0.24 + Vector3(0, 0.1, 0), Vector3(0.5, 0.05, 0.3) if step.y != 0 else Vector3(0.3, 0.05, 0.5), Color("c9c6b8").srgb_to_linear())
	for seg: Variant in segments:
		var s: Vector4 = seg as Vector4
		var a: Vector3 = Vector3(s.x, 0.0, s.y)
		var b: Vector3 = Vector3(s.z, 0.0, s.w)
		var mid: Vector3 = (a + b) * 0.5
		var length: float = a.distance_to(b)
		var along_x: bool = absf(b.x - a.x) >= absf(b.z - a.z)
		var piece: Vector4 = Vector4(mid.x, mid.z, length * 0.5, PARTITION_HEIGHT)
		mesh.box("paneling", piece, mid + Vector3(0, PARTITION_HEIGHT * 0.5, 0), Vector3(length, PARTITION_HEIGHT, 0.08) if along_x else Vector3(0.08, PARTITION_HEIGHT, length), Color.WHITE, 0.85)
		mesh.box("brass", piece, mid + Vector3(0, PARTITION_HEIGHT + 0.02, 0), Vector3(length + 0.04, 0.04, 0.12) if along_x else Vector3(0.12, 0.04, length + 0.04))
	chunk_node(key).add_child(mesh.instance("Fading"))


static var _unit_box: BoxMesh


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
	# G-03: no readable text in the world. A board carries one pictogram (DnaProps.board: slate in a brass frame, parchment posters, memos); the words are read by
	# using it (ZoneScene adds a "sign" spot).
	for sign_spec: DnaLayout.Sign in layout.signs:
		var holder: Node3D = Node3D.new()
		holder.position = sign_spec.pos
		holder.rotation_degrees.y = sign_spec.yaw
		chunk_for(sign_spec.pos).add_child(holder)
		var panel_size: Vector2 = Vector2(0.75, 0.75) * sign_spec.size
		if sign_spec.style == "memo":
			panel_size *= 0.7
		holder.add_child(DnaProps.board(panel_size, sign_spec.style))
		holder.add_child(IconSign.picture(panel_size * 0.8, sign_icon(sign_spec.key), Vector3(0, 0, 0.04)))


## The icon id a sign shows (the keys are the D.N.A.'s `sign.*` / `poster.*` / `memo.*` story keys).
const SIGN_ICONS: Dictionary = {
	"sign.lobby_main": "ICON-ENERGY-N", "sign.motto": "ICON-ESSENCE-N", "sign.take_number": "ICON-RES-REDTAPE", "sign.now_serving": "ICON-RES-REDTAPE",
	"sign.fun_day": "ICON-NODE-EVENT", "sign.requisitions": "ICON-MAP-VENDOR", "sign.exit": "ICON-MAP-EXIT", "poster.safety": "ICON-STAT-DEFENSE",
	"poster.synergy": "ICON-ESSENCE-N", "sign.coffee": "ICON-MECH-BUFF", "memo.coffee": "ICON-TOKEN-CLAUSE", "memo.lunch": "ICON-TOKEN-CLAUSE",
	"sign.heal_couch": "ICON-MAP-HEAL", "sign.time_clock": "ICON-MECH-OVEREXERT", "poster.wellness": "ICON-STAT-HP", "poster.hang_in_there": "ICON-ESSENCE-N",
	"sign.suggestion_box": "ICON-TOKEN-CONTRACT", "memo.cubicle_coffin": "ICON-TOKEN-CLAUSE", "sign.cubicle_farm_a": "ICON-MAP-TRAVEL",
	"poster.performance": "ICON-STAT-ATTACK", "memo.fun_day": "ICON-TOKEN-CLAUSE", "memo.hr": "ICON-TOKEN-CLAUSE", "sign.cubicle_farm_b": "ICON-MAP-TRAVEL",
	"memo.motto": "ICON-TOKEN-CLAUSE", "memo.reorg": "ICON-TOKEN-CLAUSE", "memo.parking": "ICON-TOKEN-CLAUSE", "sign.quiz": "ICON-MAP-QUIZ",
	"sign.printer": "ICON-MECH-PROCESSING", "sign.mailroom": "ICON-MAP-TRAVEL", "sign.puzzle": "ICON-MAP-PUZZLE", "sign.filing_maze": "ICON-MAP-TRAVEL",
	"sign.matching": "ICON-MAP-MINIGAME", "sign.elevator_bank": "ICON-MAP-TRAVEL", "sign.elevator_rule": "ICON-NODE-LOCKED",
	"sign.mini_dungeon": "ICON-MAP-SIDEDUNGEON", "memo.records": "ICON-TOKEN-CLAUSE", "sign.records": "ICON-MAP-TRAVEL", "sign.executive": "ICON-NODE-BOSS",
	"sign.main_dungeon": "ICON-MAP-DUNGEON", "sign.filed_complaint": "ICON-RES-REDTAPE",
}


static func sign_icon(key: String) -> String:
	return IconSign.icon_for(key, SIGN_ICONS)


# ---- Set pieces (elevators, time clock, the tubes...) ------------------------------------------


func _place_piece(node: Node3D, pos: Vector3, yaw: float = 0.0) -> void:
	chunk_for(pos).add_child(node)
	node.position = pos
	node.rotation_degrees.y = yaw


func _build_set_pieces() -> void:
	# Elevators along the elevator bank's north wall; the live one is Sub-Basement 3.
	for key: String in ["elevator_1", "elevator_2", "mini_dungeon", "elevator_4"]:
		var pos: Vector3 = anchor(key)
		_place_piece(DnaProps.elevator(key == "mini_dungeon"), Vector3(pos.x, 0.0, pos.z - 0.9))
	# Time clock on the breakroom's west wall, the suggestion box by the lobby doorway, the haunted printer in farm B.
	var clock_pos: Vector3 = anchor("time_clock")
	_place_piece(DnaProps.time_clock(), Vector3(clock_pos.x - 0.35, 0.0, clock_pos.z))
	_place_piece(DnaProps.suggestion_box(), anchor("suggestion"))
	_place_piece(DnaProps.printer(), anchor("printer"), 90.0)
	# Pneumatic tubes in the mail room: pipes along the north wall with capsules racing through.
	_build_tube_network()
	# Hidden chests (the same 1/4-scale gold chest as the town's secrets).
	_build_chests()


func _build_tube_network() -> void:
	var parent: Node3D = chunk_for(anchor("mail_center"))
	var pipe_material: StandardMaterial3D = StandardMaterial3D.new()
	pipe_material.albedo_color = Color("9a8450")
	pipe_material.metallic = 0.3
	pipe_material.roughness = 0.55
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
		pipe.set_meta(&"no_occlusion_fade", true)
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


# ---- The Hall of Final Approvals and the way in ---------------------------------------------------


## The main dungeon's building beyond the executive floor's north edge (DnaLayout.HALL_*): the hero model, never culled, never faded, its stair coming down to a
## stone threshold at the floor's edge; its lamps join the pooled lights. The dungeon spot waits at the stair's foot.
func _build_hall() -> void:
	var size: Vector3 = DnaLayout.HALL_SIZE
	hall = LandmarkKit.build({"id": "DNA-HERO-FINAL-APPROVALS", "kind": "facade", "size": [size.x, size.y, size.z], "color": "#6e7470", "accent": "#8a2e2e"})
	if hall == null:
		return
	root.add_child(hall)
	hall.position = Vector3(DnaLayout.HALL_CENTER.x, 0.0, DnaLayout.HALL_CENTER.y)
	for piece: Node in hall.find_children("*", "MeshInstance3D", true, false):
		piece.set_meta(&"no_range_cull", true)  # the goal must show from the whole zone (the 48 m cull would hide it from the lobby)
		piece.set_meta(&"no_occlusion_fade", true)
	for entry: Variant in hall.get_meta("lights", []) as Array:
		var light: Dictionary = entry as Dictionary
		var spot: DnaLayout.LightSpot = DnaLayout.LightSpot.new()
		spot.pos = hall.position + (light["pos"] as Vector3)
		spot.color = light["color"] as Color
		layout.lights.append(spot)
	# the threshold slab between the stair's foot and the floor's edge
	var mesh: KitMesh = KitMesh.new()
	mesh.set_material("grey_dark", DnaLandmarks._surface("DNA-WALL-GREY", DnaLandmarks.GREY, Color(0.74, 0.76, 0.76)))
	mesh.set_material("brass", DnaLandmarks._surface("DNA-TRIM-BRASS", DnaLandmarks.BRASS))
	var stair_w: float = clampf(size.x * 0.2, 3.0, 12.0)
	mesh.box("grey_dark", Vector3(DnaLayout.HALL_CENTER.x, -0.12, 1.6), Vector3(stair_w + 1.8, 0.24, 1.6), Basis.IDENTITY, 0.02)
	mesh.box("brass", Vector3(DnaLayout.HALL_CENTER.x, 0.005, 2.3), Vector3(stair_w + 1.8, 0.02, 0.2), Basis.IDENTITY, 0.0)
	var threshold: MeshInstance3D = mesh.instance("Threshold")
	threshold.set_meta(&"no_occlusion_fade", true)
	threshold.set_meta(&"no_range_cull", true)
	root.add_child(threshold)


## The hero landmarks kept from the removed sub-areas (SR-8) as views beyond the balustrades, where they crowd nothing: the Filing Tower west of the Filing
## Department, the Endless Queue along the east rim beside Cubicle Farm B and the Records Basement, the Records Stair beyond the archive's north parapet. Never
## culled or faded, nothing walkable near them. The Stamp of Approval shrine (SR-7) stands on the executive forecourt and blocks through its circles.
const FILING_TOWER: Vector3 = Vector3(-8.0, 0.0, 13.0)
const ENDLESS_QUEUE: Vector3 = Vector3(95.0, 0.0, 26.0)
const RECORDS_STAIR: Vector3 = Vector3(72.0, 0.0, -4.5)
const SHRINE_OFFSET: Vector3 = Vector3(1.6, 0.0, 0.0)


func _build_region_landmarks() -> void:
	_far_landmark({"id": "DNA-HERO-FILING-TOWER", "kind": "tower", "size": [10.0, 22.0, 6.0]}, "FilingTower", FILING_TOWER, 90.0)
	_far_landmark({"id": "DNA-HERO-ENDLESS-QUEUE", "kind": "colonnade", "size": [30.0, 3.0, 2.0]}, "EndlessQueue", ENDLESS_QUEUE, 90.0)
	_far_landmark({"id": "DNA-HERO-RECORDS-STAIR", "kind": "stair", "size": [9.0, 5.0, 8.0]}, "RecordsStair", RECORDS_STAIR, 0.0)
	var shrine_pos: Vector3 = anchor("shrine") + SHRINE_OFFSET
	var shrine: Node3D = LandmarkKit.build({"id": "stamp_shrine", "kind": "shrine", "size": [2.2, 3.0, 2.2], "color": "#6e7470", "accent": "#b8945a", "glow": "#4fbf7a", "surface": "DNA-WALL-GREY", "accent_surface": "DNA-TRIM-BRASS"})
	if shrine == null:
		return
	shrine.name = "StampShrine"
	root.add_child(shrine)
	shrine.position = shrine_pos
	shrine.rotation_degrees.y = -90.0
	var basis: Basis = Basis(Vector3.UP, deg_to_rad(-90.0))
	for circle: Variant in shrine.get_meta("circles", []) as Array:
		var local: Vector3 = circle as Vector3
		var world: Vector3 = shrine.position + basis * Vector3(local.x, 0.0, local.y)
		_add_obstacle(Vector3(world.x, world.z, local.z))
	for piece: Node in shrine.find_children("*", "MeshInstance3D", true, false):
		piece.set_meta(&"no_range_cull", true)


## A landmark that stands beyond the walkable floor as a view: on the root, never culled or faded, nothing solid (nothing walks there).
func _far_landmark(spec: Dictionary, node_name: String, at: Vector3, yaw: float) -> void:
	var node: Node3D = LandmarkKit.build(spec)
	if node == null:
		return
	node.name = node_name
	root.add_child(node)
	node.position = at
	node.rotation_degrees.y = yaw
	for piece: Node in node.find_children("*", "MeshInstance3D", true, false):
		piece.set_meta(&"no_range_cull", true)
		piece.set_meta(&"no_occlusion_fade", true)
	for entry: Variant in node.get_meta("lights", []) as Array:
		var light: Dictionary = entry as Dictionary
		var spot: DnaLayout.LightSpot = DnaLayout.LightSpot.new()
		spot.pos = node.position + (light["pos"] as Vector3)
		spot.color = light["color"] as Color
		layout.lights.append(spot)


## The gate in the lobby's south wall and the approach causeway's far landing with the bridge stub toward town (DnaLandmarks). Walking off the causeway's far
## end leaves for town (DnaScene).
func _build_entrance() -> void:
	var width: float = float(DnaLayout.APPROACH_X1 - DnaLayout.APPROACH_X0)
	var gate: Node3D = DnaLandmarks.entrance_gate(width)
	root.add_child(gate)
	gate.position = anchor("gate")
	for piece: Node in gate.find_children("*", "MeshInstance3D", true, false):
		piece.set_meta(&"no_range_cull", true)
	for circle: Variant in gate.get_meta("circles", []) as Array:
		var local: Vector3 = circle as Vector3
		_add_obstacle(Vector3(gate.position.x + local.x, gate.position.z + local.y, local.z))
	var bridge: Node3D = DnaLandmarks.approach_bridge(16.0, width)
	root.add_child(bridge)
	bridge.position = Vector3(float(DnaLayout.APPROACH_X0 + DnaLayout.APPROACH_X1) * 0.5, 0.0, float(DnaLayout.APPROACH_Z1))
	for piece: Node in bridge.find_children("*", "MeshInstance3D", true, false):
		piece.set_meta(&"no_range_cull", true)
		piece.set_meta(&"no_occlusion_fade", true)


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


func is_walkable(pos: Vector3, body_radius: float = StorybookScale.BODY_RADIUS) -> bool:
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
