extends Node3D
## Environment Kit bench: the building presets (and props / clusters / trees) in a row on a calm ground under the town style and the game's low camera, with a 1.25 m scale figure.
##   bash tools/shot.sh res://tools/kit_bench.tscn kit_a --presets=home_a,inn --nohud=true
##   --props=barrel,crate,...   --clusters=doorstep,crates   --trees=oak,pine   --yaw=20   --zoom=1.0   --hero=x,z   --dist=14

var _args: Dictionary = {}
var _camera: Camera3D
var _hero: Node3D


func screenshot_prepare(args: Dictionary) -> void:
	_args = args


func _ready() -> void:
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
	var rig: StyleRig = StyleRig.install(self, StylePresets.TOWN, _camera, _hero, 0.0)
	if rig != null:
		WorldLookRig.install(self, _camera, _hero, rig, null, false)
	KitLights.attach(self, self, rig)
