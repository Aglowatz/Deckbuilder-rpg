class_name ScatterTool
extends RefCounted
## Set-dressing scatter (docs/art/style_guide.md, section 8): weighted prop sets placed in clusters of three (a big, a medium and a small piece), never
## inside keep-out circles/polygons or on the 2 m walkable lanes, optionally hugging path edges or building skirts, with scale/rotation/tint jitter. Pure logic:
## it returns `Placement`s (no scene nodes), is deterministic for a given seed and keeps a per-set report, so it can be unit tested without a scene tree.

## One prop that may be picked: `weight` is relative, scale is in the model's own units.
class Entry:
	var folder: String = ""
	var model: String = ""
	var weight: float = 1.0
	var min_scale: float = 1.0
	var max_scale: float = 1.0
	## Largest random brightness change of the instance tint (0 = untinted).
	var tint_jitter: float = 0.0
	## Obstacle radius registered for the walkable-area blockers (0 = decorative, never blocks).
	var blocker_radius: float = 0.0

	static func make(folder_path: String, model_name: String, weight_value: float, min_s: float, max_s: float, jitter: float = 0.0, blocker: float = 0.0) -> Entry:
		var entry: Entry = Entry.new()
		entry.folder = folder_path
		entry.model = model_name
		entry.weight = weight_value
		entry.min_scale = min_s
		entry.max_scale = max_s
		entry.tint_jitter = jitter
		entry.blocker_radius = blocker
		return entry


## One placed prop.
class Placement:
	var position: Vector3 = Vector3.ZERO
	var yaw: float = 0.0
	var scale: float = 1.0
	var tint: Color = Color.WHITE
	var set_id: String = ""
	var folder: String = ""
	var model: String = ""
	var cluster: int = 0
	## Cluster role: 0 big, 1 medium, 2 small.
	var role: int = 0
	var blocker_radius: float = 0.0

	func transform() -> Transform3D:
		return Transform3D(Basis(Vector3.UP, yaw).scaled(Vector3.ONE * scale), position)


const ROLE_SCALE: Array[float] = [1.0, 0.72, 0.5]

var seed_value: int = 1
var bounds: Rect2 = Rect2(-20, -20, 40, 40)
## Circles to keep clear: Vector3(x, z, radius).
var keep_out_circles: Array[Vector3] = []
## Polygons (x/z) to keep clear (buildings, water).
var keep_out_polygons: Array[PackedVector2Array] = []
## Walkable lanes as polylines (x/z); nothing is placed within `lane_half_width` of one, except the path-edge rule which sits just outside.
var lanes: Array[PackedVector2Array] = []
var lane_half_width: float = 1.0
## Optional: Callable(Vector3) -> bool, true where props may stand (on land).
var is_floor: Callable = Callable()
## Optional: Callable(Vector3) -> float, the ground height at x/z.
var height_at: Callable = Callable()
## Height window props may stand in (slope/height rule: no props on peaks or in pits).
var min_height: float = -1000.0
var max_height: float = 1000.0
## Obstacle circles of the placed props that block (Vector3(x, z, radius)), for the walkable area.
var blockers: Array[Vector3] = []

var _report: Dictionary = {}
var _next_cluster: int = 0


## How many props each set placed: set id -> count.
func report() -> Dictionary:
	return _report.duplicate()


## Scatters `count` props of `entries` as clusters of `cluster_size` (3 = big, medium, small). `path_edge` is the share (0..1) of clusters that hug a lane edge;
## `skirt_points` (building anchors) with `skirt_radius` gives the share `skirt_share` of clusters that stand around a building.
func scatter(set_id: String, entries: Array[Entry], count: int, cluster_size: int = 3, cluster_radius: float = 1.1, path_edge: float = 0.0, skirt_points: Array[Vector3] = [], skirt_radius: float = 2.2, skirt_share: float = 0.0) -> Array[Placement]:
	var result: Array[Placement] = []
	if entries.is_empty() or count <= 0:
		return result
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_value * 7919 + hash(set_id)
	var total_weight: float = 0.0
	for entry: Entry in entries:
		total_weight += maxf(entry.weight, 0.0001)
	var tries: int = 0
	while result.size() < count and tries < count * 40:
		tries += 1
		var centre: Vector3 = _pick_centre(rng, path_edge, skirt_points, skirt_radius, skirt_share)
		if not _allowed(centre):
			continue
		_next_cluster += 1
		for role: int in range(maxi(cluster_size, 1)):
			var offset: Vector2 = Vector2.ZERO if role == 0 else Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(0.35, 1.0) * cluster_radius
			var pos: Vector3 = centre + Vector3(offset.x, 0.0, offset.y)
			if role > 0 and not _allowed(pos):
				continue
			var entry: Entry = _pick_entry(rng, entries, total_weight)
			var placement: Placement = Placement.new()
			placement.position = pos
			if height_at.is_valid():
				placement.position.y = float(height_at.call(pos))
			placement.yaw = rng.randf() * TAU
			placement.scale = rng.randf_range(entry.min_scale, entry.max_scale) * ROLE_SCALE[mini(role, ROLE_SCALE.size() - 1)]
			if entry.tint_jitter > 0.0:
				var shade: float = 1.0 + rng.randf_range(-entry.tint_jitter, entry.tint_jitter)
				placement.tint = Color(shade, shade, shade, 1.0)
			placement.set_id = set_id
			placement.folder = entry.folder
			placement.model = entry.model
			placement.cluster = _next_cluster
			placement.role = role
			placement.blocker_radius = entry.blocker_radius
			result.append(placement)
			if entry.blocker_radius > 0.0:
				blockers.append(Vector3(pos.x, pos.z, entry.blocker_radius * placement.scale))
			if result.size() >= count:
				break
	_report[set_id] = int(_report.get(set_id, 0)) + result.size()
	return result


func _pick_entry(rng: RandomNumberGenerator, entries: Array[Entry], total_weight: float) -> Entry:
	var roll: float = rng.randf() * total_weight
	for entry: Entry in entries:
		roll -= maxf(entry.weight, 0.0001)
		if roll <= 0.0:
			return entry
	return entries[entries.size() - 1]


func _pick_centre(rng: RandomNumberGenerator, path_edge: float, skirt_points: Array[Vector3], skirt_radius: float, skirt_share: float) -> Vector3:
	var roll: float = rng.randf()
	if not skirt_points.is_empty() and roll < skirt_share:
		var anchor: Vector3 = skirt_points[rng.randi() % skirt_points.size()]
		var offset: Vector2 = Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(skirt_radius * 0.6, skirt_radius)
		return Vector3(anchor.x + offset.x, 0.0, anchor.z + offset.y)
	if not lanes.is_empty() and roll < skirt_share + path_edge:
		var lane: PackedVector2Array = lanes[rng.randi() % lanes.size()]
		if lane.size() >= 2:
			var index: int = rng.randi() % (lane.size() - 1)
			var a: Vector2 = lane[index]
			var b: Vector2 = lane[index + 1]
			var point: Vector2 = a.lerp(b, rng.randf())
			var direction: Vector2 = (b - a).normalized()
			var side: float = 1.0 if rng.randf() < 0.5 else -1.0
			var edge: Vector2 = point + direction.orthogonal() * side * (lane_half_width + rng.randf_range(0.25, 1.1))
			return Vector3(edge.x, 0.0, edge.y)
	return Vector3(rng.randf_range(bounds.position.x, bounds.end.x), 0.0, rng.randf_range(bounds.position.y, bounds.end.y))


## True where a prop may stand: inside the bounds, on land, in the height window, outside keep-outs and off the lanes.
func _allowed(pos: Vector3) -> bool:
	if not bounds.has_point(Vector2(pos.x, pos.z)):
		return false
	if is_floor.is_valid() and not bool(is_floor.call(pos)):
		return false
	if height_at.is_valid():
		var height: float = float(height_at.call(pos))
		if height < min_height or height > max_height:
			return false
	for circle: Vector3 in keep_out_circles:
		if Vector2(pos.x - circle.x, pos.z - circle.y).length() < circle.z:
			return false
	for polygon: PackedVector2Array in keep_out_polygons:
		if Geometry2D.is_point_in_polygon(Vector2(pos.x, pos.z), polygon):
			return false
	for lane: PackedVector2Array in lanes:
		if _distance_to_polyline(Vector2(pos.x, pos.z), lane) < lane_half_width:
			return false
	return true


static func _distance_to_polyline(point: Vector2, line: PackedVector2Array) -> float:
	var best: float = INF
	for i: int in range(line.size() - 1):
		var closest: Vector2 = Geometry2D.get_closest_point_to_segment(point, line[i], line[i + 1])
		best = minf(best, point.distance_to(closest))
	return best
