extends SceneTree
## Dev probe (Fable Nov 14): lists the flat meshes lying under given points of a scene, to find which ground is drawn where.
## godot --path . -s res://tools/flat_mesh_probe.gd -- --scene=res://scenes/town.tscn --points=50,45;56.5,45
var _scene: Node
var _t: float = 0.0
var _args: Dictionary = {}

func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
		_args[parts[0]] = parts[1] if parts.size() > 1 else "true"
	var session: Node = root.get_node_or_null("Session")
	if session != null:
		session.set("save_enabled", false)

func _process(delta: float) -> bool:
	if _scene == null:
		_scene = (load(str(_args.get("scene", "res://scenes/town.tscn"))) as PackedScene).instantiate()
		if _scene.has_method("screenshot_prepare"):
			_scene.call("screenshot_prepare", {"quiet": "1"})
		root.add_child(_scene)
		return false
	_t += delta
	if _t < float(_args.get("wait", 12.0)):
		return false
	for spec: String in str(_args.get("points", "0,0")).split(";", false):
		var xy: PackedStringArray = spec.split(",")
		var p: Vector3 = Vector3(float(xy[0]), 0.0, float(xy[1]))
		print("POINT ", p)
		for node: Node in _scene.find_children("*", "MeshInstance3D", true, false):
			var mi: MeshInstance3D = node as MeshInstance3D
			if mi.mesh == null or not mi.is_visible_in_tree():
				continue
			var box: AABB = mi.global_transform * mi.get_aabb()
			if box.size.y < 0.6 and box.size.x * box.size.z > 60.0 and box.position.y < 0.5 and box.end.y > -0.5 and p.x > box.position.x and p.x < box.end.x and p.z > box.position.z and p.z < box.end.z:
				print("  ", mi.get_path(), " ", box.position.snappedf(0.1), " ", box.size.snappedf(0.1), " mat=", mi.material_override.resource_path if mi.material_override != null else "-")
	quit(0)
	return true
