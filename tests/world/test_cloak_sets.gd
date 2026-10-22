extends GutTest
## Apparel Part 1: the four cloak sets made from the hero's own frames by tools/make_cloaks.gd. Every set must be complete (the shop sells it), the same canvas as the default
## hero, and line up with it frame by frame (the head and the foot line never move: a cloak swap mid-walk shows no jump).

const CLOAKS: Array[String] = ["REDCAPE", "PATCHWORK", "TATTERED", "ROYAL"]


func before_each() -> void:
	SpriteLibrary.reset()


func test_every_cloak_set_is_complete_and_ready_for_the_shop() -> void:
	for cloak: String in CLOAKS:
		assert_true(SpriteLibrary.has_cloak(cloak), "%s has every direction" % cloak)
		assert_eq(SpriteLibrary.cloak_character(cloak), "PLAYER_CLOAK_" + cloak)
		assert_not_null(SpriteLibrary.item_icon(false, cloak), "%s has a shop icon" % cloak)
	for item: CosmeticData in CosmeticCatalog.cloaks():
		assert_true(SpriteCosmetics.art_ready(item), "%s is no longer 'arriving soon'" % item.display_name)


func test_every_frame_lines_up_with_the_default_hero() -> void:
	var base: Dictionary = SpriteLibrary.info("PLAYER")
	var base_head: Dictionary = base.get("head", {}) as Dictionary
	for cloak: String in CLOAKS:
		var entry: Dictionary = SpriteLibrary.info("PLAYER_CLOAK_" + cloak)
		assert_eq(entry.get("canvas"), base.get("canvas"), "%s: same canvas" % cloak)
		assert_eq(entry.get("fig_h"), base.get("fig_h"), "%s: same figure height" % cloak)
		assert_eq((entry.get("frames", []) as Array).size(), (base.get("frames", []) as Array).size(), "%s: every frame" % cloak)
		var head: Dictionary = entry.get("head", {}) as Dictionary
		for frame: Variant in base_head.keys():
			var a: Array = head.get(frame, []) as Array
			var b: Array = base_head[frame] as Array
			assert_eq(a.size(), 3, "%s %s has a head anchor" % [cloak, frame])
			if a.size() == 3:
				assert_almost_eq(float(a[0]), float(b[0]), 1.0, "%s %s: head x" % [cloak, frame])
				assert_almost_eq(float(a[1]), float(b[1]), 1.0, "%s %s: head top" % [cloak, frame])


func test_the_feet_stay_where_the_default_hero_has_them() -> void:
	for frame: String in ["FRONT_IDLE", "SIDE_WALK2", "BACK_WALK4"]:
		var base: Image = _image("PLAYER", frame)
		var base_rect: Rect2i = base.get_used_rect()
		for cloak: String in CLOAKS:
			var rect: Rect2i = _image("PLAYER_CLOAK_" + cloak, frame).get_used_rect()
			assert_eq(rect.end.y, base_rect.end.y, "%s %s: same foot line" % [cloak, frame])
			assert_eq(rect.position.y, base_rect.position.y, "%s %s: same top" % [cloak, frame])


func test_the_cloak_hue_is_measured_for_each_set() -> void:
	# The red cape is red, the royal mantle blue: the dye shader reads this hue.
	var red: float = float(SpriteLibrary.cloak_hue("PLAYER_CLOAK_REDCAPE")[0])
	assert_true(red < 0.05 or red > 0.95, "red cape hue %.3f" % red)
	var blue: float = float(SpriteLibrary.cloak_hue("PLAYER_CLOAK_ROYAL")[0])
	assert_between(blue, 0.55, 0.72, "royal mantle hue")


func _image(character: String, frame: String) -> Image:
	return Image.load_from_file(ProjectSettings.globalize_path("res://assets/art/world_test/sprites/%s/%s.png" % [character, frame]))
