extends GutTest
## Fable Nov 12c (A6): the Capital's floating grey rectangles were the rim's painted cards (dead trees, rubble) come back from the build
## cache with no material. They keep their materials now, and the ridges carry ruined-wasteland dressing that stands on the ground.

var layout: CapitalLayout
var holder: Node3D
var rim: CapitalRim
var ruins: CapitalRimRuins


func before_all() -> void:
	layout = CapitalLayout.new()
	layout.build()
	holder = Node3D.new()
	add_child(holder)
	# built twice: the second build takes the rim's meshes from BuildCache, which is how every visit after the first runs
	var first: Node3D = Node3D.new()
	holder.add_child(first)
	CapitalRim.build(first, layout)
	rim = CapitalRim.build(holder, layout)
	ruins = CapitalRimRuins.build(holder, rim)


func after_all() -> void:
	holder.free()


func test_every_surface_of_the_cached_rim_dressing_has_its_material() -> void:
	var dressing: MeshInstance3D = holder.get_node("Rim/RimDressing") as MeshInstance3D
	assert_not_null(dressing)
	assert_gt(dressing.mesh.get_surface_count(), 4, "rocks, the road and several painted cards")
	var textured: int = 0
	for surface: int in range(dressing.mesh.get_surface_count()):
		var material: Material = dressing.get_active_material(surface)
		assert_not_null(material, "surface %d has a material (a card with none draws as a flat grey rectangle)" % surface)
		if material is BaseMaterial3D and (material as BaseMaterial3D).albedo_texture != null:
			textured += 1
		elif material is ShaderMaterial:
			textured += 1
	assert_gt(textured, 2, "the dead tree and the rubble cards carry their paintings")


func test_resolve_missing_reports_what_it_could_not_fill() -> void:
	var mesh: KitMesh = KitMesh.new()
	mesh.restore({"order": ["card_CAP-TREE-DEAD", "no_such_slot"], "arrays": {}, "triangles": 0})
	var missing: Array[String] = mesh.resolve_missing(CapitalKit.resolve_slot)
	assert_eq(missing, ["no_such_slot"] as Array[String])
	assert_not_null(mesh.material_of("card_CAP-TREE-DEAD"))


func test_the_ridges_carry_the_ruined_kingdom() -> void:
	assert_between(ruins.houses.size(), 4, CapitalRimRuins.MAX_HOUSES, "dilapidated house shells")
	assert_between(ruins.fragments.size(), 3, CapitalRimRuins.MAX_FRAGMENTS, "stretches of ash wall")
	assert_between(ruins.statues.size(), 2, CapitalRimRuins.MAX_STATUES, "toppled statues")
	assert_between(ruins.crystals.size(), 5, CapitalRimRuins.MAX_CRYSTALS, "crystal growths")
	assert_between(ruins.mounds.size(), 6, CapitalRimRuins.MAX_MOUNDS, "rubble mounds")
	for spot: Vector3 in ruins.all_spots():
		assert_gte(spot.z, CapitalRimRuins.MIN_Z, "only where the outside can see it: none beside the city's side walls (frames for nothing)")


func test_every_piece_stands_on_rim_ground_off_the_walkable_map() -> void:
	for spot: Vector3 in ruins.all_spots():
		var cx: int = int(floorf(spot.x))
		var cz: int = int(floorf(spot.z))
		var distance: float = rim.distance_at(cx, cz)
		assert_true(distance >= 2.0 and distance != INF, "(%.0f, %.0f) is on the rim, 2 m or more from walkable ground" % [spot.x, spot.z])
		assert_ne(layout.cell_at(cx, cz), CapitalLayout.Cell.GROUND, "(%.0f, %.0f) is not walkable ground" % [spot.x, spot.z])
		assert_false(CapitalRim._in_city(cx, cz), "not inside the city")
		var ground: float = CapitalRimRuins.ground_at(rim, spot.x, spot.z)
		assert_lte(spot.y, ground + 0.001, "(%.0f, %.0f): the base is at or under the ground, never floating" % [spot.x, spot.z])
		assert_gt(spot.y, ground - 0.6, "and not buried")


func test_nothing_rises_between_the_camera_and_the_hero() -> void:
	var lowest: float = INF
	for shape: Array in CapitalRimRuins.HOUSE_SHAPES:
		lowest = minf(lowest, float(shape[1]) + float(shape[2]) * 0.4)
	for spot: Vector3 in ruins.houses:
		assert_gte(rim.north_cap(int(floorf(spot.x)), int(floorf(spot.z))), lowest, "a house only where the rim's rule leaves it room")


func test_houses_keep_their_distance() -> void:
	for a: int in range(ruins.houses.size()):
		for b: int in range(a + 1, ruins.houses.size()):
			assert_gte(Vector2(ruins.houses[a].x - ruins.houses[b].x, ruins.houses[a].z - ruins.houses[b].z).length(), CapitalRimRuins.HOUSE_SPACING)


func test_low_end_keeps_about_half() -> void:
	var other: Node3D = Node3D.new()
	holder.add_child(other)
	var half: CapitalRimRuins = CapitalRimRuins.build(other, rim, 0.5)
	assert_lte(half.houses.size(), CapitalRimRuins.MAX_HOUSES / 2)
	assert_lt(half.all_spots().size(), ruins.all_spots().size())
