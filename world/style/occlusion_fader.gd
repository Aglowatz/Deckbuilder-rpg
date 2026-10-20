class_name OcclusionFader
extends Node
## Walls, roofs and tall props between the camera and the hero fade out (an ordered dither driven by the toon shader instance uniform `occlusion_fade`, shadows
## stay), so the hero is never hidden behind a building (docs/art/graphics_loop.md, G-14). Candidates are the tall meshes of the scene (found again every few
## seconds): wide terrain and low ground pieces never qualify. When a candidate blocks the view the whole object it belongs to (its parent node: a building with
## its roof, trim and doors) dissolves together. Pure geometry: the segment camera -> hero is tested against each candidate's world AABB.

const SCAN_INTERVAL: float = 4.0
const MIN_HEIGHT: float = 1.0
const MAX_EXTENT: float = 400.0
const FADED: float = 0.88
## The camera is inside (or this close to) a solid piece: it is cut away completely so the lens never looks at back faces.
const CUT_AWAY: float = 1.0
const CAMERA_PADDING: float = 0.7
## Anything this close to the lens (foreground clutter that covers the lower part of the picture) dissolves too.
const NEAR_CAMERA: float = 6.5
const SPEED: float = 7.0
const HERO_LIFT: float = 0.9
const PADDING: float = 0.15
const MAX_GROUP_MESHES: int = 80
## Meshes looked at per frame while a scan is under way.
const SCAN_BATCH: int = 160

var camera: Camera3D
var hero: Node3D
var root: Node

var _candidates: Array[MeshInstance3D] = []
## Per candidate group key: the meshes that dissolve together (the candidate plus its siblings under the same parent).
var _members: Dictionary = {}
var _fade: Dictionary = {}
var _dither_cache: Dictionary = {}
var _scan_timer: float = 0.0
## Cached at each scan: the world box of every candidate, the group each belongs to, and the list of groups.
var _boxes: Array[AABB] = []
var _box_keys: Array[int] = []
## Per box: how close to the lens it dissolves as foreground clutter (a mesh may set its own with the meta `occlusion_near`; kit buildings use a small value).
var _box_near: Array[float] = []
var _next_box_near: Array[float] = []
var _group_keys: Array[int] = []
var _pending: Array[Node] = []
var _pending_index: int = 0
var _next_candidates: Array[MeshInstance3D] = []
var _next_members: Dictionary = {}
var _next_boxes: Array[AABB] = []
var _next_box_keys: Array[int] = []
var _next_group_keys: Array[int] = []


func _process(delta: float) -> void:
	if OS.get_environment("OCCLUSION_OFF") != "":
		return
	if camera == null or hero == null or root == null:
		return
	if _pending_index < _pending.size():
		_scan_step()
	else:
		_scan_timer -= delta
		if _scan_timer <= 0.0:
			_scan_timer = SCAN_INTERVAL
			_scan()
	# The visibility tests are pure float maths over every cached box; the answer changes slowly (the hero walks, the camera glides), so they run about 16 times a second
	# and the dissolve itself still advances every frame.
	_test_timer -= delta
	if _test_timer <= 0.0:
		_test_timer = TEST_INTERVAL
		_run_tests()
	# The painted tree cards fade themselves in their shader from the hero's position (KitFoliage / kit_card.gdshader): a MultiMesh field cannot be faded per tree from here.
	KitFoliage.set_hero(hero.global_position)
	var blocking_groups: Dictionary = _blocking
	var cut_groups: Dictionary = _cut
	for key: int in _active_keys(blocking_groups, cut_groups):
		var current: float = float(_fade.get(key, 0.0))
		var target: float = CUT_AWAY if cut_groups.has(key) else (FADED if blocking_groups.has(key) else 0.0)
		if absf(current - target) < 0.004:
			continue
		current = move_toward(current, target, delta * SPEED)
		_fade[key] = current
		for member: Variant in _members.get(key, []) as Array:
			if is_instance_valid(member):
				var piece: MeshInstance3D = member as MeshInstance3D
				# A smooth transparency fade for every piece (GC-4): Godot's per-instance `transparency` moves the piece to the transparent pass while it fades and keeps its
				# shadow. The ordered dither (`occlusion_fade` in the toon shaders) is no longer driven: the checkerboard read as a glitch on the ground and on props.
				piece.transparency = current


func _group_key(mesh_instance: MeshInstance3D) -> int:
	var parent: Node = mesh_instance.get_parent()
	# A building (a parent with a modest number of pieces) dissolves as one; a chunk or a whole-map holder with hundreds of children does not (one wall would take its
	# neighbours with it, and only the first pieces of the group would ever fade).
	if parent != null and parent != root and parent is Node3D and parent != camera and parent.get_child_count() <= MAX_GROUP_MESHES:
		return parent.get_instance_id()
	return mesh_instance.get_instance_id()


## Starts a scan of the tree for candidates. The work is spread over frames (SCAN_BATCH meshes each): a big zone has thousands of meshes and one frame of scanning was a
## visible hitch. The old candidate list keeps working until the new one is complete.
func _scan() -> void:
	_pending = root.find_children("*", "MeshInstance3D", true, false)
	_pending_index = 0
	_next_candidates = []
	_next_members = {}
	_next_boxes = []
	_next_box_keys = []
	_next_box_near = []
	_next_group_keys = []
	_scan_step()


func _scan_step() -> void:
	var end: int = mini(_pending_index + SCAN_BATCH, _pending.size())
	while _pending_index < end:
		var node: Node = _pending[_pending_index]
		_pending_index += 1
		if not is_instance_valid(node):
			continue
		var mesh_instance: MeshInstance3D = node as MeshInstance3D
		if mesh_instance.mesh == null or mesh_instance.layers == 0 or mesh_instance.get_parent() == camera:
			continue
		if mesh_instance.has_meta(&"no_occlusion_fade") or hero.is_ancestor_of(mesh_instance):
			continue
		var box: AABB = mesh_instance.global_transform * mesh_instance.get_aabb()
		# Big kit buildings: only their core blocks the view (the eaves and the corners of a house at the lens edge are part of the picture, as in the paint-over).
		if mesh_instance.has_meta(&"occlusion_shrink"):
			var shrink: float = minf(float(mesh_instance.get_meta(&"occlusion_shrink")), minf(box.size.x, box.size.z) * 0.4)
			box = AABB(box.position + Vector3(shrink, 0.0, shrink), box.size - Vector3(shrink * 2.0, 0.0, shrink * 2.0))
		# Overnight Oct 19: a thin piece hanging over the hero's ground (a pennant line across an entrance, a beam, a sign over a path) blocks the view as much as a
		# wall does, so it qualifies too and fades on its own (never with its whole landmark).
		var overhead: bool = is_overhead(box, hero.global_position.y) or mesh_instance.has_meta(&"occlusion_overhead")
		if (box.size.y < MIN_HEIGHT and not overhead) or maxf(box.size.x, box.size.z) > MAX_EXTENT or box.size.y > 40.0:
			continue
		if not mesh_instance.is_visible_in_tree():
			continue
		_next_candidates.append(mesh_instance)
		var solo: bool = mesh_instance.has_meta(&"occlusion_overhead") or (overhead and box.size.y < MIN_HEIGHT)
		var key: int = mesh_instance.get_instance_id() if solo else _group_key(mesh_instance)
		_next_boxes.append(box)
		_next_box_keys.append(key)
		_next_box_near.append(float(mesh_instance.get_meta(&"occlusion_near", NEAR_CAMERA)))
		if not _next_members.has(key):
			_next_group_keys.append(key)
			var members: Array = []
			var parent: Node = mesh_instance.get_parent()
			if key != mesh_instance.get_instance_id() and parent != null:
				for sibling: Node in parent.find_children("*", "MeshInstance3D", true, false):
					if members.size() < MAX_GROUP_MESHES and not sibling.has_meta(&"no_occlusion_fade") and not _is_ground(sibling as MeshInstance3D):
						members.append(sibling)
			else:
				members.append(mesh_instance)
			_next_members[key] = members
	if _pending_index >= _pending.size():
		_candidates = _next_candidates
		_members = _next_members
		_boxes = _next_boxes
		_box_keys = _next_box_keys
		_box_near = _next_box_near
		_group_keys = _next_group_keys
		_pending = []


## True for a thin piece (under MIN_HEIGHT tall) that hangs at least OVERHEAD_LIFT above the ground the hero stands on and spans at least OVERHEAD_SPAN: strings
## of pennants, beams and signs over a path. Ground clutter (rugs, low fences, decals) never qualifies.
const OVERHEAD_LIFT: float = 1.4
const OVERHEAD_SPAN: float = 1.5


static func is_overhead(box: AABB, ground_y: float) -> bool:
	return box.size.y < MIN_HEIGHT and box.position.y >= ground_y + OVERHEAD_LIFT and maxf(box.size.x, box.size.z) >= OVERHEAD_SPAN 		and maxf(box.size.x, box.size.z) <= MAX_EXTENT


## Wide terrain never fades with its group (Overnight Oct 17, Phase 2): the starting forest's 900 m floor shares a parent with the clearing's props, so a
## blocking prop took the whole floor to 88% transparent and the purple sky showed through it.
static func _is_ground(mesh_instance: MeshInstance3D) -> bool:
	if mesh_instance == null or mesh_instance.mesh == null:
		return false
	var box: AABB = mesh_instance.global_transform * mesh_instance.get_aabb()
	return maxf(box.size.x, box.size.z) > MAX_EXTENT


## True when the segment from -> to passes through `box` (slab test).
static func _segment_hits(box: AABB, from: Vector3, to: Vector3) -> bool:
	var direction: Vector3 = to - from
	var t_min: float = 0.0
	var t_max: float = 1.0
	for axis: int in range(3):
		var origin: float = from[axis]
		var delta_axis: float = direction[axis]
		var low: float = box.position[axis]
		var high: float = box.position[axis] + box.size[axis]
		if absf(delta_axis) < 0.00001:
			if origin < low or origin > high:
				return false
			continue
		var t1: float = (low - origin) / delta_axis
		var t2: float = (high - origin) / delta_axis
		if t1 > t2:
			var swap: float = t1
			t1 = t2
			t2 = swap
		t_min = maxf(t_min, t1)
		t_max = minf(t_max, t2)
		if t_min > t_max:
			return false
	return true


## True for a mesh drawn with the toon or painted-triplanar shader (they carry the dither uniform); false for anything else (translucent pieces).
func _dithers(mesh_instance: MeshInstance3D) -> bool:
	var key: int = mesh_instance.get_instance_id()
	if _dither_cache.has(key):
		return bool(_dither_cache[key])
	var material: Material = mesh_instance.material_override
	if material == null and mesh_instance.mesh != null and mesh_instance.mesh.get_surface_count() > 0:
		material = mesh_instance.get_surface_override_material(0)
		if material == null:
			material = mesh_instance.mesh.surface_get_material(0)
	var result: bool = false
	if material is ShaderMaterial:
		var shader: Shader = (material as ShaderMaterial).shader
		result = shader != null and (shader.resource_path.contains("style_toon") or shader.resource_path.contains("style_painted"))
	_dither_cache[key] = result
	return result


const TEST_INTERVAL: float = 0.06
var _test_timer: float = 0.0
var _blocking: Dictionary = {}
var _cut: Dictionary = {}


func _run_tests() -> void:
	var from: Vector3 = camera.global_position
	var to: Vector3 = hero.global_position + Vector3(0.0, HERO_LIFT, 0.0)
	var to_low: Vector3 = hero.global_position + Vector3(0.0, 0.35, 0.0)
	var blocking_groups: Dictionary = {}
	var cut_groups: Dictionary = {}
	# Pure float maths over the boxes cached at the last scan (a static scene has thousands of candidates; no node is touched here).
	for index: int in range(_boxes.size()):
		var box: AABB = _boxes[index]
		var key: int = _box_keys[index]
		if cut_groups.has(key):
			continue
		if box.grow(CAMERA_PADDING).has_point(from):
			cut_groups[key] = true
		elif blocking_groups.has(key):
			continue
		elif box.grow(_box_near[index]).has_point(from) or _segment_hits(box.grow(PADDING), from, to) or _segment_hits(box.grow(PADDING), from, to_low):
			blocking_groups[key] = true
	_blocking = blocking_groups
	_cut = cut_groups
	if OS.get_environment("OCCLUSION_DEBUG") != "" and Engine.get_process_frames() % 120 == 0:
		print("occlusion: ", debug_summary())
		print("occlusion blockers: ", "; ".join(debug_blockers()))


## Only the groups that are fading, faded or about to fade need work this frame (the rest of a big scene's groups sit at zero).
func _active_keys(blocking_groups: Dictionary, cut_groups: Dictionary) -> Array[int]:
	var work: Dictionary = {}
	for key: Variant in _fade.keys():
		if float(_fade[key]) > 0.004:
			work[int(key)] = true
	for key: Variant in blocking_groups.keys():
		work[int(key)] = true
	for key: Variant in cut_groups.keys():
		work[int(key)] = true
	var result: Array[int] = []
	for key: Variant in work.keys():
		result.append(int(key))
	return result


func debug_summary() -> String:
	return "boxes %d groups %d blocking %d cut %d fading %d" % [_boxes.size(), _group_keys.size(), _blocking.size(), _cut.size(), _fade.size()]


func debug_blockers() -> PackedStringArray:
	var names: PackedStringArray = PackedStringArray()
	for key: Variant in _blocking.keys():
		var members: Array = _members.get(int(key), []) as Array
		if not members.is_empty() and is_instance_valid(members[0]):
			var piece: MeshInstance3D = members[0] as MeshInstance3D
			names.append("%s/%s %s" % [str(piece.get_parent().name), str(piece.name), str(piece.global_position.snapped(Vector3(0.1, 0.1, 0.1)))])
	return names
