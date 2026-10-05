extends SceneTree
func _initialize() -> void:
	for path: String in OS.get_cmdline_user_args():
		var node: Node = (load(path) as PackedScene).instantiate()
		for child: Node in node.find_children("*", "MeshInstance3D", true, false):
			var mi: MeshInstance3D = child as MeshInstance3D
			for s: int in range(mi.mesh.get_surface_count()):
				var m: Material = mi.get_active_material(s)
				var arrays: Array = mi.mesh.surface_get_arrays(s)
				print(path.get_file(), " ", mi.name, " mat=", m.resource_name, " cls=", m.get_class())
				if m is StandardMaterial3D:
					var sm: StandardMaterial3D = m as StandardMaterial3D
					print("   albedo=", sm.albedo_color, " tex=", sm.albedo_texture, " vc=", sm.vertex_color_use_as_albedo, " uvscale=", sm.uv1_scale, " cull=", sm.cull_mode, " transp=", sm.transparency)
				print("   has color array: ", arrays[Mesh.ARRAY_COLOR] != null, " has uv: ", arrays[Mesh.ARRAY_TEX_UV] != null)
		node.free()
	quit()
