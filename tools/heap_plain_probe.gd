extends SceneTree
## Dev probe (Fable Nov 15b, Part 2): lists the Verdant Dump's untextured (plain-colour) meshes of furniture size, with the colour, so a
## stand-in slab in a screenshot can be found by its colour. godot --headless --path . -s res://tools/heap_plain_probe.gd [-- --min=1.2]
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
		if OS.get_environment("HEAP_PROBE_RECT").is_empty() and (c.x < 16.0 or c.x > 84.0 or c.z < 0.0 or c.z > 138.0):
			continue
		var big: float = maxf(box.size.x, maxf(box.size.y, box.size.z))
		var rect: String = OS.get_environment("HEAP_PROBE_RECT")  # "x0,z0,x1,z1": every mesh in it, any size
		if not rect.is_empty():
			var r: PackedFloat64Array = rect.split_floats(",")
			if box.end.x < r[0] or box.position.x > r[2] or box.end.z < r[1] or box.position.z > r[3] or big < 0.5:
				continue
		elif big < 1.2 or big > 9.0:
			continue
		var mat: Material = mi.material_override
		if mat == null and mi.mesh.get_surface_count() > 0:
			mat = mi.get_active_material(0)
		var colour: String = "none"
		var textured: bool = false
		if mat is StandardMaterial3D:
			textured = (mat as StandardMaterial3D).albedo_texture != null
			colour = (mat as StandardMaterial3D).albedo_color.to_html(false)
		elif mat is ShaderMaterial:
			colour = "shader:" + (mat as ShaderMaterial).shader.resource_path.get_file()
			textured = true
			for key: String in ["albedo", "base_color", "color", "tint"]:
				var v: Variant = (mat as ShaderMaterial).get_shader_parameter(key)
				if v is Color:
					colour += " " + (v as Color).to_html(false)
		var ground: float = float(layout.call("ground_height", c.x, c.z))
		print("PLAIN tex=%s col=%s at (%.1f, %.1f) lift=%.1f size %s mesh=%s  %s" % [str(textured), colour, c.x, c.z, box.position.y - ground, str(box.size.snappedf(0.1)), mi.mesh.get_class(), str(mi.get_path()).right(80)])
	quit(0)
	return true
