extends SceneTree
## Graphics Tier 1 diagnostics (run NOT headless): loads a scene like tools/screenshot.gd, waits, then prints every Light3D (shadow settings, cull mask) and
## every MeshInstance3D whose world box overlaps `--box=x0,z0,x1,z1` (name, parent, size, transparency, material). Quits after the report.
##   Godot --path . -s res://tools/scene_probe.gd -- --scene=res://scenes/town.tscn --pos=9,15 --box=4,16,12,21 [--wait=4]

var _args: Dictionary = {}
var _scene: Node
var _elapsed: float = 0.0
var _started: bool = false


func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--"):
			var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
			_args[parts[0]] = parts[1] if parts.size() > 1 else "true"
	root.size = Vector2i(1280, 720)
	DisplayServer.window_set_size(Vector2i(1280, 720))


func _process(delta: float) -> bool:
	if not _started:
		_started = true
		root.get_node("Session").set("save_enabled", false)
		var packed: PackedScene = load(str(_args.get("scene", "res://scenes/town.tscn"))) as PackedScene
		_scene = packed.instantiate()
		if _scene.has_method("screenshot_prepare"):
			_scene.call("screenshot_prepare", _args)
		root.add_child(_scene)
		return false
	_elapsed += delta
	if _elapsed < float(_args.get("wait", 4.0)):
		return false
	for node: Node in root.find_children("*", "Light3D", true, false):
		var light: Light3D = node as Light3D
		var extra: String = ""
		if light is DirectionalLight3D:
			var sun: DirectionalLight3D = light as DirectionalLight3D
			extra = " mode=%d max_dist=%.1f blur=%.2f opacity=%.2f bias=%.3f normal_bias=%.2f" % [sun.directional_shadow_mode, sun.directional_shadow_max_distance, sun.shadow_blur, sun.shadow_opacity, sun.shadow_bias, sun.shadow_normal_bias]
		print("scene_probe light: %s (%s) visible=%s energy=%.2f color=%s rot=%s shadow=%s mask=%d%s" % [light.get_path(), light.get_class(), str(light.is_visible_in_tree()), light.light_energy, str(light.light_color), str(light.rotation_degrees), str(light.shadow_enabled), light.light_cull_mask, extra])
	print("scene_probe atlas: directional shadow atlas %s, viewport positional atlas %d, scaling %d scale %.2f" % ["?", root.positional_shadow_atlas_size, root.scaling_3d_mode, root.scaling_3d_scale])
	if _args.has("box"):
		var b: PackedStringArray = str(_args["box"]).split(",")
		var region: AABB = AABB(Vector3(float(b[0]), -5.0, float(b[1])), Vector3(float(b[2]) - float(b[0]), 60.0, float(b[3]) - float(b[1])))
		for node: Node in root.find_children("*", "MeshInstance3D", true, false):
			var mesh_instance: MeshInstance3D = node as MeshInstance3D
			if mesh_instance.mesh == null or not mesh_instance.is_visible_in_tree():
				continue
			var box: AABB = mesh_instance.global_transform * mesh_instance.get_aabb()
			if not box.intersects(region):
				continue
			var material: Material = mesh_instance.material_override if mesh_instance.material_override != null else mesh_instance.mesh.surface_get_material(0) if mesh_instance.mesh.get_surface_count() > 0 else null
			var material_text: String = "none"
			if material is ShaderMaterial:
				material_text = (material as ShaderMaterial).shader.resource_path.get_file() if (material as ShaderMaterial).shader != null else "shader?"
			elif material != null:
				material_text = material.get_class()
			print("scene_probe mesh: %s parent=%s pos=%s size=%s transparency=%.2f cast=%d layers=%d mat=%s surfaces=%d" % [mesh_instance.name, mesh_instance.get_parent().name if mesh_instance.get_parent() != null else "-", str(box.position.snapped(Vector3(0.1, 0.1, 0.1))), str(box.size.snapped(Vector3(0.1, 0.1, 0.1))), mesh_instance.transparency, mesh_instance.cast_shadow, mesh_instance.layers, material_text, mesh_instance.mesh.get_surface_count()])
	quit(0)
	return true
