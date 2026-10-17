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
			return civic_kiosk(bool(ctx.get("final", false)))
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
			return queue_post(prop.variant == 0)
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


## One of Primm's portraits on the verges: the painted face in a moulded gold frame with a crest of his emblem, on a gold easel. The "Picture" quad
## and the "Defaced" group (a moustache) are what defacing flips.
static func portrait(variant: int, defaced_when_free: bool, story: ZoneStoryText = null) -> Node3D:
	var root: Node3D = Node3D.new()
	if variant == 2 and story != null:
		return lost_poster(story)
	var mesh: KitMesh = KitMesh.new()
	CapitalKit.materials(mesh)
	var center: Vector3 = Vector3(0, 2.2, 0)
	# the frame: four bevelled gold bars with a raised inner lip, a crest on top
	for bar: Array in [[Vector3(0, 0.88, 0), Vector3(1.56, 0.16, 0.14)], [Vector3(0, -0.88, 0), Vector3(1.56, 0.16, 0.14)], [Vector3(-0.7, 0, 0), Vector3(0.16, 1.92, 0.14)], [Vector3(0.7, 0, 0), Vector3(0.16, 1.92, 0.14)]]:
		mesh.box("gold", center + (bar[0] as Vector3), bar[1] as Vector3, Basis.IDENTITY, 0.04)
	mesh.box("marble_shade", center + Vector3(0, 0, -0.05), Vector3(1.3, 1.62, 0.06))
	CapitalKit.emblem(mesh, center + Vector3(0, 1.12, 0.06), 0.2, Vector3(0, 0, 1))
	CapitalKit.finial(mesh, center + Vector3(0, 1.32, 0), 0.32)
	# the easel: two splayed front legs, a back leg, a ledge under the frame
	for side: float in [-1.0, 1.0]:
		mesh.tube("gold", Vector3(side * 0.5, 0.0, 0.22), center + Vector3(side * 0.42, 0.2, 0.0), 0.04, 6)
	mesh.tube("gold", Vector3(0, 0.0, -0.55), center + Vector3(0, 0.4, -0.08), 0.035, 6)
	mesh.box("gold", center + Vector3(0, -0.98, 0.06), Vector3(1.2, 0.06, 0.2))
	CapitalLandmarks.finish(root, mesh, [], 3.6)
	var quad: MeshInstance3D = MeshInstance3D.new()
	var picture: QuadMesh = QuadMesh.new()
	picture.size = Vector2(1.25, 1.55)
	quad.mesh = picture
	quad.material_override = M.textured(portrait_texture(variant))
	quad.position = center + Vector3(0, 0, 0.0)
	quad.name = "Picture"
	root.add_child(quad)
	var moustache: Node3D = _state_group(root, "Defaced", false)
	B.box(moustache, Vector3(0.5, 0.07, 0.02), M.flat(Color(0.05, 0.05, 0.05)), Vector3(0, 2.05, 0.03), Vector3(0, 0, 4))
	B.box(moustache, Vector3(0.3, 0.05, 0.02), M.flat(Color(0.05, 0.05, 0.05)), Vector3(-0.35, 2.4, 0.03), Vector3(0, 0, -8))
	B.box(moustache, Vector3(0.3, 0.05, 0.02), M.flat(Color(0.05, 0.05, 0.05)), Vector3(0.35, 2.4, 0.03), Vector3(0, 0, 8))
	return root


## One of the city's loudspeakers: a turned white-and-gold pole, a gold head with two flared horns, the little lamp that shows it is on (red) or
## silent (grey).
static func loudspeaker(silent: bool) -> Node3D:
	var root: Node3D = Node3D.new()
	var mesh: KitMesh = KitMesh.new()
	CapitalKit.materials(mesh)
	mesh.set_material("speaker_lamp", EnvKit.glow(Color(1.0, 0.25, 0.2), 2.4) if not silent else EnvKit.flat(Color(0.3, 0.3, 0.32), "cap_speaker_off"))
	mesh.lathe("plaster", Vector3.ZERO, [Vector2(0.22, 0.0), Vector2(0.2, 0.18), Vector2(0.1, 0.3), Vector2(0.07, 0.42)], 10, 0.85, false, false)
	mesh.tube("plaster", Vector3(0, 0.4, 0), Vector3(0, 2.95, 0), 0.06, 8)
	for y: float in [0.45, 1.6, 2.9]:
		mesh.lathe("gold", Vector3(0, y, 0), [Vector2(0.085, 0.0), Vector2(0.085, 0.06)], 8, 1.0, false, false)
	mesh.blob("gold", Vector3(0, 3.1, 0), Vector3(0.18, 0.2, 0.18), 4, 10)
	for side: float in [-1.0, 1.0]:
		_horn(mesh, "gold", Vector3(side * 0.12, 3.12, 0.04), Vector3(side * 0.82, -0.12, 0.56).normalized(), 0.62, 0.07, 0.3)
	mesh.blob("speaker_lamp", Vector3(0, 3.36, 0), Vector3(0.06, 0.06, 0.06), 3, 6)
	return CapitalLandmarks.finish(root, mesh, [], 3.5)


## A flared horn from `base` along `dir`, `length` long, its throat `r0` and its bell `r1` (a flared lathe turned onto its axis).
static func _horn(mesh: KitMesh, slot: String, base: Vector3, dir: Vector3, length: float, r0: float, r1: float) -> void:
	var side: Vector3 = dir.cross(Vector3.UP).normalized()
	if side.length() < 0.1:
		side = Vector3.RIGHT
	var up: Vector3 = side.cross(dir).normalized()
	var segments: int = 10
	var rings: Array[float] = [0.0, 0.45, 0.75, 0.92, 1.0]
	for r: int in range(rings.size() - 1):
		var t0: float = rings[r]
		var t1: float = rings[r + 1]
		var rad0: float = lerpf(r0, r1, t0 * t0)
		var rad1: float = lerpf(r0, r1, t1 * t1)
		for s: int in range(segments):
			var a0: float = TAU * float(s) / float(segments)
			var a1: float = TAU * float(s + 1) / float(segments)
			var p0: Vector3 = base + dir * length * t0
			var p1: Vector3 = base + dir * length * t1
			var d0: Vector3 = side * cos(a0) + up * sin(a0)
			var d1: Vector3 = side * cos(a1) + up * sin(a1)
			var quad: Array[Vector3] = [p0 + d0 * rad0, p0 + d1 * rad0, p1 + d1 * rad1, p1 + d0 * rad1]
			mesh.quad(slot, quad, (d0 + d1).normalized())
			mesh.quad("dark", quad, -(d0 + d1).normalized())


## A lost-property notice for the "escaped Royal Asset" (Story v2): a pinned sheet that reads like a notice about a missing umbrella. Defacing it crosses out "Asset".
static func lost_poster(_story: ZoneStoryText) -> Node3D:
	var root: Node3D = Node3D.new()
	var mesh: KitMesh = KitMesh.new()
	CapitalKit.materials(mesh)
	# a notice pinned to a white board on two gold posts, its corners curling
	for side: float in [-1.0, 1.0]:
		mesh.tube("gold", Vector3(side * 0.85, 0.0, -0.06), Vector3(side * 0.85, 3.05, -0.06), 0.05, 8)
		CapitalKit.finial(mesh, Vector3(side * 0.85, 3.05, -0.06), 0.3)
	mesh.box("plaster", Vector3(0, 1.95, -0.06), Vector3(1.7, 2.2, 0.06), Basis.IDENTITY, 0.02)
	mesh.box("gold", Vector3(0, 1.95, -0.07), Vector3(1.8, 2.3, 0.04))
	mesh.box("paper", Vector3(0, 1.95, -0.02), Vector3(1.5, 1.95, 0.02))
	for corner: Vector2 in [Vector2(-0.7, 2.85), Vector2(0.7, 2.85)]:
		mesh.blob("red_gold", Vector3(corner.x, corner.y, 0.0), Vector3(0.04, 0.04, 0.03), 3, 6)
	CapitalLandmarks.finish(root, mesh, [], 3.2)
	# G-03: a face on the poster instead of lettering; the capital scene adds a spot that reads it (`prop.lost_poster` / `.known`).
	IconSign.attach(root, "ICON-UI-CHARACTER", Vector3(0, 2.0, 0.05), 1.1)
	var crossed: Node3D = _state_group(root, "Defaced", false)
	B.box(crossed, Vector3(1.6, 0.06, 0.02), M.flat(Color(0.75, 0.1, 0.1)), Vector3(0, 1.9, 0.06), Vector3(0, 0, 32))
	B.box(crossed, Vector3(1.6, 0.06, 0.02), M.flat(Color(0.75, 0.1, 0.1)), Vector3(0, 1.9, 0.06), Vector3(0, 0, -32))
	return root


## The complaint box: a white-and-gold post box on a turned pedestal, a domed lid with a finial, a gold slot nobody reads, the contract icon on its
## front (the prompt names it).
static func complaint_box(_story: ZoneStoryText) -> Node3D:
	var root: Node3D = Node3D.new()
	var mesh: KitMesh = KitMesh.new()
	CapitalKit.materials(mesh)
	mesh.lathe("plaster", Vector3.ZERO, [Vector2(0.3, 0.0), Vector2(0.28, 0.12), Vector2(0.14, 0.24), Vector2(0.1, 0.8), Vector2(0.18, 0.9)], 10, 0.85, false, true)
	mesh.lathe("gold", Vector3(0, 0.88, 0), [Vector2(0.2, 0.0), Vector2(0.2, 0.05)], 10, 1.0, false, true)
	mesh.box("pastel_blue", Vector3(0, 1.28, 0), Vector3(0.66, 0.72, 0.48), Basis.IDENTITY, 0.06, 0.9)
	mesh.box("gold", Vector3(0, 0.95, 0), Vector3(0.72, 0.06, 0.54))
	mesh.box("gold", Vector3(0, 1.64, 0), Vector3(0.72, 0.06, 0.54))
	mesh.lathe("pastel_blue", Vector3(0, 1.66, 0), [Vector2(0.34, 0.0), Vector2(0.24, 0.14), Vector2(0.0, 0.2)], 4, 1.0, false, false)
	CapitalKit.finial(mesh, Vector3(0, 1.84, 0), 0.28)
	mesh.box("dark", Vector3(0, 1.5, 0.245), Vector3(0.38, 0.05, 0.02))
	mesh.box("gold", Vector3(0, 1.5, 0.25), Vector3(0.46, 0.11, 0.015))
	CapitalLandmarks.finish(root, mesh, [], 2.0)
	IconSign.attach(root, "ICON-TOKEN-CONTRACT", Vector3(0, 1.22, 0.255), 0.32)
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


## The Reek's sick patch: a round bed of sour soil in a low white kerb, a few dead stalks bent over ("Off"); planted ("On") it greens and flowers.
static func sick_patch() -> Node3D:
	var root: Node3D = Node3D.new()
	for planted: bool in [false, true]:
		var group: Node3D = _state_group(root, "On" if planted else "Off", not planted)
		var mesh: KitMesh = KitMesh.new()
		CapitalKit.materials(mesh)
		mesh.lathe("marble_shade", Vector3.ZERO, [Vector2(1.75, 0.0), Vector2(1.75, 0.16), Vector2(1.55, 0.18), Vector2(1.55, 0.06)], 24, 0.9, false, false)
		mesh.lathe("leaf" if planted else "soil", Vector3(0, 0.07, 0), [Vector2(1.56, 0.0), Vector2(1.2, 0.04), Vector2(0.0, 0.06)], 24, 1.0, false, false)
		var rng: RandomNumberGenerator = RandomNumberGenerator.new()
		rng.seed = 404
		for index: int in range(9 if planted else 7):
			var angle: float = TAU * float(index) / (9.0 if planted else 7.0) + rng.randf_range(-0.2, 0.2)
			var foot: Vector3 = Vector3(cos(angle), 0, sin(angle)) * rng.randf_range(0.4, 1.1) + Vector3(0, 0.1, 0)
			if planted:
				mesh.tube("leaf", foot, foot + Vector3(0, 0.6, 0), 0.025, 4)
				mesh.blob(["rose", "wildflower", "lavender"][index % 3], foot + Vector3(0, 0.66, 0), Vector3(0.11, 0.09, 0.11), 3, 6)
			else:
				var bend: Vector3 = foot + Vector3(rng.randf_range(-0.1, 0.1), 0.42, rng.randf_range(-0.1, 0.1))
				mesh.tube("wood_dark", foot, bend, 0.025, 4)
				mesh.tube("wood_dark", bend, bend + Vector3(rng.randf_range(-0.25, 0.25), -0.12, rng.randf_range(-0.25, 0.25)), 0.02, 4)
		CapitalLandmarks.finish(group, mesh, [], 0.8)
	return root


static func stall_shack(_story: ZoneStoryText) -> Node3D:
	var root: Node3D = Node3D.new()
	B.box(root, Vector3(2.4, 2.0, 1.6), M.flat(M.WOOD_DARK), Vector3(0, 1.0, 0))
	B.box(root, Vector3(2.8, 0.14, 2.0), M.flat(Color(0.3, 0.4, 0.25)), Vector3(0, 2.1, 0.1), Vector3(-8, 0, 0))
	IconSign.attach(root, "ICON-RES-GARBAGE", Vector3(0, 1.3, 0.82), 0.7)
	return root


## A manhole of the service shafts: an iron cover in a gold-edged ring, cross-hatched, and the little wrinkle scratched on it (kept off the painted
## texture binding, which drew it as brick).
static func manhole() -> Node3D:
	var root: Node3D = Node3D.new()
	var mesh: KitMesh = KitMesh.new()
	CapitalKit.materials(mesh)
	mesh.lathe("gold", Vector3(0, 0.0, 0), [Vector2(0.66, 0.0), Vector2(0.66, 0.04), Vector2(0.56, 0.06)], 20, 1.0, false, false)
	mesh.lathe("iron", Vector3(0, 0.0, 0), [Vector2(0.56, 0.06), Vector2(0.5, 0.075), Vector2(0.0, 0.08)], 20, 1.0, false, false)
	for index: int in range(5):
		var x: float = -0.36 + 0.18 * float(index)
		var half: float = sqrt(maxf(0.0, 0.46 * 0.46 - x * x))
		mesh.box("iron_dark", Vector3(x, 0.085, 0), Vector3(0.04, 0.012, half * 2.0))
		mesh.box("iron_dark", Vector3(0, 0.086, x), Vector3(half * 2.0, 0.012, 0.04))
	mesh.box("cream", Vector3(0.1, 0.095, 0.05), Vector3(0.3, 0.01, 0.03), Basis(Vector3.UP, 0.6))
	return CapitalLandmarks.finish(root, mesh, [], 0.1)


## The jar of old seed in the Reek: a glass jar with a cork, the seeds glowing faintly green inside.
static func seed_jar() -> Node3D:
	var root: Node3D = Node3D.new()
	var mesh: KitMesh = KitMesh.new()
	CapitalKit.materials(mesh)
	mesh.set_material("jar_glass", M.translucent(Color(0.8, 0.95, 0.8), 0.5, 0.2))
	mesh.set_material("seeds", EnvKit.glow(Color(0.7, 1.0, 0.5), 2.2))
	mesh.lathe("jar_glass", Vector3.ZERO, [Vector2(0.18, 0.0), Vector2(0.22, 0.08), Vector2(0.22, 0.32), Vector2(0.14, 0.4), Vector2(0.12, 0.44)], 12, 1.0, true, false)
	mesh.lathe("wood", Vector3(0, 0.42, 0), [Vector2(0.13, 0.0), Vector2(0.12, 0.1)], 10, 1.0, false, true)
	mesh.blob("seeds", Vector3(0, 0.1, 0), Vector3(0.15, 0.08, 0.15), 3, 8)
	return CapitalLandmarks.finish(root, mesh, [], 0.6)


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


## The main power cable of the yards: a thick black cable snaking over the paving between two gold junction boxes, humming with a spark ("Off");
## cut ("On") its two ends lie apart, one still spitting.
static func power_cable() -> Node3D:
	var root: Node3D = Node3D.new()
	for cut: bool in [false, true]:
		var group: Node3D = _state_group(root, "On" if cut else "Off", not cut)
		var mesh: KitMesh = KitMesh.new()
		CapitalKit.materials(mesh)
		mesh.set_material("spark", EnvKit.glow(Color(0.5, 0.8, 1.0) if cut else Color(1.0, 0.9, 0.3), 2.8))
		for side: float in [-1.0, 1.0]:
			mesh.box("plaster", Vector3(side * 1.35, 0.25, 0), Vector3(0.4, 0.5, 0.4), Basis.IDENTITY, 0.04)
			mesh.box("gold", Vector3(side * 1.35, 0.52, 0), Vector3(0.46, 0.06, 0.46))
		var points: Array[Vector3] = []
		for step: int in range(9):
			var t: float = float(step) / 8.0
			points.append(Vector3(lerpf(-1.25, 1.25, t), 0.12, sin(t * PI * 2.0) * 0.18))
		for index: int in range(points.size() - 1):
			if cut and index == 4:
				continue
			var a: Vector3 = points[index]
			var b: Vector3 = points[index + 1]
			if cut and index == 5:
				b += Vector3(0.1, 0.05, 0.3)
			mesh.tube("iron_dark", a, b, 0.09, 6)
		mesh.blob("spark", points[4] + Vector3(0, 0.2 if not cut else 0.15, 0), Vector3(0.14, 0.14, 0.14), 3, 6)
		CapitalLandmarks.finish(group, mesh, [], 0.6)
	return root



# ---- The Hungry Quarter (Gourmands) ---------------------------------------------------------------


static func paste_dispenser(_story: ZoneStoryText, freed: bool) -> Node3D:
	var root: Node3D = Node3D.new()
	B.box(root, Vector3(1.6, 2.4, 1.0), M.shiny(Color(0.62, 0.64, 0.6), 0.4), Vector3(0, 1.2, 0))
	B.box(root, Vector3(0.9, 0.5, 0.5), M.flat(Color(0.7, 0.66, 0.5)), Vector3(0, 0.55, 0.6))
	B.cylinder(root, 0.12, 0.08, 0.3, M.flat(M.STONE_DARK), Vector3(0, 1.0, 0.6), 8)
	IconSign.attach(root, "ICON-MECH-PLATE", Vector3(0, 1.9, 0.52), 0.5)
	var on: Node3D = _state_group(root, "On", false)
	var slop: KitMesh = KitMesh.new()
	slop.set_material("slop", EnvKit.glow(Color(0.5, 1.0, 0.2), 1.4))
	slop.lathe("slop", Vector3(0, 0.02, 1.25), [Vector2(0.42, 0.0), Vector2(0.3, 0.05), Vector2(0.0, 0.07)], 12, 1.0, false, false)
	slop.blob("slop", Vector3(0, 0.95, 0.62), Vector3(0.1, 0.16, 0.1), 3, 6)
	CapitalLandmarks.finish(on, slop, [], 1.0)
	return root


static func kitchen_cart() -> Node3D:
	var root: Node3D = Node3D.new()
	B.box(root, Vector3(2.0, 0.9, 1.0), M.flat(M.WOOD), Vector3(0, 0.75, 0))
	for side: float in [-1.0, 1.0]:
		B.cylinder(root, 0.35, 0.35, 0.1, M.flat(M.WOOD_DARK), Vector3(side * 0.85, 0.35, 0.55), 12).rotation_degrees.x = 90.0
	B.cylinder(root, 0.3, 0.3, 0.4, M.shiny(M.METAL, 0.3), Vector3(-0.4, 1.4, 0), 10)
	B.cylinder(root, 0.25, 0.25, 0.3, M.shiny(M.METAL, 0.3), Vector3(0.4, 1.35, 0), 10)
	return root


## One of Chef Marlo's hidden recipe cards (a pickup): a stained card propped against a little crock, a faint gold glint over it.
static func recipe_card() -> Node3D:
	var root: Node3D = Node3D.new()
	var mesh: KitMesh = KitMesh.new()
	CapitalKit.materials(mesh)
	mesh.set_material("glint", EnvKit.glow(Color("ffd870"), 2.4))
	mesh.lathe("copper", Vector3(0.12, 0, -0.05), [Vector2(0.12, 0.0), Vector2(0.15, 0.12), Vector2(0.12, 0.26), Vector2(0.14, 0.3)], 10, 0.85, true, false)
	mesh.box("paper", Vector3(-0.08, 0.2, 0.06), Vector3(0.36, 0.48, 0.015), Basis(Vector3.RIGHT, -0.35) * Basis(Vector3.UP, 0.2), 0.0)
	mesh.box("compost", Vector3(-0.1, 0.24, 0.075), Vector3(0.12, 0.1, 0.005), Basis(Vector3.RIGHT, -0.35) * Basis(Vector3.UP, 0.2), 0.0)
	mesh.blob("glint", Vector3(0, 0.62, 0), Vector3(0.06, 0.06, 0.06), 3, 6)
	return CapitalLandmarks.finish(root, mesh, [], 0.7)


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


## A bed of the Correction Ward (and the Crease's cots): a white iron frame with rounded head and foot rails, a tight white mattress, a pillow, a
## grey blanket folded exactly square.
static func bed() -> Node3D:
	var root: Node3D = Node3D.new()
	var mesh: KitMesh = KitMesh.new()
	CapitalKit.materials(mesh)
	var half_w: float = 0.5
	var half_l: float = 0.98
	for end: Array in [[-half_l, 1.05], [half_l, 0.8]]:
		var z: float = float(end[0])
		var top: float = float(end[1])
		for side: float in [-1.0, 1.0]:
			mesh.tube("plaster", Vector3(side * half_w, 0.0, z), Vector3(side * half_w, top, z), 0.04, 6)
			CapitalKit.finial(mesh, Vector3(side * half_w, top, z), 0.12)
		mesh.tube("plaster", Vector3(-half_w, top - 0.04, z), Vector3(half_w, top - 0.04, z), 0.035, 6)
		mesh.tube("plaster", Vector3(-half_w, 0.5, z), Vector3(half_w, 0.5, z), 0.03, 6)
		for bar: int in range(3):
			var x: float = -0.25 + 0.25 * float(bar)
			mesh.tube("plaster", Vector3(x, 0.5, z), Vector3(x, top - 0.04, z), 0.018, 4)
	for side: float in [-1.0, 1.0]:
		mesh.tube("plaster", Vector3(side * half_w, 0.42, -half_l), Vector3(side * half_w, 0.42, half_l), 0.035, 6)
	mesh.box("marble", Vector3(0, 0.52, 0), Vector3(0.94, 0.18, 1.86), Basis.IDENTITY, 0.06, 0.9)
	mesh.blob("rose_white", Vector3(0, 0.66, -0.7), Vector3(0.32, 0.08, 0.16), 3, 8)
	mesh.box("food_grey", Vector3(0, 0.63, 0.45), Vector3(0.96, 0.05, 0.7), Basis.IDENTITY, 0.02)
	return CapitalLandmarks.finish(root, mesh, [], 1.1)


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


## A dead street lamp of the Gate Road: a turned iron post on a stepped foot, a curled arm and a cage lantern of cracked glass hanging from it; lit
## (the Beefcakes are free) it gives a cold white light, Primm's, never warm (the camp keeps the only warm light outside).
static func street_lamp(lit: bool) -> Node3D:
	var root: Node3D = Node3D.new()
	var mesh: KitMesh = KitMesh.new()
	CapitalKit.materials(mesh)
	mesh.set_material("glass", EnvKit.glow(Color("dfe8f0"), 1.6) if lit else EnvKit.flat(Color("3a3c44"), "cap_lamp_dead"))
	mesh.lathe("iron_dark", Vector3.ZERO, [Vector2(0.24, 0.0), Vector2(0.24, 0.12), Vector2(0.17, 0.2), Vector2(0.15, 0.42), Vector2(0.09, 0.55), Vector2(0.075, 0.7)], 10, 0.8, false, false)
	mesh.lathe("iron", Vector3(0, 0.7, 0), [Vector2(0.06, 0.0), Vector2(0.05, 2.5), Vector2(0.08, 2.6), Vector2(0.08, 2.7), Vector2(0.05, 2.8), Vector2(0.045, 3.0)], 8, 1.0, false, true)
	CapitalKit.finial(mesh, Vector3(0, 3.68, 0), 0.32)
	# the curled arm out to the lantern and a scroll under it
	var previous: Vector3 = Vector3(0, 3.55, 0)
	for step: int in range(1, 7):
		var t: float = float(step) / 6.0
		var point: Vector3 = Vector3(sin(t * PI * 0.5) * 0.62, 3.55 + sin(t * PI) * 0.2, 0)
		mesh.tube("iron", previous, point, 0.035, 5)
		previous = point
	var scroll: Vector3 = Vector3(0, 3.25, 0)
	for step: int in range(1, 6):
		var t: float = float(step) / 5.0
		var point: Vector3 = Vector3(t * 0.42, 3.25 + t * t * 0.3, 0)
		mesh.tube("iron", scroll, point, 0.022, 4)
		scroll = point
	# the cage lantern: a cap, four bars round the glass, a drop
	var lantern: Vector3 = Vector3(0.62, 3.2, 0)
	mesh.tube("iron", Vector3(0.62, 3.56, 0), lantern + Vector3(0, 0.34, 0), 0.02, 4)
	mesh.lathe("iron_dark", lantern + Vector3(0, 0.2, 0), [Vector2(0.21, 0.0), Vector2(0.05, 0.16)], 4, 1.0, true, true)
	mesh.box("glass", lantern, Vector3(0.24, 0.36, 0.24))
	for corner: Vector2 in [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]:
		mesh.box("iron_dark", lantern + Vector3(corner.x * 0.13, 0, corner.y * 0.13), Vector3(0.035, 0.42, 0.035))
	mesh.lathe("iron_dark", lantern - Vector3(0, 0.26, 0), [Vector2(0.0, 0.0), Vector2(0.15, 0.06)], 4, 1.0, false, true)
	CapitalLandmarks.finish(root, mesh, [], 3.9)
	if lit:
		var light: OmniLight3D = OmniLight3D.new()
		light.light_color = Color(0.85, 0.9, 1.0)
		light.light_energy = 0.9
		light.omni_range = 7.0
		light.position = lantern
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
## Plank walls round a `w` x `d` footprint, `h` tall: vertical boards of two shades on each face (`skip` leaves a gap on the +x face at that board, -1 for
## none), corner posts, a stone footing. Shared by the checkpoints and Fern's shack.
static func plank_walls(mesh: KitMesh, w: float, d: float, h: float, lean: Basis, skip: int) -> void:
	mesh.box("ash_flat", Vector3(0, 0.08, 0), Vector3(w + 0.2, 0.16, d + 0.2), Basis.IDENTITY, 0.04, 0.7)
	for face: Array in [[Vector3(0, 0, 1), w], [Vector3(0, 0, -1), w], [Vector3(1, 0, 0), d], [Vector3(-1, 0, 0), d]]:
		var normal: Vector3 = face[0] as Vector3
		var span: float = float(face[1])
		var along: Vector3 = Vector3(-normal.z, 0, normal.x)
		var reach: float = (d if normal.x == 0.0 else w) * 0.5
		var boards: int = int(span / 0.24)
		for index: int in range(boards):
			if normal.x > 0.0 and index == skip:
				continue
			var off: float = -span * 0.5 + (float(index) + 0.5) * span / float(boards)
			var height: float = h - 0.06 * float(index % 3)
			var slot: String = "wood" if index % 2 == 0 else "wood_dark"
			mesh.box(slot, normal * reach + along * off + Vector3(0, 0.16 + height * 0.5, 0), (Vector3(span / float(boards) - 0.02, height, 0.05) if normal.x == 0.0 else Vector3(0.05, height, span / float(boards) - 0.02)), lean, 0.0, 0.75)
	for corner: Vector2 in [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]:
		mesh.box("wood_dark", Vector3(corner.x * (w * 0.5 + 0.02), 0.16 + h * 0.5, corner.y * (d * 0.5 + 0.02)), Vector3(0.12, h + 0.1, 0.12), lean, 0.02)


## An abandoned checkpoint outside the walls: a plank shack on corner posts and a stone footing, a gabled roof of broken shingles with one corner
## caved in, a boarded window (the outpost sheet), a counter flap hanging off its hinge.
static func checkpoint_booth() -> Node3D:
	var root: Node3D = Node3D.new()
	var mesh: KitMesh = KitMesh.new()
	CapitalKit.materials(mesh)
	var w: float = 1.7
	var d: float = 1.5
	var h: float = 2.15
	var lean: Basis = Basis(Vector3.FORWARD, 0.035)
	plank_walls(mesh, w, d, h, lean, 2)
	# the gable roof, its right-front corner caved in
	var eave: float = h + 0.16
	var ridge: Vector3 = Vector3(0, eave + 0.75, 0)
	for side: float in [-1.0, 1.0]:
		var far: Vector3 = Vector3(side * (w * 0.5 + 0.25), eave - 0.08, 0)
		var dip: float = 0.35 if side > 0.0 else 0.0
		var corners: Array[Vector3] = [Vector3(far.x, far.y - dip, d * 0.5 + 0.3), Vector3(far.x, far.y, -d * 0.5 - 0.3), ridge + Vector3(0, 0, -d * 0.5 - 0.3), ridge + Vector3(0, -dip * 0.4, d * 0.5 + 0.3)]
		mesh.quad("roof_broken", corners, Vector3(side, 1.2, 0))
		mesh.quad("roof_broken", corners, Vector3(-side, -1.2, 0))
	for end: float in [-1.0, 1.0]:
		mesh.tri("wood_dark", [Vector3(-w * 0.5, eave, end * d * 0.5), Vector3(w * 0.5, eave, end * d * 0.5), ridge + Vector3(0, -0.05, end * d * 0.5)], Vector3(0, 0, end))
	mesh.tube("wood_dark", ridge + Vector3(0, 0.04, -d * 0.5 - 0.35), ridge + Vector3(0, -0.1, d * 0.5 + 0.35), 0.06, 5)
	# the boarded window and the hanging counter flap on the front
	CapitalKit.card(mesh, "CAP-SHEET-OUTPOST-05", Vector3(0.1, 0.95, d * 0.5 + 0.06), 0.85, Vector3(0, 0, 1))
	mesh.box("wood", Vector3(0.1, 0.75, d * 0.5 + 0.22), Vector3(0.9, 0.05, 0.36), Basis(Vector3.RIGHT, -0.5) * Basis(Vector3.FORWARD, 0.25), 0.01)
	return CapitalLandmarks.finish(root, mesh, [], 3.1)


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


## A post of the Gate Road's rope queue: a turned gold post on a round foot, a ball on top, and (`rope`) a velvet rope sagging to the next post 2 m
## along the kerb (+z, the line of the queue).
static func queue_post(rope: bool = true) -> Node3D:
	var root: Node3D = Node3D.new()
	var mesh: KitMesh = KitMesh.new()
	CapitalKit.materials(mesh)
	mesh.set_material("velvet", EnvKit.flat(Color(0.62, 0.1, 0.16), "cap_velvet"))
	mesh.lathe("gold", Vector3.ZERO, [Vector2(0.2, 0.0), Vector2(0.2, 0.05), Vector2(0.08, 0.12), Vector2(0.05, 0.9), Vector2(0.08, 0.95)], 10, 0.9, false, true)
	mesh.blob("gold", Vector3(0, 1.03, 0), Vector3(0.09, 0.09, 0.09), 4, 8)
	if rope:
		var previous: Vector3 = Vector3(0, 0.88, 0.08)
		for step: int in range(1, 9):
			var t: float = float(step) / 8.0
			var point: Vector3 = Vector3(0, 0.88 - 0.22 * sin(t * PI), lerpf(0.08, 1.92, t))
			mesh.tube("velvet", previous, point, 0.025, 5)
			previous = point
	return CapitalLandmarks.finish(root, mesh, [], 1.1)


## The hidden service shaft's cover in the rift fields: a cracked slab of the old road heaved up over the hole with rubble against it ("Off"); found
## ("On"), the slab pushed aside and the dark hole open.
static func hatch_cover() -> Node3D:
	var root: Node3D = Node3D.new()
	for open: bool in [false, true]:
		var group: Node3D = _state_group(root, "On" if open else "Off", not open)
		var mesh: KitMesh = KitMesh.new()
		CapitalKit.materials(mesh)
		if open:
			mesh.lathe("dark", Vector3(0, 0.03, 0), [Vector2(0.62, 0.0), Vector2(0.0, 0.0)], 12, 1.0, false, false)
			mesh.lathe("ash_flat", Vector3(0, 0.0, 0), [Vector2(0.75, 0.0), Vector2(0.7, 0.08), Vector2(0.62, 0.04)], 12, 0.9, false, false)
			mesh.box("ash", Vector3(1.1, 0.1, 0.1), Vector3(1.3, 0.2, 1.0), Basis(Vector3.UP, 0.7) * Basis(Vector3.FORWARD, 0.12), 0.05, 0.75)
		else:
			mesh.box("ash", Vector3(0, 0.16, 0), Vector3(1.4, 0.24, 1.1), Basis(Vector3.UP, 0.3) * Basis(Vector3.FORWARD, 0.08), 0.06, 0.75)
			CapitalKit.card(mesh, "CAP-SHEET-RUBBLE-01", Vector3(0.6, 0.0, 0.45), 0.9, Vector3(0, 0, 1))
		CapitalLandmarks.finish(group, mesh, [], 0.6)
	return root


## The height inspector's measuring post: a turned white post with black marks every hand, a gold cap and the red bar at the regulation height.
static func height_post() -> Node3D:
	var root: Node3D = Node3D.new()
	var mesh: KitMesh = KitMesh.new()
	CapitalKit.materials(mesh)
	mesh.set_material("red_bar", EnvKit.glow(Color(1.0, 0.2, 0.2), 1.6))
	mesh.lathe("marble_shade", Vector3.ZERO, [Vector2(0.24, 0.0), Vector2(0.22, 0.1), Vector2(0.1, 0.2)], 10, 0.85, false, false)
	mesh.box("plaster", Vector3(0, 1.25, 0), Vector3(0.18, 2.3, 0.14), Basis.IDENTITY, 0.03)
	for index: int in range(12):
		mesh.box("iron_dark", Vector3(0.0, 0.32 + 0.18 * float(index), 0.072), Vector3(0.24 if index % 3 == 0 else 0.14, 0.025, 0.01))
	mesh.box("gold", Vector3(0, 2.42, 0), Vector3(0.24, 0.06, 0.2))
	CapitalKit.finial(mesh, Vector3(0, 2.45, 0), 0.24)
	mesh.box("red_bar", Vector3(0.05, 1.85, 0.0), Vector3(0.46, 0.08, 0.1), Basis.IDENTITY, 0.02)
	return CapitalLandmarks.finish(root, mesh, [], 2.7)


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
	# salvaged boards of every shade on corner posts, a lean-to roof of mossy planks sloping to the back, a stovepipe
	plank_walls(mesh, 2.4, 1.6, 2.0, Basis(Vector3.FORWARD, -0.02), -1)
	for step: int in range(4):
		var z0: float = 1.05 - 2.1 * float(step) / 4.0
		var z1: float = 1.05 - 2.1 * float(step + 1) / 4.0
		var y0: float = 2.25 - 0.4 * float(step) / 4.0
		var y1: float = 2.25 - 0.4 * float(step + 1) / 4.0
		var strip: Array[Vector3] = [Vector3(-1.45, y0, z0), Vector3(1.45, y0, z0), Vector3(1.45, y1, z1), Vector3(-1.45, y1, z1)]
		mesh.quad("moss" if step % 2 == 0 else "wood_dark", strip, Vector3(0, 1, 0.2))
		mesh.quad("wood_dark", strip, Vector3(0, -1, -0.2))
	mesh.tube("iron_dark", Vector3(0.85, 1.9, -0.5), Vector3(0.85, 2.85, -0.5), 0.09, 8)
	mesh.lathe("iron_dark", Vector3(0.85, 2.85, -0.5), [Vector2(0.16, 0.0), Vector2(0.0, 0.12)], 8, 1.0, true, false)
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
	# the machine: a plinth, a rounded body with gold bands, a domed top under a hopper, pipes down its sides, a dial
	mesh.box("marble_shade", Vector3(0, 0.12, 0), Vector3(1.8, 0.24, 1.2), Basis.IDENTITY, 0.05, 0.8)
	mesh.box("plaster", Vector3(0, 1.2, 0), Vector3(1.5, 1.95, 0.95), Basis.IDENTITY, 0.18, 0.84)
	for y: float in [0.45, 1.9]:
		mesh.box("trim", Vector3(0, y, 0), Vector3(1.56, 0.14, 1.0), Basis.IDENTITY, 0.05)
	mesh.lathe("plaster", Vector3(0, 2.15, 0), [Vector2(0.62, 0.0), Vector2(0.5, 0.3), Vector2(0.22, 0.48)], 14, 1.0, false, false)
	mesh.lathe("gold", Vector3(0, 2.6, 0), [Vector2(0.16, 0.0), Vector2(0.3, 0.32), Vector2(0.32, 0.38)], 10, 1.0, false, false)
	for side: float in [-1.0, 1.0]:
		mesh.tube("gold", Vector3(side * 0.82, 0.3, 0.1), Vector3(side * 0.82, 2.0, 0.1), 0.06, 6)
		mesh.tube("gold", Vector3(side * 0.82, 2.0, 0.1), Vector3(side * 0.5, 2.35, 0.1), 0.06, 6)
	mesh.lathe("gold", Vector3(0.45, 1.25, 0.47), [Vector2(0.14, 0.0), Vector2(0.14, 0.04)], 10, 1.0, false, true)
	mesh.box("marble_shade", Vector3(0, 0.55, 0.6), Vector3(0.9, 0.5, 0.5), Basis.IDENTITY, 0.06)
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
	var slop: KitMesh = KitMesh.new()
	slop.set_material("slop", EnvKit.glow(Color(0.5, 1.0, 0.2), 1.4))
	slop.lathe("slop", Vector3(0, 0.02, 1.25), [Vector2(0.42, 0.0), Vector2(0.3, 0.05), Vector2(0.0, 0.07)], 12, 1.0, false, false)
	slop.blob("slop", Vector3(0, 0.95, 0.62), Vector3(0.1, 0.16, 0.1), 3, 6)
	CapitalLandmarks.finish(on, slop, [], 1.0)
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
