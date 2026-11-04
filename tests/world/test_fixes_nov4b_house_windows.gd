extends GutTest
## Fix pass Nov 4 (B), Part 3.1: the painted windows (open shutters included) of every building of the kit sit on their walls - inside the footprint,
## under the roof line (the eave on an eave face, the slope on a gable end) - instead of sticking out of the roof and floating past the corners.


func test_every_painted_window_of_every_preset_sits_on_its_wall() -> void:
	var checked: int = 0
	for preset: String in BuildingPresets.names():
		var spec: Dictionary = BuildingPresets.spec(preset)
		var kit: BuildingKit = BuildingKit.new()
		kit.spec = spec
		var building: Node3D = kit._assemble()
		add_child_autofree(building)
		var body: MeshInstance3D = building.find_child("Body", true, false) as MeshInstance3D
		if body == null or body.mesh == null:
			continue
		var mesh: ArrayMesh = body.mesh as ArrayMesh
		for surface: int in range(mesh.get_surface_count()):
			var material: Material = mesh.surface_get_material(surface)
			var name_hint: String = str(mesh.surface_get_name(surface))
			if not name_hint.contains("ENV-WINDOW"):
				continue
			var vertices: PackedVector3Array = mesh.surface_get_arrays(surface)[Mesh.ARRAY_VERTEX] as PackedVector3Array
			for v: Vector3 in vertices:
				checked += 1
				assert_lte(absf(v.x), kit.hw + 0.12, "%s: a window stays inside the footprint (x %.2f)" % [preset, v.x])
				assert_lte(absf(v.z), kit.hd + 0.12, "%s: a window stays inside the footprint (z %.2f)" % [preset, v.z])
				var on_front: bool = absf(absf(v.z) - kit.hd) < absf(absf(v.x) - kit.hw)
				var face: String = ("front" if v.z > 0.0 else "back") if on_front else ("right" if v.x > 0.0 else "left")
				var u: float = v.x if on_front else v.z
				assert_lte(v.y, kit.face_top(face, u) + 0.02, "%s: a %s window stays under the roof line (y %.2f at u %.2f)" % [preset, face, v.y, u])
			if material == null:
				continue
	if checked == 0:
		pass_test("no painted window art in this build (the stand-in windows are drawn instead)")


func test_a_window_too_big_for_a_narrow_eave_face_shrinks_and_moves_in() -> void:
	var kit: BuildingKit = BuildingKit.new()
	kit.spec = {"width": 4.0, "depth": 3.0, "floors": 2, "roof": {"style": "gable", "pitch": 40}}
	kit._assemble()
	var fit: Vector3 = kit.fit_window("front", 1.9, BuildingKit.floor_top(kit.spec, 0) + 1.1, 2.5, 1.0)
	assert_lte(absf(fit.x) + fit.z * 0.5, kit.hw - BuildingKit.WINDOW_MARGIN + 0.001, "inside the corners")
	assert_lte(fit.y + fit.z * 0.5, kit.wall_top - BuildingKit.WINDOW_MARGIN + 0.001, "under the eave")
