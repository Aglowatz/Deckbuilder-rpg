class_name DnaDressing
extends RefCounted
## The hand-dressed pass for the D.N.A. hub (docs/art/dna_slice.md, Part C): a few zone kit clusters (data/art/zone_kits/dna_clusters.json) tucked against the walls
## of the lobby, the breakroom, the mail room, the elevator bank, the records basement and the farms, and the kit's ground decals (coffee rings on the office floors,
## queue footprints along the way in and the main route). Nothing goes on a route, in the plaza middle, within reach of an anchor or a chest, or in the executive
## court (the Hall's forecourt stays open). Placement respects walkability; solid pieces register blockers. The generic furniture scatter is off for this zone (DN-5).

var root: Node3D
var count: int = 0
var _builder: DnaBuilder
var _anchors: Array[Vector3] = []
var _placed: Array[Vector2] = []

## cluster, anchor, offset (x, z) from the anchor, yaw (the back of the cluster faces -z rotated by yaw: 0 north wall, 90 west wall, 180 south wall, -90 east wall).
const KIT_CLUSTERS: Array = [
	["cabinet_row", "lobby_center", Vector2(-8.0, 1.6), 90.0],
	["lily_nook", "lobby_center", Vector2(-7.2, 4.8), 180.0],
	["paper_towers", "breakroom_center", Vector2(3.0, -4.2), 0.0],
	["paper_towers", "mail_center", Vector2(7.0, 2.8), 180.0],
	["lamp_planter", "bank_center", Vector2(-7.0, 2.4), 180.0],
	["cabinet_row", "records_center", Vector2(-9.0, -8.6), 0.0],
	["paper_towers", "farm_b_center", Vector2(13.0, -8.6), 0.0],
	["clerk_desk", "farm_a_center", Vector2(-13.0, 8.0), 180.0],
]
## kit decal id, anchor, offset, size (m), yaw.
const DECALS: Array = [
	["DNA-DEC-COFFEE", "breakroom_center", Vector2(-1.5, -1.2), 1.1, 20.0], ["DNA-DEC-COFFEE", "breakroom_center", Vector2(2.6, 1.0), 0.9, 140.0],
	["DNA-DEC-COFFEE", "coffee", Vector2(0.4, 1.4), 0.8, 300.0], ["DNA-DEC-COFFEE", "lobby_center", Vector2(5.5, 2.2), 1.0, 60.0],
	["DNA-DEC-COFFEE", "farm_a_center", Vector2(2.0, 1.0), 0.9, 10.0], ["DNA-DEC-COFFEE", "farm_b_center", Vector2(-3.0, 1.0), 0.9, 200.0],
	["DNA-DEC-FOOT", "spawn", Vector2(0.0, -2.6), 2.6, 0.0], ["DNA-DEC-FOOT", "gate", Vector2(0.3, 2.2), 2.4, 4.0],
	["DNA-DEC-FOOT", "gate", Vector2(-0.3, -2.6), 2.4, -3.0], ["DNA-DEC-FOOT", "lobby_center", Vector2(0.4, -4.6), 2.4, 2.0],
	["DNA-DEC-FOOT", "lobby_center", Vector2(-0.3, -9.4), 2.4, -5.0], ["DNA-DEC-FOOT", "mail_center", Vector2(0.2, 5.0), 2.6, 3.0],
	["DNA-DEC-FOOT", "mail_center", Vector2(-0.2, -5.6), 2.6, -2.0], ["DNA-DEC-FOOT", "bank_center", Vector2(0.0, -2.2), 2.4, 1.0],
]


static func build(parent: Node3D, builder: DnaBuilder, quality: int) -> DnaDressing:
	var dressing: DnaDressing = DnaDressing.new()
	dressing.root = Node3D.new()
	dressing.root.name = "DnaDressing"
	parent.add_child(dressing.root)
	dressing._builder = builder
	for key: Variant in builder.layout.anchors.keys():
		dressing._anchors.append(builder.anchor(str(key)))
	for pos: Variant in builder.layout.chests.values():
		dressing._anchors.append(pos as Vector3)
	dressing._kit_clusters()
	if quality > 0:
		dressing._decals()
	return dressing


func _kit_clusters() -> void:
	var index: int = 0
	for entry: Array in KIT_CLUSTERS:
		index += 1
		if not _builder.has_anchor(str(entry[1])):
			continue
		var offset: Vector2 = entry[2] as Vector2
		var pos: Vector3 = _builder.anchor(str(entry[1])) + Vector3(offset.x, 0.0, offset.y)
		if not _free(pos, 2.4, 2.0):
			continue
		var cluster: Node3D = PropClusters.make(str(entry[0]), 500 + index)
		if cluster == null:
			continue
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


## Free floor for a piece of dressing: walkable, `clearance` from every anchor and chest, `spacing` from the other pieces, off the plaza middle, off the executive court,
## off the approach and off the doorways (any cell within 2 m whose floor kind differs is a doorway or a room edge).
func _free(pos: Vector3, clearance: float, spacing: float) -> bool:
	if not _builder.is_walkable(pos, 0.6):
		return false
	var layout: DnaLayout = _builder.layout
	if Vector2(pos.x - layout.anchors["lobby_center"].x, pos.z - layout.anchors["lobby_center"].z).length() < 5.5:
		return false
	var room: DnaLayout.Room = layout.room_at(pos)
	if room == null or room.id == "exec":
		return false
	if DnaLayout.on_approach(pos.x, pos.z):
		return false
	for anchor: Vector3 in _anchors:
		if Vector2(pos.x - anchor.x, pos.z - anchor.z).length() < clearance:
			return false
	for other: Vector2 in _placed:
		if other.distance_to(Vector2(pos.x, pos.z)) < spacing:
			return false
	return true


## Flat kit decals just above the floor (the sub-areas place theirs from data; the hub from this list).
func _decals() -> void:
	var by_id: Dictionary = {}
	for entry: Array in DECALS:
		var id: String = str(entry[0])
		if not EnvKit.has(id) or not _builder.has_anchor(str(entry[1])):
			continue
		var offset: Vector2 = entry[2] as Vector2
		var pos: Vector3 = _builder.anchor(str(entry[1])) + Vector3(offset.x, 0.0, offset.y)
		if not _builder.is_floor_at(pos):
			continue
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
			corners.append(pos + basis * Vector3(corner.x * half.x, 0.045, corner.y * half.y))
		mesh.quad("decal", corners, Vector3.UP, [], DnaLandmarks.CARD_UVS)
		count += 1
	for id: String in by_id.keys():
		var instance: MeshInstance3D = (by_id[id] as KitMesh).instance("Decals_%s" % id)
		instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		instance.set_meta(PaintedClasses.META_NO_PAINT, true)
		instance.set_meta(&"no_occlusion_fade", true)
		root.add_child(instance)
