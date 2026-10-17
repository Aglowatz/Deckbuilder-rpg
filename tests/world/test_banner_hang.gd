extends GutTest
## Gainlands v2, Part E: banners hang from their top bar. The shared toon shaders' hang mode keeps the top edge still, swings the cloth more towards its
## bottom, only across the cloth (never through its pole), small and slow, in one wind direction, with a phase of its own per banner; poles never bend.


## The shader's offset, mirrored in GDScript (the same formula as `hang_offset` in style_toon.gdshader).
func _offset(v: Vector3, model: Basis, cloth: Vector4, top: float, phase: float, time: float) -> Vector3:
	var down: float = clampf((top - v.y) / cloth.w, 0.0, 1.0)
	var n: Vector3 = Vector3(cloth.x, cloth.y, cloth.z).normalized()
	var wind_local: Vector3 = (model.transposed() * Vector3(0.86, 0.0, 0.5)).normalized()
	var push: float = wind_local.dot(n)
	var lean: float = lerpf(0.35, 1.0, absf(push)) * (-1.0 if push < 0.0 else 1.0)
	var gust: float = 0.55 + 0.35 * sin(time * 0.85 + phase) + 0.1 * sin(time * 2.4 + phase * 1.7)
	return n * lean * gust * down * down * cloth.w * 0.035


func test_the_shaders_share_one_hang_mode() -> void:
	for path: String in ["res://assets/shaders/style_toon.gdshader", "res://assets/shaders/style_toon_double.gdshader", "res://world/style/style_cloth_icon.gdshader"]:
		var code: String = FileAccess.get_file_as_string(path)
		assert_true(code.contains("instance uniform vec4 hang"), "%s takes the cloth's normal and length per instance" % path)
		assert_true(code.contains("return n * lean * gust * down * down * cloth.w * 0.035;"), "%s: the same offset (along the normal, squared down the cloth, 3.5 %% of its length)" % path)
		assert_true(code.contains("const vec3 STYLE_WIND_DIR = vec3(0.86, 0.0, 0.5);"), "%s: one wind direction for the zone" % path)
	var toon: String = FileAccess.get_file_as_string("res://assets/shaders/style_toon.gdshader")
	assert_true(toon.contains("if (wind_amount > 0.0 && hang.w > 0.0)"), "hanging cloth leaves the foliage sway (which bends from the foot)")


func test_the_top_edge_stays_still_and_the_swing_grows_towards_the_bottom() -> void:
	var cloth: Vector4 = Vector4(0, 0, 1, 2.6)
	var top: float = 1.3
	var turn: Basis = Basis(Vector3.UP, 0.7)
	for t: float in [0.0, 1.3, 2.9, 7.4]:
		assert_almost_eq(_offset(Vector3(0.3, top, 0.0), turn, cloth, top, 1.1, t).length(), 0.0, 0.0001, "the top edge never moves (t %.1f)" % t)
		var middle: float = _offset(Vector3(0.3, 0.0, 0.0), turn, cloth, top, 1.1, t).length()
		var bottom: float = _offset(Vector3(0.3, -1.3, 0.0), turn, cloth, top, 1.1, t).length()
		assert_gt(bottom, middle, "the bottom swings more than the middle")
		assert_lte(bottom, cloth.w * 0.035 + 0.0001, "a small swing: at most 3.5 %% of the cloth's length")
		var offset: Vector3 = _offset(Vector3(0.3, -1.3, 0.0), turn, cloth, top, 1.1, t)
		assert_almost_eq(offset.x, 0.0, 0.0001, "across the cloth only (no stretch along it, nothing towards the pole)")
		assert_almost_eq(offset.y, 0.0, 0.0001, "never up or down")
	var a: Vector3 = _offset(Vector3(0, -1.3, 0), Basis.IDENTITY, cloth, top, 0.0, 2.0)
	var b: Vector3 = _offset(Vector3(0, -1.3, 0), Basis.IDENTITY, cloth, top, 2.5, 2.0)
	assert_ne(a, b, "two banners with their own phases are not in step")


func test_cloth_meshes_get_their_hang_from_their_bounds_and_poles_stay_rigid() -> void:
	var host: Node3D = Node3D.new()
	host.name = "RulerBanners"
	add_child_autofree(host)
	var banner: Node3D = RulerPresence._banner(Color.RED)
	host.add_child(banner)
	var pole: MeshInstance3D = banner.find_child("Pole", false, false) as MeshInstance3D
	var cloth: MeshInstance3D = banner.find_child("BannerCloth", false, false) as MeshInstance3D
	var stripe: MeshInstance3D = banner.find_child("BannerStripe", false, false) as MeshInstance3D
	assert_not_null(pole)
	assert_not_null(cloth)
	assert_lt(StyleToon.wind_for(pole, 1.5), 0.0, "the pole never sways")
	assert_gt(StyleToon.wind_for(cloth, 1.5), 0.0, "the cloth does")
	assert_true(StyleToon.is_cloth(cloth), "a banner's cloth is hanging cloth")
	assert_false(StyleToon.is_cloth(pole), "its pole is not")
	var params: Dictionary = StyleToon.hang_params(cloth)
	var hang: Vector4 = params["hang"] as Vector4
	assert_almost_eq(hang.w, RulerPresence.BANNER_CLOTH.y, 0.01, "the cloth's length")
	assert_almost_eq(float(params["top"]) + cloth.position.y, RulerPresence.BANNER_TOP, 0.01, "its top edge is the bar's height")
	assert_almost_eq(absf(hang.z), 1.0, 0.001, "its normal is its thin axis")
	var stripe_params: Dictionary = StyleToon.hang_params(stripe)
	assert_almost_eq(float(stripe_params["top"]) + stripe.position.y, RulerPresence.BANNER_TOP, 0.01, "the stripe hangs from the same edge: it moves with the cloth")
	assert_almost_eq(float(stripe_params["phase"]), float(params["phase"]), 0.0001, "and in step with it")
	var emblem: MeshInstance3D = banner.find_child("Emblem", false, false) as MeshInstance3D
	assert_true(emblem.material_override is ShaderMaterial and (emblem.material_override as ShaderMaterial).shader.resource_path == RulerPresence.CLOTH_ICON_SHADER, "the emblem hangs with its cloth")
	var bunting: Node3D = RulerPresence._bunting(Color.RED)
	autofree(bunting)
	assert_true(bunting.has_meta(&"no_wind"), "the freed bunting's little pennants stay still")
	StyleToon.apply(banner, 1.5)
	assert_ne(cloth.get_instance_shader_parameter("hang"), null, "the style rig sets the cloth's hang")


func test_the_kit_banner_post_hangs_its_cloth_as_its_own_mesh() -> void:
	var post: Node3D = PropKit.make("banner_post")
	autofree(post)
	var cloth: MeshInstance3D = post.find_child("BannerCloth", false, false) as MeshInstance3D
	assert_not_null(cloth, "the banner is its own mesh (it can sway; the post cannot)")
	if cloth != null:
		assert_false(cloth.has_meta("kit_static"), "never merged into a static batch")
		assert_true(StyleToon.is_cloth(cloth), "hanging cloth")
		var params: Dictionary = StyleToon.hang_params(cloth)
		assert_almost_eq(float(params["top"]), 3.15, 0.01, "it hangs from its bar")
	var body: MeshInstance3D = post.find_child("Body", false, false) as MeshInstance3D
	assert_lt(StyleToon.wind_for(body, 1.5), 0.0, "the post itself never sways")
