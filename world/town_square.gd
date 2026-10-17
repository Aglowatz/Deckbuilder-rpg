class_name TownSquare
extends RefCounted
## The visual slice (Brief 12, Part C), now laid out by `TownLayout`: the town's central plaza and its streets (`TownStreets`: paving, the royal-crest
## fountain, signposts, lamps), moss patches, sparse wind-swaying grass with a handful of flowers, clutter round the shop fronts and chimney smoke.
## Nothing is placed on the streets or on the walking lanes between buildings (docs/art/style_guide.md: walkable lanes stay at least 2 m wide).
## Deterministic (seeded), scaled by graphics quality.

const WARM_LIGHT: Color = Color("ffb45a")

var root: Node3D
var town: TownBuilder
var center: Vector3 = Vector3.ZERO
var plaza_radius: float = TownLayout.PLAZA_RADIUS
var meadow_radius: float = 30.0
var lights: Array[OmniLight3D] = []
## The roads, plaza and fountain (`TownStreets`).
var streets: TownStreets
## Where every meadow tuft/flower stands (also readable headless, where MultiMesh buffers are not).
var meadow_points: Array[Vector3] = []
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _lane_points: Array[Vector3] = []
var _quality: int = GraphicsQuality.Level.MEDIUM


static func build(parent: Node3D, builder: TownBuilder, quality: int) -> TownSquare:
	var square: TownSquare = TownSquare.new()
	square.root = Node3D.new()
	square.root.name = "TownSquare"
	parent.add_child(square.root)
	square.town = builder
	square._quality = quality
	square._rng.seed = 4242
	square.center = TownLayout.PLAZA
	square.streets = TownStreets.build(square.root, builder)
	square.lights.append_array(square.streets.lights)
	square._ground()
	square._skirts()
	square._meadow()
	square._landmarks()
	square._building_lights()
	KitBatch.merge_static(square.root)
	KitPools.build_ao(square.root, builder.ao_pools)
	KitPools.build_glow(square.root, builder.glow_pools)
	return square


func _anchor(key: String) -> Vector3:
	return town.anchors.get(key, center) as Vector3


func _put(folder: String, model: String, pos: Vector3, yaw: float = 0.0, scale_value: float = 1.0, solid: float = 0.0) -> Node3D:
	var node: Node3D = ModelKit.kit_model(folder, model)
	ModelKit.place(root, node, pos, yaw, scale_value)
	if solid > 0.0:
		town.obstacles.append(Vector3(pos.x, pos.z, solid))
	return node


func _hex_prop(model: String, pos: Vector3, yaw: float = 0.0, scale_value: float = 1.0, solid: float = 0.0) -> Node3D:
	var node: Node3D = ModelKit.prop(model)
	ModelKit.place(root, node, pos, yaw, scale_value)
	if solid > 0.0:
		town.obstacles.append(Vector3(pos.x, pos.z, solid))
	return node


# ---- ground: moss patches round the paved streets ---------------------------------------------------------------------------------------


func _ground() -> void:
	# Part C: the ground is calm. The old saturated moss discs are gone: the painted grass shows through, paths and the square are PathTool surfaces (TownStreets).
	_lane_points = TownLayout.road_points(1.5)


# ---- the meadow: natural clumps of grass and flowers (KitFoliage cards), never an even scatter -------------------------------------


func _meadow() -> void:
	var density: float = GraphicsQuality.foliage_density(_quality)
	var entries: Array[Dictionary] = []
	# 1. along the path edges, at the irregular gaps the PathTool chose
	for entry: Dictionary in streets.edge_clumps:
		if _meadow_ok(entry["pos"] as Vector3, true, -0.2):
			entries.append(entry)
	# 2. patches: a Poisson-ish set of garden / meadow patches, most of them tucked against walls and props (that is where plants grow), a few out in the open
	var centers: Array[Vector3] = []
	var wanted: int = 46
	var tries: int = 0
	while centers.size() < wanted and tries < wanted * 60:
		tries += 1
		var angle: float = _rng.randf() * TAU
		var distance: float = sqrt(_rng.randf()) * meadow_radius
		var pos: Vector3 = center + Vector3(cos(angle) * distance, 0.0, sin(angle) * distance * 0.9)
		if not _meadow_ok(pos, true):
			continue
		var too_close: bool = false
		for other: Vector3 in centers:
			if Vector2(pos.x - other.x, pos.z - other.z).length() < 4.2:
				too_close = true
				break
		if too_close:
			continue
		var near_solid: float = 99.0
		for obstacle: Vector3 in town.obstacles:
			near_solid = minf(near_solid, Vector2(pos.x - obstacle.x, pos.z - obstacle.y).length() - obstacle.z)
		# against walls and props most of the time; open meadow patches are rarer
		if near_solid > 2.6 and _rng.randf() > 0.22:
			continue
		centers.append(pos)
	for pos: Vector3 in centers:
		var pieces: int = _rng.randi_range(1, 3)
		for piece: int in range(pieces):
			var offset: Vector3 = Vector3(_rng.randf_range(-1.1, 1.1), 0.0, _rng.randf_range(-0.9, 0.9))
			var spot: Vector3 = pos + offset
			if not _meadow_ok(spot, true):
				continue
			var flowery: bool = _rng.randf() < 0.55
			entries.append({
				"pos": spot, "radius": _rng.randf_range(0.6, 1.3), "count": _rng.randi_range(4, 9),
				"cells": [2, 3, 0, 4] if flowery else [0, 1, 0, 5, 2],
			})
	for entry: Dictionary in entries:
		entry["count"] = maxi(1, int(round(float(entry["count"]) * density)))
	var instance: MultiMeshInstance3D = KitFoliage.clumps(root, entries, 31, func(p: Vector3) -> bool: return _meadow_ok(p, true, -0.1))
	if instance != null:
		for point: Vector3 in instance.get_meta("points") as Array[Vector3]:
			meadow_points.append(point)


func _meadow_ok(pos: Vector3, lane_ok: bool = false, paved_margin: float = 0.35) -> bool:
	if not town.is_floor_at(pos):
		return false
	if TownLayout.is_paved(pos, paved_margin):  # the streets and the plaza stay clear of grass
		return false
	if Vector2(pos.x - center.x, pos.z - center.z).length() < TownLayout.FOUNTAIN_RADIUS + 0.2:
		return false
	if not lane_ok:
		for point: Vector3 in _lane_points:
			if Vector2(pos.x - point.x, pos.z - point.z).length() < 0.9:
				return false
	for obstacle: Vector3 in town.obstacles:
		if Vector2(pos.x - obstacle.x, pos.z - obstacle.y).length() < obstacle.z + 0.2:
			return false
	for key: String in ["market", "deck", "well", "gate", "spawn", "npc_market", "npc_well", "npc_gate", "rift_station", "tailor", "npc_tailor"]:
		if Vector2(pos.x - _anchor(key).x, pos.z - _anchor(key).z).length() < 1.2:
			return false
	return true


func _multimesh(mesh: Mesh, transforms: Array[Transform3D]) -> void:
	if transforms.is_empty():
		return
	var multimesh: MultiMesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = mesh
	multimesh.instance_count = transforms.size()
	for i: int in range(transforms.size()):
		multimesh.set_instance_transform(i, transforms[i])
	var instance: MultiMeshInstance3D = MultiMeshInstance3D.new()
	instance.multimesh = multimesh
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var toon: ShaderMaterial = StyleToon.toon_for(mesh.surface_get_material(0), 1.0)
	if toon != null:
		instance.material_override = toon
	instance.set_meta(StyleToon.META_NO_TOON, true)
	root.add_child(instance)


# ---- building skirts: dressed doorsteps, wall corners and framing pieces ---------------------------------------------------------------


## Vertical slice, Part E: instead of scattering crates round the shops, every kit building gets a doorstep cluster (pots, a planter, a barrel or crate), most get a stack of
## crates and barrels against a wall corner, and a few get a fenced garden or a banner lamp. Worn earth lies at every doorstep. Everything is placed in the building's own frame
## and checked against the footprints, the roads and the other obstacles.
func _skirts() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 5151
	var index: int = 0
	for shop: TownLayout.Shop in TownLayout.shops():
		if shop.kind != "kit":
			continue
		var spec: Dictionary = BuildingPresets.spec(shop.preset, shop.overrides)
		var door_u: float = TownKit.door_u(spec)
		var hw: float = shop.footprint.x * 0.5
		# worn earth at the doorstep (DEC-WORNPATCH)
		var step_pos: Vector3 = TownKit.front_point(shop, door_u, 0.9)
		PathTool.patch(root, step_pos, 1.7, "dirt", shop.yaw + float(index * 37 % 90), 40 + index)
		# the doorstep cluster: pots flank the door
		var doorstep: Node3D = PropClusters.make("doorstep", index)
		_trim_to_frontage(doorstep, door_u, hw)
		TownKit.place_cluster(root, town, doorstep, TownKit.front_point(shop, door_u, 0.3), shop.yaw)
		# a stack of crates and barrels against the wall, on the side away from the door, only where it fits (clear of the neighbours, the street and the lane to the door)
		var side: float = -1.0 if door_u > 0.0 else 1.0
		if index % 3 != 2 and hw > 2.6:
			var kind: String = "crates" if index % 2 == 0 else "barrel_pair"
			var reach: Vector2 = Vector2(-1.5, 2.75) if kind == "crates" else Vector2(-0.8, 0.9)
			for attempt: int in range(2):
				var u_origin: float = side * (hw - reach.y - 0.45)
				var fits: bool = true
				for step: int in range(5):
					# the cluster's +x runs towards the wall's end on the right (side +1) and, turned 180 degrees, towards the left end on the left
					var along: float = lerpf(reach.x, reach.y, float(step) / 4.0)
					var sample: Vector3 = TownKit.front_point(shop, u_origin + side * along, 0.8)
					# (Crosspath pass, Part C: never in the Secret Dealer's alley or across its mouth)
					var blocked: bool = TownLayout.is_paved(sample, 0.1) or not town.is_floor_at(sample) or TownLayout.ALLEY.grow(1.6).has_point(Vector2(sample.x, sample.z))
					for other: TownLayout.Shop in TownLayout.shops():
						if other != shop and other.covers(sample, 0.5):
							blocked = true
					if blocked:
						fits = false
						break
				if fits:
					var crates: Node3D = PropClusters.make(kind, index + 3)
					TownKit.place_cluster(root, town, crates, TownKit.front_point(shop, u_origin, 0.45), shop.yaw + (180.0 if side < 0.0 else 0.0))
					break
				side = -side
		index += 1
	# framing pieces for the default view from the spawn: trees and a hedge at the foreground edges (the tilt-shift softens them)
	_framing()


## Crosspath pass, Part C: the doorstep cluster is seven metres wide, so a door near a corner pushed its barrel and crate past the building into a street
## mouth or the alley. Pieces (and their solid circles) beyond the building's own frontage are left out.
func _trim_to_frontage(cluster: Node3D, door_u: float, half_width: float) -> void:
	var limit: float = half_width - 0.25
	for child: Node in cluster.get_children():
		var piece: Node3D = child as Node3D
		if piece != null and absf(door_u + piece.position.x) > limit:
			cluster.remove_child(piece)
			piece.free()
	if cluster.has_meta("circles"):
		var kept: Array[Vector3] = []
		for circle: Variant in cluster.get_meta("circles") as Array:
			if absf(door_u + (circle as Vector3).x) <= limit:
				kept.append(circle as Vector3)
		cluster.set_meta("circles", kept)


func _framing() -> void:
	var trees: Array[Dictionary] = [
		# Crosspath pass, Part C: off the bigger square, at its outer corners (the old birch and pine stood where the square is now)
		{"kind": "fruit", "pos": Vector3(4.6, 0.0, 24.2), "scale": 0.95},
		{"kind": "oak", "pos": Vector3(44.6, 0.0, 24.6), "scale": 1.0},
	]
	for entry: Dictionary in trees:
		var pos: Vector3 = entry["pos"] as Vector3
		if not town.is_floor_at(pos) or TownLayout.in_footprint(pos, 0.6) or TownLayout.is_paved(pos, 0.5):
			continue
		var tree: Node3D = TreeCards.make(str(entry["kind"]), float(entry["scale"]), true)
		root.add_child(tree)
		tree.position = pos
		town.add_ao_blob(pos, 0.5, 0.3)
		town.obstacles.append(Vector3(pos.x, pos.z, 0.35))


# ---- landmarks: chimney smoke ---------------------------------------------------------------------------------------------------------


func _landmarks() -> void:
	# Chimney smoke is CPU particles: only the six chimneys nearest the spawn smoke (the rest are out of the frame at the default camera).
	var smoke: Color = Color(1.0, 0.9, 0.82, 0.5)
	var points: Array[Vector3] = []
	for building: Variant in town.kit_buildings.values():
		var node: Node3D = building as Node3D
		if node == null or not node.is_inside_tree():
			continue
		points.append_array(TownKit.smoke_points(node))
	var spawn: Vector3 = TownLayout.SPAWN
	points.sort_custom(func(a: Vector3, b: Vector3) -> bool: return a.distance_squared_to(spawn) < b.distance_squared_to(spawn))
	for index: int in range(mini(points.size(), 6)):
		StyleAmbience.chimney_smoke(root, points[index], smoke, [4, 6, 8][clampi(_quality, 0, 2)])




# ---- door lanterns: a few real warm lights (the nearest to the spawn), a glow pool for every one ---------------------------------------


const BUILDING_LIGHTS: int = 4


func _building_lights() -> void:
	var found: Array[Dictionary] = []
	for building: Variant in town.kit_buildings.values():
		var node: Node3D = building as Node3D
		if node == null or not node.is_inside_tree() or not node.has_meta("lights"):
			continue
		for item: Variant in node.get_meta("lights") as Array:
			var data: Dictionary = item as Dictionary
			var world: Vector3 = node.global_transform * (data["pos"] as Vector3)
			found.append({"pos": world, "color": data.get("color", WARM_LIGHT) as Color, "energy": float(data.get("energy", 1.6)), "range": float(data.get("range", 6.0))})
	var spawn: Vector3 = TownLayout.SPAWN
	found.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return (a["pos"] as Vector3).distance_squared_to(spawn) < (b["pos"] as Vector3).distance_squared_to(spawn))
	for index: int in range(found.size()):
		var data: Dictionary = found[index]
		var pos: Vector3 = data["pos"] as Vector3
		town.add_glow(Vector3(pos.x, 0.0, pos.z), 2.2, data["color"] as Color, 0.14)
		if index >= BUILDING_LIGHTS:
			continue
		var light: OmniLight3D = OmniLight3D.new()
		light.light_color = data["color"] as Color
		light.light_energy = float(data["energy"])
		light.omni_range = float(data["range"])
		light.omni_attenuation = 1.3
		root.add_child(light)
		light.global_position = pos
		lights.append(light)
