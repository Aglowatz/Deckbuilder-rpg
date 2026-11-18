extends GutTest
## Nov 18 evening, Part 1: the D.N.A. finished. A street of real buildings behind the painted fronts; nothing floats and nothing sits inside
## a wall (DnaPropProbe at zero); no pneumatic tubes; the time clock on its pillar; each elevator wall and its shafts are one piece; the
## stair's ghosts stand on their treads up the left side; the couch and the Waiting Room are easy to find.

var host: Node3D
var builder: DnaBuilder
var dressing: DnaDressing


func before_all() -> void:
	host = Node3D.new()
	add_child(host)
	builder = DnaBuilder.new()
	builder.build(host)
	dressing = DnaDressing.build(host, builder, 2)


func after_all() -> void:
	host.queue_free()


func test_nothing_floats_and_nothing_sits_inside_a_wall() -> void:
	var probe: DnaPropProbe = DnaPropProbe.run(builder, dressing)
	for line: String in probe.hits:
		gut.p("HIT " + line)
	gut.p("PROBE checked=%d hits=%d booths placed=%d left out=%d" % [probe.checked, probe.hits.size(), builder.booth_count, builder.booths_left_out])
	assert_gt(probe.checked, 150, "the probe looks at the zone's props")
	assert_eq(probe.hits.size(), 0, "no prop floats or overlaps a wall, a partition or a building")


func test_a_street_of_buildings_stands_behind_the_fronts() -> void:
	assert_not_null(builder.street, "the street is built")
	var buildings: Array[Dictionary] = builder.street.buildings
	assert_gt(buildings.size(), 10, "a row of buildings behind the north and west fronts")
	var heights: Dictionary = {}
	var towers: int = 0
	var layout: DnaLayout = builder.layout
	for b: Dictionary in buildings:
		var rect: Rect2 = b["rect"] as Rect2
		heights[snappedf(float(b["h"]), 0.1)] = true
		towers += int(bool(b["tower"]))
		assert_gte(minf(rect.size.x, rect.size.y), 3.0, "a real body, not a slab")
		assert_gte(float(b["h"]), DnaHall.HALL_H + 0.5, "taller than the front it stands behind")
		for cz: int in range(int(floorf(rect.position.y)), int(ceilf(rect.end.y))):
			for cx: int in range(int(floorf(rect.position.x)), int(ceilf(rect.end.x))):
				assert_false(layout.is_floor(cx, cz), "building %s stands off the walk grid (%d, %d)" % [str(rect), cx, cz])
		for keep: Rect2 in DnaStreet.RESERVED:
			assert_false(rect.intersects(keep), "clear of the Hall, its stair and the clock tower")
		var face: Vector2i = b["face"] as Vector2i
		assert_gte(rect.size.y if face.y != 0 else rect.size.x, DnaStreet.DEPTH_MIN - 0.01, "at least 6.5 m deep")
	assert_gte(heights.size(), 3, "the roof line steps (varied heights)")
	assert_gt(towers, 0, "a small tower on a long row")
	# every front cell has a building behind it, or the clock tower / the stair closes it
	var hall: DnaHall = builder.grand
	for c: Vector2i in hall.kinds.keys():
		if hall.kind_at(c) != DnaHall.Kind.OUTLINE:
			continue
		var covered: bool = false
		var open_sides: int = 0
		for outward: Vector2i in [Vector2i(0, -1), Vector2i(-1, 0)]:
			if not hall.is_outside(c + outward) or DnaStreet.ground_behind(hall, c, outward) < DnaStreet.MIN_GROUND_BEHIND:
				continue
			open_sides += 1
			var probe_at: Vector2 = Vector2(float(c.x) + 0.5, float(c.y) + 0.5) + Vector2(outward) * 1.5
			for b: Dictionary in buildings:
				if (b["rect"] as Rect2).grow(0.05).has_point(probe_at):
					covered = true
			for keep: Rect2 in DnaStreet.RESERVED:
				if keep.grow(1.6).has_point(probe_at):
					covered = true
		if open_sides > 0:
			assert_true(covered, "front cell %s has a building behind it" % str(c))


func test_the_shallow_farm_front_is_a_partition_now() -> void:
	var hall: DnaHall = builder.grand
	for x: int in range(2, 13):
		assert_ne(hall.kind_at(Vector2i(x, 25)), DnaHall.Kind.OUTLINE, "Cubicle Farm A north wall (2 m of ground behind it) is low")


func test_no_tubes_and_the_time_clock_stands_on_its_pillar() -> void:
	assert_eq(host.find_children("TubeBrackets", "", true, false).size(), 0, "no tube brackets")
	var clocks: Array[Node] = host.find_children("TimeClock", "Node3D", true, false)
	assert_eq(clocks.size(), 1, "one time clock")
	var clock: Node3D = clocks[0] as Node3D
	assert_almost_eq(clock.global_position.y, 0.0, 0.01, "the pillar stands on the floor")
	var wall_x: float = 17.5 + DnaHall.PARTITION_T * 0.5
	assert_lt(clock.global_position.x - 0.31 - wall_x, 0.35, "against the breakroom west wall")
	var spot: Vector3 = builder.anchor("time_clock")
	assert_lt(Vector2(spot.x, spot.z).distance_to(Vector2(clock.global_position.x, clock.global_position.z)), 1.4, "the Punch in spot is a step in front of it")
	assert_false(builder.is_walkable(clock.global_position, 0.2), "solid")


func test_each_elevator_wall_and_its_shafts_are_one_piece() -> void:
	assert_eq(builder.lift_banks.size(), 2)
	assert_gte(DnaBuilder.ELEVATOR_WALL_H, 4.0, "a storey and a half: as tall as the shafts")
	for bank: Node3D in builder.lift_banks:
		var meshes: Array[Node] = bank.find_children("*", "MeshInstance3D", true, false)
		assert_eq(meshes.size(), 3, "one wall and two elevators in one node")
		for mesh: Node in meshes:
			assert_eq(mesh.get_parent(), bank, "direct children: the camera cut-away dissolves them together")
			assert_false(mesh.has_meta(&"no_occlusion_fade"), "none is left standing when the rest fades")
			var box: AABB = (mesh as MeshInstance3D).global_transform * (mesh as MeshInstance3D).get_aabb()
			assert_lte(box.end.y, DnaBuilder.ELEVATOR_WALL_H + 0.6, "nothing pokes above the wall")


func test_the_stair_ghosts_stand_on_their_treads_up_the_left_side() -> void:
	assert_gte(builder.stair_ghosts.size(), 6, "a line of ghosts")
	var hall_x: float = DnaLayout.HALL_CENTER.x
	for ghost: Dictionary in builder.stair_ghosts:
		var at: Vector3 = ghost["pos"] as Vector3
		assert_true(at.y >= float(ghost["tread"]) - 0.001 and at.y <= float(ghost["tread"]) + 0.05, "feet on the tread")
		assert_lt(at.x, hall_x - 1.2, "on the left side: the middle of the stair stays clear")
	var source: String = FileAccess.get_file_as_string("res://world/dna/dna_landmarks.gd")
	assert_false(source.contains("the ghost queue on the steps, shuffling up"), "the sunk queue cards are gone")


func test_the_couch_is_easy_to_find() -> void:
	var couches: Array[Node] = host.find_children("HealCouch", "Node3D", true, false)
	assert_eq(couches.size(), 1, "the couch is built")
	var heal: Vector3 = builder.anchor("heal")
	assert_lt(heal.distance_to(DnaLayout.COUCH_POS), 2.0, "the heal spot is in front of it")
	assert_true(builder.is_walkable(heal, 0.3), "and can be stood on")
	var lit: bool = false
	for light: DnaLayout.LightSpot in builder.layout.lights:
		if light.pos.distance_to(DnaLayout.COUCH_POS + Vector3(0, 2.6, 0.6)) < 0.1:
			lit = true
	assert_true(lit, "a warm light over the couch")
	assert_true(DnaBuilder.ICON_BOARDS.has("sign.heal_couch"), "a heart sign")
	assert_eq(DnaBuilder.sign_icon("sign.heal_couch"), "ICON-MAP-HEAL")
	var def: ZoneDef = DnaZone.build_def()
	var spot: Dictionary = {}
	for entry: Dictionary in def.spots:
		if str(entry["id"]) == "heal":
			spot = entry
	assert_eq(str(spot.get("place_label", "")), "Breakroom: rest here", "its screen label")
	assert_eq(def.poi_kinds.get("heal"), MapPoi.Kind.HEAL, "the map and minimap heart")


func test_the_waiting_room_is_easy_to_find() -> void:
	var def: ZoneDef = DnaZone.build_def()
	var spot: Dictionary = {}
	for entry: Dictionary in def.spots:
		if str(entry["id"]) == "mini_dungeon":
			spot = entry
	assert_eq(str(spot.get("title", "")), "The Waiting Room of Eternity", "named for the dungeon (not Sub-Basement 3)")
	assert_eq(str(spot.get("place_label", "")), DnaZone.PLACE_LABEL_WAITING_ROOM)
	assert_eq(def.poi_kinds.get("mini_dungeon"), MapPoi.Kind.MINI_DUNGEON, "a map and minimap icon (shown once explored)")
	var door: Vector3 = builder.anchor("mini_dungeon")
	assert_true(DnaHall.on_runner(door.x, door.z - 0.6), "a red runner leads to the door")
	assert_true(DnaHall.on_runner(45.5, door.z), "from the main axis")
	var lit: int = 0
	for light: DnaLayout.LightSpot in builder.layout.lights:
		if Vector2(light.pos.x, light.pos.z).distance_to(Vector2(door.x, door.z)) < 2.5:
			lit += 1
	assert_gte(lit, 2, "the doorway is lit")
	var hanging: Dictionary = {}
	for s: Dictionary in builder.sign_spots:
		if str(s["key"]) == "sign.mini_dungeon":
			hanging = s
	assert_false(hanging.is_empty(), "the hanging sign")
	assert_almost_eq((hanging["pos"] as Vector3).x, door.x, 0.01, "over the door")
	assert_gt(float(hanging["bottom"]), 1.95, "above the doors")
	assert_eq(DnaBuilder.plaque_index("sign.mini_dungeon"), 2, "the clock plaque (waiting); a painted hourglass is a Batch 18 row")


func test_the_aisles_round_the_new_pieces_stay_clear() -> void:
	for at: Vector3 in [Vector3(33.4, 0, 56.5), Vector3(20.2, 0, 53.5), Vector3(49.0, 0, 18.6), Vector3(45.5, 0, 20.0), Vector3(29.6, 0, 52.6)]:
		assert_true(builder.is_walkable(at, 1.0), "a 2 m body fits at %s" % str(at))


func test_every_npc_chest_the_couch_and_the_waiting_room_are_reachable() -> void:
	var targets: Dictionary = {}
	for key: String in ["dolores", "barnaby", "pip", "quiz", "matching", "heal", "time_clock", "coffee", "mini_dungeon", "main_dungeon", "puzzle", "printer", "suggestion", "giant_chest", "vault_lever"]:
		if builder.has_anchor(key):
			targets[key] = builder.anchor(key)
	for id: Variant in builder.layout.chests.keys():
		targets[str(id)] = builder.layout.chests[id] as Vector3
	var can_stand: Callable = func(pos: Vector3) -> bool: return builder.is_walkable(pos)
	var missing: Array[String] = WalkProbe.unreachable(can_stand, builder.anchor("spawn"), builder.map_bounds(), targets, 2.5)
	assert_eq(missing, [] as Array[String], "everything worth walking to is reachable from the causeway")
