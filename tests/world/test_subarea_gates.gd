extends GutTest
## The gates a hub shows for its sub-areas stand on ground the hero can walk to from the hub's spawn, with the hub in its default state (barricades up, gate shut, on foot),
## and their return points are walkable too (the hero must not come back inside a wall).

var _report: PackedStringArray = PackedStringArray()


func _hub_map(scene_path: String) -> WalkableArea:
	var root: Node3D = Node3D.new()
	add_child_autofree(root)
	match scene_path:
		"res://scenes/town.tscn":
			var town: TownBuilder = TownBuilder.new()
			town.build(root)
			TownSquare.build(root, town, GraphicsQuality.Level.MEDIUM)
			var rift: Vector3 = town.anchors["rift_station"] as Vector3
			town.obstacles.append(Vector3(rift.x, rift.z, 1.3))
			return town
		"res://scenes/starting_area.tscn":
			var forest: StartingAreaBuilder = StartingAreaBuilder.new()
			forest.build(root)
			return forest
		"res://scenes/dna_zone.tscn":
			var dna: DnaBuilder = DnaBuilder.new()
			dna.layout.build()
			dna._index_obstacles()
			return dna
		"res://scenes/gainlands_zone.tscn":
			var gain: GainlandsBuilder = GainlandsBuilder.new()
			gain.layout.build()
			gain._index_obstacles()
			return gain
		"res://scenes/buffet_zone.tscn":
			var buffet: BuffetBuilder = BuffetBuilder.new()
			buffet.layout.build()
			buffet._index_obstacles()
			return buffet
		"res://scenes/heap_zone.tscn":
			var heap: HeapBuilder = HeapBuilder.new()
			heap.layout.build()
			heap._index_obstacles()
			return heap
		"res://scenes/capital_zone.tscn":
			var capital: CapitalBuilder = CapitalBuilder.new()
			capital.layout.build()
			capital._index_obstacles()
			return capital
	return null


func _spawn_of(map: WalkableArea) -> Vector3:
	if map is TownBuilder:
		return (map as TownBuilder).anchors["spawn"] as Vector3
	if map is StartingAreaBuilder:
		return (map as StartingAreaBuilder).anchors["spawn"] as Vector3
	if map is DnaBuilder:
		return (map as DnaBuilder).layout.anchors["spawn"] as Vector3
	if map is GainlandsBuilder:
		return (map as GainlandsBuilder).layout.anchors["spawn"] as Vector3
	if map is BuffetBuilder:
		return (map as BuffetBuilder).layout.anchors["spawn"] as Vector3
	if map is HeapBuilder:
		return (map as HeapBuilder).layout.anchors["spawn"] as Vector3
	if map is CapitalBuilder:
		return (map as CapitalBuilder).layout.anchors["spawn"] as Vector3
	return Vector3.ZERO


## The nearest standable point within 12 m (a hint for fixing a gate position).
func _suggest(map: WalkableArea, pos: Vector3) -> String:
	var best: Vector3 = Vector3.INF
	var best_d: float = 1e9
	var r: float = 0.5
	while r <= 12.0:
		for angle_step: int in range(16):
			var a: float = TAU * float(angle_step) / 16.0
			var p: Vector3 = pos + Vector3(cos(a), 0.0, sin(a)) * r
			if map.is_walkable(p, 0.5) and r < best_d:
				best = p
				best_d = r
		if best_d < 1e8:
			break
		r += 0.5
	return "nearest standable (%.1f, %.1f)" % [best.x, best.z] if best_d < 1e8 else "none within 12 m"


func test_every_gate_is_on_reachable_ground() -> void:
	var scenes: Dictionary = {}
	for area_id: String in SubAreaDefs.AREAS:
		var scene_path: String = SubAreaDefs.hub_scene(area_id)
		if scene_path != "":
			scenes[scene_path] = true
	for scene_path: Variant in scenes.keys():
		var map: WalkableArea = _hub_map(str(scene_path))
		assert_not_null(map, "%s has a hub map in this test" % str(scene_path))
		if map == null:
			continue
		var spawn: Vector3 = _spawn_of(map)
		var bounds: Rect2 = map.map_bounds()
		var targets: Dictionary = {}
		for area_id: String in SubAreaDefs.areas_of_scene(str(scene_path)):
			for gate: Dictionary in SubAreaDefs.gates(area_id):
				var pos: Vector3 = SubAreaMap.pos3(gate["pos"])
				var ret: Vector3 = SubAreaMap.pos3(gate.get("return", gate["pos"]))
				assert_true(map.is_walkable(pos, 0.3), "%s: gate %s stands on walkable ground (%s)" % [str(scene_path).get_file(), str(gate["id"]), _suggest(map, pos)])
				assert_true(map.is_walkable(ret, 0.3), "%s: return point of %s is walkable (%s)" % [str(scene_path).get_file(), str(gate["id"]), _suggest(map, ret)])
				targets["gate:%s" % str(gate["id"])] = pos
		var missing: Array[String] = WalkProbe.unreachable(func(p: Vector3) -> bool: return map.is_walkable(p, 0.3), spawn, bounds, targets)
		assert_eq(missing, [] as Array[String], "%s: gates unreachable from the spawn: %s" % [str(scene_path).get_file(), str(missing)])
