class_name PaintedClasses
extends RefCounted
## Part B of the painted texture system: what each flat colour region of the existing models IS (wood, stone, brick, plaster, roof, thatch, metal, rock, bark, foliage), so the toon
## material can replace it with the shared painted material (`TEX-MAT-*`, or the zone's own prop material) without remodelling anything. The palette-atlas packs (KayKit, Kenney
## colormaps) get a small class lookup texture (one class per atlas texel, built once per atlas); flat-colour materials get one fixed class from their name or colour.
## The original hue stays as a subtle tint (shader `paint_keep_hue`), so buildings keep their colour variety. Characters (skinned meshes), hex tiles and anything with the meta
## `no_paint` are never painted.

enum Kind { NONE, WOOD, TIMBER, STONE, BRICK, PLASTER, ROOF, ROOF_BLUE, THATCH, METAL, ROCK, BARK, LEAVES }

const KIND_NAMES: Array[String] = ["none", "wood", "timber", "stone", "brick", "plaster", "roof", "roof_blue", "thatch", "metal", "rock", "bark", "leaves"]
## Default texture per kind (a zone preset's "props" table overrides single entries).
const DEFAULT_TEXTURES: Dictionary = {
	"wood": "mat_woodplanks", "timber": "mat_timber", "stone": "mat_stonewall", "brick": "mat_brick", "plaster": "mat_plaster", "roof": "mat_roof_red",
	"roof_blue": "mat_roof_blue", "thatch": "mat_thatch", "metal": "mat_metal", "rock": "mat_rock", "bark": "mat_bark", "leaves": "mat_leaves",
}
const CLASS_SIZE: int = 128
const META_NO_PAINT: StringName = &"no_paint"
## Atlas texture paths that are painted (substring match); hex tiles and water are excluded on purpose.
const PAINTED_ATLASES: Array[String] = ["hexagons_medieval", "kenney-survival-kit", "kenney-graveyard-kit", "kenney-furniture-kit", "KayKit-Halloween-Bits", "KayKit-Restaurant-Bits", "kenney-car-kit", "chest_gold_dungeon"]
const EXCLUDED_ATLASES: Array[String] = ["tiles/base", "water"]
## Share of buildings that get each roof: red, blue, thatch.
const ROOF_SPLIT: Vector2 = Vector2(0.45, 0.75)

## Active only in zones that have a painted preset (set by `begin_zone`).
static var active: bool = false
static var _table: PackedInt32Array = PackedInt32Array()
static var _atlas_cache: Dictionary = {}
static var _count: int = 0


## Called by `StyleRig` before it converts the zone's meshes: loads the zone's prop table. A zone without a painted preset leaves everything as it was.
static func begin_zone(preset_id: StringName) -> void:
	_atlas_cache.clear()
	_count = 0
	var preset: Dictionary = PaintedLibrary.preset(preset_id)
	active = not preset.is_empty() and OS.get_environment("NO_PAINT") == "" and not OS.get_environment("PAINT_SKIP").contains("props")
	if not active:
		return
	var overrides: Dictionary = preset.get("props", {}) as Dictionary if preset.get("props") is Dictionary else {}
	_table = PackedInt32Array()
	for index: int in range(KIND_NAMES.size()):
		var name: String = str(overrides.get(KIND_NAMES[index], DEFAULT_TEXTURES.get(KIND_NAMES[index], "")))
		_table.append(maxi(PaintedLibrary.layer_index(name), 0))


static func painted_count() -> int:
	return _count


## What a colour is. `flat` = a plain flat-colour material (no atlas): only the unambiguous classes are allowed (a green gym bar or a red flag is not foliage or a roof).
static func classify(color: Color, flat: bool, building_atlas: bool = false) -> Kind:
	var h: float = color.h
	var s: float = color.s
	var v: float = color.v
	if v < 0.04:
		return Kind.NONE if flat else Kind.METAL
	if s < 0.14:
		if v > 0.88:
			return Kind.PLASTER
		if v < 0.22:
			return Kind.METAL
		if color.b > color.r + 0.03 and v < 0.7:
			return Kind.METAL
		return Kind.STONE
	if s < 0.24 and v > 0.72 and h > 0.04 and h < 0.17:
		return Kind.PLASTER
	if h < 0.03 or h > 0.96:
		return Kind.NONE if flat else (Kind.ROOF if s > 0.45 else Kind.NONE)
	if h < 0.12:
		if s > 0.7 and v > 0.65:
			return Kind.NONE if flat else Kind.ROOF
		return Kind.TIMBER if v < 0.42 else Kind.WOOD
	if h < 0.19:
		if s > 0.55 and v > 0.6:
			return Kind.NONE if flat else Kind.THATCH
		if v > 0.7:
			return Kind.PLASTER
		return Kind.WOOD
	if h < 0.46:
		return Kind.NONE if flat else Kind.LEAVES
	if h < 0.72 and building_atlas and not flat:
		return Kind.ROOF_BLUE
	return Kind.NONE


## Kinds that follow from a material's own name (Kenney nature kit: woodBark, leafsGreen, stone ...); NONE when the name says nothing.
static func classify_name(material_name: String) -> Kind:
	var lower: String = material_name.to_lower()
	if lower == "":
		return Kind.NONE
	if lower.contains("bark"):
		return Kind.BARK
	if lower.begins_with("leafs") or lower.contains("leaves") or lower.contains("foliage"):
		return Kind.LEAVES
	if lower.begins_with("stone") or lower.contains("rock"):
		return Kind.ROCK
	if lower.begins_with("wood") and not lower.contains("birch") and not lower.contains("inner"):
		return Kind.WOOD
	return Kind.NONE


static func is_painted_atlas(path: String) -> bool:
	for excluded: String in EXCLUDED_ATLASES:
		if path.contains(excluded):
			return false
	for allowed: String in PAINTED_ATLASES:
		if path.contains(allowed):
			return true
	return false


## Builds the one-class-per-texel lookup of an atlas (cached per atlas texture); null when the image cannot be read.
static func atlas_classes(texture: Texture2D, building_atlas: bool) -> Texture2D:
	var key: int = texture.get_instance_id()
	if _atlas_cache.has(key):
		return _atlas_cache[key] as Texture2D
	var image: Image = texture.get_image()
	if image == null:
		return null
	if image.is_compressed():
		image.decompress()
	image.convert(Image.FORMAT_RGBA8)
	var size: int = mini(CLASS_SIZE * 2 if image.get_width() <= 512 else CLASS_SIZE, image.get_width())
	image.resize(size, size, Image.INTERPOLATE_NEAREST)
	var classes: Image = Image.create(size, size, false, Image.FORMAT_R8)
	for y: int in range(size):
		for x: int in range(size):
			var color: Color = image.get_pixel(x, y)
			var kind: int = Kind.NONE if color.a < 0.5 else int(classify(color, false, building_atlas))
			classes.set_pixel(x, y, Color(float(kind) / 255.0, 0.0, 0.0))
	var result: ImageTexture = ImageTexture.create_from_image(classes)
	_atlas_cache[key] = result
	return result


## Sets the painted-material uniforms of a toon material built from `standard` (called by StyleToon.toon_for). Returns true when the material is painted.
static func configure(material: ShaderMaterial, standard: StandardMaterial3D) -> bool:
	if not active:
		return false
	var texture: Texture2D = standard.albedo_texture
	var fixed: int = 0
	var class_texture: Texture2D = null
	if texture != null:
		var path: String = texture.resource_path
		if not is_painted_atlas(path):
			return false
		class_texture = atlas_classes(texture, path.contains("buildings/"))
		if class_texture == null:
			return false
	else:
		if standard.vertex_color_use_as_albedo or standard.emission_enabled:
			return false
		var kind: Kind = classify_name(standard.resource_name)
		if kind == Kind.NONE:
			kind = classify(standard.albedo_color, true)
		if kind == Kind.NONE:
			return false
		fixed = int(kind)
	material.set_shader_parameter("paint_on", true)
	material.set_shader_parameter("paint_layers", PaintedLibrary.material_array())
	material.set_shader_parameter("paint_fixed", fixed)
	if class_texture != null:
		material.set_shader_parameter("paint_class", class_texture)
	material.set_shader_parameter("class_layer", _table)
	var thatch_index: int = int(_table[int(Kind.THATCH)])
	material.set_shader_parameter("roof_layers", Vector3i(int(_table[int(Kind.ROOF)]), int(_table[int(Kind.ROOF_BLUE)]), thatch_index))
	_count += 1
	return true


## Roof variety: a stable 0..1 value per building (its instanced model root), so a building's walls and roof agree and neighbours differ.
static func roof_value(mesh_instance: MeshInstance3D) -> float:
	var node: Node = mesh_instance
	var model_root: Node3D = mesh_instance
	while node != null:
		if node is Node3D and (node as Node3D).scene_file_path != "":
			model_root = node as Node3D
		node = node.get_parent()
	var pos: Vector3 = model_root.position
	var hashed: float = absf(sin(pos.x * 12.9898 + pos.z * 78.233 + 4.1)) * 43758.5453
	return hashed - floor(hashed)


## True when this mesh may be painted (not a character, not a hex tile, no `no_paint` meta up the tree).
static func allowed_for(mesh_instance: MeshInstance3D) -> bool:
	if mesh_instance.skin != null or mesh_instance.get_parent() is Skeleton3D:
		return false
	var node: Node = mesh_instance
	while node != null:
		if node.has_meta(META_NO_PAINT):
			return false
		node = node.get_parent()
	return true
