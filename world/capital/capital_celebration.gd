class_name CapitalCelebration
extends RefCounted
## Fable Nov 12 (Part 2.3; the late critic's "the Capital barely changes after Primm falls", the art critic's "emptier, paler and partly
## broken"): what the freed city adds once `primm_defeated` is set. Existing assets only: the townsfolk sprite sets as a crowd in the Gate
## Plaza and on the avenue (people from all four Paths' lands come to see), bunting in the Paths' colours from the fountain to the plaza's
## lamps and across the avenue, confetti on the paving. The bunting, its posts and the confetti are ONE vertex-coloured mesh (one draw
## call, no shadow); the crowd is standing sprites (no per-frame script). Low-end: half the crowd, no confetti.
## The light (StylePresets.CAPITAL_FREED), the running fountains (CapitalGrand.fountain) and the banners over Primm's face
## (CapitalKit.FREED_CLOTHS) are the rest of the change.

const PENNANT_COLOURS: Array[Color] = [Color("d9483b"), Color("f2c14e"), Color("6b8e3d"), Color("3e8e8a"), Color("f6b8c4"), Color("f2ecdd")]
const STRING_COLOUR: Color = Color("7a5a3a")
const POST_COLOUR: Color = Color("8a6440")
const CONFETTI_COLOURS: Array[Color] = [Color("e8625a"), Color("f2c14e"), Color("7fbf73"), Color("5aa0e0"), Color("f6b8c4"), Color("fff4e0")]
## Where the fountain's pedestal ends (the fallen statue left it bare) and how high a plaza lamp's arm is.
const FOUNTAIN_TOP: float = 4.35
const LAMP_TOP: float = 3.45
const AVENUE_LINE_Z: Array[float] = [20.0, 26.0, 32.0, 38.0, 44.0]
const AVENUE_HALF: float = 5.6
const POST_HEIGHT: float = 5.2
const CONFETTI: int = 320
## The crowd: groups of three or four facing each other (offsets from an anchor point, yaw in degrees), walkable spots only.
const CROWD_SETS: Array[String] = ["TOWNSFOLK_A", "TOWNSFOLK_B", "TOWNSFOLK_C", "VILLAGER", "DUMPWORKER"]
const CROWD_TINTS: Array[Color] = [Color(1.0, 1.0, 1.0), Color(1.12, 0.94, 0.88), Color(0.9, 1.04, 0.94), Color(0.92, 0.94, 1.12), Color(1.1, 1.04, 0.86)]
const CROWD_GROUPS: Array[Dictionary] = [
	{"at": Vector2(52.6, 62.4), "spots": [Vector3(0.0, 0.0, 0.0), Vector3(1.3, 0.0, 0.5), Vector3(0.5, 0.0, 1.4)]},
	{"at": Vector2(67.2, 62.8), "spots": [Vector3(0.0, 0.0, 0.0), Vector3(-1.2, 0.0, 0.7), Vector3(0.2, 0.0, 1.5), Vector3(1.2, 0.0, 0.6)]},
	{"at": Vector2(66.4, 50.6), "spots": [Vector3(0.0, 0.0, 0.0), Vector3(1.2, 0.0, -0.6), Vector3(0.9, 0.0, 0.9)]},
	{"at": Vector2(53.2, 51.0), "spots": [Vector3(0.0, 0.0, 0.0), Vector3(-1.1, 0.0, 0.6), Vector3(0.3, 0.0, 1.3)]},
	{"at": Vector2(57.4, 36.0), "spots": [Vector3(0.0, 0.0, 0.0), Vector3(0.9, 0.0, 1.0)]},
	{"at": Vector2(62.8, 27.0), "spots": [Vector3(0.0, 0.0, 0.0), Vector3(-0.9, 0.0, 1.1), Vector3(0.8, 0.0, 1.2)]},
]
## What the crowd says to a passing hero (NpcBarks; new lines for the freed city).
const CROWD_LINES: Array[String] = [
	"We walked two days to see it. The smile is gone from the palace. Look!",
	"Somebody hung washing over his face. Best banner I ever saw.",
	"The fountain runs again. My nan cried. I only had something in my eye.",
	"No inspector has measured my smile all day. I keep checking over my shoulder.",
	"They say you can frown here now. I tried it. Lovely.",
	"Four flags, four lands, one party. Mind the confetti, it gets in your boots.",
]


## Builds the celebration under `scene` (the Capital's zone scene). `walkable`: func(Vector3) -> bool; `add_blocker`: func(Vector3, float).
## Returns the crowd's sprite nodes (the scene registers their passing lines).
static func build(scene: Node3D, walkable: Callable, add_blocker: Callable, low_end: bool) -> Array[Node3D]:
	var root: Node3D = Node3D.new()
	root.name = "Celebration"
	scene.add_child(root)
	root.add_child(_decor_mesh(walkable, not low_end))
	return _crowd(root, walkable, add_blocker, low_end)


static func _crowd(root: Node3D, walkable: Callable, add_blocker: Callable, low_end: bool) -> Array[Node3D]:
	var people: Array[Node3D] = []
	var sets: Array[String] = []
	for character: String in CROWD_SETS:
		if SpriteLibrary.has_character(character):
			sets.append(character)
	if sets.is_empty():
		return people
	var count: int = 0
	for group_index: int in range(CROWD_GROUPS.size()):
		if low_end and group_index % 2 == 1:
			continue
		var group: Dictionary = CROWD_GROUPS[group_index]
		var at: Vector2 = group["at"] as Vector2
		var spots: Array = group["spots"] as Array
		var centre: Vector3 = Vector3.ZERO
		for spot: Variant in spots:
			centre += spot as Vector3
		centre /= float(spots.size())
		for spot: Variant in spots:
			var offset: Vector3 = spot as Vector3
			var pos: Vector3 = Vector3(at.x + offset.x, 0.0, at.y + offset.z)
			if not bool(walkable.call(pos)):
				continue
			var facing: Vector3 = centre - offset
			var yaw: float = rad_to_deg(atan2(facing.x, facing.z))
			var actor: SpriteActor = NpcSprites.make_actor(sets[count % sets.size()], CROWD_TINTS[(count * 3 + group_index) % CROWD_TINTS.size()])
			actor.name = "Reveller%d" % count
			ModelKit.place(root, actor, pos, yaw, TownPlayer.MODEL_SCALE)
			add_blocker.call(pos, 0.1)
			people.append(actor)
			count += 1
	return people


## The bunting (fountain to lamps, across the avenue), its posts and the confetti: one mesh, vertex colours, no shadow, no sway.
static func _decor_mesh(walkable: Callable, confetti: bool) -> MeshInstance3D:
	var tool: SurfaceTool = SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	var centre: Vector3 = Vector3(CapitalLayout.PLAZA_CENTER.x, 0.0, CapitalLayout.PLAZA_CENTER.y)
	for index: int in range(8):
		var angle: float = deg_to_rad(22.5 + 45.0 * float(index))
		var lamp: Vector3 = centre + Vector3(cos(angle), 0.0, sin(angle)) * CapitalLayout.PLAZA_LAMP_RADIUS
		_line(tool, centre + Vector3(0.0, FOUNTAIN_TOP, 0.0), lamp + Vector3(0.0, LAMP_TOP, 0.0), 0.55, index)
	for index: int in range(AVENUE_LINE_Z.size()):
		var z: float = AVENUE_LINE_Z[index]
		var west: Vector3 = Vector3(centre.x - AVENUE_HALF, 0.0, z)
		var east: Vector3 = Vector3(centre.x + AVENUE_HALF, 0.0, z)
		_post(tool, west)
		_post(tool, east)
		_line(tool, west + Vector3(0.0, POST_HEIGHT - 0.1, 0.0), east + Vector3(0.0, POST_HEIGHT - 0.1, 0.0), 0.8, index + 3)
	if confetti:
		var rng: RandomNumberGenerator = RandomNumberGenerator.new()
		rng.seed = 1112
		var placed: int = 0
		var tries: int = 0
		while placed < CONFETTI and tries < CONFETTI * 4:
			tries += 1
			var pos: Vector3
			if tries % 3 == 0:
				pos = Vector3(centre.x + rng.randf_range(-AVENUE_HALF + 0.6, AVENUE_HALF - 0.6), 0.0, rng.randf_range(16.0, 46.0))
			else:
				var reach: float = sqrt(rng.randf()) * (CapitalLayout.PLAZA_RADIUS + 1.0)
				var turn: float = rng.randf() * TAU
				pos = centre + Vector3(cos(turn) * reach, 0.0, sin(turn) * reach)
			if not bool(walkable.call(pos)):
				continue
			_confetto(tool, pos, rng)
			placed += 1
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.resource_name = "celebration_cloth"
	material.vertex_color_use_as_albedo = true
	material.vertex_color_is_srgb = true
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.roughness = 1.0
	tool.set_material(material)
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.name = "CelebrationDecor"
	instance.mesh = tool.commit()
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.set_meta(&"no_wind", true)
	instance.set_meta(&"no_occlusion_fade", true)
	return instance


## A sagging string from `from` to `to` with a pennant every 0.62 m (colours cycle, starting at `phase`).
static func _line(tool: SurfaceTool, from: Vector3, to: Vector3, sag: float, phase: int) -> void:
	var length: float = from.distance_to(to)
	var steps: int = maxi(4, int(length / 0.62))
	var along: Vector3 = (to - from).normalized()
	var side: Vector3 = Vector3.UP.cross(along).normalized()
	var previous: Vector3 = from
	for step: int in range(1, steps + 1):
		var t: float = float(step) / float(steps)
		var point: Vector3 = from.lerp(to, t) - Vector3(0.0, sag * 4.0 * t * (1.0 - t), 0.0)
		# the string: a thin ribbon
		_tri(tool, previous, point, point - Vector3(0.0, 0.03, 0.0), STRING_COLOUR, side)
		_tri(tool, previous, point - Vector3(0.0, 0.03, 0.0), previous - Vector3(0.0, 0.03, 0.0), STRING_COLOUR, side)
		# the pennant hangs from the middle of the span
		if step < steps:
			var mid: Vector3 = previous.lerp(point, 0.5)
			var half: Vector3 = (point - previous) * 0.36
			_tri(tool, mid - half, mid + half, mid - Vector3(0.0, 0.46, 0.0), PENNANT_COLOURS[(step + phase) % PENNANT_COLOURS.size()], Vector3.UP)  # lit from above: side normals put every pennant in the shade band
		previous = point


static func _post(tool: SurfaceTool, foot: Vector3) -> void:
	var r: float = 0.06
	var top: Vector3 = foot + Vector3(0.0, POST_HEIGHT, 0.0)
	for face: Vector3 in [Vector3(1, 0, 0), Vector3(-1, 0, 0), Vector3(0, 0, 1), Vector3(0, 0, -1)]:
		var across: Vector3 = Vector3.UP.cross(face) * r
		var out: Vector3 = face * r
		_tri(tool, foot + out - across, foot + out + across, top + out + across, POST_COLOUR, face)
		_tri(tool, foot + out - across, top + out + across, top + out - across, POST_COLOUR, face)


static func _confetto(tool: SurfaceTool, pos: Vector3, rng: RandomNumberGenerator) -> void:
	var turn: float = rng.randf() * TAU
	var a: Vector3 = Vector3(cos(turn), 0.0, sin(turn)) * rng.randf_range(0.05, 0.09)
	var b: Vector3 = Vector3(-sin(turn), 0.0, cos(turn)) * rng.randf_range(0.03, 0.05)
	var at: Vector3 = pos + Vector3(0.0, 0.035, 0.0)
	var colour: Color = CONFETTI_COLOURS[rng.randi() % CONFETTI_COLOURS.size()]
	_tri(tool, at - a - b, at + a - b, at + a + b, colour, Vector3.UP)
	_tri(tool, at - a - b, at + a + b, at - a + b, colour, Vector3.UP)


static func _tri(tool: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, colour: Color, normal: Vector3) -> void:
	for point: Vector3 in [a, b, c]:
		tool.set_normal(normal)
		tool.set_color(colour)
		tool.add_vertex(point)
