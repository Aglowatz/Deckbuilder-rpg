extends GutTest
## Overnight Nov 10-11 (Part 1.2, the exported-build critic's #2: a Gelatin Sentinel camped the Test Kitchen's door): no roamer's wander
## area (its home +/- its patrol radius, a road guard's challenge radius) comes within `ZoneScene.ROAMER_DOOR_CLEARANCE` of a dungeon door,
## a gate or a zone exit, in any zone - the Gainlands, the D.N.A., the Endless Buffet, the Verdant Dump and the Capital - and the exit roamer
## the scene adds keeps the same distance from the exit.

const DOOR_KINDS: Array[String] = ["exit", "main_dungeon", "mini_dungeon"]


func _builder(zone_id: String) -> ZoneMap:
	match zone_id:
		"beefcake":
			var gainlands: GainlandsBuilder = GainlandsBuilder.new()
			gainlands.layout.build()
			gainlands._index_obstacles()
			return gainlands
		"necrocrat":
			var dna: DnaBuilder = DnaBuilder.new()
			dna.layout.build()
			dna._index_obstacles()
			return dna
		"gourmand":
			var buffet: BuffetBuilder = BuffetBuilder.new()
			buffet.layout.build()
			buffet._index_obstacles()
			return buffet
		"refusemancer":
			var heap: HeapBuilder = HeapBuilder.new()
			heap.layout.build()
			heap._index_obstacles()
			return heap
		CapitalZone.ID:
			var capital: CapitalBuilder = CapitalBuilder.new()
			capital.layout.build()
			capital._index_obstacles()
			return capital
	return null


## The doors, gates and exits of a zone: [{"id", "pos"}], from the zone's spot table resolved against the builder's anchors.
static func doors_of(def: ZoneDef, builder: ZoneMap) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry: Dictionary in def.spots:
		var id: String = str(entry["id"])
		var kind: String = str(entry["kind"])
		var is_gate: bool = entry.has("gate") or int(def.poi_kinds.get(id, -1)) == MapPoi.Kind.GATE
		if not (kind in DOOR_KINDS or is_gate):
			continue
		if not builder.has_anchor(str(entry["anchor"])):
			continue
		result.append({"id": id, "pos": builder.anchor(str(entry["anchor"])) + (entry["offset"] as Vector3)})
	return result


## The offenders of one zone: "roamer (x, z) r=patrol is N m from door" lines.
static func offenders(def: ZoneDef, builder: ZoneMap) -> PackedStringArray:
	var lines: PackedStringArray = []
	var doors: Array[Dictionary] = doors_of(def, builder)
	var spawns: Array[Dictionary] = builder.enemy_spawns()
	for spawn: Dictionary in spawns:
		var home: Vector3 = spawn["home"] as Vector3
		# a road guard (the Gainlands' Gauntlet) stands still and IS the obstacle on its road by design; it never wanders to a door
		if float(spawn.get("guard", 0.0)) > 0.0:
			continue
		var reach: float = float(spawn.get("patrol", 0.0))
		for door: Dictionary in doors:
			var at: Vector3 = door["pos"] as Vector3
			var distance: float = Vector2(home.x - at.x, home.z - at.z).length() - reach
			if distance < ZoneScene.ROAMER_DOOR_CLEARANCE:
				lines.append("%s %s (%.1f, %.1f) r=%.1f is %.1f m from %s; nearest fitting home: %s" % [def.id, str(spawn.get("id", spawn["type"])), home.x, home.z, reach, distance, str(door["id"]), suggest(builder, doors, spawns, home, reach)])
	# the exit roamer the scene adds when no roamer is in sight of the exit
	if def.id != CapitalZone.ID and builder.has_anchor("exit") and builder.has_anchor("spawn"):
		var exit_pos: Vector3 = builder.anchor("exit")
		var home: Vector3 = ZoneScene.exit_roamer_home(exit_pos, builder.anchor("spawn"), func(at: Vector3) -> bool: return builder.is_walkable(at, 0.5))
		if home != Vector3.INF:
			for door: Dictionary in doors:
				var at: Vector3 = door["pos"] as Vector3
				var distance: float = Vector2(home.x - at.x, home.z - at.z).length() - 3.0
				if distance < ZoneScene.ROAMER_DOOR_CLEARANCE:
					lines.append("%s exit_roamer (%.1f, %.1f) r=3.0 is %.1f m from %s" % [def.id, home.x, home.z, distance, str(door["id"])])
	return lines


## The nearest enemy-walkable point (1 m grid, within 30 m) that keeps the clearance from every door and 4 m from every other roamer's
## home - a suggestion for the layout, printed with each offender.
static func suggest(builder: ZoneMap, doors: Array[Dictionary], spawns: Array[Dictionary], home: Vector3, reach: float) -> String:
	var best: Vector3 = Vector3.INF
	var best_distance: float = 1e9
	for dz: int in range(-30, 31):
		for dx: int in range(-30, 31):
			var at: Vector3 = Vector3(home.x + float(dx), 0.0, home.z + float(dz))
			var moved: float = Vector2(float(dx), float(dz)).length()
			if moved >= best_distance or not builder.is_enemy_walkable(at, 0.5):
				continue
			var ok: bool = true
			for door: Dictionary in doors:
				var door_pos: Vector3 = door["pos"] as Vector3
				if Vector2(at.x - door_pos.x, at.z - door_pos.z).length() - reach < ZoneScene.ROAMER_DOOR_CLEARANCE + 0.5:
					ok = false
					break
			for other: Dictionary in spawns:
				var other_home: Vector3 = other["home"] as Vector3
				if other_home != home and Vector2(at.x - other_home.x, at.z - other_home.z).length() < 4.0:
					ok = false
					break
			if ok:
				best = at
				best_distance = moved
	return "none within 30 m" if best == Vector3.INF else "(%.1f, %.1f)" % [best.x, best.z]


func _check_zone(zone_id: String) -> void:
	var def: ZoneDef = ZoneDefs.get_def(zone_id)
	assert_not_null(def, zone_id)
	var builder: ZoneMap = _builder(zone_id)
	assert_not_null(builder, "%s builds headless" % zone_id)
	if def == null or builder == null:
		return
	var doors: Array[Dictionary] = doors_of(def, builder)
	assert_gt(doors.size(), 0, "%s has doors, gates or exits to keep clear" % zone_id)
	assert_gt(builder.enemy_spawns().size(), 0, "%s has roamers" % zone_id)
	var lines: PackedStringArray = offenders(def, builder)
	assert_eq(lines.size(), 0, "%s: every roamer keeps %.0f m from doors, gates and exits:\n%s" % [zone_id, ZoneScene.ROAMER_DOOR_CLEARANCE, "\n".join(lines)])
	for spawn: Dictionary in builder.enemy_spawns():
		var home: Vector3 = spawn["home"] as Vector3
		var walkable: bool = builder.is_enemy_walkable(home)
		assert_true(walkable, "%s: %s's home (%.1f, %.1f) is ground a roamer may walk%s" % [zone_id, str(spawn.get("id", spawn["type"])), home.x, home.z,
			"" if walkable else "; nearest fitting home: " + suggest(builder, doors, builder.enemy_spawns(), home, float(spawn.get("patrol", 0.0)))])
	gut.p("%s: %d roamers against %d doors/gates/exits - %s" % [zone_id, builder.enemy_spawns().size(), doors.size(), ", ".join(doors.map(func(d: Dictionary) -> String: return str(d["id"])))])


func test_the_gainlands_roamers_keep_clear_of_doors() -> void:
	_check_zone("beefcake")


func test_the_dna_roamers_keep_clear_of_doors() -> void:
	_check_zone("necrocrat")


func test_the_buffet_roamers_keep_clear_of_doors() -> void:
	_check_zone("gourmand")


func test_the_dump_roamers_keep_clear_of_doors() -> void:
	_check_zone("refusemancer")


func test_the_capital_roamers_keep_clear_of_doors() -> void:
	_check_zone(CapitalZone.ID)


func test_the_exit_roamer_stands_clear_of_the_exit() -> void:
	var home: Vector3 = ZoneScene.exit_roamer_home(Vector3(50, 0, 90), Vector3(50, 0, 60), func(_at: Vector3) -> bool: return true)
	assert_gte(Vector2(home.x - 50.0, home.z - 90.0).length() - 3.0, ZoneScene.ROAMER_DOOR_CLEARANCE, "home %s with a 3 m patrol keeps the clearance" % str(home))
	assert_lte(Vector2(home.x - 50.0, home.z - 90.0).length(), ZoneScene.EXIT_ROAMER_SIGHT, "...and stays within sight of the exit")
