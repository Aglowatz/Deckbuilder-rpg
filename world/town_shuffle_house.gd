class_name TownShuffleHouse
extends RefCounted
## The Shuffle House, Octavia Eightfold's draft arena in Crosspath (Fable big pass Nov 23; moved Nov 24; rebuilt Nov 25).
## Fable Nov 25 (Part 3, the owner's item 14): it is a real 3D building with painted textures on it, built to the concept
## SH-CONCEPT of Batch 21. The flat painted card (TOWN-HERO-SHUFFLEHOUSE) with the plain round body behind it is gone.
##   - a two-storey half-timbered body with depth and sides on a stone foundation: SH-TEX-FRONT on the front (the arched double
##     door, the card fan, two stained-glass windows), SH-TEX-SIDE repeated on the sides and the back;
##   - three stone steps up to the door;
##   - a big-top roof with real volume: a striped tent (SH-TEX-ROOF) that rises from the overhanging eave to a gold cap, with the
##     scalloped marquee valance SH-TEX-TRIM along all four eaves;
##   - two small turrets with striped cones and flags, and a card weathervane on the peak;
##   - a cobbled apron with flower beds along the foundation, and a soft shadow under the whole footprint;
##   - marquee bulbs that glow and twinkle gently (one MultiMesh, `marquee_bulbs.gdshader`), on the painted bulbs of the valance.
## It stands where it stood (the owner kept the spot): the door, the sign, the quest marker, the map icon and the interaction
## spot all hang on CENTER / `door_spot()`, which did not move. It is lit like Crosspath's other houses (the kit's own kind of
## material: the sun shades it and it casts a shadow).
## The hanging sign (TOWN-SIGN-SHUFFLEHOUSE) stays where the door path leaves the square; a second one hangs at the lawn's edge.
## It is there from the start; it opens when all four zone drafts are won or three zones are freed (`DraftArena.is_open`).

const KEY: String = "shuffle_house"
const SIGN: String = "TOWN-SIGN-SHUFFLEHOUSE"
## The middle of the house on the ground (its door is in front of this point), its full height and the width of its body.
const CENTER: Vector3 = Vector3(47.4, 0.0, -11.4)
const HEIGHT: float = 12.7
const WIDTH: float = 9.0
## The footprint that keeps lamps, plants and props out (width x depth), and how far in front of the centre the door spot is.
const FOOTPRINT: Vector2 = Vector2(11.6, 10.4)
const DOOR: float = 2.7
## Where Octavia stands when the house is open: beside the steps, on the apron.
## (y: the top of the cobbles, so the hem of her gown rests on the apron and her shadow lies on it)
const HOST_OFFSET: Vector3 = Vector3(3.5, 0.07, 3.0)
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

# ---- The building, in metres from CENTER (x right, z towards the square, y up) --------------------------------------------------
const TEXTURES: String = "res://assets/art/env_kit/%s.webp"
const TEX_FRONT: String = "SH-TEX-FRONT"
const TEX_SIDE: String = "SH-TEX-SIDE"
const TEX_ROOF: String = "SH-TEX-ROOF"
const TEX_TRIM: String = "SH-TEX-TRIM"
## The body: the front wall's z, the depth behind it, the foundation's height and the two storeys on it (the front texture is 3:2).
const FRONT_Z: float = 0.6
## (the depth stops 1.6 m short of the loop lane that runs behind the house)
const DEPTH: float = 5.0
const FOUNDATION: float = 0.75
const FOUNDATION_LIP: float = 0.25
const WALL_HEIGHT: float = 6.0
## Three steps to the door: how wide the top one is, how much wider each lower one, and each one's tread.
const STEP_WIDTH: float = 3.2
const STEP_GROW: float = 0.5
const STEP_TREAD: float = 0.42
## The big top: how far the eave overhangs the walls, how high the tent rises above the eave, the cap's radius.
const OVERHANG: float = 0.55
const ROOF_RISE: float = 4.3
const ROOF_SAG: float = 1.6
const ROOF_RINGS: int = 10
const CAP_RADIUS: float = 0.55
## How many times the roof's six stripes go round the tent, and the valance's height (its strip is 1536 x 144).
const ROOF_REPEATS: float = 4.0
const TRIM_HEIGHT: float = 0.8
const TRIM_ASPECT: float = 1536.0 / 144.0
## The turrets: (x, z) of each, the drum's radius, how far it stands above the eave, the cone's height.
const TURRETS: Array[Vector2] = [Vector2(-3.45, -0.5), Vector2(3.45, -3.3)]
const TURRET_RADIUS: float = 0.85
const TURRET_RISE: float = 2.3
const TURRET_CONE: float = 1.6
const FLAGS: Array[Color] = [Color("3f5fae"), Color("5d8f3a")]
## The cobbled apron: an oval round the house (its middle, its two radii).
const APRON_CENTER: Vector3 = Vector3(0.0, 0.0, -0.6)
const APRON_RADII: Vector2 = Vector2(7.0, 4.6)
const STONE: Color = Color("b9a583")
const CREAM: Color = Color("e9cf98")
const TIMBER: Color = Color("6b4428")
const GOLD: Color = Color("e2b44a")
const RED: Color = Color("c8372d")
## What a surface is painted with while its texture is not imported (a fresh checkout before the art import).
const FALLBACK: Dictionary = {TEX_FRONT: Color("d9b46a"), TEX_SIDE: Color("d9b46a"), TEX_ROOF: Color("c8372d"), TEX_TRIM: Color("b8322c")}


static func door_spot() -> Vector3:
	return CENTER + Vector3(0.0, 0.0, DOOR)


static func host_spot() -> Vector3:
	return CENTER + HOST_OFFSET


## The open lawn in front of and around the house: no tree of the old map stands here, so the house is seen from the square
## (through the corner between Fenwick's and Pip's) and from the door path. The trees east and north of it stay as its backdrop.
static func in_forecourt(pos: Vector3) -> bool:
	return pos.x > 37.6 and pos.x < CENTER.x + 7.0 and pos.z > CENTER.z - 5.5 and pos.z < 3.2


static func eave_height() -> float:
	return FOUNDATION + WALL_HEIGHT - 0.1


## The eave's rectangle on the ground plan: (min x, min z, max x, max z).
static func eave_rect() -> Rect2:
	return Rect2(-WIDTH * 0.5 - OVERHANG, FRONT_Z - DEPTH - OVERHANG, WIDTH + OVERHANG * 2.0, DEPTH + OVERHANG * 2.0)


## Builds the house and its signs under `root` and adds their collision circles to `obstacles` (Vector3(x, z, radius)).
static func build(root: Node3D, obstacles: Array[Vector3]) -> Node3D:
	var holder: Node3D = Node3D.new()
	holder.name = "ShuffleHouse"
	root.add_child(holder)
	var house: Node3D = Node3D.new()
	house.name = "Building"
	house.position = CENTER
	holder.add_child(house)
	_ground(house)
	_foundation_and_steps(house)
	_walls(house)
	_roof(house)
	_trim(house)
	_turrets(house)
	_weathervane(house)
	_bulbs(house)
	_flower_beds(house, obstacles)
	holder.set_meta(&"textured", ResourceLoader.exists(TEXTURES % TEX_FRONT))
	# solid: the body's box (rows of circles), and the steps
	for z: float in [FRONT_Z - 1.15, FRONT_Z - DEPTH * 0.5, FRONT_Z - DEPTH + 1.15]:
		for x: float in [-3.45, -1.15, 1.15, 3.45]:
			obstacles.append(Vector3(CENTER.x + x, CENTER.z + z, 1.5))
	for x: float in [-1.0, 1.0]:
		obstacles.append(Vector3(CENTER.x + x, CENTER.z + FRONT_Z + FOUNDATION_LIP + STEP_TREAD, 0.85))
	_sign(holder, obstacles, SIGN_POST, "SignPost", "ShuffleHouseSign")
	_sign(holder, obstacles, SIGN_POST_LAWN, "SignPostLawn", "ShuffleHouseSignLawn")
	# the alley keeps its east side: two lengths of hedge where the row house's wall stood
	for z: float in HEDGE_Z:
		var hedge: Node3D = PropKit.make("hedge", 3.2, int(absf(z) * 10.0))
		ModelKit.place(holder, hedge, Vector3(HEDGE_X, 0.0, z), 90.0, 1.0)
		for step: float in [-1.1, 0.0, 1.1]:
			obstacles.append(Vector3(HEDGE_X, z + step, 0.55))
	# a warm pool of light on the steps and the door from the marquee
	var glow: OmniLight3D = OmniLight3D.new()
	glow.name = "MarqueeGlow"
	glow.light_color = Color("ffc56a")
	# gentle and low: the walls are lit surfaces now (a strong lamp close to the painted front washed it out)
	glow.light_energy = 0.35
	glow.omni_range = 5.0
	glow.position = CENTER + Vector3(0.0, 1.6, FRONT_Z + 3.2)
	holder.add_child(glow)
	return holder


# ---- Materials -------------------------------------------------------------------------------------------------------------------


static var _materials: Dictionary = {}


## A painted texture of the house as a material of the kit's own kind (lit by the sun like the other houses' walls, never
## repainted by the painted-texture presets). `cut`: an alpha cut-out drawn on both sides (the valance).
static func textured(id: String, cut: bool = false) -> StandardMaterial3D:
	var key: String = "%s|%s" % [id, str(cut)]
	if _materials.has(key):
		return _materials[key] as StandardMaterial3D
	var made: StandardMaterial3D = StandardMaterial3D.new()
	made.resource_name = id
	var path: String = TEXTURES % id
	if ResourceLoader.exists(path):
		made.albedo_texture = load(path) as Texture2D
	else:
		made.albedo_color = FALLBACK.get(id, Color.WHITE) as Color
	made.roughness = 1.0
	made.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	made.vertex_color_use_as_albedo = true
	if cut:
		made.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
		made.alpha_scissor_threshold = 0.5
		made.cull_mode = BaseMaterial3D.CULL_DISABLED
	made.set_meta(PaintedClasses.META_NO_PAINT, true)
	_materials[key] = made
	return made


static func _flat(colour: Color, key: String) -> StandardMaterial3D:
	return EnvKit.flat(colour, "shuffle_%s" % key)


# ---- Mesh helpers ----------------------------------------------------------------------------------------------------------------


## One quad seen from outside: a bottom-left, b bottom-right, c top-right, d top-left; `uv` is (u at a, u at b, v at the bottom,
## v at the top); `shade` darkens (bottom, top) through the vertex colour (a little baked shadow under an eave).
static func _quad(tool: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, uv: Vector4, shade: Vector2 = Vector2.ONE) -> void:
	var normal: Vector3 = (b - a).cross(d - a).normalized()
	var corners: Array[Vector3] = [a, d, b, b, d, c]
	var uvs: Array[Vector2] = [Vector2(uv.x, uv.z), Vector2(uv.x, uv.w), Vector2(uv.y, uv.z), Vector2(uv.y, uv.z), Vector2(uv.x, uv.w), Vector2(uv.y, uv.w)]
	var shades: Array[float] = [shade.x, shade.y, shade.x, shade.x, shade.y, shade.y]
	for index: int in range(6):
		tool.set_color(Color(shades[index], shades[index], shades[index]))
		tool.set_normal(normal)
		tool.set_uv(uvs[index])
		tool.add_vertex(corners[index])


## A block from `low` to `high` (its four sides and its top) with UVs in metres, for a kit surface that tiles by the metre.
static func _block(tool: SurfaceTool, low: Vector3, high: Vector3, shade: Vector2 = Vector2.ONE) -> void:
	var size: Vector3 = high - low
	# front (+z), right (+x), back (-z), left (-x)
	_quad(tool, Vector3(low.x, low.y, high.z), Vector3(high.x, low.y, high.z), Vector3(high.x, high.y, high.z), Vector3(low.x, high.y, high.z), Vector4(0.0, size.x, size.y, 0.0), shade)
	_quad(tool, Vector3(high.x, low.y, high.z), Vector3(high.x, low.y, low.z), Vector3(high.x, high.y, low.z), Vector3(high.x, high.y, high.z), Vector4(0.0, size.z, size.y, 0.0), shade)
	_quad(tool, Vector3(high.x, low.y, low.z), Vector3(low.x, low.y, low.z), Vector3(low.x, high.y, low.z), Vector3(high.x, high.y, low.z), Vector4(0.0, size.x, size.y, 0.0), shade)
	_quad(tool, Vector3(low.x, low.y, low.z), Vector3(low.x, low.y, high.z), Vector3(low.x, high.y, high.z), Vector3(low.x, high.y, low.z), Vector4(0.0, size.z, size.y, 0.0), shade)
	# top
	_quad(tool, Vector3(low.x, high.y, high.z), Vector3(high.x, high.y, high.z), Vector3(high.x, high.y, low.z), Vector3(low.x, high.y, low.z), Vector4(0.0, size.x, size.z, 0.0), Vector2(shade.y, shade.y))


static func _begin() -> SurfaceTool:
	var tool: SurfaceTool = SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	return tool


static func _add(house: Node3D, node_name: String, mesh: Mesh, material: Material, shadow: bool = true) -> MeshInstance3D:
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.material_override = material
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if shadow else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# the house never fades for the hero (the hero's outline shows behind it)
	instance.set_meta(&"no_occlusion_fade", true)
	house.add_child(instance)
	return instance


## A surface of revolution round the y axis (a turret's drum, a cone, a ball): `profile` is (radius, height) bottom to top,
## `colours` one per span; with `around` the u coordinate goes that many times round (a textured cone), v from 1 at the first
## point to 0 at the last.
static func _lathe(profile: Array[Vector2], colours: Array[Color], segments: int, around: float = 0.0) -> ArrayMesh:
	var tool: SurfaceTool = _begin()
	for segment: int in range(segments):
		var a0: float = TAU * float(segment) / float(segments)
		var a1: float = TAU * float(segment + 1) / float(segments)
		for span: int in range(profile.size() - 1):
			var colour: Color = colours[mini(span, colours.size() - 1)]
			var low: Vector2 = profile[span]
			var high: Vector2 = profile[span + 1]
			var v0: float = 1.0 - float(span) / float(profile.size() - 1)
			var v1: float = 1.0 - float(span + 1) / float(profile.size() - 1)
			var corners: Array[Vector3] = [_ring(low, a0), _ring(high, a0), _ring(low, a1), _ring(low, a1), _ring(high, a0), _ring(high, a1)]
			var uvs: Array[Vector2] = [Vector2(a0, v0), Vector2(a0, v1), Vector2(a1, v0), Vector2(a1, v0), Vector2(a0, v1), Vector2(a1, v1)]
			for index: int in range(6):
				tool.set_color(colour.srgb_to_linear() if around <= 0.0 else Color.WHITE)
				tool.set_uv(Vector2(uvs[index].x / TAU * around, uvs[index].y))
				tool.add_vertex(corners[index])
	tool.generate_normals()
	return tool.commit()


static func _ring(point: Vector2, angle: float) -> Vector3:
	return Vector3(point.x * cos(angle), point.y, -point.x * sin(angle))


# ---- The ground: the soft shadow and the cobbled apron ----------------------------------------------------------------------------


static func _ground(house: Node3D) -> void:
	# a soft dark pool under the whole footprint: the house's weight on the ground
	var shade: MeshInstance3D = MeshInstance3D.new()
	shade.name = "ContactShadow"
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2(WIDTH + 5.0, DEPTH + 5.2)
	quad.orientation = PlaneMesh.FACE_Y
	shade.mesh = quad
	var gradient: Gradient = Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.6, 1.0])
	gradient.colors = PackedColorArray([Color(0.05, 0.03, 0.08, 0.6), Color(0.05, 0.03, 0.08, 0.38), Color(0.05, 0.03, 0.08, 0.0)])
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
	shade.position = Vector3(0.0, 0.09, FRONT_Z - DEPTH * 0.5 + 0.3)
	shade.set_meta(&"no_occlusion_fade", true)
	house.add_child(shade)
	# the apron: an oval of cobbles round the house, its rim a ring darker (the kerb)
	var tool: SurfaceTool = _begin()
	var points: int = 40
	for index: int in range(points):
		var a0: float = TAU * float(index) / float(points)
		var a1: float = TAU * float(index + 1) / float(points)
		var p0: Vector3 = APRON_CENTER + Vector3(cos(a0) * APRON_RADII.x, 0.0, sin(a0) * APRON_RADII.y)
		var p1: Vector3 = APRON_CENTER + Vector3(cos(a1) * APRON_RADII.x, 0.0, sin(a1) * APRON_RADII.y)
		var inner0: Vector3 = APRON_CENTER.lerp(p0, 0.9)
		var inner1: Vector3 = APRON_CENTER.lerp(p1, 0.9)
		# clockwise seen from above (Godot's front face)
		for corner: Vector3 in [APRON_CENTER, inner0, inner1]:
			_apron_vertex(tool, corner, 1.0)
		for pair: Array in [[inner0, 1.0], [p0, 0.72], [inner1, 1.0], [p0, 0.72], [p1, 0.72], [inner1, 1.0]]:
			_apron_vertex(tool, pair[0] as Vector3, float(pair[1]))
	var apron: MeshInstance3D = _add(house, "Apron", tool.commit(), EnvKit.material("ENV-GROUND-COBBLE"), false)
	apron.position.y = 0.06


static func _apron_vertex(tool: SurfaceTool, point: Vector3, shade: float) -> void:
	tool.set_color(Color(shade, shade, shade))
	tool.set_normal(Vector3.UP)
	tool.set_uv(Vector2(point.x, point.z))
	tool.add_vertex(point)


# ---- The stone foundation and the three steps -------------------------------------------------------------------------------------


static func _foundation_and_steps(house: Node3D) -> void:
	var stone: StandardMaterial3D = EnvKit.material("ENV-WALL-FOUNDATION")
	var tool: SurfaceTool = _begin()
	var half: float = WIDTH * 0.5 + FOUNDATION_LIP
	_block(tool, Vector3(-half, 0.0, FRONT_Z - DEPTH - FOUNDATION_LIP), Vector3(half, FOUNDATION, FRONT_Z + FOUNDATION_LIP), Vector2(0.82, 1.0))
	_add(house, "Foundation", tool.commit(), stone)
	# three steps: the top one is the landing at the door's sill, each lower one wider and one tread further out
	var steps: SurfaceTool = _begin()
	var front: float = FRONT_Z + FOUNDATION_LIP
	for step: int in range(3):
		var top: float = FOUNDATION * float(3 - step) / 3.0
		var width: float = STEP_WIDTH + STEP_GROW * 2.0 * float(step)
		_block(steps, Vector3(-width * 0.5, 0.0, front - 0.05), Vector3(width * 0.5, top, front + STEP_TREAD * float(step + 1)), Vector2(0.86, 1.0))
	_add(house, "Steps", steps.commit(), stone)


## Where the lowest step ends in front (the hero stands just beyond it).
static func steps_front() -> float:
	return FRONT_Z + FOUNDATION_LIP + STEP_TREAD * 3.0


# ---- The half-timbered body -------------------------------------------------------------------------------------------------------


static func _walls(house: Node3D) -> void:
	var half: float = WIDTH * 0.5
	var low: float = FOUNDATION
	var high: float = FOUNDATION + WALL_HEIGHT
	var back: float = FRONT_Z - DEPTH
	# the front: the whole painted elevation, once
	var front: SurfaceTool = _begin()
	_quad(front, Vector3(-half, low, FRONT_Z), Vector3(half, low, FRONT_Z), Vector3(half, high, FRONT_Z), Vector3(-half, high, FRONT_Z), Vector4(0.0, 1.0, 1.0, 0.0), Vector2(1.0, 0.86))
	_add(house, "FrontWall", front.commit(), textured(TEX_FRONT))
	# the sides and the back: the side bay repeated (one bay on each side, two across the back)
	var sides: SurfaceTool = _begin()
	_quad(sides, Vector3(half, low, FRONT_Z), Vector3(half, low, back), Vector3(half, high, back), Vector3(half, high, FRONT_Z), Vector4(0.0, 1.0, 1.0, 0.0), Vector2(1.0, 0.86))
	_quad(sides, Vector3(half, low, back), Vector3(-half, low, back), Vector3(-half, high, back), Vector3(half, high, back), Vector4(0.0, 2.0, 1.0, 0.0), Vector2(1.0, 0.86))
	_quad(sides, Vector3(-half, low, back), Vector3(-half, low, FRONT_Z), Vector3(-half, high, FRONT_Z), Vector3(-half, high, back), Vector4(0.0, 1.0, 1.0, 0.0), Vector2(1.0, 0.86))
	_add(house, "SideWalls", sides.commit(), textured(TEX_SIDE))
	# timber posts on the four corners, where two painted walls meet
	var posts: SurfaceTool = _begin()
	for x: float in [-half, half]:
		for z: float in [FRONT_Z, back]:
			_block(posts, Vector3(x - 0.16, low, z - 0.16), Vector3(x + 0.16, high, z + 0.16))
	_add(house, "CornerPosts", posts.commit(), _flat(TIMBER, "timber"))


# ---- The big top ------------------------------------------------------------------------------------------------------------------


## The points round the eave's rectangle, clockwise seen from above starting at the front-left corner, with the distance
## walked so far in `x` of the second array (the stripes are laid along it).
static func _eave_loop() -> Array:
	var rect: Rect2 = eave_rect()
	var corners: Array[Vector2] = [Vector2(rect.position.x, rect.end.y), Vector2(rect.end.x, rect.end.y), Vector2(rect.end.x, rect.position.y), Vector2(rect.position.x, rect.position.y)]
	var counts: Array[int] = [10, 8, 10, 8]
	var points: Array[Vector2] = []
	var walked: Array[float] = []
	var distance: float = 0.0
	for side: int in range(4):
		var from: Vector2 = corners[side]
		var to: Vector2 = corners[(side + 1) % 4]
		for step: int in range(counts[side]):
			points.append(from.lerp(to, float(step) / float(counts[side])))
			walked.append(distance + from.distance_to(to) * float(step) / float(counts[side]))
		distance += from.distance_to(to)
	points.append(corners[0])
	walked.append(distance)
	return [points, walked]


## A point of the tent: `eave` is its point on the eave's rectangle (x, z), `t` 0 at the eave .. 1 at the cap. The canvas sags:
## it climbs slowly off the eave and steeply to the cap, like a big top.
static func roof_point(eave: Vector2, t: float) -> Vector3:
	var middle: Vector2 = eave_rect().get_center()
	var top: Vector2 = middle + (eave - middle).normalized() * CAP_RADIUS
	var flat: Vector2 = eave.lerp(top, t)
	return Vector3(flat.x, eave_height() + ROOF_RISE * pow(t, ROOF_SAG), flat.y)


static func _roof(house: Node3D) -> void:
	var loop: Array = _eave_loop()
	var points: Array[Vector2] = loop[0] as Array[Vector2]
	var walked: Array[float] = loop[1] as Array[float]
	var around: float = walked[walked.size() - 1]
	var tool: SurfaceTool = _begin()
	for column: int in range(points.size() - 1):
		var u0: float = walked[column] / around * ROOF_REPEATS
		var u1: float = walked[column + 1] / around * ROOF_REPEATS
		for ring: int in range(ROOF_RINGS):
			var t0: float = float(ring) / float(ROOF_RINGS)
			var t1: float = float(ring + 1) / float(ROOF_RINGS)
			var a: Vector3 = roof_point(points[column], t0)
			var b: Vector3 = roof_point(points[column + 1], t0)
			var c: Vector3 = roof_point(points[column + 1], t1)
			var d: Vector3 = roof_point(points[column], t1)
			var corners: Array[Vector3] = [a, d, b, b, d, c]
			var uvs: Array[Vector2] = [Vector2(u0, 1.0 - t0), Vector2(u0, 1.0 - t1), Vector2(u1, 1.0 - t0), Vector2(u1, 1.0 - t0), Vector2(u0, 1.0 - t1), Vector2(u1, 1.0 - t1)]
			for index: int in range(6):
				tool.set_color(Color.WHITE)
				tool.set_uv(uvs[index])
				tool.add_vertex(corners[index])
	tool.generate_normals()
	_add(house, "BigTop", tool.commit(), textured(TEX_ROOF))
	# the soffit: the underside of the overhang, a plain dark board
	var rect: Rect2 = eave_rect()
	var soffit: SurfaceTool = _begin()
	var y: float = eave_height() - 0.02
	_quad(soffit, Vector3(rect.position.x, y, rect.position.y), Vector3(rect.end.x, y, rect.position.y), Vector3(rect.end.x, y, rect.end.y), Vector3(rect.position.x, y, rect.end.y), Vector4(0.0, 1.0, 1.0, 0.0))
	_add(house, "Soffit", soffit.commit(), _flat(TIMBER.darkened(0.25), "soffit"))
	# the gold cap on the peak
	var middle: Vector2 = rect.get_center()
	var peak: float = eave_height() + ROOF_RISE
	var cap: MeshInstance3D = _add(house, "Cap", _lathe([Vector2(CAP_RADIUS + 0.12, peak - 0.25), Vector2(CAP_RADIUS + 0.12, peak + 0.2), Vector2(CAP_RADIUS * 0.6, peak + 0.5), Vector2(0.0, peak + 0.72)], [GOLD, GOLD.lightened(0.1), GOLD], 12), _flat(Color.WHITE, "gold"))
	cap.position = Vector3(middle.x, 0.0, middle.y)


## How many scallops of the valance fit a side of that length (its strip has ten).
static func scallops_for(length: float) -> int:
	return maxi(1, roundi(length / (TRIM_HEIGHT * TRIM_ASPECT / 10.0)))


static func _trim(house: Node3D) -> void:
	var rect: Rect2 = eave_rect()
	var top: float = eave_height() + 0.1
	var low: float = top - TRIM_HEIGHT
	var corners: Array[Vector3] = [Vector3(rect.position.x, 0.0, rect.end.y), Vector3(rect.end.x, 0.0, rect.end.y), Vector3(rect.end.x, 0.0, rect.position.y), Vector3(rect.position.x, 0.0, rect.position.y)]
	var tool: SurfaceTool = _begin()
	for side: int in range(4):
		var from: Vector3 = corners[side]
		var to: Vector3 = corners[(side + 1) % 4]
		var repeats: float = float(scallops_for(from.distance_to(to))) / 10.0
		_quad(tool, Vector3(from.x, low, from.z), Vector3(to.x, low, to.z), Vector3(to.x, top, to.z), Vector3(from.x, top, from.z), Vector4(0.0, repeats, 1.0, 0.0))
	_add(house, "Valance", tool.commit(), textured(TEX_TRIM, true))
	# a gold rail on the eave's edge, over the valance
	var rail: SurfaceTool = _begin()
	_block(rail, Vector3(rect.position.x - 0.06, top - 0.02, rect.position.y - 0.06), Vector3(rect.end.x + 0.06, top + 0.1, rect.end.y + 0.06))
	_add(house, "EaveRail", rail.commit(), _flat(GOLD, "gold"))


# ---- The turrets and the weathervane ----------------------------------------------------------------------------------------------


static func _turrets(house: Node3D) -> void:
	for index: int in range(TURRETS.size()):
		var at: Vector2 = TURRETS[index]
		var foot: float = eave_height() - 0.3
		var top: float = eave_height() + TURRET_RISE
		var turret: Node3D = Node3D.new()
		turret.name = "Turret%d" % (index + 1)
		turret.position = Vector3(at.x, 0.0, at.y)
		house.add_child(turret)
		# a half-timbered drum: timber, plaster, timber, a gold band under the cone
		var drum: Array[Vector2] = [Vector2(TURRET_RADIUS, foot), Vector2(TURRET_RADIUS, top - 1.25), Vector2(TURRET_RADIUS, top - 1.05), Vector2(TURRET_RADIUS, top - 0.35), Vector2(TURRET_RADIUS, top - 0.18), Vector2(TURRET_RADIUS + 0.1, top - 0.18), Vector2(TURRET_RADIUS + 0.1, top)]
		_add(turret, "Drum", _lathe(drum, [TIMBER, TIMBER, CREAM, TIMBER, GOLD, GOLD], 10), _flat(Color.WHITE, "turret"))
		# the striped cone, a gold ball, a pole and a flag
		_add(turret, "Cone", _lathe([Vector2(TURRET_RADIUS + 0.38, top), Vector2((TURRET_RADIUS + 0.38) * 0.5, top + TURRET_CONE * 0.42), Vector2(0.04, top + TURRET_CONE)], [Color.WHITE], 12, 1.0), textured(TEX_ROOF))
		var tip: float = top + TURRET_CONE
		_add(turret, "Ball", _lathe([Vector2(0.0, tip - 0.06), Vector2(0.17, tip + 0.06), Vector2(0.17, tip + 0.2), Vector2(0.0, tip + 0.32)], [GOLD], 8), _flat(Color.WHITE, "gold"))
		var pole: SurfaceTool = _begin()
		_block(pole, Vector3(-0.03, tip + 0.2, -0.03), Vector3(0.03, tip + 1.35, 0.03))
		_add(turret, "Pole", pole.commit(), _flat(GOLD.darkened(0.15), "pole"))
		var flag: SurfaceTool = _begin()
		var flag_top: float = tip + 1.3
		# a swallow-tailed pennant flying east (two quads; drawn on both sides)
		_quad(flag, Vector3(0.03, flag_top - 0.5, 0.0), Vector3(0.75, flag_top - 0.42, 0.06), Vector3(0.75, flag_top - 0.08, 0.06), Vector3(0.03, flag_top, 0.0), Vector4(0.0, 1.0, 1.0, 0.0))
		_quad(flag, Vector3(0.75, flag_top - 0.42, 0.06), Vector3(1.15, flag_top - 0.5, -0.04), Vector3(1.15, flag_top - 0.3, -0.04), Vector3(0.75, flag_top - 0.25, 0.06), Vector4(0.0, 1.0, 1.0, 0.0))
		var cloth: StandardMaterial3D = StandardMaterial3D.new()
		cloth.albedo_color = FLAGS[index % FLAGS.size()]
		cloth.roughness = 1.0
		cloth.cull_mode = BaseMaterial3D.CULL_DISABLED
		cloth.set_meta(PaintedClasses.META_NO_PAINT, true)
		_add(turret, "Flag", flag.commit(), cloth, false)


static func _weathervane(house: Node3D) -> void:
	var middle: Vector2 = eave_rect().get_center()
	var peak: float = eave_height() + ROOF_RISE + 0.72
	var vane: Node3D = Node3D.new()
	vane.name = "Weathervane"
	vane.position = Vector3(middle.x, 0.0, middle.y)
	house.add_child(vane)
	var metal: SurfaceTool = _begin()
	# the pole, the arrow's shaft, its head and its tail
	_block(metal, Vector3(-0.035, peak - 0.1, -0.035), Vector3(0.035, HEIGHT - 0.35, 0.035))
	var arrow: float = peak + 0.42
	_block(metal, Vector3(-0.85, arrow - 0.03, -0.03), Vector3(0.85, arrow + 0.03, 0.03))
	_block(metal, Vector3(-1.05, arrow - 0.13, -0.025), Vector3(-0.8, arrow + 0.13, 0.025))
	_block(metal, Vector3(0.8, arrow - 0.16, -0.025), Vector3(0.98, arrow + 0.16, 0.025))
	_add(vane, "Arrow", metal.commit(), _flat(GOLD, "gold"))
	# the playing card over the arrow: a cream card in a gold rim with a red pip on each face
	var card_low: float = arrow + 0.14
	var card: SurfaceTool = _begin()
	_block(card, Vector3(-0.27, card_low, -0.03), Vector3(0.27, card_low + 0.74, 0.03))
	_add(vane, "CardRim", card.commit(), _flat(GOLD, "gold"))
	var face: SurfaceTool = _begin()
	_block(face, Vector3(-0.22, card_low + 0.05, -0.04), Vector3(0.22, card_low + 0.69, 0.04))
	_add(vane, "Card", face.commit(), _flat(Color("f6ecd2"), "card"))
	var pip: MeshInstance3D = MeshInstance3D.new()
	pip.name = "Pip"
	var diamond: BoxMesh = BoxMesh.new()
	diamond.size = Vector3(0.2, 0.2, 0.1)
	pip.mesh = diamond
	pip.material_override = _flat(RED, "pip")
	pip.position = Vector3(0.0, card_low + 0.37, 0.0)
	pip.rotation_degrees = Vector3(0.0, 0.0, 45.0)
	pip.scale = Vector3(1.0, 1.35, 1.0)
	pip.set_meta(&"no_occlusion_fade", true)
	vane.add_child(pip)
	# a red pennant on the very top
	var flag: SurfaceTool = _begin()
	var top: float = HEIGHT - 0.38
	_quad(flag, Vector3(0.03, top - 0.34, 0.0), Vector3(0.95, top - 0.2, 0.05), Vector3(0.95, top - 0.12, 0.05), Vector3(0.03, top, 0.0), Vector4(0.0, 1.0, 1.0, 0.0))
	var cloth: StandardMaterial3D = StandardMaterial3D.new()
	cloth.albedo_color = RED
	cloth.roughness = 1.0
	cloth.cull_mode = BaseMaterial3D.CULL_DISABLED
	cloth.set_meta(PaintedClasses.META_NO_PAINT, true)
	_add(vane, "Pennant", flag.commit(), cloth, false)


# ---- The marquee bulbs ------------------------------------------------------------------------------------------------------------


## Where every bulb sits (metres from CENTER): two on each scallop of the valance (on its painted bulbs), a ring under each
## turret's cone, a ring on the cap, and a string up each of the tent's four ridges.
static func bulb_points() -> Array[Vector3]:
	var result: Array[Vector3] = []
	var rect: Rect2 = eave_rect()
	var y: float = eave_height() + 0.1 - TRIM_HEIGHT * 0.14
	var corners: Array[Vector3] = [Vector3(rect.position.x, 0.0, rect.end.y), Vector3(rect.end.x, 0.0, rect.end.y), Vector3(rect.end.x, 0.0, rect.position.y), Vector3(rect.position.x, 0.0, rect.position.y)]
	var outward: Array[Vector3] = [Vector3(0.0, 0.0, 1.0), Vector3(1.0, 0.0, 0.0), Vector3(0.0, 0.0, -1.0), Vector3(-1.0, 0.0, 0.0)]
	for side: int in range(4):
		var from: Vector3 = corners[side]
		var to: Vector3 = corners[(side + 1) % 4]
		var count: int = scallops_for(from.distance_to(to)) * 2
		for index: int in range(count):
			var at: Vector3 = from.lerp(to, (float(index) + 0.5) / float(count))
			result.append(Vector3(at.x, y, at.z) + outward[side] * 0.05)
	for at: Vector2 in TURRETS:
		for index: int in range(8):
			var angle: float = TAU * float(index) / 8.0
			result.append(Vector3(at.x + cos(angle) * (TURRET_RADIUS + 0.14), eave_height() + TURRET_RISE - 0.09, at.y + sin(angle) * (TURRET_RADIUS + 0.14)))
	var middle: Vector2 = rect.get_center()
	for index: int in range(10):
		var angle: float = TAU * float(index) / 10.0
		result.append(Vector3(middle.x + cos(angle) * (CAP_RADIUS + 0.16), eave_height() + ROOF_RISE, middle.y + sin(angle) * (CAP_RADIUS + 0.16)))
	for corner: Vector2 in [Vector2(rect.position.x, rect.end.y), Vector2(rect.end.x, rect.end.y), Vector2(rect.end.x, rect.position.y), Vector2(rect.position.x, rect.position.y)]:
		for index: int in range(1, 7):
			result.append(roof_point(corner, float(index) / 7.5) + Vector3(0.0, 0.07, 0.0))
	return result


static func _bulbs(house: Node3D) -> void:
	var points: Array[Vector3] = bulb_points()
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = 0.085
	sphere.height = 0.17
	sphere.radial_segments = 8
	sphere.rings = 4
	var lamps: MultiMesh = MultiMesh.new()
	lamps.transform_format = MultiMesh.TRANSFORM_3D
	lamps.mesh = sphere
	lamps.instance_count = points.size()
	for index: int in range(points.size()):
		lamps.set_instance_transform(index, Transform3D(Basis.IDENTITY, points[index]))
	var holder: MultiMeshInstance3D = MultiMeshInstance3D.new()
	holder.name = "MarqueeBulbs"
	holder.multimesh = lamps
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = load("res://assets/shaders/marquee_bulbs.gdshader") as Shader
	holder.material_override = material
	holder.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	holder.set_meta(&"no_occlusion_fade", true)
	house.add_child(holder)


# ---- The flower beds --------------------------------------------------------------------------------------------------------------


## Where the planters stand (metres from CENTER; x, z, the yaw in degrees, the length): either side of the steps and along
## both sides of the house.
const BEDS: Array[Vector4] = [Vector4(-3.25, 1.3, 0.0, 2.2), Vector4(3.25, 1.3, 0.0, 2.2), Vector4(-5.2, -1.9, 90.0, 2.4), Vector4(5.2, -1.9, 90.0, 2.4)]


static func _flower_beds(house: Node3D, obstacles: Array[Vector3]) -> void:
	for index: int in range(BEDS.size()):
		var bed: Vector4 = BEDS[index]
		var planter: Node3D = PropKit.make("planter", bed.w, 31 + index * 7)
		planter.name = "FlowerBed%d" % (index + 1)
		house.add_child(planter)
		planter.position = Vector3(bed.x, 0.06, bed.y)
		planter.rotation_degrees.y = bed.z
		var along: Vector3 = Vector3(1.0, 0.0, 0.0).rotated(Vector3.UP, deg_to_rad(bed.z))
		for step: float in [-0.5, 0.5]:
			var at: Vector3 = CENTER + Vector3(bed.x, 0.0, bed.y) + along * bed.w * step * 0.6
			obstacles.append(Vector3(at.x, at.z, 0.55))


# ---- The signs --------------------------------------------------------------------------------------------------------------------


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
