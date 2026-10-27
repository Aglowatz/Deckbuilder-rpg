extends GutTest
## Fixes Oct 27, Part 3: no sign in the open zones stands on a path. The builders move a sign that does off to the verge (SignPlacement) and the
## Capital hangs its plaques flat on their buildings; this checks the same placement on every zone's layout. The whole check, every area as built
## and played (walls, posts, floating boards): bash tools/run_sign_walkway_probe.sh. Prints the signs that move (docs/fixes_oct27.md lists them).


func _layouts() -> Dictionary:
	var result: Dictionary = {}
	for entry: Array in [["gainlands", GainlandsLayout.new()], ["buffet", BuffetLayout.new()], ["heap", HeapLayout.new()], ["capital", CapitalLayout.new()]]:
		var layout: Object = entry[1] as Object
		layout.call("build")
		result[entry[0]] = layout
	return result


func test_no_sign_stands_on_a_path_once_placed() -> void:
	var moved: int = 0
	for zone: String in _layouts().keys():
		var layout: Object = _layouts()[zone] as Object
		var bands: Array = SignPlacement.segments(layout)
		assert_gt(bands.size(), 0, "%s has paths" % zone)
		var capital: CapitalBuilder = null
		if zone == "capital":
			capital = CapitalBuilder.new()
			capital.layout = layout as CapitalLayout
		for sign: Object in layout.get("signs") as Array:
			var before: Vector3 = sign.get("pos") as Vector3
			var style: String = str(sign.get("style"))
			if style == "banner":
				continue
			if capital != null and style == "wall" and capital._onto_building(sign as CapitalLayout.Sign):
				pass
			else:
				sign.set("pos", SignPlacement.off_paths(before, bands))
			var after: Vector3 = sign.get("pos") as Vector3
			if after.distance_to(before) > 0.01:
				moved += 1
				print("SIGN_MOVED %s %s (%.1f, %.1f) -> (%.1f, %.1f)" % [zone, sign.get("key"), before.x, before.z, after.x, after.z])
			if capital == null or style != "wall" or not capital._onto_building(sign as CapitalLayout.Sign):
				assert_false(SignPlacement.on_path(Vector2(after.x, after.z), bands), "%s %s stands on a path at %s" % [zone, sign.get("key"), after])
	assert_gt(moved, 0, "the signs that stood on a path moved")


func test_stepping_off_keeps_the_side_and_clears_the_edge() -> void:
	var bands: Array = [[Vector2(0, 0), Vector2(10, 0), 1.5]]
	var moved: Vector3 = SignPlacement.off_paths(Vector3(4.0, 0.0, 0.6), bands)
	assert_almost_eq(moved.z, 1.5 + SignPlacement.CLEAR, 0.001, "beyond the edge on its own side")
	assert_almost_eq(moved.x, 4.0, 0.001)
	assert_eq(SignPlacement.off_paths(Vector3(4.0, 0.0, 3.0), bands), Vector3(4.0, 0.0, 3.0), "a sign beside the path stays")
