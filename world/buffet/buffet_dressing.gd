class_name BuffetDressing
extends RefCounted
## The hand-dressed pass for the Endless Buffet (docs/art/buffet_slice.md, Part C): a few zone kit clusters (data/art/zone_kits/buffet_clusters.json) tucked
## beside the hub's things, the show kitchen's stage, the bakery door, the freezer terrace and the road north, and the kit's ground decals (flour dust at the
## ovens and the bakery, steam at the fountain, the pots and the stew pot). Nothing goes on a route, in the plaza middle, on the bridge head, on the Test
## Kitchen's forecourt or within reach of an anchor or a chest. Placement respects walkability; solid pieces register blockers. The generic furniture scatter is
## off for this zone (BF-9).

var root: Node3D
var count: int = 0
var _builder: BuffetBuilder
var _anchors: Array[Vector3] = []
var _chests: Array[Vector3] = []
var _placed: Array[Vector2] = []

## cluster, anchor ("" = the offset is a world position), offset (x, z) from the anchor, yaw (the back of the cluster faces -z rotated by yaw).
const KIT_CLUSTERS: Array = [
	["banquet_corner", "heal", Vector2(-4.5, 1.0), 180.0],
	["stock_pots", "oven", Vector2(-0.5, 3.5), 180.0],
	["flour_store", "old_meatloaf", Vector2(-4.5, 3.0), 160.0],
	["herb_bed", "quiz", Vector2(4.0, 4.0), 0.0],
	["cutlery_marker", "hub", Vector2(-5.5, -15.0), 0.0],
	["cutlery_marker", "hub", Vector2(6.0, -15.5), 0.0],
	["pastry_display", "", Vector2(54.8, 27.6), 90.0],
	["banquet_corner", "minigame", Vector2(5.5, -3.0), 0.0],
	["stock_pots", "taste_test", Vector2(3.5, -2.5), 200.0],
	["herb_bed", "mini_dungeon", Vector2(-5.0, -1.5), 0.0],
	["herb_bed", "", Vector2(44.5, 27.0), 180.0],
	["flour_store", "", Vector2(84.5, 20.5), 0.0],
]
## kit decal id, anchor ("" = world position), offset, size (m), yaw.
const DECALS: Array = [
	["BUFF-DEC-FLOUR", "oven", Vector2(-1.6, 2.4), 1.6, 20.0], ["BUFF-DEC-FLOUR", "", Vector2(40.0, 60.0), 2.0, 0.0], ["BUFF-DEC-FLOUR", "", Vector2(60.0, 60.0), 2.0, 70.0],
	["BUFF-DEC-FLOUR", "", Vector2(55.0, 27.0), 1.4, 110.0], ["BUFF-DEC-FLOUR", "old_meatloaf", Vector2(-2.6, 1.0), 1.2, 0.0],
	["BUFF-DEC-STEAM", "soup_fountain", Vector2(2.4, 1.2), 1.6, 0.0], ["BUFF-DEC-STEAM", "oven", Vector2(3.4, 1.4), 1.4, 40.0],
	["BUFF-DEC-STEAM", "", Vector2(50.0, 49.2), 2.0, 0.0], ["BUFF-DEC-STEAM", "puzzle", Vector2(0.0, 2.0), 1.6, 0.0], ["BUFF-DEC-STEAM", "taste_test", Vector2(2.0, 1.6), 1.3, 0.0],
]


static func build(parent: Node3D, builder: BuffetBuilder, quality: int) -> BuffetDressing:
	var dressing: BuffetDressing = BuffetDressing.new()
	dressing.root = Node3D.new()
	dressing.root.name = "BuffetDressing"
	parent.add_child(dressing.root)
	dressing._builder = builder
	for key: Variant in builder.layout.anchors.keys():
		dressing._anchors.append(builder.anchor(str(key)))
	for pos: Variant in builder.layout.chests.values():
		dressing._chests.append(pos as Vector3)
	dressing._kit_clusters()
	if quality > 0:
		dressing._decals()
	return dressing


func _at(anchor: String, offset: Vector2) -> Vector3:
	if anchor == "":
		return Vector3(offset.x, 0.0, offset.y)
	return _builder.anchor(anchor) + Vector3(offset.x, 0.0, offset.y)


func _kit_clusters() -> void:
	var index: int = 0
	for entry: Array in KIT_CLUSTERS:
		index += 1
		var anchor: String = str(entry[1])
		if anchor != "" and not _builder.has_anchor(anchor):
			continue
		var pos: Vector3 = _at(anchor, entry[2] as Vector2)
		pos.y = _builder.layout.ground_height(pos.x, pos.z)
		var cluster: Node3D = PropClusters.make(str(entry[0]), 700 + index)
		if cluster == null:
			continue
		var solid: bool = not (cluster.get_meta("circles", []) as Array).is_empty()
		if not _free(pos, 3.0, 2.0, solid):
			cluster.free()
			continue
		cluster.name = "Cluster_%s_%d" % [str(entry[0]), index]
		root.add_child(cluster)
		cluster.position = pos
		cluster.rotation_degrees.y = float(entry[3])
		_placed.append(Vector2(pos.x, pos.z))
		var basis: Basis = Basis(Vector3.UP, deg_to_rad(float(entry[3])))
		for circle: Variant in cluster.get_meta("circles", []) as Array:
			var local: Vector3 = circle as Vector3
			var world: Vector3 = pos + basis * Vector3(local.x, 0.0, local.y)
			_builder.add_blocker(Vector3(world.x, 0.0, world.z), local.z)
		count += 1


## Free ground for a piece of dressing: walkable table ground, off the routes (solid pieces), off the plaza, the bridge head and the forecourt, `clearance`
## from every anchor, 2 m from every chest, `spacing` from the other pieces.
func _free(pos: Vector3, clearance: float, spacing: float, solid: bool = true) -> bool:
	if not _builder.is_walkable(pos, 0.6) or not _builder.is_floor_at(pos):
		return false
	var layout: BuffetLayout = _builder.layout
	if solid and layout.path_edge_distance(pos.x, pos.z) < BuffetLayout.PATH_CLEARANCE:
		return false
	var hub: Vector3 = layout.anchors["hub"] as Vector3
	if Vector2(pos.x - hub.x, pos.z - hub.z).length() < BuffetLayout.PLAZA_RADIUS + (1.0 if solid else 0.0):
		return false
	if Vector2(pos.x - BuffetLayout.BRIDGE_X, pos.z - BuffetLayout.BRIDGE_Z0).length() < 6.0:
		return false
	if BuffetLayout.FORECOURT.grow(1.0).has_point(Vector2(pos.x, pos.z)):
		return false
	for anchor: Vector3 in _anchors:
		if Vector2(pos.x - anchor.x, pos.z - anchor.z).length() < clearance:
			return false
	for chest: Vector3 in _chests:
		if Vector2(pos.x - chest.x, pos.z - chest.z).length() < 2.0:
			return false
	for other: Vector2 in _placed:
		if other.distance_to(Vector2(pos.x, pos.z)) < spacing:
			return false
	return true


## Flat kit decals just above the ground.
func _decals() -> void:
	var by_id: Dictionary = {}
	for entry: Array in DECALS:
		var id: String = str(entry[0])
		var anchor: String = str(entry[1])
		if not EnvKit.has(id) or (anchor != "" and not _builder.has_anchor(anchor)):
			continue
		var pos: Vector3 = _at(anchor, entry[2] as Vector2)
		if not _builder.is_floor_at(pos):
			continue
		pos.y = _builder.layout.ground_height(pos.x, pos.z)
		var size: float = float(entry[3])
		var yaw: float = deg_to_rad(float(entry[4]))
		var aspect: float = EnvKit.aspect(id)
		var half: Vector2 = Vector2(size * minf(aspect, 1.0), size * minf(1.0 / maxf(aspect, 0.001), 1.0)) * 0.5
		var basis: Basis = Basis(Vector3.UP, yaw)
		var mesh: KitMesh = by_id.get(id) as KitMesh
		if mesh == null:
			mesh = KitMesh.new()
			var material: StandardMaterial3D = EnvKit.material(id, true).duplicate() as StandardMaterial3D
			material.render_priority = 4
			material.cull_mode = BaseMaterial3D.CULL_BACK
			mesh.set_material("decal", material)
			by_id[id] = mesh
		var corners: Array[Vector3] = []
		for corner: Vector2 in [Vector2(-1, 1), Vector2(1, 1), Vector2(1, -1), Vector2(-1, -1)]:
			corners.append(pos + basis * Vector3(corner.x * half.x, 0.05, corner.y * half.y))
		mesh.quad("decal", corners, Vector3.UP, [], BuffetLandmarks.CARD_UVS)
		count += 1
	for id: String in by_id.keys():
		var instance: MeshInstance3D = (by_id[id] as KitMesh).instance("Decals_%s" % id)
		instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		instance.set_meta(PaintedClasses.META_NO_PAINT, true)
		instance.set_meta(&"no_occlusion_fade", true)
		root.add_child(instance)
