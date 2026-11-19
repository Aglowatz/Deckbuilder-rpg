extends GutTest
## Nov 18 day, Part 6: the D.N.A. back outdoors. Open air (no ceiling, no end bay); painted building fronts only on the north side and the west
## long side, the rest of the outline waist-high so the player sees out; desk islands with wide aisles (no cubicle dead ends); the camera a
## little steeper in the D.N.A. only; the clock tower landmark; tall thick walls round the elevators; the Hall's big door.


var layout: DnaLayout
var hall: DnaHall


func before_all() -> void:
	layout = DnaLayout.new()
	layout.build()
	hall = DnaHall.new(layout)


func test_it_is_open_air() -> void:
	assert_true(DnaBuilder.OPEN_AIR, "no ceiling and no end bay")
	var source: String = FileAccess.get_file_as_string("res://world/dna/dna_builder.gd")
	assert_true(source.contains("if not OPEN_AIR:\n\t\t_build_ceiling(dark)"), "the ceiling is only built for a closed hall")
	assert_false(source.get_slice("func _build_grand_hall()", 1).get_slice("\nfunc ", 0).contains("the chain up into the dark"), "chandeliers float")


func test_building_fronts_only_on_the_north_and_west() -> void:
	var fronts: int = 0
	for c: Vector2i in hall.kinds.keys():
		if hall.kind_at(c) != DnaHall.Kind.OUTLINE:
			continue
		fronts += 1
		assert_true(hall.is_front(c), "outline cell %s is a building front" % str(c))
		assert_true(c.y <= DnaHall.FRONT_NORTH_MAX_Z or c.x <= DnaHall.FRONT_WEST_MAX_X, "%s is on the north or west side" % str(c))
	assert_gt(fronts, 40, "the north and west sides keep their painted walls")
	# the south face (the lobby, the breakroom) and the east side are open: partitions on the same wall cells
	for c: Vector2i in hall.kinds.keys():
		if c.y > 48 or (c.x > 86 and c.y > 5):
			assert_ne(hall.kind_at(c), DnaHall.Kind.OUTLINE, "%s is low (the player sees out)" % str(c))


func test_the_farms_are_desk_islands_with_wide_aisles() -> void:
	for farm: Array in [["farm_a", Rect2i(2, 26, 32, 18)], ["farm_b", Rect2i(56, 26, 32, 18)]]:
		var islands: Array[Dictionary] = DnaLayout.desk_islands(str(farm[0]), farm[1] as Rect2i)
		assert_lt(islands.size(), 27, "fewer desks than the old 27 cubicles")
		for i: int in range(islands.size()):
			for j: int in range(i + 1, islands.size()):
				var a: Dictionary = islands[i]
				var b: Dictionary = islands[j]
				var gap_x: float = maxf((b["a"] as Vector3).x - (a["b"] as Vector3).x, (a["a"] as Vector3).x - (b["b"] as Vector3).x) - 1.0
				var gap_z: float = absf((a["a"] as Vector3).z - (b["a"] as Vector3).z) - 1.6
				assert_true(gap_x >= 2.5 or gap_z >= 2.5, "islands %d and %d leave at least 2.5 m between them" % [i, j])
	for spawn: Dictionary in layout.enemy_spawns:
		var home: Vector3 = spawn["home"] as Vector3
		var c: Vector2i = DnaLayout.world_to_cell(home)
		assert_true(layout.is_floor(c.x, c.y), "roamer home %s stays on the floor" % str(home))


func test_the_dna_camera_looks_down_a_little_more() -> void:
	assert_between(ZoneCamera.pitch_bonus(DnaZone.ID), 4.0, 10.0, "steeper than the presets (Fable Nov 20: +4 like every place, it was +6); the number lives in data/camera/zone_camera.json")
	CameraRig.zone_pitch_bonus = 0.0
	var flat: Vector3 = CameraRig.shape(WorldLookRig.base_offset())
	CameraRig.zone_pitch_bonus = ZoneCamera.pitch_bonus(DnaZone.ID)
	var steep: Vector3 = CameraRig.shape(WorldLookRig.base_offset())
	CameraRig.zone_pitch_bonus = 0.0
	var pitch_flat: float = rad_to_deg(atan2(flat.y, Vector2(flat.x, flat.z).length()))
	var pitch_steep: float = rad_to_deg(atan2(steep.y, Vector2(steep.x, steep.z).length()))
	assert_almost_eq(pitch_steep - pitch_flat, ZoneCamera.pitch_bonus(DnaZone.ID), 0.01)
	assert_almost_eq(flat.length(), steep.length(), 0.01, "same distance: only the pitch changes")


func test_the_landmarks_and_walls() -> void:
	assert_gt(DnaBuilder.CLOCK_BODY_H, DnaHall.PARTITION_H * 4.0, "the tower rises far above the partitions")
	assert_gt(DnaBuilder.CLOCK_BODY_H + DnaBuilder.CLOCK_STAGE_H, DnaHall.HALL_H, "and its clock stage above the building fronts")
	assert_lt(DnaBuilder.CLOCK_TOWER.z, 0.0, "outside the plaza, beyond the north side")
	assert_gt(DnaBuilder.ELEVATOR_WALL_H, 1.82 + 0.3, "the elevator doors (1.82 m) sit inside the wall")
	assert_gte(DnaLayout.ELEVATOR_WALL_Z - 14.0, 2.0, "deep enough for a shaft")
	assert_gte(DnaLandmarks.DOOR_MAX_H, 10.0, "a big door")
	assert_gt(DnaLandmarks.PYLON_THICKNESS, 2.0, "thick pylons beside the stair")
