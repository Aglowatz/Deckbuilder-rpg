extends SceneTree
## Design aid for the giant chests (Brief 16): for every zone, lists open, reachable spots 18-40 m from the spawn that are clear of every anchor and
## hidden chest, so a joke chest can be placed "slightly out of the way but visible". Run:
##   Godot --headless --path . -s res://tools/giant_chest_sites.gd


func _make(zone_id: String) -> ZoneMap:
	match zone_id:
		"dna":
			var dna: DnaBuilder = DnaBuilder.new()
			dna.layout.build()
			dna._index_obstacles()
			return dna
		"gainlands":
			var gain: GainlandsBuilder = GainlandsBuilder.new()
			gain.layout.build()
			gain._index_obstacles()
			return gain
		"buffet":
			var buffet: BuffetBuilder = BuffetBuilder.new()
			buffet.layout.build()
			buffet._index_obstacles()
			return buffet
		"heap":
			var heap: HeapBuilder = HeapBuilder.new()
			heap.layout.build()
			heap._index_obstacles()
			return heap
	return null


func _anchors(zone_id: String, zone_map: ZoneMap) -> Dictionary:
	match zone_id:
		"dna":
			return (zone_map as DnaBuilder).layout.anchors
		"gainlands":
			return (zone_map as GainlandsBuilder).layout.anchors
		"buffet":
			return (zone_map as BuffetBuilder).layout.anchors
		"heap":
			return (zone_map as HeapBuilder).layout.anchors
	return {}


func _init() -> void:
	for zone_id: String in ["gainlands", "dna", "buffet", "heap"]:
		var zone_map: ZoneMap = _make(zone_id)
		var spawn: Vector3 = zone_map.anchor("spawn")
		var can_stand: Callable = func(pos: Vector3) -> bool: return zone_map.is_walkable(pos, 0.3)
		var reached: Dictionary = WalkProbe.flood(can_stand, spawn, zone_map.map_bounds(), 0.6)
		var anchors: Dictionary = _anchors(zone_id, zone_map)
		var chests: Dictionary = zone_map.chest_positions()
		print("=== %s spawn %s, %d reached cells" % [zone_id, str(spawn), reached.size()])
		var picked: Array[Vector3] = []
		var keys: Array = reached.keys()
		keys.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return a.x < b.x or (a.x == b.x and a.y < b.y))
		for key: Variant in keys:
			var cell: Vector2i = key as Vector2i
			var pos: Vector3 = Vector3(float(cell.x) * 0.6, 0.0, float(cell.y) * 0.6)
			var from_spawn: float = Vector2(pos.x - spawn.x, pos.z - spawn.z).length()
			if from_spawn < 18.0 or from_spawn > 40.0:
				continue
			if not zone_map.is_walkable(pos, 1.3):
				continue
			var near: float = 1e9
			for anchor: Variant in anchors.values():
				near = minf(near, Vector2(pos.x - (anchor as Vector3).x, pos.z - (anchor as Vector3).z).length())
			for chest: Variant in chests.values():
				near = minf(near, Vector2(pos.x - (chest as Vector3).x, pos.z - (chest as Vector3).z).length())
			if near < 7.0:
				continue
			var crowded: bool = false
			for other: Vector3 in picked:
				if Vector2(pos.x - other.x, pos.z - other.z).length() < 7.0:
					crowded = true
			if crowded:
				continue
			picked.append(pos)
			print("  site (%.1f, %.1f)  %.0f m from spawn, %.0f m from anything" % [pos.x, pos.z, from_spawn, near])
	quit(0)
