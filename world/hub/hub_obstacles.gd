class_name HubObstacles
extends Node3D
## Overnight Oct 16, Block 3b: what blocks each zone's road until its gatekeeper is beaten (`Gatekeepers`), at storybook scale (hero 1.7 m,
## door 1.95 m), and its cleared state:
##  - the Gainlands: a timber bridge over the gorge, drawn up against the far side; it swings down and connects when Brick Bronson is beaten;
##  - the D.N.A.: a checkpoint booth and a striped "permit required" barrier arm across the cracked road; the arm rises;
##  - the Endless Buffet: an enormous pantry door in a stone frame across the orchard lane; it unlocks and swings open;
##  - the Verdant Dump: a wall of thorny overgrowth across the forest path; it browns, withers and sinks away.
## The scene keeps the old solid circle in the passage mouth while a road is blocked (walkability is unchanged); this node is the look and the
## clearing animation (`play_cleared`). No lettering anywhere: the permit sign and the keyhole are pictures.

const WOOD_TEX: String = "res://assets/art/textures/mat_woodplanks_albedo.webp"
const STONE_TEX: String = "res://assets/art/textures/mat_stonewall_albedo.webp"
const BARK_TEX: String = "res://assets/art/textures/mat_bark_albedo.webp"
const LEAF_TEX: String = "res://assets/art/textures/mat_leaves_albedo.webp"
const METAL_TEX: String = "res://assets/art/textures/mat_metal_albedo.webp"

## Zone id -> the node that moves when the obstacle clears (bridge deck pivot, barrier arm pivot, door leaves, thorn root).
var movers: Dictionary = {}
## Zone id -> true once cleared (as built, or after the animation).
var cleared: Dictionary = {}
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


static func build(parent: Node3D, town: TownBuilder, flags: Dictionary) -> HubObstacles:
	var node: HubObstacles = HubObstacles.new()
	node.name = "HubObstacles"
	parent.add_child(node)
	node._rng.seed = 404
	for zone_id: String in Gatekeepers.IDS:
		var mouth: Vector3 = town.anchors.get("portal_%s_mouth" % zone_id, Vector3.ZERO) as Vector3
		var out: Vector3 = TownBuilder.PORTAL_OUT.get(zone_id, Vector3(0, 0, -1)) as Vector3
		var is_cleared: bool = Gatekeepers.is_cleared(flags, zone_id)
		node.cleared[zone_id] = is_cleared
		var root: Node3D = Node3D.new()
		root.name = "Obstacle_%s" % zone_id
		node.add_child(root)
		root.position = mouth
		root.rotation.y = atan2(out.x, out.z)  # local +Z points down the road, away from town
		if absf(out.x) > 0.5 and Gatekeepers.obstacle(zone_id) != Gatekeepers.Obstacle.THORNS:
			# The camera looks north: an obstacle across an east or west road would be seen edge-on, so it stands at an angle across the way.
			root.rotation.y += deg_to_rad(-38.0 * signf(out.x))
		match Gatekeepers.obstacle(zone_id):
			Gatekeepers.Obstacle.BRIDGE:
				node._bridge(root, zone_id, is_cleared)
			Gatekeepers.Obstacle.BARRIER:
				node._barrier(root, zone_id, is_cleared)
			Gatekeepers.Obstacle.PANTRY_DOOR:
				node._pantry_door(root, zone_id, is_cleared)
			Gatekeepers.Obstacle.THORNS:
				node._thorns(root, zone_id, is_cleared)
		for child: Node in root.find_children("*", "MeshInstance3D", true, false):
			(child as Node3D).set_meta(&"no_range_cull", true)
	return node


func is_cleared(zone_id: String) -> bool:
	return bool(cleared.get(zone_id, false))


## The clearing animation after a gatekeeper's first defeat (about two seconds; the road opens for good).
func play_cleared(zone_id: String) -> void:
	if is_cleared(zone_id) or not movers.has(zone_id):
		return
	cleared[zone_id] = true
	var mover: Node3D = movers[zone_id] as Node3D
	var tween: Tween = create_tween()
	match Gatekeepers.obstacle(zone_id):
		Gatekeepers.Obstacle.BRIDGE:
			Audio.sfx(&"door")
			tween.tween_property(mover, "rotation:x", 0.0, 2.2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		Gatekeepers.Obstacle.BARRIER:
			Audio.sfx(&"lever_clunk")
			tween.tween_property(mover, "rotation:z", deg_to_rad(82.0), 1.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		Gatekeepers.Obstacle.PANTRY_DOOR:
			Audio.sfx(&"gate_big")
			tween.set_parallel(true)
			for leaf: Node in mover.get_children():
				var side: float = float((leaf as Node3D).get_meta(&"side", 1.0))
				tween.tween_property(leaf, "rotation:y", deg_to_rad(-105.0 * side), 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		Gatekeepers.Obstacle.THORNS:
			Audio.sfx(&"chest_open")
			for part: Node in mover.find_children("*", "MeshInstance3D", true, false):
				var material: StandardMaterial3D = (part as MeshInstance3D).material_override as StandardMaterial3D
				if material != null:
					tween.parallel().tween_property(material, "albedo_color", Color(0.42, 0.3, 0.18), 1.4)
			tween.tween_property(mover, "scale", Vector3(1.05, 0.02, 1.05), 1.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			tween.tween_callback(func() -> void: mover.visible = false)


# ---- The Gainlands: the gorge bridge -----------------------------------------------------------------------------------------------------------


func _bridge(root: Node3D, zone_id: String, is_cleared: bool) -> void:
	var near_lip: float = HubLand.GORGE_FROM
	var span: float = HubLand.GORGE_WIDTH
	var wood: StandardMaterial3D = _textured(WOOD_TEX, Color(0.95, 0.82, 0.66), Vector3(1.0, 1.0, 1.0))
	var dark: StandardMaterial3D = _textured(BARK_TEX, Color(0.62, 0.48, 0.36), Vector3(0.5, 2.0, 1.0))
	# The deck hinges on the FAR lip (it was drawn up from the Gainlands side); rotation.x 0 = lowered, 80 degrees = drawn up.
	var pivot: Node3D = Node3D.new()
	pivot.name = "BridgeDeck"
	pivot.position = Vector3(0.0, 0.05, near_lip + span)
	root.add_child(pivot)
	var plank_count: int = 14
	for i: int in range(plank_count):
		var z: float = -span + (float(i) + 0.5) * span / float(plank_count)
		var plank: MeshInstance3D = _box(Vector3(2.7 + (0.12 if i % 2 == 0 else -0.08), 0.12, span / float(plank_count) * 0.86), wood)
		plank.position = Vector3(_rng.randf_range(-0.05, 0.05), 0.0, z)
		plank.rotation.y = _rng.randf_range(-0.03, 0.03)
		pivot.add_child(plank)
	for side: float in [-1.0, 1.0]:
		var beam: MeshInstance3D = _box(Vector3(0.22, 0.2, span), dark)
		beam.position = Vector3(side * 1.3, -0.1, -span * 0.5)
		pivot.add_child(beam)
		var rail: MeshInstance3D = _box(Vector3(0.08, 0.08, span), dark)
		rail.position = Vector3(side * 1.35, 0.85, -span * 0.5)
		pivot.add_child(rail)
		for k: int in range(5):
			var stake: MeshInstance3D = _box(Vector3(0.1, 0.85, 0.1), dark)
			stake.position = Vector3(side * 1.35, 0.42, -span + float(k) * span / 4.0)
			pivot.add_child(stake)
	pivot.rotation.x = 0.0 if is_cleared else deg_to_rad(80.0)
	movers[zone_id] = pivot
	# Posts on both lips, the crank and chains on the far side (where the muscley gatekeeper's arms reached across).
	for lip: float in [near_lip - 0.2, near_lip + span + 0.2]:
		for side: float in [-1.0, 1.0]:
			var post: MeshInstance3D = _box(Vector3(0.34, 1.9, 0.34), dark)
			post.position = Vector3(side * 1.65, 0.95, lip)
			root.add_child(post)
	var crank: MeshInstance3D = _box(Vector3(0.9, 0.9, 0.3), _textured(METAL_TEX, Color(0.55, 0.5, 0.48), Vector3.ONE))
	crank.position = Vector3(2.4, 0.6, near_lip + span + 0.8)
	root.add_child(crank)


# ---- The D.N.A.: the permit checkpoint ---------------------------------------------------------------------------------------------------------


func _barrier(root: Node3D, zone_id: String, is_cleared: bool) -> void:
	var grey: StandardMaterial3D = _textured(STONE_TEX, Color(0.62, 0.62, 0.68), Vector3(1.0, 1.0, 1.0))
	var booth_wall: StandardMaterial3D = _textured(WOOD_TEX, Color(0.55, 0.57, 0.62), Vector3(1.0, 1.0, 1.0))
	var at: float = -0.9
	# The booth on the road's left, a grey little hut with a flat roof and a window.
	var booth: Node3D = Node3D.new()
	booth.name = "CheckpointBooth"
	booth.position = Vector3(-2.6, 0.0, at - 0.4)
	root.add_child(booth)
	var body: MeshInstance3D = _box(Vector3(1.3, 2.1, 1.3), booth_wall)
	body.position.y = 1.05
	booth.add_child(body)
	var roof: MeshInstance3D = _box(Vector3(1.6, 0.16, 1.6), grey)
	roof.position.y = 2.18
	booth.add_child(roof)
	var window: MeshInstance3D = _box(Vector3(0.05, 0.6, 0.8), _plain(Color(0.7, 0.85, 0.9), true))
	window.position = Vector3(0.66, 1.35, 0.0)
	booth.add_child(window)
	# The arm: red and white stripes, pivoting at the post by the booth; rotation.z 0 = down across the road, 82 degrees = raised.
	var post: MeshInstance3D = _box(Vector3(0.3, 1.1, 0.3), grey)
	post.position = Vector3(-1.75, 0.55, at)
	root.add_child(post)
	var pivot: Node3D = Node3D.new()
	pivot.name = "BarrierArm"
	pivot.position = Vector3(-1.75, 1.0, at)
	root.add_child(pivot)
	var red: StandardMaterial3D = _plain(Color(0.82, 0.18, 0.16))
	var white: StandardMaterial3D = _plain(Color(0.95, 0.93, 0.88))
	var segments: int = 8
	var length: float = 3.9
	for i: int in range(segments):
		var piece: MeshInstance3D = _box(Vector3(length / float(segments), 0.14, 0.14), red if i % 2 == 0 else white)
		piece.position = Vector3((float(i) + 0.5) * length / float(segments), 0.0, 0.0)
		pivot.add_child(piece)
	# The permit sign hanging from the arm: a picture of a stamped form (an IconSign, no letters).
	var plate: MeshInstance3D = _box(Vector3(0.72, 0.5, 0.04), white)
	plate.position = Vector3(2.0, -0.38, 0.0)
	pivot.add_child(plate)
	IconSign.attach(pivot, "ICON-RES-REDTAPE", Vector3(2.0, -0.38, -0.04), 0.42)
	var far_post: MeshInstance3D = _box(Vector3(0.22, 0.95, 0.22), grey)
	far_post.position = Vector3(2.25, 0.47, at)
	root.add_child(far_post)
	pivot.rotation.z = deg_to_rad(82.0) if is_cleared else 0.0
	movers[zone_id] = pivot


# ---- The Endless Buffet: the great pantry door -------------------------------------------------------------------------------------------------


func _pantry_door(root: Node3D, zone_id: String, is_cleared: bool) -> void:
	var stone: StandardMaterial3D = _textured(STONE_TEX, Color(0.98, 0.9, 0.78), Vector3(2.0, 2.0, 1.0))
	var wood: StandardMaterial3D = _textured(WOOD_TEX, Color(0.82, 0.58, 0.36), Vector3(1.0, 2.0, 1.0))
	var iron: StandardMaterial3D = _textured(METAL_TEX, Color(0.36, 0.33, 0.32), Vector3.ONE)
	var at: float = -0.7
	var half_width: float = 2.3
	var height: float = 5.0
	# The frame: two stone jambs and a lintel, wide and tall (the door is two and a half doors high).
	for side: float in [-1.0, 1.0]:
		var jamb: MeshInstance3D = _box(Vector3(0.9, height + 0.6, 1.1), stone)
		jamb.position = Vector3(side * (half_width + 0.45), (height + 0.6) * 0.5, at)
		root.add_child(jamb)
	var lintel: MeshInstance3D = _box(Vector3(half_width * 2.0 + 1.8, 0.9, 1.2), stone)
	lintel.position = Vector3(0.0, height + 0.45, at)
	root.add_child(lintel)
	# A giant fork-and-spoon crest over the door (a picture, no lettering).
	IconSign.attach(root, "ICON-RES-INGREDIENT", Vector3(0.0, height + 0.45, at - 0.62), 0.8)
	var leaves: Node3D = Node3D.new()
	leaves.name = "DoorLeaves"
	leaves.position = Vector3(0.0, 0.0, at)
	root.add_child(leaves)
	for side: float in [-1.0, 1.0]:
		var hinge: Node3D = Node3D.new()
		hinge.set_meta(&"side", side)
		hinge.position = Vector3(side * half_width, 0.0, 0.0)
		leaves.add_child(hinge)
		var leaf: MeshInstance3D = _box(Vector3(half_width, height, 0.28), wood)
		leaf.position = Vector3(-side * half_width * 0.5, height * 0.5, 0.0)
		hinge.add_child(leaf)
		for band_y: float in [0.9, height * 0.5, height - 0.9]:
			var band: MeshInstance3D = _box(Vector3(half_width * 0.96, 0.18, 0.06), iron)
			band.position = Vector3(-side * half_width * 0.5, band_y, -0.17)
			hinge.add_child(band)
		hinge.rotation.y = deg_to_rad(-105.0 * side) if is_cleared else 0.0
	# The lock plate with a keyhole the size of a dinner plate, on the left leaf's edge.
	var plate: MeshInstance3D = _box(Vector3(0.7, 1.0, 0.1), iron)
	plate.position = Vector3(-0.38, 2.0, -0.2)
	(leaves.get_child(0) as Node3D).add_child(plate)
	plate.position = Vector3(half_width - 0.45, 2.0, -0.2)
	movers[zone_id] = leaves


# ---- The Verdant Dump: the thorn wall ----------------------------------------------------------------------------------------------------------


func _thorns(root: Node3D, zone_id: String, is_cleared: bool) -> void:
	var holder: Node3D = Node3D.new()
	holder.name = "ThornWall"
	holder.position = Vector3(0.0, 0.0, -0.6)
	root.add_child(holder)
	# Painted twisted trees (the Dump kit's DUMP-TREE-TWISTED) grown into a wall, with thorny brambles knotted round their feet.
	for i: int in range(7):
		var tree: MeshInstance3D = KitFoliage.card("DUMP-TREE-TWISTED", Vector2(2.6, 3.9) * (0.8 + _rng.randf() * 0.35), false)
		tree.position = Vector3(lerpf(-3.3, 3.3, float(i) / 6.0) + _rng.randf_range(-0.25, 0.25), 0.0, _rng.randf_range(-0.5, 0.3))
		holder.add_child(tree)
	var vine_color: Color = Color(0.2, 0.28, 0.14)
	for i: int in range(12):
		var x: float = lerpf(-3.4, 3.4, float(i) / 15.0) + _rng.randf_range(-0.2, 0.2)
		var height: float = 1.6 + _rng.randf() * 1.6
		var clump: MeshInstance3D = MeshInstance3D.new()
		var sphere: SphereMesh = SphereMesh.new()
		sphere.radius = 0.5 + _rng.randf() * 0.3
		sphere.height = height * 0.55
		sphere.radial_segments = 10
		sphere.rings = 6
		clump.mesh = sphere
		var leaf: StandardMaterial3D = _textured(LEAF_TEX, vine_color.lightened(_rng.randf() * 0.15), Vector3(1.5, 1.5, 1.0))
		clump.material_override = leaf
		clump.position = Vector3(x, height * 0.45, _rng.randf_range(-0.4, 0.4))
		holder.add_child(clump)
		# Thorns: dark spikes sticking out of each clump.
		var spike_material: StandardMaterial3D = _plain(Color(0.25, 0.18, 0.12))
		for k: int in range(6):
			var spike: MeshInstance3D = MeshInstance3D.new()
			var cone: CylinderMesh = CylinderMesh.new()
			cone.top_radius = 0.0
			cone.bottom_radius = 0.06
			cone.height = 0.42
			cone.radial_segments = 5
			spike.mesh = cone
			spike.material_override = spike_material
			var dir: Vector3 = Vector3(_rng.randf_range(-1.0, 1.0), _rng.randf_range(-0.2, 1.0), _rng.randf_range(-1.0, 1.0)).normalized()
			spike.position = clump.position + dir * sphere.radius * 0.9
			spike.basis = Basis(Quaternion(Vector3.UP, dir))
			holder.add_child(spike)
		# Twisted vines between the clumps.
		var vine: MeshInstance3D = _box(Vector3(0.12, height * 1.1, 0.12), _textured(BARK_TEX, Color(0.3, 0.26, 0.18), Vector3.ONE))
		vine.position = Vector3(x + 0.2, height * 0.5, 0.3)
		vine.rotation.z = _rng.randf_range(-0.5, 0.5)
		holder.add_child(vine)
	if is_cleared:
		holder.visible = false
	movers[zone_id] = holder


# ---- helpers -------------------------------------------------------------------------------------------------------------------------------------


func _box(size: Vector3, material: Material) -> MeshInstance3D:
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	return instance


func _textured(path: String, tint: Color, uv_scale: Vector3) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_texture = load(path) as Texture2D
	material.albedo_color = tint
	material.uv1_triplanar = true
	material.uv1_scale = uv_scale * 0.6
	material.roughness = 1.0
	return material


func _plain(color: Color, glossy: bool = false) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.35 if glossy else 1.0
	return material
