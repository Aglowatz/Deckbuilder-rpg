class_name OcclusionFader
extends Node
## Walls, roofs and tall props between the camera and the hero fade out (an ordered dither driven by the toon shader instance uniform `occlusion_fade`, shadows
## stay), so the hero is never hidden behind a building (docs/art/graphics_loop.md, G-14). Candidates are the tall meshes of the scene (found again every few
## seconds): wide terrain and low ground pieces never qualify. When a candidate blocks the view the whole object it belongs to (its parent node: a building with
## its roof, trim and doors) dissolves together. Pure geometry: the segment camera -> hero is tested against each candidate's world AABB.

const SCAN_INTERVAL: float = 3.0
const MIN_HEIGHT: float = 1.8
const MAX_EXTENT: float = 28.0
const FADED: float = 0.82
const SPEED: float = 7.0
const HERO_LIFT: float = 0.9
const PADDING: float = 0.15
const MAX_GROUP_MESHES: int = 80

var camera: Camera3D
var hero: Node3D
var root: Node

var _candidates: Array[MeshInstance3D] = []
## Per candidate group key: the meshes that dissolve together (the candidate plus its siblings under the same parent).
var _members: Dictionary = {}
var _fade: Dictionary = {}
var _scan_timer: float = 0.0


func _process(delta: float) -> void:
	if camera == null or hero == null or root == null:
		return
	_scan_timer -= delta
	if _scan_timer <= 0.0:
		_scan_timer = SCAN_INTERVAL
		_scan()
	var from: Vector3 = camera.global_position
	var to: Vector3 = hero.global_position + Vector3(0.0, HERO_LIFT, 0.0)
	var blocking_groups: Dictionary = {}
	for mesh_instance: MeshInstance3D in _candidates:
		if not is_instance_valid(mesh_instance) or not mesh_instance.is_visible_in_tree():
			continue
		var box: AABB = mesh_instance.global_transform * mesh_instance.get_aabb()
		if _segment_hits(box.grow(PADDING), from, to):
			blocking_groups[_group_key(mesh_instance)] = true
	var seen: Dictionary = {}
	for mesh_instance: MeshInstance3D in _candidates:
		if not is_instance_valid(mesh_instance):
			continue
		var key: int = _group_key(mesh_instance)
		if seen.has(key):
			continue
		seen[key] = true
		var current: float = float(_fade.get(key, 0.0))
		var target: float = FADED if blocking_groups.has(key) else 0.0
		if absf(current - target) < 0.004:
			continue
		current = move_toward(current, target, delta * SPEED)
		_fade[key] = current
		for member: Variant in _members.get(key, [mesh_instance]) as Array:
			if is_instance_valid(member):
				(member as MeshInstance3D).set_instance_shader_parameter("occlusion_fade", current)


func _group_key(mesh_instance: MeshInstance3D) -> int:
	var parent: Node = mesh_instance.get_parent()
	if parent != null and parent != root and parent is Node3D and parent != camera:
		return parent.get_instance_id()
	return mesh_instance.get_instance_id()


func _scan() -> void:
	_candidates.clear()
	_members.clear()
	for node: Node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance: MeshInstance3D = node as MeshInstance3D
		if mesh_instance.mesh == null or mesh_instance.layers == 0 or mesh_instance.get_parent() == camera:
			continue
		if mesh_instance.has_meta(&"no_occlusion_fade") or hero.is_ancestor_of(mesh_instance):
			continue
		var box: AABB = mesh_instance.global_transform * mesh_instance.get_aabb()
		if box.size.y < MIN_HEIGHT or maxf(box.size.x, box.size.z) > MAX_EXTENT or box.size.y > 40.0:
			continue
		_candidates.append(mesh_instance)
		var key: int = _group_key(mesh_instance)
		if not _members.has(key):
			var members: Array = []
			var parent: Node = mesh_instance.get_parent()
			if key != mesh_instance.get_instance_id() and parent != null:
				for sibling: Node in parent.find_children("*", "MeshInstance3D", true, false):
					if members.size() < MAX_GROUP_MESHES and not sibling.has_meta(&"no_occlusion_fade"):
						members.append(sibling)
			else:
				members.append(mesh_instance)
			_members[key] = members


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
