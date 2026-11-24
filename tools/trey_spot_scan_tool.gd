extends RefCounted
## Fable big pass Nov 23 (Part 5.5): where can Trey Pickett's draft table stand in a Path zone? Builds each zone's ground (headless),
## prints where the hero arrives, where the zone's other people and spots stand, and the open spots near the arrival point: walkable
## with CLEAR m of room all round, at least GAP m from every other person or spot. One line per candidate, nearest the arrival first.
##   Godot --headless --path . -s res://tools/trey_spot_scan.gd [-- --zone=refusemancer --near=9 --far=16]

const CLEAR: float = 1.3
const GAP: float = 3.2
const STEP: float = 1.0

var _args: Dictionary = {}


var root: Node


func run(tree_root: Node) -> bool:
	root = tree_root
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--"):
			var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
			_args[parts[0]] = parts[1] if parts.size() > 1 else "true"
	var builders: Dictionary = {"beefcake": GainlandsBuilder, "gourmand": BuffetBuilder, "refusemancer": HeapBuilder, "necrocrat": DnaBuilder}
	for zone_id: String in builders.keys():
		if _args.has("zone") and str(_args["zone"]) != zone_id:
			continue
		var holder: Node3D = Node3D.new()
		root.add_child(holder)
		var builder: Object = (builders[zone_id] as GDScript).new()
		builder.call("build", holder)
		_scan(zone_id, builder)
		holder.queue_free()
	return true


func _scan(zone_id: String, builder: Object) -> void:
	var def: ZoneDef = ZoneDefs.get_def(zone_id)
	var spawn: Vector3 = builder.call("anchor", "spawn") as Vector3
	print("== %s: spawn (%.1f, %.1f)" % [zone_id, spawn.x, spawn.z])
	var taken: Array[Vector3] = []
	for entry: Dictionary in def.npcs:
		var anchor_name: String = str(entry.get("anchor", ""))
		if anchor_name.is_empty() or not bool(builder.call("has_anchor", anchor_name)):
			continue
		var at: Vector3 = (builder.call("anchor", anchor_name) as Vector3) + (entry.get("offset", Vector3.ZERO) as Vector3)
		if str(entry["id"]) != DraftHost.SPOT_ID:
			taken.append(at)
		if at.distance_to(spawn) < 30.0 or str(entry["id"]) in ["cardsharp", DraftHost.SPOT_ID, "quiz"]:
			print("   npc %-16s (%.1f, %.1f)  %.1f m from spawn" % [str(entry["id"]), at.x, at.z, at.distance_to(spawn)])
	for spot: Dictionary in def.spots:
		var anchor_name: String = str(spot.get("anchor", ""))
		if anchor_name.is_empty() or not bool(builder.call("has_anchor", anchor_name)) or str(spot["id"]) == DraftHost.SPOT_ID:
			continue
		var at: Vector3 = (builder.call("anchor", anchor_name) as Vector3) + (spot.get("offset", Vector3.ZERO) as Vector3)
		taken.append(at)
		if at.distance_to(spawn) < 22.0:
			print("   spot %-15s (%.1f, %.1f)  %.1f m from spawn" % [str(spot["id"]), at.x, at.z, at.distance_to(spawn)])
	var near: float = float(_args.get("near", 5.0))
	var far: float = float(_args.get("far", 13.0))
	var found: Array[Array] = []
	var x: float = -far
	while x <= far:
		var z: float = -far
		while z <= far:
			var p: Vector3 = spawn + Vector3(x, 0.0, z)
			var d: float = Vector2(x, z).length()
			if d >= near and d <= far and absf(x) >= float(_args.get("side", 0.0)) and _open(builder, p) and _apart(p, taken):
				found.append([d, p])
			z += STEP
		x += STEP
	found.sort_custom(func(a: Array, b: Array) -> bool: return float(a[0]) < float(b[0]))
	var shown: int = 0
	for row: Array in found:
		var p: Vector3 = row[1] as Vector3
		print("   open (%.1f, %.1f)  offset from spawn (%.1f, %.1f)  %.1f m  %s" % [p.x, p.z, p.x - spawn.x, p.z - spawn.z, float(row[0]), "WEST" if p.x < spawn.x else "east"])
		shown += 1
		if shown >= int(_args.get("show", 40)):
			break
	print("   %d open spots between %.0f and %.0f m" % [found.size(), near, far])


func _open(builder: Object, p: Vector3) -> bool:
	if not bool(builder.call("is_walkable", p, 0.4)):
		return false
	for i: int in range(12):
		var angle: float = TAU * float(i) / 12.0
		if not bool(builder.call("is_walkable", p + Vector3(cos(angle), 0.0, sin(angle)) * CLEAR, 0.3)):
			return false
	return true


func _apart(p: Vector3, taken: Array[Vector3]) -> bool:
	for other: Vector3 in taken:
		if Vector2(p.x - other.x, p.z - other.z).length() < GAP:
			return false
	return true
