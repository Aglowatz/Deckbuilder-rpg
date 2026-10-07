class_name ChestKit
extends RefCounted
## The hidden chests' open and shut look. The KayKit gold chest is a body plus a separate lid (`chest_gold_lid`, hinged at the back), so "opened"
## is the lid swung up and back. An opened chest stays open: scenes call `set_open(chest, true)` for every chest the save says was found, and
## `open_animated` when the player opens one now.

const LID_NODE: String = "chest_gold_lid"
const BODY_NODE: String = "chest_gold"
## The lid's rotation about its hinge when open (degrees about X: up and back).
const OPEN_ANGLE: float = -112.0


static func lid_of(chest: Node3D) -> Node3D:
	if chest == null:
		return null
	return chest.find_child(LID_NODE, true, false) as Node3D


## Snaps the lid open or shut. An open chest is also empty: the gold pile the model carries inside it is left out of the body mesh. False when the model has no lid.
static func set_open(chest: Node3D, open: bool) -> bool:
	var lid: Node3D = lid_of(chest)
	if lid == null:
		return false
	lid.rotation_degrees.x = OPEN_ANGLE if open else 0.0
	chest.set_meta(&"chest_open", open)
	var body: MeshInstance3D = chest.find_child(BODY_NODE, true, false) as MeshInstance3D
	if body != null:
		if not body.has_meta(&"full_mesh"):
			body.set_meta(&"full_mesh", body.mesh)
		body.mesh = empty_body_mesh(body.get_meta(&"full_mesh") as Mesh) if open else (body.get_meta(&"full_mesh") as Mesh)
	return true


static func is_open(chest: Node3D) -> bool:
	return chest != null and bool(chest.get_meta(&"chest_open", false))


## Swings the lid open with a little overshoot; returns the tween (null when there is no lid). The state is recorded at once.
static func open_animated(chest: Node3D) -> Tween:
	var lid: Node3D = lid_of(chest)
	if lid == null:
		return null
	chest.set_meta(&"chest_open", true)
	var tween: Tween = lid.create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(lid, "rotation_degrees:x", OPEN_ANGLE, 0.5)
	return tween


## Opens every chest in `nodes` (id -> Node3D) whose secret `secret_for(id)` the save already has.
static func apply_saved(nodes: Dictionary, secret_for: Callable) -> int:
	var opened: int = 0
	for id: Variant in nodes.keys():
		if Session.found_secret(str(secret_for.call(str(id)))) and set_open(nodes[id] as Node3D, true):
			opened += 1
	return opened


static var _empty_cache: Dictionary = {}


## The chest body without the gold pile: the model is one welded box plus several loose coin heaps, so keep only the connected piece with the biggest bounding box.
static func empty_body_mesh(source: Mesh) -> Mesh:
	var cache_key: int = source.get_instance_id()
	if _empty_cache.has(cache_key):
		return _empty_cache[cache_key] as Mesh
	var arrays: Array = source.surface_get_arrays(0)
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
	var weld_ids: Dictionary = {}
	var weld: PackedInt32Array = PackedInt32Array()
	weld.resize(vertices.size())
	var parent: Array[int] = []
	for i: int in range(vertices.size()):
		var key: Vector3i = Vector3i(roundi(vertices[i].x * 1000.0), roundi(vertices[i].y * 1000.0), roundi(vertices[i].z * 1000.0))
		if not weld_ids.has(key):
			weld_ids[key] = parent.size()
			parent.append(parent.size())
		weld[i] = int(weld_ids[key])
	for t: int in range(0, indices.size(), 3):
		var root: int = _find(parent, weld[indices[t]])
		parent[_find(parent, weld[indices[t + 1]])] = root
		parent[_find(parent, weld[indices[t + 2]])] = root
	var boxes: Dictionary = {}
	for t: int in range(0, indices.size(), 3):
		var component: int = _find(parent, weld[indices[t]])
		var box: AABB = boxes.get(component, AABB(vertices[indices[t]], Vector3.ZERO)) as AABB
		for j: int in range(3):
			box = box.expand(vertices[indices[t + j]])
		boxes[component] = box
	var keep: int = -1
	var best: float = -1.0
	for component: Variant in boxes.keys():
		var size: Vector3 = (boxes[component] as AABB).size
		var volume: float = size.x * size.y * size.z
		if volume > best:
			best = volume
			keep = int(component)
	var kept: PackedInt32Array = PackedInt32Array()
	for t: int in range(0, indices.size(), 3):
		if _find(parent, weld[indices[t]]) == keep:
			kept.append_array([indices[t], indices[t + 1], indices[t + 2]])
	var out_arrays: Array = arrays.duplicate()
	out_arrays[Mesh.ARRAY_INDEX] = kept
	var mesh: ArrayMesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, out_arrays)
	mesh.surface_set_material(0, source.surface_get_material(0))
	_empty_cache[cache_key] = mesh
	return mesh


static func _find(parent: Array[int], node: int) -> int:
	var root: int = node
	while parent[root] != root:
		root = parent[root]
	var current: int = node
	while parent[current] != root:
		var next: int = parent[current]
		parent[current] = root
		current = next
	return root
