extends GutTest
## Nov 25 night (Part B): the Cracked Mirror stands at the top of Grave Row (not by the castle door), on open ground nothing in the
## freed city uses, with a new look (a gilt frame on a plinth, shader glass with a sheen and cracks, a glow, shards); every text that
## named the old place names the new one, and its painted prop has an art row.


func test_the_mirror_stands_in_the_ward_clear_of_everything() -> void:
	var spot: Vector3 = CapitalScene.GALLERY_MIRROR_SPOT
	var layout: CapitalLayout = CapitalLayout.new()
	layout.build()
	var area: CapitalLayout.Area = layout.area_at(spot.x, spot.z)
	assert_not_null(area)
	assert_eq(area.id, "grave", "at the top of Grave Row, under the castle wall")
	assert_gt(Vector2(spot.x, spot.z).distance_to(Vector2((layout.anchors["castle_door"] as Vector3).x, (layout.anchors["castle_door"] as Vector3).z)), 20.0, "no longer by the castle door")
	var route: float = layout.route_edge_distance(spot.x, spot.z)
	assert_between(route, 1.0, 5.0, "off the lane but in sight of it")
	for anchor_name: Variant in layout.anchors:
		var at: Vector3 = layout.anchors[anchor_name] as Vector3
		assert_gt(Vector2(at.x, at.z).distance_to(Vector2(spot.x, spot.z)), 5.5, "clear of %s" % str(anchor_name))
	for circle: Vector3 in layout.obstacles:
		assert_gt(Vector2(circle.x, circle.y).distance_to(Vector2(spot.x, spot.z)) - circle.z, 1.0, "clear of every obstacle")
	for group: Dictionary in CapitalCelebration.CROWD_GROUPS:
		assert_gt((group["at"] as Vector2).distance_to(Vector2(spot.x, spot.z)), 6.0, "clear of the freed city's crowd")


func test_the_new_look() -> void:
	var mirror: Node3D = CapitalProps.gallery_mirror()
	add_child_autofree(mirror)
	var glass: MeshInstance3D = mirror.find_child("MirrorGlass", true, false) as MeshInstance3D
	assert_not_null(glass, "one pane of glass")
	assert_true(glass.material_override is ShaderMaterial, "drawn by the cracked-mirror shader (sheen, cracks, pulse)")
	assert_eq((glass.material_override as ShaderMaterial).shader.resource_path, CapitalProps.MIRROR_SHADER)
	assert_not_null(mirror.find_child("MirrorGlow", true, false), "a cold glow")
	var shader: String = FileAccess.get_file_as_string(CapitalProps.MIRROR_SHADER)
	for word: String in ["sheen", "crack_line", "pulse"]:
		assert_true(shader.contains(word), word)


func test_the_texts_name_the_new_place() -> void:
	for path: String in ["res://data/story/capital_story.tres", "res://data/dungeons/postgame_dungeons.json", "res://data/dungeons/dungeon_content.json",
			"res://core/quests/quest_definitions.gd", "res://core/quests/zone_quest_definitions.gd"]:
		var text: String = FileAccess.get_file_as_string(path).to_lower()
		for old: String in ["mirror by the castle door", "mirror at the castle door", "mirror beside the castle door", "mirror at primm's castle door", "glass at the castle door", "at the castle door: a cracked mirror"]:
			assert_false(text.contains(old), "%s no longer says '%s'" % [path, old])
	assert_true(FileAccess.get_file_as_string("res://data/story/capital_story.tres").contains("Grave Row"))
	assert_true(FileAccess.get_file_as_string("res://docs/art/batch22.csv").contains("CAP-PROP-CRACKED-MIRROR"))
