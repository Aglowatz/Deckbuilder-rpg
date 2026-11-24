class_name TownShuffleHouse
extends RefCounted
## The Shuffle House, Octavia Eightfold's draft arena in Crosspath (Fable big pass Nov 23; rebuilt and moved Nov 24).
## Fable Nov 24 (Part 1): it stands in the open lawn of Crosspath's back-right (north-east) corner now, further right and further
## back than the corner plot behind Pip's, and it is a real building: the painted TOWN-HERO-SHUFFLEHOUSE (Batch 20) stays its
## face, and behind that face stands the back half of the round house itself - a stone plinth, a half-timbered drum, the striped
## big top with its gold eave, the two little turrets - so it has depth, sides and a roof with volume from every camera preset.
## Under the face: a stone foundation wall that carries the painted plinth down to the grass at its sides (the painting's base is
## drawn from above, so its sides hung in the air), a soft contact shadow under the whole footprint, and the cobbled door path
## running right up to the painted steps - so it sits on the ground instead of floating over the grass.
## The house is taller than it was (12 m; it was 10.2): from the fountain its big top and flags stand clear over the shop roofs.
## The hanging sign (TOWN-SIGN-SHUFFLEHOUSE) stays where the door path leaves the square; a second one hangs at the lawn's edge.
## It is there from the start; it opens when all four zone drafts are won or three zones are freed (`DraftArena.is_open`).

const KEY: String = "shuffle_house"
const PAINTED: String = "TOWN-HERO-SHUFFLEHOUSE"
const SIGN: String = "TOWN-SIGN-SHUFFLEHOUSE"
## The painted front: its base line (the building's middle on the ground) and its height (the art is 3:4).
const CENTER: Vector3 = Vector3(47.4, 0.0, -11.4)
const HEIGHT: float = 12.0
const WIDTH: float = 8.94
## The footprint that keeps lamps, plants and props out (width x depth), and how far in front of the centre the door spot is.
const FOOTPRINT: Vector2 = Vector2(10.4, 10.4)
const DOOR: float = 2.7
## Where Octavia stands when the house is open: beside the steps, on the apron.
const HOST_OFFSET: Vector3 = Vector3(2.7, 0.0, 2.3)
## The sign posts: where the door path leaves the square's rim, and where it reaches the lawn.
const SIGN_POST: Vector3 = Vector3(37.2, 0.0, -0.1)
const SIGN_POST_LAWN: Vector3 = Vector3(43.7, 0.0, -3.2)
const SIGN_HEIGHT: float = 3.4
const SIGN_WIDTH: float = 1.9
## The paved path from the square to the door.
const PATH: Array[Vector3] = [Vector3(33.6, 0.0, 4.0), Vector3(37.6, 0.0, 1.1), Vector3(40.6, 0.0, -2.4), Vector3(44.2, 0.0, -5.6), Vector3(47.0, 0.0, -7.8), Vector3(47.4, 0.0, -10.5)]
## The hedge that closes the east side of the Secret Dealer's alley now that the row house is gone: from / to along x = HEDGE_X.
const HEDGE_X: float = 37.25
const HEDGE_Z: Array[float] = [-5.0, -2.0]

## The real body behind the painted face, in fractions of the painting (WIDTH for radii, HEIGHT for heights), read off the art.
const PLINTH_RADIUS: float = 0.5
const PLINTH_TOP: float = 0.13
const WALL_RADIUS: float = 0.415
const EAVE_HEIGHT: float = 0.535
const EAVE_RADIUS: float = 0.5
const APEX_HEIGHT: float = 0.775
const TURRET_X: float = 0.31
const TURRET_RADIUS: float = 0.075
const TURRET_EAVE: float = 0.635
const TURRET_APEX: float = 0.79
const SEGMENTS: int = 12
const STONE: Color = Color("b9a583")
const STONE_DARK: Color = Color("93825f")
const CREAM: Color = Color("e9cf98")
const TIMBER: Color = Color("6b4428")
const GOLD: Color = Color("e2b44a")
const STRIPES: Array[Color] = [Color("c8372d"), Color("3f5fae"), Color("c8372d"), Color("5d8f3a"), Color("c8372d"), Color("7a4a9e")]


static func door_spot() -> Vector3:
	return CENTER + Vector3(0.0, 0.0, DOOR)


static func host_spot() -> Vector3:
	return CENTER + HOST_OFFSET


## The open lawn in front of and around the house: no tree of the old map stands here, so the house is seen from the square
## (through the corner between Fenwick's and Pip's) and from the door path. The trees east and north of it stay as its backdrop.
static func in_forecourt(pos: Vector3) -> bool:
	return pos.x > 37.6 and pos.x < CENTER.x + 7.0 and pos.z > CENTER.z - 5.5 and pos.z < 3.2


## Builds the house and its signs under `root` and adds their collision circles to `obstacles` (Vector3(x, z, radius)).
static func build(root: Node3D, obstacles: Array[Vector3]) -> Node3D:
	var holder: Node3D = Node3D.new()
	holder.name = "ShuffleHouse"
	root.add_child(holder)
	_ground(holder)
	_body(holder)
	var painted: Node3D = KitPieces.stand(holder, PAINTED, CENTER, HEIGHT, true, 1.05)
	holder.set_meta(&"painted", painted != null)
	if painted == null:
		# the art is not imported: a plain striped block stands in for the face so the place is still there
		var block: MeshInstance3D = MeshInstance3D.new()
		var box: BoxMesh = BoxMesh.new()
		box.size = Vector3(WIDTH * 0.8, HEIGHT * EAVE_HEIGHT, 0.4)
		block.mesh = box
		block.material_override = EnvKit.flat(Color("a8323c"), "cloth")
		block.position = CENTER + Vector3(0.0, HEIGHT * EAVE_HEIGHT * 0.5, 0.0)
		holder.add_child(block)
	# solid: the face is a wall as wide as the painting, and the round body stands behind it
	var count: int = 5
	for index: int in range(count):
		var x: float = CENTER.x - WIDTH * 0.5 + WIDTH * (float(index) + 0.5) / float(count)
		obstacles.append(Vector3(x, CENTER.z - 0.6, WIDTH / float(count) * 0.62))
	var radius: float = WIDTH * PLINTH_RADIUS
	obstacles.append(Vector3(CENTER.x, CENTER.z - radius * 0.5, radius * 0.72))
	obstacles.append(Vector3(CENTER.x - radius * 0.62, CENTER.z - radius * 0.42, radius * 0.42))
	obstacles.append(Vector3(CENTER.x + radius * 0.62, CENTER.z - radius * 0.42, radius * 0.42))
	_sign(holder, obstacles, SIGN_POST, "SignPost", "ShuffleHouseSign")
	_sign(holder, obstacles, SIGN_POST_LAWN, "SignPostLawn", "ShuffleHouseSignLawn")
	# the alley keeps its east side: two lengths of hedge where the row house's wall stood
	for z: float in HEDGE_Z:
		var hedge: Node3D = PropKit.make("hedge", 3.2, int(absf(z) * 10.0))
		ModelKit.place(holder, hedge, Vector3(HEDGE_X, 0.0, z), 90.0, 1.0)
		for step: float in [-1.1, 0.0, 1.1]:
			obstacles.append(Vector3(HEDGE_X, z + step, 0.55))
	# a warm pool of light on the landing and the marquee's glow on the front
	var glow: OmniLight3D = OmniLight3D.new()
	glow.name = "MarqueeGlow"
	glow.light_color = Color("ffc56a")
	glow.light_energy = 1.2
	glow.omni_range = 7.5
	glow.position = CENTER + Vector3(0.0, 3.6, 2.8)
	holder.add_child(glow)
	return holder


# ---- The ground under it: the contact shadow, the paved apron, the landing and its step ------------------------------------------


static func _ground(holder: Node3D) -> void:
	var radius: float = WIDTH * PLINTH_RADIUS
	# a soft dark pool under the whole footprint (the house's weight on the grass), a little forward of the face
	var shade: MeshInstance3D = MeshInstance3D.new()
	shade.name = "ContactShadow"
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2(radius * 3.1, radius * 2.9)
	quad.orientation = PlaneMesh.FACE_Y
	shade.mesh = quad
	var gradient: Gradient = Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.55, 1.0])
	gradient.colors = PackedColorArray([Color(0.05, 0.03, 0.08, 0.62), Color(0.05, 0.03, 0.08, 0.4), Color(0.05, 0.03, 0.08, 0.0)])
	var blob: GradientTexture2D = GradientTexture2D.new()
	blob.gradient = gradient
	blob.fill = GradientTexture2D.FILL_RADIAL
	blob.fill_from = Vector2(0.5, 0.5)
	blob.fill_to = Vector2(0.5, 0.0)
	blob.width = 128
	blob.height = 128
	var shade_material: StandardMaterial3D = StandardMaterial3D.new()
	shade_material.albedo_texture = blob
	shade_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	shade_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	shade_material.set_meta(PaintedClasses.META_NO_PAINT, true)
	shade.material_override = shade_material
	shade.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	shade.position = CENTER + Vector3(0.0, 0.035, -radius * 0.45)
	shade.set_meta(&"no_occlusion_fade", true)
	holder.add_child(shade)
	# a second, tighter shadow along the foot of the face
	var foot: MeshInstance3D = shade.duplicate() as MeshInstance3D
	foot.name = "FootShadow"
	var foot_quad: QuadMesh = QuadMesh.new()
	foot_quad.size = Vector2(WIDTH * 1.25, 2.6)
	foot_quad.orientation = PlaneMesh.FACE_Y
	foot.mesh = foot_quad
	foot.position = CENTER + Vector3(0.0, 0.04, 0.35)
	holder.add_child(foot)
	# the foundation: stone courses right behind the face, from the grass up to the painted plinth (seen only where the painting
	# is clear: under the plinth's raised sides)
	var wall: SurfaceTool = SurfaceTool.new()
	wall.begin(Mesh.PRIMITIVE_TRIANGLES)
	var half: float = WIDTH * 0.47
	var courses: Array[float] = [0.0, 0.55, 1.15, HEIGHT * 0.2]
	var tones: Array[Color] = [STONE_DARK.darkened(0.18), STONE_DARK, STONE_DARK.lightened(0.12)]
	for course: int in range(courses.size() - 1):
		var low: float = courses[course]
		var high: float = courses[course + 1]
		for corner: Vector3 in [Vector3(-half, low, 0.0), Vector3(-half, high, 0.0), Vector3(half, low, 0.0), Vector3(half, low, 0.0), Vector3(-half, high, 0.0), Vector3(half, high, 0.0)]:
			wall.set_color(tones[course].srgb_to_linear())
			wall.set_normal(Vector3(0.0, 0.0, 1.0))
			wall.add_vertex(corner)
	var foundation: MeshInstance3D = _solid(holder, "Foundation", wall.commit(), "stone", false)
	foundation.position += Vector3(0.0, 0.0, -0.07)
	# the face is a painting with its own light: its foundation takes no sun shadow either (in shade it read as a dark slab)
	var stone: StandardMaterial3D = StandardMaterial3D.new()
	stone.vertex_color_use_as_albedo = true
	stone.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	stone.albedo_color = Color(0.86, 0.8, 0.74)
	stone.set_meta(PaintedClasses.META_NO_PAINT, true)
	foundation.material_override = stone


# ---- The body behind the painted face ---------------------------------------------------------------------------------------------


static func _body(holder: Node3D) -> void:
	var plinth_radius: float = WIDTH * PLINTH_RADIUS
	var plinth_top: float = HEIGHT * PLINTH_TOP
	var wall_radius: float = WIDTH * WALL_RADIUS
	var eave: float = HEIGHT * EAVE_HEIGHT
	var eave_radius: float = WIDTH * EAVE_RADIUS
	var apex: float = HEIGHT * APEX_HEIGHT
	# the back half of the stone plinth, the drum of the house on it (a timber band under the eave and one at the floor)
	_solid(holder, "Plinth", _lathe([Vector2(plinth_radius, 0.0), Vector2(plinth_radius, plinth_top), Vector2(0.0, plinth_top)], [STONE_DARK, STONE], 0.0, PI, SEGMENTS), "stone", true)
	_solid(holder, "Walls", _lathe([Vector2(wall_radius, plinth_top), Vector2(wall_radius, plinth_top + 0.5), Vector2(wall_radius, eave - 0.9), Vector2(wall_radius, eave)], [TIMBER, CREAM, TIMBER], 0.0, PI, SEGMENTS), "plaster", true)
	# the big top: the scalloped valance, the gold eave, and the striped cone up to its gold cap
	_solid(holder, "Valance", _lathe([Vector2(eave_radius * 0.97, eave - 0.75), Vector2(eave_radius, eave - 0.1)], [STRIPES[0]], 0.0, PI, SEGMENTS), "cloth", true)
	_solid(holder, "Eave", _lathe([Vector2(eave_radius, eave - 0.1), Vector2(eave_radius, eave + 0.16), Vector2(eave_radius * 0.94, eave + 0.2)], [GOLD, GOLD], 0.0, PI, SEGMENTS), "gold", true)
	_solid(holder, "BigTop", _lathe([Vector2(eave_radius * 0.94, eave + 0.2), Vector2(WIDTH * 0.2, eave + (apex - eave) * 0.62), Vector2(WIDTH * 0.07, apex - 0.35)], [Color.WHITE, Color.WHITE], 0.0, PI, SEGMENTS, STRIPES), "cloth", true)
	_solid(holder, "Cap", _lathe([Vector2(WIDTH * 0.075, apex - 0.35), Vector2(WIDTH * 0.075, apex), Vector2(0.0, apex + 0.25)], [GOLD, GOLD], 0.0, PI, 8), "gold", true)
	# the two turrets stand just behind the face, where the painting has them
	for side: float in [-1.0, 1.0]:
		var turret_radius: float = WIDTH * TURRET_RADIUS
		var at: Vector3 = Vector3(side * WIDTH * TURRET_X, 0.0, -turret_radius * 1.1)
		var profile: Array[Vector2] = [Vector2(turret_radius, eave - 0.6), Vector2(turret_radius, HEIGHT * TURRET_EAVE), Vector2(turret_radius * 1.5, HEIGHT * TURRET_EAVE), Vector2(0.0, HEIGHT * TURRET_APEX)]
		var colours: Array[Color] = [CREAM, GOLD, Color.WHITE]
		var roof: Array[Color] = [STRIPES[1], STRIPES[0]]
		if side > 0.0:
			roof = [STRIPES[5], STRIPES[3]]
		var turret: MeshInstance3D = _solid(holder, "TurretWest" if side < 0.0 else "TurretEast", _lathe(profile, colours, 0.0, TAU, 8, roof, 2), "cloth", true)
		turret.position += at


## A surface of revolution round the y axis from angle `from` to `to` (0 = +x, PI/2 = -z: 0 to PI is the half BEHIND the face,
## PI to TAU the half in front). `profile`: (radius, height) points bottom to top; `colours`: one per profile span. With
## `stripes`, a span coloured white takes the stripe colour of its segment instead (the big top's panels).
static func _lathe(profile: Array[Vector2], colours: Array[Color], from: float, to: float, segments: int, stripes: Array[Color] = [], from_span: int = 0) -> ArrayMesh:
	var tool: SurfaceTool = SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	for segment: int in range(segments):
		var a0: float = lerpf(from, to, float(segment) / float(segments))
		var a1: float = lerpf(from, to, float(segment + 1) / float(segments))
		for span: int in range(profile.size() - 1):
			var colour: Color = colours[mini(span, colours.size() - 1)]
			if not stripes.is_empty() and span >= from_span and colour == Color.WHITE:
				colour = stripes[segment % stripes.size()]
			var low: Vector2 = profile[span]
			var high: Vector2 = profile[span + 1]
			var a: Vector3 = _ring(low, a0)
			var b: Vector3 = _ring(low, a1)
			var c: Vector3 = _ring(high, a1)
			var d: Vector3 = _ring(high, a0)
			# clockwise seen from outside (Godot's front face)
			for corner: Vector3 in [a, d, b, b, d, c]:
				tool.set_color(colour.srgb_to_linear())
				tool.add_vertex(corner)
	tool.generate_normals()
	return tool.commit()


static func _ring(point: Vector2, angle: float) -> Vector3:
	return Vector3(point.x * cos(angle), point.y, -point.x * sin(angle))


static func _solid(holder: Node3D, node_name: String, mesh: ArrayMesh, material_key: String, shadow: bool) -> MeshInstance3D:
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.material_override = EnvKit.flat(Color.WHITE, "shuffle_%s" % material_key)
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if shadow else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.position = CENTER
	# like its painted face, the house never fades for the hero (the hero's outline shows behind it)
	instance.set_meta(&"no_occlusion_fade", true)
	holder.add_child(instance)
	return instance


## A hanging sign on its own post beside the door path: seen from the square, off the paving (`SignPlacement`).
static func _sign(holder: Node3D, obstacles: Array[Vector3], at: Vector3, post_name: String, sign_name: String) -> void:
	var post: MeshInstance3D = MeshInstance3D.new()
	post.name = post_name
	var shaft: BoxMesh = BoxMesh.new()
	shaft.size = Vector3(0.16, SIGN_HEIGHT, 0.16)
	post.mesh = shaft
	post.material_override = EnvKit.flat(Color("4a3626"), "wood")
	post.position = at + Vector3(0.0, SIGN_HEIGHT * 0.5, 0.0)
	holder.add_child(post)
	obstacles.append(Vector3(at.x, at.z, 0.25))
	if not EnvKit.has(SIGN) or not EnvKit.has_art(SIGN):
		return
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2(SIGN_WIDTH, SIGN_WIDTH / maxf(EnvKit.aspect(SIGN), 0.2))
	var sign: MeshInstance3D = MeshInstance3D.new()
	sign.name = sign_name
	sign.mesh = quad
	sign.material_override = EnvKit.material(SIGN, true)
	# the painted bracket is on the sign's left edge: it meets the post there
	sign.position = at + Vector3(SIGN_WIDTH * 0.5 - 0.1, SIGN_HEIGHT - quad.size.y * 0.5 + 0.2, 0.06)
	sign.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	sign.set_meta(&"no_occlusion_fade", true)
	holder.add_child(sign)
