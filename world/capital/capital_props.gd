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
			return CapitalLandmarks.build({"id": "CAP-HERO-PRIMM-FOUNTAIN", "final": bool(ctx.get("final", false))})
		"hedge":
			return hedge()
		"lamp_perfect":
			return kit_card_prop("CAP-PROP-LAMP", 3.6)
		"lamp_street":
			return street_lamp(not bool(ctx.get("dark", false)) or bool(ctx.get("final", false)))
		"statue_primm":
			return statue(prop.model_scale, bool(ctx.get("final", false)))
		"toppled_statue":
			return fallen_statue()
		"portrait":
			return portrait(prop.variant, bool(ctx.get("final", false)), story)
		"loudspeaker":
			return loudspeaker(bool(ctx.get("final", false)))
		"complaint_box":
			return complaint_box(story)
		"bench":
			return kit_card_prop("CAP-PROP-BENCH", 1.0)
		"junk_pile":
			return kit_junk(prop.variant, _free(ctx, "refusemancer"))
		"compost_heap":
			return kit_compost_heap()
		"sick_patch":
			return sick_patch()
		"stall_shack":
			return kit_fern_shack(_free(ctx, "refusemancer"))
		"manhole":
			return manhole()
		"seed_jar":
			return seed_jar()
		"grave":
			return kit_grave(prop.variant, _free(ctx, "necrocrat"))
		"parlor":
			return kit_parlor(_free(ctx, "necrocrat"))
		"permit_office":
			return kit_permit_office(_free(ctx, "necrocrat"))
		"notary_booth":
			return civic_kiosk(bool(ctx.get("final", false)))
		"family_plot":
			return kit_family_plot()
		"energy_wheel":
			return kit_energy_wheel(_free(ctx, "beefcake"))
		"crate_stack":
			return kit_crates()
		"pylon":
			return kit_pylon(_free(ctx, "beefcake") or not bool(ctx.get("dark", false)))
		"power_cable":
			return power_cable()
		"paste_dispenser":
			return kit_paste_dispenser(_free(ctx, "gourmand"))
		"kitchen_cart":
			return kit_kitchen_cart(_free(ctx, "gourmand"))
		"recipe_card":
			return recipe_card()
		"castle_door":
			return castle_door()
		"barrier":
			return barrier()
		"booth":
			return checkpoint_booth() if prop.variant % 3 == 1 else civic_kiosk(bool(ctx.get("final", false)))
		"bed":
			return bed()
		"window_booth":
			return booth(Color(0.7, 0.72, 0.78), false)
		"tent":
			return tent()
		"rift_crystals":
			return rift_crystals(prop.variant, bool(ctx.get("final", false)))
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
			return kit_wreck(prop.kind == "wreck_stack")
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


# ---- The facade ---------------------------------------------------------------------------------


## The great gate itself (CAP-HERO-GREAT-WALL-GATE): two tall white leaves in gold frames with gold lattice and Primm's emblem where they meet,
## closing the 10 m opening until the gate battle is won (then it slides up out of sight, `CapitalBuilder.open_gate`).
static func gate_barrier() -> Node3D:
	var root: Node3D = Node3D.new()
	var mesh: KitMesh = KitMesh.new()
	CapitalKit.materials(mesh)
	for side: float in [-1.0, 1.0]:
		var cx: float = side * 2.5
		mesh.box("plaster", Vector3(cx, 3.6, 0), Vector3(4.9, 7.2, 0.3), Basis.IDENTITY, 0.02, 0.85)
		for face: float in [-1.0, 1.0]:
			var z: float = face * 0.16
			for edge: Array in [[Vector3(cx - 2.4, 0.1, z), Vector3(cx + 2.4, 0.1, z)], [Vector3(cx - 2.4, 7.1, z), Vector3(cx + 2.4, 7.1, z)], [Vector3(cx - 2.4, 0.1, z), Vector3(cx - 2.4, 7.1, z)], [Vector3(cx + 2.4, 0.1, z), Vector3(cx + 2.4, 7.1, z)]]:
				CapitalLandmarks.band(mesh, "gold", edge[0] as Vector3, edge[1] as Vector3, 0.22, Vector3(0, 0, face))
			for index: int in range(4):
				var y: float = 1.2 + float(index) * 1.6
				CapitalLandmarks.band(mesh, "gold", Vector3(cx - 2.2, y, z), Vector3(cx + 2.2, y + 1.2, z), 0.09, Vector3(0, 0, face))
				CapitalLandmarks.band(mesh, "gold", Vector3(cx + 2.2, y, z), Vector3(cx - 2.2, y + 1.2, z), 0.09, Vector3(0, 0, face))
	CapitalKit.emblem(mesh, Vector3(0, 4.4, 0.2), 0.9, Vector3(0, 0, 1))
	CapitalKit.emblem(mesh, Vector3(0, 4.4, -0.2), 0.9, Vector3(0, 0, -1))
	return CapitalLandmarks.finish(root, mesh, [], 7.2)


static func gate_barrier_old() -> Node3D:
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


static func facade_arch(_story: ZoneStoryText) -> Node3D:
	var root: Node3D = Node3D.new()
	for side: float in [-1.0, 1.0]:
		B.box(root, Vector3(0.8, 4.2, 0.8), M.shiny(M.WHITE, 0.3), Vector3(side * 3.1, 2.1, 0))
		B.ball(root, 0.55, M.shiny(M.GOLD, 0.25), Vector3(side * 3.1, 4.5, 0))
	B.box(root, Vector3(7.2, 0.8, 0.8), M.shiny(M.WHITE, 0.3), Vector3(0, 4.2, 0))
	B.box(root, Vector3(6.0, 0.35, 0.86), M.shiny(M.GOLD, 0.25), Vector3(0, 4.2, 0))
	IconSign.attach(root, RulerPresence.EMBLEM_ICON, Vector3(0, 4.2, 0.46), 1.4)  # G-03: the ruler emblem, not lettering
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
	IconSign.attach(root, RulerPresence.EMBLEM_ICON, Vector3(0, height * 0.55, 0.7 * statue_scale), 0.5 * statue_scale)  # the ruler emblem on the plinth (G-03)
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


static func portrait(variant: int, defaced_when_free: bool, story: ZoneStoryText = null) -> Node3D:
	var root: Node3D = Node3D.new()
	if variant == 2 and story != null:
		return lost_poster(story)
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


## A lost-property notice for the "escaped Royal Asset" (Story v2): a pinned sheet that reads like a notice about a missing umbrella. Defacing it crosses out "Asset".
static func lost_poster(_story: ZoneStoryText) -> Node3D:
	var root: Node3D = Node3D.new()
	for side: float in [-1.0, 1.0]:
		B.cylinder(root, 0.04, 0.04, 1.4, M.flat(M.STONE_DARK), Vector3(side * 0.55, 0.7, -0.05), 6)
	B.box(root, Vector3(1.7, 2.1, 0.06), M.flat(Color(0.93, 0.9, 0.8)), Vector3(0, 1.9, 0))
	# G-03: a face on the poster instead of lettering; the capital scene adds a spot that reads it (`prop.lost_poster` / `.known`).
	IconSign.attach(root, "ICON-UI-CHARACTER", Vector3(0, 2.0, 0.05), 1.1)
	var crossed: Node3D = _state_group(root, "Defaced", false)
	B.box(crossed, Vector3(1.6, 0.06, 0.02), M.flat(Color(0.75, 0.1, 0.1)), Vector3(0, 1.9, 0.06), Vector3(0, 0, 32))
	B.box(crossed, Vector3(1.6, 0.06, 0.02), M.flat(Color(0.75, 0.1, 0.1)), Vector3(0, 1.9, 0.06), Vector3(0, 0, -32))
	return root


static func complaint_box(_story: ZoneStoryText) -> Node3D:
	var root: Node3D = Node3D.new()
	B.cylinder(root, 0.07, 0.07, 0.9, M.flat(M.STONE_GRAY), Vector3(0, 0.45, 0), 6)
	B.box(root, Vector3(0.7, 0.8, 0.5), M.shiny(Color(0.35, 0.55, 0.8), 0.3), Vector3(0, 1.3, 0))
	B.box(root, Vector3(0.4, 0.05, 0.05), M.flat(Color(0.05, 0.05, 0.08)), Vector3(0, 1.55, 0.26))
	IconSign.attach(root, "ICON-TOKEN-CONTRACT", Vector3(0, 1.2, 0.27), 0.35)
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


static func stall_shack(_story: ZoneStoryText) -> Node3D:
	var root: Node3D = Node3D.new()
	B.box(root, Vector3(2.4, 2.0, 1.6), M.flat(M.WOOD_DARK), Vector3(0, 1.0, 0))
	B.box(root, Vector3(2.8, 0.14, 2.0), M.flat(Color(0.3, 0.4, 0.25)), Vector3(0, 2.1, 0.1), Vector3(-8, 0, 0))
	IconSign.attach(root, "ICON-RES-GARBAGE", Vector3(0, 1.3, 0.82), 0.7)
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


static func parlor(_story: ZoneStoryText) -> Node3D:
	var root: Node3D = Node3D.new()
	B.box(root, Vector3(3.2, 2.2, 2.6), M.flat(Color(0.56, 0.5, 0.5)), Vector3(0, 1.1, 0))
	B.box(root, Vector3(3.6, 0.3, 3.0), M.flat(M.STONE_DARK), Vector3(0, 2.35, 0))
	B.box(root, Vector3(0.7, 1.0, 0.06), M.glow(Color(1.0, 0.85, 0.5), 1.0), Vector3(0.7, 1.3, 1.32))
	B.box(root, Vector3(1.0, 0.18, 0.5), M.flat(M.PAPER), Vector3(0.7, 0.6, 1.1))
	IconSign.attach(root, "ICON-ESSENCE-N", Vector3(-0.7, 1.4, 1.34), 0.5)
	return root


static func permit_office(_story: ZoneStoryText, closed_for_good: bool) -> Node3D:
	var root: Node3D = Node3D.new()
	B.box(root, Vector3(3.0, 2.4, 2.2), M.flat(Color(0.5, 0.46, 0.38)), Vector3(0, 1.2, 0))
	B.box(root, Vector3(1.4, 0.7, 0.06), M.flat(M.SOOT), Vector3(0, 1.4, 1.12))
	B.box(root, Vector3(1.5, 0.08, 0.5), M.flat(M.WOOD), Vector3(0, 1.0, 1.3))
	for index: int in range(6):
		B.box(root, Vector3(0.3, 0.02 + 0.03 * float(index), 0.22), M.flat(M.PAPER), Vector3(-0.5 + 0.2 * float(index), 1.06, 1.3), Vector3(0, 12.0 * float(index), 0))
	IconSign.attach(root, "ICON-RES-REDTAPE", Vector3(0, 2.05, 1.14), 0.7)
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


static func paste_dispenser(_story: ZoneStoryText, freed: bool) -> Node3D:
	var root: Node3D = Node3D.new()
	B.box(root, Vector3(1.6, 2.4, 1.0), M.shiny(Color(0.62, 0.64, 0.6), 0.4), Vector3(0, 1.2, 0))
	B.box(root, Vector3(0.9, 0.5, 0.5), M.flat(Color(0.7, 0.66, 0.5)), Vector3(0, 0.55, 0.6))
	B.cylinder(root, 0.12, 0.08, 0.3, M.flat(M.STONE_DARK), Vector3(0, 1.0, 0.6), 8)
	IconSign.attach(root, "ICON-MECH-PLATE", Vector3(0, 1.9, 0.52), 0.5)
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


## The resistance camp's fire (CAP-PROP-CAMPFIRE, the kettle on its tripod over a ring of stones): the painted card, a lick of flames and the camp's
## warm, flickering light (meta "flicker", turned by `CapitalBuilder.animate`): the only warm light outside the walls.
static func campfire() -> Node3D:
	var root: Node3D = Node3D.new()
	CapitalKit.tree_card(root, "CAP-PROP-CAMPFIRE", Vector3.ZERO, 1.3)
	var flames: CPUParticles3D = CPUParticles3D.new()
	flames.name = "Flames"
	flames.amount = 18
	flames.lifetime = 0.8
	flames.preprocess = 0.8
	flames.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	flames.emission_sphere_radius = 0.18
	flames.direction = Vector3.UP
	flames.spread = 12.0
	flames.initial_velocity_min = 0.5
	flames.initial_velocity_max = 1.0
	flames.gravity = Vector3(0, 0.4, 0)
	flames.scale_amount_min = 0.6
	flames.scale_amount_max = 1.2
	var flame: SphereMesh = SphereMesh.new()
	flame.radius = 0.07
	flame.height = 0.16
	flame.radial_segments = 6
	flame.rings = 3
	flames.mesh = flame
	flames.material_override = EnvKit.glow(Color("ffa040"), 3.0)
	flames.position = Vector3(0, 0.35, 0.05)
	root.add_child(flames)
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.6, 0.3)
	light.light_energy = 3.0
	light.omni_range = 10.5
	light.position = Vector3(0, 1.0, 0)
	root.add_child(light)
	root.set_meta("flicker", light)
	return root


static func campfire_old() -> Node3D:
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


## A dead street lamp of the Gate Road: an iron post with a crooked arm and a lantern of cracked glass; lit (the Beefcakes are free) it gives a cold
## white light, Primm's, never warm (the camp keeps the only warm light outside).
static func street_lamp(lit: bool) -> Node3D:
	var root: Node3D = Node3D.new()
	var mesh: KitMesh = KitMesh.new()
	CapitalKit.materials(mesh)
	mesh.set_material("glass", EnvKit.glow(Color("dfe8f0"), 1.6) if lit else EnvKit.flat(Color("3a3c44"), "cap_lamp_dead"))
	mesh.lathe("iron_dark", Vector3.ZERO, [Vector2(0.18, 0.0), Vector2(0.14, 0.3), Vector2(0.07, 0.4)], 8, 0.8, false, false)
	mesh.tube("iron", Vector3(0, 0.3, 0), Vector3(0, 3.5, 0), 0.06, 6)
	mesh.tube("iron", Vector3(0, 3.4, 0), Vector3(0.45, 3.65, 0), 0.04, 5)
	mesh.box("iron_dark", Vector3(0.5, 3.75, 0), Vector3(0.34, 0.06, 0.34))
	mesh.box("glass", Vector3(0.5, 3.52, 0), Vector3(0.24, 0.4, 0.24))
	mesh.box("iron_dark", Vector3(0.5, 3.3, 0), Vector3(0.3, 0.05, 0.3))
	CapitalLandmarks.finish(root, mesh, [], 3.9)
	if lit:
		var light: OmniLight3D = OmniLight3D.new()
		light.light_color = Color(0.85, 0.9, 1.0)
		light.light_energy = 0.9
		light.omni_range = 7.0
		light.position = Vector3(0.5, 3.4, 0)
		root.add_child(light)
	return root


## The toppled statue by the hidden shaft (the rift fields): the rubble sheet's broken marble head of Primm, a slab of his gold-banded plinth and
## a heap of white rubble.
static func fallen_statue() -> Node3D:
	var root: Node3D = Node3D.new()
	var mesh: KitMesh = KitMesh.new()
	CapitalKit.materials(mesh)
	mesh.box("marble", Vector3(-0.6, 0.35, 0.0), Vector3(1.6, 0.7, 1.1), Basis(Vector3.UP, 0.4) * Basis(Vector3.FORWARD, 0.12), 0.06, 0.75)
	mesh.box("gold", Vector3(-0.6, 0.62, 0.0), Vector3(1.64, 0.1, 1.14), Basis(Vector3.UP, 0.4) * Basis(Vector3.FORWARD, 0.12))
	CapitalKit.card(mesh, "CAP-SHEET-RUBBLE-05", Vector3(0.5, 0.0, 0.5), 1.6, Vector3(0, 0, 1))
	CapitalKit.card(mesh, "CAP-SHEET-RUBBLE-01", Vector3(-1.2, 0.0, 0.8), 1.1, Vector3(0, 0, 1))
	return CapitalLandmarks.finish(root, mesh, [], 1.6)


## An abandoned checkpoint booth outside the walls: a shack of grey boards under a broken roof, its window boarded up (the outpost sheet).
static func checkpoint_booth() -> Node3D:
	var root: Node3D = Node3D.new()
	var mesh: KitMesh = KitMesh.new()
	CapitalKit.materials(mesh)
	mesh.box("wood_dark", Vector3(0, 1.1, 0), Vector3(1.6, 2.2, 1.4), Basis(Vector3.FORWARD, 0.04), 0.03, 0.7)
	for plank: int in range(5):
		mesh.box("wood", Vector3(-0.64 + 0.32 * float(plank), 1.1, 0.71), Vector3(0.26, 2.1, 0.03), Basis(Vector3.FORWARD, 0.04 + 0.02 * float(plank % 2)))
	mesh.quad("roof_broken", [Vector3(-1.0, 2.15, -0.9), Vector3(1.0, 2.35, -0.9), Vector3(1.0, 2.5, 0.95), Vector3(-1.0, 2.3, 0.95)], Vector3(0, 1, 0.1))
	mesh.quad("roof_broken", [Vector3(-1.0, 2.15, -0.9), Vector3(1.0, 2.35, -0.9), Vector3(1.0, 2.5, 0.95), Vector3(-1.0, 2.3, 0.95)], Vector3(0, -1, -0.1))
	CapitalKit.card(mesh, "CAP-SHEET-OUTPOST-05", Vector3(0.1, 0.9, 0.74), 0.9, Vector3(0, 0, 1))
	return CapitalLandmarks.finish(root, mesh, [], 2.6)


## A civic kiosk inside the walls (the exit interview booth): white plaster, a gold band, a mirrored window you cannot see into, a little blue
## hipped roof with a gold finial.
static func civic_kiosk(final_state: bool) -> Node3D:
	var root: Node3D = Node3D.new()
	var mesh: KitMesh = KitMesh.new()
	CapitalKit.materials(mesh, Color(0.62, 0.57, 0.5) if final_state else Color.WHITE)
	mesh.box("plaster", Vector3(0, 1.1, 0), Vector3(1.6, 2.2, 1.4), Basis.IDENTITY, 0.03, 0.82)
	mesh.box("trim", Vector3(0, 2.05, 0), Vector3(1.66, 0.22, 1.46))
	CapitalKit.arched_window(mesh, Vector3(0, 0.9, 0.71), 0.9, 1.0, Vector3(0, 0, 1), "mirror")
	CapitalCastle._hip_roof(mesh, Vector3(0, 2.2, 0), Vector2(1.9, 1.7), 0.8, "roof_blue")
	CapitalKit.finial(mesh, Vector3(0, 2.95, 0), 0.5)
	return CapitalLandmarks.finish(root, mesh, [], 3.4)


## The wreck in the camp's far corner: the rubble sheet's broken cart, and with `stack` its scattered crates beside it.
static func kit_wreck(stack: bool) -> Node3D:
	var root: Node3D = Node3D.new()
	CapitalKit.tree_card(root, "CAP-SHEET-RUBBLE-02", Vector3.ZERO, 1.7)
	if stack:
		CapitalKit.tree_card(root, "CAP-SHEET-RUBBLE-06", Vector3(-1.1, 0, 1.0), 1.2)
	return root


## One of the perfect city's identical props as the kit's painted card (the lamppost, the bench), base at the origin, facing the camera.
static func kit_card_prop(id: String, height: float) -> Node3D:
	var root: Node3D = Node3D.new()
	CapitalKit.tree_card(root, id, Vector3.ZERO, height)
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


static func shaft_door(_index: int) -> Node3D:
	var root: Node3D = Node3D.new()
	B.box(root, Vector3(1.5, 2.4, 0.2), M.shiny(M.STONE_DARK, 0.35), Vector3(0, 1.2, 0))
	B.box(root, Vector3(1.1, 2.0, 0.08), M.flat(Color(0.14, 0.14, 0.18)), Vector3(0, 1.1, 0.08))
	B.box(root, Vector3(0.4, 0.4, 0.06), M.glow(M.LANTERN, 1.2), Vector3(0, 2.05, 0.14))
	IconSign.attach(root, "ICON-MAP-TRAVEL", Vector3(0, 2.05, 0.18), 0.36)  # G-03: a pictogram, not a door number (the prompt names the destination)
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


## A cluster of tall violet rift crystals (the rift fields' stand-in for CAPO-HERO-RIFT-A / -B): five shards, 2 to 4.5 m, glowing faintly; dull
## grey glass once Primm has fallen.
## A cluster of rift crystals breaking out of scorched ground (the kit's CAP-PLANT-CRYSTAL, painted cards of mixed heights on a CAP-GROUND-RIFT patch);
## greyed and dead once Primm has fallen.
static func rift_crystals(variant: int, final_state: bool) -> Node3D:
	var root: Node3D = Node3D.new()
	var mesh: KitMesh = KitMesh.new()
	CapitalKit.materials(mesh)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 610 + variant
	var ring: Array[Vector3] = []
	for index: int in range(12):
		var angle: float = TAU * float(index) / 12.0
		ring.append(Vector3(cos(angle), 0.03, sin(angle)) * rng.randf_range(1.8, 2.4))
	for index: int in range(12):
		mesh.tri("rift_ground", [Vector3(0, 0.035, 0), ring[index], ring[(index + 1) % 12]], Vector3.UP)
	var mul: Color = Color(0.55, 0.55, 0.6) if final_state else Color.WHITE
	for shard: Vector4 in [Vector4(0.0, -0.3, 4.2, 0.0), Vector4(-1.0, 0.2, 2.8, 1.0), Vector4(1.0, 0.3, 3.2, 0.0), Vector4(0.4, 0.9, 2.0, 1.0)]:
		CapitalKit.card(mesh, "CAP-PLANT-CRYSTAL", Vector3(shard.x, 0.0, shard.y), shard.z, Vector3(0, 0, 1), shard.w > 0.5, mul)
	CapitalLandmarks.finish(root, mesh, [], 4.2)
	return root

## A headstone of Grave Row (the concept): white marble with a rounded top, a gold rim and Primm's small gold face. Broken (the Necrocrats are not free):
## it leans, unfiled paper lies at its foot and a restless ghost drifts over it; tidy (restored): upright, flowers at its foot and a calm green
## lantern glow.
static func kit_grave(variant: int, tidy: bool) -> Node3D:
	var root: Node3D = Node3D.new()
	var mesh: KitMesh = KitMesh.new()
	CapitalKit.materials(mesh)
	mesh.set_material("green_glow", EnvKit.glow(Color("8af0b0"), 1.6))
	var lean: float = 0.0 if tidy else [-0.22, 0.14, 0.28][variant % 3]
	var basis: Basis = Basis(Vector3(0, 0, 1), lean)
	mesh.box("marble_shade", Vector3(0, 0.06, 0.05), Vector3(0.8, 0.12, 0.5), Basis.IDENTITY, 0.02)
	mesh.box("marble", basis * Vector3(0, 0.5, 0), Vector3(0.6, 0.85, 0.16), basis, 0.03, 0.85)
	var top: Vector3 = basis * Vector3(0, 0.92, 0)
	for index: int in range(8):
		var a0: float = PI * float(index) / 8.0
		var a1: float = PI * float(index + 1) / 8.0
		for face: float in [-1.0, 1.0]:
			var n: Vector3 = basis * Vector3(0, 0, face)
			var off: Vector3 = basis * Vector3(0, 0, face * 0.08)
			mesh.tri("marble", [top + off, top + off + basis * Vector3(cos(a0) * 0.3, sin(a0) * 0.3, 0), top + off + basis * Vector3(cos(a1) * 0.3, sin(a1) * 0.3, 0)], n)
		var r0: Vector3 = top + basis * Vector3(cos(a0) * 0.3, sin(a0) * 0.3, 0)
		var r1: Vector3 = top + basis * Vector3(cos(a1) * 0.3, sin(a1) * 0.3, 0)
		mesh.quad("gold", [r0 + basis * Vector3(0, 0, -0.09), r1 + basis * Vector3(0, 0, -0.09), r1 + basis * Vector3(0, 0, 0.09), r0 + basis * Vector3(0, 0, 0.09)], (r0 + r1) * 0.5 - top)
	CapitalKit.emblem(mesh, basis * Vector3(0, 0.62, 0.085), 0.13, basis * Vector3(0, 0, 1))
	if tidy:
		mesh.blob("rose", Vector3(-0.18, 0.12, 0.3), Vector3(0.1, 0.08, 0.1), 3, 6)
		mesh.blob("rose_white", Vector3(0.16, 0.12, 0.32), Vector3(0.1, 0.08, 0.1), 3, 6)
		mesh.blob("green_glow", Vector3(0.36, 0.16, 0.25), Vector3(0.07, 0.09, 0.07), 3, 6)
	else:
		for paper: Vector3 in [Vector3(-0.35, 0.02, 0.45), Vector3(0.3, 0.02, 0.62)]:
			mesh.quad("paper", [paper + Vector3(-0.14, 0, -0.1), paper + Vector3(0.14, 0, -0.12), paper + Vector3(0.15, 0.01, 0.1), paper + Vector3(-0.13, 0, 0.12)], Vector3.UP)
	CapitalLandmarks.finish(root, mesh, [], 1.3)
	if not tidy and variant % 2 == 0:
		root.add_child(ghost(variant))
	return root


## A restless ghost of Grave Row's broken state: a pale mint, softly glowing wisp with a round head and a trailing tail, bobbing slowly (the "Bob"
## child turns and rises in place; `CapitalBuilder.animate` drives it).
static func ghost(variant: int) -> Node3D:
	var bob: Node3D = Node3D.new()
	bob.name = "Ghost"
	bob.set_meta("bob", true)
	bob.position = Vector3(0.2 * float(variant % 3 - 1), 1.55, 0.2)
	var mesh: KitMesh = KitMesh.new()
	var wisp: StandardMaterial3D = CapitalKit.own_glow(Color("b8ffe0"), 0.9, 0.55)
	mesh.set_material("wisp", wisp)
	mesh.blob("wisp", Vector3(0, 0.25, 0), Vector3(0.22, 0.24, 0.22), 5, 10)
	mesh.lathe("wisp", Vector3(0, -0.45, 0), [Vector2(0.02, 0.0), Vector2(0.14, 0.3), Vector2(0.22, 0.6), Vector2(0.2, 0.7)], 10, 1.0, false, false)
	for side: float in [-1.0, 1.0]:
		mesh.blob("wisp", Vector3(side * 0.2, 0.05, 0.05), Vector3(0.06, 0.12, 0.06), 3, 6)
	var node: MeshInstance3D = mesh.instance("Wisp")
	node.set_meta(&"no_occlusion_fade", true)
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	bob.add_child(node)
	return bob


## An energy wheel of the Transit Yards (the tram shed concept's giant wheel): a white rim in gold, white spokes, a gold hub on white-and-gold
## uprights on a plaster plinth. Restored (the Beefcakes are free): red-and-gold spokes and bunting, the hub glowing. The "Spin" child turns.
static func kit_energy_wheel(freed: bool) -> Node3D:
	var root: Node3D = Node3D.new()
	var mesh: KitMesh = KitMesh.new()
	CapitalKit.materials(mesh)
	mesh.box("plaster", Vector3(0, 0.12, 0), Vector3(5.6, 0.24, 2.0), Basis.IDENTITY, 0.04, 0.85)
	mesh.box("trim", Vector3(0, 0.2, 1.01), Vector3(5.6, 0.16, 0.04))
	for side: float in [-1.0, 1.0]:
		mesh.box("plaster", Vector3(0, 1.6, side * 0.8), Vector3(0.3, 3.2, 0.3), Basis.IDENTITY, 0.03)
		mesh.box("gold", Vector3(0, 3.25, side * 0.8), Vector3(0.38, 0.12, 0.38))
	mesh.box("gold", Vector3(0, 2.7, 0), Vector3(0.2, 0.2, 1.9))
	CapitalLandmarks.finish(root, mesh, [], 5.2)
	var spin: Node3D = Node3D.new()
	spin.name = "Spin"
	spin.position = Vector3(0, 2.7, 0)
	spin.set_meta("spin_speed", 0.9 if not freed else 0.25)
	root.add_child(spin)
	var wheel: KitMesh = KitMesh.new()
	CapitalKit.materials(wheel)
	var segments: int = 24
	for index: int in range(segments):
		var a0: float = TAU * float(index) / float(segments)
		var a1: float = TAU * float(index + 1) / float(segments)
		for face: float in [-0.35, 0.35]:
			wheel.quad("gold", [Vector3(cos(a0), sin(a0), 0) * 2.45 + Vector3(0, 0, face), Vector3(cos(a1), sin(a1), 0) * 2.45 + Vector3(0, 0, face), Vector3(cos(a1), sin(a1), 0) * 2.2 + Vector3(0, 0, face), Vector3(cos(a0), sin(a0), 0) * 2.2 + Vector3(0, 0, face)], Vector3(0, 0, signf(face)))
		wheel.quad("plaster", [Vector3(cos(a0), sin(a0), 0) * 2.45 + Vector3(0, 0, -0.35), Vector3(cos(a1), sin(a1), 0) * 2.45 + Vector3(0, 0, -0.35), Vector3(cos(a1), sin(a1), 0) * 2.45 + Vector3(0, 0, 0.35), Vector3(cos(a0), sin(a0), 0) * 2.45 + Vector3(0, 0, 0.35)], Vector3(cos((a0 + a1) * 0.5), sin((a0 + a1) * 0.5), 0))
	for index: int in range(8):
		var angle: float = TAU * float(index) / 8.0
		var slot: String = ("red_gold" if index % 2 == 0 else "gold") if freed else "plaster"
		wheel.box(slot, Vector3(cos(angle), sin(angle), 0) * 1.15, Vector3(2.2, 0.14, 0.14), Basis(Vector3(0, 0, 1), angle), 0.02)
	wheel.blob("gold", Vector3.ZERO, Vector3(0.38, 0.38, 0.38), 5, 10)
	if freed:
		wheel.set_material("hub_glow", EnvKit.glow(Color("ffcf70"), 1.6))
		wheel.blob("hub_glow", Vector3(0, 0, 0.32), Vector3(0.18, 0.18, 0.1), 3, 8)
	var wheel_node: MeshInstance3D = wheel.instance("Wheel")
	wheel_node.set_meta(PaintedClasses.META_NO_PAINT, true)
	spin.add_child(wheel_node)
	return root


## A power pylon of the yards: a white mast with a gold cross-arm and two insulators, lit blue once the Beefcakes are free.
static func kit_pylon(lit: bool) -> Node3D:
	var root: Node3D = Node3D.new()
	var mesh: KitMesh = KitMesh.new()
	CapitalKit.materials(mesh)
	mesh.set_material("insulator", EnvKit.glow(Color(0.5, 0.85, 1.0), 2.0) if lit else EnvKit.flat(Color(0.25, 0.25, 0.28), "cap_insulator"))
	mesh.box("plaster", Vector3(0, 2.5, 0), Vector3(0.24, 5.0, 0.24), Basis.IDENTITY, 0.02)
	mesh.box("gold", Vector3(0, 4.6, 0), Vector3(2.4, 0.16, 0.16))
	for side: float in [-1.0, 1.0]:
		mesh.blob("insulator", Vector3(side * 1.1, 4.42, 0), Vector3(0.12, 0.14, 0.12), 3, 8)
	CapitalKit.finial(mesh, Vector3(0, 5.0, 0), 0.5)
	return CapitalLandmarks.finish(root, mesh, [], 5.2)


## The yards' crates: the rubble sheet's scattered crates, stacked tidy.
static func kit_crates() -> Node3D:
	var root: Node3D = Node3D.new()
	CapitalKit.tree_card(root, "CAP-SHEET-RUBBLE-06", Vector3.ZERO, 1.3)
	return root


## Widow Pell's parlour on Grave Row: a little white-and-gold house (a blue hipped roof, an arched door, a lit window, the Necrocrats' essence on
## its gable); once the Necrocrats are free a calm green lantern by the door and roses.
static func kit_parlor(free: bool) -> Node3D:
	var root: Node3D = Node3D.new()
	var mesh: KitMesh = KitMesh.new()
	CapitalKit.materials(mesh)
	mesh.set_material("green_glow", EnvKit.glow(Color("8af0b0"), 1.8))
	mesh.box("plaster", Vector3(0, 1.1, 0), Vector3(3.2, 2.2, 2.6), Basis.IDENTITY, 0.03, 0.82)
	mesh.box("trim", Vector3(0, 2.1, 0), Vector3(3.26, 0.22, 2.66))
	CapitalCastle._hip_roof(mesh, Vector3(0, 2.2, 0), Vector2(3.6, 3.0), 1.2, "roof_blue")
	CapitalKit.arched_window(mesh, Vector3(-0.7, 0.05, 1.31), 0.8, 1.8, Vector3(0, 0, 1), "gold")
	CapitalKit.arched_window(mesh, Vector3(0.7, 0.8, 1.31), 0.7, 0.9, Vector3(0, 0, 1), "window_warm")
	if free:
		mesh.blob("green_glow", Vector3(-1.35, 1.5, 1.45), Vector3(0.12, 0.16, 0.12), 3, 8)
		CapitalKit.card(mesh, "CAP-PLANT-ROSE", Vector3(1.0, 0.0, 1.55), 0.55, Vector3(0, 0, 1))
	CapitalLandmarks.finish(root, mesh, [], 3.4)
	IconSign.attach(root, "ICON-ESSENCE-N", Vector3(0, 1.75, 1.34), 0.45)
	return root


## The permit office on Grave Row: a white civic booth with a gold band, a service window heaped with unfiled papers and Primm's red tape; closed
## for good once the Necrocrats are free (the window shuttered gold, the papers gone).
static func kit_permit_office(closed_for_good: bool) -> Node3D:
	var root: Node3D = Node3D.new()
	var mesh: KitMesh = KitMesh.new()
	CapitalKit.materials(mesh)
	mesh.box("plaster", Vector3(0, 1.2, 0), Vector3(3.0, 2.4, 2.2), Basis.IDENTITY, 0.03, 0.82)
	mesh.box("trim", Vector3(0, 2.25, 0), Vector3(3.06, 0.24, 2.26))
	CapitalCastle._hip_roof(mesh, Vector3(0, 2.4, 0), Vector2(3.3, 2.5), 0.9, "roof_blue")
	mesh.box("gold" if closed_for_good else "dark", Vector3(0, 1.4, 1.11), Vector3(1.4, 0.7, 0.04))
	mesh.box("marble_shade", Vector3(0, 1.0, 1.3), Vector3(1.5, 0.08, 0.5))
	if not closed_for_good:
		for index: int in range(6):
			mesh.box("paper", Vector3(-0.5 + 0.2 * float(index), 1.06 + 0.015 * float(index), 1.3), Vector3(0.3, 0.02 + 0.03 * float(index), 0.22), Basis(Vector3.UP, deg_to_rad(12.0 * float(index))))
	CapitalLandmarks.finish(root, mesh, [], 3.3)
	IconSign.attach(root, "ICON-RES-REDTAPE", Vector3(0, 2.0, 1.14), 0.55)
	return root


## The Pell family plot: a marble headstone in a low white kerb; Off the soil bare and the stone askew, On (laid to rest) a bed of flowers.
static func kit_family_plot() -> Node3D:
	var root: Node3D = Node3D.new()
	for state: bool in [false, true]:
		var group: Node3D = _state_group(root, "On" if state else "Off", not state)
		var mesh: KitMesh = KitMesh.new()
		CapitalKit.materials(mesh)
		for side: float in [-1.0, 1.0]:
			mesh.box("marble_shade", Vector3(side * 1.0, 0.12, 0), Vector3(0.12, 0.24, 2.2))
			mesh.box("marble_shade", Vector3(0, 0.12, side * 1.1), Vector3(2.0, 0.24, 0.12))
		mesh.box("marble", Vector3(0, 0.45, -0.9), Vector3(0.7, 0.9, 0.16), Basis(Vector3(0, 0, 1), 0.0 if state else 0.18), 0.03)
		CapitalKit.emblem(mesh, Vector3(0, 0.55, -0.81), 0.14, Vector3(0, 0, 1))
		if state:
			mesh.box("lawn", Vector3(0, 0.08, 0.2), Vector3(1.8, 0.16, 1.4))
			for index: int in range(7):
				mesh.blob(["rose", "rose_white", "wildflower", "lavender"][index % 4], Vector3(-0.7 + 0.23 * float(index), 0.24, 0.2 + 0.25 * sin(float(index) * 1.7)), Vector3(0.1, 0.08, 0.1), 3, 6)
		else:
			mesh.box("soil", Vector3(0, 0.03, 0.15), Vector3(1.8, 0.06, 1.6))
		CapitalLandmarks.finish(group, mesh, [], 1.0)
	return root


## The Reek's junk: black bags heaped against a grey bin (broken); once the Refusemancers are free, a tidy compost bin with greens and flowers
## growing from it (restored).
static func kit_junk(variant: int, tidied: bool) -> Node3D:
	var root: Node3D = Node3D.new()
	var mesh: KitMesh = KitMesh.new()
	CapitalKit.materials(mesh)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 100 + variant
	if tidied:
		mesh.box("wood", Vector3(0, 0.45, 0), Vector3(1.3, 0.9, 1.0), Basis.IDENTITY, 0.03, 0.75)
		mesh.box("compost", Vector3(0, 0.88, 0), Vector3(1.15, 0.06, 0.85))
		for slat: float in [0.2, 0.45, 0.7]:
			mesh.box("wood_dark", Vector3(0, slat, 0.51), Vector3(1.32, 0.05, 0.03))
		for index: int in range(6):
			var p: Vector3 = Vector3(rng.randf_range(-0.45, 0.45), 0.9, rng.randf_range(-0.3, 0.3))
			mesh.tube("leaf", p, p + Vector3(0, 0.35, 0), 0.02, 4)
			mesh.blob(["wildflower", "rose", "leaf", "lavender"][index % 4], p + Vector3(0, 0.4, 0), Vector3(0.1, 0.08, 0.1), 3, 6)
	else:
		mesh.box("bin", Vector3(-0.3, 0.5, -0.2), Vector3(1.0, 1.0, 0.8), Basis(Vector3.UP, 0.2), 0.04, 0.6)
		mesh.box("bin_dark", Vector3(-0.3, 1.05, -0.35), Vector3(1.05, 0.08, 0.85), Basis(Vector3.UP, 0.2) * Basis(Vector3.RIGHT, -0.4), 0.02)
		for index: int in range(7):
			mesh.blob("bag", Vector3(rng.randf_range(-0.9, 0.9), rng.randf_range(0.2, 0.9), rng.randf_range(-0.6, 0.7)), Vector3(0.38, 0.3, 0.34), 3, 8)
		CapitalKit.card(mesh, "CAP-SHEET-RUBBLE-06", Vector3(0.6, 0.0, 0.6), 0.9, Vector3(0, 0, 1))
	return CapitalLandmarks.finish(root, mesh, [], 1.4)


## One of the Reek's three banished compost heaps (a pickup): a rich dark mound in a wooden ring, a faint healthy green glow on it.
static func kit_compost_heap() -> Node3D:
	var root: Node3D = Node3D.new()
	var mesh: KitMesh = KitMesh.new()
	CapitalKit.materials(mesh)
	mesh.set_material("sprout", EnvKit.glow(Color("8ae070"), 1.1))
	mesh.lathe("compost", Vector3.ZERO, [Vector2(0.95, 0.0), Vector2(0.85, 0.3), Vector2(0.5, 0.6), Vector2(0.0, 0.7)], 12, 0.8, false, true)
	for index: int in range(8):
		var angle: float = TAU * float(index) / 8.0
		mesh.box("wood", Vector3(cos(angle), 0, sin(angle)) * 1.0 + Vector3(0, 0.18, 0), Vector3(0.12, 0.36, 0.7), Basis(Vector3.UP, -angle))
	for index: int in range(5):
		var angle: float = TAU * float(index) / 5.0
		mesh.blob("sprout", Vector3(cos(angle) * 0.45, 0.52, sin(angle) * 0.45), Vector3(0.1, 0.12, 0.1), 3, 6)
	return CapitalLandmarks.finish(root, mesh, [], 0.9)


## Old Fern's shack in the Reek: a lean-to of salvaged boards with a moss-green roof and the Refusemancers' sign; once they are free, a warm lit
## window and a flower box.
static func kit_fern_shack(free: bool) -> Node3D:
	var root: Node3D = Node3D.new()
	var mesh: KitMesh = KitMesh.new()
	CapitalKit.materials(mesh)
	mesh.box("wood", Vector3(0, 1.0, 0), Vector3(2.4, 2.0, 1.6), Basis.IDENTITY, 0.03, 0.7)
	for plank: int in range(6):
		mesh.box("wood_dark", Vector3(-1.0 + 0.4 * float(plank), 1.0, 0.81), Vector3(0.05, 1.9, 0.03))
	mesh.quad("moss", [Vector3(-1.4, 2.0, -1.0), Vector3(1.4, 2.0, -1.0), Vector3(1.4, 2.2, 1.1), Vector3(-1.4, 2.2, 1.1)], Vector3(0, 1, 0.1))
	mesh.quad("moss", [Vector3(-1.4, 2.0, -1.0), Vector3(1.4, 2.0, -1.0), Vector3(1.4, 2.2, 1.1), Vector3(-1.4, 2.2, 1.1)], Vector3(0, -1, -0.1))
	mesh.box("window_warm" if free else "dark", Vector3(0.65, 1.3, 0.82), Vector3(0.6, 0.5, 0.03))
	if free:
		for index: int in range(4):
			mesh.blob(["wildflower", "rose", "lavender", "leaf"][index], Vector3(0.45 + 0.13 * float(index), 1.0, 0.9), Vector3(0.08, 0.07, 0.06), 3, 6)
	CapitalLandmarks.finish(root, mesh, [], 2.4)
	IconSign.attach(root, "ICON-RES-GARBAGE", Vector3(-0.5, 1.3, 0.84), 0.6)
	return root


## The Hungry Quarter's paste dispenser: a white-and-gold machine with Primm's face, its nozzle over a bowl of grey uniform paste; the "On" group (the
## paste spoiled, a quest step) keeps its green slop. Once the Gourmands are free the bowl holds real colourful food.
static func kit_paste_dispenser(freed: bool) -> Node3D:
	var root: Node3D = Node3D.new()
	var mesh: KitMesh = KitMesh.new()
	CapitalKit.materials(mesh)
	mesh.box("plaster", Vector3(0, 1.2, 0), Vector3(1.6, 2.4, 1.0), Basis.IDENTITY, 0.04, 0.82)
	mesh.box("trim", Vector3(0, 2.3, 0), Vector3(1.66, 0.2, 1.06))
	mesh.box("marble_shade", Vector3(0, 0.55, 0.6), Vector3(0.9, 0.5, 0.5))
	mesh.tube("gold", Vector3(0, 1.25, 0.5), Vector3(0, 0.95, 0.6), 0.08, 8)
	CapitalKit.emblem(mesh, Vector3(0, 1.75, 0.52), 0.3, Vector3(0, 0, 1))
	mesh.lathe("marble", Vector3(0, 0.8, 0.6), [Vector2(0.16, 0.0), Vector2(0.24, 0.12)], 10, 1.0, true, false)
	if freed:
		mesh.blob("bread", Vector3(-0.06, 0.95, 0.6), Vector3(0.1, 0.06, 0.08), 3, 6)
		mesh.blob("berry", Vector3(0.08, 0.95, 0.58), Vector3(0.06, 0.06, 0.06), 3, 6)
	else:
		mesh.lathe("food_grey", Vector3(0, 0.88, 0.6), [Vector2(0.2, 0.0), Vector2(0.0, 0.06)], 10, 1.0, false, false)
	CapitalLandmarks.finish(root, mesh, [], 2.6)
	var on: Node3D = _state_group(root, "On", false)
	B.cylinder(on, 0.25, 0.25, 0.05, M.glow(Color(0.5, 1.0, 0.2), 1.4), Vector3(0, 0.05, 1.3), 10)
	B.ball(on, 0.18, M.glow(Color(0.5, 1.0, 0.2), 1.6), Vector3(0, 0.3, 1.1))
	return root


## Chef Marlo's cart: a cream cart with copper pots; once the Gourmands are free, warm loaves and a cake on it and a little steam.
static func kit_kitchen_cart(freed: bool) -> Node3D:
	var root: Node3D = Node3D.new()
	var mesh: KitMesh = KitMesh.new()
	CapitalKit.materials(mesh)
	mesh.box("cream", Vector3(0, 0.75, 0), Vector3(2.0, 0.9, 1.0), Basis.IDENTITY, 0.04, 0.8)
	mesh.box("copper", Vector3(0, 1.22, 0), Vector3(2.06, 0.06, 1.06))
	for side: float in [-1.0, 1.0]:
		mesh.lathe("wood_dark", Vector3(side * 0.85, 0.35, 0.55), [Vector2(0.35, 0.0), Vector2(0.35, 0.08)], 12, 1.0, true, true)
	mesh.lathe("copper", Vector3(-0.45, 1.25, 0), [Vector2(0.28, 0.0), Vector2(0.3, 0.35)], 12, 0.9, false, false)
	mesh.lathe("copper", Vector3(0.4, 1.25, 0), [Vector2(0.22, 0.0), Vector2(0.24, 0.28)], 12, 0.9, false, false)
	if freed:
		mesh.blob("bread", Vector3(0.75, 1.35, 0.2), Vector3(0.22, 0.12, 0.14), 4, 8)
		mesh.lathe("cake_pink", Vector3(0.75, 1.25, -0.25), [Vector2(0.18, 0.0), Vector2(0.18, 0.2), Vector2(0.0, 0.22)], 10, 1.0, false, true)
	CapitalLandmarks.finish(root, mesh, [], 1.7)
	if freed:
		B.steam(root, Vector3(-0.45, 1.65, 0), 6, 0.15, 0.7)
	return root
