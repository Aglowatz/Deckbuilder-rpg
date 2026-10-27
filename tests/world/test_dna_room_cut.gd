extends GutTest
## Fixes Oct 27, Part 2: the D.N.A.'s walls cut away for the hero's room (DnaRoomCut + dna_fade.gdshader `room_cut`), checked with the GDScript copy of the
## shader's test over every room and corridor, at the three zooms and the three angles: the walls that hide the hero's floor fade, the room's far and side
## walls and the walls elsewhere stay solid, the hero is never behind a standing wall, and no wall changes by more than a little from one frame to the next.

const FRAME: float = 1.0 / 60.0
## Walking speed (m/s) for the frame-to-frame check.
const WALK: float = StorybookScale.WALK_SPEED
## The most a wall's fade may change in one frame (a pop is 0 -> 1 at once).
const MAX_FRAME_STEP: float = 0.2

var layout: DnaLayout
var walls: Array[Vector2] = []
var _angle: int = 0
var _zoom: float = 1.5


func before_all() -> void:
	layout = DnaLayout.new()
	layout.build()
	for cz: int in range(DnaLayout.H):
		for cx: int in range(DnaLayout.W):
			# the approach causeway's knee-high parapets are outdoors, not fading pieces (DnaBuilder._build_interior)
			if layout.cell_at(cx, cz) == DnaLayout.Cell.WALL and not (cz >= DnaLayout.APPROACH_Z0 and DnaInterior.room_beside(layout, Vector2i(cx, cz)) == ""):
				walls.append(Vector2(cx + 0.5, cz + 0.5))
	_angle = Settings.camera_angle
	_zoom = Settings.camera_zoom


func after_all() -> void:
	Settings.camera_angle = _angle
	Settings.camera_zoom = _zoom
	CameraRig.reset_swivel()


func _cam(hero: Vector3) -> Vector3:
	return hero + CameraRig.shape(WorldLookRig.base_offset())


func _views() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for angle: int in range(CameraRig.ANGLE_PITCH.size()):
		for zoom: int in range(CameraRig.ZOOM_VALUES.size()):
			result.append(Vector2i(angle, zoom))
	return result


func _set_view(view: Vector2i) -> void:
	Settings.camera_angle = view.x
	Settings.camera_zoom = CameraRig.ZOOM_VALUES[view.y]


## Spots on a room's floor, a metre in from its edges, every `step` metres.
func _spots(rect: Rect2i, step: float = 3.0) -> Array[Vector3]:
	var result: Array[Vector3] = []
	var x: float = rect.position.x + 1.0
	while x <= rect.end.x - 1.0:
		var z: float = rect.position.y + 1.0
		while z <= rect.end.y - 1.0:
			result.append(Vector3(x, 0.0, z))
			z += step
		x += step
	return result


func test_walls_hiding_the_room_fade_and_the_rest_stay_solid() -> void:
	var problems: PackedStringArray = []
	for view: Vector2i in _views():
		_set_view(view)
		for room: DnaLayout.Room in layout.rooms:
			var rect: Rect2 = Rect2(room.rect.position, room.rect.size)
			for hero: Vector3 in _spots(room.rect, 4.0):
				var cam: Vector3 = _cam(hero)
				var cam2: Vector2 = Vector2(cam.x, cam.z)
				for wall: Vector2 in walls:
					var fade: float = DnaRoomCut.piece_fade(wall, cam2, rect)
					var beside: bool = wall.x > rect.position.x - 1.0 and wall.x < rect.end.x + 1.0 and wall.y > rect.position.y - 1.0 and wall.y < rect.end.y + 1.0
					# the far wall (north, away from the camera) and every wall farther north than the room never fade
					if wall.y < rect.position.y + 0.1 and fade > 0.0:
						problems.append("%s %s hero %s: the far wall at %s fades %.2f" % [room.id, view, hero, wall, fade])
					# the near wall (south), in the room's width, fades fully while the camera stands outside the room
					var outside: bool = cam2.y > rect.end.y + 0.65
					if beside and outside and wall.y > rect.end.y and wall.x > rect.position.x + 0.5 and wall.x < rect.end.x - 0.5 and fade < 0.99:
						problems.append("%s %s hero %s: the near wall at %s only %.2f" % [room.id, view, hero, wall, fade])
	assert_eq(problems.size(), 0, "\n".join(problems.slice(0, 12)))


func test_the_hero_is_never_behind_a_standing_wall() -> void:
	var problems: PackedStringArray = []
	var regions: Array[Rect2i] = []
	for room: DnaLayout.Room in layout.rooms:
		regions.append(room.rect)
	regions.append_array(layout.links)
	var cut: DnaRoomCut = DnaRoomCut.new(layout)
	for view: Vector2i in _views():
		_set_view(view)
		for region: Rect2i in regions:
			for hero: Vector3 in _spots(region, 2.0) if region.size.x > 2 and region.size.y > 2 else [Vector3(region.get_center().x, 0.0, region.get_center().y)] as Array[Vector3]:
				if not layout.is_floor(int(hero.x), int(hero.z)):
					continue
				cut.snap(cut.region_at(hero))
				var cam: Vector3 = _cam(hero)
				var a: Vector2 = Vector2(cam.x, cam.z)
				var b: Vector2 = Vector2(hero.x, hero.z)
				for wall: Vector2 in walls:
					# a wall cell (1 m square, 10 m tall: above every sight line) on the line to the hero's body, nearer than the hero
					var closest: Vector2 = Geometry2D.get_closest_point_to_segment(wall, a, b)
					if closest.distance_to(wall) > 0.45 or closest.distance_to(b) < 0.7:
						continue
					var fade: float = cut.fade_now(wall, a)
					if fade < 0.9:
						problems.append("view %s hero %s: the wall at %s stands in front (fade %.2f)" % [view, hero, wall, fade])
	assert_eq(problems.size(), 0, "\n".join(problems.slice(0, 12)))


## A walk through the zone, frame by frame at walking speed, room to room through the doorways: no wall's fade jumps.
func test_no_wall_pops_between_frames() -> void:
	var route: Array[Vector3] = [
		Vector3(46.5, 0, 63.5), Vector3(46.5, 0, 50.0), Vector3(40.0, 0, 52.5), Vector3(30.0, 0, 52.5), Vector3(25.5, 0, 50.0), Vector3(25.5, 0, 40.0),
		Vector3(16.0, 0, 30.0), Vector3(16.0, 0, 20.0), Vector3(16.0, 0, 30.0), Vector3(30.0, 0, 34.5), Vector3(45.0, 0, 34.5), Vector3(45.0, 0, 20.0),
		Vector3(45.0, 0, 8.0), Vector3(45.0, 0, 20.0), Vector3(60.0, 0, 19.5), Vector3(72.0, 0, 15.0), Vector3(71.5, 0, 30.0), Vector3(55.0, 0, 34.5),
		Vector3(45.0, 0, 44.0), Vector3(46.5, 0, 52.0),
	]
	for view: Vector2i in [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 2)]:
		_set_view(view)
		var cut: DnaRoomCut = DnaRoomCut.new(layout)
		cut.snap(cut.region_at(route[0]))
		var last: Dictionary = {}
		var worst: float = 0.0
		var where: String = ""
		var regions: int = 0
		for leg: int in range(route.size() - 1):
			var from: Vector3 = route[leg]
			var to: Vector3 = route[leg + 1]
			var steps: int = maxi(1, ceili(from.distance_to(to) / (WALK * FRAME)))
			for i: int in range(1, steps + 1):
				var hero: Vector3 = from.lerp(to, float(i) / float(steps))
				if cut.update(hero, FRAME):
					regions += 1
				var cam: Vector3 = _cam(hero)
				var a: Vector2 = Vector2(cam.x, cam.z)
				for wall: Vector2 in walls:
					if wall.distance_to(a) > 40.0:
						continue
					var fade: float = cut.fade_now(wall, a)
					if last.has(wall):
						var jump: float = absf(fade - float(last[wall]))
						if jump > worst:
							worst = jump
							where = "wall %s near hero %s" % [wall, hero]
					last[wall] = fade
		assert_gt(regions, 10, "the walk crosses rooms and corridors")
		assert_lt(worst, MAX_FRAME_STEP, "view %s: the biggest change in one frame is %.2f (%s)" % [view, worst, where])


func test_the_shader_and_the_materials_use_the_room_cut() -> void:
	var shader: String = FileAccess.get_file_as_string("res://world/dna/dna_fade.gdshader")
	for name: String in ["uniform bool room_cut", "uniform vec4 room_a", "uniform vec4 room_b", "uniform vec4 room_c", "uniform vec3 room_w", "float room_fade("]:
		assert_true(shader.contains(name), name)
	var fade: DnaFadeMesh = DnaInterior.mesh()
	assert_not_null(fade)
	var found: int = 0
	for material: ShaderMaterial in DnaMaterials.fade_materials():
		if material.get_shader_parameter("room_cut") == true:
			found += 1
	assert_gt(found, 0, "the interior walls cut by room")
