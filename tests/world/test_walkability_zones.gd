extends GutTest
## The automated walkability check for the starting area and every zone: from the spawn point the hero can walk to every key location
## (vendors, NPCs, chests, quest givers, exits, dungeon entrances, travel points). Targets that are reachable only by a throw or a portal
## (the Gainlands' floating islands) are checked against the island-travel network instead.

## Body radius every reachable target must still admit (a lane at least 0.7 m wide).
const MIN_LANE_RADIUS: float = 0.35
## Anchors that are not places to walk to (camera marks, decorative anchors that sit inside solid scenery).
const NOT_A_DESTINATION: Array[String] = ["spawn", "fountain"]  # the Capital fountain anchor is the statue prop itself: scenery, no prompt
## An interact spot is reachable when the hero can stand this close (the biggest props - a stable, a fountain - are about 2 m in radius).
const SPOT_SLACK: float = 2.5

var _report: PackedStringArray = PackedStringArray()


func _make_zone(zone_id: String) -> ZoneMap:
	var zone_map: ZoneMap = null
	match zone_id:
		"dna":
			var dna: DnaBuilder = DnaBuilder.new()
			dna.layout.build()
			dna._index_obstacles()
			zone_map = dna
		"gainlands":
			var gain: GainlandsBuilder = GainlandsBuilder.new()
			gain.layout.build()
			gain._index_obstacles()
			zone_map = gain
		"buffet":
			var buffet: BuffetBuilder = BuffetBuilder.new()
			buffet.layout.build()
			buffet._index_obstacles()
			buffet._gate_blockers.clear()  # every progression gate open
			zone_map = buffet
		"heap":
			var heap: HeapBuilder = HeapBuilder.new()
			heap.layout.build()
			heap._index_obstacles()
			for barricade: String in heap.layout.barricade_positions.keys():
				heap.smash_barricade(barricade)
			heap.mounted = true  # the scree is walkable on a mount
			zone_map = heap
		"capital":
			var capital: CapitalBuilder = CapitalBuilder.new()
			capital.layout.build()
			capital._index_obstacles()
			capital.gate_open = true
			zone_map = capital
	return zone_map


func _targets_for(zone_id: String, zone_map: ZoneMap) -> Dictionary:
	var targets: Dictionary = {}
	var anchors: Dictionary = {}
	var chests: Dictionary = zone_map.chest_positions()
	match zone_id:
		"dna":
			anchors = (zone_map as DnaBuilder).layout.anchors
		"gainlands":
			anchors = (zone_map as GainlandsBuilder).layout.anchors
		"buffet":
			anchors = (zone_map as BuffetBuilder).layout.anchors
		"heap":
			anchors = (zone_map as HeapBuilder).layout.anchors
		"capital":
			anchors = (zone_map as CapitalBuilder).layout.anchors
	for key: String in anchors.keys():
		if key in NOT_A_DESTINATION:
			continue
		targets["anchor:%s" % key] = anchors[key]
	for key: String in chests.keys():
		targets["chest:%s" % key] = chests[key]
	return targets


## Targets that a hero on foot is not meant to reach (the Gainlands' islands, reached by throw or rift).
func _on_foot_only(zone_id: String, zone_map: ZoneMap, targets: Dictionary) -> Dictionary:
	if zone_id != "gainlands":
		return targets
	var layout: GainlandsLayout = (zone_map as GainlandsBuilder).layout
	var kept: Dictionary = {}
	for key: String in targets.keys():
		var pos: Vector3 = targets[key] as Vector3
		if layout.surface_at(pos.x, pos.z) == GainlandsLayout.Surface.GROUND:
			kept[key] = pos
	return kept


func _check_zone(zone_id: String) -> void:
	var zone_map: ZoneMap = _make_zone(zone_id)
	var spawn: Vector3 = zone_map.anchor("spawn")
	var targets: Dictionary = _on_foot_only(zone_id, zone_map, _targets_for(zone_id, zone_map))
	var can_stand: Callable = func(pos: Vector3) -> bool: return zone_map.is_walkable(pos, 0.22)
	var reached: Dictionary = WalkProbe.flood_linked(can_stand, spawn, zone_map.map_bounds(), _links_for(zone_id, zone_map))
	var missing: Array[String] = _missing(reached, targets)
	_dump(zone_id, can_stand, reached, zone_map.map_bounds(), spawn, targets)
	gut.p("%s: %d key locations, unreachable: %s" % [zone_id, targets.size(), str(missing)])
	assert_eq(missing, [] as Array[String], "%s: unreachable from the spawn: %s" % [zone_id, str(missing)])
	var clearance: float = _clearance(zone_id, zone_map, spawn, targets)
	gut.p("%s: widest body radius that still reaches everything: %.2f" % [zone_id, clearance])
	var narrow: Callable = func(pos: Vector3) -> bool: return zone_map.is_walkable(pos, MIN_LANE_RADIUS)
	var narrow_reached: Dictionary = WalkProbe.flood_linked(narrow, spawn, zone_map.map_bounds(), _links_for(zone_id, zone_map))
	assert_gte(clearance, MIN_LANE_RADIUS, "%s: lanes to every key location stay at least %.1f m wide; cut off at that width: %s" % [zone_id, MIN_LANE_RADIUS * 2.0, str(_missing(narrow_reached, targets, MIN_LANE_RADIUS - 0.22))])


func test_dna() -> void:
	_check_zone("dna")


func test_gainlands() -> void:
	_check_zone("gainlands")


func test_buffet() -> void:
	_check_zone("buffet")


func test_heap() -> void:
	_check_zone("heap")


func test_capital() -> void:
	_check_zone("capital")


func test_gainlands_station_has_no_invisible_wall() -> void:
	# The Swole Station (KayKit tavern at 2.5x, about 2.9 m x 3.3 m) must block only where it is visible.
	var zone_map: ZoneMap = _make_zone("gainlands")
	var station: Vector3 = Vector3(52.0, 0.0, 53.5)
	assert_false(zone_map.is_walkable(station, 0.22), "the building itself is solid")
	for offset: Vector3 in [Vector3(2.0, 0, 0), Vector3(-2.0, 0, 0), Vector3(0, 0, 2.6), Vector3(0, 0, -2.8), Vector3(2.0, 0, 2.2)]:
		assert_true(zone_map.is_walkable(station + offset, 0.22), "walkable %s from the station centre (no invisible wall)" % str(offset))
	var spawn: Vector3 = zone_map.anchor("spawn")
	var main_dungeon: Vector3 = zone_map.anchor("main_dungeon")
	var can_stand: Callable = func(pos: Vector3) -> bool: return zone_map.is_walkable(pos, 0.22)
	assert_eq(WalkProbe.unreachable(can_stand, spawn, zone_map.map_bounds(), {"main_dungeon": main_dungeon}), [] as Array[String], "the way north from the spawn is open")


func test_gainlands_island_travel_reaches_every_island_anchor() -> void:
	var layout: GainlandsLayout = GainlandsLayout.new()
	layout.build()
	for island: GainlandsLayout.Island in layout.islands:
		var arrive: Vector3 = layout.anchors.get("arrive_%s" % island.id, Vector3.ZERO) as Vector3
		assert_ne(arrive, Vector3.ZERO, "%s has an arrival point" % island.id)
		assert_eq(layout.surface_at(arrive.x, arrive.z), GainlandsLayout.Surface.ISLAND, "%s: the arrival point is on the island top" % island.id)
		var landing: Vector3 = layout.anchors.get("land_%s" % island.id, Vector3.ZERO) as Vector3
		assert_ne(landing, Vector3.ZERO, "%s has a landing spot on the main land" % island.id)


func test_starting_area_everything_reachable() -> void:
	var area: StartingAreaBuilder = StartingAreaBuilder.new()
	var root: Node3D = Node3D.new()
	add_child_autofree(root)
	area.build(root)
	var spawn: Vector3 = area.anchors["spawn"] as Vector3
	var targets: Dictionary = {}
	for key: String in area.anchors.keys():
		if key != "spawn":
			targets[key] = area.anchors[key]
	var can_stand: Callable = func(pos: Vector3) -> bool: return area.is_walkable(pos, 0.22)
	var missing: Array[String] = WalkProbe.unreachable(can_stand, spawn, area.map_bounds(), targets)
	gut.p("starting area: %d key locations, unreachable: %s" % [targets.size(), str(missing)])
	assert_eq(missing, [] as Array[String], "starting area: unreachable from the spawn: %s" % str(missing))


## How close the hero must be able to stand: a chest prompts within ZoneScene.HIDDEN_CHEST_RADIUS, every other spot within about 2 m.
func _missing(reached: Dictionary, targets: Dictionary, wider_body: float = 0.0) -> Array[String]:
	var chests: Dictionary = {}
	var spots: Dictionary = {}
	for key: String in targets.keys():
		if key.begins_with("chest:"):
			chests[key] = targets[key]
		else:
			spots[key] = targets[key]
	var missing: Array[String] = WalkProbe.missing_from(reached, chests, ZoneScene.HIDDEN_CHEST_RADIUS - 0.1 + wider_body)
	missing.append_array(WalkProbe.missing_from(reached, spots, SPOT_SLACK))
	return missing


func _dump(zone_id: String, can_stand: Callable, reached: Dictionary, bounds: Rect2, spawn: Vector3, targets: Dictionary) -> void:
	var dir: String = OS.get_environment("DUMP_ZONES")
	if dir == "":
		return
	var marks: Dictionary = targets.duplicate()
	marks["spawn"] = spawn
	var file: FileAccess = FileAccess.open("%s/%s.txt" % [dir, zone_id], FileAccess.WRITE)
	file.store_string("bounds %s\n%s\n" % [str(bounds), WalkProbe.ascii(can_stand, reached, bounds, marks, 1.2)])
	file.close()


## The connections that are not walking: [[from, to], ...]. Jelly pads, beanstalk ladders, manholes and the service-tunnel network.
func _links_for(zone_id: String, zone_map: ZoneMap) -> Array:
	var links: Array = []
	match zone_id:
		"buffet":
			var buffet: BuffetBuilder = zone_map as BuffetBuilder
			for pad: BuffetLayout.Pad in buffet.layout.pads:
				links.append([Vector3(pad.pos.x, 0.0, pad.pos.y), buffet.anchor(pad.dest_anchor)])
		"heap":
			links.append([zone_map.anchor("mound_a"), zone_map.anchor("ladder_a_top")])
			links.append([zone_map.anchor("mound_b"), zone_map.anchor("ladder_b_top")])
		"capital":
			# The manhole by the gate and the hidden hatch both lead down to the Crease; its ladder and tunnel lead back up.
			links.append([zone_map.anchor("manhole"), zone_map.anchor("crease_spawn")])
			links.append([zone_map.anchor("tunnel_in"), zone_map.anchor("crease_spawn")])
	return links


## The widest body radius (0.05 m steps) at which every key location is still reached.
func _clearance(zone_id: String, zone_map: ZoneMap, spawn: Vector3, targets: Dictionary) -> float:
	var best: float = 0.0
	var radius: float = 0.25
	while radius <= 0.65:
		var current: float = radius
		var can_stand: Callable = func(pos: Vector3) -> bool: return zone_map.is_walkable(pos, current)
		var reached: Dictionary = WalkProbe.flood_linked(can_stand, spawn, zone_map.map_bounds(), _links_for(zone_id, zone_map))
		if not _missing(reached, targets, current - 0.22).is_empty():
			break
		best = radius
		radius += 0.05
	return best


func test_small_decorative_rocks_have_no_collision() -> void:
	var heap: HeapLayout = HeapLayout.new()
	heap.build()
	var rocks: int = 0
	for prop: HeapLayout.Prop in heap.props:
		if prop.kind == "rock":
			rocks += 1
			assert_eq(prop.radius, 0.0, "heap rock at %s is walk-through" % str(prop.pos))
	assert_gt(rocks, 0, "the Verdant Dump still has scattered rocks")
	var capital: CapitalLayout = CapitalLayout.new()
	capital.build()
	for prop: CapitalLayout.Prop in capital.props:
		if prop.kind == "rock":
			assert_eq(prop.radius, 0.0, "capital rock at %s is walk-through" % str(prop.pos))
	var gain: GainlandsLayout = GainlandsLayout.new()
	gain.build()
	var big_boulders: int = 0
	for prop: GainlandsLayout.Prop in gain.props:
		if prop.kind == "boulder":
			if prop.radius > 0.0:
				big_boulders += 1
				assert_gte(prop.radius, 1.0, "only the big gym boulders block at %s" % str(prop.pos))
	assert_eq(big_boulders, 2, "the two big gym boulders still block the path")
