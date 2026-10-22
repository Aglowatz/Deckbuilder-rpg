extends GutTest
## Apparel Part 2: hats delivered as one sheet (COS-HAT-<NAME>-SHEET.png, five views) are split, trimmed and fitted; the fit layers (fit_auto.json from the importer,
## fit.json by hand) combine; the hat follows the tracked head through the walk.

const TEST_HATS: String = "user://test_hat_fit/"


func after_each() -> void:
	SpriteLibrary.reset()


## A 2560x512 sheet with one rectangle per view (widths 200, 180, 150, 180, 200), plus a speck and an antialiased edge pixel.
func _sheet() -> Image:
	var sheet: Image = Image.create_empty(2560, 512, false, Image.FORMAT_RGBA8)
	var widths: Array[int] = [200, 180, 150, 180, 200]
	for view: int in range(5):
		var left: int = view * 512 + 256 - widths[view] / 2
		sheet.fill_rect(Rect2i(left, 200, widths[view], 120), Color(0.2 + 0.15 * float(view), 0.3, 0.6, 1.0))
	sheet.fill_rect(Rect2i(1030, 40, 4, 4), Color.BLACK)  # a speck in the SIDE fifth
	return sheet


func test_a_sheet_splits_into_five_trimmed_views_without_specks() -> void:
	var views: Dictionary = HatSheet.split(_sheet())
	assert_eq(views.size(), 5)
	var widths: Array[int] = [200, 180, 150, 180, 200]
	for view: int in range(5):
		var image: Image = views[HatSheet.DIRS[view]] as Image
		assert_not_null(image, HatSheet.DIRS[view])
		assert_eq(image.get_width(), widths[view] + HatSheet.PAD * 2, "%s trimmed to its hat" % HatSheet.DIRS[view])
		assert_eq(image.get_height(), 120 + HatSheet.PAD * 2, "the speck above the SIDE view is dropped")
		# The bottom-centre of the trimmed view is where the hat meets the head: the hat touches the bottom (bar the padding).
		assert_gt(image.get_pixel(image.get_width() / 2, image.get_height() - HatSheet.PAD - 1).a, 0.9)


func test_a_missing_view_is_simply_missing() -> void:
	var sheet: Image = _sheet()
	sheet.fill_rect(Rect2i(2048, 0, 512, 512), Color(0, 0, 0, 0))
	var views: Dictionary = HatSheet.split(sheet)
	assert_false(views.has("BACK"))
	assert_eq(views.size(), 4)


func test_each_view_is_scaled_by_its_own_head_band() -> void:
	# A hat with a brim twice the crown's width; the back view is drawn 1.4 times bigger, the side view has a narrower brim (seen edge-on less wide).
	var views: Dictionary = {"FRONT": _hat(100, 50, 1.0), "BACK": _hat(100, 50, 1.4), "SIDE": _hat(100, 80, 1.0)}
	var fit: Dictionary = HatSheet.fit("BOWLER", views)
	assert_almost_eq(float(fit["width"]), float(HatSheet.BASE_FIT["BOWLER"]["width"]), 0.001)
	assert_almost_eq(float(fit["ratio_BACK"]), 1.0, 0.03, "a view drawn bigger is not worn bigger")
	assert_almost_eq(float(fit["ratio_SIDE"]), 1.0, 0.03, "the brim keeps its share of the head")
	assert_eq(HatSheet.band_width(views["FRONT"] as Image), 100.0)


## A brim `brim` px wide and 20 tall under a crown `crown` px wide and 60 tall, scaled by `scale`.
func _hat(brim: int, crown: int, scale: float) -> Image:
	var image: Image = Image.create_empty(int(float(brim) * scale), int(80.0 * scale), false, Image.FORMAT_RGBA8)
	image.fill_rect(Rect2i(int(float(brim - crown) * 0.5 * scale), 0, int(float(crown) * scale), int(60.0 * scale)), Color.BLUE)
	image.fill_rect(Rect2i(0, int(60.0 * scale), int(float(brim) * scale), int(20.0 * scale)), Color.BLUE)
	return image


func test_hand_tuning_wins_over_the_importer_fit() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(TEST_HATS))
	_write(TEST_HATS + "fit_auto.json", {"TESTHAT": {"width": 2.0, "sink": 0.3, "ratio_SIDE": 0.5}})
	_write(TEST_HATS + "fit.json", {"TESTHAT": {"sink": 0.1, "width_BACK": 1.0}})
	SpriteLibrary.reset()
	SpriteLibrary.hat_folder = TEST_HATS
	assert_almost_eq(float(SpriteLibrary.hat_fit("TESTHAT", "FRONT")["width"]), 2.0, 0.001, "the importer's width")
	assert_almost_eq(float(SpriteLibrary.hat_fit("TESTHAT", "SIDE")["width"]), 1.0, 0.001, "times the side ratio")
	assert_almost_eq(float(SpriteLibrary.hat_fit("TESTHAT", "SIDE")["sink"]), 0.1, 0.001, "the hand-tuned sink")
	assert_almost_eq(float(SpriteLibrary.hat_fit("TESTHAT", "BACK")["width"]), 1.0, 0.001, "a hand-set direction width")


func test_head_tracking_finds_a_moved_head() -> void:
	var idle: Image = Image.create_empty(200, 300, false, Image.FORMAT_RGBA8)
	_figure(idle, 100, 40)
	var moved: Image = Image.create_empty(200, 300, false, Image.FORMAT_RGBA8)
	_figure(moved, 105, 37)
	var anchor: Array = SpriteAnchors.head_anchor(idle)
	assert_eq(SpriteAnchors.head_offset(idle, anchor, moved), Vector2i(5, -3))


func test_the_hero_has_a_tracked_hat_anchor_for_every_frame() -> void:
	var tracked: Dictionary = SpriteLibrary.info("PLAYER").get("hat_anchor", {}) as Dictionary
	var frames: Array = SpriteLibrary.info("PLAYER").get("frames", []) as Array
	assert_eq(tracked.size(), frames.size())
	for frame: Variant in frames:
		var anchor: Array = SpriteLibrary.hat_anchor("PLAYER", str(frame))
		var idle: Array = SpriteLibrary.hat_anchor("PLAYER", str(frame).get_slice("_", 0) + "_IDLE")
		assert_eq(float(anchor[2]), float(idle[2]), "%s: one head width per direction (the hat never pulses)" % frame)
		assert_almost_eq(float(anchor[1]), float(idle[1]), 16.0, "%s: the bob stays small" % frame)


## A head (disc with a light face spot) on a body.
func _figure(image: Image, cx: int, top: int) -> void:
	for y: int in range(top, 300):
		for x: int in range(200):
			var inside: bool = false
			if y < top + 50:
				inside = Vector2(x - cx, y - (top + 25)).length() <= 25.0
			else:
				inside = absi(x - cx) <= 45
			if inside:
				image.set_pixel(x, y, Color(0.9, 0.7, 0.5) if Vector2(x - cx - 8, y - top - 20).length() < 6.0 else Color(0.4, 0.25, 0.15))


func _write(path: String, data: Dictionary) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
