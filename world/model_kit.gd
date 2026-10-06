class_name ModelKit
extends RefCounted
## Loads and places the KayKit models used by the 3D scenes.

const HEX: String = "res://assets/KayKit-Medieval-Hexagon-Pack-1.0/"
const CHARACTERS: String = "res://assets/KayKit-Character-Pack-Adventures-1.0/Characters/"
const DUNGEON_PROPS: String = "res://assets/KayKit-Dungeon-Remastered-1.0/props/"

static var _cache: Dictionary = {}


static func scene(path: String) -> PackedScene:
	if not _cache.has(path):
		_cache[path] = load(path) as PackedScene
	return _cache[path] as PackedScene


static func hex_model(folder: String, model: String) -> Node3D:
	var packed: PackedScene = scene("%s%s/%s.gltf" % [HEX, folder, model])
	if packed == null:
		push_warning("ModelKit: missing %s/%s" % [folder, model])
		return Node3D.new()
	return packed.instantiate() as Node3D


static func tile(model: String) -> Node3D:
	var node: Node3D = hex_model("tiles/base", model)
	if model == "hex_water":
		StyleWater.apply(node)
	if model == "hex_grass":
		tint(node, Color(0.5, 0.76, 0.5))
	return node


static func building(model: String) -> Node3D:
	return hex_model("buildings/blue", "building_%s_blue" % model)


static func neutral(model: String) -> Node3D:
	return hex_model("buildings/neutral", model)


static func nature(model: String) -> Node3D:
	return hex_model("decoration/nature", model)


static func prop(model: String) -> Node3D:
	return hex_model("decoration/props", model)


static func dungeon_prop(model: String) -> Node3D:
	var packed: PackedScene = scene("%s%s.glb" % [DUNGEON_PROPS, model])
	if packed == null:
		push_warning("ModelKit: missing dungeon prop %s" % model)
		return Node3D.new()
	return packed.instantiate() as Node3D


const ZONE_CHARACTERS: String = "res://assets/kenney-graveyard-kit/models/"


## Brief 5: an animated Kenney Graveyard Kit character (the D.N.A.'s undead staff).
static func zone_character(model: String) -> Node3D:
	var packed: PackedScene = scene("%s%s.glb" % [ZONE_CHARACTERS, model])
	return packed.instantiate() as Node3D


static func character(model: String) -> Node3D:
	var packed: PackedScene = scene("%s%s.glb" % [CHARACTERS, model])
	return packed.instantiate() as Node3D


## Finds the AnimationPlayer inside an imported character and makes idle/walk loop.
static func animation_player(root: Node) -> AnimationPlayer:
	var found: Array[Node] = root.find_children("*", "AnimationPlayer", true, false)
	if found.is_empty():
		return null
	var player: AnimationPlayer = found[0] as AnimationPlayer
	for anim_name: StringName in player.get_animation_list():
		var animation: Animation = player.get_animation(anim_name)
		var lower: String = String(anim_name).to_lower()
		if lower.contains("idle") or lower.contains("walking") or lower.contains("running") or lower.contains("cheer") or lower.contains("spellcasting") or lower.contains("blocking"):
			animation.loop_mode = Animation.LOOP_LINEAR
	return player


static func place(root: Node3D, node: Node3D, position: Vector3, yaw_degrees: float = 0.0, uniform_scale: float = 1.0) -> Node3D:
	root.add_child(node)
	node.position = position
	node.rotation_degrees.y = yaw_degrees
	node.scale = Vector3.ONE * uniform_scale
	return node


## Multiplies the albedo of every mesh under `node` by `tint` (used to grade the tile textures).
static func tint(node: Node, color: Color) -> void:
	for child: Node in node.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance: MeshInstance3D = child as MeshInstance3D
		for surface: int in range(mesh_instance.mesh.get_surface_count()):
			var material: Material = mesh_instance.get_active_material(surface)
			if material is StandardMaterial3D:
				var copy: StandardMaterial3D = (material as StandardMaterial3D).duplicate() as StandardMaterial3D
				copy.albedo_color = copy.albedo_color * color
				mesh_instance.set_surface_override_material(surface, copy)


# ---- More kits for set dressing (Brief 12): Kenney Nature / Survival / Food, KayKit Halloween / Restaurant / Furniture ----------------

const KENNEY_NATURE: String = "res://assets/kenney-nature-kit/models/"
const KENNEY_SURVIVAL: String = "res://assets/kenney-survival-kit/models/"
const KENNEY_FOOD: String = "res://assets/kenney-food-kit/models/"
const HALLOWEEN: String = "res://assets/KayKit-Halloween-Bits-1.0/gltf/"
const RESTAURANT: String = "res://assets/KayKit-Restaurant-Bits-1.0/gltf/"


## An instance of a model from one of the extra kits (`folder` is one of the constants above, `model` the file name without extension).
static func kit_model(folder: String, model: String) -> Node3D:
	var path: String = "%s%s.%s" % [folder, model, "gltf" if folder == HALLOWEEN or folder == RESTAURANT else "glb"]
	var packed: PackedScene = scene(path)
	if packed == null:
		push_warning("ModelKit: missing %s" % path)
		return Node3D.new()
	return packed.instantiate() as Node3D


## The first mesh of a kit model (for MultiMesh scattering), or null.
static func kit_mesh(folder: String, model: String) -> Mesh:
	var node: Node3D = kit_model(folder, model)
	var found: Array[Node] = node.find_children("*", "MeshInstance3D", true, false)
	var mesh: Mesh = null
	if not found.is_empty():
		mesh = (found[0] as MeshInstance3D).mesh
	node.free()
	return mesh
