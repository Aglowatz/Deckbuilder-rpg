extends GutTest
## Fixes Oct 26, Part 2: the D.N.A.'s full-height walls hide their tops from the default camera, the mail room's pneumatic tubes run well above the
## hero's head on wall brackets, and the lights are steady with soft round glows (no flicker, no glowing plates).

## The default camera's lens height above the hero at Normal zoom (tools/shadow_reach_probe.gd at the spawn: 8.8 / 12.1 m at Far zoom 2.0, x 0.75).
const LENS_CINEMATIC: float = 6.6
const LENS_CLASSIC: float = 9.1


func test_walls_stand_above_the_default_lens() -> void:
	assert_gt(DnaInterior.WALL_HEIGHT, LENS_CLASSIC + 0.5, "a wall top above the Classic lens: no top shows")
	assert_gt(DnaInterior.WALL_HEIGHT, LENS_CINEMATIC + 3.0, "Cinematic: the view's top edge rises 2 degrees; 70 m away it is still under the top")
	assert_gt(DnaInterior.SHELL_HEIGHT, DnaInterior.WALL_HEIGHT, "the outer shell stays the tallest")


## Fixes Oct 27: the walls cut by room (test_dna_room_cut.gd), no longer by the hero's depth.
func test_walls_in_front_of_the_hero_cut_away_completely() -> void:
	var shader: String = FileAccess.get_file_as_string("res://world/dna/dna_fade.gdshader")
	assert_true(shader.contains("uniform bool room_cut"), "the room cut exists")
	var fade: DnaFadeMesh = DnaInterior.mesh()
	fade.box("wallpaper", Vector4(0, 0, 0.5, DnaInterior.WALL_HEIGHT), Vector3(0, 5, 0), Vector3(1, 10, 1))
	var mesh: ArrayMesh = fade.build()
	var material: ShaderMaterial = mesh.surface_get_material(0) as ShaderMaterial
	assert_eq(material.get_shader_parameter("room_cut"), true, "walls cut for the hero's room")
	assert_ne(material.get_shader_parameter("cut_front"), true, "not by depth (walls popped as the hero walked past them)")
	assert_eq(float(material.get_shader_parameter("fade_strength")), 1.0, "and vanish (no ghost veil over the room)")


## Nov 18 evening (Part 1.2): the pneumatic tubes are gone - open air, they hung in the air attached to nothing.
func test_no_pneumatic_tubes() -> void:
	var source: String = FileAccess.get_file_as_string("res://world/dna/dna_builder.gd")
	assert_false(source.contains("func _build_tube_network"), "no tube network")
	assert_false(source.contains("TubeBrackets"), "no tube brackets")


func test_lights_are_steady() -> void:
	var scene_source: String = FileAccess.get_file_as_string("res://world/dna/dna_scene.gd")
	assert_false(scene_source.contains("func _flicker"), "no flicker function")
	assert_false(scene_source.contains("sin(_time"), "no light energy wave")
	assert_true(scene_source.contains("func _update_lights"))


func test_sconce_glow_is_a_soft_disc_not_a_plate() -> void:
	var interior: String = FileAccess.get_file_as_string("res://world/dna/dna_interior.gd")
	assert_false(interior.contains("fade.box(\"wash\""), "no flat glowing plate behind the sconces")
	assert_true(interior.contains("fade.disc(\"wash\""))
	var fade: DnaFadeMesh = DnaInterior.mesh()
	fade.disc("wash", Vector4(0, 0, 0.5, 10), Vector3(0, 2.6, 0), Vector3(0, 0, 1), 0.95)
	var arrays: Array = fade.build().surface_get_arrays(0)
	var custom1: PackedFloat32Array = arrays[Mesh.ARRAY_CUSTOM1] as PackedFloat32Array
	assert_eq(custom1.size(), 6 * 4, "one quad")
	for i: int in range(6):
		assert_eq(custom1[i * 4 + 3], 1.0, "every vertex marked as a soft disc")
		assert_almost_eq(Vector2(custom1[i * 4 + 1], custom1[i * 4 + 2]).length(), sqrt(2.0), 0.01, "corners at the rim: alpha 0 there")
