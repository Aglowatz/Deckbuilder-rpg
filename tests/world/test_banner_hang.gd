extends GutTest
## Gainlands v2, Part E: banners hang from their top bar. The shared toon shaders' hang mode keeps the top edge still, swings the cloth more towards its
## bottom, only across the cloth (never through its pole), small and slow, in one wind direction, with a phase of its own per banner; poles never bend.


const WIND_INCLUDE: String = "res://assets/shaders/style_wind.gdshaderinc"


## The shared gust front, mirrored in GDScript (`style_wind_gust` in style_wind.gdshaderinc; Graphics Tier 2).
func _gust(world_xz: Vector2, time: float) -> float:
	var along: float = world_xz.dot(Vector2(0.86, 0.5))
	var a: float = sin(along * 0.11 - time * 1.1)
	var b: float = sin(along * 0.037 - time * 0.45 + 1.3)
	var g: float = 0.5 + 0.5 * (0.65 * a + 0.35 * b)
	return g * g


## The shader's offset, mirrored in GDScript (the same formula as `hang_offset` in style_wind.gdshaderinc, shared by the three cloth shaders).
func _offset(v: Vector3, model: Basis, cloth: Vector4, top: float, phase: float, time: float, origin_xz: Vector2 = Vector2.ZERO) -> Vector3:
	var down: float = clampf((top - v.y) / cloth.w, 0.0, 1.0)
	var n: Vector3 = Vector3(cloth.x, cloth.y, cloth.z).normalized()
	var wind_local: Vector3 = (model.transposed() * Vector3(0.86, 0.0, 0.5)).normalized()
	var push: float = wind_local.dot(n)
	var lean: float = lerpf(0.35, 1.0, absf(push)) * (-1.0 if push < 0.0 else 1.0)
	var gust: float = 0.4 + 0.4 * _gust(origin_xz, time) + 0.15 * sin(time * 0.85 + phase) + 0.05 * sin(time * 2.4 + phase * 1.7)
	return n * lean * gust * down * down * cloth.w * 0.035


func test_the_shaders_share_one_hang_mode() -> void:
	# Graphics Tier 2: the offset and the wind direction live in one include that every cloth shader pulls in.
	var include: String = FileAccess.get_file_as_string(WIND_INCLUDE)
	assert_true(include.contains("return n * lean * gust * down * down * cloth.w * 0.035;"), "the include holds the offset (along the normal, squared down the cloth, 3.5 %% of its length)")
	assert_true(include.contains("const vec3 STYLE_WIND_DIR = vec3(0.86, 0.0, 0.5);"), "the include holds the one wind direction for the zone")
	for path: String in ["res://assets/shaders/style_toon.gdshader", "res://assets/shaders/style_toon_double.gdshader", "res://world/style/style_cloth_icon.gdshader"]:
		var code: String = FileAccess.get_file_as_string(path)
		assert_true(code.contains("instance uniform vec4 hang"), "%s takes the cloth's normal and length per instance" % path)
		assert_true(code.contains("#include \"%s\"" % WIND_INCLUDE), "%s: the same offset and wind direction, from the shared include" % path)
		assert_false(code.contains("vec3 hang_offset("), "%s: no private copy of the offset" % path)
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
	var stripe: MeshInstance3D = banner.find_child("BannerTrim", false, false) as MeshInstance3D  # Fixes Oct 26: the trim replaced the stripe
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
	assert_almost_eq(float(stripe_params["top"]) + stripe.position.y, RulerPresence.BANNER_TOP, 0.01, "the trim hangs from the same edge: it moves with the cloth")
	assert_almost_eq(float(stripe_params["phase"]), float(params["phase"]), 0.0001, "and in step with it")
	var emblem: MeshInstance3D = banner.find_child("Emblem", false, false) as MeshInstance3D
	assert_true(emblem.material_override is ShaderMaterial and (emblem.material_override as ShaderMaterial).shader.resource_path == RulerPresence.CLOTH_ICON_SHADER, "the emblem hangs with its cloth")
	var bunting: Node3D = RulerPresence._bunting(Color.RED)
	autofree(bunting)
	assert_true(bunting.has_meta(&"no_wind"), "the freed bunting's little pennants stay still")
	StyleToon.apply(banner, 1.5)
	assert_ne(cloth.get_instance_shader_parameter("hang"), null, "the style rig sets the cloth's hang")


## Fixes Oct 26, Part 5: a proper banner - swallowtail cloth of the painted canvas in the ruler's colour, darker trim, crossbar and finial (rigid),
## the emblem centred in the upper third, every hanging part in one frame.
func test_the_ruler_banner_is_a_proper_banner() -> void:
	var tint: Color = Color("8a1f1f")
	var banner: Node3D = RulerPresence._banner(tint)
	autofree(banner)
	var cloth: MeshInstance3D = banner.find_child("BannerCloth", false, false) as MeshInstance3D
	var trim: MeshInstance3D = banner.find_child("BannerTrim", false, false) as MeshInstance3D
	var cloth_box: AABB = cloth.mesh.get_aabb()
	assert_almost_eq(cloth_box.position.y, -RulerPresence.BANNER_CLOTH.y, 0.01, "the tails reach the full length")
	var lowest_middle: float = 0.0
	for v: Vector3 in cloth.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX] as PackedVector3Array:
		if absf(v.x) < 0.01:
			lowest_middle = minf(lowest_middle, v.y)
	assert_almost_eq(lowest_middle, -RulerPresence.BANNER_CLOTH.y + RulerPresence.SWALLOW_NOTCH, 0.01, "a swallowtail: the middle of the hem rises")
	var cloth_material: StandardMaterial3D = cloth.material_override as StandardMaterial3D
	var trim_material: StandardMaterial3D = trim.material_override as StandardMaterial3D
	assert_not_null(cloth_material.albedo_texture, "painted cloth (the kit canvas), not a flat colour")
	assert_lt(trim_material.albedo_color.v, cloth_material.albedo_color.v, "the trim is darker than the cloth")
	assert_almost_eq(cloth_material.albedo_color.h, tint.h, 0.03, "in the ruler's colour")
	for rigid_name: String in ["Pole", "CrossbarPole", "FinialPole"]:
		var part: MeshInstance3D = banner.find_child(rigid_name, false, false) as MeshInstance3D
		assert_not_null(part, rigid_name)
		if part != null:
			assert_lt(StyleToon.wind_for(part, 1.5), 0.0, "%s never sways" % rigid_name)
	assert_eq(trim.get_meta(&"hang"), cloth.get_meta(&"hang"), "the trim shares the cloth's hang frame")
	assert_eq(trim.position, cloth.position)
	var emblem: MeshInstance3D = banner.find_child("Emblem", false, false) as MeshInstance3D
	var from_top: float = RulerPresence.BANNER_TOP - emblem.position.y
	assert_between(from_top, RulerPresence.BANNER_CLOTH.y / 6.0 - 0.1, RulerPresence.BANNER_CLOTH.y / 6.0 + 0.1, "the emblem is centred in the upper third")
	assert_almost_eq(emblem.position.x, cloth.position.x, 0.001, "and across the cloth")
	assert_gte((emblem.mesh as QuadMesh).size.x, 0.7, "at a readable size")


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
