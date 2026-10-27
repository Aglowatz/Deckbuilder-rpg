extends SceneTree
## Fixes Oct 26, Part 6: does any NPC stand inside a prop, a building or another NPC? Loads one area (windowed, like a play session) and checks every
## standing NPC (the scene's `_npcs`): a ring of RING_SAMPLES points RING m round them is tested with the area's own `is_walkable` (body BODY m, so the
## NPC's own small blocker never counts); a blocked share above `--limit` (default 0.25) is reported with the blocked directions, and so is every pair
## of NPCs closer than PAIR_GAP. Lines "npc_overlap: <scene> <npc> at (x, z) blocked=<n>/<N> dirs=<...>" and "npc_overlap_pair: ...", then
## "npc_overlap_summary: <scene> npcs=<n> crowded=<n> pairs=<n>".
##   Godot --path . -s res://tools/npc_overlap_probe.gd -- --scene=res://scenes/buffet_zone.tscn [--limit=0.25]

var RING: float = 0.75  # --ring=
var BODY: float = 0.2  # --body=
const RING_SAMPLES: int = 16
const PAIR_GAP: float = 1.2

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
	var area: Object = _area()
	var npcs: Dictionary = _scene.get("_npcs") as Dictionary if _scene.get("_npcs") is Dictionary else {}
	var label: String = str(_args.get("label", _args.get("scene")))
	if area == null:
		print("npc_overlap_summary: %s no walkable area found" % label)
		return
	var limit: float = float(_args.get("limit", 0.25))
	RING = float(_args.get("ring", RING))
	BODY = float(_args.get("body", BODY))
	var crowded: int = 0
	var standing: Array = []
	for id: Variant in npcs.keys():
		var node: Node3D = npcs[id] as Node3D
		if node == null or not is_instance_valid(node) or not node.is_inside_tree() or not node.is_visible_in_tree():
			continue
		if str(node.name).begins_with("Stroller_"):
			continue  # walkers move: their path keeps them on open ground
		var at: Vector3 = node.global_position
		standing.append([str(id), at])
		var blocked: int = 0
		var dirs: PackedStringArray = []
		for k: int in range(RING_SAMPLES):
			var angle: float = TAU * float(k) / float(RING_SAMPLES)
			var p: Vector3 = at + Vector3(cos(angle), 0.0, sin(angle)) * RING
			if not bool(area.call("is_walkable", p, BODY)):
				blocked += 1
				dirs.append("%d" % int(round(rad_to_deg(angle))))
		if float(blocked) / float(RING_SAMPLES) > limit:
			crowded += 1
			print("npc_overlap: %s %s at (%.1f, %.1f) blocked=%d/%d dirs=%s" % [label, str(id), at.x, at.z, blocked, RING_SAMPLES, ",".join(dirs)])
	var pairs: int = 0
	for i: int in range(standing.size()):
		for j: int in range(i + 1, standing.size()):
			var a: Vector3 = standing[i][1] as Vector3
			var b: Vector3 = standing[j][1] as Vector3
			if Vector2(a.x - b.x, a.z - b.z).length() < PAIR_GAP:
				pairs += 1
				print("npc_overlap_pair: %s %s and %s %.2f m apart" % [label, str(standing[i][0]), str(standing[j][0]), Vector2(a.x - b.x, a.z - b.z).length()])
	print("npc_overlap_summary: %s npcs=%d crowded=%d pairs=%d" % [label, standing.size(), crowded, pairs])
