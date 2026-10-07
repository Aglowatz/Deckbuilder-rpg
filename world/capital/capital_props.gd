class_name CapitalProps
extends RefCounted
## Procedural props of the Capital, built from primitives in the shared palette (`CapitalMaterials`) plus a few KayKit characters
## used as golden statues of Primm. Every function returns a Node3D standing at the origin, facing +z (towards the camera). The
## `ctx` dictionary carries the world state the look depends on: `dark` (the Beefcake service is down), `free` (zone id -> bool),
## `final` (Primm has fallen). Props that change with the story hold two child groups, `Off` and `On`, which the scene flips with
## `CapitalBuilder.set_prop_state`.

const M = preload("res://world/capital/capital_materials.gd")
const B = preload("res://world/buffet/buffet_props.gd")

static var _portrait_textures: Dictionary = {}


static func build(prop: CapitalLayout.Prop, ctx: Dictionary, story: ZoneStoryText) -> Node3D:
	var node: Node3D = _make(prop, ctx, story)
	if node == null:
		return null
	node.name = "%s_%s" % [prop.kind, str(prop.pos)]
	return node


static func _free(ctx: Dictionary, zone_id: String) -> bool:
	return bool((ctx.get("free", {}) as Dictionary).get(zone_id, false)) or bool(ctx.get("final", false))


static func _make(prop: CapitalLayout.Prop, ctx: Dictionary, story: ZoneStoryText) -> Node3D:
	match prop.kind:
		"gate_barrier":
			return gate_barrier()
		"facade_arch":
			return facade_arch(story)
		"fountain":
			return fountain(ctx)
		"hedge":
			return hedge()
		"lamp_perfect":
			return lamp(true, true, M.WHITE)
		"lamp_street":
			return lamp(not bool(ctx.get("dark", false)) or bool(ctx.get("final", false)), false, M.STONE_DARK)
		"statue_primm":
			return statue(prop.model_scale, bool(ctx.get("final", false)))
		"toppled_statue":
			return toppled_statue()
		"portrait":
			return portrait(prop.variant, bool(ctx.get("final", false)))
		"loudspeaker":
			return loudspeaker(bool(ctx.get("final", false)))
		"complaint_box":
			return complaint_box(story)
		"bench":
			return bench()
		"junk_pile":
			return junk_pile(prop.variant, _free(ctx, "refusemancer"))
		"compost_heap":
			return compost_heap()
		"sick_patch":
			return sick_patch()
		"stall_shack":
			return stall_shack(story)
		"manhole":
			return manhole()
		"seed_jar":
			return seed_jar()
		"grave":
			return grave(prop.variant, _free(ctx, "necrocrat"))
		"parlor":
			return parlor(story)
		"permit_office":
			return permit_office(story, _free(ctx, "necrocrat"))
		"notary_booth":
			return booth(Color(0.5, 0.42, 0.3), true)
		"family_plot":
			return family_plot()
		"energy_wheel":
			return energy_wheel(_free(ctx, "beefcake"))
		"crate_stack":
			return crate_stack()
		"pylon":
			return pylon(not bool(ctx.get("dark", false)) or bool(ctx.get("final", false)))
		"power_cable":
			return power_cable()
		"paste_dispenser":
			return paste_dispenser(story, _free(ctx, "gourmand"))
		"kitchen_cart":
			return kitchen_cart()
		"recipe_card":
			return recipe_card()
		"castle_door":
			return castle_door()
		"barrier":
			return barrier()
		"booth":
			return booth([Color(0.55, 0.6, 0.7), Color(0.62, 0.5, 0.45), Color(0.9, 0.9, 0.9)][prop.variant % 3], false)
		"bed":
			return bed()
		"window_booth":
			return booth(Color(0.7, 0.72, 0.78), false)
		"tent":
			return tent()
		"campfire":
			return campfire()
		"rock":
			return rock(prop.variant)
		"tree_dead":
			return dead_tree(prop.variant)
		"wall_crack":
			return wall_crack(prop.variant)
		"loose_stones":
			return loose_stones(prop.variant)
		"scrub":
			return scrub(prop.variant)
		"wreck", "wreck_stack":
			return wreck(prop.kind == "wreck_stack")
		"queue_post":
			return queue_post()
		"tunnel_hatch_cover":
			return hatch_cover()
		"height_post":
			return height_post()
		"crease_column":
			return crease_column()
		"crease_table":
			return crease_table()
		"crease_stall":
			return crease_stall()
		"tea_urn":
			return tea_urn()
		"map_table":
			return crease_table()
		"ladder":
			return ladder()
		"tunnel_arch":
			return tunnel_arch()
		"crease_crate":
			return crate_stack()
		"shaft_door":
			return shaft_door(prop.variant)
		"cot":
			return bed()
	return null


# ---- Helpers -----------------------------------------------------------------------------------


static func _state_group(root: Node3D, group_name: String, visible_now: bool) -> Node3D:
	var group: Node3D = Node3D.new()
	group.name = group_name
	group.visible = visible_now
	root.add_child(group)
	return group


static func _text(parent: Node3D, text: String, pos: Vector3, pixel: float, color: Color, width_m: float = 0.0) -> Label3D:
	return B.label(parent, text, pos, pixel, color, width_m, 4)


# ---- The facade ---------------------------------------------------------------------------------


static func gate_barrier() -> Node3D:
	var root: Node3D = Node3D.new()
	for index: int in range(13):
		var x: float = -5.0 + float(index) * 0.83
		B.box(root, Vector3(0.14, 3.2, 0.14), M.shiny(M.STONE_DARK, 0.3), Vector3(x, 1.6, 0))
	for y: float in [0.7, 2.4]:
		B.box(root, Vector3(10.4, 0.18, 0.2), M.shiny(M.STONE_DARK, 0.3), Vector3(0, y, 0))
	B.box(root, Vector3(10.4, 0.3, 0.26), M.glow(Color(1.0, 0.15, 0.15), 1.6), Vector3(0, 3.0, 0))
	B.box(root, Vector3(0.5, 3.6, 0.5), M.flat(M.STONE_GRAY), Vector3(-5.4, 1.8, 0))
	B.box(root, Vector3(0.5, 3.6, 0.5), M.flat(M.STONE_GRAY), Vector3(5.4, 1.8, 0))
	return root


static func facade_arch(story: ZoneStoryText) -> Node3D:
	var root: Node3D = Node3D.new()
	for side: float in [-1.0, 1.0]:
		B.box(root, Vector3(0.8, 4.2, 0.8), M.shiny(M.WHITE, 0.3), Vector3(side * 3.1, 2.1, 0))
		B.ball(root, 0.55, M.shiny(M.GOLD, 0.25), Vector3(side * 3.1, 4.5, 0))
	B.box(root, Vector3(7.2, 0.8, 0.8), M.shiny(M.WHITE, 0.3), Vector3(0, 4.2, 0))
	B.box(root, Vector3(6.0, 0.35, 0.86), M.shiny(M.GOLD, 0.25), Vector3(0, 4.2, 0))
	_text(root, story.text("prop.facade_arch"), Vector3(0, 4.2, 0.46), 0.011, Color(0.25, 0.1, 0.05), 5.4)
	return root


static func fountain(ctx: Dictionary) -> Node3D:
	var root: Node3D = Node3D.new()
	B.cylinder(root, 2.1, 2.2, 0.45, M.shiny(M.WHITE, 0.3), Vector3(0, 0.22, 0), 20)
	B.cylinder(root, 1.9, 1.9, 0.1, M.translucent(Color(0.5, 0.9, 1.0), 0.85, 0.6), Vector3(0, 0.42, 0), 20)
	B.cylinder(root, 0.35, 0.5, 1.4, M.shiny(M.WHITE, 0.3), Vector3(0, 1.0, 0), 12)
	var figure: Node3D = _golden_figure(1.0)
	root.add_child(figure)
	figure.position = Vector3(0, 1.7, 0)
	if bool(ctx.get("final", false)):
		# Primm has fallen: the golden statue lies in the basin and the fountain runs dry.
		figure.rotation_degrees = Vector3(80.0, 0.0, 25.0)
		figure.position = Vector3(0.9, 0.7, 0.4)
	return root


static func hedge() -> Node3D:
	var root: Node3D = Node3D.new()
	B.box(root, Vector3(2.4, 0.9, 0.7), M.flat(Color(0.2, 0.62, 0.22)), Vector3(0, 0.45, 0))
	return root


static func lamp(lit: bool, ornate: bool, pole_color: Color) -> Node3D:
	var root: Node3D = Node3D.new()
	B.cylinder(root, 0.07, 0.1, 3.4, M.flat(pole_color), Vector3(0, 1.7, 0), 8)
	if ornate:
		B.ball(root, 0.3, M.glow(M.LANTERN, 2.2), Vector3(0, 3.6, 0))
		B.cylinder(root, 0.12, 0.28, 0.12, M.shiny(M.GOLD, 0.3), Vector3(0, 3.35, 0), 8)
	else:
		B.box(root, Vector3(0.34, 0.4, 0.34), M.glow(M.LANTERN, 2.0) if lit else M.flat(Color(0.2, 0.2, 0.22)), Vector3(0, 3.5, 0))
		B.box(root, Vector3(0.46, 0.08, 0.46), M.flat(M.STONE_DARK), Vector3(0, 3.76, 0))
	if lit and not ornate:
		var light: OmniLight3D = OmniLight3D.new()
		light.light_color = M.LANTERN
		light.light_energy = 1.1
		light.omni_range = 8.0
		light.position = Vector3(0, 3.5, 0)
		root.add_child(light)
	return root


## A KayKit knight tinted gold and frozen mid-idle: a statue of Primm (the crown is a little gold box).
static func _golden_figure(figure_scale: float) -> Node3D:
	var figure: Node3D = ModelKit.character("Knight")
	ModelKit.tint(figure, Color(1.7, 1.35, 0.4))
	figure.scale = Vector3.ONE * 0.95 * figure_scale
	var animation: AnimationPlayer = ModelKit.animation_player(figure)
	if animation != null and animation.has_animation("Idle"):
		animation.play("Idle")
		animation.seek(0.4, true)
		animation.pause()
	var holder: Node3D = Node3D.new()
	holder.add_child(figure)
	B.box(holder, Vector3(0.3, 0.14, 0.3), M.shiny(M.GOLD, 0.2), Vector3(0, 1.72 * figure_scale, 0))
	return holder


static func statue(statue_scale: float, toppled: bool) -> Node3D:
	var root: Node3D = Node3D.new()
	var height: float = 1.0 * statue_scale
	B.box(root, Vector3(1.3 * statue_scale, height, 1.3 * statue_scale), M.shiny(M.WHITE, 0.3), Vector3(0, height * 0.5, 0))
	B.box(root, Vector3(0.9 * statue_scale, 0.3, 0.06), M.shiny(M.GOLD, 0.3), Vector3(0, height * 0.55, 0.66 * statue_scale))
	var figure: Node3D = _golden_figure(statue_scale)
	root.add_child(figure)
	figure.position = Vector3(0, height, 0)
	if toppled:
		figure.rotation_degrees = Vector3(80.0, 0.0, 12.0)
		figure.position = Vector3(0.6, height * 0.6, 0.5)
	return root


static func toppled_statue() -> Node3D:
	var root: Node3D = Node3D.new()
	var figure: Node3D = _golden_figure(1.0)
	root.add_child(figure)
	figure.rotation_degrees = Vector3(90.0, 0.0, 0.0)
	figure.position = Vector3(0, 0.5, 0)
	B.box(root, Vector3(1.4, 0.7, 1.4), M.flat(M.STONE_GRAY), Vector3(1.8, 0.35, 0.4), Vector3(0, 20, 10))
	return root


static func portrait_texture(variant: int) -> Texture2D:
	if _portrait_textures.has(variant):
		return _portrait_textures[variant] as Texture2D
	var width: int = 96
	var height: int = 120
	var image: Image = Image.create(width, height, false, Image.FORMAT_RGBA8)
	for y: int in range(height):
		for x: int in range(width):
			var t: float = float(y) / float(height)
			image.set_pixel(x, y, Color(0.95, 0.88, 0.7).lerp(Color(0.8, 0.6, 0.45), t))
	var face_center: Vector2 = Vector2(48.0, 58.0)
	var chin: float = 31.0 if variant == 0 else 34.0
	for y: int in range(height):
		for x: int in range(width):
			var delta: Vector2 = Vector2(float(x), float(y)) - face_center
			if (delta.x * delta.x) / (28.0 * 28.0) + (delta.y * delta.y) / (chin * chin) <= 1.0:
				image.set_pixel(x, y, Color(0.98, 0.84, 0.72))
			if y < 34 and y > 20 and absf(float(x) - 48.0) < 26.0 - float(34 - y) * 0.2:
				image.set_pixel(x, y, Color(0.35, 0.22, 0.12))
	# Eyes, brows and a very fixed smile.
	for eye_x: int in [38, 58]:
		for dy: int in range(-2, 3):
			for dx: int in range(-3, 4):
				image.set_pixel(eye_x + dx, 52 + dy, Color(0.1, 0.1, 0.15))
	for dx: int in range(-13, 14):
		var smile_y: int = 80 - int(float(dx * dx) / 22.0)
		for thick: int in range(2):
			image.set_pixel(48 + dx, clampi(smile_y + thick, 0, height - 1), Color(0.7, 0.1, 0.15))
	if variant == 1:
		for dx: int in range(-24, 25):
			for dy: int in range(0, 9):
				image.set_pixel(48 + dx, 14 + dy, Color(0.96, 0.78, 0.22))
	var texture: ImageTexture = ImageTexture.create_from_image(image)
	_portrait_textures[variant] = texture
	return texture


static func portrait(variant: int, defaced_when_free: bool) -> Node3D:
	var root: Node3D = Node3D.new()
	B.box(root, Vector3(1.5, 1.85, 0.14), M.shiny(M.GOLD, 0.3), Vector3(0, 2.2, 0))
	var quad: MeshInstance3D = MeshInstance3D.new()
	var mesh: QuadMesh = QuadMesh.new()
	mesh.size = Vector2(1.25, 1.55)
	quad.mesh = mesh
	quad.material_override = M.textured(portrait_texture(variant))
	quad.position = Vector3(0, 2.2, 0.08)
	quad.name = "Picture"
	root.add_child(quad)
	for side: float in [-1.0, 1.0]:
		B.cylinder(root, 0.05, 0.05, 1.3, M.flat(M.STONE_DARK), Vector3(side * 0.55, 0.65, -0.05), 6)
	var moustache: Node3D = _state_group(root, "Defaced", false)
	B.box(moustache, Vector3(0.5, 0.07, 0.02), M.flat(Color(0.05, 0.05, 0.05)), Vector3(0, 2.05, 0.13), Vector3(0, 0, 4))
	B.box(moustache, Vector3(0.3, 0.05, 0.02), M.flat(Color(0.05, 0.05, 0.05)), Vector3(-0.35, 2.4, 0.13), Vector3(0, 0, -8))
	B.box(moustache, Vector3(0.3, 0.05, 0.02), M.flat(Color(0.05, 0.05, 0.05)), Vector3(0.35, 2.4, 0.13), Vector3(0, 0, 8))
	return root


static func loudspeaker(silent: bool) -> Node3D:
	var root: Node3D = Node3D.new()
	B.cylinder(root, 0.06, 0.08, 3.0, M.flat(M.STONE_GRAY), Vector3(0, 1.5, 0), 6)
	for side: float in [-1.0, 1.0]:
		var horn: MeshInstance3D = B.cylinder(root, 0.42, 0.1, 0.7, M.shiny(Color(0.85, 0.85, 0.9), 0.3), Vector3(side * 0.42, 3.1, 0.2), 12)
		horn.rotation_degrees = Vector3(70.0, 0.0, -side * 90.0)
	B.ball(root, 0.07, M.glow(Color(1.0, 0.2, 0.2) if not silent else Color(0.3, 0.3, 0.3), 2.5), Vector3(0, 3.5, 0))
	return root


static func complaint_box(story: ZoneStoryText) -> Node3D:
	var root: Node3D = Node3D.new()
	B.cylinder(root, 0.07, 0.07, 0.9, M.flat(M.STONE_GRAY), Vector3(0, 0.45, 0), 6)
	B.box(root, Vector3(0.7, 0.8, 0.5), M.shiny(Color(0.35, 0.55, 0.8), 0.3), Vector3(0, 1.3, 0))
	B.box(root, Vector3(0.4, 0.05, 0.05), M.flat(Color(0.05, 0.05, 0.08)), Vector3(0, 1.55, 0.26))
	_text(root, story.text("prop.complaint_box"), Vector3(0, 1.2, 0.27), 0.0055, Color(1, 1, 1), 0.6)
	return root


static func bench() -> Node3D:
	var root: Node3D = Node3D.new()
	B.box(root, Vector3(1.6, 0.12, 0.5), M.shiny(M.WHITE, 0.4), Vector3(0, 0.5, 0))
	B.box(root, Vector3(1.6, 0.5, 0.1), M.shiny(M.WHITE, 0.4), Vector3(0, 0.85, -0.22))
	for side: float in [-1.0, 1.0]:
		B.box(root, Vector3(0.1, 0.5, 0.45), M.flat(M.STONE_GRAY), Vector3(side * 0.7, 0.25, 0))
	return root


# ---- The Reek (Refusemancers) ------------------------------------------------------------------------


static func junk_pile(variant: int, tidied: bool) -> Node3D:
	var root: Node3D = Node3D.new()
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 100 + variant
	var count: int = 4 if tidied else 7
	for index: int in range(count):
		var size: Vector3 = Vector3(rng.randf_range(0.5, 1.3), rng.randf_range(0.4, 1.1), rng.randf_range(0.5, 1.2))
		var color: Color = [Color(0.4, 0.34, 0.3), Color(0.3, 0.32, 0.34), Color(0.5, 0.42, 0.3), Color(0.36, 0.3, 0.36)][index % 4]
		B.box(root, size, M.flat(color), Vector3(rng.randf_range(-0.7, 0.7), size.y * 0.5 + rng.randf_range(0.0, 0.7), rng.randf_range(-0.7, 0.7)), Vector3(rng.randf_range(-20, 20), rng.randf_range(0, 360), rng.randf_range(-20, 20)))
	B.cylinder(root, 0.4, 0.4, 0.22, M.flat(M.SOOT), Vector3(0.4, 0.2, 0.7), 10).rotation_degrees.x = 80.0
	if tidied:
		for index: int in range(5):
			B.ball(root, 0.16, M.flat(Color(0.35, 0.75, 0.3)), Vector3(rng.randf_range(-0.7, 0.7), 1.0 + rng.randf_range(0.0, 0.4), rng.randf_range(-0.7, 0.7)))
	return root


static func compost_heap() -> Node3D:
	var root: Node3D = Node3D.new()
	B.ball(root, 0.9, M.flat(Color(0.28, 0.2, 0.14)), Vector3(0, 0.0, 0), Vector3(1.0, 0.7, 1.0), true)
	for index: int in range(5):
		var angle: float = TAU * float(index) / 5.0
		B.ball(root, 0.14, M.glow(Color(0.5, 1.0, 0.45), 1.2), Vector3(cos(angle) * 0.45, 0.5, sin(angle) * 0.45))
	B.ball(root, 0.2, M.glow(Color(0.5, 1.0, 0.45), 1.8), Vector3(0, 0.75, 0))
	return root


static func sick_patch() -> Node3D:
	var root: Node3D = Node3D.new()
	var off: Node3D = _state_group(root, "Off", true)
	B.cylinder(off, 1.7, 1.7, 0.04, M.flat(Color(0.2, 0.16, 0.14)), Vector3(0, 0.03, 0), 18)
	for index: int in range(7):
		var angle: float = TAU * float(index) / 7.0
		B.box(off, Vector3(0.06, 0.6, 0.06), M.flat(Color(0.35, 0.3, 0.2)), Vector3(cos(angle) * 0.9, 0.3, sin(angle) * 0.9), Vector3(0, 0, 25.0))
	var on: Node3D = _state_group(root, "On", false)
	B.cylinder(on, 1.7, 1.7, 0.04, M.flat(Color(0.28, 0.4, 0.2)), Vector3(0, 0.03, 0), 18)
	for index: int in range(9):
		var angle: float = TAU * float(index) / 9.0
		B.cylinder(on, 0.03, 0.03, 0.7, M.flat(Color(0.3, 0.75, 0.3)), Vector3(cos(angle) * 0.9, 0.35, sin(angle) * 0.9), 5)
		B.ball(on, 0.13, M.glow(Color(1.0, 0.6, 0.8), 1.2), Vector3(cos(angle) * 0.9, 0.75, sin(angle) * 0.9))
	return root


static func stall_shack(story: ZoneStoryText) -> Node3D:
	var root: Node3D = Node3D.new()
	B.box(root, Vector3(2.4, 2.0, 1.6), M.flat(M.WOOD_DARK), Vector3(0, 1.0, 0))
	B.box(root, Vector3(2.8, 0.14, 2.0), M.flat(Color(0.3, 0.4, 0.25)), Vector3(0, 2.1, 0.1), Vector3(-8, 0, 0))
	_text(root, story.text("prop.compost_shack"), Vector3(0, 1.3, 0.82), 0.0075, M.PAPER, 2.0)
	return root


static func manhole() -> Node3D:
	var root: Node3D = Node3D.new()
	B.cylinder(root, 0.62, 0.62, 0.06, M.flat(M.SOOT), Vector3(0, 0.04, 0), 18)
	B.cylinder(root, 0.5, 0.5, 0.08, M.shiny(M.STONE_DARK, 0.3), Vector3(0, 0.06, 0), 18)
	B.box(root, Vector3(0.5, 0.012, 0.03), M.flat(Color(0.8, 0.8, 0.5)), Vector3(0, 0.11, 0), Vector3(0, 35, 0))
	return root


static func seed_jar() -> Node3D:
	var root: Node3D = Node3D.new()
	B.cylinder(root, 0.2, 0.22, 0.4, M.translucent(Color(0.8, 0.95, 0.8), 0.5, 0.2), Vector3(0, 0.2, 0), 10)
	B.ball(root, 0.07, M.glow(Color(0.7, 1.0, 0.5), 2.2), Vector3(0, 0.18, 0))
	return root


# ---- Grave Row (Necrocrats) -------------------------------------------------------------------------


static func grave(variant: int, tidy: bool) -> Node3D:
	var root: Node3D = Node3D.new()
	var lean: float = 0.0 if tidy else [-14.0, 9.0, 18.0][variant % 3]
	B.box(root, Vector3(0.55, 0.9, 0.16), M.flat(M.STONE_GRAY), Vector3(0, 0.45, 0), Vector3(0, 0, lean))
	B.ball(root, 0.28, M.flat(M.STONE_GRAY), Vector3(0, 0.9, 0), Vector3(1.0, 0.7, 0.3))
	if tidy:
		B.ball(root, 0.12, M.glow(Color(1.0, 0.85, 0.4), 1.0), Vector3(0.3, 0.1, 0.35))
	else:
		B.ball(root, 0.2, M.translucent(Color(0.5, 1.0, 0.7), 0.25, 0.8), Vector3(0, 1.3, 0.1))
	return root


static func parlor(story: ZoneStoryText) -> Node3D:
	var root: Node3D = Node3D.new()
	B.box(root, Vector3(3.2, 2.2, 2.6), M.flat(Color(0.56, 0.5, 0.5)), Vector3(0, 1.1, 0))
	B.box(root, Vector3(3.6, 0.3, 3.0), M.flat(M.STONE_DARK), Vector3(0, 2.35, 0))
	B.box(root, Vector3(0.7, 1.0, 0.06), M.glow(Color(1.0, 0.85, 0.5), 1.0), Vector3(0.7, 1.3, 1.32))
	B.box(root, Vector3(1.0, 0.18, 0.5), M.flat(M.PAPER), Vector3(0.7, 0.6, 1.1))
	_text(root, story.text("prop.parlor"), Vector3(-0.7, 1.4, 1.34), 0.0055, M.PAPER, 1.3)
	return root


static func permit_office(story: ZoneStoryText, closed_for_good: bool) -> Node3D:
	var root: Node3D = Node3D.new()
	B.box(root, Vector3(3.0, 2.4, 2.2), M.flat(Color(0.5, 0.46, 0.38)), Vector3(0, 1.2, 0))
	B.box(root, Vector3(1.4, 0.7, 0.06), M.flat(M.SOOT), Vector3(0, 1.4, 1.12))
	B.box(root, Vector3(1.5, 0.08, 0.5), M.flat(M.WOOD), Vector3(0, 1.0, 1.3))
	for index: int in range(6):
		B.box(root, Vector3(0.3, 0.02 + 0.03 * float(index), 0.22), M.flat(M.PAPER), Vector3(-0.5 + 0.2 * float(index), 1.06, 1.3), Vector3(0, 12.0 * float(index), 0))
	_text(root, story.text("prop.permit_office"), Vector3(0, 2.05, 1.14), 0.0065, M.PAPER, 2.6)
	return root


static func booth(color: Color, notary: bool) -> Node3D:
	var root: Node3D = Node3D.new()
	B.box(root, Vector3(1.6, 2.2, 1.4), M.flat(color), Vector3(0, 1.1, 0))
	B.box(root, Vector3(1.9, 0.14, 1.7), M.flat(M.STONE_DARK), Vector3(0, 2.28, 0))
	B.box(root, Vector3(1.0, 0.6, 0.06), M.glow(Color(0.7, 0.85, 1.0), 0.5), Vector3(0, 1.4, 0.72))
	if notary:
		B.ball(root, 0.18, M.shiny(M.GOLD, 0.25), Vector3(0.5, 0.95, 0.78))
	return root


static func family_plot() -> Node3D:
	var root: Node3D = Node3D.new()
	var off: Node3D = _state_group(root, "Off", true)
	for side: float in [-1.0, 1.0]:
		B.box(off, Vector3(0.1, 0.4, 2.2), M.flat(M.WOOD_DARK), Vector3(side * 1.0, 0.2, 0))
	for side: float in [-1.0, 1.0]:
		B.box(off, Vector3(2.0, 0.4, 0.1), M.flat(M.WOOD_DARK), Vector3(0, 0.2, side * 1.1))
	B.box(off, Vector3(0.6, 0.8, 0.14), M.flat(M.STONE_GRAY), Vector3(0, 0.4, -0.9))
	B.box(off, Vector3(1.6, 0.04, 1.6), M.flat(Color(0.24, 0.2, 0.18)), Vector3(0, 0.03, 0))
	var on: Node3D = _state_group(root, "On", false)
	B.box(on, Vector3(0.6, 0.8, 0.14), M.flat(M.STONE_GRAY), Vector3(0, 0.4, -0.9))
	B.box(on, Vector3(1.6, 0.3, 1.2), M.flat(Color(0.3, 0.55, 0.28)), Vector3(0, 0.15, 0.2))
	for index: int in range(6):
		B.ball(on, 0.1, M.glow([Color(1.0, 0.6, 0.8), Color(1.0, 0.9, 0.4), Color(0.8, 0.7, 1.0)][index % 3], 1.0), Vector3(-0.6 + 0.24 * float(index), 0.4, 0.2))
	return root


# ---- The Transit Yards (Beefcakes) ------------------------------------------------------------------


## A giant hamster wheel (spins when the Beefcakes are free). The rim and spokes are children of a `Spin` node.
static func energy_wheel(freed: bool) -> Node3D:
	var root: Node3D = Node3D.new()
	var spin: Node3D = Node3D.new()
	spin.name = "Spin"
	spin.position = Vector3(0, 2.7, 0)
	spin.set_meta("spin_speed", 0.9 if not freed else 0.25)
	root.add_child(spin)
	var segments: int = 18
	for index: int in range(segments):
		var angle: float = TAU * float(index) / float(segments)
		B.box(spin, Vector3(0.28, 0.28, 1.4), M.shiny(M.METAL, 0.4), Vector3(cos(angle) * 2.4, sin(angle) * 2.4, 0), Vector3(0, 0, rad_to_deg(angle) + 90.0))
		if index % 3 == 0:
			B.box(spin, Vector3(2.4, 0.12, 0.12), M.flat(M.STONE_DARK), Vector3(cos(angle) * 1.2, sin(angle) * 1.2, 0), Vector3(0, 0, rad_to_deg(angle)))
	B.ball(spin, 0.3, M.shiny(M.GOLD, 0.3), Vector3.ZERO)
	for side: float in [-1.0, 1.0]:
		B.box(root, Vector3(0.22, 3.2, 0.22), M.flat(M.STONE_DARK), Vector3(0.0, 1.6, side * 0.8), Vector3(0, 0, 0))
	B.box(root, Vector3(0.3, 0.3, 1.9), M.flat(M.STONE_DARK), Vector3(0, 2.7, 0))
	B.box(root, Vector3(5.6, 0.2, 2.0), M.flat(M.STONE_DARK), Vector3(0, 0.1, 0))
	return root


static func crate_stack() -> Node3D:
	var root: Node3D = Node3D.new()
	B.box(root, Vector3(1.0, 0.9, 1.0), M.flat(M.WOOD), Vector3(0, 0.45, 0))
	B.box(root, Vector3(0.9, 0.8, 0.9), M.flat(M.WOOD_DARK), Vector3(0.6, 0.4, 0.9), Vector3(0, 20, 0))
	B.box(root, Vector3(0.8, 0.7, 0.8), M.flat(M.WOOD), Vector3(0.1, 1.3, 0.1), Vector3(0, 35, 0))
	return root


static func pylon(lit: bool) -> Node3D:
	var root: Node3D = Node3D.new()
	B.box(root, Vector3(0.22, 5.0, 0.22), M.flat(M.STONE_DARK), Vector3(0, 2.5, 0))
	B.box(root, Vector3(2.4, 0.16, 0.16), M.flat(M.STONE_DARK), Vector3(0, 4.6, 0))
	for side: float in [-1.0, 1.0]:
		B.ball(root, 0.12, M.glow(Color(0.4, 0.8, 1.0), 2.0) if lit else M.flat(Color(0.2, 0.2, 0.22)), Vector3(side * 1.1, 4.45, 0))
	return root


static func power_cable() -> Node3D:
	var root: Node3D = Node3D.new()
	var off: Node3D = _state_group(root, "Off", true)
	B.box(off, Vector3(2.4, 0.18, 0.18), M.flat(M.SOOT), Vector3(0, 0.12, 0))
	B.ball(off, 0.15, M.glow(Color(1.0, 0.9, 0.3), 2.5), Vector3(0, 0.3, 0))
	var on: Node3D = _state_group(root, "On", false)
	B.box(on, Vector3(1.0, 0.18, 0.18), M.flat(M.SOOT), Vector3(-0.9, 0.12, 0))
	B.box(on, Vector3(1.0, 0.18, 0.18), M.flat(M.SOOT), Vector3(0.9, 0.2, 0.3), Vector3(0, 20, 0))
	B.ball(on, 0.12, M.glow(Color(0.5, 0.8, 1.0), 3.0), Vector3(0.0, 0.3, 0))
	return root



# ---- The Hungry Quarter (Gourmands) ---------------------------------------------------------------


static func paste_dispenser(story: ZoneStoryText, freed: bool) -> Node3D:
	var root: Node3D = Node3D.new()
	B.box(root, Vector3(1.6, 2.4, 1.0), M.shiny(Color(0.62, 0.64, 0.6), 0.4), Vector3(0, 1.2, 0))
	B.box(root, Vector3(0.9, 0.5, 0.5), M.flat(Color(0.7, 0.66, 0.5)), Vector3(0, 0.55, 0.6))
	B.cylinder(root, 0.12, 0.08, 0.3, M.flat(M.STONE_DARK), Vector3(0, 1.0, 0.6), 8)
	_text(root, story.text("prop.paste_dispenser"), Vector3(0, 1.9, 0.52), 0.0058, Color(0.1, 0.1, 0.1), 1.4)
	var on: Node3D = _state_group(root, "On", false)
	B.cylinder(on, 0.25, 0.25, 0.05, M.glow(Color(0.5, 1.0, 0.2), 1.4), Vector3(0, 0.05, 1.3), 10)
	B.ball(on, 0.18, M.glow(Color(0.5, 1.0, 0.2), 1.6), Vector3(0, 0.3, 1.1))
	return root


static func kitchen_cart() -> Node3D:
	var root: Node3D = Node3D.new()
	B.box(root, Vector3(2.0, 0.9, 1.0), M.flat(M.WOOD), Vector3(0, 0.75, 0))
	for side: float in [-1.0, 1.0]:
		B.cylinder(root, 0.35, 0.35, 0.1, M.flat(M.WOOD_DARK), Vector3(side * 0.85, 0.35, 0.55), 12).rotation_degrees.x = 90.0
	B.cylinder(root, 0.3, 0.3, 0.4, M.shiny(M.METAL, 0.3), Vector3(-0.4, 1.4, 0), 10)
	B.cylinder(root, 0.25, 0.25, 0.3, M.shiny(M.METAL, 0.3), Vector3(0.4, 1.35, 0), 10)
	return root


static func recipe_card() -> Node3D:
	var root: Node3D = Node3D.new()
	B.box(root, Vector3(0.5, 0.02, 0.36), M.flat(M.PAPER), Vector3(0, 0.4, 0), Vector3(0, 20, 8))
	B.ball(root, 0.06, M.glow(M.GOLD, 2.4), Vector3(0, 0.6, 0))
	return root


# ---- The castle approach, checkpoints, outskirts -----------------------------------------------------


static func castle_door() -> Node3D:
	var root: Node3D = Node3D.new()
	B.box(root, Vector3(11.0, 0.3, 0.9), M.shiny(M.GOLD, 0.3), Vector3(0, 6.6, 0.0))
	for side: float in [-1.0, 1.0]:
		B.box(root, Vector3(0.9, 6.6, 0.9), M.shiny(M.STONE_GRAY, 0.4), Vector3(side * 5.5, 3.3, 0))
		B.box(root, Vector3(5.0, 6.0, 0.4), M.shiny(Color(0.12, 0.1, 0.16), 0.3), Vector3(side * 2.5, 3.0, -0.2))
		B.box(root, Vector3(0.12, 5.4, 0.45), M.glow(M.GOLD, 1.0), Vector3(side * 2.5, 3.0, 0.02))
	B.box(root, Vector3(1.6, 1.8, 0.2), M.glow(M.GOLD, 1.2), Vector3(0, 3.0, 0.0))
	return root


static func barrier() -> Node3D:
	var root: Node3D = Node3D.new()
	B.box(root, Vector3(3.0, 0.14, 0.14), M.flat(Color(0.95, 0.9, 0.9)), Vector3(0, 0.95, 0))
	for index: int in range(5):
		B.box(root, Vector3(0.28, 0.16, 0.16), M.flat(Color(0.8, 0.15, 0.15)), Vector3(-1.2 + 0.6 * float(index), 0.95, 0.01))
	for side: float in [-1.0, 1.0]:
		B.box(root, Vector3(0.14, 1.1, 0.14), M.flat(M.STONE_DARK), Vector3(side * 1.5, 0.55, 0))
	return root


static func bed() -> Node3D:
	var root: Node3D = Node3D.new()
	B.box(root, Vector3(1.0, 0.1, 2.0), M.flat(M.STONE_DARK), Vector3(0, 0.45, 0))
	B.box(root, Vector3(0.9, 0.16, 1.7), M.flat(Color(0.7, 0.72, 0.76)), Vector3(0, 0.58, 0))
	for side: float in [-1.0, 1.0]:
		B.box(root, Vector3(0.08, 0.45, 0.08), M.flat(M.STONE_DARK), Vector3(side * 0.45, 0.22, 0.9))
		B.box(root, Vector3(0.08, 0.45, 0.08), M.flat(M.STONE_DARK), Vector3(side * 0.45, 0.22, -0.9))
	return root


static func tent() -> Node3D:
	var root: Node3D = Node3D.new()
	var roof: MeshInstance3D = B.mesh_at(root, _prism(2.6, 1.6, 2.2), M.flat(Color(0.5, 0.45, 0.4)), Vector3(0, 0.8, 0))
	roof.name = "TentRoof"
	return root


static func _prism(width: float, height: float, depth: float) -> PrismMesh:
	var prism: PrismMesh = PrismMesh.new()
	prism.size = Vector3(width, height, depth)
	return prism


static func campfire() -> Node3D:
	var root: Node3D = Node3D.new()
	for index: int in range(6):
		var angle: float = TAU * float(index) / 6.0
		B.box(root, Vector3(0.7, 0.12, 0.14), M.flat(M.WOOD_DARK), Vector3(cos(angle) * 0.3, 0.12, sin(angle) * 0.3), Vector3(0, rad_to_deg(-angle), 12))
	B.ball(root, 0.22, M.glow(Color(1.0, 0.55, 0.15), 3.0), Vector3(0, 0.4, 0))
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.6, 0.3)
	light.light_energy = 1.6
	light.omni_range = 9.0
	light.position = Vector3(0, 1.0, 0)
	root.add_child(light)
	return root


static func rock(variant: int) -> Node3D:
	var root: Node3D = Node3D.new()
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 55 + variant
	for index: int in range(3):
		B.ball(root, rng.randf_range(0.4, 0.8), M.flat(M.STONE_GRAY.darkened(0.1 * float(index))), Vector3(rng.randf_range(-0.5, 0.5), 0.2, rng.randf_range(-0.5, 0.5)), Vector3(1.0, 0.7, 1.0))
	return root


static func dead_tree(variant: int) -> Node3D:
	var root: Node3D = Node3D.new()
	B.cylinder(root, 0.12, 0.22, 3.0, M.flat(M.WOOD_DARK), Vector3(0, 1.5, 0), 6)
	for index: int in range(4):
		var angle: float = float(index) * 1.7 + float(variant)
		B.cylinder(root, 0.04, 0.08, 1.4, M.flat(M.WOOD_DARK), Vector3(cos(angle) * 0.5, 2.5 + 0.2 * float(index), sin(angle) * 0.5), 5).rotation_degrees = Vector3(sin(angle) * 55.0, 0, -cos(angle) * 55.0)
	return root


static func wreck(stack: bool) -> Node3D:
	var root: Node3D = Node3D.new()
	B.box(root, Vector3(2.4, 0.5, 1.2), M.flat(M.WOOD_DARK), Vector3(0, 0.45, 0), Vector3(0, 0, 8))
	for side: float in [-1.0, 1.0]:
		B.cylinder(root, 0.45, 0.45, 0.12, M.flat(M.SOOT), Vector3(side * 0.9, 0.35, 0.65), 12).rotation_degrees.x = 90.0
	B.box(root, Vector3(0.9, 0.7, 0.9), M.flat(M.WOOD), Vector3(0.4, 1.0, 0.0), Vector3(10, 30, 0))
	if stack:
		B.box(root, Vector3(1.6, 0.8, 1.3), M.flat(M.STONE_GRAY), Vector3(-1.0, 0.4, 1.2), Vector3(0, 25, 6))
		B.box(root, Vector3(1.2, 0.9, 1.1), M.flat(M.BRICK_DEAD), Vector3(1.0, 0.45, -1.1), Vector3(0, -20, -5))
	return root


static func queue_post() -> Node3D:
	var root: Node3D = Node3D.new()
	B.cylinder(root, 0.05, 0.08, 1.0, M.shiny(M.GOLD, 0.3), Vector3(0, 0.5, 0), 8)
	B.ball(root, 0.09, M.shiny(M.GOLD, 0.3), Vector3(0, 1.05, 0))
	B.box(root, Vector3(2.0, 0.05, 0.05), M.flat(Color(0.7, 0.1, 0.15)), Vector3(1.0, 0.85, 0))
	return root


static func hatch_cover() -> Node3D:
	var root: Node3D = Node3D.new()
	var off: Node3D = _state_group(root, "Off", true)
	B.box(off, Vector3(1.4, 0.3, 1.1), M.flat(M.STONE_GRAY), Vector3(0, 0.15, 0), Vector3(0, 18, 4))
	B.box(off, Vector3(0.9, 0.5, 0.8), M.flat(M.BRICK_DEAD), Vector3(0.5, 0.25, 0.4), Vector3(0, -12, 0))
	var on: Node3D = _state_group(root, "On", false)
	B.cylinder(on, 0.6, 0.6, 0.05, M.flat(Color(0.02, 0.02, 0.03)), Vector3(0, 0.04, 0), 12)
	B.box(on, Vector3(0.3, 0.05, 0.9), M.flat(M.STONE_DARK), Vector3(0.9, 0.1, 0), Vector3(0, 40, 0))
	return root


static func height_post() -> Node3D:
	var root: Node3D = Node3D.new()
	B.box(root, Vector3(0.18, 2.4, 0.1), M.flat(Color(0.95, 0.95, 0.9)), Vector3(0, 1.2, 0))
	for index: int in range(12):
		B.box(root, Vector3(0.28, 0.03, 0.12), M.flat(Color(0.15, 0.15, 0.2)), Vector3(0, 0.3 + 0.18 * float(index), 0.01))
	B.box(root, Vector3(0.5, 0.12, 0.12), M.glow(Color(1.0, 0.2, 0.2), 1.6), Vector3(0, 1.85, 0.0))
	return root


# ---- The Crease (the hideout) ----------------------------------------------------------------------


static func crease_column() -> Node3D:
	var root: Node3D = Node3D.new()
	B.box(root, Vector3(0.5, 4.6, 0.5), M.flat(M.WOOD_DARK), Vector3(0, 2.3, 0))
	B.box(root, Vector3(0.8, 0.2, 0.8), M.flat(M.WOOD), Vector3(0, 4.5, 0))
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.7, 0.4)
	light.light_energy = 0.8
	light.omni_range = 8.0
	light.position = Vector3(0, 3.8, 0.6)
	root.add_child(light)
	B.ball(root, 0.14, M.glow(M.LANTERN, 2.6), Vector3(0, 3.8, 0.6))
	return root


static func crease_table() -> Node3D:
	var root: Node3D = Node3D.new()
	B.box(root, Vector3(2.2, 0.12, 1.2), M.flat(M.WOOD), Vector3(0, 0.9, 0))
	for sx: float in [-0.9, 0.9]:
		for sz: float in [-0.45, 0.45]:
			B.box(root, Vector3(0.1, 0.9, 0.1), M.flat(M.WOOD_DARK), Vector3(sx, 0.45, sz))
	for index: int in range(5):
		B.box(root, Vector3(0.4, 0.02, 0.3), M.flat(M.PAPER), Vector3(-0.8 + 0.4 * float(index), 0.97, -0.1 + 0.2 * float(index % 2)), Vector3(0, 15.0 * float(index), 0))
	return root


static func crease_stall() -> Node3D:
	var root: Node3D = Node3D.new()
	B.box(root, Vector3(2.8, 1.0, 1.2), M.flat(M.WOOD_DARK), Vector3(0, 0.5, 0))
	B.box(root, Vector3(3.2, 0.1, 1.8), M.flat(Color(0.5, 0.15, 0.25)), Vector3(0, 2.2, 0.2), Vector3(-10, 0, 0))
	for side: float in [-1.0, 1.0]:
		B.box(root, Vector3(0.1, 2.2, 0.1), M.flat(M.WOOD), Vector3(side * 1.4, 1.1, 0.8))
	for index: int in range(5):
		B.box(root, Vector3(0.3, 0.3, 0.3), M.flat([Color(0.8, 0.7, 0.3), Color(0.4, 0.5, 0.8), Color(0.8, 0.3, 0.4)][index % 3]), Vector3(-1.0 + 0.5 * float(index), 1.15, 0.1))
	return root


static func tea_urn() -> Node3D:
	var root: Node3D = Node3D.new()
	B.cylinder(root, 0.4, 0.5, 1.2, M.shiny(Color(0.7, 0.45, 0.2), 0.3), Vector3(0, 0.6, 0), 12)
	B.cylinder(root, 0.12, 0.12, 0.3, M.shiny(Color(0.7, 0.45, 0.2), 0.3), Vector3(0, 1.35, 0), 8)
	B.steam(root, Vector3(0, 1.6, 0), 8, 0.12, 0.7)
	return root


static func ladder() -> Node3D:
	var root: Node3D = Node3D.new()
	for side: float in [-1.0, 1.0]:
		B.box(root, Vector3(0.08, 3.6, 0.08), M.flat(M.WOOD_DARK), Vector3(side * 0.3, 1.8, 0))
	for index: int in range(9):
		B.box(root, Vector3(0.6, 0.06, 0.06), M.flat(M.WOOD), Vector3(0, 0.3 + 0.38 * float(index), 0))
	return root


static func tunnel_arch() -> Node3D:
	var root: Node3D = Node3D.new()
	for side: float in [-1.0, 1.0]:
		B.box(root, Vector3(0.6, 3.4, 0.9), M.flat(M.BRICK_DEAD), Vector3(side * 1.5, 1.7, 0))
	B.box(root, Vector3(3.6, 0.6, 0.9), M.flat(M.BRICK_DEAD), Vector3(0, 3.5, 0))
	B.box(root, Vector3(2.4, 3.2, 0.1), M.flat(Color(0.02, 0.02, 0.03)), Vector3(0, 1.6, -0.3))
	return root


static func shaft_door(index: int) -> Node3D:
	var root: Node3D = Node3D.new()
	B.box(root, Vector3(1.5, 2.4, 0.2), M.shiny(M.STONE_DARK, 0.35), Vector3(0, 1.2, 0))
	B.box(root, Vector3(1.1, 2.0, 0.08), M.flat(Color(0.14, 0.14, 0.18)), Vector3(0, 1.1, 0.08))
	B.box(root, Vector3(0.4, 0.4, 0.06), M.glow(M.LANTERN, 1.2), Vector3(0, 2.05, 0.14))
	_text(root, str(index + 1), Vector3(0, 2.05, 0.18), 0.012, Color(0.2, 0.1, 0.05))
	return root


## Brief 16, Group C: a thin dark crack climbing the wall face (the only hint of the secret passage from far away).
static func wall_crack(variant: int) -> Node3D:
	var root: Node3D = Node3D.new()
	var dark: StandardMaterial3D = M.flat(Color(0.12, 0.1, 0.1))
	var x: float = 0.0
	var y: float = 0.1
	var index: int = 0
	while y < 3.6:
		var step: float = 0.55 + 0.12 * float((index + variant) % 3)
		var lean: float = 14.0 * float(1 - 2 * ((index + variant) % 2))
		B.box(root, Vector3(0.07, step, 0.05), dark, Vector3(x, y + step * 0.5, 0), Vector3(0, 0, lean))
		x += 0.09 * float(1 - 2 * ((index + variant) % 2))
		y += step * 0.9
		index += 1
	return root


## A few loose stones fallen from the wall at the foot of the gap.
static func loose_stones(variant: int) -> Node3D:
	var root: Node3D = Node3D.new()
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 91 + variant
	for index: int in range(4):
		var size: Vector3 = Vector3(rng.randf_range(0.18, 0.4), rng.randf_range(0.1, 0.22), rng.randf_range(0.18, 0.34))
		B.box(root, size, M.flat(M.STONE_GRAY.darkened(0.05 * float(index))), Vector3(rng.randf_range(-0.5, 0.5), 0.08, rng.randf_range(-0.35, 0.35)), Vector3(0, rng.randf_range(0.0, 90.0), rng.randf_range(-8.0, 8.0)))
	return root


## A clump of dry scrub (walkable: the hero pushes through it).
static func scrub(variant: int) -> Node3D:
	var root: Node3D = Node3D.new()
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 33 + variant
	for index: int in range(6):
		var shade: Color = Color(0.36, 0.34, 0.2).lerp(Color(0.5, 0.42, 0.24), rng.randf())
		B.ball(root, rng.randf_range(0.28, 0.5), M.flat(shade), Vector3(rng.randf_range(-0.45, 0.45), rng.randf_range(0.25, 0.7), rng.randf_range(-0.3, 0.3)), Vector3(1.0, 0.9, 1.0))
	return root
