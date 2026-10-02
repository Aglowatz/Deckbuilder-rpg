class_name HeapModels
extends RefCounted
## Loads the Verdant Heap's third-party models: the Kenney Nature Kit (trees, crops, fences, rocks, flowers), Survival
## Kit (scrap shacks, barrels, metal panels), Car Kit (rusting wrecks, tractors, tyres) and Cube Pets (the animated
## animals), plus the Kenney Food Kit for the harvest meal. All CC0. Scenes are cached.

const NATURE: String = "res://assets/kenney-nature-kit/models/"
const SURVIVAL: String = "res://assets/kenney-survival-kit/models/"
const CARS: String = "res://assets/kenney-car-kit/models/"
const PETS: String = "res://assets/kenney-cube-pets/models/"

static var _cache: Dictionary = {}


static func _scene(path: String) -> PackedScene:
	if not _cache.has(path):
		_cache[path] = load(path) as PackedScene
	return _cache[path] as PackedScene


static func _make(folder: String, model: String) -> Node3D:
	var packed: PackedScene = _scene("%s%s.glb" % [folder, model])
	if packed == null:
		push_warning("HeapModels: missing %s%s" % [folder, model])
		return Node3D.new()
	return packed.instantiate() as Node3D


static func nature(model: String) -> Node3D:
	return _make(NATURE, model)


static func survival(model: String) -> Node3D:
	return _make(SURVIVAL, model)


static func car(model: String) -> Node3D:
	return _make(CARS, model)


## An animated Cube Pets animal ("animal-pig", "animal-deer"...). Idle/walk/run/eat loop.
static func pet(model: String) -> Node3D:
	var node: Node3D = _make(PETS, model)
	var player: AnimationPlayer = ModelKit.animation_player(node)
	if player != null:
		for anim_name: StringName in player.get_animation_list():
			var lower: String = String(anim_name).to_lower()
			if lower == "idle" or lower == "walk" or lower == "run" or lower == "eat":
				player.get_animation(anim_name).loop_mode = Animation.LOOP_LINEAR
	return node


static func put(parent: Node3D, node: Node3D, pos: Vector3, yaw: float = 0.0, model_scale: float = 1.0) -> Node3D:
	parent.add_child(node)
	node.position = pos
	node.rotation_degrees.y = yaw
	node.scale = Vector3.ONE * model_scale
	return node
