extends GutTest
## Overnight Nov 19 (Part 8.5): the sign-angle probe. Every sign board, signpost and plaque in every zone faces the default camera (which looks
## north, from +z) within SignFacing.LIMIT, so its icon reads. Prints every sign with its angle to the camera.


func _report(zone: String, rows: Array[String]) -> void:
	gut.p("%s signs (key: angle to camera):\n  %s" % [zone, "\n  ".join(rows)])


## Buffet, Gainlands and the Dump turn each board by yaw + 180 (their layouts keep yaw within 180 +/- 12).
func test_buffet_gainlands_and_dump_boards_face_the_camera() -> void:
	for layout: Object in [BuffetLayout.new(), GainlandsLayout.new(), HeapLayout.new()]:
		layout.call("build")
		var rows: Array[String] = []
		for sign: Object in layout.get("signs") as Array:
			var angle: float = SignFacing.angle_to_camera(float(sign.get("yaw")) + 180.0)
			rows.append("%s: %.0f" % [str(sign.get("key")), angle])
			assert_lte(angle, SignFacing.LIMIT, "%s %s" % [layout.get_script().get_global_name(), str(sign.get("key"))])
		_report(str(layout.get_script().get_global_name()), rows)


## The D.N.A.'s boards all turn to face the camera (they stood at their rail's yaw: eight turned away, two edge-on).
func test_dna_boards_face_the_camera() -> void:
	var layout: DnaLayout = DnaLayout.new()
	layout.build()
	var rows: Array[String] = []
	for sign: DnaLayout.Sign in layout.signs:
		var angle: float = SignFacing.angle_to_camera(DnaBuilder.sign_rotation(sign))
		rows.append("%s: %.0f (layout yaw %.0f)" % [sign.key, angle, sign.yaw])
		assert_lte(angle, SignFacing.LIMIT, sign.key)
	assert_gt(layout.signs.size(), 10)
	_report("D.N.A.", rows)


## The Capital: posts, banners and loose plaques face the camera; a plaque hung on a wall keeps the wall only when that wall faces the camera.
func test_capital_boards_face_the_camera() -> void:
	var layout: CapitalLayout = CapitalLayout.new()
	layout.build()
	var rows: Array[String] = []
	var turned: int = 0
	for sign: CapitalLayout.Sign in layout.signs:
		# every way the builder may hang a plaque: as laid out, or flat on any of the four faces of a building
		for yaw: float in [sign.yaw, -180.0, 0.0, 90.0 - 180.0, -90.0 - 180.0]:
			for hung: bool in [false, true]:
				var fixed: Dictionary = SignFacing.fix(sign.pos, yaw, sign.style, 180.0, hung and sign.style == "wall")
				var angle: float = SignFacing.angle_to_camera(float(fixed["yaw"]) + 180.0)
				assert_lte(angle, SignFacing.LIMIT, "%s (yaw %.0f, hung %s)" % [sign.key, yaw, str(hung)])
		var as_laid: Dictionary = SignFacing.fix(sign.pos, sign.yaw, sign.style, 180.0, false)
		if not is_equal_approx(float(as_laid["yaw"]), sign.yaw):
			turned += 1
		rows.append("%s: %.0f (was %.0f)" % [sign.key, SignFacing.angle_to_camera(float(as_laid["yaw"]) + 180.0), SignFacing.angle_to_camera(sign.yaw + 180.0)])
	assert_gt(turned, 20, "the edge-on and turned-away boards were turned")
	_report("Capital", rows)


func test_a_plaque_on_a_sideways_wall_stands_out_in_front() -> void:
	var fixed: Dictionary = SignFacing.fix(Vector3(10, 0, 10), -90.0, "wall", 180.0, true)
	assert_eq(str(fixed["style"]), "sign", "on its own posts")
	assert_true(bool(fixed["moved"]))
	assert_gt((fixed["pos"] as Vector3).distance_to(Vector3(10, 0, 10)), 0.5, "out from the wall")
	var kept: Dictionary = SignFacing.fix(Vector3(10, 0, 10), -180.0, "wall", 180.0, true)
	assert_eq(str(kept["style"]), "wall", "a wall facing the camera keeps its plaque")
