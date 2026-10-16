extends Node3D
## Environment Kit bench: the building presets (and props / clusters / trees) in a row on a calm ground under the town style and the game's low camera, with a 1.25 m scale figure.
##   bash tools/shot.sh res://tools/kit_bench.tscn kit_a --presets=home_a,inn --nohud=true
##   --props=barrel,crate,...   --clusters=doorstep,crates   --trees=oak,pine   --yaw=20   --zoom=1.0   --hero=x,z   --dist=14   --zone=gainlands (that area's swaps and tints)   --landmarks=GAIN-HERO-WHEEL:14x14x6 --dist=14 --lyaw=20 --kind=arch --surface=GAIN-WALL-BRICK

var _args: Dictionary = {}
var _camera: Camera3D
var _hero: Node3D


func screenshot_prepare(args: Dictionary) -> void:
	_args = args


func _ready() -> void:
	# `--zone=gainlands`: the bench takes that area's material swaps and tints (ZoneStyles), so a zone kit can be checked on the shared presets.
	if _args.has("zone"):
		ZoneStyles.use_area(str(_args["zone"]))
	var ground: MeshInstance3D = MeshInstance3D.new()
	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(160, 160)
	ground.mesh = plane
	ground.material_override = EnvKit.material("ENV-GROUND-GRASS-CALM")
	add_child(ground)
	var x: float = 0.0
	var presets: PackedStringArray = str(_args.get("presets", "")).split(",", false)
	var yaw: float = float(_args.get("yaw", 0.0))
	var widths: Array[float] = []
	var nodes: Array[Node3D] = []
	for preset_name: String in presets:
		var node: Node3D = BuildingPresets.build(preset_name)
		add_child(node)
		var size: Vector2 = node.get_meta("footprint") as Vector2
		nodes.append(node)
		widths.append(size.x)
	var total: float = 0.0
	for width: float in widths:
		total += width + 3.0
	x = -total * 0.5
	for index: int in range(nodes.size()):
		x += widths[index] * 0.5
		nodes[index].position = Vector3(x, 0, 0)
		nodes[index].rotation_degrees.y = yaw
		TownKit.dress(self, nodes[index], BuildingPresets.spec(presets[index]))
		x += widths[index] * 0.5 + 3.0
	var props: PackedStringArray = str(_args.get("props", "")).split(",", false)
	var prop_x: float = -float(props.size()) * 1.2
	for prop_name: String in props:
		var prop: Node3D = PropKit.make(prop_name)
		if prop != null:
			add_child(prop)
			prop.position = Vector3(prop_x, 0, 7.0)
		prop_x += 2.4
	var clusters: PackedStringArray = str(_args.get("clusters", "")).split(",", false)
	var cluster_x: float = -float(clusters.size()) * 3.0
	for cluster_name: String in clusters:
		var cluster: Node3D = PropClusters.make(cluster_name, 0, true)
		if cluster != null:
			add_child(cluster)
			cluster.position = Vector3(cluster_x, 0, 11.0)
		cluster_x += 6.0
	# `--landmarks=GAIN-HERO-WHEEL:14x14x6,GAIN-HERO-CHAMPIONS-ARCH:12x8x1.6`: hero landmarks / stand-ins (LandmarkKit) in a row behind the presets, at the given w x h x d.
	var landmarks: PackedStringArray = str(_args.get("landmarks", "")).split(",", false)
	var landmark_x: float = -float(landmarks.size() - 1) * 10.0
	for token: String in landmarks:
		var parts: PackedStringArray = token.split(":")
		var dims: PackedStringArray = (parts[1] if parts.size() > 1 else "10x8x6").split("x")
		var size_list: Array = [float(dims[0]), float(dims[1]) if dims.size() > 1 else 8.0, float(dims[2]) if dims.size() > 2 else 6.0]
		var spec: Dictionary = {"id": parts[0], "kind": str(_args.get("kind", "box")), "size": size_list, "color": "#d9483b", "accent": "#f2c14e"}
		if _args.has("surface"):
			spec["surface"] = str(_args["surface"])
		var landmark: Node3D = LandmarkKit.build(spec)
		add_child(landmark)
		landmark.position = Vector3(landmark_x, 0, -float(_args.get("dist", 14.0)))
		landmark.rotation_degrees.y = float(_args.get("lyaw", 0.0))
		KitLights.attach(landmark, self, null, false)
		landmark_x += 20.0
	var trees: PackedStringArray = str(_args.get("trees", "")).split(",", false)
	var tree_x: float = -float(trees.size()) * 3.0
	for tree_name: String in trees:
		var tree: Node3D = TreeCards.make(tree_name)
		if tree != null:
			add_child(tree)
			tree.position = Vector3(tree_x, 0, 15.0)
		tree_x += 6.0
	_hero = MeshInstance3D.new()
	var capsule: CapsuleMesh = CapsuleMesh.new()
	capsule.radius = 0.25
	capsule.height = 1.25
	(_hero as MeshInstance3D).mesh = capsule
	var marker: StandardMaterial3D = StandardMaterial3D.new()
	marker.albedo_color = Color("e88a3a")
	(_hero as MeshInstance3D).material_override = marker
	add_child(_hero)
	var hero_xz: PackedStringArray = str(_args.get("hero", "0,6")).split(",")
	_hero.position = Vector3(float(hero_xz[0]), 0.62, float(hero_xz[1]))
	_camera = Camera3D.new()
	_camera.fov = 44.0
	add_child(_camera)
	_camera.current = true
	var offset: Vector3 = WorldLookRig.base_offset() * float(_args.get("zoom", 1.5))
	_camera.position = _hero.position + offset
	_camera.look_at(_hero.position + Vector3(0, 0.4, 0), Vector3.UP)
	# --cam=x,y,z --look=x,y,z: a free camera for a landmark too big for the hero framing (the Rotheart, Junk Mountain)
	if _args.has("cam"):
		var cam: PackedStringArray = str(_args["cam"]).split(",")
		var look: PackedStringArray = str(_args.get("look", "0,10,-40")).split(",")
		_camera.position = Vector3(float(cam[0]), float(cam[1]), float(cam[2]))
		_camera.look_at(Vector3(float(look[0]), float(look[1]), float(look[2])), Vector3.UP)
	var rig: StyleRig = StyleRig.install(self, StylePresets.TOWN, _camera, _hero, 0.0)
	if rig != null and not _args.has("cam"):
		WorldLookRig.install(self, _camera, _hero, rig, null, false)
	KitLights.attach(self, self, rig)
