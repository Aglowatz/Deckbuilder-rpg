extends SceneTree
## Fixes Oct 27, Part 3: does any sign stand in a walkway or float? Loads one area (windowed, like a play session) and checks every sign in it (every icon
## sign picture, IconSign.NODE_NAME, and the board it is on) against the area's own `is_walkable`:
##   - "wall"   : something solid right behind its face (a wall, a building, a stall) - mounted, fine;
##   - "post"   : its own geometry reaches the ground and the ground under it is not walkable (a post or stand with its blocker) - fine;
##   - "verge"  : it stands on its own post on walkable ground beside the paths (grass by a road) - a post beside the path, fine;
##   - "walkway": it stands on a path (the area's paths / routes / roads, with a quarter metre's margin), or on the D.N.A.'s floor where every cell is
##                walkway, with nothing behind it - a problem;
##   - "floats" : nothing behind it and nothing under it (hanging in the air over the floor, a path or a drop) - a problem.
## Lines "sign_walkway: <label> <verdict> <node path> at (x, y, z)", then "sign_walkway_summary: <label> signs=<n> problems=<n>".
##   Godot --path . -s res://tools/sign_walkway_probe.gd -- --scene=res://scenes/dna_zone.tscn [--label=dna]    (all areas: bash tools/run_sign_walkway_probe.sh)

## How far behind a sign's face to look for something solid (its board's own thickness and a hand's width).
const BEHIND: Array[float] = [0.12, 0.25, 0.4]
const PROBE_BODY: float = 0.05
const GROUND_REACH: float = 0.3

var _args: Dictionary = {}
var _scene: Node
var _wait: int = 300
var _started: bool = false


func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--"):
			var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
			_args[parts[0]] = parts[1] if parts.size() > 1 else "true"
	root.size = Vector2i(960, 540)


func _process(_delta: float) -> bool:
	if not _started:
		_started = true
		root.get_node("Session").set("save_enabled", false)
		_scene = (load(str(_args.get("scene", "res://scenes/town.tscn"))) as PackedScene).instantiate()
		if _scene.has_method("screenshot_prepare"):
			_scene.call("screenshot_prepare", _args)
		root.add_child(_scene)
		return false
	_wait -= 1
	if _wait > 0:
		return false
	_check()
	quit(0)
	return true


func _area() -> Object:
	for key: String in ["builder", "town", "area"]:
		var value: Variant = _scene.get(key)
		if value is Object and (value as Object).has_method("is_walkable"):
			return value as Object
	return null


func _check() -> void:
	var label: String = str(_args.get("label", _args.get("scene")))
	var area: Object = _area()
	if area == null:
		print("sign_walkway_summary: %s no walkable area found" % label)
		return
	var count: int = 0
	var problems: int = 0
	var paths: Array = path_segments(_scene)
	for node: Node in _scene.find_children(IconSign.NODE_NAME, "Node3D", true, false):
		var icon: Node3D = node as Node3D
		if icon == null:  # far chunks are hidden by distance culling: every sign counts
			continue
		count += 1
		var verdict: String = verdict_for(icon, area, paths)
		var p: Vector3 = icon.global_position
		var holder: Node3D = icon.get_parent() as Node3D
		var line: String = "sign_walkway: %s %s %s at (%.2f, %.2f, %.2f) lowest %.2f ground %.2f" % [label, verdict, _scene.get_path_to(holder), p.x, p.y, p.z, _lowest_point(holder if holder != null else icon), _ground_y(area, Vector3(p.x, 0.0, p.z))]
		if verdict == "walkway" or verdict == "floats":
			problems += 1
			print(line)
		elif _args.has("all"):
			print(line)
	print("sign_walkway_summary: %s signs=%d problems=%d path_segments=%d" % [label, count, problems, paths.size()])


## Every path band of the area as [a: Vector2, b: Vector2, half width]: the zones' `paths` ({"line", "width"}), the Capital's `routes` ({"a", "b", "width"}),
## the hub's roads ({"points"}: the ROADS widths of the node's script). An area with none (the D.N.A.: all floor is walkway) returns [].
static func path_segments(scene: Node) -> Array:
	var builder: Object = scene.get("builder") as Object if scene.get("builder") is Object else null
	var layout: Object = builder.get("layout") as Object if builder != null and builder.get("layout") is Object else null
	var result: Array = SignPlacement.segments(layout)
	for node: Node in scene.find_children("*", "Node3D", true, false):
		if not node.get("roads") is Dictionary:
			continue
		# the road widths from the node's own script (HubLand.ROADS; a -s tool script must not name a class that needs the autoloads)
		var styles: Dictionary = (node.get_script() as Script).get_script_constant_map().get("ROADS", {}) as Dictionary
		for id: Variant in (node.get("roads") as Dictionary).keys():
			var points: PackedVector3Array = ((node.get("roads") as Dictionary)[id] as Dictionary).get("points", PackedVector3Array()) as PackedVector3Array
			var half: float = float((styles.get(id, {"width": 3.0}) as Dictionary)["width"]) * 0.5
			for i: int in range(points.size() - 1):
				result.append([Vector2(points[i].x, points[i].z), Vector2(points[i + 1].x, points[i + 1].z), half])
	return result


static func verdict_for(icon: Node3D, area: Object, paths: Array = []) -> String:
	var p: Vector3 = icon.global_position
	var n: Vector3 = icon.global_basis.z
	n.y = 0.0
	if n.length() > 0.01:
		n = n.normalized()
		# solid on either side of the face: mounted (an icon plane may face out of its board's back). Walkability cannot tell a board on a wall from one
		# inside it, so the moved signs are also checked by eye (docs/fixes_oct27/p3).
		var solid: Array[bool] = [false, false]
		for i: int in range(2):
			for depth: float in BEHIND:
				var behind: Vector3 = p + n * depth * (-1.0 if i == 0 else 1.0)
				if not bool(area.call("is_walkable", Vector3(behind.x, 0.0, behind.z), PROBE_BODY)):
					solid[i] = true
		if solid[0] or solid[1]:
			return "wall"
	var holder: Node3D = icon.get_parent() as Node3D
	var bottom: float = _lowest_point(holder if holder != null else icon)
	var ground: Vector3 = Vector3(p.x, 0.0, p.z)
	var reaches_ground: bool = bottom <= _ground_y(area, ground) + GROUND_REACH
	var walkable: bool = bool(area.call("is_walkable", ground, PROBE_BODY))
	if not reaches_ground:
		return "floats"
	if not walkable:
		return "post"
	# a standing sign on walkable ground: on a path (or in an area that is all walkway) it is in the way; beside the paths it is a post on the verge
	return "walkway" if paths.is_empty() or SignPlacement.on_path(Vector2(p.x, p.z), paths) else "verge"


## The lowest point of the visible meshes under `node` (world y).
static func _lowest_point(node: Node3D) -> float:
	var lowest: float = INF
	for child: Node in [node] + node.find_children("*", "MeshInstance3D", true, false):
		var mesh: MeshInstance3D = child as MeshInstance3D
		if mesh == null or mesh.mesh == null:
			continue
		var box: AABB = mesh.global_transform * mesh.get_aabb()
		lowest = minf(lowest, box.position.y)
	return lowest


## The ground height under a point: the area's own height (WalkableArea.height_at) when it has one, else 0.
static func _ground_y(area: Object, pos: Vector3) -> float:
	return float(area.call("height_at", pos)) if area.has_method("height_at") else 0.0
