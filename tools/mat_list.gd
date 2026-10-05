extends SceneTree
## Lists unique material names + colours of every .glb in a folder: Godot --headless --path . -s res://tools/mat_list.gd -- res://assets/kenney-nature-kit/models/
func _initialize() -> void:
	var seen: Dictionary = {}
	var folder: String = OS.get_cmdline_user_args()[0]
	for file: String in DirAccess.get_files_at(folder):
		if not file.ends_with(".glb"):
			continue
		var node: Node = (load(folder + file) as PackedScene).instantiate()
		for child: Node in node.find_children("*", "MeshInstance3D", true, false):
			var mi: MeshInstance3D = child as MeshInstance3D
			for s: int in range(mi.mesh.get_surface_count()):
				var m: StandardMaterial3D = mi.get_active_material(s) as StandardMaterial3D
				if m != null and not seen.has(m.resource_name):
					seen[m.resource_name] = "%s tex=%s (first in %s)" % [m.albedo_color.to_html(false), str(m.albedo_texture != null), file]
		node.free()
	for key: String in seen:
		print(key, " ", seen[key])
	quit()
