extends GutTest
## Vertical slice, Part D: light and atmosphere. One warm sun, baked-look occlusion, lantern lights under the budget, the per-area grade as data.


func test_the_town_sun_is_low_warm_and_from_the_back_right() -> void:
	var preset: ZonePreset = StylePresets.get_preset(StylePresets.TOWN)
	assert_lt(preset.sun_pitch, -15.0, "a low sun")
	assert_gt(preset.sun_pitch, -40.0, "not overhead")
	assert_gt(preset.sun_color.r, preset.sun_color.b, "warm")
	var travel: Vector3 = Basis.from_euler(Vector3(deg_to_rad(preset.sun_pitch), deg_to_rad(preset.sun_yaw), 0.0)) * Vector3(0, 0, -1)
	assert_lt(travel.x, -0.5, "the light travels to the left of the screen: shadows fall left")
	assert_lt(travel.y, 0.0)


func test_grade_is_per_area_data() -> void:
	var town: Dictionary = WorldLookRig.values_for(WorldLookRig.mood_for(&"town"))
	assert_gt(float(town.get("green_calm", 0.0)), 0.2, "the town calms its greens")
	assert_gt(float(town.get("red_calm", 0.0)), 0.1, "and its reds")
	for id: StringName in [&"start", &"dna", &"gainlands", &"buffet", &"heap"]:
		var values: Dictionary = WorldLookRig.values_for(WorldLookRig.mood_for(id))
		assert_eq(float(values.get("green_calm", 0.0)), 0.0, "%s keeps its own palette" % id)


func test_no_area_switches_light_shafts_on_by_default() -> void:
	var moods: Dictionary = WorldLookRig.all_moods()
	# the shaft strips were tried in the town (VS-11) and read as flat translucent polygons close up: the feature stays, off
	for id: Variant in moods.keys():
		if false:
			continue
		var mood: Dictionary = WorldLookRig.mood_for(StringName(str(id)))
		assert_false(bool((mood.get("ambient", {}) as Dictionary).get("shafts", false)), "%s has no shafts" % str(id))


func test_buildings_darken_at_the_base_and_under_the_eaves() -> void:
	var building: Node3D = BuildingPresets.build("home_a")
	add_child_autofree(building)
	var mesh: ArrayMesh = (building.get_node("Body") as MeshInstance3D).mesh as ArrayMesh
	var darkest: float = 1.0
	var brightest: float = 0.0
	for surface: int in range(mesh.get_surface_count()):
		var arrays: Array = mesh.surface_get_arrays(surface)
		for color: Color in arrays[Mesh.ARRAY_COLOR] as PackedColorArray:
			darkest = minf(darkest, color.r)
			brightest = maxf(brightest, color.r)
	assert_lt(darkest, 0.6, "baked occlusion at the foot of the walls and under the roof")
	assert_gte(brightest, 0.99)


func test_ao_pools_exist_for_buildings_and_props() -> void:
	var holder: Node3D = Node3D.new()
	add_child_autofree(holder)
	var footprint: MeshInstance3D = KitAO.footprint(holder, Vector3(3, 0, 3), Vector2(6, 5), 20.0)
	var blob: MeshInstance3D = KitAO.blob(holder, Vector3(1, 0, 1), 0.5)
	assert_true(footprint.material_override is ShaderMaterial)
	assert_true(blob.material_override is ShaderMaterial)
	assert_eq(footprint.cast_shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)
	var cluster: Node3D = PropClusters.make("crates", 0, true)
	add_child_autofree(cluster)
	var pools: int = 0
	for child: Node in cluster.get_children():
		var instance: MeshInstance3D = child as MeshInstance3D
		if instance != null and instance.mesh is QuadMesh:
			pools += 1
	assert_gt(pools, 2, "every solid prop of a cluster has its contact pool")


func test_lit_windows_get_light_pools() -> void:
	var building: Node3D = BuildingPresets.build("inn")
	add_child_autofree(building)
	assert_gt((building.get_meta("glows") as Array).size(), 1, "pools of light in front of the ground-floor windows")
	assert_gt((building.get_meta("lights") as Array).size(), 0, "the door lantern is a real light")


func test_lantern_lights_follow_the_budget() -> void:
	assert_lte(GraphicsQuality.light_budget(GraphicsQuality.Level.MEDIUM), 12)
	assert_gte(GraphicsQuality.light_budget(GraphicsQuality.Level.MEDIUM), 6)
