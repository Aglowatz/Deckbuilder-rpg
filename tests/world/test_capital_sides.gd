extends GutTest
## The Capital sides pass (Nov 2, docs/art/capital_rebuild_nov1.md "The sides pass"): inside the great wall nothing grows loose on paving (the
## rows and the lane planters stand on lawn cells or inside a planter), and nothing renders near-black (every surface inside the wall keeps the
## Capital's palette: white, gold, pastel; the broken services are tidy and gilded, never a black bin or bag).

## Linear luminance under which a triangle counts as near-black (sRGB ~0.42: the old bins, bags, dark wood, dark iron all sit far below it).
const DARK: float = 0.10
## Square metres of near-black triangles the whole inside may hold (the cable, the flies, a window frame).
const DARK_BUDGET: float = 0.6
## Pieces that are dark by story and small: the Transit Yards' thick black cable.
const DARK_ALLOWED: Array[String] = ["PowerCable", "TearMesh", "Rift", "Tear", "Orbit"]


func _luminance(c: Color) -> float:
	return 0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b


func _inside(p: Vector3) -> bool:
	return p.x > 1.0 and p.x < 119.0 and p.z > 1.0 and p.z < float(CapitalLayout.WALL_Z0) and p.y < 40.0


func _allowed(node: Node) -> bool:
	var walk: Node = node
	while walk != null:
		if walk.name in DARK_ALLOWED or walk.name.begins_with("Rift_") or walk.name.begins_with("power_cable"):
			return true
		walk = walk.get_parent()
	return false


## Near-black area per 8 m cell inside the wall: {"x,z": area}, plus the names of the meshes holding it.
func _dark_report(root: Node3D) -> Dictionary:
	var cells: Dictionary = {}
	var names: Dictionary = {}
	var shades: Dictionary = {}
	for node: Node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh_node: MeshInstance3D = node as MeshInstance3D
		if mesh_node.mesh == null or not mesh_node.is_inside_tree() or not mesh_node.is_visible_in_tree() or _allowed(mesh_node):
			continue
		var xf: Transform3D = mesh_node.global_transform
		for surface: int in range(mesh_node.mesh.get_surface_count()):
			var material: Material = mesh_node.material_override if mesh_node.material_override != null else mesh_node.mesh.surface_get_material(surface)
			var albedo: Color = Color.WHITE
			var standard: StandardMaterial3D = material as StandardMaterial3D
			if standard != null:
				if standard.emission_enabled or standard.albedo_texture != null:
					continue  # lit, or the kit's painted surface
				albedo = standard.albedo_color
			elif material is ShaderMaterial:
				continue  # the water, the mirror glass, the cards
			var arrays: Array = mesh_node.mesh.surface_get_arrays(surface)
			var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var colors: PackedColorArray = arrays[Mesh.ARRAY_COLOR] if arrays[Mesh.ARRAY_COLOR] != null else PackedColorArray()
			var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX] if arrays[Mesh.ARRAY_INDEX] != null else PackedInt32Array()
			var count: int = indices.size() if indices.size() > 0 else verts.size()
			var tri: int = 0
			while tri + 2 < count:
				var i0: int = indices[tri] if indices.size() > 0 else tri
				var i1: int = indices[tri + 1] if indices.size() > 0 else tri + 1
				var i2: int = indices[tri + 2] if indices.size() > 0 else tri + 2
				tri += 3
				var centre: Vector3 = xf * ((verts[i0] + verts[i1] + verts[i2]) / 3.0)
				if not _inside(centre):
					continue
				var tint: Color = Color.WHITE
				if colors.size() > 0:
					tint = (colors[i0] + colors[i1] + colors[i2]) / 3.0
				var lum: float = _luminance(albedo.srgb_to_linear() * tint)
				if lum >= DARK:
					continue
				var area: float = (xf.basis * (verts[i1] - verts[i0])).cross(xf.basis * (verts[i2] - verts[i0])).length() * 0.5
				var key: String = "%d,%d" % [int(centre.x / 8.0) * 8, int(centre.z / 8.0) * 8]
				cells[key] = float(cells.get(key, 0.0)) + area
				var owner_name: String = _owner_name(mesh_node)
				names[owner_name] = float(names.get(owner_name, 0.0)) + area
				var shade: String = (albedo.srgb_to_linear() * tint).linear_to_srgb().to_html(false)
				var shade_key: String = "%s %s" % [shade, owner_name]
				shades[shade_key] = float(shades.get(shade_key, 0.0)) + area
	return {"cells": cells, "names": names, "shades": shades}


## The first ancestor with a telling name (not the generic Body / Detail / Batch / KitMesh / anonymous nodes).
func _owner_name(node: Node) -> String:
	var walk: Node = node
	while walk != null:
		var n: String = walk.name
		if not (n.begins_with("Body") or n.begins_with("Detail") or n.begins_with("@") or n.begins_with("KitMesh") or n == "Capital" or n.begins_with("Node3D")):
			return n
		walk = walk.get_parent()
	return node.name


func test_nothing_inside_the_wall_renders_near_black() -> void:
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	var builder: CapitalBuilder = CapitalBuilder.new()
	builder.build(host)
	var report: Dictionary = _dark_report(builder.root)
	var total: float = 0.0
	var lines: Array[String] = []
	var cells: Dictionary = report["cells"] as Dictionary
	for key: Variant in cells.keys():
		total += float(cells[key])
		if float(cells[key]) > 0.05:
			lines.append("cell %s: %.2f m2" % [str(key), float(cells[key])])
	lines.sort()
	gut.p("near-black inside the wall: %.2f m2 in %d cells\n  %s" % [total, cells.size(), "\n  ".join(lines)])
	var by_name: Array[String] = []
	var names: Dictionary = report["names"] as Dictionary
	for key: Variant in names.keys():
		if float(names[key]) > 0.05:
			by_name.append("%s: %.2f" % [str(key), float(names[key])])
	by_name.sort()
	gut.p("by mesh: %s" % ", ".join(by_name))
	var by_shade: Array[String] = []
	var shades: Dictionary = report["shades"] as Dictionary
	for key: Variant in shades.keys():
		if float(shades[key]) > 0.3:
			by_shade.append("%6.2f %s" % [float(shades[key]), str(key)])
	by_shade.sort()
	by_shade.reverse()
	gut.p("by shade: 
  %s" % "
  ".join(by_shade))
	assert_lt(total, DARK_BUDGET, "no near-black surface inside the wall (bins, bags, crates, dark wood or iron): %.2f m2" % total)


func test_nothing_grows_loose_on_paving_inside_the_wall() -> void:
	var layout: CapitalLayout = CapitalLayout.new()
	layout.build()
	var builder: CapitalBuilder = CapitalBuilder.new()
	builder.layout = layout
	builder._index_obstacles()
	builder.gate_open = true
	var parent: Node3D = Node3D.new()
	add_child_autofree(parent)
	var keep: Array[Vector3] = []
	for key: Variant in layout.anchors.keys():
		keep.append(layout.anchors[key] as Vector3)
	var dressing: CapitalDressing = CapitalDressing.build(parent, builder, keep)
	gut.p("rows refused: %s; planters %d; fields %s" % [str(dressing.refused), dressing.planters.size(), str(dressing.fields.keys())])
	var loose: Array[String] = dressing.loose_on_paving()
	assert_eq(loose, [] as Array[String], "every plant inside the wall stands on a lawn or in a planter")
	assert_gt(dressing.planters.size(), 20, "the lanes and the separators are lined with planters (%d)" % dressing.planters.size())
	assert_gt((dressing.garden_fields.get("cap_topiary", []) as Array).size(), 20, "topiary cones in gold urns along the planters")
	assert_gt(dressing.count("cap_lamp"), 1, "the lamps still line the district streets")
