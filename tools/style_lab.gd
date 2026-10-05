extends Node3D
## A test bench for the style: a row of kit models on a plain ground under a zone preset. Screenshot with
## bash tools/shot.sh res://tools/style_lab.tscn lab --preset=town --models=nature:grass_large,nature:flower_redA,survival:barrel --scale=2

var _args: Dictionary = {}


func screenshot_prepare(args: Dictionary) -> void:
	_args = args


func _ready() -> void:
	var camera: Camera3D = Camera3D.new()
	camera.fov = 38.0
	add_child(camera)
	camera.position = Vector3(0, 4.0, 4.2)
	camera.look_at(Vector3(0, 0.3, 0), Vector3.UP)
	camera.current = true
	var ground: MeshInstance3D = MeshInstance3D.new()
	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(30, 30)
	ground.mesh = plane
	var ground_material: StandardMaterial3D = StandardMaterial3D.new()
	ground_material.albedo_color = Color("6aa850")
	ground.material_override = ground_material
	add_child(ground)
	var kits: Dictionary = {"nature": ModelKit.KENNEY_NATURE, "survival": ModelKit.KENNEY_SURVIVAL, "food": ModelKit.KENNEY_FOOD, "halloween": ModelKit.HALLOWEEN, "restaurant": ModelKit.RESTAURANT}
	var specs: PackedStringArray = str(_args.get("models", "nature:grass_large")).split(",")
	var scale_value: float = float(_args.get("scale", 1.0))
	var index: int = 0
	for spec: String in specs:
		var parts: PackedStringArray = spec.split(":")
		var node: Node3D
		if parts[0] == "hex":
			node = ModelKit.prop(parts[1])
		elif parts[0] == "char":
			node = ModelKit.character(parts[1])
		else:
			node = ModelKit.kit_model(str(kits[parts[0]]), parts[1])
		add_child(node)
		node.position = Vector3((float(index) - float(specs.size() - 1) * 0.5) * 0.9, 0, 0)
		node.scale = Vector3.ONE * scale_value
		index += 1
	StyleRig.install(self, StringName(str(_args.get("preset", "town"))), camera, null)
