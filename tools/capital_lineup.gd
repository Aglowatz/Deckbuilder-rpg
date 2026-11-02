extends Node3D
## Capital rebuild (Nov 1-2): look-dev lineup of the grand pieces (CapitalGrand) on a pale paved ground under the Capital's inside style.
##   bash tools/shot.sh res://tools/capital_lineup.tscn lineup_houses --pieces=house_hip,house_mansard,house_gable --nohud=true
##   --pieces=<name,...>  house_hip | house_mansard | house_gable | house_tall | tower | tower_pink | statue | statue_fallen | fountain | lamp |
##                       planter | old_house | old_fountain
##   --final=true (the fallen state)   --cam=x,y,z --look=x,y,z (a free camera)   --gap=<m>

var _args: Dictionary = {}
var _camera: Camera3D
var _hero: MeshInstance3D


func screenshot_prepare(args: Dictionary) -> void:
	_args = args


func _piece(piece_name: String, final_state: bool) -> Node3D:
	match piece_name:
		"house_hip":
			return CapitalGrand.townhouse({"storeys": 3, "bays": 3, "accent": "pink", "roof": "hip", "final": final_state})
		"house_mansard":
			return CapitalGrand.townhouse({"storeys": 4, "bays": 3, "accent": "sage", "roof": "mansard", "final": final_state})
		"house_gable":
			return CapitalGrand.townhouse({"storeys": 3, "bays": 3, "accent": "lavender", "roof": "gable", "final": final_state, "door": "CAP-SHEET-DOORS-05"})
		"house_tall":
			return CapitalGrand.townhouse({"storeys": 5, "bays": 2, "accent": "blue", "roof": "hip", "final": final_state, "w": 4.0, "d": 4.0, "banner_roll": 1.0})
		"tower":
			return CapitalGrand.tower(16.0, 1.1, "roof_blue", final_state)
		"tower_pink":
			return CapitalGrand.tower(20.0, 1.3, "roof_pink", final_state)
		"statue":
			return CapitalGrand.statue_plinth(3.2, 4.4, final_state, false)
		"statue_fallen":
			return CapitalGrand.statue_plinth(3.2, 4.4, true, true)
		"fountain":
			return CapitalGrand.fountain(4.7, final_state)
		"old_fountain":
			return CapitalLandmarks.fountain(final_state)
		"old_house":
			return CapitalDistricts.facade_houses([Rect2(-2.0, -2.0, 4.0, 4.0)], [3.4])
		"lamp":
			var root: Node3D = Node3D.new()
			var lamp: MeshInstance3D = MeshInstance3D.new()
			lamp.mesh = CapitalGrand.lamp_mesh(3.8, true)
			root.add_child(lamp)
			var banner: MeshInstance3D = MeshInstance3D.new()
			banner.mesh = CapitalGrand.lamp_banner_mesh(3.8, 0.0)
			root.add_child(banner)
			root.set_meta("height", 4.0)
			return root
		"planter":
			var root: Node3D = Node3D.new()
			var mesh: KitMesh = CapitalGrand.mesh_for(final_state)
			var roses: Array[Vector3] = CapitalGrand.planter_run(mesh, Vector3(-3.0, 0, 0), Vector3(3.0, 0, 0), 0.9)
			CapitalGrand.planter_box(mesh, Vector3(-4.0, 0, 0), 1.1)
			CapitalGrand.planter_box(mesh, Vector3(4.0, 0, 0), 1.1)
			CapitalGrand.border(mesh, Vector3(-5.0, 0, 1.5), Vector3(5.0, 0, 1.5), 0.6)
			CapitalLandmarks.finish(root, mesh, [], 1.0)
			var entries: Array[Dictionary] = []
			for p: Vector3 in roses:
				entries.append({"pos": p, "scale": 0.9})
			KitFoliage.tree_field(root, "cap_rose", entries, false)
			KitFoliage.tree_field(root, "cap_topiary", [{"pos": Vector3(-4.0, 0.5, 0), "scale": 1.0}, {"pos": Vector3(4.0, 0.5, 0), "scale": 1.0}] as Array[Dictionary], true)
			root.set_meta("height", 3.0)
			return root
	return null


func _ready() -> void:
	ZoneStyles.use_area("capital_inside")
	var ground: MeshInstance3D = MeshInstance3D.new()
	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(200, 200)
	ground.mesh = plane
	ground.material_override = EnvKit.material("CAP-PATH-WHITE")
	add_child(ground)
	var final_state: bool = str(_args.get("final", "false")) == "true"
	var names: PackedStringArray = str(_args.get("pieces", "house_hip,tower,statue,fountain")).split(",", false)
	var gap: float = float(_args.get("gap", 3.0))
	var nodes: Array[Node3D] = []
	var widths: Array[float] = []
	var tallest: float = 4.0
	for piece_name: String in names:
		var node: Node3D = _piece(piece_name, final_state)
		if node == null:
			continue
		add_child(node)
		var box: AABB = _bounds(node)
		nodes.append(node)
		widths.append(maxf(box.size.x, 2.0))
		tallest = maxf(tallest, box.end.y)
	var total: float = 0.0
	for width: float in widths:
		total += width + gap
	var x: float = -total * 0.5
	for index: int in range(nodes.size()):
		x += widths[index] * 0.5
		nodes[index].position = Vector3(x, 0, 0)
		x += widths[index] * 0.5 + gap
	_hero = MeshInstance3D.new()
	var capsule: CapsuleMesh = CapsuleMesh.new()
	capsule.radius = 0.3
	capsule.height = 1.7
	_hero.mesh = capsule
	var marker: StandardMaterial3D = StandardMaterial3D.new()
	marker.albedo_color = Color("e88a3a")
	_hero.material_override = marker
	add_child(_hero)
	_hero.position = Vector3(0, 0.85, 4.0)
	_camera = Camera3D.new()
	_camera.fov = 44.0
	add_child(_camera)
	_camera.current = true
	var dist: float = maxf(total * 0.9, tallest * 1.6)
	_camera.position = Vector3(0, tallest * 0.55 + 2.0, dist)
	_camera.look_at(Vector3(0, tallest * 0.4, 0), Vector3.UP)
	if _args.has("cam"):
		var cam: PackedStringArray = str(_args["cam"]).split(",")
		var look: PackedStringArray = str(_args.get("look", "0,4,0")).split(",")
		_camera.position = Vector3(float(cam[0]), float(cam[1]), float(cam[2]))
		_camera.look_at(Vector3(float(look[0]), float(look[1]), float(look[2])), Vector3.UP)
	StyleRig.install(self, StylePresets.CAPITAL_INSIDE, _camera, _hero, 0.0)


static func _bounds(node: Node3D) -> AABB:
	var box: AABB = AABB()
	var first: bool = true
	for mesh: Node in node.find_children("*", "VisualInstance3D", true, false):
		var local: AABB = (mesh as VisualInstance3D).get_aabb()
		var world: AABB = (mesh as Node3D).transform * local
		if first:
			box = world
			first = false
		else:
			box = box.merge(world)
	return box
