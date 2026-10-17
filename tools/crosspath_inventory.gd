extends Node
## Crosspath pass, Part A: lists every object the town builder and the square place (name, position, solid radius nearby) and every anchor, so the
## audit in docs/art/crosspath_pass.md can name positions. Run: Godot --headless --path . res://tools/crosspath_inventory.tscn


func _ready() -> void:
	var root: Node3D = Node3D.new()
	add_child(root)
	var town: TownBuilder = TownBuilder.new()
	town.build(root)
	var square: TownSquare = TownSquare.build(root, town, GraphicsQuality.Level.MEDIUM)
	for holder: Node in [town.root, square.root, square.streets.root]:
		print("== %s (%d children)" % [holder.name, holder.get_child_count()])
		var counts: Dictionary = {}
		for child: Node in holder.get_children():
			var key: String = String(child.name).rstrip("0123456789")
			counts[key] = int(counts.get(key, 0)) + 1
			if child is Node3D and (holder == town.root and not key.begins_with("hex_")):
				var p: Vector3 = (child as Node3D).global_position
				print("  %s  (%.1f, %.1f)  scale %.2f" % [child.name, p.x, p.z, (child as Node3D).scale.x])
		print("  counts: %s" % str(counts))
	print("== expansion sites")
	for label: Variant in town.expansion.keys():
		print("  %s %s" % [str(label), str(town.expansion[label])])
	print("== anchors")
	var keys: Array = town.anchors.keys()
	keys.sort()
	for key: Variant in keys:
		var a: Vector3 = town.anchors[key] as Vector3
		print("  %s (%.1f, %.1f)" % [str(key), a.x, a.z])
	print("== lamps %d" % square.streets.lamp_points.size())
	for p: Vector3 in square.streets.lamp_points:
		print("  lamp (%.1f, %.1f) floor=%s paved=%s" % [p.x, p.z, str(town.is_floor_at(p)), str(TownLayout.is_paved(p, 1.2))])
	print("obstacles %d walkable cells %d bounds %s" % [town.obstacles.size(), town.walkable.size(), str(town.map_bounds())])
	get_tree().quit()
