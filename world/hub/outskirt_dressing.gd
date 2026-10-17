class_name OutskirtDressing
extends RefCounted
## Crosspath pass, Part E: the outskirts dressed with the town kit like the square, so the new walkable ground looks finished: small purposeful
## vignettes at the walls, the lane's corners and the field edges (a delivery corner inside the orchard wall south of the pantry gate, a woodpile behind
## the north row, barrels behind Tilly's, a bench over the lake, a garden in the west woods clearing, a low wall behind the graveyard, a cart by the
## meadow road, hay in the farmhouse's field, a bench looking over the gorge) and soft bush clumps along the gorge lip in the foreground.
## Every piece keeps off the loop lane, the roads, the buildings, the spots and the edge; what does not fit is left out and listed in `refused`.

## [kind, name, x, z, yaw, size]: kind "cluster" (PropClusters), "prop" (PropKit, size = length for walls), "card" (TreeCards kind, size = scale).
const PIECES: Array = [
	["cluster", "crates", 70.6, 19.4, 90.0, 0.0],
	["cluster", "crates", 39.0, -14.4, 0.0, 0.0],
	["cluster", "barrel_pair", 16.4, -8.2, 0.0, 0.0],
	["cluster", "bench_nook", 50.6, 36.2, 90.0, 0.0],
	["cluster", "garden_bed", -12.6, 25.8, 0.0, 0.0],
	["cluster", "crates", -21.4, -2.2, 90.0, 0.0],
	["cluster", "bench_nook", 40.4, 67.4, 180.0, 0.0],
	["prop", "stone_wall", -10.0, 28.4, 0.0, 3.6],
	["prop", "cart", 38.8, 46.4, 30.0, 0.0],
	["card", "hay", 4.4, 58.4, 0.0, 1.0],
	["card", "hay", 8.0, 60.2, 0.0, 0.9],
	["card", "hay", 14.6, 59.6, 0.0, 1.05],
]
## Bush clumps along the gorge lip (x), kept off the bridge.
const LIP_BUSHES: Array[float] = [-1.0, 6.0, 13.0, 34.0, 43.0, 51.0]
const LIP_Z: float = 69.6

var refused: Array[String] = []


static func build(root: Node3D, town: TownBuilder) -> OutskirtDressing:
	var dressing: OutskirtDressing = OutskirtDressing.new()
	var holder: Node3D = Node3D.new()
	holder.name = "OutskirtDressing"
	root.add_child(holder)
	for entry: Array in PIECES:
		dressing._piece(holder, town, entry)
	for x: float in LIP_BUSHES:
		var pos: Vector3 = Vector3(x, 0.0, LIP_Z)
		if not dressing._fits(town, pos, 0.8, "bush %.0f" % x):
			continue
		var bush: Node3D = PropKit.bush(int(x * 10.0))
		ModelKit.place(holder, bush, pos, x * 13.0, 1.25)
		town.obstacles.append(Vector3(pos.x, pos.z, 0.55))
	return dressing


func _piece(holder: Node3D, town: TownBuilder, entry: Array) -> void:
	var kind: String = str(entry[0])
	var piece_name: String = str(entry[1])
	var pos: Vector3 = Vector3(float(entry[2]), 0.0, float(entry[3]))
	var yaw: float = float(entry[4])
	match kind:
		"cluster":
			var cluster: Node3D = PropClusters.make(piece_name, int(pos.x + pos.z))
			if cluster == null:
				return
			# every solid circle of the cluster must fit
			var basis: Basis = Basis(Vector3.UP, deg_to_rad(yaw))
			for circle: Variant in cluster.get_meta("circles", []) as Array:
				var c: Vector3 = circle as Vector3
				if not _fits(town, pos + basis * Vector3(c.x, 0.0, c.y), c.z, "%s at %s" % [piece_name, str(pos)]):
					cluster.free()
					return
			TownKit.place_cluster(holder, town, cluster, pos, yaw)
		"prop":
			var length: float = float(entry[5]) if float(entry[5]) > 0.0 else 3.2
			var prop: Node3D = PropKit.make(piece_name, length, int(pos.x))
			if prop == null:
				return
			var dir: Vector3 = Basis(Vector3.UP, deg_to_rad(yaw)) * Vector3.RIGHT
			var half: float = length * 0.5 if piece_name == "stone_wall" else 0.0
			for t: float in [-half, 0.0, half]:
				if not _fits(town, pos + dir * t, 0.5, "%s at %s" % [piece_name, str(pos)]):
					prop.free()
					return
			ModelKit.place(holder, prop, pos, yaw, 1.0)
			if piece_name == "stone_wall":
				var steps: int = maxi(1, int(ceil(length / 0.7)))
				for i: int in range(steps + 1):
					var p: Vector3 = pos + dir * lerpf(-half, half, float(i) / float(steps))
					town.obstacles.append(Vector3(p.x, p.z, 0.4))
			else:
				town.obstacles.append(Vector3(pos.x, pos.z, maxf(float(prop.get_meta("radius", 0.8)), 0.6)))
		"card":
			if not _fits(town, pos, 0.7, "%s at %s" % [piece_name, str(pos)]):
				return
			var card: Node3D = TreeCards.make(piece_name, float(entry[5]), true)
			if card == null:
				return
			holder.add_child(card)
			card.position = pos
			town.obstacles.append(Vector3(pos.x, pos.z, 0.6))


## True when a solid piece of `radius` at `pos` keeps off the lane, the roads, the buildings, the spots and the edge of the walkable ground.
func _fits(town: TownBuilder, pos: Vector3, radius: float, label: String) -> bool:
	var why: String = ""
	if not town.is_floor_at(pos) or float(TownBounds.nearest_edge(pos)["distance"]) < radius + 0.2:
		why = "edge"
	elif TownBounds.lane_distance(pos) < TownBounds.LANE_WIDTH * 0.5 + 0.5 + radius:
		why = "lane"
	elif TownLayout.is_paved(pos, 0.5 + radius) or TownLayout.in_footprint(pos, 0.4 + radius):
		why = "road or building"
	else:
		for shop: TownLayout.Shop in TownExpansion.shops():
			if shop.covers(pos, 0.4 + radius):
				why = "building"
		for key: Variant in town.anchors.keys():
			var anchor: Vector3 = town.anchors[key] as Vector3
			if Vector2(anchor.x - pos.x, anchor.z - pos.z).length() < 2.5 + radius:
				why = "spot %s" % str(key)
				break
	if why == "":
		return true
	refused.append("%s (%s)" % [label, why])
	return false
