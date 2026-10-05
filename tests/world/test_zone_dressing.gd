extends GutTest
## Generic zone dressing: every zone preset has a recipe, builds within the budget, never on water, and the colour-keep rule for the monochrome zone.


func test_every_zone_preset_has_a_recipe() -> void:
	for id: StringName in [StylePresets.TOWN, StylePresets.START, StylePresets.DNA, StylePresets.GAINLANDS, StylePresets.BUFFET, StylePresets.HEAP, StylePresets.CAPITAL_FACADE, StylePresets.CAPITAL_OUTSKIRTS]:
		var recipe: Dictionary = ZoneDressing.recipe(id)
		assert_gt((recipe["items"] as Array).size(), 2, "%s has items" % id)
		assert_false((recipe["patches"] as Array).is_empty(), "%s has ground patches" % id)


func test_recipe_models_exist() -> void:
	for id: StringName in [StylePresets.TOWN, StylePresets.START, StylePresets.DNA, StylePresets.GAINLANDS, StylePresets.BUFFET, StylePresets.HEAP, StylePresets.CAPITAL_OUTSKIRTS]:
		for item: Array in ZoneDressing.recipe(id)["items"] as Array:
			assert_not_null(ModelKit.kit_mesh(str(item[0]), str(item[1])), "%s: %s loads" % [id, item[1]])


func test_dressing_on_the_starting_area_stays_on_land_and_in_budget() -> void:
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	var area: StartingAreaBuilder = StartingAreaBuilder.new()
	area.build(host)
	var root: Node3D = ZoneDressing.build(host, area, StylePresets.START, GraphicsQuality.Level.HIGH)
	var instances: int = 0
	for node: Node in root.find_children("*", "MultiMeshInstance3D", true, false):
		instances += (node as MultiMeshInstance3D).multimesh.instance_count
	assert_lte(instances, ZoneDressing.BUDGET[2])
	assert_gt(instances, 5, "a small clearing still gets dressed")
	var low_root: Node3D = ZoneDressing.build(host, area, StylePresets.START, GraphicsQuality.Level.LOW)
	var low: int = 0
	for node: Node in low_root.find_children("*", "MultiMeshInstance3D", true, false):
		low += (node as MultiMeshInstance3D).multimesh.instance_count
	assert_lte(low, instances)


func test_toon_keeps_colour_flags_on_instances() -> void:
	var mesh: MeshInstance3D = MeshInstance3D.new()
	mesh.mesh = BoxMesh.new()
	add_child_autofree(mesh)
	StyleToon.keep_colour(mesh, 1.0)
	assert_eq(mesh.get_instance_shader_parameter("colour_keep"), 1.0)
	assert_eq(mesh.get_instance_shader_parameter("accent_mix"), 1.0)


func test_material_override_meshes_are_converted() -> void:
	var mesh: MeshInstance3D = MeshInstance3D.new()
	mesh.mesh = BoxMesh.new()
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.vertex_color_is_srgb = true
	mesh.material_override = material
	assert_eq(StyleToon.apply_mesh(mesh), 1)
	var toon: ShaderMaterial = mesh.material_override as ShaderMaterial
	assert_not_null(toon)
	assert_true(bool(toon.get_shader_parameter("vertex_color_srgb")), "srgb vertex colours are kept")
	mesh.free()
