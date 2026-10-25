extends GutTest
## Performance pass Oct 25, Part 1: BuildCache stores a build's slow results under its key and the source hash, and gives back the same thing.

var _keys: Array[String] = []


func after_all() -> void:
	for key: String in _keys:
		for ext: String in ["res", "bin"]:
			var path: String = "%s/%s.%s" % [BuildCache.dev_dir(), key, ext]
			if FileAccess.file_exists(path):
				DirAccess.remove_absolute(path)


func _key(label: String) -> String:
	var key: String = "test_%s_%d" % [label, Time.get_ticks_usec()]
	_keys.append(key)
	return key


func test_plain_data_is_built_once_then_read_back() -> void:
	var key: String = _key("data")
	var calls: Array[int] = [0]
	var make: Callable = func() -> Variant:
		calls[0] += 1
		return {"t": PackedFloat32Array([1.0, 2.5, -3.0]), "n": 7}
	var first: Variant = BuildCache.fetch(key, make)
	BuildCache._written.erase(key)
	var second: Variant = BuildCache.fetch(key, make)
	assert_eq(calls[0], 1, "the second fetch reads the stored result instead of building")
	assert_eq((second as Dictionary)["t"], (first as Dictionary)["t"])
	assert_eq(int((second as Dictionary)["n"]), 7)


func test_an_image_round_trips_exactly() -> void:
	var key: String = _key("image")
	var image: Image = Image.create(8, 4, false, Image.FORMAT_RGBA8)
	image.set_pixel(3, 2, Color(0.2, 0.4, 0.6, 0.8))
	BuildCache.fetch(key, func() -> Variant: return image)
	var back: Image = BuildCache.fetch(key, func() -> Variant: return null) as Image
	assert_not_null(back)
	assert_eq(back.get_data(), image.get_data(), "same pixels")


func test_the_source_hash_is_stable_within_a_run() -> void:
	var a: String = BuildCache.source_hash()
	assert_eq(a.length(), 16)
	assert_eq(BuildCache.source_hash(), a)


func test_foliage_placement_packs_and_unpacks() -> void:
	var transforms: Array[Transform3D] = [Transform3D(Basis.from_scale(Vector3(-0.7, 0.7, 1.0)), Vector3(1.5, 0.2, -4.0))]
	var datas: Array[Color] = [Color(3.0, 0.25, 0.5, 0.0)]
	var back: Array = WorldFoliage._unpack(WorldFoliage._pack([transforms, datas]))
	assert_eq((back[0] as Array).size(), 1)
	assert_true(((back[0] as Array)[0] as Transform3D).is_equal_approx(transforms[0]))
	assert_true(((back[1] as Array)[0] as Color).is_equal_approx(datas[0]))
