class_name GainlandsRoads
extends RefCounted
## Gainlands v2, Part B: what makes the three routes read from the plaza (docs/art/gainlands_v2.md): a kerb of dressed sandstone along both edges of every
## paved route (one MultiMesh), and down the middle, left and right roads lamp posts and banner posts on alternate sides every POST_SPACING metres, just
## outside the paving. The paving itself is the painted terrain's road layer (the layout's path mask). Posts are kit props merged by `KitBatch`.

const POST_SPACING: float = 9.0
const KERB_STEP: float = 0.95
const ROUTES: Array[String] = ["middle", "left", "right"]

var root: Node3D
## Where the posts stand (x, z), for the tests: all off the paving, on the land.
var posts: Array[Vector2] = []
var kerb_count: int = 0


static func build(parent: Node3D, builder: GainlandsBuilder) -> GainlandsRoads:
	var roads: GainlandsRoads = GainlandsRoads.new()
	roads.root = Node3D.new()
	roads.root.name = "GainlandsRoads"
	parent.add_child(roads.root)
	roads._kerbs(builder)
	roads._posts(builder)
	KitBatch.merge_static(roads.root)
	return roads


func _kerb_ok(builder: GainlandsBuilder, p: Vector2) -> bool:
	var layout: GainlandsLayout = builder.layout
	if GainlandsLayout.level_at(p.x, p.y) == 0 or GainlandsLayout.main_edge_distance(p.x, p.y) < 0.4:
		return false
	if GainlandsLayout.on_stairs(p.x, p.y) or GainlandsLayout.STAIRS.grow(0.8).has_point(p):
		return false
	# not across another road (junctions stay open) and never in the plaza
	if layout.path_edge_distance(p.x, p.y) < 0.05:
		return false
	var hub: Vector3 = layout.anchors["hub"] as Vector3
	if Vector2(p.x - hub.x, p.y - hub.z).length() < GainlandsLayout.PLAZA_RADIUS + 3.5:
		return false
	for rect: Rect2 in layout.blocker_rects:
		if rect.grow(0.6).has_point(p):
			return false
	return true


func _kerbs(builder: GainlandsBuilder) -> void:
	var transforms: Array[Transform3D] = []
	var layout: GainlandsLayout = builder.layout
	for path: Dictionary in layout.paths:
		var line: PackedVector2Array = path["line"] as PackedVector2Array
		var offset: float = float(path["width"]) * 0.5 + 0.18
		for i: int in range(line.size() - 1):
			var a: Vector2 = line[i]
			var b: Vector2 = line[i + 1]
			var length: float = a.distance_to(b)
			if length < 0.5:
				continue
			var along: Vector2 = (b - a) / length
			var side_dir: Vector2 = Vector2(-along.y, along.x)
			var steps: int = int(length / KERB_STEP)
			for step: int in range(steps + 1):
				for side: float in [-1.0, 1.0]:
					var p: Vector2 = a + along * (float(step) * KERB_STEP) + side_dir * side * offset
					if not _kerb_ok(builder, p):
						continue
					var y: float = builder.layout.ground_height(p.x, p.y)
					var jitter: float = GainlandsTerrain._noise(p.x, p.y)
					var basis: Basis = Basis(Vector3.UP, atan2(along.x, along.y) + (jitter - 0.5) * 0.25).scaled(Vector3(0.95 + jitter * 0.2, 0.9 + jitter * 0.3, 1.0))
					transforms.append(Transform3D(basis, Vector3(p.x, y - 0.04, p.y)))
	kerb_count = transforms.size()
	if transforms.is_empty():
		return
	var mesh: KitMesh = KitMesh.new()
	mesh.set_material("stone", EnvKit.flat(Color("d7bc94"), "gl2_kerb"))
	mesh.box("stone", Vector3(0, 0.1, 0), Vector3(0.34, 0.26, 0.86), Basis.IDENTITY, 0.06, 0.9)
	var multimesh: MultiMesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = mesh.build()
	multimesh.instance_count = transforms.size()
	for index: int in range(transforms.size()):
		multimesh.set_instance_transform(index, transforms[index])
	var holder: MultiMeshInstance3D = MultiMeshInstance3D.new()
	holder.name = "RoadKerbs"
	holder.multimesh = multimesh
	holder.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	holder.set_meta(&"no_occlusion_fade", true)
	holder.set_meta(&"no_range_cull", true)
	root.add_child(holder)


func _posts(builder: GainlandsBuilder) -> void:
	var layout: GainlandsLayout = builder.layout
	var index: int = 0
	for route_name: String in ROUTES:
		var line: PackedVector2Array = layout.route(route_name)
		var carried: float = POST_SPACING * 0.5
		for i: int in range(line.size() - 1):
			var a: Vector2 = line[i]
			var b: Vector2 = line[i + 1]
			var length: float = a.distance_to(b)
			if length < 0.5:
				continue
			var along: Vector2 = (b - a) / length
			var side_dir: Vector2 = Vector2(-along.y, along.x)
			var t: float = carried
			while t < length:
				var side: float = 1.0 if index % 2 == 0 else -1.0
				var width: float = GainlandsLayout.MIDDLE_PATH_WIDTH if route_name == "middle" else GainlandsLayout.MAIN_PATH_WIDTH
				var p: Vector2 = a + along * t + side_dir * side * (width * 0.5 + 0.75)
				t += POST_SPACING
				if not _post_ok(builder, p):
					continue
				var post: Node3D
				if index % 3 == 1 and EnvKit.has_art("GAIN-PROP-BANNER-POST"):
					# art import Oct 20: the painted banner post (4.2 m) replaces the kit-built one
					post = Node3D.new()
					var card: MeshInstance3D = KitFoliage.card("GAIN-PROP-BANNER-POST", Vector2(4.2, 4.2), true, true)
					card.name = "Card_GAIN-PROP-BANNER-POST"
					post.add_child(card)
				else:
					post = PropKit.make("banner_post" if index % 3 == 1 else "lantern_post")
				post.set_meta("lights", [])  # glowing glass, no real lights (the lantern budget stays with the landmarks)
				root.add_child(post)
				post.position = Vector3(p.x, layout.ground_height(p.x, p.y), p.y)
				post.rotation.y = atan2(-side_dir.x * side, -side_dir.y * side)
				builder.add_blocker(post.position, 0.22)
				posts.append(p)
				index += 1
			carried = t - length


func _post_ok(builder: GainlandsBuilder, p: Vector2) -> bool:
	if not _kerb_ok(builder, p) or GainlandsLayout.main_edge_distance(p.x, p.y) < 0.9:
		return false
	var layout: GainlandsLayout = builder.layout
	if layout.path_edge_distance(p.x, p.y) < 0.4:
		return false
	for key: Variant in layout.anchors.keys():
		var anchor: Vector3 = layout.anchors[key] as Vector3
		if Vector2(p.x - anchor.x, p.y - anchor.z).length() < 2.6:
			return false
	for spawn: Dictionary in layout.enemy_spawns:
		var home: Vector3 = spawn["home"] as Vector3
		if Vector2(p.x - home.x, p.y - home.z).length() < float(spawn.get("guard", 2.0)) + 0.6:
			return false
	for other: Vector2 in posts:
		if other.distance_to(p) < 4.0:
			return false
	return true
