class_name CapitalRimRuins
extends RefCounted
## Fable Nov 12c (A6): the ruined kingdom on the Capital's rim. The ridges round the outside (the wall approaches, the land beside the
## Reek's and the Transit Yards' walls) carried only rocks, rubble cards and dead trees - and, from the build cache, those cards came back
## as flat grey rectangles. With that fixed, this adds what the wasteland is meant to show there, all from the existing Capital kit and at
## believable scale: dilapidated house shells with broken roofs (`CapitalLandmarks.ruined_house`: CAP-WALL-RUIN, CAP-ROOF-BROKEN), stretches
## of ash-blackened wall (`ruin_fragment`: CAP-WALL-ASH), toppled statues (`CapitalProps.fallen_statue`: the rubble sheet's marble head),
## rubble mounds (CAP-SHEET-RUBBLE) on an ash drift (CAP-DEC-ASH) and crystal growths (CAP-PLANT-CRYSTAL).
##
## Every piece stands ON the rim's ground (its base a little under the surface, never floating), off the walkable map, and only where the
## rim's own rule leaves room for it (`CapitalRim.north_cap`: nothing rises between the camera and the hero). Placement is a fixed seed over
## the rim's distance field, so it is the same every visit. Low-end keeps about half.

const K = preload("res://world/capital/capital_kit.gd")
const SEED: int = 9393
## Cells are tried on a jittered grid of this step (metres).
const STEP: float = 5.0
## Least distance between two pieces of one kind (metres), and the most of each.
const HOUSE_SPACING: float = 15.0
const FRAGMENT_SPACING: float = 11.0
const STATUE_SPACING: float = 17.0
const CRYSTAL_SPACING: float = 9.0
const MOUND_SPACING: float = 7.0
const MAX_HOUSES: int = 12
const MAX_FRAGMENTS: int = 12
const MAX_STATUES: int = 8
const MAX_CRYSTALS: int = 16
const MAX_MOUNDS: int = 22
## The house shells: [width, height, depth, lean] - four fixed shapes, so their geometry is four cache entries.
const HOUSE_SHAPES: Array[Array] = [[6.4, 4.2, 4.6, 3.0], [7.6, 4.8, 5.2, -2.0], [5.4, 3.6, 4.2, 5.0], [8.2, 5.2, 5.0, 1.0]]
## How far a piece's base sits under the rim's surface (the slope would otherwise show a gap under its downhill side).
const SINK: float = 0.35
## Only the outside half carries ruins (the wall approaches, the flanks either side of the front wall and south of it). The ridges beside
## the city's west and east walls are never seen - the walls stand 9 m between them and the streets - and pieces there cost the inside
## streets frames for nothing (the Capital inside fell from 64 to 57 fps on Medium before this line).
const MIN_Z: float = 69.0

var root: Node3D
var houses: Array[Vector3] = []
var fragments: Array[Vector3] = []
var statues: Array[Vector3] = []
var crystals: Array[Vector3] = []
var mounds: Array[Vector3] = []


static func build(parent: Node3D, rim: CapitalRim, share: float = 1.0) -> CapitalRimRuins:
	var ruins: CapitalRimRuins = CapitalRimRuins.new()
	ruins.root = Node3D.new()
	ruins.root.name = "RimRuins"
	ruins.root.set_meta(&"no_wind", true)
	parent.add_child(ruins.root)
	ruins._place(rim, clampf(share, 0.4, 1.0))
	return ruins


## The ground under (x, z): the lowest of the rim's four vertices round the cell, so a piece never hangs over the downhill side.
static func ground_at(rim: CapitalRim, x: float, z: float) -> float:
	var cx: int = int(floorf(x))
	var cz: int = int(floorf(z))
	return minf(minf(rim.height_at(cx, cz), rim.height_at(cx + 1, cz)), minf(rim.height_at(cx, cz + 1), rim.height_at(cx + 1, cz + 1)))


func _far_enough(list: Array[Vector3], pos: Vector3, spacing: float) -> bool:
	for other: Vector3 in list:
		if Vector2(other.x - pos.x, other.z - pos.z).length() < spacing:
			return false
	return true


## True when every cell under a footprint of `half` metres round (x, z) is rim ground at least `clear` metres from walkable ground.
func _footprint_free(rim: CapitalRim, x: float, z: float, half: float, clear: float) -> bool:
	for dz: float in [-half, 0.0, half]:
		for dx: float in [-half, 0.0, half]:
			var cx: int = int(floorf(x + dx))
			var cz: int = int(floorf(z + dz))
			var distance: float = rim.distance_at(cx, cz)
			if distance == INF or distance < clear or distance > CapitalRim.REACH - 2.0 or CapitalRim._in_city(cx, cz):
				return false
			if CapitalRim.ROAD.grow(3).has_point(Vector2i(cx, cz)):
				return false
	return true


func _place(rim: CapitalRim, share: float) -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = SEED
	var area: Rect2i = CapitalRim.AREA
	var shells: Node3D = Node3D.new()
	shells.name = "Shells"
	root.add_child(shells)
	var growths: Node3D = Node3D.new()
	growths.name = "Growths"
	root.add_child(growths)
	var decals: KitMesh = KitMesh.new()
	K.materials(decals)
	var z: float = float(area.position.y)
	while z < float(area.end.y):
		var x: float = float(area.position.x)
		while x < float(area.end.x):
			var px: float = x + rng.randf_range(0.0, STEP)
			var pz: float = z + rng.randf_range(0.0, STEP)
			var pick: float = rng.randf()
			var variant: int = rng.randi() % 1000
			var turn: float = rng.randf_range(-0.3, 0.3)
			x += STEP
			var cx: int = int(floorf(px))
			var cz: int = int(floorf(pz))
			var distance: float = rim.distance_at(cx, cz)
			if distance == INF or distance < 2.0 or CapitalRim._in_city(cx, cz) or pz < MIN_Z:
				continue
			var room: float = rim.north_cap(cx, cz)
			var pos: Vector3 = Vector3(px, ground_at(rim, px, pz) - SINK, pz)
			if pick < 0.3 and distance >= 6.0 and distance <= 17.0 and houses.size() < int(float(MAX_HOUSES) * share):
				var shape: Array = HOUSE_SHAPES[variant % HOUSE_SHAPES.size()]
				var height: float = float(shape[1]) + float(shape[2]) * 0.4
				if room >= height and _far_enough(houses, pos, HOUSE_SPACING) and _footprint_free(rim, px, pz, float(shape[0]) * 0.5, 4.0):
					var house: Node3D = CapitalLandmarks.ruined_house(float(shape[0]), float(shape[1]), float(shape[2]), float(shape[3]), variant % 4)
					_stand(shells, house, pos, turn)
					houses.append(pos)
					K.ground_card(decals, "CAP-DEC-ASH", Vector3(px, pos.y + SINK + 0.05, pz + float(shape[2]) * 0.5 + 1.0), float(shape[0]) * 1.3, 0.0)
					continue
			if pick < 0.5 and distance >= 4.0 and distance <= 14.0 and fragments.size() < int(float(MAX_FRAGMENTS) * share):
				var length: float = 3.2 + float(variant % 5) * 0.6
				var wall_height: float = 1.8 + float(variant % 4) * 0.4
				if room >= wall_height + 0.4 and _far_enough(fragments, pos, FRAGMENT_SPACING) and _far_enough(houses, pos, 7.0) and _footprint_free(rim, px, pz, length * 0.5, 3.0):
					_stand(shells, CapitalLandmarks.ruin_fragment(length, wall_height, variant % 6), pos, turn)
					fragments.append(pos)
					continue
			if pick < 0.64 and distance >= 2.5 and distance <= 9.0 and statues.size() < int(float(MAX_STATUES) * share):
				if room >= 1.7 and _far_enough(statues, pos, STATUE_SPACING) and _far_enough(houses, pos, 6.0) and _footprint_free(rim, px, pz, 1.5, 2.0):
					_stand(shells, CapitalProps.fallen_statue(), pos + Vector3(0.0, SINK - 0.08, 0.0), turn)
					statues.append(pos)
					continue
			if pick < 0.82 and distance >= 3.0 and distance <= 13.0 and crystals.size() < int(float(MAX_CRYSTALS) * share):
				var crystal_height: float = 1.5 + float(variant % 6) * 0.3
				if room >= crystal_height + 0.3 and _far_enough(crystals, pos, CRYSTAL_SPACING) and _far_enough(houses, pos, 5.0):
					K.tree_card(growths, "CAP-PLANT-CRYSTAL", pos + Vector3(0.0, SINK - 0.12, 0.0), crystal_height)
					if variant % 2 == 0:
						K.tree_card(growths, "CAP-PLANT-CRYSTAL", pos + Vector3(0.9, SINK - 0.12, 0.35), crystal_height * 0.6)
					crystals.append(pos)
					continue
			if distance >= 2.0 and distance <= 8.0 and mounds.size() < int(float(MAX_MOUNDS) * share):
				var mound_height: float = 1.0 + float(variant % 4) * 0.2
				if room >= mound_height and _far_enough(mounds, pos, MOUND_SPACING) and _far_enough(houses, pos, 5.0) and _far_enough(statues, pos, 3.0):
					K.tree_card(growths, ["CAP-SHEET-RUBBLE-01", "CAP-SHEET-RUBBLE-05", "CAP-SHEET-RUBBLE-06", "CAP-SHEET-RUBBLE-03"][variant % 4], pos + Vector3(0.0, SINK - 0.1, 0.0), mound_height)
					K.ground_card(decals, "CAP-DEC-ASH", Vector3(px, pos.y + SINK + 0.05, pz + 0.3), 2.6 + float(variant % 3) * 0.5, turn)
					mounds.append(pos)
		z += STEP
	var drifts: MeshInstance3D = decals.instance("RimAsh")
	drifts.set_meta(&"no_occlusion_fade", true)
	drifts.set_meta(PaintedClasses.META_NO_PAINT, true)
	drifts.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(drifts)
	# off the walkable map and under the camera's line by the rim's rule: nothing here ever needs to fade for the hero. No sun shadows
	# (the ridges are far from the hero and the shells are many triangles), and the shells merge into a few batches (one draw per
	# material per cell instead of one per piece).
	for node: Node in root.find_children("*", "MeshInstance3D", true, false):
		node.set_meta(&"no_occlusion_fade", true)
		(node as MeshInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for node: Node in shells.find_children("*", "MeshInstance3D", true, false):
		node.set_meta(&"kit_static", true)
	if shells.is_inside_tree():
		KitBatch.merge_static(shells, 64.0)
		for node: Node in shells.find_children("*", "MeshInstance3D", true, false):
			node.set_meta(&"no_occlusion_fade", true)
			(node as MeshInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


func _stand(parent: Node3D, piece: Node3D, pos: Vector3, turn: float) -> void:
	piece.position = pos
	piece.rotation.y = turn  # the broken front stays toward the camera (south), a little off square
	parent.add_child(piece)


## Every piece's spot (tests, the driver's scan).
func all_spots() -> Array[Vector3]:
	var result: Array[Vector3] = []
	result.append_array(houses)
	result.append_array(fragments)
	result.append_array(statues)
	result.append_array(crystals)
	result.append_array(mounds)
	return result
