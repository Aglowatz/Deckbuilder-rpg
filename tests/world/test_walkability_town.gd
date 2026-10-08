extends GutTest
## The automated walkability check for the main town: from the spawn point the hero can path to every key location
## (vendors, NPCs, chests, quest givers, zone exits, travel point), and the lanes between them stay wide.

## Minimum body radius every key lane must still admit (a 1.2 m wide lane).
const MIN_LANE_RADIUS: float = 0.5

var _town: TownBuilder
var _targets: Dictionary = {}


func before_each() -> void:
	var root: Node3D = Node3D.new()
	add_child_autofree(root)
	_town = TownBuilder.new()
	_town.build(root)
	TownSquare.build(root, _town, GraphicsQuality.Level.MEDIUM)
	# What TownScene adds on top of the builder: the Rift Express frame and the NPCs' bodies.
	var rift: Vector3 = _town.anchors["rift_station"] as Vector3
	_town.obstacles.append(Vector3(rift.x, rift.z, 1.3))
	for key: String in _town.anchors.keys():
		if key.begins_with("npc_"):
			var npc: Vector3 = _town.anchors[key] as Vector3
			_town.obstacles.append(Vector3(npc.x, npc.z, 0.3))
	_targets.clear()
	for key: String in _town.anchors.keys():
		# The spawn is the origin of the check; the sealed vault and the pitch-black dev shrine are reached on purpose, the rest must be.
		# "plaza" and "fountain" mark the solid fountain's centre; the plaza ring around it is covered by the spawn standing on it.
		if key == "spawn" or key == "plaza" or key == "fountain" or key.ends_with("_mouth") or key == "arena_gate" or key == "alchemist_door":
			continue
		_targets[key] = _town.anchors[key]
	# The Express frame is solid: the hero talks to it from its interact spot, just in front.
	_targets["rift_station"] = rift + Vector3(0.0, 0.0, 1.6)


func _can_stand(radius: float) -> Callable:
	return func(pos: Vector3) -> bool: return _town.is_walkable(pos, radius)


func test_every_key_location_is_reachable_from_the_spawn() -> void:
	var spawn: Vector3 = _town.anchors["spawn"] as Vector3
	var missing: Array[String] = WalkProbe.unreachable(_can_stand(0.22), spawn, _town.map_bounds(), _targets)
	assert_eq(missing, [] as Array[String], "unreachable from the spawn: %s" % str(missing))


func test_lanes_between_key_locations_stay_wide() -> void:
	var spawn: Vector3 = _town.anchors["spawn"] as Vector3
	var make: Callable = func(radius: float) -> Callable: return _can_stand(radius)
	var clearance: float = WalkProbe.lane_clearance(make, spawn, _town.map_bounds(), _targets)
	gut.p("town lane clearance (body radius that still reaches everything): %.2f" % clearance)
	gut.p("cut off just above that width: %s" % str(WalkProbe.unreachable(_can_stand(clearance + 0.05), spawn, _town.map_bounds(), _targets)))
	assert_gte(clearance, MIN_LANE_RADIUS, "every key location is reachable with a 1 m wide body")


func test_dump_map_when_asked() -> void:
	var path: String = OS.get_environment("DUMP_TOWN")
	if path == "":
		pass_test("no dump requested")
		return
	var spawn: Vector3 = _town.anchors["spawn"] as Vector3
	var can: Callable = _can_stand(0.22)
	var reached: Dictionary = WalkProbe.flood(can, spawn, _town.map_bounds())
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	var bounds: Rect2 = _town.map_bounds()
	file.store_string("bounds %s step 0.9\n%s\n" % [str(bounds), WalkProbe.ascii(can, reached, bounds, _targets)])
	file.close()
	pass_test("dumped")


func test_dump_free_cells_when_asked() -> void:
	var path: String = OS.get_environment("DUMP_CELLS")
	if path == "":
		pass_test("no dump requested")
		return
	var out: PackedStringArray = PackedStringArray()
	for cell: Vector2i in _town.walkable.keys():
		var pos: Vector3 = _town.cell_center(cell.x, cell.y)
		var near_anchor: float = 1.0e9
		var near_key: String = ""
		for key: String in _town.anchors.keys():
			var a: Vector3 = _town.anchors[key] as Vector3
			var d: float = Vector2(a.x - pos.x, a.z - pos.z).length()
			if d < near_anchor:
				near_anchor = d
				near_key = key
		var near_obstacle: float = 1.0e9
		for o: Vector3 in _town.obstacles:
			near_obstacle = minf(near_obstacle, Vector2(o.x - pos.x, o.y - pos.z).length() - o.z)
		out.append("%d,%d  x=%.1f z=%.1f  anchor %.1f (%s)  obstacle %.1f" % [cell.x, cell.y, pos.x, pos.z, near_anchor, near_key, near_obstacle])
	out.sort()
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_string("\n".join(out))
	file.close()
	pass_test("dumped")
