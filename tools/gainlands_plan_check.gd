extends Node
## Gainlands v2: a quick headless audit of the layout while it is being drawn: walkable area, what the hero can reach from the spawn, anchors and chests
## that are crowded by solid things or too near a drop, and how long the build takes. Run: Godot --headless --path . res://tools/gainlands_plan_check.tscn


func _ready() -> void:
	var started: int = Time.get_ticks_msec()
	var builder: GainlandsBuilder = GainlandsBuilder.new()
	builder.layout.build()
	builder._index_obstacles()
	print("layout built in %d ms" % (Time.get_ticks_msec() - started))
	var layout: GainlandsLayout = builder.layout
	var area: int = 0
	var mesa: int = 0
	for x: int in range(-2, 116):
		for z: int in range(-10, 92):
			var level: int = GainlandsLayout.level_at(float(x) + 0.5, float(z) + 0.5)
			if level > 0:
				area += 1
			if level == 2:
				mesa += 1
	print("land area %d m2 (mesa %d m2), was 4705" % [area, mesa])
	var can_stand: Callable = func(pos: Vector3) -> bool: return builder.is_walkable(pos, 0.3)
	var targets: Dictionary = {}
	for key: Variant in layout.anchors.keys():
		var pos: Vector3 = layout.anchors[key] as Vector3
		if layout.surface_at(pos.x, pos.z) == GainlandsLayout.Surface.GROUND or layout.surface_at(pos.x, pos.z) == GainlandsLayout.Surface.BRIDGE:
			targets[str(key)] = pos
	for key: Variant in layout.chests.keys():
		var chest: Vector3 = layout.chests[key] as Vector3
		if GainlandsLayout.is_main_ground(chest.x, chest.z):
			targets["chest:" + str(key)] = chest
	started = Time.get_ticks_msec()
	var missing: Array[String] = WalkProbe.unreachable(can_stand, layout.anchors["spawn"] as Vector3, builder.map_bounds(), targets)
	print("unreachable from the spawn: %s (%d ms)" % [str(missing), Time.get_ticks_msec() - started])
	for key: String in targets.keys():
		var pos: Vector3 = targets[key] as Vector3
		var edge: float = GainlandsLayout.main_edge_distance(pos.x, pos.z)
		if layout.surface_at(pos.x, pos.z) == GainlandsLayout.Surface.GROUND and edge < 1.5:
			print("  near a drop: %s (%.1f m)" % [key, edge])
		if not key.begins_with("chest") and not builder.is_walkable(pos, 0.3):
			print("  not walkable: %s" % key)
		for prop: GainlandsLayout.Prop in layout.props:
			if prop.radius > 0.0 and prop.kind != "pylon" and Vector2(prop.pos.x - pos.x, prop.pos.z - pos.z).length() - prop.radius < (2.0 if key.begins_with("chest") else GainlandsLayout.ANCHOR_CLEARANCE - 2.0):
				print("  crowded: %s by %s at (%.0f, %.0f)" % [key, prop.kind, prop.pos.x, prop.pos.z])
		for rect: Rect2 in layout.blocker_rects:
			if rect.grow(GainlandsLayout.ANCHOR_CLEARANCE - 2.0).has_point(Vector2(pos.x, pos.z)) and key != "station":
				print("  crowded: %s by a blocker rect" % key)
	for prop: GainlandsLayout.Prop in layout.props:
		if GainlandsLayout.is_main_ground(prop.pos.x, prop.pos.z) and prop.kind not in ["tree", "boulder", "pylon"]:
			var edge: float = layout.path_edge_distance(prop.pos.x, prop.pos.z) - prop.radius
			if prop.radius > 0.0 and edge < GainlandsLayout.PATH_CLEARANCE * 0.5:
				print("  %s at (%.0f, %.0f) is %.1f m off a route edge" % [prop.kind, prop.pos.x, prop.pos.z, edge])
			if prop.kind != "cavern" and GainlandsLayout.main_edge_distance(prop.pos.x, prop.pos.z) < prop.radius + 0.5:
				print("  %s at (%.0f, %.0f) hangs over a drop" % [prop.kind, prop.pos.x, prop.pos.z])
		elif not GainlandsLayout.is_main_ground(prop.pos.x, prop.pos.z) and layout.island_at(prop.pos.x, prop.pos.z) == null and prop.kind != "cavern":
			print("  %s at (%.0f, %.0f) stands off the land" % [prop.kind, prop.pos.x, prop.pos.z])
	var trees: int = 0
	var rocks: int = 0
	for prop: GainlandsLayout.Prop in layout.props:
		trees += 1 if prop.kind == "tree" else 0
		rocks += 1 if prop.kind == "boulder" else 0
	print("trees %d rocks %d props %d" % [trees, rocks, layout.props.size()])
	get_tree().quit()
