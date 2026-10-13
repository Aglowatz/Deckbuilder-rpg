class_name KitBatch
extends RefCounted
## Static batching for the kit (performance): every small prop (a MeshInstance3D flagged with the meta `kit_static`, set by `PropKit`) under `root` is merged, by material and
## 16 m ground cell, into a few big meshes with the transforms baked in, and the original nodes are removed. A town of two hundred barrels, crates, pots and planters is then a
## few dozen draw calls instead of several hundred (the iGPU is bound by draw calls). Frustum culling stays per cell. Merged meshes cast no shadow (they are small; the
## contact pools ground them). Call once, after the whole town is placed and before the style rig converts the meshes.

const CELL: float = 16.0


## Returns how many source meshes were merged away.
static func merge_static(root: Node) -> int:
	var groups: Dictionary = {}
	var victims: Array[MeshInstance3D] = []
	for node: Node in root.find_children("*", "MeshInstance3D", true, false):
		var source: MeshInstance3D = node as MeshInstance3D
		if source == null or source.mesh == null or not source.has_meta(&"kit_static") or not source.is_inside_tree():
			continue
		var xform: Transform3D = source.global_transform
		var cell: Vector2i = Vector2i(floori(xform.origin.x / CELL), floori(xform.origin.z / CELL))
		for surface: int in range(source.mesh.get_surface_count()):
			var material_value: Material = source.mesh.surface_get_material(surface)
			if material_value == null:
				continue
			var key: String = "%d|%d|%d" % [material_value.get_instance_id(), cell.x, cell.y]
			if not groups.has(key):
				var tool: SurfaceTool = SurfaceTool.new()
				tool.begin(Mesh.PRIMITIVE_TRIANGLES)
				groups[key] = {"material": material_value, "tool": tool, "cell": cell}
			((groups[key] as Dictionary)["tool"] as SurfaceTool).append_from(source.mesh, surface, xform)
		victims.append(source)
	if groups.is_empty():
		return 0
	var holder: Node3D = Node3D.new()
	holder.name = "KitBatches"
	root.add_child(holder)
	for key: String in groups.keys():
		var data: Dictionary = groups[key] as Dictionary
		var tool: SurfaceTool = data["tool"] as SurfaceTool
		var mesh: ArrayMesh = tool.commit()
		mesh.surface_set_material(0, data["material"] as Material)
		var instance: MeshInstance3D = MeshInstance3D.new()
		instance.name = "Batch_%s" % key.replace("|", "_")
		instance.mesh = mesh
		instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		instance.set_meta("no_occlusion_fade", true)
		instance.set_meta(PaintedClasses.META_NO_PAINT, true)
		holder.add_child(instance)
	for victim: MeshInstance3D in victims:
		victim.get_parent().remove_child(victim)
		victim.free()
	return victims.size()
