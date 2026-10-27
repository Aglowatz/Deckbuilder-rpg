class_name SignPlacement
extends RefCounted
## Fixes Oct 27, Part 3: signs never stand on a path. A zone's paths come as bands (centre segment + half width) from its layout - `paths`
## ({"line": PackedVector2Array, "width"}) or `routes` ({"a", "b", "width"}); a sign whose post stands on one (with MARGIN) steps sideways off the
## nearest band to stand CLEAR beyond its edge, facing the way it did. The layout's own sign moves, so its "Read the sign" spot (ZoneScene) follows.
## Checked over every area by tools/sign_walkway_probe.gd.

const MARGIN: float = 0.25
## How far beyond a path's edge a moved sign's post stands.
const CLEAR: float = 0.7


## Every path band of a layout as [a: Vector2, b: Vector2, half width] (empty when it has none).
static func segments(layout: Object) -> Array:
	var result: Array = []
	if layout == null:
		return result
	if layout.get("paths") is Array:
		for path: Variant in layout.get("paths") as Array:
			var line: PackedVector2Array = (path as Dictionary).get("line", PackedVector2Array()) as PackedVector2Array
			for i: int in range(line.size() - 1):
				result.append([line[i], line[i + 1], float((path as Dictionary).get("width", 2.0)) * 0.5])
	if layout.get("routes") is Array:
		for route: Variant in layout.get("routes") as Array:
			var r: Dictionary = route as Dictionary
			result.append([r["a"] as Vector2, r["b"] as Vector2, float(r.get("width", 2.0)) * 0.5])
	return result


## Whether a point (x, z) is on a band (within MARGIN of its edge).
static func on_path(point: Vector2, bands: Array) -> bool:
	for band: Variant in bands:
		var b: Array = band as Array
		if Geometry2D.get_closest_point_to_segment(point, b[0] as Vector2, b[1] as Vector2).distance_to(point) <= float(b[2]) + MARGIN:
			return true
	return false


## `pos` moved off every band it stands on, unchanged when it is on none. `open` (optional) says whether a spot is open ground (the builder's
## `is_walkable`): the sign's own side is tried first, then the other side, each a little farther out, so a sign never steps into a wall or water
## (nor onto another path).
static func off_paths(pos: Vector3, bands: Array, open: Callable = Callable()) -> Vector3:
	var p: Vector2 = Vector2(pos.x, pos.z)
	for band: Variant in bands:
		var b: Array = band as Array
		var closest: Vector2 = Geometry2D.get_closest_point_to_segment(p, b[0] as Vector2, b[1] as Vector2)
		var half: float = float(b[2])
		if closest.distance_to(p) > half + MARGIN:
			continue
		var out: Vector2 = p - closest
		if out.length() < 0.01:
			var along: Vector2 = ((b[1] as Vector2) - (b[0] as Vector2)).normalized()
			out = Vector2(-along.y, along.x)  # dead on the centre line: its left first
		out = out.normalized()
		var picked: Vector2 = closest + out * (half + CLEAR)
		var found: bool = false
		for extra: float in [0.0, 0.6, 1.2]:
			for side: float in [1.0, -1.0]:
				var candidate: Vector2 = closest + out * side * (half + CLEAR + extra)
				if on_path(candidate, bands):
					continue
				if not open.is_valid() or bool(open.call(Vector3(candidate.x, pos.y, candidate.y))):
					picked = candidate
					found = true
					break
			if found:
				break
		p = picked
	return Vector3(p.x, pos.y, p.y)
