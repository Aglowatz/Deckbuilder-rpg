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
## D.N.A. slice (docs/art/dna_slice.md) and the office interior (Oct 19, `DnaInterior`): the walls are full-height partition walls (WALL_HEIGHT) lit by wall
## sconces (overnight Oct 19: no ceiling beams, light strips or doorway headers - they hid the view), built into the per-chunk fade meshes so every wall cell
## fades on its own when it stands between the camera and the hero (a wall at the lens cuts away wide): the zone reads as the inside of a huge office building
## and the hero is never hidden. The cabinets are drawer stacks CABINET_HEIGHT tall (filing canyons) and the cubicle partitions paneling PARTITION_HEIGHT tall, fading the same way; the
## props are kit cards and `DnaProps` pieces; the entrance is a gate onto the approach causeway (no elevator); the Hall of Final Approvals (`DnaLandmarks`) stands
## beyond the north edge.

const CHUNK: int = 10
const VIEW_RADIUS: float = 30.0
## The interior walls (Oct 19): full height, fading per cell with a wide cut-away near the lens (DnaInterior); the hero is 0.68 m.
const WALL_HEIGHT: float = DnaInterior.WALL_HEIGHT
## The knee-high parapet of the approach causeway (outdoors, the bridge to town): never between the camera and the hero.
const PARAPET_HEIGHT: float = 0.5
## Filing cabinets taller than the hero (canyons), cubicle partitions knee-high on the hero (a clerk's cubicle wall): both fade per piece.
const CABINET_HEIGHT: float = 1.2
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
## Nov 18 evening (Part 1.1): the street of fake civic buildings behind the building fronts.
var street: DnaStreet
## Nov 18 evening (Part 1.5): the healing couch's node (its glow is attached by DnaScene).
var heal_couch: Node3D
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
	LoadTiming.detail("dna: layout.build")
	root = Node3D.new()
	root.name = "DnaZone"
	parent.add_child(root)
	_collect_cells()
	LoadTiming.detail("dna: _collect_cells")
	_collect_props()
	LoadTiming.detail("dna: _collect_props")
	_collect_partitions()
	LoadTiming.detail("dna: _collect_partitions")
	_flush()
	LoadTiming.detail("dna: _flush")
	_build_signs()
	LoadTiming.detail("dna: _build_signs")
	_build_set_pieces()
	LoadTiming.detail("dna: _build_set_pieces")
	_build_hall()
	LoadTiming.detail("dna: _build_hall")
	_build_grand_hall()
	LoadTiming.detail("dna: _build_grand_hall")
	_build_entrance()
	LoadTiming.detail("dna: _build_entrance")
	_build_region_landmarks()
	LoadTiming.detail("dna: _build_region_landmarks")
	if grand != null:
		street = DnaStreet.build(root, grand)  # Nov 18 evening (Part 1.1): the buildings behind the painted fronts
	LoadTiming.detail("dna: street")
	_index_obstacles()
	LoadTiming.detail("dna: _index_obstacles")


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
		# Overnight Nov 18 (the grand hall, indoors): the floor and the walls of a far chunk stay drawn (the hall must read as one room to its
		# far end - culled, the wasteland ground showed through); only its props, cards and set pieces cull
		if bool(node.get_meta("near", true)) != near:
			node.set_meta("near", near)
			for child: Node in node.get_children():
				if child is Node3D and child.name != &"Floor" and child.name != &"Interior" and child.name != &"Fading":
					(child as Node3D).visible = near


# ---- Cells: floors, balustrades, cabinets ----------------------------------------------------


## Overnight Nov 18: wall and enclosed-void cells that show hall marble under them (the partitions are thin; the gaps between rooms are floor).
var hall_floor_cells: Dictionary = {}


func _add_floor_quad(c: Vector2i, floor_kind: DnaLayout.Floor) -> void:
	var key: Vector2i = _chunk_key(cell_center(c.x, c.y))
	var quads: Dictionary = _floor_quads.get(key, {}) as Dictionary
	var cell_list: Array = quads.get(floor_kind, []) as Array
	cell_list.append(c)
	quads[floor_kind] = cell_list
	_floor_quads[key] = quads


func _collect_cells() -> void:
	var classify: DnaHall = DnaHall.new(layout)
	for c: Vector2i in classify.kinds.keys():
		if classify.kinds[c] == DnaHall.Kind.INSIDE_VOID or classify.kinds[c] == DnaHall.Kind.PARTITION:
			hall_floor_cells[c] = true
	for cz: int in range(DnaLayout.H):
		for cx: int in range(DnaLayout.W):
			var cell: DnaLayout.Cell = layout.cell_at(cx, cz)
			if cell == DnaLayout.Cell.VOID:
				if hall_floor_cells.has(Vector2i(cx, cz)):
					_add_floor_quad(Vector2i(cx, cz), DnaLayout.Floor.TILE)
				continue
			var center: Vector3 = cell_center(cx, cz)
			var key: Vector2i = _chunk_key(center)
			if cell == DnaLayout.Cell.WALL:
				var list: Array = _wall_cells.get(key, []) as Array
				list.append(Vector2i(cx, cz))
				_wall_cells[key] = list
				if hall_floor_cells.has(Vector2i(cx, cz)):
					_add_floor_quad(Vector2i(cx, cz), DnaLayout.Floor.TILE)
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
				if prop.model == "heal_couch":
					heal_couch = node
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
			mesh.surface_set_material(mesh.get_surface_count() - 1, DnaHall.marble_material())  # Overnight Nov 18: one polished marble floor
		var instance: MeshInstance3D = MeshInstance3D.new()
		instance.mesh = mesh
		instance.name = "Floor"
		instance.set_meta(&"no_occlusion_fade", true)
		chunk_node(key).add_child(instance)
	_build_interior()
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


## The office interior (Oct 19): full-height walls per chunk with sconces on the room faces, all as fading pieces in one `DnaInterior` fade mesh per chunk
## ("Interior"). Overnight Oct 19: the doorway headers, ceiling beams and light strips are gone (they hid the hero and the rooms beyond); the doorways are open
## to the top. `doorway_count`, `ceiling_piece_count` (0) and `sconce_count` are read by the tests; each sconce is a LightSpot for the pooled lights.
var doorway_count: int = 0
var ceiling_piece_count: int = 0
var sconce_count: int = 0


func _build_interior() -> void:
	var meshes: Dictionary = {}
	grand = DnaHall.new(layout)
	var runs: Array[Dictionary] = grand.outline_runs()
	var chunk_of: Callable = func(c: Vector2i) -> Vector2i: return _chunk_key(cell_center(c.x, c.y))
	for key: Vector2i in _wall_cells.keys():
		var interior: Array = []
		var outdoors: Array = []
		for cell: Variant in _wall_cells[key] as Array:
			# the approach causeway's parapets stay knee-high: it is the bridge outside the building
			if (cell as Vector2i).y >= DnaLayout.APPROACH_Z0 and DnaInterior.room_beside(layout, cell as Vector2i) == "":
				outdoors.append(cell)
			else:
				interior.append(cell)
		if not outdoors.is_empty():
			_build_balustrades(key, outdoors)
		if interior.is_empty():
			continue
		# Overnight Nov 18: the grand hall - painted two-storey walls on the outline, waist-high partitions on every other wall cell (DnaHall)
		var fade: DnaFadeMesh = DnaHall.mesh()
		for join: Dictionary in grand.build_outline(fade, key, chunk_of, runs):
			hall_joins.append(join)
		for post: Vector3 in grand.build_partitions(fade, interior):
			hall_posts.append(post)
		meshes[key] = fade
	doorway_count = DnaInterior.doorways(layout).size()
	var hidden: PackedStringArray = OS.get_environment("DNA_HIDE").split(",", false)  # fps / debug A-B: DNA_HIDE=Walls hides the interior
	for key: Vector2i in meshes.keys():
		# "Interior", not "Walls": PaintedContexts.dna paints a chunk child named Walls with its own override (the pre-slice wall mesh)
		var instance: MeshInstance3D = (meshes[key] as DnaFadeMesh).instance("Interior")
		instance.visible = not hidden.has("Walls")
		chunk_node(key).add_child(instance)
	_queue_hall_cards()


## Overnight Nov 18: the grand hall's cards - a post at every partition end and join, and along the hall walls, bay join by bay join, a
## column, a pair of sconces or a hanging stamp banner in turn; the office booths stand on the partitions at the rooms' back walls.
const BOOTH_SPOTS: Array[Array] = [
	[Vector2(39.0, 45.5), 1], [Vector2(52.0, 45.5), 2], [Vector2(39.5, 27.5), 2], [Vector2(50.5, 27.5), 1],
	[Vector2(23.5, 47.5), 1], [Vector2(8.5, 25.5), 2], [Vector2(28.5, 25.5), 1], [Vector2(61.5, 25.5), 1], [Vector2(81.5, 25.5), 2],
	[Vector2(35.5, 7.5), 2], [Vector2(54.5, 7.5), 1],
]
var hall_columns: Array[Vector3] = []
var hall_banners: Array[Dictionary] = []
var booth_count: int = 0


func _queue_hall_cards() -> void:
	var posts: Array = _card_entries.get("dna_post", []) as Array
	for post: Vector3 in hall_posts:
		posts.append({"pos": post, "scale": 1.0})
	_card_entries["dna_post"] = posts
	var sconces: Array = _card_entries.get("dna_sconce", []) as Array
	for index: int in range(hall_joins.size()):
		var join: Dictionary = hall_joins[index]
		var at: Vector3 = join["pos"] as Vector3
		var normal: Vector3 = join["normal"] as Vector3
		if normal.z < -0.5:
			continue  # a room's south wall: only ever seen cut away, from behind the camera
		var long_wall: bool = float(join.get("length", 0.0)) >= 14.0
		match index % 3 if long_wall else 1:
			0:
				hall_columns.append(at + normal * 0.9)
			1:
				var side: Vector3 = Vector3(-normal.z, 0.0, normal.x)
				for sgn: float in [-1.0, 1.0]:
					var p: Vector3 = at + normal * 0.15 + side * 1.1 * sgn + Vector3(0, 3.0, 0)
					sconces.append({"pos": p, "scale": 1.0})
					var spot: DnaLayout.LightSpot = DnaLayout.LightSpot.new()
					spot.pos = p + normal * 0.8 + Vector3(0, 0.7, 0)
					spot.color = WARM_LIGHT
					layout.lights.append(spot)
					sconce_count += 1
			2:
				if absf(normal.x) > 0.5:
					hall_banners.append(join)  # side walls only: a banner on a wall facing the camera hung right in front of the lens
	_card_entries["dna_sconce"] = sconces
	# Nov 18 evening (Part 1.2, "booths stuck in the middle of walls"): a booth stands on the walled-in hall floor next to its old spot (cells
	# nobody walks on, clear of every wall and partition), or it is left out - never on a partition.
	for spec: Array in BOOTH_SPOTS:
		var at2: Vector2 = spec[0] as Vector2
		var kind: String = "dna_booth_%d" % int(spec[1])
		var width: float = ((TreeCards.KINDS[kind] as Dictionary)["size"] as Vector2).x
		var spot: Vector2 = _booth_floor_spot(at2, width)
		if spot == Vector2.INF:
			booths_left_out += 1
			continue
		var list: Array = _card_entries.get(kind, []) as Array
		list.append({"pos": Vector3(spot.x, 0.0, spot.y), "scale": 1.0})
		_card_entries[kind] = list
		booth_count += 1


var booths_left_out: int = 0


## The card entries of a kind (the probe and the tests read the booths).
func booth_entries(kind: String) -> Array:
	return _card_entries.get(kind, []) as Array


## Nov 18 evening: the nearest point within 6 m of `near` where a booth `width` wide (1.2 m deep) stands wholly on hall floor that nobody walks
## on (walled-in void cells), 0.3 m clear of every wall cell; Vector2.INF when there is none.
func _booth_floor_spot(near: Vector2, width: float) -> Vector2:
	var best: Vector2 = Vector2.INF
	var best_d: float = INF
	var half: Vector2 = Vector2(width * 0.5 + 0.3, 0.9)
	for dz: int in range(-12, 13):
		for dx: int in range(-12, 13):
			var p: Vector2 = near + Vector2(float(dx), float(dz)) * 0.5
			var d: float = p.distance_to(near)
			if d >= best_d or d > 6.0:
				continue
			var ok: bool = true
			for cz: int in range(int(floorf(p.y - half.y)), int(floorf(p.y + half.y)) + 1):
				for cx: int in range(int(floorf(p.x - half.x)), int(floorf(p.x + half.x)) + 1):
					if grand == null or grand.kind_at(Vector2i(cx, cz)) != DnaHall.Kind.INSIDE_VOID:
						ok = false
						break
				if not ok:
					break
			if ok:
				best = p
				best_d = d
	return best


const WARM_LIGHT: Color = Color(1.0, 0.76, 0.44)


## Overnight Nov 18: the grand hall's classification (outline / partitions / enclosed floor), its bay joins and partition posts.
var grand: DnaHall
var hall_joins: Array[Dictionary] = []
var hall_posts: Array[Vector3] = []


## The knee-high balustrade of the slice (kept for the kit bench and as the fallback look; the zone uses `_build_interior` since Oct 19).
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
		mesh.box("grey", center + Vector3(0, PARAPET_HEIGHT * 0.5 - 0.1, 0), Vector3(1.0, PARAPET_HEIGHT + 0.2, 1.0), Basis.IDENTITY, 0.03, 0.82)
		mesh.box("brass", center + Vector3(0, PARAPET_HEIGHT + 0.015, 0), Vector3(1.02, 0.04, 1.02), Basis.IDENTITY, 0.0)
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
		var panel_size: Vector2 = Vector2(0.75, 0.75) * sign_spec.size
		if sign_spec.style == "memo":
			panel_size *= 0.7
		var plaque_id: String = "DNA-SHEET-SIGNS-%02d" % plaque_index(sign_spec.key)
		if sign_spec.key == "sign.mini_dungeon" and EnvKit.has(WAITING_SIGN_ART) and EnvKit.has_art(WAITING_SIGN_ART):
			plaque_id = WAITING_SIGN_ART  # Batch 18 (Nov 20): the Waiting Room of Eternity's own plaque, an hourglass
			panel_size *= 1.4  # a little larger than the wall plaques: it hangs alone over the lit door and must read from the hall
		var use_plaque: bool = EnvKit.has(plaque_id) and not ICON_BOARDS.has(sign_spec.key)
		var panel_h: float = panel_size.x * 1.15 / maxf(EnvKit.aspect(plaque_id), 0.1) if use_plaque else panel_size.y
		holder.position = sign_mount(sign_spec, panel_h)
		holder.rotation_degrees.y = sign_rotation(sign_spec)
		if sign_spec.key == "sign.heal_couch":
			_sign_post(holder.position - Vector3(0, panel_h * 0.5, 0.05))
		chunk_for(sign_spec.pos).add_child(holder)
		sign_spots.append({"key": sign_spec.key, "pos": holder.position, "bottom": holder.position.y - panel_h * 0.5, "mount_top": _mount_top(sign_spec)})
		# Overnight Nov 18 (the grand hall): every board is a brass plaque from DNA-SHEET-SIGNS whose icon matches what it points to;
		# Nov 18 evening: the couch's sign is a brass-framed board with the heart (ICON_BOARDS)
		if use_plaque:
			holder.add_child(_plaque(plaque_id, panel_size.x * 1.15))
			continue
		holder.add_child(DnaProps.board(panel_size, sign_spec.style))
		holder.add_child(IconSign.picture(panel_size * 0.8, sign_icon(sign_spec.key), Vector3(0, 0, 0.04)))


const WAITING_SIGN_ART: String = "DNA-SIGN-HOURGLASS"


## Nov 18 evening (Part 1.2, "nothing floats"): the signs built where they really hang - [{key, pos, bottom, mount_top}] (the prop probe).
var sign_spots: Array[Dictionary] = []
## The couch's heart sign stands on a brass post this high (its board's bottom edge), over the couch's back.
const HEAL_SIGN_BOTTOM: float = 1.45


## A slim brass sign post from the floor to `top` (the heart sign behind the couch).
func _sign_post(top: Vector3) -> void:
	var mesh: KitMesh = KitMesh.new()
	DnaLandmarks._materials(mesh)
	mesh.box("grey_dark", Vector3(top.x, 0.06, top.z), Vector3(0.36, 0.12, 0.36), Basis.IDENTITY, 0.02)
	mesh.box("brass", Vector3(top.x, top.y * 0.5, top.z), Vector3(0.07, top.y, 0.07), Basis.IDENTITY, 0.0)
	mesh.box("brass", Vector3(top.x, top.y - 0.02, top.z + 0.02), Vector3(0.5, 0.05, 0.08), Basis.IDENTITY, 0.0)
	chunk_for(top).add_child(mesh.instance("HealSignPost"))


## Signs drawn as a brass-framed board with their icon instead of a DNA-SHEET-SIGNS plaque (the couch's heart).
const ICON_BOARDS: Array[String] = ["sign.heal_couch"]


## Where a sign's centre really goes (Nov 18 evening). A sign on a two-storey front or a tall wall hangs flat on its face at the layout's
## height; a sign on a waist-high partition (open air: most of the old walls) stands on the partition's capping rail, against its face (it
## used to hang in the air over a 1.15 m rail, a third of a metre off it); a memo pinned to a desk partition stays where it is.
func sign_mount(sign_spec: DnaLayout.Sign, panel_h: float) -> Vector3:
	if sign_spec.key == "sign.heal_couch":
		return DnaLayout.COUCH_POS + Vector3(0.0, HEAL_SIGN_BOTTOM + panel_h * 0.5, -0.7)  # on its own brass post behind the couch, facing south
	if sign_spec.key == "sign.mini_dungeon":
		var door: Vector3 = anchor("mini_dungeon")
		return Vector3(door.x, WAITING_SIGN_Y, DnaLayout.ELEVATOR_WALL_Z - 0.01 + WAITING_SIGN_OUT)  # hanging from its bracket over the lit door
	if sign_spec.face_step == Vector2i.ZERO:
		return sign_spec.pos
	var top: float = _mount_top(sign_spec)
	if top >= sign_spec.pos.y + panel_h * 0.5:
		return sign_spec.pos
	var wall: Vector2i = sign_spec.face_cell + sign_spec.face_step
	var center: Vector3 = DnaLayout.cell_center(wall.x, wall.y)
	var normal: Vector3 = -Vector3(float(sign_spec.face_step.x), 0.0, float(sign_spec.face_step.y))
	var face: Vector3 = center + normal * (DnaHall.PARTITION_T * 0.5 + 0.04)
	var along: Vector3 = Vector3(sign_spec.pos.x, 0.0, sign_spec.pos.z) - Vector3(face.x, 0.0, face.z)
	along -= normal * along.dot(normal)
	return Vector3(face.x + along.x, top + 0.07 + panel_h * 0.5, face.z + along.z)


## The top of the wall a sign hangs on: a building front's cornice, the elevator walls, or a partition's rail.
func _mount_top(sign_spec: DnaLayout.Sign) -> float:
	if sign_spec.key == "sign.mini_dungeon":
		return WAITING_SIGN_ARM_Y
	if sign_spec.key == "sign.heal_couch":
		return HEAL_SIGN_BOTTOM
	if sign_spec.face_step == Vector2i.ZERO:
		return PARTITION_HEIGHT
	var wall: Vector2i = sign_spec.face_cell + sign_spec.face_step
	if grand != null and grand.kind_at(wall) == DnaHall.Kind.OUTLINE:
		return DnaHall.HALL_H
	if is_elevator_wall(wall):
		return ELEVATOR_WALL_H
	return DnaHall.PARTITION_H


## Overnight Nov 18: the plaque of a sign key (DNA-SHEET-SIGNS: 1 stamp, 2 clock, 3 arrow, 4 folder, 5 raised hand, 6 ghost).
const PLAQUE_BY_KEY: Dictionary = {
	"sign.lobby_main": 1, "sign.motto": 1, "sign.requisitions": 1, "sign.filed_complaint": 1, "sign.executive": 1, "sign.main_dungeon": 1,
	"poster.safety": 5, "poster.performance": 1, "sign.take_number": 2, "sign.now_serving": 2, "sign.time_clock": 2, "memo.lunch": 2,
	"sign.elevator_rule": 5, "sign.exit": 3, "sign.cubicle_farm_a": 3, "sign.cubicle_farm_b": 3, "sign.mailroom": 3, "sign.filing_maze": 3,
	"sign.elevator_bank": 3, "sign.records": 3, "sign.mini_dungeon": 2, "sign.suggestion_box": 5, "sign.heal_couch": 5, "sign.coffee": 5,
	"sign.fun_day": 6, "poster.synergy": 6, "poster.hang_in_there": 6, "poster.wellness": 6, "memo.cubicle_coffin": 6,
}


static func plaque_index(key: String) -> int:
	if PLAQUE_BY_KEY.has(key):
		return int(PLAQUE_BY_KEY[key])
	return 4  # memos, the printer, the quiz, the puzzle, the matching game: a folder


static func _plaque(id: String, width: float) -> MeshInstance3D:
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2(width, width / maxf(EnvKit.aspect(id), 0.1))
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.name = IconSign.NODE_NAME  # a sign picture (the hub sign test counts them)
	instance.mesh = quad
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_texture = EnvKit.texture(id)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	material.alpha_scissor_threshold = 0.4
	material.roughness = 0.5
	material.metallic_specular = 0.6
	material.emission_enabled = true
	material.emission = Color(0.18, 0.15, 0.1)
	material.set_meta(PaintedClasses.META_NO_PAINT, true)
	material.set_meta(StyleToon.META_NO_TOON, true)
	instance.material_override = material
	instance.position = Vector3(0, 0, 0.03)
	instance.set_meta(PaintedClasses.META_NO_PAINT, true)
	return instance


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


# ---- Set pieces (elevators, time clock, suggestion box, printer, chests) ------------------------------------------


func _place_piece(node: Node3D, pos: Vector3, yaw: float = 0.0) -> void:
	chunk_for(pos).add_child(node)
	node.position = pos
	node.rotation_degrees.y = yaw


func _build_set_pieces() -> void:
	# Elevators along the elevator bank's north wall; the live one is Sub-Basement 3.
	# Nov 18 evening (Part 1.3): the doors are built with their walls (`_build_elevator_walls`) so a wall and its shafts fade as one piece.
	# Time clock on the breakroom's west wall, the suggestion box by the lobby doorway, the haunted printer in farm B.
	_place_piece(DnaProps.time_clock(), DnaLayout.TIME_CLOCK_POST)  # Nov 18 evening: on its own pillar against the wall (it floated)
	_add_obstacle(Vector3(DnaLayout.TIME_CLOCK_POST.x, DnaLayout.TIME_CLOCK_POST.z, 0.38))
	_place_piece(DnaProps.suggestion_box(), anchor("suggestion"))
	_place_piece(DnaProps.printer(), anchor("printer"), 90.0)
	# Nov 18 evening (Part 1.2): the mail room's pneumatic tubes are gone (open air: they hung in the air, attached to nothing).
	# Hidden chests (the same 1/4-scale gold chest as the town's secrets).
	_build_chests()


func _build_chests() -> void:
	for id: String in layout.chests.keys():
		var pos: Vector3 = layout.chests[id] as Vector3
		var chest: Node3D = ModelKit.dungeon_prop("chest_gold")
		DnaMaterials.grade_node(chest, 0.6)
		chunk_for(pos).add_child(chest)
		chest.position = pos
		chest.rotation_degrees.y = _rng.randf() * 360.0
		chest.scale = Vector3.ONE * ChestKit.SCALE
		chest_nodes[id] = chest
		var obstacle: Vector3 = Vector3(pos.x, pos.z, ChestKit.FOOTPRINT)
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
	_build_stair_ghosts()
	var threshold: MeshInstance3D = mesh.instance("Threshold")
	threshold.set_meta(&"no_occlusion_fade", true)
	threshold.set_meta(&"no_range_cull", true)
	root.add_child(threshold)


## Nov 18 evening (Part 1.4): the line of ghosts waiting single file up the LEFT side of the Hall's stair and across its landing to the door:
## each stands on a tread (its feet on the step's top, `stair_ghosts` keeps where), bobbing gently upward from there - never below the tread.
## The middle of the stair stays clear. Camera-facing kit cards (DNA-SHEET-GHOST-QUEUE-01..06), no collision (the stair is not walked).
const STAIR_GHOST_H: float = 1.65
const STAIR_GHOST_BOB: float = 0.07
## [{"pos": Vector3 (feet), "tread": float (the step's top)}] - the tests and the prop probe.
var stair_ghosts: Array[Dictionary] = []


class StairGhosts:
	extends Node3D
	var bases: Array[float] = []
	var _time: float = 0.0

	func _process(delta: float) -> void:
		_time += delta
		for i: int in range(mini(get_child_count(), bases.size())):
			var ghost: Node3D = get_child(i) as Node3D
			ghost.position.y = bases[i] + DnaBuilder.STAIR_GHOST_BOB * (0.5 + 0.5 * sin(_time * 1.6 + float(i) * 1.3))


func _build_stair_ghosts() -> void:
	if hall == null or not hall.has_meta("stair"):
		return
	var stair: Dictionary = hall.get_meta("stair") as Dictionary
	var foot_z: float = float(stair["foot_z"])
	var height: float = float(stair["height"])
	var run: float = float(stair["run"])
	var width: float = float(stair["width"])
	var steps: int = maxi(2, int(ceilf(height / 0.3)))
	var rise: float = height / float(steps)
	var tread: float = run / float(steps)
	var spots: Array[Vector3] = []
	var left_x: float = -width * 0.5 + 1.1
	for index: int in range(1, steps - 1, 2):
		spots.append(Vector3(left_x, (float(index) + 1.0) * rise, foot_z - (float(index) + 0.5) * tread))
	# across the landing to the left leaf of the door
	var landing_z: float = float(stair["landing_z"])
	var door_z: float = float(stair["door_z"])
	var door_x: float = -float(stair["door_w"]) * 0.25
	for t: float in [0.2, 0.45, 0.7, 0.92]:
		spots.append(Vector3(lerpf(left_x, door_x, t), height, lerpf(landing_z - 0.8, door_z + 0.9, t)))
	var holder: StairGhosts = StairGhosts.new()
	holder.name = "StairGhosts"
	root.add_child(holder)
	for index: int in range(spots.size()):
		var at: Vector3 = hall.position + spots[index] + Vector3(0, 0.02, 0)
		var id: String = "DNA-SHEET-GHOST-QUEUE-%02d" % (index % 6 + 1)
		var ghost: Node3D = KitPieces.stand(holder, id, at, STAIR_GHOST_H, false)
		if ghost == null:
			continue
		holder.bases.append(at.y)
		for piece: Node in ghost.find_children("*", "MeshInstance3D", true, false):
			piece.set_meta(&"no_range_cull", true)
			piece.set_meta(&"no_occlusion_fade", true)
		stair_ghosts.append({"pos": at, "tread": hall.position.y + spots[index].y})


## Overnight Nov 18 (the grand hall): the ceiling over the building's footprint, the dark end bay north of it with DNA-BD-HALL-INTERIOR on its far
## wall (behind the Hall of Final Approvals), the red runners, the columns along the hall walls, the chandeliers over the open floor, the
## stamp banners from the gallery and the lobby clock on the Hall's drum (where the faceted dome stood).
## Nov 18 day (Part 6.1): the D.N.A. is open-air (no ceiling, no end bay).
const OPEN_AIR: bool = true
const END_BAY_DEPTH: float = 46.0
const END_BAY_H: float = 46.0
const COLUMN_H: float = 13.0
const CHANDELIERS: Array[Vector2] = [
	Vector2(45.5, 52.5), Vector2(45.5, 35.0), Vector2(17.5, 35.0), Vector2(71.5, 35.0),
	Vector2(8.5, 35.0), Vector2(26.5, 35.0), Vector2(62.5, 35.0), Vector2(80.5, 35.0), Vector2(18.0, 13.0), Vector2(72.0, 14.0), Vector2(26.5, 54.0),
]
## Nov 18 day: the chandeliers over the executive floor (45.5, 7.5) and the elevator bank (45.5, 20) are gone - they hung between the camera
## and the hero on the way to the Hall's door.
const CHANDELIER_H: float = 4.4
const CHANDELIER_BOTTOM: float = 6.9
var chandelier_count: int = 0


func _build_grand_hall() -> void:
	if grand == null:
		return
	var dark: StandardMaterial3D = StandardMaterial3D.new()
	dark.albedo_color = DnaHall.VAULT
	dark.roughness = 1.0
	dark.cull_mode = BaseMaterial3D.CULL_DISABLED
	dark.disable_fog = true  # the vault stays dark; fogged it read as a grey sky
	dark.set_meta(PaintedClasses.META_NO_PAINT, true)
	dark.set_meta(StyleToon.META_NO_TOON, true)
	# Nov 18 day (Part 6.1): open air - no ceiling, no dark end bay and no painted back wall (`OPEN_AIR`): the sky and the skyline
	# (WorldLookRig's DNA-SKY-GLOOM panorama and the DNA-BD-TOWERS cards) show over the building fronts.
	if not OPEN_AIR:
		_build_ceiling(dark)
	# the runners
	var runners: MeshInstance3D = MeshInstance3D.new()
	runners.name = "Runners"
	runners.mesh = DnaHall.runner_mesh()
	runners.material_override = DnaHall.runner_material()
	runners.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	runners.set_meta(&"no_range_cull", true)
	runners.set_meta(&"no_occlusion_fade", true)
	runners.set_meta(PaintedClasses.META_NO_PAINT, true)
	root.add_child(runners)
	# columns along the hall walls (rising past the cornice into the dark), chandeliers over the open floor
	var column_aspect: float = _kit_aspect("DNA-PROP-COLUMN", 0.28)
	for at: Vector3 in hall_columns:
		var column: MeshInstance3D = hanging_card("DNA-PROP-COLUMN", Vector2(COLUMN_H * column_aspect, COLUMN_H), false)
		column.name = "HallColumn"
		chunk_for(at).add_child(column)
		column.global_position = at
		(column.material_override as ShaderMaterial).set_shader_parameter("fade_near", 3.0)
		(column.material_override as ShaderMaterial).set_shader_parameter("fade_far", 6.5)
	var sway: bool = not GraphicsQuality.low_end
	var chandelier_aspect: float = _kit_aspect("DNA-PROP-CHANDELIER", 0.66)
	for index: int in range(CHANDELIERS.size()):
		var spot: Vector2 = CHANDELIERS[index]
		var c: Vector2i = DnaLayout.world_to_cell(Vector3(spot.x, 0, spot.y))
		if not layout.is_floor(c.x, c.y):
			continue
		var top: Vector3 = Vector3(spot.x, CHANDELIER_BOTTOM + CHANDELIER_H, spot.y)
		var chandelier: MeshInstance3D = hanging_card("DNA-PROP-CHANDELIER", Vector2(CHANDELIER_H * chandelier_aspect, CHANDELIER_H), true)
		chandelier.name = "Chandelier"
		var material: ShaderMaterial = chandelier.material_override as ShaderMaterial
		material.set_shader_parameter("sway_amp", 0.018 if sway else 0.0)
		material.set_shader_parameter("sway_phase", float(index) * 1.7)
		material.set_shader_parameter("emission", 1.6)
		material.set_shader_parameter("fade_near", 3.5)
		material.set_shader_parameter("fade_far", 7.0)
		chunk_for(top).add_child(chandelier)
		chandelier.global_position = top
		# Nov 18 day: open air - the chandeliers float (no chain up into a ceiling)
		var light: DnaLayout.LightSpot = DnaLayout.LightSpot.new()
		light.pos = Vector3(spot.x, CHANDELIER_BOTTOM + 1.2, spot.y)
		light.color = WARM_LIGHT
		layout.lights.append(light)
		chandelier_count += 1
	_build_hall_banners()
	_build_moon_shafts()
	_build_clock_tower()
	_build_elevator_walls()


## The D.N.A.'s landmark: a clock tower that rises over the building fronts, north-west of the Hall's stair, seen from the arrival and
## from most of the plaza. Since Batch 18 (Nov 20) it is the painted tower (DNA-HERO-CLOCK-TOWER), a camera-facing card tall enough
## that its lit clock face (four fifths of the way up) stands over the fronts; the kit-built tower it replaced is removed.
const CLOCK_TOWER: Vector3 = Vector3(36.0, 0.0, -2.5)
var clock_tower: Node3D


const CLOCK_TOWER_ART: String = "DNA-HERO-CLOCK-TOWER"
const CLOCK_TOWER_ART_H: float = 17.5


func _build_clock_tower() -> void:
	if not EnvKit.has(CLOCK_TOWER_ART) or not EnvKit.has_art(CLOCK_TOWER_ART):
		return
	var height: float = CLOCK_TOWER_ART_H
	var card: MeshInstance3D = hanging_card(CLOCK_TOWER_ART, Vector2(height * _kit_aspect(CLOCK_TOWER_ART, 0.31), height), false)
	card.name = "ClockTower"
	var material: ShaderMaterial = card.material_override as ShaderMaterial
	material.set_shader_parameter("fade_near", 0.0)
	material.set_shader_parameter("fade_far", 0.01)
	material.set_shader_parameter("emission", 0.55)
	card.set_meta(&"no_range_cull", true)
	card.set_meta(&"painted_tower", true)
	root.add_child(card)
	card.position = CLOCK_TOWER
	clock_tower = card
	for entry: Array in [[Vector3(0, height * 0.8, 1.6), WARM_LIGHT], [Vector3(0, height * 0.93, 0.6), Color(0.55, 1.0, 0.65)]]:
		var light: DnaLayout.LightSpot = DnaLayout.LightSpot.new()
		light.pos = CLOCK_TOWER + (entry[0] as Vector3)
		light.color = entry[1] as Color
		layout.lights.append(light)


## Nov 18 day (Part 6.5): the walls behind the elevators (the elevator bank's north side, either side of the corridor to the executive floor)
## are tall and thick - deep enough for a lift shaft - so the four elevator doors sit inside a wall. They stand on the same wall cells (z 14-16),
## so nothing about the walk grid changes.
## Nov 18 evening (Part 1.3, "close up or from the side the tall wall fades out and the elevator is left standing alone"): each half of the bank
## is ONE piece - one node ("LiftBank_W" / "LiftBank_E") holding its wall and its two elevators' doors and shaft housings - so the camera's
## cut-away (OcclusionFader, which dissolves a node's meshes together) takes the wall and its shafts away together, or neither. The walls
## rise as high as the shaft housings (ELEVATOR_WALL_H, a storey and a half) with a brass cornice; each shaft has a stone surround up to the
## cornice with a brass floor dial over its doors.
const ELEVATOR_WALL_H: float = 4.2
const ELEVATOR_WALL_SPANS: Array[Vector2] = [Vector2(36.0, 43.0), Vector2(47.0, 54.0)]
const ELEVATOR_DOORS: Array[Array] = [["elevator_1", 38.0], ["elevator_2", 41.0], ["mini_dungeon", 49.0], ["elevator_4", 52.0]]
var elevator_walls: int = 0
var lift_banks: Array[Node3D] = []
## Nov 18 evening (Part 1.6): the Waiting Room's hanging sign - its bracket arm's height, how far it reaches out from the wall, the sign's centre.
const WAITING_SIGN_ARM_Y: float = 3.75
const WAITING_SIGN_OUT: float = 0.6
const WAITING_SIGN_Y: float = 3.0


static func is_elevator_wall(c: Vector2i) -> bool:
	if c.y < 14 or c.y > 15:
		return false
	for span: Vector2 in ELEVATOR_WALL_SPANS:
		if float(c.x) >= span.x and float(c.x) < span.y:
			return true
	return false


func _build_elevator_walls() -> void:
	var z0: float = 14.0
	var z1: float = DnaLayout.ELEVATOR_WALL_Z - 0.01
	for index: int in range(ELEVATOR_WALL_SPANS.size()):
		var span: Vector2 = ELEVATOR_WALL_SPANS[index]
		var bank: Node3D = Node3D.new()
		bank.name = "LiftBank_%s" % ("W" if index == 0 else "E")
		var mesh: KitMesh = KitMesh.new()
		DnaLandmarks._materials(mesh)
		var cx: float = (span.x + span.y) * 0.5
		var width: float = span.y - span.x
		var h: float = ELEVATOR_WALL_H
		mesh.box("grey", Vector3(cx, h * 0.5, (z0 + z1) * 0.5), Vector3(width, h, z1 - z0), Basis.IDENTITY, 0.06, 0.9)
		mesh.box("paneling", Vector3(cx, 0.55, z1 + 0.01), Vector3(width - 0.1, 1.1, 0.04), Basis.IDENTITY, 0.0)
		mesh.box("brass", Vector3(cx, h + 0.1, (z0 + z1) * 0.5), Vector3(width + 0.2, 0.2, z1 - z0 + 0.2), Basis.IDENTITY, 0.0)
		mesh.box("grey_dark", Vector3(cx, h + 0.35, (z0 + z1) * 0.5), Vector3(width, 0.3, z1 - z0 - 0.2), Basis.IDENTITY, 0.02)
		mesh.box("brass", Vector3(cx, 2.4, z1 + 0.03), Vector3(width, 0.1, 0.08), Basis.IDENTITY, 0.0)
		for entry: Array in ELEVATOR_DOORS:
			var x: float = float(entry[1])
			if x < span.x or x > span.y:
				continue
			var live: bool = str(entry[0]) == "mini_dungeon"
			# the shaft's stone surround, up to the cornice, and the brass floor dial over the doors
			for side: float in [-1.0, 1.0]:
				mesh.box("grey_light", Vector3(x + side * 1.2, h * 0.5, z1 + 0.08), Vector3(0.3, h, 0.16), Basis.IDENTITY, 0.02)
			mesh.box("grey_light", Vector3(x, 2.15, z1 + 0.08), Vector3(2.7, 0.5, 0.16), Basis.IDENTITY, 0.02)
			mesh.box("glow" if live else "iron", Vector3(x, 2.15, z1 + 0.18), Vector3(0.36, 0.2, 0.02), Basis.IDENTITY, 0.0)
			if live:
				# Nov 18 evening (Part 1.6): the Waiting Room of Eternity's door is lit - a warm glowing frame round the doors, light spilling
				# out, and a brass bracket over them carrying the hanging sign (`sign.mini_dungeon`, see `sign_mount`)
				for side: float in [-1.0, 1.0]:
					mesh.box("warm_glow", Vector3(x + side * 1.08, 0.93, z1 + 0.06), Vector3(0.06, 1.86, 0.06), Basis.IDENTITY, 0.0)
				mesh.box("warm_glow", Vector3(x, 1.88, z1 + 0.06), Vector3(2.22, 0.06, 0.06), Basis.IDENTITY, 0.0)
				mesh.box("iron", Vector3(x, WAITING_SIGN_ARM_Y, z1 + WAITING_SIGN_OUT * 0.5), Vector3(0.08, 0.08, WAITING_SIGN_OUT + 0.1), Basis.IDENTITY, 0.0)
				mesh.box("iron", Vector3(x, WAITING_SIGN_ARM_Y - 0.25, z1 + 0.08), Vector3(0.1, 0.6, 0.1), Basis.IDENTITY, 0.0)
				for side2: float in [-1.0, 1.0]:
					mesh.box("brass", Vector3(x + side2 * 0.3, (WAITING_SIGN_ARM_Y + WAITING_SIGN_Y + 0.45) * 0.5, z1 + WAITING_SIGN_OUT), Vector3(0.03, WAITING_SIGN_ARM_Y - WAITING_SIGN_Y - 0.45, 0.03), Basis.IDENTITY, 0.0)
				for entry2: Array in [[Vector3(x, 2.3, z1 + 1.2), WARM_LIGHT], [Vector3(x, WAITING_SIGN_Y, z1 + 1.0), WARM_LIGHT]]:
					var light: DnaLayout.LightSpot = DnaLayout.LightSpot.new()
					light.pos = entry2[0] as Vector3
					light.color = entry2[1] as Color
					layout.lights.append(light)
			var doors: Node3D = DnaProps.elevator(live)
			var body: MeshInstance3D = doors.get_child(0) as MeshInstance3D
			doors.remove_child(body)
			doors.free()
			body.name = "Elevator_%s" % str(entry[0])
			bank.add_child(body)
			body.position = Vector3(x, 0.0, DnaLayout.ELEVATOR_WALL_Z)  # flush with the wall (Fix pass Nov 4 (B))
		var walls: MeshInstance3D = mesh.instance("LiftShaftWall")
		bank.add_child(walls)
		bank.set_meta(&"one_piece", true)
		chunk_for(Vector3(cx, 0.0, 15.0)).add_child(bank)
		lift_banks.append(bank)
		elevator_walls += 1


## The closed hall's ceiling, dark end bay and painted back wall (Overnight Nov 18); unused while `OPEN_AIR`.
func _build_ceiling(dark: StandardMaterial3D) -> void:
	# the ceiling: one strip per row over every cell that is not outside
	var tool: SurfaceTool = SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	tool.set_normal(Vector3.DOWN)
	for cz: int in range(DnaLayout.H):
		var start: int = -1
		for cx: int in range(DnaLayout.W + 1):
			var inside: bool = cx < DnaLayout.W and not grand.is_outside(Vector2i(cx, cz)) and not DnaLayout.on_approach(float(cx) + 0.5, float(cz) + 0.5)
			if inside and start < 0:
				start = cx
			elif not inside and start >= 0:
				_quad_down(tool, float(start), float(cz), float(cx), float(cz + 1), DnaHall.VAULT_H)
				start = -1
	# the end bay north of the floor: walls, its own high ceiling and the step down to the hall's ceiling
	var y1: float = END_BAY_H
	var z0: float = -END_BAY_DEPTH
	_quad_down(tool, 0.0, z0, float(DnaLayout.W), 0.0, y1)
	_wall_quad(tool, Vector3(0, 0, z0), Vector3(0, 0, 0), y1, Vector3.RIGHT)
	_wall_quad(tool, Vector3(float(DnaLayout.W), 0, 0), Vector3(float(DnaLayout.W), 0, z0), y1, Vector3.LEFT)
	_wall_quad(tool, Vector3(0, DnaHall.VAULT_H, 0.0), Vector3(float(DnaLayout.W), DnaHall.VAULT_H, 0.0), y1 - DnaHall.VAULT_H, Vector3.FORWARD)
	var shell: MeshInstance3D = MeshInstance3D.new()
	shell.name = "HallCeiling"
	shell.mesh = tool.commit()
	shell.material_override = dark
	shell.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	shell.set_meta(&"no_range_cull", true)
	shell.set_meta(&"no_occlusion_fade", true)
	shell.set_meta(PaintedClasses.META_NO_PAINT, true)
	root.add_child(shell)
	# the far wall: the painted hall interior, 2:1 like the picture, filling the end bay's back wall
	if EnvKit.has("DNA-BD-HALL-INTERIOR"):
		var back: MeshInstance3D = MeshInstance3D.new()
		back.name = "HallBackdrop"
		var quad: QuadMesh = QuadMesh.new()
		quad.size = Vector2(float(DnaLayout.W), y1)
		back.mesh = quad
		var picture: StandardMaterial3D = StandardMaterial3D.new()
		picture.albedo_texture = EnvKit.texture("DNA-BD-HALL-INTERIOR")
		picture.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		picture.albedo_color = Color(0.62, 0.58, 0.55)
		picture.set_meta(PaintedClasses.META_NO_PAINT, true)
		picture.set_meta(StyleToon.META_NO_TOON, true)
		back.material_override = picture
		back.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		back.position = Vector3(float(DnaLayout.W) * 0.5, y1 * 0.5, z0 + 0.05)
		back.set_meta(&"no_range_cull", true)
		back.set_meta(&"no_occlusion_fade", true)
		back.set_meta(PaintedClasses.META_NO_PAINT, true)
		root.add_child(back)


## Overnight Nov 18: cool moonlight slanting in from the tall windows of the long side walls onto the marble (every other bay join of a wall
## that runs north-south), each with a few slow dust motes (the motes are off on Low quality and Low-end).
var shaft_count: int = 0


func _build_moon_shafts() -> void:
	var shader: Shader = load("res://world/dna/dna_moon_shaft.gdshader") as Shader
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = shader
	material.set_meta(PaintedClasses.META_NO_PAINT, true)
	material.set_meta(StyleToon.META_NO_TOON, true)
	var motes: bool = not GraphicsQuality.low_end and Settings.graphics_quality != GraphicsQuality.Level.LOW
	var picked: int = 0
	for join: Dictionary in hall_joins:
		var normal: Vector3 = join["normal"] as Vector3
		if absf(normal.x) < 0.5 or float(join.get("length", 0.0)) < 14.0:
			continue
		picked += 1
		if picked % 2 == 1:
			continue
		var at: Vector3 = join["pos"] as Vector3
		var side: Vector3 = Vector3(0, 0, 1)
		var centre: Vector3 = at + side * 2.75
		var top_hi: float = DnaHall.HALL_H * 0.9
		var top_lo: float = DnaHall.HALL_H * 0.66
		var pts: Array[Vector3] = [centre + Vector3(0, top_hi, 0), centre + normal * 9.5, centre + normal * 6.0, centre + Vector3(0, top_lo, 0)]
		var uvs: Array[Vector2] = [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)]
		var tool: SurfaceTool = SurfaceTool.new()
		tool.begin(Mesh.PRIMITIVE_TRIANGLES)
		for k: int in [0, 1, 2, 0, 2, 3]:
			tool.set_uv(uvs[k])
			tool.add_vertex(pts[k])
		var shaft: MeshInstance3D = MeshInstance3D.new()
		shaft.name = "MoonShaft"
		shaft.mesh = tool.commit()
		shaft.material_override = material
		shaft.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		shaft.set_meta(&"no_occlusion_fade", true)
		shaft.set_meta(PaintedClasses.META_NO_PAINT, true)
		chunk_for(centre).add_child(shaft)
		shaft_count += 1
		if motes:
			var dust: GPUParticles3D = GPUParticles3D.new()
			dust.name = "ShaftMotes"
			dust.amount = 14
			dust.lifetime = 9.0
			dust.preprocess = 9.0
			var process: ParticleProcessMaterial = ParticleProcessMaterial.new()
			process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
			process.emission_box_extents = Vector3(2.4, 2.6, 1.0)
			process.gravity = Vector3(0, -0.03, 0)
			process.initial_velocity_min = 0.02
			process.initial_velocity_max = 0.08
			process.direction = Vector3(0, 1, 0)
			process.spread = 180.0
			process.scale_min = 0.6
			process.scale_max = 1.0
			dust.process_material = process
			var dot: QuadMesh = QuadMesh.new()
			dot.size = Vector2(0.05, 0.05)
			var dot_material: StandardMaterial3D = StandardMaterial3D.new()
			dot_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			dot_material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
			dot_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			dot_material.albedo_color = Color(0.85, 0.9, 1.0, 0.55)
			dot_material.set_meta(PaintedClasses.META_NO_PAINT, true)
			dot.material = dot_material
			dust.draw_pass_1 = dot
			dust.visibility_aabb = AABB(Vector3(-4, -4, -3), Vector3(8, 8, 6))
			chunk_for(centre).add_child(dust)
			dust.global_position = centre + normal * 5.0 + Vector3(0, 3.2, 0)


func _kit_aspect(id: String, fallback: float) -> float:
	if not EnvKit.has(id):
		return fallback
	var value: float = EnvKit.aspect(id)
	return value if value > 0.0 else fallback


static var _hanging_shader: Shader


## A camera-facing painted card (the chandeliers, columns, the clock): `hanging` puts the pivot at the top, else at the foot.
static func hanging_card(id: String, size: Vector2, hanging: bool) -> MeshInstance3D:
	if _hanging_shader == null:
		_hanging_shader = load("res://world/dna/dna_hanging.gdshader") as Shader
	var quad: QuadMesh = QuadMesh.new()
	quad.size = size
	quad.center_offset = Vector3(0, -size.y * 0.5 if hanging else size.y * 0.5, 0)
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = quad
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = _hanging_shader
	material.set_shader_parameter("albedo_tex", EnvKit.texture(id))
	material.set_meta(PaintedClasses.META_NO_PAINT, true)
	material.set_meta(StyleToon.META_NO_TOON, true)
	instance.material_override = material
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.extra_cull_margin = size.y
	instance.set_meta(&"no_occlusion_fade", true)
	instance.set_meta(PaintedClasses.META_NO_PAINT, true)
	instance.set_meta(StyleToon.META_NO_TOON, true)
	return instance


## The stamp banners hanging from the gallery rail at every third bay join (01 and 02 in turn), flat on the wall, fading with it.
func _build_hall_banners() -> void:
	if hall_banners.is_empty():
		return
	var fade: DnaFadeMesh = DnaHall.mesh()
	for index: int in range(hall_banners.size()):
		var join: Dictionary = hall_banners[index]
		var at: Vector3 = join["pos"] as Vector3
		var normal: Vector3 = join["normal"] as Vector3
		var side: Vector3 = Vector3(-normal.z, 0.0, normal.x)
		var slot: String = "banner_1" if index % 2 == 0 else "banner_2"
		var width: float = 1.7
		var height: float = width / _kit_aspect("DNA-BANNER-STAMP-01" if slot == "banner_1" else "DNA-BANNER-STAMP-02", 0.34)
		var top: float = DnaHall.BAND_HEIGHTS[1] * DnaHall.HALL_H + 2.4
		var base: Vector3 = at + normal * 0.12
		var piece: Vector4 = Vector4(at.x - normal.x * 0.5, at.z - normal.z * 0.5, 0.5, DnaHall.VAULT_H)
		var a: Vector3 = base - side * width * 0.5 + Vector3(0, top - height, 0)
		var b: Vector3 = base + side * width * 0.5 + Vector3(0, top - height, 0)
		var mirror: bool = normal.x > 0.5 or normal.z < -0.5
		var u0: float = 1.0 if mirror else 0.0
		var u1: float = 0.0 if mirror else 1.0
		fade.quad(slot, piece, [a, b, b + Vector3(0, height, 0), a + Vector3(0, height, 0)], [Vector2(u0, 1.0), Vector2(u1, 1.0), Vector2(u1, 0.0), Vector2(u0, 0.0)], normal)
	var instance: MeshInstance3D = fade.instance("HallBanners")
	instance.set_meta(&"no_range_cull", true)
	root.add_child(instance)


static func _quad_down(tool: SurfaceTool, x0: float, z0: float, x1: float, z1: float, y: float) -> void:
	for p: Vector3 in [Vector3(x0, y, z0), Vector3(x1, y, z1), Vector3(x1, y, z0), Vector3(x0, y, z0), Vector3(x0, y, z1), Vector3(x1, y, z1)]:
		tool.add_vertex(p)


## A dark wall quad from `a` to `b` (on the floor line), `height` tall (the material draws both sides).
static func _wall_quad(tool: SurfaceTool, a: Vector3, b: Vector3, height: float, normal: Vector3) -> void:
	var up: Vector3 = Vector3(0, height, 0)
	tool.set_normal(normal)
	for p: Vector3 in [a, b, b + up, a, b + up, a + up]:
		tool.add_vertex(p)


## The hero landmarks kept from the removed sub-areas (SR-8) as views beyond the balustrades, where they crowd nothing: the Filing Tower west of the Filing
## Department, the Endless Queue along the east rim beside Cubicle Farm B and the Records Basement, the Records Stair beyond the archive's north parapet. Never
## culled or faded, nothing walkable near them. The Stamp of Approval shrine (SR-7) stands on the executive forecourt and blocks through its circles.
## Nov 18 evening: the Filing Tower and the Records Stair moved out of the way of the street behind the west and north fronts (DnaStreet):
## the tower further west (it rises over the roofs), the stair round to the open east side beyond the Records Basement.
const FILING_TOWER: Vector3 = Vector3(-17.0, 0.0, 13.0)
const ENDLESS_QUEUE: Vector3 = Vector3(95.0, 0.0, 26.0)
const RECORDS_STAIR: Vector3 = Vector3(95.5, 0.0, 3.0)
const SHRINE_OFFSET: Vector3 = Vector3(1.6, 0.0, 0.0)


func _build_region_landmarks() -> void:
	_far_landmark({"id": "DNA-HERO-FILING-TOWER", "kind": "tower", "size": [10.0, 22.0, 6.0]}, "FilingTower", FILING_TOWER, 90.0)
	_far_landmark({"id": "DNA-HERO-ENDLESS-QUEUE", "kind": "colonnade", "size": [30.0, 3.0, 2.0]}, "EndlessQueue", ENDLESS_QUEUE, 90.0)
	_far_landmark({"id": "DNA-HERO-RECORDS-STAIR", "kind": "stair", "size": [9.0, 5.0, 8.0]}, "RecordsStair", RECORDS_STAIR, -90.0)
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


## Overnight Nov 19 (Part 8.5): every D.N.A. board faces the camera (eight stood turned away, two edge-on); its mount on the rail is unchanged.
static func sign_rotation(_sign_spec: DnaLayout.Sign) -> float:
	return 0.0
