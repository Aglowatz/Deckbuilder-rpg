extends SceneTree
## Dev probe (Fable Nov 14, Part 3.4): finds meshes in the Verdant Dump that float above the ground, and wide flat slabs the hero can walk
## through. godot --headless --path . -s res://tools/heap_odd_probe.gd
var _scene: Node
var _t: float = 0.0

func _initialize() -> void:
	var session: Node = root.get_node_or_null("Session")
	if session != null:
		session.set("save_enabled", false)

func _process(delta: float) -> bool:
	if _scene == null:
		_scene = (load("res://scenes/heap_zone.tscn") as PackedScene).instantiate()
		root.add_child(_scene)
		return false
	_t += delta
	if _t < 14.0:
		return false
	var builder: Object = _scene.get("builder") as Object
	var layout: Object = builder.get("layout") as Object
	for node: Node in _scene.find_children("*", "MeshInstance3D", true, false):
		var mi: MeshInstance3D = node as MeshInstance3D
		if mi.mesh == null or not mi.is_visible_in_tree():
			continue
		var box: AABB = mi.global_transform * mi.get_aabb()
		var c: Vector3 = box.get_center()
		if c.x < 16.0 or c.x > 84.0 or c.z < 0.0 or c.z > 138.0:
			continue
		var ground: float = float(layout.call("ground_height", c.x, c.z))
		var lift: float = box.position.y - ground
		var big: float = maxf(box.size.x, box.size.z)
		if lift > 0.5 and lift < 8.0 and big > 0.8 and big < 6.0 and box.size.y > 0.6 and box.size.y < 5.0:
			print("FLOAT lift=%.1f at (%.1f, %.1f) size %s  %s" % [lift, c.x, c.z, str(box.size.snappedf(0.1)), str(mi.get_path()).right(70)])
		if box.size.x > 2.5 and box.size.z > 2.0 and box.size.y < 1.2 and box.size.y > 0.15 and absf(lift) < 0.6 and big < 12.0:
			var open: bool = bool(builder.call("is_walkable", Vector3(c.x + box.size.x * 0.35, 0, c.z))) or bool(builder.call("is_walkable", Vector3(c.x - box.size.x * 0.35, 0, c.z)))
			print("SLAB walk_through=%s at (%.1f, %.1f) size %s  %s" % [str(open), c.x, c.z, str(box.size.snappedf(0.1)), str(mi.get_path()).right(70)])
	quit(0)
	return true
