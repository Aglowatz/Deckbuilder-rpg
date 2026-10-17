class_name ZoneClusters
extends RefCounted
## Prop clusters described as data for a zone kit (data/art/zone_kits/<zone>_clusters.json): little vignettes of painted cards (kit cut-outs: props, plants) and shared
## kit props, so a zone's dressing needs no code. `PropClusters.make` falls back here for a name it does not know. Same local frame and meta as `PropClusters`:
## origin on the ground, the open side +z, meta "circles" (solid pieces), "length", "depth".
##   {"gym_rack": {"length": 5.0, "depth": 1.6, "pieces": [{"card": "GAIN-PROP-RACK", "pos": [0, 0], "height": 1.9, "solid": true},
##                                                        {"prop": "barrel", "pos": [2.2, 0.3], "yaw": 10}],
##                 "clumps": [{"pos": [-2.4, 0.8], "radius": 0.7, "count": 6, "cells": [0, 2]}]}}
## A card piece is a camera-facing cut-out (`KitFoliage.card`): "height" metres (default: the registry's height), "solid" adds a circle of a third of its width.

const DIR: String = "res://data/art/zone_kits/"
static var _clusters: Dictionary = {}
static var _loaded: bool = false


static func _load() -> void:
	if _loaded:
		return
	_loaded = true
	var dir: DirAccess = DirAccess.open(DIR)
	if dir == null:
		return
	for file_name: String in dir.get_files():
		if not file_name.ends_with("_clusters.json"):
			continue
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(DIR + file_name))
		if parsed is Dictionary:
			for key: Variant in ((parsed as Dictionary).get("clusters", {}) as Dictionary).keys():
				var entry: Dictionary = ((parsed as Dictionary)["clusters"] as Dictionary)[key] as Dictionary
				entry["zone"] = str((parsed as Dictionary).get("zone", file_name.trim_suffix("_clusters.json")))
				_clusters[str(key)] = entry


static func names() -> Array[String]:
	_load()
	var result: Array[String] = []
	for key: Variant in _clusters.keys():
		result.append(str(key))
	result.sort()
	return result


static func has(cluster_name: String) -> bool:
	_load()
	return _clusters.has(cluster_name)


static func clear_cache() -> void:
	_clusters.clear()
	_loaded = false


## The height of a card id in metres: the registry's `height`, else a guess from its family.
static func card_height(id: String) -> float:
	var entry: Dictionary = EnvKit.entry(id)
	if entry.has("height"):
		return float(entry["height"])
	match str(entry.get("group", "prop")):
		"tree":
			return 5.0
		"banner":
			return 2.2
		"sign":
			return 1.4
	return 1.2


## A camera-facing card prop (a kit cut-out standing on the ground): meta "radius" (a third of its width), "triangles" 2, "card_id".
static func card_prop(id: String, height: float = -1.0, shadow: bool = true) -> Node3D:
	if not EnvKit.has(id):
		return null
	var h: float = height if height > 0.0 else card_height(id)
	var w: float = h * EnvKit.aspect(id)
	# Crosspath pass, Part B: only plant and tree cards bend in the wind; a rack, a sign or a crate card stands still.
	var entry: Dictionary = EnvKit.entry(id)
	var living: bool = str(entry.get("lock", "")) == "TREE" or str(entry.get("group", "")).contains("plant") or str(entry.get("group", "")).contains("tree")
	var card: MeshInstance3D = KitFoliage.card(id, Vector2(w, h), shadow, not living)
	card.name = "Body"
	card.set_meta("no_occlusion_fade", true)
	var root: Node3D = Node3D.new()
	root.name = "Card_%s" % id
	root.add_child(card)
	root.set_meta("radius", w * 0.33)
	root.set_meta("triangles", 2)
	root.set_meta("card_id", id)
	root.set_meta("lights", [] as Array[Dictionary])
	return root


static func make(cluster_name: String, seed_value: int = 0) -> Node3D:
	_load()
	if not _clusters.has(cluster_name):
		return null
	var data: Dictionary = _clusters[cluster_name] as Dictionary
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 4100 + seed_value
	var root: Node3D = Node3D.new()
	root.name = "Cluster_%s" % cluster_name
	var circles: Array[Vector3] = []
	var index: int = 0
	for item: Variant in data.get("pieces", []) as Array:
		var piece: Dictionary = item as Dictionary
		var pos_arr: Array = piece.get("pos", [0.0, 0.0]) as Array
		var pos: Vector3 = Vector3(float(pos_arr[0]), 0.0, float(pos_arr[1]))
		var yaw: float = float(piece.get("yaw", 0.0)) + rng.randf_range(-float(piece.get("jitter", 0.0)), float(piece.get("jitter", 0.0)))
		var node: Node3D = null
		var solid: bool = bool(piece.get("solid", true))
		if piece.has("card"):
			node = card_prop(str(piece["card"]), float(piece.get("height", -1.0)))
			if node != null and piece.has("flip") and bool(piece["flip"]):
				(node.get_child(0) as Node3D).scale.x *= -1.0
		elif piece.has("prop"):
			node = PropKit.make(str(piece["prop"]), float(piece.get("length", 3.2)), seed_value + index)
		elif piece.has("cluster"):
			node = PropClusters.make(str(piece["cluster"]), seed_value + index)
		if node == null:
			index += 1
			continue
		root.add_child(node)
		node.position = pos
		node.rotation_degrees.y += yaw
		var radius: float = float(piece.get("radius", float(node.get_meta("radius", 0.0))))
		if solid and radius > 0.0:
			circles.append(Vector3(pos.x, pos.z, radius))
		if node.has_meta("circles"):
			var basis: Basis = Basis(Vector3.UP, deg_to_rad(yaw))
			for circle: Variant in node.get_meta("circles") as Array:
				var local: Vector3 = circle as Vector3
				var world: Vector3 = pos + basis * Vector3(local.x, 0.0, local.y)
				circles.append(Vector3(world.x, world.z, local.z))
		index += 1
	var clumps: Array[Dictionary] = []
	for item: Variant in data.get("clumps", []) as Array:
		var clump: Dictionary = item as Dictionary
		var pos_arr: Array = clump.get("pos", [0.0, 0.0]) as Array
		clumps.append({"pos": Vector3(float(pos_arr[0]), 0.0, float(pos_arr[1])), "radius": float(clump.get("radius", 0.8)), "count": int(clump.get("count", 6)), "cells": clump.get("cells", [0, 2])})
	if not clumps.is_empty():
		KitFoliage.clumps(root, clumps, seed_value + 11)
	root.set_meta("circles", circles)
	root.set_meta("length", float(data.get("length", 3.0)))
	root.set_meta("depth", float(data.get("depth", 1.5)))
	root.set_meta("zone", str(data.get("zone", "")))
	return root
