class_name PlanView
extends RefCounted
## Crosspath pass, Part A: a top-down audit view of a walkable area for screenshots (`tools/shot.sh res://scenes/town.tscn <name>
## --top=<x>,<z>,<size> [--plan=true]`). An orthographic camera looks straight down at (x, z) covering `size` metres; with `--plan` the
## ground the hero can stand on is tinted green, every blocking circle is a red disc and every anchor a yellow dot. Debug only.


static func install(scene: Node3D, area: WalkableArea, obstacles: Array[Vector3], anchors: Dictionary, spec: String, overlay: bool) -> Camera3D:
	var parts: PackedStringArray = spec.split(",")
	var centre: Vector3 = Vector3(float(parts[0]), 0.0, float(parts[1])) if parts.size() >= 2 else Vector3.ZERO
	var size: float = float(parts[2]) if parts.size() >= 3 else 120.0
	var camera: Camera3D = Camera3D.new()
	camera.name = "PlanCamera"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = size
	camera.far = 400.0
	scene.add_child(camera)
	camera.global_transform = Transform3D(Basis(Vector3.RIGHT, -PI * 0.5), centre + Vector3(0.0, 150.0, 0.0))
	camera.current = true
	if overlay:
		_overlay(scene, area, obstacles, anchors, centre, size)
	return camera


static func _overlay(scene: Node3D, area: WalkableArea, obstacles: Array[Vector3], anchors: Dictionary, centre: Vector3, size: float) -> void:
	var step: float = 0.6
	var half: float = size * 0.5
	var walk: SurfaceTool = SurfaceTool.new()
	walk.begin(Mesh.PRIMITIVE_TRIANGLES)
	var x: float = centre.x - half
	while x < centre.x + half:
		var z: float = centre.z - half * 0.6
		while z < centre.z + half * 0.6:
			if area.is_walkable(Vector3(x, 0.0, z), 0.3):
				for v: Vector3 in [Vector3(x, 0, z), Vector3(x + step, 0, z), Vector3(x + step, 0, z + step), Vector3(x, 0, z), Vector3(x + step, 0, z + step), Vector3(x, 0, z + step)]:
					walk.add_vertex(v + Vector3(0.0, 6.0, 0.0))
			z += step
		x += step
	_add(scene, walk.commit(), Color(0.1, 1.0, 0.2, 0.28))
	var red: SurfaceTool = SurfaceTool.new()
	red.begin(Mesh.PRIMITIVE_TRIANGLES)
	for circle: Vector3 in obstacles:
		if absf(circle.x - centre.x) > half + 4.0 or absf(circle.y - centre.z) > half + 4.0:
			continue
		for s: int in range(12):
			var a0: float = TAU * float(s) / 12.0
			var a1: float = TAU * float(s + 1) / 12.0
			red.add_vertex(Vector3(circle.x, 6.1, circle.y))
			red.add_vertex(Vector3(circle.x + cos(a1) * circle.z, 6.1, circle.y + sin(a1) * circle.z))
			red.add_vertex(Vector3(circle.x + cos(a0) * circle.z, 6.1, circle.y + sin(a0) * circle.z))
	_add(scene, red.commit(), Color(1.0, 0.1, 0.1, 0.5))
	var dots: SurfaceTool = SurfaceTool.new()
	dots.begin(Mesh.PRIMITIVE_TRIANGLES)
	for key: Variant in anchors.keys():
		var p: Vector3 = anchors[key] as Vector3
		for s: int in range(8):
			var a0: float = TAU * float(s) / 8.0
			var a1: float = TAU * float(s + 1) / 8.0
			dots.add_vertex(Vector3(p.x, 6.2, p.z))
			dots.add_vertex(Vector3(p.x + cos(a1) * 0.45, 6.2, p.z + sin(a1) * 0.45))
			dots.add_vertex(Vector3(p.x + cos(a0) * 0.45, 6.2, p.z + sin(a0) * 0.45))
	_add(scene, dots.commit(), Color(1.0, 0.9, 0.1, 0.95))
	# Labels for the anchors (debug view only: never in the game world).
	for key: Variant in anchors.keys():
		var name_text: String = str(key)
		if name_text.begins_with("signpost") or name_text.begins_with("hidden_chest"):
			continue
		var label: Label3D = Label3D.new()
		label.text = name_text
		label.font_size = 28
		label.pixel_size = size / 2400.0
		label.billboard = BaseMaterial3D.BILLBOARD_DISABLED
		label.rotation = Vector3(-PI * 0.5, 0.0, 0.0)
		label.position = (anchors[key] as Vector3) + Vector3(0.0, 6.4, -0.8)
		label.modulate = Color(1, 1, 1)
		label.outline_size = 6
		label.set_meta(&"no_occlusion_fade", true)
		scene.add_child(label)


## Every mesh under `root` that moves in the wind (a toon material with `wind_amount` above 0, or a painted card with `sway` above 0), as
## "path @ position" lines: the audit of what sways (Part B wants only plants and cloth to).
static func swaying(root: Node) -> PackedStringArray:
	var lines: PackedStringArray = []
	for node: Node in root.find_children("*", "GeometryInstance3D", true, false):
		var geometry: GeometryInstance3D = node as GeometryInstance3D
		var materials: Array[Material] = [geometry.material_override]
		if geometry is MeshInstance3D and (geometry as MeshInstance3D).mesh != null:
			for surface: int in range((geometry as MeshInstance3D).mesh.get_surface_count()):
				materials.append((geometry as MeshInstance3D).get_active_material(surface))
		for material: Material in materials:
			if material is ShaderMaterial:
				var shader_material: ShaderMaterial = material as ShaderMaterial
				var wind: Variant = shader_material.get_shader_parameter("wind_amount")
				var sway: Variant = shader_material.get_shader_parameter("sway")
				if (wind != null and float(wind) > 0.0) or (sway != null and float(sway) > 0.0):
					lines.append("%s @ %s wind=%s sway=%s" % [str(root.get_path_to(geometry)), str(geometry.global_position.snapped(Vector3.ONE * 0.1)), str(wind), str(sway)])
					break
	return lines


static func _add(scene: Node3D, mesh: Mesh, color: Color) -> void:
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = mesh
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	instance.material_override = material
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.set_meta(StyleToon.META_NO_TOON, true)
	instance.set_meta(&"no_occlusion_fade", true)
	instance.set_meta(&"no_range_cull", true)
	scene.add_child(instance)
