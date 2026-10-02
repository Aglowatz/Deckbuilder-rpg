class_name BuffetModels
extends RefCounted
## Loads the Endless Buffet's third-party models: the Kenney Food Kit (CC0, the giant food) and the KayKit
## Restaurant Bits (CC0, kitchen counters, stoves, fridges and pots). Scenes are cached.

const FOOD: String = "res://assets/kenney-food-kit/models/"
const RESTAURANT: String = "res://assets/KayKit-Restaurant-Bits-1.0/gltf/"

static var _cache: Dictionary = {}


static func _scene(path: String) -> PackedScene:
	if not _cache.has(path):
		_cache[path] = load(path) as PackedScene
	return _cache[path] as PackedScene


## A Kenney Food Kit model; `model` is the file name without ".glb".
static func food(model: String) -> Node3D:
	var packed: PackedScene = _scene("%s%s.glb" % [FOOD, model])
	if packed == null:
		push_warning("BuffetModels: missing food model %s" % model)
		return Node3D.new()
	return packed.instantiate() as Node3D


## A KayKit Restaurant Bits model; `model` is the file name without ".gltf".
static func restaurant(model: String) -> Node3D:
	var packed: PackedScene = _scene("%s%s.gltf" % [RESTAURANT, model])
	if packed == null:
		push_warning("BuffetModels: missing restaurant model %s" % model)
		return Node3D.new()
	return packed.instantiate() as Node3D


## A node of `model` placed under `parent` (food) with position, yaw (degrees) and uniform scale.
static func put_food(parent: Node3D, model: String, pos: Vector3, yaw: float = 0.0, model_scale: float = 1.0) -> Node3D:
	var node: Node3D = food(model)
	parent.add_child(node)
	node.position = pos
	node.rotation_degrees.y = yaw
	node.scale = Vector3.ONE * model_scale
	return node


static func put_restaurant(parent: Node3D, model: String, pos: Vector3, yaw: float = 0.0, model_scale: float = 1.0) -> Node3D:
	var node: Node3D = restaurant(model)
	parent.add_child(node)
	node.position = pos
	node.rotation_degrees.y = yaw
	node.scale = Vector3.ONE * model_scale
	return node
