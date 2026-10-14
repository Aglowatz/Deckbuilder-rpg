extends Node
## Prints every anchor, the bounds, the chest positions and a coarse walkable map of each hub (planning aid for docs/zone_plans).
## Run: Godot --headless --path . res://tools/hub_dump.tscn


func _ready() -> void:
	var out: PackedStringArray = PackedStringArray()
	var maps: Dictionary = {}
	var dna: DnaBuilder = DnaBuilder.new()
	dna.layout.build()
	dna._index_obstacles()
	maps["dna"] = [dna, dna.layout.anchors]
	var gain: GainlandsBuilder = GainlandsBuilder.new()
	gain.layout.build()
	gain._index_obstacles()
	maps["gainlands"] = [gain, gain.layout.anchors]
	var buffet: BuffetBuilder = BuffetBuilder.new()
	buffet.layout.build()
	buffet._index_obstacles()
	maps["buffet"] = [buffet, buffet.layout.anchors]
	var heap: HeapBuilder = HeapBuilder.new()
	heap.layout.build()
	heap._index_obstacles()
	maps["heap"] = [heap, heap.layout.anchors]
	var capital: CapitalBuilder = CapitalBuilder.new()
	capital.layout.build()
	capital._index_obstacles()
	maps["capital"] = [capital, capital.layout.anchors]
	var town_root: Node3D = Node3D.new()
	add_child(town_root)
	var town: TownBuilder = TownBuilder.new()
	town.build(town_root)
	maps["town"] = [town, town.anchors]
	var forest_root: Node3D = Node3D.new()
	add_child(forest_root)
	var forest: StartingAreaBuilder = StartingAreaBuilder.new()
	forest.build(forest_root)
	maps["forest"] = [forest, forest.anchors]
	for zone: String in maps.keys():
		var map: WalkableArea = (maps[zone] as Array)[0] as WalkableArea
		var anchors: Dictionary = (maps[zone] as Array)[1] as Dictionary
		var bounds: Rect2 = map.map_bounds()
		out.append("== %s bounds x %.0f..%.0f z %.0f..%.0f" % [zone, bounds.position.x, bounds.end.x, bounds.position.y, bounds.end.y])
		var keys: Array = anchors.keys()
		keys.sort()
		for key: Variant in keys:
			var p: Vector3 = anchors[key] as Vector3
			out.append("  %s (%.1f, %.1f)%s" % [str(key), p.x, p.z, "" if map.is_walkable(p) else "  [not walkable]"])
		var chests: Dictionary = map.call("chest_positions") if map.has_method("chest_positions") else {}
		for id: Variant in chests.keys():
			var c: Vector3 = chests[id] as Vector3
			out.append("  chest:%s (%.1f, %.1f)" % [str(id), c.x, c.z])
		# Coarse walkable map: one char per 4 m.
		var step: float = 4.0
		var z: float = bounds.position.y
		while z < bounds.end.y:
			var row: String = ""
			var x: float = bounds.position.x
			while x < bounds.end.x:
				row += "#" if map.is_walkable(Vector3(x, 0.0, z), 0.3) else ("." if map.is_floor_at(Vector3(x, 0.0, z)) else " ")
				x += step
			out.append(row)
			z += step
	var file: FileAccess = FileAccess.open("user://hub_dump.txt", FileAccess.WRITE)
	file.store_string("\n".join(out))
	file.close()
	print("hub dump written to ", ProjectSettings.globalize_path("user://hub_dump.txt"))
	get_tree().quit()
