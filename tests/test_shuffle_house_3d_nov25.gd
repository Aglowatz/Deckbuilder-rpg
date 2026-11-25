extends GutTest
## Fable Nov 25, Part 3 (the owner's item 14): the Shuffle House is a real 3D building with painted textures, built to
## SH-CONCEPT - a two-storey half-timbered body on a stone foundation, three steps to the door, a big-top roof with volume,
## two turrets with flags, a cobbled apron with flower beds, a card weathervane, marquee bulbs - and the flat painted card is gone.

func _build() -> Node3D:
	var root: Node3D = Node3D.new()
	add_child_autofree(root)
	var obstacles: Array[Vector3] = []
	var holder: Node3D = TownShuffleHouse.build(root, obstacles)
	holder.set_meta(&"obstacles", obstacles)
	return holder


func _part(holder: Node3D, path: String) -> MeshInstance3D:
	return holder.get_node_or_null("Building/%s" % path) as MeshInstance3D


func test_the_four_textures_are_in_the_game() -> void:
	for id: String in [TownShuffleHouse.TEX_FRONT, TownShuffleHouse.TEX_SIDE, TownShuffleHouse.TEX_ROOF, TownShuffleHouse.TEX_TRIM]:
		assert_true(ResourceLoader.exists(TownShuffleHouse.TEXTURES % id), id)
		assert_not_null(TownShuffleHouse.textured(id).albedo_texture, "%s is on a material" % id)
	assert_eq(TownShuffleHouse.textured(TownShuffleHouse.TEX_TRIM, true).transparency, BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR, "the valance is a cut-out")
	# lit like the other houses' walls: an ordinary lit material, never unshaded
	assert_eq(TownShuffleHouse.textured(TownShuffleHouse.TEX_FRONT).shading_mode, BaseMaterial3D.SHADING_MODE_PER_PIXEL)


func test_every_part_of_the_concept_is_built() -> void:
	var holder: Node3D = _build()
	for part: String in ["ContactShadow", "Apron", "Foundation", "Steps", "FrontWall", "SideWalls", "CornerPosts", "BigTop", "Soffit", "Cap",
			"Valance", "EaveRail", "Turret1/Drum", "Turret1/Cone", "Turret1/Flag", "Turret2/Drum", "Turret2/Cone", "Turret2/Flag",
			"Weathervane/Arrow", "Weathervane/Card", "Weathervane/Pennant", "MarqueeBulbs", "FlowerBed1", "FlowerBed4"]:
		assert_not_null(holder.get_node_or_null("Building/%s" % part), "the house has its %s" % part)
	assert_true(bool(holder.get_meta(&"textured")), "the painted textures are on it")
	# the right texture on each part
	assert_eq(_part(holder, "FrontWall").material_override, TownShuffleHouse.textured(TownShuffleHouse.TEX_FRONT))
	assert_eq(_part(holder, "SideWalls").material_override, TownShuffleHouse.textured(TownShuffleHouse.TEX_SIDE))
	assert_eq(_part(holder, "BigTop").material_override, TownShuffleHouse.textured(TownShuffleHouse.TEX_ROOF))
	assert_eq(_part(holder, "Turret1/Cone").material_override, TownShuffleHouse.textured(TownShuffleHouse.TEX_ROOF))
	assert_eq(_part(holder, "Valance").material_override, TownShuffleHouse.textured(TownShuffleHouse.TEX_TRIM, true))


func test_the_old_flat_card_is_gone() -> void:
	var holder: Node3D = _build()
	for node: Node in holder.find_children("*", "", true, false):
		assert_false(str(node.name).begins_with("Kit_TOWN-HERO"), "no painted card stands in the house")
	assert_false(ResourceLoader.exists("res://assets/art/zone_kits/town/TOWN-HERO-SHUFFLEHOUSE.webp"), "the card's picture left the game")
	assert_false(EnvKit.has("TOWN-HERO-SHUFFLEHOUSE"), "and the town kit no longer lists it")
	assert_false(FileAccess.get_file_as_string("res://world/town_shuffle_house.gd").contains("KitPieces.stand("), "the builder stands no card up")


func test_the_body_has_depth_sides_and_two_storeys() -> void:
	var holder: Node3D = _build()
	var front: AABB = _part(holder, "FrontWall").mesh.get_aabb()
	assert_almost_eq(front.size.x, TownShuffleHouse.WIDTH, 0.01)
	assert_almost_eq(front.size.y, TownShuffleHouse.WALL_HEIGHT, 0.01, "two storeys")
	assert_almost_eq(front.size.x / front.size.y, 1.5, 0.01, "the front texture (3:2) is not stretched")
	assert_almost_eq(front.position.y, TownShuffleHouse.FOUNDATION, 0.01, "the walls stand on the foundation")
	var sides: AABB = _part(holder, "SideWalls").mesh.get_aabb()
	assert_almost_eq(sides.size.z, TownShuffleHouse.DEPTH, 0.01, "real depth behind the front")
	assert_gte(sides.size.z, 5.0)
	var foundation: AABB = _part(holder, "Foundation").mesh.get_aabb()
	assert_almost_eq(foundation.position.y, 0.0, 0.001, "the foundation stands on the ground")
	assert_gt(foundation.size.x, front.size.x, "and is a little wider than the walls")
	# three steps, each lower and further out, the top one at the door's sill
	var steps: AABB = _part(holder, "Steps").mesh.get_aabb()
	assert_almost_eq(steps.end.y, TownShuffleHouse.FOUNDATION, 0.01)
	assert_almost_eq(steps.end.z, TownShuffleHouse.steps_front(), 0.01)
	assert_gt(steps.size.x, TownShuffleHouse.STEP_WIDTH + 1.5, "the lowest step is the widest")
	# everything solid casts a shadow; the ground pieces do not
	assert_eq(_part(holder, "FrontWall").cast_shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_ON)
	assert_eq(_part(holder, "BigTop").cast_shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_ON)
	assert_eq(_part(holder, "ContactShadow").cast_shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)
	assert_eq(_part(holder, "Apron").cast_shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)


func test_the_big_top_has_volume_and_overhangs_the_walls() -> void:
	var holder: Node3D = _build()
	var top: AABB = _part(holder, "BigTop").mesh.get_aabb()
	assert_almost_eq(top.size.y, TownShuffleHouse.ROOF_RISE, 0.05, "the tent rises from the eave to the cap")
	assert_gt(top.size.x, TownShuffleHouse.WIDTH + 0.8, "it overhangs the walls")
	assert_gt(top.size.z, TownShuffleHouse.DEPTH + 0.8)
	assert_almost_eq(top.position.y, TownShuffleHouse.eave_height(), 0.01)
	# the canvas sags: half-way in from the eave it has climbed well under half of the rise
	var eave: Vector2 = Vector2(0.0, TownShuffleHouse.eave_rect().end.y)
	var half_way: Vector3 = TownShuffleHouse.roof_point(eave, 0.5)
	assert_lt(half_way.y - TownShuffleHouse.eave_height(), TownShuffleHouse.ROOF_RISE * 0.4)
	# the valance hangs along all four eaves, the scallops whole on each side
	var valance: AABB = _part(holder, "Valance").mesh.get_aabb()
	assert_almost_eq(valance.size.x, top.size.x, 0.05)
	assert_almost_eq(valance.size.z, top.size.z, 0.05)
	assert_almost_eq(valance.size.y, TownShuffleHouse.TRIM_HEIGHT, 0.01)
	# two turrets above the eave, each with a flag above its cone; the weathervane is the highest thing
	for index: int in [1, 2]:
		var cone: AABB = _part(holder, "Turret%d/Cone" % index).mesh.get_aabb()
		assert_gt(cone.position.y, TownShuffleHouse.eave_height() + 1.5)
		assert_gt(_part(holder, "Turret%d/Flag" % index).mesh.get_aabb().position.y, cone.end.y - 0.1, "the flag flies over the cone")
	var card: AABB = _part(holder, "Weathervane/Card").mesh.get_aabb()
	assert_gt(card.position.y, TownShuffleHouse.eave_height() + TownShuffleHouse.ROOF_RISE, "the card stands over the peak")
	assert_lte(_part(holder, "Weathervane/Pennant").mesh.get_aabb().end.y, TownShuffleHouse.HEIGHT + 0.01)
	assert_gt(TownShuffleHouse.HEIGHT, 12.0, "as tall as it was: seen over the shop roofs from the square")


func test_the_marquee_bulbs_glow_and_twinkle() -> void:
	var holder: Node3D = _build()
	var bulbs: MultiMeshInstance3D = holder.get_node("Building/MarqueeBulbs") as MultiMeshInstance3D
	var points: Array[Vector3] = TownShuffleHouse.bulb_points()
	assert_eq(bulbs.multimesh.instance_count, points.size())
	assert_gt(points.size(), 80, "a marquee's worth of bulbs")
	assert_lt(points.size(), 200, "and one draw call's worth")
	var material: ShaderMaterial = bulbs.material_override as ShaderMaterial
	assert_not_null(material)
	var code: String = material.shader.code
	assert_true(code.contains("unshaded") and code.contains("TIME"), "they shine by themselves and twinkle")
	assert_lte(float(material.shader.get_shader_uniform_list().size()), 3.0)
	# two bulbs on every scallop of the front valance, on the eave line
	var front: int = 0
	for point: Vector3 in points:
		if absf(point.z - (TownShuffleHouse.eave_rect().end.y + 0.05)) < 0.01:
			front += 1
			assert_between(point.y, TownShuffleHouse.eave_height() - 0.2, TownShuffleHouse.eave_height() + 0.2)
	assert_eq(front, TownShuffleHouse.scallops_for(TownShuffleHouse.eave_rect().size.x) * 2)


func test_the_door_the_host_and_the_apron_agree_with_the_model() -> void:
	var holder: Node3D = _build()
	var obstacles: Array[Vector3] = holder.get_meta(&"obstacles") as Array[Vector3]
	var door: Vector3 = TownShuffleHouse.door_spot()
	# the hero stands at the foot of the steps, in front of the door, on the apron
	assert_gt(door.z - TownShuffleHouse.CENTER.z, TownShuffleHouse.steps_front() + 0.3, "the door spot is clear of the lowest step")
	assert_lt(door.z - TownShuffleHouse.CENTER.z, TownShuffleHouse.steps_front() + 1.2, "and right in front of it")
	assert_almost_eq(door.x, TownShuffleHouse.CENTER.x, 0.01)
	for spot: Vector3 in [door, TownShuffleHouse.host_spot()]:
		var from_apron: Vector3 = spot - TownShuffleHouse.CENTER - TownShuffleHouse.APRON_CENTER
		assert_lt(pow(from_apron.x / TownShuffleHouse.APRON_RADII.x, 2.0) + pow(from_apron.z / TownShuffleHouse.APRON_RADII.y, 2.0), 1.0, "on the cobbled apron")
		for circle: Vector3 in obstacles:
			assert_gt(Vector2(circle.x, circle.y).distance_to(Vector2(spot.x, spot.z)), circle.z + 0.3, "free of the house's circles")
	# Octavia stands beside the steps, not on them and not in a flower bed
	var host: Vector3 = TownShuffleHouse.host_spot() - TownShuffleHouse.CENTER
	assert_gt(absf(host.x), TownShuffleHouse.STEP_WIDTH * 0.5 + TownShuffleHouse.STEP_GROW * 2.0, "beside the steps")
	for bed: Vector4 in TownShuffleHouse.BEDS:
		assert_gt(Vector2(host.x - bed.x, host.z - bed.y).length(), 1.2, "clear of a flower bed")
