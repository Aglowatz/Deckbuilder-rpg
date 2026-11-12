class_name PropGroundCheck
extends RefCounted
## Fable Nov 12 (Part 2.5): the check for props that float over the ground or lie sunk under it. Looks at every visible prop-sized mesh
## under a scene root: its world box's underside against the ground height at its centre (`height_at`, the zone map's own function).
## A prop FLOATS when its underside is more than FLOAT_GAP over the ground, and is SUNK when more than SUNK_SHARE of its height is under
## it. Things that hang or fly by design are skipped by name (banners, bunting, lanterns, signs, birds, clouds, islands, wires, smoke,
## glows) or by the meta `off_ground`; anything standing on another prop (a jar on a counter) is skipped when a bigger mesh's top lies
## just under it. `play_script` runs it on the live scene (`groundscan`); `tests/world/test_prop_ground_nov12.gd` pins the rules.

const FLOAT_GAP: float = 0.35
const SUNK_SHARE: float = 0.6
## Prop-sized: bigger than a pebble, smaller than a building (metres, the box's longest side).
const MIN_SIZE: float = 0.3
const MAX_SIZE: float = 6.0
const STACK_GAP: float = 0.3
const META_OFF_GROUND: StringName = &"off_ground"
const HANGING_WORDS: Array[String] = [
	"banner", "bunting", "lantern", "lamp", "sign", "bird", "cloud", "island", "wire", "cable", "smoke", "steam", "glow", "flag", "sail",
	"spinner", "kite", "balloon", "rope", "chain", "pennant", "vine", "awning", "roof", "beam", "mist", "foam", "water", "fall", "shadow",
	"proxy", "outline", "decal", "marker", "beacon", "plate", "label", "light", "mote", "crown", "canopy", "leaf", "leaves", "ring", "arch",
	"emblem", "window", "glass", "card", "sprite", "celebration", "skyline", "backdrop", "far", "haze", "rim", "summit", "bridge", "span",
	"sky", "lookpieces", "scenery", "distant", "sheet", "flat_", "raft", "slab", "lip", "apron", "sea", "pool", "pit", "river", "stream",
]


## One line per offender: {"path", "kind" ("floats" / "sunk"), "gap" (metres over the ground, negative = under), "pos"}.
static func scan(root: Node, height_at: Callable, limit: int = 200) -> Array[Dictionary]:
	var boxes: Array[AABB] = []
	var meshes: Array[MeshInstance3D] = []
	for node: Node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh: MeshInstance3D = node as MeshInstance3D
		if mesh.mesh == null or not mesh.is_visible_in_tree():
			continue
		boxes.append(mesh.global_transform * mesh.get_aabb())
		meshes.append(mesh)
	var result: Array[Dictionary] = []
	for index: int in range(meshes.size()):
		var mesh: MeshInstance3D = meshes[index]
		var box: AABB = boxes[index]
		var size: float = maxf(box.size.x, maxf(box.size.y, box.size.z))
		if size < MIN_SIZE or size > MAX_SIZE or skipped(mesh, root):
			continue
		var centre: Vector3 = box.get_center()
		var ground: float = float(height_at.call(centre))
		var gap: float = box.position.y - ground
		var kind: String = ""
		if gap > FLOAT_GAP and not _stands_on(box, boxes, index):
			kind = "floats"
		elif box.size.y > 0.05 and (ground - box.position.y) / box.size.y > SUNK_SHARE:
			kind = "sunk"
		if kind != "":
			result.append({"path": str(root.get_path_to(mesh)), "kind": kind, "gap": gap, "pos": centre})
			if result.size() >= limit:
				break
	return result


## Hanging or flying by design: a name (its own or an ancestor's below `root`) with one of HANGING_WORDS, or the meta.
static func skipped(mesh: Node, root: Node) -> bool:
	var node: Node = mesh
	while node != null and node != root:
		if node.has_meta(META_OFF_GROUND):
			return true
		var lowered: String = str(node.name).to_lower()
		for word: String in HANGING_WORDS:
			if lowered.contains(word):
				return true
		node = node.get_parent()
	return false


## True when a bigger mesh's top lies just under this box's underside and covers its centre (a prop on a table, a roof on a wall).
static func _stands_on(box: AABB, boxes: Array[AABB], self_index: int) -> bool:
	var centre: Vector3 = box.get_center()
	for index: int in range(boxes.size()):
		if index == self_index:
			continue
		var other: AABB = boxes[index]
		if other.size.x * other.size.z < box.size.x * box.size.z * 0.6:
			continue
		if centre.x < other.position.x or centre.x > other.end.x or centre.z < other.position.z or centre.z > other.end.z:
			continue
		if other.position.y <= box.position.y and other.end.y >= box.position.y - STACK_GAP:
			return true
	return false
