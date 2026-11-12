extends GutTest
## Fable Nov 12c (Part C, item 1): characters get a clearly visible ground shadow (darker on Medium than on Low), and every prop standing
## on the ground gets a soft darkening at its base (`PropShade`), never the things that hang, fly or lie flat.


func after_each() -> void:
	ContactShadow.apply_quality(1)


func _box(parent: Node3D, node_name: String, size: Vector3, pos: Vector3) -> MeshInstance3D:
	var holder: Node3D = Node3D.new()
	holder.name = node_name
	parent.add_child(holder)
	var mesh: MeshInstance3D = MeshInstance3D.new()
	mesh.name = "Body"
	var box: BoxMesh = BoxMesh.new()
	box.size = size
	mesh.mesh = box
	mesh.position = pos + Vector3(0.0, size.y * 0.5, 0.0)
	holder.add_child(mesh)
	return mesh


func test_the_blob_is_darker_than_it_was_and_darker_on_medium_than_on_low() -> void:
	assert_gt(ContactShadow.alpha_for(0), 0.45, "Low: clearly visible (it was 0.42 everywhere and read as faint)")
	assert_gt(ContactShadow.alpha_for(1), ContactShadow.alpha_for(0), "darker on Medium")
	assert_eq(ContactShadow.alpha_for(2), ContactShadow.alpha_for(1))
	ContactShadow.apply_quality(0)
	var holder: Node3D = Node3D.new()
	add_child_autofree(holder)
	var blob: MeshInstance3D = ContactShadow.attach(holder, 0.5)
	var material: StandardMaterial3D = (blob.mesh as QuadMesh).material as StandardMaterial3D
	assert_almost_eq(material.albedo_color.a, ContactShadow.alpha_for(0), 0.001)
	ContactShadow.apply_quality(1)
	assert_almost_eq(material.albedo_color.a, ContactShadow.alpha_for(1), 0.001, "one shared material: the setting reaches every blob")
	assert_gt(material.albedo_color.b, material.albedo_color.r, "tinted violet, never pure black")
	assert_gt(blob.scale.x, blob.scale.z, "a little wider than deep")
	assert_gt(ContactShadow.SPRITE_RADIUS, 0.3, "sized to the sprite, a little bigger than before")


func test_props_on_the_ground_get_a_base_shade() -> void:
	var root: Node3D = Node3D.new()
	add_child_autofree(root)
	_box(root, "crate_stack", Vector3(1.0, 0.9, 1.2), Vector3(4.0, 0.0, 2.0))
	_box(root, "barrel", Vector3(0.8, 1.0, 0.8), Vector3(-3.0, -0.05, 1.0))
	_box(root, "hanging_lantern", Vector3(0.5, 0.5, 0.5), Vector3(0.0, 0.0, 0.0))
	_box(root, "shelf_high", Vector3(1.0, 0.6, 0.6), Vector3(2.0, 2.4, 0.0))
	_box(root, "rug", Vector3(2.0, 0.04, 1.4), Vector3(6.0, 0.0, 0.0))
	_box(root, "pebble", Vector3(0.2, 0.3, 0.2), Vector3(7.0, 0.0, 0.0))
	_box(root, "town_hall", Vector3(12.0, 8.0, 9.0), Vector3(20.0, 0.0, 0.0))
	var walker: MeshInstance3D = _box(root, "walker", Vector3(0.8, 1.7, 0.3), Vector3(9.0, 0.0, 0.0))
	ContactShadow.attach(walker.get_parent() as Node3D, 0.5)
	var spots: Array[Dictionary] = PropShade.footprints(root)
	assert_eq(spots.size(), 2, "the crate stack and the barrel; not the lantern, the high shelf, the rug, the pebble, the hall or the walker")
	var crate: Dictionary = spots[0]
	assert_almost_eq((crate["pos"] as Vector3).x, 4.0, 0.01)
	assert_almost_eq((crate["pos"] as Vector3).y, 0.0, 0.01, "on the ground under it")
	assert_gt((crate["size"] as Vector2).y, (crate["size"] as Vector2).x, "sized to the footprint (deeper than wide here)")
	var shade: MultiMeshInstance3D = PropShade.install(root, root, Callable(), 1)
	assert_not_null(shade)
	assert_eq(shade.multimesh.instance_count, 2, "one draw call for all of them")
	assert_eq(shade.cast_shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)
	var again: MultiMeshInstance3D = PropShade.install(root, root, Callable(), 1)
	assert_eq(root.find_children(PropShade.NAME, "MultiMeshInstance3D", false, false).size(), 1, "laid again, never twice")
	assert_eq(again.multimesh.instance_count, 2, "its own blobs are not props")


func test_the_scene_ground_function_places_the_shade_on_terraces() -> void:
	var root: Node3D = Node3D.new()
	add_child_autofree(root)
	_box(root, "crate_on_terrace", Vector3(1.0, 0.9, 1.0), Vector3(0.0, 4.0, 0.0))
	_box(root, "crate_floating", Vector3(1.0, 0.9, 1.0), Vector3(5.0, 6.0, 0.0))
	var terrace: Callable = func(_p: Vector3) -> float: return 4.0
	var spots: Array[Dictionary] = PropShade.footprints(root, terrace)
	assert_eq(spots.size(), 1, "the one that stands on the terrace; a floating thing gets no shade painted under it")
	assert_almost_eq((spots[0]["pos"] as Vector3).y, 4.0, 0.01)
	assert_eq(PropShade.footprints(root).size(), 0, "without a ground function only things near y 0 count")


func test_medium_shades_more_than_low_and_the_rig_lays_it() -> void:
	assert_gt(PropShade.ALPHA[1], PropShade.ALPHA[0])
	var source: String = FileAccess.get_file_as_string("res://world/style/style_rig.gd")
	assert_true(source.contains("ContactShadow.apply_quality(quality())"))
	assert_true(source.contains("PropShade.install(self, _scene_root, PropShade.ground_of(_scene_root), quality())"))
	assert_true(source.contains("GraphicsQuality.low_end"), "none on the Low-end preset")


# ---- Part C, item 5: a marker near the lens never fills the picture ------------------------------------------------------------


func test_a_quest_marker_shrinks_near_the_lens() -> void:
	assert_eq(QuestMarkerLayer.near_scale(20.0), 1.0, "full size at the default camera's distance")
	assert_eq(QuestMarkerLayer.near_scale(QuestMarkerLayer.NEAR_FULL), 1.0)
	assert_almost_eq(QuestMarkerLayer.near_scale(4.5), 0.5, 0.001, "half size at half the distance: the same size on screen")
	assert_eq(QuestMarkerLayer.near_scale(0.5), QuestMarkerLayer.NEAR_MIN, "never smaller than that")


# ---- Part C, item 3: one water --------------------------------------------------------------------------------------------------


func test_the_shared_water_has_a_sky_tint_and_the_fountains_use_it() -> void:
	for path: String in ["res://assets/shaders/style_water.gdshader", "res://world/look/world_water.gdshader"]:
		var code: String = FileAccess.get_file_as_string(path)
		assert_true(code.contains("sky_tint"), "%s leans to the sky at a grazing view" % path.get_file())
		assert_true(code.contains("sky_amount"))
	assert_true(FileAccess.get_file_as_string("res://world/look/world_water.gdshader").contains("ripple_amount"), "slow wide ripples on the sea")
	var basin: ShaderMaterial = StyleWater.basin()
	assert_eq(basin.shader, StyleWater.material().shader, "a fountain's bowl is the shared toon water")
	assert_eq(basin.get_shader_parameter("use_depth"), false, "no depth read in a bowl a hand deep (it would all be shore foam)")
	assert_eq(basin.get_shader_parameter("foam_width"), 0.0)
	assert_eq(StyleWater.basin(), basin, "one cached material")
	var kit: KitMesh = KitMesh.new()
	CapitalKit.materials(kit)
	assert_eq(kit.material_of("water"), basin, "the Capital's fountains")
